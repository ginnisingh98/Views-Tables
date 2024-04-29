--------------------------------------------------------
--  DDL for Package Body PER_JOB_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JOB_EXTRA_INFO_API" as
/* $Header: pejeiapi.pkb 115.4 2002/12/11 11:26:57 pkakar ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_job_extra_info_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_job_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_job_extra_info
  (p_validate                     in     boolean  default false
  ,p_job_id                       in     number
  ,p_information_type             in     varchar2
  ,p_jei_attribute_category       in     varchar2 default null
  ,p_jei_attribute1               in     varchar2 default null
  ,p_jei_attribute2               in     varchar2 default null
  ,p_jei_attribute3               in     varchar2 default null
  ,p_jei_attribute4               in     varchar2 default null
  ,p_jei_attribute5               in     varchar2 default null
  ,p_jei_attribute6               in     varchar2 default null
  ,p_jei_attribute7               in     varchar2 default null
  ,p_jei_attribute8               in     varchar2 default null
  ,p_jei_attribute9               in     varchar2 default null
  ,p_jei_attribute10              in     varchar2 default null
  ,p_jei_attribute11              in     varchar2 default null
  ,p_jei_attribute12              in     varchar2 default null
  ,p_jei_attribute13              in     varchar2 default null
  ,p_jei_attribute14              in     varchar2 default null
  ,p_jei_attribute15              in     varchar2 default null
  ,p_jei_attribute16              in     varchar2 default null
  ,p_jei_attribute17              in     varchar2 default null
  ,p_jei_attribute18              in     varchar2 default null
  ,p_jei_attribute19              in     varchar2 default null
  ,p_jei_attribute20              in     varchar2 default null
  ,p_jei_information_category     in     varchar2 default null
  ,p_jei_information1             in     varchar2 default null
  ,p_jei_information2             in     varchar2 default null
  ,p_jei_information3             in     varchar2 default null
  ,p_jei_information4             in     varchar2 default null
  ,p_jei_information5             in     varchar2 default null
  ,p_jei_information6             in     varchar2 default null
  ,p_jei_information7             in     varchar2 default null
  ,p_jei_information8             in     varchar2 default null
  ,p_jei_information9             in     varchar2 default null
  ,p_jei_information10            in     varchar2 default null
  ,p_jei_information11            in     varchar2 default null
  ,p_jei_information12            in     varchar2 default null
  ,p_jei_information13            in     varchar2 default null
  ,p_jei_information14            in     varchar2 default null
  ,p_jei_information15            in     varchar2 default null
  ,p_jei_information16            in     varchar2 default null
  ,p_jei_information17            in     varchar2 default null
  ,p_jei_information18            in     varchar2 default null
  ,p_jei_information19            in     varchar2 default null
  ,p_jei_information20            in     varchar2 default null
  ,p_jei_information21            in     varchar2 default null
  ,p_jei_information22            in     varchar2 default null
  ,p_jei_information23            in     varchar2 default null
  ,p_jei_information24            in     varchar2 default null
  ,p_jei_information25            in     varchar2 default null
  ,p_jei_information26            in     varchar2 default null
  ,p_jei_information27            in     varchar2 default null
  ,p_jei_information28            in     varchar2 default null
  ,p_jei_information29            in     varchar2 default null
  ,p_jei_information30            in     varchar2 default null
  ,p_job_extra_info_id            out nocopy    number
  ,p_object_version_number        out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_job_extra_info';
  l_object_version_number	per_job_extra_info.object_version_number%type;
  l_job_extra_info_id		per_job_extra_info.job_extra_info_id%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint create_job_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
	per_job_extra_info_bk1.create_job_extra_info_b
		(
		p_information_type		=>	p_information_type,
		p_job_id			=>	p_job_id,
		p_jei_attribute_category	=>	p_jei_attribute_category,
		p_jei_attribute1		=>	p_jei_attribute1,
		p_jei_attribute2		=>	p_jei_attribute2,
		p_jei_attribute3		=>	p_jei_attribute3,
		p_jei_attribute4		=>	p_jei_attribute4,
		p_jei_attribute5		=>	p_jei_attribute5,
		p_jei_attribute6		=>	p_jei_attribute6,
		p_jei_attribute7		=>	p_jei_attribute7,
		p_jei_attribute8		=>	p_jei_attribute8,
		p_jei_attribute9		=>	p_jei_attribute9,
		p_jei_attribute10		=>	p_jei_attribute10,
		p_jei_attribute11		=>	p_jei_attribute11,
		p_jei_attribute12		=>	p_jei_attribute12,
		p_jei_attribute13		=>	p_jei_attribute13,
		p_jei_attribute14		=>	p_jei_attribute14,
		p_jei_attribute15		=>	p_jei_attribute15,
		p_jei_attribute16		=>	p_jei_attribute16,
		p_jei_attribute17		=>	p_jei_attribute17,
		p_jei_attribute18		=>	p_jei_attribute18,
		p_jei_attribute19		=>	p_jei_attribute19,
		p_jei_attribute20		=>	p_jei_attribute20,
		p_jei_information_category	=>	p_jei_information_category,
		p_jei_information1		=>	p_jei_information1,
		p_jei_information2		=>	p_jei_information2,
		p_jei_information3		=>	p_jei_information3,
		p_jei_information4		=>	p_jei_information4,
		p_jei_information5		=>	p_jei_information5,
		p_jei_information6		=>	p_jei_information6,
		p_jei_information7		=>	p_jei_information7,
		p_jei_information8		=>	p_jei_information8,
		p_jei_information9		=>	p_jei_information9,
		p_jei_information10		=>	p_jei_information10,
		p_jei_information11		=>	p_jei_information11,
		p_jei_information12		=>	p_jei_information12,
		p_jei_information13		=>	p_jei_information13,
		p_jei_information14		=>	p_jei_information14,
		p_jei_information15		=>	p_jei_information15,
		p_jei_information16		=>	p_jei_information16,
		p_jei_information17		=>	p_jei_information17,
		p_jei_information18		=>	p_jei_information18,
		p_jei_information19		=>	p_jei_information19,
		p_jei_information20		=>	p_jei_information20,
		p_jei_information21		=>	p_jei_information21,
		p_jei_information22		=>	p_jei_information22,
		p_jei_information23		=>	p_jei_information23,
		p_jei_information24		=>	p_jei_information24,
		p_jei_information25		=>	p_jei_information25,
		p_jei_information26		=>	p_jei_information26,
		p_jei_information27		=>	p_jei_information27,
		p_jei_information28		=>	p_jei_information28,
		p_jei_information29		=>	p_jei_information29,
		p_jei_information30		=>	p_jei_information30
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_job_extra_info',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  pe_jei_ins.ins
  (p_job_extra_info_id            => l_job_extra_info_id
  ,p_job_id                       => p_job_id
  ,p_information_type             => p_information_type
  ,p_jei_attribute_category       => p_jei_attribute_category
  ,p_jei_attribute1               => p_jei_attribute1
  ,p_jei_attribute2               => p_jei_attribute2
  ,p_jei_attribute3               => p_jei_attribute3
  ,p_jei_attribute4               => p_jei_attribute4
  ,p_jei_attribute5               => p_jei_attribute5
  ,p_jei_attribute6               => p_jei_attribute6
  ,p_jei_attribute7               => p_jei_attribute7
  ,p_jei_attribute8               => p_jei_attribute8
  ,p_jei_attribute9               => p_jei_attribute9
  ,p_jei_attribute10              => p_jei_attribute10
  ,p_jei_attribute11              => p_jei_attribute11
  ,p_jei_attribute12              => p_jei_attribute12
  ,p_jei_attribute13              => p_jei_attribute13
  ,p_jei_attribute14              => p_jei_attribute14
  ,p_jei_attribute15              => p_jei_attribute15
  ,p_jei_attribute16              => p_jei_attribute16
  ,p_jei_attribute17              => p_jei_attribute17
  ,p_jei_attribute18              => p_jei_attribute18
  ,p_jei_attribute19              => p_jei_attribute19
  ,p_jei_attribute20              => p_jei_attribute20
  ,p_jei_information_category     => p_jei_information_category
  ,p_jei_information1             => p_jei_information1
  ,p_jei_information2             => p_jei_information2
  ,p_jei_information3             => p_jei_information3
  ,p_jei_information4             => p_jei_information4
  ,p_jei_information5             => p_jei_information5
  ,p_jei_information6             => p_jei_information6
  ,p_jei_information7             => p_jei_information7
  ,p_jei_information8             => p_jei_information8
  ,p_jei_information9             => p_jei_information9
  ,p_jei_information10            => p_jei_information10
  ,p_jei_information11            => p_jei_information11
  ,p_jei_information12            => p_jei_information12
  ,p_jei_information13            => p_jei_information13
  ,p_jei_information14            => p_jei_information14
  ,p_jei_information15            => p_jei_information15
  ,p_jei_information16            => p_jei_information16
  ,p_jei_information17            => p_jei_information17
  ,p_jei_information18            => p_jei_information18
  ,p_jei_information19            => p_jei_information19
  ,p_jei_information20            => p_jei_information20
  ,p_jei_information21            => p_jei_information21
  ,p_jei_information22            => p_jei_information22
  ,p_jei_information23            => p_jei_information23
  ,p_jei_information24            => p_jei_information24
  ,p_jei_information25            => p_jei_information25
  ,p_jei_information26            => p_jei_information26
  ,p_jei_information27            => p_jei_information27
  ,p_jei_information28            => p_jei_information28
  ,p_jei_information29            => p_jei_information29
  ,p_jei_information30            => p_jei_information30
  ,p_object_version_number        => l_object_version_number
  ,p_validate                     => false
  );
  p_object_version_number	:= l_object_version_number;
  p_job_extra_info_id		:= l_job_extra_info_id;
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	per_job_extra_info_bk1.create_job_extra_info_a
		(
		p_job_extra_info_id		=>	l_job_extra_info_id,
		p_information_type		=>	p_information_type,
		p_job_id			=>	p_job_id,
		p_jei_attribute_category	=>	p_jei_attribute_category,
		p_jei_attribute1		=>	p_jei_attribute1,
		p_jei_attribute2		=>	p_jei_attribute2,
		p_jei_attribute3		=>	p_jei_attribute3,
		p_jei_attribute4		=>	p_jei_attribute4,
		p_jei_attribute5		=>	p_jei_attribute5,
		p_jei_attribute6		=>	p_jei_attribute6,
		p_jei_attribute7		=>	p_jei_attribute7,
		p_jei_attribute8		=>	p_jei_attribute8,
		p_jei_attribute9		=>	p_jei_attribute9,
		p_jei_attribute10		=>	p_jei_attribute10,
		p_jei_attribute11		=>	p_jei_attribute11,
		p_jei_attribute12		=>	p_jei_attribute12,
		p_jei_attribute13		=>	p_jei_attribute13,
		p_jei_attribute14		=>	p_jei_attribute14,
		p_jei_attribute15		=>	p_jei_attribute15,
		p_jei_attribute16		=>	p_jei_attribute16,
		p_jei_attribute17		=>	p_jei_attribute17,
		p_jei_attribute18		=>	p_jei_attribute18,
		p_jei_attribute19		=>	p_jei_attribute19,
		p_jei_attribute20		=>	p_jei_attribute20,
		p_jei_information_category	=>	p_jei_information_category,
		p_jei_information1		=>	p_jei_information1,
		p_jei_information2		=>	p_jei_information2,
		p_jei_information3		=>	p_jei_information3,
		p_jei_information4		=>	p_jei_information4,
		p_jei_information5		=>	p_jei_information5,
		p_jei_information6		=>	p_jei_information6,
		p_jei_information7		=>	p_jei_information7,
		p_jei_information8		=>	p_jei_information8,
		p_jei_information9		=>	p_jei_information9,
		p_jei_information10		=>	p_jei_information10,
		p_jei_information11		=>	p_jei_information11,
		p_jei_information12		=>	p_jei_information12,
		p_jei_information13		=>	p_jei_information13,
		p_jei_information14		=>	p_jei_information14,
		p_jei_information15		=>	p_jei_information15,
		p_jei_information16		=>	p_jei_information16,
		p_jei_information17		=>	p_jei_information17,
		p_jei_information18		=>	p_jei_information18,
		p_jei_information19		=>	p_jei_information19,
		p_jei_information20		=>	p_jei_information20,
		p_jei_information21		=>	p_jei_information21,
		p_jei_information22		=>	p_jei_information22,
		p_jei_information23		=>	p_jei_information23,
		p_jei_information24		=>	p_jei_information24,
		p_jei_information25		=>	p_jei_information25,
		p_jei_information26		=>	p_jei_information26,
		p_jei_information27		=>	p_jei_information27,
		p_jei_information28		=>	p_jei_information28,
		p_jei_information29		=>	p_jei_information29,
		p_jei_information30		=>	p_jei_information30,
		p_object_version_number		=>	l_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_job_extra_info',
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
    ROLLBACK TO create_job_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_job_extra_info_id := null;
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
  ROLLBACK TO create_job_extra_info;
  --
    -- set in out parameters and set out parameters
    --
   p_job_extra_info_id := null;
    p_object_version_number  := null;
  --
  raise;
  --
end create_job_extra_info;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_job_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_job_extra_info
  (p_validate                     in     boolean  default false
  ,p_job_extra_info_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_jei_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_jei_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_jei_information1             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information2             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information3             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information4             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information5             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information6             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information7             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information8             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information9             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information10            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information11            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information12            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information13            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information14            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information15            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information16            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information17            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information18            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information19            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information20            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information21            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information22            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information23            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information24            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information25            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information26            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information27            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information28            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information29            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information30            in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_job_extra_info';
  l_object_version_number per_job_extra_info.object_version_number%TYPE;
  l_ovn per_job_extra_info.object_version_number%TYPE := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint update_job_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
	per_job_extra_info_bk2.update_job_extra_info_b
		(
		p_job_extra_info_id		=>	p_job_extra_info_id,
		p_jei_attribute_category	=>	p_jei_attribute_category,
		p_jei_attribute1		=>	p_jei_attribute1,
		p_jei_attribute2		=>	p_jei_attribute2,
		p_jei_attribute3		=>	p_jei_attribute3,
		p_jei_attribute4		=>	p_jei_attribute4,
		p_jei_attribute5		=>	p_jei_attribute5,
		p_jei_attribute6		=>	p_jei_attribute6,
		p_jei_attribute7		=>	p_jei_attribute7,
		p_jei_attribute8		=>	p_jei_attribute8,
		p_jei_attribute9		=>	p_jei_attribute9,
		p_jei_attribute10		=>	p_jei_attribute10,
		p_jei_attribute11		=>	p_jei_attribute11,
		p_jei_attribute12		=>	p_jei_attribute12,
		p_jei_attribute13		=>	p_jei_attribute13,
		p_jei_attribute14		=>	p_jei_attribute14,
		p_jei_attribute15		=>	p_jei_attribute15,
		p_jei_attribute16		=>	p_jei_attribute16,
		p_jei_attribute17		=>	p_jei_attribute17,
		p_jei_attribute18		=>	p_jei_attribute18,
		p_jei_attribute19		=>	p_jei_attribute19,
		p_jei_attribute20		=>	p_jei_attribute20,
		p_jei_information_category	=>	p_jei_information_category,
		p_jei_information1		=>	p_jei_information1,
		p_jei_information2		=>	p_jei_information2,
		p_jei_information3		=>	p_jei_information3,
		p_jei_information4		=>	p_jei_information4,
		p_jei_information5		=>	p_jei_information5,
		p_jei_information6		=>	p_jei_information6,
		p_jei_information7		=>	p_jei_information7,
		p_jei_information8		=>	p_jei_information8,
		p_jei_information9		=>	p_jei_information9,
		p_jei_information10		=>	p_jei_information10,
		p_jei_information11		=>	p_jei_information11,
		p_jei_information12		=>	p_jei_information12,
		p_jei_information13		=>	p_jei_information13,
		p_jei_information14		=>	p_jei_information14,
		p_jei_information15		=>	p_jei_information15,
		p_jei_information16		=>	p_jei_information16,
		p_jei_information17		=>	p_jei_information17,
		p_jei_information18		=>	p_jei_information18,
		p_jei_information19		=>	p_jei_information19,
		p_jei_information20		=>	p_jei_information20,
		p_jei_information21		=>	p_jei_information21,
		p_jei_information22		=>	p_jei_information22,
		p_jei_information23		=>	p_jei_information23,
		p_jei_information24		=>	p_jei_information24,
		p_jei_information25		=>	p_jei_information25,
		p_jei_information26		=>	p_jei_information26,
		p_jei_information27		=>	p_jei_information27,
		p_jei_information28		=>	p_jei_information28,
		p_jei_information29		=>	p_jei_information29,
		p_jei_information30		=>	p_jei_information30,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_job_extra_info',
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
  -- Process Logic - Update job Extra Info details
  --
  pe_jei_upd.upd
  (p_job_extra_info_id            => p_job_extra_info_id
  ,p_jei_attribute_category       => p_jei_attribute_category
  ,p_jei_attribute1               => p_jei_attribute1
  ,p_jei_attribute2               => p_jei_attribute2
  ,p_jei_attribute3               => p_jei_attribute3
  ,p_jei_attribute4               => p_jei_attribute4
  ,p_jei_attribute5               => p_jei_attribute5
  ,p_jei_attribute6               => p_jei_attribute6
  ,p_jei_attribute7               => p_jei_attribute7
  ,p_jei_attribute8               => p_jei_attribute8
  ,p_jei_attribute9               => p_jei_attribute9
  ,p_jei_attribute10              => p_jei_attribute10
  ,p_jei_attribute11              => p_jei_attribute11
  ,p_jei_attribute12              => p_jei_attribute12
  ,p_jei_attribute13              => p_jei_attribute13
  ,p_jei_attribute14              => p_jei_attribute14
  ,p_jei_attribute15              => p_jei_attribute15
  ,p_jei_attribute16              => p_jei_attribute16
  ,p_jei_attribute17              => p_jei_attribute17
  ,p_jei_attribute18              => p_jei_attribute18
  ,p_jei_attribute19              => p_jei_attribute19
  ,p_jei_attribute20              => p_jei_attribute20
  ,p_jei_information_category     => p_jei_information_category
  ,p_jei_information1             => p_jei_information1
  ,p_jei_information2             => p_jei_information2
  ,p_jei_information3             => p_jei_information3
  ,p_jei_information4             => p_jei_information4
  ,p_jei_information5             => p_jei_information5
  ,p_jei_information6             => p_jei_information6
  ,p_jei_information7             => p_jei_information7
  ,p_jei_information8             => p_jei_information8
  ,p_jei_information9             => p_jei_information9
  ,p_jei_information10            => p_jei_information10
  ,p_jei_information11            => p_jei_information11
  ,p_jei_information12            => p_jei_information12
  ,p_jei_information13            => p_jei_information13
  ,p_jei_information14            => p_jei_information14
  ,p_jei_information15            => p_jei_information15
  ,p_jei_information16            => p_jei_information16
  ,p_jei_information17            => p_jei_information17
  ,p_jei_information18            => p_jei_information18
  ,p_jei_information19            => p_jei_information19
  ,p_jei_information20            => p_jei_information20
  ,p_jei_information21            => p_jei_information21
  ,p_jei_information22            => p_jei_information22
  ,p_jei_information23            => p_jei_information23
  ,p_jei_information24            => p_jei_information24
  ,p_jei_information25            => p_jei_information25
  ,p_jei_information26            => p_jei_information26
  ,p_jei_information27            => p_jei_information27
  ,p_jei_information28            => p_jei_information28
  ,p_jei_information29            => p_jei_information29
  ,p_jei_information30            => p_jei_information30
  ,p_object_version_number        => p_object_version_number
  ,p_validate                     => false
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	per_job_extra_info_bk2.update_job_extra_info_a
		(
		p_job_extra_info_id		=>	p_job_extra_info_id,
		p_jei_attribute_category	=>	p_jei_attribute_category,
		p_jei_attribute1		=>	p_jei_attribute1,
		p_jei_attribute2		=>	p_jei_attribute2,
		p_jei_attribute3		=>	p_jei_attribute3,
		p_jei_attribute4		=>	p_jei_attribute4,
		p_jei_attribute5		=>	p_jei_attribute5,
		p_jei_attribute6		=>	p_jei_attribute6,
		p_jei_attribute7		=>	p_jei_attribute7,
		p_jei_attribute8		=>	p_jei_attribute8,
		p_jei_attribute9		=>	p_jei_attribute9,
		p_jei_attribute10		=>	p_jei_attribute10,
		p_jei_attribute11		=>	p_jei_attribute11,
		p_jei_attribute12		=>	p_jei_attribute12,
		p_jei_attribute13		=>	p_jei_attribute13,
		p_jei_attribute14		=>	p_jei_attribute14,
		p_jei_attribute15		=>	p_jei_attribute15,
		p_jei_attribute16		=>	p_jei_attribute16,
		p_jei_attribute17		=>	p_jei_attribute17,
		p_jei_attribute18		=>	p_jei_attribute18,
		p_jei_attribute19		=>	p_jei_attribute19,
		p_jei_attribute20		=>	p_jei_attribute20,
		p_jei_information_category	=>	p_jei_information_category,
		p_jei_information1		=>	p_jei_information1,
		p_jei_information2		=>	p_jei_information2,
		p_jei_information3		=>	p_jei_information3,
		p_jei_information4		=>	p_jei_information4,
		p_jei_information5		=>	p_jei_information5,
		p_jei_information6		=>	p_jei_information6,
		p_jei_information7		=>	p_jei_information7,
		p_jei_information8		=>	p_jei_information8,
		p_jei_information9		=>	p_jei_information9,
		p_jei_information10		=>	p_jei_information10,
		p_jei_information11		=>	p_jei_information11,
		p_jei_information12		=>	p_jei_information12,
		p_jei_information13		=>	p_jei_information13,
		p_jei_information14		=>	p_jei_information14,
		p_jei_information15		=>	p_jei_information15,
		p_jei_information16		=>	p_jei_information16,
		p_jei_information17		=>	p_jei_information17,
		p_jei_information18		=>	p_jei_information18,
		p_jei_information19		=>	p_jei_information19,
		p_jei_information20		=>	p_jei_information20,
		p_jei_information21		=>	p_jei_information21,
		p_jei_information22		=>	p_jei_information22,
		p_jei_information23		=>	p_jei_information23,
		p_jei_information24		=>	p_jei_information24,
		p_jei_information25		=>	p_jei_information25,
		p_jei_information26		=>	p_jei_information26,
		p_jei_information27		=>	p_jei_information27,
		p_jei_information28		=>	p_jei_information28,
		p_jei_information29		=>	p_jei_information29,
		p_jei_information30		=>	p_jei_information30,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_job_extra_info',
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
    ROLLBACK TO update_job_extra_info;
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
  ROLLBACK TO update_job_extra_info;
    --
    -- set in out parameters and set out parameters
    --
   p_object_version_number  := l_ovn;
  --
  raise;
  --
end update_job_extra_info;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_job_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_job_extra_info
  (p_validate                 in     boolean  default false
  ,p_job_extra_info_id        in     number
  ,p_object_version_number    in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_job_extra_info';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint delete_job_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
	per_job_extra_info_bk3.delete_job_extra_info_b
		(
		p_job_extra_info_id		=>	p_job_extra_info_id,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_job_extra_info',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic - Delete job Extra Info details
  --
  pe_jei_del.del
  (p_job_extra_info_id             => p_job_extra_info_id
  ,p_object_version_number         => p_object_version_number
  ,p_validate                      => false
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	per_job_extra_info_bk3.delete_job_extra_info_a
		(
		p_job_extra_info_id		=>	p_job_extra_info_id,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_job_extra_info',
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
    ROLLBACK TO delete_job_extra_info;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO delete_job_extra_info;
  --
  raise;
  --
end delete_job_extra_info;
--
end per_job_extra_info_api;

/
