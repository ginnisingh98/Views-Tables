--------------------------------------------------------
--  DDL for Package Body PA_IMPL_OPTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_IMPL_OPTIONS_PUB" AS
/* $Header: PAIMWRPB.pls 120.2 2006/03/17 01:06:37 dthakker noship $*/

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_IMPL_OPTIONS_PUB';

-- API name                      : Check_Incl_rlzd_gain_loss
-- Type                          : PL/SQL Public function
-- Pre-reqs                      : None
-- Return Value                  : VC2
-- Prameters
--
-- p_org_id      IN NUMBER
--
--  History
--
--  16-AUG-02   MAansari             -Created
--
--

FUNCTION Check_Incl_rlzd_gain_loss(
 p_org_id IN NUMBER
 ) RETURN VARCHAR2 IS

  l_return_flag   VARCHAR2(1);
BEGIN

  l_return_flag := PA_FUND_REVAL_UTIL.Valid_Include_gains_losses( p_org_id );

  RETURN( NVL( l_return_flag, 'N' ) );

END Check_Incl_rlzd_gain_loss;

-- API name                      : Check_Incl_rlzd_gain_loss
-- Type                          : PL/SQL Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
--
-- x_return_status      OUT VARCHAR2
--
--  History
--
--  16-AUG-02   MAansari             -Created
--
--

PROCEDURE Upgrade_MRC_fund_bud_flag(
 x_return_status         OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
) IS
BEGIN
  SAVEPOINT upgrade_ou;
  --Clear Error Messages.
  FND_MSG_PUB.initialize;

  UPDATE pa_implementations
     SET ENABLE_MRC_FOR_FUND_FLAG = 'U';

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_IMPL_OPTIONS_PUB',
                          p_procedure_name => 'Upgrade_MRC_fund_bud_flag',
                          p_error_text     => SUBSTRB(SQLERRM,1,240));
  rollback to upgrade_ou;
  raise;
END Upgrade_MRC_fund_bud_flag;

FUNCTION Check_MRC_install(
 x_err_code OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
) RETURN VARCHAR2 IS
    l_return_value  VARCHAR2(1);
BEGIN
    IF PA_MC_FUNDINGS_PKG.check_mrc_install( x_err_code )
    --IF true
    THEN
        l_return_value := 'Y';
    ELSE
        l_return_value := 'N';
    END IF;
    RETURN ( l_return_value );
END Check_MRC_install;

FUNCTION Check_OU_Incl_gain_loss(
 p_org_id IN NUMBER
 ) RETURN VARCHAR2 IS

  l_return_flag   VARCHAR2(1);
BEGIN

  l_return_flag := PA_FUND_REVAL_UTIL.Is_OU_Include_Gains_Losses( p_org_id );

  RETURN( NVL( l_return_flag, 'N' ) );

END Check_OU_Incl_gain_loss;

FUNCTION Check_proj_Incl_gain_loss(
 p_org_id IN NUMBER,
 p_project_type IN VARCHAR2
 ) RETURN VARCHAR2 IS
   CURSOR cur_pa_proj
   IS
     SELECT include_gains_losses_flag
       FROM pa_projects_all
      WHERE org_id = p_org_id -- 5078716 , Removed nvl condition
        AND project_type = p_project_type
        AND include_gains_losses_flag = 'Y';

  l_return_flag   VARCHAR2(1);
BEGIN
     OPEN cur_pa_proj;
     FETCH cur_pa_proj INTO l_return_flag;
     CLOSE cur_pa_proj;
     RETURN NVL( l_return_flag, 'N' );
END Check_proj_Incl_gain_loss;

FUNCTION Is_PT_Include_Gains_Losses(
 p_org_id IN NUMBER,
 p_project_type IN VARCHAR2
 ) RETURN VARCHAR2 IS
  l_return_flag   VARCHAR2(1);
BEGIN
     l_return_flag := PA_FUND_REVAL_UTIL.Is_PT_Include_Gains_Losses( p_org_id, p_project_type );
     RETURN NVL( l_return_flag, 'N' );
END Is_PT_Include_Gains_Losses;


FUNCTION option_updateable(
  p_project_id IN NUMBER
 ,p_option_code VARCHAR2
 ) RETURN VARCHAR2 IS
  l_return_code   VARCHAR2(30) := 'Y';
  l_structure_type  VARCHAR2(30) := 'DELIVERABLE' ; /* Included by avaithia Bug 3476115*/
  l_error_code VARCHAR2(2000) := 'S' ;
