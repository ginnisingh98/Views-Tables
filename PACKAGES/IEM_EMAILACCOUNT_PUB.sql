--------------------------------------------------------
--  DDL for Package IEM_EMAILACCOUNT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_EMAILACCOUNT_PUB" AUTHID CURRENT_USER as
/* $Header: iempacts.pls 120.4.12010000.2 2009/08/27 06:05:41 shramana ship $ */

TYPE EMACNT_rec_type IS RECORD (
--		SERVER_ID		NUMBER,
		ACCOUNT_NAME	VARCHAR2(256) ,
		db_user		varchar2(256),
--		DOMAIN	VARCHAR2(256) ,
		ACCOUNT_PASSWORD	VARCHAR2(128) ,
          ACCOUNT_ID      NUMBER );

TYPE EMACNT_tbl_type IS TABLE OF EMACNT_rec_type
		 INDEX BY BINARY_INTEGER;
G_emacnt_tbl	emacnt_tbl_type;

TYPE msg_header IS RECORD (
        msg_id INTEGER,
        smtp_msg_id VARCHAR2(240),
        sender_name VARCHAR2(128),
        received_date DATE,
        from_str VARCHAR2(80),
        to_str VARCHAR2(240),
        priority VARCHAR2(30),
        replyto VARCHAR2(240),
        subject VARCHAR2(240),
        classification VARCHAR2(240),
        score NUMBER,
        folder_path VARCHAR2(240)
        );

TYPE msg_header_table IS TABLE OF msg_header INDEX BY
binary_integer;

type account_info_record is record (
    email_user varchar2(80),
    email_password varchar2(80),
    domain varchar2(128),
    db_server_id number,
    email_account_id number
);

type account_info_table is table of account_info_record index by
binary_integer;

TYPE ACNTDETAILS_rec_type IS RECORD (
		ACCOUNT_NAME		VARCHAR2(256),
		EMAIL_USER		VARCHAR2(100),
		EMAIL_ADDRESS		VARCHAR2(120),
		REPLY_TO_ADDRESS	VARCHAR2(256),
		FROM_NAME			VARCHAR2(100),
		EMAIL_ACCOUNT_ID	NUMBER,
		SMTP_SERVER		VARCHAR2(256),
		PORT				NUMBER,
		TEMPLATE_CATEGORY_ID	NUMBER
		);

TYPE ACNTDETAILS_tbl_type IS TABLE OF ACNTDETAILS_rec_type
		 INDEX BY BINARY_INTEGER;

TYPE AGNTACNTDETAILS_rec_type IS RECORD (
		RESOURCE_ID		NUMBER,
		RESOURCE_NAME		VARCHAR2(256),
		USER_NAME		VARCHAR2(256),
		ROLE			VARCHAR2(60),
		LAST_LOGIN_TIME		VARCHAR2(256)
		);

TYPE AGNTACNTDETAILS_tbl_type IS TABLE OF AGNTACNTDETAILS_rec_type
		 INDEX BY BINARY_INTEGER;

type AGENTACNT_rec_type is record (
    agent_account_id	number,
    email_account_id	number,
    account_name		varchar2(256),
    reply_to_address	varchar2(256),
    from_address		varchar2(256),
    from_name			varchar2(256),
    user_name			varchar2(256),
    signature			varchar2(256)
);

type AGENTACNT_tbl_type is table of AGENTACNT_rec_type index by
binary_integer;

-- *****************************************************
-- Start of Comments
--  API name 	: 	Get_EmailAccount_List
--  Type	: 	Public
--  Function	: This procedure returns a list of email accounts that a
--		  particular agent has access to. The agent_id is passed
--		  in the p_RESOURCE_ID parameter. The returned PL/SQL ta--ble
--		  has a list of email accounts, their username and login
--		  passwords and the Group_ID. Any of the email servers that
--		  belong to this group ID can be used to access the email
--		  account. An account is available on only one IM server
--		  the ID of which is the SERVER_ID attribute.
--		  If the eMC client wants to invoke IM's PLSQL APIs
--		  it first has to make a JDBC connection to the named IM
--		  server.
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_RESOURCE_ID  IN NUMBER,
--
--	OUT
--     	x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--      x_Email_Acnt_tbl  OUT  EMACNT_tbl_type
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************


PROCEDURE Get_EmailAccount_List (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
			      p_RESOURCE_ID  IN NUMBER := null,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Email_Acnt_tbl  OUT NOCOPY  EMACNT_tbl_type
			 );

Procedure getEmailHeaders(
                           p_AgentName   IN VARCHAR2,
                           p_top_n       IN INTEGER default 0,
                           p_top_option  IN INTEGER default 1,
                           p_folder_path IN VARCHAR2 default 'ALL',
                           message_headers OUT NOCOPY msg_header_table
                                        );

PROCEDURE ListAgentAccounts (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_RESOURCE_ID  IN NUMBER ,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Agent_Acnt_tbl  OUT NOCOPY  AGENTACNT_tbl_type
			 );
-- 12.1.2 Development. Bug 8829918
PROCEDURE ListAgentCPAccounts (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_RESOURCE_ID  IN NUMBER ,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Agent_Acnt_tbl  OUT NOCOPY  AGENTACNT_tbl_type
			 );
-- 12.1.2 Development. Bug 8829918 Changes end

PROCEDURE ListAgentAccountDetails (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
			      p_EMAIL_ACCOUNT_ID  IN NUMBER,
				 p_ROLEid	IN NUMBER:=-1,
				 p_Resource_id	IN NUMBER:=-1,
				 p_search_criteria IN VARCHAR2:=null,
				 p_display_size     in NUMBER:=null,
				 p_page_count  in NUMBER:=null,
				 p_sort_by     in VARCHAR2:='F',
				 p_sort_order     in NUMBER:=1,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
  		  	      x_search_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Agent_Acnt_Dtl_data  OUT NOCOPY  AGNTACNTDETAILS_tbl_type
			 );

PROCEDURE ListAccountDetails (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  	IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    		IN   VARCHAR2 := FND_API.G_FALSE,
			      p_email_account_id IN NUMBER := null,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	     OUT NOCOPY    NUMBER,
	  	  	      x_msg_data	 OUT NOCOPY VARCHAR2,
 			      x_Acnt_Details_tbl   OUT NOCOPY  ACNTDETAILS_tbl_type
			 );

END IEM_EmailAccount_PUB;

/
