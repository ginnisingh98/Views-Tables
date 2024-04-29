--------------------------------------------------------
--  DDL for Package Body BEN_PRTT_PREM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRTT_PREM_API" as
/* $Header: beppeapi.pkb 120.1.12010000.2 2008/08/05 15:16:09 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PRTT_PREM_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< recalc_PRTT_PREM >----------------------|
-- ----------------------------------------------------------------------------
--
procedure recalc_PRTT_PREM
  (p_prtt_prem_id                   in  number default null
  ,p_std_prem_uom                   in  varchar2  default null
  ,p_std_prem_val                   in out nocopy number
  ,p_actl_prem_id                   in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_per_in_ler_id                  in  number
  ,p_ler_id                         in  number
  ,p_lf_evt_ocrd_dt                 in  date
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_enrt_bnft_id                   in  number
  ,p_business_group_id              in  number    default null
  -- bof FONM
  ,p_enrt_cvg_strt_dt               in  date    default null
  ,p_rt_strt_dt                     in  date    default null
 -- eof FONM
  ,p_effective_date                 in  date
  ) is

  l_proc varchar2(72) := g_package||'recalc_PRTT_PREM';
  --- FONM p_date param added
  cursor c_prtt_prem (p_date date ) is
    select ppe.std_prem_val, ppe.actl_prem_id, ppe.prtt_enrt_rslt_id
    from ben_prtt_prem_f ppe
    where ppe.prtt_prem_id = p_prtt_prem_id
    --and p_effective_date between
    and p_date between
        ppe.effective_start_date and ppe.effective_end_date;
  l_prtt_prem c_prtt_prem%rowtype;

  --- FONM p_date param added
  cursor c_actl_prem(p_actl_prem_id number , p_date date) is
    select apr.mlt_cd, apr.pl_id, apr.oipl_id, apr.bnft_rt_typ_cd, apr.val,
           apr.rndg_cd, apr.rndg_rl, apr.upr_lmt_val, apr.lwr_lmt_val,
           apr.upr_lmt_calc_rl, apr.lwr_lmt_calc_rl, prem_asnmt_cd, val_calc_rl
    from ben_actl_prem_f apr
    where apr.actl_prem_id = p_actl_prem_id
    --and p_effective_date between
    and p_date between
        apr.effective_start_date and apr.effective_end_date;
  l_actl_prem c_actl_prem%rowtype;

  --- FONM p_date param added
  cursor c_cvg(p_pl_id number, p_oipl_id number,p_date date ) is
    select ccm.entr_val_at_enrt_flag,
           ccm.cvg_mlt_cd
    from ben_cvg_amt_calc_mthd_f ccm
    where ((ccm.pl_id = p_pl_id and p_oipl_id is null)
    or (ccm.oipl_id = p_oipl_id and p_pl_id is null))
    --and p_effective_date between
    and p_date between
        ccm.effective_start_date and ccm.effective_end_date;
  l_cvg c_cvg%rowtype;

  cursor c_rslt(p_prtt_enrt_rslt_id number) is
    select pen.bnft_amt, pen.person_id,  pen.pgm_id,
           pen.pl_id, pen.oipl_id, pen.pl_typ_id, pen.per_in_ler_id, pen.ler_id,
           epe.elig_per_elctbl_chc_id, b.enrt_bnft_id, pen.business_group_id,
           b.entr_val_at_enrt_flag, b.cvg_mlt_cd
    from ben_prtt_enrt_rslt_f pen, ben_elig_per_elctbl_chc epe, ben_enrt_bnft b
    where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and   pen.prtt_enrt_rslt_id = epe.prtt_enrt_rslt_id
    and   b.elig_per_elctbl_chc_id(+) = epe.elig_per_elctbl_chc_id
    and   pen.prtt_enrt_rslt_stat_cd is null
--    and   (b.entr_val_at_enrt_flag = 'Y' or
--           b.cvg_mlt_cd = 'ERL')
    and p_effective_date between
        pen.effective_start_date and pen.effective_end_date;
  l_rslt c_rslt%rowtype;

  --- FONM p_date param added
  cursor c_opt(p_oipl_id in number,p_date date) is
    select oipl.opt_id
    from   ben_oipl_f oipl
    where  oipl.oipl_id = p_oipl_id
    --  and  p_effective_date between
      and  p_date between
             oipl.effective_start_date and oipl.effective_end_date;

  l_opt c_opt%rowtype;

  --
  cursor c_apv is
  select 'X'
    from ben_ACTL_PREM_VRBL_RT_f apv
   where apv.actl_prem_id = p_actl_prem_id
     and p_effective_date between apv.effective_start_date
                              and apv.effective_end_date;


/*  cursor c_pil is
    select pil.LF_EVT_OCRD_DT
    from ben_per_in_ler pil
    where pil.per_in_ler_id = p_per_in_ler_id;
  l_pil c_pil%rowtype;
*/

 l_variable_val number;
 l_vr_trtmt_cd  varchar2(80);
 l_dummy_number number;
 l_dummy_char   varchar2(80);
 l_fonm_eff_dt  date ;
 l_recalc_premium  boolean := FALSE; -- 5557305: All Logic w.r.t this param is added.
 -- bof FONM

 cursor c_epe  is
 select *
 from  ben_elig_per_elctbl_chc
 where elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id  ;
 l_epe_row c_epe%rowtype ;

 l_fonm_date  date        := nvl(p_enrt_cvg_strt_dt,p_lf_evt_ocrd_dt); -- prem created on cvg date so use first
 l_fonm_flag  varchar2(1) :=   ben_manage_life_events.fonm ;
 l_fonm_cvg_strt_dt   date ;
 l_fonm_rt_strt_dt    date ;

 -- eof FONM
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
   -- bof FONM
  if  l_fonm_flag  = 'Y'   then
      l_fonm_cvg_strt_dt :=  p_enrt_cvg_strt_dt ;
      l_fonm_rt_strt_dt := p_rt_strt_dt ;
      open c_epe ;
      fetch c_epe into l_epe_row  ;
      close c_epe ;
      if  l_epe_row.fonm_cvg_strt_dt is not null then
         l_fonm_cvg_strt_dt    := l_epe_row.fonm_cvg_strt_dt ;
      end if ;
      l_fonm_date := nvl(l_fonm_cvg_strt_dt,l_fonm_date ) ;
      l_fonm_eff_dt := l_fonm_date ;        -- this date for fonm fonm date or effective date to get opt
      --if p_rt_strt_dt not null then
      --end if ;
  else -- if called from enrollment process fonm_flag is null
    --
    open c_epe ;
    fetch c_epe into l_epe_row  ;
    close c_epe ;
    if  l_epe_row.fonm_cvg_strt_dt is not null then
       l_fonm_cvg_strt_dt    := l_epe_row.fonm_cvg_strt_dt ;
    end if ;
    l_fonm_date := nvl(l_fonm_cvg_strt_dt,l_fonm_date ) ;
    l_fonm_eff_dt := nvl(l_epe_row.fonm_cvg_strt_dt, p_effective_date ) ;
    --
  end if ;
  -- eof FONM
  hr_utility.set_location('effective_date:'|| p_effective_date, 10);
  hr_utility.set_location('p_lf_evt_ocrd_dt:'|| p_lf_evt_ocrd_dt, 10);
  hr_utility.set_location('p_enrt_cvg_strt_dt:'|| p_enrt_cvg_strt_dt, 10);
  hr_utility.set_location('l_fonm_date:'|| l_fonm_date, 10);
  hr_utility.set_location('l_fonm_eff_date:'|| l_fonm_eff_dt, 10);

  if p_std_prem_val is null or p_actl_prem_id is null or p_prtt_enrt_rslt_id is null
     then
     if p_prtt_prem_id is null then
        -- If we are calling this procedure prior to a create premium, we need all these
        -- parms passed in.
        fnd_message.set_name('BEN', 'BEN_91832_PACKAGE_PARAM_NULL');
        fnd_message.set_token('PACKAGE', l_proc);
        fnd_message.set_token('PARAM',
           'p_std_prem_val or p_actl_prem_id or p_prtt_enrt_rslt_id');
        fnd_message.raise_error;
     else
        --- fonm parameter added
        open c_prtt_prem(l_fonm_date);
        fetch c_prtt_prem into l_prtt_prem;
        if c_prtt_prem%NOTFOUND or c_prtt_prem%NOTFOUND is null then
           close c_prtt_prem;
           hr_utility.set_location('BEN_91563_BENVRBRT_APR_NF', 11);
           fnd_message.set_name('BEN', 'BEN_91563_BENVRBRT_APR_NF');
           fnd_message.raise_error;
        end if;
        close c_prtt_prem;
        p_std_prem_val := l_prtt_prem.std_prem_val;  -- output parm
     end if;
  else
     l_prtt_prem.actl_prem_id := p_actl_prem_id;
     l_prtt_prem.prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
  end if;
   --- fonm parameter added
  open c_actl_prem(l_prtt_prem.actl_prem_id,l_fonm_date );
  fetch c_actl_prem into l_actl_prem;
  if c_actl_prem%NOTFOUND or c_actl_prem%NOTFOUND is null then
     close c_actl_prem;
     hr_utility.set_location('BEN_91577_BENACPRM_APR_NF', 20);
     fnd_message.set_name('BEN', 'BEN_91577_BENACPRM_APR_NF');
     fnd_message.raise_error;
  end if;
  close c_actl_prem;

  -- If the premium is a multiple of coverage and that coverage value is
  -- entered at enrollment, we need to re-calc the premium value.
  --
    -- 5557305 : Recalculate 'Actual Premium' for all Modes,
    -- as there might be Variable Premiums. So, even if the 'actual premium'
    -- did not change, variable premium would have changed.
    --
  l_recalc_premium := FALSE;
  --
  if (l_actl_prem.mlt_cd = 'CVG' and l_actl_prem.prem_asnmt_cd = 'ENRT')
  then
     --- fonm parameter added
     open c_cvg(l_actl_prem.pl_id, l_actl_prem.oipl_id,l_fonm_date);
     fetch c_cvg into l_cvg;
     if c_cvg%NOTFOUND then
           close c_cvg;
           hr_utility.set_location('BEN_92494_COVERAGE_NF', 30);
           fnd_message.set_name('BEN', 'BEN_92492_COVERAGE_NF');
           fnd_message.set_token('ID', to_char(l_prtt_prem.actl_prem_id));
           fnd_message.raise_error;
     end if;
     close c_cvg;
     --
     if l_cvg.entr_val_at_enrt_flag = 'Y' or l_cvg.cvg_mlt_cd = 'ERL' then
           l_recalc_premium := true;
     end if;
  --
  end if;

  --
  if (not l_recalc_premium) then
    open c_apv;
    fetch c_apv into l_dummy_char;
    if c_apv%FOUND then
        l_recalc_premium := true;
    end if;
    close c_apv;
  end if;
    --
  if l_recalc_premium then
