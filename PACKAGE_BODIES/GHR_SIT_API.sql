--------------------------------------------------------
--  DDL for Package Body GHR_SIT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_SIT_API" as
/* $Header: ghsitapi.pkb 115.3 2003/01/30 16:32:17 asubrahm ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  HR_SIT_API.';

-- ----------------------------------------------------------------------------
-- |-----------------------------< create_sit >-------------------------------|
-- ----------------------------------------------------------------------------
procedure create_sit
  (p_validate                  in    boolean default false
  ,p_person_id                 in    number
  ,p_business_group_id         in    number
  ,p_id_flex_num               in    number
  ,p_effective_date            in    date
  ,p_comments                  in    varchar2 default null
  ,p_date_from                 in    date     default null
  ,p_date_to                   in    date     default null
  ,p_request_id                in    number   default null
  ,p_program_application_id    in    number   default null
  ,p_program_id                in    number   default null
  ,p_program_update_date       in    date     default null
  ,p_attribute_category        in    varchar2 default null
  ,p_attribute1                in    varchar2 default null
  ,p_attribute2                in    varchar2 default null
  ,p_attribute3                in    varchar2 default null
  ,p_attribute4                in    varchar2 default null
  ,p_attribute5                in    varchar2 default null
  ,p_attribute6                in    varchar2 default null
  ,p_attribute7                in    varchar2 default null
  ,p_attribute8                in    varchar2 default null
  ,p_attribute9                in    varchar2 default null
  ,p_attribute10               in    varchar2 default null
  ,p_attribute11               in    varchar2 default null
  ,p_attribute12               in    varchar2 default null
  ,p_attribute13               in    varchar2 default null
  ,p_attribute14               in    varchar2 default null
  ,p_attribute15               in    varchar2 default null
  ,p_attribute16               in    varchar2 default null
  ,p_attribute17               in    varchar2 default null
  ,p_attribute18               in    varchar2 default null
  ,p_attribute19               in    varchar2 default null
  ,p_attribute20               in    varchar2 default null
  ,p_segment1                  in    varchar2 default null
  ,p_segment2                  in    varchar2 default null
  ,p_segment3                  in    varchar2 default null
  ,p_segment4                  in    varchar2 default null
  ,p_segment5                  in    varchar2 default null
  ,p_segment6                  in    varchar2 default null
  ,p_segment7                  in    varchar2 default null
  ,p_segment8                  in    varchar2 default null
  ,p_segment9                  in    varchar2 default null
  ,p_segment10                 in    varchar2 default null
  ,p_segment11                 in    varchar2 default null
  ,p_segment12                 in    varchar2 default null
  ,p_segment13                 in    varchar2 default null
  ,p_segment14                 in    varchar2 default null
  ,p_segment15                 in    varchar2 default null
  ,p_segment16                 in    varchar2 default null
  ,p_segment17                 in    varchar2 default null
  ,p_segment18                 in    varchar2 default null
  ,p_segment19                 in    varchar2 default null
  ,p_segment20                 in    varchar2 default null
  ,p_segment21                 in    varchar2 default null
  ,p_segment22                 in    varchar2 default null
  ,p_segment23                 in    varchar2 default null
  ,p_segment24                 in    varchar2 default null
  ,p_segment25                 in    varchar2 default null
  ,p_segment26                 in    varchar2 default null
  ,p_segment27                 in    varchar2 default null
  ,p_segment28                 in    varchar2 default null
  ,p_segment29                 in    varchar2 default null
  ,p_segment30                 in    varchar2 default null
  ,p_analysis_criteria_id      out nocopy   number
  ,p_person_analysis_id        out nocopy   number
  ,p_pea_object_version_number out nocopy   number
  ) is

  l_proc                       varchar2(72) := g_package||'create_sit';
  l_analysis_criteria_id       number;
  l_person_analysis_id         number;
  l_pea_object_version_number  number;
  l_exists               varchar2(2);
  --
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    savepoint ghr_create_sit;
  --
  --
  ghr_session.set_session_var_for_core
  (p_effective_date   =>  p_effective_date
  );

  hr_sit_api.create_sit
     (p_business_group_id          => p_business_group_id
     ,p_person_id                  => p_person_id
     ,p_id_flex_num                => p_id_flex_num
     ,p_effective_date             => trunc(p_effective_date)
     ,p_comments                   => p_comments
     ,p_date_from                  => trunc(p_date_from)
     ,p_date_to                    => trunc(p_date_to)
     ,p_request_id                 => p_request_id
     ,p_program_application_id     => p_program_application_id
     ,p_program_id                 => p_program_id
     ,p_program_update_date        => trunc(p_program_update_date)
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
     ,p_segment1                   => p_segment1
     ,p_segment2                   => p_segment2
     ,p_segment3                   => p_segment3
     ,p_segment4                   => p_segment4
     ,p_segment5                   => p_segment5
     ,p_segment6                   => p_segment6
     ,p_segment7                   => p_segment7
     ,p_segment8                   => p_segment8
     ,p_segment9                   => p_segment9
     ,p_segment10                  => p_segment10
     ,p_segment11                  => p_segment11
     ,p_segment12                  => p_segment12
     ,p_segment13                  => p_segment13
     ,p_segment14                  => p_segment14
     ,p_segment15                  => p_segment15
     ,p_segment16                  => p_segment16
     ,p_segment17                  => p_segment17
     ,p_segment18                  => p_segment18
     ,p_segment19                  => p_segment19
     ,p_segment20                  => p_segment20
     ,p_segment21                  => p_segment21
     ,p_segment22                  => p_segment22
     ,p_segment23                  => p_segment23
     ,p_segment24                  => p_segment24
     ,p_segment25                  => p_segment25
     ,p_segment26                  => p_segment26
     ,p_segment27                  => p_segment27
     ,p_segment28                  => p_segment28
     ,p_segment29                  => p_segment29
     ,p_segment30                  => p_segment30
     ,p_analysis_criteria_id       => l_analysis_criteria_id
     ,p_person_analysis_id         => l_person_analysis_id
     ,p_pea_object_version_number  => l_pea_object_version_number
     );
   hr_utility.set_location(l_proc,25);
   ghr_history_api.post_update_process;
  --Set OUT parameters
  --
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_analysis_criteria_id      := l_analysis_criteria_id;
  p_person_analysis_id        := l_person_analysis_id;
  p_pea_object_version_number := l_pea_object_version_number;

  hr_utility.set_location(' Leaving:'||l_proc, 20);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_create_sit;
    --
    -- Set OUT parameters to null
    --
  p_analysis_criteria_id      := null;
  p_person_analysis_id        := null;
  p_pea_object_version_number := null;

  when others then
   ROLLBACK TO ghr_create_sit;
   --
   -- Reset IN OUT parameters and set OUT parameters
   --
   p_analysis_criteria_id      := null;
   p_person_analysis_id        := null;
   p_pea_object_version_number := null;
   raise;

  hr_utility.set_location('Leaving:'|| l_proc, 54);
end create_sit;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_sit >-------------------------------|
-- ----------------------------------------------------------------------------
procedure update_sit
  (p_validate                  in     boolean default false
  ,p_person_analysis_id        in     number
  ,p_pea_object_version_number in out nocopy number
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
  ,p_analysis_criteria_id      out nocopy number
  ) is

  l_proc                       varchar2(72) := g_package||'update_sit';
  l_analysis_criteria_id       number;
  l_person_analysis_id         number;
  l_pea_object_version_number  number;
  l_id_flex_num                number;
  l_business_group_id          number;
  l_api_updating               boolean;
  l_exists                     varchar2(2);
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    savepoint ghr_update_sit;

  ghr_session.set_session_var_for_core
  (p_effective_date    =>   p_effective_date);

  l_pea_object_version_number := p_pea_object_version_number;

    hr_sit_api.update_sit
     (
     p_person_analysis_id         => p_person_analysis_id
     ,p_pea_object_version_number  => p_pea_object_version_number
     ,p_comments                   => p_comments
     ,p_date_from                  => trunc(p_date_from)
     ,p_date_to                    => trunc(p_date_to)
     ,p_request_id                 => p_request_id
     ,p_program_application_id     => p_program_application_id
     ,p_program_id                 => p_program_id
     ,p_program_update_date        => trunc(p_program_update_date)
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
     ,p_segment1                   => p_segment1
     ,p_segment2                   => p_segment2
     ,p_segment3                   => p_segment3
     ,p_segment4                   => p_segment4
     ,p_segment5                   => p_segment5
     ,p_segment6                   => p_segment6
     ,p_segment7                   => p_segment7
     ,p_segment8                   => p_segment8
     ,p_segment9                   => p_segment9
     ,p_segment10                  => p_segment10
     ,p_segment11                  => p_segment11
     ,p_segment12                  => p_segment12
     ,p_segment13                  => p_segment13
     ,p_segment14                  => p_segment14
     ,p_segment15                  => p_segment15
     ,p_segment16                  => p_segment16
     ,p_segment17                  => p_segment17
     ,p_segment18                  => p_segment18
     ,p_segment19                  => p_segment19
     ,p_segment20                  => p_segment20
     ,p_segment21                  => p_segment21
     ,p_segment22                  => p_segment22
     ,p_segment23                  => p_segment23
     ,p_segment24                  => p_segment24
     ,p_segment25                  => p_segment25
     ,p_segment26                  => p_segment26
     ,p_segment27                  => p_segment27
     ,p_segment28                  => p_segment28
     ,p_segment29                  => p_segment29
     ,p_segment30                  => p_segment30
     ,p_analysis_criteria_id       => l_analysis_criteria_id
     );
  hr_utility.set_location(l_proc, 10);
  --
  ghr_history_api.post_update_process;
  --
  --
  --Set OUT parameters
  --
  p_analysis_criteria_id      := l_analysis_criteria_id;
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_update_sit;
    --
    -- Set OUT parameters to null
    --
    p_analysis_criteria_id      := null;
    p_pea_object_version_number := l_pea_object_version_number;

  when others then
    ROLLBACK TO ghr_update_sit;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_analysis_criteria_id      := null;
    p_pea_object_version_number := l_pea_object_version_number;
    raise;

end update_sit;

end GHR_SIT_API;

/
