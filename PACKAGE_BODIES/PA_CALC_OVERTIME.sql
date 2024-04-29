--------------------------------------------------------
--  DDL for Package Body PA_CALC_OVERTIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CALC_OVERTIME" as
/* $Header: PAXDLCOB.pls 120.1.12010000.2 2008/09/16 09:28:40 jravisha ship $ */

  -- The user parameters used are:
  --    User_ID, Request_ID, Program_ID, Program_App_ID
  --
  -- The database columns used are:
  --    Person_ID, Person_Full_Name, Organization, Expenditure_End_Date,
  --    Rule_Set, Overtime_Exp_Type

  -- ======================================================================
  --
  --   GLOBALS
  --
  -- ======================================================================

  TYPE OTaskIDTyp IS TABLE OF number INDEX BY BINARY_INTEGER;
  TYPE OTaskLCMTyp IS TABLE OF varchar2(20) INDEX BY BINARY_INTEGER;
  TYPE OTaskNameTyp IS TABLE OF varchar2(20) INDEX BY BINARY_INTEGER;

  OTaskID_Tab OTaskIDTyp;
  OTaskLCM_Tab OTaskLCMTyp;
  OTaskName_Tab OTaskNameTyp;

  /*
     Multi-Currency related changes:
     New variables added to get currency codes in various currencies.
     One variable is used to get Txn/Functional currencies because they are same in
     case of labor.
     Project rate date and type not populated because the costing program will take care of that
   */
  OCurrcode     VARCHAR2(15);
  OProjCurrcode VARCHAR2(15);
  OProjfuncCurrcode VARCHAR2(15);

  Exp_Group_Created_Flag varchar2(1) := 'N';
  Exp_Created_Flag varchar2(1) := 'N';
  G_Org_Id  number := NULL ;
  /* Bug 1756677. Moved out of procedure Insert_Expenditure_And_Group */
  /* Bug#2373198 Modified data type from varchar2(20 to reflect as is in table */
  /* overtime_expenditure_group varchar2(20); */
     overtime_expenditure_group pa_expenditure_groups_all.expenditure_group%type;



  -- ======================================================================
  --
  --   PRIVATE PROCEDURE/FUNCTIONS
  --
  -- ======================================================================

  --
  --  Fetch Job Id for the Overtime Item
  --
  FUNCTION Get_Job_ID(
		X_Expenditure_ID		IN number) RETURN number IS
    Job_ID number;
  BEGIN
    SELECT job_id
    INTO Job_Id
    FROM per_assignments_f a,
           pa_expenditures ex
    WHERE ex.expenditure_id = X_expenditure_id
       AND a.person_id = ex.incurred_by_person_id
       AND (a.assignment_type = 'E' OR a.assignment_type = 'C')
       AND a.primary_flag = 'Y'
       AND trunc(ex.expenditure_ending_date)
		BETWEEN a.effective_start_date AND
                    a.effective_end_date;
    RETURN Job_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      /*
       * Bug#1575317
       * If control comes here, its possible that, the previous select is
       * unable to get a job_id because, the expenditure_ending_date falls
       * later to the effective_end_date and there's NO assignments for the
       * person from then on.
       * To handle this situation, the effective_end_date is mapped to the
       * next weekending date - to get the job_id.
       */
      SELECT job_id
        INTO Job_Id
        FROM per_assignments_f a,
             pa_expenditures ex
       WHERE ex.expenditure_id = X_expenditure_id
         AND a.person_id = ex.incurred_by_person_id
         AND (a.assignment_type = 'E' OR a.assignment_type = 'C')
         AND a.primary_flag = 'Y'
         AND trunc(ex.expenditure_ending_date)
                BETWEEN a.effective_start_date AND
                    pa_utils.GetWeekEnding(a.effective_end_date);

    RETURN Job_ID;
  END Get_Job_ID;

  --
  -- Update old, existing overtime expenditure items
  -- Set NET_ZERO_ADJUSTMENT_FLAG = 'Y'
  --
  PROCEDURE Update_Old_Overtime_Item (
		Temp_Task			IN     number,
		R_P_User_ID			IN     number,
		R_P_Program_ID			IN     number,
		R_P_Request_ID			IN     number,
		R_P_Program_App_ID		IN     number,
		R_Person_Id			IN     number,
		R_Expenditure_End_Date		IN     date,
		R_Overtime_Exp_Type		IN     varchar2) IS
    X_status number;
  BEGIN
    FOR c IN
	(select expenditure_item_id
	from	pa_expenditure_items i
	       ,pa_expenditures e
	where	i.system_linkage_function ||'' = 'OT'
	and	i.expenditure_id = e.expenditure_id
	and	e.incurred_by_person_id = R_Person_Id
	and	e.expenditure_ending_date = R_Expenditure_End_Date
	and	i.task_id = Temp_Task
	and	i.expenditure_item_date = R_Expenditure_End_Date
	and	i.expenditure_type = R_Overtime_Exp_Type
	and	nvl(i.net_zero_adjustment_flag,'N') <> 'Y') LOOP
      Pa_Adjustments.SetNetZero(
	 c.expenditure_item_id
	,R_P_User_ID
	,0
	,X_status);
    END LOOP;
  END Update_Old_Overtime_Item;

  --
  -- Reverse old overtime expenditure items
  --
  -- Set adjusted_expenditure_item_id = old overtime expenditure item id.
  -- Set NET_ZERO_ADJUSTMENT_FLAG = 'Y'
  --
  PROCEDURE Reverse_Old_Overtime_Item (
		X_Expenditure_ID		IN     number,
		Temp_Task			IN     number,
		R_P_User_ID			IN     number,
		R_P_Request_ID			IN     number,
		R_P_Program_ID			IN     number,
		R_P_Program_App_ID		IN     number,
		R_Person_Id			IN     number,
		R_Expenditure_End_Date		IN     date,
		R_Overtime_Exp_Type		IN     varchar2) IS
    i BINARY_INTEGER := 0;
    X_status NUMBER;
  BEGIN
    FOR c IN
      (select
	 PA_EXPENDITURE_ITEMS_S.NEXTVAL		X_expenditure_item_id
	,i.expenditure_id			X_expenditure_id
	,i.expenditure_item_date		X_expenditure_item_date
	,i.task_id				X_task_id
	,i.expenditure_type			X_expenditure_type
	,i.non_labor_resource			X_non_labor_resource
	,i.organization_id			X_nl_resource_org_id
	,i.quantity* -1				X_quantity
	,i.raw_cost* -1				X_raw_cost
	,i.raw_cost_rate			X_raw_cost_rate
	,i.override_to_organization_id		X_override_to_org_id
	,i.billable_flag			X_billable_flag
	,i.bill_hold_flag			X_bill_hold_flag
	,i.orig_transaction_reference		X_orig_transaction_ref
	,i.transferred_from_exp_item_id		X_transferred_from_ei
	,i.adjusted_expenditure_item_id		X_adj_expend_item_id
	,i.attribute_category			X_attribute_category
	,i.attribute1				X_attribute1
	,i.attribute2				X_attribute2
	,i.attribute3				X_attribute3
	,i.attribute4				X_attribute4
	,i.attribute5				X_attribute5
	,i.attribute6				X_attribute6
	,i.attribute7				X_attribute7
	,i.attribute8				X_attribute8
	,i.attribute9				X_attribute9
	,i.attribute10				X_attribute10
	,NULL					X_ei_comment
	,i.transaction_source			X_transaction_source
	,i.source_expenditure_item_id		X_source_exp_item_id
	,i.job_id				X_job_id
	,i.org_id				X_org_id
	,i.labor_cost_multiplier_name           X_labor_cost_multiplier_name
	,NULL					X_drccid
	,NULL					X_crccid
	,NULL					X_cdlsr1
	,NULL					X_cdlsr2
	,NULL					X_cdlsr3
	,NULL					X_gldate
	,i.burden_cost* -1			X_bcost
	,i.burden_cost_rate			X_bcostrate
	,i.system_linkage_function		X_etypeclass
	,i.burden_sum_dest_run_id		X_burden_sum_dest_run_id
   ,i.cost_ind_compiled_set_id   X_burden_Compile_set_id
   ,i.receipt_currency_amount    X_receipt_currency_amount
   ,i.receipt_currency_code      X_receipt_currency_code
   ,i.receipt_exchange_rate      X_receipt_exchange_rate
   ,i.denom_currency_code        X_denom_currency_code
   ,i.denom_raw_cost* -1         X_denom_raw_cost
   ,i.denom_burdened_cost* -1    X_denom_burdened_cost
   ,i.acct_currency_code         X_acct_currency_code
   ,i.acct_rate_date             X_acct_rate_date
   ,i.acct_rate_type             X_acct_rate_type
   ,i.acct_exchange_rate         X_acct_exchange_rate
   ,i.acct_raw_cost* -1          X_acct_raw_cost
   ,i.acct_burdened_Cost* -1     X_acct_burdened_cost
   ,i.acct_exchange_rounding_limit X_acct_exchange_rounding_limit
   ,i.project_currency_code      X_project_currency_code
   ,i.project_rate_date          X_project_rate_date
   ,i.project_rate_type          X_project_rate_type
   ,i.project_exchange_rate      X_project_exchange_rate
   ,i.CC_CROSS_CHARGE_CODE       CC_CROSS_CHARGE_CODE
   ,i.CC_PRVDR_ORGANIZATION_ID   CC_PRVDR_ORGANIZATION_ID
   ,i.CC_RECVR_ORGANIZATION_ID   CC_RECVR_ORGANIZATION_ID
   ,i.DENOM_TP_CURRENCY_CODE     DENOM_TP_CURRENCY_CODE
   ,i.DENOM_TRANSFER_PRICE       DENOM_TRANSFER_PRICE
   ,i.ACCT_TP_RATE_TYPE          ACCT_TP_RATE_TYPE
   ,i.ACCT_TP_RATE_DATE          ACCT_TP_RATE_DATE
   ,i.ACCT_TP_EXCHANGE_RATE      ACCT_TP_EXCHANGE_RATE
   ,i.ACCT_TRANSFER_PRICE        ACCT_TRANSFER_PRICE
   ,i.PROJACCT_TRANSFER_PRICE    PROJACCT_TRANSFER_PRICE
   ,i.CC_MARKUP_BASE_CODE        CC_MARKUP_BASE_CODE
   ,i.TP_BASE_AMOUNT             TP_BASE_AMOUNT
   ,i.CC_CROSS_CHARGE_TYPE       CC_CROSS_CHARGE_TYPE
   ,i.RECVR_ORG_ID               RECVR_ORG_ID
   ,decode(i.CC_CROSS_CHARGE_CODE,'B','N','X') CC_BL_DISTRIBUTED_CODE
   ,decode(i.CC_CROSS_CHARGE_CODE,'I','N','X') CC_IC_PROCESSED_CODE
   ,i.TP_IND_COMPILED_SET_ID     TP_IND_COMPILED_SET_ID
   ,i.TP_BILL_RATE               TP_BILL_RATE
   ,i.TP_BILL_MARKUP_PERCENTAGE  TP_BILL_MARKUP_PERCENTAGE
   ,i.TP_SCHEDULE_LINE_PERCENTAGE TP_SCHEDULE_LINE_PERCENTAGE
   ,i.TP_RULE_PERCENTAGE         TP_RULE_PERCENTAGE
   ,i.project_id                  X_project_id     -- Bugfix:2201207
   ,i.projfunc_currency_code      X_projfunc_currency_code
   ,i.projfunc_cost_rate_date     X_projfunc_cost_rate_date
   ,i.projfunc_cost_rate_type     X_projfunc_cost_rate_type
   ,i.projfunc_cost_exchange_rate X_projfunc_cost_exchg_rate
   ,i.assignment_id               X_assignment_id
   ,i.work_type_id                X_work_type_id
   ,i.tp_amt_type_code            X_tp_amt_type_code
   ,i.project_raw_cost* -1        x_project_raw_cost
   ,i.project_burdened_cost* -1   x_project_burdened_cost
    from pa_expenditure_items i
	,pa_expenditures e
    where 	i.system_linkage_function ||'' = 'OT'
      and	i.expenditure_id = e.expenditure_id
      and	e.incurred_by_person_id = R_Person_Id
      and	e.expenditure_ending_date = R_Expenditure_End_Date
      and	i.task_id = Temp_task
      and	i.expenditure_item_date = R_Expenditure_End_Date
      and	i.expenditure_type = R_Overtime_Exp_Type
      and	nvl(i.net_zero_adjustment_flag,'N') <> 'Y') LOOP

    i := i + 1;
    /*
       Multi-currency related changes:
       Get All the attributes from the parent ei and pass it to the reversed ei.
     */
    /*
       IC Changes: Get IC attribute from parent and pass to reversed ei.
    */
    Pa_Transactions.Loadei(
       X_expenditure_item_id          =>	c.X_expenditure_item_id
     , X_expenditure_id               =>	c.X_expenditure_id
     , X_expenditure_item_date        =>	c.X_expenditure_item_date
     , X_project_id                   =>	c.X_project_id  -- Bugfix : 2201207 NULL
     , X_task_id                      =>	c.X_task_id
     , X_expenditure_type             =>	c.X_expenditure_type
     , X_non_labor_resource           =>	c.X_non_labor_resource
     , X_nl_resource_org_id           =>	c.X_nl_resource_org_id
     , X_quantity                     =>	c.X_quantity
     , X_raw_cost                     =>	c.X_raw_cost
     , X_raw_cost_rate                =>	c.X_raw_cost_rate
     , X_override_to_org_id           =>	c.X_override_to_org_id
     , X_billable_flag                =>	c.X_billable_flag
     , X_bill_hold_flag               =>	c.X_bill_hold_flag
     , X_orig_transaction_ref         =>	c.X_orig_transaction_ref
     , X_transferred_from_ei          =>	c.X_transferred_from_ei
     , X_adj_expend_item_id           =>	c.X_adj_expend_item_id
     , X_attribute_category           =>	c.X_attribute_category
     , X_attribute1                   =>	c.X_attribute1
     , X_attribute2                   =>	c.X_attribute2
     , X_attribute3                   =>	c.X_attribute3
     , X_attribute4                   =>	c.X_attribute4
     , X_attribute5                   =>	c.X_attribute5
     , X_attribute6                   =>	c.X_attribute6
     , X_attribute7                   =>	c.X_attribute7
     , X_attribute8                   =>	c.X_attribute8
     , X_attribute9                   =>	c.X_attribute9
     , X_attribute10                  =>	c.X_attribute10
     , X_ei_comment                   =>	c.X_ei_comment
     , X_transaction_source           =>	c.X_transaction_source
     , X_source_exp_item_id           =>	c.X_source_exp_item_id
     , i                              =>	i
     , X_job_id                       =>	c.X_job_id
     , X_org_id                       =>	c.X_org_id
     , X_labor_cost_multiplier_name   =>	c.X_labor_cost_multiplier_name
     , X_drccid                       =>	c.X_drccid
     , X_crccid                       =>	c.X_crccid
     , X_cdlsr1                       =>	c.X_cdlsr1
     , X_cdlsr2                       =>	c.X_cdlsr2
     , X_cdlsr3                       =>	c.X_cdlsr3
     , X_gldate                       =>	c.X_gldate
     , X_bcost                        =>	c.X_bcost
     , X_bcostrate                    =>	c.X_bcostrate
     , X_etypeclass                   =>	c.X_etypeclass
     , X_burden_sum_dest_run_id       =>	c.X_burden_sum_dest_run_id
     , X_burden_compile_set_id        =>	c.X_burden_Compile_set_id
     , X_receipt_currency_amount      =>	c.X_receipt_currency_amount
     , X_receipt_currency_code        =>	c.X_receipt_currency_code
     , X_receipt_exchange_rate        =>	c.X_receipt_exchange_rate
     , X_denom_currency_code          =>	c.X_denom_currency_code
     , X_denom_raw_cost               =>	c.X_denom_raw_cost
     , X_denom_burdened_cost          =>	c.X_denom_burdened_cost
     , X_acct_currency_code           =>	c.X_acct_currency_code
     , X_acct_rate_date               =>	c.X_acct_rate_date
     , X_acct_rate_type               =>	c.X_acct_rate_type
     , X_acct_exchange_rate           =>	c.X_acct_exchange_rate
     , X_acct_raw_cost                =>	c.X_acct_raw_cost
     , X_acct_burdened_cost           =>	c.X_acct_burdened_cost
     , X_acct_exchange_rounding_limit =>	c.X_acct_exchange_rounding_limit
     , X_project_currency_code        =>	c.X_project_currency_code
     , X_project_rate_date            =>	c.X_project_rate_date
     , X_project_rate_type            =>	c.X_project_rate_type
     , X_project_exchange_rate        =>	c.X_project_exchange_rate
     , X_Cross_Charge_Type            =>  c.CC_CROSS_CHARGE_TYPE
     , X_Cross_Charge_Code            =>  c.CC_CROSS_CHARGE_CODE
     , X_Prvdr_organization_id        =>  c.CC_PRVDR_ORGANIZATION_ID
     , X_Recv_organization_id         =>  c.CC_RECVR_ORGANIZATION_ID
     , X_Recv_Operating_Unit          =>  c.RECVR_ORG_ID
     , X_Borrow_Lent_Dist_Code        =>  c.CC_BL_DISTRIBUTED_CODE
     , X_Ic_Processed_Code            =>  c.CC_IC_PROCESSED_CODE
     , X_Denom_Tp_Currency_Code       =>  c.DENOM_TP_CURRENCY_CODE
     , X_Denom_Transfer_Price         =>  c.DENOM_TRANSFER_PRICE
     , X_Acct_Tp_Rate_Type            =>  c.ACCT_TP_RATE_TYPE
     , X_Acct_Tp_Rate_Date            =>  c.ACCT_TP_RATE_DATE
     , X_Acct_Tp_Exchange_Rate        =>  c.ACCT_TP_EXCHANGE_RATE
     , X_ACCT_TRANSFER_PRICE          =>  c.ACCT_TRANSFER_PRICE
     , X_PROJACCT_TRANSFER_PRICE      =>  c.PROJACCT_TRANSFER_PRICE
     , X_CC_MARKUP_BASE_CODE          =>  c.CC_MARKUP_BASE_CODE
     , X_TP_BASE_AMOUNT               =>  c.TP_BASE_AMOUNT
     , X_TP_IND_COMPILED_SET_ID       =>  c.TP_IND_COMPILED_SET_ID
     , X_TP_BILL_RATE                 =>  c.TP_BILL_RATE
     , X_TP_BILL_MARKUP_PERCENTAGE    =>  c.TP_BILL_MARKUP_PERCENTAGE
     , X_TP_SCHEDULE_LINE_PERCENTAGE  =>  c.TP_SCHEDULE_LINE_PERCENTAGE
     , X_TP_RULE_PERCENTAGE           =>  c.TP_RULE_PERCENTAGE
     , p_assignment_id                =>  c.x_assignment_id
     , p_work_type_id                 =>  c.x_work_type_id
     , p_projfunc_currency_code       =>  c.x_projfunc_currency_code
     , p_projfunc_cost_rate_date      =>  c.x_projfunc_cost_rate_date
     , p_projfunc_cost_rate_type      =>  c.x_projfunc_cost_rate_type
     , p_projfunc_cost_exchange_rate  =>  c.x_projfunc_cost_exchg_rate
     , p_project_raw_cost             =>  c.x_project_raw_cost
     , p_project_burdened_cost        =>  c.x_project_burdened_cost
     , p_tp_amt_type_code             =>  c.x_tp_amt_type_code  );

    END LOOP;

    Pa_Transactions.InsItems(
	 R_P_User_ID
	,0 -- last_update_login
	,NULL -- module
	,NULL -- calling_process
	,i -- Rows
	,X_status
	,NULL -- gl_flag
	);

    Pa_Transactions.FlushEiTabs;
  END Reverse_Old_Overtime_Item;

  --
  -- Insert Expenditure Group and Expenditure only if
  -- not already inserted for person and week in this run
  --
  PROCEDURE Insert_Expenditure_And_Group(
		Expenditure_ID		 IN OUT NOCOPY number,
		R_P_User_ID			IN     number,
		R_P_Program_ID			IN     number,
		R_P_Request_ID			IN     number,
		R_P_Program_App_ID		IN     number,
		R_Person_Id			IN     number,
		R_Expenditure_End_Date		IN     Date,
		R_Overtime_Exp_Type		IN     varchar2,
		R_Organization			IN     number) IS
    Cycle_Start_Day number;
    l_org_id NUMBER:=  PA_MOAC_UTILS.get_current_org_id ; /*6317198*/

    /*  overtime_expenditure_group varchar2(20);  1756677 */
  BEGIN
    IF Exp_Group_Created_Flag <> 'Y' THEN

      -- Sel_Cycle_Day()
      SELECT   Exp_Cycle_Start_Day_Code
      INTO     Cycle_Start_Day
      FROM     PA_Implementations;

      -- Sel_Overtime_Expend_Group_Name()
      select 'PREMIUM - ' || to_char(R_P_Request_ID)
      into overtime_expenditure_group
      from sys.dual;
      -- Insert_Expenditure_Group()
      Pa_Transactions.InsertExpGroup(
	 Overtime_Expenditure_Group
	,'RELEASED'
	,trunc(sysdate) - to_number(to_char(sysdate-Cycle_Start_Day+1,'D')) + 7
	,'ST'
	,R_P_User_ID
	,NULL
	,NULL     /*6317198*/
	,l_org_id /*6317198*/ );
      Exp_Group_Created_Flag := 'Y';
    END IF;

    IF Exp_Created_Flag <> 'Y' THEN
      -- Sel_Expenditure_ID()
      select PA_EXPENDITURES_S.NEXTVAL INTO Expenditure_ID FROM sys.dual;

      Pa_Transactions.InsertExp(
	 		X_expenditure_id         => Expenditure_ID,
	      X_expend_status          => 'APPROVED',
	      X_expend_ending          => R_Expenditure_End_Date,
	      X_expend_class           => 'PT',
	      X_inc_by_person          => R_Person_Id,
	      X_inc_by_org             => R_Organization,
	      X_expend_group           => Overtime_Expenditure_Group,
	      X_entered_by_id          => R_P_User_ID,
	      X_created_by_id          => R_P_User_ID,
	      X_attribute_category     => NULL,
	      X_attribute1             => NULL,
         X_attribute2             => NULL,
         X_attribute3             => NULL,
         X_attribute4             => NULL,
         X_attribute5             => NULL,
         X_attribute6             => NULL,
         X_attribute7             => NULL,
         X_attribute8             => NULL,
         X_attribute9             => NULL,
         X_attribute10             => NULL,
	      X_description            => 'System created temporary overtime expenditure',
	      X_control_total          => NULL,
	      P_Org_Id                 => l_org_id /*6317198*/ );

      Exp_Created_Flag := 'Y';
    END IF;
  END Insert_Expenditure_And_Group;

  --
  -- Insert overtime items, determining whether the new overtime total
  -- is the same as the existing overtime total.
  --
  -- If the new OT total does NOT equal the existing overtime total,
  -- the existing overtime items are reversed and the new items are created.
  -- When the old items are reversed, the adjusted item and reversed item
  -- is marked with NET_ZERO_ADJUSTMENT_FLAG = 'Y' to note that the item
  -- is fully reversed.
  --
  -- A new overtime item is created only if the total hours <> 0.
  --
  PROCEDURE Insert_Overtime_Items(
		Temp_Existing_Hours		IN     number,
		Temp_Actual_Hours		IN     number,
		Temp_Task			IN     number,
		Temp_LCM			IN     varchar2,
		Expenditure_ID		 IN OUT NOCOPY number,
		R_P_User_ID			IN     number,
		R_P_Program_ID			IN     number,
		R_P_Request_ID			IN     number,
		R_P_Program_App_ID		IN     number,
		R_Person_Id			IN     number,
		R_Expenditure_End_Date		IN     date,
		R_Overtime_Exp_Type		IN     varchar2,
		R_Organization			IN     number) IS
    Any_Data_Flag varchar2(1);
    Job_ID number;
    X_expenditure_item_id number;
    X_status NUMBER;
    x_project_id     NUMBER;
    x_tp_amt_type_code   varchar2(100);
    x_assignment_id      number;
    x_assignment_name    varchar2(100);
    x_work_type_id       number;
    x_work_type_name     varchar2(100);
    x_return_status      varchar2(100);
    x_error_message_code varchar2(1000);
    x_projfunc_currency_code varchar2(30);

    cursor get_proj_id IS
    select p.project_id
	  ,p.projfunc_currency_code
    from pa_tasks t
	 ,pa_projects p
    where t.task_id = Temp_Task
    and   t.project_id = p.project_id;

  BEGIN

   /** Added EPP and project currency changes **/
    -- get the project id for the temp task
    If Temp_Task is not null then
	OPEN get_proj_id;
        FETCH get_proj_id into
		x_project_id
		,x_projfunc_currency_code;
        CLOSE get_proj_id;
    End if;
    -- if the work type profile is installed
    -- get the assignment details and work type details for the given project and tasks
    IF PA_UTILS4.is_exp_work_type_enabled = 'Y' then
    	PA_UTILS4.get_work_assignment
			    (p_person_id           => R_Person_Id
                             ,p_project_id         => x_project_id
                             ,p_task_id            => temp_task
                             ,p_ei_date            => R_Expenditure_End_Date
                             ,p_system_linkage     => 'OT'
                             ,x_tp_amt_type_code   => x_tp_amt_type_code
                             ,x_assignment_id      => x_assignment_id
                             ,x_assignment_name    => x_assignment_name
                             ,x_work_type_id       => x_work_type_id
                             ,x_work_type_name     => x_work_type_name
                             ,x_return_status      => x_return_status
                             ,x_error_message_code => x_error_message_code );
	-- donot error out generating OT lines even if the work type is not enabled
	-- or assignment is not scheduled. populate OT lines with NULL values
	IF x_return_status <> 'S' then
		x_work_type_id := NULL;
		x_assignment_id := NULL;
		x_tp_amt_type_code := NULL;
	END IF;



    ELSE
	      	x_tp_amt_type_code := NULL;
		x_assignment_id := NULL;
		x_work_type_id  := NULL;

    END IF;

    /** end of EPP and project currency changes **/


    IF Temp_Existing_Hours <> Temp_Actual_Hours THEN
      Insert_Expenditure_And_Group(
	 Expenditure_ID,
         R_P_User_ID,
         R_P_Program_ID,
         R_P_Request_ID,
         R_P_Program_App_ID,
         R_Person_Id,
         R_Expenditure_End_Date,
         R_Overtime_Exp_Type,
         R_Organization);
      Reverse_Old_Overtime_Item(
	 Expenditure_ID,
	 Temp_Task,
	 R_P_User_ID,
	 R_P_Request_ID,
	 R_P_Program_ID,
	 R_P_Program_App_ID,
	 R_Person_Id,
	 R_Expenditure_End_Date,
	 R_Overtime_Exp_Type);
      Update_Old_Overtime_Item(
	 Temp_Task,
	 R_P_User_ID,
	 R_P_Program_ID,
	 R_P_Request_ID,
	 R_P_Program_App_ID,
	 R_Person_Id,
	 R_Expenditure_End_Date,
	 R_Overtime_Exp_Type);

      IF Temp_Actual_Hours <> 0 THEN

        Job_ID := Get_Job_ID(Expenditure_ID);

        -- insert_exp_item()
	select PA_EXPENDITURE_ITEMS_S.NEXTVAL
	into X_expenditure_item_id
	from sys.dual;

   /*
      Multi-currency related changes:
      Pass Txn, Functional and Project currency
    */
