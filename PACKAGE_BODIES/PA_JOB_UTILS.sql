--------------------------------------------------------
--  DDL for Package Body PA_JOB_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_JOB_UTILS" AS
-- $Header: PAJBUTLB.pls 120.5.12010000.4 2009/04/21 05:50:33 snizam ship $


--------------------------------------------------------------------------------------------------------------
-- This procedure prints the text which is being passed as the input
-- Input parameters
-- Parameters                   Type           Required  Description
--  p_log_msg                   VARCHAR2        YES      It stores text which you want to print on screen
-- Out parameters
----------------------------------------------------------------------------------------------------------------
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
-- Added Debug Profile Option  variable initialization for bug#5094780
G_HR_CROSS_BUSINESS_GROUP varchar2(1) :=  fnd_profile.value('HR_CROSS_BUSINESS_GROUP');
G_PA_PROJ_RES_JOB_GRP NUMBER := to_number(fnd_profile.value('PA_PROJ_RES_JOB_GRP'));

PROCEDURE log_message (p_log_msg IN VARCHAR2)
IS
BEGIN
    --dbms_output.put_line('log: ' || p_log_msg);
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.write('log_message: ' || 'HR_UPDATE_API', 'log: ' || p_log_msg, 3);
    END IF;
    NULL;
END log_message;

