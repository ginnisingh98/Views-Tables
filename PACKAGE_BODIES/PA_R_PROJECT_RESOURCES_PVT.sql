--------------------------------------------------------
--  DDL for Package Body PA_R_PROJECT_RESOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_R_PROJECT_RESOURCES_PVT" 
-- $Header: PARCPRVB.pls 120.20.12010000.12 2010/02/10 06:27:01 amehrotr ship $
AS

 --Global Variables
 G_pkg_name             VARCHAR2(30) := 'PA_R_PROJECT_RESOURCES_PVT';

 --Variable for insert multiple assignment information for a resource.
 G_p_id                 NUMBER       := 0;
 G_count                NUMBER       := 0;

 --Variable to call crm workflow once for all hr assignments of a person
 G_p_crmwf_id           NUMBER       := 0;

 --Forward declaration

P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */

PROCEDURE start_crm_workflow ( p_person_id                 IN  NUMBER,
                                                           p_assignment_start_date     IN  DATE,
                               x_return_status             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_error_message_code        OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- Begin Bug 3086960. Added by Sachin.

 --This cursor will loop through each person_id from HR
 CURSOR CUR_RESOURCES(p_in_person_id    IN NUMBER,
                      p_pull_term_res   IN VARCHAR2,
                      p_term_range_date IN DATE,
                      p_person_type     IN VARCHAR2) IS
 SELECT person_id,
        name,
        organization_id,
        assignment_start_date,
        assignment_end_date,
        start_date,termination_date,
        default_OU,
        calendar_id,
        p_type,
        user_type,
        res_exists,
        per_start_date,
        per_end_date,
        per_emp_number,
        per_email,
        per_work_phone,
        per_business_group_id,
        per_first_name,
        per_last_name,
        per_middle_name,
        job_name,
        supervisor_id,
        org_name,
        resource_type,
        job_id,
        job_group_id,
        location_id
 FROM   pa_r_project_resources_v
 WHERE  person_id = p_in_person_id
   AND  (p_type = p_person_type or p_person_type = 'ALL')
 UNION
 -- This select is to get each person_id from HR that is terminated
 -- if the user wants to pull in those people.
 SELECT person_id,
        name,
        organization_id,
        assignment_start_date,
        assignment_end_date,
        start_date,termination_date,
        default_OU,
        calendar_id,
        p_type,
        user_type,
        res_exists,
        per_start_date,
        per_end_date,
        per_emp_number,
        per_email,
        per_work_phone,
        per_business_group_id,
        per_first_name,
        per_last_name,
        per_middle_name,
        job_name,
        supervisor_id,
        org_name,
        resource_type,
        job_id,
        job_group_id,
        location_id
 FROM   pa_r_project_resources_term_v
 WHERE  p_pull_term_res = 'Y'
 and    person_id = p_in_person_id
 and    termination_date >= p_term_range_date
 AND    (p_type = p_person_type or p_person_type = 'ALL')
 ORDER BY person_id, assignment_start_date;

/*
 --This cursor will loop through each person_id from HR
 CURSOR CUR_RESOURCES(l_from_emp_num IN VARCHAR2, l_to_emp_num IN VARCHAR2, l_p_org_id IN NUMBER) IS
 SELECT person_id,
        name,
        organization_id,
        assignment_start_date,
        assignment_end_date,
        start_date,termination_date,
        default_OU,
        calendar_id,
        p_type,
        user_type,
        res_exists,
        per_start_date,
        per_end_date,
        per_emp_number,
        per_email,
        per_work_phone,
        per_business_group_id,
        per_first_name,
        per_last_name,
        per_middle_name,
        job_name,
        supervisor_id,
        org_name,
        resource_type,
        job_id,
        job_group_id,
        location_id
 FROM        pa_r_project_resources_v
 WHERE  per_emp_number >= nvl(l_from_emp_num, per_emp_number) and
        per_emp_number <= nvl(l_to_emp_num, per_emp_number) and
        organization_id = nvl(l_p_org_id, organization_id)
 ORDER BY person_id, assignment_start_date;
*/

-- End Bug 3086960.

 --This is a cursor for getting resource information from the
 --view for a resource while performing individual insert.
 CURSOR CUR_IND_PERSON (l_per_id IN NUMBER)
 IS
 SELECT person_id,
        name,
        organization_id,
        assignment_start_date,
        assignment_end_date,
        start_date,
        termination_date,
        p_type,
        user_type,
        location_id,
        per_start_date,
        per_end_date,
        per_emp_number,
        per_email,
        per_work_phone,
        per_business_group_id,
        per_first_name,
        per_last_name,
        per_middle_name,
        job_name,
        supervisor_id,
        org_name,
        resource_type,
        job_id,
        job_group_id
 FROM pa_r_project_resources_ind_v
 WHERE person_id = l_per_id
/* Start of Changes for Bug 6056112 */
 UNION
 SELECT person_id,
        name,
        organization_id,
        assignment_start_date,
        assignment_end_date,
        start_date,
        termination_date,
        p_type,
        user_type,
        location_id,
        per_start_date,
        per_end_date,
        per_emp_number,
        per_email,
        per_work_phone,
        per_business_group_id,
        per_first_name,
        per_last_name,
        per_middle_name,
        job_name,
        supervisor_id,
        org_name,
        resource_type,
        job_id,
        job_group_id
 FROM pa_r_project_resources_ind_t_v
 WHERE person_id = l_per_id
/* End of Changes for Bug 6056112 */
 order by person_id, assignment_start_date;

--------------------------------------------------------------------------------------------------------------
-- This procedure prints the text which is being passed as the input
-- Input parameters
-- Parameters                   Type           Required  Description
--  p_log_msg                   VARCHAR2        YES      It stores text which you want to print on screen
-- Out parameters
----------------------------------------------------------------------------------------------------------------
PROCEDURE log_message (p_log_msg IN VARCHAR2)
IS
BEGIN
    --dbms_output.put_line('log: ' || p_log_msg);
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.write('start_crm_workflow: ' || 'Resource Pull', 'log: ' || p_log_msg, 3);
    END IF;
    NULL;
END log_message;

/* --------------------------------------------------------------------
FUNCTION: Max_Date
PURPOSE:  This function compares the dates passed in and returns
          the latest of these dates back to the calling function.
          This function is called with the following IN parameters:
          p_latest_start_date       : Latest Start Date of the person
                                      in all period of services he/she
                                      has in HR.
          p_earliest_utl_start_date : Earliest Date to start keeping
                                      Utilization records. This value
                                      is from profile PA_UTL_START_DATE
          p_calander_start_date     : The start date of the CRM calendar.
          If all the IN Parameters are NULL, it will pass back
          sysdate.
-------------------------------------------------------------------- */
FUNCTION Max_Date(p_latest_start_date       IN DATE,
                  p_earliest_utl_start_date IN DATE,
                  p_calander_start_date     IN DATE)
RETURN DATE
IS
  l_latest_start_date        DATE;
  l_earliest_utl_start_date  DATE;
  l_calander_start_date      DATE;
  l_max_start_date           DATE := sysdate;
BEGIN

   IF p_latest_start_date is not null THEN
      l_max_start_date := p_latest_start_date;
   END IF;

   IF p_earliest_utl_start_date is not null THEN
       IF p_earliest_utl_start_date > l_max_start_date THEN
           l_max_start_date := p_earliest_utl_start_date;
       END IF;
   END IF;

   IF  l_calander_start_date is not null THEN
       IF l_calander_start_date > l_max_start_date THEN
           l_max_start_date := l_calander_start_date;
       END IF;
   END IF;

   IF l_max_start_date is null THEN
      l_max_start_date := sysdate;
   END IF;

   RETURN l_max_start_date;

END Max_Date;

/* --------------------------------------------------------------------
FUNCTION: Validate_Person
PURPOSE:  This function gives an error message based on the setup
          not done for the person due to which the person cannot be
          pulled in as a resource.
          This API is called from CREATE_RESOURCE API only when that
          API is called in single resource mode.
 -------------------------------------------------------------------- */
Procedure Validate_Person(p_person_id IN NUMBER)
IS
   l_assignment_id    NUMBER;
   l_job_id           NUMBER;
   l_person_type      VARCHAR2(30);

/* Bug#2683266-Commented the cursor get_person_type and added cursor validate_person_type

   cursor get_person_type
   is
   select person_id
   from per_people_f per,
        per_person_types ptype
   where per.person_id             = p_person_id
   and   per.person_type_id        = ptype.person_type_id
   and   (ptype.system_person_type  = 'EMP'
             OR ptype.system_person_type = 'EMP_APL');

End of comment for bug#2683266 */

/* New cursor validate_person_type added for bug#2683266 */

   cursor validate_person_type
   is
   select person_id
   from per_all_people_f per                          /* per_people_f per Commented for bug 2983491 , Added per_all_people_f for it*/
   where per.person_id             = p_person_id
   and (per.current_employee_flag = 'Y' OR per.current_npw_flag = 'Y');

   cursor get_active_assignment
   is
   select asgn.assignment_id
   from per_all_assignments_f asgn,         /* from per_assignments_f per Commented for bug 2983491 , Added per_all_assignments_f for it*/
        per_assignment_status_types status,
        (select person_id, actual_termination_date from per_periods_of_service
         union all
         select person_id, actual_termination_date
           from per_periods_of_placement) po
   where asgn.person_id                  = p_person_id
   and   nvl(po.actual_termination_date, trunc(sysdate)) >= trunc(sysdate)
   and   asgn.person_id                  = po.person_id
   and   po.person_id                   = p_person_id
   and   asgn.assignment_status_type_id  = status.assignment_status_type_id
   and   status.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK')
   and   asgn.assignment_type            in ('E', 'C')     --Added for 2911451
   and   rownum                          = 1;

   cursor get_primary_assignment
   is
   select asgn.assignment_id
   from  per_all_assignments_f asgn,         /* from per_assignments_f per Commented for bug 2983491 , Added per_all_assignments_f for it*/
        (select person_id, actual_termination_date from per_periods_of_service
         union all
         select person_id, actual_termination_date
           from per_periods_of_placement) po
   where asgn.person_id            = p_person_id
   and   asgn.primary_flag         = 'Y'
   and   asgn.assignment_type      in ('E', 'C')         --Added for 2911451
   and   po.person_id              = p_person_id
   and   nvl(po.actual_termination_date, trunc(sysdate)) >= trunc(sysdate)
   and   asgn.person_id            = po.person_id
   -- and   pos.period_of_service_id  = asgn.period_of_service_id -- FP M CWK
   and   rownum                    =1;

   cursor get_job_on_assignment
   is
   select asgn.job_id
   from  per_all_assignments_f asgn,         /* from per_assignments_f per Commented for bug 2983491 , Added per_all_assignments_f for it*/
        (select person_id, actual_termination_date from per_periods_of_service
         union all
         select person_id, actual_termination_date
           from per_periods_of_placement) po
   where asgn.person_id            = p_person_id
   and   asgn.primary_flag         = 'Y'
   and   asgn.assignment_type      in ('E', 'C')
   and   po.person_id             = p_person_id
   and   nvl(po.actual_termination_date, trunc(sysdate)) >= trunc(sysdate)
   and   asgn.person_id            = po.person_id
   -- and   pos.period_of_service_id  = asgn.period_of_service_id -- FP M CWK
   and   asgn.job_id is not null
   and   rownum                    = 1;


BEGIN
/* Bug#2683266 - Changed get_person_type cursor to validate_person_type in code below */

  OPEN validate_person_type;
  FETCH validate_person_type into l_person_type;
  IF validate_person_type%NOTFOUND THEN
     CLOSE validate_person_type;
     PA_UTILS.Add_Message( p_app_short_name  => 'PA'
                           ,p_msg_name       => 'PA_INVALID_PERSON_TYPE');

  ELSE
    CLOSE validate_person_type;
    OPEN get_active_assignment;
    FETCH get_active_assignment into l_assignment_id;
    IF get_active_assignment%NOTFOUND THEN
       CLOSE get_active_assignment;
       PA_UTILS.Add_Message( p_app_short_name  => 'PA'
                             ,p_msg_name       => 'PA_NO_ACTIVE_ASSIGNMENT');
    ELSE
      CLOSE get_active_assignment;
      OPEN get_primary_assignment;
      FETCH get_primary_assignment into l_assignment_id;
      IF get_primary_assignment%NOTFOUND THEN
         CLOSE get_primary_assignment;
         PA_UTILS.Add_Message( p_app_short_name  => 'PA'
                               ,p_msg_name       => 'PA_NO_PRIMARY_ASSIGNMENT');
      ELSE
        CLOSE get_primary_assignment;
        OPEN get_job_on_assignment;
        FETCH get_job_on_assignment into l_job_id;
        IF get_job_on_assignment%NOTFOUND THEN
           CLOSE get_job_on_assignment;
           PA_UTILS.Add_Message( p_app_short_name  => 'PA'
                                 ,p_msg_name       => 'PA_NO_JOB_ON_ASSIGNMENT');
        ELSE
           CLOSE get_job_on_assignment;
           PA_UTILS.Add_Message( p_app_short_name  => 'PA'
                                 ,p_msg_name       => 'PA_RS_INVALID_SETUP');
        END IF;
      END IF;
    END IF;
  END IF;
END Validate_Person;


/*Procedure : CRM Insert
This procedure checks if the resource exists in CRM and inserts the resource into CRM by calling the CRM public API jtf_rs_resource.create_resource if it does not exist.
It also inserts the calendar for the resource in CRM. If  the resource exists the procedure checks to see if the calendar in CRM has been end dated and if so inserts the new calendar.
The procedure also checks for internal resources having multiple assignments who might have a different calendar for each assignment. If calendar is not present in hr_organization_information the calendar_id is got from profile option.*/

 PROCEDURE INSERT_INTO_CRM(
        P_CATEGORY                   IN JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
        P_PERSON_ID                  IN JTF_RS_RESOURCE_extns.SOURCE_id%TYPE,
        P_NAME                       IN JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE,
        P_START_DATE                 IN JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE,
        P_ASSIGNMENT_START_DATE      IN DATE,
        P_ASSIGNMENT_END_DATE        IN DATE,
        P_CALENDAR_ID                IN NUMBER,
        P_COUNT                      IN NUMBER,
        X_CRM_RESOURCE_ID            OUT NOCOPY JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE , --File.Sql.39 bug 4440895
        X_RETURN_STATUS              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        P_START_DATE_ACTIVE          IN pa_r_project_resources_ind_v.per_start_date%TYPE,
        P_END_DATE_ACTIVE            IN pa_r_project_resources_ind_v.per_end_date%TYPE,
        P_SOURCE_NUMBER              IN pa_r_project_resources_ind_v.per_emp_number%TYPE,
        P_SOURCE_JOB_TITLE           IN pa_r_project_resources_ind_v.job_name%TYPE,
        P_SOURCE_EMAIL               IN pa_r_project_resources_ind_v.per_email%TYPE,
        P_SOURCE_PHONE               IN pa_r_project_resources_ind_v.per_work_phone%TYPE,
        P_SOURCE_ADDRESS1            IN HR_LOCATIONS.ADDRESS_LINE_1%TYPE,
        P_SOURCE_ADDRESS2            IN HR_LOCATIONS.ADDRESS_LINE_2%TYPE,
        P_SOURCE_ADDRESS3            IN HR_LOCATIONS.ADDRESS_LINE_3%TYPE,
        P_SOURCE_CITY                IN HR_LOCATIONS.TOWN_OR_CITY%TYPE,
        P_SOURCE_POSTAL_CODE         IN HR_LOCATIONS.POSTAL_CODE%TYPE,
        P_SOURCE_COUNTRY             IN HR_LOCATIONS.COUNTRY%TYPE,
        P_SOURCE_MGR_ID              IN pa_r_project_resources_ind_v.supervisor_id%TYPE,
        P_SOURCE_MGR_NAME            IN PER_ALL_PEOPLE_F.FULL_NAME%TYPE,
        P_SOURCE_BUSINESS_GRP_ID     IN pa_r_project_resources_ind_v.per_business_group_id%TYPE,
        P_SOURCE_BUSINESS_GRP_NAME   IN pa_r_project_resources_ind_v.org_name%TYPE,
        P_SOURCE_FIRST_NAME          IN pa_r_project_resources_ind_v.per_first_name%TYPE,
        P_SOURCE_LAST_NAME           IN pa_r_project_resources_ind_v.per_last_name%TYPE,
        P_SOURCE_MIDDLE_NAME         IN pa_r_project_resources_ind_v.per_middle_name%TYPE)
 IS
        l_insert                     VARCHAR2(1) := 'N';
        l_end_date_insert            VARCHAR2(1) := 'N'; -- Bug 4668272

        --For inserting into jtf_cal_resource_assign.
        l_cal_resource_assign_id     JTF_CAL_RESOURCE_ASSIGN.CAL_RESOURCE_ASSIGN_ID%TYPE;
        l_msg_count                  NUMBER;
        l_msg_data                   VARCHAR2(100);
        --Used to check return status in jtf_cal_resource_assign_pkg.insert_row
        l_error                      VARCHAR2(1):= 'N';

        l_crm_resource_id            JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
        l_resource_number            JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE;

        l_resource_type_code         JTF_CAL_RESOURCE_ASSIGN.RESOURCE_TYPE_CODE%TYPE;
        l_category                   JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE := P_CATEGORY;
        l_start_date                 JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE := P_START_DATE_ACTIVE;
        l_person_id                  JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE := P_PERSON_ID;

        l_check_dup_id               varchar2(1);
        l_calendar_id                NUMBER := TO_NUMBER(P_CALENDAR_ID);

        l_rowid                      ROWID;
        l_user_id                    NUMBER;

        l_assignment_start_date      DATE := P_ASSIGNMENT_START_DATE;
        l_assignment_end_date        DATE := P_ASSIGNMENT_END_DATE;

        l_latest_start_date          DATE;
        l_earliest_utl_start_date    DATE;
        l_calander_start_date        DATE;

        -- For checking dates info in jtf_cal_resource_assign
        l_min_start_date             DATE;
        l_max_end_date               DATE; -- Bug 4668272
        l_populate_jtf_res_cal       VARCHAR2(1) := 'Y';   -- Bug 6411422

       /*
        * The following cursor is for CRM workaround for bug 1944726
        */
       CURSOR c_per_active IS
         SELECT PER.PERSON_ID
         FROM  PER_ALL_PEOPLE_F PER,   /*for bug 2983491  Replaced PER_PEOPLE_F PER ,  */
               PER_ALL_ASSIGNMENTS_F ASGN
         WHERE  ASGN.PERSON_ID       = PER.PERSON_ID
         AND    ASGN.PRIMARY_FLAG    = 'Y'
         AND    ASGN.ASSIGNMENT_TYPE in ('E', 'C')
         AND    TRUNC(SYSDATE) BETWEEN PER.EFFECTIVE_START_DATE AND PER.EFFECTIVE_END_DATE
         AND    TRUNC(SYSDATE) BETWEEN ASGN.EFFECTIVE_START_DATE AND ASGN.EFFECTIVE_END_DATE
         AND    (PER.EMPLOYEE_NUMBER IS NOT NULL OR PER.NPW_NUMBER IS NOT NULL)
         AND    PER.PERSON_ID           = p_person_id;

        CURSOR CUR_CRMID(l_person_id in jtf_rs_resource_extns.source_id%type,
                        l_category in jtf_rs_resource_extns.category%type)
        IS
                select resource_id
                from jtf_rs_resource_extns
                where source_id = l_person_id
                and category = l_category ;

        CURSOR c_dup_resource_assign_id (l_cal_resource_assign_id IN jtf_cal_resource_assign.cal_resource_assign_id%type)
        IS
                SELECT 'X'
                FROM jtf_cal_resource_assign
                WHERE cal_resource_assign_id = l_cal_resource_assign_id;

        CURSOR  c_jtf_cal(l_cal_resource_assign_id in jtf_cal_resource_assign.cal_resource_assign_id%type)
        IS
                SELECT rowid
                FROM   jtf_cal_resource_assign
                WHERE  cal_resource_assign_id = l_cal_resource_assign_id;

        CURSOR c_user_id(l_employee_id NUMBER)
        IS
                SELECT user_id
                FROM fnd_user
                WHERE employee_id = l_employee_id;

        CURSOR cur_crm_cal(l_crm_resource_id in NUMBER)
        IS
                SELECT 'Y'
                from jtf_cal_resource_assign
                where resource_id = l_crm_resource_id
                and resource_type_code = l_resource_type_code
                and l_assignment_start_date between start_date_time and nvl(end_date_time, to_date('31/12/4712', 'DD/MM/YYYY'))
                and primary_calendar_flag = 'Y';

        -- Bug 4668272 - Added cursor to handle the case of the assignment
        -- end date changing to be later than what it was.
        CURSOR cur_crm_cal_end(l_crm_resource_id in NUMBER)
        IS
                SELECT 'Y'
                from jtf_cal_resource_assign
                where resource_id = l_crm_resource_id
                and resource_type_code = l_resource_type_code
                and l_assignment_end_date between start_date_time and nvl(end_date_time, to_date('31/12/4712', 'DD/MM/YYYY'))
                and primary_calendar_flag = 'Y';

        CURSOR cur_crm_check_date
        IS
                SELECT MIN(start_date_time)
                from jtf_cal_resource_assign
                where resource_id = l_crm_resource_id
                and resource_type_code = l_resource_type_code
                and primary_calendar_flag = 'Y'
                and start_date_time between l_assignment_start_date and l_assignment_end_date;

        -- Bug 4668272 - Added cursor to handle the case of the assignment
        -- end date changing to be later than what it was.  This is parallel
        -- to the case that is already handled where the assignment
        -- start date is changed to be earlier that it was.  We want
        -- to insert another record for the last end date + 1 to the
        -- new end date.  NOTE: In the case where the end date is changed to
        -- be earlier than it was, we don't do anything since a calendar
        -- already exists for the time period - we ignore the fact that
        -- the end date is after the real HR end date since functionally
        -- it doesn't affect anything.  Similarly, when the start date is
        -- changed to be later than it was we don't do anything.

        CURSOR cur_crm_chk_end_date IS
                SELECT MAX(end_date_time)
                from jtf_cal_resource_assign
                where resource_id = l_crm_resource_id
                and resource_type_code = l_resource_type_code
                and primary_calendar_flag = 'Y';
                -- and end_date_time between l_assignment_start_date
                --                       and l_assignment_end_date;

        l_cal_exist         VARCHAR(1);
        l_cal_exist_end     VARCHAR(1);
        l_fde               VARCHAR(1);  -- Added for bug4690946

  BEGIN
        PA_DEBUG.set_err_stack('Insert_into_CRM');

        pa_debug.g_err_stage := 'Log: Start of Insert_into_CRM procedure';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('Inside insert_into_crm procedure');

        X_RETURN_STATUS := fnd_api.g_ret_sts_success;

        open cur_crmid(l_person_id,l_category);
        fetch cur_crmid into l_crm_resource_id;
        close cur_crmid;

        open c_user_id(p_person_id);
        fetch c_user_id into l_user_id;
        close c_user_id;

        ----------------------------------
        -- Check calendar
        -- l_calendar_id must not be null
        ----------------------------------

        --Get Calendar_Id from Profile Options if NULL
        if l_calendar_id is null then
            pa_debug.g_err_stage := 'Log: Calendar_id null, get from Profile options';
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
            END IF;
            l_calendar_id := fnd_profile.value_specific('PA_PRM_DEFAULT_CALENDAR');
        end if;

        --Calendar_Id from Profile Options is NULL
        --raise error
        if l_calendar_id is null then
            pa_debug.g_err_stage := 'Log: Calendar id null from Profile options - Invalid Calendar Setup';
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
            END IF;
            PA_UTILS.Add_Message(
                 p_app_short_name => 'PA'
                ,p_msg_name       => 'PA_INVALID_CAL_SETUP');
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
        end if;

        -------------------------------------------
        -- Resource does not exist in CRM
        -- Get a crm_resource_id for this resource
        -------------------------------------------
        IF (l_crm_resource_id is null) THEN
            --Call CRM public API
            pa_debug.g_err_stage := 'Log: Resource does not exist in CRM, calling CRM Public API';
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
            END IF;
            log_message('Resource does not exist in CRM, call CRM Public API');

            OPEN c_per_active ;
            FETCH c_per_active INTO l_person_id;

/* Added for bug 4690946 */
            BEGIN
               SELECT 'Y'
                 INTO l_fde
                 FROM dual
                WHERE EXISTS (
                      SELECT 'Y'
                        FROM per_all_people_f
                       WHERE person_id = l_person_id
                         AND (current_employee_flag = 'Y' OR
                              current_npw_flag = 'Y')
                         AND trunc(effective_start_date) > trunc(sysdate));
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     l_fde := 'N';
            END;
/* End bug 4690946 */

            ---------------------------------------------
            -- Future-dated employee, start the workflow
            ---------------------------------------------
            IF c_per_active%NOTFOUND AND l_fde = 'Y' THEN
                                     -- second condition added for 4690946

               --This person is a future dated employee
               --Workflow is launched below to pull this person on his start date
               --This must be done only once for all assignments of this person

               if G_p_crmwf_id <> p_person_id then

                  start_crm_workflow( p_person_id             => p_person_id,
                                      p_assignment_start_date => p_assignment_start_date,
                                      x_return_status         => x_return_status,
                                      x_error_message_code    => l_msg_data);

                  IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
                      log_message('Error in CRM Public API');
                      pa_debug.g_err_stage := 'Log: Error in CRM Workaround Workflow API';
                      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                         pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                      END IF;
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      CLOSE c_per_active;
                      RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  G_p_crmwf_id := p_person_id;
               end if;

            ELSE

               jtf_rs_resource_pub.create_resource(
                         P_API_VERSION                => 1.0,
                         P_INIT_MSG_LIST              => FND_API.G_FALSE,
                         P_COMMIT                     => FND_API.G_FALSE,
                         P_CATEGORY                   => l_category,
                         P_SOURCE_ID                  => l_person_id,
                         P_ADDRESS_ID                 => NULL,
                         P_CONTACT_ID                 => NULL,
                         P_MANAGING_EMP_ID            => NULL,
                         P_MANAGING_EMP_NUM           => NULL,
                         P_START_DATE_ACTIVE          => l_start_date,
                         P_END_DATE_ACTIVE            => P_END_DATE_ACTIVE,
                         P_TIME_ZONE                  => NULL,
                         P_COST_PER_HR                => NULL,
                         P_PRIMARY_LANGUAGE           => NULL,
                         P_SECONDARY_LANGUAGE         => NULL,
                         P_SUPPORT_SITE_ID            => NULL,
                         P_IES_AGENT_LOGIN            => NULL,
                         P_SERVER_GROUP_ID            => NULL,
                         P_INTERACTION_CENTER_NAME    => NULL,
                         P_ASSIGNED_TO_GROUP_ID       => NULL,
                         P_COST_CENTER                => NULL,
                         P_CHARGE_TO_COST_CENTER      => NULL,
                         P_COMP_CURRENCY_CODE         => NULL,
                         P_COMMISSIONABLE_FLAG        => NULL,
                         P_HOLD_REASON_CODE           => NULL,
                         P_HOLD_PAYMENT               => NULL,
                         P_COMP_SERVICE_TEAM_ID       => NULL,
                         P_USER_ID                    => NULL,  -- change to NULL from l_user_id
                         P_TRANSACTION_NUMBER         => NULL,
                         X_RETURN_STATUS              => x_return_status,
                         X_MSG_COUNT                  => l_msg_count,
                         X_MSG_DATA                   => l_msg_data,
                         X_RESOURCE_ID                => l_crm_resource_id,
                         X_RESOURCE_NUMBER            => l_resource_number,
                         P_RESOURCE_NAME              => p_name,
                         P_SOURCE_NAME                => p_name,
                         P_SOURCE_NUMBER              => P_SOURCE_NUMBER,
                         P_SOURCE_JOB_TITLE           => P_SOURCE_JOB_TITLE,
                         P_SOURCE_EMAIL               => P_SOURCE_EMAIL,
                         P_SOURCE_PHONE               => P_SOURCE_PHONE,
                         P_SOURCE_ADDRESS1            => P_SOURCE_ADDRESS1,
                         P_SOURCE_ADDRESS2            => P_SOURCE_ADDRESS2,
                         P_SOURCE_ADDRESS3            => P_SOURCE_ADDRESS3,
                         P_SOURCE_CITY                => P_SOURCE_CITY,
                         P_SOURCE_POSTAL_CODE         => P_SOURCE_POSTAL_CODE,
                         P_SOURCE_COUNTRY             => P_SOURCE_COUNTRY,
                         P_SOURCE_MGR_ID              => P_SOURCE_MGR_ID,
                         P_SOURCE_MGR_NAME            => P_SOURCE_MGR_NAME,
                         P_SOURCE_BUSINESS_GRP_ID     => P_SOURCE_BUSINESS_GRP_ID,
                         P_SOURCE_BUSINESS_GRP_NAME   => P_SOURCE_BUSINESS_GRP_NAME,
                         P_SOURCE_FIRST_NAME          => P_SOURCE_FIRST_NAME,
                         P_SOURCE_LAST_NAME           => P_SOURCE_LAST_NAME,
                         P_SOURCE_MIDDLE_NAME         => P_SOURCE_MIDDLE_NAME );

               IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
                   log_message('Error in CRM Public API');
                   pa_debug.g_err_stage := 'Log: Error in CRM Public API';
                   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                      pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                   END IF;

                   x_return_status := FND_API.G_RET_STS_ERROR;
                   CLOSE c_per_active;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

               pa_debug.g_err_stage := 'Log: After call to CRM Public API. CRM_RESOURCE_ID := ' || to_char(l_crm_resource_id);
               IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                  pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
               END IF;
               log_message('Out of CRM Public API');

            END IF;   /* end if for c_per_active%NOTFOUND */
            CLOSE c_per_active;

        END IF; /* end if for creating a crm resource id for this person */


        --Get the correct resource_type_code based on category
        pa_debug.g_err_stage := 'Log: Fetch the resource_type_code based on category';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('Fetch the resource_type_code based on category');

        IF p_category = 'EMPLOYEE' THEN
            l_resource_type_code := 'RS_EMPLOYEE';
        ELSIF p_category = 'PARTY' THEN
            l_resource_type_code := 'RS_PARTY';
        ELSIF p_category = 'PARTNER' THEN
            l_resource_type_code := 'RS_PARTNER';
        END IF;


        ------------------------------------------------------------------
        -- Now check whether the resource has a calendar assigned
        -- for this assignment start and end dates
        -- This check is performed on an existing or a new crm resource.
        -- Insert calendar appropriately if calendar assignment does not
        -- exist yet.
        ------------------------------------------------------------------


        -- Changing the start date login for Bug 1697261
        -- l_assignment_start_date := sysdate;

        --------------------------------------------------------------------------
        -- First, get the appropriate earliest start date for the calendar record
        --------------------------------------------------------------------------
        BEGIN
             SELECT max(DATE_START)
             INTO l_latest_start_date
             FROM
        (select person_id, date_start from per_periods_of_service
         union all
         select person_id, date_start from per_periods_of_placement) po
             WHERE po.person_id = l_person_id
         AND trunc(po.date_start) <= trunc(p_assignment_start_date); -- Added for bug 4465862;
        EXCEPTION
             WHEN OTHERS THEN
                  l_latest_start_date := null;
        END;

        BEGIN
             -- l_earliest_utl_start_date := to_date(fnd_profile.value('PA_UTL_START_DATE'), 'DD/MM/YYYY');  /* commenting for For Bug 7304151 */
             l_earliest_utl_start_date := to_date(fnd_profile.value('PA_UTL_START_DATE'), 'DD/MM/YYYY', 'NLS_DATE_LANGUAGE=AMERICAN');  /*Adding For Bug 7304151 */
        EXCEPTION
             WHEN OTHERS THEN
                  l_earliest_utl_start_date := null;
        END;

        log_message('PA_UTL_START_DATE value: ' || l_earliest_utl_start_date);

        BEGIN
             SELECT start_date_active
             INTO   l_calander_start_date
             FROM   JTF_CALENDARS_B -- change to base table - bug 4350758
             WHERE  calendar_id = l_calendar_id;
        EXCEPTION
             WHEN OTHERS THEN
                  l_calander_start_date := null;
        END;


        l_assignment_start_date := Max_Date(l_latest_start_date,
                                            l_earliest_utl_start_date,
                                            l_calander_start_date);

        log_message('l_start_date from max_date = ' || l_assignment_start_date);
        log_message('p_start_date from parameter = ' || p_assignment_start_date);

        if (trunc(p_assignment_start_date) >  trunc(l_assignment_start_date)) then
           log_message('Not the first HR assignment for the resource');
           l_assignment_start_date :=  p_assignment_start_date;
        end if;

        l_assignment_end_date :=  p_assignment_end_date;


        ---------------------------------------------------
        --Second, check if calendar exists for the resource
        --of the assignment start date
        ---------------------------------------------------
-- hr_utility.trace('l_assignment_end_date : ' || l_assignment_end_date);
-- hr_utility.trace('l_assignment_start_date : ' || l_assignment_start_date);
        open cur_crm_cal(l_crm_resource_id);
        fetch cur_crm_cal into l_cal_exist;
        close cur_crm_cal;

-- hr_utility.trace('22222 crm');
-- hr_utility.trace('l_cal_exist : ' || l_cal_exist);

        -- Assign a calendar only for resource which has crm resource id
        -- To take care of future resources (no crm resource id yet)
        IF (l_cal_exist is null and l_crm_resource_id is not null) THEN

              ------------------------------------------------------------------------
              -- Calendar does not exist as of the assignment start date
              -- This cursor checks if there is an already existing calendar assigned
              -- to this resource, with a different start date but within the
              -- assignment dates. Get this start date.
              ------------------------------------------------------------------------
              open cur_crm_check_date;
              fetch cur_crm_check_date into l_min_start_date;
              close cur_crm_check_date;

              if(l_min_start_date IS NULL) then

                  -----------------------------------------------------------------------------
                  -- When the value of l_min_start_date is NULL, this means that no calendar
                  -- exist for this resource during the assignment time period.
                  -- Will need to do insert into jtf_cal_resource_assign.
                  -- This resource is a new crm resource.
                  -----------------------------------------------------------------------------
                  log_message('L_CAL_EXIST is null: ' || to_char(l_crm_resource_id));
                  log_message('Set insert = Y');
                  l_insert := 'Y';


              else
                  -----------------------------------------------------------------------
                  -- Calendar exists for this resource but with a different start date.
                  -- The earliest start date is less than l_min_start_date value.
                  -- Will need to insert another row of calendar assignment for this
                  -- resource from earliest start date to l_min_start_date - 1
                  -----------------------------------------------------------------------

                  log_message('Start Date is earlier for : ' || to_char(l_crm_resource_id));
                  log_message('Old start date : ' || to_char(l_min_start_date, 'DD-MON-RR'));
                  log_message('New start date : ' || to_char(l_assignment_start_date, 'DD-MON-RR'));
                  log_message('Set insert = Y');
                  l_insert := 'Y';

                  -- Set assignment end date to the old_start_date - 1
                  l_assignment_end_date := l_min_start_date - 1;

              end if;

        END IF; /* end of cal is null check */


        -- Begin Bug 4668272
        open cur_crm_cal_end(l_crm_resource_id);
        fetch cur_crm_cal_end into l_cal_exist_end;
        close cur_crm_cal_end;

-- hr_utility.trace('22222 crm');
-- hr_utility.trace('l_cal_exist : ' || l_cal_exist_end);

        -- Assign a calendar only for resource which has crm resource id
        -- To take care of future resources (no crm resource id yet)
        IF (l_cal_exist_end is null and l_crm_resource_id is not null) THEN

              ----------------------------------------------------------------
              -- Calendar does not exist as of the assignment end date
              -- This cursor checks if there is an already existing calendar
              -- assigned
              -- to this resource, with a different end date but within the
              -- assignment dates. Get this end date.
              ----------------------------------------------------------------
              open cur_crm_chk_end_date;
              fetch cur_crm_chk_end_date into l_max_end_date;
              close cur_crm_chk_end_date;

-- hr_utility.trace('l_max_end_date IS : ' || l_max_end_date);
              -- Bug 4668272
              l_end_date_insert := 'N';
              IF l_max_end_date IS NULL THEN
                 -- No calendar record exists for this person, so insert
                 -- a new one.
                 l_end_date_insert := 'Y';
              ELSIF (l_max_end_date between l_assignment_start_date AND
                                            l_assignment_end_date) AND
                    trunc(l_max_end_date) <> trunc(l_assignment_end_date) THEN
-- hr_utility.trace('bug fixed case');
-- hr_utility.trace('l_max_end_date IS : ' || l_max_end_date);
-- hr_utility.trace('l_assignment_end_date IS : ' || l_assignment_end_date);

                 -- This is the case where the new end date is after the
                 -- existing end date - eg new: Dec 31 old: Dec 15.
                 -- Insert new record from Dec 16 to Dec 31.
                 -- Set assignment start date to the old end date + 1
                 l_assignment_start_date := l_max_end_date + 1;
                 l_end_date_insert := 'Y';

-- hr_utility.trace('l_assignment_start_date IS : ' || l_assignment_start_date);
              ELSE
                 -- New end date is earlier than old one. Eg:
                 -- New: Dec 15, Old: Dec 31
                 -- Calendar already exists for this time so do nothing.
                 l_end_date_insert := 'N';

              END IF;

        END IF; /* end of cal end is null check */
        -- End Bug 4668272

        ---------------------------------------------------
        --Assign the l_crm_resource_id to the out parameter
        ---------------------------------------------------
        x_crm_resource_id := l_crm_resource_id;

        ---------------------------------------------------------
        --Insert calendar details into jtf_cal_resource_assign
        --For a totally new crm resource or to insert a partial
        --period if start date changes to an earlier start date
        --for an existing resource
        ---------------------------------------------------------
        -- IF (l_insert = 'Y') THEN
        -- Bug 4668272
-- hr_utility.trace('l_end_date_insert IS : ' || l_end_date_insert);
        IF (l_insert = 'Y') OR (l_end_date_insert = 'Y') THEN

                log_message('Begin of insert into jtf_cal_resource_assign');
                log_message('l_assignment_start ' ||  to_char(l_assignment_start_date, 'DD-MON-RR'));
                log_message('l_assignment_end ' || to_char(l_assignment_end_date, 'DD-MON-RR'));

                --Unique cal_resource_assign_id from sequence
                LOOP
                        select jtf_cal_resource_assign_s.nextval
                        into l_cal_resource_assign_id
                        from dual;
                        OPEN c_dup_resource_assign_id(l_cal_resource_assign_id);
                        FETCH c_dup_resource_assign_id INTO l_check_dup_id;
                        EXIT WHEN c_dup_resource_assign_id%NOTFOUND;
                        CLOSE c_dup_resource_assign_id;
                END LOOP;
                CLOSE c_dup_resource_assign_id;

                pa_debug.g_err_stage := 'Log: Selected unique cal_resource_assign_id';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                log_message('Selected unique cal_resource_assign_id');

                pa_debug.g_err_stage := 'Log: User CRM API to Insert calendar into jtf_cal_resource_assign from '|| to_char(l_assignment_start_date,'DD-MON-RR')||' to '|| to_char(l_assignment_end_date,'DD-MON-RR');
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                log_message('Insert calendar into jtf_cal_resource_assign');

                --Added code to use CRM Table Handler API instead of direct insert

                IF( l_assignment_start_date > P_ASSIGNMENT_END_DATE ) THEN   -- Bug 6411422: IF condition added
                   l_populate_jtf_res_cal  := 'N';
                END IF ;
                IF( l_populate_jtf_res_cal = 'Y' ) THEN                      -- Bug 6411422: IF condition added

                jtf_cal_resource_assign_pkg.insert_row(
                          X_ERROR                  => l_error,
                          X_ROWID                  => l_rowid,
                          X_CAL_RESOURCE_ASSIGN_ID => l_cal_resource_assign_id,
                          X_OBJECT_VERSION_NUMBER  => 1,
                          X_ATTRIBUTE5             => null,
                          X_ATTRIBUTE6             => null,
                          X_ATTRIBUTE7             => null,
                          X_ATTRIBUTE8             => null,
                          X_ATTRIBUTE9             => null,
                          X_ATTRIBUTE10            => null,
                          X_ATTRIBUTE11            => null,
                          X_ATTRIBUTE12            => null,
                          X_ATTRIBUTE13            => null,
                          X_ATTRIBUTE14            => null,
                          X_ATTRIBUTE15            => null,
                          X_ATTRIBUTE_CATEGORY     => null,
                          X_START_DATE_TIME        => l_assignment_start_date,
                          X_END_DATE_TIME          => l_assignment_end_date,
                          X_CALENDAR_ID            => l_calendar_id,
                          X_RESOURCE_ID            => l_crm_resource_id,
                          X_RESOURCE_TYPE_CODE     => l_resource_type_code,
                          X_PRIMARY_CALENDAR_FLAG  => 'Y',
                          X_ATTRIBUTE1             => null,
                          X_ATTRIBUTE2             => null,
                          X_ATTRIBUTE3             => null,
                          X_ATTRIBUTE4             => null,
                          X_CREATION_DATE          => sysdate,
                          X_CREATED_BY             => G_user_id,
                          X_LAST_UPDATE_DATE       => sysdate,
                          X_LAST_UPDATED_BY        => G_user_id,
                          X_LAST_UPDATE_LOGIN      => G_login_id
                 );

                /* The jtf table handler returns N or Y based on
                   if the function call was a success or failure */
                IF NOT (l_error = 'N') THEN
                   log_message('Error in CRM Table Handler API for INSERT_ROW');
                   pa_debug.g_err_stage := 'Log: Error in CRM Table Handler API for INSERT_ROW';
                   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                      pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                   END IF;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;


                OPEN c_jtf_cal(l_cal_resource_assign_id);
                FETCH c_jtf_cal into l_rowid;
                IF (c_jtf_cal%NOTFOUND) THEN
                        log_message('c_jtf_cal not found');
                        CLOSE c_jtf_cal;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        RAISE fnd_api.g_exc_error;
                END IF;
                CLOSE c_jtf_cal;


                --------------------------
                --check calendar validity
                --------------------------
                log_message('Checking calendar validity');
                pa_schedule_utils.check_calendar(
                    P_JTF_RESOURCE_ID => l_crm_resource_id,
                    P_START_DATE      => l_assignment_start_date,
                    P_END_DATE        => l_assignment_end_date,
                    X_RETURN_STATUS   => x_return_status,
                    X_MSG_COUNT       => l_msg_count,
                    X_MSG_DATA        => l_msg_data );

                log_message('return status for calendar validity: ' || x_return_status);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     pa_debug.g_err_stage := 'Log: Calendar is not valid';
                     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                        pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                     END IF;
                     x_return_status := FND_API.G_RET_STS_ERROR;
                     RAISE FND_API.G_EXC_ERROR;
                END IF;

                pa_debug.g_err_stage := 'Log: After insert into jtf_cal_resource_assign';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;

                log_message('End of insert into jtf_cal_resource_assign');

        END IF;
      END IF;  -- Bug 6411422

        pa_debug.g_err_stage := 'Log: End of Insert_into_CRM procedure';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('End of insert_into_crm procedure');

        PA_DEBUG.Reset_Err_Stack;

 EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    X_CRM_RESOURCE_ID := NULL ; -- 4537865 RESET OUT PARAM
   WHEN OTHERS THEN
        X_CRM_RESOURCE_ID := NULL ; -- 4537865 RESET OUT PARAM
     -- Set the exception Message and the stack
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_R_PROJECT_RESOURCES_PVT.Insert_into_CRM'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     RAISE;
 END INSERT_INTO_CRM;

/*Procedure : PA Insert
This procedure inserts records into pa_resources and
pa_resource_txn_attributes table. This procedure calls the table
handler package PA_RESOURCE_PKG.INSERT_ROW1 and PA_RESOURCE_PKG.INSERT_ROW2 . */

 PROCEDURE INSERT_INTO_PA(
        P_RESOURCE_TYPE_ID        IN        PA_RESOURCE_TYPES.RESOURCE_TYPE_ID%TYPE,
        P_CRM_RESOURCE_ID         IN        PA_RESOURCES.JTF_RESOURCE_ID%TYPE,
        X_RESOURCE_ID             OUT       NOCOPY PA_RESOURCES.RESOURCE_ID%TYPE, --File.Sql.39 bug 4440895
        P_START_DATE              IN        PA_RESOURCES.START_DATE_ACTIVE%TYPE,
        P_END_DATE                IN        PA_RESOURCES.END_DATE_ACTIVE%TYPE DEFAULT NULL,
        P_PERSON_ID               IN        PA_RESOURCE_TXN_ATTRIBUTES.PERSON_ID%TYPE DEFAULT NULL,
        P_NAME                    IN        PA_RESOURCES.NAME%TYPE,
        P_PARTY_ID                IN        PA_RESOURCE_TXN_ATTRIBUTES.PARTY_ID%TYPE DEFAULT NULL,
        X_RETURN_STATUS           OUT       NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
        l_resource_txn_attribute_id         PA_RESOURCE_TXN_ATTRIBUTES.RESOURCE_TXN_ATTRIBUTE_ID%TYPE;
        l_check_dup_id                      VARCHAR2(1);
        l_rowid                             ROWID;
        l_check_char                        VARCHAR2(1);

     -- added for bug 3921534
        l_unit_of_measure                   pa_resources.unit_of_measure%type;
        l_rollup_quantity_flag              pa_resources.rollup_quantity_flag%type;
        l_track_as_labor_flag               pa_resources.track_as_labor_flag%type;

        CURSOR c_dup_resource_id(l_resource_id IN pa_resources.resource_id%type)
        IS
                SELECT 'X'
                FROM pa_resources
                WHERE resource_id = l_resource_id;

        CURSOR c_dup_txn_attribute_id(l_resource_txn_attribute_id IN
                                        pa_resource_txn_attributes.
                                        resource_txn_attribute_id%type)
        IS
                SELECT 'X'
                FROM pa_resource_txn_attributes
                WHERE resource_txn_attribute_id = l_resource_txn_attribute_id;

        CURSOR c_pa_resources( l_rowid   IN  ROWID ) IS
                 SELECT 'Y'
                 FROM pa_resources
                 WHERE ROWID = l_rowid;

        CURSOR c_pa_resource_txn_attributes( l_rowid   IN  ROWID ) IS
                 SELECT 'Y'
                 FROM pa_resource_txn_attributes
                 WHERE ROWID = l_rowid;

 BEGIN
        PA_DEBUG.set_err_stack('Insert_into_PA');
        pa_debug.g_err_stage := 'Log: Start of Insert_into_PA procedure';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;

        X_RETURN_STATUS := fnd_api.g_ret_sts_success;

        --Fetch unique resource_id from sequence.
        LOOP
                Select pa_resources_s.nextval
                into x_resource_id
                from dual;

                OPEN c_dup_resource_id(x_resource_id);
                FETCH c_dup_resource_id INTO l_check_dup_id;
                EXIT WHEN c_dup_resource_id%NOTFOUND;
                CLOSE c_dup_resource_id;
        END LOOP;
        CLOSE c_dup_resource_id;

        --Fetch unique resource_txn_attribute_id from sequence.
        LOOP
                select pa_resource_txn_attributes_s.nextval
                into l_resource_txn_attribute_id
                from dual;

                OPEN c_dup_txn_attribute_id(l_resource_txn_attribute_id);
                FETCH c_dup_txn_attribute_id INTO l_check_dup_id;
                EXIT WHEN c_dup_txn_attribute_id%NOTFOUND;
                CLOSE c_dup_txn_attribute_id;
        END LOOP;
        CLOSE c_dup_txn_attribute_id;

        -- added for bug 3921534
        l_unit_of_measure      := null;
        l_rollup_quantity_flag := null;
        l_track_as_labor_flag  := null;
     if p_resource_type_id = 101 then
       -- Commented the following code for Perf fix 4902403
       -- SQL ID 14906035

       --    select unit_of_measure
       --       ,rollup_quantity_flag
       --   ,track_as_labor_flag
       --       into l_unit_of_measure
       --   ,l_rollup_quantity_flag
       --   ,l_track_as_labor_flag
       --   from pa_employees_res_v
       --  where rownum = 1;

       -- Included ths code for Perf fix 4902403
		l_unit_of_measure := 'HOURS';
		l_rollup_quantity_flag := 'N';
		l_track_as_labor_flag := 'Y';
         end if;

        --Insert into pa_resources table
        pa_debug.g_err_stage := 'Log: Calling Insert_row1 to insert into PA_RESOURCES table';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('Calling insert_row1 procedure to do the actual inserts into PA_RESOURCES table');

        PA_RESOURCE_PKG.INSERT_ROW1 (
                X_ROWID                        => l_rowid,
                X_RESOURCE_ID                  => x_resource_id,
                X_NAME                         => p_name,
                X_RESOURCE_TYPE_ID             => p_resource_type_id,
                X_JTF_RESOURCE_ID              => p_crm_resource_id,
                X_START_DATE_ACTIVE            => p_start_date,
                X_END_DATE_ACTIVE              => p_end_date,
                X_UNIT_OF_MEASURE              => l_unit_of_measure,           -- added for bug 3921534
                X_ROLLUP_QUANTITY_FLAG         => l_rollup_quantity_flag,      -- added for bug 3921534
                X_TRACK_AS_LABOR_FLAG          => l_track_as_labor_flag,       -- added for bug 3921534
                X_REQUEST_ID                   => G_request_id,
                X_PROGRAM_ID                   => G_program_id,
                X_PROGRAM_UPDATE_DATE          => SYSDATE,
                X_PROGRAM_APPLICATION_ID       => G_application_id,
                X_LAST_UPDATE_BY               => G_user_id,
                X_LAST_UPDATE_DATE             => SYSDATE,
                X_CREATION_DATE                => SYSDATE,
                X_CREATED_BY                   => G_user_id,
                X_LAST_UPDATE_LOGIN            => G_login_id,
                X_RETURN_STATUS                => x_return_status);

        pa_debug.g_err_stage := 'Log: After Insert_row1 procedure';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('After Insert Row 1 Procedure');

        pa_debug.g_err_stage := 'Log: Calling Insert_row2 to insert into PA_RESOURCE_TXN_ATTRIBUTES table';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('Call insert_row2 procedure to do the actual inserts into PA_RESOURCE_TXN_ATTRIBUTES table');

        --Insert into pa_resource_txn_attributes.
        PA_RESOURCE_PKG.INSERT_ROW2 (
                X_ROWID                            => l_rowid,
                X_RESOURCE_TXN_ATTRIBUTE_ID        => l_resource_txn_attribute_id,
                X_RESOURCE_ID                      => x_resource_id,
                X_PERSON_ID                        => p_person_id,
                X_PARTY_ID                         => p_party_id,
                X_RESOURCE_FORMAT_ID               => 5,
                X_REQUEST_ID                       => G_request_id,
                X_PROGRAM_ID                       => G_program_id,
                X_PROGRAM_UPDATE_DATE              => SYSDATE,
                X_PROGRAM_APPLICATION_ID           => G_application_id,
                X_LAST_UPDATE_BY                   => G_user_id,
                X_LAST_UPDATE_DATE                 => SYSDATE,
                X_CREATION_DATE                    => SYSDATE,
                X_CREATED_BY                       => G_user_id,
                X_LAST_UPDATE_LOGIN                => G_login_id,
                X_RETURN_STATUS                    => x_return_status ) ;

        pa_debug.g_err_stage := 'Log: After Insert_row2 procedure';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('End of insert_row2 procedure');

        pa_debug.g_err_stage := 'Log: End of Insert_into_PA procedure';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('End of insert_into_pa procedure');

        PA_DEBUG.Reset_Err_Stack;
  EXCEPTION
        WHEN OTHERS THEN
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_R_PROJECT_RESOURCES_PVT.Insert_into_PA'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    -- 4537865
     x_resource_id := NULL ;
          RAISE;

 END INSERT_INTO_PA;

/*Procedure : Check_OU
This procedure check if the default OU implements projects or not.
Also if the default OU is NULL for a resource
 then gives an expected error. */

PROCEDURE CHECK_OU(
        P_DEFAULT_OU            IN      PA_RESOURCES_DENORM.RESOURCE_ORG_ID%TYPE,
        P_EXP_ORG               IN      VARCHAR2,
        X_EXP_OU                OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        X_RETURN_STATUS         OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
 IS
        l_valid                         VARCHAR2(1);
        l_code                          VARCHAR2(100);

 BEGIN
        PA_DEBUG.set_err_stack('Check_OU');

        pa_debug.g_err_stage := 'Log: Start of Check_OU procedure';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('Start of check_ou procedure');

        X_RETURN_STATUS := fnd_api.g_ret_sts_success;

        IF (p_default_OU IS NOT NULL) THEN
                --Check if OU is Expenditure OU
                log_message('Calling Check_Exp_OU');
                pa_hr_update_api.check_exp_OU(
                        p_org_id              => p_default_ou
                        ,x_return_status      => l_valid
                        ,x_error_message_code => l_code);
                log_message('After Check_Exp_OU');

                IF (l_valid = fnd_api.g_ret_sts_success) THEN
                        --If OU is Exp OU
                   x_exp_ou :=  'Y';
                   x_return_status := fnd_api.g_ret_sts_success;
                ELSE
                   --If OU is not Exp OU
                   --The code below is commented because for singlr org
                   --implementations the default OU need not be
                   --expenditure OU
                   x_exp_ou := 'N';
                END IF; --IF l_valid
        ELSE
                IF (p_exp_org = 'YES') THEN
                   --If OU is null and resource belongs to Exp Hier
                   --The code below is commented because for singlr org
                   --implementations the default OU need not be
                   --expenditure OU
                   x_exp_ou := 'N';

                END IF;
        END IF;

        pa_debug.g_err_stage := 'Log: End of Check_OU procedure';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('End of check_ou procedure');

        PA_DEBUG.Reset_Err_Stack;
  EXCEPTION
        WHEN OTHERS THEN
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_R_PROJECT_RESOURCES_PVT.Check_OU'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- 4537865
     x_exp_ou := NULL ;
          raise;

 END CHECK_OU;


/*Procedure : Create Internal Resource
This procedure is the main procedure called by the create_resource
procedure for internal resources. First the procedure checks to see if
the resource exists in PA, if it does not then it calls the CRM
procedure to perform CRM checks, calls the Insert_into_Pa and
Insert_into_Orgs procedures to insert resource into PA. Depending on
the number of primary active assignments the Insert_into_Orgs
procedure is called that many times.

If the resource does exist in PA, the procedure checks to see if CRM
calendar has been changed and respectively process the CRM
details. */

 PROCEDURE CREATE_INTERNAL_RESOURCE(
        P_PERSON_ID                 IN PA_RESOURCE_TXN_ATTRIBUTES.PERSON_ID%TYPE,
        P_NAME                      IN PA_RESOURCES.NAME%TYPE,
        P_ORGANIZATION_ID           IN PER_ALL_ASSIGNMENTS_F.ORGANIZATION_ID%TYPE,
        P_ASSIGNMENT_START_DATE     IN DATE,
        P_ASSIGNMENT_END_DATE       IN DATE,
        P_START_DATE                IN DATE,
        P_DEFAULT_OU                IN NUMBER,
        P_CALENDAR_ID               IN NUMBER,
        P_SYSTEM_TYPE               IN PER_PERSON_TYPES.SYSTEM_PERSON_TYPE%TYPE,
        P_USER_TYPE                 IN PER_PERSON_TYPES.USER_PERSON_TYPE%TYPE,
        P_RES_EXISTS                IN VARCHAR2,
        P_COUNT                     IN NUMBER,
        P_RESOURCE_TYPE             IN JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
        X_RESOURCE_ID               OUT NOCOPY PA_RESOURCES.RESOURCE_ID%TYPE, --File.Sql.39 bug 4440895
        X_RETURN_STATUS             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
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
        P_SOURCE_MIDDLE_NAME        IN pa_r_project_resources_ind_v.per_middle_name%TYPE)
 IS
        l_resource_type_code        PA_RESOURCE_TYPES.RESOURCE_TYPE_CODE%TYPE := 'EMPLOYEE';
        l_resource_type_id          PA_RESOURCE_TYPES.RESOURCE_TYPE_ID%TYPE;

        l_res_id        pa_resource_txn_attributes.resource_id%type;
        l_org_id        NUMBER;
        l_start         DATE;
        l_end           DATE;

        l_check         VARCHAR2(1) := 'N';
        l_jtf_id        NUMBER      := null;
        l_cal_id        NUMBER      := TO_NUMBER(P_CALENDAR_ID);

        x_crm_resource_id      JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
        x_error_message_code   varchar2(1000);

        l_valid                VARCHAR2(1);
        l_code                 VARCHAR2(100);

        CURSOR c_jtf_id_exist(l_res_id IN NUMBER)
        IS
                SELECT jtf_resource_id
                FROM pa_resources
                WHERE resource_id = l_res_id;

 BEGIN
        PA_DEBUG.set_err_stack('Create_Internal_Resource');

        pa_debug.g_err_stage := 'Log: Start of Create_Internal_Resource procedure';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('Inside create_internal_resource procedure');

        X_RETURN_STATUS := fnd_api.g_ret_sts_success;

        --Check to see if resource exists in PA
        IF (p_res_exists = 'NOT EXISTS') THEN

                pa_debug.g_err_stage := 'Log: Resource does not exist in PA';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                log_message('Resource does not exist');

                pa_debug.g_err_stage := 'Log: Calling Insert_into_CRM procedure to check if resource exists in CRM';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                log_message('Call insert_into_crm procedure to check if resource exists in CRM');

                --pa_debug.g_err_stage := 'Log: P_COUNT = ' || to_char(p_count);
                --pa_debug.write_file('LOG',pa_debug.g_err_stage);
                --Call Insert_into_crm procedure
                insert_into_crm(
                        P_CATEGORY                   => p_resource_type,
                        P_PERSON_ID                  => p_person_id,
                        P_NAME                       => p_name,
                        P_START_DATE                 => p_start_date,
                        P_ASSIGNMENT_START_DATE      => p_assignment_start_date,
                        P_ASSIGNMENT_END_DATE        => p_assignment_end_date,
                        P_CALENDAR_ID                => l_cal_id,
                        P_COUNT                      => p_count,
                        X_CRM_RESOURCE_ID            => x_crm_resource_id,
                        X_RETURN_STATUS              => x_return_status,
                        P_START_DATE_ACTIVE          => P_START_DATE_ACTIVE,
                        P_END_DATE_ACTIVE            => P_END_DATE_ACTIVE,
                        P_SOURCE_NUMBER              => P_SOURCE_NUMBER,
                        P_SOURCE_JOB_TITLE           => P_SOURCE_JOB_TITLE,
                        P_SOURCE_EMAIL               => P_SOURCE_EMAIL,
                        P_SOURCE_PHONE               => P_SOURCE_PHONE,
                        P_SOURCE_ADDRESS1            => P_SOURCE_ADDRESS1,
                        P_SOURCE_ADDRESS2            => P_SOURCE_ADDRESS2,
                        P_SOURCE_ADDRESS3            => P_SOURCE_ADDRESS3,
                        P_SOURCE_CITY                => P_SOURCE_CITY,
                        P_SOURCE_POSTAL_CODE         => P_SOURCE_POSTAL_CODE,
                        P_SOURCE_COUNTRY             => P_SOURCE_COUNTRY,
                        P_SOURCE_MGR_ID              => P_SOURCE_MGR_ID,
                        P_SOURCE_MGR_NAME            => P_SOURCE_MGR_NAME,
                        P_SOURCE_BUSINESS_GRP_ID     => P_SOURCE_BUSINESS_GRP_ID,
                        P_SOURCE_BUSINESS_GRP_NAME   => P_SOURCE_BUSINESS_GRP_NAME,
                        P_SOURCE_FIRST_NAME          => P_SOURCE_FIRST_NAME,
                        P_SOURCE_LAST_NAME           => P_SOURCE_LAST_NAME,
                        P_SOURCE_MIDDLE_NAME         => P_SOURCE_MIDDLE_NAME);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

                pa_debug.g_err_stage := 'Log: After Insert_into_CRM procedure ';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                log_message('Out of insert_into_crm procedure');
                log_message('x_crm_resource_id = ' || x_crm_resource_id);
                log_message('p_person_id = ' || p_person_id);

                /*--Get the resource_type_code inorder to get the resource_type_id
                pa_debug.g_err_stage := 'Log: Get the resource_type_code based on the user_type';
                pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                log_message('Get the resource_type_code based on the user_type');

                IF p_user_type = 'Employee' THEN
                        l_resource_type_code := 'EMPLOYEE';
                ELSIF p_user_type = 'Contractor' THEN
                        l_resource_type_code := 'CONTRACTOR';
                END IF;*/

                --fetch the resource_type_id
                pa_debug.g_err_stage := 'Log: Get the resource_type_id based on the resource_type_code';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                log_message('Get the resource_type_id from the resource_type_code');

                select resource_type_id into l_resource_type_id
                from pa_resource_types
                where resource_type_code = l_resource_type_code ;

                pa_debug.g_err_stage := 'Log: After getting the resource_type_id based on the resource_type_code';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;

                --This check is to check the number of assignments the resource has
                if (p_person_id <> G_p_id) then
                        pa_debug.g_err_stage := 'Log: Calling Insert_into_PA procedure';
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                        END IF;
                        log_message('Calling insert_into_pa');

                        INSERT_INTO_PA(
                                P_RESOURCE_TYPE_ID       => l_resource_type_id,
                                P_CRM_RESOURCE_ID        => x_crm_resource_id,
                                X_RESOURCE_ID            => x_resource_id,
                                P_START_DATE             => p_start_date,
                                P_PERSON_ID              => p_person_id,
                                P_NAME                   => p_name,
                                X_RETURN_STATUS          => x_return_status );

                        pa_debug.g_err_stage := 'Log: After Insert_into_PA procedure';
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                        END IF;
                        log_message('Out of insert_into_pa');

                        G_p_id := p_person_id;
                        --Assign the current person_id to the G_p_id so that
                        --in the next run the insert_into_pa will not be
                        --called.

                end if;

                --Below fixed for Bug 1555424
                select resource_id into l_res_id
                from pa_resource_txn_attributes
                where person_id = p_person_id
                and rownum = 1;                      -- added for bug 3086960.

                x_resource_id := l_res_id;

        ELSE
                --If resource exists in PA
                pa_debug.g_err_stage := 'Log: Resource exists in PA';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                log_message('For already existing resource: Resource is already in PA');

                --Check to see if CRM calendar is end dated.
                --Call insert_into_crm

                pa_debug.g_err_stage := 'Log: Calling Insert_into_CRM procedure to check if resource exists in CRM';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                log_message('Call insert_into_crm procedure to check if resource exists in CRM');

                insert_into_crm(
                                P_CATEGORY                   => p_resource_type,
                                P_PERSON_ID                  => p_person_id,
                                P_NAME                       => p_name,
                                P_START_DATE                 => p_start_date,
                                P_ASSIGNMENT_START_DATE      => p_assignment_start_date,
                                P_ASSIGNMENT_END_DATE        => p_assignment_end_date,
                                P_CALENDAR_ID                => l_cal_id,
                                P_COUNT                      => 1,
                                X_CRM_RESOURCE_ID            => x_crm_resource_id,
                                X_RETURN_STATUS              => x_return_status,
                                P_START_DATE_ACTIVE          => P_START_DATE_ACTIVE,
                                P_END_DATE_ACTIVE            => P_END_DATE_ACTIVE,
                                P_SOURCE_NUMBER              => P_SOURCE_NUMBER,
                                P_SOURCE_JOB_TITLE           => P_SOURCE_JOB_TITLE,
                                P_SOURCE_EMAIL               => P_SOURCE_EMAIL,
                                P_SOURCE_PHONE               => P_SOURCE_PHONE,
                                P_SOURCE_ADDRESS1            => P_SOURCE_ADDRESS1,
                                P_SOURCE_ADDRESS2            => P_SOURCE_ADDRESS2,
                                P_SOURCE_ADDRESS3            => P_SOURCE_ADDRESS3,
                                P_SOURCE_CITY                => P_SOURCE_CITY,
                                P_SOURCE_POSTAL_CODE         => P_SOURCE_POSTAL_CODE,
                                P_SOURCE_COUNTRY             => P_SOURCE_COUNTRY,
                                P_SOURCE_MGR_ID              => P_SOURCE_MGR_ID,
                                P_SOURCE_MGR_NAME            => P_SOURCE_MGR_NAME,
                                P_SOURCE_BUSINESS_GRP_ID     => P_SOURCE_BUSINESS_GRP_ID,
                                P_SOURCE_BUSINESS_GRP_NAME   => P_SOURCE_BUSINESS_GRP_NAME,
                                P_SOURCE_FIRST_NAME          => P_SOURCE_FIRST_NAME,
                                P_SOURCE_LAST_NAME           => P_SOURCE_LAST_NAME,
                                P_SOURCE_MIDDLE_NAME         => P_SOURCE_MIDDLE_NAME);
                log_message('After CRM '|| x_return_status);
                pa_debug.g_err_stage := 'Log: After Insert_into_CRM procedure';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                log_message(' Out of insert_into_crm procedure');
                log_message('x_crm_resource_id = ' || x_crm_resource_id);
                log_message('p_person_id = ' || p_person_id);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

                pa_debug.g_err_stage := 'Log: Get resource_id for person_id';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                log_message('Get resource_id for person_id');

                --Get resource_id from PA for the resource
                select resource_id into l_res_id
                from pa_resource_txn_attributes
                where person_id = p_person_id and rownum=1;

                x_resource_id := l_res_id ;

            -- Begin Bug 3086960. Added by Sachin.
               DECLARE
                 l_exists   VARCHAR2(1);
               BEGIN
                        -- Changed to where exists for bug 4350758
                        -- no need for rownum when exists is used.
                        SELECT 'X'
                          INTO l_exists
                          FROM dual
                          WHERE EXISTS (SELECT 'Y'
                                          FROM pa_resource_txn_attributes
                                         WHERE resource_id = x_resource_id
                                           AND person_id <> p_person_id);
                                           -- AND ROWNUM = 1);

                        ----------------------------------------------------
                        -- if for the same resource_id, another record
                        -- with a different person_id exists in the table
                        -- pa_resource_txn_attributes than raise exception
                        -- and do nothing
                        -- person not pulled because of above reason
                        ----------------------------------------------------
                        IF SQL%FOUND THEN
                           RAISE fnd_api.g_exc_error;
                        END IF;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    NULL;
                END;
             -- End Bug 3086960

                --To update jtf_resource_id for already existing
                --resource in Projects
                OPEN c_jtf_id_exist(l_res_id);
                FETCH c_jtf_id_exist INTO l_jtf_id;
                CLOSE c_jtf_id_exist;

                IF (l_jtf_id is null) or (l_jtf_id <> x_crm_resource_id) THEN
                  pa_debug.g_err_stage := 'Log: PA_RESOURCES.JTF_RESOURCE_ID does not exist or not equal to the CRM resource_id';
                  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                     pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                  END IF;

                  update pa_resources
                  set jtf_resource_id = x_crm_resource_id,
                      request_id = G_request_id,
                      program_id = G_program_id,
                      program_update_date = sysdate,
                      program_application_id = G_application_id,
                      last_update_date = sysdate,
                      last_updated_by = G_user_id,
                      last_update_login = G_login_id
                  where resource_id = l_res_id;

                  pa_debug.g_err_stage := 'Log: Calling Insert_into_CRM procedure';
                  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                     pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                  END IF;
                  insert_into_crm(
                                P_CATEGORY                 => p_resource_type,
                                P_PERSON_ID                => p_person_id,
                                P_NAME                     => p_name,
                                P_START_DATE               => p_start_date,
                                P_ASSIGNMENT_START_DATE    => p_assignment_start_date,
                                P_ASSIGNMENT_END_DATE      => p_assignment_end_date,
                                P_CALENDAR_ID              => l_cal_id,
                                P_COUNT                    => 1,
                                X_CRM_RESOURCE_ID          => x_crm_resource_id,
                                X_RETURN_STATUS            => x_return_status,
                                P_START_DATE_ACTIVE        => P_START_DATE_ACTIVE,
                                P_END_DATE_ACTIVE          => P_END_DATE_ACTIVE,
                                P_SOURCE_NUMBER            => P_SOURCE_NUMBER,
                                P_SOURCE_JOB_TITLE         => P_SOURCE_JOB_TITLE,
                                P_SOURCE_EMAIL             => P_SOURCE_EMAIL,
                                P_SOURCE_PHONE             => P_SOURCE_PHONE,
                                P_SOURCE_ADDRESS1          => P_SOURCE_ADDRESS1,
                                P_SOURCE_ADDRESS2          => P_SOURCE_ADDRESS2,
                                P_SOURCE_ADDRESS3          => P_SOURCE_ADDRESS3,
                                P_SOURCE_CITY              => P_SOURCE_CITY,
                                P_SOURCE_POSTAL_CODE       => P_SOURCE_POSTAL_CODE,
                                P_SOURCE_COUNTRY           => P_SOURCE_COUNTRY,
                                P_SOURCE_MGR_ID            => P_SOURCE_MGR_ID,
                                P_SOURCE_MGR_NAME          => P_SOURCE_MGR_NAME,
                                P_SOURCE_BUSINESS_GRP_ID   => P_SOURCE_BUSINESS_GRP_ID,
                                P_SOURCE_BUSINESS_GRP_NAME => P_SOURCE_BUSINESS_GRP_NAME,
                                P_SOURCE_FIRST_NAME        => P_SOURCE_FIRST_NAME,
                                P_SOURCE_LAST_NAME         => P_SOURCE_LAST_NAME,
                                P_SOURCE_MIDDLE_NAME       => P_SOURCE_MIDDLE_NAME);

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  pa_debug.g_err_stage := 'Log: After Insert_into_CRM procedure';
                  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                     pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                  END IF;
                  log_message(' Out of insert_into_crm procedure');
                  log_message('x_crm_resource_id = ' || x_crm_resource_id);
                  log_message('p_person_id = ' || p_person_id);
                  log_message('After CRM '|| x_return_status);
                END IF;
        END IF;
        pa_debug.g_err_stage := 'Log: End of Create_Internal_Resource procedure';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('End of create_internal_resource procedure');

        PA_DEBUG.Reset_Err_Stack;
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
          -- 4537865
        x_resource_id := NULL ;
        WHEN OTHERS THEN
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_R_PROJECT_RESOURCES_PVT.Create_Internal_Resource'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  -- 4537865
                x_resource_id := NULL ;

          RAISE;
 END CREATE_INTERNAL_RESOURCE;


/*Procedure : Create External Resource
This procedure is the main procedure called by the create_resource
procedure for external resources. First the procedure checks to see if
the resource exists in PA, if it does not then it calls the insert_into_pa
to insert the resource into pa_resources and pa_resource_txn_attributes
If the resource does exist in PA, the procedure just returns the resource_id
of the external resource */

 PROCEDURE CREATE_EXTERNAL_RESOURCE(
        P_PARTY_ID                  IN  PA_RESOURCE_TXN_ATTRIBUTES.PARTY_ID%TYPE,
        P_RESOURCE_TYPE             IN  PA_RESOURCE_TYPES.RESOURCE_TYPE_CODE%TYPE,
        X_RESOURCE_ID               OUT NOCOPY PA_RESOURCES.RESOURCE_ID%TYPE, --File.Sql.39 bug 4440895
        X_RETURN_STATUS             OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
        l_resource_type_id          PA_RESOURCE_TYPES.RESOURCE_TYPE_ID%TYPE;
        l_valid                     VARCHAR2(1) := 'N';
        l_res_exists                VARCHAR2(20);
        l_party_id                  PA_RESOURCE_TXN_ATTRIBUTES.PARTY_ID%TYPE := P_PARTY_ID;
        l_res_id                    PA_RESOURCES.RESOURCE_ID%TYPE;
        l_name                      PA_RESOURCES.NAME%TYPE;
        l_start_date                DATE;
        l_end_date                  DATE;
        l_return_status             VARCHAR2(1);

 BEGIN
        PA_DEBUG.set_err_stack('Create_External_Resource');

        pa_debug.g_err_stage := 'Log: Start of Create_External_Resource procedure';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('Inside create_external_resource procedure');

        X_RETURN_STATUS := fnd_api.g_ret_sts_success;

        --to get the resource type id for code HZ_PARTY
        select resource_type_id into l_resource_type_id
        from pa_resource_types
        where resource_type_code = p_resource_type;

        --Call check_res_exists procedure
        pa_resource_utils.check_res_exists(
              P_PARTY_ID      => l_party_id,
              X_VALID         => l_valid,
              X_RETURN_STATUS => l_return_status);

        IF (l_valid = 'Y') THEN
              l_res_exists := 'EXISTS';
              log_message('** external resource already exists in PA **');
        ELSE
              l_res_exists := 'NOT EXISTS';
              log_message('** external resource does not exist in PA **');
        END IF;

        --insert into PA only if the record does not exists yet in the PA tables
        --CRM resource Id will be null for external resource

        IF l_res_exists = 'NOT EXISTS' THEN

             -- get party_name, start date, end date
             /* bug2498092 - need to truncate the party name from hz_parties
                because HZ_PARTIES.party_name is VARCHAR2(360) while
                pa_resources.name is only VARCHAR2(100) */
        /*Bug 3612182:Modified the substr to substrb*/
             select substrb(party_name,1,100), start_date, end_date
             into l_name, l_start_date, l_end_date
             from pa_party_resource_details_v
             where party_id = l_party_id;

             pa_debug.g_err_stage := 'Log: Before Insert_into_PA procedure for external people';
             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
             END IF;
             --call insert into PA

             INSERT_INTO_PA(
                 P_RESOURCE_TYPE_ID    => l_resource_type_id,
                 P_CRM_RESOURCE_ID     => null,
                 X_RESOURCE_ID         => x_resource_id,
                 P_START_DATE          => l_start_date,
                 P_END_DATE            => l_end_date,
                 P_PARTY_ID            => l_party_id,
                 P_NAME                => l_name,
                 X_RETURN_STATUS       => x_return_status );

             pa_debug.g_err_stage := 'Log: After Insert_into_PA procedure for external people';
             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
             END IF;
             log_message('** done with insert into PA for external people **');

        ELSE
             pa_debug.g_err_stage := 'Log: External resource already in PA - retrieve resource_id';
             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
             END IF;

             log_message('** external resource already in PA - retrieve resource_id **');
             --Get resource_id from PA for the resource
             select resource_id into l_res_id
             from pa_resource_txn_attributes
             where party_id = l_party_id;

             x_resource_id := l_res_id ;

        END IF;


        pa_debug.g_err_stage := 'Log: End of Create_External_Resource procedure';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('End of create_external_resource procedure');

        PA_DEBUG.Reset_Err_Stack;
 EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
         -- 4537865
          x_resource_id := NULL ;
        WHEN OTHERS THEN
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_R_PROJECT_RESOURCES_PVT.Create_External_Resource'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                 -- 4537865
              x_resource_id := NULL ;
          RAISE;
 END CREATE_EXTERNAL_RESOURCE;


/*Procedure : Create Resource
This is the private procedure that will be called by the public API
which in turn calls the above procedures.*/

 PROCEDURE CREATE_RESOURCE (
        P_COMMIT                IN  VARCHAR2,
        P_VALIDATE_ONLY         IN  VARCHAR2,
        P_INTERNAL              IN  VARCHAR2,
        P_PERSON_ID             IN  PA_RESOURCE_TXN_ATTRIBUTES.PERSON_ID%TYPE,
        P_INDIVIDUAL            IN  VARCHAR2,
        P_CHECK_RESOURCE        IN  VARCHAR2,
        P_SCHEDULED_MEMBER_FLAG IN  VARCHAR2,
        P_RESOURCE_TYPE         IN  JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE,
        P_PARTY_ID              IN  PA_RESOURCE_TXN_ATTRIBUTES.PARTY_ID%TYPE,
        P_FROM_EMP_NUM          IN  VARCHAR2,
        P_TO_EMP_NUM            IN  VARCHAR2,
        P_ORGANIZATION_ID       IN  NUMBER,
        P_REFRESH               IN  VARCHAR2,
        P_PULL_TERM_RES     IN  VARCHAR2 DEFAULT 'N',
        P_TERM_RANGE_DATE       IN  DATE     DEFAULT NULL,
        P_PERSON_TYPE           IN  VARCHAR2 DEFAULT 'ALL',
        P_START_DATE            IN  DATE     DEFAULT NULL, -- Bug 5337454
	-- Added parameters for PJR Resource Pull Enhancements - Bug 5130414
	P_SELECTION_OPTION	IN  VARCHAR2 DEFAULT NULL,
	P_ORG_STR_VERSION_ID	IN  NUMBER   DEFAULT NULL,
	P_START_ORGANIZATION_ID	IN  NUMBER   DEFAULT NULL,
	-- End of parameters added for PJR Resource Pull Enhancements - Bug 5130414
        X_RETURN_STATUS         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        X_RESOURCE_ID           OUT NOCOPY PA_RESOURCES.RESOURCE_ID%TYPE) --File.Sql.39 bug 4440895

 IS
        L_API_VERSION            CONSTANT NUMBER        := 1.0;
        L_API_NAME               CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE';
        -- If no date specified, default to previous year.
        l_term_range_date DATE := trunc(nvl(p_term_range_date, ADD_MONTHS(trunc(sysdate), -12)));

        l_resource_type          JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE := P_RESOURCE_TYPE;

        x_resource_number        NUMBER;

        l_name                   PA_RESOURCES.NAME%TYPE;
        l_organization_id        PER_ALL_ASSIGNMENTS_F.ORGANIZATION_ID%TYPE;
        l_assignment_start_date  DATE;
        l_assignment_end_date    DATE;
        l_start_date             DATE;
        l_default_OU             NUMBER;
        l_calendar_id            NUMBER;
        l_system_type            PER_PERSON_TYPES.SYSTEM_PERSON_TYPE%TYPE;
        l_user_type              PER_PERSON_TYPES.USER_PERSON_TYPE%TYPE;
        l_res_exists             VARCHAR2(20);
        l_exists                 VARCHAR2(1) := 'N';
        l_exp_org                VARCHAR2(10);
        l_job_utilization        VARCHAR2(1) := 'N';
        l_job_schedulable        VARCHAR2(1) := 'N';
        l_job_id                 NUMBER;
        l_id                     NUMBER       := P_PERSON_ID;

        l_internal               VARCHAR2(1)  := P_INTERNAL;
        l_person_id              NUMBER       := P_PERSON_ID;
        l_individual             VARCHAR2(1)  := P_INDIVIDUAL ;
        l_party_id               NUMBER       := P_PARTY_ID;
        i                        NUMBER := 0;

        ---- new variables for parameterized resource pull
        l_from_emp_num           VARCHAR2(30) := P_FROM_EMP_NUM;
        l_to_emp_num             VARCHAR2(30) := P_TO_EMP_NUM;
        l_p_org_id               NUMBER       := P_ORGANIZATION_ID;
        l_refresh                VARCHAR2(5)  := P_REFRESH;
        l_denorm_yes             VARCHAR2(1)  := 'N';
	-- new variables for enhanced parameterization in resource pull - Bug 5130414
	l_selection_option       VARCHAR(20)  := P_SELECTION_OPTION;
	l_org_str_version_id     NUMBER       := P_ORG_STR_VERSION_ID;
	l_start_organization_id  NUMBER       := P_START_ORGANIZATION_ID;
        ----

        x_msg_count              NUMBER;
        x_msg_data               VARCHAR2(1000);
        l_counter                NUMBER;
        l_msg_index_out          NUMBER;
        l_max_count              NUMBER := 1;
        x_error_message_code     VARCHAR2(1000);
        x_exp_ou                 VARCHAR2(1);
        l_res_found              VARCHAR2(1) := 'N';
        l_valid                  VARCHAR2(1) := 'N';
        l_return_status          VARCHAR2(1000);
        l_supervisor_name        PER_ALL_PEOPLE_F.FULL_NAME%TYPE;
        l_address1               HR_LOCATIONS.ADDRESS_LINE_1%TYPE;
        l_address2               HR_LOCATIONS.ADDRESS_LINE_2%TYPE;
        l_address3               HR_LOCATIONS.ADDRESS_LINE_3%TYPE;
        l_city                   HR_LOCATIONS.TOWN_OR_CITY%TYPE;
        l_postal_code            HR_LOCATIONS.POSTAL_CODE%TYPE;
        l_country                HR_LOCATIONS.COUNTRY%TYPE;
        l_end_date               DATE;
        G_person_id              NUMBER := 0;
        l_resource_type_id       PA_RESOURCE_TYPES.RESOURCE_TYPE_ID%TYPE;
  --    l_org_type               VARCHAR2(20);  --Bug 4363092
        l_crm_resource_id        JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
        l_res_id                 PA_RESOURCES.RESOURCE_ID%TYPE;
        l_per_success            VARCHAR2(1);
        l_asgmt_success          VARCHAR2(1) := 'N';

        -- variables for fix in message stack in individual pull
        l_msg_stack_num_old      NUMBER      := 0;
        l_msg_stack_num_new      NUMBER      := 0;
        l_at_least_one_success   VARCHAR2(1) := 'N';

        l_populate_denorm_flag   VARCHAR2(1) := 'Y';  -- Bug 6411422
        l_per_start_date         DATE;                -- Bug 6411422
        l_prof_date              DATE;                -- Bug 6411422

       -- Bug 3086960. Added dynamic SQL. Sachin
       sql_cursor              NUMBER;
       l_rows                  NUMBER;
       l_sel_clause            VARCHAR2(2000);
       l_from_clause           VARCHAR2(2000);
       l_where_clause          VARCHAR2(2000);
       l_stmt                  VARCHAR2(20000);

       l_invol_term            VARCHAR2(1); --bug 5683340

       /*Added 2 new params for bug 4087022*/
       l_excep                 VARCHAR2(1) := 'N' ;
       l_resource_id           PA_RESOURCES.RESOURCE_ID%TYPE;

        PERSON_ERROR_EXCEPTION   EXCEPTION;
        TERM_DATE_EXCEPTION      EXCEPTION;

        CURSOR CUR_CRMID(l_person_id in jtf_rs_resource_extns.source_id%type,
                        l_resource_type in jtf_rs_resource_extns.category%type)
        IS
                select resource_id
                from jtf_rs_resource_extns
                where source_id = l_person_id
                and category = l_resource_type;

--MOAC Changes : Bug 4363092: Commenting this cursor as now As R12 will have multi org setup only
     /*
        CURSOR check_org_type IS
            select decode(substr(USERENV('CLIENT_INFO'),1,1),
                          ' ', NULL,
                          substr(USERENV('CLIENT_INFO'),1,10)) org from dual;        */

/* Commenting starts for Bug 6263517 */
/* Modifying existing cursor to get max terminated date (from both past terminated
   or future terminated date values )
        CURSOR get_max_end_date_term(p_person_id IN NUMBER) IS
           select max(assignment_end_date)
           from   pa_r_project_resources_term_v res
           where  res.person_id                     = p_person_id; */
/* Commenting ends for Bug 6263517 */

/* Modified cursor starts for Bug 6263517 */
        CURSOR get_max_end_date_term(p_person_id IN NUMBER) IS
        SELECT MAX (asgn_end_date) FROM
          (select max(res.assignment_end_date) asgn_end_date
           from   pa_r_project_resources_v res
           where  res.person_id                     = p_person_id
           and res.assignment_end_date IS NOT NULL
           UNION
           select max(res.assignment_end_date) ass_end_date
           from   pa_r_project_resources_term_v res
           where  res.person_id                     = p_person_id
           and res.assignment_end_date IS NOT NULL ) ;
/* Modified cursor ends for Bug 6263517 */

--MOAC Changes bug 4363092 - removed nvl used with org_id
        CURSOR get_max_asgmt_end_date IS
           select max(assignment_end_date)
           from pa_r_project_resources_ind_v res
              , hr_organization_information org_info
              , pa_all_organizations org
           where   res.person_id                     = l_person_id
             and   res.organization_id               = org_info.organization_id
             and   org_info.org_information_context  = 'Exp Organization Defaults'
             and   res.organization_id               = org.organization_id
             and   org.pa_org_use_type               = 'EXPENDITURES'
             and   org.inactive_date is null
             and   (org.organization_id,org.org_id)  = (
                            select org1.organization_id, org1.org_id
                            from pa_all_organizations org1
                            where org1.pa_org_use_type = 'EXPENDITURES'
                            and org1.inactive_date is null
                            and org1.organization_id = org.organization_id
                            and rownum               = 1 );

        CURSOR check_res_denorm IS
           select 'Y'
           from pa_resources_denorm
           where person_id = l_person_id
             and rownum=1;

        /*Cursor added for Bug 6943551*/
        CURSOR cur_denorm_del(p_person_id IN NUMBER ) IS
         SELECT prd.person_id,
                prd.resource_effective_start_date,
                prd.resource_effective_end_date
         FROM   pa_resources_denorm prd,
                per_all_assignments_f paf,
                per_assignment_status_types past
         WHERE  prd.person_id = paf.person_id
         AND prd.person_id = p_person_id
         AND paf.assignment_status_type_id = past.assignment_status_type_id
         AND paf.primary_flag = 'Y'
         AND paf.assignment_type in ('E','C')
         AND prd.resource_effective_start_date = paf.effective_start_date
         AND past.per_system_status in ('SUSP_ASSIGN','SUSP_CWK_ASG')
         ORDER BY prd.resource_effective_start_date ;

         /*Cursors added for Bug 7336526*/
         CURSOR cur_denorm_del_redundant(p_person_id IN NUMBER, l_prof_date IN DATE) IS
         SELECT prd.person_id,
                prd.resource_effective_start_date,
                prd.resource_effective_end_date
         FROM   pa_resources_denorm prd
         WHERE  prd.resource_effective_end_date < sysdate
           AND  prd.resource_effective_end_date < l_prof_date
           AND  prd.resource_effective_end_date is not null
           AND  prd.person_id = p_person_id
           ORDER BY prd.resource_effective_start_date ;

         CURSOR cur_denorm_del_term(l_prof_date IN DATE) IS
         SELECT prd.person_id,
                prd.assignment_start_date,
                prd.assignment_end_date,
                prd.organization_id
         FROM   pa_r_project_resources_term_v prd
         WHERE  per_end_date < sysdate
           AND  assignment_end_date < sysdate
           AND  per_end_date < l_prof_date
           AND  per_end_date is not null
           AND  organization_id = l_p_org_id
           ORDER BY per_start_date ;


 BEGIN

        IF p_commit = fnd_api.g_true THEN
                SAVEPOINT res_pvt_create_resource;
        END IF;

        PA_DEBUG.set_err_stack('Create_Resource');

        G_p_id        := 0;
        G_p_crmwf_id := 0;

        if ((G_user_id = '-1') or (G_login_id is null)) then
                G_user_id := '1014';
                G_login_id := '-1';
        end if;

        X_RETURN_STATUS := fnd_api.g_ret_sts_success;

        --If internal resource
        IF (l_internal = 'Y' )        THEN
          pa_debug.g_err_stage := 'Log: For Internal Resources';
          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
          END IF;
          log_message('For Internal Resources');

          ------------------------------------------------------------
          -- This is the individual case condition
          -- It goes through a loop using pa_r_project_resources_ind_v
          ------------------------------------------------------------
          IF (l_individual = 'Y') THEN
            pa_debug.g_err_stage := 'Log: For a single Resource';
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
            END IF;
            log_message('For Ind. Resource');

            l_msg_stack_num_old  := FND_MSG_PUB.Count_Msg;
            log_message('Old Number of Stack messages = ' || to_char(l_msg_stack_num_old));

            FOR eRec IN cur_ind_person(l_id) LOOP

               BEGIN

                -- do savepoint for every assignment
                -- if error occurs, it will rollback the assignment
                IF p_commit = fnd_api.g_true THEN
                    SAVEPOINT res_pvt_create_resource;
                END IF;
                log_message('do SAVEPOINT for person:' || eRec.person_id ||  ' and assignment: ' || eRec.assignment_start_date);

                l_res_found := 'Y';
                log_message('=========================');

                --Getting the latest name of person - bug 3273964
		pa_debug.g_err_stage       := 'OLD PERSON_NAME ==> ' || eRec.NAME;
		IF P_DEBUG_MODE = 'Y' THEN
			pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
		END IF;

		eRec.NAME  := pa_resource_utils.get_person_name_no_date(P_PERSON_ID => eRec.person_id);
		pa_debug.g_err_stage       := 'NEW PERSON_NAME ==> ' || eRec.NAME;
		                IF P_DEBUG_MODE = 'Y' THEN
                        pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;

		log_message('PERSON_NAME ==> '|| eRec.NAME);
		-- End Bug 3273964
                --For selecting cursor columns into local variables.
                l_person_id                := eRec.person_id;
                l_name                     := eRec.name;
                l_organization_id          := eRec.organization_id;
                l_assignment_start_date    := eRec.assignment_start_date;
                l_assignment_end_date      := eRec.assignment_end_date;
                l_start_date               := eRec.start_date;
                l_system_type              := eRec.p_type;
                l_user_type                := eRec.user_type;


                ------------------------------------------------------------------------
                -- For Non-Scheduled Member, we will only insert into PA_RESOURCES and
                -- PA_RESOURCE_TXN_ATTRIBUTES. No need for calendar assignment, timeline
                -- generation and we also do not populate the pa_resources_denorm table
                ------------------------------------------------------------------------

                IF (p_scheduled_member_flag = 'N') THEN

                    log_message('**** p_scheduled_member_flag = N *****');
                    --to get the resource type id for code EMPLOYEE: now only handles this resource type
                    select resource_type_id into l_resource_type_id
                    from pa_resource_types
                    where resource_type_code = 'EMPLOYEE';

                    open cur_crmid(l_person_id,l_resource_type);
                    fetch cur_crmid into l_crm_resource_id;

                    IF cur_crmid%NOTFOUND THEN
                        l_crm_resource_id := null;
                    END IF;
                    close cur_crmid;

                    --Call check_res_exists procedure
                    pa_resource_utils.check_res_exists(
                          P_PERSON_ID     => l_person_id,
                          X_VALID         => l_valid,
                          X_RETURN_STATUS => l_return_status);

                    IF (l_valid = 'Y') THEN
                        l_res_exists := 'EXISTS';
                        log_message('** resource already exists in PA **');
                    ELSE
                        l_res_exists := 'NOT EXISTS';
                        log_message('** resource does not exist in PA **');
                    END IF;

                    --insert into PA only if the record does not exists yet in the PA tables
                    IF l_res_exists = 'NOT EXISTS' THEN
                        pa_debug.g_err_stage := 'Log: Before Insert_into_PA procedure for non-scheduled';
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                        END IF;
                        --call insert into PA
                        INSERT_INTO_PA(
                            P_RESOURCE_TYPE_ID    => l_resource_type_id,
                            P_CRM_RESOURCE_ID     => l_crm_resource_id,
                            X_RESOURCE_ID         => x_resource_id,
                            P_START_DATE          => l_start_date,
                            P_PERSON_ID           => l_person_id,
                            P_NAME                => l_name,
                            X_RETURN_STATUS       => x_return_status );

                        pa_debug.g_err_stage := 'Log: After Insert_into_PA procedure for non-scheduled';
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                        END IF;
                        log_message('** insert into PA for non-scheduled member **');

                    ELSE
                        pa_debug.g_err_stage := 'Log: Resource already in PA - retrieve resource_id';
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                        END IF;

                        log_message('** resource already in PA - retrieve resource_id **');
                        --Get resource_id from PA for the resource
                        select resource_id into l_res_id
                        from pa_resource_txn_attributes
                        where person_id = l_person_id
                        and rownum = 1;                      -- added for bug 3086960.

                        x_resource_id := l_res_id ;

                    END IF;

                    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;

                    RETURN; --Exit out of resource API

                ----------------------------------------------------------------
                -- This is the case it is for a scheduled role
                ----------------------------------------------------------------
                ELSIF (p_scheduled_member_flag = 'Y') THEN

                     --Call get_person_name procedure
                     --to get supervisor name
                     pa_resource_utils.get_person_name(
                         P_PERSON_ID     => eRec.supervisor_id,
                         X_PERSON_NAME   => l_supervisor_name,
                         X_RETURN_STATUS => l_return_status);

                     -- the organization of a scheduled member needs to belong to exp. hierarchy
                     -- this condition calls the function and checks if this is true

                     log_message('**** p_scheduled_member_flag = Y *****');
                     pa_resource_utils.Check_Exp_Org (
                           P_ORGANIZATION_ID   => l_organization_id,
                           X_VALID             => l_valid,
                           X_RETURN_STATUS     => l_return_status);

                     IF (l_valid = 'Y') THEN
                         l_exp_org := 'YES';
                     ELSE
                         l_exp_org := 'NO';
                     END IF;

                     If l_exp_org = 'NO' Then
                         pa_debug.g_err_stage := 'Log: Scheduled member does not belong to an Exp Hierarhy Org';
                         IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                            pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                         END IF;
                         log_message('Scheduled member does not belong to an Exp Hierarhy Org');

                         PA_UTILS.Add_Message(
                               p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_NO_EXP_HIER');

                         x_return_status := FND_API.G_RET_STS_ERROR;
                         RAISE FND_API.G_EXC_ERROR;
                     End If;

                     -----------------------------------------------------
                     --  Check if Job Utilizable_flag=N, if so, error out
                     -----------------------------------------------------
                     -- Bug 5337454 Added IF
                     IF ((p_start_date is null)OR(p_start_date is not null and p_start_date >=eRec.assignment_start_date and p_start_date <=eRec.assignment_end_date)) THEN
                     l_job_utilization := pa_hr_update_api.check_job_utilization
                                          (p_job_id     => eRec.job_id
                                          ,p_person_id  => null
                                          ,p_date       => null);

                     IF l_job_utilization='N' OR l_job_utilization IS NULL THEN
                        PA_UTILS.Add_Message(p_app_short_name => 'PA'
                                             ,p_msg_name      => 'PA_NOT_SCHEDULABLE_JOB');
                                          -- bug 3146989: error msg in Add Team Member page
                                          -- Changed the msg since the utilizable_job doesn't
                                          -- really make sense for the Add Team Member page.
                                          -- ,p_msg_name      => 'PA_NON_UTILIZABLE_JOB');

                        x_return_status := FND_API.G_RET_STS_ERROR;
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;
                     END IF;
                END IF;

                ----------------------------------------------------------------
                -- The condition below only allows those scheduled members that
                -- belong to expenditure organizations and his job is utilizable
                ----------------------------------------------------------------

                IF (l_exp_org = 'YES' AND l_job_utilization='Y') THEN
                        log_message('** Resource belongs to an expenditure org **');
                        --Call get_org_defaults procedure to get default
                        --operating unit and default calendar for the organization
                        pa_resource_utils.get_org_defaults (
                            P_ORGANIZATION_ID   => l_organization_id,
                            X_DEFAULT_OU        => l_default_ou,
                            X_DEFAULT_CAL_ID    => l_calendar_id,
                            X_RETURN_STATUS     => l_return_status);

                        --Call get_location_details procedure
                        pa_resource_utils.get_location_details (
                            P_LOCATION_ID    => eRec.location_id,
                            X_ADDRESS_LINE_1 => l_address1,
                            x_address_line_2 => l_address2,
                            x_address_line_3 => l_address3,
                            x_town_or_city   => l_city,
                            x_postal_code    => l_postal_code,
                            x_country        => l_country,
                            x_return_status  => l_return_status);

                        --This logic checks for resource in PA
                        --only once for all its assignments
                        IF(G_person_id <> l_person_id) THEN
                            G_person_id := l_person_id;

                            -- do timeline savepoint ONCE for the resource
                            -- if timeline error occurs, it will rollback for every assignments
                            -- of this resource and raise an error
                            IF p_commit = fnd_api.g_true THEN
                               SAVEPOINT timeline_save;
                            END IF;

                            --Call check_res_exists procedure
                            pa_resource_utils.check_res_exists(
                                P_PERSON_ID     => l_person_id,
                                X_VALID         => l_valid,
                                X_RETURN_STATUS => l_return_status);

                            IF (l_valid = 'Y') THEN
                                l_res_exists := 'EXISTS';
                            ELSE
                                l_res_exists := 'NOT EXISTS';
                            END IF;

                        END IF;


                        log_message('Calling Create Internal Resource');
                        --Call create_internal_resource procedure
                        CREATE_INTERNAL_RESOURCE(
                                P_PERSON_ID                  => l_person_id,
                                P_NAME                       => l_name,
                                P_ORGANIZATION_ID            => l_organization_id,
                                P_ASSIGNMENT_START_DATE      => l_assignment_start_date,
                                P_ASSIGNMENT_END_DATE        => l_assignment_end_date,
                                P_START_DATE                 => l_start_date,
                                P_DEFAULT_OU                 => l_default_OU,
                                P_CALENDAR_ID                => l_calendar_id,
                                P_SYSTEM_TYPE                => l_system_type,
                                P_USER_TYPE                  => l_user_type,
                                P_RES_EXISTS                 => l_res_exists,
                                P_COUNT                      => 1,--This value is not being used and is defaulted to 1
                                P_RESOURCE_TYPE              => l_resource_type,
                                X_RESOURCE_ID                => x_resource_id,
                                X_RETURN_STATUS              => x_return_status,
                                P_START_DATE_ACTIVE          => eRec.per_start_date,
                                P_END_DATE_ACTIVE            => eRec.per_end_date,
                                P_SOURCE_NUMBER              => eRec.per_emp_number,
                                P_SOURCE_JOB_TITLE           => eRec.job_name,
                                P_SOURCE_EMAIL               => eRec.per_email,
                                P_SOURCE_PHONE               => eRec.per_work_phone,
                                P_SOURCE_ADDRESS1            => l_address1,
                                P_SOURCE_ADDRESS2            => l_address2,
                                P_SOURCE_ADDRESS3            => l_address3,
                                P_SOURCE_CITY                => l_city ,
                                P_SOURCE_POSTAL_CODE         => l_postal_code,
                                P_SOURCE_COUNTRY             => l_country,
                                P_SOURCE_MGR_ID              => eRec.supervisor_id,
                                P_SOURCE_MGR_NAME            => l_supervisor_name,
                                P_SOURCE_BUSINESS_GRP_ID     => eRec.per_business_group_id,
                                P_SOURCE_BUSINESS_GRP_NAME   => eRec.org_name,
                                P_SOURCE_FIRST_NAME          => eRec.per_first_name,
                                P_SOURCE_LAST_NAME           => eRec.per_last_name,
                                P_SOURCE_MIDDLE_NAME         => eRec.per_middle_name);
                        log_message('After Create internal resource'|| x_return_status);

                        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                             x_return_status := FND_API.G_RET_STS_ERROR;
                             RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        -------------------------------------------------------------------------------
                        --Adding call to check if OU implements Projects only if the org is a multi-org
                        -------------------------------------------------------------------------------

                        log_message('Calling check_ou');
--MOAC Changes : Bug 4363092: Commenting this cursor as now As R12 will have multi org setup only
/*                      OPEN check_org_type;
                        FETCH check_org_type into l_org_type;
                        CLOSE check_org_type;  */

                        -- case for Multi-Org
                      --  IF l_org_type IS NOT NULL THEN  -- Bug 4363092

                            CHECK_OU(
                               P_DEFAULT_OU       => l_default_OU,
                               P_EXP_ORG          => l_exp_org,
                               X_EXP_OU           => x_exp_ou,
                               X_RETURN_STATUS    => x_return_status);

                            IF(x_exp_ou = 'N') THEN
                                 pa_debug.g_err_stage := 'Log: Multi Org - OU does not implement Projects';
                                 IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                                    pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                                 END IF;
                                 PA_UTILS.Add_Message(
                                        p_app_short_name => 'PA'
                                       ,p_msg_name       => 'PA_OU_NO_PROJECTS');
                                 x_return_status := FND_API.G_RET_STS_ERROR;

                                 RAISE FND_API.G_EXC_ERROR;
                            END IF;

                        log_message('After check_ou '|| x_return_status);

                        -- case for Single-Org
/*                      ELSE   -- Bug 4383092
                             l_default_OU := NULL;
                        END IF; */


                        --------------------------------------------------------------------------
                        --      The calling procedure has passed p_check_resource = Y,
                        --      which means that if the resource already exists
                        --      in the database, just pass back the resource_id.
                        --      We do not want to create timeline data again for this resource.
                        --      Create PRM Assignment and Create Project APIs currently call this
                        --      API with p_check_resource = 'Y'. When a new resource is created
                        --      (through HR triggers), or when a new HR Assignment is created,
                        --      this flag value  will be 'N' since we want the timeline data
                        --      to be created. We are making this check in INDIVIDUAL='Y' mode
                        --      only, since in the ALL mode, we will generate timeline for every
                        --      resource.
                        ---------------------------------------------------------------------------

                        IF p_check_resource='Y' AND l_res_exists = 'EXISTS' and x_resource_id is not null
                        THEN

                        ---------------------------------------------------------------------
                        --    Added code to take care of the case that if resource is end
                        --    dated because its organization was removed from an expenditure
                        --    hierarchy then if the organization is added back to expenditure
                        --    hierarchy the resource continues to be end dated and has to be
                        --    pulled again
                        -----------------------------------------------------------------------
                              BEGIN
                                   select 'Y'
                                   into   l_exists
                                   from   pa_resources_denorm
                                   where  person_id  = l_person_id
                                   and    l_assignment_end_date BETWEEN resource_effective_start_date
                                          AND resource_effective_end_date;

                              EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                     l_exists := 'N';
                                WHEN OTHERS THEN
                                     l_exists := 'N';
                              END;
                           null;
                        END IF;

                        IF l_exists = 'N' THEN

                           -- Adding call to populate resource denormalized tables

                --------------------------------------------------------------------
                -- Bug Ref # 6411422
                -- Adding Profile Date Honoring Logic for Resource
                ---------------------------------------------------------------------
		-- l_prof_date := FND_PROFILE.value('PA_UTL_START_DATE') ; /* commenting for For Bug 7304151 */
                   l_prof_date := to_date(fnd_profile.value('PA_UTL_START_DATE'), 'DD/MM/YYYY', 'NLS_DATE_LANGUAGE=AMERICAN'); /*Adding For Bug 7304151 */
                IF( l_prof_date IS NOT NULL ) THEN
                  IF (  l_prof_date  >= l_assignment_start_date AND l_prof_date <= l_assignment_end_date  ) THEN
                     log_message(' Profile Date is Later than the Employee Start Date');
                     l_populate_denorm_flag := 'Y' ;
                     l_assignment_start_date  :=  l_prof_date;
                  ELSE
                     IF ( l_assignment_start_date >= l_prof_date ) THEN
                        l_populate_denorm_flag := 'Y' ;
                     ELSE
                        l_populate_denorm_flag := 'N' ;
                     END IF;
                  END IF;
                END IF;
                IF (  l_populate_denorm_flag = 'Y' ) THEN    -- Bug 6411422

                           pa_resource_pvt.populate_resources_denorm(
                                  p_resource_source_id          => l_person_id
                                , p_resource_id                 => x_resource_id
                                , p_resource_name               => l_name
                                , p_resource_type               => eRec.resource_type
                              , p_person_type                   => eRec.p_type
                                , p_resource_job_id             => eRec.job_id
                                , p_resource_job_group_id       => eRec.job_group_id
                                , p_resource_org_id             => l_default_OU
                                , p_resource_organization_id    => l_organization_id
                                , p_assignment_start_date       => l_assignment_start_date
                                , p_assignment_end_date         => l_assignment_end_date
                                , p_manager_id                  => eRec.supervisor_id
                                , p_manager_name                => l_supervisor_name
                                , p_request_id                  => G_request_id
                                , p_program_application_id      => G_application_id
                                , p_program_id                  => G_program_id
                                , p_commit                      => fnd_api.G_false
                                , p_validate_only               => fnd_api.G_false
                                , x_msg_data                    => x_msg_data
                                , x_msg_count                   => x_msg_count
                                , x_return_status               => x_return_status);

                           log_message('After resources denorm '|| x_return_status);
                END IF;  -- Bug 6411422
                        END IF;

                        -- if the code arrives at this logic, then at least one
                        -- HR assignment pull is a success
                        l_at_least_one_success := 'Y';

                END IF; /* End l_exp_org=YES check - for scheduled member only */

              EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                     IF p_commit = fnd_api.g_true THEN
                         ROLLBACK TO res_pvt_create_resource;
                     END IF;

                     log_message('ROLLBACK for this assignment');
                     -- exit of resource API for non-scheduled member with error
                     IF p_scheduled_member_flag = 'N' THEN
                         RETURN;
                     END IF;
              END;

            END LOOP;

            log_message('The value of l_res_found is ' || l_res_found);

            IF (l_res_found = 'N') THEN
                   validate_person(P_PERSON_ID);
                   RAISE FND_API.G_EXC_ERROR;

            -- for scheduled resource found in loop
            ELSIF (l_res_found = 'Y') THEN

               -- if all HR assignments fail, then just rollback and
               -- raise an expected error
               IF l_at_least_one_success = 'N' THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   log_message('All HR assignments failed - raise an expected error');

                   RAISE FND_API.G_EXC_ERROR;
               END IF;

               -- create timeline when check resource No OR
               -- check resource Yes and resource does not exist
               IF (p_check_resource='N' OR (p_check_resource='Y' AND l_res_exists='NOT EXISTS')) THEN


                 /*Call added for bug 5683340*/
	         log_message('before Calling pa_resource_utils.init_fte_sync_wf');
                 pa_resource_utils.init_fte_sync_wf( p_person_id => l_person_id,
                                                   x_invol_term => l_invol_term,
                                                   x_return_status => x_return_status,
                                                   x_msg_data => x_msg_data,
                                                   x_msg_count => x_msg_count);
                 log_message('After Calling pa_resource_utils.init_fte_sync_wf, x_return_status: '||x_return_status);  --bug 5683340

                 /*IF - ELSIF block  added for bug 5683340*/
                  IF ((l_invol_term = 'N') AND (x_return_status = FND_API.G_RET_STS_SUCCESS )) THEN

                     -- Call Create Timeline after all assignments are in
                     -- resource denorm table
                     log_message('Calling Create_Timeline procedure');

                     PA_TIMELINE_PVT.Create_Timeline (
                        p_start_resource_name    => NULL,
                        p_end_resource_name      => NULL,
                        p_resource_id            => x_resource_id,
                        p_start_date             => NULL,
                        p_end_date               => NULL,
                        x_return_status          => x_return_status,
                        x_msg_count              => x_msg_count,
                        x_msg_data               => x_msg_data);

                     log_message('After timeline call: '|| x_return_status);
                     log_message('Out of Create_Timeline procedure');

                     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                         x_return_status := FND_API.G_RET_STS_ERROR;

                         -- timeline error occurs
                         -- rollback for all assignments of this resource
                         -- also raise an error
                         IF p_commit = fnd_api.g_true THEN
                               ROLLBACK TO timeline_save;
                         END IF;

                         log_message('Timeline errors out - rollback all assignments for this resource');

                         RAISE FND_API.G_EXC_ERROR;
                     END IF;

                  ELSIF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN  -- for  bug 5683340
	            log_message(' Call to pa_resource_utils.init_fte_sync_wf errored in individual pull');
		  RAISE FND_API.G_EXC_ERROR;

		  END IF ; --IF ((l_invol_term = 'N') AND (x_return_status = FND_API.G_RET_STS_SUCCESS )) bug 5683340

               END IF;

               -- remove unwanted error message from the stack
               -- when at least one HR assignment pull is a success
               l_msg_stack_num_new  := FND_MSG_PUB.Count_Msg;
               log_message('New Number of Stack messages = ' || to_char(l_msg_stack_num_new));

               if (l_at_least_one_success = 'Y') then
                 if (l_msg_stack_num_new > l_msg_stack_num_old) then

                    FOR I IN (l_msg_stack_num_old+1)..l_msg_stack_num_new LOOP

                       log_message('Deleting message at index: ' || FND_MSG_PUB.Count_Msg);
                       FND_MSG_PUB.delete_msg(p_msg_index =>FND_MSG_PUB.Count_Msg);

                    END LOOP;

                 end if;

                 x_return_status := FND_API.G_RET_STS_SUCCESS;
                 log_message('Return success if at least one assignment is a success');
               end if;

            END IF;


          ------------------------------------------------------------
          -- This is the concurrent pull program
          -- It goes through a loop using pa_r_project_resources_v
          ------------------------------------------------------------
          ELSE /* Not an individual pull - Mass pull */

                -- Check that terminated resources pull date is within
                -- a year ago
-- hr_utility.trace_on(NULL, 'RMPULL');
                IF p_pull_term_res = 'Y' THEN
-- hr_utility.trace('get terminated');
-- hr_utility.trace('l_term_range_date is ' || l_term_range_date);
-- hr_utility.trace('l_term_range_date is ' || to_char(l_term_range_date, 'YYYY/MM/DD HH24:MI:SS'));
                  IF  (l_selection_option <> 'EMP_RANGE' AND l_selection_option <> 'SINGLE_ORG') THEN -- bug 7482852
                   if l_term_range_date < add_months(trunc(sysdate), -12) THEN
-- hr_utility.trace('TERM_DATE_EXCEPTION ');
              Raise TERM_DATE_EXCEPTION;
                   END IF;
                  END IF;
                END IF;

-- hr_utility.trace('after my changes');
                pa_debug.g_err_stage := 'Log: Start of Create_Resource';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                log_message('For a batch of people');

                --Inside the concurrent process
                pa_debug.g_err_stage := 'Log: Before looping through each person record';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                pa_debug.g_err_stage := '*******************************************************';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                log_message('*****************************************');
                log_message('Before looping through each person record');


           -- Begin Bug 3086960. Added by Sachin.

                sql_cursor := DBMS_SQL.OPEN_CURSOR;
/*  -- Commented for PJR Enhancement for resource pull - Bug 5130414
                -- Organization is not specified.
                IF l_p_org_id IS NULL THEN
                --  Employee range is specified
                   l_sel_clause   := ' SELECT DISTINCT p.person_id ';
                   l_from_clause  := ' FROM per_all_people_f p ';
		   -- changed l_where_clause for bug4954896
                   --l_where_clause := ' WHERE p.employee_number >= ''' || l_from_emp_num || ''''|| ' AND p.employee_number <= ''' || l_to_emp_num || '''';
                   l_where_clause := ' WHERE p.employee_number >=  :from_emp_num AND p.employee_number <= :to_emp_num ';
		ELSE
                -- Organization is specified
                   IF
                   -- Employee range is specified
                   (l_from_emp_num IS NOT NULL AND
                    l_to_emp_num IS NOT NULL ) THEN

                   l_sel_clause   := ' SELECT DISTINCT p.person_id ';
                   l_from_clause  := ' FROM per_all_people_f p, per_all_assignments_f a';
		    -- changed l_where_clause for bug4954896
                  -- l_where_clause := ' WHERE a.person_id = p.person_id '||
                  --                 ' AND a.organization_id = ' || l_p_org_id ||
                  --                   ' AND p.employee_number >= ''' || l_from_emp_num || ''''||
                  --                   ' AND p.employee_number <= ''' || l_to_emp_num || '''';
		  l_where_clause := ' WHERE a.person_id = p.person_id '||
				    ' AND a.organization_id = :org_id '||
				     ' AND p.employee_number >= :from_emp_num '||
				     ' AND p.employee_number <= :to_emp_num ';
                   ELSE
                   -- Employee range is not specified
                   l_sel_clause   := ' SELECT DISTINCT a.person_id ';
                   l_from_clause  := ' FROM  per_all_assignments_f a';
		   -- changed l_where_clause for Bug4954896
                   --l_where_clause := ' WHERE a.organization_id = ' || l_p_org_id ;
		   l_where_clause := ' WHERE a.organization_id = :org_id' ;
                   END IF;
                END IF;

                l_stmt := l_sel_clause || l_from_clause || l_where_clause;

-- hr_utility.trace('l_stmt is : ' || l_stmt);
                 DBMS_SQL.PARSE(sql_cursor, l_stmt, dbms_sql.v7);
-- Added for Bug4954896
-- Start of Bug 4954896
		IF l_p_org_id IS NULL THEN
		  DBMS_SQL.BIND_VARIABLE(sql_cursor,':from_emp_num',l_from_emp_num);
		  DBMS_SQL.BIND_VARIABLE(sql_cursor,':to_emp_num',l_to_emp_num);
       		ELSE
                -- Organization is specified
                   IF
                   -- Employee range is specified
                   (l_from_emp_num IS NOT NULL AND
                    l_to_emp_num IS NOT NULL ) THEN
		    DBMS_SQL.BIND_VARIABLE(sql_cursor,':org_id',l_p_org_id);
		    DBMS_SQL.BIND_VARIABLE(sql_cursor,':from_emp_num',l_from_emp_num);
		    DBMS_SQL.BIND_VARIABLE(sql_cursor,':to_emp_num',l_to_emp_num);
                   ELSE
		   DBMS_SQL.BIND_VARIABLE(sql_cursor,':org_id',l_p_org_id);
                   END IF;
                END IF;
 -- end of 4954896
 */
		-- Start - Bug 5130414 - PJR Resource Pull Enhancement
		IF l_selection_option = 'EMP_RANGE' THEN
			-- Employee range is specified
			l_sel_clause   := ' SELECT DISTINCT p.person_id ';
			--l_from_clause  := ' FROM per_all_people_f p ';                          /*Commented for Bug 7012687 */
			l_from_clause  := ' FROM per_all_people_f p , per_all_assignments_f a';   /*Added per_all_asgn_f for Bug 7012687 */
			l_where_clause := ' WHERE p.employee_number >=  :from_emp_num AND p.employee_number <= :to_emp_num '||
                                          ' AND p.person_id = a.person_id '||                    /*Added condition for Bug 7012687 */
                                          ' AND a.assignment_type in (''E'',''C'') '||           /*Added condition for Bug 7012687 */
                                          ' AND a.job_id is not null'||                          /*Added condition for Bug 7012687 */
                                          ' AND a.primary_flag = ''Y'' ';                        /*Added condition for Bug 7012687 */
		ELSIF l_selection_option = 'EMP_RANGE_ORG' THEN
			-- Employee range and organization is specified
			l_sel_clause   := ' SELECT DISTINCT p.person_id ';
			l_from_clause  := ' FROM per_all_people_f p, per_all_assignments_f a';
			l_where_clause := ' WHERE a.person_id = p.person_id '||
						' AND a.organization_id = :org_id '||
						' AND p.employee_number >= :from_emp_num '||
						' AND p.employee_number <= :to_emp_num '||
						' AND a.assignment_type in (''E'',''C'') '||     /*Added condition for Bug 7012687 */
						' AND a.job_id is not null'||                    /*Added condition for Bug 7012687 */
						' AND a.primary_flag = ''Y'' ';                  /*Added condition for Bug 7012687 */
		ELSIF l_selection_option = 'SINGLE_ORG' THEN
			-- Organization is specified
			l_sel_clause   := ' SELECT DISTINCT a.person_id ';
			l_from_clause  := ' FROM  per_all_assignments_f a';
			l_where_clause := ' WHERE a.organization_id = :org_id'||
                                          ' AND a.assignment_type in (''E'',''C'') '||     /*Added condition for Bug 7012687 */
                                          ' AND a.job_id is not null'||                    /*Added condition for Bug 7012687 */
                                          ' AND a.primary_flag = ''Y'' ';                  /*Added condition for Bug 7012687 */
		ELSIF l_selection_option = 'START_ORG' THEN
			-- Organization hierarchy and starting organization is specified
			l_sel_clause   := ' SELECT DISTINCT a.person_id ';
			l_from_clause  := ' FROM  per_all_assignments_f a';
			l_where_clause := ' WHERE a.organization_id IN ( '||
					  ' SELECT hrorg.organization_id '||
					  ' FROM hr_all_organization_units_tl hrorg, hr_organization_information orginfo '||
					  ' WHERE hrorg.language = userenv(''LANG'') '||
						' AND orginfo.organization_id = hrorg.organization_id '||
						' AND orginfo.ORG_INFORMATION_CONTEXT = ''CLASS'' '||
						' AND orginfo.ORG_INFORMATION1 = ''PA_EXPENDITURE_ORG'' '||
						' AND orginfo.ORG_INFORMATION2 = ''Y'' '||
						' AND hrorg.organization_id IN ( '||
							' SELECT organization_id_child organization_id '||
							' FROM PER_ORG_STRUCTURE_ELEMENTS '||
							' WHERE org_structure_version_id = :org_str_version_id '||
							' START WITH  organization_id_parent = :start_org '||
							' AND org_structure_version_id = :org_str_version_id '||
							' CONNECT BY PRIOR organization_id_child = organization_id_parent '||
							' AND org_structure_version_id = :org_str_version_id '||
							' UNION ALL '||
							' SELECT :start_org organization_id FROM dual) )'||
							' AND a.assignment_type in (''E'',''C'') '||     /*Added condition for Bug 7012687 */
							' AND a.job_id is not null'||                    /*Added condition for Bug 7012687 */
							' AND a.primary_flag = ''Y'' ';                  /*Added condition for Bug 7012687 */
		ELSIF l_selection_option IS NULL THEN
			-- Selection option not specified (Will never occur, but a check for backward compliance)
			IF l_p_org_id IS NULL THEN
				-- Employee range is specified
				l_sel_clause   := ' SELECT DISTINCT p.person_id ';
				--l_from_clause  := ' FROM per_all_people_f p ';                         /*Commented for Bug 7012687 */
				l_from_clause  := ' FROM per_all_people_f p , per_all_assignments_f a '; /*Added per_all_asgn_f for Bug 7012687 */
				l_where_clause := ' WHERE p.employee_number >=  :from_emp_num AND p.employee_number <= :to_emp_num '||
                                                  ' AND p.person_id = a.person_id '||                    /*Added condition for Bug 7012687 */
                                                  ' AND a.assignment_type in (''E'',''C'') '||           /*Added condition for Bug 7012687 */
                                                  ' AND a.job_id is not null'||                          /*Added condition for Bug 7012687 */
                                                  ' AND a.primary_flag = ''Y'' ';                        /*Added condition for Bug 7012687 */
			ELSIF (l_from_emp_num IS NOT NULL AND l_to_emp_num IS NOT NULL) THEN
				-- Employee range and Organization is specified
				l_sel_clause   := ' SELECT DISTINCT p.person_id ';
				l_from_clause  := ' FROM per_all_people_f p, per_all_assignments_f a';
				l_where_clause := ' WHERE a.person_id = p.person_id '||
					' AND a.organization_id = :org_id '||
					' AND p.employee_number >= :from_emp_num '||
					' AND p.employee_number <= :to_emp_num '||
					' AND a.assignment_type in (''E'',''C'') '||           /*Added condition for Bug 6850503 */
					' AND a.job_id is not null'||                          /*Added condition for Bug 6850503 */
					' AND a.primary_flag = ''Y'' ';                        /*Added condition for Bug 6850503 */
			ELSE
				-- Only Organization is specified
				l_sel_clause   := ' SELECT DISTINCT a.person_id ';
				l_from_clause  := ' FROM  per_all_assignments_f a';
				l_where_clause := ' WHERE a.organization_id = :org_id'||
                                                  ' AND a.assignment_type in (''E'',''C'') '||           /*Added condition for Bug 7012687 */
                                                  ' AND a.job_id is not null'||                          /*Added condition for Bug 7012687 */
                                                  ' AND a.primary_flag = ''Y'' ';                        /*Added condition for Bug 7012687 */
			END IF;
		END IF;

		l_stmt := l_sel_clause || l_from_clause || l_where_clause;
		DBMS_SQL.PARSE(sql_cursor, l_stmt, dbms_sql.v7);

		IF l_selection_option = 'EMP_RANGE' THEN
			-- Employee range is specified
			DBMS_SQL.BIND_VARIABLE(sql_cursor,':from_emp_num',l_from_emp_num);
			DBMS_SQL.BIND_VARIABLE(sql_cursor,':to_emp_num',l_to_emp_num);
		ELSIF l_selection_option = 'EMP_RANGE_ORG' THEN
			-- Employee range and organization is specified
			DBMS_SQL.BIND_VARIABLE(sql_cursor,':org_id',l_p_org_id);
			DBMS_SQL.BIND_VARIABLE(sql_cursor,':from_emp_num',l_from_emp_num);
			DBMS_SQL.BIND_VARIABLE(sql_cursor,':to_emp_num',l_to_emp_num);
		ELSIF l_selection_option = 'SINGLE_ORG' THEN
			-- Organization is specified
			DBMS_SQL.BIND_VARIABLE(sql_cursor,':org_id',l_p_org_id);
		ELSIF l_selection_option = 'START_ORG' THEN
			-- Organization hierarchy and starting organization is specified
			DBMS_SQL.BIND_VARIABLE(sql_cursor,':org_str_version_id',l_org_str_version_id);
			DBMS_SQL.BIND_VARIABLE(sql_cursor,':start_org',l_start_organization_id);
		ELSIF l_selection_option IS NULL THEN
			-- Selection option not specified (Will never occur, but a check for backward compliance)
			IF l_p_org_id IS NULL THEN
				--  Employee range is specified
				DBMS_SQL.BIND_VARIABLE(sql_cursor,':from_emp_num',l_from_emp_num);
				DBMS_SQL.BIND_VARIABLE(sql_cursor,':to_emp_num',l_to_emp_num);
			ELSIF (l_from_emp_num IS NOT NULL AND l_to_emp_num IS NOT NULL) THEN
				-- Employee range and Organization is specified
				DBMS_SQL.BIND_VARIABLE(sql_cursor,':org_id',l_p_org_id);
				DBMS_SQL.BIND_VARIABLE(sql_cursor,':from_emp_num',l_from_emp_num);
				DBMS_SQL.BIND_VARIABLE(sql_cursor,':to_emp_num',l_to_emp_num);
			ELSE
				-- Only Organization is specified
				DBMS_SQL.BIND_VARIABLE(sql_cursor,':org_id',l_p_org_id);
			END IF;
		END IF;
		-- End - Bug 5130414 - PJR Resource Pull Enhancement

		 DBMS_SQL.DEFINE_COLUMN(sql_cursor, 1, l_person_id);
                 l_rows := DBMS_SQL.EXECUTE (sql_cursor);

-- hr_utility.trace('l_rows is : ' || l_rows);
              LOOP
                 IF DBMS_SQL.FETCH_ROWS(sql_cursor) = 0 THEN
                    EXIT;
                 END IF;
                 -- Get the person ID to process into l_person_id
                 DBMS_SQL.COLUMN_VALUE(sql_cursor,1,l_person_id);


-- hr_utility.trace('person id  is : ' || l_person_id);
               -- Loop through cur_resources cursor
               FOR eRec IN cur_resources(l_person_id, p_pull_term_res,
                                         l_term_range_date, p_person_type) LOOP
-- hr_utility.trace('inside loop for person ' || l_person_id);

               -- Loop through cur_resources cursor
               -- FOR eRec IN cur_resources(l_from_emp_num, l_to_emp_num, l_p_org_id) LOOP

          -- End Bug 3086960

                   BEGIN

                     -- For selecting cursor columns into local variables.
                     --   l_person_id                := eRec.person_id;   -- Commented out for bug 3086960

                        --Check whether this person is already a resource in denorm
                        --Skip this person if he is, when the l_refresh from concurrent
                        --program parameter is No
                        --do this check once for every person
                        if (l_refresh = 'N'and G_person_id <> l_person_id) then

                            open check_res_denorm;
                            fetch check_res_denorm into l_denorm_yes;
                            close check_res_denorm;

                            if l_denorm_yes = 'Y' then
                                pa_debug.g_err_stage := 'Log: Resource already in denorm and l_refresh=N: person_id=' || l_person_id;
                                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                                END IF;
                                log_message('Resource already in denorm and l_refresh=N: person_id=' || l_person_id);
                                raise PERSON_ERROR_EXCEPTION;
                            end if;

                        end if;


                        IF (i = l_max_count and G_person_id <> l_person_id ) THEN
                           IF (fnd_api.to_boolean(p_commit)) THEN
                              COMMIT WORK;
                              log_message('Commit work - lock released');
                              pa_debug.g_err_stage := 'Log: COMMIT for person_id = ' || G_person_id;
                              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                                 pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                              END IF;
                              /* Adding the following code to re-establish
                                 Savepoint after l_max_count resources are
                                 committed
                              */
                              i := 0;--reset loop variable
                              -- SAVEPOINT res_pvt_create_resource;
                           END IF;
                        END IF;

                        log_message('G_person_id value = ' || G_person_id);
                        log_message('l_person_id value = ' || l_person_id);

			 --Getting the latest name of person - bug 3273964
			pa_debug.g_err_stage       := 'OLD PERSON_NAME ==> ' ||eRec.NAME;
			IF P_DEBUG_MODE = 'Y' THEN
				pa_debug.write_file('start_crm_workflow: ' ||'LOG',pa_debug.g_err_stage);
			END IF;

			eRec.NAME  := pa_resource_utils.get_person_name_no_date(P_PERSON_ID => eRec.person_id);

			pa_debug.g_err_stage       := 'NEW PERSON_NAME ==> ' || eRec.NAME;
                        IF P_DEBUG_MODE = 'Y' THEN
                                pa_debug.write_file('start_crm_workflow: ' ||'LOG',pa_debug.g_err_stage);
                        END IF;

			log_message('PERSON_NAME ==> '|| eRec.NAME);
			-- end bug 3273964

                        --set the global person_id variable
                        IF(G_person_id <> l_person_id) THEN

                           G_person_id := l_person_id;
                           log_message('G_person_id value - enter if condition = ' || G_person_id);

                           IF (fnd_api.to_boolean(p_commit)) THEN
                              log_message('set SAVEPOINT for G_person_id' || G_person_id);
                              SAVEPOINT res_pvt_create_resource;
                           END IF;

                           -------------------------------------------------
                           -- USER-LOCK: lock the person_id for processing
                           -- If cannot get lock, then will continue
                           -- with the next record (this is done by raising
                           -- expected error which stores the error msg in
                           -- the pa_reporting_exceptions table)
                           -------------------------------------------------
                           if(pa_resource_utils.acquire_user_lock(l_person_id, 'Resource Pull') <> 0) then
                               pa_debug.g_err_stage := 'Log: Unable to acquire LOCK for person_id = ' || l_person_id;
                               IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                                  pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                               END IF;
                               log_message('Unable to acquire LOCK for person_id = ' || l_person_id);

                               -- get the info of this person to be inserted into exception table
                               l_name                     := eRec.name;
                               l_organization_id          := eRec.organization_id;
                               l_assignment_start_date    := eRec.assignment_start_date;
                               l_assignment_end_date      := eRec.assignment_end_date;

                               PA_UTILS.Add_Message( p_app_short_name  => 'PA'
                                                    ,p_msg_name        => 'PA_RS_SKIP_CANT_LOCK');

                               -- set the variable to N so in the next loop, if it is the same person Id
                               -- too, that will raise person_error_exception and the code will not
                               -- process this person
                               l_per_success := 'N';
                               RAISE FND_API.G_EXC_ERROR;

                           else
                               pa_debug.g_err_stage := 'Log: Able to acquire LOCK for person_id = ' || l_person_id;
                               IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                                  pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                               END IF;
                               log_message('Able to acquire LOCK for person_id = ' || l_person_id);
                           end if;

                           i := i+1;
                           log_message('i = ' || i);

                           -- set the success flag for this new person to Y
                           l_per_success := 'Y';

                           -- get the latest HR assignment end date for this person id

-- hr_utility.trace('inside loop termination date is ' || eRec.termination_date);
                           IF eRec.termination_date IS NULL THEN
                              OPEN get_max_asgmt_end_date;
                              FETCH get_max_asgmt_end_date INTO l_end_date;
                              CLOSE get_max_asgmt_end_date;
                           ELSE
                              OPEN get_max_end_date_term(l_person_id);
                              FETCH get_max_end_date_term INTO l_end_date;
                              CLOSE get_max_end_date_term;
                           END IF;


                        ----------------------------------------------------
                        -- If the same person_id is seen, and there has been
                        -- an error in the previous records for this person,
                        -- exception is raised and do nothing
                        -- Person not pulled because at least one assignment
                        -- has an error.
                        ----------------------------------------------------
                        ELSIF (G_person_id = l_person_id) THEN
                           IF l_per_success = 'N' THEN
                             log_message('raising person_error_exception');
                             raise PERSON_ERROR_EXCEPTION;
                           END IF;
                        END IF;

                        pa_debug.g_err_stage       := '*******************************************************';
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                        END IF;
                        pa_debug.g_err_stage       := 'PERSON_ID ==> ' || to_char(l_person_id);
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           pa_debug.write_file('start_crm_workflow: ' || 'LOG', pa_debug.g_err_stage);
                        END IF;
                        log_message('*****************************************');
                        log_message('PERSON_ID ==> '|| to_char(l_person_id));

                        l_name                     := eRec.name;
                        l_organization_id          := eRec.organization_id;
                        l_assignment_start_date    := eRec.assignment_start_date;
                        l_assignment_end_date      := eRec.assignment_end_date;
                        l_start_date               := eRec.start_date;
                        l_default_OU               := eRec.default_OU;
                        l_calendar_id              := eRec.calendar_id;
                        l_system_type              := eRec.p_type;
                        l_user_type                := eRec.user_type;
                        l_res_exists               := eRec.res_exists;

                        log_message('ORG_ID ==> '|| to_char(l_organization_id));
                        log_message('OU ==> '|| to_char(l_default_OU));


                        --Call get_person_name procedure
                        --to get supervisor name
                        pa_resource_utils.get_person_name(
                            P_PERSON_ID     => eRec.supervisor_id,
                            X_PERSON_NAME   => l_supervisor_name,
                            X_RETURN_STATUS => l_return_status);


                        --Call get_location_details procedure
                        pa_resource_utils.get_location_details (
                            P_LOCATION_ID    => eRec.location_id,
                            X_ADDRESS_LINE_1 => l_address1,
                            x_address_line_2 => l_address2,
                            x_address_line_3 => l_address3,
                            x_town_or_city   => l_city,
                            x_postal_code    => l_postal_code,
                            x_country        => l_country,
                            x_return_status  => l_return_status);


                        pa_debug.g_err_stage := 'Log: Calling Create_Internal_Resource procedure';
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                        END IF;

			    --Call check_res_exists procedure  Added for bug 5046096
			PA_RESOURCE_UTILS.CHECK_RES_EXISTS(
			    p_person_id     => l_person_id,
			    x_valid         => l_valid,
			    x_return_status => l_return_status);

                            IF (l_valid = 'Y') THEN
                                l_res_exists := 'EXISTS';
                            ELSE
                                l_res_exists := 'NOT EXISTS';
                            END IF;

                        log_message('Before calling CREATE_INTERNAL_RESOURCE procedure');
                        --Call CREATE_INTERNAL_RESOURCE procedure
-- hr_utility.trace('before CREATE_INTERNAL_RESOURCE');
                        CREATE_INTERNAL_RESOURCE(
                                P_PERSON_ID                   => l_person_id,
                                P_NAME                        => l_name,
                                P_ORGANIZATION_ID             => l_organization_id,
                                P_ASSIGNMENT_START_DATE       => l_assignment_start_date,
                                P_ASSIGNMENT_END_DATE         => l_assignment_end_date,
                                P_START_DATE                  => l_start_date,
                                P_DEFAULT_OU                  => l_default_OU,
                                P_CALENDAR_ID                 => l_calendar_id,
                                P_SYSTEM_TYPE                 => l_system_type,
                                P_USER_TYPE                   => l_user_type,
                                P_RES_EXISTS                  => l_res_exists,
                                P_COUNT                       => 1,--This value is not being used and is defaulted to 1
                                P_RESOURCE_TYPE               => l_resource_type,
                                X_RESOURCE_ID                 => x_resource_id,
                                X_RETURN_STATUS               => l_return_status, --x_return_status, -- Commented For bug 4087022
                                P_START_DATE_ACTIVE           => eRec.per_start_date,
                                P_END_DATE_ACTIVE             => eRec.per_end_date,
                                P_SOURCE_NUMBER               => eRec.per_emp_number,
                                P_SOURCE_JOB_TITLE            => eRec.job_name,
                                P_SOURCE_EMAIL                => eRec.per_email,
                                P_SOURCE_PHONE                => eRec.per_work_phone,
                                P_SOURCE_ADDRESS1             => l_address1,
                                P_SOURCE_ADDRESS2             => l_address2,
                                P_SOURCE_ADDRESS3             => l_address3,
                                P_SOURCE_CITY                 => l_city ,
                                P_SOURCE_POSTAL_CODE          => l_postal_code,
                                P_SOURCE_COUNTRY              => l_country,
                                P_SOURCE_MGR_ID               => eRec.supervisor_id,
                                P_SOURCE_MGR_NAME             => l_supervisor_name,
                                P_SOURCE_BUSINESS_GRP_ID      => eRec.per_business_group_id,
                                P_SOURCE_BUSINESS_GRP_NAME    => eRec.org_name,
                                P_SOURCE_FIRST_NAME           => eRec.per_first_name,
                                P_SOURCE_LAST_NAME            => eRec.per_last_name,
                                P_SOURCE_MIDDLE_NAME          => eRec.per_middle_name);

-- hr_utility.trace('after CREATE_INTERNAL_RESOURCE');
-- hr_utility.trace('x_return_status is : ' || x_return_status);
                        pa_debug.g_err_stage := 'Log: After Create_Internal_Resource procedure';
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                        END IF;

--                      Commenting For bug 4087022
--			IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--                           x_return_status := FND_API.G_RET_STS_ERROR;
                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                             l_return_status := FND_API.G_RET_STS_ERROR;
                             l_per_success := 'N';
                             RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        log_message('After calling CREATE_INTERNAL_RESOURCE procedure');

                        log_message('Number of Stack messages = ' || to_char(FND_MSG_PUB.Count_Msg));
--                        log_message('Return Status after create internal resource ' || x_return_status); -- Commenting For bug 4087022
                        log_message('Return Status after create internal resource ' || l_return_status);

                        --Adding call to check if OU is Exp OU only if the org is a Multi-Org
                        log_message('Calling check_ou');
                        pa_debug.g_err_stage := 'Log: Calling Check_OU procedure';
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                        END IF;
--MOAC Changes : Bug 4363092: Commenting this cursor as now As R12 will have multi org setup only
  /*                    OPEN check_org_type;
                        FETCH check_org_type into l_org_type;
                        CLOSE check_org_type;  */

                        -- case for Multi-Org
--                        IF l_org_type IS NOT NULL THEN  --Bug 4363092

                            CHECK_OU(
                               P_DEFAULT_OU       => l_default_OU,
                               P_EXP_ORG          => 'YES',
                               X_EXP_OU           => x_exp_ou,
--                               X_RETURN_STATUS    => x_return_status); -- Commenting For bug 4087022
                               X_RETURN_STATUS    => l_return_status);

                            IF(x_exp_ou = 'N') THEN
                                 pa_debug.g_err_stage := 'Log: Multi Org - OU does not implement Projects';
                                 IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                                    pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                                 END IF;
                                 PA_UTILS.Add_Message(
                                        p_app_short_name => 'PA'
                                       ,p_msg_name       => 'PA_OU_NO_PROJECTS');
--                                 x_return_status := FND_API.G_RET_STS_ERROR; -- Commenting For bug 4087022
                                 l_return_status := FND_API.G_RET_STS_ERROR;
                                 l_per_success := 'N';

                                 RAISE FND_API.G_EXC_ERROR;
                            END IF;

--                        log_message('After check_ou '|| x_return_status); -- Commenting For bug 4087022
                        log_message('After check_ou '|| l_return_status);

                        -- case for Single-Org
/*                      ELSE  -- Bug 4363092
                             l_default_OU := NULL;
                        END IF; */


                        log_message('l_default_OU =====>  '||to_char(l_default_OU));

                        --Adding call to populate resource denorm tables
                        pa_debug.g_err_stage := 'Log: Calling Populate_Resources_Denorm procedure';
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                        END IF;

-- hr_utility.trace('before  populate_resources_denorm');

                --------------------------------------------------------------------
                -- Bug Ref # 6411422
                -- Adding Profile Date Honoring Logic for Resource
                ---------------------------------------------------------------------
                -- l_prof_date := FND_PROFILE.value('PA_UTL_START_DATE') ; /* commenting for For Bug 7304151 */
                   l_prof_date := to_date(fnd_profile.value('PA_UTL_START_DATE'), 'DD/MM/YYYY', 'NLS_DATE_LANGUAGE=AMERICAN'); /*Adding For Bug 7304151 */
                IF ( l_prof_date IS NOT NULL ) THEN
                  IF (  l_prof_date  >= l_assignment_start_date AND l_prof_date <= l_assignment_end_date  ) THEN
                    log_message(' Profile Date is Later than the Employee Start Date');
                    l_populate_denorm_flag := 'Y' ;
                    l_assignment_start_date  :=  l_prof_date;
                  ELSE
                    IF ( l_assignment_start_date >= l_prof_date ) THEN
                      l_populate_denorm_flag := 'Y' ;
                    ELSE
                      l_populate_denorm_flag := 'N' ;
                    END IF;
                  END IF;
                END IF;
                IF (  l_populate_denorm_flag = 'Y' ) THEN                        -- Bug 6411422

                        pa_resource_pvt.populate_resources_denorm(
                            p_resource_source_id              => l_person_id
                          , p_resource_id                     => x_resource_id
                          , p_resource_name                   => l_name
                          , p_resource_type                   => eRec.resource_type
                          , p_person_type                   => eRec.p_type
                          , p_resource_job_id                 => eRec.job_id
                          , p_resource_job_group_id           => eRec.job_group_id
                          , p_resource_org_id                 => l_default_OU
                          , p_resource_organization_id        => l_organization_id
                          , p_assignment_start_date           => l_assignment_start_date
                          , p_assignment_end_date             => l_assignment_end_date
                          , p_manager_id                      => eRec.supervisor_id
                          , p_manager_name                    => l_supervisor_name
                          , p_request_id                      => G_request_id
                          , p_program_application_id          => G_application_id
                          , p_program_id                      => G_program_id
                          , p_commit                          => fnd_api.G_false
                          , p_validate_only                   => fnd_api.G_false
                          , x_msg_data                        => x_msg_data
                          , x_msg_count                       => x_msg_count
--                          , x_return_status                   => x_return_status); -- Commenting For bug 4087022
                          , x_return_status                   => l_return_status);

-- hr_utility.trace('after  populate_resources_denorm');
-- hr_utility.trace('x_return_status is : ' || x_return_status);
-- hr_utility.trace('x_msg_data is : ' || x_msg_data);
                        pa_debug.g_err_stage := 'Log: After Populate_Resources_Denorm procedure';
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                        END IF;
--                        log_message('After resources denorm '|| x_return_status); -- Commenting For bug 4087022
                        log_message('After resources denorm '|| l_return_status);
                       END IF; -- Bug 6411422

                        /* Changes start for Bug 5662589 */
                        ---------------------------------------------------------------------
                        --This IF tells us the last record for a person as from cur_resources.
                        --Here we are going to delete all rows for pa_resources_denorm for
                        --which the resource_effective_end_date is greater than
                        --max(assignment_end_date) from pa_r_project_resources_term_v res
                        ---------------------------------------------------------------------
                        IF (trunc(l_end_date) = trunc(l_assignment_end_date))
	                        AND eRec.termination_date IS NOT NULL THEN

                            log_message('Delete Terminate resource denorm data');
                            pa_debug.g_err_stage := 'Delete Terminate resource denorm data';
                            IF P_DEBUG_MODE = 'Y' THEN
                             pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                            END IF;

                            DELETE FROM PA_RESOURCES_DENORM
                            WHERE person_id = l_person_id
                            AND resource_effective_start_date > l_end_date;

                            log_message('right after calling deleting denorm data');
                            pa_debug.g_err_stage := 'Log: after calling deleting denorm data';
                            IF P_DEBUG_MODE = 'Y' THEN
                              pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                            END IF;

                        END IF;
                        /* Changes end for Bug 5662589 */

                        -------------------------------------------------------
                        -- Call Create Timeline only for the last assignment
                        -- where the latest HR assignment end date is equal to
                        -- the l_assignment_end_date
                        -------------------------------------------------------
                        /*2749061: Do not create FI for past employees*/
                        IF (trunc(l_end_date) = trunc(l_assignment_end_date)) THEN
-- AND trunc(l_end_date) >= sysdate) THEN

                         /* Cleaning pa_resources_denorm start *** Bug 9198412 */
                         IF (trunc(eRec.termination_date) IS NULL
                         and trunc(l_assignment_end_date) < trunc(sysdate)
                         and l_refresh = 'Y') THEN

                          delete from pa_resources_denorm
                          where person_id = l_person_id
                          and resource_effective_start_date > l_end_date;

                         END IF;
                         /* Cleaning pa_resources_denorm start end *** Bug 9198412 */

                         /* Removing data from pa_resources_demorn as per 7336526 */
                         IF (l_refresh = 'Y' AND l_prof_date IS NOT NULL) THEN
                           FOR delrec2 IN cur_denorm_del_redundant(l_person_id, l_prof_date) LOOP

                             DELETE FROM pa_resources_denorm
                             WHERE RESOURCE_EFFECTIVE_START_DATE = delrec2.RESOURCE_EFFECTIVE_START_DATE
                             AND PERSON_ID = delrec2.PERSON_ID;

                           END LOOP ;
                        END IF;


                         /*Code starts for Bug 6943551*/
                         FOR delrec IN cur_denorm_del(l_person_id) LOOP

                          DELETE FROM pa_resources_denorm
                          WHERE RESOURCE_EFFECTIVE_START_DATE = delrec.RESOURCE_EFFECTIVE_START_DATE
						  AND PERSON_ID = delrec.PERSON_ID;  --bug#8840426

                         END LOOP ;
                         /*Code ends for Bug 6943551*/

                          /*Call added for bug 5683340*/
                          pa_debug.g_err_stage := 'Log: Calling pa_resource_utils.init_fte_sync_wf for PersonId ='  || to_char(l_person_id) ;
                          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                             pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                          END IF;

                          log_message('Before Calling pa_resource_utils.init_fte_sync_wf');
                          pa_resource_utils.init_fte_sync_wf( p_person_id => l_person_id,
                                                              x_invol_term => l_invol_term,
--                                                              x_return_status => x_return_status, -- Commenting For bug 4087022
                                                              x_return_status => l_return_status,
                                                              x_msg_data => x_msg_data,
                                                              x_msg_count => x_msg_count);
