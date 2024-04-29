--------------------------------------------------------
--  DDL for Package Body HR_POSITION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_POSITION_API" as
/* $Header: peposapi.pkb 120.5.12010000.3 2009/08/04 06:34:28 varanjan ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_position_api.';
--
-- Local procedure used by non-DateTrack Position API
--
procedure create_eliminated_rec(
  p_position_id number,
  p_object_version_number in out nocopy number,
  p_effective_date date) is
--
l_proc                     varchar2(72) ;
l_effective_start_date date;
l_effective_end_date date ;
l_position_definition_id number;
l_date_effective date;
l_name varchar2(500);
l_valid_grades_changed1 boolean;
l_availability_status_id number;
 Cursor c2 is
  Select SHARED_TYPE_ID
    from per_shared_types
   where LOOKUP_TYPE = 'POSITION_AVAILABILITY_STATUS'
     AND SYSTEM_TYPE_CD = 'ELIMINATED';
--
cursor c3 is
select object_version_number, position_definition_id, name
from hr_all_positions_f
where position_id = p_position_id
and p_effective_date between effective_start_date and effective_end_date;
--
l_ovn number;
--
begin
if g_debug then
  l_proc  := g_package||'create_eliminated_rec';
  hr_utility.set_location('Entering:'|| l_proc, 5);
end if;
  --
  open c3;
  fetch c3 into l_ovn, l_position_definition_id, l_name;
  close c3;
  --
  if p_position_id is not null
   and p_object_version_number is not null
   and p_effective_date is not null then
    open c2;
    fetch c2 into l_availability_status_id;
    close c2;
    --
    hr_position_api.update_position
    (p_position_id                    =>p_position_id
    ,p_effective_start_date           =>l_effective_start_date
    ,p_effective_end_date             =>l_effective_end_date
    ,p_position_definition_id         =>l_position_definition_id
    ,p_valid_grades_changed_warning   =>l_valid_grades_changed1
    ,p_name                           =>l_name
    ,p_availability_status_id         =>l_availability_status_id
    ,p_object_version_number          =>p_object_version_number
    ,p_effective_date                 =>p_effective_date
    ,p_datetrack_mode                 =>'UPDATE'
    );
  end if;
if g_debug then
  hr_utility.set_location('Leaving:'|| l_proc, 30);
end if;
end;
-- Reset FULL_HR to True
procedure reset_hr_installation is
begin
  FULL_HR := TRUE;
end;
-- Get the HR Installation status and set FULL_HR variable
procedure get_hr_installation is
--
  l_proc                     varchar2(72);
  l_return   boolean;
  l_status   varchar2(1);
  l_industry varchar2(1);
--
begin
  --
if g_debug then
  l_proc                     := g_package||'get_hr_installation';
  hr_utility.set_location('Entering:'|| l_proc, 5);
end if;
  --
  -- Find if full hr installation or shared hr installation
  --
  l_return := fnd_installation.get(appl_id     => 800,
                                   dep_appl_id => 800,
                                   status      => l_status,
                                   industry    => l_industry);
  --
  If l_status = 'I' then
     FULL_HR := TRUE;
  Elsif l_status = 'S' then
     FULL_HR := FALSE;
  Else
     hr_utility.set_message(801,'HR_NULL_INSTALLATION_STATUS');
     hr_utility.raise_error;
  End if;
  --
  -- For SHARED HR testing purposes
  --  FULL_HR := FALSE;
  --
if g_debug then
  hr_utility.set_location('Leaving:'|| l_proc, 30);
end if;
end;
--
-- Function to delete unused per_position_definitions
--
function delete_unused_per_pos_def(p_position_definition_id number)
return boolean is
  --
  cursor c_per_pos_def_used(p_position_definition_id number) is
  SELECT 'x'
  from dual
  where exists (
    select null
    from hr_all_positions_f
    where position_definition_id = p_position_definition_id)
  or exists (
    select null
    from per_all_positions
    where position_definition_id = p_position_definition_id)
  or exists (
    select null
    from per_mm_positions
    where new_position_definition_id = p_position_definition_id)
  or exists (
    select null
    from pqh_position_transactions
    where position_definition_id = p_position_definition_id);
  --
  l_dummy varchar2(10);
  --
begin
  open c_per_pos_def_used(p_position_definition_id);
  fetch c_per_pos_def_used into l_dummy;
  if (c_per_pos_def_used%found) then
    close c_per_pos_def_used;
    return false;
  end if;
  close c_per_pos_def_used;
  --
  delete from per_position_definitions
  where position_definition_id = p_position_definition_id;
  --
  return true;
  --
end;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_position >-------------------------------|
-- ----------------------------------------------------------------------------
-- NON DATE-TRACK CREATE_POSITION
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
    ,p_position_id                        out nocopy number
    ,p_object_version_number              out nocopy number
    ,p_position_definition_id        in   out nocopy number
    ,p_name                          in   out nocopy varchar2
    ) is
--
-- Declare cursors and local variables
--
   l_business_group_id        per_positions.business_group_id%TYPE;
   l_position_definition_id   per_positions.position_definition_id%TYPE
   := p_position_definition_id;
   l_old_position_definition_id per_positions.position_definition_id%TYPE;
   l_flex_num		      fnd_id_flex_segments.id_flex_num%TYPE;
   l_name                     per_positions.name%TYPE    := p_name;
   l_proc                     varchar2(72) ;
   l_date_effective           per_positions.date_effective%TYPE;
   l_date_end                 per_positions.date_end%TYPE;
   --
   l_effective_start_date     date;
   l_effective_end_date       date;
   l_active_status_id         number;
   l_effective_date           date;
/*Added trim to all the segment values for bug 6750144*/
   l_segment1                 varchar2(60) := trim(p_segment1);
   l_segment2                 varchar2(60) := trim(p_segment2);
   l_segment3                 varchar2(60) := trim(p_segment3);
   l_segment4                 varchar2(60) := trim(p_segment4);
   l_segment5                 varchar2(60) := trim(p_segment5);
   l_segment6                 varchar2(60) := trim(p_segment6);
   l_segment7                 varchar2(60) := trim(p_segment7);
   l_segment8                 varchar2(60) := trim(p_segment8);
   l_segment9                 varchar2(60) := trim(p_segment9);
   l_segment10                varchar2(60) := trim(p_segment10);
   l_segment11                varchar2(60) := trim(p_segment11);
   l_segment12                varchar2(60) := trim(p_segment12);
   l_segment13                varchar2(60) := trim(p_segment13);
   l_segment14                varchar2(60) := trim(p_segment14);
   l_segment15                varchar2(60) := trim(p_segment15);
   l_segment16                varchar2(60) := trim(p_segment16);
   l_segment17                varchar2(60) := trim(p_segment17);
   l_segment18                varchar2(60) := trim(p_segment18);
   l_segment19                varchar2(60) := trim(p_segment19);
   l_segment20                varchar2(60) := trim(p_segment20);
   l_segment21                varchar2(60) := trim(p_segment21);
   l_segment22                varchar2(60) := trim(p_segment22);
   l_segment23                varchar2(60) := trim(p_segment23);
   l_segment24                varchar2(60) := trim(p_segment24);
   l_segment25                varchar2(60) := trim(p_segment25);
   l_segment26                varchar2(60) := trim(p_segment26);
   l_segment27                varchar2(60) := trim(p_segment27);
   l_segment28                varchar2(60) := trim(p_segment28);
   l_segment29                varchar2(60) := trim(p_segment29);
   l_segment30                varchar2(60) := trim(p_segment30);
   --
   -- bug 2271064 new variable to indicate whether key flex id parameter
   -- enters the program with a value.
   --
   l_null_ind                 number(1)    := 0;
   --
   --
   -- Declare additional OUT variables
   --
   l_position_id              per_positions.position_id%TYPE;
   --
   cursor csr_job_bg is
     select business_group_id
     from per_jobs
     where job_id = p_job_id;
   --
   -- bug 2271064 get per_position_definitions segment values where
   -- position_definition_id is known
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
       from per_position_definitions
      where position_definition_id = l_position_definition_id;
--
begin
--
  g_debug := hr_utility.debug_enabled;
if g_debug then
   l_proc   := g_package||'create_position';
  hr_utility.set_location('Entering:'|| l_proc, 5);
end if;
  --
  -- Issue a savepoint
  --
   savepoint create_position;
  --
  get_hr_installation;
  --
  -- Get business_group_id using job.
  --
if g_debug then
   hr_utility.set_location(l_proc, 10);
end if;
  --
   open  csr_job_bg;
   fetch csr_job_bg
     into l_business_group_id;
  --
   if csr_job_bg%notfound then
     close csr_job_bg;
     hr_utility.set_message(801, 'HR_51090_JOB_NOT_EXIST');
     hr_utility.raise_error;
   else
     close csr_job_bg;
   end if;
  --
if g_debug then
   hr_utility.set_location(l_proc, 15);
end if;
  --
/*
obsoleted code [Date Tracking] vmolasi
idsel calls to user hooks etc
*/
  --
  -- assign variables
  --
  l_date_effective        := trunc(p_date_effective) ;
  l_date_end              := trunc(p_date_end);
  --
if g_debug then
  hr_utility.set_location(l_proc || ' l_name ' || l_name, 200);
  hr_utility.set_location(l_proc || ' l_pos_def_id '|| l_position_definition_id,  201);
end if;
  --
  -- 2242339 get segment values if p_position_definition_id entered with a value
  --
  if l_position_definition_id is not null
  --
  then
  --
if g_debug then
     hr_utility.set_location(l_proc, 15);
end if;
     --
     --set indicator to show p_position_definition_id did not enter program null
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
  else
     l_null_ind := 0;
     l_name := null;
  end if;
  --
  --begin
  --
  --
  -- Call new date-tracked position API
  --
   hr_position_api.create_position
    (p_position_id                  => p_position_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_effective_date               => l_date_effective
    ,p_job_id                       => p_job_id
    ,p_organization_id              => p_organization_id
    ,p_successor_position_id        => p_successor_position_id
    ,p_relief_position_id           => p_relief_position_id
    ,p_location_id                  => p_location_id
    ,p_position_definition_id       => l_position_definition_id
    ,p_date_effective               => l_date_effective
    ,p_comments                     => p_comments
    ,p_date_end                     => null --l_date_end
    ,p_frequency                    => p_frequency
    ,p_name                         => l_name
    ,p_probation_period             => p_probation_period
    ,p_probation_period_unit_cd     => p_probation_period_units
    ,p_replacement_required_flag    => p_replacement_required_flag
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_status                       => p_status
    ,p_working_hours                => p_working_hours
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
    ,p_concat_segments              => p_concat_segments
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => p_validate
    );
if g_debug then
   hr_utility.set_location(l_proc, 25);
end if;
   --
   -- Create Eliminated Record is date_end is not null
   --
   if p_date_end is not null then
     create_eliminated_rec(
        p_position_id           => p_position_id,
        p_object_version_number => p_object_version_number,
        p_effective_date        => p_date_end);
   end if;
if g_debug then
   hr_utility.set_location(l_proc, 30);
end if;
   --
   -- get the updated Object version number of the per_all_positions table
   -- which is returned to the user as ovn of created row.
   --
   p_object_version_number := per_refresh_position.get_position_ovn;
   --
if g_debug then
   hr_utility.set_location('per_all_ovn is '||p_object_version_number||l_proc,9);
end if;
--
-- When in validation only mode raise the Validate_Enabled exception
--
   if p_validate then
     raise hr_api.validate_enabled;
   end if;
--
-- Set remaining output arguments
--
   p_position_definition_id  :=  l_position_definition_id;
   p_name                    :=  l_name;
--
   reset_hr_installation;
   --
if g_debug then
   hr_utility.set_location(' Leaving:'||l_proc, 30);
end if;
   exception
   when hr_api.validate_enabled then
      reset_hr_installation;
--
-- As the Validate_Enabled exception has been raised
-- we must rollback to the savepoint
--
    ROLLBACK TO create_position;
--
-- Only set output warning arguments
-- (Any key or derived arguments must be set to null
-- when validation only mode is being used.)
--
    p_position_id                    := null;
    p_object_version_number          := null;
    if l_null_ind = 0
    then
       p_position_definition_id         := null;
    end if;
    p_name                           := null;
--
  when others then
     reset_hr_installation;
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  p_position_id                    := null;
  p_object_version_number          := null;
  p_position_definition_id         := l_position_definition_id;
  p_name                           := l_name;

  ROLLBACK TO create_position;
  --
  raise;
  --
end create_position;
--
-- ----------------------------------------------------------------------------
--|------------------------< get_dt_position_ovn >-----------------------------|
-- ----------------------------------------------------------------------------
--
function get_dt_position_ovn (p_position_id number, p_effective_date date)
return number is
cursor c1 is select object_version_number
             from hr_all_positions_f
             where position_id = p_position_id
             and p_effective_date between effective_start_date
                                  and effective_end_date ;
l_proc                  varchar2(72);
l_object_version_number number;
begin
if g_debug then
l_proc   := g_package||'get_dt_position_ovn' ;
   hr_utility.set_location(' Entering:'||l_proc, 5);
end if;
   open c1;
   fetch c1 into l_object_version_number;
   close c1;
   return l_object_version_number;
   if c1%notfound then
      close c1;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('Function', l_proc);
      hr_utility.set_message_token('STEP','5');
      hr_utility.raise_error;
   end if;
if g_debug then
   hr_utility.set_location(' Leaving:'||l_proc, 30);
end if;
end get_dt_position_ovn;
--
--
function SYSTEM_AVAILABILITY_STATUS (
--
         p_availability_status_id      number) return varchar2 is
--
cursor csr_lookup is
         select    system_type_cd
         from      per_shared_types
         where     shared_type_id  = p_availability_status_id;
--
v_meaning          varchar2(30) := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_availability_status_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
return v_meaning;
end system_availability_status;
--
procedure delete_eliminated_rec(p_position_id number) is
l_system_availability_status	varchar2(100);
l_deleted varchar2(10):='N';
l_eot date:= TO_DATE('31/12/4712','DD/MM/YYYY');
cursor c2 is
select position_id, effective_start_date, effective_end_date, availability_status_id
from hr_all_Positions_f
where position_id = p_position_id
order by effective_start_date desc
for update;
r2 c2%rowtype;
l_proc                  varchar2(72) ;
begin
if g_debug then
l_proc                   := g_package||'delete_eliminated_rec' ;
  hr_utility.set_location(' Entering:'||l_proc, 5);
