--------------------------------------------------------
--  DDL for Package Body WIP_SFCB_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_SFCB_UTILITIES" AS
/* $Header: wipsfcbb.pls 120.1 2006/05/18 12:44:19 shkalyan noship $ */

/* Private Global variables for Linearity */

g_Linearity_Date_From 	DATE ;
g_Linearity_Date_To	DATE ;
g_Linearity_Line	NUMBER ;
g_Linearity_Org		NUMBER ;

g_userid 	NUMBER;
g_applicationid NUMBER;
g_debug		NUMBER := 0 ;
g_uom_code	VARCHAR2(10);

/* Wip Contants for identifying the type */
WIP_LINEARITY          CONSTANT INTEGER := 6 ;
WIP_LINE_LOAD          CONSTANT INTEGER := 7 ;
WIP_LINE_RL            CONSTANT INTEGER := 8 ;

/*Wip Process Phase Constants */
WIP_LINEARITY_PHASE_ONE       CONSTANT INTEGER := 1 ;
WIP_LINEARITY_PHASE_TWO       CONSTANT INTEGER := 2 ;
WIP_LINE_LOAD_PHASE_ONE       CONSTANT INTEGER := 1 ;
WIP_LINE_LOAD_PHASE_TWO       CONSTANT INTEGER := 2 ;
WIP_LINE_RL_PHASE_ONE         CONSTANT INTEGER := 1 ;
WIP_LINE_RL_PHASE_TWO         CONSTANT INTEGER := 2 ;
WIP_LINE_RL_PHASE_THREE       CONSTANT INTEGER := 3 ;

/* *************************************************************
        Cursor to get all unique department, resource combination
   *************************************************************/
   CURSOR Dept_Res(
		p_org_id number,
		p_res_id number) is
   SELECT distinct
	  organization_id,
	  resource_id,
	  department_id
   FROM   bom_department_resources_v
   WHERE  organization_id = p_org_id
   AND	  resource_id = p_res_id ;



Procedure Update_Group_Id(
		p_temp_group_id	NUMBER,
		p_main_group_id	NUMBER );


/*
   Procedure that populates the efficiency information into
   the temp table
*/

PROCEDURE Populate_Efficiency(
			p_group_id	    IN  NUMBER,
			p_organization_id   IN  NUMBER,
			p_date_from	    IN  DATE,
			p_date_to	    IN  DATE,
			p_department_id     IN  NUMBER,
		        p_resource_id       IN  NUMBER,
			p_userid	    IN  NUMBER,
			p_applicationid	    IN  NUMBER,
			p_errnum	    OUT NOCOPY NUMBER,
			p_errmesg	    OUT NOCOPY VARCHAR2)

IS
x_main_group_id NUMBER ;
x_phase 	VARCHAR2(10) ;
x_temp_group_id	NUMBER;
BEGIN


   x_phase := 'I' ;
   If p_organization_id is null then
		p_errnum := -1 ;
		p_errmesg := 'Failed in Efficiency Phase : '||x_phase||' Organization Id is NULL' ;
		return ;
   End if ;

   x_phase := 'II' ;
   If p_resource_id is null AND p_department_id IS NULL then
		p_errnum := -1 ;
		p_errmesg := 'Failed in Efficiency Phase : '||x_phase||
		             ' Resource Id is NULL and department_id is NULL' ;
		return ;
   End if ;


   IF p_group_id IS NULL THEN
	select wip_indicators_temp_s.nextval into x_main_group_id
	from sys.dual ;
   ELSE
	x_main_group_id := p_group_id ;
   END IF;



   x_phase := 'III' ;
   IF p_resource_id IS NOT NULL THEN

    FOR Dept_Res_Rec IN Dept_Res(
			p_organization_id,
			p_resource_id) LOOP

	-- Generate the new Sequence for this
	begin
		select wip_indicators_temp_s.nextval into x_temp_group_id
		from sys.dual ;
	exception
	  when others then
		x_phase := 'IV';
		p_errnum := -1 ;
		p_errmesg := 'Failed in Efficiency Phase : '||x_phase|| substr(SQLERRM,1,125);
		return ;
	end ;

     	WIP_PROD_INDICATORS.Populate_Efficiency(
			p_group_id => x_temp_group_id,
			p_organization_id => p_organization_id,
			p_date_from => p_date_from,
			p_date_to => p_date_to,
			p_department_id => Dept_Res_Rec.department_id,
			p_resource_id => p_resource_id,
			p_userid => p_userid,
			p_applicationid => p_applicationid,
			p_errnum => p_errnum,
			p_errmesg => p_errmesg );


	Update_Group_Id(
			p_temp_group_id => x_temp_group_id,
			p_main_group_id => x_main_group_id);


      END LOOP ;

    /* The new section added for the department production indicators
    */
    ELSIF p_department_id IS NOT NULL AND p_resource_id IS NULL THEN

                 WIP_PROD_INDICATORS.Populate_Efficiency(
			p_group_id => x_main_group_id,
			p_organization_id => p_organization_id,
			p_date_from => p_date_from,
			p_date_to => p_date_to,
			p_department_id => p_department_id,
			p_resource_id => p_resource_id,
			p_userid => p_userid,
			p_applicationid => p_applicationid,
			p_errnum => p_errnum,
			p_errmesg => p_errmesg );


    END IF ;
   p_errnum := 1 ;
   p_errmesg := null ;
   return ;


 Exception

	when others then

		p_errnum := -1 ;
		p_errmesg := 'Failed in Efficiency Phase : '||x_phase|| substr(SQLERRM,1,125);
		return ;

END Populate_Efficiency;



PROCEDURE Populate_Utilization (
			p_group_id	    IN  NUMBER,
			p_organization_id   IN  NUMBER,
			p_date_from	    IN  DATE,
			p_date_to	    IN  DATE,
			p_department_id     IN  NUMBER,
       			p_resource_id       IN  NUMBER,
			p_userid	    IN  NUMBER,
			p_applicationid	    IN  NUMBER,
			p_errnum	    OUT NOCOPY NUMBER,
			p_errmesg	    OUT NOCOPY VARCHAR2)
IS
x_main_group_id NUMBER ;
x_phase 	VARCHAR2(10) ;
x_temp_group_id	NUMBER;
BEGIN


   x_phase := 'I' ;
   If p_organization_id is null then
		p_errnum := -1 ;
		p_errmesg := 'Failed in Utilization Phase : '||x_phase||' Organization Id is NULL' ;
		return ;
   End if ;

   x_phase := 'II' ;
   If p_resource_id is null AND p_department_id IS NULL then
		p_errnum := -1 ;
		p_errmesg := 'Failed in Utilization Phase : '||x_phase||
		             ' Resource Id is NULL and department_id is NULL' ;
		return ;
   End if ;


   IF p_group_id IS NULL THEN
	select wip_indicators_temp_s.nextval into x_main_group_id
	from sys.dual ;
   ELSE
	x_main_group_id := p_group_id ;
   END IF;



   x_phase := 'III' ;

   IF p_resource_id IS NOT NULL then

     FOR Dept_Res_Rec IN Dept_Res(
			p_organization_id,
			p_resource_id) LOOP

	-- Generate the new Sequence for this
	begin
		select wip_indicators_temp_s.nextval into x_temp_group_id
		from sys.dual ;
	exception
	  when others then
		x_phase := 'IV';
		p_errnum := -1 ;
		p_errmesg := 'Failed in Utilization Phase : '||x_phase|| substr(SQLERRM,1,125);
		return ;
	end ;

     	WIP_PROD_INDICATORS.Populate_Utilization(
			p_group_id => x_temp_group_id,
			p_organization_id => p_organization_id,
			p_date_from => p_date_from,
			p_date_to => p_date_to,
			p_department_id => Dept_Res_Rec.department_id,
			p_resource_id => p_resource_id,
			p_userid => p_userid,
			p_applicationid => p_applicationid,
			p_errnum => p_errnum,
			p_errmesg => p_errmesg,
			p_sfcb => 1 );


	Update_Group_Id(
			p_temp_group_id => x_temp_group_id,
			p_main_group_id => x_main_group_id);


      END LOOP ;


   ELSIF p_department_id IS NOT NULL AND p_resource_id IS NULL then


     	WIP_PROD_INDICATORS.Populate_Utilization(
			p_group_id => x_main_group_id,
			p_organization_id => p_organization_id,
			p_date_from => p_date_from,
			p_date_to => p_date_to,
			p_department_id => p_department_id,
			p_resource_id => p_resource_id,
			p_userid => p_userid,
			p_applicationid => p_applicationid,
			p_errnum => p_errnum,
			p_errmesg => p_errmesg,
			p_sfcb => 1 );


   END IF ;
   p_errnum := 1 ;
   p_errmesg := null ;
   return ;


 Exception

	when others then

		p_errnum := -1 ;
		p_errmesg := 'Failed in Utilization Phase : '||x_phase|| substr(SQLERRM,1,125);
		return ;

