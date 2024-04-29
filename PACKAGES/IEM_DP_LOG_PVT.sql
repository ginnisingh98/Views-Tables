--------------------------------------------------------
--  DDL for Package IEM_DP_LOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_DP_LOG_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvlogs.pls 120.0 2005/07/13 18:18:48 liangxia noship $ */
--
--
-- Purpose: Mantain Encrypted Tags
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   02/25/2002    Created
-- ---------   ------  ------------------------------------------

--  Start of Comments
--  API name    : create_item
--  Type        : Private
--  Function    : This procedure creates record in the table IEM_ENCRYPTED_TAGS table
--  Pre-reqs    : None.
--  Parameters  :
PROCEDURE CREATE_DP_LOG (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
				 P_error_code		   IN   VARCHAR2 := null,
				 P_MSG				   IN   VARCHAR2 := null,
            	 P_acct_id			   IN   number   := null,
                 p_subject         	   IN   VARCHAR2 := null,
                 p_RFC_msg_ID		   IN   VARCHAR2 := null,
				 p_received_date       IN   DATE := null,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) ;



END IEM_DP_LOG_PVT;

 

/
