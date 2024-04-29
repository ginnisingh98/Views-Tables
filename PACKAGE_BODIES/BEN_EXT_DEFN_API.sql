--------------------------------------------------------
--  DDL for Package Body BEN_EXT_DEFN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_DEFN_API" as
/* $Header: bexdfapi.pkb 120.2 2006/06/06 21:42:37 tjesumic ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_EXT_DEFN_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_DEFN >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_DEFN
  (p_validate                       in  boolean   default false
  ,p_ext_dfn_id                     out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_xml_tag_name                   in  varchar2  default null
  ,p_xdo_template_id                in  number    default null
  ,p_data_typ_cd                    in  varchar2  default null
  ,p_ext_typ_cd                     in  varchar2  default null
  ,p_output_name                    in  varchar2  default null
  ,p_output_type                    in  varchar2  default null
  ,p_apnd_rqst_id_flag              in  varchar2  default null
  ,p_prmy_sort_cd                   in  varchar2  default null
  ,p_scnd_sort_cd                   in  varchar2  default null
  ,p_strt_dt                        in  varchar2  default null
  ,p_end_dt                         in  varchar2  default null
  ,p_ext_crit_prfl_id               in  number    default null
  ,p_ext_file_id                    in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_xdf_attribute_category         in  varchar2  default null
  ,p_xdf_attribute1                 in  varchar2  default null
  ,p_xdf_attribute2                 in  varchar2  default null
  ,p_xdf_attribute3                 in  varchar2  default null
  ,p_xdf_attribute4                 in  varchar2  default null
  ,p_xdf_attribute5                 in  varchar2  default null
  ,p_xdf_attribute6                 in  varchar2  default null
  ,p_xdf_attribute7                 in  varchar2  default null
  ,p_xdf_attribute8                 in  varchar2  default null
  ,p_xdf_attribute9                 in  varchar2  default null
  ,p_xdf_attribute10                in  varchar2  default null
  ,p_xdf_attribute11                in  varchar2  default null
  ,p_xdf_attribute12                in  varchar2  default null
  ,p_xdf_attribute13                in  varchar2  default null
  ,p_xdf_attribute14                in  varchar2  default null
  ,p_xdf_attribute15                in  varchar2  default null
  ,p_xdf_attribute16                in  varchar2  default null
  ,p_xdf_attribute17                in  varchar2  default null
  ,p_xdf_attribute18                in  varchar2  default null
  ,p_xdf_attribute19                in  varchar2  default null
  ,p_xdf_attribute20                in  varchar2  default null
  ,p_xdf_attribute21                in  varchar2  default null
  ,p_xdf_attribute22                in  varchar2  default null
  ,p_xdf_attribute23                in  varchar2  default null
  ,p_xdf_attribute24                in  varchar2  default null
  ,p_xdf_attribute25                in  varchar2  default null
  ,p_xdf_attribute26                in  varchar2  default null
  ,p_xdf_attribute27                in  varchar2  default null
  ,p_xdf_attribute28                in  varchar2  default null
  ,p_xdf_attribute29                in  varchar2  default null
  ,p_xdf_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_drctry_name                    in  varchar2  default null
  ,p_kickoff_wrt_prc_flag           in  varchar2  default null
  ,p_upd_cm_sent_dt_flag            in  varchar2  default null
  ,p_spcl_hndl_flag                 in  varchar2  default null
  ,p_ext_global_flag                in  varchar2  default 'N'
  ,p_cm_display_flag                in  varchar2  default 'N'
  ,p_use_eff_dt_for_chgs_flag       in  varchar2  default null
  ,p_ext_post_prcs_rl                  in  number    default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ext_dfn_id ben_ext_dfn.ext_dfn_id%TYPE;
  l_proc varchar2(72) := g_package||'create_EXT_DEFN';
  l_object_version_number ben_ext_dfn.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_EXT_DEFN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_EXT_DEFN
    --
    ben_EXT_DEFN_bk1.create_EXT_DEFN_b
      (
       p_name                           =>  p_name
      ,p_xml_tag_name                   =>  p_xml_tag_name
      ,p_xdo_template_id                =>  p_xdo_template_id
      ,p_data_typ_cd                    =>  p_data_typ_cd
      ,p_ext_typ_cd                     =>  p_ext_typ_cd
      ,p_output_name                    =>  p_output_name
      ,p_output_type                    =>  p_output_type
      ,p_apnd_rqst_id_flag              =>  p_apnd_rqst_id_flag
      ,p_prmy_sort_cd                   =>  p_prmy_sort_cd
      ,p_scnd_sort_cd                   =>  p_scnd_sort_cd
      ,p_strt_dt                        =>  p_strt_dt
      ,p_end_dt                         =>  p_end_dt
      ,p_ext_crit_prfl_id               =>  p_ext_crit_prfl_id
      ,p_ext_file_id                    =>  p_ext_file_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xdf_attribute_category         =>  p_xdf_attribute_category
      ,p_xdf_attribute1                 =>  p_xdf_attribute1
      ,p_xdf_attribute2                 =>  p_xdf_attribute2
      ,p_xdf_attribute3                 =>  p_xdf_attribute3
      ,p_xdf_attribute4                 =>  p_xdf_attribute4
      ,p_xdf_attribute5                 =>  p_xdf_attribute5
      ,p_xdf_attribute6                 =>  p_xdf_attribute6
      ,p_xdf_attribute7                 =>  p_xdf_attribute7
      ,p_xdf_attribute8                 =>  p_xdf_attribute8
      ,p_xdf_attribute9                 =>  p_xdf_attribute9
      ,p_xdf_attribute10                =>  p_xdf_attribute10
      ,p_xdf_attribute11                =>  p_xdf_attribute11
      ,p_xdf_attribute12                =>  p_xdf_attribute12
      ,p_xdf_attribute13                =>  p_xdf_attribute13
      ,p_xdf_attribute14                =>  p_xdf_attribute14
      ,p_xdf_attribute15                =>  p_xdf_attribute15
      ,p_xdf_attribute16                =>  p_xdf_attribute16
      ,p_xdf_attribute17                =>  p_xdf_attribute17
      ,p_xdf_attribute18                =>  p_xdf_attribute18
      ,p_xdf_attribute19                =>  p_xdf_attribute19
      ,p_xdf_attribute20                =>  p_xdf_attribute20
      ,p_xdf_attribute21                =>  p_xdf_attribute21
      ,p_xdf_attribute22                =>  p_xdf_attribute22
      ,p_xdf_attribute23                =>  p_xdf_attribute23
      ,p_xdf_attribute24                =>  p_xdf_attribute24
      ,p_xdf_attribute25                =>  p_xdf_attribute25
      ,p_xdf_attribute26                =>  p_xdf_attribute26
      ,p_xdf_attribute27                =>  p_xdf_attribute27
      ,p_xdf_attribute28                =>  p_xdf_attribute28
      ,p_xdf_attribute29                =>  p_xdf_attribute29
      ,p_xdf_attribute30                =>  p_xdf_attribute30
      ,p_drctry_name                    =>  p_drctry_name
      ,p_kickoff_wrt_prc_flag           =>  p_kickoff_wrt_prc_flag
      ,p_upd_cm_sent_dt_flag            =>  p_upd_cm_sent_dt_flag
      ,p_spcl_hndl_flag                 =>  p_spcl_hndl_flag
      ,p_ext_global_flag                =>  p_ext_global_flag
      ,p_cm_display_flag                =>  p_cm_display_flag
      ,p_use_eff_dt_for_chgs_flag       =>  p_use_eff_dt_for_chgs_flag
      ,p_ext_post_prcs_rl               =>  p_ext_post_prcs_rl
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_EXT_DEFN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_EXT_DEFN
    --
  end;
  --
  ben_xdf_ins.ins
    (
     p_ext_dfn_id                    => l_ext_dfn_id
    ,p_name                          => p_name
    ,p_xml_tag_name                  => p_xml_tag_name
    ,p_xdo_template_id               => p_xdo_template_id
    ,p_data_typ_cd                   => p_data_typ_cd
    ,p_ext_typ_cd                    => p_ext_typ_cd
    ,p_output_name                   => p_output_name
    ,p_output_type                   => p_output_type
    ,p_apnd_rqst_id_flag             => p_apnd_rqst_id_flag
    ,p_prmy_sort_cd                  => p_prmy_sort_cd
    ,p_scnd_sort_cd                  => p_scnd_sort_cd
    ,p_strt_dt                       => p_strt_dt
    ,p_end_dt                        => p_end_dt
    ,p_ext_crit_prfl_id              => p_ext_crit_prfl_id
    ,p_ext_file_id                   => p_ext_file_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_xdf_attribute_category        => p_xdf_attribute_category
    ,p_xdf_attribute1                => p_xdf_attribute1
    ,p_xdf_attribute2                => p_xdf_attribute2
    ,p_xdf_attribute3                => p_xdf_attribute3
    ,p_xdf_attribute4                => p_xdf_attribute4
    ,p_xdf_attribute5                => p_xdf_attribute5
    ,p_xdf_attribute6                => p_xdf_attribute6
    ,p_xdf_attribute7                => p_xdf_attribute7
    ,p_xdf_attribute8                => p_xdf_attribute8
    ,p_xdf_attribute9                => p_xdf_attribute9
    ,p_xdf_attribute10               => p_xdf_attribute10
    ,p_xdf_attribute11               => p_xdf_attribute11
    ,p_xdf_attribute12               => p_xdf_attribute12
    ,p_xdf_attribute13               => p_xdf_attribute13
    ,p_xdf_attribute14               => p_xdf_attribute14
    ,p_xdf_attribute15               => p_xdf_attribute15
    ,p_xdf_attribute16               => p_xdf_attribute16
    ,p_xdf_attribute17               => p_xdf_attribute17
    ,p_xdf_attribute18               => p_xdf_attribute18
    ,p_xdf_attribute19               => p_xdf_attribute19
    ,p_xdf_attribute20               => p_xdf_attribute20
    ,p_xdf_attribute21               => p_xdf_attribute21
    ,p_xdf_attribute22               => p_xdf_attribute22
    ,p_xdf_attribute23               => p_xdf_attribute23
    ,p_xdf_attribute24               => p_xdf_attribute24
    ,p_xdf_attribute25               => p_xdf_attribute25
    ,p_xdf_attribute26               => p_xdf_attribute26
    ,p_xdf_attribute27               => p_xdf_attribute27
    ,p_xdf_attribute28               => p_xdf_attribute28
    ,p_xdf_attribute29               => p_xdf_attribute29
    ,p_xdf_attribute30               => p_xdf_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_drctry_name                   => p_drctry_name
    ,p_kickoff_wrt_prc_flag          => p_kickoff_wrt_prc_flag
    ,p_upd_cm_sent_dt_flag           => p_upd_cm_sent_dt_flag
    ,p_spcl_hndl_flag                => p_spcl_hndl_flag
    ,p_ext_global_flag               => p_ext_global_flag
    ,p_cm_display_flag               => p_cm_display_flag
    ,p_use_eff_dt_for_chgs_flag      => p_use_eff_dt_for_chgs_flag
    ,p_ext_post_prcs_rl              => p_ext_post_prcs_rl
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_EXT_DEFN
    --
    ben_EXT_DEFN_bk1.create_EXT_DEFN_a
      (
       p_ext_dfn_id                     =>  l_ext_dfn_id
      ,p_name                           =>  p_name
      ,p_xml_tag_name                   =>  p_xml_tag_name
      ,p_xdo_template_id                =>  p_xdo_template_id
      ,p_data_typ_cd                    =>  p_data_typ_cd
      ,p_ext_typ_cd                     =>  p_ext_typ_cd
      ,p_output_name                    =>  p_output_name
      ,p_output_type                    =>  p_output_type
      ,p_apnd_rqst_id_flag              =>  p_apnd_rqst_id_flag
      ,p_prmy_sort_cd                   =>  p_prmy_sort_cd
      ,p_scnd_sort_cd                   =>  p_scnd_sort_cd
      ,p_strt_dt                        =>  p_strt_dt
      ,p_end_dt                         =>  p_end_dt
      ,p_ext_crit_prfl_id               =>  p_ext_crit_prfl_id
      ,p_ext_file_id                    =>  p_ext_file_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xdf_attribute_category         =>  p_xdf_attribute_category
      ,p_xdf_attribute1                 =>  p_xdf_attribute1
      ,p_xdf_attribute2                 =>  p_xdf_attribute2
      ,p_xdf_attribute3                 =>  p_xdf_attribute3
      ,p_xdf_attribute4                 =>  p_xdf_attribute4
      ,p_xdf_attribute5                 =>  p_xdf_attribute5
      ,p_xdf_attribute6                 =>  p_xdf_attribute6
      ,p_xdf_attribute7                 =>  p_xdf_attribute7
      ,p_xdf_attribute8                 =>  p_xdf_attribute8
      ,p_xdf_attribute9                 =>  p_xdf_attribute9
      ,p_xdf_attribute10                =>  p_xdf_attribute10
      ,p_xdf_attribute11                =>  p_xdf_attribute11
      ,p_xdf_attribute12                =>  p_xdf_attribute12
      ,p_xdf_attribute13                =>  p_xdf_attribute13
      ,p_xdf_attribute14                =>  p_xdf_attribute14
      ,p_xdf_attribute15                =>  p_xdf_attribute15
      ,p_xdf_attribute16                =>  p_xdf_attribute16
      ,p_xdf_attribute17                =>  p_xdf_attribute17
      ,p_xdf_attribute18                =>  p_xdf_attribute18
      ,p_xdf_attribute19                =>  p_xdf_attribute19
      ,p_xdf_attribute20                =>  p_xdf_attribute20
      ,p_xdf_attribute21                =>  p_xdf_attribute21
      ,p_xdf_attribute22                =>  p_xdf_attribute22
      ,p_xdf_attribute23                =>  p_xdf_attribute23
      ,p_xdf_attribute24                =>  p_xdf_attribute24
      ,p_xdf_attribute25                =>  p_xdf_attribute25
      ,p_xdf_attribute26                =>  p_xdf_attribute26
      ,p_xdf_attribute27                =>  p_xdf_attribute27
      ,p_xdf_attribute28                =>  p_xdf_attribute28
      ,p_xdf_attribute29                =>  p_xdf_attribute29
      ,p_xdf_attribute30                =>  p_xdf_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_drctry_name                    =>  p_drctry_name
      ,p_kickoff_wrt_prc_flag           =>  p_kickoff_wrt_prc_flag
      ,p_upd_cm_sent_dt_flag            =>  p_upd_cm_sent_dt_flag
      ,p_spcl_hndl_flag                 =>  p_spcl_hndl_flag
      ,p_ext_global_flag                =>  p_ext_global_flag
      ,p_cm_display_flag                =>  p_cm_display_flag
      ,p_use_eff_dt_for_chgs_flag       =>  p_use_eff_dt_for_chgs_flag
      ,p_ext_post_prcs_rl               =>  p_ext_post_prcs_rl
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_EXT_DEFN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_EXT_DEFN
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
  p_ext_dfn_id := l_ext_dfn_id;
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
    ROLLBACK TO create_EXT_DEFN;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ext_dfn_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_EXT_DEFN;
    --
    -- NOCOPY changes.
    --
    p_ext_dfn_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
    raise;
    --
end create_EXT_DEFN;
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_DEFN >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_DEFN
  (p_validate                       in  boolean   default false
  ,p_ext_dfn_id                     in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_xml_tag_name                   in  varchar2  default hr_api.g_varchar2
  ,p_xdo_template_id                in  number    default hr_api.g_number
  ,p_data_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_ext_typ_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_output_name                    in  varchar2  default hr_api.g_varchar2
  ,p_output_type                    in  varchar2  default hr_api.g_varchar2
  ,p_apnd_rqst_id_flag              in  varchar2  default hr_api.g_varchar2
  ,p_prmy_sort_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_scnd_sort_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_strt_dt                        in  varchar2  default hr_api.g_varchar2
  ,p_end_dt                         in  varchar2  default hr_api.g_varchar2
  ,p_ext_crit_prfl_id               in  number    default hr_api.g_number
  ,p_ext_file_id                    in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_xdf_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_drctry_name                    in  varchar2  default hr_api.g_varchar2
  ,p_kickoff_wrt_prc_flag           in  varchar2  default hr_api.g_varchar2
  ,p_upd_cm_sent_dt_flag            in  varchar2  default hr_api.g_varchar2
  ,p_spcl_hndl_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_ext_global_flag                in  varchar2  default hr_api.g_varchar2
  ,p_cm_display_flag                in  varchar2  default hr_api.g_varchar2
  ,p_use_eff_dt_for_chgs_flag       in  varchar2  default hr_api.g_varchar2
  ,p_ext_post_prcs_rl               in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_DEFN';
  l_object_version_number ben_ext_dfn.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_EXT_DEFN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_EXT_DEFN
    --
    ben_EXT_DEFN_bk2.update_EXT_DEFN_b
      (
       p_ext_dfn_id                     =>  p_ext_dfn_id
      ,p_name                           =>  p_name
      ,p_xml_tag_name                   =>  p_xml_tag_name
      ,p_xdo_template_id                =>  p_xdo_template_id
      ,p_data_typ_cd                    =>  p_data_typ_cd
      ,p_ext_typ_cd                     =>  p_ext_typ_cd
      ,p_output_name                    =>  p_output_name
      ,p_output_type                    =>  p_output_type
      ,p_apnd_rqst_id_flag              =>  p_apnd_rqst_id_flag
      ,p_prmy_sort_cd                   =>  p_prmy_sort_cd
      ,p_scnd_sort_cd                   =>  p_scnd_sort_cd
      ,p_strt_dt                        =>  p_strt_dt
      ,p_end_dt                         =>  p_end_dt
      ,p_ext_crit_prfl_id               =>  p_ext_crit_prfl_id
      ,p_ext_file_id                    =>  p_ext_file_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xdf_attribute_category         =>  p_xdf_attribute_category
      ,p_xdf_attribute1                 =>  p_xdf_attribute1
      ,p_xdf_attribute2                 =>  p_xdf_attribute2
      ,p_xdf_attribute3                 =>  p_xdf_attribute3
      ,p_xdf_attribute4                 =>  p_xdf_attribute4
      ,p_xdf_attribute5                 =>  p_xdf_attribute5
      ,p_xdf_attribute6                 =>  p_xdf_attribute6
      ,p_xdf_attribute7                 =>  p_xdf_attribute7
      ,p_xdf_attribute8                 =>  p_xdf_attribute8
      ,p_xdf_attribute9                 =>  p_xdf_attribute9
      ,p_xdf_attribute10                =>  p_xdf_attribute10
      ,p_xdf_attribute11                =>  p_xdf_attribute11
      ,p_xdf_attribute12                =>  p_xdf_attribute12
      ,p_xdf_attribute13                =>  p_xdf_attribute13
      ,p_xdf_attribute14                =>  p_xdf_attribute14
      ,p_xdf_attribute15                =>  p_xdf_attribute15
      ,p_xdf_attribute16                =>  p_xdf_attribute16
      ,p_xdf_attribute17                =>  p_xdf_attribute17
      ,p_xdf_attribute18                =>  p_xdf_attribute18
      ,p_xdf_attribute19                =>  p_xdf_attribute19
      ,p_xdf_attribute20                =>  p_xdf_attribute20
      ,p_xdf_attribute21                =>  p_xdf_attribute21
      ,p_xdf_attribute22                =>  p_xdf_attribute22
      ,p_xdf_attribute23                =>  p_xdf_attribute23
      ,p_xdf_attribute24                =>  p_xdf_attribute24
      ,p_xdf_attribute25                =>  p_xdf_attribute25
      ,p_xdf_attribute26                =>  p_xdf_attribute26
      ,p_xdf_attribute27                =>  p_xdf_attribute27
      ,p_xdf_attribute28                =>  p_xdf_attribute28
      ,p_xdf_attribute29                =>  p_xdf_attribute29
      ,p_xdf_attribute30                =>  p_xdf_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_drctry_name                    =>  p_drctry_name
      ,p_kickoff_wrt_prc_flag           =>  p_kickoff_wrt_prc_flag
      ,p_upd_cm_sent_dt_flag            =>  p_upd_cm_sent_dt_flag
      ,p_spcl_hndl_flag                 =>  p_spcl_hndl_flag
      ,p_ext_global_flag                =>  p_ext_global_flag
      ,p_cm_display_flag                =>  p_cm_display_flag
      ,p_use_eff_dt_for_chgs_flag       =>  p_use_eff_dt_for_chgs_flag
      ,p_ext_post_prcs_rl               =>  p_ext_post_prcs_rl
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_DEFN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_EXT_DEFN
    --
  end;
  --
  ben_xdf_upd.upd
    (
     p_ext_dfn_id                    => p_ext_dfn_id
    ,p_name                          => p_name
    ,p_xml_tag_name                  => p_xml_tag_name
    ,p_xdo_template_id               => p_xdo_template_id
    ,p_data_typ_cd                   => p_data_typ_cd
    ,p_ext_typ_cd                    => p_ext_typ_cd
    ,p_output_name                   => p_output_name
    ,p_output_type                   => p_output_type
    ,p_apnd_rqst_id_flag             => p_apnd_rqst_id_flag
    ,p_prmy_sort_cd                  => p_prmy_sort_cd
    ,p_scnd_sort_cd                  => p_scnd_sort_cd
    ,p_strt_dt                       => p_strt_dt
    ,p_end_dt                        => p_end_dt
    ,p_ext_crit_prfl_id              => p_ext_crit_prfl_id
    ,p_ext_file_id                   => p_ext_file_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_xdf_attribute_category        => p_xdf_attribute_category
    ,p_xdf_attribute1                => p_xdf_attribute1
    ,p_xdf_attribute2                => p_xdf_attribute2
    ,p_xdf_attribute3                => p_xdf_attribute3
    ,p_xdf_attribute4                => p_xdf_attribute4
    ,p_xdf_attribute5                => p_xdf_attribute5
    ,p_xdf_attribute6                => p_xdf_attribute6
    ,p_xdf_attribute7                => p_xdf_attribute7
    ,p_xdf_attribute8                => p_xdf_attribute8
    ,p_xdf_attribute9                => p_xdf_attribute9
    ,p_xdf_attribute10               => p_xdf_attribute10
    ,p_xdf_attribute11               => p_xdf_attribute11
    ,p_xdf_attribute12               => p_xdf_attribute12
    ,p_xdf_attribute13               => p_xdf_attribute13
    ,p_xdf_attribute14               => p_xdf_attribute14
    ,p_xdf_attribute15               => p_xdf_attribute15
    ,p_xdf_attribute16               => p_xdf_attribute16
    ,p_xdf_attribute17               => p_xdf_attribute17
    ,p_xdf_attribute18               => p_xdf_attribute18
    ,p_xdf_attribute19               => p_xdf_attribute19
    ,p_xdf_attribute20               => p_xdf_attribute20
    ,p_xdf_attribute21               => p_xdf_attribute21
    ,p_xdf_attribute22               => p_xdf_attribute22
    ,p_xdf_attribute23               => p_xdf_attribute23
    ,p_xdf_attribute24               => p_xdf_attribute24
    ,p_xdf_attribute25               => p_xdf_attribute25
    ,p_xdf_attribute26               => p_xdf_attribute26
    ,p_xdf_attribute27               => p_xdf_attribute27
    ,p_xdf_attribute28               => p_xdf_attribute28
    ,p_xdf_attribute29               => p_xdf_attribute29
    ,p_xdf_attribute30               => p_xdf_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_drctry_name                   => p_drctry_name
    ,p_kickoff_wrt_prc_flag          => p_kickoff_wrt_prc_flag
    ,p_upd_cm_sent_dt_flag           => p_upd_cm_sent_dt_flag
    ,p_spcl_hndl_flag                => p_spcl_hndl_flag
    ,p_ext_global_flag               => p_ext_global_flag
    ,p_cm_display_flag               => p_cm_display_flag
    ,p_use_eff_dt_for_chgs_flag      => p_use_eff_dt_for_chgs_flag
    ,p_ext_post_prcs_rl               =>  p_ext_post_prcs_rl
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_EXT_DEFN
    --
    ben_EXT_DEFN_bk2.update_EXT_DEFN_a
      (
       p_ext_dfn_id                     =>  p_ext_dfn_id
      ,p_name                           =>  p_name
      ,p_xml_tag_name                   =>  p_xml_tag_name
      ,p_xdo_template_id                =>  p_xdo_template_id
      ,p_data_typ_cd                    =>  p_data_typ_cd
      ,p_ext_typ_cd                     =>  p_ext_typ_cd
      ,p_output_name                    =>  p_output_name
      ,p_output_type                    =>  p_output_type
      ,p_apnd_rqst_id_flag              =>  p_apnd_rqst_id_flag
      ,p_prmy_sort_cd                   =>  p_prmy_sort_cd
      ,p_scnd_sort_cd                   =>  p_scnd_sort_cd
      ,p_strt_dt                        =>  p_strt_dt
      ,p_end_dt                         =>  p_end_dt
      ,p_ext_crit_prfl_id               =>  p_ext_crit_prfl_id
      ,p_ext_file_id                    =>  p_ext_file_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xdf_attribute_category         =>  p_xdf_attribute_category
      ,p_xdf_attribute1                 =>  p_xdf_attribute1
      ,p_xdf_attribute2                 =>  p_xdf_attribute2
      ,p_xdf_attribute3                 =>  p_xdf_attribute3
      ,p_xdf_attribute4                 =>  p_xdf_attribute4
      ,p_xdf_attribute5                 =>  p_xdf_attribute5
      ,p_xdf_attribute6                 =>  p_xdf_attribute6
      ,p_xdf_attribute7                 =>  p_xdf_attribute7
      ,p_xdf_attribute8                 =>  p_xdf_attribute8
      ,p_xdf_attribute9                 =>  p_xdf_attribute9
      ,p_xdf_attribute10                =>  p_xdf_attribute10
      ,p_xdf_attribute11                =>  p_xdf_attribute11
      ,p_xdf_attribute12                =>  p_xdf_attribute12
      ,p_xdf_attribute13                =>  p_xdf_attribute13
      ,p_xdf_attribute14                =>  p_xdf_attribute14
      ,p_xdf_attribute15                =>  p_xdf_attribute15
      ,p_xdf_attribute16                =>  p_xdf_attribute16
      ,p_xdf_attribute17                =>  p_xdf_attribute17
      ,p_xdf_attribute18                =>  p_xdf_attribute18
      ,p_xdf_attribute19                =>  p_xdf_attribute19
      ,p_xdf_attribute20                =>  p_xdf_attribute20
      ,p_xdf_attribute21                =>  p_xdf_attribute21
      ,p_xdf_attribute22                =>  p_xdf_attribute22
      ,p_xdf_attribute23                =>  p_xdf_attribute23
      ,p_xdf_attribute24                =>  p_xdf_attribute24
      ,p_xdf_attribute25                =>  p_xdf_attribute25
      ,p_xdf_attribute26                =>  p_xdf_attribute26
      ,p_xdf_attribute27                =>  p_xdf_attribute27
      ,p_xdf_attribute28                =>  p_xdf_attribute28
      ,p_xdf_attribute29                =>  p_xdf_attribute29
      ,p_xdf_attribute30                =>  p_xdf_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_drctry_name                    =>  p_drctry_name
      ,p_kickoff_wrt_prc_flag           =>  p_kickoff_wrt_prc_flag
      ,p_upd_cm_sent_dt_flag            =>  p_upd_cm_sent_dt_flag
      ,p_spcl_hndl_flag                 =>  p_spcl_hndl_flag
      ,p_ext_global_flag                =>  p_ext_global_flag
      ,p_cm_display_flag                =>  p_cm_display_flag
      ,p_use_eff_dt_for_chgs_flag       =>  p_use_eff_dt_for_chgs_flag
      ,p_ext_post_prcs_rl               =>  p_ext_post_prcs_rl
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_DEFN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_EXT_DEFN
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
    ROLLBACK TO update_EXT_DEFN;
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
    ROLLBACK TO update_EXT_DEFN;
    --
    -- NOCOPY changes.
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
    raise;
    --
end update_EXT_DEFN;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_DEFN >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_DEFN
  (p_validate                       in  boolean  default false
  ,p_ext_dfn_id                     in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_DEFN';
  l_object_version_number ben_ext_dfn.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_EXT_DEFN;
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
    -- Start of API User Hook for the before hook of delete_EXT_DEFN
    --
    ben_EXT_DEFN_bk3.delete_EXT_DEFN_b
      (
       p_ext_dfn_id                     =>  p_ext_dfn_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_DEFN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_EXT_DEFN
    --
  end;
  --
  ben_xdf_del.del
    (
     p_ext_dfn_id                    => p_ext_dfn_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_EXT_DEFN
    --
    ben_EXT_DEFN_bk3.delete_EXT_DEFN_a
      (
       p_ext_dfn_id                     =>  p_ext_dfn_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_DEFN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_EXT_DEFN
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
    ROLLBACK TO delete_EXT_DEFN;
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
    ROLLBACK TO delete_EXT_DEFN;
    --
    -- NOCOPY changes.
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
    raise;
    --
end delete_EXT_DEFN;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ext_dfn_id                   in     number
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
  ben_xdf_shd.lck
    (
      p_ext_dfn_id                 => p_ext_dfn_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_EXT_DEFN_api;

/
