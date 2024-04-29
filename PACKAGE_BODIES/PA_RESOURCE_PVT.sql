--------------------------------------------------------
--  DDL for Package Body PA_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RESOURCE_PVT" AS
  -- $Header: PARRESVB.pls 120.8.12010000.5 2009/07/03 11:14:08 nisinha ship $
g_profile_id       NUMBER := 0;
g_person_id        NUMBER := 0;

l_profile varchar2(30) := NVL(FND_PROFILE.value('PA_AVAILABILITY_CAL_PERIOD'), 'DAILY'); /* Added the global profile call for bug 4930256 */

Procedure Set_No_of_Days
  (p_no_of_days    IN NUMBER)
IS
BEGIN
   PA_RESOURCE_PVT.no_of_days := p_no_of_days;
END;

/*-----------------------------------------------------------------+
 FUNCTION: Get_Start_Date
 DESCRIPTION: This Function finds the earliest available date for
              the resource passed in (p_resource_id).
              Instead of using forecast items table or pa_project_
              assignments, for PA.K, it uses pa_res_availability
              table to get available from and available to dates
------------------------------------------------------------------*/
FUNCTION Get_Start_Date
  (p_resource_id    IN NUMBER,
   p_no_of_days     IN NUMBER)
   RETURN DATE
IS
   l_start_date      DATE := '';
   l_end_date        DATE := '';
   l_available_date  DATE := '';
   l_avl_profile     VARCHAR2(240) := FND_NUMBER.CANONICAL_TO_NUMBER(fnd_profile.value('PA_RES_CAPACITY_PERCENTAGE'));

   -- new cursor to get available from date using pa_res_availability
   -- table (PA.K enhancements)
   CURSOR get_available_from IS
        SELECT (max(a1.end_date)+1) available_from
        FROM  pa_res_availability a1,
              pa_res_availability a2
        WHERE a1.resource_id = p_resource_id
          and a1.percent < l_avl_profile
          and a1.record_type = 'C'
          and a1.start_date < sysdate
          and a1.resource_id = a2.resource_id
          and a2.record_type ='C'
          and a2.percent >= l_avl_profile
          and sysdate between a2.start_date and a2.end_date
       UNION
        SELECT min(a1.start_date) available_from
        FROM  pa_res_availability a1,
              pa_res_availability a2
        WHERE a1.resource_id = p_resource_id
          and a1.percent >= l_avl_profile
          and a1.record_type = 'C'
          and a1.start_date >= sysdate
          and a1.resource_id = a2.resource_id
          and a2.record_type ='C'
          and a2.percent < l_avl_profile
          and sysdate between a2.start_date and a2.end_date
       UNION
        SELECT min(a1.start_date) available_from
        FROM   pa_res_availability a1
        WHERE  a1.record_type = 'C'
          and  a1.resource_id = p_resource_id
          and  a1.percent >= l_avl_profile
          and  sysdate < (select min(resource_effective_start_date)
                          from pa_resources_denorm res
                          where a1.resource_id = res.resource_id);


BEGIN

   PA_RESOURCE_PVT.end_date := null;

  /* ----------------------------------------------------------
   * comment out the following code because no longer using
   * forecast item and project assignments to get the available
   * from and to

   SELECT min(item_date)
   INTO   l_available_date
   FROM   pa_forecast_items
   WHERE  resource_id          = p_resource_id
   AND    forecast_item_type   = 'U'
   AND    delete_flag          = 'N'
   AND    availability_flag    = 'Y'
   AND    overcommitment_flag  = 'N'
   AND    item_date            >= trunc(sysdate);

   l_start_date := l_available_date;

   /* To get the available end date, we are checking the earliest
   * assigment of the resource, and the start date of this
   * assigment is what we treat as the end date of the resource's
   * availability */

   BEGIN
     IF l_start_date is not null THEN
        select min(start_date)
        into l_end_date
        from pa_project_assignments
        where resource_id = p_resource_id
        and start_date > l_start_date
        and status_code in (select project_status_code
                         from pa_project_statuses
                         where project_system_status_code =
                         'STAFFED_ASGMT_CONF');

        IF l_end_date is null THEN
           -- There is no confirmed assignmented. Current logic is to
           -- keep the end date null
              l_end_date := null;
        END IF;

        IF (l_start_date < trunc(sysdate)) AND (l_end_date < trunc(sysdate)) THEN
           l_start_date := null;
           l_end_date   := null;
        END IF;
      ELSE
        -- l_start_date is null.
        l_end_date := null;
      END IF;

   EXCEPTION
       WHEN OTHERS THEN
          PA_RESOURCE_PVT.end_date := null;
   END;

   ------------------------------------------------- */

   --------------------------------------------------
   -- new code using pa_res_availability begins here
   --------------------------------------------------
   OPEN get_available_from;
   FETCH get_available_from INTO l_start_date;
   CLOSE get_available_from;

   IF l_start_date IS NOT NULL THEN
       l_end_date := PA_RESOURCE_PVT.get_resource_avl_to_date(p_resource_id, l_start_date);
   ELSE
       l_end_date   := null;
   END IF;

   PA_RESOURCE_PVT.end_date := l_end_date;

   RETURN l_start_date;

EXCEPTION
   WHEN OTHERS THEN
      PA_RESOURCE_PVT.end_date := null;
      return null;
END;

FUNCTION Get_End_Date
  (p_resource_id   IN NUMBER)
   RETURN DATE
IS
BEGIN
   RETURN PA_RESOURCE_PVT.end_date;
END;

FUNCTION Get_Start_Date1
  (p_row_label_id    IN NUMBER)
   RETURN DATE
IS
   l_start_date1  DATE;
   l_end_date1    DATE;
   l_scale_type   VARCHAR2(30);
BEGIN
/*  Commneted out for 4890553
     SELECT
     RSCH.START_DATE
       , RSCH.END_DATE
       , RSCH.SCALE_TYPE
       INTO
       l_start_date1,
       l_end_date1,
       l_scale_type
       FROM  PA_RES_SCH_TIME_CHART  RSCH
       WHERE RSCH.ROW_LABEL_ID = p_ROW_LABEL_ID
       AND END_DATE >= to_date('2000-10-23', 'YYYY-MM-DD')
       AND START_DATE <=  to_date('2000-11-26', 'YYYY-MM-DD')
       AND SCALE_TYPE = 'MONTH';*/

     return l_start_date1;

EXCEPTION
   WHEN OTHERS THEN
     PA_RESOURCE_PVT.end_date1  := null;
     PA_RESOURCE_PVT.scale_type := null;
     return null;
END Get_Start_Date1;


FUNCTION Get_End_Date1
  RETURN DATE
IS
BEGIN
   RETURN PA_RESOURCE_PVT.end_date1;
END;

FUNCTION get_scale_type
  RETURN VARCHAR2
IS
BEGIN
   RETURN PA_RESOURCE_PVT.scale_type;
END;


-------------------------------------------------------------------------------+
--
--  PROCEDURE   : Insert_resource_denorm
--  DESCRIPTION : This Procedure inserts the record 'p_resource_denorm_rec'
--                to the table 'PA_RESOURCES_DENORM' after some appropriate
--                validations.
--
--------------------------------------------------------------------------------+
PROCEDURE Insert_resource_denorm
  ( p_resource_denorm_rec  IN    Resource_denorm_Rec_type,
    x_return_status        OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_data             OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count            OUT   NOCOPY NUMBER) --File.Sql.39 bug 4440895
IS
   l_resource_denorm_rec         PA_RESOURCE_PVT.Resource_denorm_Rec_type;
   l_resource_id                 pa_resources_denorm.resource_id%TYPE := NULL;
   l_return_status               VARCHAR2(1);
   l_err_msg_code                fnd_new_messages.message_name%TYPE;
   l_msg_index_out               NUMBER;
   l_rows_exists                 VARCHAR2(1);
BEGIN
   -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_RESOURCE_PVT.Insert_resource_denorm');

   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Save point in case of Roll back
   savepoint RES_PVT_INSERT_RES_DENORM;

   -- the input record to the local variable
   l_resource_denorm_rec := p_resource_denorm_rec;

   --
   -- check if all the required field are not null. If so, display an error message.
   --
   check_required_fields
     ( p_resource_denorm_rec  => l_resource_denorm_rec,
     x_return_status        => l_return_status,
     x_err_msg_code         => l_err_msg_code);

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      pa_utils.add_message
	( p_app_short_name  => 'PA',
	p_msg_name	    => l_err_msg_code);

      RAISE FND_API.G_EXC_ERROR;
   END IF;


   --
   -- Check if the combination of person_id,job_id are already exist. If it does,
   -- do not insert and display an error message instead.
   --
   -- Bug 4350723 - change to where exists to improve performance.

   SELECT 'Y'
     INTO l_rows_exists
     FROM dual
    WHERE EXISTS (SELECT 'Y'
                    FROM pa_resources_denorm
                   WHERE l_resource_denorm_rec.person_id = person_id
                     AND l_resource_denorm_rec.job_id = job_id);

   IF l_rows_exists = 'Y' THEN
      pa_utils.add_message
	( p_app_short_name   => 'PA',
	p_msg_name	     => 'PA_PERSON_ID_JOB_ID_EXIST');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --
   -- Get resource_id for the person_id
   --
   l_resource_id := pa_resource_utils.get_resource_id(l_resource_denorm_rec.person_id);

   IF l_resource_id= -999 OR l_resource_id IS NULL THEN
      pa_utils.add_message
	(p_app_short_name  => 'PA',
	p_msg_name         => 'PA_NO_RESOURCE_ID_FOUND');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Get the resource's person type from HR
   --select decode(current_employee_flag, 'Y', 'EMP', 'CWK')
     --into
     --from per_all_people_f
    --where person_id = l_resource_denorm_rec.person_id
      --and sysdate between effective_start_date and effective_end_date;
   --
   -- insert the record to the table 'PA_RESOURCE_DENORM'
   --
   INSERT into pa_resources_denorm
     (
     PERSON_ID,
     RESOURCE_ID,
     RESOURCE_NAME,
     RESOURCE_TYPE,
     RESOURCE_ORGANIZATION_ID,
     RESOURCE_COUNTRY_CODE,
     RESOURCE_COUNTRY,
     RESOURCE_REGION,
     RESOURCE_CITY,
     JOB_ID,
     RESOURCE_JOB_LEVEL,
     RESOURCE_EFFECTIVE_START_DATE,
     RESOURCE_EFFECTIVE_END_DATE,
     EMPLOYEE_FLAG,
     MANAGER_ID,
     MANAGER_NAME,
     BILLABLE_FLAG,
     UTILIZATION_FLAG,
     SCHEDULABLE_FLAG,
     RESOURCE_ORG_ID,
     REQUEST_ID,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN
     -- ,RESOURCE_PERSON_TYPE
     )
     VALUES
     (
     l_resource_denorm_rec.person_id,
     l_resource_id,
     l_resource_denorm_rec.resource_name,
     l_resource_denorm_rec.resource_type,
     l_resource_denorm_rec.resource_organization_id,
     DECODE(l_resource_denorm_rec.resource_country_code, FND_API.G_MISS_CHAR,
            NULL, l_resource_denorm_rec.resource_country_code),
     DECODE(l_resource_denorm_rec.resource_country, FND_API.G_MISS_CHAR,
            NULL, l_resource_denorm_rec.RESOURCE_COUNTRY),
     DECODE(l_resource_denorm_rec.resource_region, FND_API.G_MISS_CHAR,
            NULL, l_resource_denorm_rec.resource_region),
     DECODE(l_resource_denorm_rec.resource_city, FND_API.G_MISS_CHAR,
            NULL, l_resource_denorm_rec.resource_city),
     DECODE(l_resource_denorm_rec.job_id, FND_API.G_MISS_NUM,
            NULL, l_resource_denorm_rec.job_id),
     DECODE(l_resource_denorm_rec.resource_job_level, FND_API.G_MISS_NUM,
            NULL, l_resource_denorm_rec.resource_job_level),
     l_resource_denorm_rec.resource_effective_start_date,
     DECODE(l_resource_denorm_rec.resource_effective_end_date, FND_API.G_MISS_DATE,
            NULL, l_resource_denorm_rec.resource_effective_end_date),
     l_resource_denorm_rec.employee_flag,
     DECODE(l_resource_denorm_rec.manager_id, FND_API.G_MISS_NUM,
            NULL, l_resource_denorm_rec.manager_id),
     DECODE(l_resource_denorm_rec.manager_name, FND_API.G_MISS_CHAR,
            NULL, l_resource_denorm_rec.manager_name),
     DECODE(l_resource_denorm_rec.billable_flag, FND_API.G_MISS_CHAR,
            NULL, l_resource_denorm_rec.billable_flag),
     DECODE(l_resource_denorm_rec.utilization_flag, FND_API.G_MISS_CHAR,
            NULL, l_resource_denorm_rec.utilization_flag),
     DECODE(l_resource_denorm_rec.schedulable_flag, FND_API.G_MISS_CHAR,
            NULL, l_resource_denorm_rec.schedulable_flag),
     DECODE(l_resource_denorm_rec.resource_org_id, FND_API.G_MISS_NUM,
            NULL,l_resource_denorm_rec.resource_org_id),
     null,               -- REQUEST_ID
     null,               -- PROGRAM_APPLICATION_ID
     null,               -- PROGRAM_ID
     null,               -- PROGRAM_UPDATE_DATE
     sysdate,            -- CREATION_DATE
     fnd_global.user_id, -- CREATED_BY
     sysdate,            -- LAST_UPDATE_DATE
     fnd_global.user_id, -- LAST_UPDATED_BY
     fnd_global.login_id -- LAST_UPDATE_LOGIN
     -- ,l_resource_person_type
     );


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO RES_PVT_INSERT_RES_DENORM;

     x_return_status := FND_API.G_RET_STS_ERROR;

     -- Reset the error stack when returning to the calling program
     PA_DEBUG.Reset_Err_Stack;

     -- get the number of messages
     x_msg_count :=  FND_MSG_PUB.Count_Msg;

     -- Put a message text from message stack into the x_msg_data if there is only
     -- single error.
     IF x_msg_count = 1 THEN
	pa_interface_utils_pub.get_messages
	  (p_encoded       => FND_API.G_TRUE
	  ,p_msg_index     => 1
	  ,p_data          => x_msg_data
	  ,p_msg_index_out => l_msg_index_out);
     END IF;

   WHEN OTHERS THEN
     ROLLBACK TO RES_PVT_INSERT_RES_DENORM;

     -- Set the exception Message and the stack
     FND_MSG_PUB.add_exc_msg
       (p_pkg_name       => 'PA_RESOURCE_PVT.Insert_resource_denorm'
       ,p_procedure_name => PA_DEBUG.G_Err_Stack );

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Insert_resource_denorm;


