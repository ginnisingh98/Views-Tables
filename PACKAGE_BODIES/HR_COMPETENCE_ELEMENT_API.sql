--------------------------------------------------------
--  DDL for Package Body HR_COMPETENCE_ELEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COMPETENCE_ELEMENT_API" as
/* $Header: pecelapi.pkb 120.3 2006/02/13 14:07:13 vbala noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_competence_element_api.';
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <create_competence_element> >--------------------|
-- ---------------------------------------------------------------------------
--
procedure create_competence_element
 (p_validate                     in     boolean         default false,
  p_competence_element_id        out nocopy number,
  p_object_version_number        out nocopy number,
  p_type                         in varchar2,
  p_business_group_id            in number           default null,
  p_enterprise_id		 in number	     default null,
  p_competence_id                in number           default null,
  p_proficiency_level_id         in number           default null,
  p_high_proficiency_level_id    in number           default null,
  p_weighting_level_id           in number           default null,
  p_rating_level_id              in number           default null,
  p_person_id                    in number           default null,
  p_job_id                       in number           default null,
  p_valid_grade_id               in number           default null,
  p_position_id                  in number           default null,
  p_organization_id              in number           default null,
  p_parent_competence_element_id in number           default null,
  p_activity_version_id          in number           default null,
  p_assessment_id                in number           default null,
  p_assessment_type_id           in number           default null,
  p_mandatory           	 in varchar2         default null,
  p_effective_date_from          in date             default null,
  p_effective_date_to            in date             default null,
  p_group_competence_type        in varchar2         default null,
  p_competence_type              in varchar2         default null,
  p_normal_elapse_duration       in number           default null,
  p_normal_elapse_duration_unit  in varchar2         default null,
  p_sequence_number              in number           default null,
  p_source_of_proficiency_level  in varchar2         default null,
  p_line_score                   in number           default null,
  p_certification_date           in date             default null,
  p_certification_method         in varchar2         default null,
  p_next_certification_date      in date             default null,
  p_comments                     in varchar2         default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_effective_date		 in Date,
  p_object_id                    in number           default null,
  p_object_name                  in varchar2         default null,
  p_party_id                     in number           default null  -- HR/TCA merge
 ,p_qualification_type_id        in number           default null
 ,p_unit_standard_type           in varchar2         default null
 ,p_status                       in varchar2         default null
 ,p_information_category         in varchar2         default null
 ,p_information1                 in varchar2         default null
 ,p_information2                 in varchar2         default null
 ,p_information3                 in varchar2         default null
 ,p_information4                 in varchar2         default null
 ,p_information5                 in varchar2         default null
 ,p_information6                 in varchar2         default null
 ,p_information7                 in varchar2         default null
 ,p_information8                 in varchar2         default null
 ,p_information9                 in varchar2         default null
 ,p_information10                in varchar2         default null
 ,p_information11                in varchar2         default null
 ,p_information12                in varchar2         default null
 ,p_information13                in varchar2         default null
 ,p_information14                in varchar2         default null
 ,p_information15                in varchar2         default null
 ,p_information16                in varchar2         default null
 ,p_information17                in varchar2         default null
 ,p_information18                in varchar2         default null
 ,p_information19                in varchar2         default null
 ,p_information20                in varchar2         default null
 ,p_achieved_date                in date             default null
 ,p_appr_line_score              in number           default null
  ) is
--
  -- Declare cursors and local variables
  --
  --
  l_proc                	varchar2(72) := g_package||'create_competence_elements';
  l_competence_element_id	per_competence_elements.competence_id%TYPE;
  l_object_version_number	per_competence_elements.object_version_number%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_competence_element;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_competence_element_bk1.create_competence_element_b	(
         p_type                         => p_type
        ,p_business_group_id            => p_business_group_id
        ,p_enterprise_id	        => p_enterprise_id
        ,p_competence_id                => p_competence_id
        ,p_proficiency_level_id         => p_proficiency_level_id
        ,p_high_proficiency_level_id    => p_high_proficiency_level_id
        ,p_weighting_level_id           => p_weighting_level_id
        ,p_rating_level_id              => p_rating_level_id
        ,p_person_id                    => p_person_id
        ,p_job_id                       => p_job_id
        ,p_valid_grade_id               => p_valid_grade_id
        ,p_position_id                  => p_position_id
        ,p_organization_id              => p_organization_id
        ,p_parent_competence_element_id => p_parent_competence_element_id
        ,p_activity_version_id          => p_activity_version_id
        ,p_assessment_id                => p_assessment_id
        ,p_assessment_type_id           => p_assessment_type_id
        ,p_mandatory                    => p_mandatory
        ,p_effective_date_from          => p_effective_date_from
        ,p_effective_date_to            => p_effective_date_to
        ,p_group_competence_type        => p_group_competence_type
        ,p_competence_type              => p_competence_type
        ,p_normal_elapse_duration       => p_normal_elapse_duration
        ,p_normal_elapse_duration_unit  => p_normal_elapse_duration_unit
        ,p_sequence_number              => p_sequence_number
        ,p_source_of_proficiency_level  => p_source_of_proficiency_level
        ,p_line_score                   => p_line_score
        ,p_certification_date           => p_certification_date
        ,p_certification_method         => p_certification_method
        ,p_next_certification_date      => p_next_certification_date
        ,p_comments                     => p_comments
        ,p_attribute_category           => p_attribute_category
        ,p_attribute1                   => p_attribute1
        ,p_attribute2                   => p_attribute2
        ,p_attribute3                   => p_attribute3
        ,p_attribute4                   => p_attribute4
        ,p_attribute5                   => p_attribute5
        ,p_attribute6                   => p_attribute6
        ,p_attribute7                   => p_attribute7
        ,p_attribute8                   => p_attribute8
        ,p_attribute9                   => p_attribute9
        ,p_attribute10                  => p_attribute10
        ,p_attribute11                  => p_attribute11
        ,p_attribute12                  => p_attribute12
        ,p_attribute13                  => p_attribute13
        ,p_attribute14                  => p_attribute14
        ,p_attribute15                  => p_attribute15
        ,p_attribute16                  => p_attribute16
        ,p_attribute17                  => p_attribute17
        ,p_attribute18                  => p_attribute18
        ,p_attribute19                  => p_attribute19
        ,p_attribute20                  => p_attribute20
        ,p_effective_date	        => p_effective_date
   	,p_object_id                    => p_object_id
      	,p_object_name                  => p_object_name
      	,p_party_id                     => p_party_id
      	,p_qualification_type_id        => p_qualification_type_id
      	,p_unit_standard_type           => p_unit_standard_type
      	,p_status                       => p_status
        ,p_information_category         => p_information_category
        ,p_information1                 => p_information1
        ,p_information2                 => p_information2
        ,p_information3                 => p_information3
        ,p_information4                 => p_information4
        ,p_information5                 => p_information5
        ,p_information6                 => p_information6
        ,p_information7                 => p_information7
        ,p_information8                 => p_information8
        ,p_information9                 => p_information9
        ,p_information10                => p_information10
        ,p_information11                => p_information11
        ,p_information12                => p_information12
        ,p_information13                => p_information13
        ,p_information14                => p_information14
        ,p_information15                => p_information15
        ,p_information16                => p_information16
        ,p_information17                => p_information17
        ,p_information18                => p_information18
        ,p_information19                => p_information19
        ,p_information20                => p_information20
        ,p_achieved_date                => p_achieved_date
        ,p_appr_line_score              => p_appr_line_score
  	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_competence_element',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  per_cel_ins.ins (
   p_competence_element_id         	=> l_competence_element_id
  ,p_object_version_number        	=> l_object_version_number
  ,p_type                               => p_type
  ,p_business_group_id           	=> p_business_group_id
  ,p_enterprise_id			=> p_enterprise_id
  ,p_competence_id               	=> p_competence_id
  ,p_proficiency_level_id          	=> p_proficiency_level_id
  ,p_high_proficiency_level_id     	=> p_high_proficiency_level_id
  ,p_weighting_level_id           	=> p_weighting_level_id
  ,p_rating_level_id             	=> p_rating_level_id
  ,p_person_id                    	=> p_person_id
  ,p_job_id                       	=> p_job_id
  ,p_valid_grade_id                     => p_valid_grade_id
  ,p_position_id                   	=> p_position_id
  ,p_organization_id               	=> p_organization_id
  ,p_parent_competence_element_id  	=> p_parent_competence_element_id
  ,p_activity_version_id           	=> p_activity_version_id
  ,p_assessment_id                 	=> p_assessment_id
  ,p_assessment_type_id         	=> p_assessment_type_id
  ,p_mandatory            		=> p_mandatory
  ,p_effective_date_from          	=> p_effective_date_from
  ,p_effective_date_to           	=> p_effective_date_to
  ,p_group_competence_type         	=> p_group_competence_type
  ,p_competence_type               	=> p_competence_type
  ,p_normal_elapse_duration        	=> p_normal_elapse_duration
  ,p_normal_elapse_duration_unit   	=> p_normal_elapse_duration_unit
  ,p_sequence_number               	=> p_sequence_number
  ,p_source_of_proficiency_level   	=> p_source_of_proficiency_level
  ,p_line_score                    	=> p_line_score
  ,p_certification_date            	=> p_certification_date
  ,p_certification_method          	=> p_certification_method
  ,p_next_certification_date       	=> p_next_certification_date
  ,p_comments                      	=> p_comments
  ,p_attribute_category            	=> p_attribute_category
  ,p_attribute1                    	=> p_attribute1
  ,p_attribute2                   	=> p_attribute2
  ,p_attribute3                 	=> p_attribute3
  ,p_attribute4                    	=> p_attribute4
  ,p_attribute5                    	=> p_attribute5
  ,p_attribute6                    	=> p_attribute6
  ,p_attribute7                    	=> p_attribute7
  ,p_attribute8                   	=> p_attribute8
  ,p_attribute9                    	=> p_attribute9
  ,p_attribute10                   	=> p_attribute10
  ,p_attribute11                  	=> p_attribute11
  ,p_attribute12                   	=> p_attribute12
  ,p_attribute13                 	=> p_attribute13
  ,p_attribute14                  	=> p_attribute14
  ,p_attribute15                   	=> p_attribute15
  ,p_attribute16                  	=> p_attribute16
  ,p_attribute17             	        => p_attribute17
  ,p_attribute18                  	=> p_attribute18
  ,p_attribute19                   	=> p_attribute19
  ,p_attribute20                	=> p_attribute20
  ,p_effective_date		 	=> p_effective_date
  ,p_validate                      	=> p_validate
  ,p_object_id                          => p_object_id
  ,p_object_name                        => p_object_name
  ,p_party_id                           => p_party_id -- HR/TCA merge
  ,p_qualification_type_id              => p_qualification_type_id
  ,p_unit_standard_type                 => p_unit_standard_type
  ,p_status                             => p_status
  ,p_information_category               => p_information_category
  ,p_information1                       => p_information1
  ,p_information2                       => p_information2
  ,p_information3                       => p_information3
  ,p_information4                       => p_information4
  ,p_information5                       => p_information5
  ,p_information6                       => p_information6
  ,p_information7                       => p_information7
  ,p_information8                       => p_information8
  ,p_information9                       => p_information9
  ,p_information10                      => p_information10
  ,p_information11                      => p_information11
  ,p_information12                      => p_information12
  ,p_information13                      => p_information13
  ,p_information14                      => p_information14
  ,p_information15                      => p_information15
  ,p_information16                      => p_information16
  ,p_information17                      => p_information17
  ,p_information18                      => p_information18
  ,p_information19                      => p_information19
  ,p_information20                      => p_information20
  ,p_achieved_date                      => p_achieved_date
  ,p_appr_line_score                    => p_appr_line_score
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  --
  -- Call After Process User Hook
  --
  begin
	hr_competence_element_bk1.create_competence_element_a	(
         p_competence_element_id        => l_competence_element_id
        ,p_object_version_number        => l_object_version_number
        ,p_type                         => p_type
        ,p_business_group_id            => p_business_group_id
        ,p_enterprise_id	        => p_enterprise_id
        ,p_competence_id                => p_competence_id
        ,p_proficiency_level_id         => p_proficiency_level_id
        ,p_high_proficiency_level_id    => p_high_proficiency_level_id
        ,p_weighting_level_id           => p_weighting_level_id
        ,p_rating_level_id              => p_rating_level_id
        ,p_person_id                    => p_person_id
        ,p_job_id                       => p_job_id
        ,p_valid_grade_id               => p_valid_grade_id
        ,p_position_id                  => p_position_id
        ,p_organization_id              => p_organization_id
        ,p_parent_competence_element_id => p_parent_competence_element_id
        ,p_activity_version_id          => p_activity_version_id
        ,p_assessment_id                => p_assessment_id
        ,p_assessment_type_id           => p_assessment_type_id
        ,p_mandatory                    => p_mandatory
        ,p_effective_date_from          => p_effective_date_from
        ,p_effective_date_to            => p_effective_date_to
        ,p_group_competence_type        => p_group_competence_type
        ,p_competence_type              => p_competence_type
        ,p_normal_elapse_duration       => p_normal_elapse_duration
        ,p_normal_elapse_duration_unit  => p_normal_elapse_duration_unit
        ,p_sequence_number              => p_sequence_number
        ,p_source_of_proficiency_level  => p_source_of_proficiency_level
        ,p_line_score                   => p_line_score
        ,p_certification_date           => p_certification_date
        ,p_certification_method         => p_certification_method
        ,p_next_certification_date      => p_next_certification_date
        ,p_comments                     => p_comments
        ,p_attribute_category           => p_attribute_category
        ,p_attribute1                   => p_attribute1
        ,p_attribute2                   => p_attribute2
        ,p_attribute3                   => p_attribute3
        ,p_attribute4                   => p_attribute4
        ,p_attribute5                   => p_attribute5
        ,p_attribute6                   => p_attribute6
        ,p_attribute7                   => p_attribute7
        ,p_attribute8                   => p_attribute8
        ,p_attribute9                   => p_attribute9
        ,p_attribute10                  => p_attribute10
        ,p_attribute11                  => p_attribute11
        ,p_attribute12                  => p_attribute12
        ,p_attribute13                  => p_attribute13
        ,p_attribute14                  => p_attribute14
        ,p_attribute15                  => p_attribute15
        ,p_attribute16                  => p_attribute16
        ,p_attribute17                  => p_attribute17
        ,p_attribute18                  => p_attribute18
        ,p_attribute19                  => p_attribute19
        ,p_attribute20                  => p_attribute20
        ,p_effective_date	        => p_effective_date
 	,p_object_id                    => p_object_id
        ,p_object_name                  => p_object_name
  	,p_party_id                    	=> p_party_id -- HR/TCA merge
      	,p_qualification_type_id        => p_qualification_type_id
      	,p_unit_standard_type           => p_unit_standard_type
      	,p_status                       => p_status
        ,p_information_category         => p_information_category
        ,p_information1                 => p_information1
        ,p_information2                 => p_information2
        ,p_information3                 => p_information3
        ,p_information4                 => p_information4
        ,p_information5                 => p_information5
        ,p_information6                 => p_information6
        ,p_information7                 => p_information7
        ,p_information8                 => p_information8
        ,p_information9                 => p_information9
        ,p_information10                => p_information10
        ,p_information11                => p_information11
        ,p_information12                => p_information12
        ,p_information13                => p_information13
        ,p_information14                => p_information14
        ,p_information15                => p_information15
        ,p_information16                => p_information16
        ,p_information17                => p_information17
        ,p_information18                => p_information18
        ,p_information19                => p_information19
        ,p_information20                => p_information20
        ,p_achieved_date                => p_achieved_date
	,p_appr_line_score              => p_appr_line_score
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_competence_element',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After process user hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_competence_element_id          := l_competence_element_id;
  p_object_version_number  	   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_competence_element;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_competence_element_id          := null;
    p_object_version_number  	     := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO create_competence_element;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end create_competence_element;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <update_competence_element> >--------------------|
-- ---------------------------------------------------------------------------
--
procedure update_competence_element
  (
  p_competence_element_id        in number,
  p_object_version_number        in out nocopy number,
  p_proficiency_level_id         in number           default hr_api.g_number,
  p_high_proficiency_level_id    in number           default hr_api.g_number,
  p_weighting_level_id           in number           default hr_api.g_number,
  p_rating_level_id              in number           default hr_api.g_number,
  p_mandatory           	 in varchar2         default hr_api.g_varchar2,
  p_effective_date_from          in date             default hr_api.g_date,
  p_effective_date_to            in date             default hr_api.g_date,
  p_group_competence_type        in varchar2         default hr_api.g_varchar2,
  p_competence_type              in varchar2         default hr_api.g_varchar2,
  p_normal_elapse_duration       in number           default hr_api.g_number,
  p_normal_elapse_duration_unit  in varchar2         default hr_api.g_varchar2,
  p_sequence_number              in number           default hr_api.g_number,
  p_source_of_proficiency_level  in varchar2         default hr_api.g_varchar2,
  p_line_score                   in number           default hr_api.g_number,
  p_certification_date           in date             default hr_api.g_date,
  p_certification_method         in varchar2         default hr_api.g_varchar2,
  p_next_certification_date      in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_effective_date		 in Date,
  p_validate                     in boolean    	     default false,
  p_party_id     		 in number
 ,p_qualification_type_id        in number           default hr_api.g_number
 ,p_unit_standard_type           in varchar2         default hr_api.g_varchar2
 ,p_status                       in varchar2         default hr_api.g_varchar2
 ,p_information_category         in varchar2         default hr_api.g_varchar2
 ,p_information1                 in varchar2         default hr_api.g_varchar2
 ,p_information2                 in varchar2         default hr_api.g_varchar2
 ,p_information3                 in varchar2         default hr_api.g_varchar2
 ,p_information4                 in varchar2         default hr_api.g_varchar2
 ,p_information5                 in varchar2         default hr_api.g_varchar2
 ,p_information6                 in varchar2         default hr_api.g_varchar2
 ,p_information7                 in varchar2         default hr_api.g_varchar2
 ,p_information8                 in varchar2         default hr_api.g_varchar2
 ,p_information9                 in varchar2         default hr_api.g_varchar2
 ,p_information10                in varchar2         default hr_api.g_varchar2
 ,p_information11                in varchar2         default hr_api.g_varchar2
 ,p_information12                in varchar2         default hr_api.g_varchar2
 ,p_information13                in varchar2         default hr_api.g_varchar2
 ,p_information14                in varchar2         default hr_api.g_varchar2
 ,p_information15                in varchar2         default hr_api.g_varchar2
 ,p_information16                in varchar2         default hr_api.g_varchar2
 ,p_information17                in varchar2         default hr_api.g_varchar2
 ,p_information18                in varchar2         default hr_api.g_varchar2
 ,p_information19                in varchar2         default hr_api.g_varchar2
 ,p_information20                in varchar2         default hr_api.g_varchar2
 ,p_achieved_date                in date             default hr_api.g_date
 ,p_appr_line_score              in number           default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc                	varchar2(72) := g_package||'update_competence_element';
  l_object_version_number	per_competence_elements.object_version_number%TYPE;
  --
  lv_object_version_number       per_competence_elements.object_version_number%TYPE := p_object_version_number ;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_competence_element;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_competence_element_bk2.update_competence_element_b	(
        p_competence_element_id         	=> p_competence_element_id
       ,p_object_version_number	        	=> p_object_version_number
       ,p_proficiency_level_id          	=> p_proficiency_level_id
       ,p_high_proficiency_level_id     	=> p_high_proficiency_level_id
       ,p_weighting_level_id   	        	=> p_weighting_level_id
       ,p_rating_level_id       	     	=> p_rating_level_id
       ,p_mandatory             	 	=> p_mandatory
       ,p_effective_date_from          		=> p_effective_date_from
       ,p_effective_date_to           		=> p_effective_date_to
       ,p_group_competence_type         	=> p_group_competence_type
       ,p_competence_type               	=> p_competence_type
       ,p_normal_elapse_duration        	=> p_normal_elapse_duration
       ,p_normal_elapse_duration_unit   	=> p_normal_elapse_duration_unit
       ,p_sequence_number               	=> p_sequence_number
       ,p_source_of_proficiency_level   	=> p_source_of_proficiency_level
       ,p_line_score                    	=> p_line_score
       ,p_certification_date            	=> p_certification_date
       ,p_certification_method          	=> p_certification_method
       ,p_next_certification_date       	=> p_next_certification_date
       ,p_comments                      	=> p_comments
       ,p_attribute_category            	=> p_attribute_category
       ,p_attribute1                    	=> p_attribute1
       ,p_attribute2                   		=> p_attribute2
       ,p_attribute3                 		=> p_attribute3
       ,p_attribute4                    	=> p_attribute4
       ,p_attribute5                    	=> p_attribute5
       ,p_attribute6                    	=> p_attribute6
       ,p_attribute7                    	=> p_attribute7
       ,p_attribute8                   		=> p_attribute8
       ,p_attribute9                    	=> p_attribute9
       ,p_attribute10                   	=> p_attribute10
       ,p_attribute11                  		=> p_attribute11
       ,p_attribute12                   	=> p_attribute12
       ,p_attribute13                 		=> p_attribute13
       ,p_attribute14                  		=> p_attribute14
       ,p_attribute15                   	=> p_attribute15
       ,p_attribute16                  		=> p_attribute16
       ,p_attribute17                  		=> p_attribute17
       ,p_attribute18                  		=> p_attribute18
       ,p_attribute19                   	=> p_attribute19
       ,p_attribute20                		=> p_attribute20
       ,p_effective_date		 	=> p_effective_date
       ,p_qualification_type_id                 => p_qualification_type_id
       ,p_unit_standard_type                    => p_unit_standard_type
       ,p_status                                => p_status
       ,p_information_category                  => p_information_category
       ,p_information1                          => p_information1
       ,p_information2                          => p_information2
       ,p_information3                          => p_information3
       ,p_information4                          => p_information4
       ,p_information5                          => p_information5
       ,p_information6                          => p_information6
       ,p_information7                          => p_information7
       ,p_information8                          => p_information8
       ,p_information9                          => p_information9
       ,p_information10                         => p_information10
       ,p_information11                         => p_information11
       ,p_information12                         => p_information12
       ,p_information13                         => p_information13
       ,p_information14                         => p_information14
       ,p_information15                         => p_information15
       ,p_information16                         => p_information16
       ,p_information17                         => p_information17
       ,p_information18                         => p_information18
       ,p_information19                         => p_information19
       ,p_information20                         => p_information20
       ,p_achieved_date                         => p_achieved_date
       ,p_appr_line_score                       => p_appr_line_score
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_competence_element',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  per_cel_upd.upd (
  p_competence_element_id         	=> p_competence_element_id
  ,p_object_version_number        	=> p_object_version_number
  ,p_proficiency_level_id          	=> p_proficiency_level_id
  ,p_high_proficiency_level_id     	=> p_high_proficiency_level_id
  ,p_weighting_level_id           	=> p_weighting_level_id
  ,p_rating_level_id             	=> p_rating_level_id
  ,p_mandatory            		=> p_mandatory
  ,p_effective_date_from          	=> p_effective_date_from
  ,p_effective_date_to           	=> p_effective_date_to
  ,p_group_competence_type         	=> p_group_competence_type
  ,p_competence_type               	=> p_competence_type
  ,p_normal_elapse_duration        	=> p_normal_elapse_duration
  ,p_normal_elapse_duration_unit   	=> p_normal_elapse_duration_unit
  ,p_sequence_number               	=> p_sequence_number
  ,p_source_of_proficiency_level   	=> p_source_of_proficiency_level
  ,p_line_score                    	=> p_line_score
  ,p_certification_date            	=> p_certification_date
  ,p_certification_method          	=> p_certification_method
  ,p_next_certification_date       	=> p_next_certification_date
  ,p_comments                      	=> p_comments
  ,p_attribute_category            	=> p_attribute_category
  ,p_attribute1                    	=> p_attribute1
  ,p_attribute2                   	=> p_attribute2
  ,p_attribute3                 	=> p_attribute3
  ,p_attribute4                    	=> p_attribute4
  ,p_attribute5                    	=> p_attribute5
  ,p_attribute6                    	=> p_attribute6
  ,p_attribute7                    	=> p_attribute7
  ,p_attribute8                   	=> p_attribute8
  ,p_attribute9                    	=> p_attribute9
  ,p_attribute10                   	=> p_attribute10
  ,p_attribute11                  	=> p_attribute11
  ,p_attribute12                   	=> p_attribute12
  ,p_attribute13                 	=> p_attribute13
  ,p_attribute14                  	=> p_attribute14
  ,p_attribute15                   	=> p_attribute15
  ,p_attribute16                  	=> p_attribute16
  ,p_attribute17                 	=> p_attribute17
  ,p_attribute18                  	=> p_attribute18
  ,p_attribute19                   	=> p_attribute19
  ,p_attribute20                	=> p_attribute20
  ,p_effective_date		 	=> p_effective_date
  ,p_validate                      	=> p_validate
  ,p_party_id                           => p_party_id
  ,p_qualification_type_id              => p_qualification_type_id
  ,p_unit_standard_type                 => p_unit_standard_type
  ,p_status                             => p_status
  ,p_information_category               => p_information_category
  ,p_information1                       => p_information1
  ,p_information2                       => p_information2
  ,p_information3                       => p_information3
  ,p_information4                       => p_information4
  ,p_information5                       => p_information5
  ,p_information6                       => p_information6
  ,p_information7                       => p_information7
  ,p_information8                       => p_information8
  ,p_information9                       => p_information9
  ,p_information10                      => p_information10
  ,p_information11                      => p_information11
  ,p_information12                      => p_information12
  ,p_information13                      => p_information13
  ,p_information14                      => p_information14
  ,p_information15                      => p_information15
  ,p_information16                      => p_information16
  ,p_information17                      => p_information17
  ,p_information18                      => p_information18
  ,p_information19                      => p_information19
  ,p_information20                      => p_information20
  ,p_achieved_date                      => p_achieved_date
  ,p_appr_line_score	                => p_appr_line_score
  );
  --
  --
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_competence_element_bk2.update_competence_element_a	(
        p_competence_element_id         	=> p_competence_element_id
       ,p_object_version_number 	       	=> l_object_version_number
       ,p_proficiency_level_id          	=> p_proficiency_level_id
       ,p_high_proficiency_level_id     	=> p_high_proficiency_level_id
       ,p_weighting_level_id           		=> p_weighting_level_id
       ,p_rating_level_id             		=> p_rating_level_id
       ,p_mandatory            			=> p_mandatory
       ,p_effective_date_from          		=> p_effective_date_from
       ,p_effective_date_to           		=> p_effective_date_to
       ,p_group_competence_type         	=> p_group_competence_type
       ,p_competence_type               	=> p_competence_type
       ,p_normal_elapse_duration        	=> p_normal_elapse_duration
       ,p_normal_elapse_duration_unit   	=> p_normal_elapse_duration_unit
       ,p_sequence_number               	=> p_sequence_number
       ,p_source_of_proficiency_level   	=> p_source_of_proficiency_level
       ,p_line_score                    	=> p_line_score
       ,p_certification_date            	=> p_certification_date
       ,p_certification_method          	=> p_certification_method
       ,p_next_certification_date       	=> p_next_certification_date
       ,p_comments                      	=> p_comments
       ,p_attribute_category            	=> p_attribute_category
       ,p_attribute1                    	=> p_attribute1
       ,p_attribute2                   		=> p_attribute2
       ,p_attribute3                 		=> p_attribute3
       ,p_attribute4                    	=> p_attribute4
       ,p_attribute5                    	=> p_attribute5
       ,p_attribute6                    	=> p_attribute6
       ,p_attribute7                   	 	=> p_attribute7
       ,p_attribute8                   		=> p_attribute8
       ,p_attribute9                    	=> p_attribute9
       ,p_attribute10                   	=> p_attribute10
       ,p_attribute11                  		=> p_attribute11
       ,p_attribute12                   	=> p_attribute12
       ,p_attribute13                 		=> p_attribute13
       ,p_attribute14                  		=> p_attribute14
       ,p_attribute15                   	=> p_attribute15
       ,p_attribute16                  		=> p_attribute16
       ,p_attribute17                  		=> p_attribute17
       ,p_attribute18                  		=> p_attribute18
       ,p_attribute19                   	=> p_attribute19
       ,p_attribute20                		=> p_attribute20
       ,p_effective_date		 	=> p_effective_date
       ,p_qualification_type_id                 => p_qualification_type_id
       ,p_unit_standard_type                    => p_unit_standard_type
       ,p_status                                => p_status
       ,p_information_category                  => p_information_category
       ,p_information1                          => p_information1
       ,p_information2                          => p_information2
       ,p_information3                          => p_information3
       ,p_information4                          => p_information4
       ,p_information5                          => p_information5
       ,p_information6                          => p_information6
       ,p_information7                          => p_information7
       ,p_information8                          => p_information8
       ,p_information9                          => p_information9
       ,p_information10                         => p_information10
       ,p_information11                         => p_information11
       ,p_information12                         => p_information12
       ,p_information13                         => p_information13
       ,p_information14                         => p_information14
       ,p_information15                         => p_information15
       ,p_information16                         => p_information16
       ,p_information17                         => p_information17
       ,p_information18                         => p_information18
       ,p_information19                         => p_information19
       ,p_information20                         => p_information20
       ,p_achieved_date                         => p_achieved_date
       ,p_appr_line_score	                => p_appr_line_score
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_competence_element',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End After Process User Hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_competence_element;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    p_object_version_number  := lv_object_version_number;

    ROLLBACK TO update_competence_element;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
--
end update_competence_element;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <update_competence_element> >--------------------|
-- ---------------------------------------------------------------------------
-- |-- This is overload update_competence_element without party_id          --|
-- ---------------------------------------------------------------------------
--
procedure update_competence_element
  (
  p_competence_element_id        in number,
  p_object_version_number        in out nocopy number,
  p_proficiency_level_id         in number           default hr_api.g_number,
  p_high_proficiency_level_id    in number           default hr_api.g_number,
  p_weighting_level_id           in number           default hr_api.g_number,
  p_rating_level_id              in number           default hr_api.g_number,
  p_mandatory           	 in varchar2         default hr_api.g_varchar2,
  p_effective_date_from          in date             default hr_api.g_date,
  p_effective_date_to            in date             default hr_api.g_date,
  p_group_competence_type        in varchar2         default hr_api.g_varchar2,
  p_competence_type              in varchar2         default hr_api.g_varchar2,
  p_normal_elapse_duration       in number           default hr_api.g_number,
  p_normal_elapse_duration_unit  in varchar2         default hr_api.g_varchar2,
  p_sequence_number              in number           default hr_api.g_number,
  p_source_of_proficiency_level  in varchar2         default hr_api.g_varchar2,
  p_line_score                   in number           default hr_api.g_number,
  p_certification_date           in date             default hr_api.g_date,
  p_certification_method         in varchar2         default hr_api.g_varchar2,
  p_next_certification_date      in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_effective_date		 in Date,
  p_validate                     in boolean    	     default false
  ) is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc                	varchar2(72) := g_package||'update_competence_element';
  l_party_id			per_competence_elements.party_id%type;
  --
  cursor csr_get_party_id is
  select party_id
  from per_competence_elements
  where competence_element_id = p_competence_element_id;
  --

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- get party_id from per_competence_elements using competence_element_id
  --
  open csr_get_party_id;
  fetch csr_get_party_id into l_party_id;
  close csr_get_party_id;
  hr_utility.set_location(l_proc, 20);
  --
  --
  --
  update_competence_element
          ( p_competence_element_id        => p_competence_element_id
          , p_object_version_number        => p_object_version_number
          , p_proficiency_level_id         => p_proficiency_level_id
          , p_high_proficiency_level_id    => p_high_proficiency_level_id
          , p_weighting_level_id           => p_weighting_level_id
          , p_rating_level_id              => p_rating_level_id
          , p_mandatory                    => p_mandatory
          , p_effective_date_from          => p_effective_date_from
          , p_effective_date_to            => p_effective_date_to
          , p_group_competence_type        => p_group_competence_type
          , p_competence_type              => p_competence_type
          , p_normal_elapse_duration       => p_normal_elapse_duration
          , p_normal_elapse_duration_unit  => p_normal_elapse_duration_unit
          , p_sequence_number              => p_sequence_number
          , p_source_of_proficiency_level  => p_source_of_proficiency_level
          , p_line_score                   => p_line_score
          , p_certification_date           => p_certification_date
          , p_certification_method         => p_certification_method
          , p_next_certification_date      => p_next_certification_date
          , p_comments                     => p_comments
          , p_attribute_category           => p_attribute_category
          , p_attribute1                   => p_attribute1
          , p_attribute2                   => p_attribute2
          , p_attribute3                   => p_attribute3
          , p_attribute4                   => p_attribute4
          , p_attribute5                   => p_attribute5
          , p_attribute6                   => p_attribute6
          , p_attribute7                   => p_attribute7
          , p_attribute8                   => p_attribute8
          , p_attribute9                   => p_attribute9
          , p_attribute10                  => p_attribute10
          , p_attribute11                  => p_attribute11
          , p_attribute12                  => p_attribute12
          , p_attribute13                  => p_attribute13
          , p_attribute14                  => p_attribute14
          , p_attribute15                  => p_attribute15
          , p_attribute16                  => p_attribute16
          , p_attribute17                  => p_attribute17
          , p_attribute18                  => p_attribute18
          , p_attribute19                  => p_attribute19
          , p_attribute20                  => p_attribute20
          , p_effective_date               => p_effective_date
          , p_validate                     => p_validate
          , p_party_id                     => l_party_id
          );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
--
end update_competence_element;

-- ---------------------------------------------------------------------------
-- |-------------------< <update_personal_comp_element> >--------------------|
-- ---------------------------------------------------------------------------
--
procedure update_personal_comp_element
  (
  p_competence_element_id        in number,
  p_object_version_number        in out nocopy number,
  p_proficiency_level_id         in number           default hr_api.g_number,
  p_effective_date_from          in date             default hr_api.g_date,
  p_effective_date_to            in date             default hr_api.g_date,
  p_source_of_proficiency_level  in varchar2         default hr_api.g_varchar2,
  p_certification_date           in date             default hr_api.g_date,
  p_certification_method         in varchar2         default hr_api.g_varchar2,
  p_next_certification_date      in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_effective_date		 in Date,
  p_validate                     in boolean          default false ,
  p_ins_ovn			 out nocopy number,
  p_ins_comp_id			 out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc                	varchar2(72) := g_package||'update_Personal_comp_element';
  l_object_version_number	per_competence_elements.object_version_number%TYPE;
  l_ins_ovn			per_competence_elements.object_version_number%TYPE;
  l_ins_comp_id			number(9);
  l_competence_id		number(9);
  l_business_group_id		number(9);
  l_person_id		        per_competence_elements.person_id%TYPE;
  l_party_id		        per_competence_elements.party_id%TYPE;-- HR/TCA merg
  l_type			per_competence_elements.type%TYPE;
  l_effective_date_from		date;
  l_effective_date_to		date;
  l_upd_date_from		date := p_effective_date_from;
  l_upd_date_to			date := p_effective_date_to;
  l_proficiency_level_id	number(9);
  l_certification_date		date;
  l_source_of_proficiency_level varchar2(80);
  l_certification_method	varchar2(80);
  l_next_certification_date	date;
  l_comments			varchar2(2000);
  l_attribute_category		varchar2(80);
  l_attribute1			varchar2(150);
  l_attribute2			varchar2(150);
  l_attribute3			varchar2(150);
  l_attribute4			varchar2(150);
  l_attribute5			varchar2(150);
  l_attribute6			varchar2(150);
  l_attribute7			varchar2(150);
  l_attribute8			varchar2(150);
  l_attribute9			varchar2(150);
  l_attribute10			varchar2(150);
  l_attribute11			varchar2(150);
  l_attribute12			varchar2(150);
  l_attribute13			varchar2(150);
  l_attribute14			varchar2(150);
  l_attribute15			varchar2(150);
  l_attribute16			varchar2(150);
  l_attribute17			varchar2(150);
  l_attribute18			varchar2(150);
  l_attribute19			varchar2(150);
  l_attribute20			varchar2(150);
  l_insert			boolean := false;
  --
  lv_object_version_number       number := p_object_version_number ;
  --
  -- cusror to get the type and effective_date_from of the competence_element.
  --
  cursor csr_comp_element is
  select
	type,
	business_group_id,
	competence_id,
	proficiency_level_id,
	person_id,
	party_id,  -- HR/TCA merge
	effective_date_from,
	effective_date_to,
	source_of_proficiency_level,
	certification_date,
	certification_method,
	next_certification_date,
	comments,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20
  from  per_competence_elements
  where competence_element_id = p_competence_element_id
  and   object_version_number = p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_competence_element;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_competence_element_bk3.update_personal_comp_element_b
	(
        p_competence_element_id        =>  p_competence_element_id,
        p_object_version_number        =>  p_object_version_number,
        p_proficiency_level_id         =>  p_proficiency_level_id ,
        p_effective_date_from          =>  p_effective_date_from  ,
        p_effective_date_to            =>  p_effective_date_to    ,
        p_source_of_proficiency_level  =>  p_source_of_proficiency_level,
        p_certification_date           =>  p_certification_date   ,
        p_certification_method         =>  p_certification_method ,
        p_next_certification_date      =>  p_next_certification_date,
        p_comments                     =>  p_comments   ,
        p_attribute_category           =>  p_attribute_category,
        p_attribute1                   =>  p_attribute1 ,
        p_attribute2                   =>  p_attribute2 ,
        p_attribute3                   =>  p_attribute3 ,
        p_attribute4                   =>  p_attribute4 ,
        p_attribute5                   =>  p_attribute5 ,
        p_attribute6                   =>  p_attribute6 ,
        p_attribute7                   =>  p_attribute7 ,
        p_attribute8                   =>  p_attribute8 ,
        p_attribute9                   =>  p_attribute9 ,
        p_attribute10                  =>  p_attribute10,
        p_attribute11                  =>  p_attribute11,
        p_attribute12                  =>  p_attribute12,
        p_attribute13                  =>  p_attribute13,
        p_attribute14                  =>  p_attribute14,
        p_attribute15                  =>  p_attribute15,
        p_attribute16                  =>  p_attribute16,
        p_attribute17                  =>  p_attribute17,
        p_attribute18                  =>  p_attribute18,
        p_attribute19                  =>  p_attribute19,
        p_attribute20                  =>  p_attribute20,
        p_effective_date               =>  p_effective_date
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_personal_comp_element',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User hook
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- only do the following logic if the effective_date_from is entered.
  --
  if (p_effective_date_from is not null) then
  --
  --
  -- This is the logic to make the changes to competence element of type personal
  -- to be date tracked.
  --
  open csr_comp_element;
  fetch csr_comp_element into
	l_type,
	l_business_group_id,
	l_competence_id,
	l_proficiency_level_id,
	l_person_id,
	l_party_id, -- HR/TCA merge
	l_effective_date_from,
	l_effective_date_to,
	l_source_of_proficiency_level,
	l_certification_date,
	l_certification_method,
	l_next_certification_date,
	l_comments,
	l_attribute_category,
	l_attribute1,
	l_attribute2,
	l_attribute3,
	l_attribute4,
	l_attribute5,
	l_attribute6,
	l_attribute7,
	l_attribute8,
	l_attribute9,
	l_attribute10,
	l_attribute11,
	l_attribute12,
	l_attribute13,
	l_attribute14,
	l_attribute15,
	l_attribute16,
	l_attribute17,
	l_attribute18,
	l_attribute19,
	l_attribute20;
  if csr_comp_element%notfound then
     hr_utility.set_location(l_proc, 8);
     close csr_comp_element;
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  elsif (l_type <> 'PERSONAL') then
     hr_utility.set_location(l_proc, 9);
     hr_utility.set_message(801, 'HR_51866_CEL_INV_COMP_TYPE');
     hr_utility.raise_error;
  elsif (
	 l_effective_date_from <> p_effective_date_from and
	 ((l_proficiency_level_id is not null
	  and p_proficiency_level_id is null) OR (l_proficiency_level_id is null and
	  p_proficiency_level_id is not null) OR ( l_proficiency_level_id <>
	  p_proficiency_level_id))) then
	  --
	  --
          l_insert := true;
	  --
     if (p_effective_date_from > l_effective_date_from ) then
	--
	-- this means that the proficiency_level has changed so is the date_from.
	-- We need to update the row with the previous proficiency_level and the
	-- date_to being one day less than the p_effective_date_from.
	--
	l_effective_date_to := p_effective_date_from -1;
	   --
        if (p_effective_date_to is not null ) then
	   --
	   -- the effective_date_to is also changed.
	   --
           hr_utility.set_location(l_proc, 15);
	   l_upd_date_to := p_effective_date_to;
	   --
	end if;
      --
      elsif (p_effective_date_from < l_effective_date_from) then
	    --
	  if (p_effective_date_to is not null and
	      p_effective_date_to > l_effective_date_from) then
	      --
              hr_utility.set_location(l_proc, 20);
              hr_utility.set_message(801, 'HR_51867_CEL_DATE_OVERLAP');
              hr_utility.raise_error;
	  elsif(p_effective_date_to is null) then
	      --
              hr_utility.set_location(l_proc, 25);
	      l_upd_date_to := l_effective_date_from -1;
	      --
    	  end if;
      --
      end if;
      --
   end if;
   close csr_comp_element;
end if; -- The p_effective_date_from is not null

  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  per_cel_upd.upd (
  p_competence_element_id         	=> p_competence_element_id
  ,p_object_version_number        	=> p_object_version_number
  ,p_proficiency_level_id          	=> p_proficiency_level_id
  ,p_effective_date_from          	=> p_effective_date_from
  ,p_effective_date_to           	=> l_upd_date_to
  ,p_source_of_proficiency_level   	=> p_source_of_proficiency_level
  ,p_certification_date            	=> p_certification_date
  ,p_certification_method          	=> p_certification_method
  ,p_next_certification_date       	=> p_next_certification_date
  ,p_comments                      	=> p_comments
  ,p_attribute_category            	=> p_attribute_category
  ,p_attribute1                    	=> p_attribute1
  ,p_attribute2                   	=> p_attribute2
  ,p_attribute3                 	=> p_attribute3
  ,p_attribute4                    	=> p_attribute4
  ,p_attribute5                    	=> p_attribute5
  ,p_attribute6                    	=> p_attribute6
  ,p_attribute7                    	=> p_attribute7
  ,p_attribute8                   	=> p_attribute8
  ,p_attribute9                    	=> p_attribute9
  ,p_attribute10                   	=> p_attribute10
  ,p_attribute11                  	=> p_attribute11
  ,p_attribute12                   	=> p_attribute12
  ,p_attribute13                 	=> p_attribute13
  ,p_attribute14                  	=> p_attribute14
  ,p_attribute15                   	=> p_attribute15
  ,p_attribute16                  	=> p_attribute16
  ,p_attribute17              	=> p_attribute17
  ,p_attribute18                  	=> p_attribute18
  ,p_attribute19                   	=> p_attribute19
  ,p_attribute20                	=> p_attribute20
  ,p_effective_date		 	=> p_effective_date
  ,p_validate                      	=> p_validate
  );
  --
  --
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Now, insert a row if necessary.
  --
  if (l_insert) then
    hr_utility.set_location ('bus_id*** ' || to_char(l_business_group_id), 31);
    hr_utility.set_location ('type ***' || l_type, 32);
    hr_utility.set_location ('person **' || to_char(l_person_id),33);
    hr_utility.set_location ('date_from**' || to_char(l_effective_date_from),34);
    per_cel_ins.ins (
    p_competence_element_id         	=> l_ins_comp_id
    ,p_object_version_number        	=> l_ins_ovn
    ,p_business_group_id		=> l_business_group_id
    ,p_type				=> l_type
    ,p_competence_id			=> l_competence_id
    ,p_person_id			=> l_person_id
    ,p_proficiency_level_id          	=> l_proficiency_level_id
    ,p_effective_date_from          	=> l_effective_date_from
    ,p_effective_date_to           	=> l_effective_date_to
    ,p_source_of_proficiency_level   	=> l_source_of_proficiency_level
    ,p_certification_date            	=> l_certification_date
    ,p_certification_method          	=> l_certification_method
    ,p_next_certification_date       	=> l_next_certification_date
    ,p_comments                      	=> l_comments
    ,p_attribute_category            	=> l_attribute_category
    ,p_attribute1                    	=> l_attribute1
    ,p_attribute2                   	=> l_attribute2
    ,p_attribute3                 	=> l_attribute3
    ,p_attribute4                    	=> l_attribute4
    ,p_attribute5                    	=> l_attribute5
    ,p_attribute6                    	=> l_attribute6
    ,p_attribute7                    	=> l_attribute7
    ,p_attribute8                   	=> l_attribute8
    ,p_attribute9                    	=> l_attribute9
    ,p_attribute10                   	=> l_attribute10
    ,p_attribute11                  	=> l_attribute11
    ,p_attribute12                   	=> l_attribute12
    ,p_attribute13                 	=> l_attribute13
    ,p_attribute14                  	=> l_attribute14
    ,p_attribute15                   	=> l_attribute15
    ,p_attribute16                  	=> l_attribute16
    ,p_attribute17             		=> l_attribute17
    ,p_attribute18                  	=> l_attribute18
    ,p_attribute19                   	=> l_attribute19
    ,p_attribute20                	=> l_attribute20
    ,p_effective_date		 	=> p_effective_date
    ,p_validate                      	=> p_validate
    ,p_party_id			=> l_party_id  -- HR/TCA merge
    );
    --
    hr_utility.set_location(l_proc, 35);
    --
  end if;
  --
  -- Call After Process User Hook
  --
  begin
	hr_competence_element_bk3.update_personal_comp_element_a
	(
        p_competence_element_id        =>  p_competence_element_id,
        p_object_version_number        =>  p_object_version_number,
        p_proficiency_level_id         =>  p_proficiency_level_id ,
        p_effective_date_from          =>  p_effective_date_from  ,
        p_effective_date_to            =>  p_effective_date_to    ,
        p_source_of_proficiency_level  =>  p_source_of_proficiency_level,
        p_certification_date           =>  p_certification_date   ,
        p_certification_method         =>  p_certification_method ,
        p_next_certification_date      =>  p_next_certification_date,
        p_comments                     =>  p_comments   ,
        p_attribute_category           =>  p_attribute_category,
        p_attribute1                   =>  p_attribute1 ,
        p_attribute2                   =>  p_attribute2 ,
        p_attribute3                   =>  p_attribute3 ,
        p_attribute4                   =>  p_attribute4 ,
        p_attribute5                   =>  p_attribute5 ,
        p_attribute6                   =>  p_attribute6 ,
        p_attribute7                   =>  p_attribute7 ,
        p_attribute8                   =>  p_attribute8 ,
        p_attribute9                   =>  p_attribute9 ,
        p_attribute10                  =>  p_attribute10,
        p_attribute11                  =>  p_attribute11,
        p_attribute12                  =>  p_attribute12,
        p_attribute13                  =>  p_attribute13,
        p_attribute14                  =>  p_attribute14,
        p_attribute15                  =>  p_attribute15,
        p_attribute16                  =>  p_attribute16,
        p_attribute17                  =>  p_attribute17,
        p_attribute18                  =>  p_attribute18,
        p_attribute19                  =>  p_attribute19,
        p_attribute20                  =>  p_attribute20,
        p_effective_date               =>  p_effective_date,
        p_ins_ovn                      =>  l_ins_ovn,
        p_ins_comp_id                  =>  l_ins_comp_id
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_personal_comp_element',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_competence_element;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_ins_ovn		     := null;
    p_ins_comp_id	     := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    p_object_version_number  := lv_object_version_number;

    p_ins_ovn		     := null;
    p_ins_comp_id	     := null;
    --
    ROLLBACK TO update_competence_element;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 45);
--
end update_personal_comp_element;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <delete_competence_element> >--------------------|
-- ---------------------------------------------------------------------------
--
procedure delete_competence_element
(p_validate                           in boolean default FALSE,
 p_competence_element_id              in number,
 p_object_version_number              in number
) is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc                varchar2(72) := g_package||'delete_competence_element';
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint delete_competence_element;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_competence_element_bk4.delete_competence_element_b
		(
		p_competence_element_id       =>   p_competence_element_id,
		p_object_version_number       =>   p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_competence_element',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User hook
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  --
  -- now delete the competence itself
  --
     per_cel_del.del
     (p_validate                    => FALSE
     ,p_competence_element_id		=> p_competence_element_id
     ,p_object_version_number 	=> p_object_version_number
     );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_competence_element_bk4.delete_competence_element_a	(
		p_competence_element_id       =>   p_competence_element_id,
		p_object_version_number       =>   p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_competence_element',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User hook
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
    ROLLBACK TO delete_competence_element;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO delete_competence_element;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_competence_element;
--
-- ---------------------------------------------------------------------------
-- |--------------------< <maintain_student_comp_element> >------------------|
-- ---------------------------------------------------------------------------
--
-- maintain_student_comp_element
-- Called from Student Enrollment Form - maintains a students competence profile
--
procedure maintain_student_comp_element
(p_person_id                          in number
,p_competence_id                      in number
,p_proficiency_level_id               in number
,p_business_group_id                  in number
,p_effective_date_from                in date
,p_effective_date_to                  in date
,p_certification_date                 in date
,p_certification_method               in varchar2
,p_next_certification_date            in date
,p_source_of_proficiency_level        in varchar2
,p_comments                           in varchar2
,p_effective_date                     in date
,p_validate                           in boolean default FALSE
,p_competence_created                 out nocopy number) is
--
l_new_competence_element_id number;
l_new_object_version_number number;
l_new_effective_date_from date default null;
l_competence_element_id number;
l_object_version_number number;
l_proficiency_level_id number;
l_effective_date_from   date;
l_effective_date_to   date;                     -- added for bug#1623036
--
cursor c_get_comp_element is
select competence_element_id
,      object_version_number
,      proficiency_level_id
,      effective_date_from
,      effective_date_to                        -- added for bug#1623036
from   per_competence_elements
where  person_id = p_person_id
and    type = 'PERSONAL'
and    competence_id = p_competence_id
order by effective_date_from desc;

Cursor csr_chk_date_overlap is
select competence_element_id
,      object_version_number
,      proficiency_level_id
,      effective_date_from
,      effective_date_to
from   per_competence_elements
where  person_id = p_person_id
and    type = 'PERSONAL'
and    competence_id = p_competence_id
and
p_effective_date_from between effective_date_from and Nvl(effective_Date_to,p_effective_date_from) ;

-- get from_date nearest to new record from_date
cursor c_get_nearest_from_date is
select competence_element_id
,      object_version_number
,      proficiency_level_id
,      effective_date_from
,      effective_date_to                        -- added for bug#1623036
from   per_competence_elements
where  person_id = p_person_id
and    type = 'PERSONAL'
and    competence_id = p_competence_id
and
p_effective_date_from < effective_date_from
order by effective_date_from asc;
--
begin
--
   -- Determine if there is an existing competence element
   --
   --
   -- Issue a savepoint.
   --
   savepoint maintain_student_comp_element;
   --
   -- Call Before Process User Hook
   --
   begin
	hr_competence_element_bk5.maintain_student_comp_elemen_b	(
       p_person_id                   => p_person_id
      ,p_business_group_id           => p_business_group_id
      ,p_competence_id               => p_competence_id
      ,p_proficiency_level_id        => p_proficiency_level_id
      ,p_effective_date_from         => p_effective_date_from
      ,p_effective_date_to           => p_effective_date_to
      ,p_certification_date          => p_certification_date
      ,p_certification_method        => p_certification_method
      ,p_next_certification_date     => p_next_certification_date
      ,p_source_of_proficiency_level => p_source_of_proficiency_level
      ,p_comments                    => p_comments
      ,p_effective_date              => p_effective_date
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'maintain_student_comp_element',
				 p_hook_type	=> 'BP'
				);
   end;
   --
   -- End of Before Process User hook
   --
   open c_get_comp_element;
   fetch c_get_comp_element into l_competence_element_id,
                                 l_object_version_number,
                                 l_proficiency_level_id,
                                 l_effective_date_from,
                                 l_effective_date_to;  -- added for bug#1623036

   close c_get_comp_element;
   --
   p_competence_created := 0;
   --
   if l_competence_element_id is null then
      create_competence_element
      (p_competence_element_id       => l_new_competence_element_id
      ,p_object_version_number       => l_new_object_version_number
      ,p_type                        => 'PERSONAL'
      ,p_person_id                   => p_person_id
      ,p_business_group_id           => p_business_group_id
      ,p_competence_id               => p_competence_id
      ,p_proficiency_level_id        => p_proficiency_level_id
      ,p_effective_date_from         => p_effective_date_from
      ,p_effective_date_to           => p_effective_date_to
      ,p_certification_date          => p_certification_date
      ,p_certification_method        => p_certification_method
      ,p_next_certification_date     => p_next_certification_date
      ,p_source_of_proficiency_level => p_source_of_proficiency_level
      ,p_comments                    => p_comments
      ,p_effective_date              => p_effective_date);
      --
      p_competence_created := 1;
--
   else
   /********* NEW Logic***********8888*/
   if p_effective_date_from < l_effective_date_from then
   -- implies new record from date is less than the max(from date) of existing record.
   -- First check whether p_eff_date_from lies between some already existing record dates
    open csr_chk_date_overlap;
     fetch csr_chk_date_overlap into l_competence_element_id,
                                 l_object_version_number,
                                 l_proficiency_level_id,
                                 l_effective_date_from,
                                 l_effective_date_to;


      --Dbms_output.put_line('UPD : Date already exists');
      -- If the New E.F.Date is between the existing From and To date then simply overwrite the level.
     /*   l_object_version_number := l_new_object_version_number ;
        l_competence_element_id := l_new_competence_element_id ;

       l_effective_Date_to := l_new_effective_date_to ;*/
   If csr_chk_date_overlap%NotFound then
   -- since p_eff_date_from doesn't lie between already existing record dates
   -- get the record whose l_effective_from_date is just greater than p_effective_from_date

    open c_get_nearest_from_date;
     fetch c_get_nearest_from_date into l_competence_element_id,
                                 l_object_version_number,
                                 l_proficiency_level_id,
                                 l_effective_date_from,
                                 l_effective_date_to;

     Close c_get_nearest_from_date;

   end if; --- csr_chk_date_overlap%Found

   close csr_chk_date_overlap;
