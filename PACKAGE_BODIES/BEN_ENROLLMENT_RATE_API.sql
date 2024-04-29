--------------------------------------------------------
--  DDL for Package Body BEN_ENROLLMENT_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENROLLMENT_RATE_API" as
/* $Header: beecrapi.pkb 115.22 2004/03/23 12:43:03 ikasire ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Enrollment_Rate_api.';
--
-- ---------------------------------------------------------------------------
-- |----------------------------< person_details >----------------------------|
-- ----------------------------------------------------------------------------
--

Procedure person_details(p_elig_per_elctbl_chc_id    in number
                     ,p_effective_date            in date
                     ,p_person_name               out nocopy varchar2
)is
  --
  l_proc         varchar2(72) := g_package||'person_details';
  l_person_name  per_all_people_f.full_name%type;
  --
  cursor c_person is
   select full_name
   from per_all_people_f per
        ,ben_per_in_ler pil
        ,ben_elig_per_elctbl_chc epe
   where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
   and epe.per_in_ler_id = pil.per_in_ler_id
   and pil.person_id = per.person_id
   and p_effective_date between per.EFFECTIVE_START_DATE and per.EFFECTIVE_END_DATE;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_person;
  fetch c_person into l_person_name;
  close c_person;
  --
  p_person_name := l_person_name;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End person_details;
--

--
-- ---------------------------------------------------------------------------
-- |----------------------------< chk_perf_min_max >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the amount value and issued value is
--   between minimum and maximum for that Rate
--
-- Pre Conditions
--  p_perf_min_max_edit should be 'Y'
--
-- In Parameters
--   p_val                   Defined Amount value
--   p_iss_val               Defined issued Amount value
--   p_mx_elcn_val           Defined min value
--   p_mn_elcn_val           Defined min value
--   p_enrt_rt_id            PK of record being inserted or updated
--   p_object_version_number Object version number of record being
--                           inserted or updated.
--   p_incrmt_elcn_val       Defined increment value
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--  Private
--
Procedure chk_perf_min_max(p_val                       in number
                          ,p_iss_val                   in number
                          ,p_mx_elcn_val               in number
                          ,p_mn_elcn_val               in number
                          ,p_enrt_rt_id                in number
                          ,p_object_version_number     in number
                          ,p_elig_per_elctbl_chc_id    in number
                          ,p_effective_date            in date
                          ,p_incrmt_elcn_val           in number
)is
  --
  l_proc         varchar2(72) := g_package||'chk_perf_min_max';
  l_api_updating boolean;
  l_person_name  per_all_people_f.full_name%type;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('p_val: '||p_val, 5);
  hr_utility.set_location('p_iss_val: '||p_iss_val, 5);
  hr_utility.set_location('p_mx_elcn_val:'||p_mx_elcn_val, 5);
  hr_utility.set_location('p_mn_elcn_val:'||p_mn_elcn_val, 5);
  hr_utility.set_location('p_incrmt_elcn_val:'||p_incrmt_elcn_val, 5);
hr_utility.set_location('l_person_name:'||l_person_name, 5);
  --
  person_details(p_elig_per_elctbl_chc_id    => p_elig_per_elctbl_chc_id
                     ,p_effective_date    => p_effective_date
                     ,p_person_name       => l_person_name);

hr_utility.set_location('l_person_name:'||l_person_name, 5);
  --
  if (p_val is not null and p_val <> hr_api.g_number)and
     (p_mx_elcn_val is not null and  p_mx_elcn_val <> hr_api.g_number)
  then
      --
      if p_val > p_mx_elcn_val then
         --
         fnd_message.set_name('BEN','BEN_92984_CWB_VAL_NOT_IN_RANGE');
         fnd_message.set_token('VAL',p_val);
         fnd_message.set_token('MIN',p_mn_elcn_val);
         fnd_message.set_token('MAX',p_mx_elcn_val);
         fnd_message.set_token('PERSON',l_person_name);
         fnd_message.raise_error;
         --
      end if;
      --
  end if;
  --
  if (p_val is not null and p_val <> hr_api.g_number)and
     (p_mn_elcn_val is not null and  p_mn_elcn_val <> hr_api.g_number)
  then
      --
      if p_val < p_mn_elcn_val then
         --
         fnd_message.set_name('BEN','BEN_92984_CWB_VAL_NOT_IN_RANGE');
         fnd_message.set_token('VAL',p_val);
         fnd_message.set_token('MIN',p_mn_elcn_val);
         fnd_message.set_token('MAX',p_mx_elcn_val);
         fnd_message.set_token('PERSON',l_person_name);
         fnd_message.raise_error;
         --
      end if;
      --
  end if;
  --
  if (p_iss_val is not null and p_iss_val <> hr_api.g_number)and
     (p_mx_elcn_val is not null and  p_mx_elcn_val <> hr_api.g_number)
  then
      --
      if p_iss_val > p_mx_elcn_val then
         --
         fnd_message.set_name('BEN','BEN_92984_CWB_VAL_NOT_IN_RANGE');
         fnd_message.set_token('VAL',p_iss_val);
         fnd_message.set_token('MIN',p_mn_elcn_val);
         fnd_message.set_token('MAX',p_mx_elcn_val);
         fnd_message.set_token('PERSON',l_person_name);
         fnd_message.raise_error;
         --
      end if;
      --
  end if;
  --
  if (p_iss_val is not null and p_iss_val <> hr_api.g_number)and
     (p_mn_elcn_val is not null and  p_mn_elcn_val <> hr_api.g_number)
  then
      --
      if p_iss_val < p_mn_elcn_val then
         --
         fnd_message.set_name('BEN','BEN_92984_CWB_VAL_NOT_IN_RANGE');
         fnd_message.set_token('VAL',p_iss_val);
         fnd_message.set_token('MIN',p_mn_elcn_val);
         fnd_message.set_token('MAX',p_mx_elcn_val);
         fnd_message.set_token('PERSON',l_person_name);
         fnd_message.raise_error;
         --
      end if;
      --
  end if;
  --
  if (p_iss_val is not null and p_iss_val <> hr_api.g_number)and
     (p_incrmt_elcn_val is not null and  p_incrmt_elcn_val <> hr_api.g_number)
  then
      --
      if (mod(p_iss_val,p_incrmt_elcn_val)<>0) then
        --
        -- raise error is not multiple of increment
        --
        fnd_message.set_name('BEN','BEN_92985_CWB_VAL_NOT_INCRMNT');
        fnd_message.set_token('VAL',p_iss_val);
        fnd_message.set_token('INCREMENT', p_incrmt_elcn_val);
        fnd_message.set_token('PERSON',l_person_name);
        fnd_message.raise_error;
        --
      end if;
      --
  end if;
  --
  if (p_val is not null and p_val <> hr_api.g_number)and
     (p_incrmt_elcn_val is not null and  p_incrmt_elcn_val <> hr_api.g_number)
  then
      --
      if (mod(p_val,p_incrmt_elcn_val)<>0) then
        --
        -- raise error is not multiple of increment
        --
        fnd_message.set_name('BEN','BEN_92985_CWB_VAL_NOT_INCRMNT');
        fnd_message.set_token('VAL',p_val);
        fnd_message.set_token('INCREMENT', p_incrmt_elcn_val);
        fnd_message.set_token('PERSON',l_person_name);
        fnd_message.raise_error;
        --
      end if;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_perf_min_max;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Enrollment_Rate >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Enrollment_Rate
  ( p_validate                    in  boolean default false,
	p_enrt_rt_id                  out nocopy NUMBER,
	p_ordr_num			    in number     default null,
	p_acty_typ_cd                 in  VARCHAR2  DEFAULT NULL,
	p_tx_typ_cd                   in  VARCHAR2  DEFAULT NULL,
	p_ctfn_rqd_flag               in  VARCHAR2  DEFAULT 'N',
	p_dflt_flag                   in  VARCHAR2  DEFAULT 'N',
	p_dflt_pndg_ctfn_flag         in  VARCHAR2  DEFAULT 'N',
	p_dsply_on_enrt_flag          in  VARCHAR2  DEFAULT 'N',
	p_use_to_calc_net_flx_cr_flag in  VARCHAR2  DEFAULT 'N',
	p_entr_val_at_enrt_flag       in  VARCHAR2  DEFAULT 'N',
	p_asn_on_enrt_flag            in  VARCHAR2  DEFAULT 'N',
	p_rl_crs_only_flag            in  VARCHAR2  DEFAULT 'N',
	p_dflt_val                    in  NUMBER    DEFAULT NULL,
	p_ann_val                     in  NUMBER    DEFAULT NULL,
	p_ann_mn_elcn_val             in  NUMBER    DEFAULT NULL,
	p_ann_mx_elcn_val             in  NUMBER    DEFAULT NULL,
	p_val                         in  NUMBER    DEFAULT NULL,
	p_nnmntry_uom                 in  VARCHAR2  DEFAULT NULL,
	p_mx_elcn_val                 in  NUMBER    DEFAULT NULL,
	p_mn_elcn_val                 in  NUMBER    DEFAULT NULL,
	p_incrmt_elcn_val             in  NUMBER    DEFAULT NULL,
	p_cmcd_acty_ref_perd_cd       in  VARCHAR2  DEFAULT NULL,
	p_cmcd_mn_elcn_val            in  NUMBER    DEFAULT NULL,
	p_cmcd_mx_elcn_val            in  NUMBER    DEFAULT NULL,
	p_cmcd_val                    in  NUMBER    DEFAULT NULL,
	p_cmcd_dflt_val               in  NUMBER    DEFAULT NULL,
	p_rt_usg_cd                   in  VARCHAR2  DEFAULT NULL,
	p_ann_dflt_val                in  NUMBER    DEFAULT NULL,
	p_bnft_rt_typ_cd              in  VARCHAR2  DEFAULT NULL,
	p_rt_mlt_cd                   in  VARCHAR2  DEFAULT NULL,
	p_dsply_mn_elcn_val           in  NUMBER    DEFAULT NULL,
	p_dsply_mx_elcn_val           in  NUMBER    DEFAULT NULL,
	p_entr_ann_val_flag           in  VARCHAR2  DEFAULT 'N',
	p_rt_strt_dt                  in  DATE      DEFAULT NULL,
	p_rt_strt_dt_cd               in  VARCHAR2  DEFAULT NULL,
	p_rt_strt_dt_rl               in  NUMBER    DEFAULT NULL,
	p_rt_typ_cd                   in  VARCHAR2  DEFAULT NULL,
	p_elig_per_elctbl_chc_id      in  NUMBER    DEFAULT NULL,
	p_acty_base_rt_id             in  NUMBER    DEFAULT NULL,
	p_spcl_rt_enrt_rt_id          in  NUMBER    DEFAULT NULL,
	p_enrt_bnft_id                in  NUMBER    DEFAULT NULL,
	p_prtt_rt_val_id              in  NUMBER    DEFAULT NULL,
	p_decr_bnft_prvdr_pool_id     in  NUMBER    DEFAULT NULL,
	p_cvg_amt_calc_mthd_id        in  NUMBER    DEFAULT NULL,
	p_actl_prem_id                in  NUMBER    DEFAULT NULL,
	p_comp_lvl_fctr_id            in  NUMBER    DEFAULT NULL,
	p_ptd_comp_lvl_fctr_id        in  NUMBER    DEFAULT NULL,
	p_clm_comp_lvl_fctr_id        in  NUMBER    DEFAULT NULL,
	p_business_group_id           in  NUMBER,
        --cwb
        p_perf_min_max_edit           in  VARCHAR2  DEFAULT NULL,
        p_iss_val                     in  number    DEFAULT NULL,
        p_val_last_upd_date           in  date      DEFAULT NULL,
        p_val_last_upd_person_id      in  number    DEFAULT NULL,
        --cwb
        p_pp_in_yr_used_num           in  number    default null,
	p_ecr_attribute_category      in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute1              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute2              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute3              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute4              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute5              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute6              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute7              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute8              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute9              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute10             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute11             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute12             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute13             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute14             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute15             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute16             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute17             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute18             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute19             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute20             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute21             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute22             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute23             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute24             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute25             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute26             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute27             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute28             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute29             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute30             in  VARCHAR2  DEFAULT NULL,
    p_request_id                  in  NUMBER    DEFAULT NULL,
    p_program_application_id      in  NUMBER    DEFAULT NULL,
    p_program_id                  in  NUMBER    DEFAULT NULL,
    p_program_update_date         in  DATE      DEFAULT NULL,
    p_object_version_number       out nocopy NUMBER,
    p_effective_date              in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_enrt_rt_id ben_enrt_rt.enrt_rt_id%TYPE;
  l_proc varchar2(72) := g_package||'create_Enrollment_Rate';
  l_object_version_number ben_enrt_rt.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Enrollment_Rate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Enrollment_Rate
    --
    ben_Enrollment_Rate_bk1.create_Enrollment_Rate_b
      (
       p_enrt_rt_id                   =>  l_enrt_rt_id
      ,p_ordr_num                    =>  p_ordr_num
      ,p_acty_typ_cd                  =>  p_acty_typ_cd
      ,p_tx_typ_cd                    =>  p_tx_typ_cd
      ,p_ctfn_rqd_flag                =>  p_ctfn_rqd_flag
      ,p_dflt_flag                    =>  p_dflt_flag
      ,p_dflt_pndg_ctfn_flag          =>  p_dflt_pndg_ctfn_flag
      ,p_dsply_on_enrt_flag           =>  p_dsply_on_enrt_flag
      ,p_use_to_calc_net_flx_cr_flag  =>  p_use_to_calc_net_flx_cr_flag
      ,p_entr_val_at_enrt_flag        =>  p_entr_val_at_enrt_flag
      ,p_asn_on_enrt_flag             =>  p_asn_on_enrt_flag
      ,p_rl_crs_only_flag             =>  p_rl_crs_only_flag
      ,p_dflt_val                     =>  p_dflt_val
      ,p_ann_val                      =>  p_ann_val
      ,p_ann_mn_elcn_val              =>  p_ann_mn_elcn_val
      ,p_ann_mx_elcn_val              =>  p_ann_mx_elcn_val
      ,p_val                          =>  p_val
      ,p_nnmntry_uom                  =>  p_nnmntry_uom
      ,p_mx_elcn_val                  =>  p_mx_elcn_val
      ,p_mn_elcn_val                  =>  p_mn_elcn_val
      ,p_incrmt_elcn_val              =>  p_incrmt_elcn_val
      ,p_cmcd_acty_ref_perd_cd        =>  p_cmcd_acty_ref_perd_cd
      ,p_cmcd_mn_elcn_val             =>  p_cmcd_mn_elcn_val
      ,p_cmcd_mx_elcn_val             =>  p_cmcd_mx_elcn_val
      ,p_cmcd_val                     =>  p_cmcd_val
      ,p_cmcd_dflt_val                =>  p_cmcd_dflt_val
      ,p_rt_usg_cd                    =>  p_rt_usg_cd
      ,p_ann_dflt_val                 =>  p_ann_dflt_val
      ,p_bnft_rt_typ_cd               =>  p_bnft_rt_typ_cd
      ,p_rt_mlt_cd                    =>  p_rt_mlt_cd
      ,p_dsply_mn_elcn_val            =>  p_dsply_mn_elcn_val
      ,p_dsply_mx_elcn_val            =>  p_dsply_mx_elcn_val
      ,p_entr_ann_val_flag            =>  p_entr_ann_val_flag
      ,p_rt_strt_dt                   =>  p_rt_strt_dt
      ,p_rt_strt_dt_cd                =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                =>  p_rt_strt_dt_rl
      ,p_rt_typ_cd                    =>  p_rt_typ_cd
      ,p_elig_per_elctbl_chc_id       =>  p_elig_per_elctbl_chc_id
      ,p_acty_base_rt_id              =>  p_acty_base_rt_id
      ,p_spcl_rt_enrt_rt_id           =>  p_spcl_rt_enrt_rt_id
      ,p_enrt_bnft_id                 =>  p_enrt_bnft_id
      ,p_prtt_rt_val_id               =>  p_prtt_rt_val_id
      ,p_decr_bnft_prvdr_pool_id      =>  p_decr_bnft_prvdr_pool_id
      ,p_cvg_amt_calc_mthd_id         =>  p_cvg_amt_calc_mthd_id
      ,p_actl_prem_id                 =>  p_actl_prem_id
      ,p_comp_lvl_fctr_id             =>  p_comp_lvl_fctr_id
      ,p_ptd_comp_lvl_fctr_id         =>  p_ptd_comp_lvl_fctr_id
      ,p_clm_comp_lvl_fctr_id         =>  p_clm_comp_lvl_fctr_id
      ,p_business_group_id            =>  p_business_group_id
      --cwb
      ,p_iss_val                      =>  p_iss_val
      ,p_val_last_upd_date            =>  p_val_last_upd_date
      ,p_val_last_upd_person_id       =>  p_val_last_upd_person_id
      --cwb
      ,p_pp_in_yr_used_num            =>  p_pp_in_yr_used_num
      ,p_ecr_attribute_category       =>  p_ecr_attribute_category
      ,p_ecr_attribute1               =>  p_ecr_attribute1
      ,p_ecr_attribute2               =>  p_ecr_attribute2
      ,p_ecr_attribute3               =>  p_ecr_attribute3
      ,p_ecr_attribute4               =>  p_ecr_attribute4
      ,p_ecr_attribute5               =>  p_ecr_attribute5
      ,p_ecr_attribute6               =>  p_ecr_attribute6
      ,p_ecr_attribute7               =>  p_ecr_attribute7
      ,p_ecr_attribute8               =>  p_ecr_attribute8
      ,p_ecr_attribute9               =>  p_ecr_attribute9
      ,p_ecr_attribute10              =>  p_ecr_attribute10
      ,p_ecr_attribute11              =>  p_ecr_attribute11
      ,p_ecr_attribute12              =>  p_ecr_attribute12
      ,p_ecr_attribute13              =>  p_ecr_attribute13
      ,p_ecr_attribute14              =>  p_ecr_attribute14
      ,p_ecr_attribute15              =>  p_ecr_attribute15
      ,p_ecr_attribute16              =>  p_ecr_attribute16
      ,p_ecr_attribute17              =>  p_ecr_attribute17
      ,p_ecr_attribute18              =>  p_ecr_attribute18
      ,p_ecr_attribute19              =>  p_ecr_attribute19
      ,p_ecr_attribute20              =>  p_ecr_attribute20
      ,p_ecr_attribute21              =>  p_ecr_attribute21                           ,p_ecr_attribute22              =>  p_ecr_attribute22
      ,p_ecr_attribute23              =>  p_ecr_attribute23
      ,p_ecr_attribute24              =>  p_ecr_attribute24
      ,p_ecr_attribute25              =>  p_ecr_attribute25
      ,p_ecr_attribute26              =>  p_ecr_attribute26
      ,p_ecr_attribute27              =>  p_ecr_attribute27
      ,p_ecr_attribute28              =>  p_ecr_attribute28
      ,p_ecr_attribute29              =>  p_ecr_attribute29
      ,p_ecr_attribute30              =>  p_ecr_attribute30
      ,p_request_id                   =>  p_request_id
      ,p_program_application_id       =>  p_program_application_id
      ,p_program_id                   =>  p_program_id
      ,p_program_update_date          =>  p_program_update_date
      ,p_effective_date               =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Enrollment_Rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Enrollment_Rate
    --
  end;
  --
  ben_ecr_ins.ins
    (
       p_enrt_rt_id                   =>  l_enrt_rt_id
      ,p_ordr_num                    =>  p_ordr_num
      ,p_acty_typ_cd                  =>  p_acty_typ_cd
      ,p_tx_typ_cd                    =>  p_tx_typ_cd
      ,p_ctfn_rqd_flag                =>  p_ctfn_rqd_flag
      ,p_dflt_flag                    =>  p_dflt_flag
      ,p_dflt_pndg_ctfn_flag          =>  p_dflt_pndg_ctfn_flag
      ,p_dsply_on_enrt_flag           =>  p_dsply_on_enrt_flag
      ,p_use_to_calc_net_flx_cr_flag  =>  p_use_to_calc_net_flx_cr_flag
      ,p_entr_val_at_enrt_flag        =>  p_entr_val_at_enrt_flag
      ,p_asn_on_enrt_flag             =>  p_asn_on_enrt_flag
      ,p_rl_crs_only_flag             =>  p_rl_crs_only_flag
      ,p_dflt_val                     =>  p_dflt_val
      ,p_ann_val                      =>  p_ann_val
      ,p_ann_mn_elcn_val              =>  p_ann_mn_elcn_val
      ,p_ann_mx_elcn_val              =>  p_ann_mx_elcn_val
      ,p_val                          =>  p_val
      ,p_nnmntry_uom                  =>  p_nnmntry_uom
      ,p_mx_elcn_val                  =>  p_mx_elcn_val
      ,p_mn_elcn_val                  =>  p_mn_elcn_val
      ,p_incrmt_elcn_val              =>  p_incrmt_elcn_val
      ,p_cmcd_acty_ref_perd_cd        =>  p_cmcd_acty_ref_perd_cd
      ,p_cmcd_mn_elcn_val             =>  p_cmcd_mn_elcn_val
      ,p_cmcd_mx_elcn_val             =>  p_cmcd_mx_elcn_val
      ,p_cmcd_val                     =>  p_cmcd_val
      ,p_cmcd_dflt_val                =>  p_cmcd_dflt_val
      ,p_rt_usg_cd                    =>  p_rt_usg_cd
      ,p_ann_dflt_val                 =>  p_ann_dflt_val
      ,p_bnft_rt_typ_cd               =>  p_bnft_rt_typ_cd
      ,p_rt_mlt_cd                    =>  p_rt_mlt_cd
      ,p_dsply_mn_elcn_val            =>  p_dsply_mn_elcn_val
      ,p_dsply_mx_elcn_val            =>  p_dsply_mx_elcn_val
      ,p_entr_ann_val_flag            =>  p_entr_ann_val_flag
      ,p_rt_strt_dt                   =>  p_rt_strt_dt
      ,p_rt_strt_dt_cd                =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                =>  p_rt_strt_dt_rl
      ,p_rt_typ_cd                    =>  p_rt_typ_cd
      ,p_elig_per_elctbl_chc_id       =>  p_elig_per_elctbl_chc_id
      ,p_acty_base_rt_id              =>  p_acty_base_rt_id
      ,p_spcl_rt_enrt_rt_id           =>  p_spcl_rt_enrt_rt_id
      ,p_enrt_bnft_id                 =>  p_enrt_bnft_id
      ,p_prtt_rt_val_id               =>  p_prtt_rt_val_id
      ,p_decr_bnft_prvdr_pool_id      =>  p_decr_bnft_prvdr_pool_id
      ,p_cvg_amt_calc_mthd_id         =>  p_cvg_amt_calc_mthd_id
      ,p_actl_prem_id                 =>  p_actl_prem_id
      ,p_comp_lvl_fctr_id             =>  p_comp_lvl_fctr_id
      ,p_ptd_comp_lvl_fctr_id         =>  p_ptd_comp_lvl_fctr_id
      ,p_clm_comp_lvl_fctr_id         =>  p_clm_comp_lvl_fctr_id
      ,p_business_group_id            =>  p_business_group_id
      --cwb
      ,p_iss_val                      =>  p_iss_val
      ,p_val_last_upd_date            =>  p_val_last_upd_date
      ,p_val_last_upd_person_id       =>  p_val_last_upd_person_id
      --cwb
      ,p_pp_in_yr_used_num            =>  p_pp_in_yr_used_num
      ,p_ecr_attribute_category       =>  p_ecr_attribute_category
      ,p_ecr_attribute1               =>  p_ecr_attribute1
      ,p_ecr_attribute2               =>  p_ecr_attribute2
      ,p_ecr_attribute3               =>  p_ecr_attribute3
      ,p_ecr_attribute4               =>  p_ecr_attribute4
      ,p_ecr_attribute5               =>  p_ecr_attribute5
      ,p_ecr_attribute6               =>  p_ecr_attribute6
      ,p_ecr_attribute7               =>  p_ecr_attribute7
      ,p_ecr_attribute8               =>  p_ecr_attribute8
      ,p_ecr_attribute9               =>  p_ecr_attribute9
      ,p_ecr_attribute10              =>  p_ecr_attribute10
      ,p_ecr_attribute11              =>  p_ecr_attribute11
      ,p_ecr_attribute12              =>  p_ecr_attribute12
      ,p_ecr_attribute13              =>  p_ecr_attribute13
      ,p_ecr_attribute14              =>  p_ecr_attribute14
      ,p_ecr_attribute15              =>  p_ecr_attribute15
      ,p_ecr_attribute16              =>  p_ecr_attribute16
      ,p_ecr_attribute17              =>  p_ecr_attribute17
      ,p_ecr_attribute18              =>  p_ecr_attribute18
      ,p_ecr_attribute19              =>  p_ecr_attribute19
      ,p_ecr_attribute20              =>  p_ecr_attribute20
      ,p_ecr_attribute21              =>  p_ecr_attribute21                                  ,p_ecr_attribute22              =>  p_ecr_attribute22
      ,p_ecr_attribute23              =>  p_ecr_attribute23
      ,p_ecr_attribute24              =>  p_ecr_attribute24
      ,p_ecr_attribute25              =>  p_ecr_attribute25
      ,p_ecr_attribute26              =>  p_ecr_attribute26
      ,p_ecr_attribute27              =>  p_ecr_attribute27
      ,p_ecr_attribute28              =>  p_ecr_attribute28
      ,p_ecr_attribute29              =>  p_ecr_attribute29
      ,p_ecr_attribute30              =>  p_ecr_attribute30
      ,p_request_id                   =>  p_request_id
      ,p_program_application_id       =>  p_program_application_id
      ,p_program_id                   =>  p_program_id
      ,p_program_update_date          =>  p_program_update_date
      ,p_object_version_number        =>  p_object_version_number
      ,p_effective_date               =>  trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Enrollment_Rate
    --
    ben_Enrollment_Rate_bk1.create_Enrollment_Rate_a
      (
       p_enrt_rt_id                   =>  l_enrt_rt_id
      ,p_ordr_num                    =>  p_ordr_num
      ,p_acty_typ_cd                  =>  p_acty_typ_cd
      ,p_tx_typ_cd                    =>  p_tx_typ_cd
      ,p_ctfn_rqd_flag                =>  p_ctfn_rqd_flag
      ,p_dflt_flag                    =>  p_dflt_flag
      ,p_dflt_pndg_ctfn_flag          =>  p_dflt_pndg_ctfn_flag
      ,p_dsply_on_enrt_flag           =>  p_dsply_on_enrt_flag
      ,p_use_to_calc_net_flx_cr_flag  =>  p_use_to_calc_net_flx_cr_flag
      ,p_entr_val_at_enrt_flag        =>  p_entr_val_at_enrt_flag
      ,p_asn_on_enrt_flag             =>  p_asn_on_enrt_flag
      ,p_rl_crs_only_flag             =>  p_rl_crs_only_flag
      ,p_dflt_val                     =>  p_dflt_val
      ,p_ann_val                      =>  p_ann_val
      ,p_ann_mn_elcn_val              =>  p_ann_mn_elcn_val
      ,p_ann_mx_elcn_val              =>  p_ann_mx_elcn_val
      ,p_val                          =>  p_val
      ,p_nnmntry_uom                  =>  p_nnmntry_uom
      ,p_mx_elcn_val                  =>  p_mx_elcn_val
      ,p_mn_elcn_val                  =>  p_mn_elcn_val
      ,p_incrmt_elcn_val              =>  p_incrmt_elcn_val
      ,p_cmcd_acty_ref_perd_cd        =>  p_cmcd_acty_ref_perd_cd
      ,p_cmcd_mn_elcn_val             =>  p_cmcd_mn_elcn_val
      ,p_cmcd_mx_elcn_val             =>  p_cmcd_mx_elcn_val
      ,p_cmcd_val                     =>  p_cmcd_val
      ,p_cmcd_dflt_val                =>  p_cmcd_dflt_val
      ,p_rt_usg_cd                    =>  p_rt_usg_cd
      ,p_ann_dflt_val                 =>  p_ann_dflt_val
      ,p_bnft_rt_typ_cd               =>  p_bnft_rt_typ_cd
      ,p_rt_mlt_cd                    =>  p_rt_mlt_cd
      ,p_dsply_mn_elcn_val            =>  p_dsply_mn_elcn_val
      ,p_dsply_mx_elcn_val            =>  p_dsply_mx_elcn_val
      ,p_entr_ann_val_flag            =>  p_entr_ann_val_flag
      ,p_rt_strt_dt                   =>  p_rt_strt_dt
      ,p_rt_strt_dt_cd                =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                =>  p_rt_strt_dt_rl
      ,p_rt_typ_cd                    =>  p_rt_typ_cd
      ,p_elig_per_elctbl_chc_id       =>  p_elig_per_elctbl_chc_id
      ,p_acty_base_rt_id              =>  p_acty_base_rt_id
      ,p_spcl_rt_enrt_rt_id           =>  p_spcl_rt_enrt_rt_id
      ,p_enrt_bnft_id                 =>  p_enrt_bnft_id
      ,p_prtt_rt_val_id               =>  p_prtt_rt_val_id
      ,p_decr_bnft_prvdr_pool_id      =>  p_decr_bnft_prvdr_pool_id
      ,p_cvg_amt_calc_mthd_id         =>  p_cvg_amt_calc_mthd_id
      ,p_actl_prem_id                 =>  p_actl_prem_id
      ,p_comp_lvl_fctr_id             =>  p_comp_lvl_fctr_id
      ,p_ptd_comp_lvl_fctr_id         =>  p_ptd_comp_lvl_fctr_id
      ,p_clm_comp_lvl_fctr_id         =>  p_clm_comp_lvl_fctr_id
      ,p_business_group_id            =>  p_business_group_id
      --cwb
      ,p_iss_val                      =>  p_iss_val
      ,p_val_last_upd_date            =>  p_val_last_upd_date
      ,p_val_last_upd_person_id       =>  p_val_last_upd_person_id
      --cwb
      ,p_pp_in_yr_used_num            =>  p_pp_in_yr_used_num
      ,p_ecr_attribute_category       =>  p_ecr_attribute_category
      ,p_ecr_attribute1               =>  p_ecr_attribute1
      ,p_ecr_attribute2               =>  p_ecr_attribute2
      ,p_ecr_attribute3               =>  p_ecr_attribute3
      ,p_ecr_attribute4               =>  p_ecr_attribute4
      ,p_ecr_attribute5               =>  p_ecr_attribute5
      ,p_ecr_attribute6               =>  p_ecr_attribute6
      ,p_ecr_attribute7               =>  p_ecr_attribute7
      ,p_ecr_attribute8               =>  p_ecr_attribute8
      ,p_ecr_attribute9               =>  p_ecr_attribute9
      ,p_ecr_attribute10              =>  p_ecr_attribute10
      ,p_ecr_attribute11              =>  p_ecr_attribute11
      ,p_ecr_attribute12              =>  p_ecr_attribute12
      ,p_ecr_attribute13              =>  p_ecr_attribute13
      ,p_ecr_attribute14              =>  p_ecr_attribute14
      ,p_ecr_attribute15              =>  p_ecr_attribute15
      ,p_ecr_attribute16              =>  p_ecr_attribute16
      ,p_ecr_attribute17              =>  p_ecr_attribute17
      ,p_ecr_attribute18              =>  p_ecr_attribute18
      ,p_ecr_attribute19              =>  p_ecr_attribute19
      ,p_ecr_attribute20              =>  p_ecr_attribute20
      ,p_ecr_attribute21              =>  p_ecr_attribute21
      ,p_ecr_attribute22              =>  p_ecr_attribute22
      ,p_ecr_attribute23              =>  p_ecr_attribute23
      ,p_ecr_attribute24              =>  p_ecr_attribute24
      ,p_ecr_attribute25              =>  p_ecr_attribute25
      ,p_ecr_attribute26              =>  p_ecr_attribute26
      ,p_ecr_attribute27              =>  p_ecr_attribute27
      ,p_ecr_attribute28              =>  p_ecr_attribute28
      ,p_ecr_attribute29              =>  p_ecr_attribute29
      ,p_ecr_attribute30              =>  p_ecr_attribute30
      ,p_request_id                   =>  p_request_id
      ,p_program_application_id       =>  p_program_application_id
      ,p_program_id                   =>  p_program_id
      ,p_program_update_date          =>  p_program_update_date
      ,p_object_version_number        =>  p_object_version_number
      ,p_effective_date               =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Enrollment_Rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Enrollment_Rate
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
  p_enrt_rt_id := l_enrt_rt_id;
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
    ROLLBACK TO create_Enrollment_Rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_enrt_rt_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Enrollment_Rate;
    --
    p_enrt_rt_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end create_Enrollment_Rate;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_perf_ELIG_DPNT >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_perf_Enrollment_Rate
  (p_validate                    in  boolean default false,
	p_enrt_rt_id                  out nocopy NUMBER,
	p_ordr_num			    in number     default null,
	p_acty_typ_cd                 in  VARCHAR2  DEFAULT NULL,
	p_tx_typ_cd                   in  VARCHAR2  DEFAULT NULL,
	p_ctfn_rqd_flag               in  VARCHAR2  DEFAULT 'N',
	p_dflt_flag                   in  VARCHAR2  DEFAULT 'N',
	p_dflt_pndg_ctfn_flag         in  VARCHAR2  DEFAULT 'N',
	p_dsply_on_enrt_flag          in  VARCHAR2  DEFAULT 'N',
	p_use_to_calc_net_flx_cr_flag in  VARCHAR2  DEFAULT 'N',
	p_entr_val_at_enrt_flag       in  VARCHAR2  DEFAULT 'N',
	p_asn_on_enrt_flag            in  VARCHAR2  DEFAULT 'N',
	p_rl_crs_only_flag            in  VARCHAR2  DEFAULT 'N',
	p_dflt_val                    in  NUMBER    DEFAULT NULL,
	p_ann_val                     in  NUMBER    DEFAULT NULL,
	p_ann_mn_elcn_val             in  NUMBER    DEFAULT NULL,
	p_ann_mx_elcn_val             in  NUMBER    DEFAULT NULL,
	p_val                         in  NUMBER    DEFAULT NULL,
	p_nnmntry_uom                 in  VARCHAR2  DEFAULT NULL,
	p_mx_elcn_val                 in  NUMBER    DEFAULT NULL,
	p_mn_elcn_val                 in  NUMBER    DEFAULT NULL,
	p_incrmt_elcn_val             in  NUMBER    DEFAULT NULL,
	p_cmcd_acty_ref_perd_cd       in  VARCHAR2  DEFAULT NULL,
	p_cmcd_mn_elcn_val            in  NUMBER    DEFAULT NULL,
	p_cmcd_mx_elcn_val            in  NUMBER    DEFAULT NULL,
	p_cmcd_val                    in  NUMBER    DEFAULT NULL,
	p_cmcd_dflt_val               in  NUMBER    DEFAULT NULL,
	p_rt_usg_cd                   in  VARCHAR2  DEFAULT NULL,
	p_ann_dflt_val                in  NUMBER    DEFAULT NULL,
	p_bnft_rt_typ_cd              in  VARCHAR2  DEFAULT NULL,
	p_rt_mlt_cd                   in  VARCHAR2  DEFAULT NULL,
	p_dsply_mn_elcn_val           in  NUMBER    DEFAULT NULL,
	p_dsply_mx_elcn_val           in  NUMBER    DEFAULT NULL,
	p_entr_ann_val_flag           in  VARCHAR2,
	p_rt_strt_dt                  in  DATE      DEFAULT NULL,
	p_rt_strt_dt_cd               in  VARCHAR2  DEFAULT NULL,
	p_rt_strt_dt_rl               in  NUMBER    DEFAULT NULL,
	p_rt_typ_cd                   in  VARCHAR2  DEFAULT NULL,
	p_elig_per_elctbl_chc_id      in  NUMBER    DEFAULT NULL,
	p_acty_base_rt_id             in  NUMBER    DEFAULT NULL,
	p_spcl_rt_enrt_rt_id          in  NUMBER    DEFAULT NULL,
	p_enrt_bnft_id                in  NUMBER    DEFAULT NULL,
	p_prtt_rt_val_id              in  NUMBER    DEFAULT NULL,
	p_decr_bnft_prvdr_pool_id     in  NUMBER    DEFAULT NULL,
	p_cvg_amt_calc_mthd_id        in  NUMBER    DEFAULT NULL,
	p_actl_prem_id                in  NUMBER    DEFAULT NULL,
	p_comp_lvl_fctr_id            in  NUMBER    DEFAULT NULL,
	p_ptd_comp_lvl_fctr_id        in  NUMBER    DEFAULT NULL,
	p_clm_comp_lvl_fctr_id        in  NUMBER    DEFAULT NULL,
	p_business_group_id           in  NUMBER,
        --cwb
        p_perf_min_max_edit           in  VARCHAR2  DEFAULT NULL,
        p_iss_val                     in  number    DEFAULT NULL,
        p_val_last_upd_date           in  date      DEFAULT NULL,
        p_val_last_upd_person_id      in  number    DEFAULT NULL,
        --cwb
        p_pp_in_yr_used_num           in  number    default null,
	p_ecr_attribute_category      in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute1              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute2              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute3              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute4              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute5              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute6              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute7              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute8              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute9              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute10             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute11             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute12             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute13             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute14             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute15             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute16             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute17             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute18             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute19             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute20             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute21             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute22             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute23             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute24             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute25             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute26             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute27             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute28             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute29             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute30             in  VARCHAR2  DEFAULT NULL,
    p_request_id                  in  NUMBER    DEFAULT NULL,
    p_program_application_id      in  NUMBER    DEFAULT NULL,
    p_program_id                  in  NUMBER    DEFAULT NULL,
    p_program_update_date         in  DATE      DEFAULT NULL,
    p_object_version_number       out nocopy NUMBER,
    p_effective_date              in  date
  )
is
  --
  l_proc varchar2(72) := g_package||'create_perf_Enrollment_Rate';
  --
  -- Declare cursors and local variables
  --
  l_enrt_rt_id            ben_enrt_rt.enrt_rt_id%TYPE;
  l_object_version_number ben_enrt_rt.object_version_number%TYPE;
  --
  l_created_by            ben_enrt_rt.created_by%TYPE;
  l_creation_date         ben_enrt_rt.creation_date%TYPE;
  l_last_update_date      ben_enrt_rt.last_update_date%TYPE;
  l_last_updated_by       ben_enrt_rt.last_updated_by%TYPE;
  l_last_update_login     ben_enrt_rt.last_update_login%TYPE;
  --
  Cursor C_Sel1 is select ben_enrt_rt_s.nextval from sys.dual;
  --
  l_minmax_rec            ben_batch_dt_api.gtyp_dtsum_row;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_perf_Enrollment_Rate;
  --
  -- Insert the row
  --
  --   Set the object version number for the insert
  --
  l_object_version_number := 1;
  --
  ben_ecr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Select the next sequence number
  --
  hr_utility.set_location('Insert ECR: '||l_proc, 5);
  insert into ben_enrt_rt
    (enrt_rt_id
    ,ordr_num
    ,acty_typ_cd
    ,tx_typ_cd
    ,ctfn_rqd_flag
    ,dflt_flag
    ,dflt_pndg_ctfn_flag
    ,dsply_on_enrt_flag
    ,use_to_calc_net_flx_cr_flag
    ,entr_val_at_enrt_flag
    ,asn_on_enrt_flag
    ,rl_crs_only_flag
    ,dflt_val
    ,ann_val
    ,ann_mn_elcn_val
    ,ann_mx_elcn_val
    ,val
    ,nnmntry_uom
    ,mx_elcn_val
    ,mn_elcn_val
    ,incrmt_elcn_val
    ,cmcd_acty_ref_perd_cd
    ,cmcd_mn_elcn_val
    ,cmcd_mx_elcn_val
    ,cmcd_val
    ,cmcd_dflt_val
    ,rt_usg_cd
    ,ann_dflt_val
    ,bnft_rt_typ_cd
    ,rt_mlt_cd
    ,dsply_mn_elcn_val
    ,dsply_mx_elcn_val
    ,entr_ann_val_flag
    ,rt_strt_dt
    ,rt_strt_dt_cd
    ,rt_strt_dt_rl
    ,rt_typ_cd
    ,elig_per_elctbl_chc_id
    ,acty_base_rt_id
    ,spcl_rt_enrt_rt_id
    ,enrt_bnft_id
    ,prtt_rt_val_id
    ,decr_bnft_prvdr_pool_id
    ,cvg_amt_calc_mthd_id
    ,actl_prem_id
    ,comp_lvl_fctr_id
    ,ptd_comp_lvl_fctr_id
    ,clm_comp_lvl_fctr_id
    ,business_group_id
    --cwb
    ,iss_val
    ,val_last_upd_date
    ,val_last_upd_person_id
   --cwb
    ,ecr_attribute_category
    ,ecr_attribute1
    ,ecr_attribute2
    ,ecr_attribute3
    ,ecr_attribute4
    ,ecr_attribute5
    ,ecr_attribute6
    ,ecr_attribute7
    ,ecr_attribute8
    ,ecr_attribute9
    ,ecr_attribute10
    ,ecr_attribute11
    ,ecr_attribute12
    ,ecr_attribute13
    ,ecr_attribute14
    ,ecr_attribute15
    ,ecr_attribute16
    ,ecr_attribute17
    ,ecr_attribute18
    ,ecr_attribute19
    ,ecr_attribute20
    ,ecr_attribute21
    ,ecr_attribute22
    ,ecr_attribute23
    ,ecr_attribute24
    ,ecr_attribute25
    ,ecr_attribute26
    ,ecr_attribute27
    ,ecr_attribute28
    ,ecr_attribute29
    ,ecr_attribute30
    ,last_update_login
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,object_version_number
    )
  Values
  (ben_enrt_rt_s.nextval
  ,p_ordr_num
  ,p_acty_typ_cd
  ,p_tx_typ_cd
  ,p_ctfn_rqd_flag
  ,p_dflt_flag
  ,p_dflt_pndg_ctfn_flag
  ,p_dsply_on_enrt_flag
  ,p_use_to_calc_net_flx_cr_flag
  ,p_entr_val_at_enrt_flag
  ,p_asn_on_enrt_flag
  ,p_rl_crs_only_flag
  ,p_dflt_val
  ,p_ann_val
  ,p_ann_mn_elcn_val
  ,p_ann_mx_elcn_val
  ,p_val
  ,p_nnmntry_uom
  ,p_mx_elcn_val
  ,p_mn_elcn_val
  ,p_incrmt_elcn_val
  ,p_cmcd_acty_ref_perd_cd
  ,p_cmcd_mn_elcn_val
  ,p_cmcd_mx_elcn_val
  ,p_cmcd_val
  ,p_cmcd_dflt_val
  ,p_rt_usg_cd
  ,p_ann_dflt_val
  ,p_bnft_rt_typ_cd
  ,p_rt_mlt_cd
  ,p_dsply_mn_elcn_val
  ,p_dsply_mx_elcn_val
  ,p_entr_ann_val_flag
  ,p_rt_strt_dt
  ,p_rt_strt_dt_cd
  ,p_rt_strt_dt_rl
  ,p_rt_typ_cd
  ,p_elig_per_elctbl_chc_id
  ,p_acty_base_rt_id
  ,p_spcl_rt_enrt_rt_id
  ,p_enrt_bnft_id
  ,p_prtt_rt_val_id
  ,p_decr_bnft_prvdr_pool_id
  ,p_cvg_amt_calc_mthd_id
  ,p_actl_prem_id
  ,p_comp_lvl_fctr_id
  ,p_ptd_comp_lvl_fctr_id
  ,p_clm_comp_lvl_fctr_id
  ,p_business_group_id
  --cwb
  ,p_iss_val
  ,p_val_last_upd_date
  ,p_val_last_upd_person_id
  --cwb
  ,p_ecr_attribute_category
  ,p_ecr_attribute1
  ,p_ecr_attribute2
  ,p_ecr_attribute3
  ,p_ecr_attribute4
  ,p_ecr_attribute5
  ,p_ecr_attribute6
  ,p_ecr_attribute7
  ,p_ecr_attribute8
  ,p_ecr_attribute9
  ,p_ecr_attribute10
  ,p_ecr_attribute11
  ,p_ecr_attribute12
  ,p_ecr_attribute13
  ,p_ecr_attribute14
  ,p_ecr_attribute15
  ,p_ecr_attribute16
  ,p_ecr_attribute17
  ,p_ecr_attribute18
  ,p_ecr_attribute19
  ,p_ecr_attribute20
  ,p_ecr_attribute21
  ,p_ecr_attribute22
  ,p_ecr_attribute23
  ,p_ecr_attribute24
  ,p_ecr_attribute25
  ,p_ecr_attribute26
  ,p_ecr_attribute27
  ,p_ecr_attribute28
  ,p_ecr_attribute29
  ,p_ecr_attribute30
  ,l_last_update_login
  ,l_created_by
  ,l_creation_date
  ,l_last_updated_by
  ,l_last_update_date
  ,p_request_id
  ,p_program_application_id
  ,p_program_id
  ,p_program_update_date
  ,l_object_version_number
  ) RETURNING enrt_rt_id into l_enrt_rt_id;
  hr_utility.set_location('Dn Insert: '||l_proc, 5);
  --
  ben_ecr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_enrt_rt_id            := l_enrt_rt_id;
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
    ROLLBACK TO create_perf_Enrollment_Rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_enrt_rt_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_perf_Enrollment_Rate;
    --
    p_enrt_rt_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end create_perf_Enrollment_Rate;

-- ----------------------------------------------------------------------------
-- |------------------------< override_Enrollment_Rate >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE override_Enrollment_Rate
  (
        p_validate                    in boolean    default false,
        --
        p_person_id                   in  NUMBER,
        --
  	p_enrt_rt_id                  in  NUMBER,
  	p_ordr_num	              in number     default hr_api.g_number,
  	p_acty_typ_cd                 in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_tx_typ_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ctfn_rqd_flag               in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_flag                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_pndg_ctfn_flag         in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dsply_on_enrt_flag          in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_use_to_calc_net_flx_cr_flag in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_entr_val_at_enrt_flag       in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_asn_on_enrt_flag            in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rl_crs_only_flag            in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_val                    in  NUMBER    DEFAULT hr_api.g_number,
        --
        p_old_ann_val                 in  NUMBER    DEFAULT hr_api.g_number,
        --
  	p_ann_val                     in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_mn_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_mx_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
        --
        p_old_val                     in  NUMBER    DEFAULT hr_api.g_number,
        --
  	p_val                         in  NUMBER    DEFAULT hr_api.g_number,
  	p_nnmntry_uom                 in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_mx_elcn_val                 in  NUMBER    DEFAULT hr_api.g_number,
  	p_mn_elcn_val                 in  NUMBER    DEFAULT hr_api.g_number,
  	p_incrmt_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
        --
        p_acty_ref_perd_cd            in  VARCHAR2  DEFAULT hr_api.g_varchar2,
        --
  	p_cmcd_acty_ref_perd_cd       in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_cmcd_mn_elcn_val            in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_mx_elcn_val            in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_val                    in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_dflt_val               in  NUMBER    DEFAULT hr_api.g_number,
  	p_rt_usg_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ann_dflt_val                in  NUMBER    DEFAULT hr_api.g_number,
  	p_bnft_rt_typ_cd              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_mlt_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dsply_mn_elcn_val           in  NUMBER    DEFAULT hr_api.g_number,
  	p_dsply_mx_elcn_val           in  NUMBER    DEFAULT hr_api.g_number,
  	p_entr_ann_val_flag           in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_strt_dt                  in  DATE      DEFAULT hr_api.g_date,
  	p_rt_strt_dt_cd               in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_strt_dt_rl               in  NUMBER    DEFAULT hr_api.g_number,
  	p_rt_typ_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_elig_per_elctbl_chc_id      in  NUMBER    DEFAULT hr_api.g_number,
  	p_acty_base_rt_id             in  NUMBER    DEFAULT hr_api.g_number,
  	p_spcl_rt_enrt_rt_id          in  NUMBER    DEFAULT hr_api.g_number,
  	p_enrt_bnft_id                in  NUMBER    DEFAULT hr_api.g_number,
  	p_prtt_rt_val_id              in  NUMBER    DEFAULT hr_api.g_number,
  	p_decr_bnft_prvdr_pool_id     in  NUMBER    DEFAULT hr_api.g_number,
  	p_cvg_amt_calc_mthd_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_actl_prem_id                in  NUMBER    DEFAULT hr_api.g_number,
  	p_comp_lvl_fctr_id            in  NUMBER    DEFAULT hr_api.g_number,
  	p_ptd_comp_lvl_fctr_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_clm_comp_lvl_fctr_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_business_group_id           in  NUMBER    DEFAULT hr_api.g_number,
        --cwb
        p_perf_min_max_edit           in  VARCHAR2  DEFAULT NULL,
        p_iss_val                     in  number    DEFAULT hr_api.g_number,
        p_val_last_upd_date           in  date      DEFAULT hr_api.g_date,
        p_val_last_upd_person_id      in  number    DEFAULT hr_api.g_number,
        --cwb
        p_pp_in_yr_used_num           in  number    default hr_api.g_number,
  	p_ecr_attribute_category      in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute1              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute2              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute3              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute4              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute5              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute6              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute7              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute8              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute9              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute10             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute11             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute12             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute13             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute14             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute15             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute16             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute17             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute18             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute19             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute20             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute21             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute22             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute23             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute24             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute25             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute26             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute27             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute28             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute29             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute30             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_request_id                  in  NUMBER    DEFAULT hr_api.g_number,
    p_program_application_id      in  NUMBER    DEFAULT hr_api.g_number,
    p_program_id                  in  NUMBER    DEFAULT hr_api.g_number,
    p_program_update_date         in  DATE      DEFAULT hr_api.g_date,
    p_object_version_number       in out nocopy NUMBER,
    p_effective_date              in  date
  ) IS
  l_ann_val             number := p_ann_val;
  l_calc_ann_val        number ;
  l_val                 number := p_val;
  l_cmcd_val            number := p_cmcd_val;
/*
  l_payroll_id          number ;
  --
  cursor c_ass(p_person_id number,
             p_effective_date date  ) is
    select
      payroll_id
    from
      per_all_assignments_f ass
    where
      ass.person_id = p_person_id
    and p_effective_date between ass.effective_start_date and ass.effective_end_date
    and primary_flag = 'Y'
    and assignment_type in ( 'E','B' ) ;
*/
--
--GEVITY
 cursor c_abr(cv_acty_base_rt_id number)
 is select rate_periodization_rl
      from ben_acty_base_rt_f abr
     where abr.acty_base_rt_id = cv_acty_base_rt_id
       and p_effective_date between abr.effective_start_date
                                and abr.effective_end_date ;
 --
 l_rate_periodization_rl NUMBER;
 --
 l_dfnd_dummy number;
 l_ann_dummy  number;
 l_cmcd_dummy number;
 l_assignment_id                 per_all_assignments_f.assignment_id%type;
 l_payroll_id                    per_all_assignments_f.payroll_id%type;
 l_organization_id               per_all_assignments_f.organization_id%type;
 --END GEVITY
