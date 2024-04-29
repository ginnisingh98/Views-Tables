--------------------------------------------------------
--  DDL for Package Body PAY_ACTION_INFORMATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ACTION_INFORMATION_API" as
/* $Header: pyaifapi.pkb 115.8 2003/01/14 17:25:25 dsaxby noship $ */
--
-- Package Variables
--
g_debug boolean := hr_utility.debug_enabled;
g_package  varchar2(33) := '  pay_action_information_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_action_information >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_action_information
  (p_validate                       in     boolean   default false
  ,p_action_context_id              in     number
  ,p_action_context_type            in     varchar2
  ,p_action_information_category    in     varchar2
  ,p_tax_unit_id                    in     number    default null
  ,p_jurisdiction_code              in     varchar2  default null
  ,p_source_id                      in     number    default null
  ,p_source_text                    in     varchar2  default null
  ,p_tax_group                      in     varchar2  default null
  ,p_effective_date                 in     date      default null
  ,p_assignment_id                  in     number    default null
  ,p_action_information1            in     varchar2  default null
  ,p_action_information2            in     varchar2  default null
  ,p_action_information3            in     varchar2  default null
  ,p_action_information4            in     varchar2  default null
  ,p_action_information5            in     varchar2  default null
  ,p_action_information6            in     varchar2  default null
  ,p_action_information7            in     varchar2  default null
  ,p_action_information8            in     varchar2  default null
  ,p_action_information9            in     varchar2  default null
  ,p_action_information10           in     varchar2  default null
  ,p_action_information11           in     varchar2  default null
  ,p_action_information12           in     varchar2  default null
  ,p_action_information13           in     varchar2  default null
  ,p_action_information14           in     varchar2  default null
  ,p_action_information15           in     varchar2  default null
  ,p_action_information16           in     varchar2  default null
  ,p_action_information17           in     varchar2  default null
  ,p_action_information18           in     varchar2  default null
  ,p_action_information19           in     varchar2  default null
  ,p_action_information20           in     varchar2  default null
  ,p_action_information21           in     varchar2  default null
  ,p_action_information22           in     varchar2  default null
  ,p_action_information23           in     varchar2  default null
  ,p_action_information24           in     varchar2  default null
  ,p_action_information25           in     varchar2  default null
  ,p_action_information26           in     varchar2  default null
  ,p_action_information27           in     varchar2  default null
  ,p_action_information28           in     varchar2  default null
  ,p_action_information29           in     varchar2  default null
  ,p_action_information30           in     varchar2  default null
  ,p_action_information_id             out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_action_information_id pay_action_information.action_information_id%TYPE;
  l_proc                  varchar2(72);
  l_object_version_number pay_action_information.object_version_number%TYPE;
  l_effective_date        pay_action_information.effective_date%TYPE;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
     l_proc := g_package||'create_action_information';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_action_information;
  --
  -- Truncate time portion of date.
  --
  l_effective_date := trunc(p_effective_date);
  --
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_action_information
    --
    pay_action_information_bk1.create_action_information_b
      (
       p_action_context_id              =>  p_action_context_id
      ,p_action_context_type            =>  p_action_context_type
      ,p_tax_unit_id                    =>  p_tax_unit_id
      ,p_jurisdiction_code              =>  p_jurisdiction_code
      ,p_source_id                      =>  p_source_id
      ,p_source_text                    =>  p_source_text
      ,p_tax_group                      =>  p_tax_group
      ,p_effective_date                 =>  l_effective_date
      ,p_assignment_id                  =>  p_assignment_id
      ,p_action_information_category    =>  p_action_information_category
      ,p_action_information1            =>  p_action_information1
      ,p_action_information2            =>  p_action_information2
      ,p_action_information3            =>  p_action_information3
      ,p_action_information4            =>  p_action_information4
      ,p_action_information5            =>  p_action_information5
      ,p_action_information6            =>  p_action_information6
      ,p_action_information7            =>  p_action_information7
      ,p_action_information8            =>  p_action_information8
      ,p_action_information9            =>  p_action_information9
      ,p_action_information10           =>  p_action_information10
      ,p_action_information11           =>  p_action_information11
      ,p_action_information12           =>  p_action_information12
      ,p_action_information13           =>  p_action_information13
      ,p_action_information14           =>  p_action_information14
      ,p_action_information15           =>  p_action_information15
      ,p_action_information16           =>  p_action_information16
      ,p_action_information17           =>  p_action_information17
      ,p_action_information18           =>  p_action_information18
      ,p_action_information19           =>  p_action_information19
      ,p_action_information20           =>  p_action_information20
      ,p_action_information21           =>  p_action_information21
      ,p_action_information22           =>  p_action_information22
      ,p_action_information23           =>  p_action_information23
      ,p_action_information24           =>  p_action_information24
      ,p_action_information25           =>  p_action_information25
      ,p_action_information26           =>  p_action_information26
      ,p_action_information27           =>  p_action_information27
      ,p_action_information28           =>  p_action_information28
      ,p_action_information29           =>  p_action_information29
      ,p_action_information30           =>  p_action_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_action_information'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_action_information
    --
  end;
  --
  pay_aif_ins.ins
    (
     p_action_information_id         => l_action_information_id
    ,p_action_context_id             => p_action_context_id
    ,p_action_context_type           => p_action_context_type
    ,p_tax_unit_id                   => p_tax_unit_id
    ,p_jurisdiction_code             => p_jurisdiction_code
    ,p_source_id                     => p_source_id
    ,p_source_text                   => p_source_text
    ,p_tax_group                     => p_tax_group
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => l_effective_date
    ,p_assignment_id                 =>  p_assignment_id
    ,p_action_information_category   => p_action_information_category
    ,p_action_information1           => p_action_information1
    ,p_action_information2           => p_action_information2
    ,p_action_information3           => p_action_information3
    ,p_action_information4           => p_action_information4
    ,p_action_information5           => p_action_information5
    ,p_action_information6           => p_action_information6
    ,p_action_information7           => p_action_information7
    ,p_action_information8           => p_action_information8
    ,p_action_information9           => p_action_information9
    ,p_action_information10          => p_action_information10
    ,p_action_information11          => p_action_information11
    ,p_action_information12          => p_action_information12
    ,p_action_information13          => p_action_information13
    ,p_action_information14          => p_action_information14
    ,p_action_information15          => p_action_information15
    ,p_action_information16          => p_action_information16
    ,p_action_information17          => p_action_information17
    ,p_action_information18          => p_action_information18
    ,p_action_information19          => p_action_information19
    ,p_action_information20          => p_action_information20
    ,p_action_information21          => p_action_information21
    ,p_action_information22          => p_action_information22
    ,p_action_information23          => p_action_information23
    ,p_action_information24          => p_action_information24
    ,p_action_information25          => p_action_information25
    ,p_action_information26          => p_action_information26
    ,p_action_information27          => p_action_information27
    ,p_action_information28          => p_action_information28
    ,p_action_information29          => p_action_information29
    ,p_action_information30          => p_action_information30
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_action_information
    --
    pay_action_information_bk1.create_action_information_a
      (
       p_action_information_id          =>  l_action_information_id
      ,p_action_context_id              =>  p_action_context_id
      ,p_action_context_type            =>  p_action_context_type
      ,p_tax_unit_id                    =>  p_tax_unit_id
      ,p_jurisdiction_code              =>  p_jurisdiction_code
      ,p_source_id                      =>  p_source_id
      ,p_source_text                    =>  p_source_text
      ,p_tax_group                      =>  p_tax_group
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  l_effective_date
      ,p_assignment_id                  =>  p_assignment_id
      ,p_action_information_category    =>  p_action_information_category
      ,p_action_information1            =>  p_action_information1
      ,p_action_information2            =>  p_action_information2
      ,p_action_information3            =>  p_action_information3
      ,p_action_information4            =>  p_action_information4
      ,p_action_information5            =>  p_action_information5
      ,p_action_information6            =>  p_action_information6
      ,p_action_information7            =>  p_action_information7
      ,p_action_information8            =>  p_action_information8
      ,p_action_information9            =>  p_action_information9
      ,p_action_information10           =>  p_action_information10
      ,p_action_information11           =>  p_action_information11
      ,p_action_information12           =>  p_action_information12
      ,p_action_information13           =>  p_action_information13
      ,p_action_information14           =>  p_action_information14
      ,p_action_information15           =>  p_action_information15
      ,p_action_information16           =>  p_action_information16
      ,p_action_information17           =>  p_action_information17
      ,p_action_information18           =>  p_action_information18
      ,p_action_information19           =>  p_action_information19
      ,p_action_information20           =>  p_action_information20
      ,p_action_information21           =>  p_action_information21
      ,p_action_information22           =>  p_action_information22
      ,p_action_information23           =>  p_action_information23
      ,p_action_information24           =>  p_action_information24
      ,p_action_information25           =>  p_action_information25
      ,p_action_information26           =>  p_action_information26
      ,p_action_information27           =>  p_action_information27
      ,p_action_information28           =>  p_action_information28
      ,p_action_information29           =>  p_action_information29
      ,p_action_information30           =>  p_action_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_action_information'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_action_information
    --
  end;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_action_information_id := l_action_information_id;
  p_object_version_number := l_object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_action_information;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_action_information_id := null;
    p_object_version_number  := null;
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_action_information;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_action_information_id := null;
    p_object_version_number := null;
    raise;
    --
end create_action_information;
-- ----------------------------------------------------------------------------
-- |------------------------< update_action_information >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_action_information
  (p_validate                       in     boolean   default false
  ,p_action_information_id          in     number
  ,p_object_version_number          in out nocopy number
  ,p_action_information1            in     varchar2  default hr_api.g_varchar2
  ,p_action_information2            in     varchar2  default hr_api.g_varchar2
  ,p_action_information3            in     varchar2  default hr_api.g_varchar2
  ,p_action_information4            in     varchar2  default hr_api.g_varchar2
  ,p_action_information5            in     varchar2  default hr_api.g_varchar2
  ,p_action_information6            in     varchar2  default hr_api.g_varchar2
  ,p_action_information7            in     varchar2  default hr_api.g_varchar2
  ,p_action_information8            in     varchar2  default hr_api.g_varchar2
  ,p_action_information9            in     varchar2  default hr_api.g_varchar2
  ,p_action_information10           in     varchar2  default hr_api.g_varchar2
  ,p_action_information11           in     varchar2  default hr_api.g_varchar2
  ,p_action_information12           in     varchar2  default hr_api.g_varchar2
  ,p_action_information13           in     varchar2  default hr_api.g_varchar2
  ,p_action_information14           in     varchar2  default hr_api.g_varchar2
  ,p_action_information15           in     varchar2  default hr_api.g_varchar2
  ,p_action_information16           in     varchar2  default hr_api.g_varchar2
  ,p_action_information17           in     varchar2  default hr_api.g_varchar2
  ,p_action_information18           in     varchar2  default hr_api.g_varchar2
  ,p_action_information19           in     varchar2  default hr_api.g_varchar2
  ,p_action_information20           in     varchar2  default hr_api.g_varchar2
  ,p_action_information21           in     varchar2  default hr_api.g_varchar2
  ,p_action_information22           in     varchar2  default hr_api.g_varchar2
  ,p_action_information23           in     varchar2  default hr_api.g_varchar2
  ,p_action_information24           in     varchar2  default hr_api.g_varchar2
  ,p_action_information25           in     varchar2  default hr_api.g_varchar2
  ,p_action_information26           in     varchar2  default hr_api.g_varchar2
  ,p_action_information27           in     varchar2  default hr_api.g_varchar2
  ,p_action_information28           in     varchar2  default hr_api.g_varchar2
  ,p_action_information29           in     varchar2  default hr_api.g_varchar2
  ,p_action_information30           in     varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72);
  l_object_version_number pay_action_information.object_version_number%TYPE;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
     l_proc := g_package||'update_action_information';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_action_information;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_action_information
    --
    pay_action_information_bk2.update_action_information_b
      (
       p_action_information_id          =>  p_action_information_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_action_information1            =>  p_action_information1
      ,p_action_information2            =>  p_action_information2
      ,p_action_information3            =>  p_action_information3
      ,p_action_information4            =>  p_action_information4
      ,p_action_information5            =>  p_action_information5
      ,p_action_information6            =>  p_action_information6
      ,p_action_information7            =>  p_action_information7
      ,p_action_information8            =>  p_action_information8
      ,p_action_information9            =>  p_action_information9
      ,p_action_information10           =>  p_action_information10
      ,p_action_information11           =>  p_action_information11
      ,p_action_information12           =>  p_action_information12
      ,p_action_information13           =>  p_action_information13
      ,p_action_information14           =>  p_action_information14
      ,p_action_information15           =>  p_action_information15
      ,p_action_information16           =>  p_action_information16
      ,p_action_information17           =>  p_action_information17
      ,p_action_information18           =>  p_action_information18
      ,p_action_information19           =>  p_action_information19
      ,p_action_information20           =>  p_action_information20
      ,p_action_information21           =>  p_action_information21
      ,p_action_information22           =>  p_action_information22
      ,p_action_information23           =>  p_action_information23
      ,p_action_information24           =>  p_action_information24
      ,p_action_information25           =>  p_action_information25
      ,p_action_information26           =>  p_action_information26
      ,p_action_information27           =>  p_action_information27
      ,p_action_information28           =>  p_action_information28
      ,p_action_information29           =>  p_action_information29
      ,p_action_information30           =>  p_action_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_action_information'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_action_information
    --
  end;
  --
  pay_aif_upd.upd
    (
     p_action_information_id         => p_action_information_id
    ,p_object_version_number         => l_object_version_number
    ,p_action_information1           => p_action_information1
    ,p_action_information2           => p_action_information2
    ,p_action_information3           => p_action_information3
    ,p_action_information4           => p_action_information4
    ,p_action_information5           => p_action_information5
    ,p_action_information6           => p_action_information6
    ,p_action_information7           => p_action_information7
    ,p_action_information8           => p_action_information8
    ,p_action_information9           => p_action_information9
    ,p_action_information10          => p_action_information10
    ,p_action_information11          => p_action_information11
    ,p_action_information12          => p_action_information12
    ,p_action_information13          => p_action_information13
    ,p_action_information14          => p_action_information14
    ,p_action_information15          => p_action_information15
    ,p_action_information16          => p_action_information16
    ,p_action_information17          => p_action_information17
    ,p_action_information18          => p_action_information18
    ,p_action_information19          => p_action_information19
    ,p_action_information20          => p_action_information20
    ,p_action_information21          => p_action_information21
    ,p_action_information22          => p_action_information22
    ,p_action_information23          => p_action_information23
    ,p_action_information24          => p_action_information24
    ,p_action_information25          => p_action_information25
    ,p_action_information26          => p_action_information26
    ,p_action_information27          => p_action_information27
    ,p_action_information28          => p_action_information28
    ,p_action_information29          => p_action_information29
    ,p_action_information30          => p_action_information30
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_action_information
    --
    pay_action_information_bk2.update_action_information_a
      (
       p_action_information_id          =>  p_action_information_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_action_information1            =>  p_action_information1
      ,p_action_information2            =>  p_action_information2
      ,p_action_information3            =>  p_action_information3
      ,p_action_information4            =>  p_action_information4
      ,p_action_information5            =>  p_action_information5
      ,p_action_information6            =>  p_action_information6
      ,p_action_information7            =>  p_action_information7
      ,p_action_information8            =>  p_action_information8
      ,p_action_information9            =>  p_action_information9
      ,p_action_information10           =>  p_action_information10
      ,p_action_information11           =>  p_action_information11
      ,p_action_information12           =>  p_action_information12
      ,p_action_information13           =>  p_action_information13
      ,p_action_information14           =>  p_action_information14
      ,p_action_information15           =>  p_action_information15
      ,p_action_information16           =>  p_action_information16
      ,p_action_information17           =>  p_action_information17
      ,p_action_information18           =>  p_action_information18
      ,p_action_information19           =>  p_action_information19
      ,p_action_information20           =>  p_action_information20
      ,p_action_information21           =>  p_action_information21
      ,p_action_information22           =>  p_action_information22
      ,p_action_information23           =>  p_action_information23
      ,p_action_information24           =>  p_action_information24
      ,p_action_information25           =>  p_action_information25
      ,p_action_information26           =>  p_action_information26
      ,p_action_information27           =>  p_action_information27
      ,p_action_information28           =>  p_action_information28
      ,p_action_information29           =>  p_action_information29
      ,p_action_information30           =>  p_action_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_action_information'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_action_information
    --
  end;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
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
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_action_information;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_action_information;
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_action_information;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_action_information >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_action_information
  (p_validate                       in     boolean  default false
  ,p_action_information_id          in     number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  l_object_version_number pay_action_information.object_version_number%TYPE;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
     l_proc := g_package||'update_action_information';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_action_information;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_action_information
    --
    pay_action_information_bk3.delete_action_information_b
      (
       p_action_information_id          =>  p_action_information_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_action_information'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_action_information
    --
  end;
  --
  pay_aif_del.del
    (
     p_action_information_id         => p_action_information_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_action_information
    --
    pay_action_information_bk3.delete_action_information_a
      (
       p_action_information_id          =>  p_action_information_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_action_information'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_action_information
    --
  end;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_action_information;
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
    ROLLBACK TO delete_action_information;
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_action_information;
--
end pay_action_information_api;

/
