--------------------------------------------------------
--  DDL for Package Body BEN_EFC_ADJUSTMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EFC_ADJUSTMENTS" as
/* $Header: beefcadj.pkb 115.27 2003/02/14 01:58:10 kmahendr noship $ */
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Author	   Comments
  ---------  ---------	---------- --------------------------------------------
  115.0      31-Jan-01	mhoyes     Created.
  115.1      01-Feb-01	mhoyes     Added PRV and EEV adjustment covers.
  115.2      06-Apr-01	mhoyes     Total revamp for patchset D.
  115.6      30-May-01	mhoyes     Leapfrogged 115.4 and re-applied
                                   changes in 115.5.
                                 - Enhanced for Patchset E.
  115.7      26-Jul-01	mhoyes     Enhanced for Patchset E+ patch.
  115.8      13-Aug-01	mhoyes     Enhanced for Patchset E+ patch.
  115.9      14-Aug-01	mhoyes     ECR tuning.
  115.10     17-Aug-01	mhoyes     Enhanced for BEN July patch.
  115.11     27-Aug-01	mhoyes     Enhanced for BEN July patch.
  115.12     31-Aug-01	mhoyes     Enhanced for BEN July patch.
  115.13     13-Sep-01	mhoyes     Enhanced for BEN July patch.
  115.14     19-Sep-01	mhoyes   - Backed out nocopy autonomous transaction
                                   because of deadlock. Could be
                                   8.1.7.1 bug.
  115.15     02-Oct-01	mhoyes     Enhanced for BEN F patchset.
  115.19     04-Jan-02	mhoyes     Enhanced for BEN G patchset.
  115.21     23-May-02  kmahendr   Added a parameter to ben_determine_acty_base_rt
  115.22     03-Jun-02  pabodla    Bug 2367556 : Changed STANDARD.bitand to just bitand
  115.23     03-Jun-02  pabodla    Added SET VERIFY OFF
  115.24     08-Jun-02  pabodla    Do not select the contingent worker
                                   assignment when assignment data is
                                   fetched.
  115.25     11-Oct-02  vsethi     Rates Sequence no enhancements. Modified to cater
       				   to new column ord_num on ben_acty_base_rt_f
  115.26     30-Dec-2002 mmudigon  NOCOPY
  115.27     13-feb-2003 kmahendr  Added a parameter to call -acty_base_rt.main
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
g_package varchar2(50) := 'ben_efc_adjustments.';
--
procedure DetectAppError
  (p_sqlerrm                   in    varchar2
  ,p_abr_rt_mlt_cd             in    varchar2 default null
  ,p_abr_val                   in    number   default null
  ,p_abr_entr_val_at_enrt_flag in    varchar2 default null
  ,p_abr_id                    in    number   default null
  ,p_eff_date                  in    date     default null
  ,p_penepe_id                 in    number   default null
  --
  ,p_faterr_code                 out nocopy varchar2
  ,p_faterr_type                 out nocopy varchar2
  )
is
  --
  cursor c_parntabr
    (c_abr_id   number
    ,c_eff_date date
    )
  is
    select abr2.acty_base_rt_id,
           abr2.entr_val_at_enrt_flag,
           abr2.val
    from   ben_acty_base_rt_f abr,
           ben_acty_base_rt_f abr2
    where  abr.acty_base_rt_id = c_abr_id
    and    abr2.acty_base_rt_id = abr.parnt_acty_base_rt_id
    and    abr2.parnt_chld_cd = 'PARNT'
    and    c_eff_date
           between abr.effective_start_date
           and     abr.effective_end_date
    and    c_eff_date
           between abr2.effective_start_date
           and     abr2.effective_end_date;
  --
  l_parntabr c_parntabr%rowtype;
  --
  cursor c_epedets
    (c_epe_id   number
    )
  is
    select epe.pgm_id,
           epe.pl_id
    from ben_elig_per_elctbl_chc epe
    where epe.elig_per_elctbl_chc_id = c_epe_id;
  --
  l_epedets c_epedets%rowtype;
  --
  cursor c_plndets
    (c_pln_id   number
    ,c_eff_date date
    )
  is
    select pln.pl_id
    from   ben_pl_f pln
    where  pln.pl_id = c_pln_id
    and    c_eff_date
      between pln.effective_start_date
        and     pln.effective_end_date;
  --
  l_plndets c_plndets%rowtype;
  --
begin
  --
  if instr(p_sqlerrm,'91834') > 0
  then
    --
    if p_abr_rt_mlt_cd is null
    then
      --
      p_faterr_code   := 'ABRMCNULL';
      p_faterr_type   := 'MISSINGSETUP';
      --
    elsif (p_abr_val is null and p_abr_entr_val_at_enrt_flag = 'N')
    then
      --
      p_faterr_code   := 'ABRVALNULLEVAEFN';
      p_faterr_type   := 'MISSINGSETUP';
      --
    else
      --
      -- Check for a parent activity base rate
      --
      open c_parntabr
        (c_abr_id   => p_abr_id
        ,c_eff_date => p_eff_date
        );
      fetch c_parntabr into l_parntabr;
      if c_parntabr%found then
        --
        if l_parntabr.val is null and l_parntabr.entr_val_at_enrt_flag = 'N'
        then
          --
          p_faterr_code   := 'CHILDABRVALNULLEVAEFN';
          p_faterr_type   := 'MISSINGSETUP';
          --
        end if;
        --
      end if;
      close c_parntabr;
      --
    end if;
    --
  elsif instr(p_sqlerrm,'92411') > 0
  then
    --
    -- Get EPE dets
    --
    open c_epedets
      (c_epe_id => p_penepe_id
      );
    fetch c_epedets into l_epedets;
    if c_epedets%found then
      --
      -- Check that the EPE PGMID is null and the PLNID is not null
      --
      if l_epedets.pgm_id is null
        and l_epedets.pl_id is not null
      then
        --
        open c_plndets
          (c_pln_id   => l_epedets.pl_id
          ,c_eff_date => p_eff_date
          );
        fetch c_plndets into l_plndets;
        if c_plndets%notfound then
          --
          p_faterr_code   := 'EPEPLNNIPNOEXIST';
          p_faterr_type   := 'DELETEDINFO';
          --
        end if;
        close c_plndets;
        --
      end if;
      --
    else
      --
      p_faterr_code   := 'PENEPENOEXIST';
      p_faterr_type   := 'DELETEDINFO';
      --
    end if;
    close c_epedets;
    --
  else
    --
    p_faterr_code := null;
    p_faterr_type := null;
    --
  end if;
  --
end DetectAppError;
--
procedure DetectWhoInfo
  (p_creation_date         in     date
  ,p_last_update_date      in     date
  ,p_object_version_number in     number
  --
  ,p_who_counts            in out nocopy g_who_counts
  ,p_faterr_code              out nocopy varchar2
  ,p_faterr_type              out nocopy varchar2
  )
is
  --
  l_gap         number;
  l_faterr_type varchar2(100);
  --
begin
  --
  p_who_counts.olddata         := FALSE;
  p_who_counts.olddata12mths   := FALSE;
  p_who_counts.multtransmod    := FALSE;
  --
  -- Check for old data
  --
  if p_who_counts.olddata_count is null then
    --
    p_who_counts.olddata_count       := 0;
    p_who_counts.mod_count           := 0;
    p_who_counts.modovn1_count       := 0;
    p_who_counts.modovn2_count       := 0;
    p_who_counts.modovn3_count       := 0;
    p_who_counts.modovn4_count       := 0;
    p_who_counts.modovn5_count       := 0;
    p_who_counts.modovn6_count       := 0;
    p_who_counts.modovnov6_count     := 0;
    p_who_counts.multtransmod_count  := 0;
    --
  end if;
  --
  if nvl(p_creation_date,hr_api.g_sot)
    <> nvl(p_last_update_date,hr_api.g_sot)
  then
    --
    p_who_counts.mod_count := p_who_counts.mod_count+1;
    --
    -- Check for multiple transactions gap more that 1 min
    --
    l_gap := (p_last_update_date-p_creation_date)*(24*60);
    --
    if l_gap > 1 then
      --
      p_who_counts.multtransmod_count := p_who_counts.multtransmod_count+1;
      p_who_counts.multtransmod       := TRUE;
      --
    end if;
    --
    -- Check ENB OVN
    --
    if p_object_version_number = 1 then
      --
      p_who_counts.modovn1_count := p_who_counts.modovn1_count+1;
      --
    elsif p_object_version_number = 2 then
      --
      p_who_counts.modovn2_count := p_who_counts.modovn2_count+1;
      --
    elsif p_object_version_number = 3 then
      --
      p_who_counts.modovn3_count := p_who_counts.modovn3_count+1;
      --
    elsif p_object_version_number = 4 then
      --
      p_who_counts.modovn4_count := p_who_counts.modovn4_count+1;
      --
    elsif p_object_version_number = 5 then
      --
      p_who_counts.modovn5_count := p_who_counts.modovn5_count+1;
      --
    elsif p_object_version_number = 6 then
      --
      p_who_counts.modovn6_count := p_who_counts.modovn6_count+1;
      --
    elsif p_object_version_number > 6 then
      --
      p_who_counts.modovnov6_count := p_who_counts.modovnov6_count+1;
      --
    end if;
    --
  end if;
  --
  l_faterr_type := 'OBSOLETEDATA';
  --
  if p_creation_date is null then
    --
    p_who_counts.olddata_count := p_who_counts.olddata_count+1;
    p_who_counts.olddata       := TRUE;
    p_faterr_code              := 'NULLCREDT';
    p_faterr_type              := l_faterr_type;
    --
/*
  elsif p_creation_date
    < sysdate-365
  then
    --
    p_who_counts.olddata_count := p_who_counts.olddata_count+1;
    p_who_counts.olddata       := TRUE;
    p_faterr_code              := 'OLDDATA12MTHS';
    p_faterr_type              := l_faterr_type;
    --
*/
  else
    --
    p_who_counts.olddata       := FALSE;
    p_faterr_code              := null;
    p_faterr_type              := null;
    --
  end if;
  --
end DetectWhoInfo;
--
procedure DetectPILInfo
  (p_person_id         in     number
  ,p_per_in_ler_id     in     number
  --
  ,p_faterr_code          out nocopy varchar2
  )
is
  --
  cursor c_maxpildets
    (c_person_id in number
    )
  is
    select pil.per_in_ler_id
    from ben_per_in_ler pil
    where pil.person_id = c_person_id
    order by pil.per_in_ler_id desc;
  --
  l_maxpildets c_maxpildets%rowtype;
  --
  l_pil_count  pls_integer;
  --
begin
  --
  l_pil_count := 0;
  --
  for row in c_maxpildets
    (c_person_id => p_person_id
    )
  loop
    --
    if row.per_in_ler_id = p_per_in_ler_id then
      --
      if l_pil_count = 0 then
        --
        p_faterr_code  := null;
        --
      elsif l_pil_count = 1 then
        --
        p_faterr_code  := 'HISTPIL1';
        --
      elsif l_pil_count = 2 then
        --
        p_faterr_code  := 'HISTPIL2';
        --
      elsif l_pil_count = 3 then
        --
        p_faterr_code  := 'HISTPIL3';
        --
      elsif l_pil_count = 4 then
        --
        p_faterr_code  := 'HISTPIL4';
        --
      elsif l_pil_count = 5 then
        --
        p_faterr_code  := 'HISTPIL5';
        --
      elsif l_pil_count = 6 then
        --
        p_faterr_code  := 'HISTPIL6';
        --
      elsif l_pil_count = 7 then
        --
        p_faterr_code  := 'HISTPIL7';
        --
      elsif l_pil_count = 8 then
        --
        p_faterr_code  := 'HISTPIL8';
        --
      elsif l_pil_count = 9 then
        --
        p_faterr_code  := 'HISTPIL9';
        --
      else
        --
        p_faterr_code  := 'HISTPIL';
        --
      end if;
      --
      return;
      --
    end if;
    --
    l_pil_count := l_pil_count+1;
    --
  end loop;
  --
  if l_pil_count = 0 then
    --
    p_faterr_code  := 'NOPERPILS';
    return;
    --
  end if;
  --
end DetectPILInfo;
--
procedure DetectBCOLRowInfo
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_effective_date    in     date
  ,p_business_group_id in     number
  --
  ,p_faterr_code          out nocopy varchar2
  )
is
  --
  l_elig_rec  ben_derive_part_and_rate_cache.g_cache_clf_rec_obj;
  l_rate_rec  ben_derive_part_and_rate_cache.g_cache_clf_rec_obj;
  --
begin
  --
  -- Check that the comp object details were found
  --
  if p_comp_obj_tree_row.trk_inelig_per_flag is null then
    --
    p_faterr_code   := 'NOMATCO';
    return;
    --
  else
    --
    p_faterr_code   := null;
    --
  end if;
  --
  -- Check that attached DFs exist
  --
  if p_comp_obj_tree_row.flag_bit_val = 0
    and p_comp_obj_tree_row.oiplip_flag_bit_val = 0
  then
    --
    p_faterr_code   := 'NOATTDF';
    return;
    --
  else
    --
    p_faterr_code   := null;
    --
  end if;
  --
  -- Check for a comp DF
  --
  IF (bitand(p_comp_obj_tree_row.flag_bit_val
        ,ben_manage_life_events.g_cmp_flag) <> 0)
  THEN
    --
    ben_derive_part_and_rate_cache.get_comp_elig
      (p_pgm_id            => p_comp_obj_tree_row.pgm_id
      ,p_pl_id             => p_comp_obj_tree_row.pl_id
      ,p_oipl_id           => p_comp_obj_tree_row.oipl_id
      ,p_plip_id           => p_comp_obj_tree_row.plip_id
      ,p_ptip_id           => p_comp_obj_tree_row.ptip_id
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_rec               => l_elig_rec
      );
    --
    p_faterr_code   := null;
    --
  elsif (bitand(p_comp_obj_tree_row.flag_bit_val
           ,ben_manage_life_events.g_cmp_rt_flag) <> 0)
       OR
        (p_comp_obj_tree_row.oiplip_id IS NOT NULL
          AND bitand(p_comp_obj_tree_row.oiplip_flag_bit_val
               ,ben_manage_life_events.g_cmp_rt_flag) <> 0)
  THEN
    --
    ben_derive_part_and_rate_cache.get_comp_rate
      (p_pgm_id            => p_comp_obj_tree_row.pgm_id
      ,p_pl_id             => p_comp_obj_tree_row.pl_id
      ,p_oipl_id           => p_comp_obj_tree_row.oipl_id
      ,p_plip_id           => p_comp_obj_tree_row.plip_id
      ,p_ptip_id           => p_comp_obj_tree_row.ptip_id
      ,p_oiplip_id         => p_comp_obj_tree_row.oiplip_id
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_rec               => l_rate_rec
      );
    --
    p_faterr_code   := null;
    --
  else
    --
    p_faterr_code      := 'NOCMPATTDF';
    return;
    --
  end if;
  --
end DetectBCOLRowInfo;
--
procedure DetectEPEENBInfo
  (p_elig_per_elctbl_chc_id in     number
  ,p_enrt_bnft_id           in     number
  --
  ,p_detect_mode            in     varchar2 default null
  --
  ,p_currpil_row               out nocopy g_pil_rowtype
  ,p_currepe_row               out nocopy ben_determine_rates.g_curr_epe_rec
  ,p_faterr_code               out nocopy varchar2
  ,p_faterr_type               out nocopy varchar2
  )
is
  --
  l_tmpepe_row          ben_epe_cache.g_pilepe_inst_row;
  l_currepe_row         ben_determine_rates.g_curr_epe_rec;
  --
  cursor c_epedets
    (c_epe_id in number
    )
  is
    select pil.lf_evt_ocrd_dt,
           pil.person_id,
           pil.per_in_ler_id,
           pil.business_group_id,
           pil.ler_id,
           pil.per_in_ler_stat_cd
    from BEN_ELIG_PER_ELCTBL_CHC epe,
         ben_per_in_ler pil,
         per_all_people_f per
    where pil.per_in_ler_id = epe.per_in_ler_id
    and   epe.ELIG_PER_ELCTBL_CHC_id = c_epe_id
    and   per.person_id = pil.person_id
    and   pil.lf_evt_ocrd_dt
      between per.effective_start_date and per.effective_end_date;
  --
  l_epedets         c_epedets%rowtype;
  --
  cursor c_enbdets
    (c_enb_id in number
    )
  is
    select pil.lf_evt_ocrd_dt,
           pil.person_id,
           pil.per_in_ler_id,
           pil.business_group_id,
           pil.ler_id,
           pil.per_in_ler_stat_cd,
           enb.val
    from ben_enrt_bnft enb,
         BEN_ELIG_PER_ELCTBL_CHC epe,
         ben_per_in_ler pil,
         per_all_people_f per
    where enb.ELIG_PER_ELCTBL_CHC_id = epe.ELIG_PER_ELCTBL_CHC_id
    and   pil.per_in_ler_id = epe.per_in_ler_id
    and   enb.enrt_bnft_id = c_enb_id
    and   per.person_id = pil.person_id
    and   pil.lf_evt_ocrd_dt
      between per.effective_start_date and per.effective_end_date;
  --
  l_enbdets           c_enbdets%rowtype;
  --
  cursor c_enbnoperdets
    (c_enb_id in number
    )
  is
    select pil.lf_evt_ocrd_dt,
           pil.person_id,
           pil.per_in_ler_id,
           pil.business_group_id,
           pil.ler_id,
           pil.per_in_ler_stat_cd,
           enb.val
    from ben_enrt_bnft enb,
         BEN_ELIG_PER_ELCTBL_CHC epe,
         ben_per_in_ler pil
    where enb.ELIG_PER_ELCTBL_CHC_id = epe.ELIG_PER_ELCTBL_CHC_id
    and   pil.per_in_ler_id = epe.per_in_ler_id
    and   enb.enrt_bnft_id = c_enb_id;
  --
  l_enbnoperdets        c_enbnoperdets%rowtype;
  --
begin
/*
  --
  -- Check if the ENB id and EPE id are both set exists
  --
  if p_elig_per_elctbl_chc_id is not null
    and p_enrt_bnft_id is not null
  then
    --
    p_faterr_code   := 'EPEANDENBSET';
    p_faterr_type   := 'POTENTIALCODEBUG';
    return;
    --
  end if;
*/
  --
  -- Get EPE details
  --
  if p_elig_per_elctbl_chc_id is not null
  then
    --
    open c_epedets
      (c_epe_id => p_elig_per_elctbl_chc_id
      );
    fetch c_epedets into l_epedets;
    if c_epedets%notfound then
      --
      p_faterr_code   := 'NOEPEDETS';
      p_faterr_type   := 'DELETEDINFO';
      close c_epedets;
      return;
      --
    end if;
    close c_epedets;
    --
    p_currpil_row.per_in_ler_id  := l_epedets.per_in_ler_id;
    p_currpil_row.person_id      := l_epedets.person_id;
    p_currpil_row.lf_evt_ocrd_dt := l_epedets.lf_evt_ocrd_dt;
    --
    if l_epedets.per_in_ler_stat_cd in ('VOIDD','BCKDT')
    then
      --
      p_faterr_code   := 'VOIDBACKPIL';
      p_faterr_type   := 'VALIDEXCLUSION';
      return;
      --
    end if;
    --
    if nvl(p_detect_mode,'ZZZ') = 'EPEINFO' then
      --
      ben_epe_cache.EPE_GetEPEDets
        (p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
        ,p_per_in_ler_id          => l_epedets.per_in_ler_id
        ,p_inst_row               => l_tmpepe_row
        );
      --
    end if;
    --
  elsif p_enrt_bnft_id is not null then
    --
    open c_enbdets
      (c_enb_id => p_enrt_bnft_id
      );
    fetch c_enbdets into l_enbdets;
    if c_enbdets%notfound then
      --
      p_faterr_code   := 'NOENBEPEDETS';
      p_faterr_type   := 'POTENTIALCODEBUG';
      --
      close c_enbdets;
      --
      -- Check if the person exists for the life event
      --
      open c_enbnoperdets
        (c_enb_id => p_enrt_bnft_id
        );
      fetch c_enbnoperdets into l_enbnoperdets;
      if c_enbnoperdets%found then
        --
        p_faterr_code   := 'NOPILPERSON';
        p_faterr_type   := 'DELETEDINFO';
        --
      end if;
      close c_enbnoperdets;
      --
      return;
      --
    end if;
    close c_enbdets;
    --
    p_currpil_row.per_in_ler_id  := l_enbdets.per_in_ler_id;
    p_currpil_row.person_id      := l_enbdets.person_id;
    p_currpil_row.lf_evt_ocrd_dt := l_enbdets.lf_evt_ocrd_dt;
    --
    if l_epedets.per_in_ler_stat_cd in ('VOIDD','BCKDT')
    then
      --
      p_faterr_code   := 'VOIDBACKPIL';
      p_faterr_type   := 'VALIDEXCLUSION';
      return;
      --
    end if;
    --
    if nvl(p_detect_mode,'ZZZ') = 'EPEINFO' then
      --
      ben_epe_cache.ENBEPE_GetEPEDets
        (p_enrt_bnft_id  => p_enrt_bnft_id
        ,p_per_in_ler_id => l_enbdets.per_in_ler_id
        ,p_inst_row      => l_tmpepe_row
        );
      --
    end if;
    --
  end if;
  --
  -- Check if EPE details were found
  --
  if l_tmpepe_row.elig_per_elctbl_chc_id is null
    and nvl(p_detect_mode,'ZZZ') = 'EPEINFO'
  then
    --
    p_faterr_code   := 'EPEENBNOEPE';
    p_faterr_type   := 'POTENTIALCODEBUG';
    return;
    --
  end if;
  --
  l_currepe_row.elig_per_elctbl_chc_id := l_tmpepe_row.elig_per_elctbl_chc_id;
  l_currepe_row.business_group_id      := l_tmpepe_row.business_group_id;
  l_currepe_row.person_id              := l_tmpepe_row.person_id;
  l_currepe_row.ler_id                 := l_tmpepe_row.ler_id;
  l_currepe_row.lf_evt_ocrd_dt         := l_tmpepe_row.lf_evt_ocrd_dt;
  l_currepe_row.per_in_ler_id          := l_tmpepe_row.per_in_ler_id;
  l_currepe_row.enrt_bnft_id           := l_tmpepe_row.enrt_bnft_id;
  l_currepe_row.pgm_id                 := l_tmpepe_row.pgm_id;
  l_currepe_row.pl_typ_id              := l_tmpepe_row.pl_typ_id;
  l_currepe_row.ptip_id                := l_tmpepe_row.ptip_id;
  l_currepe_row.plip_id                := l_tmpepe_row.plip_id;
  l_currepe_row.pl_id                  := l_tmpepe_row.pl_id;
  l_currepe_row.oipl_id                := l_tmpepe_row.oipl_id;
  l_currepe_row.oiplip_id              := l_tmpepe_row.oiplip_id;
  l_currepe_row.opt_id                 := l_tmpepe_row.opt_id;
  l_currepe_row.enrt_perd_id           := l_tmpepe_row.enrt_perd_id;
  l_currepe_row.lee_rsn_id             := l_tmpepe_row.lee_rsn_id;
  l_currepe_row.enrt_perd_strt_dt      := l_tmpepe_row.enrt_perd_strt_dt;
  l_currepe_row.prtt_enrt_rslt_id      := l_tmpepe_row.prtt_enrt_rslt_id;
  l_currepe_row.prtn_strt_dt           := l_tmpepe_row.prtn_strt_dt;
  l_currepe_row.enrt_cvg_strt_dt       := l_tmpepe_row.enrt_cvg_strt_dt;
  l_currepe_row.enrt_cvg_strt_dt_cd    := l_tmpepe_row.enrt_cvg_strt_dt_cd;
  l_currepe_row.enrt_cvg_strt_dt_rl    := l_tmpepe_row.enrt_cvg_strt_dt_rl;
  l_currepe_row.yr_perd_id             := l_tmpepe_row.yr_perd_id;
  l_currepe_row.prtn_ovridn_flag       := l_tmpepe_row.prtn_ovridn_flag;
  l_currepe_row.prtn_ovridn_thru_dt    := l_tmpepe_row.prtn_ovridn_thru_dt;
  l_currepe_row.rt_age_val             := l_tmpepe_row.rt_age_val;
  l_currepe_row.rt_los_val             := l_tmpepe_row.rt_los_val;
  l_currepe_row.rt_hrs_wkd_val         := l_tmpepe_row.rt_hrs_wkd_val;
  l_currepe_row.rt_cmbn_age_n_los_val  := l_tmpepe_row.rt_cmbn_age_n_los_val;