-----------------------------------------------------------------------------------+
--
--  PROCEDURE  : check_required_fields
--  DESCRIPTION: This procedure checks if the all the required fields in
--               p_resource_denorm_rec are not null
--
-----------------------------------------------------------------------------------+
PROCEDURE check_required_fields
  ( p_resource_denorm_rec IN  Resource_denorm_Rec_type,
    x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_err_msg_code        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_resource_denorm_rec.person_id = FND_API.G_MISS_NUM
     OR p_resource_denorm_rec.resource_name = FND_API.G_MISS_CHAR
     OR p_resource_denorm_rec.resource_type = FND_API.G_MISS_CHAR
     OR p_resource_denorm_rec.resource_organization_id = FND_API.G_MISS_NUM
     OR p_resource_denorm_rec.resource_effective_start_date = FND_API.G_MISS_DATE
     OR p_resource_denorm_rec.employee_flag = FND_API.G_MISS_char  THEN

      x_err_msg_code := 'REQUIRED_FIELD_NULL';
      x_return_status := FND_API.G_RET_STS_ERROR;

   END IF;
END check_required_fields;


-----------------------------------------------------------------------------------+
--
--  PROCEDURE  : Update_resource_denorm
--  DESCRIPTION: This Function updates record(s) in the table
--               'PA_RESOURCES_DENORM' after some appropriate validations.
--
-----------------------------------------------------------------------------------+
PROCEDURE Update_resource_denorm (
				  p_resource_denorm_old_rec  IN  Resource_denorm_Rec_type,
				  p_resource_denorm_new_rec  IN  Resource_denorm_Rec_type,
				  x_return_status            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
				  x_msg_data                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
				  x_msg_count                OUT NOCOPY NUMBER )   --File.Sql.39 bug 4440895
IS
   l_resource_denorm_new_rec   PA_RESOURCE_PVT.Resource_denorm_Rec_type;
   l_resource_id               NUMBER;
   l_exists                    VARCHAR2(1);
   l_return_status             VARCHAR2(1);
   l_err_msg_code              fnd_new_messages.message_name%TYPE;
   l_msg_index_out             NUMBER;

BEGIN
   -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_RESOURCE_PVT.Update_resource_denorm');

   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Save point in case of Roll back
   savepoint RES_PVT_UPDATE_RES_DENORM;

   -- put input record to the local variable
   l_resource_denorm_new_rec := p_resource_denorm_new_rec;

   -------------------------------------------------------------------------
   -- Check if either person_id or job_id has been passed.
   -- Both person_id and job_id should not be null at the same time.
   -------------------------------------------------------------------------
   IF l_resource_denorm_new_rec.person_id = FND_API.G_MISS_NUM AND
     l_resource_denorm_new_rec.job_id = FND_API.G_MISS_num  THEN
      pa_utils.add_message (
	p_app_short_name  => 'PA',
	p_msg_name	  => 'PA_PERSON_ID_JOB_ID_NULL');

      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -------------------------------------------------------------------------
   -- If resource_effective_start_date has been passed, update an individual
   -- record after some appropriate validations.
   -- Since the combination of person_id and resource_effective_start_date is
   -- the primary key in the table 'PA_RESOURCES_DENORM', resource_effective
   -- _start_date should not be null for individual record update.
   -------------------------------------------------------------------------
   IF l_resource_denorm_new_rec.resource_effective_start_date <> FND_API.G_MISS_DATE AND
      l_resource_denorm_new_rec.resource_effective_start_date is not null THEN

      -- Update individual record.
      update_single_res_denorm_rec (
	      p_resource_denorm_rec     => l_resource_denorm_new_rec,
	      x_return_status           => l_return_status,
	      x_err_msg_code            => l_err_msg_code );


      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 pa_utils.add_message
	   ( p_app_short_name  => 'PA',
	   p_msg_name	    => l_err_msg_code);

	 RAISE FND_API.G_EXC_ERROR;
      END IF;

   -------------------------------------------------------------------------
   -- If resource_effective_start_date has not been passed, update multiple
   -- records after some appropriate validations.
   -------------------------------------------------------------------------
   ELSIF l_resource_denorm_new_rec.resource_effective_start_date = FND_API.G_MISS_DATE THEN

      -- If person_id has been passed but not job_id
      IF l_resource_denorm_new_rec.person_id <> FND_API.G_MISS_NUM AND
         l_resource_denorm_new_rec.person_id is not null AND
	 l_resource_denorm_new_rec.job_id = FND_API.G_MISS_NUM THEN

	 -- Update person related multiple records
	 update_person_res_denorm_recs (
	   p_resource_denorm_rec  => l_resource_denorm_new_rec,
	   x_return_status            => l_return_status,
	   x_err_msg_code             => l_err_msg_code );

	   IF l_return_status = FND_API.G_RET_STS_error THEN
	      pa_utils.add_message
		(p_app_short_name  => 'PA',
		p_msg_name	 => l_err_msg_code);

	      RAISE FND_API.G_EXC_ERROR;
	   END IF;

	   -- If job_id has been passed but not person_id, usually update attribute
	   -- job_level or billable_flag on multiple records.
      ELSIF l_resource_denorm_new_rec.person_id = FND_API.G_MISS_NUM
	    AND l_resource_denorm_new_rec.job_id <> FND_API.G_MISS_NUM
            AND l_resource_denorm_new_rec.job_id is not null THEN

	 -- Update job related multiple records.
	 update_job_res_denorm_recs (
	   p_resource_denorm_rec      => l_resource_denorm_new_rec,
	   x_return_status            => l_return_status,
	   x_err_msg_code             => l_err_msg_code );

	 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    pa_utils.add_message (
	      p_app_short_name     => 'PA',
		p_msg_name	   => l_err_msg_code);

	    RAISE FND_API.G_EXC_ERROR;
	 END IF;

      END IF;

   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO RES_PVT_UPDATE_RES_DENORM;

     x_return_status := FND_API.G_RET_STS_ERROR;

     -- Reset the error stack when returning to the calling program
     PA_DEBUG.Reset_Err_Stack;

     -- get the number of messages
     x_msg_count :=  FND_MSG_PUB.Count_Msg;

     -- Put a message text from message stack into the x_msg_data if there is only
     -- single error.
     IF x_msg_count = 1 THEN
	pa_interface_utils_pub.get_messages
	  (p_encoded       => FND_API.G_TRUE
	    ,p_msg_index     => 1
	    ,p_data          => x_msg_data
	    ,p_msg_index_out => l_msg_index_out);
     END IF;

   WHEN OTHERS THEN
     ROLLBACK TO RES_PVT_UPDATE_RES_DENORM;

     -- Set the exception Message and the stack
     FND_MSG_PUB.add_exc_msg
       (p_pkg_name       => 'PA_RESOURCE_PVT.Update_resource_denorm'
       ,p_procedure_name => PA_DEBUG.G_Err_Stack );

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Update_resource_denorm;



---------------------------------------------------------------------------------------
--
--  PROCEDURE  : update_single_res_denorm_rec
--  DESCRIPTION: This procedure updates single record in the table 'PA_RESOURCES_DENORM'.
--
---------------------------------------------------------------------------------------
PROCEDURE update_single_res_denorm_rec(
				       p_resource_denorm_rec  IN  resource_denorm_rec_type,
				       x_return_status        OUT NOCOPY VARCHAR, --File.Sql.39 bug 4440895
				       x_err_msg_code         OUT NOCOPY VARCHAR) --File.Sql.39 bug 4440895
IS
   num_of_rec                 NUMBER;
   l_return_status            VARCHAR2(1);
   l_err_msg_code             fnd_new_messages.message_name%TYPE;

BEGIN
   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- check if the person_id or resource_effective_start_date attribute is not null
   IF p_resource_denorm_rec.person_id = FND_API.G_MISS_NUM OR
     p_resource_denorm_rec.resource_effective_start_date = FND_API.G_MISS_date
   THEN
      x_err_msg_code := 'PA_PERSON_ID_OR_START_DATE_NULL';
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;


   UPDATE pa_resources_denorm
     SET
     resource_type               = DECODE(p_resource_denorm_rec.resource_type, FND_API.G_MISS_CHAR,
                                          resource_type,p_resource_denorm_rec.resource_type),
     resource_organization_id    = DECODE(p_resource_denorm_rec.resource_organization_ID,
                                          FND_API.G_MISS_NUM, resource_organization_id,
                                          p_resource_denorm_rec.resource_organization_id),
     resource_country_code       = DECODE(p_resource_denorm_rec.resource_country_code, FND_API.G_MISS_CHAR,
                                          resource_country_code,p_resource_denorm_rec.resource_country_code),
     resource_country            = DECODE(p_resource_denorm_rec.resource_country, FND_API.G_MISS_CHAR,
                                          resource_country,p_resource_denorm_rec.resource_country),
     resource_region             = DECODE(p_resource_denorm_rec.resource_region, FND_API.G_MISS_CHAR,
                                          resource_region,p_resource_denorm_rec.resource_region),
     resource_city               = DECODE(p_resource_denorm_rec.resource_city, FND_API.G_MISS_CHAR,
                                          resource_city,p_resource_denorm_rec.resource_city),
     job_id                      = DECODE(p_resource_denorm_rec.job_id, FND_API.G_MISS_NUM,
                                          job_id,p_resource_denorm_rec.job_id),
     resource_job_level          = DECODE(p_resource_denorm_rec.resource_job_level, FND_API.G_MISS_NUM,
                                          resource_job_level,p_resource_denorm_rec.resource_job_level),
     resource_effective_end_date = DECODE(p_resource_denorm_rec.resource_effective_end_date,
                                          FND_API.G_MISS_DATE, resource_effective_end_date,
                                          p_resource_denorm_rec. resource_effective_end_date),
     employee_flag               = DECODE(p_resource_denorm_rec.employee_flag, FND_API.G_MISS_CHAR,
                                          employee_flag,p_resource_denorm_rec.employee_flag),
     manager_id                  = DECODE(p_resource_denorm_rec.manager_id, FND_API.G_MISS_NUM,
                                          manager_id,p_resource_denorm_rec.manager_id),
     manager_name                = DECODE(p_resource_denorm_rec.manager_name, FND_API.G_MISS_CHAR,
                                          manager_name,p_resource_denorm_rec.manager_name),
     billable_flag               = DECODE(p_resource_denorm_rec.billable_flag, FND_API.G_MISS_CHAR,
                                          billable_flag,p_resource_denorm_rec.billable_flag),
     utilization_flag            = DECODE(p_resource_denorm_rec.utilization_flag, FND_API.G_MISS_CHAR,
                                          utilization_flag,p_resource_denorm_rec.utilization_flag),
     schedulable_flag            = DECODE(p_resource_denorm_rec.schedulable_flag, FND_API.G_MISS_CHAR,
                                          schedulable_flag,p_resource_denorm_rec.schedulable_flag),
     resource_org_id             = DECODE(p_resource_denorm_rec.resource_org_id, FND_API.G_MISS_NUM,
                                          resource_org_id,p_resource_denorm_rec.resource_org_id),
     LAST_UPDATE_date            = sysdate,
     LAST_UPDATED_by             = fnd_global.user_id,
     LAST_UPDATE_login           = fnd_global.login_id
     WHERE person_id = p_resource_denorm_rec.person_id
     AND resource_effective_start_date = p_resource_denorm_rec.resource_effective_start_date;
     --AND resource_effective_end_date > sysdate;

EXCEPTION
   WHEN OTHERS THEN
     -- Set the exception Message and the stack
     FND_MSG_PUB.add_exc_msg
     (p_pkg_name        => 'PA_RESOURCE_PVT.update_person_res_denorm_recs',
      p_procedure_name  => PA_DEBUG.G_Err_Stack );

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--      RAISE;
END update_single_res_denorm_rec;



------------------------------------------------------------------------------------
--
-- PROCEDURE  : update_person_res_denorm_recs
-- DESCRIPTION: This procedure updates multiple records which are related to a
--              person in the table 'PA_RESOURCES_DENORM'. This procedure usually
--              is used to update resource_name.
--
------------------------------------------------------------------------------------
PROCEDURE update_person_res_denorm_recs
  ( p_resource_denorm_rec  IN  resource_denorm_rec_type,
    x_return_status        OUT NOCOPY VARCHAR,  --File.Sql.39 bug 4440895
    x_err_msg_code         OUT NOCOPY VARCHAR) --File.Sql.39 bug 4440895
IS
   num_of_rec       NUMBER;
   l_return_status  VARCHAR2(1);
BEGIN
   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- check if the person_id or resource_effective_start_date attribute is not null
   IF p_resource_denorm_rec.person_id = FND_API.G_MISS_NUM OR
      p_resource_denorm_rec.person_id is null
   THEN
      x_err_msg_code := 'PA_PERSON_ID_NULL';
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;


   -- Update manager's name if there was an update on manager_name attribute in
   -- this record.
   syncronize_manager_name (
     p_new_resource_denorm_rec  => p_resource_denorm_rec,
     x_return_status            => l_return_status);


   UPDATE pa_resources_denorm
     SET
     resource_name         = DECODE(p_resource_denorm_rec.resource_name, FND_API.G_MISS_CHAR,
                                    resource_name,p_resource_denorm_rec.resource_name),
     resource_country_code = DECODE(p_resource_denorm_rec.resource_country_code, FND_API.G_MISS_CHAR,
                                    resource_country_code,p_resource_denorm_rec.resource_country_code),
     resource_country      = DECODE(p_resource_denorm_rec.resource_country, fnd_API.G_MISS_CHAR,
                                    resource_country,p_resource_denorm_rec.resource_country),
     resource_region       = DECODE(p_resource_denorm_rec.resource_region, FND_API.G_MISS_CHAR,
                                    resource_region,p_resource_denorm_rec.resource_region),
     resource_city         = DECODE(p_resource_denorm_rec.resource_city, FND_API.G_MISS_CHAR,
                                    resource_city,p_resource_denorm_rec.resource_city),
     last_update_date      = sysdate,
     last_updated_by       = fnd_global.user_id,
     last_update_login     = fnd_global.login_id
     WHERE p_resource_denorm_rec.person_id = person_id;

   -- The following code has been commented out because resource name changes
   -- must be done for all resource records and not based on the system date.
   --  AND resource_effective_end_date > sysdate;

EXCEPTION
   WHEN OTHERS THEN

     -- Set the exception Message and the stack
     FND_MSG_PUB.add_exc_msg
     (p_pkg_name       => 'PA_RESOURCE_PVT.update_person_res_denorm_recs'
      ,p_procedure_name => PA_DEBUG.G_Err_Stack );

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END update_person_res_denorm_recs;

------------------------------------------------------------------------------------
--
-- PROCEDURE  : syncronize_manager_name
-- DESCRIPTION: If the resource_name has been updated, we need to syncronize
--              manager_name if he is manager of someone.
--
------------------------------------------------------------------------------------
PROCEDURE syncronize_manager_name
  (p_new_resource_denorm_rec  IN  resource_denorm_rec_type,
   x_return_status            OUT NOCOPY VARCHAR) --File.Sql.39 bug 4440895
IS
   l_old_resource_name  pa_resources_denorm.resource_name%TYPE;
   l_new_resource_name  pa_resources_denorm.resource_name%TYPE := p_new_resource_denorm_rec.resource_name;
   l_name_changed       VARCHAR2(1):='N'; -- 5336386
BEGIN
   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF l_new_resource_name = FND_API.G_MISS_CHAR THEN
      RETURN;
   END IF;


   -- 5336386 : Commented below select and added new
   --SELECT DISTINCT resource_name
   --INTO l_old_resource_name
   --FROM pa_resources_denorm
   --WHERE person_id=p_new_resource_denorm_rec.person_id;

   SELECT 'Y' INTO l_name_changed
   FROM dual
   WHERE exists
      (SELECT 'Y'
       FROM pa_resources_denorm
       WHERE person_id = p_new_resource_denorm_rec.person_id
       AND resource_name <> l_new_resource_name) ;


   --IF l_new_resource_name <> l_old_resource_name THEN  5336386
   IF nvl(l_name_changed, 'N') = 'Y' THEN

      -- if the resource_name has been updated, we need to syncronize manager_name if he
      -- is manager of someone.

      UPDATE pa_resources_denorm
       	 SET manager_name = l_new_resource_name
	      WHERE manager_id = p_new_resource_denorm_rec.person_id;
	        --AND resource_effective_end_date > sysdate;
   END IF;


EXCEPTION
   WHEN OTHERS THEN

     -- Set the exception Message and the stack
     FND_MSG_PUB.add_exc_msg
     (p_pkg_name       => 'PA_RESOURCE_PVT.update_person_res_denorm_recs',
      p_procedure_name => 'PA_RESOURCE_PVT.syncronize_manager_name'); --PA_DEBUG.G_Err_Stack ); 5336386

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END syncronize_manager_name;