---------------------------------------------------------------------
-- Bug 911108: Modified to put 'OT' into the expenditure type class
-- (system linkage) field
---------------------------------------------------------------------
   /* Not modified for IC, bcoz the IC attributes are determined by
      IC identification process.  The IC identification process will
      pick EI's that have cross_charge_code = P( which is the default
      for LOadEi API)
   */
   /*
    * IC related change:
    * Recvr_Org_Id is populated for the Overtime Item
    */
	Pa_Transactions.Loadei(
       X_expenditure_item_id          =>	X_expenditure_item_id
     , X_expenditure_id               =>	Expenditure_ID
     , X_expenditure_item_date        =>	R_Expenditure_End_Date
     , X_project_id                   =>	x_project_id  --Bugfix: 2201207 NULL
     , X_task_id                      =>	Temp_Task
     , X_expenditure_type             =>	R_Overtime_Exp_Type
     , X_non_labor_resource           =>	NULL
     , X_nl_resource_org_id           =>	NULL
     , X_quantity                     =>	Temp_Actual_Hours
     , X_raw_cost                     =>	NULL
     , X_raw_cost_rate                =>	NULL
     , X_override_to_org_id           =>	NULL
     , X_billable_flag                =>	'N'
     , X_bill_hold_flag               =>	'N'
     , X_orig_transaction_ref         =>	NULL
     , X_transferred_from_ei          =>	NULL
     , X_adj_expend_item_id           =>	NULL
     , X_attribute_category           =>	NULL
     , X_attribute1                   =>	NULL
     , X_attribute2                   =>	NULL
     , X_attribute3                   =>	NULL
     , X_attribute4                   =>	NULL
     , X_attribute5                   =>	NULL
     , X_attribute6                   =>	NULL
     , X_attribute7                   =>	NULL
     , X_attribute8                   =>	NULL
     , X_attribute9                   =>	NULL
     , X_attribute10                  =>	NULL
     , X_ei_comment                   =>	NULL
     , X_transaction_source           =>	NULL
     , X_source_exp_item_id           =>	NULL
     , i                              =>	1
     , X_job_id                       =>	Job_ID
     , X_org_id                       =>	G_org_id
/* Bug# 1483807 */
     , X_labor_cost_multiplier_name   =>	Temp_LCM
     , X_drccid                       =>	NULL
     , X_crccid                       =>	NULL
     , X_cdlsr1                       =>	NULL
     , X_cdlsr2                       =>	NULL
     , X_cdlsr3                       =>	NULL
     , X_gldate                       =>	NULL
     , X_bcost                        =>	NULL
     , X_bcostrate                    =>	NULL
     , X_etypeclass                   =>	'OT'
     , X_burden_sum_dest_run_id       =>	NULL
     , X_burden_compile_set_id        =>	NULL
     , X_receipt_currency_amount      =>	NULL
     , X_receipt_currency_code        =>	NULL
     , X_receipt_exchange_rate        =>	NULL
     , X_denom_currency_code          =>	OCurrCode
     , X_denom_raw_cost               =>	NULL
     , X_denom_burdened_cost          =>	NULL
     , X_acct_currency_code           =>	OCurrCode
     , X_acct_rate_date               =>	NULL
     , X_acct_rate_type               =>	NULL
     , X_acct_exchange_rate           =>	NULL
     , X_acct_raw_cost                =>	NULL
     , X_acct_burdened_cost           =>	NULL
     , X_acct_exchange_rounding_limit =>	NULL
     , X_project_currency_code        =>	OProjCurrCode
     , X_project_rate_date            =>	NULL
     , X_project_rate_type            =>	NULL
     , X_project_exchange_rate        =>	NULL
     , X_recv_operating_unit          =>  PA_UTILS2.GetPrjOrgId(NULL,temp_task)
     /** added EPP and project currency changes **/
     , p_assignment_id                =>  x_assignment_id
     , p_work_type_id                 =>  NULL /* Changed for labor costing enhancements */
     , p_projfunc_currency_code       =>  x_projfunc_currency_code
     , p_projfunc_cost_rate_date      =>  NULL
     , p_projfunc_cost_rate_type      =>  NULL
     , p_projfunc_cost_exchange_rate  =>  NULL
     , p_project_raw_cost             =>  NULL
     , p_project_burdened_cost        =>  NULL
     , p_tp_amt_type_code             =>  NULL  /* Changed for labor costing enhancements */
           );
     /** end of EPP and project currency changes **/
        Pa_Transactions.InsItems(
		 R_P_User_ID
		,0 -- last_update_login
		,NULL -- module
		,NULL -- calling_process
		,1 -- rows
		,X_status
		,NULL -- gl_flag
		);
        Pa_Transactions.FlushEiTabs;
      END IF;
    END IF;
  END Insert_Overtime_Items;

  --
  -- Calculate Overtime based on the totals and the compensation rule
  --
  PROCEDURE Calc_OT (
		Total_Hours			IN     number,
		Sunday				IN     number,
		Monday				IN     number,
		Tuesday				IN     number,
		Wednesday			IN     number,
		Thursday			IN     number,
		Friday				IN     number,
		Saturday			IN     number,
		Double_Time_Hours		IN OUT NOCOPY  number,
		Time_And_A_Half_Hours		IN OUT NOCOPY  number,
		Uncompensated_Hours		IN OUT NOCOPY  number,
		Extra_OT_Hours_1		IN OUT NOCOPY  number,
		Extra_OT_Hours_2		IN OUT NOCOPY  number,
		R_Rule_Set			IN     varchar2) IS

    PROCEDURE Calc_Daily_Overtime(
		 Day_Total			IN     number,
		 Double_Time_Hours		IN OUT NOCOPY  number,
		 Time_And_A_Half_Hours		IN OUT NOCOPY  number) IS
    BEGIN
      IF Day_Total > 12 THEN
        Double_Time_Hours := Double_Time_Hours + (Day_Total - 12);
        Time_And_A_Half_Hours := Time_And_A_Half_Hours + 4;
      ELSIF Day_Total > 8 THEN
        Time_And_A_Half_Hours := Time_And_A_Half_Hours + (Day_Total - 8);
      END IF;
    END Calc_Daily_Overtime;

  BEGIN
    -- Reset hours for every person/period pair
    Double_Time_Hours := 0;
    Time_And_A_Half_Hours := 0;
    Uncompensated_Hours := 0;
    Extra_OT_Hours_1 := 0;
    Extra_OT_Hours_2 := 0;

    IF R_Rule_Set = 'Compensated' THEN
      IF Total_Hours > 80 THEN
        Double_Time_Hours := Double_Time_Hours + (Total_Hours - 80);
        Time_And_A_Half_Hours := Time_And_A_Half_Hours + 40;
      ELSIF Total_Hours > 40 THEN
        Time_And_A_Half_Hours := Time_And_A_Half_Hours + (Total_Hours - 40);
      END IF;
    ELSIF R_Rule_Set = 'Exempt' THEN
      IF Total_Hours > 40 THEN
        Uncompensated_Hours := Uncompensated_Hours + (Total_Hours - 40);
      END IF;
    ELSIF R_Rule_Set = 'Hourly' THEN
      Calc_Daily_Overtime(Monday, Double_Time_Hours, Time_And_A_Half_Hours);
      Calc_Daily_Overtime(Tuesday, Double_Time_Hours, Time_And_A_Half_Hours);
      Calc_Daily_Overtime(Wednesday, Double_Time_Hours, Time_And_A_Half_Hours);
      Calc_Daily_Overtime(Thursday, Double_Time_Hours, Time_And_A_Half_Hours);
      Calc_Daily_Overtime(Friday, Double_Time_Hours, Time_And_A_Half_Hours);
      Double_Time_Hours := Double_Time_Hours + Saturday + Sunday;
