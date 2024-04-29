--------------------------------------------------------
--  DDL for Package IEM_REROUTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_REROUTE_PUB" AUTHID CURRENT_USER as
/* $Header: iemprers.pls 120.0 2005/06/02 13:49:36 appldev noship $*/
	PROCEDURE 	IEM_MAIL_REROUTE_CLASS(
        				p_Api_Version_Number 	  IN NUMBER,
        				p_Init_Msg_List  		  IN VARCHAR2     ,
        				p_Commit    			  IN VARCHAR2     ,
					p_msgid in number,
					p_agent_id	in number,
					p_class_id in number,
					p_customer_id	in number,
					p_uid in number,
					p_interaction_id in number,
					p_group_id	in number,
        				x_msg_count   		      OUT NOCOPY  NUMBER,
       				x_return_status  		  OUT NOCOPY  VARCHAR2,
      				x_msg_data   			  OUT NOCOPY  VARCHAR2);

	PROCEDURE 	IEM_MAIL_REROUTE_ACCOUNT(
        				p_Api_Version_Number 	  IN NUMBER,
        				p_Init_Msg_List  		  IN VARCHAR2     ,
        				p_Commit    			  IN VARCHAR2     ,
					p_msgid in number,
					p_agent_id	number,
					p_email_account_id in number,
					p_interaction_id in number,
					p_uid in number,
        				x_msg_count   		      OUT NOCOPY  NUMBER,
       				x_return_status  		  OUT NOCOPY  VARCHAR2,
      				x_msg_data   			  OUT NOCOPY  VARCHAR2);

	PROCEDURE 	IEM_UPD_GRP_QUEMSG(
        				p_Api_Version_Number 	  IN NUMBER,
        				p_Init_Msg_List  		  IN VARCHAR2     ,
        				p_Commit    			  IN VARCHAR2     ,
      				p_msg_ids_tbl IN  		  jtf_varchar2_Table_100,
					p_group_id 		in number,
					x_upd_count	 out nocopy number,
        				x_msg_count   		      OUT NOCOPY  NUMBER,
       				x_return_status  		  OUT NOCOPY  VARCHAR2,
      				x_msg_data   			  OUT NOCOPY  VARCHAR2);

	PROCEDURE 	IEM_MAIL_REDIRECT_ACCOUNT(
        				p_Api_Version_Number 	  IN NUMBER,
        				p_Init_Msg_List  		  IN VARCHAR2     ,
        				p_Commit    			  IN VARCHAR2     ,
					p_msgid in number,
					p_email_account_id in number,
					p_uid in number,
        				x_msg_count   		      OUT NOCOPY  NUMBER,
       				x_return_status  		  OUT NOCOPY  VARCHAR2,
      				x_msg_data   			  OUT NOCOPY  VARCHAR2);

end IEM_REROUTE_PUB;

 

/
