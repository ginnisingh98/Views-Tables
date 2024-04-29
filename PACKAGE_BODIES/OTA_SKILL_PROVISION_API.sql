--------------------------------------------------------
--  DDL for Package Body OTA_SKILL_PROVISION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_SKILL_PROVISION_API" as
/* $Header: ottspapi.pkb 115.1 2003/12/30 17:50:21 asud noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_SKILL_PROVISION_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_SKILL_PROVISION >------------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_skill_provision
  (
  p_skill_provision_id           out nocopy number,
  p_activity_version_id          in number,
  p_object_version_number        out nocopy number,
  p_type                         in varchar2,
  p_comments                     in varchar2         default null,
  p_tsp_information_category     in varchar2         default null,
  p_tsp_information1             in varchar2         default null,
  p_tsp_information2             in varchar2         default null,
  p_tsp_information3             in varchar2         default null,
  p_tsp_information4             in varchar2         default null,
  p_tsp_information5             in varchar2         default null,
  p_tsp_information6             in varchar2         default null,
  p_tsp_information7             in varchar2         default null,
  p_tsp_information8             in varchar2         default null,
  p_tsp_information9             in varchar2         default null,
  p_tsp_information10            in varchar2         default null,
  p_tsp_information11            in varchar2         default null,
  p_tsp_information12            in varchar2         default null,
  p_tsp_information13            in varchar2         default null,
  p_tsp_information14            in varchar2         default null,
  p_tsp_information15            in varchar2         default null,
  p_tsp_information16            in varchar2         default null,
  p_tsp_information17            in varchar2         default null,
  p_tsp_information18            in varchar2         default null,
  p_tsp_information19            in varchar2         default null,
  p_tsp_information20            in varchar2         default null,
  p_analysis_criteria_id         in number,
  p_validate                     in boolean   default false
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Skill Provision';
  l_skill_provision_id number;
  l_object_version_number   number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_SKILL_PROVISION;

  --

   begin
    ota_skill_provision_bk1.create_skill_provision_b
  (  p_activity_version_id        => p_activity_version_id      ,
  p_object_version_number      => l_object_version_number    ,
  p_type                       => p_type                     ,
  p_comments                   => p_comments                 ,
  p_tsp_information_category   => p_tsp_information_category ,
  p_tsp_information1           => p_tsp_information1         ,
  p_tsp_information2           => p_tsp_information2         ,
  p_tsp_information3           => p_tsp_information3         ,
  p_tsp_information4           => p_tsp_information4         ,
  p_tsp_information5           => p_tsp_information5         ,
  p_tsp_information6           => p_tsp_information6         ,
  p_tsp_information7           => p_tsp_information7         ,
  p_tsp_information8           => p_tsp_information8         ,
  p_tsp_information9           => p_tsp_information9         ,
  p_tsp_information10          => p_tsp_information10        ,
  p_tsp_information11          => p_tsp_information11        ,
  p_tsp_information12          => p_tsp_information12        ,
  p_tsp_information13          => p_tsp_information13        ,
  p_tsp_information14          => p_tsp_information14        ,
  p_tsp_information15          => p_tsp_information15        ,
  p_tsp_information16          => p_tsp_information16        ,
  p_tsp_information17          => p_tsp_information17        ,
  p_tsp_information18          => p_tsp_information18        ,
  p_tsp_information19          => p_tsp_information19        ,
  p_tsp_information20          => p_tsp_information20        ,
  p_analysis_criteria_id       => p_analysis_criteria_id     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SKILL_PROVISION'
        ,p_hook_type   => 'BP'
        );
  end;
  -- Process Logic
  --
  ota_tsp_ins.ins
  (
  p_skill_provision_id         => l_skill_provision_id       ,
  p_activity_version_id        => p_activity_version_id      ,
  p_object_version_number      => l_object_version_number    ,
  p_type                       => p_type                     ,
  p_comments                   => p_comments                 ,
  p_tsp_information_category   => p_tsp_information_category ,
  p_tsp_information1           => p_tsp_information1         ,
  p_tsp_information2           => p_tsp_information2         ,
  p_tsp_information3           => p_tsp_information3         ,
  p_tsp_information4           => p_tsp_information4         ,
  p_tsp_information5           => p_tsp_information5         ,
  p_tsp_information6           => p_tsp_information6         ,
  p_tsp_information7           => p_tsp_information7         ,
  p_tsp_information8           => p_tsp_information8         ,
  p_tsp_information9           => p_tsp_information9         ,
  p_tsp_information10          => p_tsp_information10        ,
  p_tsp_information11          => p_tsp_information11        ,
  p_tsp_information12          => p_tsp_information12        ,
  p_tsp_information13          => p_tsp_information13        ,
  p_tsp_information14          => p_tsp_information14        ,
  p_tsp_information15          => p_tsp_information15        ,
  p_tsp_information16          => p_tsp_information16        ,
  p_tsp_information17          => p_tsp_information17        ,
  p_tsp_information18          => p_tsp_information18        ,
  p_tsp_information19          => p_tsp_information19        ,
  p_tsp_information20          => p_tsp_information20        ,
  p_analysis_criteria_id       => p_analysis_criteria_id     ,
  p_validate                   => p_validate
  );

 begin
    ota_skill_provision_bk1.create_skill_provision_a
  (p_skill_provision_id         => l_skill_provision_id       ,
   p_activity_version_id        => p_activity_version_id      ,
  p_object_version_number      => l_object_version_number    ,
  p_type                       => p_type                     ,
  p_comments                   => p_comments                 ,
  p_tsp_information_category   => p_tsp_information_category ,
  p_tsp_information1           => p_tsp_information1         ,
  p_tsp_information2           => p_tsp_information2         ,
  p_tsp_information3           => p_tsp_information3         ,
  p_tsp_information4           => p_tsp_information4         ,
  p_tsp_information5           => p_tsp_information5         ,
  p_tsp_information6           => p_tsp_information6         ,
  p_tsp_information7           => p_tsp_information7         ,
  p_tsp_information8           => p_tsp_information8         ,
  p_tsp_information9           => p_tsp_information9         ,
  p_tsp_information10          => p_tsp_information10        ,
  p_tsp_information11          => p_tsp_information11        ,
  p_tsp_information12          => p_tsp_information12        ,
  p_tsp_information13          => p_tsp_information13        ,
  p_tsp_information14          => p_tsp_information14        ,
  p_tsp_information15          => p_tsp_information15        ,
  p_tsp_information16          => p_tsp_information16        ,
  p_tsp_information17          => p_tsp_information17        ,
  p_tsp_information18          => p_tsp_information18        ,
  p_tsp_information19          => p_tsp_information19        ,
  p_tsp_information20          => p_tsp_information20        ,
  p_analysis_criteria_id       => p_analysis_criteria_id     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SKILL_PROVISION'
        ,p_hook_type   => 'AP'
        );
  end;



  --


  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_skill_provision_id        := l_skill_provision_id;
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_SKILL_PROVISION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_skill_provision_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_SKILL_PROVISION;
    p_skill_provision_id     := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_skill_provision;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_SKILL_PROVISION >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_skill_provision
  (
  p_skill_provision_id           in number,
  p_activity_version_id          in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_type                         in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_tsp_information_category     in varchar2         default hr_api.g_varchar2,
  p_tsp_information1             in varchar2         default hr_api.g_varchar2,
  p_tsp_information2             in varchar2         default hr_api.g_varchar2,
  p_tsp_information3             in varchar2         default hr_api.g_varchar2,
  p_tsp_information4             in varchar2         default hr_api.g_varchar2,
  p_tsp_information5             in varchar2         default hr_api.g_varchar2,
  p_tsp_information6             in varchar2         default hr_api.g_varchar2,
  p_tsp_information7             in varchar2         default hr_api.g_varchar2,
  p_tsp_information8             in varchar2         default hr_api.g_varchar2,
  p_tsp_information9             in varchar2         default hr_api.g_varchar2,
  p_tsp_information10            in varchar2         default hr_api.g_varchar2,
  p_tsp_information11            in varchar2         default hr_api.g_varchar2,
  p_tsp_information12            in varchar2         default hr_api.g_varchar2,
  p_tsp_information13            in varchar2         default hr_api.g_varchar2,
  p_tsp_information14            in varchar2         default hr_api.g_varchar2,
  p_tsp_information15            in varchar2         default hr_api.g_varchar2,
  p_tsp_information16            in varchar2         default hr_api.g_varchar2,
  p_tsp_information17            in varchar2         default hr_api.g_varchar2,
  p_tsp_information18            in varchar2         default hr_api.g_varchar2,
  p_tsp_information19            in varchar2         default hr_api.g_varchar2,
  p_tsp_information20            in varchar2         default hr_api.g_varchar2,
  p_analysis_criteria_id         in number           default hr_api.g_number,
  p_validate                     in boolean      default false
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Skill Provision';
  l_object_version_number   number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_SKILL_PROVISION;
  --
  --
  begin
    ota_skill_provision_bk2.update_skill_provision_a
  (p_skill_provision_id         => p_skill_provision_id       ,
   p_activity_version_id        => p_activity_version_id      ,
  p_object_version_number      => p_object_version_number    ,
  p_type                       => p_type                     ,
  p_comments                   => p_comments                 ,
  p_tsp_information_category   => p_tsp_information_category ,
  p_tsp_information1           => p_tsp_information1         ,
  p_tsp_information2           => p_tsp_information2         ,
  p_tsp_information3           => p_tsp_information3         ,
  p_tsp_information4           => p_tsp_information4         ,
  p_tsp_information5           => p_tsp_information5         ,
  p_tsp_information6           => p_tsp_information6         ,
  p_tsp_information7           => p_tsp_information7         ,
  p_tsp_information8           => p_tsp_information8         ,
  p_tsp_information9           => p_tsp_information9         ,
  p_tsp_information10          => p_tsp_information10        ,
  p_tsp_information11          => p_tsp_information11        ,
  p_tsp_information12          => p_tsp_information12        ,
  p_tsp_information13          => p_tsp_information13        ,
  p_tsp_information14          => p_tsp_information14        ,
  p_tsp_information15          => p_tsp_information15        ,
  p_tsp_information16          => p_tsp_information16        ,
  p_tsp_information17          => p_tsp_information17        ,
  p_tsp_information18          => p_tsp_information18        ,
  p_tsp_information19          => p_tsp_information19        ,
  p_tsp_information20          => p_tsp_information20        ,
  p_analysis_criteria_id       => p_analysis_criteria_id     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SKILL_PROVISION'
        ,p_hook_type   => 'BP'
        );
  end;



  -- Process Logic
  --
  ota_tsp_upd.upd
  (
  p_skill_provision_id           => p_skill_provision_id       ,
  p_activity_version_id          => p_activity_version_id      ,
  p_object_version_number        => l_object_version_number    ,
  p_type                         => p_type                     ,
  p_comments                     => p_comments                 ,
  p_tsp_information_category     => p_tsp_information_category ,
  p_tsp_information1             => p_tsp_information1         ,
  p_tsp_information2             => p_tsp_information2         ,
  p_tsp_information3             => p_tsp_information3         ,
  p_tsp_information4             => p_tsp_information4         ,
  p_tsp_information5             => p_tsp_information5         ,
  p_tsp_information6             => p_tsp_information6         ,
  p_tsp_information7             => p_tsp_information7         ,
  p_tsp_information8             => p_tsp_information8         ,
  p_tsp_information9             => p_tsp_information9         ,
  p_tsp_information10            => p_tsp_information10        ,
  p_tsp_information11            => p_tsp_information11        ,
  p_tsp_information12            => p_tsp_information12        ,
  p_tsp_information13            => p_tsp_information13        ,
  p_tsp_information14            => p_tsp_information14        ,
  p_tsp_information15            => p_tsp_information15        ,
  p_tsp_information16            => p_tsp_information16        ,
  p_tsp_information17            => p_tsp_information17        ,
  p_tsp_information18            => p_tsp_information18        ,
  p_tsp_information19            => p_tsp_information19        ,
  p_tsp_information20            => p_tsp_information20        ,
  p_analysis_criteria_id         => p_analysis_criteria_id     ,
  p_validate                     => p_validate
  );

  --
  begin
    ota_skill_provision_bk2.update_skill_provision_a
  (p_skill_provision_id         => p_skill_provision_id       ,
   p_activity_version_id        => p_activity_version_id      ,
  p_object_version_number      => l_object_version_number    ,
  p_type                       => p_type                     ,
  p_comments                   => p_comments                 ,
  p_tsp_information_category   => p_tsp_information_category ,
  p_tsp_information1           => p_tsp_information1         ,
  p_tsp_information2           => p_tsp_information2         ,
  p_tsp_information3           => p_tsp_information3         ,
  p_tsp_information4           => p_tsp_information4         ,
  p_tsp_information5           => p_tsp_information5         ,
  p_tsp_information6           => p_tsp_information6         ,
  p_tsp_information7           => p_tsp_information7         ,
  p_tsp_information8           => p_tsp_information8         ,
  p_tsp_information9           => p_tsp_information9         ,
  p_tsp_information10          => p_tsp_information10        ,
  p_tsp_information11          => p_tsp_information11        ,
  p_tsp_information12          => p_tsp_information12        ,
  p_tsp_information13          => p_tsp_information13        ,
  p_tsp_information14          => p_tsp_information14        ,
  p_tsp_information15          => p_tsp_information15        ,
  p_tsp_information16          => p_tsp_information16        ,
  p_tsp_information17          => p_tsp_information17        ,
  p_tsp_information18          => p_tsp_information18        ,
  p_tsp_information19          => p_tsp_information19        ,
  p_tsp_information20          => p_tsp_information20        ,
  p_analysis_criteria_id       => p_analysis_criteria_id     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SKILL_PROVISION'
        ,p_hook_type   => 'AP'
        );
  end;
  p_object_version_number   := l_object_version_number;

  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_SKILL_PROVISION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_SKILL_PROVISION;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_skill_provision;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_SKILL_PROVISION >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_skill_provision
  (
  p_skill_provision_id                in number,
  p_object_version_number              in number,
  p_validate                           in boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Skill Provision';
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_SKILL_PROVISION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
    begin
    ota_skill_provision_bk3.delete_skill_provision_b
  (p_skill_provision_id         => p_skill_provision_id       ,
  p_object_version_number    => p_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SKILL_PROVISION'
        ,p_hook_type   => 'BP'
        );
  end;


  --
  -- Process Logic
  --
  ota_tsp_del.del
  (
  p_skill_provision_id      => p_skill_provision_id             ,
  p_object_version_number    => p_object_version_number           ,
  p_validate                 => p_validate
  );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --


     begin
    ota_skill_provision_bk3.delete_skill_provision_b
  (p_skill_provision_id         => p_skill_provision_id       ,
  p_object_version_number    => p_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SKILL_PROVISION'
        ,p_hook_type   => 'AP'
        );
  end;
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_SKILL_PROVISION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_SKILL_PROVISION;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_skill_provision;
--
end ota_skill_provision_api;

/
