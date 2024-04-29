--------------------------------------------------------
--  DDL for Package Body IEM_IM_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_IM_SETUP_PVT" as
/* $Header: iemvimsb.pls 120.0 2006/06/13 19:54:12 chtang noship $*/

-- *****************************************************
-- Start of Comments
-- Package name     : IEM_IM_SETUP_PVT
-- Purpose          : APIs that are used to setup email accounts and various folders.
-- History          : June 13, 2006 All the procedures have been obsoleted in R12.  Stubbed out all the procedures
--			instead of removing the package due to the CRM Resource Manager dependency
-- 			on this package.  Please see bug 5303797
-- NOTE             :
-- End of Comments
-- *****************************************************

g_statement_log	boolean;		-- Statement Level Logging
G_PKG_NAME CONSTANT varchar2(30) :='IEM_IM_SETUP_PVT ';

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

PROCEDURE imAccountSetup (p_api_version_number    IN   NUMBER,
 		  	        p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	        p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
  				  p_email_user	IN   VARCHAR2,
  				  p_domain	IN   VARCHAR2,
  				  p_password	IN  VARCHAR2,

		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2
			 ) is

BEGIN
null;

 END;

PROCEDURE oesAccountSetup (p_api_version_number    IN   NUMBER,
 		  	        p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	        p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
  				  p_email_user	IN   VARCHAR2,
  				  p_domain	IN   VARCHAR2,
  				  p_password	IN  VARCHAR2,

		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2
			 ) is

BEGIN
null;

 END;


 PROCEDURE autoackAccountSetup (p_api_version_number    IN   NUMBER,
 		  	        p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	        p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
  				  p_email_user	IN   VARCHAR2,
  				  p_domain	IN   VARCHAR2,
  				  p_password	IN  VARCHAR2,

		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2
			 ) is

BEGIN
null;

 END;


-- Start of Comments
--  API name 	: imDeleteRules
--  Type	: 	Private
--  Function	: This procedure removes the IM Rule from the table OM_SERVER_RULES in OES via db link
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_account_id IN   NUMBER,
--	OUT
--  x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE imDeleteRules (p_api_version_number    IN   NUMBER,
 		  	            p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	        p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
                        p_account_id IN NUMBER,

		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2
			 ) is


BEGIN
null;

 END;


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
			 ) is


BEGIN


   NULL;



 END;




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

			 ) is

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

 END;





PROCEDURE deleteAgntFolder (
  			      x_return_status OUT NOCOPY VARCHAR2

			 ) is


BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;

 END;

 PROCEDURE getEmailAgents (p_email_account_id IN NUMBER,
					p_resource_id_table OUT NOCOPY resource_id_table
			 ) is


BEGIN
null;

END;

PROCEDURE getEmailAccounts (
			                 p_user_name	IN VARCHAR,
                             p_email_account_id_table OUT NOCOPY email_account_id_table
			             	 ) is

begin

null;

end;

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
--  p_oo_link        IN VARCHAR2 Required
--  p_admin_id       IN VARCHAR2 Required
--  p_admin_pass     IN VARCHAR2 Required
--  P_account_id     IN VARCHAR2 Required
--  P_account_first  IN VARCHAR2 Required
--  P_account_last   IN VARCHAR2 Required
--  P_account_pass   IN VARCHAR2 Required
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
		p_admin_id      IN  VARCHAR2:=null,
		p_admin_pass    IN  VARCHAR2:=null,
		p_account_id      IN  VARCHAR2:=null,
		p_account_first   IN  VARCHAR2:=null,
		p_account_last    IN  VARCHAR2:=null,
		p_account_pass   IN  VARCHAR2:=null,
		p_domain          IN  VARCHAR2:=null,
		p_node       IN  VARCHAR2:=null,
		p_oes_database   IN  VARCHAR2:=null,
		x_return_status  OUT NOCOPY VARCHAR2,
		x_msg_count      OUT NOCOPY NUMBER,
		x_msg_data       OUT NOCOPY VARCHAR2
			) is

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;

END;

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
--  p_oo_link       IN VARCHAR2 Required
--  p_admin_id      IN VARCHAR2 Required
--  p_admin_pass     IN VARCHAR2 Required
--  P_account_id     IN VARCHAR2 Required
--  p_domain         IN VARCHAR2 Required
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

PROCEDURE deleteAccount(p_api_version_number    IN   NUMBER,
			p_init_msg_list  IN  VARCHAR2 := FND_API.G_FALSE,
			p_commit         IN  VARCHAR2 := FND_API.G_FALSE,
			p_oo_link        IN  VARCHAR2:=null,
			p_admin_id      IN  VARCHAR2:=null,
			p_admin_pass    IN  VARCHAR2:=null,
			p_account_id      IN  VARCHAR2:=null,
			p_domain          IN  VARCHAR2:=null,
			p_oes_database   IN  VARCHAR2:=null,
			x_return_status  OUT NOCOPY VARCHAR2,
			x_msg_count      OUT NOCOPY NUMBER,
			x_msg_data       OUT NOCOPY VARCHAR2
			) is

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

END;

PROCEDURE createAgntAccount (
	x_return_status OUT NOCOPY VARCHAR2
) is


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;
END;

PROCEDURE iem_logger(l_level	   in varchar2,
				l_logmessage in varchar2) IS
begin
	null;
end iem_logger;


PROCEDURE deleteAgntAccount (
  			      x_return_status OUT NOCOPY VARCHAR2

			 ) is



BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
END;


END IEM_IM_SETUP_PVT;

/
