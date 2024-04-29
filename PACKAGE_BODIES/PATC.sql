--------------------------------------------------------
--  DDL for Package Body PATC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PATC" AS
/* $Header: PAXTTXCB.pls 120.20.12010000.9 2009/06/05 22:27:08 apaul ship $ */

     temp_status	VARCHAR2(30) := NULL;
     temp_bill_flag 	VARCHAR2(1)  := NULL;
     level_flag   VARCHAR2(1)  := NULL ;
     INVALID_DATA	EXCEPTION;
     G_TRX_SKIP_FLAG    VARCHAR2(1)  := NULL;

PROCEDURE print_message (p_msg  varchar2) IS

BEGIN

	pa_cc_utils.log_message('Log: '||substr(p_msg,1,250));
	--r_debug.r_msg('Log: '||p_msg);
	NULL;

END print_message;


--  =====================================================================
--  This procedure is called only after the item being validated passes
--  all validation checks.  It sets the return status parameter to NULL,
--  indicating the item is valid, and then determines the billability of
--  the item based on either the billable flag defined at any applicable
--  transaction controls or the task's billable flag.

        PROCEDURE set_billable_flag ( txn_cntrl_bill_flag  IN VARCHAR2
                                    , task_bill_flag       IN VARCHAR2 )
        IS
        BEGIN

	  temp_status := NULL;

          IF ( txn_cntrl_bill_flag = 'N' ) THEN
            temp_bill_flag := 'N';
          ELSE
            temp_bill_flag := task_bill_flag;
          END IF;

        END set_billable_flag;


-- This API prints the debug messages


--  =====================================================================
--  This procedure is the front-end API of the transaction controls stored
--  package.  It accepts the following as input parameters:
--		- project id
--              - task id
--              - expenditure item date
--              - non-labor resource (only for usage items)
--              - incurred_by person id
--              - quantity (optional)
--            It returns the following after validation:
--              - billable flag
--              - status code
--                   * NULL if item is valid
--                   * if item is invalid, the status code will be one of the
--                     following error messages:
--            PA_EX_QTY_EXIST      - quantity must be entered
--            PA_EXP_INV_PJTK      - invalid project/task
--            PA_EX_PROJECT_DATE   - item date not within active project dates
--            PA_EX_PROJECT_CLOSED - project is closed
--            PA_EXP_TASK_EFF      - item date not within active task dates
--            PA_EXP_TASK_STATUS   - task is not chargeable
--            PA_EXP_PJ_TC         - item violates project-level controls
--            PA_EXP_TASK_TC       - item violates task-level controls
--            PA_NO_VALID_ASSIGN   - item violates the PJRM controls

PROCEDURE get_status (
               X_project_id		IN NUMBER
		     , X_task_id		IN NUMBER
		     , X_ei_date		IN DATE
		     , X_expenditure_type	IN VARCHAR2
		     , X_non_labor_resource	IN VARCHAR2
		     , X_person_id		IN NUMBER
		     , X_quantity		IN NUMBER
		     , X_denom_currency_code    IN VARCHAR2
		     , X_acct_currency_code     IN VARCHAR2
		     , X_denom_raw_cost		IN NUMBER
		     , X_acct_raw_cost		IN NUMBER
		     , X_acct_rate_type		IN VARCHAR2
		     , X_acct_rate_date		IN DATE
		     , X_acct_exchange_rate	IN NUMBER
             , X_transfer_ei            IN NUMBER
             , X_incurred_by_org_id     IN NUMBER
             , X_nl_resource_org_id     IN NUMBER
             , X_transaction_source     IN VARCHAR2
             , X_calling_module         IN VARCHAR2
             , X_vendor_id              IN NUMBER
             , X_entered_by_user_id     IN NUMBER
             , X_attribute_category     IN VARCHAR2
             , X_attribute1             IN VARCHAR2
             , X_attribute2             IN VARCHAR2
             , X_attribute3             IN VARCHAR2
             , X_attribute4             IN VARCHAR2
             , X_attribute5             IN VARCHAR2
             , X_attribute6             IN VARCHAR2
             , X_attribute7             IN VARCHAR2
             , X_attribute8             IN VARCHAR2
             , X_attribute9             IN VARCHAR2
             , X_attribute10            IN VARCHAR2
		     , X_attribute11		IN VARCHAR2
		     , X_attribute12		IN VARCHAR2
		     , X_attribute13 		IN VARCHAR2
		     , X_attribute14		IN VARCHAR2
	         , X_attribute15 		IN VARCHAR2
		     , X_msg_application	IN OUT NOCOPY VARCHAR2
	         , X_msg_type		OUT NOCOPY VARCHAR2
		     , X_msg_token1		OUT NOCOPY VARCHAR2
		     , X_msg_token2		OUT NOCOPY VARCHAR2
		     , X_msg_token3		OUT NOCOPY VARCHAR2
		     , X_msg_count		OUT NOCOPY NUMBER
		     , X_status			OUT NOCOPY VARCHAR2
		     , X_billable_flag  	OUT NOCOPY VARCHAR2
             , p_projfunc_currency_code  IN VARCHAR2
             , p_projfunc_cost_rate_type IN VARCHAR2
             , p_projfunc_cost_rate_date IN DATE
             , p_projfunc_cost_exchg_rate IN NUMBER
             , p_assignment_id           IN  NUMBER
             , p_work_type_id            IN  NUMBER
		     , p_sys_link_function       IN VARCHAR2
		     , P_Po_Header_Id            IN  NUMBER     default null -- PA.M/CWK
		     , P_Po_Line_Id              IN  NUMBER     default null -- PA.M/CWK
		     , P_Person_Type             IN  VARCHAR2   default null -- PA.M/CWK
		     , P_Po_Price_Type           IN  VARCHAR2   default null -- PA.M/CWK
		     , P_Document_Type           IN  VARCHAR2   default null -- Added these for R12
		     , P_Document_Line_Type      IN  VARCHAR2   default null
		     , P_Document_Dist_Type      IN  VARCHAR2   default null
		     , P_pa_ref_num1             IN  NUMBER     default null
		     , P_pa_ref_num2             IN  NUMBER     default null
		     , P_pa_ref_num3             IN  NUMBER     default null
		     , P_pa_ref_num4             IN  NUMBER     default null
		     , P_pa_ref_num5             IN  NUMBER     default null
		     , P_pa_ref_num6             IN  NUMBER     default null
		     , P_pa_ref_num7             IN  NUMBER     default null
		     , P_pa_ref_num8             IN  NUMBER     default null
		     , P_pa_ref_num9             IN  NUMBER     default null
		     , P_pa_ref_num10            IN  NUMBER     default null
		     , P_pa_ref_var1             IN  VARCHAR2   default null
		     , P_pa_ref_var2             IN  VARCHAR2   default null
		     , P_pa_ref_var3             IN  VARCHAR2   default null
		     , P_pa_ref_var4             IN  VARCHAR2   default null
		     , P_pa_ref_var5             IN  VARCHAR2   default null
		     , P_pa_ref_var6             IN  VARCHAR2   default null
		     , P_pa_ref_var7             IN  VARCHAR2   default null
		     , P_pa_ref_var8             IN  VARCHAR2   default null
		     , P_pa_ref_var9             IN  VARCHAR2   default null
		     , P_pa_ref_var10            IN  VARCHAR2   default null)

IS


    level_flag_local    varchar2(1) := NULL; /* Added against bug 674526 */
    ----p_person_id         NUMBER ;            /*2188422*/
  /*l_sys_link_func     VARCHAR2(100):= 'XX'; Bug# 2955795*/

    p_msg_type          VARCHAR2(1) ;      /*2188422*/
    Temp_allow_unscheduled_exp   varchar2(1) := NULL;
    Temp_assignment_id  NUMBER ;
    l_check_pjrm_tc_flag VARCHAR2(1) := 'N';
    l_return_string      VARCHAR2(1000) := 'X'  ;
    temp_msg_type           VARCHAR2(1000);
    temp_msg_token1      VARCHAR2(1000);
    temp_msg_token2      VARCHAR2(1000);
    temp_msg_token3      VARCHAR2(1000);
    temp_msg_count       NUMBER ;
    temp_status          VARCHAR2(1000);
    l_return_status_code  VARCHAR2(1);
    l_err_msg_code        VARCHAR2(80);

    --Bug 3017533
    L_BeforeCE_AsgnId     NUMBER;

    /* added for bug#3088249 */
    l_pa_date DATE;
    l_prvdr_org_id NUMBER;
    /* Added for bug 3681318 */
    l_CURRENT_EMPLOYEE_FLAG varchar2(1);
    l_CURRENT_NPW_FLAG VARCHAR2(1);
    l_person_type VARCHAR2(10);
    l_job_id NUMBER ; -- Added for bug 4044057
    l_ac_termination_date   per_periods_of_service.actual_termination_date%type;  /*Basebug#4604614 (BaseBug#4118885) */