------------------------------------------------------------------------------------
-- PROCEDURE  : update_job_res_denorm_recs
-- DESCRIPTION: This procedure update multiple records which are related to a
--              job in the table 'PA_RESOURCES_DENORM'.
------------------------------------------------------------------------------------
PROCEDURE update_job_res_denorm_recs
  (p_resource_denorm_rec  IN  resource_denorm_rec_type,
   p_start_rowid          IN  rowid default NULL,
   p_end_rowid            IN  rowid default NULL,
   x_return_status        OUT NOCOPY VARCHAR, --File.Sql.39 bug 4440895
   x_err_msg_code         OUT NOCOPY VARCHAR ) --File.Sql.39 bug 4440895
IS
BEGIN
   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

	 -- fixed the bug 1559045 here
   UPDATE pa_resources_denorm
     SET
     resource_job_level = DECODE(p_resource_denorm_rec.resource_job_level, FND_API.G_MISS_NUM,
                                 resource_job_level,p_resource_denorm_rec.resource_job_level),
     employee_flag      = DECODE(p_resource_denorm_rec.employee_flag, FND_API.G_MISS_CHAR,
                                 employee_flag, p_resource_denorm_rec.employee_flag),
     billable_flag      = DECODE(p_resource_denorm_rec.billable_flag, FND_API.G_MISS_CHAR,
                                 billable_flag, p_resource_denorm_rec.billable_flag),
     utilization_flag   = DECODE(p_resource_denorm_rec.utilization_flag, FND_API.G_MISS_CHAR,
                                 utilization_flag, p_resource_denorm_rec.utilization_flag),
     schedulable_flag   = DECODE(p_resource_denorm_rec.schedulable_flag, FND_API.G_MISS_CHAR,
                                schedulable_flag, p_resource_denorm_rec.schedulable_flag),
     last_update_date   = sysdate,
     last_updated_by    = fnd_global.user_id,
     last_update_login  = fnd_global.login_id
     WHERE p_resource_denorm_rec.job_id = job_id
       AND rowid between nvl(p_start_rowid, rowid)
                     and nvl(p_end_rowid, rowid);

EXCEPTION
   WHEN OTHERS THEN
     -- Set the exception Message and the stack
     FND_MSG_PUB.add_exc_msg
     (p_pkg_name       => 'PA_RESOURCE_PVT.update_person_res_denorm_recs'
      ,p_procedure_name => PA_DEBUG.G_Err_Stack );

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      RAISE;
END update_job_res_denorm_recs;


------------------------------------------------------------------------------------
--
-- PROCEDURE  : delete_resource_denorm
-- DESCRIPTION: This procedure deletes a record in the table 'PA_RESOURCES_DENORM'.
--
------------------------------------------------------------------------------------
PROCEDURE delete_resource_denorm
  ( p_person_id                  IN   pa_resources_denorm.person_id%type,
    p_res_effective_start_date   IN   pa_resources_denorm.resource_effective_start_date%type,
    x_return_status              OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_data                   OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count                  OUT   NOCOPY NUMBER) --File.Sql.39 bug 4440895
IS
--   l_manager_id       pa_resources_denorm.manager_id%TYPE;
--   l_msg_index_out    NUMBER;
--   l_return_status    VARCHAR2(1);
--   l_err_msg_code     fnd_new_messages.message_name%TYPE;

BEGIN
   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   DELETE FROM PA_RESOURCES_DENORM
   WHERE person_id = p_person_id
     AND resource_effective_start_date = p_res_effective_start_date
     AND resource_effective_end_date > trunc(sysdate);


EXCEPTION
   WHEN OTHERS THEN
     -- Set the exception Message and the stack
     FND_MSG_PUB.add_exc_msg
     ( p_pkg_name       => 'PA_RESOURCE_PVT.delete_resource_denorm'
      ,p_procedure_name => PA_DEBUG.G_Err_Stack );

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END delete_resource_denorm;

 ------------------------------------------------------------------------------------
-- Bug#6875286
-- Procedure    : GET_ALL_JOB_INFO
-- DESCRIPTION: This procedure gets the value of three flags:
-- l_billable_flag, l_utilization_flag and l_schedulable_flag
--
--
------------------------------------------------------------------------------------
PROCEDURE Get_All_Job_Info (p_job_id IN NUMBER
                           ,x_billable_flag OUT NOCOPY VARCHAR2
                           ,x_utilization_flag OUT NOCOPY  VARCHAR2
                           ,x_schedulable_flag OUT NOCOPY  VARCHAR2
                           ) IS

l_job_info_type     VARCHAR2(20)  := 'Job Category';
l_billable_flag          pa_resources_denorm.billable_flag%TYPE;
l_utilization_flag       pa_resources_denorm.utilization_flag%TYPE;
l_schedulable_flag       pa_resources_denorm.schedulable_flag%TYPE;


 BEGIN

 l_billable_flag := 'N';
 l_utilization_flag := 'N';
 l_schedulable_flag := 'N';


