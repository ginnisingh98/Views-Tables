--------------------------------------------------------
--  DDL for Package Body BEN_BENEFITS_BALANCE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENEFITS_BALANCE_API" as
/* $Header: bebnbapi.pkb 115.4 2002/12/16 09:35:50 hnarayan ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_benefits_balance_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_benefits_balance >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_benefits_balance
  (p_validate                       in  boolean   default false
  ,p_bnfts_bal_id                   out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_bnfts_bal_usg_cd               in  varchar2  default null
  ,p_bnfts_bal_desc                 in  varchar2  default null
  ,p_uom                            in  varchar2  default null
  ,p_nnmntry_uom                    in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_bnb_attribute_category         in  varchar2  default null
  ,p_bnb_attribute1                 in  varchar2  default null
  ,p_bnb_attribute2                 in  varchar2  default null
  ,p_bnb_attribute3                 in  varchar2  default null
  ,p_bnb_attribute4                 in  varchar2  default null
  ,p_bnb_attribute5                 in  varchar2  default null
  ,p_bnb_attribute6                 in  varchar2  default null
  ,p_bnb_attribute7                 in  varchar2  default null
  ,p_bnb_attribute8                 in  varchar2  default null
  ,p_bnb_attribute9                 in  varchar2  default null
  ,p_bnb_attribute10                in  varchar2  default null
  ,p_bnb_attribute11                in  varchar2  default null
  ,p_bnb_attribute12                in  varchar2  default null
  ,p_bnb_attribute13                in  varchar2  default null
  ,p_bnb_attribute14                in  varchar2  default null
  ,p_bnb_attribute15                in  varchar2  default null
  ,p_bnb_attribute16                in  varchar2  default null
  ,p_bnb_attribute17                in  varchar2  default null
  ,p_bnb_attribute18                in  varchar2  default null
  ,p_bnb_attribute19                in  varchar2  default null
  ,p_bnb_attribute20                in  varchar2  default null
  ,p_bnb_attribute21                in  varchar2  default null
  ,p_bnb_attribute22                in  varchar2  default null
  ,p_bnb_attribute23                in  varchar2  default null
  ,p_bnb_attribute24                in  varchar2  default null
  ,p_bnb_attribute25                in  varchar2  default null
  ,p_bnb_attribute26                in  varchar2  default null
  ,p_bnb_attribute27                in  varchar2  default null
  ,p_bnb_attribute28                in  varchar2  default null
  ,p_bnb_attribute29                in  varchar2  default null
  ,p_bnb_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_bnfts_bal_id ben_bnfts_bal_f.bnfts_bal_id%TYPE;
  l_effective_start_date ben_bnfts_bal_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnfts_bal_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_benefits_balance';
  l_object_version_number ben_bnfts_bal_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_benefits_balance;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_benefits_balance
    --
    ben_benefits_balance_bk1.create_benefits_balance_b
      (
       p_name                           =>  p_name
      ,p_bnfts_bal_usg_cd               =>  p_bnfts_bal_usg_cd
      ,p_bnfts_bal_desc                 =>  p_bnfts_bal_desc
      ,p_uom                            =>  p_uom
      ,p_nnmntry_uom                    =>  p_nnmntry_uom
      ,p_business_group_id              =>  p_business_group_id
      ,p_bnb_attribute_category         =>  p_bnb_attribute_category
      ,p_bnb_attribute1                 =>  p_bnb_attribute1
      ,p_bnb_attribute2                 =>  p_bnb_attribute2
      ,p_bnb_attribute3                 =>  p_bnb_attribute3
      ,p_bnb_attribute4                 =>  p_bnb_attribute4
      ,p_bnb_attribute5                 =>  p_bnb_attribute5
      ,p_bnb_attribute6                 =>  p_bnb_attribute6
      ,p_bnb_attribute7                 =>  p_bnb_attribute7
      ,p_bnb_attribute8                 =>  p_bnb_attribute8
      ,p_bnb_attribute9                 =>  p_bnb_attribute9
      ,p_bnb_attribute10                =>  p_bnb_attribute10
      ,p_bnb_attribute11                =>  p_bnb_attribute11
      ,p_bnb_attribute12                =>  p_bnb_attribute12
      ,p_bnb_attribute13                =>  p_bnb_attribute13
      ,p_bnb_attribute14                =>  p_bnb_attribute14
      ,p_bnb_attribute15                =>  p_bnb_attribute15
      ,p_bnb_attribute16                =>  p_bnb_attribute16
      ,p_bnb_attribute17                =>  p_bnb_attribute17
      ,p_bnb_attribute18                =>  p_bnb_attribute18
      ,p_bnb_attribute19                =>  p_bnb_attribute19
      ,p_bnb_attribute20                =>  p_bnb_attribute20
      ,p_bnb_attribute21                =>  p_bnb_attribute21
      ,p_bnb_attribute22                =>  p_bnb_attribute22
      ,p_bnb_attribute23                =>  p_bnb_attribute23
      ,p_bnb_attribute24                =>  p_bnb_attribute24
      ,p_bnb_attribute25                =>  p_bnb_attribute25
      ,p_bnb_attribute26                =>  p_bnb_attribute26
      ,p_bnb_attribute27                =>  p_bnb_attribute27
      ,p_bnb_attribute28                =>  p_bnb_attribute28
      ,p_bnb_attribute29                =>  p_bnb_attribute29
      ,p_bnb_attribute30                =>  p_bnb_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_benefits_balance'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_benefits_balance
    --
  end;
  --
  ben_bnb_ins.ins
    (
     p_bnfts_bal_id                  => l_bnfts_bal_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_bnfts_bal_usg_cd              => p_bnfts_bal_usg_cd
    ,p_bnfts_bal_desc                => p_bnfts_bal_desc
    ,p_uom                           => p_uom
    ,p_nnmntry_uom                   => p_nnmntry_uom
    ,p_business_group_id             => p_business_group_id
    ,p_bnb_attribute_category        => p_bnb_attribute_category
    ,p_bnb_attribute1                => p_bnb_attribute1
    ,p_bnb_attribute2                => p_bnb_attribute2
    ,p_bnb_attribute3                => p_bnb_attribute3
    ,p_bnb_attribute4                => p_bnb_attribute4
    ,p_bnb_attribute5                => p_bnb_attribute5
    ,p_bnb_attribute6                => p_bnb_attribute6
    ,p_bnb_attribute7                => p_bnb_attribute7
    ,p_bnb_attribute8                => p_bnb_attribute8
    ,p_bnb_attribute9                => p_bnb_attribute9
    ,p_bnb_attribute10               => p_bnb_attribute10
    ,p_bnb_attribute11               => p_bnb_attribute11
    ,p_bnb_attribute12               => p_bnb_attribute12
    ,p_bnb_attribute13               => p_bnb_attribute13
    ,p_bnb_attribute14               => p_bnb_attribute14
    ,p_bnb_attribute15               => p_bnb_attribute15
    ,p_bnb_attribute16               => p_bnb_attribute16
    ,p_bnb_attribute17               => p_bnb_attribute17
    ,p_bnb_attribute18               => p_bnb_attribute18
    ,p_bnb_attribute19               => p_bnb_attribute19
    ,p_bnb_attribute20               => p_bnb_attribute20
    ,p_bnb_attribute21               => p_bnb_attribute21
    ,p_bnb_attribute22               => p_bnb_attribute22
    ,p_bnb_attribute23               => p_bnb_attribute23
    ,p_bnb_attribute24               => p_bnb_attribute24
    ,p_bnb_attribute25               => p_bnb_attribute25
    ,p_bnb_attribute26               => p_bnb_attribute26
    ,p_bnb_attribute27               => p_bnb_attribute27
    ,p_bnb_attribute28               => p_bnb_attribute28
    ,p_bnb_attribute29               => p_bnb_attribute29
    ,p_bnb_attribute30               => p_bnb_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_benefits_balance
    --
    ben_benefits_balance_bk1.create_benefits_balance_a
      (
       p_bnfts_bal_id                   =>  l_bnfts_bal_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_bnfts_bal_usg_cd               =>  p_bnfts_bal_usg_cd
      ,p_bnfts_bal_desc                 =>  p_bnfts_bal_desc
      ,p_uom                            =>  p_uom
      ,p_nnmntry_uom                    =>  p_nnmntry_uom
      ,p_business_group_id              =>  p_business_group_id
      ,p_bnb_attribute_category         =>  p_bnb_attribute_category
      ,p_bnb_attribute1                 =>  p_bnb_attribute1
      ,p_bnb_attribute2                 =>  p_bnb_attribute2
      ,p_bnb_attribute3                 =>  p_bnb_attribute3
      ,p_bnb_attribute4                 =>  p_bnb_attribute4
      ,p_bnb_attribute5                 =>  p_bnb_attribute5
      ,p_bnb_attribute6                 =>  p_bnb_attribute6
      ,p_bnb_attribute7                 =>  p_bnb_attribute7
      ,p_bnb_attribute8                 =>  p_bnb_attribute8
      ,p_bnb_attribute9                 =>  p_bnb_attribute9
      ,p_bnb_attribute10                =>  p_bnb_attribute10
      ,p_bnb_attribute11                =>  p_bnb_attribute11
      ,p_bnb_attribute12                =>  p_bnb_attribute12
      ,p_bnb_attribute13                =>  p_bnb_attribute13
      ,p_bnb_attribute14                =>  p_bnb_attribute14
      ,p_bnb_attribute15                =>  p_bnb_attribute15
      ,p_bnb_attribute16                =>  p_bnb_attribute16
      ,p_bnb_attribute17                =>  p_bnb_attribute17
      ,p_bnb_attribute18                =>  p_bnb_attribute18
      ,p_bnb_attribute19                =>  p_bnb_attribute19
      ,p_bnb_attribute20                =>  p_bnb_attribute20
      ,p_bnb_attribute21                =>  p_bnb_attribute21
      ,p_bnb_attribute22                =>  p_bnb_attribute22
      ,p_bnb_attribute23                =>  p_bnb_attribute23
      ,p_bnb_attribute24                =>  p_bnb_attribute24
      ,p_bnb_attribute25                =>  p_bnb_attribute25
      ,p_bnb_attribute26                =>  p_bnb_attribute26
      ,p_bnb_attribute27                =>  p_bnb_attribute27
      ,p_bnb_attribute28                =>  p_bnb_attribute28
      ,p_bnb_attribute29                =>  p_bnb_attribute29
      ,p_bnb_attribute30                =>  p_bnb_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_benefits_balance'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_benefits_balance
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
  p_bnfts_bal_id := l_bnfts_bal_id;
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
    ROLLBACK TO create_benefits_balance;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_bnfts_bal_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_bnfts_bal_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    ROLLBACK TO create_benefits_balance;
    raise;
    --
end create_benefits_balance;
-- ----------------------------------------------------------------------------
-- |------------------------< update_benefits_balance >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_benefits_balance
  (p_validate                       in  boolean   default false
  ,p_bnfts_bal_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_bnfts_bal_usg_cd               in  varchar2  default hr_api.g_varchar2
  ,p_bnfts_bal_desc                 in  varchar2  default hr_api.g_varchar2
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_nnmntry_uom                    in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_bnb_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_bnb_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_benefits_balance';
  l_object_version_number ben_bnfts_bal_f.object_version_number%TYPE;
  l_effective_start_date ben_bnfts_bal_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnfts_bal_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_benefits_balance;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_benefits_balance
    --
    ben_benefits_balance_bk2.update_benefits_balance_b
      (
       p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_name                           =>  p_name
      ,p_bnfts_bal_usg_cd               =>  p_bnfts_bal_usg_cd
      ,p_bnfts_bal_desc                 =>  p_bnfts_bal_desc
      ,p_uom                            =>  p_uom
      ,p_nnmntry_uom                    =>  p_nnmntry_uom
      ,p_business_group_id              =>  p_business_group_id
      ,p_bnb_attribute_category         =>  p_bnb_attribute_category
      ,p_bnb_attribute1                 =>  p_bnb_attribute1
      ,p_bnb_attribute2                 =>  p_bnb_attribute2
      ,p_bnb_attribute3                 =>  p_bnb_attribute3
      ,p_bnb_attribute4                 =>  p_bnb_attribute4
      ,p_bnb_attribute5                 =>  p_bnb_attribute5
      ,p_bnb_attribute6                 =>  p_bnb_attribute6
      ,p_bnb_attribute7                 =>  p_bnb_attribute7
      ,p_bnb_attribute8                 =>  p_bnb_attribute8
      ,p_bnb_attribute9                 =>  p_bnb_attribute9
      ,p_bnb_attribute10                =>  p_bnb_attribute10
      ,p_bnb_attribute11                =>  p_bnb_attribute11
      ,p_bnb_attribute12                =>  p_bnb_attribute12
      ,p_bnb_attribute13                =>  p_bnb_attribute13
      ,p_bnb_attribute14                =>  p_bnb_attribute14
      ,p_bnb_attribute15                =>  p_bnb_attribute15
      ,p_bnb_attribute16                =>  p_bnb_attribute16
      ,p_bnb_attribute17                =>  p_bnb_attribute17
      ,p_bnb_attribute18                =>  p_bnb_attribute18
      ,p_bnb_attribute19                =>  p_bnb_attribute19
      ,p_bnb_attribute20                =>  p_bnb_attribute20
      ,p_bnb_attribute21                =>  p_bnb_attribute21
      ,p_bnb_attribute22                =>  p_bnb_attribute22
      ,p_bnb_attribute23                =>  p_bnb_attribute23
      ,p_bnb_attribute24                =>  p_bnb_attribute24
      ,p_bnb_attribute25                =>  p_bnb_attribute25
      ,p_bnb_attribute26                =>  p_bnb_attribute26
      ,p_bnb_attribute27                =>  p_bnb_attribute27
      ,p_bnb_attribute28                =>  p_bnb_attribute28
      ,p_bnb_attribute29                =>  p_bnb_attribute29
      ,p_bnb_attribute30                =>  p_bnb_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_benefits_balance'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_benefits_balance
    --
  end;
  --
  ben_bnb_upd.upd
    (
     p_bnfts_bal_id                  => p_bnfts_bal_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_bnfts_bal_usg_cd              => p_bnfts_bal_usg_cd
    ,p_bnfts_bal_desc                => p_bnfts_bal_desc
    ,p_uom                           => p_uom
    ,p_nnmntry_uom                   => p_nnmntry_uom
    ,p_business_group_id             => p_business_group_id
    ,p_bnb_attribute_category        => p_bnb_attribute_category
    ,p_bnb_attribute1                => p_bnb_attribute1
    ,p_bnb_attribute2                => p_bnb_attribute2
    ,p_bnb_attribute3                => p_bnb_attribute3
    ,p_bnb_attribute4                => p_bnb_attribute4
    ,p_bnb_attribute5                => p_bnb_attribute5
    ,p_bnb_attribute6                => p_bnb_attribute6
    ,p_bnb_attribute7                => p_bnb_attribute7
    ,p_bnb_attribute8                => p_bnb_attribute8
    ,p_bnb_attribute9                => p_bnb_attribute9
    ,p_bnb_attribute10               => p_bnb_attribute10
    ,p_bnb_attribute11               => p_bnb_attribute11
    ,p_bnb_attribute12               => p_bnb_attribute12
    ,p_bnb_attribute13               => p_bnb_attribute13
    ,p_bnb_attribute14               => p_bnb_attribute14
    ,p_bnb_attribute15               => p_bnb_attribute15
    ,p_bnb_attribute16               => p_bnb_attribute16
    ,p_bnb_attribute17               => p_bnb_attribute17
    ,p_bnb_attribute18               => p_bnb_attribute18
    ,p_bnb_attribute19               => p_bnb_attribute19
    ,p_bnb_attribute20               => p_bnb_attribute20
    ,p_bnb_attribute21               => p_bnb_attribute21
    ,p_bnb_attribute22               => p_bnb_attribute22
    ,p_bnb_attribute23               => p_bnb_attribute23
    ,p_bnb_attribute24               => p_bnb_attribute24
    ,p_bnb_attribute25               => p_bnb_attribute25
    ,p_bnb_attribute26               => p_bnb_attribute26
    ,p_bnb_attribute27               => p_bnb_attribute27
    ,p_bnb_attribute28               => p_bnb_attribute28
    ,p_bnb_attribute29               => p_bnb_attribute29
    ,p_bnb_attribute30               => p_bnb_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_benefits_balance
    --
    ben_benefits_balance_bk2.update_benefits_balance_a
      (
       p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_bnfts_bal_usg_cd               =>  p_bnfts_bal_usg_cd
      ,p_bnfts_bal_desc                 =>  p_bnfts_bal_desc
      ,p_uom                            =>  p_uom
      ,p_nnmntry_uom                    =>  p_nnmntry_uom
      ,p_business_group_id              =>  p_business_group_id
      ,p_bnb_attribute_category         =>  p_bnb_attribute_category
      ,p_bnb_attribute1                 =>  p_bnb_attribute1
      ,p_bnb_attribute2                 =>  p_bnb_attribute2
      ,p_bnb_attribute3                 =>  p_bnb_attribute3
      ,p_bnb_attribute4                 =>  p_bnb_attribute4
      ,p_bnb_attribute5                 =>  p_bnb_attribute5
      ,p_bnb_attribute6                 =>  p_bnb_attribute6
      ,p_bnb_attribute7                 =>  p_bnb_attribute7
      ,p_bnb_attribute8                 =>  p_bnb_attribute8
      ,p_bnb_attribute9                 =>  p_bnb_attribute9
      ,p_bnb_attribute10                =>  p_bnb_attribute10
      ,p_bnb_attribute11                =>  p_bnb_attribute11
      ,p_bnb_attribute12                =>  p_bnb_attribute12
      ,p_bnb_attribute13                =>  p_bnb_attribute13
      ,p_bnb_attribute14                =>  p_bnb_attribute14
      ,p_bnb_attribute15                =>  p_bnb_attribute15
      ,p_bnb_attribute16                =>  p_bnb_attribute16
      ,p_bnb_attribute17                =>  p_bnb_attribute17
      ,p_bnb_attribute18                =>  p_bnb_attribute18
      ,p_bnb_attribute19                =>  p_bnb_attribute19
      ,p_bnb_attribute20                =>  p_bnb_attribute20
      ,p_bnb_attribute21                =>  p_bnb_attribute21
      ,p_bnb_attribute22                =>  p_bnb_attribute22
      ,p_bnb_attribute23                =>  p_bnb_attribute23
      ,p_bnb_attribute24                =>  p_bnb_attribute24
      ,p_bnb_attribute25                =>  p_bnb_attribute25
      ,p_bnb_attribute26                =>  p_bnb_attribute26
      ,p_bnb_attribute27                =>  p_bnb_attribute27
      ,p_bnb_attribute28                =>  p_bnb_attribute28
      ,p_bnb_attribute29                =>  p_bnb_attribute29
      ,p_bnb_attribute30                =>  p_bnb_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_benefits_balance'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_benefits_balance
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
    ROLLBACK TO update_benefits_balance;
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
    ROLLBACK TO update_benefits_balance;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_benefits_balance;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_benefits_balance >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_benefits_balance
  (p_validate                       in  boolean  default false
  ,p_bnfts_bal_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_benefits_balance';
  l_object_version_number ben_bnfts_bal_f.object_version_number%TYPE;
  l_effective_start_date ben_bnfts_bal_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnfts_bal_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_benefits_balance;
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
    -- Start of API User Hook for the before hook of delete_benefits_balance
    --
    ben_benefits_balance_bk3.delete_benefits_balance_b
      (
       p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_benefits_balance'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_benefits_balance
    --
  end;
  --
  ben_bnb_del.del
    (
     p_bnfts_bal_id                  => p_bnfts_bal_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_benefits_balance
    --
    ben_benefits_balance_bk3.delete_benefits_balance_a
      (
       p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_benefits_balance'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_benefits_balance
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
    ROLLBACK TO delete_benefits_balance;
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
    ROLLBACK TO delete_benefits_balance;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_benefits_balance;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_bnfts_bal_id                   in     number
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
  ben_bnb_shd.lck
    (
      p_bnfts_bal_id                 => p_bnfts_bal_id
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
end ben_benefits_balance_api;

/
