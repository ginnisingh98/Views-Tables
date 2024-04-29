--------------------------------------------------------
--  DDL for Package Body BEN_CWB_DATA_MODEL_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_DATA_MODEL_UPGRADE" as
/* $Header: bencwbmu.pkb 120.2.12010000.2 2008/12/04 14:17:43 cakunuru ship $ */
/* ===========================================================================+
 * Name
 *   Compensation Workbench Data Model Upgrade Package
 * Purpose
 *   This package is used to migrate data of old customers to
 *   new CWB Data model.
 *
 * Version Date        Author    Comment
 * -------+-----------+---------+----------------------------------------------
 * 115.0   14-Jan-2004 maagrawa   created
 * 115.1   15-Jan-2004 maagrawa   Added out parameters to main;used by CM.
 * 115.2   22-Jan-2004 maagrawa   Added upgrade for PP ranking.
 * 115.3   06-Feb-2004 skota      Changed the column name approval_mode to
 *                                approval_mode_cd
 * 115.4   10-Feb-2004 skota      Added get_ functions and replaced the inner
 *                                selects with calls to get_ functions
 * 115.5   12-Feb-2004 maagrawa   Call to upgrade_person_rates was missing.
 * 115.6   13-Feb-2004 skota      Added the supervisor_id to
 *                                refresh_person_info_group_pl
 * 115.7   01-Mar-2004 maagrawa   New algo to get sub_acty_typ_cd.
 * 115.8   02-Mar-2004 maagrawa   hr_update_utility package changes.
 * 115.9   15-Mar-2004 maagrawa   Commented out hr_update_utility package
 *                                call as it will not be delivered in 1st patch.
 * 115.10  30-Mar-2004 maagrawa   Null the rankings which are not integers.
 * 115.11  02-Mar-2004 maagrawa   Remove spaces for rank.
 *                                Log Upgrade progress messages.
 * 115.12  25-May-2004 maagrawa   Splitting of Perf/Promo records.
 * 115.13  21-Sep-2004 maagrawa   Included upgrade for emp reassign trans.
 * 115.14  19-Jan-2005 maagrawa   Re-instate hr_update_utility calls.
 * 115.15  28-Apr-2005 maagrawa   Also check whether the process is complete
 *                                before re-submit.
 * 115.16  03-May-2005 maagrawa   Increase the size of brief name from 250
 *                                to 360.
 * 115.17  03-Jan-2006 maagrawa   Modified for multi-currency upgrade.
 * 115.18  21-Dec-2007 steotia    6692393: Removed group_pl_id null check.
 * ==========================================================================+
 */

g_package  varchar2(80) := 'ben_cwb_data_model_upgrade.';


g_commit_size   constant number := 10000;

type t_val    is table of number index by binary_integer;
type t_id     is table of number(15) index by binary_integer;
type t_date   is table of date index by binary_integer;
type t_rowid  is table of rowid index by binary_integer;
type t_varchar_small is table of varchar2(30) index by binary_integer;
type t_varchar_med   is table of varchar2(240) index by binary_integer;
type t_varchar_med2  is table of varchar2(150) index by binary_integer;
type t_varchar_med3  is table of varchar2(360) index by binary_integer;
type t_varchar_big  is table of varchar2(2000) index by binary_integer;

g_approval_mode varchar2(30) := null;

procedure commit_and_log(p_text in varchar2) is
begin

  insert into ben_transaction
       (transaction_id
       ,transaction_type
       ,attribute1
       ,attribute40)
  values
       (ben_transaction_s.nextval
       ,'CWBUPGRADE'
       ,to_char(sysdate, 'yyyy/mm/dd hh24:mi:ss')
       ,p_text);

  commit;
end;

procedure upgrade_plan_design is

  cursor c_profile is
     select val.profile_option_value
     from   fnd_profile_options prf
           ,fnd_profile_option_values val
     where  prf.profile_option_name = 'BEN_CWB_APPROVAL_MODE'
     and    prf.application_id = 805
     and    prf.application_id = val.application_id
     and    prf.profile_option_id = val.profile_option_id
     and    val.level_id = 10001
     and    val.level_value = 0;

  cursor c_tasks(v_pl_id number) is
     select min(tk.ordr_num) min_ordr
           ,max(tk.ordr_num) max_ordr
     from  ben_cwb_wksht_grp tk
     where tk.pl_id = v_pl_id;


  cursor c_oipl(v_pl_id number) is
     select distinct oipl.oipl_id
     from   ben_oipl_f oipl
     where  oipl.pl_id = v_pl_id;

  cursor c_pl_dsgn is
     select enp.enrt_perd_id
           ,pl.pl_id
           ,pl.business_group_id
           ,enp.asnd_lf_evt_dt
           ,enp.data_freeze_date
           ,enp.uses_bdgt_flag
           ,decode(typ.comp_typ_cd, 'ICM2', 'ICM5',
                                    'ICM3', 'ICM5',
                                    'ICM6', 'ICM5',
                   typ.comp_typ_cd) comp_typ_cd
           ,typ.pl_typ_id
           ,enp.prsvr_bdgt_cd prsrv_bdgt_cd
     from  ben_pl_typ_f typ
          ,ben_pl_f pl
          ,ben_popl_enrt_typ_cycl_f cyc
          ,ben_enrt_perd enp
     where typ.opt_typ_cd = 'CWB'
     and   typ.pl_typ_id  = pl.pl_typ_id
     and   pl.pl_id       = cyc.pl_id
     and   cyc.popl_enrt_typ_cycl_id = enp.popl_enrt_typ_cycl_id
     -- and   pl.group_pl_id is null
     and   enp.data_freeze_date is null
     and   not exists (select 'Y'
                       from   ben_cwb_pl_dsgn pln
                       where  pln.pl_id = pl.pl_id
                       and    pln.lf_evt_ocrd_dt = enp.asnd_lf_evt_dt)
     and   exists (select 'Y'
                   from   ben_per_in_ler pil
                         ,ben_pil_elctbl_chc_popl popl
                   where pil.lf_evt_ocrd_dt = enp.asnd_lf_evt_dt
                   and   pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
                   and   pil.group_pl_id is null
                   and   pil.per_in_ler_id = popl.per_in_ler_id
                   and   popl.pl_id = pl.pl_id
                   and   popl.enrt_typ_cycl_cd = 'COMP');

    l_old_pl_id     number := -999;
    l_old_pl_typ_id number := -999;
    l_task_exist    boolean;
    l_min_ordr      number;
    l_max_ordr      number;

begin

  for l_pl_dsgn in c_pl_dsgn loop

    if g_approval_mode is null then
      open  c_profile;
      fetch c_profile into g_approval_mode;
      close c_profile;

      if g_approval_mode is null then
        g_approval_mode := 'NR';
      end if;
    end if;

    if l_pl_dsgn.pl_id <> l_old_pl_id then

      begin
        update ben_pl_f pl
        set    pl.group_pl_id = pl.pl_id
        where  pl.pl_id = l_pl_dsgn.pl_id
        and    pl.group_pl_id is null;
      exception
        when others then
          null;
      end;


      begin
        update ben_acty_base_rt_f abr
        set    abr.sub_acty_typ_cd = decode(abr.oipl_id,
                                                null, l_pl_dsgn.comp_typ_cd,
                                                'ICM11')
        where  abr.acty_typ_cd = 'CWBWS'
        and    abr.sub_acty_typ_cd is null
        and    (abr.pl_id = l_pl_dsgn.pl_id
               OR
               abr.oipl_id in (select oipl.oipl_id
                               from   ben_oipl_f oipl
                               where  oipl.pl_id = l_pl_dsgn.pl_id));
      exception
        -- No data found.
        when others then
          null;
      end;

      l_task_exist   := false;
      l_min_ordr  := null;
      l_max_ordr := null;

      open  c_tasks(l_pl_dsgn.pl_id);
      fetch c_tasks into l_min_ordr, l_max_ordr;
      if l_min_ordr is not null then
        l_task_exist := true;
      end if;
      close c_tasks;

      if l_task_exist then

         update ben_cwb_wksht_grp grp
         set    grp.status_cd = 'A'
              ,grp.hidden_cd = null
         where grp.pl_id = l_pl_dsgn.pl_id;

      end if;

      if l_min_ordr is null then
        l_min_ordr := 10;
      else
        l_min_ordr := l_min_ordr -1 ;
      end if;

      if l_max_ordr is null then
        l_max_ordr := 20;
      else
        l_max_ordr := l_max_ordr + 10;
      end if;


      if l_pl_dsgn.uses_bdgt_flag = 'Y' then
        insert into ben_cwb_wksht_grp
             (cwb_wksht_grp_id ,business_group_id
             ,pl_id ,ordr_num ,wksht_grp_cd ,label
             ,status_cd ,hidden_cd ,object_version_number)
         values
              (ben_cwb_wksht_grp_s.nextval ,l_pl_dsgn.business_group_id
              ,l_pl_dsgn.pl_id ,l_min_ordr
              ,'BDGT' ,'Set Budgets' ,'A' ,null ,1);
      end if;

      if not(l_task_exist) then
       insert into ben_cwb_wksht_grp
             (cwb_wksht_grp_id ,business_group_id
             ,pl_id ,ordr_num ,wksht_grp_cd ,label
             ,status_cd ,hidden_cd ,object_version_number)
         values
              (ben_cwb_wksht_grp_s.nextval ,l_pl_dsgn.business_group_id
              ,l_pl_dsgn.pl_id ,l_max_ordr ,'COMP'
              ,'Allocate Compensation' ,'A' ,null ,1);
        l_max_ordr := l_max_ordr + 10;
      end if;


      insert into ben_cwb_wksht_grp
             (cwb_wksht_grp_id ,business_group_id
             ,pl_id ,ordr_num ,wksht_grp_cd ,label
             ,status_cd ,hidden_cd ,object_version_number)
         values
              (ben_cwb_wksht_grp_s.nextval ,l_pl_dsgn.business_group_id
              ,l_pl_dsgn.pl_id ,l_max_ordr ,'APPR'
              ,'Manage Approvals' ,'A' ,null ,1);
      l_max_ordr := l_max_ordr + 10;

      insert into ben_cwb_wksht_grp
             (cwb_wksht_grp_id ,business_group_id
             ,pl_id ,ordr_num ,wksht_grp_cd ,label
             ,status_cd ,hidden_cd ,object_version_number)
         values
              (ben_cwb_wksht_grp_s.nextval ,l_pl_dsgn.business_group_id
              ,l_pl_dsgn.pl_id ,l_max_ordr ,'RVW'
              ,'Review and Submit' ,'A' ,null ,1);

    end if; -- pl_id <> old_pl_id

    if l_pl_dsgn.pl_typ_id <> l_old_pl_typ_id then

      begin

        update ben_opt_f opt
        set    opt.group_opt_id = opt.opt_id
        where  opt.opt_id in (select pon.opt_id
                              from   ben_pl_typ_opt_typ_f pon
                              where  pon.pl_typ_id = l_pl_dsgn.pl_typ_id)
        and    opt.group_opt_id is null;

      exception
        when others then
          null;
      end;

    end if; -- pl_typ_id <> old_pl_typ_id


    begin
      update ben_enrt_perd perd
      set    perd.data_freeze_date = perd.asnd_lf_evt_dt
            ,perd.approval_mode_cd = g_approval_mode
      where  perd.enrt_perd_id = l_pl_dsgn.enrt_perd_id
      and    perd.data_freeze_date is null;
    exception
      when others then
        null;
    end;

    -- Refresh Plan design information
    ben_cwb_pl_dsgn_pkg.refresh_pl_dsgn(l_pl_dsgn.pl_id,l_pl_dsgn.asnd_lf_evt_dt,l_pl_dsgn.asnd_lf_evt_dt);

    l_old_pl_id := l_pl_dsgn.pl_id;
    l_old_pl_typ_id := l_pl_dsgn.pl_typ_id;

  end loop;

  commit_and_log('Plan Design Upgrade Complete');

