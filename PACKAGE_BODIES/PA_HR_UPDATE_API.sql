--------------------------------------------------------
--  DDL for Package Body PA_HR_UPDATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_HR_UPDATE_API" AS
-- $Header: PARHRUPB.pls 120.17.12010000.9 2010/03/24 07:00:35 vgovvala ship $

--FUNCTION Get_Country_name(p_country_code    VARCHAR2) RETURN VARCHAR2 ;

-- Global variable for debugging. Bug 4352236.
-- G_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
--------------------------------------------------------------------------------------------------------------
-- This procedure prints the text which is being passed as the input
-- Input parameters
-- Parameters                   Type           Required  Description
--  p_log_msg                   VARCHAR2        YES      It stores text which you want to print on screen
-- Out parameters
----------------------------------------------------------------------------------------------------------------
PROCEDURE log_message (p_log_msg IN VARCHAR2)

IS
-- P_DEBUG_MODE varchar2(1); -- Bug 4352236 - use global variable G_DEBUG_MODE
BEGIN
    --dbms_output.put_line('log: ' || p_log_msg);
    -- P_DEBUG_MODE := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
    -- IF (G_DEBUG_MODE ='Y') THEN
    pa_debug.write('HR_UPDATE_API', 'log: ' || p_log_msg, 3);
    -- END IF;
    -- NULL;
END log_message;

-- This API returns the job group id for the corresponding Job
FUNCTION get_job_group_id(
                          P_job_id             IN   per_jobs.job_id%type
                         ) RETURN per_job_groups.job_group_id%type
IS
        v_job_grp_id   per_job_groups.job_group_id%type;

BEGIN
        v_job_grp_id := PA_JOB_UTILS.get_job_group_id(P_job_id);

        return (v_job_grp_id);

END get_job_group_id;


-- This is an wrapper api for the check exp ou procedure
-- this function returns 'Y' if the given OU is valid otherwise it returns 'N'
FUNCTION validate_exp_OU (p_org_id   IN   NUMBER)
         return VARCHAR2  IS
	v_return_status       varchar2(1000);
        v_error_message_code  varchar2(1000);
BEGIN

      pa_hr_update_api.check_exp_OU(p_org_id               => p_org_id
                    ,x_return_status      => v_return_status
                    ,x_error_message_code => v_error_message_code
                    );

      If v_return_status = FND_API.G_RET_STS_SUCCESS then
            return 'Y';
      else
            return 'N';
      End if;



END validate_exp_OU;




-- This Function returns the job level DFF based on the job_id and Job_group_id
-- 24-Dec: Move the logic of the code to PA_JOB_UTILS and call the function here
FUNCTION get_job_level(
                       P_job_id             IN  per_jobs.job_id%type
                      ,P_job_group_id       IN  per_job_groups.job_group_id%type
                      ) RETURN NUMBER
IS
        l_job_level       NUMBER;

BEGIN
        l_job_level := PA_JOB_UTILS.get_job_level (
                           P_job_id          => P_job_id
                          ,P_job_group_id    => P_job_group_id
                       );

        Return l_job_level;

END get_job_level;


-- This Procedure Adds messages to stack
PROCEDURE add_to_stack(P_return_status    VARCHAR2,
                       P_error_message_code VARCHAR2
                      ) IS

BEGIN

        if P_return_status  <> FND_API.G_RET_STS_SUCCESS then
                    PA_UTILS.add_message(p_app_short_name => 'PA',
                          p_msg_name => P_error_message_code);
        end if;


END add_to_stack;


-- This Function returns boolean value of true if a job is master job otherwise
-- it returns false -- IN parameter will be job_id
FUNCTION check_master_job(P_job_id  IN per_Jobs.job_id%type)
                       RETURN  boolean
IS
        l_flag      BOOLEAN;

BEGIN
        l_flag := PA_JOB_UTILS.check_master_job(P_job_id);
        return l_flag;

END check_master_job;


-- This API returns the utilization of job / person
-- The IN parameters will be Person_id and Date for Person's Billability
-- OR Job_id for the Job's billability
FUNCTION check_job_utilization
        (
         P_job_id        IN   number
        ,P_person_id     IN   number
        ,P_date          IN   date
         ) RETURN VARCHAR2
IS

        utilization_flag    VARCHAR2(150);
        v_job_id         per_jobs.job_id%type;
        v_job_info_type  VARCHAR2(20) := 'Job Category';

BEGIN


        v_job_id  := P_job_id;
        If P_person_id is NOT NULL AND  P_date is NOT NULL  AND P_job_id is NULL then

                SELECT  Job_id
                INTO    v_job_id
                FROM    per_all_assignments_f
                WHERE   Person_id = P_person_id
                 AND    P_date BETWEEN effective_start_date
                               AND effective_end_date
                 AND    job_id is NOT NULL
                 AND    primary_flag = 'Y'
		 and    assignment_type in ('E', 'C');

        End if;

        If v_job_id is NOT NULL then
            SELECT jei_information3
            INTO   utilization_flag
            FROM   per_job_extra_info
           WHERE   job_id = v_job_id
            AND    information_type  = v_job_info_type
	    AND    jei_information3 IS NOT NULL;  -- Bug 2898766
        End if;

        If utilization_flag is NULL then
           utilization_flag := 'N';
        End if;

        return (utilization_flag);

EXCEPTION
        /* Bug 2898766 - Handled the exception if more than one rows are returned */
        WHEN TOO_MANY_ROWS THEN
             utilization_flag := 'X';
            return (utilization_flag );

        WHEN NO_DATA_FOUND then
            utilization_flag := 'N';
            return (utilization_flag );

END check_job_utilization;




-- This API returns the Billability of job / person
-- The IN parameters will be Person_id and Date for Person's Billability
-- OR Job_id for the Job's billability
FUNCTION check_job_billability
        (
         P_job_id        IN   number
        ,P_person_id     IN   number
        ,P_date          IN   date
         ) RETURN VARCHAR2
IS

        Billable_flag    VARCHAR2(150);
        v_job_id         per_jobs.job_id%type;
        v_job_info_type  VARCHAR2(20) := 'Job Category';

BEGIN


        v_job_id  := P_job_id;
        If P_person_id is NOT NULL AND  P_date is NOT NULL  AND P_job_id is NULL then

                SELECT  Job_id
                INTO    v_job_id
                FROM    per_all_assignments_f
                WHERE   Person_id = P_person_id
                 AND    P_date BETWEEN effective_start_date
                                   AND effective_end_date
                 AND    job_id is NOT NULL
                 AND    primary_flag = 'Y'
		 AND    assignment_type in ('E', 'C');
        End if;

        If v_job_id is NOT NULL then
            SELECT jei_information2
            INTO   Billable_flag
            FROM   per_job_extra_info
           WHERE   job_id = v_job_id
            AND    information_type  = v_job_info_type
	    AND    jei_information2 IS NOT NULL;  -- Bug 2898766
        End if;

        If Billable_flag is NULL then
           Billable_flag := 'N';
        End if;

        return (Billable_flag);

EXCEPTION
      /* Bug 2898766 - Handled the exception if more than one rows are returned */
        WHEN TOO_MANY_ROWS THEN
	   Billable_flag := 'X';
            return (Billable_flag );

        WHEN NO_DATA_FOUND then
            Billable_flag := 'N';
            return (Billable_flag );

END check_job_billability;



----------------------------------------------------------------
-- This API returns the schedulable_flag value of the passed job
----------------------------------------------------------------
FUNCTION check_job_schedulable
 (
   p_job_id        IN   NUMBER
  ,p_person_id     IN   NUMBER
  ,p_date          IN   DATE
 ) RETURN VARCHAR2
IS
  l_schedulable_flag  VARCHAR2(150) := 'N';
  l_job_info_type     VARCHAR2(20)  := 'Job Category';
  l_job_id            NUMBER;
BEGIN
  l_job_id := p_job_id;

  IF p_person_id is NOT NULL AND p_date is NOT NULL THEN
      SELECT  job_id
       INTO  l_job_id
       FROM  per_all_assignments_f  paaf
      WHERE  paaf.person_id = p_person_id
        AND  trunc(p_date) BETWEEN trunc(paaf.effective_start_date)   -- Bug 8269512 : introduced trunc() on dates
                        AND trunc(paaf.effective_end_date)            -- Bug 8269512 : introduced trunc() on dates
        AND  paaf.job_id is NOT NULL
        AND  paaf.primary_flag = 'Y'
	AND  paaf.assignment_type in ('E', 'C')
        AND ((SELECT per_system_status
              FROM per_assignment_status_types past
              WHERE past.assignment_status_type_id = paaf.assignment_status_type_id) IN ('ACTIVE_ASSIGN','ACTIVE_CWK')); --Bug#8879958
  END IF;

  IF l_job_id is NOT NULL THEN
     SELECT jei_information6
       INTO l_schedulable_flag
       FROM per_job_extra_info
      WHERE job_id = l_job_id
        AND information_type = l_job_info_type
        AND jei_information6 IS NOT NULL;

     IF l_schedulable_flag IS NULL THEN
       l_schedulable_flag := 'N';
     END IF;
  END IF;

  RETURN l_schedulable_flag;
EXCEPTION
  WHEN TOO_MANY_ROWS THEN
     l_schedulable_flag := 'X';
     RETURN l_schedulable_flag;
  WHEN NO_DATA_FOUND then
     RETURN l_schedulable_flag;

END check_job_schedulable;



-- This Procedure checks whether the given OU is valid or Not
PROCEDURE check_exp_OU(p_org_id              IN   NUMBER
                    ,x_return_status       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    ,x_error_message_code  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    ) IS

        v_error_message_code    VARCHAR2(1000) := 'PA_INVALID_EXP_OU';
                                                 --'Invalid Operating Unit';
        v_return_status         VARCHAR2(1);
        v_dummy                 VARCHAR2(1):= 'N';
BEGIN
        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.check_exp_OU');
        -- Initialize the error status
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        If p_org_id is NOT NULL then

            SELECT 'Y'
             INTO  v_dummy
             FROM  pa_implementations_all
            WHERE  org_id = p_org_id
              AND  rownum = 1;

        End if;
      /*

        If v_dummy = 'Y' then
           x_error_message_code := 'Exp Ou';
        End if;
       */
        -- reset the Error stack
        PA_DEBUG.Reset_Err_Stack;

EXCEPTION

        WHEN NO_DATA_FOUND THEN
          x_error_message_code := v_error_message_code;
          x_return_status := FND_API.G_RET_STS_ERROR;


        WHEN OTHERS THEN
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.check_exp_OU'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  -- 4537865 : RESET x_error_message_code also
	  x_error_message_code := SQLCODE ;

          raise;



END check_exp_OU;


-- This API makes calls to PA_REOSURCE_PVT.UPDATE_RESOURCE_DENORM api
-- which actually updates the pa_reosurces_denorm entity
PROCEDURE call_create_resource_denorm
                         (P_job_id_old    per_jobs.job_id%type
                         ,P_job_id_new    per_jobs.job_id%type
                         ,P_job_level_old NUMBER
                         ,P_job_level_new NUMBER
                         ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         ,x_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         ,x_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                      ) IS
        v_return_status        VARCHAR2(2000);
        v_error_message_code   VARCHAR2(2000);
        v_resource_rec_old     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
        v_resource_rec_new     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
        v_job_level_old        NUMBER := 0;
        v_job_level_new        NUMBER;
        v_job_id_old           PER_JOBS.JOB_ID%type;
        v_job_id_new           PER_JOBS.JOB_ID%type;
        v_msg_data             VARCHAR2(2000);
        v_msg_count            NUMBER;
BEGIN
        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.call_create_resoruce_denorm');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
                v_job_id_new := P_job_id_new;
                v_job_level_new := P_job_level_new;
                v_job_id_old    := P_job_id_old;
                v_job_level_old := 0;
                If v_job_level_new is NULL then
                   v_job_level_new := 0;  ---- to be confirmed if no job level is found
                end if;                   ----- then assign joblevel to zero when grade is deleted

                if P_job_level_old is NOT NULL then
                   v_job_level_old := P_job_level_old;
                end if;
                If P_job_id_old is NULL then
                   v_job_id_old := P_job_id_new;
                end if;

                if v_job_id_new  is NOT NULL and v_job_level_new is NOT NULL then
                      v_resource_rec_old.job_id             := v_job_id_old;
                      v_resource_rec_old.resource_job_level := v_job_level_old;
                      v_resource_rec_new.job_id             := v_job_id_new;
                      v_resource_rec_new.resource_job_level := v_job_level_new;

                   -- Call PRM API update resource denorm which actually updates the
                     -- pa_resource_denorm entity
                      PA_RESOURCE_PVT.update_resource_denorm
                      ( p_resource_denorm_old_rec   => v_resource_rec_old
                       ,p_resource_denorm_new_rec  => v_resource_rec_new
                       ,x_return_status            => x_return_status
                       ,x_msg_data                 => x_msg_data
                       ,x_msg_count                => x_msg_count
                       );


                 End if;



        -- reset the Error stack
        PA_DEBUG.Reset_Err_Stack;

EXCEPTION

        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
	  x_msg_count := 1 ;
	  x_msg_data := SUBSTRB(SQLERRM ,1,240);

          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_HR_UPDATE_API.call_create_resource_denorm'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;



END call_create_resource_denorm;

-- This API makes calls to PA_RESOURCE_PVT.UPDATE_RESOURCE_DENORM API
-- which actually updates the pa_resources_denorm entity
-- This API will update the job level of the job id passed in of the
-- resources denorm records
PROCEDURE update_job_level_res_denorm
                ( P_job_id_old         per_jobs.job_id%type
                 ,P_job_id_new         per_jobs.job_id%type
                 ,P_job_level_old      NUMBER
                 ,P_job_level_new      NUMBER
                 ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                 ) IS

        l_resource_rec_old     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
        l_resource_rec_new     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
        l_job_level_old        NUMBER;
        l_job_level_new        NUMBER;
        l_job_id_old           PER_JOBS.JOB_ID%type;
        l_job_id_new           PER_JOBS.JOB_ID%type;
        P_DEBUG_MODE VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.update_job_level_res_denorm');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

        l_job_id_new    := P_job_id_new;
        l_job_level_new := P_job_level_new;
        l_job_id_old    := P_job_id_old;
        l_job_level_old := P_job_level_old;

        IF P_DEBUG_MODE = 'Y' THEN
           log_message('====== Job Id Info ==========');
           log_message('Job Id = ' || l_job_id_new);
           log_message('Job Level Old = ' || l_job_level_old);
           log_message('Job Level New = ' || l_job_level_new);
        END IF;

        l_resource_rec_old.job_id             := l_job_id_old;
        l_resource_rec_old.resource_job_level := l_job_level_old;
        l_resource_rec_new.job_id             := l_job_id_new;
        l_resource_rec_new.resource_job_level := l_job_level_new;

        -- Call PRM API update resource denorm which actually updates the
        -- pa_resource_denorm entity
        PA_RESOURCE_PVT.update_resource_denorm
              ( p_resource_denorm_old_rec  => l_resource_rec_old
               ,p_resource_denorm_new_rec  => l_resource_rec_new
               ,x_return_status            => x_return_status
               ,x_msg_data                 => x_msg_data
               ,x_msg_count                => x_msg_count
              );

        -- reset the Error stack
        PA_DEBUG.Reset_Err_Stack;

EXCEPTION

        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);

          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.update_job_level_res_denorm'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;

END update_job_level_res_denorm;

-- This API gets all jobs belonging to the master job id and updates
-- the resource denorm records that has the affected job id
PROCEDURE update_all_jobs
                      (  P_job_id                     per_jobs.job_id%type
                        ,P_job_level_old              pa_resources_denorm.resource_job_level%type
                        ,P_job_level_new              pa_resources_denorm.resource_job_level%type
                        ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                        ,x_msg_data                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                        ,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                       ) IS

        l_job_id               PER_JOBS.JOB_ID%type;
        l_job_level_old        pa_resources_denorm.resource_job_level%type;
        l_job_level_new        pa_resources_denorm.resource_job_level%type;
        l_resource_rec_old     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
        l_resource_rec_new     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;

        -- Cursor to get all affected job ids with the P_job_id level change
        CURSOR get_job_ids(
                           l_job_id    per_jobs.job_id%type
                          )  is
              SELECT l_job_id  effected_job_id
              FROM   sys.dual
                    ,per_job_groups  pjg
              WHERE   pjg.master_flag = 'Y'
                AND   pjg.job_group_id = get_job_group_id(l_job_id)
            UNION
              SELECT distinct pjr.from_job_id  effected_job_id
              FROM   pa_job_relationships pjr
                    ,per_job_groups pjg
              WHERE   pjg.master_flag = 'Y'
                AND   pjr.to_job_id = l_job_id
                AND   pjr.to_job_group_id = pjg.job_group_id
            UNION
              SELECT distinct pjr.to_job_id   effected_job_id
              FROM  pa_job_relationships pjr
                   ,per_job_groups pjg
              WHERE   pjg.master_flag = 'Y'
                AND   pjr.from_job_id = l_job_id
                AND   pjr.from_job_group_id = pjg.job_group_id;

    -- P_DEBUG_MODE varchar2(1); -- Bug 4352236
        P_DEBUG_MODE VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.update_all_jobs');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

        l_job_id  := P_job_id;

        -- just assign the value to the local variable because job_level can be
        -- null and do not need a default value
        l_job_level_old := P_job_level_old;
        l_job_level_new := P_job_level_new;


        -- if the job level changes then update all the jobs which are affected  and
        -- call PA_RESOURCE_PVT.UPDATE_RESOURCE_DENORM API to update the resource_denorm_table
        OPEN get_job_ids(l_job_id) ;
        LOOP
                fetch get_job_ids into l_job_id;
                Exit when get_job_ids%NOTFOUND;

                If l_job_id is NOT NULL then
		-- P_DEBUG_MODE := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
                IF (P_DEBUG_MODE ='Y') THEN
                      pa_debug.g_err_stage := 'Log: Job Level change for job_id';
                      pa_debug.write_file('LOG',pa_debug.g_err_stage);
		  end if;

                      update_job_level_res_denorm
                              ( P_job_id_old     =>  l_job_id
                               ,P_job_id_new     =>  l_job_id
                               ,P_job_level_old  =>  l_job_level_old
                               ,P_job_level_new  =>  l_job_level_new
                               ,x_return_status  =>  x_return_status
                               ,x_msg_data       =>  x_msg_data
                               ,x_msg_count      =>  x_msg_count
                              );
                End if;

        END LOOP;
        CLOSE get_job_ids;

        -- reset the Error stack
        PA_DEBUG.Reset_Err_Stack;

