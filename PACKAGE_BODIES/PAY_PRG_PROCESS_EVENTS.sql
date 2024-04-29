--------------------------------------------------------
--  DDL for Package Body PAY_PRG_PROCESS_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PRG_PROCESS_EVENTS" AS
/* $Header: pyprgevt.pkb 120.0.12010000.4 2009/08/18 10:38:03 pparate noship $*/
g_pkg_name          CONSTANT VARCHAR2(30) := 'PAY_PRG_PROCESS_EVENTS';
gv_process_name     CONSTANT varchar2(10) := 'PAYPRGEVT';

-------------------------------------------------------------------------------------
--  Name       : Purge_process_events _PAY_MGR
--  Function   : This is the Manager Process called by Conc Program
--               Purge Process Events
-------------------------------------------------------------------------------------

PROCEDURE Purge_process_events_PAY_MGR (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               p_purge_date     in  varchar2,
               X_batch_size     in  number default 1000,
               X_Num_Workers    in  number default 5)
IS

  l_module       CONSTANT VARCHAR2(90) := 'PAY_PRG_PROCESS_EVENTS.Purge_process_events_PAY_MGR';

  l_stmt_num     number;
  l_api_name     CONSTANT VARCHAR2(30)   := 'Purge_process_events_PAY_MGR';
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

  l_prg_appid    number;
  l_program_name varchar2(15);
  l_reqid_count  number;

  l_ret_code varchar2(10);

  l_product       varchar2(30);
  l_status        varchar2(30);
  l_industry      varchar2(30);
  l_retstatus     boolean;
  l_table_owner   varchar2(30);
  lv_param_found  boolean default FALSE;
  lv_Num_Workers  number default 1;
  lv_debug_enabled boolean default FALSE;
  lv_no_periods    boolean default TRUE;

  lv_logging       varchar2(30);
  lv_debug_flag    varchar2(2);
  lv_batch_size    number;
  l_pap_group_id_frm_profile number := 0;

BEGIN

/* Get pay action parameter group id */
l_pap_group_id_frm_profile := fnd_profile.value('ACTION_PARAMETER_GROUPS');
if (pay_core_utils.pay_action_parameter_group_id is null) then
  pay_core_utils.pay_action_parameter_group_id := l_pap_group_id_frm_profile;
end if;

fnd_file.put_line(fnd_file.log,'PAP Group ID:'||l_pap_group_id_frm_profile);

/* Check if logging for pl/sql code is set. If yes, enable log statments */
lv_debug_flag := 'N';
pay_core_utils.get_action_parameter('LOGGING',lv_logging,lv_param_found);

lv_debug_enabled := FALSE;
if (lv_param_found) then
  if (instr(upper(lv_logging), 'Z') <> 0 or instr(upper(lv_logging), 'T') <> 0)
then
     lv_debug_enabled := TRUE;
     lv_debug_flag := 'Y';
  end if;
end if;
lv_param_found := FALSE;

/* Set batch size using action parameter */
pay_core_utils.get_action_parameter('PPE_BATCH_SIZE',lv_batch_size,
lv_param_found);
if (not lv_param_found) then
  lv_batch_size := X_batch_size;
end if;
lv_param_found := FALSE;

If lv_debug_enabled then
           fnd_file.put_line(fnd_file.log,'Enter             :'||l_module);
           fnd_file.put_line(fnd_file.log,'In P_PURGE_DATE   :'|| p_purge_date);
           fnd_file.put_line(fnd_file.log,'PPE_BATCH_SIZE   :'|| lv_batch_size);
End if;

  l_stmt_num :=0;
  l_stmt_num :=5;
  l_prg_appid := 801;
  l_program_name := 'PAYPRGEVT';
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

           /* Call worker program based on number of threads */
           AD_CONC_UTILS_PKG.submit_subrequests(
                  X_errbuf=>X_errbuf,
                  X_retcode=>X_retcode,
                  X_WorkerConc_app_shortname=>'PAY',
                  X_WorkerConc_progname=>'PAYPRGEVTW',
                  X_Batch_size=>lv_batch_size,
                  X_Num_Workers=>lv_Num_Workers,
                  X_Argument4 => lv_debug_flag,
                  X_Argument5 => P_Purge_Date,
                  X_Argument6 => fnd_global.conc_request_id,
                  X_Argument7 => null,
                  X_Argument8 => null,
                  X_Argument9 => null,
                  X_Argument10 => null);

           exception when others then
              fnd_file.put_line(FND_FILE.LOG,'Error '||sqlcode ||' '||sqlerrm);

         end;

         If lv_debug_enabled then
                fnd_file.put_line(fnd_file.log,'After AD_CONC_UTILS_PKG.submit_subrequests ');
         End if;

      exception
         when others then
            fnd_file.put_line(FND_FILE.LOG,'Error '||sqlcode ||'   '||sqlerrm);

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

     /* Display process completion message */
     if (X_retcode = FND_API.G_RET_STS_SUCCESS) then
        fnd_file.put_line(FND_FILE.LOG,'***** Process completed successfully *****');
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