end upgrade_plan_design;


procedure upgrade_hrchy is
begin

     insert into ben_cwb_group_hrchy
       (mgr_per_in_ler_id
       ,emp_per_in_ler_id
       ,lvl_num
       ,last_update_date
       ,last_updated_by
       ,last_update_login
       ,created_by
       ,creation_date
       ,object_version_number)
     select /*+INDEX(emp_popl,ben_pil_elctbl_chc_popl_pk) INDEX(mgr_popl,ben_pil_elctbl_chc_popl_pk)*/
           mgr_popl.per_in_ler_id
          ,emp_popl.per_in_ler_id
          ,hrchy.lvl_num
          ,hrchy.last_update_date
          ,hrchy.last_updated_by
          ,hrchy.last_update_login
          ,hrchy.created_by
          ,hrchy.creation_date
          ,1
     from  ben_cwb_hrchy hrchy
          ,ben_pil_elctbl_chc_popl emp_popl
          ,ben_pil_elctbl_chc_popl mgr_popl
     where  nvl(hrchy.object_version_number,1) < 9999
     and    lvl_num > -1
     and    hrchy.emp_pil_elctbl_chc_popl_id = emp_popl.pil_elctbl_chc_popl_id
     and    hrchy.mgr_pil_elctbl_chc_popl_id = mgr_popl.pil_elctbl_chc_popl_id;

     update ben_cwb_hrchy
     set object_version_number = 9999
     where lvl_num > -1
     and nvl(object_version_number,1) < 9999;

     commit_and_log('Hierarchy Upgrade Complete');

end upgrade_hrchy;


procedure upgrade_person_groups is
begin

    insert into ben_cwb_person_groups
       (group_per_in_ler_id
       ,group_pl_id
       ,group_oipl_id
       ,lf_evt_ocrd_dt
       ,bdgt_pop_cd
       ,due_dt
       ,access_cd
       ,approval_cd
       ,submit_cd
       ,dist_bdgt_val
       ,ws_bdgt_val
       ,rsrv_val
       ,dist_bdgt_mn_val
       ,dist_bdgt_mx_val
       ,dist_bdgt_incr_val
       ,ws_bdgt_mn_val
       ,ws_bdgt_mx_val
       ,ws_bdgt_incr_val
       ,rsrv_mn_val
       ,rsrv_mx_val
       ,rsrv_incr_val
       ,dist_bdgt_iss_val
       ,ws_bdgt_iss_val
       ,dist_bdgt_iss_date
       ,ws_bdgt_iss_date
       ,ws_bdgt_val_last_upd_date
       ,dist_bdgt_val_last_upd_date
       ,rsrv_val_last_upd_date
       ,ws_bdgt_val_last_upd_by
       ,dist_bdgt_val_last_upd_by
       ,rsrv_val_last_upd_by
       ,object_version_number)
    select pil.per_in_ler_id
          ,popl.pl_id
          ,nvl(epe.oipl_id, -1)
          ,pil.lf_evt_ocrd_dt
          ,decode(popl.bdgt_stat_cd, null, null,
                                   'NS', null,
                                   popl.pop_cd) pop_cd
          ,popl.ws_due_dt
          ,popl.ws_acc_cd
          ,decode(popl.ws_stat_cd,
                      'PR', 'PR',
                      'AP', 'AP',
                      null)  approval_cd
          ,decode(popl.ws_stat_cd,
                    'PR', 'SU',
                    'PA', 'SU',
                    'AP', 'SU',
                    'NS')      submit_cd
          ,db.val dist_bdgt_val
          ,wb.val ws_bdgt_val
          ,rs.val rsrv_val
          ,db.mn_elcn_val dist_bdgt_mn_val
          ,db.mx_elcn_val dist_bdgt_mx_val
          ,db.incrmt_elcn_val dist_bdgt_incr_val
          ,wb.mn_elcn_val ws_bdgt_mn_val
          ,wb.mx_elcn_val ws_bdgt_mx_val
          ,wb.incrmt_elcn_val ws_bdgt_incr_val
          ,rs.mn_elcn_val rsrv_mn_val
          ,rs.mx_elcn_val rsrv_mx_val
          ,rs.incrmt_elcn_val rsrv_incr_val
          ,db.iss_val dist_bdgt_iss_val
          ,wb.iss_val ws_bdgt_iss_val
          ,popl.bdgt_iss_dt dist_bdgt_iss_date
          ,popl.ws_iss_dt ws_bdgt_iss_date
          ,wb.val_last_upd_date ws_bdgt_val_upd_date
          ,db.val_last_upd_date dist_bdgt_val_upd_date
          ,rs.val_last_upd_date rsrv_val_upd_date
          ,wb.val_last_upd_person_id ws_bdgt_val_last_upd_by
          ,db.val_last_upd_person_id dist_bdgt_val_last_upd_by
          ,rs.val_last_upd_person_id rsrv_val_last_upd_by
          ,1
    from ben_per_in_ler pil
        ,ben_pil_elctbl_chc_popl popl
        ,ben_elig_per_elctbl_chc epe
        ,ben_cwb_person_groups grp
        ,ben_enrt_rt db
        ,ben_enrt_rt wb
        ,ben_enrt_rt rs
    where pil.per_in_ler_stat_cd in ('PROCD', 'STRTD')
    and   pil.group_pl_id is null
    and   pil.assignment_id is null
    and   pil.per_in_ler_id = popl.per_in_ler_id
    and   popl.enrt_typ_cycl_cd = 'COMP'
    and   popl.assignment_id is not null
    and   popl.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
    and   epe.per_in_ler_id = grp.group_per_in_ler_id (+)
    and   epe.pl_id = grp.group_pl_id (+)
    and   nvl(epe.oipl_id, -1) = grp.group_oipl_id (+)
    and   grp.group_per_in_ler_id is null
    and   epe.elig_per_elctbl_chc_id = db.elig_per_elctbl_chc_id (+)
    and   db.acty_typ_cd (+) = 'CWBDB'
    and   epe.elig_per_elctbl_chc_id = wb.elig_per_elctbl_chc_id (+)
    and   wb.acty_typ_cd (+) = 'CWBWB'
    and   epe.elig_per_elctbl_chc_id = rs.elig_per_elctbl_chc_id (+)
    and   rs.acty_typ_cd (+) = 'CWBR';

    commit_and_log('Person Groups Upgrade Complete');

end upgrade_person_groups;


