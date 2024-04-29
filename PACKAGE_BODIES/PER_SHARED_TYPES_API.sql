--------------------------------------------------------
--  DDL for Package Body PER_SHARED_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SHARED_TYPES_API" as
/* $Header: peshtapi.pkb 115.10 2002/12/11 17:07:42 eumenyio ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_shared_types_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_shared_type >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- used for creating a shared_type corresponding to
-- Prerequisites:
--
-- Lookup_type should exist and should have a lookup value
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_validate                         N   in
--  p_shared_type_id                   Y   out
--  p_business_group_id                N   in
--  p_shared_type_name                 N   in
--  p_shared_type_code                 N   in
--  p_system_type_cd                   N   in
--  p_language_code                    N   in
--  p_information1                     N   in
--  p_information2                     N   in
--  p_information3                     N   in
--  p_information4                     N   in
--  p_information5                     N   in
--  p_information6                     N   in
--  p_information7                     N   in
--  p_information8                     N   in
--  p_information9                     N   in
--  p_information10                    N   in
--  p_information11                    N   in
--  p_information12                    N   in
--  p_information13                    N   in
--  p_information14                    N   in
--  p_information15                    N   in
--  p_information16                    N   in
--  p_information17                    N   in
--  p_information18                    N   in
--  p_information19                    N   in
--  p_information20                    N   in
--  p_information21                    N   in
--  p_information22                    N   in
--  p_information23                    N   in
--  p_information24                    N   in
--  p_information25                    N   in
--  p_information26                    N   in
--  p_information27                    N   in
--  p_information28                    N   in
--  p_information29                    N   in
--  p_information30                    N   in
--  p_information_category             N   in
--  p_object_version_number            Y   out
--  p_lookup_type                      N   in
--  p_effective_date                   Y   in
--
-- Post Success:
--
-- Shared Type is created corresponding to a lookup_type
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_shared_type
  (p_validate                       in  boolean   default false
  ,p_shared_type_id                 out nocopy number
  ,p_business_group_id              in  number    default null
  ,p_shared_type_name               in  varchar2  default null
  ,p_shared_type_code               in  varchar2  default null
  ,p_system_type_cd                 in  varchar2  default null
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ,p_information1                   in  varchar2  default null
  ,p_information2                   in  varchar2  default null
  ,p_information3                   in  varchar2  default null
  ,p_information4                   in  varchar2  default null
  ,p_information5                   in  varchar2  default null
  ,p_information6                   in  varchar2  default null
  ,p_information7                   in  varchar2  default null
  ,p_information8                   in  varchar2  default null
  ,p_information9                   in  varchar2  default null
  ,p_information10                  in  varchar2  default null
  ,p_information11                  in  varchar2  default null
  ,p_information12                  in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_information_category           in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_lookup_type                    in  varchar2  default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_shared_type_id per_shared_types.shared_type_id%TYPE;
  l_proc varchar2(72) := g_package||'create_shared_type';
  l_object_version_number per_shared_types.object_version_number%TYPE;
  l_language_code varchar2(30);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_shared_type;
  --
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_shared_types
    --
    per_shared_types_bk1.create_shared_type_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_shared_type_name               =>  p_shared_type_name
      ,p_shared_type_code               =>  p_shared_type_code
      ,p_system_type_cd                 =>  p_system_type_cd
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information_category           =>  p_information_category
      ,p_lookup_type                    =>  p_lookup_type
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_shared_types'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_shared_types
    --
  end;
  --
  per_sht_ins.ins
    (
     p_shared_type_id                => l_shared_type_id
    ,p_business_group_id             => p_business_group_id
    ,p_shared_type_name              => p_shared_type_name
    ,p_shared_type_code              => p_shared_type_code
    ,p_system_type_cd                => p_system_type_cd
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_information_category          => p_information_category
    ,p_object_version_number         => l_object_version_number
    ,p_lookup_type                   => p_lookup_type
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
     p_shared_type_id  := l_shared_type_id ;
     per_stt_ins.ins_tl(
       p_language_code    => p_language_code,
       p_shared_type_id   => l_shared_type_id ,
       p_shared_type_name => p_shared_type_name );
  begin
    --
    -- Start of API User Hook for the after hook of create_shared_types
    --
    per_shared_types_bk1.create_shared_type_a
      (
       p_shared_type_id                 =>  l_shared_type_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_shared_type_name               =>  p_shared_type_name
      ,p_shared_type_code               =>  p_shared_type_code
      ,p_system_type_cd                 =>  p_system_type_cd
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information_category           =>  p_information_category
      ,p_object_version_number          =>  l_object_version_number
      ,p_lookup_type                    =>  p_lookup_type
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_shared_types'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_shared_types
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
  p_shared_type_id := l_shared_type_id;
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
    ROLLBACK TO create_shared_type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_shared_type_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_shared_type_id := null;
    p_object_version_number  := null;
    ROLLBACK TO create_shared_type;
    raise;
    --
end create_shared_type;
-- ----------------------------------------------------------------------------
-- |------------------------< update_shared_type >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_shared_type
  (p_validate                       in  boolean   default false
  ,p_shared_type_id                 in  number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_shared_type_name               in  varchar2  default hr_api.g_varchar2
  ,p_shared_type_code               in  varchar2  default hr_api.g_varchar2
  ,p_system_type_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ,p_information1                   in  varchar2  default hr_api.g_varchar2
  ,p_information2                   in  varchar2  default hr_api.g_varchar2
  ,p_information3                   in  varchar2  default hr_api.g_varchar2
  ,p_information4                   in  varchar2  default hr_api.g_varchar2
  ,p_information5                   in  varchar2  default hr_api.g_varchar2
  ,p_information6                   in  varchar2  default hr_api.g_varchar2
  ,p_information7                   in  varchar2  default hr_api.g_varchar2
  ,p_information8                   in  varchar2  default hr_api.g_varchar2
  ,p_information9                   in  varchar2  default hr_api.g_varchar2
  ,p_information10                  in  varchar2  default hr_api.g_varchar2
  ,p_information11                  in  varchar2  default hr_api.g_varchar2
  ,p_information12                  in  varchar2  default hr_api.g_varchar2
  ,p_information13                  in  varchar2  default hr_api.g_varchar2
  ,p_information14                  in  varchar2  default hr_api.g_varchar2
  ,p_information15                  in  varchar2  default hr_api.g_varchar2
  ,p_information16                  in  varchar2  default hr_api.g_varchar2
  ,p_information17                  in  varchar2  default hr_api.g_varchar2
  ,p_information18                  in  varchar2  default hr_api.g_varchar2
  ,p_information19                  in  varchar2  default hr_api.g_varchar2
  ,p_information20                  in  varchar2  default hr_api.g_varchar2
  ,p_information21                  in  varchar2  default hr_api.g_varchar2
  ,p_information22                  in  varchar2  default hr_api.g_varchar2
  ,p_information23                  in  varchar2  default hr_api.g_varchar2
  ,p_information24                  in  varchar2  default hr_api.g_varchar2
  ,p_information25                  in  varchar2  default hr_api.g_varchar2
  ,p_information26                  in  varchar2  default hr_api.g_varchar2
  ,p_information27                  in  varchar2  default hr_api.g_varchar2
  ,p_information28                  in  varchar2  default hr_api.g_varchar2
  ,p_information29                  in  varchar2  default hr_api.g_varchar2
  ,p_information30                  in  varchar2  default hr_api.g_varchar2
  ,p_information_category           in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_lookup_type                    in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_shared_type';
  l_object_version_number per_shared_types.object_version_number%TYPE;
  l_language_code varchar2(30);
  l_temp_ovn number  := p_object_version_number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_shared_type;
  --
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_shared_types
    --
    per_shared_types_bk2.update_shared_type_b
      (
       p_shared_type_id                 =>  p_shared_type_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_shared_type_name               =>  p_shared_type_name
      ,p_shared_type_code               =>  p_shared_type_code
      ,p_system_type_cd                 =>  p_system_type_cd
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information_category           =>  p_information_category
      ,p_object_version_number          =>  p_object_version_number
      ,p_lookup_type                    =>  p_lookup_type
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_shared_types'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_shared_types
    --
  end;
  --
  per_sht_upd.upd
    (
     p_shared_type_id                => p_shared_type_id
    ,p_business_group_id             => p_business_group_id
    ,p_shared_type_name              => p_shared_type_name
    ,p_shared_type_code              => p_shared_type_code
    ,p_system_type_cd                => p_system_type_cd
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_information_category          => p_information_category
    ,p_object_version_number         => l_object_version_number
    ,p_lookup_type                   => p_lookup_type
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
     per_stt_upd.upd_tl(
       p_language_code    => p_language_code,
       p_shared_type_id   => p_shared_type_id ,
       p_shared_type_name => p_shared_type_name );
  begin
    --
    -- Start of API User Hook for the after hook of update_shared_types
    --
    per_shared_types_bk2.update_shared_type_a
      (
       p_shared_type_id                 =>  p_shared_type_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_shared_type_name               =>  p_shared_type_name
      ,p_shared_type_code               =>  p_shared_type_code
      ,p_system_type_cd                 =>  p_system_type_cd
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information_category           =>  p_information_category
      ,p_object_version_number          =>  l_object_version_number
      ,p_lookup_type                    =>  p_lookup_type
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_shared_types'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_shared_types
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
    ROLLBACK TO update_shared_type;
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
    p_object_version_number  := l_temp_ovn;
    ROLLBACK TO update_shared_type;
    raise;
    --
end update_shared_type;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_shared_type >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_shared_type
  (p_validate                       in  boolean  default false
  ,p_shared_type_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_shared_type';
  l_object_version_number per_shared_types.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_shared_type;
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
    -- Start of API User Hook for the before hook of delete_shared_types
    --
    per_shared_types_bk3.delete_shared_type_b
      (
       p_shared_type_id                 =>  p_shared_type_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_shared_types'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_shared_types
    --
  end;
  --
  per_sht_shd.lck
    (
     p_shared_type_id => p_shared_type_id
     ,p_object_version_number => l_object_version_number
    );
  --
  per_stt_del.del_tl
    (
     p_shared_type_id   => p_shared_type_id
    );
  --
  per_sht_del.del
    (
     p_shared_type_id                => p_shared_type_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  begin
    --
    -- Start of API User Hook for the after hook of delete_shared_types
    --
    per_shared_types_bk3.delete_shared_type_a
      (
       p_shared_type_id                 =>  p_shared_type_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_shared_types'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_shared_types
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
    ROLLBACK TO delete_shared_type;
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
    ROLLBACK TO delete_shared_type;
    raise;
    --
end delete_shared_type;
--
end per_shared_types_api;

/
