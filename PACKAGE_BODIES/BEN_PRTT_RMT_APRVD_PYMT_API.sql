--------------------------------------------------------
--  DDL for Package Body BEN_PRTT_RMT_APRVD_PYMT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRTT_RMT_APRVD_PYMT_API" as
/* $Header: bepryapi.pkb 120.3.12010000.2 2008/08/05 15:23:06 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_prtt_rmt_aprvd_pymt_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_prtt_rmt_aprvd_pymt >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_prtt_rmt_aprvd_pymt
  (p_validate                       in  boolean   default false
  ,p_prtt_rmt_aprvd_fr_pymt_id      out nocopy number
  ,p_prtt_reimbmt_rqst_id           in  number    default null
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_apprvd_fr_pymt_num             in  number    default null
  ,p_adjmt_flag                     in  varchar2  default null
  ,p_aprvd_fr_pymt_amt              in  number    default null
  ,p_pymt_stat_cd                   in  varchar2  default null
  ,p_pymt_stat_rsn_cd               in  varchar2  default null
  ,p_pymt_stat_ovrdn_rsn_cd         in  varchar2  default null
  ,p_pymt_stat_prr_to_ovrd_cd       in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_element_entry_value_id         in  number    default null
  ,p_pry_attribute_category         in  varchar2  default null
  ,p_pry_attribute1                 in  varchar2  default null
  ,p_pry_attribute2                 in  varchar2  default null
  ,p_pry_attribute3                 in  varchar2  default null
  ,p_pry_attribute4                 in  varchar2  default null
  ,p_pry_attribute5                 in  varchar2  default null
  ,p_pry_attribute6                 in  varchar2  default null
  ,p_pry_attribute7                 in  varchar2  default null
  ,p_pry_attribute8                 in  varchar2  default null
  ,p_pry_attribute9                 in  varchar2  default null
  ,p_pry_attribute10                in  varchar2  default null
  ,p_pry_attribute11                in  varchar2  default null
  ,p_pry_attribute12                in  varchar2  default null
  ,p_pry_attribute13                in  varchar2  default null
  ,p_pry_attribute14                in  varchar2  default null
  ,p_pry_attribute15                in  varchar2  default null
  ,p_pry_attribute16                in  varchar2  default null
  ,p_pry_attribute17                in  varchar2  default null
  ,p_pry_attribute18                in  varchar2  default null
  ,p_pry_attribute19                in  varchar2  default null
  ,p_pry_attribute20                in  varchar2  default null
  ,p_pry_attribute21                in  varchar2  default null
  ,p_pry_attribute22                in  varchar2  default null
  ,p_pry_attribute23                in  varchar2  default null
  ,p_pry_attribute24                in  varchar2  default null
  ,p_pry_attribute25                in  varchar2  default null
  ,p_pry_attribute26                in  varchar2  default null
  ,p_pry_attribute27                in  varchar2  default null
  ,p_pry_attribute28                in  varchar2  default null
  ,p_pry_attribute29                in  varchar2  default null
  ,p_pry_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --


  cursor c_pln
    is
    select pln.nip_acty_ref_perd_cd
          ,pln.pl_id
          ,prc.prtt_enrt_rslt_id
          ,prc.submitter_person_id
          ,prc.incrd_from_dt
          ,prc.incrd_to_dt
          ,prc.exp_incurd_dt
    from   ben_pl_f pln ,
           ben_prtt_reimbmt_rqst_f  prc
    where  pln.pl_id = prc.pl_id
    and    prc.prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id
    and    p_effective_date
           between prc.effective_start_date
           and     prc.effective_end_date
    and    p_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date;

   Cursor  c_rslt_rec (p_prtt_enrt_rslt_id  number ,
                       p_incrd_from_dt      date   ,
                       p_incrd_to_dt        date  )  is
     select pen.pgm_id,
            pen.per_in_ler_id
     from   ben_prtt_enrt_rslt_f pen
     where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and  pen.prtt_enrt_rslt_stat_cd is null
       and  pen.business_group_id = p_business_group_id
       and  p_effective_date between
            pen.effective_start_date and pen.effective_end_date
       and  p_incrd_from_dt <= pen.enrt_cvg_thru_dt
       and  p_incrd_to_dt  >=  pen.enrt_cvg_strt_dt
         ;
   --
   l_rslt_rec   c_rslt_rec%rowtype;
   --

  cursor c_abr_pl(p_pl_id number)
   is
   select abr.acty_base_rt_id  ,
          abr.rt_typ_cd,
          abr.tx_typ_cd,
          abr.acty_typ_cd,
          abr.rt_mlt_cd,
          abr.bnft_rt_typ_cd,
          abr.dsply_on_enrt_flag,
          abr.comp_lvl_fctr_id,
          abr.actl_prem_id,
          abr.input_value_id,
          abr.element_type_id
   from ben_acty_base_rt_f abr
   where pl_id = p_pl_id
   and   acty_typ_cd like 'PRD%'
   and   acty_base_rt_stat_cd = 'A'
   and   p_effective_date between
         abr.effective_start_date and
         abr.effective_end_date;


   cursor  c_abr_plip (p_pl_id number, p_pgm_id  number)
   is
   select abr.acty_base_rt_id,
          abr.rt_typ_cd,
          abr.tx_typ_cd,
          abr.acty_typ_cd,
          abr.rt_mlt_cd,
          abr.bnft_rt_typ_cd,
          abr.dsply_on_enrt_flag,
          abr.comp_lvl_fctr_id,
          abr.actl_prem_id,
          abr.input_value_id,
          abr.element_type_id
   from ben_acty_base_rt_f abr,
        ben_plip_f plp
   where plp.pl_id   = p_pl_id
   and   plp.pgm_id   = p_pgm_id
   and   p_effective_date between
         plp.effective_start_date and
         plp.effective_end_date
   and   plp.plip_id = abr.plip_id
   and   acty_base_rt_stat_cd = 'A'
   and   abr.acty_typ_cd like 'PRD%'
   and   p_effective_date between
         abr.effective_start_date and
         abr.effective_end_date;

   --
   l_acty_base_rt      c_abr_pl%rowtype;

    cursor c_cvg_pl (p_pl_id number)
    is
     select ccm.cvg_amt_calc_mthd_id
     from   ben_cvg_amt_calc_mthd_f ccm
     where  pl_id = p_pl_id
     and    p_effective_date
            between ccm.effective_start_date
     and            ccm.effective_end_date;

   cursor c_pgm
     (c_pgm_id number)
     is
     select pgm.acty_ref_perd_cd
     from   ben_pgm_f pgm
     where  pgm.pgm_id = c_pgm_id
       and  p_effective_date
            between pgm.effective_start_date
            and   pgm.effective_end_date;


  -- Declare cursors and local variables
  --
  l_prtt_rmt_aprvd_fr_pymt_id ben_prtt_rmt_aprvd_fr_pymt_f.prtt_rmt_aprvd_fr_pymt_id%TYPE;
  l_effective_start_date ben_prtt_rmt_aprvd_fr_pymt_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_rmt_aprvd_fr_pymt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_prtt_rmt_aprvd_pymt';
  l_object_version_number ben_prtt_rmt_aprvd_fr_pymt_f.object_version_number%TYPE;
  --
  l_prtt_rt_val_id             number;
  l_prtt_enrt_rslt_id          number;
  l_object_version_number_prt ben_prtt_rmt_aprvd_fr_pymt_f.object_version_number%TYPE;
  l_acty_ref_perd_cd   varchar2(30);
  l_pl_id                number ;
  l_cvg_amt_calc_mthd_id number ;
  l_submitter_person_id  number ;
  l_incrd_from_dt        date ;
  l_incrd_to_dt          date ;
  l_exp_incurd_dt        date ;

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_prtt_rmt_aprvd_pymt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_prtt_rmt_aprvd_pymt
    --
    ben_prtt_rmt_aprvd_pymt_bk1.create_prtt_rmt_aprvd_pymt_b
      (
       p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_apprvd_fr_pymt_num             =>  p_apprvd_fr_pymt_num
      ,p_adjmt_flag                     =>  p_adjmt_flag
      ,p_aprvd_fr_pymt_amt              =>  p_aprvd_fr_pymt_amt
      ,p_pymt_stat_cd                   =>  p_pymt_stat_cd
      ,p_pymt_stat_rsn_cd               =>  p_pymt_stat_rsn_cd
      ,p_pymt_stat_ovrdn_rsn_cd         =>  p_pymt_stat_ovrdn_rsn_cd
      ,p_pymt_stat_prr_to_ovrd_cd       =>  p_pymt_stat_prr_to_ovrd_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_element_entry_value_id         =>  p_element_entry_value_id
      ,p_pry_attribute_category         =>  p_pry_attribute_category
      ,p_pry_attribute1                 =>  p_pry_attribute1
      ,p_pry_attribute2                 =>  p_pry_attribute2
      ,p_pry_attribute3                 =>  p_pry_attribute3
      ,p_pry_attribute4                 =>  p_pry_attribute4
      ,p_pry_attribute5                 =>  p_pry_attribute5
      ,p_pry_attribute6                 =>  p_pry_attribute6
      ,p_pry_attribute7                 =>  p_pry_attribute7
      ,p_pry_attribute8                 =>  p_pry_attribute8
      ,p_pry_attribute9                 =>  p_pry_attribute9
      ,p_pry_attribute10                =>  p_pry_attribute10
      ,p_pry_attribute11                =>  p_pry_attribute11
      ,p_pry_attribute12                =>  p_pry_attribute12
      ,p_pry_attribute13                =>  p_pry_attribute13
      ,p_pry_attribute14                =>  p_pry_attribute14
      ,p_pry_attribute15                =>  p_pry_attribute15
      ,p_pry_attribute16                =>  p_pry_attribute16
      ,p_pry_attribute17                =>  p_pry_attribute17
      ,p_pry_attribute18                =>  p_pry_attribute18
      ,p_pry_attribute19                =>  p_pry_attribute19
      ,p_pry_attribute20                =>  p_pry_attribute20
      ,p_pry_attribute21                =>  p_pry_attribute21
      ,p_pry_attribute22                =>  p_pry_attribute22
      ,p_pry_attribute23                =>  p_pry_attribute23
      ,p_pry_attribute24                =>  p_pry_attribute24
      ,p_pry_attribute25                =>  p_pry_attribute25
      ,p_pry_attribute26                =>  p_pry_attribute26
      ,p_pry_attribute27                =>  p_pry_attribute27
      ,p_pry_attribute28                =>  p_pry_attribute28
      ,p_pry_attribute29                =>  p_pry_attribute29
      ,p_pry_attribute30                =>  p_pry_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_prtt_rmt_aprvd_pymt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_prtt_rmt_aprvd_pymt
    --
  end;
  --
  ben_pry_ins.ins
    (
     p_prtt_rmt_aprvd_fr_pymt_id     => l_prtt_rmt_aprvd_fr_pymt_id
    ,p_prtt_reimbmt_rqst_id          => p_prtt_reimbmt_rqst_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_apprvd_fr_pymt_num            => p_apprvd_fr_pymt_num
    ,p_adjmt_flag                    => p_adjmt_flag
    ,p_aprvd_fr_pymt_amt             => p_aprvd_fr_pymt_amt
    ,p_pymt_stat_cd                  => p_pymt_stat_cd
    ,p_pymt_stat_rsn_cd              => p_pymt_stat_rsn_cd
    ,p_pymt_stat_ovrdn_rsn_cd        => p_pymt_stat_ovrdn_rsn_cd
    ,p_pymt_stat_prr_to_ovrd_cd      => p_pymt_stat_prr_to_ovrd_cd
    ,p_business_group_id             => p_business_group_id
    ,p_element_entry_value_id         =>  p_element_entry_value_id
    ,p_pry_attribute_category        => p_pry_attribute_category
    ,p_pry_attribute1                => p_pry_attribute1
    ,p_pry_attribute2                => p_pry_attribute2
    ,p_pry_attribute3                => p_pry_attribute3
    ,p_pry_attribute4                => p_pry_attribute4
    ,p_pry_attribute5                => p_pry_attribute5
    ,p_pry_attribute6                => p_pry_attribute6
    ,p_pry_attribute7                => p_pry_attribute7
    ,p_pry_attribute8                => p_pry_attribute8
    ,p_pry_attribute9                => p_pry_attribute9
    ,p_pry_attribute10               => p_pry_attribute10
    ,p_pry_attribute11               => p_pry_attribute11
    ,p_pry_attribute12               => p_pry_attribute12
    ,p_pry_attribute13               => p_pry_attribute13
    ,p_pry_attribute14               => p_pry_attribute14
    ,p_pry_attribute15               => p_pry_attribute15
    ,p_pry_attribute16               => p_pry_attribute16
    ,p_pry_attribute17               => p_pry_attribute17
    ,p_pry_attribute18               => p_pry_attribute18
    ,p_pry_attribute19               => p_pry_attribute19
    ,p_pry_attribute20               => p_pry_attribute20
    ,p_pry_attribute21               => p_pry_attribute21
    ,p_pry_attribute22               => p_pry_attribute22
    ,p_pry_attribute23               => p_pry_attribute23
    ,p_pry_attribute24               => p_pry_attribute24
    ,p_pry_attribute25               => p_pry_attribute25
    ,p_pry_attribute26               => p_pry_attribute26
    ,p_pry_attribute27               => p_pry_attribute27
    ,p_pry_attribute28               => p_pry_attribute28
    ,p_pry_attribute29               => p_pry_attribute29
    ,p_pry_attribute30               => p_pry_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_prtt_rmt_aprvd_pymt
    --
    ben_prtt_rmt_aprvd_pymt_bk1.create_prtt_rmt_aprvd_pymt_a
      (
       p_prtt_rmt_aprvd_fr_pymt_id      =>  l_prtt_rmt_aprvd_fr_pymt_id
      ,p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_apprvd_fr_pymt_num             =>  p_apprvd_fr_pymt_num
      ,p_adjmt_flag                     =>  p_adjmt_flag
      ,p_aprvd_fr_pymt_amt              =>  p_aprvd_fr_pymt_amt
      ,p_pymt_stat_cd                   =>  p_pymt_stat_cd
      ,p_pymt_stat_rsn_cd               =>  p_pymt_stat_rsn_cd
      ,p_pymt_stat_ovrdn_rsn_cd         =>  p_pymt_stat_ovrdn_rsn_cd
      ,p_pymt_stat_prr_to_ovrd_cd       =>  p_pymt_stat_prr_to_ovrd_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_element_entry_value_id         =>  p_element_entry_value_id
      ,p_pry_attribute_category         =>  p_pry_attribute_category
      ,p_pry_attribute1                 =>  p_pry_attribute1
      ,p_pry_attribute2                 =>  p_pry_attribute2
      ,p_pry_attribute3                 =>  p_pry_attribute3
      ,p_pry_attribute4                 =>  p_pry_attribute4
      ,p_pry_attribute5                 =>  p_pry_attribute5
      ,p_pry_attribute6                 =>  p_pry_attribute6
      ,p_pry_attribute7                 =>  p_pry_attribute7
      ,p_pry_attribute8                 =>  p_pry_attribute8
      ,p_pry_attribute9                 =>  p_pry_attribute9
      ,p_pry_attribute10                =>  p_pry_attribute10
      ,p_pry_attribute11                =>  p_pry_attribute11
      ,p_pry_attribute12                =>  p_pry_attribute12
      ,p_pry_attribute13                =>  p_pry_attribute13
      ,p_pry_attribute14                =>  p_pry_attribute14
      ,p_pry_attribute15                =>  p_pry_attribute15
      ,p_pry_attribute16                =>  p_pry_attribute16
      ,p_pry_attribute17                =>  p_pry_attribute17
      ,p_pry_attribute18                =>  p_pry_attribute18
      ,p_pry_attribute19                =>  p_pry_attribute19
      ,p_pry_attribute20                =>  p_pry_attribute20
      ,p_pry_attribute21                =>  p_pry_attribute21
      ,p_pry_attribute22                =>  p_pry_attribute22
      ,p_pry_attribute23                =>  p_pry_attribute23
      ,p_pry_attribute24                =>  p_pry_attribute24
      ,p_pry_attribute25                =>  p_pry_attribute25
      ,p_pry_attribute26                =>  p_pry_attribute26
      ,p_pry_attribute27                =>  p_pry_attribute27
      ,p_pry_attribute28                =>  p_pry_attribute28
      ,p_pry_attribute29                =>  p_pry_attribute29
      ,p_pry_attribute30                =>  p_pry_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_prtt_rmt_aprvd_pymt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_prtt_rmt_aprvd_pymt
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  ----Creating variable to create element  entry
   open c_pln;
   fetch c_pln into
        l_acty_ref_perd_cd ,
        l_pl_id ,
        l_prtt_enrt_rslt_id,
        l_submitter_person_id ,
        l_incrd_from_dt  ,
        l_incrd_to_dt  ,
        l_exp_incurd_dt  ;
   close c_pln;

  open c_rslt_rec(l_prtt_enrt_rslt_id,
                  l_incrd_from_dt  ,
                  l_incrd_to_dt ) ;
  fetch c_rslt_rec into l_rslt_rec;
  close c_rslt_rec;

  if  l_rslt_rec.pgm_id is not null then
    --
    hr_utility.set_location('pgm '||l_rslt_rec.pgm_id,100);
    open c_pgm (l_rslt_rec.pgm_id);
    fetch c_pgm into l_acty_ref_perd_cd;
    close c_pgm;
    --
  End if  ;


  ---- chek for reimbursement rate
  open c_abr_plip(l_pl_id,l_rslt_rec.pgm_id);
  fetch c_abr_plip into l_acty_base_rt;
  if c_abr_plip%notfound then
     open c_abr_pl(l_pl_id) ;
     fetch c_abr_pl into l_acty_base_rt ;
     if c_abr_pl%notfound then
        close c_abr_pl;
        close c_abr_plip ;
        fnd_message.set_name('BEN','BEN_92697_NO_REMBMT_RATE');
        fnd_message.raise_error;
     end if ;
     close c_abr_pl;
  end if;
  close c_abr_plip;


  open c_cvg_pl(l_pl_id ) ;
  fetch c_cvg_pl into l_cvg_amt_calc_mthd_id;
  close c_cvg_pl;

  /*
  ----Creating Element Entry
  ben_prtt_rt_val_api.create_prtt_rt_val(
           p_prtt_rt_val_id                 => l_prtt_rt_val_id
          ,p_per_in_ler_id                  => l_rslt_rec.per_in_ler_id
          ,p_rt_typ_cd                      => l_acty_base_rt.rt_typ_cd
          ,p_tx_typ_cd                      => l_acty_base_rt.tx_typ_cd
          ,p_acty_typ_cd                    => l_acty_base_rt.acty_typ_cd
          ,p_mlt_cd                         => l_acty_base_rt.rt_mlt_cd
          ,p_acty_ref_perd_cd               => l_acty_ref_perd_cd
          ,p_rt_val                         => p_aprvd_fr_pymt_amt
          ,p_rt_strt_dt                     => l_effective_start_date
          ,p_rt_end_dt                      => l_effective_start_date
          ,p_bnft_rt_typ_cd                 => l_acty_base_rt.bnft_rt_typ_cd
          ,p_dsply_on_enrt_flag             => 'N'--l_acty_base_rt.dsply_on_enrt_flag
          ,p_elctns_made_dt                 => l_effective_start_date
          ,p_cvg_amt_calc_mthd_id           => l_cvg_amt_calc_mthd_id
          ,p_actl_prem_id                   => l_acty_base_rt.actl_prem_id
          ,p_comp_lvl_fctr_id               => l_acty_base_rt.comp_lvl_fctr_id
          ,p_business_group_id              => p_business_group_id
          ,p_object_version_number          => l_object_version_number_prt
          ,p_effective_date                 => p_effective_date
          ,p_acty_base_rt_id                => l_acty_base_rt.acty_base_rt_id
          ,p_person_id                      => l_submitter_person_id
          ,p_PRTT_REIMBMT_RQST_ID           => p_PRTT_REIMBMT_RQST_ID
          ,p_prtt_rmt_aprvd_fr_pymt_id      => l_prtt_rmt_aprvd_fr_pymt_id
          ,p_input_value_id                 => l_acty_base_rt.input_value_id
          ,p_element_type_id                => l_acty_base_rt.element_type_id
          ,p_prtt_enrt_rslt_id              => l_prtt_enrt_rslt_id
        );
    */
    --bug#5523456
    if l_acty_base_rt.element_type_id is not null then
      --
      ben_element_entry.create_reimburse_element
       ( p_validate                   => p_validate
        ,p_person_id                  => l_submitter_person_id
        ,p_acty_base_rt_id            => l_acty_base_rt.acty_base_rt_id
        ,p_amt                        => p_aprvd_fr_pymt_amt
        ,p_business_group_id          => p_business_group_id
        ,p_effective_date             => p_effective_date
        ,p_prtt_reimbmt_rqst_id       => p_prtt_reimbmt_rqst_id
        ,p_input_value_id             => l_acty_base_rt.input_value_id
        ,p_element_type_id            => l_acty_base_rt.element_type_id
        ,p_pl_id                      => l_pl_id
        ,p_prtt_rmt_aprvd_fr_pymt_id  => l_prtt_rmt_aprvd_fr_pymt_id
        ,p_object_version_number      => l_object_version_number
         );
       --
     end if;





  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_prtt_rmt_aprvd_fr_pymt_id := l_prtt_rmt_aprvd_fr_pymt_id;
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
    ROLLBACK TO create_prtt_rmt_aprvd_pymt;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtt_rmt_aprvd_fr_pymt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_prtt_rmt_aprvd_pymt;
    p_prtt_rmt_aprvd_fr_pymt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_prtt_rmt_aprvd_pymt;
