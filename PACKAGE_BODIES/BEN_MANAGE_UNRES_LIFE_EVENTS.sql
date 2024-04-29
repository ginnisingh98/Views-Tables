--------------------------------------------------------
--  DDL for Package Body BEN_MANAGE_UNRES_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_MANAGE_UNRES_LIFE_EVENTS" as
/* $Header: bebmures.pkb 120.9.12010000.2 2009/12/05 17:40:48 krupani ship $ */
--
/*
+========================================================================+
|             Copyright (c) 2002 Oracle Corporation                      |
|                Redwood Shores, California, USA                         |
|                      All rights reserved.                              |
+========================================================================+
*/
/*
        Date             Who        Version    What?
        ----             ---        -------    -----
        08 Feb 02        mhoyes    115.0      Created.
        04 Apr 02        kmahendr  115.1      Bug#2090319 - added a cursor in update_in_pend_flag
                                              to update in_pending_flag to N before update to Y
        08 Apr 02        kmahendr  115.2      Bug#2187697 - update in_pndg_wkflow_flag to
                                              S so that rates are not calculated again if
                                              there is any comp. object in pending or suspend
                                              status.
        16 Dec 02        hnarayan  115.3      Added NOCOPY hint
        02-Jul-03        maagrawa  115.4      Modified c_pending cursor for performance.
                                              Bug 3026837.
        23-Sep-03        pbodla
                         kmahendr  115.5      3152322 : Modified
                                              c_elig_per_elctbl_chc_3 to avoid
                                              selecting pending in wf rows.
        29        hnarayan  115.3      Added NOCOPY hint
        30 Sep 03        mmudigon  115.6      bug 3170345 - Performance changes. Bulk
                                              binding in procedure
                                              delete_elctbl_choice.
        09 Oct 03  kmahendr  115.7            Added cursor c_pl_nip to bypass
                                              update_pending flag for performance
                                              Added table count before deletes.
        14 Oct 03  kmahendr  115.8            Removed c_enrt_rt cursor as the
                                              data is not used at all.
        30 Oct 03  mmudigon  115.9            Close c_elig_per_elctbl_chc_3
        25 May 04  bmanyam   115.10           Bug 3638279: Added OVN to column list in the
                                              cursor c_sspndd_enrts
        27 Jul 04  nhunur    115.11           delete elig_dpnt for unrestricted as epe is deleted.
        15 Nov 04  kmahendr  115.12           Unrest. enh changes
        01-dec-04  kmahendr  115.13           Unrest. enh changes
        09-dec-04  kmahendr  115.14           Bug#4056365 - enrt_rslt_id on epe updated
        23-Sep-05  maagrawa  115.15           Bug 4483353. Remove hardcoding of
                                              item type for ICD transactions.
        06-Oct-05  rbingi    115.16           Bug#4640014. added proc clear_epe_cache to
                                                delete EPEs that marked delete
        05-dec-05  ssarkar   115.17           4761065 :Modified proc clear_epe_cache - Need to delete epe regardless
	                                                 whether its elctbl_flag is Y/N
        18-Jan-05  rbingi    115.18           4717052 : Not updating epe when already marked delete 'Y'
                                               returning from the proc.
        04-APR-06  ssarkar   115.19           Bug 5055119 - added end_date_elig_per_rows
	      10-apr-06  ssarkar   115.20           5055119 - redesigned the code of end_date_elig_per_rows
				29-Nov-06  gsehgal   115.21           Bug 5658405 - modified procedure end_date_elig_per_rows
        05-Dec-09  krupani   115.24           Bug 9181975 - elig_flag is not updated in ben_elig_per_elctbl_chc
                                              while running unrestricted. Fixed the same.
*/

