--------------------------------------------------------
--  DDL for Package Body PA_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EVENT_PVT" AS
/* $Header: PAEVAPVB.pls 120.6.12010000.3 2009/05/26 10:50:26 nkapling ship $ */
g_inv_evt_fun_allowed VARCHAR2(1)  DEFAULT NULL;
g_rev_evt_fun_allowed VARCHAR2(1) DEFAULT NULL;

-- ============================================================================
--
--Name:         check_mdty_params1
--Type:         Procedure
--Description:  This function validates the mandatory parameters1 which
--		includes
--		1.product code,
--		2.function security ,
--		3.api compatibility.
--
--Called subprograms:FND_API.Compatible_API_Call
--		     PA_PM_FUNCTION_SECURITY_PUB.check_function_security
--
--
--
--History:

-- ============================================================================
PROCEDURE CHECK_MDTY_PARAMS1
    ( p_api_version_number     		IN   NUMBER
     ,p_api_name 	      		IN   VARCHAR2
     ,p_pm_product_code			IN   VARCHAR2
     ,p_function_name 			IN   VARCHAR2
     ,x_return_status                   OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                       OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                        OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

AS

Cursor ProductCode_cur(P_pm_product_code    VARCHAR2)
Is
        select 1
        from pa_lookups
        where lookup_type ='PM_PRODUCT_CODE'
        and lookup_code=P_pm_product_code;

l_product_code          	NUMBER:=NULL;
l_resp_id                       NUMBER := 0;
l_function_allowed              VARCHAR2(1);
l_debug_mode 			VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

BEGIN


  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_MDTY_PARAMS1.begin'
                     ,x_msg         => 'Beginning of Check Mandatory Parameters1 '
                     ,x_log_level   => 5);
   END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;


--  Standard call to check for call compatibility.

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_MDTY_PARAMS1.begin'
                     ,x_msg         => 'Beginning of  api compatibility check '
                     ,x_log_level   => 5);
  End If;

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         p_api_name             ,
                                         G_PKG_PVT             )
    THEN

	x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_MDTY_PARAMS1.begin'
                     ,x_msg         => 'Beginning of  Function security Check'
                     ,x_log_level   => 5);
  End If;

    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      ( p_api_version_number => p_api_version_number
       ,p_responsibility_id  => l_resp_id
       ,p_function_name      => p_function_name
       ,p_msg_count          => x_msg_count
       ,p_msg_data           => x_msg_data
       ,p_return_status      => x_return_status
       ,p_function_allowed   => l_function_allowed );

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF x_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
--For Bug 3619483
END IF;

		IF fnd_function.test('PA_PAXINEVT_MAINT_INV_EVENTS') THEN
	           	g_inv_evt_fun_allowed := 'Y';
     		ELSE
        	   	g_inv_evt_fun_allowed := 'N';
     		END IF;

		IF fnd_function.test('PA_PAXINEVT_MAINT_REV_EVENTS') THEN
           		g_rev_evt_fun_allowed := 'Y';
     		ELSE
           		g_rev_evt_fun_allowed := 'N';
     		END IF;
  IF (g_inv_evt_fun_allowed = 'N') AND (g_rev_evt_fun_allowed = 'N') THEN
	pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_EV_NO_PRV_MAINT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
	 x_return_status := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
  END IF;

--END OF BUG FIX 3619483
  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_MDTY_PARAMS1.begin'
                     ,x_msg         => 'Validating Product Code'
                     ,x_log_level   => 5);
  End If;

    -- CHECK WHETHER MANDATORY INCOMING PARAMETER PRODUCT CODE EXIST
    IF (p_pm_product_code IS NULL)
     	OR (p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
     IF (p_pm_product_code IS NOT NULL AND p_function_name <> 'PA_EV_UPDATE_EVENT') /* Added for bug 5056969 */
     THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISS'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'GENERAL'
                        ,p_attribute1       => ''
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      End IF;   /* End of 'If' Added for bug 5056969 */
    ELSE
	Open ProductCode_cur(P_pm_product_code);
	Fetch ProductCode_cur Into l_product_code;
	Close ProductCode_cur;

		If l_product_code Is NULL
		Then
			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
			pa_interface_utils_pub.map_new_amg_msg
				( p_old_message_code => 'PA_INVALID_PRODUCT_CODE'
				,p_msg_attribute    => 'CHANGE'
				,p_resize_flag      => 'N'
				,p_msg_context      => 'GENERAL'
				,p_attribute1       => ''
				,p_attribute2       => ''
				,p_attribute3       => ''
				,p_attribute4       => ''
				,p_attribute5       => '');
			 END IF;
			 x_return_status := FND_API.G_RET_STS_ERROR;
			 RAISE FND_API.G_EXC_ERROR;
		End If;
    END IF;

  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_MDTY_PARAMS1.begin'
                     ,x_msg         => 'End of Check Mandatory Parameters1 '
                     ,x_log_level   => 5);
   END IF;

        --handling exceptions
        Exception
        WHEN FND_API.G_EXC_ERROR
                THEN
                RAISE FND_API.G_EXC_ERROR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
                THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        When pa_event_utils.pvt_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'check_mdty_params1->';
                Raise pub_excp;--raising exception to be handled in public package


        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'check_mdty_params1->';
                Raise pub_excp;--raising exception to be handled in public package

END check_mdty_params1;

-- ============================================================================
--
--Name:
--Type:
--Description: This API checks mandatory input parameters for null or '^'.
--		The mandatory parameters are
--		1.event reference,
--		2.project number,
--		3.event type ,
--		4.event organization
--		during creation of new event.
--		And event reference for update and delete of an event.
--
--Called subprograms:PA_EVENT_PVT.CHECK_EVENT_REF_UNQ
--
-- ============================================================================
PROCEDURE CHECK_MDTY_PARAMS2
   (  p_pm_event_reference    IN   VARCHAR2
     ,P_pm_product_code	      IN   VARCHAR2
     ,p_project_number        IN   VARCHAR2
     ,p_event_type            IN   VARCHAR2
     ,p_organization_name     IN   VARCHAR2
     ,p_calling_place         IN   VARCHAR2
     ,x_return_status         OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

AS

l_debug_mode 			VARCHAR2(1):= NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

BEGIN

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_MDTY_PARAMS2.begin'
                     ,x_msg         => 'Beginning of Check Mandatory Parameters2 '
                     ,x_log_level   => 5);
  END IF;

  --Initialising return status
  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_MDTY_PARAMS2.begin'
                     ,x_msg         => 'Checking event reference for null or ^ '
                     ,x_log_level   => 5);
  END IF;

      IF (p_pm_event_reference IS NULL
 	  OR p_pm_event_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
      THEN
		  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		  THEN
			pa_interface_utils_pub.map_new_amg_msg
			       ( p_old_message_code =>'PA_EVENT_REF_IS_MISS'
				,p_msg_attribute    => 'CHANGE'
				,p_resize_flag      => 'N'
				,p_msg_context      => 'EVENT'
				,p_attribute1       => null
				,p_attribute2       => ''
				,p_attribute3       => ''
				,p_attribute4       => ''
				,p_attribute5       => '');
		   END IF;
		 x_return_status         := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_MDTY_PARAMS2.begin'
                     ,x_msg         => 'Start of Validations for Create Event '
                     ,x_log_level   => 5);
  END IF;

 --Start of validations required for creating events
IF (p_calling_place='CREATE_EVENT') then

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_MDTY_PARAMS2.begin'
                     ,x_msg         => 'Validating Uniqueness of event reference '
                     ,x_log_level   => 5);
  END IF;

  --Calls PA_EVENT_PVT.CHECK_EVENT_REF_UNQ to check the event reference is unique
  --and not present in Oracle Projects DB for the given pm_product_code
      If PA_EVENT_PVT.CHECK_EVENT_REF_UNQ
        (P_pm_product_code      =>P_pm_product_code
        ,P_pm_event_reference   =>P_pm_event_reference)='N'
      Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_EVENT_REF_IS_NOT_UNQ'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                 END IF;
                 x_return_status         := FND_API.G_RET_STS_ERROR;
                 RAISE FND_API.G_EXC_ERROR;
      End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_MDTY_PARAMS2.begin'
                     ,x_msg         => 'Checking project number for null or ^ '
                     ,x_log_level   => 5);
  END IF;

   IF (p_project_number IS NULL
	OR p_project_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_PROJ_NUM_IS_MISS'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
           END IF;
           x_return_status         := FND_API.G_RET_STS_ERROR;
   END IF;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_MDTY_PARAMS2.begin'
                     ,x_msg         => 'Checking Event type for null or ^ '
                     ,x_log_level   => 5);
  END IF;

   IF (p_event_type IS NULL
	OR p_event_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_EVNT_TYPE_IS_MISS'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
           END IF;
         x_return_status         := FND_API.G_RET_STS_ERROR;
   END IF;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_MDTY_PARAMS2.begin'
                     ,x_msg         => 'Checking organization name for null or ^ '
                     ,x_log_level   => 5);
  END IF;

   IF (p_organization_name IS NULL
	OR p_organization_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_EVNT_ORG_IS_MISS'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
           END IF;
           x_return_status         := FND_API.G_RET_STS_ERROR;
   END IF;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_MDTY_PARAMS2.begin'
                     ,x_msg         => 'End of Validations for Create Event '
                     ,x_log_level   => 5);
  END IF;

END IF;          /* end of validations for create_event */

  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_MDTY_PARAMS1.begin'
                     ,x_msg         => 'End of Check Mandatory Parameters2'
                     ,x_log_level   => 5);
   END IF;

        --handling exceptions
        Exception
        WHEN FND_API.G_EXC_ERROR
                THEN
                RAISE FND_API.G_EXC_ERROR;

        When pa_event_utils.pvt_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_MDTY_PARAMS2->';
                Raise pub_excp;--raising exception to be handled in public package

        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_MDTY_PARAMS2->';
                Raise pub_excp;--raising exception to be handled in public package


END CHECK_MDTY_PARAMS2;