end if; ---p_effective_date_from < l_effective_date_from


    if nvl(l_proficiency_level_id, -1) = nvl(p_proficiency_level_id, -1) then

           if l_effective_date_from > p_effective_date_from then
                l_new_effective_date_from := p_effective_date_from;
            else
                l_new_effective_date_from := l_effective_date_from;
            end if;
   elsif nvl(l_proficiency_level_id, -1) < nvl(p_proficiency_level_id, -1) then

            l_new_effective_date_from := p_effective_date_from;
    Else
--
--         start modifications for bg #1623036
--
     /* if l_effective_date_from > p_effective_date_from then
         l_new_effective_date_from := l_effective_date_from;
      else*/
         l_new_effective_date_from := p_effective_date_from;
     -- end if;

    end if;
    if nvl(l_proficiency_level_id, -1) > nvl(p_proficiency_level_id, -1) then
-- new record has level lesser then  existing record

--
       --Bug 2366782
         if l_effective_date_to is null OR l_effective_date_to >= p_effective_date_from then

          /********* NEW Logic***********8888*/

          if (l_effective_date_from < p_effective_date_from) then
            if ((l_effective_date_to is null or l_effective_date_to>= nvl(p_effective_date_to,hr_api.g_eot))) then
            -- new record lies within span of existing record
            null;

            elsif (l_effective_date_to is not null and l_effective_date_to < nvl(p_effective_date_to,hr_api.g_eot) ) then
              /*update_personal_comp_element
                   (p_competence_element_id       => l_competence_element_id
                   ,p_object_version_number       => l_object_version_number
                   ,p_proficiency_level_id        => l_proficiency_level_id
                   ,p_effective_date_from         => l_effective_date_from
                   ,p_effective_date_to           => p_effective_date_from -1
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date
                   ,p_ins_ovn                     => l_new_object_version_number
                   ,p_ins_comp_id                 => l_new_competence_element_id);*/


              create_competence_element
                   (p_competence_element_id       => l_new_competence_element_id
                   ,p_object_version_number       => l_new_object_version_number
                   ,p_type                        => 'PERSONAL'
                   ,p_person_id                   => p_person_id
                   ,p_business_group_id           => p_business_group_id
                   ,p_competence_id               => p_competence_id
                   ,p_proficiency_level_id        => p_proficiency_level_id
                   ,p_effective_date_from         => l_effective_date_to+1
                   ,p_effective_date_to           => p_effective_date_to
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date);

