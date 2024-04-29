--------------------------------------------------------
--  DDL for Package Body PA_PURGE_PJR_TXNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_PJR_TXNS" AS
/* $Header: PAXPJRPB.pls 120.1 2005/08/19 17:16:54 mwasowic noship $ */
-- Start of comments
-- API name         : PA_REQUIREMENTS_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records related to Requirements for project

Procedure PA_REQUIREMENTS_PURGE ( p_purge_batch_id                 in NUMBER,
                                  p_project_id                     in NUMBER,
                                  p_purge_release                  in VARCHAR2,
                                  p_txn_to_date                    in DATE,
                                  p_archive_flag                   in VARCHAR2,
                                  p_commit_size                    in NUMBER,
                                  x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_err_code                       in OUT NOCOPY NUMBER ) IS --File.Sql.39 bug 4440895




    l_requirement_id_tab     		 PA_PLSQL_DATATYPES.IdTabTyp;
    I                                    PLS_INTEGER;
    l_last_fetch                         VARCHAR2(1):='N';
    l_this_fetch                         NUMBER:=0;
    l_totally_fetched                    NUMBER:=0;

/*This cursor will select all the assignments, which are either cancelled or filled
for Project passed. The other conditions are not checked as in closed project
purge, purging of requirements will start only if all requirements are cancelled
or filled*/

    CURSOR CUR_REQUIREMENTS_CLOSED IS
    SELECT assignment_id
    FROM pa_project_assignments pa WHERE pa.assignment_type = 'OPEN_ASSIGNMENT'
    AND pa.project_id = P_PROJECT_ID;


/*This cursor will select all the assignments, which are either cancelled or filled
for Project passed and whose end dates are before purge till date .This is
applicable for open indirect project purge.*/

    CURSOR CUR_REQUIREMENTS_ACTIVE IS
    SELECT pa.assignment_id
    FROM pa_project_assignments pa, pa_project_statuses ps
    WHERE pa.assignment_type = 'OPEN_ASSIGNMENT'
    AND pa.status_code = ps.project_status_code
    AND ps.status_type='OPEN_ASGMT'
    AND ps.project_system_status_code <> 'OPEN_ASGMT'
    AND pa.project_id = P_PROJECT_ID
    AND pa.end_date <= P_txn_to_date
    AND NOT EXISTS (Select NULL
                   From pa_project_assignments pa1,pa_project_statuses pps
                   where pa1.source_assignment_id=pa.assignment_id
                   AND pa1.end_date >P_txn_to_date
                   AND pa1.status_code = pps.project_status_code
                   AND pps.status_type = 'STAFFED_ASGMT'
                   AND pps.project_system_status_code <> 'STAFFED_ASGMT_CANCEL');

  l_old_err_stack        VARCHAR2(2000); -- Added for bug 4227589

BEGIN

  l_old_err_stack := x_err_stack;  -- Added for bug 4227589
  x_err_stack := x_err_stack || ' ->Before call to purge Requirements ';

  If p_txn_to_date IS NULL THEN

    pa_debug.debug('Purging requirements for Closed project purge');
    x_err_stage := 'About to purge requirements for project '||to_char(p_project_id) ;

    OPEN CUR_REQUIREMENTS_CLOSED;
    LOOP

      	/*Clear PL/SQL table before start */
	l_requirement_id_tab.DELETE;

        FETCH  cur_requirements_closed
        BULK COLLECT
        INTO l_requirement_id_tab LIMIT p_commit_size;

        /*  To check the rows fetched in this fetch */

        l_this_fetch := cur_requirements_closed%ROWCOUNT - l_totally_fetched;
        l_totally_fetched := cur_requirements_closed%ROWCOUNT;

        /*
         *  Check if this fetch has 0 rows returned (ie last fetch was even p_commit_size)
         *  This could happen in 2 cases
         *      1) this fetch is the very first fetch with 0 rows returned
         *   OR 2) the last fetch returned an even p_commit_size  rows
         *  If either then EXIT without any processing
         */
          IF  l_this_fetch = 0 then
              EXIT;
          END IF;

        /*
         *  Check if this fetch is the last fetch
         *  If so then set the flag l_last_fetch so as to exit after processing
         */
          IF  l_this_fetch < p_commit_size  then
              l_last_fetch := 'Y';
          ELSE
              l_last_fetch := 'N';
          END IF;

         /* Call  forecast API to archive/purge data from pa_forecast_items and detail table */

         pa_debug.debug(' About to purge Forecast Items and Forecast Item Details ') ;
         x_err_stage := 'About to purge forecast items for project '||to_char(p_project_id) ;


         pa_purge_pjr_txns.pa_forecast_items_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                    p_project_id         =>p_project_id,
                                                    p_purge_release      =>p_purge_release,
                                                    p_assignment_id_tab  =>l_requirement_id_tab,
                                                    p_archive_flag       =>p_archive_flag,
                                                    x_err_stack          =>x_err_stack,
                                                    x_err_stage          =>x_err_stage,
                                                    x_err_code           =>x_err_code);

         /* Call  schedules  API to archive/purge data from pa_schedules, pa_schedule_history and pa_schedule_except_history  */

         pa_debug.debug(' About to purge schedules, schedule history and schedule exceptions data ') ;
         x_err_stage := 'About to purge schedules data  for project '||to_char(p_project_id) ;


         pa_purge_pjr_txns.pa_schedules_purge( p_purge_batch_id     =>p_purge_batch_id,
                                               p_project_id         =>p_project_id,
                                               p_purge_release      =>p_purge_release,
                                               p_assignment_id_tab  =>l_requirement_id_tab,
                                               p_archive_flag       =>p_archive_flag,
                                               x_err_stack          =>x_err_stack,
                                               x_err_stage          =>x_err_stage,
                                               x_err_code           =>x_err_code);


        /* Call  API to archive/purge data from pa_candidates and pa_candidate_reviews  */

         pa_debug.debug(' About to purge candidate and candidate reviews  data ') ;
         x_err_stage := 'About to purge candidate and candidate reviws  for project '||to_char(p_project_id) ;

         pa_purge_pjr_txns.pa_candidates_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                p_project_id         =>p_project_id,
                                                p_purge_release      =>p_purge_release,
                                                p_assignment_id_tab  =>l_requirement_id_tab,
                                                p_archive_flag       =>p_archive_flag,
                                                x_err_stack          =>x_err_stack,
                                                x_err_stage          =>x_err_stage,
                                                x_err_code           =>x_err_code);

        /* Call  API to archive/purge data advertisements records  */

         pa_debug.debug(' About to purge advertisements  data ') ;
         x_err_stage := 'About to purge advertisements data for project '||to_char(p_project_id) ;

         pa_purge_pjr_txns.pa_advertisements_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                    p_project_id         =>p_project_id,
                                                    p_purge_release      =>p_purge_release,
                                                    p_assignment_id_tab  =>l_requirement_id_tab,
                                                    p_archive_flag       =>p_archive_flag,
                                                    x_err_stack          =>x_err_stack,
                                                    x_err_stage          =>x_err_stage,
                                                    x_err_code           =>x_err_code);

          /* Call  API to archive/purge assignment and assignment history records records  */

         pa_debug.debug(' About to purge requirement and its history data ') ;
         x_err_stage := 'About to purge  requirement and its history  '||to_char(p_project_id) ;

         pa_purge_pjr_txns.pa_project_assignment_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                        p_project_id         =>p_project_id,
                                                        p_purge_release      =>p_purge_release,
                                                        p_assignment_id_tab  =>l_requirement_id_tab,
                                                        p_archive_flag       =>p_archive_flag,
                                                        x_err_stack          =>x_err_stack,
                                                        x_err_stage          =>x_err_stage,
                                                        x_err_code           =>x_err_code);




         /*  Check if this loop is the last set of p_commit_size  If so then EXIT; */

          IF l_last_fetch='Y' THEN
               EXIT;
          END IF;

   END LOOP;

   CLOSE cur_requirements_closed;

 ELSE

   pa_debug.debug(' About to purge Requirements for Open Indirect Project ') ;
   x_err_stage := 'Opening cursor Cur_Requirements_Active' ;

   OPEN CUR_REQUIREMENTS_ACTIVE;
    LOOP

        /*Clear PL/SQL table before start */
        l_requirement_id_tab.DELETE;

        FETCH  cur_requirements_active
        BULK COLLECT
        INTO  l_requirement_id_tab  LIMIT p_commit_size;

        /*  To check the rows fetched in this fetch */

        l_this_fetch := cur_requirements_active%ROWCOUNT - l_totally_fetched;
        l_totally_fetched := cur_requirements_active%ROWCOUNT;

        /*
         *  Check if this fetch has 0 rows returned (ie last fetch was even p_commit_size)
         *  This could happen in 2 cases
         *      1) this fetch is the very first fetch with 0 rows returned
         *   OR 2) the last fetch returned an even p_commit_size  rows
         *  If either then EXIT without any processing
         */
         IF  l_this_fetch = 0 then
                EXIT;
         END IF;

        /*
         *  Check if this fetch is the last fetch
         *  If so then set the flag l_last_fetch so as to exit after processing
         */
        IF  l_this_fetch < p_commit_size  then
              l_last_fetch := 'Y';
        ELSE
              l_last_fetch := 'N';
        END IF;

       /* Call  forecast API to archive/purge data from pa_forecast_items and detail table */

         pa_debug.debug(' About to purge Forecast Items and Forecast Item Details ') ;
         x_err_stage := 'About to purge forecast items for project '||to_char(p_project_id) ;

         pa_purge_pjr_txns.pa_forecast_items_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                    p_project_id         =>p_project_id,
                                                    p_purge_release      =>p_purge_release,
                                                    p_assignment_id_tab  =>l_requirement_id_tab,
                                                    p_archive_flag       =>p_archive_flag,
                                                    x_err_stack          =>x_err_stack,
                                                    x_err_stage          =>x_err_stage,
                                                    x_err_code           =>x_err_code);

        /* Call  schedules  API to archive/purge data from pa_schedules, pa_schedule_history and pa_schedule_except_history  */

         pa_debug.debug(' About to purge schedules, schedule history and schedule exceptions data ') ;
         x_err_stage := 'About to purge sschedules data  for project '||to_char(p_project_id) ;


         pa_purge_pjr_txns.pa_schedules_purge( p_purge_batch_id     =>p_purge_batch_id,
                                               p_project_id         =>p_project_id,
                                               p_purge_release      =>p_purge_release,
                                               p_assignment_id_tab  =>l_requirement_id_tab,
                                               p_archive_flag       =>p_archive_flag,
                                               x_err_stack          =>x_err_stack,
                                               x_err_stage          =>x_err_stage,
                                               x_err_code           =>x_err_code);


         /* Call  API to archive/purge data from pa_candidates and pa_candidate_reviews  */

         pa_debug.debug(' About to purge candidate and candidate reviews  data ') ;
         x_err_stage := 'About to purge candidate and candidate reviws  for project '||to_char(p_project_id) ;

         pa_purge_pjr_txns.pa_candidates_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                p_project_id         =>p_project_id,
                                                p_purge_release      =>p_purge_release,
                                                p_assignment_id_tab  =>l_requirement_id_tab,
                                                p_archive_flag       =>p_archive_flag,
                                                x_err_stack          =>x_err_stack,
                                                x_err_stage          =>x_err_stage,
                                                x_err_code           =>x_err_code);

          /* Call  API to archive/purge data advertisements records  */

         pa_debug.debug(' About to purge advertisements  data ') ;
         x_err_stage := 'About to purge advertisements data for project '||to_char(p_project_id) ;

         pa_purge_pjr_txns.pa_advertisements_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                    p_project_id         =>p_project_id,
                                                    p_purge_release      =>p_purge_release,
                                                    p_assignment_id_tab  =>l_requirement_id_tab,
                                                    p_archive_flag       =>p_archive_flag,
                                                    x_err_stack          =>x_err_stack,
                                                    x_err_stage          =>x_err_stage,
                                                    x_err_code           =>x_err_code);

         /* Call  API to archive/purge assignment and assignment history records records  */

         pa_debug.debug(' About to purge requirement and its history data ') ;
         x_err_stage := 'About to purge  requirement and its history  '||to_char(p_project_id) ;

         pa_purge_pjr_txns.pa_project_assignment_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                        p_project_id         =>p_project_id,
                                                        p_purge_release      =>p_purge_release,
                                                        p_assignment_id_tab  =>l_requirement_id_tab,
                                                        p_archive_flag       =>p_archive_flag,
                                                        x_err_stack          =>x_err_stack,
                                                        x_err_stage          =>x_err_stage,
                                                        x_err_code           =>x_err_code);



       /*  Check if this loop is the last set of p_commit_size  If so then EXIT; */

        IF l_last_fetch='Y' THEN
               EXIT;
        END IF;

   END LOOP;

   CLOSE cur_requirements_active;

 END IF;

 x_err_stack := l_old_err_stack; -- Added for bug 4227589

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
      RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_PJR_TXNS.PA_REQUIREMENTS_PURGE' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;


END  PA_REQUIREMENTS_PURGE;

-- Start of comments
-- API name         : PA_ASSIGNMENTS_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records related to Assignments for project

Procedure PA_ASSIGNMENTS_PURGE ( p_purge_batch_id                 in NUMBER,
                                 p_project_id                     in NUMBER,
                                 p_purge_release                  in VARCHAR2,
                                 p_txn_to_date                    in DATE,
                                 p_archive_flag                   in VARCHAR2,
                                 p_commit_size                    in NUMBER,
                                 x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_err_code                       in OUT NOCOPY NUMBER ) AS --File.Sql.39 bug 4440895

    l_assignment_id_tab                  PA_PLSQL_DATATYPES.IdTabTyp;
    I                                    PLS_INTEGER;
    l_last_fetch                         VARCHAR2(1):='N';
    l_this_fetch                         NUMBER:=0;
    l_totally_fetched                    NUMBER:=0;

/*This cursor will select all the assignments for project passed(Closed Project Purge.
  All the assignments belong to project id passed will be purged. No other
  conditions are mentioned as the purge program will purge closed project
  assignments only if the all the assignmnets are eligible for purging.*/

   CURSOR CUR_ASSIGNMENTS_CLOSED IS
   SELECT assignment_id FROM Pa_project_assignments pa
   WHERE pa.project_id = P_Project_Id
   AND pa.assignment_type <>'OPEN_ASSIGNMENT';


/*This cursor will select all the assignments for project passed whose end date is
  falling before purge till date. This cursor is applicable in case of open project
  purge. In this case, we purge all the assignments falling before purge till date.*/

   CURSOR CUR_ASSIGNMENTS_ACTIVE  IS
   SELECT assignment_id FROM Pa_project_assignments pa
   WHERE pa.project_id = P_Project_Id
   AND pa.assignment_type <>'OPEN_ASSIGNMENT'
   AND p_txn_to_date >= pa.end_date;

   l_old_err_stack        VARCHAR2(2000); -- Added for bug 4227589

Begin

 l_old_err_stack := x_err_stack;  -- Added for bug 4227589
 x_err_stack := x_err_stack || ' ->Before call to purge assignments ';

 If p_txn_to_date IS NULL THEN

   pa_debug.debug(' About to purge Assignments for closed project purge ') ;
   x_err_stage := 'About to start purge for assignments for project  '||to_char(p_project_id) ;

    OPEN CUR_ASSIGNMENTS_CLOSED;
    LOOP

        /*Clear PL/SQL table before start */
        l_assignment_id_tab.DELETE;

        FETCH  cur_assignments_closed
        BULK COLLECT
        INTO l_assignment_id_tab LIMIT p_commit_size;

        /*  To check the rows fetched in this fetch */

        l_this_fetch := cur_assignments_closed%ROWCOUNT - l_totally_fetched;
        l_totally_fetched := cur_assignments_closed%ROWCOUNT;

        /*
         *  Check if this fetch has 0 rows returned (ie last fetch was even p_commit_size)
         *  This could happen in 2 cases
         *      1) this fetch is the very first fetch with 0 rows returned
         *   OR 2) the last fetch returned an even p_commit_size  rows
         *  If either then EXIT without any processing
         */
          IF  l_this_fetch = 0 then
              EXIT;
          END IF;

        /*
         *  Check if this fetch is the last fetch
         *  If so then set the flag l_last_fetch so as to exit after processing
         */
          IF  l_this_fetch < p_commit_size  then
              l_last_fetch := 'Y';
          ELSE
              l_last_fetch := 'N';
          END IF;

         /* Call  forecast API to archive/purge data from pa_forecast_items and detail table */

         pa_debug.debug(' About to purge Forecast Items and Forecast Item Details ') ;
         x_err_stage := 'About to purge forecast items for project '||to_char(p_project_id) ;

         pa_purge_pjr_txns.pa_forecast_items_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                    p_project_id         =>p_project_id,
                                                    p_purge_release      =>p_purge_release,
                                                    p_assignment_id_tab  =>l_assignment_id_tab,
                                                    p_archive_flag       =>p_archive_flag,
                                                    x_err_stack          =>x_err_stack,
                                                    x_err_stage          =>x_err_stage,
                                                    x_err_code           =>x_err_code);

         /* Call  schedules  API to archive/purge data from pa_schedules, pa_schedule_history and pa_schedule_except_history  */

         pa_debug.debug(' About to purge schedules, schedule history and schedule exceptions data ') ;
         x_err_stage := 'About to purge sschedules data  for project '||to_char(p_project_id) ;


         pa_purge_pjr_txns.pa_schedules_purge( p_purge_batch_id     =>p_purge_batch_id,
                                               p_project_id         =>p_project_id,
                                               p_purge_release      =>p_purge_release,
                                               p_assignment_id_tab  =>l_assignment_id_tab,
                                               p_archive_flag       =>p_archive_flag,
                                               x_err_stack          =>x_err_stack,
                                               x_err_stage          =>x_err_stage,
                                               x_err_code           =>x_err_code);


        /* Call conflicts  API to archive/purge data from pa_assignment_conflict_hist table  */

         pa_debug.debug(' About to purge assignment conflicts history data ') ;
         x_err_stage := 'About to purge assignment conflicts history '||to_char(p_project_id) ;


         pa_purge_pjr_txns.pa_assignment_conflicts_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                          p_project_id         =>p_project_id,
                                                          p_purge_release      =>p_purge_release,
                                                          p_assignment_id_tab  =>l_assignment_id_tab,
                                                          p_archive_flag       =>p_archive_flag,
                                                          x_err_stack          =>x_err_stack,
                                                          x_err_stage          =>x_err_stage,
                                                          x_err_code           =>x_err_code);


          /* Call conflicts  API to archive/purge data from pa_project_parties table  */

         pa_debug.debug(' About to purge pa_project_parties  data related to assignments') ;
         x_err_stage := 'About to purge  assignment related project parties data'||to_char(p_project_id) ;

         pa_purge_pjr_txns.pa_project_parties_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                     p_project_id         =>p_project_id,
                                                     p_purge_release      =>p_purge_release,
                                                     p_assignment_id_tab  =>l_assignment_id_tab,
                                                     p_archive_flag       =>p_archive_flag,
                                                     x_err_stack          =>x_err_stack,
                                                     x_err_stage          =>x_err_stage,
                                                     x_err_code           =>x_err_code);

         /* Call  API to archive/purge assignment and assignment history records records  */

         pa_debug.debug(' About to purge assignments  and its history data ') ;
         x_err_stage := 'About to purge  assignments and its history  '||to_char(p_project_id) ;

         pa_purge_pjr_txns.pa_project_assignment_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                        p_project_id         =>p_project_id,
                                                        p_purge_release      =>p_purge_release,
                                                        p_assignment_id_tab  =>l_assignment_id_tab,
                                                        p_archive_flag       =>p_archive_flag,
                                                        x_err_stack          =>x_err_stack,
                                                        x_err_stage          =>x_err_stage,
                                                        x_err_code           =>x_err_code);

         /*  Check if this loop is the last set of p_commit_size  If so then EXIT; */

          IF l_last_fetch='Y' THEN
               EXIT;
          END IF;

   END LOOP;


   CLOSE cur_assignments_closed;

 ELSE
  pa_debug.debug(' About to purge Assignments for Open Indirect Project  ') ;
  x_err_stage := 'About to purge assignments for project '||to_char(p_project_id) ;

   OPEN CUR_ASSIGNMENTS_ACTIVE;
   LOOP

        /*Clear PL/SQL table before start */
        l_assignment_id_tab.DELETE;

        FETCH  cur_assignments_active
        BULK COLLECT
        INTO l_assignment_id_tab LIMIT p_commit_size;

        /*  To check the rows fetched in this fetch */

        l_this_fetch := cur_assignments_active%ROWCOUNT - l_totally_fetched;
        l_totally_fetched := cur_assignments_active%ROWCOUNT;

        /*
         *  Check if this fetch has 0 rows returned (ie last fetch was even p_commit_size)
         *  This could happen in 2 cases
         *      1) this fetch is the very first fetch with 0 rows returned
         *   OR 2) the last fetch returned an even p_commit_size  rows
         *  If either then EXIT without any processing
         */
         IF  l_this_fetch = 0 then
                EXIT;
         END IF;

        /*
         *  Check if this fetch is the last fetch
         *  If so then set the flag l_last_fetch so as to exit after processing
         */
        /*
         *  Check if this fetch is the last fetch
         *  If so then set the flag l_last_fetch so as to exit after processing
         */
        IF  l_this_fetch < p_commit_size  then
              l_last_fetch := 'Y';
        ELSE
              l_last_fetch := 'N';
        END IF;

       /* Call  forecast API to archive/purge data from pa_forecast_items and detail table */

         pa_debug.debug(' About to purge Forecast Items and Forecast Item Details ') ;
         x_err_stage := 'About to purge forecast items for project '||to_char(p_project_id) ;

         pa_purge_pjr_txns.pa_forecast_items_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                    p_project_id         =>p_project_id,
                                                    p_purge_release      =>p_purge_release,
                                                    p_assignment_id_tab  =>l_assignment_id_tab,
                                                    p_archive_flag       =>p_archive_flag,
                                                    x_err_stack          =>x_err_stack,
                                                    x_err_stage          =>x_err_stage,
                                                    x_err_code           =>x_err_code);

        /* Call  schedules  API to archive/purge data from pa_schedules, pa_schedule_history and pa_schedule_except_history  */

         pa_debug.debug(' About to purge schedules, schedule history and schedule exceptions data ') ;
         x_err_stage := 'About to purge sschedules data  for project '||to_char(p_project_id) ;


         pa_purge_pjr_txns.pa_schedules_purge( p_purge_batch_id     =>p_purge_batch_id,
                                               p_project_id         =>p_project_id,
                                               p_purge_release      =>p_purge_release,
                                               p_assignment_id_tab  =>l_assignment_id_tab,
                                               p_archive_flag       =>p_archive_flag,
                                               x_err_stack          =>x_err_stack,
                                               x_err_stage          =>x_err_stage,
                                               x_err_code           =>x_err_code);


        /* Call conflicts  API to archive/purge data from pa_assignment_conflict_hist table  */

         pa_debug.debug(' About to purge assignment conflicts history data ') ;
         x_err_stage := 'About to purge assignment conflicts history '||to_char(p_project_id) ;


         pa_purge_pjr_txns.pa_assignment_conflicts_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                          p_project_id         =>p_project_id,
                                                          p_purge_release      =>p_purge_release,
                                                          p_assignment_id_tab  =>l_assignment_id_tab,
                                                          p_archive_flag       =>p_archive_flag,
                                                          x_err_stack          =>x_err_stack,
                                                          x_err_stage          =>x_err_stage,
                                                          x_err_code           =>x_err_code);


          /* Call conflicts  API to archive/purge data from pa_project_parties table  */

         pa_debug.debug(' About to purge pa_project_parties  data related to assignments') ;
         x_err_stage := 'About to purge  assignment related project parties data'||to_char(p_project_id) ;

         pa_purge_pjr_txns.pa_project_parties_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                     p_project_id         =>p_project_id,
                                                     p_purge_release      =>p_purge_release,
                                                     p_assignment_id_tab  =>l_assignment_id_tab,
                                                     p_archive_flag       =>p_archive_flag,
                                                     x_err_stack          =>x_err_stack,
                                                     x_err_stage          =>x_err_stage,
                                                     x_err_code           =>x_err_code);

         /* Call  API to archive/purge assignment and assignment history records records  */

         pa_debug.debug(' About to purge assignments  and its history data ') ;
         x_err_stage := 'About to purge  assignments and its history  '||to_char(p_project_id) ;

         pa_purge_pjr_txns.pa_project_assignment_purge( p_purge_batch_id     =>p_purge_batch_id,
                                                        p_project_id         =>p_project_id,
                                                        p_purge_release      =>p_purge_release,
                                                        p_assignment_id_tab  =>l_assignment_id_tab,
                                                        p_archive_flag       =>p_archive_flag,
                                                        x_err_stack          =>x_err_stack,
                                                        x_err_stage          =>x_err_stage,
                                                        x_err_code           =>x_err_code);



       /*  Check if this loop is the last set of p_commit_size  If so then EXIT; */

        IF l_last_fetch='Y' THEN
               EXIT;
        END IF;

   END LOOP;

   CLOSE cur_assignments_active;

 END IF;

 x_err_stack := l_old_err_stack; -- Added for bug 4227589

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_PJR_TXNS.PA_ASSIGNMENTS_PURGE' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

   RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