begin
--
  /*
  open c_ass(p_person_id,p_effective_date) ;
    --
    fetch c_ass into l_payroll_id ;
    --
  close c_ass;
  */
  ben_element_entry.get_abr_assignment
      (p_person_id       => p_person_id
      ,p_effective_date  => p_effective_date
      ,p_acty_base_rt_id => p_acty_base_rt_id
      ,p_organization_id => l_organization_id
      ,p_payroll_id      => l_payroll_id
      ,p_assignment_id   => l_assignment_id
      );
  --
  open c_abr(p_acty_base_rt_id) ;
    fetch c_abr into l_rate_periodization_rl ;
  close c_abr;
  --
  hr_utility.set_location(' p_val '||p_val ,99);
  hr_utility.set_location(' p_old_val'||p_old_val ,99);
  hr_utility.set_location(' p_ann_val '||p_ann_val ,99);
  hr_utility.set_location(' p_old_ann_val '||p_old_ann_val ,99);
  hr_utility.set_location(' p_cmcd_val '||p_cmcd_val ,99);
  --
  IF p_rt_typ_cd = 'PCT' then
    --
    if p_entr_ann_val_flag = 'Y' then
      --
      -- get values from annual value
      --
      if p_ann_val <> p_old_ann_val then
        --
        l_ann_val:=p_ann_val;
        l_val:=p_ann_val;
        l_cmcd_val:=p_ann_val;
        --
      end if;
      --
    else
      --
      if p_val <> p_old_val then
        --
        l_ann_val:=p_val;
        l_val:=p_val;
        l_cmcd_val:=p_val;
        --
      end if;
      --
    end if;
    --
  else -- If not PCT
    --
    if p_entr_ann_val_flag = 'Y' then
      --
      if p_ann_val <> p_old_ann_val then
        --
        -- use ann_val to drive other values
        hr_utility.set_location( 'Annula Flag  = Y ' ,99);
        --
        l_ann_val := p_ann_val ;
        --GEVITY
        IF l_rate_periodization_rl IS NOT NULL THEN
          --
          l_ann_dummy := l_ann_val;
          --
          ben_distribute_rates.periodize_with_rule
                  (p_formula_id             => l_rate_periodization_rl
                  ,p_effective_date         => p_effective_date
                  ,p_assignment_id          => l_assignment_id
                  ,p_convert_from_val       => l_ann_dummy
                  ,p_convert_from           => 'ANNUAL'
                  ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
                  ,p_acty_base_rt_id        => p_acty_base_rt_id
                  ,p_business_group_id      => p_business_group_id
                  ,p_enrt_rt_id             => p_enrt_rt_id
                  ,p_ann_val                => l_ann_val
                  ,p_cmcd_val               => l_cmcd_val
                  ,p_val                    => l_val
          );
          --
        ELSE
          --
          l_val := ben_distribute_rates.annual_to_period
                    (p_amount                  => l_ann_val,
                     p_enrt_rt_id              => p_enrt_rt_id,
                     p_acty_ref_perd_cd        => p_acty_ref_perd_cd,
                     p_business_group_id       => p_business_group_id,
                     p_effective_date          => p_effective_date,
                     p_complete_year_flag      => 'Y',
                     p_use_balance_flag        => 'Y',
                     p_payroll_id              => l_payroll_id);
          --
          l_calc_ann_val := ben_distribute_rates.period_to_annual
                    (p_amount                  => l_val,
                     p_enrt_rt_id              => p_enrt_rt_id,
                     p_acty_ref_perd_cd        => p_acty_ref_perd_cd,
                     p_business_group_id       => p_business_group_id,
                     p_effective_date          => p_effective_date,
                     p_complete_year_flag      => 'Y',
                     p_payroll_id              => l_payroll_id);
          --
          --
          l_cmcd_val := ben_distribute_rates.annual_to_period
                    (p_amount                  => l_calc_ann_val,
                     p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                     p_acty_ref_perd_cd        => p_cmcd_acty_ref_perd_cd,
                     p_business_group_id       => p_business_group_id,
                     p_effective_date          => p_effective_date,
          --           p_complete_year_flag      => 'Y',
                     p_payroll_id              => l_payroll_id);
          --
        END IF; --GEVITY
          hr_utility.set_location('l_calc_ann_val '||to_char(l_calc_ann_val), 319);
          hr_utility.set_location('p_cmcd_acty_ref_perd_cd '||p_cmcd_acty_ref_perd_cd, 319);
          hr_utility.set_location('l_cmcd_val '||l_cmcd_val , 319);
          --
      end if;
      --
    else
      --
      if p_val <> p_old_val then
        --
        l_val := p_val ;
        --GEVITY
        IF l_rate_periodization_rl IS NOT NULL THEN
          --
          l_dfnd_dummy := l_val;
          --
          ben_distribute_rates.periodize_with_rule
                  (p_formula_id             => l_rate_periodization_rl
                  ,p_effective_date         => p_effective_date
                  ,p_assignment_id          => l_assignment_id
                  ,p_convert_from_val       => l_dfnd_dummy
                  ,p_convert_from           => 'DEFINED'
                  ,p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id
                  ,p_acty_base_rt_id        => p_acty_base_rt_id
                  ,p_business_group_id      => p_business_group_id
                  ,p_enrt_rt_id             => p_enrt_rt_id
                  ,p_ann_val                => l_ann_val
                  ,p_cmcd_val               => l_cmcd_val
                  ,p_val                    => l_val
          );
          --
        ELSE
          --
          l_ann_val := ben_distribute_rates.period_to_annual
                    (p_amount                  => l_val,
                     p_enrt_rt_id              => p_enrt_rt_id,
                     p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                     p_acty_ref_perd_cd        => p_acty_ref_perd_cd,
                     p_business_group_id       => p_business_group_id,
                     p_effective_date          => p_effective_date,
                     p_complete_year_flag      => 'Y',
                     p_payroll_id              => l_payroll_id);

          --
          hr_utility.set_location( ' l_ann_val '||l_ann_val,99);
          hr_utility.set_location( ' l_payroll_id '||l_payroll_id,99);
          hr_utility.set_location( ' p_effective_date '||p_effective_date ,99);
          hr_utility.set_location( ' p_elig_per_elctbl_chc_id '||p_elig_per_elctbl_chc_id,99);
          --
          l_cmcd_val := ben_distribute_rates.annual_to_period
                    (p_amount                  => l_ann_val,
                     p_elig_per_elctbl_chc_id  => p_elig_per_elctbl_chc_id,
                     p_acty_ref_perd_cd        => p_cmcd_acty_ref_perd_cd,
                     p_business_group_id       => p_business_group_id,
                     p_effective_date          => p_effective_date,
                     p_complete_year_flag      => 'Y',
                     p_payroll_id              => l_payroll_id );

        --
        END IF; --GEVITY
      end if;
      --
    end if;
    --
  end if; -- PCT
     --
  --
  hr_utility.set_location(' l_val '||l_val ,99);
  hr_utility.set_location(' l_old_val'||p_old_val ,99);
  hr_utility.set_location(' l_ann_val '||l_ann_val ,99);
  hr_utility.set_location(' l_old_ann_val '||p_old_ann_val ,99);
  hr_utility.set_location(' l_cmcd_val '||l_cmcd_val ,99);
  --

     ben_Enrollment_Rate_api.update_Enrollment_Rate
         (
          p_validate                         => p_validate
         ,p_enrt_rt_id                       => p_enrt_rt_id
         ,p_ordr_num                       =>  p_ordr_num
         ,p_acty_typ_cd                      => p_acty_typ_cd
         ,p_tx_typ_cd                        => p_tx_typ_cd
         ,p_ctfn_rqd_flag                    => p_ctfn_rqd_flag
         ,p_dflt_flag                        => p_dflt_flag
         ,p_dflt_pndg_ctfn_flag              => p_dflt_pndg_ctfn_flag
         ,p_dsply_on_enrt_flag               => p_dsply_on_enrt_flag
         ,p_use_to_calc_net_flx_cr_flag      => p_use_to_calc_net_flx_cr_flag
         ,p_entr_val_at_enrt_flag            => p_entr_val_at_enrt_flag
         ,p_asn_on_enrt_flag                 => p_asn_on_enrt_flag
         ,p_rl_crs_only_flag                 => p_rl_crs_only_flag
         ,p_dflt_val                         => p_dflt_val
         ,p_ann_val                          => l_ann_val
         ,p_ann_mn_elcn_val                  => p_ann_mn_elcn_val
         ,p_ann_mx_elcn_val                  => p_ann_mx_elcn_val
         ,p_val                              => l_val
         ,p_nnmntry_uom                      => p_nnmntry_uom
         ,p_mx_elcn_val                      => p_mx_elcn_val
         ,p_mn_elcn_val                      => p_mn_elcn_val
         ,p_incrmt_elcn_val                  => p_incrmt_elcn_val
         ,p_cmcd_acty_ref_perd_cd            => p_cmcd_acty_ref_perd_cd
         ,p_cmcd_mn_elcn_val                 => p_cmcd_mn_elcn_val
         ,p_cmcd_mx_elcn_val                 => p_cmcd_mx_elcn_val
         ,p_cmcd_val                         => l_cmcd_val
         ,p_cmcd_dflt_val                    => p_cmcd_dflt_val
         ,p_rt_usg_cd                        => p_rt_usg_cd
         ,p_ann_dflt_val                     => p_ann_dflt_val
         ,p_bnft_rt_typ_cd                   => p_bnft_rt_typ_cd
         ,p_rt_mlt_cd                        => p_rt_mlt_cd
         ,p_dsply_mn_elcn_val                => p_dsply_mn_elcn_val
         ,p_dsply_mx_elcn_val                => p_dsply_mx_elcn_val
         ,p_entr_ann_val_flag                => p_entr_ann_val_flag
         ,p_rt_strt_dt                       => p_rt_strt_dt
         ,p_rt_strt_dt_cd                    => p_rt_strt_dt_cd
         ,p_rt_strt_dt_rl                    => p_rt_strt_dt_rl
         ,p_rt_typ_cd                        => p_rt_typ_cd
         ,p_elig_per_elctbl_chc_id           => p_elig_per_elctbl_chc_id
         ,p_acty_base_rt_id                  => p_acty_base_rt_id
         ,p_spcl_rt_enrt_rt_id               => p_spcl_rt_enrt_rt_id
         ,p_enrt_bnft_id                     => p_enrt_bnft_id
         ,p_prtt_rt_val_id                   => p_prtt_rt_val_id
         ,p_decr_bnft_prvdr_pool_id          => p_decr_bnft_prvdr_pool_id
         ,p_cvg_amt_calc_mthd_id             => p_cvg_amt_calc_mthd_id
         ,p_actl_prem_id                     => p_actl_prem_id
         ,p_comp_lvl_fctr_id                 => p_comp_lvl_fctr_id
         ,p_ptd_comp_lvl_fctr_id             => p_ptd_comp_lvl_fctr_id
         ,p_clm_comp_lvl_fctr_id             => p_clm_comp_lvl_fctr_id
         ,p_business_group_id                => p_business_group_id
         ,p_perf_min_max_edit                => p_perf_min_max_edit
         ,p_iss_val                          => p_iss_val
         ,p_val_last_upd_date                => p_val_last_upd_date
         ,p_val_last_upd_person_id           => p_val_last_upd_person_id
         ,p_ecr_attribute_category           => p_ecr_attribute_category
         ,p_ecr_attribute1                   => p_ecr_attribute1
         ,p_ecr_attribute2                   => p_ecr_attribute2
         ,p_ecr_attribute3                   => p_ecr_attribute3
         ,p_ecr_attribute4                   => p_ecr_attribute4
         ,p_ecr_attribute5                   => p_ecr_attribute5
         ,p_ecr_attribute6                   => p_ecr_attribute6
         ,p_ecr_attribute7                   => p_ecr_attribute7
         ,p_ecr_attribute8                   => p_ecr_attribute8
         ,p_ecr_attribute9                   => p_ecr_attribute9
         ,p_ecr_attribute10                  => p_ecr_attribute10
         ,p_ecr_attribute11                  => p_ecr_attribute11
         ,p_ecr_attribute12                  => p_ecr_attribute12
         ,p_ecr_attribute13                  => p_ecr_attribute13
         ,p_ecr_attribute14                  => p_ecr_attribute14
         ,p_ecr_attribute15                  => p_ecr_attribute15
         ,p_ecr_attribute16                  => p_ecr_attribute16
         ,p_ecr_attribute17                  => p_ecr_attribute17
         ,p_ecr_attribute18                  => p_ecr_attribute18
         ,p_ecr_attribute19                  => p_ecr_attribute19
         ,p_ecr_attribute20                  => p_ecr_attribute20
         ,p_ecr_attribute21                  => p_ecr_attribute21
         ,p_ecr_attribute22                  => p_ecr_attribute22
         ,p_ecr_attribute23                  => p_ecr_attribute23
         ,p_ecr_attribute24                  => p_ecr_attribute24
         ,p_ecr_attribute25                  => p_ecr_attribute25
         ,p_ecr_attribute26                  => p_ecr_attribute26
         ,p_ecr_attribute27                  => p_ecr_attribute27
         ,p_ecr_attribute28                  => p_ecr_attribute28
         ,p_ecr_attribute29                  => p_ecr_attribute29
         ,p_ecr_attribute30                  => p_ecr_attribute30
         ,p_request_id                       => p_request_id
         ,p_program_application_id           => p_program_application_id
         ,p_program_id                       => p_program_id
         ,p_program_update_date              => p_program_update_date
         ,p_object_version_number            => p_object_version_number
         ,p_effective_date                   => p_effective_date
   );
  --
  exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    raise;
  --
