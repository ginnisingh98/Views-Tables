--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_EIT_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_EIT_MIG" as
/* $Header: pyeeimpi.pkb 120.0 2005/12/16 14:59:34 ndorai noship $ */
--
-- Package Variables
--
g_debug boolean := hr_utility.debug_enabled;
g_package  varchar2(33) := '  pay_element_eit_mig.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_element_extra_info >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_element_extra_info
  (p_validate                     in     boolean  default false
  ,p_element_type_id              in     number
  ,p_information_type             in     varchar2
  ,p_eei_attribute_category       in     varchar2 default null
  ,p_eei_attribute1               in     varchar2 default null
  ,p_eei_attribute2               in     varchar2 default null
  ,p_eei_attribute3               in     varchar2 default null
  ,p_eei_attribute4               in     varchar2 default null
  ,p_eei_attribute5               in     varchar2 default null
  ,p_eei_attribute6               in     varchar2 default null
  ,p_eei_attribute7               in     varchar2 default null
  ,p_eei_attribute8               in     varchar2 default null
  ,p_eei_attribute9               in     varchar2 default null
  ,p_eei_attribute10              in     varchar2 default null
  ,p_eei_attribute11              in     varchar2 default null
  ,p_eei_attribute12              in     varchar2 default null
  ,p_eei_attribute13              in     varchar2 default null
  ,p_eei_attribute14              in     varchar2 default null
  ,p_eei_attribute15              in     varchar2 default null
  ,p_eei_attribute16              in     varchar2 default null
  ,p_eei_attribute17              in     varchar2 default null
  ,p_eei_attribute18              in     varchar2 default null
  ,p_eei_attribute19              in     varchar2 default null
  ,p_eei_attribute20              in     varchar2 default null
  ,p_eei_information_category     in     varchar2 default null
  ,p_eei_information1             in     varchar2 default null
  ,p_eei_information2             in     varchar2 default null
  ,p_eei_information3             in     varchar2 default null
  ,p_eei_information4             in     varchar2 default null
  ,p_eei_information5             in     varchar2 default null
  ,p_eei_information6             in     varchar2 default null
  ,p_eei_information7             in     varchar2 default null
  ,p_eei_information8             in     varchar2 default null
  ,p_eei_information9             in     varchar2 default null
  ,p_eei_information10            in     varchar2 default null
  ,p_eei_information11            in     varchar2 default null
  ,p_eei_information12            in     varchar2 default null
  ,p_eei_information13            in     varchar2 default null
  ,p_eei_information14            in     varchar2 default null
  ,p_eei_information15            in     varchar2 default null
  ,p_eei_information16            in     varchar2 default null
  ,p_eei_information17            in     varchar2 default null
  ,p_eei_information18            in     varchar2 default null
  ,p_eei_information19            in     varchar2 default null
  ,p_eei_information20            in     varchar2 default null
  ,p_eei_information21            in     varchar2 default null
  ,p_eei_information22            in     varchar2 default null
  ,p_eei_information23            in     varchar2 default null
  ,p_eei_information24            in     varchar2 default null
  ,p_eei_information25            in     varchar2 default null
  ,p_eei_information26            in     varchar2 default null
  ,p_eei_information27            in     varchar2 default null
  ,p_eei_information28            in     varchar2 default null
  ,p_eei_information29            in     varchar2 default null
  ,p_eei_information30            in     varchar2 default null
  ,p_element_type_extra_info_id       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'create_element_extra_info';
  l_object_version_number      pay_element_type_extra_info.object_version_number%type;
  l_element_type_extra_info_id pay_element_type_extra_info.element_type_extra_info_id%type;
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint create_element_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_element_extra_info_bk1.create_element_extra_info_b
     (p_information_type          => p_information_type,
      p_element_type_id           => p_element_type_id,
      p_eei_attribute_category    => p_eei_attribute_category,
      p_eei_attribute1            => p_eei_attribute1,
      p_eei_attribute2            => p_eei_attribute2,
      p_eei_attribute3            => p_eei_attribute3,
      p_eei_attribute4            => p_eei_attribute4,
      p_eei_attribute5            => p_eei_attribute5,
      p_eei_attribute6            => p_eei_attribute6,
      p_eei_attribute7            => p_eei_attribute7,
      p_eei_attribute8            => p_eei_attribute8,
      p_eei_attribute9            => p_eei_attribute9,
      p_eei_attribute10           => p_eei_attribute10,
      p_eei_attribute11           => p_eei_attribute11,
      p_eei_attribute12           => p_eei_attribute12,
      p_eei_attribute13           => p_eei_attribute13,
      p_eei_attribute14           => p_eei_attribute14,
      p_eei_attribute15           => p_eei_attribute15,
      p_eei_attribute16           => p_eei_attribute16,
      p_eei_attribute17           => p_eei_attribute17,
      p_eei_attribute18           => p_eei_attribute18,
      p_eei_attribute19           => p_eei_attribute19,
      p_eei_attribute20           => p_eei_attribute20,
      p_eei_information_category  => p_eei_information_category,
      p_eei_information1          => p_eei_information1,
      p_eei_information2          => p_eei_information2,
      p_eei_information3          => p_eei_information3,
      p_eei_information4          => p_eei_information4,
      p_eei_information5          => p_eei_information5,
      p_eei_information6          => p_eei_information6,
      p_eei_information7          => p_eei_information7,
      p_eei_information8          => p_eei_information8,
      p_eei_information9          => p_eei_information9,
      p_eei_information10         => p_eei_information10,
      p_eei_information11         => p_eei_information11,
      p_eei_information12         => p_eei_information12,
      p_eei_information13         => p_eei_information13,
      p_eei_information14         => p_eei_information14,
      p_eei_information15         => p_eei_information15,
      p_eei_information16         => p_eei_information16,
      p_eei_information17         => p_eei_information17,
      p_eei_information18         => p_eei_information18,
      p_eei_information19         => p_eei_information19,
      p_eei_information20         => p_eei_information20,
      p_eei_information21         => p_eei_information21,
      p_eei_information22         => p_eei_information22,
      p_eei_information23         => p_eei_information23,
      p_eei_information24         => p_eei_information24,
      p_eei_information25         => p_eei_information25,
      p_eei_information26         => p_eei_information26,
      p_eei_information27         => p_eei_information27,
      p_eei_information28         => p_eei_information28,
      p_eei_information29         => p_eei_information29,
      p_eei_information30         => p_eei_information30
      );
      exception
        when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
         (p_module_name => 'CREATE_ELEMENT_EXTRA_INFO',
          p_hook_type   => 'BP'
         );
  end;
  --
  -- End of Before Process User Hook call
  --
  --
  if g_debug then
     hr_utility.set_location(l_proc, 7);
  end if;
  --
  -- Process Logic
  --
  pay_eei_mig_ins.ins
  (p_element_type_extra_info_id   => l_element_type_extra_info_id
  ,p_element_type_id              => p_element_type_id
  ,p_information_type             => p_information_type
  ,p_eei_attribute_category       => p_eei_attribute_category
  ,p_eei_attribute1               => p_eei_attribute1
  ,p_eei_attribute2               => p_eei_attribute2
  ,p_eei_attribute3               => p_eei_attribute3
  ,p_eei_attribute4               => p_eei_attribute4
  ,p_eei_attribute5               => p_eei_attribute5
  ,p_eei_attribute6               => p_eei_attribute6
  ,p_eei_attribute7               => p_eei_attribute7
  ,p_eei_attribute8               => p_eei_attribute8
  ,p_eei_attribute9               => p_eei_attribute9
  ,p_eei_attribute10              => p_eei_attribute10
  ,p_eei_attribute11              => p_eei_attribute11
  ,p_eei_attribute12              => p_eei_attribute12
  ,p_eei_attribute13              => p_eei_attribute13
  ,p_eei_attribute14              => p_eei_attribute14
  ,p_eei_attribute15              => p_eei_attribute15
  ,p_eei_attribute16              => p_eei_attribute16
  ,p_eei_attribute17              => p_eei_attribute17
  ,p_eei_attribute18              => p_eei_attribute18
  ,p_eei_attribute19              => p_eei_attribute19
  ,p_eei_attribute20              => p_eei_attribute20
  ,p_eei_information_category     => p_eei_information_category
  ,p_eei_information1             => p_eei_information1
  ,p_eei_information2             => p_eei_information2
  ,p_eei_information3             => p_eei_information3
  ,p_eei_information4             => p_eei_information4
  ,p_eei_information5             => p_eei_information5
  ,p_eei_information6             => p_eei_information6
  ,p_eei_information7             => p_eei_information7
  ,p_eei_information8             => p_eei_information8
  ,p_eei_information9             => p_eei_information9
  ,p_eei_information10            => p_eei_information10
  ,p_eei_information11            => p_eei_information11
  ,p_eei_information12            => p_eei_information12
  ,p_eei_information13            => p_eei_information13
  ,p_eei_information14            => p_eei_information14
  ,p_eei_information15            => p_eei_information15
  ,p_eei_information16            => p_eei_information16
  ,p_eei_information17            => p_eei_information17
  ,p_eei_information18            => p_eei_information18
  ,p_eei_information19            => p_eei_information19
  ,p_eei_information20            => p_eei_information20
  ,p_eei_information21            => p_eei_information21
  ,p_eei_information22            => p_eei_information22
  ,p_eei_information23            => p_eei_information23
  ,p_eei_information24            => p_eei_information24
  ,p_eei_information25            => p_eei_information25
  ,p_eei_information26            => p_eei_information26
  ,p_eei_information27            => p_eei_information27
  ,p_eei_information28            => p_eei_information28
  ,p_eei_information29            => p_eei_information29
  ,p_eei_information30            => p_eei_information30
  ,p_object_version_number        => l_object_version_number
  );
  p_object_version_number       := l_object_version_number;
  p_element_type_extra_info_id  := l_element_type_extra_info_id;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 8);
  end if;
  --
  --
  -- Call After Process User Hook
  --
  begin
    pay_element_extra_info_bk1.create_element_extra_info_a
     (p_element_type_extra_info_id => l_element_type_extra_info_id,
      p_information_type          => p_information_type,
      p_element_type_id           => p_element_type_id,
      p_eei_attribute_category    => p_eei_attribute_category,
      p_eei_attribute1            => p_eei_attribute1,
      p_eei_attribute2            => p_eei_attribute2,
      p_eei_attribute3            => p_eei_attribute3,
      p_eei_attribute4            => p_eei_attribute4,
      p_eei_attribute5            => p_eei_attribute5,
      p_eei_attribute6            => p_eei_attribute6,
      p_eei_attribute7            => p_eei_attribute7,
      p_eei_attribute8            => p_eei_attribute8,
      p_eei_attribute9            => p_eei_attribute9,
      p_eei_attribute10           => p_eei_attribute10,
      p_eei_attribute11           => p_eei_attribute11,
      p_eei_attribute12           => p_eei_attribute12,
      p_eei_attribute13           => p_eei_attribute13,
      p_eei_attribute14           => p_eei_attribute14,
      p_eei_attribute15           => p_eei_attribute15,
      p_eei_attribute16           => p_eei_attribute16,
      p_eei_attribute17           => p_eei_attribute17,
      p_eei_attribute18           => p_eei_attribute18,
      p_eei_attribute19           => p_eei_attribute19,
      p_eei_attribute20           => p_eei_attribute20,
      p_eei_information_category  => p_eei_information_category,
      p_eei_information1          => p_eei_information1,
      p_eei_information2          => p_eei_information2,
      p_eei_information3          => p_eei_information3,
      p_eei_information4          => p_eei_information4,
      p_eei_information5          => p_eei_information5,
      p_eei_information6          => p_eei_information6,
      p_eei_information7          => p_eei_information7,
      p_eei_information8          => p_eei_information8,
      p_eei_information9          => p_eei_information9,
      p_eei_information10         => p_eei_information10,
      p_eei_information11         => p_eei_information11,
      p_eei_information12         => p_eei_information12,
      p_eei_information13         => p_eei_information13,
      p_eei_information14         => p_eei_information14,
      p_eei_information15         => p_eei_information15,
      p_eei_information16         => p_eei_information16,
      p_eei_information17         => p_eei_information17,
      p_eei_information18         => p_eei_information18,
      p_eei_information19         => p_eei_information19,
      p_eei_information20         => p_eei_information20,
      p_eei_information21         => p_eei_information21,
      p_eei_information22         => p_eei_information22,
      p_eei_information23         => p_eei_information23,
      p_eei_information24         => p_eei_information24,
      p_eei_information25         => p_eei_information25,
      p_eei_information26         => p_eei_information26,
      p_eei_information27         => p_eei_information27,
      p_eei_information28         => p_eei_information28,
      p_eei_information29         => p_eei_information29,
      p_eei_information30         => p_eei_information30,
      p_object_version_number     => l_object_version_number
      );
      exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'CREATE_ELEMENT_EXTRA_INFO',
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
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 11);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_element_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_element_type_extra_info_id := null;
    p_object_version_number  := null;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 12);
    end if;
  --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO create_element_extra_info;
  p_element_type_extra_info_id := null;
  p_object_version_number  := null;
  --
  raise;
  --
