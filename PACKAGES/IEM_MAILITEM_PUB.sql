--------------------------------------------------------
--  DDL for Package IEM_MAILITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_MAILITEM_PUB" AUTHID CURRENT_USER as
/* $Header: iemclnts.pls 120.0.12010000.3 2009/08/28 07:09:17 shramana ship $*/
TYPE email_count_rec_type IS RECORD (
          email_account_id   number,
          rt_classification_id number,
		rt_classification_name varchar2(30),
		email_account_name	varchar2(100),
          email_que_count  number,
		email_acq_count number,
		email_max_qwait number,	-- Wait Time in Queue
		email_max_await number, -- Wait Time in Acquired
		email_status 	number); -- 0 for old 1 for New

TYPE email_count_tbl IS TABLE OF email_count_rec_type
           INDEX BY BINARY_INTEGER;
TYPE class_count_rec_type IS RECORD (
          rt_classification_id number,
		rt_classification_name varchar2(30),
          email_count  number);

TYPE class_count_tbl IS TABLE OF class_count_rec_type
           INDEX BY BINARY_INTEGER;

TYPE t_number_table IS TABLE OF NUMBER;

TYPE acq_email_info_rec_type IS RECORD (
          message_id   number,
          rt_classification_id number,
		rt_classification_name varchar2(30),
	 	rt_media_item_id    number,
          rt_interaction_id   number,
		email_account_id	number,
		message_flag		varchar2(1),
		sender_name		varchar2(128),
		subject		varchar2(240),
		priority		varchar2(30),
		msg_status	varchar2(50),
		sent_date		varchar2(60),
--		message_type	varchar2(30),
		mail_item_status	varchar2(30),
		from_agent_id		number,
		read_status		varchar2(10),
		description		varchar2(240));

TYPE acq_email_info_tbl  IS TABLE OF acq_email_info_rec_type
           INDEX BY BINARY_INTEGER;

TYPE queue_email_info_rec_type IS RECORD (
		message_id   number,
		rt_classification_id number,
		rt_classification_name varchar2(30),
		email_account_id	number,
		sender_name		varchar2(128),
		subject		varchar2(240),
		sent_date		varchar2(60),
		from_agent_id		number,
		party_name		varchar2(360),
		party_id		NUMBER(15),
		contact_id		NUMBER(15),
		group_name		varchar2(60) default NULL,
		source			varchar2(60) default NULL,
		source_number		varchar2(15) default NULL);

TYPE queue_email_info_tbl  IS TABLE OF queue_email_info_rec_type
           INDEX BY BINARY_INTEGER;

  TYPE keyVals_rec_type is RECORD (
    key     iem_route_rules.key_type_code%type,
    value   iem_route_rules.value%type,
    datatype varchar2(1));

  --Table of Key-Values
  TYPE keyVals_tbl_type is TABLE OF keyVals_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE GetMailItemCount (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_resource_id in number,
				 p_tbl	in t_number_table:=NULL,
				 x_email_count out NOCOPY email_count_tbl,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2);
PROCEDURE GetMailItemCount (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_resource_id in number,
				p_tbl	in t_number_table:=NULL,
				p_email_account_id in number,
				x_class_bin	out NOCOPY class_count_tbl,
			     x_return_status	OUT NOCOPY	VARCHAR2,
  		  	     x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	     x_msg_data	OUT NOCOPY	VARCHAR2);

PROCEDURE GetMailItemCount (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_email_account_id in number,
				x_class_bin	out NOCOPY class_count_tbl,
			     x_return_status	OUT NOCOPY	VARCHAR2,
  		  	     x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	     x_msg_data	OUT NOCOPY	VARCHAR2);

PROCEDURE GetMailItemCount (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_resource_id in number,
				 p_tbl	in t_number_table:=NULL,
				 p_email_account_id in number,
				 p_classification_id in number,
				 x_count		OUT NOCOPY NUMBER,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2);

