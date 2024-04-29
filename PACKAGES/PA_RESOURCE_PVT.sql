--------------------------------------------------------
--  DDL for Package PA_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RESOURCE_PVT" AUTHID CURRENT_USER AS
  -- $Header: PARRESVS.pls 120.1 2005/08/19 17:00:10 mwasowic noship $
end_date       DATE := null;
end_date1      DATE := null;
scale_type     VARCHAR2(30) := null;
no_of_days     NUMBER := 90;

g_manager_name VARCHAR2(100);
g_project_id   NUMBER(15); /* Added this global parameter for bug#2604495 */
g_manager_resource_id NUMBER;

FUNCTION Get_Manager_Id(
P_PROJECT_ID		IN	NUMBER)
RETURN NUMBER;

FUNCTION Get_Manager_Name(p_project_id in number DEFAULT null) /* Added the parameter p_project_id for bug#2604495 */
RETURN VARCHAR2;

FUNCTION Get_Manager_Resource_Id
RETURN NUMBER;

Procedure Set_No_of_Days
  (p_no_of_days    IN NUMBER);

FUNCTION Get_Start_Date
  (p_resource_id    IN NUMBER,
   p_no_of_days     IN NUMBER)
   RETURN
  DATE;

FUNCTION Get_End_Date
  (p_resource_id    IN NUMBER)
   RETURN
  DATE;

FUNCTION Get_Start_Date1
  (p_row_label_id    IN NUMBER)
   RETURN
  DATE;

FUNCTION Get_End_Date1
  RETURN
  DATE;

FUNCTION get_scale_type
  RETURN
  VARCHAR2;


TYPE Resource_Denorm_Rec_Type
IS RECORD
   ( person_id                     pa_resources_denorm.person_id%TYPE := FND_API.G_MISS_NUM,
     resource_name                 pa_resources_denorm.resource_name%TYPE := FND_API.G_MISS_CHAR,
     resource_type                 pa_resources_denorm.resource_type%TYPE := FND_API.G_MISS_CHAR,
     resource_organization_id      pa_resources_denorm.resource_organization_id%TYPE := FND_API.G_MISS_NUM,
     resource_country_code         pa_resources_denorm.resource_country_code%TYPE := FND_API.G_MISS_CHAR,
     resource_country              pa_resources_denorm.resource_country%TYPE := FND_API.G_MISS_CHAR,
     resource_region               pa_resources_denorm.resource_region%TYPE := FND_API.G_MISS_CHAR,
     resource_city                 pa_resources_denorm.resource_city%TYPE := FND_API.G_MISS_CHAR,
     job_id                        NUMBER := FND_API.G_MISS_NUM,
     resource_job_level            pa_resources_denorm.resource_job_level%TYPE := FND_API.G_MISS_NUM,
     resource_effective_start_date pa_resources_denorm.resource_effective_start_date%TYPE := FND_API.G_MISS_DATE,
     resource_effective_end_date   pa_resources_denorm.resource_effective_end_date%TYPE := FND_API.G_MISS_DATE,
     employee_flag                 pa_resources_denorm.employee_flag%TYPE :=  FND_API.G_MISS_CHAR,
     manager_id                    NUMBER  := FND_API.G_MISS_NUM,
     manager_name                  pa_resources_denorm.manager_name%TYPE := FND_API.G_MISS_CHAR,
     billable_flag                 pa_resources_denorm.billable_flag%TYPE := FND_API.G_MISS_CHAR,
     utilization_flag              pa_resources_denorm.utilization_flag%TYPE := FND_API.G_MISS_CHAR,
     schedulable_flag              pa_resources_denorm.schedulable_flag%TYPE := FND_API.G_MISS_CHAR,
     resource_org_id               pa_resources_denorm.resource_org_id%TYPE := FND_API.G_MISS_NUM);

Procedure Insert_resource_denorm
  ( p_resource_denorm_rec  IN     Resource_denorm_Rec_type,
    x_return_status        OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_data             OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count            OUT    NOCOPY NUMBER); --File.Sql.39 bug 4440895

