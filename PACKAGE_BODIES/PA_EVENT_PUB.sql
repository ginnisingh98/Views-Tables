--------------------------------------------------------
--  DDL for Package Body PA_EVENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EVENT_PUB" AS
/* $Header: PAEVAPBB.pls 120.6.12010000.6 2009/06/20 00:20:52 skkoppul ship $ */

/* Global Constants */
G_PKG_NAME		VARCHAR2(30) := 'PA_EVENT_PUB';

--PACKAGE GLOBAL to be used during updates ---------------------------
G_USER_ID               CONSTANT NUMBER := FND_GLOBAL.USER_id;
G_LOGIN_ID              CONSTANT NUMBER := FND_GLOBAL.login_id;

l_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG.MODE'),'Y');

/*==================================================================
--
--Name:               create_event
--Type:               procedure
--Description: This API creates an event or a set of events.
--
--Called subprograms: PA_EVENT_PVT.CHECK_MDTY_PARAMS1
--		      PA_EVENT_PVT.CHECK_MDTY_PARAMS2
--		      PA_EVENT_UTILS.CHECK_VALID_PROJECT
--		      PA_EVENT_PVT.CHECK_CREATE_EVENT_OK
--		      PA_EVENT_PVT.VALIDATE_FLEXFIELD
--		      PA_EVENTS_PKG.INSERT_ROW
--History:

-- ============================================================================*/

PROCEDURE create_event
    ( p_api_version_number   IN      NUMBER
     ,p_commit               IN      VARCHAR2
     ,p_init_msg_list        IN      VARCHAR2
     ,p_pm_product_code      IN      VARCHAR2
     ,p_event_in_tbl	     IN      Event_In_Tbl_Type
     ,p_event_out_tbl	     OUT     NOCOPY Event_Out_Tbl_Type  --File.Sql.39 bug 4440895
     ,p_msg_count            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,p_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,p_return_status        OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS


rowid				varchar2(18);
l_event_type_classification	pa_event_types.event_type_classification%type;
P_project_id			pa_events.project_id%type;
P_task_id			pa_events.task_id%type;
P_Organization_Id		pa_projects_all.org_id%type;
p_inv_org_id                    pa_events.inventory_item_id%type;
p_agreement_id                  pa_events.agreement_id%type;   -- Federal Uptake

p_event_in_rec 			Event_Rec_In_Type;
p_event_out_rec			Event_Rec_Out_Type;
tot_in_rec			NUMBER:=0;
tot_out_rec                     NUMBER:=0;
p_api_name			VARCHAR2(100):='CREATE_EVENT';
p_return_msg                    VARCHAR2(2000);
p_validate_status               VARCHAR2(1):='Y';

/* Declaring varible for MCB2 */
l_multi_currency_billing_flag     pa_projects_all.multi_currency_billing_flag%type;
l_baseline_funding_flag           pa_projects_all.BASELINE_FUNDING_FLAG%TYPE;
l_revproc_currency_code           pa_projects_all.revproc_currency_code%TYPE;
l_revproc_rate_type               pa_events.revproc_rate_type%TYPE;
l_revproc_rate_date               pa_events.revproc_rate_date%TYPE;
l_revproc_exchange_rate           pa_events.revproc_exchange_rate%TYPE;
l_invproc_currency_code           pa_events.invproc_currency_code%TYPE;
l_invproc_currency_type           pa_projects_all.invproc_currency_type%TYPE;
l_invproc_rate_type               pa_events.invproc_rate_type%TYPE;
l_invproc_rate_date               pa_events.invproc_rate_date%TYPE;
l_invproc_exchange_rate           pa_events.invproc_exchange_rate%TYPE;
l_project_currency_code           pa_projects_all.project_currency_code%TYPE;
l_project_bil_rate_date_code      pa_projects_all.project_bil_rate_date_code%TYPE;
l_project_bil_rate_type           pa_projects_all.project_bil_rate_type%TYPE;
l_project_bil_rate_date           pa_projects_all.project_bil_rate_date%TYPE;
l_project_bil_exchange_rate       pa_projects_all.project_bil_exchange_rate%TYPE;
l_projfunc_currency_code          pa_projects_all.projfunc_currency_code%TYPE;
l_projfunc_bil_rate_date_code     pa_projects_all.projfunc_bil_rate_date_code%TYPE;
l_projfunc_bil_rate_type          pa_projects_all.projfunc_bil_rate_type%TYPE;
l_projfunc_bil_rate_date          pa_projects_all.projfunc_bil_rate_date%TYPE;
l_projfunc_bil_exchange_rate      pa_projects_all.projfunc_bil_exchange_rate%TYPE;
l_funding_rate_date_code          pa_projects_all.funding_rate_date_code%TYPE;
l_funding_rate_type               pa_projects_all.funding_rate_type%TYPE;
l_funding_rate_date               pa_projects_all.funding_rate_date%TYPE;
l_funding_exchange_rate           pa_projects_all.funding_exchange_rate%TYPE;

l_event_number			  pa_events.event_num%type;
l_encoded                         varchar2(1):='F';
l_return_status 		  varchar2(1):= FND_API.G_RET_STS_SUCCESS;
BEGIN
  -- Initialize the Error Stack
  pa_debug.set_err_stack('PA_EVENT_PUB.CREATE_EVENT');

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.CREATE_EVENT.begin'
                     ,x_msg         => 'Beginning of Create Event'
                     ,x_log_level   => 5);
   END IF;

      p_msg_count := 0;
      p_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.CREATE_EVENT.begin'
                     ,x_msg         => 'Calling  mandatory input parameters-1'
                     ,x_log_level   => 5);
   END IF;

 ---Validating mandatory input parameters-


   PA_EVENT_PVT.CHECK_MDTY_PARAMS1
    ( p_api_version_number             =>p_api_version_number
     ,p_api_name                       =>p_api_name
     ,p_pm_product_code                =>p_pm_product_code
     ,p_function_name                  =>'PA_EV_CREATE_EVENT'
     ,x_return_status                  =>p_return_status
     ,x_msg_count                      =>p_msg_count
     ,x_msg_data                       =>p_msg_data );


   If p_return_status <> FND_API.G_RET_STS_SUCCESS
   Then

        IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF p_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
   End If;
   tot_in_rec := p_event_in_tbl.first;
   while tot_in_rec is not null loop   -- loop begins
--  For all the date variables using TRUNC instead of ltrim(rtrim) for bug 3053669
P_event_in_rec.P_pm_event_reference             :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_pm_event_reference));
P_event_in_rec.P_task_number                    :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_task_number));
P_event_in_rec.P_event_number                   :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_event_number));
P_event_in_rec.P_event_type                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_event_type));
-- Added the below three line for federal Uptake
P_event_in_rec.P_agreement_number               :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_agreement_number));
P_event_in_rec.P_agreement_type                 :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_agreement_type));
P_event_in_rec.P_customer_number                :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_customer_number));
-- Bug 8410898 skkoppul
IF (p_event_in_tbl(tot_in_rec).P_description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
    P_event_in_rec.P_description                :=NULL;
ELSE
    P_event_in_rec.P_description                :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_description));
END IF;
P_event_in_rec.P_bill_hold_flag                 :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_bill_hold_flag));
P_event_in_rec.P_completion_date                :=trunc(p_event_in_tbl(tot_in_rec).P_completion_date);
P_event_in_rec.P_desc_flex_name                 :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_desc_flex_name));
P_event_in_rec.P_attribute_category             :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute_category));
P_event_in_rec.P_attribute1                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute1));
P_event_in_rec.P_attribute2                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute2));
P_event_in_rec.P_attribute3                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute3));
P_event_in_rec.P_attribute4                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute4));
P_event_in_rec.P_attribute5                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute5));
P_event_in_rec.P_attribute6                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute6));
P_event_in_rec.P_attribute7                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute7));
P_event_in_rec.P_attribute8                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute8));
P_event_in_rec.P_attribute9                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute9));
P_event_in_rec.P_attribute10                    :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute10));
P_event_in_rec.P_project_number                 :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_project_number));
P_event_in_rec.P_organization_name              :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_organization_name));
P_event_in_rec.P_inventory_org_name             :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_inventory_org_name));
P_event_in_rec.P_inventory_item_id              :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_inventory_item_id));
P_event_in_rec.P_quantity_billed                :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_quantity_billed));
P_event_in_rec.P_uom_code                       :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_uom_code));
P_event_in_rec.P_unit_price                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_unit_price));
P_event_in_rec.P_reference1                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference1));
P_event_in_rec.P_reference2                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference2));
P_event_in_rec.P_reference3                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference3));
P_event_in_rec.P_reference4                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference4));
P_event_in_rec.P_reference5                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference5));
P_event_in_rec.P_reference6                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference6));
P_event_in_rec.P_reference7                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference7));
P_event_in_rec.P_reference8                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference8));
P_event_in_rec.P_reference9                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference9));
P_event_in_rec.P_reference10                    :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference10));
P_event_in_rec.P_bill_trans_currency_code       :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_bill_trans_currency_code));
P_event_in_rec.P_bill_trans_bill_amount         :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_bill_trans_bill_amount));
P_event_in_rec.P_bill_trans_rev_amount          :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_bill_trans_rev_amount));
-- Bug 8410898 skkoppul
IF (p_event_in_tbl(tot_in_rec).P_project_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
   P_event_in_rec.P_project_rate_type           :=NULL;
ELSE
   P_event_in_rec.P_project_rate_type           :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_project_rate_type));
END IF;
P_event_in_rec.P_project_rate_date              :=trunc(p_event_in_tbl(tot_in_rec).P_project_rate_date);
P_event_in_rec.P_project_exchange_rate          :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_project_exchange_rate));
-- Bug 8410898 skkoppul
IF (p_event_in_tbl(tot_in_rec).P_projfunc_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
   P_event_in_rec.P_projfunc_rate_type          := NULL;
ELSE
   P_event_in_rec.P_projfunc_rate_type          :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_projfunc_rate_type));
END IF;
P_event_in_rec.P_projfunc_rate_date             :=trunc(p_event_in_tbl(tot_in_rec).P_projfunc_rate_date);
P_event_in_rec.P_projfunc_exchange_rate         :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_projfunc_exchange_rate));
-- Bug 8410898 skkoppul
IF (p_event_in_tbl(tot_in_rec).P_funding_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
    P_event_in_rec.P_funding_rate_type          := NULL;
ELSE
    P_event_in_rec.P_funding_rate_type          :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_funding_rate_type));
