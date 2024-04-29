--------------------------------------------------------
--  DDL for Package Body HR_COMPETENCES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COMPETENCES_API" as
/* $Header: pecpnapi.pkb 120.0 2005/05/31 07:13:25 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_competences_api.';
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <create_competence> >--------------------------|
-- ---------------------------------------------------------------------------
--
-- ngundura business group id made an optional parameter.
procedure create_competence
 (p_validate                     in     boolean         default false,
  p_effective_date               in     date,
  p_language_code                in     varchar2 default hr_api.userenv_lang,
  p_business_group_id            in     number           default null,
  p_description                  in     varchar2         default null,
  p_competence_alias             in     varchar2         default null,
  p_date_from                    in     date,
  p_date_to                      in     date             default null,
  p_behavioural_indicator        in     varchar2         default null,
  p_certification_required       in     varchar2         default 'N',
  p_evaluation_method            in     varchar2         default null,
  p_renewal_period_frequency     in     number           default null,
  p_renewal_period_units         in     varchar2         default null,
  p_rating_scale_id              in     number           default null,
  p_attribute_category           in     varchar2         default null,
  p_attribute1                   in     varchar2         default null,
  p_attribute2                   in     varchar2         default null,
  p_attribute3                   in     varchar2         default null,
  p_attribute4                   in     varchar2         default null,
  p_attribute5                   in     varchar2         default null,
  p_attribute6                   in     varchar2         default null,
  p_attribute7                   in     varchar2         default null,
  p_attribute8                   in     varchar2         default null,
  p_attribute9                   in     varchar2         default null,
  p_attribute10                  in     varchar2         default null,
  p_attribute11                  in     varchar2         default null,
  p_attribute12                  in     varchar2         default null,
  p_attribute13                  in     varchar2         default null,
  p_attribute14                  in     varchar2         default null,
  p_attribute15                  in     varchar2         default null,
  p_attribute16                  in     varchar2         default null,
  p_attribute17                  in     varchar2         default null,
  p_attribute18                  in     varchar2         default null,
  p_attribute19                  in     varchar2         default null,
  p_attribute20                  in     varchar2         default null
    ,p_segment1                      in     varchar2 default null
    ,p_segment2                      in     varchar2 default null
    ,p_segment3                      in     varchar2 default null
    ,p_segment4                      in     varchar2 default null
    ,p_segment5                      in     varchar2 default null
    ,p_segment6                      in     varchar2 default null
    ,p_segment7                      in     varchar2 default null
    ,p_segment8                      in     varchar2 default null
    ,p_segment9                      in     varchar2 default null
    ,p_segment10                     in     varchar2 default null
    ,p_segment11                     in     varchar2 default null
    ,p_segment12                     in     varchar2 default null
    ,p_segment13                     in     varchar2 default null
    ,p_segment14                     in     varchar2 default null
    ,p_segment15                     in     varchar2 default null
    ,p_segment16                     in     varchar2 default null
    ,p_segment17                     in     varchar2 default null
    ,p_segment18                     in     varchar2 default null
    ,p_segment19                     in     varchar2 default null
    ,p_segment20                     in     varchar2 default null
    ,p_segment21                     in     varchar2 default null
    ,p_segment22                     in     varchar2 default null
    ,p_segment23                     in     varchar2 default null
    ,p_segment24                     in     varchar2 default null
    ,p_segment25                     in     varchar2 default null
    ,p_segment26                     in     varchar2 default null
    ,p_segment27                     in     varchar2 default null
    ,p_segment28                     in     varchar2 default null
    ,p_segment29                     in     varchar2 default null
    ,p_segment30                     in     varchar2 default null
    ,p_concat_segments               in     varchar2 default null
    ,p_competence_id                 out nocopy    number
    --
    -- bug 2267635 change p_competence_definition_id from an out to an in/out
    -- parameter to enable value to be passed into program when known and reqd
    --
    ,p_competence_definition_id  in  out nocopy    number
    ,p_object_version_number         out nocopy    number
    ,p_name                          out nocopy    varchar2
    ,p_competence_cluster            in varchar2        default null
    ,p_unit_standard_id              in varchar2        default null
    ,p_credit_type                   in varchar2        default null
    ,p_credits                       in number          default null
    ,p_level_type                    in varchar2        default null
    ,p_level_number                  in number          default null
    ,p_field                         in varchar2        default null
    ,p_sub_field                     in varchar2        default null
    ,p_provider                      in varchar2        default null
    ,p_qa_organization               in varchar2        default null
    ,p_information_category          in varchar2        default null
    ,p_information1                  in varchar2        default null
    ,p_information2                  in varchar2        default null
    ,p_information3                  in varchar2        default null
    ,p_information4                  in varchar2        default null
    ,p_information5                  in varchar2        default null
    ,p_information6                  in varchar2        default null
    ,p_information7                  in varchar2        default null
    ,p_information8                  in varchar2        default null
    ,p_information9                  in varchar2        default null
    ,p_information10                 in varchar2        default null
    ,p_information11                 in varchar2        default null
    ,p_information12                 in varchar2        default null
    ,p_information13                 in varchar2        default null
    ,p_information14                 in varchar2        default null
    ,p_information15                 in varchar2        default null
    ,p_information16                 in varchar2        default null
    ,p_information17                 in varchar2        default null
    ,p_information18                 in varchar2        default null
    ,p_information19                 in varchar2        default null
    ,p_information20                 in varchar2        default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'create_competence';
  l_competence_id             per_competences.competence_id%TYPE;
  l_name                      varchar2(700) := p_concat_segments;   -- bug#2925181
  l_flex_num number;
  l_competence_definition_id  per_competences.competence_definition_id%TYPE
  := p_competence_definition_id;
  l_object_version_number     per_competences.object_version_number%TYPE;
  l_segment1                 varchar2(150) := p_segment1;
  l_segment2                 varchar2(150) := p_segment2;
  l_segment3                 varchar2(150) := p_segment3;
  l_segment4                 varchar2(150) := p_segment4;
  l_segment5                 varchar2(150) := p_segment5;
  l_segment6                 varchar2(150) := p_segment6;
  l_segment7                 varchar2(150) := p_segment7;
  l_segment8                 varchar2(150) := p_segment8;
  l_segment9                 varchar2(150) := p_segment9;
  l_segment10                varchar2(150) := p_segment10;
  l_segment11                varchar2(150) := p_segment11;
  l_segment12                varchar2(150) := p_segment12;
  l_segment13                varchar2(150) := p_segment13;
  l_segment14                varchar2(150) := p_segment14;
  l_segment15                varchar2(150) := p_segment15;
  l_segment16                varchar2(150) := p_segment16;
  l_segment17                varchar2(150) := p_segment17;
  l_segment18                varchar2(150) := p_segment18;
  l_segment19                varchar2(150) := p_segment19;
  l_segment20                varchar2(150) := p_segment20;
  l_segment21                varchar2(150) := p_segment21;
  l_segment22                varchar2(150) := p_segment22;
  l_segment23                varchar2(150) := p_segment23;
  l_segment24                varchar2(150) := p_segment24;
  l_segment25                varchar2(150) := p_segment25;
  l_segment26                varchar2(150) := p_segment26;
  l_segment27                varchar2(150) := p_segment27;
  l_segment28                varchar2(150) := p_segment28;
  l_segment29                varchar2(150) := p_segment29;
  l_segment30                varchar2(150) := p_segment30;
  l_language_code             varchar2(30);
  --
  -- bug 2267635 new variable to indicate whether key flex id parameter
  -- enters the program with a value.
  --
  l_null_ind                 number(1)    := 0;
  --
  cursor csr_comp_struct
  is
  select competence_structure
  from per_business_groups
  where business_group_id = p_business_group_id;
  --
  -- bug 2267635 get per_competence_definition segment values where
  -- competence_definition_id is known
  --
  cursor c_segments is
     select segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment16,
            segment17,
            segment18,
            segment19,
            segment20,
            segment21,
            segment22,
            segment23,
            segment24,
            segment25,
            segment26,
            segment27,
            segment28,
            segment29,
            segment30
       from per_competence_definitions
      where competence_definition_id = l_competence_definition_id;
  --
  -- bug 2267635 get per_competence name value for cases when the user is using
  -- the api to insert the record directly and the comp def id is known
  -- and the name should be saved in per_competences but
  -- p_concat_segments has not been entered as a parameter
  --
  cursor c_name is
     select name
       from per_competences_vl
      where competence_definition_id = l_competence_definition_id;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 5);
  hr_utility.set_location(l_competence_definition_id,67);
  --
  -- Issue a savepoint.
  --
  if p_business_group_id is not null then
       hr_api.validate_bus_grp_id(p_business_group_id);
  end if;
  --
  savepoint create_competence;

   -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);

  hr_utility.set_location(l_proc, 6);
  -- ngundura global competence allowed only if cross business group
  -- profile is set
  if fnd_profile.value('HR_CROSS_BUSINESS_GROUP') <> 'Y'
  and p_business_group_id is null
  then
     fnd_message.set_name('PER','HR_52691_NO_GLOB_COMP');
     fnd_message.raise_error;
  end if;
  --
  if p_business_group_id is not null
  then
     open csr_comp_struct;
     fetch csr_comp_struct into l_flex_num;
     close csr_comp_struct;
     hr_utility.set_location(l_proc, 7);
  else
     l_flex_num := fnd_profile.value('HR_GLOBAL_COMPETENCE');
  end if;
  --
  if nvl(l_flex_num,hr_api.g_number) = hr_api.g_number
  then
     hr_utility.set_message(801,'HR_6035_ALL_INVALID_KEYFLEX');
     hr_utility.raise_error;
  end if;
  --
  if l_name is null and l_competence_definition_id is not null
  then
     hr_utility.set_location(l_proc, 13);
     open c_name;
        fetch c_name into
                     l_name;
     if c_name%NOTFOUND OR c_name%NOTFOUND IS NULL
     then
        l_name := NULL;
        hr_utility.set_location(l_proc, 14);
     end if;
     close c_name;
  end if;
  --
  if l_competence_definition_id is not null
  and l_name is not null
  --
  then
  --
     hr_utility.set_location(l_proc, 15);
     --
     -- set indicator to show p_competence_definition_id did not enter pgm null
     --
     l_null_ind := 1;
     --
     open c_segments;
        fetch c_segments into
                      l_segment1,
                      l_segment2,
                      l_segment3,
                      l_segment4,
                      l_segment5,
                      l_segment6,
                      l_segment7,
                      l_segment8,
                      l_segment9,
                      l_segment10,
                      l_segment11,
                      l_segment12,
                      l_segment13,
                      l_segment14,
                      l_segment15,
                      l_segment16,
                      l_segment17,
                      l_segment18,
                      l_segment19,
                      l_segment20,
                      l_segment21,
                      l_segment22,
                      l_segment23,
                      l_segment24,
                      l_segment25,
                      l_segment26,
                      l_segment27,
                      l_segment28,
                      l_segment29,
                      l_segment30;
     if c_segments%NOTFOUND OR c_segments%NOTFOUND IS NULL
     then
        l_competence_definition_id := NULL;
        l_null_ind := 0;
        hr_utility.set_location(l_proc, 17);
     end if;
     close c_segments;
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
	hr_competences_bk1.create_competence_b	(
         p_effective_date               =>     p_effective_date,
         p_business_group_id            =>     p_business_group_id,
         p_competence_alias             =>     p_competence_alias,
         p_description                  =>     p_description,
         p_date_from                    =>     trunc(p_date_from),
         p_date_to                      =>     trunc(p_date_to),
         p_behavioural_indicator        =>     p_behavioural_indicator,
         p_certification_required       =>     p_certification_required,
         p_evaluation_method            =>     p_evaluation_method,
         p_renewal_period_frequency     =>     p_renewal_period_frequency,
         p_renewal_period_units         =>     p_renewal_period_units,
         p_rating_scale_id              =>     p_rating_scale_id,
         p_attribute_category           =>     p_attribute_category,
         p_attribute1                   =>     p_attribute1,
         p_attribute2                   =>     p_attribute2,
         p_attribute3                   =>     p_attribute3,
         p_attribute4                   =>     p_attribute4,
         p_attribute5                   =>     p_attribute5,
         p_attribute6                   =>     p_attribute6,
         p_attribute7                   =>     p_attribute7,
         p_attribute8                   =>     p_attribute8,
         p_attribute9                   =>     p_attribute9,
         p_attribute10                  =>     p_attribute10,
         p_attribute11                  =>     p_attribute11,
         p_attribute12                  =>     p_attribute12,
         p_attribute13                  =>     p_attribute13,
         p_attribute14                  =>     p_attribute14,
         p_attribute15                  =>     p_attribute15,
         p_attribute16                  =>     p_attribute16,
         p_attribute17                  =>     p_attribute17,
         p_attribute18                  =>     p_attribute18,
         p_attribute19                  =>     p_attribute19,
         p_attribute20                  =>     p_attribute20,
         p_segment1                     =>     l_segment1,
         p_segment2                     =>     l_segment2,
         p_segment3                     =>     l_segment3,
         p_segment4                     =>     l_segment4,
         p_segment5                     =>     l_segment5,
         p_segment6                     =>     l_segment6,
         p_segment7                     =>     l_segment7,
         p_segment8                     =>     l_segment8,
         p_segment9                     =>     l_segment9,
         p_segment10                    =>     l_segment10,
         p_segment11                    =>     l_segment11,
         p_segment12                    =>     l_segment12,
         p_segment13                    =>     l_segment13,
         p_segment14                    =>     l_segment14,
         p_segment15                    =>     l_segment15,
         p_segment16                    =>     l_segment16,
         p_segment17                    =>     l_segment17,
         p_segment18                    =>     l_segment18,
         p_segment19                    =>     l_segment19,
         p_segment20                    =>     l_segment20,
         p_segment21                    =>     l_segment21,
         p_segment22                    =>     l_segment22,
         p_segment23                    =>     l_segment23,
         p_segment24                    =>     l_segment24,
         p_segment25                    =>     l_segment25,
         p_segment26                    =>     l_segment26,
         p_segment27                    =>     l_segment27,
         p_segment28                    =>     l_segment28,
         p_segment29                    =>     l_segment29,
         p_segment30                    =>     l_segment30,
         p_concat_segments              =>     p_concat_segments,
         p_language_code                =>     l_language_code,
         p_competence_cluster           =>     p_competence_cluster,
         p_unit_standard_id             =>     p_unit_standard_id ,
         p_credit_type                  =>     p_credit_type,
         p_credits                      =>     p_credits,
         p_level_type                   =>     p_level_type,
         p_level_number                 =>     p_level_number,
         p_field                        =>     p_field,
         p_sub_field                    =>     p_sub_field,
         p_provider                     =>     p_provider,
         p_qa_organization              =>     p_qa_organization,
         p_information_category         =>     p_information_category,
         p_information1                 =>     p_information1,
         p_information2                 =>     p_information2,
         p_information3                 =>     p_information3,
         p_information4                 =>     p_information4,
         p_information5                 =>     p_information5,
         p_information6                 =>     p_information6,
         p_information7                 =>     p_information7,
         p_information8                 =>     p_information8,
         p_information9                 =>     p_information9,
         p_information10                =>     p_information10,
         p_information11                =>     p_information11,
         p_information12                =>     p_information12,
         p_information13                =>     p_information13,
         p_information14                =>     p_information14,
         p_information15                =>     p_information15,
         p_information16                =>     p_information16,
         p_information17                =>     p_information17,
         p_information18                =>     p_information18,
         p_information19                =>     p_information19,
         p_information20                =>     p_information20
    );
    hr_utility.set_location('hr_competences_bk1.create_competence_b',999);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_competence',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call create_competence
  --
  -- Validation in addition to Table Handlers
  --
  if l_competence_definition_id is null
  or l_name is null
  then
     l_null_ind := 0;
     --
     hr_utility.set_location(l_proc, 7);
     --
     --  Determine the competence defintion by calling ins_or_sel
     --
     hr_kflex_utility.ins_or_sel_keyflex_comb
      (p_appl_short_name	      => 'PER'
      ,p_flex_code		      => 'CMP'
      ,p_flex_num                     => l_flex_num
      ,p_segment1                     => l_segment1
      ,p_segment2                     => l_segment2
      ,p_segment3                     => l_segment3
      ,p_segment4                     => l_segment4
      ,p_segment5                     => l_segment5
      ,p_segment6                     => l_segment6
      ,p_segment7                     => l_segment7
      ,p_segment8                     => l_segment8
      ,p_segment9                     => l_segment9
      ,p_segment10                    => l_segment10
      ,p_segment11                    => l_segment11
      ,p_segment12                    => l_segment12
      ,p_segment13                    => l_segment13
      ,p_segment14                    => l_segment14
      ,p_segment15                    => l_segment15
      ,p_segment16                    => l_segment16
      ,p_segment17                    => l_segment17
      ,p_segment18                    => l_segment18
      ,p_segment19                    => l_segment19
      ,p_segment20                    => l_segment20
      ,p_segment21                    => l_segment21
      ,p_segment22                    => l_segment22
      ,p_segment23                    => l_segment23
      ,p_segment24                    => l_segment24
      ,p_segment25                    => l_segment25
      ,p_segment26                    => l_segment26
      ,p_segment27                    => l_segment27
      ,p_segment28                    => l_segment28
      ,p_segment29                    => l_segment29
      ,p_segment30                    => l_segment30
      ,p_concat_segments_in           => p_concat_segments
      ,p_ccid		              => l_competence_definition_id
      ,p_concat_segments_out          => l_name
      );
  end if;
  --
  --
  -- Process Logic
  --
  per_cpn_ins.ins
 (p_validate                     =>     p_validate,
  p_effective_date               =>     p_effective_date,
  p_name                         =>     l_name,
  p_business_group_id            =>     p_business_group_id,
  p_description                  =>     p_description,
  p_date_from                    =>     trunc(p_date_from),
  p_date_to                      =>     trunc(p_date_to),
  p_behavioural_indicator        =>     p_behavioural_indicator,
  p_certification_required       =>     p_certification_required,
  p_evaluation_method            =>     p_evaluation_method,
  p_renewal_period_frequency     =>     p_renewal_period_frequency,
  p_renewal_period_units         =>     p_renewal_period_units,
  p_rating_scale_id              =>     p_rating_scale_id,
  p_attribute_category           =>     p_attribute_category,
  p_attribute1                   =>     p_attribute1,
  p_attribute2                   =>     p_attribute2,
  p_attribute3                   =>     p_attribute3,
  p_attribute4                   =>     p_attribute4,
  p_attribute5                   =>     p_attribute5,
  p_attribute6                   =>     p_attribute6,
  p_attribute7                   =>     p_attribute7,
  p_attribute8                   =>     p_attribute8,
  p_attribute9                   =>     p_attribute9,
  p_attribute10                  =>     p_attribute10,
  p_attribute11                  =>     p_attribute11,
  p_attribute12                  =>     p_attribute12,
  p_attribute13                  =>     p_attribute13,
  p_attribute14                  =>     p_attribute14,
  p_attribute15                  =>     p_attribute15,
  p_attribute16                  =>     p_attribute16,
  p_attribute17                  =>     p_attribute17,
  p_attribute18                  =>     p_attribute18,
  p_attribute19                  =>     p_attribute19,
  p_attribute20                  =>     p_attribute20,
  p_competence_definition_id     =>     l_competence_definition_id,
  p_competence_id                =>	l_competence_id,
  p_object_version_number        =>	l_object_version_number,
  p_competence_alias	         =>     p_competence_alias,
  p_competence_cluster           =>     p_competence_cluster,
  p_unit_standard_id             =>     p_unit_standard_id ,
  p_credit_type                  =>     p_credit_type,
  p_credits                      =>     p_credits,
  p_level_type                   =>     p_level_type,
  p_level_number                 =>     p_level_number,
  p_field                        =>     p_field,
  p_sub_field                    =>     p_sub_field,
  p_provider                     =>     p_provider,
  p_qa_organization              =>     p_qa_organization,
  p_information_category         =>     p_information_category,
  p_information1                 =>     p_information1,
  p_information2                 =>     p_information2,
  p_information3                 =>     p_information3,
  p_information4                 =>     p_information4,
  p_information5                 =>     p_information5,
  p_information6                 =>     p_information6,
  p_information7                 =>     p_information7,
  p_information8                 =>     p_information8,
  p_information9                 =>     p_information9,
  p_information10                =>     p_information10,
  p_information11                =>     p_information11,
  p_information12                =>     p_information12,
  p_information13                =>     p_information13,
  p_information14                =>     p_information14,
  p_information15                =>     p_information15,
  p_information16                =>     p_information16,
  p_information17                =>     p_information17,
  p_information18                =>     p_information18,
  p_information19                =>     p_information19,
  p_information20                =>     p_information20
  );
  --
  hr_utility.set_location(l_proc, 8);

  --
  -- MLS Processing
  --
  --
  per_cpl_ins.ins_tl
  (p_effective_date               => p_effective_date
  ,p_language_code                => l_language_code
  ,p_competence_id                => l_competence_id
  ,p_name                         => l_name
  ,p_competence_alias             => p_competence_alias
  ,p_behavioural_indicator        => p_behavioural_indicator
  ,p_description                  => p_description
  );
  -- Call After Process User Hook
  --
  begin
	hr_competences_bk1.create_competence_a	(
         p_competence_id                =>     l_competence_id,
         p_object_version_number        =>     l_object_version_number,
         p_effective_date               =>     p_effective_date,
         p_name                         =>     l_name,
         p_business_group_id            =>     p_business_group_id,
         p_competence_alias             =>     p_competence_alias,
         p_description                  =>     p_description,
         p_date_from                    =>     trunc(p_date_from),
         p_date_to                      =>     trunc(p_date_to),
         p_behavioural_indicator        =>     p_behavioural_indicator,
         p_certification_required       =>     p_certification_required,
         p_evaluation_method            =>     p_evaluation_method,
         p_renewal_period_frequency     =>     p_renewal_period_frequency,
         p_renewal_period_units         =>     p_renewal_period_units,
         p_rating_scale_id              =>     p_rating_scale_id,
         p_attribute_category           =>     p_attribute_category,
         p_attribute1                   =>     p_attribute1,
         p_attribute2                   =>     p_attribute2,
         p_attribute3                   =>     p_attribute3,
         p_attribute4                   =>     p_attribute4,
         p_attribute5                   =>     p_attribute5,
         p_attribute6                   =>     p_attribute6,
         p_attribute7                   =>     p_attribute7,
         p_attribute8                   =>     p_attribute8,
         p_attribute9                   =>     p_attribute9,
         p_attribute10                  =>     p_attribute10,
         p_attribute11                  =>     p_attribute11,
         p_attribute12                  =>     p_attribute12,
         p_attribute13                  =>     p_attribute13,
         p_attribute14                  =>     p_attribute14,
         p_attribute15                  =>     p_attribute15,
         p_attribute16                  =>     p_attribute16,
         p_attribute17                  =>     p_attribute17,
         p_attribute18                  =>     p_attribute18,
         p_attribute19                  =>     p_attribute19,
         p_attribute20                  =>     p_attribute20
         ,p_segment1                      => l_segment1
         ,p_segment2                      => l_segment2
         ,p_segment3                      => l_segment3
         ,p_segment4                      => l_segment4
         ,p_segment5                      => l_segment5
         ,p_segment6                      => l_segment6
         ,p_segment7                      => l_segment7
         ,p_segment8                      => l_segment8
         ,p_segment9                      => l_segment9
         ,p_segment10                     => l_segment10
         ,p_segment11                     => l_segment11
         ,p_segment12                     => l_segment12
         ,p_segment13                     => l_segment13
         ,p_segment14                     => l_segment14
         ,p_segment15                     => l_segment15
         ,p_segment16                     => l_segment16
         ,p_segment17                     => l_segment17
         ,p_segment18                     => l_segment18
         ,p_segment19                     => l_segment19
         ,p_segment20                     => l_segment20
         ,p_segment21                     => l_segment21
         ,p_segment22                     => l_segment22
         ,p_segment23                     => l_segment23
         ,p_segment24                     => l_segment24
         ,p_segment25                     => l_segment25
         ,p_segment26                     => l_segment26
         ,p_segment27                     => l_segment27
         ,p_segment28                     => l_segment28
         ,p_segment29                     => l_segment29
         ,p_segment30                     => l_segment30
         ,p_concat_segments               => p_concat_segments
         ,p_competence_definition_id      => l_competence_definition_id
         ,p_language_code                 => l_language_code
         ,p_competence_cluster           =>     p_competence_cluster
         ,p_unit_standard_id             =>     p_unit_standard_id
         ,p_credit_type                  =>     p_credit_type
         ,p_credits                      =>     p_credits
         ,p_level_type                   =>     p_level_type
         ,p_level_number                 =>     p_level_number
         ,p_field                        =>     p_field
         ,p_sub_field                    =>     p_sub_field
         ,p_provider                     =>     p_provider
         ,p_qa_organization              =>     p_qa_organization
         ,p_information_category         =>     p_information_category
         ,p_information1                 =>     p_information1
         ,p_information2                 =>     p_information2
         ,p_information3                 =>     p_information3
         ,p_information4                 =>     p_information4
         ,p_information5                 =>     p_information5
         ,p_information6                 =>     p_information6
         ,p_information7                 =>     p_information7
         ,p_information8                 =>     p_information8
         ,p_information9                 =>     p_information9
         ,p_information10                =>     p_information10
         ,p_information11                =>     p_information11
         ,p_information12                =>     p_information12
         ,p_information13                =>     p_information13
         ,p_information14                =>     p_information14
         ,p_information15                =>     p_information15
         ,p_information16                =>     p_information16
         ,p_information17                =>     p_information17
         ,p_information18                =>     p_information18
         ,p_information19                =>     p_information19
         ,p_information20                =>     p_information20
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_competence',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After process user hook create_competence
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_competence_id            := l_competence_id;
  p_object_version_number    := l_object_version_number;
  p_competence_definition_id := l_competence_definition_id;
  p_name                     := l_name;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_competence;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_competence_id                 := null;
    p_object_version_number         := null;
    p_name                          := null;
    if l_null_ind = 0
    then
        p_competence_definition_id  := null;
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO create_competence;
    --
    -- set in out parameters and set out parameters
    --
     p_competence_definition_id  := l_competence_definition_id;
     p_competence_id                 := null;
    p_object_version_number         := null;
    p_name                          := null;
    --
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end create_competence;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <update_competence> >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure update_competence
 (p_validate                     in boolean	default false,
  p_effective_date               in date,
  p_competence_id                in number,
  p_object_version_number        in out nocopy number,
  p_language_code                in     varchar2 default hr_api.userenv_lang,
  p_name                         out nocopy varchar2 ,
  p_description                  in varchar2    default hr_api.g_varchar2,
  p_date_from                    in date        default hr_api.g_date,
  p_date_to                      in date        default hr_api.g_date,
  p_behavioural_indicator        in varchar2    default hr_api.g_varchar2,
  p_certification_required       in varchar2    default hr_api.g_varchar2,
  p_evaluation_method            in varchar2    default hr_api.g_varchar2,
  p_renewal_period_frequency     in number      default hr_api.g_number,
  p_renewal_period_units         in varchar2    default hr_api.g_varchar2,
  p_rating_scale_id              in number      default hr_api.g_number,
  p_attribute_category           in varchar2    default hr_api.g_varchar2,
  p_attribute1                   in varchar2    default hr_api.g_varchar2,
  p_attribute2                   in varchar2    default hr_api.g_varchar2,
  p_attribute3                   in varchar2    default hr_api.g_varchar2,
  p_attribute4                   in varchar2    default hr_api.g_varchar2,
  p_attribute5                   in varchar2    default hr_api.g_varchar2,
  p_attribute6                   in varchar2    default hr_api.g_varchar2,
  p_attribute7                   in varchar2    default hr_api.g_varchar2,
  p_attribute8                   in varchar2    default hr_api.g_varchar2,
  p_attribute9                   in varchar2    default hr_api.g_varchar2,
  p_attribute10                  in varchar2    default hr_api.g_varchar2,
  p_attribute11                  in varchar2    default hr_api.g_varchar2,
  p_attribute12                  in varchar2    default hr_api.g_varchar2,
  p_attribute13                  in varchar2    default hr_api.g_varchar2,
  p_attribute14                  in varchar2    default hr_api.g_varchar2,
  p_attribute15                  in varchar2    default hr_api.g_varchar2,
  p_attribute16                  in varchar2    default hr_api.g_varchar2,
  p_attribute17                  in varchar2    default hr_api.g_varchar2,
  p_attribute18                  in varchar2    default hr_api.g_varchar2,
  p_attribute19                  in varchar2    default hr_api.g_varchar2,
  p_attribute20                  in varchar2    default hr_api.g_varchar2,
  p_competence_alias             in varchar2    default hr_api.g_varchar2,
  p_segment1                     in     varchar2 default hr_api.g_varchar2,
  p_segment2                     in     varchar2 default hr_api.g_varchar2,
  p_segment3                     in     varchar2 default hr_api.g_varchar2,
  p_segment4                     in     varchar2 default hr_api.g_varchar2,
  p_segment5                     in     varchar2 default hr_api.g_varchar2,
  p_segment6                     in     varchar2 default hr_api.g_varchar2,
  p_segment7                     in     varchar2 default hr_api.g_varchar2,
  p_segment8                     in     varchar2 default hr_api.g_varchar2,
  p_segment9                     in     varchar2 default hr_api.g_varchar2,
  p_segment10                    in     varchar2 default hr_api.g_varchar2,
  p_segment11                    in     varchar2 default hr_api.g_varchar2,
  p_segment12                    in     varchar2 default hr_api.g_varchar2,
  p_segment13                    in     varchar2 default hr_api.g_varchar2,
  p_segment14                    in     varchar2 default hr_api.g_varchar2,
  p_segment15                    in     varchar2 default hr_api.g_varchar2,
  p_segment16                    in     varchar2 default hr_api.g_varchar2,
  p_segment17                    in     varchar2 default hr_api.g_varchar2,
  p_segment18                    in     varchar2 default hr_api.g_varchar2,
  p_segment19                    in     varchar2 default hr_api.g_varchar2,
  p_segment20                    in     varchar2 default hr_api.g_varchar2,
  p_segment21                    in     varchar2 default hr_api.g_varchar2,
  p_segment22                    in     varchar2 default hr_api.g_varchar2,
  p_segment23                    in     varchar2 default hr_api.g_varchar2,
  p_segment24                    in     varchar2 default hr_api.g_varchar2,
  p_segment25                    in     varchar2 default hr_api.g_varchar2,
  p_segment26                    in     varchar2 default hr_api.g_varchar2,
  p_segment27                    in     varchar2 default hr_api.g_varchar2,
  p_segment28                    in     varchar2 default hr_api.g_varchar2,
  p_segment29                    in     varchar2 default hr_api.g_varchar2,
  p_segment30                    in     varchar2 default hr_api.g_varchar2,
  p_concat_segments              in     varchar2 default hr_api.g_varchar2,
  --
  -- bug 2267635 change p_competence_definition_id from an out to an in/out
  -- parameter to enable value to be passed into program when known and required
  --
  p_competence_definition_id  in out nocopy    number
 --
 -- BUG3356369 Added unit standard qualification framework
 --
 ,p_competence_cluster           in varchar2         default hr_api.g_varchar2
 ,p_unit_standard_id             in varchar2         default hr_api.g_varchar2
 ,p_credit_type                  in varchar2         default hr_api.g_varchar2
 ,p_credits                      in number           default hr_api.g_number
 ,p_level_type                   in varchar2         default hr_api.g_varchar2
 ,p_level_number                 in number           default hr_api.g_number
 ,p_field                        in varchar2         default hr_api.g_varchar2
 ,p_sub_field                    in varchar2         default hr_api.g_varchar2
 ,p_provider                     in varchar2         default hr_api.g_varchar2
 ,p_qa_organization              in varchar2         default hr_api.g_varchar2
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
  ) is
  --
  -- Declare cursors and local variables
  --
  -- bug 2267635 initialize l_competence_definition_id and segmnt variables with
  -- values where these are passed into program.
  --
  l_proc                       varchar2(72) := g_package||'update_competence';
  l_object_version_number      per_competences.object_version_number%TYPE;
  l_ovn      per_competences.object_version_number%TYPE := p_object_version_number;
  l_competence_definition_id   per_competence_definitions.competence_definition_id%TYPE := p_competence_definition_id;
  l_comp_def_id   per_competence_definitions.competence_definition_id%TYPE := p_competence_definition_id;
  l_flex_num                   per_competence_definitions.id_flex_num%TYPE;
  l_name                       varchar2(700);   -- bug#2925181
  l_api_updating               boolean;
  l_segment1                   varchar2(150) := p_segment1;
  l_segment2                   varchar2(150) := p_segment2;
  l_segment3                   varchar2(150) := p_segment3;
  l_segment4                   varchar2(150) := p_segment4;
  l_segment5                   varchar2(150) := p_segment5;
  l_segment6                   varchar2(150) := p_segment6;
  l_segment7                   varchar2(150) := p_segment7;
  l_segment8                   varchar2(150) := p_segment8;
  l_segment9                   varchar2(150) := p_segment9;
  l_segment10                  varchar2(150) := p_segment10;
  l_segment11                  varchar2(150) := p_segment11;
  l_segment12                  varchar2(150) := p_segment12;
  l_segment13                  varchar2(150) := p_segment13;
  l_segment14                  varchar2(150) := p_segment14;
  l_segment15                  varchar2(150) := p_segment15;
  l_segment16                  varchar2(150) := p_segment16;
  l_segment17                  varchar2(150) := p_segment17;
  l_segment18                  varchar2(150) := p_segment18;
  l_segment19                  varchar2(150) := p_segment19;
  l_segment20                  varchar2(150) := p_segment20;
  l_segment21                  varchar2(150) := p_segment21;
  l_segment22                  varchar2(150) := p_segment22;
  l_segment23                  varchar2(150) := p_segment23;
  l_segment24                  varchar2(150) := p_segment24;
  l_segment25                  varchar2(150) := p_segment25;
  l_segment26                  varchar2(150) := p_segment26;
  l_segment27                  varchar2(150) := p_segment27;
  l_segment28                  varchar2(150) := p_segment28;
  l_segment29                  varchar2(150) := p_segment29;
  l_segment30                  varchar2(150) := p_segment30;
  l_null_ind                   number(1)    := 0;
  l_language_code              varchar2(30);
  --
  cursor csr_idsel is
     select cmp.id_flex_num
     from per_competence_definitions cmp
     where cmp.competence_definition_id = l_competence_definition_id;
  --
  --
  -- bug 2267635 get per_competence_definition segment values where
  -- competence_definition_id is known
  --
  cursor c_segments is
    select segment1,
           segment2,
           segment3,
           segment4,
           segment5,
           segment6,
           segment7,
           segment8,
           segment9,
           segment10,
           segment11,
           segment12,
           segment13,
           segment14,
           segment15,
           segment16,
           segment17,
           segment18,
           segment19,
           segment20,
           segment21,
           segment22,
           segment23,
           segment24,
           segment25,
           segment26,
           segment27,
           segment28,
           segment29,
           segment30
      from per_competence_definitions
     where competence_definition_id = l_competence_definition_id;
  --
  -- bug 2267635 get per_competence name value for when updating by api
  -- and comp def id is known, name should be in per_competences and
  -- p_concat_segments has not entered as a param
  --
  cursor c_name is
     select name
       from per_competences_vl
      where competence_definition_id = l_competence_definition_id;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_competence;
  hr_utility.set_location(l_proc, 6);
  hr_utility.set_location(l_competence_definition_id,69);
  hr_utility.set_location(substr(l_name,1,128),691);   --bug#2925181
  --
  if l_name is null and l_competence_definition_id is not null
  then
     hr_utility.set_location(l_proc, 13);
     open c_name;
        fetch c_name into
                     l_name;
     if c_name%NOTFOUND OR c_name%NOTFOUND IS NULL
     then
        l_name := NULL;
        hr_utility.set_location(l_proc, 14);
     end if;
     close c_name;
  end if;
  --
  if l_competence_definition_id is not null
  and l_name is not null
  then
     -- 2267635
     -- get segment values if p_competence_definition_id entered with a value
     -- set indicator to show p_competence_definition_id did not enter pgm null
     --
     l_null_ind := 1;
     --
     open c_segments;
        fetch c_segments into
                      l_segment1,
                      l_segment2,
                      l_segment3,
                      l_segment4,
                      l_segment5,
                      l_segment6,
                      l_segment7,
                      l_segment8,
                      l_segment9,
                      l_segment10,
                      l_segment11,
                      l_segment12,
                      l_segment13,
                      l_segment14,
                      l_segment15,
                      l_segment16,
                      l_segment17,
                      l_segment18,
                      l_segment19,
                      l_segment20,
                      l_segment21,
                      l_segment22,
                      l_segment23,
                      l_segment24,
                      l_segment25,
                      l_segment26,
                      l_segment27,
                      l_segment28,
                      l_segment29,
                      l_segment30;
     if c_segments%NOTFOUND OR c_segments%NOTFOUND IS NULL
     then
        l_competence_definition_id := NULL;
        l_null_ind := 0;
        hr_utility.set_location(l_proc, 24);
     end if;
     close c_segments;
     hr_utility.set_location(l_proc, 27);
     --
  end if;
  --

  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);

  -- Call Before Process User Hook
  --
  begin
	hr_competences_bk2.update_competence_b	(
         p_competence_id                =>     p_competence_id,
         p_object_version_number        =>     p_object_version_number,
         p_effective_date               =>     p_effective_date,
         p_description                  =>     p_description,
         p_date_from                    =>     trunc(p_date_from),
         p_date_to                      =>     trunc(p_date_to),
         p_behavioural_indicator        =>     p_behavioural_indicator,
         p_certification_required       =>     p_certification_required,
         p_evaluation_method            =>     p_evaluation_method,
         p_renewal_period_frequency     =>     p_renewal_period_frequency,
         p_renewal_period_units         =>     p_renewal_period_units,
         p_rating_scale_id              =>     p_rating_scale_id,
         p_attribute_category           =>     p_attribute_category,
         p_attribute1                   =>     p_attribute1,
         p_attribute2                   =>     p_attribute2,
         p_attribute3                   =>     p_attribute3,
         p_attribute4                   =>     p_attribute4,
         p_attribute5                   =>     p_attribute5,
         p_attribute6                   =>     p_attribute6,
         p_attribute7                   =>     p_attribute7,
         p_attribute8                   =>     p_attribute8,
         p_attribute9                   =>     p_attribute9,
         p_attribute10                  =>     p_attribute10,
         p_attribute11                  =>     p_attribute11,
         p_attribute12                  =>     p_attribute12,
         p_attribute13                  =>     p_attribute13,
         p_attribute14                  =>     p_attribute14,
         p_attribute15                  =>     p_attribute15,
         p_attribute16                  =>     p_attribute16,
         p_attribute17                  =>     p_attribute17,
         p_attribute18                  =>     p_attribute18,
         p_attribute19                  =>     p_attribute19,
         p_attribute20                  =>     p_attribute20,
         p_competence_alias             =>     p_competence_alias,
        p_segment1                      => l_segment1
       ,p_segment2                      => l_segment2
       ,p_segment3                      => l_segment3
       ,p_segment4                      => l_segment4
       ,p_segment5                      => l_segment5
       ,p_segment6                      => l_segment6
       ,p_segment7                      => l_segment7
       ,p_segment8                      => l_segment8
       ,p_segment9                      => l_segment9
       ,p_segment10                     => l_segment10
       ,p_segment11                     => l_segment11
       ,p_segment12                     => l_segment12
       ,p_segment13                     => l_segment13
       ,p_segment14                     => l_segment14
       ,p_segment15                     => l_segment15
       ,p_segment16                     => l_segment16
       ,p_segment17                     => l_segment17
       ,p_segment18                     => l_segment18
       ,p_segment19                     => l_segment19
       ,p_segment20                     => l_segment20
       ,p_segment21                     => l_segment21
       ,p_segment22                     => l_segment22
       ,p_segment23                     => l_segment23
       ,p_segment24                     => l_segment24
       ,p_segment25                     => l_segment25
       ,p_segment26                     => l_segment26
       ,p_segment27                     => l_segment27
       ,p_segment28                     => l_segment28
       ,p_segment29                     => l_segment29
       ,p_segment30                     => l_segment30
       ,p_concat_segments               => p_concat_segments
       ,p_language_code                 => l_language_code
       ,p_competence_cluster           =>     p_competence_cluster
       ,p_unit_standard_id             =>     p_unit_standard_id
       ,p_credit_type                  =>     p_credit_type
       ,p_credits                      =>     p_credits
       ,p_level_type                   =>     p_level_type
       ,p_level_number                 =>     p_level_number
       ,p_field                        =>     p_field
       ,p_sub_field                    =>     p_sub_field
       ,p_provider                     =>     p_provider
       ,p_qa_organization              =>     p_qa_organization
       ,p_information_category         =>     p_information_category
       ,p_information1                 =>     p_information1
       ,p_information2                 =>     p_information2
       ,p_information3                 =>     p_information3
       ,p_information4                 =>     p_information4
       ,p_information5                 =>     p_information5
       ,p_information6                 =>     p_information6
       ,p_information7                 =>     p_information7
       ,p_information8                 =>     p_information8
       ,p_information9                 =>     p_information9
       ,p_information10                =>     p_information10
       ,p_information11                =>     p_information11
       ,p_information12                =>     p_information12
       ,p_information13                =>     p_information13
       ,p_information14                =>     p_information14
       ,p_information15                =>     p_information15
       ,p_information16                =>     p_information16
       ,p_information17                =>     p_information17
       ,p_information18                =>     p_information18
       ,p_information19                =>     p_information19
       ,p_information20                =>     p_information20
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_competence',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  -- Validation in addition to Table Handlers
  --
  --
  -- Retrieve current competence details
  --
  l_api_updating := per_cpn_shd.api_updating
     (p_competence_id           => p_competence_id
     ,p_object_version_number   => p_object_version_number);
  --
  hr_utility.set_location(p_concat_segments, 692);
  hr_utility.set_location(substr(l_name,1,128), 692); --bug#2925181
  hr_utility.set_location(l_proc, 7);
  --
  if not l_api_updating
  then
     hr_utility.set_location(l_proc, 8);
     --
     -- As this an updating API, the competence should already exist.
     --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  else
--
     hr_utility.set_location(l_proc, 9);
     if l_competence_definition_id is null
     then
        l_null_ind := 0;
        l_competence_definition_id
        := per_cpn_shd.g_old_rec.competence_definition_id;
     end if;
  end if;
  --
  open csr_idsel;
  fetch csr_idsel
  into l_flex_num;
    if csr_idsel%NOTFOUND then
       close csr_idsel;
       fnd_message.set_name('PER','HR_52733_INVALID_CODE_COMB');
       fnd_message.raise_error;
     end if;
  close csr_idsel;
  --
  -- 2267635
  -- update competence definitions in per_competence_definitions if
  -- p_competence_definition_id had no value when passed into program
  -- no value when passed into program or if l_name has no value.
  --
  --
  hr_utility.set_location(l_null_ind, 693);
  if l_null_ind = 0
  or l_name is null
  then
     --
     hr_kflex_utility.upd_or_sel_keyflex_comb
       (p_appl_short_name      => 'PER'
       ,p_flex_code            => 'CMP'
       ,p_flex_num             => l_flex_num
       ,p_segment1             => l_segment1
       ,p_segment2             => l_segment2
       ,p_segment3             => l_segment3
       ,p_segment4             => l_segment4
       ,p_segment5             => l_segment5
       ,p_segment6             => l_segment6
       ,p_segment7             => l_segment7
       ,p_segment8             => l_segment8
       ,p_segment9             => l_segment9
       ,p_segment10            => l_segment10
       ,p_segment11            => l_segment11
       ,p_segment12            => l_segment12
       ,p_segment13            => l_segment13
       ,p_segment14            => l_segment14
       ,p_segment15            => l_segment15
       ,p_segment16            => l_segment16
       ,p_segment17            => l_segment17
       ,p_segment18            => l_segment18
       ,p_segment19            => l_segment19
       ,p_segment20            => l_segment20
       ,p_segment21            => l_segment21
       ,p_segment22            => l_segment22
       ,p_segment23            => l_segment23
       ,p_segment24            => l_segment24
       ,p_segment25            => l_segment25
       ,p_segment26            => l_segment26
       ,p_segment27            => l_segment27
       ,p_segment28            => l_segment28
       ,p_segment29            => l_segment29
       ,p_segment30            => l_segment30
       ,p_concat_segments_in   => p_concat_segments
       ,p_ccid                 => l_competence_definition_id
       ,p_concat_segments_out  => l_name
       );
     --
     hr_utility.set_location(l_proc, 10);
  end if;
  hr_utility.set_location(p_concat_segments, 6931);
  hr_utility.set_location(substr(l_name,1,128), 6932);   --bug#2925181
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  per_cpn_upd.upd
 (p_validate                     =>     p_validate,
  p_effective_date               =>     p_effective_date,
  p_competence_id                =>     p_competence_id,
  p_object_version_number        =>     l_object_version_number,
  p_name                         =>     l_name,
  p_description                  =>     p_description,
  p_date_from                    =>     trunc(p_date_from),
  p_date_to                      =>     trunc(p_date_to),
  p_behavioural_indicator        =>     p_behavioural_indicator,
  p_certification_required       =>     p_certification_required,
  p_evaluation_method            =>     p_evaluation_method,
  p_renewal_period_frequency     =>     p_renewal_period_frequency,
  p_renewal_period_units         =>     p_renewal_period_units,
  p_rating_scale_id              =>     p_rating_scale_id,
  p_attribute_category           =>     p_attribute_category,
  p_attribute1                   =>     p_attribute1,
  p_attribute2                   =>     p_attribute2,
  p_attribute3                   =>     p_attribute3,
  p_attribute4                   =>     p_attribute4,
  p_attribute5                   =>     p_attribute5,
  p_attribute6                   =>     p_attribute6,
  p_attribute7                   =>     p_attribute7,
  p_attribute8                   =>     p_attribute8,
  p_attribute9                   =>     p_attribute9,
  p_attribute10                  =>     p_attribute10,
  p_attribute11                  =>     p_attribute11,
  p_attribute12                  =>     p_attribute12,
  p_attribute13                  =>     p_attribute13,
  p_attribute14                  =>     p_attribute14,
  p_attribute15                  =>     p_attribute15,
  p_attribute16                  =>     p_attribute16,
  p_attribute17                  =>     p_attribute17,
  p_attribute18                  =>     p_attribute18,
  p_attribute19                  =>     p_attribute19,
  p_attribute20                  =>     p_attribute20,
  p_competence_alias             =>     p_competence_alias,
  p_competence_definition_id     =>     l_competence_definition_id,
  p_competence_cluster           =>     p_competence_cluster,
  p_unit_standard_id             =>     p_unit_standard_id ,
  p_credit_type                  =>     p_credit_type,
  p_credits                      =>     p_credits,
  p_level_type                   =>     p_level_type,
  p_level_number                 =>     p_level_number,
  p_field                        =>     p_field,
  p_sub_field                    =>     p_sub_field,
  p_provider                     =>     p_provider,
  p_qa_organization              =>     p_qa_organization,
  p_information_category         =>     p_information_category,
  p_information1                 =>     p_information1,
  p_information2                 =>     p_information2,
  p_information3                 =>     p_information3,
  p_information4                 =>     p_information4,
  p_information5                 =>     p_information5,
  p_information6                 =>     p_information6,
  p_information7                 =>     p_information7,
  p_information8                 =>     p_information8,
  p_information9                 =>     p_information9,
  p_information10                =>     p_information10,
  p_information11                =>     p_information11,
  p_information12                =>     p_information12,
  p_information13                =>     p_information13,
  p_information14                =>     p_information14,
  p_information15                =>     p_information15,
  p_information16                =>     p_information16,
  p_information17                =>     p_information17,
  p_information18                =>     p_information18,
  p_information19                =>     p_information19,
  p_information20                =>     p_information20
  );
  --
  --
  hr_utility.set_location(l_proc, 11);
  --
  -- MLS Processing
  --
  --
  per_cpl_upd.upd_tl
  (p_effective_date               => p_effective_date
  ,p_language_code                => l_language_code
  ,p_competence_id                => p_competence_id
  ,p_name                         => l_name
  ,p_competence_alias             => p_competence_alias
  ,p_behavioural_indicator        => p_behavioural_indicator
  ,p_description                  => p_description
  );
  --
  -- Call After Process User Hook
  --
  begin
	hr_competences_bk2.update_competence_a	(
         p_competence_id                =>     p_competence_id,
         p_object_version_number        =>     l_object_version_number,
         p_effective_date               =>     p_effective_date,
         p_name                         =>     l_name,
         p_description                  =>     p_description,
         p_date_from                    =>     trunc(p_date_from),
         p_date_to                      =>     trunc(p_date_to),
         p_behavioural_indicator        =>     p_behavioural_indicator,
         p_certification_required       =>     p_certification_required,
         p_evaluation_method            =>     p_evaluation_method,
         p_renewal_period_frequency     =>     p_renewal_period_frequency,
         p_renewal_period_units         =>     p_renewal_period_units,
         p_rating_scale_id              =>     p_rating_scale_id,
         p_attribute_category           =>     p_attribute_category,
         p_attribute1                   =>     p_attribute1,
         p_attribute2                   =>     p_attribute2,
         p_attribute3                   =>     p_attribute3,
         p_attribute4                   =>     p_attribute4,
         p_attribute5                   =>     p_attribute5,
         p_attribute6                   =>     p_attribute6,
         p_attribute7                   =>     p_attribute7,
         p_attribute8                   =>     p_attribute8,
         p_attribute9                   =>     p_attribute9,
         p_attribute10                  =>     p_attribute10,
         p_attribute11                  =>     p_attribute11,
         p_attribute12                  =>     p_attribute12,
         p_attribute13                  =>     p_attribute13,
         p_attribute14                  =>     p_attribute14,
         p_attribute15                  =>     p_attribute15,
         p_attribute16                  =>     p_attribute16,
         p_attribute17                  =>     p_attribute17,
         p_attribute18                  =>     p_attribute18,
         p_attribute19                  =>     p_attribute19,
         p_attribute20                  =>     p_attribute20,
         p_competence_alias             =>     p_competence_alias,
         p_segment1                     => l_segment1
        ,p_segment2                      => l_segment2
        ,p_segment3                      => l_segment3
        ,p_segment4                      => l_segment4
        ,p_segment5                      => l_segment5
        ,p_segment6                      => l_segment6
        ,p_segment7                      => l_segment7
        ,p_segment8                      => l_segment8
        ,p_segment9                      => l_segment9
        ,p_segment10                     => l_segment10
        ,p_segment11                     => l_segment11
        ,p_segment12                     => l_segment12
        ,p_segment13                     => l_segment13
        ,p_segment14                     => l_segment14
        ,p_segment15                     => l_segment15
        ,p_segment16                     => l_segment16
        ,p_segment17                     => l_segment17
        ,p_segment18                     => l_segment18
        ,p_segment19                     => l_segment19
        ,p_segment20                     => l_segment20
        ,p_segment21                     => l_segment21
        ,p_segment22                     => l_segment22
        ,p_segment23                     => l_segment23
        ,p_segment24                     => l_segment24
        ,p_segment25                     => l_segment25
        ,p_segment26                     => l_segment26
        ,p_segment27                     => l_segment27
        ,p_segment28                     => l_segment28
        ,p_segment29                     => l_segment29
        ,p_segment30                     => l_segment30
        ,p_concat_segments               => p_concat_segments
        ,p_competence_definition_id      => l_competence_definition_id
        ,p_language_code                 => l_language_code
        ,p_competence_cluster           =>     p_competence_cluster
        ,p_unit_standard_id             =>     p_unit_standard_id
        ,p_credit_type                  =>     p_credit_type
        ,p_credits                      =>     p_credits
        ,p_level_type                   =>     p_level_type
        ,p_level_number                 =>     p_level_number
        ,p_field                        =>     p_field
        ,p_sub_field                    =>     p_sub_field
        ,p_provider                     =>     p_provider
        ,p_qa_organization              =>     p_qa_organization
        ,p_information_category         =>     p_information_category
        ,p_information1                 =>     p_information1
        ,p_information2                 =>     p_information2
        ,p_information3                 =>     p_information3
        ,p_information4                 =>     p_information4
        ,p_information5                 =>     p_information5
        ,p_information6                 =>     p_information6
        ,p_information7                 =>     p_information7
        ,p_information8                 =>     p_information8
        ,p_information9                 =>     p_information9
        ,p_information10                =>     p_information10
        ,p_information11                =>     p_information11
        ,p_information12                =>     p_information12
        ,p_information13                =>     p_information13
        ,p_information14                =>     p_information14
        ,p_information15                =>     p_information15
        ,p_information16                =>     p_information16
        ,p_information17                =>     p_information17
        ,p_information18                =>     p_information18
        ,p_information19                =>     p_information19
        ,p_information20                =>     p_information20
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_competence',
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
  -- Set all output arguments. l_object_version_number now has the new
  -- object version number as the update was successful
  --
  p_object_version_number  := l_object_version_number;
  p_name := l_name;
  p_competence_definition_id := l_competence_definition_id;
  --
  hr_utility.set_location(p_concat_segments, 694);
  hr_utility.set_location(' Leaving:'||l_proc, 12);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_competence;
    --
    -- Only set output warning arguments and in out arguments back
    -- to their IN value
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
   p_name := null;
   if l_null_ind = 0
   then
      p_competence_definition_id := null;
   end if;
   --
  when others then
   --
   -- A validation or unexpected error has occurred
   --
   -- Added as part of fix to bug 632482
   --
   ROLLBACK TO update_competence;
   p_object_version_number := l_ovn;
   p_name := null;
   p_competence_definition_id := l_comp_def_id;
   raise;
   --
   -- End of fix.
   --
   hr_utility.set_location(' Leaving:'||l_proc, 12);
--
end update_competence;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <delete_competence> >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure delete_competence
(p_validate                           in boolean default false,
 p_competence_id                      in number,
 p_object_version_number              in number
) is
  --
  -- Declare cursors and local variables
  --
  cursor csr_get_prof_levels(c_competence_id     per_competences.competence_id%TYPE)
   is
   select	rating_level_id,
		object_version_number
   from	per_rating_levels
   where	competence_id = c_competence_id;
  --
  --
  l_proc                varchar2(72) := g_package||'delete_competence';
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint delete_competence;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_competences_bk3.delete_competence_b
		(
		p_competence_id          =>   p_competence_id,
		p_object_version_number  =>   p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_competence',
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
  -- check if competence has any rating levels (proficiency)
  -- if yes, delete them.
  --
  for c_prof_rec in csr_get_prof_levels(p_competence_id) loop
     per_rtl_del.del
     (p_validate                    => FALSE
     ,p_rating_level_id             => c_prof_rec.rating_level_id
     ,p_object_version_number       => c_prof_rec.object_version_number
     );
  end loop;
  --
   --
  -- MLS Processing
  --
  per_cpl_del.del_tl
  (p_competence_id              => p_competence_id
  );

  -- now delete the competence itself
  --
     per_cpn_del.del
     (p_validate                    => FALSE
     ,p_competence_id               => p_competence_id
     ,p_object_version_number       => p_object_version_number
     );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_competences_bk3.delete_competence_a	(
		p_competence_id          =>   p_competence_id,
		p_object_version_number  =>   p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_competence',
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
    ROLLBACK TO delete_competence;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO delete_competence;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_competence;
--
-- ---------------------------------------------------------------------------
-- |----------------< create_or_update_competence >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure create_or_update_competence
 (p_validate                     in     boolean          default false
 ,p_effective_date               in     date             default trunc(sysdate)
 ,p_language_code                in     varchar2 default hr_api.userenv_lang
 ,p_category                     in     varchar2         default null
 ,p_name                         in     varchar2         default null
 ,p_date_from                    in     date             default trunc(sysdate)
 ,p_date_to                      in     date             default null
 ,p_description                  in     varchar2         default null
 ,p_competence_alias             in     varchar2         default null
 ,p_behavioural_indicator        in     varchar2         default null
 ,p_certification_required       in     varchar2         default null
 ,p_evaluation_method            in     varchar2         default null
 ,p_renewal_period_frequency     in     number           default null
 ,p_renewal_period_units         in     varchar2         default null
 ,p_rating_scale_name            in     varchar2         default null
 ,p_translated_language          in     varchar2         default null
 ,p_source_category_name         in     varchar2         default null
 ,p_source_competence_name       in     varchar2         default null

) is

  l_proc                  varchar2(72) := g_package||'create_or_update_competence';
  l_competence_id            per_competences.competence_id%TYPE;
  l_source_competence_id     per_competences.competence_id%TYPE;
  l_conc_name                varchar2(700);
  l_flex_num number;
  l_competence_definition_id per_competences.competence_definition_id%TYPE;
  l_rating_scale_id          per_competences.rating_scale_id%TYPE;
  l_ovn                      per_competences.object_version_number%TYPE;
  l_source_ovn               per_competences.object_version_number%TYPE;
  l_effective_date           date;
  l_date_from                date;
  l_evaluation_method        per_competences.evaluation_method%TYPE;
  l_certification_required   per_competences.certification_required%TYPE;
  l_renewal_period_units     per_competences.renewal_period_units%TYPE;
  l_language_code            varchar2(20);
  l_translated_language      varchar2(20);
  l_segment1                 varchar2(150);
  l_segment2                 varchar2(150);
  l_concatenate_name         varchar2(150);

  cursor csr_cpn(p_competence_name in varchar2)
  is
  select competence_id , object_version_number
  from per_competences_v
  where business_group_id is null
  and name = p_competence_name;

  cursor csr_rsc
  is
  select rating_scale_id
  from per_rating_scales
  where business_group_id is null
  and name = p_rating_scale_name;

  --
  -- Declare local modules
  --
  function return_lookup_code
         (p_meaning	   in    fnd_lookup_values.meaning%TYPE default null
         ,p_lookup_type    in    fnd_lookup_values.lookup_code%TYPE
         ,p_language_code  in    fnd_lookup_values.language%TYPE
         )
         Return fnd_lookup_values.lookup_code%TYPE Is
--
  l_lookup_code  fnd_lookup_values.lookup_code%TYPE := null;
--
  Cursor Sel_Id Is
         select  flv.lookup_code
         from    fnd_lookup_values flv
         where   flv.lookup_type     = p_lookup_type
         and     UPPER(flv.meaning)  = UPPER(p_meaning)
         and     flv.language        = p_language_code
         and     flv.enabled_flag = 'Y';
--
  begin
    open Sel_Id;
    fetch Sel_Id Into l_lookup_code;
    if Sel_Id%notfound then
       close Sel_Id;
       hr_utility.set_message(800, 'HR_449156_LOOK_MEANING_INVALID');
       fnd_message.set_token('MEANING',p_meaning);
       hr_utility.raise_error;
     end if;
     close Sel_Id;
    --
    return (l_lookup_code);
  end;
--
Begin
  --
  hr_utility.set_location('Entering...' || l_proc,10);
  --
  -- Issue a savepoint.
  --
  savepoint create_or_update_competence;

  hr_competences_api.g_ignore_df := 'Y';

  if (p_language_code is NULL) then
    l_language_code :=  hr_api.userenv_lang;
  else
    l_language_code := p_language_code;
    -- BUG3668368
    hr_api.validate_language_code(p_language_code => l_language_code);
  end if;

  if (p_effective_date is NULL) then
    l_effective_date := trunc(sysdate);
  else
    l_effective_date := trunc(p_effective_date);
  end if;
  hr_utility.trace('p_effective_date : ' || p_effective_date);

  if (p_date_from is NULL) then
    l_date_from := trunc(sysdate);
  else
    l_date_from := trunc(p_date_from);
  end if;
  hr_utility.trace('p_date_from      : ' || p_date_from);

  IF ( p_translated_language IS NULL AND p_source_competence_name  IS NULL
       AND p_source_category_name IS NULL)
  THEN
    hr_utility.set_location(l_proc,20);

    if (p_category IS NOT NULL) then
       l_concatenate_name := p_category || '.' || p_name;
       l_segment1 := p_category;
       l_segment2 := p_name;
    else
       l_concatenate_name := p_name;
       l_segment1 := p_name;
       l_segment2 := NULL;
    end if;

    open csr_cpn(l_concatenate_name);
    fetch csr_cpn into l_competence_id, l_ovn;
    if csr_cpn%NOTFOUND then
       close csr_cpn;
       l_competence_id := NULL;
       l_ovn := NULL;
    else
       close csr_cpn;
    end if;
    hr_utility.trace('l_competence_id : ' || l_competence_id);
    hr_utility.trace('l_ovn           : ' || l_ovn);

    if (p_rating_scale_name is not NULL) then
      open csr_rsc;
      fetch csr_rsc into l_rating_scale_id;
      if csr_rsc%NOTFOUND then
         close csr_rsc;
         fnd_message.set_name('PER','HR_51928_APT_RSC_NOT_EXIST');
         fnd_message.raise_error;
      end if;
      close csr_rsc;
      hr_utility.trace('l_rating_scale_id : ' || l_rating_scale_id);
    end if;

    hr_utility.set_location(l_proc,30);

    if (p_evaluation_method is not null) then
      l_evaluation_method := return_lookup_code
  			(p_meaning              => p_evaluation_method
			,p_lookup_type		=> 'COMPETENCE_EVAL_TYPE'
			,p_language_code	=> l_language_code
 			);
      hr_utility.trace('l_evaluation_method      : ' || l_evaluation_method);
    else
      l_evaluation_method := null;
    end if;

    if (p_certification_required is not null) then
      l_certification_required := return_lookup_code
			(p_meaning              => p_certification_required
			,p_lookup_type		=> 'YES_NO'
			,p_language_code	=> l_language_code
 			);
      hr_utility.trace('l_certification_required : ' || l_certification_required);
    else
      l_certification_required := 'N';
    end if;

    if (p_renewal_period_units is not null) then
      l_renewal_period_units := return_lookup_code
  			(p_meaning              => p_renewal_period_units
			,p_lookup_type		=> 'FREQUENCY'
			,p_language_code	=> l_language_code
 			);
      hr_utility.trace('l_renewal_period_units   : ' || l_renewal_period_units);
    else
      l_renewal_period_units := null;
    end if;

    --
    if ( l_competence_id is null and l_ovn is null) then

      hr_utility.set_location(l_proc,40);

      create_competence
       (p_effective_date               => l_effective_date
       ,p_language_code                => l_language_code
       ,p_description                  => p_description
       ,p_competence_alias             => p_competence_alias
       ,p_date_from                    => l_date_from
       ,p_date_to                      => p_date_to
       ,p_behavioural_indicator        => p_behavioural_indicator
       ,p_certification_required       => l_certification_required
       ,p_evaluation_method            => l_evaluation_method
       ,p_renewal_period_frequency     => p_renewal_period_frequency
       ,p_renewal_period_units         => l_renewal_period_units
       ,p_rating_scale_id              => l_rating_scale_id
       ,p_segment1                     => l_segment1
       ,p_segment2                     => l_segment2
       ,p_competence_id                => l_competence_id
       ,p_competence_definition_id     => l_competence_definition_id
       ,p_object_version_number        => l_ovn
       ,p_name                         => l_conc_name
       );

    else

      hr_utility.set_location(l_proc,50);

      update_competence
       (p_effective_date               => l_effective_date
       ,p_language_code                => l_language_code
       ,p_description                  => p_description
       ,p_competence_alias             => p_competence_alias
       ,p_date_from                    => l_date_from
       ,p_date_to                      => p_date_to
       ,p_behavioural_indicator        => p_behavioural_indicator
       ,p_certification_required       => l_certification_required
       ,p_evaluation_method            => l_evaluation_method
       ,p_renewal_period_frequency     => p_renewal_period_frequency
       ,p_renewal_period_units         => l_renewal_period_units
       ,p_rating_scale_id              => l_rating_scale_id
       ,p_segment1                     => l_segment1
       ,p_segment2                     => l_segment2
       ,p_competence_id                => l_competence_id
       ,p_competence_definition_id     => l_competence_definition_id
       ,p_object_version_number        => l_ovn
       ,p_name                         => l_conc_name
       );

    end if;

  ELSE

    --
    -- MLS update
    --
    hr_utility.set_location(l_proc,50);

    if (p_source_category_name IS NOT NULL) then
       l_concatenate_name := p_source_category_name || '.' || p_source_competence_name;
    else
       l_concatenate_name := p_source_competence_name;
    end if;
    hr_utility.trace('l_concatenate_name => ' || l_concatenate_name);

    open csr_cpn(l_concatenate_name);
    fetch csr_cpn into l_source_competence_id, l_source_ovn;
    if csr_cpn%NOTFOUND then
       close csr_cpn;
       hr_utility.set_message(800, 'HR_449189_SOURCE_CPN_INVALID');
       hr_utility.raise_error;
    else
       close csr_cpn;
    end if;
    hr_utility.trace('l_source_competence_id : ' || l_source_competence_id);
    hr_utility.trace('l_source_ovn           : ' || l_source_ovn);

    l_translated_language := p_translated_language;
    hr_api.validate_language_code(p_language_code => l_translated_language);

    --
    -- MLS Processing
    --
    --
    per_cpl_upd.upd_tl
    (p_effective_date               => l_effective_date
    ,p_language_code                => l_translated_language
    ,p_competence_id                => l_source_competence_id
    ,p_name                         => l_concatenate_name
    ,p_competence_alias             => p_competence_alias
    ,p_behavioural_indicator        => p_behavioural_indicator
    ,p_description                  => p_description
    );

    hr_utility.set_location(l_proc,60);

    --
    -- Call After Process User Hook
    --
    begin
	hr_competences_bk2.update_competence_a	(
         p_competence_id                =>     l_source_competence_id,
         p_object_version_number        =>     l_source_ovn,
         p_effective_date               =>     l_effective_date,
         p_name                         =>     p_source_competence_name,
         p_description                  =>     p_description,
         p_date_from                    =>     trunc(l_date_from),
         p_date_to                      =>     trunc(p_date_to),
         p_behavioural_indicator        =>     p_behavioural_indicator,
         p_certification_required       =>     p_certification_required,
         p_evaluation_method            =>     p_evaluation_method,
         p_renewal_period_frequency     =>     p_renewal_period_frequency,
         p_renewal_period_units         =>     p_renewal_period_units,
         p_rating_scale_id              =>     NULL,
         p_attribute_category           =>     NULL,
         p_attribute1                   =>     NULL,
         p_attribute2                   =>     NULL,
         p_attribute3                   =>     NULL,
         p_attribute4                   =>     NULL,
         p_attribute5                   =>     NULL,
         p_attribute6                   =>     NULL,
         p_attribute7                   =>     NULL,
         p_attribute8                   =>     NULL,
         p_attribute9                   =>     NULL,
         p_attribute10                  =>     NULL,
         p_attribute11                  =>     NULL,
         p_attribute12                  =>     NULL,
         p_attribute13                  =>     NULL,
         p_attribute14                  =>     NULL,
         p_attribute15                  =>     NULL,
         p_attribute16                  =>     NULL,
         p_attribute17                  =>     NULL,
         p_attribute18                  =>     NULL,
         p_attribute19                  =>     NULL,
         p_attribute20                  =>     NULL,
         p_competence_alias             =>     p_competence_alias,
         p_segment1                     =>     NULL
        ,p_segment2                     =>     NULL
        ,p_segment3                     =>     NULL
        ,p_segment4                     =>     NULL
        ,p_segment5                     =>     NULL
        ,p_segment6                     =>     NULL
        ,p_segment7                     =>     NULL
        ,p_segment8                     =>     NULL
        ,p_segment9                     =>     NULL
        ,p_segment10                    =>     NULL
        ,p_segment11                    =>     NULL
        ,p_segment12                    =>     NULL
        ,p_segment13                    =>     NULL
        ,p_segment14                    =>     NULL
        ,p_segment15                    =>     NULL
        ,p_segment16                    =>     NULL
        ,p_segment17                    =>     NULL
        ,p_segment18                    =>     NULL
        ,p_segment19                    =>     NULL
        ,p_segment20                    =>     NULL
        ,p_segment21                    =>     NULL
        ,p_segment22                    =>     NULL
        ,p_segment23                    =>     NULL
        ,p_segment24                    =>     NULL
        ,p_segment25                    =>     NULL
        ,p_segment26                    =>     NULL
        ,p_segment27                    =>     NULL
        ,p_segment28                    =>     NULL
        ,p_segment29                    =>     NULL
        ,p_segment30                    =>     NULL
        ,p_concat_segments              =>     NULL
        ,p_competence_definition_id     =>     NULL
        ,p_language_code                =>     l_translated_language
        ,p_competence_cluster           =>     NULL
        ,p_unit_standard_id             =>     NULL
        ,p_credit_type                  =>     NULL
        ,p_credits                      =>     NULL
        ,p_level_type                   =>     NULL
        ,p_level_number                 =>     NULL
        ,p_field                        =>     NULL
        ,p_sub_field                    =>     NULL
        ,p_provider                     =>     NULL
        ,p_qa_organization              =>     NULL
        ,p_information_category         =>     NULL
        ,p_information1                 =>     NULL
        ,p_information2                 =>     NULL
        ,p_information3                 =>     NULL
        ,p_information4                 =>     NULL
        ,p_information5                 =>     NULL
        ,p_information6                 =>     NULL
        ,p_information7                 =>     NULL
        ,p_information8                 =>     NULL
        ,p_information9                 =>     NULL
        ,p_information10                =>     NULL
        ,p_information11                =>     NULL
        ,p_information12                =>     NULL
        ,p_information13                =>     NULL
        ,p_information14                =>     NULL
        ,p_information15                =>     NULL
        ,p_information16                =>     NULL
        ,p_information17                =>     NULL
        ,p_information18                =>     NULL
        ,p_information19                =>     NULL
        ,p_information20                =>     NULL
	);
      exception
	   when hr_api.cannot_find_prog_unit then
                  hr_competences_api.g_ignore_df := 'N';
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_competence',
				 p_hook_type	=> 'AP'
				);
    end;

  END IF;
  hr_competences_api.g_ignore_df := 'N';
  hr_utility.set_location('Leaving... ' || l_proc,70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO creaet_or_update_competence;
    --
    hr_competences_api.g_ignore_df := 'N';
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    --
    ROLLBACK TO create_or_update_competence;
    --
    hr_competences_api.g_ignore_df := 'N';
    raise;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
end create_or_update_competence;
--
--
end hr_competences_api;

/
