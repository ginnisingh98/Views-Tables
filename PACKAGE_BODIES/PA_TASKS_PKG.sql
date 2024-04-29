--------------------------------------------------------
--  DDL for Package Body PA_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASKS_PKG" as
/* $Header: PAXTASKB.pls 120.4 2006/05/03 04:20:33 sunkalya noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Task_Id                        IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Project_Id                     NUMBER,
                       X_Task_Number                    VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Task_Name                      VARCHAR2,
-- Long Task Name change by xxlu
                       X_Long_Task_Name                 VARCHAR2,
                       X_Top_Task_Id                    NUMBER,
                       X_Wbs_Level                      NUMBER,
                       X_Ready_To_Bill_Flag             VARCHAR2,
                       X_Ready_To_Distribute_Flag       VARCHAR2,
                       X_Parent_Task_Id                 NUMBER,
                       X_Description                    VARCHAR2,
                       X_Carrying_Out_Organization_Id   NUMBER,
                       X_Service_Type_Code              VARCHAR2,
                       X_Task_Manager_Person_Id         NUMBER,
                       X_Chargeable_Flag                VARCHAR2,
                       X_Billable_Flag                  VARCHAR2,
                       X_Limit_To_Txn_Controls_Flag     VARCHAR2,
                       X_Start_Date                     DATE,
                       X_Completion_Date                DATE,
                       X_Address_Id                     NUMBER,
                       X_Labor_Bill_Rate_Org_Id         NUMBER,
                       X_Labor_Std_Bill_Rate_Schdl      VARCHAR2,
                       X_Labor_Schedule_Fixed_Date      DATE,
                       X_Labor_Schedule_Discount        NUMBER,
                       X_Non_Labor_Bill_Rate_Org_Id     NUMBER,
                       X_NL_Std_Bill_Rate_Schdl         VARCHAR2,
                       X_NL_Schedule_Fixed_Date         DATE,
                       X_Non_Labor_Schedule_Discount    NUMBER,
                       X_Labor_Cost_Multiplier_Name     VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Cost_Ind_Rate_Sch_Id           NUMBER,
                       X_Rev_Ind_Rate_Sch_Id            NUMBER,
                       X_Inv_Ind_Rate_Sch_Id            NUMBER,
                       X_Cost_Ind_Sch_Fixed_Date        DATE,
                       X_Rev_Ind_Sch_Fixed_Date         DATE,
                       X_Inv_Ind_Sch_Fixed_Date         DATE,
                       X_Labor_Sch_Type                 VARCHAR2,
                       X_Non_Labor_Sch_Type             VARCHAR2,
                       X_Allow_Cross_Charge_Flag        VARCHAR2,
                       X_Project_Rate_Date              DATE,
                       X_Project_Rate_Type              VARCHAR2,
                       X_CC_Process_Labor_Flag          VARCHAR2,
                       X_Labor_Tp_Schedule_Id           NUMBER,
                       X_Labor_Tp_Fixed_Date            DATE,
                       X_CC_Process_NL_Flag             VARCHAR2,
                       X_Nl_Tp_Schedule_Id              NUMBER,
                       X_Nl_Tp_Fixed_Date               DATE,
                       X_receive_project_invoice_flag   VARCHAR2,
                       X_work_type_id                   NUMBER,
-- 21-MAR-2001 anlee
-- added job_bill_rate_schedule_id,
-- emp_bill_rate_schedule_id for
-- PRM forecasting changes
                       X_job_bill_rate_schedule_id      NUMBER,
                       X_emp_bill_rate_schedule_id      NUMBER,
--MCA Sakthi for MultiAgreementCurreny Project
                       X_taskfunc_cost_rate_type        VARCHAR2,
                       X_taskfunc_cost_rate_date        DATE,
                       X_non_lab_std_bill_rt_sch_id     NUMBER,
--MCA Sakthi for MultiAgreementCurreny Project
-- FP.K Setup changes by msundare
                       X_labor_disc_reason_code         VARCHAR2,
                       X_non_labor_disc_reason_code     VARCHAR2,
--PA L Dev
                       x_retirement_cost_flag           VARCHAR2,
                       x_cint_eligible_flag             VARCHAR2,
                       x_cint_stop_date                 DATE,
/*Added for FPM Changes */
                       x_customer_id                    Number  default NULL,
                       x_revenue_accrual_method           varchar2 default null,
                       x_invoice_method                   varchar2 default null,
                       x_gen_etc_src_code               VARCHAR2 default NULL
  ) IS
    CURSOR C IS SELECT rowid FROM PA_TASKS
                 WHERE task_id = X_Task_Id;
      CURSOR C2 IS SELECT pa_tasks_s.nextval FROM sys.dual;

	-- 4537865
	l_incoming_taskid pa_tasks.task_id%type ;
   BEGIN
	l_incoming_taskid := x_task_id ;

      if (X_Task_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Task_Id;
        CLOSE C2;
      end if;

       INSERT INTO PA_TASKS(
              task_id,
              project_id,
              task_number,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              task_name,
              long_task_name,
              top_task_id,
              wbs_level,
              ready_to_bill_flag,
              ready_to_distribute_flag,
              parent_task_id,
              description,
              carrying_out_organization_id,
              service_type_code,
              task_manager_person_id,
              chargeable_flag,
              billable_flag,
              limit_to_txn_controls_flag,
              start_date,
              completion_date,
              address_id,
              labor_bill_rate_org_id,
              labor_std_bill_rate_schdl,
              labor_schedule_fixed_date,
              labor_schedule_discount,
              non_labor_bill_rate_org_id,
              non_labor_std_bill_rate_schdl,
              non_labor_schedule_fixed_date,
              non_labor_schedule_discount,
              labor_cost_multiplier_name,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              cost_ind_rate_sch_id,
              rev_ind_rate_sch_id,
              inv_ind_rate_sch_id,
              cost_ind_sch_fixed_date,
              rev_ind_sch_fixed_date,
              inv_ind_sch_fixed_date,
              labor_sch_type,
              non_labor_sch_type,
              Allow_Cross_Charge_Flag,
              Project_Rate_Date,
              Project_Rate_Type,
			     CC_Process_Labor_Flag,
			     Labor_Tp_Schedule_Id,
			     Labor_Tp_Fixed_Date,
			     CC_Process_NL_Flag,
			     Nl_Tp_Schedule_Id,
			     Nl_Tp_Fixed_Date,
			     receive_project_invoice_flag,
              work_type_id,
              job_bill_rate_schedule_id,
              emp_bill_rate_schedule_id,
              taskfunc_cost_rate_type,
              taskfunc_cost_rate_date,
              non_lab_std_bill_rt_sch_id,
              labor_disc_reason_code,
              non_labor_disc_reason_code,
              retirement_cost_flag ,
              cint_eligible_flag ,
              cint_stop_date  ,
              record_version_number,
              customer_id,
              revenue_accrual_method,
              invoice_method,
              GEN_ETC_SOURCE_CODE
             ) VALUES (
              X_Task_Id,
              X_Project_Id,
              SUBSTRB( X_Task_Number, 1, 25 ), --Bug 4297289
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              SUBSTRB( X_Task_Name, 1, 20 ), --Bug 4297289
              X_Long_Task_Name,
              nvl(X_Top_Task_Id, X_Task_id),
              X_Wbs_Level,
              X_Ready_To_Bill_Flag,
              X_Ready_To_Distribute_Flag,
              X_Parent_Task_Id,
              X_Description,
              X_Carrying_Out_Organization_Id,
              X_Service_Type_Code,
              X_Task_Manager_Person_Id,
              X_Chargeable_Flag,
              X_Billable_Flag,
              X_Limit_To_Txn_Controls_Flag,
              X_Start_Date,
              X_Completion_Date,
              X_Address_Id,
              X_Labor_Bill_Rate_Org_Id,
              X_Labor_Std_Bill_Rate_Schdl,
              X_Labor_Schedule_Fixed_Date,
              X_Labor_Schedule_Discount,
              X_Non_Labor_Bill_Rate_Org_Id,
              X_NL_Std_Bill_Rate_Schdl,
              X_NL_Schedule_Fixed_Date,
              X_Non_Labor_Schedule_Discount,
              X_Labor_Cost_Multiplier_Name,
              X_Attribute_Category,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Cost_Ind_Rate_Sch_Id,
              X_Rev_Ind_Rate_Sch_Id,
              X_Inv_Ind_Rate_Sch_Id,
              X_Cost_Ind_Sch_Fixed_Date,
              X_Rev_Ind_Sch_Fixed_Date,
              X_Inv_Ind_Sch_Fixed_Date,
              X_Labor_Sch_Type,
              X_Non_Labor_Sch_Type,
              X_Allow_Cross_Charge_Flag,
              X_Project_Rate_Date,
              X_Project_Rate_Type,
			     X_CC_Process_Labor_Flag,
			     X_Labor_Tp_Schedule_Id,
			     X_Labor_Tp_Fixed_Date,
			     X_CC_Process_NL_Flag,
			     X_Nl_Tp_Schedule_Id,
			     X_Nl_Tp_Fixed_Date,
			     X_Receive_Project_Invoice_Flag,
              X_work_type_id,
              X_job_bill_rate_schedule_id,
              X_emp_bill_rate_schedule_id,
              X_taskfunc_cost_rate_type,
              X_taskfunc_cost_rate_date,
              X_non_lab_std_bill_rt_sch_id,
              X_labor_disc_reason_code,
              X_non_labor_disc_reason_code,
--PA L Changes 2872708
              x_retirement_cost_flag ,
              x_cint_eligible_flag ,
              x_cint_stop_date  ,
              1,
              x_customer_id,
              x_revenue_accrual_method,
              x_invoice_method,
              x_gen_etc_src_code
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
-- 4537865
EXCEPTION
  WHEN OTHERS THEN
	-- RESET IN OUT params to their original values
	X_Rowid := NULL ;
	X_Task_Id := l_incoming_taskid ;

	-- Populate error stack and RAISE
	fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_TASKS_PKG',
                          p_procedure_name => 'Insert_Row',
                          p_error_text     => SUBSTRB(SQLERRM,1,240));
  RAISE;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Task_Id                          NUMBER,
                     X_Project_Id                       NUMBER,
                     X_Task_Number                      VARCHAR2,
                     X_Task_Name                        VARCHAR2,
-- Long Task Name change by xxlu
                     X_Long_Task_Name                   VARCHAR2,
                     X_Top_Task_Id                      NUMBER,
                     X_Wbs_Level                        NUMBER,
                     X_Ready_To_Bill_Flag               VARCHAR2,
                     X_Ready_To_Distribute_Flag         VARCHAR2,
                     X_Parent_Task_Id                   NUMBER,
                     X_Description                      VARCHAR2,
                     X_Carrying_Out_Organization_Id     NUMBER,
                     X_Service_Type_Code                VARCHAR2,
                     X_Task_Manager_Person_Id           NUMBER,
                     X_Chargeable_Flag                  VARCHAR2,
                     X_Billable_Flag                    VARCHAR2,
                     X_Limit_To_Txn_Controls_Flag       VARCHAR2,
                     X_Start_Date                       DATE,
                     X_Completion_Date                  DATE,
                     X_Address_Id                       NUMBER,
                     X_Labor_Bill_Rate_Org_Id           NUMBER,
                     X_Labor_Std_Bill_Rate_Schdl        VARCHAR2,
                     X_Labor_Schedule_Fixed_Date        DATE,
                     X_Labor_Schedule_Discount          NUMBER,
                     X_Non_Labor_Bill_Rate_Org_Id       NUMBER,
                     X_NL_Std_Bill_Rate_Schdl           VARCHAR2,
                     X_NL_Schedule_Fixed_Date           DATE,
                     X_Non_Labor_Schedule_Discount      NUMBER,
                     X_Labor_Cost_Multiplier_Name       VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Cost_Ind_Rate_Sch_Id             NUMBER,
                     X_Rev_Ind_Rate_Sch_Id              NUMBER,
                     X_Inv_Ind_Rate_Sch_Id              NUMBER,
                     X_Cost_Ind_Sch_Fixed_Date          DATE,
                     X_Rev_Ind_Sch_Fixed_Date           DATE,
                     X_Inv_Ind_Sch_Fixed_Date           DATE,
                     X_Labor_Sch_Type                   VARCHAR2,
                     X_Non_Labor_Sch_Type               VARCHAR2,
                     X_Allow_Cross_Charge_Flag        VARCHAR2,
                     X_Project_Rate_Date              DATE,
                     X_Project_Rate_Type              VARCHAR2,
                     X_CC_Process_Labor_Flag          VARCHAR2,
                     X_Labor_Tp_Schedule_Id           NUMBER,
                     X_Labor_Tp_Fixed_Date            DATE,
                     X_CC_Process_NL_Flag             VARCHAR2,
                     X_Nl_Tp_Schedule_Id              NUMBER,
                     X_Nl_Tp_Fixed_Date               DATE,
                     X_receive_project_invoice_flag   VARCHAR2,
                     X_work_type_id                   NUMBER,
-- 21-MAR-2001 anlee
-- added job_bill_rate_schedule_id,
-- emp_bill_rate_schedule_id for
-- PRM forecasting changes
                     X_job_bill_rate_schedule_id      NUMBER,
                     X_emp_bill_rate_schedule_id      NUMBER,
--MCA Sakthi for MultiAgreementCurreny Project
                       X_taskfunc_cost_rate_type        VARCHAR2,
                       X_taskfunc_cost_rate_date        DATE,
                       X_non_lab_std_bill_rt_sch_id     NUMBER,
--MCA Sakthi for MultiAgreementCurreny Project
-- FP.K Setup changes by msundare
                       X_labor_disc_reason_code         VARCHAR2,
                       X_non_labor_disc_reason_code     VARCHAR2,
--PA L Changes 2872708
                       x_retirement_cost_flag           VARCHAR2,
                       x_cint_eligible_flag             VARCHAR2,
                       x_cint_stop_date                 DATE
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PA_TASKS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Task_Id NOWAIT;
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
               (Recinfo.task_id =  X_Task_Id)
           AND (Recinfo.project_id =  X_Project_Id)
           AND (ltrim(rtrim(Recinfo.task_number)) =  ltrim(rtrim(X_Task_Number)))
           AND (rtrim(Recinfo.task_name) =  rtrim(X_Task_Name))
           AND (Recinfo.top_task_id =  X_Top_Task_Id)
           AND (Recinfo.wbs_level =  X_Wbs_Level)
           AND (Recinfo.ready_to_bill_flag =  X_Ready_To_Bill_Flag)
           AND (Recinfo.ready_to_distribute_flag =  X_Ready_To_Distribute_Flag)
           AND (   (Recinfo.parent_task_id =  X_Parent_Task_Id)
                OR (    (Recinfo.parent_task_id IS NULL)
                    AND (X_Parent_Task_Id IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.carrying_out_organization_id =
			X_Carrying_Out_Organization_Id)
                OR (    (Recinfo.carrying_out_organization_id IS NULL)
                    AND (X_Carrying_Out_Organization_Id IS NULL)))
           AND (   (Recinfo.service_type_code =  X_Service_Type_Code)
                OR (    (Recinfo.service_type_code IS NULL)
                    AND (X_Service_Type_Code IS NULL)))
           AND (   (Recinfo.task_manager_person_id =
			X_Task_Manager_Person_Id)
                OR (    (Recinfo.task_manager_person_id IS NULL)
                    AND (X_Task_Manager_Person_Id IS NULL)))
           AND (   (Recinfo.chargeable_flag =  X_Chargeable_Flag)
                OR (    (Recinfo.chargeable_flag IS NULL)
                    AND (X_Chargeable_Flag IS NULL)))
           AND (   (Recinfo.billable_flag =  X_Billable_Flag)
                OR (    (Recinfo.billable_flag IS NULL)
                    AND (X_Billable_Flag IS NULL)))
           AND (   (Recinfo.limit_to_txn_controls_flag =
			X_Limit_To_Txn_Controls_Flag)
                OR (    (Recinfo.limit_to_txn_controls_flag IS NULL)
                    AND (X_Limit_To_Txn_Controls_Flag IS NULL)))
           AND (   (Recinfo.start_date =  X_Start_Date)
                OR (    (Recinfo.start_date IS NULL)
                    AND (X_Start_Date IS NULL)))
           AND (   (Recinfo.completion_date =  X_Completion_Date)
                OR (    (Recinfo.completion_date IS NULL)
                    AND (X_Completion_Date IS NULL)))
           AND (   (Recinfo.address_id =  X_Address_Id)
                OR (    (Recinfo.address_id IS NULL)
                    AND (X_Address_Id IS NULL)))
           AND (   (Recinfo.labor_bill_rate_org_id =  X_Labor_Bill_Rate_Org_Id)
                OR (    (Recinfo.labor_bill_rate_org_id IS NULL)
                    AND (X_Labor_Bill_Rate_Org_Id IS NULL)))
           AND (   (Recinfo.labor_std_bill_rate_schdl =
			 X_Labor_Std_Bill_Rate_Schdl)
                OR (    (Recinfo.labor_std_bill_rate_schdl IS NULL)
                    AND (X_Labor_Std_Bill_Rate_Schdl IS NULL)))
           AND (   (Recinfo.labor_schedule_fixed_date =
			 X_Labor_Schedule_Fixed_Date)
                OR (    (Recinfo.labor_schedule_fixed_date IS NULL)
                    AND (X_Labor_Schedule_Fixed_Date IS NULL)))
           AND (   (Recinfo.labor_schedule_discount =
			 X_Labor_Schedule_Discount)
                OR (    (Recinfo.labor_schedule_discount IS NULL)
                    AND (X_Labor_Schedule_Discount IS NULL)))
           AND (   (Recinfo.non_labor_bill_rate_org_id =
			 X_Non_Labor_Bill_Rate_Org_Id)
                OR (    (Recinfo.non_labor_bill_rate_org_id IS NULL)
                    AND (X_Non_Labor_Bill_Rate_Org_Id IS NULL)))
           AND (   (Recinfo.non_labor_std_bill_rate_schdl =
			 X_NL_Std_Bill_Rate_Schdl)
                OR (    (Recinfo.non_labor_std_bill_rate_schdl IS NULL)
                    AND (X_NL_Std_Bill_Rate_Schdl IS NULL)))
           AND (   (Recinfo.non_labor_schedule_fixed_date =
			 X_NL_Schedule_Fixed_Date)
                OR (    (Recinfo.non_labor_schedule_fixed_date IS NULL)
                    AND (X_NL_Schedule_Fixed_Date IS NULL)))
           AND (   (Recinfo.non_labor_schedule_discount =
			 X_Non_Labor_Schedule_Discount)
                OR (    (Recinfo.non_labor_schedule_discount IS NULL)
                    AND (X_Non_Labor_Schedule_Discount IS NULL)))
           AND (   (Recinfo.labor_cost_multiplier_name =
			 X_Labor_Cost_Multiplier_Name)
                OR (    (Recinfo.labor_cost_multiplier_name IS NULL)
                    AND (X_Labor_Cost_Multiplier_Name IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.cost_ind_rate_sch_id =
			X_Cost_Ind_Rate_Sch_Id)
                OR (    (Recinfo.cost_ind_rate_sch_id IS NULL)
                    AND (X_Cost_Ind_Rate_Sch_Id IS NULL)))
           AND (   (Recinfo.rev_ind_rate_sch_id =  X_Rev_Ind_Rate_Sch_Id)
                OR (    (Recinfo.rev_ind_rate_sch_id IS NULL)
                    AND (X_Rev_Ind_Rate_Sch_Id IS NULL)))
           AND (   (Recinfo.inv_ind_rate_sch_id =  X_Inv_Ind_Rate_Sch_Id)
                OR (    (Recinfo.inv_ind_rate_sch_id IS NULL)
                    AND (X_Inv_Ind_Rate_Sch_Id IS NULL)))
           AND (   (Recinfo.cost_ind_sch_fixed_date =
			 X_Cost_Ind_Sch_Fixed_Date)
                OR (    (Recinfo.cost_ind_sch_fixed_date IS NULL)
                    AND (X_Cost_Ind_Sch_Fixed_Date IS NULL)))
           AND (   (Recinfo.rev_ind_sch_fixed_date =
			 X_Rev_Ind_Sch_Fixed_Date)
                OR (    (Recinfo.rev_ind_sch_fixed_date IS NULL)
                    AND (X_Rev_Ind_Sch_Fixed_Date IS NULL)))
           AND (   (Recinfo.inv_ind_sch_fixed_date =
			 X_Inv_Ind_Sch_Fixed_Date)
                OR (    (Recinfo.inv_ind_sch_fixed_date IS NULL)
                    AND (X_Inv_Ind_Sch_Fixed_Date IS NULL)))
           AND (   (Recinfo.labor_sch_type =  X_Labor_Sch_Type)
                OR (    (Recinfo.labor_sch_type IS NULL)
                    AND (X_Labor_Sch_Type IS NULL)))
           AND (   (Recinfo.non_labor_sch_type =  X_Non_Labor_Sch_Type)
                OR (    (Recinfo.non_labor_sch_type IS NULL)
                    AND (X_Non_Labor_Sch_Type IS NULL)))
              AND (   (Recinfo.Allow_Cross_Charge_Flag =
         X_Allow_Cross_Charge_Flag)
                OR (    (Recinfo.Allow_Cross_Charge_Flag IS NULL)
                    AND (X_Allow_Cross_Charge_Flag IS NULL)))
              AND (   (Recinfo.Project_Rate_Date =
         X_Project_Rate_Date)
                OR (    (Recinfo.Project_Rate_Date IS NULL)
                    AND (X_Project_Rate_Date IS NULL)))
              AND (   (Recinfo.Project_Rate_Type =
         X_Project_Rate_Type)
                OR (    (Recinfo.Project_Rate_Type IS NULL)
                    AND (X_Project_Rate_Type IS NULL)))
              AND (   (Recinfo.CC_Process_Labor_Flag =
         X_CC_Process_Labor_Flag)
                OR (    (Recinfo.CC_Process_Labor_Flag IS NULL)
                    AND (X_CC_Process_Labor_Flag IS NULL)))
              AND (   (Recinfo.Labor_Tp_Schedule_Id =
         X_Labor_Tp_Schedule_Id)
                OR (    (Recinfo.Labor_Tp_Schedule_Id IS NULL)
                    AND (X_Labor_Tp_Schedule_Id IS NULL)))
              AND (   (Recinfo.Labor_Tp_Fixed_Date =
         X_Labor_Tp_Fixed_Date)
                OR (    (Recinfo.Labor_Tp_Fixed_Date IS NULL)
                    AND (X_Labor_Tp_Fixed_Date IS NULL)))
              AND (   (Recinfo.CC_Process_NL_Flag =
         X_CC_Process_NL_Flag)
                OR (    (Recinfo.CC_Process_NL_Flag IS NULL)
                    AND (X_CC_Process_NL_Flag IS NULL)))
              AND (   (Recinfo.Nl_Tp_Schedule_Id =
         X_Nl_Tp_Schedule_Id)
                OR (    (Recinfo.Nl_Tp_Schedule_Id IS NULL)
                    AND (X_Nl_Tp_Schedule_Id IS NULL)))
              AND (   (Recinfo.Nl_Tp_Fixed_Date =
         X_Nl_Tp_Fixed_Date)
                OR (    (Recinfo.Nl_Tp_Fixed_Date IS NULL)
                    AND (X_Nl_Tp_Fixed_Date IS NULL)))
              AND (   (Recinfo.Receive_Project_Invoice_Flag =
         X_Receive_Project_Invoice_Flag)
                OR (    (Recinfo.Receive_Project_Invoice_Flag IS NULL)
                    AND (X_Receive_Project_Invoice_Flag IS NULL)))
              AND (   (Recinfo.work_type_id =
         X_work_type_id)
                OR (    (Recinfo.work_type_id IS NULL)
                    AND (X_work_type_id IS NULL)))
              AND (   (Recinfo.job_bill_rate_schedule_id =
         X_job_bill_rate_schedule_id)
                OR (    (Recinfo.job_bill_rate_schedule_id IS NULL)
                    AND (X_job_bill_rate_schedule_id IS NULL)))
              AND (   (Recinfo.emp_bill_rate_schedule_id =
         X_emp_bill_rate_schedule_id)
                OR (    (Recinfo.emp_bill_rate_schedule_id IS NULL)
                    AND (X_emp_bill_rate_schedule_id IS NULL)))
--MCA Sakthi for MultiAgreementCurreny Project
              AND (   (Recinfo.taskfunc_cost_rate_type =
         X_taskfunc_cost_rate_type)
                OR (    (Recinfo.taskfunc_cost_rate_type IS NULL)
                    AND (X_taskfunc_cost_rate_type IS NULL)))
              AND (   (Recinfo.taskfunc_cost_rate_date =
         X_taskfunc_cost_rate_date)
                OR (    (Recinfo.taskfunc_cost_rate_date IS NULL)
                    AND (X_taskfunc_cost_rate_date IS NULL)))
              AND (   (Recinfo.non_lab_std_bill_rt_sch_id =
         X_non_lab_std_bill_rt_sch_id)
                OR (    (Recinfo.non_lab_std_bill_rt_sch_id IS NULL)
                    AND (X_non_lab_std_bill_rt_sch_id IS NULL)))
--MCA Sakthi for MultiAgreementCurreny Project
-- Modified for added columns in FP.K msundare
              AND (   (Recinfo.labor_disc_reason_code =
         X_labor_disc_reason_code)
                OR (    (Recinfo.labor_disc_reason_code IS NULL)
                    AND (X_labor_disc_reason_code IS NULL)))
              AND (   (Recinfo.non_labor_disc_reason_code =
         X_non_labor_disc_reason_code)
                OR (    (Recinfo.non_labor_disc_reason_code IS NULL)
                    AND (X_non_labor_disc_reason_code IS NULL)))
              AND (   (Recinfo.retirement_cost_flag =
         X_retirement_cost_flag)
                OR (    (Recinfo.retirement_cost_flag IS NULL)
                    AND (X_retirement_cost_flag IS NULL)))
              AND (   (Recinfo.cint_eligible_flag =
         X_cint_eligible_flag)
                OR (    (Recinfo.cint_eligible_flag IS NULL)
                    AND (X_cint_eligible_flag IS NULL)))
             AND (   (Recinfo.cint_stop_date =
         X_cint_stop_date)
                OR (    (Recinfo.cint_stop_date IS NULL)
                    AND (X_cint_stop_date IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Task_Id                        NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Number                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Task_Name                      VARCHAR2,
-- Long Task Name change by xxlu
                       X_Long_Task_Name                 VARCHAR2,
                       X_Top_Task_Id                    NUMBER,
                       X_Wbs_Level                      NUMBER,
                       X_Ready_To_Bill_Flag             VARCHAR2,
                       X_Ready_To_Distribute_Flag       VARCHAR2,
                       X_Parent_Task_Id                 NUMBER,
                       X_Description                    VARCHAR2,
                       X_Carrying_Out_Organization_Id   NUMBER,
                       X_Service_Type_Code              VARCHAR2,
                       X_Task_Manager_Person_Id         NUMBER,
                       X_Chargeable_Flag                VARCHAR2,
                       X_Billable_Flag                  VARCHAR2,
                       X_Limit_To_Txn_Controls_Flag     VARCHAR2,
                       X_Start_Date                     DATE,
                       X_Completion_Date                DATE,
                       X_Address_Id                     NUMBER,
                       X_Labor_Bill_Rate_Org_Id         NUMBER,
                       X_Labor_Std_Bill_Rate_Schdl      VARCHAR2,
                       X_Labor_Schedule_Fixed_Date      DATE,
                       X_Labor_Schedule_Discount        NUMBER,
                       X_Non_Labor_Bill_Rate_Org_Id     NUMBER,
                       X_NL_Std_Bill_Rate_Schdl  	VARCHAR2,
                       X_NL_Schedule_Fixed_Date  	DATE,
                       X_Non_Labor_Schedule_Discount    NUMBER,
                       X_Labor_Cost_Multiplier_Name     VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Cost_Ind_Rate_Sch_Id           NUMBER,
                       X_Rev_Ind_Rate_Sch_Id            NUMBER,
                       X_Inv_Ind_Rate_Sch_Id            NUMBER,
                       X_Cost_Ind_Sch_Fixed_Date        DATE,
                       X_Rev_Ind_Sch_Fixed_Date         DATE,
                       X_Inv_Ind_Sch_Fixed_Date         DATE,
                       X_Labor_Sch_Type                 VARCHAR2,
                       X_Non_Labor_Sch_Type             VARCHAR2,
                       X_Allow_Cross_Charge_Flag        VARCHAR2,
                       X_Project_Rate_Date              DATE,
                       X_Project_Rate_Type              VARCHAR2,
                       X_CC_Process_Labor_Flag          VARCHAR2,
                       X_Labor_Tp_Schedule_Id           NUMBER,
                       X_Labor_Tp_Fixed_Date            DATE,
                       X_CC_Process_NL_Flag             VARCHAR2,
                       X_Nl_Tp_Schedule_Id              NUMBER,
                       X_Nl_Tp_Fixed_Date               DATE,
                       X_receive_project_invoice_flag   VARCHAR2,
                       X_work_type_id                   NUMBER,
-- 21-MAR-2001 anlee
-- added job_bill_rate_schedule_id,
-- emp_bill_rate_schedule_id for
-- PRM forecasting changes
                       X_job_bill_rate_schedule_id      NUMBER,
                       X_emp_bill_rate_schedule_id      NUMBER,
--MCA Sakthi for MultiAgreementCurreny Project
                       X_taskfunc_cost_rate_type        VARCHAR2,
                       X_taskfunc_cost_rate_date        DATE,
                       X_non_lab_std_bill_rt_sch_id     NUMBER,
--MCA Sakthi for MultiAgreementCurreny Project
-- FP.K Setup changes by msundare
                       X_labor_disc_reason_code         VARCHAR2,
                       X_non_labor_disc_reason_code     VARCHAR2,
--PA L Dev
                       x_retirement_cost_flag           VARCHAR2,
                       x_cint_eligible_flag             VARCHAR2,
                       x_cint_stop_date                 DATE,
                       x_gen_etc_src_code               VARCHAR2
  ) IS
  BEGIN
    UPDATE PA_TASKS
    SET
       task_id                         =     X_Task_Id,
       project_id                      =     X_Project_Id,
       task_number                     =     SUBSTRB( X_Task_Number, 1, 25 ), -- 4537865 : Replaced SUBSTR with SUBSTRB
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       task_name                       =     SUBSTRB( X_Task_Name, 1, 20 ),-- 4537865 : Replaced SUBSTR with SUBSTRB
       long_task_name                  =     X_Long_Task_Name,
       top_task_id                     =     X_Top_Task_Id,
       wbs_level                       =     X_Wbs_Level,
       ready_to_bill_flag              =     X_Ready_To_Bill_Flag,
       ready_to_distribute_flag        =     X_Ready_To_Distribute_Flag,
       parent_task_id                  =     X_Parent_Task_Id,
       description                     =     X_Description,
       carrying_out_organization_id    =     X_Carrying_Out_Organization_Id,
       service_type_code               =     X_Service_Type_Code,
       task_manager_person_id          =     X_Task_Manager_Person_Id,
       chargeable_flag                 =     X_Chargeable_Flag,
       billable_flag                   =     X_Billable_Flag,
       limit_to_txn_controls_flag      =     X_Limit_To_Txn_Controls_Flag,
       start_date                      =     X_Start_Date,
       completion_date                 =     X_Completion_Date,
       address_id                      =     X_Address_Id,
       labor_bill_rate_org_id          =     X_Labor_Bill_Rate_Org_Id,
       labor_std_bill_rate_schdl       =     X_Labor_Std_Bill_Rate_Schdl,
       labor_schedule_fixed_date       =     X_Labor_Schedule_Fixed_Date,
       labor_schedule_discount         =     X_Labor_Schedule_Discount,
       non_labor_bill_rate_org_id      =     X_Non_Labor_Bill_Rate_Org_Id,
       non_labor_std_bill_rate_schdl   =     X_NL_Std_Bill_Rate_Schdl,
       non_labor_schedule_fixed_date   =     X_NL_Schedule_Fixed_Date,
       non_labor_schedule_discount     =     X_Non_Labor_Schedule_Discount,
       labor_cost_multiplier_name      =     X_Labor_Cost_Multiplier_Name,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       cost_ind_rate_sch_id            =     X_Cost_Ind_Rate_Sch_Id,
       rev_ind_rate_sch_id             =     X_Rev_Ind_Rate_Sch_Id,
       inv_ind_rate_sch_id             =     X_Inv_Ind_Rate_Sch_Id,
       cost_ind_sch_fixed_date         =     X_Cost_Ind_Sch_Fixed_Date,
       rev_ind_sch_fixed_date          =     X_Rev_Ind_Sch_Fixed_Date,
       inv_ind_sch_fixed_date          =     X_Inv_Ind_Sch_Fixed_Date,
       labor_sch_type                  =     X_Labor_Sch_Type,
       non_labor_sch_type              =     X_Non_Labor_Sch_Type,
       Allow_Cross_Charge_Flag         =     X_Allow_Cross_Charge_Flag,
       Project_Rate_Date               =     X_Project_Rate_Date,
       Project_Rate_Type               =     X_Project_Rate_Type,
       CC_Process_Labor_Flag           =     X_CC_Process_Labor_Flag,
       Labor_Tp_Schedule_Id            =     X_Labor_Tp_Schedule_Id,
       Labor_Tp_Fixed_Date             =     X_Labor_Tp_Fixed_Date,
       CC_Process_NL_Flag              =     X_CC_Process_NL_Flag,
       Nl_Tp_Schedule_Id               =     X_Nl_Tp_Schedule_Id,
       Nl_Tp_Fixed_Date                =     X_Nl_Tp_Fixed_Date,
       Receive_Project_Invoice_Flag    =     X_Receive_Project_Invoice_Flag,
       Work_Type_ID                    =     X_Work_Type_ID,
       job_bill_rate_schedule_id       =     X_job_bill_rate_schedule_id,
       emp_bill_rate_schedule_id       =     X_emp_bill_rate_schedule_id,
--MCA Sakthi for MultiAgreementCurreny Project
       taskfunc_cost_rate_type       =     X_taskfunc_cost_rate_type,
       taskfunc_cost_rate_date       =     X_taskfunc_cost_rate_date,
       non_lab_std_bill_rt_sch_id    =     X_non_lab_std_bill_rt_sch_id,
 --msundare
       labor_disc_reason_code        =     X_labor_disc_reason_code,
       non_labor_disc_reason_code    =     X_non_labor_disc_reason_code,
--PA_L
       retirement_cost_flag          =     x_retirement_cost_flag,
       cint_eligible_flag            =     x_cint_eligible_flag,
       cint_stop_date                =     x_cint_stop_date,
       GEN_ETC_SOURCE_CODE           =     x_gen_etc_src_code,
       record_version_number         =     nvl( record_version_number, 1 ) + 1
--MCA Sakthi for MultiAgreementCurreny Project
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PA_TASKS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

--
--  Name
--          verify_lowest_level_task
--
--  Purpose
--          This procedure is used to verify if a task is a lowest level task.
--
--  History
--          XX-MAY-94   R. Wadera          Created
--
procedure verify_lowest_level_task (x_return_status IN OUT NOCOPY number, --File.Sql.39 bug 4440895
                                    x_task_id       IN     number)
is
x_dummy number;

begin

  x_return_status := 0;
  begin
    select task_id
    into   x_dummy
    from   pa_tasks t1
    where  not exists
                   (select *
                    from   pa_tasks t2
                    where  t1.task_id = t2.parent_task_id)
    and t1.task_id = x_task_id;

    x_return_status := 0;
    EXCEPTION
      WHEN NO_DATA_FOUND then
      x_return_status := 1;

      WHEN OTHERS then
      x_return_status := SQLCODE;
  end;

end verify_lowest_level_task;

END PA_TASKS_PKG;

/
