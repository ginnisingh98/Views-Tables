--------------------------------------------------------
--  DDL for Package AMW_LOAD_PROC_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_LOAD_PROC_DATA" AUTHID CURRENT_USER AS
/* $Header: amwprlds.pls 120.0 2005/05/31 19:46:08 appldev noship $ */

/**
   TYPE wf_activity_rec_type IS RECORD(
   		item_type 			 varchar2(8)  		   :=		'AUDITMGR',
		name	  			 varchar2(30),
		version	  			 number,
		type	  			 varchar2(8)  		   :=		'PROCESS',
		rerun	  			 varchar2(8)		   :=		'RESET',
		expand_role	  		 varchar2(1)		   :=		'N',
		protect_level		 number		 		   :=		20,
		custom_level		 number				   :=		20,
		begin_date			 date,
		effective_date		 date 				   :=		sysdate,
		end_date			 date		  		   :=		null,
		function			 varchar2(240)		   :=		null,
		result_type			 varchar2(30)		   :=		'*',
		cost				 number			   	   :=		null,
		read_role			 varchar2(320)		   :=		null,
		write_role			 varchar2(320)		   :=		null,
		execute_role		 varchar2(320)		   :=		null,
		icon_name			 varchar2(30)		   :=		'PROCESS.ICO',
		message				 varchar2(30)		   :=		null,
		error_process		 varchar2(30)		   :=		null,
		error_item_type		 varchar2(8)		   :=		'WFERROR',
		runnable_flag		 varchar2(1)		   :=		'N',
		function_type		 varchar2(30)		   :=		null,
		event_name			 varchar2(240)		   :=		null,
		direction			 varchar2(30)		   :=		null,
		security_group_id	 varchar2(32)		   :=		null,
		display_name		 varchar2(80),
		description			 varchar2(240)		   :=		null,
		language			 varchar2(30),
		source_lang			 varchar2(4)
   );

   g_wf_activity_rec    	 wf_activity_rec_type;
   **/

   TYPE amw_process_rec IS RECORD(
        PROCESS_ID		   		  	NUMBER,
		item_type                   varchar2(8)     := 'AUDITMGR',
        name                        varchar2(30),
        PROCESS_CODE				VARCHAR2(30),
		REVISION_NUMBER				NUMBER,
   		process_rev_id 		        number,
		approval_status             varchar2(30),
        START_DATE					DATE,
		APPROVAL_DATE				DATE,
		APPROVAL_END_DATE			DATE,
		END_DATE					DATE,
		control_count               number,
        risk_count                  number,
        org_count                   number,
		significant_process_flag	varchar2(1),
		standard_process_flag	    varchar2(1),
        certification_status        varchar2(30),
        process_category            varchar2(30),
        STANDARD_VARIATION			NUMBER,
		last_update_date            date,
        last_updated_by             number,
        creation_date               date,
        created_by                  number,
        last_update_login           number,
        created_from                varchar2(30),
        request_id                  number,
        program_application_id      number,
        program_id                  number,
        program_update_date         date,
        attribute_category          varchar2(30),
        attribute1                  varchar2(150),
        attribute2                  varchar2(150),
        attribute3                  varchar2(150),
        attribute4                  varchar2(150),
        attribute5                  varchar2(150),
        attribute6                  varchar2(150),
        attribute7                  varchar2(150),
        attribute8                  varchar2(150),
        attribute9                  varchar2(150),
        attribute10                 varchar2(150),
        attribute11                 varchar2(150),
        attribute12                 varchar2(150),
        attribute13                 varchar2(150),
        attribute14                 varchar2(150),
        attribute15                 varchar2(150),
        security_group_id           number,
        object_version_number       number,
        DELETION_DATE				DATE,
		PROCESS_TYPE				VARCHAR2(10),
		CONTROL_ACTIVITY_TYPE		VARCHAR2(10),
		RISK_COUNT_LATEST			NUMBER,
		CONTROL_COUNT_LATEST		NUMBER,
		DESCRIPTION					VARCHAR2(240),
		DISPLAY_NAME				VARCHAR2(80),
		ATTACHMENT_URL				VARCHAR2(2048),
		--12.29.2004 NPANANDI: ADDED CLASSIFICATION COLS
		CLASSIFICATION				NUMBER,
		---04.22.2005 npanandi: added 3 owner columns below
		process_owner_id            number,
		application_owner_id        number,
		finance_owner_id            number
	);

   g_amw_process_rec    	 amw_process_rec;

   /**
   TYPE wf_process_activity_rec IS RECORD(
        PROCESS_ITEM_TYPE       VARCHAR2(8)     :=  'AUDITMGR',
        PROCESS_NAME            VARCHAR2(30),
        PROCESS_VERSION         NUMBER,
        ACTIVITY_ITEM_TYPE      VARCHAR2(8)     :=  'AUDITMGR',
        ACTIVITY_NAME           VARCHAR2(30),
        INSTANCE_ID             NUMBER          :=  0,
        INSTANCE_LABEL          VARCHAR2(30),
        PERFORM_ROLE_TYPE       VARCHAR2(8)     :=  'CONSTANT',
        PROTECT_LEVEL           NUMBER          :=  '20',
        CUSTOM_LEVEL            NUMBER          :=  '20',
        START_END               VARCHAR2(8)     :=  null,
        DEFAULT_RESULT          VARCHAR2(30)    :=  null,
        ICON_GEOMETRY           VARCHAR2(2000)  :=  '0,0',
        PERFORM_ROLE            VARCHAR2(320)   :=  null,
        USER_COMMENT            VARCHAR2(240)   :=  null
   	);

   g_process_activity_rec    	 wf_process_activity_rec;
   **/

   /***
   TYPE wf_activity_transition_rec IS RECORD(
        From_Process_Activity  number,
  		Result_Code 		   varchar2(30)	    := '*',
  		To_Process_Activity    number,
  		Protect_Level 		   number  		    := 20,
  		Custom_Level 		   number 		    := 20,
  		Arrow_Geometry 		   varchar2(2000)   := '0,0,0'
   	);

   g_activity_transition_rec   wf_activity_transition_rec;
   ***/

   PROCEDURE create_processes (
      ERRBUF      OUT NOCOPY   VARCHAR2
     ,RETCODE     OUT NOCOPY   VARCHAR2
     ,p_batch_id       IN       NUMBER
     ,p_user_id        IN       NUMBER
   );