--                          log_message('After Calling pa_resource_utils.init_fte_sync_wf, x_return_status: '||x_return_status); -- bug 5683340 ---- Commenting For bug 4087022
                          log_message('After Calling pa_resource_utils.init_fte_sync_wf, l_return_status: '||l_return_status); -- bug 5683340


			  pa_debug.g_err_stage := 'Log: After Calling pa_resource_utils.init_fte_sync_wf for PersonId ='  || to_char(l_person_id) ;
                          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                             pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                          END IF;


                          /*IF - ELSIF block  added for bug 5683340*/
--                          IF ((l_invol_term = 'N') AND (x_return_status = fnd_api.g_ret_sts_success )) THEN  -- Commenting For bug 4087022
                          IF ((l_invol_term = 'N') AND (l_return_status = fnd_api.g_ret_sts_success )) THEN
                              pa_debug.g_err_stage := 'Log: Calling Create_Timeline procedure for PersonId ='  || to_char(l_person_id) ;
                              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                                 pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                              END IF;
                              log_message('Calling Create_Timeline procedure after the last assignment for PersonId ='  || to_char(l_person_id));

-- hr_utility.trace('before  Create_Timeline');
                             PA_TIMELINE_PVT.Create_Timeline (
                                p_start_resource_name  => NULL,
                                p_end_resource_name    => NULL,
                                p_resource_id          => x_resource_id,
                                p_start_date           => NULL,
                                p_end_date             => NULL,
--                                x_return_status        => x_return_status, -- Commenting For bug 4087022
                                x_return_status        => l_return_status,
                                x_msg_count            => x_msg_count,
                                x_msg_data             => x_msg_data);
