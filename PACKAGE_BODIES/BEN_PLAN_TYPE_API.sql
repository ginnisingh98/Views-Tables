--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_TYPE_API" as
/* $Header: beptpapi.pkb 115.11 2003/09/25 00:34:48 rpgupta ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PLAN_TYPE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PLAN_TYPE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PLAN_TYPE
  (p_validate                       in  boolean   default false
  ,p_pl_typ_id                      out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_mx_enrl_alwd_num               in  number    default null
  ,p_mn_enrl_rqd_num                in  number    default null
  ,p_pl_typ_stat_cd                 in  varchar2  default 'A'
  ,p_opt_typ_cd                     in  varchar2  default null
  ,p_opt_dsply_fmt_cd               in  varchar2  default null
  ,p_comp_typ_cd                    in  varchar2  default null
  ,p_ivr_ident                      in  varchar2  default null
  ,p_no_mx_enrl_num_dfnd_flag       in  varchar2  default null
  ,p_no_mn_enrl_num_dfnd_flag       in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_ptp_attribute_category         in  varchar2  default null
  ,p_ptp_attribute1                 in  varchar2  default null
  ,p_ptp_attribute2                 in  varchar2  default null
  ,p_ptp_attribute3                 in  varchar2  default null
  ,p_ptp_attribute4                 in  varchar2  default null
  ,p_ptp_attribute5                 in  varchar2  default null
  ,p_ptp_attribute6                 in  varchar2  default null
  ,p_ptp_attribute7                 in  varchar2  default null
  ,p_ptp_attribute8                 in  varchar2  default null
  ,p_ptp_attribute9                 in  varchar2  default null
  ,p_ptp_attribute10                in  varchar2  default null
  ,p_ptp_attribute11                in  varchar2  default null
  ,p_ptp_attribute12                in  varchar2  default null
  ,p_ptp_attribute13                in  varchar2  default null
  ,p_ptp_attribute14                in  varchar2  default null
  ,p_ptp_attribute15                in  varchar2  default null
  ,p_ptp_attribute16                in  varchar2  default null
  ,p_ptp_attribute17                in  varchar2  default null
  ,p_ptp_attribute18                in  varchar2  default null
  ,p_ptp_attribute19                in  varchar2  default null
  ,p_ptp_attribute20                in  varchar2  default null
  ,p_ptp_attribute21                in  varchar2  default null
  ,p_ptp_attribute22                in  varchar2  default null
  ,p_ptp_attribute23                in  varchar2  default null
  ,p_ptp_attribute24                in  varchar2  default null
  ,p_ptp_attribute25                in  varchar2  default null
  ,p_ptp_attribute26                in  varchar2  default null
  ,p_ptp_attribute27                in  varchar2  default null
  ,p_ptp_attribute28                in  varchar2  default null
  ,p_ptp_attribute29                in  varchar2  default null
  ,p_ptp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_short_name             in  varchar2  default null  --FHR
  ,p_short_code             in  varchar2  default null  --FHR
    ,p_legislation_code             in  varchar2  default null
    ,p_legislation_subgroup             in  varchar2  default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pl_typ_id ben_pl_typ_f.pl_typ_id%TYPE;
  l_effective_start_date ben_pl_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_typ_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PLAN_TYPE';
  l_object_version_number ben_pl_typ_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PLAN_TYPE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PLAN_TYPE
    --
    ben_PLAN_TYPE_bk1.create_PLAN_TYPE_b
      (
       p_name                           =>  p_name
      ,p_mx_enrl_alwd_num               =>  p_mx_enrl_alwd_num
      ,p_mn_enrl_rqd_num                =>  p_mn_enrl_rqd_num
      ,p_pl_typ_stat_cd                 =>  p_pl_typ_stat_cd
      ,p_opt_typ_cd                     =>  p_opt_typ_cd
      ,p_opt_dsply_fmt_cd               =>  p_opt_dsply_fmt_cd
      ,p_comp_typ_cd                    =>  p_comp_typ_cd
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_no_mx_enrl_num_dfnd_flag       =>  p_no_mx_enrl_num_dfnd_flag
      ,p_no_mn_enrl_num_dfnd_flag       =>  p_no_mn_enrl_num_dfnd_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_ptp_attribute_category         =>  p_ptp_attribute_category
      ,p_ptp_attribute1                 =>  p_ptp_attribute1
      ,p_ptp_attribute2                 =>  p_ptp_attribute2
      ,p_ptp_attribute3                 =>  p_ptp_attribute3
      ,p_ptp_attribute4                 =>  p_ptp_attribute4
      ,p_ptp_attribute5                 =>  p_ptp_attribute5
      ,p_ptp_attribute6                 =>  p_ptp_attribute6
      ,p_ptp_attribute7                 =>  p_ptp_attribute7
      ,p_ptp_attribute8                 =>  p_ptp_attribute8
      ,p_ptp_attribute9                 =>  p_ptp_attribute9
      ,p_ptp_attribute10                =>  p_ptp_attribute10
      ,p_ptp_attribute11                =>  p_ptp_attribute11
      ,p_ptp_attribute12                =>  p_ptp_attribute12
      ,p_ptp_attribute13                =>  p_ptp_attribute13
      ,p_ptp_attribute14                =>  p_ptp_attribute14
      ,p_ptp_attribute15                =>  p_ptp_attribute15
      ,p_ptp_attribute16                =>  p_ptp_attribute16
      ,p_ptp_attribute17                =>  p_ptp_attribute17
      ,p_ptp_attribute18                =>  p_ptp_attribute18
      ,p_ptp_attribute19                =>  p_ptp_attribute19
      ,p_ptp_attribute20                =>  p_ptp_attribute20
      ,p_ptp_attribute21                =>  p_ptp_attribute21
      ,p_ptp_attribute22                =>  p_ptp_attribute22
      ,p_ptp_attribute23                =>  p_ptp_attribute23
      ,p_ptp_attribute24                =>  p_ptp_attribute24
      ,p_ptp_attribute25                =>  p_ptp_attribute25
      ,p_ptp_attribute26                =>  p_ptp_attribute26
      ,p_ptp_attribute27                =>  p_ptp_attribute27
      ,p_ptp_attribute28                =>  p_ptp_attribute28
      ,p_ptp_attribute29                =>  p_ptp_attribute29
      ,p_ptp_attribute30                =>  p_ptp_attribute30
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_short_name         =>  p_short_name        --FHR
      ,p_short_code             =>  p_short_code        --FHR
            ,p_legislation_code             =>  p_legislation_code
            ,p_legislation_subgroup             =>  p_legislation_subgroup
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PLAN_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PLAN_TYPE
    --
  end;
  --
  ben_ptp_ins.ins
    (
     p_pl_typ_id                     => l_pl_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_mx_enrl_alwd_num              => p_mx_enrl_alwd_num
    ,p_mn_enrl_rqd_num               => p_mn_enrl_rqd_num
    ,p_pl_typ_stat_cd                => p_pl_typ_stat_cd
    ,p_opt_typ_cd                    => p_opt_typ_cd
    ,p_opt_dsply_fmt_cd              => p_opt_dsply_fmt_cd
    ,p_comp_typ_cd                   => p_comp_typ_cd
    ,p_ivr_ident                     => p_ivr_ident
    ,p_no_mx_enrl_num_dfnd_flag      => p_no_mx_enrl_num_dfnd_flag
    ,p_no_mn_enrl_num_dfnd_flag      => p_no_mn_enrl_num_dfnd_flag
    ,p_business_group_id             => p_business_group_id
    ,p_ptp_attribute_category        => p_ptp_attribute_category
    ,p_ptp_attribute1                => p_ptp_attribute1
    ,p_ptp_attribute2                => p_ptp_attribute2
    ,p_ptp_attribute3                => p_ptp_attribute3
    ,p_ptp_attribute4                => p_ptp_attribute4
    ,p_ptp_attribute5                => p_ptp_attribute5
    ,p_ptp_attribute6                => p_ptp_attribute6
    ,p_ptp_attribute7                => p_ptp_attribute7
    ,p_ptp_attribute8                => p_ptp_attribute8
    ,p_ptp_attribute9                => p_ptp_attribute9
    ,p_ptp_attribute10               => p_ptp_attribute10
    ,p_ptp_attribute11               => p_ptp_attribute11
    ,p_ptp_attribute12               => p_ptp_attribute12
    ,p_ptp_attribute13               => p_ptp_attribute13
    ,p_ptp_attribute14               => p_ptp_attribute14
    ,p_ptp_attribute15               => p_ptp_attribute15
    ,p_ptp_attribute16               => p_ptp_attribute16
    ,p_ptp_attribute17               => p_ptp_attribute17
    ,p_ptp_attribute18               => p_ptp_attribute18
    ,p_ptp_attribute19               => p_ptp_attribute19
    ,p_ptp_attribute20               => p_ptp_attribute20
    ,p_ptp_attribute21               => p_ptp_attribute21
    ,p_ptp_attribute22               => p_ptp_attribute22
    ,p_ptp_attribute23               => p_ptp_attribute23
    ,p_ptp_attribute24               => p_ptp_attribute24
    ,p_ptp_attribute25               => p_ptp_attribute25
    ,p_ptp_attribute26               => p_ptp_attribute26
    ,p_ptp_attribute27               => p_ptp_attribute27
    ,p_ptp_attribute28               => p_ptp_attribute28
    ,p_ptp_attribute29               => p_ptp_attribute29
    ,p_ptp_attribute30               => p_ptp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_short_name            =>  p_short_name           --FHR
    ,p_short_code            =>  p_short_code           --FHR
        ,p_legislation_code            =>  p_legislation_code
        ,p_legislation_subgroup            =>  p_legislation_subgroup
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PLAN_TYPE
    --
    ben_PLAN_TYPE_bk1.create_PLAN_TYPE_a
      (
       p_pl_typ_id                      =>  l_pl_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_mx_enrl_alwd_num               =>  p_mx_enrl_alwd_num
      ,p_mn_enrl_rqd_num                =>  p_mn_enrl_rqd_num
      ,p_pl_typ_stat_cd                 =>  p_pl_typ_stat_cd
      ,p_opt_typ_cd                     =>  p_opt_typ_cd
      ,p_opt_dsply_fmt_cd               =>  p_opt_dsply_fmt_cd
      ,p_comp_typ_cd                    =>  p_comp_typ_cd
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_no_mx_enrl_num_dfnd_flag       =>  p_no_mx_enrl_num_dfnd_flag
      ,p_no_mn_enrl_num_dfnd_flag       =>  p_no_mn_enrl_num_dfnd_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_ptp_attribute_category         =>  p_ptp_attribute_category
      ,p_ptp_attribute1                 =>  p_ptp_attribute1
      ,p_ptp_attribute2                 =>  p_ptp_attribute2
      ,p_ptp_attribute3                 =>  p_ptp_attribute3
      ,p_ptp_attribute4                 =>  p_ptp_attribute4
      ,p_ptp_attribute5                 =>  p_ptp_attribute5
      ,p_ptp_attribute6                 =>  p_ptp_attribute6
      ,p_ptp_attribute7                 =>  p_ptp_attribute7
      ,p_ptp_attribute8                 =>  p_ptp_attribute8
      ,p_ptp_attribute9                 =>  p_ptp_attribute9
      ,p_ptp_attribute10                =>  p_ptp_attribute10
      ,p_ptp_attribute11                =>  p_ptp_attribute11
      ,p_ptp_attribute12                =>  p_ptp_attribute12
      ,p_ptp_attribute13                =>  p_ptp_attribute13
      ,p_ptp_attribute14                =>  p_ptp_attribute14
      ,p_ptp_attribute15                =>  p_ptp_attribute15
      ,p_ptp_attribute16                =>  p_ptp_attribute16
      ,p_ptp_attribute17                =>  p_ptp_attribute17
      ,p_ptp_attribute18                =>  p_ptp_attribute18
      ,p_ptp_attribute19                =>  p_ptp_attribute19
      ,p_ptp_attribute20                =>  p_ptp_attribute20
      ,p_ptp_attribute21                =>  p_ptp_attribute21
      ,p_ptp_attribute22                =>  p_ptp_attribute22
      ,p_ptp_attribute23                =>  p_ptp_attribute23
      ,p_ptp_attribute24                =>  p_ptp_attribute24
      ,p_ptp_attribute25                =>  p_ptp_attribute25
      ,p_ptp_attribute26                =>  p_ptp_attribute26
      ,p_ptp_attribute27                =>  p_ptp_attribute27
      ,p_ptp_attribute28                =>  p_ptp_attribute28
      ,p_ptp_attribute29                =>  p_ptp_attribute29
      ,p_ptp_attribute30                =>  p_ptp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_short_name         =>  p_short_name        --FHR
      ,p_short_code             =>  p_short_code        --FHR
            ,p_legislation_code             =>  p_legislation_code
            ,p_legislation_subgroup             =>  p_legislation_subgroup
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PLAN_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PLAN_TYPE
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
  p_pl_typ_id := l_pl_typ_id;
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
    ROLLBACK TO create_PLAN_TYPE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pl_typ_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    -- Initialize OUT Variables for NOCOPY
    p_pl_typ_id            :=null;
    p_effective_start_date :=null;
    p_effective_end_date   :=null;
    p_object_version_number:=null;

    --
    ROLLBACK TO create_PLAN_TYPE;
    raise;
    --
end create_PLAN_TYPE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_PLAN_TYPE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PLAN_TYPE
  (p_validate                       in  boolean   default false
  ,p_pl_typ_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_mx_enrl_alwd_num               in  number    default hr_api.g_number
  ,p_mn_enrl_rqd_num                in  number    default hr_api.g_number
  ,p_pl_typ_stat_cd                 in  varchar2  default 'A'
  ,p_opt_typ_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_opt_dsply_fmt_cd               in  varchar2  default hr_api.g_varchar2
  ,p_comp_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_ivr_ident                      in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_enrl_num_dfnd_flag       in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_enrl_num_dfnd_flag       in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ptp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ptp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_short_name             in  varchar2  default hr_api.g_varchar2     --FHR
  ,p_short_code                 in  varchar2  default hr_api.g_varchar2         --FHR
    ,p_legislation_code                 in  varchar2  default hr_api.g_varchar2
    ,p_legislation_subgroup                 in  varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PLAN_TYPE';
  l_object_version_number ben_pl_typ_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_typ_f.effective_end_date%TYPE;
  l_old_opt_dsply_fmt_cd ben_pl_typ_f.opt_dsply_fmt_cd%TYPE;
  l_ordr_num number;
  --
  cursor c_old_pl_typ is
  select plt.opt_dsply_fmt_cd
  from   ben_pl_typ_f plt
  where  plt.pl_typ_id = p_pl_typ_id
  and    p_effective_date between plt.effective_start_date and plt.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PLAN_TYPE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  open c_old_pl_typ;
  fetch c_old_pl_typ into l_old_opt_dsply_fmt_cd;
  close c_old_pl_typ;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PLAN_TYPE
    --
    ben_PLAN_TYPE_bk2.update_PLAN_TYPE_b
      (
       p_pl_typ_id                      =>  p_pl_typ_id
      ,p_name                           =>  p_name
      ,p_mx_enrl_alwd_num               =>  p_mx_enrl_alwd_num
      ,p_mn_enrl_rqd_num                =>  p_mn_enrl_rqd_num
      ,p_pl_typ_stat_cd                 =>  p_pl_typ_stat_cd
      ,p_opt_typ_cd                     =>  p_opt_typ_cd
      ,p_opt_dsply_fmt_cd               =>  p_opt_dsply_fmt_cd
      ,p_comp_typ_cd                    =>  p_comp_typ_cd
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_no_mx_enrl_num_dfnd_flag       =>  p_no_mx_enrl_num_dfnd_flag
      ,p_no_mn_enrl_num_dfnd_flag       =>  p_no_mn_enrl_num_dfnd_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_ptp_attribute_category         =>  p_ptp_attribute_category
      ,p_ptp_attribute1                 =>  p_ptp_attribute1
      ,p_ptp_attribute2                 =>  p_ptp_attribute2
      ,p_ptp_attribute3                 =>  p_ptp_attribute3
      ,p_ptp_attribute4                 =>  p_ptp_attribute4
      ,p_ptp_attribute5                 =>  p_ptp_attribute5
      ,p_ptp_attribute6                 =>  p_ptp_attribute6
      ,p_ptp_attribute7                 =>  p_ptp_attribute7
      ,p_ptp_attribute8                 =>  p_ptp_attribute8
      ,p_ptp_attribute9                 =>  p_ptp_attribute9
      ,p_ptp_attribute10                =>  p_ptp_attribute10
      ,p_ptp_attribute11                =>  p_ptp_attribute11
      ,p_ptp_attribute12                =>  p_ptp_attribute12
      ,p_ptp_attribute13                =>  p_ptp_attribute13
      ,p_ptp_attribute14                =>  p_ptp_attribute14
      ,p_ptp_attribute15                =>  p_ptp_attribute15
      ,p_ptp_attribute16                =>  p_ptp_attribute16
      ,p_ptp_attribute17                =>  p_ptp_attribute17
      ,p_ptp_attribute18                =>  p_ptp_attribute18
      ,p_ptp_attribute19                =>  p_ptp_attribute19
      ,p_ptp_attribute20                =>  p_ptp_attribute20
      ,p_ptp_attribute21                =>  p_ptp_attribute21
      ,p_ptp_attribute22                =>  p_ptp_attribute22
      ,p_ptp_attribute23                =>  p_ptp_attribute23
      ,p_ptp_attribute24                =>  p_ptp_attribute24
      ,p_ptp_attribute25                =>  p_ptp_attribute25
      ,p_ptp_attribute26                =>  p_ptp_attribute26
      ,p_ptp_attribute27                =>  p_ptp_attribute27
      ,p_ptp_attribute28                =>  p_ptp_attribute28
      ,p_ptp_attribute29                =>  p_ptp_attribute29
      ,p_ptp_attribute30                =>  p_ptp_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      ,p_short_name         =>  p_short_name        --FHR
      ,p_short_code             =>  p_short_code        --FHR
            ,p_legislation_code             =>  p_legislation_code
            ,p_legislation_subgroup             =>  p_legislation_subgroup
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PLAN_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PLAN_TYPE
    --
  end;
  --
  ben_ptp_upd.upd
    (
     p_pl_typ_id                     => p_pl_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_mx_enrl_alwd_num              => p_mx_enrl_alwd_num
    ,p_mn_enrl_rqd_num               => p_mn_enrl_rqd_num
    ,p_pl_typ_stat_cd                => p_pl_typ_stat_cd
    ,p_opt_typ_cd                    => p_opt_typ_cd
    ,p_opt_dsply_fmt_cd              => p_opt_dsply_fmt_cd
    ,p_comp_typ_cd                   => p_comp_typ_cd
    ,p_ivr_ident                     => p_ivr_ident
    ,p_no_mx_enrl_num_dfnd_flag      => p_no_mx_enrl_num_dfnd_flag
    ,p_no_mn_enrl_num_dfnd_flag      => p_no_mn_enrl_num_dfnd_flag
    ,p_business_group_id             => p_business_group_id
    ,p_ptp_attribute_category        => p_ptp_attribute_category
    ,p_ptp_attribute1                => p_ptp_attribute1
    ,p_ptp_attribute2                => p_ptp_attribute2
    ,p_ptp_attribute3                => p_ptp_attribute3
    ,p_ptp_attribute4                => p_ptp_attribute4
    ,p_ptp_attribute5                => p_ptp_attribute5
    ,p_ptp_attribute6                => p_ptp_attribute6
    ,p_ptp_attribute7                => p_ptp_attribute7
    ,p_ptp_attribute8                => p_ptp_attribute8
    ,p_ptp_attribute9                => p_ptp_attribute9
    ,p_ptp_attribute10               => p_ptp_attribute10
    ,p_ptp_attribute11               => p_ptp_attribute11
    ,p_ptp_attribute12               => p_ptp_attribute12
    ,p_ptp_attribute13               => p_ptp_attribute13
    ,p_ptp_attribute14               => p_ptp_attribute14
    ,p_ptp_attribute15               => p_ptp_attribute15
    ,p_ptp_attribute16               => p_ptp_attribute16
    ,p_ptp_attribute17               => p_ptp_attribute17
    ,p_ptp_attribute18               => p_ptp_attribute18
    ,p_ptp_attribute19               => p_ptp_attribute19
    ,p_ptp_attribute20               => p_ptp_attribute20
    ,p_ptp_attribute21               => p_ptp_attribute21
    ,p_ptp_attribute22               => p_ptp_attribute22
    ,p_ptp_attribute23               => p_ptp_attribute23
    ,p_ptp_attribute24               => p_ptp_attribute24
    ,p_ptp_attribute25               => p_ptp_attribute25
    ,p_ptp_attribute26               => p_ptp_attribute26
    ,p_ptp_attribute27               => p_ptp_attribute27
    ,p_ptp_attribute28               => p_ptp_attribute28
    ,p_ptp_attribute29               => p_ptp_attribute29
    ,p_ptp_attribute30               => p_ptp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_short_name            => p_short_name        --FHR
    ,p_short_code            => p_short_code        --FHR
        ,p_legislation_code            => p_legislation_code
        ,p_legislation_subgroup            => p_legislation_subgroup
    );
  --
  -- Bug 3042658, If the p_opt_dsply_fmt_cd is being modified then
  -- update the ordr_num = 1 for all standard rates which are based on
  -- this plan type
  --
  if (nvl(l_old_opt_dsply_fmt_cd,'NULL') <> p_opt_dsply_fmt_cd and p_opt_dsply_fmt_cd = 'HRZ')
     or (l_old_opt_dsply_fmt_cd is not null and p_opt_dsply_fmt_cd is null) then
        --
        if p_opt_dsply_fmt_cd is null then
           l_ordr_num := null;
        else
           l_ordr_num := 1;
        end if;
  	--
  	update ben_acty_base_rt_f
  	set    ordr_num = l_ordr_num
  	where  pl_id in (select pln.pl_id
  			 from   ben_pl_f pln
  			 where  pln.pl_typ_id = p_pl_typ_id
  			 and    p_effective_date between pln.effective_start_date
  			 	and pln.effective_end_date)
  	and    p_effective_date <= effective_end_date
  	and    dsply_on_enrt_flag = 'Y';
  	--
    	-- plip level
    	--
    	update ben_acty_base_rt_f
    	set    ordr_num = l_ordr_num
    	where  plip_id in (select plip_id
    			   from   ben_plip_f plip,
    			   	  ben_pl_f pln
    			   where  pln.pl_id = plip.pl_id
    			   and    pln.pl_typ_id = p_pl_typ_id
  			   and    p_effective_date between pln.effective_start_date
  			 	  and pln.effective_end_date
  			   and    p_effective_date between plip.effective_start_date
  			 	  and plip.effective_end_date)
  	and    p_effective_date <= effective_end_date
  	and    dsply_on_enrt_flag = 'Y';
  	--
    	-- oipl level
    	--
  	update ben_acty_base_rt_f
  	set    ordr_num = l_ordr_num
  	where  oipl_id in (select oipl_id
  			   from   ben_pl_f pln,
  			 	  ben_oipl_f oipl
  			   where  oipl.pl_id = pln.pl_id
  			   and	  pln.pl_typ_id = p_pl_typ_id
  			   and    p_effective_date between pln.effective_start_date
  			 	  and pln.effective_end_date
  			   and    p_effective_date between oipl.effective_start_date
  			 	  and oipl.effective_end_date)
  	and    p_effective_date <= effective_end_date
  	and    dsply_on_enrt_flag = 'Y';
  	--
    	-- oiplip level
    	--
  	update ben_acty_base_rt_f
  	set    ordr_num = l_ordr_num
  	where  oiplip_id in (select oiplip_id
  			     from   ben_oiplip_f oiplip,
  			     	    ben_oipl_f   oipl,
  			     	    ben_pl_f pln
  			     where  oipl.oipl_id = oiplip.oipl_id
  			     and    pln.pl_id = oipl.pl_id
  			     and    pln.pl_typ_id = p_pl_typ_id
  			     and    p_effective_date between pln.effective_start_date
  			 	    and pln.effective_end_date
  			     and    p_effective_date between oipl.effective_start_date
  			 	    and oipl.effective_end_date
  			     and    p_effective_date between oiplip.effective_start_date
  			 	    and oiplip.effective_end_date )
  	and    p_effective_date <= effective_end_date
  	and    dsply_on_enrt_flag = 'Y';
  	--
  end if;
  --
  -- End Bug 3042658
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PLAN_TYPE
    --
    ben_PLAN_TYPE_bk2.update_PLAN_TYPE_a
      (
       p_pl_typ_id                      =>  p_pl_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_mx_enrl_alwd_num               =>  p_mx_enrl_alwd_num
      ,p_mn_enrl_rqd_num                =>  p_mn_enrl_rqd_num
      ,p_pl_typ_stat_cd                 =>  p_pl_typ_stat_cd
      ,p_opt_typ_cd                     =>  p_opt_typ_cd
      ,p_opt_dsply_fmt_cd               =>  p_opt_dsply_fmt_cd
      ,p_comp_typ_cd                    =>  p_comp_typ_cd
      ,p_ivr_ident                      =>  p_ivr_ident
      ,p_no_mx_enrl_num_dfnd_flag       =>  p_no_mx_enrl_num_dfnd_flag
      ,p_no_mn_enrl_num_dfnd_flag       =>  p_no_mn_enrl_num_dfnd_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_ptp_attribute_category         =>  p_ptp_attribute_category
      ,p_ptp_attribute1                 =>  p_ptp_attribute1
      ,p_ptp_attribute2                 =>  p_ptp_attribute2
      ,p_ptp_attribute3                 =>  p_ptp_attribute3
      ,p_ptp_attribute4                 =>  p_ptp_attribute4
      ,p_ptp_attribute5                 =>  p_ptp_attribute5
      ,p_ptp_attribute6                 =>  p_ptp_attribute6
      ,p_ptp_attribute7                 =>  p_ptp_attribute7
      ,p_ptp_attribute8                 =>  p_ptp_attribute8
      ,p_ptp_attribute9                 =>  p_ptp_attribute9
      ,p_ptp_attribute10                =>  p_ptp_attribute10
      ,p_ptp_attribute11                =>  p_ptp_attribute11
      ,p_ptp_attribute12                =>  p_ptp_attribute12
      ,p_ptp_attribute13                =>  p_ptp_attribute13
      ,p_ptp_attribute14                =>  p_ptp_attribute14
      ,p_ptp_attribute15                =>  p_ptp_attribute15
      ,p_ptp_attribute16                =>  p_ptp_attribute16
      ,p_ptp_attribute17                =>  p_ptp_attribute17
      ,p_ptp_attribute18                =>  p_ptp_attribute18
      ,p_ptp_attribute19                =>  p_ptp_attribute19
      ,p_ptp_attribute20                =>  p_ptp_attribute20
      ,p_ptp_attribute21                =>  p_ptp_attribute21
      ,p_ptp_attribute22                =>  p_ptp_attribute22
      ,p_ptp_attribute23                =>  p_ptp_attribute23
      ,p_ptp_attribute24                =>  p_ptp_attribute24
      ,p_ptp_attribute25                =>  p_ptp_attribute25
      ,p_ptp_attribute26                =>  p_ptp_attribute26
      ,p_ptp_attribute27                =>  p_ptp_attribute27
      ,p_ptp_attribute28                =>  p_ptp_attribute28
      ,p_ptp_attribute29                =>  p_ptp_attribute29
      ,p_ptp_attribute30                =>  p_ptp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode
      ,p_short_name         =>  p_short_name        --FHR
      ,p_short_code             =>  p_short_code        --FHR
            ,p_legislation_code             =>  p_legislation_code
            ,p_legislation_subgroup             =>  p_legislation_subgroup
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PLAN_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PLAN_TYPE
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
    ROLLBACK TO update_PLAN_TYPE;
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

    -- Initialize OUT Variables for NOCOPY
    p_effective_start_date  :=null;
    p_effective_end_date    :=null;

    -- Initialize IN/OUT Variables for NOCOPY
    p_object_version_number :=l_object_version_number;

    --
    ROLLBACK TO update_PLAN_TYPE;
    raise;
    --
end update_PLAN_TYPE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PLAN_TYPE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PLAN_TYPE
  (p_validate                       in  boolean  default false
  ,p_pl_typ_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PLAN_TYPE';
  l_object_version_number ben_pl_typ_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_typ_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PLAN_TYPE;
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
    -- Start of API User Hook for the before hook of delete_PLAN_TYPE
    --
    ben_PLAN_TYPE_bk3.delete_PLAN_TYPE_b
      (
       p_pl_typ_id                      =>  p_pl_typ_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PLAN_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_PLAN_TYPE
    --
  end;
  --
  ben_ptp_del.del
    (
     p_pl_typ_id                     => p_pl_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PLAN_TYPE
    --
    ben_PLAN_TYPE_bk3.delete_PLAN_TYPE_a
      (
       p_pl_typ_id                      =>  p_pl_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PLAN_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_PLAN_TYPE
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
    ROLLBACK TO delete_PLAN_TYPE;
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

    -- Initialize OUT Variables for NOCOPY
    p_effective_start_date  :=null;
    p_effective_end_date    :=null;

    -- Initialize IN/OUT Variables for NOCOPY
    p_object_version_number :=l_object_version_number ;
    --
    ROLLBACK TO delete_PLAN_TYPE;
    raise;
    --
end delete_PLAN_TYPE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pl_typ_id                   in     number
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
  ben_ptp_shd.lck
    (
      p_pl_typ_id                 => p_pl_typ_id
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
end ben_PLAN_TYPE_api;

/
