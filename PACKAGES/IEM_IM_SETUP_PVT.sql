--------------------------------------------------------
--  DDL for Package IEM_IM_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_IM_SETUP_PVT" AUTHID CURRENT_USER as
/* $Header: iemvimss.pls 120.0 2006/06/13 19:53:14 chtang noship $*/

-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table IEM_EMAIL_ACCOUNTS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_account_name IN   VARCHAR2,
--  p_email_user	IN   VARCHAR2,
--  p_domain	IN   VARCHAR2,
--  p_email_password	IN   VARCHAR2,
--  p_account_profile	IN   VARCHAR2,
--  p_db_server_id IN   NUMBER,
--  p_server_group_id IN   NUMBER,
--  SETSUP VARIOUS FOLDERS and CALLS ICENTER SETUP
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
--G_DBLINK_NAME CONSTANT VARCHAR2(100):= 'domlink';
G_AdminFldrName constant VARCHAR2(30) := 'Admin';
G_RetryFldrName constant VARCHAR2(30) := 'Retry';
G_ResolvedFldrName constant VARCHAR2(30) := 'Resolved';
TYPE resource_id_table is TABLE of INTEGER INDEX BY BINARY_INTEGER;

type email_account_id_table is TABLE of INTEGER INDEX BY BINARY_INTEGER;

PROCEDURE imAccountSetup (p_api_version_number    IN   NUMBER,
 		  	        	p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	        	p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
  				  	p_email_user	IN   VARCHAR2,
  				  	p_domain	IN   VARCHAR2,
  				  	p_password	IN  VARCHAR2,
					x_return_status OUT NOCOPY VARCHAR2,
  		    			x_msg_count	      OUT NOCOPY NUMBER,
	  	    			x_msg_data OUT NOCOPY VARCHAR2
			 );

PROCEDURE oesAccountSetup (p_api_version_number    IN   NUMBER,
 		  	        	p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	        	p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
  				  	p_email_user	IN   VARCHAR2,
  				  	p_domain	IN   VARCHAR2,
  				  	p_password	IN  VARCHAR2,
					x_return_status OUT NOCOPY VARCHAR2,
  		    			x_msg_count	      OUT NOCOPY NUMBER,
	  	    			x_msg_data OUT NOCOPY VARCHAR2
			 );

PROCEDURE autoackAccountSetup (p_api_version_number    IN   NUMBER,
 		  	        	p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	        	p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
  				  	p_email_user	IN   VARCHAR2,
  				  	p_domain	IN   VARCHAR2,
  				  	p_password	IN  VARCHAR2,
					x_return_status OUT NOCOPY VARCHAR2,
  		    			x_msg_count	      OUT NOCOPY NUMBER,
	  	    			x_msg_data OUT NOCOPY VARCHAR2
			 );

PROCEDURE imDeleteRules (p_api_version_number    IN   NUMBER,
 		  	        p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	        p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
  				  p_account_id	IN   NUMBER,

		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2
			 );


-- Start of Comments
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure delete a record in the table IEM_EMAIL_ACCOUNTS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_email_account_id	in number,
--  p_account_name IN   VARCHAR2 ,

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

PROCEDURE imAcntPasswdSync (p_api_version_number    IN   NUMBER,
 		  	          p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	          p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
			          p_email_account_id	in number,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );
-- Start of Comments
--  API name 	: update_item
--  Type	: 	Private
--  Function	: This procedure update a record in the table IEM_EMAIL_ACCOUNTS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--p_email_account_id IN NUMBER,
--	 p_account_name IN   VARCHAR2,
--  p_email_user	IN   VARCHAR2,
--  p_domain	IN   VARCHAR2,
--  p_email_password	IN   VARCHAR2,
--  p_account_profile	IN   VARCHAR2,
--  p_db_server_id IN   NUMBER,
--  p_server_group_id IN   NUMBER,
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

