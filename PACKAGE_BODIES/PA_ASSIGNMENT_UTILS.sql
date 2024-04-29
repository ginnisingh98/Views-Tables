--------------------------------------------------------
--  DDL for Package Body PA_ASSIGNMENT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ASSIGNMENT_UTILS" AS
-- $Header: PARAUTLB.pls 120.10.12010000.2 2008/09/23 17:22:56 jcgeorge ship $

--
--  PROCEDURE
--              Check_Status_Is_In_use
--  PURPOSE
--              This procedure Checks whether a given status is used in
--      Assignments and assignment schedules
--  HISTORY
--   16-JUL-2000      R. Krishnamurthy       Created
--
li_message_level NUMBER := 1;

PROCEDURE check_status_is_in_use
            ( p_status_code IN pa_project_statuses.project_status_code%TYPE
             ,x_in_use_flag OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
BEGIN
       pa_debug.init_err_stack ('pa_assignment_utils.check_status_is_in_use');
       x_error_message_code := NULL;
       x_in_use_flag := 'N';
       x_return_status := FND_API.G_RET_STS_SUCCESS;

--change due to performance reason
/*
       SELECT 'Y', 'PA_STATUS_EXIST_IN_ASGMT'
       INTO  x_in_use_flag, x_error_message_code
       FROM dual
       WHERE EXISTS
       (SELECT 'x' FROM pa_project_assignments
    WHERE status_code = p_status_code)
        OR EXISTS
       (SELECT 'x' FROM pa_schedules
        WHERE status_code = p_status_code)
        OR EXISTS
       (SELECT 'x' FROM pa_project_assignments
        WHERE apprvl_status_code = p_status_code);

       SELECT 'Y', 'PA_STATUS_EXIST_IN_ASGMT'
       INTO  x_in_use_flag, x_error_message_code
       FROM pa_project_assignments ppa,
            pa_schedules ps
       WHERE
       (    ( ppa.status_code = p_status_code)
       OR  ( ps.status_code = p_status_code)
       OR  ( ppa.apprvl_status_code = p_status_code))
       AND rownum = 1;
*/

    BEGIN
       SELECT 'Y', 'PA_STATUS_EXIST_IN_ASGMT'
       INTO x_in_use_flag, x_error_message_code
       FROM pa_project_assignments
       WHERE status_code = p_status_code
       AND  rownum = 1;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            null;
    END;

    BEGIN
       IF x_in_use_flag = 'N' THEN
          SELECT 'Y', 'PA_STATUS_EXIST_IN_ASGMT'
          INTO x_in_use_flag, x_error_message_code
          FROM pa_project_assignments
          WHERE apprvl_status_code = p_status_code
          AND rownum = 1;
       END IF;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            null;
    END;

    BEGIN
       IF x_in_use_flag = 'N' THEN
          SELECT 'Y', 'PA_STATUS_EXIST_IN_ASGMT'
          INTO x_in_use_flag, x_error_message_code
          FROM pa_schedules
          WHERE status_code = p_status_code
          AND rownum = 1;
       END IF;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            null;
    END;

    pa_debug.reset_err_stack;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_in_use_flag := 'N';

	-- 4537865 : RESET Out params to proper values
	-- Make x_error_message_code as NULL as in this case we consider return status as 'S'

	x_error_message_code := NULL ;

	-- 4537865 : End

        pa_debug.reset_err_stack;
    WHEN OTHERS THEN
        -- 4537865 : RESET Out params to proper values
	x_error_message_code := SQLCODE ;
	x_in_use_flag := NULL ;
	-- 4537865 : End

         fnd_msg_pub.add_exc_msg
         (p_pkg_name => 'PA_ASSIGNMENT_UTILS',
          p_procedure_name => pa_debug.g_err_stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;
END check_status_is_in_use;

--
--  PROCEDURE
--              Validate_Asgmt_Competency
--  PURPOSE
--              This procedure validates the competencies for an assignment
--  HISTORY
--   17-JUL-2000      R. Krishnamurthy       Created
--
--   27-Jul-2001      Vijay Ranganathan      Changed API Validate_Asgmt_Competency
--                                           to get project business group
--                                           BUG: 1904822
PROCEDURE Validate_Asgmt_Competency
            ( p_project_id  IN pa_projects_all.project_id%TYPE
             ,p_assignment_id   IN pa_project_assignments.assignment_id%TYPE
             ,p_competence_id   IN per_competences.competence_id%TYPE
         ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_error_message_code OUT NOCOPY VARCHAR2)  IS --File.Sql.39 bug 4440895
l_comp_bg_id NUMBER := 0;
l_proj_bg_id NUMBER := 0;
CURSOR l_bg_csr IS
SELECT business_group_id FROM per_competences
WHERE  competence_id = p_competence_id;

BEGIN
     pa_debug.init_err_stack ('pa_assignment_utils.Validate_Asgmt_Competency');
     OPEN l_bg_csr;
     FETCH l_bg_csr INTO l_comp_bg_id;
     IF l_bg_csr%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message_code := 'PA_COMPETENCY_INVALID_AMBIGOUS';
    CLOSE l_bg_csr;
        pa_debug.reset_err_stack;
        RETURN;
     ELSE
    CLOSE l_bg_csr;
     END IF;

     --BUG: 1904822 Get project business group id instead of from pa_implementations
     IF ( l_comp_bg_id IS NOT NULL
         AND l_comp_bg_id <> pa_project_utils2.Get_project_business_group ( p_project_id)) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_error_message_code := 'PA_ASGMT_COMPETENCY_INVALID';
         pa_debug.reset_err_stack;
     RETURN;
     END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        pa_debug.reset_err_stack;
EXCEPTION
    WHEN OTHERS THEN
	 -- 4537865 : RESET Out params to proper values
	 x_error_message_code := SQLCODE ;
	 -- 4537865 : End

         fnd_msg_pub.add_exc_msg
         (p_pkg_name => 'PA_ASSIGNMENT_UTILS',
          p_procedure_name => pa_debug.g_err_stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;
END Validate_Asgmt_Competency;

--  PROCEDURE
--              Get_Def_Asgmt_Statuses
--    This procedure returns the default assignment statuses
--    17-JUL-2000      R. Krishnamurthy       Created

PROCEDURE Get_Def_Asgmt_Statuses
   (x_starting_oa_status OUT NOCOPY pa_project_statuses.project_status_code%TYPE, --File.Sql.39 bug 4440895
    x_starting_sa_status OUT NOCOPY pa_project_statuses.project_status_code%TYPE, --File.Sql.39 bug 4440895
    x_starting_fa_status OUT NOCOPY pa_project_statuses.project_status_code%TYPE, --File.Sql.39 bug 4440895
    x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

BEGIN
   pa_debug.init_err_stack ('pa_assignment_utils.Get_Def_Asgmt_Statuses');
   x_starting_oa_status := fnd_profile.value ('DEF_OA_STARTING_STATUS');
   x_starting_sa_status := fnd_profile.value ('DEF_SA_STARTING_STATUS');
   x_starting_fa_status := fnd_profile.value ('DEF_FA_STATUS');
   -- While it is ok for the other two statuses to be not defined,
   -- an installation must always have a default filled status defined
   -- in order for the assignments to be marked as filled whenever
   -- an open assignment is filled with a resource

   IF x_starting_fa_status IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_NO_DEF_FA_STATUS';
   ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   END IF;
   pa_debug.reset_err_stack;
EXCEPTION
    WHEN OTHERS THEN

     -- 4537865 : RESET OUT params to proper values
	x_starting_oa_status := NULL ;
	x_starting_sa_status := NULL ;
	x_starting_fa_status := NULL ;
	x_error_message_code := SQLCODE;
      -- 4537865 :ENd

      fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_ASSIGNMENT_UTILS',
       p_procedure_name => pa_debug.g_err_stack );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE;
END Get_Def_Asgmt_Statuses;

--  FUNCTION
--              Get_project_id
--    This function returns the project id for a given assignment

--    17-JUL-2000      R. Krishnamurthy       Created
FUNCTION  Get_Project_Id (p_assignment_id IN NUMBER) RETURN NUMBER IS
l_project_id  NUMBER ;
BEGIN
    pa_debug.init_err_stack ('pa_assignment_utils.Get_Project_Id');
    SELECT project_id
    INTO l_project_id
    FROM pa_project_assignments
    WHERE assignment_id = p_assignment_id ;
    pa_debug.reset_err_stack;
    RETURN l_project_id ;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN NULL;
  WHEN OTHERS THEN
       fnd_msg_pub.add_exc_msg
         (p_pkg_name => 'PA_ASSIGNMENT_UTILS',
          p_procedure_name => pa_debug.g_err_stack );
         RAISE;
END Get_Project_Id;

-- This function returns whether a given assignment status is
-- a confirmed status or not
--    18-JUL-2000      R. Krishnamurthy       Created
FUNCTION Is_Confirmed_Status
(p_status_code IN pa_project_statuses.project_status_code%TYPE ,
 p_status_type IN pa_project_statuses.status_type%TYPE )
 return VARCHAR2 IS
BEGIN
        RETURN check_input_system_status (
        p_status_code,
            p_status_type,
        'STAFFED_ASGMT_CONF');
EXCEPTION
    WHEN OTHERS THEN
  RAISE;
END Is_Confirmed_Status ;

-- This function returns whether a given assignment status is
-- a Provisional status or not
--    18-JUL-2000      R. Krishnamurthy       Created
FUNCTION Is_Provisional_Status
(p_status_code IN pa_project_statuses.project_status_code%TYPE ,
 p_status_type IN pa_project_statuses.status_type%TYPE )
 return VARCHAR2 IS
BEGIN
        RETURN check_input_system_status (
        p_status_code,
            p_status_type,
        'STAFFED_ASGMT_PROV');
EXCEPTION
    WHEN OTHERS THEN
  RAISE;
END Is_provisional_status;

-- This function returns whether a given assignment status is
-- a Filled status or not
--    18-JUL-2000      R. Krishnamurthy       Created
FUNCTION Is_Asgmt_Filled
(p_status_code IN pa_project_statuses.project_status_code%TYPE ,
 p_status_type IN pa_project_statuses.status_type%TYPE )
 return VARCHAR2 IS
BEGIN
        RETURN check_input_system_status (
        p_status_code,
            p_status_type,
        'OPEN_ASGMT_FILLED');
EXCEPTION
    WHEN OTHERS THEN
    RAISE;
END Is_Asgmt_Filled ;

-- This function returns whether a given assignment status is
-- an Open status or not
--    18-JUL-2000      R. Krishnamurthy       Created
FUNCTION Is_Asgmt_In_Open_Status
(p_status_code IN pa_project_statuses.project_status_code%TYPE ,
 p_status_type IN pa_project_statuses.status_type%TYPE )
 return VARCHAR2 IS
BEGIN
        RETURN check_input_system_status (
        p_status_code,
            p_status_type,
        'OPEN_ASGMT');
EXCEPTION
    WHEN OTHERS THEN
    RAISE;
END Is_Asgmt_In_Open_Status ;

-- This function returns whether a given open assignment status is
-- a cancelled status or not
--    18-JUL-2000      R. Krishnamurthy       Created
FUNCTION Is_Open_Asgmt_Cancelled
(p_status_code IN pa_project_statuses.project_status_code%TYPE ,
 p_status_type IN pa_project_statuses.status_type%TYPE )
 return VARCHAR2 IS
BEGIN
        RETURN check_input_system_status (
        p_status_code,
            p_status_type,
        'OPEN_ASGMT_CANCEL');
EXCEPTION
    WHEN OTHERS THEN
    RAISE;
END Is_Open_Asgmt_Cancelled ;

-- This function returns whether a given staffed assignment status is
-- a cancelled status or not
--    18-JUL-2000      R. Krishnamurthy       Created
FUNCTION Is_Staffed_Asgmt_Cancelled
(p_status_code IN pa_project_statuses.project_status_code%TYPE ,
 p_status_type IN pa_project_statuses.status_type%TYPE )
 return VARCHAR2 IS
BEGIN
        RETURN check_input_system_status (
        p_status_code,
            p_status_type,
        'STAFFED_ASGMT_CANCEL');
EXCEPTION
    WHEN OTHERS THEN
    RAISE;
END Is_Staffed_Asgmt_Cancelled ;

-- This function returns whether a given status is
-- has the specified system status
--    18-JUL-2000      R. Krishnamurthy       Created
FUNCTION Check_input_system_status
(p_status_code IN pa_project_statuses.project_status_code%TYPE ,
p_status_type IN pa_project_statuses.status_type%TYPE ,
p_in_system_status_code IN pa_project_statuses.project_system_status_code%TYPE)
RETURN VARCHAR2 IS
l_ret_val VARCHAR2(1);
BEGIN
        SELECT DECODE (project_system_status_code,
               p_in_system_status_code,'Y','N')
    INTO l_ret_val
    FROM pa_project_statuses
    WHERE project_status_code = p_status_code
    AND   status_type = p_status_type;
    RETURN l_ret_val;
EXCEPTION
    WHEN OTHERS THEN
         RAISE;
END check_input_system_status ;

PROCEDURE Check_proj_Assignments_Exist
             (p_project_id                IN NUMBER
             ,x_assignments_exist_flag   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_error_message_code       OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
BEGIN
   pa_debug.init_err_stack ('pa_assignment_utils.Check_proj_Assignments_Exist');
    x_assignments_exist_flag := 'N';
    x_error_message_code := NULL;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

--Change due to Performance Reason
/*
    SELECT 'Y', 'PA_PROJ_ASSIGNMENTS_EXIST'
    INTO  x_assignments_exist_flag, x_error_message_code
    FROM dual
    WHERE EXISTS
    (SELECT 'x' FROM pa_project_assignments
     WHERE project_id = p_project_id);
*/
    SELECT 'Y', 'PA_PROJ_ASSIGNMENTS_EXIST'
    INTO  x_assignments_exist_flag, x_error_message_code
    FROM pa_project_assignments
    WHERE project_id = p_project_id
    AND rownum=1;

        pa_debug.reset_err_stack;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_assignments_exist_flag := 'N';
    WHEN OTHERS THEN
	  -- 4537865 : Start : RESET OUT PARAMS to proper values
	 x_assignments_exist_flag := NULL ;
	 x_error_message_code := SQLCODE ;
	 -- 4537865 : End

         fnd_msg_pub.add_exc_msg
         (p_pkg_name => 'PA_ASSIGNMENT_UTILS',
          p_procedure_name => pa_debug.g_err_stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;
END check_proj_assignments_exist;

PROCEDURE Check_Assignment_Number_Or_Id( p_assignment_id      IN pa_project_assignments.assignment_id%TYPE
                                        ,p_assignment_number  IN pa_project_assignments.assignment_number%TYPE
                                        ,p_check_id_flag      IN VARCHAR2  := 'A'
                                        ,x_assignment_id      OUT NOCOPY pa_project_assignments.assignment_id%TYPE --File.Sql.39 bug 4440895
                                        ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                        ,x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
CURSOR c_ids IS
 SELECT assignment_id
 FROM pa_project_assignments
 WHERE assignment_number = p_assignment_number;

l_id_found_flag VARCHAR2(1);
l_current_id    pa_project_assignments.assignment_id%TYPE;
l_num_ids        NUMBER;
BEGIN
    pa_debug.init_err_stack ('pa_assignment_utils.check_assignment_number_or_id');
        IF p_assignment_id IS NOT NULL AND p_assignment_id <> FND_API.G_MISS_NUM THEN
     IF p_check_id_flag = 'Y' THEN
           SELECT assignment_id
           INTO   x_assignment_id
           FROM   pa_project_assignments
           WHERE  assignment_number = p_assignment_number;
     ELSIF p_check_id_flag = 'N' THEN
        x_assignment_id := p_assignment_id;
     ELSIF p_check_id_flag = 'A' THEN
            IF (p_assignment_number IS NULL) THEN
              -- Return a null ID since the name is null.
              x_assignment_id := NULL;
            ELSE
              -- Find the ID which matches the Name passed
                OPEN c_ids;
                LOOP
                  FETCH c_ids INTO l_current_id;
                  EXIT WHEN c_ids%NOTFOUND;
                  IF (l_current_id = p_assignment_id) THEN
                     l_id_found_flag := 'Y';
                     x_assignment_id := p_assignment_id;
                  END IF;
                END LOOP;
                l_num_ids := c_ids%ROWCOUNT;
                CLOSE c_ids;

                IF (l_num_ids = 0) THEN
                           -- No IDs for name
                           RAISE NO_DATA_FOUND;
                ELSIF (l_num_ids = 1) THEN
                           -- Since there is only one ID for the name use it.
                           x_assignment_id := l_current_id;
                ELSIF (l_id_found_flag = 'N') THEN
                           -- More than one ID for the name and none of the IDs matched
                           -- the ID passed in.
                           RAISE TOO_MANY_ROWS;
                END IF;
            END IF;
         END IF;
        ELSE
          IF (p_assignment_number IS NOT NULL) THEN
           SELECT assignment_id
           INTO   x_assignment_id
           FROM   pa_project_assignments
           WHERE  assignment_number = p_assignment_number;
          ELSE
           x_assignment_id := NULL;
          END IF;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
        pa_debug.reset_err_stack;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_ASGN_NUMBER_INV_AMBIGOUS';
          x_assignment_id := NULL;
    WHEN TOO_MANY_ROWS THEN
          x_assignment_id := NULL;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_ASGN_NUMBER_INV_AMBIGOUS';
        WHEN OTHERS THEN
         -- 4537865 : Start : RESET OUT PARAMS to proper values
	 x_error_message_code := SQLCODE;
	 -- 4537865 : End

          fnd_msg_pub.add_exc_msg
           (p_pkg_name => 'PA_ASSIGNMENT_UTILS',
            p_procedure_name => pa_debug.g_err_stack );
            x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
            x_assignment_id := NULL;
     RAISE;
END Check_Assignment_Number_Or_Id;

PROCEDURE Check_STF_PriorityName_Or_Code (p_staffing_priority_code  IN pa_project_assignments.staffing_priority_code%TYPE
                                               ,p_staffing_priority_name  IN pa_lookups.meaning%TYPE
                                               ,p_check_id_flag           IN VARCHAR2
                                               ,x_staffing_priority_code  OUT NOCOPY pa_project_assignments.staffing_priority_code%TYPE --File.Sql.39 bug 4440895
                                               ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                               ,x_error_message_code      OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
BEGIN
    pa_debug.init_err_stack ('pa_assignment_utils.Check_STF_PriorityName_Or_Code');

    IF p_staffing_priority_code IS NOT NULL AND p_staffing_priority_code<>FND_API.G_MISS_CHAR THEN
        IF p_check_id_flag = 'Y' THEN
            SELECT lookup_code
                INTO   x_staffing_priority_code
                FROM   pa_lookups
                WHERE  lookup_type = 'STAFFING_PRIORITY_CODE'
                        AND    lookup_code = p_staffing_priority_code;
            ELSE
            x_staffing_priority_code := p_staffing_priority_code;

        END IF;
        ELSE
        SELECT lookup_code
            INTO   x_staffing_priority_code
            FROM   pa_lookups
            WHERE  lookup_type = 'STAFFING_PRIORITY_CODE'
                AND    meaning = p_staffing_priority_name;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message_code := 'PA_STF_PRIORITY_INVALID';
        WHEN TOO_MANY_ROWS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message_code := 'PA_STF_PRIORITY_INVALID';
        WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	 -- 4537865 : Start
	x_staffing_priority_code := p_staffing_priority_code ;
	x_error_message_code := SQLCODE ;
	 -- 4537865 : End
END Check_STF_PriorityName_Or_Code;

--
--Possible values for return: 'Roll On', 'Roll Off', 'Pending Approval'
--
--Use the dates passed in to decided if the assignment is rolling on, or rolling off or pending approval.

FUNCTION  get_role_activity_text (p_assignment_id  IN NUMBER,
                                  p_start_date IN DATE,
                                  p_end_date IN DATE,
                                  p_apprvl_status_code IN VARCHAR2,
                                  p_num_of_weeks IN NUMBER) RETURN VARCHAR2
IS

l_lookup_code     pa_lookups.lookup_code%TYPE;
l_meaning         pa_lookups.meaning%TYPE;
l_today_date      pa_project_assignments.start_date%TYPE;

CURSOR get_meaning IS
SELECT meaning
FROM pa_lookups
WHERE lookup_code = l_lookup_code
AND   lookup_type = 'TEAM_ROLE_ACTIVITY_TYPE';

BEGIN

  l_today_date := TRUNC (sysdate);

  IF p_apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_submitted THEN
    l_lookup_code := 'PENDING';
  ELSIF ( l_today_date <= p_start_date) AND (l_today_date >= (p_start_date - p_num_of_weeks*7)) THEN
    l_lookup_code := 'ROLL_ON';
  ELSIF (l_today_date <= p_end_date) AND (l_today_date >= (p_end_date - p_num_of_weeks*7)) THEN
    l_lookup_code := 'ROLL_OFF';
  END IF;

  IF l_lookup_code IS NOT NULL THEN
    OPEN get_meaning;
    FETCH get_meaning INTO l_meaning;
    CLOSE get_meaning;
  END IF;

  RETURN l_meaning;


END get_role_activity_text;


--
--Possible values for return: start_date, end_date
--
--IF assignment rolling on, then return start_date
--IF assignment rolling off, then return end_date
--IF pending approval, then return start_date

FUNCTION  get_role_activity_date (p_assignment_id  IN NUMBER,
                                  p_start_date IN DATE,
                                  p_end_date IN DATE,
                                  p_apprvl_status_code IN VARCHAR2,
                                  p_num_of_weeks IN NUMBER) RETURN DATE
IS

l_date        DATE;
l_today_date  pa_project_assignments.start_date%TYPE;

BEGIN

  l_today_date := TRUNC(sysdate);

  IF p_apprvl_status_code = PA_ASSIGNMENT_APPROVAL_PUB.g_submitted THEN
    l_date := p_start_date;
  ELSIF (l_today_date <= p_start_date) AND (l_today_date >= (p_start_date - p_num_of_weeks*7)) THEN
    l_date := p_start_date;
  ELSIF (l_today_date <= p_end_date) AND (l_today_date >= (p_end_date - p_num_of_weeks*7)) THEN
    l_date := p_end_date;
  END IF;

  RETURN l_date;

END get_role_activity_date;

PROCEDURE Add_Message(p_app_short_name   IN    VARCHAR2,
                      p_msg_name         IN    VARCHAR2,
                      p_token1           IN    VARCHAR2 DEFAULT NULL,
                      p_value1           IN    VARCHAR2 DEFAULT NULL)
IS

l_message_text   FND_NEW_MESSAGES.message_text%TYPE;

/* 2708879 - Added two conditions for application id and language code for the cursor get_message below */
CURSOR get_message IS
SELECT message_text
  FROM fnd_new_messages
 WHERE message_name = p_msg_name
 and application_id = 275
 and language_code = userenv('LANG');

CURSOR get_team_template_name IS
SELECT team_template_name
  FROM pa_team_templates
 WHERE team_template_id = g_team_template_id;

BEGIN

  --when applying a team template to a project, multiple team templates containing
  --multiple assignments will be created.
  --if the team_template_name and/or team_role_name global variables are set and  there
  --are any validation errors, then the team_template_name and assignment_name will
  --be prepended to the error message.
  --If the globals are NULL then the message will appear normally (nothing prepended).
  IF pa_assignment_utils.g_team_template_name_token IS NULL AND pa_assignment_utils.g_team_role_name_token IS NULL THEN

     IF p_token1 IS NULL THEN
        --message text appear with no prepended values.
        PA_UTILS.Add_Message(p_app_short_name => p_app_short_name,
                             p_msg_name => p_msg_name);
     ELSE
        --message text appear with no prepended values.
        PA_UTILS.Add_Message(p_app_short_name => p_app_short_name,
                             p_msg_name => p_msg_name,
                             p_token1 => p_token1,
                             p_value1 => p_value1);
     END IF;

  ELSIF pa_assignment_utils.g_team_template_id IS NOT NULL THEN

     --get the message text
     OPEN get_message;
     FETCH get_message INTO l_message_text;
     CLOSE get_message;

     --if the team_template_id token is set but the name is not then get the name.
     --the apply_team_template API does not have the team_template_name but does have the
     --id, so in this way we only get the name if required.
     IF g_team_template_name_token IS NULL THEN
        OPEN get_team_template_name;
        FETCH get_team_template_name INTO g_team_template_name_token;
        CLOSE get_team_template_name;
     END IF;

     --if the team template name token value is set and
     --the team role name token value is not set then this a team template level
     --error, so the message will be displayed in the format:
     --"Team Template Name: Error Message"
     --both the team template name and error message are tokens.
     IF pa_assignment_utils.g_team_role_name_token IS NULL THEN

        IF p_token1 IS NULL THEN
           PA_UTILS.Add_Message(p_app_short_name => p_app_short_name,
                                p_msg_name       => 'PA_TEAM_TEMP_ERR_MSG',
                                p_token1         => 'TEAM_TEMPLATE_NAME',
                                p_value1         => pa_assignment_utils.g_team_template_name_token,
                                p_token2         => 'ERROR_MESSAGE',
                                p_value2         => l_message_text);
         ELSE
           PA_UTILS.Add_Message(p_app_short_name => p_app_short_name,
                                p_msg_name       => 'PA_TEAM_TEMP_ERR_MSG',
                                p_token1         => 'TEAM_TEMPLATE_NAME',
                                p_value1         => pa_assignment_utils.g_team_template_name_token,
                                p_token2         => 'ERROR_MESSAGE',
                                p_value2         => l_message_text,
                                p_token3         => p_token1,
                                p_value3         => p_value1);
          END IF;

     --if the team template name token value is set and
     --the team role name token value is set then this a requirement level which occurs when
     --the team template is being applied to a project.
     --The message will be displayed in the format:
     --"Team Template Name: Team Role Name: Error Message"
     --The team template name, team role name, and error message are tokens.
     ELSIF pa_assignment_utils.g_team_role_name_token IS NOT NULL THEN

        IF pa_assignment_utils.g_team_role_name_token IS NULL THEN
           PA_UTILS.Add_Message(p_app_short_name => p_app_short_name,
                                p_msg_name       => 'PA_TEAM_TEMP_ROLE_ERR_MSG',
                                p_token1         => 'TEAM_TEMPLATE_NAME',
                                p_value1         => pa_assignment_utils.g_team_template_name_token,
                                p_token2         => 'TEAM_ROLE_NAME',
                                p_value2         => pa_assignment_utils.g_team_role_name_token,
                                p_token3         => 'ERROR_MESSAGE',
                                p_value3         => l_message_text);
         ELSE
           PA_UTILS.Add_Message(p_app_short_name => p_app_short_name,
                                p_msg_name       => 'PA_TEAM_TEMP_ROLE_ERR_MSG',
                                p_token1         => 'TEAM_TEMPLATE_NAME',
                                p_value1         => pa_assignment_utils.g_team_template_name_token,
                                p_token2         => 'TEAM_ROLE_NAME',
                                p_value2         => pa_assignment_utils.g_team_role_name_token,
                                p_token3         => 'ERROR_MESSAGE',
                                p_value3         => l_message_text,
                                p_token4         => p_token1,
                                p_value4         => p_value1);
         END IF;

      END IF;

    END IF;

END Add_Message;


FUNCTION is_asgmt_allow_stus_ctl_check(p_asgmt_status_code IN   pa_project_statuses.project_status_code%TYPE,
                                       p_project_id        IN   pa_projects_all.project_id%TYPE,
                                       p_add_message       IN   VARCHAR2)
   RETURN VARCHAR2 IS

 CURSOR get_status_info IS
 SELECT proj.project_status_code, ps.project_status_name, ps2.project_system_status_code, ps2.project_status_name
 FROM   pa_projects_all proj,
        pa_project_statuses ps,
        pa_project_statuses ps2
 WHERE  project_id = p_project_id
   AND  proj.project_status_code = ps.project_status_code
   AND  ps2.project_status_code = p_asgmt_status_code;

 l_project_status_code      pa_project_statuses.project_status_code%TYPE;
 l_project_status_name      pa_project_statuses.project_status_name%TYPE;
 l_asgmt_system_status_code pa_project_statuses.project_system_status_code%TYPE;
 l_asgmt_status_name        pa_project_statuses.project_status_name%TYPE;
 l_allow_asgmt              VARCHAR2(1);
 l_status_control_code      pa_project_status_controls.action_code%TYPE;

BEGIN

  OPEN get_status_info;
  FETCH get_status_info INTO l_project_status_code
                           , l_project_status_name
                           , l_asgmt_system_status_code
                           , l_asgmt_status_name;
  CLOSE get_status_info;

  IF l_asgmt_system_status_code = 'STAFFED_ASGMT_CONF' THEN

     l_status_control_code := 'PROJ_ASSIGN_RESOURCES';

  ELSIF l_asgmt_system_status_code = 'STAFFED_ASGMT_PROV' THEN

     l_status_control_code := 'PROJ_PROVISIONAL_ASSIGN';

  ELSIF l_asgmt_system_status_code = 'STAFFED_ASGMT_CANCEL' THEN

     RETURN 'Y';

  END IF;

  l_allow_asgmt := PA_PROJECT_UTILS.Check_prj_stus_action_allowed
                                    ( x_project_status_code  => l_project_status_code
                                     ,x_action_code          => l_status_control_code);

  IF p_add_message = 'Y' AND l_allow_asgmt = 'N' THEN

               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_ASGN_STUS_NOT_FOR_PROJ_STUS'
                               ,p_token1         => 'PROJ_STATUS'
                   ,p_value1         => l_project_status_name
                               ,p_token2         => 'ASGN_STATUS'
                               ,p_value2         => l_asgmt_status_name);

  END IF;

  RETURN l_allow_asgmt;

  EXCEPTION
     WHEN OTHERS THEN
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ASSIGNMENT_UTILS.is_asgmt_allow_stus_ctl_check'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        RAISE;  -- This is optional depending on the needs

  END is_asgmt_allow_stus_ctl_check;


--
--  PROCEDURE
--              Get_Person_Asgmt
--  PURPOSE
--              This procedure returns the assignment with the given
--              person, in the given project and with the given date
--  PARAMETERS
--              p_person_id IN - mandatory
--              p_project_id IN - mandatory
--              p_ei_date IN - mandatory
--              x_assignment_name IN OUT - may not be passed in
--              x_assignment_id OUT - NULL if not found or multiple found
--              x_return_status OUT - S if single assignment found
--                                    E if not found or multiple found
--                                    U otherwise
--              x_error_message_code OUT
--
PROCEDURE Get_Person_Asgmt
            ( p_person_id          IN pa_resources_denorm.person_id%TYPE
             ,p_project_id         IN pa_project_assignments.project_id%TYPE
             ,p_ei_date            IN DATE
             ,x_assignment_name    IN OUT NOCOPY pa_project_assignments.assignment_name%TYPE --File.Sql.39 bug 4440895
             ,x_assignment_id      OUT NOCOPY pa_project_assignments.assignment_id%TYPE --File.Sql.39 bug 4440895
         ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_error_message_code OUT NOCOPY VARCHAR2)  IS --File.Sql.39 bug 4440895

l_row_count NUMBER := 0;
l_found boolean := FALSE;
l_assignment_id pa_project_assignments.assignment_id%TYPE;
l_assignment_name pa_project_assignments.assignment_name%TYPE;

CURSOR get_assignment_with_name IS
SELECT assignment_id, assignment_name
FROM pa_proj_assignments_actuals_v
WHERE project_id = p_project_id
AND   person_id = p_person_id
AND   p_ei_date between start_date and end_date
AND   assignment_name = x_assignment_name
ORDER BY assignment_start_date DESC;

CURSOR get_assignment_without_name IS
SELECT assignment_id, assignment_name
FROM pa_proj_assignments_actuals_v
WHERE project_id = p_project_id
AND   person_id = p_person_id
AND   p_ei_date between start_date and end_date
ORDER BY assignment_start_date DESC;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --dbms_output.put_line ('Assignment Name is ' || x_assignment_name);

  IF x_assignment_name IS NOT NULL AND x_assignment_name <> FND_API.G_MISS_CHAR THEN

     IF p_person_id = g_person_id_w_name AND p_project_id = g_project_id_w_name AND p_ei_date = g_ei_date_w_name AND x_assignment_name = g_in_asgmt_name THEN
        l_found := TRUE;
        --x_assignment_name := x_assignment_name;
        x_assignment_id := g_assignment_id_w_name;
        --dbms_output.put_line ('Flow 1. Reading cache value');
     ELSE
        l_found := FALSE;
        OPEN get_assignment_with_name;
        LOOP
          FETCH get_assignment_with_name INTO l_assignment_id, l_assignment_name;
          EXIT WHEN get_assignment_with_name%NOTFOUND;
        END LOOP;
        l_row_count := get_assignment_with_name%ROWCOUNT;
        CLOSE get_assignment_with_name;

        IF l_row_count <> 0 THEN
           g_person_id_w_name := p_person_id;
           g_project_id_w_name := p_project_id;
           g_ei_date_w_name := p_ei_date;
           g_in_asgmt_name := l_assignment_name;
           g_assignment_id_w_name := l_assignment_id;
        END IF;

     END IF;

  ELSE

     IF p_person_id = g_person_id_wo_name AND p_project_id = g_project_id_wo_name AND p_ei_date = g_ei_date_wo_name THEN
        l_found := TRUE;
        x_assignment_name := g_out_asgmt_name;
        x_assignment_id := g_assignment_id_wo_name;
        --dbms_output.put_line ('Flow 2. Reading cache value');
     ELSE
        l_found := FALSE;
        OPEN get_assignment_without_name;
        LOOP
          FETCH get_assignment_without_name INTO l_assignment_id, l_assignment_name;
          EXIT WHEN get_assignment_without_name%NOTFOUND;
        END LOOP;
        l_row_count := get_assignment_without_name%ROWCOUNT;
        CLOSE get_assignment_without_name;

        IF l_row_count <> 0 THEN
           g_person_id_wo_name := p_person_id;
           g_project_id_wo_name := p_project_id;
           g_ei_date_wo_name := p_ei_date;
           g_assignment_id_wo_name := l_assignment_id;
           g_out_asgmt_name := l_assignment_name;
        END IF;
     END IF;

  END IF;

  IF NOT l_found THEN
     IF l_row_count = 0 THEN
        g_person_id_w_name := NULL;
        g_project_id_w_name := NULL;
        g_ei_date_w_name := NULL;
        g_person_id_wo_name := NULL;
        g_project_id_wo_name := NULL;
        g_ei_date_wo_name := NULL;

        g_in_asgmt_name := NULL;
        g_assignment_id_w_name := NULL;
        g_assignment_id_wo_name := NULL;

        RAISE no_data_found;
     ELSE
       x_assignment_id := l_assignment_id;
       x_assignment_name := l_assignment_name;
     END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

        WHEN NO_DATA_FOUND THEN
                x_assignment_id := NULL;
                x_assignment_name := NULL;
            x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message_code := 'PA_NO_ASSIGNMENT';
        WHEN OTHERS THEN
                x_assignment_id := NULL;
                x_assignment_name := NULL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                RAISE;
END Get_Person_Asgmt;

------------------------------------------------------------------------------------
--
-- FUNCTION   : Get_Assignment_Measures
-- DESCRIPTION: This function gets the capacity hours of the resource who is working
--              on the project. Also sets the global variables
--              g_prvisional_hours - provisional hours of the assignment
--              g_confirmed_hours  - confirmed hours of the assignment
--              NOTE: This Function is solely used in discoverer report TR2
--              Workbook: Team Role Details Worksheet: Assignment Details
------------------------------------------------------------------------------------
FUNCTION Get_Assignment_Measures
         ( p_assignment_id        IN pa_project_assignments.assignment_id%TYPE
          ,p_resource_id          IN pa_project_assignments.resource_id%TYPE
          ,p_asgn_effort          IN pa_project_assignments.assignment_effort%TYPE
          ,p_asgn_start_date      IN pa_project_assignments.start_date%TYPE
          ,p_asgn_end_date        IN pa_project_assignments.end_date%TYPE
          ,p_multiple_status_flag IN pa_project_assignments.multiple_status_flag%TYPE)
RETURN NUMBER
IS
l_res_capacity_hrs   NUMBER;
l_provisional_flag   VARCHAR2(1);
BEGIN
  SELECT sum(capacity_quantity)
  INTO   l_res_capacity_hrs
  FROM   pa_forecast_items
  WHERE  forecast_item_type = 'U'
  AND    delete_flag = 'N'
  AND    resource_id = p_resource_id
  AND    item_date BETWEEN p_asgn_start_date AND p_asgn_end_date;

  IF l_res_capacity_hrs IS NULL THEN
     l_res_capacity_hrs := 0;
  END IF;

  IF (p_multiple_status_flag = 'Y') THEN
     SELECT sum(item_quantity)
     INTO   g_provisional_hours
     FROM   pa_forecast_items
     WHERE  forecast_item_type = 'A'
     AND    delete_flag = 'N'
     AND    provisional_flag = 'Y'
     AND    assignment_id = p_assignment_id;
  ELSE
     SELECT provisional_flag
     INTO   l_provisional_flag
     FROM   pa_forecast_items
     WHERE  forecast_item_type = 'A'
     AND    delete_flag = 'N'
     AND    provisional_flag = 'Y'
     AND    assignment_id = p_assignment_id
     AND    resource_id = p_resource_id
     AND    item_date = p_asgn_start_date;

     IF l_provisional_flag = 'Y' THEN
        g_provisional_hours := p_asgn_effort;
     ELSE
        g_provisional_hours := 0;
     END IF;
  END IF;

  g_confirmed_hours := p_asgn_effort - g_provisional_hours;

  RETURN l_res_capacity_hrs;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      g_provisional_hours := 0;
      g_confirmed_hours := p_asgn_effort;
      RETURN l_res_capacity_hrs;
END Get_Assignment_Measures;

------------------------------------------------------------------------------------
--
-- FUNCTION   : Get_Asgn_Provisional_Hours
-- DESCRIPTION: This function gets the provisional hours of the assignment from
--              the global variable g_prvisional_hours
--              NOTE: This Function is solely used in discoverer report TR2
--              Workbook: Team Role Details Worksheet: Assignment Details
------------------------------------------------------------------------------------
FUNCTION Get_Asgn_Provisional_Hours
RETURN NUMBER
IS
BEGIN
RETURN g_provisional_hours;
END Get_Asgn_Provisional_Hours;

------------------------------------------------------------------------------------
--
-- FUNCTION   : Get_Asgn_Confirmed_Hours
-- DESCRIPTION: This function gets the confirmed hours of the assignment from
--              the global variable g_confirmed_hours
--              NOTE: This Function is solely used in discoverer report TR2
--              Workbook: Team Role Details Worksheet: Assignment Details
------------------------------------------------------------------------------------
FUNCTION Get_Asgn_Confirmed_Hours
RETURN NUMBER
IS
BEGIN
RETURN g_confirmed_hours;
END Get_Asgn_Confirmed_Hours;


------------------------------------------------------------------------------
--  PROCEDURE
--             Get Default Staffing Owner
--  PURPOSE
--              This procedure returns the default team role
--              staffing owner given the project_id and exp_org_id
--  HISTORY
--   29-APR-2003      shyugen       Created
--   10-JAN-2005      anigam       Bug 4103207.Added a condition in the cursor  'get_team_member' to check that current date lies between
--                                 effective_start_date and effective_end_date. And commented of the condition ROWNUM =1
------------------------------------------------------------------------------
PROCEDURE Get_Default_Staffing_Owner
            ( p_project_id  IN pa_projects_all.project_id%TYPE
             ,p_exp_org_id      IN pa_project_assignments.expenditure_org_id%TYPE := NULL
             ,x_person_id   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_person_name     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_person_id   NUMBER := null;
l_person_name PER_PEOPLE_F.full_name%TYPE := null;
l_exp_org_id pa_project_assignments.expenditure_org_id%TYPE := null;

CURSOR get_team_member(c_project_role_id NUMBER) IS
SELECT pp.resource_source_id, res.full_name
FROM pa_project_parties pp
    ,per_all_people_f res
WHERE pp.project_role_id = c_project_role_id
AND pp.resource_type_id = 101  -- Bug 4752052 - added to improve performance
AND TRUNC(sysdate) between TRUNC(pp.start_date_active) and TRUNC(nvl(pp.end_date_active, sysdate))
AND pp.project_id = p_project_id
AND pp.resource_source_id = res.person_id
AND trunc(SYSDATE) BETWEEN res.effective_start_date AND res.effective_end_date --added for bug 4103207
AND (res.current_employee_flag = 'Y' OR res.current_npw_flag = 'Y')-- Added for bug 4938392
and pp.object_type = 'PA_PROJECTS'
and pp.object_id = p_project_id; -- Bug Ref # 	6802604
--AND ROWNUM=1; Commented for bug 4103207


BEGIN

 IF p_exp_org_id IS NULL THEN
   SELECT carrying_out_organization_id INTO l_exp_org_id
     FROM pa_projects_all
    WHERE project_id = p_project_id;
 ELSE
   l_exp_org_id := p_exp_org_id;
 END IF;

 -- 1. Check if Project Staffing Owner exists
 OPEN get_team_member(8);
  FETCH get_team_member INTO l_person_id, l_person_name;
 CLOSE get_team_member;

 -- 2. If not, check if Primary Resource Contact exists
 IF (l_person_id IS NULL or l_person_name IS NULL) AND l_exp_org_id IS NOT NULL THEN
   l_person_id := PA_RESOURCE_UTILS.Get_Org_Prim_Contact_id(l_exp_org_id, 'PA_PRM_RES_PRMRY_CONTACT');
   l_person_name := PA_RESOURCE_UTILS.Get_Org_Prim_Contact_Name(l_exp_org_id, 'PA_PRM_RES_PRMRY_CONTACT');
 END IF;

 -- 3. If not, check if Project Manager exists
 IF l_person_id IS NULL or l_person_name IS NULL THEN
   OPEN get_team_member(1);
   FETCH get_team_member INTO l_person_id, l_person_name;
   CLOSE get_team_member;
 END IF;

 x_person_id := l_person_id;
 x_person_name := l_person_name;
 x_return_status := 'S';

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'S';
    x_person_id := null;
    x_person_name := null;

END Get_Default_Staffing_Owner;


------------------------------------------------------------------------------
--  PROCEDURE
--             Get All Staffing Owner
--  PURPOSE
--              This procedure returns the project and team role
--              staffing owners for a team role
--  HISTORY
--   29-APR-2003      shyugen       Created
------------------------------------------------------------------------------
PROCEDURE Get_All_Staffing_Owners
            ( p_assignment_id   IN pa_project_assignments.assignment_id%TYPE
             ,p_project_id      IN pa_projects_all.project_id%TYPE
             ,x_person_id_tbl   OUT NOCOPY system.pa_num_tbl_type --File.Sql.39 bug 4440895
             ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


 l_person_id_tbl system.pa_num_tbl_type;

CURSOR get_all_staffing_owners IS
 SELECT resource_source_id
   FROM pa_project_parties ,
        per_all_people_f ppf
  WHERE project_role_id  = 8
    AND resource_type_id = 101 -- Bug 4752052 - added to improve performance
    AND TRUNC ( sysdate ) BETWEEN TRUNC ( start_date_active ) AND TRUNC ( NVL ( end_date_active, sysdate ) )
    AND project_id    = p_project_id
    AND object_type   = 'PA_PROJECTS' -- Bug Ref # 6802604
    AND object_id     = p_project_id  -- Bug Ref # 6802604
    AND ppf.person_id = resource_source_id -- Bug Ref # 6802697
    AND TRUNC ( sysdate ) BETWEEN effective_start_date AND effective_end_date
    AND ( ppf.current_employee_flag = 'Y' OR ppf.current_npw_flag        = 'Y' )
UNION ALL
 SELECT staffing_owner_person_id
   FROM pa_project_assignments,
        per_all_people_f ppf
  WHERE assignment_id = p_assignment_id
    AND ppf.person_id = staffing_owner_person_id -- Bug Ref # 6802697
    AND TRUNC ( sysdate ) BETWEEN effective_start_date AND effective_end_date
    AND ( ppf.current_employee_flag = 'Y' OR ppf.current_npw_flag        = 'Y' ) ;

BEGIN

  OPEN get_all_staffing_owners;
  FETCH get_all_staffing_owners BULK COLLECT INTO l_person_id_tbl;
  CLOSE get_all_staffing_owners;

  x_person_id_tbl := l_person_id_tbl;
  x_return_status := 'S';

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'S';
    x_person_id_tbl := null;
         -- 4537865 : Start
    x_error_message_code := NULL ;
         -- 4537865 :End
END Get_All_Staffing_Owners;

------------------------------------------------------------------------------
--  PROCEDURE
--             Associate Planning Resource
--  PURPOSE
--              This procedure finds and associate planning resource to
--              existing Team Roles when Resource List is changed on
--              the Workplan
--  HISTORY
--   11-MAR-2004      shyugen       Created
------------------------------------------------------------------------------
PROCEDURE Associate_Planning_Resources
            ( p_project_id             IN NUMBER
             ,p_old_resource_list_id   IN NUMBER
             ,p_new_resource_list_id   IN NUMBER
             ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_msg_count       OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
             ,x_msg_data        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS



TYPE number_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE var30_table_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE var80_table_type IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

l_msg_index_out NUMBER;

l_asgmt_res_format_id NUMBER := NULL;
l_req_res_format_id NUMBER := NULL;
l_proj_rec_ver_num NUMBER := NULL;

l_assignment_id_tbl number_table_type;
l_res_list_member_id_tbl number_table_type;

l_resource_source_id_tbl number_table_type;
l_fcst_job_id_tbl number_table_type;
l_exp_org_id_tbl number_table_type;
l_expenditure_type_tbl var30_table_type;
l_project_role_id_tbl number_table_type;
l_person_type_tbl var30_table_type;
l_assignment_name_tbl var80_table_type;


l_return_status VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;

cursor get_proj_rec_ver_num is
select record_version_number
from pa_projects_all
where project_id = p_project_id;

-- for FP-M, person_type is not tracked on a requirement

cursor get_req_res_list_member(c_req_res_format_id NUMBER) is
select asgn.assignment_id,
       asgn.fcst_job_id,
       asgn.expenditure_organization_id,
       asgn.expenditure_type,
       asgn.project_role_id,
       asgn.assignment_name
from pa_project_assignments asgn,
     pa_project_statuses ps
where asgn.project_id = p_project_id
and asgn.assignment_type = 'OPEN_ASSIGNMENT'
and asgn.status_code = ps.project_status_code(+)
and (ps.project_system_status_code = 'OPEN_ASGMT'
    OR ps.project_system_status_code IS NULL);
-- for FP-M, only 2 person types are supported in PA: CWK and EMP
-- A given person can be in multiple person types.  However, person cannot
-- be both CWK and EMP at the same time.

-- Bug 4221383: Cursor modified to get correct org_id, job_id and person_type
cursor get_asgmt_res_list_member(c_asgmt_res_format_id NUMBER)  is
select asgn.assignment_id,
       rta.person_id,
       aaf.job_id, --asgn.fcst_job_id,
       rd.resource_organization_id, --asgn.expenditure_organization_id,
       asgn.expenditure_type,
       asgn.project_role_id,
       decode(peo.current_employee_flag, 'Y', 'EMP', 'CWK'), --ppt.system_person_type,
       asgn.assignment_name
from pa_project_assignments asgn,
     pa_project_statuses ps,
     per_person_type_usages_f ptuf,
     per_person_types ppt,
     per_all_assignments_f aaf,
     pa_resource_txn_attributes rta,
     pa_resources_denorm rd,
     per_all_people_f peo
where asgn.project_id = p_project_id
and asgn.resource_id = rta.resource_id
and rta.person_id = aaf.person_id
and asgn.start_date between aaf.effective_start_date AND aaf.effective_end_date
and asgn.assignment_type <> 'OPEN_ASSIGNMENT'
and asgn.status_code = ps.project_status_code(+)
and ps.project_system_status_code <> 'STAFFED_ASGMT_CANCEL'
and rta.person_id = ptuf.person_id
and ptuf.person_type_id = ppt.person_type_id
and ppt.system_person_type in ('CWK', 'EMP')
and asgn.start_date between ptuf.effective_start_date AND ptuf.effective_end_date
and asgn.start_date between rd.resource_effective_start_date AND rd.resource_effective_end_date
and rd.resource_id = asgn.resource_id
and aaf.assignment_type in ('C','E')
and aaf.primary_flag = 'Y'
and peo.person_id = aaf.person_id
and asgn.start_date between peo.effective_start_date AND peo.effective_end_date;
/*select asgn.assignment_id,
       rta.person_id,
       asgn.fcst_job_id,
       asgn.expenditure_organization_id,
       asgn.expenditure_type,
       asgn.project_role_id,
       ppt.system_person_type,
       asgn.assignment_name
from pa_project_assignments asgn,
     pa_project_statuses ps,
     per_person_type_usages_f ptuf,
     per_person_types ppt,
     per_all_assignments_f aaf,
     pa_resource_txn_attributes rta
where asgn.project_id = p_project_id
and asgn.resource_id = rta.resource_id
and rta.person_id = aaf.person_id
and asgn.start_date between aaf.effective_start_date AND aaf.effective_end_date
and asgn.assignment_type <> 'OPEN_ASSIGNMENT'
and asgn.status_code = ps.project_status_code(+)
and ps.project_system_status_code <> 'STAFFED_ASGMT_CANCEL'
and rta.person_id = ptuf.person_id
and ptuf.person_type_id = ppt.person_type_id
and ppt.system_person_type in ('CWK', 'EMP')
and asgn.start_date between ptuf.effective_start_date AND ptuf.effective_end_date;
*/
cursor team_role_exists is
SELECT 'T'
from pa_project_assignments
where resource_list_member_id is not null
and project_id = p_project_id
and rownum = 1;

l_team_role_exists VARCHAR2(1):= 'F';
l_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); -- 5345129

BEGIN
  IF l_debug_mode = 'Y' THEN -- 5345129
        pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENT_UTILS.Associate_Planning_Resources'
              ,x_msg         => 'old_pls_id='||p_old_resource_list_id||
                                'new_pls_id='||p_new_resource_list_id
              ,x_log_level   => li_message_level);
  END IF;

  -- Get the default resource formats for team role creation/update
  -- if the resource list has been changed on the workplan
  IF NOT(p_old_resource_list_id is null and p_new_resource_list_id is null) AND
     NOT(p_old_resource_list_id is not null AND
         p_new_resource_list_id is not null AND
         p_old_resource_list_id = p_new_resource_list_id) THEN

/* Bug 3647692
    -- Disallow workplan resource list from changing if
    -- there exist project team roles already associated to
    -- planning resources in the resource list
    OPEN team_role_exists;
    FETCH team_role_exists INTO l_team_role_exists;
    CLOSE team_role_exists;

    IF l_team_role_exists = 'T' THEN
      PA_UTILS.Add_Message(p_app_short_name => 'PA',
                           p_msg_name => 'PA_NO_UP_RL_TR');
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
*/
    IF p_new_resource_list_id is not null THEN
      PA_PLANNING_RESOURCE_UTILS.Get_Res_Format_for_Team_Role(
          p_resource_list_id => p_new_resource_list_id
         ,x_asgmt_res_format_id => l_asgmt_res_format_id
         ,x_req_res_format_id => l_req_res_format_id
         ,x_return_status => l_return_status);
      --dbms_output.put_line ('x_return_status ' || l_return_status);
      --dbms_output.put_line ('Assignment res format ' || l_asgmt_res_format_id);
      --dbms_output.put_line ('Requirement res format ' || l_req_res_format_id);
      IF l_debug_mode = 'Y' THEN -- 5345129
        pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENT_UTILS.Associate_Planning_Resources'
                  ,x_msg         => 'asgmt_format_id='||l_asgmt_res_format_id||
                                    'req_format_id='||l_req_res_format_id
                  ,x_log_level   => li_message_level);
      END IF;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        RETURN;
      END IF;

    ELSE
      l_asgmt_res_format_id := null;
      l_req_res_format_id := null;

    END IF;

    OPEN get_proj_rec_ver_num;
    FETCH get_proj_rec_ver_num INTO l_proj_rec_ver_num;
    CLOSE get_proj_rec_ver_num;

    -- store default formats
    pa_resource_setup_pvt.UPDATE_ADDITIONAL_STAFF_INFO
         ( p_init_msg_list => FND_API.G_FALSE
          ,p_validate_only => FND_API.G_FALSE
          ,p_project_id    => p_project_id
          ,p_record_version_number => l_proj_rec_ver_num
          ,p_proj_req_res_format_id  => l_req_res_format_id
          ,p_proj_asgmt_res_format_id   => l_asgmt_res_format_id
          ,x_return_status        => l_return_status
          ,x_msg_count            => x_msg_count
          ,x_msg_data             => x_msg_data        );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

    -- get all requirements and corresponding planning resource
    OPEN get_req_res_list_member(l_req_res_format_id);
    FETCH get_req_res_list_member BULK COLLECT INTO
         l_assignment_id_tbl,
         l_fcst_job_id_tbl,
         l_exp_org_id_tbl,
         l_expenditure_type_tbl,
         l_project_role_id_tbl,
         l_assignment_name_tbl;
    CLOSE get_req_res_list_member;

    --dbms_output.put_line ('Assignments to be updated' || l_assignment_id_tbl.COUNT);

    -- update planning resource on Project team roles only because
    -- resource list cannot be changed on the workplan once task
    -- assignment has been created.
    IF l_assignment_id_tbl.COUNT > 0 THEN

      FOR j IN l_assignment_id_tbl.FIRST .. l_assignment_id_tbl.LAST LOOP

       IF l_req_res_format_id IS NOT NULL THEN
        l_res_list_member_id_tbl(j) := Pa_Planning_Resource_Utils.Derive_Resource_List_Member(p_project_id,
                                                              l_req_res_format_id,
                                                              NULL,
                                                              l_fcst_job_id_tbl(j),
                                                              l_exp_org_id_tbl(j),
                                                              l_expenditure_type_tbl(j),
                                                              NULL,
                                                              l_project_role_id_tbl(j),
                                                              NULL,
                                                              l_assignment_name_tbl(j));
       ELSE
        l_res_list_member_id_tbl(j) := NULL;
       END IF;
      END LOOP;

      FORALL i IN l_assignment_id_tbl.FIRST .. l_assignment_id_tbl.LAST
        UPDATE pa_project_assignments
         SET resource_list_member_id = l_res_list_member_id_tbl(i),
             record_version_number = nvl(record_version_number,0) + 1
         WHERE assignment_id = l_assignment_id_tbl(i);

    END IF;

    -- get all assignment and corresponding planning resource
      OPEN get_asgmt_res_list_member(l_asgmt_res_format_id);
      FETCH get_asgmt_res_list_member BULK COLLECT INTO
         l_assignment_id_tbl,
         l_resource_source_id_tbl,
         l_fcst_job_id_tbl,
         l_exp_org_id_tbl,
         l_expenditure_type_tbl,
         l_project_role_id_tbl,
         l_person_type_tbl,
         l_assignment_name_tbl;
      CLOSE get_asgmt_res_list_member;

    -- dbms_output.put_line ('Requirements to be updated' || l_assignment_id_tbl.COUNT);

    -- update planning resource on Project team roles only because
    -- resource list cannot be changed on the workplan once task
    -- assignment has been created.
    IF l_assignment_id_tbl.COUNT > 0 THEN

      FOR j IN l_assignment_id_tbl.FIRST .. l_assignment_id_tbl.LAST LOOP

       IF l_asgmt_res_format_id IS NOT NULL THEN
        l_res_list_member_id_tbl(j) := Pa_Planning_Resource_Utils.Derive_Resource_List_Member(p_project_id,
                                                              l_asgmt_res_format_id,
                                                              l_resource_source_id_tbl(j),
                                                              l_fcst_job_id_tbl(j),
                                                              l_exp_org_id_tbl(j),
                                                              l_expenditure_type_tbl(j),
                                                              NULL,
                                                              l_project_role_id_tbl(j),
                                                              l_person_type_tbl(j),
                                                              l_assignment_name_tbl(j));
       ELSE
        l_res_list_member_id_tbl(j) := NULL;
       END IF;
      END LOOP;

      FORALL i IN l_assignment_id_tbl.FIRST .. l_assignment_id_tbl.LAST
        UPDATE pa_project_assignments
         SET resource_list_member_id = l_res_list_member_id_tbl(i),
             record_version_number = nvl(record_version_number, 0) + 1
         WHERE assignment_id = l_assignment_id_tbl(i);

    END IF;

  END IF;  -- resource list changed

  x_return_status := l_return_status;

  x_msg_count :=  FND_MSG_PUB.Count_Msg;

  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;
-- 4537865 : Included Exception block
EXCEPTION
	WHEN OTHERS THEN
	x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
	x_msg_count := 1 ;
	x_msg_data := SUBSTRB(SQLERRM,1,240);

	Fnd_Msg_Pub.add_exc_msg
               (  p_pkg_name        => 'PA_ASSIGNMENT_UTILS'
                , p_procedure_name  => 'ASSOCIATE_PLANNING_RESOURCES'
                , p_error_text      => x_msg_data);

	RAISE;
END Associate_Planning_Resources;

/* Added new function to check if team role is associated with multiple assignement
                                                  or requirement for bug 3724780*/

FUNCTION Get_multi_team_role_flag

RETURN VARCHAR2 IS

l_flag varchar2(1) ;

BEGIN

 l_flag := 'N';

 l_flag := PA_TASK_ASSIGNMENT_UTILS.p_multi_asgmt_req_flag;

   RETURN l_flag;

EXCEPTION

WHEN OTHERS THEN

   NULL;

   RETURN l_flag;

END;

/* the query logic must be same as pa_task_assignment_utils.Get_Team_Role */

FUNCTION Get_project_assignment_id
           (p_resource_list_member_id IN NUMBER,
            p_project_id IN NUMBER) RETURN NUMBER IS

Cursor C_ASMT_ID IS
select distinct pap.assignment_id
  from pa_project_assignments pap, pa_project_statuses stat
 where pap.resource_list_member_id = p_resource_list_member_id
   and pap.project_id = p_project_id
   and pap.STATUS_CODE = stat.PROJECT_STATUS_CODE (+)
   and nvl(stat.PROJECT_SYSTEM_STATUS_CODE, '-1') not  in ('OPEN_ASGMT_CANCEL','STAFFED_ASGMT_CANCEL', 'OPEN_ASGMT_FILLED');

l_asmt_id NUMBER;

BEGIN
  IF p_resource_list_member_id IS NOT NULL THEN
   OPEN C_ASMT_ID;
   Fetch C_ASMT_ID INTO l_asmt_id;
   CLOSE C_ASMT_ID;
   RETURN l_asmt_id;
  ELSE
   RETURN null;
  END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN null;
END;

/* the query logic must be same as pa_task_assignment_utils.Get_Team_Role */
FUNCTION Get_project_assignment_type
           (p_resource_list_member_id IN NUMBER,
            p_project_id IN NUMBER) RETURN VARCHAR2 IS

Cursor C_ASMT_TYPE IS
select distinct pap.assignment_type
  from pa_project_assignments pap, pa_project_statuses stat
 where pap.resource_list_member_id = p_resource_list_member_id
   and pap.project_id = p_project_id
   and pap.STATUS_CODE = stat.PROJECT_STATUS_CODE (+)
   and nvl(stat.PROJECT_SYSTEM_STATUS_CODE, '-1') not  in ('OPEN_ASGMT_CANCEL','STAFFED_ASGMT_CANCEL', 'OPEN_ASGMT_FILLED');

l_asmt_type VARCHAR2(30);

BEGIN
  IF p_resource_list_member_id IS NOT NULL THEN
   OPEN C_ASMT_TYPE;
   Fetch C_ASMT_TYPE INTO l_asmt_type;
   CLOSE C_ASMT_TYPE;
   RETURN l_asmt_type;
  ELSE
   RETURN null;
  END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN null;
END;




FUNCTION Check_Res_Format_Used_For_TR(p_res_format_id IN NUMBER, p_resource_list_id IN NUMBER)
RETURN VARCHAR2
IS
    l_format_used_flag VARCHAR2(1);
BEGIN
    SELECT 'Y'
    INTO l_format_used_flag
    FROM pa_projects_all pa,
             pa_proj_fp_options pfo
    WHERE (pa.proj_req_res_format_id = p_res_format_id OR pa.proj_asgmt_res_format_id = p_res_format_id)
    AND pa.project_id = pfo.project_id
    AND pfo.cost_resource_list_id = p_resource_list_id
    AND pfo.fin_plan_type_id = (SELECT fin_plan_type_id
                                    FROM pa_fin_plan_types_b
                                    WHERE use_for_workplan_flag = 'Y')
    AND pfo.fin_plan_option_level_code = 'PLAN_TYPE'
    AND rownum = 1;

    RETURN l_format_used_flag;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'N';
END;

FUNCTION Get_single_submitted_status(p_project_id IN NUMBER, p_resource_list_member_id IN NUMBER)
RETURN VARCHAR2 IS
Cursor C_Team_Role_Count IS
select count(*) from pa_project_assignments pa
  where pa.project_id =  p_project_id
  and pa.resource_list_member_id = p_resource_list_member_id;

Cursor C_Submitted_Count IS
select count(*) from pa_project_assignments pa
  where pa.project_id =  p_project_id
  and pa.resource_list_member_id = p_resource_list_member_id
  and pa.APPRVL_STATUS_CODE =  'ASGMT_APPRVL_SUBMITTED';

  l_team_role_count NUMBER;
  l_submitted_count NUMBER;
  l_single_submitted_flag  VARCHAR2(1) := 'N';

BEGIN

  OPEN C_Team_Role_Count;
  Fetch C_Team_Role_Count INTO l_team_role_count;
  CLOSE C_Team_Role_Count;

  IF l_team_role_count = 1 THEN

    OPEN C_Submitted_Count;
	Fetch C_Submitted_Count INTO l_submitted_count;
	CLOSE C_Submitted_Count;

    IF l_submitted_count = 1 THEN
      l_single_submitted_flag := 'Y';
	END IF;

  END IF;

  return l_single_submitted_flag;

EXCEPTION WHEN OTHERS THEN

RETURN 'N';
END;

------------------------------------------------------------------------------
--  FUNCTION
--
--  PURPOSE
--             This function checks if the resource list member_id has task assignment's beyond team role dates
--  HISTORY
--   09-15-2004      jraj       Created
------------------------------------------------------------------------------
FUNCTION Get_At_Risk_Status(p_project_id IN NUMBER, p_resource_list_member_id IN NUMBER, p_budget_version_id IN NUMBER, p_start IN VARCHAR2)
RETURN VARCHAR2 IS

Cursor C_At_Risk_Start IS
select ra.schedule_start_date, pa.start_date, pa.end_date
from pa_resource_assignments ra , pa_project_assignments pa
where pa.assignment_id = ra.project_assignment_id
and ra.project_id = p_project_id
and ra.budget_version_id = p_budget_version_id
and ra.resource_list_member_id = p_resource_list_member_id;
C_At_Risk_Start_Rec C_At_Risk_Start%ROWTYPE;

Cursor C_At_Risk_End IS
select ra.schedule_end_date, pa.end_date, pa.start_date
from pa_resource_assignments ra , pa_project_assignments pa
where pa.assignment_id = ra.project_assignment_id
and ra.project_id = p_project_id
and ra.budget_version_id = p_budget_version_id
and ra.resource_list_member_id = p_resource_list_member_id;
C_At_Risk_End_Rec C_At_Risk_End%ROWTYPE;

l_risk_status  VARCHAR2(1) := 'N';

BEGIN

IF p_start = 'Y' THEN

  OPEN C_At_Risk_Start;
   Fetch C_At_Risk_Start INTO C_At_Risk_Start_rec;


   IF (C_At_Risk_Start_Rec.start_date > C_At_Risk_Start_Rec.schedule_start_date)  OR
      (C_At_Risk_Start_Rec.end_date   < C_At_Risk_Start_Rec.schedule_start_date)  THEN

    l_risk_status := 'Y';

   END IF;

  WHILE C_At_Risk_Start%FOUND LOOP
   Fetch C_At_Risk_Start INTO C_At_Risk_Start_rec;


    IF (C_At_Risk_Start_Rec.start_date > C_At_Risk_Start_Rec.schedule_start_date)  OR
       (C_At_Risk_Start_Rec.end_date   < C_At_Risk_Start_Rec.schedule_start_date)  THEN

      l_risk_status := 'Y';

    END IF;

   END LOOP;

  CLOSE C_At_Risk_Start;

ELSIF p_start = 'N' THEN
  OPEN C_At_Risk_End;
  Fetch C_At_Risk_End INTO C_At_Risk_End_rec;

  IF (C_At_Risk_End_Rec.end_date   < C_At_Risk_End_Rec.schedule_end_date) OR
     (C_At_Risk_End_Rec.start_date > C_At_Risk_End_Rec.schedule_end_date) THEN

    l_risk_status := 'Y';

  END IF;

  WHILE C_At_Risk_End%FOUND LOOP
   Fetch C_At_Risk_End INTO C_At_Risk_End_rec;
   IF (C_At_Risk_End_Rec.end_date   < C_At_Risk_End_Rec.schedule_end_date) OR
     (C_At_Risk_End_Rec.start_date > C_At_Risk_End_Rec.schedule_end_date) THEN

    l_risk_status := 'Y';

  END IF;
  END LOOP;
  CLOSE C_At_Risk_End;
END IF;



  return l_risk_status;

EXCEPTION WHEN OTHERS THEN

RETURN 'N';
END;



FUNCTION Get_Team_Role_Start(p_project_id IN NUMBER, p_resource_list_member_id IN NUMBER)
RETURN DATE IS
Cursor C_Team_Role_Start IS

select min(pap.start_date) team_role_start
from pa_project_assignments pap, pa_project_statuses stat
where
pap.resource_list_member_id = p_resource_list_member_id
and pap.project_id = p_project_id
and
pap.STATUS_CODE = stat.PROJECT_STATUS_CODE (+) and
nvl(stat.PROJECT_SYSTEM_STATUS_CODE, '-1') not  in
('OPEN_ASGMT_CANCEL','STAFFED_ASGMT_CANCEL', 'OPEN_ASGMT_FILLED');
C_Team_Role_Start_Rec C_Team_Role_Start%ROWTYPE;


BEGIN
OPEN C_Team_Role_Start;
FETCH C_Team_Role_Start INTO C_Team_Role_Start_Rec;
CLOSE C_Team_Role_Start;

RETURN C_Team_Role_Start_Rec.team_role_start;
EXCEPTION WHEN OTHERS THEN
RETURN to_date(NULL);
END;



FUNCTION Get_Team_Role_End(p_project_id IN NUMBER, p_resource_list_member_id IN NUMBER)
RETURN DATE IS
Cursor C_Team_Role_End IS
select max(pap.End_date) team_role_End
from pa_project_assignments pap, pa_project_statuses stat
where
pap.resource_list_member_id = p_resource_list_member_id
and pap.project_id = p_project_id
and
pap.STATUS_CODE = stat.PROJECT_STATUS_CODE (+) and
nvl(stat.PROJECT_SYSTEM_STATUS_CODE, '-1') not  in
('OPEN_ASGMT_CANCEL','STAFFED_ASGMT_CANCEL', 'OPEN_ASGMT_FILLED');
C_Team_Role_End_Rec C_Team_Role_End%ROWTYPE;


BEGIN
OPEN C_Team_Role_End;
FETCH C_Team_Role_End INTO C_Team_Role_End_Rec;
CLOSE C_Team_Role_End;

RETURN C_Team_Role_End_Rec.team_role_End;
EXCEPTION WHEN OTHERS THEN
RETURN to_date(NULL);
END;

-- 4363092 Added following function for MOAC Changes
-- returns default org_id

FUNCTION Get_Dft_Info
RETURN NUMBER IS

l_dflt_ou hr_operating_units.organization_id%TYPE;
l_ou_count NUMBER;
l_dflt_ou_name hr_operating_units.name%TYPE;

l_proj_imp_flag VARCHAR2(1) := 'N';

Cursor c_imp_ous IS
select org_id
from pa_implementations where rownum = 1;

Cursor c_check_proj_imp(p_org_id NUMBER ) IS
select 'Y'
from pa_implementations
where org_id = p_org_id ;

l_ou_id hr_operating_units.organization_id%TYPE;

BEGIN

    PA_MOAC_UTILS.GET_DEFAULT_OU
        (
            p_product_code      => 'PA',
            p_default_org_id    =>  l_dflt_ou,
            p_default_ou_name   =>  l_dflt_ou_name,
            p_ou_count          =>  l_ou_count
        );

    IF l_dflt_ou IS NOT NULL THEN

        OPEN c_check_proj_imp(l_dflt_ou);
        FETCH c_check_proj_imp INTO l_proj_imp_flag;
        CLOSE c_check_proj_imp;

        IF l_proj_imp_flag = 'Y' THEN
            l_ou_id := l_dflt_ou;
        END IF;

    END IF;

    IF l_dflt_ou IS NULL OR l_proj_imp_flag = 'N' THEN

        OPEN c_imp_ous;
        FETCH c_imp_ous INTO l_ou_id;
        CLOSE c_imp_ous;

    END IF;

    RETURN l_ou_id;

END Get_Dft_Info;

END PA_ASSIGNMENT_UTILS;

/