END Populate_Utilization;


PROCEDURE Populate_Productivity(
			p_group_id	    IN  NUMBER,
			p_organization_id   IN  NUMBER,
			p_date_from	    IN  DATE,
			p_date_to	    IN  DATE,
			p_department_id     IN  NUMBER,
		       	p_resource_id       IN  NUMBER,
			p_userid	    IN  NUMBER,
			p_applicationid	    IN  NUMBER,
			p_errnum	    OUT NOCOPY NUMBER,
			p_errmesg	    OUT NOCOPY VARCHAR2)

IS
x_main_group_id NUMBER ;
x_phase 	VARCHAR2(10) ;
x_temp_group_id	NUMBER;
BEGIN


   x_phase := 'I' ;
   If p_organization_id is null then
		p_errnum := -1 ;
		p_errmesg := 'Failed in Productivity Phase : '||x_phase||' Organization Id is NULL' ;
		return ;
   End if ;

   x_phase := 'II' ;
   If p_resource_id is null AND p_department_id IS NULL then
		p_errnum := -1 ;
		p_errmesg := 'Failed in Productivity Phase : '||x_phase||
		             ' Resource Id is NULL and department_id is NULL' ;
		return ;
   End if ;



   IF p_group_id IS NULL THEN
	select wip_indicators_temp_s.nextval into x_main_group_id
	from sys.dual ;
   ELSE
	x_main_group_id := p_group_id ;
   END IF;



   x_phase := 'III' ;
   IF p_resource_id IS NOT NULL then

      FOR Dept_Res_Rec IN Dept_Res(
			p_organization_id,
			p_resource_id) LOOP

	-- Generate the new Sequence for this
	begin
		select wip_indicators_temp_s.nextval into x_temp_group_id
		from sys.dual ;
	exception
	  when others then
		x_phase := 'IV';
		p_errnum := -1 ;
		p_errmesg := 'Failed in Productivity Phase : '||x_phase|| substr(SQLERRM,1,125);
		return ;
	end ;

     	WIP_PROD_INDICATORS.Populate_Productivity(
			p_group_id => x_temp_group_id,
			p_organization_id => p_organization_id,
			p_date_from => p_date_from,
			p_date_to => p_date_to,
			p_department_id => Dept_Res_Rec.department_id,
			p_resource_id => p_resource_id,
			p_userid => p_userid,
			p_applicationid => p_applicationid,
			p_errnum => p_errnum,
			p_errmesg => p_errmesg) ;


	Update_Group_Id(
			p_temp_group_id => x_temp_group_id,
			p_main_group_id => x_main_group_id);


      END LOOP ;


    ELSIF p_department_id IS NOT NULL AND p_resource_id IS NULL THEN

     	WIP_PROD_INDICATORS.Populate_Productivity(
			p_group_id => x_main_group_id,
			p_organization_id => p_organization_id,
			p_date_from => p_date_from,
			p_date_to => p_date_to,
			p_department_id => p_department_id,
			p_resource_id => p_resource_id,
			p_userid => p_userid,
			p_applicationid => p_applicationid,
			p_errnum => p_errnum,
			p_errmesg => p_errmesg) ;


    END IF ;
   p_errnum := 1 ;
   p_errmesg := null ;
   return ;


 Exception

	when others then

		p_errnum := -1 ;
		p_errmesg := 'Failed in Productivity Phase : '||x_phase|| substr(SQLERRM,1,125);
		return ;

END Populate_Productivity;



PROCEDURE Populate_Resource_Load (
			p_group_id	    IN  NUMBER,
			p_organization_id   IN  NUMBER,
			p_date_from	    IN  DATE,
		       	p_date_to	    IN  DATE,
			p_department_id     IN  NUMBER,
			p_resource_id       IN  NUMBER,
			p_userid	    IN  NUMBER,
			p_applicationid	    IN  NUMBER,
			p_errnum	    OUT NOCOPY NUMBER,
			p_errmesg	    OUT NOCOPY VARCHAR2)
IS
x_main_group_id NUMBER ;
x_phase 	VARCHAR2(10) ;
x_temp_group_id	NUMBER;
BEGIN


   /************************************************
   * Check for the set of required parameters
   *     1. Organization Id
   *     2. Resource ID
   *************************************************/

   x_phase := 'I' ;
   If p_organization_id is null then
		p_errnum := -1 ;
		p_errmesg := 'Failed in Resource Load Phase : '||x_phase||' Organization Id is NULL' ;
		return ;
   End if ;

   x_phase := 'II' ;
   If p_resource_id is null AND p_department_id IS NULL then
		p_errnum := -1 ;
		p_errmesg := 'Failed in Productivity Phase : '||x_phase||
		             ' Resource Id is NULL and department_id is NULL' ;
		return ;
   End if ;



   /***********************************************
   * If the Group ID is null then we would generate
   * a new group id from the sequence
   ***********************************************/


   IF p_group_id IS NULL THEN
	select wip_indicators_temp_s.nextval into x_main_group_id
	from sys.dual ;
   ELSE
	x_main_group_id := p_group_id ;
   END IF;



   x_phase := 'III' ;
   IF p_resource_id IS NOT NULL then

     FOR Dept_Res_Rec IN Dept_Res(
			p_organization_id,
			p_resource_id) LOOP

	-- Generate the new Sequence for this
	begin
		select wip_indicators_temp_s.nextval into x_temp_group_id
		from sys.dual ;
	exception
	  when others then
		x_phase := 'IV';
		p_errnum := -1 ;
		p_errmesg := 'Failed in Resource Load Phase : '||x_phase|| substr(SQLERRM,1,125);
		return ;
	end ;

     	WIP_PROD_INDICATORS.Populate_Resource_Load(
			p_group_id => x_temp_group_id,
			p_organization_id => p_organization_id,
			p_date_from => p_date_from,
			p_date_to => p_date_to,
			p_department_id => Dept_Res_Rec.department_id,
			p_resource_id => p_resource_id,
			p_userid => p_userid,
			p_applicationid => p_applicationid,
			p_errnum => p_errnum,
			p_errmesg => p_errmesg) ;


	Update_Group_Id(
			p_temp_group_id => x_temp_group_id,
			p_main_group_id => x_main_group_id);


     END LOOP ;

    ELSIF p_department_id IS NOT NULL AND p_resource_id IS NULL THEN

     	WIP_PROD_INDICATORS.Populate_Resource_Load(
			p_group_id => x_main_group_id,
			p_organization_id => p_organization_id,
			p_date_from => p_date_from,
			p_date_to => p_date_to,
			p_department_id => p_department_id,
			p_resource_id => p_resource_id,
			p_userid => p_userid,
			p_applicationid => p_applicationid,
			p_errnum => p_errnum,
			p_errmesg => p_errmesg) ;


   END IF ;
   p_errnum := 1 ;
   p_errmesg := null ;
   return ;


 Exception

	when others then

		p_errnum := -1 ;
		p_errmesg := 'Failed in Resource Load Phase : '||x_phase|| substr(SQLERRM,1,125);
		return ;

END Populate_Resource_Load;


Procedure Update_Group_Id(
		p_temp_group_id	NUMBER,
		p_main_group_id	NUMBER) IS

Begin

	UPDATE Wip_Indicators_Temp
	SET group_id = p_main_group_id
	WHERE
	    group_id = p_temp_group_id ;

End Update_Group_Id ;



/***********************************************************
* This is the API that gets called from the PCB - department
* supervisor/ department operator for resource charging.
* This API inserts the resource transaction data into the
* Wip_Resource_Txn_Interface and uses the Resource_Txn
* API written by bbaby and rbankar
*********************************************************/