END IF;
P_event_in_rec.P_funding_rate_date              :=trunc(p_event_in_tbl(tot_in_rec).P_funding_rate_date);
P_event_in_rec.P_funding_exchange_rate          :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_funding_exchange_rate));
P_event_in_rec.P_adjusting_revenue_flag         :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_adjusting_revenue_flag));
P_event_in_rec.P_event_id                       :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_event_id));
P_event_in_rec.P_deliverable_id                 :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_deliverable_id));
P_event_in_rec.P_action_id                      :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_action_id));
P_event_in_rec.P_context                        :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_context));


   BEGIN	--Start of Inner Block
	   --Seting savepoint
	     savepoint create_event;

	  --Log Message
	  IF l_debug_mode = 'Y' THEN
	  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.CREATE_EVENT.begin'
			     ,x_msg         => ' Calling mandatory input parameters-2'
			     ,x_log_level   => 5);
	  END IF;

	-- Validating mandatory input parameters-2

	     PA_EVENT_PVT.CHECK_MDTY_PARAMS2
	     (p_pm_event_reference    => p_event_in_rec.p_pm_event_reference
	     ,p_pm_product_code       => p_pm_product_code
	     ,p_project_number        => p_event_in_rec.p_project_number
	     ,p_event_type            => p_event_in_rec.p_event_type
	     ,p_organization_name     => p_event_in_rec.p_organization_name
	     ,p_calling_place         => 'CREATE_EVENT'
	     ,x_return_status         => p_return_status );

	     If p_return_status <> FND_API.G_RET_STS_SUCCESS
	     Then
		IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR
		THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		ELSIF p_return_status = FND_API.G_RET_STS_ERROR
		THEN
				RAISE FND_API.G_EXC_ERROR;
		END IF;
	     End If;

          --Log Message
          IF l_debug_mode = 'Y' THEN
          pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.CREATE_EVENT.begin'
                             ,x_msg         => 'Calling check_valid_project '
			     ,x_log_level   => 5);
          END IF;

	--validating the project number and derive the project_id.
	  If PA_EVENT_UTILS.CHECK_VALID_PROJECT
		(P_project_id   =>P_project_id
		,P_project_num  =>P_event_in_rec.P_project_number) = 'N'
	  Then
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			pa_interface_utils_pub.map_new_amg_msg
				( p_old_message_code => 'PA_INVALID_PROJECT'
				,p_msg_attribute    => 'CHANGE'
				,p_resize_flag      => 'N'
				,p_msg_context      => 'EVENT'
				,p_attribute1       => P_event_in_rec.p_pm_event_reference
				,p_attribute2       => ''
				,p_attribute3       => ''
				,p_attribute4       => ''
				,p_attribute5       => '');
		 END IF;
		 p_return_status := FND_API.G_RET_STS_ERROR;
	--If project_id is invalid then terminate further validation by raising error.
		 RAISE FND_API.G_EXC_ERROR;
	  End If;

          --Log Message
          IF l_debug_mode = 'Y' THEN
          pa_debug.write_log (x_module      =>'pa.plsql.PA_EVENT_PUB.CREATE_EVENT.begin'
                             ,x_msg         =>'Calling get_project_defaults to get defaulting currencies'
			     ,x_log_level   =>5);
          END IF;

	-- Before the check_create_event_ok function is called the mcb related
	-- fields are defaulted
	-- Defaulting currency fields for the given project_id.

	      PA_MULTI_CURRENCY_BILLING.get_project_defaults (
		    p_project_id                  =>  P_project_id,
		    x_multi_currency_billing_flag =>  l_multi_currency_billing_flag,
		    x_baseline_funding_flag       =>  l_baseline_funding_flag,
		    x_revproc_currency_code       =>  l_revproc_currency_code,
		    x_invproc_currency_type       =>  l_invproc_currency_type,
		    x_invproc_currency_code       =>  l_invproc_currency_code,
		    x_project_currency_code       =>  l_project_currency_code,
		    x_project_bil_rate_date_code  =>  l_project_bil_rate_date_code,
		    x_project_bil_rate_type       =>  l_project_bil_rate_type,
		    x_project_bil_rate_date       =>  l_project_bil_rate_date,
		    x_project_bil_exchange_rate   =>  l_project_bil_exchange_rate,
		    x_projfunc_currency_code      =>  l_projfunc_currency_code,
		    x_projfunc_bil_rate_date_code =>  l_projfunc_bil_rate_date_code,
		    x_projfunc_bil_rate_type      =>  l_projfunc_bil_rate_type,
		    x_projfunc_bil_rate_date      =>  l_projfunc_bil_rate_date,
		    x_projfunc_bil_exchange_rate  =>  l_projfunc_bil_exchange_rate,
		    x_funding_rate_date_code      =>  l_funding_rate_date_code,
		    x_funding_rate_type           =>  l_funding_rate_type,
		    x_funding_rate_date           =>  l_funding_rate_date,
		    x_funding_exchange_rate       =>  l_funding_exchange_rate,
		    x_return_status               =>  p_return_status,
		    x_msg_count                   =>  p_msg_count,
		    x_msg_data                    =>  p_msg_data);

             If p_return_status <> FND_API.G_RET_STS_SUCCESS
             Then
                IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR
                THEN
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                ELSIF p_return_status = FND_API.G_RET_STS_ERROR
                THEN
                                RAISE FND_API.G_EXC_ERROR;
                END IF;
             End If;

	--Log Message
          IF l_debug_mode = 'Y' THEN
          pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.CREATE_EVENT.begin'
                             ,x_msg         => 'Calling check_create_event_ok'
			     ,x_log_level   => 5);
          END IF;

	-- Calls check_create_event_ok function

	     If PA_EVENT_PVT.check_create_event_ok
		(P_pm_product_code 		=>p_pm_product_code
		,P_event_in_rec	        	=>p_event_in_rec
		,P_project_currency_code	=>l_project_currency_code
		,P_proj_func_currency_code	=>l_projfunc_currency_code
		,P_project_bil_rate_date_code	=>l_project_bil_rate_date_code
		,P_project_rate_type		=>l_project_bil_rate_type
		,p_project_bil_rate_date	=>l_project_bil_rate_date
		,p_projfunc_bil_rate_date_code  =>l_projfunc_bil_rate_date_code
		,P_projfunc_rate_type		=>l_projfunc_bil_rate_type
		,p_projfunc_bil_rate_date	=>l_projfunc_bil_rate_date
		,P_funding_rate_type		=>l_funding_rate_type
		,P_event_type_classification    =>l_event_type_classification
		,P_multi_currency_billing_flag	=>l_multi_currency_billing_flag
		,p_project_id			=>p_project_id
                ,p_projfunc_bil_exchange_rate   =>l_projfunc_bil_exchange_rate -- Added for bug 3009307
                ,p_funding_bil_rate_date_code  => l_funding_rate_date_code --Added for bug 3053190
		,x_task_id			=>p_task_id
		,x_organization_id		=>p_organization_id
		,x_inv_org_id			=>p_inv_org_id
                ,x_agreement_id                 =>p_agreement_id         -- Federal Uptake
		) = 'N'
	     Then
        	p_return_status             := FND_API.G_RET_STS_ERROR;
        	RAISE FND_API.G_EXC_ERROR;
  	     End If;

          --Log Message
          IF l_debug_mode = 'Y' THEN
          pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.CREATE_EVENT.begin'
                             ,x_msg         => 'Beginning Validate Flexfields'
                     ,x_log_level   => 5);
          END IF;


	--Validating Flexfields
	     IF (p_event_in_rec.p_desc_flex_name IS NOT NULL)
		 AND (p_event_in_rec.p_desc_flex_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
	     THEN
			PA_EVENT_PVT.VALIDATE_FLEXFIELD
			( p_desc_flex_name        => p_event_in_rec.p_desc_flex_name
			 ,p_attribute_category    => p_event_in_rec.p_attribute_category
			 ,p_attribute1            => p_event_in_rec.p_attribute1
			 ,p_attribute2            => p_event_in_rec.p_attribute2
			 ,p_attribute3            => p_event_in_rec.p_attribute3
			 ,p_attribute4            => p_event_in_rec.p_attribute4
			 ,p_attribute5            => p_event_in_rec.p_attribute5
			 ,p_attribute6            => p_event_in_rec.p_attribute6
			 ,p_attribute7            => p_event_in_rec.p_attribute7
			 ,p_attribute8            => p_event_in_rec.p_attribute8
			 ,p_attribute9            => p_event_in_rec.p_attribute9
			 ,p_attribute10           => p_event_in_rec.p_attribute10
			 ,p_return_msg            => p_return_msg
			 ,p_valid_status       => p_validate_status);
		   IF p_validate_status = 'N'
		   THEN
			   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			   THEN
				pa_interface_utils_pub.map_new_amg_msg
				( p_old_message_code => 'PA_INVALID_FF_VALUES'
				,p_msg_attribute    => 'CHANGE'
				,p_resize_flag      => 'N'
				,p_msg_context      => 'EVENT'
				,p_attribute1       => p_event_in_rec.p_pm_event_reference
				,p_attribute2       => ''
				,p_attribute3       => ''
				,p_attribute4       => ''
				,p_attribute5       => '');
			    END IF;
			    p_return_status             := FND_API.G_RET_STS_ERROR;
			    RAISE FND_API.G_EXC_ERROR;
		    END IF;
	       Else
			p_event_in_rec.P_desc_flex_name 	:=NULL;
			p_event_in_rec.P_attribute_category	:=NULL;
			p_event_in_rec.P_attribute1		:=NULL;
			p_event_in_rec.P_attribute2		:=NULL;
			p_event_in_rec.P_attribute3		:=NULL;
			p_event_in_rec.P_attribute4		:=NULL;
			p_event_in_rec.P_attribute5		:=NULL;
			p_event_in_rec.P_attribute6		:=NULL;
			p_event_in_rec.P_attribute7		:=NULL;
			p_event_in_rec.P_attribute8		:=NULL;
			p_event_in_rec.P_attribute9		:=NULL;
			p_event_in_rec.P_attribute10		:=NULL;
	       END IF;

		--Log Message
		IF l_debug_mode = 'Y' THEN
		pa_debug.write_log (  x_module      => 'pa.plsql.PA_EVENT_PUB.CREATE_EVENT.begin'
				     ,x_msg         => 'Validating or generating event number'
				     ,x_log_level   => 5);
		END IF;

		-- Validating the event num.If found NULL it is populated before
		-- inserting the record into pa_events.
                  If (p_event_in_rec.P_event_number Is NULL
                        OR p_event_in_rec.P_event_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
		    Then
			  --generating event number for project level events
			  If (P_task_id Is NULL)
			  Then
				SELECT NVL(max(event_num),0)+1
				INTO P_event_in_rec.p_event_number
				FROM pa_events e
				WHERE e.project_id = P_project_id
				AND e.task_id IS NULL;
			  Else
			  --generating event number for task level events
				SELECT NVL(max(event_num),0)+1
				INTO P_event_in_rec.p_event_number
				FROM pa_events e
				WHERE e.project_id =P_project_id
				AND e.task_id    = P_task_id;
			  End If;
		    End If;

		--Validating the adjust revenue flag
		If upper(p_event_in_rec.P_adjusting_revenue_flag) = 'Y'
		Then
			p_event_in_rec.P_bill_trans_bill_amount := 0;
			p_event_in_rec.P_bill_hold_flag := 'N';
                  p_event_in_rec.P_adjusting_revenue_flag :='Y';
		End If;

		--If event type is of revenue type(Write-Off), set bill trans bill amt = 0.

		If  l_event_type_classification In('WRITE OFF')
		Then
			p_event_in_rec.P_bill_trans_bill_amount:=0;
		End If;

		--If event type is of invoice type, set bill trans rev amt = 0

		If l_event_type_classification In('DEFERRED REVENUE','INVOICE REDUCTION','SCHEDULED PAYMENTS')
		Then
			p_event_in_rec.P_bill_trans_rev_amount:=0;
		End If;

		--If event type = 'Write-On' bill trans bill amt = rev amt.

		If (l_event_type_classification = 'WRITE ON')
		Then
			p_event_in_rec.P_bill_trans_bill_amount := p_event_in_rec.P_bill_trans_rev_amount;
		End If;

		--If P_description is NULL then set default as event_type

		If(p_event_in_rec.P_description Is NULL)
		Then
			p_event_in_rec.P_description:=p_event_in_rec.P_event_type;
		End If;

		--Defaulting adjusting revenue flag
		If(p_event_in_rec.P_adjusting_revenue_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
		Then
                p_event_in_rec.P_adjusting_revenue_flag :=NULL;
		End If;

		--Defaulting bill hold flag
		If(p_event_in_rec.P_bill_hold_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
		Then
			p_event_in_rec.P_bill_hold_flag :=NULL;
		End If;


          --Log Message
          IF l_debug_mode = 'Y' THEN
          pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.CREATE_EVENT.begin'
                             ,x_msg         => 'Beginning defaulting mcb parameters'
			     ,x_log_level   => 5);
          END IF;

        --Before defaulting the mcb related paramaters validating
        --if the User has overwritten any of the fields.
	If (l_multi_currency_billing_flag = 'Y')
	Then
        /* Moved the following code here from a later point for code merge of bug 5458861 */
       --Get the conversion_type for funding_rate_type, projfunc_rate_type and project_rate_type for bug3009239

           IF p_event_in_rec.p_funding_rate_type is not null
              THEN
                 SELECT conversion_type
                   INTO l_funding_rate_type
                   FROM pa_conversion_types_v
                  WHERE user_conversion_type = p_event_in_rec.p_funding_rate_type
                     or conversion_type = p_event_in_rec.p_funding_rate_type;
                 p_event_in_rec.p_funding_rate_type := l_funding_rate_type;
              END IF;

             IF p_event_in_rec.p_projfunc_rate_type is not null
              THEN
                 SELECT conversion_type
                   INTO l_projfunc_bil_rate_type
                   FROM pa_conversion_types_v
                  WHERE user_conversion_type = p_event_in_rec.p_projfunc_rate_type
                     or conversion_type = p_event_in_rec.p_projfunc_rate_type;
                 p_event_in_rec.p_projfunc_rate_type := l_projfunc_bil_rate_type;
             END IF;

             IF p_event_in_rec.p_project_rate_type is not null
              THEN
                 SELECT conversion_type
                   INTO l_project_bil_rate_type
                   FROM pa_conversion_types_v
                  WHERE user_conversion_type = p_event_in_rec.p_project_rate_type
                     or conversion_type = p_event_in_rec.p_project_rate_type;
                 p_event_in_rec.p_project_rate_type := l_project_bil_rate_type;
             END IF;

          --till here for code merge of bug 5458861


        --validating and defaulting bill transaction currency code
                  If (p_event_in_rec.P_bill_trans_currency_code Is NULL
                        OR p_event_in_rec.P_bill_trans_currency_code=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
                    Then
                        p_event_in_rec.P_bill_trans_currency_code:=l_projfunc_currency_code;
                  End If;

	--funding rate,date and type validations
                If(p_event_in_rec.P_funding_rate_type Is NULL
                        OR p_event_in_rec.P_funding_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
                   Then
                        p_event_in_rec.P_funding_rate_type:=l_funding_rate_type;
                End If;
		If (l_funding_rate_date_code = 'FIXED_DATE')
		Then
			If(p_event_in_rec.P_funding_rate_date Is NULL
                           OR p_event_in_rec.P_funding_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
                        Then
                              p_event_in_rec.P_funding_rate_date:=l_funding_rate_date;
			End If;
		Else
                   --Commented for Bug3009239
		   --	p_event_in_rec.P_funding_rate_date:=l_funding_rate_date;
                   --Added for Bug3009239
                        If(p_event_in_rec.P_funding_rate_date Is NULL
                           OR p_event_in_rec.P_funding_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
                        Then
                              p_event_in_rec.P_funding_rate_date:=l_funding_rate_date;
                        End If;
                   --till here for Bug3009239
		End If;
		--If fund rate type is User then only take the exchange rate from User
		--else default it from the project level.
/* The following block of code has been commented for bug 3045302
                If (p_event_in_rec.P_funding_rate_type <>l_funding_rate_type)
                Then
                        If ( p_event_in_rec.P_funding_rate_type <> 'User' )
                        Then
                                p_event_in_rec.P_funding_exchange_rate :=NULL;
                        Else
                           If(p_event_in_rec.P_funding_exchange_rate Is NULL
                               OR p_event_in_rec.P_funding_exchange_rate =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                           Then
                                p_event_in_rec.P_funding_exchange_rate:=l_funding_exchange_rate;
                           End If;
                           p_event_in_rec.P_funding_rate_date := null;  --Added for Bug3013256
                        End If;

                Else
                        If(p_event_in_rec.P_funding_rate_type = 'User'
                          AND (p_event_in_rec.P_funding_exchange_rate Is NULL
                              OR p_event_in_rec.P_funding_exchange_rate =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
                        Then
                                p_event_in_rec.P_funding_exchange_rate :=l_funding_exchange_rate;
                          p_event_in_rec.P_funding_rate_date := null; --Added for Bug3010927
                        --Added for Bug3013256
                        Else
                           If ( p_event_in_rec.P_funding_rate_type <> 'User' ) THEN
                                p_event_in_rec.p_funding_exchange_rate := null;
                           End If;
                        --till here for Bug3013256
                        End If;
                End If;
End of comment for bug 3045302 */

  /*Code added for bug  3045302 */
                  If ( p_event_in_rec.P_funding_rate_type <> 'User' )
                     Then
                           p_event_in_rec.P_funding_exchange_rate :=NULL;
                  Else
                           If(p_event_in_rec.P_funding_exchange_rate Is NULL
                                OR p_event_in_rec.P_funding_exchange_rate =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                               Then
                                    p_event_in_rec.P_funding_exchange_rate:=l_funding_exchange_rate;
                            End If;
                          p_event_in_rec.P_funding_rate_date := null;  --Added for Bug3013256
                  End If;
/*End of code change for Bug 3045302 */
/*The code for validation of project currency attributes has been moved from here
  to below the validation of project functional currency attributes for
  bug 3045302*/
	--project functional rate,date,type validaions
		If (p_event_in_rec.P_bill_trans_currency_code =  l_projfunc_currency_code )
		Then
			p_event_in_rec.P_projfunc_rate_type	:=NULL;
			p_event_in_rec.P_projfunc_rate_date	:=NULL;
			p_event_in_rec.P_projfunc_exchange_rate	:=NULL;

		--start of validtions when project functional currency and bill trans currency are different.
		Else
			If(p_event_in_rec.P_projfunc_rate_type Is NULL
				OR p_event_in_rec.P_projfunc_rate_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
			   Then
				p_event_in_rec.P_projfunc_rate_type:=l_projfunc_bil_rate_type;
			End If;

			If (l_projfunc_bil_rate_date_code= 'FIXED_DATE')
			Then
				If(p_event_in_rec.P_projfunc_rate_date Is NULL
					OR p_event_in_rec.P_projfunc_rate_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
				   Then
                                        p_event_in_rec.P_projfunc_rate_date:=l_projfunc_bil_rate_date;
				End If;
			Else
                           --Commented for Bug3009239
		           -- p_event_in_rec.P_projfunc_rate_date:=l_projfunc_bil_rate_date;
                           --Added for Bug3009239
                                If(p_event_in_rec.P_projfunc_rate_date Is NULL
                                        OR p_event_in_rec.P_projfunc_rate_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
                                   Then
                                        p_event_in_rec.P_projfunc_rate_date:=l_projfunc_bil_rate_date;
                                End If;
                           --till here for Bug3009239

			End If;

		       If(p_event_in_rec.P_projfunc_rate_type <> l_projfunc_bil_rate_type)
		       Then
				If ( p_event_in_rec.P_projfunc_rate_type <> 'User' )
				Then
					p_event_in_rec.P_projfunc_exchange_rate:=NULL;
                                ELSE
                                  If (p_event_in_rec.P_projfunc_exchange_rate Is NULL
                                      OR p_event_in_rec.P_projfunc_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                                  Then
                                        p_event_in_rec.P_projfunc_exchange_rate:=l_projfunc_bil_exchange_rate;
                                  End If;
                                  p_event_in_rec.P_projfunc_rate_date := null; --Added for Bug3010927
				End If;
			Else
				If(p_event_in_rec.P_projfunc_rate_type = 'User')
				Then
				  If (p_event_in_rec.P_projfunc_exchange_rate Is NULL
				      OR p_event_in_rec.P_projfunc_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
			          Then
					p_event_in_rec.P_projfunc_exchange_rate:=l_projfunc_bil_exchange_rate;
				  End If;
                                  p_event_in_rec.P_projfunc_rate_date := null; --Added for Bug3010927
				Else
                                  --Commented for Bug3013256
				  --p_event_in_rec.P_projfunc_exchange_rate:=l_projfunc_bil_exchange_rate;
				  p_event_in_rec.P_projfunc_exchange_rate:=null;  --Added for Bug3013256
				End If;
			End If;
		End If;

--project rate,date and type validations
		If (p_event_in_rec.P_bill_trans_currency_code = l_project_currency_code)
		Then
			p_event_in_rec.P_project_rate_type	:=NULL;
			p_event_in_rec.P_project_rate_date	:=NULL;
			p_event_in_rec.P_project_exchange_rate	:=NULL;

		--start of validations when project currency and bill trans currency are different.
            --If project currency code is same as projfunc currency code default the
            --attributes of project currency from project functional currency attributes.
            --Change for bug 3045302
		Elsif  (l_project_currency_code= l_projfunc_currency_code)
                  Then
                  p_event_in_rec.P_project_rate_type     := p_event_in_rec.P_projfunc_rate_type;
                  p_event_in_rec.P_project_rate_date     := p_event_in_rec.P_projfunc_rate_date;
                  p_event_in_rec.P_project_exchange_rate := p_event_in_rec.P_projfunc_exchange_rate;
            Else
			If(p_event_in_rec.P_project_rate_type Is NULL
				OR p_event_in_rec.P_project_rate_type =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
			  Then
				p_event_in_rec.P_project_rate_type:=l_project_bil_rate_type;
			End If;

			If (l_project_bil_rate_date_code = 'FIXED_DATE')
			Then
				If(p_event_in_rec.P_project_rate_date Is NULL
				    OR p_event_in_rec.P_project_rate_date =PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
				   Then
					p_event_in_rec.P_project_rate_date:=l_project_bil_rate_date;
				End If;
			Else
                          --Commented for Bug3009239
		          --	p_event_in_rec.P_project_rate_date:=l_project_bil_rate_date;
                          --Added for Bug3009239
                                If(p_event_in_rec.P_project_rate_date Is NULL
                                    OR p_event_in_rec.P_project_rate_date =PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
                                   Then
                                        p_event_in_rec.P_project_rate_date:=l_project_bil_rate_date;
                                End If;
                          --till here for Bug3009239
			End If;

			If (p_event_in_rec.P_project_rate_type<>l_project_bil_rate_type)
			Then
				If ( p_event_in_rec.P_project_rate_type <> 'User' )
				Then
					p_event_in_rec.P_project_exchange_rate:=NULL;
                                ELSE
                                   If(p_event_in_rec.P_project_exchange_rate Is NULL
                                      OR p_event_in_rec.P_project_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                                   Then
                                        p_event_in_rec.P_project_exchange_rate:=l_project_bil_exchange_rate;
                                   End If;
                                  p_event_in_rec.P_project_rate_date := null;  --Added for Bug3045302
				End If;
			Else
				If(p_event_in_rec.P_project_rate_type= 'User')
				Then
				  If(p_event_in_rec.P_project_exchange_rate Is NULL
				      OR p_event_in_rec.P_project_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
				  Then
					p_event_in_rec.P_project_exchange_rate:=l_project_bil_exchange_rate;
				  End If;
                                  p_event_in_rec.P_project_rate_date := null;  --Added for Bug3010927
				Else
                                  --Commented for Bug 3013256
			       	  --p_event_in_rec.P_project_exchange_rate:=l_project_bil_exchange_rate;
                                         p_event_in_rec.P_project_exchange_rate := null;  --Added for Bug3013256
				End If;
			End If;
                End If;

	Else
	--Defaulting the mcb columns when mcb is not enabled
		p_event_in_rec.P_project_rate_type:=l_project_bil_rate_type;
		p_event_in_rec.P_project_rate_date:=l_project_bil_rate_date;
		p_event_in_rec.P_project_exchange_rate:=l_project_bil_exchange_rate;

		p_event_in_rec.P_projfunc_rate_type:=l_projfunc_bil_rate_type;
		p_event_in_rec.P_projfunc_rate_date:=l_projfunc_bil_rate_date;
		p_event_in_rec.P_projfunc_exchange_rate:=l_projfunc_bil_exchange_rate;

		p_event_in_rec.P_funding_rate_type:=l_funding_rate_type;
		p_event_in_rec.P_funding_rate_date:=l_funding_rate_date;
		p_event_in_rec.P_funding_exchange_rate:=l_funding_exchange_rate;

		p_event_in_rec.P_bill_trans_currency_code:=l_projfunc_currency_code;
	End If;

	--Assigning null to event_id
	p_event_in_rec.p_event_id:=NULL;

          --Log Message
          IF l_debug_mode = 'Y' THEN
          pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.CREATE_EVENT.begin'
                             ,x_msg         => 'Beginning Insert event. '
                     ,x_log_level   => 5);
          END IF;

   	/* Moving the following code block to an earlier part of this procedure for code merge of bug 5458861 */

          --Get the conversion_type for funding_rate_type, projfunc_rate_type and project_rate_type for bug3009239
/*             IF p_event_in_rec.p_funding_rate_type is not null
              THEN
                 SELECT conversion_type
                   INTO l_funding_rate_type
                   FROM pa_conversion_types_v
                  WHERE user_conversion_type = p_event_in_rec.p_funding_rate_type
                     or conversion_type = p_event_in_rec.p_funding_rate_type;
                 p_event_in_rec.p_funding_rate_type := l_funding_rate_type;
              END IF;

             IF p_event_in_rec.p_projfunc_rate_type is not null
              THEN
                 SELECT conversion_type
                   INTO l_projfunc_bil_rate_type
                   FROM pa_conversion_types_v
                  WHERE user_conversion_type = p_event_in_rec.p_projfunc_rate_type
                     or conversion_type = p_event_in_rec.p_projfunc_rate_type;
                 p_event_in_rec.p_projfunc_rate_type := l_projfunc_bil_rate_type;
             END IF;

             IF p_event_in_rec.p_project_rate_type is not null
              THEN
                 SELECT conversion_type
                   INTO l_project_bil_rate_type
                   FROM pa_conversion_types_v
                  WHERE user_conversion_type = p_event_in_rec.p_project_rate_type
                     or conversion_type = p_event_in_rec.p_project_rate_type;
                 p_event_in_rec.p_project_rate_type := l_project_bil_rate_type;
             END IF;
          --till here for bug3009239
	Commented for code merge of bug 5458861 */

 -- Adding code to populate invoice and revenue attributes

    IF l_invproc_currency_type = 'PROJECT_CURRENCY' THEN
       l_invproc_currency_code := l_project_currency_code;
       l_invproc_rate_type     := p_event_in_rec.P_project_rate_type;
       l_invproc_rate_date     := p_event_in_rec.P_project_rate_date;
       l_invproc_exchange_rate := p_event_in_rec.P_project_exchange_rate;
    ELSIF l_invproc_currency_type = 'PROJFUNC_CURRENCY' THEN
       l_invproc_currency_code := l_projfunc_currency_code;
       l_invproc_rate_type     := p_event_in_rec.P_projfunc_rate_type;
       l_invproc_rate_date     := p_event_in_rec.P_projfunc_rate_date;
       l_invproc_exchange_rate := p_event_in_rec.P_projfunc_exchange_rate;
    ELSIF l_invproc_currency_type = 'FUNDING_CURRENCY' THEN
       l_invproc_currency_code := '';
       l_invproc_rate_type     := p_event_in_rec.P_funding_rate_type;
       l_invproc_rate_date     := p_event_in_rec.P_funding_rate_date;
       l_invproc_exchange_rate := p_event_in_rec.P_funding_exchange_rate;

    END IF;

    IF l_revproc_currency_code = l_projfunc_currency_code THEN
       l_revproc_currency_code := l_projfunc_currency_code;
       l_revproc_rate_type     := p_event_in_rec.P_projfunc_rate_type;
       l_revproc_rate_date     := p_event_in_rec.P_projfunc_rate_date;
       l_revproc_exchange_rate := p_event_in_rec.P_projfunc_exchange_rate;
    END IF;

--Added the following two calls for the bug 7513054
p_event_in_rec.P_bill_trans_bill_amount := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_event_in_rec.P_bill_trans_bill_amount,p_event_in_rec.P_bill_trans_currency_code);
--dbms_output.put_line('bill amount rounded');
p_event_in_rec.P_bill_trans_rev_amount := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_event_in_rec.P_bill_trans_rev_amount,p_event_in_rec.P_bill_trans_currency_code);
--dbms_output.put_line('rev amt rounded');

 -- Till here

	  --Call to table handler to insert the events into the database
	  --Calling PA_EVENTS_PKG.

	      PA_EVENTS_PKG.Insert_Row
		       (X_Rowid                      		=>rowid
		       ,X_Event_Id                      	=>p_event_in_rec.p_event_id
		       ,X_product_code                          =>p_pm_product_code
		       ,X_event_reference                       =>p_event_in_rec.p_pm_event_reference
		       ,X_Task_Id                               =>P_task_id
		       ,X_Event_Num                             =>p_event_in_rec.p_event_number
		       ,X_Last_Update_Date                      =>SYSDATE
		       ,X_Last_Updated_By                       =>G_USER_ID
		       ,X_Creation_Date                         =>SYSDATE
		       ,X_Created_By                            =>G_USER_ID
		       ,X_Last_Update_Login                     =>G_LOGIN_ID
		       ,X_Event_Type                            =>p_event_in_rec.P_event_type
		       ,X_Description                           =>p_event_in_rec.P_description
		       ,X_Bill_Amount                           =>0
		       ,X_Revenue_Amount                        =>0
		       ,X_Revenue_Distributed_Flag              =>'N'
		       ,X_Bill_Hold_Flag                        =>p_event_in_rec.P_bill_hold_flag
		       ,X_Completion_date                       =>p_event_in_rec.P_completion_date
		       ,X_Rev_Dist_Rejection_Code               =>NULL
		       ,X_Attribute_Category                    =>p_event_in_rec.P_attribute_category
		       ,X_Attribute1                            =>p_event_in_rec.P_attribute1
		       ,X_Attribute2                            =>p_event_in_rec.P_attribute2
		       ,X_Attribute3                            =>p_event_in_rec.P_attribute3
		       ,X_Attribute4                            =>p_event_in_rec.P_attribute4
		       ,X_Attribute5                            =>p_event_in_rec.P_attribute5
		       ,X_Attribute6                            =>p_event_in_rec.P_attribute6
		       ,X_Attribute7                            =>p_event_in_rec.P_attribute7
		       ,X_Attribute8                            =>p_event_in_rec.P_attribute8
		       ,X_Attribute9                            =>p_event_in_rec.P_attribute9
		       ,X_Attribute10                           =>p_event_in_rec.P_attribute10
		       ,X_Project_Id                            =>P_project_id
		       ,X_Organization_Id                       =>P_Organization_Id
		       ,X_Billing_Assignment_Id                 =>NULL
		       ,X_Event_Num_Reversed                    =>NULL
		       ,X_Calling_Place                         =>NULL
		       ,X_Calling_Process                       =>NULL
		       ,X_Bill_Trans_Currency_Code              =>p_event_in_rec.P_bill_trans_currency_code
		       ,X_Bill_Trans_Bill_Amount                =>p_event_in_rec.P_bill_trans_bill_amount
		       ,X_Bill_Trans_rev_Amount                 =>p_event_in_rec.P_bill_trans_rev_amount
		       ,X_Project_Currency_Code                 =>l_project_currency_code
		       ,X_Project_Rate_Type                     =>p_event_in_rec.P_project_rate_type
		       ,X_Project_Rate_Date                     =>p_event_in_rec.P_project_rate_date
		       ,X_Project_Exchange_Rate                 =>p_event_in_rec.P_project_exchange_rate
		       ,X_Project_Inv_Rate_Date                 =>NULL
		       ,X_Project_Inv_Exchange_Rate             =>NULL
		       ,X_Project_Bill_Amount                   =>NULL
		       ,X_Project_Rev_Rate_date                 =>NULL
		       ,X_Project_Rev_Exchange_Rate             =>NULL
		       ,X_Project_Revenue_Amount                =>NULL
		       ,X_ProjFunc_Currency_Code                =>l_projfunc_currency_code
		       ,X_ProjFunc_Rate_Type                    =>p_event_in_rec.P_projfunc_rate_type
		       ,X_ProjFunc_Rate_date                    =>p_event_in_rec.P_projfunc_rate_date
		       ,X_ProjFunc_Exchange_Rate                =>p_event_in_rec.P_projfunc_exchange_rate
		       ,X_ProjFunc_Inv_Rate_date                =>NULL
		       ,X_ProjFunc_Inv_Exchange_Rate            =>NULL
		       ,X_ProjFunc_Bill_Amount                  =>NULL
		       ,X_ProjFunc_Rev_Rate_date                =>NULL
		       ,X_Projfunc_Rev_Exchange_Rate            =>NULL
		       ,X_ProjFunc_Revenue_Amount               =>NULL
		       ,X_Funding_Rate_Type                     =>p_event_in_rec.P_funding_rate_type
		       ,X_Funding_Rate_date                     =>p_event_in_rec.P_funding_rate_date
		       ,X_Funding_Exchange_Rate                 =>p_event_in_rec.P_funding_exchange_rate
		       ,X_Invproc_Currency_Code                 =>l_invproc_currency_code
		       ,X_Invproc_Rate_Type                     =>l_invproc_rate_type
		       ,X_Invproc_Rate_date                     =>l_invproc_rate_date
		       ,X_Invproc_Exchange_Rate                 =>l_invproc_exchange_rate
		       ,X_Revproc_Currency_Code                 =>l_revproc_currency_code
		       ,X_Revproc_Rate_Type                     =>l_revproc_rate_type
		       ,X_Revproc_Rate_date                     =>l_revproc_rate_date
		       ,X_Revproc_Exchange_Rate                 =>l_revproc_exchange_rate
		       ,X_Inv_Gen_Rejection_Code                =>NULL
		       ,X_Adjusting_Revenue_Flag                =>p_event_in_rec.P_adjusting_revenue_flag
		       ,X_inventory_org_id			=>p_inv_org_id
		       ,X_inventory_item_id			=>p_event_in_rec.P_inventory_item_id
		       ,X_quantity_billed		        =>p_event_in_rec.P_quantity_billed
                       ,X_uom_code		                =>p_event_in_rec.P_uom_code
           		,X_unit_price		                =>p_event_in_rec.P_unit_price
			,X_reference1		                =>p_event_in_rec.P_reference1
			,X_reference2		                =>p_event_in_rec.P_reference2
			,X_reference3		                =>p_event_in_rec.P_reference3
			,X_reference4		                =>p_event_in_rec.P_reference4
			,X_reference5		                =>p_event_in_rec.P_reference5
			,X_reference6		                =>p_event_in_rec.P_reference6
			,X_reference7		                =>p_event_in_rec.P_reference7
			,X_reference8		                =>p_event_in_rec.P_reference8
			,X_reference9		                =>p_event_in_rec.P_reference9
			,X_reference10		                =>p_event_in_rec.P_reference10
			,X_Deliverable_Id		        =>p_event_in_rec.P_deliverable_id
			,X_Action_Id		                =>p_event_in_rec.P_action_id
			,X_Record_Version_Number	        => 1
                        ,X_Agreement_Id                         =>p_agreement_id);  -- Fedral Uptake

	--If commit is set to true then commit to database.
	    IF FND_API.to_boolean( p_commit )
	    THEN
		COMMIT;
	    END IF;

	    EXCEPTION
		WHEN FND_API.G_EXC_ERROR
			THEN
			ROLLBACK TO create_event;
			l_return_status := FND_API.G_RET_STS_ERROR;

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR
			THEN
			ROLLBACK TO create_event;
			l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                WHEN pa_event_pvt.pub_excp
                        THEN
                        ROLLBACK TO create_event;
			l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			PA_EVENT_PUB.PACKAGE_NAME
			:='(Event Reference='||p_event_in_rec.p_pm_event_reference||')'||PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
			PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CREATE_EVENT';

			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
			PACKAGE_NAME:=NULL;
			PROCEDURE_NAME:=NULL;
			END IF;

		WHEN OTHERS
			THEN
			ROLLBACK TO create_event;
			l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                PA_EVENT_PUB.PACKAGE_NAME
		:='(Event Reference='||p_event_in_rec.p_pm_event_reference||')'||PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CREATE_EVENT';

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
                PACKAGE_NAME:=NULL;
                PROCEDURE_NAME:=NULL;
                END IF;

	   END;		--end of Inner Block

   --Populating the output table
   p_event_out_tbl(tot_out_rec).pm_event_reference := p_event_in_rec.p_pm_event_reference;
   p_event_out_tbl(tot_out_rec).Event_Id           := p_event_in_rec.P_event_id;
   p_event_out_tbl(tot_out_rec).Return_status      := P_return_status;
   tot_out_rec := tot_out_rec + 1;
   tot_in_rec := p_event_in_tbl.next(tot_in_rec);

   pa_debug.reset_err_stack; -- Reset error stack
   END LOOP;    -- End of loop


   --Setting the return status to false even if one record fails the validation.
   p_return_status := l_return_status;

   --Extracting and returning error message if message count is 1.
   FND_MSG_PUB.Count_And_Get
	( p_encoded           =>      l_encoded
	 ,p_count             =>      p_msg_count
	 ,p_data              =>      p_msg_data      );


EXCEPTION
        WHEN FND_API.G_EXC_ERROR
           THEN
                p_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                        ( p_encoded           =>      l_encoded
       			 ,p_count             =>      p_msg_count
                         ,p_data              =>      p_msg_data      );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
           THEN
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                        ( p_encoded           =>      l_encoded
                         ,p_count             =>      p_msg_count
                         ,p_data              =>      p_msg_data      );

        WHEN pa_event_pvt.pub_excp
           THEN
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                PA_EVENT_PUB.PACKAGE_NAME
                :='(event_reference='||p_event_in_rec.p_pm_event_reference||')'||PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'CREATE_EVENT';

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
                PACKAGE_NAME:=NULL;
                PROCEDURE_NAME:=NULL;
                END IF;

                FND_MSG_PUB.Count_And_Get
                        ( p_encoded           =>      l_encoded
                         ,p_count             =>      p_msg_count
                         ,p_data              =>      p_msg_data      );

        WHEN OTHERS
           THEN
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		PA_EVENT_PUB.PACKAGE_NAME
		:='(event_reference='||p_event_in_rec.p_pm_event_reference||')'||PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CREATE_EVENT';

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
                PACKAGE_NAME:=NULL;
                PROCEDURE_NAME:=NULL;
                END IF;

                FND_MSG_PUB.Count_And_Get
                        ( p_encoded           =>      l_encoded
                         ,p_count             =>      p_msg_count
                         ,p_data              =>      p_msg_data      );

END create_event;
-- ============================================================================
--
--Name:               update_event
--Type:               procedure
--Description: This API updates an existing event or a set of existing events
--
--Called subprograms: PA_EVENT_PVT.CHECK_MDTY_PARAMS1
--                    PA_EVENT_PVT.CHECK_MDTY_PARAMS2
--		      PA_EVENT_PVT.check_update_event_ok
--                    PA_EVENT_PVT.VALIDATE_FLEXFIELD
--                    pa_events_pkg.update_row
--
--
--
--History:

-- ============================================================================

PROCEDURE UPDATE_EVENT
       ( p_api_version_number	IN	NUMBER
	,p_commit		IN	VARCHAR2
	,p_init_msg_list	IN	VARCHAR2
	,p_pm_product_code	IN	VARCHAR2
	,p_event_in_tbl		IN	Event_In_Tbl_Type
	,p_event_out_tbl	OUT	NOCOPY Event_Out_Tbl_Type --File.Sql.39 bug 4440895
        ,p_msg_count            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,p_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,p_return_status        OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

Cursor chk_proj_curs(P_project_number	VARCHAR2)
Is
          Select project_id
          From   pa_projects_all
          Where  segment1 = P_project_number;

p_inv_org_id			pa_events.inventory_item_id%type;
P_project_id                    pa_events.project_id%type;
l_project_id			pa_projects_all.project_id%type;
P_task_id                       pa_events.task_id%type;
l_task_id                       pa_events.task_id%type;
P_Organization_Id               pa_projects_all.org_id%type;
l_event_type_classification     pa_event_types.event_type_classification%type;
P_agreement_id                  pa_events.agreement_id%type;      -- Federal Uptake

P_event_id_out			pa_events.event_id%type;
Rowid				VARCHAR2(18);
p_event_in_rec                  Event_Rec_In_Type;
p_event_out_rec                 Event_Rec_Out_Type;
tot_in_rec			NUMBER:=0;
tot_out_rec                     NUMBER:=0;
p_api_name                      VARCHAR2(100):='UPDATE_EVENT';
p_return_msg			VARCHAR2(2000);
p_validate_status		VARCHAR2(1):='Y';
l_bill_trans_curr_code                  pa_events.Bill_Trans_Currency_Code%type;
l_project_currency_code			pa_events.Project_currency_code%type;
l_Project_Inv_Exchange_Rate		pa_events.Project_Inv_Exchange_Rate%type;
l_Project_Bill_Amount		        pa_events.Project_Bill_Amount%type;
l_Project_Rev_Rate_date		        pa_events.Project_Rev_Rate_date%type;
l_Project_Rev_Exchange_Rate		pa_events.Project_Rev_Exchange_Rate%type;
l_Project_Revenue_Amount		pa_events.Project_Revenue_Amount%type;
l_ProjFunc_Currency_Code		pa_events.ProjFunc_Currency_Code%type;
l_ProjFunc_Inv_Rate_date		pa_events.ProjFunc_Inv_Rate_date%type;
l_ProjFunc_Inv_Exchange_Rate		pa_events.ProjFunc_Inv_Exchange_Rate%type;
l_ProjFunc_Bill_Amount		        pa_events.ProjFunc_Bill_Amount%type;
l_ProjFunc_Rev_Rate_date		pa_events.ProjFunc_Rev_Rate_date%type;
l_Projfunc_Rev_Exchange_Rate		pa_events.Projfunc_Rev_Exchange_Rate%type;
l_ProjFunc_Revenue_Amount		pa_events.ProjFunc_Revenue_Amount%type;
l_Invproc_Currency_Code		        pa_events.Invproc_Currency_Code%type;
l_Invproc_Rate_Type		        pa_events.Invproc_Rate_Type%type;
l_Invproc_Rate_date		        pa_events.Invproc_Rate_date%type;
l_Invproc_Exchange_Rate		        pa_events.Invproc_Exchange_Rate%type;
l_Revproc_Currency_Code		        pa_events.Revproc_Currency_Code%type;
l_Revproc_Rate_Type		        pa_events.Revproc_Rate_Type%type;
l_Revproc_Rate_date		        pa_events.Revproc_Rate_date%type;
l_revproc_exchange_rate		        pa_events.revproc_exchange_rate%type;
l_Inv_Gen_Rejection_Code		pa_events.Inv_Gen_Rejection_Code%type;
l_project_bil_rate_date_code      	pa_projects_all.project_bil_rate_date_code%type;
l_projfunc_bil_rate_date_code     	pa_projects_all.projfunc_bil_rate_date_code%type;
l_multi_currency_billing_flag     	pa_projects_all.multi_currency_billing_flag%type;
l_project_bil_rate_type			pa_events.project_rate_type%type;
l_project_bil_rate_date			pa_events.project_rate_date%type;
l_project_bil_exchange_rate		pa_events.project_exchange_rate%type;
l_projfunc_bil_rate_type		pa_events.projfunc_rate_type%type;
l_projfunc_bil_rate_date		pa_events.projfunc_rate_date%type;
L_PROJFUNC_BIL_EXCHANGE_RATE		pa_events.PROJFUNC_EXCHANGE_RATE%type;
L_FUNDING_RATE_TYPE			pa_events.FUNDING_RATE_TYPE%type;
L_FUNDING_RATE_DATE			pa_events.FUNDING_RATE_DATE%type;
L_FUNDING_EXCHANGE_RATE			pa_events.FUNDING_EXCHANGE_RATE%type;
l_bill_trans_rev_amt                    pa_events.bill_trans_rev_amount%type;
l_bill_trans_bill_amt                   pa_events.bill_trans_bill_amount%type;
l_description				pa_events.description%type;
l_bill_hold_flag 			pa_events.bill_hold_flag%type;
L_adjusting_revenue_flag		pa_events.adjusting_revenue_flag%type;
l_inventory_org_id			pa_events.inventory_org_id%type;
l_inventory_item_id			pa_events.inventory_item_id%type;
l_organization_id			pa_events.organization_id%type;
l_funding_rate_date_code          pa_projects_all.funding_rate_date_code%TYPE;
l_encoded                         	varchar2(1):='F';
l_return_status 			varchar2(1):= FND_API.G_RET_STS_SUCCESS;
l_record_version_number                 pa_events.record_version_number%TYPE;

/* Added for bug 7110782 */
l_event_processed           varchar2(1) := 'N';
l_bill_amount               pa_events.bill_amount%type;
l_revenue_amount            pa_events.revenue_amount%type;
l_revenue_distributed_flag  pa_events.revenue_distributed_flag%type;
l_rev_dist_rejection_code   pa_events.rev_dist_rejection_code%type;
l_Billing_Assignment_Id     pa_events.Billing_Assignment_Id%type;
l_Event_Num_Reversed        pa_events.Event_Num_Reversed%type;
l_Calling_Place             pa_events.Calling_Place%type;
l_Calling_Process           pa_events.Calling_Process%type;
/* Added for bug 7110782 */

BEGIN

  -- Initialize the Error Stack
  pa_debug.set_err_stack('PA_EVENT_PUB.UPDATE_EVENT');

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.UPDATE_EVENT.begin'
                     ,x_msg         => 'Beginning of Update Event'
                     ,x_log_level   => 5);
   END IF;

      p_msg_count := 0;
      p_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.UPDATE_EVENT.begin'
                     ,x_msg         => 'Calling  mandatory input parameters-1'
                     ,x_log_level   => 5);
   END IF;

-- Validating mandatory input parameters-1

   PA_EVENT_PVT.check_mdty_params1
    ( p_api_version_number             =>p_api_version_number
     ,p_api_name                       =>p_api_name
     ,p_pm_product_code                =>p_pm_product_code
     ,p_function_name                  =>'PA_EV_UPDATE_EVENT'
     ,x_return_status                  =>p_return_status
     ,x_msg_count                      =>p_msg_count
     ,x_msg_data                       =>p_msg_data );


   If p_return_status <> FND_API.G_RET_STS_SUCCESS
   Then
        IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF p_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
   End If;

   tot_in_rec := p_event_in_tbl.first;
   while tot_in_rec is not null loop   -- loop begins
-- For all date variables using trunc instead of ltrim(rtrim)for bug 3053669
P_event_in_rec.P_pm_event_reference             :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_pm_event_reference));
P_event_in_rec.P_task_number                    :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_task_number));
P_event_in_rec.P_event_number                   :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_event_number));
P_event_in_rec.P_event_type                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_event_type));
-- Added the below three lines for Federal Uptake
P_event_in_rec.P_agreement_number               :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_agreement_number));
P_event_in_rec.P_agreement_type                 :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_agreement_type));
P_event_in_rec.P_customer_number                :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_customer_number));
P_event_in_rec.P_description                    :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_description));
P_event_in_rec.P_bill_hold_flag                 :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_bill_hold_flag));
P_event_in_rec.P_completion_date                :=trunc(p_event_in_tbl(tot_in_rec).P_completion_date);
P_event_in_rec.P_desc_flex_name                 :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_desc_flex_name));
P_event_in_rec.P_attribute_category             :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute_category));
P_event_in_rec.P_attribute1                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute1));
P_event_in_rec.P_attribute2                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute2));
P_event_in_rec.P_attribute3                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute3));
P_event_in_rec.P_attribute4                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute4));
P_event_in_rec.P_attribute5                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute5));
P_event_in_rec.P_attribute6                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute6));
P_event_in_rec.P_attribute7                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute7));
P_event_in_rec.P_attribute8                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute8));
P_event_in_rec.P_attribute9                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute9));
P_event_in_rec.P_attribute10                    :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_attribute10));
P_event_in_rec.P_project_number                 :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_project_number));
P_event_in_rec.P_organization_name              :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_organization_name));
P_event_in_rec.P_inventory_org_name             :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_inventory_org_name));
P_event_in_rec.P_inventory_item_id              :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_inventory_item_id));
P_event_in_rec.P_quantity_billed                :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_quantity_billed));
P_event_in_rec.P_uom_code                       :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_uom_code));
P_event_in_rec.P_unit_price                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_unit_price));
P_event_in_rec.P_reference1                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference1));
P_event_in_rec.P_reference2                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference2));
P_event_in_rec.P_reference3                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference3));
P_event_in_rec.P_reference4                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference4));
P_event_in_rec.P_reference5                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference5));
P_event_in_rec.P_reference6                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference6));
P_event_in_rec.P_reference7                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference7));
P_event_in_rec.P_reference8                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference8));
P_event_in_rec.P_reference9                     :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference9));
P_event_in_rec.P_reference10                    :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_reference10));
P_event_in_rec.P_bill_trans_currency_code       :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_bill_trans_currency_code));
P_event_in_rec.P_bill_trans_bill_amount         :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_bill_trans_bill_amount));
P_event_in_rec.P_bill_trans_rev_amount          :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_bill_trans_rev_amount));
P_event_in_rec.P_project_rate_type              :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_project_rate_type));
P_event_in_rec.P_project_rate_date              :=trunc(p_event_in_tbl(tot_in_rec).P_project_rate_date);
P_event_in_rec.P_project_exchange_rate          :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_project_exchange_rate));
P_event_in_rec.P_projfunc_rate_type             :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_projfunc_rate_type));
P_event_in_rec.P_projfunc_rate_date             :=trunc(p_event_in_tbl(tot_in_rec).P_projfunc_rate_date);
P_event_in_rec.P_projfunc_exchange_rate         :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_projfunc_exchange_rate));
P_event_in_rec.P_funding_rate_type              :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_funding_rate_type));
P_event_in_rec.P_funding_rate_date              :=trunc(p_event_in_tbl(tot_in_rec).P_funding_rate_date);
P_event_in_rec.P_funding_exchange_rate          :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_funding_exchange_rate));
P_event_in_rec.P_adjusting_revenue_flag         :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_adjusting_revenue_flag));
P_event_in_rec.P_event_id                       :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_event_id));
P_event_in_rec.P_deliverable_id                 :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_deliverable_id));
P_event_in_rec.P_action_id                      :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_action_id));
P_event_in_rec.P_context                        :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_context));
P_event_in_rec.P_Record_Version_Number          :=ltrim(rtrim(p_event_in_tbl(tot_in_rec).P_record_version_number));

   BEGIN	--Start of Inner Block

	--Set savepoint
	   Savepoint Update_event;

          --Log Message
          IF l_debug_mode = 'Y' THEN
          pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.UPDATE_EVENT.begin'
                             ,x_msg         => ' Calling mandatory input parameters-2'
                             ,x_log_level   => 5);
          END IF;

	-- Validating mandatory input parameters-2
