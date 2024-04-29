--------------------------------------------------------
--  DDL for Package Body BEN_OPT_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_OPT_EXTRA_INFO_API" as
/* $Header: beopiapi.pkb 115.0 2003/09/23 10:15:45 hmani noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_opt_extra_info_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_opt_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_opt_extra_info
  (p_validate                     in     boolean  default false
  ,p_opt_id                       in     number
  ,p_information_type             in     varchar2
  ,p_opi_attribute_category       in     varchar2 default null
  ,p_opi_attribute1               in     varchar2 default null
  ,p_opi_attribute2               in     varchar2 default null
  ,p_opi_attribute3               in     varchar2 default null
  ,p_opi_attribute4               in     varchar2 default null
  ,p_opi_attribute5               in     varchar2 default null
  ,p_opi_attribute6               in     varchar2 default null
  ,p_opi_attribute7               in     varchar2 default null
  ,p_opi_attribute8               in     varchar2 default null
  ,p_opi_attribute9               in     varchar2 default null
  ,p_opi_attribute10              in     varchar2 default null
  ,p_opi_attribute11              in     varchar2 default null
  ,p_opi_attribute12              in     varchar2 default null
  ,p_opi_attribute13              in     varchar2 default null
  ,p_opi_attribute14              in     varchar2 default null
  ,p_opi_attribute15              in     varchar2 default null
  ,p_opi_attribute16              in     varchar2 default null
  ,p_opi_attribute17              in     varchar2 default null
  ,p_opi_attribute18              in     varchar2 default null
  ,p_opi_attribute19              in     varchar2 default null
  ,p_opi_attribute20              in     varchar2 default null
  ,p_opi_information_category     in     varchar2 default null
  ,p_opi_information1             in     varchar2 default null
  ,p_opi_information2             in     varchar2 default null
  ,p_opi_information3             in     varchar2 default null
  ,p_opi_information4             in     varchar2 default null
  ,p_opi_information5             in     varchar2 default null
  ,p_opi_information6             in     varchar2 default null
  ,p_opi_information7             in     varchar2 default null
  ,p_opi_information8             in     varchar2 default null
  ,p_opi_information9             in     varchar2 default null
  ,p_opi_information10            in     varchar2 default null
  ,p_opi_information11            in     varchar2 default null
  ,p_opi_information12            in     varchar2 default null
  ,p_opi_information13            in     varchar2 default null
  ,p_opi_information14            in     varchar2 default null
  ,p_opi_information15            in     varchar2 default null
  ,p_opi_information16            in     varchar2 default null
  ,p_opi_information17            in     varchar2 default null
  ,p_opi_information18            in     varchar2 default null
  ,p_opi_information19            in     varchar2 default null
  ,p_opi_information20            in     varchar2 default null
  ,p_opi_information21            in     varchar2 default null
  ,p_opi_information22            in     varchar2 default null
  ,p_opi_information23            in     varchar2 default null
  ,p_opi_information24            in     varchar2 default null
  ,p_opi_information25            in     varchar2 default null
  ,p_opi_information26            in     varchar2 default null
  ,p_opi_information27            in     varchar2 default null
  ,p_opi_information28            in     varchar2 default null
  ,p_opi_information29            in     varchar2 default null
  ,p_opi_information30            in     varchar2 default null
  ,p_opt_extra_info_id            out nocopy    number
  ,p_object_version_number        out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_opt_extra_info';
  l_object_version_number	ben_opt_extra_info.object_version_number%type;
  l_opt_extra_info_id		ben_opt_extra_info.opt_extra_info_id%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint create_opt_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin

	ben_opt_extra_info_bk1.create_opt_extra_info_b
		(
		p_information_type		=>	p_information_type,
		p_opt_id			=>	p_opt_id,
		p_opi_attribute_category	=>	p_opi_attribute_category,
		p_opi_attribute1		=>	p_opi_attribute1,
		p_opi_attribute2		=>	p_opi_attribute2,
		p_opi_attribute3		=>	p_opi_attribute3,
		p_opi_attribute4		=>	p_opi_attribute4,
		p_opi_attribute5		=>	p_opi_attribute5,
		p_opi_attribute6		=>	p_opi_attribute6,
		p_opi_attribute7		=>	p_opi_attribute7,
		p_opi_attribute8		=>	p_opi_attribute8,
		p_opi_attribute9		=>	p_opi_attribute9,
		p_opi_attribute10		=>	p_opi_attribute10,
		p_opi_attribute11		=>	p_opi_attribute11,
		p_opi_attribute12		=>	p_opi_attribute12,
		p_opi_attribute13		=>	p_opi_attribute13,
		p_opi_attribute14		=>	p_opi_attribute14,
		p_opi_attribute15		=>	p_opi_attribute15,
		p_opi_attribute16		=>	p_opi_attribute16,
		p_opi_attribute17		=>	p_opi_attribute17,
		p_opi_attribute18		=>	p_opi_attribute18,
		p_opi_attribute19		=>	p_opi_attribute19,
		p_opi_attribute20		=>	p_opi_attribute20,
		p_opi_information_category	=>	p_opi_information_category,
		p_opi_information1		=>	p_opi_information1,
		p_opi_information2		=>	p_opi_information2,
		p_opi_information3		=>	p_opi_information3,
		p_opi_information4		=>	p_opi_information4,
		p_opi_information5		=>	p_opi_information5,
		p_opi_information6		=>	p_opi_information6,
		p_opi_information7		=>	p_opi_information7,
		p_opi_information8		=>	p_opi_information8,
		p_opi_information9		=>	p_opi_information9,
		p_opi_information10		=>	p_opi_information10,
		p_opi_information11		=>	p_opi_information11,
		p_opi_information12		=>	p_opi_information12,
		p_opi_information13		=>	p_opi_information13,
		p_opi_information14		=>	p_opi_information14,
		p_opi_information15		=>	p_opi_information15,
		p_opi_information16		=>	p_opi_information16,
		p_opi_information17		=>	p_opi_information17,
		p_opi_information18		=>	p_opi_information18,
		p_opi_information19		=>	p_opi_information19,
		p_opi_information20		=>	p_opi_information20,
		p_opi_information21		=>	p_opi_information21,
		p_opi_information22		=>	p_opi_information22,
		p_opi_information23		=>	p_opi_information23,
		p_opi_information24		=>	p_opi_information24,
		p_opi_information25		=>	p_opi_information25,
		p_opi_information26		=>	p_opi_information26,
		p_opi_information27		=>	p_opi_information27,
		p_opi_information28		=>	p_opi_information28,
		p_opi_information29		=>	p_opi_information29,
		p_opi_information30		=>	p_opi_information30
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_opt_extra_info',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  ben_opi_ins.ins
  (p_opt_extra_info_id            => l_opt_extra_info_id
  ,p_opt_id                       => p_opt_id
  ,p_information_type             => p_information_type
  ,p_opi_attribute_category       => p_opi_attribute_category
  ,p_opi_attribute1               => p_opi_attribute1
  ,p_opi_attribute2               => p_opi_attribute2
  ,p_opi_attribute3               => p_opi_attribute3
  ,p_opi_attribute4               => p_opi_attribute4
  ,p_opi_attribute5               => p_opi_attribute5
  ,p_opi_attribute6               => p_opi_attribute6
  ,p_opi_attribute7               => p_opi_attribute7
  ,p_opi_attribute8               => p_opi_attribute8
  ,p_opi_attribute9               => p_opi_attribute9
  ,p_opi_attribute10              => p_opi_attribute10
  ,p_opi_attribute11              => p_opi_attribute11
  ,p_opi_attribute12              => p_opi_attribute12
  ,p_opi_attribute13              => p_opi_attribute13
  ,p_opi_attribute14              => p_opi_attribute14
  ,p_opi_attribute15              => p_opi_attribute15
  ,p_opi_attribute16              => p_opi_attribute16
  ,p_opi_attribute17              => p_opi_attribute17
  ,p_opi_attribute18              => p_opi_attribute18
  ,p_opi_attribute19              => p_opi_attribute19
  ,p_opi_attribute20              => p_opi_attribute20
  ,p_opi_information_category     => p_opi_information_category
  ,p_opi_information1             => p_opi_information1
  ,p_opi_information2             => p_opi_information2
  ,p_opi_information3             => p_opi_information3
  ,p_opi_information4             => p_opi_information4
  ,p_opi_information5             => p_opi_information5
  ,p_opi_information6             => p_opi_information6
  ,p_opi_information7             => p_opi_information7
  ,p_opi_information8             => p_opi_information8
  ,p_opi_information9             => p_opi_information9
  ,p_opi_information10            => p_opi_information10
  ,p_opi_information11            => p_opi_information11
  ,p_opi_information12            => p_opi_information12
  ,p_opi_information13            => p_opi_information13
  ,p_opi_information14            => p_opi_information14
  ,p_opi_information15            => p_opi_information15
  ,p_opi_information16            => p_opi_information16
  ,p_opi_information17            => p_opi_information17
  ,p_opi_information18            => p_opi_information18
  ,p_opi_information19            => p_opi_information19
  ,p_opi_information20            => p_opi_information20
  ,p_opi_information21            => p_opi_information21
  ,p_opi_information22            => p_opi_information22
  ,p_opi_information23            => p_opi_information23
  ,p_opi_information24            => p_opi_information24
  ,p_opi_information25            => p_opi_information25
  ,p_opi_information26            => p_opi_information26
  ,p_opi_information27            => p_opi_information27
  ,p_opi_information28            => p_opi_information28
  ,p_opi_information29            => p_opi_information29
  ,p_opi_information30            => p_opi_information30
  ,p_object_version_number        => l_object_version_number
  ,p_validate                     => false
  );
  p_object_version_number	:= l_object_version_number;
  p_opt_extra_info_id		:= l_opt_extra_info_id;
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	ben_opt_extra_info_bk1.create_opt_extra_info_a
		(
		p_opt_extra_info_id		=>	l_opt_extra_info_id,
		p_information_type		=>	p_information_type,
		p_opt_id			=>	p_opt_id,
		p_opi_attribute_category	=>	p_opi_attribute_category,
		p_opi_attribute1		=>	p_opi_attribute1,
		p_opi_attribute2		=>	p_opi_attribute2,
		p_opi_attribute3		=>	p_opi_attribute3,
		p_opi_attribute4		=>	p_opi_attribute4,
		p_opi_attribute5		=>	p_opi_attribute5,
		p_opi_attribute6		=>	p_opi_attribute6,
		p_opi_attribute7		=>	p_opi_attribute7,
		p_opi_attribute8		=>	p_opi_attribute8,
		p_opi_attribute9		=>	p_opi_attribute9,
		p_opi_attribute10		=>	p_opi_attribute10,
		p_opi_attribute11		=>	p_opi_attribute11,
		p_opi_attribute12		=>	p_opi_attribute12,
		p_opi_attribute13		=>	p_opi_attribute13,
		p_opi_attribute14		=>	p_opi_attribute14,
		p_opi_attribute15		=>	p_opi_attribute15,
		p_opi_attribute16		=>	p_opi_attribute16,
		p_opi_attribute17		=>	p_opi_attribute17,
		p_opi_attribute18		=>	p_opi_attribute18,
		p_opi_attribute19		=>	p_opi_attribute19,
		p_opi_attribute20		=>	p_opi_attribute20,
		p_opi_information_category	=>	p_opi_information_category,
		p_opi_information1		=>	p_opi_information1,
		p_opi_information2		=>	p_opi_information2,
		p_opi_information3		=>	p_opi_information3,
		p_opi_information4		=>	p_opi_information4,
		p_opi_information5		=>	p_opi_information5,
		p_opi_information6		=>	p_opi_information6,
		p_opi_information7		=>	p_opi_information7,
		p_opi_information8		=>	p_opi_information8,
		p_opi_information9		=>	p_opi_information9,
		p_opi_information10		=>	p_opi_information10,
		p_opi_information11		=>	p_opi_information11,
		p_opi_information12		=>	p_opi_information12,
		p_opi_information13		=>	p_opi_information13,
		p_opi_information14		=>	p_opi_information14,
		p_opi_information15		=>	p_opi_information15,
		p_opi_information16		=>	p_opi_information16,
		p_opi_information17		=>	p_opi_information17,
		p_opi_information18		=>	p_opi_information18,
		p_opi_information19		=>	p_opi_information19,
		p_opi_information20		=>	p_opi_information20,
		p_opi_information21		=>	p_opi_information21,
		p_opi_information22		=>	p_opi_information22,
		p_opi_information23		=>	p_opi_information23,
		p_opi_information24		=>	p_opi_information24,
		p_opi_information25		=>	p_opi_information25,
		p_opi_information26		=>	p_opi_information26,
		p_opi_information27		=>	p_opi_information27,
		p_opi_information28		=>	p_opi_information28,
		p_opi_information29		=>	p_opi_information29,
		p_opi_information30		=>	p_opi_information30,
		p_object_version_number		=>	l_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_opt_extra_info',
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
    ROLLBACK TO create_opt_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_opt_extra_info_id := null;
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
  ROLLBACK TO create_opt_extra_info;
  --
    -- set in out parameters and set out parameters
    --
   p_opt_extra_info_id := null;
    p_object_version_number  := null;
  --
  raise;
  --
end create_opt_extra_info;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_opt_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_opt_extra_info
  (p_validate                     in     boolean  default false
  ,p_opt_extra_info_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_opi_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_opi_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_opi_information1             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information2             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information3             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information4             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information5             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information6             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information7             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information8             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information9             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information10            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information11            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information12            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information13            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information14            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information15            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information16            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information17            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information18            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information19            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information20            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information21            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information22            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information23            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information24            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information25            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information26            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information27            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information28            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information29            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information30            in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_opt_extra_info';
  l_object_version_number ben_opt_extra_info.object_version_number%TYPE;
  l_ovn ben_opt_extra_info.object_version_number%TYPE := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint update_opt_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
	ben_opt_extra_info_bk2.update_opt_extra_info_b
		(
		p_opt_extra_info_id		=>	p_opt_extra_info_id,
		p_opi_attribute_category	=>	p_opi_attribute_category,
		p_opi_attribute1		=>	p_opi_attribute1,
		p_opi_attribute2		=>	p_opi_attribute2,
		p_opi_attribute3		=>	p_opi_attribute3,
		p_opi_attribute4		=>	p_opi_attribute4,
		p_opi_attribute5		=>	p_opi_attribute5,
		p_opi_attribute6		=>	p_opi_attribute6,
		p_opi_attribute7		=>	p_opi_attribute7,
		p_opi_attribute8		=>	p_opi_attribute8,
		p_opi_attribute9		=>	p_opi_attribute9,
		p_opi_attribute10		=>	p_opi_attribute10,
		p_opi_attribute11		=>	p_opi_attribute11,
		p_opi_attribute12		=>	p_opi_attribute12,
		p_opi_attribute13		=>	p_opi_attribute13,
		p_opi_attribute14		=>	p_opi_attribute14,
		p_opi_attribute15		=>	p_opi_attribute15,
		p_opi_attribute16		=>	p_opi_attribute16,
		p_opi_attribute17		=>	p_opi_attribute17,
		p_opi_attribute18		=>	p_opi_attribute18,
		p_opi_attribute19		=>	p_opi_attribute19,
		p_opi_attribute20		=>	p_opi_attribute20,
		p_opi_information_category	=>	p_opi_information_category,
		p_opi_information1		=>	p_opi_information1,
		p_opi_information2		=>	p_opi_information2,
		p_opi_information3		=>	p_opi_information3,
		p_opi_information4		=>	p_opi_information4,
		p_opi_information5		=>	p_opi_information5,
		p_opi_information6		=>	p_opi_information6,
		p_opi_information7		=>	p_opi_information7,
		p_opi_information8		=>	p_opi_information8,
		p_opi_information9		=>	p_opi_information9,
		p_opi_information10		=>	p_opi_information10,
		p_opi_information11		=>	p_opi_information11,
		p_opi_information12		=>	p_opi_information12,
		p_opi_information13		=>	p_opi_information13,
		p_opi_information14		=>	p_opi_information14,
		p_opi_information15		=>	p_opi_information15,
		p_opi_information16		=>	p_opi_information16,
		p_opi_information17		=>	p_opi_information17,
		p_opi_information18		=>	p_opi_information18,
		p_opi_information19		=>	p_opi_information19,
		p_opi_information20		=>	p_opi_information20,
		p_opi_information21		=>	p_opi_information21,
		p_opi_information22		=>	p_opi_information22,
		p_opi_information23		=>	p_opi_information23,
		p_opi_information24		=>	p_opi_information24,
		p_opi_information25		=>	p_opi_information25,
		p_opi_information26		=>	p_opi_information26,
		p_opi_information27		=>	p_opi_information27,
		p_opi_information28		=>	p_opi_information28,
		p_opi_information29		=>	p_opi_information29,
		p_opi_information30		=>	p_opi_information30,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_opt_extra_info',
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
  -- Process Logic - Update opt Extra Info details
  --
  ben_opi_upd.upd
  (p_opt_extra_info_id            => p_opt_extra_info_id
  ,p_opi_attribute_category       => p_opi_attribute_category
  ,p_opi_attribute1               => p_opi_attribute1
  ,p_opi_attribute2               => p_opi_attribute2
  ,p_opi_attribute3               => p_opi_attribute3
  ,p_opi_attribute4               => p_opi_attribute4
  ,p_opi_attribute5               => p_opi_attribute5
  ,p_opi_attribute6               => p_opi_attribute6
  ,p_opi_attribute7               => p_opi_attribute7
  ,p_opi_attribute8               => p_opi_attribute8
  ,p_opi_attribute9               => p_opi_attribute9
  ,p_opi_attribute10              => p_opi_attribute10
  ,p_opi_attribute11              => p_opi_attribute11
  ,p_opi_attribute12              => p_opi_attribute12
  ,p_opi_attribute13              => p_opi_attribute13
  ,p_opi_attribute14              => p_opi_attribute14
  ,p_opi_attribute15              => p_opi_attribute15
  ,p_opi_attribute16              => p_opi_attribute16
  ,p_opi_attribute17              => p_opi_attribute17
  ,p_opi_attribute18              => p_opi_attribute18
  ,p_opi_attribute19              => p_opi_attribute19
  ,p_opi_attribute20              => p_opi_attribute20
  ,p_opi_information_category     => p_opi_information_category
  ,p_opi_information1             => p_opi_information1
  ,p_opi_information2             => p_opi_information2
  ,p_opi_information3             => p_opi_information3
  ,p_opi_information4             => p_opi_information4
  ,p_opi_information5             => p_opi_information5
  ,p_opi_information6             => p_opi_information6
  ,p_opi_information7             => p_opi_information7
  ,p_opi_information8             => p_opi_information8
  ,p_opi_information9             => p_opi_information9
  ,p_opi_information10            => p_opi_information10
  ,p_opi_information11            => p_opi_information11
  ,p_opi_information12            => p_opi_information12
  ,p_opi_information13            => p_opi_information13
  ,p_opi_information14            => p_opi_information14
  ,p_opi_information15            => p_opi_information15
  ,p_opi_information16            => p_opi_information16
  ,p_opi_information17            => p_opi_information17
  ,p_opi_information18            => p_opi_information18
  ,p_opi_information19            => p_opi_information19
  ,p_opi_information20            => p_opi_information20
  ,p_opi_information21            => p_opi_information21
  ,p_opi_information22            => p_opi_information22
  ,p_opi_information23            => p_opi_information23
  ,p_opi_information24            => p_opi_information24
  ,p_opi_information25            => p_opi_information25
  ,p_opi_information26            => p_opi_information26
  ,p_opi_information27            => p_opi_information27
  ,p_opi_information28            => p_opi_information28
  ,p_opi_information29            => p_opi_information29
  ,p_opi_information30            => p_opi_information30
  ,p_object_version_number        => p_object_version_number
  ,p_validate                     => false
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	ben_opt_extra_info_bk2.update_opt_extra_info_a
		(
		p_opt_extra_info_id		=>	p_opt_extra_info_id,
		p_opi_attribute_category	=>	p_opi_attribute_category,
		p_opi_attribute1		=>	p_opi_attribute1,
		p_opi_attribute2		=>	p_opi_attribute2,
		p_opi_attribute3		=>	p_opi_attribute3,
		p_opi_attribute4		=>	p_opi_attribute4,
		p_opi_attribute5		=>	p_opi_attribute5,
		p_opi_attribute6		=>	p_opi_attribute6,
		p_opi_attribute7		=>	p_opi_attribute7,
		p_opi_attribute8		=>	p_opi_attribute8,
		p_opi_attribute9		=>	p_opi_attribute9,
		p_opi_attribute10		=>	p_opi_attribute10,
		p_opi_attribute11		=>	p_opi_attribute11,
		p_opi_attribute12		=>	p_opi_attribute12,
		p_opi_attribute13		=>	p_opi_attribute13,
		p_opi_attribute14		=>	p_opi_attribute14,
		p_opi_attribute15		=>	p_opi_attribute15,
		p_opi_attribute16		=>	p_opi_attribute16,
		p_opi_attribute17		=>	p_opi_attribute17,
		p_opi_attribute18		=>	p_opi_attribute18,
		p_opi_attribute19		=>	p_opi_attribute19,
		p_opi_attribute20		=>	p_opi_attribute20,
		p_opi_information_category	=>	p_opi_information_category,
		p_opi_information1		=>	p_opi_information1,
		p_opi_information2		=>	p_opi_information2,
		p_opi_information3		=>	p_opi_information3,
		p_opi_information4		=>	p_opi_information4,
		p_opi_information5		=>	p_opi_information5,
		p_opi_information6		=>	p_opi_information6,
		p_opi_information7		=>	p_opi_information7,
		p_opi_information8		=>	p_opi_information8,
		p_opi_information9		=>	p_opi_information9,
		p_opi_information10		=>	p_opi_information10,
		p_opi_information11		=>	p_opi_information11,
		p_opi_information12		=>	p_opi_information12,
		p_opi_information13		=>	p_opi_information13,
		p_opi_information14		=>	p_opi_information14,
		p_opi_information15		=>	p_opi_information15,
		p_opi_information16		=>	p_opi_information16,
		p_opi_information17		=>	p_opi_information17,
		p_opi_information18		=>	p_opi_information18,
		p_opi_information19		=>	p_opi_information19,
		p_opi_information20		=>	p_opi_information20,
		p_opi_information21		=>	p_opi_information21,
		p_opi_information22		=>	p_opi_information22,
		p_opi_information23		=>	p_opi_information23,
		p_opi_information24		=>	p_opi_information24,
		p_opi_information25		=>	p_opi_information25,
		p_opi_information26		=>	p_opi_information26,
		p_opi_information27		=>	p_opi_information27,
		p_opi_information28		=>	p_opi_information28,
		p_opi_information29		=>	p_opi_information29,
		p_opi_information30		=>	p_opi_information30,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_opt_extra_info',
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
    ROLLBACK TO update_opt_extra_info;
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
  ROLLBACK TO update_opt_extra_info;
    --
    -- set in out parameters and set out parameters
    --
   p_object_version_number  := l_ovn;
  --
  raise;
  --
end update_opt_extra_info;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_opt_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_opt_extra_info
  (p_validate                 in     boolean  default false
  ,p_opt_extra_info_id        in     number
  ,p_object_version_number    in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_opt_extra_info';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint delete_opt_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
	ben_opt_extra_info_bk3.delete_opt_extra_info_b
		(
		p_opt_extra_info_id		=>	p_opt_extra_info_id,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_opt_extra_info',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic - Delete opt Extra Info details
  --
  ben_opi_del.del
  (p_opt_extra_info_id             => p_opt_extra_info_id
  ,p_object_version_number         => p_object_version_number
  ,p_validate                      => false
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	ben_opt_extra_info_bk3.delete_opt_extra_info_a
		(
		p_opt_extra_info_id		=>	p_opt_extra_info_id,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_opt_extra_info',
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
    ROLLBACK TO delete_opt_extra_info;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO delete_opt_extra_info;
  --
  raise;
  --
end delete_opt_extra_info;
--
end ben_opt_extra_info_api;

/