-- ============================================================================
--
--Name:               CHECK_CREATE_EVENT_OK
--Type:               function
--Description:  This function validates if the event is valid and can be created.
--
--Called subprograms:
--			PA_EVENT_UTILS.CHECK_VALID_TASK
--			PA_EVENT_UTILS.CHECK_VALID_EVENT_TYPE
--			PA_EVENT_UTILS.CHECK_VALID_EVENT_ORG
--			PA_EVENT_UTILS.CHECK_VALID_REV_AMT
--			PA_EVENT_UTILS.CHECK_VALID_BILL_AMT
--			PA_EVENT_UTILS.CHECK_VALID_EVENT_NUM
--			PA_EVENT_UTILS.CHECK_VALID_INV_ORG
--			PA_EVENT_UTILS.CHECK_VALID_INV_ITEM
--			PA_EVENT_UTILS.CHECK_VALID_CURR
--			PA_EVENT_UTILS.CHECK_VALID_FUND_RATE_TYPE
--			PA_EVENT_UTILS.CHECK_VALID_PROJ_RATE_TYPE
--			PA_EVENT_UTILS.CHECK_VALID_PFC_RATE_TYPE
-- 			PA_EVENT_UTILS.CHECK_VALID_AGREEMENT
--                      PA_EVENT_UTILS.CHECK_VALID_EVENT_DATE
-- ============================================================================
FUNCTION CHECK_CREATE_EVENT_OK
(P_pm_product_code      		IN      VARCHAR2
,P_event_in_rec         		IN      pa_event_pub.Event_rec_in_type
,P_project_currency_code       		IN	VARCHAR2
,P_proj_func_currency_code     		IN	VARCHAR2
,P_project_bil_rate_date_code  		IN	VARCHAR2
,P_project_rate_type                    IN      VARCHAR2
,p_project_bil_rate_date                IN      VARCHAR2
,p_projfunc_bil_rate_date_code 		IN	VARCHAR2
,P_projfunc_rate_type                   IN      VARCHAR2
,p_projfunc_bil_rate_date               IN      VARCHAR2
,P_funding_rate_type			IN 	VARCHAR2
,P_multi_currency_billing_flag		IN	VARCHAR2
,p_project_id                   	IN  	NUMBER
,p_projfunc_bil_exchange_rate           IN      NUMBER -- Added  for bug 3013137
,p_funding_bil_rate_date_code           IN      VARCHAR2 --Added for bug 3053190
,x_task_id                     		OUT 	NOCOPY NUMBER	 --File.Sql.39 bug 4440895
,x_organization_id 			OUT     NOCOPY NUMBER	 --File.Sql.39 bug 4440895
,x_inv_org_id				OUT     NOCOPY NUMBER  --File.Sql.39 bug 4440895
,x_agreement_id                         OUT     NOCOPY NUMBER  -- Federal Uptake
,P_event_type_classification            OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
RETURN VARCHAR2
IS

l_projfunc_rate_date		pa_projects_all.projfunc_bil_rate_date%type;
l_project_rate_date		pa_projects_all.project_bil_rate_date%type;
p_api_name			VARCHAR2(100):='CHECK_CREATE_EVENT_OK';
l_funding_rate_type		PA_EVENTS.funding_rate_type%TYPE;
l_proj_func_currency_code	PA_EVENTS.projfunc_currency_code%TYPE;
l_return_status			VARCHAR2(1):='Y';
l_debug_mode                    VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
l_ret_status			VARCHAR2(2000):=NULL;
l_project_rate_type		PA_EVENTS.project_rate_type%TYPE; -- Added  for bug 3013137 and 3009307
l_projfunc_rate_type		PA_EVENTS.projfunc_rate_type%TYPE; --  Added  for bug 3013137 and 3009307

BEGIN
  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
                     ,x_msg         => 'Beginning of Check Create Event Ok'
                     ,x_log_level   => 5);
  END IF;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating task for the given project'
                     ,x_log_level   => 5);
  END IF;

  --validating the task
  If (P_event_in_rec.P_task_number Is NOT NULL
      AND P_event_in_rec.P_task_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  Then
    If PA_EVENT_UTILS.check_valid_task
		(P_project_id	=>P_project_id
		,P_task_id	=>x_task_id
		,P_task_num	=>P_event_in_rec.P_task_number)='N'
    Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_TOP_TASK'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
	 Return(l_return_status);  --If task_id is invalid then terminate further validation
    End If;
	  --Log Message
	  IF l_debug_mode = 'Y' THEN
	  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
			     ,x_msg         => 'Validating funding level of the project'
			     ,x_log_level   => 5);
	  END IF;
  Else
	x_task_id:=NULL;
  End If;

  --validating the funding level of the project.
    If PA_EVENT_UTILS.check_funding
	(P_project_id	=>P_project_id
	,P_task_id	=>x_task_id)='N'
    Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_TASK_FUND_NO_PROJ_EVENT'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
         Return(l_return_status);  --If task_id is invalid then terminate further validation
    End If;

 -- log Message   -- Start of Federal Uptake
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating agreement for the given project'
                     ,x_log_level   => 5);
  END IF;

  --validating the agreement
  If ( ( P_event_in_rec.P_agreement_number Is NOT NULL  OR
         P_event_in_rec.P_agreement_type   IS NOT NULL  OR
         P_event_in_rec.P_customer_number  IS NOT NULL   )
    AND( P_event_in_rec.P_agreement_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))
  Then
    If PA_EVENT_UTILS.CHECK_VALID_AGREEMENT (
 			 P_project_id          =>  P_project_id
			,P_task_id             =>  x_task_id
			,P_agreement_number    =>  P_event_in_rec.P_agreement_number
			,P_agreement_type      =>  P_event_in_rec.P_agreement_type
			,P_customer_number     =>  P_event_in_rec.P_customer_number
			,P_agreement_id        =>  x_agreement_id ) ='N'
    Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_AGMT_NUM'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
         Return(l_return_status);  --If agreement_id is invalid then terminate further validation
    End If;
   End IF;

 --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating event date is between agreement date'
                     ,x_log_level   => 5);
  END IF;

  --validating event date
  If (   P_event_in_rec.P_completion_date Is NOT NULL
      AND P_event_in_rec.P_completion_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE  )
  Then
    If PA_EVENT_UTILS.CHECK_VALID_EVENT_DATE (
 			 P_event_date          =>  P_event_in_rec.P_completion_date
			,P_agreement_id        =>  x_agreement_id ) ='N'
    Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_EVENT_DATE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
         Return(l_return_status);  --If event date is not between agreement date
    End If;
   End IF;