--  Put other overtime rules below
--  elsif R_Rule_Set = 'Extra OT1'
--    ...
    END IF;
  END Calc_OT;


  -- ======================================================================
  --
  --   PUBLIC PROCEDURE/FUNCTIONS (entry points)
  --
  -- ======================================================================

  --
  -- Process different types of overtime for each compensation rule
  --
  PROCEDURE Process_Overtime(
		New_Expenditure_Created		   OUT NOCOPY  boolean,
		R_P_User_ID		 	IN     number,
		R_P_Program_ID			IN     number,
		R_P_Request_ID			IN     number,
		R_P_Program_App_ID		in     number,
		R_Person_Id			in     number,
		R_Expenditure_End_Date		IN     date,
		R_Overtime_Exp_Type		IN     varchar2,
		R_C_Double_Time_Hours		IN OUT NOCOPY  number,
		R_C_Time_And_A_Half_Hours	IN OUT NOCOPY  number,
		R_C_Uncompensated_Hours		IN OUT NOCOPY  number,
		R_C_Extra_OT_Hours_1		IN OUT NOCOPY  number,
		R_C_Extra_OT_Hours_2		IN OUT NOCOPY  number,
		R_Organization			in     number,
		R_Rule_Set			IN     varchar2) IS
    Total_Hours number;
    Sunday number;
    Monday number;
    Tuesday number;
    Wednesday number;
    Thursday number;
    Friday number;
    Saturday number;
    OT_PT_Exist boolean;
    Existing_Double_Time_Hours number;
    Existing_Half_Time_Hours number;
    Existing_Uncomp_Time_Hours number;
    Existing_Extra_OT_Hours_1 number;
    Existing_Extra_OT_Hours_2 number;
    Actual_Double_Time_Hours number;
    Actual_Half_Time_Hours number;
    Actual_Uncomp_Time_Hours number;
    Actual_Extra_OT_Hours_1 number;
    Actual_Extra_OT_Hours_2 number;
    Expenditure_ID number;
  BEGIN
      -- Main_Body()
      -- Reset for every person/period pair
      Exp_Created_Flag := 'N';

      -- Sel_Time_Totals()
      SELECT SUM(ITEM2.Quantity),
	     SUM(DECODE(TO_CHAR(ITEM2.Expenditure_Item_Date,'D'),
		 '1',ITEM2.Quantity,0)),
	     SUM(DECODE(TO_CHAR(ITEM2.Expenditure_Item_Date,'D'),
		 '2',ITEM2.Quantity,0)),
	     SUM(DECODE(TO_CHAR(ITEM2.Expenditure_Item_Date,'D'),
		 '3',ITEM2.Quantity,0)),
	     SUM(DECODE(TO_CHAR(ITEM2.Expenditure_Item_Date,'D'),
		 '4',ITEM2.Quantity,0)),
	     SUM(DECODE(TO_CHAR(ITEM2.Expenditure_Item_Date,'D'),
		 '5',ITEM2.Quantity,0)),
	     SUM(DECODE(TO_CHAR(ITEM2.Expenditure_Item_Date,'D'),
		 '6',ITEM2.Quantity,0)),
	     SUM(DECODE(TO_CHAR(ITEM2.Expenditure_Item_Date,'D'),
		 '7',ITEM2.Quantity,0))
      INTO   Total_Hours, Sunday, Monday, Tuesday, Wednesday,
	     Thursday, Friday, Saturday
      FROM   PA_Expenditure_Items ITEM2,
	     PA_Expenditures EXP2
      WHERE  EXP2.Incurred_By_Person_ID = R_Person_ID
        AND  EXP2.Expenditure_Ending_Date = R_Expenditure_End_Date
        AND  EXP2.Expenditure_Status_Code||'' = 'APPROVED'
        AND  EXP2.Expenditure_ID = ITEM2.Expenditure_ID
        AND  ITEM2.Quantity <> 0
	AND  ITEM2.System_Linkage_Function||''  = 'ST';

      -- Sel_Existing_Overtime() + Check_Zero_Existing_Overtime()
      select    nvl(sum(decode(ITEM.task_id,
		               OTaskID_Tab(1),ITEM.quantity,
		               0)),0),
	        nvl(sum(decode(ITEM.task_id,
		               OTaskID_Tab(2),ITEM.quantity,
		               0)),0),
	        nvl(sum(decode(ITEM.task_id,
		               OTaskID_Tab(3),ITEM.quantity,
		               0)),0),
	        nvl(sum(decode(ITEM.task_id,
		               OTaskID_Tab(4),ITEM.quantity,
		               0)),0),
	        nvl(sum(decode(ITEM.task_id,
		               OTaskID_Tab(5),ITEM.quantity,
		               0)),0)
      into	Existing_Double_Time_Hours,
		Existing_Half_Time_Hours,
		Existing_Uncomp_Time_Hours,
		Existing_Extra_OT_Hours_1,
		Existing_Extra_OT_Hours_2
      FROM	PA_expenditure_items ITEM
	       ,PA_expenditures EXP
      WHERE	EXP.Incurred_By_Person_Id  = R_Person_Id
        AND	EXP.Expenditure_Ending_Date = R_Expenditure_End_Date
        AND	ITEM.Expenditure_Id = EXP.Expenditure_Id
        AND	ITEM.Expenditure_Item_Date = R_Expenditure_End_Date
	AND	ITEM.System_Linkage_Function ||'' = 'OT';

      -- Calc_Overtime()
      Calc_OT(Total_Hours, Sunday, Monday, Tuesday, Wednesday,
	      Thursday, Friday, Saturday, Actual_Double_Time_Hours,
	      Actual_Half_Time_Hours, Actual_Uncomp_Time_Hours,
	      Actual_Extra_OT_Hours_1, Actual_Extra_OT_Hours_2, R_Rule_Set);
      R_C_Double_Time_Hours := Actual_Double_Time_Hours;
      R_C_Time_And_A_Half_Hours := Actual_Half_Time_Hours;
      R_C_Uncompensated_Hours := Actual_Uncomp_Time_Hours;
      R_C_Extra_OT_Hours_1 := Actual_Extra_OT_Hours_1;
      R_C_Extra_OT_Hours_2 := Actual_Extra_OT_Hours_2;

      -- Added by Sandeep Bharathan. We noticed that
      -- org_id was not populated while inserting exp items.

      if pa_utils.pa_morg_implemented = 'Y' then
            FND_PROFILE.GET ('ORG_ID', G_Org_Id);
      end if;

      -- End

      -- Process_Overtime(): double + half + uncomp
      -- process_double()
      FOR i in 1 .. 5 LOOP
        EXIT WHEN OTaskID_Tab(i) is NULL;
