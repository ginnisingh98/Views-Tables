--------------------------------------------------------
--  DDL for Package Body HR_POSITION_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_POSITION_EXTRA_INFO_API" as
/* $Header: pepoiapi.pkb 120.0.12010000.1 2008/07/28 05:23:20 appldev ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_position_extra_info_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_position_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_position_extra_info
  (p_validate                      in     boolean  default false
  ,p_position_id                   in     number
  ,p_information_type              in     varchar2
  ,p_poei_attribute_category       in     varchar2 default null
  ,p_poei_attribute1               in     varchar2 default null
  ,p_poei_attribute2               in     varchar2 default null
  ,p_poei_attribute3               in     varchar2 default null
  ,p_poei_attribute4               in     varchar2 default null
  ,p_poei_attribute5               in     varchar2 default null
  ,p_poei_attribute6               in     varchar2 default null
  ,p_poei_attribute7               in     varchar2 default null
  ,p_poei_attribute8               in     varchar2 default null
  ,p_poei_attribute9               in     varchar2 default null
  ,p_poei_attribute10              in     varchar2 default null
  ,p_poei_attribute11              in     varchar2 default null
  ,p_poei_attribute12              in     varchar2 default null
  ,p_poei_attribute13              in     varchar2 default null
  ,p_poei_attribute14              in     varchar2 default null
  ,p_poei_attribute15              in     varchar2 default null
  ,p_poei_attribute16              in     varchar2 default null
  ,p_poei_attribute17              in     varchar2 default null
  ,p_poei_attribute18              in     varchar2 default null
  ,p_poei_attribute19              in     varchar2 default null
  ,p_poei_attribute20              in     varchar2 default null
  ,p_poei_information_category     in     varchar2 default null
  ,p_poei_information1             in     varchar2 default null
  ,p_poei_information2             in     varchar2 default null
  ,p_poei_information3             in     varchar2 default null
  ,p_poei_information4             in     varchar2 default null
  ,p_poei_information5             in     varchar2 default null
  ,p_poei_information6             in     varchar2 default null
  ,p_poei_information7             in     varchar2 default null
  ,p_poei_information8             in     varchar2 default null
  ,p_poei_information9             in     varchar2 default null
  ,p_poei_information10            in     varchar2 default null
  ,p_poei_information11            in     varchar2 default null
  ,p_poei_information12            in     varchar2 default null
  ,p_poei_information13            in     varchar2 default null
  ,p_poei_information14            in     varchar2 default null
  ,p_poei_information15            in     varchar2 default null
  ,p_poei_information16            in     varchar2 default null
  ,p_poei_information17            in     varchar2 default null
  ,p_poei_information18            in     varchar2 default null
  ,p_poei_information19            in     varchar2 default null
  ,p_poei_information20            in     varchar2 default null
  ,p_poei_information21            in     varchar2 default null
  ,p_poei_information22            in     varchar2 default null
  ,p_poei_information23            in     varchar2 default null
  ,p_poei_information24            in     varchar2 default null
  ,p_poei_information25            in     varchar2 default null
  ,p_poei_information26            in     varchar2 default null
  ,p_poei_information27            in     varchar2 default null
  ,p_poei_information28            in     varchar2 default null
  ,p_poei_information29            in     varchar2 default null
  ,p_poei_information30            in     varchar2 default null
  ,p_position_extra_info_id           out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_position_extra_info';
  l_object_version_number		per_position_extra_info.object_version_number%type;
  l_position_extra_info_id		per_position_extra_info.position_extra_info_id%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint create_position_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
	hr_position_extra_info_bk1.create_position_extra_info_b
		(
		p_position_id			=>	p_position_id,
		p_information_type		=>	p_information_type,
		p_poei_attribute_category	=>	p_poei_attribute_category,
		p_poei_attribute1		=>	p_poei_attribute1,
		p_poei_attribute2		=>	p_poei_attribute2,
		p_poei_attribute3		=>	p_poei_attribute3,
		p_poei_attribute4		=>	p_poei_attribute4,
		p_poei_attribute5		=>	p_poei_attribute5,
		p_poei_attribute6		=>	p_poei_attribute6,
		p_poei_attribute7		=>	p_poei_attribute7,
		p_poei_attribute8		=>	p_poei_attribute8,
		p_poei_attribute9		=>	p_poei_attribute9,
		p_poei_attribute10		=>	p_poei_attribute10,
		p_poei_attribute11		=>	p_poei_attribute11,
		p_poei_attribute12		=>	p_poei_attribute12,
		p_poei_attribute13		=>	p_poei_attribute13,
		p_poei_attribute14		=>	p_poei_attribute14,
		p_poei_attribute15		=>	p_poei_attribute15,
		p_poei_attribute16		=>	p_poei_attribute16,
		p_poei_attribute17		=>	p_poei_attribute17,
		p_poei_attribute18		=>	p_poei_attribute18,
		p_poei_attribute19		=>	p_poei_attribute19,
		p_poei_attribute20		=>	p_poei_attribute20,
		p_poei_information_category	=>	p_poei_information_category,
		p_poei_information1		=>	p_poei_information1,
		p_poei_information2		=>	p_poei_information2,
		p_poei_information3		=>	p_poei_information3,
		p_poei_information4		=>	p_poei_information4,
		p_poei_information5		=>	p_poei_information5,
		p_poei_information6		=>	p_poei_information6,
		p_poei_information7		=>	p_poei_information7,
		p_poei_information8		=>	p_poei_information8,
		p_poei_information9		=>	p_poei_information9,
		p_poei_information10		=>	p_poei_information10,
		p_poei_information11		=>	p_poei_information11,
		p_poei_information12		=>	p_poei_information12,
		p_poei_information13		=>	p_poei_information13,
		p_poei_information14		=>	p_poei_information14,
		p_poei_information15		=>	p_poei_information15,
		p_poei_information16		=>	p_poei_information16,
		p_poei_information17		=>	p_poei_information17,
		p_poei_information18		=>	p_poei_information18,
		p_poei_information19		=>	p_poei_information19,
		p_poei_information20		=>	p_poei_information20,
		p_poei_information21		=>	p_poei_information21,
		p_poei_information22		=>	p_poei_information22,
		p_poei_information23		=>	p_poei_information23,
		p_poei_information24		=>	p_poei_information24,
		p_poei_information25		=>	p_poei_information25,
		p_poei_information26		=>	p_poei_information26,
		p_poei_information27		=>	p_poei_information27,
		p_poei_information28		=>	p_poei_information28,
		p_poei_information29		=>	p_poei_information29,
		p_poei_information30		=>	p_poei_information30
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_location_extra_info',
				 p_hook_type	=> 'BP'
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
  pe_poi_ins.ins
  (p_position_extra_info_id        => l_position_extra_info_id
  ,p_position_id                   => p_position_id
  ,p_information_type              => p_information_type
  ,p_poei_attribute_category       => p_poei_attribute_category
  ,p_poei_attribute1               => p_poei_attribute1
  ,p_poei_attribute2               => p_poei_attribute2
  ,p_poei_attribute3               => p_poei_attribute3
  ,p_poei_attribute4               => p_poei_attribute4
  ,p_poei_attribute5               => p_poei_attribute5
  ,p_poei_attribute6               => p_poei_attribute6
  ,p_poei_attribute7               => p_poei_attribute7
  ,p_poei_attribute8               => p_poei_attribute8
  ,p_poei_attribute9               => p_poei_attribute9
  ,p_poei_attribute10              => p_poei_attribute10
  ,p_poei_attribute11              => p_poei_attribute11
  ,p_poei_attribute12              => p_poei_attribute12
  ,p_poei_attribute13              => p_poei_attribute13
  ,p_poei_attribute14              => p_poei_attribute14
  ,p_poei_attribute15              => p_poei_attribute15
  ,p_poei_attribute16              => p_poei_attribute16
  ,p_poei_attribute17              => p_poei_attribute17
  ,p_poei_attribute18              => p_poei_attribute18
  ,p_poei_attribute19              => p_poei_attribute19
  ,p_poei_attribute20              => p_poei_attribute20
  ,p_poei_information_category     => p_poei_information_category
  ,p_poei_information1             => p_poei_information1
  ,p_poei_information2             => p_poei_information2
  ,p_poei_information3             => p_poei_information3
  ,p_poei_information4             => p_poei_information4
  ,p_poei_information5             => p_poei_information5
  ,p_poei_information6             => p_poei_information6
  ,p_poei_information7             => p_poei_information7
  ,p_poei_information8             => p_poei_information8
  ,p_poei_information9             => p_poei_information9
  ,p_poei_information10            => p_poei_information10
  ,p_poei_information11            => p_poei_information11
  ,p_poei_information12            => p_poei_information12
  ,p_poei_information13            => p_poei_information13
  ,p_poei_information14            => p_poei_information14
  ,p_poei_information15            => p_poei_information15
  ,p_poei_information16            => p_poei_information16
  ,p_poei_information17            => p_poei_information17
  ,p_poei_information18            => p_poei_information18
  ,p_poei_information19            => p_poei_information19
  ,p_poei_information20            => p_poei_information20
  ,p_poei_information21            => p_poei_information21
  ,p_poei_information22            => p_poei_information22
  ,p_poei_information23            => p_poei_information23
  ,p_poei_information24            => p_poei_information24
  ,p_poei_information25            => p_poei_information25
  ,p_poei_information26            => p_poei_information26
  ,p_poei_information27            => p_poei_information27
  ,p_poei_information28            => p_poei_information28
  ,p_poei_information29            => p_poei_information29
  ,p_poei_information30            => p_poei_information30
  ,p_object_version_number         => l_object_version_number
  ,p_validate                      => false
  );
  p_object_version_number    := l_object_version_number;
  p_position_extra_info_id   := l_position_extra_info_id;
  --
  hr_utility.set_location(l_proc, 8);
  -- Call After Process User Hook
  --
  begin
	hr_position_extra_info_bk1.create_position_extra_info_a
		(
		p_position_extra_info_id	=>	l_position_extra_info_id,
		p_object_version_number		=>	l_object_version_number,
		p_position_id			=>	p_position_id,
		p_information_type		=>	p_information_type,
		p_poei_attribute_category	=>	p_poei_attribute_category,
		p_poei_attribute1		=>	p_poei_attribute1,
		p_poei_attribute2		=>	p_poei_attribute2,
		p_poei_attribute3		=>	p_poei_attribute3,
		p_poei_attribute4		=>	p_poei_attribute4,
		p_poei_attribute5		=>	p_poei_attribute5,
		p_poei_attribute6		=>	p_poei_attribute6,
		p_poei_attribute7		=>	p_poei_attribute7,
		p_poei_attribute8		=>	p_poei_attribute8,
		p_poei_attribute9		=>	p_poei_attribute9,
		p_poei_attribute10		=>	p_poei_attribute10,
		p_poei_attribute11		=>	p_poei_attribute11,
		p_poei_attribute12		=>	p_poei_attribute12,
		p_poei_attribute13		=>	p_poei_attribute13,
		p_poei_attribute14		=>	p_poei_attribute14,
		p_poei_attribute15		=>	p_poei_attribute15,
		p_poei_attribute16		=>	p_poei_attribute16,
		p_poei_attribute17		=>	p_poei_attribute17,
		p_poei_attribute18		=>	p_poei_attribute18,
		p_poei_attribute19		=>	p_poei_attribute19,
		p_poei_attribute20		=>	p_poei_attribute20,
		p_poei_information_category	=>	p_poei_information_category,
		p_poei_information1		=>	p_poei_information1,
		p_poei_information2		=>	p_poei_information2,
		p_poei_information3		=>	p_poei_information3,
		p_poei_information4		=>	p_poei_information4,
		p_poei_information5		=>	p_poei_information5,
		p_poei_information6		=>	p_poei_information6,
		p_poei_information7		=>	p_poei_information7,
		p_poei_information8		=>	p_poei_information8,
		p_poei_information9		=>	p_poei_information9,
		p_poei_information10		=>	p_poei_information10,
		p_poei_information11		=>	p_poei_information11,
		p_poei_information12		=>	p_poei_information12,
		p_poei_information13		=>	p_poei_information13,
		p_poei_information14		=>	p_poei_information14,
		p_poei_information15		=>	p_poei_information15,
		p_poei_information16		=>	p_poei_information16,
		p_poei_information17		=>	p_poei_information17,
		p_poei_information18		=>	p_poei_information18,
		p_poei_information19		=>	p_poei_information19,
		p_poei_information20		=>	p_poei_information20,
		p_poei_information21		=>	p_poei_information21,
		p_poei_information22		=>	p_poei_information22,
		p_poei_information23		=>	p_poei_information23,
		p_poei_information24		=>	p_poei_information24,
		p_poei_information25		=>	p_poei_information25,
		p_poei_information26		=>	p_poei_information26,
		p_poei_information27		=>	p_poei_information27,
		p_poei_information28		=>	p_poei_information28,
		p_poei_information29		=>	p_poei_information29,
		p_poei_information30		=>	p_poei_information30
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_position_extra_info',
				 p_hook_type	=> 'AP'
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
    ROLLBACK TO create_position_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_position_extra_info_id := null;
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
    p_position_extra_info_id := null;
    p_object_version_number  := null;
    ROLLBACK TO create_position_extra_info;
    --
    raise;
    --
end create_position_extra_info;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_position_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_position_extra_info
  (p_validate                      in     boolean  default false
  ,p_position_extra_info_id        in     number
  ,p_object_version_number         in out nocopy number
  ,p_poei_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_poei_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_poei_information1             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information2             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information3             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information4             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information5             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information6             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information7             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information8             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information9             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information10            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information11            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information12            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information13            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information14            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information15            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information16            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information17            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information18            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information19            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information20            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information21            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information22            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information23            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information24            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information25            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information26            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information27            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information28            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information29            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information30            in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_position_extra_info';
  l_object_version_number per_position_extra_info.object_version_number%TYPE;
  l_temp_ovn              number       := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint update_position_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
	hr_position_extra_info_bk2.update_position_extra_info_b
		(
		p_position_extra_info_id	=>	p_position_extra_info_id,
		p_poei_attribute_category	=>	p_poei_attribute_category,
		p_poei_attribute1		=>	p_poei_attribute1,
		p_poei_attribute2		=>	p_poei_attribute2,
		p_poei_attribute3		=>	p_poei_attribute3,
		p_poei_attribute4		=>	p_poei_attribute4,
		p_poei_attribute5		=>	p_poei_attribute5,
		p_poei_attribute6		=>	p_poei_attribute6,
		p_poei_attribute7		=>	p_poei_attribute7,
		p_poei_attribute8		=>	p_poei_attribute8,
		p_poei_attribute9		=>	p_poei_attribute9,
		p_poei_attribute10		=>	p_poei_attribute10,
		p_poei_attribute11		=>	p_poei_attribute11,
		p_poei_attribute12		=>	p_poei_attribute12,
		p_poei_attribute13		=>	p_poei_attribute13,
		p_poei_attribute14		=>	p_poei_attribute14,
		p_poei_attribute15		=>	p_poei_attribute15,
		p_poei_attribute16		=>	p_poei_attribute16,
		p_poei_attribute17		=>	p_poei_attribute17,
		p_poei_attribute18		=>	p_poei_attribute18,
		p_poei_attribute19		=>	p_poei_attribute19,
		p_poei_attribute20		=>	p_poei_attribute20,
		p_poei_information_category	=>	p_poei_information_category,
		p_poei_information1		=>	p_poei_information1,
		p_poei_information2		=>	p_poei_information2,
		p_poei_information3		=>	p_poei_information3,
		p_poei_information4		=>	p_poei_information4,
		p_poei_information5		=>	p_poei_information5,
		p_poei_information6		=>	p_poei_information6,
		p_poei_information7		=>	p_poei_information7,
		p_poei_information8		=>	p_poei_information8,
		p_poei_information9		=>	p_poei_information9,
		p_poei_information10		=>	p_poei_information10,
		p_poei_information11		=>	p_poei_information11,
		p_poei_information12		=>	p_poei_information12,
		p_poei_information13		=>	p_poei_information13,
		p_poei_information14		=>	p_poei_information14,
		p_poei_information15		=>	p_poei_information15,
		p_poei_information16		=>	p_poei_information16,
		p_poei_information17		=>	p_poei_information17,
		p_poei_information18		=>	p_poei_information18,
		p_poei_information19		=>	p_poei_information19,
		p_poei_information20		=>	p_poei_information20,
		p_poei_information21		=>	p_poei_information21,
		p_poei_information22		=>	p_poei_information22,
		p_poei_information23		=>	p_poei_information23,
		p_poei_information24		=>	p_poei_information24,
		p_poei_information25		=>	p_poei_information25,
		p_poei_information26		=>	p_poei_information26,
		p_poei_information27		=>	p_poei_information27,
		p_poei_information28		=>	p_poei_information28,
		p_poei_information29		=>	p_poei_information29,
		p_poei_information30		=>	p_poei_information30,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_position_extra_info',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Store the original ovn in case we rollback when p_validate is true
  --
  l_object_version_number  := p_object_version_number;
  --
  -- Process Logic - Update Position Extra Info details
  --
  pe_poi_upd.upd
  (p_position_extra_info_id        => p_position_extra_info_id
  ,p_poei_attribute_category       => p_poei_attribute_category
  ,p_poei_attribute1               => p_poei_attribute1
  ,p_poei_attribute2               => p_poei_attribute2
  ,p_poei_attribute3               => p_poei_attribute3
  ,p_poei_attribute4               => p_poei_attribute4
  ,p_poei_attribute5               => p_poei_attribute5
  ,p_poei_attribute6               => p_poei_attribute6
  ,p_poei_attribute7               => p_poei_attribute7
  ,p_poei_attribute8               => p_poei_attribute8
  ,p_poei_attribute9               => p_poei_attribute9
  ,p_poei_attribute10              => p_poei_attribute10
  ,p_poei_attribute11              => p_poei_attribute11
  ,p_poei_attribute12              => p_poei_attribute12
  ,p_poei_attribute13              => p_poei_attribute13
  ,p_poei_attribute14              => p_poei_attribute14
  ,p_poei_attribute15              => p_poei_attribute15
  ,p_poei_attribute16              => p_poei_attribute16
  ,p_poei_attribute17              => p_poei_attribute17
  ,p_poei_attribute18              => p_poei_attribute18
  ,p_poei_attribute19              => p_poei_attribute19
  ,p_poei_attribute20              => p_poei_attribute20
  ,p_poei_information_category     => p_poei_information_category
  ,p_poei_information1             => p_poei_information1
  ,p_poei_information2             => p_poei_information2
  ,p_poei_information3             => p_poei_information3
  ,p_poei_information4             => p_poei_information4
  ,p_poei_information5             => p_poei_information5
  ,p_poei_information6             => p_poei_information6
  ,p_poei_information7             => p_poei_information7
  ,p_poei_information8             => p_poei_information8
  ,p_poei_information9             => p_poei_information9
  ,p_poei_information10            => p_poei_information10
  ,p_poei_information11            => p_poei_information11
  ,p_poei_information12            => p_poei_information12
  ,p_poei_information13            => p_poei_information13
  ,p_poei_information14            => p_poei_information14
  ,p_poei_information15            => p_poei_information15
  ,p_poei_information16            => p_poei_information16
  ,p_poei_information17            => p_poei_information17
  ,p_poei_information18            => p_poei_information18
  ,p_poei_information19            => p_poei_information19
  ,p_poei_information20            => p_poei_information20
  ,p_poei_information21            => p_poei_information21
  ,p_poei_information22            => p_poei_information22
  ,p_poei_information23            => p_poei_information23
  ,p_poei_information24            => p_poei_information24
  ,p_poei_information25            => p_poei_information25
  ,p_poei_information26            => p_poei_information26
  ,p_poei_information27            => p_poei_information27
  ,p_poei_information28            => p_poei_information28
  ,p_poei_information29            => p_poei_information29
  ,p_poei_information30            => p_poei_information30
  ,p_object_version_number         => p_object_version_number
  ,p_validate                      => false
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_position_extra_info_bk2.update_position_extra_info_a
		(
		p_position_extra_info_id	=>	p_position_extra_info_id,
		p_poei_attribute_category	=>	p_poei_attribute_category,
		p_poei_attribute1		=>	p_poei_attribute1,
		p_poei_attribute2		=>	p_poei_attribute2,
		p_poei_attribute3		=>	p_poei_attribute3,
		p_poei_attribute4		=>	p_poei_attribute4,
		p_poei_attribute5		=>	p_poei_attribute5,
		p_poei_attribute6		=>	p_poei_attribute6,
		p_poei_attribute7		=>	p_poei_attribute7,
		p_poei_attribute8		=>	p_poei_attribute8,
		p_poei_attribute9		=>	p_poei_attribute9,
		p_poei_attribute10		=>	p_poei_attribute10,
		p_poei_attribute11		=>	p_poei_attribute11,
		p_poei_attribute12		=>	p_poei_attribute12,
		p_poei_attribute13		=>	p_poei_attribute13,
		p_poei_attribute14		=>	p_poei_attribute14,
		p_poei_attribute15		=>	p_poei_attribute15,
		p_poei_attribute16		=>	p_poei_attribute16,
		p_poei_attribute17		=>	p_poei_attribute17,
		p_poei_attribute18		=>	p_poei_attribute18,
		p_poei_attribute19		=>	p_poei_attribute19,
		p_poei_attribute20		=>	p_poei_attribute20,
		p_poei_information_category	=>	p_poei_information_category,
		p_poei_information1		=>	p_poei_information1,
		p_poei_information2		=>	p_poei_information2,
		p_poei_information3		=>	p_poei_information3,
		p_poei_information4		=>	p_poei_information4,
		p_poei_information5		=>	p_poei_information5,
		p_poei_information6		=>	p_poei_information6,
		p_poei_information7		=>	p_poei_information7,
		p_poei_information8		=>	p_poei_information8,
		p_poei_information9		=>	p_poei_information9,
		p_poei_information10		=>	p_poei_information10,
		p_poei_information11		=>	p_poei_information11,
		p_poei_information12		=>	p_poei_information12,
		p_poei_information13		=>	p_poei_information13,
		p_poei_information14		=>	p_poei_information14,
		p_poei_information15		=>	p_poei_information15,
		p_poei_information16		=>	p_poei_information16,
		p_poei_information17		=>	p_poei_information17,
		p_poei_information18		=>	p_poei_information18,
		p_poei_information19		=>	p_poei_information19,
		p_poei_information20		=>	p_poei_information20,
		p_poei_information21		=>	p_poei_information21,
		p_poei_information22		=>	p_poei_information22,
		p_poei_information23		=>	p_poei_information23,
		p_poei_information24		=>	p_poei_information24,
		p_poei_information25		=>	p_poei_information25,
		p_poei_information26		=>	p_poei_information26,
		p_poei_information27		=>	p_poei_information27,
		p_poei_information28		=>	p_poei_information28,
		p_poei_information29		=>	p_poei_information29,
		p_poei_information30		=>	p_poei_information30,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_position_extra_info',
				 p_hook_type	=> 'AP'
				);
  end;
  --
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
    ROLLBACK TO update_position_extra_info;
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
    p_object_version_number  := l_temp_ovn;
    ROLLBACK TO update_position_extra_info;
    --
    raise;
    --
end update_position_extra_info;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_position_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_position_extra_info
  (p_validate                      in     boolean  default false
  ,p_position_extra_info_id        in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_position_extra_info';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint delete_position_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
	hr_position_extra_info_bk3.delete_position_extra_info_b
		(
		p_position_extra_info_id	=>	p_position_extra_info_id,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_position_extra_info',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic - Delete Position Extra Info details
  --
  pe_poi_del.del
  (p_position_extra_info_id        => p_position_extra_info_id
  ,p_object_version_number         => p_object_version_number
  ,p_validate                      => false
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_position_extra_info_bk3.delete_position_extra_info_a
		(
		p_position_extra_info_id	=>	p_position_extra_info_id,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_position_extra_info',
				 p_hook_type	=> 'AP'
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
    ROLLBACK TO delete_position_extra_info;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of the fix to bug 632479
    --
    ROLLBACK TO delete_position_extra_info;
    --
    raise;
    --
end delete_position_extra_info;
--
end hr_position_extra_info_api;

/
