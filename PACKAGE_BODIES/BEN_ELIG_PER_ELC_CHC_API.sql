--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_PER_ELC_CHC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_PER_ELC_CHC_API" as
/* $Header: beepeapi.pkb 120.0.12010000.2 2008/08/05 14:24:37 ubhat ship $ */
--
-- Package Variables
--
g_debug boolean := hr_utility.debug_enabled;
g_package  varchar2(33) := '  ben_elig_per_elc_chc_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< CreOrSel_pil_elctbl_chc_popl >--------------------|
-- ----------------------------------------------------------------------------
--
-- Create or select ben_pil_elctbl_chc_popl
--
procedure CreOrSel_pil_elctbl_chc_popl
  (p_per_in_ler_id          in     number
  ,p_effective_date         in     date
  ,p_business_group_id      in     number
  ,p_pgm_id                 in     number
  ,p_plip_id                in     number
  ,p_pl_id                  in     number
  ,p_oipl_id                in     number
  ,p_yr_perd_id             in     number
  ,p_uom                    in     varchar2
  ,p_acty_ref_perd_cd       in     varchar2
  ,p_dflt_enrt_dt           in     date
  ,p_cls_enrt_dt_to_use_cd  in     varchar2
  ,p_enrt_typ_cycl_cd       in     varchar2
  ,p_enrt_perd_end_dt       in     date
  ,p_enrt_perd_strt_dt      in     date
  ,p_procg_end_dt           in     date
  ,p_lee_rsn_id             in     number
  ,p_enrt_perd_id           in     number
  ,p_request_id             in     number
  ,p_program_application_id in     number
  ,p_program_id             in     number
  ,p_program_update_date    in     date
  ,p_ws_mgr_id              in     number
  ,p_assignment_id          in     number
  --
  ,p_pil_elctbl_chc_popl_id    out nocopy number
  ,p_oiplip_id                 out nocopy number
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ;
  --
  l_elig_per_elctbl_chc_id ben_elig_per_elctbl_chc.elig_per_elctbl_chc_id%TYPE;
  l_object_version_number ben_elig_per_elctbl_chc.object_version_number%TYPE;
  l_cbr_elig_perd_strt_dt ben_pil_elctbl_chc_popl.cbr_elig_perd_strt_dt%TYPE;
  l_cbr_elig_perd_end_dt  ben_pil_elctbl_chc_popl.cbr_elig_perd_end_dt%TYPE;
  l_pel_pl_id number;
  l_pel_pgm_id number;
  l_pil_elctbl_chc_popl_id number;
  l_pel_ovn number;
  l_pel_dflt_enrt_dt date;
  l_pel_cls_enrt_dt_to_use_cd varchar2(30);
  l_pel_enrt_typ_cycl_cd varchar2(30);
  l_pel_enrt_perd_strt_dt date;
  l_pel_enrt_perd_end_dt date;
  l_pel_lee_rsn_id number;
  l_pel_enrt_perd_id number;
  l_pel_procg_end_dt date;
  l_pel_uom varchar2(30):=p_uom;
  l_pel_acty_ref_perd_cd varchar2(30):=p_acty_ref_perd_cd;
  l_pel_create boolean;
  l_update_pel boolean;
  l_ws_iss_dt    date;
  l_bdgt_iss_dt  date;
  --
  -- Cursors
  --
  cursor c_pel_at_pgm_level is
    select
      pil_elctbl_chc_popl_id,
      object_version_number,
      dflt_enrt_dt,
      cls_enrt_dt_to_use_cd,
      enrt_typ_cycl_cd,
      enrt_perd_strt_dt,
      enrt_perd_end_dt,
      lee_rsn_id,
      enrt_perd_id,
      procg_end_dt,
      uom,
      acty_ref_perd_cd
    from ben_pil_elctbl_chc_popl
    where
      per_in_ler_id=p_per_in_ler_id and
      pgm_id=l_pel_pgm_id
    ;
  --
  cursor c_pel_at_pl_level is
    select
      pil_elctbl_chc_popl_id,
      object_version_number,
      dflt_enrt_dt,
      cls_enrt_dt_to_use_cd,
      enrt_typ_cycl_cd,
      enrt_perd_strt_dt,
      enrt_perd_end_dt,
      lee_rsn_id,
      enrt_perd_id,
      procg_end_dt,
      uom,
      acty_ref_perd_cd
    from ben_pil_elctbl_chc_popl
    where
      per_in_ler_id=p_per_in_ler_id and
      pl_id=l_pel_pl_id
    ;

  cursor get_oiplip is
    select oiplip_id
    from   ben_oiplip_f oi
    where  oi.oipl_id = p_oipl_id
    and    oi.plip_id = p_plip_id
    and    p_effective_date between
           oi.effective_start_date and oi.effective_end_date;
  l_oiplip_id number;
  --
   cursor c_yrp is
      select yrp.end_date
      from   ben_yr_perd yrp
      where  yrp.yr_perd_id = p_yr_perd_id
      and    yrp.business_group_id = p_business_group_id;
  l_yr_perd_end_dt   date := null;
  --
  --
  -- Bug 2174005
  --
  cursor c_enp is
      select enp.DFLT_WS_ACC_CD ,enp.ler_id,
             enp.WS_UPD_END_DT, enp.BDGT_UPD_END_DT,
             enp.auto_distr_flag,
             enp.reinstate_cd,
             enp.reinstate_ovrdn_cd
      from   ben_enrt_perd enp
      where  enrt_perd_id = p_enrt_perd_id;
  --
  cursor c_len(c_effective_date date,
               c_lee_rsn_id number)  is
      select len.reinstate_cd,
             len.reinstate_ovrdn_cd
        from ben_lee_rsn_f len
       where len.lee_rsn_id = c_lee_rsn_id
         and c_effective_date between len.effective_start_date
                                  and len.effective_end_date ;
  CURSOR c_abr_pl(
      c_pl_id  number,
      c_effective_date DATE) IS
      SELECT   'Y'
      FROM     ben_acty_base_rt_f abr
      WHERE    abr.acty_base_rt_stat_cd = 'A'
      AND      abr.pl_id = c_pl_id
      AND      abr.rt_usg_cd <> 'FLXCR'
      and      abr.acty_typ_cd in ('CWBWB','CWBDB')
      AND      c_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date;
  --
   CURSOR c_abr_oipl(
      c_oipl_id   number,
      c_effective_date DATE) IS
      SELECT   'Y'
      FROM     ben_acty_base_rt_f abr
      WHERE    abr.acty_base_rt_stat_cd = 'A'
      AND      abr.oipl_id = c_oipl_id
      AND      abr.rt_usg_cd <> 'FLXCR'
      and      abr.acty_typ_cd in ('CWBWB','CWBDB')
      AND      c_effective_date BETWEEN abr.effective_start_date
                   AND abr.effective_end_date;
  cursor c_oipl (p_pl_id number) is
    select opt.oipl_id
    from  ben_oipl_f opt
    where pl_id = p_pl_id
    and p_effective_date between opt.effective_start_date
        and opt.effective_end_date;
  --

  l_enp_rec          c_enp%rowtype;
  l_bdgt_acc_cd      varchar2(30);
  l_ws_acc_cd        varchar2(30);
  l_bdgt_stat_cd     varchar2(30);
  l_ws_stat_cd       varchar2(30);
  l_pop_cd           varchar2(30);
  l_ws_upd_end_dt    date;
  l_bdgt_upd_end_dt  date;
  l_auto_distr_flag  varchar2(1) := 'N';
  l_oipl_id          number;
  --Bug 4068639
  l_enrt_perd_id		number;
  l_pgm_id			number;
  l_pl_id			number;
  l_lee_rsn_id			number;
  l_cls_enrt_dt_to_use_cd	varchar2(30);
  l_acty_ref_perd_cd		varchar2(30);
  l_uom				varchar2(30);
  l_dflt_enrt_dt		date;
  l_enrt_perd_end_dt		date;
  l_enrt_perd_strt_dt		date;
  l_procg_end_dt		date;
  l_reinstate_cd                varchar2(30);
  l_reinstate_ovrdn_cd          varchar2(30);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if g_debug then
    l_proc := g_package||'CreOrSel_pil_elctbl_chc_popl';
    --
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.set_location(' p_pgm_id  '||p_pgm_id,120);
    hr_utility.set_location(' p_pl_id   '||p_pl_id,120);
    hr_utility.set_location(' p_lee_rsn_id  '||p_lee_rsn_id,120);
    hr_utility.set_location(' p_enrt_perd_id '||p_enrt_perd_id,120);
    --
  end if;
  --
  -- Create or find ben_pil_elctbl_chc_popl
  --
  -- Determine if plan or program level record is needed
  --
  if p_pgm_id is not null then
    l_pel_pgm_id:=p_pgm_id;
    l_pel_pl_id:=null;
    open c_pel_at_pgm_level;
    fetch c_pel_at_pgm_level into
      l_pil_elctbl_chc_popl_id,
      l_pel_ovn,
      l_pel_dflt_enrt_dt,
      l_pel_cls_enrt_dt_to_use_cd,
      l_pel_enrt_typ_cycl_cd,
      l_pel_enrt_perd_strt_dt,
      l_pel_enrt_perd_end_dt,
      l_pel_lee_rsn_id,
      l_pel_enrt_perd_id,
      l_pel_procg_end_dt,
      l_pel_uom,
      l_pel_acty_ref_perd_cd;
    l_pel_create:=c_pel_at_pgm_level%notfound;
    close c_pel_at_pgm_level;
  elsif p_pl_id is not null then -- and pgm_id is null
    l_pel_pgm_id:=null;
    l_pel_pl_id:=p_pl_id;
    open c_pel_at_pl_level;
    fetch c_pel_at_pl_level into
      l_pil_elctbl_chc_popl_id,
      l_pel_ovn,
      l_pel_dflt_enrt_dt,
      l_pel_cls_enrt_dt_to_use_cd,
      l_pel_enrt_typ_cycl_cd,
      l_pel_enrt_perd_strt_dt,
      l_pel_enrt_perd_end_dt,
      l_pel_lee_rsn_id,
      l_pel_enrt_perd_id,
      l_pel_procg_end_dt,
      l_pel_uom,
      l_pel_acty_ref_perd_cd;
    l_pel_create:=c_pel_at_pl_level%notfound;
    close c_pel_at_pl_level;
  else -- big trouble, neither is filled in error.
    if g_debug then
      hr_utility.set_location('BEN_?????_EPE_PL_OR_PGM', 22);
    end if;
    fnd_message.set_name('BEN','BEN_?????_EPE_PL_OR_PGM');
    fnd_message.raise_error;
  end if;
  --
  if l_pel_create then
    --
    if g_debug then
      hr_utility.set_location('BPECPAPI_CRE: '|| l_proc, 10);
    end if;
    --
    -- Bug 2174005
    --
    open c_enp;
    fetch c_enp into l_enp_rec;
    --
    if c_enp%found then
       --
       if g_debug then
         hr_utility.set_location('Enp found',11);
       end if;
       if l_enp_rec.ler_id is not null then
          -- It is compensation Work Bench type of plan.
          --
          l_bdgt_acc_cd       := 'NA'; -- Not Available
          l_ws_acc_cd         := l_enp_rec.DFLT_WS_ACC_CD;
          l_bdgt_stat_cd      := 'NS'; -- Not Started
          l_ws_stat_cd        := 'NS'; -- Not Started
          l_pop_cd            := 'D'; -- Direct Managers
          l_ws_upd_end_dt     := l_enp_rec.ws_upd_end_dt;
          l_bdgt_upd_end_dt   := l_enp_rec.bdgt_upd_end_dt;
          --
          if l_enp_rec.auto_distr_flag = 'Y' then
              open c_oipl (p_pl_id);
              fetch c_oipl into l_oipl_id;
              close c_oipl;
                --
              if l_oipl_id is not null then
                --
                open c_abr_oipl (l_oipl_id ,p_effective_date);
                fetch c_abr_oipl into l_auto_distr_flag;
                close c_abr_oipl;
                --
              else
                --
                open c_abr_pl (p_pl_id, p_effective_date);
                fetch c_abr_pl into l_auto_distr_flag;
                close c_abr_pl;
              end if;
              --hr_utility.set_location ('Auto distribute'||l_auto_distr_flag,12);
              if l_auto_distr_flag = 'Y' then
                l_bdgt_stat_cd  := 'IS';
                --l_ws_stat_cd    := 'IS';
                l_ws_iss_dt       := p_effective_date;
                l_bdgt_iss_dt     := p_effective_date;
              end if;
              --
           end if;

       end if;
       l_reinstate_cd      := l_enp_rec.reinstate_cd;
       l_reinstate_ovrdn_cd:= l_enp_rec.reinstate_ovrdn_cd;
       --
    end if;
    --
    -- Bug 2174005
    --
    close c_enp;
    --
    if p_lee_rsn_id is not null then
      --
      open c_len(p_effective_date,p_lee_rsn_id) ;
        fetch c_len into l_reinstate_cd,l_reinstate_ovrdn_cd;
      close c_len ;
      --
    end if;
    --
    --Bug 4068639 : When Creating PIL record, if some of the parameters
    --are erroneously set to default(values from HR_API package),
    --then pass their default value in create_Pil_Elctbl_chc_Popl procedure.

    if p_enrt_perd_id = hr_api.g_number then	--p_enrt_perd_id
      l_enrt_perd_id := null;
    else
      l_enrt_perd_id := p_enrt_perd_id;
    end if;

    if l_pel_pgm_id = hr_api.g_number then	--p_pgm_id
      l_pgm_id := null;
    else
      l_pgm_id := l_pel_pgm_id;
    end if;

    if l_pel_pl_id = hr_api.g_number then	--p_pl_id
      l_pl_id := null;
    else
      l_pl_id := l_pel_pl_id;
    end if;

    if p_lee_rsn_id = hr_api.g_number then	--p_lee_rsn_id
      l_lee_rsn_id := null;
    else
      l_lee_rsn_id := p_lee_rsn_id;
    end if;

    if l_pel_uom = hr_api.g_varchar2 then	--p_uom
      l_uom := null;
    else
      l_uom := l_pel_uom;
    end if;

    if p_cls_enrt_dt_to_use_cd = hr_api.g_varchar2 then	--p_cls_enrt_dt_to_use_cd
      l_cls_enrt_dt_to_use_cd := null;
    else
      l_cls_enrt_dt_to_use_cd := p_cls_enrt_dt_to_use_cd;
    end if;

    if l_pel_acty_ref_perd_cd = hr_api.g_varchar2 then	--p_acty_ref_perd_cd
      l_acty_ref_perd_cd := null;
    else
      l_acty_ref_perd_cd := l_pel_acty_ref_perd_cd;
    end if;

    if p_dflt_enrt_dt = hr_api.g_date then	--p_dflt_enrt_dt
      l_dflt_enrt_dt := null;
    else
      l_dflt_enrt_dt := p_dflt_enrt_dt;
    end if;

    if p_enrt_perd_end_dt = hr_api.g_date then	--p_enrt_perd_end_dt
      l_enrt_perd_end_dt := null;
    else
      l_enrt_perd_end_dt := p_enrt_perd_end_dt;
    end if;

    if p_enrt_perd_strt_dt = hr_api.g_date then	--p_enrt_perd_strt_dt
      l_enrt_perd_strt_dt := null;
    else
      l_enrt_perd_strt_dt := p_enrt_perd_strt_dt;
    end if;

    if p_procg_end_dt = hr_api.g_date then	--p_procg_end_dt
      l_procg_end_dt := null;
    else
      l_procg_end_dt := p_procg_end_dt;
    end if;
    --
    hr_utility.set_location(' l_reinstate_cd '||l_reinstate_cd,100);
    hr_utility.set_location(' l_reinstate_ovrdn_cd '||l_reinstate_ovrdn_cd,100);
    --
    ben_Pil_Elctbl_chc_Popl_api.create_Pil_Elctbl_chc_Popl
    (p_validate                       => FALSE
    ,p_pil_elctbl_chc_popl_id         => l_pil_elctbl_chc_popl_id
    ,p_dflt_enrt_dt                   => l_dflt_enrt_dt
    ,p_cls_enrt_dt_to_use_cd          => l_cls_enrt_dt_to_use_cd
    ,p_enrt_typ_cycl_cd               => p_enrt_typ_cycl_cd
    ,p_enrt_perd_end_dt               => l_enrt_perd_end_dt
    ,p_enrt_perd_strt_dt              => l_enrt_perd_strt_dt
    ,p_procg_end_dt                   => l_procg_end_dt
    ,p_pil_elctbl_popl_stat_cd        => 'STRTD'
    ,p_cbr_elig_perd_strt_dt          => l_cbr_elig_perd_strt_dt
    ,p_cbr_elig_perd_end_dt           => l_cbr_elig_perd_end_dt
    ,p_lee_rsn_id                     => l_lee_rsn_id
    ,p_enrt_perd_id                   => l_enrt_perd_id
    ,p_per_in_ler_id                  => p_per_in_ler_id
    ,p_business_group_id              => p_business_group_id
    ,p_request_id                     => p_request_id
    ,p_program_application_id         => p_program_application_id
    ,p_program_id                     => p_program_id
    ,p_program_update_date            => p_program_update_date
    ,p_object_version_number          => l_pel_ovn
    ,p_effective_date                 => p_effective_date
    ,p_pl_id                          => l_pl_id
    ,p_pgm_id                         => l_pgm_id
    ,p_uom                            => l_uom
    ,p_acty_ref_perd_cd               => l_acty_ref_perd_cd
    -- Bug 2174005
    ,p_ws_due_dt                      => l_ws_upd_end_dt
    ,p_bdgt_due_dt                    => l_bdgt_upd_end_dt
    ,p_bdgt_acc_cd                    => l_bdgt_acc_cd
    ,p_ws_acc_cd                      => l_ws_acc_cd
    ,p_bdgt_stat_cd                   => l_bdgt_stat_cd
    ,p_ws_stat_cd                     => l_ws_stat_cd
    ,p_pop_cd                         => l_pop_cd
    ,p_bdgt_iss_dt                    => l_bdgt_iss_dt
    ,p_ws_iss_dt                      => l_ws_iss_dt
    ,p_reinstate_cd                   => l_reinstate_cd
    ,p_reinstate_ovrdn_cd             => l_reinstate_ovrdn_cd
    );
   if g_debug then
     hr_utility.set_location('l_pil_elctbl_chc_popl_id '|| l_pil_elctbl_chc_popl_id, 10);
   end if;
   if g_debug then
     hr_utility.set_location('p_ws_mgr_id '|| p_ws_mgr_id, 10);
   end if;
   if g_debug then
     hr_utility.set_location('p_assignment_id '|| p_assignment_id, 10);
   end if;
    update ben_Pil_Elctbl_chc_Popl
    set ws_mgr_id = p_ws_mgr_id,
        assignment_id = p_assignment_id
    where Pil_Elctbl_chc_Popl_id = l_pil_elctbl_chc_popl_id;
   if g_debug then
     hr_utility.set_location('Dn BPECPAPI_CRE: '|| l_proc, 10);
   end if;
   --
   -- If the enrollment period spans beyond the year period, issue a message.
   --
   hr_utility.set_location('fnd_global.conc_request_id:'||fnd_global.conc_request_id,10);
   if fnd_global.conc_request_id <> -1 then
     --
     open  c_yrp;
     fetch c_yrp into l_yr_perd_end_dt;
     close c_yrp;
     --
     if p_enrt_perd_end_dt > l_yr_perd_end_dt or
        p_dflt_enrt_dt     > l_yr_perd_end_dt or
        p_procg_end_dt     > l_yr_perd_end_dt then
       --
       fnd_message.set_name('BEN','BEN_92551_ENRT_PRD_BYND_YR_PRD');
       benutils.write(p_text => substr(fnd_message.get,1,128));
       --
     end if;
     --
   end if;
   --
  else
    --
    -- Check to see which attributes need to be updated
    --
    l_update_pel:=false;
    if l_pel_dflt_enrt_dt is null and p_dflt_enrt_dt is not null then
      l_update_pel:=true;
      l_pel_dflt_enrt_dt:=p_dflt_enrt_dt;
    end if;
    if l_pel_cls_enrt_dt_to_use_cd is null and p_cls_enrt_dt_to_use_cd is not null then
      l_update_pel:=true;
      l_pel_cls_enrt_dt_to_use_cd:=p_cls_enrt_dt_to_use_cd;
    end if;
    if l_pel_enrt_typ_cycl_cd is null and p_enrt_typ_cycl_cd is not null then
      l_update_pel:=true;
      l_pel_enrt_typ_cycl_cd:=p_enrt_typ_cycl_cd;
    end if;
    if l_pel_enrt_perd_strt_dt is null and p_enrt_perd_strt_dt is not null then
      l_update_pel:=true;
      l_pel_enrt_perd_strt_dt:=p_enrt_perd_strt_dt;
    end if;
    if l_pel_enrt_perd_end_dt is null and p_enrt_perd_end_dt is not null then
      l_update_pel:=true;
      l_pel_enrt_perd_end_dt:=p_enrt_perd_end_dt;
    end if;
    if l_pel_lee_rsn_id is null and p_lee_rsn_id is not null then
      l_update_pel:=true;
      l_pel_lee_rsn_id:=p_lee_rsn_id;
    end if;
    if l_pel_enrt_perd_id is null and p_enrt_perd_id is not null then
      l_update_pel:=true;
      l_pel_enrt_perd_id:=p_enrt_perd_id;
    end if;
    if l_pel_procg_end_dt is null and p_procg_end_dt is not null then
      l_update_pel:=true;
      l_pel_procg_end_dt:=p_procg_end_dt;
    end if;
    if l_pel_uom is null and p_uom is not null then
      l_update_pel:=true;
      l_pel_uom:=p_uom;
    end if;
    if l_pel_acty_ref_perd_cd is null and p_acty_ref_perd_cd is not null then
      l_update_pel:=true;
      l_pel_acty_ref_perd_cd:=p_acty_ref_perd_cd;
    end if;
    --
    -- If any attributes need to be updated, then do it.
    --
    if l_update_pel then
      if g_debug then
        hr_utility.set_location('BPECPAPI_UPD: '|| l_proc, 10);
      end if;
      ben_Pil_Elctbl_chc_Popl_api.update_Pil_Elctbl_chc_Popl
      (p_validate                       => FALSE
      ,p_pil_elctbl_chc_popl_id         => l_pil_elctbl_chc_popl_id
      ,p_object_version_number          => l_pel_ovn
      ,p_dflt_enrt_dt                   => l_pel_dflt_enrt_dt
      ,p_cls_enrt_dt_to_use_cd          => l_pel_cls_enrt_dt_to_use_cd
      ,p_enrt_typ_cycl_cd               => l_pel_enrt_typ_cycl_cd
      ,p_enrt_perd_end_dt               => l_pel_enrt_perd_end_dt
      ,p_enrt_perd_strt_dt              => l_pel_enrt_perd_strt_dt
      ,p_procg_end_dt                   => l_pel_procg_end_dt
      ,p_lee_rsn_id                     => l_pel_lee_rsn_id
      ,p_enrt_perd_id                   => l_pel_enrt_perd_id
      ,p_effective_date                 => p_effective_date
      ,p_uom                            => l_pel_uom
      ,p_acty_ref_perd_cd               => l_pel_acty_ref_perd_cd
      );
      if g_debug then
        hr_utility.set_location('Dn BPECPAPI_UPD: '|| l_proc, 10);
      end if;
    end if;
  end if;
  --
  -- Finished with pil_elctbl_chc_popl stuff
  --
  -- Get oiplip_id for options in plans in programs.
  --
  if p_oiplip_id is null
    and p_oipl_id is not null
    and p_pgm_id is not null
  then
     if g_debug then
       hr_utility.set_location('get_oiplip', 25);
     end if;
     open get_oiplip;
     fetch get_oiplip into l_oiplip_id;
     close get_oiplip;
  else
     l_oiplip_id := p_oiplip_id;
  end if;
  --
  -- Set out parameters
  --
  p_pil_elctbl_chc_popl_id := l_pil_elctbl_chc_popl_id;
  p_oiplip_id              := l_oiplip_id;
  --
end CreOrSel_pil_elctbl_chc_popl;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELIG_PER_ELC_CHC >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_PER_ELC_CHC
  (p_validate                       in  boolean   default false
  ,p_elig_per_elctbl_chc_id         out nocopy number
  ,p_enrt_typ_cycl_cd               in  varchar2  default null
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_enrt_perd_end_dt               in  date      default null
  ,p_enrt_perd_strt_dt              in  date      default null
  ,p_enrt_cvg_strt_dt_rl            in  varchar2  default null
  ,p_ctfn_rqd_flag                  in varchar2    default 'N'
  ,p_pil_elctbl_chc_popl_id         in number      default null
  ,p_roll_crs_flag                  in  varchar2  default 'N'
  ,p_crntly_enrd_flag               in  varchar2  default 'N'
  ,p_dflt_flag                      in  varchar2  default 'N'
  ,p_elctbl_flag                    in  varchar2  default 'N'
  ,p_mndtry_flag                    in  varchar2  default 'N'
  ,p_in_pndg_wkflow_flag            in  varchar2  default 'N'
  ,p_dflt_enrt_dt                   in  date      default null
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_dpnt_cvg_strt_dt_rl            in  varchar2  default null
  ,p_enrt_cvg_strt_dt               in  date      default null
  ,p_alws_dpnt_dsgn_flag            in  varchar2  default 'N'
  ,p_dpnt_dsgn_cd                   in  varchar2  default null
  ,p_ler_chg_dpnt_cvg_cd            in  varchar2  default null
  ,p_erlst_deenrt_dt                in  date      default null
  ,p_procg_end_dt                   in  date      default null
  ,p_comp_lvl_cd                    in  varchar2  default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pgm_typ_cd                     in  varchar2  default null
  ,p_plip_id                        in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_oiplip_id                      in  number    default null
  ,p_cmbn_plip_id                   in  number    default null
  ,p_cmbn_ptip_id                   in  number    default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_assignment_id                  in  number    default null
  ,p_spcl_rt_pl_id                  in  number    default null
  ,p_spcl_rt_oipl_id                in  number    default null
  ,p_must_enrl_anthr_pl_id          in  number    default null
  ,p_int_elig_per_elctbl_chc_id in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_bnft_prvdr_pool_id             in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_yr_perd_id                     in  number    default null
  ,p_auto_enrt_flag                 in  varchar2  default 'N'
  ,p_business_group_id              in  number    default null
  ,p_pl_ordr_num                    in  number    default null
  ,p_plip_ordr_num                  in  number    default null
  ,p_ptip_ordr_num                  in  number    default null
  ,p_oipl_ordr_num                  in  number    default null
  -- cwb
  ,p_comments                        in  varchar2   default null
  ,p_elig_flag                       in  varchar2   default 'Y'
  ,p_elig_ovrid_dt                   in  date       default null
  ,p_elig_ovrid_person_id            in  number     default null
  ,p_inelig_rsn_cd                   in  varchar2   default null
  ,p_mgr_ovrid_dt                    in  date       default null
  ,p_mgr_ovrid_person_id             in  number     default null
  ,p_ws_mgr_id                       in  number     default null
  -- cwb
  ,p_epe_attribute_category         in  varchar2  default null
  ,p_epe_attribute1                 in  varchar2  default null
  ,p_epe_attribute2                 in  varchar2  default null
  ,p_epe_attribute3                 in  varchar2  default null
  ,p_epe_attribute4                 in  varchar2  default null
  ,p_epe_attribute5                 in  varchar2  default null
  ,p_epe_attribute6                 in  varchar2  default null
  ,p_epe_attribute7                 in  varchar2  default null
  ,p_epe_attribute8                 in  varchar2  default null
  ,p_epe_attribute9                 in  varchar2  default null
  ,p_epe_attribute10                in  varchar2  default null
  ,p_epe_attribute11                in  varchar2  default null
  ,p_epe_attribute12                in  varchar2  default null
  ,p_epe_attribute13                in  varchar2  default null
  ,p_epe_attribute14                in  varchar2  default null
  ,p_epe_attribute15                in  varchar2  default null
  ,p_epe_attribute16                in  varchar2  default null
  ,p_epe_attribute17                in  varchar2  default null
  ,p_epe_attribute18                in  varchar2  default null
  ,p_epe_attribute19                in  varchar2  default null
  ,p_epe_attribute20                in  varchar2  default null
  ,p_epe_attribute21                in  varchar2  default null
  ,p_epe_attribute22                in  varchar2  default null
  ,p_epe_attribute23                in  varchar2  default null
  ,p_epe_attribute24                in  varchar2  default null
  ,p_epe_attribute25                in  varchar2  default null
  ,p_epe_attribute26                in  varchar2  default null
  ,p_epe_attribute27                in  varchar2  default null
  ,p_epe_attribute28                in  varchar2  default null
  ,p_epe_attribute29                in  varchar2  default null
  ,p_epe_attribute30                in  varchar2  default null
  ,p_approval_status_cd             in  varchar2  default null
  ,p_fonm_cvg_strt_dt               in  date      default null
  ,p_cryfwd_elig_dpnt_cd            in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_enrt_perd_id                   in  number    default null
  ,p_lee_rsn_id                     in  number    default null
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default null
  ,p_uom                            in  varchar2  default null
  ,p_acty_ref_perd_cd               in  varchar2  default null
  )
is
  --
  l_proc varchar2(72) ;
  --
  l_elig_per_elctbl_chc_id ben_elig_per_elctbl_chc.elig_per_elctbl_chc_id%TYPE;
  l_object_version_number  ben_elig_per_elctbl_chc.object_version_number%TYPE;
  l_pil_elctbl_chc_popl_id number;
  l_oiplip_id              number;
  --
begin
  --
   g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'create_ELIG_PER_ELC_CHC';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ELIG_PER_ELC_CHC;
  --
  --
  -- Create or find ben_pil_elctbl_chc_popl
  --
  CreOrSel_pil_elctbl_chc_popl
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
    ,p_enrt_typ_cycl_cd       => p_enrt_typ_cycl_cd
    ,p_enrt_perd_end_dt       => p_enrt_perd_end_dt
    ,p_enrt_perd_strt_dt      => p_enrt_perd_strt_dt
    ,p_procg_end_dt           => p_procg_end_dt
    ,p_lee_rsn_id             => p_lee_rsn_id
    ,p_enrt_perd_id           => p_enrt_perd_id
    ,p_request_id             => p_request_id
    ,p_program_application_id => p_program_application_id
    ,p_program_id             => p_program_id
    ,p_program_update_date    => p_program_update_date
    ,p_ws_mgr_id              => p_ws_mgr_id
    ,p_assignment_id          => p_assignment_id
    --
    ,p_pil_elctbl_chc_popl_id => l_pil_elctbl_chc_popl_id
    ,p_oiplip_id              => l_oiplip_id
    );
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ELIG_PER_ELC_CHC
    --
    ben_ELIG_PER_ELC_CHC_bk1.create_ELIG_PER_ELC_CHC_b
      (
--       p_elig_per_elctbl_chc_id         =>  l_elig_per_elctbl_chc_id
       p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_ctfn_rqd_flag                  =>  p_ctfn_rqd_flag
      ,p_pil_elctbl_chc_popl_id         =>  l_pil_elctbl_chc_popl_id
      ,p_roll_crs_flag                  =>  p_roll_crs_flag
      ,p_crntly_enrd_flag               =>  p_crntly_enrd_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_elctbl_flag                    =>  p_elctbl_flag
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_in_pndg_wkflow_flag            =>  p_in_pndg_wkflow_flag
      ,p_dpnt_cvg_strt_dt_cd            =>  p_dpnt_cvg_strt_dt_cd
      ,p_dpnt_cvg_strt_dt_rl            =>  p_dpnt_cvg_strt_dt_rl
      ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
      ,p_alws_dpnt_dsgn_flag            =>  p_alws_dpnt_dsgn_flag
      ,p_dpnt_dsgn_cd                   =>  p_dpnt_dsgn_cd
      ,p_ler_chg_dpnt_cvg_cd            =>  p_ler_chg_dpnt_cvg_cd
      ,p_erlst_deenrt_dt                =>  p_erlst_deenrt_dt
      ,p_procg_end_dt                   =>  p_procg_end_dt
      ,p_comp_lvl_cd                    =>  p_comp_lvl_cd
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_plip_id                        =>  p_plip_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_oiplip_id                      =>  l_oiplip_id
      ,p_cmbn_plip_id                   =>  p_cmbn_ptip_id
      ,p_cmbn_ptip_id                   =>  p_cmbn_ptip_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_assignment_id                  =>  p_assignment_id
      ,p_spcl_rt_pl_id                  =>  p_spcl_rt_pl_id
      ,p_spcl_rt_oipl_id                =>  p_spcl_rt_oipl_id
      ,p_must_enrl_anthr_pl_id          =>  p_must_enrl_anthr_pl_id
      ,p_int_elig_per_elctbl_chc_id     =>  p_int_elig_per_elctbl_chc_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_auto_enrt_flag                 =>  p_auto_enrt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_ordr_num                    =>  p_pl_ordr_num
      ,p_plip_ordr_num                  =>  p_plip_ordr_num
      ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
      ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
      --cwb
      ,p_comments                      => p_comments
      ,p_elig_flag                     => p_elig_flag
      ,p_elig_ovrid_dt                 => p_elig_ovrid_dt
      ,p_elig_ovrid_person_id          => p_elig_ovrid_person_id
      ,p_inelig_rsn_cd                 => p_inelig_rsn_cd
      ,p_mgr_ovrid_dt                  => p_mgr_ovrid_dt
      ,p_mgr_ovrid_person_id           => p_mgr_ovrid_person_id
      ,p_ws_mgr_id                     => p_ws_mgr_id
      --cwb
      ,p_epe_attribute_category         =>  p_epe_attribute_category
      ,p_epe_attribute1                 =>  p_epe_attribute1
      ,p_epe_attribute2                 =>  p_epe_attribute2
      ,p_epe_attribute3                 =>  p_epe_attribute3
      ,p_epe_attribute4                 =>  p_epe_attribute4
      ,p_epe_attribute5                 =>  p_epe_attribute5
      ,p_epe_attribute6                 =>  p_epe_attribute6
      ,p_epe_attribute7                 =>  p_epe_attribute7
      ,p_epe_attribute8                 =>  p_epe_attribute8
      ,p_epe_attribute9                 =>  p_epe_attribute9
      ,p_epe_attribute10                =>  p_epe_attribute10
      ,p_epe_attribute11                =>  p_epe_attribute11
      ,p_epe_attribute12                =>  p_epe_attribute12
      ,p_epe_attribute13                =>  p_epe_attribute13
      ,p_epe_attribute14                =>  p_epe_attribute14
      ,p_epe_attribute15                =>  p_epe_attribute15
      ,p_epe_attribute16                =>  p_epe_attribute16
      ,p_epe_attribute17                =>  p_epe_attribute17
      ,p_epe_attribute18                =>  p_epe_attribute18
      ,p_epe_attribute19                =>  p_epe_attribute19
      ,p_epe_attribute20                =>  p_epe_attribute20
      ,p_epe_attribute21                =>  p_epe_attribute21
      ,p_epe_attribute22                =>  p_epe_attribute22
      ,p_epe_attribute23                =>  p_epe_attribute23
      ,p_epe_attribute24                =>  p_epe_attribute24
      ,p_epe_attribute25                =>  p_epe_attribute25
      ,p_epe_attribute26                =>  p_epe_attribute26
      ,p_epe_attribute27                =>  p_epe_attribute27
      ,p_epe_attribute28                =>  p_epe_attribute28
      ,p_epe_attribute29                =>  p_epe_attribute29
      ,p_epe_attribute30                =>  p_epe_attribute30
      ,p_approval_status_cd           =>  p_approval_status_cd
      ,p_fonm_cvg_strt_dt               =>  p_fonm_cvg_strt_dt
      ,p_cryfwd_elig_dpnt_cd            =>  p_cryfwd_elig_dpnt_cd
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ELIG_PER_ELC_CHC'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ELIG_PER_ELC_CHC
    --
  end;
  --
  -- Use the resulting l_pil_elctbl_chc_popl_id as the FK
  --
  if g_debug then
    hr_utility.set_location('EPE Ins: '|| l_proc, 10);
  end if;
  ben_epe_ins.ins
    (
     p_elig_per_elctbl_chc_id        => l_elig_per_elctbl_chc_id
    ,p_enrt_cvg_strt_dt_cd           => p_enrt_cvg_strt_dt_cd
    ,p_enrt_cvg_strt_dt_rl           => p_enrt_cvg_strt_dt_rl
    ,p_ctfn_rqd_flag                 => p_ctfn_rqd_flag
    ,p_pil_elctbl_chc_popl_id        => l_pil_elctbl_chc_popl_id
    ,p_roll_crs_flag                 => p_roll_crs_flag
    ,p_crntly_enrd_flag              => p_crntly_enrd_flag
    ,p_dflt_flag                     => p_dflt_flag
    ,p_elctbl_flag                   => p_elctbl_flag
    ,p_mndtry_flag                   => p_mndtry_flag
    ,p_in_pndg_wkflow_flag           =>  p_in_pndg_wkflow_flag
    ,p_dpnt_cvg_strt_dt_cd           => p_dpnt_cvg_strt_dt_cd
    ,p_dpnt_cvg_strt_dt_rl           => p_dpnt_cvg_strt_dt_rl
    ,p_enrt_cvg_strt_dt              => p_enrt_cvg_strt_dt
    ,p_alws_dpnt_dsgn_flag           => p_alws_dpnt_dsgn_flag
    ,p_dpnt_dsgn_cd                  => p_dpnt_dsgn_cd
    ,p_ler_chg_dpnt_cvg_cd           => p_ler_chg_dpnt_cvg_cd
    ,p_erlst_deenrt_dt               => p_erlst_deenrt_dt
    ,p_procg_end_dt                  => p_procg_end_dt
    ,p_comp_lvl_cd                   => p_comp_lvl_cd
    ,p_pl_id                         => p_pl_id
    ,p_oipl_id                       => p_oipl_id
    ,p_pgm_id                        => p_pgm_id
    ,p_plip_id                       => p_plip_id
    ,p_ptip_id                       => p_ptip_id
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_oiplip_id                     => l_oiplip_id
    ,p_cmbn_plip_id                  => p_cmbn_plip_id
    ,p_cmbn_ptip_id                  => p_cmbn_ptip_id
    ,p_cmbn_ptip_opt_id              => p_cmbn_ptip_opt_id
    ,p_assignment_id                 => p_assignment_id
    ,p_spcl_rt_pl_id                 => p_spcl_rt_pl_id
    ,p_spcl_rt_oipl_id               => p_spcl_rt_oipl_id
    ,p_must_enrl_anthr_pl_id         => p_must_enrl_anthr_pl_id
    ,p_int_elig_per_elctbl_chc_id => p_int_elig_per_elctbl_chc_id
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_bnft_prvdr_pool_id            => p_bnft_prvdr_pool_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_yr_perd_id                    => p_yr_perd_id
    ,p_auto_enrt_flag                => p_auto_enrt_flag
    ,p_business_group_id             => p_business_group_id
    ,p_pl_ordr_num                   =>  p_pl_ordr_num
    ,p_plip_ordr_num                 =>  p_plip_ordr_num
    ,p_ptip_ordr_num                 =>  p_ptip_ordr_num
    ,p_oipl_ordr_num                 =>  p_oipl_ordr_num
      --cwb
      ,p_comments                      => p_comments
      ,p_elig_flag                     => p_elig_flag
      ,p_elig_ovrid_dt                 => p_elig_ovrid_dt
      ,p_elig_ovrid_person_id          => p_elig_ovrid_person_id
      ,p_inelig_rsn_cd                 => p_inelig_rsn_cd
      ,p_mgr_ovrid_dt                  => p_mgr_ovrid_dt
      ,p_mgr_ovrid_person_id           => p_mgr_ovrid_person_id
      ,p_ws_mgr_id                     => p_ws_mgr_id
      --cwb
    ,p_epe_attribute_category        => p_epe_attribute_category
    ,p_epe_attribute1                => p_epe_attribute1
    ,p_epe_attribute2                => p_epe_attribute2
    ,p_epe_attribute3                => p_epe_attribute3
    ,p_epe_attribute4                => p_epe_attribute4
    ,p_epe_attribute5                => p_epe_attribute5
    ,p_epe_attribute6                => p_epe_attribute6
    ,p_epe_attribute7                => p_epe_attribute7
    ,p_epe_attribute8                => p_epe_attribute8
    ,p_epe_attribute9                => p_epe_attribute9
    ,p_epe_attribute10               => p_epe_attribute10
    ,p_epe_attribute11               => p_epe_attribute11
    ,p_epe_attribute12               => p_epe_attribute12
    ,p_epe_attribute13               => p_epe_attribute13
    ,p_epe_attribute14               => p_epe_attribute14
    ,p_epe_attribute15               => p_epe_attribute15
    ,p_epe_attribute16               => p_epe_attribute16
    ,p_epe_attribute17               => p_epe_attribute17
    ,p_epe_attribute18               => p_epe_attribute18
    ,p_epe_attribute19               => p_epe_attribute19
    ,p_epe_attribute20               => p_epe_attribute20
    ,p_epe_attribute21               => p_epe_attribute21
    ,p_epe_attribute22               => p_epe_attribute22
    ,p_epe_attribute23               => p_epe_attribute23
    ,p_epe_attribute24               => p_epe_attribute24
    ,p_epe_attribute25               => p_epe_attribute25
    ,p_epe_attribute26               => p_epe_attribute26
    ,p_epe_attribute27               => p_epe_attribute27
    ,p_epe_attribute28               => p_epe_attribute28
    ,p_epe_attribute29               => p_epe_attribute29
    ,p_epe_attribute30               => p_epe_attribute30
    ,p_approval_status_cd          => p_approval_status_cd
    ,p_fonm_cvg_strt_dt              => p_fonm_cvg_strt_dt
    ,p_cryfwd_elig_dpnt_cd           => p_cryfwd_elig_dpnt_cd
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  if g_debug then
    hr_utility.set_location('Dn EPE Ins: '|| l_proc, 10);
  end if;
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ELIG_PER_ELC_CHC
    --
    ben_ELIG_PER_ELC_CHC_bk1.create_ELIG_PER_ELC_CHC_a
      (
       p_elig_per_elctbl_chc_id         =>  l_elig_per_elctbl_chc_id
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_ctfn_rqd_flag                  =>  p_ctfn_rqd_flag
      ,p_pil_elctbl_chc_popl_id         =>  l_pil_elctbl_chc_popl_id
      ,p_roll_crs_flag                  =>  p_roll_crs_flag
      ,p_crntly_enrd_flag               =>  p_crntly_enrd_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_elctbl_flag                    =>  p_elctbl_flag
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_in_pndg_wkflow_flag            =>  p_in_pndg_wkflow_flag
      ,p_dpnt_cvg_strt_dt_cd            =>  p_dpnt_cvg_strt_dt_cd
      ,p_dpnt_cvg_strt_dt_rl            =>  p_dpnt_cvg_strt_dt_rl
      ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
      ,p_alws_dpnt_dsgn_flag            =>  p_alws_dpnt_dsgn_flag
      ,p_dpnt_dsgn_cd                   =>  p_dpnt_dsgn_cd
      ,p_ler_chg_dpnt_cvg_cd            =>  p_ler_chg_dpnt_cvg_cd
      ,p_erlst_deenrt_dt                =>  p_erlst_deenrt_dt
      ,p_procg_end_dt                   =>  p_procg_end_dt
      ,p_comp_lvl_cd                    =>  p_comp_lvl_cd
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_plip_id                        =>  p_plip_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_oiplip_id                      =>  l_oiplip_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_cmbn_ptip_id                   =>  p_cmbn_ptip_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_assignment_id                  =>  p_assignment_id
      ,p_spcl_rt_pl_id                  =>  p_spcl_rt_pl_id
      ,p_spcl_rt_oipl_id                =>  p_spcl_rt_oipl_id
      ,p_must_enrl_anthr_pl_id          =>  p_must_enrl_anthr_pl_id
      ,p_int_elig_per_elctbl_chc_id =>  p_int_elig_per_elctbl_chc_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_auto_enrt_flag                 =>  p_auto_enrt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_ordr_num                    =>  p_pl_ordr_num
      ,p_plip_ordr_num                  =>  p_plip_ordr_num
      ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
      ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
      --cwb
      ,p_comments                      => p_comments
      ,p_elig_flag                     => p_elig_flag
      ,p_elig_ovrid_dt                 => p_elig_ovrid_dt
      ,p_elig_ovrid_person_id          => p_elig_ovrid_person_id
      ,p_inelig_rsn_cd                 => p_inelig_rsn_cd
      ,p_mgr_ovrid_dt                  => p_mgr_ovrid_dt
      ,p_mgr_ovrid_person_id           => p_mgr_ovrid_person_id
      ,p_ws_mgr_id                     => p_ws_mgr_id
      --cwb
      ,p_epe_attribute_category         =>  p_epe_attribute_category
      ,p_epe_attribute1                 =>  p_epe_attribute1
      ,p_epe_attribute2                 =>  p_epe_attribute2
      ,p_epe_attribute3                 =>  p_epe_attribute3
      ,p_epe_attribute4                 =>  p_epe_attribute4
      ,p_epe_attribute5                 =>  p_epe_attribute5
      ,p_epe_attribute6                 =>  p_epe_attribute6
      ,p_epe_attribute7                 =>  p_epe_attribute7
      ,p_epe_attribute8                 =>  p_epe_attribute8
      ,p_epe_attribute9                 =>  p_epe_attribute9
      ,p_epe_attribute10                =>  p_epe_attribute10
      ,p_epe_attribute11                =>  p_epe_attribute11
      ,p_epe_attribute12                =>  p_epe_attribute12
      ,p_epe_attribute13                =>  p_epe_attribute13
      ,p_epe_attribute14                =>  p_epe_attribute14
      ,p_epe_attribute15                =>  p_epe_attribute15
      ,p_epe_attribute16                =>  p_epe_attribute16
      ,p_epe_attribute17                =>  p_epe_attribute17
      ,p_epe_attribute18                =>  p_epe_attribute18
      ,p_epe_attribute19                =>  p_epe_attribute19
      ,p_epe_attribute20                =>  p_epe_attribute20
      ,p_epe_attribute21                =>  p_epe_attribute21
      ,p_epe_attribute22                =>  p_epe_attribute22
      ,p_epe_attribute23                =>  p_epe_attribute23
      ,p_epe_attribute24                =>  p_epe_attribute24
      ,p_epe_attribute25                =>  p_epe_attribute25
      ,p_epe_attribute26                =>  p_epe_attribute26
      ,p_epe_attribute27                =>  p_epe_attribute27
      ,p_epe_attribute28                =>  p_epe_attribute28
      ,p_epe_attribute29                =>  p_epe_attribute29
      ,p_epe_attribute30                =>  p_epe_attribute30
      ,p_approval_status_cd           =>  p_approval_status_cd
      ,p_fonm_cvg_strt_dt               =>  p_fonm_cvg_strt_dt
      ,p_cryfwd_elig_dpnt_cd            =>  p_cryfwd_elig_dpnt_cd
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELIG_PER_ELC_CHC'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ELIG_PER_ELC_CHC
    --
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_elig_per_elctbl_chc_id := l_elig_per_elctbl_chc_id;
  p_object_version_number := l_object_version_number;
  --
  if g_debug then
    hr_utility.set_location('p_elig_per_elctbl_chc_id:'|| to_char(l_elig_per_elctbl_chc_id),99);
  end if;

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 99);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_ELIG_PER_ELC_CHC;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_per_elctbl_chc_id := null;
    p_object_version_number  := null;
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_elig_per_elctbl_chc_id := null;
    p_object_version_number  := null;
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
    ROLLBACK TO create_ELIG_PER_ELC_CHC;
    raise;
    --
end create_ELIG_PER_ELC_CHC;
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_perf_ELIG_PER_ELC_CHC >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_perf_ELIG_PER_ELC_CHC
  (p_validate                       in boolean    default false
  ,p_elig_per_elctbl_chc_id         out nocopy number
  ,p_enrt_typ_cycl_cd               in  varchar2  default null
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_enrt_perd_end_dt               in  date      default null
  ,p_enrt_perd_strt_dt              in  date      default null
  ,p_enrt_cvg_strt_dt_rl            in  varchar2  default null
  ,p_ctfn_rqd_flag                  in varchar2   default 'N'
  ,p_pil_elctbl_chc_popl_id         in number     default null
  ,p_roll_crs_flag                  in  varchar2  default 'N'
  ,p_crntly_enrd_flag               in  varchar2  default 'N'
  ,p_dflt_flag                      in  varchar2  default 'N'
  ,p_elctbl_flag                    in  varchar2  default 'N'
  ,p_mndtry_flag                    in  varchar2  default 'N'
  ,p_in_pndg_wkflow_flag            in  varchar2  default 'N'
  ,p_dflt_enrt_dt                   in  date      default null
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_dpnt_cvg_strt_dt_rl            in  varchar2  default null
  ,p_enrt_cvg_strt_dt               in  date      default null
  ,p_alws_dpnt_dsgn_flag            in  varchar2  default 'N'
  ,p_dpnt_dsgn_cd                   in  varchar2  default null
  ,p_ler_chg_dpnt_cvg_cd            in  varchar2  default null
  ,p_erlst_deenrt_dt                in  date      default null
  ,p_procg_end_dt                   in  date      default null
  ,p_comp_lvl_cd                    in  varchar2  default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pgm_typ_cd                     in  varchar2  default null
  ,p_plip_id                        in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_oiplip_id                      in  number    default null
  ,p_cmbn_plip_id                   in  number    default null
  ,p_cmbn_ptip_id                   in  number    default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_assignment_id                  in  number    default null
  ,p_spcl_rt_pl_id                  in  number    default null
  ,p_spcl_rt_oipl_id                in  number    default null
  ,p_must_enrl_anthr_pl_id          in  number    default null
  ,p_int_elig_per_elctbl_chc_id          in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_bnft_prvdr_pool_id             in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_yr_perd_id                     in  number    default null
  ,p_auto_enrt_flag                 in  varchar2  default 'N'
  ,p_business_group_id              in  number    default null
  ,p_pl_ordr_num                    in  number    default null
  ,p_plip_ordr_num                    in  number    default null
  ,p_ptip_ordr_num                    in  number    default null
  ,p_oipl_ordr_num                    in  number    default null
  -- cwb
  ,p_comments                        in  varchar2   default null
  ,p_elig_flag                       in  varchar2   default 'Y'
  ,p_elig_ovrid_dt                   in  date       default null
  ,p_elig_ovrid_person_id            in  number     default null
  ,p_inelig_rsn_cd                   in  varchar2   default null
  ,p_mgr_ovrid_dt                    in  date       default null
  ,p_mgr_ovrid_person_id             in  number     default null
  ,p_ws_mgr_id                       in  number     default null
  -- cwb
  ,p_epe_attribute_category         in  varchar2  default null
  ,p_epe_attribute1                 in  varchar2  default null
  ,p_epe_attribute2                 in  varchar2  default null
  ,p_epe_attribute3                 in  varchar2  default null
  ,p_epe_attribute4                 in  varchar2  default null
  ,p_epe_attribute5                 in  varchar2  default null
  ,p_epe_attribute6                 in  varchar2  default null
  ,p_epe_attribute7                 in  varchar2  default null
  ,p_epe_attribute8                 in  varchar2  default null
  ,p_epe_attribute9                 in  varchar2  default null
  ,p_epe_attribute10                in  varchar2  default null
  ,p_epe_attribute11                in  varchar2  default null
  ,p_epe_attribute12                in  varchar2  default null
  ,p_epe_attribute13                in  varchar2  default null
  ,p_epe_attribute14                in  varchar2  default null
  ,p_epe_attribute15                in  varchar2  default null
  ,p_epe_attribute16                in  varchar2  default null
  ,p_epe_attribute17                in  varchar2  default null
  ,p_epe_attribute18                in  varchar2  default null
  ,p_epe_attribute19                in  varchar2  default null
  ,p_epe_attribute20                in  varchar2  default null
  ,p_epe_attribute21                in  varchar2  default null
  ,p_epe_attribute22                in  varchar2  default null
  ,p_epe_attribute23                in  varchar2  default null
  ,p_epe_attribute24                in  varchar2  default null
  ,p_epe_attribute25                in  varchar2  default null
  ,p_epe_attribute26                in  varchar2  default null
  ,p_epe_attribute27                in  varchar2  default null
  ,p_epe_attribute28                in  varchar2  default null
  ,p_epe_attribute29                in  varchar2  default null
  ,p_epe_attribute30                in  varchar2  default null
  ,p_approval_status_cd             in  varchar2  default null
  ,p_fonm_cvg_strt_dt               in  date      default null
  ,p_cryfwd_elig_dpnt_cd            in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_enrt_perd_id                   in  number    default null
  ,p_lee_rsn_id                     in  number    default null
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default null
  ,p_uom                            in  varchar2  default null
  ,p_acty_ref_perd_cd               in  varchar2  default null
  -- CWB changes.
  ,p_mode                           in  varchar2  default null
  )
is
  --
  l_proc varchar2(72) ;
  --
  -- Declare cursors and local variables
  --
  l_elig_per_elctbl_chc_id ben_elig_per_elctbl_chc.elig_per_elctbl_chc_id%TYPE;
  l_object_version_number  ben_elig_per_elctbl_chc.object_version_number%TYPE;
  l_pil_elctbl_chc_popl_id number;
  l_oiplip_id              number;
  --
  l_created_by             ben_elig_per_elctbl_chc.created_by%TYPE;
  l_creation_date          ben_elig_per_elctbl_chc.creation_date%TYPE;
  l_last_update_date       ben_elig_per_elctbl_chc.last_update_date%TYPE;
  l_last_updated_by        ben_elig_per_elctbl_chc.last_updated_by%TYPE;
  l_last_update_login      ben_elig_per_elctbl_chc.last_update_login%TYPE;
  l_elig_flag              varchar2(30);
  l_inelig_rsn_cd          varchar2(30);
  --
  l_sysdate                date;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'create_perf_ELIG_PER_ELC_CHC';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_perf_ELIG_PER_ELC_CHC;
  --
  -- Create or find ben_pil_elctbl_chc_popl
  --
  CreOrSel_pil_elctbl_chc_popl
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
    ,p_enrt_typ_cycl_cd       => p_enrt_typ_cycl_cd
    ,p_enrt_perd_end_dt       => p_enrt_perd_end_dt
    ,p_enrt_perd_strt_dt      => p_enrt_perd_strt_dt
    ,p_procg_end_dt           => p_procg_end_dt
    ,p_lee_rsn_id             => p_lee_rsn_id
    ,p_enrt_perd_id           => p_enrt_perd_id
    ,p_request_id             => p_request_id
    ,p_program_application_id => p_program_application_id
    ,p_program_id             => p_program_id
    ,p_program_update_date    => p_program_update_date
    ,p_ws_mgr_id              => p_ws_mgr_id
    ,p_assignment_id          => p_assignment_id
    --
    ,p_pil_elctbl_chc_popl_id => l_pil_elctbl_chc_popl_id
    ,p_oiplip_id              => l_oiplip_id
    );
  --
  -- Insert the row
  --
  --   Set the object version number for the insert
  --
  l_object_version_number := 1;
  --
  ben_epe_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- CWB Changes Start
  --
  l_elig_flag := p_elig_flag;
  if p_elctbl_flag = 'N' then
     --
     l_elig_flag := 'N';
     --
  end if;
  --
  l_inelig_rsn_cd := p_inelig_rsn_cd;
  if l_elig_flag = 'N' and p_inelig_rsn_cd is null then
     --
     l_inelig_rsn_cd := 'OTH'; -- Other
     --
  end if;
  --
  -- CWB : End
  --
  if g_debug then
    hr_utility.set_location('Insert EPE: '||l_proc, 5);
  end if;
  insert into ben_elig_per_elctbl_chc
  (	elig_per_elctbl_chc_id,
--	enrt_typ_cycl_cd,
	enrt_cvg_strt_dt_cd,
--	enrt_perd_end_dt,
--	enrt_perd_strt_dt,
	enrt_cvg_strt_dt_rl,
--	rt_strt_dt,
--	rt_strt_dt_rl,
--	rt_strt_dt_cd,
        ctfn_rqd_flag,
        pil_elctbl_chc_popl_id,
	roll_crs_flag,
	crntly_enrd_flag,
	dflt_flag,
	elctbl_flag,
	mndtry_flag,
        in_pndg_wkflow_flag,
--	dflt_enrt_dt,
	dpnt_cvg_strt_dt_cd,
	dpnt_cvg_strt_dt_rl,
	enrt_cvg_strt_dt,
	alws_dpnt_dsgn_flag,
	dpnt_dsgn_cd,
	ler_chg_dpnt_cvg_cd,
	erlst_deenrt_dt,
	procg_end_dt,
	comp_lvl_cd,
	pl_id,
	oipl_id,
	pgm_id,
	plip_id,
	ptip_id,
	pl_typ_id,
	oiplip_id,
	cmbn_plip_id,
	cmbn_ptip_id,
	cmbn_ptip_opt_id,
        assignment_id,
	spcl_rt_pl_id,
	spcl_rt_oipl_id,
	must_enrl_anthr_pl_id,
	interim_elig_per_elctbl_chc_id,
	prtt_enrt_rslt_id,
	bnft_prvdr_pool_id,
	per_in_ler_id,
	yr_perd_id,
	auto_enrt_flag,
	business_group_id,
        pl_ordr_num,
        plip_ordr_num,
        ptip_ordr_num,
        oipl_ordr_num,
        -- cwb
        comments,
        elig_flag,
        elig_ovrid_dt,
        elig_ovrid_person_id,
        inelig_rsn_cd,
        mgr_ovrid_dt,
        mgr_ovrid_person_id,
        ws_mgr_id,
        -- cwb
	epe_attribute_category,
	epe_attribute1,
	epe_attribute2,
	epe_attribute3,
	epe_attribute4,
	epe_attribute5,
	epe_attribute6,
	epe_attribute7,
	epe_attribute8,
	epe_attribute9,
	epe_attribute10,
	epe_attribute11,
	epe_attribute12,
	epe_attribute13,
	epe_attribute14,
	epe_attribute15,
	epe_attribute16,
	epe_attribute17,
	epe_attribute18,
	epe_attribute19,
	epe_attribute20,
	epe_attribute21,
	epe_attribute22,
	epe_attribute23,
	epe_attribute24,
	epe_attribute25,
	epe_attribute26,
	epe_attribute27,
	epe_attribute28,
	epe_attribute29,
	epe_attribute30,
	approval_status_cd,
        fonm_cvg_strt_dt,
        cryfwd_elig_dpnt_cd,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
       )
  Values
       (ben_elig_per_elctbl_chc_s.nextval,
--	p_enrt_typ_cycl_cd,
	p_enrt_cvg_strt_dt_cd,
--	p_enrt_perd_end_dt,
--	p_enrt_perd_strt_dt,
	p_enrt_cvg_strt_dt_rl,
--	p_rt_strt_dt,
--	p_rt_strt_dt_rl,
--	p_rt_strt_dt_cd,
        p_ctfn_rqd_flag,
        l_pil_elctbl_chc_popl_id,
	p_roll_crs_flag,
	p_crntly_enrd_flag,
	p_dflt_flag,
	p_elctbl_flag,
	p_mndtry_flag,
        p_in_pndg_wkflow_flag,
--	p_dflt_enrt_dt,
	p_dpnt_cvg_strt_dt_cd,
	p_dpnt_cvg_strt_dt_rl,
	p_enrt_cvg_strt_dt,
	p_alws_dpnt_dsgn_flag,
	p_dpnt_dsgn_cd,
	p_ler_chg_dpnt_cvg_cd,
	p_erlst_deenrt_dt,
	p_procg_end_dt,
	p_comp_lvl_cd,
	p_pl_id,
	p_oipl_id,
	p_pgm_id,
	p_plip_id,
	p_ptip_id,
	p_pl_typ_id,
	l_oiplip_id,
	p_cmbn_plip_id,
	p_cmbn_ptip_id,
	p_cmbn_ptip_opt_id,
        p_assignment_id,
	p_spcl_rt_pl_id,
	p_spcl_rt_oipl_id,
	p_must_enrl_anthr_pl_id,
	p_int_elig_per_elctbl_chc_id,
	p_prtt_enrt_rslt_id,
	p_bnft_prvdr_pool_id,
	p_per_in_ler_id,
	p_yr_perd_id,
	p_auto_enrt_flag,
	p_business_group_id,
        p_pl_ordr_num,
        p_plip_ordr_num,
        p_ptip_ordr_num,
        p_oipl_ordr_num,
        -- cwb
        p_comments,
        l_elig_flag,
        p_elig_ovrid_dt,
        p_elig_ovrid_person_id,
        l_inelig_rsn_cd,
        p_mgr_ovrid_dt,
        p_mgr_ovrid_person_id,
        p_ws_mgr_id,
        -- cwb
	p_epe_attribute_category,
	p_epe_attribute1,
	p_epe_attribute2,
	p_epe_attribute3,
	p_epe_attribute4,
	p_epe_attribute5,
	p_epe_attribute6,
	p_epe_attribute7,
	p_epe_attribute8,
	p_epe_attribute9,
	p_epe_attribute10,
	p_epe_attribute11,
	p_epe_attribute12,
	p_epe_attribute13,
	p_epe_attribute14,
	p_epe_attribute15,
	p_epe_attribute16,
	p_epe_attribute17,
	p_epe_attribute18,
	p_epe_attribute19,
	p_epe_attribute20,
	p_epe_attribute21,
	p_epe_attribute22,
	p_epe_attribute23,
	p_epe_attribute24,
	p_epe_attribute25,
	p_epe_attribute26,
	p_epe_attribute27,
	p_epe_attribute28,
	p_epe_attribute29,
	p_epe_attribute30,
	p_approval_status_cd,
        p_fonm_cvg_strt_dt,
        p_cryfwd_elig_dpnt_cd,
	p_request_id,
	p_program_application_id,
	p_program_id,
	p_program_update_date,
	l_object_version_number
  ) RETURNING elig_per_elctbl_chc_id into l_elig_per_elctbl_chc_id;
  if g_debug then
    hr_utility.set_location('Dn Insert: '||l_proc, 5);
  end if;
  --
  ben_epe_shd.g_api_dml := false;   -- Unset the api dml status
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set electable choice current row globals
  --
  -- Check if bendenrr is being called recursively to create the parent EPE
  -- for the oipl. We do not want to modify the current EPE values if creating
  -- the parent plan EPE for an oipl EPE.
  --
  -- CWB Chnages :
  -- Do not call the caching code if called from CWB benmngle mode
  --
  if nvl(p_mode, 'OAB') <> 'W' then
     --
     if nvl(ben_epe_cache.g_currcobjepe_row.pl_id,hr_api.g_number) = nvl(p_pl_id,hr_api.g_number)
        and nvl(ben_epe_cache.g_currcobjepe_row.plip_id,hr_api.g_number) = nvl(p_plip_id,hr_api.g_number)
        and ben_epe_cache.g_currcobjepe_row.oipl_id is not null
        and p_oipl_id is null
      then
        --
        null;
        --
      else
        --
        -- BENCVRGE
        --
        ben_epe_cache.g_currcobjepe_row.elig_per_elctbl_chc_id := l_elig_per_elctbl_chc_id;
        ben_epe_cache.g_currcobjepe_row.pl_id                  := p_pl_id;
        ben_epe_cache.g_currcobjepe_row.plip_id                := p_plip_id;
        ben_epe_cache.g_currcobjepe_row.oipl_id                := p_oipl_id;
        --
        -- BENDEPEN
        --
        ben_epe_cache.g_currcobjepe_row.elctbl_flag            := p_elctbl_flag;
        ben_epe_cache.g_currcobjepe_row.per_in_ler_id          := p_per_in_ler_id;
        ben_epe_cache.g_currcobjepe_row.business_group_id      := p_business_group_id;
        ben_epe_cache.g_currcobjepe_row.object_version_number  := l_object_version_number;
        --
        -- BENCHCTF
        --
        ben_epe_cache.g_currcobjepe_row.comp_lvl_cd            := p_comp_lvl_cd;
        ben_epe_cache.g_currcobjepe_row.pgm_id                 := p_pgm_id;
        ben_epe_cache.g_currcobjepe_row.pl_typ_id              := p_pl_typ_id;
        ben_epe_cache.g_currcobjepe_row.ctfn_rqd_flag          := p_ctfn_rqd_flag;
        --
    end if;
    --
  end if;
  --
  -- Set all output arguments
  --
  p_elig_per_elctbl_chc_id := l_elig_per_elctbl_chc_id;
  p_object_version_number  := l_object_version_number;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 99);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_perf_ELIG_PER_ELC_CHC;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_per_elctbl_chc_id := null;
    p_object_version_number  := null;
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_elig_per_elctbl_chc_id := null;
    p_object_version_number  := null;
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
    ROLLBACK TO create_perf_ELIG_PER_ELC_CHC;
    raise;
    --
