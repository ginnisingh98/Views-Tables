--------------------------------------------------------
--  DDL for Package Body BEN_ELIGIBILITY_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIGIBILITY_RULE_API" as
/* $Header: becerapi.pkb 120.0 2005/05/28 01:00:28 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ELIGIBILITY_RULE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELIGIBILITY_RULE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIGIBILITY_RULE
  (p_validate                       in  boolean   default false
  ,p_prtn_eligy_rl_id               out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_prtn_elig_id                   in  number    default null
  ,p_formula_id                     in  number    default null
  ,p_drvbl_fctr_apls_flag           in  varchar2  default null
  ,p_mndtry_flag                    in  varchar2  default null
  ,p_ordr_to_aply_num               in  number    default null
  ,p_cer_attribute_category         in  varchar2  default null
  ,p_cer_attribute1                 in  varchar2  default null
  ,p_cer_attribute2                 in  varchar2  default null
  ,p_cer_attribute3                 in  varchar2  default null
  ,p_cer_attribute4                 in  varchar2  default null
  ,p_cer_attribute5                 in  varchar2  default null
  ,p_cer_attribute6                 in  varchar2  default null
  ,p_cer_attribute7                 in  varchar2  default null
  ,p_cer_attribute8                 in  varchar2  default null
  ,p_cer_attribute9                 in  varchar2  default null
  ,p_cer_attribute10                in  varchar2  default null
  ,p_cer_attribute11                in  varchar2  default null
  ,p_cer_attribute12                in  varchar2  default null
  ,p_cer_attribute13                in  varchar2  default null
  ,p_cer_attribute14                in  varchar2  default null
  ,p_cer_attribute15                in  varchar2  default null
  ,p_cer_attribute16                in  varchar2  default null
  ,p_cer_attribute17                in  varchar2  default null
  ,p_cer_attribute18                in  varchar2  default null
  ,p_cer_attribute19                in  varchar2  default null
  ,p_cer_attribute20                in  varchar2  default null
  ,p_cer_attribute21                in  varchar2  default null
  ,p_cer_attribute22                in  varchar2  default null
  ,p_cer_attribute23                in  varchar2  default null
  ,p_cer_attribute24                in  varchar2  default null
  ,p_cer_attribute25                in  varchar2  default null
  ,p_cer_attribute26                in  varchar2  default null
  ,p_cer_attribute27                in  varchar2  default null
  ,p_cer_attribute28                in  varchar2  default null
  ,p_cer_attribute29                in  varchar2  default null
  ,p_cer_attribute30                in  varchar2  default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_prtn_elig_id    number;
  l_prtn_eligy_rl_id ben_prtn_eligy_rl_f.prtn_eligy_rl_id%TYPE;
  l_effective_start_date ben_prtn_eligy_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtn_eligy_rl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_ELIGIBILITY_RULE';
  l_object_version_number ben_prtn_eligy_rl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ELIGIBILITY_RULE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  if p_prtn_elig_id is null then
        ben_prtn_elig_prfl_api.insert_prtn_elig
          (
           p_pgm_id                    => p_pgm_id
          ,p_pl_id                     => p_pl_id
          ,p_plip_id                   => p_plip_id
          ,p_ptip_id                   => p_ptip_id
          ,p_oipl_id                   => p_oipl_id
          ,p_effective_date            => p_effective_date
          ,p_business_group_id         => p_business_group_id
          ,p_prtn_elig_id              => l_prtn_elig_id
          );
  else
        l_prtn_elig_id  := p_prtn_elig_id;
  end if;

  begin
    --
    -- Start of API User Hook for the before hook of create_ELIGIBILITY_RULE
    --
    ben_ELIGIBILITY_RULE_bk1.create_ELIGIBILITY_RULE_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_prtn_elig_id                   =>  l_prtn_elig_id
      ,p_formula_id                     =>  p_formula_id
      ,p_drvbl_fctr_apls_flag           =>  p_drvbl_fctr_apls_flag
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_cer_attribute_category         =>  p_cer_attribute_category
      ,p_cer_attribute1                 =>  p_cer_attribute1
      ,p_cer_attribute2                 =>  p_cer_attribute2
      ,p_cer_attribute3                 =>  p_cer_attribute3
      ,p_cer_attribute4                 =>  p_cer_attribute4
      ,p_cer_attribute5                 =>  p_cer_attribute5
      ,p_cer_attribute6                 =>  p_cer_attribute6
      ,p_cer_attribute7                 =>  p_cer_attribute7
      ,p_cer_attribute8                 =>  p_cer_attribute8
      ,p_cer_attribute9                 =>  p_cer_attribute9
      ,p_cer_attribute10                =>  p_cer_attribute10
      ,p_cer_attribute11                =>  p_cer_attribute11
      ,p_cer_attribute12                =>  p_cer_attribute12
      ,p_cer_attribute13                =>  p_cer_attribute13
      ,p_cer_attribute14                =>  p_cer_attribute14
      ,p_cer_attribute15                =>  p_cer_attribute15
      ,p_cer_attribute16                =>  p_cer_attribute16
      ,p_cer_attribute17                =>  p_cer_attribute17
      ,p_cer_attribute18                =>  p_cer_attribute18
      ,p_cer_attribute19                =>  p_cer_attribute19
      ,p_cer_attribute20                =>  p_cer_attribute20
      ,p_cer_attribute21                =>  p_cer_attribute21
      ,p_cer_attribute22                =>  p_cer_attribute22
      ,p_cer_attribute23                =>  p_cer_attribute23
      ,p_cer_attribute24                =>  p_cer_attribute24
      ,p_cer_attribute25                =>  p_cer_attribute25
      ,p_cer_attribute26                =>  p_cer_attribute26
      ,p_cer_attribute27                =>  p_cer_attribute27
      ,p_cer_attribute28                =>  p_cer_attribute28
      ,p_cer_attribute29                =>  p_cer_attribute29
      ,p_cer_attribute30                =>  p_cer_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ELIGIBILITY_RULE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ELIGIBILITY_RULE
    --
  end;
  --
  ben_cer_ins.ins
    (
     p_prtn_eligy_rl_id              => l_prtn_eligy_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_prtn_elig_id                  => l_prtn_elig_id
    ,p_formula_id                    => p_formula_id
    ,p_drvbl_fctr_apls_flag          => p_drvbl_fctr_apls_flag
    ,p_mndtry_flag                   => p_mndtry_flag
    ,p_ordr_to_aply_num              => p_ordr_to_aply_num
    ,p_cer_attribute_category        => p_cer_attribute_category
    ,p_cer_attribute1                => p_cer_attribute1
    ,p_cer_attribute2                => p_cer_attribute2
    ,p_cer_attribute3                => p_cer_attribute3
    ,p_cer_attribute4                => p_cer_attribute4
    ,p_cer_attribute5                => p_cer_attribute5
    ,p_cer_attribute6                => p_cer_attribute6
    ,p_cer_attribute7                => p_cer_attribute7
    ,p_cer_attribute8                => p_cer_attribute8
    ,p_cer_attribute9                => p_cer_attribute9
    ,p_cer_attribute10               => p_cer_attribute10
    ,p_cer_attribute11               => p_cer_attribute11
    ,p_cer_attribute12               => p_cer_attribute12
    ,p_cer_attribute13               => p_cer_attribute13
    ,p_cer_attribute14               => p_cer_attribute14
    ,p_cer_attribute15               => p_cer_attribute15
    ,p_cer_attribute16               => p_cer_attribute16
    ,p_cer_attribute17               => p_cer_attribute17
    ,p_cer_attribute18               => p_cer_attribute18
    ,p_cer_attribute19               => p_cer_attribute19
    ,p_cer_attribute20               => p_cer_attribute20
    ,p_cer_attribute21               => p_cer_attribute21
    ,p_cer_attribute22               => p_cer_attribute22
    ,p_cer_attribute23               => p_cer_attribute23
    ,p_cer_attribute24               => p_cer_attribute24
    ,p_cer_attribute25               => p_cer_attribute25
    ,p_cer_attribute26               => p_cer_attribute26
    ,p_cer_attribute27               => p_cer_attribute27
    ,p_cer_attribute28               => p_cer_attribute28
    ,p_cer_attribute29               => p_cer_attribute29
    ,p_cer_attribute30               => p_cer_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ELIGIBILITY_RULE
    --
    ben_ELIGIBILITY_RULE_bk1.create_ELIGIBILITY_RULE_a
      (
       p_prtn_eligy_rl_id               =>  l_prtn_eligy_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_prtn_elig_id                   =>  l_prtn_elig_id
      ,p_formula_id                     =>  p_formula_id
      ,p_drvbl_fctr_apls_flag           =>  p_drvbl_fctr_apls_flag
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_cer_attribute_category         =>  p_cer_attribute_category
      ,p_cer_attribute1                 =>  p_cer_attribute1
      ,p_cer_attribute2                 =>  p_cer_attribute2
      ,p_cer_attribute3                 =>  p_cer_attribute3
      ,p_cer_attribute4                 =>  p_cer_attribute4
      ,p_cer_attribute5                 =>  p_cer_attribute5
      ,p_cer_attribute6                 =>  p_cer_attribute6
      ,p_cer_attribute7                 =>  p_cer_attribute7
      ,p_cer_attribute8                 =>  p_cer_attribute8
      ,p_cer_attribute9                 =>  p_cer_attribute9
      ,p_cer_attribute10                =>  p_cer_attribute10
      ,p_cer_attribute11                =>  p_cer_attribute11
      ,p_cer_attribute12                =>  p_cer_attribute12
      ,p_cer_attribute13                =>  p_cer_attribute13
      ,p_cer_attribute14                =>  p_cer_attribute14
      ,p_cer_attribute15                =>  p_cer_attribute15
      ,p_cer_attribute16                =>  p_cer_attribute16
      ,p_cer_attribute17                =>  p_cer_attribute17
      ,p_cer_attribute18                =>  p_cer_attribute18
      ,p_cer_attribute19                =>  p_cer_attribute19
      ,p_cer_attribute20                =>  p_cer_attribute20
      ,p_cer_attribute21                =>  p_cer_attribute21
      ,p_cer_attribute22                =>  p_cer_attribute22
      ,p_cer_attribute23                =>  p_cer_attribute23
      ,p_cer_attribute24                =>  p_cer_attribute24
      ,p_cer_attribute25                =>  p_cer_attribute25
      ,p_cer_attribute26                =>  p_cer_attribute26
      ,p_cer_attribute27                =>  p_cer_attribute27
      ,p_cer_attribute28                =>  p_cer_attribute28
      ,p_cer_attribute29                =>  p_cer_attribute29
      ,p_cer_attribute30                =>  p_cer_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELIGIBILITY_RULE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ELIGIBILITY_RULE
    --
  end;
  --
  --update statements
  --updates elig_apls_flag to 'Y' in ben_pgm_f table.
  update ben_pgm_f c
  set    c.elig_apls_flag = 'Y'
  where exists
        (select a.pgm_id
         from   ben_prtn_elig_f a,
                ben_prtn_eligy_rl_f b
         where  b.prtn_eligy_rl_id = l_prtn_eligy_rl_id
         and    a.prtn_elig_id = b.prtn_elig_id
         and    a.pgm_id = c.pgm_id);
  --
  --updates elig_apls_flag to 'Y' in ben_plip_f table.
  update ben_plip_f c
  set    c.elig_apls_flag = 'Y'
  where exists
        (select a.plip_id
         from   ben_prtn_elig_f a,
                ben_prtn_eligy_rl_f b
         where  b.prtn_eligy_rl_id = l_prtn_eligy_rl_id
         and    a.prtn_elig_id = b.prtn_elig_id
         and    a.plip_id = c.plip_id);
  --
  --updates elig_apls_flag to 'Y' in ben_ptip_f table.
  update ben_ptip_f c
  set    c.elig_apls_flag = 'Y'
  where exists
        (select a.ptip_id
         from   ben_prtn_elig_f a,
                ben_prtn_eligy_rl_f b
         where  b.prtn_eligy_rl_id = l_prtn_eligy_rl_id
         and    a.prtn_elig_id = b.prtn_elig_id
         and    a.ptip_id = c.ptip_id);
  --
  --updates elig_apls_flag to 'Y' in ben_pl_f table.
  update ben_pl_f c
  set    c.elig_apls_flag = 'Y'
  where exists
        (select a.pl_id
         from   ben_prtn_elig_f a,
                ben_prtn_eligy_rl_f b
         where  b.prtn_eligy_rl_id = l_prtn_eligy_rl_id
         and    a.prtn_elig_id = b.prtn_elig_id
         and    a.pl_id = c.pl_id);
  --
  --updates elig_apls_flag to 'Y' in ben_oipl_f table.
  update ben_oipl_f c
  set    c.elig_apls_flag = 'Y'
  where exists
        (select a.oipl_id
         from   ben_prtn_elig_f a,
                ben_prtn_eligy_rl_f b
         where  b.prtn_eligy_rl_id = l_prtn_eligy_rl_id
         and    a.prtn_elig_id = b.prtn_elig_id
         and    a.oipl_id = c.oipl_id);
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
  p_prtn_eligy_rl_id := l_prtn_eligy_rl_id;
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
    ROLLBACK TO create_ELIGIBILITY_RULE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtn_eligy_rl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ELIGIBILITY_RULE;
    raise;
    --
end create_ELIGIBILITY_RULE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELIGIBILITY_RULE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIGIBILITY_RULE
  (p_validate                       in  boolean   default false
  ,p_prtn_eligy_rl_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_prtn_elig_id                   in  number    default hr_api.g_number
  ,p_formula_id                     in  number    default hr_api.g_number
  ,p_drvbl_fctr_apls_flag           in  varchar2  default hr_api.g_varchar2
  ,p_mndtry_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_ordr_to_aply_num               in  number    default hr_api.g_number
  ,p_cer_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cer_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIGIBILITY_RULE';
  l_object_version_number ben_prtn_eligy_rl_f.object_version_number%TYPE;
  l_effective_start_date ben_prtn_eligy_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtn_eligy_rl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ELIGIBILITY_RULE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ELIGIBILITY_RULE
    --
    ben_ELIGIBILITY_RULE_bk2.update_ELIGIBILITY_RULE_b
      (
       p_prtn_eligy_rl_id               =>  p_prtn_eligy_rl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_prtn_elig_id                   =>  p_prtn_elig_id
      ,p_formula_id                     =>  p_formula_id
      ,p_drvbl_fctr_apls_flag           =>  p_drvbl_fctr_apls_flag
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_cer_attribute_category         =>  p_cer_attribute_category
      ,p_cer_attribute1                 =>  p_cer_attribute1
      ,p_cer_attribute2                 =>  p_cer_attribute2
      ,p_cer_attribute3                 =>  p_cer_attribute3
      ,p_cer_attribute4                 =>  p_cer_attribute4
      ,p_cer_attribute5                 =>  p_cer_attribute5
      ,p_cer_attribute6                 =>  p_cer_attribute6
      ,p_cer_attribute7                 =>  p_cer_attribute7
      ,p_cer_attribute8                 =>  p_cer_attribute8
      ,p_cer_attribute9                 =>  p_cer_attribute9
      ,p_cer_attribute10                =>  p_cer_attribute10
      ,p_cer_attribute11                =>  p_cer_attribute11
      ,p_cer_attribute12                =>  p_cer_attribute12
      ,p_cer_attribute13                =>  p_cer_attribute13
      ,p_cer_attribute14                =>  p_cer_attribute14
      ,p_cer_attribute15                =>  p_cer_attribute15
      ,p_cer_attribute16                =>  p_cer_attribute16
      ,p_cer_attribute17                =>  p_cer_attribute17
      ,p_cer_attribute18                =>  p_cer_attribute18
      ,p_cer_attribute19                =>  p_cer_attribute19
      ,p_cer_attribute20                =>  p_cer_attribute20
      ,p_cer_attribute21                =>  p_cer_attribute21
      ,p_cer_attribute22                =>  p_cer_attribute22
      ,p_cer_attribute23                =>  p_cer_attribute23
      ,p_cer_attribute24                =>  p_cer_attribute24
      ,p_cer_attribute25                =>  p_cer_attribute25
      ,p_cer_attribute26                =>  p_cer_attribute26
      ,p_cer_attribute27                =>  p_cer_attribute27
      ,p_cer_attribute28                =>  p_cer_attribute28
      ,p_cer_attribute29                =>  p_cer_attribute29
      ,p_cer_attribute30                =>  p_cer_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIGIBILITY_RULE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ELIGIBILITY_RULE
    --
  end;
  --
  ben_cer_upd.upd
    (
     p_prtn_eligy_rl_id              => p_prtn_eligy_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_prtn_elig_id                  => p_prtn_elig_id
    ,p_formula_id                    => p_formula_id
    ,p_drvbl_fctr_apls_flag          => p_drvbl_fctr_apls_flag
    ,p_mndtry_flag                   => p_mndtry_flag
    ,p_ordr_to_aply_num              => p_ordr_to_aply_num
    ,p_cer_attribute_category        => p_cer_attribute_category
    ,p_cer_attribute1                => p_cer_attribute1
    ,p_cer_attribute2                => p_cer_attribute2
    ,p_cer_attribute3                => p_cer_attribute3
    ,p_cer_attribute4                => p_cer_attribute4
    ,p_cer_attribute5                => p_cer_attribute5
    ,p_cer_attribute6                => p_cer_attribute6
    ,p_cer_attribute7                => p_cer_attribute7
    ,p_cer_attribute8                => p_cer_attribute8
    ,p_cer_attribute9                => p_cer_attribute9
    ,p_cer_attribute10               => p_cer_attribute10
    ,p_cer_attribute11               => p_cer_attribute11
    ,p_cer_attribute12               => p_cer_attribute12
    ,p_cer_attribute13               => p_cer_attribute13
    ,p_cer_attribute14               => p_cer_attribute14
    ,p_cer_attribute15               => p_cer_attribute15
    ,p_cer_attribute16               => p_cer_attribute16
    ,p_cer_attribute17               => p_cer_attribute17
    ,p_cer_attribute18               => p_cer_attribute18
    ,p_cer_attribute19               => p_cer_attribute19
    ,p_cer_attribute20               => p_cer_attribute20
    ,p_cer_attribute21               => p_cer_attribute21
    ,p_cer_attribute22               => p_cer_attribute22
    ,p_cer_attribute23               => p_cer_attribute23
    ,p_cer_attribute24               => p_cer_attribute24
    ,p_cer_attribute25               => p_cer_attribute25
    ,p_cer_attribute26               => p_cer_attribute26
    ,p_cer_attribute27               => p_cer_attribute27
    ,p_cer_attribute28               => p_cer_attribute28
    ,p_cer_attribute29               => p_cer_attribute29
    ,p_cer_attribute30               => p_cer_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ELIGIBILITY_RULE
    --
    ben_ELIGIBILITY_RULE_bk2.update_ELIGIBILITY_RULE_a
      (
       p_prtn_eligy_rl_id               =>  p_prtn_eligy_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_prtn_elig_id                   =>  p_prtn_elig_id
      ,p_formula_id                     =>  p_formula_id
      ,p_drvbl_fctr_apls_flag           =>  p_drvbl_fctr_apls_flag
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_cer_attribute_category         =>  p_cer_attribute_category
      ,p_cer_attribute1                 =>  p_cer_attribute1
      ,p_cer_attribute2                 =>  p_cer_attribute2
      ,p_cer_attribute3                 =>  p_cer_attribute3
      ,p_cer_attribute4                 =>  p_cer_attribute4
      ,p_cer_attribute5                 =>  p_cer_attribute5
      ,p_cer_attribute6                 =>  p_cer_attribute6
      ,p_cer_attribute7                 =>  p_cer_attribute7
      ,p_cer_attribute8                 =>  p_cer_attribute8
      ,p_cer_attribute9                 =>  p_cer_attribute9
      ,p_cer_attribute10                =>  p_cer_attribute10
      ,p_cer_attribute11                =>  p_cer_attribute11
      ,p_cer_attribute12                =>  p_cer_attribute12
      ,p_cer_attribute13                =>  p_cer_attribute13
      ,p_cer_attribute14                =>  p_cer_attribute14
      ,p_cer_attribute15                =>  p_cer_attribute15
      ,p_cer_attribute16                =>  p_cer_attribute16
      ,p_cer_attribute17                =>  p_cer_attribute17
      ,p_cer_attribute18                =>  p_cer_attribute18
      ,p_cer_attribute19                =>  p_cer_attribute19
      ,p_cer_attribute20                =>  p_cer_attribute20
      ,p_cer_attribute21                =>  p_cer_attribute21
      ,p_cer_attribute22                =>  p_cer_attribute22
      ,p_cer_attribute23                =>  p_cer_attribute23
      ,p_cer_attribute24                =>  p_cer_attribute24
      ,p_cer_attribute25                =>  p_cer_attribute25
      ,p_cer_attribute26                =>  p_cer_attribute26
      ,p_cer_attribute27                =>  p_cer_attribute27
      ,p_cer_attribute28                =>  p_cer_attribute28
      ,p_cer_attribute29                =>  p_cer_attribute29
      ,p_cer_attribute30                =>  p_cer_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIGIBILITY_RULE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ELIGIBILITY_RULE
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
    ROLLBACK TO update_ELIGIBILITY_RULE;
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
    ROLLBACK TO update_ELIGIBILITY_RULE;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_ELIGIBILITY_RULE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIGIBILITY_RULE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIGIBILITY_RULE
  (p_validate                       in  boolean  default false
  ,p_prtn_eligy_rl_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIGIBILITY_RULE';
  l_object_version_number ben_prtn_eligy_rl_f.object_version_number%TYPE;
  l_effective_start_date ben_prtn_eligy_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtn_eligy_rl_f.effective_end_date%TYPE;
  --
  cursor c1 is
    select pgm_id,
           ptip_id,
           plip_id,
           pl_id,
           oipl_id
    from   ben_prtn_elig_f a,
           ben_prtn_eligy_rl_f b
    where  a.prtn_elig_id = b.prtn_elig_id
    and    b.prtn_eligy_rl_id = p_prtn_eligy_rl_id;
  --
  l_c1 c1%rowtype;
  --
begin
  --
  open c1;
    fetch c1 into l_c1;
  close c1;
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ELIGIBILITY_RULE;
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
    -- Start of API User Hook for the before hook of delete_ELIGIBILITY_RULE
    --
    ben_ELIGIBILITY_RULE_bk3.delete_ELIGIBILITY_RULE_b
      (
       p_prtn_eligy_rl_id               =>  p_prtn_eligy_rl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIGIBILITY_RULE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ELIGIBILITY_RULE
    --
  end;
  --
  ben_cer_del.del
    (
     p_prtn_eligy_rl_id              => p_prtn_eligy_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ELIGIBILITY_RULE
    --
    ben_ELIGIBILITY_RULE_bk3.delete_ELIGIBILITY_RULE_a
      (
       p_prtn_eligy_rl_id               =>  p_prtn_eligy_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIGIBILITY_RULE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ELIGIBILITY_RULE
    --
  end;
  --
  --
  --updates elig_apls_flag to 'N' in ben_pgm_f table
  --only when no record found in profile and rule tables.
  if l_c1.pgm_id is not null then
    --
    update ben_pgm_f c
    set    c.elig_apls_flag = 'N'
    where not exists
          (select a.pgm_id
           from   ben_prtn_elig_f a,
                  ben_prtn_elig_prfl_f b
           where  a.prtn_elig_id = b.prtn_elig_id
           and    c.pgm_id = a.pgm_id)
    and not exists
          (select a.pgm_id
           from   ben_prtn_elig_f a,
                  ben_prtn_eligy_rl_f b
           where  a.prtn_elig_id = b.prtn_elig_id
           and    c.pgm_id = a.pgm_id)
    and c.pgm_id = l_c1.pgm_id;
    --
  elsif l_c1.plip_id is not null then
    --
    --updates elig_apls_flag to 'N' in ben_plip_f table
    --only when no record found in profile and rule tables.
    update ben_plip_f c
    set    c.elig_apls_flag = 'N'
    where not exists
          (select a.plip_id
           from   ben_prtn_elig_f a,
                  ben_prtn_elig_prfl_f b
           where  a.prtn_elig_id = b.prtn_elig_id
           and    c.plip_id = a.plip_id)
    and not exists
          (select a.plip_id
           from   ben_prtn_elig_f a,
                  ben_prtn_eligy_rl_f b
           where  a.prtn_elig_id = b.prtn_elig_id
           and    c.plip_id = a.plip_id)
    and c.plip_id = l_c1.plip_id;
    --
  elsif l_c1.ptip_id is not null then
    --
    --updates elig_apls_flag to 'N' in ben_ptip_f table
    --only when no record found in profile and rule tables.
    update ben_ptip_f c
      set    c.elig_apls_flag = 'N'
      where not exists
            (select a.ptip_id
             from   ben_prtn_elig_f a,
                    ben_prtn_elig_prfl_f b
             where  a.prtn_elig_id = b.prtn_elig_id
             and    c.ptip_id = a.ptip_id)
      and not exists
            (select a.ptip_id
             from   ben_prtn_elig_f a,
                    ben_prtn_eligy_rl_f b
             where  a.prtn_elig_id = b.prtn_elig_id
             and    c.ptip_id = a.ptip_id)
      and c.ptip_id = l_c1.ptip_id;
    --
  elsif l_c1.pl_id is not null then
    --
    --updates elig_apls_flag to 'N' in ben_pl_f table
    --only when no record found in profile and rule tables.
    update ben_pl_f c
    set    c.elig_apls_flag = 'N'
    where not exists
          (select a.pl_id
           from   ben_prtn_elig_f a,
                  ben_prtn_elig_prfl_f b
           where  a.prtn_elig_id = b.prtn_elig_id
           and    c.pl_id = a.pl_id)
    and not exists
          (select a.pl_id
           from   ben_prtn_elig_f a,
                  ben_prtn_eligy_rl_f b
           where  a.prtn_elig_id = b.prtn_elig_id
           and    c.pl_id = a.pl_id)
    and c.pl_id = l_c1.pl_id;
    --
  elsif l_c1.oipl_id is not null then
    --
    --updates elig_apls_flag to 'N' in ben_oipl_f table
    --only when no record found in profile and rule tables.
    update ben_oipl_f c
      set    c.elig_apls_flag = 'N'
      where not exists
            (select a.oipl_id
             from   ben_prtn_elig_f a,
                    ben_prtn_elig_prfl_f b
             where  a.prtn_elig_id = b.prtn_elig_id
             and    c.oipl_id = a.oipl_id)
      and not exists
            (select a.oipl_id
             from   ben_prtn_elig_f a,
                    ben_prtn_eligy_rl_f b
             where  a.prtn_elig_id = b.prtn_elig_id
             and    c.oipl_id = a.oipl_id)
      and c.oipl_id = l_c1.oipl_id;
    --
  end if;
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
    ROLLBACK TO delete_ELIGIBILITY_RULE;
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
    ROLLBACK TO delete_ELIGIBILITY_RULE;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end delete_ELIGIBILITY_RULE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_prtn_eligy_rl_id                   in     number
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
  ben_cer_shd.lck
    (
      p_prtn_eligy_rl_id                 => p_prtn_eligy_rl_id
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
end ben_ELIGIBILITY_RULE_api;

/
