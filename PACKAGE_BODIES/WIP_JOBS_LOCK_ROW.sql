--------------------------------------------------------
--  DDL for Package Body WIP_JOBS_LOCK_ROW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_JOBS_LOCK_ROW" as
/* $Header: wipdjlrb.pls 115.24 2002/12/12 16:57:59 rmahidha ship $ */

PROCEDURE Lock_Row
(X_Row_Id VARCHAR2,
X_wip_entity_id NUMBER,
X_organization_id               NUMBER,
X_last_update_date              DATE,
X_last_updated_by               NUMBER,
X_creation_date                 DATE,
X_created_by                    NUMBER,
X_last_update_login             NUMBER,
X_description                   VARCHAR2,
X_status_type                   NUMBER,
X_primary_item_id               NUMBER,
X_firm_planned_flag             NUMBER,
X_job_type                      NUMBER,
X_wip_supply_type               NUMBER,
X_class_code                    VARCHAR2,
X_material_account              NUMBER,
X_material_overhead_account     NUMBER,
X_resource_account              NUMBER,
X_outside_processing_account    NUMBER,
X_material_variance_account     NUMBER,
X_resource_variance_account     NUMBER,
X_outside_proc_var_account      NUMBER,
X_std_cost_adjustment_account   NUMBER,
X_overhead_account              NUMBER,
X_overhead_variance_account     NUMBER,
X_scheduled_start_date          DATE,
X_date_released                 DATE,
X_scheduled_completion_date     DATE,
X_date_completed                DATE,
X_date_closed                   DATE,
X_start_quantity                NUMBER,
X_overcompletion_toleran_type	NUMBER,
X_overcompletion_toleran_value	NUMBER,
X_quantity_completed            NUMBER,
X_quantity_scrapped             NUMBER,
X_net_quantity                  NUMBER,
X_bom_reference_id              NUMBER,
X_routing_reference_id          NUMBER,
X_common_bom_sequence_id        NUMBER,
X_common_routing_sequence_id    NUMBER,
X_bom_revision                  VARCHAR2,
X_routing_revision              VARCHAR2,
X_bom_revision_date             DATE,
X_routing_revision_date         DATE,
X_lot_number                    VARCHAR2,
X_alternate_bom_designator      VARCHAR2,
X_alternate_routing_designator  VARCHAR2,
X_completion_subinventory       VARCHAR2,
X_completion_locator_id         NUMBER,
X_demand_class                  VARCHAR2,
X_attribute_category            VARCHAR2,
X_attribute1                    VARCHAR2,
X_attribute2                    VARCHAR2,
X_attribute3                    VARCHAR2,
X_attribute4                    VARCHAR2,
X_attribute5                    VARCHAR2,
X_attribute6                    VARCHAR2,
X_attribute7                    VARCHAR2,
X_attribute8                    VARCHAR2,
X_attribute9                    VARCHAR2,
X_attribute10                   VARCHAR2,
X_attribute11                   VARCHAR2,
X_attribute12                   VARCHAR2,
X_attribute13                   VARCHAR2,
X_attribute14                   VARCHAR2,
X_attribute15                   VARCHAR2,
X_end_item_unit_number		VARCHAR2,
X_Schedule_Group_Id		NUMBER,
X_Build_Sequence		NUMBER,
X_Line_Id			NUMBER,
X_Project_Id			NUMBER,
X_Task_Id			NUMBER,
X_priority                      NUMBER,
X_due_date                      DATE,
X_due_date_penalty		NUMBER,
X_due_date_tolerance		NUMBER,
X_requested_start_date          DATE,
x_serialization_start_op        NUMBER := null)
/*X_Project_Costed		NUMBER)*/
 IS
CURSOR C IS
	SELECT wip_entity_id, organization_id, description,
		status_type, primary_item_id, firm_planned_flag, job_type,
		wip_supply_type, class_code, material_account, material_overhead_account
	   	,resource_account ,outside_processing_account ,material_variance_account
	   	,resource_variance_account ,outside_proc_variance_account ,std_cost_adjustment_account
	   	,overhead_account ,overhead_variance_account ,scheduled_start_date
	   	,date_released ,scheduled_completion_date ,date_completed
	   	,date_closed ,start_quantity ,overcompletion_tolerance_type
		,overcompletion_tolerance_value,quantity_completed
	   	,quantity_scrapped ,net_quantity , bom_reference_id
		,routing_reference_id ,common_bom_sequence_id ,common_routing_sequence_id
		,bom_revision ,routing_revision ,bom_revision_date
		,routing_revision_date ,lot_number ,alternate_bom_designator
		,alternate_routing_designator ,completion_subinventory ,completion_locator_id
		,demand_class ,attribute_category ,attribute1 ,attribute2 ,attribute3
		,attribute4 ,attribute5 ,attribute6 ,attribute7 ,attribute8
		,attribute9 ,attribute10 ,attribute11 ,attribute12 ,attribute13
	  	,attribute14 ,attribute15, end_item_unit_number, schedule_group_id, build_sequence, line_id
		,project_id, task_id, priority, due_date
		,due_date_penalty, due_date_tolerance, requested_start_date, serialization_start_op /*project_costed*/
	FROM   WIP_DISCRETE_JOBS
	WHERE  rowid = X_Row_id
	FOR UPDATE of Wip_Entity_Id NOWAIT;
