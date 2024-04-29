--------------------------------------------------------
--  DDL for Package Body GHR_POSITION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_POSITION_API" as
/* $Header: ghposapi.pkb 120.0.12010000.2 2009/05/26 10:40:18 vmididho noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ghr_position_api.';
--
-- ---------------------------------------------------------------------------
-- |--------------------------< create_position >-----------------------------|
-- ---------------------------------------------------------------------------
--
procedure create_position
  (p_validate                      in     boolean  default false
  ,p_job_id                        in     number
  ,p_organization_id               in     number
  ,p_date_effective                in     date
  ,p_successor_position_id         in     number   default null
  ,p_relief_position_id            in     number   default null
  ,p_location_id                   in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_end                      in     date     default null
  ,p_frequency                     in     varchar2 default null
  ,p_probation_period              in     number   default null
  ,p_probation_period_units        in     varchar2 default null
  ,p_replacement_required_flag     in     varchar2 default null
  ,p_time_normal_finish            in     varchar2 default null
  ,p_time_normal_start             in     varchar2 default null
  ,p_status                        in     varchar2 default null
  ,p_working_hours                 in     number   default null
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
  ,p_position_id                      out NOCOPY number
  ,p_object_version_number            out NOCOPY number
  ,p_position_definition_id           out NOCOPY number
  ,p_name                             out NOCOPY varchar2
  ) is

  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||'create_position';
  l_name				per_positions.name%type;
  l_position_definition_id	per_positions.position_definition_id%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    savepoint ghr_create_position;
  --
  hr_utility.set_location(l_proc, 10);
  --

  ghr_Session.set_session_var_for_core
  (p_effective_date    =>  p_date_effective
  );
  --
 hr_position_api.create_position
  (p_validate				=>	FALSE
  ,p_job_id 				=>	p_job_id
  ,p_organization_id			=>	p_organization_id
  ,p_date_effective			=>	p_date_effective
  ,p_successor_position_id		=>	p_successor_position_id
  ,p_relief_position_id			=>	p_relief_position_id
  ,p_location_id				=>	p_location_id
  ,p_comments				=>	p_comments
  ,p_date_end				=>	p_date_end
  ,p_frequency				=>	p_frequency
  ,p_probation_period			=>	p_probation_period
  ,p_probation_period_units		=>	p_probation_period_units
  ,p_replacement_required_flag	=>	p_replacement_required_flag
  ,p_time_normal_finish			=>	p_time_normal_finish
  ,p_time_normal_start			=>	p_time_normal_start
  ,p_status					=>	p_status
  ,p_working_hours			=>	p_working_hours
  ,p_attribute_category			=>	p_attribute_category
  ,p_attribute1				=>	p_attribute1
  ,p_attribute2				=>	p_attribute2
  ,p_attribute3				=>	p_attribute3
  ,p_attribute4				=>	p_attribute4
  ,p_attribute5				=>	p_attribute5
  ,p_attribute6				=>	p_attribute6
  ,p_attribute7				=>	p_attribute7
  ,p_attribute8				=>	p_attribute8
  ,p_attribute9				=>	p_attribute9
  ,p_attribute10				=>	p_attribute10
  ,p_attribute11				=>	p_attribute11
  ,p_attribute12				=>	p_attribute12
  ,p_attribute13				=>	p_attribute13
  ,p_attribute14				=>	p_attribute14
  ,p_attribute15				=>	p_attribute15
  ,p_attribute16				=>	p_attribute16
  ,p_attribute17				=>	p_attribute17
  ,p_attribute18				=>	p_attribute18
  ,p_attribute19				=>	p_attribute19
  ,p_attribute20				=>	p_attribute20
  ,p_segment1				=>	p_segment1
  ,p_segment2				=>	p_segment2
  ,p_segment3				=>	p_segment3
  ,p_segment4				=>	p_segment4
  ,p_segment5				=>	p_segment5
  ,p_segment6				=>	p_segment6
  ,p_segment7				=>	p_segment7
  ,p_segment8				=>	p_segment8
  ,p_segment9				=>	p_segment9
  ,p_segment10				=>	p_segment10
  ,p_segment11				=>	p_segment11
  ,p_segment12				=>	p_segment12
  ,p_segment13				=>	p_segment13
  ,p_segment14				=>	p_segment14
  ,p_segment15				=>	p_segment15
  ,p_segment16				=>	p_segment16
  ,p_segment17				=>	p_segment17
  ,p_segment18				=>	p_segment18
  ,p_segment19				=>	p_segment19
  ,p_segment20				=>	p_segment20
  ,p_segment21				=>	p_segment21
  ,p_segment22				=>	p_segment22
  ,p_segment23				=>	p_segment23
  ,p_segment24				=>	p_segment24
  ,p_segment25				=>	p_segment25
  ,p_segment26				=>	p_segment26
  ,p_segment27				=>	p_segment27
  ,p_segment28				=>	p_segment28
  ,p_segment29				=>	p_segment29
  ,p_segment30				=>	p_segment30
--  ,p_concat_segments			=>	p_concat_segments
  ,p_position_id				=>	p_position_id
  ,p_object_version_number		=>	p_object_version_number
  ,p_position_definition_id		=>	l_position_definition_id
  ,p_name					=>	l_name
  );

  hr_utility.set_location(l_proc, 20);
  --
    ghr_history_api.post_update_process;

  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
   p_position_definition_id  :=  l_position_definition_id;
   p_name := l_name;
--
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_create_position;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_name			        := null;
    p_position_id               := null;
    p_position_definition_id    := null;
    p_object_version_number 	  := null;
    --
   When others then
     ROLLBACK TO ghr_create_position;
     raise;
end create_position;

--
-- ---------------------------------------------------------------------------
-- |--------------------------< update_position >-----------------------------|
-- ---------------------------------------------------------------------------
--
procedure update_position
  (p_validate                      in     boolean  default false
  ,p_position_id                   in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_successor_position_id         in     number   default hr_api.g_number
  ,p_relief_position_id	           in     number   default hr_api.g_number
  ,p_location_id                   in     number   default hr_api.g_number
  ,p_date_effective                in     date     default hr_api.g_date
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_date_end                      in     date     default hr_api.g_date
  ,p_frequency                     in     varchar2 default hr_api.g_varchar2
  ,p_probation_period              in     number   default hr_api.g_number
  ,p_probation_period_units        in     varchar2 default hr_api.g_varchar2
  ,p_replacement_required_flag     in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish            in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start             in     varchar2 default hr_api.g_varchar2
  ,p_status                        in     varchar2 default hr_api.g_varchar2
  ,p_working_hours                 in     number   default hr_api.g_number
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
  ,p_segment1                      in     varchar2 default hr_api.g_varchar2
  ,p_segment2                      in     varchar2 default hr_api.g_varchar2
  ,p_segment3                      in     varchar2 default hr_api.g_varchar2
  ,p_segment4                      in     varchar2 default hr_api.g_varchar2
  ,p_segment5                      in     varchar2 default hr_api.g_varchar2
  ,p_segment6                      in     varchar2 default hr_api.g_varchar2
  ,p_segment7                      in     varchar2 default hr_api.g_varchar2
  ,p_segment8                      in     varchar2 default hr_api.g_varchar2
  ,p_segment9                      in     varchar2 default hr_api.g_varchar2
  ,p_segment10                     in     varchar2 default hr_api.g_varchar2
  ,p_segment11                     in     varchar2 default hr_api.g_varchar2
  ,p_segment12                     in     varchar2 default hr_api.g_varchar2
  ,p_segment13                     in     varchar2 default hr_api.g_varchar2
  ,p_segment14                     in     varchar2 default hr_api.g_varchar2
  ,p_segment15                     in     varchar2 default hr_api.g_varchar2
  ,p_segment16                     in     varchar2 default hr_api.g_varchar2
  ,p_segment17                     in     varchar2 default hr_api.g_varchar2
  ,p_segment18                     in     varchar2 default hr_api.g_varchar2
  ,p_segment19                     in     varchar2 default hr_api.g_varchar2
  ,p_segment20                     in     varchar2 default hr_api.g_varchar2
  ,p_segment21                     in     varchar2 default hr_api.g_varchar2
  ,p_segment22                     in     varchar2 default hr_api.g_varchar2
  ,p_segment23                     in     varchar2 default hr_api.g_varchar2
  ,p_segment24                     in     varchar2 default hr_api.g_varchar2
  ,p_segment25                     in     varchar2 default hr_api.g_varchar2
  ,p_segment26                     in     varchar2 default hr_api.g_varchar2
  ,p_segment27                     in     varchar2 default hr_api.g_varchar2
  ,p_segment28                     in     varchar2 default hr_api.g_varchar2
  ,p_segment29                     in     varchar2 default hr_api.g_varchar2
  ,p_segment30                     in     varchar2 default hr_api.g_varchar2
  ,p_concat_segments               in     varchar2 default hr_api.g_varchar2
  ,p_position_definition_id          out  NOCOPY number
  ,p_name                            out  NOCOPY varchar2
  ,p_valid_grades_changed_warning    out  NOCOPY boolean
  ) is

  --
  -- Declare cursors and local variables
  --
  l_name				per_positions.name%type;
  l_position_definition_id	per_positions.position_definition_id%type;
  l_object_version_number	per_positions.object_version_number%type;
  l_proc                    varchar2(72) := g_package||'update_position';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    savepoint ghr_update_position;
  --
  hr_utility.set_location(l_proc, 10);
  --

  ghr_Session.set_session_var_for_core
  (p_effective_date    =>  p_date_effective
  );
  --
 l_object_version_number	:=	p_object_version_number;
 hr_position_api.update_position
  (p_position_id				=>	p_position_id
  ,p_object_version_number		=>	l_object_version_number
  ,p_successor_position_id		=>	p_successor_position_id
  ,p_relief_position_id			=>	p_relief_position_id
  ,p_location_id				=>	p_location_id
  ,p_date_effective			=>	p_date_effective
  ,p_comments				=>	p_comments
  ,p_date_end				=>	p_date_end
  ,p_frequency				=>	p_frequency
  ,p_probation_period			=>	p_probation_period
  ,p_probation_period_units		=>	p_probation_period_units
  ,p_replacement_required_flag	=>	p_replacement_required_flag
  ,p_time_normal_finish			=>	p_time_normal_finish
  ,p_time_normal_start			=>	p_time_normal_start
  ,p_status					=>	p_status
  ,p_working_hours			=>	p_working_hours
  ,p_attribute_category			=>	p_attribute_category
  ,p_attribute1				=>	p_attribute1
  ,p_attribute2				=>	p_attribute2
  ,p_attribute3				=>	p_attribute3
  ,p_attribute4				=>	p_attribute4
  ,p_attribute5				=>	p_attribute5
  ,p_attribute6				=>	p_attribute6
  ,p_attribute7				=>	p_attribute7
  ,p_attribute8				=>	p_attribute8
  ,p_attribute9				=>	p_attribute9
  ,p_attribute10				=>	p_attribute10
  ,p_attribute11				=>	p_attribute11
  ,p_attribute12				=>	p_attribute12
  ,p_attribute13				=>	p_attribute13
  ,p_attribute14				=>	p_attribute14
  ,p_attribute15				=>	p_attribute15
  ,p_attribute16				=>	p_attribute16
  ,p_attribute17				=>	p_attribute17
  ,p_attribute18				=>	p_attribute18
  ,p_attribute19				=>	p_attribute19
  ,p_attribute20				=>	p_attribute20
  ,p_segment1				=>	p_segment1
  ,p_segment2				=>	p_segment2
  ,p_segment3				=>	p_segment3
  ,p_segment4				=>	p_segment4
  ,p_segment5				=>	p_segment5
  ,p_segment6				=>	p_segment6
  ,p_segment7				=>	p_segment7
  ,p_segment8				=>	p_segment8
  ,p_segment9				=>	p_segment9
  ,p_segment10				=>	p_segment10
  ,p_segment11				=>	p_segment11
  ,p_segment12				=>	p_segment12
  ,p_segment13				=>	p_segment13
  ,p_segment14				=>	p_segment14
  ,p_segment15				=>	p_segment15
  ,p_segment16				=>	p_segment16
  ,p_segment17				=>	p_segment17
  ,p_segment18				=>	p_segment18
  ,p_segment19				=>	p_segment19
  ,p_segment20				=>	p_segment20
  ,p_segment21				=>	p_segment21
  ,p_segment22				=>	p_segment22
  ,p_segment23				=>	p_segment23
  ,p_segment24				=>	p_segment24
  ,p_segment25				=>	p_segment25
  ,p_segment26				=>	p_segment26
  ,p_segment27				=>	p_segment27
  ,p_segment28				=>	p_segment28
  ,p_segment29				=>	p_segment29
  ,p_segment30				=>	p_segment30
 -- ,p_concat_segments			=>	p_concat_segments
  ,p_position_definition_id		=>	l_position_definition_id
  ,p_name					=>	l_name
  ,p_valid_grades_changed_warning   =>	p_valid_grades_changed_warning
  );

  hr_utility.set_location(l_proc, 20);
  --
    ghr_history_api.post_update_process;

  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
   p_object_version_number := l_object_version_number;
   p_position_definition_id := l_position_definition_id;
   p_name := l_name;
--
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_update_position;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_name			        := null;
    p_position_definition_id    := null;
    p_object_version_number 	  := p_object_version_number;
  when others then
    ROLLBACK TO ghr_update_position;
    raise;
    --
end update_position;
--
--
end ghr_position_api;

/
