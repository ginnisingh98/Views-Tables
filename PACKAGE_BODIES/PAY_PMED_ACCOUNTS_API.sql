--------------------------------------------------------
--  DDL for Package Body PAY_PMED_ACCOUNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PMED_ACCOUNTS_API" as
/* $Header: pypmaapi.pkb 115.2 2002/12/11 11:12:47 ssivasu2 noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_pmed_accounts_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_pmed_accounts >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pmed_accounts
  (p_validate                       in            boolean   default false
  ,p_organization_id                in            number    default null
  ,p_source_id                      out nocopy    number
  ,p_account_number                 in            varchar2  default null
  ,p_enabled                        in            varchar2  default null
  ,p_description                    in            varchar2  default null
  ,p_business_group_id              in            number    default null
  ,p_attribute_category             in            varchar2  default null
  ,p_attribute1                     in            varchar2  default null
  ,p_attribute2                     in            varchar2  default null
  ,p_attribute3                     in            varchar2  default null
  ,p_attribute4                     in            varchar2  default null
  ,p_attribute5                     in            varchar2  default null
  ,p_attribute6                     in            varchar2  default null
  ,p_attribute7                     in            varchar2  default null
  ,p_attribute8                     in            varchar2  default null
  ,p_attribute9                     in            varchar2  default null
  ,p_attribute10                    in            varchar2  default null
  ,p_attribute11                    in            varchar2  default null
  ,p_attribute12                    in            varchar2  default null
  ,p_attribute13                    in            varchar2  default null
  ,p_attribute14                    in            varchar2  default null
  ,p_attribute15                    in            varchar2  default null
  ,p_attribute16                    in            varchar2  default null
  ,p_attribute17                    in            varchar2  default null
  ,p_attribute18                    in            varchar2  default null
  ,p_attribute19                    in            varchar2  default null
  ,p_attribute20                    in            varchar2  default null
  ,p_attribute21                    in            varchar2  default null
  ,p_attribute22                    in            varchar2  default null
  ,p_attribute23                    in            varchar2  default null
  ,p_attribute24                    in            varchar2  default null
  ,p_attribute25                    in            varchar2  default null
  ,p_attribute26                    in            varchar2  default null
  ,p_attribute27                    in            varchar2  default null
  ,p_attribute28                    in            varchar2  default null
  ,p_attribute29                    in            varchar2  default null
  ,p_attribute30                    in            varchar2  default null
  ,p_object_version_number          out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_source_id pay_ca_pmed_accounts.source_id%TYPE;
  l_proc varchar2(72) := g_package||'create_pmed_accounts';
  l_object_version_number pay_ca_pmed_accounts.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_pmed_accounts;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_pmed_accounts
    --
    pay_pmed_accounts_bk1.create_pmed_accounts_b
      (
       p_organization_id                =>  p_organization_id
      ,p_account_number                 =>  p_account_number
      ,p_enabled                        =>  p_enabled
      ,p_description                    =>  p_description
      ,p_business_group_id              =>  p_business_group_id
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_pmed_accounts'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_pmed_accounts
    --
  end;
  --
  pay_pma_ins.ins
    (
     p_organization_id               => p_organization_id
    ,p_source_id                     => l_source_id
    ,p_account_number                => p_account_number
    ,p_enabled                       => p_enabled
    ,p_description                   => p_description
    ,p_business_group_id             => p_business_group_id
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_attribute21                   => p_attribute21
    ,p_attribute22                   => p_attribute22
    ,p_attribute23                   => p_attribute23
    ,p_attribute24                   => p_attribute24
    ,p_attribute25                   => p_attribute25
    ,p_attribute26                   => p_attribute26
    ,p_attribute27                   => p_attribute27
    ,p_attribute28                   => p_attribute28
    ,p_attribute29                   => p_attribute29
    ,p_attribute30                   => p_attribute30
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_pmed_accounts
    --
    pay_pmed_accounts_bk1.create_pmed_accounts_a
      (
       p_organization_id                =>  p_organization_id
      ,p_source_id                      =>  l_source_id
      ,p_account_number                 =>  p_account_number
      ,p_enabled                        =>  p_enabled
      ,p_description                    =>  p_description
      ,p_business_group_id              =>  p_business_group_id
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_pmed_accounts'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_pmed_accounts
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
  p_source_id := l_source_id;
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
    ROLLBACK TO create_pmed_accounts;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_source_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_pmed_accounts;
    --
    p_source_id := null;
    p_object_version_number  := null;
    --
    raise;
    --
end create_pmed_accounts;
-- ----------------------------------------------------------------------------
-- |------------------------< update_pmed_accounts >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pmed_accounts
  (p_validate                       in            boolean   default false
  ,p_organization_id                in            number    default hr_api.g_number
  ,p_source_id                      in            number
  ,p_account_number                 in            varchar2  default hr_api.g_varchar2
  ,p_enabled                        in            varchar2  default hr_api.g_varchar2
  ,p_description                    in            varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in            number    default hr_api.g_number
  ,p_attribute_category             in            varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in            varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute21                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute22                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute23                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute24                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute25                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute26                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute27                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute28                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute29                    in            varchar2  default hr_api.g_varchar2
  ,p_attribute30                    in            varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_pmed_accounts';
  l_object_version_number pay_ca_pmed_accounts.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_pmed_accounts;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_pmed_accounts
    --
    pay_pmed_accounts_bk2.update_pmed_accounts_b
      (
       p_organization_id                =>  p_organization_id
      ,p_source_id                      =>  p_source_id
      ,p_account_number                 =>  p_account_number
      ,p_enabled                        =>  p_enabled
      ,p_description                    =>  p_description
      ,p_business_group_id              =>  p_business_group_id
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_pmed_accounts'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_pmed_accounts
    --
  end;
  --
  pay_pma_upd.upd
    (
     p_organization_id               => p_organization_id
    ,p_source_id                     => p_source_id
    ,p_account_number                => p_account_number
    ,p_enabled                       => p_enabled
    ,p_description                   => p_description
    ,p_business_group_id             => p_business_group_id
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_attribute21                   => p_attribute21
    ,p_attribute22                   => p_attribute22
    ,p_attribute23                   => p_attribute23
    ,p_attribute24                   => p_attribute24
    ,p_attribute25                   => p_attribute25
    ,p_attribute26                   => p_attribute26
    ,p_attribute27                   => p_attribute27
    ,p_attribute28                   => p_attribute28
    ,p_attribute29                   => p_attribute29
    ,p_attribute30                   => p_attribute30
    ,p_object_version_number         => p_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_pmed_accounts
    --
    pay_pmed_accounts_bk2.update_pmed_accounts_a
      (
       p_organization_id                =>  p_organization_id
      ,p_source_id                      =>  p_source_id
      ,p_account_number                 =>  p_account_number
      ,p_enabled                        =>  p_enabled
      ,p_description                    =>  p_description
      ,p_business_group_id              =>  p_business_group_id
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_pmed_accounts'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_pmed_accounts
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
    ROLLBACK TO update_pmed_accounts;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_pmed_accounts;
    --
    p_object_version_number := l_object_version_number;
    --
    raise;
    --
end update_pmed_accounts;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pmed_accounts >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pmed_accounts
  (p_validate                       in            boolean   default false
  ,p_source_id                      in            number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_pmed_accounts';
  l_object_version_number pay_ca_pmed_accounts.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_pmed_accounts;
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
    -- Start of API User Hook for the before hook of delete_pmed_accounts
    --
    pay_pmed_accounts_bk3.delete_pmed_accounts_b
      (
       p_source_id                      =>  p_source_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_pmed_accounts'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_pmed_accounts
    --
  end;
  --
  pay_pma_del.del
    (
     p_source_id                     => p_source_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_pmed_accounts
    --
    pay_pmed_accounts_bk3.delete_pmed_accounts_a
      (
       p_source_id                      =>  p_source_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_pmed_accounts'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_pmed_accounts
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_pmed_accounts;
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
    ROLLBACK TO delete_pmed_accounts;
    raise;
    --
end delete_pmed_accounts;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_source_id                   in     number
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
  pay_pma_shd.lck
    (
      p_source_id                 => p_source_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pay_pmed_accounts_api;

/
