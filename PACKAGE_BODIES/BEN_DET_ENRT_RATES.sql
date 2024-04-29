--------------------------------------------------------
--  DDL for Package Body BEN_DET_ENRT_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DET_ENRT_RATES" as
/* $Header: benraten.pkb 120.4.12010000.6 2009/03/26 11:37:17 sallumwa ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_det_enrt_rates.';
--
type t_enrt_rslt_tab is table of number index by binary_integer;
type t_enrt_rt_tab   is table of number index by binary_integer;
--
g_enrt_rslt_tab    t_enrt_rslt_tab;
g_enrt_rt_tab      t_enrt_rt_tab;
g_enrt_rslt_count  number default 0;
g_enrt_rt_count    number default 0;
--
--
-- Global variable maintainance. Used to idetify rates, which needs to
-- be processed.
-- Currently used by self-service but will be extended for professional
-- interface also.
--
procedure set_global_enrt_rslt
  (p_prtt_enrt_rslt_id   in number) is
begin
  g_enrt_rslt_count := g_enrt_rslt_count + 1;
  g_enrt_rslt_tab(g_enrt_rslt_count) := p_prtt_enrt_rslt_id;
end set_global_enrt_rslt;
--
procedure set_global_enrt_rt
  (p_enrt_rt_id          in number) is
begin
  g_enrt_rt_count := g_enrt_rt_count + 1;
  g_enrt_rt_tab(g_enrt_rt_count) := p_enrt_rt_id;
end set_global_enrt_rt;
--
function enrt_rslt_exists(p_prtt_enrt_rslt_id in number) return boolean is
begin
  if g_enrt_rslt_tab.count > 0 then
    for i in g_enrt_rslt_tab.first..g_enrt_rslt_tab.last loop
      if p_prtt_enrt_rslt_id = g_enrt_rslt_tab(i) then
        return true;
      end if;
    end loop;
  end if;
  --
  return false;
  --
end enrt_rslt_exists;
--
function enrt_rt_exists(p_enrt_rt_id in number) return boolean is
begin
  if g_enrt_rt_tab.count > 0 then
    for i in g_enrt_rt_tab.first..g_enrt_rt_tab.last loop
      if p_enrt_rt_id = g_enrt_rt_tab(i) then
        return true;
      end if;
    end loop;
  end if;
  --
  return false;
  --
end enrt_rt_exists;
--
procedure clear_globals is
begin
  g_enrt_rt_count   := 0;
  g_enrt_rslt_count := 0;
  g_enrt_rslt_tab.delete;
  g_enrt_rt_tab.delete;
end;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< p_det_enrt_rates >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure p_det_enrt_rates
  (p_calculate_only_mode in     boolean default false
  ,p_person_id           in     number
  ,p_per_in_ler_id       in     number
  ,p_enrt_mthd_cd        in     varchar2
  ,p_business_group_id   in     number
  ,p_effective_date      in     date
  ,p_validate            in     boolean
  ,p_self_service_flag   in     boolean default false
  --
  ,p_prv_rtval_set          out nocopy ben_det_enrt_rates.PRVRtVal_tab
  )
is
  --
  -- Cursor to fetch the enrt rslt for the participant
  --
  cursor c_enrt_rslt
    (c_person_id      in     number
    ,c_enrt_mthd_cd   in     varchar2
    ,c_per_in_ler_id  in     number
    ,c_effective_date in     date
    )
  is
    select pen.prtt_enrt_rslt_id,
           pen.pl_id,
           pen.pgm_id,
           pen.oipl_id,
           pen.enrt_cvg_strt_dt,
           pen.comp_lvl_cd
    from ben_prtt_enrt_rslt_f pen
    where pen.person_id          = c_person_id
--
-- Bug 6445880
-- Changed enrt_mthd_cd checks, to allow Default Enrollment records to be picked
-- up when Benefit elections are made using spreadsheet from Configuration
-- workbench in which case c_enrt_mthd_cd value will be 'E'
--
--    and ( pen.enrt_mthd_cd         = c_enrt_mthd_cd
--          or pen.enrt_mthd_cd         = 'O' ) -- Bug 2200139 Override Enhancements
    and (( pen.enrt_mthd_cd = c_enrt_mthd_cd  or pen.enrt_mthd_cd = 'O' )
           or (pen.enrt_mthd_cd <> c_enrt_mthd_cd
               and c_enrt_mthd_cd = 'E'
	       and (pen.enrt_mthd_cd = 'D'
	             or pen.enrt_mthd_cd = 'A')))
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.per_in_ler_id        = c_per_in_ler_id
    and enrt_cvg_thru_dt = hr_api.g_eot
    and pen.comp_lvl_cd <> 'PLANIMP'
    and c_effective_date
      between pen.effective_start_date and pen.effective_end_date
    and pen.effective_end_date = hr_api.g_eot
    and   -- start 4354929
      ( EXISTS ( select null
        from ben_ler_f ler,
	     ben_elig_per_elctbl_chc  epe
        where ler.ler_id = pen.ler_id
	and (( ler.typ_cd = 'SCHEDDU'
               and pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
               and epe.per_in_ler_id = c_per_in_ler_id )
	    or
             ( ler.typ_cd <> 'SCHEDDU'
               and epe.per_in_ler_id = c_per_in_ler_id)
	    )
               )--exists
       ) -- end 4354929
   order by pen.rplcs_sspndd_rslt_id;
  --
  l_enrt_rslt_rec         c_enrt_rslt%rowtype;
  --
  cursor c_rslt_pgm
    (c_person_id      in     number
    ,c_enrt_mthd_cd   in     varchar2
    ,c_per_in_ler_id  in     number
    ,c_effective_date in     date
    )
  is
    select distinct pen.pgm_id
    from ben_prtt_enrt_rslt_f pen
    where pen.person_id          = c_person_id
    and ( pen.enrt_mthd_cd         = c_enrt_mthd_cd
          or pen.enrt_mthd_cd         = 'O' ) -- Bug 2200139 Override Enhancements
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.per_in_ler_id        = c_per_in_ler_id
    and enrt_cvg_thru_dt = hr_api.g_eot
    and pen.comp_lvl_cd <> 'PLANIMP'
    and pen.pgm_id is not null
    and c_effective_date
      between pen.effective_start_date and pen.effective_end_date
    and pen.effective_end_date = hr_api.g_eot;
  --
  l_pgm_id          number;

  -- Cursor to check if the prtt is also enrolled in another pl/oipl that may
  -- qualify for a special rate.
  --
  cursor c_spcl_enrt_rslt(v_pl_id in number, v_oipl_id in number)
  is
  select '1'
    from ben_prtt_enrt_rslt_f pen
   where pen.person_id            = p_person_id
     and pen.business_group_id  = p_business_group_id
     and (pen.pl_id               = v_pl_id or
          pen.oipl_id             = v_oipl_id)
     and ( pen.enrt_mthd_cd         = p_enrt_mthd_cd      -- Bug 2200139 for Override
           or pen.enrt_mthd_cd         = 'O' )
     and pen.prtt_enrt_rslt_stat_cd is null
     and pen.sspndd_flag          = 'N'
     and enrt_cvg_thru_dt = hr_api.g_eot
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date
     and pen.effective_end_date = hr_api.g_eot;
  --
  -- Cursor to fetch the electable choice.
  --
  -- Added the union to get the choice when a person is enrolled in two
  -- benefits for the same plan (One can be suspeded and other interim)
  -- but different coverage amounts, then the choice record will have been
  -- updated by interim result's result id. So the only way left to get
  -- the choice for the suspended result is to go through the benefit record.
  -- (maagrawa 2/5/00)
  --
  cursor c_elctbl_chc(v_enrt_rslt_id in number)
  is
  select epe.pl_id,
         epe.oipl_id,
         epe.elig_per_elctbl_chc_id,
         epe.spcl_rt_pl_id,
         epe.spcl_rt_oipl_id,
         epe.fonm_cvg_strt_dt,
         pel.acty_ref_perd_cd
    from ben_elig_per_elctbl_chc  epe,
         ben_per_in_ler pil,
         ben_pil_elctbl_chc_popl  pel,
         ben_prtt_enrt_rslt_f pen
   where epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
     and pil.per_in_ler_id=epe.per_in_ler_id
     and pil.per_in_ler_id = p_per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     and pen.prtt_enrt_rslt_id=v_enrt_rslt_id
     and nvl(pen.pgm_id,-1)=nvl(epe.pgm_id,-1)
     and pen.pl_id=epe.pl_id
     and nvl(pen.oipl_id,-1)=nvl(epe.oipl_id,-1)
     -- added bnft prvdr pool id to fetch the electable choice related to the comp.object
     -- and prevent the one meant for flex credit - Bug#2177187- If flex credit is defined
     -- on combination plan type and option, the cursor returns two rows without prvdr pool
     -- id join
     and epe.bnft_prvdr_pool_id is null
     and pen.prtt_enrt_rslt_stat_cd is null
     and p_effective_date between
         pen.effective_start_date and pen.effective_end_date
;
  --
  l_epe_rec        c_elctbl_chc%rowtype;
  --
  -- Cursor to fetch the enrt rate for an elecbl chc.
  --
  cursor c_enrt_rt
    (c_elig_per_elctbl_chc_id in number
    ,c_prtt_enrt_rslt_id      in number
    )
  is
    select ecr.prtt_rt_val_id,
           ecr.enrt_rt_id,
           ecr.val,
           ecr.ann_val,
           ecr.rt_mlt_cd,
           ecr.acty_typ_cd,
           ecr.rt_strt_dt,
           ecr.acty_base_rt_id,
           to_char(null) cvg_mlt_cd
    from ben_enrt_rt  ecr
    where ecr.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
      and ecr.SPCL_RT_ENRT_RT_ID is null
      and ecr.entr_val_at_enrt_flag = 'N'
      and nvl(ecr.rt_strt_dt_cd,'AED') <> 'ENTRBL'  --Bug 3053267
      and ecr.asn_on_enrt_flag = 'Y'
      and ecr.rt_mlt_cd <> 'ERL'  -- added for canon fix
  UNION
    select ecr.prtt_rt_val_id,
           ecr.enrt_rt_id,
           ecr.val,
           ecr.ann_val,
           ecr.rt_mlt_cd,
           ecr.acty_typ_cd,
           ecr.rt_strt_dt,
           ecr.acty_base_rt_id,
           enb.cvg_mlt_cd cvg_mlt_cd
    from ben_enrt_bnft  enb,
         ben_enrt_rt    ecr
    where enb.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
      and enb.ENRT_BNFT_ID           = ecr.ENRT_BNFT_ID
      and enb.prtt_enrt_rslt_id      = c_prtt_enrt_rslt_id
      and ecr.SPCL_RT_ENRT_RT_ID is null
      and ecr.entr_val_at_enrt_flag = 'N'
      and nvl(ecr.rt_strt_dt_cd,'AED') <> 'ENTRBL'  --Bug 3053267
      and ecr.asn_on_enrt_flag = 'Y'
      and ecr.rt_mlt_cd <> 'ERL' ; -- added for canon fix
  --
  -- Cursor to fetch the special enrt rate for an enrt rate.
  --
  cursor c_spcl_enrt_rt(v_enrt_rt_id in number)
  is
  select ecr.prtt_rt_val_id,
           ecr.enrt_rt_id,
           ecr.val,
           ecr.ann_val,
           ecr.rt_mlt_cd,
           ecr.acty_typ_cd,
           ecr.rt_strt_dt,
           ecr.acty_base_rt_id,
           to_char(null) cvg_mlt_cd
    from ben_enrt_rt  ecr
    where ecr.spcl_rt_enrt_rt_id = v_enrt_rt_id
    and   ecr.entr_val_at_enrt_flag = 'N'
    and   ecr.asn_on_enrt_flag      = 'Y'
    and   ecr.business_group_id   = p_business_group_id;
  --
  l_spcl_rt_rec           c_spcl_enrt_rt%rowtype;
  l_use_enrt_rec          c_spcl_enrt_rt%rowtype;
  --
  -- Added this cursor to stop re-processing the flat-fixed (FLFX) rates,
  -- once they have been written. The only cases when the non-enterable
  -- rates should be re-written is when they have been deleted or voided.
  -- The cursor below takes care of it.  (maagrawa Mar 09, 2001)
  --
  cursor c_prv(v_prtt_enrt_rslt_id in number) is
     select prv.prtt_rt_val_id
     from   ben_prtt_rt_val prv
     where  prv.prtt_rt_val_id    = l_use_enrt_rec.prtt_rt_val_id
     and    prv.per_in_ler_id     = p_per_in_ler_id
     and    prv.prtt_enrt_rslt_id = v_prtt_enrt_rslt_id
     and    prv.mlt_cd = 'FLFX'
     and    prv.prtt_rt_val_stat_cd is null
     and    prv.rt_strt_dt       <= prv.rt_end_dt;
  --
  cursor c_prv2(p_prtt_enrt_rslt_id in number,
                p_acty_base_rt_id in number) is
    select prv.prtt_rt_val_id
      from ben_prtt_rt_val prv
     where prv.prtt_enrt_rslt_id  = p_prtt_enrt_rslt_id
       and acty_base_rt_id = p_acty_base_rt_id
       and prtt_rt_val_stat_cd is null;
  --
  cursor c_unrestricted is
                   select 'Y'
                   from   ben_per_in_ler pil,
                          ben_ler_f ler
                   where  pil.per_in_ler_id = p_per_in_ler_id
                   and    pil.ler_id = ler.ler_id
                   and    ler.typ_cd = 'SCHEDDU'
                   and    ler.business_group_id = p_business_group_id
                   and    p_effective_date between ler.effective_start_date
                          and ler.effective_end_date;

  --
  cursor c_rollover_plan is
    select decode(enb.enrt_bnft_id,
                    null, ecr2.enrt_rt_id,
                          ecr1.enrt_rt_id) enrt_rt_id,
           decode(enb.enrt_bnft_id,
                    null, ecr2.rt_mlt_cd,
                          ecr1.rt_mlt_cd) rt_mlt_cd,
	   decode(enb.enrt_bnft_id,
                    null, ecr2.entr_val_at_enrt_flag,
                          ecr1.entr_val_at_enrt_flag) entr_val_at_enrt_flag, --bug 5608160
           enb.enrt_bnft_id,
           nvl(enb.val, enb.dflt_val) bnft_val,
           epe.elig_per_elctbl_chc_id,
           pel.acty_ref_perd_cd,
           pen.prtt_enrt_rslt_id,
           pen.bnft_amt,
           pen.object_version_number,
           pen.pgm_id,
           pen.pl_id,
           pen.oipl_id
    from   ben_per_in_ler pil,
           ben_elig_per_elctbl_chc epe,
           ben_pil_elctbl_chc_popl pel,
           ben_enrt_rt ecr1,
           ben_enrt_rt ecr2,
           ben_enrt_bnft enb,
           ben_prtt_enrt_rslt_f pen,
           ben_bnft_prvdr_pool_f bpp -- join to get only current pgm_id - rgajula
    where
    pil.per_in_ler_id=p_per_in_ler_id and
           pil.business_group_id=p_business_group_id and
           pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
           pil.per_in_ler_id=epe.per_in_ler_id and
           pil.per_in_ler_id = pel.per_in_ler_id and
           pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id and
           epe.business_group_id=p_business_group_id and
           epe.elig_per_elctbl_chc_id=ecr2.elig_per_elctbl_chc_id(+) and
            bpp.bnft_prvdr_pool_id in (select bnft_prvdr_pool_id from ben_bnft_pool_rlovr_rqmt_f
		                       where business_group_id=p_business_group_id
		                       and p_effective_date between effective_start_date and effective_end_date) and
            bpp.business_group_id = p_business_group_id and                                    --
            p_effective_date between bpp.effective_start_date and bpp.effective_end_date and   --
            bpp.pgm_id = epe.pgm_id and                                                        --
            (ecr1.acty_base_rt_id in (select acty_base_rt_id from ben_bnft_pool_rlovr_rqmt_f
	                              where business_group_id=p_business_group_id
	                              and p_effective_date between effective_start_date and effective_end_date) or
            ecr2.acty_base_rt_id in (select acty_base_rt_id from ben_bnft_pool_rlovr_rqmt_f
	                             where business_group_id=p_business_group_id
                                     and p_effective_date between effective_start_date and effective_end_date)) and
           pen.prtt_enrt_rslt_id(+)=epe.prtt_enrt_rslt_id and
           epe.elig_per_elctbl_chc_id=enb.elig_per_elctbl_chc_id(+) and
           enb.enrt_bnft_id = ecr1.enrt_bnft_id(+) and
           pen.prtt_enrt_rslt_stat_cd is null  and
           p_effective_date between
           pen.effective_start_date(+) and pen.effective_end_date(+) and
           pen.business_group_id(+)=p_business_group_id ;
  --
  l_rollover_plan_rec     c_rollover_plan%rowtype;
  --
  l_prv_rec               c_prv%rowtype;
  --
  l_use_spcl_rates_flag   varchar2(1) := 'N';
  l_dummy                 varchar2(1);
  l_rate_amount           number;
  l_dummy_number          number;
  --
  l_prtt_enrt_rslt_id_pool number;
  l_prtt_rt_val_id_pool    number;
  l_acty_ref_perd_cd_pool  varchar2(30);
  l_acty_base_rt_id_pool   number;
  l_rt_strt_dt_pool        date;
  l_rt_val_pool            number;
  l_element_type_id_pool   number;
  L_BNFT_PRVDD_LDGR_ID     number;
  --
  l_prtt_rt_val_id         number;
  l_call_total_pools_flag  boolean := FALSE;
  --
  l_proc    varchar2(72) := g_package||'p_det_enrt_rates';
  --
  l_penecrloop_cnt         number;
  l_pgm_rec                ben_cobj_cache.g_pgm_inst_row;
  --
  l_process_this_result    boolean := true;
  l_process_this_rate      boolean := true;
  l_net_credit_method      boolean := false;
  l_unrestricted           varchar2(1) := 'N';
  l_prtt_rt_val_id2        number;
  --
begin
  --
  hr_utility.set_location(' Entering: '  ||l_proc , 10);
  --
  --
  open c_unrestricted;
  fetch c_unrestricted into l_unrestricted;
  close c_unrestricted;

  -- Loop through all the enrt rslt records for the person.
  --
  l_penecrloop_cnt := 0;
  --
  for l_enrt_rslt_rec in c_enrt_rslt
    (c_person_id      => p_person_id
    ,c_enrt_mthd_cd   => p_enrt_mthd_cd
    ,c_per_in_ler_id  => p_per_in_ler_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_process_this_result := true;
    --

    if p_self_service_flag and l_enrt_rslt_rec.comp_lvl_cd <> 'PLANFC' then --Bug 2736036 for Flex Plan enrt_rslts are not available
                                                                            --in global result table when an Update Enrt is done
      --
      -- Check if the result exists in the global result table.
      -- If not, go to next record.
      --
      l_process_this_result := enrt_rslt_exists
                                 (p_prtt_enrt_rslt_id =>
                                       l_enrt_rslt_rec.prtt_enrt_rslt_id);
      --
    end if;
    --
    if l_process_this_result then
      --
      -- Get the elctbl_chc id for the enrt rslt
      --
      open c_elctbl_chc(l_enrt_rslt_rec.prtt_enrt_rslt_id);
      fetch c_elctbl_chc into l_epe_rec;
      --

      if c_elctbl_chc%notfound then
        -- raise error
        close c_elctbl_chc;
        fnd_message.set_name('BEN','BEN_91491_NO_ELCTBL_CHC');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PERSON_ID',p_person_id);
        fnd_message.set_token('PRTT_ENRT_RSLT_ID',
                            l_enrt_rslt_rec.prtt_enrt_rslt_id);
        fnd_message.set_token('PER_IN_LER_ID',p_per_in_ler_id);
        fnd_message.raise_error;
        --
      else
        --
        close c_elctbl_chc;
        --
      end if;

      --
      -- If the person is enrolled in a flex program, we'll need to call
      -- total pools.
      --
      if not (l_call_total_pools_flag)
        and l_enrt_rslt_rec.pgm_id is not null then
        --
        ben_cobj_cache.get_pgm_dets(p_business_group_id=> p_business_group_id
         ,p_effective_date    => p_effective_date
         ,p_pgm_id            => l_enrt_rslt_rec.pgm_id
         ,p_inst_row          => l_pgm_rec);
        --
        if l_pgm_rec.pgm_typ_cd in ('COBRAFLX','FLEX', 'FPC') then
          l_call_total_pools_flag := TRUE;
        end if;
        --
      end if;
      --
      -- Check for special rates
      --
      if l_epe_rec.spcl_rt_pl_id   is not null
        or l_epe_rec.spcl_rt_oipl_id is not null then
        --
        -- The elctbl chc has a special rate for another plan or oipl. Check
        -- if the person is enrolled in that plan or oipl and if yes, we have
        -- to use special rates... set the l_use_spl_rates_flag to 'Y'
        --
        open c_spcl_enrt_rslt(l_epe_rec.pl_id, l_epe_rec.oipl_id);
        fetch c_spcl_enrt_rslt into l_dummy;
        --
        if c_spcl_enrt_rslt%found then
           --
           l_use_spcl_rates_flag := 'Y';
           --
        else
           --
           l_use_spcl_rates_flag := 'N';
           --
        end if;
        --
        close c_spcl_enrt_rslt;
        --
        hr_utility.set_location('spcl_rates_flag: ' || l_use_spcl_rates_flag
                               ||' ' || l_proc, 20);
        --
      end if;
      --
      -- Loop through the enrt rt records for the eltbl chc
      --
      -- only if net credit method then call election rate information for shell plan
      if l_enrt_rslt_rec.comp_lvl_cd = 'PLANFC' then
         for  l_enrt_rt_rec in c_enrt_rt
          (c_elig_per_elctbl_chc_id => l_epe_rec.elig_per_elctbl_chc_id
          ,c_prtt_enrt_rslt_id      => l_enrt_rslt_rec.prtt_enrt_rslt_id
          ) loop
              if l_enrt_rt_rec.acty_typ_cd in ('NCRDSTR','NCRUDED') then
                l_net_credit_method := TRUE;
                exit;
              end if;
          end loop;
      end if;
      --
      for l_enrt_rt_rec in c_enrt_rt
        (c_elig_per_elctbl_chc_id => l_epe_rec.elig_per_elctbl_chc_id
        ,c_prtt_enrt_rslt_id      => l_enrt_rslt_rec.prtt_enrt_rslt_id
        ) loop
             if l_enrt_rslt_rec.comp_lvl_cd = 'PLANFC' and not (l_net_credit_method) then
                exit;
             end if;
        --
        -- Initialize the record to be used to the normal enrt_rt record.
        --
        l_use_enrt_rec := l_enrt_rt_rec;
        --
        if l_epe_rec.fonm_cvg_strt_dt is not null then
           ben_manage_life_events.fonm := 'Y';
           ben_manage_life_events.g_fonm_rt_strt_dt := l_enrt_rt_rec.rt_strt_dt;
           ben_manage_life_events.g_fonm_cvg_strt_dt := l_epe_rec.fonm_cvg_strt_dt;
        else
           ben_manage_life_events.fonm := 'N';
           ben_manage_life_events.g_fonm_rt_strt_dt := null;
           ben_manage_life_events.g_fonm_cvg_strt_dt := null;
        end if;
        --
        -- Check if a special rate exists and try to use that.
        --
        if l_use_spcl_rates_flag = 'Y' then
          --
          open c_spcl_enrt_rt(l_enrt_rt_rec.enrt_rt_id);
          fetch c_spcl_enrt_rt into l_spcl_rt_rec;
          --
          if c_spcl_enrt_rt%found then
            --
            -- Since a special rate record was found, we have to use this rate
            -- record instead of the normal rate.
            --
            hr_utility.set_location('Using special rates : ' || l_proc, 20);
            --
            l_use_enrt_rec := l_spcl_rt_rec;

            if ben_manage_life_events.fonm = 'Y' then
               ben_manage_life_events.g_fonm_rt_strt_dt := l_spcl_rt_rec.rt_strt_dt;
            end if;
            --
          end if;
          --
          close c_spcl_enrt_rt;
          --
        end if;
        --
        l_process_this_rate := true;
        --
        if p_self_service_flag and l_enrt_rslt_rec.comp_lvl_cd <> 'PLANFC' then -- Bug 2736036, Rates associated with Flex Plan need to be
          --                                                                    -- recalculated even if they already exist in global rates table
          --
          -- Check if the enrollent rate exists in global rate table.
          -- If yes, then do not re-process that rate again.
          --
          -- Bug 3254982, if the rate is based on any ERL calculated "coverage or parent rate or both" then re-process the rate
          if (nvl(l_enrt_rt_rec.cvg_mlt_cd,'NULL') = 'ERL') and (l_enrt_rt_rec.rt_mlt_cd in ('CVG','PRNT','PRNTANDCVG')) then
              l_process_this_rate := true;
          else
            l_process_this_rate := not enrt_rt_exists
                                     (p_enrt_rt_id => l_use_enrt_rec.enrt_rt_id);
          end if;

	  for l_rollover_plan_rec in c_rollover_plan
	  loop
		  hr_utility.set_location('l_enrt_rslt_rec.pgm_id' || l_enrt_rslt_rec.pgm_id, 1234);
		  hr_utility.set_location('l_enrt_rslt_rec.pl_id' || l_enrt_rslt_rec.pl_id, 1234);
		  hr_utility.set_location('l_enrt_rslt_rec.oipl_id' || l_enrt_rslt_rec.oipl_id, 1234);

		  hr_utility.set_location('l_rollover_plan_rec.pgm_id' || l_rollover_plan_rec.pgm_id, 987);
		  hr_utility.set_location('l_rollover_plan_rec.pl_id' || l_rollover_plan_rec.pl_id, 987);
		  hr_utility.set_location('l_rollover_plan_rec.oipl_id' || l_rollover_plan_rec.oipl_id, 987);

		  if (nvl(l_enrt_rslt_rec.pgm_id,-1) = nvl(l_rollover_plan_rec.pgm_id,-1) and
		      nvl(l_enrt_rslt_rec.pl_id,-1)  = nvl(l_rollover_plan_rec.pl_id,-1) and
		      nvl(l_enrt_rslt_rec.oipl_id,-1)  = nvl(l_rollover_plan_rec.oipl_id,-1))then
		      l_process_this_rate := true;
		      exit;
		  end if;
          end loop;
          --
        end if;
        --
        if l_process_this_rate then
          --
          l_prv_rec.prtt_rt_val_id := null;
          --
          if l_use_enrt_rec.prtt_rt_val_id is not null then
            open  c_prv(v_prtt_enrt_rslt_id =>
                           l_enrt_rslt_rec.prtt_enrt_rslt_id);
            fetch c_prv into l_prv_rec;
            close c_prv;
          end if;
          --
          -- Check for calculate only mode. Do not re-calculate flat amounts
          -- rt_mlt_cd = FLFX
          --
          if p_calculate_only_mode
           and nvl(l_enrt_rt_rec.rt_mlt_cd,'ZZZ') = 'FLFX' then
            --
            p_prv_rtval_set(l_penecrloop_cnt).rt_val         := null;
            p_prv_rtval_set(l_penecrloop_cnt).ann_rt_val     := null;
            p_prv_rtval_set(l_penecrloop_cnt).prtt_rt_val_id :=
                                                l_enrt_rt_rec.prtt_rt_val_id;
            --
          else
            --
            -- Calculate Only Mode: Always call election_rate_information to
            --                      get the calulated value.
            -- Not Calculate  Mode: Call election_rate_information, only when
            --                      rate has not been already saved for the LE.
            --
         --   if p_calculate_only_mode or l_prv_rec.prtt_rt_val_id is null then
            hr_utility.set_location('Rate Code'||l_enrt_rt_rec.rt_mlt_cd ,112);
            if l_unrestricted = 'Y' and l_enrt_rt_rec.rt_mlt_cd = 'SAREC' then
               l_prtt_rt_val_id2 := null;
               open c_prv2 (l_enrt_rslt_rec.prtt_enrt_rslt_id, l_use_enrt_rec.acty_base_rt_id);
               fetch c_prv2 into l_prtt_rt_val_id2;
               close c_prv2;
            end if;
            hr_utility.set_location('Prtt rate val'||l_prtt_rt_val_id,111);
            if  not (l_prtt_rt_val_id2 is not null and
                      l_enrt_rt_rec.rt_mlt_cd = 'SAREC' and l_unrestricted = 'Y') then
              ben_election_information.election_rate_information
                (p_calculate_only_mode => p_calculate_only_mode
                ,p_enrt_mthd_cd        => p_enrt_mthd_cd
                ,p_effective_date      => p_effective_date
                ,p_prtt_enrt_rslt_id   => l_enrt_rslt_rec.prtt_enrt_rslt_id
                ,p_per_in_ler_id       => p_per_in_ler_id
                ,p_person_id           => p_person_id
                ,p_pgm_id              => l_enrt_rslt_rec.pgm_id
                ,p_pl_id               => l_enrt_rslt_rec.pl_id
                ,p_oipl_id             => l_enrt_rslt_rec.oipl_id
                ,p_enrt_rt_id          => l_use_enrt_rec.enrt_rt_id
                ,p_prtt_rt_val_id      => l_prtt_rt_val_id
                ,p_rt_val              => l_use_enrt_rec.val
                ,p_ann_rt_val          => l_use_enrt_rec.ann_val
                ,p_enrt_cvg_strt_dt    => l_enrt_rslt_rec.enrt_cvg_strt_dt
                ,p_acty_ref_perd_cd    => l_epe_rec.acty_ref_perd_cd
                ,p_datetrack_mode      => null
                ,p_business_group_id   => p_business_group_id
                --
                ,p_prv_rt_val          => p_prv_rtval_set(l_penecrloop_cnt).
                                                                  rt_val
                ,p_prv_ann_rt_val      => p_prv_rtval_set(l_penecrloop_cnt).
                                                                   ann_rt_val
                );
              --
              p_prv_rtval_set(l_penecrloop_cnt).prtt_rt_val_id :=
                                                           l_prtt_rt_val_id;
            end if;
            --
          end if;
          --
          p_prv_rtval_set(l_penecrloop_cnt).ecr_rt_mlt_cd :=
                                                  l_enrt_rt_rec.rt_mlt_cd;
          --
          l_penecrloop_cnt := l_penecrloop_cnt+1;
          --
        end if; -- if l_process_this_rate.
        --
      end loop;
      --
    end if; -- if l_process_this_result
    --
  end loop;
  --
  -- Clear the globals used by the procedure.
  --
  clear_globals;
  --
  -- write participant rates with rate multi code ERL
  for l_enrt_rslt_rec in c_enrt_rslt
    (c_person_id      => p_person_id
    ,c_enrt_mthd_cd   => p_enrt_mthd_cd
    ,c_per_in_ler_id  => p_per_in_ler_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    open c_elctbl_chc(l_enrt_rslt_rec.prtt_enrt_rslt_id);
    fetch c_elctbl_chc into l_epe_rec;
    --
    if c_elctbl_chc%notfound then
        -- raise error
        close c_elctbl_chc;
        fnd_message.set_name('BEN','BEN_91491_NO_ELCTBL_CHC');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PERSON_ID',p_person_id);
        fnd_message.set_token('PRTT_ENRT_RSLT_ID',
                            l_enrt_rslt_rec.prtt_enrt_rslt_id);
        fnd_message.set_token('PER_IN_LER_ID',p_per_in_ler_id);
        fnd_message.raise_error;
        --
    else
        --
      close c_elctbl_chc;
        --
    end if;
    --
    --
    det_enrt_rates_erl
      (p_person_id               => p_person_id
      ,p_per_in_ler_id           => p_per_in_ler_id
      ,p_enrt_mthd_cd            => p_enrt_mthd_cd
      ,p_business_group_id       => p_business_group_id
      ,p_effective_date          => p_effective_date
      ,p_elig_per_elctbl_chc_id  => l_epe_rec.elig_per_elctbl_chc_id
      ,p_fonm_cvg_strt_dt        => l_epe_rec.fonm_cvg_strt_dt
      ,p_prtt_enrt_rslt_id       => l_enrt_rslt_rec.prtt_enrt_rslt_id
      ,p_pgm_id                  => l_enrt_rslt_rec.pgm_id
      ,p_pl_id                   => l_enrt_rslt_rec.pl_id
      ,p_oipl_id                 => l_enrt_rslt_rec.oipl_id
      ,p_enrt_cvg_strt_dt        => l_enrt_rslt_rec.enrt_cvg_strt_dt
      ,p_acty_ref_perd_cd        => l_epe_rec.acty_ref_perd_cd
      );
  end loop;
  --
   ben_det_enrt_rates.end_prtt_rt_val
          (p_person_id => p_person_id
          ,p_per_in_ler_id => p_per_in_ler_id
          ,p_enrt_mthd_cd  =>p_enrt_mthd_cd
          ,p_business_group_id => p_business_group_id
          ,p_effective_date    => p_effective_date
          );


  -- Total credits.
  --
  if l_call_total_pools_flag
    and not p_calculate_only_mode
  then
    for l_enrt_rslt_rec in c_rslt_pgm
    (c_person_id      => p_person_id
    ,c_enrt_mthd_cd   => p_enrt_mthd_cd
    ,c_per_in_ler_id  => p_per_in_ler_id
    ,c_effective_date => p_effective_date
    )
    loop
    --
       ben_provider_pools.total_pools
         (p_validate          => FALSE
         ,p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id_pool
         ,p_prtt_rt_val_id    => l_prtt_rt_val_id_pool
         ,p_acty_ref_perd_cd  => l_acty_ref_perd_cd_pool
         ,p_acty_base_rt_id   => l_acty_base_rt_id_pool
         ,p_rt_strt_dt        => l_rt_strt_dt_pool
         ,p_rt_val            => l_rt_val_pool
         ,p_element_type_id   => l_element_type_id_pool
         ,p_person_id         => p_person_id
         ,p_per_in_ler_id     => p_per_in_ler_id
         ,p_enrt_mthd_cd      => p_enrt_mthd_cd
         ,p_effective_date    => p_effective_date
         ,p_business_group_id => p_business_group_id
         ,p_pgm_id            => l_enrt_rslt_rec.pgm_id
         );
     end loop;
    --
  end if;
  --
  hr_utility.set_location(' Leaving: '  ||l_proc , 10);
  --
  --
  /*
  ben_det_enrt_rates.end_prtt_rt_val
          (p_person_id => p_person_id
          ,p_per_in_ler_id => p_per_in_ler_id
          ,p_enrt_mthd_cd  =>p_enrt_mthd_cd
          ,p_business_group_id => p_business_group_id
          ,p_effective_date    => p_effective_date
          );
  */
