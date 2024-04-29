--------------------------------------------------------
--  DDL for Package Body GHR_PERSON_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PERSON_EXTRA_INFO_API" as
/* $Header: ghpeiapi.pkb 120.0.12010000.2 2009/05/26 10:38:25 vmididho noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_person_extra_info_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_person_extra_info >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_extra_info
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_information_type              in     varchar2
  ,p_effective_date                in     date
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
  ,p_person_extra_info_id             out NOCOPY number
  ,p_object_version_number            out NOCOPY number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                	varchar2(72) := g_package||'create_person_extra_info';
  l_object_version_number	per_people_extra_info.object_version_number%type;
  l_person_extra_info_id	per_people_extra_info.person_extra_info_id%type;

  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    savepoint ghr_create_person_extra_info;
  --
  --
  ghr_session.set_session_var_for_core
  (p_effective_date    => p_effective_date
  );

  -- call hr_person_extra_info_api

           hr_person_extra_info_api.create_person_extra_info
           (
		p_person_id				=>	p_person_id			,
		p_information_type		=>	p_information_type	,
		p_pei_attribute_category	=>	p_pei_attribute_category,
		p_pei_attribute1			=>	p_pei_attribute1		,
		p_pei_attribute2			=>	p_pei_attribute2		,
		p_pei_attribute3			=>	p_pei_attribute3		,
		p_pei_attribute4			=>	p_pei_attribute4		,
		p_pei_attribute5			=>	p_pei_attribute5		,
		p_pei_attribute6			=>	p_pei_attribute6		,
		p_pei_attribute7			=>	p_pei_attribute7		,
		p_pei_attribute8			=>	p_pei_attribute8		,
		p_pei_attribute9			=>	p_pei_attribute9		,
		p_pei_attribute10			=>	p_pei_attribute10		,
		p_pei_attribute11			=>	p_pei_attribute11		,
		p_pei_attribute12			=>	p_pei_attribute12		,
		p_pei_attribute13			=>	p_pei_attribute13		,
		p_pei_attribute14			=>	p_pei_attribute14		,
		p_pei_attribute15			=>	p_pei_attribute15		,
		p_pei_attribute16			=>	p_pei_attribute16		,
		p_pei_attribute17			=>	p_pei_attribute17		,
		p_pei_attribute18			=>	p_pei_attribute18		,
		p_pei_attribute19			=>	p_pei_attribute19		,
		p_pei_attribute20			=>	p_pei_attribute20		,
		p_pei_information_category	=>	p_pei_information_category	,
		p_pei_information1		=>	p_pei_information1	,
		p_pei_information2		=>	p_pei_information2	,
		p_pei_information3		=>	p_pei_information3	,
		p_pei_information4		=>	p_pei_information4	,
		p_pei_information5		=>	p_pei_information5	,
		p_pei_information6		=>	p_pei_information6	,
		p_pei_information7		=>	p_pei_information7	,
		p_pei_information8		=>	p_pei_information8	,
		p_pei_information9		=>	p_pei_information9	,
		p_pei_information10		=>	p_pei_information10	,
		p_pei_information11		=>	p_pei_information11	,
		p_pei_information12		=>	p_pei_information12	,
		p_pei_information13		=>	p_pei_information13	,
		p_pei_information14		=>	p_pei_information14	,
		p_pei_information15		=>	p_pei_information15	,
		p_pei_information16		=>	p_pei_information16	,
		p_pei_information17		=>	p_pei_information17	,
		p_pei_information18		=>	p_pei_information18	,
		p_pei_information19		=>	p_pei_information19	,
		p_pei_information20		=>	p_pei_information20	,
		p_pei_information21		=>	p_pei_information21	,
		p_pei_information22		=>	p_pei_information22	,
		p_pei_information23		=>	p_pei_information23	,
		p_pei_information24		=>	p_pei_information24	,
		p_pei_information25		=>	p_pei_information25	,
		p_pei_information26		=>	p_pei_information26	,
		p_pei_information27		=>	p_pei_information27	,
		p_pei_information28		=>	p_pei_information28	,
		p_pei_information29		=>	p_pei_information29	,
		p_pei_information30		=>	p_pei_information30     ,
            p_person_extra_info_id        =>    l_person_extra_info_id  ,
            p_object_version_number       =>    l_object_version_number
		);
  --
  ghr_history_api.post_update_process;
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --

  --set all output variables

   p_person_extra_info_id          :=    l_person_extra_info_id;
   p_object_version_number         :=    l_object_version_number;
   hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_create_person_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_person_extra_info_id   := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
   when others then
     ROLLBACK TO ghr_create_person_extra_info;
     raise;
end create_person_extra_info;

-- ----------------------------------------------------------------------------
-- |-----------------------< update_person_extra_info >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_extra_info
  (p_validate                      in     boolean  default false
  ,p_person_extra_info_id          in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_effective_date                in     date
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
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    savepoint ghr_update_person_extra_info;
  --
  --
  ghr_session.set_session_var_for_core
  (p_effective_date    => p_effective_date
  );
  hr_person_extra_info_api.update_person_extra_info
		(
		p_person_extra_info_id		=>	p_person_extra_info_id	,
            p_pei_attribute_category	=>	p_pei_attribute_category,
		p_pei_attribute1			=>	p_pei_attribute1		,
		p_pei_attribute2			=>	p_pei_attribute2		,
		p_pei_attribute3			=>	p_pei_attribute3		,
		p_pei_attribute4			=>	p_pei_attribute4		,
		p_pei_attribute5			=>	p_pei_attribute5		,
		p_pei_attribute6			=>	p_pei_attribute6		,
		p_pei_attribute7			=>	p_pei_attribute7		,
		p_pei_attribute8			=>	p_pei_attribute8		,
		p_pei_attribute9			=>	p_pei_attribute9		,
		p_pei_attribute10			=>	p_pei_attribute10		,
		p_pei_attribute11			=>	p_pei_attribute11		,
		p_pei_attribute12			=>	p_pei_attribute12		,
		p_pei_attribute13			=>	p_pei_attribute13		,
		p_pei_attribute14			=>	p_pei_attribute14		,
		p_pei_attribute15			=>	p_pei_attribute15		,
		p_pei_attribute16			=>	p_pei_attribute16		,
		p_pei_attribute17			=>	p_pei_attribute17		,
		p_pei_attribute18			=>	p_pei_attribute18		,
		p_pei_attribute19			=>	p_pei_attribute19		,
		p_pei_attribute20			=>	p_pei_attribute20		,
		p_pei_information_category	=>	p_pei_information_category	,
		p_pei_information1		=>	p_pei_information1	,
		p_pei_information2		=>	p_pei_information2	,
		p_pei_information3		=>	p_pei_information3	,
		p_pei_information4		=>	p_pei_information4	,
		p_pei_information5		=>	p_pei_information5	,
		p_pei_information6		=>	p_pei_information6	,
		p_pei_information7		=>	p_pei_information7	,
		p_pei_information8		=>	p_pei_information8	,
		p_pei_information9		=>	p_pei_information9	,
		p_pei_information10		=>	p_pei_information10	,
		p_pei_information11		=>	p_pei_information11	,
		p_pei_information12		=>	p_pei_information12	,
		p_pei_information13		=>	p_pei_information13	,
		p_pei_information14		=>	p_pei_information14	,
		p_pei_information15		=>	p_pei_information15	,
		p_pei_information16		=>	p_pei_information16	,
		p_pei_information17		=>	p_pei_information17	,
		p_pei_information18		=>	p_pei_information18	,
		p_pei_information19		=>	p_pei_information19	,
		p_pei_information20		=>	p_pei_information20	,
		p_pei_information21		=>	p_pei_information21	,
		p_pei_information22		=>	p_pei_information22	,
		p_pei_information23		=>	p_pei_information23	,
		p_pei_information24		=>	p_pei_information24	,
		p_pei_information25		=>	p_pei_information25	,
		p_pei_information26		=>	p_pei_information26	,
		p_pei_information27		=>	p_pei_information27	,
		p_pei_information28		=>	p_pei_information28	,
		p_pei_information29		=>	p_pei_information29	,
		p_pei_information30		=>	p_pei_information30	,
		p_object_version_number		=>	p_object_version_number
		);
  --
  --
  hr_utility.set_location(l_proc, 7);
  --
  ghr_history_api.post_update_process;

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
    ROLLBACK TO ghr_update_person_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  when others then
    ROLLBACK TO ghr_update_person_extra_info;
    raise;
end update_person_extra_info;
--
--

end ghr_person_extra_info_api;


/
