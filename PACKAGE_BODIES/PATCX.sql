--------------------------------------------------------
--  DDL for Package Body PATCX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PATCX" AS
/* $Header: PAXTTCXB.pls 120.1 2005/08/08 10:51:46 sbharath noship $ */

  PROCEDURE  tc_extension (
              X_project_id                IN NUMBER
            , X_task_id                   IN NUMBER
            , X_expenditure_item_date     IN DATE
            , X_expenditure_type          IN VARCHAR2
            , X_non_labor_resource        IN VARCHAR2
            , X_incurred_by_person_id     IN NUMBER
            , X_quantity                  IN NUMBER    DEFAULT NULL
            , X_denom_currency_code       IN VARCHAR2  DEFAULT NULL
	    , X_acct_currency_code        IN VARCHAR2  DEFAULT NULL
            , X_denom_raw_cost            IN NUMBER    DEFAULT NULL
            , X_acct_raw_cost             IN NUMBER    DEFAULT NULL
            , X_acct_rate_type            IN VARCHAR2  DEFAULT NULL
            , X_acct_rate_date            IN DATE      DEFAULT NULL
            , X_acct_exchange_rate        IN NUMBER    DEFAULT NULL
            , X_transferred_from_id       IN NUMBER    DEFAULT NULL
            , X_incurred_by_org_id        IN NUMBER    DEFAULT NULL
            , X_nl_resource_org_id        IN NUMBER    DEFAULT NULL
            , X_transaction_source        IN VARCHAR2  DEFAULT NULL
            , X_calling_module            IN VARCHAR2  DEFAULT NULL
	    , X_vendor_id		  IN NUMBER    DEFAULT NULL
            , X_entered_by_user_id        IN NUMBER    DEFAULT NULL
            , X_attribute_category        IN VARCHAR2  DEFAULT NULL
            , X_attribute1                IN VARCHAR2  DEFAULT NULL
            , X_attribute2                IN VARCHAR2  DEFAULT NULL
            , X_attribute3                IN VARCHAR2  DEFAULT NULL
            , X_attribute4                IN VARCHAR2  DEFAULT NULL
            , X_attribute5                IN VARCHAR2  DEFAULT NULL
            , X_attribute6                IN VARCHAR2  DEFAULT NULL
            , X_attribute7                IN VARCHAR2  DEFAULT NULL
            , X_attribute8                IN VARCHAR2  DEFAULT NULL
            , X_attribute9                IN VARCHAR2  DEFAULT NULL
            , X_attribute10               IN VARCHAR2  DEFAULT NULL
	    , X_attribute11               IN VARCHAR2  DEFAULT NULL
            , X_attribute12               IN VARCHAR2  DEFAULT NULL
            , X_attribute13               IN VARCHAR2  DEFAULT NULL
            , X_attribute14               IN VARCHAR2  DEFAULT NULL
            , X_attribute15               IN VARCHAR2  DEFAULT NULL
            , X_msg_application       IN  OUT NOCOPY VARCHAR2
            , X_billable_flag         IN  OUT NOCOPY VARCHAR2
            , X_msg_type                  OUT NOCOPY VARCHAR2
            , X_msg_token1                OUT NOCOPY VARCHAR2
            , X_msg_token2                OUT NOCOPY VARCHAR2
            , X_msg_token3                OUT NOCOPY VARCHAR2
            , X_msg_count                 OUT NOCOPY NUMBER
            , X_outcome                   OUT NOCOPY VARCHAR2
            , p_projfunc_currency_code    IN VARCHAR2  default null
            , p_projfunc_cost_rate_type   IN VARCHAR2  default null
            , p_projfunc_cost_rate_date   IN DATE      default null
            , p_projfunc_cost_exchg_rate  IN NUMBER    default null
            , x_assignment_id         IN  OUT NOCOPY NUMBER
            , p_work_type_id              IN NUMBER    default null
            , p_sys_link_function         IN VARCHAR2  default null
            , P_Po_Header_Id              IN NUMBER    default null
	    , P_Po_Line_Id                IN NUMBER    default null
	    , P_Person_Type               IN VARCHAR2  default null
	    , P_Po_Price_Type             IN VARCHAR2  default null
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
  BEGIN

    X_outcome := NULL;     -- Initialize output parameter
    X_msg_type := 'E';     -- Initiliaze Error/Warning indicator parameter

    -- Add your Transaction Control Extensions logic here

    NULL;

    -- Add your Transaction Control Extension logic for Warnings here.
    -- Always code your warning section last. Before returning set your
    -- X_msg_type parameter to 'W' for warnings.
  EXCEPTION
    WHEN  OTHERS  THEN
      -- Add your exception handling logic here

      NULL;

  END  tc_extension;

END PATCX;

/