end  PA_ASSIGNMENTS_PURGE;

-- Start of comments
-- API name         : PA_FORECAST_ITEMS_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Purge procedure for Purging records from tables PA_FORECAST_ITEMS and PA_FORECAST_ITEM_DETAILS


Procedure PA_FORECAST_ITEMS_PURGE ( p_purge_batch_id                 in NUMBER,
                                    p_project_id                     in NUMBER,
                                    p_purge_release                  in VARCHAR2,
                                    p_assignment_id_tab              in PA_PLSQL_DATATYPES.IdTabTyp,
                                    p_archive_flag                   in VARCHAR2,
                                    x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    x_err_code                       in OUT NOCOPY NUMBER )  IS --File.Sql.39 bug 4440895

    l_forecast_item_id                   Pa_forecast_items.forecast_item_id%TYPE;
    I                                    PLS_INTEGER;
    l_assignment_id                      pa_forecast_items.assignment_id%TYPE;
    l_nos_fi_inserted                    NUMBER ;
    l_nos_fid_inserted                   NUMBER ;
    l_nos_fi_deleted                     NUMBER ;
    l_nos_fid_deleted                    NUMBER ;
    l_nos_fi_amt_inserted                NUMBER;
    l_nos_fi_amt_deleted                 NUMBER;

    CURSOR Cur_forecast_items(x_assignment_id In NUMBER)  IS
    SELECT forecast_item_id from pa_forecast_items
    WHERE assignment_id =x_assignment_id;

    l_old_err_stack        VARCHAR2(2000); -- Added for bug 4227589

Begin

 l_old_err_stack := x_err_stack;  -- Added for bug 4227589

 x_err_stack := x_err_stack || ' ->Before call to purge Forecast Item records ';

/*Initialize the no of record variables for each call */

  pa_debug.debug(' Inside Procedure to purge Forecast Items and Forecast Item Details ') ;
  x_err_stage := 'Start  purging forecast items for project '||to_char(p_project_id) ;


   l_nos_fi_inserted  :=0;
   l_nos_fid_inserted :=0;
   l_nos_fi_deleted   :=0;
   l_nos_fid_deleted  :=0;
   l_nos_fi_amt_deleted :=0;
   l_nos_fi_amt_inserted :=0;


     -----------------Begin Logic added to purge data from Workflow related tables-----------------
         /* Call  Workflow API to archive/purge data from pa_wf_processes and detail table
            and also from pa_wf_ntf_performers table*/

         Pa_Debug.DEBUG(' About to purge workflow process and details ') ;
         x_err_stage := 'About to purge workflow data for project '||TO_CHAR(p_project_id) ;

         Pa_Purge_Pjr_Txns.pa_wf_purge ( p_purge_batch_id     =>p_purge_batch_id,
                                         p_project_id         =>p_project_id,
                                         p_purge_release      =>p_purge_release,
                                         p_entity_key_tab     =>p_assignment_id_tab,
                                         p_wf_type_code       =>'FORECAST_GENERATION',
                                         p_item_type          =>'PARFIGEN',
                                         p_archive_flag       =>p_archive_flag,
                                         x_err_stack          =>x_err_stack,
                                         x_err_stage          =>x_err_stage,
                                         x_err_code           =>x_err_code);

     -----------------End of Logic added to purge data from Workflow related tables-----------------

/* Fetch the assignments from  assignment tab. */

   FOR I in p_assignment_id_tab.FIRST .. p_assignment_id_tab.LAST LOOP
     l_assignment_id :=p_assignment_id_tab(I);

     pa_debug.debug(' Fetching Forecast Items for assignments Id passed. ') ;
     x_err_stage := 'Fetching  forecast items for Assignment '||to_char(l_assignment_id) ;

     OPEN cur_forecast_items(l_assignment_id);
      LOOP
       FETCH cur_forecast_items  INTO l_forecast_item_id;
       IF cur_forecast_items%NOTFOUND THEN
         EXIT;
       END IF;

/* If archive flag is YES, archiving of data needs to be done. Insert data into correspodning AR tables */

       IF p_archive_flag='Y' THEN

       pa_debug.debug('Inserting Records into pa_forecast_items_AR table  ') ;
       x_err_stage := 'Inserting Records into pa_forecast_items_AR table for forecast item '||to_char(l_forecast_item_id) ;

         INSERT INTO pa_frcst_items_AR
              (PURGE_BATCH_ID,
               PURGE_RELEASE,
               PURGE_PROJECT_ID,
               FORECAST_ITEM_ID,
               FORECAST_ITEM_TYPE,
               PROJECT_ORG_ID,
               EXPENDITURE_ORG_ID,
               EXPENDITURE_ORGANIZATION_ID,
               PROJECT_ORGANIZATION_ID,
               PROJECT_ID,
               PROJECT_TYPE_CLASS,
               PERSON_ID,
               RESOURCE_ID,
               BORROWED_FLAG,
               ASSIGNMENT_ID,
               ITEM_DATE,
               ITEM_UOM,
               ITEM_QUANTITY,
               PVDR_PERIOD_SET_NAME,
               PVDR_PA_PERIOD_NAME,
               PVDR_GL_PERIOD_NAME,
               RCVR_PERIOD_SET_NAME,
               RCVR_PA_PERIOD_NAME,
               RCVR_GL_PERIOD_NAME,
               GLOBAL_EXP_PERIOD_END_DATE,
               EXPENDITURE_TYPE,
               EXPENDITURE_TYPE_CLASS,
               COST_REJECTION_CODE,
               REV_REJECTION_CODE,
               TP_REJECTION_CODE,
               BURDEN_REJECTION_CODE,
               OTHER_REJECTION_CODE,
               DELETE_FLAG,
               ERROR_FLAG,
               PROVISIONAL_FLAG,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               REQUEST_ID,
               PROGRAM_APPLICATION_ID,
               PROGRAM_ID,
               PROGRAM_UPDATE_DATE,
               ASGMT_SYS_STATUS_CODE,
               CAPACITY_QUANTITY,
               OVERCOMMITMENT_QUANTITY,
               AVAILABILITY_QUANTITY,
               OVERCOMMITMENT_FLAG,
               AVAILABILITY_FLAG,
               TP_AMOUNT_TYPE,
               FORECAST_AMT_CALC_FLAG,
               COST_TXN_CURRENCY_CODE,
               TXN_RAW_COST,
               TXN_BURDENED_COST,
               REVENUE_TXN_CURRENCY_CODE,
               TXN_REVENUE,
               TP_TXN_CURRENCY_CODE,
               TXN_TRANSFER_PRICE,
               PROJECT_CURRENCY_CODE,
               PROJECT_RAW_COST,
               PROJECT_BURDENED_COST,
               PROJECT_REVENUE,
               PROJECT_TRANSFER_PRICE,
               PROJFUNC_CURRENCY_CODE,
               PROJFUNC_RAW_COST,
               PROJFUNC_BURDENED_COST,
               PROJFUNC_REVENUE,
               PROJFUNC_TRANSFER_PRICE,
               EXPFUNC_CURRENCY_CODE,
               EXPFUNC_RAW_COST,
               EXPFUNC_BURDENED_COST,
               EXPFUNC_TRANSFER_PRICE,
               OVERPROVISIONAL_QTY,
               OVER_PROV_CONF_QTY,
               CONFIRMED_QTY,
               PROVISIONAL_QTY,
               JOB_ID)

          SELECT  p_purge_batch_id,
                  p_purge_release,
                  p_project_id,
                  Forecast_Item_Id,
                  Forecast_Item_Type,
                  Project_Org_Id,
                  Expenditure_Org_Id,
                  Expenditure_Organization_Id,
                  Project_Organization_Id,
                  Project_Id,
                  Project_Type_Class,
                  Person_Id,
                  Resource_Id,
                  Borrowed_Flag,
                  Assignment_Id,
                  Item_Date,
                  Item_Uom,
                  Item_Quantity,
                  Pvdr_Period_Set_Name,
                  Pvdr_Pa_Period_Name,
                  Pvdr_Gl_Period_Name,
                  Rcvr_Period_Set_Name,
                  Rcvr_Pa_Period_Name,
                  Rcvr_Gl_Period_Name,
                  Global_Exp_Period_End_Date,
                  Expenditure_Type,
                  Expenditure_Type_Class,
                  Cost_Rejection_Code,
                  Rev_Rejection_Code,
                  Tp_Rejection_Code,
                  Burden_Rejection_Code,
                  Other_Rejection_Code,
                  Delete_Flag,
                  Error_Flag,
                  Provisional_Flag,
                  Creation_Date,
                  Created_By,
                  Last_Update_Date,
                  Last_Updated_By,
                  Last_Update_Login,
                  Request_Id,
                  Program_Application_Id,
                  Program_Id,
                  Program_Update_Date,
                  Asgmt_Sys_Status_Code,
                  Capacity_Quantity,
                  Overcommitment_Quantity,
                  Availability_Quantity,
                  Overcommitment_Flag,
                  Availability_Flag,
                  Tp_Amount_Type,
                  Forecast_Amt_Calc_Flag,
                  Cost_Txn_Currency_Code,
                  Txn_Raw_Cost,
                  Txn_Burdened_Cost,
                  Revenue_Txn_Currency_Code,
                  Txn_Revenue,
                  Tp_Txn_Currency_Code,
                  Txn_Transfer_Price,
                  Project_Currency_Code,
                  Project_Raw_Cost,
                  Project_Burdened_Cost,
                  Project_Revenue,
                  Project_Transfer_Price,
                  Projfunc_Currency_Code,
                  projfunc_Raw_Cost,
                  Projfunc_Burdened_Cost,
                  Projfunc_Revenue,
                  Projfunc_Transfer_Price,
                  Expfunc_Currency_Code,
                  Expfunc_Raw_Cost,
                  Expfunc_Burdened_Cost,
                  Expfunc_Transfer_Price,
                  Overprovisional_Qty,
                  Over_Prov_Conf_Qty,
                  Confirmed_Qty,
                  Provisional_Qty,
                  Job_Id
              FROM pa_forecast_items
              WHERE forecast_item_id = l_forecast_item_id;

 /*Increase the value of l_nos_fi_inserted to indicate number of records inserted in forecast_items table.
  The value will increase for each loop(forecast item id*/
            l_nos_fi_inserted := l_nos_fi_inserted + SQL%ROWCOUNT;

       pa_debug.debug('Inserting Records into pa_forecast_item_DETAILS_AR table  ') ;
       x_err_stage := 'Inserting Records into forecast_item_detail table for forecast item '||to_char(l_forecast_item_id) ;

              INSERT INTO PA_FRCST_ITEM_DTLS_AR
                  (PURGE_BATCH_ID,
                   PURGE_RELEASE,
                   PURGE_PROJECT_ID,
                   FORECAST_ITEM_ID,
                   AMOUNT_TYPE_ID,
                   LINE_NUM,
                   RESOURCE_TYPE_CODE,
                   PERSON_BILLABLE_FLAG,
                   ITEM_DATE,
                   ITEM_UOM,
                   ITEM_QUANTITY,
                   EXPENDITURE_ORG_ID,
                   PROJECT_ORG_ID,
                   PVDR_ACCT_CURR_CODE,
                   PVDR_ACCT_AMOUNT,
                   RCVR_ACCT_CURR_CODE,
                   RCVR_ACCT_AMOUNT,
                   PROJ_CURRENCY_CODE,
                   PROJ_AMOUNT,
                   DENOM_CURRENCY_CODE,
                   DENOM_AMOUNT,
                   TP_AMOUNT_TYPE,
                   BILLABLE_FLAG,
                   FORECAST_SUMMARIZED_CODE,
                   UTIL_SUMMARIZED_CODE,
                   WORK_TYPE_ID,
                   RESOURCE_UTIL_CATEGORY_ID,
                   ORG_UTIL_CATEGORY_ID,
                   RESOURCE_UTIL_WEIGHTED,
                   ORG_UTIL_WEIGHTED,
                   PROVISIONAL_FLAG,
                   REVERSED_FLAG,
                   NET_ZERO_FLAG,
                   REDUCE_CAPACITY_FLAG,
                   LINE_NUM_REVERSED,
                   CREATION_DATE,
                   CREATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_LOGIN,
                   REQUEST_ID,
                   PROGRAM_APPLICATION_ID,
                   PROGRAM_ID,
                   PROGRAM_UPDATE_DATE,
                   CAPACITY_QUANTITY,
                   OVERCOMMITMENT_QTY,
                   OVERPROVISIONAL_QTY,
                   OVER_PROV_CONF_QTY,
                   CONFIRMED_QTY,
                   PROVISIONAL_QTY,
                   JOB_ID,
                   PROJECT_ID,
                   RESOURCE_ID,
                   EXPENDITURE_ORGANIZATION_ID,
                   PJI_SUMMARIZED_FLAG)

           SELECT  p_purge_batch_id,
                   p_Purge_Release,
                   p_Project_Id,
                   Forecast_Item_Id,
                   Amount_Type_Id,
                   Line_Num,
                   Resource_Type_Code,
                   Person_Billable_Flag,
                   Item_Date,
                   Item_Uom,
                   Item_Quantity,
                   Expenditure_Org_Id,
                   Project_Org_Id,
                   Pvdr_Acct_Curr_Code,
                   Pvdr_Acct_Amount,
                   Rcvr_Acct_Curr_Code,
                   Rcvr_Acct_Amount,
                   Proj_Currency_Code,
                   Proj_Amount,
                   Denom_Currency_Code,
                   Denom_Amount,
                   Tp_Amount_Type,
                   Billable_Flag,
                   Forecast_Summarized_Code,
                   Util_Summarized_Code,
                   Work_Type_Id,
                   Resource_Util_Category_Id,
                   Org_Util_Category_Id,
                   Resource_Util_Weighted,
                   Org_Util_Weighted,
                   Provisional_Flag,
                   Reversed_Flag,
                   Net_Zero_Flag,
                   Reduce_Capacity_Flag,
                   Line_Num_Reversed,
                   Creation_Date,
                   Created_By,
                   Last_Update_Date,
                   Last_Updated_By,
                   Last_Update_Login,
                   Request_Id,
                   Program_Application_Id,
                   Program_Id,
                   Program_Update_Date,
                   CAPACITY_QUANTITY,
                   OVERCOMMITMENT_QTY,
                   OVERPROVISIONAL_QTY,
                   OVER_PROV_CONF_QTY,
                   CONFIRMED_QTY,
                   PROVISIONAL_QTY,
                   JOB_ID,
                   PROJECT_ID,
                   RESOURCE_ID,
                   EXPENDITURE_ORGANIZATION_ID,
                   PJI_SUMMARIZED_FLAG
           FROM PA_forecast_item_details
           WHERE forecast_item_id=l_forecast_item_id;

  /*Increase the value of l_nos_fis_inserted to indicate number of records inserted in forecast_items detail table.
  The value will increase for each loop(forecast item id*/
          l_nos_fid_inserted := l_nos_fid_inserted + SQL%ROWCOUNT;

            INSERT INTO PA_FI_AMOUNT_DETAILS_AR
                       (PURGE_BATCH_ID,
			PURGE_RELEASE,
			PURGE_PROJECT_ID,
			FORECAST_ITEM_ID,
			LINE_NUM,
			ITEM_DATE,
			ITEM_UOM,
			ITEM_QUANTITY,
			REVERSED_FLAG,
			NET_ZERO_FLAG,
			LINE_NUM_REVERSED,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			REQUEST_ID,
			PROGRAM_APPLICATION_ID,
			PROGRAM_ID,
			PROGRAM_UPDATE_DATE,
			COST_TXN_CURRENCY_CODE,
			TXN_RAW_COST,
			TXN_BURDENED_COST,
			REVENUE_TXN_CURRENCY_CODE,
			TXN_REVENUE,
			TP_TXN_CURRENCY_CODE,
			TXN_TRANSFER_PRICE,
			PROJECT_CURRENCY_CODE,
			PROJECT_COST_RATE_DATE,
			PROJECT_COST_RATE_TYPE,
			PROJECT_COST_EXCHANGE_RATE,
			PROJECT_RAW_COST,
			PROJECT_BURDENED_COST,
			PROJECT_REVENUE_RATE_DATE,
			PROJECT_REVENUE_RATE_TYPE,
			PROJECT_REVENUE_EXCHANGE_RATE,
			PROJECT_REVENUE,
			PROJECT_TP_RATE_DATE,
			PROJECT_TP_RATE_TYPE,
			PROJECT_TP_EXCHANGE_RATE,
			PROJECT_TRANSFER_PRICE,
			PROJFUNC_CURRENCY_CODE,
			PROJFUNC_COST_RATE_DATE,
			PROJFUNC_COST_RATE_TYPE,
			PROJFUNC_COST_EXCHANGE_RATE,
			PROJFUNC_RAW_COST,
			PROJFUNC_BURDENED_COST,
			PROJFUNC_REVENUE,
			PROJFUNC_TRANSFER_PRICE,
			--PROJFUNC_RATE_DATE,
			--PROJFUNC_RATE_TYPE,
			--PROJFUNC_EXCHANGE_RATE,
			EXPFUNC_CURRENCY_CODE,
			EXPFUNC_COST_RATE_DATE,
			EXPFUNC_COST_RATE_TYPE,
			EXPFUNC_COST_EXCHANGE_RATE,
			EXPFUNC_RAW_COST,
			EXPFUNC_BURDENED_COST,
			EXPFUNC_TP_RATE_DATE,
			EXPFUNC_TP_RATE_TYPE,
			EXPFUNC_TP_EXCHANGE_RATE,
			EXPFUNC_TRANSFER_PRICE)

                SELECT  P_purge_batch_id,
                        P_purge_release,
                        P_project_id,
                        Forecast_Item_Id,
			Line_Num,
			Item_Date,
			Item_Uom,
			Item_Quantity,
			Reversed_Flag,
			Net_Zero_Flag,
			Line_Num_Reversed,
			Creation_Date,
			Created_By,
			Last_Update_Date,
			Last_Updated_By,
			Last_Update_Login,
			Request_Id,
			Program_Application_Id,
			Program_Id,
			Program_Update_Date,
			Cost_Txn_Currency_Code,
			Txn_Raw_Cost,
			Txn_Burdened_Cost,
			Revenue_Txn_Currency_Code,
			Txn_Revenue,
			Tp_Txn_Currency_Code,
			Txn_Transfer_Price,
			Project_Currency_Code,
			Project_Cost_Rate_Date,
			Project_Cost_Rate_Type,
			Project_Cost_Exchange_Rate,
			Project_Raw_Cost,
			Project_Burdened_Cost,
			Project_Revenue_Rate_Date,
			Project_Revenue_Rate_Type,
			Project_Revenue_Exchange_Rate,
			Project_Revenue,
			Project_Tp_Rate_Date,
			Project_Tp_Rate_Type,
			Project_Tp_Exchange_Rate,
			Project_Transfer_Price,
			Projfunc_Currency_Code,
			Projfunc_Cost_Rate_Date,
			Projfunc_Cost_Rate_Type,
			Projfunc_Cost_Exchange_Rate,
			Projfunc_Raw_Cost,
			Projfunc_Burdened_Cost,
			Projfunc_Revenue,
			Projfunc_Transfer_Price,
			--Projfunc_Rate_Date,
			--Projfunc_Rate_Type,
			--Projfunc_Exchange_Rate,
			Expfunc_Currency_Code,
			Expfunc_Cost_Rate_Date,
			Expfunc_Cost_Rate_Type,
			Expfunc_Cost_Exchange_Rate,
			Expfunc_Raw_Cost,
			Expfunc_Burdened_Cost,
			Expfunc_Tp_Rate_Date,
			Expfunc_Tp_Rate_Type,
			Expfunc_Tp_Exchange_Rate,
			Expfunc_Transfer_Price
           FROM PA_FI_AMOUNT_DETAILS Where forecast_item_id=l_forecast_item_id;

       /*Increase the value of l_nos_fi_amt_inserted to reflct the number of records inserted */

                 l_nos_fi_amt_inserted := l_nos_fi_amt_inserted + SQL%ROWCOUNT;

       END IF;

