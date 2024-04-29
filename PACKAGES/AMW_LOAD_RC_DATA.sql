--------------------------------------------------------
--  DDL for Package AMW_LOAD_RC_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_LOAD_RC_DATA" AUTHID CURRENT_USER AS
/* $Header: amwrclds.pls 120.0.12000000.1 2007/01/16 20:40:59 appldev ship $ */

   PROCEDURE create_risks_and_controls (
      ERRBUF      OUT NOCOPY   VARCHAR2
     ,RETCODE     OUT NOCOPY   VARCHAR2
     ,p_batch_id       IN       NUMBER
     ,p_user_id        IN       NUMBER

   );


   PROCEDURE update_interface_with_error (
      p_err_msg        IN   VARCHAR2
     ,p_table_name     IN   VARCHAR2
     ,p_interface_id   IN   NUMBER
   );

   PROCEDURE risk_types (
      p_risk_type_flag IN VARCHAR2,
	  p_lookup_tag IN VARCHAR2,
	  p_is_last_call in varchar2
	 );

   PROCEDURE control_objectives (
      p_ctrl_obj_flag	    IN VARCHAR2,
      p_lookup_tag	    IN VARCHAR2
     );
   PROCEDURE control_assertions (
      p_ctrl_assert_flag    IN VARCHAR2,
      p_lookup_tag	    IN VARCHAR2
     );

--KOSRINIV control_components

   PROCEDURE control_components (
   	  p_ctrl_comp_flag IN VARCHAR2,
	  p_lookup_tag IN VARCHAR2
	 );


   PROCEDURE create_process_objectives (
   			 p_process_objective_name 			IN VARCHAR2,
   			 p_process_obj_description			IN Varchar2,
   			 p_requestor_id			 			IN	number,
   			 x_return_status			 		out nocopy	varchar2);

   PROCEDURE CREATE_AMW_CTRL_ASSOC(
     P_CONTROL_ID IN NUMBER
    ,P_PROCESS_ID IN NUMBER
    ,P_RISK_ID    IN NUMBER
   );

   PROCEDURE CREATE_AMW_AP_ASSOC(
     P_CONTROL_ID 				  IN NUMBER
    ,P_AUDIT_PROCEDURE_ID		  IN NUMBER
    ,P_DESIGN_EFFECTIVENESS 	  IN VARCHAR2
    ,P_OP_EFFECTIVENESS 		  IN VARCHAR2
	--NPANANDI 12.09.2004: ADDED RETURN STATUS BECAUSE
    --CALLING REVISE_AP BELOW
	,X_RETURN_STATUS			  OUT NOCOPY VARCHAR2
    ,X_MSG_COUNT				  OUT NOCOPY NUMBER
    ,X_MSG_DATA				  OUT NOCOPY VARCHAR2
   );

   PROCEDURE CREATE_AMW_OBJ_ASSOC(
     P_PROCESS_OBJECTIVE_ID 	  IN NUMBER
    ,P_PK1		  				  IN NUMBER
	---01.13.2005 npanandi: added pk2,pk3,pk4,pk5 for Ctrl to Obj association
	,P_PK2						  IN NUMBER DEFAULT NULL
	,P_PK3						  IN NUMBER DEFAULT NULL
	,P_PK4						  IN NUMBER DEFAULT NULL
	,P_PK5						  IN NUMBER DEFAULT NULL
    ,P_OBJECT_TYPE 	  		  	  IN VARCHAR2
   );

   PROCEDURE CREATE_AMW_RISK_ASSOC(
	 P_RISK_ID 	  		   IN NUMBER
	,P_PROCESS_ID	  		   IN NUMBER
	,P_RISK_LIKELIHOOD_CODE   IN VARCHAR2
	,P_RISK_IMPACT_CODE	   IN VARCHAR2
	,P_MATERIAL			   IN VARCHAR2
	,P_MATERIAL_VALUE		   IN NUMBER
   );

   ---
   ---03.01.2005 npanandi: add Audit Procedure Owner privilege here for data security
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
	 ,p_user_id           in number
	 ,p_start_date         in date       default sysdate
	 ,p_end_date           in date       default null);

   ---
   ---03.01.2005 npanandi: function to check access privilege for this Audit Procedure
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
END amw_load_rc_data;

 

/
