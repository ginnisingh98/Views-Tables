--------------------------------------------------------
--  DDL for Package PA_HR_UPDATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_HR_UPDATE_API" AUTHID CURRENT_USER AS
-- $Header: PARHRUPS.pls 120.3.12000000.4 2007/04/05 14:16:01 kjai ship $

-- This Procedure checks whether the given OU is a Valid or Not
PROCEDURE check_exp_OU(p_org_id              IN   NUMBER
                    ,x_return_status       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    ,x_error_message_code  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    );
-- This an wrapper api for check_exp_ou this
-- Function returns 'Y' if the OU is valid otherwise 'N'
FUNCTION validate_exp_OU (p_org_id              IN   NUMBER)
         return VARCHAR2;


-- This Procedure is called from workflow process to update/create resources in projects
-- the workflow would be kicked of by the database trigger on table Hr_Organization_Information
-- and Pa_All_Organization entities.
-- 1.Whenever the default operating Unit which is
--   stored in Hr_Organization_Information.Org_information1 changes / modified ,the
--   trigger kicks off the workflow and calls this api to Update the Pa_Resource_OU
--   entity.
-- 2.Whenever the new record is inserted into Pa_All_Organizations with Pa_Org_Use_type
--   is of type 'Expenditure' or the exisitng record in Pa_all_Organiations
--   is updated with inactive_date  then trigger fires and kicks of the workflow,calls this
--   api to Update the Pa_Resource_OU.
PROCEDURE  Default_OU_Change
                        ( P_calling_mode       IN   VARCHAR2
                         ,P_Organization_id    IN   Hr_Organization_Information.Organization_id%type
                         ,P_Default_OU_new     IN   Hr_Organization_Information.Org_Information1%type
                         ,P_Default_OU_old     IN   Hr_Organization_Information.Org_Information1%type
                         ,x_return_status      OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         ,x_msg_data           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         ,x_msg_count          OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                        );


-- This Procedure is called from workflow process to update/create resources in projects
-- The workflow would be kicked of by the database trigger on table Hr_Organization_Information
-- It will update the job levels information if the Project Resource Job Group is changed
-- Created by adabdull 2-JAN-2002
PROCEDURE Proj_Res_Job_Group_Change
                        ( p_calling_mode         IN   VARCHAR2
                         ,p_organization_id      IN   Hr_Organization_Information.Organization_id%type
                         ,p_proj_job_group_new   IN   Hr_Organization_Information.Org_Information1%type
                         ,p_proj_job_group_old   IN   Hr_Organization_Information.Org_Information1%type
                         ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         ,x_msg_data             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         ,x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                        );

--This API pulls all resources into PA from HR for a given organization
--Created by virangan 11-JUN-2001

