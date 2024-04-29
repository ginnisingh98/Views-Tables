--------------------------------------------------------
--  DDL for Package Body QA_SOLUTION_CAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SOLUTION_CAR_PKG" as
/* $Header: qasocorb.pls 120.0.12000000.2 2007/02/16 11:00:16 skolluku ship $ */

 -- Package Private Variables.

 -- Bug 3684073. Modified the constants to VARCHAR2 below.
 -- We are no longer using mfg_lookups to derive the lookup_code.
 -- g_lookup_yes CONSTANT NUMBER := 1;  -- 1 is lookup_code for 'YES' in mfg_lookups.
 -- g_lookup_no  CONSTANT NUMBER := 2;  -- 2 is lookup_code for 'NO' in mfg_lookups.

 g_lookup_yes CONSTANT VARCHAR2(3) := 'YES';
 g_lookup_no  CONSTANT VARCHAR2(3) := 'NO';

 g_success CONSTANT VARCHAR2(10) := 'SUCCESS';
 g_failed  CONSTANT VARCHAR2(10) := 'FAILED';
 g_warning CONSTANT VARCHAR2(10) := 'WARNING';


-------------------------------------------------------------------------------
--  Forward declaration of Local functions.
-------------------------------------------------------------------------------

 FUNCTION get_mfg_lookups_value (p_meaning     VARCHAR2,
                                 p_lookup_type VARCHAR2)  RETURN NUMBER;

 FUNCTION get_organization_id (p_organization_code VARCHAR2)  RETURN NUMBER;
 FUNCTION get_plan_id(p_plan_name VARCHAR2)  RETURN NUMBER;



