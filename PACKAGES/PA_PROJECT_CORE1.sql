--------------------------------------------------------
--  DDL for Package PA_PROJECT_CORE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_CORE1" AUTHID CURRENT_USER as
-- $Header: PAXPCO1S.pls 120.4.12010000.4 2009/04/23 15:00:07 jsundara ship $

--
--  PROCEDURE
--              get_project_number_by_numcode
--  PURPOSE
--              This procedure retrieves project number for a specified
--              project id according to the implementation-defined Project
--              number generation mode.  If mode is 'MANUAL', the
--      user-provided project number is used; otherwise, a system
--      generated number will be generted.
--
procedure get_project_number_by_numcode ( x_orig_proj_num     IN varchar2
                            , x_resu_proj_num     IN OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
                            , x_proj_number_gen_mode OUT NOCOPY varchar2 -- Added for Bug# 7445534
                            , x_err_code          IN OUT NOCOPY number --File.Sql.39 bug 4440895
                            , x_err_stage         IN OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
                            , x_err_stack         IN OUT NOCOPY varchar2); --File.Sql.39 bug 4440895

--
--  PROCEDURE
--              revert_proj_number
--  PURPOSE
--              This procedure reverts the project number if an error
--              has occured. Added for Bug# 7445534
--
PROCEDURE revert_proj_number(p_proj_number_gen_mode IN VARCHAR2
                            ,p_project_number IN VARCHAR2 );


--
--  PROCEDURE
--              copy_project
--  PURPOSE
--
--              The objective of this procedure is to create a new
--              project and other project related information such
--              as wbs, project players, budget information, billing,
--              and costing information by copying from a specific project
--              and its related information.
--
--              Users can choose whether to copy budget, tasks, and task
--              related information by passing in 'Y' or 'N' for the
--              x_copy_task_flag and x_copy_budget_flag parameters.
--              Users can also choose whether to use copy override
--              associated with the original project by passing in
--              'Y' or 'N' for x_use_override_flag.  If 'Y' is passed
--              for x_use_override_flag, then project players with
--              project roles that are overrideable, project classes
--              with categories that are overrideable, and customers
--              with relationship role type that are overrideable will
--              not get copied from the original project to the new
--              project.  The overrideable information can be entered
--              via the Enter Project form in this case.
--
--              If no value is provided for any of these flag, the
--              default is 'Y'.
--
--      User can pass 'Y' or 'N' for x_template_flag to indicate
--      whether the resulting record is a template or not.  If
--      no value is passed, the default is 'N'.
--
procedure copy_project (
           x_orig_project_id        IN   number
            , x_project_name             IN   varchar2
                        , x_long_name                 IN          VARCHAR2 default null
            , x_project_number        IN      varchar2
            , x_description          IN   varchar2
            , x_project_type             IN   varchar2
            , x_project_status_code    IN   varchar2
                        , x_distribution_rule      IN   varchar2
            , x_public_sector_flag     IN     varchar2
            , x_organization_id        IN   number
            , x_start_date               IN   date
            , x_completion_date       IN      date
                        , x_probability_member_id  IN   number
                        , x_project_value          IN   number
                        , x_expected_approval_date IN   date
--MCA Sakthi for MultiAgreementCurreny Project
                        , x_agreement_currency     IN   VARCHAR2
                        , x_agreement_amount       IN   NUMBER
                        , x_agreement_org_id       IN   NUMBER
--MCA Sakthi for MultiAgreementCurreny Project
            , x_copy_task_flag        IN      varchar2
            , x_copy_budget_flag       IN   varchar2
                        , x_use_override_flag      IN   varchar2
                        , x_copy_assignment_flag   IN   varchar2 default 'N'
            , x_template_flag            IN   varchar2
            , x_project_id             OUT   NOCOPY number --File.Sql.39 bug 4440895
         , x_err_code           IN OUT   NOCOPY number --File.Sql.39 bug 4440895
         , x_err_stage          IN OUT   NOCOPY varchar2 --File.Sql.39 bug 4440895
         , x_err_stack          IN OUT   NOCOPY varchar2 --File.Sql.39 bug 4440895
            , x_customer_id           IN      number default NULL
            , x_new_project_number IN OUT   NOCOPY varchar2 --File.Sql.39 bug 4440895
            , x_pm_product_code       IN      varchar2 default NULL
            , x_pm_project_reference   IN     varchar2 default NULL
	    , x_project_currency_code  IN     varchar2 default NULL /* 8297384 */
            , x_attribute_category     IN   varchar2 default NULL
            , x_attribute1             IN   varchar2 default NULL
            , x_attribute2             IN   varchar2 default NULL
            , x_attribute3             IN   varchar2 default NULL
            , x_attribute4             IN   varchar2 default NULL
            , x_attribute5             IN   varchar2 default NULL
            , x_attribute6             IN   varchar2 default NULL
            , x_attribute7             IN   varchar2 default NULL
            , x_attribute8             IN   varchar2 default NULL
            , x_attribute9             IN   varchar2 default NULL
            , x_attribute10            IN   varchar2 default NULL
         , x_actual_start_date      IN   DATE     default NULL
         , x_actual_finish_date     IN   DATE     default NULL
         , x_early_start_date       IN   DATE     default NULL
         , x_early_finish_date      IN   DATE     default NULL
         , x_late_start_date        IN   DATE     default NULL
         , x_late_finish_date       IN   DATE     default NULL
         , x_scheduled_start_date   IN   DATE     default NULL
         , x_scheduled_finish_date  IN   DATE     default NULL
         , x_team_template_id       IN   NUMBER
         , x_country_code           IN   VARCHAR2
         , x_region                 IN   VARCHAR2
         , x_city                   IN   VARCHAR2
         , x_opp_value_currency_code IN  VARCHAR2
         , x_org_project_copy_flag  IN   VARCHAR2 default 'N'
         , x_priority_code          IN   VARCHAR2 default null
         , x_security_level         IN   NUMBER   default 1
         --Bug 3279981
         , p_en_top_task_cust_flag    IN VARCHAR2 default null
         , p_en_top_task_inv_mth_flag IN VARCHAR2 default null
         --Bug 3279981
	--sunkalya:federal Bug#5511353
         , p_date_eff_funds_flag      IN VARCHAR2 default null
	--sunkalya:federal Bug#5511353
         , p_ar_rec_notify_flag       IN VARCHAR2 default 'N'         -- 7508661 : EnC
         , p_auto_release_pwp_inv     IN VARCHAR2 default 'Y'         -- 7508661 : EnC
       );

