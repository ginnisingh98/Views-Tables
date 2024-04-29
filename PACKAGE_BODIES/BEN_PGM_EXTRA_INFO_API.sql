--------------------------------------------------------
--  DDL for Package Body BEN_PGM_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PGM_EXTRA_INFO_API" as
/* $Header: bepgiapi.pkb 115.0 2003/09/23 10:20:09 hmani noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_pgm_extra_info_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pgm_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pgm_extra_info
  (p_validate                     in     boolean  default false
  ,p_pgm_id                       in     number
  ,p_information_type             in     varchar2
  ,p_pgi_attribute_category       in     varchar2 default null
  ,p_pgi_attribute1               in     varchar2 default null
  ,p_pgi_attribute2               in     varchar2 default null
  ,p_pgi_attribute3               in     varchar2 default null
  ,p_pgi_attribute4               in     varchar2 default null
  ,p_pgi_attribute5               in     varchar2 default null
  ,p_pgi_attribute6               in     varchar2 default null
  ,p_pgi_attribute7               in     varchar2 default null
  ,p_pgi_attribute8               in     varchar2 default null
  ,p_pgi_attribute9               in     varchar2 default null
  ,p_pgi_attribute10              in     varchar2 default null
  ,p_pgi_attribute11              in     varchar2 default null
  ,p_pgi_attribute12              in     varchar2 default null
  ,p_pgi_attribute13              in     varchar2 default null
  ,p_pgi_attribute14              in     varchar2 default null
  ,p_pgi_attribute15              in     varchar2 default null
  ,p_pgi_attribute16              in     varchar2 default null
  ,p_pgi_attribute17              in     varchar2 default null
  ,p_pgi_attribute18              in     varchar2 default null
  ,p_pgi_attribute19              in     varchar2 default null
  ,p_pgi_attribute20              in     varchar2 default null
  ,p_pgi_information_category     in     varchar2 default null
  ,p_pgi_information1             in     varchar2 default null
  ,p_pgi_information2             in     varchar2 default null
  ,p_pgi_information3             in     varchar2 default null
  ,p_pgi_information4             in     varchar2 default null
  ,p_pgi_information5             in     varchar2 default null
  ,p_pgi_information6             in     varchar2 default null
  ,p_pgi_information7             in     varchar2 default null
  ,p_pgi_information8             in     varchar2 default null
  ,p_pgi_information9             in     varchar2 default null
  ,p_pgi_information10            in     varchar2 default null
  ,p_pgi_information11            in     varchar2 default null
  ,p_pgi_information12            in     varchar2 default null
  ,p_pgi_information13            in     varchar2 default null
  ,p_pgi_information14            in     varchar2 default null
  ,p_pgi_information15            in     varchar2 default null
  ,p_pgi_information16            in     varchar2 default null
  ,p_pgi_information17            in     varchar2 default null
  ,p_pgi_information18            in     varchar2 default null
  ,p_pgi_information19            in     varchar2 default null
  ,p_pgi_information20            in     varchar2 default null
  ,p_pgi_information21            in     varchar2 default null
  ,p_pgi_information22            in     varchar2 default null
  ,p_pgi_information23            in     varchar2 default null
  ,p_pgi_information24            in     varchar2 default null
  ,p_pgi_information25            in     varchar2 default null
  ,p_pgi_information26            in     varchar2 default null
  ,p_pgi_information27            in     varchar2 default null
  ,p_pgi_information28            in     varchar2 default null
  ,p_pgi_information29            in     varchar2 default null
  ,p_pgi_information30            in     varchar2 default null
  ,p_pgm_extra_info_id            out nocopy    number
  ,p_object_version_number        out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_pgm_extra_info';
  l_object_version_number	ben_pgm_extra_info.object_version_number%type;
  l_pgm_extra_info_id		ben_pgm_extra_info.pgm_extra_info_id%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint create_pgm_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin

	ben_pgm_extra_info_bk1.create_pgm_extra_info_b
		(
		p_information_type		=>	p_information_type,
		p_pgm_id			=>	p_pgm_id,
		p_pgi_attribute_category	=>	p_pgi_attribute_category,
		p_pgi_attribute1		=>	p_pgi_attribute1,
		p_pgi_attribute2		=>	p_pgi_attribute2,
		p_pgi_attribute3		=>	p_pgi_attribute3,
		p_pgi_attribute4		=>	p_pgi_attribute4,
		p_pgi_attribute5		=>	p_pgi_attribute5,
		p_pgi_attribute6		=>	p_pgi_attribute6,
		p_pgi_attribute7		=>	p_pgi_attribute7,
		p_pgi_attribute8		=>	p_pgi_attribute8,
		p_pgi_attribute9		=>	p_pgi_attribute9,
		p_pgi_attribute10		=>	p_pgi_attribute10,
		p_pgi_attribute11		=>	p_pgi_attribute11,
		p_pgi_attribute12		=>	p_pgi_attribute12,
		p_pgi_attribute13		=>	p_pgi_attribute13,
		p_pgi_attribute14		=>	p_pgi_attribute14,
		p_pgi_attribute15		=>	p_pgi_attribute15,
		p_pgi_attribute16		=>	p_pgi_attribute16,
		p_pgi_attribute17		=>	p_pgi_attribute17,
		p_pgi_attribute18		=>	p_pgi_attribute18,
		p_pgi_attribute19		=>	p_pgi_attribute19,
		p_pgi_attribute20		=>	p_pgi_attribute20,
		p_pgi_information_category	=>	p_pgi_information_category,
		p_pgi_information1		=>	p_pgi_information1,
		p_pgi_information2		=>	p_pgi_information2,
		p_pgi_information3		=>	p_pgi_information3,
		p_pgi_information4		=>	p_pgi_information4,
		p_pgi_information5		=>	p_pgi_information5,
		p_pgi_information6		=>	p_pgi_information6,
		p_pgi_information7		=>	p_pgi_information7,
		p_pgi_information8		=>	p_pgi_information8,
		p_pgi_information9		=>	p_pgi_information9,
		p_pgi_information10		=>	p_pgi_information10,
		p_pgi_information11		=>	p_pgi_information11,
		p_pgi_information12		=>	p_pgi_information12,
		p_pgi_information13		=>	p_pgi_information13,
		p_pgi_information14		=>	p_pgi_information14,
		p_pgi_information15		=>	p_pgi_information15,
		p_pgi_information16		=>	p_pgi_information16,
		p_pgi_information17		=>	p_pgi_information17,
		p_pgi_information18		=>	p_pgi_information18,
		p_pgi_information19		=>	p_pgi_information19,
		p_pgi_information20		=>	p_pgi_information20,
		p_pgi_information21		=>	p_pgi_information21,
		p_pgi_information22		=>	p_pgi_information22,
		p_pgi_information23		=>	p_pgi_information23,
		p_pgi_information24		=>	p_pgi_information24,
		p_pgi_information25		=>	p_pgi_information25,
		p_pgi_information26		=>	p_pgi_information26,
		p_pgi_information27		=>	p_pgi_information27,
		p_pgi_information28		=>	p_pgi_information28,
		p_pgi_information29		=>	p_pgi_information29,
		p_pgi_information30		=>	p_pgi_information30
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_pgm_extra_info',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  ben_pgi_ins.ins
  (p_pgm_extra_info_id            => l_pgm_extra_info_id
  ,p_pgm_id                       => p_pgm_id
  ,p_information_type             => p_information_type
  ,p_pgi_attribute_category       => p_pgi_attribute_category
  ,p_pgi_attribute1               => p_pgi_attribute1
  ,p_pgi_attribute2               => p_pgi_attribute2
  ,p_pgi_attribute3               => p_pgi_attribute3
  ,p_pgi_attribute4               => p_pgi_attribute4
  ,p_pgi_attribute5               => p_pgi_attribute5
  ,p_pgi_attribute6               => p_pgi_attribute6
  ,p_pgi_attribute7               => p_pgi_attribute7
  ,p_pgi_attribute8               => p_pgi_attribute8
  ,p_pgi_attribute9               => p_pgi_attribute9
  ,p_pgi_attribute10              => p_pgi_attribute10
  ,p_pgi_attribute11              => p_pgi_attribute11
  ,p_pgi_attribute12              => p_pgi_attribute12
  ,p_pgi_attribute13              => p_pgi_attribute13
  ,p_pgi_attribute14              => p_pgi_attribute14
  ,p_pgi_attribute15              => p_pgi_attribute15
  ,p_pgi_attribute16              => p_pgi_attribute16
  ,p_pgi_attribute17              => p_pgi_attribute17
  ,p_pgi_attribute18              => p_pgi_attribute18
  ,p_pgi_attribute19              => p_pgi_attribute19
  ,p_pgi_attribute20              => p_pgi_attribute20
  ,p_pgi_information_category     => p_pgi_information_category
  ,p_pgi_information1             => p_pgi_information1
  ,p_pgi_information2             => p_pgi_information2
  ,p_pgi_information3             => p_pgi_information3
  ,p_pgi_information4             => p_pgi_information4
  ,p_pgi_information5             => p_pgi_information5
  ,p_pgi_information6             => p_pgi_information6
  ,p_pgi_information7             => p_pgi_information7
  ,p_pgi_information8             => p_pgi_information8
  ,p_pgi_information9             => p_pgi_information9
  ,p_pgi_information10            => p_pgi_information10
  ,p_pgi_information11            => p_pgi_information11
  ,p_pgi_information12            => p_pgi_information12
  ,p_pgi_information13            => p_pgi_information13
  ,p_pgi_information14            => p_pgi_information14
  ,p_pgi_information15            => p_pgi_information15
  ,p_pgi_information16            => p_pgi_information16
  ,p_pgi_information17            => p_pgi_information17
  ,p_pgi_information18            => p_pgi_information18
  ,p_pgi_information19            => p_pgi_information19
  ,p_pgi_information20            => p_pgi_information20
  ,p_pgi_information21            => p_pgi_information21
  ,p_pgi_information22            => p_pgi_information22
  ,p_pgi_information23            => p_pgi_information23
  ,p_pgi_information24            => p_pgi_information24
  ,p_pgi_information25            => p_pgi_information25
  ,p_pgi_information26            => p_pgi_information26
  ,p_pgi_information27            => p_pgi_information27
  ,p_pgi_information28            => p_pgi_information28
  ,p_pgi_information29            => p_pgi_information29
  ,p_pgi_information30            => p_pgi_information30
  ,p_object_version_number        => l_object_version_number
  ,p_validate                     => false
  );
  p_object_version_number	:= l_object_version_number;
  p_pgm_extra_info_id		:= l_pgm_extra_info_id;
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	ben_pgm_extra_info_bk1.create_pgm_extra_info_a
		(
		p_pgm_extra_info_id		=>	l_pgm_extra_info_id,
		p_information_type		=>	p_information_type,
		p_pgm_id			=>	p_pgm_id,
		p_pgi_attribute_category	=>	p_pgi_attribute_category,
		p_pgi_attribute1		=>	p_pgi_attribute1,
		p_pgi_attribute2		=>	p_pgi_attribute2,
		p_pgi_attribute3		=>	p_pgi_attribute3,
		p_pgi_attribute4		=>	p_pgi_attribute4,
		p_pgi_attribute5		=>	p_pgi_attribute5,
		p_pgi_attribute6		=>	p_pgi_attribute6,
		p_pgi_attribute7		=>	p_pgi_attribute7,
		p_pgi_attribute8		=>	p_pgi_attribute8,
		p_pgi_attribute9		=>	p_pgi_attribute9,
		p_pgi_attribute10		=>	p_pgi_attribute10,
		p_pgi_attribute11		=>	p_pgi_attribute11,
		p_pgi_attribute12		=>	p_pgi_attribute12,
		p_pgi_attribute13		=>	p_pgi_attribute13,
		p_pgi_attribute14		=>	p_pgi_attribute14,
		p_pgi_attribute15		=>	p_pgi_attribute15,
		p_pgi_attribute16		=>	p_pgi_attribute16,
		p_pgi_attribute17		=>	p_pgi_attribute17,
		p_pgi_attribute18		=>	p_pgi_attribute18,
		p_pgi_attribute19		=>	p_pgi_attribute19,
		p_pgi_attribute20		=>	p_pgi_attribute20,
		p_pgi_information_category	=>	p_pgi_information_category,
		p_pgi_information1		=>	p_pgi_information1,
		p_pgi_information2		=>	p_pgi_information2,
		p_pgi_information3		=>	p_pgi_information3,
		p_pgi_information4		=>	p_pgi_information4,
		p_pgi_information5		=>	p_pgi_information5,
		p_pgi_information6		=>	p_pgi_information6,
		p_pgi_information7		=>	p_pgi_information7,
		p_pgi_information8		=>	p_pgi_information8,
		p_pgi_information9		=>	p_pgi_information9,
		p_pgi_information10		=>	p_pgi_information10,
		p_pgi_information11		=>	p_pgi_information11,
		p_pgi_information12		=>	p_pgi_information12,
		p_pgi_information13		=>	p_pgi_information13,
		p_pgi_information14		=>	p_pgi_information14,
		p_pgi_information15		=>	p_pgi_information15,
		p_pgi_information16		=>	p_pgi_information16,
		p_pgi_information17		=>	p_pgi_information17,
		p_pgi_information18		=>	p_pgi_information18,
		p_pgi_information19		=>	p_pgi_information19,
		p_pgi_information20		=>	p_pgi_information20,
		p_pgi_information21		=>	p_pgi_information21,
		p_pgi_information22		=>	p_pgi_information22,
		p_pgi_information23		=>	p_pgi_information23,
		p_pgi_information24		=>	p_pgi_information24,
		p_pgi_information25		=>	p_pgi_information25,
		p_pgi_information26		=>	p_pgi_information26,
		p_pgi_information27		=>	p_pgi_information27,
		p_pgi_information28		=>	p_pgi_information28,
		p_pgi_information29		=>	p_pgi_information29,
		p_pgi_information30		=>	p_pgi_information30,
		p_object_version_number		=>	l_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_pgm_extra_info',
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
    ROLLBACK TO create_pgm_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pgm_extra_info_id := null;
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
  ROLLBACK TO create_pgm_extra_info;
  --
    -- set in out parameters and set out parameters
    --
   p_pgm_extra_info_id := null;
    p_object_version_number  := null;
  --
  raise;
  --
end create_pgm_extra_info;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_pgm_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pgm_extra_info
  (p_validate                     in     boolean  default false
  ,p_pgm_extra_info_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_pgi_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information1             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information2             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information3             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information4             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information5             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information6             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information7             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information8             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information9             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information10            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information11            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information12            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information13            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information14            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information15            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information16            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information17            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information18            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information19            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information20            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information21            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information22            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information23            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information24            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information25            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information26            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information27            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information28            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information29            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information30            in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_pgm_extra_info';
  l_object_version_number ben_pgm_extra_info.object_version_number%TYPE;
  l_ovn ben_pgm_extra_info.object_version_number%TYPE := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint update_pgm_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
	ben_pgm_extra_info_bk2.update_pgm_extra_info_b
		(
		p_pgm_extra_info_id		=>	p_pgm_extra_info_id,
		p_pgi_attribute_category	=>	p_pgi_attribute_category,
		p_pgi_attribute1		=>	p_pgi_attribute1,
		p_pgi_attribute2		=>	p_pgi_attribute2,
		p_pgi_attribute3		=>	p_pgi_attribute3,
		p_pgi_attribute4		=>	p_pgi_attribute4,
		p_pgi_attribute5		=>	p_pgi_attribute5,
		p_pgi_attribute6		=>	p_pgi_attribute6,
		p_pgi_attribute7		=>	p_pgi_attribute7,
		p_pgi_attribute8		=>	p_pgi_attribute8,
		p_pgi_attribute9		=>	p_pgi_attribute9,
		p_pgi_attribute10		=>	p_pgi_attribute10,
		p_pgi_attribute11		=>	p_pgi_attribute11,
		p_pgi_attribute12		=>	p_pgi_attribute12,
		p_pgi_attribute13		=>	p_pgi_attribute13,
		p_pgi_attribute14		=>	p_pgi_attribute14,
		p_pgi_attribute15		=>	p_pgi_attribute15,
		p_pgi_attribute16		=>	p_pgi_attribute16,
		p_pgi_attribute17		=>	p_pgi_attribute17,
		p_pgi_attribute18		=>	p_pgi_attribute18,
		p_pgi_attribute19		=>	p_pgi_attribute19,
		p_pgi_attribute20		=>	p_pgi_attribute20,
		p_pgi_information_category	=>	p_pgi_information_category,
		p_pgi_information1		=>	p_pgi_information1,
		p_pgi_information2		=>	p_pgi_information2,
		p_pgi_information3		=>	p_pgi_information3,
		p_pgi_information4		=>	p_pgi_information4,
		p_pgi_information5		=>	p_pgi_information5,
		p_pgi_information6		=>	p_pgi_information6,
		p_pgi_information7		=>	p_pgi_information7,
		p_pgi_information8		=>	p_pgi_information8,
		p_pgi_information9		=>	p_pgi_information9,
		p_pgi_information10		=>	p_pgi_information10,
		p_pgi_information11		=>	p_pgi_information11,
		p_pgi_information12		=>	p_pgi_information12,
		p_pgi_information13		=>	p_pgi_information13,
		p_pgi_information14		=>	p_pgi_information14,
		p_pgi_information15		=>	p_pgi_information15,
		p_pgi_information16		=>	p_pgi_information16,
		p_pgi_information17		=>	p_pgi_information17,
		p_pgi_information18		=>	p_pgi_information18,
		p_pgi_information19		=>	p_pgi_information19,
		p_pgi_information20		=>	p_pgi_information20,
		p_pgi_information21		=>	p_pgi_information21,
		p_pgi_information22		=>	p_pgi_information22,
		p_pgi_information23		=>	p_pgi_information23,
		p_pgi_information24		=>	p_pgi_information24,
		p_pgi_information25		=>	p_pgi_information25,
		p_pgi_information26		=>	p_pgi_information26,
		p_pgi_information27		=>	p_pgi_information27,
		p_pgi_information28		=>	p_pgi_information28,
		p_pgi_information29		=>	p_pgi_information29,
		p_pgi_information30		=>	p_pgi_information30,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_pgm_extra_info',
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
  -- Process Logic - Update pgm Extra Info details
  --
  ben_pgi_upd.upd
  (p_pgm_extra_info_id            => p_pgm_extra_info_id
  ,p_pgi_attribute_category       => p_pgi_attribute_category
  ,p_pgi_attribute1               => p_pgi_attribute1
  ,p_pgi_attribute2               => p_pgi_attribute2
  ,p_pgi_attribute3               => p_pgi_attribute3
  ,p_pgi_attribute4               => p_pgi_attribute4
  ,p_pgi_attribute5               => p_pgi_attribute5
  ,p_pgi_attribute6               => p_pgi_attribute6
  ,p_pgi_attribute7               => p_pgi_attribute7
  ,p_pgi_attribute8               => p_pgi_attribute8
  ,p_pgi_attribute9               => p_pgi_attribute9
  ,p_pgi_attribute10              => p_pgi_attribute10
  ,p_pgi_attribute11              => p_pgi_attribute11
  ,p_pgi_attribute12              => p_pgi_attribute12
  ,p_pgi_attribute13              => p_pgi_attribute13
  ,p_pgi_attribute14              => p_pgi_attribute14
  ,p_pgi_attribute15              => p_pgi_attribute15
  ,p_pgi_attribute16              => p_pgi_attribute16
  ,p_pgi_attribute17              => p_pgi_attribute17
  ,p_pgi_attribute18              => p_pgi_attribute18
  ,p_pgi_attribute19              => p_pgi_attribute19
  ,p_pgi_attribute20              => p_pgi_attribute20
  ,p_pgi_information_category     => p_pgi_information_category
  ,p_pgi_information1             => p_pgi_information1
  ,p_pgi_information2             => p_pgi_information2
  ,p_pgi_information3             => p_pgi_information3
  ,p_pgi_information4             => p_pgi_information4
  ,p_pgi_information5             => p_pgi_information5
  ,p_pgi_information6             => p_pgi_information6
  ,p_pgi_information7             => p_pgi_information7
  ,p_pgi_information8             => p_pgi_information8
  ,p_pgi_information9             => p_pgi_information9
  ,p_pgi_information10            => p_pgi_information10
  ,p_pgi_information11            => p_pgi_information11
  ,p_pgi_information12            => p_pgi_information12
  ,p_pgi_information13            => p_pgi_information13
  ,p_pgi_information14            => p_pgi_information14
  ,p_pgi_information15            => p_pgi_information15
  ,p_pgi_information16            => p_pgi_information16
  ,p_pgi_information17            => p_pgi_information17
  ,p_pgi_information18            => p_pgi_information18
  ,p_pgi_information19            => p_pgi_information19
  ,p_pgi_information20            => p_pgi_information20
  ,p_pgi_information21            => p_pgi_information21
  ,p_pgi_information22            => p_pgi_information22
  ,p_pgi_information23            => p_pgi_information23
  ,p_pgi_information24            => p_pgi_information24
  ,p_pgi_information25            => p_pgi_information25
  ,p_pgi_information26            => p_pgi_information26
  ,p_pgi_information27            => p_pgi_information27
  ,p_pgi_information28            => p_pgi_information28
  ,p_pgi_information29            => p_pgi_information29
  ,p_pgi_information30            => p_pgi_information30
  ,p_object_version_number        => p_object_version_number
  ,p_validate                     => false
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	ben_pgm_extra_info_bk2.update_pgm_extra_info_a
		(
		p_pgm_extra_info_id		=>	p_pgm_extra_info_id,
		p_pgi_attribute_category	=>	p_pgi_attribute_category,
		p_pgi_attribute1		=>	p_pgi_attribute1,
		p_pgi_attribute2		=>	p_pgi_attribute2,
		p_pgi_attribute3		=>	p_pgi_attribute3,
		p_pgi_attribute4		=>	p_pgi_attribute4,
		p_pgi_attribute5		=>	p_pgi_attribute5,
		p_pgi_attribute6		=>	p_pgi_attribute6,
		p_pgi_attribute7		=>	p_pgi_attribute7,
		p_pgi_attribute8		=>	p_pgi_attribute8,
		p_pgi_attribute9		=>	p_pgi_attribute9,
		p_pgi_attribute10		=>	p_pgi_attribute10,
		p_pgi_attribute11		=>	p_pgi_attribute11,
		p_pgi_attribute12		=>	p_pgi_attribute12,
		p_pgi_attribute13		=>	p_pgi_attribute13,
		p_pgi_attribute14		=>	p_pgi_attribute14,
		p_pgi_attribute15		=>	p_pgi_attribute15,
		p_pgi_attribute16		=>	p_pgi_attribute16,
		p_pgi_attribute17		=>	p_pgi_attribute17,
		p_pgi_attribute18		=>	p_pgi_attribute18,
		p_pgi_attribute19		=>	p_pgi_attribute19,
		p_pgi_attribute20		=>	p_pgi_attribute20,
		p_pgi_information_category	=>	p_pgi_information_category,
		p_pgi_information1		=>	p_pgi_information1,
		p_pgi_information2		=>	p_pgi_information2,
		p_pgi_information3		=>	p_pgi_information3,
		p_pgi_information4		=>	p_pgi_information4,
		p_pgi_information5		=>	p_pgi_information5,
		p_pgi_information6		=>	p_pgi_information6,
		p_pgi_information7		=>	p_pgi_information7,
		p_pgi_information8		=>	p_pgi_information8,
		p_pgi_information9		=>	p_pgi_information9,
		p_pgi_information10		=>	p_pgi_information10,
		p_pgi_information11		=>	p_pgi_information11,
		p_pgi_information12		=>	p_pgi_information12,
		p_pgi_information13		=>	p_pgi_information13,
		p_pgi_information14		=>	p_pgi_information14,
		p_pgi_information15		=>	p_pgi_information15,
		p_pgi_information16		=>	p_pgi_information16,
		p_pgi_information17		=>	p_pgi_information17,
		p_pgi_information18		=>	p_pgi_information18,
		p_pgi_information19		=>	p_pgi_information19,
		p_pgi_information20		=>	p_pgi_information20,
		p_pgi_information21		=>	p_pgi_information21,
		p_pgi_information22		=>	p_pgi_information22,
		p_pgi_information23		=>	p_pgi_information23,
		p_pgi_information24		=>	p_pgi_information24,
		p_pgi_information25		=>	p_pgi_information25,
		p_pgi_information26		=>	p_pgi_information26,
		p_pgi_information27		=>	p_pgi_information27,
		p_pgi_information28		=>	p_pgi_information28,
		p_pgi_information29		=>	p_pgi_information29,
		p_pgi_information30		=>	p_pgi_information30,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_pgm_extra_info',
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
    ROLLBACK TO update_pgm_extra_info;
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
  ROLLBACK TO update_pgm_extra_info;
    --
    -- set in out parameters and set out parameters
    --
   p_object_version_number  := l_ovn;
  --
  raise;
  --
end update_pgm_extra_info;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_pgm_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pgm_extra_info
  (p_validate                 in     boolean  default false
  ,p_pgm_extra_info_id        in     number
  ,p_object_version_number    in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_pgm_extra_info';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint delete_pgm_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
	ben_pgm_extra_info_bk3.delete_pgm_extra_info_b
		(
		p_pgm_extra_info_id		=>	p_pgm_extra_info_id,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_pgm_extra_info',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic - Delete pgm Extra Info details
  --
  ben_pgi_del.del
  (p_pgm_extra_info_id             => p_pgm_extra_info_id
  ,p_object_version_number         => p_object_version_number
  ,p_validate                      => false
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	ben_pgm_extra_info_bk3.delete_pgm_extra_info_a
		(
		p_pgm_extra_info_id		=>	p_pgm_extra_info_id,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_pgm_extra_info',
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
    ROLLBACK TO delete_pgm_extra_info;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO delete_pgm_extra_info;
  --
  raise;
  --
end delete_pgm_extra_info;
--
end ben_pgm_extra_info_api;

/
