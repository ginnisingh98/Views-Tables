--------------------------------------------------------
--  DDL for Package Body BEN_OPT_PLTYP_IN_PGM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_OPT_PLTYP_IN_PGM_API" as
/* $Header: beotpapi.pkb 115.4 2003/09/25 00:30:18 rpgupta noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_opt_pltyp_in_pgm_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_opt_pltyp_in_pgm >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_opt_pltyp_in_pgm
  (p_validate                       in  boolean   default false
  ,p_optip_id                       out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_opt_id                         in  number    default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_legislation_code         in  varchar2  default null
  ,p_legislation_subgroup         in  varchar2  default null
  ,p_otp_attribute_category         in  varchar2  default null
  ,p_otp_attribute1                 in  varchar2  default null
  ,p_otp_attribute2                 in  varchar2  default null
  ,p_otp_attribute3                 in  varchar2  default null
  ,p_otp_attribute4                 in  varchar2  default null
  ,p_otp_attribute5                 in  varchar2  default null
  ,p_otp_attribute6                 in  varchar2  default null
  ,p_otp_attribute7                 in  varchar2  default null
  ,p_otp_attribute8                 in  varchar2  default null
  ,p_otp_attribute9                 in  varchar2  default null
  ,p_otp_attribute10                in  varchar2  default null
  ,p_otp_attribute11                in  varchar2  default null
  ,p_otp_attribute12                in  varchar2  default null
  ,p_otp_attribute13                in  varchar2  default null
  ,p_otp_attribute14                in  varchar2  default null
  ,p_otp_attribute15                in  varchar2  default null
  ,p_otp_attribute16                in  varchar2  default null
  ,p_otp_attribute17                in  varchar2  default null
  ,p_otp_attribute18                in  varchar2  default null
  ,p_otp_attribute19                in  varchar2  default null
  ,p_otp_attribute20                in  varchar2  default null
  ,p_otp_attribute21                in  varchar2  default null
  ,p_otp_attribute22                in  varchar2  default null
  ,p_otp_attribute23                in  varchar2  default null
  ,p_otp_attribute24                in  varchar2  default null
  ,p_otp_attribute25                in  varchar2  default null
  ,p_otp_attribute26                in  varchar2  default null
  ,p_otp_attribute27                in  varchar2  default null
  ,p_otp_attribute28                in  varchar2  default null
  ,p_otp_attribute29                in  varchar2  default null
  ,p_otp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Cursor to find the uniqueness of the optip
  --
  cursor c_uniq_optip is
    select null from
         ben_optip_f optip
    where optip.pgm_id = p_pgm_id
     and  optip.pl_typ_id = p_pl_typ_id
     and  optip.opt_id    = p_opt_id
     and  p_effective_date between optip.effective_start_date and
                                   optip.effective_end_date ;
  --
  cursor c_future_optip is
    select optip_id from
         ben_optip_f optip
    where optip.pgm_id = p_pgm_id
     and  optip.pl_typ_id = p_pl_typ_id
     and  optip.opt_id    = p_opt_id
     and  optip.effective_start_date  > p_effective_date ;

  -- Declare cursors and local variables
  --
  l_optip_id ben_optip_f.optip_id%TYPE;
  l_effective_start_date ben_optip_f.effective_start_date%TYPE;
  l_effective_end_date ben_optip_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_opt_pltyp_in_pgm';
  l_object_version_number ben_optip_f.object_version_number%TYPE;
  l_dummy      varchar2(1) := null ;
  l_future_optip_id ben_optip_f.optip_id%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_opt_pltyp_in_pgm;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
    --
    open c_uniq_optip ;
    --
    fetch c_uniq_optip into l_dummy;
    --
    if c_uniq_optip%found then
    --
      hr_utility.set_location('Record already exists. no need to insert another record', 20 ) ;
      hr_utility.set_location('exiting from '||l_proc,25);
      close c_uniq_optip ;
      return ;
    --
    end if;
    close c_uniq_optip ;
    --
    open c_future_optip ;
    fetch c_future_optip into l_future_optip_id ;
    --
    if c_future_optip%found then
    --
      hr_utility.set_location('Future record exists. we need to extend the record ', 20 ) ;
      update ben_optip_f
      set effective_start_date = p_effective_date
      where optip_id = l_future_optip_id ;
      hr_utility.set_location('exiting from '||l_proc,25);
      close c_future_optip ;
      return ;
    --
    end if;
    close c_future_optip ;

    begin
    -- Start of API User Hook for the before hook of create_opt_pltyp_in_pgm
    --
    ben_opt_pltyp_in_pgm_bk1.create_opt_pltyp_in_pgm_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_opt_id                         =>  p_opt_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_legislation_code         =>  p_legislation_code
      ,p_legislation_subgroup         =>  p_legislation_subgroup
      ,p_otp_attribute_category         =>  p_otp_attribute_category
      ,p_otp_attribute1                 =>  p_otp_attribute1
      ,p_otp_attribute2                 =>  p_otp_attribute2
      ,p_otp_attribute3                 =>  p_otp_attribute3
      ,p_otp_attribute4                 =>  p_otp_attribute4
      ,p_otp_attribute5                 =>  p_otp_attribute5
      ,p_otp_attribute6                 =>  p_otp_attribute6
      ,p_otp_attribute7                 =>  p_otp_attribute7
      ,p_otp_attribute8                 =>  p_otp_attribute8
      ,p_otp_attribute9                 =>  p_otp_attribute9
      ,p_otp_attribute10                =>  p_otp_attribute10
      ,p_otp_attribute11                =>  p_otp_attribute11
      ,p_otp_attribute12                =>  p_otp_attribute12
      ,p_otp_attribute13                =>  p_otp_attribute13
      ,p_otp_attribute14                =>  p_otp_attribute14
      ,p_otp_attribute15                =>  p_otp_attribute15
      ,p_otp_attribute16                =>  p_otp_attribute16
      ,p_otp_attribute17                =>  p_otp_attribute17
      ,p_otp_attribute18                =>  p_otp_attribute18
      ,p_otp_attribute19                =>  p_otp_attribute19
      ,p_otp_attribute20                =>  p_otp_attribute20
      ,p_otp_attribute21                =>  p_otp_attribute21
      ,p_otp_attribute22                =>  p_otp_attribute22
      ,p_otp_attribute23                =>  p_otp_attribute23
      ,p_otp_attribute24                =>  p_otp_attribute24
      ,p_otp_attribute25                =>  p_otp_attribute25
      ,p_otp_attribute26                =>  p_otp_attribute26
      ,p_otp_attribute27                =>  p_otp_attribute27
      ,p_otp_attribute28                =>  p_otp_attribute28
      ,p_otp_attribute29                =>  p_otp_attribute29
      ,p_otp_attribute30                =>  p_otp_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_opt_pltyp_in_pgm'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_opt_pltyp_in_pgm
    --
  end;
  --
  ben_otp_ins.ins
    (
     p_optip_id                      => l_optip_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_pgm_id                        => p_pgm_id
    ,p_ptip_id                       => p_ptip_id
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_opt_id                        => p_opt_id
    ,p_cmbn_ptip_opt_id              => p_cmbn_ptip_opt_id
    ,p_legislation_code        => p_legislation_code
    ,p_legislation_subgroup        => p_legislation_subgroup
    ,p_otp_attribute_category        => p_otp_attribute_category
    ,p_otp_attribute1                => p_otp_attribute1
    ,p_otp_attribute2                => p_otp_attribute2
    ,p_otp_attribute3                => p_otp_attribute3
    ,p_otp_attribute4                => p_otp_attribute4
    ,p_otp_attribute5                => p_otp_attribute5
    ,p_otp_attribute6                => p_otp_attribute6
    ,p_otp_attribute7                => p_otp_attribute7
    ,p_otp_attribute8                => p_otp_attribute8
    ,p_otp_attribute9                => p_otp_attribute9
    ,p_otp_attribute10               => p_otp_attribute10
    ,p_otp_attribute11               => p_otp_attribute11
    ,p_otp_attribute12               => p_otp_attribute12
    ,p_otp_attribute13               => p_otp_attribute13
    ,p_otp_attribute14               => p_otp_attribute14
    ,p_otp_attribute15               => p_otp_attribute15
    ,p_otp_attribute16               => p_otp_attribute16
    ,p_otp_attribute17               => p_otp_attribute17
    ,p_otp_attribute18               => p_otp_attribute18
    ,p_otp_attribute19               => p_otp_attribute19
    ,p_otp_attribute20               => p_otp_attribute20
    ,p_otp_attribute21               => p_otp_attribute21
    ,p_otp_attribute22               => p_otp_attribute22
    ,p_otp_attribute23               => p_otp_attribute23
    ,p_otp_attribute24               => p_otp_attribute24
    ,p_otp_attribute25               => p_otp_attribute25
    ,p_otp_attribute26               => p_otp_attribute26
    ,p_otp_attribute27               => p_otp_attribute27
    ,p_otp_attribute28               => p_otp_attribute28
    ,p_otp_attribute29               => p_otp_attribute29
    ,p_otp_attribute30               => p_otp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_opt_pltyp_in_pgm
    --
    ben_opt_pltyp_in_pgm_bk1.create_opt_pltyp_in_pgm_a
      (
       p_optip_id                       =>  l_optip_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_opt_id                         =>  p_opt_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_legislation_code         =>  p_legislation_code
      ,p_legislation_subgroup         =>  p_legislation_subgroup
      ,p_otp_attribute_category         =>  p_otp_attribute_category
      ,p_otp_attribute1                 =>  p_otp_attribute1
      ,p_otp_attribute2                 =>  p_otp_attribute2
      ,p_otp_attribute3                 =>  p_otp_attribute3
      ,p_otp_attribute4                 =>  p_otp_attribute4
      ,p_otp_attribute5                 =>  p_otp_attribute5
      ,p_otp_attribute6                 =>  p_otp_attribute6
      ,p_otp_attribute7                 =>  p_otp_attribute7
      ,p_otp_attribute8                 =>  p_otp_attribute8
      ,p_otp_attribute9                 =>  p_otp_attribute9
      ,p_otp_attribute10                =>  p_otp_attribute10
      ,p_otp_attribute11                =>  p_otp_attribute11
      ,p_otp_attribute12                =>  p_otp_attribute12
      ,p_otp_attribute13                =>  p_otp_attribute13
      ,p_otp_attribute14                =>  p_otp_attribute14
      ,p_otp_attribute15                =>  p_otp_attribute15
      ,p_otp_attribute16                =>  p_otp_attribute16
      ,p_otp_attribute17                =>  p_otp_attribute17
      ,p_otp_attribute18                =>  p_otp_attribute18
      ,p_otp_attribute19                =>  p_otp_attribute19
      ,p_otp_attribute20                =>  p_otp_attribute20
      ,p_otp_attribute21                =>  p_otp_attribute21
      ,p_otp_attribute22                =>  p_otp_attribute22
      ,p_otp_attribute23                =>  p_otp_attribute23
      ,p_otp_attribute24                =>  p_otp_attribute24
      ,p_otp_attribute25                =>  p_otp_attribute25
      ,p_otp_attribute26                =>  p_otp_attribute26
      ,p_otp_attribute27                =>  p_otp_attribute27
      ,p_otp_attribute28                =>  p_otp_attribute28
      ,p_otp_attribute29                =>  p_otp_attribute29
      ,p_otp_attribute30                =>  p_otp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_opt_pltyp_in_pgm'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_opt_pltyp_in_pgm
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
  p_optip_id := l_optip_id;
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
    ROLLBACK TO create_opt_pltyp_in_pgm;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_optip_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_opt_pltyp_in_pgm;

    -- NOCOPY, Reset out parameters
    p_optip_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;

    raise;
    --
end create_opt_pltyp_in_pgm;
-- ----------------------------------------------------------------------------
-- |------------------------< update_opt_pltyp_in_pgm >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_opt_pltyp_in_pgm
  (p_validate                       in  boolean   default false
  ,p_optip_id                       in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_opt_id                         in  number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id               in  number    default hr_api.g_number
  ,p_legislation_code         in  varchar2  default hr_api.g_varchar2
  ,p_legislation_subgroup         in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_otp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_opt_pltyp_in_pgm';
  l_object_version_number ben_optip_f.object_version_number%TYPE;
  l_effective_start_date ben_optip_f.effective_start_date%TYPE;
  l_effective_end_date ben_optip_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_opt_pltyp_in_pgm;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_opt_pltyp_in_pgm
    --
    ben_opt_pltyp_in_pgm_bk2.update_opt_pltyp_in_pgm_b
      (
       p_optip_id                       =>  p_optip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_opt_id                         =>  p_opt_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_legislation_code         =>  p_legislation_code
      ,p_legislation_subgroup         =>  p_legislation_subgroup
      ,p_otp_attribute_category         =>  p_otp_attribute_category
      ,p_otp_attribute1                 =>  p_otp_attribute1
      ,p_otp_attribute2                 =>  p_otp_attribute2
      ,p_otp_attribute3                 =>  p_otp_attribute3
      ,p_otp_attribute4                 =>  p_otp_attribute4
      ,p_otp_attribute5                 =>  p_otp_attribute5
      ,p_otp_attribute6                 =>  p_otp_attribute6
      ,p_otp_attribute7                 =>  p_otp_attribute7
      ,p_otp_attribute8                 =>  p_otp_attribute8
      ,p_otp_attribute9                 =>  p_otp_attribute9
      ,p_otp_attribute10                =>  p_otp_attribute10
      ,p_otp_attribute11                =>  p_otp_attribute11
      ,p_otp_attribute12                =>  p_otp_attribute12
      ,p_otp_attribute13                =>  p_otp_attribute13
      ,p_otp_attribute14                =>  p_otp_attribute14
      ,p_otp_attribute15                =>  p_otp_attribute15
      ,p_otp_attribute16                =>  p_otp_attribute16
      ,p_otp_attribute17                =>  p_otp_attribute17
      ,p_otp_attribute18                =>  p_otp_attribute18
      ,p_otp_attribute19                =>  p_otp_attribute19
      ,p_otp_attribute20                =>  p_otp_attribute20
      ,p_otp_attribute21                =>  p_otp_attribute21
      ,p_otp_attribute22                =>  p_otp_attribute22
      ,p_otp_attribute23                =>  p_otp_attribute23
      ,p_otp_attribute24                =>  p_otp_attribute24
      ,p_otp_attribute25                =>  p_otp_attribute25
      ,p_otp_attribute26                =>  p_otp_attribute26
      ,p_otp_attribute27                =>  p_otp_attribute27
      ,p_otp_attribute28                =>  p_otp_attribute28
      ,p_otp_attribute29                =>  p_otp_attribute29
      ,p_otp_attribute30                =>  p_otp_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_opt_pltyp_in_pgm'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_opt_pltyp_in_pgm
    --
  end;
  --
  ben_otp_upd.upd
    (
     p_optip_id                      => p_optip_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_pgm_id                        => p_pgm_id
    ,p_ptip_id                       => p_ptip_id
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_opt_id                        => p_opt_id
    ,p_cmbn_ptip_opt_id              => p_cmbn_ptip_opt_id
    ,p_legislation_code        => p_legislation_code
    ,p_legislation_subgroup        => p_legislation_subgroup
    ,p_otp_attribute_category        => p_otp_attribute_category
    ,p_otp_attribute1                => p_otp_attribute1
    ,p_otp_attribute2                => p_otp_attribute2
    ,p_otp_attribute3                => p_otp_attribute3
    ,p_otp_attribute4                => p_otp_attribute4
    ,p_otp_attribute5                => p_otp_attribute5
    ,p_otp_attribute6                => p_otp_attribute6
    ,p_otp_attribute7                => p_otp_attribute7
    ,p_otp_attribute8                => p_otp_attribute8
    ,p_otp_attribute9                => p_otp_attribute9
    ,p_otp_attribute10               => p_otp_attribute10
    ,p_otp_attribute11               => p_otp_attribute11
    ,p_otp_attribute12               => p_otp_attribute12
    ,p_otp_attribute13               => p_otp_attribute13
    ,p_otp_attribute14               => p_otp_attribute14
    ,p_otp_attribute15               => p_otp_attribute15
    ,p_otp_attribute16               => p_otp_attribute16
    ,p_otp_attribute17               => p_otp_attribute17
    ,p_otp_attribute18               => p_otp_attribute18
    ,p_otp_attribute19               => p_otp_attribute19
    ,p_otp_attribute20               => p_otp_attribute20
    ,p_otp_attribute21               => p_otp_attribute21
    ,p_otp_attribute22               => p_otp_attribute22
    ,p_otp_attribute23               => p_otp_attribute23
    ,p_otp_attribute24               => p_otp_attribute24
    ,p_otp_attribute25               => p_otp_attribute25
    ,p_otp_attribute26               => p_otp_attribute26
    ,p_otp_attribute27               => p_otp_attribute27
    ,p_otp_attribute28               => p_otp_attribute28
    ,p_otp_attribute29               => p_otp_attribute29
    ,p_otp_attribute30               => p_otp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_opt_pltyp_in_pgm
    --
    ben_opt_pltyp_in_pgm_bk2.update_opt_pltyp_in_pgm_a
      (
       p_optip_id                       =>  p_optip_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_opt_id                         =>  p_opt_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_legislation_code         =>  p_legislation_code
      ,p_legislation_subgroup         =>  p_legislation_subgroup
      ,p_otp_attribute_category         =>  p_otp_attribute_category
      ,p_otp_attribute1                 =>  p_otp_attribute1
      ,p_otp_attribute2                 =>  p_otp_attribute2
      ,p_otp_attribute3                 =>  p_otp_attribute3
      ,p_otp_attribute4                 =>  p_otp_attribute4
      ,p_otp_attribute5                 =>  p_otp_attribute5
      ,p_otp_attribute6                 =>  p_otp_attribute6
      ,p_otp_attribute7                 =>  p_otp_attribute7
      ,p_otp_attribute8                 =>  p_otp_attribute8
      ,p_otp_attribute9                 =>  p_otp_attribute9
      ,p_otp_attribute10                =>  p_otp_attribute10
      ,p_otp_attribute11                =>  p_otp_attribute11
      ,p_otp_attribute12                =>  p_otp_attribute12
      ,p_otp_attribute13                =>  p_otp_attribute13
      ,p_otp_attribute14                =>  p_otp_attribute14
      ,p_otp_attribute15                =>  p_otp_attribute15
      ,p_otp_attribute16                =>  p_otp_attribute16
      ,p_otp_attribute17                =>  p_otp_attribute17
      ,p_otp_attribute18                =>  p_otp_attribute18
      ,p_otp_attribute19                =>  p_otp_attribute19
      ,p_otp_attribute20                =>  p_otp_attribute20
      ,p_otp_attribute21                =>  p_otp_attribute21
      ,p_otp_attribute22                =>  p_otp_attribute22
      ,p_otp_attribute23                =>  p_otp_attribute23
      ,p_otp_attribute24                =>  p_otp_attribute24
      ,p_otp_attribute25                =>  p_otp_attribute25
      ,p_otp_attribute26                =>  p_otp_attribute26
      ,p_otp_attribute27                =>  p_otp_attribute27
      ,p_otp_attribute28                =>  p_otp_attribute28
      ,p_otp_attribute29                =>  p_otp_attribute29
      ,p_otp_attribute30                =>  p_otp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_opt_pltyp_in_pgm'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_opt_pltyp_in_pgm
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
    ROLLBACK TO update_opt_pltyp_in_pgm;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date   := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_opt_pltyp_in_pgm;

    -- NOCOPY, Reset out parameters
    p_effective_start_date := null;
    p_effective_end_date   := null;

    raise;
    --
end update_opt_pltyp_in_pgm;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_opt_pltyp_in_pgm >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_opt_pltyp_in_pgm
  (p_validate                       in  boolean  default false
  ,p_optip_id                       in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_opt_pltyp_in_pgm';
  l_object_version_number ben_optip_f.object_version_number%TYPE;
  l_effective_start_date ben_optip_f.effective_start_date%TYPE;
  l_effective_end_date ben_optip_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_opt_pltyp_in_pgm;
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
    -- Start of API User Hook for the before hook of delete_opt_pltyp_in_pgm
    --
    ben_opt_pltyp_in_pgm_bk3.delete_opt_pltyp_in_pgm_b
      (
       p_optip_id                       =>  p_optip_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_opt_pltyp_in_pgm'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_opt_pltyp_in_pgm
    --
  end;
  --
  ben_otp_del.del
    (
     p_optip_id                      => p_optip_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_opt_pltyp_in_pgm
    --
    ben_opt_pltyp_in_pgm_bk3.delete_opt_pltyp_in_pgm_a
      (
       p_optip_id                       =>  p_optip_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_opt_pltyp_in_pgm'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_opt_pltyp_in_pgm
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
    ROLLBACK TO delete_opt_pltyp_in_pgm;
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
    ROLLBACK TO delete_opt_pltyp_in_pgm;

    -- NOCOPY, Reset out parameters
    p_effective_start_date := null;
    p_effective_end_date   := null;

    raise;
    --
end delete_opt_pltyp_in_pgm;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_optip_id                   in     number
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
  ben_otp_shd.lck
    (
      p_optip_id                 => p_optip_id
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
end ben_opt_pltyp_in_pgm_api;

/
