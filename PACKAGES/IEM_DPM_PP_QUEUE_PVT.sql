--------------------------------------------------------
--  DDL for Package IEM_DPM_PP_QUEUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_DPM_PP_QUEUE_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvdpms.pls 120.0 2005/09/06 11:23:41 liangxia noship $ */
--
-- file name: iemvques.pls
--
-- Purpose: EMTA runtime queue management
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   8/01/2005   Created
-- ---------   ------  ------------------------------------------

  TYPE folder_worklist_rec is RECORD (
    migration_id        number,
    email_acct_id    	number,
    folder_type         varchar2(1),
    folder_name         varchar2(30), --STATIC or DYNAMIC
    user_name           varchar2(256),
    password            varchar2(256),
    server_name         varchar2(30),
	port       			number
  );

  --Table of emailProc_rec
  TYPE folder_worklist_tbl is TABLE OF folder_worklist_rec INDEX BY BINARY_INTEGER;

  --  Start of Comments
  --  API name    : get_folder_work_list
  --  Type        : Private
  --  Function    : This procedure get folder work list from iem_migration_details
  --  Pre-reqs    : None.
  --  Parameters  :
  Procedure get_folder_work_list(
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
                 x_folder_work_list    OUT  NOCOPY folder_worklist_tbl,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
    );

  --  Start of Comments
  --  API name    : get_msg_work_list
  --  Type        : Private
  --  Function    : This procedure get message work list from iem_migration_temp_store
  --  			  	for the give migration id
  --  Pre-reqs    : None.
  --  Parameters  :
 Procedure get_msg_work_list(
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
				 p_batch			   IN   NUMBER,
				 p_migration_id		   IN 	NUMBER,
				 x_mail_ids            OUT  NOCOPY JTF_NUMBER_TABLE,
                 x_message_ids         OUT  NOCOPY JTF_NUMBER_TABLE,
                 x_msg_uids            OUT  NOCOPY JTF_NUMBER_TABLE,
                 x_subjects            OUT  NOCOPY jtf_varchar2_Table_2000,
				 x_rfc_msgids          OUT  NOCOPY jtf_varchar2_Table_300,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
  ) ;

  --  Start of Comments
  --  API name    : log_batch_error
  --  Type        : Private
  --  Function    : This procedure get message work list from iem_migration_temp_store
  --  			  	for the give migration id
  --  Pre-reqs    : None.
  --  Parameters  :
   Procedure log_batch_error(
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
				 p_migration_id		   IN 	NUMBER,
				 p_mail_ids            IN   JTF_NUMBER_TABLE,
				 p_error               IN   VARCHAR2,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
    ) ;

END IEM_DPM_PP_QUEUE_PVT ;

 

/