-- End of Federal Uptake

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating the event_type'
                     ,x_log_level   => 5);
  END IF;

  If ( P_event_in_rec.P_context = 'D' )
  Then
      IF (P_event_in_rec.P_deliverable_id IS NULL OR
         P_event_in_rec.P_deliverable_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
      Then
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_EV_DLV_ID_MISS'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
          END IF;
          l_return_status:='N';
      END If;

    IF (P_event_in_rec.P_action_id IS NULL OR
         P_event_in_rec.P_action_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
      Then
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_EV_ACT_ID_MISS'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
          END IF;
          l_return_status:='N';
      END If;
  End If;

  --validating the event_type
  If PA_EVENT_UTILS.check_valid_event_type
	(P_event_type			=>P_event_in_rec.P_event_type
	,P_context			=>P_event_in_rec.P_context
	,X_event_type_classification	=>p_event_type_classification)='N'
  Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_EVNT_TYPE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
  End If;
--For Bug 3619483
IF  ((g_rev_evt_fun_allowed = 'N' )  AND
     (p_event_type_classification IN('WRITE ON','WRITE OFF') )) THEN
	pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_EV_NO_REV_MAINT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
              RAISE FND_API.G_EXC_ERROR;
END IF;

IF ((g_inv_evt_fun_allowed = 'N' )  AND
    (p_event_type_classification IN('DEFERRED REVENUE','INVOICE REDUCTION','SCHEDULED PAYMENTS'))) THEN
	pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_EV_NO_INV_MAINT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
      	      RAISE FND_API.G_EXC_ERROR;
END IF;

IF     ((p_event_type_classification = 'MANUAL')  AND
   	(g_inv_evt_fun_allowed = 'Y' )  AND
   	(g_rev_evt_fun_allowed = 'N' ) AND
  	(NVL(p_event_in_rec.P_bill_trans_rev_amount,0)<> 0)) THEN
	pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_EV_NO_REV_MAINT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
	 pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_INVALID_REV_AMT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
              RAISE FND_API.G_EXC_ERROR;
END IF;

IF   ((p_event_type_classification = 'MANUAL')  AND
     (g_inv_evt_fun_allowed = 'N' ) AND
     (g_rev_evt_fun_allowed = 'Y' ) AND
     (NVL(p_event_in_rec.P_bill_trans_bill_amount,0) <> 0 )) THEN
	pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_EV_NO_INV_MAINT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
	pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_BILL_AMT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
      	      RAISE FND_API.G_EXC_ERROR;
END IF;

--End of Bug fix3619483

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating organisation name and deriving organisation_id'
                     ,x_log_level   => 5);
  END IF;
  --calls PA_EVENT_UTILS.CHECK_VALID_EVENT_ORG to validate and
  --derive the organisation_id from organisation name
  If PA_EVENT_UTILS.check_valid_event_org
                (P_event_org_name       =>p_event_in_rec.P_organization_name
                ,P_event_org_id         =>x_Organization_Id)='N'
  Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_EVNT_ORG'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
  End If;


  --validating the currency fields if mcb is enabled
  If (P_multi_currency_billing_flag ='Y')
  Then

	  --Log Message
	  IF l_debug_mode = 'Y' THEN
	  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
			     ,x_msg         => 'Start of MCB Validations '
			     ,x_log_level   => 5);
	  END IF;

	  --Log Message
	  IF l_debug_mode = 'Y' THEN
	  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
			     ,x_msg         => 'Validating bill trans currency code'
			     ,x_log_level   => 5);
	  END IF;

	  --If bill trans currency code is null
	  --then the default value is used for further validation.
	  If (p_event_in_rec.P_bill_trans_currency_code Is NULL)
	    Then
		l_proj_func_currency_code:=P_proj_func_currency_code;
	  ElsIf PA_EVENT_UTILS.check_valid_curr
		(P_bill_trans_curr	=>p_event_in_rec.P_bill_trans_currency_code)='N'
	    Then
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			pa_interface_utils_pub.map_new_amg_msg
				(p_old_message_code => 'PA_INVALID_BIL_TRX_CUR'
				,p_msg_attribute    => 'CHANGE'
				,p_resize_flag      => 'N'
				,p_msg_context      => 'EVENT'
				,p_attribute1       => P_event_in_rec.p_pm_event_reference
				,p_attribute2       => ''
				,p_attribute3       => ''
				,p_attribute4       => ''
				,p_attribute5       => '');
		 END IF;
		 l_return_status:='N';
		 l_proj_func_currency_code:=P_proj_func_currency_code;
	    Else
		 l_proj_func_currency_code:=p_event_in_rec.P_bill_trans_currency_code;
          End If;

	  --Log Message
	  IF l_debug_mode = 'Y' THEN
	  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
			     ,x_msg         => 'Validating funding rate type'
			     ,x_log_level   => 5);
	  END IF;

	  --If funding rate type is  null or '^' then the default value is used for other validations.
	  If (P_event_in_rec.P_funding_rate_type Is NOT NULL
		AND P_event_in_rec.P_funding_rate_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
	  Then
	    If PA_EVENT_UTILS.check_valid_fund_rate_type
		(P_fund_rate_type	=>P_event_in_rec.P_funding_rate_type,
		 x_fund_rate_type	=>l_funding_rate_type)='N'
	    Then
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_FUND_RATE_TYPE_INV'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
			,p_attribute5       => '');
		 END IF;
		 l_return_status:='N';
	     End If;
          ELSE l_funding_rate_type := P_funding_rate_type; -- Added for bug 3013137 and 3009307

	  End If;

	  -- When fuding rate type is 'User' at event level and not 'User' at the  project level
	  -- and exchange rate is not a valid positive number then error is raised.
        --For bug 3045302
        --  If exchange rate has been passed by the AMG is 0 or -ve then
        --  irrespective of the Rate Type we should raise an error.

            If ((UPPER(P_event_in_rec.P_funding_rate_type) = 'USER'
		    AND p_event_in_rec.P_funding_rate_type <> P_funding_rate_type
		    AND ( p_event_in_rec.P_funding_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
			  OR p_event_in_rec.P_funding_exchange_rate Is NULL ))
			  OR p_event_in_rec.P_funding_exchange_rate <= 0)
	     Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_FUND_EXCG_RATE_INV'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
	     End If;

     /*  Added   for  bug  3053190   */
            If ( p_funding_bil_rate_date_code ='FIXED_DATE'
                 AND UPPER(P_funding_rate_type) ='USER'
                 AND NVL(UPPER(P_event_in_rec.P_funding_rate_type),'USER') <>'USER'
                 AND (P_event_in_rec.P_funding_rate_date IS NULL
                      OR P_event_in_rec.P_funding_rate_date =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE))
            THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_FUND_DATE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
	     End If;
           /*End of change for bug  3053190  */
	  --Log Message
	  IF l_debug_mode = 'Y' THEN
	  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
			     ,x_msg         => 'Validating project rate type.'
			     ,x_log_level   => 5);
	  END IF;
        /*We validate the PC attributes only when PC<>PFC  for Bug 3045302*/
        IF (P_project_currency_code  <> P_proj_func_currency_code )
        THEN
        If(p_event_in_rec.P_project_rate_date Is NULL
            or p_event_in_rec.P_project_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
	Then
		l_project_rate_date := p_project_bil_rate_date;
	Else
		l_project_rate_date := p_event_in_rec.P_project_rate_date;
	End If;

        If (p_event_in_rec.P_project_rate_type Is NOT NULL
            AND p_event_in_rec.P_project_rate_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
	Then
	   If PA_EVENT_UTILS.check_valid_proj_rate_type
		(
            P_proj_rate_type		=>p_event_in_rec.P_project_rate_type
	   ,P_bill_trans_currency_code	=>l_proj_func_currency_code
	   ,P_project_currency_code	=>P_project_currency_code
	   ,P_proj_level_rt_dt_code	=>P_project_bil_rate_date_code
	   ,P_project_rate_date		=>l_project_rate_date -- Modified
          --Commented for bug 3013137 and 3009307 ,P_event_date	=>SYSDATE) ='N'
	  ,P_event_date			=>NVL(P_event_in_rec.p_completion_date,SYSDATE)
	  ,x_proj_rate_type		=>l_project_rate_type
               ) ='N'
	    Then
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			pa_interface_utils_pub.map_new_amg_msg
				( p_old_message_code => 'PA_PROJ_RATE_TYPE_INV'
				,p_msg_attribute    => 'CHANGE'
				,p_resize_flag      => 'N'
				,p_msg_context      => 'EVENT'
				,p_attribute1       => P_event_in_rec.p_pm_event_reference
				,p_attribute2       => ''
				,p_attribute3       => ''
				,p_attribute4       => ''
				,p_attribute5       => '');
		 END IF;
		 l_return_status:='N';
	     End If;
        Else l_project_rate_type := P_project_rate_type; -- Added for bug 3013137 and 3009307
	End If;

	--If bill transaction currency is not same as the project currency
	--and if the project exchange rate type is USER, project exchange
	--rate details are defaulted from project details in PUBLIC package.
	--If at event level project rate type(User) is different from rate type
	--at project level then validating project exchange rate .
	--Setting error message in case of rate is not a valid positive number.
      --For bug 3045302
      --  If exchange rate has been passed by the AMG is 0 or -ve then
      --  irrespective of the Rate Type we should raise an error.

        If ((l_proj_func_currency_code <> P_project_currency_code
		AND UPPER(p_event_in_rec.P_project_rate_type) = 'USER'
		AND p_event_in_rec.P_project_rate_type <> P_project_rate_type
		AND ( p_event_in_rec.P_project_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
			OR p_event_in_rec.P_project_exchange_rate Is NULL))
			OR p_event_in_rec.P_project_exchange_rate <= 0)
	Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_PROJ_EXCG_RATE_INV'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
        End If;

         /*  Added   for  bug  3053190   */
            If ( P_project_bil_rate_date_code ='FIXED_DATE'
                 AND UPPER(P_project_rate_type) ='USER'
                 AND NVL(UPPER(P_event_in_rec.P_project_rate_type),'USER') <>'USER'
                 AND (P_event_in_rec.P_project_rate_date IS NULL
                      OR P_event_in_rec.P_project_rate_date =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE))
            THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_PROJ_DATE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
	     End If;
           /*End of change for bug  3053190  */
     END IF;/*P_project_currency_code  <> P_proj_func_currency_code */
	  --Log Message
	  IF l_debug_mode = 'Y' THEN
	  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
			     ,x_msg         => 'Validating project functional rate type.'
			     ,x_log_level   => 5);
	  END IF;

        If (P_event_in_rec.P_projfunc_rate_date Is NULL
            OR P_event_in_rec.P_projfunc_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
        Then
		l_projfunc_rate_date:=p_projfunc_bil_rate_date;
	Else
		l_projfunc_rate_date :=P_event_in_rec.P_projfunc_rate_date;
	End If;

        If (p_event_in_rec.P_projfunc_rate_type Is NOT NULL
            AND p_event_in_rec.P_projfunc_rate_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        Then
	    If PA_EVENT_UTILS.check_valid_pfc_rate_type
		(P_pfc_rate_type			=>P_event_in_rec.P_projfunc_rate_type
		,P_bill_trans_currency_code		=>l_proj_func_currency_code
		,P_proj_func_currency_code		=>P_proj_func_currency_code
		,P_proj_level_func_rt_dt_code		=>P_projfunc_bil_rate_date_code
		,P_projfunc_rate_date			=>l_projfunc_rate_date
	-- Commented for bug 3013137 and 3009307	,P_event_date		=>SYSDATE
		,P_event_date			=>NVL(P_event_in_rec.p_completion_date,SYSDATE)
		,x_pfc_rate_type		=>l_projfunc_rate_type
                )
		='N'
	    Then
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			pa_interface_utils_pub.map_new_amg_msg
				( p_old_message_code =>'PA_PFC_RATE_TYPE_INV'
				,p_msg_attribute    => 'CHANGE'
				,p_resize_flag      => 'N'
				,p_msg_context      => 'EVENT'
				,p_attribute1       => P_event_in_rec.p_pm_event_reference
				,p_attribute2       => ''
				,p_attribute3       => ''
				,p_attribute4       => ''
				,p_attribute5       => '');
		 END IF;
		 l_return_status:='N';
 	    End If;
        Else l_projfunc_rate_type :=  P_projfunc_rate_type; -- Added for bug 3013137 and 3009307
  	End If;

	--If bill transaction currency is not same as the projfunc currency
	--and if the projfunc exchange rate type is USER, projfunc exchange
	--rate details are defaulted from project details in PUBLIC package.
	--If at event level projfunc rate type(User) is different from rate type
	--at project level then validating projfunc exchange rate .
	--Setting error message in case of rate is not a valid positive number.
      --For bug 3045302
      --  If exchange rate has been passed by the AMG is 0 or -ve then
      --  irrespective of the Rate Type we should raise an error.

        If ((P_proj_func_currency_code <> l_proj_func_currency_code
		AND UPPER(p_event_in_rec.P_projfunc_rate_type) = 'USER'
		AND p_event_in_rec.P_projfunc_rate_type <> P_projfunc_rate_type
		AND (p_event_in_rec.P_projfunc_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
			OR p_event_in_rec.P_projfunc_exchange_rate Is NULL ))
			OR p_event_in_rec.P_projfunc_exchange_rate <= 0)
        Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_PFC_EXCG_RATE_INV'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
        End If;

      /*  Added   for  bug  3053190   */
            If ( p_projfunc_bil_rate_date_code ='FIXED_DATE'
                 AND UPPER(P_projfunc_rate_type) ='USER'
                 AND NVL(UPPER(P_event_in_rec.P_projfunc_rate_type),'USER') <>'USER'
                 AND (P_event_in_rec.P_projfunc_rate_date IS NULL
                      OR P_event_in_rec.P_projfunc_rate_date =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE))
            THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_PROJFUNC_DATE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
	     End If;
           /*End of change for bug  3053190  */
   Else	--if mcb is not enabled
          If (p_event_in_rec.P_bill_trans_currency_code Is NULL)
            Then
                l_proj_func_currency_code:=P_proj_func_currency_code;

          ElsIf (p_event_in_rec.P_bill_trans_currency_code <> P_proj_func_currency_code)
            Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                            --     (p_old_message_code => 'PA_INVALID_BIL_TRX_CUR' -- Commented for Bug#3013172
                                (p_old_message_code => 'PA_EVENT_NON_MCB_OPTION' -- Modified the message code for Bug#3013172
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
                 l_proj_func_currency_code:=P_proj_func_currency_code;
            Else
                 l_proj_func_currency_code:=p_event_in_rec.P_bill_trans_currency_code;
          End If;
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating the Adjusting Revenue flag.'
                     ,x_log_level   => 5);
  END IF;

--validating the Adjusting Revenue flag
  If(p_event_in_rec.P_adjusting_revenue_flag Is NOT NULL
     AND p_event_in_rec.P_adjusting_revenue_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     AND PA_EVENT_PVT.CHECK_YES_NO
        (P_flag         =>P_event_in_rec.P_adjusting_revenue_flag)='N')
  Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code =>'PA_INVALID_ADJ_REV_FLG'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                END IF;
                l_return_status:='N';
  ElsIf (P_event_in_rec.P_adjusting_revenue_flag in ('Y','y'))
  Then
	If (p_event_type_classification Is NULL
		OR p_event_type_classification <> 'MANUAL')
	Then
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code =>'PA_INV_EV_TYP_ADJ_REV'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                END IF;
                l_return_status:='N';
	End If;
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating the revenue amount.'
                     ,x_log_level   => 5);
  END IF;

  --validating the revenue amount
  --For revenue events like Write-on And Write-off events,
  --revenue amount is mandatory and a +ve value.
  If (p_event_type_classification In('WRITE ON','WRITE OFF'))
     Then
        If PA_EVENT_UTILS.CHECK_VALID_REV_AMT
                (P_event_type_classification    =>P_event_type_classification
                ,P_rev_amt                      =>p_event_in_rec.P_bill_trans_rev_amount)='N'
        Then
		   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
			pa_interface_utils_pub.map_new_amg_msg
				( p_old_message_code => 'PA_PR_EPR_REV_GT_ZERO'
				,p_msg_attribute    => 'CHANGE'
				,p_resize_flag      => 'N'
				,p_msg_context      => 'EVENT'
				,p_attribute1       => p_event_in_rec.p_pm_event_reference
				,p_attribute2       => ''
				,p_attribute3       => ''
				,p_attribute4       => ''
				,p_attribute5       => '');
		   END IF;
		   l_return_status:='N';
        --call to check revenue amount for write-off events .The check should be done only if the p_completion_date
        -- is not NULL.
        /*For bug 3053669  */
	ElsIf (p_event_type_classification = 'WRITE OFF'AND P_event_in_rec.p_completion_date is not NULL
                      AND P_event_in_rec.p_completion_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE )
	Then

	l_ret_status:=PA_EVENT_UTILS.check_write_off_amt
			(P_project_id          =>P_project_id
			,P_task_id             =>x_task_id
			,P_event_id            =>p_event_in_rec.P_event_id
			,P_rev_amt             =>p_event_in_rec.P_bill_trans_rev_amount
			,P_bill_trans_currency =>l_proj_func_currency_code
			,P_proj_func_currency  =>P_proj_func_currency_code
	/* Commented for bug 3013137 and 3009307 ,P_proj_func_rate_type =>p_event_in_rec.P_project_rate_type
			,P_proj_func_rate      =>p_event_in_rec.P_project_exchange_rate,
			,P_proj_func_rate_date =>p_event_in_rec.P_project_rate_date
			,P_event_date          =>sysdate); */
			,P_proj_func_rate_type =>l_projfunc_rate_type
			,P_proj_func_rate      =>NVL(p_event_in_rec.P_project_exchange_rate,
                                                     p_projfunc_bil_exchange_rate)
			,P_proj_func_rate_date =>l_projfunc_rate_date
			,P_event_date          =>P_event_in_rec.p_completion_date);
		If l_ret_status <> 'Y'
		Then
			If l_ret_status = 'N'
			Then
			   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			   THEN
				pa_interface_utils_pub.map_new_amg_msg
					( p_old_message_code =>'PA_TK_EXCESS_REV'
					,p_msg_attribute    => 'CHANGE'
					,p_resize_flag      => 'N'
					,p_msg_context      => 'EVENT'
					,p_attribute1       => p_event_in_rec.p_pm_event_reference
					,p_attribute2       => ''
					,p_attribute3       => ''
					,p_attribute4       => ''
					,p_attribute5       => '');
			   END IF;
			   l_return_status:='N';
			Else
                           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                           THEN
                                pa_interface_utils_pub.map_new_amg_msg
                                        ( p_old_message_code =>l_ret_status
                                        ,p_msg_attribute    => 'CHANGE'
                                        ,p_resize_flag      => 'N'
                                        ,p_msg_context      => 'EVENT'
                                        ,p_attribute1       => p_event_in_rec.p_pm_event_reference
                                        ,p_attribute2       => ''
                                        ,p_attribute3       => ''
                                        ,p_attribute4       => ''
                                        ,p_attribute5       => '');
                           END IF;
                           l_return_status:='N';
			End If;   /*If l_ret_status = 'N'*/
		End If;   /*If l_ret_status <> 'Y'*/
	End If;
  ElsIf (p_event_type_classification In('MANUAL','WRITE ON','WRITE OFF')
  	  AND (p_event_in_rec.P_bill_trans_rev_amount Is NULL
                 OR p_event_in_rec.P_bill_trans_rev_amount = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
    Then
                   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_INVALID_REV_AMT'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => p_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                   END IF;
                   l_return_status:='N';
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating  the bill amount.'
                     ,x_log_level   => 5);
  END IF;

  --validating the bill amount
  If PA_EVENT_UTILS.CHECK_VALID_BILL_AMT
	(P_event_type_classification    =>P_event_type_classification
	,P_bill_amt			=>p_event_in_rec.P_bill_trans_bill_amount)='N'
  Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_PR_EPR_BILL_GT_ZERO'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
  ElsIf (p_event_type_classification In('MANUAL','DEFERRED REVENUE','INVOICE REDUCTION','SCHEDULED PAYMENTS')
          AND (p_event_in_rec.P_bill_trans_bill_amount Is NULL
                 OR p_event_in_rec.P_bill_trans_bill_amount = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
    Then
                   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_INVALID_BILL_AMT'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => p_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                   END IF;
                   l_return_status:='N';
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating the Bill hold flag.'
                     ,x_log_level   => 5);
  END IF;


--validating the Bill hold flag
  If (p_event_in_rec.P_bill_hold_flag Is NOT NULL
        AND p_event_in_rec.P_bill_hold_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  Then
    If (upper(p_event_in_rec.P_bill_hold_flag) NOT In('Y','N','O'))
    Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_BIL_HLD_FLG'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
    End If;
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating event number.'
                     ,x_log_level   => 5);
  END IF;

  --validating the event number
  If (p_event_in_rec.P_event_number Is NOT NULL
	AND p_event_in_rec.P_event_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  	AND PA_EVENT_UTILS.CHECK_VALID_EVENT_NUM
		(P_project_id	=>P_project_id
		,P_task_id	=>x_task_id
		,P_event_num	=>p_event_in_rec.P_event_number)='N')
  Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INV_EVNT_NUM'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating inventory organization name and deriving inventory organization id.'
                     ,x_log_level   => 5);
  END IF;


  --validating the inventory organization name should be valid and active
  If (p_event_in_rec.P_inventory_org_name Is NOT NULL
	AND p_event_in_rec.P_inventory_org_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
	AND PA_EVENT_UTILS.CHECK_VALID_INV_ORG
                (P_inv_org_name         =>p_event_in_rec.P_inventory_org_name
		,P_inv_org_id		=>x_inv_org_id)='N')
  Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INV_INVT_ORG_NAME'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating inventory item id.'
                     ,x_log_level   => 5);
  END IF;

  --validating the inventory item_id
  If (p_event_in_rec.P_inventory_item_id Is NOT NULL
        AND p_event_in_rec.P_inventory_item_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        AND PA_EVENT_UTILS.CHECK_VALID_INV_ITEM
                (P_inv_item_id          =>p_event_in_rec.P_inventory_item_id)='N')
  Then
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
		pa_interface_utils_pub.map_new_amg_msg
			( p_old_message_code => 'PA_INV_INVT_ITEM'
			,p_msg_attribute    => 'CHANGE'
			,p_resize_flag      => 'N'
			,p_msg_context      => 'EVENT'
			,p_attribute1       => P_event_in_rec.p_pm_event_reference
			,p_attribute2       => ''
			,p_attribute3       => ''
			,p_attribute4       => ''
			,p_attribute5       => '');
	 END IF;
	 l_return_status:='N';
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_EVENT_OK.begin'
                     ,x_msg         => 'End of Check Create Event Ok'
                     ,x_log_level   => 5);
  END IF;

RETURN(l_return_status);

        --handling exceptions
        Exception
        When pa_event_utils.pvt_excp
                then
               x_task_id  := NULL; -- NOCOPY
               x_organization_id := NULL; --NOCOPY
               x_inv_org_id := NULL; --NOCOPY
               P_event_type_classification := NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_CREATE_EVENT_OK->';
                Raise pub_excp;--raising exception to be handled in public package

        When others
                then
               x_task_id  := NULL;  --NOCOPY
               x_organization_id := NULL; --NOCOPY
               x_inv_org_id := NULL; --NOCOPY
               P_event_type_classification := NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_CREATE_EVENT_OK->';
                Raise pub_excp;--raising exception to be handled in public package

END CHECK_CREATE_EVENT_OK;

-- ============================================================================
--
--Name:         CHECK_UPDATE_EVENT_OK
--Type:         function
--Description:  This function validates if the event is updateable.
--
--Called subprograms:
--                      PA_EVENT_UTILS.CHECK_VALID_TASK
--                      PA_EVENT_UTILS.CHECK_VALID_EVENT_TYPE
--                      PA_EVENT_UTILS.CHECK_VALID_EVENT_ORG
--                      PA_EVENT_UTILS.CHECK_VALID_REV_AMT
--                      PA_EVENT_UTILS.CHECK_VALID_BILL_AMT
--                      PA_EVENT_UTILS.CHECK_VALID_EVENT_NUM
--                      PA_EVENT_UTILS.CHECK_VALID_INV_ORG
--                      PA_EVENT_UTILS.CHECK_VALID_INV_ITEM
--                      PA_EVENT_UTILS.CHECK_VALID_CURR
--                      PA_EVENT_UTILS.CHECK_VALID_FUND_RATE_TYPE
--                      PA_EVENT_UTILS.CHECK_VALID_PROJ_RATE_TYPE
--                      PA_EVENT_UTILS.CHECK_VALID_PFC_RATE_TYPE
--			PA_EVENT_UTILS.CHECK_VALID_AGREEMENT
-- 			PA_EVENT_UTILS.CHECK_VALID_EVENT_DATE
-- ============================================================================
FUNCTION CHECK_UPDATE_EVENT_OK
(P_pm_product_code      		IN      VARCHAR2
,P_event_in_rec         		IN      pa_event_pub.Event_rec_in_type
,P_project_currency_code                IN      VARCHAR2
,P_proj_func_currency_code              IN      VARCHAR2
,P_project_bil_rate_date_code           IN      VARCHAR2
,P_project_rate_type                    IN      VARCHAR2
,p_project_bil_rate_date                IN      VARCHAR2
,p_projfunc_bil_rate_date_code          IN      VARCHAR2
,P_projfunc_rate_type                   IN      VARCHAR2
,p_projfunc_bil_rate_date               IN      VARCHAR2
,P_funding_rate_type                    IN      VARCHAR2
,P_multi_currency_billing_flag          IN      VARCHAR2
,p_project_id                           IN      NUMBER
,p_projfunc_bil_exchange_rate           IN      NUMBER -- Added bug 3013137
,p_funding_bill_rate_date_code          IN      VARCHAR2 --Added for bug 3053190
,x_task_id                              OUT     NOCOPY NUMBER  --File.Sql.39 bug 4440895
,x_organization_id                      OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_inv_org_id                           OUT     NOCOPY NUMBER  --File.Sql.39 bug 4440895
,x_agreement_id                         OUT     NOCOPY NUMBER  -- Federal Uptake
,p_event_type_classification            OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,P_event_processed                      OUT     NOCOPY VARCHAR2)  /* Added for bug 7110782 */
RETURN VARCHAR2
AS

l_proj_func_currency_code       PA_EVENTS.projfunc_currency_code%TYPE;
l_bill_trans_currency_code      PA_EVENTS.bill_trans_currency_code%TYPE; -- Added bug 3013137
l_projfunc_rate_date		PA_PROJECTS_ALL.projfunc_bil_rate_date%TYPE;
l_project_rate_date		PA_PROJECTS_ALL.project_bil_rate_date%TYPE;
l_funding_rate_type             PA_EVENTS.funding_rate_type%TYPE;
l_return_status         	VARCHAR2(1):='Y';
l_debug_mode                    VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
l_ret_status                    VARCHAR2(2000):=NULL;

l_project_rate_type             PA_EVENTS.project_rate_type%TYPE; -- Added bug 3013137 and 3009307
l_projfunc_rate_type            PA_EVENTS.projfunc_rate_type%TYPE; --  Added bug 3013137 and 3009307
l_completion_date               PA_EVENTS.completion_date%TYPE; --Added for bug 3053669
l_revenue_amount                PA_EVENTS.bill_trans_rev_amount%TYPE;  --Added for bug 3053669;Chgd the type for 4027500
l_adjusting_revenue_flag        PA_EVENTS.adjusting_revenue_flag%TYPE;  --Added for bug 3053669
l_bill_amount                   PA_EVENTS.bill_trans_bill_amount%TYPE;  --Added for bug 3053669
/*The following variable are added for bug 3053190.The varables are to used only for the validation
  of dates and should not be used for any other puprpose.  */
l_check_projfunc_rate_date      PA_EVENTS.PROJFUNC_RATE_DATE %TYPE;
l_check_project_rate_date       PA_EVENTS.PROJECT_RATE_DATE % TYPE;
l_check_funding_rate_date       PA_EVENTS.FUNDING_RATE_DATE % TYPE;
l_event_processed               VARCHAR2(1);
--For Bug 3619483 :Added following 2 variables
l_old_rev_amount		PA_EVENTS.bill_trans_rev_amount%TYPE;
l_old_bill_amount		PA_EVENTS.bill_trans_bill_amount%TYPE;
l_event_date	        	PA_EVENTS.completion_date%TYPE;

BEGIN

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
                     ,x_msg         => 'Beginning of Check Update Event Ok'
                     ,x_log_level   => 5);
  END IF;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating if the event is processed.'
                     ,x_log_level   => 5);
  END IF;
 /*We are getting the processed status of the event and store it in the variable l_event_processed for future
   processing for bug 3205120 */

   P_event_processed := 'N';   /* Added for bug 7110782 */
   l_event_processed :=PA_EVENT_UTILS.CHECK_EVENT_PROCESSED
                   (P_event_id             =>P_event_in_rec.P_event_id);
  --Check if the event is processed.If processed then it cannot be updated.
   --The folowing code is added to supoort events created in Deliverables in amg .
   If  l_event_processed = 'Y' AND nvl(p_event_in_rec.p_context,'Z') <> 'D'
   Then
        DECLARE

           l_deliverable_id NUMBER ;

        BEGIN

               SELECT deliverable_id
                 INTO l_deliverable_id
                 FROM PA_EVENTS
                WHERE EVENT_ID=P_event_in_rec.P_event_id
                  AND deliverable_id IS NULL;

         EXCEPTION

         WHEN NO_DATA_FOUND THEN

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_EVENT_IN_DELV_UPD'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
                 Return(l_return_status);
          END;
  ElsIf  l_event_processed = 'N'
  Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_TK_EVENT_IN_USE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
         Return(l_return_status);  --If event is processed then terminating further validation

  /* Code added for bug 7110782 - starts */

  /* Retunr I if event is only invoiced */
  ELSIF  l_event_processed = 'I' THEN
         P_event_processed := 'I';

  /* Retunr R if event is only revenue distributed */
  ELSIF  l_event_processed = 'R' THEN
         P_event_processed := 'R';

  /* Code added for bug 7110782 - ends */

  /*The following code is added for bug 3205120 */
  ELSIF  l_event_processed = 'P'
  THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_EVENT_PARTIAL_BILL'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
         Return(l_return_status);

  ELSIF l_event_processed = 'C'
   THEN
