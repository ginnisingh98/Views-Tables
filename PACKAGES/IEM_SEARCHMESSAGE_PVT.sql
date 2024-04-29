--------------------------------------------------------
--  DDL for Package IEM_SEARCHMESSAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_SEARCHMESSAGE_PVT" AUTHID CURRENT_USER as
/* $Header: iemvmshs.pls 120.0 2005/06/02 14:18:49 appldev noship $*/
-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure insert/delete a record in the table IEM_AGENTS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
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

TYPE message_rec_type IS RECORD (
          message_id   number,
          ih_media_item_id number,
		from_str varchar2(500),
		to_str	varchar2(2000),
          subject  varchar2(2000),
		sent_date varchar2(60));

TYPE message_rec_tbl IS TABLE OF message_rec_type
           INDEX BY BINARY_INTEGER;
PROCEDURE searchmessages (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_email_account_id         IN NUMBER,
			p_resource_id         IN NUMBER,
			p_email_queue         IN varchar2,
			p_sent_date_from	IN varchar2,
			p_sent_date_to		IN varchar2,
			p_received_date_from	in date,
			p_received_date_to		in date,
			p_from_str	in		varchar2,
			p_recepients	in		varchar2,
			p_cc_flag		in		varchar2,
			p_subject		in 		varchar2,
			p_message_body	 in varchar2,
			p_customer_id		in number,
			p_classification 	in varchar2,
			p_resolved_agent	in varchar2,
			p_resolved_group	in varchar2,
			x_message_tbl	out nocopy message_rec_tbl,
		      x_return_status OUT NOCOPY VARCHAR2,
  		 	 x_msg_count	      OUT NOCOPY NUMBER,
	  	  	 x_msg_data OUT NOCOPY VARCHAR2
			 );

END IEM_SEARCHMESSAGE_PVT;

 

/