end if;
  -- Delete Eliminated Record
  open c2;
  fetch c2 into r2;
  --
  if c2%found then
    l_system_availability_status := system_availability_status(r2.availability_status_id);
    if l_system_availability_status = 'ELIMINATED' then
      delete hr_all_positions_f
      where current of c2;
      l_deleted := 'Y';
    end if;
  end if;
  if l_deleted = 'Y' then
    fetch c2 into r2;
    if c2%found then
      update hr_all_positions_f
      set effective_end_date = l_eot
      where current of c2;
    end if;
  end if;
  close c2;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
end if;
  --
end;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_position >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_position
  (p_validate                      in     boolean  default false
  ,p_position_id                   in     number
  ,p_object_version_number         in out nocopy number
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
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
  ,p_position_definition_id        in  out nocopy  number
  ,p_name                          in  out nocopy  varchar2
  ,p_valid_grades_changed_warning      out nocopy  boolean
  ) is
--
-- Declare cursors and local variables
--
  -- bug 2271064 initialize l_position_definition_id and segment variables with
  -- values where these are passed into program.
  --
  l_object_version_number          per_positions.object_version_number%TYPE;
  l_proc                           varchar2(72);
  l_valid_grades_changed1          boolean default FALSE;
  l_valid_grades_changed2          boolean default FALSE;
  l_flex_num                       fnd_id_flex_segments.id_flex_num%TYPE;
  l_api_updating                   boolean;
  l_position_definition_id         per_positions.position_definition_id%TYPE
  := p_position_definition_id;
  l_name                           per_positions.name%TYPE
  := p_name;
  l_date_effective                 per_positions.date_effective%TYPE;
  l_date_end                       per_positions.date_end%TYPE;
  l_business_group_id              per_positions.business_group_id%TYPE;
  l_effective_start_date           date;
  l_effective_end_date             date;
  l_effective_date                 date;
  --
  l_return   boolean;
  l_status   varchar2(1);
  l_industry varchar2(1);
  --
  l_segment1                   varchar2(60) := p_segment1;
  l_segment2                   varchar2(60) := p_segment2;
  l_segment3                   varchar2(60) := p_segment3;
  l_segment4                   varchar2(60) := p_segment4;
  l_segment5                   varchar2(60) := p_segment5;
  l_segment6                   varchar2(60) := p_segment6;
  l_segment7                   varchar2(60) := p_segment7;
  l_segment8                   varchar2(60) := p_segment8;
  l_segment9                   varchar2(60) := p_segment9;
  l_segment10                  varchar2(60) := p_segment10;
  l_segment11                  varchar2(60) := p_segment11;
  l_segment12                  varchar2(60) := p_segment12;
  l_segment13                  varchar2(60) := p_segment13;
  l_segment14                  varchar2(60) := p_segment14;
  l_segment15                  varchar2(60) := p_segment15;
  l_segment16                  varchar2(60) := p_segment16;
  l_segment17                  varchar2(60) := p_segment17;
  l_segment18                  varchar2(60) := p_segment18;
  l_segment19                  varchar2(60) := p_segment19;
  l_segment20                  varchar2(60) := p_segment20;
  l_segment21                  varchar2(60) := p_segment21;
  l_segment22                  varchar2(60) := p_segment22;
  l_segment23                  varchar2(60) := p_segment23;
  l_segment24                  varchar2(60) := p_segment24;
  l_segment25                  varchar2(60) := p_segment25;
  l_segment26                  varchar2(60) := p_segment26;
  l_segment27                  varchar2(60) := p_segment27;
  l_segment28                  varchar2(60) := p_segment28;
  l_segment29                  varchar2(60) := p_segment29;
  l_segment30                  varchar2(60) := p_segment30;
  l_null_ind                   number(1)    := 0;
  --
  -- Declare cursors
   --
   cursor csr_idsel is
     select pd.id_flex_num
     from per_position_definitions pd
     where pd.position_definition_id = l_position_definition_id;
   --
   cursor get_curr_esd ( p_position_id in number) is
   select
      max(effective_start_date)
   from hr_all_positions_f
   where position_id = p_position_id and
         nvl(copied_to_old_table_flag, 'N') = 'Y';
   --
   -- bug 2271064 get per_position_definitions segment values where
   -- position_definition_id is known
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
       from per_position_definitions
      where position_definition_id = l_position_definition_id;
--
begin
--
  g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc   := g_package||'update_position';
   hr_utility.set_location('Entering:'|| l_proc, 5);
end if;
   --
   -- Issue a savepoint
   --
   savepoint update_position;
   --
   get_hr_installation;
   --
   l_date_effective := trunc(p_date_effective);
   l_date_end := trunc(p_date_end);
   --
   -- Validation in addition to Table Handlers
   --
   -- Retrieve current position details from position
   --
   l_api_updating := per_pos_shd.api_updating
     (p_position_id		=> p_position_id
     ,p_object_version_number	=> p_object_version_number);
   --
if g_debug then
   hr_utility.set_location(l_proc, 15);
end if;
   --
   if not l_api_updating
   then
if g_debug then
      hr_utility.set_location(l_proc, 20);
end if;
      --
      -- As this an updating API, the position should already exist.
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
   else
      if l_position_definition_id is null
      then
         l_null_ind := 0;
         -- l_name := null;
         l_position_definition_id
         := per_pos_shd.g_old_rec.position_definition_id;
         --
if g_debug then
         hr_utility.set_location(l_proc, 25);
end if;
         --
      else
         -- 2242339
         -- get segment values if p_position_definition_id entered with a value
         -- set indicator to show p_position_definition_id didnot enter pgm null
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
if g_debug then
         hr_utility.set_location(l_proc, 27);
end if;
         --
      end if;
   end if;
   --
   open csr_idsel;
   fetch csr_idsel
   into l_flex_num;
     if csr_idsel%NOTFOUND then
        close csr_idsel;
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP','5');
        hr_utility.raise_error;
     end if;
   close csr_idsel;
--
-- Code hr_kflex_utility.upd_or_sel_keyflex_comb etc has been Obsoleted due to
-- Position date-tracking [vmolasi]
--
--
  --
  -- get effective_start_Date
  --
  open get_curr_esd( p_position_id);
  fetch get_curr_esd into l_effective_date;
  if get_curr_esd%notfound then
    close get_curr_esd;
    --
    --  As this an updating API, the position should already exist.
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  else
    close get_curr_esd;
  end if;
if g_debug then
  hr_utility.set_location(l_proc, 30);
end if;
  --
  -- Delete Eliminated Rec
  delete_eliminated_rec(p_position_id);
if g_debug then
  hr_utility.set_location(l_proc, 35);
end if;
  --
  -- ovn of date tracked table is fetched for passing
  --
  l_object_version_number := get_dt_position_ovn(p_position_id,l_effective_date);
  --
if g_debug then
  hr_utility.set_location('hr_all_ovn is '||l_object_version_number||l_proc,5);
end if;
  --
--     fnd_message.set_name('PQH','DATE-'||l_object_version_number);
--   fnd_message.raise_error;
   --
if g_debug then
hr_utility.set_location(l_proc || 'l_pos_def_id '|| l_position_definition_id, 401);
hr_utility.set_location(l_proc || 'p_pos_def_id '|| p_position_definition_id, 402);
hr_utility.set_location(l_proc || 'l_name '|| l_name, 403);
hr_utility.set_location(l_proc || 'p_name '|| p_name, 404);
end if;
  l_effective_date := greatest(l_effective_date, l_date_effective);
  l_position_definition_id := p_position_definition_id;
  l_name := p_name;
  --
if g_debug then
  hr_utility.set_location(l_proc, 40);
end if;
  --
  hr_position_api.update_position
  (p_position_id                  => p_position_id
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ,p_effective_date               => l_effective_date
  ,p_successor_position_id        => p_successor_position_id
  ,p_relief_position_id	          => p_relief_position_id
  ,p_location_id	          => p_location_id
  ,p_position_definition_id       => l_position_definition_id
  ,p_date_effective               => l_date_effective
  ,p_comments                     => p_comments
  ,p_date_end                     => null --l_date_end
  ,p_frequency                    => p_frequency
  ,p_name                         => l_name
  ,p_probation_period             => p_probation_period
  ,p_probation_period_unit_cd     => p_probation_period_units
  ,p_replacement_required_flag    => p_replacement_required_flag
  ,p_time_normal_finish           => p_time_normal_finish
  ,p_time_normal_start            => p_time_normal_start
  ,p_status                       => p_status
  ,p_working_hours                => p_working_hours
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
  ,p_concat_segments              => p_concat_segments
  ,p_object_version_number        => l_object_version_number
  ,p_valid_grades_changed_warning => l_valid_grades_changed1
--,p_maintain_valid_grade_warning => l_valid_grades_changed1
  ,p_datetrack_mode               => 'CORRECTION'
  ,p_validate                     => p_validate
  );
--
if g_debug then
  hr_utility.set_location(l_proc, 45);
end if;
   -- Create Eliminated Record
--   fnd_message.set_name('PQH','DATE-'||l_object_version_number);
--   fnd_message.raise_error;

-- changed it for bugfix 2997103
  if ( nvl(hr_psf_shd.g_old_rec.date_end, hr_api.g_date) <>
       nvl(p_date_end, hr_api.g_date)
       and p_date_end is not null) then

     create_eliminated_rec(
        p_position_id           => p_position_id,
        p_object_version_number => l_object_version_number,
        p_effective_date        => l_date_end+1);
   end if;
if g_debug then
   hr_utility.set_location(l_proc, 50);
end if;
--
-- get the updated Object version number of the per_all_positions table which
-- is to be returned to the user as ovn of updated row.
--
   p_object_version_number := per_refresh_position.get_position_ovn;
--
if g_debug then
   hr_utility.set_location('per_all_ovn is '||p_object_version_number||l_proc,9);
end if;
  --
--
-- When in validation only mode raise the Validate_Enabled exception
--
   if p_validate then
     raise hr_api.validate_enabled;
   end if;
--
   if l_valid_grades_changed1 or l_valid_grades_changed2 then
     p_valid_grades_changed_warning := TRUE;
   else
     p_valid_grades_changed_warning := FALSE;
   end if;
   p_position_definition_id := l_position_definition_id;
   p_name := l_name;
   --
   reset_hr_installation;
   --
if g_debug then
   hr_utility.set_location(' Leaving:'||l_proc, 11);
end if;
   exception
   when hr_api.validate_enabled then
--
-- As the Validate_Enabled exception has been raised
-- we must rollback to the savepoint
--
   ROLLBACK TO update_position;
   --
   reset_hr_installation;
   --
--
-- Only set output warning arguments
-- (Any key or derived arguments must be set to null
-- when validation only mode is being used.)
--
   if l_valid_grades_changed1 or l_valid_grades_changed2 then
     p_valid_grades_changed_warning := TRUE;
   else
     p_valid_grades_changed_warning := FALSE;
   end if;
   if l_null_ind = 0
   then
      p_position_definition_id := null;
   end if;
   p_name := null;
  --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  p_object_version_number        := l_object_version_number;
  p_name                         := l_name;
  p_position_definition_id       := l_position_definition_id;
  p_valid_grades_changed_warning := null;

  ROLLBACK TO update_position;
  --
  reset_hr_installation;
  --
  raise;
  --
end update_position;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_dt_position_esd >---------------------------|
-- ----------------------------------------------------------------------------
--
function get_dt_position_esd (p_position_id number)
return date is
cursor c1 is select min(effective_start_date)
             from hr_all_positions_f
             where position_id = p_position_id;
l_proc                  varchar2(72) ;
l_esd date;
begin
if g_debug then
l_proc   := g_package||'get_dt_position_esd' ;
   hr_utility.set_location(' Entering:'||l_proc, 5);
end if;
   open c1;
   fetch c1 into l_esd;
   close c1;
   return l_esd;
   if c1%notfound then
      close c1;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('Function', l_proc);
      hr_utility.set_message_token('STEP','5');
      hr_utility.raise_error;
   end if;
if g_debug then
   hr_utility.set_location(' Leaving:'||l_proc, 30);
end if;
end get_dt_position_esd;
--
procedure delete_position(
  p_validate boolean  default false,
  p_position_id number,
  p_object_version_number number) is
l_object_version_number number;
l_proc                  varchar2(72);
l_effective_date date;
l_effective_start_date date;
l_effective_end_date date;
--
  l_return   boolean;
  l_status   varchar2(1);
  l_industry varchar2(1);
--
begin
--
  g_debug := hr_utility.debug_enabled;
if g_debug then
l_proc                   := g_package||'delete_position';
  hr_utility.set_location('Entering:'|| l_proc, 5);
end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_position;
  --
  get_hr_installation;
  --
  --
  -- esd of date tracked table is fetched for passing
  --
  l_effective_date := get_dt_position_esd(p_position_id);
  --
  -- ovn of date tracked table is fetched for passing
  --
  l_object_version_number := get_dt_position_ovn(p_position_id,l_effective_date);
  --
  hr_position_api.delete_position
  (
   p_validate                       => p_validate
  ,p_position_id                    => p_position_id
  ,p_effective_start_date           => l_effective_start_date
  ,p_effective_end_date             => l_effective_end_date
  ,p_object_version_number          => l_object_version_number
  ,p_effective_date                 => l_effective_date
  ,p_datetrack_mode                 => 'ZAP'
  );
  --
  reset_hr_installation;
  --
if g_debug then
  hr_utility.set_location('Exiting:'|| l_proc, 30);
end if;
  --
  exception
  when others then
  --
  -- As the Validate_Enabled exception has been raised
  -- we must rollback to the savepoint
  --
   ROLLBACK TO delete_position;
   --
    --
    reset_hr_installation;
    --
    raise;
end;
--
procedure lck
  (
   p_position_id                   in     number
  ,p_object_version_number          in     number
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ) is
  l_proc varchar2(72);
  l_effective_date date;
  l_object_version_number   number;
  l_validation_start_date date;
  l_validation_end_date date;
  l_datetrack_mode      varchar2(50) := 'ZAP';
  --
begin
  --

  g_debug := hr_utility.debug_enabled;
if g_debug then
l_proc  := g_package||'lck';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  --
  -- esd of date tracked table is fetched for passing
  --
  l_effective_date := get_dt_position_esd(p_position_id);
  --
  --
  -- ovn of date tracked table is fetched for passing
  --
  l_object_version_number := get_dt_position_ovn(p_position_id,l_effective_date);
  --
  hr_position_api.lck
    (
      p_position_id                => p_position_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_object_version_number      => l_object_version_number
     ,p_effective_date             => l_effective_date
     ,p_datetrack_mode             => l_datetrack_mode
    );
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 70);
end if;
  --

end;
--
--
--
-- date tracked position api code will be inserted here
--
-- ----------------------------------------------------------------------------
-- |------------------------< maintain_valid_grades >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This internal procedure maintains valid grades for a position when the
--   date effective or date end of a position is updated.

