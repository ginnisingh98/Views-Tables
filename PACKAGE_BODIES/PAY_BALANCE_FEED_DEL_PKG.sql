--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_FEED_DEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_FEED_DEL_PKG" AS
/* $Header: pyscd.pkb 120.0.12010000.2 2009/08/21 16:57:41 priupadh noship $ */
g_pkg_name          CONSTANT VARCHAR2(30) := 'PAY_BALANCE_FEED_DEL_PKG';
g_debug boolean;
g_lat_bal_check_mode pay_action_parameters.parameter_value%TYPE := null;

PROCEDURE bal_feed_main_proc(
        errbuf            out nocopy varchar2,
        retcode           out nocopy varchar2,
        c_element_type_id in number,
        c_pur_mode        in varchar2,
        c_dummy_param     in varchar2 default null,
        c_dummy_param_1   in varchar2 default null,
        c_bal_feed_id     in number default null,
        c_sub_class_id    in number default null,
        c_batch_size      in number default null) is


Cursor csr_bal_feed_rowid is
select rowid,
       balance_type_id,
       input_value_id,
       effective_start_date
from PAY_BALANCE_FEEDS_F
where BALANCE_FEED_ID=c_bal_feed_id;

Cursor csr_sub_class_rowid is
select rowid
from pay_sub_classification_rules_f
where SUB_CLASSIFICATION_RULE_ID = c_sub_class_id;

Cursor csr_bal_feeds_sub_class_rule
          (
           p_sub_classification_rule_id number,
           p_pay_value_name             varchar2
          ) is
     select bf.rowid row_id,
            bf.balance_type_id,
            bf.input_value_id,
            bf.effective_start_date
     from   pay_sub_classification_rules_f scr,
            pay_input_values_f iv,
            pay_balance_feeds_f bf,
            pay_balance_classifications bc,
            pay_balance_types bt
     where  scr.sub_classification_rule_id = p_sub_classification_rule_id
       and  iv.element_type_id = scr.element_type_id
       and  iv.name = p_pay_value_name
       and  bc.classification_id = scr.classification_id
       and  bt.balance_type_id = bc.balance_type_id
       and  bf.balance_type_id = bt.balance_type_id
       and  bf.input_value_id = iv.input_value_id
       and  bf.effective_start_date = scr.effective_start_date
       and  bf.effective_end_date   = scr.effective_end_date
       and  scr.effective_start_date between iv.effective_start_date
                                         and iv.effective_end_date
     for update;


  g_val_start_date date default hr_general.start_of_time;
  g_val_end_date date default hr_general.end_of_time;
  g_dt_mode varchar2(10) default 'ZAP';

  bal_rowid rowid;
  bal_type_id pay_balance_types.balance_type_id%type;
  inp_value_id pay_input_values_f.input_value_id%type;
  eff_start_date Date;
  sub_rowid rowid;

begin

    if c_pur_mode='Balance feed' and c_bal_feed_id is not null then

            Open  csr_bal_feed_rowid;
            Fetch csr_bal_feed_rowid into bal_rowid,bal_type_id,inp_value_id,eff_start_date;
            Close csr_bal_feed_rowid;