-- ----------------------------------------------------------------------------
-- |------------------------< update_prtt_rmt_aprvd_pymt >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_prtt_rmt_aprvd_pymt
  (p_validate                       in  boolean   default false
  ,p_prtt_rmt_aprvd_fr_pymt_id      in  number
  ,p_prtt_reimbmt_rqst_id           in  number    default hr_api.g_number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_apprvd_fr_pymt_num             in  number    default hr_api.g_number
  ,p_adjmt_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_aprvd_fr_pymt_amt              in  number    default hr_api.g_number
  ,p_pymt_stat_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_pymt_stat_rsn_cd               in  varchar2  default hr_api.g_varchar2
  ,p_pymt_stat_ovrdn_rsn_cd         in  varchar2  default hr_api.g_varchar2
  ,p_pymt_stat_prr_to_ovrd_cd       in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_element_entry_value_id         in  number    default hr_api.g_number
  ,p_pry_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pry_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  cursor c_pry is
  select * From ben_prtt_rmt_aprvd_fr_pymt_f pry
  where p_effective_date between pry.effective_start_date
            and pry.effective_end_date
    and pry.prtt_rmt_aprvd_fr_pymt_id = p_prtt_rmt_aprvd_fr_pymt_id;

  l_pry_rec   c_pry%rowtype ;

   cursor c_acty_base_rt (p_acty_base_rt number)
   is
   select abr.input_value_id,
          abr.element_type_id
   from ben_acty_base_rt_f abr
   where acty_base_rt_id  = p_acty_base_rt
   and   p_effective_date between
         abr.effective_start_date and
         abr.effective_end_date;

   cursor c_old_prc is
   select prc.submitter_person_id,
          prc.pl_id,
          prc.prtt_enrt_rslt_id
   from ben_prtt_reimbmt_rqst_f  prc
   where prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id
     and p_effective_date between
         prc.effective_start_date and
         prc.effective_end_date;

  cursor c_abr_pl(p_pl_id number)
   is
   select abr.acty_base_rt_id  ,
          abr.rt_typ_cd,
          abr.tx_typ_cd,
          abr.acty_typ_cd,
          abr.rt_mlt_cd,
          abr.bnft_rt_typ_cd,
          abr.dsply_on_enrt_flag,
          abr.comp_lvl_fctr_id,
          abr.actl_prem_id,
          abr.input_value_id,
          abr.element_type_id
   from ben_acty_base_rt_f abr
   where pl_id = p_pl_id
   and   acty_typ_cd like 'PRD%'
   and   acty_base_rt_stat_cd = 'A'
   and   p_effective_date between
         abr.effective_start_date and
         abr.effective_end_date;


   cursor  c_abr_plip (p_pl_id number, p_pgm_id  number)
   is
   select abr.acty_base_rt_id,
          abr.rt_typ_cd,
          abr.tx_typ_cd,
          abr.acty_typ_cd,
          abr.rt_mlt_cd,
          abr.bnft_rt_typ_cd,
          abr.dsply_on_enrt_flag,
          abr.comp_lvl_fctr_id,
          abr.actl_prem_id,
          abr.input_value_id,
          abr.element_type_id
   from ben_acty_base_rt_f abr,
        ben_plip_f plp
   where plp.pl_id   = p_pl_id
   and   plp.pgm_id   = p_pgm_id
   and   p_effective_date between
         plp.effective_start_date and
         plp.effective_end_date
   and   plp.plip_id = abr.plip_id
   and   acty_base_rt_stat_cd = 'A'
   and   abr.acty_typ_cd like 'PRD%'
   and   p_effective_date between
         abr.effective_start_date and
         abr.effective_end_date;

   --
   cursor c_rslt (p_prtt_enrt_rslt_id number) is
     select pgm_id
     from ben_prtt_enrt_rslt_f pen
     where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and pen.prtt_enrt_rslt_stat_cd is null;
   --
   l_acty_base_rt      c_abr_pl%rowtype;
  --



  --
  l_input_value_id        ben_acty_base_rt_f.input_value_id%type;
  l_element_type_id       ben_acty_base_rt_f.element_type_id%type ;
  l_proc varchar2(72) := g_package||'update_prtt_rmt_aprvd_pymt';
  l_object_version_number ben_prtt_rmt_aprvd_fr_pymt_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_rmt_aprvd_fr_pymt_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_rmt_aprvd_fr_pymt_f.effective_end_date%TYPE;
  l_submitter_person_id     number ;
  l_dummy_number            number ;
  l_pgm_id                  number;
  l_prtt_enrt_rslt_id       number;
  l_pl_id                   number;
  --Bug 5558175
  l_datetrack_mode varchar2(30);
  --Bug 5558175
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_prtt_rmt_aprvd_pymt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic

  open c_pry ;
  fetch c_pry into l_pry_rec ;
  close c_pry ;
  --
  l_object_version_number := p_object_version_number;

--Bug 5558175 : Datetrack functionality on the Reimbursement Payment block (PRY) should not be
--present and hence hard-coded datetrack_mode in update, delete to correction and zap respectively.
  l_datetrack_mode := hr_api.g_correction;
--End Bug 5558175
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_prtt_rmt_aprvd_pymt
    --
    ben_prtt_rmt_aprvd_pymt_bk2.update_prtt_rmt_aprvd_pymt_b
      (
       p_prtt_rmt_aprvd_fr_pymt_id      =>  p_prtt_rmt_aprvd_fr_pymt_id
      ,p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_apprvd_fr_pymt_num             =>  p_apprvd_fr_pymt_num
      ,p_adjmt_flag                     =>  p_adjmt_flag
      ,p_aprvd_fr_pymt_amt              =>  p_aprvd_fr_pymt_amt
      ,p_pymt_stat_cd                   =>  p_pymt_stat_cd
      ,p_pymt_stat_rsn_cd               =>  p_pymt_stat_rsn_cd
      ,p_pymt_stat_ovrdn_rsn_cd         =>  p_pymt_stat_ovrdn_rsn_cd
      ,p_pymt_stat_prr_to_ovrd_cd       =>  p_pymt_stat_prr_to_ovrd_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_element_entry_value_id         =>  p_element_entry_value_id
      ,p_pry_attribute_category         =>  p_pry_attribute_category
      ,p_pry_attribute1                 =>  p_pry_attribute1
      ,p_pry_attribute2                 =>  p_pry_attribute2
      ,p_pry_attribute3                 =>  p_pry_attribute3
      ,p_pry_attribute4                 =>  p_pry_attribute4
      ,p_pry_attribute5                 =>  p_pry_attribute5
      ,p_pry_attribute6                 =>  p_pry_attribute6
      ,p_pry_attribute7                 =>  p_pry_attribute7
      ,p_pry_attribute8                 =>  p_pry_attribute8
      ,p_pry_attribute9                 =>  p_pry_attribute9
      ,p_pry_attribute10                =>  p_pry_attribute10
      ,p_pry_attribute11                =>  p_pry_attribute11
      ,p_pry_attribute12                =>  p_pry_attribute12
      ,p_pry_attribute13                =>  p_pry_attribute13
      ,p_pry_attribute14                =>  p_pry_attribute14
      ,p_pry_attribute15                =>  p_pry_attribute15
      ,p_pry_attribute16                =>  p_pry_attribute16
      ,p_pry_attribute17                =>  p_pry_attribute17
      ,p_pry_attribute18                =>  p_pry_attribute18
      ,p_pry_attribute19                =>  p_pry_attribute19
      ,p_pry_attribute20                =>  p_pry_attribute20
      ,p_pry_attribute21                =>  p_pry_attribute21
      ,p_pry_attribute22                =>  p_pry_attribute22
      ,p_pry_attribute23                =>  p_pry_attribute23
      ,p_pry_attribute24                =>  p_pry_attribute24
      ,p_pry_attribute25                =>  p_pry_attribute25
      ,p_pry_attribute26                =>  p_pry_attribute26
      ,p_pry_attribute27                =>  p_pry_attribute27
      ,p_pry_attribute28                =>  p_pry_attribute28
      ,p_pry_attribute29                =>  p_pry_attribute29
      ,p_pry_attribute30                =>  p_pry_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => l_datetrack_mode --Bug 5558175
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_prtt_rmt_aprvd_pymt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_prtt_rmt_aprvd_pymt
    --
  end;
  --
  ben_pry_upd.upd
    (
     p_prtt_rmt_aprvd_fr_pymt_id     => p_prtt_rmt_aprvd_fr_pymt_id
    ,p_prtt_reimbmt_rqst_id          => p_prtt_reimbmt_rqst_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_apprvd_fr_pymt_num            => p_apprvd_fr_pymt_num
    ,p_adjmt_flag                    => p_adjmt_flag
    ,p_aprvd_fr_pymt_amt             => p_aprvd_fr_pymt_amt
    ,p_pymt_stat_cd                  => p_pymt_stat_cd
    ,p_pymt_stat_rsn_cd              => p_pymt_stat_rsn_cd
    ,p_pymt_stat_ovrdn_rsn_cd        => p_pymt_stat_ovrdn_rsn_cd
    ,p_pymt_stat_prr_to_ovrd_cd      => p_pymt_stat_prr_to_ovrd_cd
    ,p_business_group_id             => p_business_group_id
    ,p_element_entry_value_id        => p_element_entry_value_id
    ,p_pry_attribute_category        => p_pry_attribute_category
    ,p_pry_attribute1                => p_pry_attribute1
    ,p_pry_attribute2                => p_pry_attribute2
    ,p_pry_attribute3                => p_pry_attribute3
    ,p_pry_attribute4                => p_pry_attribute4
    ,p_pry_attribute5                => p_pry_attribute5
    ,p_pry_attribute6                => p_pry_attribute6
    ,p_pry_attribute7                => p_pry_attribute7
    ,p_pry_attribute8                => p_pry_attribute8
    ,p_pry_attribute9                => p_pry_attribute9
    ,p_pry_attribute10               => p_pry_attribute10
    ,p_pry_attribute11               => p_pry_attribute11
    ,p_pry_attribute12               => p_pry_attribute12
    ,p_pry_attribute13               => p_pry_attribute13
    ,p_pry_attribute14               => p_pry_attribute14
    ,p_pry_attribute15               => p_pry_attribute15
    ,p_pry_attribute16               => p_pry_attribute16
    ,p_pry_attribute17               => p_pry_attribute17
    ,p_pry_attribute18               => p_pry_attribute18
    ,p_pry_attribute19               => p_pry_attribute19
    ,p_pry_attribute20               => p_pry_attribute20
    ,p_pry_attribute21               => p_pry_attribute21
    ,p_pry_attribute22               => p_pry_attribute22
    ,p_pry_attribute23               => p_pry_attribute23
    ,p_pry_attribute24               => p_pry_attribute24
    ,p_pry_attribute25               => p_pry_attribute25
    ,p_pry_attribute26               => p_pry_attribute26
    ,p_pry_attribute27               => p_pry_attribute27
    ,p_pry_attribute28               => p_pry_attribute28
    ,p_pry_attribute29               => p_pry_attribute29
    ,p_pry_attribute30               => p_pry_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => l_datetrack_mode --Bug 5558175
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_prtt_rmt_aprvd_pymt
    --
    ben_prtt_rmt_aprvd_pymt_bk2.update_prtt_rmt_aprvd_pymt_a
      (
       p_prtt_rmt_aprvd_fr_pymt_id      =>  p_prtt_rmt_aprvd_fr_pymt_id
      ,p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_apprvd_fr_pymt_num             =>  p_apprvd_fr_pymt_num
      ,p_adjmt_flag                     =>  p_adjmt_flag
      ,p_aprvd_fr_pymt_amt              =>  p_aprvd_fr_pymt_amt
      ,p_pymt_stat_cd                   =>  p_pymt_stat_cd
      ,p_pymt_stat_rsn_cd               =>  p_pymt_stat_rsn_cd
      ,p_pymt_stat_ovrdn_rsn_cd         =>  p_pymt_stat_ovrdn_rsn_cd
      ,p_pymt_stat_prr_to_ovrd_cd       =>  p_pymt_stat_prr_to_ovrd_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_element_entry_value_id         =>  p_element_entry_value_id
      ,p_pry_attribute_category         =>  p_pry_attribute_category
      ,p_pry_attribute1                 =>  p_pry_attribute1
      ,p_pry_attribute2                 =>  p_pry_attribute2
      ,p_pry_attribute3                 =>  p_pry_attribute3
      ,p_pry_attribute4                 =>  p_pry_attribute4
      ,p_pry_attribute5                 =>  p_pry_attribute5
      ,p_pry_attribute6                 =>  p_pry_attribute6
      ,p_pry_attribute7                 =>  p_pry_attribute7
      ,p_pry_attribute8                 =>  p_pry_attribute8
      ,p_pry_attribute9                 =>  p_pry_attribute9
      ,p_pry_attribute10                =>  p_pry_attribute10
      ,p_pry_attribute11                =>  p_pry_attribute11
      ,p_pry_attribute12                =>  p_pry_attribute12
      ,p_pry_attribute13                =>  p_pry_attribute13
      ,p_pry_attribute14                =>  p_pry_attribute14
      ,p_pry_attribute15                =>  p_pry_attribute15
      ,p_pry_attribute16                =>  p_pry_attribute16
      ,p_pry_attribute17                =>  p_pry_attribute17
      ,p_pry_attribute18                =>  p_pry_attribute18
      ,p_pry_attribute19                =>  p_pry_attribute19
      ,p_pry_attribute20                =>  p_pry_attribute20
      ,p_pry_attribute21                =>  p_pry_attribute21
      ,p_pry_attribute22                =>  p_pry_attribute22
      ,p_pry_attribute23                =>  p_pry_attribute23
      ,p_pry_attribute24                =>  p_pry_attribute24
      ,p_pry_attribute25                =>  p_pry_attribute25
      ,p_pry_attribute26                =>  p_pry_attribute26
      ,p_pry_attribute27                =>  p_pry_attribute27
      ,p_pry_attribute28                =>  p_pry_attribute28
      ,p_pry_attribute29                =>  p_pry_attribute29
      ,p_pry_attribute30                =>  p_pry_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => l_datetrack_mode --Bug 5558175
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_prtt_rmt_aprvd_pymt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_prtt_rmt_aprvd_pymt
    --
  end;
  --

  if nvl(l_pry_rec.aprvd_fr_pymt_amt,0) <> nvl(p_aprvd_fr_pymt_amt,0) then

      open  c_old_prc ;
      fetch c_old_prc into l_submitter_person_id, l_pl_id, l_prtt_enrt_rslt_id;
      close c_old_prc ;

     /*
      --update benr_prtt_rt_val
      ben_prtt_rt_val_api.update_prtt_rt_val(
          p_prtt_rt_val_id                 => l_prv_rec.prtt_rt_val_id
         ,p_rt_end_dt                      => hr_api.g_eot
         ,p_acty_base_rt_id                => l_prv_rec.acty_base_rt_id
         ,p_input_value_id                 => l_input_value_id
         ,p_element_type_id                => l_element_type_id
         ,p_person_id                      => l_submitter_person_id
         ,p_ended_per_in_ler_id            => null
         ,p_rt_val                         => p_aprvd_fr_pymt_amt
         ,p_business_group_id              => l_prv_rec.business_group_id
         ,p_object_version_number          => l_prv_rec.object_version_number
         ,p_effective_date                 => p_effective_date
        );
    */
    -- delete the element and create a new element
    --
    open c_rslt (l_prtt_enrt_rslt_id);
    fetch c_rslt into l_pgm_id;
    close c_rslt;
    --
    open c_abr_plip(l_pl_id,l_pgm_id);
    fetch c_abr_plip into l_acty_base_rt;
    if c_abr_plip%notfound then
     open c_abr_pl(l_pl_id) ;
     fetch c_abr_pl into l_acty_base_rt ;
     if c_abr_pl%notfound then
        close c_abr_pl;
        close c_abr_plip ;
        fnd_message.set_name('BEN','BEN_92697_NO_REMBMT_RATE');
        fnd_message.raise_error;
     end if ;
     close c_abr_pl;
    end if;
    close c_abr_plip;
    --
    if l_pry_rec.element_entry_value_id is not null then
      --
      ben_element_entry.end_reimburse_element
                        (p_validate  => p_validate
                        ,p_business_group_id => p_business_group_id
                        ,p_person_id  => l_submitter_person_id
                       ,p_prtt_reimbmt_rqst_id => p_prtt_reimbmt_rqst_id
                        ,p_prtt_rmt_aprvd_fr_pymt_id => p_prtt_rmt_aprvd_fr_pymt_id
                        ,p_effective_date => p_effective_date
                        ,p_element_entry_value_id => l_pry_rec.element_entry_value_id );
    end if;
    --
    --bug#5523456
    if l_acty_base_rt.element_type_id is not null then
      --
      ben_element_entry.create_reimburse_element
       ( p_validate                   => p_validate
        ,p_person_id                  => l_submitter_person_id
        ,p_acty_base_rt_id            => l_acty_base_rt.acty_base_rt_id
        ,p_amt                        => p_aprvd_fr_pymt_amt
        ,p_business_group_id          => p_business_group_id
        ,p_effective_date             => p_effective_date
        ,p_prtt_reimbmt_rqst_id       => p_prtt_reimbmt_rqst_id
        ,p_input_value_id             => l_acty_base_rt.input_value_id
        ,p_element_type_id            => l_acty_base_rt.element_type_id
        ,p_pl_id                      => l_pl_id
        ,p_prtt_rmt_aprvd_fr_pymt_id  => p_prtt_rmt_aprvd_fr_pymt_id
        ,p_object_version_number      => l_object_version_number
         );
      --
    end if;



  end if ;



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
    ROLLBACK TO update_prtt_rmt_aprvd_pymt;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_prtt_rmt_aprvd_pymt;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_prtt_rmt_aprvd_pymt;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_prtt_rmt_aprvd_pymt >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_prtt_rmt_aprvd_pymt
  (p_validate                       in  boolean  default false
  ,p_prtt_rmt_aprvd_fr_pymt_id      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables


  cursor c_pry is
  select * From ben_prtt_rmt_aprvd_fr_pymt_f pry
  where p_effective_date between pry.effective_start_date
            and pry.effective_end_date
    and pry.prtt_rmt_aprvd_fr_pymt_id = p_prtt_rmt_aprvd_fr_pymt_id;
  --
  l_pry_rec  c_pry%rowtype;
  --
  cursor c_old_prc  is
   select prc.submitter_person_id
         ,prc.prtt_reimbmt_rqst_id
         ,prc.business_group_id
   from ben_prtt_reimbmt_rqst_f  prc ,
        ben_prtt_rmt_aprvd_fr_pymt_f pyr
   where prtt_rmt_aprvd_fr_pymt_id = p_prtt_rmt_aprvd_fr_pymt_id
     and prc.prtt_reimbmt_rqst_id  = pyr.prtt_reimbmt_rqst_id
     and p_effective_date between
         pyr.effective_start_date and
         pyr.effective_end_date
     and p_effective_date between
         prc.effective_start_date and
         prc.effective_end_date;



  --
  l_proc varchar2(72) := g_package||'delete_prtt_rmt_aprvd_pymt';
  l_object_version_number ben_prtt_rmt_aprvd_fr_pymt_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_rmt_aprvd_fr_pymt_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_rmt_aprvd_fr_pymt_f.effective_end_date%TYPE;
  l_submitter_person_id  number ;
  l_prtt_reimbmt_rqst_id number ;
  l_business_group_id    number;

--Bug 5558175
  l_datetrack_mode varchar2(30);
--End Bug 5558175
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_prtt_rmt_aprvd_pymt;
  --
  -- bug fix 2223214
  -- added old rec retrieval to before delete , previously it was after delete
  --
  open c_old_prc ;
  fetch c_old_prc
    into l_submitter_person_id,
         l_prtt_reimbmt_rqst_id,
         l_business_group_id;
  close  c_old_prc ;
  --
  -- end fix 2223214
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  open c_pry ;
  fetch c_pry into l_pry_rec ;
  close c_pry ;

  --
  l_object_version_number := p_object_version_number;

--Bug 5558175 : Datetrack functionality on the Reimbursement Payment block (PRY) should not be
--present and hence hard-coded datetrack_mode in update, delete to correction and zap respectively.
  l_datetrack_mode := hr_api.g_zap;
--End Bug 5558175
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_prtt_rmt_aprvd_pymt
    --
    ben_prtt_rmt_aprvd_pymt_bk3.delete_prtt_rmt_aprvd_pymt_b
      (
       p_prtt_rmt_aprvd_fr_pymt_id      =>  p_prtt_rmt_aprvd_fr_pymt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => l_datetrack_mode --Bug 5558175
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_prtt_rmt_aprvd_pymt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_prtt_rmt_aprvd_pymt
    --
  end;
  --
  ben_pry_del.del
    (
     p_prtt_rmt_aprvd_fr_pymt_id     => p_prtt_rmt_aprvd_fr_pymt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => l_datetrack_mode --Bug 5558175
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_prtt_rmt_aprvd_pymt
    --
    ben_prtt_rmt_aprvd_pymt_bk3.delete_prtt_rmt_aprvd_pymt_a
      (
       p_prtt_rmt_aprvd_fr_pymt_id      =>  p_prtt_rmt_aprvd_fr_pymt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => l_datetrack_mode --Bug 5558175
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_prtt_rmt_aprvd_pymt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_prtt_rmt_aprvd_pymt
    --
  end;
  --
  -- Delete the prt_rt_rate
  -- before deleting the run result to be validated
  -- if the run result exist the logic to be decided

  /*
  open c_prv(l_prtt_reimbmt_rqst_id ) ;
  fetch c_prv into l_prv_rec ;
  close c_prv ;

  ben_prtt_rt_val_api.delete_prtt_rt_val(
              --   p_validate                   => p_validate
                p_prtt_rt_val_id                => l_prv_rec.prtt_rt_val_id
                --,p_enrt_rt_id                 => l_prv_rec.enrt_rt_id
                ,p_person_id                    => l_submitter_person_id
                ,p_business_group_id            => l_prv_rec.business_group_id
                ,p_object_version_number        => l_prv_rec.object_version_number
                ,p_effective_date               => p_effective_date );

  */

  ben_element_entry.end_reimburse_element
                        (p_validate  => p_validate
                        ,p_business_group_id => l_business_group_id
                        ,p_person_id  => l_submitter_person_id
                        ,p_prtt_reimbmt_rqst_id => l_prtt_reimbmt_rqst_id
                        ,p_prtt_rmt_aprvd_fr_pymt_id => p_prtt_rmt_aprvd_fr_pymt_id
                        ,p_effective_date => p_effective_date
                        ,p_element_entry_value_id => l_pry_rec.element_entry_value_id );


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
    ROLLBACK TO delete_prtt_rmt_aprvd_pymt;
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
    ROLLBACK TO delete_prtt_rmt_aprvd_pymt;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_prtt_rmt_aprvd_pymt;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_prtt_rmt_aprvd_fr_pymt_id                   in     number
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
  ben_pry_shd.lck
    (
      p_prtt_rmt_aprvd_fr_pymt_id                 => p_prtt_rmt_aprvd_fr_pymt_id
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
end ben_prtt_rmt_aprvd_pymt_api;

/
