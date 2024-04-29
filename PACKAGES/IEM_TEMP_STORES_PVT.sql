--------------------------------------------------------
--  DDL for Package IEM_TEMP_STORES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_TEMP_STORES_PVT" AUTHID CURRENT_USER as
/* $Header: iemvmigs.pls 120.0 2005/06/02 14:04:12 appldev noship $ */
-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table iem_temp_stores
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
			p_folder_name			in varchar2,
			p_from_str			in varchar2,
			p_rfc822			in varchar2,
			p_reply_to			in varchar2,
			p_to					in varchar2,
			p_cc					in varchar2,
			p_bcc				in varchar2,
			p_sent_date			in varchar2,
			p_subject                  IN  varchar2,
			p_message_size             IN  number,
			p_mig_status                  IN  varchar2,
			p_mig_error_text		IN DATE,
			p_message_text				in varchar2,
			p_message_content		in BLOB,
		     x_return_status	OUT NOCOPY VARCHAR2,
  		 	x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	x_msg_data	OUT	NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure delete a record in the table iem_temp_stores
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

END iem_temp_stores_PVT;

 

/