Recinfo C%ROWTYPE;

BEGIN
	OPEN C;
	FETCH C INTO Recinfo;
	if (C%NOTFOUND) then
		CLOSE C;
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.Raise_Exception;
	end if;
	CLOSE C;
	if (
		(Recinfo.wip_entity_id =  X_Wip_Entity_Id)
	   AND (Recinfo.organization_id =  X_Organization_Id)
	   AND (   (Recinfo.description =  X_Description)
		OR (	(Recinfo.description IS NULL)
			AND (X_Description IS NULL)))
	   AND (Recinfo.status_type =  X_Status_Type)
	   AND (   (Recinfo.primary_item_id =  X_Primary_Item_Id)
		OR (	(Recinfo.primary_item_id IS NULL)
			AND (X_Primary_Item_Id IS NULL)))
	   AND (Recinfo.firm_planned_flag =  X_Firm_Planned_Flag)
	   AND (Recinfo.job_type =  X_Job_Type)
	   AND (Recinfo.wip_supply_type =  X_Wip_Supply_Type)
	   AND (Recinfo.class_code =  X_Class_Code)
	   AND (   (Recinfo.material_account =  X_Material_Account)
		OR (	(Recinfo.material_account IS NULL)
			AND (X_Material_Account IS NULL)))
	   AND (   (Recinfo.material_overhead_account =  X_Material_Overhead_Account)
		OR (	(Recinfo.material_overhead_account IS NULL)
			AND (X_Material_Overhead_Account IS NULL)))
	   AND (   (Recinfo.resource_account =  X_Resource_Account)
		OR (	(Recinfo.resource_account IS NULL)
			AND (X_Resource_Account IS NULL)))
	   AND (   (Recinfo.outside_processing_account =  X_Outside_Processing_Account)
		OR (	(Recinfo.outside_processing_account IS NULL)
			AND (X_Outside_Processing_Account IS NULL)))
	   AND (   (Recinfo.material_variance_account =  X_Material_Variance_Account)
		OR (	(Recinfo.material_variance_account IS NULL)
			AND (X_Material_Variance_Account IS NULL)))
	   AND (   (Recinfo.resource_variance_account =  X_Resource_Variance_Account)
		OR (	(Recinfo.resource_variance_account IS NULL)
			AND (X_Resource_Variance_Account IS NULL)))
	   AND (   (Recinfo.outside_proc_variance_account =  X_Outside_Proc_Var_Account)
		OR (	(Recinfo.outside_proc_variance_account IS NULL)
			AND (X_Outside_Proc_Var_Account IS NULL)))
	   AND (   (Recinfo.std_cost_adjustment_account =  X_Std_Cost_Adjustment_Account)
		OR (	(Recinfo.std_cost_adjustment_account IS NULL)
			AND (X_Std_Cost_Adjustment_Account IS NULL)))
	   AND (   (Recinfo.overhead_account =  X_Overhead_Account)
		OR (	(Recinfo.overhead_account IS NULL)
			AND (X_Overhead_Account IS NULL)))
	   AND (   (Recinfo.overhead_variance_account =  X_Overhead_Variance_Account)
		OR (	(Recinfo.overhead_variance_account IS NULL)
			AND (X_Overhead_Variance_Account IS NULL)))
	   AND (Recinfo.scheduled_start_date =  X_Scheduled_Start_Date)
	   AND (  (to_char(Recinfo.date_released, 'DD-MON-YYYY') =  to_char(X_Date_Released, 'DD-MON-YYYY'))
		OR (	(Recinfo.date_released IS NULL)
			AND (X_Date_Released IS NULL)))
	   AND (Recinfo.scheduled_completion_date =  X_Scheduled_Completion_Date)
	   AND (  (to_char(Recinfo.date_completed, 'DD-MON-YYYY') =  to_char(X_Date_Completed, 'DD-MON-YYYY'))
		OR (	(Recinfo.date_completed IS NULL)
			AND (X_Date_Completed IS NULL)))
	   AND (  (to_char(Recinfo.date_closed, 'DD-MON-YYYY') =  to_char(X_Date_Closed, 'DD-MON-YYYY'))
		OR (	(Recinfo.date_closed IS NULL)
			AND (X_Date_Closed IS NULL)))
	   AND (Recinfo.start_quantity =  X_Start_Quantity)
	   AND (   (Recinfo.overcompletion_tolerance_type =  X_Overcompletion_Toleran_Type)
		OR (	(Recinfo.overcompletion_tolerance_type IS NULL)
			AND (X_Overcompletion_Toleran_Type IS NULL)))
	   AND (   (Recinfo.overcompletion_tolerance_value =  X_Overcompletion_Toleran_Value)
		OR (	(Recinfo.overcompletion_tolerance_value IS NULL)
			AND (X_Overcompletion_Toleran_Value IS NULL)))
	   AND (Recinfo.quantity_completed =  NVL(X_Quantity_Completed,0))
	   AND (Recinfo.quantity_scrapped =  NVL(X_Quantity_Scrapped,0))
	   AND (Recinfo.net_quantity =  X_Net_Quantity)
) then if (
		(   (Recinfo.bom_reference_id =  X_Bom_Reference_Id)
		OR (	(Recinfo.bom_reference_id IS NULL)
			AND (X_Bom_Reference_Id IS NULL)))
	   AND (   (Recinfo.routing_reference_id =  X_Routing_Reference_Id)
		OR (	(Recinfo.routing_reference_id IS NULL)
			AND (X_Routing_Reference_Id IS NULL)))
	   AND (   (Recinfo.common_bom_sequence_id =  X_Common_Bom_Sequence_Id)
		OR (	(Recinfo.common_bom_sequence_id IS NULL)
			AND (X_Common_Bom_Sequence_Id IS NULL)))
	   AND (   (Recinfo.common_routing_sequence_id =  X_Common_Routing_Sequence_Id)
		OR (	(Recinfo.common_routing_sequence_id IS NULL)
			AND (X_Common_Routing_Sequence_Id IS NULL)))
	   AND (   (Recinfo.bom_revision =  X_Bom_Revision)
		OR (	(Recinfo.bom_revision IS NULL)
			AND (X_Bom_Revision IS NULL)))
	   AND (   (Recinfo.routing_revision =  X_Routing_Revision)
		OR (	(Recinfo.routing_revision IS NULL)
			AND (X_Routing_Revision IS NULL)))
	   AND (   (Recinfo.bom_revision_date =  X_Bom_Revision_Date)
		OR (	(Recinfo.bom_revision_date IS NULL)
			AND (X_Bom_Revision_Date IS NULL)))
	   AND (   (Recinfo.routing_revision_date =  X_Routing_Revision_Date)
		OR (	(Recinfo.routing_revision_date IS NULL)
			AND (X_Routing_Revision_Date IS NULL)))
	   AND (   (Recinfo.lot_number =  X_Lot_Number)
		OR (	(Recinfo.lot_number IS NULL)
			AND (X_Lot_Number IS NULL)))
	   AND (   (Recinfo.alternate_bom_designator =  X_Alternate_Bom_Designator)
		OR (	(Recinfo.alternate_bom_designator IS NULL)
			AND (X_Alternate_Bom_Designator IS NULL)))
	   AND (   (Recinfo.alternate_routing_designator =  X_Alternate_Routing_Designator)
		OR (	(Recinfo.alternate_routing_designator IS NULL)
			AND (X_Alternate_Routing_Designator IS NULL)))
	   AND (   (Recinfo.completion_subinventory =  X_Completion_Subinventory)
		OR (	(Recinfo.completion_subinventory IS NULL)
			AND (X_Completion_Subinventory IS NULL)))
	   AND (   (Recinfo.completion_locator_id =  X_Completion_Locator_Id)
		OR (	(Recinfo.completion_locator_id IS NULL)
			AND (X_Completion_Locator_Id IS NULL)))
	   AND (   (Recinfo.demand_class =  X_Demand_Class)
		OR (	(Recinfo.demand_class IS NULL)
			AND (X_Demand_Class IS NULL)))
	   AND (   (Recinfo.attribute_category =  X_Attribute_Category)
		OR (	(Recinfo.attribute_category IS NULL)
			AND (X_Attribute_Category IS NULL)))
	   AND (   (Recinfo.attribute1 =  X_Attribute1)
		OR (	(Recinfo.attribute1 IS NULL)
			AND (X_Attribute1 IS NULL)))
	   AND (   (Recinfo.attribute2 =  X_Attribute2)
		OR (	(Recinfo.attribute2 IS NULL)
			AND (X_Attribute2 IS NULL)))
	   AND (   (Recinfo.attribute3 =  X_Attribute3)
		OR (	(Recinfo.attribute3 IS NULL)
			AND (X_Attribute3 IS NULL)))
	   AND (   (Recinfo.attribute4 =  X_Attribute4)
		OR (	(Recinfo.attribute4 IS NULL)
			AND (X_Attribute4 IS NULL)))
	   AND (   (Recinfo.attribute5 =  X_Attribute5)
		OR (	(Recinfo.attribute5 IS NULL)
			AND (X_Attribute5 IS NULL)))
	   AND (   (Recinfo.attribute6 =  X_Attribute6)
		OR (	(Recinfo.attribute6 IS NULL)
			AND (X_Attribute6 IS NULL)))
	   AND (   (Recinfo.attribute7 =  X_Attribute7)
		OR (	(Recinfo.attribute7 IS NULL)
			AND (X_Attribute7 IS NULL)))
	   AND (   (Recinfo.attribute8 =  X_Attribute8)
		OR (	(Recinfo.attribute8 IS NULL)
			AND (X_Attribute8 IS NULL)))
	   AND (   (Recinfo.attribute9 =  X_Attribute9)
		OR (	(Recinfo.attribute9 IS NULL)
			AND (X_Attribute9 IS NULL)))
	   AND (   (Recinfo.attribute10 =  X_Attribute10)
		OR (	(Recinfo.attribute10 IS NULL)
			AND (X_Attribute10 IS NULL)))
	   AND (   (Recinfo.attribute11 =  X_Attribute11)
		OR (	(Recinfo.attribute11 IS NULL)
			AND (X_Attribute11 IS NULL)))
	   AND (   (Recinfo.attribute12 =  X_Attribute12)
		OR (	(Recinfo.attribute12 IS NULL)
			AND (X_Attribute12 IS NULL)))
	   AND (   (Recinfo.attribute13 =  X_Attribute13)
		OR (	(Recinfo.attribute13 IS NULL)
			AND (X_Attribute13 IS NULL)))
	   AND (   (Recinfo.attribute14 =  X_Attribute14)
		OR (	(Recinfo.attribute14 IS NULL)
			AND (X_Attribute14 IS NULL)))
	   AND (   (Recinfo.attribute15 =  X_Attribute15)
		OR (	(Recinfo.attribute15 IS NULL)
			AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.end_item_unit_number =  X_end_item_unit_number)
                OR (    (Recinfo.end_item_unit_number IS NULL)
                        AND (X_end_item_unit_number IS NULL)))
	   AND (   (Recinfo.schedule_group_id =  X_Schedule_Group_Id)
		OR (	(Recinfo.schedule_group_id IS NULL)
			AND (X_schedule_group_id IS NULL)))
	   AND (   (Recinfo.build_sequence =  X_build_sequence)
		OR (	(Recinfo.build_sequence IS NULL)
			AND (X_Build_Sequence IS NULL)))
	   AND (   (Recinfo.line_id =  X_line_id)
		OR (	(Recinfo.line_id IS NULL)
			AND (X_line_id IS NULL)))
	   AND (   (Recinfo.Project_Id =  X_Project_Id)
		OR (	(Recinfo.Project_id IS NULL)
			AND (X_project_id IS NULL)))
	   AND (   (Recinfo.Task_Id =  X_task_Id)
		OR (	(Recinfo.Task_id IS NULL)
			AND (X_task_id IS NULL)))
	   AND (   (Recinfo.priority =  X_priority)
		OR (	(Recinfo.priority IS NULL)
			AND (X_priority IS NULL)))
	   AND (   (Recinfo.due_date =  X_due_date)
		OR (	(Recinfo.due_date IS NULL)
			AND (X_due_date IS NULL)))
	   AND (   (Recinfo.due_date_penalty =  X_due_date_penalty)
		OR (	(Recinfo.due_date_penalty IS NULL)
			AND (X_due_date_penalty IS NULL)))
	   AND (   (Recinfo.due_date_tolerance =  X_due_date_tolerance)
		OR (	(Recinfo.due_date_tolerance IS NULL)
			AND (X_due_date_tolerance IS NULL)))
	   AND (   (Recinfo.requested_start_date =  X_requested_start_date)
                OR (    (Recinfo.requested_start_date IS NULL)
                        AND (X_requested_start_date IS NULL)))
           AND (   (Recinfo.serialization_start_op = X_serialization_start_op)
                OR (    (Recinfo.serialization_start_op IS NULL)
                        AND (X_serialization_start_op IS NULL)))
	  /* AND (   (Recinfo.Project_costed =  X_Project_Costed)
		OR (	(Recinfo.Project_costed IS NULL)
			AND (X_project_costed IS NULL)))*/
	  ) then
	  return;
	else
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	end if;
	else
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	end if;
END Lock_Row;

END WIP_JOBS_LOCK_ROW;

/