/*To keep the count of no os records deleted from pa_forecast_items and pa_forecast_item_details, manipulate the
  count of l_nos_of fi_deleted and l_nos_fis_deleted. */

       pa_debug.debug('Deleting Records from  pa_fi_amount_details table  ') ;
       x_err_stage := 'Deleting Records from  pa_fi_amount_details table for id '||to_char(l_forecast_item_id) ;

            DELETE PA_FI_AMOUNT_DETAILS
            WHERE forecast_item_id =l_forecast_item_id;

           l_nos_fi_amt_deleted := l_nos_fi_amt_deleted + SQL%ROWCOUNT;

       pa_debug.debug('Deleting Records from  pa_forecast_item_details table  ') ;
       x_err_stage := 'Deleting Records from  pa_forecast_item_details table for id '||to_char(l_forecast_item_id) ;

            DELETE PA_FORECAST_ITEM_DETAILS
            WHERE forecast_item_id =l_forecast_item_id;

            l_nos_fid_deleted :=l_nos_fid_deleted + SQL%ROWCOUNT;

            pa_debug.debug('Deleting Records from  pa_forecast_items table  ') ;
            x_err_stage := 'Deleting Records from  pa_forecast_items table for id '||to_char(l_forecast_item_id) ;


            DELETE PA_FORECAST_ITEMS
            WHERE forecast_item_id=l_forecast_item_id;

           l_nos_fi_deleted :=l_nos_fi_deleted + SQL%ROWCOUNT;


     END LOOP;
    Close cur_forecast_items;
   END LOOP;

/*After "deleting" or "deleting and inserting" a set of records the transaction is commited. This also creates a record in the Pa_Purge_Project_details, which will show the no. of records that are purged from each table.
 The procedure is called once for pa_forecast_items and once for pa_forecast_item_details */

  	pa_purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_FORECAST_ITEMS',
	                       l_nos_fi_inserted,
	                       l_nos_fi_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

       	pa_purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_FORECAST_ITEM_DETAILS',
	                       l_nos_fid_inserted,
	                       l_nos_fid_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

        pa_purge.CommitProcess(p_purge_batch_id,
                               p_project_id,
                               'PA_FI_AMOUNT_DETAILS',
	                       /*  l_nos_fid_inserted,  bug 2480653 */
                               /*  l_nos_fid_deleted,  bug 2480653 */
                               l_nos_fi_amt_inserted,
                               l_nos_fi_amt_deleted,
                               x_err_code,
                               x_err_stack,
                               x_err_stage
                               ) ;


   x_err_stack := l_old_err_stack; -- Added for bug 4227589

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_COSTING.PA_COSTING_MAIN_PURGE' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;


end pa_forecast_items_purge;


-- Start of comments
-- API name         : PA_SCHEDULES_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Purge procedure for Purging records from tables PA_Schedules, pa_schedules_history and
--                    pa_schedule_except_history tables.

Procedure PA_SCHEDULES_PURGE ( p_purge_batch_id                 in NUMBER,
                               p_project_id                     in NUMBER,
                               p_purge_release                  in VARCHAR2,
                               p_assignment_id_tab              in PA_PLSQL_DATATYPES.IdTabTyp,
                               p_archive_flag                   in VARCHAR2,
                               x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_err_code                       in OUT NOCOPY NUMBER ) IS --File.Sql.39 bug 4440895

    l_schedule_id                        pa_schedules.schedule_id%TYPE;
    l_schedule_exception_id              pa_schedule_except_history.schedule_exception_id%TYPE;
    I                                    PLS_INTEGER;
    l_assignment_id                      pa_forecast_items.assignment_id%TYPE;
    l_nos_schedule_inserted              NUMBER ;
    l_nos_schedule_his_inserted          NUMBER ;
    l_nos_schedule_exp_inserted         NUMBER ;
    l_nos_schedule_deleted               NUMBER ;
    l_nos_schedule_his_deleted           NUMBER ;
    l_nos_schedule_exp_deleted          NUMBER ;


    CURSOR Cur_schedules(x_assignment_id In NUMBER)  IS
    SELECT schedule_id from pa_schedules
    WHERE assignment_id =x_assignment_id;

    Cursor Cur_Schedule_except (a_assignment_id In NUMBER)  IS
    SELECT schedule_exception_id from pa_schedule_except_history
    WHERE assignment_id =a_assignment_id;

    l_old_err_stack        VARCHAR2(2000); -- Added for bug 4227589

Begin

l_old_err_stack := x_err_stack;  -- Added for bug 4227589

x_err_stack := x_err_stack || ' ->Before call to purge schedule related records ';

/*Initialize the no of record variables for each call */

  pa_debug.debug(' Inside Procedure to purge schedule, schedule exceptions and schedule history records ') ;
  x_err_stage := 'Start  purging schedules for project '||to_char(p_project_id) ;

    l_nos_schedule_inserted      :=0;
    l_nos_schedule_his_inserted  :=0;
    l_nos_schedule_exp_inserted  :=0;
    l_nos_schedule_deleted       :=0;
    l_nos_schedule_his_deleted   :=0;
    l_nos_schedule_exp_deleted   :=0;


/* Fetch the assignments from  assignment tab. */

   FOR I in p_assignment_id_tab.FIRST .. p_assignment_id_tab.LAST LOOP
     l_assignment_id :=p_assignment_id_tab(I);

     pa_debug.debug(' Fetching schedule records for assignments Id passed. ') ;
     x_err_stage := 'Fetching  schedule records for Assignment '||to_char(l_assignment_id) ;

     OPEN cur_schedules(l_assignment_id);
      LOOP
       FETCH cur_schedules  INTO l_schedule_id;
       IF cur_schedules%NOTFOUND THEN
         EXIT;
       END IF;

       /* If archive flag is YES, archiving of data needs to be done. Insert data into correspodning AR tables */

       IF p_archive_flag='Y' THEN

       pa_debug.debug('Inserting Records into pa_schedules_AR table  ') ;
       x_err_stage := 'Inserting Records into pa_schedules_AR table for schedule id '||to_char(l_schedule_id) ;

       INSERT INTO PA_SCHEDULES_AR
                       (PURGE_BATCH_ID,
 			PURGE_RELEASE,
 			PURGE_PROJECT_ID,
 			SCHEDULE_ID,
 			CALENDAR_ID,
 			ASSIGNMENT_ID,
 			PROJECT_ID,
 			SCHEDULE_TYPE_CODE,
 			STATUS_CODE,
 			START_DATE,
 			END_DATE,
 			MONDAY_HOURS,
 			TUESDAY_HOURS,
 			WEDNESDAY_HOURS,
 			THURSDAY_HOURS,
 			FRIDAY_HOURS,
 			SATURDAY_HOURS,
 			SUNDAY_HOURS,
 			REQUEST_ID,
 			PROGRAM_APPLICATION_ID,
 			PROGRAM_ID,
 			PROGRAM_UPDATE_DATE,
 			CREATION_DATE,
 			CREATED_BY,
 			LAST_UPDATE_DATE,
 			LAST_UPDATE_BY,
 			LAST_UPDATE_LOGIN,
 			FORECAST_TXN_VERSION_NUMBER,
 			FORECAST_TXN_GENERATED_FLAG)

                 SELECT p_purge_batch_id,
                       	p_Purge_Release,
 			p_Project_Id,
 			Schedule_Id,
 			Calendar_Id,
 			Assignment_Id,
 			Project_Id,
 			Schedule_Type_Code,
 			Status_Code,
 			Start_Date,
 			End_Date,
 			Monday_Hours,
 			Tuesday_Hours,
 			Wednesday_Hours,
 			Thursday_Hours,
 			Friday_Hours,
 			Saturday_Hours,
 			Sunday_Hours,
 			Request_Id,
 			Program_Application_Id,
 			Program_Id,
 			Program_Update_Date,
 			Creation_Date,
 			Created_By,
 			Last_Update_Date,
 			Last_Update_By,
 			Last_Update_Login,
 			Forecast_Txn_Version_Number,
 			Forecast_Txn_Generated_Flag
                FROM pa_schedules WHERE schedule_id=l_schedule_id;

        /*Increase the value of l_nos_schedule_inserted to indicate number of records inserted in schedule_ar  table.
          The value will increase for each loop*/

             l_nos_schedule_inserted := l_nos_schedule_inserted + SQL%ROWCOUNT;

       pa_debug.debug('Inserting Records into pa_schedule_except_history_AR table  ') ;
       x_err_stage := 'Inserting Records into pa_schedules_except_history_AR table for schedule id '||to_char(l_schedule_id) ;

             INSERT INTO PA_SCHEDULES_HSTRY_AR
                       (PURGE_BATCH_ID,
 			PURGE_RELEASE,
			PURGE_PROJECT_ID,
 			SCHEDULE_ID,
 			CALENDAR_ID,
 			ASSIGNMENT_ID,
 			PROJECT_ID,
 			SCHEDULE_TYPE_CODE,
 			STATUS_CODE,
 			START_DATE,
 			END_DATE,
 			MONDAY_HOURS,
 			TUESDAY_HOURS,
 			WEDNESDAY_HOURS,
 			THURSDAY_HOURS,
 			FRIDAY_HOURS,
 			SATURDAY_HOURS,
 			SUNDAY_HOURS,
 			CHANGE_ID,
 			LAST_APPROVED_FLAG,
 			REQUEST_ID,
 			PROGRAM_APPLICATION_ID,
 			PROGRAM_ID,
 			PROGRAM_UPDATE_DATE,
 			CREATION_DATE,
 			CREATED_BY,
 			LAST_UPDATE_DATE,
 			LAST_UPDATE_BY,
 			LAST_UPDATE_LOGIN)

                SELECT  p_purge_batch_id,
                        p_purge_release,
                        p_project_id,
                        Schedule_Id,
 			Calendar_Id,
 			Assignment_Id,
 			Project_Id,
 			Schedule_Type_Code,
 			Status_Code,
 			Start_Date,
 			End_Date,
 			Monday_Hours,
 			Tuesday_Hours,
 			Wednesday_Hours,
 			Thursday_Hours,
 			Friday_Hours,
 			Saturday_Hours,
 			Sunday_Hours,
 			Change_Id,
 			Last_Approved_Flag,
 			Request_Id,
 			Program_Application_Id,
 			Program_Id,
 			Program_Update_Date,
 			Creation_Date,
 			Created_By,
 			Last_Update_Date,
 			Last_Update_By,
 			Last_Update_Login
                FROM pa_schedules_history WHERE schedule_id=l_schedule_id;

        /*Increase the value of l_nos_schedule_his_inserted to indicate number of records inserted in schedule_history_ar
          table. The value will increase for each loop*/

             l_nos_schedule_his_inserted := l_nos_schedule_his_inserted + SQL%ROWCOUNT;

       END IF;

          /*To keep the count of no os records deleted from pa_forecast_items and pa_forecast_item_details, manipulate the
            count of l_nos_of fi_deleted and l_nos_fis_deleted. */

             pa_debug.debug('Deleting Records from  pa_schedule_history table  ') ;
             x_err_stage := 'Deleting Records from  pa_schedules_history table for id '||to_char(l_schedule_id) ;

            DELETE PA_SCHEDULES_HISTORY
            WHERE schedule_id =l_schedule_id;

            l_nos_schedule_his_deleted :=l_nos_schedule_his_deleted + SQL%ROWCOUNT;

            pa_debug.debug('Deleting Records from  pa_schedules table  ') ;
            x_err_stage := 'Deleting Records from  pa_schedules table for id '||to_char(l_schedule_id) ;


            DELETE PA_SCHEDULES
            WHERE schedule_id=l_schedule_id;

           l_nos_schedule_deleted :=l_nos_schedule_deleted + SQL%ROWCOUNT;


      END LOOP;
     CLOSE Cur_schedules;

     pa_debug.debug(' Fetching schedule exception records for assignments Id passed. ') ;
     x_err_stage := 'Fetching  schedule exception records for Assignment '||to_char(l_assignment_id) ;

     OPEN cur_schedule_except(l_assignment_id);
      LOOP
       FETCH cur_schedule_except  INTO l_schedule_exception_id;
       IF cur_schedule_except%NOTFOUND THEN
         EXIT;
       END IF;

       /* If archive flag is YES, archiving of data needs to be done. Insert data into correspodning AR tables */

       IF p_archive_flag='Y' THEN

       pa_debug.debug('inserting records into  pa_schedules_except_history_ar  table  ') ;
       x_err_stage := 'Inserting Records into pa_schedules_except_history_AR table for schedule id '||to_char(l_schedule_id) ;

         INSERT INTO PA_SCH_EXCPT_HSTRY_AR
                       (PURGE_BATCH_ID,
 			PURGE_RELEASE,
 			PURGE_PROJECT_ID,
 			SCHEDULE_EXCEPTION_ID,
			CALENDAR_ID,
 			ASSIGNMENT_ID,
 			PROJECT_ID,
 			SCHEDULE_TYPE_CODE,
 			STATUS_CODE,
 			EXCEPTION_TYPE_CODE,
 			RESOURCE_CALENDAR_PERCENT,
 			NON_WORKING_DAY_FLAG,
 			CHANGE_HOURS_TYPE_CODE,
 			START_DATE,
 			END_DATE,
 			MONDAY_HOURS,
 			TUESDAY_HOURS,
 			WEDNESDAY_HOURS,
 			THURSDAY_HOURS,
 			FRIDAY_HOURS,
 			SATURDAY_HOURS,
 			SUNDAY_HOURS ,
 			CREATION_DATE,
 			CREATED_BY,
 			LAST_UPDATE_DATE,
 			LAST_UPDATE_BY,
 			LAST_UPDATE_LOGIN,
 			CHANGE_ID,
 			DURATION_SHIFT_TYPE_CODE,
 			DURATION_SHIFT_UNIT_CODE,
 			NUMBER_OF_SHIFT,
 			CHANGE_CALENDAR_TYPE_CODE,
 			CHANGE_CALENDAR_ID)

              SELECT    p_purge_batch_id,
                        p_purge_release,
                        p_project_id,
                        schedule_Exception_Id,
			Calendar_Id,
 			Assignment_Id,
 			Project_Id,
 			Schedule_Type_Code,
 			Status_Code,
 			Exception_Type_Code,
 			Resource_Calendar_Percent,
 			Non_Working_Day_Flag,
 			Change_Hours_Type_Code,
 			Start_Date,
 			End_Date,
 			Monday_Hours,
 			Tuesday_Hours,
 			Wednesday_Hours,
 			Thursday_Hours,
 			Friday_Hours,
 			Saturday_Hours,
 			Sunday_Hours ,
 			Creation_Date,
 			Created_By,
 			Last_Update_Date,
 			Last_Update_By,
 			Last_Update_Login,
 			Change_Id,
 			Duration_Shift_Type_Code,
 			Duration_Shift_Unit_Code,
 			Number_Of_Shift,
 			Change_Calendar_Type_Code,
 			Change_Calendar_Id
                 FROM pa_schedule_except_history WHERE schedule_exception_id=l_schedule_exception_id;

        /*Increase the value of l_nos_schedule_his_inserted to indicate number of records inserted inschedule_except_history_ar
          table. The value will increase for each loop*/

             l_nos_schedule_exp_inserted := l_nos_schedule_exp_inserted + SQL%ROWCOUNT;

       END IF;

          /*To keep the count of no os records deleted from pa_schedules_except_history , manipulate the
            count of l_nos_schedule_exp_deleted . */

             pa_debug.debug('Deleting Records from  pa_scheduleexcept_history table  ') ;
             x_err_stage := 'Deleting Records from  pa_schedules_except_history table for id '||to_char(l_schedule_exception_id) ;

            DELETE PA_SCHEDULE_EXCEPT_HISTORY
            WHERE schedule_exception_id =l_schedule_exception_id;

            l_nos_schedule_exp_deleted := l_nos_schedule_exp_deleted + SQL%ROWCOUNT;
      END LOOP;
     Close cur_schedule_except;

  END LOOP;