--
               p_competence_created := 1;
             end if;
          else -- for (l_effective_date_from < p_effective_date_from)
              --if nvl(l_proficiency_level_id, -1) < nvl(p_proficiency_level_id, -1) then
               -- implies new record has level lesser then existing level but it's start date
               -- is also lesser than exisitng record date

               create_competence_element
                   (p_competence_element_id       => l_new_competence_element_id
                   ,p_object_version_number       => l_new_object_version_number
                   ,p_type                        => 'PERSONAL'
                   ,p_person_id                   => p_person_id
                   ,p_business_group_id           => p_business_group_id
                   ,p_competence_id               => p_competence_id
                   ,p_proficiency_level_id        => p_proficiency_level_id
                   ,p_effective_date_from         => p_effective_date_from
                   ,p_effective_date_to           => l_effective_date_from -1
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date);

                   if (nvl(l_effective_date_to,hr_api.g_eot) < nvl(p_effective_date_to,hr_api.g_eot)) then
                   create_competence_element
                   (p_competence_element_id       => l_new_competence_element_id
                   ,p_object_version_number       => l_new_object_version_number
                   ,p_type                        => 'PERSONAL'
                   ,p_person_id                   => p_person_id
                   ,p_business_group_id           => p_business_group_id
                   ,p_competence_id               => p_competence_id
                   ,p_proficiency_level_id        => p_proficiency_level_id
                   ,p_effective_date_from         => l_effective_date_to+1
                   ,p_effective_date_to           => p_effective_date_to
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date);


                    end if;
                p_competence_created := 1;
              end if;
         elsif l_effective_date_to is not null and p_effective_date_from >= l_effective_date_to then
                create_competence_element
                   (p_competence_element_id       => l_new_competence_element_id
                   ,p_object_version_number       => l_new_object_version_number
                   ,p_type                        => 'PERSONAL'
                   ,p_person_id                   => p_person_id
                   ,p_business_group_id           => p_business_group_id
                   ,p_competence_id               => p_competence_id
                   ,p_proficiency_level_id        => p_proficiency_level_id
                   ,p_effective_date_from         => l_new_effective_date_from
                   ,p_effective_date_to           => p_effective_date_to
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date);