/*Commenting out this call as the event reference is not a mandatory parameter.bug 3118781
	   PA_EVENT_PVT.CHECK_MDTY_PARAMS2
	   (  p_pm_event_reference    => p_event_in_rec.p_pm_event_reference
	     ,p_pm_product_code       => p_pm_product_code
	     ,p_project_number        => p_event_in_rec.p_project_number
	     ,p_event_type            => p_event_in_rec.p_event_type
	     ,p_organization_name     => p_event_in_rec.p_organization_name
	     ,p_calling_place         => 'UPDATE_EVENT'
	     ,x_return_status         => p_return_status );

	   If p_return_status <> FND_API.G_RET_STS_SUCCESS
	   Then
		IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR
		THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		ELSIF p_return_status = FND_API.G_RET_STS_ERROR
		THEN
				RAISE FND_API.G_EXC_ERROR;
		END IF;
	   End If;
End of comment for 3118781*/
          --Log Message
          IF l_debug_mode = 'Y' THEN
          pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.UPDATE_EVENT.begin'
                             ,x_msg         => 'Calling conv_event_ref_to_id'
                             ,x_log_level   => 5);
          END IF;

	--Call to validate the event_id or convert the event reference to event_id.
	--If the validation fails then terminate further validation for this record.
	  If PA_EVENT_PVT.CONV_EVENT_REF_TO_ID
		(P_pm_product_code      =>P_pm_product_code
		,P_pm_event_reference   =>p_event_in_rec.P_pm_event_reference
		,P_event_id             =>p_event_in_rec.P_event_id)
		='N'
	  Then
		p_return_status             := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	  End If;

	--Deriving the project_id using the event_reference and product_code
	  Select project_id, record_version_number
	  Into P_project_id, p_event_in_rec.P_record_version_number
	  From pa_events
	  Where event_id = p_event_in_rec.P_event_id;


	--Deriving the project_id using the project_number if provided.
	  Open chk_proj_curs(p_event_in_rec.P_project_number);
	  Fetch chk_proj_curs Into l_project_id;
	  Close chk_proj_curs;


	--validation to be done only if project number is provided.
	If (P_project_id <> nvl(l_project_id,P_project_id))
	Then
	        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_EV_REF_PROJ_MISS'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
		 END IF;
                 p_return_status             := FND_API.G_RET_STS_ERROR;
                 RAISE FND_API.G_EXC_ERROR;
	End If;

          --Log Message
          IF l_debug_mode = 'Y' THEN
          pa_debug.write_log (x_module      =>'pa.plsql.PA_EVENT_PUB.UPDATE_EVENT.begin'
                             ,x_msg         =>'Defaulting currency from pa_events for the given event'
                             ,x_log_level   =>5);
          END IF;

	--Select default currency from pa_events for the given event
	--And use those for validations if the currency fields are not
	--overwritten by the new changes.
	Select   ev.Project_currency_code
		,ev.ProjFunc_Inv_Rate_date
		,ev.Project_Inv_Exchange_Rate
		,ev.Project_Bill_Amount
		,ev.Project_Rev_Rate_date
		,ev.Project_Rev_Exchange_Rate
		,ev.Project_Revenue_Amount
		,ev.Project_Rate_type
		,ev.Project_Rate_date
		,ev.Project_Exchange_rate
		,ev.ProjFunc_Currency_Code
		,ev.ProjFunc_Inv_Rate_date
		,ev.ProjFunc_Inv_Exchange_Rate
		,ev.ProjFunc_Bill_Amount
		,ev.ProjFunc_Rev_Rate_date
		,ev.Projfunc_Rev_Exchange_Rate
		,ev.ProjFunc_Revenue_Amount
		,ev.ProjFunc_Rate_type
		,ev.ProjFunc_Rate_date
		,ev.ProjFunc_Exchange_rate
		,ev.Invproc_Currency_Code
		,ev.Invproc_Rate_Type
		,ev.Invproc_Rate_date
		,ev.Invproc_Exchange_Rate
		,ev.Revproc_Currency_Code
		,ev.Revproc_Rate_Type
		,ev.Revproc_Rate_date
		,ev.revproc_exchange_rate
		,ev.Inv_Gen_Rejection_Code
		,ev.Funding_Rate_type
		,ev.Funding_Rate_date
		,ev.Funding_Exchange_rate
                ,ev.Bill_trans_currency_code
	Into   l_project_currency_code
		,l_ProjFunc_Inv_Rate_date
		,l_Project_Inv_Exchange_Rate
		,l_Project_Bill_Amount
		,l_Project_Rev_Rate_date
		,l_Project_Rev_Exchange_Rate
		,l_Project_Revenue_Amount
		,l_project_bil_rate_type
		,l_project_bil_rate_date
		,l_project_bil_exchange_rate
		,l_ProjFunc_Currency_Code
		,l_ProjFunc_Inv_Rate_date
		,l_ProjFunc_Inv_Exchange_Rate
		,l_ProjFunc_Bill_Amount
		,l_ProjFunc_Rev_Rate_date
		,l_Projfunc_Rev_Exchange_Rate
		,l_ProjFunc_Revenue_Amount
		,l_projfunc_bil_rate_type
		,l_projfunc_bil_rate_date
		,l_projfunc_bil_exchange_rate
		,l_Invproc_Currency_Code
		,l_Invproc_Rate_Type
		,l_Invproc_Rate_date
		,l_Invproc_Exchange_Rate
		,l_Revproc_Currency_Code
		,l_Revproc_Rate_Type
		,l_Revproc_Rate_date
		,l_revproc_exchange_rate
		,l_Inv_Gen_Rejection_Code
		,l_funding_rate_type
		,l_funding_rate_date
		,l_funding_exchange_rate
                ,l_bill_trans_curr_code
	  From  pa_events ev
	 Where  event_id=p_event_in_rec.p_event_id;

	Select  multi_currency_billing_flag
	       ,funding_rate_date_code
	       ,project_bil_rate_date_code
	       ,projfunc_bil_rate_date_code
	  Into l_multi_currency_billing_flag
                ,l_funding_rate_date_code
	       ,l_project_bil_rate_date_code
	       ,l_projfunc_bil_rate_date_code
	  From  pa_projects_all
	 Where  project_id=P_project_id;


          --Log Message
          IF l_debug_mode = 'Y' THEN
          pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.UPDATE_EVENT.begin'
                             ,x_msg         => 'Calling check_update_event_ok'
                             ,x_log_level   => 5);
          END IF;

	-- Calls check_update_event_ok function
	   If PA_EVENT_PVT.check_update_event_ok
		(P_pm_product_code              =>p_pm_product_code
		,P_event_in_rec                 =>p_event_in_rec
		,P_project_currency_code        =>l_project_currency_code
		,P_proj_func_currency_code      =>l_projfunc_currency_code
		,P_project_bil_rate_date_code   =>l_project_bil_rate_date_code
		,P_project_rate_type            =>l_project_bil_rate_type
		,p_project_bil_rate_date	=>l_project_bil_rate_date
		,p_projfunc_bil_rate_date_code  =>l_projfunc_bil_rate_date_code
		,P_projfunc_rate_type           =>l_projfunc_bil_rate_type
		,p_projfunc_bil_rate_date	=>l_projfunc_bil_rate_date
		,P_funding_rate_type		=>l_funding_rate_type
		,P_multi_currency_billing_flag  =>l_multi_currency_billing_flag
		,P_event_type_classification    =>l_event_type_classification
		,P_event_processed      =>l_event_processed  /* Added for bug Bug 7110782 */
                ,p_project_id                   =>p_project_id
                ,p_projfunc_bil_exchange_rate   =>l_projfunc_bil_exchange_rate -- Added for bug 3013137
                ,p_funding_bill_rate_date_code   =>l_funding_rate_date_code --Added for bug 3053190
                ,x_task_id                      =>p_task_id
                ,x_organization_id              =>p_organization_id
		,x_inv_org_id			=>p_inv_org_id
                ,x_agreement_id                 =>P_agreement_id  -- Federal Uptake
		 ) = 'N'
	   Then
		p_return_status             := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;

	   End If;

          --Log Message
          IF l_debug_mode = 'Y' THEN
          pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.UPDATE_EVENT.begin'
                             ,x_msg         => 'Beginning Validate Flexfields'
                             ,x_log_level   => 5);
          END IF;

	--Validating Flexfields
	   IF (p_event_in_rec.p_desc_flex_name IS NOT NULL)
	       AND (p_event_in_rec.p_desc_flex_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
	   THEN
		   PA_EVENT_PVT.VALIDATE_FLEXFIELD
			( p_desc_flex_name        => p_event_in_rec.p_desc_flex_name
			 ,p_attribute_category    => p_event_in_rec.p_attribute_category
			 ,p_attribute1            => p_event_in_rec.p_attribute1
			 ,p_attribute2            => p_event_in_rec.p_attribute2
			 ,p_attribute3            => p_event_in_rec.p_attribute3
			 ,p_attribute4            => p_event_in_rec.p_attribute4
			 ,p_attribute5            => p_event_in_rec.p_attribute5
			 ,p_attribute6            => p_event_in_rec.p_attribute6
			 ,p_attribute7            => p_event_in_rec.p_attribute7
			 ,p_attribute8            => p_event_in_rec.p_attribute8
			 ,p_attribute9            => p_event_in_rec.p_attribute9
			 ,p_attribute10           => p_event_in_rec.p_attribute10
			 ,p_return_msg            => p_return_msg
			 ,p_valid_status       => p_validate_status);
		     IF p_validate_status = 'N'
		     THEN
			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
				pa_interface_utils_pub.map_new_amg_msg
					( p_old_message_code => 'PA_INVALID_FF_VALUES'
					,p_msg_attribute    => 'CHANGE'
					,p_resize_flag      => 'N'
					,p_msg_context      => 'EVENT'
					,p_attribute1       => p_event_in_rec.p_pm_event_reference
					,p_attribute2       => ''
					,p_attribute3       => ''
					,p_attribute4       => ''
					,p_attribute5       => '');
			END IF;
			p_return_status             := FND_API.G_RET_STS_ERROR;
			RAISE FND_API.G_EXC_ERROR;
		      END IF;
                --Defaulting attribute categories.
                Select   decode(p_event_in_rec.P_attribute_category
                                        ,NULL,attribute_category
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_attribute_category)
                        ,decode(p_event_in_rec.P_attribute1
                                        ,NULL,attribute1
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_attribute1)
                        ,decode(p_event_in_rec.P_attribute2
                                        ,NULL,attribute2
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_attribute2)
                        ,decode(p_event_in_rec.P_attribute3
                                        ,NULL,attribute3
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_attribute3)
                        ,decode(p_event_in_rec.P_attribute4
                                        ,NULL,attribute4
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_attribute4 )
                        ,decode(p_event_in_rec.P_attribute5
                                        ,NULL,attribute5
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_attribute5 )
                        ,decode(p_event_in_rec.P_attribute6
                                        ,NULL,attribute6
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_attribute6 )
                        ,decode(p_event_in_rec.P_attribute7
                                        ,NULL,attribute7
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_attribute7 )
                        ,decode(p_event_in_rec.P_attribute8
                                        ,NULL,attribute8
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_attribute8 )
                        ,decode(p_event_in_rec.P_attribute9
                                        ,NULL,attribute9
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_attribute9 )
                        ,decode(p_event_in_rec.P_attribute10
                                        ,NULL,attribute10
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_attribute10 )
		  Into   p_event_in_rec.P_attribute_category
                        ,p_event_in_rec.P_attribute1
                        ,p_event_in_rec.P_attribute2
                        ,p_event_in_rec.P_attribute3
                        ,p_event_in_rec.P_attribute4
                        ,p_event_in_rec.P_attribute5
                        ,p_event_in_rec.P_attribute6
                        ,p_event_in_rec.P_attribute7
                        ,p_event_in_rec.P_attribute8
                        ,p_event_in_rec.P_attribute9
                        ,p_event_in_rec.P_attribute10
                  From   pa_events
                  Where  event_id=p_event_in_rec.P_event_id;

             Else
                        p_event_in_rec.P_desc_flex_name         :=NULL;
                        p_event_in_rec.P_attribute_category     :=NULL;
                        p_event_in_rec.P_attribute1             :=NULL;
                        p_event_in_rec.P_attribute2             :=NULL;
                        p_event_in_rec.P_attribute3             :=NULL;
                        p_event_in_rec.P_attribute4             :=NULL;
                        p_event_in_rec.P_attribute5             :=NULL;
                        p_event_in_rec.P_attribute6             :=NULL;
                        p_event_in_rec.P_attribute7             :=NULL;
                        p_event_in_rec.P_attribute8             :=NULL;
                        p_event_in_rec.P_attribute9             :=NULL;
                        p_event_in_rec.P_attribute10            :=NULL;
	     END IF;

          --Log Message
          IF l_debug_mode = 'Y' THEN
          pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.UPDATE_EVENT.begin'
                             ,x_msg         => 'Beginning defaulting mcb parameters'
                             ,x_log_level   => 5);
          END IF;


        --Before defaulting the mcb related paramaters validating
        --if the User has overwritten any of the fields.
        If (l_multi_currency_billing_flag = 'Y')
        Then
        --validating and defaulting bill transaction currency code
                  If (p_event_in_rec.P_bill_trans_currency_code Is NULL
                     OR p_event_in_rec.P_bill_trans_currency_code=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
                  Then
                        p_event_in_rec.P_bill_trans_currency_code:=l_bill_trans_curr_code; /* 3013117 */
                  End If;

        --funding rate,date and type validations
                If(p_event_in_rec.P_funding_rate_type Is NULL
                        OR p_event_in_rec.P_funding_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
                   Then
                        p_event_in_rec.P_funding_rate_type:=l_funding_rate_type;
                End If;

                If (l_funding_rate_date_code = 'FIXED_DATE')
                Then
                        If(p_event_in_rec.P_funding_rate_date Is NULL
                           OR p_event_in_rec.P_funding_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
                        Then
                              p_event_in_rec.P_funding_rate_date:=l_funding_rate_date;
                        End If;
                Else
                     --Commented for bug3013236
                     --p_event_in_rec.P_funding_rate_date:=l_funding_rate_date;
                     --Added for bug3013236
                        If(p_event_in_rec.P_funding_rate_date Is NULL
                           OR p_event_in_rec.P_funding_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
                        Then
                             p_event_in_rec.P_funding_rate_date:=l_funding_rate_date;
                        End If;
                     --till here for Bug3013236
                End If;

                --If fund rate type is User then only take the exchange rate from User
                --else default it from the project level.
/*  The following part of the code is commented out and rewritten at the bottom. for bug 3045302

                If (p_event_in_rec.P_funding_rate_type <>l_funding_rate_type)
                Then
                        If ( p_event_in_rec.P_funding_rate_type <> 'User' )
                        Then
                                p_event_in_rec.P_funding_exchange_rate :=NULL;
                        Else
                           If(p_event_in_rec.P_funding_exchange_rate Is NULL
                               OR p_event_in_rec.P_funding_exchange_rate =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                           Then
                                p_event_in_rec.P_funding_exchange_rate:=l_funding_exchange_rate;
                           End If;
                           p_event_in_rec.P_funding_rate_date := null; --Added for Bug3010927
                        End If;
                Else
                        If(p_event_in_rec.P_funding_rate_type = 'User'
                          AND (p_event_in_rec.P_funding_exchange_rate Is NULL
                              OR p_event_in_rec.P_funding_exchange_rate =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
                        Then
                                p_event_in_rec.P_funding_exchange_rate :=l_funding_exchange_rate;
                        --Added for Bug3013256
                        Else
                             IF ( p_event_in_rec.P_funding_rate_type <> 'User' )
                             Then
                                p_event_in_rec.P_funding_exchange_rate := null;
                             End If;
                        --till here for Bug3013256
                        End If;
                        p_event_in_rec.p_funding_rate_date := null; --Added for Bug3010927
                End If;
End of commenting  for Bug  3045302  */
/*This is the code added for bug 3045302.*/
                   If  ( p_event_in_rec.P_funding_rate_type <> 'User' )
                         Then
                                 p_event_in_rec.P_funding_exchange_rate :=NULL;
                   Else
                         If (p_event_in_rec.P_funding_exchange_rate Is NULL
                               OR p_event_in_rec.P_funding_exchange_rate =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                            Then
                                   p_event_in_rec.P_funding_exchange_rate:=l_funding_exchange_rate;
                         End If;
                      p_event_in_rec.P_funding_rate_date := null;
                 End If;
/*End of code added for bug 3045302  */
/*The code for validation of project currency attributes has been moved
  below the code for validation of project functional attributes
  for bug     3045302   */

        --project functional rate,date,type validaions
                If (p_event_in_rec.P_bill_trans_currency_code =  l_projfunc_currency_code )
                Then
                        p_event_in_rec.P_projfunc_rate_type	:=NULL;
                        p_event_in_rec.P_projfunc_rate_date	:=NULL;
                        p_event_in_rec.P_projfunc_exchange_rate	:=NULL;
                Else   ---validtions if project functional currency and bill trans currency are different.
                        If(p_event_in_rec.P_projfunc_rate_type Is NULL
                                OR p_event_in_rec.P_projfunc_rate_type=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
                           Then
                                p_event_in_rec.P_projfunc_rate_type:=l_projfunc_bil_rate_type;
                        End If;

                        If (l_projfunc_bil_rate_date_code= 'FIXED_DATE')
                        Then
                                If(p_event_in_rec.P_projfunc_rate_date Is NULL
                                        OR p_event_in_rec.P_projfunc_rate_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
                                   Then
                                        p_event_in_rec.P_projfunc_rate_date:=l_projfunc_bil_rate_date;
                                End If;
			Else
                            --Commented for Bug3013236
                	    --     p_event_in_rec.P_projfunc_rate_date:=l_projfunc_bil_rate_date;
                            --Added for Bug3013236
                                If(p_event_in_rec.P_projfunc_rate_date Is NULL
                                        OR p_event_in_rec.P_projfunc_rate_date=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
                                   Then
                                        p_event_in_rec.P_projfunc_rate_date:=l_projfunc_bil_rate_date;
                                End If;
                            --till here for Bug3013236
                        End If;

                       If(p_event_in_rec.P_projfunc_rate_type <> l_projfunc_bil_rate_type)
                       Then
                                If ( p_event_in_rec.P_projfunc_rate_type <> 'User' )
                                Then
                                        p_event_in_rec.P_projfunc_exchange_rate:=NULL;
                                Else
                                     If (p_event_in_rec.P_projfunc_exchange_rate Is NULL
                                         OR p_event_in_rec.P_projfunc_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                                     Then
                                           p_event_in_rec.P_projfunc_exchange_rate:=l_projfunc_bil_exchange_rate;
                                     End If;
                                  p_event_in_rec.P_projfunc_rate_date := null; --Added for Bug3010927
                                End If;
                        Else
                                If(p_event_in_rec.P_projfunc_rate_type = 'User')
                                Then
                                  If (p_event_in_rec.P_projfunc_exchange_rate Is NULL
                                      OR p_event_in_rec.P_projfunc_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                                  Then
                                        p_event_in_rec.P_projfunc_exchange_rate:=l_projfunc_bil_exchange_rate;
                                  End If;
                                  p_event_in_rec.P_projfunc_rate_date := null; --Added for Bug3010927
                                Else
                                  --Commented for Bug3013256
                                  --p_event_in_rec.P_projfunc_exchange_rate:=l_projfunc_bil_exchange_rate;
                                    p_event_in_rec.P_projfunc_exchange_rate:=null; --Added for Bug3013256
                                End If;
                        End If;
                End If;
  --project rate,date and type validations
  --For bug 3045302.Changed the logic to default the project currency attributes
  --from the project functional currency if project currency is same as project functional currency.
                If (p_event_in_rec.P_bill_trans_currency_code = l_project_currency_code)
                Then
                        p_event_in_rec.P_project_rate_type	:=NULL;
                        p_event_in_rec.P_project_rate_date	:=NULL;
                        p_event_in_rec.P_project_exchange_rate	:=NULL;

                Elsif (l_project_currency_code = l_projfunc_currency_code )
                Then
                        p_event_in_rec.P_project_rate_type	    := p_event_in_rec.P_projfunc_rate_type;
                        p_event_in_rec.P_project_rate_date	    := p_event_in_rec.P_projfunc_rate_date;
                        p_event_in_rec.P_project_exchange_rate  := p_event_in_rec.P_projfunc_exchange_rate;

                 Else
                ---validations if project currency and bill trans currency are different.
                        If(p_event_in_rec.P_project_rate_type Is NULL
                                OR p_event_in_rec.P_project_rate_type =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
                          Then
                                p_event_in_rec.P_project_rate_type:=l_project_bil_rate_type;
                        End If;

                        If (l_project_bil_rate_date_code = 'FIXED_DATE')
                        Then
                                If(p_event_in_rec.P_project_rate_date Is NULL
                                    OR p_event_in_rec.P_project_rate_date =PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
                                   Then
                                        p_event_in_rec.P_project_rate_date:=l_project_bil_rate_date;
                                End If;
                        Else
                        --Commented for Bug3013236
                        --p_event_in_rec.P_project_rate_date:=l_project_bil_rate_date;
                        --Added for Bug3013236
                                If(p_event_in_rec.P_project_rate_date Is NULL
                                    OR p_event_in_rec.P_project_rate_date =PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
                                   Then
                                        p_event_in_rec.P_project_rate_date:=l_project_bil_rate_date;
                                End If;
                        --till here for Bug3013236
                        End If;

                       If (p_event_in_rec.P_project_rate_type<>l_project_bil_rate_type)
                        Then
                                If ( p_event_in_rec.P_project_rate_type <> 'User' )
                                Then
                                        p_event_in_rec.P_project_exchange_rate:=NULL;
                                Else
                                     If(p_event_in_rec.P_project_exchange_rate Is NULL
                                         OR p_event_in_rec.P_project_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                                     Then
                                           p_event_in_rec.P_project_exchange_rate:=l_project_bil_exchange_rate;
                                     End If;
                                  p_event_in_rec.P_project_rate_date := null;  --Added for Bug3010927
                                End If;
                        Else
                                If(p_event_in_rec.P_project_rate_type= 'User')
                                Then
                                  If(p_event_in_rec.P_project_exchange_rate Is NULL
                                      OR p_event_in_rec.P_project_exchange_rate=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                                  Then
                                        p_event_in_rec.P_project_exchange_rate:=l_project_bil_exchange_rate;
                                  End If;
                                  p_event_in_rec.P_project_rate_date := null;  --Added for Bug3010927
                                Else
                                  --Commented for Bug3013256
                                  --p_event_in_rec.P_project_exchange_rate:=l_project_bil_exchange_rate;
                                    p_event_in_rec.P_project_exchange_rate:=null; --Added for Bug3013256
                                End If;
                        End If;
                End If;

        Else
        --Defaulting the mcb columns when mcb is not enabled
                p_event_in_rec.P_project_rate_type:=l_project_bil_rate_type;
                p_event_in_rec.P_project_rate_date:=l_project_bil_rate_date;
                p_event_in_rec.P_project_exchange_rate:=l_project_bil_exchange_rate;

                p_event_in_rec.P_projfunc_rate_type:=l_projfunc_bil_rate_type;
                p_event_in_rec.P_projfunc_rate_date:=l_projfunc_bil_rate_date;
                p_event_in_rec.P_projfunc_exchange_rate:=l_projfunc_bil_exchange_rate;

                p_event_in_rec.P_funding_rate_type:=l_funding_rate_type;
                p_event_in_rec.P_funding_rate_date:=l_funding_rate_date;
                p_event_in_rec.P_funding_exchange_rate:=l_funding_exchange_rate;

		p_event_in_rec.P_bill_trans_currency_code:=l_projfunc_currency_code;
        End If;


	 --Log Message
          IF l_debug_mode = 'Y' THEN
          pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.UPDATE_EVENT.begin'
                             ,x_msg         => 'Beginning defaulting parameters before updating table'
                             ,x_log_level   => 5);
          END IF;


                -- Validating the event num.
		--If task number has been changed then generate new event_num
		--before inserting the record into pa_events.
		If (p_event_in_rec.P_event_number Is NULL
                        OR p_event_in_rec.P_event_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                Then
                   SELECT task_id
                   INTO   l_task_id
                   FROM   pa_events e
                   Where  event_id=p_event_in_rec.P_event_id;

		--Validating if the existing task_id matches with the updated task_id
		--In case of any mismatch new event_number is generated before updating the record.
		   If p_event_in_rec.p_task_number  is NOT NULL
		   Then
			If (nvl(P_task_id,-1) <> nvl(l_task_id,-1))
			Then
                          --generating event number for project level events
				  If (P_task_id Is NULL )
				  Then
					SELECT NVL(max(event_num),0)+1
					INTO P_event_in_rec.p_event_number
					FROM pa_events e
					WHERE e.project_id = P_project_id
					AND e.task_id IS NULL;
				  Else
				  --generating event number for task level events
					SELECT NVL(max(event_num),0)+1
					INTO P_event_in_rec.p_event_number
					FROM pa_events e
					WHERE e.project_id =P_project_id
					AND e.task_id    = P_task_id;
				  End If;
                        --If task number is the same defaulting the event number.
                        Else
                                        SELECT event_num
                                        INTO P_event_in_rec.p_event_number
                                        FROM pa_events e
                                        Where  event_id=p_event_in_rec.P_event_id;
                        End If;
                   Else
			SELECT event_num
			INTO P_event_in_rec.p_event_number
			FROM pa_events e
			Where  event_id=p_event_in_rec.P_event_id;
                   End If;  /* If p_event_in_rec.p_task_number  is NOT NULL */
		End If;  /* If event_num is null , '^' */

		--Populating the rowid
		  Select Rowid
		  Into rowid
		  From pa_events
		  Where event_id=p_event_in_rec.p_event_id;

		--Defaulting bill_hold_flag,adjusting_revenue_flag.
                  Select decode(p_event_in_rec.P_bill_hold_flag
					,NULL,BILL_HOLD_FLAG
					,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
					,p_event_in_rec.P_bill_hold_flag)
                        ,decode(p_event_in_rec.P_adjusting_revenue_flag
					,NULL,ADJUSTING_REVENUE_FLAG
					,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
					,p_event_in_rec.P_adjusting_revenue_flag)
		--Defaulting inventory org id and item ids
                        ,decode(p_event_in_rec.P_inventory_org_name
                                        ,NULL,inventory_org_id
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_inv_org_id)
                        ,decode(p_event_in_rec.P_inventory_item_id
                                        ,NULL,inventory_item_id
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,NULL
                                        ,p_event_in_rec.P_inventory_item_id)
		--Defaulting organization id.
                        ,decode(p_event_in_rec.P_organization_name
                                        ,NULL,organization_id
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,organization_id
                                        ,p_organization_id)
		--Defaulting OKE related fields.
                        ,decode(p_event_in_rec.P_quantity_billed
                                        ,NULL,quantity_billed
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,NULL
                                        ,p_event_in_rec.P_quantity_billed)
                        ,decode(p_event_in_rec.P_uom_code
                                        ,NULL,uom_code
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_uom_code)
                        ,decode(p_event_in_rec.P_unit_price
                                        ,NULL,unit_price
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_unit_price)
                --Defaulting references.
                        ,decode(p_event_in_rec.P_reference1
                                        ,NULL,reference1
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_reference1)
                        ,decode(p_event_in_rec.P_reference2
                                        ,NULL,reference2
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_reference2)
                        ,decode(p_event_in_rec.P_reference3
                                        ,NULL,reference3
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_reference3)
                        ,decode(p_event_in_rec.P_reference4
                                        ,NULL,reference4
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_reference4 )
                        ,decode(p_event_in_rec.P_reference5
                                        ,NULL,reference5
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_reference5 )
                        ,decode(p_event_in_rec.P_reference6
                                        ,NULL,reference6
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_reference6 )
                        ,decode(p_event_in_rec.P_reference7
                                        ,NULL,reference7
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_reference7 )
                        ,decode(p_event_in_rec.P_reference8
                                        ,NULL,reference8
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_reference8 )
                        ,decode(p_event_in_rec.P_reference9
                                        ,NULL,reference9
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_reference9 )
                        ,decode(p_event_in_rec.P_reference10
                                        ,NULL,reference10
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,p_event_in_rec.P_reference10 )
		--defaulting completion date
			,decode(p_event_in_rec.P_completion_date
					,NULL,completion_date
					,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,SYSDATE
					,p_event_in_rec.P_completion_date)
		--Defaulting event type.
			,decode(p_event_in_rec.P_event_type
					,NULL,event_type
					,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,event_type
					,p_event_in_rec.P_event_type)
		--Defaulting bill trans revenue and bill trans bill amounts
			,decode(p_event_in_rec.P_bill_trans_rev_amount
					,NULL,bill_trans_rev_amount
					,p_event_in_rec.P_bill_trans_rev_amount)
                        ,decode(p_event_in_rec.P_bill_trans_bill_amount
                                        ,NULL,bill_trans_bill_amount
                                        ,p_event_in_rec.P_bill_trans_bill_amount)
		--Defaulting task_id.
                        ,decode(p_event_in_rec.p_task_number
                                        ,NULL,task_id
                                        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,NULL
                                        ,P_task_id)
                        ,decode(p_event_in_rec.p_description, null, description,
                                PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, description, p_event_in_rec.p_description)
                        ,record_version_number
                        ,decode(ADJUSTING_REVENUE_FLAG,'N', /* Added for bug 6863270 */
                        decode(p_event_in_rec.p_bill_trans_bill_amount, PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, bill_trans_bill_amount,
                                null, bill_trans_bill_amount, p_event_in_rec.p_bill_trans_bill_amount),0)
                        ,decode(p_event_in_rec.p_bill_trans_rev_amount, PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, bill_trans_rev_amount,
                                null, bill_trans_rev_amount, p_event_in_rec.p_bill_trans_rev_amount)
                  Into   p_event_in_rec.P_bill_hold_flag
                        ,p_event_in_rec.P_adjusting_revenue_flag
                        ,p_inv_org_id
			,p_event_in_rec.P_inventory_item_id
                        ,P_organization_id
			,p_event_in_rec.P_quantity_billed
			,p_event_in_rec.P_uom_code
			,p_event_in_rec.P_unit_price
			,p_event_in_rec.P_reference1
			,p_event_in_rec.P_reference2
                        ,p_event_in_rec.P_reference3
                        ,p_event_in_rec.P_reference4
                        ,p_event_in_rec.P_reference5
                        ,p_event_in_rec.P_reference6
                        ,p_event_in_rec.P_reference7
                        ,p_event_in_rec.P_reference8
                        ,p_event_in_rec.P_reference9
                        ,p_event_in_rec.P_reference10
			,p_event_in_rec.P_completion_date
			,p_event_in_rec.P_event_type
			,p_event_in_rec.P_bill_trans_rev_amount
			,p_event_in_rec.P_bill_trans_bill_amount
			,P_task_id
			,p_event_in_rec.P_description
			,l_record_version_number
			,l_bill_trans_bill_amt   /* Added for bug 4093948 */
			,l_bill_trans_rev_amt    /* Added for bug 4093948 */

                  From   pa_events
                  Where  event_id=p_event_in_rec.P_event_id;

		--Unless the user updates with a valid description the
		--description gets defaulted with the event type.
                If (p_event_in_rec.P_description Is NULL
		    OR p_event_in_rec.P_description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
		Then
			p_event_in_rec.P_description := p_event_in_rec.P_event_type;
		End If;

                --If event type is of revenue type(Write-Off), setting bill trans bill amt = 0.
                If  l_event_type_classification In('WRITE OFF')
                Then
                        p_event_in_rec.P_bill_trans_bill_amount:=0;
                End If;

                --If event type is of invoice type, set bill trans rev amt = 0
                If l_event_type_classification In('DEFERRED REVENUE','INVOICE REDUCTION','SCHEDULED PAYMENTS')
                Then
                        p_event_in_rec.P_bill_trans_rev_amount:=0;
                End If;

                --If event type = 'Write-On' then bill amt = rev amt.
                If (l_event_type_classification = 'WRITE ON')
                Then
                        p_event_in_rec.P_bill_trans_bill_amount := p_event_in_rec.P_bill_trans_rev_amount;
                End If;

          --Log Message
          IF l_debug_mode = 'Y' THEN
          pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.UPDATE_EVENT.begin'
                             ,x_msg         => 'Begin Updating event. '
                             ,x_log_level   => 5);
          END IF;

           --Get the conversion_type of the funding_rate_type, projfunc_rate_type, project_rate_type  - for Bug3013236
              IF p_event_in_rec.p_funding_rate_type is not null
              THEN
                 SELECT conversion_type
                   INTO l_funding_rate_type
                   FROM pa_conversion_types_v
                  WHERE user_conversion_type = p_event_in_rec.p_funding_rate_type
                     or conversion_type = p_event_in_rec.p_funding_rate_type;
                 p_event_in_rec.p_funding_rate_type := l_funding_rate_type;
              END IF;

              IF p_event_in_rec.p_projfunc_rate_type is not null
              THEN
                 SELECT conversion_type
                   INTO l_projfunc_bil_rate_type
                   FROM pa_conversion_types_v
                  WHERE user_conversion_type = p_event_in_rec.p_projfunc_rate_type
                     or conversion_type = p_event_in_rec.p_projfunc_rate_type;
                 p_event_in_rec.p_projfunc_rate_type := l_projfunc_bil_rate_type;
              END IF;

              IF p_event_in_rec.p_project_rate_type is not null
              THEN
                 SELECT conversion_type
                   INTO l_project_bil_rate_type
                   FROM pa_conversion_types_v
                  WHERE user_conversion_type = p_event_in_rec.p_project_rate_type
                     or conversion_type = p_event_in_rec.p_project_rate_type;
                 p_event_in_rec.p_project_rate_type := l_project_bil_rate_type;
              END IF;

           --till here for Bug3013236

 -- Adding code to populate invoice and revenue attributes

    IF l_invproc_currency_code = l_project_currency_code THEN
       l_invproc_currency_code := l_project_currency_code;
       l_invproc_rate_type     := p_event_in_rec.P_project_rate_type;
       l_invproc_rate_date     := p_event_in_rec.P_project_rate_date;
       l_invproc_exchange_rate := p_event_in_rec.P_project_exchange_rate;
    ELSIF l_invproc_currency_code = l_projfunc_currency_code THEN
       l_invproc_currency_code := l_projfunc_currency_code;
       l_invproc_rate_type     := p_event_in_rec.P_projfunc_rate_type;
       l_invproc_rate_date     := p_event_in_rec.P_projfunc_rate_date;
       l_invproc_exchange_rate := p_event_in_rec.P_projfunc_exchange_rate;
    ELSE
       l_invproc_currency_code := '';
       l_invproc_rate_type     := p_event_in_rec.P_funding_rate_type;
       l_invproc_rate_date     := p_event_in_rec.P_funding_rate_date;
       l_invproc_exchange_rate := p_event_in_rec.P_funding_exchange_rate;

    END IF;

    IF l_revproc_currency_code = l_projfunc_currency_code THEN
       l_revproc_currency_code := l_projfunc_currency_code;
       l_revproc_rate_type     := p_event_in_rec.P_projfunc_rate_type;
       l_revproc_rate_date     := p_event_in_rec.P_projfunc_rate_date;
       l_revproc_exchange_rate := p_event_in_rec.P_projfunc_exchange_rate;
    END IF;

 -- Till here

   IF nvl(l_record_version_number, 0) <> nvl(p_event_in_rec.P_record_version_number, 0)
   Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
		pa_interface_utils_pub.map_new_amg_msg
			( p_old_message_code => 'PA_RECORD_CHANGED'
			,p_msg_attribute    => 'CHANGE'
			,p_resize_flag      => 'N'
			,p_msg_context      => 'EVENT'
		      ,p_attribute1       => P_event_in_rec.p_pm_event_reference
                        ,p_attribute2       => ''
			,p_attribute3       => ''
			,p_attribute4       => ''
			,p_attribute5       => '');
       END IF;
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 RAISE FND_API.G_EXC_ERROR;
   End If;

/* Code added for Bug 7110782 - starts */

/* l_event_processed = 'I' means that event has been billed but not revenue distributed.
   In this case we are allowing to change only the bill_trans_rev_amount value */
IF l_event_processed = 'I' THEN

SELECT ev.Task_Id
      ,ev.Event_Num
      ,ev.Event_Type
      ,ev.Bill_Amount
      ,ev.Revenue_Amount
      ,ev.Revenue_Distributed_Flag
      ,ev.Bill_Hold_Flag
      ,ev.Completion_date
      ,Rev_Dist_Rejection_Code
      ,ev.Attribute_Category
      ,ev.Attribute1
      ,ev.Attribute2
      ,ev.Attribute3
      ,ev.Attribute4
      ,ev.Attribute5
      ,ev.Attribute6
      ,ev.Attribute7
      ,ev.Attribute8
      ,ev.Attribute9
      ,ev.Attribute10
      ,ev.Project_Id
      ,ev.Organization_Id
      ,ev.Billing_Assignment_Id
      ,ev.Event_Num_Reversed
      ,ev.Calling_Place
      ,ev.Calling_Process
      ,ev.Bill_Trans_Currency_Code
      ,ev.Bill_Trans_Bill_Amount
      ,ev.Project_Currency_Code
      ,ev.Project_Rate_Type
      ,ev.Project_Rate_Date
      ,ev.Project_Exchange_Rate
      ,ev.Project_Inv_Rate_Date
      ,ev.Project_Inv_Exchange_Rate
      ,ev.Project_Bill_Amount
      ,ev.Project_Rev_Rate_date
      ,ev.Project_Rev_Exchange_Rate
      ,ev.Project_Revenue_Amount
      ,ev.ProjFunc_Currency_Code
      ,ev.ProjFunc_Rate_Type
      ,ev.ProjFunc_Rate_date
      ,ev.ProjFunc_Exchange_Rate
      ,ev.ProjFunc_Inv_Rate_date
      ,ev.ProjFunc_Inv_Exchange_Rate
      ,ev.ProjFunc_Bill_Amount
      ,ev.ProjFunc_Rev_Rate_date
      ,ev.Projfunc_Rev_Exchange_Rate
      ,ev.ProjFunc_Revenue_Amount
      ,ev.Funding_Rate_Type
      ,ev.Funding_Rate_date
      ,ev.Funding_Exchange_Rate
      ,ev.Invproc_Currency_Code
      ,ev.Invproc_Rate_Type
      ,ev.Invproc_Rate_date
      ,ev.Invproc_Exchange_Rate
      ,ev.Revproc_Currency_Code
      ,ev.Revproc_Rate_Type
      ,ev.Revproc_Rate_date
      ,ev.Revproc_Exchange_Rate
      ,ev.Inv_Gen_Rejection_Code
      ,ev.Adjusting_Revenue_Flag
      ,ev.inventory_org_id
      ,ev.inventory_item_id
      ,ev.quantity_billed
      ,ev.uom_code
      ,ev.unit_price
      ,ev.reference1
      ,ev.reference2
      ,ev.reference3
      ,ev.reference4
      ,ev.reference5
      ,ev.reference6
      ,ev.reference7
      ,ev.reference8
      ,ev.reference9
      ,ev.reference10
      ,ev.agreement_id
INTO p_task_id
    ,p_event_in_rec.p_event_number
    ,p_event_in_rec.P_event_type
    ,l_bill_amount
    ,l_revenue_amount
    ,l_revenue_distributed_flag
    ,p_event_in_rec.P_bill_hold_flag
    ,p_event_in_rec.P_completion_date
    ,l_rev_dist_rejection_code
    ,p_event_in_rec.P_attribute_category
    ,p_event_in_rec.P_attribute1
    ,p_event_in_rec.P_attribute2
    ,p_event_in_rec.P_attribute3
    ,p_event_in_rec.P_attribute4
    ,p_event_in_rec.P_attribute5
    ,p_event_in_rec.P_attribute6
    ,p_event_in_rec.P_attribute7
    ,p_event_in_rec.P_attribute8
    ,p_event_in_rec.P_attribute9
    ,p_event_in_rec.P_attribute10
    ,P_project_id
    ,P_Organization_Id
    ,l_Billing_Assignment_Id
    ,l_Event_Num_Reversed
    ,l_Calling_Place
    ,l_Calling_Process
    ,p_event_in_rec.P_bill_trans_currency_code
    ,l_Bill_Trans_Bill_Amt
    ,l_project_currency_code
    ,p_event_in_rec.P_project_rate_type
    ,p_event_in_rec.P_project_rate_date
    ,p_event_in_rec.P_project_exchange_rate
    ,l_ProjFunc_Inv_Rate_date
    ,l_Project_Inv_Exchange_Rate
    ,l_Project_Bill_Amount
    ,l_Project_Rev_Rate_date
    ,l_Project_Rev_Exchange_Rate
    ,l_Project_Revenue_Amount
    ,l_ProjFunc_Currency_Code
    ,p_event_in_rec.P_projfunc_rate_type
    ,p_event_in_rec.P_projfunc_rate_date
    ,p_event_in_rec.P_projfunc_exchange_rate
    ,l_ProjFunc_Inv_Rate_date
    ,l_ProjFunc_Inv_Exchange_Rate
    ,l_ProjFunc_Bill_Amount
    ,l_ProjFunc_Rev_Rate_date
    ,l_Projfunc_Rev_Exchange_Rate
    ,l_ProjFunc_Revenue_Amount
    ,p_event_in_rec.P_funding_rate_type
    ,p_event_in_rec.P_funding_rate_date
    ,p_event_in_rec.P_funding_exchange_rate
    ,l_Invproc_Currency_Code
    ,l_Invproc_Rate_Type
    ,l_Invproc_Rate_date
    ,l_Invproc_Exchange_Rate
    ,l_Revproc_Currency_Code
    ,l_Revproc_Rate_Type
    ,l_Revproc_Rate_date
    ,l_revproc_exchange_rate
    ,l_Inv_Gen_Rejection_Code
    ,p_event_in_rec.P_adjusting_revenue_flag
    ,p_inv_org_id
    ,p_event_in_rec.P_inventory_item_id
    ,p_event_in_rec.P_quantity_billed
    ,p_event_in_rec.P_uom_code
    ,p_event_in_rec.P_unit_price
    ,p_event_in_rec.P_reference1
    ,p_event_in_rec.P_reference2
    ,p_event_in_rec.P_reference3
    ,p_event_in_rec.P_reference4
    ,p_event_in_rec.P_reference5
    ,p_event_in_rec.P_reference6
    ,p_event_in_rec.P_reference7
    ,p_event_in_rec.P_reference8
    ,p_event_in_rec.P_reference9
    ,p_event_in_rec.P_reference10
    ,P_agreement_id
FROM pa_events ev
WHERE event_id = p_event_in_rec.p_event_id;

--Added the below call for bug 7513054
l_Bill_Trans_rev_Amt := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(l_Bill_Trans_rev_Amt,p_event_in_rec.P_bill_trans_currency_code);


   PA_EVENTS_PKG.Update_Row
	       (X_Rowid                          	    =>Rowid
	       ,X_Event_Id                      	    =>p_event_in_rec.P_event_id
	       ,X_Task_Id                               =>p_task_id
	       ,X_Event_Num                             =>p_event_in_rec.p_event_number
	       ,X_Last_Update_Date                      =>SYSDATE
	       ,X_Last_Updated_By                       =>G_USER_ID
	       ,X_Last_Update_Login                     =>G_LOGIN_ID
	       ,X_Event_Type                            =>p_event_in_rec.P_event_type
	       ,X_Description                           =>p_event_in_rec.P_description
	       ,X_Bill_Amount                           =>0
	       ,X_Revenue_Amount                        =>0
	       ,X_Revenue_Distributed_Flag              =>'N'
	       ,X_Bill_Hold_Flag                        =>p_event_in_rec.P_bill_hold_flag
	       ,X_Completion_date                       =>p_event_in_rec.P_completion_date
	       ,X_Rev_Dist_Rejection_Code               =>NULL
	       ,X_Attribute_Category                    =>p_event_in_rec.P_attribute_category
	       ,X_Attribute1                            =>p_event_in_rec.P_attribute1
	       ,X_Attribute2                            =>p_event_in_rec.P_attribute2
	       ,X_Attribute3                            =>p_event_in_rec.P_attribute3
	       ,X_Attribute4                            =>p_event_in_rec.P_attribute4
	       ,X_Attribute5                            =>p_event_in_rec.P_attribute5
	       ,X_Attribute6                            =>p_event_in_rec.P_attribute6
	       ,X_Attribute7                            =>p_event_in_rec.P_attribute7
	       ,X_Attribute8                            =>p_event_in_rec.P_attribute8
	       ,X_Attribute9                            =>p_event_in_rec.P_attribute9
	       ,X_Attribute10                           =>p_event_in_rec.P_attribute10
	       ,X_Project_Id                            =>P_project_id
	       ,X_Organization_Id                       =>P_Organization_Id
	       ,X_Billing_Assignment_Id                 =>NULL
	       ,X_Event_Num_Reversed                    =>NULL
	       ,X_Calling_Place                         =>NULL
	       ,X_Calling_Process                       =>NULL
	       ,X_Bill_Trans_Currency_Code              =>p_event_in_rec.P_bill_trans_currency_code
	       ,X_Bill_Trans_Bill_Amount                =>l_Bill_Trans_Bill_Amt
	       ,X_Bill_Trans_rev_Amount                 =>l_Bill_Trans_rev_Amt
	       ,X_Project_Currency_Code                 =>l_project_currency_code
	       ,X_Project_Rate_Type                     =>p_event_in_rec.P_project_rate_type
	       ,X_Project_Rate_Date                     =>p_event_in_rec.P_project_rate_date
	       ,X_Project_Exchange_Rate                 =>p_event_in_rec.P_project_exchange_rate
	       ,X_Project_Inv_Rate_Date                 =>l_ProjFunc_Inv_Rate_date
	       ,X_Project_Inv_Exchange_Rate             =>l_Project_Inv_Exchange_Rate
	       ,X_Project_Bill_Amount                   =>l_Project_Bill_Amount
	       ,X_Project_Rev_Rate_date                 =>l_Project_Rev_Rate_date
	       ,X_Project_Rev_Exchange_Rate             =>l_Project_Rev_Exchange_Rate
	       ,X_Project_Revenue_Amount                =>l_Project_Revenue_Amount
	       ,X_ProjFunc_Currency_Code                =>l_ProjFunc_Currency_Code
	       ,X_ProjFunc_Rate_Type                    =>p_event_in_rec.P_projfunc_rate_type
	       ,X_ProjFunc_Rate_date                    =>p_event_in_rec.P_projfunc_rate_date
	       ,X_ProjFunc_Exchange_Rate                =>p_event_in_rec.P_projfunc_exchange_rate
	       ,X_ProjFunc_Inv_Rate_date                =>l_ProjFunc_Inv_Rate_date
	       ,X_ProjFunc_Inv_Exchange_Rate            =>l_ProjFunc_Inv_Exchange_Rate
	       ,X_ProjFunc_Bill_Amount                  =>l_ProjFunc_Bill_Amount
	       ,X_ProjFunc_Rev_Rate_date                =>l_ProjFunc_Rev_Rate_date
	       ,X_Projfunc_Rev_Exchange_Rate            =>l_Projfunc_Rev_Exchange_Rate
	       ,X_ProjFunc_Revenue_Amount               =>l_ProjFunc_Revenue_Amount
	       ,X_Funding_Rate_Type                     =>p_event_in_rec.P_funding_rate_type
	       ,X_Funding_Rate_date                     =>p_event_in_rec.P_funding_rate_date
	       ,X_Funding_Exchange_Rate                 =>p_event_in_rec.P_funding_exchange_rate
	       ,X_Invproc_Currency_Code                 =>l_Invproc_Currency_Code
	       ,X_Invproc_Rate_Type                     =>l_Invproc_Rate_Type
	       ,X_Invproc_Rate_date                     =>l_Invproc_Rate_date
	       ,X_Invproc_Exchange_Rate                 =>l_Invproc_Exchange_Rate
	       ,X_Revproc_Currency_Code                 =>l_Revproc_Currency_Code
	       ,X_Revproc_Rate_Type                     =>l_Revproc_Rate_Type
	       ,X_Revproc_Rate_date                     =>l_Revproc_Rate_date
	       ,X_Revproc_Exchange_Rate                 =>l_revproc_exchange_rate
	       ,X_Inv_Gen_Rejection_Code                =>l_Inv_Gen_Rejection_Code
	       ,X_Adjusting_Revenue_Flag                =>p_event_in_rec.P_adjusting_revenue_flag
	       ,X_inventory_org_id                      =>p_inv_org_id
	       ,X_inventory_item_id                     =>p_event_in_rec.P_inventory_item_id
		,X_quantity_billed                      =>p_event_in_rec.P_quantity_billed
		,X_uom_code                             =>p_event_in_rec.P_uom_code
		,X_unit_price                           =>p_event_in_rec.P_unit_price
		,X_reference1                           =>p_event_in_rec.P_reference1
		,X_reference2                           =>p_event_in_rec.P_reference2
		,X_reference3                           =>p_event_in_rec.P_reference3
		,X_reference4                           =>p_event_in_rec.P_reference4
		,X_reference5                           =>p_event_in_rec.P_reference5
		,X_reference6                           =>p_event_in_rec.P_reference6
		,X_reference7                           =>p_event_in_rec.P_reference7
		,X_reference8                           =>p_event_in_rec.P_reference8
		,X_reference9                           =>p_event_in_rec.P_reference9
		,X_reference10                          =>p_event_in_rec.P_reference10
		,X_agreement_id				            =>P_agreement_id );

/* l_event_processed = 'R' means that event has been revenue distributed but not billed.
   In this case we are allowing to change only the bill_trans_bill_amount and bill_hold_flga values */
ELSIF l_event_processed = 'R' THEN

SELECT ev.Task_Id
      ,ev.Event_Num
      ,ev.Event_Type
      ,ev.Bill_Amount
      ,ev.Revenue_Amount
      ,ev.Revenue_Distributed_Flag
      ,ev.Completion_date
      ,Rev_Dist_Rejection_Code
      ,ev.Attribute_Category
      ,ev.Attribute1
      ,ev.Attribute2
      ,ev.Attribute3
      ,ev.Attribute4
      ,ev.Attribute5
      ,ev.Attribute6
      ,ev.Attribute7
      ,ev.Attribute8
      ,ev.Attribute9
      ,ev.Attribute10
      ,ev.Project_Id
      ,ev.Organization_Id
      ,ev.Billing_Assignment_Id
      ,ev.Event_Num_Reversed
      ,ev.Calling_Place
      ,ev.Calling_Process
      ,ev.Bill_Trans_Currency_Code
      ,ev.Bill_Trans_rev_Amount
      ,ev.Project_Currency_Code
      ,ev.Project_Rate_Type
      ,ev.Project_Rate_Date
      ,ev.Project_Exchange_Rate
      ,ev.Project_Inv_Rate_Date
      ,ev.Project_Inv_Exchange_Rate
      ,ev.Project_Bill_Amount
      ,ev.Project_Rev_Rate_date
      ,ev.Project_Rev_Exchange_Rate
      ,ev.Project_Revenue_Amount
      ,ev.ProjFunc_Currency_Code
      ,ev.ProjFunc_Rate_Type
      ,ev.ProjFunc_Rate_date
      ,ev.ProjFunc_Exchange_Rate
      ,ev.ProjFunc_Inv_Rate_date
      ,ev.ProjFunc_Inv_Exchange_Rate
      ,ev.ProjFunc_Bill_Amount
      ,ev.ProjFunc_Rev_Rate_date
      ,ev.Projfunc_Rev_Exchange_Rate
      ,ev.ProjFunc_Revenue_Amount
      ,ev.Funding_Rate_Type
      ,ev.Funding_Rate_date
      ,ev.Funding_Exchange_Rate
      ,ev.Invproc_Currency_Code
      ,ev.Invproc_Rate_Type
      ,ev.Invproc_Rate_date
      ,ev.Invproc_Exchange_Rate
      ,ev.Revproc_Currency_Code
      ,ev.Revproc_Rate_Type
      ,ev.Revproc_Rate_date
      ,ev.Revproc_Exchange_Rate
      ,ev.Inv_Gen_Rejection_Code
      ,ev.Adjusting_Revenue_Flag
      ,ev.inventory_org_id
      ,ev.inventory_item_id
      ,ev.quantity_billed
      ,ev.uom_code
      ,ev.unit_price
      ,ev.reference1
      ,ev.reference2
      ,ev.reference3
      ,ev.reference4
      ,ev.reference5
      ,ev.reference6
      ,ev.reference7
      ,ev.reference8
      ,ev.reference9
      ,ev.reference10
      ,ev.agreement_id
INTO p_task_id
    ,p_event_in_rec.p_event_number
    ,p_event_in_rec.P_event_type
    ,l_bill_amount
    ,l_revenue_amount
    ,l_revenue_distributed_flag
    ,p_event_in_rec.P_completion_date
    ,l_rev_dist_rejection_code
    ,p_event_in_rec.P_attribute_category
    ,p_event_in_rec.P_attribute1
    ,p_event_in_rec.P_attribute2
    ,p_event_in_rec.P_attribute3
    ,p_event_in_rec.P_attribute4
    ,p_event_in_rec.P_attribute5
    ,p_event_in_rec.P_attribute6
    ,p_event_in_rec.P_attribute7
    ,p_event_in_rec.P_attribute8
    ,p_event_in_rec.P_attribute9
    ,p_event_in_rec.P_attribute10
    ,P_project_id
    ,P_Organization_Id
    ,l_Billing_Assignment_Id
    ,l_Event_Num_Reversed
    ,l_Calling_Place
    ,l_Calling_Process
    ,p_event_in_rec.P_bill_trans_currency_code
    ,l_Bill_Trans_rev_Amt
    ,l_project_currency_code
    ,p_event_in_rec.P_project_rate_type
    ,p_event_in_rec.P_project_rate_date
    ,p_event_in_rec.P_project_exchange_rate
    ,l_ProjFunc_Inv_Rate_date
    ,l_Project_Inv_Exchange_Rate
    ,l_Project_Bill_Amount
    ,l_Project_Rev_Rate_date
    ,l_Project_Rev_Exchange_Rate
    ,l_Project_Revenue_Amount
    ,l_ProjFunc_Currency_Code
    ,p_event_in_rec.P_projfunc_rate_type
    ,p_event_in_rec.P_projfunc_rate_date
    ,p_event_in_rec.P_projfunc_exchange_rate
    ,l_ProjFunc_Inv_Rate_date
    ,l_ProjFunc_Inv_Exchange_Rate
    ,l_ProjFunc_Bill_Amount
    ,l_ProjFunc_Rev_Rate_date
    ,l_Projfunc_Rev_Exchange_Rate
    ,l_ProjFunc_Revenue_Amount
    ,p_event_in_rec.P_funding_rate_type
    ,p_event_in_rec.P_funding_rate_date
    ,p_event_in_rec.P_funding_exchange_rate
    ,l_Invproc_Currency_Code
    ,l_Invproc_Rate_Type
    ,l_Invproc_Rate_date
    ,l_Invproc_Exchange_Rate
    ,l_Revproc_Currency_Code
    ,l_Revproc_Rate_Type
    ,l_Revproc_Rate_date
    ,l_revproc_exchange_rate
    ,l_Inv_Gen_Rejection_Code
    ,p_event_in_rec.P_adjusting_revenue_flag
    ,p_inv_org_id
    ,p_event_in_rec.P_inventory_item_id
    ,p_event_in_rec.P_quantity_billed
    ,p_event_in_rec.P_uom_code
    ,p_event_in_rec.P_unit_price
    ,p_event_in_rec.P_reference1
    ,p_event_in_rec.P_reference2
    ,p_event_in_rec.P_reference3
    ,p_event_in_rec.P_reference4
    ,p_event_in_rec.P_reference5
    ,p_event_in_rec.P_reference6
    ,p_event_in_rec.P_reference7
    ,p_event_in_rec.P_reference8
    ,p_event_in_rec.P_reference9
    ,p_event_in_rec.P_reference10
    ,P_agreement_id
FROM pa_events ev
WHERE event_id = p_event_in_rec.p_event_id;

--Added the below call for bug 7513054
l_Bill_Trans_Bill_Amt := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(l_Bill_Trans_Bill_Amt,p_event_in_rec.P_bill_trans_currency_code);


     PA_EVENTS_PKG.Update_Row
	       (X_Rowid                          	=>Rowid
	       ,X_Event_Id                      	=>p_event_in_rec.P_event_id
	       ,X_Task_Id                               =>p_task_id
	       ,X_Event_Num                             =>p_event_in_rec.p_event_number
	       ,X_Last_Update_Date                      =>SYSDATE
	       ,X_Last_Updated_By                       =>G_USER_ID
	       ,X_Last_Update_Login                     =>G_LOGIN_ID
	       ,X_Event_Type                            =>p_event_in_rec.P_event_type
	       ,X_Description                           =>p_event_in_rec.P_description
	       ,X_Bill_Amount                           =>0
	       ,X_Revenue_Amount                        =>0
	       ,X_Revenue_Distributed_Flag              =>'N'
	       ,X_Bill_Hold_Flag                        =>p_event_in_rec.P_bill_hold_flag
	       ,X_Completion_date                       =>p_event_in_rec.P_completion_date
	       ,X_Rev_Dist_Rejection_Code               =>NULL
	       ,X_Attribute_Category                    =>p_event_in_rec.P_attribute_category
	       ,X_Attribute1                            =>p_event_in_rec.P_attribute1
	       ,X_Attribute2                            =>p_event_in_rec.P_attribute2
	       ,X_Attribute3                            =>p_event_in_rec.P_attribute3
	       ,X_Attribute4                            =>p_event_in_rec.P_attribute4
	       ,X_Attribute5                            =>p_event_in_rec.P_attribute5
	       ,X_Attribute6                            =>p_event_in_rec.P_attribute6
	       ,X_Attribute7                            =>p_event_in_rec.P_attribute7
	       ,X_Attribute8                            =>p_event_in_rec.P_attribute8
	       ,X_Attribute9                            =>p_event_in_rec.P_attribute9
	       ,X_Attribute10                           =>p_event_in_rec.P_attribute10
	       ,X_Project_Id                            =>P_project_id
	       ,X_Organization_Id                       =>P_Organization_Id
	       ,X_Billing_Assignment_Id                 =>NULL
	       ,X_Event_Num_Reversed                    =>NULL
	       ,X_Calling_Place                         =>NULL
	       ,X_Calling_Process                       =>NULL
	       ,X_Bill_Trans_Currency_Code              =>p_event_in_rec.P_bill_trans_currency_code
	       ,X_Bill_Trans_Bill_Amount                =>l_Bill_Trans_Bill_Amt
	       ,X_Bill_Trans_rev_Amount                 =>l_Bill_Trans_rev_Amt
	       ,X_Project_Currency_Code                 =>l_project_currency_code
	       ,X_Project_Rate_Type                     =>p_event_in_rec.P_project_rate_type
	       ,X_Project_Rate_Date                     =>p_event_in_rec.P_project_rate_date
	       ,X_Project_Exchange_Rate                 =>p_event_in_rec.P_project_exchange_rate
	       ,X_Project_Inv_Rate_Date                 =>l_ProjFunc_Inv_Rate_date
	       ,X_Project_Inv_Exchange_Rate             =>l_Project_Inv_Exchange_Rate
	       ,X_Project_Bill_Amount                   =>l_Project_Bill_Amount
	       ,X_Project_Rev_Rate_date                 =>l_Project_Rev_Rate_date
	       ,X_Project_Rev_Exchange_Rate             =>l_Project_Rev_Exchange_Rate
	       ,X_Project_Revenue_Amount                =>l_Project_Revenue_Amount
	       ,X_ProjFunc_Currency_Code                =>l_ProjFunc_Currency_Code
	       ,X_ProjFunc_Rate_Type                    =>p_event_in_rec.P_projfunc_rate_type
	       ,X_ProjFunc_Rate_date                    =>p_event_in_rec.P_projfunc_rate_date
	       ,X_ProjFunc_Exchange_Rate                =>p_event_in_rec.P_projfunc_exchange_rate
	       ,X_ProjFunc_Inv_Rate_date                =>l_ProjFunc_Inv_Rate_date
	       ,X_ProjFunc_Inv_Exchange_Rate            =>l_ProjFunc_Inv_Exchange_Rate
	       ,X_ProjFunc_Bill_Amount                  =>l_ProjFunc_Bill_Amount
	       ,X_ProjFunc_Rev_Rate_date                =>l_ProjFunc_Rev_Rate_date
	       ,X_Projfunc_Rev_Exchange_Rate            =>l_Projfunc_Rev_Exchange_Rate
	       ,X_ProjFunc_Revenue_Amount               =>l_ProjFunc_Revenue_Amount
	       ,X_Funding_Rate_Type                     =>p_event_in_rec.P_funding_rate_type
	       ,X_Funding_Rate_date                     =>p_event_in_rec.P_funding_rate_date
	       ,X_Funding_Exchange_Rate                 =>p_event_in_rec.P_funding_exchange_rate
	       ,X_Invproc_Currency_Code                 =>l_Invproc_Currency_Code
	       ,X_Invproc_Rate_Type                     =>l_Invproc_Rate_Type
	       ,X_Invproc_Rate_date                     =>l_Invproc_Rate_date
	       ,X_Invproc_Exchange_Rate                 =>l_Invproc_Exchange_Rate
	       ,X_Revproc_Currency_Code                 =>l_Revproc_Currency_Code
	       ,X_Revproc_Rate_Type                     =>l_Revproc_Rate_Type
	       ,X_Revproc_Rate_date                     =>l_Revproc_Rate_date
	       ,X_Revproc_Exchange_Rate                 =>l_revproc_exchange_rate
	       ,X_Inv_Gen_Rejection_Code                =>l_Inv_Gen_Rejection_Code
	       ,X_Adjusting_Revenue_Flag                =>p_event_in_rec.P_adjusting_revenue_flag
	       ,X_inventory_org_id                      =>p_inv_org_id
	       ,X_inventory_item_id                     =>p_event_in_rec.P_inventory_item_id
		,X_quantity_billed                      =>p_event_in_rec.P_quantity_billed
		,X_uom_code                             =>p_event_in_rec.P_uom_code
		,X_unit_price                           =>p_event_in_rec.P_unit_price
		,X_reference1                           =>p_event_in_rec.P_reference1
		,X_reference2                           =>p_event_in_rec.P_reference2
		,X_reference3                           =>p_event_in_rec.P_reference3
		,X_reference4                           =>p_event_in_rec.P_reference4
		,X_reference5                           =>p_event_in_rec.P_reference5
		,X_reference6                           =>p_event_in_rec.P_reference6
		,X_reference7                           =>p_event_in_rec.P_reference7
		,X_reference8                           =>p_event_in_rec.P_reference8
		,X_reference9                           =>p_event_in_rec.P_reference9
		,X_reference10                          =>p_event_in_rec.P_reference10
		,X_agreement_id				            =>P_agreement_id );

/* Code added for Bug 7110782 - ends */

ELSE

--Added below calls for bug 7513054
l_Bill_Trans_rev_Amt  := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(l_Bill_Trans_rev_Amt, p_event_in_rec.P_bill_trans_currency_code);
l_Bill_Trans_Bill_Amt := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(l_Bill_Trans_Bill_Amt,p_event_in_rec.P_bill_trans_currency_code);


	   --Calls table handler for updating valid events.
	      PA_EVENTS_PKG.Update_Row
	       (X_Rowid                          	=>Rowid
	       ,X_Event_Id                      	=>p_event_in_rec.P_event_id
	       ,X_Task_Id                               =>p_task_id
	       ,X_Event_Num                             =>p_event_in_rec.p_event_number
	       ,X_Last_Update_Date                      =>SYSDATE
	       ,X_Last_Updated_By                       =>G_USER_ID
	       ,X_Last_Update_Login                     =>G_LOGIN_ID
	       ,X_Event_Type                            =>p_event_in_rec.P_event_type
	       ,X_Description                           =>p_event_in_rec.P_description
	       ,X_Bill_Amount                           =>0
	       ,X_Revenue_Amount                        =>0
	       ,X_Revenue_Distributed_Flag              =>'N'
	       ,X_Bill_Hold_Flag                        =>p_event_in_rec.P_bill_hold_flag
	       ,X_Completion_date                       =>p_event_in_rec.P_completion_date
	       ,X_Rev_Dist_Rejection_Code               =>NULL
	       ,X_Attribute_Category                    =>p_event_in_rec.P_attribute_category
	       ,X_Attribute1                            =>p_event_in_rec.P_attribute1
	       ,X_Attribute2                            =>p_event_in_rec.P_attribute2
	       ,X_Attribute3                            =>p_event_in_rec.P_attribute3
	       ,X_Attribute4                            =>p_event_in_rec.P_attribute4
	       ,X_Attribute5                            =>p_event_in_rec.P_attribute5
	       ,X_Attribute6                            =>p_event_in_rec.P_attribute6
	       ,X_Attribute7                            =>p_event_in_rec.P_attribute7
	       ,X_Attribute8                            =>p_event_in_rec.P_attribute8
	       ,X_Attribute9                            =>p_event_in_rec.P_attribute9
	       ,X_Attribute10                           =>p_event_in_rec.P_attribute10
	       ,X_Project_Id                            =>P_project_id
	       ,X_Organization_Id                       =>P_Organization_Id
	       ,X_Billing_Assignment_Id                 =>NULL
	       ,X_Event_Num_Reversed                    =>NULL
	       ,X_Calling_Place                         =>NULL
	       ,X_Calling_Process                       =>NULL
	       ,X_Bill_Trans_Currency_Code              =>p_event_in_rec.P_bill_trans_currency_code
	       ,X_Bill_Trans_Bill_Amount                =>l_Bill_Trans_Bill_Amt
	       ,X_Bill_Trans_rev_Amount                 =>l_Bill_Trans_rev_Amt
	       ,X_Project_Currency_Code                 =>l_project_currency_code
	       ,X_Project_Rate_Type                     =>p_event_in_rec.P_project_rate_type
	       ,X_Project_Rate_Date                     =>p_event_in_rec.P_project_rate_date
	       ,X_Project_Exchange_Rate                 =>p_event_in_rec.P_project_exchange_rate
	       ,X_Project_Inv_Rate_Date                 =>l_ProjFunc_Inv_Rate_date
	       ,X_Project_Inv_Exchange_Rate             =>l_Project_Inv_Exchange_Rate
	       ,X_Project_Bill_Amount                   =>l_Project_Bill_Amount
	       ,X_Project_Rev_Rate_date                 =>l_Project_Rev_Rate_date
	       ,X_Project_Rev_Exchange_Rate             =>l_Project_Rev_Exchange_Rate
	       ,X_Project_Revenue_Amount                =>l_Project_Revenue_Amount
	       ,X_ProjFunc_Currency_Code                =>l_ProjFunc_Currency_Code
	       ,X_ProjFunc_Rate_Type                    =>p_event_in_rec.P_projfunc_rate_type
	       ,X_ProjFunc_Rate_date                    =>p_event_in_rec.P_projfunc_rate_date
	       ,X_ProjFunc_Exchange_Rate                =>p_event_in_rec.P_projfunc_exchange_rate
	       ,X_ProjFunc_Inv_Rate_date                =>l_ProjFunc_Inv_Rate_date
	       ,X_ProjFunc_Inv_Exchange_Rate            =>l_ProjFunc_Inv_Exchange_Rate
	       ,X_ProjFunc_Bill_Amount                  =>l_ProjFunc_Bill_Amount
	       ,X_ProjFunc_Rev_Rate_date                =>l_ProjFunc_Rev_Rate_date
	       ,X_Projfunc_Rev_Exchange_Rate            =>l_Projfunc_Rev_Exchange_Rate
	       ,X_ProjFunc_Revenue_Amount               =>l_ProjFunc_Revenue_Amount
	       ,X_Funding_Rate_Type                     =>p_event_in_rec.P_funding_rate_type
	       ,X_Funding_Rate_date                     =>p_event_in_rec.P_funding_rate_date
	       ,X_Funding_Exchange_Rate                 =>p_event_in_rec.P_funding_exchange_rate
	       ,X_Invproc_Currency_Code                 =>l_Invproc_Currency_Code
	       ,X_Invproc_Rate_Type                     =>l_Invproc_Rate_Type
	       ,X_Invproc_Rate_date                     =>l_Invproc_Rate_date
	       ,X_Invproc_Exchange_Rate                 =>l_Invproc_Exchange_Rate
	       ,X_Revproc_Currency_Code                 =>l_Revproc_Currency_Code
	       ,X_Revproc_Rate_Type                     =>l_Revproc_Rate_Type
	       ,X_Revproc_Rate_date                     =>l_Revproc_Rate_date
	       ,X_Revproc_Exchange_Rate                 =>l_revproc_exchange_rate
	       ,X_Inv_Gen_Rejection_Code                =>l_Inv_Gen_Rejection_Code
	       ,X_Adjusting_Revenue_Flag                =>p_event_in_rec.P_adjusting_revenue_flag
	       ,X_inventory_org_id                      =>p_inv_org_id
	       ,X_inventory_item_id                     =>p_event_in_rec.P_inventory_item_id
		,X_quantity_billed                      =>p_event_in_rec.P_quantity_billed
		,X_uom_code                             =>p_event_in_rec.P_uom_code
		,X_unit_price                           =>p_event_in_rec.P_unit_price
		,X_reference1                           =>p_event_in_rec.P_reference1
		,X_reference2                           =>p_event_in_rec.P_reference2
		,X_reference3                           =>p_event_in_rec.P_reference3
		,X_reference4                           =>p_event_in_rec.P_reference4
		,X_reference5                           =>p_event_in_rec.P_reference5
		,X_reference6                           =>p_event_in_rec.P_reference6
		,X_reference7                           =>p_event_in_rec.P_reference7
		,X_reference8                           =>p_event_in_rec.P_reference8
		,X_reference9                           =>p_event_in_rec.P_reference9
		,X_reference10                          =>p_event_in_rec.P_reference10
                ,X_agreement_id				=>P_agreement_id );  -- Federal Uptake

END IF; /* Added for Bug 7110782 */

        --If commit is set to true then commit to database.
            IF FND_API.to_boolean( p_commit )
            THEN
                COMMIT;
            END IF;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR
			THEN
			ROLLBACK TO Update_event;
			l_return_status := FND_API.G_RET_STS_ERROR;

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR
			THEN
			ROLLBACK TO Update_event;
			l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                WHEN pa_event_pvt.pub_excp
                        THEN
                        ROLLBACK TO Update_event;
			l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			PA_EVENT_PUB.PACKAGE_NAME
			:='(event_reference='||p_event_in_rec.p_pm_event_reference||')'||PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
			PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'UPDATE_EVENT';

			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				FND_MSG_PUB.add_exc_msg
				       ( p_pkg_name            => PACKAGE_NAME
				       , p_procedure_name      => PROCEDURE_NAME );
			PACKAGE_NAME:=NULL;
			PROCEDURE_NAME:=NULL;
			END IF;

		WHEN OTHERS
			THEN
			l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			ROLLBACK TO Update_event;
			PA_EVENT_PUB.PACKAGE_NAME
			:='(event_reference='||p_event_in_rec.p_pm_event_reference||')'||PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
			PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'UPDATE_EVENT';

			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				FND_MSG_PUB.add_exc_msg
				       ( p_pkg_name            => PACKAGE_NAME
				       , p_procedure_name      => PROCEDURE_NAME );
			PACKAGE_NAME:=NULL;
			PROCEDURE_NAME:=NULL;
			END IF;

     END;         --end of Inner Block

   --Populating the output table
   p_event_out_tbl(tot_out_rec).pm_event_reference := p_event_in_rec.p_pm_event_reference;
   p_event_out_tbl(tot_out_rec).Event_Id           := p_event_in_rec.P_event_id;
   p_event_out_tbl(tot_out_rec).Return_status      := P_return_status;
   tot_out_rec := tot_out_rec + 1;
   tot_in_rec := p_event_in_tbl.next(tot_in_rec);

   pa_debug.reset_err_stack; -- Reset error stack

   END LOOP;     --End of loop

   --Setting the return status to false even if one record fails the validation.
   p_return_status := l_return_status;

   --If there is one error message then extract the error meaasge and return it.
   FND_MSG_PUB.Count_And_Get
	( p_encoded           =>      l_encoded
	 ,p_count             =>      p_msg_count
	 ,p_data              =>      p_msg_data      );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR
           THEN
                p_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                        ( p_encoded           =>      l_encoded
                         ,p_count             =>      p_msg_count
                         ,p_data              =>      p_msg_data      );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
           THEN
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                        ( p_encoded           =>      l_encoded
                         ,p_count             =>      p_msg_count
                         ,p_data              =>      p_msg_data      );

        WHEN pa_event_pvt.pub_excp
           THEN
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                PA_EVENT_PUB.PACKAGE_NAME
                :='(event_reference='||p_event_in_rec.p_pm_event_reference||')'||PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'UPDATE_EVENT';

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
                PACKAGE_NAME:=NULL;
                PROCEDURE_NAME:=NULL;
                END IF;
                FND_MSG_PUB.Count_And_Get
                        ( p_encoded           =>      l_encoded
                         ,p_count             =>      p_msg_count
                         ,p_data              =>      p_msg_data      );

        WHEN OTHERS
           THEN
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                PA_EVENT_PUB.PACKAGE_NAME
                :='(event_reference='||p_event_in_rec.p_pm_event_reference||')'||PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'UPDATE_EVENT';

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
                PACKAGE_NAME:=NULL;
                PROCEDURE_NAME:=NULL;
                END IF;

                FND_MSG_PUB.Count_And_Get
                        ( p_encoded           =>      l_encoded
                         ,p_count             =>      p_msg_count
                         ,p_data              =>      p_msg_data      );

 END UPDATE_EVENT;

-- ============================================================================
--
--Name:               delete_event
--Type:               procedure
--Description: This API deletes an existing event or a set of existing events
--
--Called subprograms:
--Called subprograms: PA_EVENT_PVT.CHECK_MDTY_PARAMS1
--                    PA_EVENT_PVT.CHECK_MDTY_PARAMS2
--                    PA_EVENT_PVT.CHECK_DELETE_EVENT_OK
--                    PA_EVENTS_PKG.DELETE_ROW
--
--
--
--History:

-- ============================================================================
PROCEDURE DELETE_EVENT
(p_api_version_number	IN	NUMBER
,p_commit		IN	VARCHAR2
,p_init_msg_list	IN	VARCHAR2
,p_pm_product_code	IN	VARCHAR2
,p_pm_event_reference  	IN	VARCHAR2
,p_event_id		IN	NUMBER
,p_msg_count            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,p_return_status        OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

p_api_name                      VARCHAR2(100):='DELETE_EVENT';
P_rowid				VARCHAR2(18);
l_event_id_out			NUMBER:=NULL;
l_encoded			VARCHAR2(1):='F';
l_pm_event_reference            VARCHAR2(25);
BEGIN

  -- Initialize the Error Stack
  pa_debug.set_err_stack('PA_EVENT_PUB.DELETE_EVENT');

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.DELETE_EVENT.begin'
                     ,x_msg         => 'Beginning of Delete Event'
                     ,x_log_level   => 5);
  END IF;


   --Seting Savepoint
   Savepoint delete_event;
      p_msg_count := 0;
      p_return_status := FND_API.G_RET_STS_SUCCESS;
  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.DELETE_EVENT.begin'
                     ,x_msg         => 'Calling  mandatory input parameters-1'
                     ,x_log_level   => 5);
  END IF;

   ---Validating mandatory input parameters-1

   PA_EVENT_PVT.CHECK_MDTY_PARAMS1
    ( p_api_version_number             =>p_api_version_number
     ,p_api_name                       =>p_api_name
     ,p_pm_product_code                =>p_pm_product_code
     ,p_function_name                  =>'PA_EV_DELETE_EVENT'
     ,x_return_status                  =>p_return_status
     ,x_msg_count                      =>p_msg_count
     ,x_msg_data                       =>p_msg_data );

	   If p_return_status <> FND_API.G_RET_STS_SUCCESS
	   Then
		IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR
		THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		ELSIF p_return_status = FND_API.G_RET_STS_ERROR
		THEN
                        RAISE FND_API.G_EXC_ERROR;
		END IF;
	   End If;

          --Log Message
   IF l_debug_mode = 'Y' THEN
	  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.DELETE_EVENT.begin'
                             ,x_msg         => ' Calling mandatory input parameters-2'
                             ,x_log_level   => 5);
   END IF;

   -- Validating mandatory input parameters-2
/*Commenting out this call as the event reference is not a mandatory parameter.bug 3118781
   PA_EVENT_PVT.CHECK_MDTY_PARAMS2
   (  p_pm_event_reference    => p_pm_event_reference
     ,p_pm_product_code       => p_pm_product_code
     ,p_project_number        => NULL
     ,p_event_type            => NULL
     ,p_organization_name     => NULL
     ,p_calling_place         => 'DELETE_EVENT'
     ,x_return_status         => p_return_status );

	   If p_return_status <> FND_API.G_RET_STS_SUCCESS
	   Then
		IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR
		THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		ELSIF p_return_status = FND_API.G_RET_STS_ERROR
		THEN
				RAISE FND_API.G_EXC_ERROR;
		END IF;
	   End If;
End of comment for 3118781 */
  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.DELETE_EVENT.begin'
		     ,x_msg         => 'Calling conv_event_ref_to_id'
		     ,x_log_level   => 5);
  END IF;
   l_pm_event_reference :=p_pm_event_reference;
   l_event_id_out:=p_event_id;
   --Validation of event_id or pm_event_reference and conversion to event_id

    If PA_EVENT_PVT.CONV_EVENT_REF_TO_ID
          (P_pm_product_code      =>P_pm_product_code
          ,P_pm_event_reference   =>l_pm_event_reference
          ,P_event_id             =>l_event_id_out)
          ='N'
    Then
          p_return_status             := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
    End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.DELETE_EVENT.begin'
		     ,x_msg         => 'Calling check_delete_event_ok'
		     ,x_log_level   => 5);
  END IF;

   -- Calling check_delete_event_ok in pa_event_pvt package

   If PA_EVENT_PVT.CHECK_DELETE_EVENT_OK
	(P_pm_event_reference	=>l_pm_event_reference
	,P_event_id		=>l_event_id_out) ='N'
   Then
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_TK_EVENT_IN_USE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => l_pm_event_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         p_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;

   End If;


  --If validation is successful then delete the event from PA_EVENTS

--Populating the rowid
          Select Rowid
          Into p_rowid
          From pa_events
          Where event_id=l_event_id_out;


  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.DELETE_EVENT.begin'
		     ,x_msg         => 'Calling table handler to delete event'
		     ,x_log_level   => 5);
  END IF;

  --calling PROCEDURE Delete_Row to delete the event


  PA_EVENTS_PKG.Delete_Row(X_Rowid  =>  P_rowid);

  --If commit is set to true then commit to database.
    IF FND_API.to_boolean( p_commit )
    THEN
	COMMIT;
    END IF;


   --If there is one error message then extract the error meaasge
    FND_MSG_PUB.Count_And_Get
        ( p_encoded           =>      l_encoded
         ,p_count             =>      p_msg_count
         ,p_data              =>      p_msg_data      );

   pa_debug.reset_err_stack; -- Reset error stack


EXCEPTION
        WHEN FND_API.G_EXC_ERROR
                THEN
		ROLLBACK to delete_event;
                p_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                        (   p_encoded           =>      l_encoded
			 ,  p_count             =>      p_msg_count
                         ,  p_data              =>      p_msg_data      );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
                THEN
                ROLLBACK to delete_event;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                        (   p_encoded           =>      l_encoded
                         ,  p_count             =>      p_msg_count
                         ,  p_data              =>      p_msg_data      );

        WHEN pa_event_pvt.pub_excp
                THEN
                ROLLBACK to delete_event;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                PA_EVENT_PUB.PACKAGE_NAME
                :='(event_reference='||p_pm_event_reference||')'||PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||'DELETE_EVENT';

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
                PACKAGE_NAME:=NULL;
                PROCEDURE_NAME:=NULL;
                END IF;

                FND_MSG_PUB.Count_And_Get
                        (   p_encoded           =>      l_encoded
                         ,  p_count             =>      p_msg_count
                         ,  p_data              =>      p_msg_data      );

        WHEN OTHERS
                THEN
                ROLLBACK to delete_event;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                PA_EVENT_PUB.PACKAGE_NAME
                :='(event_reference='||p_pm_event_reference||')'||PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'DELETE_EVENT';

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
                PACKAGE_NAME:=NULL;
                PROCEDURE_NAME:=NULL;
                END IF;

                FND_MSG_PUB.Count_And_Get
                        (   p_encoded           =>      l_encoded
                         ,  p_count             =>      p_msg_count
                         ,  p_data              =>      p_msg_data      );


  END DELETE_EVENT;

-- ============================================================================
--
--Name:               init_event
--Type:               Procedure
--Description:        This procedure can be used to initialize the global PL/SQL
--                    tables that are used by a LOAD/EXECUTE/FETCH cycle.
--
--History:
--
-- =============================================================================
  PROCEDURE INIT_EVENT
  AS
  BEGIN

  --Initialising global tables
  G_event_in_tbl.delete;
  G_event_out_tbl.delete;

EXCEPTION
        WHEN OTHERS
                THEN

                PA_EVENT_PUB.PACKAGE_NAME
                :=PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'INIT_EVENT';

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
                PACKAGE_NAME:=NULL;
                PROCEDURE_NAME:=NULL;
                END IF;

  END INIT_EVENT;

-- ============================================================================
--
--Name:               load_event
--Type:               Procedure
--Description:        This procedure can be used to move the event related
--                    parameters from the client side to a record on the server side
--                    , where it will be used by a LOAD/EXECUTE/FETCH cycle.
--
--History:
--
-- ============================================================================

PROCEDURE LOAD_EVENT
(p_pm_product_code      	 IN      VARCHAR2
,P_api_version_number            IN      NUMBER
,P_init_msg_list                 IN      VARCHAR2
,P_pm_event_reference            IN      VARCHAR2
,P_task_number                   IN      VARCHAR2
,P_event_number                  IN      NUMBER
,P_event_type                    IN      VARCHAR2
,P_agreement_number              IN      VARCHAR2 -- Federal Uptake
,P_agreement_type                IN      VARCHAR2 -- Federal Uptake
,P_customer_number               IN      VARCHAR2 -- Federal Uptake
,P_description                   IN      VARCHAR2
,P_bill_hold_flag                IN      VARCHAR2
,P_completion_date               IN      DATE
,P_desc_flex_name                IN      VARCHAR2
,P_attribute_category            IN      VARCHAR2
,P_attribute1                    IN      VARCHAR2
,P_attribute2                    IN      VARCHAR2
,P_attribute3                    IN      VARCHAR2
,P_attribute4                    IN      VARCHAR2
,P_attribute5                    IN      VARCHAR2
,P_attribute6                    IN      VARCHAR2
,P_attribute7                    IN      VARCHAR2
,P_attribute8                    IN      VARCHAR2
,P_attribute9                    IN      VARCHAR2
,P_attribute10                   IN      VARCHAR2
,P_project_number                IN      VARCHAR2
,P_organization_name             IN      VARCHAR2
,P_inventory_org_name            IN      VARCHAR2
,P_inventory_item_id             IN      NUMBER
,P_quantity_billed               IN      NUMBER
,P_uom_code                      IN      VARCHAR2
,P_unit_price                    IN      NUMBER
,P_reference1                    IN      VARCHAR2
,P_reference2                    IN      VARCHAR2
,P_reference3                    IN      VARCHAR2
,P_reference4                    IN      VARCHAR2
,P_reference5                    IN      VARCHAR2
,P_reference6                    IN      VARCHAR2
,P_reference7                    IN      VARCHAR2
,P_reference8                    IN      VARCHAR2
,P_reference9                    IN      VARCHAR2
,P_reference10                   IN      VARCHAR2
,P_bill_trans_currency_code      IN      VARCHAR2
,P_bill_trans_bill_amount        IN      NUMBER
,P_bill_trans_rev_amount         IN      NUMBER
,P_project_rate_type             IN      VARCHAR2
,P_project_rate_date             IN      DATE
,P_project_exchange_rate         IN      NUMBER
,P_projfunc_rate_type            IN      VARCHAR2
,P_projfunc_rate_date            IN      DATE
,P_projfunc_exchange_rate        IN      NUMBER
,P_funding_rate_type             IN      VARCHAR2
,P_funding_rate_date             IN      DATE
,P_funding_exchange_rate         IN      NUMBER
,P_adjusting_revenue_flag        IN      VARCHAR2
,P_event_id                      IN      NUMBER
,P_return_status                 OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

AS

p_api_name		VARCHAR2(100):='LOAD_EVENT';
p_msg_count		NUMBER:=0;
p_msg_data		VARCHAR2(2000);
BEGIN

  -- Initialize the Error Stack
  pa_debug.set_err_stack('PA_EVENT_PUB.LOAD_EVENT');

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.LOAD_EVENT.begin'
                     ,x_msg         => 'Beginning of Load_Event'
                     ,x_log_level   => 5);
  End If;


  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.LOAD_EVENT.begin'
                     ,x_msg         => 'Beginning of  api compatibility check '
                     ,x_log_level   => 5);
  End If;

--  Standard call to check for api compatibility.
    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         p_api_name             ,
                                         G_PKG_NAME             )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.LOAD_EVENT.begin'
                     ,x_msg         => 'Beginning of Loading the global tables'
                     ,x_log_level   => 5);
  End If;

  --If return status is success then populating the global tables

G_event_in_tbl(G_event_tbl_count).P_pm_event_reference             :=P_pm_event_reference;
G_event_in_tbl(G_event_tbl_count).P_task_number                    :=P_task_number;
G_event_in_tbl(G_event_tbl_count).P_event_number                   :=P_event_number;
G_event_in_tbl(G_event_tbl_count).P_event_type                     :=P_event_type;
-- Added the below three lines for Federal Uptake
G_event_in_tbl(G_event_tbl_count).P_agreement_number               :=P_agreement_number;
G_event_in_tbl(G_event_tbl_count).P_agreement_type                 :=P_agreement_type;
G_event_in_tbl(G_event_tbl_count).P_customer_number                :=P_customer_number;
G_event_in_tbl(G_event_tbl_count).P_description                    :=P_description;
G_event_in_tbl(G_event_tbl_count).P_bill_hold_flag                 :=P_bill_hold_flag;
G_event_in_tbl(G_event_tbl_count).P_completion_date                :=P_completion_date;
G_event_in_tbl(G_event_tbl_count).P_desc_flex_name                 :=P_desc_flex_name;
G_event_in_tbl(G_event_tbl_count).P_attribute_category             :=P_attribute_category;
G_event_in_tbl(G_event_tbl_count).P_attribute1                     :=P_attribute1;
G_event_in_tbl(G_event_tbl_count).P_attribute2                     :=P_attribute2;
G_event_in_tbl(G_event_tbl_count).P_attribute3                     :=P_attribute3;
G_event_in_tbl(G_event_tbl_count).P_attribute4                     :=P_attribute4;
G_event_in_tbl(G_event_tbl_count).P_attribute5                     :=P_attribute5;
G_event_in_tbl(G_event_tbl_count).P_attribute6                     :=P_attribute6;
G_event_in_tbl(G_event_tbl_count).P_attribute7                     :=P_attribute7;
G_event_in_tbl(G_event_tbl_count).P_attribute8                     :=P_attribute8;
G_event_in_tbl(G_event_tbl_count).P_attribute9                     :=P_attribute9;
G_event_in_tbl(G_event_tbl_count).P_attribute10                    :=P_attribute10;
G_event_in_tbl(G_event_tbl_count).P_project_number                 :=P_project_number;
G_event_in_tbl(G_event_tbl_count).P_organization_name              :=P_organization_name;
G_event_in_tbl(G_event_tbl_count).P_inventory_org_name             :=P_inventory_org_name;
G_event_in_tbl(G_event_tbl_count).P_inventory_item_id              :=P_inventory_item_id;
G_event_in_tbl(G_event_tbl_count).P_quantity_billed                :=P_quantity_billed;
G_event_in_tbl(G_event_tbl_count).P_uom_code                       :=P_uom_code;
G_event_in_tbl(G_event_tbl_count).P_unit_price                     :=P_unit_price;
G_event_in_tbl(G_event_tbl_count).P_reference1                     :=P_reference1;
G_event_in_tbl(G_event_tbl_count).P_reference2                     :=P_reference2;
G_event_in_tbl(G_event_tbl_count).P_reference3                     :=P_reference3;
G_event_in_tbl(G_event_tbl_count).P_reference4                     :=P_reference4;
G_event_in_tbl(G_event_tbl_count).P_reference5                     :=P_reference5;
G_event_in_tbl(G_event_tbl_count).P_reference6                     :=P_reference6;
G_event_in_tbl(G_event_tbl_count).P_reference7                     :=P_reference7;
G_event_in_tbl(G_event_tbl_count).P_reference8                     :=P_reference8;
G_event_in_tbl(G_event_tbl_count).P_reference9                     :=P_reference9;
G_event_in_tbl(G_event_tbl_count).P_reference10                    :=P_reference10;
G_event_in_tbl(G_event_tbl_count).P_bill_trans_currency_code       :=P_bill_trans_currency_code;
G_event_in_tbl(G_event_tbl_count).P_bill_trans_bill_amount         :=P_bill_trans_bill_amount;
G_event_in_tbl(G_event_tbl_count).P_bill_trans_rev_amount          :=P_bill_trans_rev_amount;
G_event_in_tbl(G_event_tbl_count).P_project_rate_type              :=P_project_rate_type;
G_event_in_tbl(G_event_tbl_count).P_project_rate_date              :=P_project_rate_date;
G_event_in_tbl(G_event_tbl_count).P_project_exchange_rate          :=P_project_exchange_rate;
G_event_in_tbl(G_event_tbl_count).P_projfunc_rate_type             :=P_projfunc_rate_type;
G_event_in_tbl(G_event_tbl_count).P_projfunc_rate_date             :=P_projfunc_rate_date;
G_event_in_tbl(G_event_tbl_count).P_projfunc_exchange_rate         :=P_projfunc_exchange_rate;
G_event_in_tbl(G_event_tbl_count).P_funding_rate_type              :=P_funding_rate_type;
G_event_in_tbl(G_event_tbl_count).P_funding_rate_date              :=P_funding_rate_date;
G_event_in_tbl(G_event_tbl_count).P_funding_exchange_rate          :=P_funding_exchange_rate;
G_event_in_tbl(G_event_tbl_count).P_adjusting_revenue_flag         :=P_adjusting_revenue_flag;
G_event_in_tbl(G_event_tbl_count).P_event_id                       :=P_event_id;

  G_event_tbl_count := G_event_tbl_count+1;

  pa_debug.reset_err_stack; -- Reset error stack
EXCEPTION
        WHEN FND_API.G_EXC_ERROR
                THEN
                p_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                        (   p_count             =>      p_msg_count     ,
                            p_data              =>      p_msg_data      );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
                THEN
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                        (   p_count             =>      p_msg_count
                         ,  p_data              =>      p_msg_data      );

        WHEN OTHERS
                THEN
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                PA_EVENT_PUB.PACKAGE_NAME
                :='(event_reference='||G_event_in_tbl(G_event_tbl_count).P_pm_event_reference||')'||PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'LOAD_EVENT';

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
                PACKAGE_NAME:=NULL;
                PROCEDURE_NAME:=NULL;
                END IF;

                FND_MSG_PUB.Count_And_Get
                        (   p_count             =>      p_msg_count     ,
                            p_data              =>      p_msg_data      );


END LOAD_EVENT;

-- ============================================================================
--
--Name:               EXECUTE_CREATE_EVENT
--Type:               Procedure
--Description:        This procedure can be used to create an event
--                    using global PL/SQL tables.
--
--Called subprograms: XXX
--
--History:
-- ============================================================================
PROCEDURE EXECUTE_CREATE_EVENT
(p_api_version_number	IN	NUMBER
,p_commit		IN	VARCHAR2
,p_init_msg_list	IN	VARCHAR2
,p_pm_product_code	IN	VARCHAR2
,p_event_id_out		OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_msg_count            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,p_return_status        OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

AS
p_api_name              VARCHAR2(100):='EXECUTE_CREATE_EVENT';
l_encoded		varchar2(1):='F';
BEGIN
  -- Initialize the Error Stack
  pa_debug.set_err_stack('PA_EVENT_PUB.EXECUTE_CREATE_EVENT');

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.EXECUTE_CREATE_EVENT.begin'
                     ,x_msg         => 'Beginning of Execute_Create_Event'
                     ,x_log_level   => 5);
  End If;



  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.EXECUTE_CREATE_EVENT.begin'
                     ,x_msg         => 'Beginning of  api compatibility check '
                     ,x_log_level   => 5);
  End If;

--  Standard call to check for api compatibility.
    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         p_api_name             ,
                                         G_PKG_NAME             )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.EXECUTE_CREATE_EVENT.begin'
                     ,x_msg         => 'Calling Create_event '
                     ,x_log_level   => 5);
  End If;

  --- Calling Create_event procedure for further processing
    Create_event
	(P_api_version_number		 =>p_api_version_number
	,P_commit                        =>p_commit
	,P_init_msg_list                 =>p_init_msg_list
	,P_msg_count                     =>p_msg_count
	,P_msg_data                      =>p_msg_data
	,P_return_status                 =>p_return_status
	,P_pm_product_code               =>p_pm_product_code
	,P_event_in_tbl                  =>G_event_in_tbl
	,P_event_out_tbl                 =>G_event_out_tbl);


	   If p_return_status <> FND_API.G_RET_STS_SUCCESS
	   Then
		IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR
		THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		ELSIF p_return_status = FND_API.G_RET_STS_ERROR
		THEN
				RAISE FND_API.G_EXC_ERROR;
		END IF;
	   End If;

   -- If single event is processed then return the event_id
    If G_event_out_tbl.count = 1
    Then
      p_event_id_out := G_event_out_tbl(0).event_id;
    End If;

  -- Call fetch_event API in case of multiple events creation
  -- to get the event id of new events created

   pa_debug.reset_err_stack; -- Reset error stack


EXCEPTION
        WHEN FND_API.G_EXC_ERROR
                THEN
                p_event_id_out := NULL; -- NOCOPY
                p_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                        ( p_encoded           =>      l_encoded
                         ,p_count             =>      p_msg_count
                         ,p_data              =>      p_msg_data      );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
                THEN
                p_event_id_out := NULL; -- NOCOPY
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                        ( p_encoded           =>      l_encoded
                         ,p_count             =>      p_msg_count
                         ,p_data              =>      p_msg_data      );

        WHEN OTHERS
                THEN
                p_event_id_out := NULL; -- NOCOPY
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                PA_EVENT_PUB.PACKAGE_NAME
                :=PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'EXECUTE_CREATE_EVENT';

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
                PACKAGE_NAME:=NULL;
                PROCEDURE_NAME:=NULL;
                END IF;

                FND_MSG_PUB.Count_And_Get
                        ( p_encoded           =>      l_encoded
                         ,p_count             =>      p_msg_count
                         ,p_data              =>      p_msg_data      );


END EXECUTE_CREATE_EVENT;

-- ============================================================================
--
--Name:               EXECUTE_UPDATE_EVENT
--Type:               Procedure
--Description:        This procedure can be used to update an event
--                    using global PL/SQL tables.
--
--Called subprograms: XXX
--
--History:
--
-- ============================================================================

PROCEDURE EXECUTE_UPDATE_EVENT
(p_api_version_number	IN	NUMBER
,p_commit		IN	VARCHAR2
,p_init_msg_list	IN	VARCHAR2
,p_pm_product_code	IN	VARCHAR2
,p_msg_count            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,p_return_status        OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

AS

p_api_name		VARCHAR2(100):='EXECUTE_UPDATE_EVENT';
l_encoded               VARCHAR2(1):='F';

BEGIN

  -- Initialize the Error Stack
  pa_debug.set_err_stack('PA_EVENT_PUB.EXECUTE_UPDATE_EVENT');

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.EXECUTE_UPDATE_EVENT.begin'
                     ,x_msg         => 'Beginning of Execute_Update_Event'
                     ,x_log_level   => 5);
  End If;


  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.EXECUTE_UPDATE_EVENT.begin'
                     ,x_msg         => 'Beginning of  api compatibility check '
                     ,x_log_level   => 5);
  End If;

--  Standard call to check for api compatibility.
    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         p_api_name             ,
                                         G_PKG_NAME             )
    THEN
	p_return_status:=FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.EXECUTE_UPDATE_EVENT.begin'
                     ,x_msg         => 'Calling Update_event '
                     ,x_log_level   => 5);
  End If;

  --Calling update_event procedure for further processing

    UPDATE_EVENT
        (P_api_version_number            =>p_api_version_number
        ,P_commit                        =>p_commit
        ,P_init_msg_list                 =>p_init_msg_list
        ,P_msg_count                     =>p_msg_count
        ,P_msg_data                      =>p_msg_data
        ,P_return_status                 =>p_return_status
        ,P_pm_product_code               =>p_pm_product_code
        ,P_event_in_tbl                  =>G_event_in_tbl
        ,P_event_out_tbl                 =>G_event_out_tbl);

	   If p_return_status <> FND_API.G_RET_STS_SUCCESS
	   Then
		IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR
		THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		ELSIF p_return_status = FND_API.G_RET_STS_ERROR
		THEN
				RAISE FND_API.G_EXC_ERROR;
		END IF;
	   End If;

   pa_debug.reset_err_stack; -- Reset error stack


EXCEPTION
        WHEN FND_API.G_EXC_ERROR
                THEN
                p_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                        ( p_encoded           =>      l_encoded
                         ,p_count             =>      p_msg_count
                         ,p_data              =>      p_msg_data      );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
                THEN
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                        ( p_encoded           =>      l_encoded
                         ,p_count             =>      p_msg_count
                         ,p_data              =>      p_msg_data      );

        WHEN OTHERS
                THEN
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                PA_EVENT_PUB.PACKAGE_NAME
                :=PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'EXECUTE_UPDATE_EVENT';

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
                PACKAGE_NAME:=NULL;
                PROCEDURE_NAME:=NULL;
                END IF;

                FND_MSG_PUB.Count_And_Get
                        ( p_encoded           =>      l_encoded
                         ,p_count             =>      p_msg_count
                         ,p_data              =>      p_msg_data      );

END EXECUTE_UPDATE_EVENT;

-- ============================================================================
--
--Name:               clear_event
--Type:               Procedure
--Description:        This procedure can be used to clear the global PL/SQL
--                    tables that are used by a LOAD/EXECUTE/FETCH cycle.
--
--Called subprograms: init_event
--History:
--
-- =======================================================================
PROCEDURE CLEAR_EVENT
AS

BEGIN
  -- Call init_event procedure
    init_event;

EXCEPTION
	WHEN OTHERS
	THEN

                PA_EVENT_PUB.PACKAGE_NAME
                :=PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CLEAR_EVENT';

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
                PACKAGE_NAME:=NULL;
                PROCEDURE_NAME:=NULL;
                END IF;

END CLEAR_EVENT;


-- ============================================================================
--
--Name:               fetch_event
--Type:               Procedure
--Description:        This procedure can be used to return the event_ids to the
--		      external system  .
--
--Called subprograms: XXX
--
--
--
--History:
--
--  ============================================================================
PROCEDURE FETCH_EVENT
       (p_api_version_number		IN		NUMBER
	,P_pm_product_code		IN		VARCHAR2
	,P_pm_event_reference		IN		VARCHAR2
	,P_event_id_out			OUT		NOCOPY NUMBER --File.Sql.39 bug 4440895
	,p_return_status                OUT             NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
tot_recs		NUMBER:=0;
p_api_name		VARCHAR2(100):='FETCH_EVENT';
p_msg_count		NUMBER;
p_msg_data		VARCHAR2(2000);
l_encoded		VARCHAR2(1):='F';
BEGIN

  -- Initialize the Error Stack
  pa_debug.set_err_stack('PA_EVENT_PUB.FETCH_EVENT');

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.FETCH_EVENT.begin'
                     ,x_msg         => 'Beginning of Fetch_Event'
                     ,x_log_level   => 5);
  End If;


  --Set savepoint
    Savepoint fetch_event;
      p_msg_count := 0;
      p_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.FETCH_EVENT.begin'
                     ,x_msg         => 'Beginning of  api compatibility check '
                     ,x_log_level   => 5);
  End If;