-------------------------------------------------------------------------------
--  Create a new ECO (Engineering Change Order)
-------------------------------------------------------------------------------
--  Start of Comments
--  API name    ENG_CHANGE_ORDER
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--     p_change_notice             => New ECO Name .
--     p_change_type               => ECO Type.
--     p_description               => Description of ECO.
--     p_approval_list             => Name of the Approval List.
--     p_requestor                 => Requestor of ECO.
--     p_eco_department            => ECO Department name.
--     p_reason_code               => ECO Reason Code.
--     p_priority_code             => ECO Priority Code.
--     p_collection_id             => Collection Identifier
--     p_occurrence                => Occurrence
--     p_plan_name                 => Collection Plan Name
--     p_organization_code         => Organization Code, from which transaction happens
--     p_launch_action             => This takes two values(Yes/No)
--                                    Pass a value of 'Yes' to successfully create an ECO.
--     p_action_fired              => This takes two values(Yes/No)
--                                    Pass a value of 'No' to successfully create an ECO.
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  We are performing all the below activities here
--
--    1. Get the Collection element values.
--    2. Call the ENG_CHANGE_ORDER_INT () to call the PROCESS_ECO () API.
--    4. Get the results and perform the handshaking. Call the procedure
--       WRITE_BACK() for performing the same.
--
--  End of Comments
--
--  Bug Fixes
--
--    Bug 2714477 - Made changes in the way ECO_Rec_Type is populated. Status_type and
--                  approval_status_type got changed to status_name and approval_status_
--                  name respectively in 11.5.9 ENG Codeline. Also the requestor accepts
--                  the full name of the user instead of employee number.
--
--    Bug 2731618 - ENG expects the requestor to be fnd_user name instead of the full_name
--                  in 11.5.9 codeline. Made the changes in API to resolve this.
--
--
-------------------------------------------------------------------------------


 PROCEDURE ENG_CHANGE_ORDER(
                  p_change_notice     IN VARCHAR2,
                  p_change_type       IN VARCHAR2,
                  p_description       IN VARCHAR2,
                  p_approval_list     IN VARCHAR2,
                  p_reason_code       IN VARCHAR2,
                  p_requestor         IN VARCHAR2,
                  p_eco_department    IN VARCHAR2,
                  p_priority_code     IN VARCHAR2,
                  p_collection_id     IN NUMBER,
                  p_occurrence        IN NUMBER,
                  p_organization_code IN VARCHAR2,
                  p_plan_name         IN VARCHAR2,
                  p_launch_action     IN VARCHAR2,
                  p_action_fired      IN VARCHAR2) IS


  -- Bug 3684073. These variables are no longer required.
  -- l_launch_action   NUMBER;
  -- l_action_fired    NUMBER;

  -- Bug 2714477. Employee number is no longer required.
  -- l_emp_num         VARCHAR2(30);

  l_organization_id NUMBER;
  l_plan_id         NUMBER;
  l_result          VARCHAR2(10);

  -- Added for bug 2731618.
  l_user_name       VARCHAR2(100);

  /* Bug 2714477. The below cursor is no more needed as we are passing the full
     name of the requestor to the ECO API.

  CURSOR emp_num IS
     SELECT employee_num
     FROM   mtl_employees_current_view
     WHERE  full_name = p_requestor;
  */

  -- Bug 2731618. Added the below cursor to fetch the fnd_user name from
  -- the full_name of the employee.

  CURSOR emp_user IS
     SELECT fu.user_name
       FROM hr_employees_current_v hecv, fnd_user fu
      WHERE hecv.employee_id = fu.employee_id
        AND hecv.full_name = p_requestor;


 BEGIN

  -- Get the value entered in launch_action and Action_fired
  -- Collection elements.

  -- Bug 3684073. We should not derive the lookup_code value from
  -- mfg_lookups because the value passed to this api would be the
  -- qa_plan_char_value_lookups.short_code, which is not a translated
  -- column. The mfg_lookups view would have the lookup meaning in the
  -- language used in the current session.
  --
  -- Commented the below piece of code and compared p_launch_action
  -- and p_action_fired parameters below with the new constants to resolve
  -- the value entered. kabalakr.

  -- l_launch_action := get_mfg_lookups_value(p_launch_action,'SYS_YES_NO');
  -- l_action_fired  := get_mfg_lookups_value(p_action_fired,'SYS_YES_NO');

  -- The Action Code should get executed only if
  -- Launch_action is 'Yes' and Action_fired is 'No'

  IF (upper(p_launch_action) = g_lookup_yes AND upper(p_action_fired) = g_lookup_no) THEN
    NULL;

  ELSE
    -- dont fire the action.
    RETURN;
  END IF;

  -- Get the plan_id, org_id now. We need it for handshaking.

  l_organization_id  := get_organization_id(p_organization_code);
  l_plan_id          := get_plan_id(p_plan_name);

  IF (l_plan_id = -1 OR l_organization_id = -1) THEN

      -- We may need to populate appropriate error message here before return.
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Update the Disposition Status to 'Pending'.

  QA_SOLUTION_DISPOSITION_PKG.UPDATE_STATUS(l_plan_id, p_collection_id, p_occurrence);

  -- Get the Employee_num of the Requestor only if its entered.


 /* Bug 2714477. The below code is no more needed as we are passing the full
     name of the requestor to the ECO API.

  IF p_requestor IS NOT NULL THEN
    OPEN  emp_num;
    FETCH emp_num INTO l_emp_num;
    CLOSE emp_num;
  END IF;
  */

  -- Bug 2731618. Added the below code to fetch the fnd_user name corresponding
  -- to the requestor full_name onto l_user_name. If a corresponding fnd_user name
  -- does not exist, assign NULL to l_user_name. kabalakr.

  IF p_requestor IS NOT NULL THEN
    OPEN  emp_user;
    FETCH emp_user INTO l_user_name;

    IF (emp_user%NOTFOUND) THEN
       l_user_name := NULL;
    END IF;

    CLOSE emp_user;

  END IF;

  -- Call the ENG_CHANGE_ORDER_INT(). This procedure creates a struct of ECO_REC_TYPE.
  -- And will call the Process_ECO () API to process the ECO Header Information.

  -- Bug 2717744. Remove the l_emp_num from the below function call. Instead, we are
  -- passing the full name of the employee.

  -- Bug 2731618. Removed p_requestor from the below function call. Instead, passed
  -- l_user_name, which contains the fnd_user_name of the employee.

  l_result := ENG_CHANGE_ORDER_INT(
                        p_change_notice,
 	                p_change_type,
                        p_description,
                        p_approval_list,
                        p_reason_code,
                        l_user_name,
                        p_eco_department,
                        p_priority_code,
                        p_organization_code);


  -- Call WRITE_BACK() for handshaking the outcome onto the Collection Plan.
  -- If the ECO Creation is successful, we need to write back the new ECO
  -- name onto the hardcoded element column ECO_NAME.

  IF (l_result = g_success) THEN

     QA_SOLUTION_DISPOSITION_PKG.WRITE_BACK(
             p_plan_id        =>  l_plan_id,
             p_collection_id  =>  p_collection_id,
             p_occurrence     =>  p_occurrence,
             p_status         =>  l_result,
             p_eco_name       =>  p_change_notice);

  ELSE

     QA_SOLUTION_DISPOSITION_PKG.WRITE_BACK(
             p_plan_id        =>  l_plan_id,
             p_collection_id  =>  p_collection_id,
             p_occurrence     =>  p_occurrence,
             p_status         =>  l_result);

  END IF;


 END ENG_CHANGE_ORDER;



 FUNCTION ENG_CHANGE_ORDER_INT(
                     p_change_notice   VARCHAR2,
                     p_change_type     VARCHAR2,
                     p_description     VARCHAR2,
                     p_approval_list   VARCHAR2,
                     p_reason_code     VARCHAR2,
                     p_requestor       VARCHAR2,
                     p_eco_department  VARCHAR2,
                     p_priority_code   VARCHAR2,
                     p_org_code        VARCHAR2)

 RETURN VARCHAR2 IS

 PRAGMA AUTONOMOUS_TRANSACTION;

  l_eco_rec               Eng_Eco_Pub.Eco_Rec_Type;
  l_eco_revision_tbl      Eng_Eco_Pub.Eco_Revision_Tbl_Type;
  l_revised_item_tbl      Eng_Eco_Pub.Revised_Item_Tbl_Type;
  l_rev_component_tbl     Bom_Bo_Pub.Rev_Component_Tbl_Type;
  l_sub_component_tbl     Bom_Bo_Pub.Sub_Component_Tbl_Type;
  l_ref_designator_tbl    Bom_Bo_Pub.Ref_Designator_Tbl_Type;
  l_rev_operation_tbl     Bom_Rtg_Pub.Rev_Operation_Tbl_Type;
  l_rev_op_resource_tbl   Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type;
  l_rev_sub_resource_tbl  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type;
  l_return_status         VARCHAR2(10);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_Error_Table           Error_Handler.Error_Tbl_Type;
  l_Message_text          VARCHAR2(2000);

  -- Bug 2714477. Added the below variables and cursor c1.

  l_status_name           VARCHAR2(80);
  l_approval_status_name  VARCHAR2(80);

  CURSOR c1(type VARCHAR2) IS
    SELECT meaning
      FROM mfg_lookups
     WHERE lookup_type = type
       AND lookup_code = 1;

 BEGIN

   -- Bug 2714477. Get the Status name and Approval status name
   -- from mfg_lookups.

   OPEN  c1('ECG_ECN_STATUS');
   FETCH c1 INTO l_status_name;
   CLOSE c1;

   OPEN  c1('ENG_ECN_APPROVAL_STATUS');
   FETCH c1 INTO l_approval_status_name;
   CLOSE c1;


   -- Fill in the Eco_Rec_Type structure to pass to the API.

   -- Bug 2714477. Status_type and approval_status_type changed to status_name
   -- and approval_status_name respectively in 11.5.9 ENG codeline. Hence
   -- these changes are made here too. kabalakr.

   l_eco_rec.eco_name             := p_change_notice;
   l_eco_rec.organization_code    := p_org_code;
   l_eco_rec.change_type_code     := p_change_type;
   l_eco_rec.status_name          := l_status_name;  -- 1 for 'Open'.
   l_eco_rec.approval_list_name   := p_approval_list;
   l_eco_rec.approval_status_name := l_approval_status_name; -- 1 for 'Not submitted for Approval'.
   l_eco_rec.requestor            := p_requestor;
   l_eco_rec.priority_code        := p_priority_code;
   l_eco_rec.eco_department_name  := p_eco_department;
   l_eco_rec.reason_code          := p_reason_code;
   l_eco_rec.description          := p_description;
   l_eco_rec.transaction_type     := 'CREATE';
   --
   -- Bug 5869696
   -- The Eco_Rec_Type structure got modified in the PUBLIC API Eng_Eco_PUB
   -- since a new parameter plm_or_erp_change is added to it.
   -- Quality should pass the value 'ERP' to the API for this parameter
   -- while posting the CAR.
   -- skolluku Fri Feb 16 2007
   --
   l_eco_rec.plm_or_erp_change    := 'ERP';

   -- Calling the Process_ECO API.

   Eng_Eco_PUB.Process_Eco
   (  p_api_version_number => 1.0,
      p_init_msg_list => FALSE,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      p_bo_identifier => 'ECO',
      p_ECO_rec => l_eco_rec,
      x_ECO_rec => l_eco_rec,
      x_eco_revision_tbl => l_eco_revision_tbl,
      x_revised_item_tbl => l_revised_item_tbl,
      x_rev_component_tbl => l_rev_component_tbl,
      x_sub_component_tbl => l_sub_component_tbl,
      x_ref_designator_tbl => l_ref_designator_tbl,
      x_rev_operation_tbl => l_rev_operation_tbl,
      x_rev_op_resource_tbl => l_rev_op_resource_tbl,
      x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
   );

   -- Assign the disposition statuses as return value.

   IF (l_return_status = 'S') THEN
       l_return_status := g_success;

   ELSE
       l_return_status := g_failed;
   END IF ;

   -- Commit before the return.
   COMMIT;

   RETURN l_return_status;


 END ENG_CHANGE_ORDER_INT;



 FUNCTION get_mfg_lookups_value (p_meaning     VARCHAR2,
                                 p_lookup_type VARCHAR2)
 RETURN NUMBER IS

   l_lookup_code VARCHAR2(2);

   Cursor meaning_cur IS
      SELECT lookup_code
        FROM mfg_lookups
       WHERE lookup_type = p_lookup_type
         AND upper(meaning) = upper(ltrim(rtrim(p_meaning)));
 BEGIN
   OPEN meaning_cur;
   FETCH meaning_cur INTO l_lookup_code;
   CLOSE meaning_cur;

   RETURN l_lookup_code;

 END get_mfg_lookups_value;



 FUNCTION get_plan_id(p_plan_name VARCHAR2)
   RETURN NUMBER IS

   l_plan_id NUMBER;

   CURSOR plan_cur IS
      SELECT plan_id
        FROM qa_plans
       WHERE name = p_plan_name;
 BEGIN

    OPEN plan_cur;
    FETCH plan_cur INTO l_plan_id;
    CLOSE plan_cur;

    RETURN l_plan_id;

 END get_plan_id;


 FUNCTION get_organization_id (p_organization_code VARCHAR2)
    RETURN NUMBER IS

   l_org_id NUMBER;

   CURSOR org_cur IS
      SELECT organization_id
        FROM mtl_parameters
       WHERE organization_code = p_organization_code;

 BEGIN

    OPEN org_cur;
    FETCH org_cur INTO l_org_id;
    CLOSE org_cur;

    RETURN l_org_id;

 END Get_organization_id;


END QA_SOLUTION_CAR_PKG;


/
