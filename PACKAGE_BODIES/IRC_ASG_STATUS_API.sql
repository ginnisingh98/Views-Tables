--------------------------------------------------------
--  DDL for Package Body IRC_ASG_STATUS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_ASG_STATUS_API" as
/* $Header: iriasapi.pkb 120.3.12010000.6 2010/05/14 10:56:29 sethanga ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'IRC_ASG_STATUS_API.';


--
-- ----------------------------------------------------------------------------
-- |---------------------< dt_update_irc_asg_status >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure dt_update_irc_asg_status
  (
    p_validate                  in  boolean  default false
  , p_datetrack_mode            in  varchar2
  , p_assignment_id             in  number
  , p_assignment_status_type_id in  number
  , p_status_change_date        in  date
  , p_status_change_reason      in  varchar2 default hr_api.g_varchar2
  , p_assignment_status_id      out nocopy number
  , p_object_version_number     out nocopy number
  , p_status_change_comments    in  varchar2 default hr_api.g_varchar2
  ) IS
--
cursor csr_after_date is
    select assignment_status_id, object_Version_number
      from irc_assignment_statuses
      where assignment_id = p_assignment_id
      and trunc(status_change_date) > trunc(p_status_change_date);
--
cursor csr_get_status is
    select assignment_status_type_id
     from irc_assignment_statuses
     where assignment_id = p_assignment_id
       and status_change_date = (select max(status_change_date)
                                     from irc_assignment_statuses
                                     where assignment_id = p_assignment_id);
                                    -- and status_change_date < p_status_change_date);
                                    -- Modified for 5838786
l_assignment_status_type_id  irc_assignment_statuses.assignment_status_type_id%type;
l_status_change_comments     irc_assignment_statuses.status_change_comments%type;
l_proc    varchar2(72) := g_package||'dt_update_irc_asg_status';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  if p_datetrack_mode = 'UPDATE_OVERRIDE' then
    for c_rec in csr_after_date loop
      delete_irc_asg_status
        (p_assignment_status_id   => c_rec.assignment_status_id,
         p_object_version_number  => c_rec.object_version_number);
    end loop;
  end if;
--+
  l_assignment_status_type_id := hr_api.g_number;
--+
  open csr_get_status;
  fetch csr_get_Status into l_assignment_Status_Type_id;
  close csr_get_status;
--+
  if l_assignment_status_type_id <> p_assignment_status_type_id then
    if p_datetrack_mode ='CORRECTION'
       and trunc(sysdate) <> trunc(p_status_change_date) then
          update_irc_asg_status
               (p_validate                   => p_validate
               ,p_status_change_date         => p_status_change_date
               ,p_status_change_reason       => p_status_change_reason
               ,p_assignment_status_id       => p_assignment_status_id
               ,p_object_version_number      => p_object_version_number
               ,p_status_change_comments     => p_status_change_comments);
--+
    else
      if l_status_change_comments = hr_api.g_varchar2 then
        l_status_change_comments := null;
      end if;
      create_irc_asg_status
             (p_validate                   => p_validate
             ,p_assignment_id              => p_assignment_id
             ,p_assignment_status_type_id  => p_assignment_status_type_id
             ,p_status_change_date         => p_status_change_date
             ,p_status_change_reason       => p_status_change_reason
             ,p_assignment_status_id       => p_assignment_status_id
             ,p_object_version_number      => p_object_version_number
             ,p_status_change_comments     => l_status_change_comments);
--+
    end if;
  end if;
-- Handle exception and set the out parameters to null and reraise the exception
  hr_utility.set_location(' Leaving:'||l_proc, 20);
exception
  when others then
    p_assignment_status_id  := null;
    p_object_version_number := null;
    raise;
end;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< dt_delete_irc_asg_status >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure dt_delete_irc_asg_status
  ( p_validate                  in  boolean  default false
  , p_assignment_status_id      in  number
  , p_object_version_number     in  number
  , p_effective_date            in  date
  , p_datetrack_mode            in  varchar2) IS
--
l_assignment_id      irc_assignment_statuses.assignment_id%type;
cursor csr_ass is
    select assignment_id from irc_assignment_statuses
     where assignment_status_id = p_assignment_status_id;
--
cursor csr_after_date is
    select assignment_status_id, object_Version_number
      from irc_assignment_statuses
      where assignment_id = l_assignment_id
      and (trunc(status_change_date) > trunc(p_effective_date)
       or p_datetrack_mode <> 'FUTURE_CHANGE')
      and (trunc(status_change_date) >= trunc(p_effective_date)
       or p_datetrack_mode <> 'DELETE')
      and (p_datetrack_mode  <> 'DELETE_NEXT_CHANGE'
       or trunc(status_change_date) = (select trunc(min(status_change_date))
                                         from irc_assignment_statuses
                                        where assignment_id = l_assignment_id
                                          and status_change_date >
                                             p_effective_date));
--
begin
open csr_ass;
fetch csr_ass into l_assignment_id;
close csr_ass;
--
for c_rec in csr_after_date loop
delete_irc_asg_status
  (p_assignment_status_id   => c_rec.assignment_status_id,
   p_object_version_number  => c_rec.object_version_number);
end loop;
--
end;
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_irc_asg_status >---------------------------|
-- ---------------------------------------------------------------------------
--
procedure create_irc_asg_status
  ( p_validate                  in  boolean  default false
  , p_assignment_id             in  number
  , p_assignment_status_type_id in  number
  , p_status_change_date        in  date
  , p_status_change_reason      in  varchar2 default null
  , p_assignment_status_id      out nocopy number
  , p_object_version_number     out nocopy number
  , p_status_change_comments    in  varchar2 default null
  ) is
--
-- Declare cursors and local variables
--
  l_proc                varchar2(72) := g_package||'create_irc_asg_status';
  l_object_version_number     number;
  l_assignment_status_id      irc_assignment_statuses.assignment_id%type;
  l_status_change_date        irc_assignment_statuses.status_change_date%type;
  l_per_system_status         per_assignment_status_types.per_system_status%type;
  l_status_change_by             irc_assignment_statuses.status_change_by%type;
--
  cursor c_status_type is
    select per_system_status
    from per_assignment_status_types
    where assignment_status_type_id = p_assignment_status_type_id;
  cursor c_max_status_change_date is
    select max(status_change_date)
    from irc_assignment_statuses
    where assignment_id = p_assignment_id;
  PROCEDURE UPDATE_INTERVIEW(
       p_assignment_id in NUMBER
      ,p_assignment_status_type_id in NUMBER
  ) is
    iid_rec irc_interview_details%rowtype;
    l_return_status varchar2(30);
    L_NOTIFY_PARAMS VARCHAR2(4000);
    cursor cur_iid is
    select iid.*
      from irc_interview_details iid
           ,per_events pe
     where iid.event_id = pe.event_id
       and iid.status not in ('COMPLETED','CANCELLED')
       and sysdate between iid.start_date and iid.end_date
       and pe.assignment_id = p_assignment_id;
  begin
    for iid_rec in cur_iid
    loop
        IRC_INTERVIEW_DETAILS_SWI.UPDATE_IRC_INTERVIEW_DETAILS(
           P_STATUS                   => 'CANCELLED'
          ,P_FEEDBACK                 => IID_REC.FEEDBACK
          ,P_NOTES                    => IID_REC.NOTES
          ,P_NOTES_TO_CANDIDATE       => IID_REC.NOTES_TO_CANDIDATE
          ,P_CATEGORY                 => IID_REC.CATEGORY
          ,P_RESULT                   => IID_REC.RESULT
          ,P_IID_INFORMATION_CATEGORY => IID_REC.IID_INFORMATION_CATEGORY
          ,P_IID_INFORMATION1         => IID_REC.IID_INFORMATION1
          ,P_IID_INFORMATION2         => IID_REC.IID_INFORMATION2
          ,P_IID_INFORMATION3         => IID_REC.IID_INFORMATION3
          ,P_IID_INFORMATION4         => IID_REC.IID_INFORMATION4
          ,P_IID_INFORMATION5         => IID_REC.IID_INFORMATION5
          ,P_IID_INFORMATION6         => IID_REC.IID_INFORMATION6
          ,P_IID_INFORMATION7         => IID_REC.IID_INFORMATION7
          ,P_IID_INFORMATION8         => IID_REC.IID_INFORMATION8
          ,P_IID_INFORMATION9         => IID_REC.IID_INFORMATION9
          ,P_IID_INFORMATION10        => IID_REC.IID_INFORMATION10
          ,P_IID_INFORMATION11        => IID_REC.IID_INFORMATION11
          ,P_IID_INFORMATION12        => IID_REC.IID_INFORMATION12
          ,P_IID_INFORMATION13        => IID_REC.IID_INFORMATION13
          ,P_IID_INFORMATION14        => IID_REC.IID_INFORMATION14
          ,P_IID_INFORMATION15        => IID_REC.IID_INFORMATION15
          ,P_IID_INFORMATION16        => IID_REC.IID_INFORMATION16
          ,P_IID_INFORMATION17        => IID_REC.IID_INFORMATION17
          ,P_IID_INFORMATION18        => IID_REC.IID_INFORMATION18
          ,P_IID_INFORMATION19        => IID_REC.IID_INFORMATION19
          ,P_IID_INFORMATION20        => IID_REC.IID_INFORMATION20
          ,P_EVENT_ID                 => IID_REC.EVENT_ID
          ,P_INTERVIEW_DETAILS_ID     => IID_REC.INTERVIEW_DETAILS_ID
          ,P_START_DATE               => IID_REC.START_DATE
          ,P_END_DATE                 => IID_REC.END_DATE
          ,P_OBJECT_VERSION_NUMBER    => IID_REC.OBJECT_VERSION_NUMBER
          ,P_RETURN_STATUS            => l_return_status
	  );
       L_NOTIFY_PARAMS := 'IRC_INTVW_ID:'||IID_REC.INTERVIEW_DETAILS_ID||';IRC_INTVW_NEW_STATUS:'||'CANCELLED;IRC_INTVW_NEW_STATUS:'||IID_REC.STATUS;
       IRC_NOTIFICATION_HELPER_PKG.raiseNotifyEvent(
	  p_eventName          => 'INTW'
	 ,p_assignmentId       => p_assignment_id
	 ,p_personId           => NULL
	 ,params               => L_NOTIFY_PARAMS
       );
    end loop;
  exception
    when others then
      null;
  end UPDATE_INTERVIEW;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_irc_asg_status;
--
--
   open c_max_status_change_date;
    fetch c_max_status_change_date into l_status_change_date;
   close c_max_status_change_date;

  --
  -- Do NOT Truncate the time portion from status_change_date
  --
  -- if the date is the same as the system date, the sysdate
  -- including the time element is captured.

  if trunc(p_status_change_date) = trunc(sysdate) then
     l_status_change_date := sysdate;
  elsif( p_status_change_date = trunc(l_status_change_date)) then
     l_status_change_date := l_status_change_date + (1/1440);
  else
     l_status_change_date := p_status_change_date;
  end if;
  --
  if (p_assignment_status_type_id=7) then
  --
  l_status_change_by := get_status_change_by(l_status_change_date,p_assignment_id);
  --
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    irc_asg_status_bk1.create_irc_asg_status_b
    (
      p_assignment_id             => p_assignment_id
    , p_assignment_status_type_id => p_assignment_status_type_id
    , p_status_change_reason      => p_status_change_reason
    , p_status_change_date        => l_status_change_date
    , p_status_change_comments    => p_status_change_comments
    , p_status_change_by          => l_status_change_by
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_irc_asg_status'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  begin
    hr_utility.set_location('Entering block to call copy_candidate_details:'|| l_proc, 100);
    hr_utility.set_location('opening cursor c_status_type:'|| l_proc, 110);
    open c_status_type;
    fetch c_status_type into l_per_system_status;
    close c_status_type;
    hr_utility.set_location('value of the status_type: '||l_per_system_status||', '|| l_proc, 120);
    if l_per_system_status='ACCEPTED' then
      hr_utility.set_location('calling irc_utilities_pkg.copy_candidate_details :'|| l_proc, 130);
      irc_utilities_pkg.copy_candidate_details(p_assignment_id);
      hr_utility.set_location('After executing irc_utilities_pkg.copy_candidate_details :'|| l_proc, 140);
   end if;
   hr_utility.set_location('Leaving block to call copy_candidate_details:'|| l_proc, 150);
   exception
   when others then
     hr_utility.set_location(' Exception occured: ' || l_proc, 50);
     raise;
  end;
  --
  -- Process Logic
  --
  irc_ias_ins.ins
   (
     p_assignment_id                => p_assignment_id
   , p_assignment_status_type_id    => p_assignment_status_type_id
   , p_status_change_reason         => p_status_change_reason
   , p_assignment_status_id         => l_assignment_status_id
   , p_object_version_number        => l_object_version_number
   , p_status_change_date           => l_status_change_date
   , p_status_change_comments       => p_status_change_comments
   , p_status_change_by             => l_status_change_by
   );
  if(p_assignment_status_type_id = 1
     or p_assignment_status_type_id = 5
     or p_assignment_status_type_id = 6
     or p_assignment_status_type_id = 7) then
    UPDATE_INTERVIEW(p_assignment_id              => p_assignment_id
                  ,p_assignment_status_type_id    => p_assignment_status_type_id
                  );
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    irc_asg_status_bk1.create_irc_asg_status_a
    (
      p_assignment_id             => p_assignment_id
    , p_assignment_status_type_id => p_assignment_status_type_id
    , p_status_change_reason      => p_status_change_reason
    , p_assignment_status_id      => l_assignment_status_id
    , p_object_version_number     => l_object_version_number
    , p_status_change_date        => l_status_change_date
    , p_status_change_comments    => p_status_change_comments
    , p_status_change_by          => l_status_change_by
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_irc_asg_status'
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
  p_assignment_status_id         := l_assignment_status_id;
  p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_irc_asg_status;
    --
    -- Reset IN OUT parameters and set OUT paramters
    p_assignment_status_id   := null;
    p_object_version_number  := null;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_assignment_status_id   := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_irc_asg_status;
    -- Reset IN OUT parameters and set OUT paramters
    --
    p_assignment_status_id   := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_irc_asg_status;
--
-- ----------------------------------------------------------------------------
-- |-------------------< update_irc_asg_status >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_irc_asg_status
  (
    p_validate                  in  boolean  default false
  , p_status_change_reason      in  varchar2 default hr_api.g_varchar2
  , p_status_change_date        in  date
  , p_assignment_status_id      in  number
  , p_object_version_number  in out nocopy number
  , p_status_change_comments    in  varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_irc_asg_status';
  l_object_version_number  number       := p_object_version_number;
  l_status_change_date      irc_assignment_statuses.status_change_date%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_irc_asg_status;
  --
  -- Do NOT Truncate the time portion from status_change_date
  --
  -- if the date is the same as the system date, the sysdate
  -- including the time element is captured.

    if trunc(p_status_change_date) = trunc(sysdate) then
     l_status_change_date := sysdate;
       else
     l_status_change_date := p_status_change_date;
     end if;
--
  -- Call Before Process User Hook
  --
  begin
    irc_asg_status_bk2.update_irc_asg_status_b
    (
      p_status_change_reason      => p_status_change_reason
    , p_status_change_date        => l_status_change_date
    , p_assignment_status_id      => p_assignment_status_id
    , p_object_version_number     => l_object_version_number
    , p_status_change_comments    => p_status_change_comments
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_irc_asg_status'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_ias_upd.upd
    (
     p_assignment_status_id        =>  p_assignment_status_id
    ,p_object_version_number       =>  l_object_version_number
    ,p_status_change_reason        =>  p_status_change_reason
    ,p_status_change_date          =>  l_status_change_date
    ,p_status_change_comments      =>  p_status_change_comments
    );
  --
  --  Call After Process User Hook
  --
  begin
   irc_asg_status_bk2.update_irc_asg_status_a
     (
       p_status_change_reason   => p_status_change_reason
     , p_status_change_date     => l_status_change_date
     , p_assignment_status_id   => p_assignment_status_id
     , p_object_version_number  => l_object_version_number
     , p_status_change_comments => p_status_change_comments
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_irc_asg_status'
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
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_irc_asg_status;
    --
    -- Reset IN OUT parameters and set OUT paramters
    p_object_version_number := l_object_version_number;
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_irc_asg_status;
    -- Reset IN OUT parameters and set OUT paramters
    p_object_version_number := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_irc_asg_status;
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_irc_asg_status >------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_irc_asg_status
  (
    p_validate                  in  boolean  default false
  , p_assignment_status_id      in  number
  , p_object_version_number     in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_irc_asg_status';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_irc_asg_status;
  --
  -- Call Before Process User Hook
  --
  begin
    irc_asg_status_bk3.delete_irc_asg_status_b
      (
        p_assignment_status_id      => p_assignment_status_id
      , p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_irc_asg_status'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_ias_del.del
    (p_assignment_status_id             => p_assignment_status_id
    ,p_object_version_number            => p_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    irc_asg_status_bk3.delete_irc_asg_status_a
      (
        p_assignment_status_id      => p_assignment_status_id
      , p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_irc_asg_status'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_irc_asg_status;
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
    rollback to delete_irc_asg_status;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_irc_asg_status;
--
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_status_change_by >--------------------|
-- ----------------------------------------------------------------------------
--
--
function get_status_change_by
  ( P_EFFECTIVE_DATE               IN   date
   ,P_ASSIGNMENT_ID      IN   number
  ) RETURN VARCHAR2 Is
  l_proc                           varchar2(72) := g_package||'get_status_change_by';
  l_manager_terminates varchar2(1);
  l_status_change_by varchar2(240);
  l_user_id varchar2(250);
  --
  CURSOR csr_applicant_userid
    (p_assignment_id            IN     per_all_assignments_f.assignment_id%TYPE
    ,p_effective_date           IN     DATE
    )
  IS
  select user_id
  from per_all_assignments_f paf, fnd_user usr, per_all_people_f ppf,
  per_all_people_f linkppf
  where p_effective_date between paf.effective_start_date and
  paf.effective_end_date
  and p_effective_date between usr.start_date and
  nvl(usr.end_date,p_effective_date)
  and p_effective_date between ppf.effective_start_date and
  ppf.effective_end_date
  and p_effective_date between linkppf.effective_start_date and
  linkppf.effective_end_date
  and usr.employee_id=linkppf.person_id
  and ppf.party_id = linkppf.party_id
  and ppf.person_id = paf.person_id
  and paf.assignment_id= p_assignment_id
  and usr.user_id = fnd_global.user_id;
  --
begin
  --
  hr_utility.set_location(' Entering: '|| l_proc, 10);
  --
  OPEN csr_applicant_userid
       (p_assignment_id                => p_assignment_id
       ,p_effective_date               => trunc(p_effective_date)
       );
  FETCH csr_applicant_userid INTO l_user_id;
  IF csr_applicant_userid%NOTFOUND
  THEN
    l_manager_terminates:='Y';
  END IF;
  CLOSE csr_applicant_userid;
  --
  hr_utility.set_location('l_user_id: '||l_user_id,20);
  hr_utility.set_location('g_user_id: '||fnd_global.user_id,30);
  --
  if l_user_id=fnd_global.user_id then
    l_manager_terminates:='N';
  else
    l_manager_terminates:='Y';
  end if;
  --
  if fnd_profile.value('IRC_AGENCY_NAME') is not null then
  --
    l_status_change_by := 'AGENCY';
  --
  elsif l_manager_terminates = 'Y' then
    l_status_change_by := 'MANAGER';
  else
    l_status_change_by := 'CANDIDATE';
  end if;
  --
  hr_utility.set_location(' l_status_change_by: '||l_status_change_by,40);
  hr_utility.set_location(' Leaving: '|| l_proc, 50);
  --
  RETURN l_status_change_by;
end get_status_change_by;
--
end IRC_ASG_STATUS_API;

/