--   If the Position Date Effective is being updated, then valid grades with
--   a date to which is earlier than that Date Effective are deleted.
--   Valid Grades with a date from which is earlier than the Position Date
--   Effective and a date to which is later than the Position Date Effective
--   or null are update with their Date From set to the Position Date
--   Effective.
--
--   If the Position Date End is being updated, valid grades with a date from
--   which is later than the end date of the position are deleted.  Valid
--   Grades with a date from which is earlier then the position end date and a
--   date to which is later than the position end date or null are updated with
--   their date to set to the position end date.
--
-- Prerequisites:
--   A valid position (p_position_id) must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_validate                       Y   boolean  Default False
--  p_position_id	             Y   number
--  p_maintenance_mode	  	     Y   varchar2 Indicates whether the
--                                                position date effective or
--                                                the position date end has
--                                                been update. Valid values
--                                                are 'DATE_EFFECTIVE' and
--                                                'DATE_END'.
--  p_date_effective                 N   date     Position date effective
--  p_date_end                       N   date     Position date end
--
--
-- Post Success:
--
--   Name                                Type     Description
--   p_valid_grades_changed              boolean  Only set to true if any valid
--                                                grade rows have been updated
--                                                or deleted.
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure maintain_valid_grades
  (
   p_validate                 in boolean default false
  ,p_position_id              in number
  ,p_maintenance_mode         in varchar2
  ,p_date_effective           in date
  ,p_date_end                 in date
  ,p_valid_grades_changed     out nocopy boolean
  )
  is
  --
  l_proc                  varchar2(72) ;
  l_valid_grade_changed   boolean default FALSE;
  --
  cursor csr_valid_grades is
  select
       vgr.valid_grade_id valid_grade_id
      ,vgr.object_version_number object_version_number
      ,vgr.date_from  date_from
      ,vgr.date_to  date_to
  from per_valid_grades vgr
  where vgr.position_id = p_position_id;
  --
begin
if g_debug then
  l_proc                   := g_package||'maintain_valid_grades';
  hr_utility.set_location('Entering:'|| l_proc, 5);
end if;
--
    IF p_maintenance_mode = 'DATE_EFFECTIVE' THEN
--
-- When maintain_valid_grades has been called to maintain the valid grades
-- for a position in accordance with that position's new Date Effective,
-- (ie. p_maintenance_mode = 'DATE_EFFECTIVE') then the p_date_effective
-- parameter should have been set.
--
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument		=> 'date_effective'
    ,p_argument_value   => p_date_effective);
--
if g_debug then
  hr_utility.set_location(l_proc, 10);
end if;
--
    FOR c_vgr_rec IN csr_valid_grades LOOP
--
-- If a valid grade for the position has a Date From that is earlier
-- than the new Date Effective of the position and a Date To that is
-- later than that new Date Effective or is null, then update that
-- valid grade's Date From to that new Date Effective.
--
if g_debug then
   hr_utility.set_location(l_proc, 15);
end if;
   if (c_vgr_rec.date_from < p_date_effective and
       nvl(c_vgr_rec.date_to, hr_api.g_eot) > p_date_effective ) then
--
if g_debug then
   hr_utility.set_location(l_proc, 20);
end if;
--
   per_vgr_upd.upd
       (p_valid_grade_id => c_vgr_rec.valid_grade_id
       ,p_object_version_number => c_vgr_rec.object_version_number
       ,p_date_from => p_date_effective
       ,p_validate  => p_validate
       ,p_effective_date => p_date_effective);  --Added for Bug# 1760707
--
   l_valid_grade_changed := TRUE;
--
-- Else if valid grades exist for the position which have a date to that
-- is earlier than the new Date Effective for the position then delete
-- those valid grades.
--
--
   elsif (c_vgr_rec.date_to < p_date_effective) then
--
if g_debug then
   hr_utility.set_location(l_proc, 25);
end if;
--
   per_vgr_del.del
     (p_valid_grade_id => c_vgr_rec.valid_grade_id
     ,p_object_version_number => c_vgr_rec.object_version_number
     ,p_validate  => p_validate);
--
   l_valid_grade_changed := TRUE;
--
--
   end if;
--
   END LOOP;
--
   ELSE
--
-- When maintain_valid_grades has been called to maintain the valid grades
-- for a position in accordance with that position's new Date End,
-- (ie. p_maintenance_mode = 'DATE_END') then the p_date_end parameter
-- should have been set.
--
   hr_api.mandatory_arg_error
     (p_api_name		=> l_proc
     ,p_argument		=> 'date_end'
     ,p_argument_value          => p_date_end);
--
if g_debug then
   hr_utility.set_location(l_proc, 30);
end if;
--
   for c_vgr_rec in csr_valid_grades loop
--
-- If a valid grade for the position has a Date From that is earlier
-- than the new End Date of the position and a Date To that is later than
-- that new End Date or is null, then update that valid grade's Date To
-- to that new End Date.
--
if g_debug then
   hr_utility.set_location(l_proc, 35);
end if;
--
   if (c_vgr_rec.date_from < p_date_end and
     nvl(c_vgr_rec.date_to, hr_api.g_eot) > p_date_end ) then
--
if g_debug then
   hr_utility.set_location(l_proc, 40);
end if;
--
   per_vgr_upd.upd
     (p_valid_grade_id => c_vgr_rec.valid_grade_id
     ,p_object_version_number => c_vgr_rec.object_version_number
     ,p_date_to   => p_date_end
     ,p_validate  => p_validate
     ,p_effective_date => p_date_effective);  --Added for Bug#1760707
--
   l_valid_grade_changed := TRUE;
--
-- Else if valid grades exist for the position which have a date from that
-- is later than the new End Date for the position then delete those
-- valid grades.
--
   elsif (c_vgr_rec.date_from > p_date_end) then
--
if g_debug then
   hr_utility.set_location(l_proc, 45);
end if;
--
   per_vgr_del.del
     (p_valid_grade_id => c_vgr_rec.valid_grade_id
     ,p_object_version_number => c_vgr_rec.object_version_number
     ,p_validate  => p_validate);
--
   l_valid_grade_changed := TRUE;
--
   end if;
--
   END LOOP;
--
   END IF;
--
if g_debug then
   hr_utility.set_location(l_proc, 50);
end if;
--
   p_valid_grades_changed := l_valid_grade_changed;
if g_debug then
   hr_utility.set_location('Leaving: '||l_proc, 55);
end if;
--
   end maintain_valid_grades;
--
--
-- Procedure synchronize_per_all_positions
--
Procedure synchronize_per_all_positions
  (p_position_id               in hr_all_positions_f.position_id%TYPE
  ,p_effective_date            in date
  ,p_datetrack_mode            in varchar2
  ,p_object_version_number in out nocopy hr_all_positions_f.object_version_number%TYPE
  ) is

  --
  l_ovn       number;
  l_esd       date;
  l_eed       date;
  l_lck_mode  varchar2(100):=hr_api.g_future_change;
  l_proc      varchar2(30);
  --
  cursor c1 (p_position_id in number) is
  select object_version_number
  from per_all_positions
  where position_id = p_position_id;
  --
--
begin

if g_debug then
  l_proc       :='synchronize_per_all_positions';
  hr_utility.set_location('Entering:'||l_proc, 1);
end if;
  --
  --   Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'position_id'
    ,p_argument_value           => p_position_id
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'effective_date'
    ,p_argument_value           => p_effective_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 30);
end if;
  --
/*
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'datetrack_mode'
    ,p_argument_value           => p_datetrack_mode
    );
*/
  --
  if p_datetrack_mode = hr_api.g_zap  then
    --
    -- lock row in per_all_positions
    --
if g_debug then
    hr_utility.set_location(l_proc, 40);
end if;
    --
    open c1(p_position_id);
    fetch c1 into l_ovn;
    if c1%notfound then
      close c1;
/*
if g_debug then
      hr_utility.set_location(l_proc, 50);
end if;
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
*/
    else
      close c1;
      --
if g_debug then
      hr_utility.set_location(l_proc, 60);
end if;
      --
      per_pos_shd.lck(
         p_position_id           => p_position_id
        ,p_object_version_number => l_ovn);
      --
      -- delete row from per_all_positions
      --
if g_debug then
      hr_utility.set_location(l_proc, 70);
end if;
      --
      per_pos_del.del(
         p_position_id           => p_position_id
        ,p_object_version_number => l_ovn);
      --
if g_debug then
      hr_utility.set_location(l_proc, 80);
end if;
      --
    end if;
  elsif p_datetrack_mode = hr_api.g_update                or
        p_datetrack_mode = hr_api.g_update_change_insert  or
        p_datetrack_mode = hr_api.g_correction            or
        p_datetrack_mode = hr_api.g_delete                or
        p_datetrack_mode = hr_api.g_delete_next_change    or
        p_datetrack_mode = hr_api.g_future_change         or
        p_datetrack_mode is null
   then
    --
    -- update in per_all_positions table
    --
    begin
--      if l_effective_end_date <> hr_api.g_eot then
        -- lock the position rows explicitly
if g_debug then
        hr_utility.set_location(l_proc, 80);
end if;

        l_ovn := p_object_version_number;
        --
/*
        if p_datetrack_mode is not null then
          hr_psf_shd.lck
           (p_position_id           => p_position_id
           ,p_datetrack_mode        => l_lck_mode
           ,p_effective_Date        => p_effective_Date - 1
           ,p_object_version_number => l_ovn
           ,p_validation_start_date => l_esd
           ,p_validation_end_date   => l_eed
          );
        end if;
*/
        --
if g_debug then
        hr_utility.set_location(l_proc, 90);
end if;
        --
        -- update copied_to_old_position_flag in all the following rows
        update hr_all_positions_f
        set copied_to_old_table_flag = 'N'
        where position_id = p_position_id and
            effective_end_date >
            decode( p_datetrack_mode
                   ,hr_api.g_update,                p_effective_date
                   ,hr_api.g_correction,            p_effective_date
                   ,hr_api.g_update_change_insert,  p_effective_date
                   ,hr_api.g_delete,                p_effective_date - 1
                   ,hr_api.g_delete_next_change,    p_effective_date - 1
                   ,hr_api.g_future_change,         p_effective_date - 1
                   );
        --
if g_debug then
        hr_utility.set_location(l_proc, 100);
end if;
        -- call refresh_position procedure to replicate changes in
        -- per_all_positions
        --
        per_refresh_position.refresh_single_position
          (p_position_id           => p_position_id
          ,p_effective_date        => p_effective_date
          ,p_object_version_number => p_object_version_number
          ,p_refresh_date          => trunc(sysdate));
        --
if g_debug then
        hr_utility.set_location(l_proc, 110);
end if;
      -- end if;
     end;
  end if;
if g_debug then
  hr_utility.set_location( 'Leaving : ' || l_proc, 200);
end if;
 --