-- hr_utility.trace('after  Create_Timeline');
-- hr_utility.trace('x_return_status is : ' || x_return_status);
-- hr_utility.trace('x_msg_data is : ' || x_msg_data);

--                             log_message('right after calling create_timeline, x_return_status : '||x_return_status); -- Commenting For bug 4087022
                             log_message('right after calling create_timeline, l_return_status : '||l_return_status);
                             pa_debug.g_err_stage := 'Log: After Create_Timeline procedure';
                             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                                pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                             END IF;

--                             IF (x_return_status <> fnd_api.g_ret_sts_success) THEN -- Commenting For bug 4087022
                             IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                                 log_message('it will raise exception');
                                 pa_debug.g_err_stage := 'Log: Timeline API returned error';
                                 IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                                    pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                                 END IF;
                                 l_per_success := 'N';
                                 RAISE FND_API.G_EXC_ERROR;
                             END IF;

--                             log_message('After timeline call: ' || x_return_status); -- Commenting For bug 4087022
                             log_message('After timeline call: ' || l_return_status);

--                          ELSIF (x_return_status <> fnd_api.g_ret_sts_success ) THEN  -- for bug 5683340 -- Commenting For bug 4087022
                          ELSIF (l_return_status <> fnd_api.g_ret_sts_success ) THEN  -- for bug 5683340
                             pa_debug.g_err_stage := 'Log: init_fte_sync_wf API returned error';
                             IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                               pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                             END IF;
                             l_per_success := 'N';
			     log_message(' Call to pa_resource_utils.init_fte_sync_wf errored in mass pull');
                             RAISE FND_API.G_EXC_ERROR;

		   	  END IF ; --IF ((l_invol_term = 'N') AND (l_return_status = fnd_api.g_ret_sts_success ))

                        END IF;

                        -----------------------------------------------------------------------
                        -- Populate msgs to the exception report for the people who has been
                        -- pulled but won't be searchable because they are either non scheduable
                        -- or there is no job mapping for the person.
                        -----------------------------------------------------------------------
         IF (  l_populate_denorm_flag = 'Y' ) THEN          -- bug 8669156
                        l_job_id := PA_JOB_UTILS.Get_Job_Mapping (
                                                     p_job_id       => eRec.job_id
                                                    ,p_job_group_id => eRec.job_group_id);

    -- bug 4171563. Changed 'substr' to 'substrb' in the call to PA_MESSAGE_UTILS.save_messages

                        IF l_job_id IS NULL THEN
                           PA_MESSAGE_UTILS.save_messages(
                             p_request_id     =>  G_request_id
                                ,p_source_Type1   =>  'RESOURCE_PULL'
                                ,p_source_Type2   =>  'PARCPRJR'
                                ,p_context1       =>  l_person_id
                                ,p_context2       =>  substrb(l_name, 1, 30)
                                ,p_context3       =>  l_organization_id
                                ,p_context4       =>  eRec.job_id
                                ,p_context5       =>  substrb(l_supervisor_name, 1, 30)
                                ,p_context10      =>  'NO_JOB_MAP'
                                ,p_date_context1  =>  l_assignment_start_date
                                ,p_date_context2  =>  l_assignment_end_date
                                ,p_use_fnd_msg    =>  'N'
                                ,p_commit         =>  FND_API.G_FALSE  --p_commit
                                ,x_return_status  =>  l_return_status);
                        END IF;

                        l_job_schedulable := PA_HR_UPDATE_API.check_job_schedulable
                                                        (p_job_id  => eRec.job_id);

                        IF l_job_schedulable = 'N' THEN
                           PA_MESSAGE_UTILS.save_messages(
                             p_request_id     =>  G_request_id
                                ,p_source_Type1   =>  'RESOURCE_PULL'
                                ,p_source_Type2   =>  'PARCPRJR'
                                ,p_context1       =>  l_person_id
                                ,p_context2       =>  substrb(l_name, 1, 30)
                                ,p_context3       =>  l_organization_id
                                ,p_context4       =>  eRec.job_id
                                ,p_context5       =>  substrb(l_supervisor_name, 1, 30)
                                ,p_context10      =>  'NON_SCHEDULABLE'
                                ,p_date_context1  =>  l_assignment_start_date
                                ,p_date_context2  =>  l_assignment_end_date
                                ,p_use_fnd_msg    =>  'N'
                                ,p_commit         =>  FND_API.G_FALSE  --p_commit
                                ,x_return_status  =>  l_return_status);
                        END IF;
         END IF;  -- bug 8669156
                   EXCEPTION
                       WHEN FND_API.G_EXC_ERROR THEN
                           --x_return_status := FND_API.G_RET_STS_ERROR;

			   l_excep := 'Y' ; -- Adding For bug 4087022

                           IF p_commit = fnd_api.g_true THEN
                                log_message('rollback in inner exception block');
                                ROLLBACK TO res_pvt_create_resource;  --line 2813
                                log_message('after rollback in inner exception block');
                           END IF;

                           -- will still do this to display the error message in the log file
                           FND_MSG_PUB.get (
                              p_encoded        => FND_API.G_FALSE,
                              p_msg_index      => 1,
                              p_data           => x_msg_data,
                              p_msg_index_out  => x_msg_count );

                           pa_debug.g_err_stage := 'Expected error for Person = ' || to_char(l_person_id);
                           IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                              pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                           END IF;
                           pa_debug.g_err_stage := 'ERROR: ' || substr(x_msg_data,1,200);
                           IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                              pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                           END IF;

                           log_message('Expected error for Person = ' || to_char(l_person_id));
                           log_message('ERROR: ' || substr(x_msg_data,1,200));

                           -- then save the error message in the pa_reporting_exceptions table
                           PA_MESSAGE_UTILS.save_messages(
                             p_request_id     =>  G_request_id
                                ,p_source_Type1   =>  'RESOURCE_PULL'
                                ,p_source_Type2   =>  'PARCPRJR'
                                ,p_context1       =>  l_person_id
                                ,p_context2       =>  substrb(l_name, 1, 30)  -- Bug 3086960. Changed Substrb. Sachin
                                ,p_context3       =>  l_organization_id
                                ,p_context10      =>  'REJECTED'
                                ,p_date_context1  =>  l_assignment_start_date
                                ,p_date_context2  =>  l_assignment_end_date
                                ,p_commit         =>  p_commit
                                ,x_return_status  =>  l_return_status);

                           -- reset variable i
                           i :=0;

                      WHEN PERSON_ERROR_EXCEPTION THEN
                           null;