/*The invoice for this project has been cancelled .None of the fields other than Description,Organization,Bill Hold flag and date
  can be updated .However the DFF will be updateable. */
    if (
        P_event_in_rec.P_Task_Number                  IS NOT NULL OR
	P_event_in_rec.p_event_number		      IS NOT NULL OR
	P_event_in_rec.P_event_type                   IS NOT NULL OR
	P_event_in_rec.P_project_number	              IS NOT NULL OR
        P_event_in_rec.P_agreement_number             IS NOT NULL OR
	P_event_in_rec.P_inventory_org_name	      IS NOT NULL OR
	P_event_in_rec.P_inventory_item_id	      IS NOT NULL OR
	P_event_in_rec.P_quantity_billed	      IS NOT NULL OR
	P_event_in_rec.P_uom_code		      IS NOT NULL OR
	P_event_in_rec.P_unit_price		      IS NOT NULL OR
	P_event_in_rec.P_reference1		      IS NOT NULL OR
	P_event_in_rec.P_reference2		      IS NOT NULL OR
	P_event_in_rec.P_reference3		      IS NOT NULL OR
	P_event_in_rec.P_reference4		      IS NOT NULL OR
	P_event_in_rec.P_reference5		      IS NOT NULL OR
	P_event_in_rec.P_reference6		      IS NOT NULL OR
	P_event_in_rec.P_reference7		      IS NOT NULL OR
	P_event_in_rec.P_reference8		      IS NOT NULL OR
	P_event_in_rec.P_reference9		      IS NOT NULL OR
	P_event_in_rec.P_reference10		      IS NOT NULL OR
	P_event_in_rec.P_bill_trans_currency_code     IS NOT NULL OR
/*	P_event_in_rec.P_bill_trans_bill_amount       IS NOT NULL OR commented for bug 8485535*/
	(P_event_in_rec.P_bill_trans_rev_amount        IS NOT NULL and l_event_processed='C') OR /* Modified for bug 8485535*/
	P_event_in_rec.P_project_rate_type	      IS NOT NULL OR
	P_event_in_rec.P_project_rate_date	      IS NOT NULL OR
	P_event_in_rec.P_project_exchange_rate        IS NOT NULL OR
	P_event_in_rec.P_projfunc_rate_type	      IS NOT NULL OR
	P_event_in_rec.P_projfunc_rate_date	      IS NOT NULL OR
	P_event_in_rec.P_projfunc_exchange_rate       IS NOT NULL OR
	P_event_in_rec.P_funding_rate_type	      IS NOT NULL OR
	P_event_in_rec.P_funding_rate_date	      IS NOT NULL OR
	P_event_in_rec.P_funding_exchange_rate        IS NOT NULL OR
	P_event_in_rec.P_adjusting_revenue_flag       IS NOT NULL ) THEN

		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_EVENT_CANCEL_UPD'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
                 Return(l_return_status);
       END IF;

 /*End of chsnge for bug 3205120 */
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating task for the given project'
                     ,x_log_level   => 5);
  END IF;

  --validating the task
  If (P_event_in_rec.P_task_number Is NOT NULL
      AND P_event_in_rec.P_task_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  Then
      If PA_EVENT_UTILS.CHECK_VALID_TASK
        (P_project_id   =>P_project_id
        ,P_task_id      =>x_task_id
        ,P_task_num     =>P_event_in_rec.P_task_number)='N'
      Then
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			pa_interface_utils_pub.map_new_amg_msg
				( p_old_message_code => 'PA_INVALID_TOP_TASK'
				,p_msg_attribute    => 'CHANGE'
				,p_resize_flag      => 'N'
				,p_msg_context      => 'EVENT'
				,p_attribute1       => P_event_in_rec.p_pm_event_reference
				,p_attribute2       => ''
				,p_attribute3       => ''
				,p_attribute4       => ''
				,p_attribute5       => '');
		 END IF;
		 l_return_status:='N';
	       --If task_id is invalid then terminating further validation
		 Return(l_return_status);
	End If;
  Else
	/*  x_task_id:=NULL;  */
        select task_id
          into x_task_id
          from pa_events
         where event_id = P_event_in_rec.P_event_id;
  End If;
	  --Log Message
	  IF l_debug_mode = 'Y' THEN
	  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
			     ,x_msg         => 'Validating funding level of the project'
			     ,x_log_level   => 5);
	  END IF;

    --validating the funding level of the project.
      If PA_EVENT_UTILS.CHECK_FUNDING
        (P_project_id   =>P_project_id
        ,P_task_id      =>x_task_id)='N'
      Then
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			pa_interface_utils_pub.map_new_amg_msg
				( p_old_message_code => 'PA_TASK_FUND_NO_PROJ_EVENT'
				,p_msg_attribute    => 'CHANGE'
				,p_resize_flag      => 'N'
				,p_msg_context      => 'EVENT'
				,p_attribute1       => P_event_in_rec.p_pm_event_reference
				,p_attribute2       => ''
				,p_attribute3       => ''
				,p_attribute4       => ''
				,p_attribute5       => '');
		 END IF;
		 l_return_status:='N';
		 --If task_id is invalid then terminating further validation
		 Return(l_return_status);
      End If;

 -- log Message  -- Start Federal Uptake
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating agreement for the given project'
                     ,x_log_level   => 5);
  END IF;