end create_element_extra_info;
--
-- ----------------------------------------------------------------------------
-- |-----------------< update_element_extra_info >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_element_extra_info
  (p_validate                     in     boolean  default false
  ,p_element_type_extra_info_id   in     number
  ,p_object_version_number        in out nocopy number
  ,p_eei_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_eei_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_eei_information1             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information2             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information3             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information4             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information5             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information6             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information7             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information8             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information9             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information10            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information11            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information12            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information13            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information14            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information15            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information16            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information17            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information18            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information19            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information20            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information21            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information22            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information23            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information24            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information25            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information26            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information27            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information28            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information29            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information30            in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_element_extra_info';
  l_object_version_number pay_element_type_extra_info.object_version_number%TYPE;
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint update_element_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_element_extra_info_bk2.update_element_extra_info_b
     (p_element_type_extra_info_id => p_element_type_extra_info_id,
      p_eei_attribute_category    => p_eei_attribute_category,
      p_eei_attribute1            => p_eei_attribute1,
      p_eei_attribute2            => p_eei_attribute2,
      p_eei_attribute3            => p_eei_attribute3,
      p_eei_attribute4            => p_eei_attribute4,
      p_eei_attribute5            => p_eei_attribute5,
      p_eei_attribute6            => p_eei_attribute6,
      p_eei_attribute7            => p_eei_attribute7,
      p_eei_attribute8            => p_eei_attribute8,
      p_eei_attribute9            => p_eei_attribute9,
      p_eei_attribute10           => p_eei_attribute10,
      p_eei_attribute11           => p_eei_attribute11,
      p_eei_attribute12           => p_eei_attribute12,
      p_eei_attribute13           => p_eei_attribute13,
      p_eei_attribute14           => p_eei_attribute14,
      p_eei_attribute15           => p_eei_attribute15,
      p_eei_attribute16           => p_eei_attribute16,
      p_eei_attribute17           => p_eei_attribute17,
      p_eei_attribute18           => p_eei_attribute18,
      p_eei_attribute19           => p_eei_attribute19,
      p_eei_attribute20           => p_eei_attribute20,
      p_eei_information_category  => p_eei_information_category,
      p_eei_information1          => p_eei_information1,
      p_eei_information2          => p_eei_information2,
      p_eei_information3          => p_eei_information3,
      p_eei_information4          => p_eei_information4,
      p_eei_information5          => p_eei_information5,
      p_eei_information6          => p_eei_information6,
      p_eei_information7          => p_eei_information7,
      p_eei_information8          => p_eei_information8,
      p_eei_information9          => p_eei_information9,
      p_eei_information10         => p_eei_information10,
      p_eei_information11         => p_eei_information11,
      p_eei_information12         => p_eei_information12,
      p_eei_information13         => p_eei_information13,
      p_eei_information14         => p_eei_information14,
      p_eei_information15         => p_eei_information15,
      p_eei_information16         => p_eei_information16,
      p_eei_information17         => p_eei_information17,
      p_eei_information18         => p_eei_information18,
      p_eei_information19         => p_eei_information19,
      p_eei_information20         => p_eei_information20,
      p_eei_information21         => p_eei_information21,
      p_eei_information22         => p_eei_information22,
      p_eei_information23         => p_eei_information23,
      p_eei_information24         => p_eei_information24,
      p_eei_information25         => p_eei_information25,
      p_eei_information26         => p_eei_information26,
      p_eei_information27         => p_eei_information27,
      p_eei_information28         => p_eei_information28,
      p_eei_information29         => p_eei_information29,
      p_eei_information30         => p_eei_information30,
      p_object_version_number     => p_object_version_number
      );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
           (p_module_name => 'UPDATE_ELEMENT_EXTRA_INFO',
           p_hook_type    => 'BP'
           );
  end;
  --
  -- End of Before Process User Hook call
  --
  --
  if g_debug then
     hr_utility.set_location(l_proc, 7);
  end if;
  --
  -- Store the original ovn in case we rollback when p_validate is true
  --
  l_object_version_number  := p_object_version_number;
  --
  -- Process Logic - Update elementExtra Info details
  --
  pay_eei_mig_upd.upd
  (p_element_type_extra_info_id   => p_element_type_extra_info_id
  ,p_eei_attribute_category       => p_eei_attribute_category
  ,p_eei_attribute1               => p_eei_attribute1
  ,p_eei_attribute2               => p_eei_attribute2
  ,p_eei_attribute3               => p_eei_attribute3
  ,p_eei_attribute4               => p_eei_attribute4
  ,p_eei_attribute5               => p_eei_attribute5
  ,p_eei_attribute6               => p_eei_attribute6
  ,p_eei_attribute7               => p_eei_attribute7
  ,p_eei_attribute8               => p_eei_attribute8
  ,p_eei_attribute9               => p_eei_attribute9
  ,p_eei_attribute10              => p_eei_attribute10
  ,p_eei_attribute11              => p_eei_attribute11
  ,p_eei_attribute12              => p_eei_attribute12
  ,p_eei_attribute13              => p_eei_attribute13
  ,p_eei_attribute14              => p_eei_attribute14
  ,p_eei_attribute15              => p_eei_attribute15
  ,p_eei_attribute16              => p_eei_attribute16
  ,p_eei_attribute17              => p_eei_attribute17
  ,p_eei_attribute18              => p_eei_attribute18
  ,p_eei_attribute19              => p_eei_attribute19
  ,p_eei_attribute20              => p_eei_attribute20
  ,p_eei_information_category     => p_eei_information_category
  ,p_eei_information1             => p_eei_information1
  ,p_eei_information2             => p_eei_information2
  ,p_eei_information3             => p_eei_information3
  ,p_eei_information4             => p_eei_information4
  ,p_eei_information5             => p_eei_information5
  ,p_eei_information6             => p_eei_information6
  ,p_eei_information7             => p_eei_information7
  ,p_eei_information8             => p_eei_information8
  ,p_eei_information9             => p_eei_information9
  ,p_eei_information10            => p_eei_information10
  ,p_eei_information11            => p_eei_information11
  ,p_eei_information12            => p_eei_information12
  ,p_eei_information13            => p_eei_information13
  ,p_eei_information14            => p_eei_information14
  ,p_eei_information15            => p_eei_information15
  ,p_eei_information16            => p_eei_information16
  ,p_eei_information17            => p_eei_information17
  ,p_eei_information18            => p_eei_information18
  ,p_eei_information19            => p_eei_information19
  ,p_eei_information20            => p_eei_information20
  ,p_eei_information21            => p_eei_information21
  ,p_eei_information22            => p_eei_information22
  ,p_eei_information23            => p_eei_information23
  ,p_eei_information24            => p_eei_information24
  ,p_eei_information25            => p_eei_information25
  ,p_eei_information26            => p_eei_information26
  ,p_eei_information27            => p_eei_information27
  ,p_eei_information28            => p_eei_information28
  ,p_eei_information29            => p_eei_information29
  ,p_eei_information30            => p_eei_information30
  ,p_object_version_number        => p_object_version_number
  );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 8);
  end if;
  --
  --
  -- Call After Process User Hook
  --
  begin
    pay_element_extra_info_bk2.update_element_extra_info_a
     (p_element_type_extra_info_id => p_element_type_extra_info_id,
      p_eei_attribute_category    => p_eei_attribute_category,
      p_eei_attribute1            => p_eei_attribute1,
      p_eei_attribute2            => p_eei_attribute2,
      p_eei_attribute3            => p_eei_attribute3,
      p_eei_attribute4            => p_eei_attribute4,
      p_eei_attribute5            => p_eei_attribute5,
      p_eei_attribute6            => p_eei_attribute6,
      p_eei_attribute7            => p_eei_attribute7,
      p_eei_attribute8            => p_eei_attribute8,
      p_eei_attribute9            => p_eei_attribute9,
      p_eei_attribute10           => p_eei_attribute10,
      p_eei_attribute11           => p_eei_attribute11,
      p_eei_attribute12           => p_eei_attribute12,
      p_eei_attribute13           => p_eei_attribute13,
      p_eei_attribute14           => p_eei_attribute14,
      p_eei_attribute15           => p_eei_attribute15,
      p_eei_attribute16           => p_eei_attribute16,
      p_eei_attribute17           => p_eei_attribute17,
      p_eei_attribute18           => p_eei_attribute18,
      p_eei_attribute19           => p_eei_attribute19,
      p_eei_attribute20           => p_eei_attribute20,
      p_eei_information_category  => p_eei_information_category,
      p_eei_information1          => p_eei_information1,
      p_eei_information2          => p_eei_information2,
      p_eei_information3          => p_eei_information3,
      p_eei_information4          => p_eei_information4,
      p_eei_information5          => p_eei_information5,
      p_eei_information6          => p_eei_information6,
      p_eei_information7          => p_eei_information7,
      p_eei_information8          => p_eei_information8,
      p_eei_information9          => p_eei_information9,
      p_eei_information10         => p_eei_information10,
      p_eei_information11         => p_eei_information11,
      p_eei_information12         => p_eei_information12,
      p_eei_information13         => p_eei_information13,
      p_eei_information14         => p_eei_information14,
      p_eei_information15         => p_eei_information15,
      p_eei_information16         => p_eei_information16,
      p_eei_information17         => p_eei_information17,
      p_eei_information18         => p_eei_information18,
      p_eei_information19         => p_eei_information19,
      p_eei_information20         => p_eei_information20,
      p_eei_information21         => p_eei_information21,
      p_eei_information22         => p_eei_information22,
      p_eei_information23         => p_eei_information23,
      p_eei_information24         => p_eei_information24,
      p_eei_information25         => p_eei_information25,
      p_eei_information26         => p_eei_information26,
      p_eei_information27         => p_eei_information27,
      p_eei_information28         => p_eei_information28,
      p_eei_information29         => p_eei_information29,
      p_eei_information30         => p_eei_information30,
      p_object_version_number     => p_object_version_number
      );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
           (p_module_name => 'UPDATE_ELEMENT_EXTRA_INFO',
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
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 11);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_element_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 12);
    end if;
  --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO update_element_extra_info;
  p_object_version_number  := l_object_version_number;
  --
  raise;
  --