/*
    hrassact.trash_latest_balances gets called from trigger
    pay_balance_feeds_ard , due to performance issues in delting from
    pay_assignment_latest_balances we are performing this operation here
    before delete from pay_balance_feeds_f.

*/

            If bal_type_id is not null then
               hr_balance_feeds.lock_balance_type(bal_type_id);
            End if;

            pay_balance_feed_del_pkg.trash_latest_balances_threaded(errbuf,
                                                                    retcode,
                                                                    bal_type_id,
                                                                    inp_value_id,
                                                                    eff_start_date,
                                                                    c_batch_size);

            Delete from pay_balance_feeds_f
            where  rowid = bal_rowid;

     --       pay_balance_feeds_f_pkg.delete_row (bal_rowid,bal_type_id);

    elsif c_pur_mode='Sub Classification' and c_sub_class_id is not null then

            Open  csr_sub_class_rowid;
            Fetch csr_sub_class_rowid into sub_rowid;
            Close csr_sub_class_rowid;


            for v_bf_rec in csr_bal_feeds_sub_class_rule(c_sub_class_id,'Pay Value') loop

            pay_balance_feed_del_pkg.trash_latest_balances_threaded(errbuf,
                                                                    retcode,
                                                                    v_bf_rec.balance_type_id,
                                                                    v_bf_rec.input_value_id,
                                                                    v_bf_rec.effective_start_date,
                                                                    c_batch_size);


                       delete from pay_balance_feeds_f bf
                       where  bf.rowid = v_bf_rec.row_id;

            end loop;

            If sub_rowid is not null then
              delete from pay_sub_classification_rules_f
              where   rowid   = sub_rowid;
            End If;
            if sql%notfound then    -- system error trap
               hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
               hr_utility.set_message_token('PROCEDURE',
                                        'PAY_BALANCE_FEED_DEL_PKG.BAL_FEED_MAIN_PROC');
               hr_utility.set_message_token('STEP','2');
               hr_utility.raise_error;
            end if;

            delete from hr_application_ownerships
            where key_name = 'SUB_CLASSIFICATION_RULE_ID'
            and key_value = c_sub_class_id;

            --pay_sub_class_rules_pkg.delete_row (sub_rowid,p_sub_classification_rule_id,g_dt_mode,g_val_start_date,g_val_end_date);


    else

       errbuf:='Please give value for '||c_pur_mode||' to purge';
       retcode:=2;
    end if;

    commit;

end bal_feed_main_proc;

/*-------------------------  trash_latest_balances_threaded  -----------------------*/
/*
 *    This procedure is copied from hrassact.trash_latest_balances.
 *    Deltion from pay_assignment_latest_balances will now be done in multiple threads.
 *    Master Procedure will be called from here which will spawn slave process.
 */


procedure trash_latest_balances_threaded(X_errbuf          out NOCOPY varchar2,
                                         X_retcode         out NOCOPY varchar2,
                                         l_balance_type_id number,
                                         l_input_value_id  number,
                                         l_trash_date      date,
                                         l_batch_size      number) is
--
   -- Select all person latest balances to delete.
   cursor plbc is
   select /*+ ORDERED INDEX (PLB PAY_PERSON_LATEST_BALANCES_FK1)
              USE_NL (PLB) */
          plb.latest_balance_id
   from   pay_defined_balances       pdb,
          pay_person_latest_balances plb
   where  pdb.balance_type_id      = l_balance_type_id
   and    plb.defined_balance_id   = pdb.defined_balance_id
   and    exists (
          select null
          from   pay_run_results       prr,
                 pay_run_result_values rrv
          where  rrv.input_value_id  = l_input_value_id
          and    prr.run_result_id   = rrv.run_result_id
          and    prr.status          in ('P', 'PA')
          and    nvl(rrv.result_value, '0') <> '0');
--
   cursor lbc is
   select
          lb.latest_balance_id
   from   pay_defined_balances       pdb,
          pay_latest_balances lb
   where  pdb.balance_type_id      = l_balance_type_id
   and    lb.defined_balance_id   = pdb.defined_balance_id
   and    exists (
          select null
          from   pay_run_results       prr,
                 pay_run_result_values rrv
          where  rrv.input_value_id  = l_input_value_id
          and    prr.run_result_id   = rrv.run_result_id
          and    prr.status          in ('P', 'PA')
          and    nvl(rrv.result_value, '0') <> '0');
--

--
   cursor platbalc is
   select /*+ ORDERED INDEX (PLB PAY_PERSON_LATEST_BALANCES_FK1)
              USE_NL (PLB) */
          plb.latest_balance_id
   from   pay_defined_balances       pdb,
          pay_person_latest_balances plb
   where  pdb.balance_type_id      = l_balance_type_id
   and    plb.defined_balance_id   = pdb.defined_balance_id;
--

--
   -- Select all latest balances to delete.
   cursor latbalc is
   select /*+ ORDERED INDEX (PLB PAY_LATEST_BALANCES_FK1)
              USE_NL (PLB) */
          plb.latest_balance_id
   from   pay_defined_balances           pdb,
          pay_latest_balances            plb
   where  pdb.balance_type_id      = l_balance_type_id
   and    plb.defined_balance_id   = pdb.defined_balance_id;