procedure upgrade_person_rates is
begin

    insert into ben_cwb_person_rates
        (person_rate_id
        ,group_per_in_ler_id
        ,pl_id
        ,oipl_id
        ,group_pl_id
        ,group_oipl_id
        ,lf_evt_ocrd_dt
        ,elig_flag
        ,ws_val
        ,ws_mn_val
        ,ws_mx_val
        ,ws_incr_val
        ,elig_sal_val
        ,stat_sal_val
        ,oth_comp_val
        ,tot_comp_val
        ,misc1_val
        ,misc2_val
        ,misc3_val
        ,rec_val
        ,rec_mn_val
        ,rec_mx_val
        ,rec_incr_val
        ,ws_val_last_upd_date
        ,ws_val_last_upd_by
        ,pay_proposal_id
        ,element_entry_value_id
        ,person_id
        ,assignment_id
        ,ws_rt_start_date
        ,object_version_number
        ,currency)
    select ben_cwb_person_rates_s.nextval
          ,pil.per_in_ler_id
          ,popl.pl_id
          ,nvl(epe.oipl_id, -1)
          ,popl.pl_id
          ,nvl(epe.oipl_id, -1)
          ,pil.lf_evt_ocrd_dt
          ,epe.elig_flag
          ,ws.val ws_val
          ,ws.mn_elcn_val ws_mn_val
          ,ws.mx_elcn_val ws_mx_val
          ,ws.incrmt_elcn_val ws_incr_val
          ,es.val      elig_sal_val
          ,ss.val      stat_sal_val
          ,oc.val      oth_comp_val
          ,tc.val      tot_comp_val
          ,m1.val      misc1_val
          ,m2.val      misc2_val
          ,m3.val      misc3_val
          ,rc.val    rec_val
          ,rc.mn_elcn_val rec_mn_val
          ,rc.mx_elcn_val rec_mx_val
          ,rc.incrmt_elcn_val rec_incr_val
          ,ws.val_last_upd_date ws_val_upd_date
          ,ws.val_last_upd_person_id ws_val_last_upd_by
          ,decode(prv.pk_id_table_name,
                 'PER_PAY_PROPOSALS',prv.pk_id,null) pay_proposal_id
          ,prv.element_entry_value_id
          ,pil.person_id
          ,popl.assignment_id
          ,nvl(prv.rt_strt_dt, ws.rt_strt_dt)
          ,1
          ,popl.uom
    from ben_per_in_ler pil
        ,ben_pil_elctbl_chc_popl popl
        ,ben_elig_per_elctbl_chc epe
        ,ben_cwb_person_rates rate
        ,ben_enrt_rt ws
        ,ben_enrt_rt es
        ,ben_enrt_rt ss
        ,ben_enrt_rt oc
        ,ben_enrt_rt tc
        ,ben_enrt_rt m1
        ,ben_enrt_rt m2
        ,ben_enrt_rt m3
        ,ben_enrt_rt rc
        ,ben_prtt_rt_val prv
    where pil.per_in_ler_stat_cd in ('PROCD', 'STRTD')
    and   pil.group_pl_id is null
    and   pil.assignment_id is null
    and   pil.per_in_ler_id = popl.per_in_ler_id
    and   popl.enrt_typ_cycl_cd = 'COMP'
    and   popl.assignment_id is not null
    and   popl.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
    and   epe.elctbl_flag = 'Y'
    and   epe.per_in_ler_id = rate.group_per_in_ler_id (+)
    and   epe.pl_id = rate.pl_id (+)
    and   nvl(epe.oipl_id, -1) = rate.oipl_id (+)
    and   rate.group_per_in_ler_id is null
    and   epe.elig_per_elctbl_chc_id = ws.elig_per_elctbl_chc_id (+)
    and   ws.acty_typ_cd (+) = 'CWBWS'
    and   epe.elig_per_elctbl_chc_id = es.elig_per_elctbl_chc_id (+)
    and   es.acty_typ_cd (+) = 'CWBES'
    and   epe.elig_per_elctbl_chc_id = ss.elig_per_elctbl_chc_id (+)
    and   ss.acty_typ_cd (+) = 'CWBSS'
    and   epe.elig_per_elctbl_chc_id = oc.elig_per_elctbl_chc_id (+)
    and   oc.acty_typ_cd (+) = 'CWBOS'
    and   epe.elig_per_elctbl_chc_id = tc.elig_per_elctbl_chc_id (+)
    and   tc.acty_typ_cd (+) = 'CWBTC'
    and   epe.elig_per_elctbl_chc_id = m1.elig_per_elctbl_chc_id (+)
    and   m1.acty_typ_cd (+) = 'CWBMR1'
    and   epe.elig_per_elctbl_chc_id = m2.elig_per_elctbl_chc_id (+)
    and   m2.acty_typ_cd (+) = 'CWBMR2'
    and   epe.elig_per_elctbl_chc_id = m3.elig_per_elctbl_chc_id (+)
    and   m3.acty_typ_cd (+) = 'CWBMR3'
    and   epe.elig_per_elctbl_chc_id = rc.elig_per_elctbl_chc_id (+)
    and   rc.acty_typ_cd (+) = 'CWBRA'
    and   ws.prtt_rt_val_id = prv.prtt_rt_val_id (+)
    and   prv.prtt_rt_val_stat_cd is null;

    commit_and_log('Person Rates Upgrade Complete');

end upgrade_person_rates;

procedure upgrade_person_info is

  cursor c_pil is
     select pil.per_in_ler_id
           ,pil.person_id
           ,popl.assignment_id
           ,popl.pl_id
           ,pil.lf_evt_ocrd_dt
           ,popl.uom
           ,popl.comments
           ,popl.ws_mgr_id
           ,popl.mgr_ovrid_dt
           ,popl.mgr_ovrid_person_id
           ,popl.pel_attribute_category
           ,popl.pel_attribute1
           ,popl.pel_attribute2
           ,popl.pel_attribute3
           ,popl.pel_attribute4
           ,popl.pel_attribute5
           ,popl.pel_attribute6
           ,popl.pel_attribute7
           ,popl.pel_attribute8
           ,popl.pel_attribute9
           ,popl.pel_attribute10
           ,popl.pel_attribute11
           ,popl.pel_attribute12
           ,popl.pel_attribute13
           ,popl.pel_attribute14
           ,popl.pel_attribute15
           ,popl.pel_attribute16
           ,popl.pel_attribute17
           ,popl.pel_attribute18
           ,popl.pel_attribute19
           ,popl.pel_attribute20
           ,popl.pel_attribute21
           ,popl.pel_attribute22
           ,popl.pel_attribute23
           ,popl.pel_attribute24
           ,popl.pel_attribute25
           ,popl.pel_attribute26
           ,popl.pel_attribute27
           ,popl.pel_attribute28
           ,popl.pel_attribute29
           ,popl.pel_attribute30
      from ben_per_in_ler pil
          ,ben_pil_elctbl_chc_popl popl
          ,ben_cwb_person_info per
      where pil.group_pl_id is null
      and   pil.assignment_id is null
      and   pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
      and   pil.per_in_ler_id = popl.per_in_ler_id
      and   popl.enrt_typ_cycl_cd = 'COMP'
      and   popl.assignment_id is not null
      and   popl.per_in_ler_id = per.group_per_in_ler_id (+)
      and   per.assignment_id is null;

  l_t_per_in_ler_id t_id;
  l_t_person_id     t_id;
  l_t_assignment_id t_id;
  l_t_pl_id         t_id;
  l_t_lf_evt_ocrd_dt t_date;
  l_t_currency      t_varchar_small;
  l_t_comments      t_varchar_big;
  l_t_ws_mgr_id     t_id;
  l_t_mgr_ovrid_dt  t_date;
  l_t_mgr_ovrid_person_id t_id;
  l_t_pel_attribute_category t_varchar_small;
  l_t_pel_attribute1 t_varchar_med2;
  l_t_pel_attribute2 t_varchar_med2;
  l_t_pel_attribute3 t_varchar_med2;
  l_t_pel_attribute4 t_varchar_med2;
  l_t_pel_attribute5 t_varchar_med2;
  l_t_pel_attribute6 t_varchar_med2;
  l_t_pel_attribute7 t_varchar_med2;
  l_t_pel_attribute8 t_varchar_med2;
  l_t_pel_attribute9 t_varchar_med2;
  l_t_pel_attribute10 t_varchar_med2;
  l_t_pel_attribute11 t_varchar_med2;
  l_t_pel_attribute12 t_varchar_med2;
  l_t_pel_attribute13 t_varchar_med2;
  l_t_pel_attribute14 t_varchar_med2;
  l_t_pel_attribute15 t_varchar_med2;
  l_t_pel_attribute16 t_varchar_med2;
  l_t_pel_attribute17 t_varchar_med2;
  l_t_pel_attribute18 t_varchar_med2;
  l_t_pel_attribute19 t_varchar_med2;
  l_t_pel_attribute20 t_varchar_med2;
  l_t_pel_attribute21 t_varchar_med2;
  l_t_pel_attribute22 t_varchar_med2;
  l_t_pel_attribute23 t_varchar_med2;
  l_t_pel_attribute24 t_varchar_med2;
  l_t_pel_attribute25 t_varchar_med2;
  l_t_pel_attribute26 t_varchar_med2;
  l_t_pel_attribute27 t_varchar_med2;
  l_t_pel_attribute28 t_varchar_med2;
  l_t_pel_attribute29 t_varchar_med2;
  l_t_pel_attribute30 t_varchar_med2;