PROCEDURE Resource_Txn (
			p_DEPARTMENT_ID		IN	NUMBER,
			p_EMPLOYEE_ID		IN 	NUMBER,
			p_EMPLOYEE_NUM		IN	NUMBER,
			p_LINE_ID		IN 	NUMBER,
			p_OPERATION_SEQ_NUM	IN 	NUMBER,
			p_ORGANIZATION_ID	IN	NUMBER,
			p_PRIMARY_QUANTITY	IN	NUMBER,
			p_PROJECT_ID		IN 	NUMBER,
			p_REASON_ID		IN	NUMBER,
			p_REFERENCE		IN	VARCHAR2,
			p_RESOURCE_ID		IN 	NUMBER,
			p_RESOURCE_SEQ_NUM	IN 	NUMBER,
			p_REPETITIVE_SCHEDULE_ID IN	NUMBER,
			p_SOURCE_CODE		IN 	VARCHAR2,
			p_TASK_ID		IN	NUMBER,
			p_TRANSACTION_DATE	IN	DATE,
			p_TRANSACTION_QUANTITY	IN 	NUMBER,
			p_WIP_ENTITY_ID		IN	NUMBER,
			p_ACCT_PERIOD_ID    	IN 	NUMBER	DEFAULT NULL,
			p_ACTIVITY_ID		IN	NUMBER	DEFAULT NULL,
			p_ACTIVITY_NAME	    	IN  	VARCHAR2  DEFAULT NULL,
			p_ACTUAL_RESOURCE_RATE 	IN 	NUMBER 	      DEFAULT NULL,
	   		p_CREATED_BY		IN 	NUMBER DEFAULT NULL,
			p_CREATED_BY_NAME	IN      VARCHAR2 DEFAULT NULL,
			p_LAST_UPDATED_BY	IN	NUMBER,
			p_LAST_UPDATED_BY_NAME	IN	VARCHAR2 DEFAULT NULL,
			p_LAST_UPDATE_DATE	IN 	DATE	DEFAULT NULL,
			p_LAST_UPDATE_LOGIN	IN	NUMBER,
			p_ATTRIBUTE1		IN	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE10		IN 	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE11		IN 	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE12		IN 	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE13		IN 	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE14		IN  	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE15		IN	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE2		IN	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE3		IN	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE4		IN	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE5		IN	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE6		IN 	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE7		IN 	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE8		IN 	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE9		IN 	VARCHAR2 DEFAULT NULL,
			p_ATTRIBUTE_CATEGORY	IN	VARCHAR2 DEFAULT NULL,
			p_AUTOCHARGE_TYPE	IN 	NUMBER	DEFAULT NULL,
			p_BASIS_TYPE		IN 	NUMBER	DEFAULT NULL,
			p_COMPLETION_TRANSACTION_ID IN 	NUMBER DEFAULT NULL,
			p_CREATION_DATE		IN	DATE	DEFAULT NULL,
			p_CURRENCY_ACTUAL_RSC_RATE IN NUMBER DEFAULT NULL,
			p_CURRENCY_CODE		IN	VARCHAR2 DEFAULT NULL,
			p_CURRENCY_CONVERSION_DATE IN   DATE DEFAULT NULL,
			p_CURRENCY_CONVERSION_RATE IN   NUMBER DEFAULT NULL,
			p_CURRENCY_CONVERSION_TYPE IN   VARCHAR2 DEFAULT NULL,
			p_DEPARTMENT_CODE	IN 	VARCHAR2 DEFAULT NULL,
			p_ENTITY_TYPE		IN 	NUMBER  DEFAULT NULL,
			p_GROUP_ID		IN 	NUMBER	DEFAULT NULL,
			p_LINE_CODE		IN 	VARCHAR2 DEFAULT NULL,
			p_MOVE_TRANSACTION_ID	IN 	NUMBER	DEFAULT NULL,
			p_ORGANIZATION_CODE	IN 	VARCHAR2 DEFAULT NULL,
			p_PO_HEADER_ID		IN 	NUMBER 	DEFAULT NULL,
			p_PO_LINE_ID		IN	NUMBER	DEFAULT NULL,
			p_PRIMARY_ITEM_ID	IN	NUMBER	DEFAULT NULL,
			p_PRIMARY_UOM		IN 	VARCHAR2 DEFAULT NULL,
			p_PRIMARY_UOM_CLASS	IN	VARCHAR2 DEFAULT NULL,
			p_PROCESS_PHASE		IN	NUMBER	DEFAULT NULL,
			p_PROCESS_STATUS	IN	NUMBER	DEFAULT NULL,
			p_PROGRAM_APPLICATION_ID IN	NUMBER	DEFAULT NULL,
			p_PROGRAM_ID		IN 	NUMBER	DEFAULT NULL,
			p_PROGRAM_UPDATE_DATE	IN	DATE	DEFAULT NULL,
			p_RCV_TRANSACTION_ID	IN	NUMBER	DEFAULT NULL,
			p_REASON_NAME		IN 	VARCHAR2 DEFAULT NULL,
			p_RECEIVING_ACCOUNT_ID	IN	NUMBER DEFAULT NULL,
			p_REQUEST_ID		IN	NUMBER DEFAULT NULL,
			p_RESOURCE_CODE		IN 	VARCHAR2 DEFAULT NULL,
			p_RESOURCE_TYPE		IN	NUMBER DEFAULT NULL,
			p_SOURCE_LINE_ID	IN	NUMBER	DEFAULT NULL,
			p_STANDARD_RATE_FLAG	IN	NUMBER  DEFAULT NULL,
			p_TRANSACTION_ID	IN 	NUMBER DEFAULT NULL,
			p_TRANSACTION_TYPE	IN 	NUMBER	DEFAULT NULL,
			p_TRANSACTION_UOM	IN	VARCHAR2 DEFAULT NULL,
			p_USAGE_RATE_OR_AMOUNT	IN 	NUMBER	DEFAULT NULL,
			p_WIP_ENTITY_NAME	IN 	VARCHAR2 DEFAULT NULL,
		        p_ret_status            OUT NOCOPY     VARCHAR2
		)  is