exception
  --
  when others then
     hr_utility.set_location('Exception raised in ' || l_proc, 10);
     raise;
--
end p_det_enrt_rates;
--
procedure  end_prtt_rt_val
  (p_person_id           in     number
  ,p_per_in_ler_id       in     number
  ,p_enrt_mthd_cd        in     varchar2
  ,p_business_group_id   in     number
  ,p_effective_date      in     date
  )
is
 --
  cursor c_enrt_rslt
    (c_person_id      in     number
    ,c_enrt_mthd_cd   in     varchar2
    ,c_per_in_ler_id  in     number
    ,c_effective_date in     date
    )
  is
    select pen.prtt_enrt_rslt_id,
           pen.pl_id,
           pen.pgm_id,
           pen.oipl_id,
           pen.enrt_cvg_strt_dt,
           pen.comp_lvl_cd
    from ben_prtt_enrt_rslt_f pen
    where pen.person_id          = c_person_id
    and pen.enrt_mthd_cd         = c_enrt_mthd_cd
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.per_in_ler_id        = c_per_in_ler_id
    and enrt_cvg_thru_dt = hr_api.g_eot
    and pen.comp_lvl_cd not in ('PLANIMP','PLANFC')
    and c_effective_date
      between pen.effective_start_date and pen.effective_end_date
    and pen.effective_end_date = hr_api.g_eot
    and      -- start 4354929
      ( EXISTS ( select null
        from ben_ler_f ler,
	ben_elig_per_elctbl_chc  epe
        where ler.ler_id = pen.ler_id
	and (
	    ( ler.typ_cd = 'SCHEDDU'
              and pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
              and epe.per_in_ler_id = c_per_in_ler_id )
	    or
            ( ler.typ_cd <> 'SCHEDDU' and epe.per_in_ler_id = c_per_in_ler_id )
	   )--inner and
          )--exists
       )          -- end 4354929
    order by pen.pgm_id;
  --
  cursor c_prtt_rt_val (p_prtt_enrt_rslt_id in number)
  is
    select prv.prtt_rt_val_id,
           prv.acty_base_rt_id,
           prv.rt_strt_dt,
           prv.per_in_ler_id,
           prv.object_version_number
    from   ben_prtt_rt_val prv
    where  prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and    prv.rt_end_dt = hr_api.g_eot
    and    prv.prtt_rt_val_stat_cd is null;
  --
  cursor c_elctbl_chc(v_enrt_rslt_id in number)
  is
  select epe.pl_id,
         epe.oipl_id,
         epe.elig_per_elctbl_chc_id,
         epe.spcl_rt_pl_id,
         epe.spcl_rt_oipl_id,
         pel.acty_ref_perd_cd
    from ben_elig_per_elctbl_chc  epe,
         ben_pil_elctbl_chc_popl  pel,
         ben_prtt_enrt_rslt_f pen
   where epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
     and epe.per_in_ler_id = p_per_in_ler_id
     and pen.prtt_enrt_rslt_id=v_enrt_rslt_id
     and nvl(pen.pgm_id,-1)=nvl(epe.pgm_id,-1)
     and pen.pl_id=epe.pl_id
     and nvl(pen.oipl_id,-1)=nvl(epe.oipl_id,-1)
     and pen.prtt_enrt_rslt_stat_cd is null
     and epe.bnft_prvdr_pool_id is null
     and p_effective_date between
         pen.effective_start_date and pen.effective_end_date;
  --
  --Bug#3272320 - modified join condition
  cursor c_enrt_rt
    (c_elig_per_elctbl_chc_id in number
    ,c_acty_base_rt_id      in number
    )
  is
    select  DECR_BNFT_PRVDR_POOL_ID
    from ben_enrt_rt  ecr
    where ecr.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
      and ecr.asn_on_enrt_flag = 'Y'
     -- and ecr.prtt_rt_val_id = c_prtt_rt_val_id
      and ecr.acty_base_rt_id = c_acty_base_rt_id
  UNION
    select DECR_BNFT_PRVDR_POOL_ID
    from ben_enrt_bnft  enb,
         ben_enrt_rt    ecr
    where enb.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
      and enb.ENRT_BNFT_ID           = ecr.ENRT_BNFT_ID
      --and ecr.prtt_rt_val_id      = c_prtt_rt_val_id
      and ecr.asn_on_enrt_flag = 'Y'
      and ecr.acty_base_rt_id = c_acty_base_rt_id;
  --
  cursor c_prtt_enrt (p_pgm_id number) is
     select prtt_enrt_rslt_id
     from   ben_elig_per_elctbl_chc epe
     where  epe.per_in_ler_id = p_per_in_ler_id
     and    epe.comp_lvl_cd = 'PLANFC'
     and    epe.pgm_id      = p_pgm_id
     and    epe.business_group_id = p_business_group_id;

  --
   cursor c_ldgr_exist(p_prtt_enrt_rslt_id number
                      ,p_acty_base_rt_id number
                      ,p_per_in_ler_id number) is
    select bpl.bnft_prvdd_ldgr_id,
           bpl.object_version_number
    from ben_bnft_prvdd_ldgr_f bpl,
         ben_per_in_ler        pil
    where bpl.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and   bpl.acty_base_rt_id = p_acty_base_rt_id
    and   bpl.used_val is not null
    and   bpl.PRTT_RO_OF_UNUSD_AMT_FLAG = 'N'
    --and   bpl.per_in_ler_id = p_per_in_ler_id
    and   bpl.effective_end_date = hr_api.g_eot
    and   bpl.per_in_ler_id = pil.per_in_ler_id
    and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    and   p_effective_date between
          bpl.effective_start_date and bpl.effective_end_date;

  --
  cursor c_unrestricted is
                   select 'Y'
                   from   ben_per_in_ler pil,
                          ben_ler_f ler
                   where  pil.per_in_ler_id = p_per_in_ler_id
                   and    pil.ler_id = ler.ler_id
                   and    ler.typ_cd = 'SCHEDDU'
                   and    ler.business_group_id = p_business_group_id
                   and    p_effective_date between ler.effective_start_date
                          and ler.effective_end_date;
  --
  l_unrestricted   varchar2(30):= 'N';
  l_end_prtt_rt_val   boolean;
  l_epe_rec    c_elctbl_chc%rowtype;
  l_proc       varchar2(2000) := g_package||'End_prtt_rt_val';
  l_enrt_rt    varchar2(100);
  l_rt_end_dt  date;
  l_dummy_date   date;
  l_dummy_varchar  varchar2(200);
  l_dummy_number   number;
  l_DECR_BNFT_PRVDR_POOL_ID number;
  l_pgm_id         number := 0;
  l_prtt_enrt_rslt_id    number;
  l_ldgr_exist      c_ldgr_exist%rowtype;
  l_effective_start_date   date;
  l_effective_end_date     date;

  --
