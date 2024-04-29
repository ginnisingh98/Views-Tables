--------------------------------------------------------
--  DDL for Package Body PA_PURGE_VALIDATE_PJRM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_VALIDATE_PJRM" as
/* $Header: PAXRMVTB.pls 120.2 2005/08/19 17:19:18 mwasowic noship $ */

-- Start of comments
-- API name         : Validate_pjrm
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Validates the project resource management details
--                    and a project is not purged if there exists any
--                    PJRM transactions for a project.
--                    Following validations are performed.
--                    1. If there exists any assignment or requirement.
--                    2. If the project is of unassigned time or
--                       an administrative type.
--
-- Parameters
--		      p_project_Id			IN     NUMBER,
--                              The project id for which records have
--                              to be purged/archived.
--		      p_Active_Flag		        IN     VARCHAR2,
--                              Indicates if batch contains ACTIVE or CLOSED projects
--                              ( 'A' - Active , 'C' - Closed)
--		      p_Txn_To_Date			IN     DATE,
--                              Date on or before which all transactions are to be purged
--                              (Will be used by Costing only)
--		      X_Err_Stack			IN OUT VARCHAR2,
--                              Error stack
--		      X_Err_Stage		        IN OUT VARCHAR2,
--                              Stage in the procedure where error occurred
--		      X_Err_Code		        IN OUT NUMBER
--                              Error code returned from the procedure
--                              = 0 SUCCESS
--                              > 0 Application error
--                              < 0 Oracle error
-- End of comments

 procedure validate_pjrm    ( p_project_id                     in NUMBER,
                              p_txn_to_date                    in DATE,
                              p_active_flag                    in VARCHAR2,
                              x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage                      in OUT NOCOPY VARCHAR2 ) is --File.Sql.39 bug 4440895

  -- Cursor for pjrm validaton before purge
  --
  cursor IsAPJRMProject  is

      select 'Assignment or Requirement Exists' , 'PA_ARPR_ASG_REQ_EXISTS'
      from dual
      where exists ( select NULL
                     from   pa_project_assignments pa
                     where  nvl(pa.project_id, 0) = p_project_id
                    )
      UNION
      select 'Administrative or Unassigned Time Type' , 'PA_ARPR_ADM_UNASS_PRJ_TYP'
      from dual
      where exists ( select    pt.project_type
                     from      pa_project_types_all pt,
                               pa_projects_all p
                      where    p.project_id = p_project_id
                      and      pt.project_type = p.project_type
                      and    ( nvl(pt.administrative_flag, 'N') = 'Y'
                            or nvl(pt.unassigned_time, 'N') = 'Y' ));

      l_err_stack    VARCHAR2(2000);
      l_err_stage    VARCHAR2(500);
      l_err_code     NUMBER ;
      l_dummy        VARCHAR2(500);
      l_msg_name     VARCHAR2(50);

 BEGIN

/*
     l_err_code  := 0 ;
     l_err_stage := x_err_stage;
     l_err_stack := x_err_stack;
     pa_debug.debug('-- Performing pjrm validation for project '||to_char(p_project_id));

     -- Open cursor
     -- If cursor returns one or more rows , indicates that
     -- project is not valid for purge as far as pjrm is concerned
     --

     Open IsAPJRMProject ;

     pa_debug.debug('-- After Open cursor IsAPJRMProject');

     LOOP

     -- Fetch a row for each validation that failed
     -- and set the appropriate message
     --
     Fetch IsAPJRMProject into l_dummy , l_msg_name ;
     Exit When IsAPJRMProject%Notfound;
        fnd_message.set_name('PA',l_msg_name );
        fnd_msg_pub.add;
        x_err_stack  := x_err_stack || ' ->After open cursor ' ||l_dummy ;
        pa_debug.debug('   * '  || l_dummy|| ' for ' || to_char(p_project_id));


     END LOOP;

     close IsAPJRMProject;

     x_err_stage := l_err_stage ;
     x_err_stack := l_err_stack ;

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_VALIDATE_PJRM.VALIDATE_PJRM' );
    pa_debug.debug('Error stage is '||l_err_stage );
    pa_debug.debug('Error stack is '||l_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ; */

