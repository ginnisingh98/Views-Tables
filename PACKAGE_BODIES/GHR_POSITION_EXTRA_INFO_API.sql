--------------------------------------------------------
--  DDL for Package Body GHR_POSITION_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_POSITION_EXTRA_INFO_API" as
/* $Header: ghpoiapi.pkb 115.6 2003/01/30 16:32:12 asubrahm ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_position_extra_info_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_position_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_position_extra_info
  (p_validate                       in     boolean  default false
  ,p_position_id                    in     number
  ,p_information_type               in     varchar2
  ,p_effective_date                 in     date
  ,p_poei_attribute_category        in     varchar2 default null
  ,p_poei_attribute1                in     varchar2 default null
  ,p_poei_attribute2                in     varchar2 default null
  ,p_poei_attribute3                in     varchar2 default null
  ,p_poei_attribute4                in     varchar2 default null
  ,p_poei_attribute5                in     varchar2 default null
  ,p_poei_attribute6                in     varchar2 default null
  ,p_poei_attribute7                in     varchar2 default null
  ,p_poei_attribute8                in     varchar2 default null
  ,p_poei_attribute9                in     varchar2 default null
  ,p_poei_attribute10               in     varchar2 default null
  ,p_poei_attribute11               in     varchar2 default null
  ,p_poei_attribute12               in     varchar2 default null
  ,p_poei_attribute13               in     varchar2 default null
  ,p_poei_attribute14               in     varchar2 default null
  ,p_poei_attribute15               in     varchar2 default null
  ,p_poei_attribute16               in     varchar2 default null
  ,p_poei_attribute17               in     varchar2 default null
  ,p_poei_attribute18               in     varchar2 default null
  ,p_poei_attribute19               in     varchar2 default null
  ,p_poei_attribute20               in     varchar2 default null
  ,p_poei_information_category      in     varchar2 default null
  ,p_poei_information1              in     varchar2 default null
  ,p_poei_information2              in     varchar2 default null
  ,p_poei_information3              in     varchar2 default null
  ,p_poei_information4              in     varchar2 default null
  ,p_poei_information5              in     varchar2 default null
  ,p_poei_information6              in     varchar2 default null
  ,p_poei_information7              in     varchar2 default null
  ,p_poei_information8              in     varchar2 default null
  ,p_poei_information9              in     varchar2 default null
  ,p_poei_information10             in     varchar2 default null
  ,p_poei_information11             in     varchar2 default null
  ,p_poei_information12             in     varchar2 default null
  ,p_poei_information13             in     varchar2 default null
  ,p_poei_information14             in     varchar2 default null
  ,p_poei_information15             in     varchar2 default null
  ,p_poei_information16             in     varchar2 default null
  ,p_poei_information17             in     varchar2 default null
  ,p_poei_information18             in     varchar2 default null
  ,p_poei_information19             in     varchar2 default null
  ,p_poei_information20             in     varchar2 default null
  ,p_poei_information21             in     varchar2 default null
  ,p_poei_information22             in     varchar2 default null
  ,p_poei_information23             in     varchar2 default null
  ,p_poei_information24             in     varchar2 default null
  ,p_poei_information25             in     varchar2 default null
  ,p_poei_information26             in     varchar2 default null
  ,p_poei_information27             in     varchar2 default null
  ,p_poei_information28             in     varchar2 default null
  ,p_poei_information29             in     varchar2 default null
  ,p_poei_information30             in     varchar2 default null
  ,p_position_extra_info_id         out nocopy number
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_position_extra_info';
  l_object_version_number		per_position_extra_info.object_version_number%type;
  l_position_extra_info_id		per_position_extra_info.position_extra_info_id%type;
  l_bg_id                           per_positions.business_group_id%type;
  --

  cursor c_bg is
    SELECT business_group_id
    FROM   per_positions
    WHERE  position_id = p_position_id;

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    savepoint ghr_create_position_extra_info;
  --
  --
  --
        -- set session variables
      ghr_session.set_session_var_for_core
      (p_effective_date                 =>     p_effective_date
      );

  -----------------------------------------------------------------------------------------
  -- To fix issue with position valid grade value set using $PROFILES$.PER_BUSINESS_GROUP_ID
  -- Note:  PER_BUSINESS_GROUP_ID appears to be defaulted to zero so we cannot test it.
  -----------------------------------------------------------------------------------------
  --fnd_profile.get('PER_BUSINESS_GROUP_ID',l_bg_id);
  --IF l_bg_id IS NULL THEN
    FOR c_bg_id in c_bg LOOP
      l_bg_id := c_bg_id.business_group_id;
    END LOOP;
    fnd_profile.put('PER_BUSINESS_GROUP_ID',l_bg_id);
  --END IF;
  --
	hr_position_extra_info_api.create_position_extra_info
		(
		p_position_id			=>	p_position_id			,
		p_information_type		=>	p_information_type		,
		p_poei_attribute_category	=>	p_poei_attribute_category	,
		p_poei_attribute1			=>	p_poei_attribute1			,
		p_poei_attribute2			=>	p_poei_attribute2			,
		p_poei_attribute3			=>	p_poei_attribute3			,
		p_poei_attribute4			=>	p_poei_attribute4			,
		p_poei_attribute5			=>	p_poei_attribute5			,
		p_poei_attribute6			=>	p_poei_attribute6			,
		p_poei_attribute7			=>	p_poei_attribute7			,
		p_poei_attribute8			=>	p_poei_attribute8			,
		p_poei_attribute9			=>	p_poei_attribute9			,
		p_poei_attribute10		=>	p_poei_attribute10		,
		p_poei_attribute11		=>	p_poei_attribute11		,
		p_poei_attribute12		=>	p_poei_attribute12		,
		p_poei_attribute13		=>	p_poei_attribute13		,
		p_poei_attribute14		=>	p_poei_attribute14		,
		p_poei_attribute15		=>	p_poei_attribute15		,
		p_poei_attribute16		=>	p_poei_attribute16		,
		p_poei_attribute17		=>	p_poei_attribute17		,
		p_poei_attribute18		=>	p_poei_attribute18		,
		p_poei_attribute19		=>	p_poei_attribute19		,
		p_poei_attribute20		=>	p_poei_attribute20		,
		p_poei_information_category	=>	p_poei_information_category	,
		p_poei_information1		=>	p_poei_information1		,
		p_poei_information2		=>	p_poei_information2		,
		p_poei_information3		=>	p_poei_information3		,
		p_poei_information4		=>	p_poei_information4		,
		p_poei_information5		=>	p_poei_information5		,
		p_poei_information6		=>	p_poei_information6		,
		p_poei_information7		=>	p_poei_information7		,
		p_poei_information8		=>	p_poei_information8		,
		p_poei_information9		=>	p_poei_information9		,
		p_poei_information10		=>	p_poei_information10		,
		p_poei_information11		=>	p_poei_information11		,
		p_poei_information12		=>	p_poei_information12		,
		p_poei_information13		=>	p_poei_information13		,
		p_poei_information14		=>	p_poei_information14		,
		p_poei_information15		=>	p_poei_information15		,
		p_poei_information16		=>	p_poei_information16		,
		p_poei_information17		=>	p_poei_information17		,
		p_poei_information18		=>	p_poei_information18		,
		p_poei_information19		=>	p_poei_information19		,
		p_poei_information20		=>	p_poei_information20		,
		p_poei_information21		=>	p_poei_information21		,
		p_poei_information22		=>	p_poei_information22		,
		p_poei_information23		=>	p_poei_information23		,
		p_poei_information24		=>	p_poei_information24		,
		p_poei_information25		=>	p_poei_information25		,
		p_poei_information26		=>	p_poei_information26		,
		p_poei_information27		=>	p_poei_information27		,
		p_poei_information28		=>	p_poei_information28		,
		p_poei_information29		=>	p_poei_information29		,
		p_poei_information30		=>	p_poei_information30	      ,
            p_position_extra_info_id      =>    l_position_extra_info_id   	,
            p_object_version_number       =>    l_object_version_number
		);
  --

  hr_utility.set_location(l_proc, 7);
  --
    ghr_history_api.post_update_process;

  -- When in validation only mode raise the Validate_Enabled exception
  --

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
    p_object_version_number     := l_object_version_number;
    p_position_extra_info_id    := l_position_extra_info_id;

  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_create_position_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_position_extra_info_id := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
   when others then
     ROLLBACK TO ghr_create_position_extra_info;
     --
     -- Reset IN OUT parameters and set OUT parameters
     --
     p_position_extra_info_id := null;
     p_object_version_number  := null;
     raise;
end create_position_extra_info;
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_position_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_position_extra_info
  (p_validate                       in     boolean  default false
  ,p_position_extra_info_id         in     number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in     date
  ,p_poei_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_poei_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_poei_information1              in     varchar2 default hr_api.g_varchar2
  ,p_poei_information2              in     varchar2 default hr_api.g_varchar2
  ,p_poei_information3              in     varchar2 default hr_api.g_varchar2
  ,p_poei_information4              in     varchar2 default hr_api.g_varchar2
  ,p_poei_information5              in     varchar2 default hr_api.g_varchar2
  ,p_poei_information6              in     varchar2 default hr_api.g_varchar2
  ,p_poei_information7              in     varchar2 default hr_api.g_varchar2
  ,p_poei_information8              in     varchar2 default hr_api.g_varchar2
  ,p_poei_information9              in     varchar2 default hr_api.g_varchar2
  ,p_poei_information10             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information11             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information12             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information13             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information14             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information15             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information16             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information17             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information18             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information19             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information20             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information21             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information22             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information23             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information24             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information25             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information26             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information27             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information28             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information29             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information30             in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_position_extra_info';
  l_object_version_number per_position_extra_info.object_version_number%TYPE;
  l_bg_id                 per_positions.business_group_id%type;
  --

  cursor c_bg is
    SELECT pos.business_group_id
    FROM   per_positions pos, per_position_extra_info poi
    WHERE  pos.position_id = poi.position_id
    AND    poi.position_extra_info_id = p_position_extra_info_id;

  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    savepoint ghr_update_position_extra_info;
  --

     l_object_version_number      	     :=   p_object_version_number;

     ghr_session.set_session_var_for_core
     (p_effective_date      =>   p_effective_date
     );


  -----------------------------------------------------------------------------------------
  -- To fix issue with position valid grade value set using $PROFILE$.PER_BUSINESS_GROUP_ID
  -- Note:  PER_BUSINESS_GROUP_ID appears to be defaulted to zero so we cannot test it.
  -----------------------------------------------------------------------------------------
  --fnd_profile.get('PER_BUSINESS_GROUP_ID',l_bg_id);
  --IF l_bg_id IS NULL THEN
    FOR c_bg_id in c_bg LOOP
      l_bg_id := c_bg_id.business_group_id;
    END LOOP;
    fnd_profile.put('PER_BUSINESS_GROUP_ID',l_bg_id);
  --END IF;


	hr_position_extra_info_api.update_position_extra_info
		(
		p_position_extra_info_id	=>	p_position_extra_info_id	,
		p_poei_attribute_category	=>	p_poei_attribute_category	,
		p_poei_attribute1			=>	p_poei_attribute1			,
		p_poei_attribute2			=>	p_poei_attribute2			,
		p_poei_attribute3			=>	p_poei_attribute3			,
		p_poei_attribute4			=>	p_poei_attribute4			,
		p_poei_attribute5			=>	p_poei_attribute5			,
		p_poei_attribute6			=>	p_poei_attribute6			,
		p_poei_attribute7			=>	p_poei_attribute7			,
		p_poei_attribute8			=>	p_poei_attribute8			,
		p_poei_attribute9			=>	p_poei_attribute9	 		,
		p_poei_attribute10		=>	p_poei_attribute10		,
		p_poei_attribute11		=>	p_poei_attribute11		,
		p_poei_attribute12		=>	p_poei_attribute12		,
		p_poei_attribute13		=>	p_poei_attribute13		,
		p_poei_attribute14		=>	p_poei_attribute14		,
		p_poei_attribute15		=>	p_poei_attribute15		,
		p_poei_attribute16		=>	p_poei_attribute16		,
		p_poei_attribute17		=>	p_poei_attribute17		,
		p_poei_attribute18		=>	p_poei_attribute18		,
		p_poei_attribute19		=>	p_poei_attribute19		,
		p_poei_attribute20		=>	p_poei_attribute20		,
		p_poei_information_category	=>	p_poei_information_category	,
		p_poei_information1		=>	p_poei_information1		,
		p_poei_information2		=>	p_poei_information2		,
		p_poei_information3		=>	p_poei_information3		,
		p_poei_information4		=>	p_poei_information4		,
		p_poei_information5		=>	p_poei_information5		,
		p_poei_information6		=>	p_poei_information6		,
		p_poei_information7		=>	p_poei_information7		,
		p_poei_information8		=>	p_poei_information8		,
		p_poei_information9		=>	p_poei_information9		,
		p_poei_information10		=>	p_poei_information10		,
		p_poei_information11		=>	p_poei_information11		,
		p_poei_information12		=>	p_poei_information12		,
		p_poei_information13		=>	p_poei_information13		,
		p_poei_information14		=>	p_poei_information14		,
		p_poei_information15		=>	p_poei_information15		,
		p_poei_information16		=>	p_poei_information16		,
		p_poei_information17		=>	p_poei_information17		,
		p_poei_information18		=>	p_poei_information18		,
		p_poei_information19		=>	p_poei_information19		,
		p_poei_information20		=>	p_poei_information20		,
		p_poei_information21		=>	p_poei_information21		,
		p_poei_information22		=>	p_poei_information22		,
		p_poei_information23		=>	p_poei_information23		,
		p_poei_information24		=>	p_poei_information24		,
		p_poei_information25		=>	p_poei_information25		,
		p_poei_information26		=>	p_poei_information26		,
		p_poei_information27		=>	p_poei_information27		,
		p_poei_information28		=>	p_poei_information28		,
		p_poei_information29		=>	p_poei_information29		,
		p_poei_information30		=>	p_poei_information30		,
		p_object_version_number		=>	p_object_version_number
		);
  --
  hr_utility.set_location(l_proc, 7);
  --
    ghr_history_api.post_update_process;

  --
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
    ROLLBACK TO ghr_update_position_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  when others then
   ROLLBACK TO ghr_update_position_extra_info;
   --
   -- Reset IN OUT parameters and set OUT parameters
   --
   p_object_version_number  := l_object_version_number;
   raise;

end update_position_extra_info;
--
--
end ghr_position_extra_info_api;

/