EXCEPTION

        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);

          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.update_all_jobs'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;

END update_all_jobs;

-- This Procedure updates all resource denorm records affected by the
-- changes in job mappings in pa_job_relationships table
-- It will update the job levels of the resource denorm records
PROCEDURE pa_job_relation_job_id
                      (P_calling_mode                 IN   VARCHAR2
                      ,P_from_job_id_old              IN   pa_job_relationships.from_job_id%type
                      ,P_from_job_id_new              IN   pa_job_relationships.from_job_id%type
                      ,P_to_job_id_old                IN   pa_job_relationships.from_job_id%type
                      ,P_to_job_id_new                IN   pa_job_relationships.from_job_id%type
                      ,P_from_job_group_id            IN   pa_job_relationships.from_job_id%type
                      ,P_to_job_group_id              IN   pa_job_relationships.from_job_id%type
                      ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_msg_data                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_msg_count                    OUT NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

        l_job_level_old        NUMBER;
        l_job_level_new        NUMBER;
        l_job_id               PER_JOBS.JOB_ID%type;
        l_master_job_id        PER_JOBS.JOB_ID%type;
        l_PRJG_job_id          PER_JOBS.JOB_ID%type;
        l_condition            VARCHAR2(10);
        P_DEBUG_MODE VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.pa_job_relation_job_id');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

        IF P_DEBUG_MODE = 'Y' THEN
           log_message('P_from_job_id_old = ' || P_from_job_id_old);
           log_message('P_from_job_id_new = ' || P_from_job_id_new);
           log_message('P_to_job_id_old = ' || P_to_job_id_old);
           log_message('P_to_job_id_new = ' || P_to_job_id_new);
           log_message('P_from_job_group_id = ' || P_from_job_group_id);
           log_message('P_to_job_group_id = ' || P_to_job_group_id);
        END IF;

        If P_calling_mode = 'INSERT' OR P_calling_mode = 'UPDATE' Then

              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('P_calling_mode = ' || P_calling_mode);
              END IF;
              ----------------------------------------------------------------------------
              -- Need to check that the from_job_id belongs to the Proj_Res_Job_Group
              -- If it is a PRJG job, we need to check that the to_job_id is a master job
              -- and update the resource denorm records with the job level of the PRJG job
              -----------------------------------------------------------------------------

              If (PA_JOB_UTILS.Is_Proj_Res_Job_Group(P_from_job_id_new, P_from_job_group_id) = 'Y' AND
                  PA_JOB_UTILS.check_master_job(P_to_job_id_new)) then

                 IF P_DEBUG_MODE = 'Y' THEN
                    log_message('From is PRJG, To is Master');
                 END IF;

                  l_job_level_new := PA_JOB_UTILS.get_job_level(P_from_job_id_new,P_from_job_group_id);

                  l_PRJG_job_id := P_from_job_id_new;
                  l_master_job_id := P_to_job_id_new;
                  l_condition := 'PM';

              End if;


              -----------------------------------------------------------------------------
              -- Now, need to do the opposite: check that the to_job_id belongs to the PRJG
              -- If it is a PRJG job, we need to check that the from_job_id is a master job
              -- and update the resource denorm records with the job level of the PRJG job
              -----------------------------------------------------------------------------

              If (PA_JOB_UTILS.Is_Proj_Res_Job_Group(P_to_job_id_new, P_to_job_group_id) = 'Y' AND
                  PA_JOB_UTILS.check_master_job(P_from_job_id_new)) then

                  IF P_DEBUG_MODE = 'Y' THEN
                     log_message('From is Master, To is PRJG');
                  END IF;
                  l_job_level_new := PA_JOB_UTILS.get_job_level(P_to_job_id_new,P_to_job_group_id);

                  l_PRJG_job_id := P_to_job_id_new;
                  l_master_job_id := P_from_job_id_new;
                  l_condition := 'PM';

              End if;


              -----------------------------------------------------------------------------
              -- For Master and Normal job mapping, we need to get the job level of the job
              -- and only updates the resource denorm records which has the normal job id
              -- with the job level of the Master, PRJG job id
              -- Case: from_job_id is Master and to_job_id is Normal job
              ------------------------------------------------------------------------------

              If (PA_JOB_UTILS.check_master_job(P_from_job_id_new) AND
                  PA_JOB_UTILS.Is_Proj_Res_Job_Group(P_to_job_id_new, P_to_job_group_id) = 'N' AND
                  NOT PA_JOB_UTILS.check_master_job(P_to_job_id_new)) THEN

                  IF P_DEBUG_MODE = 'Y' THEN
                     log_message('From is Master, To is Normal');
                  END IF;
                  l_job_level_new := PA_JOB_UTILS.get_job_level(P_from_job_id_new, P_from_job_group_id);

                  l_job_id := P_to_job_id_new;
                  l_condition := 'MN';

              End If;

              ----------------------------------------------------------------------------
              -- Same as previous, but to_job_id is Master and from_job_id is normal job
              ----------------------------------------------------------------------------
              If (PA_JOB_UTILS.check_master_job(P_to_job_id_new) AND
                  PA_JOB_UTILS.Is_Proj_Res_Job_Group(P_from_job_id_new, P_from_job_group_id) = 'N' AND
                  NOT PA_JOB_UTILS.check_master_job(P_from_job_id_new)) THEN

                  IF P_DEBUG_MODE = 'Y' THEN
                     log_message('From is Normal, To is Master');
                  END IF;
                  l_job_level_new := PA_JOB_UTILS.get_job_level(P_to_job_id_new, P_to_job_group_id);

                  l_job_id := P_from_job_id_new;
                  l_condition := 'MN';

              End If;


              -- PRJG and Master Job Mapping
              -- Update all jobs belonging to the Master job
              If l_condition = 'PM' Then

                   IF P_DEBUG_MODE = 'Y' THEN
                      log_message('Updating records for PRJG job');
                   END IF;
                   update_job_level_res_denorm
                              ( P_job_id_old     =>  NULL
                               ,P_job_id_new     =>  l_PRJG_job_id
                               ,P_job_level_old  =>  NULL
                               ,P_job_level_new  =>  l_job_level_new
                               ,x_return_status  =>  x_return_status
                               ,x_msg_data       =>  x_msg_data
                               ,x_msg_count      =>  x_msg_count
                              );

                   IF P_DEBUG_MODE = 'Y' THEN
                     log_message('Updating records for jobs belonging to master');
                   END IF;
                   update_all_jobs
                            (  P_job_id          =>  l_master_job_id
                              ,P_job_level_old   =>  NULL
                              ,P_job_level_new   =>  l_job_level_new
                              ,x_return_status   =>  x_return_status
                              ,x_msg_data        =>  x_msg_data
                              ,x_msg_count       =>  x_msg_count
                            );

              -- Master and Normal Job mapping
              -- Only update the normal job id
              Elsif l_condition = 'MN' Then

                    IF P_DEBUG_MODE = 'Y' THEN
                       log_message('Updating records only for the normal job id');
                    END IF;
                    update_job_level_res_denorm
                              ( P_job_id_old     =>  NULL
                               ,P_job_id_new     =>  l_job_id
                               ,P_job_level_old  =>  NULL
                               ,P_job_level_new  =>  l_job_level_new
                               ,x_return_status  =>  x_return_status
                               ,x_msg_data       =>  x_msg_data
                               ,x_msg_count      =>  x_msg_count
                              );

              End If;

        Elsif  P_calling_mode = 'UPDATE' then

              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('P_calling_mode = UPDATE');
              END IF;


        Elsif  P_calling_mode = 'DELETE' then

              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('P_calling_mode = DELETE');
              END IF;
              ------------------------------------------------------------------------------
              -- The following condition checks if the from_job_id is a Master and to_job_id
              -- is in the Proj_Res_Job_Group or the opposite
              -- Also checks if the from_job_id is a Master Job and to_job_id is a normal job
              -- id or the opposite
              -- Sets the appropriate value for the job ids and the condition to update the
              -- resource denorm records
              ------------------------------------------------------------------------------

              IF ((PA_JOB_UTILS.check_master_job(P_from_job_id_old) AND
                   PA_JOB_UTILS.Is_Proj_Res_Job_Group(P_to_job_id_old, P_to_job_group_id) = 'Y')) THEN

              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('From is Master, To is PRJG');
              END IF;
                 l_master_job_id := P_from_job_id_old;
                 l_PRJG_job_id   := P_to_job_id_old;
                 l_condition     := 'PM';

              ELSIF ((PA_JOB_UTILS.check_master_job(P_to_job_id_old) AND
                      PA_JOB_UTILS.Is_Proj_Res_Job_Group(P_from_job_id_old, P_from_job_group_id) = 'Y')) THEN

              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('From is PRJG, To is Master');
              END IF;
                 l_master_job_id := P_to_job_id_old;
                 l_PRJG_job_id   := P_from_job_id_old;
                 l_condition     := 'PM';

              ELSIF ( PA_JOB_UTILS.check_master_job(P_from_job_id_old) AND
                      PA_JOB_UTILS.Is_Proj_Res_Job_Group(P_to_job_id_old, P_to_job_group_id) = 'N' AND
                      NOT PA_JOB_UTILS.check_master_job(P_to_job_id_old)) THEN

              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('From is Master, To is Normal');
              END IF;
                 l_master_job_id := P_from_job_id_old;
                 l_job_id := P_to_job_id_old;
                 l_condition := 'MN';

              ELSIF ( PA_JOB_UTILS.check_master_job(P_to_job_id_old) AND
                      PA_JOB_UTILS.Is_Proj_Res_Job_Group(P_from_job_id_old, P_from_job_group_id) = 'N'AND
                      NOT PA_JOB_UTILS.check_master_job(P_from_job_id_old)) THEN

              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('From is Normal, To is Master');
              END IF;
                 l_master_job_id := P_to_job_id_old;
                 l_job_id := P_from_job_id_old;
                 l_condition := 'MN';

              END IF;


              ------------------------------------------------------------
              -- Next, update the resource denorm records correspondingly
              -- If l_condition is 'PM' : PRJG and Master Jobs mapping,
              -- We need to sets the job level to Null for all resource
              -- denorm records with the job_id belonging to the Master,
              -- and the Master Job itself
              -- If l_condition is 'MN' : Master and Normal Jobs mapping,
              -- We need to set the job level to Null ONLY for resource
              -- denorm records with the job id of the Normal Job Id
              ------------------------------------------------------------

              If l_condition = 'PM' Then

                 IF P_DEBUG_MODE = 'Y' THEN
                    log_message('Updating records with job ids belong to Master');
                    log_message('Master Job Id = ' || l_master_job_id);
                 END IF;
                 update_all_jobs
                            (  P_job_id          =>  l_master_job_id
                              ,P_job_level_old   =>  NULL
                              ,P_job_level_new   =>  NULL
                              ,x_return_status   =>  x_return_status
                              ,x_msg_data        =>  x_msg_data
                              ,x_msg_count       =>  x_msg_count
                            );


              Elsif l_condition = 'MN' Then

                IF P_DEBUG_MODE = 'Y' THEN
                  log_message('Updating only records with the normal job id');
                  log_message('Job Id = ' || l_job_id);
                END IF;
                  update_job_level_res_denorm
                              ( P_job_id_old     =>  NULL
                               ,P_job_id_new     =>  l_job_id
                               ,P_job_level_old  =>  NULL
                               ,P_job_level_new  =>  NULL
                               ,x_return_status  =>  x_return_status
                               ,x_msg_data       =>  x_msg_data
                               ,x_msg_count      =>  x_msg_count
                              );
              End If;

        End if;



        -- reset the Error stack
        PA_DEBUG.Reset_Err_Stack;

EXCEPTION

        WHEN NO_DATA_FOUND THEN
           NULL;

        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);

          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.pa_job_relation_job_id'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;


END pa_job_relation_job_id;


-- Do updates on job level for PRJG job, master jobs and normal jobs
-- which has mapping to each other
PROCEDURE perform_job_updates
                     (   P_job_id                     per_jobs.job_id%type
                        ,P_job_level_old              pa_resources_denorm.resource_job_level%type
                        ,P_job_level_new              pa_resources_denorm.resource_job_level%type
                        ,P_job_group_id               per_job_groups.job_group_id%type
                        ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                        ,x_msg_data                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                        ,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                      ) IS

        l_job_id               PER_JOBS.JOB_ID%type;
        l_master_job_id        PER_JOBS.JOB_ID%type;
        l_job_level_old        pa_resources_denorm.resource_job_level%type;
        l_job_level_new        pa_resources_denorm.resource_job_level%type;
        l_job_group_id         per_job_groups.job_group_id%type;
        P_DEBUG_MODE VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

        -- Cursor to get the associated master job id of the PRJG job id
        CURSOR get_master_job (
                            l_job_id        per_jobs.job_id%type
                           ,l_job_group_id  per_job_groups.job_group_id%type
                          )  IS

              SELECT  distinct pjr.from_job_id  effected_job_id
              FROM    pa_job_relationships pjr
              WHERE   pjr.to_job_id = l_job_id
              AND     pjr.to_job_group_id = l_job_group_id
           UNION
              SELECT  distinct pjr.to_job_id   effected_job_id
              FROM    pa_job_relationships pjr
              WHERE   pjr.from_job_id = l_job_id
              AND     pjr.from_job_group_id = l_job_group_id;

BEGIN

        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.perform_job_updates');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
        IF P_DEBUG_MODE = 'Y' THEN
           log_message('**** Performing Job Level Updates ****');
        END IF;

        l_job_id := P_job_id;
        l_job_level_old := P_job_level_old;
        l_job_level_new := P_job_level_new;
        l_job_group_id := P_job_group_id;

        -- first updates the denorm records which has the PRJG job id
        IF P_DEBUG_MODE = 'Y' THEN
           log_message('Updating Denorm for PRJG job id = ' || l_job_id);
        END IF;
        update_job_level_res_denorm
                ( P_job_id_old     =>  l_job_id
                 ,P_job_id_new     =>  l_job_id
                 ,P_job_level_old  =>  l_job_level_old
                 ,P_job_level_new  =>  l_job_level_new
                 ,x_return_status  =>  x_return_status
                 ,x_msg_data       =>  x_msg_data
                 ,x_msg_count      =>  x_msg_count
                );

        -- next get the master job id and then updates all jobs
        -- belonging to that master job id if the job id is NOT
        -- a master job

        If (PA_JOB_UTILS.check_master_job(l_job_id) = FALSE) Then

              OPEN get_master_job(l_job_id, l_job_group_id);
              LOOP
                  FETCH get_master_job INTO l_master_job_id;
                  Exit when get_master_job%NOTFOUND;

                  IF P_DEBUG_MODE = 'Y' THEN
                     log_message('Updating Denorm for jobs belongs to master job id = ' || l_master_job_id);
                  END IF;

                  update_all_jobs
                            (  P_job_id          =>  l_master_job_id
                              ,P_job_level_old   =>  l_job_level_old
                              ,P_job_level_new   =>  l_job_level_new
                              ,x_return_status   =>  x_return_status
                              ,x_msg_data        =>  x_msg_data
                              ,x_msg_count       =>  x_msg_count
                            );
              END LOOP;
              CLOSE get_master_job;

        Else

              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('Updating Denorm for jobs belongs to master job, also PRJG job id = ' || l_job_id);
              END IF;
              update_all_jobs
                            (  P_job_id          =>  l_job_id
                              ,P_job_level_old   =>  l_job_level_old
                              ,P_job_level_new   =>  l_job_level_new
                              ,x_return_status   =>  x_return_status
                              ,x_msg_data        =>  x_msg_data
                              ,x_msg_count       =>  x_msg_count
                            );
        End If;

EXCEPTION
    -- when no data found from the get_master_job cursor, then there is no
    -- mapping, do not do any updates
    WHEN NO_DATA_FOUND THEN
        null;
    WHEN OTHERS THEN -- Included WHEN OTHERS Block for 4537865
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API',
				  p_procedure_name => 'perform_job_updates',
				  p_error_text => x_msg_data );
	  RAISE ;
END perform_job_updates;



-- Main API for job level change, job mapping change
-- This API will update the resource denorm records with the job level change of a job id.
-- It depends on the type of job : whether it is in the Project Resource Job Group or not
PROCEDURE update_job_level_dff
                     (   P_job_id                     per_jobs.job_id%type
                        ,P_job_level_old              pa_resources_denorm.resource_job_level%type
                        ,P_job_level_new              pa_resources_denorm.resource_job_level%type
                        ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                        ,x_msg_data                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                        ,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                      ) IS

        l_job_id               PER_JOBS.JOB_ID%type;
        l_job_level_old        pa_resources_denorm.resource_job_level%type;
        l_job_level_new        pa_resources_denorm.resource_job_level%type;
        l_job_group_id         per_job_groups.job_group_id%type;
        l_isPRJG               VARCHAR2(1);
        P_DEBUG_MODE VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.update_job_level_dff');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

        l_job_id := P_job_id;
        l_job_level_old := P_job_level_old;
        l_job_level_new := P_job_level_new;

        -- When Project Resource Job Group does not exist, we just use
        -- the job id and job level passed in and update the resource
        -- denorm records affected by this change
        IF PA_JOB_UTILS.Proj_Res_Job_Group_Exists(p_job_id => l_job_id) = 'N' THEN
             IF P_DEBUG_MODE = 'Y' THEN
                log_message('Proj_Res_Job_Group does not exist');
                log_message('Update Denorm for the Job Id and Job Level');
             END IF;

             update_job_level_res_denorm
                      ( P_job_id_old     =>  l_job_id
                       ,P_job_id_new     =>  l_job_id
                       ,P_job_level_old  =>  l_job_level_old
                       ,P_job_level_new  =>  l_job_level_new
                       ,x_return_status  =>  x_return_status
                       ,x_msg_data       =>  x_msg_data
                       ,x_msg_count      =>  x_msg_count
                      );
        ELSE
             -----------------------------------------------------------
             -- This is the case when the Proj_Res_Job_Group value exist
             -----------------------------------------------------------
             IF P_DEBUG_MODE = 'Y' THEN
                log_message('Proj_Res_Job_Group Exist');
             END IF;

             -- get the job group id of the job id passed in
             l_job_group_id :=  PA_JOB_UTILS.get_job_group_id(l_job_id);
             IF P_DEBUG_MODE = 'Y' THEN
                log_message('Job Group Id = ' || l_job_group_id );
             END IF;

             -- check whether the job group is the Proj_Res_Job_Group
             l_isPRJG :=  PA_JOB_UTILS.Is_Proj_Res_Job_Group
                              ( p_job_id       => l_job_id
                               ,p_job_group_id => l_job_group_id);

             -------------------------------------------------------------
             -- When l_isPRJG is 'Y', we need to get the master job id
             -- associated with the job id passed in from the job mapping
             -- and update all resource denorm records of the affected
             -- jobs
             -- Call procedure 'perform_job_updates' for this
             -- When the value is 'N', we not need to change anything
             -------------------------------------------------------------

             If l_isPRJG = 'Y' Then

                 IF P_DEBUG_MODE = 'Y' THEN
                    log_message('Job Id passed in belongs to PRJG job group');
                 END IF;

                 perform_job_updates
                        ( P_job_id             => l_job_id
                         ,P_job_level_old      => l_job_level_old
                         ,P_job_level_new      => l_job_level_new
                         ,P_job_group_id       => l_job_group_id
                         ,x_return_status      => x_return_status
                         ,x_msg_data           => x_msg_data
                         ,x_msg_count          => x_msg_count
                        );

             End If;

        END IF;

