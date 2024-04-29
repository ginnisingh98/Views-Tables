--------------------------------------------------------
--  DDL for Package Body PAY_SLA_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SLA_UPDATE_PKG" AS
/* $Header: payxlaupg.pkb 120.0.12010000.4 2009/01/28 10:00:51 priupadh noship $*/
g_pkg_name          CONSTANT VARCHAR2(30) := 'PAY_SLA_UPDATE_PKG';
gv_process_name     CONSTANT varchar2(10) := 'PAYSLAUPG';

g_xla_tran_s xla_transaction_entities.entity_id%type;
g_xla_event_s xla_events.event_id%type;
g_xla_headers_s xla_ae_headers.ae_header_id%type;

-------------------------------------------------------------------------------------
--  Name       : Trans_Pay_Patch_Status
--  Function   : To transfer qualified periods to PAY_PATCH_STATUS.
--               Period should be Closed/Permanently Closed , Non Adjustment
--               and between Start Period and End Period both inclusive .
--
--              Column Values
--              ==============
--              ID           = Pay_Patch_Status_s.Nextval
--              Patch Number = Ledger Id
--              Patch Name   = Period Name
--              Process Type = 'PAYSLAUPG'
--              Status       = Null if period needs to be upgraded by this process.
--                           = U if period is already upgraded before.
--              Phase        = 'PAYSLAUPG'||Concurrent Request Id .
--                             To identify what periods are inserted by a particular
--                             Conc Program
-------------------------------------------------------------------------------------

PROCEDURE Trans_Pay_Patch_Status
     (p_Ledger_Id     IN VARCHAR2,
      p_Start_Period  IN VARCHAR2,
      p_End_Period    IN VARCHAR2)
IS
    CURSOR csr_Get_Periods IS
    SELECT   gps.Ledger_Id Ledger_Id,
             gps.Period_Name Period_Name
    FROM     gl_Period_Statuses gps
    WHERE    gps.Ledger_Id = p_Ledger_Id
             AND gps.cLosing_Status IN ('C','P')
             AND gps.Adjustment_Period_Flag = 'N'
             AND gps.Application_Id = '101'
             AND gps.Start_Date >= (SELECT Start_Date
                                    FROM   gl_Period_Statuses
                                    WHERE  Ledger_Id = p_Ledger_Id
                                           AND Application_Id = '101'
                                           AND Period_Name = p_Start_Period)
             AND (gps.End_Date <= (SELECT End_Date
                                  FROM   gl_Period_Statuses
                                  WHERE  Ledger_Id = p_Ledger_Id
                                         AND Application_Id = '101'
                                         AND Period_Name = p_End_Period)
                  OR p_End_Period is null)
             AND EXISTS (SELECT 1
                         FROM   Pay_All_Payrolls_f pp
                         WHERE  pp.gl_Set_Of_Books_Id IS NOT NULL
                                AND gps.Ledger_Id = pp.gl_Set_Of_Books_Id)
    ORDER BY gps.Start_Date;

    lv_temp  NUMBER(5);

BEGIN
/* Transfer rows from GL_PERIOD_STATUS to PAY_PATCH_STATUS */

  FOR a IN csr_Get_Periods LOOP
    lv_temp := NULL;

    BEGIN
      SELECT 1
      INTO   lv_temp
      FROM   Dual
      WHERE  EXISTS (SELECT 1
                     FROM   Pay_Patch_Status pps
                     WHERE  Process_Type = gv_process_name
                            AND pps.Patch_Number = a.Ledger_Id
                            AND pps.Patch_Name = a.Period_Name
                            AND Status = 'U');
    EXCEPTION
      WHEN No_Data_Found THEN
        lv_temp := 0;
    END;
    /* If already upgraded thenset status as U else Null */

    IF lv_temp = 0 THEN
      INSERT INTO Pay_Patch_Status
                 (Id,
                  Patch_Number,
                  Patch_Name,
                  Process_Type,
                  Status,
                  Phase,
                  update_date)
      VALUES     (Pay_Patch_Status_s.Nextval,
                  a.Ledger_Id,
                  a.Period_Name,
                  gv_process_name,
                  NULL,
                  gv_process_name||fnd_Global.Conc_Request_Id,
                  sysdate  );
    ELSIF lv_temp = 1 THEN
      INSERT INTO Pay_Patch_Status
                 (Id,
                  Patch_Number,
                  Patch_Name,
                  Process_Type,
                  Status,
                  Phase,
                  Description,
                  update_date)
      VALUES     (Pay_Patch_Status_s.Nextval,
                  a.Ledger_Id,
                  a.Period_Name,
                  gv_process_name,
                  'U',
                  gv_process_name||fnd_Global.Conc_Request_Id,
                  'Period already Upgraded',
                  sysdate);
    END IF;
  END LOOP;

  COMMIT;
END;
-------------------------------------------------------------------------------------
--  Name       : Update_Proc_MGR
--  Function   : This is the Manager Process called by Conc Program
--               Upgrade Historical Payroll Data to SLA.
-------------------------------------------------------------------------------------

