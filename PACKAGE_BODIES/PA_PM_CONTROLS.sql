--------------------------------------------------------
--  DDL for Package Body PA_PM_CONTROLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PM_CONTROLS" AS
/* $Header: PAPMCONB.pls 120.2.12010000.2 2008/08/22 16:11:23 mumohan ship $ */

    Procedure Action_Allowed (p_action            IN VARCHAR2,
                              p_pm_product_code   IN VARCHAR2,
                              p_field_value_code  IN VARCHAR2 DEFAULT NULL,
                              p_action_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_error_code        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              p_error_stack       IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_error_stage       IN OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

-- This procedure checks the pa_pm_control_rules table to determine
-- whether a given action is allowed to be performed in Oracle Projects
-- The rules are set up , for each project management product
-- by system administrators . If an active record is found for the given
-- product code and action ,then the procedure returns p_action_allowed
-- as 'N', else it returns 'Y'
-- The procedure is called by various Oracle Projects forms to determine
-- whether an action can be performed on a record that has been imported
-- from an external project management system

l_old_stack varchar2(630);
l_field_value_allowed_flag  VARCHAR2(1);
l_field_value_code          VARCHAR2(30);
l_dummy                     VARCHAR2(1);

CURSOR l_control_actions_csr IS
SELECT NVL(field_value_allowed_flag,'N')
FROM pa_pm_control_actions
WHERE action = p_action;


CURSOR l_control_rules_csr IS
Select 'x'
FROM pa_pm_product_control_rules pc,
     pa_pm_control_actions pa
WHERE pa.action = p_action
AND pa.control_rule_id = pc.control_rule_id
AND pc.pm_product_code = p_pm_product_code
AND NVL(l_field_value_code,'N') = NVL(pc.field_value_code,'N')
AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE))
AND TRUNC(NVL(end_date_active,SYSDATE));

BEGIN
    l_old_stack := p_error_stack;
    p_error_code := 0;
    p_error_stack := p_error_stack ||
    '->PA_PM_CONTROLS.Action_Allowed';
    IF p_action IS NULL THEN
       p_error_code := 10;
       p_error_stage := 'PA_PM_ACTION_NAME_REQD';
       RETURN;
    END IF ;

    IF p_pm_product_code IS NULL THEN
       p_error_code := 11;
       p_error_stage := 'PA_PM_PRODUCT_CODE_REQD';
       RETURN;
    END IF ;
    p_error_stage := 'Select nvl(field_value_allowed_flag,N) from '||
                     'pa_pm_control_actions';

--  Check whether the passed action is a valid one and get the
--  field_value_allowed_flag

    OPEN l_control_actions_csr;
    FETCH l_control_actions_csr INTO l_field_value_allowed_flag;
    IF l_control_actions_csr%NOTFOUND THEN
       p_error_code := 12;
       p_error_stage := 'PA_PM_ACTION_NAME_INVALID';
       CLOSE l_control_actions_csr;
       RETURN;
    ELSE
       CLOSE l_control_actions_csr;
    END IF;

-- If the field_value_allowed_flag is 'N' ,then ignore whatever is
-- passed for p_field_value_code

    IF l_field_value_allowed_flag = 'N' THEN
       l_field_value_code := NULL;
    ELSE
       l_field_value_code := p_field_value_code;
    END IF;

    p_error_stage :=
    'Select x from pa_pm_product_control_rules,pa_pm_control_actions';

-- If a record is found , then return 'N' else return 'Y'

    OPEN l_control_rules_csr;
    FETCH l_control_rules_csr INTO l_dummy;
    IF l_control_rules_csr%NOTFOUND THEN
       p_action_allowed := 'Y';
    ELSE
       p_action_allowed := 'N';
    END IF;
    CLOSE l_control_rules_csr;

-- Restore the old stack

    p_error_stack := l_old_stack;

EXCEPTION

     WHEN OTHERS THEN
        p_error_code := SQLCODE;
	-- 4537865 RESET Other OUT PARAMS also
	p_error_stack := p_error_stack || '->' || SUBSTRB(SQLERRM,1,100);
	p_action_allowed := 'N';
	-- p_error_stage should not be reset