/*After "deleting" or "deleting and inserting" a set of records the transaction is commited. This also creates a record in
  the Pa_Purge_Project_details, which will show the no. of records that are purged from each table.
 The procedure is called pa_schedules, pa_schedule_except_history and pa_schedules_history tables */

  	pa_purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_SCHEDULES',
	                       l_nos_schedule_inserted,
	                       l_nos_schedule_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

       	pa_purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_SCHEDULES_HISTORY',
	                       l_nos_schedule_his_inserted,
	                       l_nos_schedule_his_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

        pa_purge.CommitProcess(p_purge_batch_id,
                               p_project_id,
                               'PA_SCHEDULE_EXCEPT_HISTORY',
                               l_nos_schedule_exp_inserted,
                               l_nos_schedule_exp_deleted,
                               x_err_code,
                               x_err_stack,
                               x_err_stage
                               ) ;


  x_err_stack := l_old_err_stack; -- Added for bug 4227589

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
      RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_PJR_TXNS.PA_SCHEDULES_PURGE' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;


end Pa_schedules_purge;


-- Start of comments
-- API name         : PA_CANDIDATES_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records from PA_CANDIDATES and PA_CANDIDATE_REVIEWS table


Procedure PA_CANDIDATES_PURGE ( p_purge_batch_id                 in NUMBER,
                                p_project_id                     in NUMBER,
                                p_purge_release                  in VARCHAR2,
                                p_assignment_id_tab              in PA_PLSQL_DATATYPES.IdTabTyp,
                                p_archive_flag                   in VARCHAR2,
                                x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_err_code                       in OUT NOCOPY NUMBER)   IS  --File.Sql.39 bug 4440895


    l_candidate_id                       pa_candidates.candidate_id%TYPE;
    I                                    PLS_INTEGER;
    l_assignment_id                      pa_forecast_items.assignment_id%TYPE;
    l_nos_candidate_inserted             NUMBER ;
    l_nos_candidate_rev_inserted         NUMBER ;
    l_nos_candidate_deleted              NUMBER ;
    l_nos_candidate_rev_deleted          NUMBER ;

    CURSOR Cur_candidates (x_assignment_id In NUMBER)  IS
    SELECT candidate_id from pa_candidates
    WHERE assignment_id =x_assignment_id;

    l_old_err_stack        VARCHAR2(2000); -- Added for bug 4227589

Begin

  l_old_err_stack := x_err_stack;  -- Added for bug 4227589

  x_err_stack := x_err_stack || ' ->Before call to purge candidates  records ';

/*Initialize the no of record variables for each call */

  pa_debug.debug(' Inside Procedure to purge candidates and candidate review log ') ;
  x_err_stage := 'Inside Procedure to purge candidates and candidate review log fro project '||to_char(p_project_id) ;

  l_nos_candidate_inserted     :=0;
  l_nos_candidate_rev_inserted :=0;
  l_nos_candidate_deleted      :=0;
  l_nos_candidate_rev_deleted  :=0;

     -----------------Begin Logic added to purge data from Workflow related tables-----------------
         /* Call  Workflow API to archive/purge data from pa_wf_processes and detail table
            and also from pa_wf_ntf_performers table*/

         Pa_Debug.DEBUG(' About to purge workflow process and details ') ;
         x_err_stage := 'About to purge workflow data for project '||TO_CHAR(p_project_id) ;

         Pa_Purge_Pjr_Txns.pa_wf_purge ( p_purge_batch_id     =>p_purge_batch_id,
                                         p_project_id         =>p_project_id,
                                         p_purge_release      =>p_purge_release,
                                         p_entity_key_tab     =>p_assignment_id_tab,
                                         p_wf_type_code       =>'CANDIDATE',
                                         p_item_type          =>'PACANDID',
                                         p_archive_flag       =>p_archive_flag,
                                         x_err_stack          =>x_err_stack,
                                         x_err_stage          =>x_err_stage,
                                         x_err_code           =>x_err_code);

     -----------------End of Logic added to purge data from Workflow related tables-----------------

  /* Fetch the assignments from  assignment tab. */

   FOR I in p_assignment_id_tab.FIRST .. p_assignment_id_tab.LAST LOOP
     l_assignment_id :=p_assignment_id_tab(I);

     pa_debug.debug(' Fetching schedule records for assignments Id passed. ') ;
     x_err_stage := 'Fetching  schedule records for Assignment '||to_char(l_assignment_id) ;

     OPEN cur_candidates(l_assignment_id);
      LOOP
       FETCH cur_candidates  INTO l_candidate_id;
       IF cur_candidates%NOTFOUND THEN
         EXIT;
       END IF;

       /* If archive flag is YES, archiving of data needs to be done. Insert data into correspodning AR tables */

       IF p_archive_flag='Y' THEN

      pa_debug.debug('Inserting Records into pa_candidates_AR table  ') ;
      x_err_stage := 'Inserting Records into pa_candidates_AR table for candidate id '||to_char(l_candidate_id) ;

          INSERT INTO PA_CANDIDATES_AR
                      ( PURGE_BATCH_ID,
			PURGE_RELEASE,
			PURGE_PROJECT_ID,
			CANDIDATE_ID,
 			ASSIGNMENT_ID,
 			RESOURCE_ID,
 			RECORD_VERSION_NUMBER,
 			STATUS_CODE,
 			NOMINATED_BY_PERSON_ID,
 			NOMINATION_DATE,
 			NOMINATION_COMMENTS,
 			CANDIDATE_RANKING,
 			ATTRIBUTE_CATEGORY,
 			ATTRIBUTE1,
 			ATTRIBUTE2,
 			ATTRIBUTE3,
 			ATTRIBUTE4,
 			ATTRIBUTE5,
 			ATTRIBUTE6,
 			ATTRIBUTE7,
 			ATTRIBUTE8,
 			ATTRIBUTE9,
 			ATTRIBUTE10,
 			ATTRIBUTE11,
 			ATTRIBUTE12,
 			ATTRIBUTE13,
 			ATTRIBUTE14,
 			ATTRIBUTE15,
 			CREATION_DATE,
 			CREATED_BY,
 			LAST_UPDATE_DATE,
 			LAST_UPDATED_BY,
 			LAST_UPDATE_LOGIN)

                SELECT  p_purge_batch_id,
                        p_purge_release,
                        p_project_id,
                        Candidate_Id,
 			Assignment_Id,
 			Resource_Id,
 			Record_Version_Number,
 			Status_Code,
 			Nominated_By_Person_Id,
 			Nomination_Date,
 			Nomination_Comments,
 			Candidate_Ranking,
 			Attribute_Category,
 			Attribute1,
 			Attribute2,
 			Attribute3,
 			Attribute4,
 			Attribute5,
 			Attribute6,
 			Attribute7,
 			Attribute8,
 			Attribute9,
 			Attribute10,
 			Attribute11,
 			Attribute12,
 			Attribute13,
 			Attribute14,
 			Attribute15,
 			Creation_Date,
 			Created_By,
 			Last_Update_Date,
 			Last_Updated_By,
 			Last_Update_Login
               FROM PA_CANDIDATES  WHERE candidate_id=l_candidate_id;

     /*Increase the value of l_nos_candidate_inserted to indicate number of records inserted in candidates_ar  table.
       The value will increase for each loop*/

             l_nos_candidate_inserted := l_nos_candidate_inserted + SQL%ROWCOUNT;

       pa_debug.debug('Inserting Records into pa_candidate_reviews_AR table  ') ;
       x_err_stage := 'Inserting Records into pa_candidate_reviews_AR  table for candidate  id '||to_char(l_candidate_id) ;

           INSERT INTO PA_CANDIDATES_REV_AR
                       (PURGE_BATCH_ID,
 			PURGE_RELEASE,
 			PURGE_PROJECT_ID,
 			CANDIDATE_REVIEW_ID,
 			CANDIDATE_ID,
 			RECORD_VERSION_NUMBER,
 			STATUS_CODE,
 			REVIEWER_PERSON_ID,
 			REVIEW_DATE,
 			CHANGE_REASON_CODE,
 			REVIEW_COMMENTS,
 			ATTRIBUTE_CATEGORY,
 			ATTRIBUTE1,
 			ATTRIBUTE2,
 			ATTRIBUTE3,
 			ATTRIBUTE4,
 			ATTRIBUTE5,
 			ATTRIBUTE6,
 			ATTRIBUTE7,
 			ATTRIBUTE8,
 			ATTRIBUTE9,
 			ATTRIBUTE10,
 			ATTRIBUTE11,
 			ATTRIBUTE12,
 			ATTRIBUTE13,
 			ATTRIBUTE14,
 			ATTRIBUTE15,
 			CREATION_DATE,
 			CREATED_BY,
 			LAST_UPDATE_DATE,
 			LAST_UPDATED_BY,
 			LAST_UPDATE_LOGIN)

                SELECT  p_purge_batch_id,
                        p_purge_release,
                        p_project_id,
                        Candidate_Review_Id,
 			Candidate_Id,
 			Record_Version_Number,
 			Status_Code,
 			Reviewer_Person_Id,
 			Review_Date,
 			Change_Reason_Code,
 			Review_Comments,
 			Attribute_Category,
 			Attribute1,
 			Attribute2,
 			Attribute3,
 			Attribute4,
 			Attribute5,
 			Attribute6,
 			Attribute7,
 			Attribute8,
 			Attribute9,
 			Attribute10,
 			Attribute11,
 			Attribute12,
 			Attribute13,
 			Attribute14,
 			Attribute15,
 			Creation_Date,
 			Created_By,
 			Last_Update_Date,
 			Last_Updated_By,
 			Last_Update_Login
                FROM PA_CANDIDATE_REVIEWS WHERE candidate_id = l_candidate_id;

        /*Increase the value of l_nos_candidate_rev_inserted to indicate number of records inserted in candidate_reviews_ar
          table. The value will increase for each loop*/

             l_nos_candidate_rev_inserted := l_nos_candidate_rev_inserted + SQL%ROWCOUNT;

       END IF;

          /*To keep the count of no os records deleted from pa_candidates and pa_candidate_reviews, manipulate the
            count of l_nos_candidate_deleted and l_nos_candidate_rev_deleted. */

             pa_debug.debug('Deleting Records from  pa_candidate_reviews table  ') ;
             x_err_stage := 'Deleting Records from  pa_candidate_reviews table for id '||to_char(l_candidate_id) ;

            DELETE PA_CANDIDATE_REVIEWS
            WHERE candidate_id =l_candidate_id;

            l_nos_candidate_rev_deleted :=l_nos_candidate_rev_deleted + SQL%ROWCOUNT;

            pa_debug.debug('Deleting Records from  pa_candidates table  ') ;
             x_err_stage := 'Deleting Records from  pa_candidates table for id '||to_char(l_candidate_id) ;

            DELETE PA_CANDIDATES
            WHERE candidate_id =l_candidate_id;

            l_nos_candidate_deleted :=l_nos_candidate_deleted + SQL%ROWCOUNT;

      END LOOP;

     CLOSE Cur_candidates;

  END LOOP;

  /*After "deleting" or "deleting and inserting" a set of records the transaction is commited. This also creates a record in
    the Pa_Purge_Project_details, which will show the no. of records that are purged from each table.
    The procedure is called pa_schedules, pa_schedule_except_history and pa_schedules_history tables */

        pa_purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_CANDIDATES',
	                       l_nos_candidate_inserted,
	                       l_nos_candidate_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

       	pa_purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_CANDIDATE_REVIEWS',
	                       l_nos_candidate_rev_inserted,
	                       l_nos_candidate_rev_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

    x_err_stack := l_old_err_stack; -- Added for bug 4227589

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_PJR_TXNS.PA_CANDIDATES_PURGE');
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

End pa_candidates_purge;


-- Start of comments
-- API name         : PA_ASSIGNMENT_CONFLICTS_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records from PA_ASSIGNMENT_CONFLICT_HIST  table


Procedure PA_ASSIGNMENT_CONFLICTS_PURGE ( p_purge_batch_id                 in NUMBER,
                                          p_project_id                     in NUMBER,
                                          p_purge_release                  in VARCHAR2,
                                          p_assignment_id_tab              in PA_PLSQL_DATATYPES.IdTabTyp,
                                          p_archive_flag                   in VARCHAR2,
                                          x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                          x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                          x_err_code                       in OUT NOCOPY NUMBER ) IS --File.Sql.39 bug 4440895

    l_assignment_id                      pa_forecast_items.assignment_id%TYPE;
    l_nos_conflicts_inserted             NUMBER ;
    l_nos_conflicts_deleted              NUMBER ;

   ----------------------------------------------------------------------------------
   -- Cursor to fetch all the conflicting projects based on the assignment_id passed.
   -- Added for Bug 2979944
   ----------------------------------------------------------------------------------
    CURSOR c1 (x_assignment_id   pa_project_assignments.assignment_id%TYPE) IS
    SELECT DISTINCT asgn.project_id
      FROM pa_project_assignments asgn,
           pa_assignment_conflict_hist hist
     WHERE asgn.assignment_id = hist.conflict_assignment_id
       AND hist.assignment_id = x_assignment_id;

    l_project_id_tab                  Pa_Plsql_Datatypes.IdTabTyp;
    l_count                           NUMBER;
    l_overcommitment_flag             VARCHAR2(1) := 'N';

   ----------------------------------------------------------------------------------

    l_old_err_stack        VARCHAR2(2000); -- Added for bug 4227589

Begin

l_old_err_stack := x_err_stack;  -- Added for bug 4227589

x_err_stack := x_err_stack || ' ->Before call to purge assignment conflicts  records ';

/*Initialize the no of record variables for each call */

  pa_debug.debug(' Inside Procedure to purge assignment conflicts records ') ;
  x_err_stage := 'Start  purging assignment conflicts for project '||to_char(p_project_id) ;

         l_nos_conflicts_inserted :=0;
         l_nos_conflicts_deleted  :=0;


  FOR I in p_assignment_id_tab.FIRST .. p_assignment_id_tab.LAST LOOP
     l_assignment_id :=p_assignment_id_tab(I);

  -----------------------------------------------------------------------------------------------
   -- Added for Bug 2979944

      FOR j IN c1(l_assignment_id) LOOP

         l_overcommitment_flag := 'Y';

         l_count := l_project_id_tab.COUNT + 1;

         l_project_id_tab(l_count) := j.project_id;

      END LOOP;
  -----------------------------------------------------------------------------------------------

     pa_debug.debug(' Fetching conflicts records for assignments Id passed. ') ;
     x_err_stage := 'Fetching  conflicts records for Assignment '||to_char(l_assignment_id) ;

   IF p_archive_flag='Y' THEN

    INSERT INTO PA_ASGMT_CNFLT_HIST_AR
                       (PURGE_BATCH_ID,
 			PURGE_RELEASE,
 			PURGE_PROJECT_ID,
 			CONFLICT_GROUP_ID,
 			ASSIGNMENT_ID,
 			CONFLICT_ASSIGNMENT_ID,
 			RESOLVE_CONFLICTS_ACTION_CODE,
 			INTRA_TXN_CONFLICT_FLAG,
 			PROCESSED_FLAG,
 			SELF_CONFLICT_FLAG,
 			CREATION_DATE,
 			CREATED_BY,
 			LAST_UPDATE_DATE,
 			LAST_UPDATED_BY,
 			LAST_UPDATE_LOGIN)

                SELECT  P_purge_batch_id,
                        P_purge_release,
                        P_project_id,
                        Conflict_Group_Id,
 			Assignment_Id,
			Conflict_Assignment_Id,
 			Resolve_Conflicts_Action_Code,
 			Intra_Txn_Conflict_Flag,
 			Processed_Flag,
 			Self_Conflict_Flag,
 			Creation_Date,
 			Created_By,
 			Last_Update_Date,
 			Last_Updated_By,
 			Last_Update_Login
                FROM   PA_ASSIGNMENT_CONFLICT_HIST WHERE assignment_id = l_assignment_id;

        /*Increase the value of l_nos_conflicts_inserted to indicate number of records inserted in assignment_conflict_hist
          table. The value will increase for each loop*/

             l_nos_conflicts_inserted := l_nos_conflicts_inserted + SQL%ROWCOUNT;

      END IF;

          /*To keep the count of no of records deleted from pa_assignment_conflict_hist, manipulate the
            count of l_nos_conflicts. */

             pa_debug.debug('Deleting Records from  pa_assignment_conflict_hist table  ') ;
             x_err_stage := 'Deleting Records from  pa_assignment_conflict_hist table for id '||to_char(l_assignment_id) ;

            DELETE PA_ASSIGNMENT_CONFLICT_HIST
            WHERE assignment_id =l_assignment_id;

            l_nos_conflicts_deleted :=l_nos_conflicts_deleted + SQL%ROWCOUNT;
  END LOOP;

/*After "deleting" or "deleting and inserting" a set of records the transaction is commited. This also creates a record in
  the Pa_Purge_Project_details, which will show the no. of records that are purged from each table.
 The procedure is called pa_schedules, pa_schedule_except_history and pa_schedules_history tables */

  	pa_purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_ASSIGNMENT_CONFLICT_HIST',
	                       l_nos_conflicts_inserted,
	                       l_nos_conflicts_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage);

     -----------------Begin Logic added to purge data from Workflow related tables-----------------

     IF l_overcommitment_flag = 'Y' THEN

         /* Call  Workflow API to archive/purge data from pa_wf_processes and detail table
            and also from pa_wf_ntf_performers table*/

         Pa_Debug.DEBUG(' About to purge workflow process and details ') ;
         x_err_stage := 'About to purge workflow data for project '||TO_CHAR(p_project_id) ;

         Pa_Purge_Pjr_Txns.pa_wf_purge ( p_purge_batch_id     =>p_purge_batch_id,
                                         p_project_id         =>p_project_id,
                                         p_purge_release      =>p_purge_release,
                                         p_entity_key_tab     =>l_project_id_tab,
                                         p_wf_type_code       =>'OVERCOMMITMENT',
                                         p_item_type          =>'PAROVCNT',
                                         p_archive_flag       =>p_archive_flag,
                                         x_err_stack          =>x_err_stack,
                                         x_err_stage          =>x_err_stage,
                                         x_err_code           =>x_err_code);

     END IF;

         /* Call  Workflow API to archive/purge data from pa_wf_processes table*/

         Pa_Debug.DEBUG(' About to purge workflow process ') ;
         x_err_stage := 'About to purge workflow data for project '||TO_CHAR(p_project_id) ;

         Pa_Purge_Pjr_Txns.pa_wf_key_purge ( p_purge_batch_id     =>p_purge_batch_id,
                                             p_project_id         =>p_project_id,
                                             p_purge_release      =>p_purge_release,
                                             p_entity_key2        =>'SELF_OVERCOMMITMENT',
                                             p_wf_type_code       =>'OVERCOMMITMENT',
                                             p_item_type          =>'PAROVCNT',
                                             p_archive_flag       =>p_archive_flag,
                                             x_err_stack          =>x_err_stack,
                                             x_err_stage          =>x_err_stage,
                                             x_err_code           =>x_err_code);

     -----------------End of Logic added to purge data from Workflow related tables-----------------

    x_err_stack := l_old_err_stack; -- Added for bug 4227589
EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
      RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_PJR_TXNS.PA_ASSIGNMENT_CONFLICTS_PURGE' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
   PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

end PA_ASSIGNMENT_CONFLICTS_PURGE;



-- Start of comments
-- API name         : PA_PROJECT_ASSIGNMENT_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records from PA_PROJECT_ASSIGNMENTS  table


Procedure PA_PROJECT_ASSIGNMENT_PURGE   ( p_purge_batch_id                 in NUMBER,
                                          p_project_id                     in NUMBER,
                                          p_purge_release                  in VARCHAR2,
                                          p_assignment_id_tab              in PA_PLSQL_DATATYPES.IdTabTyp,
                                          p_archive_flag                   in VARCHAR2,
                                          x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                          x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                          x_err_code                       in OUT NOCOPY NUMBER )  IS --File.Sql.39 bug 4440895


    l_assignment_id                      pa_forecast_items.assignment_id%TYPE;
    l_nos_assignments_inserted           NUMBER ;
    l_nos_assignments_his_inserted       NUMBER ;
    l_nos_assignments_deleted            NUMBER ;
    l_nos_assignments_his_deleted        NUMBER ;
    l_old_err_stack                      VARCHAR2(2000); -- Added for bug 4227589

BEGIN

l_old_err_stack := x_err_stack;  -- Added for bug 4227589

x_err_stack := x_err_stack || ' ->Before call to purge assignments records ';

