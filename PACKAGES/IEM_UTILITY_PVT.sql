--------------------------------------------------------
--  DDL for Package IEM_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_UTILITY_PVT" AUTHID CURRENT_USER as
/* $Header: iemutils.pls 115.4 2004/07/15 18:02:20 rtripath shipped $*/
TYPE email_account_rec_type IS RECORD (
          email_account_id   number,
          account_name varchar2(256));

TYPE email_account_tbl IS TABLE OF email_account_rec_type
           INDEX BY BINARY_INTEGER;
TYPE email_class_rec_type IS RECORD (
          rt_classification_id number,
		name varchar2(100));

TYPE email_class_tbl IS TABLE OF email_class_rec_type
           INDEX BY BINARY_INTEGER;

PROCEDURE GetEmailAccountList(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 x_account_tbl	out nocopy email_account_tbl,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2);
PROCEDURE GetClassLists(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_email_account_id	in number,
				 x_class_tbl	out nocopy email_class_tbl,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2);
FUNCTION gettimezone(p_date in date,
				p_resource_id	in number) return varchar2;
end IEM_UTILITY_PVT;

 

/
