--------------------------------------------------------
--  DDL for Package IEM_RT_PREPROC_EMAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_RT_PREPROC_EMAILS_PVT" AUTHID CURRENT_USER as
/* $Header: iempreps.pls 120.0 2005/06/02 13:56:36 appldev noship $ */
-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table iem_rt_preproc_emails
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2
--  p_commit	IN VARCHAR2
--  p_db_link IN   VARCHAR2,
--  p_db_username	IN   VARCHAR2,
--  p_db_password	IN   VARCHAR2,
--  p_db_server_id IN   NUMBER,
--  p_is_admin IN   VARCHAR2,
--  p_conn_desc IN   VARCHAR2,
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
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_message_id			   IN  NUMBER,
			p_email_account_id          IN  NUMBER,
			p_priority                  IN  number,
			p_received_date		IN DATE,
		     x_return_status	OUT NOCOPY VARCHAR2,
  		 	x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	x_msg_data	OUT	NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure delete a record in the table iem_rt_preproc_emails
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2
--  p_commit	IN VARCHAR2
--  p_message_id	in number,

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
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_message_id	in number,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT	 NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2
			 );

END iem_rt_preproc_emails_PVT;

 

/