--
   -- Select if run result value exists for input value
   cursor ivchk is
   select '1' from dual
    where exists (select 1
     from pay_run_results prr,
          pay_run_result_values rrv
    where rrv.input_value_id = l_input_value_id
      and prr.run_result_id  = rrv.run_result_id
      and prr.status         in ('P', 'PA')
      and nvl(rrv.result_value, '0') <> '0');
--


   cursor pl_feed_chk is
   select plb.latest_balance_id,
          'P' balance_type
     from pay_person_latest_balances plb,
          pay_defined_balances pdb,
          pay_balance_dimensions pbd
    where pdb.balance_type_id = l_balance_type_id
      and pdb.defined_balance_id = plb.defined_balance_id
      and pdb.balance_dimension_id = pbd.balance_dimension_id
      and pbd.feed_checking_type = 'F'
    union
    select plb.latest_balance_id,
           'B' balance_type
      from pay_latest_balances plb,
           pay_defined_balances pdb,
           pay_balance_dimensions pbd
     where pdb.balance_type_id = l_balance_type_id
       and pdb.defined_balance_id = plb.defined_balance_id
       and pdb.balance_dimension_id = pbd.balance_dimension_id
       and pbd.feed_checking_type = 'F';

  l_ivchk varchar2(2);
  l_rrv_found number := -1;
  --Added following type for Bug:6595092 bulk delete
  Type t_latbal is table of pay_assignment_latest_balances.latest_balance_id%type;
  lat_bal_list t_latbal;
  lv_proc_name varchar2(80);

--
begin
   g_debug := hr_utility.debug_enabled;
   lv_proc_name := 'pay_balance_feed_del_pkg.trash_latest_balances_threaded';
--
   if g_debug then
      hr_utility.set_location(lv_proc_name,10);
   end if;

   if (g_lat_bal_check_mode is null) then
      begin
         if g_debug then
            hr_utility.set_location(lv_proc_name,15);
         end if;
         select parameter_value
         into   g_lat_bal_check_mode
         from   pay_action_parameters
         where  parameter_name = 'LAT_BAL_CHECK_MODE';

      exception
         when others then
            g_lat_bal_check_mode := 'N';
      end;

      if (g_lat_bal_check_mode = 'B') then
         HRASSACT.CHECK_LAT_BALS_FIRST := TRUE;
      elsif (g_lat_bal_check_mode = 'R') then
         HRASSACT.CHECK_RRVS_FIRST := TRUE;
      end if;
   end if;
--
 if HRASSACT.CHECK_LATEST_BALANCES = TRUE then

  if HRASSACT.CHECK_RRVS_FIRST = TRUE then

   if g_debug then
      hr_utility.set_location(lv_proc_name,20);
   end if;
   --
   -- Check for existance of run result value for input value
   --
   open ivchk;
   fetch ivchk
   into l_ivchk;

   if ivchk%FOUND then
--
     if g_debug then
        hr_utility.set_location(lv_proc_name,30);
     end if;
     -- Delete all balance context values and
     -- person latest balances.
     for plbcrec in platbalc loop
        delete from pay_balance_context_values BCV
        where  BCV.latest_balance_id = plbcrec.latest_balance_id;
--
        delete from pay_person_latest_balances PLB
        where  PLB.latest_balance_id = plbcrec.latest_balance_id;
     end loop;

     if g_debug then
        hr_utility.set_location(lv_proc_name,40);
     end if;
     -- Delete all balance context values and
     -- assignment latest balances.

     --Commented the following and added a block with cusrsor and bulk delete
     --for Bug:6595092
  /*   for albcrec in alatbalc loop
       delete from pay_balance_context_values BCV
        where  BCV.latest_balance_id = albcrec.latest_balance_id;
--
        delete from pay_assignment_latest_balances ALB
        where  ALB.latest_balance_id = albcrec.latest_balance_id;
     end loop; */

        Delete_Proc_PAY_MGR (X_errbuf  => X_errbuf,
                             X_retcode => X_retcode,
                             p_cursor  => 'alatbalc',
                             p_balance_type_id => to_char(l_balance_type_id),
                             X_batch_size => l_batch_size);