-- This cursor selects all applicable task-level transaction controls

	CURSOR task_level_tc IS       /*2188422*/ /*Bug# 2955795:Removed c_sys_link_func as it is not reqd*/
          SELECT
                  tc.task_id
          ,       tc.person_id
          ,       tc.expenditure_category
          ,       tc.expenditure_type
          ,       tc.non_labor_resource
          ,       tc.chargeable_flag
          ,       tc.billable_indicator
          ,       tc.SCHEDULED_EXP_ONLY
	      ,       tc.employees_only_flag  -- PA.M/CWK changes
	      ,       tc.workplan_res_only_flag -- PA.M/Task Assignment changes
            FROM
                  pa_transaction_controls tc
           WHERE
                  tc.project_id = X_project_id
             AND  ( tc.task_id is null
                   OR
                   tc.task_id = X_task_id
                  )
	       /******** Bug fix :2345895 Start  donot modify refer to bug for details
                AND  ( tc.person_id IS NULL these lines are commented out for bug fix 2345895
                     or or c_person_id  = -9999  )  --Added for bug# 2188422
                     Commented for bug# 2188422
                    OR
                    (X_person_id is NOT NULL and  --Added for # 1652082
                    tc.person_id = X_person_id )
                    OR                   -- Added or clause for # 1652082
                    (X_vendor_id is NOT NULL and
                    X_person_id is NULL)
                    )
		***END of bug fix 2345895 ********/
         	/*AND ((p_sys_link_function = 'VI'Commented for bug 5735180*/        /*Bug# 2955795: Replaced c_sys_link_func by p_sys_link_function*/
                /*        AND (tc.expenditure_category is NOT NULL
                            OR tc.expenditure_type is NOT NULL
                            OR tc.task_id is NOT NULL
                          )
		      AND tc.person_id is null -- Added for bug 2942492
		      AND tc.non_labor_resource is null) Commented for Bug 5735180*/ /*  Added for bug 2942492, added ( in start and )
                                                             for bug 2939224  */
                   /* OR Commented for bug5735180 */ /* Added for bug#2939224 */
                   /* Added VI following condition for bug 5735180*/
               AND ( --Added for Bug 5735180
                    (p_sys_link_function in ('USG', 'PJ','VI') AND ((tc.person_id is NULL) OR ((X_person_id is NOT NULL) AND
                                                                                          (X_person_id = tc.person_id)))) -- Modified for bug 4585740
                      OR
                          ( nvl(p_sys_link_function,'-99') NOT IN ('VI', 'USG', 'PJ')  /* Bug 5721949 */
                                    /*Bug# 2955795: Replaced c_sys_link_func by p_sys_link_function*/
                                    /* Bug 2939224-Added not in USG and PG and VI */
                            AND (tc.person_id is NULL OR
                                 /**tc.person_id = tc.person_id Bug 2467454 **/
                                 tc.person_id = x_person_id
                                )
                          )
                    )
               /** Bug fix :2345895 End  **/
             AND  (    tc.expenditure_category IS NULL
                    OR tc.expenditure_category =
                         ( SELECT expenditure_category
                             FROM pa_expenditure_types
                            WHERE expenditure_type = X_expenditure_type ) )
             AND  (    tc.expenditure_type IS NULL
                    OR tc.expenditure_type = X_expenditure_type )
             AND  (    tc.non_labor_resource IS NULL
                    OR tc.non_labor_resource = X_non_labor_resource )
             AND  X_ei_date BETWEEN tc.start_date_active
                                AND nvl( tc.end_date_active, X_ei_date )
          GROUP BY
                  tc.task_id
	      ,       decode(p_sys_link_function,'VI',0, 'USG', 0, 'PJ', 0, tc.person_id)  -- for VI group by task,exp_cat,exp_tpe /*2955795*/ /* Added USG and PJ here as no grouping on person_id is required for these sys links */
          /*** ,  tc.person_id commented for bug fix :2345895 **/-- for <> VI group by task,person,exp_cat,exp_type
          ,       tc.expenditure_category
          ,       tc.expenditure_type
          ,       tc.non_labor_resource
          ,       tc.start_date_active
          ,       tc.end_date_active
          ,       tc.chargeable_flag
	      ,       tc.billable_indicator
          ,       tc.SCHEDULED_EXP_ONLY
	      ,       tc.employees_only_flag -- PA.M/CWK changes
	      ,       tc.workplan_res_only_flag -- PA.M/Task Assignment changes
	      ,       tc.person_id
          ORDER BY tc.task_id;

/* Commented for bug 2957441 ,decode(c_sys_link_func,'VI',nvl(tc.person_id,0),0); */

-- This cursor selects project/task information

        CURSOR project_info IS
          SELECT
                  p.project_status_code
          ,       nvl( p.start_date, X_ei_date )            p_start_date
          ,       nvl( p.completion_date, X_ei_date )       p_end_date
          ,       nvl( p.limit_to_txn_controls_flag, 'N' )  p_limit_flag
          ,       nvl( p.template_flag, 'N')                p_template_flag
          ,       nvl( t.chargeable_flag, 'N' )             t_chargeable_flag
          ,       nvl( t.billable_flag, 'N' )               t_billable_flag
          ,       nvl( t.start_date, X_ei_date )            t_start_date
          ,       nvl( t.completion_date, X_ei_date )       t_end_date
          ,       nvl( t.limit_to_txn_controls_flag, 'N' )  t_limit_flag
          ,       t.retirement_cost_flag                    t_ret_cost_flag        -- PA.L Retirement Cost Processing
          ,       pt.project_type_class_code                p_proj_typ_class_code  -- PA.L Retirement Cost Processing
          ,       nvl(p.assign_precedes_task, 'N')          p_assign_precedes_task -- Bug 3017533
	    FROM
		  pa_tasks t
	  ,	  pa_projects_all p
          ,       pa_project_types_all pt                                          -- PA.L Retirement Cost Processing
	   WHERE
		  t.task_id = X_task_id
	     AND  p.project_id = t.project_id
	     AND  p.project_id = X_project_id
             AND  p.project_type = pt.project_type                                -- PA.L Retirement Cost Processing
             AND  p.org_id = pt.org_id ;                                          -- For the Bug 5368274.Reverted the
                                                                                  -- fixes of bug 3989402.


        tc		task_level_tc%ROWTYPE;

	proj		project_info%ROWTYPE;

   patcx_bill_flag  VARCHAR2(1);

   X_org_id         NUMBER(15)    DEFAULT NULL;