EXCEPTION
    -- when no data found from the get_master_job cursor, then there is no
    -- mapping, do not do any updates
    WHEN NO_DATA_FOUND THEN
        null;
    WHEN OTHERS THEN -- Included WHEN OTHERS Block for 4537865
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API',
                                  p_procedure_name => 'update_job_level_dff',
                                  p_error_text => x_msg_data );
          RAISE ;
END update_job_level_dff;





-- This Procedure gets list of all the jobs which are afftected due to changes in
-- grade_id in per_valid_grade  entity
PROCEDURE per_valid_grades_job_id
                      (P_job_id             IN   per_jobs.job_id%type
                      ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_msg_count          OUT NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

        v_return_status        VARCHAR2(2000);
        v_error_message_code   VARCHAR2(2000);
        v_job_group_id         PER_JOBS.JOB_GROUP_ID%type;
        v_job_level_old        NUMBER;
        v_job_level_new        NUMBER;
        v_job_id               PER_JOBS.JOB_ID%type;
        v_msg_data             VARCHAR2(2000);
        v_msg_count            NUMBER;

        CURSOR get_job_ids(
                           l_job_id    per_jobs.job_id%type
                          )  is
            SELECT l_job_id  effected_job_id
             FROM  sys.dual
                  ,per_job_groups  pjg
            WHERE pjg.master_flag = 'Y'
             AND  pjg.job_group_id = get_job_group_id(l_job_id)
            UNION
            SELECT distinct pjr.from_job_id  effected_job_id
             FROM   pa_job_relationships pjr
                    ,per_job_groups pjg
           WHERE    pjg.master_flag = 'Y'
            AND     pjr.to_job_id = l_job_id
            AND     pjr.to_job_group_id = pjg.job_group_id
           UNION
            SELECT distinct pjr.to_job_id   effected_job_id
             FROM  pa_job_relationships pjr
                  ,per_job_groups pjg
           WHERE    pjg.master_flag = 'Y'
            AND     pjr.from_job_id = l_job_id
            AND     pjr.from_job_group_id = pjg.job_group_id
           UNION
           SELECT  l_job_id   effected_job_id
             FROM  sys.dual
                  ,per_job_groups pjg
           WHERE    pjg.master_flag = 'N'
            AND     pjg.job_group_id = get_job_group_id(l_job_id)
            AND     NOT EXISTS (
                             SELECT  'Y'
                             FROM   per_job_groups
                             WHERE  master_flag = 'Y'
                             AND job_group_id = get_job_group_id(l_job_id)
                              );
BEGIN

        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.per_valid_grades_job_id');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

        -- if the grade id  changes then update all the jobs which are affected  and
        -- call PA_RESOURCE_PVT.UPDATE_RESOURCE_DENORM API to update the resource_denorm_table
        OPEN get_job_ids(P_job_id) ;
        LOOP
                fetch get_job_ids into v_job_id;
                Exit when get_job_ids%NOTFOUND;
                v_job_group_id  := get_job_group_id(v_job_id);
                v_job_level_new := get_job_level(v_job_id,v_job_group_id);
                v_job_level_old := 0;

                If v_job_id is NOT NULL then
                      call_create_resource_denorm
                         (P_job_id_old         => v_job_id
                         ,P_job_id_new         => v_job_id
                         ,P_job_level_old      => v_job_level_old
                         ,P_job_level_new      => v_job_level_new
                         ,x_return_status      => x_return_status
                         ,x_msg_data           => x_msg_data
                         ,x_msg_count          => x_msg_count
                          );
                End if;


        END LOOP;
        CLOSE get_job_ids;

        -- reset the Error stack
        PA_DEBUG.Reset_Err_Stack;

EXCEPTION

        WHEN NO_DATA_FOUND THEN
           NULL;

        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.per_valid_grades_job_id'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            raise;


END per_valid_grades_job_id;

-- This Procedure gets list of all the jobs which are afftected due to changes in
-- sequence(job level) in per grades entity
PROCEDURE per_grades_job_id
                      (P_grade_id           IN   per_grades.grade_id%type
                      ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                      ) IS

        v_return_status        VARCHAR2(2000);
        v_error_message_code   VARCHAR2(2000);
        v_job_group_id         PER_JOBS.JOB_GROUP_ID%type;
        v_job_level_new        NUMBER;
        v_job_level_old        NUMBER;
        v_job_id               PER_JOBS.JOB_ID%type;
        v_row_num              NUMBER := 0;
        v_msg_data             VARCHAR2(2000);
        v_msg_count            NUMBER;
        CURSOR get_job_ids(l_grade_id per_grades.grade_id%type) is
            SELECT distinct pvg.job_id
             FROM  per_valid_grades pvg
                  ,per_job_groups  pjg
            WHERE
                  pvg.grade_id = l_grade_id
             AND  pjg.master_flag = 'Y'
             AND  pjg.job_group_id = get_job_group_id(pvg.job_id)
            UNION
            SELECT distinct pjr.from_job_id
             FROM   per_valid_grades pvg
                    ,pa_job_relationships pjr
                    ,per_job_groups pjg
           WHERE    pjg.master_flag = 'Y'
            AND     pjr.to_job_id = pvg.job_id
            AND     pjr.to_job_group_id = pjg.job_group_id
            AND     pvg.grade_id = l_grade_id
           UNION
            SELECT distinct pjr.to_job_id
             FROM   per_valid_grades pvg
                    ,pa_job_relationships pjr
                    ,per_job_groups pjg
           WHERE    pjg.master_flag = 'Y'
            AND     pjr.from_job_id = pvg.job_id
            AND     pjr.from_job_group_id = pjg.job_group_id
            AND     pvg.grade_id = l_grade_id
           UNION
           SELECT  distinct pvg.job_id
             FROM  per_valid_grades pvg
                  ,per_job_groups  pjg
           WHERE    pjg.master_flag = 'N'
            AND     pjg.job_group_id = get_job_group_id(pvg.job_id)
            AND     pvg.grade_id = l_grade_id
            AND     NOT EXISTS (
                             SELECT  'Y'
                             FROM   per_job_groups
                             WHERE  master_flag = 'Y'
                             AND job_group_id = get_job_group_id(pvg.job_id)
                              );


BEGIN


        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.per_grades_job_id');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

        -- if the sequence is changes then update all the jobs which are affected due to
        -- call PA_RESOURCE_PVT.UPDATE_RESOURCE_DENORM API to update the resource_denorm_table
        OPEN get_job_ids(P_grade_id) ;
        LOOP
                fetch get_job_ids into v_job_id;
                Exit when get_job_ids%NOTFOUND;
                v_job_group_id     := get_job_group_id(v_job_id);
                v_job_level_new    := get_job_level(v_job_id,v_job_group_id);
                v_job_level_old    := 0;
                if v_job_id is NOT NULL then
                      call_create_resource_denorm
                         (P_job_id_old         => v_job_id
                         ,P_job_id_new         => v_job_id
                         ,P_job_level_old      => v_job_level_old
                         ,P_job_level_new      => v_job_level_new
                         ,x_return_status      => x_return_status
                         ,x_msg_data           => x_msg_data
                         ,x_msg_count          => x_msg_count
                          );
                End if;


        END LOOP;
        CLOSE get_job_ids;

        -- reset the Error stack
        PA_DEBUG.Reset_Err_Stack;
EXCEPTION

        WHEN NO_DATA_FOUND THEN
           NULL;

        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.per_grades_job_id'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            raise;



END per_grades_job_id;



-- This Procedure will get a list of all affected jobs due to change in the job mapping
-- and then calls to PRM API GET_JOB_LEVEL in a loop which actually
-- updates the levels in the resource denorm table.
-- Whenever job mapping columns in pa_job_relationships updated,workflow will kickoff
-- this api from the database trigger on table pa_job_relationships
-- Pa_Job_Relationships Entity--
-- IN Parameters
-- P_calling_mode,P_from_job_id_new,P_to_job_id_new,P_from_job_group_id,P_to_job_group_id -- INSERT
-- P_calling_mode,P_from_job_id_new,P_to_job_id_new,P_from_job_group_id,P_to_job_group_id,
--                 P_from_job_id_old,P_to_job_id_old                                      -- UPDATE
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
             )IS

        v_return_status        VARCHAR2(2000);
        v_error_message_code   VARCHAR2(2000);
        v_grade_id             per_grades.grade_id%type;
        v_msg_data             VARCHAR2(2000);
        v_msg_count            NUMBER;

BEGIN
        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.Update_job_levels');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

         -- Code for if job mapping has changed

        If (P_from_job_group_id is NOT NULL and P_to_job_group_id is NOT NULL)  and
           (P_from_job_id_old is NOT NULL or P_from_job_id_new is NOT NULL or
            P_to_job_id_old  is NOT NULL or P_to_job_id_new is NOT NULL ) then
                pa_job_relation_job_id
                      (p_calling_mode         => p_calling_mode
                      ,P_from_job_id_old      => P_from_job_id_old
                      ,P_from_job_id_new      => P_from_job_id_new
                      ,P_to_job_id_old        => P_to_job_id_old
                      ,P_to_job_id_new        => P_to_job_id_new
                      ,P_from_job_group_id    => P_from_job_group_id
                      ,P_to_job_group_id      => P_to_job_group_id
                      ,x_return_status        => x_return_status
                      ,x_msg_data             => x_msg_data
                      ,x_msg_count            => x_msg_count
                       );
        End if;

        -- reset the Error stack
        PA_DEBUG.Reset_Err_Stack;

EXCEPTION

        WHEN NO_DATA_FOUND THEN
           NULL;

        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);

          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.Update_job_levels'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            raise;

END update_job_levels;


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
                             )IS

	v_return_status        VARCHAR2(2000);
    v_error_message_code   VARCHAR2(2000);
    v_resource_rec_old     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
    v_resource_rec_new     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
    v_msg_data             VARCHAR2(2000);
    v_msg_count            NUMBER;

    CURSOR res_denorm_recs IS
	    SELECT resource_effective_start_date,
               resource_effective_end_date
        FROM   pa_resources_denorm
        WHERE  person_id = p_person_id
        AND    nvl(p_end_date_new, sysdate) >= resource_effective_start_date
        AND    resource_effective_start_date >= p_start_date
        AND    resource_effective_end_date   <= p_end_date_old
	;
BEGIN

    v_resource_rec_old.resource_org_id               := p_default_OU_old;
    v_resource_rec_old.person_id                     := p_person_id;
    v_resource_rec_new.resource_org_id               := p_default_OU_new;
    v_resource_rec_new.person_id                     := p_person_id;



    --dbms_output.put_line('Calling Update_OU_resource');
    --dbms_output.put_line('End date for OU:' || p_default_OU_new || 'end date:' || P_end_date_new);

    -- Initialize the Error stack
    PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.Update_OU_resource');
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    FOR rec IN res_denorm_recs LOOP

        v_resource_rec_old.resource_effective_start_date := rec.resource_effective_start_date;
        v_resource_rec_new.resource_effective_start_date := rec.resource_effective_start_date;


        PA_RESOURCE_PVT.update_resource_denorm (
            p_resource_denorm_old_rec   => v_resource_rec_old
            ,p_resource_denorm_new_rec  => v_resource_rec_new
            ,x_return_status            => x_return_status
            ,x_msg_data                 => x_msg_data
            ,x_msg_count                => x_msg_count );

    END LOOP;

    --If new end date is passed for this assignment (from make_resource_inactive api)
    If P_end_date_new is NOT NULL then
          Update_EndDate(
		p_person_id      => p_person_id,
	        p_old_start_date => p_start_date,
       	        p_new_start_date => p_start_date,
	        p_old_end_date   => p_end_date_old,
	        p_new_end_date   => p_end_date_new,
	        x_return_status  => x_return_status,
	        x_msg_data       => x_msg_data,
                x_msg_count      => x_msg_count);

    End if;

    -- reset the Error stack
    PA_DEBUG.Reset_Err_Stack;

