--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_TYPE_OPTION_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_TYPE_OPTION_TYPE_API" as
/* $Header: beponapi.pkb 120.0 2005/05/28 10:56:01 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_plan_type_option_type_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_plan_type_option_type >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_plan_type_option_type
  (p_validate                       in  boolean   default false
  ,p_pl_typ_opt_typ_id              out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_pl_typ_opt_typ_cd              in  varchar2  default null
  ,p_opt_id                         in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code         in  varchar2  default null
  ,p_legislation_subgroup         in  varchar2  default null
  ,p_pon_attribute_category         in  varchar2  default null
  ,p_pon_attribute1                 in  varchar2  default null
  ,p_pon_attribute2                 in  varchar2  default null
  ,p_pon_attribute3                 in  varchar2  default null
  ,p_pon_attribute4                 in  varchar2  default null
  ,p_pon_attribute5                 in  varchar2  default null
  ,p_pon_attribute6                 in  varchar2  default null
  ,p_pon_attribute7                 in  varchar2  default null
  ,p_pon_attribute8                 in  varchar2  default null
  ,p_pon_attribute9                 in  varchar2  default null
  ,p_pon_attribute10                in  varchar2  default null
  ,p_pon_attribute11                in  varchar2  default null
  ,p_pon_attribute12                in  varchar2  default null
  ,p_pon_attribute13                in  varchar2  default null
  ,p_pon_attribute14                in  varchar2  default null
  ,p_pon_attribute15                in  varchar2  default null
  ,p_pon_attribute16                in  varchar2  default null
  ,p_pon_attribute17                in  varchar2  default null
  ,p_pon_attribute18                in  varchar2  default null
  ,p_pon_attribute19                in  varchar2  default null
  ,p_pon_attribute20                in  varchar2  default null
  ,p_pon_attribute21                in  varchar2  default null
  ,p_pon_attribute22                in  varchar2  default null
  ,p_pon_attribute23                in  varchar2  default null
  ,p_pon_attribute24                in  varchar2  default null
  ,p_pon_attribute25                in  varchar2  default null
  ,p_pon_attribute26                in  varchar2  default null
  ,p_pon_attribute27                in  varchar2  default null
  ,p_pon_attribute28                in  varchar2  default null
  ,p_pon_attribute29                in  varchar2  default null
  ,p_pon_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pl_typ_opt_typ_id ben_pl_typ_opt_typ_f.pl_typ_opt_typ_id%TYPE;
  l_effective_start_date ben_pl_typ_opt_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_typ_opt_typ_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_plan_type_option_type';
  l_object_version_number ben_pl_typ_opt_typ_f.object_version_number%TYPE;
  --

  --  to find the cwb plan type for updating the  group plan

  cursor c_opt  is
    select  opt.Group_opt_id ,
            opt.object_version_number
      from ben_opt_f opt
           where  opt.opt_id = p_opt_id
             and  p_effective_date between
                  opt.effective_start_date and opt.effective_end_date ;

  cursor c_ptp  is
    select  ptp.opt_typ_cd
      from ben_pl_typ_f  ptp
           where  ptp.pl_typ_id  = p_pl_typ_id
             and  p_effective_date between
                  ptp.effective_start_date and ptp.effective_end_date ;

  l_group_opt_id ben_opt_f.Group_opt_id%type ;
  l_opt_typ_cd   ben_pl_typ_f.opt_typ_cd%type ;
  l_opt_ovn      number ;
  l_eff_st_dt    date   ;
  l_eff_end_dt   date   ;

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_plan_type_option_type;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_plan_type_option_type
    --
    ben_plan_type_option_type_bk1.create_plan_type_option_type_b
      (
       p_pl_typ_opt_typ_cd              =>  p_pl_typ_opt_typ_cd
      ,p_opt_id                         =>  p_opt_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code         =>  p_legislation_code
      ,p_legislation_subgroup         =>  p_legislation_subgroup
      ,p_pon_attribute_category         =>  p_pon_attribute_category
      ,p_pon_attribute1                 =>  p_pon_attribute1
      ,p_pon_attribute2                 =>  p_pon_attribute2
      ,p_pon_attribute3                 =>  p_pon_attribute3
      ,p_pon_attribute4                 =>  p_pon_attribute4
      ,p_pon_attribute5                 =>  p_pon_attribute5
      ,p_pon_attribute6                 =>  p_pon_attribute6
      ,p_pon_attribute7                 =>  p_pon_attribute7
      ,p_pon_attribute8                 =>  p_pon_attribute8
      ,p_pon_attribute9                 =>  p_pon_attribute9
      ,p_pon_attribute10                =>  p_pon_attribute10
      ,p_pon_attribute11                =>  p_pon_attribute11
      ,p_pon_attribute12                =>  p_pon_attribute12
      ,p_pon_attribute13                =>  p_pon_attribute13
      ,p_pon_attribute14                =>  p_pon_attribute14
      ,p_pon_attribute15                =>  p_pon_attribute15
      ,p_pon_attribute16                =>  p_pon_attribute16
      ,p_pon_attribute17                =>  p_pon_attribute17
      ,p_pon_attribute18                =>  p_pon_attribute18
      ,p_pon_attribute19                =>  p_pon_attribute19
      ,p_pon_attribute20                =>  p_pon_attribute20
      ,p_pon_attribute21                =>  p_pon_attribute21
      ,p_pon_attribute22                =>  p_pon_attribute22
      ,p_pon_attribute23                =>  p_pon_attribute23
      ,p_pon_attribute24                =>  p_pon_attribute24
      ,p_pon_attribute25                =>  p_pon_attribute25
      ,p_pon_attribute26                =>  p_pon_attribute26
      ,p_pon_attribute27                =>  p_pon_attribute27
      ,p_pon_attribute28                =>  p_pon_attribute28
      ,p_pon_attribute29                =>  p_pon_attribute29
      ,p_pon_attribute30                =>  p_pon_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_plan_type_option_type'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_plan_type_option_type
    --
  end;
  --
  ben_pon_ins.ins
    (
     p_pl_typ_opt_typ_id             => l_pl_typ_opt_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_pl_typ_opt_typ_cd             => p_pl_typ_opt_typ_cd
    ,p_opt_id                        => p_opt_id
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code        => p_legislation_code
    ,p_legislation_subgroup        => p_legislation_subgroup
    ,p_pon_attribute_category        => p_pon_attribute_category
    ,p_pon_attribute1                => p_pon_attribute1
    ,p_pon_attribute2                => p_pon_attribute2
    ,p_pon_attribute3                => p_pon_attribute3
    ,p_pon_attribute4                => p_pon_attribute4
    ,p_pon_attribute5                => p_pon_attribute5
    ,p_pon_attribute6                => p_pon_attribute6
    ,p_pon_attribute7                => p_pon_attribute7
    ,p_pon_attribute8                => p_pon_attribute8
    ,p_pon_attribute9                => p_pon_attribute9
    ,p_pon_attribute10               => p_pon_attribute10
    ,p_pon_attribute11               => p_pon_attribute11
    ,p_pon_attribute12               => p_pon_attribute12
    ,p_pon_attribute13               => p_pon_attribute13
    ,p_pon_attribute14               => p_pon_attribute14
    ,p_pon_attribute15               => p_pon_attribute15
    ,p_pon_attribute16               => p_pon_attribute16
    ,p_pon_attribute17               => p_pon_attribute17
    ,p_pon_attribute18               => p_pon_attribute18
    ,p_pon_attribute19               => p_pon_attribute19
    ,p_pon_attribute20               => p_pon_attribute20
    ,p_pon_attribute21               => p_pon_attribute21
    ,p_pon_attribute22               => p_pon_attribute22
    ,p_pon_attribute23               => p_pon_attribute23
    ,p_pon_attribute24               => p_pon_attribute24
    ,p_pon_attribute25               => p_pon_attribute25
    ,p_pon_attribute26               => p_pon_attribute26
    ,p_pon_attribute27               => p_pon_attribute27
    ,p_pon_attribute28               => p_pon_attribute28
    ,p_pon_attribute29               => p_pon_attribute29
    ,p_pon_attribute30               => p_pon_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_plan_type_option_type
    --
    ben_plan_type_option_type_bk1.create_plan_type_option_type_a
      (
       p_pl_typ_opt_typ_id              =>  l_pl_typ_opt_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_pl_typ_opt_typ_cd              =>  p_pl_typ_opt_typ_cd
      ,p_opt_id                         =>  p_opt_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code         =>  p_legislation_code
      ,p_legislation_subgroup         =>  p_legislation_subgroup
      ,p_pon_attribute_category         =>  p_pon_attribute_category
      ,p_pon_attribute1                 =>  p_pon_attribute1
      ,p_pon_attribute2                 =>  p_pon_attribute2
      ,p_pon_attribute3                 =>  p_pon_attribute3
      ,p_pon_attribute4                 =>  p_pon_attribute4
      ,p_pon_attribute5                 =>  p_pon_attribute5
      ,p_pon_attribute6                 =>  p_pon_attribute6
      ,p_pon_attribute7                 =>  p_pon_attribute7
      ,p_pon_attribute8                 =>  p_pon_attribute8
      ,p_pon_attribute9                 =>  p_pon_attribute9
      ,p_pon_attribute10                =>  p_pon_attribute10
      ,p_pon_attribute11                =>  p_pon_attribute11
      ,p_pon_attribute12                =>  p_pon_attribute12
      ,p_pon_attribute13                =>  p_pon_attribute13
      ,p_pon_attribute14                =>  p_pon_attribute14
      ,p_pon_attribute15                =>  p_pon_attribute15
      ,p_pon_attribute16                =>  p_pon_attribute16
      ,p_pon_attribute17                =>  p_pon_attribute17
      ,p_pon_attribute18                =>  p_pon_attribute18
      ,p_pon_attribute19                =>  p_pon_attribute19
      ,p_pon_attribute20                =>  p_pon_attribute20
      ,p_pon_attribute21                =>  p_pon_attribute21
      ,p_pon_attribute22                =>  p_pon_attribute22
      ,p_pon_attribute23                =>  p_pon_attribute23
      ,p_pon_attribute24                =>  p_pon_attribute24
      ,p_pon_attribute25                =>  p_pon_attribute25
      ,p_pon_attribute26                =>  p_pon_attribute26
      ,p_pon_attribute27                =>  p_pon_attribute27
      ,p_pon_attribute28                =>  p_pon_attribute28
      ,p_pon_attribute29                =>  p_pon_attribute29
      ,p_pon_attribute30                =>  p_pon_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_plan_type_option_type'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_plan_type_option_type
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --

   hr_utility.set_location(l_proc, 60);
  -- when the  plan type is CWB and  the group_id is null then
  -- update the group  id
  open c_ptp ;
  fetch c_ptp into l_opt_typ_cd ;
  close c_ptp ;
  hr_utility.set_location('OPT TYP CD '|| l_opt_typ_cd , 60);
  if l_opt_typ_cd = 'CWB' then
     open c_opt ;
     fetch c_opt
      into l_group_opt_id ,
            l_opt_ovn ;
     close c_opt ;
     hr_utility.set_location(' l_group_opt_id '||  l_group_opt_id , 60);
     if l_group_opt_id is null then
         BEN_option_definition_API.update_option_definition
                           (p_validate => FALSE
                           ,p_OPT_ID => p_opt_id
                           ,p_EFFECTIVE_START_DATE => l_eff_st_dt
                           ,p_EFFECTIVE_END_DATE   => l_eff_end_dt
                           ,p_group_opt_id         => p_opt_id
                           ,p_OBJECT_VERSION_NUMBER=> l_opt_ovn
                           ,p_effective_date       => p_effective_date
                           ,p_datetrack_mode =>  'CORRECTION'
                          );
     end if ;
  end if ;

  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_pl_typ_opt_typ_id := l_pl_typ_opt_typ_id;
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
    ROLLBACK TO create_plan_type_option_type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pl_typ_opt_typ_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_plan_type_option_type;
    /* Inserted for nocopy changes */
    p_pl_typ_opt_typ_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_plan_type_option_type;
