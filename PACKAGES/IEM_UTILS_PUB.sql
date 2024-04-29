--------------------------------------------------------
--  DDL for Package IEM_UTILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_UTILS_PUB" AUTHID CURRENT_USER as
/* $Header: iemputls.pls 120.0 2005/06/02 13:49:43 appldev noship $*/

TYPE email_account IS RECORD (
          email_account_id   iem_email_accounts.email_account_id%type,
          account_name iem_email_accounts.account_name%type,
          email_user iem_email_accounts.email_user%type,
          domain iem_email_accounts.domain%type);

TYPE email_account_tbl IS TABLE OF email_account
           INDEX BY BINARY_INTEGER;


-- Start of Comments
--  API name 	: 	show_all_accounts
--  Type	: 	Private
--  Function	: 	This procedure retrieve email accounts from table IEM_EMAIL_ACCOUNTS for dropdownbox
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list		IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit			IN VARCHAR2	Optional Default = FND_API.G_FALSE
--
--	OUT
--   x_email_account_tbl OUT    iem_utils_pub.email_account_tbl
--   x_return_status	OUT	VARCHAR2
--   x_msg_count	OUT	NUMBER
--   x_msg_data		OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

TYPE email_count_type IS RECORD (
          resource_id   number,
          count number);

TYPE email_count_tbl IS TABLE OF email_count_type
           INDEX BY BINARY_INTEGER;

TYPE email_status_type IS RECORD (
          resource_id   number,
		new_count		number,
          read_count number);

TYPE email_status_count_tbl IS TABLE OF email_status_type
           INDEX BY BINARY_INTEGER;
TYPE email_milcs_type IS RECORD (
          milcs_id   number);
TYPE t_number_table IS TABLE OF email_milcs_type
           INDEX BY BINARY_INTEGER;
PROCEDURE show_all_accounts (p_api_version_number    	IN   	NUMBER,
 		  	     p_init_msg_list  		IN   	VARCHAR2 := FND_API.G_FALSE,
		    	     p_commit	    		IN   	VARCHAR2 := FND_API.G_FALSE,
		  	     x_email_account_tbl 	OUT NOCOPY  	iem_utils_pub.email_account_tbl,
		  	     x_return_status		OUT NOCOPY	VARCHAR2,
  		    	     x_msg_count	      	OUT 	NOCOPY  NUMBER,
	  	    	     x_msg_data			OUT	NOCOPY VARCHAR2);


PROCEDURE Get_Mailcount_by_days (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_duration in number,
				 p_resource_id in number,
				 x_email_count out NOCOPY email_status_count_tbl,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2);

PROCEDURE Get_Mailcount_by_MILCS (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_duration in number,
				 p_resource_id in number,
				 p_tbl	in t_number_table,
				 x_email_count out NOCOPY email_count_tbl,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2);


END IEM_UTILS_PUB;

 

/