l_res_txn_rec Wip_Transaction_PUB.Res_rec_Type ;
l_msg_count NUMBER;
l_msg_data  VARCHAR2(240);
x_txn_date   DATE ;
Begin

	if (p_Transaction_Date is null) then
		x_txn_date := sysdate ;
	else
		x_txn_date := p_TRANSACTION_DATE ;
	end if ;



	l_res_txn_rec.acct_period_id := p_acct_period_id ;
    	l_res_txn_rec.activity_id := p_activity_id ;
   	l_res_txn_rec.activity_name := p_activity_name ;
        l_res_txn_rec.actual_resource_rate := p_actual_resource_rate ;
        l_res_txn_rec.attribute1 := p_attribute1 ;
        l_res_txn_rec.attribute10 := p_attribute10  ;
        l_res_txn_rec.attribute11 := p_attribute11  ;
        l_res_txn_rec.attribute12 := p_attribute12  ;
        l_res_txn_rec.attribute13 := p_attribute13  ;
        l_res_txn_rec.attribute14 := p_attribute14  ;
        l_res_txn_rec.attribute15 := p_attribute15  ;
        l_res_txn_rec.attribute2 :=  p_attribute2 ;
        l_res_txn_rec.attribute3 :=  p_attribute3 ;
        l_res_txn_rec.attribute4 :=  p_attribute4 ;
        l_res_txn_rec.attribute5 :=  p_attribute5 ;
        l_res_txn_rec.attribute6 :=  p_attribute6 ;
        l_res_txn_rec.attribute7 :=  p_attribute7 ;
        l_res_txn_rec.attribute8 :=  p_attribute8 ;
        l_res_txn_rec.attribute9 :=  p_attribute9 ;
        l_res_txn_rec.attribute_category := p_attribute_category  ;
        l_res_txn_rec.autocharge_type :=  p_autocharge_type ;
        l_res_txn_rec.basis_type :=  p_basis_type ;
        l_res_txn_rec.completion_transaction_id := p_completion_transaction_id  ;
        l_res_txn_rec.created_by := p_created_by  ;
        l_res_txn_rec.created_by_name := p_created_by_name  ;
        l_res_txn_rec.creation_date := p_creation_date  ;
        l_res_txn_rec.currency_actual_rsc_rate := p_currency_actual_rsc_rate  ;
        l_res_txn_rec.currency_code := p_currency_code  ;
        l_res_txn_rec.currency_conversion_date := p_currency_conversion_date  ;
        l_res_txn_rec.currency_conversion_rate := p_currency_conversion_rate  ;
        l_res_txn_rec.currency_conversion_type := p_currency_conversion_type  ;
        l_res_txn_rec.department_code := p_department_code  ;
        l_res_txn_rec.department_id := p_department_id  ;
        l_res_txn_rec.employee_id := p_employee_id  ;
        l_res_txn_rec.employee_num := p_employee_num  ;
        l_res_txn_rec.entity_type := p_entity_type  ;
        l_res_txn_rec.group_id := p_group_id  ;
        l_res_txn_rec.last_updated_by := p_last_updated_by  ;
        l_res_txn_rec.last_updated_by_name := p_last_updated_by_name  ;
        l_res_txn_rec.last_update_date := p_last_update_date  ;
        l_res_txn_rec.last_update_login := p_last_update_login  ;
        l_res_txn_rec.line_code := p_line_code  ;
        l_res_txn_rec.line_id := p_line_id  ;
        l_res_txn_rec.move_transaction_id := p_move_transaction_id  ;
        l_res_txn_rec.operation_seq_num := p_operation_seq_num  ;
        l_res_txn_rec.organization_code := p_organization_code  ;
        l_res_txn_rec.organization_id := p_organization_id  ;
        l_res_txn_rec.po_header_id := p_po_header_id  ;
        l_res_txn_rec.po_line_id := p_po_line_id  ;
        l_res_txn_rec.primary_item_id := p_primary_item_id  ;
        l_res_txn_rec.primary_quantity := p_primary_quantity  ;
        l_res_txn_rec.primary_uom := p_primary_uom  ;
        l_res_txn_rec.primary_uom_class := p_primary_uom_class  ;
        l_res_txn_rec.process_phase := p_process_phase  ;
        l_res_txn_rec.process_status := p_process_status  ;
        l_res_txn_rec.program_application_id := p_program_application_id  ;
        l_res_txn_rec.program_id := p_program_id  ;
        l_res_txn_rec.program_update_date := p_program_update_date  ;
        l_res_txn_rec.project_id := p_project_id  ;
        l_res_txn_rec.rcv_transaction_id := p_rcv_transaction_id  ;
        l_res_txn_rec.reason_id := p_reason_id  ;
        l_res_txn_rec.reason_name := p_reason_name  ;
        l_res_txn_rec.receiving_account_id := p_receiving_account_id  ;
        l_res_txn_rec.reference := p_reference  ;
        l_res_txn_rec.repetitive_schedule_id := p_repetitive_schedule_id  ;
        l_res_txn_rec.request_id := p_request_id  ;
        l_res_txn_rec.resource_code := p_resource_code  ;
        l_res_txn_rec.resource_id := p_resource_id  ;
        l_res_txn_rec.resource_seq_num := p_resource_seq_num  ;
        l_res_txn_rec.resource_type := p_resource_type  ;
        l_res_txn_rec.source_code := p_source_code  ;
        l_res_txn_rec.source_line_id := p_source_line_id  ;
        l_res_txn_rec.standard_rate_flag := p_standard_rate_flag  ;
        l_res_txn_rec.task_id := p_task_id  ;
        l_res_txn_rec.transaction_date := x_txn_date  ;
        l_res_txn_rec.transaction_id := p_transaction_id  ;
        l_res_txn_rec.transaction_quantity := p_transaction_quantity  ;
        l_res_txn_rec.transaction_type := p_transaction_type  ;
        l_res_txn_rec.transaction_uom := p_transaction_uom  ;
        l_res_txn_rec.usage_rate_or_amount := p_usage_rate_or_amount  ;
        l_res_txn_rec.wip_entity_id := p_wip_entity_id  ;
        l_res_txn_rec.wip_entity_name := p_wip_entity_name  ;


	WIP_Transaction_PVT.Process_Resource_Transaction(
		p_res_txn_rec => l_res_txn_rec,
		p_return_status => p_ret_status,
		p_msg_count  =>  l_msg_count,
		p_msg_data   =>  l_msg_data ) ;

	-- commit regardless of status..
	--if (p_ret_status <> FND_API.G_RET_STS_SUCCESS) then
	--	rollback;
	--else

	-- this was to fix the bug#845918
	commit ;

	--end if;

End Resource_Txn ;


--------------------------------------------------
--  This procedure updates the Current Line Operation
--  in the Wip_Flow_Schedules for a particular
--  flow schedule.
--------------------------------------------------
PROCEDURE Update_Line_Operation (
			p_line_operation IN NUMBER,
			p_wip_entity_id IN NUMBER,
			p_organization_id IN NUMBER )
IS

BEGIN

	Update Wip_Flow_Schedules
	SET current_Line_Operation = p_line_operation
	WHERE
	     Wip_Entity_Id = p_wip_entity_id
	AND  Organization_Id = p_organization_id ;


END Update_Line_Operation ;




/**************************************************
*  This procedure calculates the Line Load for a
*  particular line and this is called from the
*  flow operator Work bench
*
*  yulin, to support oracle time zone
*  p_date_from and p_date_to should be date only
*  to represent a whole day in client timezone
*************************************************/

Procedure Populate_Line_Load(
		p_group_id  IN  NUMBER,
		p_date_from IN	DATE,
		p_date_to   IN  DATE,
		p_line_id   IN  NUMBER,
		p_userid    IN  NUMBER,
		p_applicationid IN NUMBER,
		p_errnum    OUT NOCOPY NUMBER,
		p_errmesg   OUT NOCOPY VARCHAR2)
IS
x_phase 	VARCHAR2(10) ;
x_group_id   NUMBER ;
x_date_to    DATE ;
x_available_quantity NUMBER ;
x_userid      NUMBER;
x_appl_id     NUMBER;
x_org_id      NUMBER;
BEGIN

   /************************************************
   * Check for the set of required parameters
   *     1. Line Id
   *     2. Date From
   *************************************************/


        x_phase := 'I';
   	If p_line_id is null then
		p_errnum := -1 ;
		p_errmesg := 'Failed in Line Load Phase : '||x_phase||' Line Id is NULL' ;
		return ;
   	End if ;


   	If p_date_from is null then
		p_errnum := -1 ;
		p_errmesg := 'Failed in Line Load Phase : '||x_phase||' Date From is NULL' ;
		return ;
   	End if ;


   /***********************************************
   * If the To Date is null, default the sysdate
   * to be the To Date
   ***********************************************/

   	If p_date_to is null then
		x_date_to := trunc(wip_sfcb_utilities.sdate_to_cdate(sysdate)) ;
	ELSE
		x_date_to := p_date_to ;
   	End if ;


   /***********************************************
   * If the Group ID is null then we would generate
   * a new group id from the sequence
   ***********************************************/

     IF p_group_id IS NULL THEN
		select wip_indicators_temp_s.nextval into x_group_id
		from sys.dual ;
	ELSE
		x_group_id := p_group_id ;
   	END IF;


	-- Defaulting the User Id, if it is not send in

        if p_userid is null then
                -- This is an Error Condition
                x_userid :=  fnd_global.user_id ;
        else
                x_userid := p_userid ;
        end if;

	-- Defaulting the Application Id, if it is not send in

        if p_applicationid is null then
                -- This is an Error Condition
                x_appl_id :=  fnd_global.prog_appl_id ;
        else
                x_appl_id := p_applicationid ;
        end if;

        g_userid := x_userid ;
        g_applicationid := x_appl_id ;



	-- Get the line rate, the quantity that can be
	-- produced by the line every day.

	x_phase := 'II';
	select
	  ((stop_time - start_time)*maximum_rate)/3600
	into
	   x_available_quantity
	from
	   wip_lines
	where
	   line_id = p_line_id ;


        x_phase := 'III';