begin


  open c_pil;

  loop
    fetch c_pil bulk collect into
          l_t_per_in_ler_id
         ,l_t_person_id
         ,l_t_assignment_id
         ,l_t_pl_id
         ,l_t_lf_evt_ocrd_dt
         ,l_t_currency
         ,l_t_comments
         ,l_t_ws_mgr_id
         ,l_t_mgr_ovrid_dt
         ,l_t_mgr_ovrid_person_id
         ,l_t_pel_attribute_category
         ,l_t_pel_attribute1
         ,l_t_pel_attribute2
         ,l_t_pel_attribute3
         ,l_t_pel_attribute4
         ,l_t_pel_attribute5
         ,l_t_pel_attribute6
         ,l_t_pel_attribute7
         ,l_t_pel_attribute8
         ,l_t_pel_attribute9
         ,l_t_pel_attribute10
         ,l_t_pel_attribute11
         ,l_t_pel_attribute12
         ,l_t_pel_attribute13
         ,l_t_pel_attribute14
         ,l_t_pel_attribute15
         ,l_t_pel_attribute16
         ,l_t_pel_attribute17
         ,l_t_pel_attribute18
         ,l_t_pel_attribute19
         ,l_t_pel_attribute20
         ,l_t_pel_attribute21
         ,l_t_pel_attribute22
         ,l_t_pel_attribute23
         ,l_t_pel_attribute24
         ,l_t_pel_attribute25
         ,l_t_pel_attribute26
         ,l_t_pel_attribute27
         ,l_t_pel_attribute28
         ,l_t_pel_attribute29
         ,l_t_pel_attribute30
    limit g_commit_size;


    if l_t_per_in_ler_id.count > 0 then

      forall i in l_t_per_in_ler_id.first .. l_t_per_in_ler_id.last
        insert into ben_cwb_person_info
            (group_per_in_ler_id
            ,assignment_id
            ,person_id
            ,group_pl_id
            ,lf_evt_ocrd_dt
            ,base_salary_currency
            ,ws_comments
            ,cpi_attribute_category
            ,cpi_attribute1
            ,cpi_attribute2
            ,cpi_attribute3
            ,cpi_attribute4
            ,cpi_attribute5
            ,cpi_attribute6
            ,cpi_attribute7
            ,cpi_attribute8
            ,cpi_attribute9
            ,cpi_attribute10
            ,cpi_attribute11
            ,cpi_attribute12
            ,cpi_attribute13
            ,cpi_attribute14
            ,cpi_attribute15
            ,cpi_attribute16
            ,cpi_attribute17
            ,cpi_attribute18
            ,cpi_attribute19
            ,cpi_attribute20
            ,cpi_attribute21
            ,cpi_attribute22
            ,cpi_attribute23
            ,cpi_attribute24
            ,cpi_attribute25
            ,cpi_attribute26
            ,cpi_attribute27
            ,cpi_attribute28
            ,cpi_attribute29
            ,cpi_attribute30
            ,object_version_number)
        values
          (l_t_per_in_ler_id(i)
          ,l_t_assignment_id(i)
          ,l_t_person_id(i)
          ,l_t_pl_id(i)
          ,l_t_lf_evt_ocrd_dt(i)
          ,l_t_currency(i)
          ,l_t_comments(i)
          ,l_t_pel_attribute_category(i)
          ,l_t_pel_attribute1(i)
          ,l_t_pel_attribute2(i)
          ,l_t_pel_attribute3(i)
          ,l_t_pel_attribute4(i)
          ,l_t_pel_attribute5(i)
          ,l_t_pel_attribute6(i)
          ,l_t_pel_attribute7(i)
          ,l_t_pel_attribute8(i)
          ,l_t_pel_attribute9(i)
          ,l_t_pel_attribute10(i)
          ,l_t_pel_attribute11(i)
          ,l_t_pel_attribute12(i)
          ,l_t_pel_attribute13(i)
          ,l_t_pel_attribute14(i)
          ,l_t_pel_attribute15(i)
          ,l_t_pel_attribute16(i)
          ,l_t_pel_attribute17(i)
          ,l_t_pel_attribute18(i)
          ,l_t_pel_attribute19(i)
          ,l_t_pel_attribute20(i)
          ,l_t_pel_attribute21(i)
          ,l_t_pel_attribute22(i)
          ,l_t_pel_attribute23(i)
          ,l_t_pel_attribute24(i)
          ,l_t_pel_attribute25(i)
          ,l_t_pel_attribute26(i)
          ,l_t_pel_attribute27(i)
          ,l_t_pel_attribute28(i)
          ,l_t_pel_attribute29(i)
          ,l_t_pel_attribute30(i)
          ,1);


      forall i in l_t_per_in_ler_id.first .. l_t_per_in_ler_id.last
        update ben_per_in_ler pil
        set    pil.assignment_id = l_t_assignment_id(i)
              ,pil.group_pl_id   = l_t_pl_id (i)
              ,pil.ws_mgr_id     = l_t_ws_mgr_id(i)
              ,pil.mgr_ovrid_dt  = l_t_mgr_ovrid_dt(i)
              ,pil.mgr_ovrid_person_id = l_t_mgr_ovrid_person_id(i)
        where pil.per_in_ler_id = l_t_per_in_ler_id(i);


    end if;

    commit_and_log('Person Info Upgrade Cycle Complete');

    if c_pil%notfound then
      close c_pil;
      exit;
    end if;

  end loop;

  commit_and_log('Person Info Upgrade Complete');

end upgrade_person_info;

procedure upgrade_person_tasks is
begin

    insert into ben_cwb_person_tasks
       (group_per_in_ler_id
       ,task_id
       ,group_pl_id
       ,lf_evt_ocrd_dt
       ,status_cd
       ,object_version_number)
    select pil.per_in_ler_id
          ,tk.cwb_wksht_grp_id
          ,tk.pl_id
          ,pil.lf_evt_ocrd_dt
          ,decode(tk.wksht_grp_cd
                  ,'BDGT', decode(popl.bdgt_stat_cd, 'IP', 'IP','IS','CO', 'NS')
                  ,'APPR', decode(popl.ws_stat_cd,'PR', 'CO', 'AP', 'CO',  'NS')
                  ,'RVW', decode(popl.ws_stat_cd, 'PR','CO','AP', 'CO', 'NS')
                  ,decode(popl.ws_stat_cd,'IP','IP','PR','CO','PA','CO','CO','CO','NS')
                 ) status_cd
          ,1
    from  ben_cwb_wksht_grp tk
         ,ben_per_in_ler pil
         ,ben_pil_elctbl_chc_popl popl
    where pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
    and   pil.group_pl_id is null
    and   pil.assignment_id is null
    and   pil.per_in_ler_id = popl.per_in_ler_id
    and   popl.enrt_typ_cycl_cd = 'COMP'
    and   popl.assignment_id is not null
    and   popl.pgm_id is null
    and   popl.pl_id = tk.pl_id
    and   tk.status_cd = 'A';

    commit_and_log('Person Tasks Upgrade Complete');

end upgrade_person_tasks;


-- the following functions are referred by refresh_person_info_group_pl
--
function get_years_in_job(p_assignment_id  in number
                         ,p_job_id         in number
                         ,p_effective_date in date
			 ,p_asg_effective_start_date in date)
return number is
--
   l_years_in_job number;
--
begin
   select trunc(sum(months_between(
               decode(asgjob.effective_end_date,
               to_date('4712/12/31', 'yyyy/mm/dd'),p_effective_date,
               asgjob.effective_end_date+1),asgjob.effective_start_date))/12,1)
	  into l_years_in_job
   from per_all_assignments_f asgjob
   where asgjob.assignment_id=p_assignment_id
   and   asgjob.job_id = p_job_id
   and   asgjob.effective_start_date <= p_asg_effective_start_date;
   --
   return l_years_in_job;
end;

function get_years_in_position(p_assignment_id  in number
                              ,p_position_id    in number
                              ,p_effective_date in date
			      ,p_asg_effective_start_date in date)
return number is
--
   l_years_in_position number;
--
begin
   select trunc(sum(months_between(
              decode(asgpos.effective_end_date,
              to_date('4712/12/31', 'yyyy/mm/dd'),p_effective_date,
              asgpos.effective_end_date+1),asgpos.effective_start_date))/12,1)
	  into l_years_in_position
   from per_all_assignments_f asgpos
   where asgpos.assignment_id=p_assignment_id
   and   asgpos.position_id = p_position_id
   and   asgpos.effective_start_date <= p_asg_effective_start_date;
   --
   return l_years_in_position;
end;

function get_years_in_grade(p_assignment_id  in number
                           ,p_grade_id    in number
                           ,p_effective_date in date
			   ,p_asg_effective_start_date in date)
return number is
--
   l_years_in_grade number;
--
begin
   select trunc(sum(months_between(
               decode(asggrd.effective_end_date,
               to_date('4712/12/31', 'yyyy/mm/dd'),p_effective_date,
               asggrd.effective_end_date+1),asggrd.effective_start_date))/12,1)
	  into l_years_in_grade
   from per_all_assignments_f asggrd
   where asggrd.assignment_id=p_assignment_id
   and   asggrd.grade_id = p_grade_id
   and   asggrd.effective_start_date <= p_asg_effective_start_date;
   --
   return l_years_in_grade;
end; -- get_years_in_grade

function get_grd_min_val(p_grade_id  in number
                        ,p_rate_id   in number
                        ,p_effective_date in date)
return number is
--
   l_grd_min_val number;
--
begin
   select fnd_number.canonical_to_number(minimum) into l_grd_min_val
   from pay_grade_rules_f grdrule
   where grdrule.rate_id  = p_rate_id
   and   grdrule.grade_or_spinal_point_id = p_grade_id
   and   p_effective_date between grdrule.effective_start_date
                  and grdrule.effective_end_date;
   --
   return l_grd_min_val;
end; -- get_grd_min_val

function get_grd_max_val(p_grade_id  in number
                        ,p_rate_id   in number
                        ,p_effective_date in date)
return number is
--
   l_grd_max_val number;
--
begin
   select fnd_number.canonical_to_number(maximum) into l_grd_max_val
   from pay_grade_rules_f grdrule
   where grdrule.rate_id  = p_rate_id
   and   grdrule.grade_or_spinal_point_id = p_grade_id
   and p_effective_date between grdrule.effective_start_date
                  and grdrule.effective_end_date;
   --
   return l_grd_max_val;
end; -- get_grd_max_val

