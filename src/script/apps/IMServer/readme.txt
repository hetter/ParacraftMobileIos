A Very Simple Instant Messaging Server for Game Applications

Author: LiXizhi
Date: 2010.1.21
Company:ParaEngine

---++ Overview
IMServer is a simple and fast im server for game applications built on top of ParaEngine. 
Alternatively we full-fleged ejabberd IM server, however, we begin to experience crashes now and then with over 10K concurrent users when user activity is high, no matter the server is clustered or not. 

Such IMServer is meant to be small, fast, stable, scalable and memory only IM system. Since it is used mostly in game applications, it can sit behind game servers as a backend module, thus saving the cost of extra user connections.
It is memory only because it does not write anything to database. All roster information is kept in game specific databases. 

The IMServer in a game architecture is given below.

client(s) <----------> game servers(GSL) <----------------> IMServer(s)
The client maintains a persistent TCP connection with a game server. Each game server maintains a TCP connection with one of the IM Server(s). 
IMServer maintains TCP connections with each other IMServer(s), in order to synchronize user presence. 
Ideally, UDP multicast should be used between IMServers however since NPL only support TCP, we will emulate multicast using TCP. 
The multicast emulation makes server scaling more costful, however, in most cases we only needs to scale to 2 or 3 servers to support over 200K active users(enough for most game applications). 

---++ Architecture
IMServer uses a traditional client/server architecture. The client can be a user_client or router_client. A user_client is a user with a single nid; and a router_client can represents a large number(10k) of clients. 
Router_client usually runs in a highly trusted environment, such as game server. For example, the game server can use it to communicate with an im server for all authenticated users on the game server.  

So the following communication method is possible. And the top one is the recommended usage since it saves user connections. Please note the router_client act both as a proxy server(for user_client) and a client to im server. 
clients(user_client)<---------> game servers(router_client) <--------> IMServer
clients(user_client)<------------------------------------------------> IMServer

We focus on the first behind-game-server architecture first. 

user_client(IM_client) <------------------------> (game server)router_client(IM_router) <----------------------------------> IM_gateway <---------> IM_usermanager(lots of IM_user)

IM_client send and receive presence/roster/messages via the router_client thread run in the currently connected game server. Connection authenticated is done by the game server via nid, so additional auth for the IM is not needed. 
The IM_router will set up a timer that periodically send queued messages/queries to an IM_gateway. The IM_gateway will dispatch presence messages to all other IM_gateways in the network as well as to IM_usermanager in its current runtime. 
This mechinism ensures that all IM servers receives the presence messages from all game server(IM_router)s in the network. Hence each IM server knows the presence of each user as well as its current connected game server. 

Now we will see how the IM_usermanager deals with three major task of IM, that is user presence, roster list, and p2p message. 

---+++ Presence/Roster management
Since IM_usermanager receives presence info from all clients(via IM_router and other IM_gateways), it knows the presences of all users (maybe as large as 200K). 
It keeps them in a large map table of currently online users, where user nid is the key, and the IM_user data structure is the value.

IM_user := {
	nid,	-- user nid.
	gameserver_nid,  -- the game server nid (or IM_router nid)that it is currently connected with. 
	info = {
		presence,	-- current presence, such as online/offline/NA, etc. 
		message, -- a single line of presence text message. 
	}
	roster = {instances of other IM_users, or just nid(for offline)}, 
}

---+++ Roster Management
It is the job of the client to tell the IM server which users are its friends(in its roster) at login time. The IM_usermanager will update the IM_user's roster list accordingly. 

---+++ Messaging
P2P realtime messaging is extreamly easy. IM_gateway will not forward p2p message to other IM server, instead it will handle by itself. Whenever a IM_gateway receive a message it will look up the receiver in the user map, 
and send the message to IM_router on the receiver's gameserver_nid. The IM_router will then forward the message to the final receiver. 

---++ Message Protocols

client ----------------------> IM_router----------------------> IM_gateway ----------------------> IM_usermanager
IM_CS_Login:{user_nid, roster, message}-> 
client to server sign in
								IM_RS_Login:{user_nid, roster, message}-> 
								router just forward to a IM_gateway
																IM_GS_Login:{user_nid, roster, message}  --> Mark the user as signed in and mark the gameserver_nid as the message call's nid. 
																gateway call the local user manager 
   <--	IM_SC_Presence:{}<-----------------------   IM_SR_Presence:{online={nid,...}, offline={nid,...}}
												send the presence of all online users in the user's roster back to the user. 
   <--	IM_SC_Presence:{}<-----------------------   IM_SR_Presence:{online={nid}}(it may send to serveral IM_routers(game servers))
												Send the presence of user_nid to all the online people in the user's roster
																
																IM_GS_Login:{user_nid, gameserver_nid=nid, roster, message}
																gateway also needs to forward the message to all other IM_gateways in the network, see below 
												IM_gateway ----> IM_gateway(another gateway)
												IM_GS_Login:{user_nid, gameserver_nid=nid, roster, message}	--> Mark the user as signed in and mark the gameserver_nid. 
												gateway receives login messages from another IM_gateways. 
												
								IM_RS_Logout:{user_nid, roster, message}
																everything is the same in Logout as in Login. 
																
