--------------------------------------------------------
--  DDL for Package Body HR_COMP_ELEMENT_OUTCOME_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COMP_ELEMENT_OUTCOME_API" as
/* $Header: peceoapi.pkb 115.1 2004/03/30 18:10 ynegoro noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_comp_element_outcome_api.';
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_element_outcome >---------------------------|
-- ----------------------------------------------------------------------------
procedure create_element_outcome
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_competence_element_id         in     number
  ,p_outcome_id                    in     number
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
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
  ,p_comp_element_outcome_id          out nocopy number
  ,p_object_version_number            out nocopy number
 ) is

   --
   -- Declare cursors and local variables
   --
   cursor csr_competence_element is
   select party_id ,person_id, type, status, object_version_number
   from per_competence_elements
   where competence_element_id = p_competence_element_id;

   cursor csr_get_competence_id is
       select competence_id
       from per_competence_outcomes
       where outcome_id = p_outcome_id;

   l_proc                     varchar2(72) := g_package||'create_element_outcome';
   l_effective_date           date;
   l_boolean                  boolean;
   l_competence_id            per_competence_outcomes.competence_id%TYPE;
   l_max_date_from            date;

   --
   -- Declare out parameters
   --
   l_comp_element_outcome_id  per_comp_element_outcomes.comp_element_outcome_id%TYPE;
   l_object_version_number    per_comp_element_outcomes.object_version_number%TYPE;
   lv_object_version_number   per_competence_elements.object_version_number%TYPE;
   l_party_id                 per_competence_elements.party_id%TYPE;
   l_person_id                per_competence_elements.person_id%TYPE;
   l_type                     per_competence_elements.type%TYPE;
   l_status                   per_competence_elements.status%TYPE;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_comp_element_outcome_id := p_comp_element_outcome_id;

  --
  -- Issue a savepoint
  --
  savepoint create_element_outcome;

  hr_utility.set_location(l_proc, 20);

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date    := trunc(p_effective_date);

  --
  -- Call Before Process User hook for create_comp_element_outcome
  --
  begin
  hr_comp_element_outcome_bk1.create_element_outcome_b
    (p_effective_date	             => l_effective_date
    ,p_competence_element_id         => p_competence_element_id
    ,p_outcome_id                    => p_outcome_id
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
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
        (p_module_name => 'CREATE_ELEMENT_OUTCOME'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of before hook process (create_element_outcome)
  --
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --

  --
  -- Insert competence outcome
  --
  --
  per_ceo_ins.ins
    (p_effective_date                => l_effective_date
    ,p_competence_element_id         => p_competence_element_id
    ,p_outcome_id                    => p_outcome_id
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
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
    ,p_comp_element_outcome_id       => l_comp_element_outcome_id
    ,p_object_version_number         => l_object_version_number
    );

  hr_utility.set_location(l_proc, 40);

  --
  --
  -- Call After Process hook for create_element_outcome
  --

  begin
  hr_comp_element_outcome_bk1.create_element_outcome_a
    (p_effective_date                => l_effective_date
    ,p_comp_element_outcome_id       => p_comp_element_outcome_id
    ,p_competence_element_id         => p_competence_element_id
    ,p_outcome_id                    => p_outcome_id
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
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
        (p_module_name => 'CREATE_ELEMENT_OUTCOME'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of after hook process (create_element_outcome)
    --
  end;

  hr_utility.set_location(l_proc, 50);
  --
  --  Call update_competence_element to update the status to ACHIEVED
  --  If all required outcome are achieved
  --
  select competence_id into l_competence_id
                       from per_competence_outcomes
                       where outcome_id = p_outcome_id;

  hr_utility.trace('l_competence_id   : ' || l_competence_id);

  l_max_date_from := per_ceo_bus.check_outcome_achieved(
                p_effective_date         =>  l_effective_date
               ,p_competence_element_id  =>  p_competence_element_id
               ,p_competence_id          =>  l_competence_id
               );
  --
  if (l_max_date_from is not NULL) then
    hr_utility.set_location(l_proc, 60);
    hr_utility.trace('l_max_date_from : ' || l_max_date_from);
    open csr_competence_element;
    fetch csr_competence_element into l_party_id, l_person_id, l_type ,
                                      l_status,lv_object_version_number;
    if csr_competence_element%FOUND then
      close csr_competence_element;
      hr_utility.set_location(l_proc, 70);
      if l_status is NULL or l_status <> 'ACHIEVED' then
        hr_utility.set_location(l_proc, 80);
        hr_competence_element_api.update_competence_element
          (p_effective_date                => l_effective_date
          ,p_competence_element_id         => p_competence_element_id
          ,p_status                        => 'ACHIEVED'
          ,p_achieved_date                 => l_max_date_from
          ,p_party_id                      => l_party_id
          ,p_object_version_number         => lv_object_version_number
        );
      end if;
    else
      close csr_competence_element;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','5');
      fnd_message.raise_error;
    end if;
  end if;

  hr_utility.set_location(l_proc, 90);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate
  then
     raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 100);
  --
  -- Set OUT parameters
  --
  p_comp_element_outcome_id := l_comp_element_outcome_id;
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving...:' ||l_proc, 110);
  --
  exception
  --
  when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     ROLLBACK TO create_element_outcome;
     --
     -- Set OUT parameters to null
     -- Only set output warning arguments
     -- (Any key or derived arguments must be set to null
     -- when validation only mode is being used.)
     --
     p_comp_element_outcome_id   := null;
     p_object_version_number     := null;
     --
     hr_utility.set_location(' Leaving....:'||l_proc, 120);
  --
  when others then
     --
     -- A validation or unexpected error has occurred
     --
     ROLLBACK TO create_element_outcome;
     --
     hr_utility.set_location(' Leaving......:'||l_proc, 130);
     --
     p_comp_element_outcome_id   := null;
     p_object_version_number     := null;
     --
     raise;
     --
end create_element_outcome;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_element_outcome >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_element_outcome
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_comp_element_outcome_id       in     number
  ,p_object_version_number         in out nocopy number
  ,p_competence_element_id         in     number   default hr_api.g_number
  ,p_outcome_id                    in     number   default hr_api.g_number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
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
   l_proc                     varchar2(72) := g_package||'update_element_outcome';
   l_effective_date           date;
   lv_object_version_number   per_comp_element_outcomes.object_version_number%TYPE;

   --
   -- Declare out parameters
   --
   l_object_version_number    per_comp_element_outcomes.object_version_number%TYPE;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  lv_object_version_number := p_object_version_number;

  --
  -- Issue a savepoint
  --
  savepoint update_element_outcome;

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
  -- Call Before Process User hook for update_element_outcome
  --
  begin
  hr_comp_element_outcome_bk2.update_element_outcome_b
    (p_effective_date		     => l_effective_date
    ,p_comp_element_outcome_id       => p_comp_element_outcome_id
    ,p_competence_element_id         => p_competence_element_id
    ,p_outcome_id                    => p_outcome_id
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
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
        (p_module_name => 'UPDATE_ELEMENT_OUTCOME'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of before hook process (update_element_outcome)
  --
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --

  l_object_version_number := p_object_version_number;

  --
  -- Update Progression Point
  --
  --
  per_ceo_upd.upd
    (p_effective_date                => l_effective_date
    ,p_comp_element_outcome_id       => p_comp_element_outcome_id
    ,p_competence_element_id         => p_competence_element_id
    ,p_outcome_id                    => p_outcome_id
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_object_version_number         => l_object_version_number
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

  hr_utility.set_location(l_proc, 40);

  --
  --
  -- Call After Process hook for update_comp_element_outcome
  --

  begin
  hr_comp_element_outcome_bk2.update_element_outcome_a
    (p_effective_date                => l_effective_date
    ,p_comp_element_outcome_id       => p_comp_element_outcome_id
    ,p_object_version_number         => l_object_version_number
    ,p_competence_element_id         => p_competence_element_id
    ,p_outcome_id                    => p_outcome_id
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
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
        (p_module_name => 'UPDATE_ELEMENT_OUTCOME'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of after hook process (update_element_outcome)
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate
  then
     raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Set OUT parameters
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:' ||l_proc, 60);
  --
  exception
  --
  when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     rollback to update_element_outcome;
     --
     -- Set OUT parameters to null
     -- Only set output warning arguments
     -- (Any key or derived arguments must be set to null
     -- when validation only mode is being used.)
     --
     p_object_version_number     := p_object_version_number;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  when others then
     --
     -- A validation or unexpected error has occurred
     --
     rollback to update_element_outcome;
     --
     p_object_version_number     := lv_object_version_number;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 80);
     --
     raise;
     --
end update_element_outcome;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_element_outcome >-----------------------|
-- ----------------------------------------------------------------------------
--

procedure delete_element_outcome
  (p_validate                      in     boolean
  ,p_comp_element_outcome_id       in     number
  ,p_object_version_number         in out nocopy number
) IS

  --
  -- Declare cursors and local variables
  --

  cursor csr_get_competence_element_id is
     select competence_element_id
     from per_comp_element_outcomes
     where comp_element_outcome_id = p_comp_element_outcome_id;

  l_competence_element_id  per_comp_element_outcomes.competence_element_id%TYPE;
  cursor csr_competence_element is
     select party_id ,person_id, type, status, object_version_number
     from per_competence_elements
     where competence_element_id = l_competence_element_id;


  l_proc                   varchar2(72) := g_package||'delete_element_outcome';
  lv_object_version_number per_comp_element_outcomes.object_version_number%TYPE;
  ll_object_version_number per_competence_elements.object_version_number%TYPE;
  l_party_id               per_competence_elements.party_id%TYPE;
  l_person_id              per_competence_elements.person_id%TYPE;
  l_type                   per_competence_elements.type%TYPE;
  l_status                 per_competence_elements.status%TYPE;

  --
  -- Declare out variables
  --
  l_object_version_number    per_comp_element_outcomes.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  lv_object_version_number := p_object_version_number;

  --
  -- Issue a savepoint
  --
  savepoint delete_element_outcome;

  l_object_version_number := p_object_version_number;

  --
  -- Call Before Process User Hook
  --
  begin
  hr_comp_element_outcome_bk3.delete_element_outcome_b
    (p_comp_element_outcome_id    =>  p_comp_element_outcome_id
    ,p_object_version_number      =>  l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELEMENT_OUTCOME'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location(l_proc, 20);

  open csr_get_competence_element_id;
  fetch csr_get_competence_element_id into l_competence_element_id;
  close csr_get_competence_element_id;

  --
  -- Process Logic
  --

  per_ceo_del.del
    (p_comp_element_outcome_id       => p_comp_element_outcome_id
    ,p_object_version_number         => l_object_version_number
    );

  hr_utility.set_location(l_proc, 30);

  --
  -- Call After Process User Hook
  --
 begin
  hr_comp_element_outcome_bk3.delete_element_outcome_a
    (p_comp_element_outcome_id       => p_comp_element_outcome_id
    ,p_object_version_number         => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELEMENT_OUTCOME'
        ,p_hook_type   => 'AP'
        );
  end;

  hr_utility.set_location(l_proc, 40);

  --
  --  Call update_competence_element to update the status to IN_PROGRESS
  --

  open csr_competence_element;
  fetch csr_competence_element into l_party_id, l_person_id, l_type ,
                                    l_status,ll_object_version_number;
  if csr_competence_element%FOUND then
    close csr_competence_element;
    hr_utility.set_location(l_proc, 50);
    if l_status <> 'IN_PROGRESS' then
      hr_competence_element_api.update_competence_element
        (p_effective_date               => sysdate
        ,p_competence_element_id        => l_competence_element_id
        ,p_status                       => 'IN_PROGRESS'
        ,p_achieved_date                => NULL
        ,p_party_id                     => l_party_id
        ,p_object_version_number        => ll_object_version_number
    );
    end if;
  else
    close csr_competence_element;
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  end if;

  hr_utility.set_location(l_proc, 60);

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

  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when hr_api.validate_enabled then
    hr_utility.set_location(' Leaving...:'||l_proc, 70);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_element_outcome;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := null;
    --
  when others then
    hr_utility.set_location(' Leaving...:'||l_proc, 80);
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_element_outcome;
     --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := lv_object_version_number;
    --
    raise;
--
end delete_element_outcome;
--
end hr_comp_element_outcome_api;

/