PROCEDURE Update_Proc_PAY_MGR (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               p_ledger_id      in  varchar2,
               p_start_period   in  varchar2,
               p_end_period     in  varchar2,
               p_debug_flag     in  varchar2,
               X_batch_size     in  number default 1,
               X_Num_Workers    in  number default 5,
               X_Argument4      in  varchar2 default null,
               X_Argument5      in  varchar2 default null,
               X_Argument6      in  varchar2 default null,
               X_Argument7      in  varchar2 default null,
               X_Argument8      in  varchar2 default null,
               X_Argument9      in  varchar2 default null,
               X_Argument10     in  varchar2 default null)
IS

  l_module       CONSTANT VARCHAR2(90) := 'PAY_SLA_UPDATE_PKG.Update_Proc_MGR';

  l_stmt_num     number;
  l_api_name     CONSTANT VARCHAR2(30)   := 'Update_Proc_PAY_MGR';
  l_api_version  CONSTANT NUMBER           := 1.0;

  l_conc_status  BOOLEAN;

  submit_conc_failed EXCEPTION;

  l_phase        varchar2(80);
  l_status_code  varchar2(80);
  l_dev_phase    varchar2(15);
  l_message        varchar2(255);

  L_SUB_REQTAB   fnd_concurrent.requests_tab_type;
  req_data       varchar2(10);
  submit_req     boolean;

  PAY_UPGRADE_RUNNING exception;
  l_prg_appid    number;
  l_program_name varchar2(15);
  l_reqid_count  number;

  l_ret_code varchar2(10);

  l_argument4     number;
  l_argument5     number;
  l_product       varchar2(30);
  l_status        varchar2(30);
  l_industry      varchar2(30);
  l_retstatus     boolean;
  l_table_owner   varchar2(30);
  lv_param_found  boolean default FALSE;
  lv_Num_Workers  number default 1;
  lv_debug_enabled boolean default FALSE;
  lv_no_periods    boolean default TRUE;

Cursor csr_pay_patch_status(p_req_id in number) is
select row_number() over(partition by phase order by id) Nu,patch_number Ledger_id,patch_name Period_name,decode(Status,'U','Upgraded','E','Errored',null) Status,Description description
from pay_patch_status
where PROCESS_TYPE='PAYSLAUPG'
and phase='PAYSLAUPG'||to_char(p_req_id)
and patch_number=p_ledger_id
order by id;

BEGIN

if p_debug_flag = 'Y' then
 lv_debug_enabled := TRUE;
end if;

If lv_debug_enabled then
           fnd_file.put_line(fnd_file.log,'Enter             :'||l_module);
           fnd_file.put_line(fnd_file.log,'In P_LEDGER_ID    :'|| P_LEDGER_ID);
           fnd_file.put_line(fnd_file.log,'In P_START_PERIOD :'|| P_START_PERIOD);
           fnd_file.put_line(fnd_file.log,'In P_END_PERIOD   :'|| P_END_PERIOD);