/*********************************************************************
** Get_Next_Avail_Proj_Num
**          Procedure to return the next available
**     Project number for automatic project numbering.
**
** Called when the new automatic project number generated is not unique.
**
** Parameters :
**    Start_proj_num - Project number(segment1) which was found to be
**                     non-unique. It starts from the next number.
**    No_tries       - The no of times it should loop around for checking
**                     the uniqueness of the project number.
**    Next_proj_num  - Next Project number
**    x_error_code   - 0 if unique number found in the tries specified
**                     1 if unique number not found
**                     SQLCODE (< 0) if exception raised.
**    x_error_stage  - Message
**    x_error_stack  - The Satck of procedures.
**
** Author - tsaifee  01/24/97
**
*********************************************************************/

Procedure Get_Next_Avail_Proj_Num (
                            Start_proj_num IN Number,
                             No_tries IN Number,
                             Next_proj_num IN OUT NOCOPY Number, --File.Sql.39 bug 4440895
                             x_error_code IN OUT NOCOPY Number, --File.Sql.39 bug 4440895
                             x_error_stack IN OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                             x_error_stage IN OUT NOCOPY Varchar2 ); --File.Sql.39 bug 4440895

--
-- FUNCTION
--
--          Get_Message_from_stack
--          This function returns message from the stack and if does not
--          find one then returns whatever message passed to it.
-- HISTORY
--     12-DEC-01      MAansari    -Created

FUNCTION Get_Message_from_stack( p_err_stage IN VARCHAR2 ) RETURN VARCHAR2;


-- PROCEDURE : populate_copy_options
-- PURPOSE   : This API should be called to populate values for copy options into the global
--             temporary table PA_PROJECT_COPY_OPTIONS_TMP
PROCEDURE populate_copy_options( p_api_version      IN  NUMBER   := 1.0
                                ,p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE
                                ,p_commit           IN  VARCHAR2 := FND_API.G_FALSE
                                ,p_validate_only    IN  VARCHAR2 := FND_API.G_TRUE
                                ,p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                ,p_calling_module   IN  VARCHAR2 := 'SELF_SERVICE'
                                ,p_debug_mode       IN  VARCHAR2 := 'N'
                                ,p_context_tbl      IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
                                ,p_flag_tbl         IN SYSTEM.PA_VARCHAR2_1_TBL_TYPE  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE()
                                ,p_version_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE()
                                ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                ,x_msg_count      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                ,x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                ) ;

-- PROCEDURE : populate_default_copy_options
-- PURPOSE   : This API should be called to populate default values for copy options into the global
--             temporary table PA_PROJECT_COPY_OPTIONS_TMP
PROCEDURE populate_default_copy_options( p_api_version      IN  NUMBER := 1.0
                                        ,p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE
                                        ,p_commit           IN  VARCHAR2 := FND_API.G_FALSE
                                        ,p_validate_only    IN  VARCHAR2 := FND_API.G_TRUE
                                        ,p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                        ,p_calling_module   IN  VARCHAR2 := 'SELF_SERVICE'
                                        ,p_debug_mode       IN  VARCHAR2 := 'N'
                                        ,p_src_project_id     IN NUMBER
                                        ,p_src_template_flag  IN VARCHAR2
                                        ,p_dest_template_flag IN VARCHAR2
                                        ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                        ,x_msg_count      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                        ,x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                        );

-- 4363092 Commented COPY_BUDGETORY_CTRL procedure from specification to fix invalid
-- object issue, the fix for 4431234 will be done later after complete analysis
/*
PROCEDURE COPY_BUDGETORY_CTRL
    (
       p_api_version_number    IN   NUMBER   := 1.0
     , p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE
     , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
     , p_src_project_id        IN   NUMBER
     , p_dest_project_id       IN   NUMBER
     , x_return_status     OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count         OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data          OUT   NOCOPY VARCHAR2        --File.Sql.39 bug 4440895
   );
*/

end PA_PROJECT_CORE1 ;


/