begin
  --
  hr_utility.set_location('Entering'||l_proc,10);
  open c_unrestricted;
  fetch c_unrestricted into l_unrestricted;
  close c_unrestricted;
  --
  for l_enrt_rslt_rec in c_enrt_rslt
    (c_person_id      => p_person_id
    ,c_enrt_mthd_cd   => p_enrt_mthd_cd
    ,c_per_in_ler_id  => p_per_in_ler_id
    ,c_effective_date => p_effective_date
    )
  loop
   --
    for l_prtt_rt_val in c_prtt_rt_val
       (l_enrt_rslt_rec.prtt_enrt_rslt_id)
      loop
        --
        l_end_prtt_rt_val := false;
           --  only in OSB per_in_ler_id will be same for more than one prtt_rt_val
           hr_utility.set_location('Inside Loop',11);


           --if l_unrestricted = 'Y' then
               open c_elctbl_chc(l_enrt_rslt_rec.prtt_enrt_rslt_id);
               fetch c_elctbl_chc into l_epe_rec;
               --
               if c_elctbl_chc%notfound then
                 -- raise error
                 close c_elctbl_chc;
                 fnd_message.set_name('BEN','BEN_91491_NO_ELCTBL_CHC');
                 fnd_message.set_token('PROC',l_proc);
                 fnd_message.set_token('PERSON_ID',p_person_id);
                 fnd_message.set_token('PRTT_ENRT_RSLT_ID',
                                     l_enrt_rslt_rec.prtt_enrt_rslt_id);
                 fnd_message.set_token('PER_IN_LER_ID',p_per_in_ler_id);
                 fnd_message.raise_error;
                 --
               else
                 --
                 close c_elctbl_chc;
                 --
               end if;
               --
               l_DECR_BNFT_PRVDR_POOL_ID := null;
               --Bug#3272320 - modified join condition
               open c_enrt_rt
                  (c_elig_per_elctbl_chc_id => l_epe_rec.elig_per_elctbl_chc_id
                  ,c_acty_base_rt_id         => l_prtt_rt_val.acty_base_rt_id
                   );
               fetch c_enrt_rt  into l_DECR_BNFT_PRVDR_POOL_ID;
               if c_enrt_rt%notfound then
                  l_end_prtt_rt_val := TRUE;
               end if;
               close c_enrt_rt;
               --
          --  end if;
       /*  else
            --
             open c_elctbl_chc(l_enrt_rslt_rec.prtt_enrt_rslt_id);
             fetch c_elctbl_chc into l_epe_rec;
              --
              if c_elctbl_chc%notfound then
                -- raise error
                close c_elctbl_chc;
                fnd_message.set_name('BEN','BEN_91491_NO_ELCTBL_CHC');
                fnd_message.set_token('PROC',l_proc);
                fnd_message.set_token('PERSON_ID',p_person_id);
                fnd_message.set_token('PRTT_ENRT_RSLT_ID',
                                    l_enrt_rslt_rec.prtt_enrt_rslt_id);
                fnd_message.set_token('PER_IN_LER_ID',p_per_in_ler_id);
                fnd_message.raise_error;
                --
              else
                --
                close c_elctbl_chc;
                --
              end if;
              l_end_prtt_rt_val := TRUE;
         end if;
         */
         --
         if l_pgm_id <> l_enrt_rslt_rec.pgm_id then
           --
           l_pgm_id := l_enrt_rslt_rec.pgm_id;
           --
           l_prtt_enrt_rslt_id := null;
           open c_prtt_enrt (l_enrt_rslt_rec.pgm_id);
           fetch c_prtt_enrt into l_prtt_enrt_rslt_id;
           close c_prtt_enrt;
           --
           --  hr_utility.set_location('Shell plan'||l_prtt_enrt_rslt_id,12);

         end if;
         --
         -- hr_utility.set_location('Decr pool id'||l_DECR_BNFT_PRVDR_POOL_ID,13);
         -- check for flex program
         if l_prtt_enrt_rslt_id is not null and
                      ((l_end_prtt_rt_val) or l_DECR_BNFT_PRVDR_POOL_ID is null) then
           -- delete the debit ledger entry as the application is end dated
           open c_ldgr_exist (l_prtt_enrt_rslt_id, l_prtt_rt_val.acty_base_rt_id,
                               l_prtt_rt_val.per_in_ler_id);
           fetch c_ldgr_exist into l_ldgr_exist;
           if c_ldgr_exist%found then
             --
              ben_Benefit_Prvdd_Ledger_api.delete_Benefit_Prvdd_Ledger(
                    p_bnft_prvdd_ldgr_id      => l_ldgr_exist.bnft_prvdd_ldgr_id,
                    p_effective_start_date    => l_effective_start_date,
                    p_effective_end_date      => l_effective_end_date,
                    p_object_version_number   => l_ldgr_exist.object_version_number,
                    p_effective_date          => (p_effective_date - 1),
                    p_datetrack_mode          => hr_api.g_delete,
                    p_business_group_id       => p_business_group_id
                    );
              --
           end if;
           close c_ldgr_exist;
           --

         end if;
         --

         if l_end_prtt_rt_val then
            -- end prtt_rt_val as the standard rate is not applicable any more
            ben_determine_date.rate_and_coverage_dates
            (p_which_dates_cd         => 'R'
            ,p_business_group_id      => p_business_group_id
            ,p_elig_per_elctbl_chc_id => l_epe_rec.elig_per_elctbl_chc_id
            ,p_enrt_cvg_strt_dt       => l_dummy_date
            ,p_enrt_cvg_strt_dt_cd    => l_dummy_varchar
            ,p_enrt_cvg_strt_dt_rl    => l_dummy_number
            ,p_rt_strt_dt             => l_dummy_date
            ,p_rt_strt_dt_cd          => l_dummy_varchar
            ,p_rt_strt_dt_rl          => l_dummy_number
            ,p_enrt_cvg_end_dt        => l_dummy_date
            ,p_enrt_cvg_end_dt_cd     => l_dummy_varchar
            ,p_enrt_cvg_end_dt_rl     => l_dummy_number
            ,p_rt_end_dt              => l_rt_end_dt
            ,p_rt_end_dt_cd           => l_dummy_varchar
            ,p_rt_end_dt_rl           => l_dummy_number
            ,p_acty_base_rt_id        => l_prtt_rt_val.acty_base_rt_id
            ,p_effective_date         => p_effective_date);
            --
              hr_utility.set_location('prtt rt val id'||l_prtt_rt_val.prtt_rt_val_id,11);
             ben_prtt_rt_val_api.update_prtt_rt_val
              (p_prtt_rt_val_id                => l_prtt_rt_val.prtt_rt_val_id
              ,p_rt_end_dt                     => l_rt_end_dt
              ,p_ended_per_in_ler_id           => p_per_in_ler_id
              ,p_person_id                     => p_person_id
              ,p_business_group_id             => p_business_group_id
              ,p_object_version_number         => l_prtt_rt_val.object_version_number
              ,p_effective_date                => p_effective_date
              );

         end if;
     End loop;  -- c_prtt_rt_val
     --
  End loop; -- c_prtt_enrt_rslt
  hr_utility.set_location('Leaving'||l_proc,10);