--------------------------------------------------------------------------------
--
g_package             varchar2(80) := 'ben_manage_unres_life_events';
--
procedure update_in_pend_flag
  (p_person_id         in     number
  ,p_per_in_ler_id     in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_pending    number;
  l_package    varchar2(100) := 'update_in_pend_flag';
  --
  cursor c_pending is
     SELECT vlv_choice.number_value elig_per_elctbl_chc_id
     from wf_item_activity_statuses process ,
          wf_process_activities activity ,
          hr_api_transactions txn,
          hr_api_transaction_steps step ,
          hr_api_transaction_values vlv_choice
     WHERE activity.process_name = 'ROOT'
     and activity.process_item_type = activity.activity_item_type
     and activity.instance_id = process.process_activity
     and process.activity_status = 'ACTIVE'
     and txn.item_type = process.item_type
     and txn.item_key  = process.item_key
     and txn.selected_person_id = p_person_id
     and txn.transaction_id = step.transaction_id
     and step.api_name = 'BEN_PROCESS_COMPENSATION_W.PROCESS_API'
     and step.transaction_step_id = vlv_choice.transaction_step_id
     and vlv_choice.name = 'P_ELIG_PER_ELCTBL_CHC_ID';
  --
  /*
    -- Bug : 1894718
       Also treat the electable choices associated with suspended
       enrollments as in pending work flow. In other words do not
       delete the electable choises data and other data if the
       enrollment is in suspended state.
       Temporarily mark the in_pndg_wkflow_flag of electable choices
       with 'Z' value and set the flag back to 'N' after deleting
       the electable choice data and other data.
       Conditions which may cause problems. :
       1. Make enrollments on 10-oct-01 and come back and run
          unrestricted on 10-may-01. How to deal with future
          suspended rows.
       2.
    --
   */
   cursor c_sspndd_enrts is
   select epe.elig_per_elctbl_chc_id, epe.object_version_number -- 3638279: Added ovn;
   from ben_elig_per_elctbl_chc epe,
        ben_prtt_enrt_rslt_f pen
   where pen.person_id = p_person_id
     and pen.per_in_ler_id = p_per_in_ler_id
     and epe.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
     and pen.business_group_id = p_business_group_id
     and pen.business_group_id = epe.business_group_id
     and pen.sspndd_flag = 'Y'
     and nvl(epe.in_pndg_wkflow_flag,'N') = 'N'
     and pen.prtt_enrt_rslt_stat_cd IS NULL
     and pen.effective_end_date = hr_api.g_eot
     and pen.enrt_cvg_thru_dt   = hr_api.g_eot;
   /* need to worry about the following conditions
     and    p_effective_date
           between enrt_cvg_strt_dt
           and     enrt_cvg_thru_dt
    and    enrt_cvg_thru_dt <= effective_end_date
    and    p_effective_date between effective_start_date and effective_end_date
   */
  --
  cursor c_elig_per_elctbl_chc is
    select object_version_number
    from  ben_elig_per_elctbl_chc
    where elig_per_elctbl_chc_id = l_pending;
  --
  cursor c_elig_per_elctbl_chc_2 is
    select elig_per_elctbl_chc_id,
           object_version_number
    from  ben_elig_per_elctbl_chc
    where per_in_ler_id  = p_per_in_ler_id
    and   in_pndg_wkflow_flag = 'Y';
  --
  cursor c_elig_per_elctbl_chc_3 is
    select elig_per_elctbl_chc_id,
           object_version_number
    from  ben_elig_per_elctbl_chc
    where per_in_ler_id  = p_per_in_ler_id
    and   in_pndg_wkflow_flag <> 'Y'
    and   pil_elctbl_chc_popl_id in
           (select pil_elctbl_chc_popl_id
            from ben_pil_elctbl_chc_popl pel
            where pel.per_in_ler_id = p_per_in_ler_id and
            exists
                 ( select null
                   from ben_elig_per_elctbl_chc epe
                   where pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
                   and   nvl(epe.in_pndg_wkflow_flag,'N') in ('Y', 'S') ));
  --
  l_object_version_number number;
  l_elig_per_elctbl_chc_id number;
  --
begin
  --
   hr_utility.set_location ('Entering '||l_package,10);
  -- need to update the pending flag to 'N' as the flag is not being reset by process
  --after unpending
  open c_elig_per_elctbl_chc_2;
  loop
    fetch c_elig_per_elctbl_chc_2 into
              l_elig_per_elctbl_chc_id, l_object_version_number;
    if c_elig_per_elctbl_chc_2%notfound then
      exit;
    end if;
       ben_ELIG_PER_ELC_CHC_api.update_ELIG_PER_ELC_CHC
        (p_validate                => FALSE
        ,p_elig_per_elctbl_chc_id  => l_elig_per_elctbl_chc_id
        ,p_object_version_number   => l_object_version_number
        ,p_in_pndg_wkflow_flag     => 'N'
        ,p_effective_date          => p_effective_date
        );
  end loop;
  --
  close c_elig_per_elctbl_chc_2;
  --
  open c_pending;
  loop
    --
    fetch c_pending into l_pending;
    if c_pending%notfound then
       exit;
    end if;
    --
    if l_pending is not null then
      --
      open c_elig_per_elctbl_chc;
      fetch c_elig_per_elctbl_chc into l_object_version_number;
      --
      if c_elig_per_elctbl_chc%found then
        ben_ELIG_PER_ELC_CHC_api.update_ELIG_PER_ELC_CHC
          (p_validate                => FALSE
          ,p_elig_per_elctbl_chc_id  => l_pending
          ,p_object_version_number   => l_object_version_number
          ,p_in_pndg_wkflow_flag     => 'Y'
          ,p_effective_date          => p_effective_date);
      end if;
      close c_elig_per_elctbl_chc;
    end if;
    --
  end loop;
  --
  close c_pending;
  --
  for l_epe_rec in c_sspndd_enrts loop
      --
    --
    ben_ELIG_PER_ELC_CHC_api.update_ELIG_PER_ELC_CHC
        (p_validate                => FALSE
        ,p_elig_per_elctbl_chc_id  => l_epe_rec.elig_per_elctbl_chc_id
        ,p_object_version_number   => l_epe_rec.object_version_number
        ,p_in_pndg_wkflow_flag     => 'S'
        ,p_effective_date          => p_effective_date
        );
    --
    /*
      hr_utility.set_location ('sspndd epe =  '||l_epe_rec.elig_per_elctbl_chc_id,20);
      update ben_elig_per_elctbl_chc
      set in_pndg_wkflow_flag = 'S'
      where elig_per_elctbl_chc_id = l_epe_rec.elig_per_elctbl_chc_id;
     */
      --
  end loop;
  --
  --Bug#2187697 - update all the comp. objects in a program/not in program if any of one
  --comp. object is in pending work-flow or suspended status as choices are not deleted
  open c_elig_per_elctbl_chc_3;
  loop
    fetch c_elig_per_elctbl_chc_3 into
           l_elig_per_elctbl_chc_id, l_object_version_number;
    if c_elig_per_elctbl_chc_3%notfound then
      exit;
    end if;
    --
     ben_elig_per_elc_chc_api.update_perf_ELIG_PER_ELC_CHC
      (p_elig_per_elctbl_chc_id    => l_elig_per_elctbl_chc_id
      ,p_object_version_number      => l_object_version_number
      ,p_in_pndg_wkflow_flag        => 'S'
      ,p_effective_date             => p_effective_date
    );
    --
  end loop ;
  close c_elig_per_elctbl_chc_3;

  --
  hr_utility.set_location ('Leaving '||l_package,30);

end update_in_pend_flag;
--
procedure delete_elctbl_choice
  (p_person_id         in     number
  ,p_effective_date    in     date
  ,p_business_group_id in     number
  ,p_rec                  out nocopy benutils.g_active_life_event
  )
is
  --
  l_rec                   benutils.g_active_life_event;

  type epetab is table of ben_elig_per_elctbl_chc.elig_per_elctbl_chc_id%type;
  t_epe_tbl epetab;

  l_object_version_number  number ;
  l_package                varchar2(100):= 'delete_elctbl_choice';
  l_cnt                    number;
  --
/*
  cursor c_enrt_rt is
    select *
    from ben_enrt_rt
    where elig_per_elctbl_chc_id in
       (select elig_per_elctbl_chc_id from ben_elig_per_elctbl_chc
          where per_in_ler_id = p_rec.per_in_ler_id)
  union
    select *
    from ben_enrt_rt
     where enrt_bnft_id in
       (select enrt_bnft_id from ben_enrt_bnft
          where elig_per_elctbl_chc_id in
          (select elig_per_elctbl_chc_id from ben_elig_per_elctbl_chc
             where per_in_ler_id = p_rec.per_in_ler_id));
*/
  --
  cursor c_pil_popl is
    select *
    from ben_pil_elctbl_chc_popl
    where per_in_ler_id = p_rec.per_in_ler_id;
  --
  cursor c_pl_nip is
    select null
    from ben_pil_elctbl_chc_popl
    where per_in_ler_id = p_rec.per_in_ler_id
    and   pl_id is not null;
  --
  cursor c_epe(p_per_in_ler_id number) is
  select epe.elig_per_elctbl_chc_id
    from ben_elig_per_elctbl_chc epe
   where epe.per_in_ler_id = p_per_in_ler_id
     and epe.pil_elctbl_chc_popl_id in
         (select pel.pil_elctbl_chc_popl_id
            from ben_pil_elctbl_chc_popl pel
           where pel.per_in_ler_id = p_per_in_ler_id
             and not exists
                 (select null
                    from ben_elig_per_elctbl_chc epe2
                   where pel.pil_elctbl_chc_popl_id=epe2.pil_elctbl_chc_popl_id
                     and nvl(epe2.in_pndg_wkflow_flag,'N') in ('Y', 'S')));
  --
  cursor c_epe_ch (p_elig_per_elctbl_chc_id number) is
    select FONM_CVG_STRT_DT
          ,PGM_ID
          ,PL_ID
          ,PL_TYP_ID
          ,PLIP_ID
          ,PTIP_ID
          ,ENRT_CVG_STRT_DT_CD
          ,ENRT_CVG_STRT_DT_RL
          ,PRTT_ENRT_RSLT_ID
          ,DPNT_CVG_STRT_DT_CD
          ,DPNT_CVG_STRT_DT_RL
          ,ENRT_CVG_STRT_DT
          ,DPNT_DSGN_CD
          ,LER_CHG_DPNT_CVG_CD
          ,ERLST_DEENRT_DT
          ,PROCG_END_DT
          ,CRYFWD_ELIG_DPNT_CD
          ,ELIG_FLAG
          ,ELIG_OVRID_DT
          ,ELIG_OVRID_PERSON_ID
          ,INELIG_RSN_CD
          ,MGR_OVRID_DT
          ,MGR_OVRID_PERSON_ID
          ,WS_MGR_ID
          ,ASSIGNMENT_ID
          ,ROLL_CRS_FLAG
          ,CRNTLY_ENRD_FLAG
          ,DFLT_FLAG
          ,ELCTBL_FLAG
          ,MNDTRY_FLAG
          ,ALWS_DPNT_DSGN_FLAG
          ,COMP_LVL_CD
          ,AUTO_ENRT_FLAG
          ,CTFN_RQD_FLAG
          ,PER_IN_LER_ID
          ,YR_PERD_ID
          ,OIPLIP_ID
          ,PL_ORDR_NUM
          ,PLIP_ORDR_NUM
          ,PTIP_ORDR_NUM
          ,OIPL_ORDR_NUM
          ,MUST_ENRL_ANTHR_PL_ID
          ,SPCL_RT_PL_ID
          ,SPCL_RT_OIPL_ID
          ,BNFT_PRVDR_POOL_ID
          ,CMBN_PTIP_ID
          ,CMBN_PTIP_OPT_ID
          ,CMBN_PLIP_ID
          ,OIPL_ID
          ,APPROVAL_STATUS_CD
          ,elig_per_elctbl_chc_id
          ,object_version_number
          ,null  mark_delete
      from ben_elig_per_elctbl_chc
      where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
   --
   cursor c_enb_ch (p_elig_per_elctbl_chc_id number) is
     select enrt_bnft_id
           ,ELIG_PER_ELCTBL_CHC_ID
           ,ORDR_NUM
           ,OBJECT_VERSION_NUMBER
           ,null mark_delete
  from ben_enrt_bnft
  where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
  --
  cursor c_ecr_ch (p_elig_per_elctbl_chc_id number) is
    select enrt_rt_id
           ,ELIG_PER_ELCTBL_CHC_ID
           ,ENRT_BNFT_ID
           ,OBJECT_VERSION_NUMBER
           ,ACTY_BASE_RT_ID
           ,null mark_delete
    from ben_enrt_rt
    where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
    union
    select enrt_rt_id
           ,ELIG_PER_ELCTBL_CHC_ID
           ,ENRT_BNFT_ID
           ,OBJECT_VERSION_NUMBER
           ,ACTY_BASE_RT_ID
           ,null mark_delete
    from ben_enrt_rt
    where enrt_bnft_id in  (select enrt_bnft_id
                          from ben_enrt_bnft
                          where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
                          );
  --
  cursor c_epr_ch (p_elig_per_elctbl_chc_id number) is
    select enrt_prem_id
           ,actl_prem_id
           ,ELIG_PER_ELCTBL_CHC_ID
           ,ENRT_BNFT_ID
           ,OBJECT_VERSION_NUMBER
           ,null mark_delete
    from ben_enrt_prem
    where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
  --
  cursor c_egd_ch (p_elig_per_elctbl_chc_id number) is
    select elig_dpnt_id
          ,ELIG_PER_ELCTBL_CHC_ID
          ,PER_IN_LER_ID
          ,ELIG_PER_ID
          ,ELIG_PER_OPT_ID
          ,ELIG_CVRD_DPNT_ID
          ,DPNT_INELIG_FLAG
          ,OVRDN_FLAG
          ,DPNT_PERSON_ID
          ,OBJECT_VERSION_NUMBER
          ,null mark_delete
   from ben_elig_dpnt
   where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
  --
  cursor c_ecc_ch (p_elig_per_elctbl_chc_id number) is
    select elctbl_chc_ctfn_id
           ,enrt_ctfn_typ_cd
           ,ELIG_PER_ELCTBL_CHC_ID
           ,ENRT_BNFT_ID
           ,OBJECT_VERSION_NUMBER
           ,null mark_delete
    from ben_elctbl_chc_ctfn
    where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
  --
  --
  l_dummy varchar2(10);
  l_count number := 1;
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
   g_unrest_epe_instance.delete;
   g_unrest_enb_instance.delete;
   g_unrest_ecr_instance.delete;
   g_unrest_egd_instance.delete;
   g_unrest_ecc_instance.delete;
   g_unrest_epr_instance.delete;
   --
  benutils.get_active_life_event
      (p_person_id         => p_person_id,
       p_business_group_id => p_business_group_id,
       p_effective_date    => p_effective_date,
       p_lf_event_mode     => 'U',
       p_rec               => p_rec);
  --
  --

  if p_rec.per_in_ler_id is not null then
     -- call update routine only if there are plnip/icd plans
     open c_pl_nip;
     fetch c_pl_nip into l_dummy;
     if c_pl_nip%found then
       --
       update_in_pend_flag(p_person_id             => p_person_id
                          ,p_per_in_ler_id         => p_rec.per_in_ler_id
                          ,p_business_group_id     => p_business_group_id
                          ,p_effective_date        => p_effective_date
                          );
    end if;
    close c_pl_nip;
  -- call default assignment process before deleting electable choices
  --
  -- only if effective_date is => previous lf evt occrd
/*
-- Commented as per Bug1874263 and
  After discussing with Denise it is decided to remove the default enrollment
  process from the benmngle call due to following reasons :
  1. As unrestricted is called only from the professional UI and SS interface
     user will always see the defaults on the enrollment forms.
  2. Once the defaults are seen user takes a explicit action whether to enroll
     or not, so it is not necessary to call the default enrollment process as part
     of subsequent run.
  3. Another problem is if we run the second unrestricted event after say
     6 months, we should't create the enrollments for the first unrestricted run.
     that too user explicitly not selected the default one as part of first enrollment.

     if p_effective_date >= p_rec.lf_evt_ocrd_dt then
        ben_manage_default_enrt.Process_default_enrt
                     (p_person_id             => p_person_id
                     ,p_object_version_number => l_object_version_number
                     ,p_business_group_id     => p_business_group_id
                     ,p_effective_date        => p_effective_date
                     );
     end if;
*/
     -- before deleting enrt_rt - capture the data into pl/sql table
/*
     for i in c_enrt_rt loop
       --
       ben_manage_life_events.g_enrt_rt_tbl(l_count).enrt_rt_id   := i.enrt_rt_id;
       ben_manage_life_events.g_enrt_rt_tbl(l_count).acty_base_rt_id := i.acty_base_rt_id;
       ben_manage_life_events.g_enrt_rt_tbl(l_count).prtt_rt_val_id  := i.prtt_rt_val_id;
       l_count  := l_count + 1;
       --
     end loop;
     --
*/
     l_count  := 1;
     for i in c_pil_popl loop
       --
       ben_manage_life_events.g_pil_popl_tbl(l_count).pgm_id := i.pgm_id;
       ben_manage_life_events.g_pil_popl_tbl(l_count).pl_id  := i.pl_id;
       ben_manage_life_events.g_pil_popl_tbl(l_count).elcns_made_dt := i.elcns_made_dt;
       l_count  := l_count + 1;
       --
    end loop;
    --
    open c_epe(p_rec.per_in_ler_id);
    fetch c_epe bulk collect into t_epe_tbl;
    close c_epe;
    --
    --
    hr_utility.set_location('epe count'|| t_epe_tbl.count,10);
    if t_epe_tbl.count > 0 then
     /*
      forall i in 1..t_epe_tbl.last
        delete from ben_enrt_rt
        where elig_per_elctbl_chc_id = t_epe_tbl(i);

      forall i in 1..t_epe_tbl.last
        delete from ben_enrt_rt
        where enrt_bnft_id in
        (select enrt_bnft_id
           from ben_enrt_bnft
          where elig_per_elctbl_chc_id = t_epe_tbl(i));

      forall i in 1..t_epe_tbl.last
        delete from ben_elctbl_chc_ctfn
        where elig_per_elctbl_chc_id  =  t_epe_tbl(i);

      forall i in 1..t_epe_tbl.last
        delete from ben_elctbl_chc_ctfn
        where  enrt_bnft_id in
              (select enrt_bnft_id
                 from ben_enrt_bnft
                where elig_per_elctbl_chc_id = t_epe_tbl(i));

      forall i in 1..t_epe_tbl.last
        delete from ben_enrt_bnft
        where elig_per_elctbl_chc_id  =  t_epe_tbl(i);

      forall i in 1..t_epe_tbl.last
        delete from ben_elig_dpnt
        where elig_per_elctbl_chc_id  =  t_epe_tbl(i);

      forall i in 1..t_epe_tbl.last
        delete from ben_elig_per_elctbl_chc
        where elig_per_elctbl_chc_id  =  t_epe_tbl(i);
      */
      for i in 1..t_epe_tbl.last loop
        hr_utility.set_location (' within loop'||t_epe_tbl(i),10);
        open c_epe_ch (t_epe_tbl(i));
        fetch c_epe_ch into g_unrest_epe_instance(i);
        --
        update ben_elig_per_elctbl_chc set prtt_enrt_rslt_id = null
          where elig_per_elctbl_chc_id = t_epe_tbl(i);
        --
        close c_epe_ch;
      end loop;
      --
      l_cnt := 1;
      for i in 1..t_epe_tbl.last loop
        hr_utility.set_location (' within enb',10);
        open c_enb_ch (t_epe_tbl(i));
        loop
          fetch c_enb_ch into g_unrest_enb_instance_row;
          if c_enb_ch%found then
            g_unrest_enb_instance(l_cnt) := g_unrest_enb_instance_row;
            l_cnt := l_cnt + 1;
          else
            exit;
          end if;
        end loop;
        close c_enb_ch;
      end loop;
      --
      l_cnt := 1;
      for i in 1..t_epe_tbl.last loop
        hr_utility.set_location (' within ecr',10);
        open c_ecr_ch (t_epe_tbl(i));
        loop
          fetch c_ecr_ch into g_unrest_ecr_instance_row;
          if c_ecr_ch%found then
            hr_utility.set_location ('enrt id'||g_unrest_ecr_instance_row.enrt_rt_id,11);
            g_unrest_ecr_instance(l_cnt) := g_unrest_ecr_instance_row;
            l_cnt := l_cnt + 1;
          else
            exit;
          end if;
        end loop;
        close c_ecr_ch;
      end loop;
      --
      l_cnt := 1;
      for i in 1..t_epe_tbl.last loop
        hr_utility.set_location (' within ecr',10);
        open c_epr_ch (t_epe_tbl(i));
        loop
          fetch c_epr_ch into g_unrest_epr_instance_row;
          if c_epr_ch%found then
            hr_utility.set_location ('prem id'||g_unrest_epr_instance_row.enrt_prem_id,11);
            g_unrest_epr_instance(l_cnt) := g_unrest_epr_instance_row;
            l_cnt := l_cnt + 1;
          else
            exit;
          end if;
        end loop;
        close c_epr_ch;
      end loop;
      --
      l_cnt := 1;
      for i in 1..t_epe_tbl.last loop
        hr_utility.set_location (' within ecc',10);
        open c_ecc_ch (t_epe_tbl(i));
        loop
          fetch c_ecc_ch into g_unrest_ecc_instance_row;
          if c_ecc_ch%found then
            hr_utility.set_location ('Chc ctfn id'||g_unrest_ecc_instance_row.elctbl_chc_ctfn_id,11);
            g_unrest_ecc_instance(l_cnt) := g_unrest_ecc_instance_row;
            l_cnt := l_cnt + 1;
          else
            exit;
          end if;
        end loop;
        close c_ecc_ch;
      end loop;
      --
      l_cnt := 1;
      for i in 1..t_epe_tbl.last loop
        hr_utility.set_location (' within egd ',10);
        open c_egd_ch (t_epe_tbl(i));
        loop
          fetch c_egd_ch into g_unrest_egd_instance_row;
          if c_egd_ch%found then
            g_unrest_egd_instance(l_cnt) := g_unrest_egd_instance_row;
            l_cnt := l_cnt + 1;
          else
            exit;
          end if;
        end loop;
        close c_egd_ch;

      end loop;

     end if;
     --
     delete from ben_pil_elctbl_chc_popl pel
       where per_in_ler_id = p_rec.per_in_ler_id
       and not exists
           (select null
              from ben_elig_per_elctbl_chc epe
             where pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
               and nvl(epe.in_pndg_wkflow_flag,'N') in ('Y', 'S') ) ;
     --
     -- Reset back 'Z' value of the in_pndg_wkflow_flag  to 'N'.
     -- As it was just used to suppress the deletion of electable choice
     -- data associated with the suspended enrollments.
     --
/*
     update ben_elig_per_elctbl_chc
     set in_pndg_wkflow_flag = 'N'
     where in_pndg_wkflow_flag = 'Z'
       and per_in_ler_id = p_rec.per_in_ler_id;
*/
  -- this call is moved to process_comp_objects
  -- will be called just before calling the ben_automatic_enrollments.main
  --   reset_elctbl_chc_inpng_flag(p_rec.per_in_ler_id);
     --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_package,11);
