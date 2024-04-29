--------------------------------------------------------
--  DDL for Package PA_IMPL_OPTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_IMPL_OPTIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: PAIMWRPS.pls 120.1 2005/08/19 16:34:52 mwasowic noship $*/

FUNCTION Check_Incl_rlzd_gain_loss(
 p_org_id IN NUMBER
 ) RETURN VARCHAR2;

PROCEDURE Upgrade_MRC_fund_bud_flag(
 x_return_status         OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);

FUNCTION Check_MRC_install( x_err_code OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2; --File.Sql.39 bug 4440895

FUNCTION Check_OU_Incl_gain_loss(
 p_org_id IN NUMBER
 ) RETURN VARCHAR2;

FUNCTION Check_proj_Incl_gain_loss(
 p_org_id IN NUMBER,
 p_project_type IN VARCHAR2
 ) RETURN VARCHAR2;

FUNCTION Is_PT_Include_Gains_Losses(
 p_org_id IN NUMBER,
 p_project_type IN VARCHAR2
 ) RETURN VARCHAR2;

FUNCTION option_updateable(
  p_project_id IN NUMBER
 ,p_option_code VARCHAR2
 ) RETURN VARCHAR2;

FUNCTION check_budget_trans_exists(
  p_project_id IN NUMBER
 ) RETURN VARCHAR2;

FUNCTION enable_auto_baseline(
  p_project_id IN NUMBER
 ) RETURN VARCHAR2;

procedure Update_Access_level
( errbuf                     out NOCOPY varchar2, --File.Sql.39 bug 4440895
  retcode                    out NOCOPY varchar2, --File.Sql.39 bug 4440895
  p_from_project_number      in  varchar2 default null,
  p_to_project_number        in varchar2 default null,
  p_project_status           in varchar2 default null,
  p_project_type             in varchar2 default null,
  p_project_organization     in number default null,
  p_access_level             in varchar2 default '1'
);

--PA L Changes 2872708
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
);

FUNCTION Tag_Number_Exists( P_Tag_Number IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Allow_AssetType_Change(P_From_Asset_Type  IN VARCHAR2,
                                   P_To_Asset_Type    IN VARCHAR2,
                                   P_Project_Asset_Id IN NUMBER,
                                   P_Capitalized_Flag IN VARCHAR2,
                                   P_Capital_Event_Id IN NUMBER
                                  ) RETURN VARCHAR2;


PROCEDURE CHECK_CUST_FUNDING_EXISTS(
         p_proj_customer_id         NUMBER,
         p_project_id               NUMBER,
         p_cust_contribution        NUMBER,
         x_return_status            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_msg_data                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_msg_count                OUT NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
);   --for enahanced billing feature

FUNCTION is_ord_mgmt_installed RETURN VARCHAR2;  --for credit receiver feature

PROCEDURE check_asset_alloc_method (
         p_asset_allocation_method  VARCHAR2
        ,p_amg_segment1             VARCHAR2
        ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE check_cap_event_method (
         p_capital_event_processing  VARCHAR2
        ,p_amg_segment1             VARCHAR2
        ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE check_cint_schedule (
         p_cint_rate_sch_id         NUMBER
        ,p_amg_segment1             VARCHAR2
        ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

--PA L Changes 2872708


END PA_IMPL_OPTIONS_PUB;

 

/