End ;

--
procedure end_prtt_rt_val
  (p_prtt_enrt_rslt_id   in     number
  ,p_person_id           in     number
  ,p_per_in_ler_id       in     number
  ,p_business_group_id   in     number
  ,p_effective_date      in     date
  )
is
  --
  cursor c_prtt_rt_val (p_prtt_enrt_rslt_id in number)
  is
    select prv.prtt_rt_val_id,
           prv.acty_base_rt_id,
           prv.rt_strt_dt,
           prv.per_in_ler_id,
           prv.object_version_number
    from   ben_prtt_rt_val prv
    where  prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and    prv.rt_end_dt = hr_api.g_eot
    and    prv.prtt_rt_val_stat_cd is null;
  --
  cursor c_elctbl_chc(v_enrt_rslt_id in number)
  is
  select epe.pl_id,
         epe.oipl_id,
         epe.elig_per_elctbl_chc_id,
         epe.spcl_rt_pl_id,
         epe.spcl_rt_oipl_id,
         pel.acty_ref_perd_cd
    from ben_elig_per_elctbl_chc  epe,
         ben_pil_elctbl_chc_popl  pel,
         ben_prtt_enrt_rslt_f pen
   where epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
     and epe.per_in_ler_id = p_per_in_ler_id
     and pen.prtt_enrt_rslt_id=v_enrt_rslt_id
     and nvl(pen.pgm_id,-1)=nvl(epe.pgm_id,-1)
     and pen.pl_id=epe.pl_id
     and nvl(pen.oipl_id,-1)=nvl(epe.oipl_id,-1)
     and pen.prtt_enrt_rslt_stat_cd is null
     and epe.bnft_prvdr_pool_id is null
     and p_effective_date between
         pen.effective_start_date and pen.effective_end_date;
   --
  --Bug#3272320 - modified join condition
  cursor c_enrt_rt
    (c_elig_per_elctbl_chc_id in number
    ,c_acty_base_rt_id      in number
    )
  is
    select  DECR_BNFT_PRVDR_POOL_ID
    from ben_enrt_rt  ecr
    where ecr.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
      and ecr.asn_on_enrt_flag = 'Y'
      and ecr.acty_base_rt_id = c_acty_base_rt_id
  UNION
    select DECR_BNFT_PRVDR_POOL_ID
    from ben_enrt_bnft  enb,
         ben_enrt_rt    ecr
    where enb.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
      and enb.ENRT_BNFT_ID           = ecr.ENRT_BNFT_ID
      and ecr.acty_base_rt_id = c_acty_base_rt_id
      and ecr.asn_on_enrt_flag = 'Y';
  --
  cursor c_rslt_pgm is
    select pen.pgm_id,
           pen.enrt_mthd_cd
    from   ben_prtt_enrt_rslt_f pen
    where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and  pen.prtt_enrt_rslt_stat_cd is null;
  --
  cursor c_prtt_enrt (p_pgm_id number) is
     select prtt_enrt_rslt_id
     from   ben_elig_per_elctbl_chc epe
     where  epe.per_in_ler_id = p_per_in_ler_id
     and    epe.comp_lvl_cd = 'PLANFC'
     and    epe.pgm_id      = p_pgm_id
     and    epe.business_group_id = p_business_group_id;

  --
   cursor c_ldgr_exist(p_prtt_enrt_rslt_id number
                      ,p_acty_base_rt_id number
                      ,p_per_in_ler_id number) is
    select bpl.bnft_prvdd_ldgr_id,
           bpl.object_version_number
    from ben_bnft_prvdd_ldgr_f bpl,
         ben_per_in_ler        pil
    where bpl.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and   bpl.acty_base_rt_id = p_acty_base_rt_id
    and   bpl.used_val is not null
    and   bpl.PRTT_RO_OF_UNUSD_AMT_FLAG = 'N'
    --and   bpl.per_in_ler_id = p_per_in_ler_id
    and   bpl.effective_end_date = hr_api.g_eot
    and   bpl.per_in_ler_id = pil.per_in_ler_id
    and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    and   p_effective_date between
          bpl.effective_start_date and bpl.effective_end_date;
   --
   cursor c_unrestricted is
                   select 'Y'
                   from   ben_per_in_ler pil,
                          ben_ler_f ler
                   where  pil.per_in_ler_id = p_per_in_ler_id
                   and    pil.ler_id = ler.ler_id
                   and    ler.typ_cd = 'SCHEDDU'
                   and    ler.business_group_id = p_business_group_id
                   and    p_effective_date between ler.effective_start_date
                          and ler.effective_end_date;
  --
  l_unrestricted   varchar2(30):= 'N';
  l_end_prtt_rt_val   boolean;
  l_epe_rec    c_elctbl_chc%rowtype;
  l_proc       varchar2(2000) := g_package||'End_prtt_rt_val';
  l_enrt_rt    varchar2(100);
  l_rt_end_dt  date;
  l_dummy_date   date;
  l_dummy_varchar  varchar2(200);
  l_dummy_number   number;
  l_DECR_BNFT_PRVDR_POOL_ID number;
  l_pgm_id         number := 0;
  l_prtt_enrt_rslt_id    number;
  l_ldgr_exist      c_ldgr_exist%rowtype;
  l_effective_start_date   date;
  l_effective_end_date     date;
  --
  l_prtt_enrt_rslt_id_pool number;
  l_prtt_rt_val_id_pool    number;
  l_acty_ref_perd_cd_pool  varchar2(30);
  l_acty_base_rt_id_pool   number;
  l_rt_strt_dt_pool        date;
  l_rt_val_pool            number;
  l_element_type_id_pool   number;
  L_BNFT_PRVDD_LDGR_ID     number;
  l_enrt_mthd_cd           varchar2(100);

  --