--validating the agreement

   If (P_event_in_rec.P_agreement_number Is NULL  AND
       P_event_in_rec.P_agreement_type   IS NULL  AND
       P_event_in_rec.P_customer_number  IS NULL )
   Then
       select agreement_id
         into x_agreement_id
         from pa_events
        where event_id = P_event_in_rec.P_event_id;
   else
      if
          (P_event_in_rec.P_agreement_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (P_event_in_rec.P_agreement_type   = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (P_event_in_rec.P_customer_number  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
      Then
          x_agreement_id := NULL;
      else
          if PA_EVENT_UTILS.CHECK_VALID_AGREEMENT (
                         P_project_id          =>  P_project_id
                        ,P_task_id             =>  x_task_id
                        ,P_agreement_number    =>  P_event_in_rec.P_agreement_number
                        ,P_agreement_type      =>  P_event_in_rec.P_agreement_type
                        ,P_customer_number     =>  P_event_in_rec.P_customer_number
                        ,P_agreement_id        =>  x_agreement_id ) ='N'
          Then
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_AGMT_NUM'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
             END IF;
             l_return_status:='N';
             Return(l_return_status);  --If agreement_id is invalid then terminate further validation
          End If;
      End IF;
   END IF;

 --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_CREATE_UPDATE_OK.begin'
                     ,x_msg         => 'Validating event date is between agreement date'
                     ,x_log_level   => 5);
  END IF;

  --validating event date

 IF ( P_event_in_rec.P_completion_date is NULL )
 Then
    select completion_date
      into l_event_date
      from pa_events
     where event_id = P_event_in_rec.P_event_id;
  ELSE
    l_event_date      := P_event_in_rec.P_completion_date;
 END IF;

  IF  l_event_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  Then
    If PA_EVENT_UTILS.CHECK_VALID_EVENT_DATE (
                         P_event_date          =>  l_event_date
                        ,P_agreement_id        =>  x_agreement_id ) ='N'
    Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_EVENT_DATE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
         Return(l_return_status);  --If event date is not between agreement date
    End If;
   End IF;

-- End Federal Uptake

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating the event_type'
                     ,x_log_level   => 5);
  END IF;

  --validating the event_type
  If (P_event_in_rec.P_event_type Is NOT NULL
	AND P_event_in_rec.P_event_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  Then
     If PA_EVENT_UTILS.CHECK_VALID_EVENT_TYPE
        (P_event_type   		=>P_event_in_rec.P_event_type
	,P_context			=>P_event_in_rec.P_context
	,X_event_type_classification	=>p_event_type_classification)='N'
     Then
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			pa_interface_utils_pub.map_new_amg_msg
				(p_old_message_code => 'PA_INVALID_EVNT_TYPE'
				,p_msg_attribute    => 'CHANGE'
				,p_resize_flag      => 'N'
				,p_msg_context      => 'EVENT'
				,p_attribute1       => P_event_in_rec.p_pm_event_reference
				,p_attribute2       => ''
				,p_attribute3       => ''
				,p_attribute4       => ''
				,p_attribute5       => '');
		 END IF;
		 l_return_status:='N';
     End If;
  Else
		--Defaulting event_type_classification for other validations
		 SELECT  t.event_type_classification
		   INTO  p_event_type_classification
		   FROM  pa_event_types t,pa_events v
		  WHERE  v.event_id=P_event_in_rec.P_event_id
		    AND  t.event_type=v.event_type ;
  End If;
--For Bug 3619483
  IF ( (g_rev_evt_fun_allowed = 'N' )  AND
      (p_event_type_classification IN('WRITE ON','WRITE OFF')) ) THEN
	 pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_EV_NO_REV_MAINT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
       RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ( (g_inv_evt_fun_allowed = 'N' )  AND
      (p_event_type_classification IN('DEFERRED REVENUE','INVOICE REDUCTION','SCHEDULED PAYMENTS'))) THEN
       pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_EV_NO_INV_MAINT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
       RAISE FND_API.G_EXC_ERROR;
  END IF;

  SELECT  bill_trans_rev_amount,
  	  bill_trans_bill_amount
  INTO    l_old_rev_amount,
   	  l_old_bill_amount
  FROM pa_events
  WHERE event_id = p_event_in_rec.P_event_id;

   IF (p_event_type_classification = 'MANUAL')  THEN
     	IF (   (g_inv_evt_fun_allowed = 'Y' )  AND
  	       (g_rev_evt_fun_allowed = 'N' )  AND
  	       (l_old_rev_amount <> NVL(p_event_in_rec.p_bill_trans_rev_amount,0)) ) THEN
	 	pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_EV_NO_REV_MAINT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
		      pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_INVALID_REV_AMT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
       		      RAISE FND_API.G_EXC_ERROR;

    	ELSIF ( (g_inv_evt_fun_allowed = 'N' )  AND
  		(g_rev_evt_fun_allowed = 'Y' )  AND
  		(l_old_bill_amount <> NVL(p_event_in_rec.p_bill_trans_bill_amount,0))) THEN
       		 pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_EV_NO_INV_MAINT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
		     pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_BILL_AMT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
       		     RAISE FND_API.G_EXC_ERROR;
    	END IF;

   END IF;
 --End of Bug fix 3619483
  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating organisation name and deriving organisation_id'
                     ,x_log_level   => 5);
  END IF;

  --calls PA_EVENT_UTILS.CHECK_VALID_EVENT_ORG to validate and
  --derive the organisation_id from organisation name
  If (p_event_in_rec.P_organization_name Is NOT NULL
	AND p_event_in_rec.P_organization_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        AND PA_EVENT_UTILS.CHECK_VALID_EVENT_ORG
                (P_event_org_name       =>p_event_in_rec.P_organization_name
                ,P_event_org_id         =>x_Organization_Id)='N')
  Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_EVNT_ORG'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
  End If;

  /* For bug 3053190.Moved the following select from below and added the columns
  PROJECT_RATE_DATE,PROJFUNC_RATE_DATE,FUNDING_RATE_DATE to the select */

  /*Added for bug 3053669 The validation should happen if the revenue amount passed is not null
  OR the revenue amount present in the database is not NULL .Selecting the completion date of the
  event for validation of Write Off events */

        SELECT  decode(p_event_in_rec.P_bill_trans_rev_amount,NULL,bill_trans_rev_amount,
                       p_event_in_rec.P_bill_trans_rev_amount),
                decode(p_event_in_rec.P_bill_trans_bill_amount,NULL,bill_trans_bill_amount,
                       p_event_in_rec.P_bill_trans_bill_amount),
                decode(p_event_in_rec.p_completion_date,NULL,ev.completion_date,P_event_in_rec.p_completion_date),
                decode(p_event_in_rec.P_adjusting_revenue_flag,NULL,ev.adjusting_revenue_flag,
                       p_event_in_rec.P_adjusting_revenue_flag),
                decode(p_event_in_rec.P_projfunc_rate_date,NULL,ev.projfunc_rate_date,
                         PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,ev.projfunc_rate_date,
                           p_event_in_rec.P_projfunc_rate_date),
                decode(p_event_in_rec.P_project_rate_date,NULL,ev.project_rate_date,
                         PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,ev.project_rate_date,
                           p_event_in_rec.P_project_rate_date),
                decode(p_event_in_rec.P_funding_rate_date,NULL,ev.funding_rate_date,
                         PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,ev.funding_rate_date,
                           p_event_in_rec.P_funding_rate_date)
                  into l_revenue_amount,l_bill_amount,l_completion_date,l_adjusting_revenue_flag,
                       l_check_projfunc_rate_date,l_check_project_rate_date,l_check_funding_rate_date
                  from pa_events ev
                 where ev.event_id = p_event_in_rec.P_event_id;


  --validating the currency fields if mcb is enabled
  If (P_multi_currency_billing_flag ='Y')
  Then

	  --Log Message
	  IF l_debug_mode = 'Y' THEN
	  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
			     ,x_msg         => 'Start of MCB Validations '
			     ,x_log_level   => 5);
	  END IF;

	  --Log Message
	  IF l_debug_mode = 'Y' THEN
	  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
			     ,x_msg         => 'Validating bill trans currency code'
			     ,x_log_level   => 5);
	  END IF;


          --If bill trans currency code is null or '^' then the default value
          --is used for further validation.
          /*  If (p_event_in_rec.P_bill_trans_currency_code Is NULL)  4027500 */
          If (p_event_in_rec.P_bill_trans_currency_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
            Then
/*              l_proj_func_currency_code:=P_proj_func_currency_code;  commented for bug 3049100 */

             SELECT bill_trans_currency_code
               INTO l_proj_func_currency_code
               FROM pa_events
              WHERE event_id = P_event_in_rec.P_event_id;

          ElsIf PA_EVENT_UTILS.CHECK_VALID_CURR
                (P_bill_trans_curr      =>p_event_in_rec.P_bill_trans_currency_code)='N'
            Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                (p_old_message_code => 'PA_INVALID_BIL_TRX_CUR'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
                 l_proj_func_currency_code:=P_proj_func_currency_code;
            Else
                 l_proj_func_currency_code:=p_event_in_rec.P_bill_trans_currency_code;
          End If;

	  --Log Message
	  IF l_debug_mode = 'Y' THEN
	  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
			     ,x_msg         => 'Validating funding rate type'
			     ,x_log_level   => 5);
	  END IF;

        --If funding rate type is  null or '^' then the default value is used for
        --other validations.
          If (P_event_in_rec.P_funding_rate_type Is NOT NULL
                AND P_event_in_rec.P_funding_rate_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
          Then
            If PA_EVENT_UTILS.CHECK_VALID_FUND_RATE_TYPE
                (P_fund_rate_type       =>P_event_in_rec.P_funding_rate_type
                 ,x_fund_rate_type      =>l_funding_rate_type)='N'

            Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_FUND_RATE_TYPE_INV'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
             End If;

          -- When fuding rate type is 'User' at event level and not 'User' at the  project level
          -- and exchange rate is not a valid positive number then error is raised.
          --For bug 3045302
          --  If exchange rate has been passed by the AMG is 0 or -ve then
          --  irrespective of the Rate Type we should raise an error.
            If ((UPPER(P_event_in_rec.P_funding_rate_type) = 'USER'
                    AND p_event_in_rec.P_funding_rate_type <> P_funding_rate_type
                    AND ( p_event_in_rec.P_funding_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                          OR p_event_in_rec.P_funding_exchange_rate Is NULL ))
			  OR p_event_in_rec.P_funding_exchange_rate <=0 )
             Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_FUND_EXCG_RATE_INV'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
             End If;
           Else l_funding_rate_type :=  P_funding_rate_type; -- Added bug 3013137 and 3009307
          End If;
         /*  Added   for  bug  3053190   */
            If ( p_funding_bill_rate_date_code ='FIXED_DATE'
                 AND UPPER(P_funding_rate_type) ='USER'
                 AND NVL(UPPER(P_event_in_rec.P_funding_rate_type),'USER') <>'USER'
                 AND l_check_funding_rate_date IS NULL )
            THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_FUND_DATE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
	     End If;
           /*End of change for bug  3053190  */
	  --Log Message
	  IF l_debug_mode = 'Y' THEN
	  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
			     ,x_msg         => 'Validating project rate type.'
			     ,x_log_level   => 5);
	  END IF;
   /*The Project Currency Attributes should not be validated when PC=PFC.
     This is because we will be using the PFC attributes and not the PC attributes
     for bug 3045302*/

     IF (P_project_currency_code  <> P_proj_func_currency_code  )
     THEN
        If(p_event_in_rec.P_project_rate_date Is NULL
            or p_event_in_rec.P_project_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
	Then
		l_project_rate_date := p_project_bil_rate_date;
	Else
		l_project_rate_date := p_event_in_rec.P_project_rate_date;
	End If;

        If (p_event_in_rec.P_project_rate_type Is NOT NULL
            AND p_event_in_rec.P_project_rate_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        Then
           If PA_EVENT_UTILS.check_valid_proj_rate_type
                (P_proj_rate_type               =>p_event_in_rec.P_project_rate_type
                ,P_bill_trans_currency_code     =>l_proj_func_currency_code
                ,P_project_currency_code        =>P_project_currency_code
                ,P_proj_level_rt_dt_code        =>P_project_bil_rate_date_code
                ,P_project_rate_date         =>l_project_rate_date -- Modified
               --Commented bug 3013137 and 3009307 ,P_event_date      =>SYSDATE) ='N'
               ,P_event_date                 =>NVL(P_event_in_rec.p_completion_date,SYSDATE)
               ,x_proj_rate_type             =>l_project_rate_type
               ) ='N'

            Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_PROJ_RATE_TYPE_INV'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
             End If;
           Else l_project_rate_type := P_project_rate_type; -- Added bug 3013137 and 3009307
        End If;

	--If bill transaction currency is not same as the project currency
	--and if the project exchange rate type is USER, project exchange
	--rate details are defaulted from project details in PUBLIC package.
	--If at event level project rate type(User) is different from rate type
	--at project level then validating project exchange rate .
	--Setting error message in case of rate is not a valid positive number.
      --For bug 3045302
      --  If exchange rate has been passed by the AMG is 0 or -ve then
      --  irrespective of the Rate Type we should raise an error.

        If (( l_proj_func_currency_code <> P_project_currency_code
                AND UPPER(p_event_in_rec.P_project_rate_type) = 'USER'
                AND p_event_in_rec.P_project_rate_type <> P_project_rate_type
                AND ( p_event_in_rec.P_project_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                        OR p_event_in_rec.P_project_exchange_rate Is NULL))
			OR p_event_in_rec.P_project_exchange_rate <= 0)
        Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_PROJ_EXCG_RATE_INV'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
        End If;

      /*  Added   for  bug  3053190   */
            If ( P_project_bil_rate_date_code ='FIXED_DATE'
                 AND UPPER(P_project_rate_type) ='USER'
                 AND NVL(UPPER(P_event_in_rec.P_project_rate_type),'USER') <>'USER'
                 AND l_check_project_rate_date IS NULL)
            THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_PROJ_DATE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
	     End If;
           /*End of change for bug  3053190  */

     END IF; /*End of P_project_currency_code  <> P_proj_func_currency_code  */

	  --Log Message
	  IF l_debug_mode = 'Y' THEN
	  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
			     ,x_msg         => 'Validating project functional rate type.'
			     ,x_log_level   => 5);
	  END IF;

        If (P_event_in_rec.P_projfunc_rate_date Is NULL
            OR P_event_in_rec.P_projfunc_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
        Then
		l_projfunc_rate_date:=p_projfunc_bil_rate_date;
	Else
		l_projfunc_rate_date :=P_event_in_rec.P_projfunc_rate_date;
	End If;

        If (p_event_in_rec.P_projfunc_rate_type Is NOT NULL
            AND p_event_in_rec.P_projfunc_rate_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        Then
            If PA_EVENT_UTILS.check_valid_pfc_rate_type
                (P_pfc_rate_type                        =>P_event_in_rec.P_projfunc_rate_type
                ,P_bill_trans_currency_code             =>l_proj_func_currency_code
                ,P_proj_func_currency_code              =>P_proj_func_currency_code -- Modified
                ,P_proj_level_func_rt_dt_code           =>P_projfunc_bil_rate_date_code
                ,P_projfunc_rate_date                   =>l_projfunc_rate_date
        -- Commented bug 3013137 and 3009307   ,P_event_date             =>SYSDATE
                ,P_event_date                   =>NVL(P_event_in_rec.p_completion_date,SYSDATE)
                ,x_pfc_rate_type                =>l_projfunc_rate_type
                )
                ='N'

            Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code =>'PA_PFC_RATE_TYPE_INV'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
            End If;
        Else l_projfunc_rate_type :=  P_projfunc_rate_type; -- Added bug 3013137 and 3009307
        End If;

	--If bill transaction currency is not same as the projfunc currency
	--and if the projfunc exchange rate type is USER, projfunc exchange
	--rate details are defaulted from project details in PUBLIC package.
	--If at event level projfunc rate type(User) is different from rate type
	--at project level then validating projfunc exchange rate .
	--Setting error message in case of rate is not a valid positive number.
      --For bug 3045302
      --  If exchange rate has been passed by the AMG is 0 or -ve then
      --  irrespective of the Rate Type we should raise an error.

        If ((P_proj_func_currency_code <> l_proj_func_currency_code
                AND UPPER(p_event_in_rec.P_projfunc_rate_type) = 'USER'
                AND p_event_in_rec.P_projfunc_rate_type <> P_projfunc_rate_type
                AND (p_event_in_rec.P_projfunc_exchange_rate = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                        OR p_event_in_rec.P_projfunc_exchange_rate Is NULL ))
			OR p_event_in_rec.P_projfunc_exchange_rate <= 0)
        Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_PFC_EXCG_RATE_INV'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
        End If;

         /*  Added   for  bug  3053190   */
            If ( p_projfunc_bil_rate_date_code  ='FIXED_DATE'
                 AND UPPER(P_projfunc_rate_type) ='USER'
                 AND NVL(UPPER(P_event_in_rec.P_projfunc_rate_type),'USER') <>'USER'
                 AND l_check_projfunc_rate_date IS NULL )
            THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_PROJFUNC_DATE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
	     End If;
           /*End of change for bug  3053190  */

	  --If mcb is not enabled then validating bill trans currency code
	  --is null then the default value is used for further validation.
   Else
	  If (p_event_in_rec.P_bill_trans_currency_code Is NULL)
            Then
                l_proj_func_currency_code:=P_proj_func_currency_code;

          ElsIf (p_event_in_rec.P_bill_trans_currency_code <> P_proj_func_currency_code)
            Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        pa_interface_utils_pub.map_new_amg_msg
                          --      (p_old_message_code => 'PA_INVALID_BIL_TRX_CUR' --Commented for Bug#3013172
                                (p_old_message_code => 'PA_EVENT_NON_MCB_OPTION'  --Modified for Bug#3013172
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                 END IF;
                 l_return_status:='N';
                 l_proj_func_currency_code:=P_proj_func_currency_code;
            Else
                 l_proj_func_currency_code:=p_event_in_rec.P_bill_trans_currency_code;
          End If;
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating the Adjusting Revenue flag.'
                     ,x_log_level   => 5);
  END IF;

--validating the Adjusting Revenue flag
/*Added for bug 3053669 The validation should happen if the revenue amount passed is not null
  OR the revenue amount present in the database is not NULL .Selecting the completion date of the
  event for validation of Write Off events */

/*        SELECT  decode(p_event_in_rec.P_bill_trans_rev_amount,NULL,bill_trans_rev_amount,
                       p_event_in_rec.P_bill_trans_rev_amount),
                decode(p_event_in_rec.P_bill_trans_bill_amount,NULL,bill_trans_bill_amount,
                       p_event_in_rec.P_bill_trans_bill_amount),
                decode(p_event_in_rec.p_completion_date,NULL,ev.completion_date,P_event_in_rec.p_completion_date),
                decode(p_event_in_rec.P_adjusting_revenue_flag,NULL,ev.adjusting_revenue_flag,
                       p_event_in_rec.P_adjusting_revenue_flag)
                  into l_revenue_amount,l_bill_amount,l_completion_date,l_adjusting_revenue_flag
                  from pa_events ev
                 where ev.event_id = p_event_in_rec.P_event_id;  */

  If(l_adjusting_revenue_flag Is NOT NULL
     AND l_adjusting_revenue_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     AND PA_EVENT_PVT.CHECK_YES_NO
        (P_flag         =>l_adjusting_revenue_flag)='N')
  Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code =>'PA_INVALID_ADJ_REV_FLG'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                END IF;
                l_return_status:='N';
  ElsIf (l_adjusting_revenue_flag in ('Y','y'))
  Then
        If (p_event_type_classification <> 'MANUAL')
        Then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code =>'PA_INV_EV_TYP_ADJ_REV'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                END IF;
                l_return_status:='N';
	End If;
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating the revenue amount.'
                     ,x_log_level   => 5);
  END IF;

  --validating the revenue amount
  --For revenue events like Write-on And Write-off events,
  --revenue amount is mandatory and a +ve value.

  If (l_revenue_amount Is NOT NULL
        AND l_revenue_amount <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  Then
     If (p_event_type_classification In('WRITE ON','WRITE OFF'))
     Then
	If PA_EVENT_UTILS.check_valid_rev_amt
                (P_event_type_classification    =>P_event_type_classification
                ,P_rev_amt                      =>l_revenue_amount)='N'
                Then
                   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_PR_EPR_REV_GT_ZERO'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => p_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                   END IF;
                   l_return_status:='N';
        --call to check revenue amount for write-on events .
        ElsIf (p_event_type_classification = 'WRITE OFF')
        Then
   /*   Added for bug 3053669  */
           IF (l_completion_date IS NOT NULL AND l_completion_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE )
           THEN
           l_ret_status:=PA_EVENT_UTILS.check_write_off_amt
                        (P_project_id          =>P_project_id
                        ,P_task_id             =>x_task_id
                        ,P_event_id            =>p_event_in_rec.P_event_id
                        ,P_rev_amt             =>l_revenue_amount
                        ,P_bill_trans_currency =>l_proj_func_currency_code
                        ,P_proj_func_currency  =>P_proj_func_currency_code
        /* Commented bug 3013137 and 3009307 ,P_proj_func_rate_type =>p_event_in_rec.P_project_rate_type
                        ,P_proj_func_rate      =>p_event_in_rec.P_project_exchange_rate,
                        ,P_proj_func_rate_date =>p_event_in_rec.P_project_rate_date
                        ,P_event_date          =>sysdate); */
                        ,P_proj_func_rate_type =>l_projfunc_rate_type
                        ,P_proj_func_rate      =>NVL(p_event_in_rec.P_project_exchange_rate,
                                                     p_projfunc_bil_exchange_rate)
                        ,P_proj_func_rate_date =>l_projfunc_rate_date
                        ,P_event_date          =>l_completion_date);
                If l_ret_status <> 'Y'
                Then
                        If l_ret_status = 'N'
                        Then
                           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                           THEN
                                pa_interface_utils_pub.map_new_amg_msg
                                        ( p_old_message_code =>'PA_TK_EXCESS_REV'
                                        ,p_msg_attribute    => 'CHANGE'
                                        ,p_resize_flag      => 'N'
                                        ,p_msg_context      => 'EVENT'
                                        ,p_attribute1       => p_event_in_rec.p_pm_event_reference
                                        ,p_attribute2       => ''
                                        ,p_attribute3       => ''
                                        ,p_attribute4       => ''
                                        ,p_attribute5       => '');
                           END IF;
                           l_return_status:='N';
                        Else
                           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                           THEN
                                pa_interface_utils_pub.map_new_amg_msg
                                        ( p_old_message_code =>l_ret_status
                                        ,p_msg_attribute    => 'CHANGE'
                                        ,p_resize_flag      => 'N'
                                        ,p_msg_context      => 'EVENT'
                                        ,p_attribute1       => p_event_in_rec.p_pm_event_reference
                                        ,p_attribute2       => ''
                                        ,p_attribute3       => ''
                                        ,p_attribute4       => ''
                                        ,p_attribute5       => '');
                           END IF;
                           l_return_status:='N';
                        End If;
                End If;
            End If;/* P_event_in_rec.p_completion_date IS NOT NULL  */
        End If;
    End If;
  ElsIf (p_event_type_classification In('MANUAL','WRITE ON','WRITE OFF')
          /*  AND  l_bill_amount= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) 4027500 */ AND l_revenue_amount is null )
    Then
                   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_INVALID_REV_AMT'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => p_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                   END IF;
                   l_return_status:='N';

  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating  the bill amount.'
                     ,x_log_level   => 5);
  END IF;

  --validating the bill amount. Changed the variable name for bug 3013226.
  If (l_bill_amount Is NOT NULL
        AND l_bill_amount <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  	AND PA_EVENT_UTILS.CHECK_VALID_BILL_AMT
	   (P_event_type_classification    =>P_event_type_classification
           ,P_bill_amt     		   =>l_bill_amount)='N')
  Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_PR_EPR_BILL_GT_ZERO'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
  ElsIf (p_event_type_classification In('MANUAL','DEFERRED REVENUE','INVOICE REDUCTION','SCHEDULED PAYMENTS')
          /*  AND l_bill_amount= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) 4027500  */ AND l_bill_amount is null )
    Then
                   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                        pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_INVALID_BILL_AMT'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'EVENT'
                                ,p_attribute1       => p_event_in_rec.p_pm_event_reference
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                   END IF;
                   l_return_status:='N';
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating the Bill hold flag.'
                     ,x_log_level   => 5);
  END IF;

--validating the Bill hold flag
  If (p_event_in_rec.P_bill_hold_flag Is NOT NULL
	AND p_event_in_rec.P_bill_hold_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
  Then
    If (upper(p_event_in_rec.P_bill_hold_flag) NOT In('Y','N','O'))
    Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_BIL_HLD_FLG'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
    End If;
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating event number.'
                     ,x_log_level   => 5);
  END IF;

  --validating the event number
  If ((p_event_in_rec.P_event_number Is NOT NULL
	AND p_event_in_rec.P_event_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
	AND PA_EVENT_UTILS.CHECK_VALID_EVENT_NUM
        (P_project_id   =>P_project_id
        ,P_task_id      =>x_task_id
        ,P_event_num    =>p_event_in_rec.P_event_number)='Y')
       OR p_event_in_rec.P_event_number <=0 )  -- Added the OR condition for bug 5697448
  Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INV_EVNT_NUM'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating inventory organization name and deriving inventory organization id.'
                     ,x_log_level   => 5);
  END IF;

  --validating the inventory organization name should be valid and active
  If (p_event_in_rec.P_inventory_org_name Is NOT NULL
        AND p_event_in_rec.P_inventory_org_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        AND PA_EVENT_UTILS.CHECK_VALID_INV_ORG
                (P_inv_org_name         =>p_event_in_rec.P_inventory_org_name
                ,P_inv_org_id           =>x_inv_org_id)='N')
  Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INV_INVT_ORG_NAME'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_return_status:='N';
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
                     ,x_msg         => 'Validating inventory item id.'
                     ,x_log_level   => 5);
  END IF;

  --validating the inventory item_id
  If (p_event_in_rec.P_inventory_item_id Is NOT NULL
        AND p_event_in_rec.P_inventory_item_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        AND PA_EVENT_UTILS.CHECK_VALID_INV_ITEM
                (P_inv_item_id          =>p_event_in_rec.P_inventory_item_id)='N')
  Then
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
		pa_interface_utils_pub.map_new_amg_msg
			( p_old_message_code => 'PA_INV_INVT_ITEM'
			,p_msg_attribute    => 'CHANGE'
			,p_resize_flag      => 'N'
			,p_msg_context      => 'EVENT'
			,p_attribute1       => P_event_in_rec.p_pm_event_reference
			,p_attribute2       => ''
			,p_attribute3       => ''
			,p_attribute4       => ''
			,p_attribute5       => '');
	 END IF;
	 l_return_status:='N';
  End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PVT.CHECK_UPDATE_EVENT_OK.begin'
                     ,x_msg         => 'End of Check Update Event Ok'
                     ,x_log_level   => 5);
  END IF;

