--------------------------------------------------------
--  DDL for Package Body HR_GRADE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GRADE_API" as
/* $Header: pegrdapi.pkb 120.1.12010000.3 2008/08/06 09:12:21 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_grade_api.';
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_grade >----------------------------------|
-- ----------------------------------------------------------------------------
procedure create_grade
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_date_from                     in     date
  ,p_sequence			   in	  number
  ,p_effective_date		   in     date     default null
  ,p_date_to                       in     date     default null
  ,p_request_id			   in 	  number   default null
  ,p_program_application_id        in 	  number   default null
  ,p_program_id                    in 	  number   default null
  ,p_program_update_date           in 	  date     default null
  ,p_last_update_date              in 	  date     default null
  ,p_last_updated_by               in 	  number   default null
  ,p_last_update_login             in 	  number   default null
  ,p_created_by                    in 	  number   default null
  ,p_creation_date                 in 	  date     default null
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
  ,p_information1 	           in     varchar2 default null
  ,p_information2 	           in     varchar2 default null
  ,p_information3 	           in     varchar2 default null
  ,p_information4 	           in     varchar2 default null
  ,p_information5 	           in     varchar2 default null
  ,p_information6 	           in     varchar2 default null
  ,p_information7 	           in     varchar2 default null
  ,p_information8 	           in     varchar2 default null
  ,p_information9 	           in     varchar2 default null
  ,p_information10 	           in     varchar2 default null
  ,p_information11 	           in     varchar2 default null
  ,p_information12 	           in     varchar2 default null
  ,p_information13 	           in     varchar2 default null
  ,p_information14 	           in     varchar2 default null
  ,p_information15 	           in     varchar2 default null
  ,p_information16 	           in     varchar2 default null
  ,p_information17 	           in     varchar2 default null
  ,p_information18 	           in     varchar2 default null
  ,p_information19 	           in     varchar2 default null
  ,p_information20 	           in     varchar2 default null
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
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_concat_segments               in     varchar2 default null
  ,p_short_name			   in     varchar2 default null
  ,p_grade_id                      out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_grade_definition_id           in out nocopy number
  ,p_name                          in out nocopy varchar2
   ) is
--
-- Declare cursors and local variables
--
   l_grade_id                 per_grades.grade_id%TYPE;
   l_grade_definition_id      per_grades.grade_definition_id%TYPE := p_grade_definition_id;
   l_business_group_id        per_grades.business_group_id%TYPE;
   l_name                     per_grades.name%TYPE 	:= p_name;
   l_proc                     varchar2(72) := g_package||'create_grade';
   l_flex_num                 fnd_id_flex_segments.id_flex_num%TYPE;
   l_object_version_number    per_grades.object_version_number%TYPE;
   l_sequence		          per_grades.sequence%TYPE;
   l_date_from                per_grades.date_from%TYPE;
   l_date_to                  per_grades.date_to%TYPE;
   l_effective_date           date := p_effective_date;
   l_segment1                 varchar2(60) := p_segment1;
   l_segment2                 varchar2(60) := p_segment2;
   l_segment3                 varchar2(60) := p_segment3;
   l_segment4                 varchar2(60) := p_segment4;
   l_segment5                 varchar2(60) := p_segment5;
   l_segment6                 varchar2(60) := p_segment6;
   l_segment7                 varchar2(60) := p_segment7;
   l_segment8                 varchar2(60) := p_segment8;
   l_segment9                 varchar2(60) := p_segment9;
   l_segment10                varchar2(60) := p_segment10;
   l_segment11                varchar2(60) := p_segment11;
   l_segment12                varchar2(60) := p_segment12;
   l_segment13                varchar2(60) := p_segment13;
   l_segment14                varchar2(60) := p_segment14;
   l_segment15                varchar2(60) := p_segment15;
   l_segment16                varchar2(60) := p_segment16;
   l_segment17                varchar2(60) := p_segment17;
   l_segment18                varchar2(60) := p_segment18;
   l_segment19                varchar2(60) := p_segment19;
   l_segment20                varchar2(60) := p_segment20;
   l_segment21                varchar2(60) := p_segment21;
   l_segment22                varchar2(60) := p_segment22;
   l_segment23                varchar2(60) := p_segment23;
   l_segment24                varchar2(60) := p_segment24;
   l_segment25                varchar2(60) := p_segment25;
   l_segment26                varchar2(60) := p_segment26;
   l_segment27                varchar2(60) := p_segment27;
   l_segment28                varchar2(60) := p_segment28;
   l_segment29                varchar2(60) := p_segment29;
   l_segment30                varchar2(60) := p_segment30;
   l_language_code            varchar2(30) := p_language_code;
   l_short_name               per_grades.short_name%TYPE;
   --
   -- variable to indicate whether key flex id parameter
   -- enters the program with a value.
   --
   l_null_ind                 number(1)    := 0;
   --
   --
cursor isdel is
       select pbg.grade_structure
       from per_business_groups_perf pbg
       where pbg.business_group_id = p_business_group_id;

   --
   -- get per_grade_definition segment values where
   -- grade_definition_id is known
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
       from per_grade_definitions
      where grade_definition_id = l_grade_definition_id;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_grade;
  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  -- Truncate date_from and date_to
  --
  l_date_from      := trunc(p_date_from);
  l_date_to        := trunc(p_date_to);
  --
  -- check that flex structure is valid
  --
  open isdel;
  fetch isdel into l_flex_num;
  if isdel%notfound
  then
     close isdel;
     --
     -- the flex structure has not been found
     --
     hr_utility.set_message(801, 'HR_6039_ALL_CANT_GET_FFIELD');
     hr_utility.raise_error;
  end if;
  close isdel;
  --
  -- get segment values if p_grade_definition_id entered with a value
  --
  if l_grade_definition_id is not null
  --
  then
  --
     hr_utility.set_location(l_proc, 15);
     --
     -- set indicator to show p_grade_definition_id did not enter program null
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
     close c_segments;
  end if;
  --
  begin
  --
  -- Call Before Process User hook for create_grade
  --
  hr_grade_bk1.create_grade_b
    (p_business_group_id             => l_business_group_id
    ,p_date_from                     => l_date_from
    ,p_sequence		             => l_sequence
    ,p_date_to                       => l_date_to
    ,p_request_id	             => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_last_update_date              => p_last_update_date
    ,p_last_updated_by               => p_last_updated_by
    ,p_last_update_login             => p_last_update_login
    ,p_created_by                    => p_created_by
    ,p_creation_date                 => p_creation_date
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
    ,p_information20 	             => p_information20
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
    ,p_language_code                 => l_language_code
    ,p_concat_segments               => p_concat_segments
    ,p_grade_id                      => l_grade_id
    ,p_object_version_number         => l_object_version_number
    ,p_grade_definition_id           => l_grade_definition_id
    ,p_name                          => l_name
    ,p_effective_date		     => p_effective_date
    ,p_short_name                    => p_short_name
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_GRADE'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of before hook process (create_grade)
  --
  end;
  --
  -- Process Logic
  --
  if l_grade_definition_id is null
  then
     --
     -- Determine the Grade defintion by calling ins_or_sel
     --
     hr_utility.set_location(l_proc, 20);
     --
     hr_kflex_utility.ins_or_sel_keyflex_comb
       (p_appl_short_name       => 'PER'
       ,p_flex_code             => 'GRD'
       ,p_flex_num              => l_flex_num
       ,p_segment1              => l_segment1
       ,p_segment2              => l_segment2
       ,p_segment3              => l_segment3
       ,p_segment4              => l_segment4
       ,p_segment5              => l_segment5
       ,p_segment6              => l_segment6
       ,p_segment7              => l_segment7
       ,p_segment8              => l_segment8
       ,p_segment9              => l_segment9
       ,p_segment10             => l_segment10
       ,p_segment11             => l_segment11
       ,p_segment12             => l_segment12
       ,p_segment13             => l_segment13
       ,p_segment14             => l_segment14
       ,p_segment15             => l_segment15
       ,p_segment16             => l_segment16
       ,p_segment17             => l_segment17
       ,p_segment18             => l_segment18
       ,p_segment19             => l_segment19
       ,p_segment20             => l_segment20
       ,p_segment21             => l_segment21
       ,p_segment22             => l_segment22
       ,p_segment23             => l_segment23
       ,p_segment24             => l_segment24
       ,p_segment25             => l_segment25
       ,p_segment26             => l_segment26
       ,p_segment27             => l_segment27
       ,p_segment28             => l_segment28
       ,p_segment29             => l_segment29
       ,p_segment30             => l_segment30
       ,p_concat_segments_in    => p_concat_segments
       ,p_ccid                  => l_grade_definition_id
       ,p_concat_segments_out   => l_name
       );
  end if;
  --
  if l_grade_definition_id is not null
  then
  --
  -- Insert Grade.
  --
     hr_utility.set_location(l_proc, 30);
     --
     per_grd_ins.ins
       (p_effective_date               => p_effective_date
       ,p_business_group_id            => p_business_group_id
       ,p_grade_definition_id          => l_grade_definition_id
       ,p_date_from                    => l_date_from
       ,p_sequence                     => p_sequence
       ,p_date_to                      => l_date_to
       ,p_name                         => l_name
       ,p_request_id                   => p_request_id
       ,p_program_application_id       => p_program_application_id
       ,p_program_id                   => p_program_id
       ,p_program_update_date          => p_program_update_date
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
       ,p_grade_id                     => l_grade_id
       ,p_object_version_number        => l_object_version_number
       ,p_short_name		       => p_short_name
       );
     --
     hr_utility.set_location(l_proc, 40);
  --
  end if;
  --
  -- MLS Processing
  --
  per_gdt_ins.ins_tl
  (p_language_code         => l_language_code
  ,p_grade_id              => l_grade_id
  ,p_name                  => p_name
  );
  --
  --
  -- Call After Process hook for create_grade
  --
  begin
    hr_grade_bk1.create_grade_a
    (p_business_group_id             => l_business_group_id
    ,p_date_from                     => l_date_from
    ,p_sequence			     => l_sequence
    ,p_date_to                       => l_date_to
    ,p_request_id		     => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_last_update_date              => p_last_update_date
    ,p_last_updated_by               => p_last_updated_by
    ,p_last_update_login             => p_last_update_login
    ,p_created_by                    => p_created_by
    ,p_creation_date                 => p_creation_date
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
    ,p_information20 	             => p_information20
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
    ,p_grade_id                      => l_grade_id
    ,p_object_version_number         => l_object_version_number
    ,p_grade_definition_id           => l_grade_definition_id
    ,p_name                          => l_name
    ,p_effective_date		     => p_effective_date
    ,p_language_code                 => l_language_code
    ,p_short_name                    => p_short_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_GRADE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of after hook process (create_grade)
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
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  -- Set OUT parameters
  --
   p_grade_id                := l_grade_id;
   p_object_version_number := l_object_version_number;
   p_grade_definition_id     := l_grade_definition_id;
   p_name                  := l_name;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 60);
   --
   exception
   --
   when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     ROLLBACK TO create_grade;
     --
     -- Set OUT parameters to null
     -- Only set output warning arguments
     -- (Any key or derived arguments must be set to null
     -- when validation only mode is being used.)
     --
     if l_null_ind = 0
     then
        p_grade_definition_id      := null;
     end if;
     p_grade_id                    := null;
     p_object_version_number     := null;
     p_grade_definition_id         := null;
     p_name                      := null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  when others then
     --
     -- A validation or unexpected error has occurred
     --
     --
     --
     ROLLBACK TO create_grade;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 80);
     --
     raise;
     --
end create_grade;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_grade >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_grade(
          p_validate                 in boolean  default false
         ,p_grade_id                 in number
         ,p_sequence                 in number   default hr_api.g_number
         ,p_date_from                in date     default hr_api.g_date
         ,p_effective_date           in date     default hr_api.g_date
         ,p_date_to                  in date     default hr_api.g_date
         ,p_request_id               in number   default hr_api.g_number
         ,p_program_application_id   in number   default hr_api.g_number
         ,p_program_id               in number   default hr_api.g_number
         ,p_program_update_date      in date     default hr_api.g_date
         ,p_attribute_category       in varchar2 default hr_api.g_varchar2
         ,p_attribute1               in varchar2 default hr_api.g_varchar2
         ,p_attribute2               in varchar2 default hr_api.g_varchar2
         ,p_attribute3               in varchar2 default hr_api.g_varchar2
         ,p_attribute4               in varchar2 default hr_api.g_varchar2
         ,p_attribute5               in varchar2 default hr_api.g_varchar2
         ,p_attribute6               in varchar2 default hr_api.g_varchar2
         ,p_attribute7               in varchar2 default hr_api.g_varchar2
         ,p_attribute8               in varchar2 default hr_api.g_varchar2
         ,p_attribute9               in varchar2 default hr_api.g_varchar2
         ,p_attribute10              in varchar2 default hr_api.g_varchar2
         ,p_attribute11              in varchar2 default hr_api.g_varchar2
         ,p_attribute12              in varchar2 default hr_api.g_varchar2
         ,p_attribute13              in varchar2 default hr_api.g_varchar2
         ,p_attribute14              in varchar2 default hr_api.g_varchar2
         ,p_attribute15              in varchar2 default hr_api.g_varchar2
         ,p_attribute16              in varchar2 default hr_api.g_varchar2
         ,p_attribute17              in varchar2 default hr_api.g_varchar2
         ,p_attribute18              in varchar2 default hr_api.g_varchar2
         ,p_attribute19              in varchar2 default hr_api.g_varchar2
         ,p_attribute20              in varchar2 default hr_api.g_varchar2
         ,p_information_category     in varchar2 default hr_api.g_varchar2
         ,p_information1             in varchar2 default hr_api.g_varchar2
         ,p_information2             in varchar2 default hr_api.g_varchar2
         ,p_information3             in varchar2 default hr_api.g_varchar2
         ,p_information4             in varchar2 default hr_api.g_varchar2
         ,p_information5             in varchar2 default hr_api.g_varchar2
         ,p_information6             in varchar2 default hr_api.g_varchar2
         ,p_information7             in varchar2 default hr_api.g_varchar2
         ,p_information8             in varchar2 default hr_api.g_varchar2
         ,p_information9             in varchar2 default hr_api.g_varchar2
         ,p_information10            in varchar2 default hr_api.g_varchar2
         ,p_information11            in varchar2 default hr_api.g_varchar2
         ,p_information12            in varchar2 default hr_api.g_varchar2
         ,p_information13            in varchar2 default hr_api.g_varchar2
         ,p_information14            in varchar2 default hr_api.g_varchar2
         ,p_information15            in varchar2 default hr_api.g_varchar2
         ,p_information16            in varchar2 default hr_api.g_varchar2
         ,p_information17            in varchar2 default hr_api.g_varchar2
         ,p_information18            in varchar2 default hr_api.g_varchar2
         ,p_information19            in varchar2 default hr_api.g_varchar2
         ,p_information20            in varchar2 default hr_api.g_varchar2
         ,p_last_update_date         in date     default hr_api.g_date
         ,p_last_updated_by          in number   default hr_api.g_number
         ,p_last_update_login        in number   default hr_api.g_number
         ,p_created_by               in number   default hr_api.g_number
         ,p_creation_date            in date     default hr_api.g_date
         ,p_segment1                 in varchar2 default hr_api.g_varchar2
         ,p_segment2                 in varchar2 default hr_api.g_varchar2
         ,p_segment3                 in varchar2 default hr_api.g_varchar2
         ,p_segment4                 in varchar2 default hr_api.g_varchar2
         ,p_segment5                 in varchar2 default hr_api.g_varchar2
         ,p_segment6                 in varchar2 default hr_api.g_varchar2
         ,p_segment7                 in varchar2 default hr_api.g_varchar2
         ,p_segment8                 in varchar2 default hr_api.g_varchar2
         ,p_segment9                 in varchar2 default hr_api.g_varchar2
         ,p_segment10                in varchar2 default hr_api.g_varchar2
         ,p_segment11                in varchar2 default hr_api.g_varchar2
         ,p_segment12                in varchar2 default hr_api.g_varchar2
         ,p_segment13                in varchar2 default hr_api.g_varchar2
         ,p_segment14                in varchar2 default hr_api.g_varchar2
         ,p_segment15                in varchar2 default hr_api.g_varchar2
         ,p_segment16                in varchar2 default hr_api.g_varchar2
         ,p_segment17                in varchar2 default hr_api.g_varchar2
         ,p_segment18                in varchar2 default hr_api.g_varchar2
         ,p_segment19                in varchar2 default hr_api.g_varchar2
         ,p_segment20                in varchar2 default hr_api.g_varchar2
         ,p_segment21                in varchar2 default hr_api.g_varchar2
         ,p_segment22                in varchar2 default hr_api.g_varchar2
         ,p_segment23                in varchar2 default hr_api.g_varchar2
         ,p_segment24                in varchar2 default hr_api.g_varchar2
         ,p_segment25                in varchar2 default hr_api.g_varchar2
         ,p_segment26                in varchar2 default hr_api.g_varchar2
         ,p_segment27                in varchar2 default hr_api.g_varchar2
         ,p_segment28                in varchar2 default hr_api.g_varchar2
         ,p_segment29                in varchar2 default hr_api.g_varchar2
         ,p_segment30                in varchar2 default hr_api.g_varchar2
         ,p_language_code            in varchar2 default hr_api.userenv_lang
         ,p_short_name               in varchar2 default hr_api.g_varchar2
         ,p_concat_segments          in out nocopy varchar2
         ,p_name                     in out nocopy varchar2
         ,p_object_version_number    in out nocopy number
         ,p_grade_definition_id      in out nocopy number
         ,p_form_calling             in boolean default false --for bug 6522394
         ) is
  --
  -- Declare cursors and local variables
  l_name                  varchar2(240);
  l_proc                  varchar2(72) := g_package||'update_grade';
  l_api_updating          boolean;
  l_effective_date        date;
  l_date_to               per_grades.date_to%type;
  l_sequence              per_grades.sequence%type;
  l_grade_id              per_grades.grade_id%type;
  l_date_from             per_grades.date_from%type;
  l_short_name            per_grades.short_name%type;
  l_business_group_id     per_grades.business_group_id%type;
  l_grade_definition_id   per_grades.grade_definition_id%type
                          := p_grade_definition_id;
  l_flex_num              fnd_id_flex_segments.id_flex_num%type;
  l_object_version_number per_grades.object_version_number%type;
  l_segment1              varchar2(60) := p_segment1;
  l_segment2              varchar2(60) := p_segment2;
  l_segment3              varchar2(60) := p_segment3;
  l_segment4              varchar2(60) := p_segment4;
  l_segment5              varchar2(60) := p_segment5;
  l_segment6              varchar2(60) := p_segment6;
  l_segment7              varchar2(60) := p_segment7;
  l_segment8              varchar2(60) := p_segment8;
  l_segment9              varchar2(60) := p_segment9;
  l_segment10             varchar2(60) := p_segment10;
  l_segment11             varchar2(60) := p_segment11;
  l_segment12             varchar2(60) := p_segment12;
  l_segment13             varchar2(60) := p_segment13;
  l_segment14             varchar2(60) := p_segment14;
  l_segment15             varchar2(60) := p_segment15;
  l_segment16             varchar2(60) := p_segment16;
  l_segment17             varchar2(60) := p_segment17;
  l_segment18             varchar2(60) := p_segment18;
  l_segment19             varchar2(60) := p_segment19;
  l_segment20             varchar2(60) := p_segment20;
  l_segment21             varchar2(60) := p_segment21;
  l_segment22             varchar2(60) := p_segment22;
  l_segment23             varchar2(60) := p_segment23;
  l_segment24             varchar2(60) := p_segment24;
  l_segment25             varchar2(60) := p_segment25;
  l_segment26             varchar2(60) := p_segment26;
  l_segment27             varchar2(60) := p_segment27;
  l_segment28             varchar2(60) := p_segment28;
  l_segment29             varchar2(60) := p_segment29;
  l_segment30             varchar2(60) := p_segment30;
  l_language_code         varchar2(30) := p_language_code;
  l_null_ind              number(1)    := 0;
  l_old_seq               number; --for bug 6522394
  --
  -- Declare cursors
  cursor isdel is
         select pgd.id_flex_num
           from per_grade_definitions pgd
          where pgd.grade_definition_id = l_grade_definition_id;
  --

 --start changes for bug 6522394
   cursor csr_old_seq is
   select sequence
   from per_grades
   where grade_id = p_grade_id;
 --end changes for bug 6522394

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
           from per_grade_definitions
          where grade_definition_id = l_grade_definition_id;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  savepoint update_grade;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  l_grade_definition_id   := p_grade_definition_id;
  l_object_version_number := p_object_version_number;
  --
  -- Validation in addition to Table Handlers
  l_api_updating := per_grd_shd.api_updating(
                    p_grade_id              => p_grade_id
                   ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 15);
  --
  if not l_api_updating then
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- As this an updating API, the grade should already exist.
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
    --
  else
    --
    if l_grade_definition_id is null then
      --
      l_null_ind := 0;
      l_grade_definition_id := per_grd_shd.g_old_rec.grade_definition_id;
      hr_utility.set_location(l_proc, 24);
      --
    else
      --
      -- get segment values if p_grade_definition_id entered with a value
      -- set indicator to show p_grade_definition_id did not enter program null
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
      close c_segments;
      --
      hr_utility.set_location(l_proc, 27);
      --
    end if;
    --
  end if;
  --
  --start changes for bug 6522394
  open csr_old_seq;
  fetch csr_old_seq into l_old_seq;

  if csr_old_seq%found then
    close csr_old_seq;
  end if;
  --end changes for bug 6522394

  hr_utility.set_location('Entering: call - update_grade_b', 35);
  --
  -- Call Before Process User Hook
  begin
    --
    hr_grade_bk2.update_grade_b(
       p_grade_id                      => p_grade_id
      ,p_sequence                      => p_sequence
      ,p_date_from                     => l_date_from
      ,p_date_to                       => l_date_to
      ,p_effective_date                => p_effective_date
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
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
      ,p_last_update_date              => p_last_update_date
      ,p_last_updated_by               => p_last_updated_by
      ,p_last_update_login             => p_last_update_login
      ,p_created_by                    => p_created_by
      ,p_creation_date                 => p_creation_date
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
      ,p_language_code                 => l_language_code
      ,p_concat_segments               => p_concat_segments
      ,p_name                          => p_name
      ,p_short_name                    => p_short_name
      ,p_object_version_number         => p_object_version_number
      ,p_grade_definition_id           => p_grade_definition_id);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error(
                p_module_name => 'UPDATE_GRADE'
               ,p_hook_type   => 'BP');
    --
  end; -- End of API User Hook for the before hook of update_grade
  --
  hr_utility.set_location(l_proc, 30);
  --
  open isdel;
  fetch isdel into l_flex_num;
  if isdel%notfound then
    --
    hr_utility.set_location(l_proc, 38);
    close isdel;
    --
    -- the flex structure has not been found
    hr_utility.set_message(801, 'HR_6039_ALL_CANT_GET_FFIELD');
    hr_utility.raise_error;
    --
  end if;
  --
  close isdel;
  hr_utility.set_location(l_proc, 40);
  l_date_from      := trunc(p_date_from);
  l_date_to        := trunc(p_date_to);
  --
  -- update grade definitions
  hr_utility.set_location(l_proc, 50);
  hr_utility.trace('GRD before upd_or_sel '||l_grade_definition_id);
  --
  hr_kflex_utility.upd_or_sel_keyflex_comb(
        p_appl_short_name     => 'PER'
       ,p_flex_code           => 'GRD'
       ,p_flex_num            => l_flex_num
       ,p_segment1            => l_segment1
       ,p_segment2            => l_segment2
       ,p_segment3            => l_segment3
       ,p_segment4            => l_segment4
       ,p_segment5            => l_segment5
       ,p_segment6            => l_segment6
       ,p_segment7            => l_segment7
       ,p_segment8            => l_segment8
       ,p_segment9            => l_segment9
       ,p_segment10           => l_segment10 -- fix for bug 4758481.
       ,p_segment11           => l_segment11
       ,p_segment12           => l_segment12
       ,p_segment13           => l_segment13
       ,p_segment14           => l_segment14
       ,p_segment15           => l_segment15
       ,p_segment16           => l_segment16
       ,p_segment17           => l_segment17
       ,p_segment18           => l_segment18
       ,p_segment19           => l_segment19
       ,p_segment20           => l_segment20
       ,p_segment21           => l_segment21
       ,p_segment22           => l_segment22
       ,p_segment23           => l_segment23
       ,p_segment24           => l_segment24
       ,p_segment25           => l_segment25
       ,p_segment26           => l_segment26
       ,p_segment27           => l_segment27
       ,p_segment28           => l_segment28
       ,p_segment29           => l_segment29
       ,p_segment30           => l_segment30
       ,p_concat_segments_in  => p_concat_segments
       ,p_ccid                => l_grade_definition_id
       ,p_concat_segments_out => l_name);
  --
  hr_utility.set_location(l_proc, 60);
  --
  per_grd_upd.upd(
        p_effective_date         => p_effective_date
       ,p_grade_id               => p_grade_id
       ,p_object_version_number  => l_object_version_number
       ,p_business_group_id      => l_business_group_id
       ,p_grade_definition_id    => l_grade_definition_id
       ,p_date_from              => p_date_from
       ,p_sequence               => p_sequence
       ,p_date_to                => p_date_to
       ,p_name                   => l_name
       ,p_short_name             => p_short_name
       ,p_request_id             => p_request_id
       ,p_program_application_id => p_program_application_id
       ,p_program_id             => p_program_id
       ,p_program_update_date    => p_program_update_date
       ,p_attribute_category     => p_attribute_category
       ,p_attribute1             => p_attribute1
       ,p_attribute2             => p_attribute2
       ,p_attribute3             => p_attribute3
       ,p_attribute4             => p_attribute4
       ,p_attribute5             => p_attribute5
       ,p_attribute6             => p_attribute6
       ,p_attribute7             => p_attribute7
       ,p_attribute8             => p_attribute8
       ,p_attribute9             => p_attribute9
       ,p_attribute10            => p_attribute10
       ,p_attribute11            => p_attribute11
       ,p_attribute12            => p_attribute12
       ,p_attribute13            => p_attribute13
       ,p_attribute14            => p_attribute14
       ,p_attribute15            => p_attribute15
       ,p_attribute16            => p_attribute16
       ,p_attribute17            => p_attribute17
       ,p_attribute18            => p_attribute18
       ,p_attribute19            => p_attribute19
       ,p_attribute20            => p_attribute20
       ,p_information_category   => p_information_category
       ,p_information1           => p_information1
       ,p_information2           => p_information2
       ,p_information3           => p_information3
       ,p_information4           => p_information4
       ,p_information5           => p_information5
       ,p_information6           => p_information6
       ,p_information7           => p_information7
       ,p_information8           => p_information8
       ,p_information9           => p_information9
       ,p_information10          => p_information10
       ,p_information11          => p_information11
       ,p_information12          => p_information12
       ,p_information13          => p_information13
       ,p_information14          => p_information14
       ,p_information15          => p_information15
       ,p_information16          => p_information16
       ,p_information17          => p_information17
       ,p_information18          => p_information18
       ,p_information19          => p_information19
       ,p_information20          => p_information20);
  --
  -- MLS Processing
  per_gdt_upd.upd_tl(
        p_language_code          => l_language_code
       ,p_grade_id               => p_grade_id
       ,p_name                   => p_name);
  --

  --start changes for bug 6522394
  if not p_form_calling then
	declare
	 l_exists varchar2(1) ;
	 l_tmp_business_group_id number;
	 l_eot date:=to_date('31-12-4712','dd-mm-yyyy');

	 cursor csr_get_bgrp is
	  select business_group_id
	  from per_grades
	  where grade_id = p_grade_id;

	begin

	open csr_get_bgrp;
	fetch csr_get_bgrp into l_tmp_business_group_id;

	if csr_get_bgrp%found then
	 close csr_get_bgrp;
	end if;

	 per_grades_pkg.postup1(p_sequence,
				l_old_seq,
				p_last_updated_by,
				p_last_update_login,
				p_grade_id,
				l_tmp_business_group_id,
				l_exists );

	 IF l_exists = 'Y' THEN
	  per_grades_pkg.postup2(p_grade_id,
				       l_tmp_business_group_id,
				       p_date_from,
				       p_date_to,
				       l_eot,
				       null);
	END IF;
	end;
  end if;
  --end changes for bug 6522394

  hr_utility.set_location('Entering: call - update_grade_a', 65);
  --
  begin
    --
    hr_grade_bk2.update_grade_a(
        p_grade_id               => p_grade_id
       ,p_sequence               => p_sequence
       ,p_date_from              => l_date_from
       ,p_date_to                => l_date_to
       ,p_request_id             => p_request_id
       ,p_program_application_id => p_program_application_id
       ,p_program_id             => p_program_id
       ,p_program_update_date    => p_program_update_date
       ,p_attribute_category     => p_attribute_category
       ,p_attribute1             => p_attribute1
       ,p_attribute2             => p_attribute2
       ,p_attribute3             => p_attribute3
       ,p_attribute4             => p_attribute4
       ,p_attribute5             => p_attribute5
       ,p_attribute6             => p_attribute6
       ,p_attribute7             => p_attribute7
       ,p_attribute8             => p_attribute8
       ,p_attribute9             => p_attribute9
       ,p_attribute10            => p_attribute10
       ,p_attribute11            => p_attribute11
       ,p_attribute12            => p_attribute12
       ,p_attribute13            => p_attribute13
       ,p_attribute14            => p_attribute14
       ,p_attribute15            => p_attribute15
       ,p_attribute16            => p_attribute16
       ,p_attribute17            => p_attribute17
       ,p_attribute18            => p_attribute18
       ,p_attribute19            => p_attribute19
       ,p_attribute20            => p_attribute20
       ,p_information_category   => p_information_category
       ,p_information1           => p_information1
       ,p_information2           => p_information2
       ,p_information3           => p_information3
       ,p_information4           => p_information4
       ,p_information5           => p_information5
       ,p_information6           => p_information6
       ,p_information7           => p_information7
       ,p_information8           => p_information8
       ,p_information9           => p_information9
       ,p_information10          => p_information10
       ,p_information11          => p_information11
       ,p_information12          => p_information12
       ,p_information13          => p_information13
       ,p_information14          => p_information14
       ,p_information15          => p_information15
       ,p_information16          => p_information16
       ,p_information17          => p_information17
       ,p_information18          => p_information18
       ,p_information19          => p_information19
       ,p_information20          => p_information20
       ,p_last_update_date       => p_last_update_date
       ,p_last_updated_by        => p_last_updated_by
       ,p_last_update_login      => p_last_update_login
       ,p_created_by             => p_created_by
       ,p_creation_date          => p_creation_date
       ,p_segment1               => l_segment1
       ,p_segment2               => l_segment2
       ,p_segment3               => l_segment3
       ,p_segment4               => l_segment4
       ,p_segment5               => l_segment5
       ,p_segment6               => l_segment6
       ,p_segment7               => l_segment7
       ,p_segment8               => l_segment8
       ,p_segment9               => l_segment9
       ,p_segment10              => l_segment10
       ,p_segment11              => l_segment11
       ,p_segment12              => l_segment12
       ,p_segment13              => l_segment13
       ,p_segment14              => l_segment14
       ,p_segment15              => l_segment15
       ,p_segment16              => l_segment16
       ,p_segment17              => l_segment17
       ,p_segment18              => l_segment18
       ,p_segment19              => l_segment19
       ,p_segment20              => l_segment20
       ,p_segment21              => l_segment21
       ,p_segment22              => l_segment22
       ,p_segment23              => l_segment23
       ,p_segment24              => l_segment24
       ,p_segment25              => l_segment25
       ,p_segment26              => l_segment26
       ,p_segment27              => l_segment27
       ,p_segment28              => l_segment28
       ,p_segment29              => l_segment29
       ,p_segment30              => l_segment30
       ,p_language_code          => l_language_code
       ,p_concat_segments        => p_concat_segments
       ,p_name                   => p_name
       ,p_short_name             => p_short_name
       ,p_object_version_number  => p_object_version_number
       ,p_grade_definition_id    => p_grade_definition_id
       ,p_effective_date         => p_effective_date);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error(
                p_module_name => 'UPDATE_GRADE'
               ,p_hook_type   => 'AP');
  end; -- End of API User Hook for the after hook of update_grade
  --
  hr_utility.set_location(l_proc, 90);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_object_version_number;
  p_grade_definition_id   := l_grade_definition_id;
  p_name                  := l_name;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    rollback to update_grade;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    p_object_version_number := p_object_version_number;
    if l_null_ind = 0 then
      p_grade_definition_id := null;
    end if;
    p_name := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    rollback to update_grade;
    hr_utility.set_location(' Leaving:'||l_proc, 120);
    raise;
  --
end update_grade;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_grade >-------------------------------|
-- ----------------------------------------------------------------------------
--

procedure delete_grade
  (p_validate                      in     boolean
  ,p_grade_id                      in     number
  ,p_object_version_number         in out nocopy number) IS

  l_object_version_number       number(9);
  l_proc                varchar2(72) := g_package||'DELETE_GRADE';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Issue a savepoint
  --
  savepoint DELETE_GRADE;

  --
  -- Call Before Process User Hook
  --
  begin
  hr_grade_bk3.delete_grade_b
    (p_validate                   =>  p_validate
    ,p_grade_id                   =>  p_grade_id
    ,p_object_version_number      =>  p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GRADE'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 20);
  --
  -- MLS Processing
  --
  per_gdt_del.del_tl(p_grade_id  => p_grade_id);
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  per_grd_del.del
  (p_grade_id                      => p_grade_id
  ,p_object_version_number         => l_object_version_number);
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Call After Process User Hook
  --
 begin
  hr_grade_bk3.delete_grade_a
    (p_validate                   =>  p_validate
    ,p_grade_id                   =>  p_grade_id
    ,p_object_version_number      =>  l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GRADE'
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
  -- Set all output arguments
  --
  --
  p_object_version_number := l_object_version_number;

  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when hr_api.validate_enabled then
    hr_utility.set_location(' Leaving...:'||l_proc, 80);
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_GRADE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  when others then
    hr_utility.set_location(' Leaving...:'||l_proc, 90);
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_GRADE;
    raise;
end delete_grade;
end hr_grade_api;

/