--
               p_competence_created := 1;

         else
              create_competence_element
                   (p_competence_element_id       => l_new_competence_element_id
                   ,p_object_version_number       => l_new_object_version_number
                   ,p_type                        => 'PERSONAL'
                   ,p_person_id                   => p_person_id
                   ,p_business_group_id           => p_business_group_id
                   ,p_competence_id               => p_competence_id
                   ,p_proficiency_level_id        => p_proficiency_level_id
                   ,p_effective_date_from         => l_new_effective_date_from
                   ,p_effective_date_to           => p_effective_date_to
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date);
               p_competence_created := 1;

         end if;

--
      elsif nvl(l_proficiency_level_id, -1) < nvl(p_proficiency_level_id, -1) then
--
       --Bug 2366782
         if l_effective_date_to is null OR l_effective_date_to >= p_effective_date_from then

          /********* NEW Logic***********8888*/
            if l_effective_date_from < p_effective_date_from then
              update_personal_comp_element
                   (p_competence_element_id       => l_competence_element_id
                   ,p_object_version_number       => l_object_version_number
                   ,p_proficiency_level_id        => l_proficiency_level_id
                   ,p_effective_date_from         => l_effective_date_from
                   ,p_effective_date_to           => p_effective_date_from -1
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date
                   ,p_ins_ovn                     => l_new_object_version_number
                   ,p_ins_comp_id                 => l_new_competence_element_id);


              create_competence_element
                   (p_competence_element_id       => l_new_competence_element_id
                   ,p_object_version_number       => l_new_object_version_number
                   ,p_type                        => 'PERSONAL'
                   ,p_person_id                   => p_person_id
                   ,p_business_group_id           => p_business_group_id
                   ,p_competence_id               => p_competence_id
                   ,p_proficiency_level_id        => p_proficiency_level_id
                   ,p_effective_date_from         => l_new_effective_date_from
                   ,p_effective_date_to           => p_effective_date_to
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date);

                   if (p_effective_date_to is not null and nvl(l_effective_date_to,hr_api.g_eot)> p_effective_date_to) then

                    create_competence_element
                   (p_competence_element_id       => l_new_competence_element_id
                   ,p_object_version_number       => l_new_object_version_number
                   ,p_type                        => 'PERSONAL'
                   ,p_person_id                   => p_person_id
                   ,p_business_group_id           => p_business_group_id
                   ,p_competence_id               => p_competence_id
                   ,p_proficiency_level_id        => l_proficiency_level_id
                   ,p_effective_date_from         => p_effective_date_to+1
                   ,p_effective_date_to           => l_effective_date_to
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date);

                   end if;