EXCEPTION

        WHEN NO_DATA_FOUND THEN
           NULL;

        WHEN OTHERS THEN          -- Set the exception Message and the stack
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.Update_OU_resource'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            raise;
END  Update_OU_resource;


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
-- Make this procedure a PRAGMA AUTONOMOUS_TRANSACTION because we'll commit or rollback
-- after every resource in the loop
PROCEDURE  Default_OU_Change
                        ( P_calling_mode       IN   VARCHAR2
                         ,P_Organization_id    IN   Hr_Organization_Information.Organization_id%type
                         ,P_Default_OU_new     IN   Hr_Organization_Information.Org_Information1%type
                         ,P_Default_OU_old     IN   Hr_Organization_Information.Org_Information1%type
                         ,x_return_status      OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         ,x_msg_data           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         ,x_msg_count          OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                        ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;

        v_return_status        VARCHAR2(2000);
        v_error_message_code   VARCHAR2(2000);
        v_assn_start_date      Per_all_assignments_f.Effective_Start_Date%type;
        v_assn_end_date        Per_all_assignments_f.Effective_End_Date%type;
        v_Person_id            Per_all_assignments_f.person_id%type;
        v_Default_OU           Hr_Organization_Information.Org_Information1%type;
        v_commit               VARCHAR2(200) := FND_API.G_FALSE;
                               -- set to false since the api is being called from trigger
        v_validate_only        VARCHAR2(200) := FND_API.G_FALSE;
        v_internal             VARCHAR2(1) := 'Y';
        v_individual           VARCHAR2(1) := 'Y'; -- to process single resource in loop
        v_resource_type        VARCHAR2(15):= 'EMPLOYEE';
        v_org_type             VARCHAR2(15):= 'YES';  --'EXPENDITURES';
        v_msg_data             VARCHAR2(2000);
        v_msg_count            NUMBER;
        v_dummy                NUMBER;
        L_API_VERSION          CONSTANT NUMBER := 1.0;
        v_process_further      BOOLEAN := FALSE;
	-- get all the resources who belongs to Expenditure type of organizaion and
        -- belongs to Expenditure Hierarchy ,Active_Assign, and of Primary assignment type
        -- is 'Y' and default OU inactive date is NUll

       CURSOR get_all_resource(l_organization_id  Hr_Organization_Information.Organization_id%type) is

             SELECT distinct
                      ind.person_id
                     ,ind.assignment_start_date
                     ,ind.assignment_end_date
                     ,to_number(hoi.org_information1) default_OU
               FROM  pa_r_project_resources_ind_v ind
                     ,hr_organization_information hoi
              WHERE  ind.organization_id                          =
	      /* Changed for Bug 2499051-  l_organization_id */   hoi.organization_id
   		AND  ind.assignment_end_date                     >= sysdate
                AND  hoi.organization_id                          = l_organization_id
                AND  hoi.org_information_context                  = 'Exp Organization Defaults'
                AND  ind.organization_id                          = l_organization_id -- 4898509
           ORDER BY  ind.person_id,ind.assignment_start_date  ;

BEGIN

        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.Default_OU_Change');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
        -- for each resource found  for the default ou changes  update
        -- pa resource ou entity with new default OU

       -- check whether the new OU is a valid exp OU or not
       -- if not then donot process further

       If  P_Default_OU_new is NOT NULL then

             v_default_OU := P_Default_OU_new;
       Else
             v_default_OU := -9999;
	     -- For bug 5330402 Added call to make_resource_inactive
	     -- This will take sysdate as inactive date
	     -- Return after the call, as no further processing is required.
              make_resource_inactive
                (P_calling_mode       =>  'UPDATE'
                ,P_Organization_id    =>  P_Organization_id
                ,P_Default_OU         =>  P_Default_OU_old
		,P_Default_OU_NEW     =>  v_default_OU
                ,P_inactive_date      =>  trunc(sysdate)
                ,x_return_status      =>  x_return_status
                ,x_msg_data           =>  x_msg_data
                ,x_msg_count          =>  x_msg_count
               ) ;
	       PA_DEBUG.Reset_Err_Stack;
	       Return;
       End if;

       pa_hr_update_api.check_exp_OU
            (p_org_id             => v_default_OU
            ,x_return_status      => v_return_status
            ,x_error_message_code => v_error_message_code
             );

       If v_return_status <> FND_API.G_RET_STS_SUCCESS then
             X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
             x_msg_data      := v_error_message_code;
             v_process_further := FALSE;
             PA_UTILS.add_message(p_app_short_name => 'PA',
                                  p_msg_name => v_error_message_code);
             x_msg_count := fnd_msg_pub.count_msg;

       Elsif v_return_status =  FND_API.G_RET_STS_SUCCESS then

             v_process_further := TRUE;

       End if;

       -- Start Bug : 4656855
       IF (check_pjr_default_ou(P_Organization_id, v_default_OU) <> 'Y') THEN
          RETURN;
       END IF;
       -- End Bug : 4656855

       If (v_process_further) then
            open get_all_resource(P_Organization_id);
            LOOP
                fetch get_all_resource into
                   v_person_id
                  ,v_assn_start_date
                  ,v_assn_end_date
                  ,v_default_OU ;
                Exit when get_all_resource%NOTFOUND;

                 -- call the check ou change api to update records in pa_resource_OU
                 -- for each resource belongs to this updated OU in Hr_Organization_defaults
                 If  P_calling_mode = 'UPDATE' then

                     -- check for whether the default OU is changed if so call
                     -- check OU change api to update the resource OU entity
                     If (NVL(P_default_OU_old,-99) <> nvl(P_default_OU_new,-99)) then
                        -- if OU is updated then call resource denorm api to
                        -- reflect  the changes in pa_resources_denorm entity
                         If v_person_id is NOT NULL then


                             Update_OU_resource
                               (P_default_OU_old      => p_default_OU_old
                                ,p_default_OU_new     => p_default_OU_new
                                ,P_person_id          => v_person_id
                                ,P_start_date         => v_assn_start_date
                                ,P_end_date_old       => v_assn_end_date
                                ,x_return_status      => x_return_status
                                ,x_msg_data           => x_msg_data
                                ,x_msg_count          => x_msg_count
                                );

                             -- call forecast api to regenerate the forcast items
                             -- for the person with the organization OU change
                             -- update forecast data for unassigned and assigned time
                             PA_FORECASTITEM_PVT.Create_Forecast_Item
                               (
                                  p_person_id      => v_person_id
                                 ,p_start_date     => v_assn_start_date
                                 ,p_end_date       => v_assn_end_date
                                 ,p_process_mode   => 'GENERATE'
                                 ,x_return_status  => x_return_status
                                 ,x_msg_count      => x_msg_count
                                 ,x_msg_data       => x_msg_data
                                ) ;

                             if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
                                   COMMIT;
                             else
                                   ROLLBACK;
                             end if;

                          End if;


                      Elsif P_default_OU_old is NULL and P_default_OU_new is NOT NULL then
                          -- when new OU is assigned to existing organization it must pull all
                          -- resources belongs to this OU  so call create resource api

                          PA_R_PROJECT_RESOURCES_PUB.CREATE_RESOURCE (
                                P_API_VERSION    => L_API_VERSION
                                ,P_COMMIT        => v_commit
                                ,P_VALIDATE_ONLY => v_validate_only
                                ,P_INTERNAL      => v_internal
                                ,P_PERSON_ID     => v_person_id
                                ,P_INDIVIDUAL    => v_individual
                                ,P_RESOURCE_TYPE => v_resource_type
                                ,X_RETURN_STATUS => x_return_status
                                ,X_RESOURCE_ID   => v_dummy
                                ,X_MSG_COUNT     => x_msg_count
                                ,X_MSG_DATA      => x_msg_data
                                );

                          -- call this procedure to update the forecast data for
                          -- assigned time ONLY for this resource
                          -- this is called only if create_resource is a success
                          if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
                             PA_FORECASTITEM_PVT.Create_Forecast_Item
                               (  p_person_id      => v_person_id
                                 ,p_start_date     => null
                                 ,p_end_date       => null
                                 ,p_process_mode   => 'GENERATE_ASGMT'
                                 ,x_return_status  => x_return_status
                                 ,x_msg_count      => x_msg_count
                                 ,x_msg_data       => x_msg_data
                               ) ;

                              if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
                                   COMMIT;
                              else
                                   ROLLBACK;
                              end if;
                          else
                             ROLLBACK;
                          end if;

                      End if;

             /* cannot raise - because will be out from the loop and will not process other records
                      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;
              */

                 Elsif P_calling_mode = 'INSERT' then
                    -- the P_calling_mode is 'INSERT'
                    -- this  api is called to populate resources  whenever a new record is added in
                    -- in Hr_organizatioin_information entity
                    -- or due to insert in pa_all_organizations entity

                    PA_R_PROJECT_RESOURCES_PUB.CREATE_RESOURCE (
                                P_API_VERSION    => L_API_VERSION
                                ,P_COMMIT        => v_commit
                                ,P_VALIDATE_ONLY => v_validate_only
                                ,P_INTERNAL      => v_internal
                                ,P_PERSON_ID     => v_person_id
                                ,P_INDIVIDUAL    => v_individual
                                ,P_RESOURCE_TYPE => v_resource_type
                                ,X_RETURN_STATUS => x_return_status
                                ,X_RESOURCE_ID   => v_dummy
                                ,X_MSG_COUNT     => x_msg_count
                                ,X_MSG_DATA      => x_msg_data
                                );


                    -- it is also necessary to call forecast item here,
                    -- because this is also called from project_organization_change
                    -- when p_calling_mode is insert
                    -- A person can belong to Org1(belong to Exp Hier), then the org
                    -- was changed to Org2 (not belong to Exp Hier)
                    -- If Org2 is inserted and belong to Exp Hier, we need to fix
                    -- the assigned time for this person when he/she was with Org1
                    -- So, call this procedure to update the forecast data for
                    -- assigned time ONLY for this resource
                    -- this is called only if create_resource is a success
                    if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
                          PA_FORECASTITEM_PVT.Create_Forecast_Item
                               (  p_person_id      => v_person_id
                                 ,p_start_date     => null
                                 ,p_end_date       => null
                                 ,p_process_mode   => 'GENERATE_ASGMT'
                                 ,x_return_status  => x_return_status
                                 ,x_msg_count      => x_msg_count
                                 ,x_msg_data       => x_msg_data
                               ) ;

                          if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
                              COMMIT;
                          else
                              ROLLBACK;
                          end if;
                    else
                        ROLLBACK;
                    end if;


               /* cannot raise - because will be out from the loop and will not process other records
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE FND_API.G_EXC_ERROR;
                    END IF;
                */

                 End if;
             END LOOP;
             close get_all_resource;

             --set the final return status to SUCCESS after loop
             x_return_status := FND_API.G_RET_STS_SUCCESS;

       End if;

        -- reset the Error stack
       PA_DEBUG.Reset_Err_Stack;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.Default_OU_Change'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;

END Default_OU_Change;


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
                        ) IS

      l_job_id                per_jobs.job_id%type;
      l_job_level             NUMBER;
      l_proj_job_group_new    NUMBER;
      l_proj_job_group_old    NUMBER;
      l_job_group_id          NUMBER;
      P_DEBUG_MODE VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

      CURSOR get_new_job_ids IS
          SELECT job_id
          FROM per_jobs
          WHERE job_group_id = l_proj_job_group_new
            AND business_group_id = p_organization_id;

      CURSOR get_old_job_ids IS
          SELECT job_id
          FROM per_jobs
          WHERE job_group_id = l_proj_job_group_old
            AND business_group_id = p_organization_id;

BEGIN

      -- Initialize the Error stack
      PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.Proj_Res_Job_Group_Change');
      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      l_proj_job_group_old := TO_NUMBER(p_proj_job_group_old);
      l_proj_job_group_new := TO_NUMBER(p_proj_job_group_new);

      IF P_DEBUG_MODE = 'Y' THEN
         log_message('p_calling_mode = ' || p_calling_mode);
         log_message('old proj res job group value = ' || l_proj_job_group_old);
         log_message('new proj res job group value = ' || l_proj_job_group_new);
      END IF;

      IF p_calling_mode = 'INSERT' and fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'N' THEN

           -- When Insert, we update all resource denorm records with job_id that
           -- belongs to the new Project Resource Job Group Id
           OPEN get_new_job_ids;
           LOOP

              FETCH get_new_job_ids INTO l_job_id;
              Exit when get_new_job_ids%NOTFOUND;

              l_job_level := PA_JOB_UTILS.get_job_level(l_job_id);
              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('Job id to set level ' || l_job_level || ' = ' || l_job_id);
              END IF;

              update_job_level_dff
                         (P_job_id             => l_job_id
                         ,P_job_level_old      => NULL
                         ,P_job_level_new      => l_job_level
                         ,x_return_status      => x_return_status
                         ,x_msg_data           => x_msg_data
                         ,x_msg_count          => x_msg_count
                        );
           END LOOP;
           CLOSE get_new_job_ids;

       ELSIF p_calling_mode = 'UPDATE' and fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'N' THEN

           -- When update we have to set the resource denorm records job level to NULL for job id
           -- that belongs to the old Project Resource Job Group Id
           OPEN get_old_job_ids;
           LOOP

              FETCH get_old_job_ids INTO l_job_id;
              Exit when get_old_job_ids%NOTFOUND;

              l_job_level := NULL;

              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('Job id to set level Null = ' || l_job_id);
              END IF;

              l_job_group_id :=  PA_JOB_UTILS.get_job_group_id(l_job_id);

              perform_job_updates
                         (P_job_id             => l_job_id
                         ,P_job_level_old      => NULL
                         ,P_job_level_new      => l_job_level
                         ,P_job_group_id       => l_job_group_id
                         ,x_return_status      => x_return_status
                         ,x_msg_data           => x_msg_data
                         ,x_msg_count          => x_msg_count
                        );

           END LOOP;
           CLOSE get_old_job_ids;


           -- Also, when Update, we update all resource denorm records with job_id that
           -- belongs to the new Project Resource Job Group Id

           OPEN get_new_job_ids;
           LOOP

              FETCH get_new_job_ids INTO l_job_id;
              Exit when get_new_job_ids%NOTFOUND;

              l_job_level := PA_JOB_UTILS.get_job_level(l_job_id);
              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('Job id to set level ' || l_job_level || ' = ' || l_job_id);
              END IF;

              update_job_level_dff
                         (P_job_id             => l_job_id
                         ,P_job_level_old      => NULL
                         ,P_job_level_new      => l_job_level
                         ,x_return_status      => x_return_status
                         ,x_msg_data           => x_msg_data
                         ,x_msg_count          => x_msg_count
                        );

           END LOOP;
           CLOSE get_new_job_ids;


       ELSIF p_calling_mode = 'DELETE' and fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'N' THEN

           -- When Delete, we have to set the resource denorm records job level to NULL for job id
           -- that belongs to the old Project Resource Job Group Id

           OPEN get_old_job_ids;
           LOOP

              FETCH get_old_job_ids INTO l_job_id;
              Exit when get_old_job_ids%NOTFOUND;

              l_job_level := NULL;
              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('Job id to set level Null = ' || l_job_id);
              END IF;

              update_job_level_dff
                         (P_job_id             => l_job_id
                         ,P_job_level_old      => NULL
                         ,P_job_level_new      => l_job_level
                         ,x_return_status      => x_return_status
                         ,x_msg_data           => x_msg_data
                         ,x_msg_count          => x_msg_count
                        );

           END LOOP;
           CLOSE get_old_job_ids;

       END IF;


       -- reset the Error stack
       PA_DEBUG.Reset_Err_Stack;

EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.Proj_Res_Job_Group_Change'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;

END Proj_Res_Job_Group_Change;

-- This API pulls all resources into PA from HR for a given organization
-- Created by virangan 11-JUN-2001
-- Make this procedure a PRAGMA AUTONOMOUS_TRANSACTION because we'll commit after every
-- resource in the loop
PROCEDURE pull_resources( p_organization_id IN  pa_all_organizations.organization_id%type
                          ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          ,x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          ,x_msg_count      OUT NOCOPY NUMBER ) --File.Sql.39 bug 4440895
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_commit               VARCHAR2(200) := FND_API.G_FALSE;
                               -- set to false since the api is being called from trigger
        l_validate_only        VARCHAR2(200) := FND_API.G_FALSE;
        l_internal             VARCHAR2(1) := 'Y';
        l_individual           VARCHAR2(1) := 'Y'; -- to process single resource in loop
        l_resource_type        VARCHAR2(15):= 'EMPLOYEE';
        l_Person_id            Per_all_assignments_f.person_id%type;
        l_return_status        VARCHAR2(2000);
        l_msg_data             VARCHAR2(2000);
        l_msg_count            NUMBER;
        l_dummy                NUMBER;
        L_API_VERSION          CONSTANT NUMBER := 1.0;

        CURSOR get_all_resource(l_organization_id  Hr_Organization_Information.Organization_id%type) is

             SELECT distinct ind.person_id
               FROM  pa_r_project_resources_ind_v ind
                     ,hr_organization_information hoi
              WHERE  ind.organization_id                          =
	       /* Changed for Bug 2499051-  l_organization_id */   hoi.organization_id
   		AND  ind.assignment_end_date                     >= sysdate
                AND  hoi.organization_id                          = l_organization_id
                AND  hoi.org_information_context                  = 'Exp Organization Defaults'
           ORDER BY  ind.person_id;

BEGIN
	-- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.pull_resources');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

	open get_all_resource(p_organization_id);
            LOOP
                fetch get_all_resource into
                   l_person_id;
                Exit when get_all_resource%NOTFOUND;

		PA_R_PROJECT_RESOURCES_PUB.CREATE_RESOURCE (
                                 P_API_VERSION   => L_API_VERSION
                                ,P_COMMIT        => l_commit
                                ,P_VALIDATE_ONLY => l_validate_only
                                ,P_INTERNAL      => l_internal
                                ,P_PERSON_ID     => l_person_id
                                ,P_INDIVIDUAL    => l_individual
                                ,P_RESOURCE_TYPE => l_resource_type
                                ,X_RETURN_STATUS => l_return_status
                                ,X_RESOURCE_ID   => l_dummy
                                ,X_MSG_COUNT     => l_msg_count
                                ,X_MSG_DATA      => l_msg_data  );

                -- call this procedure to update the forecast data for
                -- assigned time ONLY for this resource
                -- pass null to start date and end date
                -- this is called only if create_resource is a success
                if (l_return_status = FND_API.G_RET_STS_SUCCESS) then
                     PA_FORECASTITEM_PVT.Create_Forecast_Item(
                                  p_person_id      => l_person_id
                                 ,p_start_date     => null
                                 ,p_end_date       => null
                                 ,p_process_mode   => 'GENERATE_ASGMT'
                                 ,x_return_status  => l_return_status
                                 ,x_msg_count      => l_msg_count
                                 ,x_msg_data       => l_msg_data
                               ) ;

                     if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
                              COMMIT;
                     else
                              ROLLBACK;
                     end if;
                else
                     ROLLBACK;
                end if;

             END LOOP;
        close get_all_resource;

        --set the final return status to SUCCESS after loop
        x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- reset the Error stack
        PA_DEBUG.Reset_Err_Stack;

EXCEPTION
        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name        => 'PA_HR_UPDATE_API.pull_resources'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;

END pull_resources;