BEGIN

    IF p_option_code in( 'WORKPLAN_OPTIONS', 'WORKPLAN_OPTIONS_SS', 'TASK_PROGRESS',
                         'WORKPLAN_STRUCTURE', 'WP_TASK_DET', 'PLANNING_OPTIONS_WP',
                         'CURRENCY_SETTINGS_WP', 'RATE_SCHEDULES_WP' )
    THEN
       IF PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS( p_project_id ) = 'N'
       THEN
           l_return_code := 'PA_SETUP_WRKPLN_OPT_ERR';
       ELSE
           l_return_code := 'Y';
           IF p_option_code = 'WP_TASK_DET'
           THEN
              IF PA_PROJ_TASK_STRUC_PUB.IS_WP_SEPARATE_FROM_FN( p_project_id ) = 'Y'
              THEN
                  l_return_code := 'PA_SETUP_WRKPLN_OPT_ERR2';    --new message ios created for bug 2609565
              END IF;
           END IF;
       END IF;
     -- bug no.3589818 sdnambia start
     -- bug no. 3683346 sdnambia
     --Bug Number :4281752 - Included FINANCIAL_OPTIONS_SS in the following list
     ELSIF p_option_code in ('FBS_SS', 'BUDGETS_AND_FORECASTS', 'PLANNING_OPTIONS', 'CURRENCY_SETTINGS', 'RATE_SCHEDULES','FINANCIAL_OPTIONS_SS')
     THEN
         IF PA_PROJECT_STRUCTURE_UTILS.check_financial_enabled(p_project_id) = 'N'
         THEN
             l_return_code := 'PA_SETUP_FINPLN_OPT_ERR';
         ELSE
             l_return_code := 'Y';
         END IF;
     -- bug no.3589818 sdnambia end
     ELSE  /*Included by avaithia Bug 3476115*/
         IF p_option_code = 'DELIVERABLES_SS' THEN
              PA_PROJECT_STRUCTURE_UTILS.Check_Structure_Type_Exists
              (
               p_project_id          => p_project_id
              ,p_structure_type      => l_structure_type
              ,x_return_status       => l_return_code
              ,x_error_message_code  => l_error_code
              );
              IF l_return_code <> 'E' THEN /*the API is coded so that it returns "E" when the structure type exists and "S" if not*/
                   l_return_code := 'PA_PS_DELIVERABLE_DISABLED' ;
              ELSE
                   l_return_code := 'Y';
              END IF;

         END IF;
    END IF;
    Return l_return_code;
END option_updateable;

FUNCTION check_budget_trans_exists(
  p_project_id IN NUMBER
 ) RETURN VARCHAR2 IS
  l_return_flag   VARCHAR2(1);
BEGIN
     l_return_flag := pa_fin_plan_utils.check_budget_trans_exists( p_project_id );
     RETURN NVL( l_return_flag, 'N' );
END check_budget_trans_exists;

FUNCTION enable_auto_baseline(
  p_project_id IN NUMBER
 ) RETURN VARCHAR2 IS
  l_return_flag   VARCHAR2(1);
BEGIN
     l_return_flag := pa_fin_plan_utils.enable_auto_baseline( p_project_id );
     RETURN NVL( l_return_flag, 'N' );
END enable_auto_baseline;

  -- -----------------------------------------------------
  -- procedure Update_Access_level
  --
  -- This procedure is invoked when concurrent program
  -- PRC: Update Project Access Level is run
  -- -----------------------------------------------------
  procedure Update_Access_level
  ( errbuf                     out NOCOPY varchar2, --File.Sql.39 bug 4440895
    retcode                    out NOCOPY varchar2, --File.Sql.39 bug 4440895
    p_from_project_number      in  varchar2 default null,
    p_to_project_number        in varchar2 default null,
    p_project_status           in varchar2 default null,
    p_project_type             in varchar2 default null,
    p_project_organization     in number default null,
    p_access_level             in varchar2 default '1'
  ) is

  cursor c_projects is
    select project_id
    from   pa_projects_all
    where  segment1                     >= nvl(p_from_project_number, segment1)
    and    segment1                     <= nvl(p_to_project_number, segment1)
    and    project_status_code          = nvl(p_project_status, project_status_code)
    and    project_type                 = nvl(p_project_type, project_type)
    and    carrying_out_organization_id = nvl(p_project_organization,carrying_out_organization_id);

  l_commit_size number := 5000;
  l_loop_count number := 0;
  l_last_update_date date;
  l_last_updated_by number;
  l_last_update_login number;

  begin

    l_last_update_date := sysdate;
    l_last_updated_by  := fnd_global.user_id;
    l_last_update_login := fnd_global.user_id;

   IF p_access_level is not null THEN

    for rec in c_projects loop

      update pa_projects_all
        set security_level      = to_number( p_access_level),
            last_update_date    = l_last_update_date,
            last_updated_by     = l_last_updated_by,
            last_update_login   = l_last_update_login
      where project_id = rec.project_id;

      l_loop_count := l_loop_count + 1;

      if l_loop_count = l_commit_size then
        commit;
        l_loop_count := 0;
      end if;

    end loop;

   END IF;

    retcode := 0;

  exception
    when others then

      retcode := 2;
      errbuf := sqlerrm;
      rollback;
      raise;

  end Update_Access_Level;