end synchronize_per_all_positions;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_position >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_position
  (p_position_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_position_definition_id         in out nocopy number
  ,p_name                           in out nocopy varchar2
  ,p_object_version_number          out nocopy number
  ,p_job_id                         in  number
  ,p_organization_id                in  number
  ,p_effective_date                 in  date
  ,p_date_effective                 in  date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ,p_validate                       in  boolean   default false
  ,p_availability_status_id         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_entry_step_id                  in  number    default null
  ,p_entry_grade_rule_id            in  number    default null
  ,p_location_id                    in  number    default null
  ,p_pay_freq_payroll_id            in  number    default null
  ,p_position_transaction_id        in  number    default null
  ,p_prior_position_id              in  number    default null
  ,p_relief_position_id             in  number    default null
  ,p_entry_grade_id                 in  number    default null
  ,p_successor_position_id          in  number    default null
  ,p_supervisor_position_id         in  number    default null
  ,p_amendment_date                 in  date      default null
  ,p_amendment_recommendation       in  varchar2  default null
  ,p_amendment_ref_number           in  varchar2  default null
  ,p_bargaining_unit_cd             in  varchar2  default null
  ,p_comments                       in  long      default null
  ,p_current_job_prop_end_date      in  date      default null
  ,p_current_org_prop_end_date      in  date      default null
  ,p_avail_status_prop_end_date     in  date      default null
  ,p_date_end                       in  date      default null
  ,p_earliest_hire_date             in  date      default null
  ,p_fill_by_date                   in  date      default null
  ,p_frequency                      in  varchar2  default null
  ,p_fte                            in  number    default null
  ,p_max_persons                    in  number    default null
  ,p_overlap_period                 in  number    default null
  ,p_overlap_unit_cd                in  varchar2  default null
  ,p_pay_term_end_day_cd            in  varchar2  default null
  ,p_pay_term_end_month_cd          in  varchar2  default null
  ,p_permanent_temporary_flag       in  varchar2  default null
  ,p_permit_recruitment_flag        in  varchar2  default null
  ,p_position_type                  in  varchar2  default 'NONE'
  ,p_posting_description            in  varchar2  default null
  ,p_probation_period               in  number    default null
  ,p_probation_period_unit_cd       in  varchar2  default null
  ,p_replacement_required_flag      in  varchar2  default null
  ,p_review_flag                    in  varchar2  default null
  ,p_seasonal_flag                  in  varchar2  default null
  ,p_security_requirements          in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_term_start_day_cd              in  varchar2  default null
  ,p_term_start_month_cd            in  varchar2  default null
  ,p_time_normal_finish             in  varchar2  default null
  ,p_time_normal_start              in  varchar2  default null
  ,p_update_source_cd               in  varchar2  default null
  ,p_working_hours                  in  number    default null
  ,p_works_council_approval_flag    in  varchar2  default null
  ,p_work_period_type_cd            in  varchar2  default null
  ,p_work_term_end_day_cd           in  varchar2  default null
  ,p_work_term_end_month_cd         in  varchar2  default null
  ,p_proposed_fte_for_layoff        in  number    default null
  ,p_proposed_date_for_layoff       in  date      default null
  ,p_pay_basis_id                   in  number    default null
  ,p_supervisor_id                  in  number    default null
  --,p_copied_to_old_table_flag       in  varchar2  default null
  ,p_information1                   in  varchar2  default null
  ,p_information2                   in  varchar2  default null
  ,p_information3                   in  varchar2  default null
  ,p_information4                   in  varchar2  default null
  ,p_information5                   in  varchar2  default null
  ,p_information6                   in  varchar2  default null
  ,p_information7                   in  varchar2  default null
  ,p_information8                   in  varchar2  default null
  ,p_information9                   in  varchar2  default null
  ,p_information10                  in  varchar2  default null
  ,p_information11                  in  varchar2  default null
  ,p_information12                  in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_information_category           in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_attribute21                    in  varchar2  default null
  ,p_attribute22                    in  varchar2  default null
  ,p_attribute23                    in  varchar2  default null
  ,p_attribute24                    in  varchar2  default null
  ,p_attribute25                    in  varchar2  default null
  ,p_attribute26                    in  varchar2  default null
  ,p_attribute27                    in  varchar2  default null
  ,p_attribute28                    in  varchar2  default null
  ,p_attribute29                    in  varchar2  default null
  ,p_attribute30                    in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_segment1                       in  varchar2  default null
  ,p_segment2                       in  varchar2  default null
  ,p_segment3                       in  varchar2  default null
  ,p_segment4                       in  varchar2  default null
  ,p_segment5                       in  varchar2  default null
  ,p_segment6                       in  varchar2  default null
  ,p_segment7                       in  varchar2  default null
  ,p_segment8                       in  varchar2  default null
  ,p_segment9                       in  varchar2  default null
  ,p_segment10                      in  varchar2  default null
  ,p_segment11                      in  varchar2  default null
  ,p_segment12                      in  varchar2  default null
  ,p_segment13                      in  varchar2  default null
  ,p_segment14                      in  varchar2  default null
  ,p_segment15                      in  varchar2  default null
  ,p_segment16                      in  varchar2  default null
  ,p_segment17                      in  varchar2  default null
  ,p_segment18                      in  varchar2  default null
  ,p_segment19                      in  varchar2  default null
  ,p_segment20                      in  varchar2  default null
  ,p_segment21                      in  varchar2  default null
  ,p_segment22                      in  varchar2  default null
  ,p_segment23                      in  varchar2  default null
  ,p_segment24                      in  varchar2  default null
  ,p_segment25                      in  varchar2  default null
  ,p_segment26                      in  varchar2  default null
  ,p_segment27                      in  varchar2  default null
  ,p_segment28                      in  varchar2  default null
  ,p_segment29                      in  varchar2  default null
  ,p_segment30                      in  varchar2  default null
  ,p_concat_segments                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_security_profile_id	    in number	  default hr_security.get_security_profile
  ) is
  --
  -- Declare cursors and local variables
  --
  l_position_id              hr_all_positions_f.position_id%TYPE;
  l_effective_start_date     hr_all_positions_f.effective_start_date%TYPE;
  l_effective_end_date       hr_all_positions_f.effective_end_date%TYPE;
  l_proc                     varchar2(72) ;
  l_object_version_number    hr_all_positions_f.object_version_number%TYPE;
  --
  l_language_code            fnd_languages.language_code%TYPE;
  --
  l_business_group_id        hr_all_positions_f.business_group_id%TYPE;
  l_position_definition_id   hr_all_positions_f.position_definition_id%TYPE
  := p_position_definition_id;
  l_old_position_definition_id per_positions.position_definition_id%TYPE;
  l_flex_num                 fnd_id_flex_segments.id_flex_num%TYPE;
  l_pos_def_id_flex_num      fnd_id_flex_segments.id_flex_num%TYPE;
  l_name                     hr_all_positions_f.name%TYPE
  := p_name;
  l_date_effective           hr_all_positions_f.date_effective%TYPE;
  l_date_end                 hr_all_positions_f.date_end%TYPE;
  --
  l_active_status_id         number;
  l_availability_Status_id   number;
  l_copied_to_old_table_flag varchar2(30):='N';
  l_retcode                  varchar2(2000);
  l_errbuf                   varchar2(2000);
  l_view_all_positions_flag  varchar2(30);
  l_dummy		     hr_all_positions_f.object_version_number%TYPE;
  --
  -- bug 2271064 set up segments as local variables
  --
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
  --
  -- bug 2271064 new variable to indicate whether key flex id parameter
  -- enters the program with a value.
  --
  l_null_ind                 number(1)    := 0;
  --
  --
  cursor c_view_all_pos is
  select view_all_positions_flag
  from per_security_profiles
  where security_profile_id = p_security_profile_id;
--
   cursor csr_job_bg is
     select business_group_id
     from per_jobs
     where job_id = p_job_id;
--
   cursor isdel is
     select pbg.position_structure
     from per_business_groups pbg
     where pbg.business_group_id = l_business_group_id;
--
  cursor csr_idsel is
     select pd.id_flex_num
     from per_position_definitions pd
     where pd.position_definition_id = l_position_definition_id;
--
   cursor c1 is
   select SHARED_TYPE_ID
     from per_shared_types
    where LOOKUP_TYPE = 'POSITION_AVAILABILITY_STATUS'
      AND SYSTEM_TYPE_CD = 'ACTIVE'
     and (business_group_id = p_business_group_id or business_group_id is null);
--
   cursor csr_get_nondt_pos(p_position_id in number) is
   select object_version_number
   from per_all_positions
   where position_id = p_position_id;
   --
   -- bug 2271064 get per_position_definitions segment values where
   -- position_definition_id is known
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
       from per_position_definitions
      where position_definition_id = l_position_definition_id;
--
begin
--
  g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc         := g_package||'create_position';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  -- Issue a savepoint
  --
  savepoint create_position;
  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  -- Get business_group_id using job.
  --
if g_debug then
  hr_utility.set_location(l_proc, 10);
end if;
  --
  open  csr_job_bg;
  fetch csr_job_bg
    into l_business_group_id;
  --
  if csr_job_bg%notfound then
     close csr_job_bg;
     hr_utility.set_message(801, 'HR_51090_JOB_NOT_EXIST');
     hr_utility.raise_error;
  else
     close csr_job_bg;
  end if;
  --
if g_debug then
  hr_utility.set_location(l_proc, 15);
end if;
  --
  open isdel;
  fetch isdel into l_flex_num;
  if isdel%notfound then
    close isdel;
    --
    -- the flex structure has not been found
    --
    hr_utility.set_message(801, 'HR_7471_FLEX_PEA_INVLALID_ID');
    hr_utility.raise_error;
  end if;
  close isdel;
  --
if g_debug then
  hr_utility.set_location(l_proc, 30);
end if;
  --
  --
  l_date_effective := trunc(p_date_effective);
  l_date_end       := trunc(p_date_end);
  --
if g_debug then
  hr_utility.set_location(l_proc, 35);
end if;
  --
  -- if p_availability_status_id is NULL then default it to 'ACTIVE' status_id
  --
  if p_availability_status_id is null then
   open c1;
   fetch c1 into l_availability_status_id;
   if c1%notfound then
     close c1;
     --
     hr_utility.set_message(801,'HR_INVALID_ACTIVE_POS_STATUS');
     hr_utility.raise_error;
     --
   else
     close c1;
   end if;
  else
   l_availability_Status_id := p_availability_status_id;
  end if;
  --
if g_debug then
  hr_utility.set_location(l_proc, 20);
end if;
  --
  -- 2242339 get segment values if p_job_definition_id entered with a value
  -- also get flex number for this flex structure.
  --
  if l_position_definition_id is not null
  --
  then
  --
if g_debug then
     hr_utility.set_location(l_proc, 15);
