--------------------------------------------------------
--  DDL for Package Body GMS_FC_SYS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_FC_SYS" AS
--$Header: gmsfcsyb.pls 120.4.12010000.4 2009/05/26 13:30:48 byeturi ship $

-- To check on, whether to print debug messages in log file or not
L_DEBUG varchar2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');

object_type   varchar2(10) := ' PACKAGE ';
object_name   varchar2(30) := ' GMS_FC_SYS';
sub_program   varchar2(30);
stage         number;
errcode       varchar2(10);
errmesg       varchar2(100);

-- Bug 5726575
-- =====================
-- Start of the comment
-- API Name       : create_burden_impacted_enc
-- Type           : Public
-- Pre_reqs       : None
-- Description    : Added a new procedure create_burden_impacted_enc,
--                  to create adjusting ADLs and entries in GMS_BC_PACKETS
--                  for document_type ENC.
--
-- Called from    : funds_check_enc
-- Return Value   : None
--
-- Parameters     :
-- IN             :p_request_id
--                 p_packet_id
--                 p_sys_date
--                 p_sob_id
--                 p_project_id
--                 p_rows_inserted
-- End of comments
-- ===============
procedure create_burden_impacted_enc (p_request_id number,
                                      p_packet_id number,
                                      p_sys_date in date,
                                      p_sob_id in number,
                                      p_project_id in number default null,
				      p_enc_group  in varchar2 default null, --Bug 5956414
                                      p_rows_inserted out nocopy number) --5726575
is
  l_max_adl_line_num number;
  l_profile_set_size number;
  l_default_set_size number := 500;
  cursor brdn_impacted_enc1 is -- Modified for bug:8232859
    select adl.award_set_id,
           adl.adl_line_num,
           adl.raw_cost,
           adl.project_id,
           adl.task_id,
           adl.award_id,
           adl.expenditure_item_id,
           adl.cdl_line_num,
           adl.ind_compiled_set_id,
           adl.gl_date,
           adl.line_num_reversed,
           adl.adl_status,
           adl.fc_status,
           adl.reversed_flag,
           adl.burdenable_raw_cost,
           adl.cost_distributed_flag,
           adl.accumulated_flag,
           gei.encumbrance_item_date,
           gei.enc_distributed_flag,
           gei.adjusted_encumbrance_item_id,
           gei.net_zero_adjustment_flag,
           gei.transferred_from_enc_item_id,
           gei.amount,
           gei.ind_compiled_set_id enc_ind_compiled_set_id,
           gei.denom_raw_amount,
           gei.acct_raw_cost,
           adl.capitalizable_flag,
           adl.bill_hold_flag,
           adl.billable_flag
    from gms_encumbrance_items_all gei,
         gms_encumbrances_all ge,
         gms_award_distributions adl
    where gei.encumbrance_id = ge.encumbrance_id
      and gei.encumbrance_item_id = adl.expenditure_item_id
      and adl.adl_status = 'A'
      and adl.document_type = 'ENC'
      and gei.enc_distributed_flag = 'N'
      and nvl(reversed_flag, 'N') <> 'Y'
      and line_num_reversed is null
      and gei.adjustment_type in ('BURDEN_RECOMPILE', 'BURDEN_RECALC') -- Bug 6761516 added 'BURDEN_RECALC'
      and gei.request_id = p_request_id
      and adl.project_id = nvl(p_project_id, adl.project_id)  --Bug 5956414
      and ge.encumbrance_group = p_enc_group --Added for bug:8232859
      and adl.ind_compiled_set_id is not null
      and adl.fc_status = 'A';

        cursor brdn_impacted_enc2 is -- added for bug:8232859
 	     select adl.award_set_id,
 	            adl.adl_line_num,
 	            adl.raw_cost,
 	            adl.project_id,
 	            adl.task_id,
 	            adl.award_id,
 	            adl.expenditure_item_id,
 	            adl.cdl_line_num,
 	            adl.ind_compiled_set_id,
 	            adl.gl_date,
 	            adl.line_num_reversed,
 	            adl.adl_status,
 	            adl.fc_status,
 	            adl.reversed_flag,
 	            adl.burdenable_raw_cost,
 	            adl.cost_distributed_flag,
 	            adl.accumulated_flag,
 	            gei.encumbrance_item_date,
 	            gei.enc_distributed_flag,
 	            gei.adjusted_encumbrance_item_id,
 	            gei.net_zero_adjustment_flag,
 	            gei.transferred_from_enc_item_id,
 	            gei.amount,
 	            gei.ind_compiled_set_id enc_ind_compiled_set_id,
 	            gei.denom_raw_amount,
 	            gei.acct_raw_cost,
 	            adl.capitalizable_flag,
 	            adl.bill_hold_flag,
 	            adl.billable_flag
 	     from gms_encumbrance_items_all gei,
 	          gms_award_distributions adl
 	     where gei.encumbrance_item_id = adl.expenditure_item_id
 	       and adl.adl_status = 'A'
 	       and adl.document_type = 'ENC'
 	       and gei.enc_distributed_flag = 'N'
 	       and nvl(reversed_flag, 'N') <> 'Y'
 	       and line_num_reversed is null
 	       and gei.adjustment_type in ('BURDEN_RECOMPILE', 'BURDEN_RECALC') -- Bug 6674999 added 'BURDEN_RECALC'
 	       and gei.request_id = p_request_id
 	       and adl.project_id = nvl(p_project_id, adl.project_id)  --Bug 5926419
 	       and adl.ind_compiled_set_id is not null
 	       and adl.fc_status = 'A';

 type l_brdn_impacted_enc_tab is table of brdn_impacted_enc1%rowtype index by binary_integer;

  type adl_tbl is table of gms_award_distributions%rowtype index by binary_integer;
  l_negative_ln_adl_tbl adl_tbl;
  l_positive_ln_adl_tbl adl_tbl;
  l_brdn_impacted_enc l_brdn_impacted_enc_tab;
