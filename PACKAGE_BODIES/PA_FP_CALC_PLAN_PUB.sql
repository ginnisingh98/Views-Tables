--------------------------------------------------------
--  DDL for Package Body PA_FP_CALC_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_CALC_PLAN_PUB" AS
--/* $Header: PAFPCPUB.pls 120.1.12000000.2 2007/09/11 08:51:13 anuragar ship $ */

g_module_name   VARCHAR2(100) := 'PA_FP_CALC_PLAN_PUB';
Invalid_Arg_Exc_WP Exception;
G_PKG_NAME      VARCHAR2(100) := 'PA_FP_CALC_PLAN_PUB';

-- Procedure            : REFRESH_RATES
-- Type                 : Public Procedure
-- Purpose              : This is an AMG API to refresh cost/conversion rates in bulk.
-- Note                 : This public AMG API refreshes the cost rates or conversion rates (depending
--			: on the IN parameters) of either all the planning resources in the entire
--			: budget version or specific planning resources in the budget version.
--			: It supports both Workplan and Financial structures, and it performs all
--			: validation and security checks before refreshing rates.
-- Assumptions          :

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_project_id                 NUMBER   NO              Project Id
-- p_pm_project_reference       VARCHAR2 NO              Project Reference, either project_id or project reference
-- p_update_plan_type           VARCHAR2 Yes             Accepted values are 'WORKPLAN' or 'FINPLAN'.
-- p_structure_version_id       NUMBER   NO              Identifier of the workplan structure version. Required if
--                                                       update plan type = WORKPLAN.
-- p_budget_version_number      VARCHAR2 NO              Identifier of the budget version. Required if update plan type = FINPLAN.
-- p_version_type               VARCHAR2 NO              Identifier of the budget version. Required if update plan type = FINPLAN.
-- p_finplan_type_id            NUMBER   NO              Identifier of the budget version. Either p_finplan_type_id
--                                                       or p_finplan_type_name must be provided if update plan type = FINPLAN.
-- p_finplan_type_name          VARCHAR2 NO              Identifier of the budget version. Either p_finplan_type_id
--                                                       or p_finplan_type_name must be provided if update plan type = FINPLAN.
-- p_resource_class_code_tab    Table    NO              Optional parameter; if passed in, only the planning resource
--                                                       assignments in the specified resource classes will be refreshed.
-- p_resource_asgn_id_tab       Table    NO              Optional parameter; if passed in, only the specified planning
--                                                       resource assignments will be refreshed.
-- p_txn_curr_code_tab          Table    NO              Optional parameter.  If passed in with resource assignment ids,
--                                                       only the specified planning resource assignments and transaction currency
--                                                       combination will be refreshed.
-- p_refresh_cost_bill_rates_flag VARCHAR2 NO            Flag indicates whether Refresh Cost Rates action should be performed.
--                                                       Accepted values are 'Y' and 'N'.
-- p_refresh_conv_rates_flag    VARCHAR2 NO              Flag indicates whether Refresh Conversion Rates action should be performed.
--                                                       Accepted values are 'Y' and 'N'.

PROCEDURE REFRESH_RATES
    (
       p_api_version_number    IN   NUMBER   := 1.0
     , p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE
     , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
     , p_pm_product_code       IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     , p_project_id            IN   NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     , p_pm_project_reference  IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     , p_update_plan_type      IN   VARCHAR2
     , p_structure_version_id  IN   NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     , p_budget_version_number IN   PA_BUDGET_VERSIONS.version_number%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     , p_version_type          IN   PA_BUDGET_VERSIONS.version_type%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     , p_finplan_type_id       IN   PA_BUDGET_VERSIONS.fin_plan_type_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     , p_finplan_type_name     IN   PA_FIN_PLAN_TYPES_VL.name%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     , p_resource_class_code_tab IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     , p_resource_asgn_id_tab    IN SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE()
     , p_txn_curr_code_tab       IN SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
     , p_refresh_cost_bill_rates_flag IN VARCHAR2 := 'N'
     , p_refresh_conv_rates_flag      IN VARCHAR2 := 'N'
     , p_budget_version_id     IN  NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     , x_return_status     OUT   VARCHAR2
     , x_msg_count         OUT   NUMBER
     , x_msg_data          OUT   VARCHAR2
   )
IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_user_id                        NUMBER;
l_login_id                       NUMBER;
l_return_status                 VARCHAR2(1);

l_project_id                     NUMBER;
l_budget_version_id              NUMBER;
l_version_type                   PA_BUDGET_VERSIONS.version_type%TYPE;
l_finplan_type_id                NUMBER;
l_finplan_type_name              PA_FIN_PLAN_TYPES_VL.name%TYPE;
l_budget_version_number          NUMBER;


l_budget_entry_method_code       VARCHAR2(30);
l_resource_list_id               NUMBER;
l_fin_plan_level_code            VARCHAR2(30);
l_time_phased_code               VARCHAR2(30);
l_plan_in_multi_curr_flag        VARCHAR2(1);
l_budget_amount_code             VARCHAR2(30);
l_categorization_code            VARCHAR2(30);
l_project_number                 VARCHAR2(25);
l_budget_type_code               VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
l_change_reason_code             VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;

l_txn_curr_passed_flag           VARCHAR2(1) := 'N';
l_resource_asgn_id               NUMBER      := null;
l_valid                          VARCHAR2(1) := 'X';
l_trxn_curr_code                 VARCHAR2(30):= null;
l_call_with_res_txn_tbl_flag     VARCHAR2(1) := 'N';

l_raid_tmp_tbl                   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
l_resource_asgn_id_tab           SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
l_txn_curr_code_tab              SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
l_trxn_curr_code_tmp_tbl         SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;
--Added for bug 6378555 to pass G_PA_MISS_CHAR
l_pa_miss_char varchar2(1) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;

CURSOR c_validate_res_asgn_id
       (   l_project_id NUMBER , l_budget_version_id NUMBER
         , l_resource_assignment_id NUMBER
       )  IS
   SELECT '1'
   FROM DUAL
   WHERE EXISTS
   (
	   SELECT resource_assignment_id
	   FROM   PA_RESOURCE_ASSIGNMENTS
	   WHERE  PROJECT_ID = l_project_id
	   AND    BUDGET_VERSION_ID = l_budget_version_id
	   AND    RESOURCE_ASSIGNMENT_ID = l_resource_assignment_id
   );

CURSOR c_get_all_raid_txn_curr(l_project_id NUMBER, l_budget_version_id NUMBER,
l_resource_class_code VARCHAR2) IS
	select
	      pra.resource_assignment_id raid,
              pbl.txn_currency_code
	from
	      pa_resource_assignments pra,
	      pa_budget_lines pbl
	where pra.project_id = l_project_id
	and   pra.budget_version_id = l_budget_version_id
	AND   pra.resource_class_code = l_resource_class_code
	and   pra.resource_assignment_id = pbl.resource_assignment_id
	AND   pra.budget_version_id = pbl.budget_version_id
	GROUP BY pra.resource_assignment_id, pbl.txn_currency_code;

CURSOR c_get_txn_curr_code(l_resource_assignment_id NUMBER) IS
   SELECT distinct txn_currency_code
   FROM   pa_budget_lines
   WHERE  resource_assignment_id = l_resource_assignment_id;

CURSOR C_VALIDATE_FP_BUDGET_VERSION (l_budget_version_id NUMBER, l_project_id NUMBER )
IS
SELECT bv.fin_plan_type_id , bv.version_type, bv.version_number
FROM   pa_budget_versions bv
WHERE  bv.budget_version_id = l_budget_version_id
AND    bv.project_id = l_project_id
AND    bv.ci_id IS NULL;

CURSOR c_validate_curr_code(l_currency_code VARCHAR2 , l_resource_assignment_id NUMBER, l_budget_version_id NUMBER) IS
   SELECT 'Y'
   FROM DUAL
   WHERE EXISTS
	   (
	   SELECT TXN_CURRENCY_CODE
	   FROM pa_budget_lines
	   WHERE txn_currency_code = l_currency_code
	   AND   resource_assignment_id = l_resource_assignment_id
	   AND   budget_version_id = l_budget_version_id
	   );
