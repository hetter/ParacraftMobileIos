---+++ NPL Router Server 
| Author | Gosling |
| Date	 | 2009.7.18 |

The NPL router server application starts the router server for routing incoming database and game server requests.
The server is implemented in NPL c++ scripts in libNPLRouter.so(or NPLRouter.dll).

---+++ Boot Procedure

   1. boot the ParaEngineServer using "bootstrapper_router.xml"
   1. NPLRouter:Start(); is called at start up
      --> 
      --> self:load_config();
		-->load "config/NPLRouter.config.xml"
			--> read config and start server
			--> add all public files by using NPL.LoadPublicFilesFromXML(self.config.public_files);
			--> run n work threads to serve incoming route request according to config;
			--> create npl runtime address table      
			--> create relation table from table index to server by nid.
      		
---+++ Message protocol
7.21 adding d_rts,g_rts for specify work stat.
game server-> router
{ver="1.0",result=0,msg="",d_rts="1",g_rts="1",nid=2001,dest="db",game_nid=2001,user_nid=10089,data_table={name1="value1",name2="value2",},}
router->db server
{ver="1.0",result=0,msg="",d_rts="1",g_rts="1",nid=1901,game_nid=2001,user_nid=10089,data_table={name1="value1",name2="value2",},}
db server->router
{ver="1.0",result=0,msg="",d_rts="1",g_rts="1",nid=1001,dest="game",game_nid=2001,user_nid=10089,data_table={name1="value1",name2="value2",},}
router->game server
{ver="1.0",result=0,msg="",d_rts="1",g_rts="1",nid=1901,game_nid=2001,user_nid=10089,data_table={name1="value1",name2="value2",},}

---+++ Usage of dest
dest=="db"  router will transfer msg to db server.
   if user_nid==0, router will transfer msg to random db server
   else router will transfer msg to the right db server we define.
dest=="game" router will transfer msg to game server.
dest==other value,go to db server.
