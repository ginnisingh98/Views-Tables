--------------------------------------------------------
--  DDL for Package IEM_LOCAL_MESSAGE_STORE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_LOCAL_MESSAGE_STORE_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvsams.pls 120.0 2005/06/02 14:02:13 appldev noship $ */

PROCEDURE save_message (
                 p_api_version_number  IN   NUMBER,
		 p_init_msg_list       IN   VARCHAR2 := null,
		 p_commit              IN   VARCHAR2 := null,
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
		 p_action		IN	VARCHAR2,
		 x_message_id		OUT 	NOCOPY NUMBER,
                 x_return_status	OUT     NOCOPY VARCHAR2,
  		 x_msg_count	        OUT	NOCOPY NUMBER,
	  	 x_msg_data	        OUT	NOCOPY VARCHAR2
			 );


PROCEDURE delete_message (
                 p_api_version_number  IN   NUMBER,
		 p_init_msg_list       IN   VARCHAR2 := null,
		 p_commit              IN   VARCHAR2 := null,
		 p_message_id		IN	NUMBER,
		 p_action_flag		IN	VARCHAR2,
		 x_return_status	OUT     NOCOPY VARCHAR2,
  		 x_msg_count	        OUT	NOCOPY NUMBER,
	  	 x_msg_data	        OUT	NOCOPY VARCHAR2
			 );

END IEM_LOCAL_MESSAGE_STORE_PVT ;





 

/