PROCEDURE check_required_fields
     ( p_resource_denorm_rec IN  Resource_denorm_Rec_type,
       x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_err_msg_code        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

Procedure Update_resource_denorm
  ( p_resource_denorm_old_rec  IN    Resource_denorm_Rec_type,
    p_resource_denorm_new_rec  IN    Resource_denorm_Rec_type,
    x_return_status            OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_data                 OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count                OUT   NOCOPY NUMBER);   --File.Sql.39 bug 4440895

PROCEDURE update_single_res_denorm_rec
  (p_resource_denorm_rec  IN  resource_denorm_rec_type,
   x_return_status        OUT NOCOPY VARCHAR, --File.Sql.39 bug 4440895
   x_err_msg_code         OUT NOCOPY VARCHAR); --File.Sql.39 bug 4440895



PROCEDURE update_person_res_denorm_recs
  (p_resource_denorm_rec  IN  resource_denorm_rec_type,
   x_return_status        OUT NOCOPY VARCHAR,  --File.Sql.39 bug 4440895
   x_err_msg_code         OUT NOCOPY VARCHAR); --File.Sql.39 bug 4440895


PROCEDURE syncronize_manager_name
  (p_new_resource_denorm_rec  IN  resource_denorm_rec_type,
   x_return_status            OUT NOCOPY VARCHAR); --File.Sql.39 bug 4440895

PROCEDURE update_job_res_denorm_recs
  ( p_resource_denorm_rec   IN  resource_denorm_rec_type,
    p_start_rowid           IN  rowid default NULL,
    p_end_rowid             IN  rowid default NULL,
    x_return_status         OUT NOCOPY VARCHAR, --File.Sql.39 bug 4440895
    x_err_msg_code          OUT NOCOPY VARCHAR);   --File.Sql.39 bug 4440895

PROCEDURE delete_resource_denorm
  (p_person_id                IN   pa_resources_denorm.person_id%type,
   p_res_effective_start_date IN   pa_resources_denorm.resource_effective_start_date%type,
   x_return_status            OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_data                 OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                OUT  NOCOPY NUMBER);   --File.Sql.39 bug 4440895


PROCEDURE Populate_Resources_Denorm ( p_resource_source_id       IN  NUMBER
					, p_resource_id              IN  NUMBER
					, p_resource_name            IN  VARCHAR2
					, p_resource_type            IN  VARCHAR2
					, p_person_type              IN  VARCHAR2
					, p_resource_job_id          IN  NUMBER
					, p_resource_job_group_id    IN  NUMBER
					, p_resource_org_id          IN  NUMBER
					, p_resource_organization_id IN  NUMBER
					, p_assignment_start_date    IN  DATE
					, p_assignment_end_date      IN  DATE
					, p_manager_id               IN  NUMBER
					, p_manager_name             IN  VARCHAR2
					, p_request_id               IN  NUMBER   DEFAULT NULL
					, p_program_application_id   IN  NUMBER   DEFAULT NULL
					, p_program_id               IN  NUMBER   DEFAULT NULL
					, p_commit                   IN  VARCHAR2
					, p_validate_only            IN  VARCHAR2
					, x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
					, x_msg_count                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
					, x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				    );

g_prev_res_source_id    NUMBER := NULL;

FUNCTION Get_Resource_Avl_To_Date (p_resource_id IN NUMBER,
                                   p_avl_from_date IN DATE)
RETURN DATE;

FUNCTION Get_Resource_Ovc_To_Date (p_resource_id IN NUMBER,
                                   p_ovc_from_date IN DATE)
RETURN DATE;

FUNCTION Get_Resource_Ovc_hours(p_resource_id   IN NUMBER,
                                p_ovc_from_date IN DATE,
                                p_ovc_to_date   IN DATE)
RETURN NUMBER;

--  PROCEDURE
--             Validate_Staff_Filter_Values
--  PURPOSE
--             Specifically for staffing pages use.
--             Currrently used by StaffingHomeAMImpl and ResourceListAMImpl.
--             This procedure validates the organization or/and manager
--             parameters used in the staffing filters. It requires p_responsibility=RM
--             if the user has resource manager responsibility and p_check=Y
--             if the manager_name contains % character (from My Resources page).
--  HISTORY
--             20-AUG-2002  Created    adabdull
--+
PROCEDURE Validate_Staff_Filter_Values(
                                     p_manager_name    IN  VARCHAR2
                                    ,p_manager_id      IN  NUMBER    DEFAULT NULL
                                    ,p_org_name        IN  VARCHAR2
                                    ,p_org_id          IN  NUMBER    DEFAULT NULL
                                    ,p_responsibility  IN  VARCHAR2  DEFAULT NULL
                                    ,p_check            IN  VARCHAR2  DEFAULT 'N'
                                    ,x_manager_id      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                    ,x_org_id          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                    ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                    ,x_msg_count       OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                    ,x_msg_data        OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-------------------------------------------------------------------------------+
--
--  PROCEDURE   : Update_Res_Availability
--  DESCRIPTION : This Procedure is called after FIs are generated
--                for any PJR assignment
--                This API updates PA_RES_AVAILABILITY based
--                on the new assignment created
--
--------------------------------------------------------------------------------+
PROCEDURE update_res_availability (
  p_resource_id   IN NUMBER,
  p_start_date    IN DATE,
  p_end_date      IN DATE,
  x_return_status OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_data      OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count     OUT   NOCOPY NUMBER ); --File.Sql.39 bug 4440895

-------------------------------------------------------------------------------+
--
--  PROCEDURE   : Populate_Res_Availability
--  DESCRIPTION : This Procedure populates PA_RES_AVAILABILITY for the resource
--                for the given dates
--                It populates the following data slices
--                - (Confirmed) Availability/Overcommittment
--                - (Confirmed + Provisional) Availability/Overcommittment
--                This procedure is also called from the upgrade script
--                used to populate PA_RES_AVAILABILITY
--
--------------------------------------------------------------------------------+
PROCEDURE populate_res_availability (
  p_resource_id   IN NUMBER,
  p_cstart_date   IN DATE,
  p_cend_date     IN DATE,
  p_bstart_date   IN DATE,
  p_bend_date     IN DATE,
  x_return_status OUT   NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE refresh_res_availability (
  errbuf   OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  retcode  OUT   NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

FUNCTION  get_res_conf_availability( p_resource_id          IN      NUMBER,
                                     p_start_date           IN      DATE,
                                     p_end_date             IN      DATE)
RETURN NUMBER;

FUNCTION  get_res_prov_conf_availability( p_resource_id          IN      NUMBER,
                                          p_start_date           IN      DATE,
                                          p_end_date             IN      DATE)
RETURN NUMBER;


--  FUNCTION
--             Get_Staff_Mgr_Org_Id
--  PURPOSE
--             Specifically for staffing pages use (Avl/Ovc CO objects)
--             It gets the Staffing Manager Organization (either SM organization
--             or from the profile option) to be used in the VO. It returns the
--             organization id.
FUNCTION Get_Staff_Mgr_Org_Id (p_user_id    IN NUMBER
                              ,p_person_id  IN NUMBER)
RETURN VARCHAR2;

end PA_RESOURCE_PVT;
 

/