/*Initialize the no of record variables for each call */

  pa_debug.debug(' Inside Procedure to purge assignments records ') ;
  x_err_stage := 'Start  purging assignments for project '||to_char(p_project_id) ;

    l_nos_assignments_inserted      :=0;
    l_nos_assignments_his_inserted  :=0;
    l_nos_assignments_deleted       :=0;
    l_nos_assignments_his_deleted   :=0;

     -----------------Begin Logic added to purge data from Workflow related tables-----------------
         /* Call  Workflow API to archive/purge data from pa_wf_processes and detail table */

         Pa_Debug.DEBUG(' About to purge workflow process and details ') ;
         x_err_stage := 'About to purge workflow data for project '||TO_CHAR(p_project_id) ;

         Pa_Purge_Pjr_Txns.pa_wf_mass_purge ( p_purge_batch_id     =>p_purge_batch_id,
                                              p_project_id         =>p_project_id,
                                              p_purge_release      =>p_purge_release,
                                              p_object_id_tab      =>p_assignment_id_tab,
                                              p_item_type          =>'PARMATRX',
                                              p_archive_flag       =>p_archive_flag,
                                              x_err_stack          =>x_err_stack,
                                              x_err_stage          =>x_err_stage,
                                              x_err_code           =>x_err_code);

         /* Call  Workflow API to archive/purge data from pa_wf_processes and detail table
            and also from pa_wf_ntf_performers table*/

         Pa_Debug.DEBUG(' About to purge workflow process and details ') ;
         x_err_stage := 'About to purge workflow data for project '||TO_CHAR(p_project_id) ;

         Pa_Purge_Pjr_Txns.pa_wf_purge ( p_purge_batch_id     =>p_purge_batch_id,
                                         p_project_id         =>p_project_id,
                                         p_purge_release      =>p_purge_release,
                                         p_entity_key_tab     =>p_assignment_id_tab,
                                         p_wf_type_code       =>'ASSIGNMENT_APPROVAL',
                                         p_item_type          =>'PAWFAAP',
                                         p_archive_flag       =>p_archive_flag,
                                         x_err_stack          =>x_err_stack,
                                         x_err_stage          =>x_err_stage,
                                         x_err_code           =>x_err_code);

         /* Call  Workflow API to archive/purge data from pa_wf_processes table*/

         Pa_Debug.DEBUG(' About to purge workflow process and details ') ;
         x_err_stage := 'About to purge workflow data for project '||TO_CHAR(p_project_id) ;

         Pa_Purge_Pjr_Txns.pa_wf_key_purge ( p_purge_batch_id     =>p_purge_batch_id,
                                             p_project_id         =>p_project_id,
                                             p_purge_release      =>p_purge_release,
                                             p_entity_key2        =>'0',
                                             p_wf_type_code       =>'APPLY_TEAM_TEMPLATE',
                                             p_item_type          =>'PARAPTEM',
                                             p_archive_flag       =>p_archive_flag,
                                             x_err_stack          =>x_err_stack,
                                             x_err_stage          =>x_err_stage,
                                             x_err_code           =>x_err_code);

         /* Call  Workflow API to archive/purge data from pa_wf_processes table*/

         Pa_Debug.DEBUG(' About to purge workflow process and details ') ;
         x_err_stage := 'About to purge workflow data for project '||TO_CHAR(p_project_id) ;

         Pa_Purge_Pjr_Txns.pa_wf_mass_asgn_purge ( p_purge_batch_id     =>p_purge_batch_id,
                                                   p_project_id         =>p_project_id,
                                                   p_purge_release      =>p_purge_release,
                                                   p_object_id_tab      =>p_assignment_id_tab,
                                                   p_wf_type_code       =>'MASS_ASSIGNMENT_APPROVAL',
                                                   p_archive_flag       =>p_archive_flag,
                                                   x_err_stack          =>x_err_stack,
                                                   x_err_stage          =>x_err_stage,
                                                   x_err_code           =>x_err_code);

     -----------------End of Logic added to purge data from Workflow related tables-----------------

  FOR I in p_assignment_id_tab.FIRST .. p_assignment_id_tab.LAST LOOP
     l_assignment_id :=p_assignment_id_tab(I);

         IF p_archive_flag='Y' THEN
           pa_debug.debug('Inserting Records into pa_project_asgmts_AR table  ') ;
           x_err_stage := 'Inserting Records into pa_project_asgmts_AR table for assignment  id '||to_char(l_assignment_id) ;

               INSERT INTO PA_PROJECT_ASGMTS_AR
                     ( 	PURGE_BATCH_ID,
 			PURGE_RELEASE,
 			PURGE_PROJECT_ID,
 			ASSIGNMENT_ID,
 			ASSIGNMENT_NAME,
 			ASSIGNMENT_TYPE,
 			MULTIPLE_STATUS_FLAG,
 			RECORD_VERSION_NUMBER,
 			STATUS_CODE,
 			PROJECT_ID,
 			PROJECT_ROLE_ID,
 			RESOURCE_ID,
 			PROJECT_PARTY_ID,
 			DESCRIPTION,
 			START_DATE,
 			END_DATE,
 			ASSIGNMENT_EFFORT,
 			EXTENSION_POSSIBLE,
 			SOURCE_ASSIGNMENT_ID,
 			ASSIGNMENT_TEMPLATE_ID,
 			MIN_RESOURCE_JOB_LEVEL,
 			MAX_RESOURCE_JOB_LEVEL,
 			ASSIGNMENT_NUMBER,
 			ADDITIONAL_INFORMATION,
 			WORK_TYPE_ID,
 			REVENUE_CURRENCY_CODE,
 			REVENUE_BILL_RATE,
 			EXPENSE_OWNER,
 			EXPENSE_LIMIT,
 			EXPENSE_LIMIT_CURRENCY_CODE,
 			FCST_TP_AMOUNT_TYPE,
 			FCST_JOB_ID,
 			LOCATION_ID,
 			CALENDAR_TYPE,
 			CALENDAR_ID,
 			RESOURCE_CALENDAR_PERCENT,
 			ATTRIBUTE_CATEGORY,
 			ATTRIBUTE1,
 			ATTRIBUTE2,
 			ATTRIBUTE3,
 			ATTRIBUTE4,
 			ATTRIBUTE5,
 			ATTRIBUTE6,
 			ATTRIBUTE7,
 			ATTRIBUTE8,
 			ATTRIBUTE9,
 			ATTRIBUTE10,
 			ATTRIBUTE11,
 			ATTRIBUTE12,
 			ATTRIBUTE13,
 			ATTRIBUTE14,
 			ATTRIBUTE15 ,
 			CREATION_DATE,
 			CREATED_BY,
 			LAST_UPDATE_DATE,
 			LAST_UPDATED_BY,
 			LAST_UPDATE_LOGIN,
 			PENDING_APPROVAL_FLAG,
 			FCST_JOB_GROUP_ID,
 			EXPENDITURE_ORG_ID,
 			EXPENDITURE_ORGANIZATION_ID,
 			EXPENDITURE_TYPE_CLASS,
 			EXPENDITURE_TYPE,
 			APPRVL_STATUS_CODE,
 			NOTE_TO_APPROVER,
 			STAFFING_PRIORITY_CODE,
                        STAFFING_OWNER_PERSON_ID,
 			TEMPLATE_FLAG,
 			NO_OF_ACTIVE_CANDIDATES,
 			MASS_WF_IN_PROGRESS_FLAG,
 			BILL_RATE_OVERRIDE,
 			BILL_RATE_CURR_OVERRIDE,
 			MARKUP_PERCENT_OVERRIDE,
 			TP_RATE_OVERRIDE,
 			TP_CURRENCY_OVERRIDE,
 			TP_CALC_BASE_CODE_OVERRIDE,
 			TP_PERCENT_APPLIED_OVERRIDE,
 			MARKUP_PERCENT,
 			SEARCH_MIN_AVAILABILITY,
 			SEARCH_COUNTRY_CODE,
 			SEARCH_EXP_ORG_STRUCT_VER_ID,
 			SEARCH_EXP_START_ORG_ID,
 			SEARCH_MIN_CANDIDATE_SCORE,
			LAST_AUTO_SEARCH_DATE,
 			ENABLE_AUTO_CAND_NOM_FLAG,
 			COMPETENCE_MATCH_WEIGHTING,
 			AVAILABILITY_MATCH_WEIGHTING,
 			JOB_LEVEL_MATCH_WEIGHTING,
                        DISCOUNT_PERCENTAGE,  -- bug 2686889
                        RATE_DISC_REASON_CODE,
                        TRANSFER_PRICE_RATE,   --Added for bug 3051110
                        TRANSFER_PR_RATE_CURR,
			RESOURCE_LIST_MEMBER_ID)

               SELECT   P_purge_batch_id,
                        P_purge_release,
                        P_project_id,
                       	Assignment_Id,
                        Assignment_Name,
 			Assignment_Type,
 			Multiple_Status_Flag,
 			Record_Version_Number,
 			Status_Code,
 			Project_Id,
 			Project_Role_Id,
 			Resource_Id,
 			Project_Party_Id,
 			Description,
 			Start_Date,
 			End_Date,
 			Assignment_Effort,
 			Extension_Possible,
 			Source_Assignment_Id,
 			Assignment_Template_Id,
 			Min_Resource_Job_Level,
 			Max_Resource_Job_Level,
 			Assignment_Number,
 			Additional_Information,
 			Work_Type_Id,
 			Revenue_Currency_Code,
 			Revenue_Bill_Rate,
 			Expense_Owner,
 			Expense_Limit,
 			Expense_Limit_Currency_Code,
 			Fcst_Tp_Amount_Type,
 			Fcst_Job_Id,
 			Location_Id,
 			Calendar_Type,
 			Calendar_Id,
 			Resource_Calendar_Percent,
 			Attribute_Category,
 			Attribute1,
 			Attribute2,
 			Attribute3,
 			Attribute4,
 			Attribute5,
 			Attribute6,
 			Attribute7,
 			Attribute8,
 			Attribute9,
 			Attribute10,
 			Attribute11,
 			Attribute12,
 			Attribute13,
 			Attribute14,
 			Attribute15 ,
 			Creation_Date,
 			Created_By,
 			Last_Update_Date,
 			Last_Updated_By,
 			Last_Update_Login,
 			Pending_Approval_Flag,
 			Fcst_Job_Group_Id,
 			Expenditure_Org_Id,
 			Expenditure_Organization_Id,
 			Expenditure_Type_Class,
 			Expenditure_Type,
 			Apprvl_Status_Code,
 			Note_To_Approver,
 			Staffing_Priority_Code,
                        Staffing_Owner_Person_Id,
 			Template_Flag,
 			No_Of_Active_Candidates,
 			Mass_Wf_In_Progress_Flag,
 			Bill_Rate_Override,
 			Bill_Rate_Curr_Override,
 			Markup_Percent_Override,
 			Tp_Rate_Override,
 			Tp_Currency_Override,
 			Tp_Calc_Base_Code_Override,
 			Tp_Percent_Applied_Override,
 			Markup_Percent,
 			Search_Min_Availability,
 			Search_Country_Code,
 			Search_Exp_Org_Struct_Ver_Id,
 			Search_Exp_Start_Org_Id,
 			Search_Min_Candidate_Score,
			Last_Auto_Search_Date,
 			Enable_Auto_Cand_Nom_Flag,
 			Competence_Match_Weighting,
 			Availability_Match_Weighting,
 			Job_Level_Match_Weighting,
                        discount_percentage,
                        rate_disc_reason_Code,
                        Transfer_price_Rate,  -- Added for bug 3051110
                        Transfer_pr_rate_curr,
			Resource_List_Member_Id
                 FROM pa_project_assignments where assignment_id=l_assignment_id;

 /*Increase the value of l_nos_assignments_inserted to indicate number of records inserted in assignments_ar table.
  The value will increase for each loop(assignment id)*/
            l_nos_assignments_inserted := l_nos_assignments_inserted + SQL%ROWCOUNT;

       pa_debug.debug('Inserting Records into pa_assignment_history ar  table  ') ;

            INSERT INTO PA_ASGMTS_HSTRY_AR
                       (PURGE_BATCH_ID,
			PURGE_RELEASE,
			PURGE_PROJECT_ID,
			ASSIGNMENT_ID,
 			ASSIGNMENT_NAME,
 			ASSIGNMENT_TYPE,
 			MULTIPLE_STATUS_FLAG,
 			RECORD_VERSION_NUMBER,
 			CHANGE_ID,
 			APPRVL_STATUS_CODE,
 			STATUS_CODE,
 			PROJECT_ID,
 			PROJECT_ROLE_ID,
 			RESOURCE_ID,
 			PROJECT_PARTY_ID,
 			DESCRIPTION,
 			NOTE_TO_APPROVER,
 			START_DATE,
 			END_DATE,
 			ASSIGNMENT_EFFORT,
 			EXTENSION_POSSIBLE,
 			SOURCE_ASSIGNMENT_ID,
 			ASSIGNMENT_TEMPLATE_ID,
 			MIN_RESOURCE_JOB_LEVEL,
 			MAX_RESOURCE_JOB_LEVEL,
 			ASSIGNMENT_NUMBER,
 			ADDITIONAL_INFORMATION,
 			WORK_TYPE_ID,
 			REVENUE_CURRENCY_CODE,
 			REVENUE_BILL_RATE,
 			EXPENSE_OWNER,
 			EXPENSE_LIMIT,
 			EXPENSE_LIMIT_CURRENCY_CODE ,
 			FCST_TP_AMOUNT_TYPE,
 			FCST_JOB_ID,
 			FCST_JOB_GROUP_ID,
 			EXPENDITURE_ORG_ID,
 			EXPENDITURE_ORGANIZATION_ID,
 			EXPENDITURE_TYPE_CLASS,
 			EXPENDITURE_TYPE,
 			LOCATION_ID,
 			CALENDAR_TYPE,
 			CALENDAR_ID,
 			RESOURCE_CALENDAR_PERCENT,
 			PENDING_APPROVAL_FLAG,
 			LAST_APPROVED_FLAG,
 			ATTRIBUTE_CATEGORY,
 			ATTRIBUTE1,
 			ATTRIBUTE2,
 			ATTRIBUTE3,
 			ATTRIBUTE4,
 			ATTRIBUTE5,
 			ATTRIBUTE6,
 			ATTRIBUTE7,
 			ATTRIBUTE8,
 			ATTRIBUTE9,
 			ATTRIBUTE10,
 			ATTRIBUTE11,
 			ATTRIBUTE12,
 			ATTRIBUTE13,
 			ATTRIBUTE14,
 			ATTRIBUTE15,
 			CREATION_DATE,
 			CREATED_BY,
 			LAST_UPDATE_DATE,
 			LAST_UPDATED_BY,
 			LAST_UPDATE_LOGIN,
 			STAFFING_PRIORITY_CODE,
                        STAFFING_OWNER_PERSON_ID,
 			PROJECT_SUBTEAM_ID,
 			NO_OF_ACTIVE_CANDIDATES,
 			TEMPLATE_FLAG,
 			COMPETENCE_MATCH_WEIGHTING,
 			AVAILABILITY_MATCH_WEIGHTING,
 			JOB_LEVEL_MATCH_WEIGHTING,
 			SEARCH_MIN_AVAILABILITY,
 			SEARCH_COUNTRY_CODE,
 			SEARCH_EXP_ORG_STRUCT_VER_ID,
 			SEARCH_EXP_START_ORG_ID,
 			SEARCH_MIN_CANDIDATE_SCORE,
 			LAST_AUTO_SEARCH_DATE,
 			ENABLE_AUTO_CAND_NOM_FLAG,
 			MASS_WF_IN_PROGRESS_FLAG,
 			BILL_RATE_OVERRIDE,
 			BILL_RATE_CURR_OVERRIDE,
 			MARKUP_PERCENT_OVERRIDE,
 			TP_RATE_OVERRIDE,
 			TP_CURRENCY_OVERRIDE,
 			TP_CALC_BASE_CODE_OVERRIDE,
 			TP_PERCENT_APPLIED_OVERRIDE,
 			MARKUP_PERCENT,
                        TRANSFER_PRICE_RATE,  -- Added for bug 3051110
                        TRANSFER_PR_RATE_CURR,
			DISCOUNT_PERCENTAGE,  -- Added for bug 3041583
			RATE_DISC_REASON_CODE) -- Added for bug 3041583
                SELECT  P_purge_batch_id,
                        p_purge_release,
                        p_project_id,
                        Assignment_Id,
 			Assignment_Name,
 			Assignment_Type,
 			Multiple_Status_Flag,
 			Record_Version_Number,
 			Change_Id,
 			Apprvl_Status_Code,
 			Status_Code,
 			Project_Id,
 			Project_Role_Id,
 			Resource_Id,
 			Project_Party_Id,
 			Description,
 			Note_To_Approver,
 			Start_Date,
 			End_Date,
 			Assignment_Effort,
 			Extension_Possible,
 			Source_Assignment_Id,
 			Assignment_Template_Id,
 			Min_Resource_Job_Level,
 			Max_Resource_Job_Level,
 			Assignment_Number,
 			Additional_Information,
 			Work_Type_Id,
 			Revenue_Currency_Code,
 			Revenue_Bill_Rate,
 			Expense_Owner,
 			Expense_Limit,
 			Expense_Limit_Currency_Code ,
 			Fcst_Tp_Amount_Type,
 			Fcst_Job_Id,
 			Fcst_Job_Group_Id,
 			Expenditure_Org_Id,
 			Expenditure_Organization_Id,
 			Expenditure_Type_Class,
 			Expenditure_Type,
 			Location_Id,
 			Calendar_Type,
 			Calendar_Id,
 			Resource_Calendar_Percent,
 			Pending_Approval_Flag,
 			Last_Approved_Flag,
 			Attribute_Category,
 			Attribute1,
 			Attribute2,
 			Attribute3,
 			Attribute4,
 			Attribute5,
 			Attribute6,
 			Attribute7,
 			Attribute8,
 			Attribute9,
 			Attribute10,
 			Attribute11,
 			Attribute12,
 			Attribute13,
 			Attribute14,
 			Attribute15,
 			Creation_Date,
 			Created_By,
 			Last_Update_Date,
 			Last_Updated_By,
 			Last_Update_Login,
 			Staffing_Priority_Code,
                        Staffing_Owner_Person_Id,
 			Project_Subteam_Id,
 			No_Of_Active_Candidates,
 			Template_Flag,
 			Competence_Match_Weighting,
 			Availability_Match_Weighting,
 			Job_Level_Match_Weighting,
 			Search_Min_Availability,
 			Search_Country_Code,
 			Search_Exp_Org_Struct_Ver_Id,
 			Search_Exp_Start_Org_Id,
 			Search_Min_Candidate_Score,
 			Last_Auto_Search_Date,
 			Enable_Auto_Cand_Nom_Flag,
 			Mass_Wf_In_Progress_Flag,
 			Bill_Rate_Override,
 			Bill_Rate_Curr_Override,
 			Markup_Percent_Override,
 			Tp_Rate_Override,
 			Tp_Currency_Override,
 			Tp_Calc_Base_Code_Override,
 			Tp_Percent_Applied_Override,
 			Markup_Percent,
                        Transfer_price_rate,  -- Added for bug 3051110
                        Transfer_pr_rate_curr,
			discount_percentage,  -- Added for bug 3041583
			rate_disc_reason_code -- Added for bug 3041583
                  From pa_assignments_history where assignment_id=l_assignment_id;

     /*Increase the value of l_assignments_his_inserted to indicate number of records inserted in assignments_history_ar
          table. The value will increase for each loop*/

             l_nos_assignments_his_inserted := l_nos_assignments_his_inserted  + SQL%ROWCOUNT;

       END IF;

          /*To keep the count of no of records deleted from pa_project_assignments and pa_assignments_history, manipulate the
            count of l_nos_assignments_deleted and l_nos_assignments_his_deleted. */

             pa_debug.debug('Deleting Records from  pa_assignments_history table  ') ;
             x_err_stage := 'Deleting Records from  pa_assignments_history table for id '||to_char(l_assignment_id) ;

            DELETE PA_ASSIGNMENTS_HISTORY
            WHERE assignment_id =l_assignment_id;

            l_nos_assignments_his_deleted :=l_nos_assignments_his_deleted + SQL%ROWCOUNT;

            pa_debug.debug('Deleting Records from  pa_assignments  table  ') ;
             x_err_stage := 'Deleting Records from  pa_assignments table for id '||to_char(l_assignment_id) ;

            DELETE PA_PROJECT_ASSIGNMENTS
            WHERE assignment_id =l_assignment_id;

            l_nos_assignments_deleted :=l_nos_assignments_deleted + SQL%ROWCOUNT;

  END LOOP;


        pa_purge.CommitProcess(p_purge_batch_id,
                               p_project_id,
                               'PA_PROJECT_ASSIGNMENTS',
                               l_nos_assignments_inserted,
                               l_nos_assignments_deleted,
                               x_err_code,
                               x_err_stack,
                               x_err_stage
                               ) ;

        pa_purge.CommitProcess(p_purge_batch_id,
                               p_project_id,
                               'PA_ASSIGNMENTS_HISTORY',
                               l_nos_assignments_his_inserted,
                               l_nos_assignments_his_deleted,
                               x_err_code,
                               x_err_stack,
                               x_err_stage
                               ) ;

    x_err_stack := l_old_err_stack; -- Added for bug 4227589

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_PJR_TXNS.PA_PROJECT_ASSIGNMENT_PURGE' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;


