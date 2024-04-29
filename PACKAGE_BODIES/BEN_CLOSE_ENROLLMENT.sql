--------------------------------------------------------
--  DDL for Package Body BEN_CLOSE_ENROLLMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLOSE_ENROLLMENT" AS
/* $Header: benclenr.pkb 120.13.12010000.5 2009/08/17 11:32:44 pvelvano ship $ */
--
g_package          varchar2(80) := 'ben_close_enrollment';
g_max_person_err   Number := 100;
g_persons_errored  Number := 0;
g_persons_procd    Number := 0;
g_cache_per_proc   g_cache_person_process_rec;
l_pend_approvals   boolean;
--
-- Global cursor declaration
--
  cursor gc_pel(c_per_in_ler_id     number
               ,c_business_group_id number)
  is
  select a.pil_elctbl_chc_popl_id
        ,a.cls_enrt_dt_to_use_cd
        ,a.dflt_asnd_dt
        ,a.dflt_enrt_dt
        ,a.auto_asnd_dt
        ,a.elcns_made_dt
        ,a.enrt_perd_end_dt
        ,a.enrt_perd_strt_dt
        ,a.enrt_typ_cycl_cd
        ,a.pgm_id
        ,a.pl_id
        ,a.pil_elctbl_popl_stat_cd
        ,a.procg_end_dt
        ,'N' set_flag
        ,a.object_version_number
	,a.defer_deenrol_flag
    from ben_pil_elctbl_chc_popl a
   where a.per_in_ler_id = c_per_in_ler_id
     and a.business_group_id = c_business_group_id
     and a.pil_elctbl_popl_stat_cd = 'STRTD';
  --
  cursor c_all_auto(p_pil_elctbl_chc_popl_id number) is
    select 'Y'
    from   ben_elig_per_elctbl_chc
    where  (elctbl_flag = 'Y'      -------Bug 8531750
      or   crntly_enrd_flag = 'Y') -------Bug 8531750
    and    auto_enrt_flag = 'N'
    and    pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id;
  --
  l_dummy varchar2(30);
--
-- Type declaration
--
type g_pel_rec is table of gc_pel%rowtype index by binary_integer;
--
-- -----------------------------------------------------------------------------
-- |-----------------------< write_person_category >---------------------------|
-- -----------------------------------------------------------------------------
--
procedure write_person_category
  (p_per_in_ler_clsed   in boolean
  ,p_audit_log          in varchar2 default 'N'
  ,p_error              in boolean  default false
  ,p_business_group_id  in number
  ,p_person_id          in number
  ,p_effective_date     in date)
is
  --
  cursor c1 (c_prtt_enrt_rslt_id number)
  is
  select ecd.dpnt_person_id, ecd.cvg_strt_dt, ecd.cvg_thru_dt
    from ben_elig_cvrd_dpnt_f ecd,
         ben_per_in_ler pil
   where ecd.prtt_enrt_rslt_id is not NULL
     and ecd.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
     and ecd.business_group_id = p_business_group_id
     and p_effective_date between effective_start_date
                              and effective_end_date
     and pil.per_in_ler_id=ecd.per_in_ler_id
     and pil.business_group_id=p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  l_actn       varchar2(80);
  l_cache      ben_batch_utils.g_comp_obj_table := ben_batch_utils.g_cache_comp;
  l_cache_cnt  binary_integer := ben_batch_utils.g_cache_comp_cnt;
  l_category   varchar2(30);
  l_chg        boolean;
  l_detail     varchar2(132) := 'Default election asigned - ' ||
                                'no current elections changed' ;
  l_ovn        number;
  l_id         number;
  l_ovn1       varchar2(240);
  l_actn_cd    varchar2(30);
  --
  l_proc       varchar2(80) := g_package || '.write_person_category';
  --
begin
  --
  hr_utility.set_location ('Entering ' || l_proc, 05);
  --
  if p_error then
    --
    if p_audit_log = 'Y' then
      --
      l_category := 'ERROR_C';
      l_detail := 'Error occur while closing enrollment';
      --
      ben_batch_utils.write_rec(p_typ_cd => l_category
                               ,p_text   => l_detail);
      --
    end if;
    --
  else
    --
    if l_cache_cnt = 0 then
      --
      if p_per_in_ler_clsed then
        l_category := 'CLSNODEF';
        l_detail := 'Participant enrollment closed without defaults';
      else
        l_category := 'CLSNNOACTN';
        l_detail := 'Participant processed without action';
      end if;
      --
    else
      --
      l_chg := FALSE;
      --
      for i in 1..l_cache_cnt
      loop
        --
        if l_cache(i).upd_flag or
           l_cache(i).ins_flag or
           l_cache(i).del_flag then
          --
          l_chg := TRUE;
          exit;
          --
        end if;
        --
      end loop;
      --
      if p_per_in_ler_clsed then
        --
        if l_chg then
          --
          l_category := 'CLSDEFWCHG';
          l_detail := 'Participant Enrollment closed without default changed';
          --
        else
          --
          l_category := 'CLSDEFNOCHG';
          l_detail := 'Participant Enrollment closed without default unchanged';
          --
        end if;
        --
      else
        --
        if l_chg then
          --
          l_category := 'CLSNDEFWCHG';
          l_detail := 'Participant Enrollment not closed with defaults changed';
          --
        else
          --
          l_category := 'CLSNDEFNOCHG';
          l_detail :=
                    'Participant Enrollment not closed with defaults unchanged';
          --
        end if;
        --
      end if;
      --
    end if;
    --
    l_actn := 'Calling ben_batch_utils.write_rec (DEFAULT)...';
    --
    ben_batch_utils.write_rec(p_typ_cd => l_category
                             ,p_text   => l_detail);
  end if;
  --
  if p_audit_log = 'Y' then
    --
    for i in 1..l_cache_cnt
    loop
      --
      if l_cache(i).del_flag then
        --
        l_actn_cd := 'DEL';
        --
      elsif l_cache(i).ins_flag then
        --
        l_actn_cd := 'INS';
        --
      elsif l_cache(i).upd_flag then
        --
        l_actn_cd := 'UPD';
        --
      elsif l_cache(i).def_flag then
        --
        l_actn_cd := 'DEF';
        --
      end if;
      --
      l_actn := 'Calling ben_batch_rate_info_api.create_batch_rate_info...';
      --
      ben_batch_rate_info_api.create_batch_rate_info
        (p_batch_rt_id           => l_id
        ,p_benefit_action_id     => benutils.g_benefit_action_id
        ,p_person_id             => p_person_id
        ,p_pgm_id                => l_cache(i).pgm_id
        ,p_pl_id                 => l_cache(i).pl_id
        ,p_oipl_id               => l_cache(i).oipl_id
        ,p_dflt_val              => l_cache(i).bnft_amt
        ,p_val                   => l_cache(i).prtt_enrt_rslt_id
        ,p_enrt_cvg_strt_dt      => l_cache(i).cvg_strt_dt           /* Bug 4229221 */
        ,p_enrt_cvg_thru_dt      => l_cache(i).cvg_thru_dt           /* Bug 4229221 */
        ,p_actn_cd               => l_actn_cd
        ,p_dflt_flag             => 'Y'
        ,p_business_group_id     => p_business_group_id
        ,p_effective_date        => p_effective_date
        ,p_object_version_number => l_ovn
        );
      --
      if l_cache(i).prtt_enrt_rslt_id is not NULL then
        --
        for l_rec in c1(l_cache(i).prtt_enrt_rslt_id)
        loop
          --
          l_actn := 'Calling ben_batch_dpnt_info_api.create_batch_dpnt_info...';
          --
          ben_batch_dpnt_info_api.create_batch_dpnt_info
            (p_batch_dpnt_id         => l_id
            ,p_person_id             => p_person_id
            ,p_benefit_action_id     => benutils.g_benefit_action_id
            ,p_business_group_id     => p_business_group_id
            ,p_pgm_id                => l_cache(i).pgm_id
            ,p_pl_id                 => l_cache(i).pl_id
            ,p_oipl_id               => l_cache(i).oipl_id
            ,p_enrt_cvg_strt_dt      => l_rec.cvg_strt_dt
            ,p_enrt_cvg_thru_dt      => l_rec.cvg_thru_dt
            ,p_actn_cd               => l_actn_cd
            ,p_object_version_number => l_ovn1
            ,p_dpnt_person_id        => l_rec.dpnt_person_id
            ,p_effective_date        => p_effective_date);
          --
        end loop;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
exception
  --
  when others then
    --
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag  => TRUE);
    --
    raise;
    --
end write_person_category;
--
-- -----------------------------------------------------------------------------
-- |-----------------------< write_pil_elctbl_popl >---------------------------|
-- -----------------------------------------------------------------------------
--
procedure write_pil_elctbl_popl
  (p_rec               in out nocopy g_pel_rec
  ,p_cnt               in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date)
is
  --
  l_proc        varchar2(80) := g_package||'.write_pil_elctbl_popl';
  l_status      varchar2(30) := 'Started';
  l_pgm_name    ben_pgm_f.name%TYPE; -- UTF8 varchar2(80);
  l_pl_name     ben_pl_f.name%TYPE;  -- UTF8 varchar2(80);
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,05);
  --
  if p_cnt > 0 then
    --
    ben_batch_utils.write
      (ben_batch_utils.ret_str('Program name',    30) ||
       ben_batch_utils.ret_str('Plan name',       30) ||
       ben_batch_utils.ret_str('Cls_to_use_cd',   15) ||
       ben_batch_utils.ret_str('Enrt_perd_strt',  15) ||
       ben_batch_utils.ret_str('Enrt_perd_end',   15) ||
       ben_batch_utils.ret_str('Procd_end_date',  15) ||
       ben_batch_utils.ret_str('Deflt_apply_dt',  15) ||
       ben_batch_utils.ret_str('Elcn_made_date',  15) ||
       ben_batch_utils.ret_str('Dflt_asgn_date',  15) ||
       ben_batch_utils.ret_str('Enrt status',     10)
      );
    --
    for i in 1..p_cnt
    loop
      --
      if p_rec(i).set_flag = 'Y' then
        l_status := 'Processed';
      else
        l_status := 'Started';
      end if;
      --
      l_pgm_name := ben_batch_utils.get_pgm_name
                     (p_pgm_id            => p_rec(i).pgm_id
                     ,p_business_group_id => p_business_group_id
                     ,p_effective_date    => p_effective_date);
      --
      l_pl_name  := ben_batch_utils.get_pl_name
                     (p_pl_id             => p_rec(i).pl_id
                     ,p_business_group_id => p_business_group_id
                     ,p_effective_date    => p_effective_date);
      --
      ben_batch_utils.write
        (ben_batch_utils.ret_str(l_pgm_name,30) ||
         ben_batch_utils.ret_str(l_pl_name, 30) ||
         ben_batch_utils.ret_str(p_rec(i).cls_enrt_dt_to_use_cd, 15) ||
         ben_batch_utils.ret_str(p_rec(i).enrt_perd_strt_dt, 15)     ||
         ben_batch_utils.ret_str(p_rec(i).enrt_perd_end_dt, 15)      ||
         ben_batch_utils.ret_str(p_rec(i).procg_end_dt, 15)          ||
         ben_batch_utils.ret_str(p_rec(i).dflt_enrt_dt, 15)          ||
         ben_batch_utils.ret_str(p_rec(i).elcns_made_dt, 15)         ||
         ben_batch_utils.ret_str(p_rec(i).dflt_asnd_dt, 15)          ||
         ben_batch_utils.ret_str(l_status,10)
        );
      --
    end loop;
    --
  end if;
  --
  hr_utility.set_location ('Leaving ' || l_proc, 10);
  --
end write_pil_elctbl_popl;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< submit_all_reports >----------------------------|
-- -----------------------------------------------------------------------------
--
procedure submit_all_reports
  (p_rpt_flag    in boolean    default FALSE
  ,p_audit_log   in varchar2   default 'N')