begin

  if l_debug = 'Y' then
    gms_error_pkg.gms_debug('Start of create_burden_impacted_enc', 'C');
  end if;

  p_rows_inserted := 0;

  if l_debug = 'Y' then
    gms_error_pkg.gms_debug('Inserting into GMS_BC_PACKETS for the records which failed funds check previously.', 'C');
  end if;

  --Inserting into GMS_BC_PACKETS for the records which failed funds check previously.
  insert into gms_bc_packets (packet_id,
                              set_of_books_id,
                              je_source_name,
                              je_category_name,
                              actual_flag,
                              period_name,
                              period_year,
                              period_num,
                              project_id,
                              task_id,
                              award_id,
                              result_code,
                              funding_pattern_id,
                              funding_sequence,
                              fp_status,
                              status_code,
                              last_update_date,
                              last_updated_by,
                              created_by,
                              creation_date,
                              last_update_login,
                              entered_dr,
                              entered_cr,
                              expenditure_type,
                              expenditure_organization_id,
                              expenditure_item_date,
                              document_type,
                              document_header_id,
                              document_distribution_id,
                              TRANSFERED_FLAG,
                              account_type,
                              request_id,
                              bc_packet_id,
                              person_id,
                              job_id,
                              expenditure_category,
                              revenue_category,
                              adjusted_document_header_id,
                              transaction_source,
                              award_set_id,
                              ind_compiled_set_id)
  Select p_packet_id,
         p_sob_id,
         decode(substr(gei.transaction_source,1,4),
                'GMSE', gei.transaction_source,
                decode(gei.transaction_source,
                       'GOLDE', 'Labor Distribution',
                       'Project Accounting')),
         'Encumberances',
         'E',
         glst.period_name,
         glst.period_year,
         glst.period_num,
         p.project_id,
         adl.task_id,
         adl.award_id,
         NULL,
         null,
         null,
         null,
         'P',
         p_sys_date,
         FND_GLOBAL.USER_ID,
         FND_GLOBAL.USER_ID,
         p_sys_date,
         FND_GLOBAL.LOGIN_ID,
         pa_currency.round_currency_amt(decode(sign(adl.raw_cost),1,adl.raw_cost,0)),
         pa_currency.round_currency_amt(decode(sign(adl.raw_cost),-1,-1*adl.raw_cost,0)),
         gei.encumbrance_type,
         nvl(gei.override_to_organization_id,ge.incurred_by_organization_id),
         trunc(gei.encumbrance_item_date),
         'ENC',
         gei.encumbrance_item_id,
         adl.adl_line_num, --Changed
         'N',
         'E',
         p_request_id,
         gms_bc_packets_s.nextval,
         ge.incurred_by_person_id,
         gei.job_id,
         pet.expenditure_category,
         pet.revenue_category_code,
         Decode(gei.net_zero_adjustment_flag,
               'Y', decode(gei.adjusted_encumbrance_item_id,
                           NULL, gei.encumbrance_item_id,
                           gei.adjusted_encumbrance_item_id),
               NULL),
         gei.transaction_source,
         adl.award_set_id,
         adl.ind_compiled_set_id
  from gl_period_statuses glst,
       gl_sets_of_books sob,
       pa_projects p,
       gms_project_types gpt,
       pa_expenditure_types pet,
       gms_award_distributions adl,
       gms_encumbrance_groups_all  geg,
       gms_encumbrances_all ge,
       gms_encumbrance_items_all gei
  where gei.request_id = p_request_id
    and ge.encumbrance_group = geg.encumbrance_group
    and ge.encumbrance_id = gei.encumbrance_id
    and p.project_id = nvl(p_project_id, p.project_id)
    and geg.encumbrance_group = nvl(p_enc_group, geg.encumbrance_group) --Bug 5956414
    and gei.encumbrance_item_id = adl.expenditure_item_id
    and nvl(adl.document_type,'ENC') = 'ENC'
    and nvl(adl.adl_status,'A') = 'A'
    and gei.enc_distributed_flag = 'N'
    and adl.project_id = p.project_id
    and p.project_type = gpt.project_type
    and gpt.sponsored_flag = 'Y'
    and sob.set_of_books_id = p_sob_id
    and glst.set_of_books_id = p_sob_id
    and gei.encumbrance_item_date between glst.start_date and glst.end_date
    and glst.application_id = 101
    and glst.adjustment_period_flag = 'N'
    and gei.encumbrance_type = pet.expenditure_type
    and gei.adjustment_type in ('BURDEN_RECOMPILE', 'BURDEN_RECALC') -- Bug 6761516 'BURDEN_RECALC'
    and adl.fc_status = 'N';

  p_rows_inserted := p_rows_inserted + sql%rowcount;

  --Get batch size.
  FND_PROFILE.GET('PA_NUM_CDL_PER_SET', l_profile_set_size);
  if ( nvl(l_profile_set_size, 0) = 0 ) then
    l_profile_set_size := l_default_set_size;
  end if;

  if l_debug = 'Y' then
    gms_error_pkg.gms_debug('Batch size is: ' || l_profile_set_size, 'C');
  end if;

    if p_enc_group is not null then -- added for bug:8232859
     open brdn_impacted_enc1;
    else
    open brdn_impacted_enc2;
    end if;

  loop --BULK COLLECT Logic

     if p_enc_group is not null then -- added for bug:8232859
 	          fetch brdn_impacted_enc1 bulk collect
 	           into l_brdn_impacted_enc
 	          limit l_profile_set_size;
 	  else
 	         fetch brdn_impacted_enc2 bulk collect
             into l_brdn_impacted_enc
             limit l_profile_set_size;
      end if;
    if nvl(l_brdn_impacted_enc.count, 0) = 0 then
      exit;
    end if;
    for i in 1..l_brdn_impacted_enc.count loop

      if l_debug = 'Y' then
        gms_error_pkg.gms_debug('Processing ENC_ID: ' || l_brdn_impacted_enc(i).expenditure_item_id, 'C');
      end if;

      --Create -ive ADL
      select max(adl_line_num)
      into l_max_adl_line_num
      from gms_award_distributions
      where award_set_id = l_brdn_impacted_enc(i).award_set_id;

      l_negative_ln_adl_tbl(i).award_set_id := l_brdn_impacted_enc(i).award_set_id;
      l_negative_ln_adl_tbl(i).adl_line_num := l_max_adl_line_num + 1;
      l_negative_ln_adl_tbl(i).raw_cost := l_brdn_impacted_enc(i).raw_cost * -1;
      l_negative_ln_adl_tbl(i).document_type := 'ENC';
      l_negative_ln_adl_tbl(i).project_id := l_brdn_impacted_enc(i).project_id;
      l_negative_ln_adl_tbl(i).task_id := l_brdn_impacted_enc(i).task_id;
      l_negative_ln_adl_tbl(i).award_id := l_brdn_impacted_enc(i).award_id;
      l_negative_ln_adl_tbl(i).expenditure_item_id := l_brdn_impacted_enc(i).expenditure_item_id;
      l_negative_ln_adl_tbl(i).cdl_line_num := l_brdn_impacted_enc(i).cdl_line_num;
      l_negative_ln_adl_tbl(i).ind_compiled_set_id := l_brdn_impacted_enc(i).ind_compiled_set_id;
      l_negative_ln_adl_tbl(i).request_id := p_request_id;
      l_negative_ln_adl_tbl(i).line_num_reversed := l_brdn_impacted_enc(i).adl_line_num;
      l_negative_ln_adl_tbl(i).resource_list_member_id := NULL;
      l_negative_ln_adl_tbl(i).adl_status := 'A';
      l_negative_ln_adl_tbl(i).fc_status := 'N';
      l_negative_ln_adl_tbl(i).line_type := 'R';
      l_negative_ln_adl_tbl(i).capitalized_flag := 'N';
      l_negative_ln_adl_tbl(i).capitalizable_flag := l_brdn_impacted_enc(i).capitalizable_flag;
      l_negative_ln_adl_tbl(i).reversed_flag := NULL;
      l_negative_ln_adl_tbl(i).bill_hold_flag := l_brdn_impacted_enc(i).bill_hold_flag;
      --l_negative_ln_adl_tbl(i).burdenable_raw_cost := l_brdn_impacted_enc(i).burdenable_raw_cost * -1; --If we are putting this then take care of gms_award_exp_type_act_cost table.
      l_negative_ln_adl_tbl(i).billable_flag := l_brdn_impacted_enc(i).billable_flag;

      if l_debug = 'Y' then
        gms_error_pkg.gms_debug('Creating -ive Line.', 'C');
      end if;

      --Create -ive ADL
      gms_awards_dist_pkg.create_adls(l_negative_ln_adl_tbl(i));

      l_positive_ln_adl_tbl(i).award_set_id := l_brdn_impacted_enc(i).award_set_id;
      l_positive_ln_adl_tbl(i).adl_line_num := l_max_adl_line_num + 2;
      l_positive_ln_adl_tbl(i).raw_cost := l_brdn_impacted_enc(i).raw_cost;
      l_positive_ln_adl_tbl(i).document_type := 'ENC';
      l_positive_ln_adl_tbl(i).project_id := l_brdn_impacted_enc(i).project_id;
      l_positive_ln_adl_tbl(i).task_id := l_brdn_impacted_enc(i).task_id;
      l_positive_ln_adl_tbl(i).award_id := l_brdn_impacted_enc(i).award_id;
      l_positive_ln_adl_tbl(i).expenditure_item_id := l_brdn_impacted_enc(i).expenditure_item_id;
      l_positive_ln_adl_tbl(i).cdl_line_num := l_brdn_impacted_enc(i).cdl_line_num;
      l_positive_ln_adl_tbl(i).ind_compiled_set_id := NULL;
      l_positive_ln_adl_tbl(i).request_id := p_request_id;
      l_positive_ln_adl_tbl(i).line_num_reversed := NULL;
      l_positive_ln_adl_tbl(i).resource_list_member_id := NULL;
      l_positive_ln_adl_tbl(i).adl_status := 'A';
      l_positive_ln_adl_tbl(i).fc_status := 'N';
      l_positive_ln_adl_tbl(i).line_type := 'R';
      l_positive_ln_adl_tbl(i).capitalized_flag := 'N';
      l_positive_ln_adl_tbl(i).capitalizable_flag := l_brdn_impacted_enc(i).capitalizable_flag;
      l_positive_ln_adl_tbl(i).reversed_flag := NULL;
      l_positive_ln_adl_tbl(i).bill_hold_flag := l_brdn_impacted_enc(i).bill_hold_flag;
      --l_positive_ln_adl_tbl(i).burdenable_raw_cost := l_brdn_impacted_enc(i).burdenable_raw_cost;
      l_positive_ln_adl_tbl(i).billable_flag := l_brdn_impacted_enc(i).billable_flag;

      if l_debug = 'Y' then
        gms_error_pkg.gms_debug('Creating +ive Line.', 'C');
      end if;

      --Create +ive ADL
      gms_awards_dist_pkg.create_adls(l_positive_ln_adl_tbl(i));

      if l_debug = 'Y' then
        gms_error_pkg.gms_debug('Updating reversed flag.', 'C');
      end if;

      --Update reversed_flag on original line.
      update gms_award_distributions
      set reversed_flag = 'Y',
          request_id = p_request_id
      where award_set_id = l_brdn_impacted_enc(i).award_set_id
        and adl_line_num = l_brdn_impacted_enc(i).adl_line_num
        and adl_status = 'A';

      if l_debug = 'Y' then
        gms_error_pkg.gms_debug('Inserting into gms_bc_packets.', 'C');
      end if;

      --Insert into GMS_BC_PACKETS
      insert into gms_bc_packets (packet_id,
                                  set_of_books_id,
                                  je_source_name,
                                  je_category_name,
                                  actual_flag,
                                  period_name,
                                  period_year,
                                  period_num,
                                  project_id,
                                  task_id,
                                  award_id,
                                  result_code,
                                  funding_pattern_id,
                                  funding_sequence,
                                  fp_status,
                                  status_code,
                                  last_update_date,
                                  last_updated_by,
                                  created_by,
                                  creation_date,
                                  last_update_login,
                                  entered_dr,
                                  entered_cr,
                                  expenditure_type,
                                  expenditure_organization_id,
                                  expenditure_item_date,
                                  document_type,
                                  document_header_id,
                                  document_distribution_id,
                                  TRANSFERED_FLAG,
                                  account_type,
                                  request_id,
                                  bc_packet_id,
                                  person_id,
                                  job_id,
                                  expenditure_category,
                                  revenue_category,
                                  adjusted_document_header_id,
                                  transaction_source,
                                  award_set_id,
                                  ind_compiled_set_id)
      Select p_packet_id,
             p_sob_id,
             decode(substr(gei.transaction_source,1,4),
                    'GMSE', gei.transaction_source,
                    decode(gei.transaction_source,
                           'GOLDE', 'Labor Distribution',
                           'Project Accounting')),
             'Encumberances',
             'E',
             glst.period_name,
             glst.period_year,
             glst.period_num,
             p.project_id,
             adl.task_id,
             adl.award_id,
             NULL,
             null,
             null,
             null,
             'P',
             p_sys_date,
             FND_GLOBAL.USER_ID,
             FND_GLOBAL.USER_ID,
             p_sys_date,
             FND_GLOBAL.LOGIN_ID,
             pa_currency.round_currency_amt(decode(sign(adl.raw_cost),1,adl.raw_cost,0)),
             pa_currency.round_currency_amt(decode(sign(adl.raw_cost),-1,-1*adl.raw_cost,0)),
             gei.encumbrance_type,
             nvl(gei.override_to_organization_id,ge.incurred_by_organization_id),
             trunc(gei.encumbrance_item_date),
             'ENC',
             gei.encumbrance_item_id,
             adl.adl_line_num, --Changed
             'N',
             'E',
             p_request_id,
             gms_bc_packets_s.nextval,
             ge.incurred_by_person_id,
             gei.job_id,
             pet.expenditure_category,
             pet.revenue_category_code,
             Decode(gei.net_zero_adjustment_flag,
                   'Y', decode(gei.adjusted_encumbrance_item_id,
                               NULL, gei.encumbrance_item_id,
                               gei.adjusted_encumbrance_item_id),
                   NULL),
             gei.transaction_source,
             adl.award_set_id,
             adl.ind_compiled_set_id
      from gl_period_statuses glst,
           gl_sets_of_books sob,
           pa_projects p,
           gms_project_types gpt,
           pa_expenditure_types pet,
           gms_award_distributions adl,
           gms_encumbrance_groups_all  geg,
           gms_encumbrances_all ge,
           gms_encumbrance_items_all gei
      where gei.request_id = p_request_id
        and ge.encumbrance_group = geg.encumbrance_group
        and ge.encumbrance_id = gei.encumbrance_id
        and p.project_id = nvl(p_project_id, p.project_id)
        and geg.encumbrance_group = nvl(p_enc_group, geg.encumbrance_group) --Bug 5956414
        and gei.encumbrance_item_id = adl.expenditure_item_id
        and nvl(adl.document_type,'ENC') = 'ENC'
        and nvl(adl.adl_status,'A') = 'A'
        and gei.enc_distributed_flag = 'N'
        and adl.project_id = p.project_id
        and p.project_type = gpt.project_type
        and gpt.sponsored_flag = 'Y'
        and sob.set_of_books_id = p_sob_id
        and glst.set_of_books_id = p_sob_id
        and gei.encumbrance_item_date between glst.start_date and glst.end_date
        and glst.application_id = 101
        and glst.adjustment_period_flag = 'N'
        and gei.encumbrance_type = pet.expenditure_type
        and gei.adjustment_type in ('BURDEN_RECOMPILE', 'BURDEN_RECALC') -- Bug 6761516 added 'BURDEN_RECALC'
        and adl.award_set_id = l_brdn_impacted_enc(i).award_set_id
        and adl.adl_line_num in (l_negative_ln_adl_tbl(i).adl_line_num, l_positive_ln_adl_tbl(i).adl_line_num);

      p_rows_inserted := p_rows_inserted + sql%rowcount;
    end loop; --for i in 1..l_brdn_impacted_enc.count loop
  end loop;  --BULK COLLECT Logic

      if p_enc_group is not null then -- added for bug:8232859
 	     close brdn_impacted_enc1;
 	   else
 	     close brdn_impacted_enc2;
 	   end if;

  if l_debug = 'Y' then
    gms_error_pkg.gms_debug('Ending create_burden_impacted_enc.', 'C');
  end if;

