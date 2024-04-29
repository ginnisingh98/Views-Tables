--------------------------------------------------------
--  DDL for Package Body BEN_OPTION_DEFINITION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_OPTION_DEFINITION_API" as
/* $Header: beoptapi.pkb 120.0 2005/05/28 09:56:10 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_option_definition_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_option_definition >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_option_definition
  (p_validate                       in  boolean   default false
  ,p_opt_id                         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_opt_attribute_category         in  varchar2  default null
  ,p_opt_attribute1                 in  varchar2  default null
  ,p_opt_attribute2                 in  varchar2  default null
  ,p_opt_attribute3                 in  varchar2  default null
  ,p_opt_attribute4                 in  varchar2  default null
  ,p_opt_attribute5                 in  varchar2  default null
  ,p_opt_attribute6                 in  varchar2  default null
  ,p_opt_attribute7                 in  varchar2  default null
  ,p_opt_attribute8                 in  varchar2  default null
  ,p_opt_attribute9                 in  varchar2  default null
  ,p_opt_attribute10                in  varchar2  default null
  ,p_opt_attribute11                in  varchar2  default null
  ,p_opt_attribute12                in  varchar2  default null
  ,p_opt_attribute13                in  varchar2  default null
  ,p_opt_attribute14                in  varchar2  default null
  ,p_opt_attribute15                in  varchar2  default null
  ,p_opt_attribute16                in  varchar2  default null
  ,p_opt_attribute17                in  varchar2  default null
  ,p_opt_attribute18                in  varchar2  default null
  ,p_opt_attribute19                in  varchar2  default null
  ,p_opt_attribute20                in  varchar2  default null
  ,p_opt_attribute21                in  varchar2  default null
  ,p_opt_attribute22                in  varchar2  default null
  ,p_opt_attribute23                in  varchar2  default null
  ,p_opt_attribute24                in  varchar2  default null
  ,p_opt_attribute25                in  varchar2  default null
  ,p_opt_attribute26                in  varchar2  default null
  ,p_opt_attribute27                in  varchar2  default null
  ,p_opt_attribute28                in  varchar2  default null
  ,p_opt_attribute29                in  varchar2  default null
  ,p_opt_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_rqd_perd_enrt_nenrt_uom        in  varchar2  default null
  ,p_rqd_perd_enrt_nenrt_val        in  number    default null
  ,p_rqd_perd_enrt_nenrt_rl         in  number    default null
  ,p_invk_wv_opt_flag               in  varchar2  default 'N'
  ,p_short_name			    in  varchar2  default null
  ,p_short_code			    in  varchar2  default null
  ,p_legislation_code		    in  varchar2  default null
  ,p_legislation_subgroup	    in  varchar2  default null
  ,p_group_opt_id          	    in  number    default null
  ,p_component_reason		    in  varchar2  default null
  ,p_mapping_table_name             in  varchar2  default null
  ,p_mapping_table_pk_id            in  number    default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_opt_id ben_opt_f.opt_id%TYPE;
  l_effective_start_date ben_opt_f.effective_start_date%TYPE;
  l_effective_end_date ben_opt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_option_definition';
  l_object_version_number ben_opt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_option_definition;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_option_definition
    --
    ben_option_definition_bk1.create_option_definition_b
      (
       p_name                           =>  p_name
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_opt_attribute_category         =>  p_opt_attribute_category
      ,p_opt_attribute1                 =>  p_opt_attribute1
      ,p_opt_attribute2                 =>  p_opt_attribute2
      ,p_opt_attribute3                 =>  p_opt_attribute3
      ,p_opt_attribute4                 =>  p_opt_attribute4
      ,p_opt_attribute5                 =>  p_opt_attribute5
      ,p_opt_attribute6                 =>  p_opt_attribute6
      ,p_opt_attribute7                 =>  p_opt_attribute7
      ,p_opt_attribute8                 =>  p_opt_attribute8
      ,p_opt_attribute9                 =>  p_opt_attribute9
      ,p_opt_attribute10                =>  p_opt_attribute10
      ,p_opt_attribute11                =>  p_opt_attribute11
      ,p_opt_attribute12                =>  p_opt_attribute12
      ,p_opt_attribute13                =>  p_opt_attribute13
      ,p_opt_attribute14                =>  p_opt_attribute14
      ,p_opt_attribute15                =>  p_opt_attribute15
      ,p_opt_attribute16                =>  p_opt_attribute16
      ,p_opt_attribute17                =>  p_opt_attribute17
      ,p_opt_attribute18                =>  p_opt_attribute18
      ,p_opt_attribute19                =>  p_opt_attribute19
      ,p_opt_attribute20                =>  p_opt_attribute20
      ,p_opt_attribute21                =>  p_opt_attribute21
      ,p_opt_attribute22                =>  p_opt_attribute22
      ,p_opt_attribute23                =>  p_opt_attribute23
      ,p_opt_attribute24                =>  p_opt_attribute24
      ,p_opt_attribute25                =>  p_opt_attribute25
      ,p_opt_attribute26                =>  p_opt_attribute26
      ,p_opt_attribute27                =>  p_opt_attribute27
      ,p_opt_attribute28                =>  p_opt_attribute28
      ,p_opt_attribute29                =>  p_opt_attribute29
      ,p_opt_attribute30                =>  p_opt_attribute30
      ,p_rqd_perd_enrt_nenrt_uom        =>  p_rqd_perd_enrt_nenrt_uom
      ,p_rqd_perd_enrt_nenrt_val        =>  p_rqd_perd_enrt_nenrt_val
      ,p_rqd_perd_enrt_nenrt_rl         =>  p_rqd_perd_enrt_nenrt_rl
      ,p_invk_wv_opt_flag               =>  p_invk_wv_opt_flag
      ,p_short_name                     =>  p_short_name
      ,p_short_code                     =>  p_short_code
      ,p_legislation_code               =>  p_legislation_code
      ,p_legislation_subgroup           =>  p_legislation_subgroup
      ,p_group_opt_id                   =>  p_group_opt_id
      ,p_component_reason		=>  p_component_reason
      ,p_mapping_table_name             =>  p_mapping_table_name
      ,p_mapping_table_pk_id            =>  p_mapping_table_pk_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_option_definition'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_option_definition
    --
  end;
  --
  ben_opt_ins.ins
    (
     p_opt_id                        => l_opt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_cmbn_ptip_opt_id              => p_cmbn_ptip_opt_id
    ,p_business_group_id             => p_business_group_id
    ,p_opt_attribute_category        => p_opt_attribute_category
    ,p_opt_attribute1                => p_opt_attribute1
    ,p_opt_attribute2                => p_opt_attribute2
    ,p_opt_attribute3                => p_opt_attribute3
    ,p_opt_attribute4                => p_opt_attribute4
    ,p_opt_attribute5                => p_opt_attribute5
    ,p_opt_attribute6                => p_opt_attribute6
    ,p_opt_attribute7                => p_opt_attribute7
    ,p_opt_attribute8                => p_opt_attribute8
    ,p_opt_attribute9                => p_opt_attribute9
    ,p_opt_attribute10               => p_opt_attribute10
    ,p_opt_attribute11               => p_opt_attribute11
    ,p_opt_attribute12               => p_opt_attribute12
    ,p_opt_attribute13               => p_opt_attribute13
    ,p_opt_attribute14               => p_opt_attribute14
    ,p_opt_attribute15               => p_opt_attribute15
    ,p_opt_attribute16               => p_opt_attribute16
    ,p_opt_attribute17               => p_opt_attribute17
    ,p_opt_attribute18               => p_opt_attribute18
    ,p_opt_attribute19               => p_opt_attribute19
    ,p_opt_attribute20               => p_opt_attribute20
    ,p_opt_attribute21               => p_opt_attribute21
    ,p_opt_attribute22               => p_opt_attribute22
    ,p_opt_attribute23               => p_opt_attribute23
    ,p_opt_attribute24               => p_opt_attribute24
    ,p_opt_attribute25               => p_opt_attribute25
    ,p_opt_attribute26               => p_opt_attribute26
    ,p_opt_attribute27               => p_opt_attribute27
    ,p_opt_attribute28               => p_opt_attribute28
    ,p_opt_attribute29               => p_opt_attribute29
    ,p_opt_attribute30               => p_opt_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_rqd_perd_enrt_nenrt_uom       => p_rqd_perd_enrt_nenrt_uom
    ,p_rqd_perd_enrt_nenrt_val       => p_rqd_perd_enrt_nenrt_val
    ,p_rqd_perd_enrt_nenrt_rl        => p_rqd_perd_enrt_nenrt_rl
    ,p_invk_wv_opt_flag              => p_invk_wv_opt_flag
    ,p_short_name                    => p_short_name
    ,p_short_code                    => p_short_code
    ,p_legislation_code              => p_legislation_code
    ,p_legislation_subgroup          => p_legislation_subgroup
    ,p_group_opt_id                  => p_group_opt_id
    ,p_component_reason		     => p_component_reason
    ,p_mapping_table_name            => p_mapping_table_name
    ,p_mapping_table_pk_id           => p_mapping_table_pk_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_option_definition
    --
    ben_option_definition_bk1.create_option_definition_a
      (
       p_opt_id                         =>  l_opt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_opt_attribute_category         =>  p_opt_attribute_category
      ,p_opt_attribute1                 =>  p_opt_attribute1
      ,p_opt_attribute2                 =>  p_opt_attribute2
      ,p_opt_attribute3                 =>  p_opt_attribute3
      ,p_opt_attribute4                 =>  p_opt_attribute4
      ,p_opt_attribute5                 =>  p_opt_attribute5
      ,p_opt_attribute6                 =>  p_opt_attribute6
      ,p_opt_attribute7                 =>  p_opt_attribute7
      ,p_opt_attribute8                 =>  p_opt_attribute8
      ,p_opt_attribute9                 =>  p_opt_attribute9
      ,p_opt_attribute10                =>  p_opt_attribute10
      ,p_opt_attribute11                =>  p_opt_attribute11
      ,p_opt_attribute12                =>  p_opt_attribute12
      ,p_opt_attribute13                =>  p_opt_attribute13
      ,p_opt_attribute14                =>  p_opt_attribute14
      ,p_opt_attribute15                =>  p_opt_attribute15
      ,p_opt_attribute16                =>  p_opt_attribute16
      ,p_opt_attribute17                =>  p_opt_attribute17
      ,p_opt_attribute18                =>  p_opt_attribute18
      ,p_opt_attribute19                =>  p_opt_attribute19
      ,p_opt_attribute20                =>  p_opt_attribute20
      ,p_opt_attribute21                =>  p_opt_attribute21
      ,p_opt_attribute22                =>  p_opt_attribute22
      ,p_opt_attribute23                =>  p_opt_attribute23
      ,p_opt_attribute24                =>  p_opt_attribute24
      ,p_opt_attribute25                =>  p_opt_attribute25
      ,p_opt_attribute26                =>  p_opt_attribute26
      ,p_opt_attribute27                =>  p_opt_attribute27
      ,p_opt_attribute28                =>  p_opt_attribute28
      ,p_opt_attribute29                =>  p_opt_attribute29
      ,p_opt_attribute30                =>  p_opt_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_rqd_perd_enrt_nenrt_uom        =>  p_rqd_perd_enrt_nenrt_uom
      ,p_rqd_perd_enrt_nenrt_val        =>  p_rqd_perd_enrt_nenrt_val
      ,p_rqd_perd_enrt_nenrt_rl         =>  p_rqd_perd_enrt_nenrt_rl
      ,p_invk_wv_opt_flag               =>  p_invk_wv_opt_flag
      ,p_short_name                     =>  p_short_name
      ,p_short_code                     =>  p_short_code
      ,p_legislation_code               =>  p_legislation_code
      ,p_legislation_subgroup           =>  p_legislation_subgroup
      ,p_group_opt_id                   =>  p_group_opt_id
      ,p_component_reason		=>  p_component_reason
      ,p_mapping_table_name             =>  p_mapping_table_name
      ,p_mapping_table_pk_id            =>  p_mapping_table_pk_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_option_definition'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_option_definition
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
  p_opt_id := l_opt_id;
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
    ROLLBACK TO create_option_definition;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_opt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_option_definition;
    	-- Added the following code for NOCOPY Changes.
    	p_opt_id := null;
	    p_effective_start_date := null;
	    p_effective_end_date := null;
    	p_object_version_number  := null;
    	-- Added the above code for NOCOPY Changes.
    raise;
    --
end create_option_definition;
-- ----------------------------------------------------------------------------
-- |------------------------< update_option_definition >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_option_definition
  (p_validate                       in  boolean   default false
  ,p_opt_id                         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_cmbn_ptip_opt_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_opt_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_opt_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_rqd_perd_enrt_nenrt_uom        in  varchar2  default hr_api.g_varchar2
  ,p_rqd_perd_enrt_nenrt_val        in  number    default hr_api.g_number
  ,p_rqd_perd_enrt_nenrt_rl         in  number    default hr_api.g_number
  ,p_invk_wv_opt_flag               in  varchar2  default hr_api.g_varchar2
  ,p_short_name                     in  varchar2  default hr_api.g_varchar2
  ,p_short_code                     in  varchar2  default hr_api.g_varchar2
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_legislation_subgroup           in  varchar2  default hr_api.g_varchar2
  ,p_group_opt_id                   in  number    default hr_api.g_number
  ,p_component_reason		    in  varchar2  default hr_api.g_varchar2
  ,p_mapping_table_name             in  varchar2  default hr_api.g_varchar2
  ,p_mapping_table_pk_id            in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_option_definition';
  l_object_version_number ben_opt_f.object_version_number%TYPE;
  l_effective_start_date ben_opt_f.effective_start_date%TYPE;
  l_effective_end_date ben_opt_f.effective_end_date%TYPE;
  --
  l_group_opt_id     number(15) ;
  cursor c_ptp  (p_opt_id in number) is
        select count(*)
        from ben_pl_typ_opt_typ_f
        where pl_typ_opt_typ_cd = 'CWB'
        and opt_id = p_opt_id
        and p_effective_date between effective_start_date and effective_end_date;
  l_count_cwb_pl_typ number;

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_option_definition;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;


  -- if the option id us null and plan type attahed to option is
  -- cwb , then copy the opt id to group_opt_id
  l_group_opt_id := p_group_opt_id  ;
  if l_group_opt_id is null  then

     open c_ptp (p_opt_id ) ;
     fetch c_ptp into l_count_cwb_pl_typ ;
     close c_ptp ;
     hr_utility.set_location(' cwb count '|| l_count_cwb_pl_typ , 60);
     if  l_count_cwb_pl_typ > 0   then
        l_group_opt_id := p_opt_id ;
     end if ;

  end if ;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_option_definition
    --
    ben_option_definition_bk2.update_option_definition_b
      (
       p_opt_id                         =>  p_opt_id
      ,p_name                           =>  p_name
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_opt_attribute_category         =>  p_opt_attribute_category
      ,p_opt_attribute1                 =>  p_opt_attribute1
      ,p_opt_attribute2                 =>  p_opt_attribute2
      ,p_opt_attribute3                 =>  p_opt_attribute3
      ,p_opt_attribute4                 =>  p_opt_attribute4
      ,p_opt_attribute5                 =>  p_opt_attribute5
      ,p_opt_attribute6                 =>  p_opt_attribute6
      ,p_opt_attribute7                 =>  p_opt_attribute7
      ,p_opt_attribute8                 =>  p_opt_attribute8
      ,p_opt_attribute9                 =>  p_opt_attribute9
      ,p_opt_attribute10                =>  p_opt_attribute10
      ,p_opt_attribute11                =>  p_opt_attribute11
      ,p_opt_attribute12                =>  p_opt_attribute12
      ,p_opt_attribute13                =>  p_opt_attribute13
      ,p_opt_attribute14                =>  p_opt_attribute14
      ,p_opt_attribute15                =>  p_opt_attribute15
      ,p_opt_attribute16                =>  p_opt_attribute16
      ,p_opt_attribute17                =>  p_opt_attribute17
      ,p_opt_attribute18                =>  p_opt_attribute18
      ,p_opt_attribute19                =>  p_opt_attribute19
      ,p_opt_attribute20                =>  p_opt_attribute20
      ,p_opt_attribute21                =>  p_opt_attribute21
      ,p_opt_attribute22                =>  p_opt_attribute22
      ,p_opt_attribute23                =>  p_opt_attribute23
      ,p_opt_attribute24                =>  p_opt_attribute24
      ,p_opt_attribute25                =>  p_opt_attribute25
      ,p_opt_attribute26                =>  p_opt_attribute26
      ,p_opt_attribute27                =>  p_opt_attribute27
      ,p_opt_attribute28                =>  p_opt_attribute28
      ,p_opt_attribute29                =>  p_opt_attribute29
      ,p_opt_attribute30                =>  p_opt_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_rqd_perd_enrt_nenrt_uom        =>  p_rqd_perd_enrt_nenrt_uom
      ,p_rqd_perd_enrt_nenrt_val        =>  p_rqd_perd_enrt_nenrt_val
      ,p_rqd_perd_enrt_nenrt_rl         =>  p_rqd_perd_enrt_nenrt_rl
      ,p_invk_wv_opt_flag               =>  p_invk_wv_opt_flag
      ,p_short_name                     =>  p_short_name
      ,p_short_code                     =>  p_short_code
      ,p_legislation_code               =>  p_legislation_code
      ,p_legislation_subgroup           =>  p_legislation_subgroup
      ,p_group_opt_id                   =>  l_group_opt_id
      ,p_component_reason		=>  p_component_reason
      ,p_mapping_table_name             =>  p_mapping_table_name
      ,p_mapping_table_pk_id            =>  p_mapping_table_pk_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_option_definition'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_option_definition
    --
  end;
  --
  ben_opt_upd.upd
    (
     p_opt_id                        => p_opt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_cmbn_ptip_opt_id              => p_cmbn_ptip_opt_id
    ,p_business_group_id             => p_business_group_id
    ,p_opt_attribute_category        => p_opt_attribute_category
    ,p_opt_attribute1                => p_opt_attribute1
    ,p_opt_attribute2                => p_opt_attribute2
    ,p_opt_attribute3                => p_opt_attribute3
    ,p_opt_attribute4                => p_opt_attribute4
    ,p_opt_attribute5                => p_opt_attribute5
    ,p_opt_attribute6                => p_opt_attribute6
    ,p_opt_attribute7                => p_opt_attribute7
    ,p_opt_attribute8                => p_opt_attribute8
    ,p_opt_attribute9                => p_opt_attribute9
    ,p_opt_attribute10               => p_opt_attribute10
    ,p_opt_attribute11               => p_opt_attribute11
    ,p_opt_attribute12               => p_opt_attribute12
    ,p_opt_attribute13               => p_opt_attribute13
    ,p_opt_attribute14               => p_opt_attribute14
    ,p_opt_attribute15               => p_opt_attribute15
    ,p_opt_attribute16               => p_opt_attribute16
    ,p_opt_attribute17               => p_opt_attribute17
    ,p_opt_attribute18               => p_opt_attribute18
    ,p_opt_attribute19               => p_opt_attribute19
    ,p_opt_attribute20               => p_opt_attribute20
    ,p_opt_attribute21               => p_opt_attribute21
    ,p_opt_attribute22               => p_opt_attribute22
    ,p_opt_attribute23               => p_opt_attribute23
    ,p_opt_attribute24               => p_opt_attribute24
    ,p_opt_attribute25               => p_opt_attribute25
    ,p_opt_attribute26               => p_opt_attribute26
    ,p_opt_attribute27               => p_opt_attribute27
    ,p_opt_attribute28               => p_opt_attribute28
    ,p_opt_attribute29               => p_opt_attribute29
    ,p_opt_attribute30               => p_opt_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_rqd_perd_enrt_nenrt_uom       => p_rqd_perd_enrt_nenrt_uom
    ,p_rqd_perd_enrt_nenrt_val       => p_rqd_perd_enrt_nenrt_val
    ,p_rqd_perd_enrt_nenrt_rl        => p_rqd_perd_enrt_nenrt_rl
    ,p_invk_wv_opt_flag              => p_invk_wv_opt_flag
    ,p_short_name                    => p_short_name
    ,p_short_code                    => p_short_code
    ,p_legislation_code              => p_legislation_code
    ,p_legislation_subgroup          => p_legislation_subgroup
    ,p_group_opt_id                  => l_group_opt_id
    ,p_component_reason		     => p_component_reason
    ,p_mapping_table_name            => p_mapping_table_name
    ,p_mapping_table_pk_id           => p_mapping_table_pk_id
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_option_definition
    --
    ben_option_definition_bk2.update_option_definition_a
      (
       p_opt_id                         =>  p_opt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_opt_attribute_category         =>  p_opt_attribute_category
      ,p_opt_attribute1                 =>  p_opt_attribute1
      ,p_opt_attribute2                 =>  p_opt_attribute2
      ,p_opt_attribute3                 =>  p_opt_attribute3
      ,p_opt_attribute4                 =>  p_opt_attribute4
      ,p_opt_attribute5                 =>  p_opt_attribute5
      ,p_opt_attribute6                 =>  p_opt_attribute6
      ,p_opt_attribute7                 =>  p_opt_attribute7
      ,p_opt_attribute8                 =>  p_opt_attribute8
      ,p_opt_attribute9                 =>  p_opt_attribute9
      ,p_opt_attribute10                =>  p_opt_attribute10
      ,p_opt_attribute11                =>  p_opt_attribute11
      ,p_opt_attribute12                =>  p_opt_attribute12
      ,p_opt_attribute13                =>  p_opt_attribute13
      ,p_opt_attribute14                =>  p_opt_attribute14
      ,p_opt_attribute15                =>  p_opt_attribute15
      ,p_opt_attribute16                =>  p_opt_attribute16
      ,p_opt_attribute17                =>  p_opt_attribute17
      ,p_opt_attribute18                =>  p_opt_attribute18
      ,p_opt_attribute19                =>  p_opt_attribute19
      ,p_opt_attribute20                =>  p_opt_attribute20
      ,p_opt_attribute21                =>  p_opt_attribute21
      ,p_opt_attribute22                =>  p_opt_attribute22
      ,p_opt_attribute23                =>  p_opt_attribute23
      ,p_opt_attribute24                =>  p_opt_attribute24
      ,p_opt_attribute25                =>  p_opt_attribute25
      ,p_opt_attribute26                =>  p_opt_attribute26
      ,p_opt_attribute27                =>  p_opt_attribute27
      ,p_opt_attribute28                =>  p_opt_attribute28
      ,p_opt_attribute29                =>  p_opt_attribute29
      ,p_opt_attribute30                =>  p_opt_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_rqd_perd_enrt_nenrt_uom        =>  p_rqd_perd_enrt_nenrt_uom
      ,p_rqd_perd_enrt_nenrt_val        =>  p_rqd_perd_enrt_nenrt_val
      ,p_rqd_perd_enrt_nenrt_rl         =>  p_rqd_perd_enrt_nenrt_rl
      ,p_invk_wv_opt_flag               =>  p_invk_wv_opt_flag
      ,p_short_name                     =>  p_short_name
      ,p_short_code                     =>  p_short_code
      ,p_legislation_code               =>  p_legislation_code
      ,p_legislation_subgroup           =>  p_legislation_subgroup
      ,p_group_opt_id                   =>  l_group_opt_id
      ,p_component_reason		=>  p_component_reason
      ,p_mapping_table_name             =>  p_mapping_table_name
      ,p_mapping_table_pk_id            =>  p_mapping_table_pk_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_option_definition'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_option_definition
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
    ROLLBACK TO update_option_definition;
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
    ROLLBACK TO update_option_definition;
      -- Added the following code for NOCOPY Changes.
	  p_object_version_number := l_object_version_number;
	  p_effective_start_date := null;
      p_effective_end_date := null;
  	  -- Added the above code for NOCOPY Changes.
    raise;
    --
end update_option_definition;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_option_definition >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_option_definition
  (p_validate                       in  boolean  default false
  ,p_opt_id                         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_option_definition';
  l_object_version_number ben_opt_f.object_version_number%TYPE;
  l_effective_start_date ben_opt_f.effective_start_date%TYPE;
  l_effective_end_date ben_opt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_option_definition;
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
    -- Start of API User Hook for the before hook of delete_option_definition
    --
    ben_option_definition_bk3.delete_option_definition_b
      (
       p_opt_id                         =>  p_opt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_option_definition'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_option_definition
    --
  end;
  --
  ben_opt_del.del
    (
     p_opt_id                        => p_opt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_option_definition
    --
    ben_option_definition_bk3.delete_option_definition_a
      (
       p_opt_id                         =>  p_opt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_option_definition'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_option_definition
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
    ROLLBACK TO delete_option_definition;
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
    ROLLBACK TO delete_option_definition;
      -- Added the following code for NOCOPY Changes.
	  p_object_version_number := l_object_version_number;
	  p_effective_start_date := null;
      p_effective_end_date := null;
  	  -- Added the above code for NOCOPY Changes.

    raise;
    --
end delete_option_definition;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_opt_id                   in     number
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
  ben_opt_shd.lck
    (
      p_opt_id                 => p_opt_id
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
end ben_option_definition_api;

/