--
--  PROCEDURE
--              Check_JobName_Or_Id
--  PURPOSE
--              This procedure does the following
--              If Job name is passed converts it to the id
--		If Job Id is passed,
--		based on the check_id_flag validates it
--  HISTORY
--   27-JUN-2000      P.Bandla       Created
--   11-APR-2001      virangan       Added LOV fixes
--   27-APR-2001      virangan       Removed LOV fixes
--
 PROCEDURE Check_JobName_Or_Id(
			 p_job_id		IN	NUMBER,
			 p_job_name		IN	VARCHAR2,
			 p_check_id_flag	IN	VARCHAR2,
			 p_job_group_id         IN      NUMBER := NULL, -- 5130421
			 x_job_id		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
			 x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			 x_error_message_code	OUT	NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
 BEGIN
	IF p_job_id IS NOT NULL AND p_job_id<>FND_API.G_MISS_NUM THEN
		IF p_check_id_flag = 'Y' THEN
			 SELECT job_id
			 INTO   x_job_id
		         FROM   per_jobs
		         WHERE  job_id = p_job_id
                         AND job_group_id = nvl(p_job_group_id, job_group_id) -- 5130421
                         ;
	        ELSE
		         x_job_id := p_job_id;
	        END IF;
        ELSE
	        SELECT job_id
	        INTO   x_job_id
	        FROM   per_jobs
	        WHERE  name = p_job_name
                AND job_group_id = nvl(p_job_group_id, job_group_id) -- 5130421
                ;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_JOB_INVALID_AMBIGUOUS';
        WHEN TOO_MANY_ROWS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_JOB_INVALID_AMBIGUOUS';
        WHEN OTHERS THEN
        --PA_Error_Utils.Set_Error_Stack
        -- (`pa_job_utils.check_jobname_or_id');
           -- This sets the current program unit name in the
           -- error stack. Helpful in Debugging
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

 END Check_JobName_Or_id;

--
--  PROCEDURE
--              Check_JobLevel
--  PURPOSE
--              This procedure validates the job level.
--  HISTORY
--   04-AUG-2000      P.Bandla	 Created
--   24-DEC-2001      A.Abdullah Modified to reflect the change in job
--                               level implementation
--                               It checks from pa_setup_job_levels_v if
--                               the job level exists
--

 PROCEDURE Check_JobLevel(
			 p_level		IN	NUMBER,
			 x_valid		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			 x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			 x_error_message_code	OUT	NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
 IS
	l_level NUMBER;

        CURSOR joblevels IS
            select job_level
            from PA_SETUP_JOB_LEVELS_V
            where job_level = p_level;

 BEGIN
        OPEN joblevels;
        FETCH joblevels into l_level;

        IF l_level IS NOT NULL  THEN
           x_valid := 'Y' ;
           x_return_status := FND_API.G_RET_STS_SUCCESS;
        ELSE
           x_valid := 'N';
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_error_message_code := 'PA_JOBLEVEL_INVALID_AMBIGUOUS';
        END IF;

        CLOSE joblevels;

 EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_JOBLEVEL_INVALID_AMBIGUOUS';
        WHEN OTHERS THEN
        --PA_Error_Utils.Set_Error_Stack
        -- (`pa_job_utils.check_jobname_or_id');
           -- This sets the current program unit name in the
           -- error stack. Helpful in Debugging
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

 END Check_JobLevel;

--  PROCEDURE
--              Check_Job_GroupName_Or_Id
--  PURPOSE
--              This procedure does the following
--              If job group name is passed converts it to the id
--              If job group Id is passed,
--              based on the check_id_flag validates it
--  HISTORY
--   21-NOV-2000      P. Bandla       Created
--   11-APR-2001      virangan        Added LOV fixes
--
 PROCEDURE Check_Job_GroupName_Or_Id(
			p_job_group_id		IN	NUMBER,
			p_job_group_name	IN	VARCHAR2,
			p_check_id_flag		IN	VARCHAR2,
			x_job_group_id		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
			x_return_status		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			x_error_message_code	OUT	NOCOPY VARCHAR2 )  --File.Sql.39 bug 4440895
 IS

      l_current_id NUMBER := NULL;
      l_num_ids NUMBER := 0;
      l_id_found_flag VARCHAR(1) := 'N';

      CURSOR j_ids IS
          SELECT job_group_id
          FROM per_job_groups
          WHERE displayed_name = p_job_group_name;
 BEGIN

	IF p_job_group_id IS NOT NULL AND p_job_group_id<>FND_API.G_MISS_NUM THEN
		IF p_check_id_flag = 'Y' THEN
			SELECT job_group_id
		        INTO   x_job_group_id
		        FROM   per_job_groups
		        WHERE  job_group_id = p_job_group_id;
	        ELSIF p_check_id_flag = 'N' THEN
			x_job_group_id := p_job_group_id;
                ELSIF (p_check_id_flag = 'A') THEN
                     IF (p_job_group_name IS NULL) THEN
                        -- Return a null ID since the name is null.
                        x_job_group_id := NULL;
                     ELSE
                        -- Find the ID which matches the Name passed
                        OPEN j_ids;
                        LOOP
                           FETCH j_ids INTO l_current_id;
                           EXIT WHEN j_ids%NOTFOUND;
                           IF (l_current_id = p_job_group_id) THEN
                              l_id_found_flag := 'Y';
                              x_job_group_id := p_job_group_id;
                           END IF;
                        END LOOP;
                        l_num_ids := j_ids%ROWCOUNT;
                        CLOSE j_ids;

                        IF (l_num_ids = 0) THEN
                           -- No IDs for name
                           RAISE NO_DATA_FOUND;
                        ELSIF (l_num_ids = 1) THEN
                           -- Since there is only one ID for the name use it.
                           x_job_group_id := l_current_id;
                        ELSIF (l_id_found_flag = 'N') THEN
                           -- More than one ID for the name and none of the IDs matched
                           -- the ID passed in.
                           RAISE TOO_MANY_ROWS;
                        END IF;
                     END IF;
		END IF;
        ELSE
            IF (p_job_group_name IS NOT NULL) THEN
		SELECT job_group_id
	        INTO   x_job_group_id
	        FROM   per_job_groups
	        WHERE  displayed_name = p_job_group_name;
            ELSE
               x_job_group_id := NULL;
            END IF;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
        WHEN NO_DATA_FOUND THEN
                x_job_group_id := NULL;
	        x_return_status := FND_API.G_RET_STS_ERROR;
		x_error_message_code := 'PA_JOBGROUP_INVALID';
        WHEN TOO_MANY_ROWS THEN
                x_job_group_id := NULL;
	        x_return_status := FND_API.G_RET_STS_ERROR;
		x_error_message_code := 'PA_JOBGROUP_INVALID';
        WHEN OTHERS THEN
                x_job_group_id := NULL;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

 END Check_Job_GroupName_Or_Id;

--
--
-- Procedure
-- created by Ranga Iyengar  : 05-DEC-2000
-- This Api validates the given job_id and job_group_id is a part of
-- the pa_job_relationships entity.the IN parameters will be job_id and
-- job_group_id
--
--
PROCEDURE validate_job_relationship
            ( p_job_id             IN  per_jobs.job_id%type
             ,p_job_group_id       IN  per_jobs.job_group_id%type
             ,x_return_status      OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
             ,x_error_message_code OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
            ) IS

        v_return_status        VARCHAR2(2000);
        v_error_message_code   VARCHAR2(2000):='PA_INVALID_JOB_RELATION';
                                   --'This Job Not  Belongs to Valid Job Group';
        v_job_group_id         per_jobs.job_group_id%type ;


BEGIN
        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_JOB_UTILS.validate_job_relationship');
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        SELECT job_group_id
        INTO   v_job_group_id
        FROM   per_jobs
        WHERE  job_id = p_job_id
         AND   job_group_id = p_job_group_id;

        If v_job_group_id is NOT NULL then
           v_return_status := FND_API.G_RET_STS_SUCCESS;
        End if;

        -- reset the Error stack
        PA_DEBUG.Reset_Err_Stack;
EXCEPTION

        WHEN NO_DATA_FOUND THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_error_message_code  := v_error_message_code;

        WHEN TOO_MANY_ROWS THEN
             x_return_status := FND_API.G_RET_STS_SUCCESS;

        WHEN OTHERS THEN
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_JOB_UTILS.validate_job_relationship'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;
END validate_job_relationship;


--------------------------------------------------------------------------------
-- Function:    Get_Proj_Res_Job_Group
-- Description: This function returns the project resource job group in the system
--------------------------------------------------------------------------------
Function Get_Proj_Res_Job_Group(p_job_id IN NUMBER)
RETURN NUMBER
IS
l_prjg_id           NUMBER;
l_business_group_id NUMBER;
BEGIN

/*Commented for 5094780
IF fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'Y'
  THEN
     log_message('CBGA Profile is Y');
     RETURN to_number(fnd_profile.value('PA_PROJ_RES_JOB_GRP'));
 else */
-- changed for 5094780
  IF G_HR_CROSS_BUSINESS_GROUP = 'Y'
  THEN
     log_message('CBGA Profile is Y');
     RETURN G_PA_PROJ_RES_JOB_GRP;
  ELSE
     log_message('CBGA Profile is N');

     -- if the p_job_id parameter is null, we get the business group id
     -- from the profile option: this method is also called from the
     -- parvw031.sql view
     IF p_job_id is null THEN

        log_message('Get business group id from profile option');
        l_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');

     ELSE

        log_message('Get business group id using job id');
        -- Get the business group of the job id
        SELECT BUSINESS_GROUP_ID
        INTO l_business_group_id
        FROM PER_JOBS
        WHERE job_id = p_job_id;

     END IF;

     log_message('l_business_group_id = ' || l_business_group_id);

     SELECT ORG_INFORMATION1
     INTO l_prjg_id
     FROM HR_ORGANIZATION_INFORMATION
     WHERE ORGANIZATION_ID=l_business_group_id
     AND ORG_INFORMATION_CONTEXT='Project Resource Job Group';

     log_message('PRJG id returned from context = ' || l_prjg_id);
     RETURN to_number(l_prjg_id);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  WHEN OTHERS THEN
      RETURN NULL;
END;

--------------------------------------------------------------------------------
-- Function:    Proj_Res_Job_Group_Exists
-- Description: This function checks if a Project Resource Job Group Exists
--              in the system. Returns 'Y' if it does and returns 'N' if it does
--              not.
--------------------------------------------------------------------------------
Function Proj_Res_Job_Group_Exists(p_job_id IN NUMBER)
RETURN VARCHAR2
IS
BEGIN
   IF Get_Proj_Res_Job_Group(p_job_id => p_job_id) is null THEN
      RETURN 'N';
   ELSE
      RETURN 'Y';
   END IF;
END;
--------------------------------------------------------------------------------
-- Function:    Is_Proj_Res_Job_Group
-- Description: This function checks if a job group passed in is a
--              Project Resource Job Group.
--              Returns 'Y' if it is and returns 'N' if it is not
--------------------------------------------------------------------------------
Function Is_Proj_Res_Job_Group(p_job_id       IN NUMBER,
                               p_job_group_id IN NUMBER)
RETURN VARCHAR2
IS
BEGIN
  IF p_job_group_id = Get_Proj_Res_Job_Group(p_job_id => p_job_id) THEN
     RETURN 'Y';
  ELSE
     RETURN 'N';
  END IF;
END;
--------------------------------------------------------------------------------
-- Function:    Get_Job_Mapping
-- Description: This function returns the job in the Project Resource Job
--              Group towhich p_job_id is mapped.
--              Returns the job_id of the job in PRJG
--------------------------------------------------------------------------------
Function Get_Job_Mapping(p_job_id       IN NUMBER,
                         p_job_group_id IN NUMBER)
RETURN NUMBER
IS
  l_master_job_id       NUMBER;
  l_master_job_group_id NUMBER;
  l_prjg_job_id         NUMBER;
  l_prjg_id             NUMBER;

  CURSOR get_master_job_to IS
           SELECT to_job_id,to_job_group_id
           FROM pa_job_relationships, per_job_groups pjg
           WHERE from_job_id = P_job_id
           AND from_job_group_id = P_job_group_id
           AND to_job_group_id = pjg.job_group_id
           AND pjg.master_flag = 'Y';

  CURSOR get_master_job_from IS
           SELECT from_job_id,from_job_group_id
           FROM pa_job_relationships, per_job_groups pjg
           WHERE to_job_id = P_job_id
           AND to_job_group_id = P_job_group_id
           AND from_job_group_id = pjg.job_group_id
           AND pjg.master_flag = 'Y';

  CURSOR get_prjg_job_to IS
           SELECT to_job_id
           FROM pa_job_relationships
           WHERE from_job_id = l_master_job_id
           AND from_job_group_id = l_master_job_group_id
           AND to_job_group_id = l_prjg_id;

  CURSOR get_prjg_job_from IS
           SELECT from_job_id
           FROM pa_job_relationships
           WHERE to_job_id = l_master_job_id
           AND to_job_group_id = l_master_job_group_id
           AND from_job_group_id = l_prjg_id;
BEGIN

   l_prjg_id := Get_Proj_Res_Job_Group(p_job_id => p_job_id);
   log_message('PRJG Job Group Id = ' || l_prjg_id);

   IF l_prjg_id is null THEN
      RETURN NULL;
   END IF;

   -- only if it is not a master job, do we use the master cursor
   IF(NOT check_master_job(p_job_id)) THEN

      log_message('Not a master job in Get Job Mapping');
      OPEN get_master_job_to;
      FETCH get_master_job_to INTO l_master_job_id,l_master_job_group_id;

      IF get_master_job_to%NOTFOUND THEN
         OPEN get_master_job_from;
         FETCH get_master_job_from INTO l_master_job_id,l_master_job_group_id;

         IF get_master_job_from%NOTFOUND THEN
            -- There is no mapping with the master job, so we cannot find the mapping
            -- with the Project Resource Job Group
	    CLOSE get_master_job_from ; -- Added for 5338664
	    CLOSE get_master_job_to ; -- Added for 5338664
            RETURN NULL;
	 ELSE -- Added for 5338664
	    CLOSE get_master_job_from ;
         END IF;
      END IF;

      IF get_master_job_to%ISOPEN THEN --Added for 5338664
      CLOSE get_master_job_to;
      END IF;

   ELSE
      log_message('Is a master job in Get Job Mapping');
      -- it's already a master job, so just assign to the local params
      l_master_job_id := p_job_id;
      l_master_job_group_id := p_job_group_id;
   END IF;

   IF Is_Proj_Res_Job_Group(p_job_id       => l_master_job_id,
                            p_job_group_id => l_master_job_group_id) = 'Y'
   THEN
       RETURN l_master_job_id;
   END IF;

   OPEN get_prjg_job_to;
   FETCH get_prjg_job_to INTO l_prjg_job_id;

   IF get_prjg_job_to%NOTFOUND THEN
      OPEN get_prjg_job_from;
      FETCH get_prjg_job_from INTO l_prjg_job_id;
      CLOSE get_prjg_job_from;
   END IF;
   CLOSE get_prjg_job_to;

   RETURN l_prjg_job_id;
END;

--------------------------------------------------------------------------------
-- Function:    Get_job_level
-- Description: This function returns the Job Level of the job passed in
--              by looking at the 'Project Job Level' DFF segmeent of the
--              'Job Category' DFF.
--------------------------------------------------------------------------------

FUNCTION get_job_level(p_job_id IN NUMBER)
RETURN NUMBER
IS
l_job_level       per_job_extra_info.jei_information4%type;
BEGIN

  SELECT jei_information4
  INTO l_job_level
  FROM per_job_extra_info
  WHERE job_id = p_job_id
  AND information_type = 'Job Category'
  AND jei_information4 IS NOT NULL; -- Bug 2898766

  log_message('Job Level in get_job_level = ' || l_job_level);
  RETURN TO_NUMBER(l_job_level);

EXCEPTION
/* Bug 2898766 - Handled the exception if more than one rows are returned */
  WHEN TOO_MANY_ROWS THEN
      l_job_level := '-99';
      RETURN TO_NUMBER(l_job_level);
  WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  WHEN OTHERS THEN
      RETURN NULL;
END;

--------------------------------------------------------------------------------
-- Function get_job_level
-- This function returns the job level DFF based on the job_id and Job_group_id
-- If there is no Project Resource Job Group (PRJG) in the system,
--     return the Job Level associated to the job.
-- If the Job belongs to a Job Group which is the PRJG,
--       Return the  Job Level.
-- Find the mapping of the job to a job in PRJG.
--       If no mapping, return null job group.
--       If there is mappping, return the job level associated to the job in PRJG.
--------------------------------------------------------------------------------

FUNCTION get_job_level
(P_job_id             IN  per_jobs.job_id%type,
 P_job_group_id       IN  per_job_groups.job_group_id%type)
RETURN NUMBER
IS
        l_job_level       per_job_extra_info.jei_information4%type;
        l_job_info_type   VARCHAR2(20) := 'Job Category';
        l_master_job_id   pa_job_relationships.to_job_id%type;
        l_job_id          per_jobs.job_id%type;
        l_job_mapping     NUMBER;
        c_job_group_id    NUMBER;


BEGIN

        /*IF Proj_Res_Job_Group_Exists(p_job_id => p_job_id) = 'N' THEN    -- Commented as part of the performance bug logged 6875253
           -- There is no Project Resource Job Group in the system, so
           -- pass back the passed in job's job level.
           log_message('No PRJG in system, get job level using Job Id');
           RETURN Get_Job_Level(p_job_id => p_job_id);
        END IF;

        -- Check if the Job group of the job is a PRJG
        IF Is_Proj_Res_Job_Group(p_job_id       => p_job_id,
                                 p_job_group_id => p_job_group_id) = 'Y'
        THEN
           -- The job group of the job is the Project Resource Job Group, so
           -- pass back the passed in job's job level.
           log_message('Job is in PRJG group, get job level using Job Id');
           RETURN Get_Job_Level(p_job_id => p_job_id);
        END IF;*/

        c_job_group_id := Get_Proj_Res_Job_Group(p_job_id => p_job_id);     -- newly added code in place of the above commented code -- 6875253

        IF 	c_job_group_id IS NULL THEN
            log_message('No PRJG in system, get job level using Job Id');
            RETURN Get_Job_Level(p_job_id => p_job_id);

        ELSE
             IF p_job_group_id = c_job_group_id  THEN
             	 log_message('Job is in PRJG group, get job level using Job Id');
             	 RETURN Get_Job_Level(p_job_id => p_job_id);
             END IF;
        END IF;

                -- Get the mapping with a job in PRJG
        log_message('Job is not in PRJG group, get mapping first');
        l_job_mapping := Get_Job_Mapping(p_job_id       => p_job_id,
                                         p_job_group_id => p_job_group_id);

        log_message('l_job_mapping_id = ' || l_job_mapping);
        IF l_job_mapping is null THEN
           RETURN NULL;
        ELSE
           RETURN Get_Job_Level(p_job_id => l_job_mapping);
        END IF;

END get_job_level;

-- This Function returns boolean value of true if a job is master job otherwise
-- it returns false -- IN parameter will be job_id
FUNCTION check_master_job(P_job_id  IN per_Jobs.job_id%type)
                       RETURN  boolean
IS
        v_job_group_id    per_jobs.job_group_id%type;
        v_master_flag     per_job_groups.master_flag%type;

BEGIN
        v_job_group_id := get_job_group_id(P_job_id);

        -- Bug 4350734 - Changed to base table from per_job_groups_v
        SELECT master_flag
        INTO   v_master_flag
        FROM   per_job_groups
        WHERE  job_group_id = v_job_group_id;

        if v_master_flag = 'Y' then
             return TRUE;
        else
             return FALSE;
        end if;
EXCEPTION

        WHEN NO_DATA_FOUND then
           return FALSE;

END check_master_job;

-- This API returns the job group id for the corresponding Job
FUNCTION get_job_group_id(
                          P_job_id             IN   per_jobs.job_id%type
                         ) RETURN per_job_groups.job_group_id%type
IS
        v_job_grp_id   per_job_groups.job_group_id%type;

BEGIN
        -- Bug 4350734 - Removed max sine it is not needed.

        SELECT job_group_id
        INTO   v_job_grp_id
        FROM   per_jobs
        WHERE  job_id = P_job_id;

        return (v_job_grp_id);

EXCEPTION

      WHEN NO_DATA_FOUND THEN --Bug 8263219
        return NULL;

END get_job_group_id;


--------------------------------------------------------------------------------
-- Function get_job_name
-- This function returns the job level DFF based on the job_id and Job_group_id
-- If there is no Project Resource Job Group (PRJG) in the system,
--     return the Job Level associated to the job.
-- If the Job belongs to a Job Group which is the PRJG,
--       Return the  Job Level.
-- Find the mapping of the job to a job in PRJG.
--       If no mapping, return null job group.
--       If there is mappping, return the job level associated to the job in PRJG.
--------------------------------------------------------------------------------

FUNCTION get_job_name
(P_job_id             IN  per_jobs.job_id%type,
 P_job_group_id       IN  per_job_groups.job_group_id%type)
RETURN VARCHAR2
IS
        l_mapped_job_id   NUMBER;
BEGIN
        -- If there is no Project Resource Job Group in the system or
        -- the Job group of the job is the PRJG, pass back the passed
        -- in job's job level.
        IF (Proj_Res_Job_Group_Exists(p_job_id => p_job_id) = 'N' OR
            Is_Proj_Res_Job_Group(p_job_id       => p_job_id,
                                  p_job_group_id => p_job_group_id) = 'Y') THEN
           log_message('No PRJG in system or job group=PRJG, get job level using Job Id');
           RETURN PA_HR_UPDATE_API.Get_Job_Name (p_job_id => p_job_id);
        END IF;

        -- Get the mapping with a job in PRJG
        log_message('Job is not in PRJG group, get mapping first');
        l_mapped_job_id := Get_Job_Mapping(p_job_id       => p_job_id,
                                           p_job_group_id => p_job_group_id);

        log_message('l_mapped_job_id = ' || l_mapped_job_id);
        IF l_mapped_job_id is null THEN
           RETURN NULL;
        ELSE
           RETURN PA_HR_UPDATE_API.Get_Job_Name(p_job_id => l_mapped_job_id);
        END IF;

END get_job_name;

-----------------------------------------------------------------------------
-- Procedure : check_job_relationships
-- This procedure checks if there are any relatioships existing in PA
-- for a given job_id.

-- Called by HR API, before deleting a job
-----------------------------------------------------------------------------

 PROCEDURE check_job_relationships (p_job_id IN number)
   IS
         l_job_relationship  PA_JOB_RELATIONSHIPS%ROWTYPE;
         Cursor C1 IS Select * from PA_JOB_RELATIONSHIPS where
                FROM_JOB_ID = p_job_id OR TO_JOB_ID = p_job_id;
        begin

        Open C1;
        fetch C1 into l_job_relationship;

        IF C1%FOUND Then
                Close C1;
                dbms_standard.raise_application_error
               (num => -20999
               ,msg => 'Relations involving this job exist in Projects. Please delete those relations before deleting the job!');
        END IF;

    Close C1;
  END check_job_relationships;

END pa_job_utils ;


/