--
               p_competence_created := 2;
              else
               --if nvl(l_proficiency_level_id, -1) < nvl(p_proficiency_level_id, -1) then
               -- implies new record has level greater then existing level but it's start date
               -- is less than exisitng record date
               -- update the exisitng record to new level and new start date
               if (p_effective_date_to is null) then
               --implies new record covers entire span of existing record
               delete_competence_element
                (p_validate      => p_validate,
                    p_competence_element_id       => l_competence_element_id
                   ,p_object_version_number       => l_object_version_number
                );
               create_competence_element
                   (p_competence_element_id       => l_new_competence_element_id
                   ,p_object_version_number       => l_new_object_version_number
                   ,p_type                        => 'PERSONAL'
                   ,p_person_id                   => p_person_id
                   ,p_business_group_id           => p_business_group_id
                   ,p_competence_id               => p_competence_id
                   ,p_proficiency_level_id        => p_proficiency_level_id
                   ,p_effective_date_from         => p_effective_date_from
                   ,p_effective_date_to           => p_effective_date_to
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date);

               elsif (p_effective_date_to is not null and p_effective_date_to < nvl(l_effective_date_to,hr_api.g_eot)) then
               -- new record has an end date less than existing record
                    update_personal_comp_element
                   (p_competence_element_id       => l_competence_element_id
                   ,p_object_version_number       => l_object_version_number
                   ,p_proficiency_level_id        => l_proficiency_level_id
                   ,p_effective_date_from         => p_effective_date_to+1
                   ,p_effective_date_to           => l_effective_date_to
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date
                   ,p_ins_ovn                     => l_new_object_version_number
                   ,p_ins_comp_id                 => l_new_competence_element_id);

                   create_competence_element
                   (p_competence_element_id       => l_new_competence_element_id
                   ,p_object_version_number       => l_new_object_version_number
                   ,p_type                        => 'PERSONAL'
                   ,p_person_id                   => p_person_id
                   ,p_business_group_id           => p_business_group_id
                   ,p_competence_id               => p_competence_id
                   ,p_proficiency_level_id        => p_proficiency_level_id
                   ,p_effective_date_from         => p_effective_date_from
                   ,p_effective_date_to           => p_effective_date_to
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date);

               else
                update_personal_comp_element
                   (p_competence_element_id       => l_competence_element_id
                   ,p_object_version_number       => l_object_version_number
                   ,p_proficiency_level_id        => p_proficiency_level_id
                   ,p_effective_date_from         => l_new_effective_date_from
                   ,p_effective_date_to           => p_effective_date_to
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date
                   ,p_ins_ovn                     => l_new_object_version_number
                   ,p_ins_comp_id                 => l_new_competence_element_id);
                 end if;
            /*  else
                 -- implies new record has level less then existing level and it's start date
               -- is less than exisitng record date
               -- create a new record with new level and new start date and end it
               -- one day before the exisitng record start date
                    create_competence_element
                   (p_competence_element_id       => l_new_competence_element_id
                   ,p_object_version_number       => l_new_object_version_number
                   ,p_type                        => 'PERSONAL'
                   ,p_person_id                   => p_person_id
                   ,p_business_group_id           => p_business_group_id
                   ,p_competence_id               => p_competence_id
                   ,p_proficiency_level_id        => p_proficiency_level_id
                   ,p_effective_date_from         => l_new_effective_date_from
                   ,p_effective_date_to           => l_effective_date_from-1
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date);

                 end if;*/
		p_competence_created := 2;

              end if;
         elsif l_effective_date_to is not null and p_effective_date_from >= l_effective_date_to then
              create_competence_element
                   (p_competence_element_id       => l_new_competence_element_id
                   ,p_object_version_number       => l_new_object_version_number
                   ,p_type                        => 'PERSONAL'
                   ,p_person_id                   => p_person_id
                   ,p_business_group_id           => p_business_group_id
                   ,p_competence_id               => p_competence_id
                   ,p_proficiency_level_id        => p_proficiency_level_id
                   ,p_effective_date_from         => l_new_effective_date_from
                   ,p_effective_date_to           => p_effective_date_to
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date);

