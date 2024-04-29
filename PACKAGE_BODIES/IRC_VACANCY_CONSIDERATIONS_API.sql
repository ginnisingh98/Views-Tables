--------------------------------------------------------
--  DDL for Package Body IRC_VACANCY_CONSIDERATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_VACANCY_CONSIDERATIONS_API" as
/* $Header: irivcapi.pkb 120.2.12010000.4 2009/10/29 11:43:05 sethanga ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  IRC_VACANCY_CONSIDERATIONS_API.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< GET_EMAIL_MESSAGE_BODY >--------------------------|
-- ----------------------------------------------------------------------------
--
function get_email_message_body
  (p_person_id                     in     number
  ,p_vacancy_id                    in     number
  ,p_effective_date                in     date
  )
return varchar2 is
  --
  -- Declare cursors and local variables
  --
  cursor c_potential_applicant_details is
    select first_name
      from per_all_people_f
     where  person_id = p_person_id;
   --
  cursor c_recruiter_details is
    select ppl.full_name
         , pj.name  job_name
      from per_all_people_f ppl
         , per_all_assignments_f pasg
         , per_jobs pj
     where ppl.person_id = fnd_global.employee_id
       and ppl.person_id = pasg.person_id
       and pasg.primary_flag = 'Y'
       and pasg.job_id = pj.job_id(+)
       and p_effective_date
           between ppl.effective_start_date
               and ppl.effective_end_date
       and p_effective_date
           between pasg.effective_start_date
               and pasg.effective_end_date;
   --
  cursor c_posting_details is
    select pctl.brief_description
         , pctl.job_title
         , pctl.posting_content_id
         , pctl.name
      from per_recruitment_activity_for raf
         , per_recruitment_activities ra
         , irc_posting_contents_tl pctl
     where raf.vacancy_id = p_vacancy_id
       and raf.recruitment_activity_id = ra.recruitment_activity_id
       and ra.posting_content_id = pctl.posting_content_id
       and userenv('LANG') = pctl.language
       and rownum = 1;
  --
  l_message_intro        VARCHAR2(2000) ;
  l_message_conc         VARCHAR2(2000) ;

  l_base_url             VARCHAR2(250);
  l_whole_url            VARCHAR2(2000);
  l_appl_first_name      VARCHAR2(150);
  l_recr_full_name       VARCHAR2(150);
  l_recr_job_name        VARCHAR2(150);
  l_job_title            irc_posting_contents_tl.job_title%type;
  l_posting_content_id   irc_posting_contents_tl.posting_content_id%type;
  l_posting_content_name irc_posting_contents_tl.name%type;
  l_name                 VARCHAR2(240);
  l_brief_description_clob   irc_posting_contents_tl.brief_description%type;
  l_brief_description_v2  varchar2(960) default '';
  l_user_name             VARCHAR2(240) ;
  l_amount                BINARY_INTEGER  default 240;

  l_whole_message         VARCHAR2(32000);
  l_proc                  varchar2(72) := g_package||
                                           'get_email_message_body';
  l_apps_fwk_agent        VARCHAR2(2000);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Obtain all the data for use in the message.
  --
  --Commented for Bug 6004149
  --l_base_url := fnd_profile.value('IRC_JOB_NOTIFICATION_URL');

  if (irc_utilities_pkg.is_internal_person(p_person_id,p_effective_date)='TRUE') then
    l_apps_fwk_agent := rtrim(fnd_profile.value_specific('APPS_FRAMEWORK_AGENT',0,0,0,0,0)
                          ||fnd_profile.value('ICX_PREFIX'),'/');
    l_base_url := irc_seeker_vac_matching_pkg.get_job_notification_function('Y');
  else
    l_apps_fwk_agent := rtrim(nvl(fnd_profile.value('IRC_FRAMEWORK_AGENT'),fnd_profile.value('APPS_FRAMEWORK_AGENT'))
                          ||fnd_profile.value('ICX_PREFIX'),'/');
    l_base_url := irc_seeker_vac_matching_pkg.get_job_notification_function('N');
  end if;
  --
  if l_base_url is null then
    fnd_message.set_name('PER','IRC_412056_NO_EMAIL_JOB_URL');
    fnd_message.raise_error;
  end if;
  --
  open c_potential_applicant_details ;
  fetch c_potential_applicant_details into l_appl_first_name;
  close c_potential_applicant_details;
  --
  open c_recruiter_details ;
  fetch c_recruiter_details into l_recr_full_name, l_recr_job_name ;
  close c_recruiter_details ;
  -- Get the advert details (inc a clob), convert to a v2 for workflow to accept.
  open c_posting_details ;
  fetch c_posting_details into l_brief_description_clob, l_job_title, l_posting_content_id, l_posting_content_name ;
  close c_posting_details;
  --
  -- Incase the job_title is null, Display posting name.
  if ( l_job_title is null ) then
     l_name := l_posting_content_name;
  else
     l_name := l_job_title;
  end if;
  --
  l_whole_url:= '<a HREF="'
               ||   l_apps_fwk_agent
               ||   '/OA_HTML/OA.jsp?OAFunc='
               ||   l_base_url
               ||   '&p_svid='||to_char(p_vacancy_id)
               ||   '&p_spid='||to_char(l_posting_content_id)
               ||   '">'
               ||   l_name
               ||   '</a>';

  -- Convert the clob to a v2 so that wf can display it.
  IF (dbms_lob.getlength(l_brief_description_clob) > 0) THEN
      dbms_lob.read( l_brief_description_clob
                   , l_amount
                   , 1
                   , l_brief_description_v2
                   );
  ELSE
    l_brief_description_v2 := '';
  END IF;

  l_user_name := irc_notification_helper_pkg.get_job_seekers_role
                (p_person_id => p_person_id);

  -- Build the message up.

  fnd_message.set_name('PER','IRC_PURSUE_SEEKER_INTRO');
  fnd_message.set_token('SEEKER_FIRST_NAME',l_appl_first_name );
  fnd_message.set_token('VAC_JOB_TITLE', l_name);
  l_message_intro := fnd_message.get;

  fnd_message.set_name('PER','IRC_PURSUE_SEEKER_CONC');
  fnd_message.set_token('URL', l_whole_url);
  fnd_message.set_token('SENDER_FULL_NAME', l_recr_full_name);
  fnd_message.set_token('SENDER_JOB_TITLE', l_recr_job_name);
  l_message_conc := fnd_message.get;

  l_whole_message := l_message_intro
                  || '<br>' || l_brief_description_v2||'<br><br>'
                  || l_message_conc ;

  RETURN l_whole_message;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end get_email_message_body;
--
-- ----------------------------------------------------------------------------
-- |----------------------< GET_TEXT_MESSAGE_BODY >--------------------------|
-- ----------------------------------------------------------------------------
function get_text_message_body
  (p_person_id                     in     number
  ,p_vacancy_id                    in     number
  ,p_effective_date                in     date
  )
return varchar2 is
  --
  -- Declare cursors and local variables
  --
  cursor c_potential_applicant_details is
    select first_name
      from per_all_people_f
     where  person_id = p_person_id;
   --
  cursor c_recruiter_details is
    select ppl.full_name
         , pj.name  job_name
      from per_all_people_f ppl
         , per_all_assignments_f pasg
         , per_jobs pj
     where ppl.person_id = fnd_global.employee_id
       and ppl.person_id = pasg.person_id
       and pasg.primary_flag = 'Y'
       and pasg.job_id = pj.job_id(+)
       and p_effective_date
           between ppl.effective_start_date
               and ppl.effective_end_date
       and p_effective_date
           between pasg.effective_start_date
               and pasg.effective_end_date;
   --
  cursor c_posting_details is
    select pctl.brief_description
         , pctl.job_title
         , pctl.posting_content_id
         , pctl.name
      from per_recruitment_activity_for raf
         , per_recruitment_activities ra
         , irc_posting_contents_tl pctl
     where raf.vacancy_id = p_vacancy_id
       and raf.recruitment_activity_id = ra.recruitment_activity_id
       and ra.posting_content_id = pctl.posting_content_id
       and userenv('LANG') = pctl.language
       and rownum = 1;
  --
  l_message_intro        VARCHAR2(2000) ;
  l_message_conc         VARCHAR2(2000) ;

  l_base_url             VARCHAR2(250);
  l_whole_url            VARCHAR2(2000);
  l_appl_first_name      VARCHAR2(150);
  l_recr_full_name       VARCHAR2(150);
  l_recr_job_name        VARCHAR2(150);
  l_job_title            irc_posting_contents_tl.job_title%type;
  l_posting_content_id   irc_posting_contents_tl.posting_content_id%type;
  l_posting_content_name irc_posting_contents_tl.name%type;
  l_name                 VARCHAR2(240);
  l_brief_description_clob   irc_posting_contents_tl.brief_description%type;
  l_brief_description_v2  varchar2(960) default '';
  l_user_name             VARCHAR2(240) ;
  l_amount                BINARY_INTEGER  default 240;

  l_whole_message         VARCHAR2(32000);
  l_proc                  varchar2(72) := g_package||
                                           'get_text_message_body';
  l_apps_fwk_agent        VARCHAR2(2000);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Obtain all the data for use in the message.
  --
  --Commented for Bug 6004149
  --l_base_url := fnd_profile.value('IRC_JOB_NOTIFICATION_URL');
  if (irc_utilities_pkg.is_internal_person(p_person_id,p_effective_date)='TRUE') then
    l_apps_fwk_agent := rtrim(fnd_profile.value_specific('APPS_FRAMEWORK_AGENT',0,0,0,0,0)
                          ||fnd_profile.value('ICX_PREFIX'),'/');
    l_base_url := irc_seeker_vac_matching_pkg.get_job_notification_function('Y');
  else
    l_apps_fwk_agent := rtrim(nvl(fnd_profile.value('IRC_FRAMEWORK_AGENT'),fnd_profile.value('APPS_FRAMEWORK_AGENT'))
                          ||fnd_profile.value('ICX_PREFIX'),'/');
    l_base_url := irc_seeker_vac_matching_pkg.get_job_notification_function('N');
  end if;
  --
  if l_base_url is null then
    fnd_message.set_name('PER','IRC_412056_NO_EMAIL_JOB_URL');
    fnd_message.raise_error;
  end if;
  --
  open c_potential_applicant_details ;
  fetch c_potential_applicant_details into l_appl_first_name;
  close c_potential_applicant_details;
  --
  open c_recruiter_details ;
  fetch c_recruiter_details into l_recr_full_name, l_recr_job_name ;
  close c_recruiter_details ;
  -- Get the advert details (inc a clob), convert to a v2 for workflow to accept.
  open c_posting_details ;
  fetch c_posting_details into l_brief_description_clob, l_job_title, l_posting_content_id, l_posting_content_name ;
  close c_posting_details;
  --
  -- Incase the job_title is null, Display posting name.
  if ( l_job_title is null ) then
     l_name := l_posting_content_name;
  else
     l_name := l_job_title;
  end if;
  --
  l_whole_url:=    l_apps_fwk_agent
               ||   '/OA_HTML/OA.jsp?OAFunc='
               ||   l_base_url
               ||   '&p_svid='||to_char(p_vacancy_id)
               ||   '&p_spid='||to_char(l_posting_content_id);

  -- Convert the clob to a v2 so that wf can display it.
  IF (dbms_lob.getlength(l_brief_description_clob) > 0) THEN
      dbms_lob.read( l_brief_description_clob
                   , l_amount
                   , 1
                   , l_brief_description_v2
                   );
  ELSE
    l_brief_description_v2 := '';
  END IF;

  l_user_name := irc_notification_helper_pkg.get_job_seekers_role
                 (p_person_id => p_person_id);

  -- Build the message up.

  fnd_message.set_name('PER','IRC_PURSUE_SEEKER_INTRO_TEXT');
  fnd_message.set_token('SEEKER_FIRST_NAME',l_appl_first_name );
  fnd_message.set_token('VAC_JOB_TITLE', l_name);
  l_message_intro := fnd_message.get;

  fnd_message.set_name('PER','IRC_PURSUE_SEEKER_CONC_TEXT');
  fnd_message.set_token('URL', l_whole_url);
  fnd_message.set_token('SENDER_FULL_NAME', l_recr_full_name);
  fnd_message.set_token('SENDER_JOB_TITLE', l_recr_job_name);
  l_message_conc := fnd_message.get;

  l_whole_message := l_message_intro
                  || '\n' || l_brief_description_v2||'\n\n'
                  || l_message_conc ;

  RETURN l_whole_message;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end get_text_message_body;

-- ----------------------------------------------------------------------------
-- |--------------------------< NOTIFY_SEEKER_IF_REQUIRED >-------------------|
-- ----------------------------------------------------------------------------
-- Comment
--   This procedure will send an email to a job seeker under certain
--   circumstances.
procedure notify_seeker_if_required
  (p_person_id                     in     number
  ,p_vacancy_id                    in     number
  ,p_consideration_status          in     varchar2
  ,p_effective_date                in     date
  ,p_validate_only                 in     boolean)
is
 --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||
                                            'notify_seeker_if_required';
  l_message_subject      VARCHAR2(240)
            DEFAULT fnd_message.get_string('PER','IRC_PURSUE_SEEKER_SUBJECT');
  --
  l_id                   NUMBER;
  l_rec_found varchar2(1);
  l_user_role varchar2(240);
  --
  cursor c_posting_details is
    select null
      from per_recruitment_activity_for raf
         , per_recruitment_activities ra
         , irc_posting_contents_tl pctl
     where raf.vacancy_id = p_vacancy_id
       and raf.recruitment_activity_id = ra.recruitment_activity_id
       and ra.posting_content_id = pctl.posting_content_id
       and userenv('LANG') = pctl.language
       and rownum = 1;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- An email only need to be sent under certain conditions
  --
  if p_consideration_status = 'PURSUE'  and p_validate_only = FALSE then
    --
    open c_posting_details;
    fetch c_posting_details into l_rec_found;
    if(c_posting_details%notfound)
    then
      close c_posting_details;
      fnd_message.set_name('PER','IRC_412148_VAC_NO_POSTING');
      fnd_message.raise_error;
    end if;
    close c_posting_details;
    l_user_role := irc_notification_helper_pkg.get_job_seekers_role(p_person_id => p_person_id);
    if(l_user_role is not null ) then
      l_id := irc_notification_helper_pkg.send_notification
                    ( p_person_id  => p_person_id
                    , p_subject   => l_message_subject
                    , p_html_body => get_email_message_body
                                    ( p_person_id      => p_person_id
                                    , p_vacancy_id     => p_vacancy_id
                                    , p_effective_date => p_effective_date)
                    , p_text_body => get_text_message_body
                                        ( p_person_id      => p_person_id
                                        , p_vacancy_id     => p_vacancy_id
                                        , p_effective_date => p_effective_date)
                    );
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
exception
when others then
  -- Let the calling code handle any errors
  raise;
end notify_seeker_if_required;
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_VACANCY_CONSIDERATION >----------------|
-- ----------------------------------------------------------------------------
--
procedure create_vacancy_consideration
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_vacancy_id                    in     number
  ,p_consideration_status          in     varchar2 default 'CONSIDER'
  ,p_vacancy_consideration_id      out nocopy number
  ,p_object_version_number         out nocopy    number
  ,p_effective_date                in     date
  )is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc                    varchar2(72) := g_package||
                                            'create_vacancy_consideration';
  l_vacancy_consideration_id number;
  l_object_version_number   number;
  l_effective_date          date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_vacancy_consideration;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_VACANCY_CONSIDERATIONS_BK1.CREATE_VACANCY_CONSIDERATION_B
    (
     p_person_id            =>   p_person_id
    ,p_vacancy_id           =>   p_vacancy_id
    ,p_consideration_status =>   p_consideration_status
    ,p_effective_date       =>   l_effective_date
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_VACANCY_CONSIDERATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_ivc_ins.ins
  (
   p_person_id                      => p_person_id
  ,p_vacancy_id                     => p_vacancy_id
  ,p_consideration_status           => p_consideration_status
  ,p_vacancy_consideration_id       => l_vacancy_consideration_id
  ,p_object_version_number          => l_object_version_number
  ,p_effective_date                 => l_effective_date
  );
  --
  notify_seeker_if_required
  (p_person_id                      => p_person_id
  ,p_vacancy_id                     => p_vacancy_id
  ,p_consideration_status           => p_consideration_status
  ,p_effective_date                 => l_effective_date
  ,p_validate_only                  => p_validate
  );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_VACANCY_CONSIDERATIONS_BK1.CREATE_VACANCY_CONSIDERATION_A
    (p_vacancy_consideration_id     => l_vacancy_consideration_id
    ,p_person_id                    => p_person_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_consideration_status         => p_consideration_status
    ,p_object_version_number        => l_object_version_number
    ,p_effective_date               => l_effective_date
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_VACANCY_CONSIDERATION'
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
  p_vacancy_consideration_id := l_vacancy_consideration_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_VACANCY_CONSIDERATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_vacancy_consideration_id := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_VACANCY_CONSIDERATION;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number := null;
    p_vacancy_consideration_id := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_VACANCY_CONSIDERATION;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_VACANCY_CONSIDERATION >----------------|
-- ----------------------------------------------------------------------------
--
procedure update_vacancy_consideration
  (p_validate                      in     boolean  default false
  ,p_vacancy_consideration_id      in     number
  ,p_party_id                      in     number   default hr_api.g_number
  ,p_consideration_status          in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_effective_date                in     date
  ) is
--
  --
  -- Declare cursors and local variables
  --
  l_proc              varchar2(72) := g_package||
                                           'update_vacancy_consideration';
  l_object_version_number  number := p_object_version_number;
  l_effective_date    date;
  l_person_id         number;
  l_vacancy_id        number;
  cursor csr_person_vac is
      Select person_id, vacancy_id
        from irc_vacancy_considerations
       where vacancy_consideration_id = p_vacancy_consideration_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_vacancy_consideration;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_VACANCY_CONSIDERATIONS_BK2.UPDATE_VACANCY_CONSIDERATION_B
    (
     p_vacancy_consideration_id =>   p_vacancy_consideration_id
    ,p_party_id                 =>   p_party_id
    ,p_consideration_status     =>   p_consideration_status
    ,p_object_version_number    =>   l_object_version_number
    ,p_effective_date           =>   l_effective_date
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_VACANCY_CONSIDERATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_ivc_upd.upd
  (
   p_vacancy_consideration_id => p_vacancy_consideration_id
  ,p_party_id                 => p_party_id
  ,p_consideration_status     => p_consideration_status
  ,p_object_version_number    => l_object_version_number
  ,p_effective_date           => l_effective_date
  );
  --
  --
  open csr_person_vac;
  fetch csr_person_vac into l_person_id, l_vacancy_id;
  close csr_person_vac;
  notify_seeker_if_required
  (p_person_id                      => l_person_id
  ,p_vacancy_id                     => l_vacancy_id
  ,p_consideration_status           => p_consideration_status
  ,p_effective_date                 => l_effective_date
  ,p_validate_only                  => p_validate
  );
  -- Call After Process User Hook
  --
  begin
    IRC_VACANCY_CONSIDERATIONS_BK2.UPDATE_VACANCY_CONSIDERATION_A
    (p_vacancy_consideration_id => p_vacancy_consideration_id
    ,p_party_id                 => p_party_id
    ,p_consideration_status     => p_consideration_status
    ,p_object_version_number    => l_object_version_number
    ,p_effective_date           => l_effective_date
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_VACANCY_CONSIDERATION'
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
    rollback to UPDATE_VACANCY_CONSIDERATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_VACANCY_CONSIDERATION;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_VACANCY_CONSIDERATION;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_VACANCY_CONSIDERATION >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_vacancy_consideration
  (p_validate                      in     boolean  default false
  ,p_vacancy_consideration_id      in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||
                                        'delete_vacancy_consideration';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_vacancy_consideration;
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_VACANCY_CONSIDERATIONS_BK3.DELETE_VACANCY_CONSIDERATION_B
    (p_vacancy_consideration_id      => p_vacancy_consideration_id
    ,p_object_version_number         => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_VACANCY_CONSIDERATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_ivc_del.del
  (p_vacancy_consideration_id      => p_vacancy_consideration_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
     IRC_VACANCY_CONSIDERATIONS_BK3.DELETE_VACANCY_CONSIDERATION_A
    (
     p_vacancy_consideration_id  => p_vacancy_consideration_id
    ,p_object_version_number     => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_VACANCY_CONSIDERATION'
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
    rollback to DELETE_VACANCY_CONSIDERATION;
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
    rollback to DELETE_VACANCY_CONSIDERATION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_VACANCY_CONSIDERATION;
--
end IRC_VACANCY_CONSIDERATIONS_API;

/
