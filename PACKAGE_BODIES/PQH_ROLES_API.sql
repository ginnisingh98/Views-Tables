--------------------------------------------------------
--  DDL for Package Body PQH_ROLES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ROLES_API" as
/* $Header: pqrlsapi.pkb 115.8 2002/12/03 20:43:04 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_roles_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_role >----------------------|
-- ----------------------------------------------------------------------------
--
-- mvanakda
-- Added Developer DF Columns to the procedure create_role
procedure create_role
  (p_validate                       in  boolean
  ,p_role_id                        out nocopy number
  ,p_role_name                      in  varchar2
  ,p_role_type_cd                   in  varchar2
  ,p_enable_flag                    in  varchar2
  ,p_object_version_number          out nocopy number
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ,p_information_category           in varchar2
  ,p_information1                   in varchar2
  ,p_information2                   in varchar2
  ,p_information3                   in varchar2
  ,p_information4                   in varchar2
  ,p_information5                   in varchar2
  ,p_information6                   in varchar2
  ,p_information7                   in varchar2
  ,p_information8                   in varchar2
  ,p_information9                   in varchar2
  ,p_information10                  in varchar2
  ,p_information11                  in varchar2
  ,p_information12                  in varchar2
  ,p_information13                  in varchar2
  ,p_information14                  in varchar2
  ,p_information15                  in varchar2
  ,p_information16                  in varchar2
  ,p_information17                  in varchar2
  ,p_information18                  in varchar2
  ,p_information19                  in varchar2
  ,p_information20                  in varchar2
  ,p_information21                  in varchar2
  ,p_information22                  in varchar2
  ,p_information23                  in varchar2
  ,p_information24                  in varchar2
  ,p_information25                  in varchar2
  ,p_information26                  in varchar2
  ,p_information27                  in varchar2
  ,p_information28                  in varchar2
  ,p_information29                  in varchar2
  ,p_information30                  in varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_role_id pqh_roles.role_id%TYPE;
  l_proc varchar2(72) := g_package||'create_role';
  l_object_version_number pqh_roles.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_role;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_role
    --



    pqh_roles_bk1.create_role_b
      (
       p_role_name                      =>  p_role_name
      ,p_role_type_cd                   =>  p_role_type_cd
      ,p_enable_flag                    =>  p_enable_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_information_category           => p_information_category
      ,p_information1              	=> p_information1
      ,p_information2                   => p_information2
      ,p_information3                   => p_information3
      ,p_information4                   => p_information4
      ,p_information5                   => p_information5
      ,p_information6                   => p_information6
      ,p_information7                   => p_information7
      ,p_information8                   => p_information8
      ,p_information9                   => p_information9
      ,p_information10                  => p_information10
      ,p_information11                  => p_information11
      ,p_information12                  => p_information12
      ,p_information13                  => p_information13
      ,p_information14                  => p_information14
      ,p_information15                  => p_information15
      ,p_information16                  => p_information16
      ,p_information17                  => p_information17
      ,p_information18                  => p_information18
      ,p_information19                  => p_information19
      ,p_information20                  => p_information20
      ,p_information21                  => p_information21
      ,p_information22                  => p_information22
      ,p_information23                  => p_information23
      ,p_information24                  => p_information24
      ,p_information25                  => p_information25
      ,p_information26                  => p_information26
      ,p_information27                  => p_information27
      ,p_information28                  => p_information28
      ,p_information29                  => p_information29
      ,p_information30                  => p_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_role'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_role
    --
  end;
  --
  pqh_rls_ins.ins
    (
     p_role_id                       => l_role_id
    ,p_role_name                     => p_role_name
    ,p_role_type_cd                  => p_role_type_cd
    ,p_enable_flag                   => p_enable_flag
    ,p_object_version_number         => l_object_version_number
    ,p_business_group_id             => p_business_group_id
    ,p_effective_date                => trunc(p_effective_date)
      ,p_information_category           => p_information_category
      ,p_information1              	=> p_information1
      ,p_information2                   => p_information2
      ,p_information3                   => p_information3
      ,p_information4                   => p_information4
      ,p_information5                   => p_information5
      ,p_information6                   => p_information6
      ,p_information7                   => p_information7
      ,p_information8                   => p_information8
      ,p_information9                   => p_information9
      ,p_information10                  => p_information10
      ,p_information11                  => p_information11
      ,p_information12                  => p_information12
      ,p_information13                  => p_information13
      ,p_information14                  => p_information14
      ,p_information15                  => p_information15
      ,p_information16                  => p_information16
      ,p_information17                  => p_information17
      ,p_information18                  => p_information18
      ,p_information19                  => p_information19
      ,p_information20                  => p_information20
      ,p_information21                  => p_information21
      ,p_information22                  => p_information22
      ,p_information23                  => p_information23
      ,p_information24                  => p_information24
      ,p_information25                  => p_information25
      ,p_information26                  => p_information26
      ,p_information27                  => p_information27
      ,p_information28                  => p_information28
      ,p_information29                  => p_information29
      ,p_information30                  => p_information30
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_role
    --
    pqh_roles_bk1.create_role_a
      (
       p_role_id                        =>  l_role_id
      ,p_role_name                      =>  p_role_name
      ,p_role_type_cd                   =>  p_role_type_cd
      ,p_enable_flag                    =>  p_enable_flag
      ,p_object_version_number          =>  l_object_version_number
      ,p_business_group_id              =>  p_business_group_id
      ,p_effective_date                 => trunc(p_effective_date)
       ,p_information_category          => p_information_category
       ,p_information1              	=> p_information1
       ,p_information2                   => p_information2
       ,p_information3                   => p_information3
       ,p_information4                   => p_information4
       ,p_information5                   => p_information5
       ,p_information6                   => p_information6
       ,p_information7                   => p_information7
       ,p_information8                   => p_information8
       ,p_information9                   => p_information9
       ,p_information10                  => p_information10
       ,p_information11                  => p_information11
       ,p_information12                  => p_information12
       ,p_information13                  => p_information13
       ,p_information14                  => p_information14
       ,p_information15                  => p_information15
       ,p_information16                  => p_information16
       ,p_information17                  => p_information17
       ,p_information18                  => p_information18
       ,p_information19                  => p_information19
       ,p_information20                  => p_information20
       ,p_information21                  => p_information21
       ,p_information22                  => p_information22
       ,p_information23                  => p_information23
       ,p_information24                  => p_information24
       ,p_information25                  => p_information25
       ,p_information26                  => p_information26
       ,p_information27                  => p_information27
       ,p_information28                  => p_information28
       ,p_information29                  => p_information29
       ,p_information30                  => p_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_role'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_role
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
  p_role_id := l_role_id;
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
    ROLLBACK TO create_role;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_role_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
  p_role_id := null;
  p_object_version_number := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_role;
    raise;
    --
end create_role;
-- ----------------------------------------------------------------------------
-- |------------------------< update_role >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_role
  (p_validate                       in  boolean
  ,p_role_id                        in  number
  ,p_role_name                      in  varchar2
  ,p_role_type_cd                   in  varchar2
  ,p_enable_flag                    in  varchar2
  ,p_object_version_number          in out nocopy number
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ,p_information_category           in varchar2
  ,p_information1                   in varchar2
  ,p_information2                   in varchar2
  ,p_information3                   in varchar2
  ,p_information4                   in varchar2
  ,p_information5                   in varchar2
  ,p_information6                   in varchar2
  ,p_information7                   in varchar2
  ,p_information8                   in varchar2
  ,p_information9                   in varchar2
  ,p_information10                  in varchar2
  ,p_information11                  in varchar2
  ,p_information12                  in varchar2
  ,p_information13                  in varchar2
  ,p_information14                  in varchar2
  ,p_information15                  in varchar2
  ,p_information16                  in varchar2
  ,p_information17                  in varchar2
  ,p_information18                  in varchar2
  ,p_information19                  in varchar2
  ,p_information20                  in varchar2
  ,p_information21                  in varchar2
  ,p_information22                  in varchar2
  ,p_information23                  in varchar2
  ,p_information24                  in varchar2
  ,p_information25                  in varchar2
  ,p_information26                  in varchar2
  ,p_information27                  in varchar2
  ,p_information28                  in varchar2
  ,p_information29                  in varchar2
  ,p_information30                  in varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_role';
  l_object_version_number pqh_roles.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_role;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_role
    --
    pqh_roles_bk2.update_role_b
      (
       p_role_id                        =>  p_role_id
      ,p_role_name                      =>  p_role_name
      ,p_role_type_cd                   =>  p_role_type_cd
      ,p_enable_flag                    =>  p_enable_flag
      ,p_object_version_number          =>  p_object_version_number
      ,p_business_group_id              =>  p_business_group_id
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_information_category           => p_information_category
      ,p_information1              	=> p_information1
      ,p_information2                   => p_information2
      ,p_information3                   => p_information3
      ,p_information4                   => p_information4
      ,p_information5                   => p_information5
      ,p_information6                   => p_information6
      ,p_information7                   => p_information7
      ,p_information8                   => p_information8
      ,p_information9                   => p_information9
      ,p_information10                  => p_information10
      ,p_information11                  => p_information11
      ,p_information12                  => p_information12
      ,p_information13                  => p_information13
      ,p_information14                  => p_information14
      ,p_information15                  => p_information15
      ,p_information16                  => p_information16
      ,p_information17                  => p_information17
      ,p_information18                  => p_information18
      ,p_information19                  => p_information19
      ,p_information20                  => p_information20
      ,p_information21                  => p_information21
      ,p_information22                  => p_information22
      ,p_information23                  => p_information23
      ,p_information24                  => p_information24
      ,p_information25                  => p_information25
      ,p_information26                  => p_information26
      ,p_information27                  => p_information27
      ,p_information28                  => p_information28
      ,p_information29                  => p_information29
      ,p_information30                  => p_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_role'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_role
    --
  end;
  --
  pqh_rls_upd.upd
    (
     p_role_id                       => p_role_id
    ,p_role_name                     => p_role_name
    ,p_role_type_cd                  => p_role_type_cd
    ,p_enable_flag                   => p_enable_flag
    ,p_object_version_number         => l_object_version_number
    ,p_business_group_id             => p_business_group_id
    ,p_effective_date                => trunc(p_effective_date)
      ,p_information_category           => p_information_category
      ,p_information1              	=> p_information1
      ,p_information2                   => p_information2
      ,p_information3                   => p_information3
      ,p_information4                   => p_information4
      ,p_information5                   => p_information5
      ,p_information6                   => p_information6
      ,p_information7                   => p_information7
      ,p_information8                   => p_information8
      ,p_information9                   => p_information9
      ,p_information10                  => p_information10
      ,p_information11                  => p_information11
      ,p_information12                  => p_information12
      ,p_information13                  => p_information13
      ,p_information14                  => p_information14
      ,p_information15                  => p_information15
      ,p_information16                  => p_information16
      ,p_information17                  => p_information17
      ,p_information18                  => p_information18
      ,p_information19                  => p_information19
      ,p_information20                  => p_information20
      ,p_information21                  => p_information21
      ,p_information22                  => p_information22
      ,p_information23                  => p_information23
      ,p_information24                  => p_information24
      ,p_information25                  => p_information25
      ,p_information26                  => p_information26
      ,p_information27                  => p_information27
      ,p_information28                  => p_information28
      ,p_information29                  => p_information29
      ,p_information30                  => p_information30
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_role
    --
    pqh_roles_bk2.update_role_a
      (
       p_role_id                        =>  p_role_id
      ,p_role_name                      =>  p_role_name
      ,p_role_type_cd                   =>  p_role_type_cd
      ,p_enable_flag                    =>  p_enable_flag
      ,p_object_version_number          =>  l_object_version_number
      ,p_business_group_id              =>  p_business_group_id
      ,p_effective_date                => trunc(p_effective_date)
      ,p_information_category           => p_information_category
      ,p_information1              	=> p_information1
      ,p_information2                   => p_information2
      ,p_information3                   => p_information3
      ,p_information4                   => p_information4
      ,p_information5                   => p_information5
      ,p_information6                   => p_information6
      ,p_information7                   => p_information7
      ,p_information8                   => p_information8
      ,p_information9                   => p_information9
      ,p_information10                  => p_information10
      ,p_information11                  => p_information11
      ,p_information12                  => p_information12
      ,p_information13                  => p_information13
      ,p_information14                  => p_information14
      ,p_information15                  => p_information15
      ,p_information16                  => p_information16
      ,p_information17                  => p_information17
      ,p_information18                  => p_information18
      ,p_information19                  => p_information19
      ,p_information20                  => p_information20
      ,p_information21                  => p_information21
      ,p_information22                  => p_information22
      ,p_information23                  => p_information23
      ,p_information24                  => p_information24
      ,p_information25                  => p_information25
      ,p_information26                  => p_information26
      ,p_information27                  => p_information27
      ,p_information28                  => p_information28
      ,p_information29                  => p_information29
      ,p_information30                  => p_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_role'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_role
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
    ROLLBACK TO update_role;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
  p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_role;
    raise;
    --
end update_role;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_role >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_role
  (p_validate                       in  boolean
  ,p_role_id                        in  number
  ,p_object_version_number          in number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_role';
  l_object_version_number pqh_roles.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_role;
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
    -- Start of API User Hook for the before hook of delete_role
    --
    pqh_roles_bk3.delete_role_b
      (
       p_role_id                        =>  p_role_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_role'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_role
    --
  end;
  --
  pqh_rls_del.del
    (
     p_role_id                       => p_role_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_role
    --
    pqh_roles_bk3.delete_role_a
      (
       p_role_id                        =>  p_role_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_role'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_role
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
    ROLLBACK TO delete_role;
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
    ROLLBACK TO delete_role;
    raise;
    --
end delete_role;
--
--
end pqh_roles_api;

/