SELECT jei_information2, jei_information3,jei_information6
  INTO l_billable_flag, l_utilization_flag, l_schedulable_flag
  FROM per_job_extra_info
  WHERE job_id = p_job_id
  AND information_type = l_job_info_type;

IF l_billable_flag IS NULL THEN
  l_billable_flag := 'N';
END IF ;

IF l_utilization_flag IS NULL THEN
  l_utilization_flag := 'N';
END IF ;

IF l_schedulable_flag IS NULL THEN
  l_schedulable_flag := 'N';
END IF ;

x_billable_flag := l_billable_flag;
x_utilization_flag :=  l_utilization_flag;
x_schedulable_flag :=  l_schedulable_flag;


 EXCEPTION
  WHEN TOO_MANY_ROWS THEN
      l_utilization_flag := 'X';
      l_billable_flag := 'X';
      l_schedulable_flag := 'X';
     x_billable_flag := l_billable_flag;
x_utilization_flag :=  l_utilization_flag;
x_schedulable_flag :=  l_schedulable_flag;

WHEN NO_DATA_FOUND THEN
l_utilization_flag :='N';
l_billable_flag := 'N';
l_schedulable_flag := 'N';
x_billable_flag := l_billable_flag;
x_utilization_flag :=  l_utilization_flag;
x_schedulable_flag :=  l_schedulable_flag;

WHEN OTHERS THEN
NULL ;

END Get_All_Job_Info;

-- end bug#6875286


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
                                      , p_request_id               IN  NUMBER
                                      , p_program_application_id   IN  NUMBER
                                      , p_program_id               IN  NUMBER
                                      , p_commit                   IN  VARCHAR2
                                      , p_validate_only            IN  VARCHAR2
                                      , x_msg_data                 OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                                      , x_msg_count                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                      , x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      ) IS

  l_resource_country_code  pa_resources_denorm.resource_country_code%TYPE;
  l_resource_country       pa_resources_denorm.resource_country%TYPE;
  l_resource_region        pa_resources_denorm.resource_region%TYPE;
  l_resource_city          pa_resources_denorm.resource_city%TYPE;
  l_resource_job_level     pa_resources_denorm.resource_job_level%TYPE;
  l_employee_flag          pa_resources_denorm.employee_flag%TYPE;
  l_billable_flag          pa_resources_denorm.billable_flag%TYPE;
  l_utilization_flag       pa_resources_denorm.utilization_flag%TYPE;
  l_schedulable_flag       pa_resources_denorm.schedulable_flag%TYPE;
  l_return_status	   VARCHAR2(1);
  l_error_msg_code	   VARCHAR2(2000);
  l_msg_count              NUMBER;
  l_first_time             VARCHAR2(1) := 'Y';
  l_null_location          VARCHAR2(1) := 'N';
  l_rec_start_date         pa_resources_denorm.resource_effective_start_date%TYPE;
  l_rec_end_date           pa_resources_denorm.resource_effective_end_date%TYPE;


  CURSOR denormalized_locations (l_person_id IN NUMBER, l_asgn_start_date IN DATE, l_asgn_end_date IN DATE ) IS
      SELECT date_from,
             date_to
      FROM   per_addresses
      WHERE  person_id                        = l_person_id
      AND    date_from                       <= l_asgn_end_date
      AND    nvl(date_to, l_asgn_end_date)   >= l_asgn_start_date
      AND    primary_flag                     = 'Y'
      ORDER BY date_from
  ;

  location_rec denormalized_locations%ROWTYPE;
  l_msg_index_out       NUMBER; -- bug 5689674

BEGIN


    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- The delete logic deletes all overlapping records in pa_resources_denorm
    -- for the incoming assignment record
    -- This logic also works with location denormalization changes.
    DELETE FROM  pa_resources_denorm
        WHERE  person_id                      = p_resource_source_id
        AND    resource_effective_start_date <= p_assignment_end_date
        AND    resource_effective_end_date   >= p_assignment_start_date
    ;

    -- Get common attributes for this HR assignment

       -- get thre resource's job level
    l_resource_job_level := PA_HR_UPDATE_API.Get_Job_Level(
                                           p_job_id => p_resource_job_id,
                                           p_job_group_id => p_resource_job_group_id);


   /*  Start of commented code for bug#6875286
   Reason to do so:
   =================
   Instead  of deriving billable_flag, utilization_flag and schedulable_flag
   from table per_job_extra_info in three different hits, wrote a procedure to directly query
   these 3 flags. This would reduce the hits to the table from 3 to 1 and thus improve the performance.

    -- get the resource's billable flag
   l_billable_flag := PA_HR_UPDATE_API.check_job_billability(
                                           p_job_id => p_resource_job_id,
                                           p_person_id => p_resource_source_id,
                                           p_date => p_assignment_start_date);


   -- get the resource's utilization flag
    l_utilization_flag := PA_HR_UPDATE_API.check_job_utilization(
                                           p_job_id => p_resource_job_id,
                                           p_person_id => p_resource_source_id,
                                           p_date => p_assignment_start_date);

    -- get the resource's job schedulable flag
    l_schedulable_flag := PA_HR_UPDATE_API.check_job_schedulable
                                          (p_job_id => p_resource_job_id);

    End of commented code for bug#6875286 */

    -- Start of code change for bug#6875286

       get_all_job_info(p_job_id => p_resource_job_id
                       ,x_billable_flag => l_billable_flag
                       ,x_utilization_flag => l_utilization_flag
                       ,x_schedulable_flag => l_schedulable_flag );

    -- End of code change for bug#6875286

    /* Bug 2898766 - Raise an exception if the information type attached to this job
      contains multiple rows */

    IF (l_billable_flag = 'X') OR (l_resource_job_level = -99) OR
       (l_utilization_flag = 'X') OR (l_schedulable_flag='X') THEN
       /* Bug 5689674: Added code to pass the error message to make the
          FND_API.G_EXC_ERROR being raised a generic call for any excpetion. */

       PA_UTILS.Add_Message(
               p_app_short_name => 'PA'
              ,p_msg_name       => 'PA_MULT_INF_TYPES_FOR_JOB');
	/* End of changes Bug for 5689674 */
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* Bug 2898766 - End */

    -- Set the employee flag according to the resource type
    IF p_resource_type = 'EMPLOYEE' THEN
      	 l_employee_flag:= 'Y';
    ELSE
      	 l_employee_flag:= 'N';
    END IF;

    -- Location denormalization changes involve the following
    -- Code loops through all the different location records of a HR assignment
    -- and creates 1 record in pa_resources_denorm for every different location
    -- of a HR assignment
    OPEN denormalized_locations(p_resource_source_id, p_assignment_start_date, p_assignment_end_date);

    LOOP
     	FETCH denormalized_locations INTO location_rec;


        IF l_first_time = 'Y' THEN
          --dbms_output.put_line('First time in loop');
	  --dbms_output.put_line('p_assignment_start_date:' ||  p_assignment_start_date);
	  --dbms_output.put_line('p_assignment_end_date:' || p_assignment_end_date);

          -- Null location record must be populated under the following conditions
          -- 1. If no location record is found during this assignment
          -- 2. If no location record in the beginning of this assignment

        	IF denormalized_locations%NOTFOUND THEN
               	--dbms_output.put_line('No record for location');
                l_null_location := 'Y';
                l_rec_end_date := p_assignment_end_date;
         ELSIF location_rec.date_from > p_assignment_start_date THEN
                --dbms_output.put_line('First null location record');
                l_null_location := 'Y';
                l_rec_end_date := location_rec.date_from - 1;
         END IF;

            IF l_null_location = 'Y' THEN

            	l_rec_start_date := p_assignment_start_date;

                        INSERT INTO PA_RESOURCES_DENORM ( person_id
                                      , resource_id
                                      , resource_name
                                      , resource_type
                                      , resource_org_id
                                      , resource_organization_id
                                      , resource_country_code
                                      , resource_country
                                      , resource_region
                                      , resource_city
                                      , resource_job_level
                                      , resource_effective_start_date
                                      , resource_effective_end_date
                                      , employee_flag
                                      , manager_id
                                      , manager_name
                                      , billable_flag
                                      , job_id
                                      , utilization_flag
                                      , schedulable_flag
                                      , request_id
                                      , program_application_id
                                      , program_id
                                      , program_update_date
                                      , creation_date
                                      , created_by
                                      , last_update_date
                                      , last_updated_by
                                      , last_update_login
                                      , resource_person_type
                                      )
                              SELECT    p_resource_source_id
                                      , p_resource_id
                                      , p_resource_name
                                      , p_resource_type
                                      , p_resource_org_id
                                      , p_resource_organization_id
                                      , l_resource_country_code
                                      , l_resource_country
                                      , l_resource_region
                                      , l_resource_city
                                      , l_resource_job_level
                                      , l_rec_start_date
                                      , l_rec_end_date
                                      , l_employee_flag
                                      , p_manager_id
                                      , p_manager_name
                                      , l_billable_flag
                                      , p_resource_job_id
                                      , l_utilization_flag
                                      , l_schedulable_flag
                                      , p_request_id
                                      , p_program_application_id
                                      , p_program_id
                                      , sysdate
                                      , sysdate
/*----- Bug 1992257 commented
                                      , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                      , sysdate
                                      , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                      , TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'))
        End of Comment, added next 4 lines */
                                      , TO_NUMBER(FND_GLOBAL.USER_ID)
                                      , sysdate
                                      , TO_NUMBER(FND_GLOBAL.USER_ID)
                                      , TO_NUMBER(FND_GLOBAL.LOGIN_ID)
                                      , p_person_type
                                FROM  dual;
                  --end null location
                  END IF;
        -- end first time
        END IF;

        l_first_time := 'N';

        EXIT WHEN denormalized_locations%NOTFOUND;


        -- Initialize the start and end dates and location of the location defined resource records

        IF location_rec.date_from <= p_assignment_start_date THEN
            l_rec_start_date := p_assignment_start_date;
        ELSE
            l_rec_start_date := location_rec.date_from;
        END IF;

        IF location_rec.date_to IS NULL THEN
		          l_rec_end_date := p_assignment_end_date;
        ELSIF location_rec.date_to >= p_assignment_end_date THEN
 											l_rec_end_date := p_assignment_end_date;
	       ELSE
								    l_rec_end_date := location_rec.date_to;
								END IF;

								--dbms_output.put_line('p_start_date:' ||  l_rec_start_date);
								--dbms_output.put_line('p_end_date:' || l_rec_end_date);


        --get the resources locations details
    	PA_LOCATION_UTILS.Get_EMP_Location_Details(p_person_id      => p_resource_source_id,
                                               p_assign_date        => l_rec_start_date,
                                               x_country_name       => l_resource_country,
                                               x_city               => l_resource_city,
                                               x_region             => l_resource_region,
                                               x_country_code       => l_resource_country_code,
                                               x_return_status      => l_return_status,
                                               x_error_message_code => l_error_msg_code);

	/* Bug 5689674: Added the below exception handling to throw an error without
	   proceeding on inserting into pa_resources_denorm. This will show the
	   error as an exception in the report output. */
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
		IF l_error_msg_code IS NOT NULL THEN
		     pa_utils.add_message
      		      ( p_app_short_name   => 'PA',
			p_msg_name	   => l_error_msg_code);
		END IF;
	       RAISE FND_API.G_EXC_ERROR;
	END IF;
	/* End of changes for Bug 5689674 */

     	INSERT INTO PA_RESOURCES_DENORM ( person_id
                                      , resource_id
                                      , resource_name
                                      , resource_type
                                      , resource_org_id
                                      , resource_organization_id
                                      , resource_country_code
                                      , resource_country
                                      , resource_region
                                      , resource_city
                                      , resource_job_level
                                      , resource_effective_start_date
                                      , resource_effective_end_date
                                      , employee_flag
                                      , manager_id
                                      , manager_name
                                      , billable_flag
                                      , job_id
                                      , utilization_flag
                                      , schedulable_flag
                                      , request_id
                                      , program_application_id
                                      , program_id
                                      , program_update_date
                                      , creation_date
                                      , created_by
                                      , last_update_date
                                      , last_updated_by
                                      , last_update_login
                                      , resource_person_type
                                      )
                              SELECT    p_resource_source_id
                                      , p_resource_id
                                      , p_resource_name
                                      , p_resource_type
                                      , p_resource_org_id
                                      , p_resource_organization_id
                                      , l_resource_country_code
                                      , l_resource_country
                                      , l_resource_region
                                      , l_resource_city
                                      , l_resource_job_level
                                      , l_rec_start_date
                                      , l_rec_end_date
                                      , l_employee_flag
                                      , p_manager_id
                                      , p_manager_name
                                      , l_billable_flag
                                      , p_resource_job_id
                                      , l_utilization_flag
                                      , l_schedulable_flag
                                      , p_request_id
                                      , p_program_application_id
                                      , p_program_id
                                      , sysdate
                                      , sysdate
