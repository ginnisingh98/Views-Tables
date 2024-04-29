--------------------------------------------------------
--  DDL for Package Body HR_POSITION_REQUIREMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_POSITION_REQUIREMENT_API" as
/* $Header: pepsrapi.pkb 115.9 2002/12/11 11:51:33 eumenyio ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_position_requirement_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_position_requirement >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_position_requirement
  (p_validate                      in     boolean  default false
  ,p_id_flex_num                   in     number
  ,p_position_id                   in     number
  ,p_comments                      in     varchar2 default null
  ,p_essential                     in     varchar2 default 'N'
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
  ,p_job_requirement_id               out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_analysis_criteria_id          in out nocopy number
  ) is
--
-- Declare cursors and local variables
--
  l_business_group_id       number;
  l_analysis_criteria_id    number := p_analysis_criteria_id;
  l_proc                    varchar2(72)
  := g_package||'create_position_requirement';
  l_analysis_criteria_id_temp number := p_analysis_criteria_id;
  --
  -- bug 2292372 initialize l_analysis_criteria_id and segment variables with
  -- values where these are passed into program.
  --
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
  --
  -- bug 2292372 new variable to indicate whether key flex id parameter
  -- enters the program with a value.
  --
  l_null_ind                 number(1)    := 0;
  --
  -- Declare additional OUT variables
  --
  l_job_requirement_id      number;
  l_object_version_number   number;
  l_anc_name                varchar2(2000);
  --
  -- Changed 02-Oct-99 SCNair (per_positions to hr_positions_f)
  -- Date tracked Positions requirement
  --
  cursor csr_pos_bg is
    select business_group_id
    from hr_positions_f
    where position_id = p_position_id;
   --
   -- bug 2292372 get segment values where analysis criteria id is known
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
    from   per_analysis_criteria
    where  analysis_criteria_id = l_analysis_criteria_id;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_position_requirement;
  --
  -- 2292372 get segment values if p_analysis_criteria_id entered with a value
  --
  if l_analysis_criteria_id is not null
  --
  then
  --
     hr_utility.set_location(l_proc, 15);
     --
     -- set indicator to show p_criteria_analysis_id did not enter program null
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
           l_analysis_criteria_id := NULL;
           l_null_ind := 0;
           hr_utility.set_location(l_proc, 27);
        end if;
     close c_segments;
  else
     l_null_ind := 0;
  end if;
  --
  begin
  --
    --
    -- Start of API User Hook for the before hook of create_position_requirement
    --
    hr_position_requirement_bk1.create_position_requirement_b
      (p_id_flex_num                   => p_id_flex_num
      ,p_position_id                   => p_position_id
      ,p_comments                      => p_comments
      ,p_essential                     => p_essential
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
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_POSITION_REQUIREMENT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_position_requirement
    --
  end;
  --
  -- Get business_group_id using position.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'position_id',
     p_argument_value => p_position_id);
  --
  hr_utility.set_location(l_proc, 15);
  --
  open  csr_pos_bg;
  fetch csr_pos_bg
  into l_business_group_id;
  --
  if csr_pos_bg%notfound then
     close csr_pos_bg;
     hr_utility.set_message(801, 'HR_51093_POS_NOT_EXIST');
     hr_utility.raise_error;
  else
     close csr_pos_bg;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  --  Only call this if p_analysis_criteria_id has no value
  --
  if l_null_ind = 0
  then
     --
     -- Insert or select the analysis criteria id
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
     ,p_concat_segments_out   => l_anc_name
     );
  end if;
  --
  -- Insert Job Requirements.
  --
  -- Set local analysis criteria to pass to ins jbr
  --
  hr_utility.set_location(l_proc, 25);
  --
  per_jbr_ins.ins
  (p_job_requirement_id		  => l_job_requirement_id
  ,p_business_group_id            => l_business_group_id
  ,p_analysis_criteria_id         => l_analysis_criteria_id
  ,p_comments                     => p_comments
  ,p_essential                    => p_essential
  ,p_position_id		  => p_position_id
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
  ,p_object_version_number        => l_object_version_number
  ,p_validate                     => FALSE
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_position_requirement
    --
    hr_position_requirement_bk1.create_position_requirement_a
      (p_id_flex_num                   => p_id_flex_num
      ,p_position_id                   => p_position_id
      ,p_comments                      => p_comments
      ,p_essential                     => p_essential
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
      ,p_job_requirement_id            => l_job_requirement_id
      ,p_object_version_number         => l_object_version_number
      ,p_analysis_criteria_id          => l_analysis_criteria_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_POSITION_REQUIREMENT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_position_requirement
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set output arguments
  --
  p_job_requirement_id     := l_job_requirement_id;
  p_object_version_number  := l_object_version_number;
  p_analysis_criteria_id   := l_analysis_criteria_id;
  --
  hr_utility.set_location('Leaving:'||l_proc, 35);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_position_requirement;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_job_requirement_id             := null;
    p_object_version_number          := null;
    if l_null_ind = 0
    then
       p_analysis_criteria_id        := null;
    end if;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_job_requirement_id             := null;
    p_object_version_number          := null;
    p_analysis_criteria_id           := l_analysis_criteria_id_temp;
    ROLLBACK TO create_position_requirement;
    raise;
    --
    -- End of fix.
    --
end create_position_requirement;
--
end hr_position_requirement_api;
--

/