--
-- Reset p_rec to null if exception
--
exception
--
  when others then
  --
    p_rec := null;
    raise;
  --
--
End;

--
procedure update_elig_per_elctbl_choice
  (
   p_elig_per_elctbl_chc_id         in  number
  ,p_enrt_cvg_strt_dt_cd            in  varchar2
  ,p_enrt_cvg_strt_dt_rl            in  varchar2
  ,p_ctfn_rqd_flag                  in  varchar2
  ,p_pil_elctbl_chc_popl_id         in  number
  ,p_roll_crs_flag                  in  varchar2
  ,p_crntly_enrd_flag               in  varchar2
  ,p_dflt_flag                      in  varchar2
  ,p_elctbl_flag                    in  varchar2
  ,p_mndtry_flag                    in  varchar2
  ,p_in_pndg_wkflow_flag            in  varchar2
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2
  ,p_dpnt_cvg_strt_dt_rl            in  varchar2
  ,p_enrt_cvg_strt_dt               in  date
  ,p_alws_dpnt_dsgn_flag            in  varchar2
  ,p_dpnt_dsgn_cd                   in  varchar2
  ,p_ler_chg_dpnt_cvg_cd            in  varchar2
  ,p_erlst_deenrt_dt                in  date
  ,p_procg_end_dt                   in  date
  ,p_comp_lvl_cd                    in  varchar2
  ,p_pl_id                          in  number
  ,p_oipl_id                        in  number
  ,p_pgm_id                         in  number
  ,p_plip_id                        in  number
  ,p_ptip_id                        in  number
  ,p_pl_typ_id                      in  number
  ,p_oiplip_id                      in  number
  ,p_cmbn_plip_id                   in  number
  ,p_cmbn_ptip_id                   in  number
  ,p_cmbn_ptip_opt_id               in  number
  ,p_assignment_id                  in  number
  ,p_spcl_rt_pl_id                  in  number
  ,p_spcl_rt_oipl_id                in  number
  ,p_must_enrl_anthr_pl_id          in  number
  ,p_int_elig_per_elctbl_chc_id     in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_bnft_prvdr_pool_id             in  number
  ,p_per_in_ler_id                  in  number
  ,p_yr_perd_id                     in  number
  ,p_auto_enrt_flag                 in  varchar2
  ,p_business_group_id              in  number
  ,p_pl_ordr_num                    in  number
  ,p_plip_ordr_num                  in  number
  ,p_ptip_ordr_num                  in  number
  ,p_oipl_ordr_num                  in  number
  ,p_comments                       in  varchar2
  ,p_elig_flag                      in  varchar2
  ,p_elig_ovrid_dt                  in  date
  ,p_elig_ovrid_person_id           in  number
  ,p_inelig_rsn_cd                  in  varchar2
  ,p_mgr_ovrid_dt                   in  date
  ,p_mgr_ovrid_person_id            in  number
  ,p_ws_mgr_id                      in  number
  ,p_approval_status_cd             in  varchar2
  ,p_fonm_cvg_strt_dt               in  date
  ,p_cryfwd_elig_dpnt_cd            in  varchar2
  ,p_effective_date                 in  date
  ,p_pgm_typ_cd                     in  varchar2
  ,p_enrt_perd_end_dt               in  date
  ,p_enrt_perd_strt_dt              in  date
  ,p_dflt_enrt_dt                   in  varchar2
  ,p_uom                            in  varchar2
  ,p_acty_ref_perd_cd               in  varchar2
  ,p_lee_rsn_id                     in  number
  ,p_enrt_perd_id                   in  number
  ,p_cls_enrt_dt_to_use_cd          in  varchar2
  ) is
  --
  l_package varchar2(30) := '.Update_elig_per_elecatble';
  l_object_version_number    number;
  l_pil_elctbl_chc_popl_id   number;
  l_oiplip_id                number;
--
begin
 --
 hr_utility.set_location ('Entering '||l_package,10);
 --
 ben_elig_per_elc_chc_api.CreOrSel_pil_elctbl_chc_popl
    (p_per_in_ler_id          => p_per_in_ler_id
    ,p_effective_date         => p_effective_date
    ,p_business_group_id      => p_business_group_id
    ,p_pgm_id                 => p_pgm_id
    ,p_plip_id                => p_plip_id
    ,p_pl_id                  => p_pl_id
    ,p_oipl_id                => p_oipl_id
    ,p_yr_perd_id             => p_yr_perd_id
    ,p_uom                    => p_uom
    ,p_acty_ref_perd_cd       => p_acty_ref_perd_cd
    ,p_dflt_enrt_dt           => p_dflt_enrt_dt
    ,p_cls_enrt_dt_to_use_cd  => p_cls_enrt_dt_to_use_cd
    ,p_enrt_typ_cycl_cd       => 'U'
    ,p_enrt_perd_end_dt       => p_enrt_perd_end_dt
    ,p_enrt_perd_strt_dt      => p_enrt_perd_strt_dt
    ,p_procg_end_dt           => p_procg_end_dt
    ,p_lee_rsn_id             => p_lee_rsn_id
    ,p_enrt_perd_id           => p_enrt_perd_id
    ,p_ws_mgr_id              => p_ws_mgr_id
    ,p_assignment_id          => p_assignment_id
    ,p_program_application_id  => fnd_global.prog_appl_id
    ,p_program_id              => fnd_global.conc_program_id
    ,p_request_id              => fnd_global.conc_request_id
    ,p_program_update_date     => sysdate
    --
    ,p_pil_elctbl_chc_popl_id => l_pil_elctbl_chc_popl_id
    ,p_oiplip_id              => l_oiplip_id
    );
 --
 if g_unrest_epe_instance.count > 0 then
    --
    for i in g_unrest_epe_instance.first..g_unrest_epe_instance.last loop
       if g_unrest_epe_instance(i).elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id then
        if g_unrest_epe_instance(i).mark_delete = 'Y' then -- Bug 4717052, Added this IF
          return;
        else
          l_object_version_number := g_unrest_epe_instance(i).object_version_number;
          g_unrest_epe_instance(i).mark_delete := 'Y';
        end if;
       end if;
       --
   end loop;
   --
 end if;
 --
 ben_epe_cache.g_currcobjepe_row.elig_per_elctbl_chc_id := p_elig_per_elctbl_chc_id;
 ben_epe_cache.g_currcobjepe_row.pl_id                  := p_pl_id;
 ben_epe_cache.g_currcobjepe_row.plip_id                := p_plip_id;
 ben_epe_cache.g_currcobjepe_row.oipl_id                := p_oipl_id;
 --
 ben_epe_cache.g_currcobjepe_row.elctbl_flag            := p_elctbl_flag;
 ben_epe_cache.g_currcobjepe_row.per_in_ler_id          := p_per_in_ler_id;
 ben_epe_cache.g_currcobjepe_row.business_group_id      := p_business_group_id;
 --ben_epe_cache.g_currcobjepe_row.object_version_number  := l_object_version_number;
 ben_epe_cache.g_currcobjepe_row.comp_lvl_cd            := p_comp_lvl_cd;
 ben_epe_cache.g_currcobjepe_row.pgm_id                 := p_pgm_id;
 ben_epe_cache.g_currcobjepe_row.pl_typ_id              := p_pl_typ_id;
 ben_epe_cache.g_currcobjepe_row.ctfn_rqd_flag          := p_ctfn_rqd_flag;
 --
 ben_elig_per_elc_chc_api.update_perf_elig_per_elc_chc
          (p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
           p_dflt_flag               => p_dflt_flag,
           p_elctbl_flag             => p_elctbl_flag,
           p_elig_flag               => p_elig_flag,                   -- Bug 9181975
           p_object_version_number   => l_object_version_number,
           p_effective_date          => p_effective_date,
           p_program_application_id  => fnd_global.prog_appl_id,
           p_program_id              => fnd_global.conc_program_id,
           p_request_id              => fnd_global.conc_request_id,
           p_program_update_date     => sysdate
          ,p_enrt_cvg_strt_dt_cd     => p_enrt_cvg_strt_dt_cd
          ,p_enrt_cvg_strt_dt_rl     => p_enrt_cvg_strt_dt_rl
          ,p_ctfn_rqd_flag           => p_ctfn_rqd_flag
          ,p_pil_elctbl_chc_popl_id  => l_pil_elctbl_chc_popl_id
          ,p_roll_crs_flag           => p_roll_crs_flag
          ,p_crntly_enrd_flag        => p_crntly_enrd_flag
          ,p_mndtry_flag             => p_mndtry_flag
          ,p_dpnt_cvg_strt_dt_cd     => p_dpnt_cvg_strt_dt_cd
          ,p_dpnt_cvg_strt_dt_rl     => p_dpnt_cvg_strt_dt_rl
          ,p_enrt_cvg_strt_dt        => p_enrt_cvg_strt_dt
          ,p_alws_dpnt_dsgn_flag     => p_alws_dpnt_dsgn_flag
          ,p_dpnt_dsgn_cd            => p_dpnt_dsgn_cd
          ,p_ler_chg_dpnt_cvg_cd     => p_ler_chg_dpnt_cvg_cd
          ,p_erlst_deenrt_dt         => p_erlst_deenrt_dt
          ,p_procg_end_dt            => p_procg_end_dt
          ,p_comp_lvl_cd             => p_comp_lvl_cd
          ,p_pl_id                   => p_pl_id
          ,p_oipl_id                 => p_oipl_id
          ,p_pgm_id                  => p_pgm_id
          ,p_plip_id                 => p_plip_id
          ,p_ptip_id                 => p_ptip_id
          ,p_pl_typ_id               => p_pl_typ_id
          ,p_oiplip_id               => p_oiplip_id
          ,p_cmbn_plip_id            => p_cmbn_plip_id
          ,p_cmbn_ptip_id            => p_cmbn_ptip_id
          ,p_cmbn_ptip_opt_id        => p_cmbn_ptip_opt_id
          ,p_assignment_id           => p_assignment_id
          ,p_spcl_rt_pl_id           => p_spcl_rt_pl_id
          ,p_spcl_rt_oipl_id         => p_spcl_rt_oipl_id
          ,p_must_enrl_anthr_pl_id   => p_must_enrl_anthr_pl_id
          ,p_prtt_enrt_rslt_id       => p_prtt_enrt_rslt_id
          ,p_bnft_prvdr_pool_id      => p_bnft_prvdr_pool_id
          ,p_per_in_ler_id           => p_per_in_ler_id
          ,p_yr_perd_id              => p_yr_perd_id
          ,p_auto_enrt_flag          => p_auto_enrt_flag
          ,p_business_group_id       => p_business_group_id
          ,p_pl_ordr_num             => p_pl_ordr_num
          ,p_plip_ordr_num           => p_plip_ordr_num
          ,p_ptip_ordr_num           => p_ptip_ordr_num
          ,p_oipl_ordr_num           => p_oipl_ordr_num
          ,p_fonm_cvg_strt_dt        => p_fonm_cvg_strt_dt
        );


