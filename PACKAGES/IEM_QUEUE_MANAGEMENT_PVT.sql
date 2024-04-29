--------------------------------------------------------
--  DDL for Package IEM_QUEUE_MANAGEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_QUEUE_MANAGEMENT_PVT" AUTHID CURRENT_USER as
/* $Header: iemvqums.pls 120.1 2006/02/13 14:33:40 chtang noship $*/
TYPE message_type IS RECORD (
          message_id   iem_rt_proc_emails.message_id%type,
          email_account_id iem_rt_proc_emails.email_account_id%type,
          sender_name iem_rt_proc_emails.from_address%type,
          subject iem_rt_proc_emails.subject%type,
          classification_name iem_route_classifications.name%type,
          customer_name hz_parties.party_name%type,
          sent_date varchar2(500),
          message_uid iem_rt_proc_emails.message_id%type,
          agent_account_id iem_agents.agent_id%type,
          group_name	jtf_rs_groups_tl.group_name%type,
          real_received_date   iem_rt_proc_emails.received_date%type);

TYPE message_tbl IS TABLE OF message_type
           INDEX BY BINARY_INTEGER;

TYPE temp_message_type IS RECORD (
          message_id   iem_rt_proc_emails.message_id%type,
          email_account_id iem_rt_proc_emails.email_account_id%type,
          sender_name iem_rt_proc_emails.from_address%type,
          subject iem_rt_proc_emails.subject%type,
          classification_name iem_route_classifications.name%type,
          customer_name hz_parties.party_name%type,
          sent_date varchar2(500),
          real_sent_date   iem_rt_proc_emails.sent_date%type,
          message_uid iem_rt_proc_emails.message_id%type,
          group_name	jtf_rs_groups_tl.group_name%type);

TYPE temp_message_tbl IS TABLE OF temp_message_type
           INDEX BY BINARY_INTEGER;

TYPE resource_count_type IS RECORD (
          resource_id   number,
          resource_name varchar2(200),
          email_count  number,
          last_login_time varchar2(500));

TYPE resource_count_tbl IS TABLE OF resource_count_type
           INDEX BY BINARY_INTEGER;

TYPE resource_group_count_type IS RECORD (
          group_id   number,
          group_name varchar2(200),
          agent_count  number,
          email_count  number);

TYPE resource_group_count_tbl IS TABLE OF resource_group_count_type
           INDEX BY BINARY_INTEGER;



PROCEDURE search_messages_in_queue (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2:=NULL,
		    	      p_commit	    IN   VARCHAR2:=NULL,
			      p_email_account_id in number,
			      p_classification_id in number,
			      p_subject		in	varchar2 :=NULL,
			      p_customer_name   in	varchar2 :=NULL,
			      p_sender_name	in	varchar2 :=NULL,
			      p_sent_date_from 	in	varchar2 :=NULL,
			      p_sent_date_to	in	varchar2 :=NULL,
			      p_sent_date_format in	varchar2 :=NULL,
			      p_group_id	 in	number,
			      p_sort_column	IN	number:=5,
			      p_sort_state	IN	varchar2 :=NULL,
			      x_message_tbl out nocopy message_tbl,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2);

PROCEDURE get_total_count_in_queue (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := NULL,
		    	      p_commit	    IN   VARCHAR2 := NULL,
			      p_email_account_id in number,
			      p_classification_id in number,
			      p_subject		in	varchar2 :=NULL,
			      p_customer_name   in	varchar2 :=NULL,
			      p_sender_name	in	varchar2 :=NULL,
			      p_sent_date_from 	in	varchar2 :=NULL,
			      p_sent_date_to	in	varchar2 :=NULL,
			      p_sent_date_format in	varchar2 :=NULL,
			      p_group_id	 in	number,
			      x_message_count   out nocopy     number,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2);

PROCEDURE show_agent_list (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := NULL,
		    	      p_commit	    IN   VARCHAR2 := NULL,
			      p_email_account_id in number,
			      p_sort_column	IN	number,
			      p_sort_state	IN	varchar2,
			      x_resource_count out nocopy resource_count_tbl,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2);

PROCEDURE show_resource_group_list (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := NULL,
		    	      p_commit	    IN   VARCHAR2 := NULL,
			      p_email_account_id in number,
			      p_sort_column	IN	number,
			      p_sort_state	IN	varchar2,
			      x_resource_group_count out nocopy resource_group_count_tbl,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2);

end IEM_QUEUE_MANAGEMENT_PVT;

 

/