END Purge_process_events_PAY_MGR;

----------------------------------------------------------------------------------------
--  Name       : Purge_process_events_PAY_WKR
--  Function   : Worker process to Purge Process Events.
--               This is called by #Purge_process_events_PAY_MGR

----------------------------------------------------------------------------------------
PROCEDURE Purge_process_events_PAY_WKR (
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
               X_Argument10  in varchar2 default  null)
IS

   l_module               constant varchar2(90) := 'PAY_PRG_PROCESS_EVENTS.Purge_process_events_PAY_WKR';
  l_worker_id            number;
  l_product              varchar2(30);
  l_table_name           varchar2(30) := 'PAY_PROCESS_EVENTS';
  l_id_column            varchar2(30) := 'ASSIGNMENT_ID';
  l_update_name          varchar2(30);

  l_table_owner          varchar2(30);
  l_status               varchar2(30);
  l_industry             varchar2(30);
  l_retstatus            boolean;
  l_any_rows_to_process  boolean;

  l_start_id             number;
  l_end_id               number;
  l_rows_processed       number;

  l_stmt_num             number;
  purge_events_exception exception;
  l_conc_status          boolean;
  lv_debug_enabled       boolean default FALSE;
  lv_purge_date          varchar2(30);

BEGIN

  l_stmt_num :=0;
  if X_Argument4 = 'Y' then
     lv_debug_enabled := TRUE;
  end if;

  If lv_debug_enabled then
      fnd_file.put_line(fnd_file.log,'Enter:'||l_module);
      fnd_file.put_line(fnd_file.log,'In Purge Date :'||X_Argument5);
  End if;

  BEGIN
    l_stmt_num :=10;

    l_update_name := 'PAYPRGEVT' ||X_Argument6;
    l_retstatus := FND_INSTALLATION.GET_APP_INFO('PAY', l_status, l_industry, l_table_owner);
    l_table_owner:='HR';


    /* Call to AD utility to enable process in multi-threaded mode */
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
         fnd_file.put_line(fnd_file.log,'Before calling Purge Process Events');
         fnd_file.put_line(fnd_file.log,'l_start_id :'||l_start_id);
         fnd_file.put_line(fnd_file.log,'l_end_id   :'||l_end_id);
      End if;

      /* Call to code for prcoessing purge process events request */
      PAY_PRG_PROCESS_EVENTS.Purge_process_events(
                  X_errbuf=>X_errbuf,
                  X_retcode=>X_retcode,
                  X_start_id=>l_start_id,
                  X_end_id=>l_end_id,
                  P_Purge_Date=>X_Argument5,
                  P_Debug_Flag=>X_Argument4);

      If lv_debug_enabled then
         fnd_file.put_line(fnd_file.log,'After calling Purge Process Events' );
      End if;

      if (X_retcode <>FND_API.G_RET_STS_SUCCESS) then
          raise purge_events_exception;
      end if;

      l_rows_processed := X_batch_size;
      l_stmt_num := 40;

      ad_parallel_updates_pkg.processed_id_range(
          l_rows_processed,
          l_end_id);

      commit;

      l_stmt_num := 50;
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

  WHEN purge_events_exception THEN
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

END Purge_process_events_PAY_WKR;


-------------------------------------------------------------------------------------
--  Name       : Purge_process_events
--  Type       : Private
--  Function   : To purge data from pay_process_events table and archive it deleted
--               deleted data into pay_process_events_shadow table.
--  Pre-reqs   :
--  Parameters :
--  IN         : p_purge_date
--               p_debug_flag
--               x_start_id
--               x_end_id
--
--  OUT        : X_errbuf  out NOCOPY varchar2,
--               X_retcode out NOCOPY varchar2
--
--  Notes      : The Procedure is called from Purge_process_events_PAY_WKR
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE Purge_process_events (
               x_errbuf     out nocopy varchar2,
               x_retcode    out nocopy varchar2,
               x_start_id   in number,
               x_end_id     in number,
               p_purge_date in varchar2,
               p_debug_flag in varchar2 )