end create_perf_ELIG_PER_ELC_CHC;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELIG_PER_ELC_CHC >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_PER_ELC_CHC
  (p_validate                       in  boolean   default false
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_enrt_typ_cycl_cd               in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_end_dt               in  date      default hr_api.g_date
  ,p_enrt_perd_strt_dt              in  date      default hr_api.g_date
  ,p_enrt_cvg_strt_dt_rl            in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_pil_elctbl_chc_popl_id         in  number    default hr_api.g_number
  ,p_roll_crs_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_crntly_enrd_flag               in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_elctbl_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_mndtry_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_in_pndg_wkflow_flag            in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_dt                   in  date      default hr_api.g_date
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_rl            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_alws_dpnt_dsgn_flag            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_ler_chg_dpnt_cvg_cd            in  varchar2  default hr_api.g_varchar2
  ,p_erlst_deenrt_dt                in  date      default hr_api.g_date
  ,p_procg_end_dt                   in  date      default hr_api.g_date
  ,p_comp_lvl_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_oiplip_id                      in  number    default hr_api.g_number
  ,p_cmbn_plip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id               in  number    default hr_api.g_number
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_spcl_rt_pl_id                  in  number    default hr_api.g_number
  ,p_spcl_rt_oipl_id                in  number    default hr_api.g_number
  ,p_must_enrl_anthr_pl_id          in  number    default hr_api.g_number
  ,p_int_elig_per_elctbl_chc_id in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id             in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_yr_perd_id                     in  number    default hr_api.g_number
  ,p_auto_enrt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_ordr_num                    in  number    default hr_api.g_number
  ,p_plip_ordr_num                    in  number    default hr_api.g_number
  ,p_ptip_ordr_num                    in  number    default hr_api.g_number
  ,p_oipl_ordr_num                    in  number    default hr_api.g_number
  -- cwb
  ,p_comments                        in  varchar2       default hr_api.g_varchar2
  ,p_elig_flag                       in  varchar2       default hr_api.g_varchar2
  ,p_elig_ovrid_dt                   in  date           default hr_api.g_date
  ,p_elig_ovrid_person_id            in  number         default hr_api.g_number
  ,p_inelig_rsn_cd                   in  varchar2       default hr_api.g_varchar2
  ,p_mgr_ovrid_dt                    in  date           default hr_api.g_date
  ,p_mgr_ovrid_person_id             in  number         default hr_api.g_number
  ,p_ws_mgr_id                       in  number         default hr_api.g_number
  -- cwb
  ,p_epe_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_approval_status_cd           in  varchar2  default hr_api.g_varchar2
  ,p_fonm_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_cryfwd_elig_dpnt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ;
  l_object_version_number ben_elig_per_elctbl_chc.object_version_number%TYPE;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'update_ELIG_PER_ELC_CHC';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ELIG_PER_ELC_CHC;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ELIG_PER_ELC_CHC
    --
    ben_ELIG_PER_ELC_CHC_bk2.update_ELIG_PER_ELC_CHC_b
      (
       p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_ctfn_rqd_flag                  =>  p_ctfn_rqd_flag
      ,p_pil_elctbl_chc_popl_id         =>  p_pil_elctbl_chc_popl_id
      ,p_roll_crs_flag                  =>  p_roll_crs_flag
      ,p_crntly_enrd_flag               =>  p_crntly_enrd_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_elctbl_flag                    =>  p_elctbl_flag
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_in_pndg_wkflow_flag            =>  p_in_pndg_wkflow_flag
      ,p_dpnt_cvg_strt_dt_cd            =>  p_dpnt_cvg_strt_dt_cd
      ,p_dpnt_cvg_strt_dt_rl            =>  p_dpnt_cvg_strt_dt_rl
      ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
      ,p_alws_dpnt_dsgn_flag            =>  p_alws_dpnt_dsgn_flag
      ,p_dpnt_dsgn_cd                   =>  p_dpnt_dsgn_cd
      ,p_ler_chg_dpnt_cvg_cd            =>  p_ler_chg_dpnt_cvg_cd
      ,p_erlst_deenrt_dt                =>  p_erlst_deenrt_dt
      ,p_procg_end_dt                   =>  p_procg_end_dt
      ,p_comp_lvl_cd                    =>  p_comp_lvl_cd
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_plip_id                        =>  p_plip_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_oiplip_id                      =>  p_oiplip_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_cmbn_ptip_id                   =>  p_cmbn_ptip_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_assignment_id                  =>  p_assignment_id
      ,p_spcl_rt_pl_id                  =>  p_spcl_rt_pl_id
      ,p_spcl_rt_oipl_id                =>  p_spcl_rt_oipl_id
      ,p_must_enrl_anthr_pl_id          =>  p_must_enrl_anthr_pl_id
      ,p_int_elig_per_elctbl_chc_id =>  p_int_elig_per_elctbl_chc_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_auto_enrt_flag                 =>  p_auto_enrt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_ordr_num                    =>  p_pl_ordr_num
      ,p_plip_ordr_num                  =>  p_plip_ordr_num
      ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
      ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
      --cwb
      ,p_comments                      => p_comments
      ,p_elig_flag                     => p_elig_flag
      ,p_elig_ovrid_dt                 => p_elig_ovrid_dt
      ,p_elig_ovrid_person_id          => p_elig_ovrid_person_id
      ,p_inelig_rsn_cd                 => p_inelig_rsn_cd
      ,p_mgr_ovrid_dt                  => p_mgr_ovrid_dt
      ,p_mgr_ovrid_person_id           => p_mgr_ovrid_person_id
      ,p_ws_mgr_id                     => p_ws_mgr_id
      --cwb
      ,p_epe_attribute_category         =>  p_epe_attribute_category
      ,p_epe_attribute1                 =>  p_epe_attribute1
      ,p_epe_attribute2                 =>  p_epe_attribute2
      ,p_epe_attribute3                 =>  p_epe_attribute3
      ,p_epe_attribute4                 =>  p_epe_attribute4
      ,p_epe_attribute5                 =>  p_epe_attribute5
      ,p_epe_attribute6                 =>  p_epe_attribute6
      ,p_epe_attribute7                 =>  p_epe_attribute7
      ,p_epe_attribute8                 =>  p_epe_attribute8
      ,p_epe_attribute9                 =>  p_epe_attribute9
      ,p_epe_attribute10                =>  p_epe_attribute10
      ,p_epe_attribute11                =>  p_epe_attribute11
      ,p_epe_attribute12                =>  p_epe_attribute12
      ,p_epe_attribute13                =>  p_epe_attribute13
      ,p_epe_attribute14                =>  p_epe_attribute14
      ,p_epe_attribute15                =>  p_epe_attribute15
      ,p_epe_attribute16                =>  p_epe_attribute16
      ,p_epe_attribute17                =>  p_epe_attribute17
      ,p_epe_attribute18                =>  p_epe_attribute18
      ,p_epe_attribute19                =>  p_epe_attribute19
      ,p_epe_attribute20                =>  p_epe_attribute20
      ,p_epe_attribute21                =>  p_epe_attribute21
      ,p_epe_attribute22                =>  p_epe_attribute22
      ,p_epe_attribute23                =>  p_epe_attribute23
      ,p_epe_attribute24                =>  p_epe_attribute24
      ,p_epe_attribute25                =>  p_epe_attribute25
      ,p_epe_attribute26                =>  p_epe_attribute26
      ,p_epe_attribute27                =>  p_epe_attribute27
      ,p_epe_attribute28                =>  p_epe_attribute28
      ,p_epe_attribute29                =>  p_epe_attribute29
      ,p_epe_attribute30                =>  p_epe_attribute30
      ,p_approval_status_cd           =>  p_approval_status_cd
      ,p_fonm_cvg_strt_dt               =>  p_fonm_cvg_strt_dt
      ,p_cryfwd_elig_dpnt_cd            =>  p_cryfwd_elig_dpnt_cd
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIG_PER_ELC_CHC'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ELIG_PER_ELC_CHC
    --
  end;
  --
  if g_debug then
    hr_utility.set_location(' EPE Upd'|| l_proc, 10);
  end if;
  ben_epe_upd.upd
    (
     p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
    ,p_enrt_cvg_strt_dt_cd           => p_enrt_cvg_strt_dt_cd
    ,p_enrt_cvg_strt_dt_rl           => p_enrt_cvg_strt_dt_rl
    ,p_ctfn_rqd_flag                 => p_ctfn_rqd_flag
    ,p_pil_elctbl_chc_popl_id        => p_pil_elctbl_chc_popl_id
    ,p_roll_crs_flag                 => p_roll_crs_flag
    ,p_crntly_enrd_flag              => p_crntly_enrd_flag
    ,p_dflt_flag                     => p_dflt_flag
    ,p_elctbl_flag                   => p_elctbl_flag
    ,p_mndtry_flag                   => p_mndtry_flag
    ,p_in_pndg_wkflow_flag           => p_in_pndg_wkflow_flag
    ,p_dpnt_cvg_strt_dt_cd           => p_dpnt_cvg_strt_dt_cd
    ,p_dpnt_cvg_strt_dt_rl           => p_dpnt_cvg_strt_dt_rl
    ,p_enrt_cvg_strt_dt              => p_enrt_cvg_strt_dt
    ,p_alws_dpnt_dsgn_flag           => p_alws_dpnt_dsgn_flag
    ,p_dpnt_dsgn_cd                  => p_dpnt_dsgn_cd
    ,p_ler_chg_dpnt_cvg_cd           => p_ler_chg_dpnt_cvg_cd
    ,p_erlst_deenrt_dt               => p_erlst_deenrt_dt
    ,p_procg_end_dt                  => p_procg_end_dt
    ,p_comp_lvl_cd                   => p_comp_lvl_cd
    ,p_pl_id                         => p_pl_id
    ,p_oipl_id                       => p_oipl_id
    ,p_pgm_id                        => p_pgm_id
    ,p_plip_id                       => p_plip_id
    ,p_ptip_id                       => p_ptip_id
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_oiplip_id                      =>  p_oiplip_id
    ,p_cmbn_plip_id                  => p_cmbn_plip_id
    ,p_cmbn_ptip_id                  => p_cmbn_ptip_id
    ,p_cmbn_ptip_opt_id              => p_cmbn_ptip_opt_id
    ,p_assignment_id                 => p_assignment_id
    ,p_spcl_rt_pl_id                 => p_spcl_rt_pl_id
    ,p_spcl_rt_oipl_id               => p_spcl_rt_oipl_id
    ,p_must_enrl_anthr_pl_id         => p_must_enrl_anthr_pl_id
    ,p_int_elig_per_elctbl_chc_id => p_int_elig_per_elctbl_chc_id
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_bnft_prvdr_pool_id            => p_bnft_prvdr_pool_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_yr_perd_id                    => p_yr_perd_id
    ,p_auto_enrt_flag                => p_auto_enrt_flag
    ,p_business_group_id             => p_business_group_id
    ,p_pl_ordr_num                    =>  p_pl_ordr_num
    ,p_plip_ordr_num                  =>  p_plip_ordr_num
    ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
    ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
      --cwb
      ,p_comments                      => p_comments
      ,p_elig_flag                     => p_elig_flag
      ,p_elig_ovrid_dt                 => p_elig_ovrid_dt
      ,p_elig_ovrid_person_id          => p_elig_ovrid_person_id
      ,p_inelig_rsn_cd                 => p_inelig_rsn_cd
      ,p_mgr_ovrid_dt                  => p_mgr_ovrid_dt
      ,p_mgr_ovrid_person_id           => p_mgr_ovrid_person_id
      ,p_ws_mgr_id                     => p_ws_mgr_id
      --cwb
    ,p_epe_attribute_category        => p_epe_attribute_category
    ,p_epe_attribute1                => p_epe_attribute1
    ,p_epe_attribute2                => p_epe_attribute2
    ,p_epe_attribute3                => p_epe_attribute3
    ,p_epe_attribute4                => p_epe_attribute4
    ,p_epe_attribute5                => p_epe_attribute5
    ,p_epe_attribute6                => p_epe_attribute6
    ,p_epe_attribute7                => p_epe_attribute7
    ,p_epe_attribute8                => p_epe_attribute8
    ,p_epe_attribute9                => p_epe_attribute9
    ,p_epe_attribute10               => p_epe_attribute10
    ,p_epe_attribute11               => p_epe_attribute11
    ,p_epe_attribute12               => p_epe_attribute12
    ,p_epe_attribute13               => p_epe_attribute13
    ,p_epe_attribute14               => p_epe_attribute14
    ,p_epe_attribute15               => p_epe_attribute15
    ,p_epe_attribute16               => p_epe_attribute16
    ,p_epe_attribute17               => p_epe_attribute17
    ,p_epe_attribute18               => p_epe_attribute18
    ,p_epe_attribute19               => p_epe_attribute19
    ,p_epe_attribute20               => p_epe_attribute20
    ,p_epe_attribute21               => p_epe_attribute21
    ,p_epe_attribute22               => p_epe_attribute22
    ,p_epe_attribute23               => p_epe_attribute23
    ,p_epe_attribute24               => p_epe_attribute24
    ,p_epe_attribute25               => p_epe_attribute25
    ,p_epe_attribute26               => p_epe_attribute26
    ,p_epe_attribute27               => p_epe_attribute27
    ,p_epe_attribute28               => p_epe_attribute28
    ,p_epe_attribute29               => p_epe_attribute29
    ,p_epe_attribute30               => p_epe_attribute30
    ,p_approval_status_cd          => p_approval_status_cd
    ,p_fonm_cvg_strt_dt              => p_fonm_cvg_strt_dt
    ,p_cryfwd_elig_dpnt_cd           => p_cryfwd_elig_dpnt_cd
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  if g_debug then
    hr_utility.set_location(' Dn EPE Upd'|| l_proc, 10);
  end if;
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ELIG_PER_ELC_CHC
    --
    ben_ELIG_PER_ELC_CHC_bk2.update_ELIG_PER_ELC_CHC_a
      (
       p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_ctfn_rqd_flag                  =>  p_ctfn_rqd_flag
      ,p_pil_elctbl_chc_popl_id         =>  p_pil_elctbl_chc_popl_id
      ,p_roll_crs_flag                  =>  p_roll_crs_flag
      ,p_crntly_enrd_flag               =>  p_crntly_enrd_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_elctbl_flag                    =>  p_elctbl_flag
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_in_pndg_wkflow_flag            =>  p_in_pndg_wkflow_flag
      ,p_dpnt_cvg_strt_dt_cd            =>  p_dpnt_cvg_strt_dt_cd
      ,p_dpnt_cvg_strt_dt_rl            =>  p_dpnt_cvg_strt_dt_rl
      ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
      ,p_alws_dpnt_dsgn_flag            =>  p_alws_dpnt_dsgn_flag
      ,p_dpnt_dsgn_cd                   =>  p_dpnt_dsgn_cd
      ,p_ler_chg_dpnt_cvg_cd            =>  p_ler_chg_dpnt_cvg_cd
      ,p_erlst_deenrt_dt                =>  p_erlst_deenrt_dt
      ,p_procg_end_dt                   =>  p_procg_end_dt
      ,p_comp_lvl_cd                    =>  p_comp_lvl_cd
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_plip_id                        =>  p_plip_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_oiplip_id                      =>  p_oiplip_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_cmbn_ptip_id                   =>  p_cmbn_ptip_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_assignment_id                  =>  p_assignment_id
      ,p_spcl_rt_pl_id                  =>  p_spcl_rt_pl_id
      ,p_spcl_rt_oipl_id                =>  p_spcl_rt_oipl_id
      ,p_must_enrl_anthr_pl_id          =>  p_must_enrl_anthr_pl_id
      ,p_int_elig_per_elctbl_chc_id =>  p_int_elig_per_elctbl_chc_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_auto_enrt_flag                 =>  p_auto_enrt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_ordr_num                    =>  p_pl_ordr_num
      ,p_plip_ordr_num                  =>  p_plip_ordr_num
      ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
      ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
      --cwb
      ,p_comments                      => p_comments
      ,p_elig_flag                     => p_elig_flag
      ,p_elig_ovrid_dt                 => p_elig_ovrid_dt
      ,p_elig_ovrid_person_id          => p_elig_ovrid_person_id
      ,p_inelig_rsn_cd                 => p_inelig_rsn_cd
      ,p_mgr_ovrid_dt                  => p_mgr_ovrid_dt
      ,p_mgr_ovrid_person_id           => p_mgr_ovrid_person_id
      ,p_ws_mgr_id                     => p_ws_mgr_id
      --cwb
      ,p_epe_attribute_category         =>  p_epe_attribute_category
      ,p_epe_attribute1                 =>  p_epe_attribute1
      ,p_epe_attribute2                 =>  p_epe_attribute2
      ,p_epe_attribute3                 =>  p_epe_attribute3
      ,p_epe_attribute4                 =>  p_epe_attribute4
      ,p_epe_attribute5                 =>  p_epe_attribute5
      ,p_epe_attribute6                 =>  p_epe_attribute6
      ,p_epe_attribute7                 =>  p_epe_attribute7
      ,p_epe_attribute8                 =>  p_epe_attribute8
      ,p_epe_attribute9                 =>  p_epe_attribute9
      ,p_epe_attribute10                =>  p_epe_attribute10
      ,p_epe_attribute11                =>  p_epe_attribute11
      ,p_epe_attribute12                =>  p_epe_attribute12
      ,p_epe_attribute13                =>  p_epe_attribute13
      ,p_epe_attribute14                =>  p_epe_attribute14
      ,p_epe_attribute15                =>  p_epe_attribute15
      ,p_epe_attribute16                =>  p_epe_attribute16
      ,p_epe_attribute17                =>  p_epe_attribute17
      ,p_epe_attribute18                =>  p_epe_attribute18
      ,p_epe_attribute19                =>  p_epe_attribute19
      ,p_epe_attribute20                =>  p_epe_attribute20
      ,p_epe_attribute21                =>  p_epe_attribute21
      ,p_epe_attribute22                =>  p_epe_attribute22
      ,p_epe_attribute23                =>  p_epe_attribute23
      ,p_epe_attribute24                =>  p_epe_attribute24
      ,p_epe_attribute25                =>  p_epe_attribute25
      ,p_epe_attribute26                =>  p_epe_attribute26
      ,p_epe_attribute27                =>  p_epe_attribute27
      ,p_epe_attribute28                =>  p_epe_attribute28
      ,p_epe_attribute29                =>  p_epe_attribute29
      ,p_epe_attribute30                =>  p_epe_attribute30
      ,p_approval_status_cd           =>  p_approval_status_cd
      ,p_fonm_cvg_strt_dt               =>  p_fonm_cvg_strt_dt
      ,p_cryfwd_elig_dpnt_cd            =>  p_cryfwd_elig_dpnt_cd
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIG_PER_ELC_CHC'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ELIG_PER_ELC_CHC
    --
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_ELIG_PER_ELC_CHC;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number  := l_object_version_number;
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
    ROLLBACK TO update_ELIG_PER_ELC_CHC;
    raise;
    --
end update_ELIG_PER_ELC_CHC;
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_valid_mgr >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_valid_mgr(
p_emp_epe_id number,
p_new_mgr_id number,
p_effective_date in date) is

   cursor c1 is
   select per1.full_name person1,
          per2.full_name person2
     from ben_cwb_mgr_hrchy cwb1,
          ben_elig_per_elctbl_chc epe1,
          ben_per_in_ler pil1,
          per_all_people_f per1,
          per_all_people_f per2
    where cwb1.mgr_elig_per_elctbl_chc_id = p_emp_epe_id
      and cwb1.lvl_num > 0
      and epe1.elig_per_elctbl_chc_id = cwb1.mgr_elig_per_elctbl_chc_id
      and pil1.per_in_ler_id = epe1.per_in_ler_id
      and per1.person_id = pil1.person_id
      and trunc(sysdate) between per1.effective_start_date
      and per1.effective_end_date
      and per2.person_id = p_new_mgr_id
      and trunc(sysdate) between per2.effective_start_date
      and per2.effective_end_date
      and exists
      ( select 'x'
          from ben_elig_per_elctbl_chc epe2,
               ben_per_in_ler pil2
         where pil2.person_id = p_new_mgr_id
           and pil2.lf_evt_ocrd_dt = pil1.lf_evt_ocrd_dt
           and pil2.ler_id = pil1.ler_id
           and epe2.per_in_ler_id = pil2.per_in_ler_id
           and epe2.pl_id = epe1.pl_id
           and epe2.elig_per_elctbl_chc_id = cwb1.emp_elig_per_elctbl_chc_id);

   l_person1 per_all_people_f.full_name%type;
   l_person2 per_all_people_f.full_name%type;
   l_proc varchar2(72) ;

begin

   if g_debug then
     l_proc := g_package||'chk_valid_mgr';
     hr_utility.set_location(' Entering:'||l_proc, 10);
   end if;

   open c1;
   fetch c1 into l_person1,l_person2;
   if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_93251_CWB_CANNOT_REASSIGN');
      fnd_message.set_token('PERSON1', l_person1);
      fnd_message.set_token('PERSON2', l_person2);
      fnd_message.raise_error;
   end if;
   close c1;

   if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 20);
   end if;
end;
-- ----------------------------------------------------------------------------
-- |--------------------< update_perf_ELIG_PER_ELC_CHC >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_perf_ELIG_PER_ELC_CHC
  (p_validate                       in boolean    default false
  ,p_elig_per_elctbl_chc_id         in  number
  -- ,p_enrt_typ_cycl_cd               in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  --,p_enrt_perd_end_dt               in  date      default hr_api.g_date
  --,p_enrt_perd_strt_dt              in  date      default hr_api.g_date
  ,p_enrt_cvg_strt_dt_rl            in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_pil_elctbl_chc_popl_id         in  number    default hr_api.g_number
  ,p_roll_crs_flag             in  varchar2  default hr_api.g_varchar2
  ,p_crntly_enrd_flag               in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_elctbl_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_mndtry_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_in_pndg_wkflow_flag            in  varchar2  default hr_api.g_varchar2
  -- ,p_dflt_enrt_dt                   in  date      default hr_api.g_date
  ,p_dpnt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_rl            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_alws_dpnt_dsgn_flag            in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_ler_chg_dpnt_cvg_cd            in  varchar2  default hr_api.g_varchar2
  ,p_erlst_deenrt_dt                in  date      default hr_api.g_date
  ,p_procg_end_dt                   in  date      default hr_api.g_date
  ,p_comp_lvl_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_oiplip_id                      in  number    default hr_api.g_number
  ,p_cmbn_plip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id               in  number    default hr_api.g_number
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_spcl_rt_pl_id                  in  number    default hr_api.g_number
  ,p_spcl_rt_oipl_id                in  number    default hr_api.g_number
  ,p_must_enrl_anthr_pl_id          in  number    default hr_api.g_number
  ,p_int_elig_per_elctbl_chc_id          in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id             in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_yr_perd_id                     in  number    default hr_api.g_number
  ,p_auto_enrt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_ordr_num                    in  number    default hr_api.g_number
  ,p_plip_ordr_num                    in  number    default hr_api.g_number
  ,p_ptip_ordr_num                    in  number    default hr_api.g_number
  ,p_oipl_ordr_num                    in  number    default hr_api.g_number
  -- cwb
  ,p_comments                        in  varchar2       default hr_api.g_varchar2
  ,p_elig_flag                       in  varchar2       default hr_api.g_varchar2
  ,p_elig_ovrid_dt                   in  date           default hr_api.g_date
  ,p_elig_ovrid_person_id            in  number         default hr_api.g_number
  ,p_inelig_rsn_cd                   in  varchar2       default hr_api.g_varchar2
  ,p_mgr_ovrid_dt                    in  date           default hr_api.g_date
  ,p_mgr_ovrid_person_id             in  number         default hr_api.g_number
  ,p_ws_mgr_id                       in  number         default hr_api.g_number
  -- cwb
  ,p_epe_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_epe_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_approval_status_cd           in  varchar2  default hr_api.g_varchar2
  ,p_fonm_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_cryfwd_elig_dpnt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ;
  l_rec	                  ben_epe_shd.g_rec_type;
  l_object_version_number ben_elig_per_elctbl_chc.object_version_number%TYPE;
  l_elig_flag              varchar2(30);
  l_inelig_rsn_cd          varchar2(30);
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'update_perf_ELIG_PER_ELC_CHC';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_perf_ELIG_PER_ELC_CHC;
  --
  --
  -- CWB Changes : Start
  --
  l_elig_flag := p_elig_flag;
  if p_elctbl_flag = 'N' then
     --
     l_elig_flag := 'N';
     --
  end if;
  --
  l_inelig_rsn_cd := p_inelig_rsn_cd;
  if l_elig_flag = 'N' and p_inelig_rsn_cd is null then
     --
     l_inelig_rsn_cd := 'OTH'; -- Other
     --
  end if;

  --
  -- CWB Changes : End
  --
  l_rec :=
  ben_epe_shd.convert_args
  (
  p_elig_per_elctbl_chc_id,
-- p_enrt_typ_cycl_cd,
  p_enrt_cvg_strt_dt_cd,
--  p_enrt_perd_end_dt,
-- p_enrt_perd_strt_dt,
  p_enrt_cvg_strt_dt_rl,
--  p_rt_strt_dt,
--  p_rt_strt_dt_rl,
--  p_rt_strt_dt_cd,
  p_ctfn_rqd_flag,
  p_pil_elctbl_chc_popl_id,
  p_roll_crs_flag,
  p_crntly_enrd_flag,
  p_dflt_flag,
  p_elctbl_flag,
  p_mndtry_flag,
  p_in_pndg_wkflow_flag,
--  p_dflt_enrt_dt,
  p_dpnt_cvg_strt_dt_cd,
  p_dpnt_cvg_strt_dt_rl,
  p_enrt_cvg_strt_dt,
  p_alws_dpnt_dsgn_flag,
  p_dpnt_dsgn_cd,
  p_ler_chg_dpnt_cvg_cd,
  p_erlst_deenrt_dt,
  p_procg_end_dt,
  p_comp_lvl_cd,
  p_pl_id,
  p_oipl_id,
  p_pgm_id,
  p_plip_id,
  p_ptip_id,
  p_pl_typ_id,
  p_oiplip_id,
  p_cmbn_plip_id,
  p_cmbn_ptip_id,
  p_cmbn_ptip_opt_id,
  p_assignment_id,
  p_spcl_rt_pl_id,
  p_spcl_rt_oipl_id,
  p_must_enrl_anthr_pl_id,
  p_int_elig_per_elctbl_chc_id,
  p_prtt_enrt_rslt_id,
  p_bnft_prvdr_pool_id,
  p_per_in_ler_id,
  p_yr_perd_id,
  p_auto_enrt_flag,
  p_business_group_id,
  p_pl_ordr_num,
  p_plip_ordr_num,
  p_ptip_ordr_num,
  p_oipl_ordr_num,
  -- cwb
  p_comments,
  l_elig_flag,
  p_elig_ovrid_dt,
  p_elig_ovrid_person_id,
  l_inelig_rsn_cd,
  p_mgr_ovrid_dt,
  p_mgr_ovrid_person_id,
  p_ws_mgr_id,
  -- cwb
  p_epe_attribute_category,
  p_epe_attribute1,
  p_epe_attribute2,
  p_epe_attribute3,
  p_epe_attribute4,
  p_epe_attribute5,
  p_epe_attribute6,
  p_epe_attribute7,
  p_epe_attribute8,
  p_epe_attribute9,
  p_epe_attribute10,
  p_epe_attribute11,
  p_epe_attribute12,
  p_epe_attribute13,
  p_epe_attribute14,
  p_epe_attribute15,
  p_epe_attribute16,
  p_epe_attribute17,
  p_epe_attribute18,
  p_epe_attribute19,
  p_epe_attribute20,
  p_epe_attribute21,
  p_epe_attribute22,
  p_epe_attribute23,
  p_epe_attribute24,
  p_epe_attribute25,
  p_epe_attribute26,
  p_epe_attribute27,
  p_epe_attribute28,
  p_epe_attribute29,
  p_epe_attribute30,
  p_approval_status_cd,
  p_fonm_cvg_strt_dt,
  p_cryfwd_elig_dpnt_cd,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  null
  );

  --
  -- We must lock the row which we need to update.
  --
  ben_epe_shd.lck
    (p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
    ,p_object_version_number  => p_object_version_number
    );
  --
  ben_epe_upd.convert_defs(p_rec => l_rec);
  --
  --CWB
  -- Check only if the new manager is not null or defaulted.
  --
  if (nvl(p_ws_mgr_id, hr_api.g_number) <> hr_api.g_number) and
     (nvl(ben_epe_shd.g_old_rec.ws_mgr_id,-1) <> nvl(p_ws_mgr_id,-1))
  then
     chk_valid_mgr(p_elig_per_elctbl_chc_id,p_ws_mgr_id,p_effective_date);
  end if;
  --CWB
  --
  -- Increment object version number
  --
  l_object_version_number := p_object_version_number+1;
  --
  if g_debug then
    hr_utility.set_location(' EPE Upd'|| l_proc, 10);
  end if;
  ben_epe_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_elig_per_elctbl_chc Row
  --

  update ben_elig_per_elctbl_chc
  set
  elig_per_elctbl_chc_id            = l_rec.elig_per_elctbl_chc_id,
--  enrt_typ_cycl_cd                  = l_rec.enrt_typ_cycl_cd,
  enrt_cvg_strt_dt_cd               = l_rec.enrt_cvg_strt_dt_cd,
--  enrt_perd_end_dt                  = l_rec.enrt_perd_end_dt,
--  enrt_perd_strt_dt                 = l_rec.enrt_perd_strt_dt,
  enrt_cvg_strt_dt_rl               = l_rec.enrt_cvg_strt_dt_rl,
--  rt_strt_dt                        = l_rec.rt_strt_dt,
--  rt_strt_dt_rl                     = l_rec.rt_strt_dt_rl,
--  rt_strt_dt_cd                     = l_rec.rt_strt_dt_cd,
  ctfn_rqd_flag                     = l_rec.ctfn_rqd_flag,
  pil_elctbl_chc_popl_id            = l_rec.pil_elctbl_chc_popl_id,
  roll_crs_flag                = l_rec.roll_crs_flag,
  crntly_enrd_flag                  = l_rec.crntly_enrd_flag,
  dflt_flag                         = l_rec.dflt_flag,
  elctbl_flag                       = l_rec.elctbl_flag,
  mndtry_flag                       = l_rec.mndtry_flag,
  in_pndg_wkflow_flag               = l_rec.in_pndg_wkflow_flag,
--  dflt_enrt_dt                      = l_rec.dflt_enrt_dt,
  dpnt_cvg_strt_dt_cd               = l_rec.dpnt_cvg_strt_dt_cd,
  dpnt_cvg_strt_dt_rl               = l_rec.dpnt_cvg_strt_dt_rl,
  enrt_cvg_strt_dt                  = l_rec.enrt_cvg_strt_dt,
  alws_dpnt_dsgn_flag               = l_rec.alws_dpnt_dsgn_flag,
  dpnt_dsgn_cd                      = l_rec.dpnt_dsgn_cd,
  ler_chg_dpnt_cvg_cd               = l_rec.ler_chg_dpnt_cvg_cd,
  erlst_deenrt_dt                   = l_rec.erlst_deenrt_dt,
  procg_end_dt                      = l_rec.procg_end_dt,
  comp_lvl_cd                       = l_rec.comp_lvl_cd,
  pl_id                             = l_rec.pl_id,
  oipl_id                           = l_rec.oipl_id,
  pgm_id                            = l_rec.pgm_id,
  plip_id                           = l_rec.plip_id,
  ptip_id                           = l_rec.ptip_id,
  pl_typ_id                         = l_rec.pl_typ_id,
  oiplip_id                         = l_rec.oiplip_id,
  cmbn_plip_id                      = l_rec.cmbn_plip_id,
  cmbn_ptip_id                      = l_rec.cmbn_ptip_id,
  cmbn_ptip_opt_id                  = l_rec.cmbn_ptip_opt_id,
  spcl_rt_pl_id                     = l_rec.spcl_rt_pl_id,
  spcl_rt_oipl_id                   = l_rec.spcl_rt_oipl_id,
  must_enrl_anthr_pl_id             = l_rec.must_enrl_anthr_pl_id,
  interim_elig_per_elctbl_chc_id    = l_rec.int_elig_per_elctbl_chc_id,
  prtt_enrt_rslt_id                 = l_rec.prtt_enrt_rslt_id,
  bnft_prvdr_pool_id                = l_rec.bnft_prvdr_pool_id,
  per_in_ler_id                     = l_rec.per_in_ler_id,
  yr_perd_id                        = l_rec.yr_perd_id,
  auto_enrt_flag                    = l_rec.auto_enrt_flag,
  business_group_id                 = l_rec.business_group_id,
  pl_ordr_num                       = l_rec.pl_ordr_num,
  plip_ordr_num                     = l_rec.plip_ordr_num,
  ptip_ordr_num                       = l_rec.ptip_ordr_num,
  oipl_ordr_num                       = l_rec.oipl_ordr_num,
  -- cwb
  comments                          = l_rec.comments,
  elig_flag                         = l_rec.elig_flag,
  elig_ovrid_dt                     = l_rec.elig_ovrid_dt,
  elig_ovrid_person_id              = l_rec.elig_ovrid_person_id,
  inelig_rsn_cd                     = l_rec.inelig_rsn_cd,
  mgr_ovrid_dt                      = l_rec.mgr_ovrid_dt,
  mgr_ovrid_person_id               = l_rec.mgr_ovrid_person_id,
  ws_mgr_id                         = l_rec.ws_mgr_id,
  -- cwb
  epe_attribute_category            = l_rec.epe_attribute_category,
  epe_attribute1                    = l_rec.epe_attribute1,
  epe_attribute2                    = l_rec.epe_attribute2,
  epe_attribute3                    = l_rec.epe_attribute3,
  epe_attribute4                    = l_rec.epe_attribute4,
  epe_attribute5                    = l_rec.epe_attribute5,
  epe_attribute6                    = l_rec.epe_attribute6,
  epe_attribute7                    = l_rec.epe_attribute7,
  epe_attribute8                    = l_rec.epe_attribute8,
  epe_attribute9                    = l_rec.epe_attribute9,
  epe_attribute10                   = l_rec.epe_attribute10,
  epe_attribute11                   = l_rec.epe_attribute11,
  epe_attribute12                   = l_rec.epe_attribute12,
  epe_attribute13                   = l_rec.epe_attribute13,
  epe_attribute14                   = l_rec.epe_attribute14,
  epe_attribute15                   = l_rec.epe_attribute15,
  epe_attribute16                   = l_rec.epe_attribute16,
  epe_attribute17                   = l_rec.epe_attribute17,
  epe_attribute18                   = l_rec.epe_attribute18,
  epe_attribute19                   = l_rec.epe_attribute19,
  epe_attribute20                   = l_rec.epe_attribute20,
  epe_attribute21                   = l_rec.epe_attribute21,
  epe_attribute22                   = l_rec.epe_attribute22,
  epe_attribute23                   = l_rec.epe_attribute23,
  epe_attribute24                   = l_rec.epe_attribute24,
  epe_attribute25                   = l_rec.epe_attribute25,
  epe_attribute26                   = l_rec.epe_attribute26,
  epe_attribute27                   = l_rec.epe_attribute27,
  epe_attribute28                   = l_rec.epe_attribute28,
  epe_attribute29                   = l_rec.epe_attribute29,
  epe_attribute30                   = l_rec.epe_attribute30,
  approval_status_cd                   = l_rec.approval_status_cd,
  fonm_cvg_strt_dt                  = l_rec.fonm_cvg_strt_dt,
  cryfwd_elig_dpnt_cd               = l_rec.cryfwd_elig_dpnt_cd,
  request_id                        = l_rec.request_id,
  program_application_id            = l_rec.program_application_id,
  program_id                        = l_rec.program_id,
  program_update_date               = l_rec.program_update_date,
  object_version_number             = l_object_version_number
  where elig_per_elctbl_chc_id = l_rec.elig_per_elctbl_chc_id;
  --
  ben_epe_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
    hr_utility.set_location(' Dn EPE Upd'|| l_proc, 10);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set EPE comp object context values
  --
  if ben_epe_cache.g_currcobjepe_row.elig_per_elctbl_chc_id is not null then
    --
    -- BENDEPEN
    --
    ben_epe_cache.g_currcobjepe_row.alws_dpnt_dsgn_flag   := l_rec.alws_dpnt_dsgn_flag;
    ben_epe_cache.g_currcobjepe_row.object_version_number := l_object_version_number;
    ben_epe_cache.g_currcobjepe_row.dpnt_dsgn_cd          := l_rec.dpnt_dsgn_cd;
    ben_epe_cache.g_currcobjepe_row.ler_chg_dpnt_cvg_cd   := l_rec.ler_chg_dpnt_cvg_cd;
    ben_epe_cache.g_currcobjepe_row.dpnt_cvg_strt_dt_cd   := l_rec.dpnt_cvg_strt_dt_cd;
    ben_epe_cache.g_currcobjepe_row.dpnt_cvg_strt_dt_rl   := l_rec.dpnt_cvg_strt_dt_rl;
    --
    -- BENCHCTF
    --
    ben_epe_cache.g_currcobjepe_row.ctfn_rqd_flag := l_rec.ctfn_rqd_flag;
    --
    -- BENCVRGE
    --
    ben_epe_cache.g_currcobjepe_row.elctbl_flag := l_rec.elctbl_flag;
    ben_epe_cache.g_currcobjepe_row.dflt_flag   := l_rec.dflt_flag;
    --
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_perf_ELIG_PER_ELC_CHC;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number  := l_object_version_number;
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
    ROLLBACK TO update_perf_ELIG_PER_ELC_CHC;
    raise;
    --
end update_perf_ELIG_PER_ELC_CHC;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIG_PER_ELC_CHC >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_PER_ELC_CHC
  (p_validate                       in  boolean  default false
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ;
  l_object_version_number ben_elig_per_elctbl_chc.object_version_number%TYPE;

  cursor c_ctfn is
 /*   select ecc.elctbl_chc_ctfn_id,
           ecc.object_version_number
    from   ben_elctbl_chc_ctfn ecc
    where  elig_per_elctbl_chc_id in
          (select elig_per_elctbl_chc_id
          from ben_elig_per_elctbl_chc
          where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id)
       or enrt_bnft_id in
          (select enrt_bnft_id
          from ben_enrt_bnft
          where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id);*/

   select ecc.elctbl_chc_ctfn_id,
           ecc.object_version_number
    from   ben_elctbl_chc_ctfn ecc
    where  elig_per_elctbl_chc_id in
          (select elig_per_elctbl_chc_id
          from ben_elig_per_elctbl_chc
          where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id)
    UNION
      select ecc.elctbl_chc_ctfn_id,
           ecc.object_version_number
    from   ben_elctbl_chc_ctfn ecc
    where enrt_bnft_id in
          (select enrt_bnft_id
          from ben_enrt_bnft
          where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id);


  cursor c_rate is
/*    select ecr.enrt_rt_id,
           ecr.object_version_number
    from   ben_enrt_rt ecr
    where  elig_per_elctbl_chc_id in
          (select elig_per_elctbl_chc_id
          from ben_elig_per_elctbl_chc
          where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id)
       or enrt_bnft_id in
          (select enrt_bnft_id
          from ben_enrt_bnft
          where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id);
*/

select ecr.enrt_rt_id,
           ecr.object_version_number
    from   ben_enrt_rt ecr
    where  elig_per_elctbl_chc_id in
          (select elig_per_elctbl_chc_id
          from ben_elig_per_elctbl_chc
          where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id)
       UNION all
select ecr.enrt_rt_id,
           ecr.object_version_number
    from   ben_enrt_rt ecr
    where  enrt_bnft_id in
          (select enrt_bnft_id
          from ben_enrt_bnft
          where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id);


  cursor c_bnft is
    select enb.enrt_bnft_id,
           enb.object_version_number
    from   ben_enrt_bnft enb
    where  elig_per_elctbl_chc_id in
          (select elig_per_elctbl_chc_id
          from ben_elig_per_elctbl_chc
          where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id);

  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'update_ELIG_PER_ELC_CHC';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ELIG_PER_ELC_CHC;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_ELIG_PER_ELC_CHC
    --
    ben_ELIG_PER_ELC_CHC_bk3.delete_ELIG_PER_ELC_CHC_b
      (
       p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_PER_ELC_CHC'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ELIG_PER_ELC_CHC
    --
  end;
  --
  -- Delete all other related choice info:

  -- Choice Certification:
  for l_ctfn in c_ctfn loop
    null;  -- api does not exist yet!
    --  ben_elctbl_chc_ctfn_api.delete_elctbl_chc_ctfn
    --      (p_validate              => false,
    --       p_enrt_cvg_n_rt_ctfn_id => l_ctfn.enrt_cvg_n_rt_ctfn_id,
    --       p_object_version_number => l_ctfn.object_version_number,
    --       p_effective_date        => p_effective_date);
  end loop;

  -- Choice Rates:
  for l_rate in c_rate loop
      ben_enrollment_rate_api.delete_enrollment_rate
          (p_validate              => false,
           p_enrt_rt_id            => l_rate.enrt_rt_id,
           p_object_version_number => l_rate.object_version_number,
           p_effective_date        => p_effective_date);
  end loop;

  -- Choice Benefits:
  for l_bnft in c_bnft loop
      ben_enrt_bnft_api.delete_enrt_bnft
          (p_validate              => false,
           p_enrt_bnft_id          => l_bnft.enrt_bnft_id,
           p_object_version_number => l_bnft.object_version_number,
           p_effective_date        => p_effective_date);
  end loop;

  -- Delete the choice:
  --
  ben_epe_del.del
    (
     p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ELIG_PER_ELC_CHC
    --
    ben_ELIG_PER_ELC_CHC_bk3.delete_ELIG_PER_ELC_CHC_a
      (
       p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_PER_ELC_CHC'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ELIG_PER_ELC_CHC
    --
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_ELIG_PER_ELC_CHC;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number  := l_object_version_number;
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
    ROLLBACK TO delete_ELIG_PER_ELC_CHC;
    raise;
    --
end delete_ELIG_PER_ELC_CHC;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_elig_per_elctbl_chc_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'lck';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  ben_epe_shd.lck
    (
      p_elig_per_elctbl_chc_id                 => p_elig_per_elctbl_chc_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
end lck;
--
end ben_elig_per_elc_chc_api;

/
