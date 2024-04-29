--------------------------------------------------------
--  DDL for Package Body HR_PERSON_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_EXTRA_INFO_API" as
/* $Header: pepeiapi.pkb 115.6 2002/12/11 13:53:50 pkakar ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_person_extra_info_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_person_extra_info >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_extra_info
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_information_type              in     varchar2
  ,p_pei_attribute_category        in     varchar2 default null
  ,p_pei_attribute1                in     varchar2 default null
  ,p_pei_attribute2                in     varchar2 default null
  ,p_pei_attribute3                in     varchar2 default null
  ,p_pei_attribute4                in     varchar2 default null
  ,p_pei_attribute5                in     varchar2 default null
  ,p_pei_attribute6                in     varchar2 default null
  ,p_pei_attribute7                in     varchar2 default null
  ,p_pei_attribute8                in     varchar2 default null
  ,p_pei_attribute9                in     varchar2 default null
  ,p_pei_attribute10               in     varchar2 default null
  ,p_pei_attribute11               in     varchar2 default null
  ,p_pei_attribute12               in     varchar2 default null
  ,p_pei_attribute13               in     varchar2 default null
  ,p_pei_attribute14               in     varchar2 default null
  ,p_pei_attribute15               in     varchar2 default null
  ,p_pei_attribute16               in     varchar2 default null
  ,p_pei_attribute17               in     varchar2 default null
  ,p_pei_attribute18               in     varchar2 default null
  ,p_pei_attribute19               in     varchar2 default null
  ,p_pei_attribute20               in     varchar2 default null
  ,p_pei_information_category      in     varchar2 default null
  ,p_pei_information1              in     varchar2 default null
  ,p_pei_information2              in     varchar2 default null
  ,p_pei_information3              in     varchar2 default null
  ,p_pei_information4              in     varchar2 default null
  ,p_pei_information5              in     varchar2 default null
  ,p_pei_information6              in     varchar2 default null
  ,p_pei_information7              in     varchar2 default null
  ,p_pei_information8              in     varchar2 default null
  ,p_pei_information9              in     varchar2 default null
  ,p_pei_information10             in     varchar2 default null
  ,p_pei_information11             in     varchar2 default null
  ,p_pei_information12             in     varchar2 default null
  ,p_pei_information13             in     varchar2 default null
  ,p_pei_information14             in     varchar2 default null
  ,p_pei_information15             in     varchar2 default null
  ,p_pei_information16             in     varchar2 default null
  ,p_pei_information17             in     varchar2 default null
  ,p_pei_information18             in     varchar2 default null
  ,p_pei_information19             in     varchar2 default null
  ,p_pei_information20             in     varchar2 default null
  ,p_pei_information21             in     varchar2 default null
  ,p_pei_information22             in     varchar2 default null
  ,p_pei_information23             in     varchar2 default null
  ,p_pei_information24             in     varchar2 default null
  ,p_pei_information25             in     varchar2 default null
  ,p_pei_information26             in     varchar2 default null
  ,p_pei_information27             in     varchar2 default null
  ,p_pei_information28             in     varchar2 default null
  ,p_pei_information29             in     varchar2 default null
  ,p_pei_information30             in     varchar2 default null
  ,p_person_extra_info_id             out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc			varchar2(72) := g_package||'create_person_extra_info';
  l_object_version_number	per_people_extra_info.object_version_number%type;
  l_person_extra_info_id	per_people_extra_info.person_extra_info_id%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint create_person_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_person_extra_info_bk1.create_person_extra_info_b
     (p_person_id                  => p_person_id,
      p_information_type           => p_information_type,
      p_pei_attribute_category     => p_pei_attribute_category,
      p_pei_attribute1             => p_pei_attribute1,
      p_pei_attribute2             => p_pei_attribute2,
      p_pei_attribute3             => p_pei_attribute3,
      p_pei_attribute4             => p_pei_attribute4,
      p_pei_attribute5             => p_pei_attribute5,
      p_pei_attribute6             => p_pei_attribute6,
      p_pei_attribute7             => p_pei_attribute7,
      p_pei_attribute8             => p_pei_attribute8,
      p_pei_attribute9             => p_pei_attribute9,
      p_pei_attribute10            => p_pei_attribute10,
      p_pei_attribute11	           => p_pei_attribute11,
      p_pei_attribute12            => p_pei_attribute12,
      p_pei_attribute13            => p_pei_attribute13,
      p_pei_attribute14            => p_pei_attribute14,
      p_pei_attribute15            => p_pei_attribute15,
      p_pei_attribute16            => p_pei_attribute16,
      p_pei_attribute17            => p_pei_attribute17,
      p_pei_attribute18            => p_pei_attribute18,
      p_pei_attribute19            => p_pei_attribute19,
      p_pei_attribute20            => p_pei_attribute20,
      p_pei_information_category   => p_pei_information_category,
      p_pei_information1           => p_pei_information1,
      p_pei_information2           => p_pei_information2,
      p_pei_information3           => p_pei_information3,
      p_pei_information4           => p_pei_information4,
      p_pei_information5           => p_pei_information5,
      p_pei_information6           => p_pei_information6,
      p_pei_information7           => p_pei_information7,
      p_pei_information8           => p_pei_information8,
      p_pei_information9           => p_pei_information9,
      p_pei_information10          => p_pei_information10,
      p_pei_information11          => p_pei_information11,
      p_pei_information12          => p_pei_information12,
      p_pei_information13          => p_pei_information13,
      p_pei_information14          => p_pei_information14,
      p_pei_information15          => p_pei_information15,
      p_pei_information16          => p_pei_information16,
      p_pei_information17          => p_pei_information17,
      p_pei_information18          => p_pei_information18,
      p_pei_information19          => p_pei_information19,
      p_pei_information20          => p_pei_information20,
      p_pei_information21          => p_pei_information21,
      p_pei_information22          => p_pei_information22,
      p_pei_information23          => p_pei_information23,
      p_pei_information24          => p_pei_information24,
      p_pei_information25          => p_pei_information25,
      p_pei_information26          => p_pei_information26,
      p_pei_information27          => p_pei_information27,
      p_pei_information28          => p_pei_information28,
      p_pei_information29          => p_pei_information29,
      p_pei_information30          => p_pei_information30
      );
      exception
        when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
         (p_module_name => 'CREATE_PERSON_EXTRA_INFO',
          p_hook_type   => 'BP'
         );
end;
  --
  -- End of Before Process User Hook call
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  pe_pei_ins.ins
  (p_person_extra_info_id          => l_person_extra_info_id
  ,p_person_id                     => p_person_id
  ,p_information_type              => p_information_type
  ,p_pei_attribute_category        => p_pei_attribute_category
  ,p_pei_attribute1                => p_pei_attribute1
  ,p_pei_attribute2                => p_pei_attribute2
  ,p_pei_attribute3                => p_pei_attribute3
  ,p_pei_attribute4                => p_pei_attribute4
  ,p_pei_attribute5                => p_pei_attribute5
  ,p_pei_attribute6                => p_pei_attribute6
  ,p_pei_attribute7                => p_pei_attribute7
  ,p_pei_attribute8                => p_pei_attribute8
  ,p_pei_attribute9                => p_pei_attribute9
  ,p_pei_attribute10               => p_pei_attribute10
  ,p_pei_attribute11               => p_pei_attribute11
  ,p_pei_attribute12               => p_pei_attribute12
  ,p_pei_attribute13               => p_pei_attribute13
  ,p_pei_attribute14               => p_pei_attribute14
  ,p_pei_attribute15               => p_pei_attribute15
  ,p_pei_attribute16               => p_pei_attribute16
  ,p_pei_attribute17               => p_pei_attribute17
  ,p_pei_attribute18               => p_pei_attribute18
  ,p_pei_attribute19               => p_pei_attribute19
  ,p_pei_attribute20               => p_pei_attribute20
  ,p_pei_information_category      => p_pei_information_category
  ,p_pei_information1              => p_pei_information1
  ,p_pei_information2              => p_pei_information2
  ,p_pei_information3              => p_pei_information3
  ,p_pei_information4              => p_pei_information4
  ,p_pei_information5              => p_pei_information5
  ,p_pei_information6              => p_pei_information6
  ,p_pei_information7              => p_pei_information7
  ,p_pei_information8              => p_pei_information8
  ,p_pei_information9              => p_pei_information9
  ,p_pei_information10             => p_pei_information10
  ,p_pei_information11             => p_pei_information11
  ,p_pei_information12             => p_pei_information12
  ,p_pei_information13             => p_pei_information13
  ,p_pei_information14             => p_pei_information14
  ,p_pei_information15             => p_pei_information15
  ,p_pei_information16             => p_pei_information16
  ,p_pei_information17             => p_pei_information17
  ,p_pei_information18             => p_pei_information18
  ,p_pei_information19             => p_pei_information19
  ,p_pei_information20             => p_pei_information20
  ,p_pei_information21             => p_pei_information21
  ,p_pei_information22             => p_pei_information22
  ,p_pei_information23             => p_pei_information23
  ,p_pei_information24             => p_pei_information24
  ,p_pei_information25             => p_pei_information25
  ,p_pei_information26             => p_pei_information26
  ,p_pei_information27             => p_pei_information27
  ,p_pei_information28             => p_pei_information28
  ,p_pei_information29             => p_pei_information29
  ,p_pei_information30             => p_pei_information30
  ,p_object_version_number         => l_object_version_number
  ,p_validate                      => false
  );
  p_object_version_number	:= l_object_version_number;
  p_person_extra_info_id	:= l_person_extra_info_id;
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
    hr_person_extra_info_bk1.create_person_extra_info_a
     (p_person_extra_info_id       => l_person_extra_info_id,
      p_person_id                  => p_person_id,
      p_information_type           => p_information_type,
      p_pei_attribute_category     => p_pei_attribute_category,
      p_pei_attribute1             => p_pei_attribute1,
      p_pei_attribute2             => p_pei_attribute2,
      p_pei_attribute3             => p_pei_attribute3,
      p_pei_attribute4             => p_pei_attribute4,
      p_pei_attribute5             => p_pei_attribute5,
      p_pei_attribute6             => p_pei_attribute6,
      p_pei_attribute7             => p_pei_attribute7,
      p_pei_attribute8             => p_pei_attribute8,
      p_pei_attribute9             => p_pei_attribute9,
      p_pei_attribute10            => p_pei_attribute10,
      p_pei_attribute11            => p_pei_attribute11,
      p_pei_attribute12            => p_pei_attribute12,
      p_pei_attribute13            => p_pei_attribute13,
      p_pei_attribute14            => p_pei_attribute14,
      p_pei_attribute15            => p_pei_attribute15,
      p_pei_attribute16            => p_pei_attribute16,
      p_pei_attribute17            => p_pei_attribute17,
      p_pei_attribute18            => p_pei_attribute18,
      p_pei_attribute19            => p_pei_attribute19,
      p_pei_attribute20            => p_pei_attribute20,
      p_pei_information_category   => p_pei_information_category,
      p_pei_information1           => p_pei_information1,
      p_pei_information2           => p_pei_information2,
      p_pei_information3           => p_pei_information3,
      p_pei_information4           => p_pei_information4,
      p_pei_information5           => p_pei_information5,
      p_pei_information6           => p_pei_information6,
      p_pei_information7           => p_pei_information7,
      p_pei_information8           => p_pei_information8,
      p_pei_information9           => p_pei_information9,
      p_pei_information10          => p_pei_information10,
      p_pei_information11          => p_pei_information11,
      p_pei_information12          => p_pei_information12,
      p_pei_information13          => p_pei_information13,
      p_pei_information14          => p_pei_information14,
      p_pei_information15          => p_pei_information15,
      p_pei_information16          => p_pei_information16,
      p_pei_information17          => p_pei_information17,
      p_pei_information18          => p_pei_information18,
      p_pei_information19          => p_pei_information19,
      p_pei_information20          => p_pei_information20,
      p_pei_information21          => p_pei_information21,
      p_pei_information22          => p_pei_information22,
      p_pei_information23          => p_pei_information23,
      p_pei_information24          => p_pei_information24,
      p_pei_information25          => p_pei_information25,
      p_pei_information26          => p_pei_information26,
      p_pei_information27          => p_pei_information27,
      p_pei_information28          => p_pei_information28,
      p_pei_information29          => p_pei_information29,
      p_pei_information30          => p_pei_information30,
      p_object_version_number      => l_object_version_number
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'CREATE_PERSON_EXTRA_INFO',
           p_hook_type   => 'AP'
          );
end;
  --
  -- End of After Process User Hook call
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_person_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_person_extra_info_id   := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of the fix to bug 632479
    --
    ROLLBACK TO create_person_extra_info;
    --
    -- set in out parameters and set out parameters
    --
    p_person_extra_info_id   := null;
    p_object_version_number  := null;
    --
    raise;
    --
end create_person_extra_info;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_person_extra_info >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_extra_info
  (p_validate                      in     boolean  default false
  ,p_person_extra_info_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_pei_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_pei_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_pei_information1              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information2              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information3              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information4              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information5              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information6              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information7              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information8              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information9              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information10             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information11             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information12             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information13             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information14             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information15             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information16             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information17             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information18             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information19             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information20             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information21             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information22             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information23             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information24             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information25             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information26             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information27             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information28             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information29             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information30             in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_person_extra_info';
  l_object_version_number per_phones.object_version_number%TYPE;
  l_ovn 		  per_phones.object_version_number%TYPE := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint update_person_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_person_extra_info_bk2.update_person_extra_info_b
     (p_person_extra_info_id         => p_person_extra_info_id,
      p_pei_attribute_category     => p_pei_attribute_category,
      p_pei_attribute1             => p_pei_attribute1,
      p_pei_attribute2             => p_pei_attribute2,
      p_pei_attribute3             => p_pei_attribute3,
      p_pei_attribute4             => p_pei_attribute4,
      p_pei_attribute5             => p_pei_attribute5,
      p_pei_attribute6             => p_pei_attribute6,
      p_pei_attribute7             => p_pei_attribute7,
      p_pei_attribute8             => p_pei_attribute8,
      p_pei_attribute9             => p_pei_attribute9,
      p_pei_attribute10            => p_pei_attribute10,
      p_pei_attribute11            => p_pei_attribute11,
      p_pei_attribute12            => p_pei_attribute12,
      p_pei_attribute13            => p_pei_attribute13,
      p_pei_attribute14            => p_pei_attribute14,
      p_pei_attribute15            => p_pei_attribute15,
      p_pei_attribute16            => p_pei_attribute16,
      p_pei_attribute17            => p_pei_attribute17,
      p_pei_attribute18            => p_pei_attribute18,
      p_pei_attribute19            => p_pei_attribute19,
      p_pei_attribute20            => p_pei_attribute20,
      p_pei_information_category   => p_pei_information_category,
      p_pei_information1           => p_pei_information1,
      p_pei_information2           => p_pei_information2,
      p_pei_information3           => p_pei_information3,
      p_pei_information4           => p_pei_information4,
      p_pei_information5           => p_pei_information5,
      p_pei_information6           => p_pei_information6,
      p_pei_information7           => p_pei_information7,
      p_pei_information8           => p_pei_information8,
      p_pei_information9           => p_pei_information9,
      p_pei_information10          => p_pei_information10,
      p_pei_information11          => p_pei_information11,
      p_pei_information12          => p_pei_information12,
      p_pei_information13          => p_pei_information13,
      p_pei_information14          => p_pei_information14,
      p_pei_information15          => p_pei_information15,
      p_pei_information16          => p_pei_information16,
      p_pei_information17          => p_pei_information17,
      p_pei_information18          => p_pei_information18,
      p_pei_information19          => p_pei_information19,
      p_pei_information20          => p_pei_information20,
      p_pei_information21          => p_pei_information21,
      p_pei_information22          => p_pei_information22,
      p_pei_information23          => p_pei_information23,
      p_pei_information24          => p_pei_information24,
      p_pei_information25          => p_pei_information25,
      p_pei_information26          => p_pei_information26,
      p_pei_information27          => p_pei_information27,
      p_pei_information28          => p_pei_information28,
      p_pei_information29          => p_pei_information29,
      p_pei_information30          => p_pei_information30,
      p_object_version_number      => p_object_version_number
      );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'UPDATE_PERSON_EXTRA_INFO',
             p_hook_type   => 'BP'
            );
end;
  --
  -- End of Before Process User Hook call
  --
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Store the original ovn in case we rollback when p_validate is true
  --
  l_object_version_number  := p_object_version_number;
  --
  -- Process Logic - Update Person Extra Info details
  --
  pe_pei_upd.upd
  (p_person_extra_info_id          => p_person_extra_info_id
  ,p_pei_attribute_category        => p_pei_attribute_category
  ,p_pei_attribute1                => p_pei_attribute1
  ,p_pei_attribute2                => p_pei_attribute2
  ,p_pei_attribute3                => p_pei_attribute3
  ,p_pei_attribute4                => p_pei_attribute4
  ,p_pei_attribute5                => p_pei_attribute5
  ,p_pei_attribute6                => p_pei_attribute6
  ,p_pei_attribute7                => p_pei_attribute7
  ,p_pei_attribute8                => p_pei_attribute8
  ,p_pei_attribute9                => p_pei_attribute9
  ,p_pei_attribute10               => p_pei_attribute10
  ,p_pei_attribute11               => p_pei_attribute11
  ,p_pei_attribute12               => p_pei_attribute12
  ,p_pei_attribute13               => p_pei_attribute13
  ,p_pei_attribute14               => p_pei_attribute14
  ,p_pei_attribute15               => p_pei_attribute15
  ,p_pei_attribute16               => p_pei_attribute16
  ,p_pei_attribute17               => p_pei_attribute17
  ,p_pei_attribute18               => p_pei_attribute18
  ,p_pei_attribute19               => p_pei_attribute19
  ,p_pei_attribute20               => p_pei_attribute20
  ,p_pei_information_category      => p_pei_information_category
  ,p_pei_information1              => p_pei_information1
  ,p_pei_information2              => p_pei_information2
  ,p_pei_information3              => p_pei_information3
  ,p_pei_information4              => p_pei_information4
  ,p_pei_information5              => p_pei_information5
  ,p_pei_information6              => p_pei_information6
  ,p_pei_information7              => p_pei_information7
  ,p_pei_information8              => p_pei_information8
  ,p_pei_information9              => p_pei_information9
  ,p_pei_information10             => p_pei_information10
  ,p_pei_information11             => p_pei_information11
  ,p_pei_information12             => p_pei_information12
  ,p_pei_information13             => p_pei_information13
  ,p_pei_information14             => p_pei_information14
  ,p_pei_information15             => p_pei_information15
  ,p_pei_information16             => p_pei_information16
  ,p_pei_information17             => p_pei_information17
  ,p_pei_information18             => p_pei_information18
  ,p_pei_information19             => p_pei_information19
  ,p_pei_information20             => p_pei_information20
  ,p_pei_information21             => p_pei_information21
  ,p_pei_information22             => p_pei_information22
  ,p_pei_information23             => p_pei_information23
  ,p_pei_information24             => p_pei_information24
  ,p_pei_information25             => p_pei_information25
  ,p_pei_information26             => p_pei_information26
  ,p_pei_information27             => p_pei_information27
  ,p_pei_information28             => p_pei_information28
  ,p_pei_information29             => p_pei_information29
  ,p_pei_information30             => p_pei_information30
  ,p_object_version_number         => p_object_version_number
  ,p_validate                      => false
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
    hr_person_extra_info_bk2.update_person_extra_info_a
     (p_person_extra_info_id       => p_person_extra_info_id,
      p_pei_attribute_category     => p_pei_attribute_category,
      p_pei_attribute1             => p_pei_attribute1,
      p_pei_attribute2             => p_pei_attribute2,
      p_pei_attribute3             => p_pei_attribute3,
      p_pei_attribute4             => p_pei_attribute4,
      p_pei_attribute5             => p_pei_attribute5,
      p_pei_attribute6             => p_pei_attribute6,
      p_pei_attribute7             => p_pei_attribute7,
      p_pei_attribute8             => p_pei_attribute8,
      p_pei_attribute9             => p_pei_attribute9,
      p_pei_attribute10            => p_pei_attribute10,
      p_pei_attribute11            => p_pei_attribute11,
      p_pei_attribute12            => p_pei_attribute12,
      p_pei_attribute13            => p_pei_attribute13,
      p_pei_attribute14            => p_pei_attribute14,
      p_pei_attribute15            => p_pei_attribute15,
      p_pei_attribute16            => p_pei_attribute16,
      p_pei_attribute17            => p_pei_attribute17,
      p_pei_attribute18            => p_pei_attribute18,
      p_pei_attribute19            => p_pei_attribute19,
      p_pei_attribute20            => p_pei_attribute20,
      p_pei_information_category   => p_pei_information_category,
      p_pei_information1           => p_pei_information1,
      p_pei_information2           => p_pei_information2,
      p_pei_information3           => p_pei_information3,
      p_pei_information4           => p_pei_information4,
      p_pei_information5           => p_pei_information5,
      p_pei_information6           => p_pei_information6,
      p_pei_information7           => p_pei_information7,
      p_pei_information8           => p_pei_information8,
      p_pei_information9           => p_pei_information9,
      p_pei_information10          => p_pei_information10,
      p_pei_information11          => p_pei_information11,
      p_pei_information12          => p_pei_information12,
      p_pei_information13          => p_pei_information13,
      p_pei_information14          => p_pei_information14,
      p_pei_information15          => p_pei_information15,
      p_pei_information16          => p_pei_information16,
      p_pei_information17          => p_pei_information17,
      p_pei_information18          => p_pei_information18,
      p_pei_information19          => p_pei_information19,
      p_pei_information20          => p_pei_information20,
      p_pei_information21          => p_pei_information21,
      p_pei_information22          => p_pei_information22,
      p_pei_information23          => p_pei_information23,
      p_pei_information24          => p_pei_information24,
      p_pei_information25          => p_pei_information25,
      p_pei_information26          => p_pei_information26,
      p_pei_information27          => p_pei_information27,
      p_pei_information28          => p_pei_information28,
      p_pei_information29          => p_pei_information29,
      p_pei_information30          => p_pei_information30,
      p_object_version_number      => p_object_version_number
      );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
      	    (p_module_name => 'UPDATE_PERSON_EXTRA_INFO',
             p_hook_type   => 'AP'
            );
end;
  --
  -- End of After Process User Hook call
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_person_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of the fix to bug 632479
    --
    ROLLBACK TO update_person_extra_info;
    --
    -- set in out parameters and set out parameters
    --
        p_object_version_number  := l_ovn;
    --
    raise;
    --
end update_person_extra_info;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_person_extra_info >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_extra_info
  (p_validate                      in     boolean  default false
  ,p_person_extra_info_id          in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_person_extra_info';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint delete_person_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_person_extra_info_bk3.delete_person_extra_info_b
      (p_person_extra_info_id       => p_person_extra_info_id,
       p_object_version_number      => p_object_version_number
      );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'DELETE_PERSON_EXTRA_INFO',
             p_hook_type   => 'BP'
            );
end;
  --
  -- End of Before Process User Hook call
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic - Delete Person Extra Info details
  --
  pe_pei_del.del
  (p_person_extra_info_id          => p_person_extra_info_id
  ,p_object_version_number         => p_object_version_number
  ,p_validate                      => false
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_person_extra_info_bk3.delete_person_extra_info_a
      (p_person_extra_info_id      => p_person_extra_info_id,
       p_object_version_number     => p_object_version_number
      );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'DELETE_PERSON_EXTRA_INFO',
             p_hook_type   => 'AP'
            );
end;
  --
  -- End of After Process User Hook call
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_person_extra_info;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of the fix to bug 632479
    --
    ROLLBACK TO delete_person_extra_info;
    --
    raise;
    --
end delete_person_extra_info;
--
end hr_person_extra_info_api;

/
