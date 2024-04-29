--------------------------------------------------------
--  DDL for Package IEM_SPV_MONITORING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_SPV_MONITORING_PVT" AUTHID CURRENT_USER as
/* $Header: iemvspms.pls 115.4 2003/09/08 23:47:08 chtang noship $*/
TYPE email_activity IS RECORD (
          email_account_id iem_post_mdts.email_account_id%type,
          classification_id iem_route_classifications.route_classification_id%type,
          account_classification_name varchar2(256),
          queue_count number,
          total_count number,
          queue_wait_time number,
          agent_count number,
          inbox_count number,
          inbox_wait_time number,
          queue_average_time number,
          inbox_average_time number,
          queue_zero_flag varchar2(10),
          inbox_zero_flag varchar2(10));

TYPE email_activity_tbl IS TABLE OF email_activity
           INDEX BY BINARY_INTEGER;

TYPE agent_activity IS RECORD (
          resource_id iem_post_mdts.agent_id%type,
          email_account_id iem_email_accounts.email_account_id%type,
          resource_account_name varchar2(750),
          email_count number,
          assigned_email_count number,
          average_age number,
          oldest_age number,
          last_login_time varchar2(500),
          account_count number,
          zero_flag varchar2(10),
          requeue_all_flag varchar2(10));

TYPE agent_activity_tbl IS TABLE OF agent_activity
           INDEX BY BINARY_INTEGER;

PROCEDURE get_email_activity (p_api_version_number    	IN   	NUMBER,
 		  	      p_init_msg_list  		IN   	VARCHAR2,
		    	      p_commit	    		IN   	VARCHAR2,
			      x_email_activity_tbl 	OUT 	NOCOPY	email_activity_tbl,
			      x_return_status		OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	      	OUT	NOCOPY NUMBER,
	  	  	      x_msg_data		OUT	NOCOPY VARCHAR2);

PROCEDURE get_agent_activity (p_api_version_number    	IN   	NUMBER,
 		  	      p_init_msg_list  		IN   	VARCHAR2,
		    	      p_commit	    		IN   	VARCHAR2,
		    	      p_resource_role		IN	NUMBER:=1,
		    	      p_resource_name		IN	VARCHAR2:=null,
			      x_agent_activity_tbl 	OUT 	NOCOPY	agent_activity_tbl,
			      x_return_status		OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	      	OUT	NOCOPY NUMBER,
	  	  	      x_msg_data		OUT	NOCOPY VARCHAR2);


end IEM_SPV_MONITORING_PVT;

 

/
