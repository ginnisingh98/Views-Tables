--------------------------------------------------------
--  DDL for Package Body BEN_PRTN_ELIG_PRFL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRTN_ELIG_PRFL_API" as
/* $Header: becepapi.pkb 120.0 2005/05/28 00:59:43 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PRTN_ELIG_PRFL_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PRTN_ELIG_PRFL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PRTN_ELIG_PRFL
  (p_validate                       in  boolean   default false
  ,p_prtn_elig_prfl_id              out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_mndtry_flag                    in  varchar2  default null
  ,p_prtn_elig_id                   in  number    default null
  ,p_eligy_prfl_id                  in  number    default null
  ,p_Elig_prfl_type_cd              in  varchar2  default null
  ,p_cep_attribute_category         in  varchar2  default null
  ,p_cep_attribute1                 in  varchar2  default null
  ,p_cep_attribute2                 in  varchar2  default null
  ,p_cep_attribute3                 in  varchar2  default null
  ,p_cep_attribute4                 in  varchar2  default null
  ,p_cep_attribute5                 in  varchar2  default null
  ,p_cep_attribute6                 in  varchar2  default null
  ,p_cep_attribute7                 in  varchar2  default null
  ,p_cep_attribute8                 in  varchar2  default null
  ,p_cep_attribute9                 in  varchar2  default null
  ,p_cep_attribute10                in  varchar2  default null
  ,p_cep_attribute11                in  varchar2  default null
  ,p_cep_attribute12                in  varchar2  default null
  ,p_cep_attribute13                in  varchar2  default null
  ,p_cep_attribute14                in  varchar2  default null
  ,p_cep_attribute15                in  varchar2  default null
  ,p_cep_attribute16                in  varchar2  default null
  ,p_cep_attribute17                in  varchar2  default null
  ,p_cep_attribute18                in  varchar2  default null
  ,p_cep_attribute19                in  varchar2  default null
  ,p_cep_attribute20                in  varchar2  default null
  ,p_cep_attribute21                in  varchar2  default null
  ,p_cep_attribute22                in  varchar2  default null
  ,p_cep_attribute23                in  varchar2  default null
  ,p_cep_attribute24                in  varchar2  default null
  ,p_cep_attribute25                in  varchar2  default null
  ,p_cep_attribute26                in  varchar2  default null
  ,p_cep_attribute27                in  varchar2  default null
  ,p_cep_attribute28                in  varchar2  default null
  ,p_cep_attribute29                in  varchar2  default null
  ,p_cep_attribute30                in  varchar2  default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_compute_score_flag             in  varchar2  default null
  ) is
  --
  -- Declare cursors and local variables
  --
  cursor c1(l_prtn_elig_id number) is select pgm_id,pl_id,ptip_id,plip_id,oipl_id
     from ben_prtn_elig_f
     where prtn_elig_id = l_prtn_elig_id;
  l_pgm_id number;
  l_pl_id  number;
  l_plip_id number;
  l_oipl_id number;
  l_ptip_id number;
  l_prtn_elig_id  number;
  l_prtn_elig_prfl_id ben_prtn_elig_prfl_f.prtn_elig_prfl_id%TYPE;
  l_effective_start_date ben_prtn_elig_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtn_elig_prfl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PRTN_ELIG_PRFL';
  l_object_version_number ben_prtn_elig_prfl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PRTN_ELIG_PRFL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
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
    -- Start of API User Hook for the before hook of create_PRTN_ELIG_PRFL
    --
    ben_PRTN_ELIG_PRFL_bk1.create_PRTN_ELIG_PRFL_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_prtn_elig_id                   =>  l_prtn_elig_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_Elig_prfl_type_cd              =>  p_Elig_prfl_type_cd
      ,p_cep_attribute_category         =>  p_cep_attribute_category
      ,p_cep_attribute1                 =>  p_cep_attribute1
      ,p_cep_attribute2                 =>  p_cep_attribute2
      ,p_cep_attribute3                 =>  p_cep_attribute3
      ,p_cep_attribute4                 =>  p_cep_attribute4
      ,p_cep_attribute5                 =>  p_cep_attribute5
      ,p_cep_attribute6                 =>  p_cep_attribute6
      ,p_cep_attribute7                 =>  p_cep_attribute7
      ,p_cep_attribute8                 =>  p_cep_attribute8
      ,p_cep_attribute9                 =>  p_cep_attribute9
      ,p_cep_attribute10                =>  p_cep_attribute10
      ,p_cep_attribute11                =>  p_cep_attribute11
      ,p_cep_attribute12                =>  p_cep_attribute12
      ,p_cep_attribute13                =>  p_cep_attribute13
      ,p_cep_attribute14                =>  p_cep_attribute14
      ,p_cep_attribute15                =>  p_cep_attribute15
      ,p_cep_attribute16                =>  p_cep_attribute16
      ,p_cep_attribute17                =>  p_cep_attribute17
      ,p_cep_attribute18                =>  p_cep_attribute18
      ,p_cep_attribute19                =>  p_cep_attribute19
      ,p_cep_attribute20                =>  p_cep_attribute20
      ,p_cep_attribute21                =>  p_cep_attribute21
      ,p_cep_attribute22                =>  p_cep_attribute22
      ,p_cep_attribute23                =>  p_cep_attribute23
      ,p_cep_attribute24                =>  p_cep_attribute24
      ,p_cep_attribute25                =>  p_cep_attribute25
      ,p_cep_attribute26                =>  p_cep_attribute26
      ,p_cep_attribute27                =>  p_cep_attribute27
      ,p_cep_attribute28                =>  p_cep_attribute28
      ,p_cep_attribute29                =>  p_cep_attribute29
      ,p_cep_attribute30                =>  p_cep_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_compute_score_flag             =>  p_compute_score_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PRTN_ELIG_PRFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PRTN_ELIG_PRFL
    --
  end;
  --
  ben_cep_ins.ins
    (
     p_prtn_elig_prfl_id             => l_prtn_elig_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_mndtry_flag                   => p_mndtry_flag
    ,p_prtn_elig_id                  => l_prtn_elig_id
    ,p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_Elig_prfl_type_cd             => p_Elig_prfl_type_cd
    ,p_cep_attribute_category        => p_cep_attribute_category
    ,p_cep_attribute1                => p_cep_attribute1
    ,p_cep_attribute2                => p_cep_attribute2
    ,p_cep_attribute3                => p_cep_attribute3
    ,p_cep_attribute4                => p_cep_attribute4
    ,p_cep_attribute5                => p_cep_attribute5
    ,p_cep_attribute6                => p_cep_attribute6
    ,p_cep_attribute7                => p_cep_attribute7
    ,p_cep_attribute8                => p_cep_attribute8
    ,p_cep_attribute9                => p_cep_attribute9
    ,p_cep_attribute10               => p_cep_attribute10
    ,p_cep_attribute11               => p_cep_attribute11
    ,p_cep_attribute12               => p_cep_attribute12
    ,p_cep_attribute13               => p_cep_attribute13
    ,p_cep_attribute14               => p_cep_attribute14
    ,p_cep_attribute15               => p_cep_attribute15
    ,p_cep_attribute16               => p_cep_attribute16
    ,p_cep_attribute17               => p_cep_attribute17
    ,p_cep_attribute18               => p_cep_attribute18
    ,p_cep_attribute19               => p_cep_attribute19
    ,p_cep_attribute20               => p_cep_attribute20
    ,p_cep_attribute21               => p_cep_attribute21
    ,p_cep_attribute22               => p_cep_attribute22
    ,p_cep_attribute23               => p_cep_attribute23
    ,p_cep_attribute24               => p_cep_attribute24
    ,p_cep_attribute25               => p_cep_attribute25
    ,p_cep_attribute26               => p_cep_attribute26
    ,p_cep_attribute27               => p_cep_attribute27
    ,p_cep_attribute28               => p_cep_attribute28
    ,p_cep_attribute29               => p_cep_attribute29
    ,p_cep_attribute30               => p_cep_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_compute_score_flag            => p_compute_score_flag
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PRTN_ELIG_PRFL
    --
    ben_PRTN_ELIG_PRFL_bk1.create_PRTN_ELIG_PRFL_a
      (
       p_prtn_elig_prfl_id              =>  l_prtn_elig_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_prtn_elig_id                   =>  l_prtn_elig_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_Elig_prfl_type_cd              =>  p_Elig_prfl_type_cd
      ,p_cep_attribute_category         =>  p_cep_attribute_category
      ,p_cep_attribute1                 =>  p_cep_attribute1
      ,p_cep_attribute2                 =>  p_cep_attribute2
      ,p_cep_attribute3                 =>  p_cep_attribute3
      ,p_cep_attribute4                 =>  p_cep_attribute4
      ,p_cep_attribute5                 =>  p_cep_attribute5
      ,p_cep_attribute6                 =>  p_cep_attribute6
      ,p_cep_attribute7                 =>  p_cep_attribute7
      ,p_cep_attribute8                 =>  p_cep_attribute8
      ,p_cep_attribute9                 =>  p_cep_attribute9
      ,p_cep_attribute10                =>  p_cep_attribute10
      ,p_cep_attribute11                =>  p_cep_attribute11
      ,p_cep_attribute12                =>  p_cep_attribute12
      ,p_cep_attribute13                =>  p_cep_attribute13
      ,p_cep_attribute14                =>  p_cep_attribute14
      ,p_cep_attribute15                =>  p_cep_attribute15
      ,p_cep_attribute16                =>  p_cep_attribute16
      ,p_cep_attribute17                =>  p_cep_attribute17
      ,p_cep_attribute18                =>  p_cep_attribute18
      ,p_cep_attribute19                =>  p_cep_attribute19
      ,p_cep_attribute20                =>  p_cep_attribute20
      ,p_cep_attribute21                =>  p_cep_attribute21
      ,p_cep_attribute22                =>  p_cep_attribute22
      ,p_cep_attribute23                =>  p_cep_attribute23
      ,p_cep_attribute24                =>  p_cep_attribute24
      ,p_cep_attribute25                =>  p_cep_attribute25
      ,p_cep_attribute26                =>  p_cep_attribute26
      ,p_cep_attribute27                =>  p_cep_attribute27
      ,p_cep_attribute28                =>  p_cep_attribute28
      ,p_cep_attribute29                =>  p_cep_attribute29
      ,p_cep_attribute30                =>  p_cep_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_compute_score_flag             =>  p_compute_score_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PRTN_ELIG_PRFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PRTN_ELIG_PRFL
    --
  end;
  --
  Open c1(l_prtn_elig_id);
  fetch c1 into l_pgm_id,l_pl_id,l_ptip_id,l_plip_id,l_oipl_id;
  close c1;
  --
  --update statements
  --updates elig_apls_flag to 'Y' in ben_pgm_f table.
  --
  if l_pgm_id is not null then
  update ben_pgm_f c
  set   c.elig_apls_flag = 'Y'
  where c.business_group_id = p_business_group_id
  and   c.elig_apls_flag <> 'Y'
  and   c.pgm_id = l_pgm_id ;
  --
  hr_utility.set_location(' update of pgm_f ' , 60);
  --
  elsif l_plip_id is not null then
  --
  --updates elig_apls_flag to 'Y' in ben_plip_f table.
  update ben_plip_f c
  set    c.elig_apls_flag = 'Y'
  where c.business_group_id = p_business_group_id
  and   c.elig_apls_flag <> 'Y'
  and   c.plip_id = l_plip_id ;
  --
  hr_utility.set_location(' update of plip_f ' , 60);
  --
  elsif l_ptip_id is not null then
  --updates elig_apls_flag to 'Y' in ben_ptip_f table.
  update ben_ptip_f c
  set    c.elig_apls_flag = 'Y'
  where c.business_group_id = p_business_group_id
  and   c.elig_apls_flag <> 'Y'
  and  c.ptip_id = l_ptip_id ;
  hr_utility.set_location(' update of ptip_f ' , 60);
  --
  elsif l_pl_id is not null then
  --updates elig_apls_flag to 'Y' in ben_pl_f table.
  update ben_pl_f c
  set    c.elig_apls_flag = 'Y'
  where c.business_group_id = p_business_group_id
  and   c.elig_apls_flag <> 'Y'
  and   c.pl_id = l_pl_id ;
  --
  hr_utility.set_location(' update of pl_f ' , 60);
  --
  elsif l_oipl_id is not null then
  --updates elig_apls_flag to 'Y' in ben_oipl_f table.
  update ben_oipl_f c
  set    c.elig_apls_flag = 'Y'
  where c.business_group_id = p_business_group_id
  and   c.elig_apls_flag <> 'Y'
  and   c.oipl_id = l_oipl_id ;
  --
  hr_utility.set_location(' update of oipl_f ' , 60);
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

  if l_pgm_id is not null then
     ben_derivable_factor.eligy_prfl_handler('CREATE','ben_pgm_f','pgm_id',l_pgm_id);
  end if;
  --
  if l_pl_id is not null then
     ben_derivable_factor.eligy_prfl_handler('CREATE','ben_pl_f','pl_id',l_pl_id);
  end if;
  --
  if l_plip_id is not null then
     ben_derivable_factor.eligy_prfl_handler('CREATE','ben_plip_f','plip_id',l_plip_id);
  end if;
  --
  if l_ptip_id is not null then
     ben_derivable_factor.eligy_prfl_handler('CREATE','ben_ptip_f','ptip_id',l_ptip_id);
  end if;
  --
  if l_oipl_id is not null then
     ben_derivable_factor.eligy_prfl_handler('CREATE','ben_oipl_f','oipl_id',l_oipl_id);
  end if;
  --
  -- Set all output arguments
  p_prtn_elig_prfl_id := l_prtn_elig_prfl_id;
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
    ROLLBACK TO create_PRTN_ELIG_PRFL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtn_elig_prfl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PRTN_ELIG_PRFL;
    raise;
    --
end create_PRTN_ELIG_PRFL;
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRTN_ELIG_PRFL >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PRTN_ELIG_PRFL
  (p_validate                       in  boolean   default false
  ,p_prtn_elig_prfl_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_mndtry_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_prtn_elig_id                   in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_Elig_prfl_type_cd              in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cep_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_compute_score_flag             in  varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  -- 3688111
  cursor c_cep is
  select eligy_prfl_id
  from  ben_prtn_elig_prfl_f
  where prtn_elig_prfl_id = p_prtn_elig_prfl_id
  and  p_effective_date between effective_start_date and effective_end_date ;

  cursor c1 is
    select pgm_id,
           ptip_id,
           plip_id,
           pl_id,
           oipl_id
    from   ben_prtn_elig_f a,
           ben_prtn_elig_prfl_f b
    where  a.prtn_elig_id = b.prtn_elig_id
    and    b.prtn_elig_prfl_id = p_prtn_elig_prfl_id;
  l_c1 c1%rowtype;
  --
  cursor c_pgm_flag (c_id number) is
  select drvbl_fctr_prtn_elig_flag
  from ben_pgm_f
  where pgm_id = c_id
  and p_effective_date between effective_start_date and effective_end_date ;

  cursor c_pl_flag (c_id number) is
  select drvbl_fctr_prtn_elig_flag
  from ben_pl_f
  where pl_id = c_id
  and p_effective_date between effective_start_date and effective_end_date ;

  cursor c_plip_flag (c_id number) is
  select drvbl_fctr_prtn_elig_flag
  from ben_plip_f
  where plip_id = c_id
  and p_effective_date between effective_start_date and effective_end_date ;

  cursor c_ptip_flag (c_id number) is
  select drvbl_fctr_prtn_elig_flag
  from ben_ptip_f
  where ptip_id = c_id
  and p_effective_date between effective_start_date and effective_end_date ;


  cursor c_oipl_flag (c_id number) is
  select drvbl_fctr_prtn_elig_flag
  from ben_oipl_f
  where oipl_id = c_id
  and p_effective_date between effective_start_date and effective_end_date ;

  --
  l_proc varchar2(72) := g_package||'update_PRTN_ELIG_PRFL';
  l_object_version_number ben_prtn_elig_prfl_f.object_version_number%TYPE;
  l_effective_start_date ben_prtn_elig_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtn_elig_prfl_f.effective_end_date%TYPE;
  -- 3688111
  l_old_eligy_prfl_id          number ;
  l_drvbl_fctr_prtn_elig_flag  varchar2(30) ;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PRTN_ELIG_PRFL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --

    -- bug 3688111 get the old id
    open c_cep ;
    fetch c_cep into l_old_eligy_prfl_id ;
    close c_cep ;

    -- Start of API User Hook for the before hook of update_PRTN_ELIG_PRFL
    --
    ben_PRTN_ELIG_PRFL_bk2.update_PRTN_ELIG_PRFL_b
      (
       p_prtn_elig_prfl_id              =>  p_prtn_elig_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_prtn_elig_id                   =>  p_prtn_elig_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_Elig_prfl_type_cd              =>  p_Elig_prfl_type_cd
      ,p_cep_attribute_category         =>  p_cep_attribute_category
      ,p_cep_attribute1                 =>  p_cep_attribute1
      ,p_cep_attribute2                 =>  p_cep_attribute2
      ,p_cep_attribute3                 =>  p_cep_attribute3
      ,p_cep_attribute4                 =>  p_cep_attribute4
      ,p_cep_attribute5                 =>  p_cep_attribute5
      ,p_cep_attribute6                 =>  p_cep_attribute6
      ,p_cep_attribute7                 =>  p_cep_attribute7
      ,p_cep_attribute8                 =>  p_cep_attribute8
      ,p_cep_attribute9                 =>  p_cep_attribute9
      ,p_cep_attribute10                =>  p_cep_attribute10
      ,p_cep_attribute11                =>  p_cep_attribute11
      ,p_cep_attribute12                =>  p_cep_attribute12
      ,p_cep_attribute13                =>  p_cep_attribute13
      ,p_cep_attribute14                =>  p_cep_attribute14
      ,p_cep_attribute15                =>  p_cep_attribute15
      ,p_cep_attribute16                =>  p_cep_attribute16
      ,p_cep_attribute17                =>  p_cep_attribute17
      ,p_cep_attribute18                =>  p_cep_attribute18
      ,p_cep_attribute19                =>  p_cep_attribute19
      ,p_cep_attribute20                =>  p_cep_attribute20
      ,p_cep_attribute21                =>  p_cep_attribute21
      ,p_cep_attribute22                =>  p_cep_attribute22
      ,p_cep_attribute23                =>  p_cep_attribute23
      ,p_cep_attribute24                =>  p_cep_attribute24
      ,p_cep_attribute25                =>  p_cep_attribute25
      ,p_cep_attribute26                =>  p_cep_attribute26
      ,p_cep_attribute27                =>  p_cep_attribute27
      ,p_cep_attribute28                =>  p_cep_attribute28
      ,p_cep_attribute29                =>  p_cep_attribute29
      ,p_cep_attribute30                =>  p_cep_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      ,p_compute_score_flag             =>  p_compute_score_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTN_ELIG_PRFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PRTN_ELIG_PRFL
    --
  end;
  --
  ben_cep_upd.upd
    (
     p_prtn_elig_prfl_id             => p_prtn_elig_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_mndtry_flag                   => p_mndtry_flag
    ,p_prtn_elig_id                  => p_prtn_elig_id
    ,p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_Elig_prfl_type_cd             => p_Elig_prfl_type_cd
    ,p_cep_attribute_category        => p_cep_attribute_category
    ,p_cep_attribute1                => p_cep_attribute1
    ,p_cep_attribute2                => p_cep_attribute2
    ,p_cep_attribute3                => p_cep_attribute3
    ,p_cep_attribute4                => p_cep_attribute4
    ,p_cep_attribute5                => p_cep_attribute5
    ,p_cep_attribute6                => p_cep_attribute6
    ,p_cep_attribute7                => p_cep_attribute7
    ,p_cep_attribute8                => p_cep_attribute8
    ,p_cep_attribute9                => p_cep_attribute9
    ,p_cep_attribute10               => p_cep_attribute10
    ,p_cep_attribute11               => p_cep_attribute11
    ,p_cep_attribute12               => p_cep_attribute12
    ,p_cep_attribute13               => p_cep_attribute13
    ,p_cep_attribute14               => p_cep_attribute14
    ,p_cep_attribute15               => p_cep_attribute15
    ,p_cep_attribute16               => p_cep_attribute16
    ,p_cep_attribute17               => p_cep_attribute17
    ,p_cep_attribute18               => p_cep_attribute18
    ,p_cep_attribute19               => p_cep_attribute19
    ,p_cep_attribute20               => p_cep_attribute20
    ,p_cep_attribute21               => p_cep_attribute21
    ,p_cep_attribute22               => p_cep_attribute22
    ,p_cep_attribute23               => p_cep_attribute23
    ,p_cep_attribute24               => p_cep_attribute24
    ,p_cep_attribute25               => p_cep_attribute25
    ,p_cep_attribute26               => p_cep_attribute26
    ,p_cep_attribute27               => p_cep_attribute27
    ,p_cep_attribute28               => p_cep_attribute28
    ,p_cep_attribute29               => p_cep_attribute29
    ,p_cep_attribute30               => p_cep_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_compute_score_flag            => p_compute_score_flag
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PRTN_ELIG_PRFL
    --
    ben_PRTN_ELIG_PRFL_bk2.update_PRTN_ELIG_PRFL_a
      (
       p_prtn_elig_prfl_id              =>  p_prtn_elig_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_prtn_elig_id                   =>  p_prtn_elig_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_Elig_prfl_type_cd              =>  p_Elig_prfl_type_cd
      ,p_cep_attribute_category         =>  p_cep_attribute_category
      ,p_cep_attribute1                 =>  p_cep_attribute1
      ,p_cep_attribute2                 =>  p_cep_attribute2
      ,p_cep_attribute3                 =>  p_cep_attribute3
      ,p_cep_attribute4                 =>  p_cep_attribute4
      ,p_cep_attribute5                 =>  p_cep_attribute5
      ,p_cep_attribute6                 =>  p_cep_attribute6
      ,p_cep_attribute7                 =>  p_cep_attribute7
      ,p_cep_attribute8                 =>  p_cep_attribute8
      ,p_cep_attribute9                 =>  p_cep_attribute9
      ,p_cep_attribute10                =>  p_cep_attribute10
      ,p_cep_attribute11                =>  p_cep_attribute11
      ,p_cep_attribute12                =>  p_cep_attribute12
      ,p_cep_attribute13                =>  p_cep_attribute13
      ,p_cep_attribute14                =>  p_cep_attribute14
      ,p_cep_attribute15                =>  p_cep_attribute15
      ,p_cep_attribute16                =>  p_cep_attribute16
      ,p_cep_attribute17                =>  p_cep_attribute17
      ,p_cep_attribute18                =>  p_cep_attribute18
      ,p_cep_attribute19                =>  p_cep_attribute19
      ,p_cep_attribute20                =>  p_cep_attribute20
      ,p_cep_attribute21                =>  p_cep_attribute21
      ,p_cep_attribute22                =>  p_cep_attribute22
      ,p_cep_attribute23                =>  p_cep_attribute23
      ,p_cep_attribute24                =>  p_cep_attribute24
      ,p_cep_attribute25                =>  p_cep_attribute25
      ,p_cep_attribute26                =>  p_cep_attribute26
      ,p_cep_attribute27                =>  p_cep_attribute27
      ,p_cep_attribute28                =>  p_cep_attribute28
      ,p_cep_attribute29                =>  p_cep_attribute29
      ,p_cep_attribute30                =>  p_cep_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      ,p_compute_score_flag             =>  p_compute_score_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTN_ELIG_PRFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PRTN_ELIG_PRFL
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

 -- eligy_prfl_handler called to update the DRVBL_FCTR_PRTN_ELIG_FLAG flag
 -- so far this procedure called in create and delete only
 -- there is a possibility the user may attach a prfile without derive factor
 -- then update the profile with a profile which has derive factor or vise a verse
 -- in this case we have to call the eligy_prfl_handler to update the column DRVBL_FCTR_PRTN_ELIG_FLAG
 -- bug 3688111
 -- 1 check whether  the old profile id and new profile id is the same , if not
 -- 2 if the flag is 'Y' and  ther is a possibility current may not have the DF, so call in  delete mode
 -- 3 if the flag is 'N' and  ther is a possibility current may have the DF, so call in Create mode

 hr_utility.set_location( ' old ' || l_old_eligy_prfl_id || ' new ' ||  p_eligy_prfl_id , 11);
 if l_old_eligy_prfl_id <> p_eligy_prfl_id then
    open c1 ;
    fetch c1 into l_c1;
    close c1;

    if l_c1.pgm_id is not null then
       open c_pgm_flag(l_c1.pgm_id) ;
       fetch c_pgm_flag into l_drvbl_fctr_prtn_elig_flag ;
       close c_pgm_flag ;

       hr_utility.set_location( ' old pgm  flag ' ||  l_drvbl_fctr_prtn_elig_flag , 11);

       if nvl( l_drvbl_fctr_prtn_elig_flag,'N')  = 'N' then
          ben_derivable_factor.eligy_prfl_handler('CREATE','ben_pgm_f','pgm_id',l_c1.pgm_id);
       else
         ben_derivable_factor.eligy_prfl_handler('DELETE','ben_pgm_f','pgm_id',l_c1.pgm_id);
       end if ;
    end if;
    --
    if l_c1.pl_id is not null then

       open c_pl_flag(l_c1.pl_id) ;
       fetch c_pl_flag into l_drvbl_fctr_prtn_elig_flag ;
       close c_pl_flag ;

       hr_utility.set_location( ' old pl  flag ' ||  l_drvbl_fctr_prtn_elig_flag , 11);


       if nvl( l_drvbl_fctr_prtn_elig_flag,'N')  = 'N' then
          ben_derivable_factor.eligy_prfl_handler('CREATE','ben_pl_f','pl_id',l_c1.pl_id);
       else
           ben_derivable_factor.eligy_prfl_handler('DELETE','ben_pl_f','pl_id',l_c1.pl_id);
       end if ;
    end if;
    --
    if l_c1.plip_id is not null then

       open c_plip_flag( l_c1.plip_id ) ;
       fetch c_plip_flag into l_drvbl_fctr_prtn_elig_flag ;
       close c_plip_flag ;

       hr_utility.set_location( ' old plip  flag ' ||  l_drvbl_fctr_prtn_elig_flag , 11);

       if nvl( l_drvbl_fctr_prtn_elig_flag,'N')  = 'N' then
          ben_derivable_factor.eligy_prfl_handler('CREATE','ben_plip_f','plip_id',l_c1.plip_id);
       else
          ben_derivable_factor.eligy_prfl_handler('DELETE','ben_plip_f','plip_id',l_c1.plip_id);
       end if ;
    end if;
    --
    if l_c1.ptip_id is not null then

       open c_ptip_flag (l_c1.ptip_id ) ;
       fetch c_ptip_flag into l_drvbl_fctr_prtn_elig_flag ;
       close c_ptip_flag ;

       hr_utility.set_location( ' old ptip  flag ' ||  l_drvbl_fctr_prtn_elig_flag , 11);

       if nvl( l_drvbl_fctr_prtn_elig_flag,'N')  = 'N' then
          ben_derivable_factor.eligy_prfl_handler('CREATE','ben_ptip_f','ptip_id',l_c1.ptip_id);
       else
          ben_derivable_factor.eligy_prfl_handler('DELETE','ben_ptip_f','ptip_id',l_c1.ptip_id);
       end if ;
    end if;
    --
    if l_c1.oipl_id is not null then

       open c_oipl_flag ( l_c1.oipl_id ) ;
       fetch c_oipl_flag into l_drvbl_fctr_prtn_elig_flag ;
       close c_oipl_flag ;

       hr_utility.set_location( ' old oipl  flag ' ||  l_drvbl_fctr_prtn_elig_flag , 11);


       if nvl( l_drvbl_fctr_prtn_elig_flag,'N')  = 'N' then
          ben_derivable_factor.eligy_prfl_handler('CREATE','ben_oipl_f','oipl_id',l_c1.oipl_id);
       else
          ben_derivable_factor.eligy_prfl_handler('DELETE','ben_oipl_f','oipl_id',l_c1.oipl_id);
       end if;

    end if;
 end if ;


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
    ROLLBACK TO update_PRTN_ELIG_PRFL;
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
    ROLLBACK TO update_PRTN_ELIG_PRFL;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_PRTN_ELIG_PRFL;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRTN_ELIG_PRFL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTN_ELIG_PRFL
  (p_validate                       in  boolean  default false
  ,p_prtn_elig_prfl_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PRTN_ELIG_PRFL';
  l_object_version_number ben_prtn_elig_prfl_f.object_version_number%TYPE;
  l_effective_start_date ben_prtn_elig_prfl_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtn_elig_prfl_f.effective_end_date%TYPE;
  --
  cursor c1 is
    select pgm_id,
           ptip_id,
           plip_id,
           pl_id,
           oipl_id
    from   ben_prtn_elig_f a,
           ben_prtn_elig_prfl_f b
    where  a.prtn_elig_id = b.prtn_elig_id
    and    b.prtn_elig_prfl_id = p_prtn_elig_prfl_id;
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
  savepoint delete_PRTN_ELIG_PRFL;
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
    -- Start of API User Hook for the before hook of delete_PRTN_ELIG_PRFL
    --
    ben_PRTN_ELIG_PRFL_bk3.delete_PRTN_ELIG_PRFL_b
      (
       p_prtn_elig_prfl_id              =>  p_prtn_elig_prfl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTN_ELIG_PRFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_PRTN_ELIG_PRFL
    --
  end;
  --
  ben_cep_del.del
    (
     p_prtn_elig_prfl_id             => p_prtn_elig_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PRTN_ELIG_PRFL
    --
    ben_PRTN_ELIG_PRFL_bk3.delete_PRTN_ELIG_PRFL_a
      (
       p_prtn_elig_prfl_id              =>  p_prtn_elig_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTN_ELIG_PRFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_PRTN_ELIG_PRFL
    --
  end;
  --
  --updates elig_apls_flag to 'N' in ben_pgm_f table only when
  --no record found in profile and rule tables.
  if l_c1.pgm_id is not null then
    --
    update ben_pgm_f c
      set    c.elig_apls_flag = 'N'
      where not exists
          (select a.pgm_id
           from   ben_prtn_elig_f a,
                  ben_prtn_elig_prfl_f b
           where  a.prtn_elig_id = b.prtn_elig_id
           and    a.pgm_id = c.pgm_id)
      and not exists
            (select a.pgm_id
             from   ben_prtn_elig_f a,
                    ben_prtn_eligy_rl_f b
             where  a.prtn_elig_id = b.prtn_elig_id
             and    a.pgm_id = c.pgm_id)
      and c.pgm_id = l_c1.pgm_id;
    -- updates drvbl_fctr_prtn_elig_flag
     ben_derivable_factor.eligy_prfl_handler('DELETE','ben_pgm_f','pgm_id',l_c1.pgm_id);
    --
    --updates elig_apls_flag to 'N' in ben_plip_f table only when
    --no record found in profile and rule tables.
  elsif l_c1.plip_id is not null then
    --
    update ben_plip_f c
      set    c.elig_apls_flag = 'N'
      where not exists
            (select a.plip_id
             from   ben_prtn_elig_f a,
                    ben_prtn_elig_prfl_f b
             where  a.prtn_elig_id = b.prtn_elig_id
             and    a.plip_id = c.plip_id)
      and not exists
            (select a.plip_id
             from   ben_prtn_elig_f a,
                    ben_prtn_eligy_rl_f b
             where  a.prtn_elig_id = b.prtn_elig_id
             and    a.plip_id = c.plip_id)
      and c.plip_id = l_c1.plip_id;
    --
    -- updates drvbl_fctr_prtn_elig_flag
     ben_derivable_factor.eligy_prfl_handler('DELETE','ben_plip_f','plip_id',l_c1.plip_id);
    --
    --
    --updates elig_apls_flag to 'N' in ben_ptip_f table only when
    --no record found in profile and rule tables.
  elsif l_c1.ptip_id is not null then
    update ben_ptip_f c
      set    c.elig_apls_flag = 'N'
      where not exists
            (select a.ptip_id
             from   ben_prtn_elig_f a,
                    ben_prtn_elig_prfl_f b
             where  a.prtn_elig_id = b.prtn_elig_id
             and    a.ptip_id = c.ptip_id)
      and not exists
            (select a.ptip_id
             from   ben_prtn_elig_f a,
                    ben_prtn_eligy_rl_f b
             where  a.prtn_elig_id = b.prtn_elig_id
             and    a.ptip_id = c.ptip_id)
      and c.ptip_id = l_c1.ptip_id;
    --
    -- updates drvbl_fctr_prtn_elig_flag
     ben_derivable_factor.eligy_prfl_handler('DELETE','ben_ptip_f','ptip_id',l_c1.ptip_id);
    --
    --updates elig_apls_flag to 'N' in ben_pl_f table only when
    --no record found in profile and rule tables.
  elsif l_c1.pl_id is not null then
    update ben_pl_f c
      set    c.elig_apls_flag = 'N'
      where not exists
            (select a.pl_id
             from   ben_prtn_elig_f a,
                    ben_prtn_elig_prfl_f b
             where  a.prtn_elig_id = b.prtn_elig_id
             and    a.pl_id = c.pl_id)
      and not exists
            (select a.pl_id
             from   ben_prtn_elig_f a,
                    ben_prtn_eligy_rl_f b
             where  a.prtn_elig_id = b.prtn_elig_id
             and    a.pl_id = c.pl_id)
      and c.pl_id = l_c1.pl_id;
    --
    -- updates drvbl_fctr_prtn_elig_flag
     ben_derivable_factor.eligy_prfl_handler('DELETE','ben_pl_f','pl_id',l_c1.pl_id);
    --
    --
    --updates elig_apls_flag to 'N' in ben_oipl_f table only when
    --no record found in profile and rule tables.
  elsif l_c1.oipl_id is not null then
    update ben_oipl_f c
      set    c.elig_apls_flag = 'N'
      where not exists
            (select a.oipl_id
             from   ben_prtn_elig_f a,
                    ben_prtn_elig_prfl_f b
             where  a.prtn_elig_id = b.prtn_elig_id
             and    a.oipl_id = c.oipl_id)
      and not exists
            (select a.oipl_id
             from   ben_prtn_elig_f a,
                    ben_prtn_eligy_rl_f b
             where  a.prtn_elig_id = b.prtn_elig_id
             and    a.oipl_id = c.oipl_id)
      and c.oipl_id = l_c1.oipl_id;
    --
    -- updates drvbl_fctr_prtn_elig_flag
     ben_derivable_factor.eligy_prfl_handler('DELETE','ben_oipl_f','oipl_id',l_c1.oipl_id);
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
    ROLLBACK TO delete_PRTN_ELIG_PRFL;
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
    ROLLBACK TO delete_PRTN_ELIG_PRFL;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_PRTN_ELIG_PRFL;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_prtn_elig_prfl_id                   in     number
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
  ben_cep_shd.lck
    (
      p_prtn_elig_prfl_id                 => p_prtn_elig_prfl_id
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
procedure insert_prtn_elig
 (
    p_pgm_id                in number  default null
   ,p_pl_id                 in number  default null
   ,p_plip_id               in number  default null
   ,p_oipl_id               in number  default null
   ,p_ptip_id               in number  default null
   ,p_effective_date        in date
   ,p_business_group_id     in number  default null
   ,p_prtn_elig_id          out nocopy number
  )  is
  --
     l_effective_start_date      date;
     l_effective_end_date        date;
     l_prtn_elig_id              number;
     l_object_version_number     number;
  --
     cursor c1 is
       select prtn_elig_id
        from ben_prtn_elig_f
        where ( pgm_id   = p_pgm_id or p_pgm_id is null  ) and
              ( pl_id    = p_pl_id  or p_pl_id is null   ) and
              ( plip_id  = p_plip_id or p_plip_id is null) and
              ( ptip_id  = p_ptip_id or p_ptip_id is null) and
              ( oipl_id  = p_oipl_id or p_oipl_id is null) and
                effective_start_date <= p_effective_date   and
                effective_end_date   >= p_effective_date;
begin
   --
   open c1;
   fetch c1 into l_prtn_elig_id;
   if c1%notfound then
      ben_Participation_Elig_api.create_Participation_Elig
        ( p_prtn_elig_id                   =>l_prtn_elig_id
        ,p_effective_start_date           =>l_effective_start_date
        ,p_effective_end_date             =>l_effective_end_date
        ,p_business_group_id              =>p_business_group_id
        ,p_pgm_id                         =>p_pgm_id
        ,p_pl_id                          =>p_pl_id
        ,p_oipl_id                        =>p_oipl_id
        ,p_ptip_id                        =>p_ptip_id
        ,p_plip_id                        =>p_plip_id
        ,p_object_version_number          =>l_object_version_number
        ,p_trk_scr_for_inelg_flag         =>'N'
        ,p_effective_date                 =>p_effective_date
        ) ;
   end if;
   close c1;
   --
   p_prtn_elig_id   := l_prtn_elig_id;
   --
end;
end ben_PRTN_ELIG_PRFL_api;

/
