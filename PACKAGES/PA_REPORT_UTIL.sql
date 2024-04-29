--------------------------------------------------------
--  DDL for Package PA_REPORT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REPORT_UTIL" AUTHID CURRENT_USER AS
        /* $Header: PARFRULS.pls 120.1 2005/08/19 16:52:29 mwasowic noship $   */
PROCEDURE get_default_val(
                          p_calling_screen              IN      VARCHAR2,
                          x_org_id                      OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_org_name                    OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_def_period_typ              OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_def_period_typ_desc         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_def_period_yr               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_def_period_name             OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_def_period_name_desc        OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_def_show_percentages_by     OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_billing_installed           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_prm_installed               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_login_person_name           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_login_person_id             OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data                    OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


--
-- Procedure            : Get_Default_Val
-- Purpose              : This procedure will populate the values for screen U1 ,and U2.
-- Parameters           :
--

PROCEDURE validate_u1    (p_org_name           IN      VARCHAR2,
                          p_period_type_desc   IN      VARCHAR2,
                          p_select_yr          IN      NUMBER,
                          p_period_name        IN      VARCHAR2,
                          p_calling_mode       IN      VARCHAR2,
                          p_showprctgby        IN      VARCHAR2,
                          x_org_id             OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_period_type        OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_period_name        OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_return_status      OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count          OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data           OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--
-- Procedure            : Validate_U1
-- Purpose              : This procedure will validate the passed values for screen U1.
-- Parameters           :
--



PROCEDURE validate_u2    (p_mgr_name           IN      VARCHAR ,
                          p_org_name           IN      VARCHAR2,
                          p_org_id             IN      NUMBER,
                          p_mgr_id             IN      NUMBER,
                          p_assignment_sts     IN      VARCHAR2,
                          p_period_year        IN      NUMBER,
                          p_period_type_desc   IN      VARCHAR2,
                          p_period_name        IN      VARCHAR2,
                          p_util_category      IN      NUMBER,
                          p_Show_Percentage_By IN      VARCHAR2,
                          p_Utilization_Method IN      VARCHAR2,
                          p_calling_mode       IN      VARCHAR2,
                          x_return_status      OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count          OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data           OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--
-- Procedure            : Validate_U2
-- Purpose              : This procedure will validate the passed values for screen U2.
-- Parameters           :
--

PROCEDURE get_default_period_val(
                          x_def_period          OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_def_period_typ      IN OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_def_period_yr       IN OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_def_period_name     IN OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_def_period_sts_code OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_def_period_sts      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_def_mon_or_qtr      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_def_period_num      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_return_status       OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count           OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data            OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


--
-- Procedure            : get_default_period_val
-- Purpose              : This procedure will populate screen U3.
-- Parameters           :
--



PROCEDURE Get_GE_Flag(
        p_periodname IN  VARCHAR2,
        x_flag       OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


--
-- Procedure            : Get_GE_Flag
-- Purpose              : This procedure will get the GE flag.
-- Parameters           :
--
END PA_REPORT_UTIL;
 

/