/*----- Bug 1992257 commented
                                      , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                      , sysdate
                                      , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                      , TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'))
        End of Comment, added next 4 lines */
                                      , TO_NUMBER(FND_GLOBAL.USER_ID)
                                      , sysdate
                                      , TO_NUMBER(FND_GLOBAL.USER_ID)
                                      , TO_NUMBER(FND_GLOBAL.LOGIN_ID)
                                      , p_person_type
                                FROM  dual;
     END LOOP;

     CLOSE denormalized_locations;

     x_msg_count := FND_MSG_PUB.Count_Msg;

     IF x_msg_count > 0 THEN

       x_return_status := FND_API.G_RET_STS_ERROR;

     END IF;

     IF p_commit = FND_API.G_TRUE AND l_msg_count=0 THEN

     	 COMMIT;

     END IF;

EXCEPTION
    /* Bug 2898766 - save the error message in the pa_reporting_exceptions table */

    WHEN FND_API.G_EXC_ERROR THEN
       /* Bug 5689674: Modified the code to make the exception handling generic. */

       x_return_status := FND_API.G_RET_STS_ERROR;

       -- Reset the error stack when returning to the calling program
       PA_DEBUG.Reset_Err_Stack;

       -- get the number of messages
       x_msg_count :=  FND_MSG_PUB.Count_Msg;

       -- Put a message text from message stack into the x_msg_data if there is only
       -- single error.
       IF x_msg_count = 1 THEN
	 pa_interface_utils_pub.get_messages
	   (p_encoded       => FND_API.G_TRUE
	   ,p_msg_index     => 1
	   ,p_data          => x_msg_data
	   ,p_msg_index_out => l_msg_index_out);
       END IF;
       /* End of Changes for Bug 5689674*/

     /* p_context10      =>  'REJECTED'  Added for bug 4172140*/
       PA_MESSAGE_UTILS.save_messages(
 	                         p_request_id     =>  p_request_id
                                ,p_source_Type1   =>  'RESOURCE_PULL'
                                ,p_source_Type2	  =>  'PARCPRJR'
                                ,p_context1       =>  p_resource_source_id
                                ,p_context2       =>  substrb(p_resource_name, 1, 30)  --Changed substr to substrb for bug4584297
                                ,p_context3       =>  p_resource_organization_id
				,p_context10      =>  'REJECTED'
                                ,p_date_context1  =>  p_assignment_start_date
                                ,p_date_context2  =>  p_assignment_end_date
                                ,p_commit         =>  p_commit
                                ,x_return_status  =>  l_return_status);
    /* Bug 2898766 - End */
    WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_RESOURCE_PVT.Populate_Resources_Denorm'
                              , p_procedure_name => PA_DEBUG.G_Err_Stack);
      x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;

END Populate_Resources_Denorm;


------------------------------------------------------------------------------------
--
-- FUNCTION   : Get_Manager_Id
-- DESCRIPTION: This function gets the manager_id for a given project. It returns
--              null if there is no manager. Also sets the following global variables
--              g_manager_name - manager name
--              g_manager_resource_id - manager's resource_id from pa_resources_denorm
--              This API is used specifically in views pa_project_open_assns_v
--              and pa_project_open_assns_staff_v
--
------------------------------------------------------------------------------------
FUNCTION Get_Manager_Id(
p_project_id		IN	NUMBER)
RETURN NUMBER
IS
l_party_id       NUMBER;
BEGIN
  SELECT parties.resource_source_id
  INTO l_party_id
  from   pa_project_parties          parties
  where  parties.project_role_id        = 1
  AND  parties.project_id             = p_project_id
  AND  trunc(sysdate) between  parties.start_date_active AND  NVL(parties.end_date_active,trunc(sysdate) + 1)--;
-- start --    18-AUG-2008       cklee               Fixed bug: 6708404
 and object_id = p_project_id
 and object_type = 'PA_PROJECTS'
 and resource_type_id = 101;
-- end --    18-AUG-2008       cklee               Fixed bug: 6708404

   select resource_name
   into   g_manager_name
   from   pa_resources_denorm
   where  person_id = l_party_id
   and    trunc(sysdate) between resource_effective_start_date and resource_effective_end_date;

   select resource_id
   into   g_manager_resource_id
   from   pa_resources_denorm
   where  person_id = l_party_id
   and     trunc(sysdate) between resource_effective_start_date and resource_effective_end_date;

    g_project_id := p_project_id; /* Bug#2604495 Setting the Global variable's value */

  RETURN l_party_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
      g_manager_name := null;
      g_manager_resource_id := null;
      g_project_id := null;  /* Bug#2604495 Setting the global variable as null if no data found occurs*/
      RETURN NULL;
END;

------------------------------------------------------------------------------------
--
-- FUNCTION   : Get_Manager_Name
-- DESCRIPTION: This function gets the manager_name from the global variable
--              g_manager_name - manager name
--              This API is used specifically in views pa_project_open_assns_v
--              and pa_project_open_assns_staff_v
--
------------------------------------------------------------------------------------
FUNCTION Get_Manager_Name(p_project_id in number DEFAULT null) /*Bug#2604495-Added the parameter p_project_id to the function */
RETURN VARCHAR2
is
l_party_id number(15);  /* 2604495-Added local variable */
BEGIN
/* code for bug#2604495 starts */

if p_project_id = g_project_id then
null;
else
l_party_id := get_manager_id(p_project_id);
end if;

/* Code for bug#2604495 ends */
RETURN g_manager_name;
END;

------------------------------------------------------------------------------------
--
-- FUNCTION   : Get_Manager_Resource_Id
-- DESCRIPTION: This function gets the manager's resource_id from the global variable
--              g_manager_resource_id - manager's resource_id
--              This API is used specifically in views pa_project_open_assns_v
--              and pa_project_open_assns_staff_v
--
------------------------------------------------------------------------------------
FUNCTION Get_Manager_Resource_Id
RETURN NUMBER
IS
BEGIN
RETURN g_manager_resource_id;
END;

------------------------------------------------------------------------------------
--
-- FUNCTION   : Get_Resource_Avl_to_date
-- DESCRIPTION: This function gets the resource available to date for staffing
--              home view objects. This function is modified for PA.K using a new
--              data model (PA_RES_AVAILABILITY) to get availability information.
--
------------------------------------------------------------------------------------
FUNCTION Get_Resource_Avl_To_Date (p_resource_id   IN NUMBER,
                                   p_avl_from_date IN DATE)
RETURN DATE
IS
   l_avl_to_date DATE;
   l_avl_profile     NUMBER := FND_NUMBER.CANONICAL_TO_NUMBER(fnd_profile.value('PA_RES_CAPACITY_PERCENTAGE')); -- 4725606
BEGIN

   IF p_avl_from_date is not null THEN

        select min(start_date)-1
        into l_avl_to_date
        from pa_res_availability
        where resource_id = p_resource_id
          and record_type = 'C'
          and start_date  > p_avl_from_date
          -- Commented for 4725606 and percent     < FND_NUMBER.CANONICAL_TO_NUMBER(fnd_profile.value('PA_RES_CAPACITY_PERCENTAGE'));
          and percent <  l_avl_profile ; -- 4725606

   ELSE
      l_avl_to_date := null;
   END IF;

   -- we do not want to show 31-Dec-4712 as the available to date
   -- so perform the following logic to show it as null instead
   IF l_avl_to_date IS NOT NULL THEN
      IF to_char(l_avl_to_date, 'DD-MM-YYYY') = '31-12-4712' THEN
         l_avl_to_date := null;
      END IF;
   END IF;


   RETURN l_avl_to_date;

EXCEPTION
    WHEN OTHERS THEN
       RETURN null;
END;

------------------------------------------------------------------------------------
--
-- FUNCTION   : Get_Resource_ovc_to_date
-- DESCRIPTION: This function gets the resource overcommited to date for staffing
--              home view objects. This function is modified for PA.K using a new
--              data model (PA_RES_AVAILABILITY) to get overcommitment information.
--
------------------------------------------------------------------------------------
FUNCTION Get_Resource_Ovc_To_Date (p_resource_id   IN NUMBER,
                                   p_ovc_from_date IN DATE)
RETURN DATE
IS
   l_ovc_to_date DATE;
   l_ovc_profile     NUMBER := FND_NUMBER.CANONICAL_TO_NUMBER(fnd_profile.value('PA_OVERCOMMITMENT_PERCENTAGE')); -- 4725606
BEGIN

   IF p_ovc_from_date is not null THEN
       select min(start_date)-1
       into l_ovc_to_date
       from pa_res_availability
       where resource_id   = p_resource_id
          and record_type  = 'C'
          and start_date   > p_ovc_from_date
          -- Commented for 4725606 and -1 * percent < FND_NUMBER.CANONICAL_TO_NUMBER(fnd_profile.value('PA_OVERCOMMITMENT_PERCENTAGE'));
          and  -1 * percent < l_ovc_profile ; -- 4725606
   ELSE
       l_ovc_to_date := null;
   END IF;

   -- we do not want to show 31-Dec-4712 as the available to date
   -- so perform the following logic to show it as null instead
   IF l_ovc_to_date IS NOT NULL THEN
      IF to_char(l_ovc_to_date, 'DD-MM-YYYY') = '31-12-4712' THEN
         l_ovc_to_date := null;
      END IF;
   END IF;


   RETURN l_ovc_to_date;

EXCEPTION
    WHEN OTHERS THEN
       RETURN null;
END;

------------------------------------------------------------------------------------
--
-- FUNCTION   : Get_Resource_ovc_hours
-- DESCRIPTION: This function gets the resource overcommited hours for the given
--              from and to dates using pa_res_availability table.
--
------------------------------------------------------------------------------------
FUNCTION Get_Resource_Ovc_hours(p_resource_id   IN NUMBER,
                                p_ovc_from_date IN DATE,
                                p_ovc_to_date   IN DATE)
RETURN NUMBER
IS
   l_ovc_hours   NUMBER;
BEGIN

   IF p_ovc_from_date is null OR p_ovc_to_date is null THEN
        l_ovc_hours := null;
   ELSE
        -- have to multiply by -1 since we store overcommitment as
        -- negative availability
        select sum(hours) * -1
        into l_ovc_hours
        from pa_res_availability
        where resource_id       = p_resource_id
        and   record_type       = 'C'
        and   start_date       >= p_ovc_from_date
        and   end_date         <= p_ovc_to_date;
   END IF;

   RETURN l_ovc_hours;

EXCEPTION
    WHEN OTHERS THEN
       RETURN null;
END;


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
                                    ,p_manager_id      IN  NUMBER
                                    ,p_org_name        IN  VARCHAR2
                                    ,p_org_id          IN  NUMBER
                                    ,p_responsibility  IN  VARCHAR2
                                    ,p_check           IN  VARCHAR2
                                    ,x_manager_id      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                    ,x_org_id          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                    ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                    ,x_msg_count       OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                    ,x_msg_data        OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
     l_return_status       VARCHAR2(1);
     l_msg_data            VARCHAR2(2000);
     l_error_message_code  fnd_new_messages.message_name%TYPE;
     l_resource_type_id    NUMBER;
     l_msg_index_out       NUMBER;
     l_msg_count           NUMBER;