/*
  l_currepe_row.elctbl_flag            := l_tmpepe_row.elctbl_flag;
  l_currepe_row.object_version_number  := l_tmpepe_row.object_version_number;
  l_currepe_row.alws_dpnt_dsgn_flag    := l_tmpepe_row.alws_dpnt_dsgn_flag;
  l_currepe_row.dpnt_dsgn_cd           := l_tmpepe_row.dpnt_dsgn_cd;
  l_currepe_row.ler_chg_dpnt_cvg_cd    := l_tmpepe_row.ler_chg_dpnt_cvg_cd;
  l_currepe_row.dpnt_cvg_strt_dt_cd    := l_tmpepe_row.dpnt_cvg_strt_dt_cd;
  l_currepe_row.dpnt_cvg_strt_dt_rl    := l_tmpepe_row.dpnt_cvg_strt_dt_rl;
  l_currepe_row.in_pndg_wkflow_flag    := l_tmpepe_row.in_pndg_wkflow_flag;
*/
  l_currepe_row.bnft_prvdr_pool_id     := l_tmpepe_row.bnft_prvdr_pool_id;
  --
  -- Set OUT parameters
  --
  p_currepe_row := l_currepe_row;
  --
end DetectEPEENBInfo;
--
procedure DetectVAPROInfo
  (p_currepe_row          in     ben_determine_rates.g_curr_epe_rec
  --
  ,p_lf_evt_ocrd_dt       in     date
  ,p_last_update_date     in     date
  --
  ,p_actl_prem_id         in     number default null
  ,p_acty_base_rt_id      in     number default null
  ,p_cvg_amt_calc_mthd_id in     number default null
  --
  ,p_vpfdets                 out nocopy gc_vpfdets%rowtype
  ,p_vpf_id                  out nocopy number
  ,p_faterr_code             out nocopy varchar2
  ,p_faterr_type             out nocopy varchar2
  )
is
  --
  l_vpfdets gc_vpfdets%rowtype;
  --
  cursor c_avrdets
    (c_vpf_id   in     number
    ,c_abr_id   in     number
    ,c_eff_date in     date
    )
  is
    select avr.creation_date,
           avr.last_update_date
    from   ben_acty_vrbl_rt_f avr
    where  avr.vrbl_rt_prfl_id = c_vpf_id
    and    avr.ACTY_BASE_RT_ID = c_abr_id
    and    c_eff_date
      between avr.effective_start_date
        and     avr.effective_end_date;
  --
  l_avrdets c_avrdets%rowtype;
  --
  l_vpf_id number;
  --
begin
  --
  ben_evaluate_rate_profiles.main
    (p_currepe_row               => p_currepe_row
    --
    ,p_person_id                 => p_currepe_row.person_id
    ,p_acty_base_rt_id           => p_acty_base_rt_id
    ,p_actl_prem_id              => p_actl_prem_id
    ,p_cvg_amt_calc_mthd_id      => p_cvg_amt_calc_mthd_id
    ,p_elig_per_elctbl_chc_id    => p_currepe_row.elig_per_elctbl_chc_id
    ,p_effective_date            => p_lf_evt_ocrd_dt
    ,p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt
    ,p_calc_only_rt_val_flag     => FALSE
    ,p_pgm_id                    => p_currepe_row.pgm_id
    ,p_pl_id                     => p_currepe_row.pl_id
    ,p_pl_typ_id                 => p_currepe_row.pl_typ_id
    ,p_oipl_id                   => p_currepe_row.oipl_id
    ,p_per_in_ler_id             => p_currepe_row.per_in_ler_id
    ,p_ler_id                    => p_currepe_row.ler_id
    ,p_business_group_id         => p_currepe_row.business_group_id
    ,p_vrbl_rt_prfl_id           => l_vpf_id
    );
  --
  -- Check for VAPRO
  --
  if l_vpf_id is null then
    --
    p_faterr_code := null;
    return;
    --
  end if;
  --
  -- Set OUT parameters
  --
  p_vpf_id  := l_vpf_id;
  --
  -- Get vapro details
  --
  open gc_vpfdets
    (c_vpf_id   => l_vpf_id
    ,c_eff_date => p_lf_evt_ocrd_dt
    );
  fetch gc_vpfdets into l_vpfdets;
  if gc_vpfdets%notfound then
    --
    p_faterr_code   := 'NODTVPF';
    return;
    --
  end if;
  close gc_vpfdets;
  --
  p_vpfdets := l_vpfdets;
  --
  -- Check for modified VAPRO since LUD
  --
  if l_vpfdets.last_update_date > nvl(p_last_update_date,hr_api.g_eot)
  then
    --
    p_faterr_code   := 'VPFCORR';
    p_faterr_type   := 'CORRECTEDINFO';
    return;
    --
  end if;
  --
  -- Check for AVRs
  --
  if p_acty_base_rt_id is not null then
    --
    open c_avrdets
      (c_vpf_id   => l_vpf_id
      ,c_abr_id   => p_acty_base_rt_id
      ,c_eff_date => p_lf_evt_ocrd_dt
      );
    fetch c_avrdets into l_avrdets;
    if c_avrdets%notfound then
      --
      p_faterr_code   := 'NODTAVRVPF';
      return;
      --
    end if;
    close c_avrdets;
    --
    -- Check for modified AVR since LUD
    --
    if l_avrdets.last_update_date > p_last_update_date
    then
      --
      p_faterr_code   := 'VPFAVRCORR';
      return;
      --
    end if;
    --
  end if;
/*
  --
  -- Check for flat amount vapros
  --
  if l_vpfdets.mlt_cd = 'FLFX' then
    --
    p_faterr_code   := 'VPFFLFX';
    return;
    --
  end if;
*/
  --
end DetectVAPROInfo;
--
procedure DetectRoundInfo
  (p_rndg_cd     in     varchar2
  ,p_rndg_rl     in     number
  ,p_old_val     in     number
  ,p_new_val     in     number
  ,p_eff_date    in     date
  --
  ,p_faterr_code    out nocopy varchar2
  ,p_faterr_type    out nocopy varchar2
  )
is
  --

  --
begin
  --
  if (p_rndg_cd is not null
      or p_rndg_rl is not null
        )
  then
    --
    if benutils.do_rounding
        (p_rounding_cd    => p_rndg_cd
        ,p_rounding_rl    => p_rndg_rl
        ,p_value          => p_new_val
        ,p_effective_date => p_eff_date
        ) <> p_new_val
      and round(p_new_val) = round(p_old_val)
    then
      --
      p_faterr_code := 'NOROUND';
      p_faterr_type := 'CONVEXCLUSION';
      return;
      --
    end if;
    --
    if benutils.do_rounding
        (p_rounding_cd    => p_rndg_cd
        ,p_rounding_rl    => p_rndg_rl
        ,p_value          => p_old_val
        ,p_effective_date => p_eff_date
        ) = p_new_val
    then
      --
      p_faterr_code := 'NEWLYROUNDED';
      p_faterr_type := 'CONVEXCLUSION';
      return;
      --
    end if;
    --
    if benutils.do_rounding
        (p_rounding_cd    => p_rndg_cd
        ,p_rounding_rl    => p_rndg_rl
        ,p_value          => p_new_val
        ,p_effective_date => p_eff_date
        ) = p_old_val
    then
      --
      p_faterr_code := 'WASROUNDED';
      p_faterr_type := 'CONVEXCLUSION';
      return;
      --
    end if;
    --
  end if;
  --
  -- Hard coded rounded removal
  --
  if round(p_new_val,2) = p_old_val then
    --
    p_faterr_code := 'WASHCROUNDED';
    p_faterr_type := 'CONVEXCLUSION';
    return;
    --
  end if;
  --
  -- Check for the hard code rounded change in bendisrt
  --
  if (p_rndg_cd is null
      and p_rndg_rl is null
     )
    and p_old_val = round(p_new_val,-1)
    and p_old_val > 0
  then
    --
    p_faterr_code := 'RNGDERRTO10';
    p_faterr_type := 'CONVEXCLUSION';
    return;
    --
  elsif (p_rndg_cd is null
      and p_rndg_rl is null
     )
    and p_old_val = round(p_new_val,-2)
    and p_old_val > 0
  then
    --
    p_faterr_code := 'RNGDERRTO100';
    p_faterr_type := 'CONVEXCLUSION';
    return;
    --
  elsif (p_rndg_cd is null
      and p_rndg_rl is null
     )
    and p_old_val = round(p_new_val,-3)
    and p_old_val > 0
  then
    --
    p_faterr_code := 'RNGDERRTO1000';
    p_faterr_type := 'CONVEXCLUSION';
    return;
    --
  elsif (p_rndg_cd is null
      and p_rndg_rl is null
     )
    and p_old_val = round(p_new_val,-4)
    and p_old_val > 0
  then
    --
    p_faterr_code := 'RNGDERRTO10000';
    p_faterr_type := 'CONVEXCLUSION';
    return;
    --
  elsif (p_rndg_cd is null
      and p_rndg_rl is null
     )
    and p_old_val = round(p_new_val,-5)
    and p_old_val > 0
  then
    --
    p_faterr_code := 'RNGDERRTO100000';
    p_faterr_type := 'CONVEXCLUSION';
    return;
    --
  elsif (p_rndg_cd is null
      and p_rndg_rl is null
     )
    and p_old_val = round(p_new_val,-6)
    and p_old_val > 0
  then
    --
    p_faterr_code := 'RNGDERRTO1000000';
    p_faterr_type := 'CONVEXCLUSION';
    return;
    --
  elsif (p_rndg_cd is null
      and p_rndg_rl is null
     )
    and p_old_val = round(p_new_val,-7)
    and p_old_val > 0
  then
    --
    p_faterr_code := 'RNGDERRTO10000000';
    p_faterr_type := 'CONVEXCLUSION';
    return;
    --
  elsif (p_rndg_cd is null
      and p_rndg_rl is null
     )
    and (p_old_val
      between (p_new_val*.99) and (p_new_val*1.01))
    and p_old_val > 0
  then
    --
    p_faterr_code := 'RNGDERR1%';
    p_faterr_type := 'CONVEXCLUSION';
    return;
    --
  elsif (p_rndg_cd is null
      and p_rndg_rl is null
     )
    and (p_old_val
      between (p_new_val*.98) and (p_new_val*1.02))
    and p_old_val > 0
  then
    --
    p_faterr_code := 'RNGDERR2%';
    p_faterr_type := 'CONVEXCLUSION';
    return;
    --
  elsif (p_rndg_cd is null
      and p_rndg_rl is null
     )
    and (p_old_val
      between (p_new_val*.97) and (p_new_val*1.03))
    and p_old_val > 0
  then
    --
    p_faterr_code := 'RNGDERR3%';
    p_faterr_type := 'CONVEXCLUSION';
    return;
    --
  elsif (p_rndg_cd is null
      and p_rndg_rl is null
     )
    and (p_old_val
      between (p_new_val*.96) and (p_new_val*1.04))
    and p_old_val > 0
  then
    --
    p_faterr_code := 'RNGDERR4%';
    p_faterr_type := 'CONVEXCLUSION';
    return;
    --
  elsif (p_rndg_cd is null
      and p_rndg_rl is null
     )
    and (p_old_val
      between (p_new_val*.9) and (p_new_val*1.1))
    and p_old_val > 0
  then
    --
    p_faterr_code := 'RNGDERR10%';
    p_faterr_type := 'CONVEXCLUSION';
    return;
    --
  end if;
  --
end DetectRoundInfo;
--
procedure DetectConvInfo
  (p_ncucurr_code in     varchar2
  ,p_new_val      in     number
  ,p_preconv_val  in     number
  --
  ,p_faterr_code     out nocopy varchar2
  ,p_faterr_type     out nocopy varchar2
  ,p_postconv_val    out nocopy number
  )
is
  --
  cursor c_ccfactdets
    (c_curr_code varchar2
    )
  is
    select fcu.derive_factor
    from fnd_currencies fcu
    where fcu.currency_code = c_curr_code;
  --
  l_ccfactdets c_ccfactdets%rowtype;
  --
  l_faterr_code    varchar2(30);
  l_faterr_type    varchar2(30);
  l_rndfaterr_code varchar2(30);
  l_rndfaterr_type varchar2(30);
  l_postconv_val   number;
  --
begin
  --
  open c_ccfactdets
    (c_curr_code => p_ncucurr_code
    );
  fetch c_ccfactdets into l_ccfactdets;
  if c_ccfactdets%notfound then
    --
    l_faterr_code   := 'NOCURRCONVFACT';
    l_faterr_type   := 'CORRUPTDATA';
    --
  end if;
  close c_ccfactdets;
  --
  -- Check for a converted value problems
  --
  if l_faterr_code is null
    and p_new_val=p_preconv_val
    and l_ccfactdets.derive_factor <> 1
  then
    --
    l_postconv_val := p_new_val;
    l_faterr_code  := 'NOCONVADJVAL';
    l_faterr_type  := 'CONVEXCLUSION';
    --
  elsif l_faterr_code is null
    and (p_new_val*l_ccfactdets.derive_factor)
      between (p_preconv_val*0.95)
        and (p_preconv_val*1.05)
    and l_ccfactdets.derive_factor <> 1
  then
    --
    l_postconv_val := p_new_val*l_ccfactdets.derive_factor;
    l_faterr_code  := 'CONVADJVAL5%';
    l_faterr_type  := 'CONVEXCLUSION';
    --
  elsif l_faterr_code is null
    and (p_new_val*l_ccfactdets.derive_factor)
      between (p_preconv_val*0.9)
        and (p_preconv_val*1.1)
    and l_ccfactdets.derive_factor <> 1
  then
    --
    l_postconv_val := p_new_val*l_ccfactdets.derive_factor;
    l_faterr_code  := 'CONVADJVAL10%';
    l_faterr_type  := 'CONVEXCLUSION';
    --
  elsif l_faterr_code is null
    and (p_new_val*l_ccfactdets.derive_factor)
      between (p_preconv_val*0.75)
        and (p_preconv_val*1.25)
    and l_ccfactdets.derive_factor <> 1
  then
    --
    l_postconv_val := p_new_val*l_ccfactdets.derive_factor;
    l_faterr_code  := 'CONVADJVAL25%';
    l_faterr_type  := 'CONVEXCLUSION';
    --
  elsif l_faterr_code is null
    and (p_new_val*l_ccfactdets.derive_factor)
      between (p_preconv_val*0.5)
        and (p_preconv_val*1.5)
    and l_ccfactdets.derive_factor <> 1
  then
    --
    l_postconv_val := p_new_val*l_ccfactdets.derive_factor;
    l_faterr_code  := 'CONVADJVAL50%';
    l_faterr_type  := 'CONVEXCLUSION';
    --
  elsif l_faterr_code is null
    and l_ccfactdets.derive_factor <> 1
  then
    --
    l_postconv_val := p_new_val*l_ccfactdets.derive_factor;
    l_faterr_code  := 'CONVADJVAL>50%';
    l_faterr_type  := 'CONVEXCLUSION';
    --
    -- Check for negative values
    --
    if p_preconv_val < 0 then
      --
      l_faterr_code  := 'MINUSCONVADJVAL';
      l_faterr_type  := 'CONVEXCLUSION';
      --
    end if;
    --
  end if;
  --
  -- Check for hard coded rounding problems
  --
  if l_faterr_code in ('CONVADJVAL5%'
                      ,'CONVADJVAL10%'
                      ,'CONVADJVAL25%'
                      ,'CONVADJVAL50%'
                      ,'CONVADJVAL>50%'
                      )
  then
    --
    ben_efc_adjustments.DetectRoundInfo
      (p_rndg_cd        => null
      ,p_rndg_rl        => null
      ,p_old_val        => p_preconv_val
      ,p_new_val        => l_postconv_val
      ,p_eff_date       => null
      --
      ,p_faterr_code    => l_rndfaterr_code
      ,p_faterr_type    => l_rndfaterr_type
      );
    --
    if l_rndfaterr_code is not null then
      --
      l_faterr_code  := l_rndfaterr_code;
      l_faterr_type  := 'CONVEXCLUSION';
      --
    end if;
    --
  end if;
  --
  p_faterr_code  := l_faterr_code;
  p_faterr_type  := l_faterr_type;
  p_postconv_val := l_postconv_val;
  --
end DetectConvInfo;
--
procedure DetectInvAsg
  (p_person_id      in     number
  ,p_eff_date       in     date
  --
  ,p_perasg            out nocopy gc_perasg%rowtype
  ,p_noasgpay          out nocopy boolean
  )
is
  --
  l_perasg  gc_perasg%rowtype;
  --
begin
  --
  open gc_perasg
    (c_person_id      => p_person_id
    ,c_effective_date => p_eff_date
    );
  fetch gc_perasg into l_perasg;
  close gc_perasg;
  --
  if l_perasg.payroll_id is null then
    --
    p_noasgpay := TRUE;
    --
  else
    --
    p_noasgpay := FALSE;
    --
  end if;
  --
  p_perasg := l_perasg;
  --
end DetectInvAsg;
--
procedure Insert_fndsession_row
  (p_ses_date in     date
  )
is
  --
/*
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
  l_commit number;
*/
  --
begin
  --
  null;
/*
  dt_fndate.change_ses_date
    (p_ses_date => p_ses_date
    ,p_commit   => l_commit
    );
  --
  COMMIT;
*/
  --
end Insert_fndsession_row;
--
procedure insert_validation_exceptions
  (p_val_set        in     g_failed_adj_values_tbl
  ,p_efc_action_id  in     number
  ,p_ent_scode      in     varchar2
  ,p_exception_type in     varchar2
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
  l_esd            date;
  l_eed            date;
  --
  l_exception_type varchar2(100);
  --
begin
  --
  if p_val_set.count > 0 then
    --
    l_exception_type := p_exception_type;
    --
    for ele_num in p_val_set.first..p_val_set.last
    loop
      --
      if p_exception_type is null then
        --
        l_exception_type := p_val_set(ele_num).faterr_type;
        --
      end if;
      --
      l_esd := p_val_set(ele_num).esd;
      l_eed := p_val_set(ele_num).eed;
      --
      if p_val_set(ele_num).esd is null then
        --
        l_esd := hr_api.g_sot;
        --
      end if;
      --
      if p_val_set(ele_num).eed is null then
        --
        l_eed := hr_api.g_eot;
        --
      end if;
      --
      insert into ben_efc_exclusions
        (efc_action_id
        ,ent_scode
        ,exclusion_type
        ,pk_id
        ,effective_start_date
        ,effective_end_date
        ,exclusion_code
        ,old_val
        ,new_val
        ,object_version_number
        ,business_group_id
        ,creation_date
        ,last_update_date
        ,created_by
        ,last_updated_by
        )
      values
        (p_efc_action_id
        ,p_ent_scode
        ,l_exception_type
        ,p_val_set(ele_num).id
        ,l_esd
        ,l_eed
        ,p_val_set(ele_num).faterr_code
        ,p_val_set(ele_num).old_val1
        ,p_val_set(ele_num).new_val1
        ,p_val_set(ele_num).ovn
        ,p_val_set(ele_num).bgp_id
        ,p_val_set(ele_num).credt
        ,p_val_set(ele_num).lud
        ,p_val_set(ele_num).cre_by
        ,p_val_set(ele_num).lu_by
        );
      --
    end loop;
    --
    COMMIT;
    --
  end if;
  --
end insert_validation_exceptions;
--
procedure pep_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy g_adjustment_counts
  )
is
  --
  TYPE cur_type IS REF CURSOR;
  --
  type g_efc_row is record
    (elig_per_id           ben_elig_per_f.elig_per_id%type
    ,effective_start_date  ben_elig_per_f.effective_start_date%type
    ,effective_end_date    ben_elig_per_f.effective_end_date%type
    ,comp_ref_amt          ben_elig_per_f.comp_ref_amt%type
    ,rt_comp_ref_amt       ben_elig_per_f.rt_comp_ref_amt%type
    ,comp_ref_uom          ben_elig_per_f.comp_ref_uom%type
    ,rt_comp_ref_uom       ben_elig_per_f.rt_comp_ref_uom%type
    ,person_id             ben_elig_per_f.person_id%type
    ,pgm_id                ben_elig_per_f.pgm_id%type
    ,ptip_id               ben_elig_per_f.ptip_id%type
    ,plip_id               ben_elig_per_f.plip_id%type
    ,pl_id                 ben_elig_per_f.pl_id%type
    ,business_group_id     ben_elig_per_f.business_group_id%type
    ,lf_evt_ocrd_dt        ben_per_in_ler.lf_evt_ocrd_dt%type
    ,per_in_ler_id         ben_per_in_ler.per_in_ler_id%type
    ,creation_date         ben_elig_per_f.creation_date%type
    ,last_update_date      ben_elig_per_f.last_update_date%type
    ,object_version_number ben_elig_per_f.object_version_number%type
    );
  --
  c_efc_rows               cur_type;
  --
  l_proc                   varchar2(1000) := 'pep_adjustments';
  --
  l_efc_row                g_efc_row;
  --
  l_who_counts             g_who_counts;
  --
  l_row_count              pls_integer;
  l_calfail_count          pls_integer;
  l_calsucc_count          pls_integer;
  l_conv_count             pls_integer;
  l_unconv_count           pls_integer;
  l_actconv_count          pls_integer;
  l_dupconv_count          pls_integer;
  --
  l_rcoerr_count           pls_integer;
  l_faterrs_count          pls_integer;
  --
  l_olddata                boolean;
  l_tabrow_count           pls_integer;
  --
  l_fatal_error            boolean;
  l_sql_str                long;
  l_from_str               long;
  l_where_str              long;
  --
  l_efc_batch              boolean;
  l_mode                   varchar2(100);
  l_nomatco                boolean;
  l_noattdf                boolean;
  l_nocmpattdf             boolean;
  --
  l_comp_obj_tree          ben_manage_life_events.g_cache_proc_object_table;
  l_comp_obj_tree_row      ben_manage_life_events.g_cache_proc_objects_rec;
  l_init_comp_obj_tree_row ben_manage_life_events.g_cache_proc_objects_rec;
  l_df_counts              ben_efc_functions.g_attach_df_counts;
  l_per_row                per_all_people_f%ROWTYPE;
  l_empasg_row             per_all_assignments_f%ROWTYPE;
  l_benasg_row             per_all_assignments_f%ROWTYPE;
  l_pil_row                ben_per_in_ler%rowtype;
  l_comp_rec               ben_derive_part_and_rate_facts.g_cache_structure;
  l_d_comp_rec             ben_derive_part_and_rate_facts.g_cache_structure;
  l_oiplip_rec             ben_derive_part_and_rate_facts.g_cache_structure;
  l_d_oiplip_rec           ben_derive_part_and_rate_facts.g_cache_structure;
  --
  l_coent_scode            varchar2(100);
  l_compobj_id             number;
  l_pk1                    number;
  --
  l_faterr_code            varchar2(100);
  l_faterr_type            varchar2(100);
  l_adjfailed              boolean;
  --
  l_prevbgp_id             number;
  --
