--------------------------------------------------------
--  DDL for Package Body PA_REP_UTIL_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_REP_UTIL_SETUP" as
/* $Header: PARRSETB.pls 120.1 2005/08/19 17:00:27 mwasowic noship $ */

/*
 * This procedure reads profile and set the flag of CDL data to X of all
 * records before the cut off date define in the profile
 */


PROCEDURE set_flag_cut_off_records(
                                  errbuf                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                 ,retcode               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                 ,p_debug_mode          IN  VARCHAR2
                                  )
  IS

  l_records_update  NUMBER :=0;
  l_total_records   NUMBER :=0;
  l_cut_off_date    DATE;
  l_commit_size     PLS_INTEGER;
  l_fnd_msg         VARCHAR2 (2000);
  l_debug varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  CURSOR discarded_records(p_cut_off_date IN DATE) IS
  select cdl.rowid
	from  pa_expenditure_items_all          ei
             ,pa_cost_distribution_lines_all   cdl
    where ei.expenditure_item_date < p_cut_off_date
    and ei.expenditure_item_id = cdl.expenditure_item_id;


BEGIN
    /*
     *  To Initialize the error stack
     */
    PA_DEBUG.Set_Curr_Function(
                                p_function   => 'Set_Flag_Cut_Off_Records',
                                p_process    => 'PLSQL',
                                p_write_file => 'LOG',
                                p_debug_mode => p_debug_mode);

     PA_DEBUG.g_err_stage := 'Process : Set Flag of Cut Off Records';
     PA_DEBUG.Log_Message(p_message    => PA_DEBUG.g_err_stage,
                         p_write_file => 'OUT');
    /*
     * Assume Success
     */

    retcode := 0;
    /*
     * Set Util_Summarized_Flag to X of all Records having date before
     * the profile date
     */

   IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := 'Arguments';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := '---------';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    PA_DEBUG.g_err_stage := 'p_debug_mode        : '||p_debug_mode;
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := '50 : before geting the value of global commit size';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   END IF;

    l_commit_size     := pa_rep_util_glob.G_util_fetch_size;

   IF l_debug ='Y'THEN -- bug 2674619
    PA_DEBUG.g_err_stage := 'l_commit_size        : '||to_char(nvl(l_commit_size,0));
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := '100 : after geting the value of global commit size';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

    PA_DEBUG.g_err_stage := '150 : before geting the value of profile PA_UTL_START_DATE';
    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   END IF;

    l_cut_off_date :=FND_PROFILE.VALUE('PA_UTL_START_DATE');

    IF l_cut_off_date IS NULL THEN
      retcode := 2;
      errbuf  := 'The profile PA_UTL_START_DATE is not defined and its value is  null';
      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.g_err_stage := '200 : The PA_UTL_START_DATE is not defined and its value is  null';
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;
      FND_MESSAGE.Set_Name('PA','PA_UTL_START_DATE');
      l_fnd_msg := FND_MESSAGE.Get;
      PA_DEBUG.Log_Message(p_message    => l_fnd_msg,
                           p_write_file => 'OUT');
      PA_Debug.Reset_Curr_Function;
      RETURN;
    END IF;

    IF l_debug ='Y'THEN -- bug 2674619
     PA_DEBUG.g_err_stage := 'PA_UTL_START_DATE Profile Value:'||TO_CHAR(l_cut_off_date,'DD-MON-YYYY');
     PA_DEBUG.log_message(PA_DEBUG.g_err_stage);

     PA_DEBUG.g_err_stage := 'Set util_summarized_flag to X of all records having date before cutoff date';
     PA_DEBUG.log_message(PA_DEBUG.g_err_stage);

     PA_DEBUG.g_err_stage := '250 : Before Update CDL flag to X';
     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

    for rec in discarded_records(l_cut_off_date)
      LOOP
        UPDATE pa_cost_distribution_lines_all  cdl
        SET cdl.util_summarized_flag = 'X'
        WHERE rowid = rec.rowid;

        l_records_update := l_records_update + 1;
        l_total_records  := l_total_records + 1;
        IF l_records_update = l_commit_size THEN
           commit;
           l_records_update := 0;
        END IF;
      END LOOP;
      IF l_debug ='Y'THEN -- bug 2674619
       PA_DEBUG.g_err_stage := '300 : After  update the CDL Flag';
       PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;

      IF l_debug ='Y'THEN -- bug 2674619
       PA_DEBUG.g_err_stage := 'Process completed successfully, '||to_char(l_total_records)||' Records discarded';
       PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
      END IF;
      PA_DEBUG.Reset_curr_function;

EXCEPTION
    WHEN OTHERS THEN
      retcode := 2;
      errbuf  := SUBSTR(SQLERRM,1,240);
      IF l_debug ='Y'THEN -- bug 2674619
      PA_DEBUG.Log_Message( SQLERRM);
      PA_DEBUG.Log_Message(PA_DEBUG.g_err_stack);
      END IF;
      FND_MSG_PUB.add_exc_msg ( p_pkg_name       => 'PA_REP_UTIL_SETUP.set_flag_cut_off_records'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack );
      RAISE;
      PA_DEBUG.Reset_curr_function;
END set_flag_cut_off_records;
END PA_REP_UTIL_SETUP;

/