END Action_Allowed;

   Procedure Get_Project_Actions_Allowed (
                              p_pm_product_code              IN VARCHAR2,
                              p_delete_project_allowed      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_proj_num_allowed     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_proj_name_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_proj_desc_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_proj_dates_allowed   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_proj_status_allowed  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_proj_manager_allowed OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_proj_org_allowed     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_add_task_allowed            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_delete_task_allowed         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_task_num_allowed     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_task_name_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_task_dates_allowed   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_task_desc_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_parent_task_allowed  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_task_org_allowed     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_error_code                  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              p_error_stack              IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_error_stage              IN OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
-- This is a specific API being called by the Projects form
-- It returns 16 flags pertaining to project and tasks
-- indicating whether the action is allowed to be performed in Oracle Projects
-- The rules are set up , for each project management product
-- by system administrators . If an active record is found for the given
-- product code and action ,then the procedure returns the relevant flag
-- as 'N', else it returns 'Y'
-- The procedure is called only by the Projects form to determine
-- whether such actions can be performed on a project that has been imported
-- from an external project management system

   l_old_stack varchar2(630);
   TYPE actiontabtype IS TABLE OF pa_pm_control_actions.action%TYPE
                      INDEX BY BINARY_INTEGER;
   l_action actiontabtype;
   l_dummy  VARCHAR2(1);

BEGIN
         l_old_stack := p_error_stack;
         p_error_code := 0;
         p_error_stack := p_error_stack ||
         '->PA_PM_CONTROLS.Get_Project_Actions_Allowed';

         p_delete_project_allowed      := 'Y';
         p_update_proj_num_allowed     := 'Y';
         p_update_proj_name_allowed    := 'Y';
         p_update_proj_desc_allowed    := 'Y';
         p_update_proj_dates_allowed   := 'Y';
         p_update_proj_status_allowed  := 'Y';
         p_update_proj_manager_allowed := 'Y';
         p_update_proj_org_allowed     := 'Y';
         p_add_task_allowed            := 'Y';
         p_delete_task_allowed         := 'Y';
         p_update_task_num_allowed     := 'Y';
         p_update_task_name_allowed    := 'Y';
         p_update_task_dates_allowed   := 'Y';
         p_update_task_desc_allowed    := 'Y';
         p_update_parent_task_allowed  := 'Y';
         p_update_task_org_allowed     := 'Y';

         l_action(1)  := 'DELETE_PROJECT';
         l_action(2)  := 'UPDATE_PROJECT_NUMBER';
         l_action(3)  := 'UPDATE_PROJECT_NAME';
         l_action(4)  := 'UPDATE_PROJECT_DESCRIPTION';
         l_action(5)  := 'UPDATE_PROJECT_DATES';
         l_action(6)  := 'UPDATE_PROJECT_STATUS';
         l_action(7)  := 'UPDATE_PROJECT_MANAGER';
         l_action(8)  := 'UPDATE_PROJECT_ORGANIZATION';
         l_action(9)  := 'ADD_TASK';
         l_action(10) := 'DELETE_TASK';
         l_action(11) := 'UPDATE_TASK_NUMBER';
         l_action(12) := 'UPDATE_TASK_NAME';
         l_action(13) := 'UPDATE_TASK_DATES';
         l_action(14) := 'UPDATE_TASK_DESCRIPTION';
         l_action(15) := 'UPDATE_PARENT_TASK';
         l_action(16) := 'UPDATE_TASK_ORGANIZATION';

         FOR i IN 1..16 LOOP

           BEGIN
              p_error_stage :=
             'Select x from pa_pm_product_control_rules,pa_pm_control_actions';

              SELECT 'x' INTO l_dummy
              FROM pa_pm_product_control_rules pc,
                   pa_pm_control_actions pa
              WHERE pa.action = l_action(i)
              AND pa.control_rule_id = pc.control_rule_id
              AND pc.pm_product_code = p_pm_product_code
              AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE))
              AND TRUNC(NVL(end_date_active,SYSDATE));

              IF i = 1 THEN
                 p_delete_project_allowed      := 'N';
              ELSIF i = 2 THEN
                 p_update_proj_num_allowed     := 'N';
              ELSIF i = 3 THEN
                 p_update_proj_name_allowed    := 'N';
              ELSIF i = 4 THEN
                 p_update_proj_desc_allowed    := 'N';
              ELSIF i = 5 THEN
                 p_update_proj_dates_allowed   := 'N';
              ELSIF i = 6 THEN
                 p_update_proj_status_allowed  := 'N';
              ELSIF i = 7 THEN
                 p_update_proj_manager_allowed := 'N';
              ELSIF i = 8 THEN
                 p_update_proj_org_allowed     := 'N';
              ELSIF i = 9 THEN
                 p_add_task_allowed            := 'N';
              ELSIF i = 10 THEN
                 p_delete_task_allowed         := 'N';
              ELSIF i = 11 THEN
                 p_update_task_num_allowed     := 'N';
              ELSIF i = 12 THEN
                 p_update_task_name_allowed    := 'N';
              ELSIF i = 13 THEN
                 p_update_task_dates_allowed   := 'N';
              ELSIF i = 14 THEN
                 p_update_task_desc_allowed    := 'N';
              ELSIF i = 15 THEN
                 p_update_parent_task_allowed  := 'N';
              ELSIF i = 16 THEN
                 p_update_task_org_allowed     := 'N';
              END IF;

           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   NULL;
              WHEN OTHERS THEN
                 p_error_code := SQLCODE;
           END ;

       END LOOP;