BEGIN

     -- initialize error stack
     fnd_msg_pub.initialize;

     -- set return status to Success
     x_return_status :=  FND_API.G_RET_STS_SUCCESS;

     IF(p_org_name IS NOT NULL) THEN
          -- check whether organization name is valid
          PA_HR_ORG_UTILS.Check_OrgName_Or_Id (
               p_organization_id   => p_org_id,
               p_organization_name => p_org_name,
               p_check_id_flag     => PA_STARTUP.G_Check_ID_Flag,
               x_organization_id   => x_org_id,
               x_return_status     => l_return_status,
               x_error_msg_code    => l_error_message_code);

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               PA_UTILS.Add_Message (
                    p_app_short_name => 'PA'
                   ,p_msg_name       => l_error_message_code );
          END IF;
     ELSE
          x_org_id := NULL;
     END IF;

     IF(p_manager_name IS NOT NULL) THEN

          -- validate whether the manager name entered or selected in the LOV
          -- exists in the corresponding view depending on user's responsibility
          PA_RESOURCE_UTILS.Check_ManagerName_Or_Id(
               p_manager_name       => p_manager_name
              ,p_manager_id         => p_manager_id
              ,p_responsibility     => p_responsibility
              ,p_check              => p_check
              ,x_manager_id         => x_manager_id
              ,x_msg_count          => l_msg_count
              ,x_return_status      => l_return_status
              ,x_error_message_code => l_error_message_code);

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.Add_Message(
                    p_app_short_name => 'PA'
                   ,p_msg_name       => l_error_message_code);
          END IF;
      ELSE
          x_manager_id := NULL;
      END IF;

      x_msg_count := FND_MSG_PUB.Count_Msg;

      IF x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                               ,p_msg_index     => 1
                                               ,p_data          => x_msg_data
                                               ,p_msg_index_out => l_msg_index_out);
      END IF;

      IF x_msg_count <> 0 THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

EXCEPTION
     WHEN OTHERS THEN
        x_manager_id := NULL;
        x_org_id     := NULL;
        x_return_status  := FND_API.G_RET_STS_ERROR;
END Validate_Staff_Filter_Values;

FUNCTION  get_res_conf_availability( p_resource_id          IN      NUMBER,
                                     p_start_date           IN      DATE,
                                     p_end_date             IN      DATE)
RETURN NUMBER
IS
l_conf_availability        NUMBER;

BEGIN


  BEGIN

     SELECT sum(nvl(capacity_quantity,0) - nvl(confirmed_qty,0))
     INTO   l_conf_availability
     FROM   pa_forecast_items
     WHERE  resource_id      = p_resource_id
     AND    delete_flag      = 'N'
     AND    forecast_item_type = 'U'
     AND    item_date  between p_start_date
                       and     p_end_date;
  EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_conf_availability := 0;
  END;


   RETURN l_conf_availability;
EXCEPTION
   WHEN OTHERS THEN
        RETURN 0;
END get_res_conf_availability;

FUNCTION  get_res_prov_conf_availability( p_resource_id          IN      NUMBER,
                                          p_start_date           IN      DATE,
                                          p_end_date             IN      DATE)
RETURN NUMBER
IS
l_prov_conf_availability        NUMBER;

BEGIN


  BEGIN

     SELECT sum(nvl(capacity_quantity,0) - nvl(confirmed_qty,0) - nvl(provisional_qty,0))
     INTO   l_prov_conf_availability
     FROM   pa_forecast_items
     WHERE  resource_id      = p_resource_id
     AND    delete_flag      = 'N'
     AND    forecast_item_type = 'U'
     AND    item_date  between p_start_date
                       and     p_end_date;
  EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_prov_conf_availability := 0;
  END;


   RETURN l_prov_conf_availability;
EXCEPTION
   WHEN OTHERS THEN
        RETURN 0;
END get_res_prov_conf_availability;

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
  p_resource_id    IN NUMBER,
  p_cstart_date    IN DATE,
  p_cend_date      IN DATE,
  p_bstart_date    IN DATE,
  p_bend_date      IN DATE,
  x_return_status OUT   NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

--l_profile varchar2(30) := 'DAILY';
l_created_by number;
l_last_updated_by number;
l_last_update_login number;
l_start_date date;
l_end_date date;
l_percent number := -1;
l_earliest_start_date date;
l_rec_count number:= 0;

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_created_by        := fnd_global.user_id;
  l_last_updated_by   := fnd_global.user_id;
  l_last_update_login := fnd_global.login_id;

-- commented out for perf bug 4930256
-- l_profile := FND_PROFILE.VALUE_SPECIFIC('PA_AVAILABILITY_CAL_PERIOD');

  --Dynamic SQL is being used as Oracle 8i PL/SQL does not support
  --Analytic functions

  IF l_profile = 'DAILY' THEN

    --For Confirmed Availability/Overcommittment
/* Commented dynamix SQL and replaced with bind variables for Bug #3964268
    execute immediate
    'insert into PA_RES_AVAILABILITY
    ( start_date,
      end_date,
      percent,
      record_type,
      resource_id,
      hours,
      creation_date,
      last_update_date,
      created_by,
	  last_updated_by,
      last_update_login
    )
    select item_date,
         (lead(item_date) over(order by item_date)) - 1,
         c * 100 ,
         ' || '''C''' ||
         ' , resource_id,
         pa_resource_pvt.get_res_conf_availability(resource_id, nvl(item_date,' || '''' || p_cstart_date || ''''||  '),
         nvl((lead(item_date) over(order by item_date)),' || '''' || p_cend_date || ''''||  ') - 1),
         sysdate,
         sysdate,
         ' || l_created_by || ',
         ' || l_last_updated_by || ',
         ' || l_last_update_login || '
    from (  select (nvl(capacity_quantity,0) - nvl(confirmed_qty,0))/nvl(capacity_quantity,0) a,
                    lag((nvl(capacity_quantity,0) - nvl(confirmed_qty,0))/nvl(capacity_quantity,0),1,1000) -- bug 3229929
		               over ( order by item_date) as b,
                   (nvl(capacity_quantity,0) - nvl(confirmed_qty,0))/capacity_quantity c,
                   item_date,
                   resource_id
            from pa_forecast_items
            where forecast_item_type = ' || '''U''' ||
            ' and resource_id = ' || p_resource_id || '
            and capacity_quantity > 0
            and delete_flag = ' || '''N''' || '
            and item_date  between ' || '''' || p_cstart_date || '''' || ' and ' ||
                '''' || p_cend_date || ''''||  ')
    where nvl(a,0) - nvl(b,0) <> 0';
*/
/* Modified the above commented SQL as below for Bug #3964268 with bind variables */
    execute immediate
    'insert into PA_RES_AVAILABILITY
    ( start_date,
      end_date,
      percent,
      record_type,
      resource_id,
      hours,
      creation_date,
      last_update_date,
      created_by,
	  last_updated_by,
      last_update_login
    )
    select item_date,
         (lead(item_date) over(order by item_date)) - 1,
         c * 100 ,
         :c,
         resource_id,
         pa_resource_pvt.get_res_conf_availability(resource_id, nvl(item_date, :cstart_date ),
         nvl((lead(item_date) over(order by item_date)), :cend_date ) - 1),
         sysdate,
         sysdate,
         :created_by,
         :last_updated_by,
         :last_update_login
    from (  select (nvl(capacity_quantity,0) - nvl(confirmed_qty,0))/nvl(capacity_quantity,0) a,
                    lag((nvl(capacity_quantity,0) - nvl(confirmed_qty,0))/nvl(capacity_quantity,0),1,1000) -- bug 3229929
		               over ( order by item_date) as b,
                   (nvl(capacity_quantity,0) - nvl(confirmed_qty,0))/capacity_quantity c,
                   item_date,
                   resource_id
            from pa_forecast_items
            where forecast_item_type = :u
            and resource_id = :resource_id
            and capacity_quantity > 0
            and delete_flag = :n
            and item_date  between :cstart_date and :cend_date )
    where nvl(a,0) - nvl(b,0) <> 0' using 'C', p_cstart_date, p_cend_date, l_created_by,
    l_last_updated_by, l_last_update_login, 'U', p_resource_id, 'N', p_cstart_date, p_cend_date;

    --For Confirmed+Provisional Availability/Overcommittment
/* Commented dynamix SQL and replaced with bind variables for Bug #3964268
    execute immediate
    'insert into PA_RES_AVAILABILITY
    ( start_date,
      end_date,
      percent,
      record_type,
      resource_id,
      hours,
      creation_date,
      last_update_date,
      created_by,
	  last_updated_by,
      last_update_login
    )
    select item_date,
         (lead(item_date) over(order by item_date)) - 1,
         c * 100 ,
         ' || '''B''' ||
         ' , resource_id,
         pa_resource_pvt.get_res_prov_conf_availability(resource_id, nvl(item_date,' || '''' || p_bstart_date || '''' || '), nvl((lead(item_date) over(order by item_date)),' || '''' || p_bend_date || ''''||  ') - 1),
         sysdate,
         sysdate,
         ' || l_created_by || '  ,
         ' || l_last_updated_by || '  ,
         ' || l_last_update_login || '
    from (  select (nvl(capacity_quantity,0) - nvl(confirmed_qty,0) - nvl(provisional_qty,0))/nvl(capacity_quantity,0) a,
                   lag((nvl(capacity_quantity,0) - nvl(confirmed_qty,0) - nvl(provisional_qty,0))/nvl(capacity_quantity,0))
		               over ( order by item_date) as b,
                   (nvl(capacity_quantity,0) - nvl(confirmed_qty,0) - nvl(provisional_qty,0))/capacity_quantity c,
                   item_date,
                   resource_id
            from pa_forecast_items
            where forecast_item_type = ' || '''U''' ||
            ' and resource_id = ' || p_resource_id || '
            and capacity_quantity > 0
            and delete_flag = ' || '''N''' || '
            and item_date between ' || '''' || p_bstart_date || '''' || ' and ' ||
                '''' || p_bend_date || ''''||  ')
    where nvl(a,0) - nvl(b,0) <> 0';
*/
/* Modified the above commented SQL as below for Bug #3964268 with bind variables */
    execute immediate
    'insert into PA_RES_AVAILABILITY
    ( start_date,
      end_date,
      percent,
      record_type,
      resource_id,
      hours,
      creation_date,
      last_update_date,
      created_by,
	  last_updated_by,
      last_update_login
    )
    select item_date,
         (lead(item_date) over(order by item_date)) - 1,
         c * 100 ,
         :b,
         resource_id,
         pa_resource_pvt.get_res_prov_conf_availability(resource_id, nvl(item_date, :bstart_date ), nvl((lead(item_date) over(order by item_date)), :bend_date ) - 1),
         sysdate,
         sysdate,
         :created_by,
         :last_updated_by,
         :last_update_login
    from (  select (nvl(capacity_quantity,0) - nvl(confirmed_qty,0) - nvl(provisional_qty,0))/nvl(capacity_quantity,0) a,
                   lag((nvl(capacity_quantity,0) - nvl(confirmed_qty,0) - nvl(provisional_qty,0))/nvl(capacity_quantity,0))
		               over ( order by item_date) as b,
                   (nvl(capacity_quantity,0) - nvl(confirmed_qty,0) - nvl(provisional_qty,0))/capacity_quantity c,
                   item_date,
                   resource_id
            from pa_forecast_items
            where forecast_item_type = :u
            and resource_id = :resource_id
            and capacity_quantity > 0
            and delete_flag = :n
            and item_date between :bstart_date and :bend_date )
    where nvl(a,0) - nvl(b,0) <> 0' using 'B', p_bstart_date, p_bend_date, l_created_by,
    l_last_updated_by, l_last_update_login, 'U', p_resource_id, 'N', p_bstart_date, p_bend_date;

    --Logic to update the null dates due to usage of lead/lag
    update pa_res_availability avl
    set start_date = p_cstart_date
    where resource_id = p_resource_id
    and record_type = 'C'
    and start_date is null;

    update pa_res_availability avl
    set end_date = p_cend_date
    where resource_id = p_resource_id
    and record_type = 'C'
    and end_date is null;

    --Logic to insert 0 percent records in the beginning and end
    select min(start_date)
    into   l_start_date
    from pa_res_availability
    where resource_id = p_resource_id
    and record_type = 'C';

    IF l_start_date is not null THEN

      select percent
      into   l_percent
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'C'
      and start_date = l_start_date;

    END IF;

    IF l_percent <> 0 THEN

      insert into PA_RES_AVAILABILITY
      ( start_date,
        end_date,
        percent,
        record_type,
        resource_id,
	    creation_date,
	    last_update_date,
	    created_by,
	    last_updated_by,
        last_update_login)
      select min(start_date) - 1,
             min(start_date) - 1,
	         0,
             record_type,
	         resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'C'
      group by 0,
             record_type,
	         resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login;
    END IF;


    select max(end_date)
    into   l_end_date
    from pa_res_availability
    where resource_id = p_resource_id
    and record_type = 'C';

    IF l_end_date is not null THEN

      select percent
      into   l_percent
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'C'
      and end_date = l_end_date;
    END IF;

    IF l_percent <> 0 THEN

      insert into PA_RES_AVAILABILITY
      ( start_date,
        end_date,
        percent,
        record_type,
        resource_id,
	    creation_date,
	    last_update_date,
	    created_by,
	    last_updated_by,
        last_update_login)
      select max(end_date) + 1,
             max(end_date) + 1,
		     0,
		     record_type,
		     resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'C'
      group by 0,
		     record_type,
		     resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login;
    END IF;

    --Logic to update the null dates due to usage of lead/lag
    update pa_res_availability avl
    set start_date = p_bstart_date
    where resource_id = p_resource_id
    and record_type = 'B'
    and start_date is null;

    update pa_res_availability avl
    set end_date = p_bend_date
    where resource_id = p_resource_id
    and record_type = 'B'
    and end_date is null;

    --Logic to insert 0 percent records in the beginning and end
    select min(start_date)
    into   l_start_date
    from pa_res_availability
    where resource_id = p_resource_id
    and record_type = 'B';

    IF l_start_date is not null THEN

      select percent
      into   l_percent
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'B'
      and start_date = l_start_date;

    END IF;

    IF l_percent <> 0 THEN


      insert into PA_RES_AVAILABILITY
      ( start_date,
        end_date,
        percent,
        record_type,
        resource_id,
	    creation_date,
	    last_update_date,
	    created_by,
	    last_updated_by,
        last_update_login)
      select min(start_date) - 1,
             min(start_date) - 1,
	         0,
             record_type,
	         resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'B'
      group by 0,
             record_type,
	         resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login;
    END IF;

    select max(end_date)
    into   l_end_date
    from pa_res_availability
    where resource_id = p_resource_id
    and record_type = 'B';

    IF l_end_date is not null THEN

      select percent
      into   l_percent
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'B'
      and end_date = l_end_date;

    END IF;

    IF l_percent <> 0 THEN

      insert into PA_RES_AVAILABILITY
      ( start_date,
        end_date,
        percent,
        record_type,
        resource_id,
	    creation_date,
	    last_update_date,
	    created_by,
	    last_updated_by,
        last_update_login)
      select max(end_date) + 1,
             max(end_date) + 1,
		     0,
		     record_type,
		     resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'B'
      group by 0,
		     record_type,
		     resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login;
    END IF;

  ELSIF l_profile = 'WEEKLY' THEN

    --dbms_output.put_line('Profile is weekly');

    --For Confirmed Availability/Overcommittment
