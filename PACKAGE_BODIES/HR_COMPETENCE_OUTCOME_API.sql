--------------------------------------------------------
--  DDL for Package Body HR_COMPETENCE_OUTCOME_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COMPETENCE_OUTCOME_API" as
/* $Header: pecpoapi.pkb 115.3 2004/03/31 13:54 ynegoro noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_competence_outcome_api.';
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_outcome >---------------------------------|
-- ----------------------------------------------------------------------------
procedure create_outcome
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_competence_id                 in     number
  ,p_outcome_number                in     number
  ,p_name                          in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_assessment_criteria           in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_information_category          in     varchar2 default null
  ,p_information1                  in     varchar2 default null
  ,p_information2                  in     varchar2 default null
  ,p_information3                  in     varchar2 default null
  ,p_information4                  in     varchar2 default null
  ,p_information5                  in     varchar2 default null
  ,p_information6                  in     varchar2 default null
  ,p_information7                  in     varchar2 default null
  ,p_information8                  in     varchar2 default null
  ,p_information9                  in     varchar2 default null
  ,p_information10                 in     varchar2 default null
  ,p_information11                 in     varchar2 default null
  ,p_information12                 in     varchar2 default null
  ,p_information13                 in     varchar2 default null
  ,p_information14                 in     varchar2 default null
  ,p_information15                 in     varchar2 default null
  ,p_information16                 in     varchar2 default null
  ,p_information17                 in     varchar2 default null
  ,p_information18                 in     varchar2 default null
  ,p_information19                 in     varchar2 default null
  ,p_information20                 in     varchar2 default null
  ,p_outcome_id    	              out nocopy number
  ,p_object_version_number            out nocopy number
 ) is

   --
   -- Declare cursors and local variables
   --

   l_proc                    varchar2(72) := g_package||'create_outcome';
   l_effective_date          date;
   l_language_code           per_competence_outcomes_tl.language%TYPE;

   --
   -- Declare out parameters
   --
   l_outcome_id               per_competence_outcomes.outcome_id%TYPE;
   l_object_version_number    per_competence_outcomes.object_version_number%TYPE;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_outcome_id := p_outcome_id;

  --
  -- Issue a savepoint
  --
  savepoint create_outcome;

  hr_utility.set_location(l_proc, 20);

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date    := trunc(p_effective_date);

  --
  -- Call Before Process User hook for create_competence_outcome
  --
  begin
  hr_competence_outcome_bk1.create_outcome_b
    (p_effective_date		     => l_effective_date
    ,p_language_code                 => p_language_code
    ,p_competence_id                 => p_competence_id
    ,p_outcome_number                => p_outcome_number
    ,p_name           	             => p_name
    ,p_date_from	             => p_date_from
    ,p_date_to	                     => p_date_to
    ,p_assessment_criteria           => p_assessment_criteria
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_OUTCOME'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of before hook process (create_outcome)
  --
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --

  --
  -- Validate the language parameter. l_language_code should be passed to
  -- functions instead of p_language_code from now on, to allow an IN OUT
  -- parameter to be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);

  hr_utility.set_location(l_proc, 40);

  --
  -- Insert competence outcome
  --
  --
  per_cpo_ins.ins
    (p_effective_date                => l_effective_date
    ,p_competence_id                 => p_competence_id
    ,p_outcome_number                => p_outcome_number
    ,p_name                          => p_name
    ,p_date_from	             => p_date_from
    ,p_date_to	                     => p_date_to
    ,p_assessment_criteria           => p_assessment_criteria
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_outcome_id                    => l_outcome_id
    ,p_object_version_number         => l_object_version_number
    );

  hr_utility.set_location(l_proc, 50);

  --
  --  Insert translatable rows in per_competence_outcomes_tl table
  --
  per_cot_ins.ins_tl
    (p_outcome_id          => l_outcome_id
    ,p_language_code       => l_language_code
    ,p_name                => p_name
    ,p_assessment_criteria => p_assessment_criteria
    );
  --
  hr_utility.set_location(l_proc, 60);

  --
  --
  -- Call After Process hook for create_outcome
  --

  begin
  hr_competence_outcome_bk1.create_outcome_a
    (p_effective_date                => l_effective_date
    ,p_language_code                 => p_language_code
    ,p_outcome_id                    => p_outcome_id
    ,p_competence_id                 => p_competence_id
    ,p_outcome_number                => p_outcome_number
    ,p_name                          => p_name
    ,p_date_from	             => p_date_from
    ,p_date_to	                     => p_date_to
    ,p_assessment_criteria           => p_assessment_criteria
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_object_version_number         => l_object_version_number
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_OUTCOME'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of after hook process (create_outcome)
    --
  end;

  hr_utility.set_location(l_proc, 70);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate
  then
     raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- Set OUT parameters
  --
  p_outcome_id            := l_outcome_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:' ||l_proc, 90);
  --
  exception
  --
  when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     ROLLBACK TO create_outcome;
     --
     -- Set OUT parameters to null
     -- Only set output warning arguments
     -- (Any key or derived arguments must be set to null
     -- when validation only mode is being used.)
     --
     p_outcome_id                := null;
     p_object_version_number     := null;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
  when others then
     --
     -- A validation or unexpected error has occurred
     --
     ROLLBACK TO create_outcome;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 110);
     --
     p_outcome_id                := null;
     p_object_version_number     := null;
     --
     raise;
     --
end create_outcome;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_outcome >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_outcome
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_outcome_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_competence_id                 in     number   default hr_api.g_number
  ,p_outcome_number                in     number   default hr_api.g_number
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_assessment_criteria           in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_information1                  in     varchar2 default hr_api.g_varchar2
  ,p_information2                  in     varchar2 default hr_api.g_varchar2
  ,p_information3                  in     varchar2 default hr_api.g_varchar2
  ,p_information4                  in     varchar2 default hr_api.g_varchar2
  ,p_information5                  in     varchar2 default hr_api.g_varchar2
  ,p_information6                  in     varchar2 default hr_api.g_varchar2
  ,p_information7                  in     varchar2 default hr_api.g_varchar2
  ,p_information8                  in     varchar2 default hr_api.g_varchar2
  ,p_information9                  in     varchar2 default hr_api.g_varchar2
  ,p_information10                 in     varchar2 default hr_api.g_varchar2
  ,p_information11                 in     varchar2 default hr_api.g_varchar2
  ,p_information12                 in     varchar2 default hr_api.g_varchar2
  ,p_information13                 in     varchar2 default hr_api.g_varchar2
  ,p_information14                 in     varchar2 default hr_api.g_varchar2
  ,p_information15                 in     varchar2 default hr_api.g_varchar2
  ,p_information16                 in     varchar2 default hr_api.g_varchar2
  ,p_information17                 in     varchar2 default hr_api.g_varchar2
  ,p_information18                 in     varchar2 default hr_api.g_varchar2
  ,p_information19                 in     varchar2 default hr_api.g_varchar2
  ,p_information20                 in     varchar2 default hr_api.g_varchar2
  ) is

   --
   -- Declare cursors and local variables
   --
   l_proc                    varchar2(72) := g_package||'update_outcome';
   l_effective_date          date;
   lv_object_version_number  per_competence_outcomes.object_version_number%TYPE;
   l_language_code           per_competence_outcomes_tl.language%TYPE;
   l_date_from               per_comp_element_outcomes.date_from%TYPE;
   l_date_to	             per_comp_element_outcomes.date_to%TYPE;
   l_ceo_ovn                 per_comp_element_outcomes.object_version_number%TYPE;
   l_cel_ovn                 per_competence_elements.object_version_number%TYPE;
   l_boolean                 boolean;
   l_competence_element_id   per_competence_elements.competence_element_id%TYPE;
   l_party_id                per_competence_elements.party_id%TYPE;
   lo_object_version_number  per_competence_elements.object_version_number%TYPE;
   l_competence_id           per_competence_outcomes.competence_id%TYPE;
   l_exists                  varchar2(1);
   l_max_date_from           date;

   --
   cursor csr_get_competence_element_id is
      select competence_element_id ,party_id,object_version_number
      from per_competence_elements
      where competence_id = l_competence_id
      and type = 'PERSONAL';

   --
   -- Declare out parameters
   --
   l_object_version_number    per_competence_outcomes.object_version_number%TYPE;
   --
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  lv_object_version_number := p_object_version_number;

  --
  -- Issue a savepoint
  --
  savepoint update_outcome;

  hr_utility.set_location(l_proc, 20);

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date    := trunc(p_effective_date);

  --
  -- store object version number passed in
  --
  l_object_version_number := p_object_version_number;

  --
  -- Call Before Process User hook for update_outcome
  --
  begin
  hr_competence_outcome_bk2.update_outcome_b
    (p_effective_date		     => l_effective_date
    ,p_language_code                 => p_language_code
    ,p_outcome_id                    => p_outcome_id
    ,p_competence_id                 => p_competence_id
    ,p_outcome_number                => p_outcome_number
    ,p_name                          => p_name
    ,p_date_from	             => p_date_from
    ,p_date_to	                     => p_date_to
    ,p_assessment_criteria           => p_assessment_criteria
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_object_version_number         => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_OUTCOME'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of before hook process (update_outcome)
  --
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --

  --
  -- Validate the language parameter. l_language_code should be passed to
  -- functions instead of p_language_code from now on, to allow an IN OUT
  -- parameter to be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);

  hr_utility.set_location(l_proc, 40);

  l_object_version_number := p_object_version_number;

  --
  -- Update Progression Point
  --
  --
  per_cpo_upd.upd
    (p_effective_date                => l_effective_date
    ,p_outcome_id                    => p_outcome_id
    ,p_object_version_number         => l_object_version_number
    ,p_competence_id                 => p_competence_id
    ,p_outcome_number                => p_outcome_number
    ,p_name                          => p_name
    ,p_date_from	             => p_date_from
    ,p_date_to	                     => p_date_to
    ,p_assessment_criteria           => p_assessment_criteria
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    );

  --
  -- Assign the out parameters.
  --
  p_object_version_number     := l_object_version_number;

  hr_utility.set_location(l_proc, 50);

  --
  --  Insert translatable rows in per_competence_outcomes_tl table
  --
  per_cot_upd.upd_tl
    (p_outcome_id          => p_outcome_id
    ,p_language_code       => p_language_code
    ,p_name                => p_name
    ,p_assessment_criteria => p_assessment_criteria
    );
  --
  hr_utility.set_location(l_proc, 60);

  --
  --
  -- Call After Process hook for update_competence_outcome
  --

  begin
  hr_competence_outcome_bk2.update_outcome_a
    (p_effective_date                => l_effective_date
    ,p_language_code                 => p_language_code
    ,p_outcome_id                    => p_outcome_id
    ,p_object_version_number         => l_object_version_number
    ,p_competence_id                 => p_competence_id
    ,p_outcome_number                => p_outcome_number
    ,p_name                          => p_name
    ,p_date_from	             => p_date_from
    ,p_date_to	                     => p_date_to
    ,p_assessment_criteria           => p_assessment_criteria
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_OUTCOME'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of after hook process (update_outcome)
    --
  end;

  hr_utility.set_location(l_proc, 70);
  --
  -- If the outcome is end dated, associated outcome achieved should
  -- change to 'IN_PROGRESS'
  --
  if p_date_from <> hr_api.g_date or p_date_to <> hr_api.g_date then
    hr_utility.set_location(l_proc, 71);
    hr_utility.trace('p_competence_id : ' || p_competence_id);
    if (p_competence_id = hr_api.g_number) then
      hr_utility.set_location(l_proc, 72);
      select competence_id  into l_competence_id
      from per_competence_outcomes
      where outcome_id = p_outcome_id;
    else
      hr_utility.set_location(l_proc, 73);
      l_competence_id := p_competence_id;
    end if;
    open csr_get_competence_element_id;
    loop
      hr_utility.set_location(l_proc, 74);
      fetch csr_get_competence_element_id into l_competence_element_id
            ,l_party_id , lo_object_version_number;
      exit when csr_get_competence_element_id%NOTFOUND;
      hr_utility.trace('p_outcome_id            : '|| p_outcome_id);
      hr_utility.trace('l_comptence_element_id  : '|| l_competence_element_id);
      hr_utility.trace('l_party_id              : '|| l_party_id);
      hr_utility.trace('lo_object_version_number: '|| lo_object_version_number);

      l_max_date_from := per_ceo_bus.check_outcome_achieved(
                p_effective_date         =>  l_effective_date
               ,p_competence_element_id  =>  l_competence_element_id
               ,p_competence_id          =>  l_competence_id
               );

      hr_utility.trace('l_max_date_from         : '|| l_max_date_from);

      if l_max_date_from is not NULL then
         hr_utility.set_location(l_proc, 75);
         hr_competence_element_api.update_competence_element
            (p_effective_date                => l_effective_date
            ,p_competence_element_id         => l_competence_element_id
            ,p_status                        => 'ACHIEVED'
            ,p_achieved_date                 => l_max_date_from
            ,p_party_id                      => l_party_id
            ,p_object_version_number         => lo_object_version_number
          );
      else
         --
         hr_utility.set_location(l_proc, 76);
         hr_competence_element_api.update_competence_element
            (p_effective_date                => l_effective_date
            ,p_competence_element_id         => l_competence_element_id
            ,p_status                        => 'IN_PROGRESS'
            ,p_achieved_date                 => NULL
            ,p_party_id                      => l_party_id
            ,p_object_version_number         => lo_object_version_number
          );
      end if;
    end loop;
    close csr_get_competence_element_id;
  end if;
  hr_utility.set_location(l_proc, 77);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate
  then
     raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- Set OUT parameters
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:' ||l_proc, 90);
  --
  exception
  --
  when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     rollback to update_outcome;
     --
     -- Set OUT parameters to null
     -- Only set output warning arguments
     -- (Any key or derived arguments must be set to null
     -- when validation only mode is being used.)
     --
     p_object_version_number     := p_object_version_number;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
  when others then
     --
     -- A validation or unexpected error has occurred
     --
     rollback to update_outcome;
     --
     p_object_version_number     := lv_object_version_number;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 110);
     --
     raise;
     --
end update_outcome;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_outcome >-------------------------------|
-- ----------------------------------------------------------------------------
--

procedure delete_outcome
  (p_validate                      in     boolean
  ,p_outcome_id                    in     number
  ,p_object_version_number         in out nocopy number
) IS

  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||'delete_outcome';
  lv_object_version_number  per_competence_outcomes.object_version_number%TYPE;
  l_competence_element_id   per_competence_elements.competence_element_id%TYPE;
  l_party_id                per_competence_elements.party_id%TYPE;
  lo_object_version_number  per_competence_elements.object_version_number%TYPE;
  l_competence_id           per_competence_outcomes.competence_id%TYPE;
  l_max_date_from           date;


  cursor csr_get_competence_element_id is
      select competence_element_id ,party_id,object_version_number
      from per_competence_elements
      where competence_id = l_competence_id
      and type = 'PERSONAL' and status = 'IN_PROGRESS';

  --
  -- Declare out variables
  --
  l_object_version_number    per_competence_outcomes.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  lv_object_version_number := p_object_version_number;

  --
  -- Issue a savepoint
  --
  savepoint delete_outcome;

  l_object_version_number := p_object_version_number;

  --
  -- Call Before Process User Hook
  --
  begin
  hr_competence_outcome_bk3.delete_outcome_b
    (p_outcome_id                 =>  p_outcome_id
    ,p_object_version_number      =>  l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_OUTCOME'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location(l_proc, 20);

  --
  -- Saved competence_id for calling hr_competence_element api
  --
  hr_utility.trace('p_outcome_id            : '|| p_outcome_id);
  select competence_id  into l_competence_id
      from per_competence_outcomes
      where outcome_id = p_outcome_id;

  hr_utility.trace('l_competence_id         : '|| l_competence_id);

  --
  -- Remove all matching translation rows in per_competence_outcomes_tl
  --
  per_cot_del.del_tl
    (p_outcome_id             => p_outcome_id
    );

  hr_utility.set_location(l_proc, 30);

  --
  -- Process Logic
  --

  per_cpo_del.del
    (p_outcome_id                    => p_outcome_id
    ,p_object_version_number         => l_object_version_number
    );

  hr_utility.set_location(l_proc, 40);

  --
  -- Call After Process User Hook
  --
 begin
  hr_competence_outcome_bk3.delete_outcome_a
    (p_outcome_id                    => p_outcome_id
    ,p_object_version_number         => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_OUTCOME'
        ,p_hook_type   => 'AP'
        );
  end;

  hr_utility.set_location(l_proc, 50);

  --
  -- If an outcome is deleted, associated outcome achieved may be
  -- change to 'ACHIEVED'
  --
  open csr_get_competence_element_id;
  loop
      fetch csr_get_competence_element_id into l_competence_element_id
            ,l_party_id , lo_object_version_number;
      exit when csr_get_competence_element_id%NOTFOUND;
      hr_utility.trace('l_comptence_element_id  : '|| l_competence_element_id);
      hr_utility.trace('l_party_id              : '|| l_party_id);

      l_max_date_from := per_ceo_bus.check_outcome_achieved(
                p_effective_date         =>  sysdate
               ,p_competence_element_id  =>  l_competence_element_id
               ,p_competence_id          =>  l_competence_id
               );

      hr_utility.trace('l_max_date_from         : '|| l_max_date_from);
      if (l_max_date_from is not NULL) then
          hr_utility.set_location(l_proc, 60);
          hr_competence_element_api.update_competence_element
            (p_effective_date                => sysdate
            ,p_competence_element_id         => l_competence_element_id
            ,p_status                        => 'ACHIEVED'
            ,p_achieved_date                 => l_max_date_from
            ,p_party_id                      => l_party_id
            ,p_object_version_number         => lo_object_version_number
          );
      end if;
  end loop;
  close csr_get_competence_element_id;

  hr_utility.set_location(l_proc, 70);

  p_object_version_number := l_object_version_number;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Set all output arguments (returned by some dt modes only)
  --
  p_object_version_number  := l_object_version_number;

  hr_utility.set_location(' Leaving:'||l_proc, 80);
exception
  when hr_api.validate_enabled then
    hr_utility.set_location(' Leaving...:'||l_proc, 90);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_outcome;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := null;
    --
  when others then
    hr_utility.set_location(' Leaving...:'||l_proc, 100);
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_outcome;
     --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := lv_object_version_number;
    --
    raise;
--
end delete_outcome;
--
end hr_competence_outcome_api;

/