end if;
     --
     -- set indicator to show p_position_definition_id did not enter pgm null
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
     --
     open csr_idsel;
     fetch csr_idsel
     into l_pos_def_id_flex_num;
     if csr_idsel%NOTFOUND
     then
       -- close csr_idsel;  -- fix for the bug 8521611
        /*-- start change for the bug 5682240
	 hr_utility.set_message (801, 'No flex number for this position definition id');  -- orignal
        --------------------------  */
	hr_utility.set_location('No flex number for position definition id= '||l_position_definition_id, 630);

     end if;
     close csr_idsel;
  else
     l_null_ind := 0;
     l_name := null;
  end if;
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_position
    --
    hr_position_bk1.create_position_b
      (
       p_availability_status_id         =>  l_availability_status_id
      ,p_business_group_id              =>  l_business_group_id
      ,p_entry_step_id                  =>  p_entry_step_id
      ,p_entry_grade_rule_id            =>  p_entry_grade_rule_id
      ,p_job_id                         =>  p_job_id
      ,p_location_id                    =>  p_location_id
      ,p_organization_id                =>  p_organization_id
      ,p_pay_freq_payroll_id            =>  p_pay_freq_payroll_id
--      ,p_position_definition_id         =>  p_position_definition_id
      ,p_position_transaction_id        =>  p_position_transaction_id
      ,p_prior_position_id              =>  p_prior_position_id
      ,p_relief_position_id             =>  p_relief_position_id
      ,p_entry_grade_id                 =>  p_entry_grade_id
      ,p_successor_position_id          =>  p_successor_position_id
      ,p_supervisor_position_id         =>  p_supervisor_position_id
      ,p_amendment_date                 =>  p_amendment_date
      ,p_amendment_recommendation       =>  p_amendment_recommendation
      ,p_amendment_ref_number           =>  p_amendment_ref_number
      ,p_bargaining_unit_cd             =>  p_bargaining_unit_cd
      ,p_comments                       =>  p_comments
      ,p_current_job_prop_end_date      =>  p_current_job_prop_end_date
      ,p_current_org_prop_end_date      =>  p_current_org_prop_end_date
      ,p_avail_status_prop_end_date     =>  p_avail_status_prop_end_date
      ,p_date_effective                 =>  l_date_effective
      ,p_date_end                       =>  l_date_end
      ,p_earliest_hire_date             =>  p_earliest_hire_date
      ,p_fill_by_date                   =>  p_fill_by_date
      ,p_frequency                      =>  p_frequency
      ,p_fte                            =>  p_fte
      ,p_max_persons                    =>  p_max_persons
      -- ,p_name                           =>  l_name --vb
      ,p_overlap_period                 =>  p_overlap_period
      ,p_overlap_unit_cd                =>  p_overlap_unit_cd
      ,p_pay_term_end_day_cd            =>  p_pay_term_end_day_cd
      ,p_pay_term_end_month_cd          =>  p_pay_term_end_month_cd
      ,p_permanent_temporary_flag       =>  p_permanent_temporary_flag
      ,p_permit_recruitment_flag        =>  p_permit_recruitment_flag
      ,p_position_type                  =>  p_position_type
      ,p_posting_description            =>  p_posting_description
      ,p_probation_period               =>  p_probation_period
      ,p_probation_period_unit_cd       =>  p_probation_period_unit_cd
      ,p_replacement_required_flag      =>  p_replacement_required_flag
      ,p_review_flag                    =>  p_review_flag
      ,p_seasonal_flag                  =>  p_seasonal_flag
      ,p_security_requirements          =>  p_security_requirements
      ,p_status                         =>  p_status
      ,p_term_start_day_cd              =>  p_term_start_day_cd
      ,p_term_start_month_cd            =>  p_term_start_month_cd
      ,p_time_normal_finish             =>  p_time_normal_finish
      ,p_time_normal_start              =>  p_time_normal_start
      ,p_update_source_cd               =>  p_update_source_cd
      ,p_working_hours                  =>  p_working_hours
      ,p_works_council_approval_flag    =>  p_works_council_approval_flag
      ,p_work_period_type_cd            =>  p_work_period_type_cd
      ,p_work_term_end_day_cd           =>  p_work_term_end_day_cd
      ,p_work_term_end_month_cd         =>  p_work_term_end_month_cd
      ,p_proposed_fte_for_layoff        =>  p_proposed_fte_for_layoff
      ,p_proposed_date_for_layoff       =>  p_proposed_date_for_layoff
      ,p_pay_basis_id                   =>  p_pay_basis_id
      ,p_supervisor_id                  =>  p_supervisor_id
      --,p_copied_to_old_table_flag       =>  l_copied_to_old_table_flag
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information_category           =>  p_information_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_attribute_category             =>  p_attribute_category
      ,p_segment1                       =>  l_segment1
      ,p_segment2                       =>  l_segment2
      ,p_segment3                       =>  l_segment3
      ,p_segment4                       =>  l_segment4
      ,p_segment5                       =>  l_segment5
      ,p_segment6                       =>  l_segment6
      ,p_segment7                       =>  l_segment7
      ,p_segment8                       =>  l_segment8
      ,p_segment9                       =>  l_segment9
      ,p_segment10                      =>  l_segment10
      ,p_segment11                      =>  l_segment11
      ,p_segment12                      =>  l_segment12
      ,p_segment13                      =>  l_segment13
      ,p_segment14                      =>  l_segment14
      ,p_segment15                      =>  l_segment15
      ,p_segment16                      =>  l_segment16
      ,p_segment17                      =>  l_segment17
      ,p_segment18                      =>  l_segment18
      ,p_segment19                      =>  l_segment19
      ,p_segment20                      =>  l_segment20
      ,p_segment21                      =>  l_segment21
      ,p_segment22                      =>  l_segment22
      ,p_segment23                      =>  l_segment23
      ,p_segment24                      =>  l_segment24
      ,p_segment25                      =>  l_segment25
      ,p_segment26                      =>  l_segment26
      ,p_segment27                      =>  l_segment27
      ,p_segment28                      =>  l_segment28
      ,p_segment29                      =>  l_segment29
      ,p_segment30                      =>  l_segment30
      ,p_concat_segments                =>  p_concat_segments
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_language_code                  =>  l_language_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_POSITION'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_position
    --
  end;
  --
  --  Determine the position defintion by calling ins_or_sel
  --  bug 2271064 - when position definition id is null.
  --  also make sure that name has a value... get it from the appropriate
  --  flex number
  --
  if l_position_definition_id is not null
  and l_name is null
  then
     hr_kflex_utility.ins_or_sel_keyflex_comb
     (p_appl_short_name              => 'PER'
     ,p_flex_code                    => 'POS'
     ,p_flex_num                     => l_pos_def_id_flex_num
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
     ,p_ccid                         => l_old_position_definition_id
     ,p_concat_segments_out          => l_name
      );
  end if;
  --
  if l_position_definition_id is null
  -- or l_name is null
  then
     if nvl(fnd_profile.value('FLEXFIELDS:VALIDATE_ON_SERVER'),'N') = 'Y'
     or l_name is null
     then
        hr_kflex_utility.ins_or_sel_keyflex_comb
        (p_appl_short_name              => 'PER'
        ,p_flex_code                    => 'POS'
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
        ,p_ccid                         => l_position_definition_id
        ,p_concat_segments_out          => l_name
        );
     end if;
  end if;
  --
  -- l_position_definition_id now has a value, whether it entered with one
  -- or not. ditto l_name.
  --
  hr_psf_ins.ins
    (
     p_position_id                   => l_position_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_availability_status_id        => l_availability_status_id
    ,p_business_group_id             => l_business_group_id
    ,p_entry_step_id                 => p_entry_step_id
    ,p_entry_grade_rule_id           => p_entry_grade_rule_id
    ,p_job_id                        => p_job_id
    ,p_location_id                   => p_location_id
    ,p_organization_id               => p_organization_id
    ,p_pay_freq_payroll_id           => p_pay_freq_payroll_id
    ,p_position_definition_id        => l_position_definition_id
    ,p_position_transaction_id       => p_position_transaction_id
    ,p_prior_position_id             => p_prior_position_id
    ,p_relief_position_id            => p_relief_position_id
    ,p_entry_grade_id                => p_entry_grade_id
    ,p_successor_position_id         => p_successor_position_id
    ,p_supervisor_position_id        => p_supervisor_position_id
    ,p_amendment_date                => p_amendment_date
    ,p_amendment_recommendation      => p_amendment_recommendation
    ,p_amendment_ref_number          => p_amendment_ref_number
    ,p_bargaining_unit_cd            => p_bargaining_unit_cd
    ,p_comments                      => p_comments
    ,p_current_job_prop_end_date     => p_current_job_prop_end_date
    ,p_current_org_prop_end_date     => p_current_org_prop_end_date
    ,p_avail_status_prop_end_date    => p_avail_status_prop_end_date
    ,p_date_effective                => l_date_effective
    ,p_date_end                      => l_date_end
    ,p_earliest_hire_date            => p_earliest_hire_date
    ,p_fill_by_date                  => p_fill_by_date
    ,p_frequency                     => p_frequency
    ,p_fte                           => p_fte
    ,p_max_persons                   => p_max_persons
    ,p_name                          => l_name
    ,p_overlap_period                => p_overlap_period
    ,p_overlap_unit_cd               => p_overlap_unit_cd
    ,p_pay_term_end_day_cd           => p_pay_term_end_day_cd
    ,p_pay_term_end_month_cd         => p_pay_term_end_month_cd
    ,p_permanent_temporary_flag      => p_permanent_temporary_flag
    ,p_permit_recruitment_flag       => p_permit_recruitment_flag
    ,p_position_type                 => p_position_type
    ,p_posting_description           => p_posting_description
    ,p_probation_period              => p_probation_period
    ,p_probation_period_unit_cd      => p_probation_period_unit_cd
    ,p_replacement_required_flag     => p_replacement_required_flag
    ,p_review_flag                   => p_review_flag
    ,p_seasonal_flag                 => p_seasonal_flag
    ,p_security_requirements         => p_security_requirements
    ,p_status                        => p_status
    ,p_term_start_day_cd             => p_term_start_day_cd
    ,p_term_start_month_cd           => p_term_start_month_cd
    ,p_time_normal_finish            => p_time_normal_finish
    ,p_time_normal_start             => p_time_normal_start
    ,p_update_source_cd              => p_update_source_cd
    ,p_working_hours                 => p_working_hours
    ,p_works_council_approval_flag   => p_works_council_approval_flag
    ,p_work_period_type_cd           => p_work_period_type_cd
    ,p_work_term_end_day_cd          => p_work_term_end_day_cd
    ,p_work_term_end_month_cd        => p_work_term_end_month_cd
    ,p_proposed_fte_for_layoff       => p_proposed_fte_for_layoff
    ,p_proposed_date_for_layoff      => p_proposed_date_for_layoff
    ,p_pay_basis_id                  => p_pay_basis_id
    ,p_supervisor_id                 => p_supervisor_id
    ,p_copied_to_old_table_flag      => 'N'
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
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_information_category          => p_information_category
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
    ,p_attribute21                   => p_attribute21
    ,p_attribute22                   => p_attribute22
    ,p_attribute23                   => p_attribute23
    ,p_attribute24                   => p_attribute24
    ,p_attribute25                   => p_attribute25
    ,p_attribute26                   => p_attribute26
    ,p_attribute27                   => p_attribute27
    ,p_attribute28                   => p_attribute28
    ,p_attribute29                   => p_attribute29
    ,p_attribute30                   => p_attribute30
    ,p_attribute_category            => p_attribute_category
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_validate                      => p_validate
    ,p_security_profile_id	     => p_security_profile_id
    );
  --
  -- PMFLETCH Insert into translation table
  --
  hr_pft_ins.ins_tl
    ( p_language_code                => l_language_code
    , p_position_id                  => l_position_id
    , p_position_definition_id       => l_position_definition_id
    );
  --
  -- Insert in per_all_positions table
  --
  begin
    --
    -- call refresh_position procedure to replicate changes in per_all_positions
    --
if g_debug then
    hr_utility.set_location ( l_proc, 1000);
    hr_utility.set_location ( 'POSITION ID : ' || l_position_id || l_proc, 1000);
end if;
    --
    synchronize_per_all_positions
      (p_position_id              => l_position_id
      ,p_effective_date           => trunc(p_effective_date)
      ,p_datetrack_mode           => null
      ,p_object_version_number     => l_object_version_number
      );
    --
if g_debug then
    hr_utility.set_location ( l_proc, 1001);
    hr_utility.set_location ( 'POSITION ID : ' || l_position_id || l_proc, 1000);
end if;
    --
    --
  end;
  --
  -- Insert in position security list table
  --
  begin
  open c_view_all_pos;
  fetch c_view_all_pos into l_view_all_positions_flag;
  close c_view_all_pos;

  if l_view_all_positions_flag <> 'Y' then
/*
    open csr_get_nondt_pos(l_position_id );
    fetch csr_get_nondt_pos into l_dummy;
    if csr_get_nondt_pos%FOUND then
      --
      close csr_get_nondt_pos;
      --
*/
    hr_security.add_position(l_position_id,
                             p_security_profile_id);
    --
  end if;
  end;
  --
--
  begin
    --
    -- Start of API User Hook for the after hook of create_position
    --
    hr_position_bk1.create_position_a
      (
       p_position_id                    =>  l_position_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_availability_status_id         =>  l_availability_status_id
      ,p_business_group_id              =>  l_business_group_id
      ,p_entry_step_id                  =>  p_entry_step_id
      ,p_entry_grade_rule_id            =>  p_entry_grade_rule_id
      ,p_job_id                         =>  p_job_id
      ,p_location_id                    =>  p_location_id
      ,p_organization_id                =>  p_organization_id
      ,p_pay_freq_payroll_id            =>  p_pay_freq_payroll_id
      ,p_position_definition_id         =>  l_position_definition_id
      ,p_position_transaction_id        =>  p_position_transaction_id
      ,p_prior_position_id              =>  p_prior_position_id
      ,p_relief_position_id             =>  p_relief_position_id
      ,p_entry_grade_id                 =>  p_entry_grade_id
      ,p_successor_position_id          =>  p_successor_position_id
      ,p_supervisor_position_id         =>  p_supervisor_position_id
      ,p_amendment_date                 =>  p_amendment_date
      ,p_amendment_recommendation       =>  p_amendment_recommendation
      ,p_amendment_ref_number           =>  p_amendment_ref_number
      ,p_bargaining_unit_cd             =>  p_bargaining_unit_cd
      ,p_comments                       =>  p_comments
      ,p_current_job_prop_end_date      =>  p_current_job_prop_end_date
      ,p_current_org_prop_end_date      =>  p_current_org_prop_end_date
      ,p_avail_status_prop_end_date     =>  p_avail_status_prop_end_date
      ,p_date_effective                 =>  l_date_effective
      ,p_date_end                       =>  l_date_end
      ,p_earliest_hire_date             =>  p_earliest_hire_date
      ,p_fill_by_date                   =>  p_fill_by_date
      ,p_frequency                      =>  p_frequency
      ,p_fte                            =>  p_fte
      ,p_max_persons                    =>  p_max_persons
      ,p_name                           =>  l_name
      ,p_overlap_period                 =>  p_overlap_period
      ,p_overlap_unit_cd                =>  p_overlap_unit_cd
      ,p_pay_term_end_day_cd            =>  p_pay_term_end_day_cd
      ,p_pay_term_end_month_cd          =>  p_pay_term_end_month_cd
      ,p_permanent_temporary_flag       =>  p_permanent_temporary_flag
      ,p_permit_recruitment_flag        =>  p_permit_recruitment_flag
      ,p_position_type                  =>  p_position_type
      ,p_posting_description            =>  p_posting_description
      ,p_probation_period               =>  p_probation_period
      ,p_probation_period_unit_cd       =>  p_probation_period_unit_cd
      ,p_replacement_required_flag      =>  p_replacement_required_flag
      ,p_review_flag                    =>  p_review_flag
      ,p_seasonal_flag                  =>  p_seasonal_flag
      ,p_security_requirements          =>  p_security_requirements
      ,p_status                         =>  p_status
      ,p_term_start_day_cd              =>  p_term_start_day_cd
      ,p_term_start_month_cd            =>  p_term_start_month_cd
      ,p_time_normal_finish             =>  p_time_normal_finish
      ,p_time_normal_start              =>  p_time_normal_start
      ,p_update_source_cd               =>  p_update_source_cd
      ,p_working_hours                  =>  p_working_hours
      ,p_works_council_approval_flag    =>  p_works_council_approval_flag
      ,p_work_period_type_cd            =>  p_work_period_type_cd
      ,p_work_term_end_day_cd           =>  p_work_term_end_day_cd
      ,p_work_term_end_month_cd         =>  p_work_term_end_month_cd
      ,p_proposed_fte_for_layoff        =>  p_proposed_fte_for_layoff
      ,p_proposed_date_for_layoff       =>  p_proposed_date_for_layoff
      ,p_pay_basis_id                   =>  p_pay_basis_id
      ,p_supervisor_id                  =>  p_supervisor_id
      --,p_copied_to_old_table_flag       =>  p_copied_to_old_table_flag
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information_category           =>  p_information_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_attribute_category             =>  p_attribute_category
      ,p_segment1                       =>  l_segment1
      ,p_segment2                       =>  l_segment2
      ,p_segment3                       =>  l_segment3
      ,p_segment4                       =>  l_segment4
      ,p_segment5                       =>  l_segment5
      ,p_segment6                       =>  l_segment6
      ,p_segment7                       =>  l_segment7
      ,p_segment8                       =>  l_segment8
      ,p_segment9                       =>  l_segment9
      ,p_segment10                      =>  l_segment10
      ,p_segment11                      =>  l_segment11
      ,p_segment12                      =>  l_segment12
      ,p_segment13                      =>  l_segment13
      ,p_segment14                      =>  l_segment14
      ,p_segment15                      =>  l_segment15
      ,p_segment16                      =>  l_segment16
      ,p_segment17                      =>  l_segment17
      ,p_segment18                      =>  l_segment18
      ,p_segment19                      =>  l_segment19
      ,p_segment20                      =>  l_segment20
      ,p_segment21                      =>  l_segment21
      ,p_segment22                      =>  l_segment22
      ,p_segment23                      =>  l_segment23
      ,p_segment24                      =>  l_segment24
      ,p_segment25                      =>  l_segment25
      ,p_segment26                      =>  l_segment26
      ,p_segment27                      =>  l_segment27
      ,p_segment28                      =>  l_segment28
      ,p_segment29                      =>  l_segment29
      ,p_segment30                      =>  l_segment30
      ,p_concat_segments                =>  p_concat_segments
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_language_code                  =>  l_language_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_POSITION'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_position
    --
  end;
  --
if g_debug then
  hr_utility.set_location(l_proc, 60);
end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_position_id := l_position_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  p_position_definition_id  :=  l_position_definition_id;
  p_name                    :=  l_name;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 70);
end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_position;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_position_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    if l_null_ind = 0
    then
       p_position_definition_id  :=  null;
    else
       p_position_definition_id  :=  l_position_definition_id;
    end if;
    p_name                    :=  l_name;
if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 80);
end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_position_id             := null;
    p_effective_start_date    := null;
    p_effective_end_date      := null;
    p_object_version_number   := null;
    p_position_definition_id  := l_position_definition_id;
    p_name                    := l_name;

    ROLLBACK TO create_position;
    raise;
    --
