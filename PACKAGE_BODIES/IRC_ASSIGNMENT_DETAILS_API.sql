--------------------------------------------------------
--  DDL for Package Body IRC_ASSIGNMENT_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_ASSIGNMENT_DETAILS_API" as
/* $Header: iriadapi.pkb 120.3.12010000.3 2010/05/18 14:44:54 vmummidi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  irc_assignment_details_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_assignment_details >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_assignment_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_attempt_id                    in     number   default null
  ,p_qualified                     in     varchar2 default null
  ,p_considered                    in     varchar2 default null
  ,p_assignment_details_id            out nocopy   number
  ,p_details_version                  out nocopy   number
  ,p_effective_start_date             out nocopy   date
  ,p_effective_end_date               out nocopy   date
  ,p_object_version_number            out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_latest_details         irc_assignment_details_f.latest_details%TYPE;
  -- out variables
  l_assignment_details_id  irc_assignment_details_f.assignment_details_id%TYPE;
  l_details_version        irc_assignment_details_f.details_version%TYPE;
  l_effective_start_date   irc_assignment_details_f.effective_start_date%TYPE;
  l_effective_end_date     irc_assignment_details_f.effective_end_date%TYPE;
  l_object_version_number  irc_assignment_details_f.object_version_number%TYPE;

  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'create_assignment_details';
  l_considered           varchar2(30);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_assignment_details;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  hr_utility.set_location(l_proc, 20);
  --
  -- set the value of considered, if qualified is not null.
  --
  if ( p_qualified <> null ) then
    l_considered := 'Y';
  else
    l_considered := p_considered;
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    irc_assignment_details_bk1.create_assignment_details_b
      (p_effective_date                => l_effective_date
      ,p_assignment_id                 => p_assignment_id
      ,p_attempt_id                    => p_attempt_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_assignment_details'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  irc_iad_ins.ins
    (p_effective_date             => l_effective_date
    ,p_assignment_id              => p_assignment_id
    ,p_attempt_id                 => p_attempt_id
    ,p_qualified                  => p_qualified
    ,p_considered                 => l_considered
    ,p_assignment_details_id      => l_assignment_details_id
    ,p_details_version            => l_details_version
    ,p_latest_details             => l_latest_details
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    ,p_object_version_number      => l_object_version_number
    );
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    irc_assignment_details_bk1.create_assignment_details_a
      (p_effective_date                => l_effective_date
      ,p_assignment_id                 => p_assignment_id
      ,p_attempt_id                    => p_attempt_id
      ,p_qualified                     => p_qualified
      ,p_considered                    => l_considered
      ,p_assignment_details_id         => l_assignment_details_id
      ,p_details_version               => l_details_version
      ,p_latest_details                => l_latest_details
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_assignment_details'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_assignment_details_id  := l_assignment_details_id;
  p_details_version        := l_details_version;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_assignment_details;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_assignment_details_id  := null;
    p_details_version        := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_assignment_details;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_assignment_details_id  := null;
    p_details_version        := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_assignment_details;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_assignment_details >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_assignment_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_assignment_id                 in     number   default hr_api.g_number
  ,p_attempt_id                    in     number   default hr_api.g_number
  ,p_qualified                     in     varchar2 default hr_api.g_varchar2
  ,p_considered                    in     varchar2 default hr_api.g_varchar2
  ,p_assignment_details_id         in out nocopy   number
  ,p_object_version_number         in out nocopy   number
  ,p_details_version                  out nocopy   number
  ,p_effective_start_date             out nocopy   date
  ,p_effective_end_date               out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_latest_details         irc_assignment_details_f.latest_details%TYPE;
  -- out variables
  l_assignment_details_id  irc_assignment_details_f.assignment_details_id%TYPE;
  l_details_version        irc_assignment_details_f.details_version%TYPE;
  l_effective_start_date   irc_assignment_details_f.effective_start_date%TYPE;
  l_effective_end_date     irc_assignment_details_f.effective_end_date%TYPE;
  l_object_version_number  irc_assignment_details_f.object_version_number%TYPE;

  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'update_assignment_details';
  l_considered           varchar2(30);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_assignment_details;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  l_assignment_details_id := p_assignment_details_id;
  l_object_version_number := p_object_version_number;

  hr_utility.set_location(l_proc, 20);
  --
  -- set the value of considered, if qualified is not null.
  --
  if ( p_qualified <> hr_api.g_varchar2 ) then
    l_considered := 'Y';
  else
    l_considered := p_considered;
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    irc_assignment_details_bk2.update_assignment_details_b
      (p_effective_date                => l_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_assignment_id                 => p_assignment_id
      ,p_attempt_id                    => p_attempt_id
      ,p_assignment_details_id         => l_assignment_details_id
      ,p_object_version_number         => l_object_version_number
      ,p_qualified                     => p_qualified
      ,p_considered                    => l_considered
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_assignment_details'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  irc_iad_upd.upd
    (p_effective_date             => l_effective_date
    ,p_datetrack_mode             => p_datetrack_update_mode
    ,p_assignment_id              => p_assignment_id
    ,p_attempt_id                 => p_attempt_id
    ,p_qualified                  => p_qualified
    ,p_considered                 => l_considered
    ,p_assignment_details_id      => l_assignment_details_id
    ,p_details_version            => l_details_version
    ,p_latest_details             => l_latest_details
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    ,p_object_version_number      => l_object_version_number
    );
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    irc_assignment_details_bk2.update_assignment_details_a
      (p_effective_date                => l_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_assignment_details_id         => l_assignment_details_id
      ,p_assignment_id                 => p_assignment_id
      ,p_attempt_id                    => p_attempt_id
      ,p_details_version               => l_details_version
      ,p_latest_details                => l_latest_details
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_object_version_number         => l_object_version_number
      ,p_qualified                     => p_qualified
      ,p_considered                    => l_considered
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_assignment_details'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_assignment_details_id  := l_assignment_details_id;
  p_object_version_number  := l_object_version_number;
  p_details_version        := l_details_version;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_assignment_details;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_assignment_details_id  := p_assignment_details_id;
    p_object_version_number  := p_object_version_number;
    p_details_version        := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_assignment_details;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_assignment_details_id  := p_assignment_details_id;
    p_object_version_number  := p_object_version_number;
    p_details_version        := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_assignment_details;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< copy_assignment_details >----------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_assignment_details
  (p_source_assignment_id in number
  ,p_target_assignment_id in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'copy_assignment_details';
  --
  l_assignment_details_id  irc_assignment_details_f.assignment_details_id%type;
  --
  cursor csr_assignment_details is
  select *
    from irc_assignment_details_f
   where assignment_id = p_source_assignment_id;
  --
  Cursor C_Sel1 is select irc_assignment_details_s.nextval from sys.dual;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_assignment_details;
  --
  --
  -- Process Logic
  --
  FOR l_asg_det_rec in csr_assignment_details
  LOOP
  --
  --
  Open C_Sel1;
  Fetch C_Sel1 Into l_assignment_details_id;
  Close C_Sel1;
  --
  insert into irc_assignment_details_f
      (assignment_details_id
      ,assignment_id
      ,effective_start_date
      ,effective_end_date
      ,details_version
      ,latest_details
      ,attempt_id
      ,qualified
      ,considered
      ,object_version_number
      )
  Values
    (l_assignment_details_id
    ,p_target_assignment_id
    ,l_asg_det_rec.effective_start_date
    ,l_asg_det_rec.effective_end_date
    ,l_asg_det_rec.details_version
    ,l_asg_det_rec.latest_details
    ,l_asg_det_rec.attempt_id
    ,l_asg_det_rec.qualified
    ,l_asg_det_rec.considered
    ,l_asg_det_rec.object_version_number
    );
  --
  END LOOP;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_assignment_details;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 30);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_assignment_details;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 40);
    raise;
end copy_assignment_details;
--
end irc_assignment_details_api;

/
