--------------------------------------------------------
--  DDL for Package IEM_ARCH_MSGDTLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_ARCH_MSGDTLS_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvarms.pls 120.0 2005/06/02 14:09:27 appldev noship $ */


PROCEDURE create_item (
                 p_api_version_number  IN   NUMBER,
		 p_init_msg_list       IN   VARCHAR2 := null,
		 p_commit              IN   VARCHAR2 := null,
		 p_message_id		IN	NUMBER,
		 p_inbound_message_id	IN	NUMBER,
		 p_email_account_id       IN   NUMBER,
		 p_mailproc_status	IN	VARCHAR2,
		 p_rt_classification_id	IN	NUMBER,
		 p_mail_type			NUMBER,
		 p_from_str		IN	VARCHAR2,
		 p_reply_to_str		IN	VARCHAR2,
		 p_to_str		IN	VARCHAR2,
		 p_cc_str		IN	VARCHAR2,
		 p_bcc_str		IN	VARCHAR2,
		 p_sent_date		IN	VARCHAR2,
		 p_received_date	IN	DATE,
		 p_subject             IN   VARCHAR2,
		 p_agent_id		IN	NUMBER,
		 p_group_id		IN	NUMBER,
		 p_ih_media_item_id	IN	NUMBER,
		 p_customer_id		IN	NUMBER,
		 p_message_size		IN	NUMBER,
		 p_contact_id		IN	NUMBER,
		 p_relationship_id	IN	NUMBER,
		 p_top_intent		IN	VARCHAR2,
		 p_message_text		IN	VARCHAR2,
		 p_ATTRIBUTE1    	IN VARCHAR2,
          	 p_ATTRIBUTE2    	IN VARCHAR2,
          	 p_ATTRIBUTE3    	IN VARCHAR2,
          	 p_ATTRIBUTE4    	IN VARCHAR2,
          	 p_ATTRIBUTE5    	IN VARCHAR2,
          	 p_ATTRIBUTE6    	IN VARCHAR2,
          	 p_ATTRIBUTE7    	IN VARCHAR2,
          	 p_ATTRIBUTE8    	IN VARCHAR2,
          	 p_ATTRIBUTE9    	IN VARCHAR2,
          	 p_ATTRIBUTE10    	IN VARCHAR2,
          	 p_ATTRIBUTE11    	IN VARCHAR2,
          	 p_ATTRIBUTE12    	IN VARCHAR2,
          	 p_ATTRIBUTE13    	IN VARCHAR2,
          	 p_ATTRIBUTE14    	IN VARCHAR2,
          	 p_ATTRIBUTE15    	IN VARCHAR2,
		 x_message_id		OUT 	NOCOPY NUMBER,
                 x_return_status	OUT     NOCOPY VARCHAR2,
  		 x_msg_count	        OUT	NOCOPY NUMBER,
	  	 x_msg_data	        OUT	NOCOPY VARCHAR2
			 );





END IEM_ARCH_MSGDTLS_PVT ;





 

/