END PA_PROJECT_ASSIGNMENT_PURGE ;



-- Start of comments
-- API name         : PA_PROJECT_PARTIES_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records from PA_PROJECT_PARTIES table


Procedure PA_PROJECT_PARTIES_PURGE   ( p_purge_batch_id                 in NUMBER,
                                       p_project_id                     in NUMBER,
                                       p_purge_release                  in VARCHAR2,
                                       p_assignment_id_tab              in PA_PLSQL_DATATYPES.IdTabTyp,
                                       p_archive_flag                   in VARCHAR2,
                                       x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_err_code                       in OUT NOCOPY NUMBER )   IS --File.Sql.39 bug 4440895

    l_assignment_id                      pa_forecast_items.assignment_id%TYPE;
    l_nos_parties_inserted               NUMBER ;
    l_nos_parties_deleted                NUMBER ;
    l_old_err_stack                      VARCHAR2(2000); -- Added for bug 4227589

Begin

l_old_err_stack := x_err_stack;  -- Added for bug 4227589
x_err_stack := x_err_stack || ' ->Before call to purge Project Parties records ';

/*Initialize the no of record variables for each call */

  pa_debug.debug(' Inside Procedure to purge project parties records ') ;
  x_err_stage := 'Start  purging project parties records for project '||to_char(p_project_id) ;

    l_nos_parties_inserted:=0;
    l_nos_parties_deleted :=0 ;

  FOR I in p_assignment_id_tab.FIRST .. p_assignment_id_tab.LAST LOOP
     l_assignment_id :=p_assignment_id_tab(I);

         IF p_archive_flag='Y' THEN
           pa_debug.debug('Inserting Records into PA_project_parties_AR table  ') ;
           x_err_stage := 'Inserting Records into pa_project_parties_AR table for assignment  id '||to_char(l_assignment_id);

               INSERT INTO PA_PROJECT_PARTIES_AR
                       (PURGE_BATCH_ID,
 			PURGE_RELEASE,
 			PURGE_PROJECT_ID,
 			PROJECT_PARTY_ID,
 			OBJECT_ID,
 			OBJECT_TYPE,
 			PROJECT_ID,
 			RESOURCE_ID,
 			RESOURCE_TYPE_ID,
 			RESOURCE_SOURCE_ID,
 			PROJECT_ROLE_ID,
 			START_DATE_ACTIVE,
 			END_DATE_ACTIVE,
 			SCHEDULED_FLAG,
 			RECORD_VERSION_NUMBER,
 			CREATION_DATE,
 			CREATED_BY,
 			LAST_UPDATE_DATE,
 			LAST_UPDATED_BY,
 			LAST_UPDATE_LOGIN,
 			GRANT_ID)

               SELECT   p_purge_batch_id,
                        p_purge_release,
                        p_project_id,
                        Project_Party_Id,
   		        Object_Id,
 		        Object_Type,
 			Project_Id,
 			Resource_Id,
 			Resource_Type_Id,
 			Resource_Source_Id,
 			Project_Role_Id,
 			Start_Date_Active,
 			End_Date_Active,
 			Scheduled_Flag,
 			Record_Version_Number,
 			Creation_Date,
 			Created_By,
 			Last_Update_Date,
 			Last_Updated_By,
 			Last_Update_Login,
 			Grant_Id
              FROM PA_PROJECT_PARTIES WHERE project_party_id = (SELECT project_party_id from pa_project_assignments
                                                                WHERE assignment_id=l_assignment_id);

         /*Increase the value of l_assignments_his_inserted to indicate number of records inserted in assignments_history_ar
          table. The value will increase for each loop*/

             l_nos_parties_inserted := l_nos_parties_inserted  + SQL%ROWCOUNT;

       END IF;

          /*To keep the count of no of records deleted from pa_project_parties, manipulate the
            count of l_nos_parties_deleted */

             pa_debug.debug('Deleting Records from  pa_project_parties table  ') ;
             x_err_stage := 'Deleting Records from  pa_project_parties table for id '||to_char(l_assignment_id) ;

            DELETE PA_PROJECT_PARTIES
            WHERE project_party_id =(SELECT project_party_id FROM pa_project_assignments
                                     WHERE assignment_id=l_assignment_id);

            l_nos_parties_deleted :=l_nos_parties_deleted + SQL%ROWCOUNT;

     END LOOP;

        pa_purge.CommitProcess(p_purge_batch_id,
                               p_project_id,
                               'PA_PROJECT_PARTIES',
                               l_nos_parties_inserted,
                               l_nos_parties_deleted,
                               x_err_code,
                               x_err_stack,
                               x_err_stage
                               ) ;

     x_err_stack := l_old_err_stack; -- Added for bug 4227589

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_PJR_TXNS.PA_PROJECT_PARTIES_PURGE' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

End  Pa_Project_Parties_Purge;


-- Start of comments
-- API name         : PA_ADVERTISEMENTS_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records from Advertisements related tables:
--                             PA_ACTION_SETS,
--                             PA_ACTION_SET_LINES,
--                             PA_ACTION_SET_LINE_COND
--                             PA_ACTION_SET_LINE_AUD


Procedure PA_ADVERTISEMENTS_PURGE   ( p_purge_batch_id                 in NUMBER,
                                      p_project_id                     in NUMBER,
                                      p_purge_release                  in VARCHAR2,
                                      p_assignment_id_tab              in PA_PLSQL_DATATYPES.IdTabTyp,
                                      p_archive_flag                   in VARCHAR2,
                                      x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                      x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                      x_err_code                       in OUT NOCOPY NUMBER ) IS --File.Sql.39 bug 4440895

      l_assignment_id                      pa_forecast_items.assignment_id%TYPE;
      l_action_set_id                      pa_action_sets.action_set_id%TYPE;
      l_nos_action_sets_inserted           NUMBER;
      l_nos_set_lines_inserted             NUMBER;
      l_nos_lines_cond_inserted            NUMBER;
      l_nos_lines_aud_inserted             NUMBER;
      l_nos_action_sets_deleted            NUMBER;
      l_nos_set_lines_deleted              NUMBER;
      l_nos_lines_cond_deleted             NUMBER;
      l_nos_lines_aud_deleted              NUMBER;

      CURSOR Cur_action_sets (x_assignment_id IN pa_project_assignments.assignment_id%TYPE) IS
      SELECT action_set_id From Pa_action_sets
      WHERE action_set_type_code = 'ADVERTISEMENT'
      AND object_type ='OPEN_ASSIGNMENT'
      AND object_id=x_assignment_id;

      l_old_err_stack        VARCHAR2(2000); -- Added for bug 4227589
Begin

     l_old_err_stack := x_err_stack;  -- Added for bug 4227589
     x_err_stack := x_err_stack || ' ->Before call to purge Requirement advertisements  records ';

/*Initialize the no of record variables for each call */

  pa_debug.debug(' Inside Procedure to purge requirement Advertisements  records ') ;
  x_err_stage := 'Start purging requirement Advertisements records for project '||to_char(p_project_id) ;

      l_nos_action_sets_inserted :=0;
      l_nos_set_lines_inserted   :=0;
      l_nos_lines_cond_inserted  :=0;
      l_nos_lines_aud_inserted   :=0;
      l_nos_action_sets_deleted  :=0;
      l_nos_set_lines_deleted    :=0;
      l_nos_lines_cond_deleted   :=0;
      l_nos_lines_aud_deleted    :=0;

     -----------------Begin Logic added to purge data from Workflow related tables-----------------
         /* Call  Workflow API to archive/purge data from pa_wf_processes table*/

         Pa_Debug.DEBUG(' About to purge workflow process ') ;
         x_err_stage := 'About to purge workflow data for project '||TO_CHAR(p_project_id) ;

         Pa_Purge_Pjr_Txns.pa_wf_key_purge ( p_purge_batch_id     =>p_purge_batch_id,
                                             p_project_id         =>p_project_id,
                                             p_purge_release      =>p_purge_release,
                                             p_entity_key2        => '-999',
                                             p_wf_type_code       =>'ADVERTISEMENTS_NTF_WF',
                                             p_item_type          =>'PARADVWF',
                                             p_archive_flag       =>p_archive_flag,
                                             x_err_stack          =>x_err_stack,
                                             x_err_stage          =>x_err_stage,
                                             x_err_code           =>x_err_code);

         /* Call  Workflow API to archive/purge data from pa_wf_processes and detail table
            and also from pa_wf_ntf_performers table*/

         Pa_Debug.DEBUG(' About to purge workflow process and details ') ;
         x_err_stage := 'About to purge workflow data for project '||TO_CHAR(p_project_id) ;

         Pa_Purge_Pjr_Txns.pa_wf_purge ( p_purge_batch_id     =>p_purge_batch_id,
                                         p_project_id         =>p_project_id,
                                         p_purge_release      =>p_purge_release,
                                         p_entity_key_tab     =>p_assignment_id_tab,
                                         p_wf_type_code       =>'ADVERTISEMENTS_NTF_WF',
                                         p_item_type          =>'PARADVWF',
                                         p_archive_flag       =>p_archive_flag,
                                         x_err_stack          =>x_err_stack,
                                         x_err_stage          =>x_err_stage,
                                         x_err_code           =>x_err_code);

     -----------------End of Logic added to purge data from Workflow related tables-----------------

  FOR I in p_assignment_id_tab.FIRST .. p_assignment_id_tab.LAST LOOP
     l_assignment_id :=p_assignment_id_tab(I);

    OPEN cur_action_sets(l_assignment_id);
      LOOP
       FETCH cur_action_sets  INTO l_action_set_id;
       IF cur_action_sets%NOTFOUND THEN
         EXIT;
       END IF;


         IF p_archive_flag='Y' THEN
           pa_debug.debug('Inserting Records into PA_ACTION_SETS_AR table  ') ;
           x_err_stage := 'Inserting Records into P_ACTION_SETS_AR table for assignment  id '||to_char(l_assignment_id);

              INSERT INTO PA_ACTION_SETS_AR
                       (PURGE_BATCH_ID,
			PURGE_RELEASE,
 			PURGE_PROJECT_ID,
 			ACTION_SET_ID,
 			ACTION_SET_NAME,
 			ACTION_SET_TYPE_CODE,
 			OBJECT_TYPE,
 			OBJECT_ID,
 			START_DATE_ACTIVE,
 			END_DATE_ACTIVE,
 			ACTUAL_START_DATE,
 			DESCRIPTION,
 			RECORD_VERSION_NUMBER,
 			SOURCE_ACTION_SET_ID,
 			STATUS_CODE,
 			ACTION_SET_TEMPLATE_FLAG,
 			MOD_SOURCE_ACTION_SET_FLAG,
 			ATTRIBUTE_CATEGORY,
 			ATTRIBUTE1,
 			ATTRIBUTE2,
 			ATTRIBUTE3,
 			ATTRIBUTE4,
 			ATTRIBUTE5,
 			ATTRIBUTE6,
 			ATTRIBUTE7,
 			ATTRIBUTE8,
 			ATTRIBUTE9,
 			ATTRIBUTE10,
 			ATTRIBUTE11,
 			ATTRIBUTE12,
 			ATTRIBUTE13,
 			ATTRIBUTE14,
 			ATTRIBUTE15,
 			CREATED_BY,
 			CREATION_DATE,
 			LAST_UPDATE_DATE,
 			LAST_UPDATED_BY,
 			LAST_UPDATE_LOGIN)

               SELECT   p_purge_batch_id,
                        p_purge_release,
                        p_project_id,
                      	Action_Set_Id,
 			Action_Set_Name,
 			Action_Set_Type_Code,
 			Object_Type,
 			Object_Id,
 			Start_Date_Active,
 			End_Date_Active,
 			Actual_Start_Date,
 			Description,
 			Record_Version_Number,
 			Source_Action_Set_Id,
 			Status_Code,
 			Action_Set_Template_Flag,
 			Mod_Source_Action_Set_Flag,
 			Attribute_Category,
 			Attribute1,
 			Attribute2,
 			Attribute3,
 			Attribute4,
 			Attribute5,
 			Attribute6,
 			Attribute7,
 			Attribute8,
 			Attribute9,
 			Attribute10,
 			Attribute11,
 			Attribute12,
 			Attribute13,
 			Attribute14,
 			Attribute15,
 			Created_By,
 			Creation_Date,
 			Last_Update_Date,
 			Last_Updated_By,
 			Last_Update_Login
              From pa_action_sets where action_set_id=l_action_set_id;

        /*Increase the value of l_nos_action_sets_inserted to indicate number of records inserted in action_sets_ar  table.
          The value will increase for each loop*/

             l_nos_action_sets_inserted := l_nos_action_sets_inserted + SQL%ROWCOUNT;

       pa_debug.debug('Inserting Records into pa_action_set_lines_AR table  ') ;
       x_err_stage := 'Inserting Records into pa_action_setl_lines_AR table for action set  id '||to_char(l_action_set_id) ;


            INSERT INTO PA_ACTION_SET_LINES_AR
                      ( PURGE_BATCH_ID,
 			PURGE_RELEASE,
			PURGE_PROJECT_ID,
			ACTION_SET_LINE_ID,
 			ACTION_SET_ID,
 			ACTION_SET_LINE_NUMBER,
 			STATUS_CODE,
	 		DESCRIPTION,
 			RECORD_VERSION_NUMBER,
 			LINE_DELETED_FLAG,
 			ACTION_CODE,
 			ACTION_ATTRIBUTE1,
 			ACTION_ATTRIBUTE2,
 			ACTION_ATTRIBUTE3,
 			ACTION_ATTRIBUTE4,
 			ACTION_ATTRIBUTE5,
 			ACTION_ATTRIBUTE6,
 			ACTION_ATTRIBUTE7,
	 		ACTION_ATTRIBUTE8,
 			ACTION_ATTRIBUTE9,
 			ACTION_ATTRIBUTE10,
 			CREATION_DATE,
 			CREATED_BY,
 			LAST_UPDATE_DATE,
 			LAST_UPDATED_BY,
 			LAST_UPDATE_LOGIN)

                SELECT  P_purge_batch_id,
                        P_purge_release,
                        P_project_id,
                     	Action_Set_Line_Id,
 			Action_Set_Id,
 			Action_Set_Line_Number,
 			Status_Code,
	 		Description,
 			Record_Version_Number,
 			Line_Deleted_Flag,
 			Action_Code,
 			Action_Attribute1,
 			Action_Attribute2,
 			Action_Attribute3,
 			Action_Attribute4,
 			Action_Attribute5,
 			Action_Attribute6,
 			Action_Attribute7,
	 		Action_Attribute8,
 			Action_Attribute9,
 			Action_Attribute10,
 			Creation_Date,
 			Created_By,
 			Last_Update_Date,
 			Last_Updated_By,
 			Last_Update_Login
                FROM Pa_Action_Set_Lines WHERE action_set_id=l_action_set_id;

      /*Increase the value of l_nos_set_lines_inserted to indicate number of records inserted in action_set_lines_ar table.
       The value will increase for each loop*/

             l_nos_set_lines_inserted := l_nos_set_lines_inserted + SQL%ROWCOUNT;

       pa_debug.debug('Inserting Records into pa_action_set_line_cond_AR table  ') ;
       x_err_stage := 'Inserting Records into pa_action_set_line__cond_AR table for lines of action set id '||to_char(l_action_set_id) ;

               INSERT INTO PA_ACTN_SET_LN_COND_AR
                      (	PURGE_BATCH_ID,
 			PURGE_RELEASE,
 			PURGE_PROJECT_ID,
 			ACTION_SET_LINE_ID,
 			ACTION_SET_LINE_CONDITION_ID,
			DESCRIPTION,
 			CONDITION_DATE,
 			CONDITION_CODE,
 			CONDITION_ATTRIBUTE1,
 			CONDITION_ATTRIBUTE2,
 			CONDITION_ATTRIBUTE3,
 			CONDITION_ATTRIBUTE4,
 			CONDITION_ATTRIBUTE5,
 			CONDITION_ATTRIBUTE6,
 			CONDITION_ATTRIBUTE7,
 			CONDITION_ATTRIBUTE8,
	 		CONDITION_ATTRIBUTE9,
 			CONDITION_ATTRIBUTE10,
 			CREATION_DATE,
 			CREATED_BY,
	 		LAST_UPDATE_DATE,
 			LAST_UPDATED_BY,
	 		LAST_UPDATE_LOGIN)

                 SELECT P_purge_batch_id,
                        P_purge_release,
                        P_project_id,
                     	Action_Set_Line_Id,
           		Action_Set_Line_Condition_Id,
			Description,
 			Condition_Date,
 			Condition_Code,
 			Condition_Attribute1,
 			Condition_Attribute2,
 			Condition_Attribute3,
 			Condition_Attribute4,
 			Condition_Attribute5,
 			Condition_Attribute6,
 			Condition_Attribute7,
 			Condition_Attribute8,
	 		Condition_Attribute9,
 			Condition_Attribute10,
 			Creation_Date,
 			Created_By,
	 		Last_Update_Date,
 			Last_Updated_By,
	 		Last_Update_Login
            FROM PA_ACTION_SET_LINE_COND WHERE action_set_line_id IN (SELECT action_set_line_id
                                                                      From pa_action_set_lines where action_set_id=l_action_set_id);

       /*Increase the value of l_l_nos_lines_cond_inserted to indicate number of records inserted in action_set_lines_acond_ar  table.
          The value will increase for each loop*/

             l_nos_lines_cond_inserted := l_nos_lines_cond_inserted + SQL%ROWCOUNT;

       pa_debug.debug('Inserting Records into pa_action_set_lines_audit table  ') ;
       x_err_stage := 'Inserting Records into pa_action_set_lines_audit table for lines of action set id '||to_char(l_action_set_id) ;

            INSERT INTO PA_ACTN_SETLN_AUD_AR
                      ( PURGE_BATCH_ID,
 			PURGE_RELEASE,
 			PURGE_PROJECT_ID,
 			ACTION_SET_LINE_ID,
 			OBJECT_TYPE,
 			OBJECT_ID,
 			ACTION_SET_TYPE_CODE,
 			STATUS_CODE,
 			REASON_CODE,
 			ACTION_CODE,
 			AUDIT_DISPLAY_ATTRIBUTE,
 			AUDIT_ATTRIBUTE,
 			ACTION_DATE,
 			ACTIVE_FLAG,
 			REVERSED_ACTION_SET_LINE_ID,
 			OBJECT_NAME,
 			ENCODED_ERROR_MESSAGE,
 			CREATION_DATE,
 			CREATED_BY,
 			LAST_UPDATE_DATE,
 			LAST_UPDATED_BY,
 			LAST_UPDATE_LOGIN,
 			REQUEST_ID,
 			PROGRAM_APPLICATION_ID,
 			PROGRAM_ID,
 			PROGRAM_UPDATE_DATE)

                 SELECT P_purge_batch_id,
                        P_purge_release,
                        P_project_id,
                        Action_Set_Line_Id,
 			Object_Type,
 			Object_Id,
 			Action_Set_Type_Code,
 			Status_Code,
 			Reason_Code,
 			Action_Code,
 			Audit_Display_Attribute,
 			Audit_Attribute,
 			Action_Date,
 			Active_Flag,
 			Reversed_Action_Set_Line_Id,
 			Object_Name,
 			Encoded_Error_Message,
 			Creation_Date,
 			Created_By,
 			Last_Update_Date,
 			Last_Updated_By,
 			Last_Update_Login,
 			Request_Id,
 			Program_Application_Id,
 			Program_Id,
 			Program_Update_Date
                  From  PA_ACTION_SET_LINE_AUD WHERE action_set_line_ID IN (SELECT action_set_line_id From pa_action_set_lines
                                                                            WHERE action_set_id=l_action_set_id);


        /*Increase the value of l_nos_lines_aud_inserted to indicate number of records inserted in action_set_lines_aud_ar
          table. The value will increase for each loop*/

            l_nos_lines_aud_inserted :=  l_nos_lines_aud_inserted + SQL%ROWCOUNT;

         END IF;

          /*To keep the count of no of records deleted from adcertisement related tables, manipulate the
            count of variables: */

           pa_debug.debug('Deleting Records from  pa_action_set_lines_aud table  ') ;
           x_err_stage := 'Deleting Records from  pa_action_set_lines_aud for id for lines of action set id'||to_char(l_action_set_id) ;

            DELETE PA_ACTION_SET_LINE_AUD
            WHERE action_set_line_ID IN (SELECT action_set_line_id From pa_action_set_lines
                                         WHERE action_set_id=l_action_set_id);

           l_nos_lines_aud_deleted :=  l_nos_lines_aud_deleted + SQL%ROWCOUNT;

           pa_debug.debug('Deleting Records from  PA_ACTION_SET_LINE_COND table  ') ;
           x_err_stage := 'Deleting Records from  PA_ACTION_SET_LINE_COND for id for lines of action set id'||to_char(l_action_set_id) ;

            DELETE PA_ACTION_SET_LINE_COND
            WHERE action_set_line_ID IN (SELECT action_set_line_id From pa_action_set_lines
                                         WHERE action_set_id=l_action_set_id);

            l_nos_lines_cond_deleted := l_nos_lines_cond_deleted + SQL%ROWCOUNT;

           pa_debug.debug('Deleting Records from  PA_ACTION_SET_LINES table  ') ;
           x_err_stage := 'Deleting Records from  PA_ACTION_SET_LINES for id for lines of action set id'||to_char(l_action_set_id) ;

            DELETE  PA_ACTION_SET_LINES
            WHERE action_set_id=l_action_set_id;

            l_nos_set_lines_deleted := l_nos_set_lines_deleted + SQL%ROWCOUNT;

           pa_debug.debug('Deleting Records from  PA_ACTION_SETS table  ') ;
           x_err_stage := 'Deleting Records from  PA_ACTION_SETS for id for lines of action set id'||to_char(l_action_set_id) ;

            DELETE  PA_ACTION_SETS
            WHERE action_set_id=l_action_set_id;

            l_nos_action_sets_deleted := l_nos_action_sets_deleted + SQL%ROWCOUNT;



      END LOOP;
     CLOSE Cur_Action_sets;

  END LOOP;

        pa_purge.CommitProcess(p_purge_batch_id,
                               p_project_id,
                               'PA_ACTION_SETS',
                               l_nos_action_sets_inserted,
                               l_nos_action_sets_deleted,
                               x_err_code,
                               x_err_stack,
                               x_err_stage
                               ) ;

        pa_purge.CommitProcess(p_purge_batch_id,
                               p_project_id,
                               'PA_ACTION_SET_LINES',
                               l_nos_set_lines_inserted,
                               l_nos_set_lines_deleted,
                               x_err_code,
                               x_err_stack,
                               x_err_stage
                               ) ;

       pa_purge.CommitProcess(p_purge_batch_id,
                              p_project_id,
                              /*  'PA_ACTN_SET_LN_COND_AR',  bug 2480653 */
                              'PA_ACTION_SET_LINE_COND',
                              l_nos_lines_cond_inserted,
                              l_nos_lines_cond_deleted,
                              x_err_code,
                              x_err_stack,
                              x_err_stage
                               ) ;

        pa_purge.CommitProcess(p_purge_batch_id,
                               p_project_id,
                               /*  'PA_ACTN_SETLN_AUD_AR',  bug 2480653 */
                               'PA_ACTION_SET_LINE_AUD',
                               l_nos_lines_aud_inserted,
                               l_nos_lines_aud_deleted,
                               x_err_code,
                               x_err_stack,
                               x_err_stage
                               ) ;

    x_err_stack := l_old_err_stack; -- Added for bug 4227589

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_PJR_TXNS.PA_ADVERTISEMENTS_PURGE' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;




