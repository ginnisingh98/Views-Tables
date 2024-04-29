--------------------------------------------------------
--  DDL for Package Body PQH_PTX_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PTX_EXTRA_INFO_API" as
/* $Header: pqpteapi.pkb 115.4 2002/12/06 18:06:52 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_ptx_extra_info_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ptx_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ptx_extra_info
  (p_validate                       in  boolean   default false
  ,p_ptx_extra_info_id              out nocopy number
  ,p_information_type               in  varchar2  default null
  ,p_position_transaction_id        in  number    default null
  ,p_position_extra_info_id         in  number    default null
  ,p_information_category           in  varchar2  default null
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
  ,p_attribute_category             in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ptx_extra_info_id pqh_ptx_extra_info.ptx_extra_info_id%TYPE;
  l_proc varchar2(72) := g_package||'create_ptx_extra_info';
  l_object_version_number pqh_ptx_extra_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ptx_extra_info;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ptx_extra_info
    --
    pqh_ptx_extra_info_bk1.create_ptx_extra_info_b
      (
       p_information_type               =>  p_information_type
      ,p_position_transaction_id        =>  p_position_transaction_id
      ,p_position_extra_info_id         =>  p_position_extra_info_id
      ,p_information_category           =>  p_information_category
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
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PTX_EXTRA_INFO'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ptx_extra_info
    --
  end;
  --
  pqh_pte_ins.ins
    (
     p_ptx_extra_info_id             => l_ptx_extra_info_id
    ,p_information_type              => p_information_type
    ,p_position_transaction_id       => p_position_transaction_id
    ,p_position_extra_info_id        => p_position_extra_info_id
    ,p_information_category          => p_information_category
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
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ptx_extra_info
    --
    pqh_ptx_extra_info_bk1.create_ptx_extra_info_a
      (
       p_ptx_extra_info_id              =>  l_ptx_extra_info_id
      ,p_information_type               =>  p_information_type
      ,p_position_transaction_id        =>  p_position_transaction_id
      ,p_position_extra_info_id         =>  p_position_extra_info_id
      ,p_information_category           =>  p_information_category
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
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PTX_EXTRA_INFO'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ptx_extra_info
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
  p_ptx_extra_info_id := l_ptx_extra_info_id;
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
    ROLLBACK TO create_ptx_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ptx_extra_info_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_ptx_extra_info_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ptx_extra_info;
    raise;
    --
end create_ptx_extra_info;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ptx_extra_info >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ptx_extra_info
  (p_validate                       in  boolean   default false
  ,p_ptx_extra_info_id              in  number
  ,p_information_type               in  varchar2  default hr_api.g_varchar2
  ,p_position_transaction_id        in  number    default hr_api.g_number
  ,p_position_extra_info_id         in  number    default hr_api.g_number
  ,p_information_category           in  varchar2  default hr_api.g_varchar2
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
  ,p_attribute_category             in  varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ptx_extra_info';
  l_object_version_number pqh_ptx_extra_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ptx_extra_info;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ptx_extra_info
    --
    pqh_ptx_extra_info_bk2.update_ptx_extra_info_b
      (
       p_ptx_extra_info_id              =>  p_ptx_extra_info_id
      ,p_information_type               =>  p_information_type
      ,p_position_transaction_id        =>  p_position_transaction_id
      ,p_position_extra_info_id         =>  p_position_extra_info_id
      ,p_information_category           =>  p_information_category
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
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PTX_EXTRA_INFO'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ptx_extra_info
    --
  end;
  --
  pqh_pte_upd.upd
    (
     p_ptx_extra_info_id             => p_ptx_extra_info_id
    ,p_information_type              => p_information_type
    ,p_position_transaction_id       => p_position_transaction_id
    ,p_position_extra_info_id        => p_position_extra_info_id
    ,p_information_category          => p_information_category
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
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ptx_extra_info
    --
    pqh_ptx_extra_info_bk2.update_ptx_extra_info_a
      (
       p_ptx_extra_info_id              =>  p_ptx_extra_info_id
      ,p_information_type               =>  p_information_type
      ,p_position_transaction_id        =>  p_position_transaction_id
      ,p_position_extra_info_id         =>  p_position_extra_info_id
      ,p_information_category           =>  p_information_category
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
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PTX_EXTRA_INFO'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ptx_extra_info
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
    ROLLBACK TO update_ptx_extra_info;
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
    ROLLBACK TO update_ptx_extra_info;
    raise;
    --
end update_ptx_extra_info;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ptx_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ptx_extra_info
  (p_validate                       in  boolean  default false
  ,p_ptx_extra_info_id              in  number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ptx_extra_info';
  l_object_version_number pqh_ptx_extra_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ptx_extra_info;
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
    -- Start of API User Hook for the before hook of delete_ptx_extra_info
    --
    pqh_ptx_extra_info_bk3.delete_ptx_extra_info_b
      (
       p_ptx_extra_info_id              =>  p_ptx_extra_info_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PTX_EXTRA_INFO'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ptx_extra_info
    --
  end;
  --
  pqh_pte_del.del
    (
     p_ptx_extra_info_id             => p_ptx_extra_info_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ptx_extra_info
    --
    pqh_ptx_extra_info_bk3.delete_ptx_extra_info_a
      (
       p_ptx_extra_info_id              =>  p_ptx_extra_info_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PTX_EXTRA_INFO'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ptx_extra_info
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
    ROLLBACK TO delete_ptx_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_ptx_extra_info;
    raise;
    --
end delete_ptx_extra_info;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ptx_extra_info_id                   in     number
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
  pqh_pte_shd.lck
    (
      p_ptx_extra_info_id                 => p_ptx_extra_info_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_ptx_extra_info_api;

/