-- This will return  POST MDT Data when called by EMC CLient
PROCEDURE GetMailItem (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_resource_id in number,
				p_tbl	in t_number_table:=NULL,
				p_rt_classification in number,
				p_account_id in number,
				x_email_data out NOCOPY  iem_rt_proc_emails%rowtype,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT NOCOPY	   NUMBER,
	  	     	x_msg_data	OUT NOCOPY	VARCHAR2);

-- This will return the Tag information along with POST MDT Data Called by
-- EMC Client
PROCEDURE GetMailItem (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_resource_id in number,
				p_tbl	in t_number_table:=NULL,
				p_rt_classification in number,
				p_account_id in number,
				x_email_data out NOCOPY  iem_rt_proc_emails%rowtype,
				x_tag_key_value	OUT NOCOPY keyVals_tbl_type,
				x_encrypted_id		OUT NOCOPY VARCHAR2,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT NOCOPY	   NUMBER,
	  	     	x_msg_data	OUT NOCOPY	VARCHAR2);
-- This will return  POST MDT Data when called by UWQ
PROCEDURE GetMailItem(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_resource_id in number,
				p_acct_rt_class_id in number,
				x_email_data out NOCOPY  iem_rt_proc_emails%rowtype,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT NOCOPY	   NUMBER,
	  	     	x_msg_data	OUT NOCOPY	VARCHAR2);
PROCEDURE DisposeMailItem (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_message_id	in number,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2);

PROCEDURE ResolvedMessage (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_message_id	in number,
				 p_action_flag		in  varchar2,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2);
PROCEDURE getGroupDetails(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_resource_id	in number,
			    	x_tbl	out NOCOPY t_number_table,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT	 NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2);

PROCEDURE UpdateMailItem (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_email_data in  iem_rt_proc_emails%rowtype,
		     	x_return_status	OUT	 NOCOPY VARCHAR2,
  		     	x_msg_count	      OUT	 NOCOPY   NUMBER,
	  	     	x_msg_data	OUT	 NOCOPY VARCHAR2);
PROCEDURE getMailItemInfo(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_message_id	in number,
				 p_account_id		in number,
				 p_agent_id		in number,
				x_email_data out  NOCOPY iem_rt_proc_emails%rowtype,
		     	x_return_status	OUT	 NOCOPY VARCHAR2,
  		     	x_msg_count	      OUT	 NOCOPY   NUMBER,
	  	     	x_msg_data	OUT	 NOCOPY VARCHAR2);
PROCEDURE getEmailHeaders(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_resource_id	in number,
				 p_email_account_id		in number,
				 p_display_size	in NUMBER,
				 p_page_count	in NUMBER,
				 p_sort_by	in VARCHAR2,
				 p_sort_order	in number,
				 x_total_message	OUT NOCOPY NUMBER,
				x_acq_email_data out  NOCOPY acq_email_info_tbl,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT NOCOPY	   NUMBER,
	  	     	x_msg_data	OUT NOCOPY	VARCHAR2);

--12.1.3 Development cherry picking
-- This API will return the unread email headers
PROCEDURE getUnreadEmailHeaders(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_email_account_id		in number,
				 p_display_size	in NUMBER,
				 p_page_count	in NUMBER,
				 p_sort_by	in VARCHAR2,
				 p_sort_order	in number,
				 x_total_message	OUT NOCOPY NUMBER,
				x_queue_email_data out  NOCOPY queue_email_info_tbl,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT NOCOPY	   NUMBER,
	  	     	x_msg_data	OUT NOCOPY	VARCHAR2);
/* This Api Will Return the meta Data and Tag Data for a message Id */
PROCEDURE GetQueueItemData (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_message_id in number,
				p_from_agent_id in number,
				p_to_agent_id in number,
				p_mail_item_status in varchar2,
				x_email_data out NOCOPY iem_rt_proc_emails%rowtype,
				x_tag_key_value	OUT NOCOPY keyVals_tbl_type,
				x_encrypted_id		OUT NOCOPY VARCHAR2,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT	NOCOPY  NUMBER,
	  	     	x_msg_data	OUT NOCOPY VARCHAR2);
end IEM_MAILITEM_PUB;

/