end create_burden_impacted_enc;

-- Bug 4961220 : Created the autonomous procedure load_enc_pkts

PROCEDURE load_enc_pkts                (p_enc_group	IN	VARCHAR2 ,
			                p_project_id    IN 	NUMBER,
			                p_end_date	IN 	DATE,
			                p_org_id	IN 	NUMBER,
					p_sob_id        IN 	NUMBER,
					x_packet_id     OUT    NOCOPY  NUMBER,
					x_count         OUT    NOCOPY  NUMBER
                                          ) IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_request_id    	NUMBER := fnd_global.conc_request_id ;
l_rows_inserted         NUMBER;  --Bug 5726575

/* ----------------------------- Update baselined budget_version_id  ----------------------------------- */

x_budget_version_id number(15);

Cursor Cur_for_bvid_update is
    Select distinct award_id,
                    project_id
    from   gms_bc_packets
    where  packet_id = x_packet_id;

BEGIN

/* ---------------- Update of Requset Id on  gms_encumbrance_items_all --------------------- */	--1472753

if p_enc_group is null then -- added for bug:8232859

 	         update gms_encumbrance_items_all
 	         set request_id = l_request_id
 	         where encumbrance_item_id in (
 	         select gei.encumbrance_item_id
 	         from         pa_projects p,
 	                     gms_project_types gpt,
 	                 gms_award_distributions adl,
 	                 gms_encumbrance_groups_all  geg,
 	                 gms_encumbrances_all ge,
 	                 gms_encumbrance_items_all gei
 	         where  /*geg.encumbrance_group =   nvl(p_enc_group,geg.encumbrance_group) -- Bug:8232859
 	         and   */geg.encumbrance_group_status_code = 'RELEASED'                                -- Bug Fix 1364085
 	         and   ge.encumbrance_group  =  geg.encumbrance_group
 	         and   ge.encumbrance_id     =  gei.encumbrance_id
 	         and   p.project_id        = nvl(p_project_id,p.project_id)
 	         and   gei.encumbrance_item_date        <= nvl(p_end_date, gei.encumbrance_item_date)
 	         and   nvl(gei.override_to_organization_id,ge.incurred_by_organization_id)
 	                         = nvl(p_org_id,nvl(gei.override_to_organization_id,ge.incurred_by_organization_id))
 	         and   gei.encumbrance_item_id = adl.expenditure_item_id
 	         and        gei.enc_distributed_flag = 'N'
 	         and        adl.project_id        = p.project_id
 	         and   adl.document_type     = 'ENC'
 	         and         p.project_type        = gpt.project_type
 	         and         gpt.sponsored_flag    = 'Y'
 	         and   nvl(adl.adl_status,'A')= 'A');

 	 else
	update gms_encumbrance_items_all
	set request_id = l_request_id
	where encumbrance_item_id in (
 	select gei.encumbrance_item_id
 	from 	pa_projects p,
 	    	gms_project_types gpt,
        	gms_award_distributions adl,
        	gms_encumbrance_groups_all  geg,
        	gms_encumbrances_all ge,
		gms_encumbrance_items_all gei
 	where geg.encumbrance_group =   p_enc_group -- Bug:8232859
  	and   geg.encumbrance_group_status_code = 'RELEASED'				-- Bug Fix 1364085
  	and   ge.encumbrance_group  =  geg.encumbrance_group
  	and   ge.encumbrance_id     =  gei.encumbrance_id
  	and   p.project_id        = nvl(p_project_id,p.project_id)
  	and   gei.encumbrance_item_date        <= nvl(p_end_date, gei.encumbrance_item_date)
       	and   nvl(gei.override_to_organization_id,ge.incurred_by_organization_id)
			= nvl(p_org_id,nvl(gei.override_to_organization_id,ge.incurred_by_organization_id))
       	and   gei.encumbrance_item_id = adl.expenditure_item_id
   	and	gei.enc_distributed_flag = 'N'
  	and	adl.project_id        = p.project_id
  	and   adl.document_type     = 'ENC'
  	and 	p.project_type        = gpt.project_type
  	and 	gpt.sponsored_flag    = 'Y'
  	and   nvl(adl.adl_status,'A')= 'A');

   	 end if;