--
               p_competence_created := 1;

         else
              create_competence_element
                   (p_competence_element_id       => l_new_competence_element_id
                   ,p_object_version_number       => l_new_object_version_number
                   ,p_type                        => 'PERSONAL'
                   ,p_person_id                   => p_person_id
                   ,p_business_group_id           => p_business_group_id
                   ,p_competence_id               => p_competence_id
                   ,p_proficiency_level_id        => p_proficiency_level_id
                   ,p_effective_date_from         => l_new_effective_date_from
                   ,p_effective_date_to           => p_effective_date_to
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date);
               p_competence_created := 1;

         end if;
       --Bug 2366782
--
      elsif nvl(l_proficiency_level_id, -1) = nvl(p_proficiency_level_id, -1) then
--
         if l_effective_date_to is null and p_effective_date_to is null and l_effective_date_from > p_effective_date_from then
--
           update_personal_comp_element
                   (p_competence_element_id       => l_competence_element_id
                   ,p_object_version_number       => l_object_version_number
                   ,p_proficiency_level_id        => p_proficiency_level_id
                   ,p_effective_date_from         => l_new_effective_date_from
                   ,p_effective_date_to           => p_effective_date_to
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date
                   ,p_ins_ovn                     => l_new_object_version_number
                   ,p_ins_comp_id                 => l_new_competence_element_id);
