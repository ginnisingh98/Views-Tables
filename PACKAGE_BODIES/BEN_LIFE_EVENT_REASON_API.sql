--------------------------------------------------------
--  DDL for Package Body BEN_LIFE_EVENT_REASON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LIFE_EVENT_REASON_API" as
/* $Header: belerapi.pkb 120.1 2006/11/03 10:39:32 vborkar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Life_Event_Reason_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Life_Event_Reason >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Life_Event_Reason
  (p_validate                       in  boolean   default false
  ,p_ler_id                         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_typ_cd                         in  varchar2  default null
  ,p_lf_evt_oper_cd                 in  varchar2  default null
  ,p_short_name                 in  varchar2  default null
  ,p_short_code                 in  varchar2  default null
  ,p_ptnl_ler_trtmt_cd              in  varchar2  default null
  ,p_ck_rltd_per_elig_flag          in  varchar2  default null
  ,p_ler_eval_rl                    in  number    default null
  ,p_cm_aply_flag                   in  varchar2  default null
  ,p_ovridg_le_flag                 in  varchar2  default null
  ,p_qualg_evt_flag                 in  varchar2  default null
  ,p_whn_to_prcs_cd                 in  varchar2  default null
  ,p_desc_txt                       in  varchar2  default null
  ,p_tmlns_eval_cd                  in  varchar2  default null
  ,p_tmlns_perd_cd                  in  varchar2  default null
  ,p_tmlns_dys_num                  in  number    default null
  ,p_tmlns_perd_rl                  in  number    default null
  ,p_ocrd_dt_det_cd                 in  varchar2  default null
  ,p_ler_stat_cd                    in  varchar2  default null
  ,p_slctbl_slf_svc_cd              in  varchar2  default null
  ,p_ss_pcp_disp_cd                 in  varchar2  default null
  ,p_ler_attribute_category         in  varchar2  default null
  ,p_ler_attribute1                 in  varchar2  default null
  ,p_ler_attribute2                 in  varchar2  default null
  ,p_ler_attribute3                 in  varchar2  default null
  ,p_ler_attribute4                 in  varchar2  default null
  ,p_ler_attribute5                 in  varchar2  default null
  ,p_ler_attribute6                 in  varchar2  default null
  ,p_ler_attribute7                 in  varchar2  default null
  ,p_ler_attribute8                 in  varchar2  default null
  ,p_ler_attribute9                 in  varchar2  default null
  ,p_ler_attribute10                in  varchar2  default null
  ,p_ler_attribute11                in  varchar2  default null
  ,p_ler_attribute12                in  varchar2  default null
  ,p_ler_attribute13                in  varchar2  default null
  ,p_ler_attribute14                in  varchar2  default null
  ,p_ler_attribute15                in  varchar2  default null
  ,p_ler_attribute16                in  varchar2  default null
  ,p_ler_attribute17                in  varchar2  default null
  ,p_ler_attribute18                in  varchar2  default null
  ,p_ler_attribute19                in  varchar2  default null
  ,p_ler_attribute20                in  varchar2  default null
  ,p_ler_attribute21                in  varchar2  default null
  ,p_ler_attribute22                in  varchar2  default null
  ,p_ler_attribute23                in  varchar2  default null
  ,p_ler_attribute24                in  varchar2  default null
  ,p_ler_attribute25                in  varchar2  default null
  ,p_ler_attribute26                in  varchar2  default null
  ,p_ler_attribute27                in  varchar2  default null
  ,p_ler_attribute28                in  varchar2  default null
  ,p_ler_attribute29                in  varchar2  default null
  ,p_ler_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ler_id ben_ler_f.ler_id%TYPE;
  l_effective_start_date ben_ler_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Life_Event_Reason';
  l_object_version_number ben_ler_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Life_Event_Reason;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Life_Event_Reason
    --
    ben_Life_Event_Reason_bk1.create_Life_Event_Reason_b
      (
       p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_typ_cd                         =>  p_typ_cd
      ,p_lf_evt_oper_cd                 =>  p_lf_evt_oper_cd
      ,p_short_name                     =>  p_short_name
      ,p_short_code                     =>  p_short_code
      ,p_ptnl_ler_trtmt_cd              =>  p_ptnl_ler_trtmt_cd
      ,p_ck_rltd_per_elig_flag          =>  p_ck_rltd_per_elig_flag
      ,p_ler_eval_rl                    =>  p_ler_eval_rl
      ,p_cm_aply_flag                   =>  p_cm_aply_flag
      ,p_ovridg_le_flag                 =>  p_ovridg_le_flag
      ,p_qualg_evt_flag                 =>  p_qualg_evt_flag
      ,p_whn_to_prcs_cd                 =>  p_whn_to_prcs_cd
      ,p_desc_txt                       =>  p_desc_txt
      ,p_tmlns_eval_cd                  =>  p_tmlns_eval_cd
      ,p_tmlns_perd_cd                  =>  p_tmlns_perd_cd
      ,p_tmlns_dys_num                  =>  p_tmlns_dys_num
      ,p_tmlns_perd_rl                  =>  p_tmlns_perd_rl
      ,p_ocrd_dt_det_cd                 =>  p_ocrd_dt_det_cd
      ,p_ler_stat_cd                    =>  p_ler_stat_cd
      ,p_slctbl_slf_svc_cd              =>  p_slctbl_slf_svc_cd
      ,p_ss_pcp_disp_cd                 =>  p_ss_pcp_disp_cd
      ,p_ler_attribute_category         =>  p_ler_attribute_category
      ,p_ler_attribute1                 =>  p_ler_attribute1
      ,p_ler_attribute2                 =>  p_ler_attribute2
      ,p_ler_attribute3                 =>  p_ler_attribute3
      ,p_ler_attribute4                 =>  p_ler_attribute4
      ,p_ler_attribute5                 =>  p_ler_attribute5
      ,p_ler_attribute6                 =>  p_ler_attribute6
      ,p_ler_attribute7                 =>  p_ler_attribute7
      ,p_ler_attribute8                 =>  p_ler_attribute8
      ,p_ler_attribute9                 =>  p_ler_attribute9
      ,p_ler_attribute10                =>  p_ler_attribute10
      ,p_ler_attribute11                =>  p_ler_attribute11
      ,p_ler_attribute12                =>  p_ler_attribute12
      ,p_ler_attribute13                =>  p_ler_attribute13
      ,p_ler_attribute14                =>  p_ler_attribute14
      ,p_ler_attribute15                =>  p_ler_attribute15
      ,p_ler_attribute16                =>  p_ler_attribute16
      ,p_ler_attribute17                =>  p_ler_attribute17
      ,p_ler_attribute18                =>  p_ler_attribute18
      ,p_ler_attribute19                =>  p_ler_attribute19
      ,p_ler_attribute20                =>  p_ler_attribute20
      ,p_ler_attribute21                =>  p_ler_attribute21
      ,p_ler_attribute22                =>  p_ler_attribute22
      ,p_ler_attribute23                =>  p_ler_attribute23
      ,p_ler_attribute24                =>  p_ler_attribute24
      ,p_ler_attribute25                =>  p_ler_attribute25
      ,p_ler_attribute26                =>  p_ler_attribute26
      ,p_ler_attribute27                =>  p_ler_attribute27
      ,p_ler_attribute28                =>  p_ler_attribute28
      ,p_ler_attribute29                =>  p_ler_attribute29
      ,p_ler_attribute30                =>  p_ler_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Life_Event_Reason'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Life_Event_Reason
    --
  end;
  --
  ben_ler_ins.ins
    (
     p_ler_id                        => l_ler_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_business_group_id             => p_business_group_id
    ,p_typ_cd                        => p_typ_cd
    ,p_lf_evt_oper_cd                => p_lf_evt_oper_cd
    ,p_short_name                => p_short_name
    ,p_short_code                => p_short_code
    ,p_ptnl_ler_trtmt_cd             => p_ptnl_ler_trtmt_cd
    ,p_ck_rltd_per_elig_flag         => p_ck_rltd_per_elig_flag
    ,p_ler_eval_rl                   => p_ler_eval_rl
    ,p_cm_aply_flag                  => p_cm_aply_flag
    ,p_ovridg_le_flag                => p_ovridg_le_flag
    ,p_qualg_evt_flag                => p_qualg_evt_flag
    ,p_whn_to_prcs_cd                => p_whn_to_prcs_cd
    ,p_desc_txt                      => p_desc_txt
    ,p_tmlns_eval_cd                 => p_tmlns_eval_cd
    ,p_tmlns_perd_cd                 => p_tmlns_perd_cd
    ,p_tmlns_dys_num                 => p_tmlns_dys_num
    ,p_tmlns_perd_rl                 => p_tmlns_perd_rl
    ,p_ocrd_dt_det_cd                => p_ocrd_dt_det_cd
    ,p_ler_stat_cd                   => p_ler_stat_cd
    ,p_slctbl_slf_svc_cd             => p_slctbl_slf_svc_cd
		,p_ss_pcp_disp_cd                => p_ss_pcp_disp_cd
    ,p_ler_attribute_category        => p_ler_attribute_category
    ,p_ler_attribute1                => p_ler_attribute1
    ,p_ler_attribute2                => p_ler_attribute2
    ,p_ler_attribute3                => p_ler_attribute3
    ,p_ler_attribute4                => p_ler_attribute4
    ,p_ler_attribute5                => p_ler_attribute5
    ,p_ler_attribute6                => p_ler_attribute6
    ,p_ler_attribute7                => p_ler_attribute7
    ,p_ler_attribute8                => p_ler_attribute8
    ,p_ler_attribute9                => p_ler_attribute9
    ,p_ler_attribute10               => p_ler_attribute10
    ,p_ler_attribute11               => p_ler_attribute11
    ,p_ler_attribute12               => p_ler_attribute12
    ,p_ler_attribute13               => p_ler_attribute13
    ,p_ler_attribute14               => p_ler_attribute14
    ,p_ler_attribute15               => p_ler_attribute15
    ,p_ler_attribute16               => p_ler_attribute16
    ,p_ler_attribute17               => p_ler_attribute17
    ,p_ler_attribute18               => p_ler_attribute18
    ,p_ler_attribute19               => p_ler_attribute19
    ,p_ler_attribute20               => p_ler_attribute20
    ,p_ler_attribute21               => p_ler_attribute21
    ,p_ler_attribute22               => p_ler_attribute22
    ,p_ler_attribute23               => p_ler_attribute23
    ,p_ler_attribute24               => p_ler_attribute24
    ,p_ler_attribute25               => p_ler_attribute25
    ,p_ler_attribute26               => p_ler_attribute26
    ,p_ler_attribute27               => p_ler_attribute27
    ,p_ler_attribute28               => p_ler_attribute28
    ,p_ler_attribute29               => p_ler_attribute29
    ,p_ler_attribute30               => p_ler_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Life_Event_Reason
    --
    ben_Life_Event_Reason_bk1.create_Life_Event_Reason_a
      (
       p_ler_id                         =>  l_ler_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_typ_cd                         =>  p_typ_cd
      ,p_lf_evt_oper_cd                 =>  p_lf_evt_oper_cd
      ,p_short_name                 =>  p_short_name
      ,p_short_code                 =>  p_short_code
      ,p_ptnl_ler_trtmt_cd              =>  p_ptnl_ler_trtmt_cd
      ,p_ck_rltd_per_elig_flag          =>  p_ck_rltd_per_elig_flag
      ,p_ler_eval_rl                    =>  p_ler_eval_rl
      ,p_cm_aply_flag                   =>  p_cm_aply_flag
      ,p_ovridg_le_flag                 =>  p_ovridg_le_flag
      ,p_qualg_evt_flag                 =>  p_qualg_evt_flag
      ,p_whn_to_prcs_cd                 =>  p_whn_to_prcs_cd
      ,p_desc_txt                       =>  p_desc_txt
      ,p_tmlns_eval_cd                  =>  p_tmlns_eval_cd
      ,p_tmlns_perd_cd                  =>  p_tmlns_perd_cd
      ,p_tmlns_dys_num                  =>  p_tmlns_dys_num
      ,p_tmlns_perd_rl                  =>  p_tmlns_perd_rl
      ,p_ocrd_dt_det_cd                 =>  p_ocrd_dt_det_cd
      ,p_ler_stat_cd                    =>  p_ler_stat_cd
      ,p_slctbl_slf_svc_cd              =>  p_slctbl_slf_svc_cd
			,p_ss_pcp_disp_cd                 =>  p_ss_pcp_disp_cd
      ,p_ler_attribute_category         =>  p_ler_attribute_category
      ,p_ler_attribute1                 =>  p_ler_attribute1
      ,p_ler_attribute2                 =>  p_ler_attribute2
      ,p_ler_attribute3                 =>  p_ler_attribute3
      ,p_ler_attribute4                 =>  p_ler_attribute4
      ,p_ler_attribute5                 =>  p_ler_attribute5
      ,p_ler_attribute6                 =>  p_ler_attribute6
      ,p_ler_attribute7                 =>  p_ler_attribute7
      ,p_ler_attribute8                 =>  p_ler_attribute8
      ,p_ler_attribute9                 =>  p_ler_attribute9
      ,p_ler_attribute10                =>  p_ler_attribute10
      ,p_ler_attribute11                =>  p_ler_attribute11
      ,p_ler_attribute12                =>  p_ler_attribute12
      ,p_ler_attribute13                =>  p_ler_attribute13
      ,p_ler_attribute14                =>  p_ler_attribute14
      ,p_ler_attribute15                =>  p_ler_attribute15
      ,p_ler_attribute16                =>  p_ler_attribute16
      ,p_ler_attribute17                =>  p_ler_attribute17
      ,p_ler_attribute18                =>  p_ler_attribute18
      ,p_ler_attribute19                =>  p_ler_attribute19
      ,p_ler_attribute20                =>  p_ler_attribute20
      ,p_ler_attribute21                =>  p_ler_attribute21
      ,p_ler_attribute22                =>  p_ler_attribute22
      ,p_ler_attribute23                =>  p_ler_attribute23
      ,p_ler_attribute24                =>  p_ler_attribute24
      ,p_ler_attribute25                =>  p_ler_attribute25
      ,p_ler_attribute26                =>  p_ler_attribute26
      ,p_ler_attribute27                =>  p_ler_attribute27
      ,p_ler_attribute28                =>  p_ler_attribute28
      ,p_ler_attribute29                =>  p_ler_attribute29
      ,p_ler_attribute30                =>  p_ler_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Life_Event_Reason'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Life_Event_Reason
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
  p_ler_id := l_ler_id;
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
    ROLLBACK TO create_Life_Event_Reason;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ler_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Life_Event_Reason;
    /* Inserted for nocopy changes */
    p_ler_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_Life_Event_Reason;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Life_Event_Reason >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Life_Event_Reason
  (p_validate                       in  boolean   default false
  ,p_ler_id                         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_typ_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_lf_evt_oper_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_short_name               in varchar2         default hr_api.g_varchar2
  ,p_short_code               in varchar2         default hr_api.g_varchar2
  ,p_ptnl_ler_trtmt_cd              in  varchar2  default hr_api.g_varchar2
  ,p_ck_rltd_per_elig_flag          in  varchar2  default hr_api.g_varchar2
  ,p_ler_eval_rl                    in  number    default hr_api.g_number
  ,p_cm_aply_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_ovridg_le_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_qualg_evt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_whn_to_prcs_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_desc_txt                       in  varchar2  default hr_api.g_varchar2
  ,p_tmlns_eval_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_tmlns_perd_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_tmlns_dys_num                  in  number    default hr_api.g_number
  ,p_tmlns_perd_rl                  in  number    default hr_api.g_number
  ,p_ocrd_dt_det_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_stat_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_slctbl_slf_svc_cd              in  varchar2  default hr_api.g_varchar2
  ,p_ss_pcp_disp_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ler_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Life_Event_Reason';
  l_object_version_number ben_ler_f.object_version_number%TYPE;
  l_effective_start_date ben_ler_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Life_Event_Reason;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Life_Event_Reason
    --
    ben_Life_Event_Reason_bk2.update_Life_Event_Reason_b
      (
       p_ler_id                         =>  p_ler_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_typ_cd                         =>  p_typ_cd
      ,p_lf_evt_oper_cd                 =>  p_lf_evt_oper_cd
      ,p_short_name                =>p_short_name
      ,p_short_code                =>p_short_code
      ,p_ptnl_ler_trtmt_cd              =>  p_ptnl_ler_trtmt_cd
      ,p_ck_rltd_per_elig_flag          =>  p_ck_rltd_per_elig_flag
      ,p_ler_eval_rl                    =>  p_ler_eval_rl
      ,p_cm_aply_flag                   =>  p_cm_aply_flag
      ,p_ovridg_le_flag                 =>  p_ovridg_le_flag
      ,p_qualg_evt_flag                 =>  p_qualg_evt_flag
      ,p_whn_to_prcs_cd                 =>  p_whn_to_prcs_cd
      ,p_desc_txt                       =>  p_desc_txt
      ,p_tmlns_eval_cd                  =>  p_tmlns_eval_cd
      ,p_tmlns_perd_cd                  =>  p_tmlns_perd_cd
      ,p_tmlns_dys_num                  =>  p_tmlns_dys_num
      ,p_tmlns_perd_rl                  =>  p_tmlns_perd_rl
      ,p_ocrd_dt_det_cd                 =>  p_ocrd_dt_det_cd
      ,p_ler_stat_cd                    =>  p_ler_stat_cd
      ,p_slctbl_slf_svc_cd              =>  p_slctbl_slf_svc_cd
			,p_ss_pcp_disp_cd                 =>  p_ss_pcp_disp_cd
      ,p_ler_attribute_category         =>  p_ler_attribute_category
      ,p_ler_attribute1                 =>  p_ler_attribute1
      ,p_ler_attribute2                 =>  p_ler_attribute2
      ,p_ler_attribute3                 =>  p_ler_attribute3
      ,p_ler_attribute4                 =>  p_ler_attribute4
      ,p_ler_attribute5                 =>  p_ler_attribute5
      ,p_ler_attribute6                 =>  p_ler_attribute6
      ,p_ler_attribute7                 =>  p_ler_attribute7
      ,p_ler_attribute8                 =>  p_ler_attribute8
      ,p_ler_attribute9                 =>  p_ler_attribute9
      ,p_ler_attribute10                =>  p_ler_attribute10
      ,p_ler_attribute11                =>  p_ler_attribute11
      ,p_ler_attribute12                =>  p_ler_attribute12
      ,p_ler_attribute13                =>  p_ler_attribute13
      ,p_ler_attribute14                =>  p_ler_attribute14
      ,p_ler_attribute15                =>  p_ler_attribute15
      ,p_ler_attribute16                =>  p_ler_attribute16
      ,p_ler_attribute17                =>  p_ler_attribute17
      ,p_ler_attribute18                =>  p_ler_attribute18
      ,p_ler_attribute19                =>  p_ler_attribute19
      ,p_ler_attribute20                =>  p_ler_attribute20
      ,p_ler_attribute21                =>  p_ler_attribute21
      ,p_ler_attribute22                =>  p_ler_attribute22
      ,p_ler_attribute23                =>  p_ler_attribute23
      ,p_ler_attribute24                =>  p_ler_attribute24
      ,p_ler_attribute25                =>  p_ler_attribute25
      ,p_ler_attribute26                =>  p_ler_attribute26
      ,p_ler_attribute27                =>  p_ler_attribute27
      ,p_ler_attribute28                =>  p_ler_attribute28
      ,p_ler_attribute29                =>  p_ler_attribute29
      ,p_ler_attribute30                =>  p_ler_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Life_Event_Reason'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Life_Event_Reason
    --
  end;
  --
  ben_ler_upd.upd
    (
     p_ler_id                        => p_ler_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_business_group_id             => p_business_group_id
    ,p_typ_cd                        => p_typ_cd
    ,p_lf_evt_oper_cd                => p_lf_evt_oper_cd
    ,p_short_name                => p_short_name
    ,p_short_code                => p_short_code
    ,p_ptnl_ler_trtmt_cd             => p_ptnl_ler_trtmt_cd
    ,p_ck_rltd_per_elig_flag         => p_ck_rltd_per_elig_flag
    ,p_ler_eval_rl                   => p_ler_eval_rl
    ,p_cm_aply_flag                  => p_cm_aply_flag
    ,p_ovridg_le_flag                => p_ovridg_le_flag
    ,p_qualg_evt_flag                => p_qualg_evt_flag
    ,p_whn_to_prcs_cd                => p_whn_to_prcs_cd
    ,p_desc_txt                      => p_desc_txt
    ,p_tmlns_eval_cd                 => p_tmlns_eval_cd
    ,p_tmlns_perd_cd                 => p_tmlns_perd_cd
    ,p_tmlns_dys_num                 => p_tmlns_dys_num
    ,p_tmlns_perd_rl                 => p_tmlns_perd_rl
    ,p_ocrd_dt_det_cd                => p_ocrd_dt_det_cd
    ,p_ler_stat_cd                   => p_ler_stat_cd
    ,p_slctbl_slf_svc_cd             => p_slctbl_slf_svc_cd
		,p_ss_pcp_disp_cd                => p_ss_pcp_disp_cd
    ,p_ler_attribute_category        => p_ler_attribute_category
    ,p_ler_attribute1                => p_ler_attribute1
    ,p_ler_attribute2                => p_ler_attribute2
    ,p_ler_attribute3                => p_ler_attribute3
    ,p_ler_attribute4                => p_ler_attribute4
    ,p_ler_attribute5                => p_ler_attribute5
    ,p_ler_attribute6                => p_ler_attribute6
    ,p_ler_attribute7                => p_ler_attribute7
    ,p_ler_attribute8                => p_ler_attribute8
    ,p_ler_attribute9                => p_ler_attribute9
    ,p_ler_attribute10               => p_ler_attribute10
    ,p_ler_attribute11               => p_ler_attribute11
    ,p_ler_attribute12               => p_ler_attribute12
    ,p_ler_attribute13               => p_ler_attribute13
    ,p_ler_attribute14               => p_ler_attribute14
    ,p_ler_attribute15               => p_ler_attribute15
    ,p_ler_attribute16               => p_ler_attribute16
    ,p_ler_attribute17               => p_ler_attribute17
    ,p_ler_attribute18               => p_ler_attribute18
    ,p_ler_attribute19               => p_ler_attribute19
    ,p_ler_attribute20               => p_ler_attribute20
    ,p_ler_attribute21               => p_ler_attribute21
    ,p_ler_attribute22               => p_ler_attribute22
    ,p_ler_attribute23               => p_ler_attribute23
    ,p_ler_attribute24               => p_ler_attribute24
    ,p_ler_attribute25               => p_ler_attribute25
    ,p_ler_attribute26               => p_ler_attribute26
    ,p_ler_attribute27               => p_ler_attribute27
    ,p_ler_attribute28               => p_ler_attribute28
    ,p_ler_attribute29               => p_ler_attribute29
    ,p_ler_attribute30               => p_ler_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Life_Event_Reason
    --
    ben_Life_Event_Reason_bk2.update_Life_Event_Reason_a
      (
       p_ler_id                         =>  p_ler_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_typ_cd                         =>  p_typ_cd
      ,p_lf_evt_oper_cd                 =>  p_lf_evt_oper_cd
      ,p_short_name                 =>  p_short_name
      ,p_short_code                 =>  p_short_code
      ,p_ptnl_ler_trtmt_cd              =>  p_ptnl_ler_trtmt_cd
      ,p_ck_rltd_per_elig_flag          =>  p_ck_rltd_per_elig_flag
      ,p_ler_eval_rl                    =>  p_ler_eval_rl
      ,p_cm_aply_flag                   =>  p_cm_aply_flag
      ,p_ovridg_le_flag                 =>  p_ovridg_le_flag
      ,p_qualg_evt_flag                 =>  p_qualg_evt_flag
      ,p_whn_to_prcs_cd                 =>  p_whn_to_prcs_cd
      ,p_desc_txt                       =>  p_desc_txt
      ,p_tmlns_eval_cd                  =>  p_tmlns_eval_cd
      ,p_tmlns_perd_cd                  =>  p_tmlns_perd_cd
      ,p_tmlns_dys_num                  =>  p_tmlns_dys_num
      ,p_tmlns_perd_rl                  =>  p_tmlns_perd_rl
      ,p_ocrd_dt_det_cd                 =>  p_ocrd_dt_det_cd
      ,p_ler_stat_cd                    =>  p_ler_stat_cd
      ,p_slctbl_slf_svc_cd              =>  p_slctbl_slf_svc_cd
			,p_ss_pcp_disp_cd                 =>  p_ss_pcp_disp_cd
      ,p_ler_attribute_category         =>  p_ler_attribute_category
      ,p_ler_attribute1                 =>  p_ler_attribute1
      ,p_ler_attribute2                 =>  p_ler_attribute2
      ,p_ler_attribute3                 =>  p_ler_attribute3
      ,p_ler_attribute4                 =>  p_ler_attribute4
      ,p_ler_attribute5                 =>  p_ler_attribute5
      ,p_ler_attribute6                 =>  p_ler_attribute6
      ,p_ler_attribute7                 =>  p_ler_attribute7
      ,p_ler_attribute8                 =>  p_ler_attribute8
      ,p_ler_attribute9                 =>  p_ler_attribute9
      ,p_ler_attribute10                =>  p_ler_attribute10
      ,p_ler_attribute11                =>  p_ler_attribute11
      ,p_ler_attribute12                =>  p_ler_attribute12
      ,p_ler_attribute13                =>  p_ler_attribute13
      ,p_ler_attribute14                =>  p_ler_attribute14
      ,p_ler_attribute15                =>  p_ler_attribute15
      ,p_ler_attribute16                =>  p_ler_attribute16
      ,p_ler_attribute17                =>  p_ler_attribute17
      ,p_ler_attribute18                =>  p_ler_attribute18
      ,p_ler_attribute19                =>  p_ler_attribute19
      ,p_ler_attribute20                =>  p_ler_attribute20
      ,p_ler_attribute21                =>  p_ler_attribute21
      ,p_ler_attribute22                =>  p_ler_attribute22
      ,p_ler_attribute23                =>  p_ler_attribute23
      ,p_ler_attribute24                =>  p_ler_attribute24
      ,p_ler_attribute25                =>  p_ler_attribute25
      ,p_ler_attribute26                =>  p_ler_attribute26
      ,p_ler_attribute27                =>  p_ler_attribute27
      ,p_ler_attribute28                =>  p_ler_attribute28
      ,p_ler_attribute29                =>  p_ler_attribute29
      ,p_ler_attribute30                =>  p_ler_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Life_Event_Reason'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Life_Event_Reason
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
    ROLLBACK TO update_Life_Event_Reason;
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
    ROLLBACK TO update_Life_Event_Reason;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_Life_Event_Reason;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Life_Event_Reason >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Life_Event_Reason
  (p_validate                       in  boolean  default false
  ,p_ler_id                         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Life_Event_Reason';
  l_object_version_number ben_ler_f.object_version_number%TYPE;
  l_effective_start_date ben_ler_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Life_Event_Reason;
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
    -- Start of API User Hook for the before hook of delete_Life_Event_Reason
    --
    ben_Life_Event_Reason_bk3.delete_Life_Event_Reason_b
      (
       p_ler_id                         =>  p_ler_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Life_Event_Reason'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Life_Event_Reason
    --
  end;
  --
  ben_ler_del.del
    (
     p_ler_id                        => p_ler_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Life_Event_Reason
    --
    ben_Life_Event_Reason_bk3.delete_Life_Event_Reason_a
      (
       p_ler_id                         =>  p_ler_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Life_Event_Reason'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Life_Event_Reason
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
    ROLLBACK TO delete_Life_Event_Reason;
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
    ROLLBACK TO delete_Life_Event_Reason;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_Life_Event_Reason;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ler_id                   in     number
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
  ben_ler_shd.lck
    (
      p_ler_id                 => p_ler_id
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
end ben_Life_Event_Reason_api;

/
