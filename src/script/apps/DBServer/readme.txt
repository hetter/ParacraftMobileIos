---+++ Data Base Server 
| Author | LiXizhi |
| Date	 | 2009.7.18 |

The database server application starts the database server for servicing incoming database requests.
The server is implemented in NPL C# scripts in DBServer.dll(see WebAPI/trunk/DBServer/readme.txt), which contains all WebAPI used by the project.

The database server exposes a REST-like interface, but uses persistent TCP connections and multithreaded state pools provided by the NPL network layer. 
The server can be configured to operate in two mode simultaneously. 
   1. service directly with a client 
   1. service via a NPLRouter(see script/apps/NPLRouter/readme.txt). 

__note__: currently connection authentication are handled by the DBServer.dll(i.e. C# scripts). The current implementation does not authenticate at all for performance. So database server should be used in inner network. 

---+++ Boot Procedure

   1. boot the ParaEngineServer using "bootstrapper_dbserver.xml"
   1. DBServer.Start() is called at start up
      --> set working directory for DBServer.dll: NPL.activate("DBServer.dll/DBServer.DBServer.cs", {root_dir = ParaIO.GetCurDirectory(0)});
      --> load "./config/DBServer.config.xml"
			--> create specified npl runtime states (threads) to service requests
			

---+++ Message protocol

To service a client, 