--dbms_output.put_line('Before the Insert statement');
--dbms_output.put_line(to_char(p_date_from,'DD-Mon-YYYY'));
	--dbms_output.put_line(to_char(x_date_to,'DD-Mon-YYYY'));

	-- Insert the planned quantity and the available quantity for
	-- every day based on the WFS table. Note this will make the
	-- assumption that the line will be working on non working days
	-- also if, a flow schedule is required on a non working day.
	-- To correct this hack we actually perform a update at the end
	-- of this procedure (that is a hack, you can do a join in this
	-- sql statement and actually perform the whole intelligent insert
	-- in this statement itself).

	insert into wip_indicators_temp(
		group_id,
		line_id,
		transaction_date,
		required_quantity,
		available_quantity,
		indicator_type,
		process_phase,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		program_application_id )
	select
		x_group_id,
		p_line_id,
		trunc(wip_sfcb_utilities.sdate_to_cdate(wfs.scheduled_completion_date)),
		sum(wfs.planned_quantity),
		x_available_quantity,
		WIP_LINE_LOAD,
		WIP_LINE_LOAD_PHASE_ONE,
		sysdate,
		x_userid,
		sysdate,
		x_userid,
		x_appl_id
	from
		wip_flow_schedules wfs
	where
		wfs.line_id = p_line_id
	and	trunc(wip_sfcb_utilities.sdate_to_cdate(wfs.scheduled_completion_date))
                  between p_date_from and x_date_to
	group by trunc(wip_sfcb_utilities.sdate_to_cdate(wfs.scheduled_completion_date)) ;


        /* bug 2644622 - from meeting with richard and adrian, should only display
               days with a schedule.  So commenting this section out.
	-- Insert tha line availability for all the days when the line
	-- is available, but there is no load on the line. I.e., there
	-- are no records in WFS.

        -- insert into wip_indicators_temp(
        --        group_id,
        --        line_id,
        --        transaction_date,
        --        required_quantity,
        --        available_quantity,
        --        indicator_type,
        --        process_phase,
        --        last_update_date,
        --        last_updated_by,
        --        creation_date,
        --        created_by,
	--	program_application_id )
        --select
        --        x_group_id,
        --        p_line_id,
        --        bcd.calendar_date,
        --        null,
        --        x_available_quantity,
        --        WIP_LINE_LOAD,
        --        WIP_LINE_LOAD_PHASE_ONE,
        --        sysdate,
        --        x_userid,
        --        sysdate,
        --        x_userid,
	--	x_appl_id
	--from
	--        bom_calendar_dates bcd,
      	--        mtl_parameters mp,
	--	wip_lines wl
	--where
	--	wl.line_id = p_line_id
     	--and     mp.organization_id = wl.organization_id
        --and     bcd.calendar_code = mp.calendar_code
        --and     bcd.exception_set_id = mp.calendar_exception_set_id
        --and     bcd.calendar_date between p_date_from and p_date_to
        --and     bcd.seq_num is not null
	--and     bcd.calendar_date not in
	--        (    	Select distinct transaction_date
	--		from   wip_indicators_temp
	--		where  group_id = x_group_id
	--		and    indicator_type = WIP_LINE_LOAD
	--		and    process_phase = WIP_LINE_LOAD_PHASE_ONE
	--        ) ;
        */


	-- This is a hack and is used to update the availability of
	-- the line to be null on the non working days as per
	-- the decision by jgu and dsoosai

	-- add flm_timezone call to support timezone
	SELECT organization_id
	INTO x_org_id
	FROM wip_lines
	WHERE line_id = p_line_id;
	flm_timezone.init_timezone(x_org_id);
	UPDATE wip_indicators_temp wit
        SET    wit.available_quantity = 0
        WHERE wit.group_id = x_group_id
          and flm_timezone.client_to_calendar(wit.transaction_date) NOT IN (
	        SELECT bcd.calendar_date
	        FROM   bom_calendar_dates bcd,
      	               mtl_parameters mp,
		       wip_lines wl
	        where
		        wl.line_id = p_line_id
     	        and     mp.organization_id = wl.organization_id
                and     bcd.calendar_code = mp.calendar_code
                and     bcd.exception_set_id = mp.calendar_exception_set_id
                and     bcd.calendar_date between
                            flm_timezone.client_to_calendar(p_date_from) and
                            flm_timezone.client_to_calendar(p_date_to)
                and     bcd.seq_num is not null
              ) ;


  Exception

	When others then
--dbms_output.put_line('In the exception region');

		p_errnum := -1 ;
		p_errmesg := 'Failed in Line Load Phase : '||x_phase|| substr(SQLERRM,1,125);
		return ;



End Populate_Line_Load ;



/*  ---------------------------------
--  Set of procedures required for setting
--  the variables for calculating linearity
-------------------------------------- */

Procedure Set_Organization(p_org_Id IN NUMBER) is
Begin

    g_Linearity_Org := p_org_id ;

End Set_Organization;


Procedure Set_Linearity_Dates(
			p_from_date IN DATE DEFAULT NULL,
			p_to_date   IN DATE DEFAULT NULL ) IS
x_from_date DATE := sysdate - 7;
x_to_date   DATE := sysdate ;
Begin

        If p_from_date is not null then
		x_from_date := p_from_date ;
	End if ;

	If p_to_date is not null then
		x_to_date := p_to_date ;
	End if ;

	g_Linearity_Date_From := x_from_date ;
	g_Linearity_Date_To :=  x_to_date ;

End Set_Linearity_Dates ;


Procedure Set_Line(p_line_id IN NUMBER) is
Begin

    g_Linearity_Line := p_line_id ;

End Set_Line;


Function get_Organization RETURN NUMBER Is
Begin
	return g_Linearity_Org ;
End get_Organization ;


Function get_Linearity_From_Date RETURN DATE is
Begin

	return g_Linearity_Date_From;

End get_Linearity_From_Date ;


Function get_Linearity_To_Date RETURN DATE is
Begin

	return g_Linearity_Date_To;

End get_Linearity_To_Date ;


Function get_Line RETURN NUMBER IS
Begin

    return g_Linearity_Line ;

End get_Line;


-- Checks whether or not the line operation is pending based on the current line operation which
-- is to be worked on (column in WFS).  The line operation and current line operation passed in
-- are the actual operation sequence numbers and not the ID's!
function line_op_is_pending (
			     p_line_op in number,
			     p_rtg_seq_id in number,
			     p_assy_item_id IN NUMBER,
			     p_org_id IN NUMBER,
			     p_alt_rtg_designator IN VARCHAR2,
			     p_current_line_op in NUMBER DEFAULT NULL
) return number
  IS

     ops_table bom_rtg_network_api.op_tbl_type ;
     i BINARY_INTEGER;

begin

  -- If no current line op is specified, get the list of all line ops
  -- for the routing.  This is when just starting out..
  if (p_current_line_op IS NULL) then

     bom_rtg_network_api.get_all_line_ops(
					  P_RTG_SEQUENCE_ID => p_rtg_seq_id,
					  P_ASSY_ITEM_ID => p_assy_item_id,
					  P_ORG_ID => p_org_id,
					  P_ALT_RTG_DESIG => p_alt_rtg_designator,
					  X_OP_TBL => ops_table
					  );

  -- If the current line op is -1, then we have completed the last line operation for
  -- the schedule.  We will know immediately that the line op isn't pending.
  ELSIF (p_current_line_op = -1) THEN

    RETURN 2 ;

  -- In the special case that the line op is the same as the current line op,
  -- we can immediately tell that the line op is pending.
  elsif (p_line_op = p_current_line_op) then

    return 1 ;

  -- If the current line op is non-null and different from the specified
  -- line op, get the list of all line ops that appear _after_ the current
  -- op in the routing.
  else

     bom_rtg_network_api.get_all_next_line_ops(
					       p_rtg_sequence_id => p_rtg_seq_id,
					       p_assy_item_id => p_assy_item_id,
					       p_org_id => p_org_id,
					       p_alt_rtg_desig => p_alt_rtg_designator,
					       p_curr_line_op => p_current_line_op,
					       x_op_tbl => ops_table
       );

  end if ;

  -- The specified line op is pending iff it is in the list of line ops
  -- we retrieved.

  IF (ops_table.COUNT > 0) then

     FOR i IN ops_table.first..ops_table.last LOOP

        IF ops_table(i).operation_seq_num = p_line_op THEN
	   RETURN 1;
        END IF;

     END LOOP;

  END IF;


  return 2 ;


  EXCEPTION
    WHEN OTHERS THEN RETURN 1;

end line_op_is_pending ;


/* This is called from the Flow Operator
   Work Bench. This is done in the following
   4 steps :

     1. Get the list Open Schedules from the
	Wip_Open_Schedules_V for that particular
	Line and Line Operation.

     1. Get the Maximum and Minimum Simulation
	Dates from wip_open_schedules_v view.

     2. Call the Resource Availability Routine

     3. Either open the cursor, and for every
        flow schedule and get the resource requirements
	or get the resource requirements in one
	step.

     4. Sum the resource requirements across the
	schedules.

     5. Update the available hours.

*** to support oracle timez zone
 p_from_date, p_to_date should be date only, to represent
 a whole day in client time zone

*/

PROCEDURE Populate_Line_Resource_Load (
             p_group_id          IN  NUMBER,
             p_organization_id   IN  NUMBER,
             p_date_from         IN  DATE,
             p_date_to           IN  DATE,
	     p_line_id		 IN  NUMBER,
             p_line_op_id        IN  NUMBER,
             p_userid            IN  NUMBER,
             p_applicationid     IN  NUMBER,
             p_errnum            OUT NOCOPY NUMBER,
             p_errmesg           OUT NOCOPY VARCHAR2)   IS
  x_date_from   DATE;
  x_date_to     DATE;
  x_sim_date_from DATE;
  x_sim_date_to DATE;
  x_group_id    NUMBER;
  x_phase       VARCHAR2(10);
  x_userid      NUMBER;
  x_appl_id     NUMBER;

  -- server time for the p_date_from and p_date_to
  s_time_from DATE;
  s_time_to   DATE;