/* ---------------- Update of Requset Id on  gms_encumbrance_items_all --------------------- */	--1472753

	        select gl_bc_packets_s.nextval into x_packet_id from dual;

 		insert into gms_bc_packets (
				  packet_id,
                                  set_of_books_id,
                                  je_source_name,
                                  je_category_name,
                                  actual_flag,
                                  period_name,
                                  period_year,
				  period_num,
                                  project_id,
                                  task_id,
                                  award_id,
				  result_code,
				  funding_pattern_id,
				  funding_sequence,
				  fp_status,
                                  status_code,
                                  last_update_date,
                                  last_updated_by,
                                  created_by,
                                  creation_date,
                                  last_update_login,
                                  entered_dr,
                                  entered_cr,
                                  expenditure_type,
                                  expenditure_organization_id,
                                  expenditure_item_date,
                                  document_type,
                                  document_header_id,
                                  document_distribution_id,
				  TRANSFERED_FLAG,
				  account_type, request_id,
				  bc_packet_id,
				  person_id,
				  job_id,
				  expenditure_category,
				  revenue_category,
                                  adjusted_document_header_id,
				  transaction_source,
				  award_set_id
				  )
 		Select
                        x_packet_id,
			p_sob_id,
			--decode(gei.transaction_source,'GOLDE','Labor Distribution','Project Accounting'),	--Bug Fix - 1364133
			decode(substr(gei.transaction_source,1,4),'GMSE',gei.transaction_source,decode(gei.transaction_source,'GOLDE','Labor Distribution','Project Accounting')), -- Bug 3035863
			'Encumberances',
			'E',
			glst.period_name,
			glst.period_year,
			glst.period_num,
                        p.project_id,
                        adl.task_id,
                        adl.award_id,
			 NULL ,
			null,
			null,
			null,
			'P',		-- Bug 2163845
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        FND_GLOBAL.USER_ID,
                        sysdate,
                        FND_GLOBAL.LOGIN_ID,
			pa_currency.round_currency_amt(decode(sign(gei.amount),1,gei.amount,0)),
			pa_currency.round_currency_amt(decode(sign(gei.amount),-1,-1*gei.amount,0)),
                        gei.encumbrance_type,
                        nvl(gei.override_to_organization_id,ge.incurred_by_organization_id),
                        trunc(gei.encumbrance_item_date),
			'ENC',
			gei.encumbrance_item_id,
			adl.adl_line_num, --Bug 5693864 1,
			'N',
			'E',
            		l_request_id,
            		gms_bc_packets_s.nextval,
			ge.incurred_by_person_id,
			gei.job_id,
			pet.expenditure_category,
			pet.revenue_category_code,
                        Decode(gei.net_zero_adjustment_flag,'Y',
                                   Decode(gei.adjusted_encumbrance_item_id,
			                  Null,gei.encumbrance_item_id,
                            	          gei.adjusted_encumbrance_item_id
                                          ), null ),	 -- fix for bug : 2927485
		        gei.transaction_source,
			adl.award_set_id
       		   from gl_period_STATUSES glst,
			gl_sets_of_books sob,
			pa_projects p,
			gms_project_types gpt,
			pa_expenditure_types pet,
            		gms_award_distributions adl,
            		gms_encumbrance_groups_all  geg,
            		gms_encumbrances_all ge,
			gms_encumbrance_items_all gei
		where   gei.request_id=l_request_id
              	  and   ge.encumbrance_group  		=  geg.encumbrance_group
      		  and   ge.encumbrance_id     		=  gei.encumbrance_id
      		  and   p.project_id        = nvl(p_project_id, p.project_id)
                  and   geg.encumbrance_group           = nvl(p_enc_group, geg.encumbrance_group) --Bug 5956414
      		  and   gei.encumbrance_item_id 	= adl.expenditure_item_id
      		  and   nvl(adl.document_type,'ENC')  	= 'ENC'
	  	  and   nvl(adl.adl_status,'A')		= 'A'
     	  	  and	gei.enc_distributed_flag 	= 'N'
	     	  and	adl.project_id        		= p.project_id
	   	  and 	p.project_type        		= gpt.project_type
	  	  and 	gpt.sponsored_flag    		= 'Y'
	  	  and	sob.set_of_books_id	   	= p_sob_id
	  	  and	glst.set_of_books_id   		= p_sob_id
      		  and   gei.encumbrance_item_date between glst.start_date and glst.end_date
	  	  and	glst.application_id	   	= 101
	  	  and	glst.adjustment_period_flag	= 'N'
		  and   gei.encumbrance_type = pet.expenditure_type 		-- Bug 2069132 (RLMI Change)
                  and   nvl(gei.adjustment_type, 'X') not in ('BURDEN_RECOMPILE',  'BURDEN_RECALC'); --Bug 5726575
		                                                                -- Bug 6761516 added 'BURDEN_RECALC'

    		x_count := sql%rowcount;
			IF L_DEBUG = 'Y' THEN
				gms_error_pkg.gms_debug('Encumbrance record count '||x_count,'C');
			END IF;

                --Bug 5726575
                create_burden_impacted_enc(l_request_id,
                                           x_packet_id,
                                           sysdate,
                                           p_sob_id,
                                           p_project_id,
					   p_enc_group, --Bug 5956414
                                           l_rows_inserted);
                x_count := x_count + l_rows_inserted;

                IF L_DEBUG = 'Y' THEN
                  gms_error_pkg.gms_debug('Encumbrance record count after create_burden_impacted_enc: ' || x_count, 'C');
                END IF;

		for records in cur_for_bvid_update
		loop

  			Begin

    				select budget_version_id
    				into   x_budget_version_id
    				from   gms_budget_versions
    				where  project_id = records.project_id
    				and    award_id = records.award_id
    				and    budget_status_code = 'B'
    				and    current_flag= 'Y';

    				update gms_bc_packets
    				set    budget_version_id = x_budget_version_id
    				where  project_id = records.project_id
    				and    award_id = records.award_id
    				and    packet_id = x_packet_id;

 			Exception

    				When others then


         				update gms_bc_packets gms
    					set 	gms.status_code = 'R',
	       					gms.result_code = 'F10',
    						gms.RES_RESULT_CODE = 'F10',
	      					gms.RES_GRP_RESULT_CODE  = 'F10',
	       					gms.TASK_RESULT_CODE = 'F10',
    						gms.AWARD_RESULT_CODE = 'F10'
	       				where 	gms.packet_id = x_packet_id
           				and   	gms.project_id = records.project_id
           				and   	gms.award_id = records.award_id;
			end;
		end loop;
		COMMIT;