--  Standard call to check for api compatibility.
    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         p_api_name             ,
                                         G_PKG_NAME             )
    THEN
        p_return_status:=FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- CHECK WHETHER MANDATORY INCOMING PARAMETER PRODUCT CODE EXIST

    IF (p_pm_product_code IS NULL)
        OR (p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISS'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'EVENT'
                        ,p_attribute1       => ''
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         p_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
    END IF;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.FETCH_EVENT.begin'
                     ,x_msg         => 'Begin Fetching event_id from event_reference'
                     ,x_log_level   => 5);
  End If;


 --Deriving event_id from p_pm_event_reference.
    If(p_pm_event_reference Is NOT NULL
	And p_pm_event_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    Then
        While tot_recs <= G_event_tbl_count
	loop
	    If (G_event_out_tbl(tot_recs).pm_event_reference = p_pm_event_reference )
	    Then
		  P_event_id_out:=G_event_out_tbl(tot_recs).event_id;
		  Exit;
	    End If;
	    tot_recs :=tot_recs + 1;
	End Loop;
    Else
            If FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            Then
			FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- Bug 2257612
               		FND_MESSAGE.SET_TOKEN('ATTR_NAME','p_pm_event_reference');
               		FND_MESSAGE.SET_TOKEN('ATTR_VALUE', p_pm_event_reference);
               		FND_MSG_PUB.ADD;
             End If;
         p_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
    END IF;

	FND_MSG_PUB.Count_And_Get
		(   p_encoded           =>      l_encoded
		 ,  p_count             =>      p_msg_count
		 ,  p_data              =>      p_msg_data      );


  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.FETCH_EVENT.begin'
                     ,x_msg         => 'End of Fetch_Event'
                     ,x_log_level   => 5);
  End If;

   pa_debug.reset_err_stack; -- Reset error stack