End Pa_Advertisements_purge;


-- Start of comments
-- API name         : PA_WF_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records from Workflow related tables:
-- Note             : Argument p_entity_key2_tab can have the following values-
--                       pa_wf_processes.entity_key2
--                       pa_wf_process-details.object_id1.
--                       pa_wf_ntf_performers.object_id1.

PROCEDURE PA_WF_PURGE ( p_purge_batch_id                 IN NUMBER,
                        p_project_id                     IN NUMBER,
                        p_purge_release                  IN VARCHAR2,
                        p_entity_key_tab                 IN Pa_Plsql_Datatypes.IdTabTyp,
                        p_wf_type_code                   IN VARCHAR2,
                        p_item_type                      IN VARCHAR2,
                        p_archive_flag                   IN VARCHAR2,
                        x_err_stack                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_err_stage                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_err_code                       IN OUT NOCOPY NUMBER ) AS --File.Sql.39 bug 4440895

    CURSOR cur_workflow (x_entity_key VARCHAR2) IS
    SELECT item_key
      FROM pa_wf_processes
     WHERE entity_key1  = TO_CHAR(p_project_id)
       AND entity_key2  = x_entity_key
       AND wf_type_code = p_wf_type_code
       AND item_type    = p_item_type;

    l_item_key                          pa_wf_processes.item_key%TYPE;
    I                                   PLS_INTEGER;
    l_entity_key                        pa_wf_processes.entity_key2%TYPE;
    l_nos_wf_process_inserted           NUMBER ;
    l_nos_wf_process_dtls_inserted      NUMBER ;
    l_nos_wf_ntf_perf_inserted          NUMBER ;
    l_nos_wf_process_deleted            NUMBER ;
    l_nos_wf_process_dtls_deleted       NUMBER ;
    l_nos_wf_ntf_perf_deleted           NUMBER ;

    l_status                            VARCHAR2(100);
    l_result                            VARCHAR2(100);
    l_old_err_stack                     VARCHAR2(2000); -- Added for bug 4227589

BEGIN

l_old_err_stack := x_err_stack;  -- Added for bug 4227589
x_err_stack := x_err_stack || ' ->Before call to purge workflow records ';

/*Initialize the no of record variables for each call */

  Pa_Debug.DEBUG(' Inside Procedure to purge workflow process details and notification ') ;
  x_err_stage := 'Inside Procedure to purge workflow process details and notification for project '||TO_CHAR(p_project_id) ;

    l_nos_wf_process_inserted           := 0;
    l_nos_wf_process_dtls_inserted      := 0;
    l_nos_wf_ntf_perf_inserted          := 0;
    l_nos_wf_process_deleted            := 0;
    l_nos_wf_process_dtls_deleted       := 0;
    l_nos_wf_ntf_perf_deleted           := 0;

  /* Fetch the records from PLSQL table. */

   FOR I IN p_entity_key_tab.FIRST .. p_entity_key_tab.LAST LOOP
     l_entity_key := TO_CHAR(p_entity_key_tab(I));

     OPEN cur_workflow(l_entity_key);
      LOOP
       FETCH cur_workflow  INTO l_item_key;
       IF cur_workflow%NOTFOUND THEN
         EXIT;
       END IF;

/* If archive flag is YES, archiving of data needs to be done. Insert data into correspodning AR tables */

       IF p_archive_flag='Y' THEN

          Pa_Debug.DEBUG('Inserting Records into pa_wf_processes_AR table  ') ;
          x_err_stage := 'Inserting Records into pa_wf_processes_AR table for item key '||l_item_key ;

          INSERT INTO pa_wf_processes_ar
               (purge_batch_id,
                purge_release,
                purge_project_id,
                wf_type_code,
                item_type,
                item_key,
                entity_key1,
                entity_key2,
                description,
                last_updated_by,
                last_update_date,
                creation_date,
                created_by,
                last_update_login)
          SELECT  p_purge_batch_id,
                  p_purge_release,
                  p_project_id,
                  wf_type_code,
                  item_type,
                  item_key,
                  entity_key1,
                  entity_key2,
                  description,
                  last_updated_by,
                  last_update_date,
                  creation_date,
                  created_by,
                  last_update_login
             FROM pa_wf_processes
            WHERE entity_key1  = TO_CHAR(p_project_id)
              AND entity_key2  = l_entity_key
              AND wf_type_code = p_wf_type_code
              AND item_type    = p_item_type;

 /*Increase the value of l_nos_wf_process_inserted to indicate number of records inserted in pa_wf_processes_ar table.
  The value will increase for each loop(item_key)*/
            l_nos_wf_process_inserted := l_nos_wf_process_inserted + SQL%ROWCOUNT;

              Pa_Debug.DEBUG('Inserting Records into pa_wf_process_DETAILS_AR table  ') ;
              x_err_stage := 'Inserting Records into pa_wf_process_DETAILS_AR table for item key '|| l_item_key ;


              INSERT INTO pa_wf_process_details_ar
                   (purge_batch_id,
                    purge_release,
                    purge_project_id,
                    wf_type_code,
                    item_type,
                    item_key,
                    object_id1,
                    object_id2,
                    process_status_code,
                    source_attribute1,
                    source_attribute2,
                    source_attribute3,
                    source_attribute4,
                    source_attribute5,
                    source_attribute6,
                    source_attribute7,
                    source_attribute8,
                    source_attribute9,
                    source_attribute10,
                    last_updated_by,
                    last_update_date,
                    creation_date,
                    created_by,
                    last_update_login)
              SELECT  p_purge_batch_id,
                      p_purge_release,
                      p_project_id,
                      wf_type_code,
                      item_type,
                      item_key,
                      object_id1,
                      object_id2,
                      process_status_code,
                      source_attribute1,
                      source_attribute2,
                      source_attribute3,
                      source_attribute4,
                      source_attribute5,
                      source_attribute6,
                      source_attribute7,
                      source_attribute8,
                      source_attribute9,
                      source_attribute10,
                      last_updated_by,
                      last_update_date,
                      creation_date,
                      created_by,
                      last_update_login
                 FROM pa_wf_process_details
                WHERE item_key   = l_item_key
                  AND object_id1 = l_entity_key
                  AND wf_type_code = p_wf_type_code
                  AND item_type    = p_item_type;

            /* Increase the value of l_nos_wf_process_dtls_inserted to indicate number of records inserted in
               pa_wf_process_details_ar table. The value will increase for each loop(item_key)*/
               l_nos_wf_process_dtls_inserted := l_nos_wf_process_dtls_inserted + SQL%ROWCOUNT;

           Pa_Debug.DEBUG('Inserting Records into pa_wf_ntf_performers_AR table  ') ;
           x_err_stage := 'Inserting Records into pa_wf_ntf_performers_AR table for item key '|| l_item_key ;


           INSERT INTO pa_wf_ntf_performers_ar
                (purge_batch_id,
                 purge_release,
                 purge_project_id,
                 wf_type_code,
                 item_type,
                 item_key,
                 object_id1,
                 object_id2,
                 user_name,
                 user_type,
                 routing_order,
                 current_approver_flag,
                 approver_comments,
                 group_id,
                 approver_group_id,
                 approval_status,
                 sequence_number,
                 action_code,
                 action_date,
                 display_flag,
                 last_updated_by,
                 last_update_date,
                 creation_date,
                 created_by,
                 last_update_login)
           SELECT  p_purge_batch_id,
                   p_purge_release,
                   p_project_id,
                   wf_type_code,
                   item_type,
                   item_key,
                   object_id1,
                   object_id2,
                   user_name,
                   user_type,
                   routing_order,
                   current_approver_flag,
                   approver_comments,
                   group_id,
                   approver_group_id,
                   approval_status,
                   sequence_number,
                   action_code,
                   action_date,
                   display_flag,
                   Fnd_Global.user_id,
                   SYSDATE,
                   SYSDATE,
                   Fnd_Global.user_id,
                   Fnd_Global.login_id
              FROM pa_wf_ntf_performers
             WHERE object_id2 = TO_CHAR(p_project_id)
               AND object_id1 = l_entity_key
               AND wf_type_code = p_wf_type_code
               AND item_type    = p_item_type;

 /*Increase the value of l_nos_wf_ntf_perf_inserted to indicate number of records inserted in pa_wf_process_details_ar table.
  The value will increase for each loop(item_key)*/
            l_nos_wf_ntf_perf_inserted := l_nos_wf_ntf_perf_inserted + SQL%ROWCOUNT;

        END IF; -- p_archive_flag='Y'

/* To keep the count of no of records deleted from pa_wf_processes, pa_wf_process_details and pa_wf_ntf_performers,
   manipulate the count of l_nos_wf_process_deleted, l_nos_wf_process_dtls_deleted and l_nos_wf_ntf_perf_deleted. */

       Pa_Debug.DEBUG('Deleting Records from  pa_wf_ntf_performers table  ') ;
       x_err_stage := 'Deleting Records from  pa_wf_ntf_performers table for item key '|| l_item_key ;

       DELETE pa_wf_ntf_performers
        WHERE object_id2   = TO_CHAR(p_project_id)
          AND object_id1   = l_entity_key
          AND wf_type_code = p_wf_type_code
          AND item_type    = p_item_type;

       l_nos_wf_ntf_perf_deleted := l_nos_wf_ntf_perf_deleted + SQL%ROWCOUNT;

       Pa_Debug.DEBUG('Deleting Records from  pa_wf_process_details table  ') ;
       x_err_stage := 'Deleting Records from  pa_wf_process_details table for item key '|| l_item_key ;

       DELETE pa_wf_process_details
        WHERE object_id2   = TO_CHAR(p_project_id)
          AND object_id1   = l_entity_key
          AND wf_type_code = p_wf_type_code
          AND item_type    = p_item_type;

       l_nos_wf_process_dtls_deleted := l_nos_wf_process_dtls_deleted + SQL%ROWCOUNT;

       Pa_Debug.DEBUG('Deleting Records from  pa_wf_processes table  ') ;
       x_err_stage := 'Deleting Records from  pa_wf_processes table for item key '|| l_item_key ;


       DELETE pa_wf_processes
        WHERE entity_key1  = TO_CHAR(p_project_id)
          AND entity_key2  = l_entity_key
          AND wf_type_code = p_wf_type_code
          AND item_type    = p_item_type;

       l_nos_wf_process_deleted := l_nos_wf_process_deleted + SQL%ROWCOUNT;

    -------------------Delete the records from WORKFLOW tables by calling suitable APIs----------------------

     /* Check the item status for the workflow process */
       Wf_Engine.itemstatus ( itemtype  => p_item_type,
                              itemkey   => l_item_key,
                              status    => l_status,
                              result    => l_result );
       /* If the status of the item is ACTIVE, the process need to be aborted before purging */
       IF l_status = 'ACTIVE' THEN

        Wf_Engine.abortprocess ( itemtype  => p_item_type,
                                 itemkey   => l_item_key );
       END IF;

       /* Purge the record from workflow tables.*/
       Wf_Purge.total( itemtype  => p_item_type,
                       itemkey   => l_item_key );


   END LOOP;

  CLOSE cur_workflow;

END LOOP;

  /*After "deleting" or "deleting and inserting" a set of records the transaction is commited. This also creates a record in
    the Pa_Purge_Project_details, which will show the no. of records that are purged from each table.
    The procedure is called once for ppa_wf_processes, pa_wf_process_details and pa_wf_ntf_performers tables */

        Pa_Purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_WF_NTF_PERFORMERS',
	                       l_nos_wf_ntf_perf_inserted,
	                       l_nos_wf_ntf_perf_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

       	Pa_Purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_WF_PROCESS_DETAILS',
	                       l_nos_wf_process_dtls_inserted,
	                       l_nos_wf_process_dtls_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

       	Pa_Purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_WF_PROCESSES',
	                       l_nos_wf_process_inserted,
	                       l_nos_wf_process_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

    x_err_stack := l_old_err_stack; -- Added for bug 4227589
EXCEPTION
  WHEN Pa_Project_Utils2.PA_Arch_Pur_Subroutine_Error THEN
       RAISE Pa_Project_Utils2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    Pa_Debug.DEBUG('Error Procedure Name  := PA_PURGE_PJR_TXNS.PA_WF_PURGE');
    Pa_Debug.DEBUG('Error stage is '||x_err_stage );
    Pa_Debug.DEBUG('Error stack is '||x_err_stack );
    Pa_Debug.DEBUG(SQLERRM);
    Pa_Project_Utils2.g_sqlerrm := SQLERRM ;

    RAISE Pa_Project_Utils2.PA_Arch_Pur_Subroutine_Error ;


END PA_WF_PURGE;


PROCEDURE PA_WF_MASS_PURGE ( p_purge_batch_id                 IN NUMBER,
                             p_project_id                     IN NUMBER,
                             p_purge_release                  IN VARCHAR2,
                             p_object_id_tab                  IN Pa_Plsql_Datatypes.IdTabTyp,
                             p_item_type                      IN VARCHAR2,
                             p_archive_flag                   IN VARCHAR2,
                             x_err_stack                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_err_stage                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_err_code                       IN OUT NOCOPY NUMBER ) AS --File.Sql.39 bug 4440895

    CURSOR cur_workflow (x_object_id VARCHAR2) IS
    SELECT item_key
      FROM pa_wf_process_details
     WHERE NVL(object_id2, object_id1) = x_object_id
       AND item_type    = p_item_type;

    l_item_key                          pa_wf_processes.item_key%TYPE;
    I                                   PLS_INTEGER;
    l_object_id                         pa_wf_process_details.object_id1%TYPE;
    l_nos_wf_process_inserted           NUMBER ;
    l_nos_wf_process_dtls_inserted      NUMBER ;
    l_nos_wf_process_deleted            NUMBER ;
    l_nos_wf_process_dtls_deleted       NUMBER ;

    l_status                            VARCHAR2(100);
    l_result                            VARCHAR2(100);
    l_old_err_stack                     VARCHAR2(2000); -- Added for bug 4227589

BEGIN

l_old_err_stack := x_err_stack;  -- Added for bug 4227589
x_err_stack := x_err_stack || ' ->Before call to purge workflow records ';

/*Initialize the no of record variables for each call */

  Pa_Debug.DEBUG(' Inside Procedure to purge workflow process details ') ;
  x_err_stage := 'Inside Procedure to purge workflow process details for project '||TO_CHAR(p_project_id) ;

    l_nos_wf_process_inserted           := 0;
    l_nos_wf_process_dtls_inserted      := 0;
    l_nos_wf_process_deleted            := 0;
    l_nos_wf_process_dtls_deleted       := 0;

  /* Fetch the records from PLSQL table. */

   FOR I IN p_object_id_tab.FIRST .. p_object_id_tab.LAST LOOP
     l_object_id := p_object_id_tab(I);

     OPEN cur_workflow(l_object_id);
      LOOP
       FETCH cur_workflow  INTO l_item_key;
       IF cur_workflow%NOTFOUND THEN
         EXIT;
       END IF;

/* If archive flag is YES, archiving of data needs to be done. Insert data into correspodning AR tables */

       IF p_archive_flag='Y' THEN

          Pa_Debug.DEBUG('Inserting Records into pa_wf_processes_AR table  ') ;
          x_err_stage := 'Inserting Records into pa_wf_processes_AR table for item key '||l_item_key ;

          INSERT INTO pa_wf_processes_ar
               (purge_batch_id,
                purge_release,
                purge_project_id,
                wf_type_code,
                item_type,
                item_key,
                entity_key1,
                entity_key2,
                description,
                last_updated_by,
                last_update_date,
                creation_date,
                created_by,
                last_update_login)
          SELECT  p_purge_batch_id,
                  p_purge_release,
                  p_project_id,
                  wf_type_code,
                  item_type,
                  item_key,
                  entity_key1,
                  entity_key2,
                  description,
                  last_updated_by,
                  last_update_date,
                  creation_date,
                  created_by,
                  last_update_login
             FROM pa_wf_processes
            WHERE item_key     = l_item_key
              AND entity_key1  = TO_CHAR(p_project_id)
              AND item_type    = p_item_type;

 /*Increase the value of l_nos_wf_process_inserted to indicate number of records inserted in pa_wf_processes_ar table.
  The value will increase for each loop(item_key)*/
            l_nos_wf_process_inserted := l_nos_wf_process_inserted + SQL%ROWCOUNT;

              Pa_Debug.DEBUG('Inserting Records into pa_wf_process_DETAILS_AR table  ') ;
              x_err_stage := 'Inserting Records into pa_wf_process_DETAILS_AR table for item key '|| l_item_key ;


              INSERT INTO pa_wf_process_details_ar
                   (purge_batch_id,
                    purge_release,
                    purge_project_id,
                    wf_type_code,
                    item_type,
                    item_key,
                    object_id1,
                    object_id2,
                    process_status_code,
                    source_attribute1,
                    source_attribute2,
                    source_attribute3,
                    source_attribute4,
                    source_attribute5,
                    source_attribute6,
                    source_attribute7,
                    source_attribute8,
                    source_attribute9,
                    source_attribute10,
                    last_updated_by,
                    last_update_date,
                    creation_date,
                    created_by,
                    last_update_login)
              SELECT  p_purge_batch_id,
                      p_purge_release,
                      p_project_id,
                      wf_type_code,
                      item_type,
                      item_key,
                      object_id1,
                      object_id2,
                      process_status_code,
                      source_attribute1,
                      source_attribute2,
                      source_attribute3,
                      source_attribute4,
                      source_attribute5,
                      source_attribute6,
                      source_attribute7,
                      source_attribute8,
                      source_attribute9,
                      source_attribute10,
                      last_updated_by,
                      last_update_date,
                      creation_date,
                      created_by,
                      last_update_login
                 FROM pa_wf_process_details
                WHERE item_key   = l_item_key
                  AND NVL(object_id2, object_id1) = TO_CHAR(l_object_id)
                  AND item_type    = p_item_type;

            /* Increase the value of l_nos_wf_process_dtls_inserted to indicate number of records inserted in
               pa_wf_process_details_ar table. The value will increase for each loop(item_key)*/
               l_nos_wf_process_dtls_inserted := l_nos_wf_process_dtls_inserted + SQL%ROWCOUNT;

        END IF; -- p_archive_flag='Y'

