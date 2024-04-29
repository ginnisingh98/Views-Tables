--------------------------------------------------------
--  DDL for Package PA_HR_UPDATE_PA_ENTITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_HR_UPDATE_PA_ENTITIES" AUTHID CURRENT_USER as
/* $Header: PAHRUPDS.pls 120.1.12000000.2 2007/04/05 14:27:34 kjai ship $ */

-- Bug fix : 1580103 -- initializing the pa_res_denorm_rec casuses the
-- pl/sql numeric error and fails to complete the work flow process
-- hence commented out
-- pa_res_denorm_rec        PA_RESOURCE_PVT.Resource_Denorm_Rec_Type ;


-- Start of comments
-- API name         : Update_Project_Entities
-- Type             : Private
-- Pre-reqs         : None
-- Purpose          : This procedure will be called from the database triggers
--                    created on the following HR and PA entities.
--                    1>.  PER_ALL_ASSIGNMENTS_F
--                    2>.  PER_ALL_PEOPLE_F
--                    3>.  PER_JOBS_EXTRA_INFO
--                    4>.  HR_ORGANIZATION_INFORMATION
--                    5>.  PER_VALID_GRADES
--                    6>.  PER_GRADES
--                    7>.  PER_ADDRESSES
--                    8>.  PER_ORG_STRUCTURE_ELEMENTS
--                    9>.  PA_ALL_ORGANIZATIONS
--                    10>. PA_JOB_RELATIONSHIPS
--
--                    Based on the values of the parameters it invokes a worklow
--                    and sets the appropriate attribute values in the workflow
--                    and starts a process based on the entity that is updated/
--                    inserted.
--
-- Parameters
--    p_calling_mode              IN VARCHAR2
--           This parameter will indicate the mode in which the table is changed
--           i.e. INSERT or UPDATE or DELETE.
--    p_table_name                IN VARCHAR2
--           This parameter will have the table name for which this api is called.
--    p_person_id                 IN NUMBER
--           This parameter will have the person identifier for which the record is
--           inserted or updated. This parameter value is set only if the api is
--           called from PER_ALL_ASSIGNMENTS, PER_ADDRESSES and PER_ALL_PEOPLE_F.
--    p_start_date_old            IN DATE
--           This parameter will have the old value of the assignment start date
--           if the start date of an assignment is modified. It will be populated
--           only for table PER_ALL_ASSIGNMENTS_F.
--    p_start_date_new            IN DATE
--           This parameter will have the new value of the asignment start date if
--           the start date of an assignment is modified or if a new assignment is
--           created. It will be populated only for table PER_ALL_ASSIGNMENTS_F.
--    p_end_date_old              IN DATE
--           This parameter will have the old value of the assignment end date
--           if the end date of an assignment is modified. It will be populated
--           only for table PER_ALL_ASSIGNMENTS_F.
--    p_end_date_new              IN DATE
--           This parameter will have the new value of the asignment end date if
--           the end date of an assignment is modified or if a new assignment is
--           created. It will be populated only for table PER_ALL_ASSIGNMENTS_F.
--    p_org_id_old                IN NUMBER
--           This parameter will have the old value of organization identifier if
--           the organization is changed. It will be populated only for table
--           PER_ALL_ASSIGNMENTS_F.
--    p_org_id_new                IN NUMBER
--           This parameter will have the new value of the organization if the
--           organization identifier is changed. It will be populated for tables
--           PER_ALL_ASSIGNMENTS_F and HR_ORGANIZATION_INFORMATION.
--    p_job_id_old                IN NUMBER
--           This parameter will have the old value job identifier if it is changed.
--           It will be populated for PER_VALID_GRADES, PER_ALL_ASSIGNMENTS_F,
--           PA_JOB_MAPPINGS
--    p_job_id_new                IN NUMBER
--           This parameter will have the new value of ob identifier if it is changed.
--           It will be populated for PER_VALID_GRADES, PER_ALL_ASSIGNMENTS_F,
--           PA_JOB_MAPPINGS.
--    p_from_job_group_id         IN NUMBER
--           This parameter will have the value of the from job group identifier when
--           a job mapping is changed. It will be populated only if PA_JOB_MAPPINGS
--           is changed.
--    p_to_job_group_id           IN NUMBER
--           This parameter will have the value of the to job group identifier when
--           a job mapping is changed. It will be populated only if PA_JOB_MAPPINGS
--           is changed.
--    p_job_level_old             IN NUMBER
--           This parameter will have the old value of the job level when PER_GRADES
--           table is changed.
--    p_job_level_new             IN NUMBER
--           This parameter will have the new value of the job level when PER_GRADES
--           table is changed.
--    p_supervisor_old            IN NUMBER
--           This parameter will have the old value of the supervisor identifier when
--           PER_ASSIGNMENTS_F is changed.
--    p_supervisor_new            IN NUMBER
--           This parameter will have the new value of the supervisor identifier when
--           PER_ASSIGNMENTS_F is changed.
--    p_primary_flag_old          IN VARCHAR2
--           This parameter will have the old value of the primary flag when an
--           assignment is changed.
--    p_primary_flag_new          IN VARCHAR2
--           This parameter will have the new value of the primary flag when an
--           assignment is changed.
--    p_org_info1_old             IN VARCHAR2
--           This parameter will have the old value of the operating unit when its
--           value is changed in HR_ORGANIZATION_INFORMATION.
--    p_org_info1_new             IN VARCHAR2
--           This parameter will have the new value of the operating unit when its
--           value is changed in HR_ORGANIZATION_INFORMATION.
--    p_jei_information2_old        IN VARCHAR2
--           This parameter will have the old value of job billability when its
--           value is changed in PER_JOBS_EXTRA_INFO.
--    p_jei_information2_new        IN VARCHAR2
--           This parameter will have the new value of job billability when its
--           value is changed in PER_JOBS_EXTRA_INFO.
--    p_jei_information3_old        IN VARCHAR2
--           This parameter will have the old value of job utilization when its
--           value is changed in PER_JOBS_EXTRA_INFO.
--    p_jei_information3_new        IN VARCHAR2
--           This parameter will have the new value of job utilization when its
--           value is changed in PER_JOBS_EXTRA_INFO.
--    p_jei_information4_old        IN VARCHAR2
--           This parameter will have the old value of project job level when its
--           value is changed in PER_JOBS_EXTRA_INFO.
--    p_jei_information4_new        IN VARCHAR2
--           This parameter will have the new value of project job level when its
--           value is changed in PER_JOBS_EXTRA_INFO.
--    p_jei_information6_old        IN VARCHAR2
--           This parameter will have the old value of scheduable flag when its
--           value is changed in PER_JOBS_EXTRA_INFO.
--    p_jei_informatio6_new        IN VARCHAR2
--           This parameter will have the new value of scheduable flag when its
--           value is changed in PER_JOBS_EXTRA_INFO.
--    p_grade_id_old
--           This parameter will have the old value of the grade identifier when
--           its value is changed in PER_VALID_GRADES.
--    p_grade_id_new
--           This parameter will have the new value of the grade identifier when
--           its value is changed in PER_VALID_GRADES.  Also when a job level is
--           changed in PER_GRADES its value is set.
--    p_full_name_old             IN VARCHAR2
--           When the full_name of a person is changed the old value of the
--           person's full name is passed through this parameter. So it value is
--           set only for PER_ALL_PEOPLE_F.
--    p_full_name_new             IN VARCHAR2
--           When the full_name of a person is changed the old value of the
--           person's full name is passed through this parameter. So it value is
--           set only for PER_ALL_PEOPLE_F.
--    p_country_old               IN VARCHAR2
--           This parameter will have the old value of the country code when the country
--           of an employee is changed. It is passed only for table PER_ADDRESSES.
--    p_country_new               IN VARCHAR2
--           This parameter will have the new value of the country code when the country
--           of an employee is changed. It is passed only for table PER_ADDRESSES.
--    p_city_old                  IN  VARCHAR2
--           This parameter will have the old value of the city when the city
--           of an employee is changed. It is passed only for table PER_ADDRESSES.
--    p_city_new                  IN  VARCHAR2
--           This parameter will have the new value of the city when the city
--           of an employee is changed. It is passed only for table PER_ADDRESSES.
--    p_region2_old               IN  VARCHAR2
--           This parameter will have the old value of the state when the state
--           of an employee is changed. It is passed only for table PER_ADDRESSES.
--    p_region2_new               IN  VARCHAR2
--           This parameter will have the new value of the state when the state
--           of an employee is changed. It is passed only for table PER_ADDRESSES.
--    p_org_struct_element_id     IN  NUMBER
--           This parameter will have the value of organization structure element
--           identifier when you change a hierarchy. It is populated only for
--           PER_ORG_STRUCTURE_ELEMENTS.
--    p_organization_id_parent    IN  NUMBER
--           This parameter will have the value of the parent organization identifier
--           when you change a hierarchy. It is populated only for
--           PER_ORG_STRUCTURE_ELEMENTS.
--    p_organization_id_child     IN  NUMBER
--           This parameter will have the value of the child organization identifier
--           when you change a hierarchy. It is populated only for
--           PER_ORG_STRUCTURE_ELEMENTS.
--    p_org_structure_version_id  IN  NUMBER
--           This parameter will have the version identifier of the structure when
--           you change a hierarchy. It is populated only for
--           PER_ORG_STRUCTURE_ELEMENTS.
--    p_inactive_date_old         IN  DATE
--           This parameter will have the old inactive date date of a project
--           organization.
--    p_inactive_date_new         IN  DATE
--           This parameter will have the new inactive date date of a project
--           organization.
--    p_from_job_id_old           IN  NUMBER
--           This parameter will have the old value of the from job identifier. It is
--           populated only for PA_JOB_MAPPINGS.
--    p_from_job_id_new           IN  NUMBER
--           This parameter will have the new value of the from job identifier. It is
--           populated only for PA_JOB_MAPPINGS.
--    p_to_job_id_old             IN  NUMBER
--           This parameter will have the old value of the to job identifier. It is
--           populated only for PA_JOB_MAPPINGS.
--    p_to_job_id_new             IN  NUMBER
--           This parameter will have the new value of the to job identifier. It is
--           populated only for PA_JOB_MAPPINGS.
--    p_org_info_context          in  VARCHAR2
--           This parameter will have the value of the organization information
--           context. This applied to table HR_ORGANIZATION_INFORMATION.
--    x_return_status             OUT VARCHAR2
--    x_error_message_code        OUT VARCHAR2