begin
  --
  l_efc_batch        := FALSE;
  --
  l_row_count        := 0;
  l_calfail_count    := 0;
  l_calsucc_count    := 0;
  l_dupconv_count    := 0;
  l_conv_count       := 0;
  l_actconv_count    := 0;
  l_unconv_count     := 0;
  --
  l_rcoerr_count     := 0;
  l_faterrs_count    := 0;
  --
  g_pep_success_adj_val_set.delete;
  g_pep_rcoerr_val_set.delete;
  g_pep_failed_adj_val_set.delete;
  g_pep_fatal_error_val_set.delete;
  --
  l_mode             := 'L';
  --
  -- Check if EFC process parameters are set
  --
  if p_action_id is not null
    and p_pk1 is not null
    and p_chunk is not null
    and p_efc_worker_id is not null
  then
    --
    l_efc_batch := TRUE;
    --
  end if;
  --
  l_from_str := ' FROM ben_elig_per_f pep, '
                ||'      ben_per_in_ler pil, '
                ||'      per_all_people_f per ';
  --
  l_where_str := ' where pep.per_in_ler_id        = pil.per_in_ler_id '
                 ||' and   (pep.comp_ref_amt is not null '
                 ||'       or pep.rt_comp_ref_amt is not null) '
                 ||' and   pil.person_id            = per.person_id '
                 ||' and   pil.LF_EVT_OCRD_DT '
                 ||'   between per.effective_start_date and per.effective_end_date ';
  --
  -- Check if we are restricting by business group
  --
  if p_business_group_id is not null then
    --
    l_where_str := l_where_str||' and pep.business_group_id = '||p_business_group_id;
    --
  end if;
  --
  -- Build in batch specific restrictions
  --
  if l_efc_batch then
    --
    l_from_str  := l_from_str||', ben_elig_per_f_efc efc ';
    l_where_str := l_where_str||' and   efc.elig_per_id = pep.elig_per_id '
                   ||' and   efc.effective_start_date = pep.effective_start_date '
                   ||' and   efc.effective_end_date   = pep.effective_end_date '
                   ||' and   efc.efc_action_id        = :action_id '
                   ||' and   pep.elig_per_id          > :pk1 '
                   ||' and   mod(pep.elig_per_id, :total_workers) = :worker_id ';
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    l_where_str := l_where_str||' and mod(pep.elig_per_id, :valtotal_workers) = :valworker_id ';
    --
  end if;
  --
  l_sql_str  := ' select pep.elig_per_id, '
               ||'       pep.effective_start_date, '
               ||'       pep.effective_end_date, '
               ||'       pep.comp_ref_amt, '
               ||'       pep.rt_comp_ref_amt, '
               ||'       pep.comp_ref_uom, '
               ||'       pep.rt_comp_ref_uom, '
               ||'       pep.person_id, '
               ||'       pep.pgm_id, '
               ||'       pep.ptip_id, '
               ||'       pep.plip_id, '
               ||'       pep.pl_id, '
               ||'       pep.business_group_id, '
               ||'       pil.lf_evt_ocrd_dt, '
               ||'       pil.per_in_ler_id, '
               ||'       pep.creation_date, '
               ||'       pep.last_update_date, '
               ||'       pep.object_version_number '
               ||l_from_str
               ||l_where_str
               ||' order by pep.elig_per_id ';
  --
  if l_efc_batch then
    --
    hr_efc_info.insert_line('-- ');
    hr_efc_info.insert_line('-- Adjusting elig pers ');
    hr_efc_info.insert_line('-- ');
    --
    open c_efc_rows FOR l_sql_str using p_action_id, p_pk1, p_total_workers, p_worker_id;
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    open c_efc_rows FOR l_sql_str using p_valtotal_workers, p_valworker_id;
    --
  else
    --
    open c_efc_rows FOR l_sql_str;
    --
  end if;
  --
  loop
    FETCH c_efc_rows INTO l_efc_row;
    EXIT WHEN c_efc_rows%NOTFOUND;
    --
    l_fatal_error := FALSE;
    l_faterr_type := null;
    l_faterr_code := null;
    l_adjfailed   := FALSE;
    --
    -- Success and failure checks
    --
    if (l_efc_row.comp_ref_amt is not null
        and l_efc_row.comp_ref_uom is null)
      or
       (l_efc_row.rt_comp_ref_amt is not null
        and l_efc_row.rt_comp_ref_uom is null)
      and l_faterr_code is null
    then
      --
      l_adjfailed   := TRUE;
      l_faterr_code := 'NULLUOM';
      l_faterr_type := 'MISSINGSETUP';
      --
    end if;
    --
    if nvl(l_efc_row.comp_ref_uom,'ZZZZ') = 'EUR'
      or nvl(l_efc_row.rt_comp_ref_uom,'ZZZZ') = 'EUR'
      and l_faterr_code is null
    then
      --
      l_adjfailed   := TRUE;
      l_faterr_code := 'EUROUOM';
      l_faterr_type := 'VALIDEXCLUSION';
      --
    end if;
    --
    if l_faterr_code is null then
      --
      ben_derive_part_and_rate_cache.clear_down_cache;
      ben_person_object.clear_down_cache;
      ben_pil_object.clear_down_cache;
      --
      if nvl(l_prevbgp_id,-9999) <> l_efc_row.business_group_id then
        --
        ben_manage_life_events.g_cache_proc_object.delete;
        --
      end if;
      --
      begin
        --
        -- Set up comp object list
        --
        ben_comp_object_list.build_comp_object_list
          (p_effective_date         => l_efc_row.lf_evt_ocrd_dt
          ,p_business_group_id      => l_efc_row.business_group_id
          ,p_mode                   => l_mode
          );
        --
        l_prevbgp_id := l_efc_row.business_group_id;
        l_comp_obj_tree := ben_manage_life_events.g_cache_proc_object;
        --
        -- Set comp object context values
        --
        l_comp_obj_tree_row := l_init_comp_obj_tree_row;
        --
      exception
        when others then
          --
          g_pep_rcoerr_val_set(l_rcoerr_count).id        := l_efc_row.elig_per_id;
          g_pep_rcoerr_val_set(l_rcoerr_count).esd       := l_efc_row.effective_start_date;
          g_pep_rcoerr_val_set(l_rcoerr_count).eed       := l_efc_row.effective_end_date;
          g_pep_rcoerr_val_set(l_rcoerr_count).rco_name  := 'BCOL';
          g_pep_rcoerr_val_set(l_rcoerr_count).sql_error := SQLERRM;
          g_pep_rcoerr_val_set(l_rcoerr_count).lud       := l_efc_row.last_update_date;
          g_pep_rcoerr_val_set(l_rcoerr_count).credt     := l_efc_row.creation_date;
          --
          l_rcoerr_count     := l_rcoerr_count+1;
          l_fatal_error      := TRUE;
          --
      end;
      --
    end if;
    --
    if l_comp_obj_tree.count > 0
      and not l_fatal_error
    then
      --
      for bcolele_num in l_comp_obj_tree.first..l_comp_obj_tree.last
      loop
        --
        if nvl(l_comp_obj_tree(bcolele_num).par_pgm_id,9999) = nvl(l_efc_row.pgm_id,9999)
          and nvl(l_comp_obj_tree(bcolele_num).ptip_id,9999) = nvl(l_efc_row.ptip_id,9999)
          and nvl(l_comp_obj_tree(bcolele_num).pl_id,9999) = nvl(l_efc_row.pl_id,9999)
          and nvl(l_comp_obj_tree(bcolele_num).plip_id,9999) = nvl(l_efc_row.plip_id,9999)
        then
          --
          l_comp_obj_tree_row := l_comp_obj_tree(bcolele_num);
          --
          exit;
          --
        end if;
        --
      end loop;
      --
      -- Detect comp object list information
      --
      ben_efc_adjustments.DetectBCOLRowInfo
        (p_comp_obj_tree_row => l_comp_obj_tree_row
        ,p_effective_date    => l_efc_row.lf_evt_ocrd_dt
        ,p_business_group_id => l_efc_row.business_group_id
        --
        ,p_faterr_code       => l_faterr_code
        );
      --
    end if;
    --
    if l_faterr_code is null then
      --
      -- Check the comp object type
      --
      if l_comp_obj_tree_row.plip_id is not null then
        --
        l_coent_scode := 'CPP';
        l_compobj_id  := l_comp_obj_tree_row.plip_id;
        --
      elsif l_comp_obj_tree_row.pl_id is not null then
        --
        l_coent_scode := 'PLN';
        l_compobj_id  := l_comp_obj_tree_row.pl_id;
        --
      elsif l_comp_obj_tree_row.ptip_id is not null then
        --
        l_coent_scode := 'CTP';
        l_compobj_id  := l_comp_obj_tree_row.ptip_id;
        --
      elsif l_comp_obj_tree_row.pgm_id is not null then
        --
        l_coent_scode := 'PGM';
        l_compobj_id  := l_comp_obj_tree_row.pgm_id;
        --
      end if;
      --
      ben_efc_functions.CompObject_ChkAttachDF
        (p_coent_scode => l_coent_scode
        ,p_compobj_id  => l_compobj_id
        --
        ,p_counts      => l_df_counts
        );
      --
      if l_df_counts.noattdf_count = 0 then
        --
        l_faterr_code   := 'NOATTDF';
        --
      end if;
      --
    end if;
    --
    if l_faterr_code is null then
      --
      -- Set up benefits environment
      --
      ben_env_object.init
        (p_business_group_id => l_efc_row.business_group_id
        ,p_effective_date    => l_efc_row.lf_evt_ocrd_dt
        ,p_thread_id         => 1
        ,p_chunk_size        => 10
        ,p_threads           => 1
        ,p_max_errors        => 100
        ,p_benefit_action_id => 99999
        ,p_audit_log_flag    => 'N'
        );
      --
      -- Get person info
      --
      ben_person_object.get_object
        (p_person_id => l_efc_row.person_id
        ,p_rec       => l_per_row
        );
      --
      ben_person_object.get_object
        (p_person_id => l_efc_row.person_id
        ,p_rec       => l_empasg_row
        );
      --
      ben_person_object.get_benass_object
        (p_person_id => l_efc_row.person_id
        ,p_rec       => l_benasg_row
        );
      --
      ben_person_object.get_object
        (p_person_id => l_efc_row.person_id
        ,p_rec       => l_pil_row
        );
      --
      l_comp_rec:=l_d_comp_rec;
      l_oiplip_rec:=l_d_oiplip_rec;
      --
      begin
        --
        ben_derive_part_and_rate_facts.derive_rates_and_factors
          (p_calculate_only_mode => TRUE
          ,p_comp_obj_tree_row   => l_comp_obj_tree_row
          --
          -- Context info
          --
          ,p_per_row             => l_per_row
          ,p_empasg_row          => l_empasg_row
          ,p_benasg_row          => l_benasg_row
          ,p_pil_row             => l_pil_row
          --
          ,p_mode                => l_mode
          --
          ,p_effective_date      => l_efc_row.lf_evt_ocrd_dt
          ,p_lf_evt_ocrd_dt      => l_efc_row.lf_evt_ocrd_dt
          ,p_person_id           => l_efc_row.person_id
          ,p_business_group_id   => l_efc_row.business_group_id
          ,p_pgm_id              => l_comp_obj_tree_row.pgm_id
          ,p_pl_id               => l_comp_obj_tree_row.pl_id
          ,p_oipl_id             => l_comp_obj_tree_row.oipl_id
          ,p_plip_id             => l_comp_obj_tree_row.plip_id
          ,p_ptip_id             => l_comp_obj_tree_row.ptip_id
          --
          ,p_comp_rec            => l_comp_rec
          ,p_oiplip_rec          => l_oiplip_rec
          );
        --
        if nvl(l_comp_rec.comp_ref_amt,9999) <> nvl(l_efc_row.comp_ref_amt,9999)
        then
          --
          g_pep_failed_adj_val_set(l_calfail_count).id       := l_efc_row.elig_per_id;
          g_pep_failed_adj_val_set(l_calfail_count).esd      := l_efc_row.effective_start_date;
          g_pep_failed_adj_val_set(l_calfail_count).eed      := l_efc_row.effective_end_date;
          g_pep_failed_adj_val_set(l_calfail_count).old_val1 := l_efc_row.comp_ref_amt;
          g_pep_failed_adj_val_set(l_calfail_count).new_val1 := l_comp_rec.comp_ref_amt;
          g_pep_failed_adj_val_set(l_calfail_count).val_type := 'PEP_CRAMT';
          g_pep_failed_adj_val_set(l_calfail_count).lud      := l_efc_row.last_update_date;
          g_pep_failed_adj_val_set(l_calfail_count).credt    := l_efc_row.creation_date;
          --
          l_adjfailed := TRUE;
          l_calfail_count := l_calfail_count+1;
          --
        elsif nvl(l_comp_rec.rt_comp_ref_amt,9999) <> nvl(l_efc_row.rt_comp_ref_amt,9999)
        then
          --
          g_pep_failed_adj_val_set(l_calfail_count).id       := l_efc_row.elig_per_id;
          g_pep_failed_adj_val_set(l_calfail_count).esd      := l_efc_row.effective_start_date;
          g_pep_failed_adj_val_set(l_calfail_count).eed      := l_efc_row.effective_end_date;
          g_pep_failed_adj_val_set(l_calfail_count).old_val1 := l_efc_row.rt_comp_ref_amt;
          g_pep_failed_adj_val_set(l_calfail_count).new_val1 := l_comp_rec.rt_comp_ref_amt;
          g_pep_failed_adj_val_set(l_calfail_count).val_type := 'PEP_RTCRAMT';
          g_pep_failed_adj_val_set(l_calfail_count).lud      := l_efc_row.last_update_date;
          g_pep_failed_adj_val_set(l_calfail_count).credt    := l_efc_row.creation_date;
          --
          l_adjfailed := TRUE;
          l_calfail_count := l_calfail_count+1;
          --
        else
          --
          l_adjfailed := FALSE;
          --
        end if;
        --
        if l_adjfailed
          and l_faterr_code is null
        then
          --
          -- WHO checks
          --
          if l_faterr_code is null then
            --
            ben_efc_adjustments.DetectWhoInfo
              (p_creation_date         => l_efc_row.creation_date
              ,p_last_update_date      => l_efc_row.last_update_date
              ,p_object_version_number => l_efc_row.object_version_number
              --
              ,p_who_counts            => l_who_counts
              ,p_faterr_code           => l_faterr_code
              ,p_faterr_type           => l_faterr_type
              );
            --
          end if;
          --
        end if;
        --
        if l_efc_batch
          and l_faterr_code is null
        then
          --
          update ben_elig_per_f pep
          set    pep.comp_ref_amt         = l_comp_rec.comp_ref_amt,
                 pep.rt_comp_ref_amt      = l_comp_rec.rt_comp_ref_amt
          where  pep.elig_per_id          = l_efc_row.elig_per_id
          and    pep.effective_start_date = l_efc_row.effective_start_date
          and    pep.effective_end_date   = l_efc_row.effective_end_date;
          --
          if p_validate then
            --
            rollback;
            --
          end if;
          --
          -- Check for end of chunk and commit if necessary
          --
          l_pk1 := l_efc_row.elig_per_id;
          --
          ben_efc_functions.maintain_chunks
            (p_row_count     => l_row_count
            ,p_pk1           => l_pk1
            ,p_chunk_size    => p_chunk
            ,p_efc_worker_id => p_efc_worker_id
            );
          --
        end if;
        --
      exception
        when others then
          --
          g_pep_rcoerr_val_set(l_rcoerr_count).id        := l_efc_row.elig_per_id;
          g_pep_rcoerr_val_set(l_rcoerr_count).esd       := l_efc_row.effective_start_date;
          g_pep_rcoerr_val_set(l_rcoerr_count).eed       := l_efc_row.effective_end_date;
          g_pep_rcoerr_val_set(l_rcoerr_count).rco_name  := 'BENDRPAR';
          g_pep_rcoerr_val_set(l_rcoerr_count).sql_error := SQLERRM;
          g_pep_rcoerr_val_set(l_rcoerr_count).lud       := l_efc_row.last_update_date;
          g_pep_rcoerr_val_set(l_rcoerr_count).credt     := l_efc_row.creation_date;
          --
          l_rcoerr_count := l_rcoerr_count+1;
          --
      end;
      --
    end if;
    --
    -- Check for fatal errors
    --
    if l_faterr_code is not null
    then
      --
      g_pep_fatal_error_val_set(l_faterrs_count).id          := l_efc_row.elig_per_id;
      g_pep_fatal_error_val_set(l_faterrs_count).esd         := l_efc_row.effective_start_date;
      g_pep_fatal_error_val_set(l_faterrs_count).eed         := l_efc_row.effective_end_date;
      g_pep_fatal_error_val_set(l_faterrs_count).old_val1    := l_efc_row.comp_ref_amt;
      g_pep_fatal_error_val_set(l_faterrs_count).faterr_code := l_faterr_code;
      g_pep_fatal_error_val_set(l_faterrs_count).faterr_type := l_faterr_type;
      g_pep_fatal_error_val_set(l_faterrs_count).lud         := l_efc_row.last_update_date;
      g_pep_fatal_error_val_set(l_faterrs_count).credt       := l_efc_row.creation_date;
      --
      l_faterrs_count := l_faterrs_count+1;
      --
    elsif l_faterr_code is null
      and not l_adjfailed
    then
      --
      g_pep_success_adj_val_set(l_calsucc_count).id          := l_efc_row.elig_per_id;
      g_pep_success_adj_val_set(l_calsucc_count).esd         := l_efc_row.effective_start_date;
      g_pep_success_adj_val_set(l_calsucc_count).eed         := l_efc_row.effective_end_date;
      g_pep_success_adj_val_set(l_calsucc_count).old_val1    := l_efc_row.comp_ref_amt;
      g_pep_success_adj_val_set(l_calsucc_count).lud         := l_efc_row.last_update_date;
      g_pep_success_adj_val_set(l_calsucc_count).credt       := l_efc_row.creation_date;
      --
      l_calsucc_count := l_calsucc_count+1;
      --
    end if;
    --
    l_row_count := l_row_count+1;
    --
  end loop;
  CLOSE c_efc_rows;
  --
  ben_efc_functions.conv_check
    (p_table_name      => 'ben_elig_per_f'
    ,p_efctable_name   => 'ben_elig_per_f_efc'
    --
    ,p_tabwhere_clause => ' (comp_ref_amt is not null '
                          ||' or rt_comp_ref_amt is not null) '
    ,p_bgp_id        => p_business_group_id
    ,p_action_id     => p_action_id
    --
    ,p_conv_count    => l_conv_count
    ,p_unconv_count  => l_unconv_count
    ,p_tabrow_count  => l_tabrow_count
    );
  --
  -- Set counts
  --
  if p_action_id is null then
    --
    l_actconv_count := 0;
    --
  else
    --
    l_actconv_count := l_conv_count;
    --
  end if;
  --
  p_adjustment_counts.efcrow_count       := l_row_count;
  p_adjustment_counts.rcoerr_count       := l_rcoerr_count;
  p_adjustment_counts.tabrow_count       := l_tabrow_count;
  --
  p_adjustment_counts.calfail_count      := l_calfail_count;
  p_adjustment_counts.calsucc_count      := l_calsucc_count;
  p_adjustment_counts.dupconv_count      := l_dupconv_count;
  p_adjustment_counts.conv_count         := l_conv_count;
  p_adjustment_counts.actconv_count      := l_actconv_count;
  p_adjustment_counts.unconv_count       := l_unconv_count;
  --
end pep_adjustments;
--
procedure epo_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy g_adjustment_counts
  )
is
  --
  TYPE cur_type IS REF CURSOR;
  --
  type g_efc_row is record
    (elig_per_opt_id       ben_elig_per_opt_f.elig_per_opt_id%type
    ,effective_start_date  ben_elig_per_opt_f.effective_start_date%type
    ,effective_end_date    ben_elig_per_opt_f.effective_end_date%type
    ,comp_ref_amt          ben_elig_per_opt_f.comp_ref_amt%type
    ,rt_comp_ref_amt       ben_elig_per_opt_f.rt_comp_ref_amt%type
    ,person_id             ben_elig_per_f.person_id%type
    ,pgm_id                ben_elig_per_f.pgm_id%type
    ,pl_id                 ben_elig_per_f.pl_id%type
    ,opt_id                ben_elig_per_opt_f.opt_id%type
    ,business_group_id     ben_elig_per_opt_f.business_group_id%type
    ,lf_evt_ocrd_dt        ben_per_in_ler.lf_evt_ocrd_dt%type
    ,creation_date         ben_elig_per_opt_f.creation_date%type
    ,last_update_date      ben_elig_per_opt_f.last_update_date%type
    ,object_version_number ben_elig_per_opt_f.object_version_number%type
    ,per_in_ler_id         ben_elig_per_opt_f.per_in_ler_id%type
    );
  --
  c_efc_rows       cur_type;
  --
  l_proc           varchar2(1000) := 'epo_adjustments';
  --
  l_efc_row        g_efc_row;
  --
  l_who_counts             g_who_counts;
  --
  l_row_count              pls_integer;
  l_calfail_count          pls_integer;
  l_calsucc_count          pls_integer;
  l_nomatco_count          pls_integer;
  l_noattdf_count          pls_integer;
  l_nocmpattdf_count       pls_integer;
  l_conv_count             pls_integer;
  l_unconv_count           pls_integer;
  l_actconv_count          pls_integer;
  l_dupconv_count          pls_integer;
  l_oipl_count             pls_integer;
  l_oiplip_count           pls_integer;
  --
  l_rcoerr_count           pls_integer;
  l_bcolrcoerr_count       pls_integer;
  l_pbbepocorr_count       pls_integer;
  l_pbbenddate_count       pls_integer;
  --
  l_olddata                boolean;
  --
  l_tabrow_count           pls_integer;
  --
  l_succepocra_count       pls_integer;
  l_succeporcra_count      pls_integer;
  --
  l_epopildtupd_count      pls_integer;
  l_faterrs_count          pls_integer;
  --
  l_fatal_error            boolean;
  l_sql_str                long;
  l_from_str               long;
  l_where_str              long;
  --
  l_efc_batch              boolean;
  l_mode                   varchar2(100);
  --
  l_nomatco                boolean;
  l_noattdf                boolean;
  l_nocmpattdf             boolean;
  --
  l_comp_obj_tree          ben_manage_life_events.g_cache_proc_object_table;
  l_comp_obj_tree_row      ben_manage_life_events.g_cache_proc_objects_rec;
  l_init_comp_obj_tree_row ben_manage_life_events.g_cache_proc_objects_rec;
  l_df_counts              ben_efc_functions.g_attach_df_counts;
  l_per_row                per_all_people_f%ROWTYPE;
  l_empasg_row             per_all_assignments_f%ROWTYPE;
  l_benasg_row             per_all_assignments_f%ROWTYPE;
  l_pil_row                ben_per_in_ler%rowtype;
  l_comp_rec               ben_derive_part_and_rate_facts.g_cache_structure;
  l_d_comp_rec             ben_derive_part_and_rate_facts.g_cache_structure;
  l_oiplip_rec             ben_derive_part_and_rate_facts.g_cache_structure;
  l_d_oiplip_rec           ben_derive_part_and_rate_facts.g_cache_structure;
  --
  l_coent_scode            varchar2(100);
  l_compobj_id             number;
  l_pk1                    number;
  --
  l_oipl_id                number;
  l_oiplip_id              number;
  l_prevbgp_id             number;
  --
  CURSOR c_oipl
    (c_opt_id   in number
    ,c_pl_id    in number
    ,c_eff_date in date
    )
  IS
    select cop.oipl_id
    FROM ben_oipl_f cop
    where cop.opt_id = c_opt_id
    and   cop.pl_id  = c_pl_id
    and   c_eff_date
      between cop.effective_start_date and cop.effective_end_date;
  --
  CURSOR c_oiplip
    (c_oipl_id  in number
    ,c_plip_id  in number
    ,c_eff_date in date
    )
  IS
    select opp.oiplip_id
    FROM ben_oiplip_f opp
    where opp.oipl_id = c_oipl_id
    and   opp.plip_id = c_plip_id
    and   c_eff_date
      between opp.effective_start_date and opp.effective_end_date;
  --
  CURSOR c_pbbdets
    (c_person_id in number
    ,c_eff_date  in date
    )
  IS
    select pbb.per_bnfts_bal_id,
           pbb.last_update_date,
           pbb.object_version_number,
           pbb.effective_end_date
    FROM ben_per_bnfts_bal_f pbb
    where pbb.person_id = c_person_id
    order by pbb.per_bnfts_bal_id;
  --
  l_pbbdets  c_pbbdets%rowtype;
  --
  CURSOR c_epopildtupd
    (c_per_in_ler_id   in number
    ,c_elig_per_opt_id in number
    )
  IS
    select epo.elig_per_opt_id,
           count(*)
    FROM ben_elig_per_opt_f epo
    where epo.per_in_ler_id   = c_per_in_ler_id
    and   epo.elig_per_opt_id = c_elig_per_opt_id
    group by epo.elig_per_opt_id
    having count(*) > 1;
  --
  l_epopildtupd  c_epopildtupd%rowtype;
  --
  l_faterr_code    varchar2(100);
  l_faterr_type    varchar2(100);
  l_adjfailed      boolean;
  --
