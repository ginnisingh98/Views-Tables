--------------------------------------------------------
--  DDL for Package IEM_DBLINK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_DBLINK_PVT" AUTHID CURRENT_USER as
/* $Header: iemvdbls.pls 115.15 2002/12/05 20:14:07 chtang shipped $*/

-- Start of Comments
--  API name 	: create_link
--  Type	: 	Private
--  Function	: This procedure create a record in the table IEM_DB_CONNECTIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_db_link IN   VARCHAR2,
--  p_db_username	IN   VARCHAR2,
--  p_db_password	IN   VARCHAR2,
--  p_db_server_id IN   NUMBER,
--  p_is_admin		IN	VARCHAR2
--
--	OUT
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE create_link (p_api_version_number    IN   NUMBER,
 		  	     p_init_msg_list  	IN   VARCHAR2 := FND_API.G_FALSE,
		    	     p_commit	    		IN   VARCHAR2 := FND_API.G_FALSE,
  				p_db_server_id 	IN   NUMBER,
  				p_db_glname 		IN VARCHAR2,
                    p_db_username 		IN VARCHAR2,
                    p_db_password 		IN VARCHAR2,
                    p_is_admin 		IN VARCHAR2,
                	x_return_status OUT NOCOPY VARCHAR2,
  		    		x_msg_count	     OUT NOCOPY NUMBER,
	  	    		x_msg_data	 OUT NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: delete_link
--  Type	: 	Private
--  Function	: This procedure delete a record in the table IEM_DB_CONNECTIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_db_connection_id	in number:=FND_API.G_MISS_NUM,
--
--	OUT
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE delete_link (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  	IN   VARCHAR2,
		    	      p_commit	    		IN   VARCHAR2,
			 	 p_db_connection_id IN   NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	     OUT NOCOPY    NUMBER,
	  	  	      x_msg_data	 OUT NOCOPY VARCHAR2
			 );

END IEM_DBLINK_PVT;

 

/