Begin


   /************************************************
   * Check for the set of required parameters
   *     1. Line Id
   *     2. Line Op Id
   *     3. Date From
   *************************************************/

        x_phase := 'I';
   	If p_line_id is null then
		p_errnum := -1 ;
		p_errmesg := 'Failed in Line Resource Load Phase : '||x_phase||' Line Id is NULL' ;
		return ;
   	End if ;

   	If p_line_op_id is null then
		p_errnum := -1 ;
		p_errmesg := 'Failed in Line Resource Load Phase : '||x_phase||' Line Id is NULL' ;
		return ;
   	End if ;


   	If p_date_from is null then
		p_errnum := -1 ;
		p_errmesg := 'Failed in Line Resource Load Phase : '||x_phase||' Date From is NULL' ;
		return ;
   	End if ;


   /***********************************************
   * If the To Date is null, default the sysdate
   * to be the To Date
   ***********************************************/

        If p_date_to is null then
		x_date_to := trunc(wip_sfcb_utilities.sdate_to_cdate(sysdate)) ;
	ELSE
		x_date_to := p_date_to ;
   	End if ;



   /***********************************************
   * If the Group ID is null then we would generate
   * a new group id from the sequence
   ***********************************************/

   	IF p_group_id IS NULL THEN
		select wip_indicators_temp_s.nextval into x_group_id
		from sys.dual ;
	ELSE
		x_group_id := p_group_id ;
   	END IF;


	-- Defaulting the User Id, if it is not send in
        if p_userid is null then
                -- This is an Error Condition
                x_userid :=  fnd_global.user_id ;
        else
                x_userid := p_userid ;
        end if;

	-- Defaulting the Application Id, if it is not send in
        if p_applicationid is null then
                -- This is an Error Condition
                x_appl_id :=  fnd_global.prog_appl_id ;
        else
                x_appl_id := p_applicationid ;
        end if;

        g_userid := x_userid ;
        g_applicationid := x_appl_id ;




	x_phase := 'II';

	x_date_from := p_date_from ;
	x_date_to := p_date_to ;

        -- compute the corresponding server times before hand
        s_time_from := wip_sfcb_utilities.cdate_to_sdate(x_date_from);
        s_time_to   := wip_sfcb_utilities.cdate_to_sdate(x_date_to) + 1;

	-- Gets the Minimum Start Date and Maximum End Date to run
	-- the simulation for the line resource load.


	begin

          -- Bug 4890953
          -- Replacing view wip_open_flow_schedules_v
          -- With the view query to avoid redundant joins
          -- and improve performance.
/*
		select  min(scheduled_start_date), max(scheduled_completion_date)
		into	x_sim_date_from, x_sim_date_to
		from  	wip_open_flow_schedules_v
		where	line_id = p_line_id
		and	standard_operation_id = p_line_op_id
                -- for the sake of performance
                and
                (
                  ( scheduled_start_date >= s_time_from
                    and scheduled_start_date < s_time_to)
                  or
                  ( scheduled_completion_date >= s_time_from
                    and scheduled_completion_date >= s_time_to )
               );
*/

          SELECT
            min(wfs.scheduled_start_date),
            max(wfs.scheduled_completion_date)
          INTO
            x_sim_date_from,
            x_sim_date_to
          FROM
            wip_lines wl,
            bom_operation_sequences_v bos,
            bom_operational_routings bor,
            wip_flow_schedules wfs
          WHERE
            wfs.scheduled_flag = 1
            and bor.organization_id = wfs.organization_id
            and bor.assembly_item_id = wfs.primary_item_id
            and bor.line_id = wfs.line_id
            and bor.cfm_routing_flag = 1
            and decode(bor.alternate_routing_designator, null,'@@@@@@@',bor.alternate_routing_designator) =
              decode(wfs.alternate_routing_designator, null, '@@@@@@@', wfs.alternate_routing_designator)
            and bos.operation_type = 3 /* line operation */
            and bos.routing_sequence_id = bor.common_routing_sequence_id
            and wl.line_id = wfs.line_id
            and wl.organization_id = wfs.organization_id
            and wfs.status <> 2
            and WIP_SFCB_Utilities.line_op_is_pending (
                               BOS.operation_seq_num,
                               BOR.common_routing_sequence_id,
                               WFS.primary_item_id,
                               WFS.organization_id,
                               WFS.alternate_routing_designator,
                               WFS.current_line_operation
                             ) = 1
            and wfs.line_id = p_line_id
            and bos.standard_operation_id = p_line_op_id
            and
              (
                ( wfs.scheduled_start_date >= s_time_from
                  and wfs.scheduled_start_date < s_time_to)
                or
                ( wfs.scheduled_completion_date >= s_time_from
                  and wfs.scheduled_completion_date >= s_time_to )
              ) ;

            x_sim_date_from :=  trunc(wip_sfcb_utilities.sdate_to_cdate(x_sim_date_from));
            x_sim_date_to   :=  trunc(wip_sfcb_utilities.sdate_to_cdate(x_sim_date_to));

	exception
	  when others then
	--dbms_output.put_line('Exception in the simulation date calculation section');
		x_sim_date_from := x_date_from ;
		x_sim_date_to := x_date_to ;

	end ;


	x_phase := 'III';
	if g_debug = 1 then
		fnd_file.put_line(fnd_file.log, 'Before Stage  LRL Phase III');
	end if ;


	-- Calculate the resource availability and populate the
	-- information into MRP_NET_RESOURCE_AVAIL

       Wip_Prod_Indicators.Calculate_Resource_Avail(
		p_organization_id => p_organization_id,
              	p_date_from         => x_sim_date_from,
                p_date_to           => x_sim_date_to,
                p_department_id     => null,
                p_resource_id       => null,
                p_errnum            => p_errnum,
                p_errmesg           => p_errmesg
		) ;


	x_phase := 'IV';
	if g_debug = 1 then
		fnd_file.put_line(fnd_file.log, 'Before Stage  LRL Phase IV');
	end if ;

	-- Insert the required hours for each resource in the line operation
	-- This will insert a  unique row for each one of shift in each day
	-- for which the resource was loaded. The left over resource load
	-- will be equally allocated across each of these unique rows.

	insert into wip_indicators_temp (
		   group_id,
		   wip_entity_id,
		   organization_id,
		   resource_id,
		   resource_code,
		   department_id,
		   department_code,
		   transaction_date,
		   required_hours,
		   indicator_type,
		   process_phase,
		   last_update_date,
		   last_updated_by,
		   creation_date,
		   created_by,
		   program_application_id )
	select
		   x_group_id,
		   wofsv.wip_entity_id,
		   wofsv.organization_id,
		   bors.resource_id,
		   br.resource_code,
		   bos.department_id,
		   bd.department_code,
		   null,
		   decode(bors.basis_type,
		 	      1,
	  		      (NVL( bors.usage_rate_or_amount *
				  (wofsv.planned_quantity-wofsv.quantity_completed),0
				 )*
			      WIP_SFCB_UTILITIES.get_Workday_factor
	                       (trunc(wip_sfcb_utilities.sdate_to_cdate(wofsv.scheduled_start_date)),
	                        trunc(wip_sfcb_utilities.sdate_to_cdate(wofsv.scheduled_completion_date)),
	                        trunc(x_date_from),
	                        trunc(x_date_to),
				bors.resource_id,
				wofsv.organization_id)),
			      2,
	  		      DECODE(sign(trunc(wip_sfcb_utilities.sdate_to_cdate(wofsv.scheduled_completion_date)) -
					  x_date_to),
				     1,
				     0,
				     bors.usage_rate_or_amount
				    )
			   ),
		   WIP_LINE_RL, -- Indicator Type
		   WIP_LINE_RL_PHASE_ONE, -- process phase
		   sysdate,
		   g_userid,
		   sysdate,
		   g_userid,
		   g_applicationid
	from
		bom_departments bd,
		bom_resources br,
              	bom_operation_resources bors,
              	bom_operation_sequences bos2,    /* event seqs */
              	bom_operation_sequences bos,     /* line operations */
              	bom_operational_routings bor,
              	wip_open_flow_schedules_v wofsv
	where
              	wofsv.organization_id = p_organization_id
        and 	wofsv.line_id = p_line_id
	and	wofsv.standard_operation_id = p_line_op_id
 	and	( ( wofsv.scheduled_start_date >= s_time_from
                    and wofsv.scheduled_start_date < s_time_to)
		  or
                  ( wofsv.scheduled_completion_date >= s_time_from
                    and  wofsv.scheduled_completion_date < s_time_to)
		)
        and 	bor.organization_id = wofsv.organization_id
        and 	bor.assembly_item_id = wofsv.primary_item_id
        and 	bor.line_id = wofsv.line_id
        and 	nvl(bor.alternate_routing_designator,'@@@') =
                  nvl(wofsv.alternate_routing_designator,'@@@')
        and 	bos.operation_type = 3
        and 	bos.routing_sequence_id = bor.common_routing_sequence_id
        and 	bos.standard_operation_id = p_line_op_id
        and 	bos2.line_op_seq_id = bos.operation_sequence_id
        and 	bors.operation_sequence_id = bos2.operation_sequence_id
	and	br.resource_id = bors.resource_id
	and	bd.department_id = bos.department_id ;



	x_phase := 'V';
	if g_debug = 1 then
		fnd_file.put_line(fnd_file.log, 'Before Stage  LRL Phase V');
	end if ;


	-- Summarize the information inserted in the previous statement
	-- across the various days, as we do not have show the resource
	-- load by day, but we aggregate the information across the days
	-- for each resource.
	insert into wip_indicators_temp (
		   group_id,
		   organization_id,
		   resource_id,
		   resource_code,
		   department_id,
		   department_code,
		   transaction_date,
		   required_hours,
		   indicator_type,
		   process_phase,
		   last_update_date,
		   last_updated_by,
		   creation_date,
		   created_by,
		   program_application_id )
	select
		   wit.group_id,
		   wit.organization_id,
		   wit.resource_id,
		   wit.resource_code,
		   wit.department_id,
		   wit.department_code,
		   wit.transaction_date,
		   sum(wit.required_hours),
		   WIP_LINE_RL, -- Indicator Type
		   WIP_LINE_RL_PHASE_TWO, -- process phase
		   wit.last_update_date,
		   wit.last_updated_by,
		   wit.creation_date,
		   wit.created_by,
		   wit.program_application_id
	from
		wip_indicators_temp wit
	where
		wit.group_id = x_group_id
	and	wit.indicator_type = WIP_LINE_RL
	and 	wit.process_phase =  WIP_LINE_RL_PHASE_ONE
	group by
		   wit.group_id,
		   wit.organization_id,
		   wit.resource_id,
		   wit.resource_code,
		   wit.department_id,
		   wit.department_code,
		   wit.transaction_date,
		   WIP_LINE_RL, -- Indicator Type
		   WIP_LINE_RL_PHASE_TWO, -- process phase
		   wit.last_update_date,
		   wit.last_updated_by,
		   wit.creation_date,
		   wit.created_by,
		   wit.program_application_id ;



	x_phase := 'VI';
	if g_debug = 1 then
		fnd_file.put_line(fnd_file.log, 'Before Stage  LRL Phase VI');
	end if ;


	-- Delete the non-aggregated resource load information that
	-- was inserted with the process phase = 1.
	delete from wip_indicators_temp
	where 	group_id = x_group_id
	and	indicator_type = WIP_LINE_RL
	and	process_phase = WIP_LINE_RL_PHASE_ONE ;



	x_phase := 'VII';
	if g_debug = 1 then
		fnd_file.put_line(fnd_file.log, 'Before Stage  LRL Phase VII');
	end if ;


	-- Update the gross availaibility for
	-- the various resources in the line operation
	-- across the various days that falls in the range that
	-- are specified as the parameters.
    	UPDATE wip_indicators_temp wit
    	SET    wit.available_units = (
			select
				nvl(sum(((mnra.to_time-mnra.from_time)/3600)*mnra.capacity_units),0)
			from
				mrp_net_resource_avail mnra
			where
				mnra.organization_id = wit.organization_id
			and	mnra.resource_id = wit.resource_id
			and	mnra.department_id = wit.department_id
			and     trunc(mnra.shift_date) between x_date_from and x_date_to
			and     simulation_set is null
		   )
    	where wit.group_id = x_group_id
	and wit.indicator_type = WIP_LINE_RL
    	and process_phase = WIP_LINE_RL_PHASE_TWO ;



  Exception

	When others then

		p_errnum := -1 ;
		p_errmesg := 'Failed in Line RL Phase : '||x_phase|| substr(SQLERRM,1,125);
		return ;