begin
  --
  l_efc_batch        := FALSE;
  --
  l_row_count        := 0;
  l_calfail_count    := 0;
  l_calsucc_count    := 0;
  l_dupconv_count    := 0;
  l_conv_count       := 0;
  l_actconv_count    := 0;
  l_unconv_count     := 0;
  --
  l_rcoerr_count     := 0;
  l_faterrs_count    := 0;
  --
  g_epo_success_adj_val_set.delete;
  g_epo_failed_adj_val_set.delete;
  g_epo_rcoerr_val_set.delete;
  g_epo_fatal_error_val_set.delete;
  --
  l_mode             := 'L';
  --
  -- Check if EFC process parameters are set
  --
  if p_action_id is not null
    and p_pk1 is not null
    and p_chunk is not null
    and p_efc_worker_id is not null
  then
    --
    l_efc_batch := TRUE;
    --
  end if;
  --
  l_from_str := ' FROM ben_elig_per_opt_f epo, '
                ||'      ben_elig_per_f pep, '
                ||'      ben_per_in_ler pil, '
                ||'      per_all_people_f per ';
  --
  l_where_str := ' where epo.elig_per_id = pep.elig_per_id '
                 ||' and epo.effective_start_date '
                 ||'   between pep.effective_start_date and pep.effective_end_date '
                 ||' and epo.per_in_ler_id        = pil.per_in_ler_id '
                 ||' and   epo.opt_id is not null '
                 ||' and (epo.comp_ref_amt is not null '
                 ||'     or epo.rt_comp_ref_amt is not null) '
                 ||' and pil.person_id            = per.person_id '
                 ||' and pil.LF_EVT_OCRD_DT '
                 ||'   between per.effective_start_date and per.effective_end_date ';
  --
  -- Check if we are restricting by business group
  --
  if p_business_group_id is not null then
    --
    l_where_str := l_where_str||' and epo.business_group_id = '||p_business_group_id;
    --
  end if;
  --
  -- Build in batch specific restrictions
  --
  if l_efc_batch then
    --
    l_from_str  := l_from_str||', ben_elig_per_opt_f_efc efc ';
    l_where_str := l_where_str||' and   efc.elig_per_opt_id = epo.elig_per_opt_id '
                   ||' and   efc.effective_start_date = epo.effective_start_date '
                   ||' and   efc.effective_end_date   = epo.effective_end_date '
                   ||' and   efc.efc_action_id        = :action_id '
                   ||' and   epo.elig_per_opt_id      > :pk1 '
                   ||' and   mod(epo.elig_per_opt_id, :total_workers) = :worker_id ';
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    l_where_str := l_where_str||' and mod(epo.elig_per_opt_id, :valtotal_workers) = :valworker_id ';
    --
  end if;
  --
  l_sql_str  := ' select epo.elig_per_opt_id, '
               ||'       epo.effective_start_date, '
               ||'       epo.effective_end_date, '
               ||'       epo.comp_ref_amt, '
               ||'       epo.rt_comp_ref_amt, '
               ||'       pep.person_id, '
               ||'       pep.pgm_id, '
               ||'       pep.pl_id, '
               ||'       epo.opt_id, '
               ||'       pep.business_group_id, '
               ||'       pil.lf_evt_ocrd_dt, '
               ||'       epo.creation_date, '
               ||'       epo.last_update_date, '
               ||'       epo.object_version_number, '
               ||'       epo.per_in_ler_id '
               ||l_from_str
               ||l_where_str
               ||' order by epo.elig_per_opt_id ';
  --
  if l_efc_batch then
    --
    hr_efc_info.insert_line('-- ');
    hr_efc_info.insert_line('-- Adjusting elig per options ');
    hr_efc_info.insert_line('-- ');
    --
    open c_efc_rows FOR l_sql_str using p_action_id, p_pk1, p_total_workers, p_worker_id;
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    open c_efc_rows FOR l_sql_str using p_valtotal_workers, p_valworker_id;
    --
  else
    --
    open c_efc_rows FOR l_sql_str;
    --
  end if;
  --
  loop
    FETCH c_efc_rows INTO l_efc_row;
    EXIT WHEN c_efc_rows%NOTFOUND;
    --
    l_fatal_error := FALSE;
    l_faterr_code := null;
    --
    -- WHO checks
    --
    ben_efc_adjustments.DetectWhoInfo
      (p_creation_date         => l_efc_row.creation_date
      ,p_last_update_date      => l_efc_row.last_update_date
      ,p_object_version_number => l_efc_row.object_version_number
      ,p_who_counts            => l_who_counts
      ,p_faterr_code           => l_faterr_code
      ,p_faterr_type           => l_faterr_type
      );
    --
    -- Check for old data
    --
    if l_faterr_code is not null then
      --
      l_fatal_error  := TRUE;
      --
    end if;
    --
    if not l_fatal_error then
      --
      -- Check for multiple DT instances for an EPO within a PIL
      --
      open c_epopildtupd
        (c_per_in_ler_id   => l_efc_row.per_in_ler_id
        ,c_elig_per_opt_id => l_efc_row.elig_per_opt_id
        );
      fetch c_epopildtupd into l_epopildtupd;
      if c_epopildtupd%found then
        --
        l_faterr_code := 'EPOPILDTUPD';
        l_fatal_error := TRUE;
        --
      end if;
      close c_epopildtupd;
      --
    end if;
    --
    if not l_fatal_error then
      --
      ben_derive_part_and_rate_cache.clear_down_cache;
      ben_person_object.clear_down_cache;
      ben_pil_object.clear_down_cache;
      --
      if nvl(l_prevbgp_id,-9999) <> l_efc_row.business_group_id then
        --
        ben_manage_life_events.g_cache_proc_object.delete;
        --
      end if;
      --
      begin
        --
        -- Set up comp object list
        --
        ben_comp_object_list.build_comp_object_list
          (p_effective_date         => l_efc_row.lf_evt_ocrd_dt
          ,p_business_group_id      => l_efc_row.business_group_id
          ,p_mode                   => l_mode
          );
        --
        l_prevbgp_id := l_efc_row.business_group_id;
        l_comp_obj_tree := ben_manage_life_events.g_cache_proc_object;
        --
        -- Set comp object context values
        --
        l_comp_obj_tree_row := l_init_comp_obj_tree_row;
        --
      exception
        when others then
          --
          g_epo_rcoerr_val_set(l_rcoerr_count).id        := l_efc_row.elig_per_opt_id;
          g_epo_rcoerr_val_set(l_rcoerr_count).esd       := l_efc_row.effective_start_date;
          g_epo_rcoerr_val_set(l_rcoerr_count).eed       := l_efc_row.effective_end_date;
          g_epo_rcoerr_val_set(l_rcoerr_count).rco_name  := 'BCOL';
          g_epo_rcoerr_val_set(l_rcoerr_count).sql_error := SQLERRM;
          --
          l_rcoerr_count     := l_rcoerr_count+1;
          l_fatal_error      := TRUE;
          --
      end;
      --
    end if;
    --
    if l_comp_obj_tree.count > 0
      and not l_fatal_error
    then
      --
      for bcolele_num in l_comp_obj_tree.first..l_comp_obj_tree.last
      loop
        --
        if nvl(l_comp_obj_tree(bcolele_num).par_pgm_id,9999) = nvl(l_efc_row.pgm_id,9999)
          and nvl(l_comp_obj_tree(bcolele_num).par_pl_id,9999) = nvl(l_efc_row.pl_id,9999)
          and nvl(l_comp_obj_tree(bcolele_num).par_opt_id,9999) = nvl(l_efc_row.opt_id,9999)
        then
          --
          l_comp_obj_tree_row := l_comp_obj_tree(bcolele_num);
          --
          exit;
          --
        end if;
        --
      end loop;
      --
      -- Detect comp object list information
      --
      ben_efc_adjustments.DetectBCOLRowInfo
        (p_comp_obj_tree_row => l_comp_obj_tree_row
        ,p_effective_date    => l_efc_row.lf_evt_ocrd_dt
        ,p_business_group_id => l_efc_row.business_group_id
        --
        ,p_faterr_code       => l_faterr_code
        );
      --
      -- Check fatal BCOL errors
      --
      if l_faterr_code is not null
      then
        --
        l_fatal_error   := TRUE;
        --
      end if;
      --
    end if;
    --
    if not l_fatal_error then
      --
      open c_oipl
        (c_opt_id   => l_efc_row.opt_id
        ,c_pl_id    => l_efc_row.pl_id
        ,c_eff_date => l_efc_row.lf_evt_ocrd_dt
        );
      fetch c_oipl into l_oipl_id;
      if c_oipl%found then
        --
        open c_oiplip
          (c_oipl_id  => l_oipl_id
          ,c_plip_id  => l_comp_obj_tree_row.par_plip_id
          ,c_eff_date => l_efc_row.lf_evt_ocrd_dt
          );
        fetch c_oiplip into l_oiplip_id;
        if c_oiplip%found then
          --
          l_oiplip_count := l_oiplip_count+1;
          --
        end if;
        close c_oiplip;
        --
        l_oipl_count := l_oipl_count+1;
        --
        -- Check for attached derived factors
        --
        ben_efc_functions.CompObject_ChkAttachDF
          (p_coent_scode => 'COP'
          ,p_compobj_id  => l_oipl_id
          --
          ,p_counts      => l_df_counts
          );
        --
        if l_df_counts.noattdf_count = 0 then
          --
          l_faterr_code   := 'NOATTDF';
          l_fatal_error   := TRUE;
          --
        end if;
        --
      end if;
      close c_oipl;
      --
    end if;
    --
    if not l_fatal_error then
      --
      -- Set up benefits environment
      --
      ben_env_object.init
        (p_business_group_id => l_efc_row.business_group_id
        ,p_effective_date    => l_efc_row.lf_evt_ocrd_dt
        ,p_thread_id         => 1
        ,p_chunk_size        => 10
        ,p_threads           => 1
        ,p_max_errors        => 100
        ,p_benefit_action_id => 99999
        ,p_audit_log_flag    => 'N'
        );
      --
      -- Get person info
      --
      ben_person_object.get_object
        (p_person_id => l_efc_row.person_id
        ,p_rec       => l_per_row
        );
      --
      ben_person_object.get_object
        (p_person_id => l_efc_row.person_id
        ,p_rec       => l_empasg_row
        );
      --
      ben_person_object.get_benass_object
        (p_person_id => l_efc_row.person_id
        ,p_rec       => l_benasg_row
        );
      --
      ben_person_object.get_object
        (p_person_id => l_efc_row.person_id
        ,p_rec       => l_pil_row
        );
      --
      -- Check for modified person benefit balances
      --
      for row in c_pbbdets
        (c_person_id => l_efc_row.person_id
        ,c_eff_date  => l_efc_row.lf_evt_ocrd_dt
        )
      loop
        --
        -- Check for a modified PBB since the EPO was last updated
        --
        if row.last_update_date > l_efc_row.last_update_date then
          --
          l_fatal_error      := TRUE;
          l_faterr_code      := 'PBBEPOCORR';
          exit;
          --
        end if;
        --
        -- Check for a end dated PBB
        --
        if row.effective_end_date <> hr_api.g_eot
        then
          --
          l_fatal_error      := TRUE;
          l_faterr_code      := 'PBBENDDATE';
          exit;
          --
        end if;
        --
      end loop;
      --
      if not l_fatal_error then
        --
        l_comp_rec:=l_d_comp_rec;
        l_oiplip_rec:=l_d_oiplip_rec;
        --
        begin
          --
          ben_derive_part_and_rate_facts.derive_rates_and_factors
            (p_comp_obj_tree_row   => l_comp_obj_tree_row
            --
            -- Context info
            --
            ,p_per_row             => l_per_row
            ,p_empasg_row          => l_empasg_row
            ,p_benasg_row          => l_benasg_row
            ,p_pil_row             => l_pil_row
            --
            ,p_mode                => l_mode
            --
            ,p_effective_date      => l_efc_row.lf_evt_ocrd_dt
            ,p_lf_evt_ocrd_dt      => l_efc_row.lf_evt_ocrd_dt
            ,p_person_id           => l_efc_row.person_id
            ,p_business_group_id   => l_efc_row.business_group_id
            ,p_pgm_id              => l_comp_obj_tree_row.pgm_id
            ,p_pl_id               => l_comp_obj_tree_row.pl_id
            ,p_oipl_id             => l_comp_obj_tree_row.oipl_id
            ,p_plip_id             => l_comp_obj_tree_row.plip_id
            ,p_ptip_id             => l_comp_obj_tree_row.ptip_id
            --
            ,p_comp_rec            => l_comp_rec
            ,p_oiplip_rec          => l_oiplip_rec
            );
          --
          if nvl(l_comp_rec.comp_ref_amt,9999) <> nvl(l_efc_row.comp_ref_amt,9999)
          then
            --
            g_epo_failed_adj_val_set(l_calfail_count).id       := l_efc_row.elig_per_opt_id;
            g_epo_failed_adj_val_set(l_calfail_count).esd      := l_efc_row.effective_start_date;
            g_epo_failed_adj_val_set(l_calfail_count).eed      := l_efc_row.effective_end_date;
            g_epo_failed_adj_val_set(l_calfail_count).old_val1 := l_efc_row.comp_ref_amt;
            g_epo_failed_adj_val_set(l_calfail_count).new_val1 := l_comp_rec.comp_ref_amt;
            g_epo_failed_adj_val_set(l_calfail_count).val_type := 'EPO_CRAMT';
            g_epo_failed_adj_val_set(l_calfail_count).lud      := l_efc_row.last_update_date;
            g_epo_failed_adj_val_set(l_calfail_count).credt    := l_efc_row.creation_date;
            --
            l_adjfailed     := TRUE;
            l_calfail_count := l_calfail_count+1;
            --
          elsif nvl(l_comp_rec.rt_comp_ref_amt,9999) <> nvl(l_efc_row.rt_comp_ref_amt,9999)
          then
            --
            g_epo_failed_adj_val_set(l_calfail_count).id       := l_efc_row.elig_per_opt_id;
            g_epo_failed_adj_val_set(l_calfail_count).esd      := l_efc_row.effective_start_date;
            g_epo_failed_adj_val_set(l_calfail_count).eed      := l_efc_row.effective_end_date;
            g_epo_failed_adj_val_set(l_calfail_count).old_val1 := l_efc_row.rt_comp_ref_amt;
            g_epo_failed_adj_val_set(l_calfail_count).new_val1 := l_comp_rec.rt_comp_ref_amt;
            g_epo_failed_adj_val_set(l_calfail_count).val_type := 'EPO_RTCRAMT';
            g_epo_failed_adj_val_set(l_calfail_count).lud      := l_efc_row.last_update_date;
            g_epo_failed_adj_val_set(l_calfail_count).credt    := l_efc_row.creation_date;
            --
            l_adjfailed     := TRUE;
            l_calfail_count := l_calfail_count+1;
            --
          else
            --
            l_adjfailed     := FALSE;
            --
          end if;
          --
          if l_efc_batch
            and l_faterr_code is null
          then
            --
            update ben_elig_per_opt_f epo
            set    epo.comp_ref_amt         = l_comp_rec.comp_ref_amt,
                   epo.rt_comp_ref_amt      = l_comp_rec.rt_comp_ref_amt
            where  epo.elig_per_opt_id      = l_efc_row.elig_per_opt_id
            and    epo.effective_start_date = l_efc_row.effective_start_date
            and    epo.effective_end_date   = l_efc_row.effective_end_date;
            --
            if p_validate then
              --
              rollback;
              --
            end if;
            --
            -- Check for end of chunk and commit if necessary
            --
            l_pk1 := l_efc_row.elig_per_opt_id;
            --
            ben_efc_functions.maintain_chunks
              (p_row_count     => l_row_count
              ,p_pk1           => l_pk1
              ,p_chunk_size    => p_chunk
              ,p_efc_worker_id => p_efc_worker_id
              );
            --
          end if;
          --
        exception
          when others then
            --
            g_epo_rcoerr_val_set(l_rcoerr_count).id        := l_efc_row.elig_per_opt_id;
            g_epo_rcoerr_val_set(l_rcoerr_count).esd       := l_efc_row.effective_start_date;
            g_epo_rcoerr_val_set(l_rcoerr_count).eed       := l_efc_row.effective_end_date;
            g_epo_rcoerr_val_set(l_rcoerr_count).rco_name  := 'BENDRPAR';
            g_epo_rcoerr_val_set(l_rcoerr_count).sql_error := SQLERRM;
            g_epo_rcoerr_val_set(l_rcoerr_count).lud       := l_efc_row.last_update_date;
            g_epo_rcoerr_val_set(l_rcoerr_count).credt     := l_efc_row.creation_date;
            --
            l_rcoerr_count := l_rcoerr_count+1;
            --
        end;
        --
      end if;
      --
    end if;
    --
    -- Check for fatal errors
    --
    if l_faterr_code is not null
    then
      --
      g_epo_fatal_error_val_set(l_faterrs_count).id          := l_efc_row.elig_per_opt_id;
      g_epo_fatal_error_val_set(l_faterrs_count).esd         := l_efc_row.effective_start_date;
      g_epo_fatal_error_val_set(l_faterrs_count).eed         := l_efc_row.effective_end_date;
      g_epo_fatal_error_val_set(l_faterrs_count).faterr_code := l_faterr_code;
      g_epo_fatal_error_val_set(l_faterrs_count).lud         := l_efc_row.last_update_date;
      g_epo_fatal_error_val_set(l_faterrs_count).credt       := l_efc_row.creation_date;
      --
      l_faterrs_count := l_faterrs_count+1;
    --
    elsif l_faterr_code is null
      and not l_adjfailed
    then
      --
      g_epo_success_adj_val_set(l_calsucc_count).id          := l_efc_row.elig_per_opt_id;
      g_epo_success_adj_val_set(l_calsucc_count).esd         := l_efc_row.effective_start_date;
      g_epo_success_adj_val_set(l_calsucc_count).eed         := l_efc_row.effective_end_date;
      g_epo_success_adj_val_set(l_calsucc_count).lud         := l_efc_row.last_update_date;
      g_epo_success_adj_val_set(l_calsucc_count).credt       := l_efc_row.creation_date;
      --
      l_calsucc_count := l_calsucc_count+1;
      --
    end if;
    --
    l_row_count := l_row_count+1;
    --
  end loop;
  CLOSE c_efc_rows;
  --
  -- Check that all rows have been converted or excluded
  --
  ben_efc_functions.conv_check
    (p_table_name      => 'ben_elig_per_opt_f'
    ,p_efctable_name   => 'ben_elig_per_opt_f_efc'
    ,p_tabwhere_clause => ' (comp_ref_amt is not null '
                          ||' or rt_comp_ref_amt is not null) '
    --
    ,p_bgp_id          => p_business_group_id
    ,p_action_id       => p_action_id
    --
    ,p_conv_count      => l_conv_count
    ,p_unconv_count    => l_unconv_count
    ,p_tabrow_count    => l_tabrow_count
    );
  --
  -- Set counts
  --
  if p_action_id is null then
    --
    l_actconv_count := 0;
    --
  else
    --
    l_actconv_count := l_conv_count;
    --
  end if;
  --
  p_adjustment_counts.efcrow_count       := l_row_count;
  p_adjustment_counts.tabrow_count       := l_tabrow_count;
  p_adjustment_counts.calfail_count      := l_calfail_count;
  p_adjustment_counts.calsucc_count      := l_calsucc_count;
  p_adjustment_counts.rcoerr_count       := l_rcoerr_count;
  p_adjustment_counts.dupconv_count      := l_dupconv_count;
  p_adjustment_counts.conv_count         := l_conv_count;
  p_adjustment_counts.actconv_count      := l_actconv_count;
  p_adjustment_counts.unconv_count       := l_unconv_count;
  --
end epo_adjustments;
--
procedure enb_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy g_adjustment_counts
  )
is
  --
  TYPE cur_type IS REF CURSOR;
  --
  type g_efc_row is record
    (enrt_bnft_id           ben_enrt_bnft.enrt_bnft_id%type
    ,elig_per_elctbl_chc_id ben_enrt_bnft.elig_per_elctbl_chc_id%type
    ,business_group_id      ben_enrt_bnft.business_group_id%type
    ,mx_wout_ctfn_val       ben_enrt_bnft.mx_wout_ctfn_val%type
    ,mn_val                 ben_enrt_bnft.mn_val%type
    ,mx_val                 ben_enrt_bnft.mx_val%type
    ,incrmt_val             ben_enrt_bnft.incrmt_val%type
    ,dflt_val               ben_enrt_bnft.dflt_val%type
    ,val                    ben_enrt_bnft.val%type
    ,pgm_id                 ben_elig_per_elctbl_chc.pgm_id%type
    ,pl_id                  ben_elig_per_elctbl_chc.pl_id%type
    ,pl_typ_id              ben_elig_per_elctbl_chc.pl_typ_id%type
    ,ptip_id                ben_elig_per_elctbl_chc.ptip_id%type
    ,plip_id                ben_elig_per_elctbl_chc.plip_id%type
    ,oipl_id                ben_elig_per_elctbl_chc.oipl_id%type
    ,prtt_enrt_rslt_id      ben_elig_per_elctbl_chc.prtt_enrt_rslt_id%type
    ,epe_ovn                ben_elig_per_elctbl_chc.object_version_number%type
    ,elctbl_flag            ben_elig_per_elctbl_chc.elctbl_flag%type
    ,per_in_ler_id          ben_per_in_ler.per_in_ler_id%type
    ,person_id              ben_per_in_ler.person_id%type
    ,lf_evt_ocrd_dt         ben_per_in_ler.lf_evt_ocrd_dt%type
    ,ler_id                 ben_per_in_ler.ler_id%type
    ,last_update_date       ben_enrt_bnft.last_update_date%type
    ,creation_date          ben_enrt_bnft.creation_date%type
    ,object_version_number  ben_enrt_bnft.object_version_number%type
    ,cvg_mlt_cd             ben_enrt_bnft.cvg_mlt_cd%type
    );
  --
  c_efc_rows               cur_type;
  --
  l_proc                   varchar2(1000) := 'enb_adjustments';
  --
  l_efc_row                g_efc_row;
  --
  l_who_counts             g_who_counts;
  --
  l_cvg_set                ben_cvg_cache.g_epeplncvg_cache;
  --
  l_enb_valrow             ben_determine_coverage.ENBValType;
  l_perasg                 gc_perasg%rowtype;
  l_vpfdets                gc_vpfdets%rowtype;
  --
  l_currepe_row            ben_determine_rates.g_curr_epe_rec;
  --
  l_row_count              pls_integer;
  l_calfail_count          pls_integer;
  l_calsucc_count          pls_integer;
  l_conv_count             pls_integer;
  l_unconv_count           pls_integer;
  l_actconv_count          pls_integer;
  l_dupconv_count          pls_integer;
  --
  l_rcoerr_count           pls_integer;
  l_faterrs_count          pls_integer;
  --
  l_tabrow_count           pls_integer;
  --
  l_sql_str                long;
  l_from_str               long;
  l_where_str              long;
  --
  l_efc_batch              boolean;
  --
  l_pk1                    number;
  --
  l_detected               boolean;
  l_olddata                boolean;
  l_comp_value             number;
  l_faterr_code            varchar2(100);
  l_faterr_type            varchar2(100);
  --
  l_adjfailed              boolean;
  --
  l_val_type               varchar2(100);
  l_old_val1               number;
  l_new_val1               number;
  l_vpf_id                 number;
  --
  l_enb_uom                varchar2(100);
  --
  cursor c_pbb_dets
    (c_person_id    in number
    ,c_bnfts_bal_id in number
    ,c_eff_date     in date
    )
  is
    select pbb.val,
           bnb.name,
           bnb.uom
    from   ben_per_bnfts_bal_f pbb,
           ben_bnfts_bal_f bnb
    where  pbb.person_id = c_person_id
    and    pbb.bnfts_bal_id = bnb.bnfts_bal_id
    and    c_eff_date
      between bnb.effective_start_date
        and     bnb.effective_end_date
    and    c_eff_date
      between pbb.effective_start_date
        and     pbb.effective_end_date
    and    pbb.bnfts_bal_id = c_bnfts_bal_id;
  --
  l_pbb_dets c_pbb_dets%rowtype;
  --
  cursor c_clf_dets
    (c_clf_id in     number
    )
  is
    select clf.comp_src_cd,
           clf.bnfts_bal_id
    from   ben_comp_lvl_fctr clf
    where  clf.comp_lvl_fctr_id = c_clf_id;
  --
  l_clf_dets c_clf_dets%rowtype;
  --
  cursor c_ccm_dets
    (c_ccm_id   in     number
    ,c_eff_date in     date
    )
  is
    select ccm.creation_date,
           ccm.last_update_date,
           ccm.object_version_number
    from   ben_cvg_amt_calc_mthd_f ccm
    where  ccm.cvg_amt_calc_mthd_id = c_ccm_id
    and c_eff_date
      between ccm.effective_start_date and ccm.effective_end_date;
  --
  l_ccm_dets c_ccm_dets%rowtype;
  --
  cursor c_cop_dets
    (c_cop_id   in     number
    ,c_eff_date in     date
    )
  is
    select cop.creation_date,
           cop.last_update_date,
           cop.object_version_number
    from   ben_oipl_f cop
    where  cop.oipl_id = c_cop_id
    and c_eff_date
      between cop.effective_start_date and cop.effective_end_date;
  --
  l_cop_dets c_cop_dets%rowtype;
  --
  cursor c_pln_dets
    (c_pln_id   in     number
    ,c_eff_date in     date
    )
  is
    select pln.creation_date,
           pln.last_update_date,
           pln.object_version_number
    from   ben_pl_f pln
    where  pln.pl_id = c_pln_id
    and c_eff_date
      between pln.effective_start_date and pln.effective_end_date;
  --
  l_pln_dets c_pln_dets%rowtype;
  --
  cursor c_asgpppdets
    (c_per_id   in number
    ,c_eff_date in date
    )
  is
    select ppp.PAY_PROPOSAL_ID
    from   per_pay_proposals ppp,
           per_assignments_f asg
    where  ppp.assignment_id = asg.assignment_id
    and    c_eff_date
      between asg.effective_start_date and asg.effective_end_date
    and    asg.person_id = c_per_id;
  --
  l_asgpppdets c_asgpppdets%rowtype;
  --
  cursor c_pppdets
    (c_person_id in number
    ,c_eff_date  in date
    )
  is
    select ppp.proposed_salary_n proposed_salary,
           ppb.pay_basis,
           ppb.pay_annualization_factor,
           paf.period_type payroll,
           asg.normal_hours,
           asg.frequency
    from   per_pay_proposals ppp,
           per_assignments_f asg,
           per_pay_bases ppb,
           pay_all_payrolls_f paf,
           per_all_people_f per
    where  per.person_id = c_person_id
    and    asg.assignment_type <> 'C'
    and    asg.person_id = per.person_id
    and    asg.primary_flag = 'Y'
    and    ppb.pay_basis_id = asg.pay_basis_id
    and    asg.payroll_id = paf.payroll_id
    and    c_eff_date
      between asg.effective_start_date
           and     asg.effective_end_date
    and    c_eff_date
      between per.effective_start_date
           and     per.effective_end_date
    and    asg.assignment_id = ppp.assignment_id
    and    ppp.change_date <= c_eff_date
    order  by ppp.change_date desc;
  --
  l_pppdets c_pppdets%rowtype;
  --