--         if l_cvg.entr_val_at_enrt_flag = 'Y' or l_cvg.cvg_mlt_cd = 'ERL' then
       open c_rslt(l_prtt_prem.prtt_enrt_rslt_id);
       fetch c_rslt into l_rslt;
       if c_rslt%NOTFOUND or c_rslt%NOTFOUND is null then
          close c_rslt;
          hr_utility.set_location('BEN_91711_ENRT_RSLT_NOT_FND', 11);
          fnd_message.set_name('BEN', 'BEN_91711_ENRT_RSLT_NOT_FND');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('ID', to_char(l_prtt_prem.prtt_enrt_rslt_id));
          fnd_message.set_token('PERSON_ID',null);
          fnd_message.set_token('LER_ID', to_char(p_ler_id));
          fnd_message.set_token('EFFECTIVE_DATE', to_char(p_effective_date));
          fnd_message.raise_error;
       end if;
       close c_rslt;
          --
       if l_rslt.oipl_id is not null then
          --- fonm parameter added
          open c_opt(l_rslt.oipl_id,l_fonm_eff_dt);
          fetch c_opt into l_opt;
          close c_opt;
       end if;
       -- re-calc the premium value
       BEN_DETERMINE_ACTUAL_PREMIUM.compute_premium
        (p_person_id              => l_rslt.person_id,
         p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
         p_effective_date         => p_effective_date,
         p_business_group_id      => l_rslt.business_group_id,
         p_per_in_ler_id          => p_per_in_ler_id,
         p_ler_id                 => p_ler_id,
         p_actl_prem_id           => l_prtt_prem.actl_prem_id,
         p_perform_rounding_flg   => TRUE,
         p_calc_only_rt_val_flag  => TRUE,
         p_pgm_id                 => l_rslt.pgm_id,
         p_pl_typ_id              => l_rslt.pl_typ_id,
         p_pl_id                  => l_rslt.pl_id,
         p_oipl_id                => l_rslt.oipl_id,
         p_opt_id                 => l_opt.opt_id,
         p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
         p_enrt_bnft_id           => p_enrt_bnft_id,
         p_bnft_amt               => l_rslt.bnft_amt,
         p_prem_val               => l_actl_prem.val,
         p_mlt_cd                 => l_actl_prem.mlt_cd,
         p_bnft_rt_typ_cd         => l_actl_prem.bnft_rt_typ_cd,
         p_val_calc_rl            => l_actl_prem.val_calc_rl,
         p_rndg_cd                => l_actl_prem.rndg_cd,
         p_rndg_rl                => l_actl_prem.rndg_rl,
         p_upr_lmt_val            => l_actl_prem.upr_lmt_val,
         p_lwr_lmt_val            => l_actl_prem.lwr_lmt_val,
         p_upr_lmt_calc_rl        => l_actl_prem.upr_lmt_calc_rl,
         p_lwr_lmt_calc_rl        => l_actl_prem.lwr_lmt_calc_rl,
         -- bof Fonm
         p_fonm_cvg_strt_dt       => l_fonm_cvg_strt_dt ,
         p_fonm_rt_strt_dt        => l_fonm_rt_strt_dt  ,
         -- eof FONM
         p_computed_val           => p_std_prem_val); -- output

   end if;
  --end if;
  hr_utility.set_location('p_std_prem_val:'||to_char(p_std_prem_val), 99);
  hr_utility.set_location('Leaving:'|| l_proc, 99);