--
--    p_end_date_new         IN DATE
--           This parameter will have the new value of the organization
--           if the end date of an assignment is modified or if a new assignment
--           is created. It will be populated only for table PER_ALL_ASSIGNMENTS_F
--           and HR_ORGANIZATION_INFORMATION.

PROCEDURE update_project_entities    ( p_calling_mode              in  varchar2,
                                       p_table_name                in  varchar2,
                                       p_person_id                 in  number DEFAULT NULL,
                                       p_start_date_old            in  date DEFAULT NULL,
                                       p_start_date_new            in  date DEFAULT NULL,
                                       p_end_date_old              in  date DEFAULT NULL,
                                       p_end_date_new              in  date DEFAULT NULL,
                                       p_org_id_old                in  number DEFAULT NULL,
                                       p_org_id_new                in  number DEFAULT NULL,
                                       p_job_id_old                in  number DEFAULT NULL,
                                       p_job_id_new                in  number DEFAULT NULL,
                                       p_from_job_group_id         in  number DEFAULT NULL,
                                       p_to_job_group_id           in  number DEFAULT NULL,
                                       p_job_level_old             in  number DEFAULT NULL,
                                       p_job_level_new             in  number DEFAULT NULL,
                                       p_supervisor_old            in  number DEFAULT NULL,
                                       p_supervisor_new            in  number DEFAULT NULL,
                                       p_primary_flag_old          in  varchar2 DEFAULT NULL,
                                       p_primary_flag_new          in  varchar2 DEFAULT NULL,
                                       p_org_info1_old             in  varchar2 DEFAULT NULL,
                                       p_org_info1_new             in  varchar2 DEFAULT NULL,
                                       p_jei_information2_old      in  varchar2 DEFAULT NULL,
                                       p_jei_information2_new      in  varchar2 DEFAULT NULL,
                                       p_jei_information3_old      in  varchar2 DEFAULT NULL,
                                       p_jei_information3_new      in  varchar2 DEFAULT NULL,
                                       p_jei_information4_old      in  varchar2 DEFAULT NULL,
                                       p_jei_information4_new      in  varchar2 DEFAULT NULL,
                                       p_jei_information6_old      in  varchar2 DEFAULT NULL,
                                       p_jei_information6_new      in  varchar2 DEFAULT NULL,
                                       p_grade_id_old              in  number DEFAULT NULL,
                                       p_grade_id_new              in  number DEFAULT NULL,
                                       p_full_name_old             in  varchar2 DEFAULT NULL,
                                       p_full_name_new             in  varchar2 DEFAULT NULL,
                                       p_country_old               in  varchar2 DEFAULT NULL,
                                       p_country_new               in  varchar2 DEFAULT NULL,
                                       p_city_old                  in  varchar2 DEFAULT NULL,
                                       p_city_new                  in  varchar2 DEFAULT NULL,
                                       p_region2_old               in  varchar2 DEFAULT NULL,
                                       p_region2_new               in  varchar2 DEFAULT NULL,
                                       p_org_struct_element_id     in  number DEFAULT NULL,
                                       p_organization_id_parent    in  number DEFAULT NULL,
                                       p_organization_id_child     in  number DEFAULT NULL,
                                       p_org_structure_version_id  in  number DEFAULT NULL,
                                       p_inactive_date_old         in  date DEFAULT NULL,
                                       p_inactive_date_new         in  date DEFAULT NULL,
                                       p_from_job_id_old           in  number DEFAULT NULL,
                                       p_from_job_id_new           in  number DEFAULT NULL,
                                       p_to_job_id_old             in  number DEFAULT NULL,
                                       p_to_job_id_new             in  number DEFAULT NULL,
                                       p_org_info_context          in  varchar2 DEFAULT NULL,
                                       x_return_status             out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                       x_error_message_code        out NOCOPY varchar2); --File.Sql.39 bug 4440895