is
  l_proc        varchar2(80) := g_package||'.submit_all_reports';
  l_actn        varchar2(80);
  l_request_id  number;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,05);
  --
  if fnd_global.conc_request_id <> -1 then
    --
    if upper(p_audit_log) = 'Y' then
      --
      l_actn := 'Calling ben_batch_utils.batch_report (BENCLAUD)...';
      --
      ben_batch_utils.batch_report
        (p_concurrent_request_id => fnd_global.conc_request_id
        ,p_program_name          => 'BENCLAUD'
        ,p_request_id            => l_request_id);
      --
    end if;
    --
    l_actn := 'Calling ben_batch_utils.batch_report (BENCLSUM)...';
    --
    ben_batch_utils.batch_report
      (p_concurrent_request_id => fnd_global.conc_request_id
      ,p_program_name          => 'BENCLSUM'
      ,p_request_id            => l_request_id);
    --
    -- Submit the generic error by error type and error by person reports.
    --
    ben_batch_reporting.batch_reports
      (p_concurrent_request_id => fnd_global.conc_request_id
      ,p_report_type           => 'ERROR_BY_ERROR_TYPE');
    --
    ben_batch_reporting.batch_reports
      (p_concurrent_request_id => fnd_global.conc_request_id
      ,p_report_type           => 'ERROR_BY_PERSON');
    --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
exception
  --
  when others then
    --
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag  => p_rpt_flag);
    --
    raise;
    --
end submit_all_reports;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< update_per_in_ler >-----------------------------|
-- -----------------------------------------------------------------------------
--
--  This procedure is called to update the per_in_ler record with the
--  appropriate status code (per_in_ler_stat_cd) when the enrollment
--  is to be closed.
--
procedure update_per_in_ler
  (p_per_in_ler_id         in number
  ,p_ler_id                in number
  ,p_person_id             in number
  ,p_effective_date        in date
  ,p_business_group_id     in number
  ,p_per_in_ler_stat_cd    in varchar2
  ,p_object_version_number in number
  ,p_datetrack_mode        in varchar2
  )
is
  --
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_object_version_number ben_per_in_ler.object_version_number%TYPE;
  l_proc varchar2(80):=g_package||'.update_per_in_ler';
  l_actn varchar2(80);
  l_dummy_dt date;
  l_procd_dt date;
  l_strtd_dt date;
  l_voidd_dt date;
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  l_object_version_number  := p_object_version_number;
  --
  -- No updates need to be done when the status code
  -- (p_per_in_ler_stat_cd) is null as the cursor would not have fetched
  -- the required rows.
  --
  if p_per_in_ler_stat_cd is NOT NULL then
    --
    --  Generate Communications
    --
    -- Update person life event
    --
    ben_person_life_event_api.update_person_life_event
      (p_validate                => FALSE
      ,p_per_in_ler_id           => p_per_in_ler_id
      ,p_per_in_ler_stat_cd      => p_per_in_ler_stat_cd
      ,p_object_version_number   => l_object_version_number
      ,p_effective_date          => p_effective_date
      ,p_business_group_id       => p_business_group_id
      ,p_program_application_id  => fnd_global.prog_appl_id
      ,p_program_id              => fnd_global.conc_program_id
      ,p_request_id              => fnd_global.conc_request_id
      ,p_program_update_date     => sysdate
      ,p_procd_dt                => l_procd_dt
      ,p_strtd_dt                => l_strtd_dt
      ,p_voidd_dt                => l_voidd_dt);
    --
    ben_generate_communications.main
      (p_person_id             => p_person_id
      ,p_per_in_ler_id         => p_per_in_ler_id
      ,p_ler_id                => p_ler_id
      ,p_business_group_id     => p_business_group_id
      ,p_proc_cd1              => 'CLSENRT'
      ,p_proc_cd2              => 'HPAPRTTDE'
      ,p_proc_cd3              => 'HPADPNTLC'
      ,p_effective_date        => p_effective_date
      ,p_source                => 'benclenr');
  --
    benutils.update_life_event_cache(p_open_and_closed => 'N');
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
exception
  --
  when others then
    --
        ben_batch_utils.rpt_error(p_proc=>l_proc, p_last_actn=>l_actn);
        raise;
    --
end update_per_in_ler;
--
-- -----------------------------------------------------------------------------
-- |----------------------< close_single_enrollment >--------------------------|
-- -----------------------------------------------------------------------------
--
-- This is the main procedure to be called by other modules and procedures
-- to close the enrollment for a particular per_in_ler_id.
--
procedure close_single_enrollment
  (p_per_in_ler_id           in     number
  ,p_effective_date          in     date
  ,p_business_group_id       in     number
  ,p_validate                in     boolean  default FALSE
  ,p_batch_flag              in     boolean  default FALSE
  ,p_person_action_id        in     Number   default NULL
  ,p_object_version_number   in     Number   default NULL
  ,p_audit_log               in     varchar2 default 'N'
  ,p_close_cd                in     varchar2 default NULL
  ,p_close_uneai_flag        in     varchar2
  ,p_uneai_effective_date    in     date
  )
is
  --
  -- Cursor to fetch the per_in_ler record and exclude unrestricted per_in_ler.
  --

  cursor c_pil
  is
  select pil.object_version_number
        ,pil.person_id
        ,pil.ler_id
        ,pil.lf_evt_ocrd_dt
	,ppf.business_group_id
	,pil.per_in_ler_stat_cd
    from ben_per_in_ler pil,
         per_all_people_f ppf,
         ben_ler_f ler
   where pil.per_in_ler_id = p_per_in_ler_id
     and pil.business_group_id  = p_business_group_id
     and pil.per_in_ler_stat_cd = 'STRTD'
     and ler.ler_id = pil.ler_id
     and ppf.person_id = pil.person_id
    and    p_effective_date
           between ppf.effective_start_date
           and     ppf.effective_end_date
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ler.typ_cd <>   'SCHEDDU';
  --
  -- Cursor to pick enrollment results for which prtt is no longer eligible.
  --
  cursor c_no_lngr_elig
  is
  select prtt_enrt_rslt_id,
         person_id,
         pgm_id,
         pl_id,
         oipl_id,
         object_version_number,
         ler_id
    from ben_prtt_enrt_rslt_f pen
   where pen.per_in_ler_id = p_per_in_ler_id
     and pen.no_lngr_elig_flag = 'Y'
     and nvl(pen.enrt_cvg_thru_dt, hr_api.g_eot) = hr_api.g_eot
     and pen.effective_end_date = hr_api.g_eot
     and pen.prtt_enrt_rslt_stat_cd is null
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date
     and pen.business_group_id = p_business_group_id;
  --
  l_person_id number(15);
  --
  -- Cursor to check pending approvals.
  --
  cursor c_get_pending_approvals is
             select 'Y'
             from wf_item_activity_statuses process ,
                  wf_process_activities activity ,
                  hr_api_transactions txn,
                  hr_api_transaction_steps step ,
                  hr_api_transaction_values vlv,
                  wf_item_attribute_values submit_attribute
             where activity.process_name = 'ROOT'
             and activity.process_item_type = activity.activity_item_type
             and activity.instance_id = process.process_activity
             and process.activity_status = 'ACTIVE'
             and txn.item_type = process.item_type
             and txn.item_key  = process.item_key
             and txn.selected_person_id = l_person_id
             and txn.transaction_id = step.transaction_id
             and step.api_name = 'BEN_PROCESS_COMPENSATION_W.PROCESS_API'
             and vlv.number_value is not null
             and submit_attribute.text_value = 'Y'
             and txn.item_type = submit_attribute.item_type
             and txn.item_key = submit_attribute.item_key
             and submit_attribute.name = 'TRAN_SUBMIT'
             and step.transaction_step_id = vlv.transaction_step_id
             and vlv.name = 'P_PER_IN_LER_ID'
             and vlv.number_value = p_per_in_ler_id;
  --
  cursor c_ler is
    select null
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.per_in_ler_id = p_per_in_ler_id
    and    pil.business_group_id = p_business_group_id
    and    ler.ler_id = pil.ler_id
    and    ler.business_group_id = p_business_group_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ler.typ_cd = 'SCHEDDU';

  --
  --Bug(2300866): Check cursor for closing the life event.
  --
  cursor  c_chk_epe_exists is
   select ELIG_PER_ELCTBL_CHC_ID,
          ELCTBL_FLAG
   from   ben_elig_per_elctbl_chc
   where  per_in_ler_id =p_per_in_ler_id
   and    business_group_id = p_business_group_id;
  --
  l_chk_epe_exists c_chk_epe_exists%rowtype;
  --
  -- Bug 2386000
  CURSOR c_lee_rsn_for_plan (c_ler_id number, c_pl_id number ) IS
      SELECT   leer.lee_rsn_id
      FROM     ben_lee_rsn_f leer,
               ben_popl_enrt_typ_cycl_f petc
      WHERE    leer.ler_id            = c_ler_id
      AND      leer.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN leer.effective_start_date
                   AND leer.effective_end_date
      AND      leer.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
      AND      petc.pl_id                 = c_pl_id
      AND      petc.enrt_typ_cycl_cd = 'L'                        -- life event
      AND      petc.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN petc.effective_start_date
                   AND petc.effective_end_date;
  --
  CURSOR c_lee_rsn_for_program (c_ler_id number, c_pgm_id number )IS
      SELECT   leer.lee_rsn_id
      FROM     ben_lee_rsn_f leer,
               ben_popl_enrt_typ_cycl_f petc
      WHERE    leer.ler_id            = c_ler_id
      AND      leer.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN leer.effective_start_date
                   AND leer.effective_end_date
      AND      leer.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
      AND      petc.pgm_id                = c_pgm_id
      AND      petc.enrt_typ_cycl_cd      = 'L'
      AND      petc.business_group_id     = p_business_group_id
      AND      p_effective_date BETWEEN petc.effective_start_date
                   AND petc.effective_end_date;
  --
  cursor c_min_max_enrt_dt(c_per_in_ler_id     number
                       ,c_business_group_id number)
  is
  select
        max(a.enrt_perd_end_dt),
        min(a.enrt_perd_strt_dt)
   from ben_pil_elctbl_chc_popl a
   where a.per_in_ler_id = c_per_in_ler_id
     and a.business_group_id = c_business_group_id
     and a.pil_elctbl_popl_stat_cd = 'STRTD';
  ---
  l_lee_rsn_id                number := null ;
  --
   -----Bug 8531750
cursor c_check_elctbl_chc(p_popl_id number) is
SELECT elctbl_flag
  FROM ben_elig_per_elctbl_chc epe1
 WHERE epe1.business_group_id = p_business_group_id
   AND epe1.pil_elctbl_chc_popl_id = p_popl_id
   AND epe1.elctbl_flag = 'Y';

l_check_elctbl_chc  c_check_elctbl_chc%rowtype;

cursor c_check_cur_enr(p_popl_id number) is
SELECT elctbl_flag
  FROM ben_elig_per_elctbl_chc epe
 WHERE epe.business_group_id = p_business_group_id
   AND epe.pil_elctbl_chc_popl_id = p_popl_id
   AND epe.crntly_enrd_flag = 'Y'
   AND epe.auto_enrt_flag = 'N';