-- ----------------------------------------------------------------------------
-- |------------------------< update_plan_type_option_type >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_plan_type_option_type
  (p_validate                       in  boolean   default false
  ,p_pl_typ_opt_typ_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_pl_typ_opt_typ_cd              in  varchar2  default hr_api.g_varchar2
  ,p_opt_id                         in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code         in  varchar2  default hr_api.g_varchar2
  ,p_legislation_subgroup         in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pon_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_plan_type_option_type';
  l_object_version_number ben_pl_typ_opt_typ_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_typ_opt_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_typ_opt_typ_f.effective_end_date%TYPE;
  --  to find the cwb plan type for updating the  group plan

  cursor c_opt  is
    select  opt.Group_opt_id ,
            opt.object_version_number
      from ben_opt_f opt
           where  opt.opt_id = p_opt_id
             and  p_effective_date between
                  opt.effective_start_date and opt.effective_end_date ;

  cursor c_ptp  is
    select  ptp.opt_typ_cd
      from ben_pl_typ_f  ptp
           where  ptp.pl_typ_id  = p_pl_typ_id
             and  p_effective_date between
                  ptp.effective_start_date and ptp.effective_end_date ;

  l_group_opt_id ben_opt_f.Group_opt_id%type ;
  l_opt_typ_cd   ben_pl_typ_f.opt_typ_cd%type ;
  l_opt_ovn      number ;
  l_eff_st_dt    date   ;
  l_eff_end_dt   date   ;

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_plan_type_option_type;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_plan_type_option_type
    --
    ben_plan_type_option_type_bk2.update_plan_type_option_type_b
      (
       p_pl_typ_opt_typ_id              =>  p_pl_typ_opt_typ_id
      ,p_pl_typ_opt_typ_cd              =>  p_pl_typ_opt_typ_cd
      ,p_opt_id                         =>  p_opt_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code         =>  p_legislation_code
      ,p_legislation_subgroup         =>  p_legislation_subgroup
      ,p_pon_attribute_category         =>  p_pon_attribute_category
      ,p_pon_attribute1                 =>  p_pon_attribute1
      ,p_pon_attribute2                 =>  p_pon_attribute2
      ,p_pon_attribute3                 =>  p_pon_attribute3
      ,p_pon_attribute4                 =>  p_pon_attribute4
      ,p_pon_attribute5                 =>  p_pon_attribute5
      ,p_pon_attribute6                 =>  p_pon_attribute6
      ,p_pon_attribute7                 =>  p_pon_attribute7
      ,p_pon_attribute8                 =>  p_pon_attribute8
      ,p_pon_attribute9                 =>  p_pon_attribute9
      ,p_pon_attribute10                =>  p_pon_attribute10
      ,p_pon_attribute11                =>  p_pon_attribute11
      ,p_pon_attribute12                =>  p_pon_attribute12
      ,p_pon_attribute13                =>  p_pon_attribute13
      ,p_pon_attribute14                =>  p_pon_attribute14
      ,p_pon_attribute15                =>  p_pon_attribute15
      ,p_pon_attribute16                =>  p_pon_attribute16
      ,p_pon_attribute17                =>  p_pon_attribute17
      ,p_pon_attribute18                =>  p_pon_attribute18
      ,p_pon_attribute19                =>  p_pon_attribute19
      ,p_pon_attribute20                =>  p_pon_attribute20
      ,p_pon_attribute21                =>  p_pon_attribute21
      ,p_pon_attribute22                =>  p_pon_attribute22
      ,p_pon_attribute23                =>  p_pon_attribute23
      ,p_pon_attribute24                =>  p_pon_attribute24
      ,p_pon_attribute25                =>  p_pon_attribute25
      ,p_pon_attribute26                =>  p_pon_attribute26
      ,p_pon_attribute27                =>  p_pon_attribute27
      ,p_pon_attribute28                =>  p_pon_attribute28
      ,p_pon_attribute29                =>  p_pon_attribute29
      ,p_pon_attribute30                =>  p_pon_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_plan_type_option_type'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_plan_type_option_type
    --
  end;
  --
  ben_pon_upd.upd
    (
     p_pl_typ_opt_typ_id             => p_pl_typ_opt_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_pl_typ_opt_typ_cd             => p_pl_typ_opt_typ_cd
    ,p_opt_id                        => p_opt_id
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code        => p_legislation_code
    ,p_legislation_subgroup        => p_legislation_subgroup
    ,p_pon_attribute_category        => p_pon_attribute_category
    ,p_pon_attribute1                => p_pon_attribute1
    ,p_pon_attribute2                => p_pon_attribute2
    ,p_pon_attribute3                => p_pon_attribute3
    ,p_pon_attribute4                => p_pon_attribute4
    ,p_pon_attribute5                => p_pon_attribute5
    ,p_pon_attribute6                => p_pon_attribute6
    ,p_pon_attribute7                => p_pon_attribute7
    ,p_pon_attribute8                => p_pon_attribute8
    ,p_pon_attribute9                => p_pon_attribute9
    ,p_pon_attribute10               => p_pon_attribute10
    ,p_pon_attribute11               => p_pon_attribute11
    ,p_pon_attribute12               => p_pon_attribute12
    ,p_pon_attribute13               => p_pon_attribute13
    ,p_pon_attribute14               => p_pon_attribute14
    ,p_pon_attribute15               => p_pon_attribute15
    ,p_pon_attribute16               => p_pon_attribute16
    ,p_pon_attribute17               => p_pon_attribute17
    ,p_pon_attribute18               => p_pon_attribute18
    ,p_pon_attribute19               => p_pon_attribute19
    ,p_pon_attribute20               => p_pon_attribute20
    ,p_pon_attribute21               => p_pon_attribute21
    ,p_pon_attribute22               => p_pon_attribute22
    ,p_pon_attribute23               => p_pon_attribute23
    ,p_pon_attribute24               => p_pon_attribute24
    ,p_pon_attribute25               => p_pon_attribute25
    ,p_pon_attribute26               => p_pon_attribute26
    ,p_pon_attribute27               => p_pon_attribute27
    ,p_pon_attribute28               => p_pon_attribute28
    ,p_pon_attribute29               => p_pon_attribute29
    ,p_pon_attribute30               => p_pon_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_plan_type_option_type
    --
    ben_plan_type_option_type_bk2.update_plan_type_option_type_a
      (
       p_pl_typ_opt_typ_id              =>  p_pl_typ_opt_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_pl_typ_opt_typ_cd              =>  p_pl_typ_opt_typ_cd
      ,p_opt_id                         =>  p_opt_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code         =>  p_legislation_code
      ,p_legislation_subgroup         =>  p_legislation_subgroup
      ,p_pon_attribute_category         =>  p_pon_attribute_category
      ,p_pon_attribute1                 =>  p_pon_attribute1
      ,p_pon_attribute2                 =>  p_pon_attribute2
      ,p_pon_attribute3                 =>  p_pon_attribute3
      ,p_pon_attribute4                 =>  p_pon_attribute4
      ,p_pon_attribute5                 =>  p_pon_attribute5
      ,p_pon_attribute6                 =>  p_pon_attribute6
      ,p_pon_attribute7                 =>  p_pon_attribute7
      ,p_pon_attribute8                 =>  p_pon_attribute8
      ,p_pon_attribute9                 =>  p_pon_attribute9
      ,p_pon_attribute10                =>  p_pon_attribute10
      ,p_pon_attribute11                =>  p_pon_attribute11
      ,p_pon_attribute12                =>  p_pon_attribute12
      ,p_pon_attribute13                =>  p_pon_attribute13
      ,p_pon_attribute14                =>  p_pon_attribute14
      ,p_pon_attribute15                =>  p_pon_attribute15
      ,p_pon_attribute16                =>  p_pon_attribute16
      ,p_pon_attribute17                =>  p_pon_attribute17
      ,p_pon_attribute18                =>  p_pon_attribute18
      ,p_pon_attribute19                =>  p_pon_attribute19
      ,p_pon_attribute20                =>  p_pon_attribute20
      ,p_pon_attribute21                =>  p_pon_attribute21
      ,p_pon_attribute22                =>  p_pon_attribute22
      ,p_pon_attribute23                =>  p_pon_attribute23
      ,p_pon_attribute24                =>  p_pon_attribute24
      ,p_pon_attribute25                =>  p_pon_attribute25
      ,p_pon_attribute26                =>  p_pon_attribute26
      ,p_pon_attribute27                =>  p_pon_attribute27
      ,p_pon_attribute28                =>  p_pon_attribute28
      ,p_pon_attribute29                =>  p_pon_attribute29
      ,p_pon_attribute30                =>  p_pon_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_plan_type_option_type'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_plan_type_option_type
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  -- when the  plan type is CWB and  the group_id is null then
  -- update the group  id
  open c_ptp ;
  fetch c_ptp into l_opt_typ_cd ;
  close c_ptp ;
  hr_utility.set_location('OPT TYP CD '|| l_opt_typ_cd , 60);
  if l_opt_typ_cd = 'CWB' then
     open c_opt ;
     fetch c_opt
      into l_group_opt_id ,
            l_opt_ovn ;
     close c_opt ;
     hr_utility.set_location(' l_group_opt_id '||  l_group_opt_id , 60);
     if l_group_opt_id is null then
         BEN_option_definition_API.update_option_definition
                           (p_validate => FALSE
                           ,p_OPT_ID => p_opt_id
                           ,p_EFFECTIVE_START_DATE => l_eff_st_dt
                           ,p_EFFECTIVE_END_DATE   => l_eff_end_dt
                           ,p_group_opt_id         =>  p_opt_id
                           ,p_OBJECT_VERSION_NUMBER=> l_opt_ovn
                           ,p_effective_date       => p_effective_date
                           ,p_datetrack_mode =>  'CORRECTION'
                          );
     end if ;
  end if ;





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
    ROLLBACK TO update_plan_type_option_type;
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
    ROLLBACK TO update_plan_type_option_type;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_plan_type_option_type;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_plan_type_option_type >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_plan_type_option_type
  (p_validate                       in  boolean  default false
  ,p_pl_typ_opt_typ_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
    cursor c1 is
  	select opt.opt_id, opt.object_version_number
	from ben_pl_typ_opt_typ_f pon, ben_opt_f opt
	where pon.opt_id = opt.opt_id
	and pon.pl_typ_opt_typ_id = p_pl_typ_opt_typ_id
	and p_effective_date between pon.effective_start_date and pon.effective_end_date
	and p_effective_date between opt.effective_start_date and opt.effective_end_date;
  --
  cursor c2 (p_opt_id in number) is
	select count(*)
	from ben_pl_typ_opt_typ_f
	where pl_typ_opt_typ_cd = 'CWB'
	and opt_id = p_opt_id
	and p_effective_date between effective_start_date and effective_end_date;
  --
  l_opt_id number;
  l_count_cwb_pl_typ number;
  l_opt_OVN number;
  --
  l_proc varchar2(72) := g_package||'update_plan_type_option_type';
  l_object_version_number ben_pl_typ_opt_typ_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_typ_opt_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_typ_opt_typ_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_plan_type_option_type;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --Bug : 3453791
  open c1;
  fetch c1 into l_opt_id, l_opt_OVN;
  close c1;
  --Bug : 3453791
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_plan_type_option_type
    --
    ben_plan_type_option_type_bk3.delete_plan_type_option_type_b
      (
       p_pl_typ_opt_typ_id              =>  p_pl_typ_opt_typ_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_plan_type_option_type'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_plan_type_option_type
    --
  end;
  --
  ben_pon_del.del
    (
     p_pl_typ_opt_typ_id             => p_pl_typ_opt_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_plan_type_option_type
    --
    ben_plan_type_option_type_bk3.delete_plan_type_option_type_a
      (
       p_pl_typ_opt_typ_id              =>  p_pl_typ_opt_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_plan_type_option_type'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_plan_type_option_type
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
  --
  --Bug : 3453791
  --
  open c2(l_opt_id);
  fetch c2 into l_count_cwb_pl_typ;
  close c2;
  --
  if l_count_cwb_pl_typ = 0 then
  -- If the plan type being deleted is the last CWB plan type associated with the option
  -- then make group_option_id in ben_opt_f as null
  --
	update ben_opt_f
	set group_opt_id = null
	where opt_id = l_opt_id
	and p_effective_date between effective_start_date and effective_end_date;
  end if;
  --
  --Bug : 3453791
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
    ROLLBACK TO delete_plan_type_option_type;
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
    ROLLBACK TO delete_plan_type_option_type;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_plan_type_option_type;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pl_typ_opt_typ_id                   in     number
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
  ben_pon_shd.lck
    (
      p_pl_typ_opt_typ_id                 => p_pl_typ_opt_typ_id
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
end ben_plan_type_option_type_api;

/