end ;
--

procedure update_enrt_bnft
 ( p_enrt_bnft_id                   in  number
  ,p_dflt_flag                      in  varchar2
  ,p_val_has_bn_prortd_flag         in  varchar2
  ,p_bndry_perd_cd                  in  varchar2
  ,p_val                            in  number
  ,p_nnmntry_uom                    in  varchar2
  ,p_bnft_typ_cd                    in  varchar2
  ,p_entr_val_at_enrt_flag          in  varchar2
  ,p_mn_val                         in  number
  ,p_mx_val                         in  number
  ,p_incrmt_val                     in  number
  ,p_dflt_val                       in  number
  ,p_rt_typ_cd                      in  varchar2
  ,p_cvg_mlt_cd                     in  varchar2
  ,p_ctfn_rqd_flag                  in  varchar2
  ,p_ordr_num                       in  number
  ,p_crntly_enrld_flag              in  varchar2
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_comp_lvl_fctr_id               in  number
  ,p_business_group_id              in  number
  ,p_enb_attribute_category         in  varchar2
  ,p_enb_attribute1                 in  varchar2
  ,p_enb_attribute2                 in  varchar2
  ,p_enb_attribute3                 in  varchar2
  ,p_enb_attribute4                 in  varchar2
  ,p_enb_attribute5                 in  varchar2
  ,p_enb_attribute6                 in  varchar2
  ,p_enb_attribute7                 in  varchar2
  ,p_enb_attribute8                 in  varchar2
  ,p_enb_attribute9                 in  varchar2
  ,p_enb_attribute10                in  varchar2
  ,p_enb_attribute11                in  varchar2
  ,p_enb_attribute12                in  varchar2
  ,p_enb_attribute13                in  varchar2
  ,p_enb_attribute14                in  varchar2
  ,p_enb_attribute15                in  varchar2
  ,p_enb_attribute16                in  varchar2
  ,p_enb_attribute17                in  varchar2
  ,p_enb_attribute18                in  varchar2
  ,p_enb_attribute19                in  varchar2
  ,p_enb_attribute20                in  varchar2
  ,p_enb_attribute21                in  varchar2
  ,p_enb_attribute22                in  varchar2
  ,p_enb_attribute23                in  varchar2
  ,p_enb_attribute24                in  varchar2
  ,p_enb_attribute25                in  varchar2
  ,p_enb_attribute26                in  varchar2
  ,p_enb_attribute27                in  varchar2
  ,p_enb_attribute28                in  varchar2
  ,p_enb_attribute29                in  varchar2
  ,p_enb_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_mx_wout_ctfn_val               in number
  ,p_mx_wo_ctfn_flag                in varchar2
  ,p_effective_date                 in  date
  ) is
  --
  l_object_version_number           number;

begin
 --
 if g_unrest_enb_instance.count > 0 then
    --
    for i in g_unrest_enb_instance.first..g_unrest_enb_instance.last loop
       if g_unrest_enb_instance(i).enrt_bnft_id = p_enrt_bnft_id then
        l_object_version_number := g_unrest_enb_instance(i).object_version_number;
        g_unrest_enb_instance(i).mark_delete := 'Y';
       end if;
       --
   end loop;
   --
 end if;
 --
 ben_enrt_bnft_api.update_enrt_bnft
      (p_enrt_bnft_id                  => p_enrt_bnft_id
      ,p_dflt_flag                     => p_dflt_flag
      ,p_val_has_bn_prortd_flag        => p_val_has_bn_prortd_flag
      ,p_bndry_perd_cd                 => p_bndry_perd_cd
      ,p_val                           => p_val
      ,p_nnmntry_uom                   => p_nnmntry_uom
      ,p_bnft_typ_cd                   => p_bnft_typ_cd
      ,p_entr_val_at_enrt_flag         => p_entr_val_at_enrt_flag
      ,p_mn_val                        => p_mn_val
      ,p_mx_val                        => p_mx_val
      ,p_incrmt_val                    => p_incrmt_val
      ,p_dflt_val                      => p_dflt_val
      ,p_rt_typ_cd                     => p_rt_typ_cd
      ,p_cvg_mlt_cd                    => p_cvg_mlt_cd
      ,p_ctfn_rqd_flag                 => p_ctfn_rqd_flag
      ,p_ordr_num                      => p_ordr_num
      ,p_crntly_enrld_flag             => p_crntly_enrld_flag
      ,p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
      ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
      ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
      ,p_business_group_id             => p_business_group_id
      ,p_enb_attribute_category        => p_enb_attribute_category
      ,p_enb_attribute1                => p_enb_attribute1
      ,p_enb_attribute2                => p_enb_attribute2
      ,p_enb_attribute3                => p_enb_attribute3
      ,p_enb_attribute4                => p_enb_attribute4
      ,p_enb_attribute5                => p_enb_attribute5
      ,p_enb_attribute6                => p_enb_attribute6
      ,p_enb_attribute7                => p_enb_attribute7
      ,p_enb_attribute8                => p_enb_attribute8
      ,p_enb_attribute9                => p_enb_attribute9
      ,p_enb_attribute10               => p_enb_attribute10
      ,p_enb_attribute11               => p_enb_attribute11
      ,p_enb_attribute12               => p_enb_attribute12
      ,p_enb_attribute13               => p_enb_attribute13
      ,p_enb_attribute14               => p_enb_attribute14
      ,p_enb_attribute15               => p_enb_attribute15
      ,p_enb_attribute16               => p_enb_attribute16
      ,p_enb_attribute17               => p_enb_attribute17
      ,p_enb_attribute18               => p_enb_attribute18
      ,p_enb_attribute19               => p_enb_attribute19
      ,p_enb_attribute20               => p_enb_attribute20
      ,p_enb_attribute21               => p_enb_attribute21
      ,p_enb_attribute22               => p_enb_attribute22
      ,p_enb_attribute23               => p_enb_attribute23
      ,p_enb_attribute24               => p_enb_attribute24
      ,p_enb_attribute25               => p_enb_attribute25
      ,p_enb_attribute26               => p_enb_attribute26
      ,p_enb_attribute27               => p_enb_attribute27
      ,p_enb_attribute28               => p_enb_attribute28
      ,p_enb_attribute29               => p_enb_attribute29
      ,p_enb_attribute30               => p_enb_attribute30
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      ,p_mx_wout_ctfn_val              => p_mx_wout_ctfn_val
      ,p_mx_wo_ctfn_flag               => p_mx_wo_ctfn_flag
      ,p_object_version_number         => l_object_version_number
      ,p_effective_date                => trunc(p_effective_date));