begin
  --
  hr_utility.set_location('Entering'||l_proc,11);
  open c_unrestricted;
  fetch c_unrestricted into l_unrestricted;
  close c_unrestricted;
  --
  open c_rslt_pgm;
  fetch c_rslt_pgm into l_pgm_id, l_enrt_mthd_cd;
  close c_rslt_pgm;
  --
  open c_prtt_enrt (l_pgm_id);
  fetch c_prtt_enrt into l_prtt_enrt_rslt_id;
  close c_prtt_enrt;
  --
  for l_prtt_rt_val in c_prtt_rt_val
       (p_prtt_enrt_rslt_id)
      loop
        --
        l_end_prtt_rt_val := false;

               open c_elctbl_chc(p_prtt_enrt_rslt_id);
               fetch c_elctbl_chc into l_epe_rec;
               --
               if c_elctbl_chc%notfound then
                 -- raise error
                 close c_elctbl_chc;
                 fnd_message.set_name('BEN','BEN_91491_NO_ELCTBL_CHC');
                 fnd_message.set_token('PROC',l_proc);
                 fnd_message.set_token('PRTT_ENRT_RSLT_ID',
                                     p_prtt_enrt_rslt_id);
                 fnd_message.set_token('PER_IN_LER_ID',p_per_in_ler_id);
                 fnd_message.raise_error;
                 --
               else
                 --
                 close c_elctbl_chc;
                 --
               end if;
               --
               l_DECR_BNFT_PRVDR_POOL_ID := null;
               --Bug#3272320 - modified join condition
               open c_enrt_rt
                  (c_elig_per_elctbl_chc_id => l_epe_rec.elig_per_elctbl_chc_id
                  ,c_acty_base_rt_id         => l_prtt_rt_val.acty_base_rt_id
                   );
               fetch c_enrt_rt  into l_DECR_BNFT_PRVDR_POOL_ID;
               if c_enrt_rt%notfound then
                  l_end_prtt_rt_val := TRUE;
               end if;
               close c_enrt_rt;
               --
          -- check for flex program
         if l_prtt_enrt_rslt_id is not null and
                      ((l_end_prtt_rt_val) or l_DECR_BNFT_PRVDR_POOL_ID is null) then
           -- delete the debit ledger entry as the application is end dated
           open c_ldgr_exist (l_prtt_enrt_rslt_id, l_prtt_rt_val.acty_base_rt_id,
                               l_prtt_rt_val.per_in_ler_id);
           fetch c_ldgr_exist into l_ldgr_exist;
           if c_ldgr_exist%found then
             --
              ben_Benefit_Prvdd_Ledger_api.delete_Benefit_Prvdd_Ledger(
                    p_bnft_prvdd_ldgr_id      => l_ldgr_exist.bnft_prvdd_ldgr_id,
                    p_effective_start_date    => l_effective_start_date,
                    p_effective_end_date      => l_effective_end_date,
                    p_object_version_number   => l_ldgr_exist.object_version_number,
                    p_effective_date          => (p_effective_date - 1),
                    p_datetrack_mode          => hr_api.g_delete,
                    p_business_group_id       => p_business_group_id
                    );
               --
               ben_provider_pools.total_pools
                        (p_validate          => FALSE
                        ,p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id_pool
                        ,p_prtt_rt_val_id    => l_prtt_rt_val_id_pool
                        ,p_acty_ref_perd_cd  => l_acty_ref_perd_cd_pool
                        ,p_acty_base_rt_id   => l_acty_base_rt_id_pool
                        ,p_rt_strt_dt        => l_rt_strt_dt_pool
                        ,p_rt_val            => l_rt_val_pool
                        ,p_element_type_id   => l_element_type_id_pool
                        ,p_person_id         => p_person_id
                        ,p_per_in_ler_id     => p_per_in_ler_id
                        ,p_enrt_mthd_cd      => l_enrt_mthd_cd
                        ,p_effective_date    => p_effective_date
                        ,p_business_group_id => p_business_group_id
                        ,p_pgm_id            => l_pgm_id
                        );
               --
            end if;
            close c_ldgr_exist;
           --

           end if;
           --

          if l_end_prtt_rt_val then
            -- end prtt_rt_val as the standard rate is not applicable any more
            ben_determine_date.rate_and_coverage_dates
            (p_which_dates_cd         => 'R'
            ,p_business_group_id      => p_business_group_id
            ,p_elig_per_elctbl_chc_id => l_epe_rec.elig_per_elctbl_chc_id
            ,p_enrt_cvg_strt_dt       => l_dummy_date
            ,p_enrt_cvg_strt_dt_cd    => l_dummy_varchar
            ,p_enrt_cvg_strt_dt_rl    => l_dummy_number
            ,p_rt_strt_dt             => l_dummy_date
            ,p_rt_strt_dt_cd          => l_dummy_varchar
            ,p_rt_strt_dt_rl          => l_dummy_number
            ,p_enrt_cvg_end_dt        => l_dummy_date
            ,p_enrt_cvg_end_dt_cd     => l_dummy_varchar
            ,p_enrt_cvg_end_dt_rl     => l_dummy_number
            ,p_rt_end_dt              => l_rt_end_dt
            ,p_rt_end_dt_cd           => l_dummy_varchar
            ,p_rt_end_dt_rl           => l_dummy_number
            ,p_acty_base_rt_id        => l_prtt_rt_val.acty_base_rt_id
            ,p_effective_date         => p_effective_date);
            --
             ben_prtt_rt_val_api.update_prtt_rt_val
              (p_prtt_rt_val_id                => l_prtt_rt_val.prtt_rt_val_id
              ,p_rt_end_dt                     => l_rt_end_dt
              ,p_ended_per_in_ler_id           => p_per_in_ler_id
              ,p_person_id                     => p_person_id
              ,p_business_group_id             => p_business_group_id
              ,p_object_version_number         => l_prtt_rt_val.object_version_number
              ,p_effective_date                => p_effective_date
              );

         end if;
     End loop;
    hr_utility.set_location('Leaving'||l_proc,12);