--  =====================================================================
--  This procedure sets the return status parameter to a particular message
--  name and raises the INVALID_DATA exception which stops all processing.

        PROCEDURE return_error ( msg_name  IN VARCHAR2)
        IS
        BEGIN
          -- Do not set status and billable flag to NULL if it is called
          -- from PAVVIT. This done to reduce rejections during transfer.
          -- For more Info Refer Bug# 290684 or Incident# 81149.

          -- Bug 987539: If the calling module is transferring records from
          -- AP, we do not report any error.  PAAPIMP is the only module
          -- which transfers records from AP
          IF ( X_calling_Module <> 'PAAPIMP')
		    OR  -- added this for bug fix :2345895
	         ( X_calling_Module =  'PAAPIMP' and Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' )  THEN
	           print_message('PATC ERROR:'||msg_name);
               X_status := msg_name;
               -- Begin bug 4518893
               If ( nvl(X_msg_type,'W') = 'E' ) THEN
                    X_billable_flag := NULL;
               End If;
               -- End bug 4518893
            RAISE INVALID_DATA;
          END IF;

        END return_error;



--  =====================================================================
--  This procedure checks if a quantity has been entered for VENDOR INVOICE
--  items having an expenditure type where a cost rate is required.

        PROCEDURE check_quantity
        IS
	   dummy		NUMBER;
        BEGIN
          SELECT  count(1)
            INTO  dummy
            FROM  dual
           WHERE NOT EXISTS
                   ( SELECT  1
                       FROM  pa_expend_typ_sys_links etsl
                           , pa_expenditure_types    et
                      WHERE  etsl.expenditure_type = et.expenditure_type
                        AND  etsl.expenditure_type = X_expenditure_type
                        AND  etsl.system_linkage_function = 'VI'
                        AND  et.cost_rate_flag = 'Y' );

          IF ( dummy = 0 ) THEN
            IF ( X_quantity IS NULL ) THEN
              return_error( 'PA_EX_QTY_EXIST' );
            END IF;
          END IF;

        END check_quantity;

--  =====================================================================
--  This procedure checks whether expenditure type is active on the
--  expenditure Item date.

        PROCEDURE check_etype_date
        IS
	     dummy		NUMBER;
        BEGIN
          SELECT  count(1)

            INTO  dummy
          FROM pa_expenditure_types  et
          WHERE et.expenditure_type = X_expenditure_type
            AND X_ei_date BETWEEN et.start_date_active AND
                           nvl( et.end_date_active, X_ei_date ) ;

          IF ( dummy = 0 ) THEN

            G_PREV_EXP_TYPE_ACTIVE :=0;
            return_error('EXP_TYPE_INACTIVE') ;

          ELSE
            G_PREV_EXP_TYPE_ACTIVE :=1;

          END IF ;

        END check_etype_date;

--  =====================================================================
--  This procedure checks whether non_labor_resource org is active  on the
--  expenditure Item date.

        PROCEDURE check_nlro_date
        IS
	     dummy		NUMBER;
        BEGIN
          SELECT  count(1)
            INTO  dummy
            FROM  pa_organizations_v
           WHERE  organization_id = X_nl_resource_org_id
             AND  X_ei_date between date_from and nvl(date_to,X_ei_date);
          IF ( dummy = 0 ) THEN
            IF pa_trx_import.g_skip_tc_flag <> 'Y' then /* Added for Bug # 2170237 */
              return_error('PA_TR_EPE_NLR_ORG_NOT_ACTIVE') ;
            END IF ; /* Added for Bug # 2170237 */
          END IF ;

        END check_nlro_date;

--  =====================================================================
--  This procedure checks for the level of transaction control

        PROCEDURE check_level
        IS
	       dummy		NUMBER;
        BEGIN
          SELECT  count(1)
            INTO  dummy
            FROM  dual
           WHERE EXISTS
                   ( SELECT  1
                     FROM pa_transaction_controls
                     WHERE project_id = X_project_id
                     AND task_id    = X_task_id ) ;

          IF ( dummy = 0 ) THEN

            G_PREV_LEVEL := 'P';
            level_flag   := 'P' ;
          ELSE

            G_PREV_LEVEL := 'T';
            level_flag   := 'T' ;
          END IF;

        END check_level;

-- ==========================================================================
 /*Added check_person_id() for bug# 2188422*/
-- This Procedure checks for the for valid person Id if the system linkage is ER
 /*2955795 :Restructured this procedure and replaced the existing logic to determine if a transaction
 belongs to Expense Report or Supplier invoices on the basis of system_linkage attached to expenditure type*/
 /*This is done in view of new IN parameter to get_status() - p_sys_link_function storing 'VI'/'ER' for
  Expense Report/Supplier invoices ,which was not there earlier .*/
 /*For earlier logic please refer to previous versions*/

    PROCEDURE check_person_id      /*Bug# 2955795*/
       IS
           dummy   NUMBER;
           dummy2   NUMBER; /* bug # 2426506 */

    BEGIN
      IF p_sys_link_function ='ER' THEN       /*2955795*/

          /* bug # 2426506 */
         SELECT count(*)
         INTO  dummy2
         FROM  po_vendors_ap_v
         WHERE vendor_id  = x_vendor_id
          AND vendor_type_lookup_code = 'EMPLOYEE'
         AND   employee_id is NULL ;

         SELECT count(*)
         INTO  dummy
         FROM  po_vendors_ap_v
         WHERE vendor_id  = x_vendor_id
         AND   employee_id is NULL ;

        /* bug # 2426506, added if condition */
         IF (dummy2<>0) and p_sys_link_function='ER' then       /*2955795 :Added p_sys_link_function condition*/
              x_msg_type :='E';
              return_error('PA_ER_CANNOT_XFACE_EMP');
         ELSE
          IF ( dummy <> 0  ) and p_sys_link_function = 'ER' then     /*2955795 :Added p_sys_link_function condition*/
              x_msg_type :='E';
              return_error( 'PA_ER_CANNOT_XFACE');
          End IF;
         END IF;
      END IF; /*p_sys_link_function ='ER' :Bug# 2955795*/
     END check_person_id; /*2955795*/
/*End of changes for bug# 2188422*/
-- ======================================================================+
/** This API checks the person is valid or not for the given
 ** Expenditure item date . For expense Reports the x_person_id will be
 ** NULL so derive the person_id based on vendor and check whether the person
 ** is active or Not
 ** Bug fix :2483863 **/
 FUNCTION check_active_employee (p_vendor_id   Number
                                ,p_person_id   Number
                                ,p_Ei_Date     Date ) Return varchar2 IS

        l_return_string  varchar2(10) := 'Y';
        l_return_number  Number := NULL;
        l_emp_number     Number := Null;
          CURSOR cur_emp  IS
                  SELECT vend.employee_id
                  FROM  po_vendors vend
                  WHERE  vend.vendor_id = p_vendor_id
                  AND   p_ei_date BETWEEN nvl(vend.start_date_active,p_ei_date) AND
                           nvl( vend.end_date_active, trunc(sysdate) ) ;

 BEGIN
           If nvl(p_person_id,0) = 0  then
                OPEN cur_emp;
                FETCH cur_emp INTO l_emp_number;
                CLOSE cur_emp;
           Else
                l_emp_number := p_person_id;
           End If;

	   If l_emp_number is NOT NULL then

           	l_return_number := pa_utils.GetEmpOrgId( l_emp_number, p_ei_date );
           	If l_return_number is NULL then
                	l_return_string :=  'N';
           	End If;
	   End If;
           Return l_return_string;

 END check_active_employee;
 /** End of bug fix : 2483863 ***/

-- ======================================================================+
/* Added check_etype_eclass for bug 2831477 */

  PROCEDURE  check_etype_eclass( X_etype  IN VARCHAR2
                             , X_system_linkage IN VARCHAR2 ) IS
  BEGIN

    If (nvl(G_EXP_TYPE,'NULL') <> X_etype OR nvl(G_EXP_TYPE_SYS_LINK,'NULL') <> X_system_linkage) then

       SELECT
               system_linkage_function
              ,start_date_active
              ,end_date_active
         INTO
               G_EXP_TYPE_SYS_LINK
              ,G_EXP_TYPE_START_DATE
              ,G_EXP_TYPE_END_DATE
         FROM  pa_expend_typ_sys_links
        WHERE  system_linkage_function = X_system_linkage
          AND  expenditure_type        = X_etype ;


        G_EXP_TYPE := X_etype;

    End If;

  Exception
    When No_Data_Found Then
        G_EXP_TYPE_SYS_LINK := Null;
        G_EXP_TYPE_START_DATE := Null;
        G_EXP_TYPE_END_DATE := Null;
    When Others Then
        Raise;

  END check_etype_eclass;

--=====================================================================+
/* Added this procedure for bug 2942492 */

/* Added parameter p_sys_link for bug 2939224 */

FUNCTION check_person_level_TCs(p_sys_link in varchar2,
                                p_project_id IN NUMBER,
                                p_task_id IN NUMBER DEFAULT NULL,
                                x_person_id in NUMBER DEFAULT NULL) -- added the parameter x_person_id for bug 4585740
RETURN BOOLEAN

IS

TC_EXISTS NUMBER;
l_tc_count NUMBER; /* Added for bug4778164 */

BEGIN
/* Starts - Added for bug4778164 */
l_tc_count := 0;

If p_task_id is not null then

  SELECT count(1) INTO l_tc_count
  From pa_transaction_controls
  WHERE project_id = p_project_id
  AND task_id = p_task_id;

Else

  SELECT count(1) INTO l_tc_count
  From pa_transaction_controls
  WHERE project_id = p_project_id;

End If;
/* Ends - Added for bug4778164 */
/*Commented the following for bug 5735180
If ( l_tc_count > 0  AND p_sys_link = 'VI') THEN */  /* Added l_tc_count for bug4778164 */ -- added for bug 2939224
/* Commented the following for bug 5735180

     IF p_task_id is not null then

          print_message(' p  '||p_project_id||'  t  '||p_task_id);

          SELECT 1 INTO TC_EXISTS
          From pa_transaction_controls
          WHERE project_id = p_project_id
          AND task_id = p_task_id
          AND (expenditure_category IS NOT NULL OR expenditure_type IS NOT NULL)
          AND person_id IS NULL
          AND non_labor_resource IS NULL
          AND ROWNUM =1;

     ELSE

          SELECT 1 INTO TC_EXISTS
          FROM pa_transaction_controls
          WHERE project_id = p_project_id
          AND task_id is NULL
          AND (expenditure_category IS NOT NULL OR expenditure_type IS NOT NULL)
          AND person_id IS NULL
          AND non_labor_resource IS NULL
          AND ROWNUM =1;

     END IF;
*/
     /* Code added for bug 2939224 */
/*Commented and added VI also for bug 5735180
ELSIF (( l_tc_count > 0 ) AND (p_sys_link = 'USG' or p_sys_link = 'PJ')) THEN   Added l_tc_count for bug4778164 */
IF (( l_tc_count > 0 ) AND (p_sys_link = 'USG' or p_sys_link = 'PJ' or p_sys_link = 'VI')) THEN  /* Added l_tc_count for bug4778164 */

     IF p_task_id is not null then

          print_message(' p  '||p_project_id||'  t  '||p_task_id);

          SELECT 1 INTO TC_EXISTS
          FROM pa_transaction_controls
          WHERE project_id = p_project_id
          AND task_id = p_task_id
          -- Commented for bug 4585740
          -- AND (expenditure_category IS NOT NULL OR expenditure_type IS NOT NULL)
          AND (person_id IS NULL OR x_person_id is NOT NULL) -- Modified for bug 4585740
          AND ROWNUM =1;

     ELSE

          SELECT 1 INTO TC_EXISTS
          FROM pa_transaction_controls
          WHERE project_id = p_project_id
          AND task_id is NULL
          -- Commented for bug 4585740
          -- AND (expenditure_category IS NOT NULL OR expenditure_type IS NOT NULL)
          AND (person_id IS NULL OR x_person_id is NOT NULL) -- Modified for bug 4585740
          AND ROWNUM =1;

  END IF;

END IF;

/* end of code added for bug 2939224 */
RETURN TRUE;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN FALSE;

END;
/*======================================================================*/
/**Bug# 3494771 :
 **This procedure is to check if a given expenditure_type is of
 **system_linkage_function 'VI' .
 **This check is required for validation of exp. type when user
 **enters it manually in IProcurement.
*/
PROCEDURE check_exp_type
        IS
  dummy                NUMBER;
  BEGIN

   dummy :=0;

   SELECT  count(1)
    INTO  dummy
    FROM  dual
    WHERE EXISTS
              ( SELECT  1
                 FROM  pa_expend_typ_sys_links etsl
                     , pa_expenditure_types    et
                  WHERE  etsl.expenditure_type = et.expenditure_type
                    AND  etsl.expenditure_type = X_expenditure_type
                    AND  etsl.system_linkage_function = 'VI'
                 );

    IF ( dummy = 0 ) THEN
     return_error( 'PA_INVALID_EXPENDITURE_TYPE' );
    END IF;

  END check_exp_type;
/*End of changes for bug# 3494771*/
/*=====================================================================*/

-- This is the start of the get_status procedure logic

  BEGIN

	/** assign the in param assignment id to global variable **/
	PATC.G_OVERIDE_ASSIGNMENT_ID := p_assignment_id;
	print_message('Stage:PATC:10.10.001 GET_STATUS API');
	print_message('IN PARAMS : Project_id:['||X_project_id||'] Task_id :['||X_task_id||'] EI_date:['||X_ei_date||
                      ']Exp Type:['||X_expenditure_type||'] non_labor_resource:['||X_non_labor_resource||']'||
                      'person_id:['||X_person_id||']quantity:['||X_quantity||']denom_currency_code:['||
                      X_denom_currency_code||']acct_currency_code:['||X_acct_currency_code||']transfer_ei:['||
                      X_transfer_ei||']incurred_by_org_id:['||X_incurred_by_org_id||']vendor_id:['||X_vendor_id||
                      ']System linkage:['||P_sys_link_function||'] assignment_id:['||p_assignment_id||
		              ']work_type_id:['||p_work_type_id||']Billable_flag:['||x_billable_flag||']'||
		              'calling module :['||X_Calling_Module||']Transaction_source:['||X_transaction_source||
                      ']TC skip Flag:['||Pa_Trx_Import.G_Skip_Tc_Flag||']');

	/** Initialize the transaction controls skip flag for each call
      *  if the calling module is PAAPIMP and transaction source is AP EXPENSE
      *  we should revalidate the transaction at the time of import.and override the
      *  Pa_Trx_Import.G_Skip_Tc_flag  **/
	G_TRX_SKIP_FLAG := nvl(Pa_Trx_Import.G_Skip_Tc_Flag,'N');

    /* Start- Commented the following code to override the skip tc flag for bug 4549869
	IF ( x_calling_module = 'PAAPIMP' and x_transaction_source = 'AP EXPENSE') Then */
		/** If the expenditure type is part of ER and VI then we should revalidate the
            the transaction for expense report during import **/
        /*Bug# 2955795 :This check is not required since we have p_sys_link_function now to
                 store 'ER'/'VI' for Expense Report/Supplier Invoice*/

  	    /*check_person_id(p_mode => 'SYS_LINK_CHECK'
                         ,x_return_string => l_return_string );
        If l_return_string = 'VI,ER,' or l_return_string = 'ER,VI,' then  Bug# 2955795*/
         /*
         If p_sys_link_function ='ER' Then                  Bug# 2955795*/
		 /*	 print_message('Overriding the Pa_Trx_Import.G_Skip_Tc_Flag ');
			 Pa_Trx_Import.G_Skip_Tc_Flag := 'N';
         End if;
	End If;
    Ends- Commented the following code to override the skip tc flag for bug 4549869 */
    X_msg_type := 'E'; -- Initiliaze Error/Warning indicator parameter.

    -- Calling Module    PAXPRRPE - Exp Adjustments GUI Form
    --                   PAXINADI - Invoice Review GUI Form

    IF ( (X_Calling_Module not in ('PAXPRRPE', 'PAXINADI')) AND
         (substr(X_Calling_Module, 1, 2) <> 'PO' )) THEN

         -- No Need to do quanitity checks for calls from GUI Forms
         print_message('Stage:PATC:10.10.002');
         IF P_sys_link_function = 'VI' THEN
                    check_quantity;
         END IF;
    END IF;

    /* Bug# 3494771 : If calling module is from IProcurement then we need to
       validate expenditure type maually entered by user */
    IF X_Calling_Module ='POWEBREQ'  THEN
         print_message('Stage:PATC:10.10.02.5');
         check_exp_type;
    END IF;
    /*End of changes for Bug# 3494771*/

    -- Fix for Bug # 801194. For related Items, we skip the validations for
    -- expenditure type date since the exp type for related items are created only
    -- for 1 day. We just go thru the task level transaction control and the
    -- tc_extension so that client controls and TC are not ignored

    IF X_Calling_Module <> 'CreateRelatedItem' THEN

	     print_message('Stage:PATC:10.10.003');

         IF (nvl(G_PREV_EI_DATE,trunc(sysdate-100000)) <> X_ei_date OR nvl(G_PREV_EXP_TYPE,'NO EXP TYPE') <> X_expenditure_type) THEN

              G_PREV_EI_DATE   := X_ei_date;
              G_PREV_EXP_TYPE  := X_expenditure_type;
              check_etype_date ;

         ELSE

              IF( G_PREV_EXP_TYPE_ACTIVE    =1) THEN
                   NULL;
              ELSIF (G_PREV_EXP_TYPE_ACTIVE =0) THEN
                   return_error('EXP_TYPE_INACTIVE') ;
              END IF;

         END IF;

         /* Added the call to check_etype_eclass and the validations after that for bug 2831477 */

	     IF p_sys_link_function is not null THEN

		      check_etype_eclass(X_expenditure_type, p_sys_link_function);

  		      IF  ( G_EXP_TYPE_SYS_LINK is NULL ) then
        	        return_error('INVALID_ETYPE_SYSLINK') ;
  		      END IF ;

  		      IF  ( X_ei_date NOT BETWEEN G_EXP_TYPE_START_DATE AND nvl( G_EXP_TYPE_END_DATE, X_ei_date ) ) THEN
      			return_error('ETYPE_SLINK_INACTIVE');
  		      END IF;

	      END IF;

    END IF ; -- X_Calling_Module <> 'CreateRelatedItem'

    /*Bug# 2188422*/
    /** ---p_person_id := x_person_id ;  bug fix 2345895 **/
    /*    l_sys_link_func :='XX';   Bug# 2955795*/

    /** added 'APXIIMPT','apiimptb.pls' for payable import process bug fix : 2467454**/
	/** Added SelfService for validation during Self Service Expense Report Entry. 2971043 **/
    IF x_calling_module in ('APXINENT','apiindib.pls','apiimptb.pls','APXIIMPT','SelfService') THEN

         print_message('Stage:PATC:10.10.003.1');
         check_person_id ;                       /*2955795*/

	    /*If ( l_return_string = 'VI,ER,' or l_return_string = 'ER,VI,'
                or l_return_string = 'VI,')  then
		    print_message('Stage:PATC:Setting the l_sys_link_func to VI');
		    l_sys_link_func := 'VI';
	      End if;
        :Bug# 2955795 :Setting of l_sys_link_func is not required now */

    END IF;
    /*Bug# 2188422*/

    /*Bug 2726763: Since the check to see if project is chargeable is done in pa_trx_import
    --             only if the transaction source's skip_tc_validation_flag is 'N', we have
    --             to add the check here for calling module 'APXIIMPT'. For all other calling
    --             modules the check will be performed when selecting the project from the
    --             form's LOV */
    If (x_calling_module = 'APXIIMPT') Then

         print_message('Calling module = APXIIMPT');

         If not pa_utils.IsCrossChargeable(X_Project_Id) then
              print_message('Project not chargeable');
              return_error('PA_PROJECT_NOT_VALID');
         End If ;

    End If;
    /* end of Bug fix 2726763 */

    -- Perform basic validation against transaction:
    --         * project status is not 'CLOSED'
    --         * task is chargeable
    --         * item date is between start and end dates of project/task
    --         * Made changes in the call of Return Error Based on the  global Parameter
    --         * pa_trx_import.g_skip_tc_flag <> 'Y' then   --  code added for Bug 1299910

    OPEN  project_info;

    FETCH  project_info  INTO  proj;

    -- Fix for Bug # 801194. included CreateRelatedItem below to avoid
    -- Project level and task level checks for related items

    IF X_Calling_Module not in ('PAXPRRPE', 'PAXINADI','CreateRelatedItem') THEN
         -- Project level and task level checks are not required
         -- because as they are validated in the GUI forms for these
         -- Calling Modules.
         print_message('Stage:PATC:10.10.004');
         IF ( project_info%ROWCOUNT = 0 ) THEN  -- Project/Task combination is
                                                -- not valid
              IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added If Condition for bug 1299909 */
	               print_message('Stage:PATC:10.10.005');
	               return_error(  'PA_EXP_INV_PJTK' );
              End If;

         ELSIF ( proj.p_template_flag = 'Y' ) THEN  -- Checks if it is a
                                                    -- template project

              IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added If Condition for bug 1299909 */
	               print_message('Stage:PATC:10.10.006');
                   return_error( 'PA_EX_TEMPLATE_PROJECT');
              End If;

              -- BUG: 4600792 PQE:R12 CHANGE AWARD END WHEN ENCUMBRANCE EXISTS, IMPORT ENC REVERSALS FOR CLOSE
	          --
       /* Added trunc() for bug#5999555 */
	 ELSIF ( trunc(X_ei_date) NOT BETWEEN trunc(proj.p_start_date) AND trunc(proj.p_end_date) )
	                         AND PA_TRX_IMPORT.Get_GVal_ProjTskEi_Date ='Y'  THEN

              IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added If Condition for bug 1299909 */
	               print_message('Stage:PATC:10.10.007');
                   return_error( 'PA_EX_PROJECT_DATE' );
              End If;

         ELSIF (PA_PROJECT_UTILS.Check_prj_stus_action_allowed(proj.project_status_code,'NEW_TXNS') = 'N' ) THEN

              IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added If Condition for bug 1299909 */
	               print_message('Stage:PATC:10.10.008');
                   return_error( 'PA_NEW_TXNS_NOT_ALLOWED' );
              End If;

              -- BUG: 4600792 PQE:R12 CHANGE AWARD END WHEN ENCUMBRANCE EXISTS, IMPORT ENC REVERSALS FOR CLOSE
	          --
         ELSIF ( X_ei_date NOT BETWEEN proj.t_start_date AND proj.t_end_date ) AND PA_TRX_IMPORT.Get_GVal_ProjTskEi_Date ='Y' THEN

              IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added If Condition for bug 1299909 */
	               print_message('Stage:PATC:10.10.009');
                   return_error( 'PA_EXP_TASK_EFF' );
              End If;

	     ELSIF ( proj.t_chargeable_flag = 'N' ) THEN

              IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added If Condition for bug 1299909 */
                   print_message('Stage:PATC:10.10.010');
                   return_error( 'PA_EXP_TASK_STATUS' );
              End If;

         ELSIF (Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y') Then

              print_message('Calling Check_fin_Task_published');
              PA_PROJ_ELEMENTS_UTILS.Check_Fin_Task_Published(
                    p_project_id         => x_project_id
                   ,p_task_id            => x_task_id
                   ,x_return_status      => l_return_status_code
                   ,x_error_message_code => l_err_msg_code);

              IF l_return_status_code = 'N' THEN

                   print_message('check_fin_task_published returned status of N');
                   return_error(l_err_msg_code);

              END IF;

            If p_sys_link_function = 'VI' and X_calling_module not in  ('APXRICAD','POXPOEPO')
            Then  /*Added for bug 3608942,6118060,8545071*/
		           /* start for bug#3088249 */
                   /* Modified the following select statement for bug 3620355
		           select to_number(SUBSTR(USERENV('CLIENT_INFO'),1,10)) into l_prvdr_org_id from dual; */
                   /* Begin Bug 5214766
                      We no longer use client info to get the operating_unit in r12 due to MOAC being introduced.
                      We using pa_moac_utils.get_current_org_id;
                   select to_number(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' '
                                     ,NULL ,SUBSTRB(USERENV('CLIENT_INFO'),1,10))) into l_prvdr_org_id from dual;
                   */
                   l_prvdr_org_id := pa_moac_utils.get_current_org_id;
                   /* End bug 5214766

		           l_pa_date := pa_utils2.get_pa_date( p_ei_date  => X_ei_date
							                          ,p_gl_date  => SYSDATE
							                          ,p_org_id   => l_prvdr_org_id);

		           IF l_pa_date is null THEN
		                print_message('PA Date is null');
		                return_error( 'INVALID_PA_DATE');
		           END IF;
		           /* end for bug#3088249 */
              End If;

         END IF;

    END IF; -- X_Calling_Module not in ('PAXPRRPE', 'PAXINADI','CreateRelatedItem')

    -- BUG: 4600792 PQE:R12 CHANGE AWARD END WHEN ENCUMBRANCE EXISTS, IMPORT ENC REVERSALS FOR CLOSE
    --
    /* Initializing the value-- Bug4138033 */
    PA_TRX_IMPORT.Set_GVal_ProjTskEi_Date('Y');
    /* End Bug# 4138033 */

    -- If item passes basic validation, then validate the item against all
    -- applicable task-level transaction controls

    --    If there any transaction controls defined for task set level_flag = 'T'
    --    else set the flag to 'P'.

    level_flag := NULL ;

    IF (nvl(G_PREV_PROJ_ID,-99) <> x_project_id OR nvl(G_PREV_TASK_ID,-99) <> x_task_id) THEN

         G_PREV_PROJ_ID  := x_project_id;
         G_PREV_TASK_ID  := x_task_id;

         check_level ;

    ELSE /* proj id and task id are the same */

         level_flag := G_PREV_LEVEL;

    END IF;
    -- Begin to check transaction controls

    OPEN  task_level_tc;                  /*Bug# 2955795*/

    --  The following fetch will get both task level and project level controls
    --  in the order.

    FETCH  task_level_tc  INTO  tc;

     /* Start -- CWK block moved from below to here for assigning the person_type at the initial stage only
      for bug 5948324*/

        /** Begin PA.M/CWK changes **/

         -- Fix start for bug : 3681318
         IF X_person_id IS NOT NULL /*AND P_PERSON_TYPE IS NULL*/ then /*Commented p_person_type for bug 7395534 */

            BEGIN
                  select p.CURRENT_EMPLOYEE_FLAG , p.CURRENT_NPW_FLAG
                  into  l_CURRENT_EMPLOYEE_FLAG , l_CURRENT_NPW_FLAG
                  from per_all_people_f  p
                  where p.person_id = x_person_id
                  and x_ei_date between p.effective_start_date and  p.effective_end_date
                  and ((p.current_employee_flag = 'Y') OR (p.current_npw_flag = 'Y')); -- added for bug 7395534
                  --and p.effective_start_date  <=  x_ei_date
                  --and p.effective_end_date    >= x_ei_date ;

                  if l_CURRENT_EMPLOYEE_FLAG IS NOT NULL then
                       l_person_type := 'EMP' ;
                  else
                       l_person_type := 'CWK' ;
                  end if ;

            Exception
                 WHEN NO_DATA_FOUND THEN
                    /* Bug 6053374: If condition introduced. No error should be thrown in this case, for a Standard Invoice.*/
                    IF p_sys_link_function = 'VI' THEN
                       null;
                    ELSE
                      /*  Raise ; Commented for bug 5151539 */
                      print_message('No Active Assignment with the given information'); /* Added for bug5151539 */
                      return_error( 'PA_NO_ASSIGNMENT'); /* Added for bug5151539 */
                    END IF;
            END ;

         END IF ; -- X_person_id IS NOT NULL AND P_PERSON_TYPE IS NULL

         /*if p_person_type IS NOT NULL and X_person_id IS NOT NULL then
              l_person_type := p_person_type ;
         end if ; Commented for bug 7395534 */
         -- Fix end for bug : 3681318

    ---******** Selva Code starts

    IF  task_level_tc%NOTFOUND  THEN

	     print_message('Stage:PATC:10.11.001');

         IF proj.t_limit_flag = 'Y' THEN

             /* Commented for bug 2939224
             IF (p_sys_link_function <> 'VI' OR (p_sys_link_function = 'VI' AND check_person_level_TCs(x_project_id, x_task_id))) THEN  */ -- added for bug 2942492

             -- Added x_person_id parameter to function call for bug 4585740
             /* Added x_person_id is NULL condition below for bug 8290672 */
             If ((x_person_id is NULL) OR (check_person_level_TCs(p_sys_link_function, x_project_id, x_task_id,x_person_id))) THEN -- added for bug 2939224/bug 4912880 added x_person_id to call

                  IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added If Condition for bug 1299909 */
	                   print_message('Stage:PATC:10.11.002');

                    -- Added following block for CWk changes bug# 5948324
                    if l_person_Type = 'CWK' Then
                       return_error('PA_CWK_TXN_NOT_ALLOWED');
                    Else
                       return_error('PA_EXP_TASK_TC');
                    END IF;
                    -- End CWK changes bug# 5948324

                  End If;

	         END IF;

         END IF ;

         -- Changed by Rajnish .
         -- Removed ( level_flag <> 'T') from the following If condition
         -- This is the fix for bug # 1363773

         /*
         IF ( level_flag <> 'T' AND proj.p_limit_flag = 'Y')  THEN  commented for bug 1363773  */

         IF proj.p_limit_flag = 'Y' THEN           /*Added for bug 1363773*/

              /* Commented the if for bug 2939224
              IF (p_sys_link_function <> 'VI' OR
                 (p_sys_link_function = 'VI' AND check_person_level_TCs(x_project_id))) THEN  */-- added for bug 2942492
              -- Added x_person_id parameter to function call for bug 4585740
              /* Added x_person_id is NULL condition below for bug 8290672 */
              IF ((x_person_id is NULL) OR (check_person_level_TCs(p_sys_link_function, x_project_id,x_person_id))) THEN  -- added for bug 2939224/bug 4912880 added x_person_id to call

                   IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added If Condition for bug 1299909 */
	                    print_message('Stage:PATC:10.11.003');
                        return_error( 'PA_EXP_PJ_TC' );
                   End If;

	          END IF;

         END IF ;

    ELSE -- task_level_tc found

	     print_message('Stage:PATC:10.12.001');
	     print_message('Transaction contol record:task_id['||tc.task_id||
                        ']person_id['||tc.person_id||']exp_cat['||tc.expenditure_category||
			            ']exp_type['||tc.expenditure_type||']non_lab_res['||tc.non_labor_resource||
		                ']charge_flag['||tc.chargeable_flag||']bill_flag['||tc.billable_indicator||
			            ']schd_exp['||tc.SCHEDULED_EXP_ONLY||']' );

         --        if the task level limit  flag is true then there should be
         --        a transaction control at task level.

         IF ( proj.t_limit_flag = 'Y' AND tc.task_id is NULL ) THEN

              IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added If Condition for bug 1299909 */

	               print_message('Stage:PATC:10.12.002');
                   -- Begin CWK/FP_M changes
                 /*  IF p_sys_link_function not in ('USG', 'PJ') THEN --Bug 4266933*//*Commented for Bug 5735180*/


                        If l_Person_Type = 'EMP' Then
                              return_error( 'PA_EXP_TASK_TC' );
                        Elsif l_Person_Type = 'CWK' Then
                             return_error('PA_CWK_TXN_NOT_ALLOWED');
                        Else
                           -- Added the following block for the condition Limit to TC='Y' and don't have any
                           -- TCs and EI is not based on Employee Bug#5948324
                            return_error('PA_TR_EPE_TASK_TXN_CTRLS');
                        End If;

                        -- End CWK/FP_M changes

	         /*      END IF; --Bug 4266933*/ /*For Bug 5735180*/

              End If;

         END IF ;

         --    Modified against Bug# 674526
         --    a new temporary variable is created to get the level
         --    of Txn Control here.
         --    rest of the code is kept as it is

         IF tc.task_id is NOT NULL THEN
              level_flag_local := 'T' ;
         ELSE
              level_flag_local := 'P' ;
         END IF ;

         /** Added this code for Transaction Controls for PJRM
           *  If PRM installed and system linkage function in ST,OT,ER and
           *  transaction controls setup donot allow unscheduled assignment and assignment is NULL then
           *  return error else do nothing
           *  Added the following if - else conditions based on the following matrix
           *  PJRM check is required based on the system linkage function ( ST, OT, ER).If sys link func param is
           *  Null , then figure out based on Trx source and calling module . If Trx source is NULL
           *  figure out based on the calling module and expenditure type
           *  source          calling module      sys_link        Trx source         skip tc flag
           *  --------------------------------------------------------------------------------
           *  1.Pre approved     PAXPRRPE            Yes           -                check <> Y
           *  2.SST              PAXVSSTS            -             Yes              check <> Y
           *  3.SSE              SelfService         -             -                check <> Y
           *  4.OTL              PAXVOTCB            -             Yes              check <> Y
           *  5.AP payables-VI   APXINENT            -             -                check <> Y
           *  5.AP payables-ER   APXINENT            -             -                donot check
           *  6.Import           PAAPIMP             Yes           AP EXPENSE       donot check
           *  7.Import           PAAPIMP             Yes           -                check <> Y
           *  8.All others                           Yes                            check <> Y
           *  9.Payable Imports  APXIIMPT            -             -
           **/
	     l_check_pjrm_tc_flag := 'N';
	     l_return_string := NULL;

	     --- Bug 4092732 IF nvl(PA_INSTALL.is_prm_licensed,'N') = 'Y' Then

		 IF p_sys_link_function in ('ST','OT','ER') THEN

	          IF ( x_calling_module = 'PAAPIMP' and x_transaction_source = 'AP EXPENSE') OR
		         ( x_calling_module <> 'PAAPIMP' and Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' ) Then

			       print_message('Stage:PATC:10.12.003.1');
			       l_check_pjrm_tc_flag := 'Y';

		      END IF;
              /** added 'APXIIMPT','apiimptb.pls' for bug fix : 2467454 **/
		 ELSIF ( x_calling_module in  ('APXINENT','apiindib.pls','apiimptb.pls','APXIIMPT')) Then
			   /** Based on the expenditure_type derive the system linkage function
			     *  IF expenditure_type is part of ER,VI the display warning
                 *  else raise error **/

		      print_message('Stage:PATC:10.12.003.2');
              /*This is not required now since we have p_sys_link_function now that contains
                store 'ER'/'VI' for Expense Report/Supplier Invoice
			  check_person_id(p_mode => 'SYS_LINK_CHECK'
					         ,x_return_string => l_return_string );     Bug# 2955795*/

			  If p_sys_link_function = 'ER' then       /*Bug# 2955795*/
			       l_check_pjrm_tc_flag := 'Y';
			  Else
				   l_check_pjrm_tc_flag := 'N';
			  End if;

		 ELSIF ( x_calling_module IN ('SelfService','PAXVSSTS','PAXVOTCB')) Then

			   print_message('Stage:PATC:10.12.003.3');
			   l_check_pjrm_tc_flag := 'Y';

		 ELSIF  Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' then

			   print_message('Stage:PATC:10.12.003.4');
			   l_check_pjrm_tc_flag := 'N';

         END IF;

	     /* Bug 4092732
	     ELSE  -- prm is not installed

		   print_message('Stage:PATC:10.12.003.5');
		   l_check_pjrm_tc_flag := 'N';
		   PATC.G_OVERIDE_ASSIGNMENT_ID := p_assignment_id;

	     END If;
	     */
         Temp_allow_unscheduled_exp := nvl(tc.SCHEDULED_EXP_ONLY,'N') ;
         IF ( p_assignment_id is NULL and x_person_id is NOT NULL and l_check_pjrm_tc_flag = 'Y')  Then

		      print_message('Stage:PATC:10.12.003.6');
              temp_assignment_id := PA_UTILS4.get_assignment_id
                               (p_person_id   => x_person_id
                               ,p_project_id => x_project_id
                               ,p_task_id    => x_task_id
                               ,p_ei_date    => x_ei_date );
         Else

		     print_message('Stage:PATC:10.12.003.7');
             temp_assignment_id := p_assignment_id;

         End If;

         print_message('Check for PJRM controls temp_assignment_id:['||temp_assignment_id||
		      ']l_return_string:['||l_return_string||
		      ']l_check_pjrm_tc_flag:['||l_check_pjrm_tc_flag||
              ']Prm Installed['||nvl(PA_INSTALL.is_prm_licensed,'N')||
		      ']level_flag_local['||level_flag_local||']task_limit_flag['||proj.t_limit_flag||
		      ']project_limit_flag['||proj.p_limit_flag||']'  );

         If (nvl(temp_assignment_id,0) = 0 and l_check_pjrm_tc_flag = 'Y' and nvl(tc.SCHEDULED_EXP_ONLY,'N') =  'Y' ) then

              Print_Message('Stage:PATC:10.12.003.8');
              -- Bug 7715496 Changed message to PA_PJR_NO_ASSIGNMENT
              X_status := 'PA_PJR_NO_ASSIGNMENT'; -- Bug#3442186 Changed status from PA_INVALID_ASSIGNMENT
              X_Billable_Flag := NULL;
		      Print_Message('PATC ERROR: ' || X_status);
              RAISE INVALID_DATA;

         Else

		      Print_Message('Stage:PATC:10.12.003.9');
              PATC.G_OVERIDE_ASSIGNMENT_ID := temp_assignment_id;

         End if; -- PA_NO_ASSIGNMENT

         /** End of PJRM changes **/

        /*The block has been moved to top for bug 5948324 as the person_type should get assigned
         before the initial check for TC */

         -- Begin bug 4068808
         If ((proj.p_limit_flag = 'Y' and level_flag_local = 'P') or (proj.t_limit_flag = 'Y' and level_flag_local = 'T')) Then

              IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added for bug 4549869 */

                   -- If P_Person_Type = 'CWK' and Tc.Employees_Only_flag = 'Y' Then
                   If l_Person_Type = 'CWK' and Tc.Employees_Only_flag = 'E' Then

                        Print_Message('Stage:PATC:10.12.004.1a');
                        X_Status := 'PA_CWK_TXN_NOT_ALLOWED';
                        X_Billable_Flag := NULL;
                        Print_Message('PATC ERROR: ' || X_status);
                        RAISE INVALID_DATA;

                   ElsIf l_Person_Type = 'EMP' and Tc.Employees_Only_flag = 'C' Then

                        Print_Message('Stage:PATC:10.12.004.1b');
                        If level_flag_local = 'P' Then
                             X_Status := 'PA_TR_EPE_PROJ_TXN_CTRLS';
                        Else
                             X_Status := 'PA_TR_EPE_TASK_TXN_CTRLS';
                        End If;
                        X_Billable_Flag := NULL;
                        Print_Message('PATC ERROR: ' || X_status);
                        RAISE INVALID_DATA;

                   Else

                        print_message('Stage:PATC:10.12.004.1c');

                   End If;

              End If; /* Added for bug 4549869 */

         ElsIf ((proj.p_limit_flag = 'N' and level_flag_local = 'P') or (proj.t_limit_flag = 'N' and level_flag_local = 'T')) Then

              If Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added for bug 4549869 */

                   If l_Person_Type = 'CWK' and (tc.Employees_Only_Flag = 'C' or tc.Employees_Only_flag is Null) Then

                        If tc.chargeable_flag = 'N' Then -- Added for Bug#4549448

                             Print_Message('Stage:PATC:10.12.004.1d');
                             X_Status := 'PA_CWK_TXN_NOT_ALLOWED';
                             X_Billable_Flag := NULL;
                             Print_Message('PATC ERROR: ' || X_status);
                             RAISE INVALID_DATA;

                        End If; -- Added for Bug#4549448

                   ElsIf l_Person_Type = 'EMP' and (tc.Employees_Only_Flag = 'E' or tc.Employees_Only_flag is Null) Then

                        If tc.chargeable_flag = 'N' Then -- Added for Bug#4549448

                             Print_Message('Stage:PATC:10.12.004.1e');

                             If level_flag_local = 'P' Then
                                  X_Status := 'PA_TR_EPE_PROJ_TXN_CTRLS';
                             Else
                                  X_Status := 'PA_TR_EPE_TASK_TXN_CTRLS';
                             End If;

                             X_Billable_Flag := NULL;
                             Print_Message('PATC ERROR: ' || X_status);
                             RAISE INVALID_DATA;

                        End If; -- Added for Bug#4549448

                        -- Start, added the following block for bug 4556126
			-- Added 'BTC', 'WIP', 'INV' conditions for bug 6626535

           /* 8333176: Removed BTC from the below condition to exclude BTC transactions being returned with error
                   to avoid the billable_flag being NULL when inserting the BTC lines in Create and dstribute burden process */

                   ElsIf (p_sys_link_function in ('USG', 'PJ', 'VI', 'WIP', 'INV') and x_person_id is NULL) Then

                        If tc.chargeable_flag = 'N' Then

                             Print_Message('Stage:PATC:10.12.004.1e');

                             If level_flag_local = 'P' Then
                                  X_Status := 'PA_TR_EPE_PROJ_TXN_CTRLS';
                             Else
                                  X_Status := 'PA_TR_EPE_TASK_TXN_CTRLS';
                             End If;

                             X_Billable_Flag := NULL;
                             Print_Message('PATC ERROR: ' || X_status);
                             RAISE INVALID_DATA;

                        End If;
                        -- End, added the following block for bug 4556126
                   End If;

              End If; -- Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' /* Added for bug 4549869 */

         Else

              print_message('Stage:PATC:10.12.004.2');

         End If;
         -- End bug 4068808

         If Pa_Pjc_CWk_Utils.Is_CWK_TC_Xface_Allowed(X_Project_Id) <> 'Y' And
            -- P_Person_Type = 'CWK' And
            l_Person_Type = 'CWK' And
            P_Sys_Link_Function in ('ST','OT') And
            P_PO_Line_Id Is Not Null Then

              If Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added for bug 4549869 */

		           Print_Message('Stage:PATC:10.12.004.3');
                   X_Status := 'PA_CWK_TC_NOT_ALLOWED';
                   X_Billable_Flag := NULL;
		           Print_Message('PATC ERROR: '|| X_status);
                   RAISE INVALID_DATA;

              End If; /* Added for bug 4549869 */

         Else

		      Print_Message('Stage:PATC:10.12.004.4');

         End If;

         /** End PA.M/CWK changes **/

         /** Begin PA.M/Task Assignment changes **/

	     If P_Sys_Link_Function in ('ST','OT','ER') and
	        Pa_Project_Structure_Utils.Check_Workplan_Enabled(P_Project_Id => X_Project_Id) = 'Y' and
	        Tc.Workplan_Res_Only_flag = 'Y' Then

              If Pa_Task_Assignment_Utils.Check_Task_Asgmt_Exists (
                                      P_Person_Id 	      => X_Person_id,
	 							      P_Financial_Task_Id => X_Task_Id,
								      P_Ei_Date 	      => X_Ei_Date ) = 'N' Then

		           Print_Message('Stage:PATC:10.12.004.5');
                   X_Status := 'PA_WP_RES_NOT_DEFINED';
                   X_Billable_Flag := NULL;
			       Print_Message('PATC ERROR: ' || X_Status);
                   RAISE INVALID_DATA;

	          Else

			       Print_Message('Stage:PATC:10.12.004.6');

		      End If;

	     Else

		      Print_Message('Stage:PATC:10.12.004.7');

	     End If;

         /** End PA.M/Task Assignment changes **/

         If ((proj.p_limit_flag = 'Y' and level_flag_local = 'P') or (proj.t_limit_flag = 'Y' and level_flag_local = 'T')) Then

              IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added for bug 4549869 */

                   IF tc.chargeable_flag = 'N' THEN

                        IF level_flag_local = 'T' THEN

                             IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added If Condition for bug 1299909 */

	                              print_message('Stage:PATC:10.12.005');
                                  return_error( 'PA_EXP_TASK_TC' );

                             End If;

                        END IF ;
                        IF level_flag_local = 'P' THEN

                             IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added If Condition for bug 1299909 */
		                          print_message('Stage:PATC:10.12.006');
                                  return_error( 'PA_EXP_PJ_TC' );
                             End If;
                        END IF ;

                   ELSE

	                    print_message('Stage:PATC:10.12.007');
                        IF tc.person_id is NOT NULL AND tc.expenditure_category is NULL THEN

                             FETCH  task_level_tc  INTO  tc;
                             IF task_level_tc%FOUND THEN
                                  IF level_flag = 'T' AND
                                     tc.task_id is NOT NULL AND
                                     tc.chargeable_flag = 'N' THEN

                                       IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added If Condition for bug 1299909 */
			                                print_message('Stage:PATC:10.12.008');
                                            return_error( 'PA_EXP_TASK_TC' );
                                       End If;
                                  END IF ;
                                  IF level_flag = 'P' AND
                                     tc.chargeable_flag = 'N' THEN

                                       IF Pa_Trx_Import.G_Skip_Tc_Flag <> 'Y' Then     /* Added If Condition for bug 1299909 */
			                                print_message('Stage:PATC:10.12.009');
                                            return_error( 'PA_EXP_PJ_TC' );
                                       End If;
                                  END IF ;

                              END IF ;

                        END IF ;

                   END IF ;

              End If; /* Added for bug 4549869 */

         End If; -- proj.p_limit_flag = 'Y' or proj.t_limit_flag = 'Y'

    END IF ; -- IF task_level_tc%NOTFOUND

    print_message('Stage:PATC:10.12.010');
    set_billable_flag( tc.billable_indicator, proj.t_billable_flag );

    ---******** Selva Code ends

    CLOSE task_level_tc;

    -- Bug # 801194. For related items, this check is not required

    IF ( X_Calling_Module <> 'CreateRelatedItem') THEN

         /** bug fix :2483863 for expense reports the employee should be validated
          ** Validate ER during Payable Entry form if the sys link is ER
          ** otherwise validate it during payable import to project
          **/
         /*  If (x_calling_module in ('APXINENT','apiindib.pls','APXIIMPT','apiimptb.pls')) OR
                   (x_calling_module = 'PAAPIMP' AND x_transaction_source = 'AP EXPENSE' ) Then
                     check_person_id(p_mode => 'SYS_LINK_CHECK'
                                    ,x_return_string => l_return_string );
                     print_message('Stage:PATC:10.12.010.1');
             End If;                                              Commented for bug# 2955795 */

	     /** Added SelfService for validation during Self Service Expense Report Entry. 2971043 **/
	     /** At present Iexpenses does not pass the p_sys_link_function parameter. But since
	        in Ixpenses only Expense Reports are entered hence comparing based on calling
	        module only, so that we do not introduce any dependencies.**/
         If (x_calling_module in ('APXINENT','apiindib.pls','APXIIMPT','apiimptb.pls') AND p_sys_link_function = 'ER')  /*2955795*/
	       OR (x_calling_module = 'SelfService')
               OR
              ( x_calling_module = 'PAAPIMP' AND
                x_transaction_source = 'AP EXPENSE' AND p_sys_link_function = 'ER' ) THEN     /*Bug# 2955795*/

              print_message('Stage:PATC:10.12.010.2');

              IF nvl(check_active_employee
                       (p_vendor_id => x_vendor_id
                       ,p_person_id => x_person_id
                       ,p_ei_date   => x_ei_date),'N') = 'N' then
                   print_message('Stage:PATC:10.12.010.3');
                   return_error( 'NO_ASSIGNMENT');

              End if;

         End if;
         /** End of Bug fix: 2483863 **/

         -- Bug 4044057 To add validation for active assignment for entered Purchase Order for CWK
         IF x_calling_module = 'PAXVOTCB' and p_po_header_id is not null THEN

              l_job_id := pa_utils.GetEmpJobId(
                             X_person_id => x_person_id,
                             X_date      => X_ei_date ,
                             X_po_header_id => p_po_header_id,
                             X_po_line_id => p_po_line_id);

              -- Added PO params for bug 4044057
              -- Need to validate the assigment for the entered PO
              IF l_job_id is NULL THEN

                 print_message('Stage:PATC:10.12.010.4');
                 return_error('NO_PO_ASSIGNMENT');

              END IF;

         END IF; -- End of Bug 4044057

         --  Bug 570709. To add the expenditure org validation for transactions
         IF X_incurred_by_org_id is NOT NULL THEN

              IF pa_trx_import.g_skip_tc_flag <> 'Y' then /* Added for Bug # 2170237 */

                   IF pa_utils2.CheckExporg(X_incurred_by_org_id,X_ei_date) = 'N' then

	                    print_message('Stage:PATC:10.12.011');
                        return_error( 'PA_EXP_ORG_NOT_ACTIVE');
                   END IF;

              END IF; /* Added for Bug # 2170237 */

         ELSE
          /* Added for Bug#4604614 (BaseBug#4118885) -- Start */
	      IF ( X_Calling_Module in ( 'PAXVSSTS','PAXVOTCB' )) THEN
	           -- Bug 6156072: Base Bug 6045051: start
	           -- Bug 6156072: Base Bug 6045051: If condition introduced to check for person_type and then
	           --              call corresponding procedure to check for termination
	           IF (l_Person_Type = 'EMP') THEN
		       patc.check_termination (X_person_id, x_ei_date, l_ac_termination_date);
	           ELSIF (l_Person_Type = 'CWK') THEN
		       patc.check_termination_for_cwk (X_person_id, x_ei_date, l_ac_termination_date);
	           END IF;
	           -- Bug 6156072: Base Bug 6045051: end
	      end if;

	      IF ( l_ac_termination_date is not null ) then
	           X_org_id := pa_utils.GetEmpOrgId( X_person_id, l_ac_termination_date);
	      ELSE
	           X_org_id := pa_utils.GetEmpOrgId( X_person_id, X_ei_date );
	      END IF;
          /* Added for Bug#4604614 (BaseBug#4118885) -- End */

              IF ( X_org_id IS NULL ) THEN
	               print_message('Stage:PATC:10.12.012');
                   return_error( 'NO_ASSIGNMENT');
              END IF;

              IF pa_trx_import.g_skip_tc_flag <> 'Y' then /* Added for Bug # 2170237 */

                   IF pa_utils2.CheckExporg(X_org_id,X_ei_date) = 'N' then
	                    print_message('Stage:PATC:10.12.013');
                        return_error( 'PA_EXP_ORG_NOT_ACTIVE');
                   END IF;
              END IF;  /* Added for Bug # 2170237 */

         END IF ;

         -- Check for Non_labor_resource_org

         if ( X_nl_resource_org_id is NOT NULL ) then
	          print_message('Stage:PATC:10.12.014');
              check_nlro_date ;
         end if ;

    END IF ; -- IF ( X_Calling_Module <> 'CreateRelatedItem')

    patcx_bill_flag := temp_bill_flag;

    print_message('Stage:PATC:10.13.00:Calling patcx.tc_extension api');

    --Bug 3017533
    L_BeforeCE_AsgnId := PATC.G_OVERIDE_ASSIGNMENT_ID;

    patcx.tc_extension(
                X_project_id => X_project_id
              , X_task_id => X_task_id
              , X_expenditure_item_date => X_ei_date
              , X_expenditure_type => X_expenditure_type
              , X_non_labor_resource => X_non_labor_resource
              , X_incurred_by_person_id => X_person_id
              , X_quantity => X_quantity
		      , X_denom_currency_code => X_denom_currency_code
		      , X_acct_currency_code => X_acct_currency_code
		      , X_denom_raw_cost => X_denom_raw_cost
		      , X_acct_raw_cost => X_acct_raw_cost
		      , X_acct_rate_type => X_acct_rate_type
		      , X_acct_rate_date => X_acct_rate_date
		      , X_acct_exchange_rate => X_acct_exchange_rate
              , X_transferred_from_id => X_transfer_ei
              , X_incurred_by_org_id => X_incurred_by_org_id
              , X_nl_resource_org_id => X_nl_resource_org_id
              , X_transaction_source => X_transaction_source
              , X_calling_module => X_calling_module
	    	  , X_vendor_id => X_vendor_id
              , X_entered_by_user_id => X_entered_by_user_id
              , X_attribute_category => X_attribute_category
              , X_attribute1 => X_attribute1
              , X_attribute2 => X_attribute2
              , X_attribute3 => X_attribute3
              , X_attribute4 => X_attribute4
              , X_attribute5 => X_attribute5
              , X_attribute6 => X_attribute6
              , X_attribute7 => X_attribute7
              , X_attribute8 => X_attribute8
              , X_attribute9 => X_attribute9
              , X_attribute10 => X_attribute10
		      , X_attribute11 => X_attribute11
		      , X_attribute12 => X_attribute12
		      , X_attribute13 => X_attribute13
		      , X_attribute14 => X_attribute14
	          , X_attribute15 => X_attribute15
		      , X_msg_application => X_msg_application
              , X_billable_flag => patcx_bill_flag
	          , X_msg_type => temp_msg_type
		      , X_msg_token1 => temp_msg_token1
		      , X_msg_token2 => temp_msg_token2
		      , X_msg_token3 => temp_msg_token3
		      , X_msg_count => temp_msg_count
              , X_outcome => temp_status
              , p_projfunc_currency_code   => p_projfunc_currency_code
              , p_projfunc_cost_rate_type  => p_projfunc_cost_rate_type
              , p_projfunc_cost_rate_date  => p_projfunc_cost_rate_date
              , p_projfunc_cost_exchg_rate => p_projfunc_cost_exchg_rate
              , x_assignment_id            => PATC.G_OVERIDE_ASSIGNMENT_ID
              , p_work_type_id             => p_work_type_id
              , p_sys_link_function        => p_sys_link_function
		      , P_Po_Header_Id		       => P_Po_Header_Id
		      , P_Po_Line_Id		       => P_Po_Line_Id
		      , P_Person_Type		       => l_Person_Type
		      , P_Po_Price_Type		       => P_Po_Price_Type
              , P_Document_Type            => P_Document_Type
              , P_Document_Line_Type       => P_Document_Line_Type
              , P_Document_Dist_Type       => P_Document_Dist_Type
              , P_pa_ref_num1              => P_pa_ref_num1
              , P_pa_ref_num2              => P_pa_ref_num2
              , P_pa_ref_num3              => P_pa_ref_num3
              , P_pa_ref_num4              => P_pa_ref_num4
              , P_pa_ref_num5              => P_pa_ref_num5
              , P_pa_ref_num6              => P_pa_ref_num6
              , P_pa_ref_num7              => P_pa_ref_num7
              , P_pa_ref_num8              => P_pa_ref_num8
              , P_pa_ref_num9              => P_pa_ref_num9
              , P_pa_ref_num10             => P_pa_ref_num10
              , P_pa_ref_var1              => P_pa_ref_var1
              , P_pa_ref_var2              => P_pa_ref_var2
              , P_pa_ref_var3              => P_pa_ref_var3
              , P_pa_ref_var4              => P_pa_ref_var4
              , P_pa_ref_var5              => P_pa_ref_var5
              , P_pa_ref_var6              => P_pa_ref_var6
              , P_pa_ref_var7              => P_pa_ref_var7
              , P_pa_ref_var8              => P_pa_ref_var8
              , P_pa_ref_var9              => P_pa_ref_var9
              , P_pa_ref_var10             => P_pa_ref_var10 );

    print_message('Stage:PATC:10.13.001');
    print_message('End of patcx.tc_extension api patcx_bill_flag :'||patcx_bill_flag||
			      'Assignment :'||PATC.G_OVERIDE_ASSIGNMENT_ID||'patcx_status['||temp_status||']');

    /*Start Bug4518893 */
    IF (   patcx_bill_flag = 'N' OR patcx_bill_flag = 'Y' ) THEN
         X_billable_flag := patcx_bill_flag;
    ELSE
         X_billable_flag := temp_bill_flag;
    END IF;
    /*End Bug4518893 */


/* Bug 7685120 Move the following code to the point where we have set the Global variables for work type in PATC
    IF ( temp_status IS NOT NULL ) THEN

         If pa_trx_import.g_skip_tc_flag <> 'Y' then /* Added for Bug # 2108456

	          print_message('Stage:PATC:10.13.002');
              X_msg_type := temp_msg_type;
              X_msg_count := temp_msg_count;
              X_msg_token1 := temp_msg_token1;
              X_msg_token2 := temp_msg_token2;
              X_msg_token3 := temp_msg_token3;
              return_error( temp_status );

         End If;

    END IF;

    CLOSE project_info;
End of change for Bug 7685120 */

    /* Start bug4518893
    IF (   patcx_bill_flag = 'N' OR patcx_bill_flag = 'Y' ) THEN
         X_billable_flag := patcx_bill_flag;
    ELSE
         X_billable_flag := temp_bill_flag;
    END IF;
    End bug4518893 */

    /* Bug 2648550 starts */
    -- new work_type_id and tp_amt_type_code,assignment_name,work_type_name
    -- is derived using the new assignment_id all references to PATC to be changed
    -- to use the newly derived work_type_id,tp_amt_type_code,assignment_name,work_type_name
    --Bug 3017533, only if the asgn has changed from previous and assign_precedes_task is set
    --for all modules other than PAXTREPE then override the WT, TP amt type

    If ( (nvl(PATC.G_OVERIDE_ASSIGNMENT_ID,0) <> nvl(L_BeforeCE_AsgnId,0)) and
       (proj.p_assign_precedes_task = 'Y') and
       (X_Calling_Module <> 'PAXTREPE') ) Then

         PATC.G_OVERIDE_WORK_TYPE_ID := PA_UTILS4.get_work_type_id (
                                               p_project_id =>X_project_id
                                             , p_task_id =>X_task_id
                                             , p_assignment_id=>nvl(PATC.G_OVERIDE_ASSIGNMENT_ID,0) );

    	 PATC.G_OVERIDE_TP_AMT_TYPE_CODE := pa_utils4.get_tp_amt_type_code(
                                               p_work_type_id => PATC.G_OVERIDE_WORK_TYPE_ID );

    	 PATC.G_OVERIDE_ASSIGNMENT_NAME := pa_utils4.get_assignment_name(
				               p_assignment_id =>PATC.G_OVERIDE_ASSIGNMENT_ID);

    	 PATC.G_OVERIDE_WORK_TYPE_NAME := pa_utils4.get_work_type_name(
				               p_work_type_id => PATC.G_OVERIDE_WORK_TYPE_ID);

   	     -- start of projcurrency and EI attrib changes
    	 -- Override the Billable flag if the work type biilability is enabled
    	 print_message('Stage:PATC:10.13.003');

    	 X_billable_flag := PA_UTILS4.get_trxn_work_billabilty
         /*	(p_work_type_id => p_work_type_id    commented for bug 2648550 */
         /* Bug 2648550 used global variable in work_type_id parameter */
                        (p_work_type_id => PATC.G_OVERIDE_WORK_TYPE_ID
			            ,p_tc_extn_bill_flag => X_billable_flag);
         /* end of bug 2648550 */

    Else

         PATC.G_OVERIDE_WORK_TYPE_ID := p_work_type_id;
         PATC.G_OVERIDE_TP_AMT_TYPE_CODE :=  pa_utils4.get_tp_amt_type_code(
                                      p_work_type_id => p_work_type_id);
         PATC.G_OVERIDE_ASSIGNMENT_NAME := pa_utils4.get_assignment_name(
                                       p_assignment_id =>p_assignment_id);
         PATC.G_OVERIDE_WORK_TYPE_NAME := pa_utils4.get_work_type_name(
                                       p_work_type_id => p_work_type_id);

         -- start of projcurrency and EI attrib changes
         -- Override the Billable flag if the work type biilability is enabled
         print_message('Stage:PATC:10.13.004');
         X_billable_flag := PA_UTILS4.get_trxn_work_billabilty
                        (p_work_type_id => p_work_type_id
                        ,p_tc_extn_bill_flag => X_billable_flag);


    End If; --Bug 3017533
/*Start of changes for Bug 7685120 */
   IF ( temp_status IS NOT NULL ) THEN

         If pa_trx_import.g_skip_tc_flag <> 'Y' then /* Added for Bug # 2108456 */

	          print_message('Stage:PATC:10.13.002');
              X_msg_type := temp_msg_type;
              X_msg_count := temp_msg_count;
              X_msg_token1 := temp_msg_token1;
              X_msg_token2 := temp_msg_token2;
              X_msg_token3 := temp_msg_token3;
              return_error( temp_status );

         End If; /* Added for Bug # 2108456 */

    END IF;

    CLOSE project_info;
/*End of change for Bug 7685120 */

    -- end of projcurrency and EI attrib changes

    print_message('Stage:PATC:10.13.005');
    print_message('Billable Flag after override:['||X_billable_flag||
		      ']override assn:['||PATC.G_OVERIDE_ASSIGNMENT_ID||']x_status ['||x_status||']');

    -- Begin PA.L Retirement Cost Processing changes
    print_message('Stage:PATC:10.14.00: Check capitalizable_flag against retirement_cost_flag');
    If pa_trx_import.g_skip_tc_flag <> 'Y' then

         If proj.p_proj_typ_class_code = 'CAPITAL' and
            proj.t_ret_cost_flag = 'Y' and
            x_billable_flag = 'Y' then

           	  -- The transaction cannot be capitalizable and a retirement cost at the same time.
              return_error('PA_TRX_CANT_BE_CAP');

         End If;

    End If;
    -- End PA.L Retirement Cost Processing changes

    print_message('END of GET_STATUS API ');

    Pa_Trx_Import.G_Skip_Tc_Flag := G_TRX_SKIP_FLAG;

  EXCEPTION
    WHEN  INVALID_DATA  THEN
	  Pa_Trx_Import.G_Skip_Tc_Flag := G_TRX_SKIP_FLAG;
      NULL;
    WHEN OTHERS THEN
      Pa_Trx_Import.G_Skip_Tc_Flag := G_TRX_SKIP_FLAG;
      X_status := SQLCODE;
      X_billable_flag := NULL;
	  print_message('Failed in GET_PATC api sqlerror:'||X_status);

  END get_status;


/* Added procedure check_termination for Bug#4604614 (BaseBug#4118885) */

procedure check_termination (p_person_id in per_all_people_f.person_id%type,
                             p_ei_date   in pa_expenditure_items_all.expenditure_item_date%type,
			     x_actual_termination_date out nocopy per_periods_of_service.actual_termination_date%type) IS

cursor check_periods_of_service is
select null
from   per_periods_of_service
where  person_id = p_person_id
and    p_ei_date between date_start and nvl(actual_termination_date, p_ei_date);

l_actual_termination_date  per_periods_of_service.actual_termination_date%type := NULL;
begin

open check_periods_of_service;

fetch check_periods_of_service into l_actual_termination_date;
if check_periods_of_service%notfound then
begin
  select actual_termination_date into l_actual_termination_date from (
  select actual_termination_date
  from   per_periods_of_service
  where  person_id = p_person_id
  and    actual_termination_date < p_ei_date
  order by actual_termination_date desc)
  where rownum = 1;
exception
when no_data_found then
l_actual_termination_date := NULL;
end;
end if;
close check_periods_of_service;

x_actual_termination_date := l_actual_termination_date;

exception
when others then
raise;

end check_termination;

-- Bug 6156072: Base Bug 6045051: start
-- Bug 6156072: Base Bug 6045051: new procedure added to check if EI Date falls between active service periods
--              of the contingent worker. This is similar to procedure check_termination
procedure check_termination_for_cwk (p_person_id in per_all_people_f.person_id%type,
                             p_ei_date   in pa_expenditure_items_all.expenditure_item_date%type,
			     x_actual_termination_date out nocopy per_periods_of_placement.actual_termination_date%type) IS

cursor check_periods_of_service is
select null
from   per_periods_of_placement
where  person_id = p_person_id
and    p_ei_date between date_start and nvl(actual_termination_date, p_ei_date);

l_actual_termination_date  per_periods_of_placement.actual_termination_date%type := NULL;
begin

open check_periods_of_service;

fetch check_periods_of_service into l_actual_termination_date;
if check_periods_of_service%notfound then
begin
  select actual_termination_date into l_actual_termination_date from (
  select actual_termination_date
  from   per_periods_of_placement
  where  person_id = p_person_id
  and    actual_termination_date < p_ei_date
  order by actual_termination_date desc)
  where rownum = 1;
exception
when no_data_found then
l_actual_termination_date := NULL;
end;
end if;
close check_periods_of_service;

x_actual_termination_date := l_actual_termination_date;

exception
when others then
raise;

end check_termination_for_cwk;
-- Bug 6156072: Base Bug 6045051: end

END PATC;

/