End if;

  l_stmt_num :=0;
  l_stmt_num :=5;
  l_prg_appid := 801;
  l_program_name := 'PAYSLAUPG';
  l_reqid_count := 0;
  lv_no_periods := TRUE;

  req_data := fnd_conc_global.request_data;

  if (req_data is null) then
     submit_req := TRUE;
  else
     submit_req := FALSE;
  end if;

  if (submit_req = TRUE) then

   if (nvl(fnd_global.conc_request_id, -1) <  0) then
       raise_application_error(-20001, 'SUBMIT_SUBREQUESTS() must be called from a concurrent request');
    end if;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (
             l_api_version,
             1.0,
             l_api_name,
             G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_retcode := FND_API.G_RET_STS_SUCCESS;

    l_product :='PAY';

    l_stmt_num :=10;
    l_retstatus := fnd_installation.get_app_info(
                       l_product, l_status, l_industry, l_table_owner);

    if ((l_retstatus = TRUE) AND (l_table_owner is not null)) then

       Begin

          /* Call Trans_pay_patch_status to Transfer rows from GL_PERIOD_STATUS to PAY_PATCH_STATUS */

              If lv_debug_enabled then
                 fnd_file.put_line(fnd_file.log,'Before Trans_pay_patch_status ');
              End if;

               Trans_pay_patch_status (
               P_LEDGER_ID     => P_LEDGER_ID,
               P_START_PERIOD  => P_START_PERIOD,
               P_END_PERIOD    => P_END_PERIOD);

              If lv_debug_enabled then
                         fnd_file.put_line(fnd_file.log,'After Trans_pay_patch_status ');
              End if;

             lv_Num_Workers := X_Num_Workers;
          /* Get the Pay Action Parameter Value of THREADS  */

              If lv_debug_enabled then
                         fnd_file.put_line(fnd_file.log,'Before pay_core_utils.get_action_parameter ');
              End if;

             pay_core_utils.get_action_parameter('THREADS',lv_Num_Workers,lv_param_found);

              if (not lv_param_found) then
                 lv_Num_Workers := x_Num_Workers;
              end if;

              If lv_debug_enabled then
                         fnd_file.put_line(fnd_file.log,'No of Workers :'||to_char(lv_Num_Workers));
              End if;

              If lv_debug_enabled then
                         fnd_file.put_line(fnd_file.log,'After pay_core_utils.get_action_parameter ');
              End if;

            begin

              If lv_debug_enabled then
                         fnd_file.put_line(fnd_file.log,'Before AD_CONC_UTILS_PKG.submit_subrequests ');
              End if;

                  AD_CONC_UTILS_PKG.submit_subrequests(
                         X_errbuf=>X_errbuf,
                         X_retcode=>X_retcode,
                         X_WorkerConc_app_shortname=>'PAY',
                         X_WorkerConc_progname=>'PAYSLAUPGW',
                         X_Batch_size=>X_batch_size,
                         X_Num_Workers=>lv_Num_Workers,
                         X_Argument4 => P_LEDGER_ID,
                         X_Argument5 => P_START_PERIOD,
                         X_Argument6 => nvl(P_END_PERIOD,'null'),
                         X_Argument7 => fnd_global.conc_request_id,
                         X_Argument8 => P_DEBUG_FLAG,
                         X_Argument9 => null,
                         X_Argument10 => null);

             exception when others then
                 fnd_file.put_line(FND_FILE.LOG,'Error '||sqlcode ||'   '||sqlerrm);

             end;

              If lv_debug_enabled then
                         fnd_file.put_line(fnd_file.log,'After AD_CONC_UTILS_PKG.submit_subrequests ');
              End if;
       exception
          when no_data_found then
            fnd_file.put_line(FND_FILE.LOG, 'No Payroll Sub Ledger data needs to be upgraded.');

        end;
    end if;
else

     l_sub_reqtab := fnd_concurrent.get_sub_requests(fnd_global.conc_request_id);

     x_retcode := FND_API.G_RET_STS_SUCCESS;

     for i IN 1..l_sub_reqtab.COUNT()
     loop

        if (l_sub_reqtab(i).dev_status <> 'NORMAL') then
           X_retcode := FND_API.g_ret_sts_unexp_error;
        end if;

     end loop;

     if (X_retcode = FND_API.G_RET_STS_SUCCESS) then
        fnd_file.put_line(FND_FILE.LOG,'--------------------------------------------------------------------------------------');
        fnd_file.put_line(FND_FILE.LOG,'-------------------Upgrade of Historical Payroll data to Subledger Accounting---------');
        fnd_file.put_line(FND_FILE.LOG,'--------------------------------------------------------------------------------------');
        fnd_file.put_line(FND_FILE.LOG,'Parameters:');
        fnd_file.put_line(FND_FILE.LOG,'Ledger Id    : '||p_ledger_id);
        fnd_file.put_line(FND_FILE.LOG,'Start Period : '||p_start_period);
        fnd_file.put_line(FND_FILE.LOG,'End Period   : '||p_end_period);

        fnd_file.put_line(FND_FILE.LOG,'--------------------------------------------------------------------------------------');
        fnd_file.put_line(FND_FILE.LOG,'  No   Period Name  Status     Message                                                ');
        fnd_file.put_line(FND_FILE.LOG,'--------------------------------------------------------------------------------------');


        For b in csr_pay_patch_status(fnd_global.conc_request_id)
        loop
        fnd_file.put_line(FND_FILE.LOG,'  '||substr(rpad(to_char(b.nu),3,' '),1,4)||'  '||b.period_name||'      '||b.status||'   '||b.Description);
        lv_no_periods := FALSE;
        end loop;

        If lv_no_periods then
        fnd_file.put_line(FND_FILE.LOG,' There are no Closed/Permanently Closed Periods between this Start Date and End Date');
        end if;

        fnd_file.put_line(FND_FILE.LOG,'--------------------------------------------------------------------------------------');
        fnd_file.put_line(FND_FILE.LOG,'--------------------------------------------------------------------------------------');
     end if;
end if;

If lv_debug_enabled then
    fnd_file.put_line(fnd_file.log,'Leaving             :'||l_module);
End if;

EXCEPTION
   WHEN submit_conc_failed THEN
    X_retcode := FND_API.g_ret_sts_unexp_error;
    X_errbuf:=l_module||'.'||l_stmt_num||': Submit concurrent request failed.';
    l_conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',X_errbuf);

   WHEN fnd_api.g_exc_unexpected_error THEN
    X_retcode := FND_API.g_ret_sts_unexp_error;

    X_errbuf:=l_module||'.'||l_stmt_num||': An exception has occurred.';
    l_conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',X_errbuf);

  WHEN fnd_api.g_exc_error THEN
    X_retcode := FND_API.g_ret_sts_error;

    X_errbuf:=l_module||'.'||l_stmt_num||': '|| SQLERRM;
    l_conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',X_errbuf);

  WHEN OTHERS THEN
    X_retcode := FND_API.g_ret_sts_unexp_error;
    X_errbuf:=l_module||'.'||l_stmt_num||': '|| SQLERRM;
    l_conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',X_errbuf);

END Update_Proc_PAY_MGR;

----------------------------------------------------------------------------------------
--  Name       : Update_Proc_PAY_WKR
--  Function   : Worker process to update Payroll Sub Ledger to SLA data model.
--               This is called by Manager Procewss Update_Proc_PAY_MGR

----------------------------------------------------------------------------------------
PROCEDURE Update_Proc_PAY_WKR (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_batch_size  in number,
               X_Worker_Id   in number,
               X_Num_Workers in number,
               X_Argument4   in varchar2 default null,
               X_Argument5   in varchar2 default null,
               X_Argument6   in varchar2 default null,
               X_Argument7   in varchar2 default null,
               X_Argument8   in varchar2 default null,
               X_Argument9   in varchar2 default null,
               X_Argument10  in varchar2 default null)
IS

  l_module       CONSTANT VARCHAR2(90) := 'PAY_SLA_UPDATE_PKG.Update_Proc_WKR';
  l_worker_id  number;
  l_product     varchar2(30);
  l_table_name      varchar2(30) := 'PAY_PATCH_STATUS';
  l_id_column       varchar2(30) := 'ID';
  l_update_name     varchar2(30);

  l_table_owner      varchar2(30);
  l_status           VARCHAR2(30);
  l_industry         VARCHAR2(30);
  l_retstatus        BOOLEAN;
  l_any_rows_to_process  boolean;

  l_start_id     number;
  l_end_id       number;
  l_rows_processed  number;

  l_stmt_num      number;
  update_subledger_exception exception;
  l_conc_status  BOOLEAN;
  lv_debug_enabled boolean default FALSE;

BEGIN
  l_stmt_num :=0;
  if X_Argument8 = 'Y' then /* X_Argument8 = P_DEBUG_FLAG */
     lv_debug_enabled := TRUE;
  end if;

If lv_debug_enabled then
    fnd_file.put_line(fnd_file.log,'Enter                        :'||l_module);
    fnd_file.put_line(fnd_file.log,'In P_LEDGER_ID(X_Argument4)  :'|| X_Argument4);
End if;
  --
  BEGIN
    l_stmt_num :=10;

    l_update_name := 'PAYSLA' ||X_Argument7;
    l_retstatus := FND_INSTALLATION.GET_APP_INFO('GL', l_status, l_industry, l_table_owner);
    l_table_owner:='HR';


    ad_parallel_updates_pkg.initialize_id_range(
                 X_update_type=>ad_parallel_updates_pkg.ID_RANGE,
                 X_owner=>l_table_owner,
                 X_table=>l_table_name,
                 X_script=>l_update_name,
                 X_ID_column=>l_id_column,
                 X_worker_id=>X_Worker_Id,
                 X_num_workers=>X_num_workers,
                 X_batch_size=>X_batch_size,
                 X_debug_level=>0);


    ad_parallel_updates_pkg.get_id_range(
           l_start_id,
           l_end_id,
           l_any_rows_to_process,
           X_batch_size,
           TRUE);


    while (l_any_rows_to_process = TRUE)
    loop
      l_stmt_num :=30;
      If lv_debug_enabled then
         fnd_file.put_line(fnd_file.log,'Before calling Update_Payroll_Subledger');
         fnd_file.put_line(fnd_file.log,'l_start_id :'||l_start_id);
         fnd_file.put_line(fnd_file.log,'l_end_id   :'||l_end_id);
      End if;

      PAY_SLA_UPDATE_PKG.Update_Payroll_Subledger(
                  X_errbuf=>X_errbuf,
                  X_retcode=>X_retcode,
                  X_start_id=>l_start_id,
                  X_end_id=>l_end_id,
                  P_LEDGER_ID=>X_Argument4,
                  P_MGR_REQ_ID=>X_Argument7,
                  P_DEBUG_FLAG=>X_Argument8);

      If lv_debug_enabled then
         fnd_file.put_line(fnd_file.log,'After calling Update_Payroll_Subledger');
      End if;

      if (X_retcode <>FND_API.G_RET_STS_SUCCESS) then
          raise update_subledger_exception;
      end if;

      l_rows_processed := X_batch_size;

      l_stmt_num :=40;

      ad_parallel_updates_pkg.processed_id_range(
          l_rows_processed,
          l_end_id);

      commit;

      l_stmt_num :=50;
      ad_parallel_updates_pkg.get_id_range(
         l_start_id,
         l_end_id,
         l_any_rows_to_process,
         X_batch_size,
         FALSE);

    end loop;

    X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

  EXCEPTION
  WHEN OTHERS THEN
    X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
    X_errbuf:=l_module||'.'||l_stmt_num||': '|| SQLERRM;
    raise;
  END;

If lv_debug_enabled then
   fnd_file.put_line(fnd_file.log,'Leaving                      :'||l_module);
End if;

EXCEPTION
WHEN update_subledger_exception THEN
    ROLLBACK;
    X_errbuf:=l_module||'.'||l_stmt_num||': '|| SQLERRM;
    l_conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',X_errbuf);

WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    X_errbuf:=l_module||'.'||l_stmt_num||': An exception has occurred.';
    l_conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',X_errbuf);

WHEN fnd_api.g_exc_error THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_error;
    X_errbuf:=l_module||'.'||l_stmt_num||': '|| SQLERRM;
    l_conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',X_errbuf);

WHEN OTHERS THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    X_errbuf:=l_module||'.'||l_stmt_num||': '|| SQLERRM;
    l_conc_status:=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',X_errbuf);

END Update_Proc_PAY_WKR;

----------------------------------------------------------------------------------------
--  Name       : GET_SEQUENCE_VALUE
--  Function   : TO get the sequence values for XLA Sequences .
----------------------------------------------------------------------------------------

FUNCTION get_sequence_value(p_row_number in number,p_tab_name varchar2)
return number is
BEGIN

if p_tab_name='xla_transaction_entities' then
   If p_row_number = 1 then
     select xla_transaction_entities_s.nextval,
            xla_events_s.nextval,
            xla_ae_headers_s.nextval
     into g_xla_tran_s,g_xla_event_s,g_xla_headers_s
     from dual;
          return g_xla_tran_s;
   else
          return g_xla_tran_s;
   end if;
end if;

if p_tab_name='xla_events' then
          return g_xla_event_s;
end if;

if p_tab_name='xla_ae_headers' then
         return g_xla_headers_s;
end if;

END get_sequence_value;

----------------------------------------------------------------------------------------
--  Name       : GET_FULL_NAME
--  Function   : TO get the Full Name from Assignment_Action_Id
----------------------------------------------------------------------------------------

FUNCTION get_full_name(p_assignment_act_id in pay_assignment_actions.assignment_action_id%type,
                       p_eff_date in date)
return varchar2 is

Cursor csr_full_name(p_assnmnt_act_id in pay_assignment_actions.assignment_action_id%type,
                     p_eff_date in date)
is
select full_name
from per_people_f ppf,
     per_assignments_f paf,
     pay_assignment_actions paa
where paa.assignment_id=paf.assignment_id
and   paf.person_id=ppf.person_id
and   paa.assignment_action_id=p_assnmnt_act_id
and   p_eff_date between ppf.effective_start_date and ppf.effective_end_date;

lv_full_name varchar2(240);
BEGIN

      open csr_full_name(p_assignment_act_id,p_eff_date);
      fetch csr_full_name into lv_full_name;
      close csr_full_name;

return lv_full_name;
END get_full_name;


-------------------------------------------------------------------------------------
--  Name       : Update_Payroll_Subledger
--  Type       : Private
--  Function   : To update Payroll Sub Ledger to SLA data model from Start ID
--               to End ID for Ledger (P_LEDGER_ID).
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_start_id     in  number
--                     X_end_id       in  number
--                     P_LEDGER_ID    in varchar2
--                     P_MGR_REQ_ID in varchar2
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--
--  Notes      : The Procedure is called from Update_Proc_PAY_WKR.
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE Update_Payroll_Subledger (
               x_errbuf     out nocopy varchar2,
               x_retcode    out nocopy varchar2,
               x_start_id      in number,
               x_end_id        in number,
               p_ledger_id     in varchar2,
               p_mgr_req_id    in varchar2,
               p_debug_flag    in varchar2
)
IS

   l_module            CONSTANT VARCHAR2(90) := 'PAY_SLA_UPDATE_PKG.Update_Payroll_Subledger';
   lv_application_id   CONSTANT number := 801;
   l_upg_batch_id      number;
   lv_Error_msg        varchar2(1000);
   lv_application_name CONSTANT varchar2(10) := 'Payroll';
   lv_debug_enabled boolean default FALSE;

 Cursor csr_get_periods(p_start_id in pay_patch_status.id%type,
                        p_end_id   in pay_patch_status.id%type,
                        p_process_name in varchar2,
                        p_mgr_req_id   in varchar2)
 is
 select  patch_number ledger_id,patch_name period_name
 from pay_patch_status
 where id between p_start_id and p_end_id
 and process_type=p_process_name
 and phase = p_process_name||p_mgr_req_id
 and patch_number=p_ledger_id
 and  status is null;

 Cursor csr_get_headers(p_ledger_id   in gl_je_headers.ledger_id%type,
                        p_period_name in gl_je_headers.period_name%type,
                        p_app_name    in varchar2)
 is
 select je_header_id
 from gl_je_headers gjh
 where  gjh.period_name=p_period_name
 and     gjh.je_category=p_app_name
 and     gjh.ledger_id=p_ledger_id
 and     gjh.je_source=p_app_name
 order by je_header_id;

BEGIN

if p_debug_flag = 'Y' then
 lv_debug_enabled := TRUE;
end if;

If lv_debug_enabled then
    fnd_file.put_line(fnd_file.log,'Enter           :'||l_module);
    fnd_file.put_line(fnd_file.log,'In P_LEDGER_ID  :'|| P_LEDGER_ID);
    fnd_file.put_line(fnd_file.log,'In X_START_ID   :'|| to_char(X_start_id));
    fnd_file.put_line(fnd_file.log,'In X_END_ID     :'|| to_char(X_end_id));
    fnd_file.put_line(fnd_file.log,'In P_MGR_REQ_ID :'|| to_char(p_mgr_req_id));
End if;

 l_upg_batch_id    := to_number(p_mgr_req_id);

 g_xla_tran_s :=0;
 g_xla_event_s :=0;
 g_xla_headers_s :=0;

  For j in csr_get_periods(X_start_id ,X_end_id,gv_process_name,to_char(p_mgr_req_id))
  Loop

  If lv_debug_enabled then
       fnd_file.put_line(fnd_file.log,'Before upgrading ledger_id        :'|| j.ledger_id);
       fnd_file.put_line(fnd_file.log,'Before upgrading period_name      :'|| j.period_name);
       fnd_file.put_line(fnd_file.log,'Before upgrading gv_process_name  :'|| gv_process_name);
  End if;

    Begin

    If lv_debug_enabled then
       fnd_file.put_line(fnd_file.log,'Before updating GL Tables ');
    End if;

       For l in csr_get_headers(j.ledger_id,j.period_name,lv_application_name)
       Loop

         update gl_je_headers
         set je_from_sla_flag='Y'
         where je_header_id=l.je_header_id;

         update gl_je_lines
         set gl_sl_link_id=XLA_GL_SL_LINK_ID_S.nextval ,
            gl_sl_link_table='XLAJEL'
         where je_header_id =l.je_header_id;

         update gl_import_references gir
         set gir.gl_sl_link_id = (select gl_sl_link_id from gl_je_lines gjl1
                                  where  gir.je_header_id = gjl1.je_header_id
                                  and   gir.je_line_num=gjl1.je_line_num),
             gir.gl_sl_link_table ='XLAJEL'
         where gir.je_header_id = l.je_header_id
         and gir.je_line_num = (select je_line_num from gl_je_lines gjl
                                where  gir.je_header_id = gjl.je_header_id
                                and   gir.je_line_num=gjl.je_line_num);

       End loop;

    If lv_debug_enabled then
       fnd_file.put_line(fnd_file.log,'After updating GL Tables ');
    End if;

    If lv_debug_enabled then
       fnd_file.put_line(fnd_file.log,'Before Inserting into XLA Tables ');
    End if;

        INSERT ALL
        WHEN (rank_id=1) then
        INTO xla_transaction_entities (
            upg_batch_id,
            entity_id,
            application_id,
            ledger_id,
            entity_code,
            source_id_int_1,
            source_id_char_1,
            transaction_number,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            source_application_id,
            upg_source_application_id)
        VALUES (l_upg_batch_id,
            xla_transaction_seq,
            lv_application_id,
            ledger_id,
            'ASSIGNMENTS',
             TGL_ASSIGNMENT_ACTION_ID,
             To_char(EFFECTIVE_DATE,'YYYY/MM/DD'),
             TGL_ASSIGNMENT_ACTION_ID,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            lv_application_id,
            lv_application_id)
        INTO xla_events (
            upg_batch_id,
            application_id,
            entity_id,
            event_id,
            event_number,
            event_type_code,
            event_date,
            event_status_code,
            process_status_code,
            on_hold_flag,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            transaction_date,
            upg_source_application_id)
        VALUES (l_upg_batch_id,
            lv_application_id,
            xla_transaction_seq,
            xla_events_seq,
            1,
            EVENT_TYPE_CODE,
            EFFECTIVE_DATE,
            'P',
            'P',
            'N',
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            EFFECTIVE_DATE,
            lv_application_id)
        INTO xla_ae_headers (
            upg_batch_id,
            application_id,
            amb_context_code,
            entity_id,
            event_id,
            event_type_code,
            ae_header_id,
            ledger_id,
            je_category_name,
            accounting_date,
            period_name,
            balance_type_code,
            gl_transfer_status_code,
            gl_transfer_date,
            accounting_entry_status_code,
            accounting_entry_type_code,
            description,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            zero_amount_flag,
            accrual_reversal_flag,
            upg_source_application_id)
        VALUES (l_upg_batch_id,
            lv_application_id,
            'DEFAULT',
             xla_transaction_seq,
             xla_events_seq,
            EVENT_TYPE_CODE,
            xla_ae_headers_seq,
            ledger_id,
            lv_application_name,
            EFFECTIVE_DATE,
            period_name,
            'A',
            'Y',
            effective_date,
            'F',
            'STANDARD',
            header_desc,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            'N',
            'N',
            lv_application_id)
        INTO pay_xla_events(
           event_id,
           assignment_action_id,
           accounting_date,
           event_status)
        VALUES(xla_events_seq,
               TGL_ASSIGNMENT_ACTION_ID,
               EFFECTIVE_DATE,
               'P')
        WHEN (1=1) then
        INTO xla_ae_lines (
            upg_batch_id,
            application_id,
            ae_header_id,
            ae_line_num,
            code_combination_id,
            gl_transfer_mode_code,
            description,
            accounted_dr,
            accounted_cr,
            currency_code,
            currency_conversion_date,
            currency_conversion_rate,
            currency_conversion_type,
            entered_dr,
            entered_cr,
            accounting_class_code,
            gl_sl_link_id,
            gl_sl_link_table,
            gain_or_loss_flag,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            accounting_date,
            ledger_id,
            mpa_accrual_entry_flag)
        VALUES (l_upg_batch_id,
            lv_application_id,
            xla_ae_headers_seq,
            rank_id,
            code_combination_id,
            'S',
            line_desc,
            accounted_dr,
            accounted_cr,
            currency_code,
            currency_conversion_date,
            currency_conversion_rate,
            currency_conversion_type,
            entered_dr,
            entered_cr,
            'COST',
            link_id,
            'XLAJEL',
            'N',
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            EFFECTIVE_DATE,
            ledger_id,
            'N')
        INTO xla_distribution_links (
            upg_batch_id,
            application_id,
            event_id,
            ae_header_id,
            ae_line_num,
            source_distribution_type,
            source_distribution_id_num_1,
            merge_duplicate_code,
            ref_ae_header_id,
            temp_line_num,
            event_class_code,
            event_type_code)
        VALUES (l_upg_batch_id,
            lv_application_id,
            xla_events_seq,
            xla_ae_headers_seq,
            rank_id,
            action_type,
            TGL_ASSIGNMENT_ACTION_ID,
            'N',
            xla_ae_headers_seq,
            rank_id,
            EVENT_CLASS_CODE,
            DIS_EVENT_TYPE_CODE)
        SELECT row_number() over(partition by tgl_assignment_action_id order by debit_or_credit) RANK_ID,
        get_sequence_value((row_number() over(partition by tgl_assignment_action_id order by debit_or_credit)),'xla_transaction_entities') xla_transaction_seq,
        get_sequence_value((row_number() over(partition by tgl_assignment_action_id order by debit_or_credit)),'xla_events') xla_events_seq,
        get_sequence_value((row_number() over(partition by tgl_assignment_action_id order by debit_or_credit)),'xla_ae_headers') xla_ae_headers_seq,
        ledger_id,
        period_name,
        je_header_id,
        currency_code,
        currency_conversion_date,
        currency_conversion_rate,
        currency_conversion_type,
        effective_date,
        tgl_assignment_action_id,
        code_combination_id,
        costing_assignment_action_id,
        link_id,
        cost_allocation_keyflex_id,
        element_name,
        debit_or_credit,
        entered_dr,
        entered_cr,
        (entered_dr*currency_conversion_rate) accounted_dr,
        (entered_cr*currency_conversion_rate) accounted_cr,
        decode(action_type,'C','COST','CP','PAYMENT_COST','S','RETRO_COST') event_type_code,
        decode(action_type,'C','COSTS_ALL','CP','PAYMENT_COSTS_ALL','COSTS_ALL') dis_event_type_code,
        decode(action_type,'C','COSTS','CP','PAYMENT_COSTS','COSTS') event_class_code,
        decode(action_type,'CP','Payment Cost for '||get_full_name(tgl_assignment_action_id,effective_date)||' on '||effective_date) header_desc,
        decode(action_type,'C',debit_or_credit ||' Cost for '||Element_name,'CP',debit_or_credit||' payment cost') line_desc,
        action_type,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login
        From
        (SELECT distinct gjh.ledger_id LEDGER_ID,
                gjh.period_name PERIOD_NAME,
                gjh.je_header_id JE_HEADER_ID,
                gjh.currency_code,
                gjh.currency_conversion_date,
                gjh.currency_conversion_rate,
                gjh.currency_conversion_type,
                gjl.effective_date EFFECTIVE_DATE,
                pa.assignment_action_id TGL_ASSIGNMENT_ACTION_ID,
                gjl.code_combination_id CODE_COMBINATION_ID,
                gjl.gl_sl_link_id LINK_ID,
                gjl.creation_date,
                gjl.created_by,
                gjl.last_update_date,
                gjl.last_updated_by,
                gjl.last_update_login,
                pcv.assignment_action_id COSTING_ASSIGNMENT_ACTION_ID,
                pcv.cost_allocation_keyflex_id,
                pcv.element_name,
                pcv.debit_or_credit,
                decode(pcv.debit_or_credit,'Debit',pcv.costed_value,null) entered_dr,
                decode(pcv.debit_or_credit,'Credit',pcv.costed_value,null) entered_cr ,
                ppa1.action_type
        FROM    pay_payroll_actions      ppa1,  -- Cost pay actions
                pay_assignment_actions   pa1,   -- Cost asg actions.
                pay_action_interlocks    pi3,   -- Cost - Run
                pay_action_interlocks    pi1,   -- Cost - Trans GL
                pay_all_payrolls_f           pp,
                pay_action_classifications pac,
                pay_payroll_actions      ppa2,  -- Payroll run actions.
                pay_assignment_actions   pa2,   -- Payroll run asg actions.
                pay_action_interlocks    pi2,   -- Run - Trans GL
                pay_assignment_actions   pa,    -- Trans GL asg actions
                pay_payroll_actions      ppa,    -- Trans GL pay actions
                pay_costs_v pcv,
                gl_je_headers gjh,
                gl_je_lines gjl
        WHERE   ppa.payroll_action_id    = to_number(gjl.reference_1)
        AND     pa.payroll_action_id     = ppa.payroll_action_id
        AND     pa.action_status         = 'C'
        AND     ppa2.payroll_action_id   = to_number(gjl.reference_5)
        AND     pcv.cost_allocation_keyflex_id=to_number(gjl.reference_2)
        AND     pi2.locking_action_id    = pa.assignment_action_id
        AND     pa2.assignment_action_id = pi2.locked_action_id
        AND     ppa2.payroll_action_id   = pa2.payroll_action_id
        AND     ppa2.consolidation_set_id +0 = ppa.consolidation_set_id
        AND     pac.action_type          = ppa2.action_type
        AND     pac.classification_name  = 'COSTED'
        AND     pp.payroll_id            = ppa2.payroll_id
        AND     pi1.locking_action_id    = pa.assignment_action_id
        AND     pa1.assignment_action_id = pi1.locked_action_id
        AND     pa1.assignment_action_id <> pa2.assignment_action_id
        AND     pi3.locking_action_id    = pa1.assignment_action_id
        AND     pa2.assignment_action_id = pi3.locked_action_id
        AND     ppa1.payroll_action_id   = pa1.payroll_action_id
        AND     ppa1.action_type         in ('C','S')
        AND     ppa.effective_date   BETWEEN pp.effective_start_date  AND     pp.effective_end_date
        AND     pcv.assignment_action_id=  pa1.assignment_action_id
        AND     gjl.je_header_id=gjh.je_header_id
        AND     decode(gjl.entered_cr,0,'Debit','Credit')=pcv.debit_or_credit
        AND     gjh.period_name=j.period_name
        AND     gjh.je_category=lv_application_name
        AND     gjh.ledger_id= j.ledger_id
        AND     gjh.je_source=lv_application_name
	UNION
        SELECT distinct gjh.ledger_id LEDGER_ID,
                        gjh.period_name PERIOD_NAME,
                        gjh.je_header_id JE_HEADER_ID,
                        gjh.currency_code,
                        gjh.currency_conversion_date,
                        gjh.currency_conversion_rate,
                        gjh.currency_conversion_type,
                        gjl.effective_date EFFECTIVE_DATE,
                        pa.assignment_action_id TGL_ASSIGNMENT_ACTION_ID,
                        gjl.code_combination_id CODE_COMBINATION_ID,
                        gjl.gl_sl_link_id LINK_ID,
                        gjl.creation_date,
                        gjl.created_by,
                        gjl.last_update_date,
                        gjl.last_updated_by,
                        gjl.last_update_login,
                        ppc.assignment_action_id COSTING_ASSIGNMENT_ACTION_ID,
                        ppc.gl_account_ccid,
                        ppc.payment_method_name,
                        ppc.debit_or_credit,
                        decode(ppc.debit_or_credit,'Debit',to_number(ppc.costed_value),null) entered_dr,
                        decode(ppc.debit_or_credit,'Credit',to_number(ppc.costed_value),null) entered_cr,
                        ppa1.action_type
                FROM    pay_payroll_actions      ppa,   -- Trans GL pay actions
                        pay_assignment_actions   pa,    -- Trans GL asg actions
                        pay_action_interlocks    pi1,   -- Cost - Trans GL
                        pay_assignment_actions   pa1,   -- Cost asg actions
                        pay_payroll_actions      ppa1,  -- Cost pay actions
                        per_all_assignments_f    pera,
                        pay_all_payrolls_f       pp,
                        pay_payment_costs_v ppc,
                        gl_je_headers gjh,
                        gl_je_lines gjl
                WHERE   ppa.payroll_action_id    = to_number(gjl.reference_1)
                AND     pa.payroll_action_id     = ppa.payroll_action_id
                AND     pi1.locking_action_id    = pa.assignment_action_id
                AND     pa1.assignment_action_id = pi1.locked_action_id
                AND     ppa1.payroll_action_id   = pa1.payroll_action_id
                AND     ppa1.action_type         = 'CP'
                AND     pera.assignment_id       = pa.assignment_id
                AND     ppa1.effective_date  BETWEEN pera.effective_start_date        AND     pera.effective_end_date
                AND     pp.payroll_id            = pera.payroll_id
                AND     ppa.effective_date   BETWEEN pp.effective_start_date AND     pp.effective_end_date
                AND     ppc.gl_account_ccid =to_number(gjl.reference_2)
                AND     ppc.assignment_action_id=  pa1.assignment_action_id
                AND     gjl.je_header_id=gjh.je_header_id
                AND     decode(gjl.entered_cr,0,'Debit','Credit')=ppc.debit_or_credit
                AND     gjh.period_name=j.period_name
                AND     gjh.je_category=lv_application_name
                AND     gjh.ledger_id= j.ledger_id
                AND     gjh.je_source=lv_application_name) A;


    If lv_debug_enabled then
       fnd_file.put_line(fnd_file.log,'After  Inserting into XLA Tables ');
    End if;

                 update pay_patch_status
                 set status='U',
                     description='Period Successfully Upgraded'
                 where process_type=gv_process_name
                 and phase =gv_process_name||P_MGR_REQ_ID
                 and patch_number=j.ledger_id
                 and patch_name =j.period_name;

                 commit;

    If lv_debug_enabled then
       fnd_file.put_line(fnd_file.log,'Period '||j.period_name||' Successfully upgraded ');
    End if;


    Exception when others then
        Rollback;

        lv_Error_msg :=SQLCODE||' '||SQLERRM;

        update pay_patch_status
        set status='E',
            description='Error '||lv_Error_msg
        where process_type=gv_process_name
        and phase =gv_process_name||P_MGR_REQ_ID
        and patch_number=j.ledger_id
        and patch_name =j.period_name;

       fnd_file.put_line(FND_FILE.LOG,'Error Update_Payroll_Subledger '||j.period_name||' '||lv_Error_msg);

    End;

  If lv_debug_enabled then
       fnd_file.put_line(fnd_file.log,'After  upgrading ledger_id    :'|| j.ledger_id);
       fnd_file.put_line(fnd_file.log,'After  upgrading period_name  :'|| j.period_name);
  End if;

  End Loop;

If lv_debug_enabled then
    fnd_file.put_line(fnd_file.log,'Leaving         :'||l_module);
End if;

EXCEPTION when others then
   Rollback;
    X_errbuf:=l_module||': '|| SQLERRM;
    fnd_file.put_line(FND_FILE.LOG,'Error Update_Payroll_Subledger '||SQLCODE||'  '||SQLERRM);
end Update_Payroll_Subledger;

END PAY_SLA_UPDATE_PKG;

/