l_check_cur_enr  c_check_cur_enr%rowtype;
l_no_dflt_flag   boolean := false;
-----Bug 8531750
  -- Cursor Pec related variable.
  --
  l_pec_rec               g_pel_rec;
  l_pec_cnt               binary_integer := 0;
  --
  -- Local Variables.
  --
  l_object_version_number number(15);
  l_ler_id                number(15);
  l_datetrack_mode        varchar2(80);
  l_actn                  varchar2(80);
  l_set_pel_stat_cd       boolean := FALSE;
  l_set_pil_stat_cd       boolean := FALSE;
  l_step                  integer := 0;
  l_dump_num              number(15);
  l_susp_flag             boolean;
  l_dflt_flag             boolean := FALSE;
  l_per_in_ler_cls        boolean := FALSE;
  l_stage                 varchar2(80);
  l_pers_ovn              number := p_object_version_number;
  l_enrt_cvg_end_dt_cd    hr_lookups.lookup_code%TYPE; -- UTF8   varchar2(30);
  l_rslt_eff_start_date   date;
  l_rslt_eff_end_date     date;
  l_lf_evt_ocrd_dt        date;
  l_min_enrt_perd_strt_dt date;
  l_max_enrt_perd_end_dt  date;
  --
  l_dummy_dt              date;
  l_dummy_num             number(15);
  l_dummy_varchar         varchar2(30);
  l_found                 varchar2(1);
  l_per_business_group_id per_all_people_f.business_group_id%type;
  --
  l_proc                  varchar2(80) := g_package||'.close_single_enrollment';
  l_dflt_enrt_date        date;
  l_pil_stat_cd           varchar2(30);
  l_auto_flag             boolean := FALSE;  --Bug 6144967
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Make sure all the mandatory input parameters are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'p_per_in_ler_id'
                            ,p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'p_effective_date'
                            ,p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'p_business_group_id'
                            ,p_argument_value => p_business_group_id);
  -- Add environment init procedure
  --
  -- Work out if we are being called from a concurrent program
  -- otherwise we need to initialize the environment
  --
  if fnd_global.conc_request_id = -1 then
    --
    ben_env_object.init(p_business_group_id  => p_business_group_id,
                        p_effective_date     => p_effective_date,
                        p_thread_id          => 1,
                        p_chunk_size         => 1,
                        p_threads            => 1,
                        p_max_errors         => 1,
                        p_benefit_action_id  => null);
    --
  end if;
  --
  --
  -- Issue a savepoint for validation mode.
  --
  savepoint close_enrollment;
  --
  -- if per_in_ler is unrestricted, do nothing
  open c_ler;
  fetch c_ler into l_dummy_varchar;
  if c_ler%found then
    close c_ler;
    return;
  end if;
  close c_ler;
  --
  open c_pil;
  fetch c_pil into l_object_version_number
                  ,l_person_id
                  ,l_ler_id
                  ,l_lf_evt_ocrd_dt
                  ,l_per_business_group_id
		  ,l_pil_stat_cd;
  --
  if c_pil%notfound then
    close c_pil;
    fnd_message.set_name('BEN','BEN_91272_PER_IN_LER_MISSING');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
    fnd_message.set_token('PERSON_ID',null);
    fnd_message.set_token('LER_ID',null);
    fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
    fnd_message.set_token('BG_ID',to_char(p_business_group_id));
    fnd_message.raise_error;
  end if;
  --
  close c_pil;
  --
  if p_batch_flag then
    --
    -- 2205261 : CWB Change : Pass the persons business group
    -- Which could be different from business group id on per in ler
    -- for CWB data.
    --
    ben_batch_utils.person_header
      (p_person_id         => l_person_id
      ,p_business_group_id => l_per_business_group_id
      ,p_effective_date    => p_effective_date);
    --
    ben_batch_utils.ini('COMP_OBJ');
    --
  end if;
  --
  --- Check the Enmrt Closeing date is between  the  min and max of enreollment period
  --- if not  through the error
  /*  Phil wanted to talk with Fido before maing any changes. so the fix will wait
      till phil get info from Fido
  open c_min_max_enrt_dt(p_per_in_ler_id,p_business_group_id );
  fetch c_min_max_enrt_dt into  l_min_enrt_perd_strt_dt, l_max_enrt_perd_end_dt ;
  close c_min_max_enrt_dt ;

  if l_min_enrt_perd_strt_dt is not null and l_max_enrt_perd_end_dt is not null then
     if  not p_effective_date between l_min_enrt_perd_strt_dt and l_max_enrt_perd_end_dt then
        fnd_message.set_name('BEN','BEN_93111_ENRT_PERD_CLS_DT');
        fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
        fnd_message.set_token('ENRT_PERD_STRT_DT',l_min_enrt_perd_strt_dt);
        fnd_message.set_token('ENRT_PERD_END_DT',l_max_enrt_perd_end_dt);
        fnd_message.raise_error;
     end if ;
  end if ;
  */

  -- Loop through all the pil_elctbl_chc_popl records for the per_in_ler_id
  --
  for l_rec in gc_pel(c_per_in_ler_id     => p_per_in_ler_id
                     ,c_business_group_id => p_business_group_id)
  loop
    --
    l_pec_cnt   := l_pec_cnt + 1;
    l_set_pel_stat_cd := FALSE;
    l_dflt_flag := FALSE;
    l_auto_flag := FALSE;--Bug 6144967
    --
    l_pend_approvals := FALSE;
    --
    -- Test if pil elctbl chc popl is auto enrt in which case we can
    -- close the per in ler
    --
    l_dummy := 'N';
    open c_all_auto(l_rec.pil_elctbl_chc_popl_id);
      fetch c_all_auto into l_dummy;
    close c_all_auto;
    --
    if l_dummy = 'N' then
      --
      l_set_pel_stat_cd := TRUE;
      l_auto_flag := TRUE;   --Bug 6144967
      --
    elsif p_close_cd in ('FORCE', 'PRPENDTR') then  -- 1674123
      --
      -- PB : When open enrollment called from authentication form if a active
      -- life event exists and PSR opts closure of the active life event.
      --
      hr_utility.set_location('p_close_cd is : ' || p_close_cd, 5);
      --
      if p_close_cd = 'PRPENDTR' then
         --
         open c_get_pending_approvals;
         fetch c_get_pending_approvals into l_found;
         if c_get_pending_approvals%found then
            l_pend_approvals := TRUE;
         end if;
         close c_get_pending_approvals;
         --
         if l_pend_approvals then
            --
            -- If pending approvals exists for the person do
            -- not process any of the pil electble choice popls.
            --
            l_set_pel_stat_cd := FALSE;
            l_set_pil_stat_cd := FALSE;
            l_pec_cnt         := 0;

            if p_batch_flag then
              --
              ben_batch_utils.write( p_text =>
                          'Life event is not closed due to pending approvals.');
              --
            end if;

            exit;
            --
         end if;
         --
      end if;
      --
      ----Bug 8531750,check if the Life event has electability or not.
      l_no_dflt_flag := false;
      hr_utility.set_location('no default flag', 5);
      open c_check_elctbl_chc(l_rec.pil_elctbl_chc_popl_id);
      fetch c_check_elctbl_chc into l_check_elctbl_chc;
      if c_check_elctbl_chc%notfound then
         hr_utility.set_location('no electability', 5);
         open c_check_cur_enr(l_rec.pil_elctbl_chc_popl_id);
	 fetch c_check_cur_enr into l_check_cur_enr;
	    if c_check_cur_enr%found then
	       hr_utility.set_location('crntly enrd but no electability', 5);
	       l_no_dflt_flag := true;
	    end if;
	 close c_check_cur_enr;
      end if;
      close c_check_elctbl_chc;
      --------Bug 8531750
      if l_rec.elcns_made_dt is NULL and
         l_rec.dflt_enrt_dt is not null and
         l_rec.dflt_asnd_dt is null  and
	 not l_no_dflt_flag and   -----Bug 8531750
         not l_pend_approvals
      then
        --
        hr_utility.set_location('Defaults will be assigned', 5);
        --
        l_dflt_flag := TRUE;
        l_set_pel_stat_cd := TRUE;
        --
      else
        hr_utility.set_location('Elections have been made or Defaults ' ||
                                'assigned or No Defaults required', 5);
        --
        l_set_pel_stat_cd := TRUE;
        --
      end if;
      --
    elsif l_rec.cls_enrt_dt_to_use_cd = 'ELCNSMADE' then
      --
      hr_utility.set_location('cls_enrt_dt_to_use_cd is ELCNSMADE', 10);
      --
      if l_rec.elcns_made_dt is not NULL then
        --
        hr_utility.set_location('Elections have been made', 10);
        --
        l_set_pel_stat_cd  := TRUE;
        --
      elsif l_rec.procg_end_dt is not null and
            l_rec.procg_end_dt <= p_effective_date then
        --
        -- Elections not made. Processing end date reached.
        --
        hr_utility.set_location('Elections not made. procg_end_dt reached', 10);
        --
        if l_rec.dflt_asnd_dt is not null then
          --
          -- The defaults have been assigned to the enrollment.
          --
          hr_utility.set_location('Defaults assigned.', 10);
          --
          l_set_pel_stat_cd  := TRUE;
          --
        else
          --
          -- Processing end date reached. Defaults not asigned.
          --
          hr_utility.set_location('Defaults not assigned.', 10);
          --
          if l_rec.dflt_enrt_dt is not null and
             l_rec.dflt_enrt_dt <= p_effective_date then
            --
            hr_utility.set_location('Defaults will be assigned', 10);
            --
            l_dflt_flag := TRUE;
            l_set_pel_stat_cd  := TRUE;
            --
          elsif l_rec.dflt_enrt_dt is NULL then
            --
            -- This comp-object does not need to be defaulted.
            --
            hr_utility.set_location('No action needed.', 10);
            --
            l_set_pel_stat_cd  := TRUE;
            --
          end if;
          --
        end if;
        --
      end if;
      --
    elsif l_rec.cls_enrt_dt_to_use_cd = 'ENRTPERDEND' then
      --
      hr_utility.set_location('cls_enrt_dt_to_use_cd is ENRTPERDEND', 10);
      --
      if l_rec.enrt_perd_end_dt is not null and
         l_rec.enrt_perd_end_dt <= p_effective_date then
        --
        hr_utility.set_location('Enrt perd over', 10);
        --
        if l_rec.elcns_made_dt is not Null or
           l_rec.dflt_asnd_dt is not null then
          --
          hr_utility.set_location('Enrt end dt reached. Either elections ' ||
                                  'have been made or enrt defaulted', 10);
          --
          l_set_pel_stat_cd  := TRUE;
          --
        elsif l_rec.dflt_enrt_dt is not null and
              l_rec.dflt_enrt_dt <= p_effective_date then
          --
          hr_utility.set_location('No defaults yet. Assigning defaults', 10);
          --
          l_dflt_flag := TRUE;
          l_set_pel_stat_cd  := TRUE;
          --
        elsif l_rec.dflt_enrt_dt is NULL then
          --
          -- This comp-object does not need to be defaulted.
          --
          hr_utility.set_location('No action needed.', 10);
          --
          l_set_pel_stat_cd  := TRUE;
          --
        end if;
        --
      elsif l_rec.enrt_perd_end_dt is NULL then
        --
        hr_utility.set_location('enrt_perd_end date is NULL', 10);
        --
        fnd_message.set_name('BEN','BEN_91903_ENRT_PERD_END_DT_NUL');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PIL_ELCTBL_CHC_POPL_ID',
                               to_char(l_rec.pil_elctbl_chc_popl_id));
        fnd_message.set_token('PERSON_ID',to_char(l_person_id));
        fnd_message.set_token('LER_ID',to_char(l_ler_id));
        fnd_message.set_token('BG_ID',to_char(p_business_group_id));
        fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
        fnd_message.raise_error;
        --
      end if;
      --
    elsif l_rec.cls_enrt_dt_to_use_cd = 'PROCGEND' then
      --
      hr_utility.set_location('cls_enrt_dt_to_use_cd is PROCGEND', 10);
      --
      if l_rec.procg_end_dt is not null and
         l_rec.procg_end_dt <= p_effective_date then
        --
        hr_utility.set_location('Processing end date reached.', 10);
        --
        if l_rec.elcns_made_dt is not null or
           l_rec.dflt_asnd_dt is not null then
          --
          --
          hr_utility.set_location('Enrt end dt reached. Either elections ' ||
                                  'have been made or enrt defaulted', 10);
          --
          l_set_pel_stat_cd := TRUE;
          --
        elsif l_rec.dflt_enrt_dt is not NULL and
              l_rec.dflt_enrt_dt <= p_effective_date then
          --
          hr_utility.set_location('No defaults yet. Assigning defaults', 10);
          --
          l_dflt_flag := TRUE;
          l_set_pel_stat_cd  := TRUE;
          --
        elsif (l_rec.dflt_enrt_dt is NULL) then
          --
          -- This comp-object does not need to be defaulted.
          --
          hr_utility.set_location('No action needed', 10);
          --
          l_set_pel_stat_cd := TRUE;
          --
        end if;
        --
      elsif l_rec.procg_end_dt is null then
        --
        hr_utility.set_location('Processing end date is null', 10);
        --
        fnd_message.set_name('BEN','BEN_91904_PROCG_END_DT_NULL');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PIL_ELCTBL_CHC_POPL_ID',
                               to_char(l_rec.pil_elctbl_chc_popl_id));
        fnd_message.set_token('PERSON_ID',to_char(l_person_id));
        fnd_message.set_token('LER_ID',to_char(l_ler_id));
        fnd_message.set_token('BG_ID',to_char(p_business_group_id));
        fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
        fnd_message.raise_error;
        --
      end if;
      --
    else
      --
      hr_utility.set_location('Invalid cls_enrt_dt_cd', 10);
      --
      fnd_message.set_name('BEN','BEN_91905_INVLD_CLS_ENRT_DT_CD');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('CLS_ENRT_DT_TO_USE_CD',
                               l_rec.cls_enrt_dt_to_use_cd);
        fnd_message.set_token('PIL_ELCTBL_CHC_POPL_ID',
                               to_char(l_rec.pil_elctbl_chc_popl_id));
      fnd_message.raise_error;
      --
    end if;
    --
    if l_set_pel_stat_cd = TRUE then
      --
     hr_utility.set_location('Setting pil_elcbl_chc_popl_stat to PROCD', 10);
      --