-- Begin Bug 3086960. Added by Sachin.

/*                   END;

                END LOOP;
*/
            WHEN OTHERS THEN

            /*Adding For bug 4087022*/
	    l_excep := 'Y' ;
            FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_R_PROJECT_RESOURCES_PVT.Create_Resource'
                                   ,p_procedure_name =>'Create_Resource' );
            /*For bug 4087022*/

	    IF p_commit = fnd_api.g_true THEN
                              log_message('when others rollback in inner exception block') ;
                                ROLLBACK TO res_pvt_create_resource;
                        END IF;

                           -- will still do this to display the error message inthe log file
                           FND_MSG_PUB.get (
                              p_encoded        => FND_API.G_FALSE,
                              p_msg_index      => 1,
                              p_data           => x_msg_data,
                              p_msg_index_out  => x_msg_count );
                           log_message('*** When Others Un Expected error for Person = ' || TO_CHAR (l_person_id));
                           log_message('ERROR: ' || SUBSTR(x_msg_data,1,200));

                           -- then save the error message in the pa_reporting_exceptions table
                           PA_MESSAGE_UTILS.save_messages(
                                 p_request_id     =>  G_request_id
                                ,p_source_Type1   =>  'RESOURCE_PULL'
                                ,p_source_Type2   =>  'PARCPRJR'
                                ,p_context1       =>  l_person_id
                                ,p_context2       =>  SUBSTRB(l_name,1,30)
                                ,p_context3       =>  l_organization_id
                                ,p_context10      =>  'REJECTED'
                                ,p_date_context1  =>  l_assignment_start_date
                                ,p_date_context2  =>  l_assignment_end_date
                                ,p_commit         =>  p_commit
                                ,x_return_status  =>  l_return_status);

                           -- reset variable i
                           i :=0;

                   END;

                END LOOP;
                 /* Placing this outside the loop so as to only make it execute once. removing data from pa_resources_denorm as per Bug 7336526*/
                         IF (l_refresh = 'Y' AND l_prof_date IS NOT NULL AND p_pull_term_res = 'Y') THEN
                            FOR delrec3 IN cur_denorm_del_term(l_prof_date) LOOP

                             DELETE FROM pa_resources_denorm
                             WHERE person_id = delrec3.person_id
                               AND resource_effective_start_date = delrec3.assignment_start_date
                               AND resource_organization_id = l_p_org_id;


                            END LOOP ;
                         END IF;


                END LOOP; -- Dynamic SQL loop
                DBMS_SQL.CLOSE_CURSOR(sql_cursor);