begin
  --
  l_efc_batch         := FALSE;
  --
  l_row_count         := 0;
  l_calfail_count     := 0;
  l_calsucc_count     := 0;
  l_dupconv_count     := 0;
  l_conv_count        := 0;
  l_actconv_count     := 0;
  l_unconv_count      := 0;
  l_rcoerr_count      := 0;
  l_faterrs_count     := 0;
  --
  g_enb_success_adj_val_set.delete;
  g_enb_failed_adj_val_set.delete;
  g_enb_rcoerr_val_set.delete;
  g_enb_fatal_error_val_set.delete;
  --
  -- Check if EFC process parameters are set
  --
  if p_action_id is not null
    and p_pk1 is not null
    and p_chunk is not null
    and p_efc_worker_id is not null
  then
    --
    l_efc_batch := TRUE;
    --
  end if;
  --
  l_from_str := ' FROM ben_enrt_bnft enb, '
                ||'    BEN_ELIG_PER_ELCTBL_CHC epe, '
                ||'    ben_per_in_ler pil, '
                ||'    per_all_people_f per ';
  --
  l_where_str := ' where enb.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id '
                 ||' and   epe.per_in_ler_id = pil.per_in_ler_id '
                 ||' and   pil.person_id = per.person_id '
                 ||' and   pil.LF_EVT_OCRD_DT '
                 ||'   between   per.effective_start_date and per.effective_end_date '
/* Exclude flat amounts */
                 ||' and   enb.cvg_mlt_cd not in ('||''''||'FLFX'||''''||') '
                 ||' and (enb.mx_wout_ctfn_val is not null '
                 ||'     or enb.mn_val is not null '
                 ||'     or enb.mx_val is not null '
                 ||'     or enb.incrmt_val is not null '
                 ||'     or enb.dflt_val is not null '
                 ||'     or enb.val is not null '
                 ||'     ) ';
  --
  -- Check if we are restricting by business group
  --
  if p_business_group_id is not null then
    --
    l_where_str := l_where_str||' and enb.business_group_id = '||p_business_group_id
                   ||' and pil.business_group_id = '||p_business_group_id;
    --
  end if;
  --
  -- Build in batch specific restrictions
  --
  if l_efc_batch then
    --
    l_from_str  := l_from_str||', ben_enrt_bnft_efc efc ';
    l_where_str := l_where_str||' and efc.enrt_bnft_id = enb.enrt_bnft_id '
                   ||' and   efc.efc_action_id         = :action_id '
                   ||' and   enb.enrt_bnft_id          > :pk1 '
                   ||' and   mod(enb.enrt_bnft_id, :total_workers) = :worker_id ';
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    l_where_str := l_where_str||' and mod(enb.enrt_bnft_id, :valtotal_workers) = :valworker_id ';
    --
  end if;
  --
  l_sql_str  := ' select enb.enrt_bnft_id, '
                ||'      enb.elig_per_elctbl_chc_id, '
                ||'      enb.business_group_id, '
                ||'      enb.mx_wout_ctfn_val, '
                ||'      enb.mn_val, '
                ||'      enb.mx_val, '
                ||'      enb.incrmt_val, '
                ||'      enb.dflt_val, '
                ||'      enb.val, '
                ||'      epe.pgm_id, '
                ||'      epe.pl_id, '
                ||'      epe.pl_typ_id, '
                ||'      epe.ptip_id, '
                ||'      epe.plip_id, '
                ||'      epe.oipl_id, '
                ||'      epe.prtt_enrt_rslt_id, '
                ||'      epe.object_version_number epe_ovn, '
                ||'      epe.elctbl_flag, '
                ||'      pil.per_in_ler_id, '
                ||'      pil.person_id, '
                ||'      pil.lf_evt_ocrd_dt, '
                ||'      pil.ler_id, '
                ||'      enb.last_update_date, '
                ||'      enb.creation_date, '
                ||'      enb.object_version_number, '
                ||'      enb.cvg_mlt_cd '
                ||l_from_str
                ||l_where_str
                ||' order by enb.enrt_bnft_id ';
  --
  if l_efc_batch then
    --
    hr_efc_info.insert_line('-- ');
    hr_efc_info.insert_line('-- Adjusting coverages ');
    hr_efc_info.insert_line('-- ');
    --
    open c_efc_rows FOR l_sql_str using p_action_id, p_pk1, p_total_workers, p_worker_id;
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    open c_efc_rows FOR l_sql_str using p_valtotal_workers, p_valworker_id;
    --
  else
    --
    open c_efc_rows FOR l_sql_str;
    --
  end if;
  --
  loop
    FETCH c_efc_rows INTO l_efc_row;
    EXIT WHEN c_efc_rows%NOTFOUND;
    --
    l_faterr_code := null;
    l_adjfailed   := FALSE;
    --
    -- Check for modifications
    --
    if l_faterr_code is null then
      --
      -- Check that the assignment is valid
      --
      ben_efc_adjustments.DetectInvAsg
        (p_person_id => l_efc_row.person_id
        ,p_eff_date  => l_efc_row.lf_evt_ocrd_dt
        --
        ,p_perasg    => l_perasg
        ,p_noasgpay  => l_detected
        );
      --
      if l_detected then
        --
        l_faterr_code := 'NOASGPAY';
        l_faterr_type := 'MISSINGSETUP';
        --
      end if;
      --
    end if;
    --
    -- Check if the plan has been modified
    --
    if l_faterr_code is null
    then
      --
      open c_pln_dets
        (c_pln_id   => l_efc_row.pl_id
        ,c_eff_date => l_efc_row.lf_evt_ocrd_dt
        );
      fetch c_pln_dets into l_pln_dets;
      if c_pln_dets%notfound then
        --
        l_faterr_code := 'NODTPLN';
        --
      end if;
      close c_pln_dets;
      --
    end if;
    --
    -- Check if the oipl has been modified
    --
    if l_efc_row.oipl_id is not null
      and l_faterr_code is null
    then
      --
      open c_cop_dets
        (c_cop_id   => l_efc_row.oipl_id
        ,c_eff_date => l_efc_row.lf_evt_ocrd_dt
        );
      fetch c_cop_dets into l_cop_dets;
      if c_cop_dets%notfound then
        --
        l_faterr_code := 'NODTCOP';
        l_faterr_type := 'DELETEDINFO';
        --
      end if;
      close c_cop_dets;
      --
    end if;
    --
    -- Check if the compensation is 0
    --
    if l_faterr_code is null then
      --
      -- Set up benefits environment
      --
      ben_env_object.init
        (p_business_group_id => l_efc_row.business_group_id
        ,p_effective_date    => l_efc_row.lf_evt_ocrd_dt
        ,p_thread_id         => 1
        ,p_chunk_size        => 10
        ,p_threads           => 1
        ,p_max_errors        => 100
        ,p_benefit_action_id => 99999
        ,p_audit_log_flag    => 'N'
        );
      --
      -- Get the comp level details
      --
      ben_cvg_cache.epecobjtree_getcvgdets
        (p_epe_id         => l_efc_row.elig_per_elctbl_chc_id
        ,p_epe_pl_id      => l_efc_row.pl_id
        ,p_epe_plip_id    => l_efc_row.plip_id
        ,p_epe_oipl_id    => l_efc_row.oipl_id
        ,p_effective_date => l_efc_row.lf_evt_ocrd_dt
        --
        ,p_cvg_set        => l_cvg_set
        );
      --
      -- Check if coverage details found
      --
      if l_cvg_set.count = 0 then
        --
        l_faterr_code    := 'NOEPECCM';
        --
      else
        --
        -- Get CCM details
        --
        open c_ccm_dets
          (c_ccm_id   => l_cvg_set(0).cvg_amt_calc_mthd_id
          ,c_eff_date => l_efc_row.lf_evt_ocrd_dt
          );
        fetch c_ccm_dets into l_ccm_dets;
        close c_ccm_dets;
        --
        -- Get comp level factor details
        --
        if l_cvg_set(0).comp_lvl_fctr_id is not null
          and l_faterr_code is null
        then
          --
          open c_clf_dets
            (c_clf_id => l_cvg_set(0).comp_lvl_fctr_id
            );
          fetch c_clf_dets into l_clf_dets;
          if c_clf_dets%notfound then
            --
            l_faterr_code := 'NOCLF';
            --
          end if;
          close c_clf_dets;
          --
        end if;
        --
        -- Check multiple codes
        --
        if l_cvg_set(0).cvg_mlt_cd in ('CL','CLRNG','FLFXPCL','FLPCLRNG','CLPFLRNG')
          and l_faterr_code is null
        then
          --
          -- Check person salary information for STTDCOMP CLF
          --
          if l_faterr_code is null
            and l_clf_dets.comp_src_cd = 'STTDCOMP'
          then
            --
            open c_pppdets
              (c_person_id => l_efc_row.person_id
              ,c_eff_date  => l_efc_row.lf_evt_ocrd_dt
              );
            fetch c_pppdets into l_pppdets;
            if c_pppdets%notfound then
              --
              l_faterr_code    := 'NODTSALDETS';
              --
            end if;
            close c_pppdets;
            --
          end if;
          --
          if l_faterr_code is null then
            --
            ben_derive_factors.determine_compensation
              (p_comp_lvl_fctr_id     => l_cvg_set(0).comp_lvl_fctr_id
              ,p_person_id            => l_efc_row.person_id
              ,p_pgm_id               => null
              ,p_pl_id                => l_efc_row.pl_id
              ,p_oipl_id              => l_efc_row.oipl_id
              ,p_per_in_ler_id        => l_efc_row.per_in_ler_id
              ,p_business_group_id    => l_efc_row.business_group_id
              ,p_perform_rounding_flg => true
              ,p_effective_date       => l_efc_row.lf_evt_ocrd_dt
              ,p_lf_evt_ocrd_dt       => l_efc_row.lf_evt_ocrd_dt
              ,p_calc_bal_to_date     => null
              ,p_value                => l_comp_value
              );
            --
            if l_comp_value = 0 then
              --
              l_faterr_code       := 'ZEROCOMPVAL';
              --
            end if;
            --
          end if;
          --
          -- Check that a person benefits balance exists when the CLF
          -- source code is BNFTBALTYP
          --
          if l_clf_dets.comp_src_cd = 'BNFTBALTYP' then
            --
            -- Get the PBB
            --
            open c_pbb_dets
              (c_person_id    => l_efc_row.person_id
              ,c_bnfts_bal_id => l_clf_dets.bnfts_bal_id
              ,c_eff_date     => l_efc_row.lf_evt_ocrd_dt
              );
            fetch c_pbb_dets into l_pbb_dets;
            if c_pbb_dets%notfound then
              --
              l_faterr_code   := 'NODTPBB';
              l_faterr_type   := 'MISSINGSETUP';
              --
            end if;
            close c_pbb_dets;
            --
            if l_pbb_dets.uom is null
              and l_faterr_code is null
            then
              --
              l_faterr_code := 'NULLUOM';
              l_faterr_type := 'MISSINGSETUP';
              --
            end if;
            --
            if nvl(l_pbb_dets.uom,'ZZZZ') = 'EUR'
              and l_faterr_code is null
            then
              --
              l_faterr_code := 'EUROUOM';
              l_faterr_type := 'VALIDEXCLUSION';
              --
            end if;
            --
          end if;
          --
        elsif l_cvg_set(0).cvg_mlt_cd in ('FLFX')
        then
          --
          l_faterr_code   := 'CCMFLFX';
          l_faterr_type   := 'VALIDEXCLUSION';
          --
        end if;
        --
      end if;
      --
    end if;
    --
    if l_faterr_code is null then
      --
      -- Set up benefits environment
      --
      ben_env_object.init
        (p_business_group_id => l_efc_row.business_group_id
        ,p_effective_date    => l_efc_row.lf_evt_ocrd_dt
        ,p_thread_id         => 1
        ,p_chunk_size        => 10
        ,p_threads           => 1
        ,p_max_errors        => 100
        ,p_benefit_action_id => 99999
        ,p_audit_log_flag    => 'N'
        );
      --
      -- Set up electable choice context
      --
      ben_epe_cache.g_currcobjepe_row.pl_id   := l_efc_row.pl_id;
      ben_epe_cache.g_currcobjepe_row.plip_id := l_efc_row.plip_id;
      ben_epe_cache.g_currcobjepe_row.oipl_id := l_efc_row.oipl_id;
      --
      -- Add a row to fnd sessions
      --
      Insert_fndsession_row
        (p_ses_date => l_efc_row.lf_evt_ocrd_dt
        );
      --
      begin
        --
        begin
          --
          ben_epe_cache.g_currcobjepe_row.elig_per_elctbl_chc_id := l_efc_row.elig_per_elctbl_chc_id;
          ben_epe_cache.g_currcobjepe_row.business_group_id      := l_efc_row.business_group_id;
          ben_epe_cache.g_currcobjepe_row.pgm_id                 := l_efc_row.pgm_id;
          ben_epe_cache.g_currcobjepe_row.pl_id                  := l_efc_row.pl_id;
          ben_epe_cache.g_currcobjepe_row.pl_typ_id              := l_efc_row.pl_typ_id;
          ben_epe_cache.g_currcobjepe_row.ptip_id                := l_efc_row.ptip_id;
          ben_epe_cache.g_currcobjepe_row.plip_id                := l_efc_row.plip_id;
          ben_epe_cache.g_currcobjepe_row.oipl_id                := l_efc_row.oipl_id;
          ben_epe_cache.g_currcobjepe_row.prtt_enrt_rslt_id      := l_efc_row.prtt_enrt_rslt_id;
          ben_epe_cache.g_currcobjepe_row.ler_id                 := l_efc_row.ler_id;
          ben_epe_cache.g_currcobjepe_row.object_version_number  := l_efc_row.epe_ovn;
          ben_epe_cache.g_currcobjepe_row.elctbl_flag            := l_efc_row.elctbl_flag;
          ben_epe_cache.g_currcobjepe_row.per_in_ler_id          := l_efc_row.per_in_ler_id;
          --
          ben_determine_coverage.main
            (p_calculate_only_mode    => TRUE
            ,p_elig_per_elctbl_chc_id => l_efc_row.elig_per_elctbl_chc_id
            ,p_effective_date         => l_efc_row.lf_evt_ocrd_dt
            ,p_lf_evt_ocrd_dt         => l_efc_row.lf_evt_ocrd_dt
            ,p_perform_rounding_flg   => TRUE
            --
            ,p_enb_valrow             => l_enb_valrow
            );
          --
        exception
          when ben_manage_life_events.g_record_error then
            --
            fnd_message.raise_error;
            --
        end;
        --
        if nvl(l_efc_row.val,9999) <> nvl(l_enb_valrow.val,9999)
        then
          --
          l_val_type  := 'ENB_VAL';
          l_old_val1  := l_efc_row.val;
          --
          if l_efc_row.val is null then
            --
            l_enb_valrow.val := null;
            l_new_val1       := null;
            l_adjfailed := FALSE;
            --
          else
            --
            l_new_val1  := l_enb_valrow.val;
            l_adjfailed := TRUE;
            --
          end if;
          --
        end if;
        --
        if nvl(l_efc_row.mn_val,9999) <> nvl(l_enb_valrow.mn_val,9999)
          and not l_adjfailed
        then
          --
          l_val_type  := 'ENB_MNVAL';
          l_old_val1  := l_efc_row.mn_val;
          --
          if l_efc_row.mn_val is null then
            --
            l_enb_valrow.mn_val := null;
            l_new_val1          := null;
            l_adjfailed         := FALSE;
            --
          else
            --
            l_new_val1  := l_enb_valrow.mn_val;
            l_adjfailed := TRUE;
            --
          end if;
          --
        end if;
        --
        if nvl(l_efc_row.mx_val,9999) <> nvl(l_enb_valrow.mx_val,9999)
          and not l_adjfailed
        then
          --
          l_val_type  := 'ENB_MXVAL';
          l_old_val1  := l_efc_row.mx_val;
          --
          if l_efc_row.mx_val is null then
            --
            l_enb_valrow.mx_val := null;
            l_new_val1          := null;
            l_adjfailed         := FALSE;
            --
          else
            --
            l_new_val1  := l_enb_valrow.mx_val;
            l_adjfailed := TRUE;
            --
          end if;
          --
        end if;
        --
        if nvl(l_efc_row.incrmt_val,9999) <> nvl(l_enb_valrow.incrmt_val,9999)
          and not l_adjfailed
        then
          --
          l_val_type  := 'ENB_INCRMTVAL';
          l_old_val1  := l_efc_row.incrmt_val;
          --
          if l_efc_row.incrmt_val is null then
            --
            l_enb_valrow.incrmt_val := null;
            l_new_val1              := null;
            l_adjfailed             := FALSE;
            --
          else
            --
            l_new_val1  := l_enb_valrow.incrmt_val;
            l_adjfailed := TRUE;
            --
          end if;
          --
        end if;
        --
        if nvl(l_efc_row.dflt_val,9999) <> nvl(l_enb_valrow.dflt_val,9999)
          and not l_adjfailed
        then
          --
          l_val_type  := 'ENB_DFLTVAL';
          l_old_val1  := l_efc_row.dflt_val;
          --
          if l_efc_row.dflt_val is null then
            --
            l_enb_valrow.dflt_val := null;
            l_new_val1            := null;
            l_adjfailed           := FALSE;
            --
          else
            --
            l_new_val1  := l_enb_valrow.dflt_val;
            l_adjfailed := TRUE;
            --
          end if;
          --
        end if;
        --
        if nvl(l_efc_row.mx_wout_ctfn_val,9999) <> nvl(l_enb_valrow.mx_wout_ctfn_val,9999)
          and not l_adjfailed
        then
          --
          l_val_type  := 'ENB_MXWOCTFNVAL';
          l_old_val1  := l_efc_row.mx_wout_ctfn_val;
          --
          if l_efc_row.mx_wout_ctfn_val is null then
            --
            l_enb_valrow.mx_wout_ctfn_val := null;
            l_new_val1            := null;
            l_adjfailed           := FALSE;
            --
          else
            --
            l_new_val1  := l_enb_valrow.mx_wout_ctfn_val;
            l_adjfailed := TRUE;
            --
          end if;
          --
        end if;
        --
        if not l_adjfailed
        then
          --
          l_val_type  := 'ENB_VAL';
          l_old_val1  := l_efc_row.val;
          l_new_val1  := l_enb_valrow.val;
          l_adjfailed := FALSE;
          --
        end if;
        --
        -- Success and failure fatal error checks
        --
        --
        -- Get the parent UOM
        --
        ben_efc_functions.CompObject_GetParUom
          (p_pgm_id      => l_efc_row.pgm_id
          ,p_ptip_id     => l_efc_row.ptip_id
          ,p_pl_id       => l_efc_row.pl_id
          ,p_plip_id     => l_efc_row.plip_id
          ,p_oipl_id     => l_efc_row.oipl_id
          ,p_oiplip_id   => null
          ,p_eff_date    => l_efc_row.lf_evt_ocrd_dt
          --
          ,p_paruom      => l_enb_uom
          ,p_faterr_code => l_faterr_code
          ,p_faterr_type => l_faterr_type
          );
        --
        -- Check for points uom
        --
        if l_enb_uom = 'POINTS'
          and l_faterr_code is null
        then
          --
          l_faterr_code := 'ENBPOINTSUOM';
          l_faterr_type := 'VALIDEXCLUSION';
          --
        end if;
        --
        -- Post failure fatal error checks
        --
        if l_adjfailed
        then
          --
          if l_faterr_code is null then
            --
            -- Check for a FLRNG mlt cd
            --
            if l_efc_row.cvg_mlt_cd = 'FLRNG'
            then
              --
              l_faterr_code      := 'FLRNGCVGMC';
              l_faterr_type      := 'UNSUPPORTTRANS';
              --
            end if;
            --
          end if;
          --
          -- Check for a VAPRO treatment code of RPLC
          --
          if l_faterr_code is null then
            --
            -- Validate vapro
            --
            l_currepe_row.person_id              := l_efc_row.person_id;
            l_currepe_row.elig_per_elctbl_chc_id := l_efc_row.elig_per_elctbl_chc_id;
            l_currepe_row.pgm_id                 := l_efc_row.pgm_id;
            l_currepe_row.pl_id                  := l_efc_row.pl_id;
            l_currepe_row.pl_typ_id              := l_efc_row.pl_typ_id;
            l_currepe_row.oipl_id                := l_efc_row.oipl_id;
            l_currepe_row.per_in_ler_id          := l_efc_row.per_in_ler_id;
            l_currepe_row.ler_id                 := l_efc_row.ler_id;
            l_currepe_row.business_group_id      := l_efc_row.business_group_id;
            --
            ben_efc_adjustments.DetectVAPROInfo
              (p_currepe_row          => l_currepe_row
              --
              ,p_lf_evt_ocrd_dt       => l_efc_row.lf_evt_ocrd_dt
              ,p_last_update_date     => l_efc_row.last_update_date
              --
              ,p_cvg_amt_calc_mthd_id => l_cvg_set(0).cvg_amt_calc_mthd_id
              --
              ,p_vpfdets              => l_vpfdets
              ,p_vpf_id               => l_vpf_id
              ,p_faterr_code          => l_faterr_code
              ,p_faterr_type          => l_faterr_type
              );
            --
            -- Check for a replace rate type. A code fix has been made since the
            -- original info was created.
            --
            if l_vpfdets.vrbl_rt_trtmt_cd = 'RPLC'
              and l_faterr_code is null
            then
              --
              l_faterr_code := 'INVADJRPLCVPF';
              l_faterr_type := 'CODECHANGE';
              --
            end if;
            --
          end if;
          --
          if l_faterr_code is null
          then
            --
            -- Check rounding
            --
            ben_efc_adjustments.DetectRoundInfo
              (p_rndg_cd        => null
              ,p_rndg_rl        => null
              ,p_old_val        => l_old_val1
              ,p_new_val        => l_new_val1
              ,p_eff_date       => l_efc_row.lf_evt_ocrd_dt
              --
              ,p_faterr_code    => l_faterr_code
              ,p_faterr_type    => l_faterr_type
              );
            --
          end if;
          --
          if l_faterr_code is null
          then
            --
            -- Check if the CCM has been modified since the ENB was created
            --
            if nvl(l_ccm_dets.last_update_date,hr_api.g_sot)
              > nvl(l_efc_row.creation_date,hr_api.g_sot)
            then
              --
              l_faterr_code   := 'CCMDTCORR';
              l_faterr_type   := 'CORRECTEDINFO';
              --
            elsif l_who_counts.multtransmod_count > 0
              and l_efc_row.object_version_number > 1
            then
              --
              l_faterr_code   := 'ENBMODS';
              l_faterr_type   := 'UNSUPPORTTRANS';
              --
            elsif l_who_counts.multtransmod_count > 0
              and l_efc_row.object_version_number = 1
            then
              --
              l_faterr_code  := 'INVOVNTRIG';
              l_faterr_type  := 'DATACORRUPT';
              --
            end if;
            --
          end if;
          --
          -- Check multiple codes
          --
          if l_cvg_set(0).cvg_mlt_cd in ('CL','CLRNG','FLFXPCL','FLPCLRNG','CLPFLRNG')
            and l_faterr_code is null
          then
            --
            -- Check that a pay proposal exists for the assignment
            --
            open c_asgpppdets
              (c_per_id   => l_efc_row.person_id
              ,c_eff_date => l_efc_row.lf_evt_ocrd_dt
              );
            fetch c_asgpppdets into l_asgpppdets;
            if c_asgpppdets%notfound then
              --
              l_faterr_code    := 'NOASGPPP';
              --
            end if;
            close c_asgpppdets;
            --
          end if;
          --
          if l_faterr_code is null then
            --
            -- WHO checks
            --
            ben_efc_adjustments.DetectWhoInfo
              (p_creation_date         => l_efc_row.creation_date
              ,p_last_update_date      => l_efc_row.last_update_date
              ,p_object_version_number => l_efc_row.object_version_number
              ,p_who_counts            => l_who_counts
              ,p_faterr_code           => l_faterr_code
              ,p_faterr_type           => l_faterr_type
              );
            --
          end if;
          --
          if l_faterr_code is null then
            --
            g_enb_failed_adj_val_set(l_calfail_count).id       := l_efc_row.enrt_bnft_id;
            g_enb_failed_adj_val_set(l_calfail_count).old_val1 := l_old_val1;
            g_enb_failed_adj_val_set(l_calfail_count).new_val1 := l_new_val1;
            g_enb_failed_adj_val_set(l_calfail_count).val_type := l_val_type;
            g_enb_failed_adj_val_set(l_calfail_count).lud      := l_efc_row.last_update_date;
            g_enb_failed_adj_val_set(l_calfail_count).credt    := l_efc_row.creation_date;
            --
            if l_cvg_set.count > 0 then
              --
              g_enb_failed_adj_val_set(l_calfail_count).code1    := l_cvg_set(0).cvg_mlt_cd;
              --
            end if;
            --
            g_enb_failed_adj_val_set(l_calfail_count).code2    := l_clf_dets.comp_src_cd;
            g_enb_failed_adj_val_set(l_calfail_count).code3    := l_vpfdets.mlt_cd;
            g_enb_failed_adj_val_set(l_calfail_count).code4    := l_enb_uom;
            --
            l_calfail_count := l_calfail_count+1;
            --
          end if;
          --
        end if;
        --
        if l_efc_batch
          and l_faterr_code is null
        then
          --
          update ben_enrt_bnft enb
          set    enb.val              = l_enb_valrow.val,
                 enb.mn_val           = l_enb_valrow.mn_val,
                 enb.mx_val           = l_enb_valrow.mx_val,
                 enb.mx_wout_ctfn_val = l_enb_valrow.mx_wout_ctfn_val,
                 enb.incrmt_val       = l_enb_valrow.incrmt_val,
                 enb.dflt_val         = l_enb_valrow.dflt_val
          where  enb.enrt_bnft_id     = l_efc_row.enrt_bnft_id;
          --
          if p_validate then
            --
            rollback;
            --
          end if;
          --
          -- Check for end of chunk and commit if necessary
          --
          l_pk1 := l_efc_row.enrt_bnft_id;
          --
          ben_efc_functions.maintain_chunks
            (p_row_count     => l_row_count
            ,p_pk1           => l_pk1
            ,p_chunk_size    => p_chunk
            ,p_efc_worker_id => p_efc_worker_id
            );
          --
        end if;
        --
      exception
        when others then
          --
          g_enb_rcoerr_val_set(l_rcoerr_count).id        := l_efc_row.enrt_bnft_id;
          g_enb_rcoerr_val_set(l_rcoerr_count).rco_name  := 'BENCVRGE';
          g_enb_rcoerr_val_set(l_rcoerr_count).sql_error := SQLERRM;
          g_enb_rcoerr_val_set(l_rcoerr_count).lud       := l_efc_row.last_update_date;
          g_enb_rcoerr_val_set(l_rcoerr_count).credt     := l_efc_row.creation_date;
          --
          l_rcoerr_count  := l_rcoerr_count+1;
          --
      end;
      --
    end if;
    --
    -- Check for fatal errors
    --
    if l_faterr_code is not null
    then
      --
      g_enb_fatal_error_val_set(l_faterrs_count).id          := l_efc_row.enrt_bnft_id;
      g_enb_fatal_error_val_set(l_faterrs_count).faterr_code := l_faterr_code;
      g_enb_fatal_error_val_set(l_faterrs_count).faterr_type := l_faterr_type;
      g_enb_fatal_error_val_set(l_faterrs_count).old_val1    := l_old_val1;
      g_enb_fatal_error_val_set(l_faterrs_count).new_val1    := l_new_val1;
      g_enb_fatal_error_val_set(l_faterrs_count).lud         := l_efc_row.last_update_date;
      g_enb_fatal_error_val_set(l_faterrs_count).credt       := l_efc_row.creation_date;
      --
      if l_cvg_set.count > 0 then
        --
        g_enb_fatal_error_val_set(l_faterrs_count).code1    := l_cvg_set(0).cvg_mlt_cd;
        --
      end if;
      --
      g_enb_fatal_error_val_set(l_faterrs_count).code2       := l_clf_dets.comp_src_cd;
      g_enb_fatal_error_val_set(l_faterrs_count).code3       := l_vpfdets.mlt_cd;
      g_enb_fatal_error_val_set(l_faterrs_count).code4       := l_enb_uom;
      --
      l_faterrs_count := l_faterrs_count+1;
    --
    elsif l_faterr_code is null
      and not l_adjfailed
    then
      --
      g_enb_success_adj_val_set(l_calsucc_count).id          := l_efc_row.enrt_bnft_id;
      g_enb_success_adj_val_set(l_calsucc_count).faterr_code := l_faterr_code;
      g_enb_success_adj_val_set(l_calsucc_count).faterr_type := l_faterr_type;
      g_enb_success_adj_val_set(l_calsucc_count).old_val1    := l_old_val1;
      g_enb_success_adj_val_set(l_calsucc_count).new_val1    := l_new_val1;
      g_enb_success_adj_val_set(l_calsucc_count).lud         := l_efc_row.last_update_date;
      g_enb_success_adj_val_set(l_calsucc_count).credt       := l_efc_row.creation_date;
      g_enb_success_adj_val_set(l_calsucc_count).code1       := l_cvg_set(0).cvg_mlt_cd;
      g_enb_success_adj_val_set(l_calsucc_count).code2       := l_clf_dets.comp_src_cd;
      g_enb_success_adj_val_set(l_calsucc_count).code3       := l_vpfdets.mlt_cd;
      --
      l_calsucc_count := l_calsucc_count+1;
      --
    end if;
    --
    l_row_count := l_row_count+1;
    --
  end loop;
  CLOSE c_efc_rows;
  --
  -- Check that all rows have been converted or excluded
  --
  ben_efc_functions.conv_check
    (p_table_name      => 'ben_enrt_bnft'
    ,p_efctable_name   => 'ben_enrt_bnft_efc'
    ,p_tabwhere_clause => ' (mx_wout_ctfn_val is not null '
                          ||' or mn_val is not null '
                          ||' or mx_val is not null '
                          ||' or incrmt_val is not null '
                          ||' or dflt_val is not null '
                          ||' or val is not null '
                          ||' ) '
    --
    ,p_bgp_id        => p_business_group_id
    ,p_action_id     => p_action_id
    --
    ,p_conv_count    => l_conv_count
    ,p_unconv_count  => l_unconv_count
    ,p_tabrow_count  => l_tabrow_count
    );
  --
  -- Set counts
  --
  if p_action_id is null then
    --
    l_actconv_count := 0;
    --
  else
    --
    l_actconv_count := l_conv_count;
    --
  end if;
  --
  p_adjustment_counts.efcrow_count         := l_row_count;
  p_adjustment_counts.tabrow_count         := l_tabrow_count;
  p_adjustment_counts.calfail_count        := l_calfail_count;
  p_adjustment_counts.calsucc_count        := l_calsucc_count;
  p_adjustment_counts.dupconv_count        := l_dupconv_count;
  p_adjustment_counts.conv_count           := l_conv_count;
  p_adjustment_counts.actconv_count        := l_actconv_count;
  p_adjustment_counts.unconv_count         := l_unconv_count;
  p_adjustment_counts.rcoerr_count         := l_rcoerr_count;
  --
