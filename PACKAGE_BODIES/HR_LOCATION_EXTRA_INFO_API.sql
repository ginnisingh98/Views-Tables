--------------------------------------------------------
--  DDL for Package Body HR_LOCATION_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOCATION_EXTRA_INFO_API" as
/* $Header: hrleiapi.pkb 115.4 2003/09/12 03:02:27 smparame ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_location_extra_info_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_location_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_location_extra_info
  (p_validate                     in     boolean  default false
  ,p_location_id                  in     number
  ,p_information_type             in     varchar2
  ,p_lei_attribute_category       in     varchar2 default null
  ,p_lei_attribute1               in     varchar2 default null
  ,p_lei_attribute2               in     varchar2 default null
  ,p_lei_attribute3               in     varchar2 default null
  ,p_lei_attribute4               in     varchar2 default null
  ,p_lei_attribute5               in     varchar2 default null
  ,p_lei_attribute6               in     varchar2 default null
  ,p_lei_attribute7               in     varchar2 default null
  ,p_lei_attribute8               in     varchar2 default null
  ,p_lei_attribute9               in     varchar2 default null
  ,p_lei_attribute10              in     varchar2 default null
  ,p_lei_attribute11              in     varchar2 default null
  ,p_lei_attribute12              in     varchar2 default null
  ,p_lei_attribute13              in     varchar2 default null
  ,p_lei_attribute14              in     varchar2 default null
  ,p_lei_attribute15              in     varchar2 default null
  ,p_lei_attribute16              in     varchar2 default null
  ,p_lei_attribute17              in     varchar2 default null
  ,p_lei_attribute18              in     varchar2 default null
  ,p_lei_attribute19              in     varchar2 default null
  ,p_lei_attribute20              in     varchar2 default null
  ,p_lei_information_category     in     varchar2 default null
  ,p_lei_information1             in     varchar2 default null
  ,p_lei_information2             in     varchar2 default null
  ,p_lei_information3             in     varchar2 default null
  ,p_lei_information4             in     varchar2 default null
  ,p_lei_information5             in     varchar2 default null
  ,p_lei_information6             in     varchar2 default null
  ,p_lei_information7             in     varchar2 default null
  ,p_lei_information8             in     varchar2 default null
  ,p_lei_information9             in     varchar2 default null
  ,p_lei_information10            in     varchar2 default null
  ,p_lei_information11            in     varchar2 default null
  ,p_lei_information12            in     varchar2 default null
  ,p_lei_information13            in     varchar2 default null
  ,p_lei_information14            in     varchar2 default null
  ,p_lei_information15            in     varchar2 default null
  ,p_lei_information16            in     varchar2 default null
  ,p_lei_information17            in     varchar2 default null
  ,p_lei_information18            in     varchar2 default null
  ,p_lei_information19            in     varchar2 default null
  ,p_lei_information20            in     varchar2 default null
  ,p_lei_information21            in     varchar2 default null
  ,p_lei_information22            in     varchar2 default null
  ,p_lei_information23            in     varchar2 default null
  ,p_lei_information24            in     varchar2 default null
  ,p_lei_information25            in     varchar2 default null
  ,p_lei_information26            in     varchar2 default null
  ,p_lei_information27            in     varchar2 default null
  ,p_lei_information28            in     varchar2 default null
  ,p_lei_information29            in     varchar2 default null
  ,p_lei_information30            in     varchar2 default null
  ,p_location_extra_info_id           out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc					varchar2(72) := g_package||'create_location_extra_info';
  l_object_version_number		hr_location_extra_info.object_version_number%type;
  l_location_extra_info_id		hr_location_extra_info.location_extra_info_id%type;
  -- Bug fix 3132479 . Local variable to store information category.
  l_lei_information_category    	hr_location_extra_info.lei_information_category%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint create_location_extra_info;

  -- Bug Fix 3132479
  -- If the information category is passed as null then
  -- information type passed is assigned to it.

  if p_lei_information_category is null then
      l_lei_information_category := p_information_type;
  else
      l_lei_information_category := p_lei_information_category;
  end if;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_location_extra_info_bk1.create_location_extra_info_b
     (p_information_type          => p_information_type,
      p_location_id               => p_location_id,
      p_lei_attribute_category    => p_lei_attribute_category,
      p_lei_attribute1            => p_lei_attribute1,
      p_lei_attribute2            => p_lei_attribute2,
      p_lei_attribute3            => p_lei_attribute3,
      p_lei_attribute4            => p_lei_attribute4,
      p_lei_attribute5            => p_lei_attribute5,
      p_lei_attribute6            => p_lei_attribute6,
      p_lei_attribute7            => p_lei_attribute7,
      p_lei_attribute8            => p_lei_attribute8,
      p_lei_attribute9            => p_lei_attribute9,
      p_lei_attribute10           => p_lei_attribute10,
      p_lei_attribute11           => p_lei_attribute11,
      p_lei_attribute12           => p_lei_attribute12,
      p_lei_attribute13           => p_lei_attribute13,
      p_lei_attribute14           => p_lei_attribute14,
      p_lei_attribute15           => p_lei_attribute15,
      p_lei_attribute16           => p_lei_attribute16,
      p_lei_attribute17           => p_lei_attribute17,
      p_lei_attribute18           => p_lei_attribute18,
      p_lei_attribute19           => p_lei_attribute19,
      p_lei_attribute20           => p_lei_attribute20,
      p_lei_information_category  => l_lei_information_category,
      p_lei_information1          => p_lei_information1,
      p_lei_information2          => p_lei_information2,
      p_lei_information3          => p_lei_information3,
      p_lei_information4          => p_lei_information4,
      p_lei_information5          => p_lei_information5,
      p_lei_information6          => p_lei_information6,
      p_lei_information7          => p_lei_information7,
      p_lei_information8          => p_lei_information8,
      p_lei_information9          => p_lei_information9,
      p_lei_information10         => p_lei_information10,
      p_lei_information11         => p_lei_information11,
      p_lei_information12         => p_lei_information12,
      p_lei_information13         => p_lei_information13,
      p_lei_information14         => p_lei_information14,
      p_lei_information15         => p_lei_information15,
      p_lei_information16         => p_lei_information16,
      p_lei_information17         => p_lei_information17,
      p_lei_information18         => p_lei_information18,
      p_lei_information19         => p_lei_information19,
      p_lei_information20         => p_lei_information20,
      p_lei_information21         => p_lei_information21,
      p_lei_information22         => p_lei_information22,
      p_lei_information23         => p_lei_information23,
      p_lei_information24         => p_lei_information24,
      p_lei_information25         => p_lei_information25,
      p_lei_information26         => p_lei_information26,
      p_lei_information27         => p_lei_information27,
      p_lei_information28         => p_lei_information28,
      p_lei_information29         => p_lei_information29,
      p_lei_information30         => p_lei_information30
      );
      exception
        when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
         (p_module_name	=> 'CREATE_LOCATION_EXTRA_INFO',
          p_hook_type   => 'BP'
         );
  end;
  --
  -- End of Before Process User Hook call
  --
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  hr_lei_ins.ins
  (p_location_extra_info_id       => l_location_extra_info_id
  ,p_location_id                  => p_location_id
  ,p_information_type             => p_information_type
  ,p_lei_attribute_category       => p_lei_attribute_category
  ,p_lei_attribute1               => p_lei_attribute1
  ,p_lei_attribute2               => p_lei_attribute2
  ,p_lei_attribute3               => p_lei_attribute3
  ,p_lei_attribute4               => p_lei_attribute4
  ,p_lei_attribute5               => p_lei_attribute5
  ,p_lei_attribute6               => p_lei_attribute6
  ,p_lei_attribute7               => p_lei_attribute7
  ,p_lei_attribute8               => p_lei_attribute8
  ,p_lei_attribute9               => p_lei_attribute9
  ,p_lei_attribute10              => p_lei_attribute10
  ,p_lei_attribute11              => p_lei_attribute11
  ,p_lei_attribute12              => p_lei_attribute12
  ,p_lei_attribute13              => p_lei_attribute13
  ,p_lei_attribute14              => p_lei_attribute14
  ,p_lei_attribute15              => p_lei_attribute15
  ,p_lei_attribute16              => p_lei_attribute16
  ,p_lei_attribute17              => p_lei_attribute17
  ,p_lei_attribute18              => p_lei_attribute18
  ,p_lei_attribute19              => p_lei_attribute19
  ,p_lei_attribute20              => p_lei_attribute20
  ,p_lei_information_category     => l_lei_information_category
  ,p_lei_information1             => p_lei_information1
  ,p_lei_information2             => p_lei_information2
  ,p_lei_information3             => p_lei_information3
  ,p_lei_information4             => p_lei_information4
  ,p_lei_information5             => p_lei_information5
  ,p_lei_information6             => p_lei_information6
  ,p_lei_information7             => p_lei_information7
  ,p_lei_information8             => p_lei_information8
  ,p_lei_information9             => p_lei_information9
  ,p_lei_information10            => p_lei_information10
  ,p_lei_information11            => p_lei_information11
  ,p_lei_information12            => p_lei_information12
  ,p_lei_information13            => p_lei_information13
  ,p_lei_information14            => p_lei_information14
  ,p_lei_information15            => p_lei_information15
  ,p_lei_information16            => p_lei_information16
  ,p_lei_information17            => p_lei_information17
  ,p_lei_information18            => p_lei_information18
  ,p_lei_information19            => p_lei_information19
  ,p_lei_information20            => p_lei_information20
  ,p_lei_information21            => p_lei_information21
  ,p_lei_information22            => p_lei_information22
  ,p_lei_information23            => p_lei_information23
  ,p_lei_information24            => p_lei_information24
  ,p_lei_information25            => p_lei_information25
  ,p_lei_information26            => p_lei_information26
  ,p_lei_information27            => p_lei_information27
  ,p_lei_information28            => p_lei_information28
  ,p_lei_information29            => p_lei_information29
  ,p_lei_information30            => p_lei_information30
  ,p_object_version_number        => l_object_version_number
  ,p_validate                     => false
  );
  p_object_version_number       := l_object_version_number;
  p_location_extra_info_id	:= l_location_extra_info_id;
  --
  hr_utility.set_location(l_proc, 8);
  --
  --
  -- Call After Process User Hook
  --
  begin
    hr_location_extra_info_bk1.create_location_extra_info_a
     (p_location_extra_info_id    => l_location_extra_info_id,
      p_information_type          => p_information_type,
      p_location_id               => p_location_id,
      p_lei_attribute_category	  => p_lei_attribute_category,
      p_lei_attribute1            => p_lei_attribute1,
      p_lei_attribute2            => p_lei_attribute2,
      p_lei_attribute3            => p_lei_attribute3,
      p_lei_attribute4            => p_lei_attribute4,
      p_lei_attribute5            => p_lei_attribute5,
      p_lei_attribute6            => p_lei_attribute6,
      p_lei_attribute7            => p_lei_attribute7,
      p_lei_attribute8            => p_lei_attribute8,
      p_lei_attribute9            => p_lei_attribute9,
      p_lei_attribute10           => p_lei_attribute10,
      p_lei_attribute11           => p_lei_attribute11,
      p_lei_attribute12           => p_lei_attribute12,
      p_lei_attribute13           => p_lei_attribute13,
      p_lei_attribute14           => p_lei_attribute14,
      p_lei_attribute15           => p_lei_attribute15,
      p_lei_attribute16           => p_lei_attribute16,
      p_lei_attribute17           => p_lei_attribute17,
      p_lei_attribute18           => p_lei_attribute18,
      p_lei_attribute19           => p_lei_attribute19,
      p_lei_attribute20           => p_lei_attribute20,
      p_lei_information_category  => l_lei_information_category,
      p_lei_information1          => p_lei_information1,
      p_lei_information2          => p_lei_information2,
      p_lei_information3          => p_lei_information3,
      p_lei_information4          => p_lei_information4,
      p_lei_information5          => p_lei_information5,
      p_lei_information6          => p_lei_information6,
      p_lei_information7          => p_lei_information7,
      p_lei_information8          => p_lei_information8,
      p_lei_information9          => p_lei_information9,
      p_lei_information10         => p_lei_information10,
      p_lei_information11         => p_lei_information11,
      p_lei_information12         => p_lei_information12,
      p_lei_information13         => p_lei_information13,
      p_lei_information14         => p_lei_information14,
      p_lei_information15         => p_lei_information15,
      p_lei_information16         => p_lei_information16,
      p_lei_information17         => p_lei_information17,
      p_lei_information18         => p_lei_information18,
      p_lei_information19         => p_lei_information19,
      p_lei_information20         => p_lei_information20,
      p_lei_information21         => p_lei_information21,
      p_lei_information22         => p_lei_information22,
      p_lei_information23         => p_lei_information23,
      p_lei_information24         => p_lei_information24,
      p_lei_information25         => p_lei_information25,
      p_lei_information26         => p_lei_information26,
      p_lei_information27         => p_lei_information27,
      p_lei_information28         => p_lei_information28,
      p_lei_information29         => p_lei_information29,
      p_lei_information30         => p_lei_information30,
      p_object_version_number     => l_object_version_number
      );
      exception
      when hr_api.cannot_find_prog_unit then
      -- Set OUT parameters to null
      p_location_extra_info_id := null;
      p_object_version_number  := null;

        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'CREATE_LOCATION_EXTRA_INFO',
           p_hook_type   => 'AP'
          );
  end;
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
    ROLLBACK TO create_location_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_location_extra_info_id := null;
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
  ROLLBACK TO create_location_extra_info;
  --
  -- Set OUT parameters to null
  p_location_extra_info_id := null;
  p_object_version_number  := null;
  raise;
  --
end create_location_extra_info;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_location_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_location_extra_info
  (p_validate                     in     boolean  default false
  ,p_location_extra_info_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_lei_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_lei_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_lei_information1             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information2             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information3             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information4             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information5             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information6             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information7             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information8             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information9             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information10            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information11            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information12            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information13            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information14            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information15            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information16            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information17            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information18            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information19            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information20            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information21            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information22            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information23            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information24            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information25            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information26            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information27            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information28            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information29            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information30            in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_location_extra_info';
  l_object_version_number hr_location_extra_info.object_version_number%TYPE;
  l_temp_ovn              hr_location_extra_info.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint update_location_extra_info;

  l_temp_ovn := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_location_extra_info_bk2.update_location_extra_info_b
     (p_location_extra_info_id    => p_location_extra_info_id,
      p_lei_attribute_category    => p_lei_attribute_category,
      p_lei_attribute1            => p_lei_attribute1,
      p_lei_attribute2            => p_lei_attribute2,
      p_lei_attribute3            => p_lei_attribute3,
      p_lei_attribute4            => p_lei_attribute4,
      p_lei_attribute5            => p_lei_attribute5,
      p_lei_attribute6            => p_lei_attribute6,
      p_lei_attribute7            => p_lei_attribute7,
      p_lei_attribute8            => p_lei_attribute8,
      p_lei_attribute9            => p_lei_attribute9,
      p_lei_attribute10           => p_lei_attribute10,
      p_lei_attribute11	          => p_lei_attribute11,
      p_lei_attribute12	          => p_lei_attribute12,
      p_lei_attribute13	          => p_lei_attribute13,
      p_lei_attribute14	          => p_lei_attribute14,
      p_lei_attribute15	          => p_lei_attribute15,
      p_lei_attribute16	          => p_lei_attribute16,
      p_lei_attribute17	          => p_lei_attribute17,
      p_lei_attribute18	          => p_lei_attribute18,
      p_lei_attribute19	          => p_lei_attribute19,
      p_lei_attribute20	          => p_lei_attribute20,
      p_lei_information_category  => p_lei_information_category,
      p_lei_information1          => p_lei_information1,
      p_lei_information2          => p_lei_information2,
      p_lei_information3          => p_lei_information3,
      p_lei_information4          => p_lei_information4,
      p_lei_information5          => p_lei_information5,
      p_lei_information6          => p_lei_information6,
      p_lei_information7          => p_lei_information7,
      p_lei_information8          => p_lei_information8,
      p_lei_information9          => p_lei_information9,
      p_lei_information10         => p_lei_information10,
      p_lei_information11         => p_lei_information11,
      p_lei_information12         => p_lei_information12,
      p_lei_information13         => p_lei_information13,
      p_lei_information14         => p_lei_information14,
      p_lei_information15         => p_lei_information15,
      p_lei_information16         => p_lei_information16,
      p_lei_information17         => p_lei_information17,
      p_lei_information18         => p_lei_information18,
      p_lei_information19         => p_lei_information19,
      p_lei_information20         => p_lei_information20,
      p_lei_information21         => p_lei_information21,
      p_lei_information22         => p_lei_information22,
      p_lei_information23         => p_lei_information23,
      p_lei_information24         => p_lei_information24,
      p_lei_information25         => p_lei_information25,
      p_lei_information26         => p_lei_information26,
      p_lei_information27         => p_lei_information27,
      p_lei_information28         => p_lei_information28,
      p_lei_information29         => p_lei_information29,
      p_lei_information30         => p_lei_information30,
      p_object_version_number     => p_object_version_number
      );
      exception
      when hr_api.cannot_find_prog_unit then
      -- Reset OUT parameters
      p_object_version_number := l_temp_ovn;
          hr_api.cannot_find_prog_unit_error
           (p_module_name => 'UPDATE_LOCATION_EXTRA_INFO',
           p_hook_type    => 'BP'
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
  -- Process Logic - Update location Extra Info details
  --
  hr_lei_upd.upd
  (p_location_extra_info_id       => p_location_extra_info_id
  ,p_lei_attribute_category       => p_lei_attribute_category
  ,p_lei_attribute1               => p_lei_attribute1
  ,p_lei_attribute2               => p_lei_attribute2
  ,p_lei_attribute3               => p_lei_attribute3
  ,p_lei_attribute4               => p_lei_attribute4
  ,p_lei_attribute5               => p_lei_attribute5
  ,p_lei_attribute6               => p_lei_attribute6
  ,p_lei_attribute7               => p_lei_attribute7
  ,p_lei_attribute8               => p_lei_attribute8
  ,p_lei_attribute9               => p_lei_attribute9
  ,p_lei_attribute10              => p_lei_attribute10
  ,p_lei_attribute11              => p_lei_attribute11
  ,p_lei_attribute12              => p_lei_attribute12
  ,p_lei_attribute13              => p_lei_attribute13
  ,p_lei_attribute14              => p_lei_attribute14
  ,p_lei_attribute15              => p_lei_attribute15
  ,p_lei_attribute16              => p_lei_attribute16
  ,p_lei_attribute17              => p_lei_attribute17
  ,p_lei_attribute18              => p_lei_attribute18
  ,p_lei_attribute19              => p_lei_attribute19
  ,p_lei_attribute20              => p_lei_attribute20
  ,p_lei_information_category     => p_lei_information_category
  ,p_lei_information1             => p_lei_information1
  ,p_lei_information2             => p_lei_information2
  ,p_lei_information3             => p_lei_information3
  ,p_lei_information4             => p_lei_information4
  ,p_lei_information5             => p_lei_information5
  ,p_lei_information6             => p_lei_information6
  ,p_lei_information7             => p_lei_information7
  ,p_lei_information8             => p_lei_information8
  ,p_lei_information9             => p_lei_information9
  ,p_lei_information10            => p_lei_information10
  ,p_lei_information11            => p_lei_information11
  ,p_lei_information12            => p_lei_information12
  ,p_lei_information13            => p_lei_information13
  ,p_lei_information14            => p_lei_information14
  ,p_lei_information15            => p_lei_information15
  ,p_lei_information16            => p_lei_information16
  ,p_lei_information17            => p_lei_information17
  ,p_lei_information18            => p_lei_information18
  ,p_lei_information19            => p_lei_information19
  ,p_lei_information20            => p_lei_information20
  ,p_lei_information21            => p_lei_information21
  ,p_lei_information22            => p_lei_information22
  ,p_lei_information23            => p_lei_information23
  ,p_lei_information24            => p_lei_information24
  ,p_lei_information25            => p_lei_information25
  ,p_lei_information26            => p_lei_information26
  ,p_lei_information27            => p_lei_information27
  ,p_lei_information28            => p_lei_information28
  ,p_lei_information29            => p_lei_information29
  ,p_lei_information30            => p_lei_information30
  ,p_object_version_number        => p_object_version_number
  ,p_validate                     => false
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  --
  -- Call After Process User Hook
  --
  begin
    hr_location_extra_info_bk2.update_location_extra_info_a
     (p_location_extra_info_id    => p_location_extra_info_id,
      p_lei_attribute_category    => p_lei_attribute_category,
      p_lei_attribute1            => p_lei_attribute1,
      p_lei_attribute2            => p_lei_attribute2,
      p_lei_attribute3            => p_lei_attribute3,
      p_lei_attribute4            => p_lei_attribute4,
      p_lei_attribute5            => p_lei_attribute5,
      p_lei_attribute6            => p_lei_attribute6,
      p_lei_attribute7            => p_lei_attribute7,
      p_lei_attribute8            => p_lei_attribute8,
      p_lei_attribute9            => p_lei_attribute9,
      p_lei_attribute10           => p_lei_attribute10,
      p_lei_attribute11           => p_lei_attribute11,
      p_lei_attribute12           => p_lei_attribute12,
      p_lei_attribute13           => p_lei_attribute13,
      p_lei_attribute14           => p_lei_attribute14,
      p_lei_attribute15           => p_lei_attribute15,
      p_lei_attribute16           => p_lei_attribute16,
      p_lei_attribute17           => p_lei_attribute17,
      p_lei_attribute18           => p_lei_attribute18,
      p_lei_attribute19           => p_lei_attribute19,
      p_lei_attribute20           => p_lei_attribute20,
      p_lei_information_category  => p_lei_information_category,
      p_lei_information1          => p_lei_information1,
      p_lei_information2          => p_lei_information2,
      p_lei_information3          => p_lei_information3,
      p_lei_information4          => p_lei_information4,
      p_lei_information5          => p_lei_information5,
      p_lei_information6          => p_lei_information6,
      p_lei_information7          => p_lei_information7,
      p_lei_information8          => p_lei_information8,
      p_lei_information9          => p_lei_information9,
      p_lei_information10         => p_lei_information10,
      p_lei_information11         => p_lei_information11,
      p_lei_information12         => p_lei_information12,
      p_lei_information13         => p_lei_information13,
      p_lei_information14         => p_lei_information14,
      p_lei_information15         => p_lei_information15,
      p_lei_information16         => p_lei_information16,
      p_lei_information17         => p_lei_information17,
      p_lei_information18         => p_lei_information18,
      p_lei_information19         => p_lei_information19,
      p_lei_information20         => p_lei_information20,
      p_lei_information21         => p_lei_information21,
      p_lei_information22         => p_lei_information22,
      p_lei_information23         => p_lei_information23,
      p_lei_information24         => p_lei_information24,
      p_lei_information25         => p_lei_information25,
      p_lei_information26         => p_lei_information26,
      p_lei_information27         => p_lei_information27,
      p_lei_information28         => p_lei_information28,
      p_lei_information29         => p_lei_information29,
      p_lei_information30         => p_lei_information30,
      p_object_version_number     => p_object_version_number
      );
      exception
      when hr_api.cannot_find_prog_unit then
      -- Reset OUT parameters
      p_object_version_number := l_temp_ovn;
          hr_api.cannot_find_prog_unit_error
           (p_module_name => 'UPDATE_LOCATION_EXTRA_INFO',
            p_hook_type	  => 'AP'
           );
  end;
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
    ROLLBACK TO update_location_extra_info;
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
  ROLLBACK TO update_location_extra_info;
  -- Reset OUT parameters
  p_object_version_number := l_temp_ovn;
  --
  raise;
  --
end update_location_extra_info;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_location_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_location_extra_info
  (p_validate                      in     boolean  default false
  ,p_location_extra_info_id        in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_location_extra_info';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint delete_location_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_location_extra_info_bk3.delete_location_extra_info_b
     (p_location_extra_info_id	=> p_location_extra_info_id,
      p_object_version_number	=> p_object_version_number
     );
     exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
          (p_module_name => 'DELETE_LOCATION_EXTRA_INFO',
           p_hook_type   => 'BP'
          );
  end;
  --
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic - Delete location Extra Info details
  --
  hr_lei_del.del
  (p_location_extra_info_id        => p_location_extra_info_id
  ,p_object_version_number         => p_object_version_number
  ,p_validate                      => false
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  --
  -- Call After Process User Hook
  --
  begin
    hr_location_extra_info_bk3.delete_location_extra_info_a
     (p_location_extra_info_id  => p_location_extra_info_id,
      p_object_version_number   => p_object_version_number
     );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
           (p_module_name  => 'DELETE_LOCATION_EXTRA_INFO',
            p_hook_type   => 'AP'
           );
  end;
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
    ROLLBACK TO delete_location_extra_info;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO delete_location_extra_info;
  --
  raise;
  --
end delete_location_extra_info;
--
end hr_location_extra_info_api;

/
