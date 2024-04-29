--------------------------------------------------------
--  DDL for Package Body PQH_ROLE_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ROLE_EXTRA_INFO_API" as
/* $Header: pqreiapi.pkb 115.1 2002/12/10 11:14:04 mvankada noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_role_extra_info_api.';
--
-- ---------------------------------------------------------------------------+
-- |----------------------< create_role_extra_info >--------------------------|
-- ---------------------------------------------------------------------------+
--
procedure create_role_extra_info
  (p_validate                     in     boolean
  ,p_role_id                       in     number
  ,p_information_type             in     varchar2
  ,p_attribute_category       in     varchar2
  ,p_attribute1               in     varchar2
  ,p_attribute2               in     varchar2
  ,p_attribute3               in     varchar2
  ,p_attribute4               in     varchar2
  ,p_attribute5               in     varchar2
  ,p_attribute6               in     varchar2
  ,p_attribute7               in     varchar2
  ,p_attribute8               in     varchar2
  ,p_attribute9               in     varchar2
  ,p_attribute10              in     varchar2
  ,p_attribute11              in     varchar2
  ,p_attribute12              in     varchar2
  ,p_attribute13              in     varchar2
  ,p_attribute14              in     varchar2
  ,p_attribute15              in     varchar2
  ,p_attribute16              in     varchar2
  ,p_attribute17              in     varchar2
  ,p_attribute18              in     varchar2
  ,p_attribute19              in     varchar2
  ,p_attribute20              in     varchar2
  ,p_attribute21              in     varchar2
  ,p_attribute22              in     varchar2
  ,p_attribute23              in     varchar2
  ,p_attribute24              in     varchar2
  ,p_attribute25              in     varchar2
  ,p_attribute26              in     varchar2
  ,p_attribute27              in     varchar2
  ,p_attribute28              in     varchar2
  ,p_attribute29              in     varchar2
  ,p_attribute30              in     varchar2
  ,p_information_category     in     varchar2
  ,p_information1             in     varchar2
  ,p_information2             in     varchar2
  ,p_information3             in     varchar2
  ,p_information4             in     varchar2
  ,p_information5             in     varchar2
  ,p_information6             in     varchar2
  ,p_information7             in     varchar2
  ,p_information8             in     varchar2
  ,p_information9             in     varchar2
  ,p_information10            in     varchar2
  ,p_information11            in     varchar2
  ,p_information12            in     varchar2
  ,p_information13            in     varchar2
  ,p_information14            in     varchar2
  ,p_information15            in     varchar2
  ,p_information16            in     varchar2
  ,p_information17            in     varchar2
  ,p_information18            in     varchar2
  ,p_information19            in     varchar2
  ,p_information20            in     varchar2
  ,p_information21            in     varchar2
  ,p_information22            in     varchar2
  ,p_information23            in     varchar2
  ,p_information24            in     varchar2
  ,p_information25            in     varchar2
  ,p_information26            in     varchar2
  ,p_information27            in     varchar2
  ,p_information28            in     varchar2
  ,p_information29            in     varchar2
  ,p_information30            in     varchar2
  ,p_role_extra_info_id            out  nocopy  number
  ,p_object_version_number        out   nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_role_extra_info';
  l_object_version_number	pqh_role_extra_info.object_version_number%type;
  l_role_extra_info_id		pqh_role_extra_info.role_extra_info_id%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint create_role_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
	pqh_role_extra_info_bk1.create_role_extra_info_b
		(
		p_information_type		=>	p_information_type,
		p_role_id			=>	p_role_id,
		p_attribute_category	=>	p_attribute_category,
		p_attribute1		=>	p_attribute1,
		p_attribute2		=>	p_attribute2,
		p_attribute3		=>	p_attribute3,
		p_attribute4		=>	p_attribute4,
		p_attribute5		=>	p_attribute5,
		p_attribute6		=>	p_attribute6,
		p_attribute7		=>	p_attribute7,
		p_attribute8		=>	p_attribute8,
		p_attribute9		=>	p_attribute9,
		p_attribute10		=>	p_attribute10,
		p_attribute11		=>	p_attribute11,
		p_attribute12		=>	p_attribute12,
		p_attribute13		=>	p_attribute13,
		p_attribute14		=>	p_attribute14,
		p_attribute15		=>	p_attribute15,
		p_attribute16		=>	p_attribute16,
		p_attribute17		=>	p_attribute17,
		p_attribute18		=>	p_attribute18,
		p_attribute19		=>	p_attribute19,
		p_attribute20		=>	p_attribute20,
		p_attribute21		=>	p_attribute21,
		p_attribute22		=>	p_attribute22,
		p_attribute23		=>	p_attribute23,
		p_attribute24		=>	p_attribute24,
		p_attribute25		=>	p_attribute25,
		p_attribute26		=>	p_attribute26,
		p_attribute27		=>	p_attribute27,
		p_attribute28		=>	p_attribute28,
		p_attribute29		=>	p_attribute29,
		p_attribute30		=>	p_attribute30,
		p_information_category	=>	p_information_category,
		p_information1		=>	p_information1,
		p_information2		=>	p_information2,
		p_information3		=>	p_information3,
		p_information4		=>	p_information4,
		p_information5		=>	p_information5,
		p_information6		=>	p_information6,
		p_information7		=>	p_information7,
		p_information8		=>	p_information8,
		p_information9		=>	p_information9,
		p_information10		=>	p_information10,
		p_information11		=>	p_information11,
		p_information12		=>	p_information12,
		p_information13		=>	p_information13,
		p_information14		=>	p_information14,
		p_information15		=>	p_information15,
		p_information16		=>	p_information16,
		p_information17		=>	p_information17,
		p_information18		=>	p_information18,
		p_information19		=>	p_information19,
		p_information20		=>	p_information20,
		p_information21		=>	p_information21,
		p_information22		=>	p_information22,
		p_information23		=>	p_information23,
		p_information24		=>	p_information24,
		p_information25		=>	p_information25,
		p_information26		=>	p_information26,
		p_information27		=>	p_information27,
		p_information28		=>	p_information28,
		p_information29		=>	p_information29,
		p_information30		=>	p_information30
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_role_extra_info',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  pqh_rei_ins.ins
  (p_role_extra_info_id       => l_role_extra_info_id
  ,p_role_id                  => p_role_id
  ,p_information_type         => p_information_type
  ,p_attribute_category       => p_attribute_category
  ,p_attribute1               => p_attribute1
  ,p_attribute2               => p_attribute2
  ,p_attribute3               => p_attribute3
  ,p_attribute4               => p_attribute4
  ,p_attribute5               => p_attribute5
  ,p_attribute6               => p_attribute6
  ,p_attribute7               => p_attribute7
  ,p_attribute8               => p_attribute8
  ,p_attribute9               => p_attribute9
  ,p_attribute10              => p_attribute10
  ,p_attribute11              => p_attribute11
  ,p_attribute12              => p_attribute12
  ,p_attribute13              => p_attribute13
  ,p_attribute14              => p_attribute14
  ,p_attribute15              => p_attribute15
  ,p_attribute16              => p_attribute16
  ,p_attribute17              => p_attribute17
  ,p_attribute18              => p_attribute18
  ,p_attribute19              => p_attribute19
  ,p_attribute20              => p_attribute20
  ,p_attribute21              => p_attribute21
  ,p_attribute22	      => p_attribute22
  ,p_attribute23	      => p_attribute23
  ,p_attribute24	      => p_attribute24
  ,p_attribute25	      => p_attribute25
  ,p_attribute26	      => p_attribute26
  ,p_attribute27	      => p_attribute27
  ,p_attribute28	      => p_attribute28
  ,p_attribute29	      => p_attribute29
  ,p_attribute30	      => p_attribute30
  ,p_information_category     => p_information_category
  ,p_information1             => p_information1
  ,p_information2             => p_information2
  ,p_information3             => p_information3
  ,p_information4             => p_information4
  ,p_information5             => p_information5
  ,p_information6             => p_information6
  ,p_information7             => p_information7
  ,p_information8             => p_information8
  ,p_information9             => p_information9
  ,p_information10            => p_information10
  ,p_information11            => p_information11
  ,p_information12            => p_information12
  ,p_information13            => p_information13
  ,p_information14            => p_information14
  ,p_information15            => p_information15
  ,p_information16            => p_information16
  ,p_information17            => p_information17
  ,p_information18            => p_information18
  ,p_information19            => p_information19
  ,p_information20            => p_information20
  ,p_information21            => p_information21
  ,p_information22            => p_information22
  ,p_information23            => p_information23
  ,p_information24            => p_information24
  ,p_information25            => p_information25
  ,p_information26            => p_information26
  ,p_information27            => p_information27
  ,p_information28            => p_information28
  ,p_information29            => p_information29
  ,p_information30            => p_information30
  ,p_object_version_number        => l_object_version_number
  ,p_validate                     => false
  );
  p_object_version_number	:= l_object_version_number;
  p_role_extra_info_id		:= l_role_extra_info_id;
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	pqh_role_extra_info_bk1.create_role_extra_info_a
		(
		p_role_extra_info_id	=>	l_role_extra_info_id,
		p_information_type	=>	p_information_type,
		p_role_id		=>	p_role_id,
		p_attribute_category	=>	p_attribute_category,
		p_attribute1		=>	p_attribute1,
		p_attribute2		=>	p_attribute2,
		p_attribute3		=>	p_attribute3,
		p_attribute4		=>	p_attribute4,
		p_attribute5		=>	p_attribute5,
		p_attribute6		=>	p_attribute6,
		p_attribute7		=>	p_attribute7,
		p_attribute8		=>	p_attribute8,
		p_attribute9		=>	p_attribute9,
		p_attribute10		=>	p_attribute10,
		p_attribute11		=>	p_attribute11,
		p_attribute12		=>	p_attribute12,
		p_attribute13		=>	p_attribute13,
		p_attribute14		=>	p_attribute14,
		p_attribute15		=>	p_attribute15,
		p_attribute16		=>	p_attribute16,
		p_attribute17		=>	p_attribute17,
		p_attribute18		=>	p_attribute18,
		p_attribute19		=>	p_attribute19,
		p_attribute20		=>	p_attribute20,
		p_attribute21		=>	p_attribute21,
		p_attribute22		=>	p_attribute22,
		p_attribute23		=>	p_attribute23,
		p_attribute24		=>	p_attribute24,
		p_attribute25		=>	p_attribute25,
		p_attribute26		=>	p_attribute26,
		p_attribute27		=>	p_attribute27,
		p_attribute28		=>	p_attribute28,
		p_attribute29		=>	p_attribute29,
		p_attribute30		=>	p_attribute30,
		p_information_category	=>	p_information_category,
		p_information1		=>	p_information1,
		p_information2		=>	p_information2,
		p_information3		=>	p_information3,
		p_information4		=>	p_information4,
		p_information5		=>	p_information5,
		p_information6		=>	p_information6,
		p_information7		=>	p_information7,
		p_information8		=>	p_information8,
		p_information9		=>	p_information9,
		p_information10		=>	p_information10,
		p_information11		=>	p_information11,
		p_information12		=>	p_information12,
		p_information13		=>	p_information13,
		p_information14		=>	p_information14,
		p_information15		=>	p_information15,
		p_information16		=>	p_information16,
		p_information17		=>	p_information17,
		p_information18		=>	p_information18,
		p_information19		=>	p_information19,
		p_information20		=>	p_information20,
		p_information21		=>	p_information21,
		p_information22		=>	p_information22,
		p_information23		=>	p_information23,
		p_information24		=>	p_information24,
		p_information25		=>	p_information25,
		p_information26		=>	p_information26,
		p_information27		=>	p_information27,
		p_information28		=>	p_information28,
		p_information29		=>	p_information29,
		p_information30		=>	p_information30,
		p_object_version_number		=>	l_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_role_extra_info',
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
    ROLLBACK TO create_role_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_role_extra_info_id := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
  when others then

    p_role_extra_info_id := null;
    p_object_version_number  := null;
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO create_role_extra_info;
  --
  raise;
  --
end create_role_extra_info;
--
-- ----------------------------------------------------------------------------+
-- |----------------------< update_role_extra_info >----------------------|
-- ---------------------------------------------------------------------------+
--
procedure update_role_extra_info
  (p_validate                     in     boolean
  ,p_role_extra_info_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_attribute_category       in     varchar2
  ,p_attribute1               in     varchar2
  ,p_attribute2               in     varchar2
  ,p_attribute3               in     varchar2
  ,p_attribute4               in     varchar2
  ,p_attribute5               in     varchar2
  ,p_attribute6               in     varchar2
  ,p_attribute7               in     varchar2
  ,p_attribute8               in     varchar2
  ,p_attribute9               in     varchar2
  ,p_attribute10              in     varchar2
  ,p_attribute11              in     varchar2
  ,p_attribute12              in     varchar2
  ,p_attribute13              in     varchar2
  ,p_attribute14              in     varchar2
  ,p_attribute15              in     varchar2
  ,p_attribute16              in     varchar2
  ,p_attribute17              in     varchar2
  ,p_attribute18              in     varchar2
  ,p_attribute19              in     varchar2
  ,p_attribute20              in     varchar2
  ,p_attribute21              in     varchar2
  ,p_attribute22              in     varchar2
  ,p_attribute23              in     varchar2
  ,p_attribute24              in     varchar2
  ,p_attribute25              in     varchar2
  ,p_attribute26              in     varchar2
  ,p_attribute27              in     varchar2
  ,p_attribute28              in     varchar2
  ,p_attribute29              in     varchar2
  ,p_attribute30              in     varchar2
  ,p_information_category     in     varchar2
  ,p_information1             in     varchar2
  ,p_information2             in     varchar2
  ,p_information3             in     varchar2
  ,p_information4             in     varchar2
  ,p_information5             in     varchar2
  ,p_information6             in     varchar2
  ,p_information7             in     varchar2
  ,p_information8             in     varchar2
  ,p_information9             in     varchar2
  ,p_information10            in     varchar2
  ,p_information11            in     varchar2
  ,p_information12            in     varchar2
  ,p_information13            in     varchar2
  ,p_information14            in     varchar2
  ,p_information15            in     varchar2
  ,p_information16            in     varchar2
  ,p_information17            in     varchar2
  ,p_information18            in     varchar2
  ,p_information19            in     varchar2
  ,p_information20            in     varchar2
  ,p_information21            in     varchar2
  ,p_information22            in     varchar2
  ,p_information23            in     varchar2
  ,p_information24            in     varchar2
  ,p_information25            in     varchar2
  ,p_information26            in     varchar2
  ,p_information27            in     varchar2
  ,p_information28            in     varchar2
  ,p_information29            in     varchar2
  ,p_information30            in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_role_extra_info';
  l_object_version_number pqh_role_extra_info.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint update_role_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
	pqh_role_extra_info_bk2.update_role_extra_info_b
		(
		p_role_extra_info_id	=>	p_role_extra_info_id,
		p_attribute_category	=>	p_attribute_category,
		p_attribute1		=>	p_attribute1,
		p_attribute2		=>	p_attribute2,
		p_attribute3		=>	p_attribute3,
		p_attribute4		=>	p_attribute4,
		p_attribute5		=>	p_attribute5,
		p_attribute6		=>	p_attribute6,
		p_attribute7		=>	p_attribute7,
		p_attribute8		=>	p_attribute8,
		p_attribute9		=>	p_attribute9,
		p_attribute10		=>	p_attribute10,
		p_attribute11		=>	p_attribute11,
		p_attribute12		=>	p_attribute12,
		p_attribute13		=>	p_attribute13,
		p_attribute14		=>	p_attribute14,
		p_attribute15		=>	p_attribute15,
		p_attribute16		=>	p_attribute16,
		p_attribute17		=>	p_attribute17,
		p_attribute18		=>	p_attribute18,
		p_attribute19		=>	p_attribute19,
		p_attribute20		=>	p_attribute20,
		p_attribute21		=>	p_attribute21,
		p_attribute22		=>	p_attribute22,
		p_attribute23		=>	p_attribute23,
		p_attribute24		=>	p_attribute24,
		p_attribute25		=>	p_attribute25,
		p_attribute26		=>	p_attribute26,
		p_attribute27		=>	p_attribute27,
		p_attribute28		=>	p_attribute28,
		p_attribute29		=>	p_attribute29,
		p_attribute30		=>	p_attribute30,
		p_information_category	=>	p_information_category,
		p_information1		=>	p_information1,
		p_information2		=>	p_information2,
		p_information3		=>	p_information3,
		p_information4		=>	p_information4,
		p_information5		=>	p_information5,
		p_information6		=>	p_information6,
		p_information7		=>	p_information7,
		p_information8		=>	p_information8,
		p_information9		=>	p_information9,
		p_information10		=>	p_information10,
		p_information11		=>	p_information11,
		p_information12		=>	p_information12,
		p_information13		=>	p_information13,
		p_information14		=>	p_information14,
		p_information15		=>	p_information15,
		p_information16		=>	p_information16,
		p_information17		=>	p_information17,
		p_information18		=>	p_information18,
		p_information19		=>	p_information19,
		p_information20		=>	p_information20,
		p_information21		=>	p_information21,
		p_information22		=>	p_information22,
		p_information23		=>	p_information23,
		p_information24		=>	p_information24,
		p_information25		=>	p_information25,
		p_information26		=>	p_information26,
		p_information27		=>	p_information27,
		p_information28		=>	p_information28,
		p_information29		=>	p_information29,
		p_information30		=>	p_information30,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_role_extra_info',
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
  -- Process Logic - Update role Extra Info details
  --
  pqh_rei_upd.upd
  (p_role_extra_info_id       => p_role_extra_info_id
  ,p_attribute_category       => p_attribute_category
  ,p_attribute1               => p_attribute1
  ,p_attribute2               => p_attribute2
  ,p_attribute3               => p_attribute3
  ,p_attribute4               => p_attribute4
  ,p_attribute5               => p_attribute5
  ,p_attribute6               => p_attribute6
  ,p_attribute7               => p_attribute7
  ,p_attribute8               => p_attribute8
  ,p_attribute9               => p_attribute9
  ,p_attribute10              => p_attribute10
  ,p_attribute11              => p_attribute11
  ,p_attribute12              => p_attribute12
  ,p_attribute13              => p_attribute13
  ,p_attribute14              => p_attribute14
  ,p_attribute15              => p_attribute15
  ,p_attribute16              => p_attribute16
  ,p_attribute17              => p_attribute17
  ,p_attribute18              => p_attribute18
  ,p_attribute19              => p_attribute19
  ,p_attribute20              => p_attribute20
  ,p_attribute21              => p_attribute21
  ,p_attribute22              => p_attribute22
  ,p_attribute23              => p_attribute23
  ,p_attribute24              => p_attribute24
  ,p_attribute25              => p_attribute25
  ,p_attribute26              => p_attribute26
  ,p_attribute27              => p_attribute27
  ,p_attribute28              => p_attribute28
  ,p_attribute29              => p_attribute29
  ,p_attribute30              => p_attribute30
  ,p_information_category     => p_information_category
  ,p_information1             => p_information1
  ,p_information2             => p_information2
  ,p_information3             => p_information3
  ,p_information4             => p_information4
  ,p_information5             => p_information5
  ,p_information6             => p_information6
  ,p_information7             => p_information7
  ,p_information8             => p_information8
  ,p_information9             => p_information9
  ,p_information10            => p_information10
  ,p_information11            => p_information11
  ,p_information12            => p_information12
  ,p_information13            => p_information13
  ,p_information14            => p_information14
  ,p_information15            => p_information15
  ,p_information16            => p_information16
  ,p_information17            => p_information17
  ,p_information18            => p_information18
  ,p_information19            => p_information19
  ,p_information20            => p_information20
  ,p_information21            => p_information21
  ,p_information22            => p_information22
  ,p_information23            => p_information23
  ,p_information24            => p_information24
  ,p_information25            => p_information25
  ,p_information26            => p_information26
  ,p_information27            => p_information27
  ,p_information28            => p_information28
  ,p_information29            => p_information29
  ,p_information30            => p_information30
  ,p_object_version_number        => p_object_version_number
  ,p_validate                     => false
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	pqh_role_extra_info_bk2.update_role_extra_info_a
		(
		p_role_extra_info_id		=>	p_role_extra_info_id,
		p_attribute_category	=>	p_attribute_category,
		p_attribute1		=>	p_attribute1,
		p_attribute2		=>	p_attribute2,
		p_attribute3		=>	p_attribute3,
		p_attribute4		=>	p_attribute4,
		p_attribute5		=>	p_attribute5,
		p_attribute6		=>	p_attribute6,
		p_attribute7		=>	p_attribute7,
		p_attribute8		=>	p_attribute8,
		p_attribute9		=>	p_attribute9,
		p_attribute10		=>	p_attribute10,
		p_attribute11		=>	p_attribute11,
		p_attribute12		=>	p_attribute12,
		p_attribute13		=>	p_attribute13,
		p_attribute14		=>	p_attribute14,
		p_attribute15		=>	p_attribute15,
		p_attribute16		=>	p_attribute16,
		p_attribute17		=>	p_attribute17,
		p_attribute18		=>	p_attribute18,
		p_attribute19		=>	p_attribute19,
		p_attribute20		=>	p_attribute20,
		p_attribute21		=>	p_attribute21,
		p_attribute22		=>	p_attribute22,
		p_attribute23		=>	p_attribute23,
		p_attribute24		=>	p_attribute24,
		p_attribute25		=>	p_attribute25,
		p_attribute26		=>	p_attribute26,
		p_attribute27		=>	p_attribute27,
		p_attribute28		=>	p_attribute28,
		p_attribute29		=>	p_attribute29,
		p_attribute30		=>	p_attribute30,
		p_information_category	=>	p_information_category,
		p_information1		=>	p_information1,
		p_information2		=>	p_information2,
		p_information3		=>	p_information3,
		p_information4		=>	p_information4,
		p_information5		=>	p_information5,
		p_information6		=>	p_information6,
		p_information7		=>	p_information7,
		p_information8		=>	p_information8,
		p_information9		=>	p_information9,
		p_information10		=>	p_information10,
		p_information11		=>	p_information11,
		p_information12		=>	p_information12,
		p_information13		=>	p_information13,
		p_information14		=>	p_information14,
		p_information15		=>	p_information15,
		p_information16		=>	p_information16,
		p_information17		=>	p_information17,
		p_information18		=>	p_information18,
		p_information19		=>	p_information19,
		p_information20		=>	p_information20,
		p_information21		=>	p_information21,
		p_information22		=>	p_information22,
		p_information23		=>	p_information23,
		p_information24		=>	p_information24,
		p_information25		=>	p_information25,
		p_information26		=>	p_information26,
		p_information27		=>	p_information27,
		p_information28		=>	p_information28,
		p_information29		=>	p_information29,
		p_information30		=>	p_information30,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_role_extra_info',
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
    ROLLBACK TO update_role_extra_info;
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

  p_object_version_number := l_object_version_number;
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO update_role_extra_info;
  --
  raise;
  --
end update_role_extra_info;
--
--
-- ---------------------------------------------------------------------------+
-- |----------------------< delete_role_extra_info >----------------------|
-- ---------------------------------------------------------------------------+
--
procedure delete_role_extra_info
  (p_validate                 in     boolean
  ,p_role_extra_info_id        in     number
  ,p_object_version_number    in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_role_extra_info';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint delete_role_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
	pqh_role_extra_info_bk3.delete_role_extra_info_b
		(
		p_role_extra_info_id		=>	p_role_extra_info_id,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_role_extra_info',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic - Delete role Extra Info details
  --
  pqh_rei_del.del
  (p_role_extra_info_id             => p_role_extra_info_id
  ,p_object_version_number         => p_object_version_number
  ,p_validate                      => false
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	pqh_role_extra_info_bk3.delete_role_extra_info_a
		(
		p_role_extra_info_id		=>	p_role_extra_info_id,
		p_object_version_number		=>	p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_role_extra_info',
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
    ROLLBACK TO delete_role_extra_info;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO delete_role_extra_info;
  --
  raise;
  --
end delete_role_extra_info;
--
end pqh_role_extra_info_api;

/