end enb_adjustments;
--
procedure epr_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy g_adjustment_counts
  )
is
  --
  TYPE cur_type IS REF CURSOR;
  --
  type g_efc_row is record
    (enrt_prem_id           ben_enrt_prem.enrt_prem_id%type
    ,elig_per_elctbl_chc_id ben_enrt_prem.elig_per_elctbl_chc_id%type
    ,enrt_bnft_id           ben_enrt_prem.enrt_bnft_id%type
    ,actl_prem_id           ben_enrt_prem.actl_prem_id%type
    ,business_group_id      ben_enrt_prem.business_group_id%type
    ,val                    ben_enrt_prem.val%type
    ,last_update_date       ben_enrt_prem.last_update_date%type
    ,creation_date          ben_enrt_prem.creation_date%type
    ,object_version_number  ben_enrt_prem.object_version_number%type
    );
  --
  c_efc_rows               cur_type;
  --
  l_proc                   varchar2(1000) := 'epr_adjustments';
  --
  l_efc_row                g_efc_row;
  --
  l_who_counts             g_who_counts;
  --
  l_currepe_row            ben_determine_rates.g_curr_epe_rec;
  --
  l_vpfdets                gc_vpfdets%rowtype;
  --
  l_currpil_row            g_pil_rowtype;
  --
  l_row_count              pls_integer;
  l_calfail_count          pls_integer;
  l_calsucc_count          pls_integer;
  l_conv_count             pls_integer;
  l_unconv_count           pls_integer;
  l_actconv_count          pls_integer;
  l_dupconv_count          pls_integer;
  --
  l_rcoerr_count           pls_integer;
  --
  l_faterrs_count          pls_integer;
  l_tabrow_count           pls_integer;
  --
  l_olddata                boolean;
  --
  l_sql_str                long;
  l_from_str               long;
  l_where_str              long;
  --
  l_efc_batch              boolean;
  --
  l_pk1                    number;
  --
  l_bnft_amt               number;
  l_val                    number;
  l_vpf_id                 number;
  l_prev_person_id         number;
  --
  l_faterr_code            varchar2(100);
  l_faterr_type            varchar2(100);
  l_adj_failed             boolean;
  --
  cursor c_apr
    (c_apr_id         in number
    ,c_lf_evt_ocrd_dt in date
    )
  is
    select apr.actl_prem_id,
           apr.mlt_cd,
           apr.val,
           apr.rndg_cd,
           apr.rndg_rl,
           apr.rt_typ_cd,
           apr.bnft_rt_typ_cd,
           apr.comp_lvl_fctr_id,
           apr.prem_asnmt_cd,
           apr.val_calc_rl,
           apr.upr_lmt_val,
           apr.upr_lmt_calc_rl,
           apr.lwr_lmt_val,
           apr.lwr_lmt_calc_rl,
           apr.uom,
           apr.last_update_date
    from   ben_actl_prem_f apr
    where  apr.actl_prem_id = c_apr_id
    and    apr.prem_asnmt_cd = 'ENRT'
    and    c_lf_evt_ocrd_dt
           between apr.effective_start_date
           and     apr.effective_end_date;
  --
  l_apr c_apr%rowtype;
  --
  cursor c_epeenb_dets
    (c_epe_id in number
    )
  is
    select enb.val
    from BEN_ELIG_PER_ELCTBL_CHC epe,
         ben_enrt_bnft enb
    where epe.ELIG_PER_ELCTBL_CHC_id = c_epe_id
    and   epe.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id;
  --
  cursor c_enb_dets
    (c_enb_id in number
    )
  is
    select enb.val
    from ben_enrt_bnft enb
    where enb.enrt_bnft_id = c_enb_id;
  --
  cursor c_mxaprvprlud
    (c_apr_id   in    number
    ,c_eff_date in    date
    )
  is
    select apr.actl_prem_id,
           max(apr.last_update_date) mxapr_lud,
           max(vrp.last_update_date) mxvrp_lud
    from   ben_actl_prem_vrbl_rt_f apr,
           ben_vrbl_rt_prfl_f vrp
    where  vrp.vrbl_rt_prfl_stat_cd = 'A'
    and    c_eff_date
      between vrp.effective_start_date and vrp.effective_end_date
    and    apr.actl_prem_id    = c_apr_id
    and    vrp.vrbl_rt_prfl_id = apr.vrbl_rt_prfl_id
    and    c_eff_date
           between apr.effective_start_date
           and     apr.effective_end_date
    group by apr.actl_prem_id;
  --
  l_mxaprvprlud    c_mxaprvprlud%rowtype;
  --
begin
  --
  l_efc_batch     := FALSE;
  --
  l_row_count     := 0;
  l_calfail_count := 0;
  l_calsucc_count := 0;
  l_dupconv_count := 0;
  l_conv_count    := 0;
  l_actconv_count := 0;
  l_unconv_count  := 0;
  l_rcoerr_count  := 0;
  l_faterrs_count := 0;
  --
  l_prev_person_id    := -1;
  --
  g_epr_success_adj_val_set.delete;
  g_epr_failed_adj_val_set.delete;
  g_epr_rcoerr_val_set.delete;
  g_epr_fatal_error_val_set.delete;
  --
  -- Check if EFC process parameters are set
  --
  if p_action_id is not null
    and p_pk1 is not null
    and p_chunk is not null
    and p_efc_worker_id is not null
  then
    --
    l_efc_batch := TRUE;
    --
  end if;
  --
  l_from_str := ' FROM ben_enrt_prem epr ';
  --
  l_where_str := ' where epr.val is not null ';
  --
  -- Check if we are restricting by business group
  --
  if p_business_group_id is not null then
    --
    l_where_str := l_where_str||' and epr.business_group_id = '||p_business_group_id;
    --
  end if;
  --
  -- Build in batch specific restrictions
  --
  if l_efc_batch then
    --
    l_from_str  := l_from_str||', ben_enrt_prem_efc efc ';
    l_where_str := l_where_str||' and efc.enrt_prem_id = epr.enrt_prem_id '
                   ||' and   efc.efc_action_id         = :action_id '
                   ||' and   epr.enrt_prem_id          > :pk1 '
                   ||' and   mod(epr.enrt_prem_id, :total_workers) = :worker_id ';
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    l_where_str := l_where_str||' and mod(epr.enrt_prem_id, :valtotal_workers) = :valworker_id ';
    --
  end if;
  --
  l_sql_str  := ' select epr.enrt_prem_id, '
                ||'      epr.elig_per_elctbl_chc_id, '
                ||'      epr.enrt_bnft_id, '
                ||'      epr.actl_prem_id, '
                ||'      epr.business_group_id, '
                ||'      epr.val, '
                ||'      epr.last_update_date, '
                ||'      epr.creation_date, '
                ||'      epr.object_version_number '
                ||l_from_str
                ||l_where_str
                ||' order by epr.enrt_prem_id ';
  --
  if l_efc_batch then
    --
    hr_efc_info.insert_line('-- ');
    hr_efc_info.insert_line('-- Adjusting enrolment premiums ');
    hr_efc_info.insert_line('-- ');
    --
    open c_efc_rows FOR l_sql_str using p_action_id, p_pk1, p_total_workers, p_worker_id;
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    open c_efc_rows FOR l_sql_str using p_valtotal_workers, p_valworker_id;
    --
  else
    --
    open c_efc_rows FOR l_sql_str;
    --
  end if;
  --
  ben_epe_cache.clear_down_cache;
  --
  loop
    FETCH c_efc_rows INTO l_efc_row;
    EXIT WHEN c_efc_rows%NOTFOUND;
    --
    l_faterr_code := null;
    l_adj_failed  := FALSE;
    --
    if l_faterr_code is null then
      --
      -- Detect EPE or ENB Info
      --
      ben_efc_adjustments.DetectEPEENBInfo
        (p_elig_per_elctbl_chc_id => l_efc_row.elig_per_elctbl_chc_id
        ,p_enrt_bnft_id           => l_efc_row.enrt_bnft_id
        --
        ,p_detect_mode            => 'EPEINFO'
        --
        ,p_currepe_row            => l_currepe_row
        ,p_currpil_row            => l_currpil_row
        ,p_faterr_code            => l_faterr_code
        ,p_faterr_type            => l_faterr_type
        );
      --
      -- Set up benefits environment
      --
      ben_env_object.init
        (p_business_group_id => l_efc_row.business_group_id
        ,p_effective_date    => l_currepe_row.lf_evt_ocrd_dt
        ,p_thread_id         => 1
        ,p_chunk_size        => 10
        ,p_threads           => 1
        ,p_max_errors        => 100
        ,p_benefit_action_id => 99999
        ,p_audit_log_flag    => 'N'
        );
      --
    end if;
    --
    -- Check actual premium info
    --
    if l_faterr_code is null then
      --
      open c_apr
        (c_apr_id         => l_efc_row.actl_prem_id
        ,c_lf_evt_ocrd_dt => l_currepe_row.lf_evt_ocrd_dt
        );
      fetch c_apr into l_apr;
      if c_apr%notfound then
        --
        l_faterr_code := 'NODTAPR';
        l_faterr_type := 'DELETEDINFO';
        --
      end if;
      close c_apr;
      --
      if l_apr.uom = 'EUR'
        and l_faterr_code is null
      then
        --
        l_faterr_code := 'EUROUOM';
        l_faterr_type := 'VALIDEXCLUSION';
        --
      end if;
      --
    end if;
    --
    if l_faterr_code is null then
      --
      -- Check if the person has changed if so flush person level caches
      --
      if l_currepe_row.person_id <> l_prev_person_id
      then
        --
        ben_person_object.clear_down_cache;
        ben_comp_object.clear_down_cache;
        ben_rt_prfl_cache.clear_down_cache;
        --
        l_prev_person_id := l_currepe_row.person_id;
        --
      end if;
      --
      -- Get the benefit amount value from the coverage
      --
      if l_efc_row.elig_per_elctbl_chc_id is not null then
        --
        open c_epeenb_dets
          (c_epe_id => l_efc_row.elig_per_elctbl_chc_id
          );
        fetch c_epeenb_dets into l_bnft_amt;
        close c_epeenb_dets;
        --
      else
        --
        open c_enb_dets
          (c_enb_id => l_efc_row.enrt_bnft_id
          );
        fetch c_enb_dets into l_bnft_amt;
        close c_enb_dets;
        --
      end if;
      --
      -- Check if the bnft amt is set when using the coverage mlt code
      --
      if l_apr.mlt_cd = 'CVG'
        and l_bnft_amt is null
      then
        --
        l_faterr_code            := 'APRMLTCDBAMTNULL';
        --
      end if;
      --
      if l_faterr_code is null then
        --
        begin
          --
          BEN_DETERMINE_ACTUAL_PREMIUM.compute_premium
            (p_person_id              => l_currepe_row.person_id
            ,p_lf_evt_ocrd_dt         => l_currepe_row.lf_evt_ocrd_dt
            ,p_effective_date         => l_currepe_row.lf_evt_ocrd_dt
            ,p_business_group_id      => l_currepe_row.business_group_id
            ,p_per_in_ler_id          => l_currepe_row.per_in_ler_id
            ,p_ler_id                 => l_currepe_row.ler_id
            ,p_actl_prem_id           => l_efc_row.actl_prem_id
            ,p_perform_rounding_flg   => TRUE
            ,p_calc_only_rt_val_flag  => FALSE
            ,p_pgm_id                 => l_currepe_row.pgm_id
            ,p_pl_typ_id              => l_currepe_row.pl_typ_id
            ,p_pl_id                  => l_currepe_row.pl_id
            ,p_oipl_id                => l_currepe_row.oipl_id
            ,p_opt_id                 => l_currepe_row.opt_id
            ,p_elig_per_elctbl_chc_id => l_currepe_row.elig_per_elctbl_chc_id
            ,p_enrt_bnft_id           => l_currepe_row.enrt_bnft_id
            ,p_bnft_amt               => l_bnft_amt
            ,p_prem_val               => l_apr.val
            ,p_mlt_cd                 => l_apr.mlt_cd
            ,p_bnft_rt_typ_cd         => l_apr.bnft_rt_typ_cd
            ,p_val_calc_rl            => l_apr.val_calc_rl
            ,p_rndg_cd                => l_apr.rndg_cd
            ,p_rndg_rl                => l_apr.rndg_rl
            ,p_upr_lmt_val            => l_apr.upr_lmt_val
            ,p_lwr_lmt_val            => l_apr.lwr_lmt_val
            ,p_upr_lmt_calc_rl        => l_apr.upr_lmt_calc_rl
            ,p_lwr_lmt_calc_rl        => l_apr.lwr_lmt_calc_rl
            ,p_computed_val           => l_val
            );
          --
          if nvl(l_efc_row.val,9999) <> nvl(l_val,9999)
          then
            --
            -- Check for a null value
            --
            if l_val is null then
              --
              l_faterr_code := 'EPRVALNULL';
              l_faterr_type := 'POTENTIALCODEBUG';
              --
            end if;
            --
            if l_faterr_code is null then
              --
              -- Validate vapro information
              --
              ben_efc_adjustments.DetectVAPROInfo
                (p_currepe_row      => l_currepe_row
                --
                ,p_lf_evt_ocrd_dt   => l_currepe_row.lf_evt_ocrd_dt
                ,p_last_update_date => l_efc_row.last_update_date
                --
                ,p_actl_prem_id     => l_efc_row.actl_prem_id
                --
                ,p_vpfdets          => l_vpfdets
                ,p_vpf_id           => l_vpf_id
                ,p_faterr_code      => l_faterr_code
                ,p_faterr_type      => l_faterr_type
                );
              --
              -- Check if the vapro fails
              --
              if l_vpf_id is null
                and l_faterr_code is null
              then
                --
                -- Check for a zero value
                --
                if l_efc_row.val = 0 then
                  --
                  l_faterr_code          := 'EPRVRPFAIL0VAL';
                  --
                end if;
                --
              end if;
              --
            end if;
            --
            -- Check for apr mods since the actual premium was created
            --
            if nvl(l_apr.last_update_date,hr_api.g_sot)
              > nvl(l_efc_row.last_update_date,hr_api.g_eot)
              and l_faterr_code is null
            then
              --
              l_faterr_code      := 'APREPRCORR';
              --
            end if;
            --
            if l_faterr_code is null then
              --
              ben_efc_adjustments.DetectWhoInfo
                (p_creation_date         => l_efc_row.creation_date
                ,p_last_update_date      => l_efc_row.last_update_date
                ,p_object_version_number => l_efc_row.object_version_number
                --
                ,p_who_counts            => l_who_counts
                ,p_faterr_code           => l_faterr_code
                ,p_faterr_type           => l_faterr_type
                );
              --
            end if;
            --
            if l_faterr_code is null then
              --
              g_epr_failed_adj_val_set(l_calfail_count).id       := l_efc_row.enrt_prem_id;
              g_epr_failed_adj_val_set(l_calfail_count).old_val1 := l_efc_row.val;
              g_epr_failed_adj_val_set(l_calfail_count).new_val1 := l_val;
              g_epr_failed_adj_val_set(l_calfail_count).val_type := 'EPR_VAL';
              g_epr_failed_adj_val_set(l_calfail_count).lud      := l_efc_row.last_update_date;
              g_epr_failed_adj_val_set(l_calfail_count).credt    := l_efc_row.creation_date;
              --
              l_adj_failed    := TRUE;
              l_calfail_count := l_calfail_count+1;
              --
            end if;
            --
          end if;
          --
        exception
          when others then
            --
            g_epr_rcoerr_val_set(l_rcoerr_count).id        := l_efc_row.enrt_prem_id;
            g_epr_rcoerr_val_set(l_rcoerr_count).rco_name  := 'BENACPRM';
            g_epr_rcoerr_val_set(l_rcoerr_count).sql_error := SQLERRM;
            g_epr_rcoerr_val_set(l_rcoerr_count).lud       := l_efc_row.last_update_date;
            g_epr_rcoerr_val_set(l_rcoerr_count).credt     := l_efc_row.creation_date;
            --
            l_rcoerr_count  := l_rcoerr_count+1;
            --
        end;
        --
      end if;
      --
      if l_efc_batch
        and l_faterr_code is null
      then
        --
        update ben_enrt_prem epr
        set    epr.val          = l_val
        where  epr.enrt_prem_id = l_efc_row.enrt_prem_id;
        --
        if p_validate then
          --
          rollback;
          --
        end if;
        --
        -- Check for end of chunk and commit if necessary
        --
        l_pk1 := l_efc_row.enrt_prem_id;
        --
        ben_efc_functions.maintain_chunks
          (p_row_count     => l_row_count
          ,p_pk1           => l_pk1
          ,p_chunk_size    => p_chunk
          ,p_efc_worker_id => p_efc_worker_id
          );
        --
      end if;
    --
    end if;
    --
    -- Check for fatal errors
    --
    if l_faterr_code is not null
    then
      --
      g_epr_fatal_error_val_set(l_faterrs_count).id          := l_efc_row.enrt_prem_id;
      g_epr_fatal_error_val_set(l_faterrs_count).faterr_code := l_faterr_code;
      g_epr_fatal_error_val_set(l_faterrs_count).faterr_type := l_faterr_type;
      g_epr_fatal_error_val_set(l_faterrs_count).old_val1    := l_efc_row.val;
      g_epr_fatal_error_val_set(l_faterrs_count).new_val1    := l_val;
      g_epr_fatal_error_val_set(l_faterrs_count).lud         := l_efc_row.last_update_date;
      g_epr_fatal_error_val_set(l_faterrs_count).credt       := l_efc_row.creation_date;
      g_epr_fatal_error_val_set(l_faterrs_count).code1       := l_apr.uom;
      --
      l_faterrs_count := l_faterrs_count+1;
      --
    elsif l_faterr_code is null
      and not l_adj_failed
    then
      --
      g_epr_success_adj_val_set(l_calsucc_count).id          := l_efc_row.enrt_prem_id;
      g_epr_success_adj_val_set(l_calsucc_count).lud         := l_efc_row.last_update_date;
      g_epr_success_adj_val_set(l_calsucc_count).credt       := l_efc_row.creation_date;
      g_epr_success_adj_val_set(l_calsucc_count).code1       := l_apr.uom;
      --
      l_calsucc_count := l_calsucc_count+1;
      --
    end if;
    --
    l_row_count   := l_row_count+1;
    --
  end loop;
  CLOSE c_efc_rows;
