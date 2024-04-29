--------------------------------------------------------
--  DDL for Package INV_PROJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PROJECT" AUTHID CURRENT_USER AS
/* $Header: INVPRJIS.pls 120.1 2005/08/01 11:29:32 janetli noship $ */

Procedure resolve_project_references(
	source_project_id		IN	number,
	source_project_number	IN	OUT	NOCOPY varchar2,
	source_task_id			IN	number,
	source_task_number	IN	OUT	NOCOPY varchar2,
	p_project_id			IN	number,
	p_project_number	IN	OUT	NOCOPY varchar2,
	t_task_id			IN	number,
	t_task_number		IN	OUT	NOCOPY varchar2,
	to_project_id			IN	number,
	to_project_number	IN	OUT	NOCOPY varchar2,
	to_task_id			IN	number,
	to_task_number		IN	OUT	NOCOPY varchar2,
	pa_expenditure_org_id		IN	number,
	pa_expenditure_org	IN	OUT	NOCOPY varchar2,
	success			IN	OUT	NOCOPY boolean ) ;


Procedure org_project_parameters(
	org_id				IN	number,
	p_project_reference_enabled	OUT	NOCOPY number,
	p_pm_cost_collection_enabled	OUT	NOCOPY number,
	p_project_control_level		OUT	NOCOPY number,
	success				OUT	NOCOPY boolean);

  Function onhand_qty(
	org_id 		number,
	sub_code	varchar2,
	loc_id		number)return number ;

 Function pending_in_temp(
	org_id		number,
	sub_code	varchar2,
	loc_id		number) return number ;


  Function pending_in_interface(
	org_id		number,
	sub_code	varchar2,
	loc_id		number) return number ;


Procedure onhand_pending_trx(
	org_id				IN	number,
	sub_code			IN	varchar2,
	locator_id			IN	number,
	onhand				OUT	NOCOPY boolean,
	pending_trx			OUT	NOCOPY boolean,
	success				OUT	NOCOPY boolean);

Procedure populate_project_info(
	FM_ORG_ID	IN	NUMBER,
	TO_ORG_ID	IN	NUMBER,
	FM_SUB		IN	VARCHAR2,
	TO_SUB		IN	VARCHAR2,
	FM_LOCATOR	IN	NUMBER,
	TO_LOCATOR	IN	NUMBER,
	F_PROJECT_ID	IN OUT	NOCOPY NUMBER,
	F_TASK_ID	IN OUT	NOCOPY NUMBER,
	T_PROJECT_ID	IN OUT	NOCOPY NUMBER,
	T_TASK_ID	IN OUT 	NOCOPY NUMBER,
	ERROR_CODE	OUT	NOCOPY VARCHAR2,
	ERROR_EXPL	OUT	NOCOPY VARCHAR2,
	SRC_TYPE_ID	IN	NUMBER,
	ACTION_ID	IN	NUMBER,
        SOURCE_ID       IN      NUMBER ) ;

Procedure call_cust_val(
	 V_item_id			IN	number
	,V_revision			IN	varchar2 	DEFAULT NULL
	,V_org_id			IN	number
	,V_sub_code			IN	varchar2
	,V_locator_id			IN	number		DEFAULT NULL
	,V_xfr_org_id			IN	number 		DEFAULT NULL
	,V_xfr_sub_code			IN	varchar2 	DEFAULT NULL
	,V_xfr_locator_id		IN	number 		DEFAULT NULL
	,V_quantity			IN	number
	,V_txn_type_id			IN	number
	,V_txn_action_id		IN	number 		DEFAULT NULL
	,V_txn_source_type_id		IN	number 		DEFAULT NULL
	,V_txn_source_id		IN	number 		DEFAULT NULL
	,V_txn_source_name		IN	varchar2	DEFAULT NULL
	,V_project_id			IN 	number 		DEFAULT NULL
	,V_task_id			IN OUT	NOCOPY number
	,V_source_project_id		IN 	number 		DEFAULT NULL
	,V_source_task_id		IN OUT	NOCOPY number
	,V_to_project_id		IN 	number 		DEFAULT NULL
	,V_to_task_id			IN OUT	NOCOPY number
	,V_txn_date			IN	date
	,V_pa_expenditure_org_id 	IN	number 		DEFAULT NULL
	,V_expenditure_type		IN	varchar2 	DEFAULT NULL
	,V_calling_module		IN	varchar2
	,V_user_id			IN	number
	,V_error_mesg			OUT	NOCOPY varchar2
	,V_warning_mesg			OUT	NOCOPY varchar2
	,V_success_flag			OUT	NOCOPY number
	,V_attribute_category		IN	varchar2
	,V_attribute1			IN	varchar2	DEFAULT NULL
	,V_attribute2			IN	varchar2	DEFAULT NULL
	,V_attribute3			IN	varchar2	DEFAULT NULL
	,V_attribute4			IN	varchar2	DEFAULT NULL
	,V_attribute5			IN	varchar2	DEFAULT NULL
	,V_attribute6			IN	varchar2	DEFAULT NULL
	,V_attribute7			IN	varchar2	DEFAULT NULL
	,V_attribute8			IN	varchar2	DEFAULT NULL
	,V_attribute9			IN	varchar2	DEFAULT NULL
	,V_attribute10			IN	varchar2	DEFAULT NULL
	,V_attribute11			IN	varchar2	DEFAULT NULL
	,V_attribute12			IN	varchar2	DEFAULT NULL
	,V_attribute13			IN	varchar2	DEFAULT NULL
	,V_attribute14			IN	varchar2	DEFAULT NULL
	,V_attribute15			IN	varchar2	DEFAULT NULL );