end update_element_extra_info;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_element_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_element_extra_info
  (p_validate                      in     boolean  default false
  ,p_element_type_extra_info_id    in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_element_extra_info';
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint delete_element_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_element_extra_info_bk3.delete_element_extra_info_b
     (p_element_type_extra_info_id => p_element_type_extra_info_id,
      p_object_version_number => p_object_version_number
     );
     exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
          (p_module_name => 'DELETE_ELEMENT_EXTRA_INFO',
           p_hook_type   => 'BP'
          );
  end;
  --
  --
  if g_debug then
     hr_utility.set_location(l_proc, 7);
  end if;
  --
  -- Process Logic - Delete element Extra Info details
  --
  pay_eei_mig_del.del
  (p_element_type_extra_info_id    => p_element_type_extra_info_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 8);
  end if;
  --
  --
  -- Call After Process User Hook
  --
  begin
    pay_element_extra_info_bk3.delete_element_extra_info_a
     (p_element_type_extra_info_id  => p_element_type_extra_info_id,
      p_object_version_number   => p_object_version_number
     );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
           (p_module_name  => 'DELETE_ELEMENT_EXTRA_INFO',
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
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 11);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_element_extra_info;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 12);
    end if;
  --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO delete_element_extra_info;
  --
  raise;
  --
end delete_element_extra_info;
--
end pay_element_eit_mig;

/