--Start Bug 6144967

   if (l_auto_flag) then

   	--Bug 6154180 : Removed the calls to  Process_Post_Enrollments

	 -- Calling Multi Rows Edit
	 --
	    Ben_PRTT_ENRT_RESULT_api.multi_rows_edit
	       (p_person_id           => l_person_id
	        ,p_effective_date     => p_effective_date
	        ,p_business_group_id  => p_business_group_id
	        ,p_pgm_id 	       => l_rec.pgm_id
	        ,p_per_in_ler_id      => p_per_in_ler_id
	        );

	 --
	 -- Invoke post result process.
	 --

	    Ben_proc_common_enrt_rslt.process_post_results
	     (p_person_id          => l_person_id
	     ,p_enrt_mthd_cd       => 'E'
	     ,p_effective_date     => p_effective_date
	     ,p_business_group_id  => p_business_group_id
	     ,p_validate           => FALSE
	     ,p_per_in_ler_id      => p_per_in_ler_id
	     );

    end if;
--End Bug 6144967

      ben_pil_elctbl_chc_popl_api.update_pil_elctbl_chc_popl
        (p_validate                   => p_validate
        ,p_pil_elctbl_chc_popl_id     => l_rec.pil_elctbl_chc_popl_id
        ,p_pil_elctbl_popl_stat_cd    => 'PROCD'
        ,p_business_group_id          => p_business_group_id
        ,p_object_version_number      => l_rec.object_version_number
        ,p_effective_date             => p_effective_date
	,p_defer_deenrol_flag         => l_rec.defer_deenrol_flag);
      --
      -- Set the flag to indicate that the record has been updated to PROCD.
      --
      l_rec.set_flag := 'Y';
      --
      --  Check COBRA eligibility.
      --
      if l_rec.pgm_id is not null then
        ben_cobra_requirements.chk_cobra_eligibility
          (p_per_in_ler_id     => p_per_in_ler_id
          ,p_person_id         => l_person_id
          ,p_pgm_id            => l_rec.pgm_id
          ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
          ,p_business_group_id => p_business_group_id
          ,p_effective_date    => p_effective_date
          ,p_validate          => p_validate
          );
       end if;
    end if;
    --
    if l_dflt_flag = TRUE then
      --
      hr_utility.set_location('Assign defaults', 10);
      --
      -- Bug 5407755
      -- Close enrollment date = nvl (  (     'Defaults will be assigned on',
      --                                   OR 'Days after Enrollment Period to Apply Defaults'
      --                                 ),
      --                               Enrollment Period End Date
      --                              )
      --
      l_dflt_enrt_date := nvl(l_rec.dflt_enrt_dt, l_rec.enrt_perd_end_dt);
      -----Bug 7133885
      if l_dflt_enrt_Date is null or p_close_cd = 'FORCE'
      then
        l_dflt_enrt_date := p_effective_date;
      end if;
      hr_utility.set_location('ACE l_Dflt_enrt_Date = ' || l_Dflt_enrt_Date, 9999);
      ben_manage_default_enrt.default_comp_obj
        (p_validate           => FALSE
        ,p_per_in_ler_id      => p_per_in_ler_id
        ,p_person_id          => l_person_id
        ,p_business_group_id  => p_business_group_id
        ,p_effective_date     => l_Dflt_enrt_Date
        ,p_pgm_id             => l_rec.pgm_id
        ,p_pl_nip_id          => l_rec.pl_id
        ,p_susp_flag          => l_susp_flag
        ,p_batch_flag         => p_batch_flag
        ,p_cls_enrt_flag      => FALSE);
      --
    end if;
    --
    -- Store the record into a pl/sql table structure.
    --
    l_pec_rec(l_pec_cnt) := l_rec;
    --
  end loop;-- <<end of gc_pel cursor loop>>
  --
  --Bug(2300866):Should allow to close the life event if the electable
  -- choice is not there or elctbl_flag is N
  --
  open  c_chk_epe_exists;
  fetch c_chk_epe_exists into l_chk_epe_exists;
  close c_chk_epe_exists;
  --
  hr_utility.set_location('l_set_pil_stat_cd = ' || 'FALSE' , 9999);
  hr_utility.set_location('l_pec_cnt = ' || to_char(l_pec_cnt), 9999);
  hr_utility.set_location('ELIG_PER_ELCTBL_CHC_ID = ' || l_chk_epe_exists.ELIG_PER_ELCTBL_CHC_ID, 9999);
  hr_utility.set_location('l_pil_stat_cd = ' || l_pil_stat_cd, 9999);
  --
  -- Third OR condition is for all PEL in PROCD and PIL in STRTD
  --
  if l_pec_cnt <> 0
  or (l_chk_epe_exists.ELIG_PER_ELCTBL_CHC_ID is NULL or l_chk_epe_exists.elctbl_flag <> 'Y')
  or ( l_pec_cnt = 0 and l_set_pil_stat_cd = FALSE
       and l_chk_epe_exists.ELIG_PER_ELCTBL_CHC_ID is NOT NULL
       and l_pil_stat_cd = 'STRTD' )
  then
    --
    l_set_pil_stat_cd := TRUE;
    --
    -- Loop through all the pil_elctbl_chc_popl records stored in the l_pec_rec.
    --
    if l_pec_cnt <> 0 then
     for i in 1..l_pec_cnt
     loop
      --
      -- If any of the records has not been set to PROCD then set the flag to
      -- FALSE so that the per_in_ler is not closed.
      --
       if l_pec_rec(i).set_flag = 'N' then
        --
        hr_utility.set_location('PEL not processed. ' ||
                                'Cannot set per_in_ler status to PROCD', 10);
        --
        l_set_pil_stat_cd := FALSE;
        --
        exit;
        --
       end if;
      --
     end loop;
    --
    end if;
    --
    if l_set_pil_stat_cd = TRUE then
      --
      -- All pel_elctbl_chc records have been processed. We can set per_in_ler.
      -- Loop through enrollments for which the prtt is no longer eligible and
      -- haven't been closed yet.
      --
      hr_utility.set_location('set_pil_stat_cd flag is TRUE', 10);
      --
      for rslt in c_no_lngr_elig
      loop
        --
        --Bug 2386000
        l_lee_rsn_id := null ;
        open c_lee_rsn_for_plan(rslt.ler_id, rslt.pl_id );
        fetch c_lee_rsn_for_plan into l_lee_rsn_id ;
        close c_lee_rsn_for_plan ;
        --
        if l_lee_rsn_id is null and rslt.pgm_id is not null then
          open c_lee_rsn_for_program(rslt.ler_id, rslt.pgm_id);
          fetch c_lee_rsn_for_program into l_lee_rsn_id ;
          close c_lee_rsn_for_program ;
        end if;
        --
        -- Get the enrt_cvg_end_dt code for the comp object.
        --
        ben_determine_date.rate_and_coverage_dates
          (p_which_dates_cd      => 'C'
          ,p_date_mandatory_flag => 'N'
          ,p_compute_dates_flag  => 'N'
          ,p_per_in_ler_id       => p_per_in_ler_id
          ,p_person_id           => rslt.person_id
          ,p_pgm_id              => rslt.pgm_id
          ,p_pl_id               => rslt.pl_id
          ,p_oipl_id             => rslt.oipl_id
          ,p_lee_rsn_id          => l_lee_rsn_id
          ,p_business_group_id   => p_business_group_id
          ,p_enrt_cvg_strt_dt    => l_dummy_dt
          ,p_enrt_cvg_strt_dt_cd => l_dummy_varchar
          ,p_enrt_cvg_strt_dt_rl => l_dummy_num
          ,p_rt_strt_dt          => l_dummy_dt
          ,p_rt_strt_dt_cd       => l_dummy_varchar
          ,p_rt_strt_dt_rl       => l_dummy_num
          ,p_enrt_cvg_end_dt     => l_dummy_dt
          ,p_enrt_cvg_end_dt_cd  => l_enrt_cvg_end_dt_cd
          ,p_enrt_cvg_end_dt_rl  => l_dummy_num
          ,p_rt_end_dt           => l_dummy_dt
          ,p_rt_end_dt_cd        => l_dummy_varchar
          ,p_rt_end_dt_rl        => l_dummy_num
          ,p_effective_date      => p_effective_date
          ,p_lf_evt_ocrd_dt      => null);
        --
        if nvl(l_enrt_cvg_end_dt_cd, '-1') <> 'WEM' then
          --
          -- The end date code is not 'when elections made'. Delete enrt.
          --
          hr_utility.set_location('End date cd not WEM. Deleting enrt', 10);
          --
          ben_prtt_enrt_result_api.delete_enrollment
            (p_validate                => p_validate
            ,p_per_in_ler_id           => p_per_in_ler_id
            ,p_prtt_enrt_rslt_id       => rslt.prtt_enrt_rslt_id
            ,p_business_group_id       => p_business_group_id
            ,p_effective_start_date    => l_rslt_eff_start_date
            ,p_effective_end_date      => l_rslt_eff_end_date
            ,p_object_version_number   => rslt.object_version_number
            ,p_effective_date          => p_effective_date
            ,p_datetrack_mode          => 'DELETE'
            ,p_multi_row_validate      => TRUE
            ,p_source                  => 'benclenr');
          --
        end if;
        --
      end loop; -- no_lngr_elig
      --
      -- Close unresolved actn items.
      --
      if p_close_uneai_flag='Y' then
        --
        hr_utility.set_location ('effectiv_date=' ||
             to_char(p_effective_date,'YYYY/MM/DD HH24:MI:SS'), 05);
        --
        hr_utility.set_location ('uneai_effectiv_date=' ||
             to_char(p_uneai_effective_date,'YYYY/MM/DD HH24:MI:SS'), 05);
        --
        ben_cls_unresolved_actn_item.cls_per_unresolved_actn_item
          (p_person_id            => l_person_id
          ,p_effective_date       => p_uneai_effective_date
          ,p_business_group_id    => p_business_group_id);
        --
      end if;
      --
      -- Update the per_in_ler's status code to PROCD
      -- only when called from close enrt process or BENDSPLE form
      -- not from default enrt process
      --
      if ( p_batch_flag = TRUE or nvl(p_close_cd,'xxx') = 'FORCE' )
      then
      --
	ben_newly_ineligible.defer_delete_enrollment
	  (p_per_in_ler_id	    => p_per_in_ler_id,
	   p_person_id		    => l_person_id,
	   p_business_group_id      => p_business_group_id,
	   p_effective_date         => p_effective_date
	   );
      --
     update_per_in_ler
        (p_per_in_ler_id          => p_per_in_ler_id
        ,p_ler_id                 => l_ler_id
        ,p_person_id              => l_person_id
        ,p_effective_date         => p_effective_date
        ,p_business_group_id      => p_business_group_id
        ,p_per_in_ler_stat_cd     => 'PROCD'
        ,p_object_version_number  => l_object_version_number
        ,p_datetrack_mode         => hr_api.g_correction);
      end if;
      --
      -- Update person life event logging information to show event was
      -- closed but also created electable choices which must have been
      -- automatic.
      --
      l_per_in_ler_cls := TRUE;
      --
      benutils.update_life_event_cache(p_open_and_closed => 'Y');
      --
    end if;
    --
  end if;
  --
  if p_validate = TRUE then
    --
    rollback to close_enrollment;
    --
  end if;
  --
  -- If the procedure was called from within the batch process, do additionional
  -- processing.
  --
  if p_batch_flag = TRUE then
    --
    g_persons_procd := g_persons_procd + 1;
    --
    -- Log person related info.
    --
    --
    write_person_category
      (p_per_in_ler_clsed  => l_per_in_ler_cls
      ,p_person_id         => l_person_id
      ,p_audit_log         => p_audit_log
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date);

    --
    -- Log pil_elctbl_popl info
    --
    write_pil_elctbl_popl
      (p_rec               => l_pec_rec
      ,p_cnt               => l_pec_cnt
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date);
    --
    -- Calling write_comp...
    --
    ben_batch_utils.write_comp
      (p_business_group_id    => p_business_group_id
      ,p_effective_date       => p_effective_date);
    --
    if p_person_action_id is not null then
      --
      -- update the person action status to processed.
      --
      ben_person_actions_api.update_person_actions
        (p_person_action_id      => p_person_action_id
        ,p_action_status_cd      => 'P'
        ,p_object_version_number => l_pers_ovn
        ,p_effective_date        => p_effective_date);
      --
    end if;
    --
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
exception
  --
  when others then
    --
    rollback to close_enrollment;
    --
    -- If called from a batch mode, do additional processing.
    --
    if p_batch_flag then
      --
      g_persons_errored := g_persons_errored + 1;
      --
      /* 666
              ben_batch_utils.write( p_text =>
                          'Life event is not closed due to pending approvals.');
      */
      write_pil_elctbl_popl
        (p_rec               => l_pec_rec
        ,p_cnt               => l_pec_cnt
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date);
      --
      ben_batch_utils.write_comp
        (p_business_group_id    => p_business_group_id
        ,p_effective_date       => p_effective_date);
      --
      ben_batch_utils.write_error_rec;
      --
      ben_batch_utils.rpt_error(p_proc => l_proc
                               ,p_last_actn => l_actn
                               ,p_rpt_flag    => false);
      --
      ben_batch_utils.write(p_text => benutils.g_banner_minus);
      --
      -- Update the person action status code to errored.
      --
      if p_person_action_id is not null then
        --
        ben_person_actions_api.update_person_actions
          (p_person_action_id      => p_person_action_id
          ,p_action_status_cd      => 'E'
          ,p_object_version_number => l_pers_ovn
          ,p_effective_date        => p_effective_date);
        --
      end if;
      --
      write_person_category(p_per_in_ler_clsed  => l_per_in_Ler_cls
                           ,p_person_id         => l_person_id
                           ,p_audit_log         => p_audit_log
                           ,p_error             => TRUE
                           ,p_business_group_id => p_business_group_id
                           ,p_effective_date    => p_effective_date);
      --
      benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
      --
      raise ben_batch_utils.g_record_error;
      --
    else
      fnd_message.raise_error;
    end if;
    --