End Populate_Line_Resource_Load ;


function get_Workday_factor
                       (p_sched_start_date      IN  DATE,
                        p_sched_completion_date IN  DATE,
                        p_date_from             IN  DATE,
                        p_date_to               IN  DATE,
			p_resource_id		IN  NUMBER,
			p_organization_id	IN  NUMBER )
return NUMBER IS
   x_total_days NUMBER ;
   x_sched_days NUMBER;
   x_workday_factor NUMBER;
BEGIN


 /******************************************************************

    The design can be thought of as shown below :

	   p_date_from			   p_date_to
		|------------------------------|
			 (1)
	             |----------|
		 sch_start   sch_end
		(2)				  (3)
	  |-------------|                |--------------------|
      sch_start      sch_end	      sch_start		   sch_end
				(4)
          |--------------------------------------------|
       sch_start				    sch_end


     The Workday Factor for the various cases should be :

	1. In this case it should be the fraction returned should
	   be 1, so that we get the whole range.

	2. In this case, the fraction returned should still be 1,
	   eventhough the scheduled_start_date is less than the
	   p_date_from, because the completed quantities are handled
	   by the quantity_completed column in the wip_flow_schedules

	3. For this case, the fraction returned is actually =

		Number of calendar working days for the resource
		between sch_start and p_date_to
	     ------------------------------------------------------
		Number of calendar working days for the resource
		between sch_start and sch_end

        4. For this case, the fraction returned is actually =

                Number of calendar working days for the resource
                between p_date_from and p_date_to
             ------------------------------------------------------
                Number of calendar working days for the resource
                between p_date_from and sch_end

	    As the fraction of the schedule before the p_date_from
	    is actually handled by quantity_completed column in the
	    wip_flow_schedules


     *********************************************************************/


   if (p_sched_start_date >= p_date_from) and  (p_sched_completion_date <= p_date_to) then

	x_workday_factor := 1 ;

   elsif (p_sched_start_date <= p_date_from) and (p_sched_completion_date <= p_date_to) then

        x_workday_factor := 1 ;

   elsif (p_sched_start_date >= p_date_from ) and (p_sched_completion_date >= p_date_to) then

	begin

		select
			nvl(count(distinct shift_date),0)
		into
			x_sched_days
        	from
			mrp_net_resource_avail
        	where resource_id = p_resource_id
        	and   organization_id = p_organization_id
        	and   simulation_set is null
		and   shift_date between p_sched_start_date and p_date_to ;

	exception
	   when others then
		x_sched_days := 0 ;

	end ;

        begin

                select
                        nvl(count(distinct shift_date),0)
                into
                        x_total_days
                from
                        mrp_net_resource_avail
                where resource_id = p_resource_id
                and   organization_id = p_organization_id
                and   simulation_set is null
                and   shift_date between p_sched_start_date and p_sched_completion_date ;

        exception
           when others then
                x_total_days := 0 ;

        end ;


	x_workday_factor := x_sched_days/x_total_days ;


  elsif (p_sched_start_date < p_date_from ) and (p_sched_completion_date > p_date_to) then

        begin

                select
                        nvl(count(distinct shift_date),0)
                into
                        x_sched_days
                from
                        mrp_net_resource_avail
                where resource_id = p_resource_id
                and   organization_id = p_organization_id
                and   simulation_set is null
                and   shift_date between p_date_from and p_date_to ;

        exception
           when others then
                x_sched_days := 0 ;

        end ;

        begin

                select
                        nvl(count(distinct shift_date),0)
                into
                        x_total_days
                from
                        mrp_net_resource_avail
                where resource_id = p_resource_id
                and   organization_id = p_organization_id
                and   simulation_set is null
                and   shift_date between p_date_from and p_sched_completion_date ;

        exception
           when others then
                x_total_days := 0 ;

        end ;


        x_workday_factor := x_sched_days/x_total_days ;

   end if ;



   return x_workday_factor ;


    exception

	when others then
	   return 1 ;

End Get_Workday_Factor ;


FUNCTION get_all_line_ops (
				  p_rtg_sequence_id	IN 	NUMBER,
                                  p_assy_item_id      IN  NUMBER,
                                  p_org_id            IN  NUMBER,
                                  p_alt_rtg_desig     IN  VARCHAR2 )
RETURN VARCHAR2 IS
     ops_table bom_rtg_network_api.op_tbl_type ;
     i BINARY_INTEGER ;
     opcode VARCHAR2(4);

     lineops VARCHAR2(30000);
BEGIN

   bom_rtg_network_api.get_all_line_ops(
					p_rtg_sequence_id => p_rtg_sequence_id,
					p_assy_item_id => p_assy_item_id,
					p_org_id => p_org_id,
					p_alt_rtg_desig => p_alt_rtg_desig,
					x_op_tbl => ops_table );


   IF (ops_table.COUNT > 0) then

      FOR i IN ops_table.first..ops_table.last LOOP

        select bso.operation_code into opcode
        from bom_standard_operations bso, bom_operation_sequences bos
        where bso.organization_id = p_org_id
          and bso.standard_operation_id = bos.standard_operation_id
          and bos.operation_sequence_id = ops_table(i).operation_sequence_id;

        lineops := lineops || ops_table(i).operation_seq_num || ' ' ||
                   opcode;

	IF (i <> ops_table.last) THEN
	   lineops := lineops || ',' ;
	END IF;

      END LOOP;

   END IF;


   RETURN lineops;