end recalc_PRTT_PREM;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PRTT_PREM >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PRTT_PREM
  (p_validate                       in  boolean   default false
  ,p_prtt_prem_id                   out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_std_prem_uom                   in  varchar2  default null
  ,p_std_prem_val                   in  number    default null
  ,p_actl_prem_id                   in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_per_in_ler_id              in  number
  ,p_business_group_id              in  number    default null
  ,p_ppe_attribute_category         in  varchar2  default null
  ,p_ppe_attribute1                 in  varchar2  default null
  ,p_ppe_attribute2                 in  varchar2  default null
  ,p_ppe_attribute3                 in  varchar2  default null
  ,p_ppe_attribute4                 in  varchar2  default null
  ,p_ppe_attribute5                 in  varchar2  default null
  ,p_ppe_attribute6                 in  varchar2  default null
  ,p_ppe_attribute7                 in  varchar2  default null
  ,p_ppe_attribute8                 in  varchar2  default null
  ,p_ppe_attribute9                 in  varchar2  default null
  ,p_ppe_attribute10                in  varchar2  default null
  ,p_ppe_attribute11                in  varchar2  default null
  ,p_ppe_attribute12                in  varchar2  default null
  ,p_ppe_attribute13                in  varchar2  default null
  ,p_ppe_attribute14                in  varchar2  default null
  ,p_ppe_attribute15                in  varchar2  default null
  ,p_ppe_attribute16                in  varchar2  default null
  ,p_ppe_attribute17                in  varchar2  default null
  ,p_ppe_attribute18                in  varchar2  default null
  ,p_ppe_attribute19                in  varchar2  default null
  ,p_ppe_attribute20                in  varchar2  default null
  ,p_ppe_attribute21                in  varchar2  default null
  ,p_ppe_attribute22                in  varchar2  default null
  ,p_ppe_attribute23                in  varchar2  default null
  ,p_ppe_attribute24                in  varchar2  default null
  ,p_ppe_attribute25                in  varchar2  default null
  ,p_ppe_attribute26                in  varchar2  default null
  ,p_ppe_attribute27                in  varchar2  default null
  ,p_ppe_attribute28                in  varchar2  default null
  ,p_ppe_attribute29                in  varchar2  default null
  ,p_ppe_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_prtt_prem_id ben_prtt_prem_f.prtt_prem_id%TYPE;
  l_effective_start_date ben_prtt_prem_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_prem_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PRTT_PREM';
  l_object_version_number ben_prtt_prem_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PRTT_PREM;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PRTT_PREM
    --
    ben_PRTT_PREM_bk1.create_PRTT_PREM_b
      (
       p_std_prem_uom                   =>  p_std_prem_uom
      ,p_std_prem_val                   =>  p_std_prem_val
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id              =>  p_per_in_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ppe_attribute_category         =>  p_ppe_attribute_category
      ,p_ppe_attribute1                 =>  p_ppe_attribute1
      ,p_ppe_attribute2                 =>  p_ppe_attribute2
      ,p_ppe_attribute3                 =>  p_ppe_attribute3
      ,p_ppe_attribute4                 =>  p_ppe_attribute4
      ,p_ppe_attribute5                 =>  p_ppe_attribute5
      ,p_ppe_attribute6                 =>  p_ppe_attribute6
      ,p_ppe_attribute7                 =>  p_ppe_attribute7
      ,p_ppe_attribute8                 =>  p_ppe_attribute8
      ,p_ppe_attribute9                 =>  p_ppe_attribute9
      ,p_ppe_attribute10                =>  p_ppe_attribute10
      ,p_ppe_attribute11                =>  p_ppe_attribute11
      ,p_ppe_attribute12                =>  p_ppe_attribute12
      ,p_ppe_attribute13                =>  p_ppe_attribute13
      ,p_ppe_attribute14                =>  p_ppe_attribute14
      ,p_ppe_attribute15                =>  p_ppe_attribute15
      ,p_ppe_attribute16                =>  p_ppe_attribute16
      ,p_ppe_attribute17                =>  p_ppe_attribute17
      ,p_ppe_attribute18                =>  p_ppe_attribute18
      ,p_ppe_attribute19                =>  p_ppe_attribute19
      ,p_ppe_attribute20                =>  p_ppe_attribute20
      ,p_ppe_attribute21                =>  p_ppe_attribute21
      ,p_ppe_attribute22                =>  p_ppe_attribute22
      ,p_ppe_attribute23                =>  p_ppe_attribute23
      ,p_ppe_attribute24                =>  p_ppe_attribute24
      ,p_ppe_attribute25                =>  p_ppe_attribute25
      ,p_ppe_attribute26                =>  p_ppe_attribute26
      ,p_ppe_attribute27                =>  p_ppe_attribute27
      ,p_ppe_attribute28                =>  p_ppe_attribute28
      ,p_ppe_attribute29                =>  p_ppe_attribute29
      ,p_ppe_attribute30                =>  p_ppe_attribute30
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
         p_module_name => 'CREATE_PRTT_PREM'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PRTT_PREM
    --
  end;
  --
  ben_ppe_ins.ins
    (
     p_prtt_prem_id                  => l_prtt_prem_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_std_prem_uom                  => p_std_prem_uom
    ,p_std_prem_val                  => p_std_prem_val
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_per_in_ler_id             => p_per_in_ler_id
    ,p_business_group_id             => p_business_group_id
    ,p_ppe_attribute_category        => p_ppe_attribute_category
    ,p_ppe_attribute1                => p_ppe_attribute1
    ,p_ppe_attribute2                => p_ppe_attribute2
    ,p_ppe_attribute3                => p_ppe_attribute3
    ,p_ppe_attribute4                => p_ppe_attribute4
    ,p_ppe_attribute5                => p_ppe_attribute5
    ,p_ppe_attribute6                => p_ppe_attribute6
    ,p_ppe_attribute7                => p_ppe_attribute7
    ,p_ppe_attribute8                => p_ppe_attribute8
    ,p_ppe_attribute9                => p_ppe_attribute9
    ,p_ppe_attribute10               => p_ppe_attribute10
    ,p_ppe_attribute11               => p_ppe_attribute11
    ,p_ppe_attribute12               => p_ppe_attribute12
    ,p_ppe_attribute13               => p_ppe_attribute13
    ,p_ppe_attribute14               => p_ppe_attribute14
    ,p_ppe_attribute15               => p_ppe_attribute15
    ,p_ppe_attribute16               => p_ppe_attribute16
    ,p_ppe_attribute17               => p_ppe_attribute17
    ,p_ppe_attribute18               => p_ppe_attribute18
    ,p_ppe_attribute19               => p_ppe_attribute19
    ,p_ppe_attribute20               => p_ppe_attribute20
    ,p_ppe_attribute21               => p_ppe_attribute21
    ,p_ppe_attribute22               => p_ppe_attribute22
    ,p_ppe_attribute23               => p_ppe_attribute23
    ,p_ppe_attribute24               => p_ppe_attribute24
    ,p_ppe_attribute25               => p_ppe_attribute25
    ,p_ppe_attribute26               => p_ppe_attribute26
    ,p_ppe_attribute27               => p_ppe_attribute27
    ,p_ppe_attribute28               => p_ppe_attribute28
    ,p_ppe_attribute29               => p_ppe_attribute29
    ,p_ppe_attribute30               => p_ppe_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PRTT_PREM
    --
    ben_PRTT_PREM_bk1.create_PRTT_PREM_a
      (
       p_prtt_prem_id                   =>  l_prtt_prem_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_std_prem_uom                   =>  p_std_prem_uom
      ,p_std_prem_val                   =>  p_std_prem_val
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id              =>  p_per_in_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ppe_attribute_category         =>  p_ppe_attribute_category
      ,p_ppe_attribute1                 =>  p_ppe_attribute1
      ,p_ppe_attribute2                 =>  p_ppe_attribute2
      ,p_ppe_attribute3                 =>  p_ppe_attribute3
      ,p_ppe_attribute4                 =>  p_ppe_attribute4
      ,p_ppe_attribute5                 =>  p_ppe_attribute5
      ,p_ppe_attribute6                 =>  p_ppe_attribute6
      ,p_ppe_attribute7                 =>  p_ppe_attribute7
      ,p_ppe_attribute8                 =>  p_ppe_attribute8
      ,p_ppe_attribute9                 =>  p_ppe_attribute9
      ,p_ppe_attribute10                =>  p_ppe_attribute10
      ,p_ppe_attribute11                =>  p_ppe_attribute11
      ,p_ppe_attribute12                =>  p_ppe_attribute12
      ,p_ppe_attribute13                =>  p_ppe_attribute13
      ,p_ppe_attribute14                =>  p_ppe_attribute14
      ,p_ppe_attribute15                =>  p_ppe_attribute15
      ,p_ppe_attribute16                =>  p_ppe_attribute16
      ,p_ppe_attribute17                =>  p_ppe_attribute17
      ,p_ppe_attribute18                =>  p_ppe_attribute18
      ,p_ppe_attribute19                =>  p_ppe_attribute19
      ,p_ppe_attribute20                =>  p_ppe_attribute20
      ,p_ppe_attribute21                =>  p_ppe_attribute21
      ,p_ppe_attribute22                =>  p_ppe_attribute22
      ,p_ppe_attribute23                =>  p_ppe_attribute23
      ,p_ppe_attribute24                =>  p_ppe_attribute24
      ,p_ppe_attribute25                =>  p_ppe_attribute25
      ,p_ppe_attribute26                =>  p_ppe_attribute26
      ,p_ppe_attribute27                =>  p_ppe_attribute27
      ,p_ppe_attribute28                =>  p_ppe_attribute28
      ,p_ppe_attribute29                =>  p_ppe_attribute29
      ,p_ppe_attribute30                =>  p_ppe_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PRTT_PREM'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PRTT_PREM
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_prtt_prem_id := l_prtt_prem_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_PRTT_PREM;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtt_prem_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PRTT_PREM;
    raise;
    --
end create_PRTT_PREM;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PRTT_PREM >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PRTT_PREM
  (p_validate                       in  boolean   default false
  ,p_prtt_prem_id                   out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_std_prem_uom                   in  varchar2  default null
  ,p_std_prem_val                   in  number    default null
  ,p_actl_prem_id                   in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ppe_attribute_category         in  varchar2  default null
  ,p_ppe_attribute1                 in  varchar2  default null
  ,p_ppe_attribute2                 in  varchar2  default null
  ,p_ppe_attribute3                 in  varchar2  default null
  ,p_ppe_attribute4                 in  varchar2  default null
  ,p_ppe_attribute5                 in  varchar2  default null
  ,p_ppe_attribute6                 in  varchar2  default null
  ,p_ppe_attribute7                 in  varchar2  default null
  ,p_ppe_attribute8                 in  varchar2  default null
  ,p_ppe_attribute9                 in  varchar2  default null
  ,p_ppe_attribute10                in  varchar2  default null
  ,p_ppe_attribute11                in  varchar2  default null
  ,p_ppe_attribute12                in  varchar2  default null
  ,p_ppe_attribute13                in  varchar2  default null
  ,p_ppe_attribute14                in  varchar2  default null
  ,p_ppe_attribute15                in  varchar2  default null
  ,p_ppe_attribute16                in  varchar2  default null
  ,p_ppe_attribute17                in  varchar2  default null
  ,p_ppe_attribute18                in  varchar2  default null
  ,p_ppe_attribute19                in  varchar2  default null
  ,p_ppe_attribute20                in  varchar2  default null
  ,p_ppe_attribute21                in  varchar2  default null
  ,p_ppe_attribute22                in  varchar2  default null
  ,p_ppe_attribute23                in  varchar2  default null
  ,p_ppe_attribute24                in  varchar2  default null
  ,p_ppe_attribute25                in  varchar2  default null
  ,p_ppe_attribute26                in  varchar2  default null
  ,p_ppe_attribute27                in  varchar2  default null
  ,p_ppe_attribute28                in  varchar2  default null
  ,p_ppe_attribute29                in  varchar2  default null
  ,p_ppe_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_prtt_prem_id ben_prtt_prem_f.prtt_prem_id%TYPE;
  l_effective_start_date ben_prtt_prem_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_prem_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PRTT_PREM';
  l_object_version_number ben_prtt_prem_f.object_version_number%TYPE;
  l_per_in_ler_id ben_prtt_prem_f.per_in_ler_id%TYPE;
  --
  cursor c_per_in_ler is
    select pen.per_in_ler_id
    from   ben_prtt_enrt_rslt_f pen
    where  pen.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id and
           pen.prtt_enrt_rslt_stat_cd is null and
           pen.business_group_id+0=p_business_group_id and
           p_effective_date between
             pen.effective_start_date and pen.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PRTT_PREM;
  --
  open c_per_in_ler;
  fetch c_per_in_ler into l_per_in_ler_id;
  close c_per_in_ler;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PRTT_PREM
    --
    ben_PRTT_PREM_bk1.create_PRTT_PREM_b
      (
       p_std_prem_uom                   =>  p_std_prem_uom
      ,p_std_prem_val                   =>  p_std_prem_val
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id              =>  l_per_in_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ppe_attribute_category         =>  p_ppe_attribute_category
      ,p_ppe_attribute1                 =>  p_ppe_attribute1
      ,p_ppe_attribute2                 =>  p_ppe_attribute2
      ,p_ppe_attribute3                 =>  p_ppe_attribute3
      ,p_ppe_attribute4                 =>  p_ppe_attribute4
      ,p_ppe_attribute5                 =>  p_ppe_attribute5
      ,p_ppe_attribute6                 =>  p_ppe_attribute6
      ,p_ppe_attribute7                 =>  p_ppe_attribute7
      ,p_ppe_attribute8                 =>  p_ppe_attribute8
      ,p_ppe_attribute9                 =>  p_ppe_attribute9
      ,p_ppe_attribute10                =>  p_ppe_attribute10
      ,p_ppe_attribute11                =>  p_ppe_attribute11
      ,p_ppe_attribute12                =>  p_ppe_attribute12
      ,p_ppe_attribute13                =>  p_ppe_attribute13
      ,p_ppe_attribute14                =>  p_ppe_attribute14
      ,p_ppe_attribute15                =>  p_ppe_attribute15
      ,p_ppe_attribute16                =>  p_ppe_attribute16
      ,p_ppe_attribute17                =>  p_ppe_attribute17
      ,p_ppe_attribute18                =>  p_ppe_attribute18
      ,p_ppe_attribute19                =>  p_ppe_attribute19
      ,p_ppe_attribute20                =>  p_ppe_attribute20
      ,p_ppe_attribute21                =>  p_ppe_attribute21
      ,p_ppe_attribute22                =>  p_ppe_attribute22
      ,p_ppe_attribute23                =>  p_ppe_attribute23
      ,p_ppe_attribute24                =>  p_ppe_attribute24
      ,p_ppe_attribute25                =>  p_ppe_attribute25
      ,p_ppe_attribute26                =>  p_ppe_attribute26
      ,p_ppe_attribute27                =>  p_ppe_attribute27
      ,p_ppe_attribute28                =>  p_ppe_attribute28
      ,p_ppe_attribute29                =>  p_ppe_attribute29
      ,p_ppe_attribute30                =>  p_ppe_attribute30
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
         p_module_name => 'CREATE_PRTT_PREM'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PRTT_PREM
    --
  end;
  --
  ben_ppe_ins.ins
    (
     p_prtt_prem_id                  => l_prtt_prem_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_std_prem_uom                  => p_std_prem_uom
    ,p_std_prem_val                  => p_std_prem_val
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_per_in_ler_id             => l_per_in_ler_id
    ,p_business_group_id             => p_business_group_id
    ,p_ppe_attribute_category        => p_ppe_attribute_category
    ,p_ppe_attribute1                => p_ppe_attribute1
    ,p_ppe_attribute2                => p_ppe_attribute2
    ,p_ppe_attribute3                => p_ppe_attribute3
    ,p_ppe_attribute4                => p_ppe_attribute4
    ,p_ppe_attribute5                => p_ppe_attribute5
    ,p_ppe_attribute6                => p_ppe_attribute6
    ,p_ppe_attribute7                => p_ppe_attribute7
    ,p_ppe_attribute8                => p_ppe_attribute8
    ,p_ppe_attribute9                => p_ppe_attribute9
    ,p_ppe_attribute10               => p_ppe_attribute10
    ,p_ppe_attribute11               => p_ppe_attribute11
    ,p_ppe_attribute12               => p_ppe_attribute12
    ,p_ppe_attribute13               => p_ppe_attribute13
    ,p_ppe_attribute14               => p_ppe_attribute14
    ,p_ppe_attribute15               => p_ppe_attribute15
    ,p_ppe_attribute16               => p_ppe_attribute16
    ,p_ppe_attribute17               => p_ppe_attribute17
    ,p_ppe_attribute18               => p_ppe_attribute18
    ,p_ppe_attribute19               => p_ppe_attribute19
    ,p_ppe_attribute20               => p_ppe_attribute20
    ,p_ppe_attribute21               => p_ppe_attribute21
    ,p_ppe_attribute22               => p_ppe_attribute22
    ,p_ppe_attribute23               => p_ppe_attribute23
    ,p_ppe_attribute24               => p_ppe_attribute24
    ,p_ppe_attribute25               => p_ppe_attribute25
    ,p_ppe_attribute26               => p_ppe_attribute26
    ,p_ppe_attribute27               => p_ppe_attribute27
    ,p_ppe_attribute28               => p_ppe_attribute28
    ,p_ppe_attribute29               => p_ppe_attribute29
    ,p_ppe_attribute30               => p_ppe_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PRTT_PREM
    --
    ben_PRTT_PREM_bk1.create_PRTT_PREM_a
      (
       p_prtt_prem_id                   =>  l_prtt_prem_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_std_prem_uom                   =>  p_std_prem_uom
      ,p_std_prem_val                   =>  p_std_prem_val
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id              =>  l_per_in_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ppe_attribute_category         =>  p_ppe_attribute_category
      ,p_ppe_attribute1                 =>  p_ppe_attribute1
      ,p_ppe_attribute2                 =>  p_ppe_attribute2
      ,p_ppe_attribute3                 =>  p_ppe_attribute3
      ,p_ppe_attribute4                 =>  p_ppe_attribute4
      ,p_ppe_attribute5                 =>  p_ppe_attribute5
      ,p_ppe_attribute6                 =>  p_ppe_attribute6
      ,p_ppe_attribute7                 =>  p_ppe_attribute7
      ,p_ppe_attribute8                 =>  p_ppe_attribute8
      ,p_ppe_attribute9                 =>  p_ppe_attribute9
      ,p_ppe_attribute10                =>  p_ppe_attribute10
      ,p_ppe_attribute11                =>  p_ppe_attribute11
      ,p_ppe_attribute12                =>  p_ppe_attribute12
      ,p_ppe_attribute13                =>  p_ppe_attribute13
      ,p_ppe_attribute14                =>  p_ppe_attribute14
      ,p_ppe_attribute15                =>  p_ppe_attribute15
      ,p_ppe_attribute16                =>  p_ppe_attribute16
      ,p_ppe_attribute17                =>  p_ppe_attribute17
      ,p_ppe_attribute18                =>  p_ppe_attribute18
      ,p_ppe_attribute19                =>  p_ppe_attribute19
      ,p_ppe_attribute20                =>  p_ppe_attribute20
      ,p_ppe_attribute21                =>  p_ppe_attribute21
      ,p_ppe_attribute22                =>  p_ppe_attribute22
      ,p_ppe_attribute23                =>  p_ppe_attribute23
      ,p_ppe_attribute24                =>  p_ppe_attribute24
      ,p_ppe_attribute25                =>  p_ppe_attribute25
      ,p_ppe_attribute26                =>  p_ppe_attribute26
      ,p_ppe_attribute27                =>  p_ppe_attribute27
      ,p_ppe_attribute28                =>  p_ppe_attribute28
      ,p_ppe_attribute29                =>  p_ppe_attribute29
      ,p_ppe_attribute30                =>  p_ppe_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PRTT_PREM'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PRTT_PREM
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_prtt_prem_id := l_prtt_prem_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_PRTT_PREM;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtt_prem_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PRTT_PREM;
    raise;
    --
end create_PRTT_PREM;
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRTT_PREM >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PRTT_PREM
  (p_validate                       in  boolean   default false
  ,p_prtt_prem_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_std_prem_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_std_prem_val                   in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_per_in_ler_id              in  number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ppe_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PRTT_PREM';
  l_object_version_number ben_prtt_prem_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_prem_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_prem_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PRTT_PREM;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PRTT_PREM
    --
    ben_PRTT_PREM_bk2.update_PRTT_PREM_b
      (
       p_prtt_prem_id                   =>  p_prtt_prem_id
      ,p_std_prem_uom                   =>  p_std_prem_uom
      ,p_std_prem_val                   =>  p_std_prem_val
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id              =>  p_per_in_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ppe_attribute_category         =>  p_ppe_attribute_category
      ,p_ppe_attribute1                 =>  p_ppe_attribute1
      ,p_ppe_attribute2                 =>  p_ppe_attribute2
      ,p_ppe_attribute3                 =>  p_ppe_attribute3
      ,p_ppe_attribute4                 =>  p_ppe_attribute4
      ,p_ppe_attribute5                 =>  p_ppe_attribute5
      ,p_ppe_attribute6                 =>  p_ppe_attribute6
      ,p_ppe_attribute7                 =>  p_ppe_attribute7
      ,p_ppe_attribute8                 =>  p_ppe_attribute8
      ,p_ppe_attribute9                 =>  p_ppe_attribute9
      ,p_ppe_attribute10                =>  p_ppe_attribute10
      ,p_ppe_attribute11                =>  p_ppe_attribute11
      ,p_ppe_attribute12                =>  p_ppe_attribute12
      ,p_ppe_attribute13                =>  p_ppe_attribute13
      ,p_ppe_attribute14                =>  p_ppe_attribute14
      ,p_ppe_attribute15                =>  p_ppe_attribute15
      ,p_ppe_attribute16                =>  p_ppe_attribute16
      ,p_ppe_attribute17                =>  p_ppe_attribute17
      ,p_ppe_attribute18                =>  p_ppe_attribute18
      ,p_ppe_attribute19                =>  p_ppe_attribute19
      ,p_ppe_attribute20                =>  p_ppe_attribute20
      ,p_ppe_attribute21                =>  p_ppe_attribute21
      ,p_ppe_attribute22                =>  p_ppe_attribute22
      ,p_ppe_attribute23                =>  p_ppe_attribute23
      ,p_ppe_attribute24                =>  p_ppe_attribute24
      ,p_ppe_attribute25                =>  p_ppe_attribute25
      ,p_ppe_attribute26                =>  p_ppe_attribute26
      ,p_ppe_attribute27                =>  p_ppe_attribute27
      ,p_ppe_attribute28                =>  p_ppe_attribute28
      ,p_ppe_attribute29                =>  p_ppe_attribute29
      ,p_ppe_attribute30                =>  p_ppe_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_PREM'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PRTT_PREM
    --
  end;
  --
  ben_ppe_upd.upd
    (
     p_prtt_prem_id                  => p_prtt_prem_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_std_prem_uom                  => p_std_prem_uom
    ,p_std_prem_val                  => p_std_prem_val
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_per_in_ler_id             => p_per_in_ler_id
    ,p_business_group_id             => p_business_group_id
    ,p_ppe_attribute_category        => p_ppe_attribute_category
    ,p_ppe_attribute1                => p_ppe_attribute1
    ,p_ppe_attribute2                => p_ppe_attribute2
    ,p_ppe_attribute3                => p_ppe_attribute3
    ,p_ppe_attribute4                => p_ppe_attribute4
    ,p_ppe_attribute5                => p_ppe_attribute5
    ,p_ppe_attribute6                => p_ppe_attribute6
    ,p_ppe_attribute7                => p_ppe_attribute7
    ,p_ppe_attribute8                => p_ppe_attribute8
    ,p_ppe_attribute9                => p_ppe_attribute9
    ,p_ppe_attribute10               => p_ppe_attribute10
    ,p_ppe_attribute11               => p_ppe_attribute11
    ,p_ppe_attribute12               => p_ppe_attribute12
    ,p_ppe_attribute13               => p_ppe_attribute13
    ,p_ppe_attribute14               => p_ppe_attribute14
    ,p_ppe_attribute15               => p_ppe_attribute15
    ,p_ppe_attribute16               => p_ppe_attribute16
    ,p_ppe_attribute17               => p_ppe_attribute17
    ,p_ppe_attribute18               => p_ppe_attribute18
    ,p_ppe_attribute19               => p_ppe_attribute19
    ,p_ppe_attribute20               => p_ppe_attribute20
    ,p_ppe_attribute21               => p_ppe_attribute21
    ,p_ppe_attribute22               => p_ppe_attribute22
    ,p_ppe_attribute23               => p_ppe_attribute23
    ,p_ppe_attribute24               => p_ppe_attribute24
    ,p_ppe_attribute25               => p_ppe_attribute25
    ,p_ppe_attribute26               => p_ppe_attribute26
    ,p_ppe_attribute27               => p_ppe_attribute27
    ,p_ppe_attribute28               => p_ppe_attribute28
    ,p_ppe_attribute29               => p_ppe_attribute29
    ,p_ppe_attribute30               => p_ppe_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PRTT_PREM
    --
    ben_PRTT_PREM_bk2.update_PRTT_PREM_a
      (
       p_prtt_prem_id                   =>  p_prtt_prem_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_std_prem_uom                   =>  p_std_prem_uom
      ,p_std_prem_val                   =>  p_std_prem_val
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id              =>  p_per_in_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ppe_attribute_category         =>  p_ppe_attribute_category
      ,p_ppe_attribute1                 =>  p_ppe_attribute1
      ,p_ppe_attribute2                 =>  p_ppe_attribute2
      ,p_ppe_attribute3                 =>  p_ppe_attribute3
      ,p_ppe_attribute4                 =>  p_ppe_attribute4
      ,p_ppe_attribute5                 =>  p_ppe_attribute5
      ,p_ppe_attribute6                 =>  p_ppe_attribute6
      ,p_ppe_attribute7                 =>  p_ppe_attribute7
      ,p_ppe_attribute8                 =>  p_ppe_attribute8
      ,p_ppe_attribute9                 =>  p_ppe_attribute9
      ,p_ppe_attribute10                =>  p_ppe_attribute10
      ,p_ppe_attribute11                =>  p_ppe_attribute11
      ,p_ppe_attribute12                =>  p_ppe_attribute12
      ,p_ppe_attribute13                =>  p_ppe_attribute13
      ,p_ppe_attribute14                =>  p_ppe_attribute14
      ,p_ppe_attribute15                =>  p_ppe_attribute15
      ,p_ppe_attribute16                =>  p_ppe_attribute16
      ,p_ppe_attribute17                =>  p_ppe_attribute17
      ,p_ppe_attribute18                =>  p_ppe_attribute18
      ,p_ppe_attribute19                =>  p_ppe_attribute19
      ,p_ppe_attribute20                =>  p_ppe_attribute20
      ,p_ppe_attribute21                =>  p_ppe_attribute21
      ,p_ppe_attribute22                =>  p_ppe_attribute22
      ,p_ppe_attribute23                =>  p_ppe_attribute23
      ,p_ppe_attribute24                =>  p_ppe_attribute24
      ,p_ppe_attribute25                =>  p_ppe_attribute25
      ,p_ppe_attribute26                =>  p_ppe_attribute26
      ,p_ppe_attribute27                =>  p_ppe_attribute27
      ,p_ppe_attribute28                =>  p_ppe_attribute28
      ,p_ppe_attribute29                =>  p_ppe_attribute29
      ,p_ppe_attribute30                =>  p_ppe_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_PREM'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PRTT_PREM
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
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
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_PRTT_PREM;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_PRTT_PREM;
    raise;
    --
end update_PRTT_PREM;
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRTT_PREM >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PRTT_PREM
  (p_validate                       in  boolean   default false
  ,p_prtt_prem_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_std_prem_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_std_prem_val                   in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ppe_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ppe_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PRTT_PREM';
  l_object_version_number ben_prtt_prem_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_prem_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_prem_f.effective_end_date%TYPE;
  l_per_in_ler_id ben_prtt_prem_f.per_in_ler_id%TYPE;
  --
  cursor c_per_in_ler is
    select pen.per_in_ler_id
    from   ben_prtt_enrt_rslt_f pen
    where  pen.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id and
           pen.prtt_enrt_rslt_stat_cd is null and
           pen.business_group_id+0=p_business_group_id and
           p_effective_date between
             pen.effective_start_date and pen.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PRTT_PREM;
  --
  open c_per_in_ler;
  fetch c_per_in_ler into l_per_in_ler_id;
  if c_per_in_ler%notfound then
    l_per_in_ler_id:=hr_api.g_number;
  end if;
  close c_per_in_ler;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PRTT_PREM
    --
    ben_PRTT_PREM_bk2.update_PRTT_PREM_b
      (
       p_prtt_prem_id                   =>  p_prtt_prem_id
      ,p_std_prem_uom                   =>  p_std_prem_uom
      ,p_std_prem_val                   =>  p_std_prem_val
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id              =>  l_per_in_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ppe_attribute_category         =>  p_ppe_attribute_category
      ,p_ppe_attribute1                 =>  p_ppe_attribute1
      ,p_ppe_attribute2                 =>  p_ppe_attribute2
      ,p_ppe_attribute3                 =>  p_ppe_attribute3
      ,p_ppe_attribute4                 =>  p_ppe_attribute4
      ,p_ppe_attribute5                 =>  p_ppe_attribute5
      ,p_ppe_attribute6                 =>  p_ppe_attribute6
      ,p_ppe_attribute7                 =>  p_ppe_attribute7
      ,p_ppe_attribute8                 =>  p_ppe_attribute8
      ,p_ppe_attribute9                 =>  p_ppe_attribute9
      ,p_ppe_attribute10                =>  p_ppe_attribute10
      ,p_ppe_attribute11                =>  p_ppe_attribute11
      ,p_ppe_attribute12                =>  p_ppe_attribute12
      ,p_ppe_attribute13                =>  p_ppe_attribute13
      ,p_ppe_attribute14                =>  p_ppe_attribute14
      ,p_ppe_attribute15                =>  p_ppe_attribute15
      ,p_ppe_attribute16                =>  p_ppe_attribute16
      ,p_ppe_attribute17                =>  p_ppe_attribute17
      ,p_ppe_attribute18                =>  p_ppe_attribute18
      ,p_ppe_attribute19                =>  p_ppe_attribute19
      ,p_ppe_attribute20                =>  p_ppe_attribute20
      ,p_ppe_attribute21                =>  p_ppe_attribute21
      ,p_ppe_attribute22                =>  p_ppe_attribute22
      ,p_ppe_attribute23                =>  p_ppe_attribute23
      ,p_ppe_attribute24                =>  p_ppe_attribute24
      ,p_ppe_attribute25                =>  p_ppe_attribute25
      ,p_ppe_attribute26                =>  p_ppe_attribute26
      ,p_ppe_attribute27                =>  p_ppe_attribute27
      ,p_ppe_attribute28                =>  p_ppe_attribute28
      ,p_ppe_attribute29                =>  p_ppe_attribute29
      ,p_ppe_attribute30                =>  p_ppe_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_PREM'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PRTT_PREM
    --
  end;
  --
  ben_ppe_upd.upd
    (
     p_prtt_prem_id                  => p_prtt_prem_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_std_prem_uom                  => p_std_prem_uom
    ,p_std_prem_val                  => p_std_prem_val
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_per_in_ler_id             => l_per_in_ler_id
    ,p_business_group_id             => p_business_group_id
    ,p_ppe_attribute_category        => p_ppe_attribute_category
    ,p_ppe_attribute1                => p_ppe_attribute1
    ,p_ppe_attribute2                => p_ppe_attribute2
    ,p_ppe_attribute3                => p_ppe_attribute3
    ,p_ppe_attribute4                => p_ppe_attribute4
    ,p_ppe_attribute5                => p_ppe_attribute5
    ,p_ppe_attribute6                => p_ppe_attribute6
    ,p_ppe_attribute7                => p_ppe_attribute7
    ,p_ppe_attribute8                => p_ppe_attribute8
    ,p_ppe_attribute9                => p_ppe_attribute9
    ,p_ppe_attribute10               => p_ppe_attribute10
    ,p_ppe_attribute11               => p_ppe_attribute11
    ,p_ppe_attribute12               => p_ppe_attribute12
    ,p_ppe_attribute13               => p_ppe_attribute13
    ,p_ppe_attribute14               => p_ppe_attribute14
    ,p_ppe_attribute15               => p_ppe_attribute15
    ,p_ppe_attribute16               => p_ppe_attribute16
    ,p_ppe_attribute17               => p_ppe_attribute17
    ,p_ppe_attribute18               => p_ppe_attribute18
    ,p_ppe_attribute19               => p_ppe_attribute19
    ,p_ppe_attribute20               => p_ppe_attribute20
    ,p_ppe_attribute21               => p_ppe_attribute21
    ,p_ppe_attribute22               => p_ppe_attribute22
    ,p_ppe_attribute23               => p_ppe_attribute23
    ,p_ppe_attribute24               => p_ppe_attribute24
    ,p_ppe_attribute25               => p_ppe_attribute25
    ,p_ppe_attribute26               => p_ppe_attribute26
    ,p_ppe_attribute27               => p_ppe_attribute27
    ,p_ppe_attribute28               => p_ppe_attribute28
    ,p_ppe_attribute29               => p_ppe_attribute29
    ,p_ppe_attribute30               => p_ppe_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PRTT_PREM
    --
    ben_PRTT_PREM_bk2.update_PRTT_PREM_a
      (
       p_prtt_prem_id                   =>  p_prtt_prem_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_std_prem_uom                   =>  p_std_prem_uom
      ,p_std_prem_val                   =>  p_std_prem_val
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id              =>  l_per_in_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ppe_attribute_category         =>  p_ppe_attribute_category
      ,p_ppe_attribute1                 =>  p_ppe_attribute1
      ,p_ppe_attribute2                 =>  p_ppe_attribute2
      ,p_ppe_attribute3                 =>  p_ppe_attribute3
      ,p_ppe_attribute4                 =>  p_ppe_attribute4
      ,p_ppe_attribute5                 =>  p_ppe_attribute5
      ,p_ppe_attribute6                 =>  p_ppe_attribute6
      ,p_ppe_attribute7                 =>  p_ppe_attribute7
      ,p_ppe_attribute8                 =>  p_ppe_attribute8
      ,p_ppe_attribute9                 =>  p_ppe_attribute9
      ,p_ppe_attribute10                =>  p_ppe_attribute10
      ,p_ppe_attribute11                =>  p_ppe_attribute11
      ,p_ppe_attribute12                =>  p_ppe_attribute12
      ,p_ppe_attribute13                =>  p_ppe_attribute13
      ,p_ppe_attribute14                =>  p_ppe_attribute14
      ,p_ppe_attribute15                =>  p_ppe_attribute15
      ,p_ppe_attribute16                =>  p_ppe_attribute16
      ,p_ppe_attribute17                =>  p_ppe_attribute17
      ,p_ppe_attribute18                =>  p_ppe_attribute18
      ,p_ppe_attribute19                =>  p_ppe_attribute19
      ,p_ppe_attribute20                =>  p_ppe_attribute20
      ,p_ppe_attribute21                =>  p_ppe_attribute21
      ,p_ppe_attribute22                =>  p_ppe_attribute22
      ,p_ppe_attribute23                =>  p_ppe_attribute23
      ,p_ppe_attribute24                =>  p_ppe_attribute24
      ,p_ppe_attribute25                =>  p_ppe_attribute25
      ,p_ppe_attribute26                =>  p_ppe_attribute26
      ,p_ppe_attribute27                =>  p_ppe_attribute27
      ,p_ppe_attribute28                =>  p_ppe_attribute28
      ,p_ppe_attribute29                =>  p_ppe_attribute29
      ,p_ppe_attribute30                =>  p_ppe_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_PREM'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PRTT_PREM
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
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
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_PRTT_PREM;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_PRTT_PREM;
    raise;
    --
end update_PRTT_PREM;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRTT_PREM >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_PREM
  (p_validate                       in  boolean  default false
  ,p_prtt_prem_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PRTT_PREM';
  l_object_version_number ben_prtt_prem_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_prem_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_prem_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PRTT_PREM;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_PRTT_PREM
    --
    ben_PRTT_PREM_bk3.delete_PRTT_PREM_b
      (
       p_prtt_prem_id                   =>  p_prtt_prem_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTT_PREM'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_PRTT_PREM
    --
  end;
  --
  ben_ppe_del.del
    (
     p_prtt_prem_id                  => p_prtt_prem_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PRTT_PREM
    --
    ben_PRTT_PREM_bk3.delete_PRTT_PREM_a
      (
       p_prtt_prem_id                   =>  p_prtt_prem_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTT_PREM'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_PRTT_PREM
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_PRTT_PREM;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_PRTT_PREM;
    raise;
    --
end delete_PRTT_PREM;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_prtt_prem_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_ppe_shd.lck
    (
      p_prtt_prem_id                 => p_prtt_prem_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_PRTT_PREM_api;

/