function get_grd_mid_point(p_grade_id  in number
                          ,p_rate_id   in number
                          ,p_effective_date in date)
return number is
--
   l_grd_mid_point number;
--
begin
   select fnd_number.canonical_to_number(mid_value) into l_grd_mid_point
   from pay_grade_rules_f grdrule
   where grdrule.rate_id  = p_rate_id
   and   grdrule.grade_or_spinal_point_id = p_grade_id
   and   p_effective_date between grdrule.effective_start_date
	             and grdrule.effective_end_date;
   --
   return l_grd_mid_point;
end; -- get_grd_mid_point
--
-- The above functions are referred by refresh_person_info_group_pl


procedure refresh_person_info_group_pl(p_group_pl_id in number,
                                       p_lf_evt_ocrd_dt in date) is

 l_performance_rating_type varchar2(30);

 cursor c_person_info is
   select pers.group_per_in_ler_id group_per_in_ler_id
         ,pil.lf_evt_ocrd_dt       effective_date
         ,ppf.full_name          full_name
         ,ppf.first_name ||' '||ppf.last_name||' '||ppf.suffix  brief_name
         ,null            custom_name
	 ,paf.supervisor_id      supervisor_id
         ,supv.full_name         supervisor_full_name
         ,supv.first_name||' '||supv.last_name||' '||supv.suffix
                  supervisor_brief_name
         ,null             supervisor_custom_name
         ,bg.legislation_code    legislation_code
         ,trunc(months_between(p_lf_evt_ocrd_dt,
               nvl(service_period.adjusted_svc_date,
               nvl(service_period.date_start,
               ppf.start_date)))/12,1)    years_employed
         ,get_years_in_job(paf.assignment_id
	                  ,paf.job_id
			  ,p_lf_evt_ocrd_dt
			  ,paf.effective_start_date) years_in_job
         ,get_years_in_position(paf.assignment_id
  	                       ,paf.position_id
  			       ,p_lf_evt_ocrd_dt
			       ,paf.effective_start_date) years_in_position
         ,get_years_in_grade(paf.assignment_id
  	                    ,paf.grade_id
  			    ,p_lf_evt_ocrd_dt
			    ,paf.effective_start_date) years_in_grade
         ,ppf.employee_number    employee_number
         ,nvl(service_period.date_start,ppf.start_date) start_date
         ,ppf.original_date_of_hire  original_start_date
         ,service_period.adjusted_svc_date   adjusted_svc_date
         ,ppp.proposed_salary_n  base_salary
         ,ppp.change_date        base_salary_change_date
         ,pay.payroll_name       payroll_name
         ,perf.performance_rating    performance_rating
         ,perf.review_date       performance_rating_date
         ,paf.business_group_id  business_group_id
         ,paf.organization_id    organization_id
         ,paf.job_id             job_id
         ,paf.grade_id           grade_id
         ,paf.position_id        position_id
         ,paf.people_group_id    people_group_id
         ,paf.soft_coding_keyflex_id   soft_coding_keyflex_id
         ,paf.location_id        location_id
         ,ppb.rate_id            pay_rate_id
         ,nvl(ppb.grade_annualization_factor,1) grade_annualization_factor
         ,nvl(ppb.pay_annualization_factor,1)   pay_annualization_factor
	 ,get_grd_min_val(paf.grade_id
	                 ,ppb.rate_id
			 ,p_lf_evt_ocrd_dt) grd_min_val
	 ,get_grd_max_val(paf.grade_id
	                 ,ppb.rate_id
			 ,p_lf_evt_ocrd_dt) grd_max_val
	 ,get_grd_mid_point(paf.grade_id
	                   ,ppb.rate_id
			   ,p_lf_evt_ocrd_dt) grd_mid_point
	 ,paf.employment_category   emp_category
         ,paf.change_reason      change_reason
         ,paf.normal_hours       normal_hours
         ,ppf.email_address      email_address
         ,paf.assignment_status_type_id
         ,paf.frequency
         ,paf.ass_attribute_category   ass_attribute_category
         ,paf.ass_attribute1     ass_attribute1
         ,paf.ass_attribute2     ass_attribute2
         ,paf.ass_attribute3     ass_attribute3
         ,paf.ass_attribute4     ass_attribute4
         ,paf.ass_attribute5     ass_attribute5
         ,paf.ass_attribute6     ass_attribute6
         ,paf.ass_attribute7     ass_attribute7
         ,paf.ass_attribute8     ass_attribute8
         ,paf.ass_attribute9     ass_attribute9
         ,paf.ass_attribute10    ass_attribute10
         ,paf.ass_attribute11    ass_attribute11
         ,paf.ass_attribute12    ass_attribute12
         ,paf.ass_attribute13    ass_attribute13
         ,paf.ass_attribute14    ass_attribute14
         ,paf.ass_attribute15    ass_attribute15
         ,paf.ass_attribute16    ass_attribute16
         ,paf.ass_attribute17    ass_attribute17
         ,paf.ass_attribute18    ass_attribute18
         ,paf.ass_attribute19    ass_attribute19
         ,paf.ass_attribute20    ass_attribute20
         ,paf.ass_attribute21    ass_attribute21
         ,paf.ass_attribute22    ass_attribute22
         ,paf.ass_attribute23    ass_attribute23
         ,paf.ass_attribute24    ass_attribute24
         ,paf.ass_attribute25    ass_attribute25
         ,paf.ass_attribute26    ass_attribute26
         ,paf.ass_attribute27    ass_attribute27
         ,paf.ass_attribute28    ass_attribute28
         ,paf.ass_attribute29    ass_attribute29
         ,paf.ass_attribute30    ass_attribute30
	 ,perf.appraisal_id      appraisal_id
    from  per_all_people_f           ppf
         ,per_all_assignments_f  paf
         ,ben_per_in_ler         pil
         ,per_all_people_f       supv
         ,per_business_groups    bg
         ,per_periods_of_service service_period
         ,per_pay_proposals      ppp
         ,pay_all_payrolls_f     pay
         ,ben_cwb_person_info    pers
         ,(select rtg1.review_date review_date
                 ,rtg1.performance_rating performance_rating
                 ,rtg1.person_id person_id
		 ,apr.appraisal_id
          from per_performance_reviews rtg1
              ,per_events evt1
	      ,per_appraisals apr
          where rtg1.event_id = evt1.event_id (+)
          and   rtg1.review_date < p_lf_evt_ocrd_dt
          and   nvl(evt1.type, '-X-X-X-') = nvl(l_performance_rating_type, '-X-X-X-')
	  and   evt1.event_id = apr.event_id(+)) perf
         ,per_pay_bases          ppb
   where  pil.group_pl_id = p_group_pl_id
   and pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and  pil.per_in_ler_id = pers.group_per_in_ler_id
   and   paf.assignment_id  = pil.assignment_id
   and   p_lf_evt_ocrd_dt between paf.effective_start_date and
            paf.effective_end_date
   and   paf.person_id = ppf.person_id
   and   p_lf_evt_ocrd_dt between ppf.effective_start_date and
            ppf.effective_end_date
   and   paf.supervisor_id = supv.person_id (+)
   and   p_lf_evt_ocrd_dt between supv.effective_start_date (+) and
            supv.effective_end_date (+)
   and   bg.business_group_id = paf.business_group_id
   and   paf.period_of_service_id = service_period.period_of_service_id (+)
   and   paf.assignment_id = ppp.assignment_id (+)
   and   ppp.approved (+) = 'Y'
   and   ppp.change_date (+) <= p_lf_evt_ocrd_dt
   and   nvl(ppp.change_date,to_date('4712/12/31', 'yyyy/mm/dd')) =
            (select nvl(max(ppp1.change_date), to_date('4712/12/31',
                        'yyyy/mm/dd'))
             from per_pay_proposals ppp1
             where ppp1.assignment_id = ppp.assignment_id
             and ppp1.change_date <= p_lf_evt_ocrd_dt
             and ppp1.approved = 'Y')
   and   paf.payroll_id = pay.payroll_id (+)
   and   p_lf_evt_ocrd_dt between pay.effective_start_date (+) and
            pay.effective_end_date (+)
   and   ppf.person_id = perf.person_id (+)
   and   nvl(perf.review_date, to_date('4712/12/31', 'yyyy/mm/dd')) =
            (select nvl(max(rtg2.review_date),to_date('4712/12/31',
                     'yyyy/mm/dd'))
             from   per_performance_reviews rtg2
                   ,per_events evt2
             where  rtg2.person_id = ppf.person_id
             and    rtg2.review_date < p_lf_evt_ocrd_dt
             and    rtg2.event_id = evt2.event_id (+)
             and    nvl(evt2.type, '-X-X-X-') = nvl(l_performance_rating_type, '-X-X-X-') )
             and   paf.pay_basis_id = ppb.pay_basis_id (+);

          l_t_group_per_in_ler_id       t_id;
          l_t_effective_date            t_date;
          l_t_full_name                 t_varchar_med;
          l_t_brief_name        t_varchar_med3;
          l_t_custom_name           t_varchar_med;
	  l_t_supervisor_id          t_id;
          l_t_supervisor_full_name   t_varchar_med;
          l_t_supervisor_brief_name   t_varchar_med3;
          l_t_supervisor_custom_name   t_varchar_med;
          l_t_legislation_code         t_varchar_small;
          l_t_years_employed           t_val;
          l_t_years_in_job             t_val;
          l_t_years_in_position        t_val;
          l_t_years_in_grade           t_val;
          l_t_employee_number          t_varchar_small;
          l_t_start_date               t_date;
          l_t_original_start_date      t_date;
          l_t_adjusted_svc_date        t_date;
          l_t_base_salary              t_val;
          l_t_base_salary_change_date  t_date;
          l_t_payroll_name              t_varchar_med;
          l_t_performance_rating        t_varchar_small;
          l_t_performance_rating_date   t_date;
          l_t_business_group_id         t_id;
          l_t_organization_id           t_id;
          l_t_job_id                    t_id;
          l_t_grade_id                  t_id;
          l_t_position_id               t_id;
          l_t_people_group_id           t_id;
          l_t_soft_coding_keyflex_id    t_id;
          l_t_location_id               t_id;
          l_t_pay_rate_id               t_id;
          l_t_grade_annualization_factor t_val;
          l_t_pay_annualization_factor   t_val;
          l_t_grd_min_val               t_val;
          l_t_grd_max_val               t_val;
          l_t_grd_mid_point             t_val;
          l_t_emp_category              t_varchar_small;
          l_t_change_reason             t_varchar_small;
          l_t_normal_hours              t_val;
          l_t_email_address             t_varchar_med;
          l_t_assignment_status_type_id t_id;
          l_t_frequency                 t_varchar_small;
          l_t_ass_attribute_category    t_varchar_small;
          l_t_ass_attribute1            t_varchar_med2;
          l_t_ass_attribute2            t_varchar_med2;
          l_t_ass_attribute3            t_varchar_med2;
          l_t_ass_attribute4            t_varchar_med2;
          l_t_ass_attribute5            t_varchar_med2;
          l_t_ass_attribute6            t_varchar_med2;
          l_t_ass_attribute7            t_varchar_med2;
          l_t_ass_attribute8            t_varchar_med2;
          l_t_ass_attribute9            t_varchar_med2;
          l_t_ass_attribute10           t_varchar_med2;
          l_t_ass_attribute11           t_varchar_med2;
          l_t_ass_attribute12           t_varchar_med2;
          l_t_ass_attribute13           t_varchar_med2;
          l_t_ass_attribute14           t_varchar_med2;
          l_t_ass_attribute15           t_varchar_med2;
          l_t_ass_attribute16           t_varchar_med2;
          l_t_ass_attribute17           t_varchar_med2;
          l_t_ass_attribute18           t_varchar_med2;
          l_t_ass_attribute19           t_varchar_med2;
          l_t_ass_attribute20           t_varchar_med2;
          l_t_ass_attribute21           t_varchar_med2;
          l_t_ass_attribute22           t_varchar_med2;
          l_t_ass_attribute23           t_varchar_med2;
          l_t_ass_attribute24           t_varchar_med2;
          l_t_ass_attribute25           t_varchar_med2;
          l_t_ass_attribute26           t_varchar_med2;
          l_t_ass_attribute27           t_varchar_med2;
          l_t_ass_attribute28           t_varchar_med2;
          l_t_ass_attribute29           t_varchar_med2;
          l_t_ass_attribute30           t_varchar_med2;
	  l_t_appraisal_id                t_id;

