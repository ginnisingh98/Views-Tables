--------------------------------------------------------
--  DDL for Package Body IRC_REFERRAL_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_REFERRAL_INFO_API" as
/* $Header: irirfapi.pkb 120.0.12010000.2 2010/05/19 05:57:45 vmummidi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  IRC_REFERRAL_INFO_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_referral_info >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_referral_info
  (p_validate                       in       boolean  default false
  ,p_object_id                   	in 		 number
  ,p_object_type                    in 		 varchar2
  ,p_source_type            		in 		 varchar2 default null
  ,p_source_name            		in 		 varchar2 default null
  ,p_source_criteria1               in 	     varchar2 default null
  ,p_source_value1            	    in 		 varchar2 default null
  ,p_source_criteria2               in 		 varchar2 default null
  ,p_source_value2            	    in 		 varchar2 default null
  ,p_source_criteria3               in 		 varchar2 default null
  ,p_source_value3                  in 		 varchar2 default null
  ,p_source_criteria4               in 		 varchar2 default null
  ,p_source_value4                  in 		 varchar2 default null
  ,p_source_criteria5               in 		 varchar2 default null
  ,p_source_value5                  in 		 varchar2 default null
  ,p_source_person_id               in 		 number   default null
  ,p_candidate_comment              in 		 varchar2 default null
  ,p_employee_comment               in 		 varchar2 default null
  ,p_irf_attribute_category         in 		 varchar2 default null
  ,p_irf_attribute1                 in 		 varchar2 default null
  ,p_irf_attribute2                 in 		 varchar2 default null
  ,p_irf_attribute3                 in 		 varchar2 default null
  ,p_irf_attribute4                 in 		 varchar2 default null
  ,p_irf_attribute5                 in 		 varchar2 default null
  ,p_irf_attribute6                 in 		 varchar2 default null
  ,p_irf_attribute7                 in 		 varchar2 default null
  ,p_irf_attribute8                 in 		 varchar2 default null
  ,p_irf_attribute9                 in 		 varchar2 default null
  ,p_irf_attribute10                in 		 varchar2 default null
  ,p_irf_information_category       in 		 varchar2 default null
  ,p_irf_information1               in 		 varchar2 default null
  ,p_irf_information2               in 		 varchar2 default null
  ,p_irf_information3               in 		 varchar2 default null
  ,p_irf_information4               in 		 varchar2 default null
  ,p_irf_information5               in 		 varchar2 default null
  ,p_irf_information6               in 		 varchar2 default null
  ,p_irf_information7               in 		 varchar2 default null
  ,p_irf_information8               in 		 varchar2 default null
  ,p_irf_information9               in 		 varchar2 default null
  ,p_irf_information10              in 		 varchar2 default null
  ,p_object_created_by              in 		 varchar2 default null
  ,p_referral_info_id               out nocopy   number
  ,p_object_version_number          out nocopy   number
  ,p_start_date                     out nocopy   date
  ,p_end_date                       out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                     varchar2(72) := g_package||'create_referral_info';
  l_referral_info_id         number;
  l_object_version_number    number;
  l_start_date               date;
  l_end_date                 date;
  l_effective_date           date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_referral_info;
  --
  -- Call Before Process User Hook
  --
  begin
    irc_referral_info_bk1.create_referral_info_b
                 (p_object_id					=>		p_object_id
                 ,p_object_type					=>		p_object_type
                 ,p_source_type					=>		p_source_type
                 ,p_source_name					=>		p_source_name
                 ,p_source_criteria1			=>		p_source_criteria1
                 ,p_source_value1				=>		p_source_value1
                 ,p_source_criteria2			=>		p_source_criteria2
                 ,p_source_value2				=>		p_source_value2
                 ,p_source_criteria3			=>		p_source_criteria3
                 ,p_source_value3				=>		p_source_value3
                 ,p_source_criteria4			=>		p_source_criteria4
                 ,p_source_value4				=>		p_source_value4
                 ,p_source_criteria5			=>		p_source_criteria5
                 ,p_source_value5				=>		p_source_value5
                 ,p_source_person_id			=>		p_source_person_id
                 ,p_candidate_comment			=>		p_candidate_comment
                 ,p_employee_comment			=>		p_employee_comment
                 ,p_irf_attribute_category		=>		p_irf_attribute_category
                 ,p_irf_attribute1				=>		p_irf_attribute1
                 ,p_irf_attribute2				=>		p_irf_attribute2
                 ,p_irf_attribute3				=>		p_irf_attribute3
                 ,p_irf_attribute4				=>		p_irf_attribute4
                 ,p_irf_attribute5				=>		p_irf_attribute5
                 ,p_irf_attribute6				=>		p_irf_attribute6
                 ,p_irf_attribute7				=>		p_irf_attribute7
                 ,p_irf_attribute8				=>		p_irf_attribute8
                 ,p_irf_attribute9				=>		p_irf_attribute9
                 ,p_irf_attribute10				=>		p_irf_attribute10
                 ,p_irf_information_category	=>		p_irf_information_category
                 ,p_irf_information1			=>		p_irf_information1
                 ,p_irf_information2			=>		p_irf_information2
                 ,p_irf_information3			=>		p_irf_information3
                 ,p_irf_information4			=>		p_irf_information4
                 ,p_irf_information5			=>		p_irf_information5
                 ,p_irf_information6			=>		p_irf_information6
                 ,p_irf_information7			=>		p_irf_information7
                 ,p_irf_information8			=>		p_irf_information8
                 ,p_irf_information9			=>		p_irf_information9
                 ,p_irf_information10			=>		p_irf_information10
                 ,p_object_created_by			=>		p_object_created_by
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_referral_info'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;

  irc_irf_ins.ins(p_effective_date              =>      l_effective_date
                 ,p_object_id					=>		p_object_id
                 ,p_object_type					=>		p_object_type
                 ,p_source_type					=>		p_source_type
                 ,p_source_name					=>		p_source_name
                 ,p_source_criteria1			=>		p_source_criteria1
                 ,p_source_value1				=>		p_source_value1
                 ,p_source_criteria2			=>		p_source_criteria2
                 ,p_source_value2				=>		p_source_value2
                 ,p_source_criteria3			=>		p_source_criteria3
                 ,p_source_value3				=>		p_source_value3
                 ,p_source_criteria4			=>		p_source_criteria4
                 ,p_source_value4				=>		p_source_value4
                 ,p_source_criteria5			=>		p_source_criteria5
                 ,p_source_value5				=>		p_source_value5
                 ,p_source_person_id			=>		p_source_person_id
                 ,p_candidate_comment			=>		p_candidate_comment
                 ,p_employee_comment			=>		p_employee_comment
                 ,p_irf_attribute_category		=>		p_irf_attribute_category
                 ,p_irf_attribute1				=>		p_irf_attribute1
                 ,p_irf_attribute2				=>		p_irf_attribute2
                 ,p_irf_attribute3				=>		p_irf_attribute3
                 ,p_irf_attribute4				=>		p_irf_attribute4
                 ,p_irf_attribute5				=>		p_irf_attribute5
                 ,p_irf_attribute6				=>		p_irf_attribute6
                 ,p_irf_attribute7				=>		p_irf_attribute7
                 ,p_irf_attribute8				=>		p_irf_attribute8
                 ,p_irf_attribute9				=>		p_irf_attribute9
                 ,p_irf_attribute10				=>		p_irf_attribute10
                 ,p_irf_information_category	=>		p_irf_information_category
                 ,p_irf_information1			=>		p_irf_information1
                 ,p_irf_information2			=>		p_irf_information2
                 ,p_irf_information3			=>		p_irf_information3
                 ,p_irf_information4			=>		p_irf_information4
                 ,p_irf_information5			=>		p_irf_information5
                 ,p_irf_information6			=>		p_irf_information6
                 ,p_irf_information7			=>		p_irf_information7
                 ,p_irf_information8			=>		p_irf_information8
                 ,p_irf_information9			=>		p_irf_information9
                 ,p_irf_information10			=>		p_irf_information10
                 ,p_object_created_by			=>		p_object_created_by
                 ,p_referral_info_id            =>      l_referral_info_id
                 ,p_object_version_number       =>      l_object_version_number
                 ,p_start_date                  =>      l_start_date
                 ,p_end_date                    =>      l_end_date
                 );
  -- Call After Process User Hook
  --
  begin
    irc_referral_info_bk1.create_referral_info_a
                 (p_referral_info_id            =>      l_referral_info_id
                 ,p_object_id					=>		p_object_id
                 ,p_object_type					=>		p_object_type
                 ,p_source_type					=>		p_source_type
                 ,p_source_name					=>		p_source_name
                 ,p_source_criteria1			=>		p_source_criteria1
                 ,p_source_value1				=>		p_source_value1
                 ,p_source_criteria2			=>		p_source_criteria2
                 ,p_source_value2				=>		p_source_value2
                 ,p_source_criteria3			=>		p_source_criteria3
                 ,p_source_value3				=>		p_source_value3
                 ,p_source_criteria4			=>		p_source_criteria4
                 ,p_source_value4				=>		p_source_value4
                 ,p_source_criteria5			=>		p_source_criteria5
                 ,p_source_value5				=>		p_source_value5
                 ,p_source_person_id			=>		p_source_person_id
                 ,p_candidate_comment			=>		p_candidate_comment
                 ,p_employee_comment			=>		p_employee_comment
                 ,p_irf_attribute_category		=>		p_irf_attribute_category
                 ,p_irf_attribute1				=>		p_irf_attribute1
                 ,p_irf_attribute2				=>		p_irf_attribute2
                 ,p_irf_attribute3				=>		p_irf_attribute3
                 ,p_irf_attribute4				=>		p_irf_attribute4
                 ,p_irf_attribute5				=>		p_irf_attribute5
                 ,p_irf_attribute6				=>		p_irf_attribute6
                 ,p_irf_attribute7				=>		p_irf_attribute7
                 ,p_irf_attribute8				=>		p_irf_attribute8
                 ,p_irf_attribute9				=>		p_irf_attribute9
                 ,p_irf_attribute10				=>		p_irf_attribute10
                 ,p_irf_information_category	=>		p_irf_information_category
                 ,p_irf_information1			=>		p_irf_information1
                 ,p_irf_information2			=>		p_irf_information2
                 ,p_irf_information3			=>		p_irf_information3
                 ,p_irf_information4			=>		p_irf_information4
                 ,p_irf_information5			=>		p_irf_information5
                 ,p_irf_information6			=>		p_irf_information6
                 ,p_irf_information7			=>		p_irf_information7
                 ,p_irf_information8			=>		p_irf_information8
                 ,p_irf_information9			=>		p_irf_information9
                 ,p_irf_information10			=>		p_irf_information10
                 ,p_object_created_by			=>		p_object_created_by
                 ,p_object_version_number       =>      l_object_version_number
                 ,p_start_date                  =>      l_start_date
                 ,p_end_date                    =>      l_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_referral_info'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_referral_info_id          := l_referral_info_id;
  p_object_version_number     := l_object_version_number;
  p_start_date                := l_start_date;
  p_end_date                  := l_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_referral_info;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_referral_info_id          := null;
    p_object_version_number     := null;
    p_start_date                := null;
    p_end_date                  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_referral_info;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_referral_info_id          := null;
    p_object_version_number     := null;
    p_start_date                := null;
    p_end_date                  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_referral_info;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_referral_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_referral_info
  (p_validate                       in       boolean  default false
  ,p_referral_info_id               in       number
  ,p_source_type            		in 		 varchar2 default hr_api.g_varchar2
  ,p_source_name            		in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria1               in 	     varchar2 default hr_api.g_varchar2
  ,p_source_value1            	    in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria2               in 		 varchar2 default hr_api.g_varchar2
  ,p_source_value2            	    in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria3               in 		 varchar2 default hr_api.g_varchar2
  ,p_source_value3                  in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria4               in 		 varchar2 default hr_api.g_varchar2
  ,p_source_value4                  in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria5               in 		 varchar2 default hr_api.g_varchar2
  ,p_source_value5                  in 		 varchar2 default hr_api.g_varchar2
  ,p_source_person_id               in 		 number   default hr_api.g_number
  ,p_candidate_comment              in 		 varchar2 default hr_api.g_varchar2
  ,p_employee_comment               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute_category         in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute1                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute2                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute3                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute4                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute5                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute6                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute7                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute8                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute9                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute10                in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information_category       in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information1               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information2               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information3               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information4               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information5               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information6               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information7               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information8               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information9               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information10              in 		 varchar2 default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy   number
  ,p_start_date                     out nocopy   date
  ,p_end_date                       out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number    number;
  l_start_date               date;
  l_end_date                 date;
  l_effective_date           date;
  l_proc                     varchar2(72) := g_package||'update_referral_info';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_referral_info;
  --
  -- Call Before Process User Hook
  --
  begin
    irc_referral_info_bk2.update_referral_info_b
                 (p_referral_info_id            =>      p_referral_info_id
                 ,p_source_type					=>		p_source_type
                 ,p_source_name					=>		p_source_name
                 ,p_source_criteria1			=>		p_source_criteria1
                 ,p_source_value1				=>		p_source_value1
                 ,p_source_criteria2			=>		p_source_criteria2
                 ,p_source_value2				=>		p_source_value2
                 ,p_source_criteria3			=>		p_source_criteria3
                 ,p_source_value3				=>		p_source_value3
                 ,p_source_criteria4			=>		p_source_criteria4
                 ,p_source_value4				=>		p_source_value4
                 ,p_source_criteria5			=>		p_source_criteria5
                 ,p_source_value5				=>		p_source_value5
                 ,p_source_person_id			=>		p_source_person_id
                 ,p_candidate_comment			=>		p_candidate_comment
                 ,p_employee_comment			=>		p_employee_comment
                 ,p_irf_attribute_category		=>		p_irf_attribute_category
                 ,p_irf_attribute1				=>		p_irf_attribute1
                 ,p_irf_attribute2				=>		p_irf_attribute2
                 ,p_irf_attribute3				=>		p_irf_attribute3
                 ,p_irf_attribute4				=>		p_irf_attribute4
                 ,p_irf_attribute5				=>		p_irf_attribute5
                 ,p_irf_attribute6				=>		p_irf_attribute6
                 ,p_irf_attribute7				=>		p_irf_attribute7
                 ,p_irf_attribute8				=>		p_irf_attribute8
                 ,p_irf_attribute9				=>		p_irf_attribute9
                 ,p_irf_attribute10				=>		p_irf_attribute10
                 ,p_irf_information_category	=>		p_irf_information_category
                 ,p_irf_information1			=>		p_irf_information1
                 ,p_irf_information2			=>		p_irf_information2
                 ,p_irf_information3			=>		p_irf_information3
                 ,p_irf_information4			=>		p_irf_information4
                 ,p_irf_information5			=>		p_irf_information5
                 ,p_irf_information6			=>		p_irf_information6
                 ,p_irf_information7			=>		p_irf_information7
                 ,p_irf_information8			=>		p_irf_information8
                 ,p_irf_information9			=>		p_irf_information9
                 ,p_irf_information10			=>		p_irf_information10
                 ,p_object_version_number       =>      p_object_version_number
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_referral_info'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_object_version_number := p_object_version_number;
  if p_referral_info_id is null then
    -- RAISE ERROR SAYING INVALID REFERRAL_INFO_ID
    fnd_message.set_name('PER', 'IRC_INV_REF_INFO_ID');
    fnd_message.raise_error;
  end if;
  irc_irf_upd.upd(p_effective_date              =>     l_effective_date
                 ,p_datetrack_mode              =>     'UPDATE'
                 ,p_referral_info_id            =>      p_referral_info_id
                 ,p_object_version_number       =>      l_object_version_number
                 ,p_source_type					=>		p_source_type
                 ,p_source_name					=>		p_source_name
                 ,p_source_criteria1			=>		p_source_criteria1
                 ,p_source_value1				=>		p_source_value1
                 ,p_source_criteria2			=>		p_source_criteria2
                 ,p_source_value2				=>		p_source_value2
                 ,p_source_criteria3			=>		p_source_criteria3
                 ,p_source_value3				=>		p_source_value3
                 ,p_source_criteria4			=>		p_source_criteria4
                 ,p_source_value4				=>		p_source_value4
                 ,p_source_criteria5			=>		p_source_criteria5
                 ,p_source_value5				=>		p_source_value5
                 ,p_source_person_id			=>		p_source_person_id
                 ,p_candidate_comment			=>		p_candidate_comment
                 ,p_employee_comment			=>		p_employee_comment
                 ,p_irf_attribute_category		=>		p_irf_attribute_category
                 ,p_irf_attribute1				=>		p_irf_attribute1
                 ,p_irf_attribute2				=>		p_irf_attribute2
                 ,p_irf_attribute3				=>		p_irf_attribute3
                 ,p_irf_attribute4				=>		p_irf_attribute4
                 ,p_irf_attribute5				=>		p_irf_attribute5
                 ,p_irf_attribute6				=>		p_irf_attribute6
                 ,p_irf_attribute7				=>		p_irf_attribute7
                 ,p_irf_attribute8				=>		p_irf_attribute8
                 ,p_irf_attribute9				=>		p_irf_attribute9
                 ,p_irf_attribute10				=>		p_irf_attribute10
                 ,p_irf_information_category	=>		p_irf_information_category
                 ,p_irf_information1			=>		p_irf_information1
                 ,p_irf_information2			=>		p_irf_information2
                 ,p_irf_information3			=>		p_irf_information3
                 ,p_irf_information4			=>		p_irf_information4
                 ,p_irf_information5			=>		p_irf_information5
                 ,p_irf_information6			=>		p_irf_information6
                 ,p_irf_information7			=>		p_irf_information7
                 ,p_irf_information8			=>		p_irf_information8
                 ,p_irf_information9			=>		p_irf_information9
                 ,p_irf_information10			=>		p_irf_information10
                 ,p_start_date                  =>      l_start_date
                 ,p_end_date                    =>      l_end_date
                 );
  --
  -- Call After Process User Hook
  --
  begin
    irc_referral_info_bk2.update_referral_info_a
                 (p_referral_info_id            =>      p_referral_info_id
                 ,p_source_type					=>		p_source_type
                 ,p_source_name					=>		p_source_name
                 ,p_source_criteria1			=>		p_source_criteria1
                 ,p_source_value1				=>		p_source_value1
                 ,p_source_criteria2			=>		p_source_criteria2
                 ,p_source_value2				=>		p_source_value2
                 ,p_source_criteria3			=>		p_source_criteria3
                 ,p_source_value3				=>		p_source_value3
                 ,p_source_criteria4			=>		p_source_criteria4
                 ,p_source_value4				=>		p_source_value4
                 ,p_source_criteria5			=>		p_source_criteria5
                 ,p_source_value5				=>		p_source_value5
                 ,p_source_person_id			=>		p_source_person_id
                 ,p_candidate_comment			=>		p_candidate_comment
                 ,p_employee_comment			=>		p_employee_comment
                 ,p_irf_attribute_category		=>		p_irf_attribute_category
                 ,p_irf_attribute1				=>		p_irf_attribute1
                 ,p_irf_attribute2				=>		p_irf_attribute2
                 ,p_irf_attribute3				=>		p_irf_attribute3
                 ,p_irf_attribute4				=>		p_irf_attribute4
                 ,p_irf_attribute5				=>		p_irf_attribute5
                 ,p_irf_attribute6				=>		p_irf_attribute6
                 ,p_irf_attribute7				=>		p_irf_attribute7
                 ,p_irf_attribute8				=>		p_irf_attribute8
                 ,p_irf_attribute9				=>		p_irf_attribute9
                 ,p_irf_attribute10				=>		p_irf_attribute10
                 ,p_irf_information_category	=>		p_irf_information_category
                 ,p_irf_information1			=>		p_irf_information1
                 ,p_irf_information2			=>		p_irf_information2
                 ,p_irf_information3			=>		p_irf_information3
                 ,p_irf_information4			=>		p_irf_information4
                 ,p_irf_information5			=>		p_irf_information5
                 ,p_irf_information6			=>		p_irf_information6
                 ,p_irf_information7			=>		p_irf_information7
                 ,p_irf_information8			=>		p_irf_information8
                 ,p_irf_information9			=>		p_irf_information9
                 ,p_irf_information10			=>		p_irf_information10
                 ,p_object_version_number       =>      p_object_version_number
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_referral_info'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number := l_object_version_number;
  p_start_date            := l_start_date;
  p_end_date              := l_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_referral_info;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_start_date  := null;
    p_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_referral_info;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_start_date  := null;
    p_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_referral_info;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< copy_referral_details >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_referral_details
  (p_source_assignment_id in number
  ,p_target_assignment_id in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'copy_referral_details';
  --
  l_referral_info_id  irc_referral_info.referral_info_id%type;
  --
  cursor csr_referral_info is
  select *
    from irc_referral_info
   where object_id = p_source_assignment_id;
  --
  Cursor C_Sel1 is select irc_referral_info_s.nextval from sys.dual;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_referral_details;
  --
  --
  -- Process Logic
  --
  --
  Open C_Sel1;
  Fetch C_Sel1 Into l_referral_info_id;
  Close C_Sel1;
  --
  FOR l_ref_rec in csr_referral_info
  LOOP
  --
  insert into irc_referral_info
      (referral_info_id
      ,object_id
      ,object_type
      ,start_date
      ,end_date
      ,source_type
      ,source_name
      ,source_criteria1
      ,source_value1
      ,source_criteria2
      ,source_value2
      ,source_criteria3
      ,source_value3
      ,source_criteria4
      ,source_value4
      ,source_criteria5
      ,source_value5
      ,source_person_id
      ,candidate_comment
      ,employee_comment
      ,irf_attribute_category
      ,irf_attribute1
      ,irf_attribute2
      ,irf_attribute3
      ,irf_attribute4
      ,irf_attribute5
      ,irf_attribute6
      ,irf_attribute7
      ,irf_attribute8
      ,irf_attribute9
      ,irf_attribute10
      ,irf_information_category
      ,irf_information1
      ,irf_information2
      ,irf_information3
      ,irf_information4
      ,irf_information5
      ,irf_information6
      ,irf_information7
      ,irf_information8
      ,irf_information9
      ,irf_information10
      ,object_created_by
      ,object_version_number
      )
  Values
    (l_referral_info_id
    ,p_target_assignment_id
    ,l_ref_rec.object_type
    ,l_ref_rec.start_date
    ,l_ref_rec.end_date
    ,l_ref_rec.source_type
    ,l_ref_rec.source_name
    ,l_ref_rec.source_criteria1
    ,l_ref_rec.source_value1
    ,l_ref_rec.source_criteria2
    ,l_ref_rec.source_value2
    ,l_ref_rec.source_criteria3
    ,l_ref_rec.source_value3
    ,l_ref_rec.source_criteria4
    ,l_ref_rec.source_value4
    ,l_ref_rec.source_criteria5
    ,l_ref_rec.source_value5
    ,l_ref_rec.source_person_id
    ,l_ref_rec.candidate_comment
    ,l_ref_rec.employee_comment
    ,l_ref_rec.irf_attribute_category
    ,l_ref_rec.irf_attribute1
    ,l_ref_rec.irf_attribute2
    ,l_ref_rec.irf_attribute3
    ,l_ref_rec.irf_attribute4
    ,l_ref_rec.irf_attribute5
    ,l_ref_rec.irf_attribute6
    ,l_ref_rec.irf_attribute7
    ,l_ref_rec.irf_attribute8
    ,l_ref_rec.irf_attribute9
    ,l_ref_rec.irf_attribute10
    ,l_ref_rec.irf_information_category
    ,l_ref_rec.irf_information1
    ,l_ref_rec.irf_information2
    ,l_ref_rec.irf_information3
    ,l_ref_rec.irf_information4
    ,l_ref_rec.irf_information5
    ,l_ref_rec.irf_information6
    ,l_ref_rec.irf_information7
    ,l_ref_rec.irf_information8
    ,l_ref_rec.irf_information9
    ,l_ref_rec.irf_information10
    ,l_ref_rec.object_created_by
    ,l_ref_rec.object_version_number
    );
  --
  END LOOP;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_referral_details;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 30);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_referral_details;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 40);
    raise;
end copy_referral_details;
--
end IRC_REFERRAL_INFO_API;

/