/* Bug# 1483807 */
        IF OTaskName_Tab(i) = 'Uncompensated' THEN
        Insert_Overtime_Items(
          Existing_Uncomp_Time_Hours,
          Actual_Uncomp_Time_Hours,
          OTaskID_Tab(i),
          OTaskLCM_Tab(i),
          Expenditure_ID,
          R_P_User_ID,
          R_P_Program_ID,
          R_P_Request_ID,
          R_P_Program_App_ID,
          R_Person_Id,
          R_Expenditure_End_Date,
          R_Overtime_Exp_Type,
          R_Organization);

        ELSIF OTaskName_Tab(i) = 'Time and Half' THEN
        Insert_Overtime_Items(
          Existing_Half_Time_Hours,
          Actual_Half_Time_Hours,
          OTaskID_Tab(i),
          OTaskLCM_Tab(i),
          Expenditure_ID,
          R_P_User_ID,
          R_P_Program_ID,
          R_P_Request_ID,
          R_P_Program_App_ID,
          R_Person_Id,
          R_Expenditure_End_Date,
          R_Overtime_Exp_Type,
          R_Organization);

        ELSIF OTaskName_Tab(i) = 'Double Time' THEN
        Insert_Overtime_Items(
	  Existing_Double_Time_Hours,
	  Actual_Double_time_Hours,
	  OTaskID_Tab(i),
	  OTaskLCM_Tab(i),
	  Expenditure_ID,
	  R_P_User_ID,
	  R_P_Program_ID,
	  R_P_Request_ID,
	  R_P_Program_App_ID,
	  R_Person_Id,
	  R_Expenditure_End_Date,
	  R_Overtime_Exp_Type,
	  R_Organization);
	END IF;
      END LOOP;

      New_Expenditure_Created := Exp_Created_Flag = 'Y';

  END Process_Overtime;

  --
  -- Fetch all overtime task ids.
  -- Called from BEFOREREPORT trigger so that if no 'OT' project or
  -- Double, Half, and Uncomp tasks exist, report will stop.
  --
  PROCEDURE Check_Overtime_Tasks_Exist(
		Overtime_Tasks_Exist		   OUT NOCOPY  boolean,
		R_ot_title_1			   OUT NOCOPY  varchar2,
		R_ot_title_2			   OUT NOCOPY  varchar2,
		R_ot_title_3			   OUT NOCOPY  varchar2,
		R_ot_title_4			   OUT NOCOPY  varchar2,
		R_ot_title_5			   OUT NOCOPY  varchar2) IS
    x_count number := 0;
  BEGIN
    /*
       Multi-currency related changes:
       Get project currency code
     */
    FOR c IN (
	SELECT	t.task_id overtime_task_id
        ,	t.labor_cost_multiplier_name overtime_LCM
	     ,	t.task_name overtime_task_name
        ,   p.project_currency_code proj_curr_code
        ,   p.projfunc_currency_code projfunc_currency_code
	FROM	pa_tasks t
   	,	pa_projects p
	WHERE	t.project_id = p.project_id
	  AND	p.segment1 = 'OT') LOOP
      EXIT WHEN x_count >= 5;
      x_count := x_count+1;
      OTaskID_Tab(x_count) := c.overtime_task_id;
      OTaskLCM_Tab(x_count) := c.overtime_LCM;
      OTaskName_Tab(x_count) := c.overtime_task_name;
      OProjCurrCode := c.proj_curr_code;
      OProjfuncCurrCode := c.projfunc_currency_code;
    END LOOP;

    FOR d IN x_count+1 .. 5 LOOP
      OTaskID_Tab(d) := NULL;
      OTaskLCM_Tab(d) := NULL;
      OTaskName_Tab(d) := NULL;
    END LOOP;

    /*
       Multi-currency related changes:
       Get Txn/Functional currency code
     */
    OCurrCode := pa_multi_currency.get_acct_currency_code;

    R_ot_title_1 := OTaskName_Tab(1);
    R_ot_title_2 := OTaskName_Tab(2);
    R_ot_title_3 := OTaskName_Tab(3);
    R_ot_title_4 := OTaskName_Tab(4);
    R_ot_title_5 := OTaskName_Tab(5);

   Overtime_Tasks_Exist := x_count > 0;
  EXCEPTION
     WHEN others THEN
       Overtime_Tasks_Exist := FALSE;
  END Check_Overtime_Tasks_Exist;

  --
  -- Create status record so labor distribution knows Report finished
  --
  PROCEDURE Create_Status_Record(
		R_P_User_ID			IN      number,
		R_P_Request_ID			IN      number,
		R_P_Program_ID			IN      number,
		R_P_Program_App_ID		IN      number) IS
  BEGIN
    INSERT INTO PA_Spawned_Program_Statuses
        (
	Last_Update_Date,
	Last_Updated_By,
        Creation_Date,
	Created_By,
        Request_ID,
	Program_ID,
	Program_Application_ID,
        Program_Update_Date
        )
    VALUES
        (
	SYSDATE,
	R_P_User_ID,
	SYSDATE,
        R_P_User_ID,
	R_P_Request_ID,
	R_P_Program_ID,
	R_P_Program_App_ID,
	SYSDATE
        );
  END Create_Status_Record;

END PA_CALC_OVERTIME;

/
