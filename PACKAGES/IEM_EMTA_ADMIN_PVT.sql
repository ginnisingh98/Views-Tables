--------------------------------------------------------
--  DDL for Package IEM_EMTA_ADMIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_EMTA_ADMIN_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvemts.pls 120.2 2005/07/13 18:01:40 appldev noship $ */
--
--
-- Purpose:
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   10/05/2004    Created
-- ---------   ------  ------------------------------------------
  TYPE acct_info_rec is RECORD (
    account_id            number,
    action                varchar2(10),
	update_flag           varchar2(1),
	user_name			  varchar2(100),
	user_password         varchar2(100),
	in_host				  varchar2(256),
	in_port				  number
    );

 TYPE acct_info_tbl is TABLE OF acct_info_rec INDEX BY BINARY_INTEGER;

--  Start of Comments
--  API name    : IS_DLPS_RUNNING
--  Type        : Private
--  Function    : This procedure is used to check if Download Processor running for the given Account.
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE IS_DLPS_RUNNING  (
                 			p_api_version_number  IN   NUMBER,
 		  	     			p_init_msg_list       IN   VARCHAR2 := null,
		    	 			p_commit              IN   VARCHAR2 := null,
            				p_email_acct_id       IN   NUMBER,
							x_running_status      OUT  NOCOPY VARCHAR2,
                 	    	x_return_status	  	  OUT  NOCOPY VARCHAR2,
  							x_msg_count	  		  OUT  NOCOPY NUMBER,
							x_msg_data	          OUT  NOCOPY VARCHAR2 );


--  Start of Comments
--  API name    : UPDATE_DP_CONFIG_DATA
--  Type        : Private
--  Function    : This procedure is to insert data into IEM_EMTA_CONFIG_PARAMS so that email account update could be uptake by
--                Download Processor.
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE UPDATE_DP_CONFIG_DATA(
                 			p_api_version_number  IN   NUMBER,
 		  	     			p_init_msg_list       IN   VARCHAR2 := null,
		    	 			p_commit              IN   VARCHAR2 := null,
            				p_email_acct_id       IN   NUMBER,
							p_active_flag		  IN   VARCHAR2,
							p_is_acct_update      IN   VARCHAR2,
                 	    	x_return_status	  	  OUT  NOCOPY VARCHAR2,
  							x_msg_count	  		  OUT  NOCOPY NUMBER,
							x_msg_data	          OUT  NOCOPY VARCHAR2 );

--  Start of Comments
--  API name    : UGET_ACCOUNT_INFO
--  Type        : Private
--  Function    : This procedure is retrieve email account information to be updated
--                Download Processor.
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE GET_ACCOUNT_INFO(
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
                 x_acct_info      	   OUT NOCOPY acct_info_tbl,
                 x_return_status	   OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT NOCOPY VARCHAR2
			 );


--  Start of Comments
--  API name    : UDELETE_ITEMS
--  Type        : Private
--  Function    : This procedure is delete items that has been used.
--                Download Processor.
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE DELETE_ITEMS(
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
                 x_return_status	   OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT NOCOPY VARCHAR2
			 );

--  Start of Comments
--  API name    : UPDATE_DP_CONFIG_DATA_WRAP
--  Type        : Private
--  Function    : This procedure is called by Email account GUI to insert data into IEM_EMTA_CONFIG_PARAMS when Email account is
--				  created, updated or deleted.
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE UPDATE_DP_CONFIG_DATA_WRAP(
 		  p_api_version_number  IN   NUMBER,
		  p_init_msg_list       IN   VARCHAR2 := null,
		  p_commit              IN   VARCHAR2 := null,
		  p_email_acct_id       IN   NUMBER ,
		  p_action         		IN 	 VARCHAR2,
		  P_ACTIVE_FLAG    		IN 	 varchar2 := null,
		  P_USER_NAME 			IN 	 varchar2 := null,
		  P_USER_PASSWORD 		IN 	 varchar2 := null,
		  P_IN_HOST 			IN 	 varchar2 := null,
		  P_IN_PORT				IN 	 varchar2 := null,
		  x_return_status       OUT  NOCOPY VARCHAR2,
		  x_msg_count    		OUT  NOCOPY NUMBER,
		  x_msg_data			OUT  NOCOPY VARCHAR2 );
--  Start of Comments
--  API name    : is_data_changed
--  Type        : Private
--  Function    : This procedure is internally used to check if any inbound server related account info changed
--  Pre-reqs    : None.
--  Parameters  :
/*
FUNCTION is_data_changed ( 	 p_email_account_id    IN number,
	  					 	 P_ACTIVE_FLAG 		   IN varchar2,
		  					 P_USER_NAME 		   IN varchar2,
		  					 P_USER_PASSWORD 	   IN varchar2,
						  	 P_IN_HOST 			   IN varchar2,
		  					 P_IN_PORT 			   IN varchar2,
							 x_is_acct_updated 	   OUT varchar2 )
return boolean;*/
PROCEDURE CHECK_IF_ACCOUNT_UPDATED(
 		  				  	 p_api_version_number  IN   NUMBER,
		  					 p_init_msg_list       IN   VARCHAR2 := null,
		  					 p_commit              IN   VARCHAR2 := null,
		  					 p_email_account_id 		IN number,
	  					 	 P_ACTIVE_FLAG 				IN varchar2,
		  					 P_USER_NAME 				IN varchar2,
		  					 P_USER_PASSWORD 			IN varchar2,
						  	 P_IN_HOST 					IN varchar2,
		  					 P_IN_PORT 					IN varchar2,
							 x_is_data_changed		OUT NOCOPY varchar2,
							 x_is_acct_updated 		OUT NOCOPY varchar2,
		  					 x_return_status       	OUT  NOCOPY VARCHAR2,
		  					 x_msg_count    		OUT  NOCOPY NUMBER,
		  					 x_msg_data             OUT  NOCOPY VARCHAR2 );
end ;

 

/