EXCEPTION
        WHEN FND_API.G_EXC_ERROR
                THEN
		ROLLBACK to fetch_event;
                p_event_id_out := NULL; -- NOCOPY
                p_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                        (   p_encoded           =>      l_encoded
                         ,  p_count             =>      p_msg_count
                         ,  p_data              =>      p_msg_data      );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
                THEN
                ROLLBACK to fetch_event;
                p_event_id_out := NULL; -- NOCOPY
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                        (   p_encoded           =>      l_encoded
                         ,  p_count             =>      p_msg_count
                         ,  p_data              =>      p_msg_data      );

        WHEN OTHERS
                THEN
                ROLLBACK to fetch_event;
                p_event_id_out := NULL; -- NOCOPY
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                PA_EVENT_PUB.PACKAGE_NAME
                :='(event_reference='||p_pm_event_reference||')'||PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'FETCH_EVENT';

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
                PACKAGE_NAME:=NULL;
                PROCEDURE_NAME:=NULL;
                END IF;

                FND_MSG_PUB.Count_And_Get
                        (   p_encoded           =>      l_encoded
                         ,  p_count             =>      p_msg_count
                         ,  p_data              =>      p_msg_data      );


END FETCH_EVENT;

-- ============================================================================
--
--Name:               CHECK_DELETE_EVENT_OK
--Type:               procedure
--Description: This API ONLY checks if an existing event or a set of existing events
--             can be deleted or not.
--Called subprograms:
--
--
--
--History:

-- ============================================================================
PROCEDURE CHECK_DELETE_EVENT_OK
(P_api_version_number	IN	NUMBER
,P_commit		IN	VARCHAR2
,P_init_msg_list	IN	VARCHAR2
,P_pm_product_code	IN	VARCHAR2
,P_pm_event_reference	IN	VARCHAR2
,P_event_id		IN	NUMBER
,P_del_event_ok_flag	OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,P_msg_count            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,P_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,P_return_status        OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895


AS
p_api_name		VARCHAR2(100):='CHECK_DELETE_EVENT_OK';
l_event_id		NUMBER:=NULL;
l_encoded		VARCHAR2(1):='F';
l_pm_event_reference    VARCHAR2(25);
BEGIN
  -- Initialize the Error Stack
  pa_debug.set_err_stack('PA_EVENT_PUB.CHECK_DELETE_EVENT_OK');

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.CHECK_DELETE_EVENT_OK.begin'
                     ,x_msg         => 'Beginning of Check_Delete_Event_Ok'
                     ,x_log_level   => 5);
   END IF;

  --Set savepoint
    Savepoint check_delete_event_ok;
      p_msg_count := 0;
      p_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.CHECK_DELETE_EVENT_OK.begin'
                     ,x_msg         => 'Calling  mandatory input parameters-1'
                     ,x_log_level   => 5);
   END IF;

 --Validating mandatory input parameters-1

   PA_EVENT_PVT.CHECK_MDTY_PARAMS1
    ( p_api_version_number             =>p_api_version_number
     ,p_api_name                       =>p_api_name
     ,p_pm_product_code                =>p_pm_product_code
     ,p_function_name                  =>'PA_EV_DEL_EVENT_OK'
     ,x_return_status                  =>p_return_status
     ,x_msg_count                      =>p_msg_count
     ,x_msg_data                       =>p_msg_data );

   If p_return_status <> FND_API.G_RET_STS_SUCCESS
   Then
        IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF p_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
   End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.CHECK_DELETE_EVENT_OK.begin'
		     ,x_msg         => 'Calling conv_event_ref_to_id'
		     ,x_log_level   => 5);
  END IF;

    l_event_id:=p_event_id;
 --Validation of event_id or pm_event_reference and conversion to event_id
    If PA_EVENT_PVT.CONV_EVENT_REF_TO_ID
          (P_pm_product_code      =>P_pm_product_code
          ,P_pm_event_reference   =>l_pm_event_reference
          ,P_event_id             =>l_event_id)
          ='N'
    Then
          p_return_status             := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
    End If;

  --Log Message
  IF l_debug_mode = 'Y' THEN
  pa_debug.write_log (x_module      => 'pa.plsql.PA_EVENT_PUB.CHECK_DELETE_EVENT_OK.begin'
                     ,x_msg         => 'Calling Check_Event_Processed'
                     ,x_log_level   => 5);
  END IF;


  --Validating if the event is billed or revenue distributed
  --Calls PA_EVENT_UTILS.CHECK_EVENT_PROCESSED

    If PA_EVENT_UTILS.CHECK_EVENT_PROCESSED
	(P_event_id		=>l_event_id) IN ('N','I','R')/*For Bug 7305416*/
    Then
          pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_TK_EVENT_IN_USE'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'EVENT'
            ,p_attribute1       => l_pm_event_reference
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
    END IF;

	FND_MSG_PUB.Count_And_Get
		(   p_encoded           =>      l_encoded
		 ,  p_count             =>      p_msg_count
		 ,  p_data              =>      p_msg_data      );

   pa_debug.reset_err_stack; -- Reset error stack