/* Commented dynamix SQL and replaced with bind variables for Bug #3964268
    execute immediate
    'insert into PA_RES_AVAILABILITY
    ( start_date,
      end_date,
      percent,
      record_type,
      resource_id,
      hours,
      creation_date,
      last_update_date,
      created_by,
	  last_updated_by,
      last_update_login
    )
    select item_date,
         (lead(item_date) over(order by item_date)) - 1,
         c * 100 ,
         ' || '''C''' ||
         ' , resource_id,
         pa_resource_pvt.get_res_conf_availability(resource_id, nvl(item_date,' || '''' || p_cstart_date || '''' || '), nvl((lead(item_date) over(order by item_date)),' || '''' || p_cend_date || ''''||  ') - 1),
         sysdate,
         sysdate,
         ' || l_created_by || ',
         ' || l_last_updated_by || ',
         ' || l_last_update_login || '
    from (
      select (nvl(a1,0) - nvl(a2,0))/nvl(a1,1) a,
             lag((nvl(a1,0) - nvl(a2,0))/nvl(a1,1))
		       over ( order by d) as b,
             (nvl(a1,0) - nvl(a2,0))/nvl(a1,1) c,
             d item_date,
             resource_id
      from (
        select (global_exp_period_end_date - 6) d,
               resource_id,
               sum(capacity_quantity) a1,
               sum(confirmed_qty) a2
        from   pa_forecast_items
        where  forecast_item_type = ' || '''U''' ||
        'and resource_id = ' || p_resource_id || '
        and capacity_quantity > 0
        and delete_flag = ' || '''N''' || '
        and item_date between ' || '''' || p_cstart_date || '''' || ' and ' ||
          '''' || p_cend_date || ''''||
        'group by global_exp_period_end_date - 6,
         resource_id))
    where nvl(a,0) - nvl(b,0) <> 0 ';
*/
/* Modified the above commented SQL as below for Bug #3964268 with bind variables */
    execute immediate
    'insert into PA_RES_AVAILABILITY
    ( start_date,
      end_date,
      percent,
      record_type,
      resource_id,
      hours,
      creation_date,
      last_update_date,
      created_by,
	  last_updated_by,
      last_update_login
    )
    select item_date,
         (lead(item_date) over(order by item_date)) - 1,
         c * 100 ,
         :c,
         resource_id,
         pa_resource_pvt.get_res_conf_availability(resource_id, nvl(item_date, :cstart_date), nvl((lead(item_date) over(order by item_date)), :cend_date ) - 1),
         sysdate,
         sysdate,
         :created_by,
         :last_updated_by,
         :last_update_login
    from (
      select (nvl(a1,0) - nvl(a2,0))/nvl(a1,1) a,
             lag((nvl(a1,0) - nvl(a2,0))/nvl(a1,1))
		       over ( order by d) as b,
             (nvl(a1,0) - nvl(a2,0))/nvl(a1,1) c,
             d item_date,
             resource_id
      from (
        select (global_exp_period_end_date - 6) d,
               resource_id,
               sum(capacity_quantity) a1,
               sum(confirmed_qty) a2
        from   pa_forecast_items
        where  forecast_item_type = :u
        and resource_id = :resource_id
        and capacity_quantity > 0
        and delete_flag = :n
        and item_date between :cstart_date and :cend_date
        group by global_exp_period_end_date - 6,
         resource_id))
    where nvl(a,0) - nvl(b,0) <> 0 ' using 'C', p_cstart_date, p_cend_date, l_created_by,
    l_last_updated_by, l_last_update_login, 'U', p_resource_id, 'N', p_cstart_date, p_cend_date;

    --For Confirmed+Provisional Availability/Overcommittment
/* Commented dynamix SQL and replaced with bind variables for Bug #3964268
    execute immediate
    'insert into PA_RES_AVAILABILITY
    ( start_date,
      end_date,
      percent,
      record_type,
      resource_id,
      hours,
      creation_date,
      last_update_date,
      created_by,
	  last_updated_by,
      last_update_login
    )
    select item_date,
         (lead(item_date) over(order by item_date)) - 1,
         c * 100 ,
         ' || '''B''' ||
         ' , resource_id,
         pa_resource_pvt.get_res_prov_conf_availability(resource_id, nvl(item_date,' || '''' || p_bstart_date || '''' || '), nvl((lead(item_date) over(order by item_date)),' || '''' || p_bend_date || ''''||  ') - 1),
         sysdate,
         sysdate,
         ' || l_created_by || ',
         ' || l_last_updated_by ||',
         ' || l_last_update_login || '
    from (
      select (nvl(a1,0) - nvl(a2,0) - nvl(a3,0))/nvl(a1,1) a,
             lag((nvl(a1,0) - nvl(a2,0) - nvl(a3,0))/nvl(a1,1))
		       over ( order by d) as b,
             (nvl(a1,0) - nvl(a2,0) - nvl(a3,0))/nvl(a1,1) c,
             d item_date,
             resource_id
      from (
        select (global_exp_period_end_date - 6) d,
               resource_id,
               sum(capacity_quantity) a1,
               sum(confirmed_qty) a2,
               sum(provisional_qty) a3
        from   pa_forecast_items
        where  forecast_item_type = ' || '''U''' ||
        'and resource_id = ' || p_resource_id || '
        and capacity_quantity > 0
        and delete_flag = ' || '''N''' || '
        and item_date between ' || '''' || p_bstart_date || '''' || ' and ' ||
          '''' || p_bend_date || ''''||
        'group by global_exp_period_end_date - 6,
         resource_id))
    where nvl(a,0) - nvl(b,0) <> 0 ';
*/
/* Modified the above commented SQL as below for Bug #3964268 with bind variables */
    execute immediate
    'insert into PA_RES_AVAILABILITY
    ( start_date,
      end_date,
      percent,
      record_type,
      resource_id,
      hours,
      creation_date,
      last_update_date,
      created_by,
	  last_updated_by,
      last_update_login
    )
    select item_date,
         (lead(item_date) over(order by item_date)) - 1,
         c * 100 ,
         :b,
         resource_id,
         pa_resource_pvt.get_res_prov_conf_availability(resource_id, nvl(item_date, :bstart_date ), nvl((lead(item_date) over(order by item_date)), :bend_date ) - 1),
         sysdate,
         sysdate,
         :created_by,
         :last_updated_by,
         :last_update_login
    from (
      select (nvl(a1,0) - nvl(a2,0) - nvl(a3,0))/nvl(a1,1) a,
             lag((nvl(a1,0) - nvl(a2,0) - nvl(a3,0))/nvl(a1,1))
		       over ( order by d) as b,
             (nvl(a1,0) - nvl(a2,0) - nvl(a3,0))/nvl(a1,1) c,
             d item_date,
             resource_id
      from (
        select (global_exp_period_end_date - 6) d,
               resource_id,
               sum(capacity_quantity) a1,
               sum(confirmed_qty) a2,
               sum(provisional_qty) a3
        from   pa_forecast_items
        where  forecast_item_type = :u
        and resource_id = :resource_id
        and capacity_quantity > 0
        and delete_flag = :n
        and item_date between :bstart_date and :bend_date
        group by global_exp_period_end_date - 6,
         resource_id))
    where nvl(a,0) - nvl(b,0) <> 0 ' using 'B', p_bstart_date, p_bend_date, l_created_by,
    l_last_updated_by, l_last_update_login, 'U', p_resource_id, 'N', p_bstart_date, p_bend_date;

    --dbms_output.put_line('After Insert');

    --Logic to update the null dates due to usage of lead/lag
    update pa_res_availability avl
    set start_date = p_cstart_date
    where resource_id = p_resource_id
    and record_type = 'C'
    and start_date is null;

    --dbms_output.put_line('After C Update 1');

    update pa_res_availability avl
    set end_date = p_cend_date
    where resource_id = p_resource_id
    and record_type = 'C'
    and end_date is null;

    --dbms_output.put_line('After C Update 2');

    --Logic to insert 0 percent records in the beginning and end
    select min(start_date)
    into   l_start_date
    from pa_res_availability
    where resource_id = p_resource_id
    and record_type = 'C';

    IF l_start_date is not null THEN

    BEGIN
      select percent
      into   l_percent
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'C'
      and start_date = l_start_date
      and percent = 0;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_percent := -1;
    END;
      --dbms_output.put_line('After C l_percent');

    END IF;

    IF l_percent <> 0 THEN

      insert into PA_RES_AVAILABILITY
      ( start_date,
        end_date,
        percent,
        record_type,
        resource_id,
	    creation_date,
	    last_update_date,
	    created_by,
	    last_updated_by,
        last_update_login)
      select min(start_date) - 1,
             min(start_date) - 1,
	         0,
             record_type,
	         resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'C'
      group by 0,
             record_type,
	         resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login;
    END IF;

    select max(end_date)
    into   l_end_date
    from pa_res_availability
    where resource_id = p_resource_id
    and record_type = 'C';

    IF l_end_date is not null THEN

    BEGIN
      select percent
      into   l_percent
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'C'
      and end_date = l_end_date
      and percent = 0;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_percent := -1;
    END;
      --dbms_output.put_line('After B l_percent');

    END IF;

    IF l_percent <> 0 THEN

      insert into PA_RES_AVAILABILITY
      ( start_date,
        end_date,
        percent,
        record_type,
        resource_id,
	    creation_date,
	    last_update_date,
	    created_by,
	    last_updated_by,
        last_update_login)
      select max(end_date) + 1,
             max(end_date) + 1,
		     0,
		     record_type,
		     resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'C'
      group by 0,
		     record_type,
		     resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login;
    END IF;

    --Logic to update the null dates due to usage of lead/lag
    update pa_res_availability avl
    set start_date = p_bstart_date
    where resource_id = p_resource_id
    and record_type = 'B'
    and start_date is null;

    update pa_res_availability avl
    set end_date = p_bend_date
    where resource_id = p_resource_id
    and record_type = 'B'
    and end_date is null;

    --Logic to insert 0 percent records in the beginning and end
    select min(start_date)
    into   l_start_date
    from pa_res_availability
    where resource_id = p_resource_id
    and record_type = 'B';

    IF l_start_date is not null THEN

    BEGIN
      select percent
      into   l_percent
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'B'
      and start_date = l_start_date
      and percent    = 0;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_percent := -1;
    END;

    END IF;

    IF l_percent <> 0 THEN

      insert into PA_RES_AVAILABILITY
      ( start_date,
        end_date,
        percent,
        record_type,
        resource_id,
	    creation_date,
	    last_update_date,
	    created_by,
	    last_updated_by,
        last_update_login)
      select min(start_date) - 1,
             min(start_date) - 1,
	         0,
             record_type,
	         resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'B'
      group by 0,
             record_type,
	         resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login;
    END IF;

    select max(end_date)
    into   l_end_date
    from pa_res_availability
    where resource_id = p_resource_id
    and record_type = 'B';

    IF l_end_date is not null THEN

      BEGIN
      select percent
      into   l_percent
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'B'
      and end_date = l_end_date
      and percent = 0;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_percent := -1;
      END;
    END IF;

    IF l_percent <> 0 THEN

      insert into PA_RES_AVAILABILITY
      ( start_date,
        end_date,
        percent,
        record_type,
        resource_id,
	    creation_date,
	    last_update_date,
	    created_by,
	    last_updated_by,
        last_update_login)
      select max(end_date) + 1,
             max(end_date) + 1,
		     0,
		     record_type,
		     resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login
      from pa_res_availability
      where resource_id = p_resource_id
      and record_type = 'B'
      group by 0,
		     record_type,
		     resource_id,
		     sysdate,
		     sysdate,
		     l_created_by,
		     l_last_updated_by,
             l_last_update_login;
    END IF;

  ELSE

    --TODO: Add error message for missing profile value
    PA_UTILS.Add_Message(
      p_app_short_name => 'PA'
     ,p_msg_name       => 'PA_NO_AVL_CALC_PROF');

    x_return_status := FND_API.G_RET_STS_ERROR;

    RETURN;
  END IF;

  --dbms_output.put_line('Before bug fix');

  --------------------------------------------------
  --BUG 2634959: Availability start date must not be
  --earlier than min. resource start date
  --------------------------------------------------
  select min(RESOURCE_EFFECTIVE_START_DATE)
  into   l_earliest_start_date
  from   pa_resources_denorm
  where  RESOURCE_ID        = p_resource_id;

  update pa_res_availability
    set  start_date  = l_earliest_start_date
  where  resource_id = p_resource_id
  and    start_date  <  l_earliest_start_date
  and    percent     > 0;

  select count(*)
  into   l_rec_count
  from pa_res_availability
  where  resource_id = p_resource_id
  and    start_date  <  l_earliest_start_date
  and    record_type = 'B'
  and    percent     = 0;

  IF l_rec_count > 1 THEN

    delete
    from pa_res_availability
    where  resource_id = p_resource_id
    and    start_date  <  l_earliest_start_date - 1
    and    record_type = 'B'
    and    percent     = 0;

  END IF;

  select count(*)
  into   l_rec_count
  from pa_res_availability
  where  resource_id = p_resource_id
  and    start_date  <  l_earliest_start_date
  and    record_type = 'C'
  and    percent     = 0;

  IF l_rec_count > 1 THEN

    delete
    from pa_res_availability
    where  resource_id = p_resource_id
    and    start_date  <  l_earliest_start_date - 1
    and    record_type = 'C'
    and    percent     = 0;

  END IF;

  update pa_res_availability
    set  start_date = l_earliest_start_date -1,
         end_date   = l_earliest_start_date -1
  where  resource_id = p_resource_id
  and    start_date  <  l_earliest_start_date
  and    percent     = 0;
  --------------------------------------------------

  --dbms_output.put_line('After bug fix');

EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;

END populate_res_availability;

-------------------------------------------------------------------------------+
--
--  PROCEDURE   : Update_Res_Availability
--  DESCRIPTION : This Procedure is called after FIs are generated
--                for any PJR assignment
--                This API updates PA_RES_AVAILABILITY based
--                on the new assignment created
--------------------------------------------------------------------------------+
PROCEDURE update_res_availability (
  p_resource_id   IN NUMBER,
  p_start_date    IN DATE,
  p_end_date      IN DATE,
  x_return_status OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_data      OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count     OUT   NOCOPY NUMBER ) --File.Sql.39 bug 4440895
IS

  l_msg_index_out number;
  l_cstart_date date;
  l_cend_date date;
  l_bstart_date date;
  l_bend_date date;
  l_start_date date;
  l_end_date date;

BEGIN

   -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_RESOURCE_PVT.Update_Res_Availability');

   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   BEGIN

     select min(resource_effective_start_date)
     into   l_start_date
     from pa_resources_denorm
     where resource_id = p_resource_id;

     /*bug 3229929 modified min(resource_effective_end_date) to max(resource_effective_end_date) */
     select max(resource_effective_end_date)
     into   l_end_date
     from pa_resources_denorm
     where resource_id = p_resource_id;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_start_date := trunc(p_start_date);
       l_end_date   := trunc(p_end_date);
   END;

   --Delete all records in pa_res_availability for this resource
   delete
   from pa_res_availability
   where resource_id = p_resource_id;


   populate_res_availability (
     p_resource_id => p_resource_id,
     p_cstart_date  => trunc(l_start_date),
     p_cend_date    => trunc(l_end_date),
     p_bstart_date  => trunc(l_start_date),
     p_bend_date    => trunc(l_end_date),
     x_return_status => x_return_status );

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

     -- Reset the error stack when returning to the calling program
     PA_DEBUG.Reset_Err_Stack;

     -- get the number of messages
     x_msg_count :=  FND_MSG_PUB.Count_Msg;

     -- Put a message text from message stack into the x_msg_data if there is only
     -- single error.
     IF x_msg_count = 1 THEN
	   pa_interface_utils_pub.get_messages
	    (p_encoded       => FND_API.G_TRUE
	    ,p_msg_index     => 1
	    ,p_data          => x_msg_data
	    ,p_msg_index_out => l_msg_index_out);
     END IF;

     RAISE;

   WHEN OTHERS THEN
     -- Set the exception Message and the stack
     FND_MSG_PUB.add_exc_msg
       (p_pkg_name       => 'PA_RESOURCE_PVT.Update_Res_Availability'
       ,p_procedure_name => PA_DEBUG.G_Err_Stack );

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     RAISE;

END Update_Res_Availability;

-------------------------------------------------------------------------------+
--
--  PROCEDURE   : Refresh_Res_Availability
--  DESCRIPTION : This Procedure is called by the concurrent program
--                to refresh PA_RES_AVAILABILITY
--------------------------------------------------------------------------------+
PROCEDURE refresh_res_availability (
  errbuf   OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  retcode  OUT   NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  l_return_status varchar2(1);
  l_msg_index_out number;
--  l_profile varchar2(30) := 'DAILY';
  CURSOR resources IS
  select resource_id,
       min(resource_effective_start_date) start_date,
	   max(resource_effective_end_date) end_date
  from pa_resources_denorm
  group by resource_id;

  CURSOR redundant_resources IS -- Added for bug 7316435
  select resource_id
  from pa_res_availability
  where resource_id not in (Select resource_id from pa_resources_denorm)
  and resource_id <> -1;

  l_res_count Number;       --Added for bug 4928773


BEGIN

   -- Initialize the return status to success
   retcode := 0;

   FOR rec IN redundant_resources LOOP  --Added for bug 7316435 (Cleaning Redundant records)

     delete
      from PA_RES_AVAILABILITY where RESOURCE_ID = rec.resource_id;

   END LOOP;



   --SAVEPOINT s_res_avl_begin; commented for bug 4928773

   --Cleanup existing records in PA_RES_AVAILABILITY
   --delete
   --from PA_RES_AVAILABILITY;commented for bug 4928773
   l_res_count := 0;
   FOR rec IN resources LOOP

      If l_res_count = 100 or l_res_count = 0 then  --Added If block for bug 4928773
         l_res_count := 0;
         commit;
         SAVEPOINT s_res_avl_begin;
      end if;

      delete
      from PA_RES_AVAILABILITY where RESOURCE_ID = rec.resource_id;  --Added for bug 4928773

      pa_resource_pvt.populate_res_availability(
        p_resource_id    => rec.resource_id,
        p_cstart_date    => rec.start_date,
        p_cend_date      => rec.end_date,
        p_bstart_date    => rec.start_date,
        p_bend_date      => rec.end_date,
        x_return_status  => l_return_status );

      l_res_count := l_res_count + 1;   --Added for bug 4928773

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        ROLLBACK TO s_res_avl_begin;
        retcode := 2;
        EXIT;

      END IF;

   END LOOP;

-- commented out for perf bug 4930256
-- l_profile := FND_PROFILE.VALUE_SPECIFIC('PA_AVAILABILITY_CAL_PERIOD');

   delete
   from PA_RES_AVAILABILITY where RESOURCE_ID = -1;      --Added for bug 4928773

   INSERT
   INTO PA_RES_AVAILABILITY
   (
     RESOURCE_ID,
     START_DATE,
     RECORD_TYPE,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY
   )
   VALUES
   (
     -1,
     sysdate,
     decode(l_profile, 'DAILY', 'D', 'W'),
     sysdate,
     -1,
     sysdate,
     -1
   );


   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     retcode := 2;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   COMMIT;

   retcode := 0;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

     ROLLBACK TO s_res_avl_begin;

     retcode := 2;
     errbuf := SQLERRM;

   WHEN OTHERS THEN

     ROLLBACK TO s_res_avl_begin;

     errbuf := SQLERRM;
     retcode := 2;

END Refresh_Res_Availability;


--  FUNCTION
--             Get_Staff_Mgr_Org_Id
--  PURPOSE
--             Specifically for staffing pages use (Avl/Ovc CO objects)
--             It gets the Staffing Manager Organization (either SM organization
--             or from the profile option) to be used in the VO. It returns the
--             organization id.
--+
FUNCTION Get_Staff_Mgr_Org_Id (p_user_id    IN NUMBER
                              ,p_person_id  IN NUMBER)
RETURN VARCHAR2
IS
   l_org_id               NUMBER;
   l_return_status        VARCHAR2(1);
   l_error_message_code   fnd_new_messages.message_name%TYPE;
BEGIN

   l_org_id := fnd_profile.value_specific(
                 name    => 'PA_STAFF_HOME_DEF_ORG',
                 user_id => p_user_id);

   IF l_org_id IS NULL THEN
         PA_RESOURCE_UTILS.get_org_id(
                 p_personid            => p_person_id,
                 p_start_date          => sysdate,
                 x_orgid               => l_org_id,
                 x_error_message_code  => l_error_message_code,
                 x_return_status       => l_return_status);
   END IF;

   RETURN l_org_id;

END Get_Staff_Mgr_Org_Id;


END PA_RESOURCE_PVT;

/