-- End Bug 3086960

                pa_debug.g_err_stage := 'Log: Calling Populate_Org_Hier_Denorm procedure';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                log_message('Calling Populate_Org_Hier_Denorm procedure');

-- Begin Bug 3086960. Commented out for performance. Sachin
/*
                PA_ORG_UTILS.Populate_Org_Hier_Denorm(
                   x_return_status  => x_return_status,
                   x_msg_data       => x_msg_data);
*/
                pa_debug.g_err_stage := 'Log: After Populate_Org_Hier_Denorm procedure';
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
                END IF;
                log_message('Out of Populate_Org_Hier_Denorm procedure');


          END IF; --For Individual, Internal person


        ELSE
          ----------------------------------------------------
          -- this is the else for the condition l_internal=Y
          -- For pulling external person
          -- PULLING EXTERNAL PEOPLE
          ----------------------------------------------------

          IF (l_individual = 'Y') THEN
            pa_debug.g_err_stage := 'Log: For a single external Resource';
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
            END IF;
            log_message('For Ind. External Resource');

            -----------------------------------------------------------------
            -- First, need to check if the resource_type is HZ_PARTY and
            -- party_id is passed. If Yes - the call CREATE_EXTERNAL_RESOURCE
            -----------------------------------------------------------------
            IF(l_resource_type = 'HZ_PARTY' and l_party_id is not null) THEN
              log_message('Creating External Person as a Resource');

              CREATE_EXTERNAL_RESOURCE(
                     P_PARTY_ID        => l_party_id,
                     P_RESOURCE_TYPE   => l_resource_type,
                     X_RESOURCE_ID     => x_resource_id,
                     X_RETURN_STATUS   => x_return_status);


              IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

              RETURN;

            END IF;

          END IF;

        END IF; --For Internal

        pa_debug.g_err_stage := 'Log: End of Create_Resource procedure';
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.write_file('start_crm_workflow: ' || 'LOG',pa_debug.g_err_stage);
        END IF;
        log_message('End of create_resource procedure');

        IF fnd_api.to_boolean(p_commit) THEN
                COMMIT WORK;
        END IF;

        --Reset all Global Variables.
        PA_RESOURCE_PVT.G_Prev_Res_Source_Id := NULL;

        G_pkg_name         := NULL;
        G_p_id             := NULL;
        G_count            := NULL;

        G_user_id          := NULL;
        G_login_id         := NULL;
        G_request_id       := NULL;
        G_program_id       := NULL;
        G_application_id   := NULL;

        PA_DEBUG.Reset_Err_Stack;

        /*Added for bug 4087022*/
	/*to return status as warning when l_excep = Y , i.e., */
	/*when some resource raised exception in inner loop */
	IF (l_excep = 'Y') THEN
         x_return_status := 'W';
	 x_resource_id := NULL ;
	END IF ;

 EXCEPTION

    WHEN TERM_DATE_EXCEPTION THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         PA_UTILS.Add_Message(
                               p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_TERM_DATE_OVER_MAX');

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
    -- 4537865
    x_resource_id := NULL ;

    WHEN OTHERS THEN
         log_message (' =============== ');
         log_message (' Raised Others in Create Resource Private');

        log_message (SQLCODE || SQLERRM);
        IF p_commit = fnd_api.g_true THEN
                log_message('rollback in outer exception block');
                ROLLBACK TO res_pvt_create_resource;  -- line 3005
        END IF;
        FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_R_PROJECT_RESOURCES_PVT.Create_Resource'
                                  ,p_procedure_name =>PA_DEBUG.G_Err_Stack );
        X_RETURN_STATUS := fnd_api.g_ret_sts_unexp_error;
            -- 4537865
        x_resource_id := NULL ;
        raise;

 END CREATE_RESOURCE;