begin


   select emp_interview_typ_cd
   into l_performance_rating_type
   from ben_cwb_pl_dsgn pldsgn
   where pldsgn.pl_id = p_group_pl_id
   and   pldsgn.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and   pldsgn.oipl_id = -1 ;

  open  c_person_info;

  loop

    fetch c_person_info bulk collect into
          l_t_group_per_in_ler_id,
          l_t_effective_date,
          l_t_full_name,
          l_t_brief_name,
          l_t_custom_name,
	  l_t_supervisor_id,
          l_t_supervisor_full_name,
          l_t_supervisor_brief_name,
          l_t_supervisor_custom_name,
          l_t_legislation_code,
          l_t_years_employed,
          l_t_years_in_job,
          l_t_years_in_position,
          l_t_years_in_grade,
          l_t_employee_number,
          l_t_start_date,
          l_t_original_start_date,
          l_t_adjusted_svc_date,
          l_t_base_salary,
          l_t_base_salary_change_date,
          l_t_payroll_name,
          l_t_performance_rating,
          l_t_performance_rating_date,
          l_t_business_group_id,
          l_t_organization_id,
          l_t_job_id,
          l_t_grade_id,
          l_t_position_id,
          l_t_people_group_id,
          l_t_soft_coding_keyflex_id,
          l_t_location_id,
          l_t_pay_rate_id,
          l_t_grade_annualization_factor,
          l_t_pay_annualization_factor,
          l_t_grd_min_val,
          l_t_grd_max_val,
          l_t_grd_mid_point,
          l_t_emp_category,
          l_t_change_reason,
          l_t_normal_hours,
          l_t_email_address,
          l_t_assignment_status_type_id,
          l_t_frequency,
          l_t_ass_attribute_category,
          l_t_ass_attribute1,
          l_t_ass_attribute2,
          l_t_ass_attribute3,
          l_t_ass_attribute4,
          l_t_ass_attribute5,
          l_t_ass_attribute6,
          l_t_ass_attribute7,
          l_t_ass_attribute8,
          l_t_ass_attribute9,
          l_t_ass_attribute10,
          l_t_ass_attribute11,
          l_t_ass_attribute12,
          l_t_ass_attribute13,
          l_t_ass_attribute14,
          l_t_ass_attribute15,
          l_t_ass_attribute16,
          l_t_ass_attribute17,
          l_t_ass_attribute18,
          l_t_ass_attribute19,
          l_t_ass_attribute20,
          l_t_ass_attribute21,
          l_t_ass_attribute22,
          l_t_ass_attribute23,
          l_t_ass_attribute24,
          l_t_ass_attribute25,
          l_t_ass_attribute26,
          l_t_ass_attribute27,
          l_t_ass_attribute28,
          l_t_ass_attribute29,
          l_t_ass_attribute30,
	  l_t_appraisal_id
    limit g_commit_size;

    if l_t_group_per_in_ler_id.count > 0 then
      forall i in l_t_group_per_in_ler_id.first .. l_t_group_per_in_ler_id.last
      update ben_cwb_person_info
      set  effective_date            = l_t_effective_date(i)
          ,full_name                 = l_t_full_name(i)
          ,brief_name                = l_t_brief_name(i)
          ,custom_name               = l_t_custom_name(i)
	  ,supervisor_id             = l_t_supervisor_id(i)
          ,supervisor_full_name      = l_t_supervisor_full_name(i)
          ,supervisor_brief_name     = l_t_supervisor_brief_name(i)
          ,supervisor_custom_name    = l_t_supervisor_custom_name(i)
          ,legislation_code          = l_t_legislation_code(i)
          ,years_employed            = l_t_years_employed(i)
          ,years_in_job              = l_t_years_in_job(i)
          ,years_in_position         = l_t_years_in_position(i)
          ,years_in_grade            = l_t_years_in_grade(i)
          ,employee_number           = l_t_employee_number(i)
          ,start_date                = l_t_start_date(i)
          ,original_start_date       = l_t_original_start_date(i)
          ,adjusted_svc_date         = l_t_adjusted_svc_date(i)
          ,base_salary               = l_t_base_salary(i)
          ,base_salary_change_date   = l_t_base_salary_change_date(i)
          ,payroll_name              = l_t_payroll_name(i)
          ,performance_rating        = l_t_performance_rating(i)
          ,performance_rating_type   = l_performance_rating_type
          ,performance_rating_date   = l_t_performance_rating_date(i)
          ,business_group_id         = l_t_business_group_id(i)
          ,organization_id           = l_t_organization_id(i)
          ,job_id                    = l_t_job_id(i)
          ,grade_id                  = l_t_grade_id(i)
          ,position_id               = l_t_position_id(i)
          ,people_group_id           = l_t_people_group_id(i)
          ,soft_coding_keyflex_id    = l_t_soft_coding_keyflex_id(i)
          ,location_id               = l_t_location_id(i)
          ,pay_rate_id               = l_t_pay_rate_id(i)
          ,grade_annulization_factor= l_t_grade_annualization_factor(i)
          ,pay_annulization_factor  = l_t_pay_annualization_factor(i)
          ,grd_min_val               = l_t_grd_min_val(i)
          ,grd_max_val               = l_t_grd_max_val(i)
          ,grd_mid_point             = l_t_grd_mid_point(i)
          ,emp_category              = l_t_emp_category(i)
          ,change_reason             = l_t_change_reason(i)
          ,normal_hours              = l_t_normal_hours(i)
          ,email_address             = l_t_email_address(i)
          ,assignment_status_type_id = l_t_assignment_status_type_id(i)
          ,frequency                 = l_t_frequency(i)
          ,ass_attribute_category    = l_t_ass_attribute_category(i)
          ,ass_attribute1            = l_t_ass_attribute1(i)
          ,ass_attribute2            = l_t_ass_attribute2(i)
          ,ass_attribute3            = l_t_ass_attribute3(i)
          ,ass_attribute4            = l_t_ass_attribute4(i)
          ,ass_attribute5            = l_t_ass_attribute5(i)
          ,ass_attribute6            = l_t_ass_attribute6(i)
          ,ass_attribute7            = l_t_ass_attribute7(i)
          ,ass_attribute8            = l_t_ass_attribute8(i)
          ,ass_attribute9            = l_t_ass_attribute9(i)
          ,ass_attribute10           = l_t_ass_attribute10(i)
          ,ass_attribute11           = l_t_ass_attribute11(i)
          ,ass_attribute12           = l_t_ass_attribute12(i)
          ,ass_attribute13           = l_t_ass_attribute13(i)
          ,ass_attribute14           = l_t_ass_attribute14(i)
          ,ass_attribute15           = l_t_ass_attribute15(i)
          ,ass_attribute16           = l_t_ass_attribute16(i)
          ,ass_attribute17           = l_t_ass_attribute17(i)
          ,ass_attribute18           = l_t_ass_attribute18(i)
          ,ass_attribute19           = l_t_ass_attribute19(i)
          ,ass_attribute20           = l_t_ass_attribute20(i)
          ,ass_attribute21           = l_t_ass_attribute21(i)
          ,ass_attribute22           = l_t_ass_attribute22(i)
          ,ass_attribute23           = l_t_ass_attribute23(i)
          ,ass_attribute24           = l_t_ass_attribute24(i)
          ,ass_attribute25           = l_t_ass_attribute25(i)
          ,ass_attribute26           = l_t_ass_attribute26(i)
          ,ass_attribute27           = l_t_ass_attribute27(i)
          ,ass_attribute28           = l_t_ass_attribute28(i)
          ,ass_attribute29           = l_t_ass_attribute29(i)
          ,ass_attribute30           = l_t_ass_attribute30(i)
	  ,appraisal_id              = l_t_appraisal_id(i)
      where  group_per_in_ler_id = l_t_group_per_in_ler_id(i);

    end if;

    commit_and_log('Refresh Person Info Cycle Complete');

    if (c_person_info%notfound) then
      close c_person_info;
      exit;
    end if;

  end loop;

  commit_and_log('Refresh Person Info Complete');