--
     -- Delete all latest Balanaces.
     for lbcrec in latbalc loop
--
        delete from pay_latest_balances LB
        where  LB.latest_balance_id = lbcrec.latest_balance_id;
     end loop;
--
   end if;
   close ivchk;

  elsif HRASSACT.CHECK_LAT_BALS_FIRST = TRUE then

   if g_debug then
      hr_utility.set_location(lv_proc_name,50);
   end if;
   --
   -- Check for any latest balances before relevant run result value
   --
   for plbcrec in platbalc loop
      if l_rrv_found = -1 then
         open ivchk;

         fetch ivchk
         into l_ivchk;

         if ivchk%FOUND then
            l_rrv_found := 1;
         else
            l_rrv_found := 0;
            close ivchk;
            exit;
         end if;
         close ivchk;
      end if;
      if l_rrv_found = 1 then
         delete from pay_balance_context_values BCV
         where  BCV.latest_balance_id = plbcrec.latest_balance_id;
--
         delete from pay_person_latest_balances PLB
         where  PLB.latest_balance_id = plbcrec.latest_balance_id;
      end if;
   end loop;
--
  if g_debug then
      hr_utility.set_location(lv_proc_name,60);
   end if;
   -- Delete all balance context values and
   -- assignment latest balances.
   if l_rrv_found <> 0 then
         if l_rrv_found = -1 then
            open ivchk;
            fetch ivchk
            into l_ivchk;

            if ivchk%FOUND then
               l_rrv_found := 1;
            else
               l_rrv_found := 0;
               close ivchk;
            end if;
            close ivchk;
         end if;
         if l_rrv_found = 1 then
          Delete_Proc_PAY_MGR (X_errbuf  => X_errbuf,
                               X_retcode => X_retcode,
                               p_cursor  => 'alatbalc',
                               p_balance_type_id => to_char(l_balance_type_id),
                               X_batch_size => l_batch_size);

         end if;
   end if;
--
   for lbcrec in latbalc loop
      if l_rrv_found = -1 then
         open ivchk;

         fetch ivchk
         into l_ivchk;

         if ivchk%FOUND then
            l_rrv_found := 1;
         else
            l_rrv_found := 0;
            close ivchk;
            exit;
         end if;
         close ivchk;
      end if;
      if l_rrv_found = 1 then
         delete from pay_latest_balances ALB
         where  ALB.latest_balance_id = lbcrec.latest_balance_id;
      end if;
   end loop;

  else
   --
   -- Original Code
   --
   if g_debug then
      hr_utility.set_location(lv_proc_name,70);
   end if;
   -- Delete all balance context values and
   -- person latest balances.
   for plbcrec in plbc loop
      delete from pay_balance_context_values BCV
      where  BCV.latest_balance_id = plbcrec.latest_balance_id;
--
      delete from pay_person_latest_balances PLB
      where  PLB.latest_balance_id = plbcrec.latest_balance_id;
   end loop;
--
   if g_debug then
      hr_utility.set_location(lv_proc_name,80);
   end if;
   -- Delete all balance context values and
   -- assignment latest balances.

        Delete_Proc_PAY_MGR (X_errbuf  => X_errbuf,
                             X_retcode => X_retcode,
                             p_cursor  => 'albc',
                             p_balance_type_id => to_char(l_balance_type_id),
                             p_input_value_id  => to_char(l_input_value_id),
                             X_batch_size => l_batch_size);

--
   if g_debug then
      hr_utility.set_location(lv_proc_name,70);
   end if;
--
   for lbcrec in lbc loop
      delete from pay_latest_balances ALB
      where  ALB.latest_balance_id = lbcrec.latest_balance_id;
   end loop;
--
  end if;
--
   if g_debug then
      hr_utility.set_location(lv_proc_name,90);
   end if;
--
   for plrec in pl_feed_chk loop
--
     if g_debug then
        hr_utility.set_location(lv_proc_name,100);
     end if;

     delete from pay_balance_context_values BCV
      where  BCV.latest_balance_id = plrec.latest_balance_id;