procedure COPY_ASSET(
    p_cur_project_asset_id IN       NUMBER,
    p_asset_name            IN      VARCHAR2,
    p_asset_description     IN      VARCHAR2,
    p_project_asset_type    IN      VARCHAR2,
    p_asset_units           IN      NUMBER DEFAULT NULL,
    p_est_asset_units       IN      NUMBER DEFAULT NULL,
    p_asset_dpis            IN      DATE DEFAULT NULL,
    p_est_asset_dpis        IN      DATE DEFAULT NULL,
    p_asset_number          IN      VARCHAR2 DEFAULT NULL,
    p_copy_assignments      IN      VARCHAR2,
    x_new_project_asset_id     OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_data                 OUT NOCOPY VARCHAR2
) IS

begin

    PA_COPY_ASSET_PVT.COPY_ASSET(
         p_cur_project_asset_id  =>p_cur_project_asset_id,
         p_asset_name            =>p_asset_name,
         p_asset_description     =>p_asset_description,
         p_project_asset_type    =>p_project_asset_type,
         p_asset_units           =>p_asset_units,
         p_est_asset_units       =>p_est_asset_units,
         p_asset_dpis            =>p_asset_dpis,
         p_est_asset_dpis        =>p_est_asset_dpis,
         p_asset_number          =>p_asset_number,
         p_copy_assignments      =>p_copy_assignments,
         x_new_project_asset_id  => x_new_project_asset_id,
         x_return_status         => x_return_status,
         x_msg_data              => x_msg_data);

end COPY_ASSET;

FUNCTION Tag_Number_Exists( P_Tag_Number IN VARCHAR2) RETURN VARCHAR2 IS

   l_return_value VARCHAR2(1) := 'N';

BEGIN
     l_return_value := PA_CAPITAL_PROJECT_UTILS.Tag_Number_Exists ( p_tag_number );
     RETURN ( l_return_value );
END Tag_Number_Exists;

FUNCTION Allow_AssetType_Change(P_From_Asset_Type  IN VARCHAR2,
                                   P_To_Asset_Type    IN VARCHAR2,
                                   P_Project_Asset_Id IN NUMBER,
                                   P_Capitalized_Flag IN VARCHAR2,
                                   P_Capital_Event_Id IN NUMBER
                                  ) RETURN VARCHAR2 IS

  l_return_value VARCHAR2(1) := 'N';

BEGIN
     l_return_value := PA_CAPITAL_PROJECT_UTILS.Allow_AssetType_Change(
                             P_From_Asset_Type     => P_From_Asset_Type
                            ,P_To_Asset_Type       => P_To_Asset_Type
                            ,P_Project_Asset_Id    => P_Project_Asset_Id
                            ,P_Capitalized_Flag    => P_Capitalized_Flag
                            ,P_Capital_Event_Id    => P_Capital_Event_Id
                          );

     RETURN ( l_return_value );
END Allow_AssetType_Change;

/*FUNCTION get_depreciation_expense
              (P_project_asset_id        IN  NUMBER,
               P_book_type_code          IN  VARCHAR2,
               P_asset_category_id       IN  NUMBER,
               P_date_placed_in_service  IN  DATE
              ) RETURN NUMBER IS

  l_return_value NUMBER;

BEGIN

    l_return_value := PA_CAPITAL_PROJECT_UTILS.get_depreciation_expense(
                             p_project_asset_id        => p_project_asset_id
                            ,p_book_type_code          => p_book_type_code
                            ,p_asset_category_id       => p_asset_category_id
                            ,p_date_placed_in_service  => p_date_placed_in_service

    RETURN ( l_return_value );
END get_depreciation_expense;
*/

PROCEDURE CHECK_CUST_FUNDING_EXISTS(
         p_proj_customer_id         NUMBER,
         p_project_id               NUMBER,
         p_cust_contribution        NUMBER,
         x_return_status            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_msg_data                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_msg_count                OUT NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
)  IS
BEGIN
     PA_MULTI_CURRENCY_BILLING.Check_Cust_Funding_Exists(
         p_proj_customer_id         => p_proj_customer_id,
         p_project_id               => p_project_id,
         p_cust_contribution        => p_cust_contribution,
         x_return_status            => x_return_status,
         x_msg_data                 => x_msg_data,
         x_msg_count                => x_msg_count
         );