end create_position;
-- ----------------------------------------------------------------------------
-- |------------------------< update_position >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_position
  (p_validate                       in  boolean   default false
  ,p_position_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_position_definition_id         in out nocopy number
  ,p_valid_grades_changed_warning   out nocopy boolean
  ,p_name                           in out nocopy varchar2
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ,p_availability_status_id         in  number    default hr_api.g_number
--  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_entry_step_id                  in  number    default hr_api.g_number
  ,p_entry_grade_rule_id            in  number    default hr_api.g_number
--  ,p_job_id                         in  number    default hr_api.g_number
  ,p_location_id                    in  number    default hr_api.g_number
--  ,p_organization_id                in  number    default hr_api.g_number
  ,p_pay_freq_payroll_id            in  number    default hr_api.g_number
  ,p_position_transaction_id        in  number    default hr_api.g_number
  ,p_prior_position_id              in  number    default hr_api.g_number
  ,p_relief_position_id             in  number    default hr_api.g_number
  ,p_entry_grade_id                 in  number    default hr_api.g_number
  ,p_successor_position_id          in  number    default hr_api.g_number
  ,p_supervisor_position_id         in  number    default hr_api.g_number
  ,p_amendment_date                 in  date      default hr_api.g_date
  ,p_amendment_recommendation       in  varchar2  default hr_api.g_varchar2
  ,p_amendment_ref_number           in  varchar2  default hr_api.g_varchar2
  ,p_bargaining_unit_cd             in  varchar2  default hr_api.g_varchar2
  ,p_comments                       in  long      default hr_api.g_varchar2
  ,p_current_job_prop_end_date      in  date      default hr_api.g_date
  ,p_current_org_prop_end_date      in  date      default hr_api.g_date
  ,p_avail_status_prop_end_date     in  date      default hr_api.g_date
  ,p_date_effective                 in  date      default hr_api.g_date
  ,p_date_end                       in  date      default hr_api.g_date
  ,p_earliest_hire_date             in  date      default hr_api.g_date
  ,p_fill_by_date                   in  date      default hr_api.g_date
  ,p_frequency                      in  varchar2  default hr_api.g_varchar2
  ,p_fte                            in  number    default hr_api.g_number
  ,p_max_persons                    in  number    default hr_api.g_number
  ,p_overlap_period                 in  number    default hr_api.g_number
  ,p_overlap_unit_cd                in  varchar2  default hr_api.g_varchar2
  ,p_pay_term_end_day_cd            in  varchar2  default hr_api.g_varchar2
  ,p_pay_term_end_month_cd          in  varchar2  default hr_api.g_varchar2
  ,p_permanent_temporary_flag       in  varchar2  default hr_api.g_varchar2
  ,p_permit_recruitment_flag        in  varchar2  default hr_api.g_varchar2
  ,p_position_type                  in  varchar2  default hr_api.g_varchar2
  ,p_posting_description            in  varchar2  default hr_api.g_varchar2
  ,p_probation_period               in  number    default hr_api.g_number
  ,p_probation_period_unit_cd       in  varchar2  default hr_api.g_varchar2
  ,p_replacement_required_flag      in  varchar2  default hr_api.g_varchar2
  ,p_review_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_seasonal_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_security_requirements          in  varchar2  default hr_api.g_varchar2
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_term_start_day_cd              in  varchar2  default hr_api.g_varchar2
  ,p_term_start_month_cd            in  varchar2  default hr_api.g_varchar2
  ,p_time_normal_finish             in  varchar2  default hr_api.g_varchar2
  ,p_time_normal_start              in  varchar2  default hr_api.g_varchar2
  ,p_update_source_cd               in  varchar2  default hr_api.g_varchar2
  ,p_working_hours                  in  number    default hr_api.g_number
  ,p_works_council_approval_flag    in  varchar2  default hr_api.g_varchar2
  ,p_work_period_type_cd            in  varchar2  default hr_api.g_varchar2
  ,p_work_term_end_day_cd           in  varchar2  default hr_api.g_varchar2
  ,p_work_term_end_month_cd         in  varchar2  default hr_api.g_varchar2
  ,p_proposed_fte_for_layoff        in  number    default hr_api.g_number
  ,p_proposed_date_for_layoff       in  date      default hr_api.g_date
  ,p_pay_basis_id                   in  number    default hr_api.g_number
  ,p_supervisor_id                  in  number    default hr_api.g_number
  --,p_copied_to_old_table_flag       in  varchar2    default hr_api.g_varchar2
  ,p_information1                   in  varchar2  default hr_api.g_varchar2
  ,p_information2                   in  varchar2  default hr_api.g_varchar2
  ,p_information3                   in  varchar2  default hr_api.g_varchar2
  ,p_information4                   in  varchar2  default hr_api.g_varchar2
  ,p_information5                   in  varchar2  default hr_api.g_varchar2
  ,p_information6                   in  varchar2  default hr_api.g_varchar2
  ,p_information7                   in  varchar2  default hr_api.g_varchar2
  ,p_information8                   in  varchar2  default hr_api.g_varchar2
  ,p_information9                   in  varchar2  default hr_api.g_varchar2
  ,p_information10                  in  varchar2  default hr_api.g_varchar2
  ,p_information11                  in  varchar2  default hr_api.g_varchar2
  ,p_information12                  in  varchar2  default hr_api.g_varchar2
  ,p_information13                  in  varchar2  default hr_api.g_varchar2
  ,p_information14                  in  varchar2  default hr_api.g_varchar2
  ,p_information15                  in  varchar2  default hr_api.g_varchar2
  ,p_information16                  in  varchar2  default hr_api.g_varchar2
  ,p_information17                  in  varchar2  default hr_api.g_varchar2
  ,p_information18                  in  varchar2  default hr_api.g_varchar2
  ,p_information19                  in  varchar2  default hr_api.g_varchar2
  ,p_information20                  in  varchar2  default hr_api.g_varchar2
  ,p_information21                  in  varchar2  default hr_api.g_varchar2
  ,p_information22                  in  varchar2  default hr_api.g_varchar2
  ,p_information23                  in  varchar2  default hr_api.g_varchar2
  ,p_information24                  in  varchar2  default hr_api.g_varchar2
  ,p_information25                  in  varchar2  default hr_api.g_varchar2
  ,p_information26                  in  varchar2  default hr_api.g_varchar2
  ,p_information27                  in  varchar2  default hr_api.g_varchar2
  ,p_information28                  in  varchar2  default hr_api.g_varchar2
  ,p_information29                  in  varchar2  default hr_api.g_varchar2
  ,p_information30                  in  varchar2  default hr_api.g_varchar2
  ,p_information_category           in  varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute21                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute22                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute23                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute24                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute25                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute26                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute27                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute28                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute29                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute30                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute_category             in  varchar2  default hr_api.g_varchar2
  ,p_segment1                       in  varchar2 default hr_api.g_varchar2
  ,p_segment2                       in  varchar2 default hr_api.g_varchar2
  ,p_segment3                       in  varchar2 default hr_api.g_varchar2
  ,p_segment4                       in  varchar2 default hr_api.g_varchar2
  ,p_segment5                       in  varchar2 default hr_api.g_varchar2
  ,p_segment6                       in  varchar2 default hr_api.g_varchar2
  ,p_segment7                       in  varchar2 default hr_api.g_varchar2
  ,p_segment8                       in  varchar2 default hr_api.g_varchar2
  ,p_segment9                       in  varchar2 default hr_api.g_varchar2
  ,p_segment10                      in  varchar2 default hr_api.g_varchar2
  ,p_segment11                      in  varchar2 default hr_api.g_varchar2
  ,p_segment12                      in  varchar2 default hr_api.g_varchar2
  ,p_segment13                      in  varchar2 default hr_api.g_varchar2
  ,p_segment14                      in  varchar2 default hr_api.g_varchar2
  ,p_segment15                      in  varchar2 default hr_api.g_varchar2
  ,p_segment16                      in  varchar2 default hr_api.g_varchar2
  ,p_segment17                      in  varchar2 default hr_api.g_varchar2
  ,p_segment18                      in  varchar2 default hr_api.g_varchar2
  ,p_segment19                      in  varchar2 default hr_api.g_varchar2
  ,p_segment20                      in  varchar2 default hr_api.g_varchar2
  ,p_segment21                      in  varchar2 default hr_api.g_varchar2
  ,p_segment22                      in  varchar2 default hr_api.g_varchar2
  ,p_segment23                      in  varchar2 default hr_api.g_varchar2
  ,p_segment24                      in  varchar2 default hr_api.g_varchar2
  ,p_segment25                      in  varchar2 default hr_api.g_varchar2
  ,p_segment26                      in  varchar2 default hr_api.g_varchar2
  ,p_segment27                      in  varchar2 default hr_api.g_varchar2
  ,p_segment28                      in  varchar2 default hr_api.g_varchar2
  ,p_segment29                      in  varchar2 default hr_api.g_varchar2
  ,p_segment30                      in  varchar2 default hr_api.g_varchar2
  ,p_concat_segments                in  varchar2 default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) ;
  l_object_version_number hr_all_positions_f.object_version_number%TYPE;
  l_effective_start_date  hr_all_positions_f.effective_start_date%TYPE;
  l_effective_end_date    hr_all_positions_f.effective_end_date%TYPE;
  --
  l_language_code         fnd_languages.language_code%TYPE;
  --
  l_valid_grades_changed1         boolean default FALSE;
  l_valid_grades_changed2         boolean default FALSE;
  l_flex_num                      fnd_id_flex_segments.id_flex_num%TYPE;
  l_api_updating                  boolean;
  l_position_definition_id        hr_all_positions_f.position_definition_id%TYPE  := p_position_definition_id;
  l_name                          hr_all_positions_f.name%TYPE
  := p_name;
  l_date_effective                hr_all_positions_f.date_effective%TYPE;
  l_date_end                      hr_all_positions_f.date_end%TYPE;
  l_business_group_id             hr_all_positions_f.business_group_id%TYPE;
  l_minesd                        date;
  l_ovn                            number;
  l_esd                            date;
  l_eed                            date;
  l_retcode                    varchar2(2000);
  l_errbuf                     varchar2(2000);
  l_segment1                   varchar2(60) := p_segment1;
  l_segment2                   varchar2(60) := p_segment2;
  l_segment3                   varchar2(60) := p_segment3;
  l_segment4                   varchar2(60) := p_segment4;
  l_segment5                   varchar2(60) := p_segment5;
  l_segment6                   varchar2(60) := p_segment6;
  l_segment7                   varchar2(60) := p_segment7;
  l_segment8                   varchar2(60) := p_segment8;
  l_segment9                   varchar2(60) := p_segment9;
  l_segment10                  varchar2(60) := p_segment10;
  l_segment11                  varchar2(60) := p_segment11;
  l_segment12                  varchar2(60) := p_segment12;
  l_segment13                  varchar2(60) := p_segment13;
  l_segment14                  varchar2(60) := p_segment14;
  l_segment15                  varchar2(60) := p_segment15;
  l_segment16                  varchar2(60) := p_segment16;
  l_segment17                  varchar2(60) := p_segment17;
  l_segment18                  varchar2(60) := p_segment18;
  l_segment19                  varchar2(60) := p_segment19;
  l_segment20                  varchar2(60) := p_segment20;
  l_segment21                  varchar2(60) := p_segment21;
  l_segment22                  varchar2(60) := p_segment22;
  l_segment23                  varchar2(60) := p_segment23;
  l_segment24                  varchar2(60) := p_segment24;
  l_segment25                  varchar2(60) := p_segment25;
  l_segment26                  varchar2(60) := p_segment26;
  l_segment27                  varchar2(60) := p_segment27;
  l_segment28                  varchar2(60) := p_segment28;
  l_segment29                  varchar2(60) := p_segment29;
  l_segment30                  varchar2(60) := p_segment30;
  l_null_ind                   number(1)    := 0;
  --
  -- Declare cursors
  --
  cursor csr_idsel is
     select pd.id_flex_num
     from per_position_definitions pd
     where pd.position_definition_id = l_position_definition_id;
  --
  cursor csr_isfirstrow is
     select min(effective_start_date)
     from hr_all_positions_f
     where position_id = p_position_id;
   --
   -- bug 2271064 get per_position_definitions segment values where
   -- position_definition_id is known
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
       from per_position_definitions
      where position_definition_id = l_position_definition_id;
--
begin
--
  g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc          := g_package||'update_position';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_position;
  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
if g_debug then
  hr_utility.set_location(l_proc, 20);
end if;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  l_date_effective := trunc(p_date_effective);
  l_date_end := trunc(p_date_end);
  --
  -- 2271064 get segment values if p_job_definition_id entered with a value
  --
  if l_position_definition_id is not null
  --
  then
  --
if g_debug then
     hr_utility.set_location(l_proc, 15);
end if;
     --
     -- set indicator to show p_position_definition_id did not enter pgm null
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
     --
if g_debug then
     hr_utility.set_location(l_proc, 27);
