--------------------------------------------------------
--  DDL for Package PA_RESOURCE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RESOURCE_UTILS" AUTHID CURRENT_USER AS
-- $Header: PARSUTLS.pls 120.5.12010000.4 2009/12/29 23:58:11 skkoppul ship $

--
-- Global Variables.
--
  G_SELECTED_FLAG     VARCHAR2(1);
  G_PRIMARY_CONTACT_NAME VARCHAR2(240);
  G_PRIMARY_CONTACT_ID  NUMBER;
  G_CURRENT_PROJECT_ID  PA_PROJECTS_ALL.PROJECT_ID%TYPE;
  G_PERSON_ID         PA_EMPLOYEES.PERSON_ID%TYPE;
  G_VERSION_ID        PER_ORG_STRUCTURE_ELEMENTS.ORG_STRUCTURE_VERSION_ID%TYPE;
  G_START_ORG_ID      PER_ORG_STRUCTURE_ELEMENTS.ORGANIZATION_ID_PARENT%TYPE;
  G_PERIOD_DATE       DATE ;
  type PLSQLTAB_NAMEARRAY is table of varchar2(120) index by binary_integer;
  type PLSQLTAB_INTARRAY  is table of NUMBER index by binary_integer;
  g_provisional_hours NUMBER;
  g_confirmed_hours NUMBER;
  /*Bug 3737529 :- Added the below global variables */
  G_HR_SUPERVISOR_NAME VARCHAR2(240);
  G_HR_SUPERVISOR_ID NUMBER;
  G_ASSIGNMENT_ID NUMBER;
  G_RESOURCE_ID NUMBER;
  /*Bug 3737529 : Code addtion ends*/
  G_START_DATE  DATE; -- For bug 4443604
  G_ORGANIZATION_ID   HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE; -- 4882876
  G_ORGANIZATION_NAME HR_ORGANIZATION_UNITS.NAME%TYPE; -- 4882876

  G_TERM_PERSON_ID    PA_EMPLOYEES.PERSON_ID%TYPE; -- Bug 5683340
  G_FTE_DATE DATE; -- Bug 5683340
  G_FTE_FLAG VARCHAR2(1); -- Bug 5683340