-- This API  will be called from workflow process to update/create resources in projects.
-- The workflow would be kicked of by the database trigger on pa_all_organization entity
-- whenever a inactive_date in pa_all_organization is updated this api get kicked of by the
-- workflow.
-- Make this procedure a PRAGMA AUTONOMOUS_TRANSACTION because we'll commit after every
-- resource in the loop
PROCEDURE make_resource_inactive
                (P_calling_mode       IN   VARCHAR2
                ,P_Organization_id    IN   Hr_Organization_Information.Organization_id%type
                ,P_Default_OU         IN    pa_all_organizations.org_id%type
                ,P_inactive_date      IN   pa_all_organizations.inactive_date%type
		,P_Default_OU_NEW     IN    pa_all_organizations.org_id%type DEFAULT NULL   -- Added for bug 5330402
                ,x_return_status      OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                ,x_msg_data           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
               ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_return_status        VARCHAR2(2000);
        v_error_message_code   VARCHAR2(2000);
        v_assn_start_date      Per_all_assignments_f.Effective_Start_Date%type;
        v_assn_end_date        Per_all_assignments_f.Effective_End_Date%type;
        v_Person_id            Per_all_assignments_f.person_id%type;
        v_resource_id          Pa_Resource_txn_attributes.resource_id%type;
        v_Default_OU           Hr_Organization_Information.Org_Information1%type;
        v_msg_data             VARCHAR2(2000);
        v_msg_count            NUMBER;

       -- get  all the resources who are employees and belongs to expenditure
       -- organizations and in the expenditure  organization hierarchy
       -- and have a primary assignment (Active assignment) and have assigned
       -- to default OU

       -- Bug 4347907 - change to base HR tables and remove nvl on dates
       --MOAC changes: bug 4363092: removed nvl used with org_id
        CURSOR get_all_inactive_resource
          IS
          SELECT
                distinct
                assn.person_id
                ,assn.effective_start_date
                ,assn.effective_end_date
                , res.resource_id
                , hrinf.org_information1
          FROM  per_all_assignments_f assn
                , hr_organization_information hrinf
          /*      , per_person_types pertypes  Commented for bug#2781713 */
                , per_assignment_status_types  pastype
                , pa_resource_txn_attributes res
                , pa_all_organizations allorgs
                , per_all_people_f pep
         WHERE
                assn.assignment_status_type_id = pastype.assignment_status_type_id
          AND   assn.person_id = res.person_id
          AND   assn.primary_flag = 'Y'
          AND   assn.assignment_type in ('E', 'C') -- CWK Changes
          AND   assn.organization_id = allorgs.organization_id
          AND   assn.organization_id = hrinf.organization_id
          AND   assn.effective_start_date BETWEEN pep.effective_start_date
                                          AND     pep.effective_end_date
          AND   assn.effective_end_date >= trunc(sysdate)
          AND   pastype.per_system_status in  ('ACTIVE_ASSIGN', 'ACTIVE_CWK') -- CWK Changes
          AND   hrinf.org_information_context = 'Exp Organization Defaults'
/*          AND   pertypes.system_person_type = 'EMP'  Commented for bug#2781713 */
          AND   (pep.employee_number is not null OR pep.npw_number IS NOT NULL) -- CWK Changes
/*          AND   pep.person_type_id = pertypes.person_type_id  Commented for bug#2781713 */
          AND (pep.current_employee_flag = 'Y' /* added for bug#2781713 */ OR
               pep.current_npw_flag = 'Y') -- CWK Changes
          AND   pep.person_id = assn.person_id
          AND   allorgs.organization_id = P_organization_id
          AND   allorgs.org_id = P_default_OU
          AND   allorgs.pa_org_use_type = 'EXPENDITURES'
          AND   allorgs.inactive_date is Not null
          AND   (allorgs.organization_id,allorgs.org_id) = (
                SELECT exporg.organization_id, exporg.org_id
                FROM pa_all_organizations exporg
                WHERE exporg.pa_org_use_type = 'EXPENDITURES'
                AND exporg.inactive_date is Not null
                AND exporg.organization_id = allorgs.organization_id
                AND exporg.org_id  = allorgs.org_id
                AND rownum = 1 );

/* -- Added for bug 5330402
cursor get_all_inactive_resource_org is same as
get_all_inactive_resource but commented out inactive date condition in where clause
*/
        CURSOR get_all_inactive_resource_org
          IS
          SELECT
                distinct
                assn.person_id
                ,assn.effective_start_date
                ,assn.effective_end_date
                , res.resource_id
              --  , hrinf.org_information1
          FROM  per_all_assignments_f assn
                , hr_organization_information hrinf
          /*      , per_person_types pertypes  Commented for bug#2781713 */
                , per_assignment_status_types  pastype
                , pa_resource_txn_attributes res
                , pa_all_organizations allorgs
                , per_all_people_f pep
         WHERE
                assn.assignment_status_type_id = pastype.assignment_status_type_id
          AND   assn.person_id = res.person_id
          AND   assn.primary_flag = 'Y'
          AND   assn.assignment_type in ('E', 'C') -- CWK Changes
          AND   assn.organization_id = allorgs.organization_id
          AND   assn.organization_id = hrinf.organization_id
          AND   assn.effective_start_date BETWEEN pep.effective_start_date
                                          AND     pep.effective_end_date
          AND   assn.effective_end_date >= trunc(sysdate)
          AND   pastype.per_system_status in  ('ACTIVE_ASSIGN', 'ACTIVE_CWK') -- CWK Changes
          AND   hrinf.org_information_context = 'Exp Organization Defaults'
/*          AND   pertypes.system_person_type = 'EMP'  Commented for bug#2781713 */
          AND   (pep.employee_number is not null OR pep.npw_number IS NOT NULL) -- CWK Changes
/*          AND   pep.person_type_id = pertypes.person_type_id  Commented for bug#2781713 */
          AND (pep.current_employee_flag = 'Y' /* added for bug#2781713 */ OR
               pep.current_npw_flag = 'Y') -- CWK Changes
          AND   pep.person_id = assn.person_id
          AND   allorgs.organization_id = P_organization_id
          AND   allorgs.org_id = P_default_OU		      -- Removed the NVL as this is not required.Sunkalya.Bug#5330402
          AND   allorgs.pa_org_use_type = 'EXPENDITURES'
      --    AND   allorgs.inactive_date is Not null
          AND   (allorgs.organization_id,allorgs.org_id) = (  -- Removed the NVL as this is not required.Sunkalya.Bug#5330402
                SELECT exporg.organization_id, exporg.org_id
                FROM pa_all_organizations exporg
                WHERE exporg.pa_org_use_type = 'EXPENDITURES'
              --  AND exporg.inactive_date is Not null
                AND exporg.organization_id = allorgs.organization_id
                AND exporg.org_id          = allorgs.org_id   -- Removed the NVL as this is not required.Sunkalya.Bug#5330402
                AND rownum = 1 );

BEGIN
        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.make_resource_inactive');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

       --dbms_output.put_line('Inside make resource inactive');
       --dbms_output.put_line('Default OU:' || p_default_ou);
       /* bug 5330402
       P_Default_OU_NEW will be null when called for orghierarchy update
       P_Default_OU_NEW will not be null when called for nulling out default OU
*/
        IF p_inactive_date is NOT NULL and p_calling_mode = 'UPDATE' then
	     if P_Default_OU_NEW is null then
	          open get_all_inactive_resource;
	     else
                  open get_all_inactive_resource_org;
	     end if;
             LOOP
	        if P_Default_OU_NEW is null then --bug 5330402
                    fetch get_all_inactive_resource into
                     v_person_id
                    ,v_assn_start_date
                    ,v_assn_end_date
                    ,v_resource_id
		    ,v_default_OU;
                    Exit when get_all_inactive_resource%NOTFOUND;
		 else
                  fetch get_all_inactive_resource_org into
                     v_person_id
                    ,v_assn_start_date
                    ,v_assn_end_date
                    ,v_resource_id;
                  Exit when get_all_inactive_resource_org%NOTFOUND;
		   v_default_OU := P_Default_OU; --bug 5330402 setting OU to old value though currently it is null
		  end if;
                  If v_person_id is NOT NULL  then

                      --dbms_output.put_line('Calling Update OU Resource');
		      -- update the resource denorm with end date the resources
                      Update_OU_resource (
                         P_default_OU_old      => v_default_OU
                         ,p_default_OU_new     => v_default_OU
                         ,P_person_id          => v_person_id
                         ,P_start_date         => v_assn_start_date
                         ,P_end_date_old       => v_assn_end_date
                         ,P_end_date_new       => p_inactive_date
                         ,x_return_status      => x_return_status
                         ,x_msg_data           => x_msg_data
                         ,x_msg_count          => x_msg_count );

                      if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
                            COMMIT;
                      else
                            ROLLBACK;
                      end if;

                  End if;

             END LOOP;
	     if P_Default_OU_NEW is null then  --bug 5330402
		close get_all_inactive_resource;
	     else
		close get_all_inactive_resource_org;
	     end if;

             --set the final return status to SUCCESS after loop
             x_return_status := FND_API.G_RET_STS_SUCCESS;

        END IF;

        -- reset the Error stack
        PA_DEBUG.Reset_Err_Stack;
EXCEPTION
        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.make_resource_inactive'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;



END make_resource_inactive;


-- This API makes calls to PA_FORECASTITEM_PVT.Create_Forecast_Item api
-- which will generate or update the forecast items
-- This API performs commit and rollback because it is only called by
-- per_job_extra_billability, which is an autonomous transaction
-- This will not affect the workflow process when doing any commit or rollback
PROCEDURE  call_forcast_api
              (P_table_name     IN VARCHAR2
              ,P_person_id      IN PER_ALL_ASSIGNMENTS_F.PERSON_ID%TYPE default NULL
              ,P_Job_id         IN per_jobs.job_id%type default NULL
              ,P_billable_flag  IN VARCHAR2 default NULL
              ,P_organization_id IN Hr_organization_information.organization_id%type default NULL
              ,p_start_date     IN date default NULL
              ,P_end_date       IN date default NULL
              ,P_resource_OU    IN NUMBER default NULL
              ,P_resource_type  IN VARCHAR2 default NULL
              ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              ,x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              ,x_msg_count      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
             ) IS

         v_person_id       PER_ALL_ASSIGNMENTS_F.PERSON_ID%TYPE;
         v_start_date      Date;
         v_end_date        Date;

        --- This cursor picks all the persons who are Employees category and
        --  belongs to Expenditure Hierarchy
        --  and belongs to job id = paremeter
         Cursor person_jobs(l_job_id  per_jobs.job_id%type)is
               SELECT distinct
                      assn.person_id
                     ,assn.effective_start_date
                     ,assn.effective_end_date
          FROM  per_all_assignments_f assn
                , hr_organization_information hrinf
            /*    , per_person_types pertypes   Commented for Bug#2781713 */
                , per_assignment_status_types  pastype
                , per_all_people_f pep
         WHERE
                assn.assignment_status_type_id = pastype.assignment_status_type_id
          AND   assn.primary_flag = 'Y'
          AND   assn.assignment_type in ('E', 'C') -- CWK Changes
          AND   assn.job_id = l_job_id
          AND   assn.organization_id = hrinf.organization_id
          AND   assn.effective_start_date BETWEEN pep.effective_start_date
                                          AND     pep.effective_end_date
          AND   assn.effective_end_date >= trunc(sysdate)
          AND   pastype.per_system_status in  ('ACTIVE_ASSIGN', 'ACTIVE_CWK') -- CWK Changes
          AND   hrinf.org_information_context = 'Exp Organization Defaults'
       /* AND   pertypes.system_person_type = 'EMP'    Commented for Bug#2781713 */
          AND   (pep.employee_number is not null OR pep.npw_number IS NOT NULL) -- CWK Changes
       /*  AND   pep.person_type_id = pertypes.person_type_id   Commented for Bug#2781713 */
          AND (pep.current_employee_flag = 'Y' /* added for bug#2781713 */ OR
               pep.current_npw_flag = 'Y') -- CWK Changes
          AND   pep.person_id = assn.person_id
          AND   assn.organization_id =
                (SELECT exporg.organization_id
                FROM pa_all_organizations exporg
                WHERE exporg.pa_org_use_type = 'EXPENDITURES'
                AND exporg.inactive_date is null
                AND exporg.organization_id = assn.organization_id
                AND rownum = 1 )
          ORDER BY 1,2;

        -- This cursor picks all the persons who are Employees and belongs to the
        -- expenditure hierarchy and belongs to organzation where organization_id = l_org_id
        CURSOR person_orgs(l_org_id  Hr_Organization_Information.Organization_id%type) is
               SELECT distinct
                      assn.person_id
                     ,assn.effective_start_date
                     ,assn.effective_end_date
          FROM  per_all_assignments_f assn
                , hr_organization_information hrinf
                /* , per_person_types pertypes  Commented for Bug#2781713 */
                , per_assignment_status_types  pastype
                , per_all_people_f pep
         WHERE
                assn.assignment_status_type_id = pastype.assignment_status_type_id
          AND   assn.primary_flag = 'Y'
          AND   assn.assignment_type in ('E', 'C') -- CWK Changes
          AND   assn.organization_id = l_org_id
          AND   assn.organization_id = hrinf.organization_id
          AND   assn.effective_start_date BETWEEN pep.effective_start_date
                                          AND     pep.effective_end_date
          AND   assn.effective_end_date >= trunc(sysdate)
          AND   pastype.per_system_status in  ('ACTIVE_ASSIGN', 'ACTIVE_CWK') -- CWK Changes
          AND   hrinf.org_information_context = 'Exp Organization Defaults'
         /* AND   pertypes.system_person_type = 'EMP'  Commented for Bug#2781713 */
          AND   (pep.employee_number is not null OR pep.npw_number IS NOT NULL) -- CWK Changes
        /*  AND   pep.person_type_id = pertypes.person_type_id   Commented for Bug#2781713 */
          AND (pep.current_employee_flag = 'Y' /* added for bug#2781713 */ OR
               pep.current_npw_flag = 'Y') -- CWK Changes
	  AND   pep.person_id = assn.person_id
          AND   assn.organization_id =
                (SELECT exporg.organization_id
                FROM pa_all_organizations exporg
                WHERE exporg.pa_org_use_type = 'EXPENDITURES'
                AND exporg.inactive_date is null
                AND exporg.organization_id = assn.organization_id
                AND rownum = 1 )
          ORDER BY 1,2;


BEGIN
        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.call_forcast_api');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

        If (P_table_name = 'PER_JOB_EXTRA_INFO'    or
            P_table_name = 'PER_VALID_GRADES'      or
            P_table_name = 'PER_GRADES'            or
            P_table_name = 'PA_ALL_ORGANIZATIONS') and
           (P_job_id is NOT NULL) then

            -- get all the persons belongs to this job Id and
            -- Call Forecast Item regeneration API to update the forecast
            -- data for unassigned and assigned time

           OPEN person_jobs(P_job_id);
           LOOP
                fetch person_jobs into v_person_id,v_start_date,v_end_date;
                exit when person_jobs%notfound;

                PA_FORECASTITEM_PVT.Create_Forecast_Item
                        (
                         p_person_id      => v_person_id
                        ,p_start_date     => v_start_date
                        ,p_end_date       => v_end_date
                        ,p_process_mode   => 'GENERATE'
                        ,x_return_status  => x_return_status
                        ,x_msg_count      => x_msg_count
                        ,x_msg_data       => x_msg_data
                        ) ;

                if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
                     COMMIT;
                else
                     ROLLBACK;
                end if;

             /* cannot raise - because will be out from the loop and will not process other records
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
              */

            END LOOP;
            CLOSE person_jobs;

        Elsif (P_table_name = 'HR_ORGANIZATION_INFORMATION')
               and (P_organization_id is NOT NULL) then

           -- get all the persons who belongs to this organization and
           -- Call Forecast Item regeneration API to update the forecast
           -- data for unassigned and assigned time

           OPEN person_orgs(P_organization_id);
           LOOP
                fetch person_orgs into v_person_id,v_start_date,v_end_date;
                exit when person_orgs%notfound;

                PA_FORECASTITEM_PVT.Create_Forecast_Item
                        (
                         p_person_id      => v_person_id
                        ,p_start_date     => v_start_date
                        ,p_end_date       => v_end_date
                        ,p_process_mode   => 'GENERATE'
                        ,x_return_status  => x_return_status
                        ,x_msg_count      => x_msg_count
                        ,x_msg_data       => x_msg_data
                        ) ;

                if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
                     COMMIT;
                else
                     ROLLBACK;
                end if;

             /* cannot raise - because will be out from the loop and will not process other records
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
              */
            END LOOP;
            CLOSE person_orgs;

         End if;

         --set the final return status to SUCCESS after loop
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         -- reset the Error stack
         PA_DEBUG.Reset_Err_Stack;
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.call_forcast_api'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            raise;



END call_forcast_api;


-- This Procedure makes calls to PA_RESOURCE_PVT.update_resource_denorm api
-- which actually updates the pa_resources_denorm entity
PROCEDURE call_billable_resoruce_denorm
                         (P_job_id_old                 per_jobs.job_id%type
                         ,P_job_id_new                 per_jobs.job_id%type
                         ,P_billable_flag_old          pa_resources_denorm.billable_flag%type
                         ,P_billable_flag_new          pa_resources_denorm.billable_flag%type
                         ,P_utilize_flag_old           pa_resources_denorm.utilization_flag%type
                         ,P_utilize_flag_new           pa_resources_denorm.utilization_flag%type
                         ,p_schedulable_flag_old       pa_resources_denorm.schedulable_flag%type
                         ,p_schedulable_flag_new       pa_resources_denorm.schedulable_flag%type
                         ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         ,x_msg_data                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         ,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                      ) IS
        v_return_status        VARCHAR2(2000);
        v_error_message_code   VARCHAR2(2000);
        v_resource_rec_old     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
        v_resource_rec_new     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
        v_job_id_old           PER_JOBS.JOB_ID%type;
        v_job_id_new           PER_JOBS.JOB_ID%type;
        v_billable_flag_old    pa_resources_denorm.billable_flag%type;
        v_billable_flag_new    pa_resources_denorm.billable_flag%type;
        v_utilize_flag_old     pa_resources_denorm.utilization_flag%type;
        v_utilize_flag_new     pa_resources_denorm.utilization_flag%type;
        v_schedulable_flag_old pa_resources_denorm.schedulable_flag%type;
        v_schedulable_flag_new pa_resources_denorm.schedulable_flag%type;
        v_msg_data             VARCHAR2(2000);
        v_msg_count            NUMBER;

BEGIN

        -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.call_billable_resoruce_denorm');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
                v_job_id_new    := P_job_id_new;
                v_job_id_old    := P_job_id_old;

        If P_billable_flag_new is NOT NULL then
                v_billable_flag_new := P_billable_flag_new;
        Else
                v_billable_flag_new := 'N';
        End if;

        If P_billable_flag_old is NOT NULL then
               v_billable_flag_old := P_billable_flag_old;
        Else
               v_billable_flag_old := 'N';
        End if;

        If P_utilize_flag_new is NOT NULL then
                v_utilize_flag_new := P_utilize_flag_new;
        Else
                v_utilize_flag_new := 'N';
        End if;

        If P_utilize_flag_old is NOT NULL then
               v_utilize_flag_old := P_utilize_flag_old;
        Else
               v_utilize_flag_old := 'N';
        End if;

        If P_schedulable_flag_new is NOT NULL then
                v_schedulable_flag_new := P_schedulable_flag_new;
        Else
                v_schedulable_flag_new := 'N';
        End if;
        If P_schedulable_flag_old is NOT NULL then
                v_schedulable_flag_old := P_schedulable_flag_old;
        Else
                v_schedulable_flag_old := 'N';
        End if;

                if v_job_id_new  is NOT NULL then
                      v_resource_rec_old.job_id             := v_job_id_old;
                      v_resource_rec_old.billable_flag      := v_billable_flag_old;
                      v_resource_rec_new.job_id             := v_job_id_new;
                      v_resource_rec_new.billable_flag      := v_billable_flag_new;
                      v_resource_rec_old.utilization_flag   := v_utilize_flag_old;
                      v_resource_rec_new.utilization_flag   := v_utilize_flag_new;
                      v_resource_rec_old.schedulable_flag   := v_schedulable_flag_old;
                      v_resource_rec_new.schedulable_flag   := v_schedulable_flag_new;

                   -- Call PRM API update resource denorm which actually updates the
                     -- pa_resource_denorm entity

                      PA_RESOURCE_PVT.update_resource_denorm
                      ( p_resource_denorm_old_rec  => v_resource_rec_old
                       ,p_resource_denorm_new_rec  => v_resource_rec_new
                       ,x_return_status            => x_return_status
                       ,x_msg_data                 => x_msg_data
                       ,x_msg_count                => x_msg_count
                       );



                 End if;
        -- reset the Error stack
        PA_DEBUG.Reset_Err_Stack;

EXCEPTION

        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.call_billable_resoruce_denorm'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;

END call_billable_resoruce_denorm;

-- This Procedure is kicked off by the workflow when jei_infomration2
-- which stores the jobs billability information. whenever the row is updated
-- or inserted into per_job_extra_info entity which stores the job information
-- and types a database triggers fires and kicks of the workflow
-- This procedure makes calls to forecast regenerate apis and create resource
-- denorm apis to to update the new billability for the resource
-- Make this procedure a PRAGMA AUTONOMOUS_TRANSACTION because at the end
-- this procedure call call_forcast_api which do commit after every resource
-- in a loop to update the forecast items
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
                      ,x_msg_count                    OUT NOCOPY NUMBER) IS --File.Sql.39 bug 4440895
 PRAGMA AUTONOMOUS_TRANSACTION;

 v_return_status        VARCHAR2(2000);
 v_error_message_code   VARCHAR2(2000);
 v_job_id               PER_JOBS.JOB_ID%type;
 v_msg_data             VARCHAR2(2000);
 v_msg_count            NUMBER;
 l_pull_res_flag        VARCHAR2(1) := 'N';
 l_end_date_res_flag    VARCHAR2(1) := 'N';
 l_prv_person_id        NUMBER;
 l_resource_id          NUMBER;
 P_DEBUG_MODE VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

 /*
  CURSOR all_job_res_recs IS
    SELECT person_id, min(resource_effective_start_date) resource_effective_start_date,
           max(resource_effective_end_date) resource_effective_end_date
      FROM pa_resources_denorm
     WHERE job_id = p_job_id
  GROUP BY person_id;  */

  CURSOR all_job_res_recs IS  -- Modified cursor for Bug 7336158
    SELECT person_id, min(resource_effective_start_date) resource_effective_start_date,
           max(resource_effective_end_date) resource_effective_end_date
      FROM pa_resources_denorm
     WHERE job_id = p_job_id
     AND resource_effective_end_date = (Select max(resource_effective_end_date)
                                              from pa_resources_denorm rd2
                                              where rd2.job_id = p_job_id
                                              AND (rd2.resource_effective_end_date >= sysdate OR rd2.resource_effective_end_date is null))
  GROUP BY person_id;

 CURSOR distinct_job_res_recs IS
    SELECT DISTINCT res.person_id person_id
      FROM pa_r_project_resources_v res
     WHERE res.job_id = p_job_id;