RETURN(l_return_status);

        --handling exceptions
        Exception
       When pa_event_utils.pvt_excp
                then
                x_task_id                  := NULL; --NOCOPY
                x_organization_id          := NULL; --NOCOPY
                x_inv_org_id               := NULL; --NOCOPY
                P_event_type_classification:= NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_UPDATE_EVENT_OK->';
                Raise pub_excp;--raising exception to be handled in public package

        When others
                then
                x_task_id                  := NULL; --NOCOPY
                x_organization_id          := NULL; --NOCOPY
                x_inv_org_id               := NULL; --NOCOPY
                P_event_type_classification:= NULL; --NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_UPDATE_EVENT_OK->';
                Raise pub_excp;--raising exception to be handled in public package


END CHECK_UPDATE_EVENT_OK;

-- ============================================================================
--
--Name:               validate_flex_fields
--Type:               Procedure
--Description:  This procedure can be used to validate flexfields.
--
--Called subprograms:
--                      None
--
-- ============================================================================

PROCEDURE VALIDATE_FLEXFIELD
( P_desc_flex_name       IN      VARCHAR2
 ,P_attribute_category   IN      VARCHAR2
 ,P_attribute1           IN      VARCHAR2
 ,P_attribute2           IN      VARCHAR2
 ,P_attribute3           IN      VARCHAR2
 ,P_attribute4           IN      VARCHAR2
 ,P_attribute5           IN      VARCHAR2
 ,P_attribute6           IN      VARCHAR2
 ,P_attribute7           IN      VARCHAR2
 ,P_attribute8           IN      VARCHAR2
 ,P_attribute9           IN      VARCHAR2
 ,P_attribute10          IN      VARCHAR2
 ,P_return_msg           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,P_valid_status         OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS
l_dummy VARCHAR2(1);
l_r VARCHAR2(2000);
BEGIN

        -- DEFINE ID COLUMNS
        fnd_flex_descval.set_context_value(p_attribute_category);
        fnd_flex_descval.set_column_value('ATTRIBUTE1', p_attribute1);
        fnd_flex_descval.set_column_value('ATTRIBUTE2', p_attribute2);
        fnd_flex_descval.set_column_value('ATTRIBUTE3', p_attribute3);
        fnd_flex_descval.set_column_value('ATTRIBUTE4', p_attribute4);
        fnd_flex_descval.set_column_value('ATTRIBUTE5', p_attribute5);
        fnd_flex_descval.set_column_value('ATTRIBUTE6', p_attribute6);
        fnd_flex_descval.set_column_value('ATTRIBUTE7', p_attribute7);
        fnd_flex_descval.set_column_value('ATTRIBUTE8', p_attribute8);
        fnd_flex_descval.set_column_value('ATTRIBUTE9', p_attribute9);
        fnd_flex_descval.set_column_value('ATTRIBUTE10', p_attribute10);

        -- VALIDATE
        IF (fnd_flex_descval.validate_desccols( 'PA',p_desc_flex_name)) then
              p_RETURN_msg := 'VALID: ' || fnd_flex_descval.concatenated_ids;
              p_valid_status := 'Y';
        ELSE
              p_RETURN_msg := 'INVALID: ' || fnd_flex_descval.error_message;
              p_valid_status := 'N';
        END IF;

        --handling exceptions
        Exception
        When pa_event_utils.pvt_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'VALIDATE_FLEXFIELD->';
                Raise pub_excp;--raising exception to be handled in public package

        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'VALIDATE_FLEXFIELD->';
                Raise pub_excp;--raising exception to be handled in public package

END VALIDATE_FLEXFIELD;
-- ============================================================================
--
--Name:         CONV_EVENT_REF_TO_ID
--Type:         Procedure
--Description:  This procedure can be used to validate event_id if provide
--		OR
--		If event_id is not provided then validate the event reference
--		and convert the event reference to an event id.
--
--Called subprograms:
--                    PA_EVENT_PVT.FETCH_EVENT_ID
--
-- ============================================================================
FUNCTION CONV_EVENT_REF_TO_ID
(P_pm_product_code      IN      VARCHAR2
,P_pm_event_reference   IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,P_event_id             IN OUT  NOCOPY NUMBER) --File.Sql.39 bug 4440895
RETURN VARCHAR2
AS

Cursor check_event_id
Is
Select 'x'
From  pa_events
Where event_id=P_event_id;
  -- And pm_product_code =P_pm_product_code; /* Commented for bug 5056969 */

event_id_found                  VARCHAR2(1);
l_return_status			VARCHAR2(1) := 'Y';
l_event_id                      pa_events.event_id%type;

l_pm_event_reference varchar2(30) := p_pm_event_reference;
l1_event_id     pa_events.event_id%type := p_event_id;

BEGIN
--validating that either the event reference or the event id is passed.
          If   (   (   P_pm_event_reference IS NULL
                    OR P_pm_event_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
                AND (  P_event_id IS NULL
                     OR P_event_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                )

          Then
                       If FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        Then
                                pa_interface_utils_pub.map_new_amg_msg
                                        ( p_old_message_code => 'PA_INV_EVNT_ID_REF'
                                        ,p_msg_attribute    => 'CHANGE'
                                        ,p_resize_flag      => 'N'
                                        ,p_msg_context      => 'EVENT'
                                        ,p_attribute1       => p_pm_event_reference
                                        ,p_attribute2       => ''
                                        ,p_attribute3       => ''
                                        ,p_attribute4       => ''
                                        ,p_attribute5       => '');
                        End If;
                        l_return_status := 'N';
            End If;

  --validating event id when provided.
  If (P_event_id is not null)
    And (P_event_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  Then
	   Open check_event_id;
	   Fetch check_event_id into event_id_found;

		If check_event_id%NOTFOUND
		Then
			If FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			Then
				pa_interface_utils_pub.map_new_amg_msg
					( p_old_message_code => 'PA_INV_EVNT_ID'
					,p_msg_attribute    => 'CHANGE'
					,p_resize_flag      => 'N'
					,p_msg_context      => 'EVENT'
					,p_attribute1       => p_pm_event_reference
					,p_attribute2       => ''
					,p_attribute3       => ''
					,p_attribute4       => ''
					,p_attribute5       => '');
			End If;
			l_return_status := 'N';
		End If;
	   Close check_event_id;
  End If;

  --Validating event_reference.
  --Derive event_id from the event_reference number when not provided.

      If  (    P_pm_event_reference IS NOT  NULL
           AND P_pm_event_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)

      Then

	  l_event_id := PA_EVENT_PVT.FETCH_EVENT_ID
				(P_pm_product_code	=>P_pm_product_code
				,P_pm_event_reference	=>p_pm_event_reference);

	  --If event_id is null then return false.
	  If (l_event_id Is NULL)
	  Then
			If FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			Then
				pa_interface_utils_pub.map_new_amg_msg
					(p_old_message_code => 'PA_INVALID_EVENT_REF'
					,p_msg_attribute    => 'CHANGE'
					,p_resize_flag      => 'N'
					,p_msg_context      => 'EVENT'
					,p_attribute1       => p_pm_event_reference
					,p_attribute2       => ''
					,p_attribute3       => ''
				,p_attribute4       => ''
				,p_attribute5       => '');
		End If;
		l_return_status := 'N';
	  End If;

     End If; /*P_pm_event_reference */

  --Check if the event_id is same in both the above cases.

  If (P_event_id is not null)
    And (P_event_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    And P_pm_event_reference IS NOT  NULL
    And  P_pm_event_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  Then

	  If (l_event_id <> p_event_id )
	  Then
			If FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			Then
				pa_interface_utils_pub.map_new_amg_msg
					(p_old_message_code => 'PA_INV_EVENT_REF_ID'
					,p_msg_attribute    => 'CHANGE'
					,p_resize_flag      => 'N'
					,p_msg_context      => 'EVENT'
					,p_attribute1       => p_pm_event_reference
					,p_attribute2       => ''
					,p_attribute3       => ''
					,p_attribute4       => ''
					,p_attribute5       => '');
			End If;
			l_return_status := 'N';
	  End If;
  elsif (P_event_id IS NULL
                     OR P_event_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  Then
          p_event_id := l_event_id;
  End If;

--If the event reference is not given then derive then derive it from the id.

	If    (   P_pm_event_reference IS NULL
	       OR P_pm_event_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)

       Then

             BEGIN

                    SELECT pm_event_reference
                      INTO P_pm_event_reference
                      FROM PA_EVENTS
                     WHERE event_id=p_event_id;
             Exception

                 When others
                   then
                        NULL;

             END;

        End If;

Return(l_return_status);

        --handling exceptions
        Exception
        When pa_event_utils.pvt_excp
                then
                p_pm_event_reference  := l_pm_event_reference ; -- NOCOPY
                p_event_id := l1_event_id; -- NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CONV_EVENT_REF_TO_ID->';
                Raise pub_excp;--raising exception to be handled in public package

        When others
                then
                p_pm_event_reference  := l_pm_event_reference ; -- NOCOPY
                p_event_id := l1_event_id; -- NOCOPY
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CONV_EVENT_REF_TO_ID->';
                Raise pub_excp;--raising exception to be handled in public package


END CONV_EVENT_REF_TO_ID;
-- ============================================================================
--
--Name:               CHECK_DELETE_EVENT_OK
--Type:               procedure
--Description: This API checks if an existing event or a set of existing events
--             can be deleted or not.If the validation is successful then it
--	       it deletes these events.
--Called subprograms:
--
--
--
--History:

-- ============================================================================

FUNCTION CHECK_DELETE_EVENT_OK
(P_pm_event_reference	IN	VARCHAR2
,P_event_id		IN	NUMBER)
RETURN VARCHAR2
AS

P_event_id_out		NUMBER:=NULL;
P_return_status		VARCHAR2(1):='Y';
l_event_processed       VARCHAR2(1);
p_event_type_classification   VARCHAR2(30);  --For Bug 3619483
l_rev_amount 		NUMBER; --For Bug 3619483
l_bill_amount		NUMBER; --For Bug 3619483
BEGIN


  --Checking if the event is processed.
  --If the event is billed or revenue distributed then it cannot be deleted.
  -- Now the function can return more than two statuses and
 -- only if the return status='Y' we should continue with furthure processing
 -- For bug 3205120.We get the processed status of the event and store it in a local variable
  l_event_processed :=  PA_EVENT_UTILS.CHECK_EVENT_PROCESSED
                   (P_event_id             =>P_event_id);

    --The folowing code is added to supoort events created in Deliverables in amg .
   If  l_event_processed = 'Y'
   Then
        DECLARE

           l_deliverable_id NUMBER ;

        BEGIN

                SELECT deliverable_id
                  INTO l_deliverable_id
                  FROM PA_EVENTS
                 WHERE EVENT_ID=P_event_id
                   AND deliverable_id IS NULL;

         EXCEPTION

         WHEN NO_DATA_FOUND THEN

                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN
                         pa_interface_utils_pub.map_new_amg_msg
                                 ( p_old_message_code => 'PA_EVENT_IN_DELV_DEL'
                                 ,p_msg_attribute    => 'CHANGE'
                                 ,p_resize_flag      => 'N'
                                 ,p_msg_context      => 'EVENT'
                                 ,p_attribute1       => p_pm_event_reference
                                 ,p_attribute2       => ''
                                 ,p_attribute3       => ''
                                 ,p_attribute4       => ''
                                 ,p_attribute5       => '');
                  END IF;
                  p_return_status:='N';
                  Return(p_return_status);
          END;
  ElsIf  l_event_processed IN ('N','I','R')/*For Bug 7305416*/
  Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_TK_EVENT_IN_USE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         p_return_status:='N';
         Return(p_return_status);
/* The following code has been added for bug 3205120 */
  Elsif l_event_processed ='P'
  Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_EVENT_PARTIAL_BILL'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         p_return_status:='N';
         Return(p_return_status);
  Elsif l_event_processed = 'C'
  Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_EVENT_CANCEL_DEL'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         p_return_status:='N';
         Return(p_return_status);
/*End of change for bug 3205120  */
  End If;
 --For Bug 3619483
   SELECT  	t.event_type_classification
   INTO  	p_event_type_classification
   FROM  	pa_event_types t,pa_events v
   WHERE  	v.event_id=P_event_id
   AND  	t.event_type=v.event_type ;

  IF ( (g_rev_evt_fun_allowed = 'N' )  AND
      (p_event_type_classification IN('WRITE ON','WRITE OFF')) ) THEN
               pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_EV_NO_REV_MAINT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
              RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ( (g_inv_evt_fun_allowed = 'N' )  AND
      (p_event_type_classification IN('DEFERRED REVENUE','INVOICE REDUCTION','SCHEDULED PAYMENTS'))) THEN
	    pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_EV_NO_INV_MAINT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
              RAISE FND_API.G_EXC_ERROR;
  END IF;
 SELECT  bill_trans_rev_amount,
          bill_trans_bill_amount
  INTO    l_rev_amount,
          l_bill_amount
  FROM pa_events
  WHERE event_id = P_event_id;

   IF (p_event_type_classification = 'MANUAL')  THEN
        IF (   (g_inv_evt_fun_allowed = 'Y' )  AND
               (g_rev_evt_fun_allowed = 'N' )  AND
               (l_rev_amount <> 0) ) THEN
                      pa_interface_utils_pub.map_new_amg_msg
                         ( p_old_message_code => 'PA_EV_NO_REV_MAINT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
                      RAISE FND_API.G_EXC_ERROR;

        ELSIF ( (g_inv_evt_fun_allowed = 'N' )  AND
                (g_rev_evt_fun_allowed = 'Y' )  AND
                (l_bill_amount <> 0)) THEN
                     pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_EV_NO_INV_MAINT_AMG'
                         ,p_msg_attribute    => 'CHANGE'
                         ,p_resize_flag      => 'Y'
                         ,p_msg_context      => 'GENERAL'
                         ,p_attribute1       => ''
                         ,p_attribute2       => ''
                         ,p_attribute3       => ''
                         ,p_attribute4       => ''
                        ,p_attribute5       => '');
                     RAISE FND_API.G_EXC_ERROR;
        END IF;

   END IF;

--End of Bug  3619483
  Return(p_return_status);

        --handling exceptions
        Exception
        When pa_event_utils.pvt_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_DELETE_EVENT_OK->';
                Raise pub_excp;--raising exception to be handled in public package

        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_DELETE_EVENT_OK->';
                Raise pub_excp;--raising exception to be handled in public package

END CHECK_DELETE_EVENT_OK;

-- ============================================================================
--
--Name:
--Type:
--Description:  This function validates the uniqueness of the event_reference
--		and product_code combination during creation of new events.
--
--Called subprograms: None
--
-- ============================================================================
FUNCTION CHECK_EVENT_REF_UNQ
(P_pm_product_code	IN	VARCHAR2
,P_pm_event_reference	IN	VARCHAR2)
RETURN VARCHAR2
AS

Cursor ProductCode_cur(P_pm_product_code    VARCHAR2)
Is
	select 1
	from pa_lookups
	where lookup_type ='PM_PRODUCT_CODE'
	and lookup_code=P_pm_product_code;

Cursor unique_evnt_ref_curs(P_pm_product_code    VARCHAR2
			  ,P_pm_event_reference	VARCHAR2)
Is
	 Select 1
	 From pa_events
	 Where pm_product_code=P_pm_product_code
	 And pm_event_reference =P_pm_event_reference;

l_product_code	 	NUMBER:=NULL;
l_event_reference	NUMBER:=NULL;
BEGIN

Open ProductCode_cur(P_pm_product_code);
Fetch ProductCode_cur Into l_product_code;
Close ProductCode_cur;

If l_product_code Is NULL
Then
	 RETURN('N');
Else
	Open unique_evnt_ref_curs(P_pm_product_code,P_pm_event_reference);
	Fetch unique_evnt_ref_curs Into l_event_reference;
	Close unique_evnt_ref_curs;
	If l_event_reference Is NOT NULL
	Then
		RETURN('N');
	Else
		RETURN('Y');
	End If;
End If;

        --handling exceptions
        Exception
        When pa_event_utils.pvt_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_EVENT_REF_UNQ->';
                Raise pub_excp;--raising exception to be handled in public package

        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_EVENT_REF_UNQ->';
                Raise pub_excp;--raising exception to be handled in public package

END CHECK_EVENT_REF_UNQ;
-- ============================================================================
--
--Name:
--Type:
--Description:  This function validates and returns 'T' if the given value is
--		in ('Y','y','N','n')
--
--Called subprograms: None
--
-- ============================================================================
FUNCTION CHECK_YES_NO
(P_flag		IN	VARCHAR2)
RETURN VARCHAR2
AS
l_return_status         VARCHAR2(1):='Y';

BEGIN

   If (P_flag In('Y','y','N','n')
        OR P_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
   Then
	RETURN(l_return_status);
   Else
	l_return_status := 'N';
	RETURN(l_return_status);
   End If;

        --handling exceptions
        Exception
        When pa_event_utils.pvt_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CHECK_YES_NO->';
                Raise pub_excp;--raising exception to be handled in public package

        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_YES_NO->';
                Raise pub_excp;--raising exception to be handled in public package

END CHECK_YES_NO;

-- ============================================================================
--
--Name:
--Type:
--Description:  This function fetches the event_id for the given event_reference
--		and product_code combination.
--
--Called subprograms: None
--
-- ============================================================================
FUNCTION FETCH_EVENT_ID
(P_pm_product_code	IN	VARCHAR2
,P_pm_event_reference 	IN	VARCHAR2)
RETURN NUMBER
AS

cursor fetch_event_id_curs
Is
	  Select event_id
	  From pa_events
	  Where pm_event_reference = p_pm_event_reference
	  And pm_product_code = p_pm_product_code;

P_event_out_id		NUMBER:=NULL;

BEGIN

  Open fetch_event_id_curs;
  Fetch fetch_event_id_curs Into P_event_out_id;
  Close fetch_event_id_curs;

  If P_event_out_id is not NULL
  Then
          RETURN(P_event_out_id);
  else
          RETURN(NULL);
  End If;

        --handling exceptions
        Exception
        When pa_event_utils.pvt_excp
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'FETCH_EVENT_ID->';
                Raise pub_excp;--raising exception to be handled in public package

        When others
                then
                PA_EVENT_PUB.PACKAGE_NAME:=PA_EVENT_PUB.PACKAGE_NAME||'PRIVATE->';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'FETCH_EVENT_ID->';
                Raise pub_excp;--raising exception to be handled in public package

END FETCH_EVENT_ID;

END PA_EVENT_PVT;


/