/* To keep the count of no of records deleted from pa_wf_processes and pa_wf_process_details, manipulate the
   count of l_nos_wf_process_deleted and l_nos_wf_process_dtls_deleted. */

       Pa_Debug.DEBUG('Deleting Records from  pa_wf_process_details table  ') ;
       x_err_stage := 'Deleting Records from  pa_wf_process_details table for item key '|| l_item_key ;

       DELETE pa_wf_process_details
        WHERE item_key   = l_item_key
          AND NVL(object_id2, object_id1) = TO_CHAR(l_object_id)
          AND item_type    = p_item_type;

       l_nos_wf_process_dtls_deleted := l_nos_wf_process_dtls_deleted + SQL%ROWCOUNT;

       Pa_Debug.DEBUG('Deleting Records from  pa_wf_processes table  ') ;
       x_err_stage := 'Deleting Records from  pa_wf_processes table for item key '|| l_item_key ;


       DELETE pa_wf_processes
        WHERE item_key     = l_item_key
          AND entity_key1  = TO_CHAR(p_project_id)
          AND item_type    = p_item_type;

       l_nos_wf_process_deleted := l_nos_wf_process_deleted + SQL%ROWCOUNT;

    -------------------Delete the records from WORKFLOW tables by calling suitable APIs----------------------

     /* Check the item status for the workflow process */
       Wf_Engine.itemstatus ( itemtype  => p_item_type,
                              itemkey   => l_item_key,
                              status    => l_status,
                              result    => l_result );
       /* If the status of the item is ACTIVE, the process need to be aborted before purging */
       IF l_status = 'ACTIVE' THEN

        Wf_Engine.abortprocess ( itemtype  => p_item_type,
                                 itemkey   => l_item_key );
       END IF;

       /* Purge the record from workflow tables.*/
       Wf_Purge.total( itemtype  => p_item_type,
                       itemkey   => l_item_key );


   END LOOP;

  CLOSE cur_workflow;

END LOOP;

  /*After "deleting" or "deleting and inserting" a set of records the transaction is commited. This also creates a record in
    the Pa_Purge_Project_details, which will show the no. of records that are purged from each table.
    The procedure is called once for pa_wf_processes, pa_wf_process_details and pa_wf_ntf_performers tables */

       	Pa_Purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_WF_PROCESS_DETAILS',
	                       l_nos_wf_process_dtls_inserted,
	                       l_nos_wf_process_dtls_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

       	Pa_Purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_WF_PROCESSES',
	                       l_nos_wf_process_inserted,
	                       l_nos_wf_process_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

    x_err_stack := l_old_err_stack; -- Added for bug 4227589
EXCEPTION
  WHEN Pa_Project_Utils2.PA_Arch_Pur_Subroutine_Error THEN
       RAISE Pa_Project_Utils2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    Pa_Debug.DEBUG('Error Procedure Name  := PA_PURGE_PJR_TXNS.PA_WF_MASS_PURGE');
    Pa_Debug.DEBUG('Error stage is '||x_err_stage );
    Pa_Debug.DEBUG('Error stack is '||x_err_stack );
    Pa_Debug.DEBUG(SQLERRM);
    Pa_Project_Utils2.g_sqlerrm := SQLERRM ;

    RAISE Pa_Project_Utils2.PA_Arch_Pur_Subroutine_Error ;


END PA_WF_MASS_PURGE;

-- Start of comments
-- API name         : PA_WF_MASS_ASGN_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Procedure for Purging records from Workflow related tables for item_type 'PARMAAP':

PROCEDURE PA_WF_MASS_ASGN_PURGE ( p_purge_batch_id                 IN NUMBER,
                                  p_project_id                     IN NUMBER,
                                  p_purge_release                  IN VARCHAR2,
                                  p_object_id_tab                  IN Pa_Plsql_Datatypes.IdTabTyp,
                                  p_wf_type_code                   IN VARCHAR2,
                                  p_archive_flag                   IN VARCHAR2,
                                  x_err_stack                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_err_stage                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_err_code                       IN OUT NOCOPY NUMBER ) AS --File.Sql.39 bug 4440895

    CURSOR cur_workflow (x_object_id VARCHAR2) IS
    SELECT item_key, group_id
      FROM pa_wf_ntf_performers
     WHERE object_id1 = x_object_id
       AND wf_type_code = p_wf_type_code
       AND item_type    <> 'PAWFAAP';

    l_item_key                          pa_wf_processes.item_key%TYPE;
    l_group_id                          pa_wf_ntf_performers.group_id%TYPE;
    I                                   PLS_INTEGER;
    l_object_id                         pa_wf_ntf_performers.object_id1%TYPE;
    l_nos_wf_process_inserted           NUMBER ;
    l_nos_wf_ntf_perf_inserted          NUMBER ;
    l_nos_wf_process_deleted            NUMBER ;
    l_nos_wf_ntf_perf_deleted           NUMBER ;

    l_status                            VARCHAR2(100);
    l_result                            VARCHAR2(100);
    l_old_err_stack                     VARCHAR2(2000); -- Added for bug 4227589

BEGIN

l_old_err_stack := x_err_stack;  -- Added for bug 4227589
x_err_stack := x_err_stack || ' ->Before call to purge workflow records ';

/*Initialize the no of record variables for each call */

  Pa_Debug.DEBUG(' Inside Procedure to purge workflow process and notification ') ;
  x_err_stage := 'Inside Procedure to purge workflow process and notification for project '||TO_CHAR(p_project_id) ;

    l_nos_wf_process_inserted           := 0;
    l_nos_wf_ntf_perf_inserted          := 0;
    l_nos_wf_process_deleted            := 0;
    l_nos_wf_ntf_perf_deleted           := 0;

  /* Fetch the records from PLSQL table. */

   FOR I IN p_object_id_tab.FIRST .. p_object_id_tab.LAST LOOP
     l_object_id := p_object_id_tab(I);

     OPEN cur_workflow(l_object_id);
      LOOP
       FETCH cur_workflow  INTO l_item_key,l_group_id;
       IF cur_workflow%NOTFOUND THEN
         EXIT;
       END IF;

/* If archive flag is YES, archiving of data needs to be done. Insert data into correspodning AR tables */

       IF p_archive_flag='Y' THEN

          Pa_Debug.DEBUG('Inserting Records into pa_wf_processes_AR table  ') ;
          x_err_stage := 'Inserting Records into pa_wf_processes_AR table for assignment_id/group_id '||l_group_id ;

          INSERT INTO pa_wf_processes_ar
               (purge_batch_id,
                purge_release,
                purge_project_id,
                wf_type_code,
                item_type,
                item_key,
                entity_key1,
                entity_key2,
                description,
                last_updated_by,
                last_update_date,
                creation_date,
                created_by,
                last_update_login)
          SELECT  p_purge_batch_id,
                  p_purge_release,
                  p_project_id,
                  wf_type_code,
                  item_type,
                  item_key,
                  entity_key1,
                  entity_key2,
                  description,
                  last_updated_by,
                  last_update_date,
                  creation_date,
                  created_by,
                  last_update_login
             FROM pa_wf_processes
            WHERE ( entity_key2  = TO_CHAR(l_object_id)
               OR entity_key2  = TO_CHAR(l_group_id ))
              AND entity_key1  = TO_CHAR(p_project_id)
              AND wf_type_code = p_wf_type_code
              AND item_type    <> 'PAWFAAP';

 /*Increase the value of l_nos_wf_process_inserted to indicate number of records inserted in pa_wf_processes_ar table.
  The value will increase for each loop(item_key)*/
            l_nos_wf_process_inserted := l_nos_wf_process_inserted + SQL%ROWCOUNT;

           Pa_Debug.DEBUG('Inserting Records into pa_wf_ntf_performers_AR table  ') ;
           x_err_stage := 'Inserting Records into pa_wf_ntf_performers_AR table for assignment_id/group_id '|| l_group_id ;


           INSERT INTO pa_wf_ntf_performers_ar
                (purge_batch_id,
                 purge_release,
                 purge_project_id,
                 wf_type_code,
                 item_type,
                 item_key,
                 object_id1,
                 object_id2,
                 user_name,
                 user_type,
                 routing_order,
                 current_approver_flag,
                 approver_comments,
                 group_id,
                 approver_group_id,
                 approval_status,
                 sequence_number,
                 action_code,
                 action_date,
                 display_flag,
                 last_updated_by,
                 last_update_date,
                 creation_date,
                 created_by,
                 last_update_login)
           SELECT  p_purge_batch_id,
                   p_purge_release,
                   p_project_id,
                   wf_type_code,
                   item_type,
                   item_key,
                   object_id1,
                   object_id2,
                   user_name,
                   user_type,
                   routing_order,
                   current_approver_flag,
                   approver_comments,
                   group_id,
                   approver_group_id,
                   approval_status,
                   sequence_number,
                   action_code,
                   action_date,
                   display_flag,
                   Fnd_Global.user_id,
                   SYSDATE,
                   SYSDATE,
                   Fnd_Global.user_id,
                   Fnd_Global.login_id
              FROM pa_wf_ntf_performers
             WHERE object_id1 = TO_CHAR(l_object_id)
               AND wf_type_code = p_wf_type_code
               AND item_type    <> 'PAWFAAP';

 /*Increase the value of l_nos_wf_ntf_perf_inserted to indicate number of records inserted in pa_wf_process_details_ar table.
  The value will increase for each loop(item_key)*/
            l_nos_wf_ntf_perf_inserted := l_nos_wf_ntf_perf_inserted + SQL%ROWCOUNT;

        END IF; -- p_archive_flag='Y'

/* To keep the count of no of records deleted from pa_wf_processes, pa_wf_process_details and pa_wf_ntf_performers,
   manipulate the count of l_nos_wf_process_deleted, l_nos_wf_process_dtls_deleted and l_nos_wf_ntf_perf_deleted. */

       Pa_Debug.DEBUG('Deleting Records from  pa_wf_ntf_performers table  ') ;
       x_err_stage := 'Deleting Records from  pa_wf_ntf_performers table for assignment_id/group_id '|| l_group_id;

       DELETE pa_wf_ntf_performers
        WHERE object_id1 = TO_CHAR(l_object_id)
          AND wf_type_code = p_wf_type_code
          AND item_type    <> 'PAWFAAP';

       l_nos_wf_ntf_perf_deleted := l_nos_wf_ntf_perf_deleted + SQL%ROWCOUNT;

       Pa_Debug.DEBUG('Deleting Records from  pa_wf_processes table  ') ;
       x_err_stage := 'Deleting Records from  pa_wf_processes table for assignment_id/group_id '|| l_group_id;


       DELETE pa_wf_processes
        WHERE entity_key1  = TO_CHAR(p_project_id)
          aND (entity_key2  = TO_CHAR(l_object_id)
           OR entity_key2  = TO_CHAR(l_group_id) )
          AND wf_type_code = p_wf_type_code
          AND item_type    <> 'PAWFAAP';

       l_nos_wf_process_deleted := l_nos_wf_process_deleted + SQL%ROWCOUNT;

    -------------------Delete the records from WORKFLOW tables by calling suitable APIs----------------------

     /* Check the item status for the workflow process */
       Wf_Engine.itemstatus ( itemtype  => 'PARMAAP',
                              itemkey   => l_item_key,
                              status    => l_status,
                              result    => l_result );
       /* If the status of the item is ACTIVE, the process need to be aborted before purging */
       IF l_status = 'ACTIVE' THEN

        Wf_Engine.abortprocess ( itemtype  => 'PARMAAP',
                                 itemkey   => l_item_key );
       END IF;

       /* Purge the record from workflow tables.*/
       Wf_Purge.total( itemtype  => 'PARMAAP',
                       itemkey   => l_item_key );


   END LOOP;

  CLOSE cur_workflow;

END LOOP;

  /*After "deleting" or "deleting and inserting" a set of records the transaction is commited. This also creates a record in
    the Pa_Purge_Project_details, which will show the no. of records that are purged from each table.
    The procedure is called once for pa_wf_processes and pa_wf_ntf_performers tables */

        Pa_Purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_WF_NTF_PERFORMERS',
	                       l_nos_wf_ntf_perf_inserted,
	                       l_nos_wf_ntf_perf_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

       	Pa_Purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_WF_PROCESSES',
	                       l_nos_wf_process_inserted,
	                       l_nos_wf_process_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

    x_err_stack := l_old_err_stack; -- Added for bug 4227589
EXCEPTION
  WHEN Pa_Project_Utils2.PA_Arch_Pur_Subroutine_Error THEN
       RAISE Pa_Project_Utils2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    Pa_Debug.DEBUG('Error Procedure Name  := PA_PURGE_PJR_TXNS.PA_WF_MASS_ASGN_PURGE');
    Pa_Debug.DEBUG('Error stage is '||x_err_stage );
    Pa_Debug.DEBUG('Error stack is '||x_err_stack );
    Pa_Debug.DEBUG(SQLERRM);
    Pa_Project_Utils2.g_sqlerrm := SQLERRM ;

    RAISE Pa_Project_Utils2.PA_Arch_Pur_Subroutine_Error ;


END PA_WF_MASS_ASGN_PURGE;

-- Start of comments
-- API name         : PA_WF_KEY_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Procedure for Purging records from Workflow related tables where
--                    pa_wf_processes.entity_key2 does not store assignment_id

PROCEDURE PA_WF_KEY_PURGE ( p_purge_batch_id                 IN NUMBER,
                            p_project_id                     IN NUMBER,
                            p_purge_release                  IN VARCHAR2,
                            p_entity_key2                    IN VARCHAR2,
                            p_wf_type_code                   IN VARCHAR2,
                            p_item_type                      IN VARCHAR2,
                            p_archive_flag                   IN VARCHAR2,
                            x_err_stack                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_err_stage                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_err_code                       IN OUT NOCOPY NUMBER ) AS --File.Sql.39 bug 4440895

    CURSOR cur_workflow (x_entity_key VARCHAR2) IS
    SELECT item_key
      FROM pa_wf_processes
     WHERE entity_key1  = TO_CHAR(p_project_id)
       AND entity_key2  = x_entity_key
       AND wf_type_code = p_wf_type_code
       AND item_type    = p_item_type;

    l_item_key                          pa_wf_processes.item_key%TYPE;
    I                                   PLS_INTEGER;
    l_entity_key                        pa_wf_processes.entity_key2%TYPE;
    l_nos_wf_process_inserted           NUMBER ;
    l_nos_wf_process_deleted            NUMBER ;

    l_status                            VARCHAR2(100);
    l_result                            VARCHAR2(100);
    l_old_err_stack                     VARCHAR2(2000); -- Added for bug 4227589

BEGIN

l_old_err_stack := x_err_stack;  -- Added for bug 4227589
x_err_stack := x_err_stack || ' ->Before call to purge workflow records ';

/*Initialize the no of record variables for each call */

  Pa_Debug.DEBUG(' Inside Procedure to purge workflow processn ') ;
  x_err_stage := 'Inside Procedure to purge workflow process for project '||TO_CHAR(p_project_id) ;

    l_nos_wf_process_inserted           := 0;
    l_nos_wf_process_deleted            := 0;

     OPEN cur_workflow(p_entity_key2);
      LOOP
       FETCH cur_workflow  INTO l_item_key;
       IF cur_workflow%NOTFOUND THEN
         EXIT;
       END IF;

/* If archive flag is YES, archiving of data needs to be done. Insert data into correspodning AR tables */

       IF p_archive_flag='Y' THEN

          Pa_Debug.DEBUG('Inserting Records into pa_wf_processes_AR table  ') ;
          x_err_stage := 'Inserting Records into pa_wf_processes_AR table for item key '||l_item_key ;

          INSERT INTO pa_wf_processes_ar
               (purge_batch_id,
                purge_release,
                purge_project_id,
                wf_type_code,
                item_type,
                item_key,
                entity_key1,
                entity_key2,
                description,
                last_updated_by,
                last_update_date,
                creation_date,
                created_by,
                last_update_login)
          SELECT  p_purge_batch_id,
                  p_purge_release,
                  p_project_id,
                  wf_type_code,
                  item_type,
                  item_key,
                  entity_key1,
                  entity_key2,
                  description,
                  last_updated_by,
                  last_update_date,
                  creation_date,
                  created_by,
                  last_update_login
             FROM pa_wf_processes
            WHERE entity_key1  = TO_CHAR(p_project_id)
              AND entity_key2  = p_entity_key2
              AND wf_type_code = p_wf_type_code
              AND item_type    = p_item_type;

 /*Increase the value of l_nos_wf_process_inserted to indicate number of records inserted in pa_wf_processes_ar table.
  The value will increase for each loop(item_key)*/
            l_nos_wf_process_inserted := l_nos_wf_process_inserted + SQL%ROWCOUNT;


        END IF; -- p_archive_flag='Y'

/* To keep the count of no of records deleted from pa_wf_processes manipulate the count of l_nos_wf_process_deleted. */

       Pa_Debug.DEBUG('Deleting Records from  pa_wf_processes table  ') ;
       x_err_stage := 'Deleting Records from  pa_wf_processes table for item key '|| l_item_key ;


       DELETE pa_wf_processes
        WHERE entity_key1  = TO_CHAR(p_project_id)
          AND entity_key2  = p_entity_key2
          AND wf_type_code = p_wf_type_code
          AND item_type    = p_item_type;

       l_nos_wf_process_deleted := l_nos_wf_process_deleted + SQL%ROWCOUNT;

    -------------------Delete the records from WORKFLOW tables by calling suitable APIs----------------------

     /* Check the item status for the workflow process */
       Wf_Engine.itemstatus ( itemtype  => p_item_type,
                              itemkey   => l_item_key,
                              status    => l_status,
                              result    => l_result );
       /* If the status of the item is ACTIVE, the process need to be aborted before purging */
       IF l_status = 'ACTIVE' THEN

        Wf_Engine.abortprocess ( itemtype  => p_item_type,
                                 itemkey   => l_item_key );
       END IF;

       /* Purge the record from workflow tables.*/
       Wf_Purge.total( itemtype  => p_item_type,
                       itemkey   => l_item_key );


   END LOOP;

  CLOSE cur_workflow;

  /*After "deleting" or "deleting and inserting" a set of records the transaction is commited.
    This also creates a record in the Pa_Purge_Project_details, which will show the no. of
    records that are purged from each table.The procedure is called once for pa_wf_processes tables */

       	Pa_Purge.CommitProcess(p_purge_batch_id,
	                       p_project_id,
	                       'PA_WF_PROCESSES',
	                       l_nos_wf_process_inserted,
	                       l_nos_wf_process_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

    x_err_stack := l_old_err_stack; -- Added for bug 4227589
EXCEPTION
  WHEN Pa_Project_Utils2.PA_Arch_Pur_Subroutine_Error THEN
       RAISE Pa_Project_Utils2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    Pa_Debug.DEBUG('Error Procedure Name  := PA_PURGE_PJR_TXNS.PA_WF_KEY_PURGE');
    Pa_Debug.DEBUG('Error stage is '||x_err_stage );
    Pa_Debug.DEBUG('Error stack is '||x_err_stack );
    Pa_Debug.DEBUG(SQLERRM);
    Pa_Project_Utils2.g_sqlerrm := SQLERRM ;

    RAISE Pa_Project_Utils2.PA_Arch_Pur_Subroutine_Error ;


END PA_WF_KEY_PURGE;

END;

/