BEGIN
 -- Initialize the Error stack
 PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.per_job_extra_billability');
 X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

 IF P_DEBUG_MODE = 'Y' THEN
    log_message('beginning of per_job_extra_billability, P_calling_mode:'|| P_calling_mode || ', job_id: '||P_job_id);
 END IF;

 -------------------------------------------------------------------------
 -- If P_calling_mode='INSERT', P_utilize_flag_new will always be 'Y' and
 -- we need to pull those people who has the job.
 -- Because if P_utilize_flag_new=N, the trigger won't launch WF which
 -- eventually calls this API.
 --------------------------------------------------------------------------
 If P_calling_mode = 'INSERT' THEN
   l_pull_res_flag := 'Y';

 -------------------------------------------------------------------------
 -- If P_calling_mode='UPDATE'
 -------------------------------------------------------------------------
 ELSIF P_calling_mode = 'UPDATE' THEN
   -- If p_utilize_flag_old='N' AND p_utilize_flag_new='Y', we need to
   -- pull the people who have the job
   IF p_utilize_flag_old='N' AND p_utilize_flag_new='Y' THEN
     l_pull_res_flag := 'Y';

   ELSE
     -- If p_utilize_flag_old='Y' and p_utilize_flag_new ='N', we need
     -- to end date the resources from pa_resources_denorm
     IF p_utilize_flag_old ='Y' AND p_utilize_flag_new ='N' THEN
       l_end_date_res_flag := 'Y';
     END IF;

     IF P_DEBUG_MODE = 'Y' THEN
         log_message('p_utilize_flag_new: ' ||p_utilize_flag_new ||
                     ',l_end_date_res_flag: '||l_end_date_res_flag);
     END IF;

     -- Update pa_resources_denorm
     call_billable_resoruce_denorm
            (P_job_id_old           => P_job_id
            ,P_job_id_new           => P_job_id
            ,P_billable_flag_old    => P_billable_flag_old
            ,P_billable_flag_new    => P_billable_flag_new
            ,P_utilize_flag_old     => P_utilize_flag_old
            ,P_utilize_flag_new     => P_utilize_flag_new
            ,p_schedulable_flag_old => p_schedulable_flag_old
            ,p_schedulable_flag_new => p_schedulable_flag_new
            ,x_return_status        => x_return_status
            ,x_msg_data             => x_msg_data
            ,x_msg_count            => x_msg_count );
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('After call_billable_resoruce_denorm');
     END IF;

     -- Update job level
     update_job_level_dff
            (P_job_id             => P_job_id
            ,P_job_level_old      => TO_NUMBER(P_job_level_old)
            ,P_job_level_new      => TO_NUMBER(P_job_level_new)
            ,x_return_status      => x_return_status
            ,x_msg_data           => x_msg_data
            ,x_msg_count          => x_msg_count );
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('After update_job_level_dff');
     END IF;
   END IF;

 -------------------------------------------------------------------------
 -- If P_calling_mode='DELETE' and p_utilize_flag_old='Y', end date those
 -- resources who has the job. If p_utilize_flag_old='N', there won't be
 -- current active data. But we still need to update the other flags on
 -- the past date records.
 -------------------------------------------------------------------------
 ELSIF P_calling_mode = 'DELETE' THEN
   IF p_utilize_flag_old ='Y' THEN
     l_end_date_res_flag := 'Y';
   END IF;
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('P_calling_mode=DELETE, p_utilize_flag_old:'||p_utilize_flag_old
                  ||', l_end_date_res_flag:'||l_end_date_res_flag);
     END IF;

   call_billable_resoruce_denorm
                (P_job_id_old           => P_job_id
                ,P_job_id_new           => P_job_id
                ,P_billable_flag_old    => P_billable_flag_old
                ,P_billable_flag_new    => NULL
                ,P_utilize_flag_old     => P_utilize_flag_old
                ,P_utilize_flag_new     => NULL
                ,p_schedulable_flag_old => p_schedulable_flag_old
                ,p_schedulable_flag_new => NULL
                ,x_return_status        => x_return_status
                ,x_msg_data             => x_msg_data
                ,x_msg_count            => x_msg_count );

   update_job_level_dff
                (P_job_id             => P_job_id
                ,P_job_level_old      => TO_NUMBER(P_job_level_old)
                ,P_job_level_new      => NULL
                ,x_return_status      => x_return_status
                ,x_msg_data           => x_msg_data
                ,x_msg_count          => x_msg_count );
   IF P_DEBUG_MODE = 'Y' THEN
      log_message('After calling update_job_level_dff');
   END IF;
 END IF;

 ----------------------------------------------------------------
 -- pull the people
 ----------------------------------------------------------------
 IF (l_pull_res_flag = 'Y') THEN
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('it will pull the people');
    END IF;
    FOR rec IN distinct_job_res_recs  LOOP
       BEGIN
          IF P_DEBUG_MODE = 'Y' THEN
             log_message('person Id = ' || rec.person_id);
          END IF;

          PA_R_PROJECT_RESOURCES_PUB.CREATE_RESOURCE (
                    p_api_version   => 1.0
                   ,p_commit        => FND_API.G_FALSE
                   ,p_validate_only => FND_API.G_FALSE
                   ,p_internal      => 'Y'
                   ,p_person_id     => rec.person_id
                   ,p_individual    => 'Y'
                   ,p_resource_type => 'EMPLOYEE'
                   ,x_resource_id   => l_resource_id
                   ,x_return_status => x_return_status
                   ,x_msg_count     => x_msg_count
                   ,x_msg_data      => x_msg_data );

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Return status from CREATE_RESOURCE = ' || x_return_status);
          END IF;
          IF (x_return_status = FND_API.G_RET_STS_SUCCESS) then
             COMMIT;
          ELSE
             ROLLBACK;
          END IF;

       EXCEPTION
          -- whenever an expected error is raised from this API
          -- will need to continue for the next record
          WHEN OTHERS THEN
              FND_MSG_PUB.get (
                    p_encoded        => FND_API.G_FALSE,
                    p_msg_index      => 1,
                    p_data           => x_msg_data,
                    p_msg_index_out  => x_msg_count );
              IF P_DEBUG_MODE = 'Y' THEN
                 log_message('error msg from CREATE_RESOURCE: ' || substr(x_msg_data,1,200));
              END IF;
       END;
    END LOOP;

 -----------------------------------------------------------------------------
 -- End date all those resources who has the job from the pa_resources_denorm
 -----------------------------------------------------------------------------
 ELSIF (l_end_date_res_flag = 'Y') THEN
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('it will end date the resources');
    END IF;
    FOR rec IN all_job_res_recs  LOOP
       BEGIN
          IF P_DEBUG_MODE = 'Y' THEN
             log_message('person Id = ' || rec.person_id ||' ,start_date: ' ||
                      rec.resource_effective_start_date || ', end_date: '||
                      rec.resource_effective_end_date );
          END IF;

          Update_EndDate
                   (p_person_id            => rec.person_id,
                    p_old_start_date       => rec.resource_effective_start_date,
                    p_new_start_date       => rec.resource_effective_start_date,
                    p_old_end_date         => rec.resource_effective_end_date,
                    p_new_end_date         => sysdate,
                    x_return_status        => x_return_status,
                    x_msg_count            => x_msg_count,
                    x_msg_data             => x_msg_data);

          IF P_DEBUG_MODE = 'Y' THEN
             log_message('Return status from Update_EndDate = ' || x_return_status);
          END IF;
          IF (x_return_status = FND_API.G_RET_STS_SUCCESS) then
             COMMIT;
          ELSE
             ROLLBACK;
          END IF;
       EXCEPTION
          -- whenever an expected error is raised from this API
          -- will need to continue for the next record
          WHEN OTHERS THEN
             IF P_DEBUG_MODE = 'Y' THEN
                log_message('error occured');
             END IF;
             ROLLBACK;
             FND_MSG_PUB.get (
                     p_encoded        => FND_API.G_FALSE,
                     p_msg_index      => 1,
                     p_data           => x_msg_data,
                     p_msg_index_out  => x_msg_count );
             IF P_DEBUG_MODE = 'Y' THEN
                log_message('error msg from Update_EndDate: ' || substr(x_msg_data,1,200));
             END IF;
       END;
    END LOOP;

 END IF;


 -- call forecast api to regenerate the forcast items due to change in
 -- billability flag
 call_forcast_api
         (P_table_name     => 'PER_JOB_EXTRA_INFO'
         ,P_Job_id         => P_job_id
         ,x_return_status  => x_return_status
         ,x_msg_data       => x_msg_data
         ,x_msg_count      => x_msg_count );
 IF P_DEBUG_MODE = 'Y' THEN
    log_message('After calling call_forcast_api, x_return_status: '||x_return_status);
 END IF;

 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('It will raise exception');
    END IF;
    RAISE FND_API.G_EXC_ERROR;
 ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('will commit');
    END IF;
    COMMIT;
 END IF;

 -- reset the Error stack
 PA_DEBUG.Reset_Err_Stack;
 IF P_DEBUG_MODE = 'Y' THEN
    log_message('after Reset_Err_Stack');
 END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN NO_DATA_FOUND THEN
       NULL;
    WHEN OTHERS THEN
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('Error occured');
       END IF;
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
       -- Set the exception Message and the stack
       FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.per_job_extra_billability'
                              ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;
END per_job_extra_billability;


-- PROCEDURE
--        withdraw_cand_nominations
-- PURPOSE
--        to withdraw all PJR candidate nominations for this
--        person_id when the person is terminated in HR
--        or the assignment organization no longer belongs to
--        expenditure hierarchy
--
PROCEDURE withdraw_cand_nominations
                ( p_person_id        IN    NUMBER,
                  p_effective_date   IN    DATE,
                  x_return_status    OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_msg_count        OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
                  x_msg_data         OUT   NOCOPY VARCHAR2) IS   --File.Sql.39 bug 4440895

    l_resource_id    NUMBER;
    l_status_code    VARCHAR2(30);
    l_rec_ver_num    NUMBER;
    P_DEBUG_MODE VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

    CURSOR get_nominations(l_resource_id IN NUMBER) IS
        select cand.candidate_id, cand.record_version_number
        from pa_candidates cand,
             pa_project_assignments asgmt,
             pa_project_statuses ps
        where cand.resource_id                   = l_resource_id
          and cand.assignment_id                 = asgmt.assignment_id
          and asgmt.assignment_type              = 'OPEN_ASSIGNMENT'
          and asgmt.status_code                  = ps.project_status_code (+)
          and (ps.project_system_status_code     = 'OPEN_ASGMT'
            OR ps.project_system_status_code is null)
          and asgmt.start_date                   > trunc(p_effective_date)
          and cand.status_code not in
                  (select ps2.project_status_code
                   from pa_project_statuses ps2
                   where ps2.status_type='CANDIDATE'
                     and ps2.project_system_status_code IN
                                   ('CANDIDATE_DECLINED','CANDIDATE_WITHDRAWN'));

    l_candidate_in_rec	 PA_RES_MANAGEMENT_AMG_PUB.CANDIDATE_IN_REC_TYPE;  -- Added for bug 9187892


BEGIN

    -- Initialize the Error stack
    PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.withdraw_cand_nominations');
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    l_resource_id := PA_RESOURCE_UTILS.get_resource_id(p_person_id);

    IF (l_resource_id <> -999) THEN

       l_status_code  := FND_PROFILE.value('PA_INV_RES_CAND_STATUS');
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('Candidate status code = ' || l_status_code);
       END IF;

       -- if the profile option is not set, then we use the status code
       -- '111' that we ship to customers for 'CANDIDATE_WITHDRAWN'
       -- system status code
       IF l_status_code is null THEN
          l_status_code := '111';
       END IF;

       FOR rec IN get_nominations(l_resource_id) LOOP

         BEGIN
            SAVEPOINT save_candidate;
            IF P_DEBUG_MODE = 'Y' THEN
               log_message('Candidate Id = ' || rec.candidate_id);
            END IF;

            PA_CANDIDATE_PUB.Update_Candidate
                   (p_candidate_id            => rec.candidate_id,
                    p_status_code             => l_status_code,
                    p_ranking                 => null,
                    p_change_reason_code      => null,
                    p_record_version_number   => rec.record_version_number,
                    p_init_msg_list           => FND_API.G_FALSE,
                    p_validate_status         => FND_API.G_FALSE,
                    -- Added for bug 9187892
                    p_attribute_category    => l_candidate_in_rec.attribute_category,
                    p_attribute1            => l_candidate_in_rec.attribute1,
                    p_attribute2            => l_candidate_in_rec.attribute2,
                    p_attribute3            => l_candidate_in_rec.attribute3,
                    p_attribute4            => l_candidate_in_rec.attribute4,
                    p_attribute5            => l_candidate_in_rec.attribute5,
                    p_attribute6            => l_candidate_in_rec.attribute6,
                    p_attribute7            => l_candidate_in_rec.attribute7,
                    p_attribute8            => l_candidate_in_rec.attribute8,
                    p_attribute9            => l_candidate_in_rec.attribute9,
                    p_attribute10           => l_candidate_in_rec.attribute10,
                    p_attribute11           => l_candidate_in_rec.attribute11,
                    p_attribute12           => l_candidate_in_rec.attribute12,
                    p_attribute13           => l_candidate_in_rec.attribute13,
                    p_attribute14           => l_candidate_in_rec.attribute14,
                    p_attribute15           => l_candidate_in_rec.attribute15,
                    x_record_version_number   => l_rec_ver_num,
                    x_return_status           => x_return_status,
                    x_msg_count               => x_msg_count,
                    x_msg_data                => x_msg_data);

            IF P_DEBUG_MODE = 'Y' THEN
               log_message('Return status from Update Candidate = ' || x_return_status);
            END IF;

         EXCEPTION
            -- whenever an expected error is raised from this API
            -- will need to continue for the next record
            WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO save_candidate;
                FND_MSG_PUB.get (
                     p_encoded        => FND_API.G_FALSE,
                     p_msg_index      => 1,
                     p_data           => x_msg_data,
                     p_msg_index_out  => x_msg_count );
                IF P_DEBUG_MODE = 'Y' THEN
                   log_message('Withdraw_Cand_Nominations EXPECTED ERROR: Candidate_Id =' || rec.candidate_id);
                   log_message('Log: ' || substr(x_msg_data,1,200));
                END IF;
         END;

       END LOOP;

       X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    ELSE
       -- person does not exist in pa_resource_txn_attributes
       X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    END IF;

    -- reset the Error stack
    PA_DEBUG.Reset_Err_Stack;

EXCEPTION

    WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
       -- Set the exception Message and the stack
       FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.withdraw_cand_nominations'
                              ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       raise;
END withdraw_cand_nominations;


