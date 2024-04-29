--------------------------------------------------------
--  DDL for Package Body HR_SIT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SIT_API" as
/* $Header: pesitapi.pkb 120.2.12010000.3 2009/03/02 11:10:05 ktithy ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  HR_SIT_API.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_sit >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_sit
  (p_validate                  in     boolean default false
  ,p_person_id                 in     number
  ,p_business_group_id         in     number
  ,p_id_flex_num               in     number
  ,p_effective_date            in     date
  ,p_comments                  in     varchar2 default null
  ,p_date_from                 in     date     default null
  ,p_date_to                   in     date     default null
  ,p_request_id                in     number   default null
  ,p_program_application_id    in     number   default null
  ,p_program_id                in     number   default null
  ,p_program_update_date       in     date     default null
  ,p_attribute_category        in     varchar2 default null
  ,p_attribute1                in     varchar2 default null
  ,p_attribute2                in     varchar2 default null
  ,p_attribute3                in     varchar2 default null
  ,p_attribute4                in     varchar2 default null
  ,p_attribute5                in     varchar2 default null
  ,p_attribute6                in     varchar2 default null
  ,p_attribute7                in     varchar2 default null
  ,p_attribute8                in     varchar2 default null
  ,p_attribute9                in     varchar2 default null
  ,p_attribute10               in     varchar2 default null
  ,p_attribute11               in     varchar2 default null
  ,p_attribute12               in     varchar2 default null
  ,p_attribute13               in     varchar2 default null
  ,p_attribute14               in     varchar2 default null
  ,p_attribute15               in     varchar2 default null
  ,p_attribute16               in     varchar2 default null
  ,p_attribute17               in     varchar2 default null
  ,p_attribute18               in     varchar2 default null
  ,p_attribute19               in     varchar2 default null
  ,p_attribute20               in     varchar2 default null
  ,p_segment1                  in     varchar2 default null
  ,p_segment2                  in     varchar2 default null
  ,p_segment3                  in     varchar2 default null
  ,p_segment4                  in     varchar2 default null
  ,p_segment5                  in     varchar2 default null
  ,p_segment6                  in     varchar2 default null
  ,p_segment7                  in     varchar2 default null
  ,p_segment8                  in     varchar2 default null
  ,p_segment9                  in     varchar2 default null
  ,p_segment10                 in     varchar2 default null
  ,p_segment11                 in     varchar2 default null
  ,p_segment12                 in     varchar2 default null
  ,p_segment13                 in     varchar2 default null
  ,p_segment14                 in     varchar2 default null
  ,p_segment15                 in     varchar2 default null
  ,p_segment16                 in     varchar2 default null
  ,p_segment17                 in     varchar2 default null
  ,p_segment18                 in     varchar2 default null
  ,p_segment19                 in     varchar2 default null
  ,p_segment20                 in     varchar2 default null
  ,p_segment21                 in     varchar2 default null
  ,p_segment22                 in     varchar2 default null
  ,p_segment23                 in     varchar2 default null
  ,p_segment24                 in     varchar2 default null
  ,p_segment25                 in     varchar2 default null
  ,p_segment26                 in     varchar2 default null
  ,p_segment27                 in     varchar2 default null
  ,p_segment28                 in     varchar2 default null
  ,p_segment29                 in     varchar2 default null
  ,p_segment30                 in     varchar2 default null
  ,p_concat_segments           in     varchar2 default null
  ,p_analysis_criteria_id      in out nocopy number
  ,p_person_analysis_id        out nocopy    number
  ,p_pea_object_version_number out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'create_sit';
  l_analysis_criteria_id       per_person_analyses.analysis_criteria_id%TYPE := p_analysis_criteria_id;
  l_person_analysis_id         per_person_analyses.person_analysis_id%TYPE;
  l_discard                    number;
  l_name                       varchar2(700);
  l_effective_date             date;
  l_object_version_number      per_person_analyses.object_version_number%TYPE;
  l_date_from                  per_person_analyses.date_from%TYPE;
  l_date_to                    per_person_analyses.date_to%TYPE;
  l_program_update_date        per_person_analyses.program_update_date%TYPE;
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
  --
  --
  cursor csr_bg is
    select 1
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
  -- the cursor ancsel ensures the id_flex_num must be valid, enabled for
  -- the id_flex_code 'PEA' and must exist within PER_SPECIAL_INFO_TYPES
  -- for the business group.
  --
  cursor ancsel is
    select   1
    from     per_special_info_types pc,
             fnd_id_flex_structures fs
    where    fs.id_flex_num           = pc.id_flex_num
    and      fs.id_flex_code          = 'PEA'
    and      pc.enabled_flag          = 'Y'
    and      pc.business_group_id + 0 = p_business_group_id
    and      pc.id_flex_num           = p_id_flex_num;
  --
  -- the cursor ancerrsel1 determines if the id_flex_num is valid
  -- note: only called when cursor ancsel fails
  --
  cursor ancerrsel1 is
    select 1
    from   fnd_id_flex_structures fs
    where  fs.id_flex_num           = p_id_flex_num
    and    fs.id_flex_code          = 'PEA';
  --
  -- the cursor ancerrsel2 determines if the id_flex_num is valid for
  -- per_special_info_types
  -- note: only called when cursor ancsel fails
  --
  cursor ancerrsel2 is
    select 1
    from   per_special_info_types pc
    where  pc.business_group_id + 0 = p_business_group_id
    and    pc.id_flex_num           = p_id_flex_num;
  --
  -- the cursor c1 derives segment values using p_analysis_criteria_id
  -- if it has a value
  -- note: only called if p_analysis_criteria_id is not null
  --
  cursor c1 is
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
    from   per_analysis_criteria
    where  analysis_criteria_id = l_analysis_criteria_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_sit;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate date, date_from, date_to and program_update_date values,
  -- effectively removing time element.
  --
  l_effective_date            := trunc(p_effective_date);
  l_date_from                 := trunc(p_date_from);
  l_date_to                   := trunc(p_date_to);
  l_program_update_date       := trunc(p_program_update_date);
  --
  -- Check if the p_business_group_id is valid
  --
  open csr_bg;
  fetch csr_bg into l_discard;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check if the p_person_id is valid
  --
  per_pea_bus.chk_person_id
    (p_person_id             => p_person_id,
     p_business_group_id     => p_business_group_id,
     p_effective_date        => l_effective_date
    );
  --
  -- get segment values if p_analysis_criteria_id has a value
  --
  if l_analysis_criteria_id is not null
  then
     -- set indicator to show p_criteria_analysis_id did not enter program null
     --
     l_null_ind := 1;
     --
     open c1;
        fetch c1 into l_segment1,
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
     close c1;
  end if;
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_sit
    --
    hr_sit_bk1.create_sit_b
      (p_person_id                 => p_person_id
      ,p_business_group_id         => p_business_group_id
      ,p_id_flex_num               => p_id_flex_num
      ,p_effective_date            => l_effective_date
      ,p_comments                  => p_comments
      ,p_date_from                 => l_date_from
      ,p_date_to                   => l_date_to
      ,p_request_id                => p_request_id
      ,p_program_application_id    => p_program_application_id
      ,p_program_id                => p_program_id
      ,p_program_update_date       => l_program_update_date
      ,p_attribute_category        => p_attribute_category
      ,p_attribute1                => p_attribute1
      ,p_attribute2                => p_attribute2
      ,p_attribute3                => p_attribute3
      ,p_attribute4                => p_attribute4
      ,p_attribute5                => p_attribute5
      ,p_attribute6                => p_attribute6
      ,p_attribute7                => p_attribute7
      ,p_attribute8                => p_attribute8
      ,p_attribute9                => p_attribute9
      ,p_attribute10               => p_attribute10
      ,p_attribute11               => p_attribute11
      ,p_attribute12               => p_attribute12
      ,p_attribute13               => p_attribute13
      ,p_attribute14               => p_attribute14
      ,p_attribute15               => p_attribute15
      ,p_attribute16               => p_attribute16
      ,p_attribute17               => p_attribute17
      ,p_attribute18               => p_attribute18
      ,p_attribute19               => p_attribute19
      ,p_attribute20               => p_attribute20
      ,p_segment1                  => l_segment1
      ,p_segment2                  => l_segment2
      ,p_segment3                  => l_segment3
      ,p_segment4                  => l_segment4
      ,p_segment5                  => l_segment5
      ,p_segment6                  => l_segment6
      ,p_segment7                  => l_segment7
      ,p_segment8                  => l_segment8
      ,p_segment9                  => l_segment9
      ,p_segment10                 => l_segment10
      ,p_segment11                 => l_segment11
      ,p_segment12                 => l_segment12
      ,p_segment13                 => l_segment13
      ,p_segment14                 => l_segment14
      ,p_segment15                 => l_segment15
      ,p_segment16                 => l_segment16
      ,p_segment17                 => l_segment17
      ,p_segment18                 => l_segment18
      ,p_segment19                 => l_segment19
      ,p_segment20                 => l_segment20
      ,p_segment21                 => l_segment21
      ,p_segment22                 => l_segment22
      ,p_segment23                 => l_segment23
      ,p_segment24                 => l_segment24
      ,p_segment25                 => l_segment25
      ,p_segment26                 => l_segment26
      ,p_segment27                 => l_segment27
      ,p_segment28                 => l_segment28
      ,p_segment29                 => l_segment29
      ,p_segment30                 => l_segment30
      ,p_concat_segments           => p_concat_segments
      );
 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SIT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_sit
    --
 end;
    --
    open ancsel;
    fetch ancsel into l_discard;
    if ancsel%notfound then
      close ancsel;
      --
      -- the flex structure has not been found therefore we must
      -- determine the error
      --
      open ancerrsel1;
      fetch ancerrsel1 into l_discard;
      if ancerrsel1%notfound then
        close ancerrsel1;
        hr_utility.set_message(801, 'HR_6039_ALL_CANT_GET_FFIELD');
        hr_utility.set_message_token('FLEXFIELD_STRUCTURE',
                                     p_id_flex_num);
        hr_utility.raise_error;
      end if;
      close ancerrsel1;
      --
      open ancerrsel2;
      fetch ancerrsel2 into l_discard;
      if ancerrsel2%notfound then
      close ancerrsel2;
        --
        -- the row does not exist in PER_SPECIAL_INFO_TYPES
        --
        hr_utility.set_message(801, 'HR_51114_JBR_SPCIAL_NOT_EXIST');
        hr_utility.raise_error;
      end if;
      close ancerrsel2;
        --
        -- the row is not enabled in PER_SPECIAL_INFO_TYPES
        --
        hr_utility.set_message(801, 'HR_51115_JBR_SPCIAL_NOT_ENABLE');
        hr_utility.raise_error;
    end if;
    close ancsel;
  --
  hr_utility.set_location(l_proc, 30);
  --
  --  Only call this if p_analysis_criteria_id has no value
  --
  if l_analysis_criteria_id is null
  then
     --
     --  Determine the position defintion by calling ins_or_sel
     --
     hr_kflex_utility.ins_or_sel_keyflex_comb
       (p_appl_short_name       => 'PER'
       ,p_flex_code             => 'PEA'
       ,p_flex_num              => p_id_flex_num
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
       ,p_ccid                  => l_analysis_criteria_id
       ,p_concat_segments_out   => l_name
       );
      --
      hr_utility.set_location(l_proc, 40);
      --
  end if;
  --
  if l_analysis_criteria_id is not null
  then
    --
    -- insert person_analyses into PER_PERSON_ANALYSES
    per_pea_ins.ins
     (p_business_group_id          => p_business_group_id
     ,p_analysis_criteria_id       => l_analysis_criteria_id
     ,p_person_id                  => p_person_id
     ,p_id_flex_num                => p_id_flex_num
     ,p_effective_date             => l_effective_date
     ,p_comments                   => p_comments
     ,p_date_from                  => l_date_from
     ,p_date_to                    => l_date_to
     ,p_request_id                 => p_request_id
     ,p_program_application_id     => p_program_application_id
     ,p_program_id                 => p_program_id
     ,p_program_update_date        => l_program_update_date
     ,p_attribute_category         => p_attribute_category
     ,p_attribute1                 => p_attribute1
     ,p_attribute2                 => p_attribute2
     ,p_attribute3                 => p_attribute3
     ,p_attribute4                 => p_attribute4
     ,p_attribute5                 => p_attribute5
     ,p_attribute6                 => p_attribute6
     ,p_attribute7                 => p_attribute7
     ,p_attribute8                 => p_attribute8
     ,p_attribute9                 => p_attribute9
     ,p_attribute10                => p_attribute10
     ,p_attribute11                => p_attribute11
     ,p_attribute12                => p_attribute12
     ,p_attribute13                => p_attribute13
     ,p_attribute14                => p_attribute14
     ,p_attribute15                => p_attribute15
     ,p_attribute16                => p_attribute16
     ,p_attribute17                => p_attribute17
     ,p_attribute18                => p_attribute18
     ,p_attribute19                => p_attribute19
     ,p_attribute20                => p_attribute20
     ,p_object_version_number      => l_object_version_number
     ,p_person_analysis_id         => l_person_analysis_id
     );
  end if;
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    hr_sit_bk1.create_sit_a
      (p_person_id                     => p_person_id
      ,p_business_group_id             => p_business_group_id
      ,p_id_flex_num                   => p_id_flex_num
      ,p_effective_date                => l_effective_date
      ,p_comments                      => p_comments
      ,p_date_from                     => l_date_from
      ,p_date_to                       => l_date_to
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => l_program_update_date
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
      ,p_analysis_criteria_id          => l_analysis_criteria_id
      ,p_person_analysis_id            => l_person_analysis_id
      ,p_pea_object_version_number     => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SIT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_sit
    --
  end;
  --
  hr_utility.set_location(l_proc, 70);
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 75);
  --
  -- Set OUT parameters
  --
  if l_null_ind = 1
  then
     p_person_analysis_id        := l_person_analysis_id;
     p_pea_object_version_number := l_object_version_number;
  else
     p_analysis_criteria_id      := l_analysis_criteria_id;
     p_person_analysis_id        := l_person_analysis_id;
     p_pea_object_version_number := l_object_version_number;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_sit;
    --
    -- Set OUT parameters to null
    --
  if l_null_ind = 1
  then
     p_person_analysis_id        := null;
     p_pea_object_version_number := null;
  else
     p_analysis_criteria_id      := null;
     p_person_analysis_id        := null;
     p_pea_object_version_number := null;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
  --
  when others then
  --
  -- A validation or unexpected error has occured
  --
  -- Added as part of the fix to bug 632479
  --
  p_analysis_criteria_id      := l_analysis_criteria_id;
  p_person_analysis_id        := null;
  p_pea_object_version_number := null;
  ROLLBACK TO create_sit;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
  raise;
  --
end create_sit;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_sit >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_sit
  (p_validate                  in     boolean default false
  ,p_person_analysis_id        in     number
  ,p_pea_object_version_number in out nocopy number
  ,p_comments                  in     varchar2 default hr_api.g_varchar2
  ,p_date_from                 in     date     default hr_api.g_date
  ,p_date_to                   in     date     default hr_api.g_date
  ,p_request_id                in     number   default hr_api.g_number
  ,p_program_application_id    in     number   default hr_api.g_number
  ,p_program_id                in     number   default hr_api.g_number
  ,p_program_update_date       in     date     default hr_api.g_date
  ,p_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_segment1                  in     varchar2 default hr_api.g_varchar2
  ,p_segment2                  in     varchar2 default hr_api.g_varchar2
  ,p_segment3                  in     varchar2 default hr_api.g_varchar2
  ,p_segment4                  in     varchar2 default hr_api.g_varchar2
  ,p_segment5                  in     varchar2 default hr_api.g_varchar2
  ,p_segment6                  in     varchar2 default hr_api.g_varchar2
  ,p_segment7                  in     varchar2 default hr_api.g_varchar2
  ,p_segment8                  in     varchar2 default hr_api.g_varchar2
  ,p_segment9                  in     varchar2 default hr_api.g_varchar2
  ,p_segment10                 in     varchar2 default hr_api.g_varchar2
  ,p_segment11                 in     varchar2 default hr_api.g_varchar2
  ,p_segment12                 in     varchar2 default hr_api.g_varchar2
  ,p_segment13                 in     varchar2 default hr_api.g_varchar2
  ,p_segment14                 in     varchar2 default hr_api.g_varchar2
  ,p_segment15                 in     varchar2 default hr_api.g_varchar2
  ,p_segment16                 in     varchar2 default hr_api.g_varchar2
  ,p_segment17                 in     varchar2 default hr_api.g_varchar2
  ,p_segment18                 in     varchar2 default hr_api.g_varchar2
  ,p_segment19                 in     varchar2 default hr_api.g_varchar2
  ,p_segment20                 in     varchar2 default hr_api.g_varchar2
  ,p_segment21                 in     varchar2 default hr_api.g_varchar2
  ,p_segment22                 in     varchar2 default hr_api.g_varchar2
  ,p_segment23                 in     varchar2 default hr_api.g_varchar2
  ,p_segment24                 in     varchar2 default hr_api.g_varchar2
  ,p_segment25                 in     varchar2 default hr_api.g_varchar2
  ,p_segment26                 in     varchar2 default hr_api.g_varchar2
  ,p_segment27                 in     varchar2 default hr_api.g_varchar2
  ,p_segment28                 in     varchar2 default hr_api.g_varchar2
  ,p_segment29                 in     varchar2 default hr_api.g_varchar2
  ,p_segment30                 in     varchar2 default hr_api.g_varchar2
  ,p_concat_segments           in     varchar2 default hr_api.g_varchar2
  ,p_analysis_criteria_id      in out nocopy number
  ) is
  --
  --
  l_proc                       varchar2(72) := g_package||'update_sit';
  l_analysis_criteria_id       per_person_analyses.analysis_criteria_id%TYPE := p_analysis_criteria_id;
  l_object_version_number      per_person_analyses.object_version_number%TYPE;
  l_pea_object_version_number      per_person_analyses.object_version_number%TYPE := p_pea_object_version_number;
  l_id_flex_num                per_person_analyses.id_flex_num%TYPE;
  l_name                       varchar2(700);
  l_business_group_id          per_person_analyses.business_group_id%TYPE;
  l_api_updating               boolean;
  l_date_from                  per_person_analyses.date_from%TYPE;
  l_date_to                    per_person_analyses.date_to%TYPE;
  l_program_update_date        per_person_analyses.program_update_date%TYPE;
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
  --
  -- Declare cursors and local variables
  --
  -- the cursor c1 derives segment values using p_analysis_criteria_id if
  -- it has a value
  -- note: only called if p_analysis_criteria_id is not null
  --
  cursor c1 is
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
    from   per_analysis_criteria
    where  analysis_criteria_id = l_analysis_criteria_id;
  --
  --
  -- Cursor to select the id_flex_num required for the keyflex utility.
  --
  cursor c2 is
    select id_flex_num
    from   per_person_analyses
    where  person_analysis_id = p_person_analysis_id;
  --
  --
  begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_sit;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate date, date_from, date_to and program_update_date values,
  -- effectively removing time element.
  --
  l_date_from                 := trunc(p_date_from);
  l_date_to                   := trunc(p_date_to);
  l_program_update_date       := trunc(p_program_update_date);
  l_object_version_number     := p_pea_object_version_number;
  --
  if l_analysis_criteria_id is not null
  then
     l_null_ind := 1;
     open c1;
        fetch c1 into l_segment1,
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
     close c1;
  END IF;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_sit_bk2.update_sit_b
      (p_person_analysis_id        => p_person_analysis_id
      ,p_pea_object_version_number => p_pea_object_version_number
      ,p_comments                  => p_comments
      ,p_date_from                 => l_date_from
      ,p_date_to                   => l_date_to
      ,p_request_id                => p_request_id
      ,p_program_application_id    => p_program_application_id
      ,p_program_id                => p_program_id
      ,p_program_update_date       => l_program_update_date
      ,p_attribute_category        => p_attribute_category
      ,p_attribute1                => p_attribute1
      ,p_attribute2                => p_attribute2
      ,p_attribute3                => p_attribute3
      ,p_attribute4                => p_attribute4
      ,p_attribute5                => p_attribute5
      ,p_attribute6                => p_attribute6
      ,p_attribute7                => p_attribute7
      ,p_attribute8                => p_attribute8
      ,p_attribute9                => p_attribute9
      ,p_attribute10               => p_attribute10
      ,p_attribute11               => p_attribute11
      ,p_attribute12               => p_attribute12
      ,p_attribute13               => p_attribute13
      ,p_attribute14               => p_attribute14
      ,p_attribute15               => p_attribute15
      ,p_attribute16               => p_attribute16
      ,p_attribute17               => p_attribute17
      ,p_attribute18               => p_attribute18
      ,p_attribute19               => p_attribute19
      ,p_attribute20               => p_attribute20
      ,p_segment1                  => l_segment1
      ,p_segment2                  => l_segment2
      ,p_segment3                  => l_segment3
      ,p_segment4                  => l_segment4
      ,p_segment5                  => l_segment5
      ,p_segment6                  => l_segment6
      ,p_segment7                  => l_segment7
      ,p_segment8                  => l_segment8
      ,p_segment9                  => l_segment9
      ,p_segment10                 => l_segment10
      ,p_segment11                 => l_segment11
      ,p_segment12                 => l_segment12
      ,p_segment13                 => l_segment13
      ,p_segment14                 => l_segment14
      ,p_segment15                 => l_segment15
      ,p_segment16                 => l_segment16
      ,p_segment17                 => l_segment17
      ,p_segment18                 => l_segment18
      ,p_segment19                 => l_segment19
      ,p_segment20                 => l_segment20
      ,p_segment21                 => l_segment21
      ,p_segment22                 => l_segment22
      ,p_segment23                 => l_segment23
      ,p_segment24                 => l_segment24
      ,p_segment25                 => l_segment25
      ,p_segment26                 => l_segment26
      ,p_segment27                 => l_segment27
      ,p_segment28                 => l_segment28
      ,p_segment29                 => l_segment29
      ,p_segment30                 => l_segment30
      ,p_concat_segments           => p_concat_segments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SIT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_position
    --
  end;
  --
  open c2;
    fetch c2 into l_id_flex_num;
    if c2%NOTFOUND then
      --
      close c2;
      -- the row is not enabled in PER_SPECIAL_INFO_TYPES
      --
      hr_utility.set_message(800, 'PER_52508_PEA_INV_FLEX');
      hr_utility.raise_error;
      --
    end if;
  close c2;
  --
  hr_utility.set_location(l_proc, 30);
  --
  --
  -- Retrieve Current person analysis Details from person_analyses
  --
  l_api_updating := per_pea_shd.api_updating
    (p_person_analysis_id    => p_person_analysis_id
    ,p_object_version_number => p_pea_object_version_number);
  --
  hr_utility.set_location(l_proc, 40);
  --
  if not l_api_updating then
     hr_utility.set_location(l_proc, 50);
     --
     -- As this an updating API, the person_analysis_id must exist.
     --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  else
     hr_utility.set_location(l_proc, 60);
     l_id_flex_num            := per_pea_shd.g_old_rec.id_flex_num;
     l_business_group_id      := per_pea_shd.g_old_rec.business_group_id;
  end if;
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- update analysis criteria in PER_ANALYSIS_CRITERIA
  --
  --  Determine the position defintion by calling upd_or_sel
  --
  if l_analysis_criteria_id is null
  then
     --
     l_analysis_criteria_id := per_pea_shd.g_old_rec.analysis_criteria_id;
     --
     hr_kflex_utility.upd_or_sel_keyflex_comb
       (p_appl_short_name       => 'PER'
       ,p_flex_code             => 'PEA'
       ,p_flex_num              => l_id_flex_num
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
       ,p_ccid                  => l_analysis_criteria_id
       ,p_concat_segments_out   => l_name
       );
  END IF;
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- update person_analyses into PER_PERSON_ANALYSES
  --
  per_pea_upd.upd
     (p_person_analysis_id         => p_person_analysis_id
     ,p_analysis_criteria_id       => l_analysis_criteria_id
     ,p_id_flex_num                => l_id_flex_num
     ,p_comments                   => p_comments
     ,p_date_from                  => l_date_from
     ,p_date_to                    => l_date_to
     ,p_request_id                 => p_request_id
     ,p_program_application_id     => p_program_application_id
     ,p_program_id                 => p_program_id
     ,p_program_update_date        => l_program_update_date
     ,p_attribute_category         => p_attribute_category
     ,p_attribute1                 => p_attribute1
     ,p_attribute2                 => p_attribute2
     ,p_attribute3                 => p_attribute3
     ,p_attribute4                 => p_attribute4
     ,p_attribute5                 => p_attribute5
     ,p_attribute6                 => p_attribute6
     ,p_attribute7                 => p_attribute7
     ,p_attribute8                 => p_attribute8
     ,p_attribute9                 => p_attribute9
     ,p_attribute10                => p_attribute10
     ,p_attribute11                => p_attribute11
     ,p_attribute12                => p_attribute12
     ,p_attribute13                => p_attribute13
     ,p_attribute14                => p_attribute14
     ,p_attribute15                => p_attribute15
     ,p_attribute16                => p_attribute16
     ,p_attribute17                => p_attribute17
     ,p_attribute18                => p_attribute18
     ,p_attribute19                => p_attribute19
     ,p_attribute20                => p_attribute20
     ,p_object_version_number      => l_object_version_number
     );
  --
  hr_utility.set_location(l_proc, 90);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_sit
    --
    hr_sit_bk2.update_sit_a
      (p_person_analysis_id            => p_person_analysis_id
      ,p_pea_object_version_number     => l_object_version_number
      ,p_comments                      => p_comments
      ,p_date_from                     => l_date_from
      ,p_date_to                       => l_date_to
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => l_program_update_date
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
      ,p_analysis_criteria_id          => l_analysis_criteria_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SIT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_sit
    --
  end;
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 95);
  --
  --Set OUT parameters
  --
  if l_null_ind = 1
  then
     p_pea_object_version_number := l_object_version_number;
  else
     p_analysis_criteria_id      := l_analysis_criteria_id;
     p_pea_object_version_number := l_object_version_number;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_sit;
    --
    -- Only set output warning arguments
    -- (any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
    if l_null_ind = 0
    then
       p_analysis_criteria_id    := null;
    end if;
  --
  hr_utility.set_location(' Leaving:' ||l_proc, 110);
  --
  when others then
  --
  -- A validation or unexpected error has occured
  --
  -- Added as part of the fix to bug 632479
  --
  p_pea_object_version_number := l_pea_object_version_number;
  p_analysis_criteria_id    := l_analysis_criteria_id;
   ROLLBACK TO update_sit;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 120);
  --
  raise;
  --
end update_sit;
--
-- ----------------------------------------------------------------------------
-- |----------------------------<  delete_sit  >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This Special Information type business process deletes a special
--   information type record from the table PER_PERSON_ANALYSES.  Note
--   it does not alter the key flex codes combination table
--   PER_ANALYSIS_CRITERIA, since a single code combination could
--   be used by more than one special information type record on
--   PER_PERSON_ANALYSES
--
-- Prerequisites:
--   The SIT specified by p_person_analysis_id and p_object_version_number
--   must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                      N   boolean  If true, the database
--                                                remains unchanged. If false
--                                                then the employee will be
--                                                deleted from the database.
--   p_person_analysis_id            Y   number   ID of PER_PERSON_ANALYSES
--                                                record for delete.
--   p_pea_object_version_number     Y   number   Version number of the PPA
--                                                record

-- Post Success:
--   The API deletes the SIT record in PER_PERSON_ANALYSES, but leaves
--   the code combination unchanged.
--
-- Post Failure:
--   The API does not delete the special infomration type record and raises
--   an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
procedure delete_sit
  (p_validate                       in     boolean  default false
  ,p_person_analysis_id             in     number
  ,p_pea_object_version_number      in     number
  ) IS
--
l_proc                  varchar2(72) := g_package||'delete_sit';
--
BEGIN
   --
   hr_utility.set_location('Entering:'|| l_proc,10);
   --
   -- Issue a savepoint
   --
   savepoint delete_sit;
   --
   hr_utility.set_location('Entering:'|| l_proc,20);
   --
   -- Insert Before delete user hook
   --
   begin
    hr_sit_bk3.delete_sit_b
      (p_person_analysis_id        => p_person_analysis_id
      ,p_pea_object_version_number => p_pea_object_version_number
      );
   exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name => 'DELETE_SIT'
         ,p_hook_type   => 'BP'
         );
     --
     -- End of API User Hook for the before hook of delete SIT
     --
   end;
   --
   --
   --
   per_pea_del.del(p_person_analysis_id => p_person_analysis_id,
                   p_object_version_number => p_pea_object_version_number,
                   p_validate => false);
   --
   hr_utility.set_location('Entering:'|| l_proc,20);
   --
   -- Insert After delete user hook
   --
   begin
    hr_sit_bk3.delete_sit_a
      (p_person_analysis_id        => p_person_analysis_id
      ,p_pea_object_version_number => p_pea_object_version_number
      );
   exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name => 'DELETE_SIT'
         ,p_hook_type   => 'AP'
         );
     --
     -- End of API User Hook for the before hook of delete SIT
     --
   end;
   --
   --
   -- If in validate mode, raise the API validation exception
   --
   if p_validate then
      raise hr_api.validate_enabled;
   end if;
--
EXCEPTION
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_sit;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
     ROLLBACK TO delete_sit;
    raise;
--
END delete_sit;
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_person_analysis_id                   in     number
  ,p_pea_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||' lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  per_pea_shd.lck
    (
      p_person_analysis_id                 => p_person_analysis_id
     ,p_object_version_number      => p_pea_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
end hr_sit_api;

/