/*
  --
  -- Write exceptions down to the table
  --
  if l_efc_batch then
    --
    ben_efc_adjustments.insert_validation_exceptions
      (p_val_set        => g_epr_fatal_error_val_set
      ,p_efc_action_id  => p_action_id
      ,p_ent_scode      => 'EPR'
      ,p_exception_type => null
      );
    --
  end if;
*/
  --
  -- Check that all rows have been converted or excluded
  --
  ben_efc_functions.conv_check
    (p_table_name      => 'ben_enrt_prem'
    ,p_efctable_name   => 'ben_enrt_prem_efc'
    ,p_tabwhere_clause => ' val is not null '
    --
    ,p_bgp_id          => p_business_group_id
    ,p_action_id       => p_action_id
    --
    ,p_conv_count      => l_conv_count
    ,p_unconv_count    => l_unconv_count
    ,p_tabrow_count    => l_tabrow_count
    );
  --
  -- Set counts
  --
  if p_action_id is null then
    --
    l_actconv_count := 0;
    --
  else
    --
    l_actconv_count := l_conv_count;
    --
  end if;
  --
  p_adjustment_counts.efcrow_count       := l_row_count;
  p_adjustment_counts.tabrow_count       := l_tabrow_count;
  p_adjustment_counts.calfail_count      := l_calfail_count;
  p_adjustment_counts.calsucc_count      := l_calsucc_count;
  p_adjustment_counts.dupconv_count      := l_dupconv_count;
  p_adjustment_counts.conv_count         := l_conv_count;
  p_adjustment_counts.actconv_count      := l_actconv_count;
  p_adjustment_counts.unconv_count       := l_unconv_count;
  p_adjustment_counts.faterrs_count      := l_faterrs_count;
  p_adjustment_counts.rcoerr_count       := l_rcoerr_count;
  --
end epr_adjustments;
--
procedure ecr_adjustments
  (p_validate          in     boolean default false
  ,p_worker_id         in     number  default null
  ,p_action_id         in     number  default null
  ,p_total_workers     in     number  default null
  ,p_pk1               in     number  default null
  ,p_chunk             in     number  default null
  ,p_efc_worker_id     in     number  default null
  --
  ,p_valworker_id      in     number  default null
  ,p_valtotal_workers  in     number  default null
  --
  ,p_business_group_id in     number  default null
  --
  ,p_adjustment_counts    out nocopy g_adjustment_counts
  )
is
  --
  TYPE cur_type IS REF CURSOR;
  --
  type g_efc_row is record
    (enrt_rt_id             ben_enrt_rt.enrt_rt_id%type
    ,elig_per_elctbl_chc_id ben_enrt_rt.elig_per_elctbl_chc_id%type
    ,enrt_bnft_id           ben_enrt_rt.enrt_bnft_id%type
    ,acty_base_rt_id        ben_enrt_rt.acty_base_rt_id%type
    ,business_group_id      ben_enrt_rt.business_group_id%type
    ,cmcd_mn_elcn_val       ben_enrt_rt.cmcd_mn_elcn_val%type
    ,cmcd_mx_elcn_val       ben_enrt_rt.cmcd_mx_elcn_val%type
    ,cmcd_val               ben_enrt_rt.cmcd_val%type
    ,cmcd_dflt_val          ben_enrt_rt.cmcd_dflt_val%type
    ,ann_dflt_val           ben_enrt_rt.ann_dflt_val%type
    ,dsply_mn_elcn_val      ben_enrt_rt.dsply_mn_elcn_val%type
    ,dsply_mx_elcn_val      ben_enrt_rt.dsply_mx_elcn_val%type
    ,dflt_val               ben_enrt_rt.dflt_val%type
    ,ann_val                ben_enrt_rt.ann_val%type
    ,ann_mn_elcn_val        ben_enrt_rt.ann_mn_elcn_val%type
    ,ann_mx_elcn_val        ben_enrt_rt.ann_mx_elcn_val%type
    ,mx_elcn_val            ben_enrt_rt.mx_elcn_val%type
    ,mn_elcn_val            ben_enrt_rt.mn_elcn_val%type
    ,incrmt_elcn_val        ben_enrt_rt.incrmt_elcn_val%type
    ,val                    ben_enrt_rt.val%type
    ,last_update_date       ben_enrt_rt.last_update_date%type
    ,creation_date          ben_enrt_rt.creation_date%type
    ,object_version_number  ben_enrt_rt.object_version_number%type
    );
  --
  c_efc_rows               cur_type;
  --
  l_proc                   varchar2(1000) := 'ecr_adjustments';
  --
  l_efc_row                g_efc_row;
  --
  l_who_counts             g_who_counts;
  --
  l_perasg                 gc_perasg%rowtype;
  l_vpfdets                gc_vpfdets%rowtype;
  --
  l_currpil_row            g_pil_rowtype;
  --
  l_row_count              pls_integer;
  l_calfail_count          pls_integer;
  l_calsucc_count          pls_integer;
  l_conv_count             pls_integer;
  l_unconv_count           pls_integer;
  l_actconv_count          pls_integer;
  l_dupconv_count          pls_integer;
  --
  l_faterrs_count          pls_integer;
  l_rcoerr_count           pls_integer;
  --
  l_tabrow_count           pls_integer;
  l_chunkrow_count         pls_integer;
  --
  l_sql_str                long;
  l_from_str               long;
  l_where_str              long;
  --
  l_efc_batch              boolean;
  l_detected               boolean;
  l_pk1                    number;
  --
  l_currepe_row            ben_determine_rates.g_curr_epe_rec;
  l_per_row                per_all_people_F%rowtype;
  l_asg_row                per_all_assignments_f%rowtype;
  l_ast_row                per_assignment_status_types%rowtype;
  l_adr_row                per_addresses%rowtype;
  --
  l_val                    number;
  l_mn_elcn_val            number;
  l_mx_elcn_val            number;
  l_ann_val                number;
  l_ann_mn_elcn_val        number;
  l_ann_mx_elcn_val        number;
  l_cmcd_val               number;
  l_cmcd_mn_elcn_val       number;
  l_cmcd_mx_elcn_val       number;
  l_incrmt_elcn_val        number;
  l_dflt_val               number;
  l_ann_dflt_val           number;
  l_dsply_mn_elcn_val      number;
  l_dsply_mx_elcn_val      number;
  --
  l_dummy_varchar2         varchar2(100);
  l_dummy_number           number;
  l_dummy_date             date;
  --
  l_faterr_code            varchar2(100);
  l_faterr_type            varchar2(100);
  --
  l_olddata                boolean;
  --
  l_vpf_id                 number;
  l_adjfailed              boolean;
  --
  l_val_type               varchar2(100);
  l_old_val1               number;
  l_new_val1               number;
  l_preconv_val            number;
  l_postconv_val           number;
  --
  l_lf_evt_ocrd_dt         date;
  l_person_id              number;
  l_per_in_ler_id          number;
  l_prev_bgp_id            number;
  --
  cursor c_apr
    (c_apr_id         in number
    ,c_lf_evt_ocrd_dt in date
    )
  is
    select apr.actl_prem_id,
           apr.mlt_cd,
           apr.val,
           apr.rndg_cd,
           apr.rndg_rl,
           apr.rt_typ_cd,
           apr.bnft_rt_typ_cd,
           apr.comp_lvl_fctr_id,
           apr.prem_asnmt_cd,
           apr.val_calc_rl,
           apr.upr_lmt_val,
           apr.upr_lmt_calc_rl,
           apr.lwr_lmt_val,
           apr.lwr_lmt_calc_rl,
           apr.uom
    from   ben_actl_prem_f apr
    where  apr.actl_prem_id = c_apr_id
    and    apr.prem_asnmt_cd = 'ENRT'
    and    c_lf_evt_ocrd_dt
           between apr.effective_start_date
           and     apr.effective_end_date;
  --
  l_apr c_apr%rowtype;
  --
  cursor c_epeenb_dets
    (c_epe_id in number
    )
  is
    select enb.val
    from BEN_ELIG_PER_ELCTBL_CHC epe,
         ben_enrt_bnft enb
    where epe.ELIG_PER_ELCTBL_CHC_id = c_epe_id
    and   epe.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id;
  --
  cursor c_enb_dets
    (c_enb_id in number
    )
  is
    select enb.val,
           enb.last_update_date
    from ben_enrt_bnft enb
    where enb.enrt_bnft_id = c_enb_id;
  --
  l_enb_dets   c_enb_dets%rowtype;
  --
  cursor c_pgmdets
    (c_pgm_id   in number
    ,c_eff_date in date
    )
  is
    select pgm.acty_ref_perd_cd,
           pgm.object_version_number,
           pgm.last_update_date
    from   ben_pgm_f pgm
    where  pgm.pgm_id = c_pgm_id
    and    c_eff_date
      between pgm.effective_start_date
           and pgm.effective_end_date;
  --
  l_pgmdets   c_pgmdets%rowtype;
  --
  cursor c_abrdets
    (c_abr_id   in number
    ,c_eff_date in date
    )
  is
    select abr.rt_mlt_cd,
           abr.actl_prem_id,
           abr.last_update_date,
           abr.rndg_cd,
           abr.rndg_rl,
           abr.use_calc_acty_bs_rt_flag,
           abr.nnmntry_uom,
           abr.val,
           abr.entr_val_at_enrt_flag,
           abr.entr_ann_val_flag,
           abr.mn_elcn_val,
           abr.mx_elcn_val,
           abr.incrmt_elcn_val
    from   ben_acty_base_rt_f abr
    where  abr.acty_base_rt_id = c_abr_id
    and    c_eff_date
      between abr.effective_start_date
           and abr.effective_end_date;
  --
  l_abrdets   c_abrdets%rowtype;
  --
  cursor c_abrvpfdets
    (c_abr_id   in number
    ,c_eff_date in date
    )
  is
    select vrp.vrbl_rt_prfl_id,
           vrp.mlt_cd
    from   ben_acty_vrbl_rt_f avr,
           ben_vrbl_rt_prfl_f vrp
    where  vrp.vrbl_rt_prfl_stat_cd = 'A'
    and    c_eff_date
      between vrp.effective_start_date
           and vrp.effective_end_date
    and    avr.acty_base_rt_id = c_abr_id
    and    vrp.vrbl_rt_prfl_id = avr.vrbl_rt_prfl_id
    and    c_eff_date
      between avr.effective_start_date
           and     avr.effective_end_date;
  --
  l_abrvpfdets   c_abrvpfdets%rowtype;
  --
  cursor c_epeaprepr
    (c_actl_prem_id           in number
    ,c_elig_per_elctbl_chc_id in number
    )
  is
    select epr.val,
           pil.per_in_ler_stat_cd
    from   ben_enrt_prem epr,
           ben_per_in_ler pil,
           ben_elig_per_elctbl_chc epe
    where  epr.actl_prem_id = c_actl_prem_id
      and  epr.elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id
      and  epe.elig_per_elctbl_chc_id = epr.elig_per_elctbl_chc_id
      and  pil.per_in_ler_id = epe.per_in_ler_id;
  --
  l_epeaprepr   c_epeaprepr%rowtype;
  --
  cursor c_asgppp
    (c_asg_id in number
    )
  is
    select ppp.change_date
    from   per_pay_proposals ppp
    where  ppp.assignment_id = c_asg_id
    order  by ppp.change_date desc;
  --
  l_asgppp   c_asgppp%rowtype;
  --
  cursor c_preconvdets
    (c_efc_action_id number
    ,c_ecr_id        number
    )
  is
    select efc.CMCD_MN_ELCN_VAL,
           efc.CMCD_MX_ELCN_VAL,
           efc.CMCD_VAL,
           efc.CMCD_DFLT_VAL,
           efc.ANN_DFLT_VAL,
           efc.DSPLY_MN_ELCN_VAL,
           efc.DSPLY_MX_ELCN_VAL,
           efc.DFLT_VAL,
           efc.ANN_VAL,
           efc.ANN_MN_ELCN_VAL,
           efc.ANN_MX_ELCN_VAL,
           efc.MX_ELCN_VAL,
           efc.MN_ELCN_VAL,
           efc.INCRMT_ELCN_VAL,
           efc.VAL,
           nvl(efc.pgm_uom,efc.nip_pl_uom) uom
    from ben_enrt_rt_efc efc
    where efc.efc_action_id = c_efc_action_id
    and   efc.enrt_rt_id    = c_ecr_id;
  --
  l_preconvdets c_preconvdets%rowtype;
  --
begin
  --
  l_efc_batch          := FALSE;
  --
  l_row_count          := 0;
  l_calfail_count      := 0;
  l_calsucc_count      := 0;
  l_dupconv_count      := 0;
  l_conv_count         := 0;
  l_actconv_count      := 0;
  l_unconv_count       := 0;
  --
  l_faterrs_count  := 0;
  l_rcoerr_count   := 0;
  --
  l_chunkrow_count := 0;
  --
  g_ecr_success_adj_val_set.delete;
  g_ecr_failed_adj_val_set.delete;
  g_ecr_rcoerr_val_set.delete;
  g_ecr_fatal_error_val_set.delete;
  --
  -- Check if EFC process parameters are set
  --
  if p_action_id is not null
    and p_pk1 is not null
    and p_chunk is not null
    and p_efc_worker_id is not null
  then
    --
    l_efc_batch := TRUE;
    --
  end if;
  --
  l_from_str := ' FROM ben_enrt_rt ecr ';
  --
  l_where_str := ' where (ecr.val is not null '
                 ||' or ecr.ann_val is not null '
                 ||' or ecr.dflt_val is not null '
                 ||' or ecr.ann_dflt_val is not null '
                 ||' or ecr.cmcd_val is not null '
                 ||' ) '
                 ;
  --
  -- Check if we are restricting by business group
  --
  if p_business_group_id is not null then
    --
    l_where_str := l_where_str||' and ecr.business_group_id = '||p_business_group_id;
    --
  end if;
  --
  -- Build in batch specific restrictions
  --
  if l_efc_batch then
    --
    l_from_str  := l_from_str||', ben_enrt_rt_efc efc ';
    l_where_str := l_where_str||' and efc.enrt_rt_id = ecr.enrt_rt_id '
                   ||' and   efc.efc_action_id       = :action_id '
                   ||' and   ecr.enrt_rt_id          > :pk1 '
                   ||' and   mod(ecr.enrt_rt_id, :total_workers) = :worker_id ';
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    l_where_str := l_where_str||' and mod(ecr.enrt_rt_id, :valtotal_workers) = :valworker_id ';
    --
  end if;
  --
  l_sql_str  := ' select ecr.enrt_rt_id, '
                ||'      ecr.elig_per_elctbl_chc_id, '
                ||'      ecr.enrt_bnft_id, '
                ||'      ecr.acty_base_rt_id, '
                ||'      ecr.business_group_id, '
                ||'      ecr.cmcd_mn_elcn_val, '
                ||'      ecr.cmcd_mx_elcn_val, '
                ||'      ecr.cmcd_val, '
                ||'      ecr.cmcd_dflt_val, '
                ||'      ecr.ann_dflt_val, '
                ||'      ecr.dsply_mn_elcn_val, '
                ||'      ecr.dsply_mx_elcn_val, '
                ||'      ecr.dflt_val, '
                ||'      ecr.ann_val, '
                ||'      ecr.ann_mn_elcn_val, '
                ||'      ecr.ann_mx_elcn_val, '
                ||'      ecr.mx_elcn_val, '
                ||'      ecr.mn_elcn_val, '
                ||'      ecr.incrmt_elcn_val, '
                ||'      ecr.val, '
                ||'      ecr.last_update_date, '
                ||'      ecr.creation_date, '
                ||'      ecr.object_version_number '
                ||l_from_str
                ||l_where_str
                ||' order by ecr.enrt_rt_id ';
  --
  if l_efc_batch then
    --
/*
    l_sql_str := l_sql_str||' FOR UPDATE OF ecr.enrt_rt_id ';
    --
*/
    hr_efc_info.insert_line('-- ');
    hr_efc_info.insert_line('-- Adjusting enrolment rates. Worker: '||p_worker_id
                           ||' of '||p_total_workers
                           );
    hr_efc_info.insert_line('-- ');
    --
    open c_efc_rows FOR l_sql_str using p_action_id, p_pk1, p_total_workers, p_worker_id;
    --
  elsif p_valworker_id is not null
    and p_valtotal_workers is not null
  then
    --
    open c_efc_rows FOR l_sql_str using p_valtotal_workers, p_valworker_id;
    --
  else
    --
    hr_efc_info.insert_line('-- ');
    hr_efc_info.insert_line('-- Validating enrolment rate adjustments');
    hr_efc_info.insert_line('-- ');
    --
    open c_efc_rows FOR l_sql_str;
    --
  end if;
  --
  ben_epe_cache.clear_down_cache;
  --
  loop
    --
    FETCH c_efc_rows INTO l_efc_row;
    EXIT WHEN c_efc_rows%NOTFOUND;
    --
    l_faterr_code := null;
    l_adjfailed   := FALSE;
    --
    if l_faterr_code is null
    then
      --
      -- Detect EPE or ENB Info
      --
      ben_efc_adjustments.DetectEPEENBInfo
        (p_elig_per_elctbl_chc_id => l_efc_row.elig_per_elctbl_chc_id
        ,p_enrt_bnft_id           => l_efc_row.enrt_bnft_id
        --
        ,p_currpil_row            => l_currpil_row
        ,p_currepe_row            => l_currepe_row
        ,p_faterr_code            => l_faterr_code
        ,p_faterr_type            => l_faterr_type
        );
      --
      l_lf_evt_ocrd_dt := l_currpil_row.lf_evt_ocrd_dt;
      l_person_id      := l_currpil_row.person_id;
      l_per_in_ler_id  := l_currpil_row.per_in_ler_id;
      --
      -- Set up benefits environment
      --
      ben_env_object.init
        (p_business_group_id => l_efc_row.business_group_id
        ,p_effective_date    => l_lf_evt_ocrd_dt
        ,p_thread_id         => 1
        ,p_chunk_size        => 10
        ,p_threads           => 1
        ,p_max_errors        => 100
        ,p_benefit_action_id => 99999
        ,p_audit_log_flag    => 'N'
        );
      --
    end if;
    --
    -- Check ABR info
    --
    if l_faterr_code is null then
      --
      open c_abrdets
        (c_abr_id   => l_efc_row.acty_base_rt_id
        ,c_eff_date => l_lf_evt_ocrd_dt
        );
      fetch c_abrdets into l_abrdets;
      if c_abrdets%notfound then
        --
        l_faterr_code := 'NODTABR';
        l_faterr_type := 'DELETEDINFO';
        --
      end if;
      close c_abrdets;
      --
    end if;
    --
    -- Check for flat amount
    --
    if l_abrdets.rt_mlt_cd = 'FLFX'
      and l_faterr_code is null
    then
      --
      l_faterr_code   := 'ABRMCFLFX';
      l_faterr_type   := 'VALIDEXCLUSION';
      --
    end if;
    --
    -- Validate PGM info
    --
    if l_currepe_row.pgm_id is not null
      and l_faterr_code is null
    then
      --
      open c_pgmdets
        (c_pgm_id   => l_currepe_row.pgm_id
        ,c_eff_date => l_lf_evt_ocrd_dt
        );
      fetch c_pgmdets into l_pgmdets;
      if c_pgmdets%notfound then
        --
        l_faterr_code   := 'NODTPGM';
        --
      end if;
      close c_pgmdets;
      --
    end if;
    --
    if l_faterr_code is null then
      --
      -- Check actual premium info
      --
      if l_abrdets.rt_mlt_cd = 'AP'
        and l_abrdets.actl_prem_id is not null
        and l_faterr_code is null
      then
        --
        open c_apr
          (c_apr_id         => l_abrdets.actl_prem_id
          ,c_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
          );
        fetch c_apr into l_apr;
        if c_apr%notfound then
          --
          l_faterr_code := 'NODTAPR';
          l_faterr_type := 'DELETEDINFO';
          --
        end if;
        close c_apr;
        --
        if l_apr.uom = 'EUR'
          and l_faterr_code is null
        then
          --
          l_faterr_code := 'EUROUOM';
          l_faterr_type := 'VALIDEXCLUSION';
          --
        end if;
        --
      end if;
      --
    end if;
    --
    -- Check the coverage has not been modified
    --
    if l_faterr_code is null
      and l_efc_row.enrt_bnft_id is not null
    then
      --
      open c_enb_dets
        (c_enb_id => l_efc_row.enrt_bnft_id
        );
      fetch c_enb_dets into l_enb_dets;
      close c_enb_dets;
      --
    end if;
    --
    -- Check primary assignment information for comp related calcs
    --
    if l_faterr_code is null then
      --
      ben_efc_adjustments.DetectInvAsg
        (p_person_id => l_person_id
        ,p_eff_date  => l_lf_evt_ocrd_dt
        --
        ,p_perasg    => l_perasg
        ,p_noasgpay  => l_detected
        );
      --
      if l_detected then
        --
        l_faterr_code    := 'NOASGPAY';
        l_faterr_type    := 'MISSINGSETUP';
        --
      end if;
      --
    end if;
    --
    if l_abrdets.rt_mlt_cd in ('CL')
      and l_faterr_code is null
    then
      --
      if l_perasg.pay_basis_id is null then
        --
        l_faterr_code := 'NOASGPBB';
        l_faterr_type := 'MISSINGSETUP';
        --
      end if;
      --
      -- Check if the pay proposal exists for the assignment
      --
      if l_faterr_code is null then
        --
        open c_asgppp
          (c_asg_id => l_perasg.assignment_id
          );
        fetch c_asgppp into l_asgppp;
        if c_asgppp%notfound then
          --
          l_faterr_code    := 'NOASGPPP';
          l_faterr_type    := 'MISSINGSETUP';
          --
        end if;
        close c_asgppp;
        --
      end if;
      --
    end if;
    --
    -- Validate premimum info
    --
    if l_abrdets.rt_mlt_cd in ('APANDCVG','AP')
      and l_faterr_code is null
      and l_currepe_row.ELIG_PER_ELCTBL_CHC_id is not null
    then
      --
      open c_epeaprepr
        (c_actl_prem_id           => l_abrdets.actl_prem_id
        ,c_elig_per_elctbl_chc_id => l_currepe_row.ELIG_PER_ELCTBL_CHC_id
        );
      fetch c_epeaprepr into l_epeaprepr;
      if c_epeaprepr%notfound then
        --
        l_faterr_code       := 'NOEPEAPREPR';
        --
      end if;
      close c_epeaprepr;
      --
      -- Check for a voided or backed out life event
      --
      if l_epeaprepr.per_in_ler_stat_cd in ('VOIDD','BCKDT') then
        --
        l_faterr_code       := 'VOIDBACKPIL';
        l_faterr_type       := 'VALIDEXCLUSION';
        --
      end if;
      --
    end if;
    --
    if l_faterr_code is null then
      --
      -- Clear the ATP/PTA cache
      --
      ben_distribute_rates.clear_down_cache;
      --
      -- Detect EPE or ENB Info
      --
      ben_efc_adjustments.DetectEPEENBInfo
        (p_elig_per_elctbl_chc_id => l_efc_row.elig_per_elctbl_chc_id
        ,p_enrt_bnft_id           => l_efc_row.enrt_bnft_id
        --
        ,p_detect_mode            => 'EPEINFO'
        --
        ,p_currpil_row            => l_currpil_row
        ,p_currepe_row            => l_currepe_row
        ,p_faterr_code            => l_faterr_code
        ,p_faterr_type            => l_faterr_type
        );
      --
      begin
        --
        -- Check for a business group change and refresh vapro caches
        --
        if l_efc_row.business_group_id <> nvl(l_prev_bgp_id,-9999)
        then
          --
          ben_rt_prfl_cache.clear_down_cache;
          l_prev_bgp_id := l_efc_row.business_group_id;
          --
        end if;
        ben_determine_activity_base_rt.main
          (p_currepe_row                 => l_currepe_row
          ,p_per_row                     => l_per_row
          ,p_asg_row                     => l_asg_row
          ,p_ast_row                     => l_ast_row
          ,p_adr_row                     => l_adr_row
          ,p_person_id                   => l_person_id
          ,p_elig_per_elctbl_chc_id      => l_currepe_row.ELIG_PER_ELCTBL_CHC_id
          ,p_enrt_bnft_id                => l_efc_row.enrt_bnft_id
          ,p_acty_base_rt_id             => l_efc_row.acty_base_rt_id
          ,p_effective_date              => l_lf_evt_ocrd_dt
          ,p_lf_evt_ocrd_dt              => l_lf_evt_ocrd_dt
          ,p_perform_rounding_flg        => TRUE
          ,p_val                         => l_val
          ,p_mn_elcn_val                 => l_mn_elcn_val
          ,p_mx_elcn_val                 => l_mx_elcn_val
          ,p_ann_val                     => l_ann_val
          ,p_ann_mn_elcn_val             => l_ann_mn_elcn_val
          ,p_ann_mx_elcn_val             => l_ann_mx_elcn_val
          ,p_cmcd_val                    => l_cmcd_val
          ,p_cmcd_mn_elcn_val            => l_cmcd_mn_elcn_val
          ,p_cmcd_mx_elcn_val            => l_cmcd_mx_elcn_val
          ,p_incrmt_elcn_val             => l_incrmt_elcn_val
          ,p_dflt_val                    => l_dflt_val
          ,p_ann_dflt_val                => l_ann_dflt_val
          ,p_dsply_mn_elcn_val           => l_dsply_mn_elcn_val
          ,p_dsply_mx_elcn_val           => l_dsply_mx_elcn_val
          --
          ,p_cmcd_acty_ref_perd_cd       => l_dummy_varchar2
          ,p_tx_typ_cd                   => l_dummy_varchar2
          ,p_acty_typ_cd                 => l_dummy_varchar2
          ,p_nnmntry_uom                 => l_dummy_varchar2
          ,p_entr_val_at_enrt_flag       => l_dummy_varchar2
          ,p_dsply_on_enrt_flag          => l_dummy_varchar2
          ,p_use_to_calc_net_flx_cr_flag => l_dummy_varchar2
          ,p_rt_usg_cd                   => l_dummy_varchar2
          ,p_bnft_prvdr_pool_id          => l_dummy_number
          ,p_actl_prem_id                => l_dummy_number
          ,p_cvg_calc_amt_mthd_id        => l_dummy_number
          ,p_bnft_rt_typ_cd              => l_dummy_varchar2
          ,p_rt_typ_cd                   => l_dummy_varchar2
          ,p_rt_mlt_cd                   => l_dummy_varchar2
          ,p_comp_lvl_fctr_id            => l_dummy_number
          ,p_entr_ann_val_flag           => l_dummy_varchar2
          ,p_ptd_comp_lvl_fctr_id        => l_dummy_number
          ,p_clm_comp_lvl_fctr_id        => l_dummy_number
          ,p_rt_strt_dt                  => l_dummy_date
          ,p_rt_strt_dt_cd               => l_dummy_varchar2
          ,p_rt_strt_dt_rl               => l_dummy_number
          ,p_prtt_rt_val_id              => l_dummy_number
          ,p_pp_in_yr_used_num           => l_dummy_number
          ,p_ordr_num           	 => l_dummy_number
          ,p_iss_val                     => l_dummy_number
          );
        --
        if l_efc_row.val <> nvl(l_val,-999999)
        then
          --
          l_adjfailed := TRUE;
          l_val_type := 'ECR_VAL';
          l_old_val1 := l_efc_row.val;
          l_new_val1 := l_val;
          --
        elsif l_efc_row.ann_val <> nvl(l_ann_val,-999999)
        then
          --
          l_adjfailed := TRUE;
          l_val_type := 'ECR_ANNVAL';
          l_old_val1 := l_efc_row.ann_val;
          l_new_val1 := l_ann_val;
          --
        elsif l_efc_row.dflt_val <> nvl(l_dflt_val,-999999)
        then
          --
          l_adjfailed := TRUE;
          l_val_type := 'ECR_DFLTVAL';
          l_old_val1 := l_efc_row.dflt_val;
          l_new_val1 := l_dflt_val;
          --
        elsif l_efc_row.ann_dflt_val <> nvl(l_ann_dflt_val,-999999)
        then
          --
          l_adjfailed := TRUE;
          l_val_type := 'ECR_ANNDFLTVAL';
          l_old_val1 := l_efc_row.ann_dflt_val;
          l_new_val1 := l_ann_dflt_val;
          --
        elsif l_efc_row.cmcd_val <> nvl(l_cmcd_val,-999999)
        then
          --
          l_adjfailed := TRUE;
          l_val_type := 'ECR_CMCDVAL';
          l_old_val1 := l_efc_row.cmcd_val;
          l_new_val1 := l_cmcd_val;
        --
        -- Copied straight from a Vapro or ABR. No adjustment required.
        --