end override_Enrollment_Rate ;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Enrollment_Rate >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Enrollment_Rate
  ( p_validate                    in boolean    default false,
  	p_enrt_rt_id                  in  NUMBER,
  	p_ordr_num			    in number     default hr_api.g_number,
  	p_acty_typ_cd                 in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_tx_typ_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ctfn_rqd_flag               in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_flag                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_pndg_ctfn_flag         in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dsply_on_enrt_flag          in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_use_to_calc_net_flx_cr_flag in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_entr_val_at_enrt_flag       in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_asn_on_enrt_flag            in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rl_crs_only_flag            in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_val                    in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_val                     in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_mn_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_mx_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  	p_val                         in  NUMBER    DEFAULT hr_api.g_number,
  	p_nnmntry_uom                 in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_mx_elcn_val                 in  NUMBER    DEFAULT hr_api.g_number,
  	p_mn_elcn_val                 in  NUMBER    DEFAULT hr_api.g_number,
  	p_incrmt_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_acty_ref_perd_cd       in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_cmcd_mn_elcn_val            in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_mx_elcn_val            in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_val                    in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_dflt_val               in  NUMBER    DEFAULT hr_api.g_number,
  	p_rt_usg_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ann_dflt_val                in  NUMBER    DEFAULT hr_api.g_number,
  	p_bnft_rt_typ_cd              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_mlt_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dsply_mn_elcn_val           in  NUMBER    DEFAULT hr_api.g_number,
  	p_dsply_mx_elcn_val           in  NUMBER    DEFAULT hr_api.g_number,
  	p_entr_ann_val_flag           in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_strt_dt                  in  DATE      DEFAULT hr_api.g_date,
  	p_rt_strt_dt_cd               in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_strt_dt_rl               in  NUMBER    DEFAULT hr_api.g_number,
  	p_rt_typ_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_elig_per_elctbl_chc_id      in  NUMBER    DEFAULT hr_api.g_number,
  	p_acty_base_rt_id             in  NUMBER    DEFAULT hr_api.g_number,
  	p_spcl_rt_enrt_rt_id          in  NUMBER    DEFAULT hr_api.g_number,
  	p_enrt_bnft_id                in  NUMBER    DEFAULT hr_api.g_number,
  	p_prtt_rt_val_id              in  NUMBER    DEFAULT hr_api.g_number,
  	p_decr_bnft_prvdr_pool_id     in  NUMBER    DEFAULT hr_api.g_number,
  	p_cvg_amt_calc_mthd_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_actl_prem_id                in  NUMBER    DEFAULT hr_api.g_number,
  	p_comp_lvl_fctr_id            in  NUMBER    DEFAULT hr_api.g_number,
  	p_ptd_comp_lvl_fctr_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_clm_comp_lvl_fctr_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_business_group_id           in  NUMBER    DEFAULT hr_api.g_number,
        --cwb
        p_perf_min_max_edit           in  VARCHAR2  DEFAULT NULL,
        p_iss_val                     in  number    DEFAULT hr_api.g_number,
        p_val_last_upd_date           in  date      DEFAULT hr_api.g_date,
        p_val_last_upd_person_id      in  number    DEFAULT hr_api.g_number,
        --cwb
        p_pp_in_yr_used_num           in  number    default hr_api.g_number,
  	p_ecr_attribute_category      in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute1              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute2              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute3              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute4              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute5              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute6              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute7              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute8              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute9              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute10             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute11             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute12             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute13             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute14             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute15             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute16             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute17             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute18             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute19             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute20             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute21             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute22             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute23             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute24             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute25             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute26             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute27             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute28             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute29             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute30             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_request_id                  in  NUMBER    DEFAULT hr_api.g_number,
    p_program_application_id      in  NUMBER    DEFAULT hr_api.g_number,
    p_program_id                  in  NUMBER    DEFAULT hr_api.g_number,
    p_program_update_date         in  DATE      DEFAULT hr_api.g_date,
    p_object_version_number       in out nocopy NUMBER,
    p_effective_date              in  date
  ) is
  --
  -- Declare cursors and local variables
  --
     cursor c_rate_vals is
     select  mx_elcn_val , mn_elcn_val , incrmt_elcn_val , elig_per_elctbl_chc_id
     from ben_enrt_rt
     where enrt_rt_id = p_enrt_rt_id ;
  l_rate_vals c_rate_vals%rowtype;
  l_proc varchar2(72) := g_package||'update_Enrollment_Rate';
  l_object_version_number ben_enrt_rt.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Enrollment_Rate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Enrollment_Rate
    --
    ben_Enrollment_Rate_bk2.update_Enrollment_Rate_b
      (
       p_enrt_rt_id                   =>  p_enrt_rt_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_acty_typ_cd                  =>  p_acty_typ_cd
      ,p_tx_typ_cd                    =>  p_tx_typ_cd
      ,p_ctfn_rqd_flag                =>  p_ctfn_rqd_flag
      ,p_dflt_flag                    =>  p_dflt_flag
      ,p_dflt_pndg_ctfn_flag          =>  p_dflt_pndg_ctfn_flag
      ,p_dsply_on_enrt_flag           =>  p_dsply_on_enrt_flag
      ,p_use_to_calc_net_flx_cr_flag  =>  p_use_to_calc_net_flx_cr_flag
      ,p_entr_val_at_enrt_flag        =>  p_entr_val_at_enrt_flag
      ,p_asn_on_enrt_flag             =>  p_asn_on_enrt_flag
      ,p_rl_crs_only_flag             =>  p_rl_crs_only_flag
      ,p_dflt_val                     =>  p_dflt_val
      ,p_ann_val                      =>  p_ann_val
      ,p_ann_mn_elcn_val              =>  p_ann_mn_elcn_val
      ,p_ann_mx_elcn_val              =>  p_ann_mx_elcn_val
      ,p_val                          =>  p_val
      ,p_nnmntry_uom                  =>  p_nnmntry_uom
      ,p_mx_elcn_val                  =>  p_mx_elcn_val
      ,p_mn_elcn_val                  =>  p_mn_elcn_val
      ,p_incrmt_elcn_val              =>  p_incrmt_elcn_val
      ,p_cmcd_acty_ref_perd_cd        =>  p_cmcd_acty_ref_perd_cd
      ,p_cmcd_mn_elcn_val             =>  p_cmcd_mn_elcn_val
      ,p_cmcd_mx_elcn_val             =>  p_cmcd_mx_elcn_val
      ,p_cmcd_val                     =>  p_cmcd_val
      ,p_cmcd_dflt_val                =>  p_cmcd_dflt_val
      ,p_rt_usg_cd                    =>  p_rt_usg_cd
      ,p_ann_dflt_val                 =>  p_ann_dflt_val
      ,p_bnft_rt_typ_cd               =>  p_bnft_rt_typ_cd
      ,p_rt_mlt_cd                    =>  p_rt_mlt_cd
      ,p_dsply_mn_elcn_val            =>  p_dsply_mn_elcn_val
      ,p_dsply_mx_elcn_val            =>  p_dsply_mx_elcn_val
      ,p_entr_ann_val_flag            =>  p_entr_ann_val_flag
      ,p_rt_strt_dt                   =>  p_rt_strt_dt
      ,p_rt_strt_dt_cd                =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                =>  p_rt_strt_dt_rl
      ,p_rt_typ_cd                    =>  p_rt_typ_cd
      ,p_elig_per_elctbl_chc_id       =>  p_elig_per_elctbl_chc_id
      ,p_acty_base_rt_id              =>  p_acty_base_rt_id
      ,p_spcl_rt_enrt_rt_id           =>  p_spcl_rt_enrt_rt_id
      ,p_enrt_bnft_id                 =>  p_enrt_bnft_id
      ,p_prtt_rt_val_id               =>  p_prtt_rt_val_id
      ,p_decr_bnft_prvdr_pool_id      =>  p_decr_bnft_prvdr_pool_id
      ,p_cvg_amt_calc_mthd_id         =>  p_cvg_amt_calc_mthd_id
      ,p_actl_prem_id                 =>  p_actl_prem_id
      ,p_comp_lvl_fctr_id             =>  p_comp_lvl_fctr_id
      ,p_ptd_comp_lvl_fctr_id         =>  p_ptd_comp_lvl_fctr_id
      ,p_clm_comp_lvl_fctr_id         =>  p_clm_comp_lvl_fctr_id
      ,p_business_group_id            =>  p_business_group_id
      --cwb
      ,p_iss_val                      =>  p_iss_val
      ,p_val_last_upd_date            =>  p_val_last_upd_date
      ,p_val_last_upd_person_id       =>  p_val_last_upd_person_id
      --cwb
      ,p_pp_in_yr_used_num            =>  p_pp_in_yr_used_num
      ,p_ecr_attribute_category       =>  p_ecr_attribute_category
      ,p_ecr_attribute1               =>  p_ecr_attribute1
      ,p_ecr_attribute2               =>  p_ecr_attribute2
      ,p_ecr_attribute3               =>  p_ecr_attribute3
      ,p_ecr_attribute4               =>  p_ecr_attribute4
      ,p_ecr_attribute5               =>  p_ecr_attribute5
      ,p_ecr_attribute6               =>  p_ecr_attribute6
      ,p_ecr_attribute7               =>  p_ecr_attribute7
      ,p_ecr_attribute8               =>  p_ecr_attribute8
      ,p_ecr_attribute9               =>  p_ecr_attribute9
      ,p_ecr_attribute10              =>  p_ecr_attribute10
      ,p_ecr_attribute11              =>  p_ecr_attribute11
      ,p_ecr_attribute12              =>  p_ecr_attribute12
      ,p_ecr_attribute13              =>  p_ecr_attribute13
      ,p_ecr_attribute14              =>  p_ecr_attribute14
      ,p_ecr_attribute15              =>  p_ecr_attribute15
      ,p_ecr_attribute16              =>  p_ecr_attribute16
      ,p_ecr_attribute17              =>  p_ecr_attribute17
      ,p_ecr_attribute18              =>  p_ecr_attribute18
      ,p_ecr_attribute19              =>  p_ecr_attribute19
      ,p_ecr_attribute20              =>  p_ecr_attribute20
      ,p_ecr_attribute21              =>  p_ecr_attribute21
      ,p_ecr_attribute22              =>  p_ecr_attribute22
      ,p_ecr_attribute23              =>  p_ecr_attribute23
      ,p_ecr_attribute24              =>  p_ecr_attribute24
      ,p_ecr_attribute25              =>  p_ecr_attribute25
      ,p_ecr_attribute26              =>  p_ecr_attribute26
      ,p_ecr_attribute27              =>  p_ecr_attribute27
      ,p_ecr_attribute28              =>  p_ecr_attribute28
      ,p_ecr_attribute29              =>  p_ecr_attribute29
      ,p_ecr_attribute30              =>  p_ecr_attribute30
      ,p_request_id                   =>  p_request_id
      ,p_program_application_id       =>  p_program_application_id
      ,p_program_id                   =>  p_program_id
      ,p_program_update_date          =>  p_program_update_date
      ,p_object_version_number        =>  p_object_version_number
      ,p_effective_date               =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Enrollment_Rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Enrollment_Rate
    --
  end;
  --
  -- Bug : 2214948 -
  if p_perf_min_max_edit = 'Y' then
     --
       open c_rate_vals;
       fetch c_rate_vals into l_rate_vals;
       close c_rate_vals;

       if (p_mx_elcn_val <> hr_api.g_number) then
            l_rate_vals.mx_elcn_val := p_mx_elcn_val;
       end if;
       if (p_mn_elcn_val <> hr_api.g_number ) then
	    l_rate_vals.mn_elcn_val :=  p_mn_elcn_val;
       end if;
       if (p_incrmt_elcn_val <> hr_api.g_number) then
	    l_rate_vals.incrmt_elcn_val := p_incrmt_elcn_val;
       end if;

       if(p_elig_per_elctbl_chc_id <> hr_api.g_number) then
         l_rate_vals.elig_per_elctbl_chc_id := p_elig_per_elctbl_chc_id;
       end if;

     chk_perf_min_max(p_val                    => p_val
                  ,p_iss_val                   => p_iss_val
                  ,p_mx_elcn_val               => l_rate_vals.mx_elcn_val
                  ,p_mn_elcn_val               => l_rate_vals.mn_elcn_val
                  ,p_enrt_rt_id                => p_enrt_rt_id
                  ,p_object_version_number     => p_object_version_number
                  ,p_elig_per_elctbl_chc_id    => l_rate_vals.elig_per_elctbl_chc_id
                  ,p_effective_date            => trunc(p_effective_date)
                  ,p_incrmt_elcn_val           => l_rate_vals.incrmt_elcn_val);
     --
  end if;
  --
  ben_ecr_upd.upd
    (
       p_enrt_rt_id                   =>  p_enrt_rt_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_acty_typ_cd                  =>  p_acty_typ_cd
      ,p_tx_typ_cd                    =>  p_tx_typ_cd
      ,p_ctfn_rqd_flag                =>  p_ctfn_rqd_flag
      ,p_dflt_flag                    =>  p_dflt_flag
      ,p_dflt_pndg_ctfn_flag          =>  p_dflt_pndg_ctfn_flag
      ,p_dsply_on_enrt_flag           =>  p_dsply_on_enrt_flag
      ,p_use_to_calc_net_flx_cr_flag  =>  p_use_to_calc_net_flx_cr_flag
      ,p_entr_val_at_enrt_flag        =>  p_entr_val_at_enrt_flag
      ,p_asn_on_enrt_flag             =>  p_asn_on_enrt_flag
      ,p_rl_crs_only_flag             =>  p_rl_crs_only_flag
      ,p_dflt_val                     =>  p_dflt_val
      ,p_ann_val                      =>  p_ann_val
      ,p_ann_mn_elcn_val              =>  p_ann_mn_elcn_val
      ,p_ann_mx_elcn_val              =>  p_ann_mx_elcn_val
      ,p_val                          =>  p_val
      ,p_nnmntry_uom                  =>  p_nnmntry_uom
      ,p_mx_elcn_val                  =>  p_mx_elcn_val
      ,p_mn_elcn_val                  =>  p_mn_elcn_val
      ,p_incrmt_elcn_val              =>  p_incrmt_elcn_val
      ,p_cmcd_acty_ref_perd_cd        =>  p_cmcd_acty_ref_perd_cd
      ,p_cmcd_mn_elcn_val             =>  p_cmcd_mn_elcn_val
      ,p_cmcd_mx_elcn_val             =>  p_cmcd_mx_elcn_val
      ,p_cmcd_val                     =>  p_cmcd_val
      ,p_cmcd_dflt_val                =>  p_cmcd_dflt_val
      ,p_rt_usg_cd                    =>  p_rt_usg_cd
      ,p_ann_dflt_val                 =>  p_ann_dflt_val
      ,p_bnft_rt_typ_cd               =>  p_bnft_rt_typ_cd
      ,p_rt_mlt_cd                    =>  p_rt_mlt_cd
      ,p_dsply_mn_elcn_val            =>  p_dsply_mn_elcn_val
      ,p_dsply_mx_elcn_val            =>  p_dsply_mx_elcn_val
      ,p_entr_ann_val_flag            =>  p_entr_ann_val_flag
      ,p_rt_strt_dt                   =>  p_rt_strt_dt
      ,p_rt_strt_dt_cd                =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                =>  p_rt_strt_dt_rl
      ,p_rt_typ_cd                    =>  p_rt_typ_cd
      ,p_elig_per_elctbl_chc_id       =>  p_elig_per_elctbl_chc_id
      ,p_acty_base_rt_id              =>  p_acty_base_rt_id
      ,p_spcl_rt_enrt_rt_id           =>  p_spcl_rt_enrt_rt_id
      ,p_enrt_bnft_id                 =>  p_enrt_bnft_id
      ,p_prtt_rt_val_id               =>  p_prtt_rt_val_id
      ,p_decr_bnft_prvdr_pool_id      =>  p_decr_bnft_prvdr_pool_id
      ,p_cvg_amt_calc_mthd_id         =>  p_cvg_amt_calc_mthd_id
      ,p_actl_prem_id                 =>  p_actl_prem_id
      ,p_comp_lvl_fctr_id             =>  p_comp_lvl_fctr_id
      ,p_ptd_comp_lvl_fctr_id         =>  p_ptd_comp_lvl_fctr_id
      ,p_clm_comp_lvl_fctr_id         =>  p_clm_comp_lvl_fctr_id
      ,p_business_group_id            =>  p_business_group_id
      --cwb
      ,p_iss_val                      =>  p_iss_val
      ,p_val_last_upd_date            =>  p_val_last_upd_date
      ,p_val_last_upd_person_id       =>  p_val_last_upd_person_id
      --cwb
      ,p_pp_in_yr_used_num            =>  p_pp_in_yr_used_num
      ,p_ecr_attribute_category       =>  p_ecr_attribute_category
      ,p_ecr_attribute1               =>  p_ecr_attribute1
      ,p_ecr_attribute2               =>  p_ecr_attribute2
      ,p_ecr_attribute3               =>  p_ecr_attribute3
      ,p_ecr_attribute4               =>  p_ecr_attribute4
      ,p_ecr_attribute5               =>  p_ecr_attribute5
      ,p_ecr_attribute6               =>  p_ecr_attribute6
      ,p_ecr_attribute7               =>  p_ecr_attribute7
      ,p_ecr_attribute8               =>  p_ecr_attribute8
      ,p_ecr_attribute9               =>  p_ecr_attribute9
      ,p_ecr_attribute10              =>  p_ecr_attribute10
      ,p_ecr_attribute11              =>  p_ecr_attribute11
      ,p_ecr_attribute12              =>  p_ecr_attribute12
      ,p_ecr_attribute13              =>  p_ecr_attribute13
      ,p_ecr_attribute14              =>  p_ecr_attribute14
      ,p_ecr_attribute15              =>  p_ecr_attribute15
      ,p_ecr_attribute16              =>  p_ecr_attribute16
      ,p_ecr_attribute17              =>  p_ecr_attribute17
      ,p_ecr_attribute18              =>  p_ecr_attribute18
      ,p_ecr_attribute19              =>  p_ecr_attribute19
      ,p_ecr_attribute20              =>  p_ecr_attribute20
      ,p_ecr_attribute21              =>  p_ecr_attribute21
      ,p_ecr_attribute22              =>  p_ecr_attribute22
      ,p_ecr_attribute23              =>  p_ecr_attribute23
      ,p_ecr_attribute24              =>  p_ecr_attribute24
      ,p_ecr_attribute25              =>  p_ecr_attribute25
      ,p_ecr_attribute26              =>  p_ecr_attribute26
      ,p_ecr_attribute27              =>  p_ecr_attribute27
      ,p_ecr_attribute28              =>  p_ecr_attribute28
      ,p_ecr_attribute29              =>  p_ecr_attribute29
      ,p_ecr_attribute30              =>  p_ecr_attribute30
      ,p_request_id                   =>  p_request_id
      ,p_program_application_id       =>  p_program_application_id
      ,p_program_id                   =>  p_program_id
      ,p_program_update_date          =>  p_program_update_date
      ,p_object_version_number        =>  p_object_version_number
      ,p_effective_date               =>  trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Enrollment_Rate
    --
    ben_Enrollment_Rate_bk2.update_Enrollment_Rate_a
      (
       p_enrt_rt_id                   =>  p_enrt_rt_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_acty_typ_cd                  =>  p_acty_typ_cd
      ,p_tx_typ_cd                    =>  p_tx_typ_cd
      ,p_ctfn_rqd_flag                =>  p_ctfn_rqd_flag
      ,p_dflt_flag                    =>  p_dflt_flag
      ,p_dflt_pndg_ctfn_flag          =>  p_dflt_pndg_ctfn_flag
      ,p_dsply_on_enrt_flag           =>  p_dsply_on_enrt_flag
      ,p_use_to_calc_net_flx_cr_flag  =>  p_use_to_calc_net_flx_cr_flag
      ,p_entr_val_at_enrt_flag        =>  p_entr_val_at_enrt_flag
      ,p_asn_on_enrt_flag             =>  p_asn_on_enrt_flag
      ,p_rl_crs_only_flag             =>  p_rl_crs_only_flag
      ,p_dflt_val                     =>  p_dflt_val
      ,p_ann_val                      =>  p_ann_val
      ,p_ann_mn_elcn_val              =>  p_ann_mn_elcn_val
      ,p_ann_mx_elcn_val              =>  p_ann_mx_elcn_val
      ,p_val                          =>  p_val
      ,p_nnmntry_uom                  =>  p_nnmntry_uom
      ,p_mx_elcn_val                  =>  p_mx_elcn_val
      ,p_mn_elcn_val                  =>  p_mn_elcn_val
      ,p_incrmt_elcn_val              =>  p_incrmt_elcn_val
      ,p_cmcd_acty_ref_perd_cd        =>  p_cmcd_acty_ref_perd_cd
      ,p_cmcd_mn_elcn_val             =>  p_cmcd_mn_elcn_val
      ,p_cmcd_mx_elcn_val             =>  p_cmcd_mx_elcn_val
      ,p_cmcd_val                     =>  p_cmcd_val
      ,p_cmcd_dflt_val                =>  p_cmcd_dflt_val
      ,p_rt_usg_cd                    =>  p_rt_usg_cd
      ,p_ann_dflt_val                 =>  p_ann_dflt_val
      ,p_bnft_rt_typ_cd               =>  p_bnft_rt_typ_cd
      ,p_rt_mlt_cd                    =>  p_rt_mlt_cd
      ,p_dsply_mn_elcn_val            =>  p_dsply_mn_elcn_val
      ,p_dsply_mx_elcn_val            =>  p_dsply_mx_elcn_val
      ,p_entr_ann_val_flag            =>  p_entr_ann_val_flag
      ,p_rt_strt_dt                   =>  p_rt_strt_dt
      ,p_rt_strt_dt_cd                =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                =>  p_rt_strt_dt_rl
      ,p_rt_typ_cd                    =>  p_rt_typ_cd
      ,p_elig_per_elctbl_chc_id       =>  p_elig_per_elctbl_chc_id
      ,p_acty_base_rt_id              =>  p_acty_base_rt_id
      ,p_spcl_rt_enrt_rt_id           =>  p_spcl_rt_enrt_rt_id
      ,p_enrt_bnft_id                 =>  p_enrt_bnft_id
      ,p_prtt_rt_val_id               =>  p_prtt_rt_val_id
      ,p_decr_bnft_prvdr_pool_id      =>  p_decr_bnft_prvdr_pool_id
      ,p_cvg_amt_calc_mthd_id         =>  p_cvg_amt_calc_mthd_id
      ,p_actl_prem_id                 =>  p_actl_prem_id
      ,p_comp_lvl_fctr_id             =>  p_comp_lvl_fctr_id
      ,p_ptd_comp_lvl_fctr_id         =>  p_ptd_comp_lvl_fctr_id
      ,p_clm_comp_lvl_fctr_id         =>  p_clm_comp_lvl_fctr_id
      ,p_business_group_id            =>  p_business_group_id
      --cwb
      ,p_iss_val                      =>  p_iss_val
      ,p_val_last_upd_date            =>  p_val_last_upd_date
      ,p_val_last_upd_person_id       =>  p_val_last_upd_person_id
      --cwb
      ,p_pp_in_yr_used_num            =>  p_pp_in_yr_used_num
      ,p_ecr_attribute_category       =>  p_ecr_attribute_category
      ,p_ecr_attribute1               =>  p_ecr_attribute1
      ,p_ecr_attribute2               =>  p_ecr_attribute2
      ,p_ecr_attribute3               =>  p_ecr_attribute3
      ,p_ecr_attribute4               =>  p_ecr_attribute4
      ,p_ecr_attribute5               =>  p_ecr_attribute5
      ,p_ecr_attribute6               =>  p_ecr_attribute6
      ,p_ecr_attribute7               =>  p_ecr_attribute7
      ,p_ecr_attribute8               =>  p_ecr_attribute8
      ,p_ecr_attribute9               =>  p_ecr_attribute9
      ,p_ecr_attribute10              =>  p_ecr_attribute10
      ,p_ecr_attribute11              =>  p_ecr_attribute11
      ,p_ecr_attribute12              =>  p_ecr_attribute12
      ,p_ecr_attribute13              =>  p_ecr_attribute13
      ,p_ecr_attribute14              =>  p_ecr_attribute14
      ,p_ecr_attribute15              =>  p_ecr_attribute15
      ,p_ecr_attribute16              =>  p_ecr_attribute16
      ,p_ecr_attribute17              =>  p_ecr_attribute17
      ,p_ecr_attribute18              =>  p_ecr_attribute18
      ,p_ecr_attribute19              =>  p_ecr_attribute19
      ,p_ecr_attribute20              =>  p_ecr_attribute20
      ,p_ecr_attribute21              =>  p_ecr_attribute21                           ,p_ecr_attribute22              =>  p_ecr_attribute22
      ,p_ecr_attribute23              =>  p_ecr_attribute23
      ,p_ecr_attribute24              =>  p_ecr_attribute24
      ,p_ecr_attribute25              =>  p_ecr_attribute25
      ,p_ecr_attribute26              =>  p_ecr_attribute26
      ,p_ecr_attribute27              =>  p_ecr_attribute27
      ,p_ecr_attribute28              =>  p_ecr_attribute28
      ,p_ecr_attribute29              =>  p_ecr_attribute29
      ,p_ecr_attribute30              =>  p_ecr_attribute30
      ,p_request_id                   =>  p_request_id
      ,p_program_application_id       =>  p_program_application_id
      ,p_program_id                   =>  p_program_id
      ,p_program_update_date          =>  p_program_update_date
      ,p_object_version_number        =>  p_object_version_number
      ,p_effective_date               =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Enrollment_Rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Enrollment_Rate
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
  -- p_object_version_number := l_object_version_number;
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
    ROLLBACK TO update_Enrollment_Rate;
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
    ROLLBACK TO update_Enrollment_Rate;
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end update_Enrollment_Rate;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Enrollment_Rate >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Enrollment_Rate
  (p_validate                       in  boolean  default false
  ,p_enrt_rt_id                     in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Enrollment_Rate';
  l_object_version_number ben_enrt_rt.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Enrollment_Rate;
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
    -- Start of API User Hook for the before hook of delete_Enrollment_Rate
    --
    ben_Enrollment_Rate_bk3.delete_Enrollment_Rate_b
      (
       p_enrt_rt_id                     =>  p_enrt_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Enrollment_Rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Enrollment_Rate
    --
  end;
  --
  ben_ecr_del.del
    (
     p_enrt_rt_id                    => p_enrt_rt_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Enrollment_Rate
    --
    ben_Enrollment_Rate_bk3.delete_Enrollment_Rate_a
      (
       p_enrt_rt_id                     =>  p_enrt_rt_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Enrollment_Rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Enrollment_Rate
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
    ROLLBACK TO delete_Enrollment_Rate;
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
    ROLLBACK TO delete_Enrollment_Rate;
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end delete_Enrollment_Rate;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_enrt_rt_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_ecr_shd.lck
    (
      p_enrt_rt_id                 => p_enrt_rt_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_Enrollment_Rate_api;

/