PROCEDURE createAgntFolder (
	x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE createAgntAccount(
	x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE deleteAgntFolder (
	x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE deleteAgntAccount (
	x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE getEmailAgents (
	p_email_account_id  IN NUMBER,
  	p_resource_id_table OUT NOCOPY resource_id_table
);

PROCEDURE getEmailAccounts (
	p_user_name	IN VARCHAR,
     p_email_account_id_table OUT NOCOPY email_account_id_table
);

-- Start of Comments
--  API name    : createAccount
--  Type        : Private
--  Function    : This procedure creates an account in the OES database
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--  p_api_version_number      IN NUMBER Required
--  p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE
--  p_commit         IN VARCHAR2 := FND_API.G_FALSE
--  p_admin_id       IN VARCHAR2 Required
--  p_admin_pass     IN VARCHAR2 Required
--  P_account_id     IN VARCHAR2 Required
--  P_account_first  IN VARCHAR2 Required
--  P_account_last   IN VARCHAR2 Required
--  P_account_pass   IN VARCHAR2 Required
--  p_oo_link        IN VARCHAR2 Required
--  p_domain         IN VARCHAR2 Required
--  p_node           IN VARCHAR2 Required
--  p_oes_database   IN VARCHAR2 Required

--      OUT
--   x_return_status OUT     VARCHAR2
--   x_msg_count     OUT     NUMBER
--   x_msg_data      OUT     VARCHAR2
--
--      Version : 1.0
--      Notes           :
--
-- End of comments
-- **********************************************************

PROCEDURE createAccount(p_api_version_number    IN   NUMBER,
p_init_msg_list  IN  VARCHAR2 := FND_API.G_FALSE,
p_commit         IN  VARCHAR2 := FND_API.G_FALSE,
p_oo_link        IN  VARCHAR2:=null,
p_admin_id       IN  VARCHAR2:=null,
p_admin_pass     IN  VARCHAR2:=null,
p_account_id     IN  VARCHAR2:=null,
p_account_first  IN VARCHAR2:=null,
p_account_last   IN VARCHAR2:=null,
p_account_pass   IN  VARCHAR2:=null,
p_domain         IN  VARCHAR2:=null,
p_node           IN  VARCHAR2:=null,
p_oes_database   IN  VARCHAR2:=null,
x_return_status  OUT NOCOPY VARCHAR2,
x_msg_count      OUT NOCOPY NUMBER,
x_msg_data       OUT NOCOPY VARCHAR2
				    );

-- Start of Comments
--  API name    : deleteAccount
--  Type        : Private
--  Function    : This procedure deletes an account in the OES database
--  Pre-reqs    : None.
--  Parameters  :
--      IN
--  p_api_version_number      IN NUMBER Required
--  p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE
--  p_commit         IN VARCHAR2 := FND_API.G_FALSE
--  p_admin_id       IN VARCHAR2 Required
--  p_admin_pass     IN VARCHAR2 Required
--  P_account_id     IN VARCHAR2 Required
--  p_domain         IN VARCHAR2 Required
--  p_oo_link        IN VARCHAR2 Required
--  p_oes_database   IN VARCHAR2 Required

--      OUT
--   x_return_status OUT     VARCHAR2
--   x_msg_count     OUT     NUMBER
--   x_msg_data      OUT     VARCHAR2
--
--      Version : 1.0
--      Notes           :
--
-- End of comments
PROCEDURE deleteAccount(p_api_version_number    IN   NUMBER,
p_init_msg_list  IN  VARCHAR2 := FND_API.G_FALSE,
p_commit         IN  VARCHAR2 := FND_API.G_FALSE,
p_oo_link        IN  VARCHAR2:=null,
p_admin_id       IN  VARCHAR2:=null,
p_admin_pass     IN  VARCHAR2:=null,
p_account_id     IN  VARCHAR2:=null,
p_domain         IN  VARCHAR2:=null,
p_oes_database   IN  VARCHAR2:=null,
x_return_status  OUT NOCOPY VARCHAR2,
x_msg_count      OUT NOCOPY NUMBER,
x_msg_data       OUT NOCOPY VARCHAR2
				    );
PROCEDURE iem_logger(l_level	   in varchar2,
				l_logmessage in varchar2);

END IEM_IM_SETUP_PVT;

 

/