PROCEDURE org_struct_element_change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

PROCEDURE Job_Bill_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

PROCEDURE Full_Name_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;


PROCEDURE Default_OU_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;


PROCEDURE Valid_Grade_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

PROCEDURE Job_Level_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

PROCEDURE Address_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

PROCEDURE Project_Organization_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

PROCEDURE Job_Rel_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

PROCEDURE assignment_change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;


PROCEDURE Set_Nf_Error_Msg_Attr (p_item_type IN VARCHAR2,
			         p_item_key  IN VARCHAR2,
				 p_msg_count IN NUMBER,
				 p_msg_data IN VARCHAR2 ) ;

--
--  PROCEDURE
--              create_fte_sync_wf
--  PURPOSE
--              This procedure creates a wf process for termination of employee/contingent worker
--
--  HISTORY
--  27-MAR-207       kjai       Created for Bug 5683340
PROCEDURE create_fte_sync_wf
(p_person_id    IN  PA_EMPLOYEES.PERSON_ID%TYPE
,p_wait_days    IN NUMBER
,x_return_status      OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_data           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count          OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
) ;

--
--  PROCEDURE
--              start_fte_sync_wf
--  PURPOSE
--              This procedure starts wf process for termination of employee/contingent worker
--
--  HISTORY
--  27-MAR-207       kjai       Created for Bug 5683340
PROCEDURE start_fte_sync_wf
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

END pa_hr_update_pa_entities ;

 

/