/**
   procedure find_parent_process(
     p_orig_process_display_name in varchar2,
     p_process_display_name in varchar2,
     p_batch_id             in number,
	 p_interface_id in number);
**/
   PROCEDURE update_interface_with_error (
      p_err_msg        IN   VARCHAR2
     ,p_table_name     IN   VARCHAR2
     ,p_interface_id   IN   NUMBER
   );

   PROCEDURE FIND_PARENT_PROCESS_V(P_PROCESS_CODE 		 IN VARCHAR2
                                  ,P_PARENT_PROCESS_CODE IN VARCHAR2
                                  ,P_BATCH_ID     		 IN NUMBER);
							   --,p_num				  in number);

   FUNCTION Check_Function_Security(p_function_name in varchar2) return BOOLEAN;

   FUNCTION GET_INV_PRC_CODE_ROW(P_BATCH_ID IN NUMBER) RETURN NUMBER;

   FUNCTION New_Parent_Processes_Check(p_batch_id in NUMBER) RETURN Boolean;

   PROCEDURE POPULATE_INTF_TBL(
      P_BATCH_ID IN NUMBER);

   PROCEDURE INSERT_AMW_PROCESS(
      P_PROCESS_REC   IN AMW_PROCESS_REC
	 ,X_RETURN_STATUS OUT nocopy VARCHAR2
	 ,X_MSG_COUNT     OUT nocopy NUMBER
	 ,X_MSG_DATA      OUT nocopy VARCHAR2
   );

   PROCEDURE UPD_AMW_PROCESS(
      P_PROCESS_REC   IN AMW_PROCESS_REC
	 ,X_RETURN_STATUS OUT nocopy VARCHAR2
	 ,X_MSG_COUNT     OUT nocopy NUMBER
	 ,X_MSG_DATA      OUT nocopy VARCHAR2
   );

   FUNCTION PROCESS_CODE_EXISTS(p_PARENT_PROCESS_CODE IN VARCHAR2) RETURN Boolean;

   FUNCTION inv_hierarchy_EXISTS(
      p_PARENT_child_CODE IN VARCHAR2
     ,p_PROCESS_CODE      IN VARCHAR2 ) RETURN Boolean;

   FUNCTION PRC_APPR_CHK_FAILS(
      P_BATCH_ID 				IN NUMBER
     ,P_PROCESS_INTERFACE_ID 	IN NUMBER
   ) RETURN BOOLEAN;

   ---
   ---03.02.2005 npanandi: add Process Owner privilege here for data security
   ---
   procedure add_owner_privilege(
   	  p_role_name          in varchar2
	 ,p_object_name        in varchar2
	 ,p_grantee_type       in varchar2
	 ,p_instance_set_id    in number     default null
	 ,p_instance_pk1_value in varchar2
	 ,p_instance_pk2_value in varchar2   default null
	 ,p_instance_pk3_value in varchar2   default null
	 ,p_instance_pk4_value in varchar2   default null
	 ,p_instance_pk5_value in varchar2   default null
	 ---04.22.2005 npanandi: partyId is being passed directly
	 ---instead of userId
	 ---,p_user_id            in number
	 ,p_party_id           in number
	 ,p_start_date         in date       default sysdate
	 ,p_end_date           in date       default null);

   ---
   ---03.02.2005 npanandi: function to check access privilege for this Process
   ---
   function check_function(
      p_function           in varchar2
     ,p_object_name        in varchar2
     ,p_instance_pk1_value in number
     ,p_instance_pk2_value in number default null
     ,p_instance_pk3_value in number default null
     ,p_instance_pk4_value in number default null
     ,p_instance_pk5_value in number default null
     ,p_user_id            in number) return varchar2;

   ---
   ---04.29.2005 npanandi: added below procedure to check for existing
   ---                     Owner roles
   ---
   procedure pre_process_role_grant(
      p_role_name in varchar2
	 ,p_pk1_value in number);
END amw_load_proc_data;

 

/
