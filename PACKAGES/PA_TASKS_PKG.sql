--------------------------------------------------------
--  DDL for Package PA_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASKS_PKG" AUTHID CURRENT_USER as
/* $Header: PAXTASKS.pls 120.1 2005/08/19 17:21:40 mwasowic noship $ */


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
                       X_Receive_Project_Invoice_Flag   VARCHAR2,
                       X_Work_Type_ID                   NUMBER,
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
/*FPM Changes */
                       x_customer_id                    Number  default NULL,
                       x_revenue_accrual_method           varchar2 default null,
                       x_invoice_method                   varchar2 default null,
                       x_gen_etc_src_code               VARCHAR2 default NULL
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Task_Id                          NUMBER,
                     X_Project_Id                       NUMBER,
                     X_Task_Number                      VARCHAR2,
                     X_Task_Name                        VARCHAR2,
-- Long Task Name change by xxlu
                     X_Long_Task_Name                 VARCHAR2,
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
                     X_Receive_Project_Invoice_Flag   VARCHAR2,
                     X_Work_Type_ID                   NUMBER,
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
                       x_cint_stop_date                 DATE
                    );

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
                       X_Receive_Project_Invoice_Flag   VARCHAR2,
                       X_Work_Type_ID                   NUMBER,
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
                     );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);


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
                                    x_task_id       IN     number);


END PA_TASKS_PKG;

 

/
