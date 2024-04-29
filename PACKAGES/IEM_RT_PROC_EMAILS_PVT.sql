--------------------------------------------------------
--  DDL for Package IEM_RT_PROC_EMAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_RT_PROC_EMAILS_PVT" AUTHID CURRENT_USER as
/* $Header: iemrprcs.pls 120.0 2005/06/02 14:18:52 appldev noship $*/
-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table iem_rt_proc_emails
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2
--  p_commit	IN VARCHAR2
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
				p_message_id IN NUMBER,
				p_email_account_id  IN NUMBER,
				p_priority  IN NUMBER ,
				p_agent_id  IN NUMBER,
				p_group_id  IN NUMBER,
				p_sent_date IN varchar2,
				p_received_date in date,
				p_rt_classification_id in number,
				p_customer_id    in number,
				p_contact_id    in number,
				p_relationship_id    in number,
				p_interaction_id in number,
				p_ih_media_item_id  in number,
				p_msg_status  in varchar2,
				p_mail_proc_status in varchar2,
				p_mail_item_status in varchar2,
				p_category_map_id in number,
				p_rule_id		in number,
				p_subject		in varchar2,
				p_sender_address	in varchar2,
				p_from_agent_id	in number,
		     x_return_status	OUT NOCOPY VARCHAR2,
  		 	x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	x_msg_data	OUT	NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure delete a record in the table iem_rt_proc_emails
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
  		  	      x_msg_count	      OUT	NOCOPY    NUMBER,
	  	  	      x_msg_data	OUT NOCOPY 	VARCHAR2
			 );

END IEM_RT_PROC_EMAILS_PVT;

 

/