end;
--
procedure update_enrt_rt
( p_enrt_rt_id                  in NUMBER,
  p_ordr_num           	        in  number     ,
  p_acty_typ_cd                 in  VARCHAR2   ,
  p_tx_typ_cd                   in  VARCHAR2   ,
  p_ctfn_rqd_flag               in  VARCHAR2   ,
  p_dflt_flag                   in  VARCHAR2   ,
  p_dflt_pndg_ctfn_flag         in  VARCHAR2   ,
  p_dsply_on_enrt_flag          in  VARCHAR2   ,
  p_use_to_calc_net_flx_cr_flag in  VARCHAR2   ,
  p_entr_val_at_enrt_flag       in  VARCHAR2   ,
  p_asn_on_enrt_flag            in  VARCHAR2   ,
  p_rl_crs_only_flag            in  VARCHAR2   ,
  p_dflt_val                    in  NUMBER     ,
  p_ann_val                     in  NUMBER     ,
  p_ann_mn_elcn_val             in  NUMBER     ,
  p_ann_mx_elcn_val             in  NUMBER     ,
  p_val                         in  NUMBER     ,
  p_nnmntry_uom                 in  VARCHAR2   ,
  p_mx_elcn_val                 in  NUMBER     ,
  p_mn_elcn_val                 in  NUMBER     ,
  p_incrmt_elcn_val             in  NUMBER     ,
  p_cmcd_acty_ref_perd_cd       in  VARCHAR2   ,
  p_cmcd_mn_elcn_val            in  NUMBER     ,
  p_cmcd_mx_elcn_val            in  NUMBER     ,
  p_cmcd_val                    in  NUMBER     ,
  p_cmcd_dflt_val               in  NUMBER     ,
  p_rt_usg_cd                   in  VARCHAR2   ,
  p_ann_dflt_val                in  NUMBER     ,
  p_bnft_rt_typ_cd              in  VARCHAR2   ,
  p_rt_mlt_cd                   in  VARCHAR2   ,
  p_dsply_mn_elcn_val           in  NUMBER     ,
  p_dsply_mx_elcn_val           in  NUMBER     ,
  p_entr_ann_val_flag           in  VARCHAR2,
  p_rt_strt_dt                  in  DATE       ,
  p_rt_strt_dt_cd               in  VARCHAR2   ,
  p_rt_strt_dt_rl               in  NUMBER     ,
  p_rt_typ_cd                   in  VARCHAR2   ,
  p_elig_per_elctbl_chc_id      in  NUMBER     ,
  p_acty_base_rt_id             in  NUMBER     ,
  p_spcl_rt_enrt_rt_id          in  NUMBER     ,
  p_enrt_bnft_id                in  NUMBER     ,
  p_prtt_rt_val_id              in  NUMBER     ,
  p_decr_bnft_prvdr_pool_id     in  NUMBER     ,
  p_cvg_amt_calc_mthd_id        in  NUMBER     ,
  p_actl_prem_id                in  NUMBER     ,
  p_comp_lvl_fctr_id            in  NUMBER     ,
  p_ptd_comp_lvl_fctr_id        in  NUMBER     ,
  p_clm_comp_lvl_fctr_id        in  NUMBER     ,
  p_business_group_id           in  NUMBER,
  p_perf_min_max_edit           in  VARCHAR2   ,
  p_iss_val                     in  number     ,
  p_val_last_upd_date           in  date       ,
  p_val_last_upd_person_id      in  number     ,
  p_pp_in_yr_used_num           in  number     ,
  p_ecr_attribute_category      in  VARCHAR2   ,
  p_ecr_attribute1              in  VARCHAR2   ,
  p_ecr_attribute2              in  VARCHAR2   ,
  p_ecr_attribute3              in  VARCHAR2   ,
  p_ecr_attribute4              in  VARCHAR2   ,
  p_ecr_attribute5              in  VARCHAR2   ,
  p_ecr_attribute6              in  VARCHAR2   ,
  p_ecr_attribute7              in  VARCHAR2   ,
  p_ecr_attribute8              in  VARCHAR2   ,
  p_ecr_attribute9              in  VARCHAR2   ,
  p_ecr_attribute10             in  VARCHAR2   ,
  p_ecr_attribute11             in  VARCHAR2   ,
  p_ecr_attribute12             in  VARCHAR2   ,
  p_ecr_attribute13             in  VARCHAR2   ,
  p_ecr_attribute14             in  VARCHAR2   ,
  p_ecr_attribute15             in  VARCHAR2   ,
  p_ecr_attribute16             in  VARCHAR2   ,
  p_ecr_attribute17             in  VARCHAR2   ,
  p_ecr_attribute18             in  VARCHAR2   ,
  p_ecr_attribute19             in  VARCHAR2   ,
  p_ecr_attribute20             in  VARCHAR2   ,
  p_ecr_attribute21             in  VARCHAR2   ,
  p_ecr_attribute22             in  VARCHAR2   ,
  p_ecr_attribute23             in  VARCHAR2   ,
  p_ecr_attribute24             in  VARCHAR2   ,
  p_ecr_attribute25             in  VARCHAR2   ,
  p_ecr_attribute26             in  VARCHAR2   ,
  p_ecr_attribute27             in  VARCHAR2   ,
  p_ecr_attribute28             in  VARCHAR2   ,
  p_ecr_attribute29             in  VARCHAR2   ,
  p_ecr_attribute30             in  VARCHAR2   ,
  p_request_id                  in  NUMBER     ,
  p_program_application_id      in  NUMBER     ,
  p_program_id                  in  NUMBER     ,
  p_program_update_date         in  DATE       ,
  p_effective_date              in  date
  ) is
  --
  l_object_version_number  number;
 --
begin
  --
 if g_unrest_ecr_instance.count > 0 then
    --
    for i in g_unrest_ecr_instance.first..g_unrest_ecr_instance.last loop
       if g_unrest_ecr_instance(i).enrt_rt_id = p_enrt_rt_id then
        l_object_version_number := g_unrest_ecr_instance(i).object_version_number;
        g_unrest_ecr_instance(i).mark_delete := 'Y';
       end if;
       --
   end loop;
   --
 end if;
 --
  ben_Enrollment_Rate_api.update_Enrollment_Rate
  (   p_enrt_rt_id              => p_enrt_rt_id
    , p_acty_typ_cd             =>p_acty_typ_cd
    , p_tx_typ_cd               =>p_tx_typ_cd
    , p_ctfn_rqd_flag           =>p_ctfn_rqd_flag
    , p_dflt_flag               =>p_dflt_flag
    , p_dflt_pndg_ctfn_flag     =>p_dflt_pndg_ctfn_flag
    , p_dsply_on_enrt_flag      =>p_dsply_on_enrt_flag
    , p_use_to_calc_net_flx_cr_flag =>p_use_to_calc_net_flx_cr_flag
    , p_entr_val_at_enrt_flag    =>p_entr_val_at_enrt_flag
    , p_asn_on_enrt_flag         =>p_asn_on_enrt_flag
    , p_rl_crs_only_flag         =>p_rl_crs_only_flag
    , p_dflt_val                 =>p_dflt_val
    , p_ann_val                  =>p_ann_val
    , p_ann_mn_elcn_val          =>p_ann_mn_elcn_val
    , p_ann_mx_elcn_val          =>p_ann_mx_elcn_val
    , p_val                      =>p_val
    , p_nnmntry_uom              =>p_nnmntry_uom
    , p_mx_elcn_val              =>p_mx_elcn_val
    , p_mn_elcn_val              =>p_mn_elcn_val
    , p_incrmt_elcn_val          =>p_incrmt_elcn_val
    , p_cmcd_acty_ref_perd_cd    =>p_cmcd_acty_ref_perd_cd
    , p_cmcd_mn_elcn_val         =>p_cmcd_mn_elcn_val
    , p_cmcd_mx_elcn_val         =>p_cmcd_mx_elcn_val
    , p_cmcd_val                 =>p_cmcd_val
    , p_cmcd_dflt_val            =>p_cmcd_dflt_val
    , p_rt_usg_cd                =>p_rt_usg_cd
    , p_ann_dflt_val             =>p_ann_dflt_val
    , p_bnft_rt_typ_cd           =>p_bnft_rt_typ_cd
    , p_rt_mlt_cd                =>p_rt_mlt_cd
    , p_dsply_mn_elcn_val        =>p_dsply_mn_elcn_val
    , p_dsply_mx_elcn_val        =>p_dsply_mx_elcn_val
    , p_entr_ann_val_flag        =>p_entr_ann_val_flag
    , p_rt_strt_dt               =>p_rt_strt_dt
    , p_rt_strt_dt_cd            =>p_rt_strt_dt_cd
    , p_rt_strt_dt_rl            =>p_rt_strt_dt_rl
    , p_rt_typ_cd                =>p_rt_typ_cd
    , p_elig_per_elctbl_chc_id   =>p_elig_per_elctbl_chc_id
    , p_acty_base_rt_id          =>p_acty_base_rt_id
    , p_spcl_rt_enrt_rt_id       =>p_spcl_rt_enrt_rt_id
    , p_enrt_bnft_id             =>p_enrt_bnft_id
    , p_prtt_rt_val_id           =>p_prtt_rt_val_id
    , p_decr_bnft_prvdr_pool_id  =>p_decr_bnft_prvdr_pool_id
    , p_cvg_amt_calc_mthd_id     =>p_cvg_amt_calc_mthd_id
    , p_actl_prem_id             =>p_actl_prem_id
    , p_comp_lvl_fctr_id         =>p_comp_lvl_fctr_id
    , p_ptd_comp_lvl_fctr_id     =>p_ptd_comp_lvl_fctr_id
    , p_clm_comp_lvl_fctr_id     =>p_clm_comp_lvl_fctr_id
    , p_business_group_id        =>p_business_group_id
    , p_request_id               =>p_request_id
    , p_program_application_id   =>p_program_application_id
    , p_program_id               =>p_program_id
    , p_program_update_date      =>p_program_update_date
    , p_effective_date           =>p_effective_date
    , p_pp_in_yr_used_num        =>p_pp_in_yr_used_num
    , p_ordr_num                 =>p_ordr_num
    , p_iss_val                  =>p_iss_val
    , p_object_version_number    => l_object_version_number
    );

  null;
end;
--
procedure update_elig_dpnt
  (p_elig_dpnt_id                   in  number
  ,p_create_dt                      in  date
  ,p_elig_strt_dt                   in  date
  ,p_elig_thru_dt                   in  date
  ,p_ovrdn_flag                     in  varchar2
  ,p_ovrdn_thru_dt                  in  date
  ,p_inelg_rsn_cd                   in  varchar2
  ,p_dpnt_inelig_flag               in  varchar2
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_per_in_ler_id                  in  number
  ,p_elig_per_id                    in  number
  ,p_elig_per_opt_id                in  number
  ,p_elig_cvrd_dpnt_id              in  number
  ,p_dpnt_person_id                 in  number
  ,p_business_group_id              in  number
  ,p_egd_attribute_category         in  varchar2
  ,p_egd_attribute1                 in  varchar2
  ,p_egd_attribute2                 in  varchar2
  ,p_egd_attribute3                 in  varchar2
  ,p_egd_attribute4                 in  varchar2
  ,p_egd_attribute5                 in  varchar2
  ,p_egd_attribute6                 in  varchar2
  ,p_egd_attribute7                 in  varchar2
  ,p_egd_attribute8                 in  varchar2
  ,p_egd_attribute9                 in  varchar2
  ,p_egd_attribute10                in  varchar2
  ,p_egd_attribute11                in  varchar2
  ,p_egd_attribute12                in  varchar2
  ,p_egd_attribute13                in  varchar2
  ,p_egd_attribute14                in  varchar2
  ,p_egd_attribute15                in  varchar2
  ,p_egd_attribute16                in  varchar2
  ,p_egd_attribute17                in  varchar2
  ,p_egd_attribute18                in  varchar2
  ,p_egd_attribute19                in  varchar2
  ,p_egd_attribute20                in  varchar2
  ,p_egd_attribute21                in  varchar2
  ,p_egd_attribute22                in  varchar2
  ,p_egd_attribute23                in  varchar2
  ,p_egd_attribute24                in  varchar2
  ,p_egd_attribute25                in  varchar2
  ,p_egd_attribute26                in  varchar2
  ,p_egd_attribute27                in  varchar2
  ,p_egd_attribute28                in  varchar2
  ,p_egd_attribute29                in  varchar2
  ,p_egd_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  )  is
  --
  l_object_version_number  number;
  --
begin
  --
 if g_unrest_egd_instance.count > 0 then
    --
    for i in g_unrest_egd_instance.first..g_unrest_egd_instance.last loop
       if g_unrest_egd_instance(i).elig_dpnt_id = p_elig_dpnt_id then
        l_object_version_number := g_unrest_egd_instance(i).object_version_number;
        g_unrest_egd_instance(i).mark_delete := 'Y';
       end if;
       --
   end loop;
   --
 end if;
 --
  ben_ELIG_DPNT_api.update_perf_ELIG_DPNT
                 (p_elig_dpnt_id           => p_elig_dpnt_id
                 ,p_create_dt              => p_create_dt
                 ,p_business_group_id      => p_business_group_id
                 ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
                 ,p_dpnt_person_id         => p_dpnt_person_id
                 ,p_per_in_ler_id          => p_per_in_ler_id
                 ,p_elig_cvrd_dpnt_id      => p_elig_cvrd_dpnt_id
                 ,p_elig_strt_dt           => p_elig_strt_dt
                 ,p_elig_thru_dt           => p_elig_thru_dt
                 ,p_elig_per_id            => p_elig_per_id
                 ,p_elig_per_opt_id        => p_elig_per_opt_id
                 ,p_ovrdn_flag             => p_ovrdn_flag
                 ,p_ovrdn_thru_dt          => p_ovrdn_thru_dt
                 ,p_object_version_number  => l_object_version_number
                 ,p_effective_date         => p_effective_date
                 ,p_program_application_id => p_program_application_id
                 ,p_program_id             => p_program_id
                 ,p_request_id             => p_request_id
                 ,p_program_update_date    => p_program_update_date
                 );
                 --
  p_object_version_number := l_object_version_number;