end;
--
procedure det_enrt_rates_erl
  (p_person_id              in     number
  ,p_per_in_ler_id          in     number
  ,p_enrt_mthd_cd           in     varchar2
  ,p_business_group_id      in     number
  ,p_effective_date         in     date
  ,p_elig_per_elctbl_chc_id in     number
  ,p_fonm_cvg_strt_dt       in     date default null
  ,p_prtt_enrt_rslt_id      in     number
  ,p_pgm_id                 in     number
  ,p_pl_id                  in     number
  ,p_oipl_id                in     number
  ,p_enrt_cvg_strt_dt       in     date
  ,p_acty_ref_perd_cd       in     varchar2
  )
is
  --

  cursor c_enrt_rt
    (c_elig_per_elctbl_chc_id in number
    ,c_prtt_enrt_rslt_id      in number
    )
  is
    select ecr.prtt_rt_val_id,
           ecr.enrt_rt_id,
           ecr.val,
           ecr.ann_val,
           ecr.rt_mlt_cd,
           ecr.acty_typ_cd,
           ecr.rt_strt_dt,
	   ecr.object_version_number, -----Bug 8214477
           ecr.acty_base_rt_id
    from ben_enrt_rt  ecr
    where ecr.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
      and ecr.SPCL_RT_ENRT_RT_ID is null
      and ecr.entr_val_at_enrt_flag = 'N'
      and ecr.asn_on_enrt_flag = 'Y'
      and ecr.rt_mlt_cd = 'ERL'
  UNION
    select ecr.prtt_rt_val_id,
           ecr.enrt_rt_id,
           ecr.val,
           ecr.ann_val,
           ecr.rt_mlt_cd,
           ecr.acty_typ_cd,
           ecr.rt_strt_dt,
	   ecr.object_version_number,    -----Bug 8214477
           ecr.acty_base_rt_id
    from ben_enrt_bnft  enb,
         ben_enrt_rt    ecr
    where enb.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
      and enb.ENRT_BNFT_ID           = ecr.ENRT_BNFT_ID
      and enb.prtt_enrt_rslt_id      = c_prtt_enrt_rslt_id
      and ecr.SPCL_RT_ENRT_RT_ID is null
      and ecr.entr_val_at_enrt_flag = 'N'
      and ecr.asn_on_enrt_flag = 'Y'
      and ecr.rt_mlt_cd = 'ERL';
 --
 l_use_enrt_rec    c_enrt_rt%rowtype;
 l_prv_rt_val      number;
 l_prv_ann_rt_val  number;
 l_prtt_rt_val_id         number;
 --
 -----Bug 8214477
 cursor c_prv(p_prtt_enrt_rslt_id number)