--
     if (plrec.balance_type = 'P') then
       delete from pay_person_latest_balances PLB
       where  PLB.latest_balance_id = plrec.latest_balance_id;
     else
       delete from pay_latest_balances PLB
       where  PLB.latest_balance_id = plrec.latest_balance_id;
     end if;
--
   end loop;

                Delete_Proc_PAY_MGR (X_errbuf  => X_errbuf,
                             X_retcode => X_retcode,
                             p_cursor  => 'pl_feed_chk_a',
                             p_balance_type_id => to_char(l_balance_type_id),
                             X_batch_size => l_batch_size);

--
 end if;
--
   if g_debug then
      hr_utility.set_location(lv_proc_name,110);
   end if;
--
   return;
--
end trash_latest_balances_threaded;

-------------------------------------------------------------------------------------
--  Name       : Delete_Proc_PAY_MGR
--  Function   : This is the Manager Process called by trash_latest_balances_threaded
--
-------------------------------------------------------------------------------------
PROCEDURE Delete_Proc_PAY_MGR (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               p_cursor          in varchar2,
               p_balance_type_id in varchar2,
               p_input_value_id  in  varchar2 default null,
               X_batch_size      in  number default 1000,
               X_Num_Workers     in  number default 5)
IS

  l_module       CONSTANT VARCHAR2(90) := 'PAY_BALANCE_FEED_DEL_PKG.Delete_Proc_PAY_MGR';

  l_stmt_num     number;
  l_api_name     CONSTANT VARCHAR2(30)   := 'Delete_Proc_PAY_MGR';
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

  sub_rowid rowid;

BEGIN


 lv_debug_enabled := FALSE;


If lv_debug_enabled then
           fnd_file.put_line(fnd_file.log,'Enter             :'||l_module);