--
            p_competence_created := 1;
--
         elsif l_effective_date_to is null and p_effective_date_to is not null then
--
            if p_effective_date_to >= l_effective_date_from then
            update_personal_comp_element
                   (p_competence_element_id       => l_competence_element_id
                   ,p_object_version_number       => l_object_version_number
                   ,p_proficiency_level_id        => p_proficiency_level_id
                   ,p_effective_date_from         => l_new_effective_date_from
                   ,p_effective_date_to           => l_effective_date_to
                   ,p_certification_date          => p_certification_date
                   ,p_certification_method        => p_certification_method
                   ,p_next_certification_date     => p_next_certification_date
                   ,p_source_of_proficiency_level => p_source_of_proficiency_level
                   ,p_comments                    => p_comments
                   ,p_effective_date              => p_effective_date
                   ,p_ins_ovn                     => l_new_object_version_number
                   ,p_ins_comp_id                 => l_new_competence_element_id);

            else
            -- new record ends before exisitng record start date.
            create_competence_element
                      (p_competence_element_id       => l_new_competence_element_id
                      ,p_object_version_number       => l_new_object_version_number
                      ,p_type                        => 'PERSONAL'
                      ,p_person_id                   => p_person_id
                      ,p_business_group_id           => p_business_group_id
                      ,p_competence_id               => p_competence_id
                      ,p_proficiency_level_id        => p_proficiency_level_id
                      ,p_effective_date_from         => p_effective_date_from
                      ,p_effective_date_to           => p_effective_date_to
                      ,p_certification_date          => p_certification_date
                      ,p_certification_method        => p_certification_method
                      ,p_next_certification_date     => p_next_certification_date
                      ,p_source_of_proficiency_level => p_source_of_proficiency_level
                      ,p_comments                    => p_comments
                      ,p_effective_date              => p_effective_date);

            end if;
--
            p_competence_created := 1;
--
         elsif l_effective_date_to is not null
               and (p_effective_date_to is null and p_effective_date_from > l_effective_date_to) then
--
               create_competence_element
                      (p_competence_element_id       => l_new_competence_element_id
                      ,p_object_version_number       => l_new_object_version_number
                      ,p_type                        => 'PERSONAL'
                      ,p_person_id                   => p_person_id
                      ,p_business_group_id           => p_business_group_id
                      ,p_competence_id               => p_competence_id
                      ,p_proficiency_level_id        => p_proficiency_level_id
                      ,p_effective_date_from         => p_effective_date_from
                      ,p_effective_date_to           => p_effective_date_to
                      ,p_certification_date          => p_certification_date
                      ,p_certification_method        => p_certification_method
                      ,p_next_certification_date     => p_next_certification_date
                      ,p_source_of_proficiency_level => p_source_of_proficiency_level
                      ,p_comments                    => p_comments
                      ,p_effective_date              => p_effective_date);
--
               p_competence_created := 1;
--
         elsif l_effective_date_to is not null and p_effective_date_to is not null then
--
            if l_effective_date_from <= p_effective_date_from
               and l_effective_date_to >= p_effective_date_to then
--
               null;
--
            elsif l_effective_date_to < p_effective_date_from then
--
               create_competence_element
                      (p_competence_element_id       => l_new_competence_element_id
                      ,p_object_version_number       => l_new_object_version_number
                      ,p_type                        => 'PERSONAL'
                      ,p_person_id                   => p_person_id
                      ,p_business_group_id           => p_business_group_id
                      ,p_competence_id               => p_competence_id
                      ,p_proficiency_level_id        => p_proficiency_level_id
                      ,p_effective_date_from         => p_effective_date_from
                      ,p_effective_date_to           => p_effective_date_to
                      ,p_certification_date          => p_certification_date
                      ,p_certification_method        => p_certification_method
                      ,p_next_certification_date     => p_next_certification_date
                      ,p_source_of_proficiency_level => p_source_of_proficiency_level
                      ,p_comments                    => p_comments
                      ,p_effective_date              => p_effective_date);
--
               p_competence_created := 1;
--
         else
--
               if p_effective_date_to >= l_effective_date_from then
               update_personal_comp_element
                      (p_competence_element_id       => l_competence_element_id
                      ,p_object_version_number       => l_object_version_number
                      ,p_proficiency_level_id        => p_proficiency_level_id
                      ,p_effective_date_from         => l_new_effective_date_from
                      ,p_effective_date_to           => p_effective_date_to
                      ,p_certification_date          => p_certification_date
                      ,p_certification_method        => p_certification_method
                      ,p_next_certification_date     => p_next_certification_date
                      ,p_source_of_proficiency_level => p_source_of_proficiency_level
                      ,p_comments                    => p_comments
                      ,p_effective_date              => p_effective_date
                      ,p_ins_ovn                     => l_new_object_version_number
                      ,p_ins_comp_id                 => l_new_competence_element_id);

               else
            -- new record ends before exisitng record start date.
            create_competence_element
                      (p_competence_element_id       => l_new_competence_element_id
                      ,p_object_version_number       => l_new_object_version_number
                      ,p_type                        => 'PERSONAL'
                      ,p_person_id                   => p_person_id
                      ,p_business_group_id           => p_business_group_id
                      ,p_competence_id               => p_competence_id
                      ,p_proficiency_level_id        => p_proficiency_level_id
                      ,p_effective_date_from         => p_effective_date_from
                      ,p_effective_date_to           => p_effective_date_to
                      ,p_certification_date          => p_certification_date
                      ,p_certification_method        => p_certification_method
                      ,p_next_certification_date     => p_next_certification_date
                      ,p_source_of_proficiency_level => p_source_of_proficiency_level
                      ,p_comments                    => p_comments
                      ,p_effective_date              => p_effective_date);

               end if;
--
               p_competence_created := 1;
--
            end if;
         elsif l_effective_date_to is not null
               and (p_effective_date_to is null and p_effective_date_from < l_effective_date_to) then

       --Bug 2366782
               update_personal_comp_element
                      (p_competence_element_id       => l_competence_element_id
                      ,p_object_version_number       => l_object_version_number
                      ,p_proficiency_level_id        => p_proficiency_level_id
                      ,p_effective_date_from         => l_new_effective_date_from
                      ,p_effective_date_to           => p_effective_date_to
                      ,p_certification_date          => p_certification_date
                      ,p_certification_method        => p_certification_method
                      ,p_next_certification_date     => p_next_certification_date
                      ,p_source_of_proficiency_level => p_source_of_proficiency_level
                      ,p_comments                    => p_comments
                      ,p_effective_date              => p_effective_date
                      ,p_ins_ovn                     => l_new_object_version_number
                      ,p_ins_comp_id                 => l_new_competence_element_id);
--
--
               p_competence_created := 1;

       --Bug 2366782
         end if;
--
       end if;
--
   end if;
--
--         end modifications for bug #1623036
--
-- Call After Process User Hook
--