end close_single_enrollment;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< do_multithread >-------------------------------|
-- -----------------------------------------------------------------------------
--
-- This is the main batch procedure to be called from the concurrent manager
-- or interactively to close all the un-resolved per_in_ler/Enrollment.
--
procedure do_multithread
  (errbuf                     out nocopy varchar2
  ,retcode                    out nocopy number
  ,p_validate              in     varchar2 default 'N'
  ,p_benefit_action_id     in     number
  ,p_thread_id             in     number
  ,p_effective_date        in     varchar2
  ,p_business_group_id     in     number
  ,p_audit_log             in     varchar2 default 'N')
is
  --
  -- Local variable declaration
  --
  l_effective_date         date;
  l_proc                   varchar2(80) := g_package || '.do_multithread';
  l_person_id              ben_person_actions.person_id%type;
  l_person_action_id       ben_person_actions.person_action_id%type;
  l_object_version_number  ben_person_actions.object_version_number%type;
  l_ler_id                 ben_person_actions.ler_id%type;
  l_range_id               ben_batch_ranges.range_id%type;
  l_record_number          number := 0;
  l_start_person_action_id number := 0;
  l_end_person_action_id   number := 0;
  l_actn                   varchar2(80);
  l_cnt                    number(5):= 0;
  l_validate               Boolean := FALSE;
  l_chunk_size             number;
  l_threads                number;
  --
  -- Cursor declarations
  --
  cursor c_range_thread
  is
  select ran.range_id
        ,ran.starting_person_action_id
        ,ran.ending_person_action_id
    from ben_batch_ranges ran
   where ran.range_status_cd = 'U'
     and ran.benefit_action_id  = p_benefit_action_id
     and rownum < 2
     for update of ran.range_status_cd;
  --
  cursor c_person_thread
  is
  select ben.person_id
        ,ben.person_action_id
        ,ben.object_version_number
        ,ben.ler_id
    from ben_person_actions ben
   where ben.benefit_action_id = p_benefit_action_id
     and ben.action_status_cd <> 'P'
     and ben.person_action_id between l_start_person_action_id
                                  and l_end_person_action_id
   order by ben.person_action_id;
  --
  cursor c_parameter
  is
  select *
    from ben_benefit_actions ben
   where ben.benefit_action_id = p_benefit_action_id;
  --
  l_parm c_parameter%rowtype;
  l_commit number;
  --
  -- start bug 3079317
  l_rec               benutils.g_active_life_event;
  l_env               ben_env_object.g_global_env_rec_type;
  l_per_rec           per_all_people_f%rowtype;
  l_encoded_message   varchar2(2000);
  l_app_short_name    varchar2(2000);
  l_message_name      varchar2(2000);
  g_rec               ben_type.g_report_rec;
  --
  -- end bug 3079317

begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  /*
  l_effective_date := to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date := to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR')
                             ,'DD/MM/RRRR');
  */
  l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
  --
  -- Put row in fnd_sessions
  --
  dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  l_actn := 'Calling benutils.get_parameter...';
  benutils.get_parameter(p_business_group_id  => p_business_group_id
                        ,p_batch_exe_cd       => 'BENCLENR'
                        ,p_threads            => l_threads
                        ,p_chunk_size         => l_chunk_size
                        ,p_max_errors         => g_max_person_err);
  --
  -- Set up benefits environment
  --
  ben_env_object.init(p_business_group_id => p_business_group_id,
                      p_effective_date    => l_effective_date,
                      p_thread_id         => p_thread_id,
                      p_chunk_size        => l_chunk_size,
                      p_threads           => l_threads,
                      p_max_errors        => g_max_person_err,
                      p_benefit_action_id => p_benefit_action_id);
  --
  g_persons_procd   := 0;
  g_persons_errored := 0;
  --
  ben_batch_utils.ini;
  --
  benutils.g_benefit_action_id := p_benefit_action_id;
  benutils.g_thread_id         := p_thread_id;
  --
  -- Fetch the parameters defined for the batch process.
  --
  open c_parameter;
  fetch c_parameter into l_parm;
  close c_parameter;
  --
  if p_validate = 'Y' then
    l_validate := TRUE;
  else
    l_validate := FALSE;
  end if;
  --
  -- Print the parameters to the log file.
  --
  ben_batch_utils.print_parameters
    (p_thread_id                => p_thread_id
    ,p_benefit_action_id        => p_benefit_action_id
    ,p_validate                 => p_validate
    ,p_business_group_id        => p_business_group_id
    ,p_effective_date           => l_effective_date
    ,p_person_id                => l_parm.person_id
    ,p_person_selection_rule_id => l_parm.person_selection_rl
    ,p_location_id              => l_parm.location_id
    ,p_ler_id                   => l_parm.ler_id
    ,p_mode                     => l_parm.mode_cd -- 1674123
    ,p_audit_log                => p_audit_log);
  --
  loop
    --
    open c_range_thread;
    fetch c_range_thread into l_range_id,
                              l_start_person_action_id,
                              l_end_person_action_id;
    --
    exit when c_range_thread%notfound;
    --
    close c_range_thread;
    --
    -- Update the range status code to processed 'P'
    --
    update ben_batch_ranges ran
       set ran.range_status_cd = 'P'
     where ran.range_id = l_range_id;
    --
    hr_utility.set_location('Updated range ' || to_char(l_range_id) ||
                            ' status code to P', 10);
    --
    commit;
    --
    -- Remove all records from cache
    --
    g_cache_per_proc.delete;
    --
    open c_person_thread;
    --
    l_record_number := 0;
    --
    hr_utility.set_location('Load person actions into the cache', 10);
    --
    loop
      --
      fetch c_person_thread into
            g_cache_per_proc(l_record_number+1).person_id
           ,g_cache_per_proc(l_record_number+1).person_action_id
           ,g_cache_per_proc(l_record_number+1).object_version_number
           ,g_cache_per_proc(l_record_number+1).ler_id;
      --
      exit when c_person_thread%notfound;
      --
      l_record_number := l_record_number + 1;
      --
      l_actn := 'Updating person_ations.';
      --
      update ben_person_actions
         set action_status_cd = 'T'
       where person_action_id = l_person_action_id;
      --
    end loop;
    --
    close c_person_thread;
    --
    commit;
    --
    if l_record_number > 0 then
      --
      for l_cnt in 1..l_record_number
      loop
        --
        hr_utility.set_location('Closing Enrollment for ' ||
                                to_char(g_cache_per_proc(l_cnt).person_id), 10);
        --
        begin
          --
          ben_close_enrollment.Close_Single_Enrollment
            (p_per_in_ler_id         => g_cache_per_proc(l_cnt).ler_id
            ,p_effective_date        => l_effective_date
            ,p_business_group_id     => p_business_group_id
            ,p_validate              => l_validate
            ,p_batch_flag            => TRUE
            ,p_person_action_id      => g_cache_per_proc(l_cnt).
                                        person_action_id
            ,p_object_version_number => g_cache_per_proc(l_cnt).
                                        object_version_number
            ,p_audit_log             => p_audit_log
            ,p_close_uneai_flag      => l_parm.close_uneai_flag
            ,p_close_cd              => l_parm.mode_cd -- 1674123
            ,p_uneai_effective_date  => l_parm.uneai_effective_date);
          --
        exception
          --
          when others then
          --
          -- start bug 3079317
	  ben_env_object.setenv(p_lf_evt_ocrd_dt => l_effective_date);
	  ben_env_object.get(p_rec => l_env);
	  ben_person_object.get_object(p_person_id => g_cache_per_proc(l_cnt).person_id,
				       p_rec       => l_per_rec);
	  --
	  l_encoded_message := fnd_message.get_encoded;
	  fnd_message.parse_encoded(encoded_message => l_encoded_message,
				    app_short_name  => l_app_short_name,
				    message_name    => l_message_name);

	  fnd_message.set_encoded(encoded_message => l_encoded_message);
	  --
	  g_rec.text := fnd_message.get ;
	  --
	  g_rec.error_message_code := nvl(l_message_name , nvl(g_rec.error_message_code,sqlcode));
	  g_rec.text := nvl(g_rec.text , nvl(g_rec.text,substr(sqlerrm,1,400)) );
	  g_rec.rep_typ_cd := 'ERROR';
	  g_rec.person_id := g_cache_per_proc(l_cnt).person_id;
	  g_rec.pgm_id := l_env.pgm_id;
	  g_rec.pl_id := l_env.pl_id;
	  g_rec.oipl_id := l_env.oipl_id;
	  g_rec.national_identifier := l_per_rec.national_identifier;
	  benutils.write(p_text => g_rec.text);
	  benutils.write(p_rec => g_rec);
          --
          update ben_person_actions
	  set action_status_cd = 'E'
	  where person_action_id = g_cache_per_proc(l_cnt).person_action_id;
	  --
          -- end bug 3079317
          --
          if g_persons_errored > g_max_person_err then
              fnd_message.raise_error;
          end if;
          --
        end;
        --
      end loop;
      --
    else
      --
      hr_utility.set_location('No records found. Erroring out.', 10);
      --
      l_actn := 'Reporting error since there is no record found';
      --
      fnd_message.set_name('BEN','BEN_91906_PER_NOT_FND_IN_RNG');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('BENEFIT_ACTION_ID',to_char(p_benefit_action_id));
      fnd_message.set_token('BG_ID',to_char(p_business_group_id));
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
      --
    end if;
    --
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    --
    commit;
    --
  end loop;
  --
  benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
  --
  commit;
  --
  l_actn := 'Calling log_beneadeb_statistics...';
  --
  ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_procd
                               ,p_num_pers_errored   => g_persons_errored);
  --
  hr_utility.set_location ('Leaving '||l_proc,70);
  --
exception
  --
  when others then
    --
    rollback;
    benutils.write(p_text => sqlerrm);
    --
    hr_utility.set_location('BENCLENR Super Error ' || l_proc, 10);
    --
    ben_batch_utils.rpt_error(p_proc       => l_proc
                             ,p_last_actn  => l_actn
                             ,p_rpt_flag   => TRUE);
    --
    ben_batch_utils.write_logfile(p_num_pers_processed => g_persons_procd
                                 ,p_num_pers_errored   => g_persons_errored);
    --
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP',l_actn );
    fnd_message.raise_error;
    --