end;
--
--
procedure update_enrt_prem
 ( p_enrt_prem_id                   in  number
  ,p_val                            in  number
  ,p_uom                            in  varchar2
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_enrt_bnft_id                   in  number
  ,p_actl_prem_id                   in  number
  ,p_business_group_id              in  number
  ,p_epr_attribute_category         in  varchar2
  ,p_epr_attribute1                 in  varchar2
  ,p_epr_attribute2                 in  varchar2
  ,p_epr_attribute3                 in  varchar2
  ,p_epr_attribute4                 in  varchar2
  ,p_epr_attribute5                 in  varchar2
  ,p_epr_attribute6                 in  varchar2
  ,p_epr_attribute7                 in  varchar2
  ,p_epr_attribute8                 in  varchar2
  ,p_epr_attribute9                 in  varchar2
  ,p_epr_attribute10                in  varchar2
  ,p_epr_attribute11                in  varchar2
  ,p_epr_attribute12                in  varchar2
  ,p_epr_attribute13                in  varchar2
  ,p_epr_attribute14                in  varchar2
  ,p_epr_attribute15                in  varchar2
  ,p_epr_attribute16                in  varchar2
  ,p_epr_attribute17                in  varchar2
  ,p_epr_attribute18                in  varchar2
  ,p_epr_attribute19                in  varchar2
  ,p_epr_attribute20                in  varchar2
  ,p_epr_attribute21                in  varchar2
  ,p_epr_attribute22                in  varchar2
  ,p_epr_attribute23                in  varchar2
  ,p_epr_attribute24                in  varchar2
  ,p_epr_attribute25                in  varchar2
  ,p_epr_attribute26                in  varchar2
  ,p_epr_attribute27                in  varchar2
  ,p_epr_attribute28                in  varchar2
  ,p_epr_attribute29                in  varchar2
  ,p_epr_attribute30                in  varchar2
  ,p_object_version_number          in out nocopy number
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ) is
  --
  l_object_version_number   number;
  --
begin
 --
  if g_unrest_epr_instance.count > 0 then
    --
    for i in g_unrest_epr_instance.first..g_unrest_epr_instance.last loop
       if g_unrest_epr_instance(i).enrt_prem_id = p_enrt_prem_id then
        l_object_version_number := g_unrest_epr_instance(i).object_version_number;
        g_unrest_epr_instance(i).mark_delete := 'Y';
       end if;
       --
   end loop;
   --
  end if;
  --
  hr_utility.set_location('Obj version'||l_object_version_number,10);
  --
  update ben_enrt_prem set val = p_val, uom=p_uom
    where enrt_prem_id = p_enrt_prem_id;
  /*
  ben_enrt_prem_api.update_enrt_prem
    (p_enrt_prem_id                  => p_enrt_prem_id
    ,p_val                           => p_val
    ,p_uom                           => p_uom
    ,p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
    ,p_enrt_bnft_id                  => p_enrt_bnft_id
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_business_group_id             => p_business_group_id
    ,p_epr_attribute_category        => p_epr_attribute_category
    ,p_epr_attribute1                => p_epr_attribute1
    ,p_epr_attribute2                => p_epr_attribute2
    ,p_epr_attribute3                => p_epr_attribute3
    ,p_epr_attribute4                => p_epr_attribute4
    ,p_epr_attribute5                => p_epr_attribute5
    ,p_epr_attribute6                => p_epr_attribute6
    ,p_epr_attribute7                => p_epr_attribute7
    ,p_epr_attribute8                => p_epr_attribute8
    ,p_epr_attribute9                => p_epr_attribute9
    ,p_epr_attribute10               => p_epr_attribute10
    ,p_epr_attribute11               => p_epr_attribute11
    ,p_epr_attribute12               => p_epr_attribute12
    ,p_epr_attribute13               => p_epr_attribute13
    ,p_epr_attribute14               => p_epr_attribute14
    ,p_epr_attribute15               => p_epr_attribute15
    ,p_epr_attribute16               => p_epr_attribute16
    ,p_epr_attribute17               => p_epr_attribute17
    ,p_epr_attribute18               => p_epr_attribute18
    ,p_epr_attribute19               => p_epr_attribute19
    ,p_epr_attribute20               => p_epr_attribute20
    ,p_epr_attribute21               => p_epr_attribute21
    ,p_epr_attribute22               => p_epr_attribute22
    ,p_epr_attribute23               => p_epr_attribute23
    ,p_epr_attribute24               => p_epr_attribute24
    ,p_epr_attribute25               => p_epr_attribute25
    ,p_epr_attribute26               => p_epr_attribute26
    ,p_epr_attribute27               => p_epr_attribute27
    ,p_epr_attribute28               => p_epr_attribute28
    ,p_epr_attribute29               => p_epr_attribute29
    ,p_epr_attribute30               => p_epr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    );
  --
  p_object_version_number := l_object_version_number;
  */
  --
end;
--
function epe_exists
  ( p_per_in_ler_id  number
   ,p_pgm_id        number
   ,p_pl_id         number
   ,p_oipl_id       number
   ,p_plip_id       number
   ,p_oiplip_id     number
   ,p_ptip_id       number
   ,p_bnft_prvdr_pool_id  number
   ,p_CMBN_PTIP_ID    number
   ,p_CMBN_PTIP_OPT_ID number
   ,p_CMBN_PLIP_ID     number
   ,p_comp_lvl_cd     varchar2
   )  return number is
--
  l_elig_per_elctbl_chc_id number;
begin
  --
  if g_unrest_epe_instance.count > 0 and p_bnft_prvdr_pool_id is null then
    --
    for i in g_unrest_epe_instance.first..g_unrest_epe_instance.last loop
    --
     if g_unrest_epe_instance(i).per_in_ler_id = p_per_in_ler_id and
       nvl(g_unrest_epe_instance(i).pgm_id,-1) = nvl(p_pgm_id,-1) and
       nvl(g_unrest_epe_instance(i).pl_id, -1) = nvl(p_pl_id, -1) and
       nvl(g_unrest_epe_instance(i).oipl_id, -1) =  nvl(p_oipl_id, -1)
        then
        l_elig_per_elctbl_chc_id := g_unrest_epe_instance(i).elig_per_elctbl_chc_id;
       exit;
     end if;
    end loop;
  end if;
  --
  if  g_unrest_epe_instance.count > 0 and p_bnft_prvdr_pool_id is not null then
    --
   if p_comp_lvl_cd = 'PGM' then
     --
     for i in g_unrest_epe_instance.first..g_unrest_epe_instance.last loop
      --
      if g_unrest_epe_instance(i).per_in_ler_id = p_per_in_ler_id and
        g_unrest_epe_instance(i).pgm_id = p_pgm_id and
        g_unrest_epe_instance(i).comp_lvl_cd = p_comp_lvl_cd
        then
        l_elig_per_elctbl_chc_id := g_unrest_epe_instance(i).elig_per_elctbl_chc_id;
        exit;
      end if;
     end loop;
    --
   elsif p_comp_lvl_cd = 'PLIP' then
     --
     for i in g_unrest_epe_instance.first..g_unrest_epe_instance.last loop
      --
      if g_unrest_epe_instance(i).per_in_ler_id = p_per_in_ler_id and
         g_unrest_epe_instance(i).plip_id = p_plip_id and
         g_unrest_epe_instance(i).comp_lvl_cd = p_comp_lvl_cd
        then
        l_elig_per_elctbl_chc_id := g_unrest_epe_instance(i).elig_per_elctbl_chc_id;
        exit;
      end if;
     end loop;
    --
   elsif p_comp_lvl_cd = 'PTIP' then
     --
     for i in g_unrest_epe_instance.first..g_unrest_epe_instance.last loop
      --
      if g_unrest_epe_instance(i).per_in_ler_id = p_per_in_ler_id and
         g_unrest_epe_instance(i).ptip_id = p_ptip_id and
         g_unrest_epe_instance(i).comp_lvl_cd = p_comp_lvl_cd
        then
        l_elig_per_elctbl_chc_id := g_unrest_epe_instance(i).elig_per_elctbl_chc_id;
        exit;
      end if;
     end loop;
    --
   elsif p_comp_lvl_cd = 'CPLIP'  then
     --
     for i in g_unrest_epe_instance.first..g_unrest_epe_instance.last loop
      --
      if g_unrest_epe_instance(i).per_in_ler_id = p_per_in_ler_id and
         g_unrest_epe_instance(i).cmbn_plip_id = p_cmbn_plip_id and
         g_unrest_epe_instance(i).comp_lvl_cd = p_comp_lvl_cd
        then
        l_elig_per_elctbl_chc_id := g_unrest_epe_instance(i).elig_per_elctbl_chc_id;
        exit;
      end if;
     end loop;
    --
   elsif p_comp_lvl_cd = 'CPTIP' then
     --
     for i in g_unrest_epe_instance.first..g_unrest_epe_instance.last loop
      --
      if g_unrest_epe_instance(i).per_in_ler_id = p_per_in_ler_id and
         g_unrest_epe_instance(i).cmbn_ptip_id = p_cmbn_ptip_id and
         g_unrest_epe_instance(i).comp_lvl_cd = p_comp_lvl_cd
        then
        l_elig_per_elctbl_chc_id := g_unrest_epe_instance(i).elig_per_elctbl_chc_id;
        exit;
      end if;
     end loop;
    --
   elsif p_comp_lvl_cd = 'OIPLIP' then
     --
     for i in g_unrest_epe_instance.first..g_unrest_epe_instance.last loop
      --
      if g_unrest_epe_instance(i).per_in_ler_id = p_per_in_ler_id and
         g_unrest_epe_instance(i).oiplip_id = p_oiplip_id and
         g_unrest_epe_instance(i).comp_lvl_cd = p_comp_lvl_cd
        then
        l_elig_per_elctbl_chc_id := g_unrest_epe_instance(i).elig_per_elctbl_chc_id;
        exit;
      end if;
     end loop;
    --
   elsif p_comp_lvl_cd = 'CPTIPOPT' then
     --
     for i in g_unrest_epe_instance.first..g_unrest_epe_instance.last loop
      --
      if g_unrest_epe_instance(i).per_in_ler_id = p_per_in_ler_id and
         g_unrest_epe_instance(i).cmbn_ptip_opt_id = p_cmbn_ptip_opt_id and
         g_unrest_epe_instance(i).comp_lvl_cd = p_comp_lvl_cd
        then
        l_elig_per_elctbl_chc_id := g_unrest_epe_instance(i).elig_per_elctbl_chc_id;
        exit;
      end if;
      end loop;
    --
   end if;
   --
 end if;
  hr_utility.set_location('Elig per chc id'||l_elig_per_elctbl_chc_id,10);
  return l_elig_per_elctbl_chc_id;

end;
--
function enb_exists
 (p_ELIG_PER_ELCTBL_CHC_ID  number
 ,p_ORDR_NUM                number
 ) return number is
 --
 l_enrt_bnft_id number;
 --