PROCEDURE start_crm_workflow ( p_person_id                 IN  NUMBER,
                               p_assignment_start_date     IN  DATE,
                               x_return_status             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_error_message_code        OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
    IS

         ItemType           varchar2(30) := 'PACRMUPD';  -- Identifies the workflow that will be executed.
         ItemKey            number ;
         l_process          VARCHAR2(30);

         l_msg_count        NUMBER;
         l_msg_data         VARCHAR(2000);
         l_return_status    VARCHAR2(1);
-- l_api_version_number     NUMBER                := 1.0;
         l_data             VARCHAR2(2000);
         l_msg_index_out    NUMBER;
         l_save_thresh      NUMBER;

         l_err_code         NUMBER := 0;
         l_err_stage        VARCHAR2(2000);
         l_err_stack        VARCHAR2(2000);
--
--
   BEGIN


        --
        -- Get a unique identifier for this specific workflow
        --


        SELECT pa_workflow_itemkey_s.nextval
        INTO itemkey
        FROM dual;
        --
        -- Since this workflow needs to be executed in the background we need
        -- to change the threshold. So we save the current threshold which
        -- will be used later on to change it back to the current threshold.
        --

        l_save_thresh  := wf_engine.threshold ;


        IF wf_engine.threshold < 0 THEN
            wf_engine.threshold := l_save_thresh ;
        END IF;


        --
        -- Set the threshold to bellow 0 so that the process will be created
        -- in the background
        --

        wf_engine.threshold := -1 ;


        l_process  := 'PROCESS_CRM_UPDATE' ;


        --
        -- Create the appropriate process
        --
        wf_engine.CreateProcess( ItemType => ItemType,
                                 ItemKey  => ItemKey,
                                 process  => l_process );

                --
                -- Initialize workflow item attributes with the parameter values
                --
                wf_engine.SetItemAttrText ( itemtype        => itemtype,
                                            itemkey         => itemkey,
                                            aname           => 'PROJECT_RESOURCE_ADMINISTRATOR',
                                            avalue          => 'PASYSADMIN');

                wf_engine.SetItemAttrDate ( itemtype        => itemtype,
                                            itemkey         => itemkey,
                                            aname           => 'ASSIGNMENT_START_DATE',
                                            avalue          => p_assignment_start_date);

                wf_engine.SetItemAttrNumber ( itemtype      => itemtype,
                                              itemkey       => itemkey,
                                              aname         => 'PERSON_ID',
                                              avalue        => p_person_id);

                wf_engine.StartProcess ( itemtype    => itemtype,
                                         itemkey     => itemkey );

  /*      -- Insert to PA tables wf process information.
        -- This is required for displaying notifications on PA pages.

        BEGIN

           PA_WORKFLOW_UTILS.Insert_WF_Processes
                (p_wf_type_code        => 'HR_CHANGE_MGMT'
                ,p_item_type           => itemtype
                ,p_item_key            => itemkey
                ,p_entity_key1         => to_char(p_person_id)
                ,p_entity_key2         => to_char(p_person_id)
                ,p_description         => NULL
                ,p_err_code            => l_err_code
                ,p_err_stage           => l_err_stage
                ,p_err_stack           => l_err_stack
                );

        EXCEPTION
           WHEN OTHERS THEN
                null;
        END; */

        wf_engine.threshold := l_save_thresh ;
  EXCEPTION
      WHEN OTHERS THEN
          null;

  END start_crm_workflow;


PROCEDURE create_future_crm_resource
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

   l_person_id               NUMBER;
   l_assignment_start_date   DATE;
   l_current_asgn_start_date DATE;
   l_resource_id             NUMBER;


   l_msg_count                    NUMBER;
   l_msg_data                    VARCHAR(2000);
   l_return_status                VARCHAR2(1);
   l_api_version_number        NUMBER                := 1.0;
   l_data                            VARCHAR2(2000);
   l_msg_index_out                NUMBER;

   l_savepoint             BOOLEAN;

BEGIN

        --
        -- Get the workflow attribute values
        --

        l_person_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'PERSON_ID' );

        l_assignment_start_date := wf_engine.GetItemAttrDate( itemtype => itemtype,
                                                              itemkey  => itemkey,
                                                              aname    => 'ASSIGNMENT_START_DATE' );

        --
        -- Check if assignment start date has not changed
        --
        SAVEPOINT l_create_future_crm_resource ;
                l_savepoint := true;


                BEGIN
                   SELECT min(effective_start_date)
                   INTO   l_current_asgn_start_date
                   FROM   per_all_assignments_f
                   WHERE  person_id = l_person_id
                   AND    primary_flag = 'Y'
                   AND    job_id IS NOT NULL
                   AND    assignment_type in ('E', 'C');
                EXCEPTION
                   WHEN OTHERS THEN
                         l_current_asgn_start_date := NULL;
                END;

                IF (l_current_asgn_start_date IS NOT NULL) AND (l_current_asgn_start_date = l_assignment_start_date) THEN
                  pa_r_project_resources_pub.create_resource (
                      p_api_version        => 1.0
                     ,p_init_msg_list      => NULL
                     ,p_commit             => FND_API.G_FALSE
                     ,p_validate_only      => NULL
                     ,p_max_msg_count      => NULL
                     ,p_internal           => 'Y'
                     ,p_person_id          => l_person_id
                     ,p_individual         => 'Y'
                     ,p_scheduled_member_flag => 'Y'
                     ,p_resource_type      => NULL
                     ,x_return_status      => l_return_status
                     ,x_msg_count          => l_msg_count
                     ,x_msg_data           => l_msg_data
                                 ,x_resource_id        => l_resource_id);

