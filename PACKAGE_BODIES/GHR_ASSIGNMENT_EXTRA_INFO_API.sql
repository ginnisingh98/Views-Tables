--------------------------------------------------------
--  DDL for Package Body GHR_ASSIGNMENT_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_ASSIGNMENT_EXTRA_INFO_API" as
/* $Header: ghaeiapi.pkb 120.0.12010000.2 2009/05/26 10:25:41 utokachi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_assignment_extra_info_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_assignment_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_assignment_extra_info
  (p_validate                       in     boolean  default false
  ,p_assignment_id                    in     number
  ,p_information_type               in     varchar2
  ,p_effective_date                 in     date
  ,p_aei_attribute_category        in     varchar2 default null
  ,p_aei_attribute1                in     varchar2 default null
  ,p_aei_attribute2                in     varchar2 default null
  ,p_aei_attribute3                in     varchar2 default null
  ,p_aei_attribute4                in     varchar2 default null
  ,p_aei_attribute5                in     varchar2 default null
  ,p_aei_attribute6                in     varchar2 default null
  ,p_aei_attribute7                in     varchar2 default null
  ,p_aei_attribute8                in     varchar2 default null
  ,p_aei_attribute9                in     varchar2 default null
  ,p_aei_attribute10               in     varchar2 default null
  ,p_aei_attribute11               in     varchar2 default null
  ,p_aei_attribute12               in     varchar2 default null
  ,p_aei_attribute13               in     varchar2 default null
  ,p_aei_attribute14               in     varchar2 default null
  ,p_aei_attribute15               in     varchar2 default null
  ,p_aei_attribute16               in     varchar2 default null
  ,p_aei_attribute17               in     varchar2 default null
  ,p_aei_attribute18               in     varchar2 default null
  ,p_aei_attribute19               in     varchar2 default null
  ,p_aei_attribute20               in     varchar2 default null
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  ,p_aei_information11             in     varchar2 default null
  ,p_aei_information12             in     varchar2 default null
  ,p_aei_information13             in     varchar2 default null
  ,p_aei_information14             in     varchar2 default null
  ,p_aei_information15             in     varchar2 default null
  ,p_aei_information16             in     varchar2 default null
  ,p_aei_information17             in     varchar2 default null
  ,p_aei_information18             in     varchar2 default null
  ,p_aei_information19             in     varchar2 default null
  ,p_aei_information20             in     varchar2 default null
  ,p_aei_information21             in     varchar2 default null
  ,p_aei_information22             in     varchar2 default null
  ,p_aei_information23             in     varchar2 default null
  ,p_aei_information24             in     varchar2 default null
  ,p_aei_information25             in     varchar2 default null
  ,p_aei_information26             in     varchar2 default null
  ,p_aei_information27             in     varchar2 default null
  ,p_aei_information28             in     varchar2 default null
  ,p_aei_information29             in     varchar2 default null
  ,p_aei_information30             in     varchar2 default null
  ,p_assignment_extra_info_id         out NOCOPY number
  ,p_object_version_number          out NOCOPY number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_assignment_extra_info';
  l_object_version_number		per_assignment_extra_info.object_version_number%type;
  l_assignment_extra_info_id		per_assignment_extra_info.assignment_extra_info_id%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    savepoint ghr_create_asg_extra_info;
  --
  --
  --
        -- set session variables
      ghr_session.set_session_var_for_core
      (p_effective_date                 =>     p_effective_date
      );

	hr_assignment_extra_info_api.create_assignment_extra_info
		(
		p_assignment_id			=>	p_assignment_id			,
		p_information_type		=>	p_information_type		,
		p_aei_attribute_category	=>	p_aei_attribute_category	,
		p_aei_attribute1			=>	p_aei_attribute1			,
		p_aei_attribute2			=>	p_aei_attribute2			,
		p_aei_attribute3			=>	p_aei_attribute3			,
		p_aei_attribute4			=>	p_aei_attribute4			,
		p_aei_attribute5			=>	p_aei_attribute5			,
		p_aei_attribute6			=>	p_aei_attribute6			,
		p_aei_attribute7			=>	p_aei_attribute7			,
		p_aei_attribute8			=>	p_aei_attribute8			,
		p_aei_attribute9			=>	p_aei_attribute9			,
		p_aei_attribute10		=>	p_aei_attribute10		,
		p_aei_attribute11		=>	p_aei_attribute11		,
		p_aei_attribute12		=>	p_aei_attribute12		,
		p_aei_attribute13		=>	p_aei_attribute13		,
		p_aei_attribute14		=>	p_aei_attribute14		,
		p_aei_attribute15		=>	p_aei_attribute15		,
		p_aei_attribute16		=>	p_aei_attribute16		,
		p_aei_attribute17		=>	p_aei_attribute17		,
		p_aei_attribute18		=>	p_aei_attribute18		,
		p_aei_attribute19		=>	p_aei_attribute19		,
		p_aei_attribute20		=>	p_aei_attribute20		,
		p_aei_information_category	=>	p_aei_information_category	,
		p_aei_information1		=>	p_aei_information1		,
		p_aei_information2		=>	p_aei_information2		,
		p_aei_information3		=>	p_aei_information3		,
		p_aei_information4		=>	p_aei_information4		,
		p_aei_information5		=>	p_aei_information5		,
		p_aei_information6		=>	p_aei_information6		,
		p_aei_information7		=>	p_aei_information7		,
		p_aei_information8		=>	p_aei_information8		,
		p_aei_information9		=>	p_aei_information9		,
		p_aei_information10		=>	p_aei_information10		,
		p_aei_information11		=>	p_aei_information11		,
		p_aei_information12		=>	p_aei_information12		,
		p_aei_information13		=>	p_aei_information13		,
		p_aei_information14		=>	p_aei_information14		,
		p_aei_information15		=>	p_aei_information15		,
		p_aei_information16		=>	p_aei_information16		,
		p_aei_information17		=>	p_aei_information17		,
		p_aei_information18		=>	p_aei_information18		,
		p_aei_information19		=>	p_aei_information19		,
		p_aei_information20		=>	p_aei_information20		,
		p_aei_information21		=>	p_aei_information21		,
		p_aei_information22		=>	p_aei_information22		,
		p_aei_information23		=>	p_aei_information23		,
		p_aei_information24		=>	p_aei_information24		,
		p_aei_information25		=>	p_aei_information25		,
		p_aei_information26		=>	p_aei_information26		,
		p_aei_information27		=>	p_aei_information27		,
		p_aei_information28		=>	p_aei_information28		,
		p_aei_information29		=>	p_aei_information29		,
		p_aei_information30		=>	p_aei_information30	      ,
            p_assignment_extra_info_id      =>    l_assignment_extra_info_id   	,
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
    p_assignment_extra_info_id    := l_assignment_extra_info_id;

  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_create_asg_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_assignment_extra_info_id := null;
    p_object_version_number  := null;
    --

  when others then
    ROLLBACK TO ghr_create_asg_extra_info;
    raise;

    hr_utility.set_location(' Leaving:'||l_proc, 12);
end create_assignment_extra_info;
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_assignment_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_assignment_extra_info
  (p_validate                       in     boolean  default false
  ,p_assignment_extra_info_id         in     number
  ,p_object_version_number          in out NOCOPY number
  ,p_effective_date                 in     date
  ,p_aei_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_aei_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_aei_information1              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information2              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information3              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information4              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information5              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information6              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information7              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information8              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information9              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information10             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information11             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information12             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information13             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information14             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information15             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information16             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information17             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information18             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information19             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information20             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information21             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information22             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information23             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information24             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information25             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information26             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information27             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information28             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information29             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information30             in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_assignment_extra_info';
  l_object_version_number per_assignment_extra_info.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    savepoint ghr_update_asg_extra_info;
  --


     l_object_version_number      	     :=   p_object_version_number;

     ghr_session.set_session_var_for_core
     (p_effective_date      =>   p_effective_date
     );

	hr_assignment_extra_info_api.update_assignment_extra_info
		(
		p_assignment_extra_info_id	=>	p_assignment_extra_info_id	,
		p_aei_attribute_category	=>	p_aei_attribute_category	,
		p_aei_attribute1			=>	p_aei_attribute1			,
		p_aei_attribute2			=>	p_aei_attribute2			,
		p_aei_attribute3			=>	p_aei_attribute3			,
		p_aei_attribute4			=>	p_aei_attribute4			,
		p_aei_attribute5			=>	p_aei_attribute5			,
		p_aei_attribute6			=>	p_aei_attribute6			,
		p_aei_attribute7			=>	p_aei_attribute7			,
		p_aei_attribute8			=>	p_aei_attribute8			,
		p_aei_attribute9			=>	p_aei_attribute9	 		,
		p_aei_attribute10		=>	p_aei_attribute10		,
		p_aei_attribute11		=>	p_aei_attribute11		,
		p_aei_attribute12		=>	p_aei_attribute12		,
		p_aei_attribute13		=>	p_aei_attribute13		,
		p_aei_attribute14		=>	p_aei_attribute14		,
		p_aei_attribute15		=>	p_aei_attribute15		,
		p_aei_attribute16		=>	p_aei_attribute16		,
		p_aei_attribute17		=>	p_aei_attribute17		,
		p_aei_attribute18		=>	p_aei_attribute18		,
		p_aei_attribute19		=>	p_aei_attribute19		,
		p_aei_attribute20		=>	p_aei_attribute20		,
		p_aei_information_category	=>	p_aei_information_category	,
		p_aei_information1		=>	p_aei_information1		,
		p_aei_information2		=>	p_aei_information2		,
		p_aei_information3		=>	p_aei_information3		,
		p_aei_information4		=>	p_aei_information4		,
		p_aei_information5		=>	p_aei_information5		,
		p_aei_information6		=>	p_aei_information6		,
		p_aei_information7		=>	p_aei_information7		,
		p_aei_information8		=>	p_aei_information8		,
		p_aei_information9		=>	p_aei_information9		,
		p_aei_information10		=>	p_aei_information10		,
		p_aei_information11		=>	p_aei_information11		,
		p_aei_information12		=>	p_aei_information12		,
		p_aei_information13		=>	p_aei_information13		,
		p_aei_information14		=>	p_aei_information14		,
		p_aei_information15		=>	p_aei_information15		,
		p_aei_information16		=>	p_aei_information16		,
		p_aei_information17		=>	p_aei_information17		,
		p_aei_information18		=>	p_aei_information18		,
		p_aei_information19		=>	p_aei_information19		,
		p_aei_information20		=>	p_aei_information20		,
		p_aei_information21		=>	p_aei_information21		,
		p_aei_information22		=>	p_aei_information22		,
		p_aei_information23		=>	p_aei_information23		,
		p_aei_information24		=>	p_aei_information24		,
		p_aei_information25		=>	p_aei_information25		,
		p_aei_information26		=>	p_aei_information26		,
		p_aei_information27		=>	p_aei_information27		,
		p_aei_information28		=>	p_aei_information28		,
		p_aei_information29		=>	p_aei_information29		,
		p_aei_information30		=>	p_aei_information30		,
		p_object_version_number		=>	p_object_version_number
		);
  --
  hr_utility.set_location(l_proc, 7);
  --
  --
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
    ROLLBACK TO ghr_update_asg_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  when others then
    ROLLBACK TO ghr_update_asg_extra_info;
    raise;
end update_assignment_extra_info;
--
--
end ghr_assignment_extra_info_api;

/