begin
  --
  if g_unrest_enb_instance.count > 0 then
    --
    for i in g_unrest_enb_instance.first..g_unrest_enb_instance.last loop
    --
     if g_unrest_enb_instance(i).ELIG_PER_ELCTBL_CHC_ID = p_ELIG_PER_ELCTBL_CHC_ID and
       nvl(g_unrest_enb_instance(i).ORDR_NUM,-100) = nvl(p_ORDR_NUM,-100)
        then
        l_enrt_bnft_id := g_unrest_enb_instance(i).enrt_bnft_id;
       exit;
     end if;
    end loop;
  end if;
  hr_utility.set_location('ENrt Bnft id'||l_enrt_bnft_id,10);
  return l_enrt_bnft_id;

end;
--
function ecr_exists
 (p_ELIG_PER_ELCTBL_CHC_ID  number
 ,p_enrt_bnft_id    number
 ,p_acty_base_rt_id  number
 ) return number is
 --
 l_enrt_rt_id   number;
 --
begin
 --
  hr_utility.set_location('Count '||g_unrest_ecr_instance.count,1);
  hr_utility.set_location('Electable choice Id'||p_ELIG_PER_ELCTBL_CHC_ID,2);
  hr_utility.set_location('Act base rt id'||p_acty_base_rt_id,3);
  hr_utility.set_location('Benefit Id'||p_enrt_bnft_id,4);


  if g_unrest_ecr_instance.count > 0 then
    --
    for i in g_unrest_ecr_instance.first..g_unrest_ecr_instance.last loop
    --
     if nvl(g_unrest_ecr_instance(i).ELIG_PER_ELCTBL_CHC_ID, -1) =
                nvl(p_ELIG_PER_ELCTBL_CHC_ID, -1) and
       nvl(g_unrest_ecr_instance(i).enrt_bnft_id,-100) = nvl(p_enrt_bnft_id,-100) and
       nvl(g_unrest_ecr_instance(i).acty_base_rt_id,-100) = nvl(p_acty_base_rt_id,-100)
        then
        l_enrt_rt_id := g_unrest_ecr_instance(i).enrt_rt_id;
       exit;
     end if;
    end loop;
  end if;
  hr_utility.set_location('ENrt Rate id'||l_enrt_rt_id,10);
  return l_enrt_rt_id;

end;
--
function epr_exists
 (p_ELIG_PER_ELCTBL_CHC_ID  number
 ,p_enrt_bnft_id    number
 ,p_ACTL_PREM_ID    number
 ) return number is
 --
 l_enrt_prem_id  number;
 --
begin
  --
  if g_unrest_epr_instance.count > 0 then
    --
    for i in g_unrest_epr_instance.first..g_unrest_epr_instance.last loop
    --
     if nvl(g_unrest_epr_instance(i).ELIG_PER_ELCTBL_CHC_ID, -1) =
                         nvl(p_ELIG_PER_ELCTBL_CHC_ID, -1) and
       nvl(g_unrest_epr_instance(i).enrt_bnft_id,-100) = nvl(p_enrt_bnft_id,-100) and
       nvl(g_unrest_epr_instance(i).ACTL_PREM_ID,-100) = nvl(p_ACTL_PREM_ID,-100)
        then
        l_enrt_prem_id := g_unrest_epr_instance(i).enrt_prem_id;
       exit;
     end if;
    end loop;
  end if;
  hr_utility.set_location('ENrt Premium id'||l_enrt_prem_id,10);
  return l_enrt_prem_id;

end;

function egd_exists
 (p_PER_IN_LER_ID  number
 ,p_ELIG_PER_ID    number
 ,p_ELIG_PER_OPT_ID  number
 ,p_DPNT_PERSON_ID   number
 ) return number is
 --
 l_elig_dpnt_id number;
 --
begin
  --
   hr_utility.set_location('Egd Exists',10);
   hr_utility.set_location('Egd count'||g_unrest_egd_instance.count,11);
   if g_unrest_egd_instance.count > 0 then
    --
    for i in g_unrest_egd_instance.first..g_unrest_egd_instance.last loop
      hr_utility.set_location('per_in ler id'||g_unrest_egd_instance(i).PER_IN_LER_ID,12);
    --
     if g_unrest_egd_instance(i).PER_IN_LER_ID = p_PER_IN_LER_ID and
       nvl(g_unrest_egd_instance(i).ELIG_PER_ID,-100) = nvl(p_ELIG_PER_ID,-100) and
       nvl(g_unrest_egd_instance(i).ELIG_PER_OPT_ID,-1) = nvl(p_ELIG_PER_OPT_ID,-1) and
       g_unrest_egd_instance(i).DPNT_PERSON_ID = p_DPNT_PERSON_ID
        then
        l_elig_dpnt_id := g_unrest_egd_instance(i).elig_dpnt_id;
       exit;
     end if;
    end loop;
  end if;
  hr_utility.set_location('Elig dpnt id'||l_elig_dpnt_id,10);
  return l_elig_dpnt_id;

end;
--
function ecc_exists
( p_ELIG_PER_ELCTBL_CHC_ID  number default null
 ,p_enrt_bnft_id    number default null
 ,p_ENRT_CTFN_TYP_CD  varchar2
) return number is
 --
 l_enrt_ctfn_id  number;
 --
begin
  --
  if g_unrest_ecc_instance.count > 0 then
    --
    for i in g_unrest_ecc_instance.first..g_unrest_ecc_instance.last loop
    --
     if nvl(g_unrest_ecc_instance(i).ELIG_PER_ELCTBL_CHC_ID, -1) =
                nvl(p_ELIG_PER_ELCTBL_CHC_ID, -1) and
       nvl(g_unrest_ecc_instance(i).enrt_bnft_id,-100) = nvl(p_enrt_bnft_id,-100) and
       nvl(g_unrest_ecc_instance(i).ENRT_CTFN_TYP_CD,-100) = nvl(p_ENRT_CTFN_TYP_CD,-100)
        then
        l_enrt_ctfn_id := g_unrest_ecc_instance(i).elctbl_chc_ctfn_id;
       exit;
     end if;
    end loop;
  end if;
  hr_utility.set_location('Chc Cert  id'||l_enrt_ctfn_id,10);
  return l_enrt_ctfn_id;
  --
end;
--
procedure update_enrt_ctfn
(  p_elctbl_chc_ctfn_id             in  number
  ,p_enrt_ctfn_typ_cd               in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_enrt_bnft_id                   in  number
  ,p_business_group_id              in  number
  ,p_ecc_attribute_category         in  varchar2
  ,p_ecc_attribute1                 in  varchar2
  ,p_ecc_attribute2                 in  varchar2
  ,p_ecc_attribute3                 in  varchar2
  ,p_ecc_attribute4                 in  varchar2
  ,p_ecc_attribute5                 in  varchar2
  ,p_ecc_attribute6                 in  varchar2
  ,p_ecc_attribute7                 in  varchar2
  ,p_ecc_attribute8                 in  varchar2
  ,p_ecc_attribute9                 in  varchar2
  ,p_ecc_attribute10                in  varchar2
  ,p_ecc_attribute11                in  varchar2
  ,p_ecc_attribute12                in  varchar2
  ,p_ecc_attribute13                in  varchar2
  ,p_ecc_attribute14                in  varchar2
  ,p_ecc_attribute15                in  varchar2
  ,p_ecc_attribute16                in  varchar2
  ,p_ecc_attribute17                in  varchar2
  ,p_ecc_attribute18                in  varchar2
  ,p_ecc_attribute19                in  varchar2
  ,p_ecc_attribute20                in  varchar2
  ,p_ecc_attribute21                in  varchar2
  ,p_ecc_attribute22                in  varchar2
  ,p_ecc_attribute23                in  varchar2
  ,p_ecc_attribute24                in  varchar2
  ,p_ecc_attribute25                in  varchar2
  ,p_ecc_attribute26                in  varchar2
  ,p_ecc_attribute27                in  varchar2
  ,p_ecc_attribute28                in  varchar2
  ,p_ecc_attribute29                in  varchar2
  ,p_ecc_attribute30                in  varchar2
  ,p_susp_if_ctfn_not_prvd_flag     in  varchar2
  ,p_ctfn_determine_cd              in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  ) is
  --
  l_object_version_number   number;
  --