/*
        elsif l_efc_row.incrmt_elcn_val <> nvl(l_incrmt_elcn_val,-999999)
        then
          --
          l_adjfailed := TRUE;
          l_val_type := 'ECR_INCELVAL';
          l_old_val1 := l_efc_row.incrmt_elcn_val;
          l_new_val1 := l_incrmt_elcn_val;
          --
        elsif l_efc_row.mx_elcn_val <> nvl(l_mx_elcn_val,-999999)
        then
          --
          l_adjfailed := TRUE;
          l_val_type := 'ECR_MXELVAL';
          l_old_val1 := l_efc_row.mx_elcn_val;
          l_new_val1 := l_mx_elcn_val;
          --
        elsif l_efc_row.ann_mx_elcn_val <> nvl(l_ann_mx_elcn_val,-999999)
        then
          --
          l_adjfailed := TRUE;
          l_val_type := 'ECR_ANNMXELVAL';
          l_old_val1 := l_efc_row.ann_mx_elcn_val;
          l_new_val1 := l_ann_mx_elcn_val;
          --
        elsif l_efc_row.dsply_mx_elcn_val <> nvl(l_dsply_mx_elcn_val,-999999)
        then
          --
          l_adjfailed := TRUE;
          l_val_type := 'ECR_DSMXELVAL';
          l_old_val1 := l_efc_row.dsply_mx_elcn_val;
          l_new_val1 := l_dsply_mx_elcn_val;
          --
        elsif l_efc_row.cmcd_mx_elcn_val <> nvl(l_cmcd_mx_elcn_val,-999999)
        then
          --
          l_adjfailed := TRUE;
          l_val_type := 'ECR_CMCDMXELVAL';
          l_old_val1 := l_efc_row.cmcd_mx_elcn_val;
          l_new_val1 := l_cmcd_mx_elcn_val;
          --
        elsif l_efc_row.mn_elcn_val <> nvl(l_mn_elcn_val,-999999)
        then
          --
          l_adjfailed := TRUE;
          l_val_type := 'ECR_MNELVAL';
          l_old_val1 := l_efc_row.mn_elcn_val;
          l_new_val1 := l_mn_elcn_val;
          --
        elsif l_efc_row.ann_mn_elcn_val <> nvl(l_ann_mn_elcn_val,-999999)
        then
          --
          l_adjfailed := TRUE;
          l_val_type := 'ECR_ANNMNELVAL';
          l_old_val1 := l_efc_row.ann_mn_elcn_val;
          l_new_val1 := l_ann_mn_elcn_val;
          --
        elsif l_efc_row.dsply_mn_elcn_val <> nvl(l_dsply_mn_elcn_val,-999999)
        then
          --
          l_adjfailed := TRUE;
          l_val_type := 'ECR_DSMNELVAL';
          l_old_val1 := l_efc_row.dsply_mn_elcn_val;
          l_new_val1 := l_dsply_mn_elcn_val;
          --
        elsif l_efc_row.cmcd_mn_elcn_val <> nvl(l_cmcd_mn_elcn_val,-999999)
        then
          --
          l_adjfailed := TRUE;
          l_val_type := 'ECR_CMCDMNELVAL';
          l_old_val1 := l_efc_row.cmcd_mn_elcn_val;
          l_new_val1 := l_cmcd_mn_elcn_val;
          --
*/
        else
          --
          l_faterr_code := null;
          l_adjfailed   := FALSE;
          l_val_type    := 'ECR_VAL';
          --
          -- Added so that converted vals can be checked
          --
          l_old_val1 := l_efc_row.val;
          l_new_val1 := l_val;
          --
        end if;
        --
        -- Success and failure checks
        --
        -- Check for a non monetary UOM
        --
        if l_abrdets.NNMNTRY_UOM is not null
          and l_faterr_code is null
        then
          --
          l_faterr_code   := 'ABRNONMONUOM';
          l_faterr_type   := 'VALIDEXCLUSION';
        --
        -- Check for enter value at enrolment
        --
        elsif l_abrdets.entr_val_at_enrt_flag = 'Y'
          and l_faterr_code is null
        then
          --
          l_faterr_code   := 'ABREVAEFLGY';
          l_faterr_type   := 'VALIDEXCLUSION';
          --
        end if;
        --
        -- Check if the adjustment failed
        --
        if l_adjfailed then
          --
          -- Get the currency conversion factor details
          --
          if l_faterr_code is null
            and l_efc_batch
          then
            --
            if l_faterr_code is null then
              --
              -- get pre conversion details
              --
              open c_preconvdets
                (c_efc_action_id => p_action_id
                ,c_ecr_id        => l_efc_row.enrt_rt_id
                );
              fetch c_preconvdets into l_preconvdets;
              if c_preconvdets%notfound then
                --
                l_faterr_code   := 'NOEFCACTEEV';
                l_faterr_type   := 'CORRUPTDATA';
                --
              end if;
              close c_preconvdets;
              --
            end if;
            --
            if l_faterr_code is null then
              --
              if l_val_type = 'ECR_VAL' then
                --
                l_preconv_val := l_preconvdets.val;
                --
              elsif l_val_type = 'ECR_ANNVAL' then
                --
                l_preconv_val := l_preconvdets.ANN_VAL;
                --
              elsif l_val_type = 'ECR_DFLTVAL' then
                --
                l_preconv_val := l_preconvdets.DFLT_VAL;
                --
              elsif l_val_type = 'ECR_ANNDFLTVAL' then
                --
                l_preconv_val := l_preconvdets.ANN_DFLT_VAL;
                --
              elsif l_val_type = 'ECR_CMCDVAL' then
                --
                l_preconv_val := l_preconvdets.CMCD_VAL;
                --
/*
              --
              -- Copied straight from a Vapro or ABR. No adjustment required.
              --
              elsif l_val_type = 'ECR_INCELVAL' then
                --
                l_preconv_val := l_preconvdets.INCRMT_ELCN_VAL;
                --
              elsif l_val_type = 'ECR_MXELVAL' then
                --
                l_preconv_val := l_preconvdets.MX_ELCN_VAL;
                --
              elsif l_val_type = 'ECR_MNELVAL' then
                --
                l_preconv_val := l_preconvdets.MN_ELCN_VAL;
                --
              elsif l_val_type = 'ECR_ANNMXELVAL' then
                --
                l_preconv_val := l_preconvdets.ANN_MX_ELCN_VAL;
                --
              elsif l_val_type = 'ECR_ANNMNELVAL' then
                --
                l_preconv_val := l_preconvdets.ANN_MN_ELCN_VAL;
                --
              elsif l_val_type = 'ECR_DSMNELVAL' then
                --
                l_preconv_val := l_preconvdets.DSPLY_MN_ELCN_VAL;
                --
              elsif l_val_type = 'ECR_DSMXELVAL' then
                --
                l_preconv_val := l_preconvdets.DSPLY_MX_ELCN_VAL;
                --
              elsif l_val_type = 'ECR_CMCDMNELVAL' then
                --
                l_preconv_val := l_preconvdets.CMCD_MN_ELCN_VAL;
                --
              elsif l_val_type = 'ECR_CMCDMXELVAL' then
                --
                l_preconv_val := l_preconvdets.CMCD_MX_ELCN_VAL;
                --
*/
              end if;
              --
/*
              ben_efc_adjustments.DetectConvInfo
                (p_ncucurr_code => l_preconvdets.uom
                ,p_new_val      => l_new_val1
                ,p_preconv_val  => l_preconv_val
                --
                ,p_faterr_code  => l_faterr_code
                ,p_faterr_type  => l_faterr_type
                ,p_postconv_val => l_postconv_val
                );
              --
              if l_faterr_code is not null then
                --
                l_old_val1 := l_preconv_val;
                l_new_val1 := l_postconv_val;
                --
              end if;
              --
*/
            end if;
            --
          end if;
          --
          -- Check for hard coded rounding code
          --
          if l_faterr_code is null then
            --
            ben_efc_adjustments.DetectRoundInfo
              (p_rndg_cd        => l_abrdets.rndg_cd
              ,p_rndg_rl        => l_abrdets.rndg_rl
              ,p_old_val        => l_old_val1
              ,p_new_val        => l_new_val1
              ,p_eff_date       => l_lf_evt_ocrd_dt
              --
              ,p_faterr_code    => l_faterr_code
              ,p_faterr_type    => l_faterr_type
              );
            --
            if (nvl(l_abrdets.last_update_date,hr_api.g_sot)
              > nvl(l_efc_row.last_update_date,hr_api.g_eot))
              and l_faterr_code is null
            then
              --
              l_faterr_code := 'ABRCORR';
              l_faterr_type := 'CORRECTEDINFO';
              --
            end if;
            --
          end if;
          --
          -- Check VAPRO info
          --
          if l_faterr_code is null
            and l_abrdets.use_calc_acty_bs_rt_flag = 'Y'
          then
            --
            -- Validate vapro
            --
            ben_efc_adjustments.DetectVAPROInfo
              (p_currepe_row      => l_currepe_row
              --
              ,p_lf_evt_ocrd_dt   => l_lf_evt_ocrd_dt
              ,p_last_update_date => l_efc_row.last_update_date
              --
              ,p_acty_base_rt_id  => l_efc_row.acty_base_rt_id
              --
              ,p_vpfdets          => l_vpfdets
              ,p_vpf_id           => l_vpf_id
              ,p_faterr_code      => l_faterr_code
              ,p_faterr_type      => l_faterr_type
              );
            --
            -- Check for a replace rate type. A code fix has been made since the
            -- original info was created.
            --
            if l_vpfdets.vrbl_rt_trtmt_cd = 'RPLC'
              and l_faterr_code is null
            then
              --
              l_faterr_code := 'INVADJRPLCVPF';
              l_faterr_type := 'CODECHANGE';
              --
            end if;
            --
          end if;
          --
          -- Check for a null value
          --
          if l_new_val1 is null
            and l_faterr_code is null
          then
            --
            l_faterr_code   := 'NULLADJECRVAL';
            l_faterr_type   := 'ADJUSTBUG';
            --
          end if;
          --
          if l_faterr_code is null then
            --
            ben_efc_adjustments.DetectWhoInfo
              (p_creation_date         => l_efc_row.creation_date
              ,p_last_update_date      => l_efc_row.last_update_date
              ,p_object_version_number => l_efc_row.object_version_number
              --
              ,p_who_counts            => l_who_counts
              ,p_faterr_code           => l_faterr_code
              ,p_faterr_type           => l_faterr_type
              );
            --
          end if;
          --
          if l_faterr_code is null then
            --
            g_ecr_failed_adj_val_set(l_calfail_count).id       := l_efc_row.enrt_rt_id;
            g_ecr_failed_adj_val_set(l_calfail_count).old_val1 := l_old_val1;
            g_ecr_failed_adj_val_set(l_calfail_count).new_val1 := l_new_val1;
            g_ecr_failed_adj_val_set(l_calfail_count).val_type := l_val_type;
            g_ecr_failed_adj_val_set(l_calfail_count).code1    := l_abrdets.rt_mlt_cd;
            g_ecr_failed_adj_val_set(l_calfail_count).credt    := l_efc_row.creation_date;
            g_ecr_failed_adj_val_set(l_calfail_count).lud      := l_efc_row.last_update_date;
            --
            l_calfail_count := l_calfail_count+1;
            --
          end if;
          --
        end if;
        --
        if l_efc_batch
          and (l_faterr_code is null
            or nvl(l_faterr_type,'ZZZZ') = 'CONVEXCLUSION')
        then
          --
          update ben_enrt_rt ecr
          set  ecr.val               = l_val,
               ecr.ann_val           = l_ann_val,
               ecr.dflt_val          = l_dflt_val,
               ecr.ann_dflt_val      = l_ann_dflt_val,
               ecr.cmcd_val          = l_cmcd_val
/*
               --
               -- Copied straight from a Vapro or ABR. No adjustment required.
               --
               ecr.cmcd_mn_elcn_val  = l_cmcd_mn_elcn_val,
               ecr.cmcd_mx_elcn_val  = l_cmcd_mx_elcn_val,
               ecr.dsply_mn_elcn_val = l_dsply_mn_elcn_val,
               ecr.dsply_mx_elcn_val = l_dsply_mx_elcn_val,
               ecr.ann_mn_elcn_val   = l_ann_mn_elcn_val,
               ecr.ann_mx_elcn_val   = l_ann_mx_elcn_val,
               ecr.mx_elcn_val       = l_mx_elcn_val,
               ecr.mn_elcn_val       = l_mn_elcn_val,
               ecr.incrmt_elcn_val   = l_incrmt_elcn_val,
*/
          where ecr.enrt_rt_id = l_efc_row.enrt_rt_id;
          --
          -- Check for end of chunk and commit if necessary
          --
          l_pk1 := l_efc_row.enrt_rt_id;
          --
          ben_efc_functions.maintain_chunks
            (p_row_count     => l_chunkrow_count
            ,p_pk1           => l_pk1
            ,p_chunk_size    => p_chunk
            ,p_efc_worker_id => p_efc_worker_id
            );
          --
        end if;
        --
      exception
        when others then
          --
          ben_efc_adjustments.DetectAppError
            (p_sqlerrm                   => SQLERRM
            ,p_abr_rt_mlt_cd             => l_abrdets.rt_mlt_cd
            ,p_abr_val                   => l_abrdets.val
            ,p_abr_entr_val_at_enrt_flag => l_abrdets.entr_val_at_enrt_flag
            ,p_abr_id                    => l_efc_row.acty_base_rt_id
            ,p_eff_date                  => l_lf_evt_ocrd_dt
            --
            ,p_faterr_code               => l_faterr_code
            ,p_faterr_type               => l_faterr_type
            );
          --
          if instr(SQLERRM,'92749') > 0
          then
            --
            l_faterr_code   := 'NOSTSALSTCOMP';
            l_faterr_type   := 'MISSINGSETUP';
            --
          elsif instr(SQLERRM,'92741') > 0
          then
            --
            l_faterr_code   := 'NOPLNCCMCVGMC';
            l_faterr_type   := 'DELETEDINFO';
            --
          elsif instr(SQLERRM,'92746') > 0
          then
            --
            l_faterr_code   := 'NULLCOMP';
            l_faterr_type   := 'POTENTIALCODEBUG';
            --
          elsif instr(SQLERRM,'92748') > 0
          then
            --
            l_faterr_code   := 'NULLENBIDCVGMC';
            l_faterr_type   := 'POTENTIALCODEBUG';
            --
          end if;
          --
          if l_faterr_code is null then
            --
            g_ecr_rcoerr_val_set(l_rcoerr_count).id        := l_efc_row.enrt_rt_id;
            g_ecr_rcoerr_val_set(l_rcoerr_count).rco_name  := 'BENACTBR';
            g_ecr_rcoerr_val_set(l_rcoerr_count).sql_error := SQLERRM;
            g_ecr_rcoerr_val_set(l_rcoerr_count).credt     := l_efc_row.creation_date;
            g_ecr_rcoerr_val_set(l_rcoerr_count).lud       := l_efc_row.last_update_date;
            --
            l_rcoerr_count  := l_rcoerr_count+1;
            --
          end if;
          --
      end;
      --
    end if;
    --
    -- Check for fatal errors
    --
    if l_faterr_code is not null
    then
      --
      g_ecr_fatal_error_val_set(l_faterrs_count).id          := l_efc_row.enrt_rt_id;
      g_ecr_fatal_error_val_set(l_faterrs_count).faterr_code := l_faterr_code;
      g_ecr_fatal_error_val_set(l_faterrs_count).faterr_type := l_faterr_type;
      g_ecr_fatal_error_val_set(l_faterrs_count).val_type    := l_val_type;
      g_ecr_fatal_error_val_set(l_faterrs_count).old_val1    := l_old_val1;
      g_ecr_fatal_error_val_set(l_faterrs_count).new_val1    := l_new_val1;
      g_ecr_fatal_error_val_set(l_faterrs_count).code1       := l_abrdets.rt_mlt_cd;
      g_ecr_fatal_error_val_set(l_faterrs_count).lud         := l_efc_row.last_update_date;
      g_ecr_fatal_error_val_set(l_faterrs_count).credt       := l_efc_row.creation_date;
      --
      l_faterrs_count := l_faterrs_count+1;
      --
    elsif l_faterr_code is null
      and not l_adjfailed
    then
      --
      g_ecr_success_adj_val_set(l_calsucc_count).id       := l_efc_row.enrt_rt_id;
      g_ecr_success_adj_val_set(l_calsucc_count).old_val1 := l_old_val1;
      g_ecr_success_adj_val_set(l_calsucc_count).new_val1 := l_new_val1;
      g_ecr_success_adj_val_set(l_calsucc_count).credt    := l_efc_row.creation_date;
      g_ecr_success_adj_val_set(l_calsucc_count).lud      := l_efc_row.last_update_date;
      --
      l_calsucc_count := l_calsucc_count+1;
      --
    end if;
    --
    l_row_count   := l_row_count+1;
    --
  end loop;
  CLOSE c_efc_rows;
/*
  --
  -- Write exceptions down to the table
  --
  if l_efc_batch then
    --
    ben_efc_adjustments.insert_validation_exceptions
      (p_val_set        => g_ecr_failed_adj_val_set
      ,p_efc_action_id  => p_action_id
      ,p_ent_scode      => 'ECR'
      ,p_exception_type => 'AF'
      );
    --
    ben_efc_adjustments.insert_validation_exceptions
      (p_val_set        => g_ecr_fatal_error_val_set
      ,p_efc_action_id  => p_action_id
      ,p_ent_scode      => 'ECR'
      ,p_exception_type => null
      );
    --
  end if;
*/
  --
  -- Check that all rows have been converted or excluded
  --
  ben_efc_functions.conv_check
    (p_table_name      => 'ben_enrt_rt'
    ,p_efctable_name   => 'ben_enrt_rt_efc'
    ,p_tabwhere_clause => ' (cmcd_mn_elcn_val is not null '
                          ||' or cmcd_mn_elcn_val is not null '
                          ||' or cmcd_mx_elcn_val is not null '
                          ||' or cmcd_val is not null '
                          ||' or cmcd_dflt_val is not null '
                          ||' or ann_dflt_val is not null '
                          ||' or dsply_mn_elcn_val is not null '
                          ||' or dsply_mx_elcn_val is not null '
                          ||' or dflt_val is not null '
                          ||' or ann_val is not null '
                          ||' or ann_mn_elcn_val is not null '
                          ||' or ann_mx_elcn_val is not null '
                          ||' or mx_elcn_val is not null '
                          ||' or mn_elcn_val is not null '
                          ||' or incrmt_elcn_val is not null '
                          ||' or val is not null) '
    --
    ,p_bgp_id        => p_business_group_id
    ,p_action_id     => p_action_id
    --
    ,p_conv_count    => l_conv_count
    ,p_unconv_count  => l_unconv_count
    ,p_tabrow_count  => l_tabrow_count
    );
  --
  -- Set counts
  --
  if p_action_id is null then
    --
    l_actconv_count := 0;
    --
  else
    --
    l_actconv_count := l_conv_count;
    --
  end if;
  --
  p_adjustment_counts.efcrow_count      := l_row_count;
  p_adjustment_counts.tabrow_count      := l_tabrow_count;
  p_adjustment_counts.actconv_count     := l_actconv_count;
  p_adjustment_counts.calfail_count     := l_calfail_count;
  p_adjustment_counts.calsucc_count     := l_calsucc_count;
  p_adjustment_counts.dupconv_count     := l_dupconv_count;
  p_adjustment_counts.conv_count        := l_conv_count;
  p_adjustment_counts.unconv_count      := l_unconv_count;
  p_adjustment_counts.faterrs_count     := l_faterrs_count;
  p_adjustment_counts.rcoerr_count      := l_rcoerr_count;
  --
end ecr_adjustments;
--
end ben_efc_adjustments;

/
