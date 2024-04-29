--------------------------------------------------------
--  DDL for Package IEM_EMTA_ACCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_EMTA_ACCT_PVT" AUTHID CURRENT_USER AS
/* $Header: iemveacs.pls 120.2.12010000.2 2009/07/23 09:29:44 lkullamb ship $ */
--
--
-- Purpose:
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   10/05/2004    Created
-- ---------   ------  ------------------------------------------

--  Start of Comments
--  API name    : LOAD_ACCOUNT_INFO
--  Type        : Private
--  Function    : This procedure is used to load account details.
--  Pre-reqs    : None.
--  Parameters  :
--  lkullamb   07/23/2009  Added an out parameter to return whether an account is SSL enabled or not

PROCEDURE LOAD_ACCOUNT_INFO(
 		  				  	 p_api_version_number  IN   NUMBER,
		  					 p_init_msg_list       IN   VARCHAR2 := null,
		  					 p_commit              IN   VARCHAR2 := null,
		  					 p_email_account_id 		IN number,
		  					 X_USER_NAME 				OUT NOCOPY varchar2,
		  					 X_USER_PASSWORD 			OUT NOCOPY varchar2,
						  	 X_IN_HOST 					OUT NOCOPY varchar2,
		  					 X_IN_PORT 					OUT NOCOPY varchar2,
							 X_SSL_CONNECTION_FLAG                          OUT NOCOPY varchar2,
		  					 x_return_status       OUT  NOCOPY VARCHAR2,
		  					 x_msg_count    		OUT  NOCOPY NUMBER,
		  					 x_msg_data            OUT  NOCOPY VARCHAR2 );
end ;

/