--
--  PROCEDURE
--              Check_ResourceName_Or_Id
--  PURPOSE
--              This procedure does the following
--              If Resource name is passed converts it to the id
--		If Resource Id is passed,
--		based on the check_id_flag validates it
--  HISTORY
--   27-JUN-2000      P. Bandla       Created
--   05-SEP-2000      P. Bandla       Modified
--      Added P_DATE parameter

 PROCEDURE Check_ResourceName_Or_Id(
			p_resource_id		IN	NUMBER,
			p_resource_name		IN	VARCHAR2,
			p_date			IN	DATE DEFAULT SYSDATE,
			p_end_date              IN	DATE :=null, -- 3235018
			p_check_id_flag		IN	VARCHAR2,
                        p_resource_type_id      IN      NUMBER DEFAULT 101,
			x_resource_id		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
			x_resource_type_id      OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
			x_return_status		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			x_error_message_code	OUT	NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
--  PROCEDURE
--              Get_CRM_Res_id
--  PURPOSE
--              Returns the CRM Resource_id based on the
--              project_player_id

--  HISTORY
--   27-JUN-2000      P. Bandla       Created

 PROCEDURE Get_CRM_Res_id(
	P_PROJECT_PLAYER_ID	IN	NUMBER DEFAULT NULL,
        P_RESOURCE_ID           IN      NUMBER DEFAULT NULL,
	X_JTF_RESOURCE_ID	OUT	NOCOPY NUMBER,  --File.Sql.39 bug 4440895
        X_RETURN_STATUS		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        X_ERROR_MESSAGE_CODE	OUT	NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

 PROCEDURE CHECK_CC_FOR_RESOURCE(
        P_RESOURCE_ID           IN      NUMBER,
        P_PROJECT_ID            IN      NUMBER,
        P_START_DATE            IN      DATE,
        P_END_DATE              IN      DATE DEFAULT NULL,
        X_CC_OK                 OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        X_RETURN_STATUS         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        X_ERROR_MESSAGE_CODE    OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--
--  PROCEDURE
--              Check_Resource_Belongs_ExpOrg
--  PURPOSE
--              This procedure does the following
--              For the given Resource Id,
--              checks if that resource
--		belongs to an expenditure organization
--  HISTORY
--   22-AUG-2000      P.Bandla       Created
--
 PROCEDURE CHECK_RES_BELONGS_EXPORG(
                         P_RESOURCE_ID          IN      NUMBER,
			 --P_DATE			IN	DATE DEFAULT 'SYSDATE',
                         X_VALID	        OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         X_RETURN_STATUS        OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         X_ERROR_MESSAGE_CODE   OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--
--  PROCEDURE
--              Check_Resource_Belongs_ExpOrg
--  PURPOSE
--              This is a overloaded procedure which does the following
--              For the given Resource Id, Resource Start Date and Resource End Date
--              checks if that resource
--		belongs to an expenditure organization
--  HISTORY
--   01-JAN-2009      asahoo       Created
--
 PROCEDURE CHECK_RES_BELONGS_EXPORG(
                         P_RESOURCE_ID          IN      NUMBER,
			 P_START_DATE_ACTIVE	IN	DATE,
			 P_END_DATE_ACTIVE	IN	DATE,
                         X_VALID	        OUT     NOCOPY VARCHAR2,
                         X_RETURN_STATUS        OUT     NOCOPY VARCHAR2,
                         X_ERROR_MESSAGE_CODE   OUT     NOCOPY VARCHAR2);

PROCEDURE set_global_variables( p_selected_flag IN VARCHAR2
                               ,p_person_id     IN PA_EMPLOYEES.PERSON_ID%TYPE
                               ,p_version_id    IN PER_ORG_STRUCTURE_ELEMENTS.ORG_STRUCTURE_VERSION_ID%TYPE
                               ,p_start_org_id  IN PER_ORG_STRUCTURE_ELEMENTS.ORGANIZATION_ID_PARENT%TYPE
                              );

FUNCTION get_selected_flag RETURN VARCHAR2;
pragma RESTRICT_REFERENCES (get_selected_flag, WNDS, WNPS );

FUNCTION get_person_id RETURN PA_EMPLOYEES.PERSON_ID%TYPE;
pragma RESTRICT_REFERENCES (get_person_id, WNDS, WNPS );

FUNCTION get_version_id RETURN PER_ORG_STRUCTURE_ELEMENTS.ORG_STRUCTURE_VERSION_ID%TYPE;
pragma RESTRICT_REFERENCES (get_version_id, WNDS, WNPS );

FUNCTION get_start_org_id RETURN PER_ORG_STRUCTURE_ELEMENTS.ORGANIZATION_ID_PARENT%TYPE;
pragma RESTRICT_REFERENCES (get_start_org_id, WNDS, WNPS );

FUNCTION get_projected_end_date(p_person_id IN NUMBER) RETURN DATE;
pragma RESTRICT_REFERENCES (get_projected_end_date, WNDS, WNPS);

FUNCTION get_period_date RETURN DATE;
pragma RESTRICT_REFERENCES (get_period_date, WNDS, WNPS );

PROCEDURE populate_role_flags( p_person_id      IN PA_EMPLOYEES.PERSON_ID%TYPE
                              ,p_org_id         IN PER_ORG_STRUCTURE_ELEMENTS.ORGANIZATION_ID_PARENT%TYPE
                              ,x_res_aut_flag   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_proj_aut_flag  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_prim_ctct_flag OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			      ,x_frcst_aut_flag   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_frcst_prim_ctct_flag OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			      ,x_utl_aut_flag  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             ) ;

-- 4882876 : Removed WNPS restriction from get_organization_name
FUNCTION get_organization_name ( p_org_id IN HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE ) RETURN HR_ORGANIZATION_UNITS.NAME%TYPE;
pragma RESTRICT_REFERENCES (get_organization_name, WNDS);

PROCEDURE delete_grant(  p_person_id  IN NUMBER
                        ,p_org_id     IN NUMBER
                        ,p_role_name  IN VARCHAR2
                        ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                       );

PROCEDURE insert_grant( p_person_id   IN NUMBER
                        ,p_org_id     IN NUMBER
                        ,p_role_name  IN VARCHAR2
                        ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                       );


FUNCTION GetValJobGradeId (P_job_id IN per_jobs.job_id%TYPE,
                           P_Job_Grp_Id IN per_jobs.job_group_id%TYPE)
					return per_valid_grades.grade_id%type;
pragma RESTRICT_REFERENCES (GetValJobGradeId, WNDS );

PROCEDURE GetToJobId (P_From_Forecast_JobGrpId IN per_jobs.job_group_id%TYPE,
                      P_From_JobId IN per_jobs.job_id%TYPE,
                      P_To_Proj_Cost_JobGrpId IN per_jobs.job_group_id%TYPE,
                      X_To_JobId OUT NOCOPY per_jobs.job_id%TYPE); --File.Sql.39 bug 4440895

PROCEDURE GetToJobName (P_From_Forecast_JobGrpId IN per_jobs.job_group_id%TYPE,
                        P_From_JobId IN per_jobs.job_id%TYPE,
                        P_To_Proj_Cost_JobGrpId IN per_jobs.job_group_id%TYPE,
                        X_To_JobName OUT NOCOPY per_jobs.name%TYPE); --File.Sql.39 bug 4440895




--  PROCEDURE
--              get_resource_analyst
--  PURPOSE
--              This procedure does the following
--              If Person Id is passed it retrives the corresponding
--              resource analyst Id ,Resource Analyst Name,Primary contact Id ,
--              Name.
--  HISTORY
--   25-SEP-2000      R Iyengar

PROCEDURE get_resource_analyst
                          (P_PersonId             IN NUMBER,
                           P_ResourceIdTab        OUT NOCOPY PLSQLTAB_INTARRAY,
                           P_ResourceAnalystTab   OUT NOCOPY PLSQLTAB_NAMEARRAY,
                           P_PrimaryContactId     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           P_PrimaryContactName   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           X_return_Status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           X_error_message_code   OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


--  PROCEDURE
--              get_org_primary_contact
--  PURPOSE
--              This  procedure does the following
--              If Resource Id is passed it retrives the corresponding
--              resource primary contact Id , Name,Managerid and manager name.
--  HISTORY
--
--  29-SEP-2000      R Iyengar   created
--  05-SEP-2001      virangan    Added p_assignment_id parameter
--  03-OCT-2001      virangan    Defaulted p_assignment_id

PROCEDURE get_org_primary_contact(P_ResourceId    IN  NUMBER,
                           p_assignment_id        IN  NUMBER DEFAULT NULL,
                           x_PrimaryContactId     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_PrimaryContactName   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_ManagerId            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_ManagerName          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_return_Status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                           );

--  PROCEDURE
--              get_resource_id
--  PURPOSE
--              This  function returns back the resource_id
--              for a person based on the person_Id passed in.
--  HISTORY
--  08-NOV-2000      R Fadia

FUNCTION get_resource_id(P_Person_Id IN NUMBER)
RETURN NUMBER;

--
--  FUNCTION
--              Get_Resource_Headcount
--  PURPOSE
--              This  function gets the resource head count for a given
--              organization, category, period type, period name, Global
--              week end date and year.
--
--  HISTORY     Changes for BUG: 1660614
--              Added the following new parameters:
--              p_category : This could be one of the following.
--                         1. SUBORG_EMP - Includes all subordinate excluding the direct reports
--                         2. DIRECT_EMP - Includes all the direct reports
--                         3. TOTAL_EMP - Includes all subordinates
--              p_period_type: Possible values are GL - gl period, GE - global expenditure
--                             week, PA - pa period, QR - quarter, YR - year
--              p_period_name: Values only for GL and PA periods, Quarter number for QR
--              p_end_date: Only for global expenditure week GE
--              p_year : For YR and QR types - pass the year
FUNCTION Get_Resource_Headcount(p_org_id IN NUMBER,
                                p_category IN VARCHAR2,
                                p_period_type IN VARCHAR2,
                                p_period_name IN VARCHAR2,
                                p_end_date in DATE,
                                p_year in NUMBER) RETURN NUMBER;

PROCEDURE Set_Period_Date(p_period_type IN VARCHAR2,
                         p_period_name IN VARCHAR2,
                         p_end_date    IN DATE,
                         p_year        IN NUMBER);

PROCEDURE get_manager_id_name(P_personid           IN  NUMBER,
                              p_start_date         IN  DATE,
                              x_ManagerId          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_ManagerName        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_error_message_code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_return_status      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION Get_People_Assigned(p_org_id in pa_resources_denorm.resource_organization_id%TYPE,
                             p_date in DATE,
			     p_emp_type IN VARCHAR DEFAULT 'EMP') RETURN number; --Added p_emp_type for bug 5680366

--  PROCEDURE
--              get_resource_manager_id
--  PURPOSE
--              This function returns the root manager_id for the logged in
--              FND user
--  HISTORY
--  27-JAN-2001 virangan  Created
FUNCTION get_resource_manager_id(p_user_id IN NUMBER) RETURN NUMBER;

--  PROCEDURE
--              get_resource_capacity
--  PURPOSE
--              This function returns the capacity hours for a resource
--              for the given week
--  HISTORY
--  14-MAR-2001 virangan  Created
FUNCTION get_resource_capacity(res_id IN NUMBER, week_start_date IN DATE)
                               RETURN NUMBER;


--  PROCEDURE
--              Get_Current_Project_NameNumber
--  PURPOSE
--              This function has been created for CURRENT_PROJECT_NAME_NUMBER column
--              of pa_resource_availability_v. This will return the project namd and
--              number in the format: project_name(project_number).
--
--  HISTORY
--  09-APR-2001 snam  Created
FUNCTION Get_Current_Project_NameNumber(p_resource_id IN NUMBER)
 RETURN VARCHAR2;

--  PROCEDURE
--              Get_Current_Project_Id
--  PURPOSE
--              This function has been created for CURRENT_PROJECT_ID column
--              of pa_resource_availability_v. This procedure should be called after
--              calling 'Get_Current_Project_NameNumber'.
--  HISTORY
--    05-Sep-2001 snam  Created
FUNCTION Get_Current_Project_Id(p_resource_id IN NUMBER)
RETURN NUMBER;

--  PROCEDURE
--              Get_Person_name
--  PURPOSE
--              This procedure returns the persons name for
--              a given person_id
--
--  HISTORY
--              10-MAY-2001  created  virangan
--
PROCEDURE get_person_name (     p_person_id           IN  NUMBER,
                                x_person_name         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status       OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--  PROCEDURE
--              Get_Location_Details
--  PURPOSE
--              This procedure returns  location details for
--              given location id
--
--  HISTORY
--              10-MAY-2001  created  virangan
--
PROCEDURE get_location_details (p_location_id         IN  NUMBER,
                                x_address_line_1      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_address_line_2      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_address_line_3      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_town_or_city        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_postal_code         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_country             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status       OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--  PROCEDURE
--              Get_Org_Defaults
--  PURPOSE
--              This procedure returns the default operating unit and default
--              calendar for an organization
--
--  HISTORY
--              10-MAY-2001  created  virangan
--
PROCEDURE get_org_defaults (p_organization_id           IN  NUMBER,
                            x_default_ou                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_default_cal_id            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_return_status             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--  PROCEDURE
--              Check_Exp_Org
--  PURPOSE
--              This procedure checks if an organization belongs
--              to an expenditure hierarchy or not
--
--  HISTORY
--              10-MAY-2001  created  virangan
--
PROCEDURE Check_Exp_Org (p_organization_id   IN  NUMBER,
                         x_valid             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         x_return_status     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--  PROCEDURE
--              Check_Res_Exists
--  PURPOSE
--              This procedure checks if a person exists in PA
--              giver a person_id
--
--  HISTORY
--              10-MAY-2001  virangan   created
--              28-MAR-2001  adabdull   Added parameter p_party_id and set
--                                      this and p_person_id with default null
PROCEDURE Check_Res_Exists (p_person_id         IN  NUMBER DEFAULT NULL,
                            p_party_id          IN  NUMBER DEFAULT NULL,
                            x_valid             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_return_status     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--  FUNCTION
--           Get_Org_Prim_Contact_Name
--  PURPOSE
--           This function returns the primary contact name of the given organzation
--  HISTORY
--           11-JUL-2001 snam  Created
FUNCTION Get_Org_Prim_Contact_Name(p_org_id         IN NUMBER,
                                   p_prim_role_name IN VARCHAR2)
RETURN VARCHAR2;


--  FUNCTION
--           Get_Org_Prim_Contact_Id
--  PURPOSE
--           This function returns the primary_contact_id of the org which has been queried
--           in the function 'Get_Org_Prim_Contact_Name'. This function should be used only
--           after calling the funtion 'Get_Org_Prim_Contact_Name'.
--  HISTORY
--           27-AUG-2001 snam  Created
FUNCTION Get_Org_Prim_Contact_Id(p_org_id         IN NUMBER,
                                 p_prim_role_name IN VARCHAR2)
RETURN NUMBER;


--  FUNCTION
--              Is_Future_Resource
--  PURPOSE
--              This procedure checks if a person has only future
--              records in pa_resources_denorm
--
--  HISTORY
--              31-AUG-2001  created  virangan
--
FUNCTION Is_Future_Resource (p_resource_id IN NUMBER)
 RETURN VARCHAR2;

--  FUNCTION
--              Is_Past_Resource
--  PURPOSE
--              This procedure checks if a person has only past
--              records in pa_resources_denorm
--
--  HISTORY
--              01-JAN-2009  created  asahoo
--
FUNCTION Is_Past_Resource (p_resource_id IN NUMBER)
 RETURN VARCHAR2;

--  FUNCTION
--              Is_Future_Rehire -- added for bug 8988264
--  PURPOSE
--              This procedure checks if a person has only future
--              records in pa_resources_denorm
--
--  HISTORY
--              28-DEC-2009  created  skkoppul
--
FUNCTION Is_Future_Rehire (p_resource_id IN NUMBER)
 RETURN VARCHAR2;

--  FUNCTION
--              Get_Resource_Start_Date_Rehire -- added for 8988264
--  PURPOSE
--              This procedure returns the start date of the resource
--              in pa_resources_denorm
--
--  HISTORY
--              28-DEC-2009  created  skkoppul
--
FUNCTION Get_Resource_Start_Date_Rehire (p_resource_id IN NUMBER)
			RETURN DATE;

 --bug#9062662 start
 --  FUNCTION
--              Get_Resource_End_date
--  PURPOSE
--              This procedure returns the end  date of the resource
--              in pa_resources_denorm
--
--  HISTORY
--              12-Dec-2009  created  NISINHA
--
FUNCTION Get_Resource_end_Date (p_resource_id IN NUMBER)
                        RETURN DATE;
--bug#9062662 end


--  FUNCTION
--              Get_Resource_Start_date
--  PURPOSE
--              This procedure returns the start date of the resource
--              in pa_resources_denorm
--
--  HISTORY
--              31-AUG-2001  created  virangan
--
FUNCTION Get_Resource_Start_Date (p_resource_id IN NUMBER)
			RETURN DATE;


--  FUNCTION
--              Get_Person_Start_date
--  PURPOSE
--              This procedure returns the start date of the person
--              in per_all_people_f
--
--  HISTORY
--             21-JAN-2003  created  sramesh for bug 2686120
--
FUNCTION Get_Person_Start_Date (p_person_id IN NUMBER)
			RETURN DATE;
--  FUNCTION
--              Get_Resource_Effective_date
--  PURPOSE
--              This procedure returns the effective date of the resource
--              in pa_resources_denorm. This is the resource_effective_start_date
--              for a future resource or sysdate for active resources
--
--  HISTORY
--              17-SEP-2001  created  virangan
--
FUNCTION Get_Resource_Effective_Date (p_resource_id IN NUMBER)
	  RETURN DATE;

--
--  PROCEDURE
--              Get_Res_Capacity
--  PURPOSE
--              This procedure does the following
--              For the given Resource Id, start date and end date
--              gets the capacity hours for the resource
--  HISTORY
--              04-SEP-2001 Vijay Ranganathan    created
--
 FUNCTION  get_res_capacity( p_resource_id          IN      NUMBER,
							                      p_start_date           IN      DATE,
							                      p_end_date             IN      DATE)
		RETURN NUMBER;

--
--  PROCEDURE
--              Get_Res_Wk_Capacity
--  PURPOSE
--              This procedure does the following
--              For the given Resource Id, week date date
--              gets the capacity hours for the resource
--  HISTORY
--              13-SEP-2001 Vijay Ranganathan    created
--
 FUNCTION  get_res_wk_capacity( p_resource_id          IN      NUMBER,
                                p_wk_date              IN      DATE)
		RETURN NUMBER;

--  FUNCTION
--              get_pa_logged_user
--  PURPOSE
--              This procedure checks if logged user is
--              Project Super User or Resource Manager
--              or Staffing Manager
--
--  HISTORY
--              25-SEP-2001  created  virangan
--
FUNCTION get_pa_logged_user ( p_authority IN VARCHAR2 DEFAULT 'RESOURCE')
	RETURN VARCHAR2;

--
--  PROCEDURE
--              Get_Provisional_hours
--  PURPOSE
--              This procedure gets the provisional hours
--              for a resource on a given date
--  HISTORY
--              22-OCT-2001 Vijay Ranganathan    created
--
FUNCTION get_provisional_hours
    ( p_resource_id IN Number,
      p_Week_date IN DATE)
RETURN NUMBER;

--
--  PROCEDURE
--              Get_Confirmed_hours
--  PURPOSE
--              This procedure gets the confirmed hours
--              for a resource based on the date set in
--              the get_provisional_hours call
--  HISTORY
--              22-OCT-2001 Vijay Ranganathan    created
--
FUNCTION get_confirmed_hours
RETURN NUMBER;

--  FUNCTION
--           check_user_has_res_auth
--  PURPOSE
--           This function checks if the given user has resource authority
--           over the specified resource
--  HISTORY
--           03-OCT-2001 virangan  Created
FUNCTION check_user_has_res_auth (p_user_person_id  IN NUMBER
                                 ,p_resource_id IN NUMBER )
    RETURN VARCHAR2;

--  PROCEDURE
--              get_person_id
--  PURPOSE
--              This  function returns back the person_id
--              for a person based on the resource_id passed in.
--  HISTORY
--  13-NOV-2001      shyugen

FUNCTION get_person_id(p_resource_id IN NUMBER)
RETURN NUMBER;

--
--  FUNCTION
--              get_person_id_from_party_id
--  PURPOSE
--              This  function returns back the person_id
--              for a person based on the party_id passed in.
--  HISTORY
--  22-OCT-2002      ramurthy

FUNCTION get_person_id_from_party_id(p_party_id IN NUMBER)
RETURN NUMBER;
--

--  PROCEDURE
--              check_res_not_terminated
--  PURPOSE
--              This function returns true if the person has not been
--              terminated and false if it is a terminated employee.
--  HISTORY
--  14-FEB-2003 ramurthy  Created
FUNCTION check_res_not_terminated(p_object_type          IN VARCHAR2,
                                  p_object_id            IN NUMBER,
                                  p_effective_start_date IN DATE)
RETURN BOOLEAN;


--  PROCEDURE
--           validate_person
--  PURPOSE
--           This procedure checks if the resource is valid as of the
--           start date in the pa_resources_denorm table
--
PROCEDURE validate_person (   p_person_id             IN NUMBER,
                              p_start_date            IN DATE,
                              x_return_status         OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--  PROCEDURE
--              get_party_id
--  PURPOSE
--              This  function returns back the party_id
--              for a person based on the resource_id passed in.
--  HISTORY
--  01-APR-2002      adabdull

FUNCTION get_party_id(p_resource_id IN NUMBER)
RETURN NUMBER;


--  PROCEDURE
--              get_resource_type
--  PURPOSE
--              This  function returns back the resource_type
--              for a person based on the resource_id passed in.
--  HISTORY
--  01-APR-2002      adabdull

FUNCTION get_resource_type(p_resource_id IN NUMBER)
RETURN VARCHAR2;

--  PROCEDURE
--              allocate_unique
--  PURPOSE
--              This procedure returns a lock handle for retrieving
--              and releasing a dbms_lock
PROCEDURE allocate_unique(p_lock_name  IN VARCHAR2,
                          p_lock_handle OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


--  PROCEDURE
--              acquire_user_lock
--  PURPOSE
--              This procedure acquires a user lock and return
--              status (whether success or failure)
FUNCTION Acquire_User_Lock ( p_source_id         IN  NUMBER,
                             p_lock_for          IN  VARCHAR2)

RETURN NUMBER;


--  PROCEDURE
--              release_user_lock
--  PURPOSE
--              This procedure release a user lock and return
--              status (whether success or failure)
FUNCTION Release_User_Lock (p_source_id   IN  NUMBER,
                            p_lock_for    IN  VARCHAR2)
RETURN NUMBER;


--  PROCEDURE
--             get_resource_id
--  PURPOSE
--             This function returns the resource_id of the
--             person using the fnd user name passed to the
--             function
FUNCTION get_resource_id(p_user_name IN VARCHAR2 DEFAULT NULL,
                         p_user_id   IN NUMBER   DEFAULT NULL)
RETURN NUMBER;

--  PROCEDURE
--             get_res_name_from_type
--  PURPOSE
--             This function returns the name of the
--             person using the resource type to determine whether
--             it is an HR or HZ resource.
FUNCTION get_res_name_from_type(p_resource_type_id     IN NUMBER,
                                p_resource_source_id   IN NUMBER)
RETURN VARCHAR2;

--  PROCEDURE
--             get_resource_name
--  PURPOSE
--             This function returns the resource_name of the
--             resource_id passed in using pa_resources table
FUNCTION get_resource_name(p_resource_id IN NUMBER)
RETURN VARCHAR2;

--  FUNCTION
--              get_pa_logged_resp
--  PURPOSE
--              This procedure checks if logged responsibility is
--              Project Super User or Resource Manager
--              or Staffing Manager
--
--  HISTORY
--              23-July-2002  created  virangan
--
FUNCTION get_pa_logged_resp
	RETURN VARCHAR2;


--  PROCEDURE
--             Check_ManagerName_Or_Id
--  PURPOSE
--             Specifically for resource supervisor hierarchy use.
--             This procedure validates the manager_id and manager_name passed.
--             It also depends on the responsibility value. User needs to pass
--             RM if resource manager because it uses another view to validate
--             the manager (whether the manager belongs to the login user
--             HR supervisor hierarchy).
--  HISTORY
--             20-AUG-2002  Created    adabdull
--+
PROCEDURE Check_ManagerName_Or_Id(
                            p_manager_name       IN  VARCHAR2
                           ,p_manager_id         IN  NUMBER
                           ,p_responsibility     IN  VARCHAR2 DEFAULT NULL
                           ,p_check              IN  VARCHAR2 DEFAULT 'N'
                           ,x_manager_id         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                           ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                           ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                           ,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE get_org_id(P_personid            IN  NUMBER,
                     p_start_date          IN  DATE,
                     x_orgid               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_error_message_code  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_return_status       OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


--  FUNCTION
--              get_person_name_no_date
--  PURPOSE
--              This function returns the latest person name not
--              based on any date.
--
--  HISTORY
--  28-APR-2003   shyugen

FUNCTION get_person_name_no_date(p_person_id IN NUMBER)
RETURN VARCHAR;

/*Bug 3737529: Code addition starts*/
FUNCTION get_hr_manager_id(p_resource_id IN NUMBER,p_start_date IN  DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION get_hr_manager_name(p_resource_id IN NUMBER,p_start_date IN  DATE DEFAULT NULL)
RETURN VARCHAR2;
/*Bug 3737529: Code addition ends*/

/* *******************************************************************
 * This function checks to see if the given supplier ID is used by any
 * planning resource lists or resource breakdown structures.  If it is
 * in use, it returns 'Y'; if not, it returns 'N'
 * ******************************************************************* */
FUNCTION chk_supplier_in_use(p_supplier_id IN NUMBER)
RETURN VARCHAR2;

--
--  FUNCTION
--              get_term_type
--  PURPOSE
--              This function returns the leaving/termination reason type
--              of an employee/contingent worker as 'V' or 'I'
--  HISTORY
--   05-MAR-207       kjai       Created for Bug 5683340
--
 FUNCTION get_term_type( p_person_id     IN PA_EMPLOYEES.PERSON_ID%TYPE )
 RETURN VARCHAR2;

--
--  PROCEDURE
--              Init_FTE_Sync_WF
--  PURPOSE
--              This procedure is used to initiate Timeout_Termination_Process
--              workflow for future termination of employee.
--
--  HISTORY
--   05-MAR-207       kjai       Created for Bug 5683340
--
 PROCEDURE Init_FTE_Sync_WF(
                            p_person_id     IN    PA_EMPLOYEES.PERSON_ID%TYPE,
                            x_invol_term    OUT  NOCOPY VARCHAR2,
                            x_return_status OUT  NOCOPY VARCHAR2,
                            x_msg_data      OUT  NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER);

--
--  PROCEDURE
--              set_fte_flag
--  PURPOSE
--              This procedure sets the new future_term_wf_flag
--              in table pa_resources for the passed person_id
--  HISTORY
--  05-MAR-207       kjai       Created for Bug 5683340
--
PROCEDURE Set_fte_flag(p_person_id IN PA_EMPLOYEES.PERSON_ID%TYPE,
                       p_future_term_wf_flag IN PA_RESOURCES.FUTURE_TERM_WF_FLAG%TYPE,
                       x_return_status OUT  NOCOPY VARCHAR2,
                       x_msg_data      OUT  NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER);
--
--  PROCEDURE
--              get_fte_flag
--  PURPOSE
--              This procedure gets the new future_term_wf_flag
--              in table pa_resources for the passed person_id
--  HISTORY
--  05-MAR-207       kjai       Created for Bug 5683340
--
PROCEDURE Get_fte_flag(p_person_id     IN PA_EMPLOYEES.PERSON_ID%TYPE,
                       x_future_term_wf_flag OUT NOCOPY PA_RESOURCES.FUTURE_TERM_WF_FLAG%TYPE,
                       x_return_status OUT  NOCOPY VARCHAR2,
                       x_msg_data      OUT  NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER);

--
--  PROCEDURE
--              is_fte
--  PURPOSE
--              This procedure checks whether the person is an FTE, as of sysdate.
--              If he is, then returns the actual term date , wait days.
--  HISTORY
--  05-MAR-207       kjai       Created for Bug 5683340
--
PROCEDURE Is_fte( p_person_id     IN PA_EMPLOYEES.PERSON_ID%TYPE ,
                  x_return_end_date OUT	NOCOPY DATE ,
                  x_wait_days       OUT NOCOPY NUMBER ,
                  x_invol_term      OUT NOCOPY VARCHAR2,
                  x_return_status OUT  NOCOPY VARCHAR2,
                  x_msg_data      OUT  NOCOPY VARCHAR2,
                  x_msg_count OUT NOCOPY NUMBER);

--
--  PROCEDURE
--              get_valid_enddate
--  PURPOSE
--              This procedure returns a valid end date if person is an FTE(as of sysdate)
--
--  HISTORY
--  05-MAR-207       kjai       Created for Bug 5683340
--
PROCEDURE get_valid_enddate(p_person_id     IN PA_EMPLOYEES.PERSON_ID%TYPE ,
                            p_actual_term_date IN DATE ,
                            x_valid_end_date OUT NOCOPY DATE,
                            x_return_status OUT  NOCOPY VARCHAR2,
                            x_msg_data      OUT  NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER);

--
--  PROCEDURE
--              is_term_as_of_sys_date
--  PURPOSE
--              This procedure checks whether the employee / cwk
--              is terminated as of sysdate
--  HISTORY
--   05-MAR-207       kjai       Created for Bug 5683340
--
 PROCEDURE is_term_as_of_sys_date( itemtype                      IN      VARCHAR2
                                 , itemkey                       IN      VARCHAR2
                                 , actid                         IN      NUMBER
                                 , funcmode                      IN      VARCHAR2
                                 , resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


END pa_resource_utils ;

/