begin
	hr_competence_element_bk5.maintain_student_comp_elemen_a	(
       p_person_id                   => p_person_id
      ,p_business_group_id           => p_business_group_id
      ,p_competence_id               => p_competence_id
      ,p_proficiency_level_id        => p_proficiency_level_id
      ,p_effective_date_from         => l_new_effective_date_from
      ,p_effective_date_to           => p_effective_date_to
      ,p_certification_date          => p_certification_date
      ,p_certification_method        => p_certification_method
      ,p_next_certification_date     => p_next_certification_date
      ,p_source_of_proficiency_level => p_source_of_proficiency_level
      ,p_comments                    => p_comments
      ,p_effective_date              => p_effective_date
      ,p_competence_created          => p_competence_created
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'maintain_student_comp_element',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User hook
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO maintain_student_comp_element;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_competence_created  	     := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    p_competence_created := null;
    --
    ROLLBACK TO maintain_student_comp_element;
    raise;
    --
    -- End of fix.
    --
end maintain_student_comp_element;
--
--
--
-- ---------------------------------------------------------------------------
-- |--------------------------< <copy_competencies> >------------------------|
-- ---------------------------------------------------------------------------
--
procedure copy_competencies(p_activity_version_from number
                           ,p_activity_version_to number
			   ,p_competence_type	VARCHAR2 default null -- Added for bug 1868713
                           ,p_validate              boolean  default FALSE) is
--
l_competence_element_id number;
l_object_version_number number;
--
/*Added for Globalization*/
cursor c_get_competencies_trainer is
select e.competence_id
,      e.business_group_id
,      e.proficiency_level_id
,      e.effective_date_from
,      e.effective_date_to
,      e.comments
,      e.attribute_category
,      e.attribute1
,      e.attribute2
,      e.attribute3
,      e.attribute4
,      e.attribute5
,      e.attribute6
,      e.attribute7
,      e.attribute8
,      e.attribute9
,      e.attribute10
,      e.attribute11
,      e.attribute12
,      e.attribute13
,      e.attribute14
,      e.attribute15
,      e.attribute16
,      e.attribute17
,      e.attribute18
,      e.attribute19
,      e.attribute20
from per_competence_elements e
where e.object_id = p_activity_version_from
and e.type='TRAINER';
--
cursor c_get_competencies_other is
select e.competence_id
,      e.business_group_id
,      e.proficiency_level_id
,      e.effective_date_from
,      e.effective_date_to
,      e.comments
,      e.attribute_category
,      e.attribute1
,      e.attribute2
,      e.attribute3
,      e.attribute4
,      e.attribute5
,      e.attribute6
,      e.attribute7
,      e.attribute8
,      e.attribute9
,      e.attribute10
,      e.attribute11
,      e.attribute12
,      e.attribute13
,      e.attribute14
,      e.attribute15
,      e.attribute16
,      e.attribute17
,      e.attribute18
,      e.attribute19
,      e.attribute20
from per_competence_elements e
where e.activity_version_id = p_activity_version_from
and e.type = nvl(p_competence_type,'DELIVERY');  -- For Bug 1868713
--
begin
  --
  -- Issue a savepoint.
  --
  savepoint copy_competencies;
  --
  -- Call Before Process User Hook
  --
  begin
     --
     -- p_activity_version_from will be passed to p_activity_version_id since the
     -- function ota_tav_bus.return_legislation_code expects the parameter
     -- activity_version_id and it is the same as the activity_version_from.
     --
     hr_competence_element_bk6.copy_competencies_b	(
         p_activity_version_from => p_activity_version_from,
         p_activity_version_id   => p_activity_version_from,
         p_activity_version_to   => p_activity_version_to ,
         p_competence_type       => p_competence_type
      );
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'copy_competencies',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User hook
  --
IF p_competence_type= 'TRAINER' then

  for comp in c_get_competencies_trainer loop
      per_cel_ins.ins
  (p_competence_element_id         	=> l_competence_element_id
  ,p_object_version_number        	=> l_object_version_number
  ,p_type                           => 'TRAINER'
  ,p_business_group_id           	=> comp.business_group_id
  ,p_competence_id               	=> comp.competence_id
  ,p_proficiency_level_id          	=> comp.proficiency_level_id
  ,p_activity_version_id           	=>NULL-- p_activity_version_to Modified for Globalization
  ,p_effective_date_from          	=> comp.effective_date_from
  ,p_effective_date_to           	=> comp.effective_date_to
  ,p_comments                      	=> comp.comments
  ,p_attribute_category            	=> comp.attribute_category
  ,p_attribute1                    	=> comp.attribute1
  ,p_attribute2                   	=> comp.attribute2
  ,p_attribute3                 	=> comp.attribute3
  ,p_attribute4                    	=> comp.attribute4
  ,p_attribute5                    	=> comp.attribute5
  ,p_attribute6                    	=> comp.attribute6
  ,p_attribute7                    	=> comp.attribute7
  ,p_attribute8                   	=> comp.attribute8
  ,p_attribute9                    	=> comp.attribute9
  ,p_attribute10                   	=> comp.attribute10
  ,p_attribute11                  	=> comp.attribute11
  ,p_attribute12                   	=> comp.attribute12
  ,p_attribute13                 	=> comp.attribute13
  ,p_attribute14                  	=> comp.attribute14
  ,p_attribute15                   	=> comp.attribute15
  ,p_attribute16                  	=> comp.attribute16
  ,p_attribute17                 	=> comp.attribute17
  ,p_attribute18                  	=> comp.attribute18
  ,p_attribute19                   	=> comp.attribute19
  ,p_attribute20                	=> comp.attribute20
  ,p_effective_date		 	=> sysdate
  ,p_validate                      	=> FALSE
  ,p_object_id				=> p_activity_version_to /*Added for Globalization*/
  );
  end loop;
ELSE
for comp in c_get_competencies_other loop
	per_cel_ins.ins
  (p_competence_element_id         	=> l_competence_element_id
  ,p_object_version_number        	=> l_object_version_number
  ,p_type                           => 'DELIVERY'
  ,p_business_group_id           	=> comp.business_group_id
  ,p_competence_id               	=> comp.competence_id
  ,p_proficiency_level_id          	=> comp.proficiency_level_id
  ,p_activity_version_id           	=> p_activity_version_to   -- Modified for Globalization
  ,p_effective_date_from          	=> comp.effective_date_from
  ,p_effective_date_to           	=> comp.effective_date_to
  ,p_comments                      	=> comp.comments
  ,p_attribute_category            	=> comp.attribute_category
  ,p_attribute1                    	=> comp.attribute1
  ,p_attribute2                   	=> comp.attribute2
  ,p_attribute3                 	=> comp.attribute3
  ,p_attribute4                    	=> comp.attribute4
  ,p_attribute5                    	=> comp.attribute5
  ,p_attribute6                    	=> comp.attribute6
  ,p_attribute7                    	=> comp.attribute7
  ,p_attribute8                   	=> comp.attribute8
  ,p_attribute9                    	=> comp.attribute9
  ,p_attribute10                   	=> comp.attribute10
  ,p_attribute11                  	=> comp.attribute11
  ,p_attribute12                   	=> comp.attribute12
  ,p_attribute13                 	=> comp.attribute13
  ,p_attribute14                  	=> comp.attribute14
  ,p_attribute15                   	=> comp.attribute15
  ,p_attribute16                  	=> comp.attribute16
  ,p_attribute17              	=> comp.attribute17
  ,p_attribute18                  	=> comp.attribute18
  ,p_attribute19                   	=> comp.attribute19
  ,p_attribute20                	=> comp.attribute20
  ,p_effective_date		 	=> sysdate
  ,p_validate                      	=> FALSE
  );
end loop;
END IF;

  -- Call after Process User Hook
  --
  begin
     --
     -- p_activity_version_from will be passed to p_activity_version_id since the
     -- function ota_tav_bus.return_legislation_code expects the parameter
     -- activity_version_id and it is the same as the activity_version_from.
     --
     hr_competence_element_bk6.copy_competencies_a	(
         p_activity_version_from => p_activity_version_from,
         p_activity_version_id   => p_activity_version_from,
         p_activity_version_to   => p_activity_version_to ,
         p_competence_type       => p_competence_type  );
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'copy_competencies',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User hook
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO copy_competencies;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO copy_competencies;
    raise;
    --
    -- End of fix.
    --
end copy_competencies;
--
--
-- ---------------------------------------------------------------------------
-- |------------------------< <update_delivered_dates> >---------------------|
-- ---------------------------------------------------------------------------
--
procedure update_delivered_dates
        (p_activity_version_id                 in number,
        p_old_start_date                       in date,
        p_start_date                           in date,
        p_old_end_date                         in date,
        p_end_date                             in date,
	p_validate			       in boolean   default FALSE)  is
  --
  v_proc         varchar2 (72) := g_package || 'update_delivered_dates';
  l_start_date         date;
  l_end_date           date;
  l_sd_changed         varchar2 (20) := 'N';
  l_ed_changed         varchar2 (20) := 'N';

 l_start_date_changed boolean :=
        ota_general.value_changed(p_old_start_date,p_start_date);
l_end_date_changed boolean :=
        ota_general.value_changed(p_old_end_date,p_end_date);
  --
  v_competence_element_id      number;
  v_object_version_number   number;
  v_start_date             date;
  v_end_date               date;
  v_competence_date_from          date;
  v_competence_date_to            date;

cursor get_competence_element is
  select e.competence_element_id
        ,e.object_version_number
        ,e.effective_date_from
        ,e.effective_date_to
        ,c.date_from
        ,c.date_to
  from per_competence_elements e
  ,    per_competences c
  where e.activity_version_id = p_activity_version_id
  and   e.type = 'DELIVERY'
  and   e.competence_id = c.competence_id
  and (((l_sd_changed = 'Y'
   and nvl(e.effective_date_from,hr_api.g_sot)
     = nvl(p_old_start_date,hr_api.g_sot))
     or ( l_sd_changed = 'N'
       and l_ed_changed = 'Y'
     and nvl(e.effective_date_to,hr_api.g_eot)
       = nvl(p_old_end_date,hr_api.g_eot)))
  OR ((l_ed_changed = 'Y'
   and nvl(e.effective_date_to,hr_api.g_eot)
     = nvl(p_old_end_date,hr_api.g_eot))
  OR (l_ed_changed = 'N'
       and l_sd_changed = 'Y'
   and nvl(e.effective_date_from,hr_api.g_sot)
     = nvl(p_old_start_date,hr_api.g_sot))));

Begin
  --
  hr_utility.set_location ('Entering:' || v_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_delivered_dates;
  --
  -- Call Before Process User Hook
  --
  begin
     hr_competence_element_bk7.update_delivered_dates_b	(
        p_activity_version_id      =>  p_activity_version_id,
        p_old_start_date           =>  p_old_start_date     ,
        p_start_date               =>  p_start_date         ,
        p_old_end_date             =>  p_old_end_date       ,
        p_end_date                 =>  p_end_date
      );
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_delivered_dates',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User hook
  --
  -- If niether the start/end date has changed then return
  --
  If not (l_start_date_changed) and not (l_end_date_changed) Then
     return;
  End if;
  --
  -- Set variable to indicate whether start/end date has changed
  --
 If l_start_date_changed Then
    l_sd_changed := 'Y';
 End if;

 If l_end_date_changed Then
    l_ed_changed := 'Y';
 End if;
 --
 -- Fetch the elements that need to be updated
 --

 Open get_competence_element;
 Fetch get_competence_element into v_competence_element_id
                               ,v_object_version_number
                               ,v_start_date
                               ,v_end_date
                               ,v_competence_date_from
                               ,v_competence_date_to;

Loop
  --
  Exit When get_competence_element%notfound
  OR get_competence_element%notfound is null;
  --
  -- If both start and end date have changed then need to determine whether the
  -- cel start date matches the old activity start date and also if the the old
  -- end date matches the cel end date.
  --
  If l_start_date_changed and
     l_end_date_changed   Then
     --
     -- If the old start date is the same as the cel start date then need to
     -- update to the new date
     --
     If not ota_general.value_changed(p_old_start_date,v_start_date) Then
        l_start_date := greatest(p_start_date
                                ,nvl(v_competence_date_from,hr_api.g_sot));
     Else
      l_start_date := hr_api.g_date;
     End if;
     --
     -- If the old end date is the same as the cel end date then need to
     -- update to the new date
     --
     If not ota_general.value_changed(p_old_end_date,v_end_date) Then
        l_end_date := least(p_end_date
                           ,nvl(v_competence_date_to,hr_api.g_eot));
     Else
        l_end_date := hr_api.g_date;
     End if;
     --
  Else
     --
     -- If the start has changed then update the resource usage with the new
     -- activity start date, otherwise use the default value so that the
     -- existing resource usage start date is used
     --
     If l_start_date_changed Then
        l_start_date := greatest(p_start_date
                                ,nvl(v_competence_date_from,hr_api.g_sot));
     Else
       l_start_date := hr_api.g_date;
     End if;
     --
    --
    -- If the end date has changed then update the resource usage with the new
    -- activity end date otherwise, use the default value so that the existing

    -- resource usage end date is used
    --
    If l_end_date_changed Then
       l_end_date := least(p_end_date
                          ,nvl(v_competence_date_to,hr_api.g_eot));
    Else
       l_end_date := hr_api.g_date;
    End if;
    --
  End if;
  --
  -- Now, perform the update
  --
  per_cel_upd.upd(p_competence_element_id  => v_competence_element_id
                ,p_object_version_number  => v_object_version_number
                ,p_effective_date_from    => l_start_date
                ,p_effective_date_to      => l_end_date
                ,p_effective_date         => sysdate
                );
  --
 Fetch get_competence_element into v_competence_element_id
                               ,v_object_version_number
                               ,v_start_date
                               ,v_end_date
                               ,v_competence_date_from
                               ,v_competence_date_to;
End loop;
--
Close get_competence_element;
--
-- Call After Process User Hook
--
  begin
     hr_competence_element_bk7.update_delivered_dates_a	(
        p_activity_version_id      =>  p_activity_version_id,
        p_old_start_date           =>  p_old_start_date     ,
        p_start_date               =>  p_start_date         ,
        p_old_end_date             =>  p_old_end_date       ,
        p_end_date                 =>  p_end_date
      );
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_delivered_dates',
				 p_hook_type	=> 'AP'
				);
  end;
--
-- End of after Process User hook
--
if p_validate then
   raise hr_api.validate_enabled;
end if;
--
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_delivered_dates;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO update_delivered_dates;
    raise;
    --
    -- End of fix.
    --
--
  hr_utility.set_location (' Leaving:' || v_proc, 5);
--
End update_delivered_dates;
--
end hr_competence_element_api;

/