-- Restore the old stack

    p_error_stack := l_old_stack;

EXCEPTION

     WHEN OTHERS THEN
        p_error_code := SQLCODE;
      -- 4537865 : RESET OTHER OUT PARAMS Also.
      p_delete_project_allowed      :=  'N' ;
      p_update_proj_num_allowed     :=  'N' ;
      p_update_proj_name_allowed    :=  'N' ;
      p_update_proj_desc_allowed    :=  'N' ;
      p_update_proj_dates_allowed   :=  'N' ;
      p_update_proj_status_allowed  :=  'N' ;
      p_update_proj_manager_allowed :=  'N' ;
      p_update_proj_org_allowed     :=  'N' ;
      p_add_task_allowed            :=  'N' ;
      p_delete_task_allowed         :=  'N' ;
      p_update_task_num_allowed     :=  'N' ;
      p_update_task_name_allowed    :=  'N' ;
      p_update_task_dates_allowed   :=  'N' ;
      p_update_task_desc_allowed    :=  'N' ;
      p_update_parent_task_allowed  :=  'N' ;
      p_update_task_org_allowed     :=  'N' ;

      p_error_stack := p_error_stack || '->' || SUBSTRB(SQLERRM,1,100) ;
      -- Should not reset p_error_stage
END Get_Project_Actions_Allowed;


   Procedure Get_Billing_Actions_Allowed (
                              p_pm_product_code             IN VARCHAR2,
                              p_update_agreement_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_delete_agreement_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_add_funding_allowed         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_funding_allowed      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_delete_funding_allowed      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_error_code                  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              p_error_stack              IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_error_stage              IN OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
/* *****************************************************************************
-- This is a specific API being called by the Agreement/Funding Form
-- It returns 5 flags pertaining to Agreements and Fundings
-- indicating whether the action is allowed to be performed in Oracle Projects
-- The rules are set up , for each project management product
-- by system administrators . If an active record is found for the given
-- product code and action ,then the procedure returns the relevant flag
-- as 'N', else it returns 'Y'
-- The procedure is called only by the Projects form to determine
-- whether such actions can be performed on a project that has been imported
-- from an external project management system
   ***************************************************************************** */

   l_old_stack varchar2(630);
   TYPE actiontabtype IS TABLE OF pa_pm_control_actions.action%TYPE
                      INDEX BY BINARY_INTEGER;
   l_action actiontabtype;
   l_dummy  VARCHAR2(1);

BEGIN
         l_old_stack := p_error_stack;
         p_error_code := 0;
         p_error_stack := p_error_stack ||
         '->PA_PM_CONTROLS.Get_Billing_Actions_Allowed';

         p_update_agreement_allowed    := 'Y';
         p_delete_agreement_allowed    := 'Y';
         p_add_funding_allowed         := 'Y';
         p_update_funding_allowed      := 'Y';
         p_delete_funding_allowed      := 'Y';

         l_action(1)  := 'UPDATE_AGREEMENT';
         l_action(2)  := 'DELETE_AGREEMENT';
         l_action(3)  := 'ADD_FUNDING';
         l_action(4)  := 'UPDATE_FUNDING';
         l_action(5)  := 'DELETE_FUNDING';

         FOR i IN 1..5 LOOP

           BEGIN
              p_error_stage :=
             'Select x from pa_pm_product_control_rules,pa_pm_control_actions';

              SELECT 'x' INTO l_dummy
              FROM pa_pm_product_control_rules pc,
                   pa_pm_control_actions pa
              WHERE pa.action = l_action(i)
              AND pa.control_rule_id = pc.control_rule_id
              AND pc.pm_product_code = p_pm_product_code
              AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE))
              AND TRUNC(NVL(end_date_active,SYSDATE));

              IF i = 1 THEN
                 p_update_agreement_allowed    := 'N';
              ELSIF i = 2 THEN
                 p_delete_agreement_allowed    := 'N';
              ELSIF i = 3 THEN
                 p_add_funding_allowed         := 'N';
              ELSIF i = 4 THEN
                 p_update_funding_allowed      := 'N';
              ELSIF i = 5 THEN
                 p_delete_funding_allowed      := 'N';
              END IF;

           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   NULL;
              WHEN OTHERS THEN
                 p_error_code := SQLCODE;
           END ;

       END LOOP;

