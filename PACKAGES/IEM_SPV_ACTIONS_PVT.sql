--------------------------------------------------------
--  DDL for Package IEM_SPV_ACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_SPV_ACTIONS_PVT" AUTHID CURRENT_USER as
/* $Header: iemvspas.pls 115.2 2003/07/25 00:57:28 chtang noship $*/


PROCEDURE delete_queue_msg (p_api_version_number    	IN   NUMBER,
 		  	      p_init_msg_list  		IN   VARCHAR2 :=NULL,
		    	      p_commit	    		IN   VARCHAR2 := NULL,
			      p_message_id 		in  number,
			      p_reason_id		in  number,
			      x_return_status		OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      	OUT NOCOPY	  NUMBER,
	  	  	      x_msg_data		OUT NOCOPY	VARCHAR2);

PROCEDURE delete_queue_msg_batch (p_api_version_number  IN   NUMBER,
 		  	      p_init_msg_list  		IN   VARCHAR2 := NULL,
		    	      p_commit	    		IN   VARCHAR2 := NULL,
			      p_message_ids_tbl 	IN  jtf_varchar2_Table_100,
			      p_reason_id		IN	number,
			      x_moved_message_count 	OUT	NOCOPY	NUMBER,
			      x_return_status		OUT	NOCOPY  VARCHAR2,
  		  	      x_msg_count	      	OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data		OUT	NOCOPY 	VARCHAR2);

end IEM_SPV_ACTIONS_PVT;

 

/