PROCEDURE pull_resources( p_organization_id IN  pa_all_organizations.organization_id%type
                          ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          ,x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          ,x_msg_count      OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895


-- This API  will be called from workflow process to update resources in projects.
-- The workflow would be kicked of by the database trigger on pa_all_organization entity
-- whenever a inactive_date in pa_all_organization is updated this api get kicked of by the
-- workflow.

PROCEDURE make_resource_inactive
                (P_calling_mode       IN   VARCHAR2
                ,P_Organization_id    IN   Hr_Organization_Information.Organization_id%type
                ,P_Default_OU         IN    pa_all_organizations.org_id%type
                ,P_inactive_date      IN   pa_all_organizations.inactive_date%type
 		,P_Default_OU_NEW     IN    pa_all_organizations.org_id%type DEFAULT NULL  --Added for bug 5330402
                ,x_return_status      OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                ,x_msg_data           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
               );

-- This Procedure is kicked off by the workflow when jei_infomration2
-- which stores the jobs billability information. whenever the row is updated
-- or inserted into per_job_extra_info entity which stores the job information
-- and types a database triggers fires and kicks of the workflow
-- This procedure makes calls to forecast regenerate apis and create resource
-- denorm apis to to update the new billability for the resource

PROCEDURE per_job_extra_billability
                      (p_calling_mode                 IN   VARCHAR2
                      ,P_job_id                       IN  per_jobs.job_id%type
                      ,P_billable_flag_new            IN  per_job_extra_info.jei_information2%type
                      ,P_billable_flag_old            IN  per_job_extra_info.jei_information2%type
                      ,P_utilize_flag_old             IN  per_job_extra_info.jei_information3%type
                      ,P_utilize_flag_new             IN  per_job_extra_info.jei_information3%type
                      ,P_job_level_new                IN  per_job_extra_info.jei_information4%type
                      ,P_job_level_old                IN  per_job_extra_info.jei_information4%type
                      ,p_schedulable_flag_new         IN  per_job_extra_info.jei_information6%type
                      ,p_schedulable_flag_old         IN  per_job_extra_info.jei_information6%type
                      ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_msg_data                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_msg_count                    OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895


-- This Procedure will get a list of all affected jobs due to change in the grade,
-- sequence or mapping and then calls to PRM API GET_JOB_LEVEL in a loop which actually
-- updates the levels in the denorm table
-- whenever a grade,sequence,jobmapping columns in per_grades,per_valid_grades,pa_job_relationships
-- respectively updated,workflow will kickoff this api from the database trigger on table
-- per_grades,Per_valid_grades,pa_job_relationships
-- Requirements for calling this api from triggers different entities.
-- Per_Grades_Entity--
-- IN Parameters
--    P_calling_mode,P_per_grades_grade_id,P_per_grades_sequence_new  -- for INSERT trigger
--    P_calling_mode,P_per_grades_grade_id,P_per_grades_sequence_new,P_per_grades_sequence_old -- for UPDATE
--    P_calling_mode,P_per_grades_grade_id,P_per_grades_sequence_old --- for DELETE trigger
-- Per_Valid_Grades Entity--
-- IN Parameters
--    P_calling_mode,P_per_valid_grade_job_id,P_per_valid_grade_id_new -- for INSERT
--    P_calling_mode,P_per_valid_grade_job_id,P_per_valid_grade_id_new,P_per_valid_grade_id_old -- UPDATE
--    P_calling_mode,P_per_valid_grade_job_id,P_per_valid_grade_id_old -- for DELETE trigger
-- Pa_Job_Relationships Entity--
-- IN Parameters
-- P_calling_mode,P_from_job_id_new,P_to_job_id_new,P_from_job_group_id,P_to_job_group_id  -- INSERT
-- P_calling_mode,P_from_job_id_new,P_to_job_id_new,P_from_job_group_id,P_to_job_group_id,
--                 P_from_job_id_old,P_to_job_id_old ----------- UPDATE trigger
-- P_calling_mode,P_from_job_id_old,P_to_job_id_old,P_from_job_group_id,P_to_job_group_id -- DELETE

PROCEDURE  update_job_levels
             ( P_calling_mode                  IN VARCHAR2
              ,P_per_grades_grade_id          IN per_grades.grade_id%type        DEFAULT NULL
              ,P_per_grades_sequence_old      IN NUMBER                          DEFAULT NULL
              ,P_per_grades_sequence_new      IN NUMBER                          DEFAULT NULL
              ,P_per_valid_grade_job_id       IN per_valid_grades.valid_grade_id%type  DEFAULT NULL
              ,P_per_valid_grade_id_old       IN per_grades.grade_id%type        DEFAULT NULL
              ,P_per_valid_grade_id_new       IN per_grades.grade_id%type        DEFAULT NULL
              ,P_from_job_id_old              IN pa_job_relationships.from_job_id%type   DEFAULT NULL
              ,P_from_job_id_new              IN pa_job_relationships.from_job_id%type   DEFAULT NULL
              ,P_to_job_id_old                IN pa_job_relationships.to_job_id%type     DEFAULT NULL
              ,P_to_job_id_new                IN pa_job_relationships.to_job_id%type     DEFAULT NULL
              ,P_from_job_group_id            IN pa_job_relationships.to_job_id%type     DEFAULT NULL
              ,P_to_job_group_id              IN pa_job_relationships.to_job_id%type     DEFAULT NULL
              ,x_return_status                IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              ,x_msg_data                     IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              ,x_msg_count                    IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
             );

-- This API returns the Billability of job / person
-- The IN parameters will be Person_id and Date for Person's Billability
-- and Job_id for the Job's billability
FUNCTION check_job_billability
        (
         P_job_id        IN   number
        ,P_person_id     IN   number
        ,P_date          IN   date
         ) RETURN VARCHAR2;

 pragma RESTRICT_REFERENCES(check_job_billability,WNDS,WNPS);

----------------------------------------------------------------
-- This API returns the schedulable_flag value of the passed job
----------------------------------------------------------------
FUNCTION check_job_schedulable
 (
   p_job_id        IN  NUMBER DEFAULT NULL
  ,p_person_id     IN  NUMBER DEFAULT NULL
  ,p_date          IN  DATE   DEFAULT NULL
 ) RETURN VARCHAR2;

 pragma RESTRICT_REFERENCES(check_job_schedulable,WNDS,WNPS);


-- This API returns the utilization of job / person
-- The IN parameters will be Person_id and Date for Person's Billability
-- OR Job_id for the Job's billability
FUNCTION check_job_utilization
        (
         P_job_id        IN   number
        ,P_person_id     IN   number
        ,P_date          IN   date
         ) RETURN VARCHAR2;
 pragma RESTRICT_REFERENCES(check_job_utilization,WNDS,WNPS);



-- This API returns the job group id for the corresponding Job
FUNCTION get_job_group_id(
                          P_job_id             IN   per_jobs.job_id%type
                         ) RETURN per_job_groups.job_group_id%type;

-- pragma RESTRICT_REFERENCES (get_job_group_id, WNDS, WNPS );

FUNCTION get_job_name(
                          P_job_id             IN   per_jobs.job_id%type
                         ) RETURN per_jobs.name%type;

-- pragma RESTRICT_REFERENCES (get_job_name, WNDS, WNPS );

FUNCTION get_org_name(
                          P_org_id             IN   hr_all_organization_units.organization_id%type
                         ) RETURN hr_all_organization_units.name%type;

-- pragma RESTRICT_REFERENCES (get_org_name, WNDS, WNPS );

FUNCTION get_grade_name(
                          P_grade_id             IN   NUMBER
                         ) RETURN VARCHAR2 ;

-- pragma RESTRICT_REFERENCES (get_grade_name, WNDS, WNPS );


-- This Function returns the job level(sequence) based on the job_id and Job_group_id
FUNCTION get_job_level(
                       P_job_id             IN   per_jobs.job_id%type
                      ,P_job_group_id       IN  per_job_groups.job_group_id%type
                      ) RETURN NUMBER;

-- This Function returns boolean value of true if a job is master job otherwise
-- it returns false -- IN parameter will be job_id
FUNCTION check_master_job(P_job_id  IN per_Jobs.job_id%type)
                       RETURN  boolean;
-- pragma RESTRICT_REFERENCES (check_master_job, WNDS, WNPS );

-- This Procedure updates the pa_resource_OU and set the resources
-- end date active to sysdate when pa_all_organizations.inactive_date
-- is updated.
PROCEDURE  Update_OU_resource(P_default_OU_old     IN  Pa_all_organizations.org_id%type
                             ,P_default_OU_new     IN  Pa_all_organizations.org_id%type
                             ,P_resource_id        IN  Pa_Resources_denorm.resource_id%type
                                                       default NULL
                             ,P_person_id          IN  Pa_Resources_denorm.person_id%type
                                                       default NULL
                             ,P_start_date         IN  Date  default NULL
                             ,P_end_date_old       IN  Date  default NULL
                             ,P_end_date_new       IN  Date  default NULL
                             ,x_return_status      IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             ,x_msg_data           IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             ,x_msg_count          IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                             );
PROCEDURE Update_EndDate(p_person_id IN per_all_people_f.person_id%TYPE,
        p_old_start_date     IN per_all_assignments_f.effective_start_date%TYPE,
        p_new_start_date     IN per_all_assignments_f.effective_end_date%TYPE,
        p_old_end_date       IN per_all_assignments_f.effective_start_date%TYPE,
        p_new_end_date       IN per_all_assignments_f.effective_end_date%TYPE,
        x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_data           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_count          OUT  NOCOPY NUMBER); --File.Sql.39 bug 4440895

PROCEDURE Update_Org(p_person_id IN per_all_people_f.person_id%TYPE,
        p_old_org_id         IN per_all_assignments_f.organization_id%TYPE,
        p_new_org_id         IN per_all_assignments_f.organization_id%TYPE,
        p_old_start_date     IN per_all_assignments_f.effective_start_date%TYPE,
        p_new_start_date     IN per_all_assignments_f.effective_end_date%TYPE,
        p_old_end_date       IN per_all_assignments_f.effective_start_date%TYPE,
        p_new_end_date       IN per_all_assignments_f.effective_end_date%TYPE,
        x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_data           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_count          OUT  NOCOPY NUMBER); --File.Sql.39 bug 4440895

FUNCTION check_pjr_default_ou(P_Organization_id IN Hr_Organization_Information.Organization_id%type,
                              P_Default_OU_new IN Hr_Organization_Information.Org_Information1%type) RETURN VARCHAR2; -- Bug 4656855
 pragma RESTRICT_REFERENCES (check_pjr_default_ou, WNDS, WNPS);

FUNCTION Belongs_ExpOrg(p_org_id IN per_all_assignments_f.organization_id%TYPE) RETURN VARCHAR2;
 pragma RESTRICT_REFERENCES (Belongs_ExpOrg, WNDS, WNPS);

FUNCTION Get_DefaultOU(p_org_id IN per_all_assignments_f.organization_id%TYPE) RETURN NUMBER ;
 pragma RESTRICT_REFERENCES (Get_DefaultOU, WNDS, WNPS);

PROCEDURE Update_Job(p_person_id IN per_all_people_f.person_id%TYPE,
        p_old_job            IN per_all_assignments_f.job_id%TYPE,
        p_new_job            IN per_all_assignments_f.job_id%TYPE,
        p_new_start_date     IN per_all_assignments_f.effective_start_date%TYPE,
        p_new_end_date       IN per_all_assignments_f.effective_end_date%TYPE,
        x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_data           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_count          OUT  NOCOPY NUMBER); --File.Sql.39 bug 4440895

PROCEDURE Update_Supervisor(p_person_id IN per_all_people_f.person_id%TYPE,
        p_old_supervisor     IN per_all_assignments_f.supervisor_id%TYPE,
        p_new_supervisor     IN per_all_assignments_f.supervisor_id%TYPE,
	    p_new_start_date     IN per_all_assignments_f.effective_start_date%TYPE,
        p_new_end_date       IN per_all_assignments_f.effective_end_date%TYPE,
        x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_data           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_count          OUT  NOCOPY NUMBER); --File.Sql.39 bug 4440895

PROCEDURE Update_PrimaryFlag(p_person_id IN per_all_people_f.person_id%TYPE,
        p_old_start_date     IN per_all_assignments_f.effective_start_date%TYPE,
        p_new_start_date     IN per_all_assignments_f.effective_end_date%TYPE,
        p_old_end_date       IN per_all_assignments_f.effective_start_date%TYPE,
        p_new_end_date       IN per_all_assignments_f.effective_end_date%TYPE,
        x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_data           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_count          OUT  NOCOPY NUMBER); --File.Sql.39 bug 4440895

PROCEDURE Update_Name(
	p_person_id          IN  per_all_people_f.person_id%TYPE,
	p_old_name	     IN  per_all_people_f.full_name%TYPE,
	p_new_name	     IN  per_all_people_f.full_name%TYPE,
	x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_data           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_count	     OUT  NOCOPY NUMBER); --File.Sql.39 bug 4440895

-- Added the following parameters for the bug fix :1583544
-- p_date_from_old,p_date_from_new,p_date_to_old,p_date_to_new,
-- p_addr_prim_flag_old,p_addr_prim_flag_new
-- to update the pa_resource_denorm when person address changes with respect
-- date
PROCEDURE address_change ( p_calling_mode              in  varchar2,
                           p_person_id                 in  number,
                           p_country_old               in  varchar2,
                           p_country_new               in  varchar2,
                           p_city_old                  in  varchar2,
                           p_city_new                  in  varchar2,
                           p_region2_old               in  varchar2,
                           p_region2_new               in  varchar2,
                           p_date_from_old             in  date,
                           p_date_from_new             in date,
                           p_date_to_old               in  date,
                           p_date_to_new               in  date,
                           p_addr_prim_flag_old        in varchar2,
                           p_addr_prim_flag_new        in varchar2,
                           x_return_status             out NOCOPY varchar2, --File.Sql.39 bug 4440895
                           x_msg_count                 out NOCOPY number, --File.Sql.39 bug 4440895
                           x_msg_data                  out NOCOPY varchar2); --File.Sql.39 bug 4440895

FUNCTION Get_Country_name(p_country_code    VARCHAR2) RETURN VARCHAR2 ;

-- Procedure to delete the records in pa_resources_denorm when the corresponding records
-- in per_all_assignments_f are deleted.
PROCEDURE Delete_PA_Resource_Denorm(
    p_person_id          IN   per_all_people_f.person_id%TYPE,
    p_old_start_date     IN   per_all_assignments_f.effective_start_date%TYPE,
    p_old_end_date       IN   per_all_assignments_f.effective_end_date%TYPE,
    x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_data           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count	         OUT  NOCOPY NUMBER); --File.Sql.39 bug 4440895

-- PROCEDURE
--        withdraw_cand_nominations
-- PURPOSE
--        to withdraw all PJR candidate nominations for this
--        person_id when the person is terminated in HR
--        or the assignment organization no longer belongs to
--        expenditure hierarchy
-- HISTORY
--   05-MAR-207       kjai       Created for Bug 5683340
--
PROCEDURE withdraw_cand_nominations
                ( p_person_id        IN    NUMBER,
                  p_effective_date   IN    DATE,
                  x_return_status    OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_msg_count        OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
                  x_msg_data         OUT   NOCOPY VARCHAR2);   --File.Sql.39 bug 4440895

END PA_HR_UPDATE_API;

 

/