-- Restore the old stack

    p_error_stack := l_old_stack;

EXCEPTION

     WHEN OTHERS THEN
        p_error_code := SQLCODE;
	-- 4537865 : RESET other out params too.
        p_update_agreement_allowed    := 'N' ;
        p_delete_agreement_allowed    := 'N' ;
        p_add_funding_allowed         := 'N' ;
        p_update_funding_allowed      := 'N' ;
        p_delete_funding_allowed      := 'N' ;
	p_error_stack := p_error_stack || '->' || SUBSTRB(SQLERRM,1,100);
END Get_Billing_Actions_Allowed;

/* ***********************************************************************************************
--This is a specific procedure called from event form.
--It returns two flags depending on whethere an event
--that originated from an external system can be updated
--or not and whether these events can be deleted.
*************************************************************************************************  */
PROCEDURE GET_EVENT_ACTIONS_ALLOWED
                (P_PM_PRODUCT_CODE          	IN 	VARCHAR2,
                 p_update_Event_allowed      	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                 p_delete_Event_allowed       	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		 p_update_event_bill_hold 	OUT NOCOPY VARCHAR2, /* added for bug 6870421*/
                 P_ERROR_CODE	           	OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
                 P_ERROR_STACK              	IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                 P_ERROR_STAGE	           	IN OUT	NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
IS

TYPE actiontabtype IS TABLE OF pa_pm_control_actions.action%TYPE INDEX BY BINARY_INTEGER;
l_action actiontabtype;
l_dummy      VARCHAR2(1);

Begin
P_update_event_allowed :='Y';
P_delete_event_allowed := 'Y';
p_update_event_bill_hold :='Y'; /* added for bug 6870421*/
l_action(1) := 'UPDATE_EVENT';
l_action(2) := 'DELETE_EVENT';
l_action(3) := 'UPDATE_EVENT_BILL_HOLD'; /* added for bug 6870421*/
--4537865
P_ERROR_STAGE := P_ERROR_STAGE || '-> Inside GET_EVENT_ACTIONS_ALLOWED ' ;
FOR I IN 1..3 LOOP
BEGIN
P_ERROR_STAGE := 'SELECT x INTO l_dummy FROM pa_pm_product_control_rules pc,pa_pm_control_actions pa' ; --4537865

	         SELECT 'x' INTO l_dummy
              FROM pa_pm_product_control_rules pc,
                   	  pa_pm_control_actions pa
              WHERE pa.action = l_action(i)
              AND pa.control_rule_id = pc.control_rule_id
              AND pc.pm_product_code = p_pm_product_code
              AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE))
              AND TRUNC(NVL(end_date_active,SYSDATE));

              IF i = 1 THEN
                 p_update_event_allowed    := 'N';
              ELSIF i = 2 THEN
                 p_delete_event_allowed    := 'N';
              ELSIF i = 3 THEN /* added for bug 6870421*/
                 p_update_event_bill_hold  := 'N';
              END IF;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		NULL;
	END;
END LOOP;
-- 4537865
EXCEPTION
WHEN OTHERS THEN
	P_ERROR_CODE := SQLCODE ;
	p_update_event_allowed    := 'N';
	p_delete_event_allowed    := 'N';
        P_ERROR_STACK := P_ERROR_STACK || '->' || SUBSTRB(SQLERRM,1,100);

END GET_EVENT_ACTIONS_ALLOWED;
END PA_PM_CONTROLS;

/