begin
  --
  if g_unrest_ecc_instance.count > 0 then
    --
    for i in g_unrest_ecc_instance.first..g_unrest_ecc_instance.last loop
       if g_unrest_ecc_instance(i).elctbl_chc_ctfn_id = p_elctbl_chc_ctfn_id then
        l_object_version_number := g_unrest_ecc_instance(i).object_version_number;
        g_unrest_ecc_instance(i).mark_delete := 'Y';
       end if;
       --
   end loop;
   --
 end if;
 --
   ben_ELTBL_CHC_CTFN_api.update_ELTBL_CHC_CTFN
    (p_elctbl_chc_ctfn_id            => p_elctbl_chc_ctfn_id
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_rqd_flag                      => p_rqd_flag
    ,p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
    ,p_enrt_bnft_id                  => p_enrt_bnft_id
    ,p_business_group_id             => p_business_group_id
    ,p_ecc_attribute_category        => p_ecc_attribute_category
    ,p_ecc_attribute1                => p_ecc_attribute1
    ,p_ecc_attribute2                => p_ecc_attribute2
    ,p_ecc_attribute3                => p_ecc_attribute3
    ,p_ecc_attribute4                => p_ecc_attribute4
    ,p_ecc_attribute5                => p_ecc_attribute5
    ,p_ecc_attribute6                => p_ecc_attribute6
    ,p_ecc_attribute7                => p_ecc_attribute7
    ,p_ecc_attribute8                => p_ecc_attribute8
    ,p_ecc_attribute9                => p_ecc_attribute9
    ,p_ecc_attribute10               => p_ecc_attribute10
    ,p_ecc_attribute11               => p_ecc_attribute11
    ,p_ecc_attribute12               => p_ecc_attribute12
    ,p_ecc_attribute13               => p_ecc_attribute13
    ,p_ecc_attribute14               => p_ecc_attribute14
    ,p_ecc_attribute15               => p_ecc_attribute15
    ,p_ecc_attribute16               => p_ecc_attribute16
    ,p_ecc_attribute17               => p_ecc_attribute17
    ,p_ecc_attribute18               => p_ecc_attribute18
    ,p_ecc_attribute19               => p_ecc_attribute19
    ,p_ecc_attribute20               => p_ecc_attribute20
    ,p_ecc_attribute21               => p_ecc_attribute21
    ,p_ecc_attribute22               => p_ecc_attribute22
    ,p_ecc_attribute23               => p_ecc_attribute23
    ,p_ecc_attribute24               => p_ecc_attribute24
    ,p_ecc_attribute25               => p_ecc_attribute25
    ,p_ecc_attribute26               => p_ecc_attribute26
    ,p_ecc_attribute27               => p_ecc_attribute27
    ,p_ecc_attribute28               => p_ecc_attribute28
    ,p_ecc_attribute29               => p_ecc_attribute29
    ,p_ecc_attribute30               => p_ecc_attribute30
    ,p_susp_if_ctfn_not_prvd_flag    => p_susp_if_ctfn_not_prvd_flag
    ,p_ctfn_determine_cd             => p_ctfn_determine_cd
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
   --
   p_object_version_number := l_object_version_number;
end;
--
procedure clear_cache is
 --
begin
  --
   if g_unrest_ecr_instance.count > 0 then
     --
     for i in g_unrest_ecr_instance.first..g_unrest_ecr_instance.last loop
      --
      if g_unrest_ecr_instance(i).mark_delete is null then
        --
        delete from ben_enrt_rt where enrt_rt_id = g_unrest_ecr_instance(i).enrt_rt_id;
        --
      end if;
      --
     end loop;
     --
   end if;
   --
   if g_unrest_epr_instance.count > 0 then
     --
     for i in g_unrest_epr_instance.first..g_unrest_epr_instance.last loop
      --
      if g_unrest_epr_instance(i).mark_delete is null then
        --
        delete from ben_enrt_prem where enrt_prem_id = g_unrest_epr_instance(i).enrt_prem_id;
        --
      end if;
      --
     end loop;
     --
   end if;
   --
   if g_unrest_ecc_instance.count > 0 then
     --
     for i in g_unrest_ecc_instance.first..g_unrest_ecc_instance.last loop
      --
      if g_unrest_ecc_instance(i).mark_delete is null then
        --
        delete from ben_elctbl_chc_ctfn where elctbl_chc_ctfn_id =
                       g_unrest_ecc_instance(i).elctbl_chc_ctfn_id;
        --
      end if;
      --
     end loop;
     --
   end if;
   --
   if g_unrest_enb_instance.count > 0 then
     --
     for i in g_unrest_enb_instance.first..g_unrest_enb_instance.last loop
      --
      if g_unrest_enb_instance(i).mark_delete is null then
        --
        delete from ben_enrt_bnft where enrt_bnft_id = g_unrest_enb_instance(i).enrt_bnft_id;
        --
      end if;
      --
     end loop;
     --
   end if;
   --
   if g_unrest_egd_instance.count > 0 then
     --
     for i in g_unrest_egd_instance.first..g_unrest_egd_instance.last loop
      --
      if g_unrest_egd_instance(i).mark_delete is null then
        --
        delete from ben_elig_dpnt where elig_dpnt_id = g_unrest_egd_instance(i).elig_dpnt_id;
        --
      end if;
      --
     end loop;
     --
   end if;
   --
   if g_unrest_epe_instance.count > 0 then
     --
     for i in g_unrest_epe_instance.first..g_unrest_epe_instance.last loop
      --
      if g_unrest_epe_instance(i).mark_delete is null then
        --
        hr_utility.set_location ('Delete Elig Id '||g_unrest_epe_instance(i).elig_per_elctbl_chc_id,11);
        delete from ben_elig_per_elctbl_chc where elig_per_elctbl_chc_id =
               g_unrest_epe_instance(i).elig_per_elctbl_chc_id;
        --
      end if;
      --
     end loop;
     --
   end if;
   --
   g_unrest_epe_instance.delete;
   g_unrest_enb_instance.delete;
   g_unrest_ecr_instance.delete;
   g_unrest_egd_instance.delete;
   g_unrest_ecc_instance.delete;
   g_unrest_epr_instance.delete;
   --
end;
--
procedure clear_epe_cache is
 -- Added during bug fix 4640014
 l_unrest_epe_instance g_unrest_epe_inst_tbl;
 l_idx number := 1 ;
 --
begin
  --
   if g_unrest_epe_instance.count > 0 then
     --
     for i in g_unrest_epe_instance.first..g_unrest_epe_instance.last loop
      --
      if g_unrest_epe_instance(i).mark_delete is null
       and g_unrest_epe_instance(i).comp_lvl_cd in ('OIPL','PLAN') then
      -- and g_unrest_epe_instance(i).elctbl_flag = 'Y' -- bug 4761065 : Need to delete epe regardless whether its elctbl_flag is Y/N .
        --
        hr_utility.set_location ('Delete Elig Id in clear_epe '||g_unrest_epe_instance(i).elig_per_elctbl_chc_id,11);
        delete from ben_elig_per_elctbl_chc where elig_per_elctbl_chc_id =
               g_unrest_epe_instance(i).elig_per_elctbl_chc_id;
        --
      else
        --
        l_unrest_epe_instance(l_idx) := g_unrest_epe_instance(i) ;
        l_idx := l_idx + 1;
        --
      end if;
      --
     end loop;
     --
      g_unrest_epe_instance := l_unrest_epe_instance ;
     --
   end if;
   --
end clear_epe_cache;
--
-- Bug 5055119

PROCEDURE end_date_elig_per_rows (
   p_person_id        IN   NUMBER,
   p_per_in_ler_id    IN   NUMBER,
   p_effective_date   IN   DATE
)
IS
   /**
   Get the new peps which has corresponding future pep
   .If found then end date new pep to one day before effective start date of
   future counterpart pep
   **/
   CURSOR get_pep
   IS
      SELECT   new_pep.elig_per_id, new_pep.object_version_number,
               MIN (old_pep.effective_start_date) - 1 end_date
          FROM ben_elig_per_f new_pep, ben_elig_per_f old_pep
         WHERE new_pep.person_id = p_person_id
           AND old_pep.person_id = new_pep.person_id
           AND new_pep.per_in_ler_id = p_per_in_ler_id
           AND old_pep.per_in_ler_id = new_pep.per_in_ler_id
           AND (   (    NVL (new_pep.pgm_id, -1) = NVL (old_pep.pgm_id, -2)
                    AND new_pep.pl_id IS NULL
                    AND new_pep.plip_id IS NULL
                    AND new_pep.ptip_id IS NULL
                    AND old_pep.pl_id IS NULL
                    AND old_pep.plip_id IS NULL
                    AND old_pep.ptip_id IS NULL
                   )
                OR (    NVL (old_pep.pl_id, -1) = NVL (new_pep.pl_id, -2)
                    -- added bug 5658405
                    AND NVL (new_pep.pgm_id, -1) = NVL (old_pep.pgm_id, -1)
                   )
                OR NVL (old_pep.plip_id, -1) = NVL (new_pep.plip_id, -2)
                OR NVL (old_pep.ptip_id, -1) = NVL (new_pep.ptip_id, -2)
               )
           AND old_pep.effective_start_date > p_effective_date
           AND old_pep.effective_start_date > new_pep.effective_start_date
           AND new_pep.effective_start_date = p_effective_date
           AND new_pep.effective_end_date = hr_api.g_eot
      GROUP BY new_pep.elig_per_id, new_pep.object_version_number;

   /**
   Get the new child epos of new peps which has corresponding future pep
   .If found then end date new epos to one day before effective start date of
   future parent pep
   **/
   CURSOR get_epo (v_elig_per_id IN NUMBER
                                          -- added 5658405
   , v_end_date IN DATE)
   IS
      SELECT new_epo.elig_per_opt_id, new_epo.object_version_number,
             effective_start_date, effective_end_date
        FROM ben_elig_per_opt_f new_epo
       WHERE new_epo.elig_per_id = v_elig_per_id
              -- bug 5658405
              -- AND new_epo.per_in_ler_id = p_per_in_ler_id
         -- AND new_epo.effective_start_date = p_effective_date
              -- AND new_epo.effective_end_date = hr_api.g_eot;
         AND v_end_date BETWEEN new_epo.effective_start_date
                            AND new_epo.effective_end_date;

   -- added bug 5658405
   CURSOR get_future_epo (v_elig_per_id IN NUMBER, v_end_date IN DATE)
   IS
      SELECT future_epo.elig_per_opt_id, future_epo.object_version_number
        FROM ben_elig_per_opt_f future_epo
       WHERE elig_per_id = v_elig_per_id AND effective_end_date > v_end_date;

   l_effective_start_date   DATE;
   l_effective_end_date     DATE;
   l_epo                    get_epo%ROWTYPE;
   l_pep                    get_pep%ROWTYPE;

   future_epo_rec           get_future_epo%ROWTYPE;
   ---- end bug 5658405
/***/
BEGIN
   hr_utility.set_location
             ('Entering ben_manage_unres_life_events.end_date_elig_per_rows',
              10
             );

   OPEN get_pep;

   LOOP
      FETCH get_pep
       INTO l_pep;

      EXIT WHEN get_pep%NOTFOUND;

      /**get its child **/
      -- OPEN get_epo (l_pep.elig_per_id);
         hr_utility.set_location
                                (   '******************* l_pep.elig_per_id '
                                 || l_pep.elig_per_id,
                                 12.12
                                );

      OPEN get_epo (l_pep.elig_per_id, l_pep.end_date);

      LOOP
         FETCH get_epo
          INTO l_epo;

         EXIT WHEN get_epo%NOTFOUND;
         hr_utility.set_location (   'End-dating elig_per_opt_id  '
                                  || l_epo.elig_per_opt_id
                                  || ' to '
                                  || l_pep.end_date,
                                  9909
                                 );
         hr_utility.set_location (   l_epo.elig_per_opt_id
                                  || ' : '
                                  || TO_CHAR (l_pep.end_date)
                                  || ' : '
                                  || l_epo.object_version_number
                                  || ' : '
                                  || TO_CHAR (l_epo.effective_start_date)
                                  || ' : '
                                  || TO_CHAR (l_epo.effective_end_date),
                                  12.12
                                 );
         ben_elig_person_option_api.delete_elig_person_option
                      (p_elig_per_opt_id            => l_epo.elig_per_opt_id,
                       p_object_version_number      => l_epo.object_version_number,
                       p_effective_start_date       => l_effective_start_date,
                       p_effective_end_date         => l_effective_end_date,
                       p_effective_date             => l_pep.end_date,
                       p_datetrack_mode             => 'DELETE'
                      );
      END LOOP;

      CLOSE get_epo;

      -- bug 5658405
      OPEN get_future_epo (l_pep.elig_per_id, l_pep.end_date);
	-- end dating the future epos .. otherwise these will have no parent pep
	-- and these will not end date the pep records.

      LOOP
         FETCH get_future_epo
          INTO future_epo_rec;

         EXIT WHEN get_future_epo%NOTFOUND;
         hr_utility.set_location (   'End-dating elig_per_opt_id  update'
                                  || future_epo_rec.elig_per_opt_id
                                  || ' to '
                                  || l_pep.end_date,
                                  9909
                                 );

         UPDATE ben_elig_per_opt_f
		-- updating the elig_per_opt_f
		-- as these cant be end dated using api.
            SET effective_end_date = l_pep.end_date
          WHERE elig_per_opt_id = future_epo_rec.elig_per_opt_id
            AND object_version_number = future_epo_rec.object_version_number;
      END LOOP;

      CLOSE get_future_epo;

      hr_utility.set_location (   'End-dating elig_per_id  '
                               || l_pep.elig_per_id
                               || ' to '
                               || l_pep.end_date,
                               9909
                              );
      hr_utility.set_location (   'per_in_ler_id'
                               || ' : '
                               || 'elig_per_opt_id'
                               || ' : '
                               || 'effective_start_date'
                               || ' : '
                               || 'effective_end_date',
                               12.12
                              );

      hr_utility.set_location (   '=>l_pep.elig_per_id '
                               || l_pep.elig_per_id
                               || '  '
                               || l_pep.object_version_number,
                               12.12
                              );

      ben_eligible_person_api.delete_eligible_person
                      (p_elig_per_id                => l_pep.elig_per_id,
                       p_object_version_number      => l_pep.object_version_number,
                       p_effective_date             => l_pep.end_date,
                       p_effective_start_date       => l_effective_start_date,
                       p_effective_end_date         => l_effective_end_date,
                       p_datetrack_mode             => 'DELETE'
                      );
      hr_utility.set_location (   'After ending pep '
                               || l_pep.elig_per_id
                               || ' '
                               || TO_CHAR (l_effective_start_date)
                               || ' '
                               || TO_CHAR (l_effective_end_date),
                               12.12
                              );
   END LOOP;

   CLOSE get_pep;

   hr_utility.set_location
               ('Leaving ben_manage_unres_life_events.end_date_elig_per_rows',
                20
               );
END end_date_elig_per_rows;

end ben_manage_unres_life_events;

/