end do_multithread;
--
-- -----------------------------------------------------------------------------
-- |----------------------------< restart >------------------------------------|
-- -----------------------------------------------------------------------------
--
procedure restart
  (errbuf                 out nocopy varchar2
  ,retcode                out nocopy number
  ,p_benefit_action_id in     number)
is
  --
  -- Cursor Declaration
  --
  cursor c_parameters
  is
  select -- to_char(process_date, 'YYYY/MM/DD HH24:MI:SS') process_date
        fnd_date.date_to_canonical(process_date) process_date
        ,business_group_id
        ,pgm_id
        ,pl_id
        ,location_id
        ,ler_id
        -- PB : 5422 :
        ,lf_evt_ocrd_dt
        -- ,popl_enrt_typ_cycl_id
        ,person_id
        ,person_selection_rl
        ,validate_flag
        ,debug_messages_flag
        ,audit_log_flag
        ,close_uneai_flag
        ,uneai_effective_date
        ,mode_cd  -- 1674123
    From ben_benefit_actions ben
   Where ben.benefit_action_id = p_benefit_action_id;
  --
  -- Local Variable declaration.
  --
  l_parameters  c_parameters%rowtype;
  l_errbuf      varchar2(80);
  l_retcode     number;
  l_actn        varchar2(80);
  --
  l_proc        varchar2(80) := g_package||'.restart';
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- get the parameters for a previous run and do a restart
  --
  open c_parameters;
  fetch c_parameters into l_parameters;
  --
  if c_parameters%notfound then
    --
    close c_parameters;
    fnd_message.set_name('BEN','BEN_91710_RESTRT_PARMS_NOT_FND');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.raise_error;
    --
  end if;
  --
  close c_parameters;
  --
  -- Call the process procedure with parameters for restart
  --
  Process
    (errbuf                     => l_errbuf
    ,retcode                    => l_retcode
    ,p_benefit_action_id        => p_benefit_action_id
    ,p_effective_date           => l_parameters.process_date
    ,p_validate                 => l_parameters.validate_flag
    ,p_business_group_id        => l_parameters.business_group_id
    ,p_pgm_id                   => l_parameters.pgm_id
    ,p_pl_nip_id                => l_parameters.pl_id
    ,p_location_id              => l_parameters.location_id
    ,p_ler_id                   => l_parameters.ler_id
    -- PB : 5422 :
    -- ,p_popl_enrt_typ_cycl_id    => l_parameters.popl_enrt_typ_cycl_id
    ,p_lf_evt_ocrd_dt           => fnd_date.date_to_canonical(l_parameters.lf_evt_ocrd_dt)
    ,p_person_id                => l_parameters.person_id
    ,p_debug_messages           => l_parameters.debug_messages_flag
    ,p_audit_log                => l_parameters.audit_log_flag
    ,p_close_uneai_flag         => l_parameters.close_uneai_flag
    ,p_close_cd                 => l_parameters.mode_cd        -- 1674123
    ,p_uneai_effective_date     => l_parameters.uneai_effective_date);
  --
  hr_utility.set_location ('Leaving '||l_proc,70);
  --
end restart;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< process >-----------------------------------|
-- -----------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------
-- This is the main batch procedure to be called from the concurrent manager
-- or interactively to close any enrollment has not been closed and close
-- per_in_ler as well.
-- -----------------------------------------------------------------------------
--
procedure process
  (errbuf                       out nocopy varchar2
  ,retcode                      out nocopy number
  ,p_benefit_action_id       in     number
  ,p_effective_date          in     varchar2
  ,p_business_group_id       in     number
  ,p_pgm_id                  in     number   default NULL
  ,p_pl_nip_id               in     number   default NULL
  ,p_location_id             in     number   default NULL
  ,p_ler_id                  in     number   default NULL
  -- 5422 : PB
  ,p_lf_evt_ocrd_dt          in     varchar2     default NULL
  -- ,p_popl_enrt_typ_cycl_id   in     number   default NULL
  ,p_Person_id               in     number   default NULL
  ,p_Person_selection_rl     in     number   default NULL
  ,p_validate                in     varchar2 default 'N'
  ,p_debug_messages          in     varchar2 default 'N'
  ,p_audit_log               in     varchar2 default 'N'
  ,p_uneai_effective_date    in     varchar2 default null
  ,p_close_uneai_flag        in     varchar2 default 'Y'
  ,p_close_cd                in     varchar2 default 'NORCLOSE' -- 1674123
  )
is
  --
  -- Local variable declaration.
  --
  l_uneai_effective_date   date;
  l_effective_date         date;
  l_person_ok              varchar2(30) := 'Y';
  l_person_actn_cnt        number(15) := 0;
  l_start_person_actn_id   number(15);
  l_end_person_actn_id     number(15);
  l_object_version_number  number(15);
  l_datetrack_mode         varchar2(80);
  l_actn                   varchar2(80);
  l_request_id             number(15);
  l_benefit_action_id      number(15);
  l_person_id              number(15);
  l_person_action_id       number(15);
  l_ler_id                 number(15);
  l_range_id               number(15);
  l_chunk_size             number := 20;
  l_chunk_num              number := 1;
  l_threads                number(5) := 1;
  l_step                   number := 0;
  l_num_ranges             number := 0;
  l_lf_evt_ocrd_dt         date;
  --
  -- Cursor Declaration.
  --
  cursor c_pil
  is
  select distinct pil.person_id
        ,pil.per_in_ler_id
    from ben_per_in_ler pil,
         per_all_people_f per,
         ben_ler_f ler
   where pil.business_group_id = p_business_group_id
     and pil.per_in_ler_stat_cd = 'STRTD'
     and pil.person_id         = per.person_id
     and pil.ler_id            = ler.ler_id
     --GSP changes
     --and ler.typ_cd not in ('GSP','COMP','SCHEDDU','ABS', 'IREC')  /* Bug 3981328 : Added Code IREC */
     and l_effective_date between ler.effective_start_date and
                                  ler.effective_end_date
     and l_effective_date between per.effective_start_date and
                                  per.effective_end_date
     and ((p_ler_id is null and ler.typ_cd not in ('GSP','COMP','SCHEDDU','ABS', 'IREC')) or
          (pil.ler_id = p_ler_id and ler.typ_cd not in ('GSP','SCHEDDU','ABS', 'IREC')))
  --Bug 4193968: Added the following check to prevent closing of the enrollments if the
  -- Effective date is less than the life event occured date, in case the life event type is not 'Open'
     and ((ler.typ_cd  in('SCHEDDO')) or  (l_effective_date >= pil.lf_evt_ocrd_dt ))
  -- End Bug 4193968
     and (p_person_id is null or pil.person_id = p_person_id)
     and (p_lf_evt_ocrd_dt is null
          or exists (select null
                       from ben_pil_elctbl_chc_popl pel,
                            ben_enrt_perd enp
                      where pel.per_in_ler_id = pil.per_in_ler_id
                        and pel.enrt_perd_id = enp.enrt_perd_id
                        and enp.asnd_lf_evt_dt  = l_lf_evt_ocrd_dt
                        and pel.pil_elctbl_popl_stat_cd = 'STRTD' ))
     /* PB : 5422 :
     and (p_popl_enrt_typ_cycl_id is null
          or exists (select null
                       from ben_pil_elctbl_chc_popl pel
                      where pel.per_in_ler_id = pil.per_in_ler_id
                        and pel.enrt_perd_id = p_popl_enrt_typ_cycl_id
                        and pel.pil_elctbl_popl_stat_cd = 'STRTD' ))
     */
     and (p_location_id is null
          or exists(select null
                     from per_all_assignments_f paf
                    where paf.person_id = pil.person_id
                      and paf.assignment_type <> 'C'
                      and paf.location_id = p_location_id
                      and paf.primary_flag = 'Y'
                      and l_effective_date between
                          paf.effective_start_date and paf.effective_end_date))
    and (p_pgm_id is null
         or exists(select null
                     from ben_pil_elctbl_chc_popl pel
                    where pel.pgm_id = p_pgm_id
                      and pel.per_in_ler_id = pil.per_in_ler_id
                      and pel.pil_elctbl_popl_stat_cd = 'STRTD' ))
    and (p_pl_nip_id is null
         or exists(select null
                     from ben_pil_elctbl_chc_popl pel
                    where pl_id = p_pl_nip_id
                      and pel.per_in_ler_id = pil.per_in_ler_id
                      and pel.pgm_id is null
                      and pel.pil_elctbl_popl_stat_cd = 'STRTD' ));
  --
  -- Type declarations
  --
  Type Pil_a is table of C_pil%rowtype index by binary_integer;
  --
  l_pil_rec    pil_a;
  l_pil_cnt    binary_integer := 0;
  --
  l_proc       varchar2(80) := g_package||'.process';
  l_commit     number;
  --
  type g_number_table is varray(1000000) of number;
  --
  l_perid_va g_number_table := g_number_table();
  l_pilid_va g_number_table := g_number_table();