/*                  IF l_return_status <>  'S' then
                         app_exception.raise_exception;
          END IF; */   -- Bug 7369682 : If error comes, we need to put it into Workkflow

                END IF;

        IF l_return_status = 'S'  THEN

            resultout := wf_engine.eng_completed||':'||'S';
        ELSE

            --
            -- Set any error messages
            --
            l_savepoint := false;
                        rollback to l_create_future_crm_resource ;

            /*Added For bug 7690604 */
            l_data := FND_MESSAGE.get_string('PA', l_msg_data );

                         wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG'
                               , avalue => l_data -- l_msg_data -- For bug 7690604
                               );

            resultout := wf_engine.eng_completed||':'||'F';

        END IF;

EXCEPTION

    WHEN OTHERS THEN
           wf_core.context('pa_r_project_resources_pvt',
                       'create_future_crm_resource',
                       itemtype,
                       itemkey,
                       to_char(actid),
                       funcmode);

           If (l_savepoint) then
                  rollback to l_create_future_crm_resource ;
           End if;

           wf_engine.SetItemAttrText ( itemtype => itemtype
                                   , itemkey =>  itemkey
                                   , aname => 'ERROR_MSG'
                                   , avalue => l_msg_data
                                                                 );
       resultout := wf_engine.eng_completed||':'||'F';

