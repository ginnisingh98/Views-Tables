--------------------------------------------------------
--  DDL for Package PA_PRJ_PERIOD_PROFILE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PRJ_PERIOD_PROFILE_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAPJPDPS.pls 120.1 2005/08/19 16:41:13 mwasowic noship $ */

    Procedure Maintain_Prj_Period_Profile(
                          p_project_id IN NUMBER,
                          p_period_profile_type IN VARCHAR2,
                          p_plan_period_type    IN VARCHAR2,
                          p_period_set_name     IN VARCHAR2,
                          p_gl_period_type      IN VARCHAR2,
                          p_pa_period_type      IN VARCHAR2,
                          p_start_date          IN DATE,
                          px_end_date           IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          px_period_profile_id  IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_commit_flag         IN VARCHAR2 DEFAULT 'N',
                          px_number_of_periods  IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_debug_mode          IN VARCHAR2 DEFAULT 'N',
                          p_add_msg_in_stack    IN VARCHAR2 DEFAULT 'N',
                          x_plan_start_date     OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          x_plan_end_date       OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data            OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


    Procedure Get_Prj_Period_Profile_Dtls(
                          p_period_profile_id   IN  NUMBER,
                          p_debug_mode          IN VARCHAR2 DEFAULT 'N',
                          p_add_msg_in_stack    IN VARCHAR2 DEFAULT 'N',
                          x_period_profile_type OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_plan_period_type    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_period_set_name     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_gl_period_type      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_plan_start_date     OUT  NOCOPY DATE, --File.Sql.39 bug 4440895
                          x_plan_end_date       OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          x_number_of_periods   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_data            OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895
  procedure Get_Date_details(
                         p_project_id IN NUMBER,
                         p_period_name IN VARCHAR2,
                         p_plan_period_type IN VARCHAR2,
                         x_start_date  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         x_end_date    OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

 Procedure Maintain_Prj_Profile_wrp(
                          p_project_id          IN NUMBER,
                          p_period_profile_type IN VARCHAR2,
                          p_pa_start_date          IN DATE DEFAULT NULL,
                          px_pa_end_date           IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          px_pa_period_profile_id  IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_commit_flag         IN VARCHAR2 DEFAULT 'N',
                          px_pa_number_of_periods  IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_debug_mode          IN VARCHAR2 DEFAULT 'N',
                          p_add_msg_in_stack    IN VARCHAR2 DEFAULT 'N',
                          x_pa_plan_start_date     OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          x_pa_plan_end_date       OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                          x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          p_pa_start_period        IN  VARCHAR2 DEFAULT NULL,
                          p_pa_end_period          IN  VARCHAR2 DEFAULT NULL,
                          p_gl_start_period        IN  VARCHAR2 DEFAULT NULL,
                          p_gl_end_period          IN  VARCHAR2 DEFAULT NULL,
                          p_gl_start_date IN DATE DEFAULT NULL,
                          px_gl_end_date IN OUT NOCOPY DATE , --File.Sql.39 bug 4440895
                          px_gl_period_profile_id  IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          px_gl_number_of_periods IN OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
                          p_old_pa_profile_id      IN NUMBER ,
                          p_old_gl_profile_id      IN NUMBER,
                          p_refresh_option_code    IN VARCHAR2 DEFAULT 'NONE',
                          x_conc_req_id            OUT NOCOPY VARCHAR2  ); --File.Sql.39 bug 4440895


 Procedure Get_Prj_Defaults( p_project_id IN NUMBER,
                              p_info_flag  IN VARCHAR2,
                              p_create_defaults IN VARCHAR2, --Y or N
                             x_gl_start_period OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_gl_end_period   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_gl_start_Date   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_pa_start_period   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_pa_end_period   OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                             x_pa_start_date   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_plan_version_exists_flag OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_prj_start_date  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_prj_end_date   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            );

 Procedure Get_Curr_Period_Profile_Info(
             p_project_id           IN VARCHAR2
             ,p_period_type         IN VARCHAR2
             ,p_period_profile_type IN VARCHAR2
             ,x_period_profile_id   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
             ,x_start_period        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_end_period          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
             ,x_msg_data            OUT NOCOPY VARCHAR2  ); --File.Sql.39 bug 4440895

PROCEDURE Refresh_Period_Profile
	(
		p_budget_version_id		IN NUMBER,
		p_period_profile_id		IN NUMBER,
		p_project_id			IN NUMBER,
		x_return_status     		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		x_msg_count         		OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
		x_msg_data          		OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	);

PROCEDURE Wrapper_Refresh_Pd_Profile
	(
		errbuff 			OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		retcode 			OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		p_budget_version_id1		IN NUMBER DEFAULT NULL,
		p_budget_version_id2		IN NUMBER DEFAULT NULL,
		p_project_id			IN NUMBER DEFAULT NULL,
		p_refresh_option_code		IN VARCHAR2 DEFAULT NULL,
		p_gl_period_profile_id		IN NUMBER DEFAULT NULL,
		p_pa_period_profile_id		IN NUMBER DEFAULT NULL,
		p_debug_mode        		IN VARCHAR2 DEFAULT 'N'
	) ;

procedure get_current_period_info
    (p_period_profile_id        IN      pa_proj_period_profiles.period_profile_id%TYPE,
     x_cur_period_number        OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_cur_period_name          OUT     NOCOPY pa_proj_period_profiles.period_name1%TYPE, --File.Sql.39 bug 4440895
     x_cur_period_start_date    OUT     NOCOPY pa_proj_period_profiles.period1_start_date%TYPE, --File.Sql.39 bug 4440895
     x_cur_period_end_date      OUT     NOCOPY pa_proj_period_profiles.period1_end_date%TYPE, --File.Sql.39 bug 4440895
     x_return_status            OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                 OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

function has_preceding_periods
    (p_budget_version_id    IN      pa_budget_versions.budget_version_id%TYPE) RETURN VARCHAR2;

function has_succeeding_periods
    (p_budget_version_id    IN      pa_budget_versions.budget_version_id%TYPE) RETURN VARCHAR2;

 PROCEDURE UPDATE_BUDGET_VERSION(p_budget_version_id IN NUMBER,
                                 p_return_status     IN VARCHAR2,
                                 p_project_id        IN NUMBER,
                                 p_request_id        IN NUMBER );
end Pa_Prj_Period_Profile_Utils;

 

/