END CHECK_CUST_FUNDING_EXISTS;


FUNCTION is_ord_mgmt_installed RETURN VARCHAR2  --for credit receiver feature
IS
  l_return_value VARCHAR2(1) := 'N';
BEGIN

    l_return_value := PA_INSTALL.is_ord_mgmt_installed;
    RETURN ( l_return_value );
END is_ord_mgmt_installed;


PROCEDURE check_asset_alloc_method (
         p_asset_allocation_method  VARCHAR2
        ,p_amg_segment1             VARCHAR2
        ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
    CURSOR cur_lookup IS
    SELECT 'x'
      FROM pa_lookups
     WHERE lookup_type = 'ASSET_ALLOCATION_METHOD'
       AND lookup_code = p_asset_allocation_method;
    l_dummy_char   VARCHAR2(1);
    l_api_name  CONSTANT         VARCHAR2(30) := 'check_asset_alloc_method';
BEGIN

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    OPEN cur_lookup;
    FETCH cur_lookup INTO l_dummy_char;
    IF cur_lookup%NOTFOUND
    THEN
       CLOSE cur_lookup;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
       THEN
           pa_interface_utils_pub.map_new_amg_msg
               ( p_old_message_code => 'PA_CAP_INV_ASSET_ALLOC'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'PROJECT'
                ,p_attribute1       => p_amg_segment1
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
        CLOSE cur_lookup;
    END IF;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.add_exc_msg
               (  p_pkg_name            => G_PKG_NAME
                , p_procedure_name      => l_api_name   );

        END IF;

END check_asset_alloc_method;

PROCEDURE check_cap_event_method (
         p_capital_event_processing  VARCHAR2
        ,p_amg_segment1             VARCHAR2
        ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
    CURSOR cur_lookup IS
    SELECT 'x'
      FROM pa_lookups
     WHERE lookup_type = 'CAPITAL_EVENT_PROCESSING'
       AND lookup_code = p_capital_event_processing;
    l_dummy_char   VARCHAR2(1);
    l_api_name  CONSTANT         VARCHAR2(30) := 'check_cap_event_method';
BEGIN

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    OPEN cur_lookup;
    FETCH cur_lookup INTO l_dummy_char;
    IF cur_lookup%NOTFOUND
    THEN
       CLOSE cur_lookup;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
       THEN
           pa_interface_utils_pub.map_new_amg_msg
               ( p_old_message_code => 'PA_CAP_INV_CAP_EVENT'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'PROJECT'
                ,p_attribute1       => p_amg_segment1
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
        CLOSE cur_lookup;
    END IF;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.add_exc_msg
               (  p_pkg_name            => G_PKG_NAME
                , p_procedure_name      => l_api_name   );

        END IF;

END check_cap_event_method;

PROCEDURE check_cint_schedule (
         p_cint_rate_sch_id         NUMBER
        ,p_amg_segment1             VARCHAR2
        ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
    CURSOR cur_sch IS
       SELECT  'X'
         FROM  pa_ind_rate_schedules_all_bg
        WHERE  IND_RATE_SCH_USAGE = 'CAPITALIZED_INTEREST'
          AND  trunc(sysdate) between START_DATE_ACTIVE
          AND  nvl(trunc(END_DATE_ACTIVE),trunc(sysdate))
          AND  IND_RATE_SCH_ID = p_cint_rate_sch_id ;

    l_dummy_char                 VARCHAR2(1);
    l_api_name  CONSTANT         VARCHAR2(30) := 'check_cint_schedule';
BEGIN

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    OPEN cur_sch;
    FETCH cur_sch INTO l_dummy_char;
    IF cur_sch%NOTFOUND
    THEN
       CLOSE cur_sch;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
       THEN
           pa_interface_utils_pub.map_new_amg_msg
               ( p_old_message_code => 'PA_CAP_INV_CINT_SCH'
                ,p_msg_attribute    => 'CHANGE'
                ,p_resize_flag      => 'N'
                ,p_msg_context      => 'PROJECT'
                ,p_attribute1       => p_amg_segment1
                ,p_attribute2       => ''
                ,p_attribute3       => ''
                ,p_attribute4       => ''
                ,p_attribute5       => '');
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
        CLOSE cur_sch;
    END IF;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.add_exc_msg
               (  p_pkg_name            => G_PKG_NAME
                , p_procedure_name      => l_api_name   );

        END IF;

END check_cint_schedule;

--PA L Changes 2872708


END PA_IMPL_OPTIONS_PUB;

/
