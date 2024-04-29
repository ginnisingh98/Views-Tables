--------------------------------------------------------
--  DDL for Package IEM_DB_CONNECTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_DB_CONNECTIONS_PVT" AUTHID CURRENT_USER as
/* $Header: iemvdbcs.pls 115.5 2002/12/03 20:03:24 chtang ship $ */
-- Start of Comments
--  API name 	: create_item
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
--  p_is_admin IN   VARCHAR2,
--  p_conn_desc IN   VARCHAR2:=FND_API.G_MISS_CHAR,
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

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
  				 p_db_link IN   VARCHAR2,
  				 p_db_username	IN   VARCHAR2,
  				 p_db_password	IN   VARCHAR2,
  				 p_db_server_id IN   NUMBER,
  				 p_is_admin IN   VARCHAR2,
  				 p_conn_desc IN   VARCHAR2:=null,
			p_CREATED_BY    NUMBER:=null,
          	p_CREATION_DATE    DATE:=null,
         		p_LAST_UPDATED_BY    NUMBER:=null,
          	p_LAST_UPDATE_DATE    DATE:=null,
          	p_LAST_UPDATE_LOGIN    NUMBER:=null,
         		p_ATTRIBUTE1    VARCHAR2:=null,
          	p_ATTRIBUTE2    VARCHAR2:=null,
          	p_ATTRIBUTE3    VARCHAR2:=null,
          	p_ATTRIBUTE4    VARCHAR2:=null,
          	p_ATTRIBUTE5    VARCHAR2:=null,
          	p_ATTRIBUTE6    VARCHAR2:=null,
          	p_ATTRIBUTE7    VARCHAR2:=null,
          	p_ATTRIBUTE8    VARCHAR2:=null,
          	p_ATTRIBUTE9    VARCHAR2:=null,
          	p_ATTRIBUTE10    VARCHAR2:=null,
          	p_ATTRIBUTE11    VARCHAR2:=null,
          	p_ATTRIBUTE12    VARCHAR2:=null,
          	p_ATTRIBUTE13    VARCHAR2:=null,
          	p_ATTRIBUTE14    VARCHAR2:=null,
          	p_ATTRIBUTE15    VARCHAR2:=null,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure delete a record in the table IEM_DB_CONNECTIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_db_conn_id	in number:=null,
--  p_db_username IN   VARCHAR2 :=null,
--  p_db_server_id IN   NUMBER:=null,

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

PROCEDURE delete_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
				 p_db_conn_id	in number:=null,
				 p_db_username IN   VARCHAR2 :=null,
				 p_db_server_id IN   NUMBER:=null,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );
-- Start of Comments
--  API name 	: update_item
--  Type	: 	Private
--  Function	: This procedure update a record in the table IEM_DB_CONNECTIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_db_conn_id	IN NUMBER:=NULL,
--  p_db_link IN   VARCHAR2:=NULL,
--  p_db_username	IN   VARCHAR2:=NULL,
--  p_db_password	IN   VARCHAR2:=NULL,
--  p_db_server_id IN   NUMBER:=NULL,
--  p_is_admin IN   VARCHAR2:=NULL,
--  p_conn_desc IN   VARCHAR2:=NULL,
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

PROCEDURE update_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
				 p_db_conn_id IN NUMBER:=null,
  				 p_db_link IN   VARCHAR2:=null,
  				 p_db_username	IN   VARCHAR2:=null,
  				 p_db_password	IN   VARCHAR2:=null,
  				 p_db_server_id IN   NUMBER:=null,
  				 p_is_admin IN   VARCHAR2:=null,
  				 p_conn_desc IN   VARCHAR2:=null,
		p_CREATED_BY    NUMBER:=null,
          	p_CREATION_DATE    DATE:=null,
         	p_LAST_UPDATED_BY    NUMBER:=null ,
          	p_LAST_UPDATE_DATE    DATE:=null,
          	p_LAST_UPDATE_LOGIN    NUMBER:=null,
         	p_ATTRIBUTE1    VARCHAR2:=null,
          	p_ATTRIBUTE2    VARCHAR2:=null,
          	p_ATTRIBUTE3    VARCHAR2:=null,
          	p_ATTRIBUTE4    VARCHAR2:=null,
          	p_ATTRIBUTE5    VARCHAR2:=null,
          	p_ATTRIBUTE6    VARCHAR2:=null,
          	p_ATTRIBUTE7    VARCHAR2:=null,
          	p_ATTRIBUTE8    VARCHAR2:=null,
          	p_ATTRIBUTE9    VARCHAR2:=null,
          	p_ATTRIBUTE10    VARCHAR2:=null,
          	p_ATTRIBUTE11    VARCHAR2:=null,
          	p_ATTRIBUTE12    VARCHAR2:=null,
          	p_ATTRIBUTE13    VARCHAR2:=null,
          	p_ATTRIBUTE14    VARCHAR2:=null,
          	p_ATTRIBUTE15    VARCHAR2:=null,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: select_item
--  Type	: 	Private
--  Function	: This procedure returns the db_link name
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_email_account_id	in number:=null,
--  p_is_admin IN   VARCHAR2 :=null,

--	OUT
--   x_db_link	OUT	VARCHAR2
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************
PROCEDURE select_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
				 p_db_server_id	in number:=null,
				 p_is_admin IN   VARCHAR2 :=null,
				 x_db_link OUT NOCOPY   VARCHAR2,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );

END IEM_DB_CONNECTIONS_PVT;

 

/