Procedure update_project_task(v_org_id	       number,
                              v_in_project_id  number,
                              v_in_task_id     number,
                              v_out_project_id in out NOCOPY number,
                              v_out_task_id    in out NOCOPY number);
Procedure update_project_task_number(v_org_id  number,
                              v_in_project_id  number,
                              v_in_task_id     number,
                              v_out_project_id in out NOCOPY number,
                              v_out_task_id    in out NOCOPY number,
                              v_out_project    in out NOCOPY varchar2,
                              v_out_task       in out NOCOPY varchar2);
Procedure Get_project_info_from_Req(
        x_Return_Status         Out NOCOPY Varchar2,
        x_Project_Id            Out NOCOPY Number,
        x_Task_Id               Out NOCOPY Number,
        P_Req_Line_Id           In  Number);

Procedure Get_project_info_for_RcvTrx(
        x_Return_Status         Out NOCOPY Varchar2,
        x_Project_Id            Out NOCOPY Number,
        x_Task_Id               Out NOCOPY Number,
        P_Rcv_Trx_Id            In  Number);

Procedure Get_project_loc_for_prj_Req(
        X_Return_Status         Out     NOCOPY Varchar2,
        X_locator_Id            In Out  NOCOPY Number,
        P_organization_id       In      Number,
        P_Req_Line_Id           In      Number);

Procedure Set_Org_client_info(X_return_Status   Out NOCOPY Varchar2,
                              P_Organization_Id In  Number);

Procedure get_proj_task_from_lpn(
        p_organization_Id       IN  NUMBER,
        p_lpn_id                IN  NUMBER,
        x_project_id            OUT NOCOPY NUMBER,
        x_task_id               OUT NOCOPY NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2);

Function Is_Project_Enabled(
        p_org_id                IN  NUMBER
        ) return VARCHAR2;


PROCEDURE SET_SESSION_PARAMETERS(
                                 X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
                                 X_MSG_COUNT       OUT NOCOPY NUMBER,
                                 X_MSG_DATA        OUT NOCOPY VARCHAR2,
                                 P_ORGANIZATION_ID IN  NUMBER
                                );
FUNCTION GET_LOCATOR(P_LOCATOR_ID IN NUMBER,
                            P_ORG_ID IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_PROJECT_NUMBER(P_PROJECT_ID IN NUMBER) RETURN VARCHAR2;
FUNCTION GET_TASK_NUMBER(P_TASK_ID IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_LOCSEGS(P_LOCATOR_ID IN NUMBER, P_ORG_ID IN NUMBER) RETURN VARCHAR2;
FUNCTION GET_PROJECT_NUMBER RETURN VARCHAR2;
FUNCTION GET_TASK_NUMBER RETURN VARCHAR2;
FUNCTION GET_PROJECT_ID RETURN VARCHAR2;
FUNCTION GET_TASK_ID RETURN VARCHAR2;
--This function is written as a part of bug fix 2902336 for the locator performance issue
FUNCTION GET_LOCSEGS(P_CONCATENATED_SEGMENTS IN VARCHAR2)RETURN VARCHAR2;
FUNCTION GET_PJM_LOCSEGS(p_concatenated_segments IN VARCHAR2)
      RETURN VARCHAR2;
END inv_project;

 

/