END create_future_crm_resource;

-----------------------------------------------------------------------------
--------------------------< get_user_person_type >--------------------------|
-----------------------------------------------------------------------------
FUNCTION GET_USER_PERSON_TYPE
  (P_EFFECTIVE_DATE               IN     DATE
  ,P_PERSON_ID                    IN     NUMBER
  )
RETURN VARCHAR2
IS
  CURSOR CSR_PERSON_TYPES
    (P_EFFECTIVE_DATE               IN     DATE
    ,P_PERSON_ID                    IN     NUMBER
    )
  IS
    SELECT TTL.USER_PERSON_TYPE
      FROM PER_PERSON_TYPES_TL TTL
          ,PER_PERSON_TYPES TYP
          ,PER_PERSON_TYPE_USAGES_F PTU
     WHERE TTL.LANGUAGE = USERENV('LANG')
       AND TTL.PERSON_TYPE_ID = TYP.PERSON_TYPE_ID
       AND TYP.SYSTEM_PERSON_TYPE IN ('EMP','EX_EMP','CWK','EX_CWK')
       AND TYP.PERSON_TYPE_ID = PTU.PERSON_TYPE_ID
       AND P_EFFECTIVE_DATE BETWEEN PTU.EFFECTIVE_START_DATE
                                AND PTU.EFFECTIVE_END_DATE
       AND PTU.PERSON_ID = P_PERSON_ID
  ORDER BY DECODE(TYP.SYSTEM_PERSON_TYPE
                 ,'EMP'   ,1
                 ,'CWK'   ,2
                 ,'EX_EMP',3
                 ,'EX_CWK',4
                          ,5
                 );
  L_USER_PERSON_TYPE             VARCHAR2(2000);
  L_SEPARATOR                    HR_PERSON_TYPE_USAGE_INFO.G_USER_PERSON_TYPE_SEPARATOR%TYPE;

BEGIN
  L_SEPARATOR := HR_PERSON_TYPE_USAGE_INFO.GET_USER_PERSON_TYPE_SEPARATOR();

  FOR L_PERSON_TYPE IN CSR_PERSON_TYPES
    (P_EFFECTIVE_DATE               => P_EFFECTIVE_DATE
    ,P_PERSON_ID                    => P_PERSON_ID
    )
  LOOP
    IF (L_USER_PERSON_TYPE IS NULL)
    THEN
      L_USER_PERSON_TYPE := L_PERSON_TYPE.USER_PERSON_TYPE;
    ELSE
      L_USER_PERSON_TYPE := L_USER_PERSON_TYPE
                         || L_SEPARATOR
                         || L_PERSON_TYPE.USER_PERSON_TYPE;
    END IF;
  END LOOP;
  RETURN L_USER_PERSON_TYPE;
END GET_USER_PERSON_TYPE;

END PA_R_PROJECT_RESOURCES_PVT;

/