is
select prtt_rt_val_id, rt_strt_dt
from ben_prtt_rt_val prv, ben_per_in_ler pil
where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
and prv.rt_end_dt = hr_api.g_eot
and prv.per_in_ler_id = pil.per_in_ler_id
and prv.per_in_ler_id = p_per_in_ler_id --------- Bug 8342612
and pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD');

l_prv_rec c_prv%rowtype;
-----Bug 8214477
begin
 --
  for l_enrt_rt_rec in c_enrt_rt
     (c_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
     ,c_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
      ) loop
        --
        --
        l_use_enrt_rec := l_enrt_rt_rec;
        --
        if p_fonm_cvg_strt_dt is not null then
	-----Bug 8214477
	l_prv_rec := NULL;
	open c_prv(p_prtt_enrt_rslt_id);
	fetch c_prv into l_prv_rec;
	close c_prv;

	if l_prv_rec.rt_strt_dt is not NULL
	  and l_enrt_rt_rec.rt_strt_dt <> l_prv_rec.rt_strt_dt then
	 ben_enrollment_rate_api.update_enrollment_rate(
	 p_enrt_rt_id            => l_enrt_rt_rec.enrt_rt_id,
	 p_rt_strt_dt            => l_prv_rec.rt_strt_dt,
	 p_object_version_number => l_enrt_rt_rec.object_version_number,
	  p_effective_date        => p_effective_date
	  );

	 l_enrt_rt_rec.rt_strt_dt := l_prv_rec.rt_strt_dt;

	end if;
	------Bug 8214477
           ben_manage_life_events.fonm := 'Y';
           ben_manage_life_events.g_fonm_rt_strt_dt := l_enrt_rt_rec.rt_strt_dt;
           ben_manage_life_events.g_fonm_cvg_strt_dt := p_fonm_cvg_strt_dt;
        else
           ben_manage_life_events.fonm := 'N';
           ben_manage_life_events.g_fonm_rt_strt_dt := null;
           ben_manage_life_events.g_fonm_cvg_strt_dt := null;
        end if;

        ben_election_information.election_rate_information
        (p_enrt_mthd_cd        => p_enrt_mthd_cd
        ,p_effective_date      => p_effective_date
        ,p_prtt_enrt_rslt_id   => p_prtt_enrt_rslt_id
        ,p_per_in_ler_id       => p_per_in_ler_id
        ,p_person_id           => p_person_id
        ,p_pgm_id              => p_pgm_id
        ,p_pl_id               => p_pl_id
        ,p_oipl_id             => p_oipl_id
        ,p_enrt_rt_id          => l_use_enrt_rec.enrt_rt_id
        ,p_prtt_rt_val_id      => l_prtt_rt_val_id
        ,p_rt_val              => l_use_enrt_rec.val
        ,p_ann_rt_val          => l_use_enrt_rec.ann_val
        ,p_enrt_cvg_strt_dt    => p_enrt_cvg_strt_dt
        ,p_acty_ref_perd_cd    => p_acty_ref_perd_cd
        ,p_datetrack_mode      => null
        ,p_business_group_id   => p_business_group_id
        --
        ,p_prv_rt_val          => l_prv_rt_val
        ,p_prv_ann_rt_val      => l_prv_ann_rt_val
        );
        --
    --
  end loop;

End;
end ben_det_enrt_rates;

/