EXCEPTION
        WHEN FND_API.G_EXC_ERROR
                THEN
		ROLLBACK to check_delete_event_ok;
                p_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
			(   p_encoded           =>      l_encoded
			 ,  p_count             =>      p_msg_count
			 ,  p_data              =>      p_msg_data      );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
                THEN
                ROLLBACK to check_delete_event_ok;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                        (   p_encoded           =>      l_encoded
                         ,  p_count             =>      p_msg_count
                         ,  p_data              =>      p_msg_data      );

        WHEN OTHERS
                THEN
                ROLLBACK to check_delete_event_ok;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                PA_EVENT_PUB.PACKAGE_NAME
                :='(event_reference='||p_pm_event_reference||')'||PA_EVENT_PUB.PACKAGE_NAME||'PUBLIC';
                PA_EVENT_PUB.PROCEDURE_NAME:=PA_EVENT_PUB.PROCEDURE_NAME||substr(sqlerrm,1,80)||'CHECK_DELETE_EVENT_OK';

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                               ( p_pkg_name            => PACKAGE_NAME
                               , p_procedure_name      => PROCEDURE_NAME );
                PACKAGE_NAME:=NULL;
                PROCEDURE_NAME:=NULL;
                END IF;

                FND_MSG_PUB.Count_And_Get
                        (   p_encoded           =>      l_encoded
                         ,  p_count             =>      p_msg_count
                         ,  p_data              =>      p_msg_data      );


END CHECK_DELETE_EVENT_OK;

END PA_EVENT_PUB;

/