end refresh_person_info_group_pl;


procedure upgrade_summary is

  cursor c_plans is
     select distinct pl.group_pl_id
            ,pl.lf_evt_ocrd_dt
     from  ben_cwb_pl_dsgn pl
     where pl.pl_id = pl.group_pl_id
     and   not exists (select 'Y'
                       from  ben_cwb_summary summ
                       where summ.group_pl_id = pl.group_pl_id
                       and   summ.lf_evt_ocrd_dt = pl.lf_evt_ocrd_dt);


begin
 commit_and_log('Gather stats started');
 fnd_stats.gather_table_stats(ownname => 'BEN',tabname => 'BEN_CWB_GROUP_HRCHY');
 fnd_stats.gather_table_stats(ownname => 'BEN',tabname => 'BEN_CWB_PERSON_GROUPS');
 fnd_stats.gather_table_stats(ownname => 'BEN',tabname => 'BEN_CWB_PERSON_RATES');
 fnd_stats.gather_table_stats(ownname => 'BEN',tabname => 'BEN_CWB_PERSON_INFO');
 fnd_stats.gather_table_stats(ownname => 'BEN',tabname => 'BEN_PER_IN_LER');
 commit_and_log('Gather stats complete');


  for l_plans in c_plans loop

     refresh_person_info_group_pl
       (p_group_pl_id   => l_plans.group_pl_id
       ,p_lf_evt_ocrd_dt=> l_plans.lf_evt_ocrd_dt);

     commit_and_log('Refresh Person Info Done for '  ||
                    to_char(l_plans.group_pl_id) || ' Date ' ||
                    to_char(l_plans.lf_evt_ocrd_dt, 'yyyy/mm/dd'));

     ben_cwb_summary_pkg.refresh_summary_group_pl
       (p_group_pl_id    => l_plans.group_pl_id
       ,p_lf_evt_ocrd_dt => l_plans.lf_evt_ocrd_dt);

     commit_and_log('Refresh Summary Done for '  ||
                    to_char(l_plans.group_pl_id) || ' Date ' ||
                    to_char(l_plans.lf_evt_ocrd_dt, 'yyyy/mm/dd'));

  end loop;

end upgrade_summary;


procedure upgrade_transaction_data is

  cursor c_pil is
   select 'Y'
   from   ben_per_in_ler pil
         ,ben_ler_f ler
   where  pil.per_in_ler_stat_cd in ('STRTD', 'PROCD')
   and    pil.ler_id = ler.ler_id
   and    ler.typ_cd = 'COMP'
   and    pil.assignment_id is null
   and    pil.group_pl_id is null;

  l_exists char(1) := 'N';

begin


  open c_pil;
  fetch c_pil into l_exists;
  close c_pil;

  if l_exists = 'N' then
    return;
  end if;


  upgrade_hrchy();
  upgrade_person_groups();
  upgrade_person_rates();
  upgrade_person_tasks();
  upgrade_person_info();

end upgrade_transaction_data;

procedure upgrade_temp_data is

  cursor c_rank is
     select ext.assignment_extra_info_id
           ,pen.per_in_ler_id
      from per_assignment_extra_info ext
          ,per_all_assignments_f  asg
          ,ben_prtt_enrt_rslt_f  pen
      where ext.information_type = 'CWBRANK'
      and   ext.aei_information_category = 'CWBRANK'
      and   ext.aei_information3 is not null
      and   ext.aei_information5 is not null
      and   ext.aei_information6 is not null
      and   ext.assignment_id = asg.assignment_id
      and   fnd_date.canonical_to_date(ext.aei_information5) between
            asg.effective_start_date and asg.effective_end_date
      and   asg.person_id = pen.person_id
      and   to_number(ext.aei_information3) = pen.prtt_enrt_rslt_id
      and   to_number(ext.aei_information6) = pen.pl_id
      and   fnd_date.canonical_to_date(ext.aei_information5) between
            pen.effective_start_date and pen.effective_end_date
      and   pen.per_in_ler_id is not null;

  cursor c_epe_rsgn_appr is
     select pil.per_in_ler_id
           ,tx.transaction_id
     from  ben_transaction tx
          ,ben_elig_per_elctbl_chc epe
          ,ben_per_in_ler          pil
     where tx.transaction_type = 'CWBEMPRSGN'
     and   tx.attribute1       = 'APPR'
     and   epe.elig_per_elctbl_chc_id = to_number(tx.attribute10)
     and   epe.per_in_ler_id          = pil.per_in_ler_id
     and   pil.person_id              = to_number(tx.attribute13);

  cursor c_pel_rsgn_appr is
     select pil.per_in_ler_id
           ,tx.transaction_id
     from  ben_transaction tx
          ,ben_pil_elctbl_chc_popl pel
          ,ben_per_in_ler          pil
     where tx.transaction_type = 'CWBEMPRSGN'
     and   tx.attribute1       = 'APPR'
     and   pel.pil_elctbl_chc_popl_id = to_number(tx.attribute10)
     and   pel.per_in_ler_id          = pil.per_in_ler_id
     and   pil.person_id              = to_number(tx.attribute13);

  cursor c_epe_rsgn_emp is
     select emp_pil.per_in_ler_id
           ,curr_mgr_pil.per_in_ler_id
           ,prop_mgr_pil.per_in_ler_id
           ,emp.pl_id
           ,tx.transaction_id
     from  ben_transaction tx
          ,ben_elig_per_elctbl_chc emp
          ,ben_per_in_ler          emp_pil
          ,ben_elig_per_elctbl_chc curr_mgr
          ,ben_per_in_ler          curr_mgr_pil
          ,ben_elig_per_elctbl_chc prop_mgr
          ,ben_per_in_ler          prop_mgr_pil
     where tx.transaction_type             = 'CWBEMPRSGN'
     and   tx.attribute1                   = 'EMP'
     and   tx.attribute21 is null
     and   emp.elig_per_elctbl_chc_id      = to_number(tx.attribute3)
     and   emp.per_in_ler_id               = emp_pil.per_in_ler_id
     and   curr_mgr.elig_per_elctbl_chc_id = to_number(tx.attribute16)
     and   curr_mgr.per_in_ler_id          = curr_mgr_pil.per_in_ler_id
     and   prop_mgr.elig_per_elctbl_chc_id = to_number(tx.attribute14)
     and   prop_mgr.per_in_ler_id          = prop_mgr_pil.per_in_ler_id
     and   emp.pl_id                       = curr_mgr.pl_id
     and   emp.pl_id                       = prop_mgr.pl_id
     and   emp_pil.ler_id                  = curr_mgr_pil.ler_id
     and   emp_pil.ler_id                  = prop_mgr_pil.ler_id;

  cursor c_pel_rsgn_emp is
     select emp_pil.per_in_ler_id
           ,curr_mgr_pil.per_in_ler_id
           ,prop_mgr_pil.per_in_ler_id
           ,emp.pl_id
           ,tx.transaction_id
     from  ben_transaction tx
          ,ben_pil_elctbl_chc_popl emp
          ,ben_per_in_ler          emp_pil
          ,ben_pil_elctbl_chc_popl curr_mgr
          ,ben_per_in_ler          curr_mgr_pil
          ,ben_pil_elctbl_chc_popl prop_mgr
          ,ben_per_in_ler          prop_mgr_pil
     where tx.transaction_type             = 'CWBEMPRSGN'
     and   tx.attribute1                   = 'EMP'
     and   tx.attribute21 is null
     and   emp.pil_elctbl_chc_popl_id      = to_number(tx.attribute3)
     and   emp.per_in_ler_id               = emp_pil.per_in_ler_id
     and   curr_mgr.pil_elctbl_chc_popl_id = to_number(tx.attribute16)
     and   curr_mgr.per_in_ler_id          = curr_mgr_pil.per_in_ler_id
     and   prop_mgr.pil_elctbl_chc_popl_id = to_number(tx.attribute14)
     and   prop_mgr.per_in_ler_id          = prop_mgr_pil.per_in_ler_id
     and   emp.pl_id                       = curr_mgr.pl_id
     and   emp.pl_id                       = prop_mgr.pl_id
     and   emp_pil.ler_id                  = curr_mgr_pil.ler_id
     and   emp_pil.ler_id                  = prop_mgr_pil.ler_id;

  l_t_info_id       t_id;
  l_t_per_in_ler_id t_id;

  l_t_emp_pil_id      t_id;
  l_t_curr_mgr_pil_id t_id;
  l_t_prop_mgr_pil_id t_id;
  l_t_grp_pl_id       t_id;
  l_t_txn_id          t_id;