begin
  --
  hr_utility.set_location ('Entering ' || l_proc, 10);
  -- Bug 5857493
  if p_audit_log ='Y' then
     ben_batch_utils.g_audit_flag := true;
  else
     ben_batch_utils.g_audit_flag := false;
  end if;
  --
  -- Convert varchar2 dates to real dates
  -- 1) First remove time component
  -- 2) Next convert format
  --
  /* BUG  4046914
  l_effective_date := to_date(p_effective_date
                             ,'YYYY/MM/DD HH24:MI:SS');
  --
  l_effective_date := to_date(to_char(trunc(l_effective_date)
                                     ,'DD/MM/RRRR'),'DD/MM/RRRR');
  l_lf_evt_ocrd_dt := to_date(p_lf_evt_ocrd_dt
                             ,'YYYY/MM/DD HH24:MI:SS');
  --
  l_lf_evt_ocrd_dt := to_date(to_char(trunc(l_lf_evt_ocrd_dt)
                                     ,'DD/MM/RRRR'),'DD/MM/RRRR');
  */
  l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
  l_lf_evt_ocrd_dt := trunc(fnd_date.canonical_to_date(p_lf_evt_ocrd_dt));
  --
  -- Put row in fnd_sessions
  --
     dt_fndate.change_ses_date
      (p_ses_date => l_effective_date,
       p_commit   => l_commit);
  --
  -- Now same for uneai_effecive_date
  --
  if p_uneai_effective_date is null then
    l_uneai_effective_date:=l_effective_date;
  else
    /*
    l_uneai_effective_date := to_date(p_uneai_effective_date
                                      ,'YYYY/MM/DD HH24:MI:SS');
    --
    l_uneai_effective_date := to_date(to_char(trunc(l_uneai_effective_date)
                                      ,'DD/MM/RRRR'),'DD/MM/RRRR');
    */
    l_uneai_effective_date := trunc(fnd_date.canonical_to_date(p_uneai_effective_date));
  end if;
  --
  -- Check business rules and mandatory parameters
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value => l_effective_date);
  --
  -- p_pgm_id and Pl_nip are mutually exclusive
  --
  if p_pgm_id is not null and p_pl_nip_id is not null then
    --
    fnd_message.set_name('BEN', 'BEN_91907_PGM_PL_MUTUAL_EXCL');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
    fnd_message.set_token('PL_NIP_ID',to_char(p_pl_nip_id));
    fnd_message.set_token('PERSON_ID',to_char(p_person_id));
    fnd_message.set_token('BG_ID',to_char(p_business_group_id));
    fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
    fnd_message.raise_error;
    --
  end if;
  --
  -- Initialize the batch process.
  --
  ben_batch_utils.ini(p_actn_cd => 'PROC_INFO');
  --
  -- Get the parameters defined for the batch process.
  --
  benutils.get_parameter
    (p_business_group_id   => p_business_group_id
    ,p_batch_exe_cd        => 'BENCLENR'
    ,p_threads             => l_threads
    ,p_chunk_size          => l_chunk_size
    ,p_max_errors          => g_max_person_err);
  --
  -- If p_benefit_action_id is null then this is a new batch process. Create the
  -- batch ranges and person actions. Else restart using the benefit_action_id.
  --
  if p_benefit_action_id is null then
    --
    -- Create a new benefit_action row.
    --
    ben_benefit_actions_api.create_benefit_actions
      (p_validate               => FALSE
      ,p_benefit_action_id      => l_benefit_action_id
      ,p_process_date           => l_effective_date
      ,p_mode_cd                => p_close_cd --  'S' -- 1674123
      -- 1674123 : This param is used to pass the close_cd.
      ,p_derivable_factors_flag => 'N'
      ,p_validate_flag          => p_validate
      ,p_person_id              => p_person_id
      ,p_person_type_id         => NULL
      ,p_pgm_id                 => p_pgm_id
      ,p_business_group_id      => p_business_group_id
      ,p_pl_id                  => p_pl_nip_id
      -- 5422 : PB :
      -- ,p_popl_enrt_typ_cycl_id  => p_popl_enrt_typ_cycl_id
      ,p_lf_evt_ocrd_dt         => l_lf_evt_ocrd_dt
      ,p_no_programs_flag       => 'N'
      ,p_no_plans_flag          => 'N'
      ,p_comp_selection_rl      => NULL
      ,p_person_selection_rl    => p_person_selection_rl
      ,p_ler_id                 => p_ler_id
      ,p_organization_id        => NULL
      ,p_benfts_grp_id          => NULL
      ,p_location_id            => p_location_id
      ,p_pstl_zip_rng_id        => NULL
      ,p_rptg_grp_id            => NULL
      ,p_pl_typ_id              => NULL
      ,p_opt_id                 => NULL
      ,p_eligy_prfl_id          => NULL
      ,p_vrbl_rt_prfl_id        => NULL
      ,p_legal_entity_id        => NULL
      ,p_payroll_id             => NULL
      ,p_audit_log_flag         => p_audit_log
      ,p_debug_messages_flag    => 'N'
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => l_effective_date
      ,p_request_id             => fnd_global.conc_request_id
      ,p_program_application_id => fnd_global.prog_appl_id
      ,p_program_id             => fnd_global.conc_program_id
      ,p_program_update_date    => sysdate
      ,p_uneai_effective_date   => l_uneai_effective_date
      ,p_close_uneai_flag       => p_close_uneai_flag
      --
      -- Bug No 4034201
      --
      ,p_ptnl_ler_for_per_stat_cd  => p_close_cd
    );
    --
    benutils.g_benefit_action_id := l_benefit_action_id;
    --
    benutils.g_thread_id         := 99;
    --
    l_actn := 'Removing batch ranges ';
    --
    delete from ben_batch_ranges
     where benefit_action_id = l_benefit_action_id;
    --
    -- Loop through rows in ben_per_in_ler_f based on the parameters passed and
    -- create person actions for the selected people.
    --
    open c_pil;
    fetch c_pil bulk collect into l_perid_va,l_pilid_va;
    close c_pil;
    --
    for i in 1..l_perid_va.COUNT
    loop
      --
      -- set variables for this iteration
      --
      l_person_ok := 'Y';
      --
      -- Check the person selection rule.
      --
      if p_person_selection_rl is not null then
        --
        l_person_ok := ben_batch_utils.person_selection_rule
                         (p_person_id                => l_perid_va(i)
                         ,p_business_group_id        => p_business_group_id
                         ,p_person_selection_rule_id => p_person_selection_rl
                         ,p_effective_date           => l_effective_date);
        --
      end if;
      --
      if l_person_ok = 'Y' then
        --
        -- Either no person sel rule or person selection rule passed. Create a
        -- person action row.
        --
        ben_person_actions_api.create_person_actions
          (p_validate              => FALSE
          ,p_person_action_id      => l_person_action_id
          ,p_person_id             => l_perid_va(i)
          ,p_ler_id                => l_pilid_va(i)
          ,p_benefit_action_id     => l_benefit_action_id
          ,p_action_status_cd      => 'U'
          ,p_chunk_number          => l_chunk_num
          ,p_object_version_number => l_object_version_number
          ,p_effective_date        => l_effective_date);
        --
        -- increment the person action count
        --
        l_person_actn_cnt := l_person_actn_cnt + 1;
        --
        -- Set the ending person action id to the last person action id that got
        -- created
        --
        l_end_person_actn_id := l_person_action_id;
        --
        -- We have to create batch ranges based on the number of person actions
        -- created and the chunk size defined for the batch process.
        --
        if mod(l_person_actn_cnt, l_chunk_size) = 1 or l_chunk_size = 1 then
          --
          -- This is the first person action id in a new range.
          --
          l_start_person_actn_id := l_person_action_id;
          --
        end if;
        --
        if mod(l_person_actn_cnt, l_chunk_size) = 0 or l_chunk_size = 1 then
          --
          -- The number of person actions that got created equals the chunk
          -- size. Create a batch range for the person actions.
          --
          ben_batch_ranges_api.create_batch_ranges
            (p_validate                  => FALSE
            ,p_effective_date            => l_effective_date
            ,p_benefit_action_id         => l_benefit_action_id
            ,p_range_id                  => l_range_id
            ,p_range_status_cd           => 'U'
            ,p_starting_person_action_id => l_start_person_actn_id
            ,p_ending_person_action_id   => l_end_person_actn_id
            ,p_object_version_number     => l_object_version_number);
          --
          l_num_ranges := l_num_ranges + 1;
          l_chunk_num := l_chunk_num + 1;
          --
        end if;
        --
      end if;
      --
    end loop;
    --
    -- There may be a few person actions left over from the loop above that may
    -- not have got inserted into a batch range because the number was less than
    -- the chunk size. Create a range for the remaining person actions. This
    -- also applies when only one person gets selected.
    --
    if l_person_actn_cnt > 0 and
       mod(l_person_actn_cnt, l_chunk_size) <> 0 then
      --
      ben_batch_ranges_api.create_batch_ranges
        (p_validate                  => FALSE
        ,p_effective_date            => l_effective_date
        ,p_benefit_action_id         => l_benefit_action_id
        ,p_range_id                  => l_range_id
        ,p_range_status_cd           => 'U'
        ,p_starting_person_action_id => l_start_person_actn_id
        ,p_ending_person_action_id   => l_end_person_actn_id
        ,p_object_version_number     => l_object_version_number);
      --
      l_num_ranges := l_num_ranges + 1;
      --
    end if;
    --
  Else
    --
    -- Benefit action id is not null i.e. the batch process is being restarted
    -- for a certain benefit action id. Create batch ranges and person actions
    -- for restarting.
    --
    l_benefit_action_id := p_benefit_action_id;
    --
    hr_utility.set_location('Restarting for benefit action id : ' ||
                            to_char(l_benefit_action_id), 10);
    --
    ben_batch_utils.create_restart_person_actions
      (p_benefit_action_id  => p_benefit_action_id
      ,p_effective_date     => l_effective_date
      ,p_chunk_size         => l_chunk_size
      ,p_threads            => l_threads
      ,p_num_ranges         => l_num_ranges
      ,p_num_persons        => l_person_actn_cnt);
    --
  end if;
  --
  commit;
  --
  -- Submit requests to the concurrent manager based on the number of ranges
  -- that got created.
  --
  if l_num_ranges > 1 then
    --
    hr_utility.set_location('More than one range got created.', 10);
    --
    --
    -- Set the number of threads to the lesser of the defined number of threads
    -- and the number of ranges created above. There's no point in submitting
    -- 5 threads for only two ranges.
    --
    l_threads := least(l_threads, l_num_ranges);
    --
    for l_count in 1..(l_threads - 1)
    loop
      --
      -- We are subtracting one from the number of threads because the main
      -- process will act as the last thread and will be able to keep track of
      -- the child requests that get submitted.
      --
      hr_utility.set_location('Submitting request ' || l_count, 10);
      --
      l_request_id := fnd_request.submit_request
                        (application => 'BEN'
                        ,program     => 'BENCLENRS'
                        ,description => NULL
                        ,sub_request => FALSE
                        ,argument1   => p_validate
                        ,argument2   => l_benefit_action_id
                        ,argument3   => l_count
                        ,argument4   => p_effective_date
                        ,argument5   => p_business_group_id
                        ,argument6   => p_audit_log );
      --
      -- Store the request id of the concurrent request
      --
      ben_batch_utils.g_num_processes := ben_batch_utils.g_num_processes + 1;
      ben_batch_utils.g_processes_tbl(ben_batch_utils.g_num_processes)
        := l_request_id;
      commit;
      --
    end loop;
    --
  elsif l_num_ranges = 0 then
    --
    -- No ranges got created. i.e. no people got selected. Error out.
    --
    ben_batch_utils.print_parameters
      (p_thread_id                => 99
      ,p_benefit_action_id        => l_benefit_action_id
      ,p_validate                 => p_validate
      ,p_business_group_id        => p_business_group_id
      ,p_effective_date           => l_effective_date
      ,p_person_id                => p_person_id
      ,p_person_selection_rule_id => p_person_selection_rl
      ,p_location_id              => p_location_id
      ,p_ler_id                   => p_ler_id
      ,p_mode                     => p_close_cd -- 1674123
      ,p_audit_log                => p_audit_log);
    --
    ben_batch_utils.write(p_text =>
                       'No person got selected with above selection criteria.');
    --
    fnd_message.set_name('BEN','BEN_91769_NOONE_TO_PROCESS');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.raise_error;
    --
  end if;
  --
  -- Carry on with the master. This will ensure that the master finishes last.
  --
  hr_utility.set_location('Submitting the master process', 10);
  --
  do_multithread
    (errbuf               => errbuf
    ,retcode              => retcode
    ,p_validate           => p_validate
    ,p_benefit_action_id  => l_benefit_action_id
    ,p_thread_id          => l_threads
    ,p_effective_date     => p_effective_date
    ,p_business_group_id  => p_business_group_id
    ,p_audit_log          => p_audit_log);
  --
  -- Check if all the slave processes are finished.
  --
  ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
  --
  -- End the process.
  --
  ben_batch_utils.end_process
    (p_benefit_action_id => l_benefit_action_id
    ,p_person_selected   => l_person_actn_cnt
    ,p_business_group_id => p_business_group_id);
  --
  -- Submit reports.
  --
  submit_all_reports(p_audit_log => p_audit_log);
  --
  hr_utility.set_location ('Leaving ' || l_proc, 10);
  --
exception
  --
  when others then
    --
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn
                             ,p_rpt_flag  => TRUE);
    --
    benutils.write(p_text => fnd_message.get);
    benutils.write(p_text => sqlerrm);
    benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
    --
    if l_num_ranges > 0 then
      --
      ben_batch_utils.check_all_slaves_finished(p_rpt_flag => TRUE);
      --
      ben_batch_utils.end_process(p_benefit_action_id => l_benefit_action_id
                                 ,p_person_selected   => l_person_actn_cnt
                                 ,p_business_group_id => p_business_group_id);
      --
      submit_all_reports(p_audit_log => p_audit_log);
      --
    end if;
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP', l_actn );
    fnd_message.raise_error;
   --
end process;
--
-- Bug : 1700853 : reopen the closed life event.
--
-- -----------------------------------------------------------------------------
-- |----------------------< reopen_single_life_event >-------------------------|
-- -----------------------------------------------------------------------------
--
-- This procedure to be called to open the single life event.
--
procedure reopen_single_life_event
  (p_per_in_ler_id           in     number
  ,p_person_id               in     number
  ,p_lf_evt_ocrd_dt          in     date
  ,p_effective_date          in     date
  ,p_business_group_id       in     number
  ,p_object_version_number   in     number
  ,p_validate                in     boolean  default FALSE
  ,p_source                  in     varchar2 default 'reopen' --Bug 5929635
  )
