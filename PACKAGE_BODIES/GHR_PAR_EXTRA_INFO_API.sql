--------------------------------------------------------
--  DDL for Package Body GHR_PAR_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PAR_EXTRA_INFO_API" as
/* $Header: ghreiapi.pkb 120.7.12000000.1 2007/01/18 14:10:36 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_par_extra_info_api.';
--

PROCEDURE validate_extra_info
   (p_pa_request_id NUMBER
  ,p_information_type VARCHAR2
  ,p_rei_information_category  VARCHAR2
  ,p_rei_information1  VARCHAR2
  ,p_rei_information2  VARCHAR2
  ,p_rei_information3  VARCHAR2
  ,p_rei_information4  VARCHAR2
  ,p_rei_information5  VARCHAR2
  ,p_rei_information6  VARCHAR2
  ,p_rei_information7  VARCHAR2
  ,p_rei_information8  VARCHAR2
  ,p_rei_information9  VARCHAR2
  ,p_rei_information10  VARCHAR2
  ,p_rei_information11  VARCHAR2
  ,p_rei_information12  VARCHAR2
  ,p_rei_information13  VARCHAR2
  ,p_rei_information14  VARCHAR2
  ,p_rei_information15  VARCHAR2
  ,p_rei_information16  VARCHAR2
  ,p_rei_information17  VARCHAR2
  ,p_rei_information18  VARCHAR2
  ,p_rei_information19  VARCHAR2
  ,p_rei_information20  VARCHAR2
  ,p_rei_information21  VARCHAR2
  ,p_rei_information22  VARCHAR2
  ,p_rei_information23  VARCHAR2
  ,p_rei_information24  VARCHAR2
  ,p_rei_information25  VARCHAR2
  ,p_rei_information26  VARCHAR2
  ,p_rei_information27  VARCHAR2
  ,p_rei_information28  VARCHAR2
  ,p_rei_information29  VARCHAR2
  ,p_rei_information30 VARCHAR2
  ,p_ben_ei_validate varchar2 default 'FALSE');

-- ----------------------------------------------------------------------------
-- |----------------------< create_pa_request_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pa_request_extra_info
  (p_validate                     in     boolean  default false
  ,p_pa_request_id                in     number
  ,p_information_type             in     varchar2
  ,p_rei_attribute_category       in     varchar2 default null
  ,p_rei_attribute1               in     varchar2 default null
  ,p_rei_attribute2               in     varchar2 default null
  ,p_rei_attribute3               in     varchar2 default null
  ,p_rei_attribute4               in     varchar2 default null
  ,p_rei_attribute5               in     varchar2 default null
  ,p_rei_attribute6               in     varchar2 default null
  ,p_rei_attribute7               in     varchar2 default null
  ,p_rei_attribute8               in     varchar2 default null
  ,p_rei_attribute9               in     varchar2 default null
  ,p_rei_attribute10              in     varchar2 default null
  ,p_rei_attribute11              in     varchar2 default null
  ,p_rei_attribute12              in     varchar2 default null
  ,p_rei_attribute13              in     varchar2 default null
  ,p_rei_attribute14              in     varchar2 default null
  ,p_rei_attribute15              in     varchar2 default null
  ,p_rei_attribute16              in     varchar2 default null
  ,p_rei_attribute17              in     varchar2 default null
  ,p_rei_attribute18              in     varchar2 default null
  ,p_rei_attribute19              in     varchar2 default null
  ,p_rei_attribute20              in     varchar2 default null
  ,p_rei_information_category     in     varchar2 default null
  ,p_rei_information1             in     varchar2 default null
  ,p_rei_information2             in     varchar2 default null
  ,p_rei_information3             in     varchar2 default null
  ,p_rei_information4             in     varchar2 default null
  ,p_rei_information5             in     varchar2 default null
  ,p_rei_information6             in     varchar2 default null
  ,p_rei_information7             in     varchar2 default null
  ,p_rei_information8             in     varchar2 default null
  ,p_rei_information9             in     varchar2 default null
  ,p_rei_information10            in     varchar2 default null
  ,p_rei_information11            in     varchar2 default null
  ,p_rei_information12            in     varchar2 default null
  ,p_rei_information13            in     varchar2 default null
  ,p_rei_information14            in     varchar2 default null
  ,p_rei_information15            in     varchar2 default null
  ,p_rei_information16            in     varchar2 default null
  ,p_rei_information17            in     varchar2 default null
  ,p_rei_information18            in     varchar2 default null
  ,p_rei_information19            in     varchar2 default null
  ,p_rei_information20            in     varchar2 default null
  ,p_rei_information21            in     varchar2 default null
  ,p_rei_information22            in     varchar2 default null
  ,p_rei_information23            in     varchar2 default null
  ,p_rei_information24            in     varchar2 default null
  ,p_rei_information25            in     varchar2 default null
  ,p_rei_information26            in     varchar2 default null
  ,p_rei_information27            in     varchar2 default null
  ,p_rei_information28            in     varchar2 default null
  ,p_rei_information29            in     varchar2 default null
  ,p_rei_information30            in     varchar2 default null
  ,p_pa_request_extra_info_id     out NOCOPY   number
  ,p_object_version_number        out NOCOPY   number
  ,p_ben_ei_validate			  in     varchar2 default 'FALSE'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  --
  CURSOR c_noa_family_code(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
  SELECT noa_family_code
  FROM ghr_pa_requests
  WHERE pa_request_id = c_pa_request_id;
  l_noa_family_code ghr_pa_requests.noa_family_code%type;

begin
  l_proc := g_package||'create_pa_request_extra_info';
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  savepoint create_pa_request_extra_info;
  --
  --
  -- Call Before Process User Hook
  --
  begin
	ghr_par_extra_info_bk1.create_par_extra_info_b	(
          p_pa_request_id                => p_pa_request_id
         ,p_information_type             => p_information_type
         ,p_rei_attribute_category       => p_rei_attribute_category
         ,p_rei_attribute1               => p_rei_attribute1
         ,p_rei_attribute2               => p_rei_attribute2
         ,p_rei_attribute3               => p_rei_attribute3
         ,p_rei_attribute4               => p_rei_attribute4
         ,p_rei_attribute5               => p_rei_attribute5
         ,p_rei_attribute6               => p_rei_attribute6
         ,p_rei_attribute7               => p_rei_attribute7
         ,p_rei_attribute8               => p_rei_attribute8
         ,p_rei_attribute9               => p_rei_attribute9
         ,p_rei_attribute10              => p_rei_attribute10
         ,p_rei_attribute11              => p_rei_attribute11
         ,p_rei_attribute12              => p_rei_attribute12
         ,p_rei_attribute13              => p_rei_attribute13
         ,p_rei_attribute14              => p_rei_attribute14
         ,p_rei_attribute15              => p_rei_attribute15
         ,p_rei_attribute16              => p_rei_attribute16
         ,p_rei_attribute17              => p_rei_attribute17
         ,p_rei_attribute18              => p_rei_attribute18
         ,p_rei_attribute19              => p_rei_attribute19
         ,p_rei_attribute20              => p_rei_attribute20
         ,p_rei_information_category     => p_rei_information_category
         ,p_rei_information1             => p_rei_information1
         ,p_rei_information2             => p_rei_information2
         ,p_rei_information3             => p_rei_information3
         ,p_rei_information4             => p_rei_information4
         ,p_rei_information5             => p_rei_information5
         ,p_rei_information6             => p_rei_information6
         ,p_rei_information7             => p_rei_information7
         ,p_rei_information8             => p_rei_information8
         ,p_rei_information9             => p_rei_information9
         ,p_rei_information10            => p_rei_information10
         ,p_rei_information11            => p_rei_information11
         ,p_rei_information12            => p_rei_information12
         ,p_rei_information13            => p_rei_information13
         ,p_rei_information14            => p_rei_information14
         ,p_rei_information15            => p_rei_information15
         ,p_rei_information16            => p_rei_information16
         ,p_rei_information17            => p_rei_information17
         ,p_rei_information18            => p_rei_information18
         ,p_rei_information19            => p_rei_information19
         ,p_rei_information20            => p_rei_information20
         ,p_rei_information21            => p_rei_information21
         ,p_rei_information22            => p_rei_information22
         ,p_rei_information23            => p_rei_information23
         ,p_rei_information24            => p_rei_information24
         ,p_rei_information25            => p_rei_information25
         ,p_rei_information26            => p_rei_information26
         ,p_rei_information27            => p_rei_information27
         ,p_rei_information28            => p_rei_information28
         ,p_rei_information29            => p_rei_information29
         ,p_rei_information30            => p_rei_information30
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_par_extra_info',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  hr_utility.set_location(l_proc, 7);
  -- Validation

  FOR l_cur_noa_family_code  IN c_noa_family_code(p_pa_request_id) LOOP
	l_noa_family_code := l_cur_noa_family_code.noa_family_code;
  END LOOP;

	IF l_noa_family_code IN ('APP','CONV_APP','EXT_NTE') THEN
		  validate_extra_info
		   (p_pa_request_id             => p_pa_request_id
		  ,p_information_type           => p_information_type
		  ,p_rei_information_category    => p_rei_information_category
		  ,p_rei_information1         	 => p_rei_information1
		  ,p_rei_information2         	 => p_rei_information2
		  ,p_rei_information3         	 => p_rei_information3
		  ,p_rei_information4         	 => p_rei_information4
		  ,p_rei_information5         	 => p_rei_information5
		  ,p_rei_information6         	 => p_rei_information6
		  ,p_rei_information7         	 => p_rei_information7
		  ,p_rei_information8         	 => p_rei_information8
		  ,p_rei_information9         	 => p_rei_information9
		  ,p_rei_information10        	 => p_rei_information10
		  ,p_rei_information11        	 => p_rei_information11
		  ,p_rei_information12        	 => p_rei_information12
		  ,p_rei_information13        	 => p_rei_information13
		  ,p_rei_information14        	 => p_rei_information14
		  ,p_rei_information15        	 => p_rei_information15
		  ,p_rei_information16        	 => p_rei_information16
		  ,p_rei_information17        	 => p_rei_information17
		  ,p_rei_information18        	 => p_rei_information18
		  ,p_rei_information19        	 => p_rei_information19
		  ,p_rei_information20        	 => p_rei_information20
		  ,p_rei_information21        	 => p_rei_information21
		  ,p_rei_information22        	 => p_rei_information22
		  ,p_rei_information23        	 => p_rei_information23
		  ,p_rei_information24        	 => p_rei_information24
		  ,p_rei_information25        	 => p_rei_information25
		  ,p_rei_information26        	 => p_rei_information26
		  ,p_rei_information27        	 => p_rei_information27
		  ,p_rei_information28        	 => p_rei_information28
		  ,p_rei_information29        	 => p_rei_information29
		  ,p_rei_information30 			 => p_rei_information30
		  ,p_ben_ei_validate			 => p_ben_ei_validate
		);
	END IF; -- IF l_noa_family_code = 'APP' THEN
  --

  -- Process Logic

  ghr_rei_ins.ins
  (p_pa_request_extra_info_id     => p_pa_request_extra_info_id
  ,p_pa_request_id                => p_pa_request_id
  ,p_information_type             => p_information_type
  ,p_rei_attribute_category       => p_rei_attribute_category
  ,p_rei_attribute1               => p_rei_attribute1
  ,p_rei_attribute2               => p_rei_attribute2
  ,p_rei_attribute3               => p_rei_attribute3
  ,p_rei_attribute4               => p_rei_attribute4
  ,p_rei_attribute5               => p_rei_attribute5
  ,p_rei_attribute6               => p_rei_attribute6
  ,p_rei_attribute7               => p_rei_attribute7
  ,p_rei_attribute8               => p_rei_attribute8
  ,p_rei_attribute9               => p_rei_attribute9
  ,p_rei_attribute10              => p_rei_attribute10
  ,p_rei_attribute11              => p_rei_attribute11
  ,p_rei_attribute12              => p_rei_attribute12
  ,p_rei_attribute13              => p_rei_attribute13
  ,p_rei_attribute14              => p_rei_attribute14
  ,p_rei_attribute15              => p_rei_attribute15
  ,p_rei_attribute16              => p_rei_attribute16
  ,p_rei_attribute17              => p_rei_attribute17
  ,p_rei_attribute18              => p_rei_attribute18
  ,p_rei_attribute19              => p_rei_attribute19
  ,p_rei_attribute20              => p_rei_attribute20
  ,p_rei_information_category     => p_rei_information_category
  ,p_rei_information1             => p_rei_information1
  ,p_rei_information2             => p_rei_information2
  ,p_rei_information3             => p_rei_information3
  ,p_rei_information4             => p_rei_information4
  ,p_rei_information5             => p_rei_information5
  ,p_rei_information6             => p_rei_information6
  ,p_rei_information7             => p_rei_information7
  ,p_rei_information8             => p_rei_information8
  ,p_rei_information9             => p_rei_information9
  ,p_rei_information10            => p_rei_information10
  ,p_rei_information11            => p_rei_information11
  ,p_rei_information12            => p_rei_information12
  ,p_rei_information13            => p_rei_information13
  ,p_rei_information14            => p_rei_information14
  ,p_rei_information15            => p_rei_information15
  ,p_rei_information16            => p_rei_information16
  ,p_rei_information17            => p_rei_information17
  ,p_rei_information18            => p_rei_information18
  ,p_rei_information19            => p_rei_information19
  ,p_rei_information20            => p_rei_information20
  ,p_rei_information21            => p_rei_information21
  ,p_rei_information22            => p_rei_information22
  ,p_rei_information23            => p_rei_information23
  ,p_rei_information24            => p_rei_information24
  ,p_rei_information25            => p_rei_information25
  ,p_rei_information26            => p_rei_information26
  ,p_rei_information27            => p_rei_information27
  ,p_rei_information28            => p_rei_information28
  ,p_rei_information29            => p_rei_information29
  ,p_rei_information30            => p_rei_information30
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
	ghr_par_extra_info_bk1.create_par_extra_info_a	(
          p_pa_request_extra_info_id     => p_pa_request_extra_info_id
         ,p_pa_request_id                => p_pa_request_id
         ,p_information_type             => p_information_type
         ,p_rei_attribute_category       => p_rei_attribute_category
         ,p_rei_attribute1               => p_rei_attribute1
         ,p_rei_attribute2               => p_rei_attribute2
         ,p_rei_attribute3               => p_rei_attribute3
         ,p_rei_attribute4               => p_rei_attribute4
         ,p_rei_attribute5               => p_rei_attribute5
         ,p_rei_attribute6               => p_rei_attribute6
         ,p_rei_attribute7               => p_rei_attribute7
         ,p_rei_attribute8               => p_rei_attribute8
         ,p_rei_attribute9               => p_rei_attribute9
         ,p_rei_attribute10              => p_rei_attribute10
         ,p_rei_attribute11              => p_rei_attribute11
         ,p_rei_attribute12              => p_rei_attribute12
         ,p_rei_attribute13              => p_rei_attribute13
         ,p_rei_attribute14              => p_rei_attribute14
         ,p_rei_attribute15              => p_rei_attribute15
         ,p_rei_attribute16              => p_rei_attribute16
         ,p_rei_attribute17              => p_rei_attribute17
         ,p_rei_attribute18              => p_rei_attribute18
         ,p_rei_attribute19              => p_rei_attribute19
         ,p_rei_attribute20              => p_rei_attribute20
         ,p_rei_information_category     => p_rei_information_category
         ,p_rei_information1             => p_rei_information1
         ,p_rei_information2             => p_rei_information2
         ,p_rei_information3             => p_rei_information3
         ,p_rei_information4             => p_rei_information4
         ,p_rei_information5             => p_rei_information5
         ,p_rei_information6             => p_rei_information6
         ,p_rei_information7             => p_rei_information7
         ,p_rei_information8             => p_rei_information8
         ,p_rei_information9             => p_rei_information9
         ,p_rei_information10            => p_rei_information10
         ,p_rei_information11            => p_rei_information11
         ,p_rei_information12            => p_rei_information12
         ,p_rei_information13            => p_rei_information13
         ,p_rei_information14            => p_rei_information14
         ,p_rei_information15            => p_rei_information15
         ,p_rei_information16            => p_rei_information16
         ,p_rei_information17            => p_rei_information17
         ,p_rei_information18            => p_rei_information18
         ,p_rei_information19            => p_rei_information19
         ,p_rei_information20            => p_rei_information20
         ,p_rei_information21            => p_rei_information21
         ,p_rei_information22            => p_rei_information22
         ,p_rei_information23            => p_rei_information23
         ,p_rei_information24            => p_rei_information24
         ,p_rei_information25            => p_rei_information25
         ,p_rei_information26            => p_rei_information26
         ,p_rei_information27            => p_rei_information27
         ,p_rei_information28            => p_rei_information28
         ,p_rei_information29            => p_rei_information29
         ,p_rei_information30            => p_rei_information30
         ,p_object_version_number        => p_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_par_extra_info',
				 p_hook_type	=> 'AP'
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
    ROLLBACK TO create_pa_request_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pa_request_extra_info_id := null;
    p_object_version_number  := null;
    --
    when others then
     ROLLBACK TO create_pa_request_extra_info;
     p_pa_request_extra_info_id := null;
     p_object_version_number  := null;
     hr_utility.set_location(' Leaving:'||l_proc, 12);
     raise;

end create_pa_request_extra_info;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_pa_request_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pa_request_extra_info
  (p_validate                     in     boolean  default false
  ,p_pa_request_extra_info_id     in     number
  ,p_object_version_number        in out NOCOPY number
  ,p_rei_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_rei_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_rei_information1             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information2             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information3             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information4             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information5             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information6             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information7             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information8             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information9             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information10            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information11            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information12            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information13            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information14            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information15            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information16            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information17            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information18            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information19            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information20            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information21            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information22            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information23            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information24            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information25            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information26            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information27            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information28            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information29            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information30            in     varchar2 default hr_api.g_varchar2
  ,p_ben_ei_validate			  in     varchar2 default 'FALSE'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) ;
  l_object_version_number ghr_pa_request_extra_info.object_version_number%TYPE;
  l_obj_version_number ghr_pa_request_extra_info.object_version_number%TYPE; -- NOCOPY changes
  --
  CURSOR c_noa_family_code(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
  SELECT noa_family_code
  FROM ghr_pa_requests
  WHERE pa_request_id = c_pa_request_id;
  l_noa_family_code ghr_pa_requests.noa_family_code%type;
  l_pa_req_id ghr_pa_requests.pa_request_id%type;
  l_information_type ghr_pa_request_extra_info.information_type%type;

  CURSOR c_pa_req_id (c_pa_req_extra_info_id ghr_pa_request_extra_info.pa_request_extra_info_id%type) IS
  SELECT pa_request_id, information_type
  FROM ghr_pa_request_extra_info
  WHERE pa_request_extra_info_id = c_pa_req_extra_info_id;

begin
  l_proc := g_package||'update_pa_request_extra_info';
  hr_utility.set_location('Entering:'|| l_proc, 5);
  l_obj_version_number := p_object_version_number;
  --
  savepoint update_pa_request_extra_info;
  --
  --
  -- Call Before Process User Hook
  --
  begin
	ghr_par_extra_info_bk2.update_par_extra_info_b	(
          p_pa_request_extra_info_id     => p_pa_request_extra_info_id
         ,p_rei_attribute_category       => p_rei_attribute_category
         ,p_rei_attribute1               => p_rei_attribute1
         ,p_rei_attribute2               => p_rei_attribute2
         ,p_rei_attribute3               => p_rei_attribute3
         ,p_rei_attribute4               => p_rei_attribute4
         ,p_rei_attribute5               => p_rei_attribute5
         ,p_rei_attribute6               => p_rei_attribute6
         ,p_rei_attribute7               => p_rei_attribute7
         ,p_rei_attribute8               => p_rei_attribute8
         ,p_rei_attribute9               => p_rei_attribute9
         ,p_rei_attribute10              => p_rei_attribute10
         ,p_rei_attribute11              => p_rei_attribute11
         ,p_rei_attribute12              => p_rei_attribute12
         ,p_rei_attribute13              => p_rei_attribute13
         ,p_rei_attribute14              => p_rei_attribute14
         ,p_rei_attribute15              => p_rei_attribute15
         ,p_rei_attribute16              => p_rei_attribute16
         ,p_rei_attribute17              => p_rei_attribute17
         ,p_rei_attribute18              => p_rei_attribute18
         ,p_rei_attribute19              => p_rei_attribute19
         ,p_rei_attribute20              => p_rei_attribute20
         ,p_rei_information_category     => p_rei_information_category
         ,p_rei_information1             => p_rei_information1
         ,p_rei_information2             => p_rei_information2
         ,p_rei_information3             => p_rei_information3
         ,p_rei_information4             => p_rei_information4
         ,p_rei_information5             => p_rei_information5
         ,p_rei_information6             => p_rei_information6
         ,p_rei_information7             => p_rei_information7
         ,p_rei_information8             => p_rei_information8
         ,p_rei_information9             => p_rei_information9
         ,p_rei_information10            => p_rei_information10
         ,p_rei_information11            => p_rei_information11
         ,p_rei_information12            => p_rei_information12
         ,p_rei_information13            => p_rei_information13
         ,p_rei_information14            => p_rei_information14
         ,p_rei_information15            => p_rei_information15
         ,p_rei_information16            => p_rei_information16
         ,p_rei_information17            => p_rei_information17
         ,p_rei_information18            => p_rei_information18
         ,p_rei_information19            => p_rei_information19
         ,p_rei_information20            => p_rei_information20
         ,p_rei_information21            => p_rei_information21
         ,p_rei_information22            => p_rei_information22
         ,p_rei_information23            => p_rei_information23
         ,p_rei_information24            => p_rei_information24
         ,p_rei_information25            => p_rei_information25
         ,p_rei_information26            => p_rei_information26
         ,p_rei_information27            => p_rei_information27
         ,p_rei_information28            => p_rei_information28
         ,p_rei_information29            => p_rei_information29
         ,p_rei_information30            => p_rei_information30
         ,p_object_version_number        => p_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
	          p_object_version_number := l_obj_version_number; -- NOCOPY Changes
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_par_extra_info',
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
-- Validation
  FOR l_cur_pa_req IN c_pa_req_id(p_pa_request_extra_info_id) LOOP
	l_pa_req_id := l_cur_pa_req.pa_request_id;
	l_information_type := l_cur_pa_req.information_type;
  END LOOP;

  FOR l_cur_noa_family_code  IN c_noa_family_code(l_pa_req_id) LOOP
	l_noa_family_code := l_cur_noa_family_code.noa_family_code;
  END LOOP;

	IF l_noa_family_code IN ('APP','CONV_APP','EXT_NTE') THEN
		  validate_extra_info
		   (p_pa_request_id             => l_pa_req_id
		  ,p_information_type           => l_information_type
		  ,p_rei_information_category    => p_rei_information_category
		  ,p_rei_information1         	 => p_rei_information1
		  ,p_rei_information2         	 => p_rei_information2
		  ,p_rei_information3         	 => p_rei_information3
		  ,p_rei_information4         	 => p_rei_information4
		  ,p_rei_information5         	 => p_rei_information5
		  ,p_rei_information6         	 => p_rei_information6
		  ,p_rei_information7         	 => p_rei_information7
		  ,p_rei_information8         	 => p_rei_information8
		  ,p_rei_information9         	 => p_rei_information9
		  ,p_rei_information10        	 => p_rei_information10
		  ,p_rei_information11        	 => p_rei_information11
		  ,p_rei_information12        	 => p_rei_information12
		  ,p_rei_information13        	 => p_rei_information13
		  ,p_rei_information14        	 => p_rei_information14
		  ,p_rei_information15        	 => p_rei_information15
		  ,p_rei_information16        	 => p_rei_information16
		  ,p_rei_information17        	 => p_rei_information17
		  ,p_rei_information18        	 => p_rei_information18
		  ,p_rei_information19        	 => p_rei_information19
		  ,p_rei_information20        	 => p_rei_information20
		  ,p_rei_information21        	 => p_rei_information21
		  ,p_rei_information22        	 => p_rei_information22
		  ,p_rei_information23        	 => p_rei_information23
		  ,p_rei_information24        	 => p_rei_information24
		  ,p_rei_information25        	 => p_rei_information25
		  ,p_rei_information26        	 => p_rei_information26
		  ,p_rei_information27        	 => p_rei_information27
		  ,p_rei_information28        	 => p_rei_information28
		  ,p_rei_information29        	 => p_rei_information29
		  ,p_rei_information30 			 => p_rei_information30
		  ,p_ben_ei_validate			 => p_ben_ei_validate
		);
	END IF; -- IF l_noa_family_code = 'APP' THEN
  --
  -- Process Logic - Update pa_request Extra Info details
  --


  ghr_rei_upd.upd
  (p_pa_request_extra_info_id     => p_pa_request_extra_info_id
  ,p_rei_attribute_category       => p_rei_attribute_category
  ,p_rei_attribute1               => p_rei_attribute1
  ,p_rei_attribute2               => p_rei_attribute2
  ,p_rei_attribute3               => p_rei_attribute3
  ,p_rei_attribute4               => p_rei_attribute4
  ,p_rei_attribute5               => p_rei_attribute5
  ,p_rei_attribute6               => p_rei_attribute6
  ,p_rei_attribute7               => p_rei_attribute7
  ,p_rei_attribute8               => p_rei_attribute8
  ,p_rei_attribute9               => p_rei_attribute9
  ,p_rei_attribute10              => p_rei_attribute10
  ,p_rei_attribute11              => p_rei_attribute11
  ,p_rei_attribute12              => p_rei_attribute12
  ,p_rei_attribute13              => p_rei_attribute13
  ,p_rei_attribute14              => p_rei_attribute14
  ,p_rei_attribute15              => p_rei_attribute15
  ,p_rei_attribute16              => p_rei_attribute16
  ,p_rei_attribute17              => p_rei_attribute17
  ,p_rei_attribute18              => p_rei_attribute18
  ,p_rei_attribute19              => p_rei_attribute19
  ,p_rei_attribute20              => p_rei_attribute20
  ,p_rei_information_category     => p_rei_information_category
  ,p_rei_information1             => p_rei_information1
  ,p_rei_information2             => p_rei_information2
  ,p_rei_information3             => p_rei_information3
  ,p_rei_information4             => p_rei_information4
  ,p_rei_information5             => p_rei_information5
  ,p_rei_information6             => p_rei_information6
  ,p_rei_information7             => p_rei_information7
  ,p_rei_information8             => p_rei_information8
  ,p_rei_information9             => p_rei_information9
  ,p_rei_information10            => p_rei_information10
  ,p_rei_information11            => p_rei_information11
  ,p_rei_information12            => p_rei_information12
  ,p_rei_information13            => p_rei_information13
  ,p_rei_information14            => p_rei_information14
  ,p_rei_information15            => p_rei_information15
  ,p_rei_information16            => p_rei_information16
  ,p_rei_information17            => p_rei_information17
  ,p_rei_information18            => p_rei_information18
  ,p_rei_information19            => p_rei_information19
  ,p_rei_information20            => p_rei_information20
  ,p_rei_information21            => p_rei_information21
  ,p_rei_information22            => p_rei_information22
  ,p_rei_information23            => p_rei_information23
  ,p_rei_information24            => p_rei_information24
  ,p_rei_information25            => p_rei_information25
  ,p_rei_information26            => p_rei_information26
  ,p_rei_information27            => p_rei_information27
  ,p_rei_information28            => p_rei_information28
  ,p_rei_information29            => p_rei_information29
  ,p_rei_information30            => p_rei_information30
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
	ghr_par_extra_info_bk2.update_par_extra_info_a	(
          p_pa_request_extra_info_id     => p_pa_request_extra_info_id
         ,p_rei_attribute_category       => p_rei_attribute_category
         ,p_rei_attribute1               => p_rei_attribute1
         ,p_rei_attribute2               => p_rei_attribute2
         ,p_rei_attribute3               => p_rei_attribute3
         ,p_rei_attribute4               => p_rei_attribute4
         ,p_rei_attribute5               => p_rei_attribute5
         ,p_rei_attribute6               => p_rei_attribute6
         ,p_rei_attribute7               => p_rei_attribute7
         ,p_rei_attribute8               => p_rei_attribute8
         ,p_rei_attribute9               => p_rei_attribute9
         ,p_rei_attribute10              => p_rei_attribute10
         ,p_rei_attribute11              => p_rei_attribute11
         ,p_rei_attribute12              => p_rei_attribute12
         ,p_rei_attribute13              => p_rei_attribute13
         ,p_rei_attribute14              => p_rei_attribute14
         ,p_rei_attribute15              => p_rei_attribute15
         ,p_rei_attribute16              => p_rei_attribute16
         ,p_rei_attribute17              => p_rei_attribute17
         ,p_rei_attribute18              => p_rei_attribute18
         ,p_rei_attribute19              => p_rei_attribute19
         ,p_rei_attribute20              => p_rei_attribute20
         ,p_rei_information_category     => p_rei_information_category
         ,p_rei_information1             => p_rei_information1
         ,p_rei_information2             => p_rei_information2
         ,p_rei_information3             => p_rei_information3
         ,p_rei_information4             => p_rei_information4
         ,p_rei_information5             => p_rei_information5
         ,p_rei_information6             => p_rei_information6
         ,p_rei_information7             => p_rei_information7
         ,p_rei_information8             => p_rei_information8
         ,p_rei_information9             => p_rei_information9
         ,p_rei_information10            => p_rei_information10
         ,p_rei_information11            => p_rei_information11
         ,p_rei_information12            => p_rei_information12
         ,p_rei_information13            => p_rei_information13
         ,p_rei_information14            => p_rei_information14
         ,p_rei_information15            => p_rei_information15
         ,p_rei_information16            => p_rei_information16
         ,p_rei_information17            => p_rei_information17
         ,p_rei_information18            => p_rei_information18
         ,p_rei_information19            => p_rei_information19
         ,p_rei_information20            => p_rei_information20
         ,p_rei_information21            => p_rei_information21
         ,p_rei_information22            => p_rei_information22
         ,p_rei_information23            => p_rei_information23
         ,p_rei_information24            => p_rei_information24
         ,p_rei_information25            => p_rei_information25
         ,p_rei_information26            => p_rei_information26
         ,p_rei_information27            => p_rei_information27
         ,p_rei_information28            => p_rei_information28
         ,p_rei_information29            => p_rei_information29
         ,p_rei_information30            => p_rei_information30
         ,p_object_version_number        => p_object_version_number

		);
      exception
	   when hr_api.cannot_find_prog_unit then
   	          p_object_version_number := l_obj_version_number; -- NOCOPY Changes
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_par_extra_info',
				 p_hook_type	=> 'AP'
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
    ROLLBACK TO update_pa_request_extra_info;
    p_object_version_number := l_obj_version_number; -- NOCOPY Changes
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;

    when others then
      ROLLBACK TO update_pa_request_extra_info;
      p_object_version_number := l_obj_version_number; -- NOCOPY Changes
      raise;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end update_pa_request_extra_info;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_pa_request_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pa_request_extra_info
  (p_validate                      in     boolean  default false
  ,p_pa_request_extra_info_id      in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  --
begin
  l_proc := g_package||'delete_pa_request_extra_info';
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  savepoint delete_pa_request_extra_info;
  --
  --
  -- Call Before Process User Hook
  --
  begin
	ghr_par_extra_info_bk3.delete_par_extra_info_b	(
             p_pa_request_extra_info_id    =>   p_pa_request_extra_info_id
            ,p_object_version_number       =>   p_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_par_extra_info',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic - Delete pa_request Extra Info details
  --
  ghr_rei_del.del
  (p_pa_request_extra_info_id      => p_pa_request_extra_info_id
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
	ghr_par_extra_info_bk3.delete_par_extra_info_a	(
             p_pa_request_extra_info_id    =>   p_pa_request_extra_info_id
            ,p_object_version_number       =>   p_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_par_extra_info',
				 p_hook_type	=> 'AP'
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
    ROLLBACK TO delete_pa_request_extra_info;
    --
  when others then
    ROLLBACK TO delete_pa_request_extra_info;
    raise;

    hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_pa_request_extra_info;
--
--

PROCEDURE validate_extra_info
   (p_pa_request_id NUMBER
  ,p_information_type VARCHAR2
  ,p_rei_information_category  VARCHAR2
  ,p_rei_information1  VARCHAR2
  ,p_rei_information2  VARCHAR2
  ,p_rei_information3  VARCHAR2
  ,p_rei_information4  VARCHAR2
  ,p_rei_information5  VARCHAR2
  ,p_rei_information6  VARCHAR2
  ,p_rei_information7  VARCHAR2
  ,p_rei_information8  VARCHAR2
  ,p_rei_information9  VARCHAR2
  ,p_rei_information10  VARCHAR2
  ,p_rei_information11  VARCHAR2
  ,p_rei_information12  VARCHAR2
  ,p_rei_information13  VARCHAR2
  ,p_rei_information14  VARCHAR2
  ,p_rei_information15  VARCHAR2
  ,p_rei_information16  VARCHAR2
  ,p_rei_information17  VARCHAR2
  ,p_rei_information18  VARCHAR2
  ,p_rei_information19  VARCHAR2
  ,p_rei_information20  VARCHAR2
  ,p_rei_information21  VARCHAR2
  ,p_rei_information22  VARCHAR2
  ,p_rei_information23  VARCHAR2
  ,p_rei_information24  VARCHAR2
  ,p_rei_information25  VARCHAR2
  ,p_rei_information26  VARCHAR2
  ,p_rei_information27  VARCHAR2
  ,p_rei_information28  VARCHAR2
  ,p_rei_information29  VARCHAR2
  ,p_rei_information30 VARCHAR2
  ,p_ben_ei_validate varchar2 default 'FALSE') IS

CURSOR c_get_pa_req(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
SELECT *
FROM ghr_pa_requests
WHERE pa_request_id = c_pa_request_id;

 CURSOR c_payroll_id(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
	SELECT rei_information3 payroll_id
	  FROM   ghr_pa_request_extra_info
	  WHERE  pa_request_id       =   c_pa_request_id
	  AND    information_type    =   'GHR_US_PAR_PAYROLL_TYPE';

CURSOR c_start_date(c_payroll_id pay_payrolls_f.payroll_id%type, c_year varchar2, c_month varchar2) IS
SELECT min(start_date) start_date
   FROM per_time_periods
   WHERE payroll_id = c_payroll_id
   AND TO_CHAR(start_date,'YYYY') = c_year
   AND TO_CHAR(start_date,'MM') = c_month;


l_retirement_plan ghr_pa_requests.retirement_plan%type;
l_pa_request_id ghr_pa_requests.pa_request_id%type;
l_start_date per_time_periods.start_date%type;
l_effective_date ghr_pa_requests.effective_date%type;
l_first_noa_code ghr_pa_requests.first_noa_code%type;
l_tenure ghr_pa_requests.tenure%type;
l_annuitant_indicator ghr_pa_requests.annuitant_indicator%type;
l_assignment_id ghr_pa_requests.employee_assignment_id%type;

l_health_plan ghr_pa_request_extra_info.rei_information5%type;
l_enrollment_option ghr_pa_request_extra_info.rei_information6%type;
l_date_temp_elig date;
l_fegli ghr_pa_requests.fegli%type;
l_tsp_status ghr_pa_request_extra_info.rei_information15%type;
l_payroll_id ghr_pa_request_extra_info.rei_information3%type;
l_noa_family_code ghr_pa_requests.noa_family_code%type;
l_st_month VARCHAR2(20);
l_end_month VARCHAR2(20);
l_pay_month VARCHAR2(20);

BEGIN
  --  Validation for US Federal Benefits
  IF p_information_type	= 'GHR_US_PAR_BENEFITS' THEN

    IF p_ben_ei_validate = 'TRUE' THEN
			-- Get PA Request Record details
			hr_utility.set_location('---------------- Validation starts-------------------------------',1234);
			FOR l_cur_pa_req IN c_get_pa_req(p_pa_request_id) LOOP
				l_retirement_plan := l_cur_pa_req.retirement_plan;
				l_pa_request_id := l_cur_pa_req.pa_request_id;
				l_effective_date := l_cur_pa_req.effective_date;
				l_first_noa_code := l_cur_pa_req.first_noa_code;
				l_tenure := l_cur_pa_req.tenure;
				l_fegli := l_cur_pa_req.fegli;
				l_noa_family_code := l_cur_pa_req.noa_family_code;
				l_annuitant_indicator := l_cur_pa_req.annuitant_indicator;
				l_assignment_id := l_cur_pa_req.employee_assignment_id;
			END LOOP;

			l_health_plan := p_rei_information5;
			l_enrollment_option := p_rei_information6;
			l_date_temp_elig := fnd_date.canonical_to_date(p_rei_information4);
			l_tsp_status := p_rei_information15;

			GHR_BEN_VALIDATION.validate_benefits
			(p_effective_date => l_effective_date,
			p_which_eit => 'R',
			p_pa_request_id => l_pa_request_id,
			p_first_noa_code => l_first_noa_code,
			p_noa_family_code => l_noa_family_code,
			p_health_plan => l_health_plan,
			p_enrollment_option => l_enrollment_option,
			p_date_fehb_elig => fnd_date.canonical_to_date(p_rei_information3),
			p_date_temp_elig => l_date_temp_elig,
			p_temps_total_cost => p_rei_information8,
			p_pre_tax_waiver => p_rei_information9,
			p_tsp_scd => fnd_date.canonical_to_date(p_rei_information12),
			p_tsp_amount => p_rei_information13,
			p_tsp_rate => p_rei_information14,
			p_tsp_status => p_rei_information15,
			p_tsp_status_date => fnd_date.canonical_to_date(p_rei_information16),
			p_agency_contrib_date =>  fnd_date.canonical_to_date(p_rei_information17),
			p_emp_contrib_date => fnd_date.canonical_to_date(p_rei_information18),
			p_tenure => l_tenure,
			p_retirement_plan => l_retirement_plan,
			p_fegli_elig_exp_date => fnd_date.canonical_to_date(p_rei_information10),
			p_fers_elig_exp_date => fnd_date.canonical_to_date(p_rei_information11),
			p_annuitant_indicator => l_annuitant_indicator,
			p_assignment_id => l_assignment_id
			);




	END IF; --  IF p_ben_ei_validate = 'TRUE' THEN
 END IF; -- IF p_information_type	= 'GHR_US_PAR_BENEFITS' THEN
END validate_extra_info;

END ghr_par_extra_info_api;

/