end if;
     --
  else
     l_null_ind := 0;
     -- l_name := null;
  end if;
  --
  begin
  --
    -- Start of API User Hook for the before hook of update_position
    --
    hr_position_bk2.update_position_b
      (
       p_position_id                    =>  p_position_id
      ,p_availability_status_id         =>  p_availability_status_id
--      ,p_business_group_id              =>  p_business_group_id
      ,p_entry_step_id                  =>  p_entry_step_id
      ,p_entry_grade_rule_id            =>  p_entry_grade_rule_id
--      ,p_job_id                         =>  p_job_id
      ,p_location_id                    =>  p_location_id
--      ,p_organization_id                =>  p_organization_id
      ,p_pay_freq_payroll_id            =>  p_pay_freq_payroll_id
      ,p_position_definition_id         =>  p_position_definition_id
      ,p_position_transaction_id        =>  p_position_transaction_id
      ,p_prior_position_id              =>  p_prior_position_id
      ,p_relief_position_id             =>  p_relief_position_id
      ,p_entry_grade_id                 =>  p_entry_grade_id
      ,p_successor_position_id          =>  p_successor_position_id
      ,p_supervisor_position_id         =>  p_supervisor_position_id
      ,p_amendment_date                 =>  p_amendment_date
      ,p_amendment_recommendation       =>  p_amendment_recommendation
      ,p_amendment_ref_number           =>  p_amendment_ref_number
      ,p_bargaining_unit_cd             =>  p_bargaining_unit_cd
      ,p_comments                       =>  p_comments
      ,p_current_job_prop_end_date      =>  p_current_job_prop_end_date
      ,p_current_org_prop_end_date      =>  p_current_org_prop_end_date
      ,p_avail_status_prop_end_date     =>  p_avail_status_prop_end_date
      ,p_date_effective                 =>  l_date_effective
      ,p_date_end                       =>  l_date_end
      ,p_earliest_hire_date             =>  p_earliest_hire_date
      ,p_fill_by_date                   =>  p_fill_by_date
      ,p_frequency                      =>  p_frequency
      ,p_fte                            =>  p_fte
      ,p_max_persons                    =>  p_max_persons
      ,p_name                           =>  p_name
      ,p_overlap_period                 =>  p_overlap_period
      ,p_overlap_unit_cd                =>  p_overlap_unit_cd
      ,p_pay_term_end_day_cd            =>  p_pay_term_end_day_cd
      ,p_pay_term_end_month_cd          =>  p_pay_term_end_month_cd
      ,p_permanent_temporary_flag       =>  p_permanent_temporary_flag
      ,p_permit_recruitment_flag        =>  p_permit_recruitment_flag
      ,p_position_type                  =>  p_position_type
      ,p_posting_description            =>  p_posting_description
      ,p_probation_period               =>  p_probation_period
      ,p_probation_period_unit_cd       =>  p_probation_period_unit_cd
      ,p_replacement_required_flag      =>  p_replacement_required_flag
      ,p_review_flag                    =>  p_review_flag
      ,p_seasonal_flag                  =>  p_seasonal_flag
      ,p_security_requirements          =>  p_security_requirements
      ,p_status                         =>  p_status
      ,p_term_start_day_cd              =>  p_term_start_day_cd
      ,p_term_start_month_cd            =>  p_term_start_month_cd
      ,p_time_normal_finish             =>  p_time_normal_finish
      ,p_time_normal_start              =>  p_time_normal_start
      ,p_update_source_cd               =>  p_update_source_cd
      ,p_working_hours                  =>  p_working_hours
      ,p_works_council_approval_flag    =>  p_works_council_approval_flag
      ,p_work_period_type_cd            =>  p_work_period_type_cd
      ,p_work_term_end_day_cd           =>  p_work_term_end_day_cd
      ,p_work_term_end_month_cd         =>  p_work_term_end_month_cd
      ,p_proposed_fte_for_layoff        =>  p_proposed_fte_for_layoff
      ,p_proposed_date_for_layoff       =>  p_proposed_date_for_layoff
      ,p_pay_basis_id                   =>  p_pay_basis_id
      ,p_supervisor_id                  =>  p_supervisor_id
      -- ,p_copied_to_old_table_flag       =>  p_copied_to_old_table_flag
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information_category           =>  p_information_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_attribute_category             =>  p_attribute_category
       ,p_segment1                      =>  l_segment1
       ,p_segment2                      =>  l_segment2
       ,p_segment3                      =>  l_segment3
       ,p_segment4                      =>  l_segment4
       ,p_segment5                      =>  l_segment5
       ,p_segment6                      =>  l_segment6
       ,p_segment7                      =>  l_segment7
       ,p_segment8                      =>  l_segment8
       ,p_segment9                      =>  l_segment9
       ,p_segment10                     =>  l_segment10
       ,p_segment11                     =>  l_segment11
       ,p_segment12                     =>  l_segment12
       ,p_segment13                     =>  l_segment13
       ,p_segment14                     =>  l_segment14
       ,p_segment15                     =>  l_segment15
       ,p_segment16                     =>  l_segment16
       ,p_segment17                     =>  l_segment17
       ,p_segment18                     =>  l_segment18
       ,p_segment19                     =>  l_segment19
       ,p_segment20                     =>  l_segment20
       ,p_segment21                     =>  l_segment21
       ,p_segment22                     =>  l_segment22
       ,p_segment23                     =>  l_segment23
       ,p_segment24                     =>  l_segment24
       ,p_segment25                     =>  l_segment25
       ,p_segment26                     =>  l_segment26
       ,p_segment27                     =>  l_segment27
       ,p_segment28                     =>  l_segment28
       ,p_segment29                     =>  l_segment29
       ,p_segment30                     =>  l_segment30
       ,p_concat_segments               =>  p_concat_segments
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      ,p_language_code                  =>  l_language_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_POSITION'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_position
    --
  end;

if g_debug then
  hr_utility.set_location(l_proc, 30);
end if;
  --
  -- Validation in addition to Table Handlers
  --
  -- Retrieve current position details from position
  --
  l_api_updating := hr_psf_shd.api_updating
     (p_position_id             => p_position_id
     ,p_effective_Date          => p_effective_Date
     ,p_object_version_number   => l_object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 40);
end if;
  --
  if not l_api_updating then
if g_debug then
    hr_utility.set_location(l_proc, 50);
end if;
    --
    -- As this an updating API, the position should already exist.
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  else
    --
if g_debug then
    hr_utility.set_location(l_proc, 60);
end if;
    --
    if l_null_ind = 0
    then
       l_position_definition_id := hr_psf_shd.g_old_rec.position_definition_id;
    end if;
  end if;
  --
  open csr_idsel;
  fetch csr_idsel
  into l_flex_num;
    if csr_idsel%NOTFOUND then
       close csr_idsel;
          hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE', l_proc);
          hr_utility.set_message_token('STEP','5');
          hr_utility.raise_error;
     end if;
  close csr_idsel;
  --
  open csr_isfirstrow;
  fetch csr_isfirstrow into l_minesd;
  if csr_isfirstrow%NOTFOUND then
     close csr_idsel;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE', l_proc);
     hr_utility.set_message_token('STEP','6');
     hr_utility.raise_error;
  else
    close csr_isfirstrow;
  end if;
  --
if g_debug then
  hr_utility.set_location(l_proc||'l_pos_def_id : '
  ||l_position_definition_id, 700);
  hr_utility.set_location(l_proc||'l_name :' || l_name, 701);
  hr_utility.set_location(l_proc, 70);
end if;
  --
  if l_null_ind = 1 and l_name is null
  then
     hr_kflex_utility.upd_or_sel_keyflex_comb
        (p_appl_short_name      => 'PER'
        ,p_flex_code            => 'POS'
        ,p_flex_num             => l_flex_num
        ,p_segment1             => p_segment1
        ,p_segment2             => p_segment2
        ,p_segment3             => p_segment3
        ,p_segment4             => p_segment4
        ,p_segment5             => p_segment5
        ,p_segment6             => p_segment6
        ,p_segment7             => p_segment7
        ,p_segment8             => p_segment8
        ,p_segment9             => p_segment9
        ,p_segment10            => p_segment10
        ,p_segment11            => p_segment11
        ,p_segment12            => p_segment12
        ,p_segment13            => p_segment13
        ,p_segment14            => p_segment14
        ,p_segment15            => p_segment15
        ,p_segment16            => p_segment16
        ,p_segment17            => p_segment17
        ,p_segment18            => p_segment18
        ,p_segment19            => p_segment19
        ,p_segment20            => p_segment20
        ,p_segment21            => p_segment21
        ,p_segment22            => p_segment22
        ,p_segment23            => p_segment23
        ,p_segment24            => p_segment24
        ,p_segment25            => p_segment25
        ,p_segment26            => p_segment26
        ,p_segment27            => p_segment27
        ,p_segment28            => p_segment28
        ,p_segment29            => p_segment29
        ,p_segment30            => p_segment30
        ,p_ccid                 => l_position_definition_id
        ,p_concat_segments_out  => l_name
        );
  end if;
  --
  if l_null_ind = 0
  then
     if nvl(fnd_profile.value('FLEXFIELDS:VALIDATE_ON_SERVER'),'N') = 'Y'
     or p_name is null
     then
        --
        hr_kflex_utility.upd_or_sel_keyflex_comb
        (p_appl_short_name      => 'PER'
        ,p_flex_code            => 'POS'
        ,p_flex_num             => l_flex_num
        ,p_segment1             => p_segment1
        ,p_segment2             => p_segment2
        ,p_segment3             => p_segment3
        ,p_segment4             => p_segment4
        ,p_segment5             => p_segment5
        ,p_segment6             => p_segment6
        ,p_segment7             => p_segment7
        ,p_segment8             => p_segment8
        ,p_segment9             => p_segment9
        ,p_segment10            => p_segment10
        ,p_segment11            => p_segment11
        ,p_segment12            => p_segment12
        ,p_segment13            => p_segment13
        ,p_segment14            => p_segment14
        ,p_segment15            => p_segment15
        ,p_segment16            => p_segment16
        ,p_segment17            => p_segment17
        ,p_segment18            => p_segment18
        ,p_segment19            => p_segment19
        ,p_segment20            => p_segment20
        ,p_segment21            => p_segment21
        ,p_segment22            => p_segment22
        ,p_segment23            => p_segment23
        ,p_segment24            => p_segment24
        ,p_segment25            => p_segment25
        ,p_segment26            => p_segment26
        ,p_segment27            => p_segment27
        ,p_segment28            => p_segment28
        ,p_segment29            => p_segment29
        ,p_segment30            => p_segment30
        ,p_concat_segments_in   => p_concat_segments
        ,p_ccid                 => l_position_definition_id
        ,p_concat_segments_out  => l_name
        );
     end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(l_proc||'l_pos_def_id : '
  || l_position_definition_id, 700);
  hr_utility.set_location(l_proc||'l_name :' || l_name, 701);
  hr_utility.set_location(l_proc, 80);
end if;
 /*
  --
  -- Because we may need to maintain the valid grade dates, need to
  -- explicitly lock the hr_all_positions_f row.
  --
  -- hr_psf_shd.lck(p_position_id => p_position_id
  --       ,p_object_version_number => l_object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 85);
end if;
 Maintain Grade requirements to be investigated
  --
  -- If date_effective is being updated , then need to maintain valid grades
  -- accordingly for that position.
  --
  IF ((nvl(p_date_effective, hr_api.g_date) <> hr_api.g_date) and
       hr_psf_shd.g_old_rec.date_effective <>
       nvl(p_date_effective, hr_api.g_date)) THEN
  --

  PER_POSITIONS_PKG.maintain_valid_grades
    (p_validate             => p_validate
    ,p_position_id          => p_position_id
    ,p_maintenance_mode     => 'DATE_EFFECTIVE'
    ,p_date_end             => l_date_end
    ,p_date_effective       => l_date_effective
    ,p_valid_grades_changed => l_valid_grades_changed1);
  --
  end if;
  --
if g_debug then
   hr_utility.set_location(l_proc, 90);
end if;
  --
  -- If date_end is being updated , then need to maintain valid grades
  -- accordingly for that position.
  --
  IF ((nvl(p_date_end, hr_api.g_date) <> hr_api.g_date) and
         nvl(hr_psf_shd.g_old_rec.date_end, hr_api.g_date) <>
         nvl(p_date_end, hr_api.g_date)) THEN
  --
  pER_POSITIONS_PKG.maintain_valid_grades
    (p_validate         => p_validate
    ,p_position_id      => p_position_id
    ,p_maintenance_mode => 'DATE_END'
    ,p_date_end         => l_date_end
    ,p_date_effective   => l_date_effective
    ,p_valid_grades_changed => l_valid_grades_changed2);
    --
  end if;
*/
  --
  -- Update Position Details
  --
if g_debug then
  hr_utility.set_location(l_proc||'l_pos_def_id : '
  || l_position_definition_id, 800);
  hr_utility.set_location(l_proc||'l_name :' || l_name, 801);
end if;
  --
  hr_psf_upd.upd
    (
     p_position_id                   => p_position_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_availability_status_id        => p_availability_status_id
--    ,p_business_group_id             => p_business_group_id
    ,p_entry_step_id                 => p_entry_step_id
    ,p_entry_grade_rule_id           => p_entry_grade_rule_id
--    ,p_job_id                        => p_job_id
    ,p_location_id                   => p_location_id
--    ,p_organization_id               => p_organization_id
    ,p_pay_freq_payroll_id           => p_pay_freq_payroll_id
    ,p_position_definition_id        => l_position_definition_id
    ,p_position_transaction_id       => p_position_transaction_id
    ,p_prior_position_id             => p_prior_position_id
    ,p_relief_position_id            => p_relief_position_id
    ,p_entry_grade_id                => p_entry_grade_id
    ,p_successor_position_id         => p_successor_position_id
    ,p_supervisor_position_id        => p_supervisor_position_id
    ,p_amendment_date                => p_amendment_date
    ,p_amendment_recommendation      => p_amendment_recommendation
    ,p_amendment_ref_number          => p_amendment_ref_number
    ,p_bargaining_unit_cd            => p_bargaining_unit_cd
    ,p_comments                      => p_comments
    ,p_current_job_prop_end_date     => p_current_job_prop_end_date
    ,p_current_org_prop_end_date     => p_current_org_prop_end_date
    ,p_avail_status_prop_end_date    => p_avail_status_prop_end_date
    ,p_date_effective                => l_date_effective
    ,p_date_end                      => p_date_end
    ,p_earliest_hire_date            => p_earliest_hire_date
    ,p_fill_by_date                  => p_fill_by_date
    ,p_frequency                     => p_frequency
    ,p_fte                           => p_fte
    ,p_max_persons                   => p_max_persons
    ,p_name                          => l_name
    ,p_overlap_period                => p_overlap_period
    ,p_overlap_unit_cd               => p_overlap_unit_cd
    ,p_pay_term_end_day_cd           => p_pay_term_end_day_cd
    ,p_pay_term_end_month_cd         => p_pay_term_end_month_cd
    ,p_permanent_temporary_flag      => p_permanent_temporary_flag
    ,p_permit_recruitment_flag       => p_permit_recruitment_flag
    ,p_position_type                 => p_position_type
    ,p_posting_description           => p_posting_description
    ,p_probation_period              => p_probation_period
    ,p_probation_period_unit_cd      => p_probation_period_unit_cd
    ,p_replacement_required_flag     => p_replacement_required_flag
    ,p_review_flag                   => p_review_flag
    ,p_seasonal_flag                 => p_seasonal_flag
    ,p_security_requirements         => p_security_requirements
    ,p_status                        => p_status
    ,p_term_start_day_cd             => p_term_start_day_cd
    ,p_term_start_month_cd           => p_term_start_month_cd
    ,p_time_normal_finish            => p_time_normal_finish
    ,p_time_normal_start             => p_time_normal_start
    ,p_update_source_cd              => p_update_source_cd
    ,p_working_hours                 => p_working_hours
    ,p_works_council_approval_flag   => p_works_council_approval_flag
    ,p_work_period_type_cd           => p_work_period_type_cd
    ,p_work_term_end_day_cd          => p_work_term_end_day_cd
    ,p_work_term_end_month_cd        => p_work_term_end_month_cd
    ,p_proposed_fte_for_layoff       => p_proposed_fte_for_layoff
    ,p_proposed_date_for_layoff      => p_proposed_date_for_layoff
    ,p_pay_basis_id                  =>  p_pay_basis_id
    ,p_supervisor_id                 =>  p_supervisor_id
    ,p_copied_to_old_table_flag      =>  'N'
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
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_information_category          => p_information_category
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
    ,p_attribute21                   => p_attribute21
    ,p_attribute22                   => p_attribute22
    ,p_attribute23                   => p_attribute23
    ,p_attribute24                   => p_attribute24
    ,p_attribute25                   => p_attribute25
    ,p_attribute26                   => p_attribute26
    ,p_attribute27                   => p_attribute27
    ,p_attribute28                   => p_attribute28
    ,p_attribute29                   => p_attribute29
    ,p_attribute30                   => p_attribute30
    ,p_attribute_category            => p_attribute_category
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_validate                      => p_validate
    );
  --
  -- PMFLETCH Update translation table if base table record is to eot and
  -- position_definition_id has been updated.
  --
  if ( l_effective_end_date = hr_api.g_eot
     AND (
       hr_psf_shd.g_old_rec.position_definition_id <> l_position_definition_id
       or
       hr_psf_shd.g_old_rec.name <> l_name
       )
     ) then
    hr_pft_upd.upd_tl
      ( p_language_code                => l_language_code
      , p_position_id                  => p_position_id
      , p_position_definition_id       => l_position_definition_id
      );
  end if;
  --
  -- Refresh per_all_positions
  --
  begin
    --
    -- call refresh_position procedure to replicate changes in per_all_positions
    --
if g_debug then
    hr_utility.set_location ( l_proc, 1000);
end if;
    --
    synchronize_per_all_positions
      (p_position_id              => p_position_id
      ,p_effective_date           => p_effective_date
      ,p_datetrack_mode           => p_datetrack_mode
      ,p_object_version_number    => l_object_version_number
      );
    --
if g_debug then
    hr_utility.set_location ( l_proc, 1001);
end if;
    --
  end;
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_position
    --
    hr_position_bk2.update_position_a
      (
       p_position_id                    =>  p_position_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_availability_status_id         =>  p_availability_status_id
--      ,p_business_group_id              =>  p_business_group_id
      ,p_entry_step_id                  =>  p_entry_step_id
      ,p_entry_grade_rule_id            =>  p_entry_grade_rule_id
--      ,p_job_id                         =>  p_job_id
      ,p_location_id                    =>  p_location_id
--      ,p_organization_id                =>  p_organization_id
      ,p_pay_freq_payroll_id            =>  p_pay_freq_payroll_id
      ,p_position_definition_id         =>  l_position_definition_id
      ,p_position_transaction_id        =>  p_position_transaction_id
      ,p_prior_position_id              =>  p_prior_position_id
      ,p_relief_position_id             =>  p_relief_position_id
      ,p_entry_grade_id                 =>  p_entry_grade_id
      ,p_successor_position_id          =>  p_successor_position_id
      ,p_supervisor_position_id         =>  p_supervisor_position_id
      ,p_amendment_date                 =>  p_amendment_date
      ,p_amendment_recommendation       =>  p_amendment_recommendation
      ,p_amendment_ref_number           =>  p_amendment_ref_number
      ,p_bargaining_unit_cd             =>  p_bargaining_unit_cd
      ,p_comments                       =>  p_comments
      ,p_current_job_prop_end_date      =>  p_current_job_prop_end_date
      ,p_current_org_prop_end_date      =>  p_current_org_prop_end_date
      ,p_avail_status_prop_end_date     =>  p_avail_status_prop_end_date
      ,p_date_effective                 =>  l_date_effective
      ,p_date_end                       =>  l_date_end
      ,p_earliest_hire_date             =>  p_earliest_hire_date
      ,p_fill_by_date                   =>  p_fill_by_date
      ,p_frequency                      =>  p_frequency
      ,p_fte                            =>  p_fte
      ,p_max_persons                    =>  p_max_persons
      ,p_name                           =>  p_name
      ,p_overlap_period                 =>  p_overlap_period
      ,p_overlap_unit_cd                =>  p_overlap_unit_cd
      ,p_pay_term_end_day_cd            =>  p_pay_term_end_day_cd
      ,p_pay_term_end_month_cd          =>  p_pay_term_end_month_cd
      ,p_permanent_temporary_flag       =>  p_permanent_temporary_flag
      ,p_permit_recruitment_flag        =>  p_permit_recruitment_flag
      ,p_position_type                  =>  p_position_type
      ,p_posting_description            =>  p_posting_description
      ,p_probation_period               =>  p_probation_period
      ,p_probation_period_unit_cd       =>  p_probation_period_unit_cd
      ,p_replacement_required_flag      =>  p_replacement_required_flag
      ,p_review_flag                    =>  p_review_flag
      ,p_seasonal_flag                  =>  p_seasonal_flag
      ,p_security_requirements          =>  p_security_requirements
      ,p_status                         =>  p_status
      ,p_term_start_day_cd              =>  p_term_start_day_cd
      ,p_term_start_month_cd            =>  p_term_start_month_cd
      ,p_time_normal_finish             =>  p_time_normal_finish
      ,p_time_normal_start              =>  p_time_normal_start
      ,p_update_source_cd               =>  p_update_source_cd
      ,p_working_hours                  =>  p_working_hours
      ,p_works_council_approval_flag    =>  p_works_council_approval_flag
      ,p_work_period_type_cd            =>  p_work_period_type_cd
      ,p_work_term_end_day_cd           =>  p_work_term_end_day_cd
      ,p_work_term_end_month_cd         =>  p_work_term_end_month_cd
      ,p_proposed_fte_for_layoff        =>  p_proposed_fte_for_layoff
      ,p_proposed_date_for_layoff       =>  p_proposed_date_for_layoff
      ,p_pay_basis_id                   =>  p_pay_basis_id
      ,p_supervisor_id                  =>  p_supervisor_id
      --,p_copied_to_old_table_flag       =>  p_copied_to_old_table_flag
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_information_category           =>  p_information_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_attribute21                    =>  p_attribute21
      ,p_attribute22                    =>  p_attribute22
      ,p_attribute23                    =>  p_attribute23
      ,p_attribute24                    =>  p_attribute24
      ,p_attribute25                    =>  p_attribute25
      ,p_attribute26                    =>  p_attribute26
      ,p_attribute27                    =>  p_attribute27
      ,p_attribute28                    =>  p_attribute28
      ,p_attribute29                    =>  p_attribute29
      ,p_attribute30                    =>  p_attribute30
      ,p_attribute_category             =>  p_attribute_category
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
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      ,p_language_code                  =>  l_language_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_POSITION'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_position
    --
  end;
  --
if g_debug then
  hr_utility.set_location(l_proc, 100);
end if;
  -- -----------      Maintain Grade requirements to be investigated
  --
  -- Because we may need to maintain the valid grade dates, need to
  -- explicitly lock the hr_all_positions_f row.
  --
  -- hr_psf_shd.lck(p_position_id => p_position_id
  --       ,p_object_version_number => l_object_version_number);
  --
if g_debug then
  hr_utility.set_location(l_proc, 85);
end if;
  --
  -- If date_effective is being updated , then need to maintain valid grades
  -- accordingly for that position.
  --
  IF ((nvl(p_date_effective, hr_api.g_date) <> hr_api.g_date) and
       hr_psf_shd.g_old_rec.date_effective <>
       nvl(p_date_effective, hr_api.g_date)) THEN
  --

  maintain_valid_grades
    (p_validate             => p_validate
    ,p_position_id          => p_position_id
    ,p_maintenance_mode     => 'DATE_EFFECTIVE'
    ,p_date_end             => l_date_end
    ,p_date_effective       => l_date_effective
    ,p_valid_grades_changed => l_valid_grades_changed1);
  --
  end if;
  --
if g_debug then
   hr_utility.set_location(l_proc, 90);
end if;
  --
  -- If date_end is being updated , then need to maintain valid grades
  -- accordingly for that position.
  --
  IF ((nvl(p_date_end, hr_api.g_date) <> hr_api.g_date) and
         nvl(hr_psf_shd.g_old_rec.date_end, hr_api.g_date) <>
         nvl(p_date_end, hr_api.g_date)) THEN
  --
  maintain_valid_grades
    (p_validate         => p_validate
    ,p_position_id      => p_position_id
    ,p_maintenance_mode => 'DATE_END'
    ,p_date_end         => l_date_end
    ,p_date_effective   => l_date_effective
    ,p_valid_grades_changed => l_valid_grades_changed2);
    --
  end if;
  --
  if l_valid_grades_changed1 or l_valid_grades_changed2 then
    p_valid_grades_changed_warning := TRUE;
  else
    p_valid_grades_changed_warning := FALSE;
  end if;
  --
if g_debug then
  hr_utility.set_location(l_proc, 110);
end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_position_definition_id := l_position_definition_id;
  p_name := l_name;
  p_object_version_number := l_object_version_number;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  --
if g_debug then
  hr_utility.set_location('date effective is '||to_char(p_date_effective)
  ||l_proc,192);
  hr_utility.set_location(' Leaving:'||l_proc, 120);
end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_position;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := p_object_version_number;
    p_position_definition_id := p_position_definition_id;
if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 130);
end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number          := l_object_version_number;
    p_position_definition_id         := l_position_definition_id;
    p_name                           := l_name;
    p_effective_start_date           := null;
    p_effective_end_date             := null;
    p_valid_grades_changed_warning   := null;

    ROLLBACK TO update_position;
    raise;
    --
end update_position;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_position >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_position
  (p_validate                       in  boolean  default false
  ,p_position_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_security_profile_id	    in number	  default hr_security.get_security_profile
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ;
  l_object_version_number hr_all_positions_f.object_version_number%TYPE;
  l_effective_start_date hr_all_positions_f.effective_start_date%TYPE;
  l_effective_end_date hr_all_positions_f.effective_end_date%TYPE;
  --
  l_view_all_positions_flag		varchar2(30);
--
  cursor c1 is
  select view_all_positions_flag
  from per_security_profiles
  where security_profile_id = p_security_profile_id;
--
begin

  --
  g_debug := hr_utility.debug_enabled;
if g_debug then
  l_proc  := g_package||'delete_position';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_position;
  --
if g_debug then
  hr_utility.set_location(l_proc, 20);
end if;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_position
    --
    hr_position_bk3.delete_position_b
      (
       p_position_id                    =>  p_position_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_POSITION'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_position
    --
  end;
  --
  begin
  --
  --
  -- Delete record from position security list table
  --
  if (p_datetrack_mode = 'ZAP') then
    open c1;
    fetch c1 into l_view_all_positions_flag;
    close c1;
    --
--    if l_view_all_positions_flag <> 'Y' then
        hr_security.delete_pos_from_list(p_position_Id);
--    end if;
  end if;
  --
  end;
  --
  -- PMFLETCH Delete TL Table
  --
  if (p_datetrack_mode = 'ZAP') then
    hr_pft_del.del_tl
      ( p_position_id                => p_position_id
      , p_datetrack_mode             => p_datetrack_mode
      );
  end if;
  --
  declare
    --
    cursor c_position_definition(p_position_id number) is
    select position_definition_id
    from hr_all_positions_f
    where position_id = p_position_id;
    --
    l_position_definition_id number;
    l_pos_def_deleted   boolean;
  begin
    open c_position_definition(p_position_id);
    --
  hr_psf_del.del
    (
     p_position_id                   => p_position_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_validate                      => p_validate
    ,p_security_profile_id	     => p_security_profile_id
    );
  --
  -- PMFLETCH Delete/Update TL Table
  --
  if (p_datetrack_mode <> 'ZAP') then
    hr_pft_del.del_tl
      ( p_position_id                => p_position_id
      , p_datetrack_mode             => p_datetrack_mode
      );
  end if;

  --

  --
  begin
    --
    -- call refresh_position procedure to replicate changes in per_all_positions
    --
if g_debug then
    hr_utility.set_location ( l_proc, 1000);
end if;
    --
    synchronize_per_all_positions
      (p_position_id              => p_position_id
      ,p_effective_date           => p_effective_date
      ,p_datetrack_mode           => p_datetrack_mode
      ,p_object_version_number     => l_object_version_number
      );
    --
if g_debug then
    hr_utility.set_location ( l_proc, 1001);
end if;
    --
    -- delete Position Defintions if not used
    --
    if (not p_validate) then
    loop
      fetch c_position_definition into l_position_definition_id;
      exit when (c_position_definition%notfound);
      l_pos_def_deleted := delete_unused_per_pos_def(l_position_definition_id);
    end loop;
    end if;
    close c_position_definition;
  exception
    when others then
      if (c_position_definition%isopen) then
        close c_position_definition;
      end if;
      raise;
  end;
   --
  end;
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_position
    --
    hr_position_bk3.delete_position_a
      (
       p_position_id                    =>  p_position_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_POSITION'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_position
    --
  end;
  --
if g_debug then
  hr_utility.set_location(l_proc, 60);
end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 70);
end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_position;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    p_object_version_number := l_object_version_number;

    ROLLBACK TO delete_position;
    raise;
    --
end delete_position;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_position_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ;
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc  := g_package||'lck';
  hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  hr_psf_shd.lck
    (
      p_position_id                => p_position_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode
    );
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 70);
end if;
  --
end lck;
--
-- ----------------------------------------------------------------------------
-- |------------------------< regenerate_position_name >----------------------|
-- ----------------------------------------------------------------------------
--  Regenerate_position_name to rebuild position name for only one position
--  from current flexfield values
--
-- If this process is called at the server-side ensure that
-- fnd_profiles are initialized when position flexfield valuesets
-- uses profile values
--
procedure regenerate_position_name(p_position_id number) is
cursor c_position(p_position_id number) is
select psf.effective_start_date, psf.position_definition_id,
       psf.object_version_number, pd.id_flex_num
from hr_all_positions_f psf, per_position_definitions pd
where position_id = p_position_id
and psf.position_definition_id = pd.position_definition_id
and effective_end_date = hr_api.g_eot;
--
l_effective_start_date         date;
l_effective_end_date           date;
l_position_definition_id       number;
l_valid_grades_changed_warning boolean;
l_name                         varchar2(420);
l_object_version_number        number;
l_effective_date               date;
l_id_flex_num                  number;
l_commit                       number;
begin
  if (p_position_id is not null) then
    --
    open c_position(p_position_id);
    fetch c_position into l_effective_date, l_position_definition_id,
                          l_object_version_number, l_id_flex_num;
    --
    if (c_position%found) then
      --
      dt_fndate.change_ses_date(trunc(l_effective_date),l_commit);
      --
      l_name := FND_FLEX_EXT.GET_SEGS('PER', 'POS', l_id_flex_num, l_position_definition_id);
      --
      hr_position_api.update_position
      (p_validate                       => false
      ,p_position_id                    => p_position_id
      ,p_effective_start_date           => l_effective_start_date
      ,p_effective_end_date             => l_effective_end_date
      ,p_position_definition_id         => l_position_definition_id
      ,p_valid_grades_changed_warning   => l_valid_grades_changed_warning
      ,p_name                           => l_name
      ,p_object_version_number          => l_object_version_number
      ,p_effective_date                 => l_effective_date
      ,p_datetrack_mode                 => 'CORRECTION'
      );
      --
    end if;
    --
    close c_position;
    --
  end if;
  --
end;
--
-- ----------------------------------------------------------------------------
-- |------------------------< regenerate_position_names >---------------------|
-- ----------------------------------------------------------------------------
--  Regenerate Position Names process is used to rebuild
--  position names using current Position flexfield values
--
procedure regenerate_position_names(
                            errbuf   out nocopy varchar2
                          , retcode   out nocopy number
                          , p_business_group_id number,
                            p_organization_id number) is
--
cursor c_all_positions is
select psf.position_id
from hr_all_positions_f psf
where psf.effective_end_date = hr_api.g_eot;
--
cursor c_bg_positions(p_business_group_id number) is
select psf.position_id
from hr_all_positions_f psf
where psf.business_group_id = p_business_group_id
and psf.effective_end_date = hr_api.g_eot;
--
cursor c_org_positions(p_organization_id number) is
select psf.position_id
from hr_all_positions_f psf
where psf.organization_id = p_organization_id
and psf.effective_end_date = hr_api.g_eot;
--
l_position_id number;
--
begin
  if (p_organization_id is not null) then
    -- Regenerate Position names for all positions in an organization
    for r_pos in c_org_positions(p_organization_id)
    loop
      l_position_id := r_pos.position_id;
      regenerate_position_name(r_pos.position_id);
      commit;
    end loop;
  elsif (p_business_group_id is not null) then
    -- Regenerate Position names for all positions in a Business Group
    for r_pos in c_bg_positions(p_business_group_id)
    loop
      l_position_id := r_pos.position_id;
      regenerate_position_name(r_pos.position_id);
      commit;
    end loop;
  else
    -- Regenerate Position names for all positions
    for r_pos in c_all_positions
    loop
      l_position_id := r_pos.position_id;
      regenerate_position_name(r_pos.position_id);
      commit;
    end loop;
  end if;
  --
  --
exception
  when others then
    retcode := 2;
    errbuf := SQLERRM;
end;
--
-- end of date tracked position api code
--
--
end hr_position_api;

/
