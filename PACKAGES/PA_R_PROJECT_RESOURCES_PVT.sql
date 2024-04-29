--------------------------------------------------------
--  DDL for Package PA_R_PROJECT_RESOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_R_PROJECT_RESOURCES_PVT" 
-- $Header: PARCPRVS.pls 120.3.12010000.2 2009/12/21 15:25:54 jcgeorge ship $
AUTHID CURRENT_USER AS

 --Global Variables
 G_user_id              NUMBER := fnd_profile.value('USER_ID');
 G_login_id             NUMBER := fnd_profile.value('LOGIN_ID');
 G_request_id           NUMBER := fnd_global.conc_request_id;
 G_program_id           NUMBER := fnd_global.conc_program_id;
 G_application_id       NUMBER := fnd_global.prog_appl_id;

  PROCEDURE INSERT_INTO_CRM(
	P_CATEGORY		IN JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
	P_PERSON_ID		IN JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE,
	P_NAME			IN JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE,
	P_START_DATE		IN JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
	P_ASSIGNMENT_START_DATE IN DATE,
	P_ASSIGNMENT_END_DATE	IN DATE,
	P_CALENDAR_ID		IN NUMBER,
	P_COUNT			IN NUMBER,
	X_CRM_RESOURCE_ID	OUT NOCOPY JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE , --File.Sql.39 bug 4440895
	X_RETURN_STATUS		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	P_START_DATE_ACTIVE     IN pa_r_project_resources_ind_v.per_start_date%TYPE,
	P_END_DATE_ACTIVE       IN pa_r_project_resources_ind_v.per_end_date%TYPE,
	P_SOURCE_NUMBER         IN pa_r_project_resources_ind_v.per_emp_number%TYPE,
	P_SOURCE_JOB_TITLE      IN pa_r_project_resources_ind_v.job_name%TYPE,
	P_SOURCE_EMAIL          IN pa_r_project_resources_ind_v.per_email%TYPE,
	P_SOURCE_PHONE          IN pa_r_project_resources_ind_v.per_work_phone%TYPE,
	P_SOURCE_ADDRESS1       IN HR_LOCATIONS.ADDRESS_LINE_1%TYPE,
	P_SOURCE_ADDRESS2       IN HR_LOCATIONS.ADDRESS_LINE_2%TYPE,
	P_SOURCE_ADDRESS3       IN HR_LOCATIONS.ADDRESS_LINE_3%TYPE,
	P_SOURCE_CITY           IN HR_LOCATIONS.TOWN_OR_CITY%TYPE,
	P_SOURCE_POSTAL_CODE    IN HR_LOCATIONS.POSTAL_CODE%TYPE,
	P_SOURCE_COUNTRY        IN HR_LOCATIONS.COUNTRY%TYPE,
	P_SOURCE_MGR_ID         IN pa_r_project_resources_ind_v.supervisor_id%TYPE,
	P_SOURCE_MGR_NAME       IN PER_ALL_PEOPLE_F.FULL_NAME%TYPE,
	P_SOURCE_BUSINESS_GRP_ID     IN pa_r_project_resources_ind_v.per_business_group_id%TYPE,
	P_SOURCE_BUSINESS_GRP_NAME   IN pa_r_project_resources_ind_v.org_name%TYPE,
	P_SOURCE_FIRST_NAME     IN pa_r_project_resources_ind_v.per_first_name%TYPE,
	P_SOURCE_LAST_NAME      IN pa_r_project_resources_ind_v.per_last_name%TYPE,
	P_SOURCE_MIDDLE_NAME    IN pa_r_project_resources_ind_v.per_middle_name%TYPE) ;

 PROCEDURE INSERT_INTO_PA(
        P_RESOURCE_TYPE_ID     IN      PA_RESOURCE_TYPES.RESOURCE_TYPE_ID%TYPE,
        P_CRM_RESOURCE_ID      IN      PA_RESOURCES.JTF_RESOURCE_ID%TYPE,
        X_RESOURCE_ID          OUT     NOCOPY PA_RESOURCES.RESOURCE_ID%TYPE, --File.Sql.39 bug 4440895
        P_START_DATE           IN      PA_RESOURCES.START_DATE_ACTIVE%TYPE,
        P_END_DATE             IN      PA_RESOURCES.END_DATE_ACTIVE%TYPE DEFAULT NULL,
        P_PERSON_ID            IN      PA_RESOURCE_TXN_ATTRIBUTES.
                                        PERSON_ID%TYPE  DEFAULT NULL,
	P_NAME		       IN      PA_RESOURCES.NAME%TYPE,
        P_PARTY_ID             IN      PA_RESOURCE_TXN_ATTRIBUTES.
                                        PARTY_ID%TYPE   DEFAULT NULL,
        X_RETURN_STATUS        OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

 PROCEDURE CHECK_OU(
        P_DEFAULT_OU            IN      PA_RESOURCES_DENORM.RESOURCE_ORG_ID%TYPE,
        P_EXP_ORG		IN	VARCHAR2,
	X_EXP_OU		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_RETURN_STATUS         OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


 PROCEDURE CREATE_INTERNAL_RESOURCE(
	P_PERSON_ID		    IN PA_RESOURCE_TXN_ATTRIBUTES.PERSON_ID%TYPE,
	P_NAME			    IN PA_RESOURCES.NAME%TYPE,
	P_ORGANIZATION_ID	    IN PER_ALL_ASSIGNMENTS_F.ORGANIZATION_ID%TYPE,
	P_ASSIGNMENT_START_DATE	    IN DATE,
	P_ASSIGNMENT_END_DATE	    IN DATE,
	P_START_DATE		    IN DATE,
	P_DEFAULT_OU		    IN NUMBER,
	P_CALENDAR_ID		    IN NUMBER,
	P_SYSTEM_TYPE		    IN PER_PERSON_TYPES.SYSTEM_PERSON_TYPE%TYPE,
	P_USER_TYPE		    IN PER_PERSON_TYPES.USER_PERSON_TYPE%TYPE,
	P_RES_EXISTS		    IN VARCHAR2,
	P_COUNT			    IN NUMBER,
	P_RESOURCE_TYPE		    IN JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
	X_RESOURCE_ID		    OUT NOCOPY PA_RESOURCES.RESOURCE_ID%TYPE, --File.Sql.39 bug 4440895
	X_RETURN_STATUS		    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	P_START_DATE_ACTIVE         IN pa_r_project_resources_ind_v.per_start_date%TYPE,
	P_END_DATE_ACTIVE           IN pa_r_project_resources_ind_v.per_end_date%TYPE,
	P_SOURCE_NUMBER             IN pa_r_project_resources_ind_v.per_emp_number%TYPE,
	P_SOURCE_JOB_TITLE          IN pa_r_project_resources_ind_v.job_name%TYPE,
	P_SOURCE_EMAIL              IN pa_r_project_resources_ind_v.per_email%TYPE,
	P_SOURCE_PHONE              IN pa_r_project_resources_ind_v.per_work_phone%TYPE,
	P_SOURCE_ADDRESS1           IN HR_LOCATIONS.ADDRESS_LINE_1%TYPE,
	P_SOURCE_ADDRESS2           IN HR_LOCATIONS.ADDRESS_LINE_2%TYPE,
	P_SOURCE_ADDRESS3           IN HR_LOCATIONS.ADDRESS_LINE_3%TYPE,
	P_SOURCE_CITY               IN HR_LOCATIONS.TOWN_OR_CITY%TYPE,
	P_SOURCE_POSTAL_CODE        IN HR_LOCATIONS.POSTAL_CODE%TYPE,
	P_SOURCE_COUNTRY            IN HR_LOCATIONS.COUNTRY%TYPE,
	P_SOURCE_MGR_ID             IN pa_r_project_resources_ind_v.supervisor_id%TYPE,
	P_SOURCE_MGR_NAME           IN PER_ALL_PEOPLE_F.FULL_NAME%TYPE,
	P_SOURCE_BUSINESS_GRP_ID    IN pa_r_project_resources_ind_v.per_business_group_id%TYPE,
	P_SOURCE_BUSINESS_GRP_NAME  IN pa_r_project_resources_ind_v.org_name%TYPE,
	P_SOURCE_FIRST_NAME         IN pa_r_project_resources_ind_v.per_first_name%TYPE,
	P_SOURCE_LAST_NAME          IN pa_r_project_resources_ind_v.per_last_name%TYPE,
	P_SOURCE_MIDDLE_NAME        IN pa_r_project_resources_ind_v.per_middle_name%TYPE);

 PROCEDURE CREATE_RESOURCE(
	P_COMMIT 	        IN   VARCHAR2,
	P_VALIDATE_ONLY	        IN   VARCHAR2,
	P_INTERNAL 	        IN   VARCHAR2,
	P_PERSON_ID	        IN   PA_RESOURCE_TXN_ATTRIBUTES.PERSON_ID%TYPE,
	P_INDIVIDUAL 	        IN   VARCHAR2,
	P_CHECK_RESOURCE        IN   VARCHAR2,
        P_SCHEDULED_MEMBER_FLAG IN   VARCHAR2,
	P_RESOURCE_TYPE	        IN   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
        P_PARTY_ID              IN   PA_RESOURCE_TXN_ATTRIBUTES.PARTY_ID%TYPE,
        P_FROM_EMP_NUM          IN   VARCHAR2,
        P_TO_EMP_NUM            IN   VARCHAR2,
        P_ORGANIZATION_ID       IN   NUMBER,
        P_REFRESH               IN   VARCHAR2,
        P_PULL_TERM_RES         IN   VARCHAR2 DEFAULT 'N',
        P_TERM_RANGE_DATE       IN   DATE     DEFAULT NULL,
        P_PERSON_TYPE           IN   VARCHAR2 DEFAULT 'ALL',
        P_START_DATE            IN   DATE     DEFAULT NULL, -- Bug 5337454
	-- Added parameters for PJR Resource Pull Enhancements - Bug 5130414
	P_SELECTION_OPTION	IN   VARCHAR2 DEFAULT NULL,
	P_ORG_STR_VERSION_ID	IN   NUMBER   DEFAULT NULL,
	P_START_ORGANIZATION_ID	IN   NUMBER   DEFAULT NULL,
	-- End of parameters added for PJR Resource Pull Enhancements - Bug 5130414
	X_RETURN_STATUS         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_RESOURCE_ID	        OUT  NOCOPY PA_RESOURCES.RESOURCE_ID%TYPE); --File.Sql.39 bug 4440895

 PROCEDURE create_future_crm_resource
   (itemtype                       IN      VARCHAR2
   , itemkey                       IN      VARCHAR2
   , actid                         IN      NUMBER
   , funcmode                      IN      VARCHAR2
   , resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );

FUNCTION GET_USER_PERSON_TYPE
  (P_EFFECTIVE_DATE               IN     DATE
  ,P_PERSON_ID                    IN     NUMBER
  )
RETURN VARCHAR2;


END PA_R_PROJECT_RESOURCES_PVT;

/
