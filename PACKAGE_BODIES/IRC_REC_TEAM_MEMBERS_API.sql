--------------------------------------------------------
--  DDL for Package Body IRC_REC_TEAM_MEMBERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_REC_TEAM_MEMBERS_API" as
/* $Header: irrtmapi.pkb 120.3 2008/01/22 10:16:41 mkjayara noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  IRC_REC_TEAM_MEMBERS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_REC_TEAM_MEMBER >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_rec_team_member
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_vacancy_id                    in     number
  ,p_job_id                        in     number   default null
  ,p_start_date                    in     date     default null
  ,p_end_date                      in     date     default null
  ,p_update_allowed                in     varchar2 default 'Y'
  ,p_delete_allowed                in     varchar2 default 'Y'
  ,p_rec_team_member_id            out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_interview_security             in      varchar2 default 'SELF'
  ) is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc                    varchar2(72) := g_package||'create_rec_team_member';
  l_object_version_number   number;
  l_start_date              date;
  l_end_date                date;
  l_rec_team_member_id      number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_rec_team_member;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_start_date := trunc(p_start_date);
  l_end_date   := trunc(p_end_date);
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_REC_TEAM_MEMBERS_BK1.CREATE_REC_TEAM_MEMBER_B
    (p_rec_team_member_id  =>   p_rec_team_member_id
    ,p_person_id           =>   p_person_id
    ,p_vacancy_id          =>   p_vacancy_id
    ,p_job_id              =>   p_job_id
    ,p_start_date          =>   l_start_date
    ,p_end_date            =>   l_end_date
    ,p_update_allowed      =>   p_update_allowed
    ,p_delete_allowed      =>   p_delete_allowed
    ,p_interview_security   =>   p_interview_security
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_REC_TEAM_MEMBER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_rtm_ins.ins
  (p_job_id                         => p_job_id
  ,p_update_allowed                 => p_update_allowed
  ,p_delete_allowed                 => p_delete_allowed
  ,p_start_date                     => l_start_date
  ,p_end_date                       => l_end_date
  ,p_person_id                      => p_person_id
  ,p_vacancy_id                     => p_vacancy_id
  ,p_rec_team_member_id             => l_rec_team_member_id
  ,p_object_version_number          => l_object_version_number
  ,p_interview_security              => p_interview_security
  );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_REC_TEAM_MEMBERS_BK1.CREATE_REC_TEAM_MEMBER_A
    (p_rec_team_member_id           => l_rec_team_member_id
    ,p_person_id                    => p_person_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_job_id                       => p_job_id
    ,p_start_date                   => l_start_date
    ,p_end_date                     => l_end_date
    ,p_update_allowed               => p_update_allowed
    ,p_delete_allowed               => p_delete_allowed
    ,p_object_version_number        => l_object_version_number
    ,p_interview_security            => p_interview_security
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_REC_TEAM_MEMBER'
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
  p_object_version_number  := l_object_version_number;
  p_rec_team_member_id     := l_rec_team_member_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_REC_TEAM_MEMBER;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_rec_team_member_id := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_REC_TEAM_MEMBER;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number  := null;
    p_rec_team_member_id := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_REC_TEAM_MEMBER;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_REC_TEAM_MEMBER >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_rec_team_member
  (p_validate                      in     boolean  default false
  ,p_rec_team_member_id            in     number
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_vacancy_id                    in     number   default hr_api.g_number
  ,p_party_id                      in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  ,p_job_id                        in     number   default hr_api.g_number
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_update_allowed                in     varchar2 default hr_api.g_varchar2
  ,p_delete_allowed                in     varchar2 default hr_api.g_varchar2
  ,p_interview_security             in     varchar2 default 'SELF'
  ) is
--
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'update_rec_team_member';
  l_object_version_number  number := p_object_version_number;
  l_start_date             date;
  l_end_date               date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_rec_team_member;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_start_date := trunc(p_start_date);
  l_end_date   := trunc(p_end_date);
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_REC_TEAM_MEMBERS_BK2.UPDATE_REC_TEAM_MEMBER_B
    (p_rec_team_member_id    =>   p_rec_team_member_id
    ,p_person_id             =>   p_person_id
    ,p_object_version_number =>   l_object_version_number
    ,p_job_id                =>   p_job_id
    ,p_start_date            =>   l_start_date
    ,p_end_date              =>   l_end_date
    ,p_update_allowed        =>   p_update_allowed
    ,p_delete_allowed        =>   p_delete_allowed
    ,p_interview_security     =>   p_interview_security
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REC_TEAM_MEMBER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_rtm_upd.upd
  (p_rec_team_member_id      => p_rec_team_member_id
  ,p_person_id               => p_person_id
  ,p_party_id                => p_party_id
  ,p_vacancy_id              => p_vacancy_id
  ,p_object_version_number   => l_object_version_number
  ,p_job_id                  => p_job_id
  ,p_update_allowed          => p_update_allowed
  ,p_delete_allowed          => p_delete_allowed
  ,p_start_date              => l_start_date
  ,p_end_date                => l_end_date
  ,p_interview_security       => p_interview_security
  );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_REC_TEAM_MEMBERS_BK2.UPDATE_REC_TEAM_MEMBER_A
    (p_rec_team_member_id     => p_rec_team_member_id
    ,p_person_id              => p_person_id
    ,p_object_version_number  => l_object_version_number
    ,p_job_id                 => p_job_id
    ,p_start_date             => l_start_date
    ,p_end_date               => l_end_date
    ,p_update_allowed         => p_update_allowed
    ,p_delete_allowed         => p_delete_allowed
    ,p_interview_security      => p_interview_security
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REC_TEAM_MEMBER'
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
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_REC_TEAM_MEMBER;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_REC_TEAM_MEMBER;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_REC_TEAM_MEMBER;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_REC_TEAM_MEMBER >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rec_team_member
  (p_validate                      in     boolean  default false
  ,p_rec_team_member_id             in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_rec_team_member';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_rec_team_member;
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_REC_TEAM_MEMBERS_BK3.DELETE_REC_TEAM_MEMBER_B
    (p_rec_team_member_id    => p_rec_team_member_id
    ,p_object_version_number => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REC_TEAM_MEMBER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_rtm_del.del
  (p_rec_team_member_id    =>     p_rec_team_member_id
  ,p_object_version_number =>     p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
     IRC_REC_TEAM_MEMBERS_BK3.DELETE_REC_TEAM_MEMBER_A
    (p_rec_team_member_id      => p_rec_team_member_id
    ,p_object_version_number   => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REC_TEAM_MEMBER'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_REC_TEAM_MEMBER;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_REC_TEAM_MEMBER;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_REC_TEAM_MEMBER;
--
end IRC_REC_TEAM_MEMBERS_API;

/