/* Procedure Update_EndDate calls Update_Resource_Denorm to update the
   end date in pa_resources_denorm and update FI data for the resource.
   This procedure now also handles automatic candidates withdrawal.
   It is called whenever a resource is terminated in HR, whenever
   the change in assignment organization which does not belong to Exp Hier,
   or whenever an organization is taken out from the Exp Hier. In these
   cases, the resource is considered no longer active in PJR.
*/
PROCEDURE Update_EndDate(
    p_person_id          IN   per_all_people_f.person_id%TYPE,
    p_old_start_date     IN   per_all_assignments_f.effective_start_date%TYPE,
    p_new_start_date     IN   per_all_assignments_f.effective_end_date%TYPE,
    p_old_end_date       IN   per_all_assignments_f.effective_start_date%TYPE,
    p_new_end_date       IN   per_all_assignments_f.effective_end_date%TYPE,
    x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_data           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count	         OUT  NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

    l_resource_rec_old     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
    l_resource_rec_new     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;

    l_return_status        VARCHAR2(1);

    l_invol_term            VARCHAR2(1); --bug 5683340

    l_count  NUMBER ; -- bug 7147575

    CURSOR res_denorm_recs IS
	       SELECT resource_effective_start_date,
               resource_effective_end_date
        FROM   pa_resources_denorm
        WHERE  person_id = p_person_id
     --   AND    p_new_end_date >= resource_effective_start_date
        AND    resource_effective_start_date >= p_old_start_date
        AND    resource_effective_end_date   <= p_old_end_date
    ;

    -- Bug 8791391
    l_resource_effective_end_date  per_all_assignments_f.effective_end_date%TYPE ;
    l_withdraw_nom_flag            VARCHAR2(1) :='Y';
BEGIN

    --dbms_output.put_line('Inside Update End Date');
    --dbms_output.put_line('Person Id:' || p_person_id);
    --dbms_output.put_line('New End Date:' || p_new_end_date);

    -- Initialize the Error stack
    PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.Update_EndDate');
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    l_count := 0; -- bug 7147575 : None records in pa_resources_denorm so far.

    FOR rec IN res_denorm_recs LOOP

    l_count := l_count + 1 ; -- bug 7147575 :this means that there was atleast one record in pa_resources_denorm

        --dbms_output.put_line('resource_effective_start_date:' || rec.resource_effective_start_date);
        --dbms_output.put_line('resource_effective_end_date:' || rec.resource_effective_end_date);


        -- Bug 4668272 - added case of p_new_end_date >
        -- rec.resource_effective_end_date - this case occurs when a
        -- reverse termination happens in HR.
        -- IF p_new_end_date BETWEEN rec.resource_effective_start_date AND rec.resource_effective_end_date THEN
        IF (p_new_end_date BETWEEN rec.resource_effective_start_date AND
                                   rec.resource_effective_end_date) OR
           (p_new_end_date > rec.resource_effective_end_date) THEN

              --End date this record
	      --Set the values for the Resources Denorm Record Type

              l_resource_rec_old.person_id := p_person_id;
              l_resource_rec_new.person_id := p_person_id;

              l_resource_rec_old.resource_effective_start_date := rec.resource_effective_start_date;
              l_resource_rec_new.resource_effective_start_date := rec.resource_effective_start_date;

              l_resource_rec_old.resource_effective_end_date :=  rec.resource_effective_end_date;
              l_resource_rec_new.resource_effective_end_date :=  p_new_end_date;

              --Call Resource Denorm API
	      PA_RESOURCE_PVT.update_resource_denorm(
	              p_resource_denorm_old_rec  => l_resource_rec_old
	             ,p_resource_denorm_new_rec  => l_resource_rec_new
	             ,x_return_status            => l_return_status
	             ,x_msg_data                 => x_msg_data
	             ,x_msg_count                => x_msg_count);

	      IF l_return_status  = FND_API.G_RET_STS_ERROR THEN
	             x_return_status := FND_API.G_RET_STS_ERROR ;
              END IF;

        ELSIF p_new_end_date < rec.resource_effective_start_date THEN

	      --Delete this record
              pa_resource_pvt.delete_resource_denorm(
	             p_person_id                  => p_person_id
	             ,p_res_effective_start_date  => rec.resource_effective_start_date
	             ,x_return_status             => l_return_status
                     ,x_msg_data                  => x_msg_data
		     ,x_msg_count                 => x_msg_count);

              IF l_return_status  = FND_API.G_RET_STS_ERROR THEN
	             x_return_status := FND_API.G_RET_STS_ERROR ;
              END IF;

        END IF;

    END LOOP; --end FOR

IF (l_count > 0 ) THEN   -- bug 7147575 : so now on, only if records are there in pa_resources_denorm, then only further code will get executed.

 /*Call added for bug 5683340*/
 pa_resource_utils.init_fte_sync_wf( p_person_id => p_person_id,
                                     x_invol_term => l_invol_term,
                                     x_return_status => l_return_status,
                                     x_msg_data => x_msg_data,
                                     x_msg_count => x_msg_count);

IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
END IF ;

/*if block added for bug 5683340*/
IF ((l_invol_term = 'N') AND (l_return_status = FND_API.G_RET_STS_SUCCESS)) THEN

    --Call Forecast Item regeneration API
    --to fix forecast data after resource was end_dated
    --start_date passed is the date when it changes
    PA_FORECASTITEM_PVT.Create_Forecast_Item(
            p_person_id	     => p_person_id,
            --p_start_date     => p_new_end_date+1, p_old_end_date Bug 6120875
	    p_start_date     => Least(p_new_end_date+1, p_old_end_date+1),
            p_end_date	     => null,
            p_process_mode   => 'GENERATE',
            x_return_status  => l_return_status,
            x_msg_count	     => x_msg_count,
            x_msg_data	     => x_msg_data) ;

    IF l_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF;


    -- Bug 8791391
    -- Candidancy should be withdrawn only if end dates have been modified
    -- It shouldnt get called when assignments are modified in update mode
    -- which causes in creation of new row and updation of teh endate of the
    -- existing row.

		SELECT MAX(paaf.effective_end_date)
		  INTO l_resource_effective_end_date
		  FROM per_all_assignments_f paaf,
		       per_assignment_status_types past
		  WHERE paaf.person_id=p_person_id
		  AND paaf.primary_flag = 'Y'
		  AND paaf.assignment_type in ('E','C')
		  AND past.assignment_status_type_id = paaf.assignment_status_type_id
		  AND past.per_system_status in ('ACTIVE_ASSIGN','ACTIVE_CWK');

	  IF trunc(p_new_end_date) < trunc(l_resource_effective_end_date) THEN
	  	l_withdraw_nom_flag := 'Y';
	  ELSE
	    l_withdraw_nom_flag := 'N';
	  END IF;


    -- Call this procedure to withdraw any active candidacy of this
    -- person in PJR whenever the person is end dated (due to termination
    -- or the organization no longer belong to Exp Hier)
    IF l_withdraw_nom_flag = 'Y' THEN   --Bug 8791391
	    withdraw_cand_nominations
	                ( p_person_id        => p_person_id,
	                  p_effective_date   => p_new_end_date,
	                  x_return_status    => l_return_status,
	                  x_msg_count        => x_msg_count,
	                  x_msg_data         => x_msg_data);
		END IF;

    -- reset the Error stack

END IF ;  --((l_invol_term = 'N') AND (l_return_status = FND_API.G_RET_STS_SUCCESS)) bug 5683340

END IF ; -- bug 7147575 : IF (l_count > 0 )

    PA_DEBUG.Reset_Err_Stack;

 EXCEPTION

	WHEN NO_DATA_FOUND THEN
	  x_return_status := FND_API.G_RET_STS_ERROR ;

        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.Update_EndDate'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;
 END Update_EndDate;

/* Procedure Update_Org calls Update_Resource_Denorm and Create_Forecast_Item to update the organization and org_id for the resources in pa_resources_denorm table and regenerate forecast items for the resource respectively.
*/
 PROCEDURE Update_Org(
     p_person_id	  IN    per_all_people_f.person_id%TYPE,
     p_old_org_id	  IN	per_all_assignments_f.organization_id%TYPE,
     p_new_org_id	  IN	per_all_assignments_f.organization_id%TYPE,
     p_old_start_date     IN	per_all_assignments_f.effective_start_date%TYPE,
     p_new_start_date     IN	per_all_assignments_f.effective_end_date%TYPE,
     p_old_end_date	  IN	per_all_assignments_f.effective_start_date%TYPE,
     p_new_end_date	  IN	per_all_assignments_f.effective_end_date%TYPE,
     x_return_status      OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_data           OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count	  OUT   NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

     l_default_ou_old       pa_resources_denorm.resource_org_id%TYPE;
     l_default_ou_new       pa_resources_denorm.resource_org_id%TYPE;

     l_resource_rec_old     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
     l_resource_rec_new     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;

     l_return_status        VARCHAR2(1);
     l_org_type             VARCHAR2(20);
     l_resource_id          NUMBER(15);


    -- Cursor to get all denormalized resource records
    --   for this HR assignment
    CURSOR res_denorm_recs IS
	       SELECT resource_effective_start_date,
               resource_effective_end_date
        FROM   pa_resources_denorm
        WHERE  person_id = p_person_id
        AND    resource_effective_start_date >= p_new_start_date
        AND    resource_effective_end_date   <= p_new_end_date
	   ;

    -- CURSOR to check whether it is a Multi or Single Org Implementation
--MOAC Changes : Bug 4363092: Get the value of current org from PA_MOAC_UTILS.GET_CURRENT_ORG_ID
/*    CURSOR check_org_type IS
            select decode(substr(USERENV('CLIENT_INFO'),1,1),
                          ' ', NULL,
                          substr(USERENV('CLIENT_INFO'),1,10)) org from dual;  */

 BEGIN

       --dbms_output.put_line('Inside Update Org');

       -- Initialize the Error stack
       PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.Update_Org');

       X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

       /* Check if new organization belongs to an expenditure
          organization, if yes then get default ou for old and new organization
          and update pa_resource_ou.organization.*/

       IF (Belongs_ExpOrg(p_new_org_id) = 'Y') THEN

          -- If the old org Id does not belong to exp hier,
          -- we have to fix data in resource denorm (we end dated that
          -- record previously when the org changes from Exp Hier
          -- to Non Exp Hier). So calling Create_Resource
          IF(Belongs_ExpOrg(p_old_org_id) = 'N') THEN

            pa_r_project_resources_pub.create_resource (
                      p_api_version        => 1.0
                     ,p_init_msg_list      => NULL
                     ,p_commit             => FND_API.G_FALSE
                     ,p_validate_only      => NULL
                     ,p_max_msg_count      => NULL
                     ,p_internal           => 'Y'
                     ,p_person_id          => p_person_id
                     ,p_individual         => 'Y'
                     ,p_resource_type      => NULL
                     ,x_return_status      => l_return_status
                     ,x_msg_count          => x_msg_count
                     ,x_msg_data           => x_msg_data
                     ,x_resource_id        => l_resource_id);


            -- call this procedure to update the forecast data for
            -- assigned time ONLY for this resource
            -- pass null to start date and end date
            -- this is called only if create_resource is a success
            if (l_return_status = 'S' and l_resource_id is not null) then
                 PA_FORECASTITEM_PVT.Create_Forecast_Item(
                    p_person_id      => p_person_id
                   ,p_start_date     => null
                   ,p_end_date       => null
                   ,p_process_mode   => 'GENERATE_ASGMT'
                   ,x_return_status  => l_return_status
                   ,x_msg_count      => x_msg_count
                   ,x_msg_data       => x_msg_data
                ) ;
            end if;

          ELSE

            l_default_ou_old := Get_DefaultOU(p_old_org_id);
	    l_default_ou_new := Get_DefaultOU(p_new_org_id);

            IF (l_default_ou_new = -999) THEN
/* Bug 4363092: Commenting this check as R12 will be multi org only */
--                OPEN check_org_type;
--                FETCH check_org_type into l_org_type;
--                CLOSE check_org_type;

                -- case for Multi-Org: no OU - so set return status
                -- to error and return
--                IF l_org_type IS NOT NULL THEN
                     PA_UTILS.Add_Message(
                                  p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_RS_DEF_OU_NULL');

                     x_msg_data := 'PA_RS_DEF_OU_NULL';
                     X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
                     RETURN;
--                ELSE
--                   l_default_ou_new := NULL;
--                END IF;

	    END IF;

	    --Set the values for the Resources Denorm Record Type
	    l_resource_rec_old.person_id := p_person_id;
	    l_resource_rec_new.person_id := p_person_id;

            l_resource_rec_old.resource_org_id := l_default_ou_old;
	    l_resource_rec_new.resource_org_id := l_default_ou_new;

	    l_resource_rec_old.resource_organization_id := p_old_org_id;
	    l_resource_rec_new.resource_organization_id := p_new_org_id;

            FOR rec IN res_denorm_recs LOOP

                 l_resource_rec_old.resource_effective_start_date := rec.resource_effective_start_date;
                 l_resource_rec_new.resource_effective_start_date := rec.resource_effective_start_date;

		 l_resource_rec_old.resource_effective_end_date :=  rec.resource_effective_end_date;
	         l_resource_rec_new.resource_effective_end_date :=  rec.resource_effective_end_date;

        	 --Call Resource Denorm API
	         PA_RESOURCE_PVT.update_resource_denorm(
                     p_resource_denorm_old_rec   => l_resource_rec_old
            	     ,p_resource_denorm_new_rec  => l_resource_rec_new
            	     ,x_return_status            => l_return_status
            	     ,x_msg_data                 => x_msg_data
            	     ,x_msg_count                => x_msg_count);

	         IF l_return_status  = FND_API.G_RET_STS_ERROR THEN
		       x_return_status := FND_API.G_RET_STS_ERROR ;
                 END IF;

             END LOOP; --end FOR

--Bug 7690398 put an if condition for the resource id
	IF (pa_resource_utils.get_resource_id(p_person_id) <> -999) THEN
             --Call Forecast Item regeneration API
             PA_FORECASTITEM_PVT.Create_Forecast_Item(
                  p_person_id      => p_person_id,
                  p_start_date     => p_new_start_date,
                  p_end_date	   => p_new_end_date,
                  p_process_mode   => 'GENERATE',
                  x_return_status  => l_return_status,
                  x_msg_count	   => x_msg_count,
                  x_msg_data	   => x_msg_data) ;

          END IF;

          IF l_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
              x_return_status := FND_API.G_RET_STS_ERROR ;
          END IF;
    END IF; -- Bug 7690398
       ELSE
    	  /* In case the organization does not belong to expenditure
             hierarchy the record in pa_resource_denorm must be end dated*/

            Update_EndDate(
                    p_person_id      => p_person_id,
                    p_old_start_date => p_old_start_date,
         	    p_new_start_date => p_new_start_date,
                    p_old_end_date   => p_old_end_date,
                    p_new_end_date   => sysdate,
                    x_return_status  => l_return_status,
                    x_msg_data       => x_msg_data,
                    x_msg_count      => x_msg_count);

            IF l_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
          	x_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;

       END IF;


       -- reset the Error stack
       PA_DEBUG.Reset_Err_Stack;

 EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  X_RETURN_STATUS := fnd_api.g_ret_sts_error;

        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.Update_Org'
          	,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;
 END Update_Org;

-- Start Bug : 4656855
/* Function check_pjr_default_ou checks if org_id in pa_all_organizations = the PJR default operating unit */
 FUNCTION check_pjr_default_ou(P_Organization_id IN Hr_Organization_Information.Organization_id%type, P_Default_OU_new IN Hr_Organization_Information.Org_Information1%type)
 RETURN VARCHAR2 IS
	-- This function returns 'Y'  if org_id in pa_all_organizations = the PJR default operating unit
        -- otherwise , it returns 'N'

        CURSOR c_check_pjr_default_ou IS
        SELECT 'Y' FROM dual WHERE exists
         (SELECT 'Y' FROM hr_organization_information
                     WHERE organization_id = P_Organization_id
                     and org_information_context = 'Exp Organization Defaults'
                     and org_information1 = P_Default_OU_new);

        l_dummy  VARCHAR2(1);
 BEGIN
	OPEN c_check_pjr_default_ou;
        FETCH c_check_pjr_default_ou INTO l_dummy;

	IF c_check_pjr_default_ou%NOTFOUND THEN
             CLOSE c_check_pjr_default_ou; -- Bug 5336837
             RETURN 'N';
        ELSE
           CLOSE c_check_pjr_default_ou; -- Bug 5336837
           RETURN 'Y';
        END IF;

        -- CLOSE c_check_pjr_default_ou; -- Bug 5336837
 EXCEPTION
        WHEN OTHERS THEN
	  -- Bug 5336837
	  IF c_check_pjr_default_ou%ISOPEN THEN
	    CLOSE c_check_pjr_default_ou ;
	  END IF;

	  return 'N';
 END check_pjr_default_ou;
-- End Bug : 4656855

/* Function Belongs_ExpOrg checks if the given organization belongs to
an expenditure/event organization
*/
 FUNCTION Belongs_ExpOrg(p_org_id IN per_all_assignments_f.organization_id%TYPE)
 RETURN VARCHAR2 IS
	-- This function returns 'Y'  if a given org is a Exp organization ,
        -- otherwise , it returns 'N'

        CURSOR c_exp_org IS
        SELECT 'x'
	FROM dual
	WHERE exists
		(select organization_id
	        FROM pa_all_organizations
	        WHERE organization_id = p_org_id
	        AND inactive_date is null
		AND pa_org_use_type = 'EXPENDITURES');

        l_dummy  VARCHAR2(1);
 BEGIN
	OPEN c_exp_org;
        FETCH c_exp_org INTO l_dummy;

	IF c_exp_org%NOTFOUND THEN
           CLOSE c_exp_org; -- Bug 5336837
           RETURN 'N';
        ELSE
           CLOSE c_exp_org; -- Bug 5336837
           RETURN 'Y';
        END IF;

        -- CLOSE c_exp_org;   -- Bug 5336837
 EXCEPTION
        WHEN OTHERS THEN
	  -- Bug 5336837
	  IF c_exp_org%ISOPEN THEN
	    CLOSE c_exp_org ;
	  END IF;

	  return 'N';
 END Belongs_ExpOrg;

/* Function Get_DefaultOU returns the default OU for the given organization.
*/
 FUNCTION Get_DefaultOU(p_org_id IN per_all_assignments_f.organization_id%TYPE)
 RETURN NUMBER IS
	l_default_ou number;
 BEGIN
	select to_number(org_information1)
	into l_default_ou
	from hr_organization_information
	where organization_id = p_org_id
	and org_information_context = 'Exp Organization Defaults';

        if l_default_ou is null then
           l_default_ou := -999;
        end if;

	return l_default_ou;
 EXCEPTION
        WHEN OTHERS THEN
	  return -999;
 END Get_DefaultOU;

 /*
   Procedure Update_Job retrieves the job level for the job and calls
   Update_Resource_Denorm and Create_Forecast_Item to update the denorm
   table and regenerate forecast items for the resource respectively.
 */
 PROCEDURE Update_Job(
    p_person_id          IN   per_all_people_f.person_id%TYPE,
    p_old_job            IN   per_all_assignments_f.job_id%TYPE,
    p_new_job            IN   per_all_assignments_f.job_id%TYPE,
    p_new_start_date     IN   per_all_assignments_f.effective_start_date%TYPE,
    p_new_end_date       IN   per_all_assignments_f.effective_end_date%TYPE,
    x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_data           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count	     OUT  NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

    l_resource_rec_old     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
    l_resource_rec_new     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
    l_return_status        VARCHAR2(1);
    l_resource_id          NUMBER;
    l_resource_start_date  DATE;
    l_resource_end_date    DATE;
    l_old_job_group_id     per_job_groups.job_group_id%type;
    l_new_job_group_id     per_job_groups.job_group_id%type;
    l_old_job_level        NUMBER;
    l_new_job_level        NUMBER;
    l_old_job_billable     pa_resources_denorm.billable_flag%type;
    l_new_job_billable     pa_resources_denorm.billable_flag%type;
    l_old_job_utilizable   pa_resources_denorm.utilization_flag%type;
    l_new_job_utilizable   pa_resources_denorm.utilization_flag%type;
    l_old_job_schedulable  pa_resources_denorm.schedulable_flag%type;
    l_new_job_schedulable  pa_resources_denorm.schedulable_flag%type;
    P_DEBUG_MODE VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

    -- Cursor to get all denormalized resource records
    --  for this HR assignment
    CURSOR res_denorm_recs IS
    SELECT resource_effective_start_date,
           resource_effective_end_date
      FROM pa_resources_denorm
     WHERE person_id = p_person_id
       AND resource_effective_start_date >= p_new_start_date
       AND resource_effective_end_date   <= p_new_end_date;
    --Bug 9047714 Start
    /*CURSOR min_max_res_dates IS
    SELECT min(resource_effective_start_date) resource_effective_start_date,
           max(resource_effective_end_date) resource_effective_end_date
      FROM pa_resources_denorm
     WHERE job_id = p_old_job
       AND person_id = p_person_id
  GROUP BY person_id;*/
  CURSOR min_max_res_dates IS
    SELECT min(resource_effective_start_date) resource_effective_start_date,
           max(resource_effective_end_date) resource_effective_end_date
      FROM pa_resources_denorm
      WHERE job_id = p_old_job
      AND person_id = p_person_id
      AND resource_effective_end_date = (Select max(resource_effective_end_date)
                                           from pa_resources_denorm rd2
                                           where rd2.job_id = p_old_job
                                           AND rd2.person_id = p_person_id
                                           AND (rd2.resource_effective_end_date >= sysdate OR rd2.resource_effective_end_date is null))
    GROUP BY person_id;
    --Bug 9047714 End

 BEGIN
    -- Initialize the Error stack
    PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.Update_Job');
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('beginning of Update_Job');
    END IF;

    --Get the job group id for the old and new job
    l_old_job_group_id := get_job_group_id(p_old_job);
    l_new_job_group_id := get_job_group_id(p_new_job);

    --Get the old/new job level and job flags
    l_old_job_level := get_job_level(P_job_id	=> p_old_job,
      				     P_job_group_id	=> l_old_job_group_id);
    l_new_job_level := get_job_level(P_job_id	=> p_new_job,
  			             P_job_group_id	=> l_new_job_group_id);
    l_old_job_billable := check_job_billability(P_job_id => p_old_job,
		 	  	                P_person_id => NULL,
				                p_date  =>  NULL );
    l_new_job_billable := check_job_billability(P_job_id => p_new_job,
				                P_person_id => NULL,
				                p_date  => NULL );
    l_old_job_utilizable := check_job_utilization(P_job_id    => p_old_job,
				                  P_person_id => NULL,
				                  p_date      => NULL );
    l_new_job_utilizable := check_job_utilization(P_job_id    => p_new_job,
				                  P_person_id => NULL,
				                  p_date      => NULL );
    l_old_job_schedulable := check_job_schedulable(P_job_id => p_old_job);
    l_new_job_schedulable := check_job_schedulable(P_job_id => p_new_job);

    ------------------------------------------------------------------
    -- If old job's util_flag=N and new job's util_flag=Y, we need to
    -- pull the person.
    ------------------------------------------------------------------
    IF l_old_job_utilizable='N' AND l_new_job_utilizable='Y' THEN
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('pull the person_Id = ' || p_person_id);
       END IF;

       PA_R_PROJECT_RESOURCES_PUB.CREATE_RESOURCE (
                    p_api_version   => 1.0
                   ,p_commit        => FND_API.G_FALSE
                   ,p_validate_only => FND_API.G_FALSE
                   ,p_internal      => 'Y'
                   ,p_person_id     => p_person_id
                   ,p_individual    => 'Y'
                   ,p_resource_type => 'EMPLOYEE'
                   ,x_resource_id   => l_resource_id
                   ,x_return_status => x_return_status
                   ,x_msg_count     => x_msg_count
                   ,x_msg_data      => x_msg_data );

    ------------------------------------------------------------------
    -- If old util_flag=Y and new_util_flag=N, end date the resource
    ------------------------------------------------------------------
    ELSIF l_old_job_utilizable='Y' AND l_new_job_utilizable='N' THEN
       OPEN min_max_res_dates;
       FETCH min_max_res_dates INTO l_resource_start_date, l_resource_end_date;
       CLOSE min_max_res_dates;

       IF P_DEBUG_MODE = 'Y' THEN
          log_message('person Id = ' || p_person_id ||' ,start_date: ' ||
                   l_resource_start_date || ', end_date: '||l_resource_end_date );
       END IF;

       Update_EndDate
                   (p_person_id            => p_person_id,
                    p_old_start_date       => l_resource_start_date,
                    p_new_start_date       => l_resource_start_date,
                    p_old_end_date         => l_resource_end_date,
                    p_new_end_date         => sysdate,
                    x_return_status        => x_return_status,
                    x_msg_count            => x_msg_count,
                    x_msg_data             => x_msg_data);

       IF P_DEBUG_MODE = 'Y' THEN
          log_message('Return status from Update_EndDate = ' || x_return_status);
       END IF;

    ------------------------------------------------------------------
    -- If old util_flag=new util_flag, just update job flags
    ------------------------------------------------------------------
    ELSE
       --Set the values for the Resources Denorm Record Type
       l_resource_rec_old.person_id          := p_person_id;
       l_resource_rec_new.person_id          := p_person_id;
       l_resource_rec_old.job_id             := p_old_job;
       l_resource_rec_new.job_id             := p_new_job;
       l_resource_rec_old.resource_job_level := l_old_job_level;
       l_resource_rec_new.resource_job_level := l_new_job_level;
       l_resource_rec_old.billable_flag      := l_old_job_billable;
       l_resource_rec_new.billable_flag      := l_new_job_billable;
       l_resource_rec_old.utilization_flag   := l_old_job_utilizable;
       l_resource_rec_new.utilization_flag   := l_new_job_utilizable;
       l_resource_rec_old.schedulable_flag   := l_old_job_schedulable;
       l_resource_rec_new.schedulable_flag   := l_new_job_schedulable;

       -- loop through all record of the person in pa_resources_denorm and update
       -- the job flags
       FOR rec IN res_denorm_recs LOOP
    	  l_resource_rec_new.resource_effective_start_date := rec.resource_effective_start_date;
	  l_resource_rec_new.resource_effective_end_date   := rec.resource_effective_end_date;
          IF P_DEBUG_MODE = 'Y' THEN
             log_message('start_date:'||rec.resource_effective_start_date||', end_Date:'||
                      rec.resource_effective_end_date);
          END IF;

	  PA_RESOURCE_PVT.update_resource_denorm(
	     p_resource_denorm_old_rec  => l_resource_rec_old
            ,p_resource_denorm_new_rec  => l_resource_rec_new
            ,x_return_status            => l_return_status
            ,x_msg_data                 => x_msg_data
            ,x_msg_count                => x_msg_count);

	  IF l_return_status  = FND_API.G_RET_STS_ERROR THEN
 	     x_return_status := FND_API.G_RET_STS_ERROR ;
    	  END IF;
       END LOOP;

    END IF;

    IF P_DEBUG_MODE = 'Y' THEN
       log_message('before calling Create_Forecast_Item');
    END IF;
    --Call Forecast Item regeneration API
	--Bug 7690398 put an if condition for the resource id
	IF (pa_resource_utils.get_resource_id(p_person_id) <> -999) THEN
    PA_FORECASTITEM_PVT.Create_Forecast_Item(
		p_person_id	    => p_person_id,
                p_start_date	    => p_new_start_date,
                p_end_date	    => p_new_end_date,
                p_process_mode	    => 'GENERATE',
                x_return_status     => l_return_status,
                x_msg_count	    => x_msg_count,
                x_msg_data	    => x_msg_data) ;

    IF P_DEBUG_MODE = 'Y' THEN
       log_message('after calling Create_Forecast_Item, l_return_status:'||l_return_status);
    END IF;
    IF l_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF;
 END IF; --Bug 7690398
    -- reset the Error stack
    PA_DEBUG.Reset_Err_Stack;

 EXCEPTION
    WHEN OTHERS THEN
        IF P_DEBUG_MODE = 'Y' THEN
           log_message('exception was thrown');
        END IF;
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
    	-- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.Update_Job'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
 END Update_Job;

/* Procedure Update_Supervisor calls Update_Resource_Denorm to update
the resource's supervisor in the denorm table.
*/
PROCEDURE Update_Supervisor(
	p_person_id          IN per_all_people_f.person_id%TYPE,
	p_old_supervisor     IN per_all_assignments_f.supervisor_id%TYPE,
	p_new_supervisor     IN per_all_assignments_f.supervisor_id%TYPE,
	p_new_start_date     IN per_all_assignments_f.effective_start_date%TYPE,
    p_new_end_date       IN per_all_assignments_f.effective_end_date%TYPE,
	x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_data           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count	         OUT  NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

	l_resource_rec_old     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
    l_resource_rec_new     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;

	l_return_status        VARCHAR2(1);
    l_manager_name             pa_resources_denorm.manager_name%TYPE;

    CURSOR res_denorm_recs IS
	    SELECT resource_effective_start_date,
               resource_effective_end_date
        FROM   pa_resources_denorm
        WHERE  person_id = p_person_id
        AND    p_new_end_date >= resource_effective_start_date
        AND    resource_effective_start_date >= p_new_start_date
        AND    resource_effective_end_date   <= p_new_end_date
	;

    CURSOR manager_name IS
    	SELECT DISTINCT resource_name
    	FROM pa_resources_denorm
	    WHERE person_id = p_new_supervisor
    ;

 BEGIN

    -- Initialize the Error stack
    PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.Update_Supervisor');
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    --Set the values for the Resources Denorm Record Type
    l_resource_rec_old.person_id := p_person_id;
    l_resource_rec_new.person_id := p_person_id;

    l_resource_rec_old.manager_id := p_old_supervisor;
    l_resource_rec_new.manager_id := p_new_supervisor;

    OPEN manager_name;
    FETCH manager_name INTO l_manager_name;
    l_resource_rec_new.manager_name := l_manager_name;
    CLOSE manager_name;

    FOR rec IN res_denorm_recs LOOP

    	l_resource_rec_new.resource_effective_start_date := rec.resource_effective_start_date;

        --Call Resource Denorm API
        PA_RESOURCE_PVT.update_resource_denorm(
             p_resource_denorm_old_rec  => l_resource_rec_old
            ,p_resource_denorm_new_rec  => l_resource_rec_new
            ,x_return_status            => l_return_status
            ,x_msg_data                 => x_msg_data
            ,x_msg_count                => x_msg_count);

        IF l_return_status  = FND_API.G_RET_STS_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;

    END LOOP;--end FOR

    -- reset the Error stack
    PA_DEBUG.Reset_Err_Stack;

 EXCEPTION
    WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.Update_Supervisor'
          ,p_procedure_name => PA_DEBUG.G_Err_Stack );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    raise;
 END Update_Supervisor;

/* Procedure Update_PrimaryFlag calls Update_EndDate to end date the
record for which the assignment record's primary flag has changed form
yes to no and then calls Create_Forecast_Item to regenerate
the forecast items for this resource.
*/
 PROCEDURE Update_PrimaryFlag(
	p_person_id          IN per_all_people_f.person_id%TYPE,
	p_old_start_date     IN per_all_assignments_f.effective_start_date%TYPE,
	p_new_start_date     IN per_all_assignments_f.effective_end_date%TYPE,
	p_old_end_date       IN per_all_assignments_f.effective_start_date%TYPE,
	p_new_end_date       IN per_all_assignments_f.effective_end_date%TYPE,
	x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_data           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_count	     OUT  NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

	l_return_status        VARCHAR2(1);

 BEGIN
	 -- Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.Update_PrimaryFlag');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

	--Call Update_EndDate to end date the resource_ou record.
        -- Commented the end date change in PA as this is not required
        -- Solves bug 1608837
/*	Update_EndDate(p_person_id => p_person_id,
		p_old_start_date => p_old_start_date,
		p_new_start_date => p_new_start_date,
		p_old_end_date => p_old_end_date,
		p_new_end_date => p_new_end_date,
		x_return_status => x_return_status,
	        x_msg_data      => x_msg_data,
	        x_msg_count	=> x_msg_count);
*/

        --Call Forecast Item regeneration API
	PA_FORECASTITEM_PVT.Create_Forecast_Item(
		p_person_id	=> p_person_id,
                p_start_date	=> p_new_start_date,
                p_end_date	=> p_new_end_date,
                p_process_mode	=> 'GENERATE',
                x_return_status => l_return_status,
                x_msg_count	=> x_msg_count,
                x_msg_data	=> x_msg_data) ;

	IF l_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
	     x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;

	-- reset the Error stack
        PA_DEBUG.Reset_Err_Stack;

 EXCEPTION
        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.Update_PrimaryFlag'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;
 END Update_PrimaryFlag;

/* Procedure Update_Name calls updates the resource's name in pa_resources.
*/
 PROCEDURE Update_Name(
    p_person_id     IN  per_all_people_f.person_id%TYPE,
    p_old_name	     IN  per_all_people_f.full_name%TYPE,
    p_new_name	     IN  per_all_people_f.full_name%TYPE,
    x_return_status OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_data      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count	    OUT  NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

    l_resource_id	     pa_resources.resource_id%TYPE;
    l_return_status      VARCHAR2(1);

    l_resource_rec_old     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
    l_resource_rec_new     PA_RESOURCE_PVT.Resource_Denorm_Rec_Type;
 BEGIN

	--Initialize the Error stack
        PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.Update_Name');
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

	--Get resource_id for person_id
	l_resource_id := pa_resource_utils.get_resource_id(p_person_id);

	IF (l_resource_id = -999) THEN
           X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
           return;
        END IF;

	UPDATE pa_resources
	SET name = p_new_name
	WHERE resource_id = l_resource_id;

	--Set the values for the Resources Denorm Record Type
	l_resource_rec_old.person_id := p_person_id;
	l_resource_rec_new.person_id := p_person_id;

	l_resource_rec_old.resource_name := p_old_name;
	l_resource_rec_new.resource_name := p_new_name;

	--Call Resource Denorm API
	PA_RESOURCE_PVT.update_resource_denorm(
		              p_resource_denorm_old_rec   => l_resource_rec_old
                ,p_resource_denorm_new_rec  => l_resource_rec_new
                ,x_return_status            => l_return_status
                ,x_msg_data                 => x_msg_data
                ,x_msg_count                => x_msg_count);

	IF l_return_status  = FND_API.G_RET_STS_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;

	--Reset the Error stack
        PA_DEBUG.Reset_Err_Stack;

 EXCEPTION
        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.Update_Name'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;
 END Update_Name;



-- Procedure Address_Change  Modified for location denormalization
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
                           x_msg_data                  out NOCOPY varchar2) IS --File.Sql.39 bug 4440895

	l_return_status         VARCHAR2(1);
	l_resource_id           NUMBER;

BEGIN


    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_addr_prim_flag_new = 'Y' THEN

     --dbms_output.put_line('Inside address Update for person id:' || p_person_id);

     	pa_r_project_resources_pub.create_resource (
             p_api_version        => 1.0
            ,p_init_msg_list      => NULL
            ,p_commit             => FND_API.G_FALSE
            ,p_validate_only      => NULL
            ,p_max_msg_count      => NULL
            ,p_internal           => 'Y'
            ,p_person_id          => p_person_id
            ,p_individual         => 'Y'
            ,p_resource_type      => 'EMPLOYEE'
            ,x_return_status      => l_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
            ,x_resource_id        => l_resource_id);

    END IF;

    --dbms_output.put_line('After address Update');

    IF l_return_status  = FND_API.G_RET_STS_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF;

EXCEPTION
   when others then
      NULL;
      raise;

END address_change;

FUNCTION Get_Country_name(p_country_code    VARCHAR2) RETURN VARCHAR2 IS

  l_country_code     VARCHAR2(240);

BEGIN

    SELECT territory_short_name
      INTO l_country_code
      FROM fnd_territories_vl
     WHERE territory_code = p_country_code ;

     RETURN l_country_code ;
EXCEPTION

   WHEN NO_DATA_FOUND THEN
       RETURN NULL;

   WHEN OTHERS THEN

      RAISE ;

END ;

FUNCTION get_job_name(P_job_id  IN   per_jobs.job_id%type)
RETURN per_jobs.name%type IS

  l_job_name     varchar2(240);

BEGIN

      SELECT name
        INTO l_job_name
        FROM per_jobs
       WHERE job_id = P_job_id;

      RETURN (l_job_name) ;
EXCEPTION

   WHEN NO_DATA_FOUND THEN
       RETURN NULL;

  WHEN OTHERS THEN

    RAISE ;

END ;

FUNCTION get_org_name(P_org_id  IN   hr_all_organization_units.organization_id%type)
RETURN hr_all_organization_units.name%type IS
  l_org_name     varchar2(240);

BEGIN

      SELECT name
        INTO l_org_name
        FROM hr_all_organization_units_tl
       WHERE organization_id = P_org_id
         AND language = USERENV('LANG');

      RETURN (l_org_name) ;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
       RETURN NULL;

  WHEN OTHERS THEN
    RAISE ;
END ;

FUNCTION get_grade_name(P_grade_id IN   NUMBER)
RETURN VARCHAR2 IS
  l_grade_name     varchar2(240);

BEGIN
      SELECT name
        INTO l_grade_name
        FROM per_grades
       WHERE grade_id = P_grade_id;

      RETURN (l_grade_name) ;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
       RETURN NULL;

  WHEN OTHERS THEN
    RAISE ;
END ;

-- Added for bug 3957522
-- Procedure to delete records in pa_resources_denorm
PROCEDURE Delete_PA_Resource_Denorm(
    p_person_id          IN   per_all_people_f.person_id%TYPE,
    p_old_start_date     IN   per_all_assignments_f.effective_start_date%TYPE,
    p_old_end_date       IN   per_all_assignments_f.effective_end_date%TYPE,
    x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_data           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count	         OUT  NOCOPY NUMBER) IS --File.Sql.39 bug 4440895


    CURSOR res_denorm_recs IS
	       SELECT resource_effective_start_date,
               resource_effective_end_date
        FROM   pa_resources_denorm
        WHERE  person_id = p_person_id
        AND    resource_effective_start_date >= p_old_start_date
        AND    resource_effective_end_date   <= p_old_end_date
    ;

BEGIN
    -- Initialize the Error stack
    PA_DEBUG.init_err_stack('PA_HR_UPDATE_API.Delete_PA_Resource_Denorm');
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    FOR rec IN res_denorm_recs LOOP
	      --Delete the record
               DELETE FROM PA_RESOURCES_DENORM
                 WHERE person_id = p_person_id
                 AND resource_effective_start_date = rec.resource_effective_start_date;

    END LOOP; --end FOR

    -- reset the Error stack
    PA_DEBUG.Reset_Err_Stack;

 EXCEPTION

	WHEN NO_DATA_FOUND THEN
	  x_return_status := FND_API.G_RET_STS_ERROR ;

        WHEN OTHERS THEN
          -- 4537865 : RESET x_msg_count and x_msg_data also
          x_msg_count := 1 ;
          x_msg_data := SUBSTRB(SQLERRM ,1,240);
          -- Set the exception Message and the stack
          FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_HR_UPDATE_API.Delete_PA_Resource_Denorm'
                                  ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          raise;
 END Delete_PA_Resource_Denorm;

END PA_HR_UPDATE_API;

/