EXCEPTION
  When others then
  	IF L_DEBUG = 'Y' THEN
	  gms_error_pkg.gms_debug('load_enc_pkts - In When Others Exception','C');
	END IF;
	RAISE;
END load_enc_pkts;

--------------------------------------------------------------------------------------------------------
-- Procedure to do Fund check on Encumbrance Items
--------------------------------------------------------------------------------------------------------

 Procedure funds_check_enc(errbuf	OUT NOCOPY	VARCHAR2,
			   retcode	OUT NOCOPY	VARCHAR2,
			   p_enc_group	IN	VARCHAR2 default null,
			   p_project_id IN 	NUMBER	 default null,
			   p_end_date	IN 	DATE	 default null,
			   p_org_id	IN 	NUMBER	 default null
                           )
 is

    l_sob_id        	NUMBER(15) ;
    x_packet_id     	NUMBER ;
    x_count         	NUMBER ;
    x_e_code	    	VARCHAR2(1) := null;
    x_e_stage	    	VARCHAR2(10) := null;
    x_return_code   	VARCHAR2(3);
    x_e_mesg	    	VARCHAR2(2000) := null;


BEGIN
	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('****project***'||p_project_id,'C');
		gms_error_pkg.gms_debug('****exp group***'||p_enc_group,'C');
		gms_error_pkg.gms_debug('****end date***'||p_end_date,'C');
		gms_error_pkg.gms_debug('****org id***'||p_org_id,'C');
	END IF;


	-- Bug 1980810 : Added to set currency related global variables
	--		 Call to pa_currency.round_currency_amt function will use
	--		 global variables and thus improves performance
	--		 For Actuals this call is done in Funds check process (gmsfcfcb.pls) itself.
	--		 For Manual enc. as we are using PA rounding call, we are setting it here.

	 pa_currency.set_currency_info;


		select set_of_books_id
		into l_sob_id
		from pa_implementations;


        load_enc_pkts                  (p_enc_group     => p_enc_group ,
			                p_project_id    => p_project_id,
			                p_end_date	=> p_end_date,
			                p_org_id	=> p_org_id,
					p_sob_id        => l_sob_id,
					x_packet_id     => x_packet_id,
					x_count         => x_count);


    		If x_count > 0 THEN
			IF L_DEBUG = 'Y' THEN
				gms_error_pkg.gms_debug('Calling gms funds checker','C');
			END IF;

       			If not GMS_FUNDS_CONTROL_PKG.GMS_FCK( l_sob_id,
      		             	              		x_packet_id,
                              	              		'E',                     -- DEFAULT 'R'
    	           	 	              		'N',                     --x_over DEFAULT 'N'
				              		'Y',                      --x_partial DEFAULT 'N'
    	             		              		fnd_global.user_id,       -- x_user_id,
                   		              		fnd_global.resp_id,
			 	              		'Y',
				              		x_return_code,
			 	              		x_e_code,
			 	              		x_e_mesg)   then

            			errbuf	:= x_e_stage||': '||x_e_mesg;


          		End if ;

      		End if ;
			IF L_DEBUG = 'Y' THEN
				gms_error_pkg.gms_debug('exception x_count-'||x_count,'C');
			END IF;