is
  --
  cursor c_get_future_per_in_ler is
    select null
    from ben_per_in_ler pil,
         ben_ler_f ler
    where pil.lf_evt_ocrd_dt > p_lf_evt_ocrd_dt
    and pil.person_id = p_person_id
    and ler.ler_id    = pil.ler_id
    and ler.typ_cd  not in ( 'COMP','SCHEDDU', 'ABS', 'GSP', 'IREC')   /* Bug 3981328 : Added Codes GSP, IREC, ABS */
    and pil.lf_evt_ocrd_dt between
        ler.effective_start_date and
        ler.effective_end_date
    and pil.business_group_id = p_business_group_id
    and pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT');
  --
  cursor c_get_pil_elctbl_chc_popl is
    select pel.*
    from ben_pil_elctbl_chc_popl pel
    where pel.per_in_ler_id = p_per_in_ler_id
    and   pel.business_group_id = p_business_group_id;
  --
  cursor c_get_cbr_per_in_ler is
    select crp.*
    from ben_cbr_per_in_ler crp
    where crp.per_in_ler_id = p_per_in_ler_id
    and   crp.business_group_id = p_business_group_id
    and   crp.init_evt_flag = 'N';
  --
  cursor c_get_cbr_quald_bnf(p_cbr_per_in_ler_id number) is
    select cqb.*
    from ben_cbr_quald_bnf cqb
        ,ben_cbr_per_in_ler crp
    where crp.cbr_per_in_ler_id = p_cbr_per_in_ler_id
    and   crp.cbr_quald_bnf_id = cqb.cbr_quald_bnf_id
    and   cqb.business_group_id = p_business_group_id
    and   cqb.business_group_id = crp.business_group_id;
  --
  --  Temporary until we add the reopen date.
  --
  cursor c_get_strtd_dt is
    select pil.*
    from ben_per_in_ler pil
    where pil.per_in_ler_id = p_per_in_ler_id
    and   pil.business_group_id = p_business_group_id;
  --
  -- Bug(2300866):Check cursor for Reopening Life Events
  -- Before reopening the life event need to have a check to see if
  -- the electable flag is 'Y' or whether a row there is a row in
  -- ben_elig_per_elctbl_chc table. If the row is not there raising a error
  -- Tilak : there can be first row is not eligible and secodn row is elctbl
  --- so it is neccessary to validate the elctbl flag 2
  cursor c_chk_reopen_lf_event is
  select ELIG_PER_ELCTBL_CHC_ID,
         ELCTBL_FLAG
  from   ben_elig_per_elctbl_chc
  where  per_in_ler_id =p_per_in_ler_id
   and   elctbl_flag   = 'Y'
  and    business_group_id = p_business_group_id;
  --
  l_chk_reopen_lf_event c_chk_reopen_lf_event%rowtype;
  --
  cursor c_enb(cv_per_in_ler_id number ) is
    select enb.enrt_bnft_id,
           enb.object_version_number,
           enb.business_group_id,
           epe.prtt_enrt_rslt_id
      from ben_elig_per_elctbl_chc epe,
           ben_enrt_bnft enb
     where epe.per_in_ler_id = cv_per_in_ler_id
       and epe.elig_per_elctbl_chc_id  = enb.elig_per_elctbl_chc_id
       and epe.prtt_enrt_rslt_id IS NOT NULL
       and enb.prtt_enrt_rslt_id IS NULL
       and exists ( select 'x' from ben_prtt_enrt_rslt_f pen
                     where pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
                       and pen.bnft_ordr_num     = enb.ordr_num
                       and pen.prtt_enrt_rslt_stat_cd is NULL
                       and pen.per_in_ler_id     = epe.per_in_ler_id ) ;
  --
  --
  l_proc                  varchar2(80) := g_package||'.reopen_single_life_event';
  l_exists                varchar2(1);
  l_object_version_number ben_per_in_ler.object_version_number%type;
  l_dummy_dt              date;
  l_procd_dt              date;
  l_strtd_dt              date;
  l_voidd_dt              date;
  l_pil_rec               c_get_strtd_dt%rowtype;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);

  --
  --Bug(2300866):Should not allow to reopen the bug
  --the prtspnt does not have any electable choices.
  --
  hr_utility.set_location('p_per_in_ler_id' || p_per_in_ler_id , 99 );

  open  c_chk_reopen_lf_event;
  fetch c_chk_reopen_lf_event into l_chk_reopen_lf_event;
  close c_chk_reopen_lf_event;

  --
	  if(l_chk_reopen_lf_event.ELIG_PER_ELCTBL_CHC_ID is NULL  and p_source = 'reopen') then  --Bug 5929635 : Do not raise error message if the call is in backout routine
	    fnd_message.set_name('BEN', 'BEN_93044_REOPEN_LF_EVNT');
	    fnd_message.raise_error;
	  end if;
  --

  --
  -- Step 1 : Check any future life events exists.
  -- if so return a warning message.
  --
  /*Bug 8604243: Added 'if' condition. While backing out a LE,if previous LE does not have
   electability and no enrollments results then per_in_ler_id of the LE for which enrollment results are ended is passed to the procedure
   In this case there will be future LE and error will be raised.Added 'if' condition so that control will not enter in the above
   scenario*/
   if ( ben_back_out_life_event.g_no_reopen_flag = 'N') then
	  open c_get_future_per_in_ler;
	  fetch c_get_future_per_in_ler into l_exists;

	  if c_get_future_per_in_ler%found then
	    close c_get_future_per_in_ler;
	    fnd_message.set_name('BEN', 'BEN_92711_LIFE_EVENT_EXISTS');
	    fnd_message.raise_error;
	  else
	    close c_get_future_per_in_ler;
	  end if;
   end if;
  --
  -- Step 2 : Open all the pil electable choice popl rows.
  --
  for l_pel_rec in c_get_pil_elctbl_chc_popl loop
          /*Bug 8604243: Added 'if' condition.*/
	  if ( ben_back_out_life_event.g_no_reopen_flag = 'N') then
	    ben_pil_elctbl_chc_popl_api.update_pil_elctbl_chc_popl
	      (p_validate                   => p_validate
	      ,p_pil_elctbl_chc_popl_id     => l_pel_rec.pil_elctbl_chc_popl_id
	      ,p_pil_elctbl_popl_stat_cd    => 'STRTD'
	      ,p_business_group_id          => p_business_group_id
	      ,p_object_version_number      => l_pel_rec.object_version_number
	      ,p_effective_date             => p_effective_date);
	  end if;
    --
    -- For COBRA participants, restore eligibility if it has been terminated.
    --
    if l_pel_rec.pgm_id is not null then
      --
      if (ben_cobra_requirements.chk_pgm_typ
            (p_pgm_id            => l_pel_rec.pgm_id
            ,p_effective_date    => p_effective_date
            ,p_business_group_id => p_business_group_id)
          ) then
        --
        --  Check if eligibility was terminated.
        --
        for l_crp_rec in c_get_cbr_per_in_ler loop
          --
          --  Restore eligibility.
          --
          for l_cqb_rec in c_get_cbr_quald_bnf(l_crp_rec.cbr_per_in_ler_id) loop
            --
            l_object_version_number := l_cqb_rec.object_version_number;
            --
            ben_cbr_quald_bnf_api.update_cbr_quald_bnf
              (p_validate              => false
              ,p_cbr_quald_bnf_id      => l_cqb_rec.cbr_quald_bnf_id
              ,p_cbr_elig_perd_end_dt  => l_crp_rec.prvs_elig_perd_end_dt
              ,p_cbr_inelg_rsn_cd      => null
              ,p_business_group_id     => p_business_group_id
              ,p_object_version_number => l_object_version_number
              ,p_effective_date        => p_effective_date
              );
            --
            -- Delete the cobra per_in_ler row.
            --
            ben_cbr_per_in_ler_api.delete_cbr_per_in_ler
              (p_validate              => false
              ,p_cbr_per_in_ler_id     => l_crp_rec.cbr_per_in_ler_id
              ,p_object_version_number => l_crp_rec.object_version_number
              ,p_effective_date        => p_effective_date
              );
          end loop;
        end loop;
      end if;
    end if;
    --
  end loop;
  --
  -- Step 3 : Open the per in ler row.
  --
  open c_get_strtd_dt;
  fetch c_get_strtd_dt into l_pil_rec;
  close c_get_strtd_dt;
  --
  l_object_version_number := p_object_version_number;
  --
   /*Bug 8604243: Added 'if' condition. While backing out the LE,if previous LE does not have
   electability and no enrollments results then previous LE status will not be updated to 'STRTD' status.*/
   if ( ben_back_out_life_event.g_no_reopen_flag = 'N') then
	  ben_person_life_event_api.update_person_life_event
	    (p_validate              => p_validate
	    ,p_per_in_ler_id         => p_per_in_ler_id
	    ,p_per_in_ler_stat_cd    => 'STRTD'
	    ,p_business_group_id     => p_business_group_id
	    ,p_object_version_number => l_object_version_number
	    ,p_effective_date        => l_pil_rec.strtd_dt
	    ,p_procd_dt              => l_procd_dt
	    ,p_strtd_dt              => l_strtd_dt
	    ,p_voidd_dt              => l_voidd_dt
	    );
  end if;
  --
  --Bug 3452376 fixes. We need to update the enrt_bnft with the pen id from
  --epe and valid result.
  --
  FOR l_enb IN c_enb(p_per_in_ler_id) LOOP
    --
    hr_utility.set_location ('manage_enrt_bnft '||l_enb.enrt_bnft_id,10);
    --
    ben_election_information.manage_enrt_bnft
      ( p_enrt_bnft_id               => l_enb.enrt_bnft_id,
        p_effective_date             => p_effective_date,
        p_object_version_number      => l_enb.object_version_number,
        p_business_group_id          => l_enb.business_group_id,
        p_prtt_enrt_rslt_id          => l_enb.prtt_enrt_rslt_id,
        p_creation_date              => null,
        p_created_by                 => null,
        p_per_in_ler_id              => p_per_in_ler_id
       );
    --
  END LOOP;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
end reopen_single_life_event;
--
--Selfservice wrapper to call close enrollment for closing a per in ler
--
procedure close_single_enrollment_ss
  (p_per_in_ler_id           in     number
  ,p_effective_date          in     date
  ,p_business_group_id       in     number
  ,p_validate                in     boolean  default FALSE
  ,p_batch_flag              in     boolean  default FALSE
  ,p_person_action_id        in     Number   default NULL
  ,p_object_version_number   in     Number   default NULL
  ,p_audit_log               in     varchar2 default 'N'
  ,p_close_cd                in     varchar2 default 'FORCE'
  ,p_close_uneai_flag        in     varchar2 default NULL
  ,p_uneai_effective_date    in     date     default NULL
  )
is
--
begin
--
close_single_enrollment
  (p_per_in_ler_id           =>p_per_in_ler_id
  ,p_effective_date          =>p_effective_date
  ,p_business_group_id       =>p_business_group_id
  ,p_validate                =>p_validate
  ,p_close_cd                =>p_close_cd
  ,p_close_uneai_flag        =>p_close_uneai_flag
  ,p_uneai_effective_date    =>p_uneai_effective_date
  );
--
commit;
exception
  when others then
    fnd_message.set_name('BEN', 'BEN_92988_CANT_CLS_ENRT');
--
end close_single_enrollment_ss;
--
procedure close_enrt_n_run_benmngle_ss
  (p_person_id               in     number
  ,p_mode                    in     varchar2 default 'L'
  ,p_per_in_ler_id           in     number
  ,p_effective_date          in     date
  ,p_run_date                in     date
  ,p_business_group_id       in     number
  ,p_validate                in     boolean  default FALSE
  ,p_batch_flag              in     boolean  default FALSE
  ,p_person_action_id        in     Number   default NULL
  ,p_object_version_number   in     Number   default NULL
  ,p_audit_log               in     varchar2 default 'N'
  ,p_close_cd                in     varchar2 default 'FORCE'
  ,p_close_uneai_flag        in     varchar2 default NULL
  ,p_uneai_effective_date    in     date     default NULL
  )
is
l_return_status varchar2(10) ;
--
begin
--
close_single_enrollment_ss
  (p_per_in_ler_id           =>p_per_in_ler_id
  ,p_effective_date          =>p_effective_date
  ,p_business_group_id       =>p_business_group_id
  ,p_validate                =>p_validate
  ,p_close_cd                =>p_close_cd
  ,p_close_uneai_flag        =>p_close_uneai_flag
  ,p_uneai_effective_date    =>p_uneai_effective_date
  );
--
ben_on_line_lf_evt.p_manage_life_events_w(
            p_person_id             =>p_person_id
           ,p_effective_date        =>p_run_date
           ,p_lf_evt_ocrd_dt        =>null
           ,p_business_group_id     =>p_business_group_id
           ,p_mode                  =>p_mode
	   ,p_return_status         =>l_return_status);
--
end close_enrt_n_run_benmngle_ss;
--
end ben_close_enrollment;

/