NULL;

END validate_pjrm ;


-- Start of comments
-- API name         : Validate_Requirement
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Validates the project resource management details for requirements
--


PROCEDURE  Validate_Requirement( p_project_id                     in NUMBER,
                                 p_txn_to_date                    in DATE,
                                 p_active_flag                    in VARCHAR2,
                                 x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_err_stage                      in OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895


/*Bug 2489778:For closed prject purge, even the requirement exist after project closed date,
the requirement and project can be purged.So this cursoris not valid anymore.

The below cursor will select any open requirement for the passed project id. If the
Cursor return any row, it means that project contains requirements in open status, so
Requirement and project cannot be purged. This curor is applicable in case of Closed
Projects.

  CURSOR CUR_REQUIREMENTS_CLOSED IS
  SELECT 1
  FROM pa_project_assignments pa, pa_project_statuses ps, pa_projects pr
  WHERE pa.assignment_type = 'OPEN_ASSIGNMENT'
  AND pa.status_code = ps.project_status_code
  AND ps.status_type='OPEN_ASGMT'
  AND ps.project_system_status_code ='OPEN_ASGMT'
  AND pa.project_id = P_PROJECT_ID
  AND pa.end_date > nvl(p_txn_to_date,pr.closed_date)
  AND pa.project_id=pr.project_id;

*/

/*The below cursor will select any open requirement for the passed project id which
exist before purge Till Date. If the cursor return any row,it means that project
contains requirements in open status, so Requirement and project cannot be purged.
This cursor is applicable for Open Indirect Project Purge.*/

   CURSOR CUR_REQUIREMENTS_ACTIVE IS
   SELECT 1
   FROM pa_project_assignments pa, pa_project_statuses ps
   WHERE pa.assignment_type = 'OPEN_ASSIGNMENT'
   AND pa.status_code = ps.project_status_code
   AND ps.status_type='OPEN_ASGMT'
   AND ps.project_system_status_code ='OPEN_ASGMT'
   AND pa.project_id = P_PROJECT_ID
   AND p_active_flag = 'A'
   AND pa.end_date <= P_txn_to_date;


   l_err_stack    VARCHAR2(2000);
   l_err_stage    VARCHAR2(500);
   l_err_code     NUMBER ;
   l_dummy        NUMBER;
   l_msg_name     VARCHAR2(50);

BEGIN

   l_err_code  := 0 ;
   l_err_stage := x_err_stage;
   l_err_stack := x_err_stack;
   pa_debug.debug('Performing Requirement validation for project '||to_char(p_project_id));


/* Indirect project purge validations */

   IF p_active_flag ='A' THEN
      pa_debug.debug('Opening cursor for Open Indirect Project purge ');

      OPEN CUR_REQUIREMENTS_ACTIVE;
      FETCH CUR_REQUIREMENTS_ACTIVE INTO l_dummy;

      IF CUR_REQUIREMENTS_ACTIVE%FOUND THEN
          fnd_message.set_name('PA', 'PA_ARPR_OPEN_REQ_EXIST');
          fnd_msg_pub.add;
          l_err_code   :=  10 ;

          l_err_stage := 'After checking for Requirements for Open Indirect Project';
          l_err_stack := l_err_stack ||
                       ' ->After checking for Requirements for Open Indirect Project';
          pa_debug.debug(' The project '||to_char(p_project_id)|| 'has Requirements in open status before purge date');

      END IF;
      CLOSE CUR_REQUIREMENTS_ACTIVE;

/* Code commented for bug 2489778
  ELSE
      pa_debug.debug('Opening cursor for Closed Project purge ');

      OPEN CUR_REQUIREMENTS_CLOSED;
      FETCH CUR_REQUIREMENTS_CLOSED INTO l_dummy;

      IF CUR_REQUIREMENTS_CLOSED%FOUND THEN
          fnd_message.set_name('PA', 'PA_ARPR_CLOSED_REQ_EXIST');
          fnd_msg_pub.add;
          l_err_code   :=  10 ;
          l_err_stage := 'After checking for Requirements for Closed  Project';
          l_err_stack := l_err_stack ||
                       ' ->After checking for Requirements for Closed Project';
          pa_debug.debug(' The project '||to_char(p_project_id)|| 'has Requirements in Open Status ');

      END IF;
      CLOSE CUR_REQUIREMENTS_CLOSED;
*/

  END IF;

   x_err_code  := l_err_code ;
   x_err_stage := l_err_stage ;
   x_err_stack := l_err_stack ;

EXCEPTION
  WHEN OTHERS THEN
    x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_VALIDATE_COSTING.VALIDATE_COSTING' );
    pa_debug.debug('Error stage is '||l_err_stage );
    pa_debug.debug('Error stack is '||l_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;


END Validate_Requirement;


-- Start of comments
-- API name         : Validate_Assignments
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Validates the project resource management details for requirements
--                    The proceduire do following validations
--                    1.In case of closed project purge,if there exist any assignment whose end date
--                      is greater than project closed date,then pjr assignment and project will not be purged.
--                      In above validation, the procedure will return error message if validation fails.
--
--

PROCEDURE  Validate_assignment ( p_project_id                     in NUMBER,
                                 p_txn_to_date                    in DATE,
                                 p_active_flag                    in VARCHAR2,
                                 x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_err_stage                      in OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895


/*This cursor will select any assignments for project passed (closed Project)
  Which is having assignment end date greater than Purge Till Date and NOT cancelled.
  This is required, as even there exist any assignment with cancelled status with end
  Date Greater than purge till date, the assignment can be purged.
  Also, as p_txn_to_date will be NULL in case of closed project purge, the assignment
  Dates are compared with project Closed Date*/

    CURSOR CUR_ASSIGNMENTS IS
    SELECT 1
    FROM  Pa_project_assignments pa
	, pa_project_statuses ps
	, pa_projects pr
   WHERE pa.project_id = P_Project_Id
   AND pa.assignment_type <>'OPEN_ASSIGNMENT'
   AND nvl(p_txn_to_date,Pr.CLOSED_DATE) < pa.end_date
   AND pa.status_code = ps.project_status_code
   AND ps.status_type = 'STAFFED_ASGMT'
   AND ps.project_system_status_code <> 'STAFFED_ASGMT_CANCEL'
   AND pr.project_id =pa.project_id;

   l_err_stack    VARCHAR2(2000);
   l_err_stage    VARCHAR2(500);
   l_err_code     NUMBER ;
   l_dummy        NUMBER;
   l_msg_name     VARCHAR2(50);

BEGIN

   l_err_code  := 0 ;
   l_err_stage := x_err_stage;
   l_err_stack := x_err_stack;
   pa_debug.debug('Performing validation whether any active assignment exist for the project '||to_char(p_project_id));

   /* Project purge validations for active assignments */

   IF p_active_flag <> 'A' THEN
      pa_debug.debug('Opening cursor for Active Assignments ');

      OPEN CUR_ASSIGNMENTS;
      FETCH CUR_ASSIGNMENTS INTO  l_dummy;

      IF CUR_ASSIGNMENTS%FOUND THEN
         fnd_message.set_name('PA', 'PA_ARPR_CLOSED_ASGMT_EXIST');
         fnd_msg_pub.add;
         l_err_code   :=  10 ;
         l_err_stage := 'After checking for Assignments for Closed  Project';
         l_err_stack := l_err_stack ||
                       ' ->After checking for Assignments for Closed Project';
         pa_debug.debug(' The project '||to_char(p_project_id)|| 'has assignments either in provisional or confirmed  Status ');
      END IF;
      CLOSE CUR_ASSIGNMENTS;

   END IF;

   x_err_code  := l_err_code ;
   x_err_stage := l_err_stage ;
   x_err_stack := l_err_stack ;

EXCEPTION

  WHEN OTHERS THEN
    x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_VALIDATE_COSTING.VALIDATE_COSTING' );
    pa_debug.debug('Error stage is '||l_err_stage );
    pa_debug.debug('Error stack is '||l_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

END validate_assignment;


/* The below procedure is added for bug 2962582
   Created By: Vinay */

-- Start of comments
-- API name         : Validate_PJI
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Validates the PJI details for the project.
--                    The procedure does the following validations
--                    1. In case PJI is installed and the project has unsummarized transactions, then it returns
--                       error message.
--

-- Parameters
--                    p_project_Id       IN     NUMBER              The project id for which records have
--                                                                  to be purged/archived.
--                    p_project_end_date IN     DATE                End date of the project to be purged.
--
--                    X_Err_Stack      IN OUT   VARCHAR2            Error stack
--
--                    X_Err_Stage      IN OUT   VARCHAR2            Stage in the procedure where error occurred
--
--                    X_Err_Code       IN OUT   NUMBER              Error code returned from the procedure
--                                                                    = 0 SUCCESS
--                                                                    > 0 Application error
--                                                                    < 0 Oracle error
-- End of comments

Procedure Validate_PJI ( p_project_id       IN NUMBER,
                         p_project_end_date IN DATE,
                         x_err_code         IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                         x_err_stack        IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         x_err_stage        IN OUT NOCOPY VARCHAR2 )  --File.Sql.39 bug 4440895
IS

   l_count          NUMBER := -1;
   l_install        VARCHAR2(1);
   l_start_date     DATE;
   l_project_status PA_PROJECTS_ALL.project_status_code%TYPE;
   l_count_fnd      NUMBER := 0;
   l_count_drv      NUMBER := 0;
   l_count_cdl      NUMBER := 0;
   l_count_inv      NUMBER := 0;
   l_count_log      NUMBER := 0;
   l_string         VARCHAR2(1000);

   l_err_stack    VARCHAR2(2000);
   l_err_stage    VARCHAR2(500);
   l_err_code     NUMBER ;

CURSOR chk_funding IS
   SELECT 1
     FROM DUAL
    WHERE EXISTS
            (SELECT NULL
               FROM pa_project_fundings
              WHERE project_id = p_project_id
                AND pji_summarized_flag = 'N');

CURSOR chk_revenue IS
   SELECT 1
     FROM DUAL
    WHERE EXISTS
            (SELECT NULL
               FROM pa_draft_revenues_all
              WHERE project_id = p_project_id
                AND released_date IS NOT NULL
                AND transfer_status_code = 'A'
                AND pji_summarized_flag = 'N');

CURSOR chk_cdl IS
   SELECT 1
     FROM DUAL
    WHERE EXISTS
            (SELECT NULL
               FROM pa_cost_distribution_lines_all
              WHERE project_id = p_project_id
                AND line_type IN ('R', 'I')
                AND pji_summarized_flag = 'N');

CURSOR chk_inv IS
   SELECT 1
     FROM DUAL
    WHERE EXISTS
            (SELECT NULL
               FROM pa_draft_invoices_all
              WHERE project_id = p_project_id
                AND system_reference IS NOT NULL
                AND system_reference <> 0
                AND pji_summarized_flag = 'N');

CURSOR chk_log IS
   SELECT 1
     FROM DUAL
    WHERE EXISTS
            (SELECT NULL
               FROM pa_pji_proj_events_log
              WHERE event_type in ('Projects', 'Classifications', 'DRAFT_REVENUES')
	      and event_object =  p_project_id); /* Added this condition for bug 3807671 */

BEGIN

   l_err_code  := 0 ;
   l_err_stage := x_err_stage;
   l_err_stack := x_err_stack;
   pa_debug.debug('Performing validation whether any unsummarized PJI transaction exists for project '||to_char(p_project_id));

   l_install := PA_INSTALL.is_pji_licensed;
   IF l_install = 'Y' THEN
   -- Begin. Added for bug 3130009.
      l_install := '';
      l_install := PA_INSTALL.is_pji_installed;
      IF l_install = 'Y' THEN
         l_string := 'SELECT COUNT(*) FROM pji_system_parameters';
         EXECUTE IMMEDIATE l_string INTO l_count;
      ELSE
         RETURN;
      END IF;
   -- End. Added for bug 3130009.
   ELSE
      RETURN;
   END IF;

   IF l_count > 1 THEN
      l_string := 'SELECT BIS_COMMON_PARAMETERS.get_global_start_date FROM DUAL';
      EXECUTE IMMEDIATE l_string INTO l_start_date;

      SELECT project_status_code
        INTO l_project_status
        FROM pa_projects_all
       WHERE project_id = p_project_id;

      IF nvl(p_project_end_date, l_start_date ) >= l_start_date
         AND PA_PROJECT_UTILS.check_prj_stus_action_allowed(l_project_status, 'STATUS_REPORTING') = 'Y' THEN

         OPEN chk_funding;
         FETCH chk_funding INTO l_count_fnd;
         CLOSE chk_funding;

         OPEN chk_revenue;
         FETCH chk_revenue INTO l_count_drv;
         CLOSE chk_revenue;

         OPEN chk_cdl;
         FETCH chk_cdl INTO l_count_cdl;
         CLOSE chk_cdl;

         OPEN chk_inv;
         FETCH chk_inv INTO l_count_inv;
         CLOSE chk_inv;

         OPEN chk_log;
         FETCH chk_log INTO l_count_log;
         CLOSE chk_log;

         IF nvl(l_count_fnd, 0) = 1 OR nvl(l_count_drv, 0) = 1
           OR nvl(l_count_cdl, 0) = 1 OR nvl(l_count_inv, 0) = 1
           OR nvl(l_count_log, 0) = 1 THEN

            fnd_message.set_name('PA', 'PA_PJI_UNSUMMARIZED_EXIST');
            fnd_msg_pub.add;
            l_err_code  := 10;
            l_err_stage := 'After checking for PJI details the Project';
            l_err_stack := l_err_stack ||
                        ' ->After checking for PJI details for the Project';
            pa_debug.debug(' The project '||to_char(p_project_id)|| 'has transactions that are not summarized by PJI module.');
         END IF;

      END IF;

   END IF;

END Validate_PJI;


/*bug 4255353*/
Procedure Validate_Perf_reporting  ( p_project_id       IN NUMBER,
                                     x_err_code         IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_err_stack        IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_err_stage        IN OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
cursor chk_pji_migrated IS
   SELECT 1 from dual
      where exists (select 1
                    from   pa_projects_all
                    where  project_id=p_project_id
                    and    pji_source_flag='Y');
 l_count_migrated NUMBER :=0;
    l_err_stack    VARCHAR2(2000);
   l_err_stage    VARCHAR2(500);
   l_err_code     NUMBER ;
BEGIN
l_err_code  := 0 ;
   l_err_stage := x_err_stage;
   l_err_stack := x_err_stack;
          OPEN chk_pji_migrated;
      FETCH chk_pji_migrated INTO l_count_migrated;
      CLOSE chk_pji_migrated;

      IF  l_count_migrated = 1 AND NVL(pa_purge_validate_pjrm.g_purge_summary_flag,'N')='Y' THEN
         fnd_message.set_name('PA', 'PA_PJI_MIGRATED_PROJECT');
         fnd_msg_pub.add;
         l_err_code := 10;
        l_err_stage:='After checking for Perf Reporting details the Project';
         l_err_stack := l_err_stack ||
          ' ->After checking for Perf Reporting details for the Project';
        pa_debug.debug('The project '||to_char(p_project_id)|| 'has PJI data migrated to the new Summarization Model');

       END IF;
x_err_stack:= l_err_stack;
x_err_code := l_err_code;
x_err_stage := l_err_stage ;
EXCEPTION
 WHEN OTHERS THEN
    x_err_stage := l_err_stage ;
    l_err_stack := l_err_stack ||SUBSTR(SQLERRM,100);
    pa_debug.debug('Error Procedure Name  := pa_purge_validate_pjrm.VALIDATE_perf_reporting' );
    pa_debug.debug('Error stage is '||l_err_stage );
    pa_debug.debug('Error stack is '||l_err_stack );
    pa_debug.debug(SQLERRM);
    x_err_code:=SQLCODE;
    x_err_stack:= l_err_stack;

END Validate_Perf_reporting ;


END ;

/