EXCEPTION
  When others then
       RETCODE := '2'; -- Changed from 'H' to '2' for Bug:2464800
       errcode := SQLCODE;
       errmesg := sqlerrm;
       ERRBUF:='Error in '||object_type||object_name||sub_program||'at stage '||
                 to_char(stage)||' '||errmesg;
End funds_check_enc;


-----------------------------------------------------------------------------------------------
-- Procedure to submit Fundscheck Encumbrance Items called from GMSTRENE.fmb
------------------------------------------------------------------------------------------------
Function submit_funds_check_enc( p_enc_group   IN      VARCHAR2 default null,
			          p_project_id		NUMBER	 default null,
			          p_end_date		DATE	 default null,
			          p_org_id		NUMBER	 default null) return NUMBER
IS
 v_reqid     number;
 complete    boolean;
 phase       varchar2(30);
 status      varchar2(30);
 dev_phase   varchar2(30);
 dev_status  varchar2(30);
 message     varchar2(240);
 BEGIN
        sub_program   := ' COSTING ';
	v_reqid:= fnd_request.submit_request('GMS','GMSFCENC','','',FALSE
          	                              ,p_enc_group
                                              ,p_project_id
                                              ,to_char(p_end_date,'YYYY/MM/DD HH24:MI:SS')
                                              ,p_org_id
					      ,null
					      ,'ENC');
      	if(v_reqid=0) then
		return v_reqid;
     	else
    	    commit;
            complete := FND_CONCURRENT.WAIT_FOR_REQUEST(v_reqid,10,0,phase,status,
                                                        dev_phase, dev_status,message);
 	    return v_reqid;
     	end if;
END submit_funds_check_enc;


END GMS_FC_SYS ;

/