End if;

  l_stmt_num :=0;
  l_stmt_num :=5;
  l_prg_appid := 801;
  l_program_name := 'PAYSCDW';
  l_reqid_count := 0;

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

                  AD_CONC_UTILS_PKG.submit_subrequests(
                         X_errbuf=>X_errbuf,
                         X_retcode=>X_retcode,
                         X_WorkerConc_app_shortname=>'PAY',
                         X_WorkerConc_progname=>'PAYSCDW',
                         X_Batch_size=> X_batch_size,
                         X_Num_Workers=>lv_Num_Workers,
                         X_Argument4 => p_cursor,
                         X_Argument5 => p_balance_type_id,
                         X_Argument6 => p_input_value_id,
                         X_Argument7 => fnd_global.conc_request_id,
                         X_Argument8 => null,
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
            fnd_file.put_line(FND_FILE.LOG, 'No more deletions in pay_assignment_latest_balances.');

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

END Delete_Proc_PAY_MGR;

----------------------------------------------------------------------------------------
--  Name       : Delete_Proc_PAY_WKR
--  Function   : Worker process to delete from pay_assignment_latest_balances

----------------------------------------------------------------------------------------
PROCEDURE Delete_Proc_PAY_WKR (
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

  l_module       CONSTANT VARCHAR2(90) := 'PAY_BALANCE_FEED_DEL_PKG.Delete_Proc_PAY_WKR';
  l_worker_id  number;
  l_product     varchar2(30);
  l_table_name      varchar2(30) := 'PER_ALL_ASSIGNMENTS_F';
  l_id_column       varchar2(30) := 'ASSIGNMENT_ID';
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
  update_exception exception;
  l_conc_status  BOOLEAN;
  lv_debug_enabled boolean default FALSE;

BEGIN
  l_stmt_num :=0;

     lv_debug_enabled := FALSE;


If lv_debug_enabled then
    fnd_file.put_line(fnd_file.log,'Enter                        :'||l_module);
End if;
  --
  BEGIN
    l_stmt_num :=10;

    l_update_name := 'PAYSCD' ||X_Argument7;
    l_retstatus := FND_INSTALLATION.GET_APP_INFO('PAY', l_status, l_industry, l_table_owner);
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

      PAY_BALANCE_FEED_DEL_PKG.Delete_assnmnt_lat_bal(
                  X_errbuf=>X_errbuf,
                  X_retcode=>X_retcode,
                  x_assnmnt_start_id=>l_start_id,
                  x_assnmnt_end_id=>l_end_id,
                  p_cursor=>X_Argument4,
                  p_balance_type_id=>X_Argument5,
                  P_input_value_id=>X_Argument6);

      If lv_debug_enabled then
         fnd_file.put_line(fnd_file.log,'After calling Update_Payroll_Subledger');
      End if;

      if (X_retcode <>FND_API.G_RET_STS_SUCCESS) then
          raise update_exception;
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
WHEN update_exception THEN
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

END Delete_Proc_PAY_WKR;

-------------------------------------------------------------------------------------
--  Name       : Delete_assnmnt_lat_bal
--  Function   : To delete from pay_assignment_latest_balances for Assignment ID's
--               between to x_assnmnt_start_id and x_assnmnt_end_id .
--  Pre-reqs   :
--  Parameters :
--  IN         :       x_assnmnt_start_id     in  number
--                     x_assnmnt_end_id       in  number
--                     p_cursor               in varchar2
--                     p_balance_type_id      in varchar2
--                     p_input_value_id       in varchar2
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--
--  Notes      : The Procedure is called from Update_Proc_PAY_WKR.
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE Delete_assnmnt_lat_bal(
               x_errbuf             out nocopy varchar2,
               x_retcode            out nocopy varchar2,
               x_assnmnt_start_id           in number,
               x_assnmnt_end_id             in number,
               p_cursor             in varchar2,
               p_balance_type_id    in varchar2,
               p_input_value_id     in varchar2
)
IS

   -- Select all assignment latest balances to delete.
   cursor albc(p_assnmnt_start_id in varchar2,
               p_assnmnt_end_id   in varchar2,
               p_balance_type_id  in varchar2,
               p_input_value_id   in varchar2) is
   select /*+ ORDERED INDEX (PLB PAY_ASSIGNMENT_LATEST_BALA_FK2)
              USE_NL (PLB) */
          plb.latest_balance_id
   from   pay_defined_balances           pdb,
          pay_assignment_latest_balances plb
   where  pdb.balance_type_id      = p_balance_type_id
   and    plb.defined_balance_id   = pdb.defined_balance_id
   and    plb.assignment_id between p_assnmnt_start_id and p_assnmnt_end_id
   and    exists (
          select null
          from   pay_run_results       prr,
                 pay_run_result_values rrv
          where  rrv.input_value_id  = p_input_value_id
          and    prr.run_result_id   = rrv.run_result_id
          and    prr.status          in ('P', 'PA')
          and    nvl(rrv.result_value, '0') <> '0');

   -- Select all assignment latest balances to delete.
   cursor alatbalc(p_assnmnt_start_id in varchar2,
                   p_assnmnt_end_id   in varchar2,
                   p_balance_type_id  in varchar2) is
   select /*+ ORDERED INDEX (PLB PAY_ASSIGNMENT_LATEST_BALA_FK2)
              USE_NL (PLB) */
          plb.latest_balance_id
   from   pay_defined_balances           pdb,
          pay_assignment_latest_balances plb
   where  pdb.balance_type_id      = p_balance_type_id
   and    plb.defined_balance_id   = pdb.defined_balance_id
   and    plb.assignment_id between p_assnmnt_start_id and p_assnmnt_end_id;

      -- Select the balances that are PL/SQL fed.
   cursor pl_feed_chk_a(p_assnmnt_start_id in varchar2,
                        p_assnmnt_end_id   in varchar2,
                        p_balance_type_id  in varchar2) is
   select alb.latest_balance_id
     from pay_assignment_latest_balances alb,
          pay_defined_balances pdb,
          pay_balance_dimensions pbd
    where pdb.balance_type_id = p_balance_type_id
      and pdb.defined_balance_id = alb.defined_balance_id
      and pdb.balance_dimension_id = pbd.balance_dimension_id
      and pbd.feed_checking_type = 'F'
      and alb.assignment_id between p_assnmnt_start_id and p_assnmnt_end_id;

   l_module            CONSTANT VARCHAR2(90) := 'PAY_BALANCE_FEED_DEL_PKG.Delete_assnmnt_lat_bal';
   lv_application_id   CONSTANT number := 801;
   l_upg_batch_id      number;
   lv_Error_msg        varchar2(1000);
   lv_application_name CONSTANT varchar2(10) := 'Payroll';
   lv_debug_enabled boolean default FALSE;

  Type t_latbal is table of pay_assignment_latest_balances.latest_balance_id%type;
  lat_bal_list t_latbal;
--
   v_pay_value_name varchar2(80);

BEGIN


  lv_debug_enabled := FALSE;


  If lv_debug_enabled then
    fnd_file.put_line(fnd_file.log,'Enter                    :'||l_module);
    fnd_file.put_line(fnd_file.log,'In X_ASSNMNT_START_ID    :'|| to_char(x_assnmnt_start_id));
    fnd_file.put_line(fnd_file.log,'In X_ASSNMNT_END_ID      :'|| to_char(x_assnmnt_end_id));
    fnd_file.put_line(fnd_file.log,'In P_CURSOR              :'|| to_char(p_cursor));
    fnd_file.put_line(fnd_file.log,'In P_BALANCE_TYPE_ID     :'|| to_char(p_balance_type_id));
    fnd_file.put_line(fnd_file.log,'In P_INPUT_VALUE_ID      :'|| to_char(p_input_value_id));
  End if;

  If p_cursor = 'alatbalc' then

      open alatbalc(x_assnmnt_start_id,x_assnmnt_end_id,p_balance_type_id);
      loop
         fetch alatbalc bulk collect into lat_bal_list limit 10000;

           forall i in 1..lat_bal_list.count
             delete from pay_balance_context_values BCV
             where  BCV.latest_balance_id = lat_bal_list(i);

           forall i in 1..lat_bal_list.count
             delete from pay_assignment_latest_balances ALB
             where  ALB.latest_balance_id =lat_bal_list(i);

             exit when alatbalc%notfound;
      end loop;
      lat_bal_list.delete;
      if alatbalc%isopen then
         close alatbalc;
      end if;

  elsif p_cursor = 'albc' then
      open albc(x_assnmnt_start_id,x_assnmnt_end_id,p_balance_type_id,p_input_value_id);
      loop
         fetch albc bulk collect into lat_bal_list limit 10000;

           forall i in 1..lat_bal_list.count
             delete from pay_balance_context_values BCV
             where  BCV.latest_balance_id = lat_bal_list(i);

             forall i in 1..lat_bal_list.count
             delete from pay_assignment_latest_balances ALB
             where  ALB.latest_balance_id =lat_bal_list(i);

          exit when albc%notfound;
      end loop;

      lat_bal_list.delete;

      if albc%isopen then
         close albc;
      end if;

  elsif p_cursor = 'pl_feed_chk_a' then

      open pl_feed_chk_a(x_assnmnt_start_id,x_assnmnt_end_id,p_balance_type_id);
      loop
        fetch pl_feed_chk_a bulk collect into lat_bal_list limit 10000;

          forall i in 1..lat_bal_list.count
            delete from pay_balance_context_values bcv
            where  bcv.latest_balance_id = lat_bal_list(i);

          forall i in 1..lat_bal_list.count
            delete from pay_assignment_latest_balances alb
            where  alb.latest_balance_id =lat_bal_list(i);

          exit when pl_feed_chk_a%notfound;
      end loop;

      lat_bal_list.delete;

      if pl_feed_chk_a%isopen then
         close pl_feed_chk_a;
      end if;

end if;

--

If lv_debug_enabled then
    fnd_file.put_line(fnd_file.log,'Leaving         :'||l_module);
End if;
commit;

EXCEPTION when others then
   Rollback;
    X_errbuf:=l_module||': '|| SQLERRM;
    X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
    fnd_file.put_line(FND_FILE.LOG,'Error Update_Payroll_Subledger '||SQLCODE||'  '||SQLERRM);
end Delete_assnmnt_lat_bal;

END PAY_BALANCE_FEED_DEL_PKG;

/