begin

  -- Rank Updates

  update per_assignment_extra_info ext
  set    ext.aei_information1 = rtrim(ltrim(ext.aei_information1))
  where  ext.information_type = 'CWBRANK'
  and    ext.aei_information_category = 'CWBRANK'
  and    ext.aei_information1 is not null;

  commit_and_log('Removing Extra Spaces from Rank Complete');

  update per_assignment_extra_info ext
  set    ext.aei_information1 = null
  where  ext.information_type = 'CWBRANK'
  and    ext.aei_information_category = 'CWBRANK'
  and    ext.aei_information1 is not null
  and    replace(translate(ext.aei_information1, '0123456789','          ')
                 ,' ') is not null;

  commit_and_log('Invalid Ranks Check Complete');
  --

  open c_rank;
  loop
    fetch c_rank bulk collect into
          l_t_info_id
         ,l_t_per_in_ler_id
    limit g_commit_size;

    if l_t_info_id.count > 0 then

      forall i in l_t_info_id.first .. l_t_info_id.last
        update per_assignment_extra_info ext
        set    ext.aei_information3 = l_t_per_in_ler_id(i)
        where ext.assignment_extra_info_id = l_t_info_id(i);

    end if;

    commit_and_log('Rank Upgrade Cycle Complete');

    if c_rank%notfound then
      close c_rank;
      exit;
    end if;

  end loop;

  commit_and_log('Rank Upgrade Complete');

  insert into ben_transaction
       (transaction_id
       ,transaction_type
       ,status
       ,attribute1
       ,attribute2
       ,attribute3)
 select popl.assignment_id
       ,'CWBPERF'||tx.attribute1||enp.emp_interview_type_cd
       ,tx.status
       ,tx.attribute1
       ,enp.emp_interview_type_cd
       ,tx.attribute3
    from  ben_transaction tx
         ,ben_pil_elctbl_chc_popl popl
         ,ben_enrt_perd enp
    where tx.transaction_type = 'CWBWSASG'
    and   tx.attribute1 is not null
    and   tx.attribute3 is not null
    and   tx.transaction_id = popl.pil_elctbl_chc_popl_id
    and   popl.enrt_perd_id = enp.enrt_perd_id;


  insert into ben_transaction
       (transaction_id
       ,transaction_type
       ,status
       ,attribute1
       ,attribute3
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
       ,attribute16
       ,attribute17
       ,attribute18
       ,attribute19
       ,attribute20
       ,attribute21
       ,attribute22
       ,attribute23
       ,attribute24
       ,attribute25
       ,attribute26
       ,attribute27
       ,attribute28
       ,attribute29
       ,attribute30
       ,attribute31
       ,attribute32
       ,attribute33
       ,attribute34
       ,attribute35
       ,attribute36
       ,attribute37
       ,attribute38
       ,attribute39
       ,attribute40 )
    select popl.assignment_id
          ,'CWBASG'||tx.attribute2
          ,tx.status
          ,tx.attribute2
          ,tx.attribute4
          ,tx.attribute5
          ,tx.attribute6
          ,tx.attribute7
          ,tx.attribute8
          ,tx.attribute9
          ,tx.attribute10
          ,tx.attribute11
          ,tx.attribute12
          ,tx.attribute13
          ,tx.attribute14
          ,tx.attribute15
          ,tx.attribute16
          ,tx.attribute17
          ,tx.attribute18
          ,tx.attribute19
          ,tx.attribute20
          ,tx.attribute21
          ,tx.attribute22
          ,tx.attribute23
          ,tx.attribute24
          ,tx.attribute25
          ,tx.attribute26
          ,tx.attribute27
          ,tx.attribute28
          ,tx.attribute29
          ,tx.attribute30
          ,tx.attribute31
          ,tx.attribute32
          ,tx.attribute33
          ,tx.attribute34
          ,tx.attribute35
          ,tx.attribute36
          ,tx.attribute37
          ,tx.attribute38
          ,tx.attribute39
          ,tx.attribute40
    from  ben_transaction tx
         ,ben_pil_elctbl_chc_popl popl
    where tx.transaction_type = 'CWBWSASG'
    and   tx.attribute2 is not null
    and   tx.transaction_id = popl.pil_elctbl_chc_popl_id;

  delete ben_transaction
  where  transaction_type = 'CWBWSASG';

  commit_and_log('Pending WS Transaction Upgrade Complete');

  open c_epe_rsgn_appr;
  loop
    fetch c_epe_rsgn_appr bulk collect into
          l_t_emp_pil_id
         ,l_t_txn_id
    limit g_commit_size;

    if l_t_txn_id.count > 0 then

      forall i in l_t_txn_id.first .. l_t_txn_id.last
        update ben_transaction tx
        set    tx.attribute10      = to_char(l_t_emp_pil_id(i))
        where  tx.transaction_id   = l_t_txn_id(i)
        and    tx.transaction_type = 'CWBEMPRSGN';

    end if;

    if c_epe_rsgn_appr%notfound then
      close c_epe_rsgn_appr;
      exit;
    end if;

  end loop;

  open c_pel_rsgn_appr;
  loop
    fetch c_pel_rsgn_appr bulk collect into
          l_t_emp_pil_id
         ,l_t_txn_id
    limit g_commit_size;

    if l_t_txn_id.count > 0 then

      forall i in l_t_txn_id.first .. l_t_txn_id.last
        update ben_transaction tx
        set    tx.attribute10      = to_char(l_t_emp_pil_id(i))
        where  tx.transaction_id   = l_t_txn_id(i)
        and    tx.transaction_type = 'CWBEMPRSGN';

    end if;

    if c_pel_rsgn_appr%notfound then
      close c_pel_rsgn_appr;
      exit;
    end if;

  end loop;

  open c_epe_rsgn_emp;
  loop
    fetch c_epe_rsgn_emp bulk collect into
          l_t_emp_pil_id
         ,l_t_curr_mgr_pil_id
         ,l_t_prop_mgr_pil_id
         ,l_t_grp_pl_id
         ,l_t_txn_id
    limit g_commit_size;

    if l_t_txn_id.count > 0 then

      forall i in l_t_txn_id.first .. l_t_txn_id.last
        update ben_transaction tx
        set    tx.attribute3      = to_char(l_t_emp_pil_id(i))
              ,tx.attribute14     = to_char(l_t_prop_mgr_pil_id(i))
              ,tx.attribute16     = to_char(l_t_curr_mgr_pil_id(i))
              ,tx.attribute21     = to_char(l_t_grp_pl_id(i))
        where  tx.transaction_id   = l_t_txn_id(i)
        and    tx.transaction_type = 'CWBEMPRSGN';

    end if;

    if c_epe_rsgn_emp%notfound then
      close c_epe_rsgn_emp;
      exit;
    end if;

  end loop;

  open c_pel_rsgn_emp;
  loop
    fetch c_pel_rsgn_emp bulk collect into
          l_t_emp_pil_id
         ,l_t_curr_mgr_pil_id
         ,l_t_prop_mgr_pil_id
         ,l_t_grp_pl_id
         ,l_t_txn_id
    limit g_commit_size;

    if l_t_txn_id.count > 0 then

      forall i in l_t_txn_id.first .. l_t_txn_id.last
        update ben_transaction tx
        set    tx.attribute3      = to_char(l_t_emp_pil_id(i))
              ,tx.attribute14     = to_char(l_t_prop_mgr_pil_id(i))
              ,tx.attribute16     = to_char(l_t_curr_mgr_pil_id(i))
              ,tx.attribute21     = to_char(l_t_grp_pl_id(i))
        where  tx.transaction_id   = l_t_txn_id(i)
        and    tx.transaction_type = 'CWBEMPRSGN';

    end if;

    if c_pel_rsgn_emp%notfound then
      close c_pel_rsgn_emp;
      exit;
    end if;

  end loop;

  commit_and_log('Reassignment Transaction Upgrade Complete');

exception
  when others then
    null;

end upgrade_temp_data;

procedure is_cwb_used(p_result out nocopy varchar2) is

   cursor c_cwb_setup is
    select 'TRUE'
    from   ben_ler_f
    where  typ_cd = 'COMP';

begin
  p_result := 'FALSE';

  open  c_cwb_setup;
  fetch c_cwb_setup into p_result;
  close c_cwb_setup;

end is_cwb_used;


procedure main(errbuf  out  nocopy  varchar2
              ,retcode out  nocopy  number) is

  l_cwb_used varchar2(30) := 'FALSE';

begin
  if hr_update_utility.isUpdateComplete
                   (p_app_shortname     => 'BEN'
                   ,p_function_name     => null
                   ,p_business_group_id => null
                   ,p_update_name       => 'BENCWBMU') = 'TRUE' then
    return;
  end if;

  hr_update_utility.setUpdateProcessing(p_update_name => 'BENCWBMU');

  is_cwb_used(p_result => l_cwb_used);

  if l_cwb_used = 'TRUE' then

    commit_and_log('CWB Upgrade Started');

    upgrade_plan_design();
    upgrade_transaction_data();
    upgrade_summary();
    upgrade_temp_data();

    commit_and_log('CWB Upgrade Complete');

  end if;

 hr_update_utility.setUpdateComplete(p_update_name => 'BENCWBMU');


end main;

end ben_cwb_data_model_upgrade;

/
