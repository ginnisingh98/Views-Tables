--------------------------------------------------------
--  DDL for Package Body PA_PM_FUNCTION_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PM_FUNCTION_SECURITY_PUB" AS
/*$Header: PAPMFSPB.pls 120.2 2005/08/19 16:42:38 mwasowic ship $*/

g_module_name VARCHAR2(100) := 'pa.plsql.PA_PM_FUNCTION_SECURITY_PUB';

PROCEDURE check_function_security
     (p_api_version_number  IN NUMBER,
      p_responsibility_id  IN NUMBER,
      p_function_name      IN VARCHAR2,
      p_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
      p_msg_data           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      p_return_status     OUT NOCOPY VARCHAR2 ,      --File.Sql.39 bug 4440895
      p_function_allowed  OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

--CURSOR l_fnd_function_csr IS
--SELECT 'x'
--FROM fnd_form_functions ff,
--     fnd_resp_functions fr
--WHERE ff.function_name = p_function_name
--AND   ff.function_id     = fr.action_id
--AND   fr.responsibility_id = p_responsibility_id;

l_dummy        VARCHAR2(1);
l_api_version_number    CONSTANT       NUMBER      :=  1.0;
l_api_name              CONSTANT       VARCHAR2(30):=
                        'check_function_security';
l_return_status                        VARCHAR2(1);
l_function_allowed                     VARCHAR2(1) := NULL;

--bug2442069
l_object_type                          VARCHAR2(12) := NULL;
--bug 2442069

BEGIN
    -- The caching logic for checking the function security would not let the
    -- initialisation of x_return_status happen. Hence moved this up
    p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Included call to Check_Global_Vars, to check for global variables and
  -- see if check_function_security procedure has already been called once.
  -- This way, we are avoiding multiple calls to this procedure
  -- check_function_security         S Sanckar 09-Jul-99

  Check_Global_Vars ( p_function_name    => p_function_name,
                  p_function_allowed => p_function_allowed,
                        p_found_or_not     => G_found_or_not);

  IF G_found_or_not = 'N' THEN


  -- Standard Api compatibility call
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --p_return_status := FND_API.G_RET_STS_SUCCESS; Moved this above

   -- function security is enforced in Applications by excluding
   -- a function from a given responsibility. Hence, if we get a
   -- row for the cursor , then the function is not allowed

    /* Commented out the following code for bug 2442069 and replaced the logic. Please see below.

     IF fnd_function.test(p_function_name) THEN
         p_function_allowed := 'Y';
         l_function_allowed := 'Y';
     ELSE
           p_function_allowed := 'N';
           l_function_allowed := 'N';
     END IF;*/

   --Added the following code replacing the above logic to incorporate advanced proejct security
   --bug 2442069
   IF PA_INTERFACE_UTILS_PUB.G_ADVANCED_PROJ_SEC_FLAG = 'N'
   THEN

     -- -- dbms_output.put_line( 'Default Function Security is enforced! ' );
     IF fnd_function.test(p_function_name) THEN
           p_function_allowed := 'Y';
           l_function_allowed := 'Y';
     ELSE
           p_function_allowed := 'N';
           l_function_allowed := 'N';
     END IF;
   ELSE
       -- -- dbms_output.put_line( 'WATCH Advanced Project Security is enforced! ' );
       IF PA_INTERFACE_UTILS_PUB.G_PROJECt_ID IS NULL
       THEN
           l_object_type := null;
       ELSE
           l_object_type := 'PA_PROJECTS';
       END IF;
       IF  PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
               p_privilege     => p_function_name
              ,p_object_name   => l_object_type
              ,p_object_key    => PA_INTERFACE_UTILS_PUB.G_PROJECt_ID
            ) = 'T'
       THEN
           p_function_allowed := 'Y';
           l_function_allowed := 'Y';
       ELSE
           p_function_allowed := 'N';
           l_function_allowed := 'N';
       END IF;
   END IF;
   --bug 2442069

--   OPEN l_fnd_function_csr;
--   FETCH l_fnd_function_csr INTO l_dummy;
--   IF l_fnd_function_csr%FOUND THEN
--      p_function_allowed := 'N';
--   ELSE
--      p_function_allowed := 'Y';
--   END IF;
--   CLOSE l_fnd_function_csr;

   -- Included call to Set_Global_Vars, to set the global variables
   -- which are used in checking if check_function_security procedure has
   -- already been called. This way, we are avoiding multiple calls to
   -- this procedure check_function_security         S Sanckar 09-Jul-99

   Set_Global_Vars ( p_function_name    => p_function_name,
                 p_function_allowed => l_function_allowed);

    -- dbms_output.put_line('x return status is '||p_return_status);

  END IF;  /* End of G_found_or_not IF condition */

   -- dbms_output.put_line('x return status is '||p_return_status);

EXCEPTION

      WHEN FND_API.G_EXC_ERROR
      THEN

            p_return_status := FND_API.G_RET_STS_ERROR;

            FND_MSG_PUB.Count_And_Get
                  (   p_count       =>    p_msg_count ,
                      p_data        =>    p_msg_data  );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR
      THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get
                  (   p_count       =>    p_msg_count ,
                      p_data        =>    p_msg_data  );

      WHEN OTHERS
      THEN

      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
            FND_MSG_PUB.add_exc_msg
                        ( p_pkg_name            => G_PKG_NAME
                        , p_procedure_name      => l_api_name     );

      END IF;

      FND_MSG_PUB.Count_And_Get
                  (   p_count       =>    p_msg_count ,
                      p_data        =>    p_msg_data  );

END check_function_security;

-- New Procedure added to use global variables and thus avoid
-- repeated calls to Check_Function_Security   S Sanckar 09-Jul-99