IS

   l_module               constant varchar2(90) := 'PAY_PRG_PRCESS_EVENTS.Purge_process_events';
   lv_application_id      constant number := 801;
   lv_Error_msg           varchar2(1000);
   lv_application_name    constant varchar2(10) := 'Payroll';
   lv_debug_enabled       boolean default FALSE;
   l_effective_start_date date;
   v_time                 number;
   lv_bulk_limit          number;
   lv_param_found         boolean default FALSE;


   type ppe_t is table of PAY_PROCESS_EVENTS%ROWTYPE index by binary_integer;
   type ppes_t is table of PAY_PROCESS_EVENTS_SHADOW%ROWTYPE index by binary_integer;
   type process_event_t is table of PAY_PROCESS_EVENTS.PROCESS_EVENT_ID%TYPE index by binary_integer;

   ppe_table_rec ppe_t;
   ppes_table_rec ppes_t;
   process_event_rec process_event_t;

   /* Cursor that defines what data to purge and archive */
   cursor get_archive_events is
     select ppe.*
     from pay_process_events ppe
     where ppe.creation_date < fnd_date.canonical_to_date(p_purge_date)
       and ppe.assignment_id between x_start_id and x_end_id
       and (not exists
           (select 1
            from pay_recorded_requests prr
            where prr.attribute1 = ppe.assignment_id
              and prr.attribute_category = 'RETRONOT_ASG')
         or ppe.creation_date < (select prr.recorded_date
                                 from pay_recorded_requests prr
                                 where prr.attribute1 = ppe.assignment_id
                                   and prr.attribute_category = 'RETRONOT_ASG'));

BEGIN

   if p_debug_flag = 'Y' then
    lv_debug_enabled := TRUE;
   end if;

   pay_core_utils.get_action_parameter('PPE_BULK_LIMIT',lv_bulk_limit,lv_param_found);

   /* If PRG_BULK_LIMIT action parameter is not set, default bulk limit to 10000   */
   if (not lv_param_found) then
      lv_bulk_limit := 10000;
   end if;

   If lv_debug_enabled then
       fnd_file.put_line(fnd_file.log,'Enter           :'|| l_module);
       fnd_file.put_line(fnd_file.log,'In P_Purge_Date :'|| P_Purge_Date);
       fnd_file.put_line(fnd_file.log,'In X_START_ID   :'|| to_char(X_start_id));
       fnd_file.put_line(fnd_file.log,'In X_END_ID     :'|| to_char(X_end_id));
       fnd_file.put_line(fnd_file.log,'PPE_BULK_LIMIT  :'|| lv_bulk_limit);
   End if;

   v_time := dbms_utility.get_time;


   open get_archive_events;

   loop

     fetch get_archive_events bulk collect into ppe_table_rec limit lv_bulk_limit;

     FOR j IN 1 .. ppe_table_rec.count
     LOOP
        process_event_rec(j) :=   ppe_table_rec(j).process_event_id;
     END LOOP;

     FOR k IN 1 .. ppe_table_rec.count
     LOOP
        ppes_table_rec(k).process_event_id := ppe_table_rec(k).process_event_id;
        ppes_table_rec(k).assignment_id := ppe_table_rec(k).assignment_id;
        ppes_table_rec(k).effective_date := ppe_table_rec(k).effective_date;
        ppes_table_rec(k).change_type := ppe_table_rec(k).change_type;
        ppes_table_rec(k).status := ppe_table_rec(k).status;
        ppes_table_rec(k).description := ppe_table_rec(k).description;
        ppes_table_rec(k).event_update_id := ppe_table_rec(k).event_update_id;
        ppes_table_rec(k).business_group_id := ppe_table_rec(k).business_group_id;
        ppes_table_rec(k).org_process_event_group_id := ppe_table_rec(k).org_process_event_group_id;
        ppes_table_rec(k).surrogate_key := ppe_table_rec(k).surrogate_key;
        ppes_table_rec(k).object_version_number := ppe_table_rec(k).object_version_number;
        ppes_table_rec(k).last_update_date := ppe_table_rec(k).last_update_date;
        ppes_table_rec(k).last_updated_by := ppe_table_rec(k).last_updated_by;
        ppes_table_rec(k).last_update_login := ppe_table_rec(k).last_update_login;
        ppes_table_rec(k).created_by := ppe_table_rec(k).created_by;
        ppes_table_rec(k).creation_date := ppe_table_rec(k).creation_date;
        ppes_table_rec(k).calculation_date := ppe_table_rec(k).calculation_date;
        ppes_table_rec(k).retroactive_status := ppe_table_rec(k).retroactive_status;
        ppes_table_rec(k).noted_value := ppe_table_rec(k).noted_value;

     END LOOP;

     forall x in 1 .. ppe_table_rec.count
     insert into PAY_PROCESS_EVENTS_SHADOW
     values ppes_table_rec(x);

     forall x in 1 .. process_event_rec.count
     delete from PAY_PROCESS_EVENTS
     where process_event_id = process_event_rec(x);

     exit when get_archive_events%notfound;
     commit;

   end loop;

  if lv_debug_enabled then
     fnd_file.put_line(fnd_file.log,'Time used: ' || (dbms_utility.get_time - v_time) / 100 || ' secs');
  end if;

   close get_archive_events;

   commit;

  If lv_debug_enabled then
    fnd_file.put_line(fnd_file.log,'Leaving         :'||l_module);
  End if;

EXCEPTION when others then
   Rollback;
    X_errbuf:=l_module||': '|| SQLERRM;
    fnd_file.put_line(FND_FILE.LOG,'Error Purge_process_events '||SQLCODE||' '||SQLERRM);

END Purge_process_events;

END PAY_PRG_PROCESS_EVENTS;

/