END get_all_line_ops;


---------------------------------------------------------------------
FUNCTION check_last_line_op (
			       p_rtg_sequence_id   IN  NUMBER,
			       p_assy_item_id      IN  NUMBER,
			       p_org_id            IN  NUMBER,
			       p_alt_rtg_desig     IN  VARCHAR2,
			       p_curr_line_op      IN  NUMBER )
RETURN NUMBER IS

   islast NUMBER;
   bislast BOOLEAN;

BEGIN

   bislast := bom_rtg_network_api.check_last_line_op (
					   p_rtg_sequence_id,
					   p_assy_item_id,
					   p_org_id,
					   p_alt_rtg_desig,
					   p_curr_line_op );

   IF (bislast = TRUE) THEN
      islast := 1;
   ELSE
      islast := 2;
   END IF;

   RETURN islast;

END check_last_line_op ;

 ----------------------------------------------------------
 /* added for oracle timezone support in the workstation */

 /* date only string to datetime string, assuming time component is 00:00:00 */
  function displaydate_to_displayDT(p_displaydate IN VARCHAR2) return VARCHAR2
  IS
  BEGIN
    return to_char(to_date(p_displaydate, fnd_date.output_mask), fnd_date.outputdt_mask);
  EXCEPTION WHEN OTHERS THEN
    return null;
  END;

  /* take a client date only string and convert it to sever time, assuming time is 0 */
  function displaydate_to_date_tz(p_displaydate IN VARCHAR2) return DATE
  IS
  BEGIN
    return fnd_date.displaydt_to_date(displaydate_to_displayDT(p_displaydate ));
  EXCEPTION WHEN OTHERS THEN
    return null;
  END;

 /* same as fnd_daet.displaydt_to_date, but caches exception so it
    can be used to validate the format too */
  function displaydt_to_date_tz(p_displaydt IN VARCHAR2) return DATE
  IS
  BEGIN
    return fnd_date.displaydt_to_date(p_displaydt);
  EXCEPTION WHEN OTHERS THEN
    return null;
  END;

 /* given a server datetime, convert it to client time zone, and then
    return the date only part of the string, this is useful for
    bucketing the data according to client date */
 function date_to_displaydate_tz(p_date IN DATE) return VARCHAR2
 IS
   tmp VARCHAR2(255);
   ret VARCHAR2(255);
 BEGIN
    tmp := fnd_date.outputdt_mask;
    -- using date only mask to to the converstion
    fnd_date.outputdt_mask := fnd_date.output_mask;
    ret := fnd_date.date_to_displaydt(p_date);
    fnd_date.outputdt_mask := tmp;

    return ret;
 END;

 /* given a server datetime, convert it to client time zone and return it.
  * the return value contains the time portion */
 function date_to_displaydt_tz(p_date IN DATE) return VARCHAR2
 IS
 BEGIN
   return fnd_date.date_to_displayDT(p_date);
 EXCEPTION WHEN OTHERS THEN
   return null;
 END;


 /* for validating the display date */
 function is_validate_displaydate(p_date IN VARCHAR2) return VARCHAR2
 IS
   t_date DATE;
   ret VARCHAR2(4) := FND_API.G_TRUE;
 BEGIN
   BEGIN
     select to_date(p_date, fnd_date.output_mask)
     into t_date
     from dual;
   EXCEPTION WHEN OTHERS THEN
     ret := FND_API.G_FALSE;
   END;
   return ret;
 END;

 /* for validating display datetime */
 function is_validate_displayDT(p_date IN VARCHAR2) return VARCHAR2
 IS
   t_date DATE;
   ret VARCHAR2(4) := FND_API.G_TRUE;
 BEGIN
   BEGIN
     select to_date(p_date, fnd_date.outputdt_mask)
     into t_date
     from dual;
   EXCEPTION WHEN OTHERS THEN
     ret := FND_API.G_FALSE;
   END;
   return ret;
 END;

 /* convert server date to client date, by faking it. */
 function sdate_to_cdate(p_sdate IN DATE) return DATE
 IS
 BEGIN
   return to_date(fnd_date.date_to_displaydt(p_sdate), fnd_date.outputdt_mask);
 END;

 /* convert a client date back to server date.  use it carefully */
 function cdate_to_sdate(p_cdate IN DATE) return DATE
 IS
 BEGIN
   return fnd_date.displaydt_to_date( to_char(p_cdate, fnd_date.outputdt_mask) );
 END;


 /* returns the number of hours between the given datetimes */
 function calculate_dt_range(p_from_dt IN VARCHAR2,
                              p_to_dt IN VARCHAR2) return VARCHAR2
 IS
   diff NUMBER;  --difference in dt's, in days
 BEGIN
   BEGIN
     select to_date(p_to_dt,fnd_date.outputdt_mask) - to_date(p_from_dt,fnd_date.outputdt_mask)
     into diff
     from dual;
   EXCEPTION WHEN OTHERS THEN
     return FND_API.G_RET_STS_ERROR;
   END;
   return to_char(diff * 24);  -- return in hours
 END;


 /* intialize time zone variables for workstation, TCF or fnd_global.initialize
   is supposed to initialize these because it makes more sense. However,
   they are not going to make the changes very soon so we have to do it ourselves. */

/* These code explicitly depends on fnd timezone patch. As a result, it cannot be
   comiled in an evnrionment that the fnd timezone patch has not been applied.
   This is a problem since we want the code to work whether timezone patch is applied
   or not.

   So this procedure ends up not being used. Instead, the sql has been moved to java side,
   where sql is dynanmic. Though it will throw an exception if timezone patch is not there,
   but the exception can be catched and ignored.
*/
 procedure init_timezone(p_output_mask IN VARCHAR2, p_outputdt_mask IN VARCHAR2)
 IS
 BEGIN
   fnd_date.initialize(p_output_mask, p_outputdt_mask);

--  comment out the code because it depends on the fnd timezone patch.
/*
   fnd_date.client_timezone_code := fnd_timezones.get_code( fnd_profile.value('CLIENT_TIMEZONE_ID'));
   fnd_date.server_timezone_code := fnd_timezones.get_code( fnd_profile.value('SERVER_TIMEZONE_ID'));

   if( fnd_timezones.timezones_enabled = 'Y') then
     fnd_date.timezones_enabled := true;
   else
     fnd_date.timezones_enabled := false;
   end if;
*/

 END;


  procedure check_attachment_and_contract(p_pkey1 in VARCHAR2,
                                          p_pkey2 in VARCHAR2,
                                          p_pkey3 in VARCHAR2,
                                          p_jobID in number,
                                          x_hasAttachement out nocopy VARCHAR2,
                                          x_hasContract    out nocopy VARCHAR2) is
    l_result boolean;
    l_status varchar2(1);
    l_industry varchar2(1);
    l_num number := null;
  begin
    x_hasAttachement := 'N';
    x_hasContract := 'N';

    x_hasAttachement := fnd_attachment_util_pkg.get_atchmt_exists(
                             l_entity_name => 'WIP_DISCRETE_OPERATIONS',
                             l_pkey1 => p_pkey1,
                             l_pkey2 => p_pkey2,
                             l_pkey3 => p_pkey3,
                             l_pkey4 => NULL,
                             l_pkey5 => NULL,
                             l_function_name => 'WIP_WIPOPMDF',
                             l_function_type => 'F');

    l_result := fnd_installation.get(777, 777, l_status, l_industry);

    if ( l_status <> 'I' ) then
      return;
    end if;

    begin
      select count(*) into l_num
        from wip_discrete_jobs wdj,
             oke_k_deliverables_b okd,
             (select k_header_id,
                     oke_k_security_pkg.get_k_access(k_header_id) acc
              from oke_k_deliverables_b) okh
       where wdj.wip_entity_id = p_jobID
         and okd.project_id  = wdj.project_id
         and nvl(okd.task_id, -1) = nvl(wdj.task_id, -1)
         and okh.k_header_id = okd.k_header_id
         and okh.acc <> 'NONE';
    exception
      when others then
        return;
    end;

     if ( l_num > 0 ) then
       x_hasContract := 'Y';
     end if;

  end check_attachment_and_contract;


END WIP_SFCB_UTILITIES;

/