PROCEDURE Check_Global_Vars
     (p_function_name      IN VARCHAR2,
      p_function_allowed  OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
      p_found_or_not      OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

BEGIN

  p_found_or_not := 'N';

  IF p_function_name = 'PA_PM_CREATE_PROJECT' AND
     G_Create_Project   IS NOT NULL THEN
       p_function_allowed := G_Create_Project;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPDATE_PROJECT' AND
     G_Update_Project   IS NOT NULL THEN
       p_function_allowed := G_Update_Project;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_DELETE_PROJECT' AND
     G_Delete_Project   IS NOT NULL THEN
       p_function_allowed := G_Delete_Project;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPDATE_PROJ_PROGRESS' AND
     G_Update_Proj_Progress   IS NOT NULL THEN
       p_function_allowed := G_Update_Proj_Progress;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_ADD_TASK' AND
     G_Add_Task   IS NOT NULL THEN
       p_function_allowed := G_Add_Task;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPDATE_TASK' AND
     G_Update_Task   IS NOT NULL THEN
       p_function_allowed := G_Update_Task;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_MODIFY_TOP_TASK' AND
     G_Modify_Top_Task   IS NOT NULL THEN
       p_function_allowed := G_Modify_Top_Task;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_DELETE_TASK' AND
     G_Delete_Task   IS NOT NULL THEN
       p_function_allowed := G_Delete_Task;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_CREATE_DRAFT_BUDGET' AND
     G_Create_Draft_Budget   IS NOT NULL THEN
       p_function_allowed := G_Create_Draft_Budget;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPDATE_BUDGET' AND
     G_Update_Budget   IS NOT NULL THEN
       p_function_allowed := G_Update_Budget;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_BASELINE_BUDGET' AND
     G_Baseline_Budget   IS NOT NULL THEN
       p_function_allowed := G_Baseline_Budget;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_DELETE_DRAFT_BUDGET' AND
     G_Delete_Draft_Budget   IS NOT NULL THEN
       p_function_allowed := G_Delete_Draft_Budget;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_ADD_BUDGET_LINE' AND
     G_Add_Budget_Line   IS NOT NULL THEN
       p_function_allowed := G_Add_Budget_Line;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPDATE_BUDGET_LINE' AND
     G_Update_Budget_Line   IS NOT NULL THEN
       p_function_allowed := G_Update_Budget_Line;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_DELETE_BUDGET_LINE' AND
     G_Delete_Budget_Line   IS NOT NULL THEN
       p_function_allowed := G_Delete_Budget_Line;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPDATE_EARNED_VALUE' AND
     G_Update_Earned_Value   IS NOT NULL THEN
       p_function_allowed := G_Update_Earned_Value;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_CREATE_RESOURCE_LIST' AND
     G_Create_Res_List   IS NOT NULL THEN
       p_function_allowed := G_Create_Res_List;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPDATE_RESOURCE_LIST' AND
     G_Update_Res_List   IS NOT NULL THEN
       p_function_allowed := G_Update_Res_List;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_DELETE_RESOURCE_LIST' AND
     G_Delete_Res_List   IS NOT NULL THEN
       p_function_allowed := G_Delete_Res_List;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_ADD_RESOURCE_LIST_MEMBER' AND
     G_Add_Res_List_Member   IS NOT NULL THEN
       p_function_allowed := G_Add_Res_List_Member;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPD_RESOURCE_LIST_MEMBER' AND
     G_Update_Res_List_Member   IS NOT NULL THEN
       p_function_allowed := G_Update_Res_List_Member;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_DEL_RESOURCE_LIST_MEMBER' AND
     G_Delete_Res_List_Member   IS NOT NULL THEN
       p_function_allowed := G_Delete_Res_List_Member;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_AF_CREATE_AGREEMENT' AND
     G_Create_Agreement   IS NOT NULL THEN
       p_function_allowed := G_Create_Agreement;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_AF_DELETE_AGREEMENT' AND
     G_Delete_Agreement   IS NOT NULL THEN
       p_function_allowed := G_Delete_Agreement;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;


  IF p_function_name = 'PA_AF_UPDATE_AGREEMENT' AND
     G_Update_Agreement   IS NOT NULL THEN
       p_function_allowed := G_Update_Agreement;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_ADD_FUNDING' AND
     G_Add_Funding   IS NOT NULL THEN
       p_function_allowed := G_Add_Funding;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_DELETE_FUNDING' AND
     G_Delete_Funding   IS NOT NULL THEN
       p_function_allowed := G_Delete_Funding;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_UPDATE_FUNDING' AND
     G_Update_Funding   IS NOT NULL THEN
       p_function_allowed := G_Update_Funding;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_INIT_AGREEMENT' AND
     G_Init_Agreement   IS NOT NULL THEN
       p_function_allowed := G_Init_Agreement;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_LOAD_AGREEMENT' AND
     G_Load_Agreement   IS NOT NULL THEN
       p_function_allowed := G_Load_Agreement;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_LOAD_FUNDING' AND
     G_Load_Funding   IS NOT NULL THEN
       p_function_allowed := G_Load_Funding;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_EXE_CRE_AGMT' AND
     G_Exe_Cre_Agmt   IS NOT NULL THEN
       p_function_allowed := G_Exe_Cre_Agmt;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_EXE_UPD_AGMT' AND
     G_Exe_Upd_Agmt   IS NOT NULL THEN
       p_function_allowed := G_Exe_Upd_Agmt;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_FETCH_FUNDING' AND
     G_Fetch_Funding   IS NOT NULL THEN
       p_function_allowed := G_Fetch_Funding;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_CLR_AGREEMENT' AND
     G_Clear_Agreement   IS NOT NULL THEN
       p_function_allowed := G_Clear_Agreement;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_DEL_AGMT_OK' AND
     G_Check_Del_Agmt_Ok   IS NOT NULL THEN
       p_function_allowed := G_Check_Del_Agmt_Ok;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_ADD_FUND_OK' AND
     G_Check_Add_Fund_Ok   IS NOT NULL THEN
       p_function_allowed := G_Check_Add_Fund_Ok;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_DEL_FUND_OK' AND
     G_Check_Del_Fund_Ok   IS NOT NULL THEN
       p_function_allowed := G_Check_Del_Fund_Ok;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_UPD_FUND_OK' AND
     G_Check_Upd_Fund_Ok   IS NOT NULL THEN
       p_function_allowed := G_Check_Upd_Fund_Ok;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  /* Start of code for bug #4317792 */

  IF p_function_name = 'PA_FP_APP_BDGT_MNT_COST_PLAN' AND
     G_FP_Maintain_AC_Plan IS NOT NULL THEN
       p_function_allowed := G_FP_Maintain_AC_Plan;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_FP_BDGT_MNT_COST_PLAN' AND
     G_FP_Maintain_C_Plan IS NOT NULL THEN
       p_function_allowed := G_FP_Maintain_C_Plan;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_FP_FCST_MNT_COST_PLAN' AND
     G_FP_Maintain_FC_Plan IS NOT NULL THEN
       p_function_allowed := G_FP_Maintain_FC_Plan;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_FP_APP_BDGT_MNT_REV_PLAN' AND
     G_FP_Maintain_AR_Plan IS NOT NULL THEN
       p_function_allowed := G_FP_Maintain_AR_Plan;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_FP_BDGT_MNT_REV_PLAN' AND
     G_FP_Maintain_R_Plan IS NOT NULL THEN
       p_function_allowed := G_FP_Maintain_R_Plan;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_FP_FCST_MNT_REV_PLAN' AND
     G_FP_Maintain_FR_Plan IS NOT NULL THEN
       p_function_allowed := G_FP_Maintain_FR_Plan;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_FP_APP_BDGT_BSLN_COST_PLAN' AND
     G_FP_Baseline_AC_Plan IS NOT NULL THEN
       p_function_allowed := G_FP_Baseline_AC_Plan;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_FP_BDGT_BSLN_COST_PLAN' AND
     G_FP_Baseline_C_Plan IS NOT NULL THEN
       p_function_allowed := G_FP_Baseline_C_Plan;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_FP_FCST_BSLN_COST_PLAN' AND
     G_FP_Baseline_FC_Plan IS NOT NULL THEN
       p_function_allowed := G_FP_Baseline_FC_Plan;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_FP_APP_BDGT_BSLN_REV_PLAN' AND
     G_FP_Baseline_AR_Plan IS NOT NULL THEN
       p_function_allowed := G_FP_Baseline_AR_Plan;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_FP_BDGT_BSLN_REV_PLAN' AND
     G_FP_Baseline_R_Plan IS NOT NULL THEN
       p_function_allowed := G_FP_Baseline_R_Plan;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_FP_FCST_BSLN_REV_PLAN' AND
     G_FP_Baseline_FR_Plan IS NOT NULL THEN
       p_function_allowed := G_FP_Baseline_FR_Plan;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_FP_APP_BDGT_MNT_PLAN_LINES' AND
     G_FP_Maintain_AC_AR_Plan_Lines IS NOT NULL THEN
       p_function_allowed := G_FP_Maintain_AC_AR_Plan_Lines;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_FP_BDGT_MNT_PLAN_LINES' AND
     G_FP_Maintain_Plan_Lines IS NOT NULL THEN
       p_function_allowed := G_FP_Maintain_Plan_Lines;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  IF p_function_name = 'PA_FP_FCST_MNT_PLAN_LINES' AND
     G_FP_Maintain_FC_FR_Plan_Lines IS NOT NULL THEN
       p_function_allowed := G_FP_Maintain_FC_FR_Plan_Lines;
       p_found_or_not     := 'Y';
       RETURN;
  END IF;

  /* End of code for bug #4317792 */

END Check_Global_Vars;


-- New Procedure added to set global variables and thus avoid
-- repeated calls to Check_Function_Security   S Sanckar 09-Jul-99

PROCEDURE Set_Global_Vars
     (p_function_name      IN VARCHAR2,
      p_function_allowed   IN VARCHAR2) IS

BEGIN

  IF p_function_name = 'PA_PM_CREATE_PROJECT' THEN
       G_Create_Project := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPDATE_PROJECT' THEN
       G_Update_Project := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_DELETE_PROJECT' THEN
       G_Delete_Project := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPDATE_PROJ_PROGRESS' THEN
       G_Update_Proj_Progress := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_ADD_TASK' THEN
       G_Add_Task := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPDATE_TASK' THEN
       G_Update_Task := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_MODIFY_TOP_TASK' THEN
       G_Modify_Top_Task := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_DELETE_TASK' THEN
       G_Delete_Task := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_CREATE_DRAFT_BUDGET' THEN
       G_Create_Draft_Budget := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPDATE_BUDGET' THEN
       G_Update_Budget := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_BASELINE_BUDGET' THEN
       G_Baseline_Budget := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_DELETE_DRAFT_BUDGET' THEN
       G_Delete_Draft_Budget := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_ADD_BUDGET_LINE' THEN
       G_Add_Budget_Line := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPDATE_BUDGET_LINE' THEN
       G_Update_Budget_Line := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_DELETE_BUDGET_LINE' THEN
       G_Delete_Budget_Line := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPDATE_EARNED_VALUE' THEN
       G_Update_Earned_Value := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_CREATE_RESOURCE_LIST' THEN
       G_Create_Res_List := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPDATE_RESOURCE_LIST' THEN
       G_Update_Res_List := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_DELETE_RESOURCE_LIST' THEN
       G_Delete_Res_List := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_ADD_RESOURCE_LIST_MEMBER' THEN
       G_Add_Res_List_Member := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_UPD_RESOURCE_LIST_MEMBER' THEN
       G_Update_Res_List_Member := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_PM_DEL_RESOURCE_LIST_MEMBER' THEN
       G_Delete_Res_List_Member := p_function_allowed;
       RETURN;
  END IF;

  IF p_function_name = 'PA_AF_CREATE_AGREEMENT' THEN
       G_Create_Agreement:= p_function_allowed ;
       RETURN;
  END IF;

  IF p_function_name = 'PA_AF_DELETE_AGREEMENT' THEN
       G_Delete_Agreement := p_function_allowed ;
       RETURN;
  END IF;


  IF p_function_name = 'PA_AF_UPDATE_AGREEMENT' THEN
       G_Update_Agreement := p_function_allowed ;
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_ADD_FUNDING' THEN
       G_Add_Funding   := p_function_allowed;
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_DELETE_FUNDING' THEN
       G_Delete_Funding := p_function_allowed ;
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_UPDATE_FUNDING' THEN
       G_Update_Funding := p_function_allowed ;
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_INIT_AGREEMENT' THEN
       G_Init_Agreement := p_function_allowed ;
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_LOAD_AGREEMENT' THEN
       G_Load_Agreement    := p_function_allowed ;
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_LOAD_FUNDING' THEN
       G_Load_Funding := p_function_allowed ;
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_EXE_CRE_AGMT' THEN
       G_Exe_Cre_Agmt := p_function_allowed ;
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_EXE_UPD_AGMT' THEN
       G_Exe_Upd_Agmt := p_function_allowed ;
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_FETCH_FUNDING' THEN
       G_Fetch_Funding := p_function_allowed ;
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_CLR_AGREEMENT' THEN
       G_Clear_Agreement := p_function_allowed ;
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_DEL_AGMT_OK' THEN
       G_Check_Del_Agmt_Ok := p_function_allowed;
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_ADD_FUND_OK' THEN
       G_Check_Add_Fund_Ok := p_function_allowed;
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_DEL_FUND_OK' THEN
       G_Check_Del_Fund_Ok    := p_function_allowed ;
       RETURN;
  END IF;

   IF p_function_name = 'PA_AF_UPD_FUND_OK' THEN
       G_Check_Upd_Fund_Ok    := p_function_allowed ;
       RETURN;
  END IF;

  /* Start of code for bug #4317792 */

  IF p_function_name = 'PA_FP_APP_BDGT_MNT_COST_PLAN' THEN
      G_FP_Maintain_AC_Plan    := p_function_allowed ;
      RETURN;
  END IF;

  IF p_function_name = 'PA_FP_BDGT_MNT_COST_PLAN' THEN
      G_FP_Maintain_C_Plan    := p_function_allowed ;
      RETURN;
  END IF;

  IF p_function_name = 'PA_FP_FCST_MNT_COST_PLAN' THEN
      G_FP_Maintain_FC_Plan    := p_function_allowed ;
      RETURN;
  END IF;

  IF p_function_name = 'PA_FP_APP_BDGT_MNT_REV_PLAN' THEN
      G_FP_Maintain_AR_Plan    := p_function_allowed ;
      RETURN;
  END IF;

  IF p_function_name = 'PA_FP_BDGT_MNT_REV_PLAN' THEN
      G_FP_Maintain_R_Plan    := p_function_allowed ;
      RETURN;
  END IF;

  IF p_function_name = 'PA_FP_FCST_MNT_REV_PLAN' THEN
      G_FP_Maintain_FR_Plan    := p_function_allowed ;
      RETURN;
  END IF;

  IF p_function_name = 'PA_FP_APP_BDGT_BSLN_COST_PLAN' THEN
      G_FP_Baseline_AC_Plan    := p_function_allowed ;
      RETURN;
  END IF;

  IF p_function_name = 'PA_FP_BDGT_BSLN_COST_PLAN' THEN
      G_FP_Baseline_C_Plan    := p_function_allowed ;
      RETURN;
  END IF;

  IF p_function_name = 'PA_FP_FCST_BSLN_COST_PLAN' THEN
      G_FP_Baseline_FC_Plan    := p_function_allowed ;
      RETURN;
  END IF;

  IF p_function_name = 'PA_FP_APP_BDGT_BSLN_REV_PLAN' THEN
      G_FP_Baseline_AR_Plan    := p_function_allowed ;
      RETURN;
  END IF;

  IF p_function_name = 'PA_FP_BDGT_BSLN_REV_PLAN' THEN
      G_FP_Baseline_R_Plan    := p_function_allowed ;
      RETURN;
  END IF;

  IF p_function_name = 'PA_FP_FCST_BSLN_REV_PLAN' THEN
      G_FP_Baseline_FR_Plan    := p_function_allowed ;
      RETURN;
  END IF;

  IF p_function_name = 'PA_FP_APP_BDGT_MNT_PLAN_LINES' THEN
      G_FP_Maintain_AC_AR_Plan_Lines    := p_function_allowed ;
      RETURN;
  END IF;

  IF p_function_name = 'PA_FP_BDGT_MNT_PLAN_LINES' THEN
      G_FP_Maintain_Plan_Lines    := p_function_allowed ;
      RETURN;
  END IF;

  IF p_function_name = 'PA_FP_FCST_MNT_PLAN_LINES' THEN
      G_FP_Maintain_FC_FR_Plan_Lines    := p_function_allowed ;
      RETURN;
  END IF;

  /* End of code for bug #4317792 */

END Set_Global_Vars;


/*
This procedure is a wrapper for all the project and function security related
actions. This procedure does the following :
1. Initializes the security variables
2. Checks if the user has QUERY and UPDATE permissions on the given project
3. For the given function name whether function security exists or not.
If any of the checks fail, 'F' is returned and if the user has all the required
permissions / function security, 'T' is returned.
This API is called from all BUDGETS AMG APIs.

This procedure internally calls:
1. pa_security.initialize
2. pa_security.allow_query
3. check_function_security

Created : 25-Dec-2002    bvarnasi
15-Sep-03 vejayara As part of PCS changes, the function security check is done based
                   on the plan type. Refer bug for more details
*/

PROCEDURE CHECK_BUDGET_SECURITY (
                        p_api_version_number IN  NUMBER,
                        p_project_id         IN  PA_PROJECTS_ALL.PROJECT_ID%TYPE,
                        p_fin_plan_type_id   IN  PA_FIN_PLAN_TYPES_B.FIN_PLAN_TYPE_ID%TYPE,
                        p_calling_context    IN  VARCHAR2,
                        p_function_name      IN  VARCHAR2,
                        p_version_type       IN  VARCHAR2,
                        x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_ret_code           OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

l_api_version_number   CONSTANT   NUMBER      :=  1.0;
l_api_name             CONSTANT   VARCHAR2(30):= 'CHECK_BUDGET_SECURITY';

l_module_name                     VARCHAR2(100);
p_pa_debug_mode                   VARCHAR2(1);

l_resp_id                         NUMBER;
l_user_id                         NUMBER;

l_cost_ret_status                 VARCHAR2(1);
l_rev_ret_status                  VARCHAR2(1);

l_ret_code                        VARCHAR2(1);
l_msg_count                       NUMBER := 0;
l_msg_data                        VARCHAR2(2000);
l_debug_mode                      VARCHAR2(1);
l_function_is_allowed  CONSTANT   VARCHAR2(1):='Y';
l_function_not_allowed CONSTANT   VARCHAR2(1):='N';
l_plan_class                      VARCHAR2(2000); /* Return value of a function */
l_function_name                   VARCHAR2(2000);

BEGIN
      /* Set module name and other standard things like setting error stack etc. */
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_module_name    := g_module_name;
      p_pa_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');


      IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function   => 'CHECK_BUDGET_SECURITY',
                                    p_debug_mode => l_debug_mode );
      END IF;

      IF p_pa_debug_mode = 'Y' THEN
          pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
          pa_debug.g_err_stage := 'Validating input parameters ';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      -- Validate input parameters
      IF p_project_id IS NULL THEN
            IF p_pa_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Project Id can not be null';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
            PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                 p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
      END IF;

      IF p_calling_context IS NULL THEN
            IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage := 'Calling Context can not be null';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
            PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                               p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
      END IF;

      IF p_function_name IS NULL THEN
            IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage := 'Function Name can not be null';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;
            PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                               p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
      END IF;

       -- dbms_output.put_line('validateing ver type');
      IF  p_calling_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN THEN

            IF p_fin_plan_type_id IS NULL THEN /* Bug 3139924 */
                  IF p_pa_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Plan Type Id can not be null';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;
                  PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                     p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
            END IF;

            IF p_version_type IS NULL THEN
                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Version Type can not be null for calling context : '||
                                                 p_calling_context;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;
                  PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                       p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
            ELSIF p_version_type NOT IN (PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST,
                                       PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_REVENUE,
                                       PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL) THEN
                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Version Type '|| p_version_type ||' is invalid. ';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;
                  PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                     p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
            END IF;
      END IF;
             -- dbms_output.put_line('after validateing ver type');
      /* Validations of input parameters are over */
      /* Get the responsibility and user id  and initialize security variables */

      l_resp_id := FND_GLOBAL.Resp_id;
      l_user_id := FND_GLOBAL.User_id;

      IF p_pa_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Responsibility Id: '|| l_resp_id ||' User Id: '||l_user_id||
                                ' Project Id: '||p_project_id;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      -- Set the project Id into the global variable, this is reference by the
      -- API CHECK_FUNCTION_SECURITY
      PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := p_project_id;

      pa_security.initialize (X_user_id        => l_user_id,
                              X_calling_module => p_function_name);
      -- Check if the user has QUERY and UPDATE permissions on the project

      IF pa_security.allow_query (x_project_id => p_project_id ) = 'N' THEN
            IF p_pa_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Query Permission does not exist for project id '||p_project_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            pa_utils.add_message(
                  p_app_short_name  => 'PA',
                  p_msg_name        => 'PA_PR_SECURITY_ENFORCED_AMG');

            RAISE FND_API.G_EXC_ERROR;
      ELSIF pa_security.allow_update (x_project_id => p_project_id ) = 'N' THEN
            IF p_pa_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Update Permission does not exist for project id '||p_project_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            pa_utils.add_message(
                  p_app_short_name  => 'PA',
                  p_msg_name        => 'PA_PR_SECURITY_ENFORCED_AMG');

            RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF p_pa_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'Checking Function Securrity for '||p_function_name||
                                ' in '||p_calling_context||' module.';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;
       -- dbms_output.put_line('validateing ver type 2');

      -- Now check if the user has FUNCTION SECURITY on the function passed
      -- for BUDGETs Model

      IF p_calling_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET THEN

            IF p_function_name = 'PA_PM_CREATE_DRAFT_BUDGET' THEN
                   -- dbms_output.put_line('before  checking for PA_PM_CREATE_DRAFT_BUDGET x_return_status'
                   --||x_return_status);
                  PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                          p_api_version_number => p_api_version_number,
                          p_responsibility_id  => l_resp_id,
                          p_function_name      => 'PA_PM_CREATE_DRAFT_BUDGET',
                          p_msg_count          => l_msg_count,
                          p_msg_data           => l_msg_data,
                          p_return_status      => x_return_status,
                          p_function_allowed   => l_ret_code);

                   -- dbms_output.put_line('after checking for PA_PM_CREATE_DRAFT_BUDGET');
                   -- dbms_output.put_line('x_return_status is '||x_return_status);
                   -- dbms_output.put_line('l_ret_code is '||l_ret_code);

                  IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                     l_ret_code = l_function_is_allowed THEN
                        x_ret_code := l_function_is_allowed;
                  ELSE
                        x_ret_code := l_function_not_allowed;
                        pa_utils.add_message(
                        p_app_short_name  => 'PA',
                        p_msg_name        => 'PA_FUNCTION_SECURITY_ENFORCED');
                  /* 3377434  Modified message name PA_PR_SECURITY_ENFORCED_AMG to
                  PA_FUNCTION_SECURITY_ENFORCED above*/
                  END IF;

                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'PA_PM_CREATE_DRAFT_BUDGET : '||x_ret_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  --Changes for bug 3182963
                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.reset_curr_function;
                  END IF;

                  RETURN;

            ELSIF p_function_name = 'PA_PM_DELETE_DRAFT_BUDGET' THEN
                  PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                        p_api_version_number => p_api_version_number,
                        p_responsibility_id  => l_resp_id,
                        p_function_name      => 'PA_PM_DELETE_DRAFT_BUDGET',
                        p_msg_count          => l_msg_count,
                        p_msg_data           => l_msg_data,
                        p_return_status      => x_return_status,
                        p_function_allowed   => l_ret_code);

                  IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                     l_ret_code = l_function_is_allowed THEN

                        x_ret_code := l_function_is_allowed;

                  ELSE
                        x_ret_code := l_function_not_allowed;
                        pa_utils.add_message(
                        p_app_short_name  => 'PA',
                        p_msg_name        => 'PA_FUNCTION_SECURITY_ENFORCED');
                  /* 3377434  Modified message name PA_PR_SECURITY_ENFORCED_AMG to
                  PA_FUNCTION_SECURITY_ENFORCED above*/
                  END IF;

                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'PA_PM_DELETE_DRAFT_BUDGET : '||x_ret_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  --Changes for bug 3182963
                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.reset_curr_function;
                  END IF;

                  RETURN;

            ELSIF p_function_name = 'PA_PM_UPDATE_BUDGET' THEN

                  PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                          p_api_version_number => p_api_version_number,
                          p_responsibility_id  => l_resp_id,
                          p_function_name      => 'PA_PM_UPDATE_BUDGET',
                          p_msg_count          => l_msg_count,
                          p_msg_data           => l_msg_data,
                          p_return_status      => x_return_status,
                          p_function_allowed   => l_ret_code);

                  IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                     l_ret_code = l_function_is_allowed THEN

                        x_ret_code := l_function_is_allowed;
                  ELSE
                        x_ret_code := l_function_not_allowed;
                        pa_utils.add_message(
                        p_app_short_name  => 'PA',
                        p_msg_name        => 'PA_FUNCTION_SECURITY_ENFORCED');
                  /* 3377434  Modified message name PA_PR_SECURITY_ENFORCED_AMG to
                  PA_FUNCTION_SECURITY_ENFORCED above*/
                  END IF;

                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'PA_PM_UPDATE_BUDGET : '||x_ret_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  --Changes for bug 3182963
                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.reset_curr_function;
                  END IF;

                  RETURN;

            ELSIF p_function_name = 'PA_PM_ADD_BUDGET_LINE' THEN
                  PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                          p_api_version_number => p_api_version_number,
                          p_responsibility_id  => l_resp_id,
                          p_function_name      => 'PA_PM_ADD_BUDGET_LINE',
                          p_msg_count          => l_msg_count,
                          p_msg_data           => l_msg_data,
                          p_return_status      => x_return_status,
                          p_function_allowed   => l_ret_code);

                  IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                     l_ret_code = l_function_is_allowed THEN
                        x_ret_code := l_function_is_allowed;
                  ELSE
                        x_ret_code := l_function_not_allowed;
                        pa_utils.add_message(
                        p_app_short_name  => 'PA',
                        p_msg_name        => 'PA_FUNCTION_SECURITY_ENFORCED');
                  /* 3377434  Modified message name PA_PR_SECURITY_ENFORCED_AMG to
                  PA_FUNCTION_SECURITY_ENFORCED above*/
                  END IF;

                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'PA_PM_ADD_BUDGET_LINE : '||x_ret_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  --Changes for bug 3182963
                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.reset_curr_function;
                  END IF;

                  RETURN;

            ELSIF p_function_name = 'PA_PM_DELETE_BUDGET_LINE' THEN

                  PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                          p_api_version_number => p_api_version_number,
                          p_responsibility_id  => l_resp_id,
                          p_function_name      => 'PA_PM_DELETE_BUDGET_LINE',
                          p_msg_count          => l_msg_count,
                          p_msg_data           => l_msg_data,
                          p_return_status      => x_return_status,
                          p_function_allowed   => l_ret_code);

                  IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                     l_ret_code = l_function_is_allowed THEN

                        x_ret_code := l_function_is_allowed;
                  ELSE
                        x_ret_code := l_function_not_allowed;
                        pa_utils.add_message(
                        p_app_short_name  => 'PA',
                        p_msg_name        => 'PA_FUNCTION_SECURITY_ENFORCED');
                  /* 3377434  Modified message name PA_PR_SECURITY_ENFORCED_AMG to
                  PA_FUNCTION_SECURITY_ENFORCED above*/
                  END IF;

                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'PA_PM_DELETE_BUDGET_LINE : '||x_ret_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

              --Changes for bug 3182963
                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.reset_curr_function;
                  END IF;

                  RETURN;

            ELSIF p_function_name = 'PA_PM_UPDATE_BUDGET_LINE' THEN
                  PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                          p_api_version_number => p_api_version_number,
                          p_responsibility_id  => l_resp_id,
                          p_function_name      => 'PA_PM_UPDATE_BUDGET_LINE',
                          p_msg_count          => l_msg_count,
                          p_msg_data           => l_msg_data,
                          p_return_status      => x_return_status,
                          p_function_allowed   => l_ret_code);

                  IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                     l_ret_code = l_function_is_allowed THEN
                        x_ret_code := l_function_is_allowed;
                  ELSE
                        x_ret_code := l_function_not_allowed;
                        pa_utils.add_message(
                        p_app_short_name  => 'PA',
                        p_msg_name        => 'PA_FUNCTION_SECURITY_ENFORCED');
                  /* 3377434  Modified message name PA_PR_SECURITY_ENFORCED_AMG to
                  PA_FUNCTION_SECURITY_ENFORCED above*/
              END IF;

                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'PA_PM_UPDATE_BUDGET_LINE : '||x_ret_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  --Changes for bug 3182963
                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.reset_curr_function;
                  END IF;

                  RETURN;

            ELSIF p_function_name = 'PA_PM_BASELINE_BUDGET' THEN
                  PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                          p_api_version_number => p_api_version_number,
                          p_responsibility_id  => l_resp_id,
                          p_function_name      => 'PA_PM_BASELINE_BUDGET',
                          p_msg_count          => l_msg_count,
                          p_msg_data           => l_msg_data,
                          p_return_status      => x_return_status,
                          p_function_allowed   => l_ret_code);

                  IF x_return_status = FND_API.G_RET_STS_SUCCESS AND l_ret_code = l_function_is_allowed
                  THEN
                        x_ret_code := l_function_is_allowed;
                  ELSE
                        x_ret_code := l_function_not_allowed;
                        pa_utils.add_message(
                        p_app_short_name  => 'PA',
                        p_msg_name        => 'PA_FUNCTION_SECURITY_ENFORCED');
                  /* 3377434  Modified message name PA_PR_SECURITY_ENFORCED_AMG to
                  PA_FUNCTION_SECURITY_ENFORCED above*/
                  END IF;

                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'PA_PM_BASELINE_BUDGET : '||x_ret_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  --Changes for bug 3182963
                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.reset_curr_function;
                  END IF;

                  RETURN;

            ELSIF p_function_name = 'CALCULATE_AMOUNTS' THEN
                  PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                          p_api_version_number => p_api_version_number,
                          p_responsibility_id  => l_resp_id,
                          p_function_name      => 'CALCULATE_AMOUNTS',
                          p_msg_count          => l_msg_count,
                          p_msg_data           => l_msg_data,
                          p_return_status      => x_return_status,
                          p_function_allowed   => l_ret_code);

                  IF x_return_status = FND_API.G_RET_STS_SUCCESS AND l_ret_code = l_function_is_allowed
                  THEN
                        x_ret_code := l_function_is_allowed;
                  ELSE
                        x_ret_code := l_function_not_allowed;
                        pa_utils.add_message(
                        p_app_short_name  => 'PA',
                        p_msg_name        => 'PA_FUNCTION_SECURITY_ENFORCED');
                  /* 3377434  Modified message name PA_PR_SECURITY_ENFORCED_AMG to
                  PA_FUNCTION_SECURITY_ENFORCED above*/
                  END IF;

                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'CALCULATE_AMOUNTS : '||x_ret_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

              --Changes for bug 3182963
                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.reset_curr_function;
                  END IF;

                  RETURN;

            --Bug 4224464: Added the following elsif blocks to check function security
            --for PA_BUDGET_PUB.delete_baseline_budget AMG api.
            --Secuity check for deleting Approved Baseline Budget (Cost or Revenue)
            ELSIF p_function_name = 'PA_FP_DEL_BSLN_APPRVD_BDGT' THEN
                  PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                          p_api_version_number => p_api_version_number,
                          p_responsibility_id  => l_resp_id,
                          p_function_name      => 'PA_FP_DEL_BSLN_APPRVD_BDGT',
                          p_msg_count          => l_msg_count,
                          p_msg_data           => l_msg_data,
                          p_return_status      => x_return_status,
                          p_function_allowed   => l_ret_code);

                  IF x_return_status = FND_API.G_RET_STS_SUCCESS AND l_ret_code = l_function_is_allowed
                  THEN
                        x_ret_code := l_function_is_allowed;
                  ELSE
                        x_ret_code := l_function_not_allowed;
                        pa_utils.add_message(
                        p_app_short_name  => 'PA',
                        p_msg_name        => 'PA_FUNCTION_SECURITY_ENFORCED');
                  END IF;

                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'PA_FP_DEL_BSLN_APPRVD_BDGT : '||x_ret_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.reset_curr_function;
                  END IF;

                  RETURN;

            --Secuity check for deleting Baseline Budget (not approved Cost or Revenue)
            ELSIF p_function_name = 'PA_FP_DEL_BSLN_BDGT' THEN
                  PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                          p_api_version_number => p_api_version_number,
                          p_responsibility_id  => l_resp_id,
                          p_function_name      => 'PA_FP_DEL_BSLN_BDGT',
                          p_msg_count          => l_msg_count,
                          p_msg_data           => l_msg_data,
                          p_return_status      => x_return_status,
                          p_function_allowed   => l_ret_code);

                  IF x_return_status = FND_API.G_RET_STS_SUCCESS AND l_ret_code = l_function_is_allowed
                  THEN
                        x_ret_code := l_function_is_allowed;
                  ELSE
                        x_ret_code := l_function_not_allowed;
                        pa_utils.add_message(
                        p_app_short_name  => 'PA',
                        p_msg_name        => 'PA_FUNCTION_SECURITY_ENFORCED');
                  END IF;

                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'PA_FP_DEL_BSLN_BDGT : '||x_ret_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.reset_curr_function;
                  END IF;

                  RETURN;
            --Bug 4224464: End of changes

            ELSE -- Unhandled functions security - Hence throw invalid arg exception
                  RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
            END IF;-- End of function security checks for BUDGETs model

      ELSIF p_calling_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN THEN

            /* Derive the plan class of the plan type */

            l_plan_class := pa_fin_plan_type_global.plantype_to_planclass(
                                     p_project_id => p_project_id,
                                     p_fin_plan_type_id => p_fin_plan_type_id);

            IF l_plan_class =  'INVALID_PLAN_TYPE' THEN

                  IF p_pa_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Error while retrieving the plan class. Invalid plan type ..';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;
                  PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                     p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;

            END IF;

            IF p_pa_debug_mode = 'Y' THEN

                  pa_debug.g_err_stage := 'Checking function security for FinPlan module. ' ||
                  'Plan Class:' || l_plan_class || ' : ' ||
                  'Version Type: ' || p_version_type || ' : ' ||
                  'Function Name: ' || p_function_name;

                  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

            END IF;

                   -- dbms_output.put_line('validateing ver type 6');

            IF p_function_name = 'PA_PM_CREATE_DRAFT_BUDGET' OR
               p_function_name = 'PA_PM_DELETE_DRAFT_BUDGET' OR
               p_function_name = 'PA_PM_UPDATE_BUDGET'       OR
               p_function_name = 'PA_PM_ADD_BUDGET_LINE'     OR
               p_function_name = 'PA_PM_DELETE_BUDGET_LINE'  OR
               p_function_name = 'PA_PM_UPDATE_BUDGET_LINE'  THEN

                  -- In case of FINPLAN, check fn security for COST or ALL version

                  IF p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST OR
                     p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL  THEN

                        IF l_plan_class =  'APPROVED_BUDGET' THEN

                            l_function_name      := 'PA_FP_APP_BDGT_MNT_COST_PLAN';

                        ELSIF l_plan_class =  'NON_APPROVED_BUDGET' THEN

                            l_function_name      := 'PA_FP_BDGT_MNT_COST_PLAN';

                        ELSIF l_plan_class =  'FORECAST' THEN

                             l_function_name     := 'PA_FP_FCST_MNT_COST_PLAN';

                        ELSE

                             IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage := 'Error while retrieving the plan class. ' ||
                                                       'Invalid plan type ..';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                             END IF;
                             PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                                p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
                             RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;

                        END IF;

                        PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                                    p_api_version_number => p_api_version_number,
                                    p_responsibility_id  => l_resp_id,
                                    p_function_name      => l_function_name,
                                    p_msg_count          => l_msg_count,
                                    p_msg_data           => l_msg_data,
                                    p_return_status      => x_return_status,
                                    p_function_allowed   => l_ret_code);

                        IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                           l_ret_code = l_function_is_allowed THEN
                              l_cost_ret_status := l_function_is_allowed;
                              x_ret_code := l_function_is_allowed;
                        ELSE
                              l_cost_ret_status := l_function_not_allowed;
                              x_ret_code := l_function_not_allowed;
                        END IF;

                        IF p_pa_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'status : '||l_ret_code;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                  END IF;

                  -- In case of FINPLAN, check fn security for REVENUE or ALL version

                  --We should NOT use ELSIF here as we want this block also to be executed
                  --when p_version_type is ALL.

                  IF p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_REVENUE OR
                     p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL  THEN

                        IF l_plan_class =  'APPROVED_BUDGET' THEN

                             l_function_name      := 'PA_FP_APP_BDGT_MNT_REV_PLAN';

                        ELSIF l_plan_class =  'NON_APPROVED_BUDGET' THEN

                              l_function_name     := 'PA_FP_BDGT_MNT_REV_PLAN';

                        ELSIF l_plan_class =  'FORECAST' THEN

                              l_function_name     := 'PA_FP_FCST_MNT_REV_PLAN';

                        ELSE

                             IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage := 'Error while retrieving the plan class. ' ||
                                                       'Invalid plan type ..';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                             END IF;
                             PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                                p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
                             RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;

                        END IF;

                        PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                                    p_api_version_number => p_api_version_number,
                                    p_responsibility_id  => l_resp_id,
                                    p_function_name      => l_function_name,
                                    p_msg_count          => l_msg_count,
                                    p_msg_data           => l_msg_data,
                                    p_return_status      => x_return_status,
                                    p_function_allowed   => l_ret_code);

                        IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                           l_ret_code = l_function_is_allowed THEN
                              l_rev_ret_status := l_function_is_allowed;
                              x_ret_code := l_function_is_allowed;
                        ELSE
                              l_rev_ret_status := l_function_not_allowed;
                              x_ret_code := l_function_not_allowed;
                        END IF;

                        IF p_pa_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'status : '||l_ret_code;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                  END IF;

                  -- In case of FINPLAN, check fn security for ALL version
                  IF p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL  THEN

                        IF l_cost_ret_status = l_function_is_allowed OR
                           l_rev_ret_status = l_function_is_allowed THEN
                           l_ret_code := l_function_is_allowed;
                           x_ret_code := l_function_is_allowed;
                        ELSE
                           l_ret_code := l_function_not_allowed;
                           x_ret_code := l_function_not_allowed;
                        END IF;

                        IF p_pa_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'status : '||l_ret_code;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                  END IF; -- Comparision for ALL version_type ends

            ELSIF p_function_name = 'PA_PM_BASELINE_BUDGET'  THEN

              -- In case of FINPLAN, check fn security for COST or ALL version

                  IF p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST OR
                     p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL  THEN

                        IF l_plan_class =  'APPROVED_BUDGET' THEN

                              l_function_name      := 'PA_FP_APP_BDGT_BSLN_COST_PLAN';

                        ELSIF l_plan_class =  'NON_APPROVED_BUDGET' THEN

                              l_function_name      := 'PA_FP_BDGT_BSLN_COST_PLAN';

                        ELSIF l_plan_class =  'FORECAST' THEN

                              l_function_name      := 'PA_FP_FCST_BSLN_COST_PLAN';

                        ELSE

                             IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage := 'Error while retrieving the plan class.' ||
                                                       'Invalid plan type ..';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                             END IF;
                             PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                                p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
                             RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;

                        END IF;

                        PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                                    p_api_version_number => p_api_version_number,
                                    p_responsibility_id  => l_resp_id,
                                    p_function_name      => l_function_name,
                                    p_msg_count          => l_msg_count,
                                    p_msg_data           => l_msg_data,
                                    p_return_status      => x_return_status,
                                    p_function_allowed   => l_ret_code);

                        IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                           l_ret_code = l_function_is_allowed THEN
                              l_cost_ret_status := l_function_is_allowed;
                              x_ret_code := l_function_is_allowed;
                        ELSE
                              l_cost_ret_status := l_function_not_allowed;
                              x_ret_code := l_function_not_allowed;
                        END IF;

                        IF p_pa_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'status : '||l_ret_code;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                  END IF;

                  --In case of FINPLAN, check fn security for REVENUE or ALL version
                  IF p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_REVENUE OR
                    p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL  THEN

                        IF l_plan_class =  'APPROVED_BUDGET' THEN

                              l_function_name      := 'PA_FP_APP_BDGT_BSLN_REV_PLAN';

                        ELSIF l_plan_class =  'NON_APPROVED_BUDGET' THEN

                              l_function_name      := 'PA_FP_BDGT_BSLN_REV_PLAN';

                        ELSIF l_plan_class =  'FORECAST' THEN

                              l_function_name      := 'PA_FP_FCST_BSLN_REV_PLAN';

                        ELSE

                             IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage := 'Error while retrieving the plan class. ' ||
                                                       'Invalid plan type ..';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                             END IF;

                             PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                                p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
                             RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;

                        END IF;

                        PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                                    p_api_version_number => p_api_version_number,
                                    p_responsibility_id  => l_resp_id,
                                    p_function_name      => l_function_name,
                                    p_msg_count          => l_msg_count,
                                    p_msg_data           => l_msg_data,
                                    p_return_status      => x_return_status,
                                    p_function_allowed   => l_ret_code);

                        IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                           l_ret_code = l_function_is_allowed THEN
                              l_rev_ret_status := l_function_is_allowed;
                              x_ret_code := l_function_is_allowed;
                        ELSE
                              l_rev_ret_status := l_function_not_allowed;
                              x_ret_code := l_function_not_allowed;
                        END IF;

                        IF p_pa_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'status : '||l_ret_code;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                  END IF;

                  --In case of FINPLAN, check fn security for ALL version
                  IF p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL  THEN

                        IF l_cost_ret_status = l_function_is_allowed OR
                           l_rev_ret_status = l_function_is_allowed THEN
                              l_ret_code := l_function_is_allowed;
                              x_ret_code := l_function_is_allowed;
                        ELSE
                              l_ret_code := l_function_not_allowed;
                              x_ret_code := l_function_not_allowed;
                        END IF;

                        IF p_pa_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'status : '||l_ret_code;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                  END IF; -- Comparision for ALL version_type ends

            ELSIF p_function_name = 'CALCULATE_AMOUNTS'  THEN

                   IF l_plan_class =  'APPROVED_BUDGET' THEN

                        l_function_name      := 'PA_FP_APP_BDGT_MNT_PLAN_LINES';

                   ELSIF l_plan_class =  'NON_APPROVED_BUDGET' THEN

                        l_function_name      := 'PA_FP_BDGT_MNT_PLAN_LINES';

                   ELSIF l_plan_class =  'FORECAST' THEN

                         l_function_name      := 'PA_FP_FCST_MNT_PLAN_LINES';

                   ELSE

                        IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage := 'Error while retrieving the plan class.' ||
                                                       'Invalid plan type ..';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END IF;
                        PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                             p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
                        RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;

                   END IF;

                   PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                              p_api_version_number => p_api_version_number,
                              p_responsibility_id  => l_resp_id,
                              p_function_name      => l_function_name,
                              p_msg_count          => l_msg_count,
                              p_msg_data           => l_msg_data,
                              p_return_status      => x_return_status,
                              p_function_allowed   => l_ret_code);

                   IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                      l_ret_code = l_function_is_allowed THEN
                          l_ret_code := l_function_is_allowed;
                          x_ret_code := l_function_is_allowed;
                   ELSE
                         l_ret_code := l_function_not_allowed;
                         x_ret_code := l_function_not_allowed;
                   END IF;

                   IF p_pa_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'status : '||l_ret_code;
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                   END IF;

            --Bug 4224464: Added the following elsif block to check function security
            --for PA_BUDGET_PUB.delete_baseline_budget AMG api.
            ELSIF p_function_name = 'PA_PM_DELETE_BASELINE_BUDGET'  THEN

                   IF l_plan_class =  'APPROVED_BUDGET' THEN

                        l_function_name      := 'PA_FP_DEL_BSLN_APPRVD_BDGT';

                   ELSIF l_plan_class =  'NON_APPROVED_BUDGET' THEN

                        l_function_name      := 'PA_FP_DEL_BSLN_BDGT';

                   ELSIF l_plan_class =  'FORECAST' THEN

                         l_function_name      := 'PA_FP_DEL_APPRVD_FCST';

                   ELSE

                        IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage := 'Error while retrieving the plan class.' ||
                                                       'Invalid plan type ..';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END IF;
                        PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                             p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
                        RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;

                   END IF;

                   PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                              p_api_version_number => p_api_version_number,
                              p_responsibility_id  => l_resp_id,
                              p_function_name      => l_function_name,
                              p_msg_count          => l_msg_count,
                              p_msg_data           => l_msg_data,
                              p_return_status      => x_return_status,
                              p_function_allowed   => l_ret_code);

                   IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                      l_ret_code = l_function_is_allowed THEN
                          l_ret_code := l_function_is_allowed;
                          x_ret_code := l_function_is_allowed;
                   ELSE
                         l_ret_code := l_function_not_allowed;
                         x_ret_code := l_function_not_allowed;
                   END IF;

                   IF p_pa_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'status : '||l_ret_code;
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                   END IF;
            --Bug 4224464: End of changes

            -- Bug 3986129: FP.M Web ADI Dev. Inculded the following checks
            -- for editing of change order versions and forecasr versions
            ELSIF p_function_name = 'PA_PM_UPDATE_CHG_DOC'  THEN -- for maintaing CI versions

              -- check fn security for COST or ALL version

                  IF p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST OR
                     p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL  THEN

                        l_function_name := 'PA_FP_MNT_CHG_DOC_COST_FIN_IMP';

                        PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                                    p_api_version_number => p_api_version_number,
                                    p_responsibility_id  => l_resp_id,
                                    p_function_name      => l_function_name,
                                    p_msg_count          => l_msg_count,
                                    p_msg_data           => l_msg_data,
                                    p_return_status      => x_return_status,
                                    p_function_allowed   => l_ret_code);

                        IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                           l_ret_code = l_function_is_allowed THEN
                              l_cost_ret_status := l_function_is_allowed;
                              x_ret_code := l_function_is_allowed;
                        ELSE
                              l_cost_ret_status := l_function_not_allowed;
                              x_ret_code := l_function_not_allowed;
                        END IF;

                        IF p_pa_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'status : '||l_ret_code;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                  END IF;

                  --In case of FINPLAN, check fn security for REVENUE or ALL version
                  IF p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_REVENUE OR
                    p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL  THEN
                              l_function_name      := 'PA_FP_MNT_CHG_DOC_REV_FIN_IMP';

                        PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                                    p_api_version_number => p_api_version_number,
                                    p_responsibility_id  => l_resp_id,
                                    p_function_name      => l_function_name,
                                    p_msg_count          => l_msg_count,
                                    p_msg_data           => l_msg_data,
                                    p_return_status      => x_return_status,
                                    p_function_allowed   => l_ret_code);

                        IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                           l_ret_code = l_function_is_allowed THEN
                              l_rev_ret_status := l_function_is_allowed;
                              x_ret_code := l_function_is_allowed;
                        ELSE
                              l_rev_ret_status := l_function_not_allowed;
                              x_ret_code := l_function_not_allowed;
                        END IF;

                        IF p_pa_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'status : '||l_ret_code;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                  END IF;

                  IF p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL  THEN

                        IF l_cost_ret_status = l_function_is_allowed OR
                           l_rev_ret_status = l_function_is_allowed THEN
                              l_ret_code := l_function_is_allowed;
                              x_ret_code := l_function_is_allowed;
                        ELSE
                              l_ret_code := l_function_not_allowed;
                              x_ret_code := l_function_not_allowed;
                        END IF;

                        IF p_pa_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'status : '||l_ret_code;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                  END IF; -- Comparision for ALL version_type ends

            ELSIF p_function_name = 'PA_PM_SUBMIT_BUDGET'  THEN -- submit privilege for budget/forecasts

                  IF p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST OR
                     p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL  THEN

                        IF l_plan_class =  'APPROVED_BUDGET' THEN

                              l_function_name      := 'PA_FP_APP_BDGT_SUB_COST_PLAN';

                        ELSIF l_plan_class =  'NON_APPROVED_BUDGET' THEN

                              l_function_name      := 'PA_FP_BDGT_SUB_COST_PLAN';

                        ELSIF l_plan_class =  'FORECAST' THEN

                              l_function_name      := 'PA_FP_FCST_SUB_COST_PLAN';

                        ELSE

                             IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage := 'Error while retrieving the plan class.' ||
                                                       'Invalid plan type ..';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                             END IF;
                             PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                                p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
                             RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;

                        END IF;

                        PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                                    p_api_version_number => p_api_version_number,
                                    p_responsibility_id  => l_resp_id,
                                    p_function_name      => l_function_name,
                                    p_msg_count          => l_msg_count,
                                    p_msg_data           => l_msg_data,
                                    p_return_status      => x_return_status,
                                    p_function_allowed   => l_ret_code);

                        IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                           l_ret_code = l_function_is_allowed THEN
                              l_cost_ret_status := l_function_is_allowed;
                              x_ret_code := l_function_is_allowed;
                        ELSE
                              l_cost_ret_status := l_function_not_allowed;
                              x_ret_code := l_function_not_allowed;
                        END IF;

                        IF p_pa_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'status : '||l_ret_code;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                  END IF;

                  --In case of FINPLAN, check fn security for REVENUE or ALL version
                  IF p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_REVENUE OR
                    p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL  THEN

                        IF l_plan_class =  'APPROVED_BUDGET' THEN

                              l_function_name      := 'PA_FP_APP_BDGT_SUB_REV_PLAN';

                        ELSIF l_plan_class =  'NON_APPROVED_BUDGET' THEN

                              l_function_name      := 'PA_FP_BDGT_SUB_REV_PLAN';

                        ELSIF l_plan_class =  'FORECAST' THEN

                              l_function_name      := 'PA_FP_FCST_SUB_REV_PLAN';

                        ELSE

                             IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage := 'Error while retrieving the plan class. ' ||
                                                       'Invalid plan type ..';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                             END IF;

                             PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                                p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
                             RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;

                        END IF;

                        PA_PM_FUNCTION_SECURITY_PUB.check_function_security(
                                    p_api_version_number => p_api_version_number,
                                    p_responsibility_id  => l_resp_id,
                                    p_function_name      => l_function_name,
                                    p_msg_count          => l_msg_count,
                                    p_msg_data           => l_msg_data,
                                    p_return_status      => x_return_status,
                                    p_function_allowed   => l_ret_code);

                        IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
                           l_ret_code = l_function_is_allowed THEN
                              l_rev_ret_status := l_function_is_allowed;
                              x_ret_code := l_function_is_allowed;
                        ELSE
                              l_rev_ret_status := l_function_not_allowed;
                              x_ret_code := l_function_not_allowed;
                        END IF;

                        IF p_pa_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'status : '||l_ret_code;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                  END IF;

                  --In case of FINPLAN, check fn security for ALL version
                  IF p_version_type = PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL  THEN

                        IF l_cost_ret_status = l_function_is_allowed OR
                           l_rev_ret_status = l_function_is_allowed THEN
                              l_ret_code := l_function_is_allowed;
                              x_ret_code := l_function_is_allowed;
                        ELSE
                              l_ret_code := l_function_not_allowed;
                              x_ret_code := l_function_not_allowed;
                        END IF;

                        IF p_pa_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'status : '||l_ret_code;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                        END IF;

                  END IF; -- Comparision for ALL version_type ends

            ELSE  -- if the function passed doesnot match any value compared
                  IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Invalid function name passed';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                  END IF;
                  pa_utils.add_message
                         (p_app_short_name  => 'PA',
                          p_msg_name        => 'PA_FP_INV_PARAM_PASSED');
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF; -- end of processing for various function calls
            -- Bug 3986129: FP.M Web ADI changes ends

            IF x_ret_code = l_function_not_allowed THEN
                  pa_utils.add_message(
                              p_app_short_name  => 'PA',
                              p_msg_name        => 'PA_FUNCTION_SECURITY_ENFORCED');
                  /* 3377434  Modified message name PA_PR_SECURITY_ENFORCED_AMG to
                  PA_FUNCTION_SECURITY_ENFORCED above*/
            END IF;

      ELSE -- End of ELSE block where p_calling_context = FINPLAN is checked.

            IF p_pa_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Unhandled case of p_calling_context '||p_calling_context;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            END IF;

            RAISE PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;

      END IF;

      --Changes for bug 3182963
      IF p_pa_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
      END IF;

-- Exception handling
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC THEN
          l_ret_code      :=l_function_not_allowed;
          x_ret_code      := l_function_not_allowed;
          x_return_status := FND_API.G_RET_STS_ERROR;

          --Changes for bug 3182963
          IF p_pa_debug_mode = 'Y' THEN
              pa_debug.reset_curr_function;
          END IF;

          RETURN;

    WHEN FND_API.G_EXC_ERROR THEN
          l_ret_code      :=l_function_not_allowed;
          x_ret_code      := l_function_not_allowed;
          x_return_status := FND_API.G_RET_STS_ERROR;

          --Changes for bug 3182963
          IF p_pa_debug_mode = 'Y' THEN
              pa_debug.reset_curr_function;
          END IF;

          RETURN;

    WHEN OTHERS THEN
          l_ret_code    :=l_function_not_allowed;
          x_ret_code      := l_function_not_allowed;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage := 'Unexpected Exception: '||sqlerrm;
              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
          END IF;

          --Changes for bug 3182963
          IF p_pa_debug_mode = 'Y' THEN
              pa_debug.reset_curr_function;
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CHECK_BUDGET_SECURITY;

END PA_PM_FUNCTION_SECURITY_PUB;

/