l_valid_currency VARCHAR2(1);

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_user_id := fnd_global.user_id;
     l_login_id := fnd_global.login_id;
     l_debug_mode  := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id, l_login_id,275,null,null),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'REFRESH_RATES',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF NOT FND_API.Compatible_API_Call ( 1.0  ,p_api_version_number,'REFRESH_RATES',G_PKG_NAME) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     --Print All Input Params
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_FP_CALC_PLAN_PUB :REFRESH_RATES: Printing Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_pm_product_code'||':'||p_pm_product_code,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_project_id'||':'||p_project_id,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_pm_project_reference'||':'||p_pm_project_reference,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_update_plan_type'||':'||p_update_plan_type,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_structure_version_id'||':'||p_structure_version_id,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_budget_version_number'||':'||p_budget_version_number,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_version_type '||':'||p_version_type,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_finplan_type_id'||':'||p_finplan_type_id,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_finplan_type_name'||':'||p_finplan_type_name,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_refresh_cost_bill_rates_flag'||':'||p_refresh_cost_bill_rates_flag,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_refresh_conv_rates_flag'||':'||p_refresh_conv_rates_flag,
                                     l_debug_level3);

	  IF (p_resource_class_code_tab is not null and nvl(p_resource_class_code_tab.last,0) > 0) THEN
		  Pa_Debug.WRITE(g_module_name,'p_resource_class_code_tab is passed',l_debug_level3);
          END IF;

	  IF (p_resource_asgn_id_tab is not null and nvl(p_resource_asgn_id_tab.last,0) > 0) THEN
		  Pa_Debug.WRITE(g_module_name,'p_resource_asgn_id_tab is passed',l_debug_level3);
          END IF;

	  IF (p_txn_curr_code_tab is not null and nvl(p_txn_curr_code_tab.last,0) > 0) THEN
		  Pa_Debug.WRITE(g_module_name,'p_txn_curr_code_tab is passed',l_debug_level3);
          END IF;

     END IF;


     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint REFRESH_RATES_PUBLIC;
     END IF;
     --Validate All Input Params
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_FP_CALC_PLAN_PUB :REFRESH_RATES : Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF ( ( p_project_id IS NULL OR p_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) AND
          ( p_pm_project_reference IS NULL
	    OR p_pm_project_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
        )
     THEN
         IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage := 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES : Both Project_id and Project_reference are null';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
         END IF;
         RAISE Invalid_Arg_Exc_WP;
     END IF;

     IF ( p_update_plan_type NOT IN ('WORKPLAN', 'FINPLAN')) THEN
         IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES : p_update_plan_type is not WORKPLAN or FINPLAN ';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
         END IF;
         RAISE Invalid_Arg_Exc_WP;
     END IF;

     IF ( nvl ( p_refresh_cost_bill_rates_flag,'N' )='N' AND
          nvl ( p_refresh_conv_rates_flag, 'N' ) = 'N' ) THEN
         IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES : BOTH cost bill rate and conv rate flags are N';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
         END IF;
         RAISE Invalid_Arg_Exc_WP;
     END IF;

     IF ( p_update_plan_type = 'WORKPLAN' AND
         ( p_structure_version_id is null or p_structure_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) AND
	 ( p_budget_version_id is null or p_budget_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
        ) THEN
         IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES : p_update_plan_type is WORKPLAN but str version id is not passed';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
         END IF;
         pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_PS_STRUC_BV_VER_REQ'
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'GENERAL'
                     ,p_attribute1       => ''
                     ,p_attribute2       => ''
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF ( p_update_plan_type = 'FINPLAN' AND
          (
		  ( p_budget_version_number is null or p_budget_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) AND
		  ( p_finplan_type_id is null or p_finplan_type_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
		  ( p_finplan_type_name is null or p_finplan_type_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
          ) AND
		  ( p_budget_version_id is null or p_budget_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
        ) THEN
         IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES : p_update_plan_type is  FINPLAN but params not passed';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
         END IF;
         RAISE Invalid_Arg_Exc_WP;
     END IF;

     --
     IF (p_resource_asgn_id_tab is not null and nvl(p_resource_asgn_id_tab.last,0) > 0)  AND
        (p_txn_curr_code_tab is not null and nvl(p_txn_curr_code_tab.last,0) > 0) AND
	( p_resource_asgn_id_tab.count <> p_txn_curr_code_tab.count )
     THEN
	  IF l_debug_mode = 'Y' THEN
	       Pa_Debug.g_err_stage:= 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES : Txn_curr_code_tbl.count <> p_resource_asgn_id_tab.count';
	       Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
	  END IF;
	  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
		       p_msg_name => 'PA_PASS_TXN_CURR_CODE');
	  RAISE Invalid_Arg_Exc_WP;
     END IF;
     --Validate for project_id
     PA_PROJECT_PVT.Convert_pm_projref_to_id
        (        p_pm_project_reference =>      p_pm_project_reference
                 ,  p_pa_project_id     =>      p_project_id
                 ,  p_out_project_id    =>      l_project_id
                 ,  p_return_status     =>      l_return_status
        );
     IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE  Invalid_Arg_Exc_WP;
     ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE  FND_API.G_EXC_ERROR;
     END IF;
     --Assign values to local variables
     l_version_type := p_version_type;
     l_finplan_type_id := p_finplan_type_id;
     l_finplan_type_name := p_finplan_type_name;
     l_budget_version_number := p_budget_version_number;

     --Invoke check_edit_task_ok
     IF (p_update_plan_type = 'WORKPLAN') THEN

	IF ( p_budget_version_id is not null AND p_budget_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) THEN
	   l_budget_version_id := p_budget_version_id;
	ELSE
	   l_budget_version_id := null;
	END IF;

	IF l_debug_mode = 'Y' THEN
	      pa_debug.g_err_stage := 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES :Calling CHECK_EDIT_OK';
      	      Pa_Debug.WRITE(g_module_name,pa_debug.g_err_stage ,l_debug_level3);
	      Pa_Debug.WRITE(g_module_name,'l_project_id'||l_project_id,l_debug_level3);
              Pa_Debug.WRITE(g_module_name,'p_structure_version_id'||p_structure_version_id,l_debug_level3);
              Pa_Debug.WRITE(g_module_name,'l_budget_version_id'||l_budget_version_id,l_debug_level3);
        END IF;

	PA_TASK_ASSIGNMENT_UTILS.CHECK_EDIT_OK(
	 p_init_msg_list         => p_init_msg_list
	, p_commit                => 'F'
	, p_project_id            => l_project_id
	, p_pa_structure_version_id => p_structure_version_id
	, px_budget_version_id     => l_budget_version_id
	, x_return_status =>	l_return_status
	, x_msg_data      =>    l_msg_data
	, x_msg_count     =>    l_msg_count);

	IF l_debug_mode = 'Y' THEN
	      pa_debug.g_err_stage := 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES :Calling CHECK_EDIT_OK returned'||l_return_status;
	      Pa_Debug.WRITE(g_module_name,pa_debug.g_err_stage ,l_debug_level3);
	      Pa_Debug.WRITE(g_module_name,'l_budget_version_id'||l_budget_version_id,l_debug_level3);
        END IF;

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	        IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES :CHECK_EDIT_TASK_OK returned'||l_return_status ;
                      Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

     ELSIF (p_update_plan_type = 'FINPLAN') THEN
       IF (p_budget_version_id is not null and p_budget_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
		OPEN  C_VALIDATE_FP_BUDGET_VERSION(p_budget_version_id, l_project_id);
		FETCH C_VALIDATE_FP_BUDGET_VERSION INTO l_finplan_type_id, l_version_type, l_budget_version_number;
		IF (C_VALIDATE_FP_BUDGET_VERSION%NOTFOUND) THEN
			PA_UTILS.ADD_MESSAGE(
			 p_app_short_name  => 'PA'
			,p_msg_name        => 'PA_FP_INVALID_VERSION_ID'
			,p_token1          => 'BUDGET_VERSION_ID'
			,p_value1          => p_budget_version_id);

			CLOSE C_VALIDATE_FP_BUDGET_VERSION;
			raise FND_API.G_EXC_ERROR;
		END IF;
		CLOSE C_VALIDATE_FP_BUDGET_VERSION;
       END IF;
       IF l_debug_mode = 'Y' THEN
	      pa_debug.g_err_stage := 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES :Calling Validate_Header_Info';
	      Pa_Debug.WRITE(g_module_name,pa_debug.g_err_stage ,l_debug_level3);
	      Pa_Debug.WRITE(g_module_name,'l_project_id'||l_project_id,l_debug_level3);
              Pa_Debug.WRITE(g_module_name,'p_pm_project_reference'||p_pm_project_reference,l_debug_level3);
              Pa_Debug.WRITE(g_module_name,'p_pm_product_code'||p_pm_product_code,l_debug_level3);
              Pa_Debug.WRITE(g_module_name,'l_finplan_type_id'||l_finplan_type_id,l_debug_level3);
              Pa_Debug.WRITE(g_module_name,'l_finplan_type_name'||l_finplan_type_name,l_debug_level3);
              Pa_Debug.WRITE(g_module_name,'l_version_type'||l_version_type,l_debug_level3);
              Pa_Debug.WRITE(g_module_name,'l_budget_type_code'||l_budget_type_code,l_debug_level3);
              Pa_Debug.WRITE(g_module_name,'l_budget_version_number'||l_budget_version_number,l_debug_level3);
              Pa_Debug.WRITE(g_module_name,'l_change_reason_code'||l_change_reason_code,l_debug_level3);
       END IF;

	PA_BUDGET_PVT.Validate_Header_Info
	(
	  p_api_version_number            => 1.0
	 ,p_init_msg_list                 => 'F'
	 ,p_api_name                      => 'REFRESH_RATES'
	 ,px_pa_project_id                => l_project_id
	 ,p_pm_project_reference          => p_pm_project_reference
	 ,p_pm_product_code               => p_pm_product_code
	 ,px_fin_plan_type_id             => l_finplan_type_id
	 ,px_fin_plan_type_name           => l_finplan_type_name
	 ,px_version_type                 => l_version_type
	 ,px_budget_type_code             => l_budget_type_code
	 ,p_budget_version_number         => l_budget_version_number
	 ,p_function_name                 => 'PA_PM_UPDATE_BUDGET'
	 ,p_change_reason_code            => l_change_reason_code
	 ,x_budget_entry_method_code      => l_budget_entry_method_code
	 ,x_resource_list_id              => l_resource_list_id
	 ,x_budget_version_id             => l_budget_version_id
	 ,x_fin_plan_level_code           => l_fin_plan_level_code
	 ,x_time_phased_code              => l_time_phased_code
	 ,x_plan_in_multi_curr_flag       => l_plan_in_multi_curr_flag
	 ,x_budget_amount_code            => l_budget_amount_code
	 ,x_categorization_code           => l_categorization_code
	 ,x_project_number                => l_project_number
	  /* Plan Amount Entry flags introduced by bug 6378555 */
    /*Passing all as G_PA_MISS_CHAR since validations not required*/
         ,px_raw_cost_flag         =>   l_pa_miss_char
         ,px_burdened_cost_flag    =>   l_pa_miss_char
         ,px_revenue_flag          =>   l_pa_miss_char
         ,px_cost_qty_flag         =>   l_pa_miss_char
         ,px_revenue_qty_flag      =>   l_pa_miss_char
         ,px_all_qty_flag          =>   l_pa_miss_char
         ,px_bill_rate_flag        =>   l_pa_miss_char
         ,px_cost_rate_flag        =>   l_pa_miss_char
         ,px_burden_rate_flag      =>   l_pa_miss_char
       /* Plan Amount Entry flags introduced by bug 6378555 */
	 ,x_msg_count                     => l_msg_count
	 ,x_msg_data                      => l_msg_data
	 ,x_return_status                 => l_return_status
	 );
        IF l_debug_mode = 'Y' THEN
		Pa_Debug.WRITE(g_module_name,'PA_FP_CALC_PLAN_PUB : REFRESH_RATES :Calling Validate_Header_Info'||l_return_status,l_debug_level3);
		Pa_Debug.WRITE(g_module_name,'PA_FP_CALC_PLAN_PUB : REFRESH_RATES :Calling Validate_Header_Info'||l_budget_version_id,l_debug_level3);
        END IF;
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		IF l_debug_mode = 'Y' THEN
		      pa_debug.g_err_stage := 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES :Validate_Header_Info returned'||l_return_status ;
		      Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
     END IF;--update_plan_type FINPLAN

     IF ( p_txn_curr_code_tab is not null and nvl(p_txn_curr_code_tab.last,0) > 0 ) THEN
         l_txn_curr_passed_flag := 'Y';
     END IF;

     l_resource_asgn_id_tab.delete;
     l_txn_curr_code_tab.delete;

     --If res_asgn_id_tbl is passed
     -----if trxn_curr_code_tbl is also passed
     -----populate local res asgn id tbl and trxn curr tables with corresponding vales
     -----else
     -----derive trxn currency codes for each resource asgn id
     -----populate local res asgn id tbl and trxn curr tables with corresponding vales
     IF ( p_resource_asgn_id_tab is not null and nvl(p_resource_asgn_id_tab.last,0) > 0 ) THEN
         l_resource_asgn_id := null;

	 FOR i IN p_resource_asgn_id_tab.FIRST..p_resource_asgn_id_tab.LAST LOOP
           l_resource_asgn_id := p_resource_asgn_id_tab(i);

	    --Validate res asgn id with budget version id
	    OPEN  c_validate_res_asgn_id ( l_project_id,l_budget_version_id ,l_resource_asgn_id );
	    FETCH c_validate_res_asgn_id  INTO l_valid;
	    IF   ( c_validate_res_asgn_id%NOTFOUND ) THEN
	       --Raise Error
  	         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
		     p_msg_name => 'PA_INVALID_RES_ASGN_ID');
	         CLOSE c_validate_res_asgn_id;
		 RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE c_validate_res_asgn_id;

	    IF ( l_txn_curr_passed_flag = 'Y') THEN
		 IF ( p_txn_curr_code_tab(i) IS NULL OR
		      p_txn_curr_code_tab(i) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN
			 /*--Raise Error
			 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
			     p_msg_name => 'PA_PASS_TXN_CURR_CODE');
			 RAISE FND_API.G_EXC_ERROR;*/

			 /*
			 In Case Selective Refresh is required, we can comment above and use following
			 After discussion with Venky, it is assumed that if user is passinf txn curr
			 code tbl he/she will pass it correctly with each txn curr code.

			 In case if it is decided to supprot selective refresh, following code can be uncommented
                         */

			 OPEN  c_get_txn_curr_code(l_resource_asgn_id);
			 FETCH c_get_txn_curr_code BULK COLLECT INTO l_trxn_curr_code_tmp_tbl;
			 CLOSE c_get_txn_curr_code;
			 IF (l_trxn_curr_code_tmp_tbl is not null and
			     nvl (l_trxn_curr_code_tmp_tbl.last, 0) > 0) THEN
				 FOR  i  IN l_trxn_curr_code_tmp_tbl.FIRST..l_trxn_curr_code_tmp_tbl.LAST LOOP
				      l_resource_asgn_id_tab.extend;
				      l_txn_curr_code_tab.extend;

				      l_resource_asgn_id_tab(l_resource_asgn_id_tab.count) := l_resource_asgn_id;
				      l_txn_curr_code_tab(l_txn_curr_code_tab.count) := l_trxn_curr_code_tmp_tbl(i);
				 END LOOP;
			 END IF;

	 	 ELSE
		     --Code to validate if txn currency code is correct or not
		     OPEN   c_validate_curr_code(p_txn_curr_code_tab(i),l_resource_asgn_id, l_budget_version_id);
		     FETCH  c_validate_curr_code INTO l_valid_currency;
		     IF (c_validate_curr_code%NOTFOUND) THEN
		        PA_UTILS.ADD_MESSAGE(   p_app_short_name => 'PA'
		                              , p_msg_name => 'PA_INVALID_CURR_CODE'
 					      , p_token1           => 'TxncurrencyCode'
                                              , p_value1           => p_txn_curr_code_tab(i)
                                              , p_token2           => 'ResourceAssignmentID'
                                              , p_value2           => l_resource_asgn_id);
	                CLOSE c_validate_curr_code;
		        RAISE FND_API.G_EXC_ERROR;
		     END IF;
		     CLOSE c_validate_curr_code;
		     l_resource_asgn_id_tab.extend;
		     l_txn_curr_code_tab.extend;

                     l_resource_asgn_id_tab(l_resource_asgn_id_tab.count) := l_resource_asgn_id;
		     l_txn_curr_code_tab(l_txn_curr_code_tab.count) := p_txn_curr_code_tab(i);
                 END IF;
            ELSE
	         OPEN  c_get_txn_curr_code(l_resource_asgn_id);
		 FETCH c_get_txn_curr_code BULK COLLECT INTO l_trxn_curr_code_tmp_tbl;
		 CLOSE c_get_txn_curr_code;
		 IF (l_trxn_curr_code_tmp_tbl is not null and
		     nvl (l_trxn_curr_code_tmp_tbl.last, 0) > 0) THEN
			 FOR  i  IN l_trxn_curr_code_tmp_tbl.FIRST..l_trxn_curr_code_tmp_tbl.LAST LOOP
			      l_resource_asgn_id_tab.extend;
			      l_txn_curr_code_tab.extend;

			      l_resource_asgn_id_tab(l_resource_asgn_id_tab.count) := l_resource_asgn_id;
			      l_txn_curr_code_tab(l_txn_curr_code_tab.count) := l_trxn_curr_code_tmp_tbl(i);
			 END LOOP;
		 END IF;
	    END IF;
	 END LOOP;
	 l_call_with_res_txn_tbl_flag := 'Y';
     --else if
     --resource_class_codes are passed
     --1. For each resource class code, project_id, budget_version_id , get all res asgn id and their corres-
     --ponding txn currency codes
     --2. Populate local plsql tables l_resource_asgn_id_tab and l_txn_curr_code_tab
     ELSIF (p_resource_class_code_tab is not null and nvl(p_resource_class_code_tab.last,0) > 0) THEN
         l_raid_tmp_tbl.delete;
	 l_trxn_curr_code_tmp_tbl.delete;

	 FOR i IN p_resource_class_code_tab.FIRST..p_resource_class_code_tab.LAST LOOP
		OPEN  c_get_all_raid_txn_curr(l_project_id , l_budget_version_id , p_resource_class_code_tab(i) );
		FETCH c_get_all_raid_txn_curr BULK COLLECT INTO l_raid_tmp_tbl, l_trxn_curr_code_tmp_tbl;
		CLOSE c_get_all_raid_txn_curr;

		IF (l_raid_tmp_tbl is not null and nvl(l_raid_tmp_tbl.count,0) >0) THEN
			FOR i IN l_raid_tmp_tbl.FIRST..l_raid_tmp_tbl.LAST LOOP
			    l_resource_asgn_id_tab.extend;
			    l_txn_curr_code_tab.extend;
			    l_resource_asgn_id_tab(l_resource_asgn_id_tab.count) := l_raid_tmp_tbl(i);
			    l_txn_curr_code_tab(l_txn_curr_code_tab.count) := l_trxn_curr_code_tmp_tbl(i);
			END LOOP;
                END IF;
                l_raid_tmp_tbl.delete;
	        l_trxn_curr_code_tmp_tbl.delete;
         END LOOP;
	 l_call_with_res_txn_tbl_flag := 'Y';

     --else nothing is passed, refresh for  budget version id
     ELSE
	  PA_FP_CALC_PLAN_PKG.calculate(
	  	  p_project_id              => l_project_id
   	        , p_budget_version_id       => l_budget_version_id
 	        , p_refresh_rates_flag      => p_refresh_cost_bill_rates_flag
 	        , p_refresh_conv_rates_flag => p_refresh_conv_rates_flag
 	        , p_source_context	    => 'RESOURCE_ASSIGNMENT'
	        , x_return_status	    => l_return_status
		, x_msg_count		    => l_msg_count
		, x_msg_data		    => l_msg_data
	  );
	  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	        IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES :Calculate returned '||l_return_status ;
                      Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
                END IF;
                RAISE FND_API.G_EXC_ERROR;
	  END IF;

     END IF;

     IF (l_call_with_res_txn_tbl_flag = 'Y' ) THEN
     IF l_debug_mode = 'Y' THEN
	      pa_debug.g_err_stage := 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES :Calling Calculate';
      	      Pa_Debug.WRITE(g_module_name,pa_debug.g_err_stage ,l_debug_level3);
	      Pa_Debug.WRITE(g_module_name,'l_project_id'||l_project_id,l_debug_level3);
              Pa_Debug.WRITE(g_module_name,'l_budget_version_id'||l_budget_version_id,l_debug_level3);
              Pa_Debug.WRITE(g_module_name,'p_refresh_cost_bill_rates_flag'||p_refresh_cost_bill_rates_flag,l_debug_level3);
              Pa_Debug.WRITE(g_module_name,'p_refresh_conv_rates_flag'||p_refresh_conv_rates_flag,l_debug_level3);
              FOR i IN l_resource_asgn_id_tab.FIRST..l_resource_asgn_id_tab.LAST LOOP
		      Pa_Debug.WRITE(g_module_name,'l_resource_asgn_id_tab'||to_char(l_resource_asgn_id_tab(i)),l_debug_level3);
		      Pa_Debug.WRITE(g_module_name,'l_txn_curr_code_tab'||to_char( l_txn_curr_code_tab(i)),l_debug_level3);
	      END LOOP;
     END IF;
        PA_FP_CALC_PLAN_PKG.calculate(
	   	  p_project_id              => l_project_id
   	        , p_budget_version_id       => l_budget_version_id
 	        , p_refresh_rates_flag      => p_refresh_cost_bill_rates_flag
 	        , p_refresh_conv_rates_flag => p_refresh_conv_rates_flag
 	        , p_source_context          => 'RESOURCE_ASSIGNMENT'
		, p_resource_assignment_tab => l_resource_asgn_id_tab
                , p_txn_currency_code_tab   => l_txn_curr_code_tab
		, x_return_status	    => l_return_status
		, x_msg_count		    => l_msg_count
		, x_msg_data		    => l_msg_data
	  );
	  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	        IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES :Calculate returned '||l_return_status ;
                      Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
                END IF;
                RAISE FND_API.G_EXC_ERROR;
	  END IF;
     END IF;



 IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
 END IF;


EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO REFRESH_RATES_PUBLIC;
     END IF;

     IF c_validate_res_asgn_id%ISOPEN THEN
        CLOSE c_validate_res_asgn_id;
     END IF;

     IF c_get_all_raid_txn_curr%ISOPEN THEN
        CLOSE c_get_all_raid_txn_curr;
     END IF;

     IF c_get_txn_curr_code%ISOPEN THEN
        CLOSE c_get_txn_curr_code;
     END IF;

     IF C_VALIDATE_FP_BUDGET_VERSION%ISOPEN THEN
        CLOSE C_VALIDATE_FP_BUDGET_VERSION;
     END IF;

     IF c_validate_curr_code%ISOPEN THEN
        CLOSE c_validate_curr_code;
     END IF;

     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_TRUE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc_WP THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'PA_FP_CALC_PLAN_PUB : REFRESH_RATES :Invalid Arguments are passed';

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO REFRESH_RATES_PUBLIC;
     END IF;

     IF c_validate_res_asgn_id%ISOPEN THEN
        CLOSE c_validate_res_asgn_id;
     END IF;

     IF c_get_all_raid_txn_curr%ISOPEN THEN
        CLOSE c_get_all_raid_txn_curr;
     END IF;

     IF c_get_txn_curr_code%ISOPEN THEN
        CLOSE c_get_txn_curr_code;
     END IF;

     IF C_VALIDATE_FP_BUDGET_VERSION%ISOPEN THEN
        CLOSE C_VALIDATE_FP_BUDGET_VERSION;
     END IF;

     IF c_validate_curr_code%ISOPEN THEN
        CLOSE c_validate_curr_code;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_CALC_PLAN_PUB'
                    , p_procedure_name  => 'REFRESH_RATES'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     -- RAISE; Bug 4530531

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO REFRESH_RATES_PUBLIC;
     END IF;

     IF c_validate_res_asgn_id%ISOPEN THEN
        CLOSE c_validate_res_asgn_id;
     END IF;

     IF c_get_all_raid_txn_curr%ISOPEN THEN
        CLOSE c_get_all_raid_txn_curr;
     END IF;

     IF c_get_txn_curr_code%ISOPEN THEN
        CLOSE c_get_txn_curr_code;
     END IF;

     IF C_VALIDATE_FP_BUDGET_VERSION%ISOPEN THEN
        CLOSE C_VALIDATE_FP_BUDGET_VERSION;
     END IF;

     IF c_validate_curr_code%ISOPEN THEN
        CLOSE c_validate_curr_code;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_FP_CALC_PLAN_PUB'
                    , p_procedure_name  => 'REFRESH_RATES'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     -- RAISE; Bug 4530531

END REFRESH_RATES ;


END PA_FP_CALC_PLAN_PUB;

/
