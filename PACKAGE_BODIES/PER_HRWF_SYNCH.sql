--------------------------------------------------------
--  DDL for Package Body PER_HRWF_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HRWF_SYNCH" AS
/* $Header: perhrwfs.pkb 120.4.12010000.2 2008/11/11 09:27:14 skura ship $ */
  --
  g_package varchar2(30) := 'per_hrwf_synch.';
  g_count   number := 0;
  --
  --
  -- ----------------------------------------------------------------------------
  -- |--------------------------< chk_date_status >-----------------------------|
  -- ----------------------------------------------------------------------------
  function chk_date_status
    (p_start_date      in date,
     p_end_date        in date) return varchar2 is
    --
    l_proc             varchar2(80) := g_package||'chk_date_status';
    l_status           varchar2(10);
    --
  begin
    --
    -- This routine is used to check where start date and end date fall
    -- in the time frames of CURRENT, FUTURE or PAST.
    --
    -- If sysdate between p_start_date and p_end_date then
    --   return 'CURRENT'
    -- elsif sysdate < p_start_date then
    --   return 'FUTURE'
    -- elsif sysdate > p_start_date then
    --   return 'PAST'
    -- end if;
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    -- bug 4635241 Modified the following If condition to consider the Past date as well
    --
    if sysdate between p_start_date and p_end_date
       or (p_start_date < sysdate and p_end_date < sysdate) then
      --
      l_status := 'CURRENT';
      --
    elsif sysdate < p_start_date then
      --
      l_status := 'FUTURE';
      --
    elsif sysdate > p_start_date then
      --
      l_status := 'PAST';
      --
    end if;
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    return(l_status);
    --
  end chk_date_status;
  --
  --
  --
  -- ----------------------------------------------------------------------------
  -- |------------------------------< call_back >--------------------------------|
  -- ----------------------------------------------------------------------------
  procedure call_back(p_parameters in wf_parameter_list_t default null) is
    --
    l_counter                   number;
    l_proc                      varchar2(80) := g_package||'call_back';
    l_entity                    varchar2(10);
    l_person_rec                per_all_people_f%rowtype;
    l_assignment_rec            per_all_assignments_f%rowtype;
    l_person_id                 number;
    l_assignment_id             number;
    l_person_id_canonical       varchar2(20);
    l_assignment_id_canonical   varchar2(20);
    l_start_date                date;
    l_end_date                  date;
    l_start_date_canonical      varchar2(30);
    l_end_date_canonical        varchar2(30);
    -- 3297591 these not really needed here
    l_person_party_id           number;
    l_person_party_id_canonical varchar2(20);
    --
    --per_all_people_f%rowtype cursor.
    --
    cursor l_person_cur is
           select *
           from per_all_people_f
           where person_id                   = l_person_id
           and   trunc(effective_start_date) = l_start_date
           and   trunc(effective_end_date)   = l_end_date;
    --
    --per_all_assignments_f%rowtype cursor.
    --
    cursor l_assignment_cur is
           select *
           from per_all_assignments_f
           where assignment_id               = l_assignment_id
           and   trunc(effective_start_date) = l_start_date
           and   trunc(effective_end_date)   = l_end_date;
    --
  begin
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    -- Check that the records exist in the parameter list.
    -- if p_parametrs.count = 0 then .... return .....end if
    --
    if p_parameters.count = 0 then
      --
      hr_utility.set_location('Not a single parameter exists '||l_proc,15);
      hr_utility.set_location('Leaving '||l_proc,16);
      return;
      --
    end if;
    --
    --get the attribute CONTEXT value from the parameter list.
    --
    hr_utility.set_location('Start assigning values from param_list '||l_proc,25);

    l_entity := wf_event.getvalueforparameter(
                            p_name          => 'CONTEXT',
                            p_parameterlist => p_parameters);
    --
    l_start_date_canonical := wf_event.getvalueforparameter(
                            p_name          => 'STARTDATE',
                            p_parameterlist => p_parameters);

    l_end_date_canonical := wf_event.getvalueforparameter(
                            p_name          => 'ENDDATE',
                            p_parameterlist => p_parameters);

    l_start_date := FND_DATE.canonical_to_date(l_start_date_canonical);
    l_end_date   := FND_DATE.canonical_to_date(l_end_date_canonical);
    hr_utility.set_location('End assign Values from param_list '||l_proc,30);
    --
    if l_entity = 'PERSON' then
    --
      hr_utility.set_location('Person Record '||l_proc,35);
      -- get attribute values of peson from parameter list.
      --
      l_person_id_canonical := wf_event.getvalueforparameter(
                               p_name          => 'PERSONID',
                               p_parameterlist => p_parameters);
      l_person_id  := FND_NUMBER.canonical_to_number(l_person_id_canonical);
      --
      -- 3297591
      --/*
      l_person_party_id_canonical := wf_event.getvalueforparameter(
                                     p_name          => 'PERSONPARTYID',
                                     p_parameterlist => p_parameters);
      l_person_party_id := FND_NUMBER.canonical_to_number(l_person_party_id_canonical);
      --*/
      --
      -- get the appropriate person record.
      --
      open l_person_cur;
      fetch l_person_cur into l_person_rec;
      close l_person_cur;
      --
      hr_utility.set_location('Before call to person routine '||l_proc,40);
      --
      PER_HRWF_SYNCH.per_per_wf(p_rec     => l_person_rec,
                                p_action  => null);
      hr_utility.set_location('After call to person routine '||l_proc,45);
    --
    end if;    -- l_entity = 'PERSON'
    --
    --
    if l_entity = 'POSITION' then
    --
      hr_utility.set_location('Position Record '||l_proc,35);
      l_assignment_id_canonical := wf_event.getvalueforparameter(
                                   p_name          => 'ASSIGNMENTID',
                                   p_parameterlist => p_parameters);
                                   --
      l_assignment_id  := FND_NUMBER.canonical_to_number(l_assignment_id_canonical);
      --
      -- get the appropriate assignment record
      --
      open l_assignment_cur;
      fetch l_assignment_cur into l_assignment_rec;
      close l_assignment_cur;
      hr_utility.set_location('Before call to Assignment routine '||l_proc,35);
      --
      --call the routine
      --
      PER_HRWF_SYNCH.per_asg_wf(p_rec    => l_assignment_rec,
                                p_action => null);
      hr_utility.set_location('After call to Assignment routine '||l_proc,35);
    --
    end if;  --l_entity = 'POSITION'
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    --
  end call_back;
  --
  --
  --
  -- ----------------------------------------------------------------------------
  -- |-----------------------------< per_per_wf >-------------------------------|
  -- ----------------------------------------------------------------------------
  --
  --
  procedure per_per_wf(
        p_rec          in per_all_people_f%rowtype,
        p_action       in varchar2) is
  --
  -- local variables
  --
  l_proc                      varchar2(80) := g_package||'per_per_wf';
  l_date_chk	              varchar2(10);
  l_emp_num_canonical         varchar2(30);
  l_start_date_canonical      varchar2(30);
  l_end_date_canonical        varchar2(30);
  l_person_id_canonical       varchar2(20);
  l_person_party_id_canonical varchar2(20);  -- 3297591
  l_parameters                wf_parameter_list_t;
  --
  --
  l_employee_type per_person_types.user_person_type%type;
  l_birth_date      varchar2(30);
  l_hire_date       varchar2(30);
  l_date_created    varchar2(30);
  l_update_date     varchar2(30);
  l_updated_by      varchar2(20);
  l_created_by      varchar2(20);
  -- l_user_name     wf_local_roles.name%type;
  -- l_user_name       varchar2(60);  -- 3297591
  l_user_name     fnd_user.user_name%type; -- 5340008
  l_expiration_date varchar2(30);
  --l_display_name  wf_local_roles.display_name%TYPE;;
  l_display_name    varchar2(310); -- 3297591,4149356
  l_update varchar(1) default 'Y'; -- Bug 4597033
  --
  -- cursors
  --
  cursor role_exists(p_person_id in number) is
    select name
    from   wf_local_roles
    where  orig_system    = 'PER'
    and    orig_system_id = p_person_id
    and rownum = 1; -- This extra WHERE condition is added as per the request of "tpapired"
-- fix for bug 7455694
    l_description  wf_local_roles.description%TYPE;
     cursor role_description(p_person_id in number) is
    select description
    from   wf_local_roles
    where  orig_system    = 'PER'
    and    orig_system_id = p_person_id
    and rownum = 1;

  --
  Begin
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    -- check for the current employee flag
    -- if current employee flag <> 'Y' then
    --   return
    -- end if
    --
    -- the following if condition was changed to include a check for
    -- contingent worker to be taken care.
    --
    -- Bug fix 3883910
    -- If condition to check whether the person is an employee or cwk
    -- is removed, as wf_local_roles as to be updated for all persons.

   /* if (nvl(p_rec.current_employee_flag,'N') <>'Y'
        and
	nvl(p_rec.current_npw_flag,'N') <>'Y') then
    --
      hr_utility.set_location('Not a current employee '||l_proc,15);
      hr_utility.set_location('Leaving ... '||l_proc,15);
      return;
    --
    end if;*/
    --
    l_person_id_canonical  := FND_NUMBER.number_to_canonical(p_rec.person_id);
    l_person_party_id_canonical := FND_NUMBER.number_to_canonical(p_rec.party_id); -- 3297591
    l_start_date_canonical := FND_DATE.date_to_canonical(p_rec.effective_start_date);
    l_end_date_canonical   := FND_DATE.date_to_canonical(p_rec.effective_end_date);
    -- need to set up display name here - 3297591...
    l_display_name := HR_PERSON_NAME.get_person_name(p_rec.person_id,
                                                     p_rec.effective_start_date,
                                                     null); -- 3297591
    -- Check if this is DELETE
    --
    if nvl(p_action,'NO_DELETE') = 'DELETE' then
      --
      hr_utility.set_location('Delete Person '||l_proc,20);
      wf_event.addparametertolist(
                  p_name          => 'DELETE',
                  p_value         => 'TRUE',
                  p_parameterlist => l_parameters);
      --
      -- if ROLE is already created, then assign USER_NAME to l_user_name.
      --
      open role_exists(p_rec.person_id);
      fetch role_exists into l_user_name;
      --
      if role_exists%notfound then
         l_user_name := 'PER:'||p_rec.person_id;
      end if;
      close role_exists;
      --
      wf_event.addparametertolist('orclWFOrigSystem','PER',l_parameters);
      wf_event.addparametertolist('orclWFOrigSystemID',p_rec.person_id,l_parameters);
      wf_event.addparametertolist('PERSON_PARTY_ID',p_rec.party_id,l_parameters); -- 3297591
      wf_event.addparametertolist('USER_NAME',l_user_name,l_parameters);
      -- wf_event.addparametertolist('DisplayName',p_rec.full_name,l_parameters); -- 3297591
      wf_event.addparametertolist('DisplayName',l_display_name,l_parameters);
      --
      wf_local_synch.propagate_role(
                       p_orig_system     => 'PER',
                       p_orig_system_id  => p_rec.person_id,
                       p_attributes      => l_parameters,
                       p_start_date      => p_rec.effective_start_date,
                       p_expiration_date => null);
      --
      return;
      --
    end if;
    --
    l_date_chk := PER_HRWF_SYNCH.chk_date_status(
                                  p_rec.effective_start_date,
                                  p_rec.effective_end_date);
    --
    -- If the transaction is in CURRENT time frame
    --
    if l_date_chk = 'CURRENT' then
    --
      hr_utility.set_location('Current Person '||l_proc,20);
      -- call propagate user as of now
      --
      -- assign attributes and values(not null values only) to l_parameters.
      --
      -- NEW CODE START
      --
      --
      -- if ROLE is already created, then assign USER_NAME to l_user_name.
      --
      open role_exists(p_rec.person_id);
      fetch role_exists into l_user_name;
      --
      if role_exists%notfound then
         l_user_name := 'PER:'||p_rec.person_id;
         l_update := 'N'; -- Bug 4597033
      end if;
      --
      close role_exists;
      --
      hr_utility.set_location('start add params',63);
        wf_event.addparametertolist(
                      p_name          => 'USER_NAME',
                      p_value         => l_user_name,
                      p_parameterlist => l_parameters);
        /*
        wf_event.addparametertolist(
                      p_name          => 'DisplayName',
                      p_value         => p_rec.full_name,
                      p_parameterlist => l_parameters);
        */ -- 3297591

        wf_event.addparametertolist(
                      p_name          => 'DisplayName',
                      p_value         => l_display_name,
                      p_parameterlist => l_parameters);  -- 3297591

        wf_event.addparametertolist(
                      p_name          => 'PERSON_PARTY_ID',
                      p_value         => p_rec.party_id,
                      p_parameterlist => l_parameters);   -- 3297591

/*        -- For now these are commented
        wf_event.addparametertolist(
                      p_name          => 'orclWorkFlowNotificationPref',
                      p_value         => 'QUERY',
                      p_parameterlist => l_parameters);

        wf_event.addparametertolist(
                      p_name          => 'preferredLanguage',
                      p_value         => p_rec.correspondence_language,
                      p_parameterlist => l_parameters);

        wf_event.addparametertolist(
                      p_name          => 'FascimileTelephoneNumber',
                      p_value         => FAX,
                      p_parameterlist => l_parameters);
        wf_event.addparametertolist(
                      p_name          => 'orclNLSTerritory',
                      p_value         => TERRITORY,
                      p_parameterlist => l_parameters);

*/
        wf_event.addparametertolist(
                      p_name          => 'mail',
                      p_value         => p_rec.email_address,
                      p_parameterlist => l_parameters);

        wf_event.addparametertolist(
                      p_name          => 'orclIsEnabled',
                      p_value         => 'ACTIVE',
                      p_parameterlist => l_parameters);
-- bug 4635241 commented out the following line and set the value to Null.
       -- l_expiration_date := FND_DATE.date_to_canonical(p_rec.effective_end_date);
       l_expiration_date := NULL;
        wf_event.addparametertolist(
                      p_name          => 'ExpirationDate',
                      p_value         => l_expiration_date,
                      p_parameterlist => l_parameters);

        wf_event.addparametertolist(
                      p_name          => 'orclWFOrigSystem',
                      p_value         => 'PER',
                      p_parameterlist => l_parameters);

        wf_event.addparametertolist(
                      p_name          => 'orclWFOrigSystemID',
                      p_value         => p_rec.person_id,
                      p_parameterlist => l_parameters);
-- Bug 4597033
-- If the transaction is an update then passing the overwrite parameter with value TRUE
        if l_update = 'Y' then
          wf_event.addparametertolist(
                        p_name          => 'WFSYNCH_OVERWRITE',
                        p_value         => 'TRUE',
                        p_parameterlist => l_parameters);

	  open role_description (p_rec.person_id);
          fetch role_description into l_description ;
          close role_description;
          hr_utility.set_location('l_description   '|| l_description,20);

          wf_event.addparametertolist(
                      p_name          => 'description',
                      p_value         => l_description,
                      p_parameterlist => l_parameters);


        end if;
      hr_utility.set_location('end add params',64);
--
-- NEW CODE END
--
      wf_local_synch.propagate_role(
                       p_orig_system     => 'PER',
                       p_orig_system_id  => p_rec.person_id,
                       p_attributes      => l_parameters,
                       p_start_date      => p_rec.effective_start_date,
                      -- p_expiration_date => p_rec.effective_end_date);
		      p_expiration_date => NULL);
  -- Bug 4635241 Modified the call to wf_local_synch.propagate_role
  -- by passing NULL as value for p_expiration_date
    --
      hr_utility.set_location('After calling propagate_role ',65);
    end if;  --l_date_chk = CURRENT
    --
    -- if this is a future dated transaction then defer calling propagate user
    -- until the future date equals sysdate
    --
    if l_date_chk = 'FUTURE' then
      --
      -- This is effective in the future date, Call_back routine must be called.
      --
      -- assign attributes and values for l_parameters.
      --
        hr_utility.set_location('Future Person '||l_proc,50);
      --
      wf_event.addparametertolist(
                    p_name          => 'CONTEXT',
                    p_value         => 'PERSON',
                    p_parameterlist => l_parameters);

      wf_event.addparametertolist(
                    p_name          => 'PERSONID',
                    p_value         => l_person_id_canonical,
                    p_parameterlist => l_parameters);
      wf_event.addparametertolist(
                    p_name          => 'STARTDATE',
                    p_value         => l_start_date_canonical,
                    p_parameterlist => l_parameters);
      wf_event.addparametertolist(
                    p_name          => 'ENDDATE',
                    p_value         => l_end_date_canonical,
                    p_parameterlist => l_parameters);

      --
      hr_utility.set_location('Before calling call_me_later '||l_proc,50);
      -- Call the routine wf_util.call_me_later ()
      --
      wf_util.call_me_later(p_callback   => 'per_hrwf_synch.call_back',
                            p_when       => trunc(p_rec.effective_start_date),
                            p_parameters => l_parameters);
      --
    end if;
    --
    hr_utility.set_location('Leaving '||l_proc,10);
  --
  end per_per_wf;
  --
  --
  --
  -- ----------------------------------------------------------------------------
  -- |-----------------------------< per_asg_wf >-------------------------------|
  -- ----------------------------------------------------------------------------
  --
  --
  --
  procedure per_asg_wf(
        p_rec          in per_all_assignments_f%rowtype,
        p_action       in varchar2) is
  --
  -- local variables
  --
  l_proc                         varchar2(80) := g_package||'per_asg_wf';
  l_date_chk	                 varchar2(10);
  l_start_date_canonical         varchar2(30);
  l_end_date_canonical           varchar2(30);
  l_person_id_canonical          varchar2(20);
  l_assignment_id_canonical      varchar2(20);
  l_parameters                   wf_parameter_list_t;
  --
  l_position_id   per_all_assignments_f.position_id%TYPE;
  l_assignment_id per_all_assignments_f.assignment_id%TYPE;
  l_max_date      date;
  l_start_date    date;
  l_end_date      date;
  --
  cursor start_date is
     select min(effective_start_date)
     from   per_all_assignments_f
     where  assignment_id            = l_assignment_id
     and    position_id              = l_position_id
     and    nvl(assignment_type,'Z') = 'E'
     and    nvl(primary_flag,'Z')    = 'Y';
  --
  cursor maxpos_date is
     select max(nvl(date_end, hr_api.g_eot))
     from   per_all_positions
     where  position_id = l_position_id;
  --
  Begin
    --
    l_position_id   := p_rec.position_id;
    l_assignment_id := p_rec.assignment_id;
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    -- check for the primary assignment flag=Y and assignmrnt type = E
    -- if primary flag <> 'Y' then
    --   return
    -- end if
    --
    if p_rec.assignment_type <> 'E' and p_rec.primary_flag <>'Y' then
    --
      hr_utility.set_location('Assignment neither Primary nor type = E '||l_proc,15);
      hr_utility.set_location('Leaving '||l_proc,16);
      return;
    --
    end if;
    --
    -- No need to process where position_id is null
    --
    if p_rec.position_id is null then
    --
      hr_utility.set_location('Position id is null ..  '||l_proc,20);
      hr_utility.set_location('Leaving ..  '||l_proc,21);
      return;
    --
    end if;
    --
    -- Check if this is DELETE
    --
    if nvl(p_action,'NO_DELETE') = 'DELETE' then
      hr_utility.set_location('Delete Assignment  ',25);
      --
      WF_LOCAL_SYNCH.propagate_user_role(
                     p_user_orig_system     => 'PER',
                     p_user_orig_system_id  => p_rec.person_id,
                     p_role_orig_system     => 'POS',
                     p_role_orig_system_id  => 'POS'||':'||p_rec.position_id,
                     p_start_date           => p_rec.effective_start_date,
                     p_expiration_date      => p_rec.effective_end_date);
      return;
      --
    end if;
    --
    l_date_chk := PER_HRWF_SYNCH.chk_date_status(
                                  p_rec.effective_start_date,
                                  p_rec.effective_end_date);
    --
    -- If the transaction is in CURRENT time frame
    --
    if l_date_chk = 'CURRENT' then
      --
      hr_utility.set_location('Current Assignment  ',30);
      -- call propagate user as of now
      --
      -- we are not passing any attributes to propagate_user_role procedure....
      open start_date;
      fetch start_date into l_start_date;
      close start_date;
      --
      open maxpos_date;
      fetch maxpos_date into l_max_date;
      close maxpos_date;
      --
      if l_max_date <= p_rec.effective_end_date then
         l_end_date := l_max_date;
      else
         l_end_date := p_rec.effective_end_date;
      end if;
      --
      -- Call wf_local_synch.propogate_user_role()
      hr_utility.set_location('Before Calling propagate_user_role  ',35);
      WF_LOCAL_SYNCH.propagate_user_role(
                     p_user_orig_system     => 'PER',
                     p_user_orig_system_id  => p_rec.person_id,
                     p_role_orig_system     => 'POS',
                     p_role_orig_system_id  => p_rec.position_id,
                     p_start_date           => l_start_date,
                     p_expiration_date      => l_end_date);
    --
    end if;  --l_date_chk = CURRENT
    --
    -- if this is effective in a future date then defer calling propagate user
    -- until the future date equals sysdate
    --
    --
    if l_date_chk = 'FUTURE' then
      --
      hr_utility.set_location('Future Assignment  ',40);
      -- This is effective in the future date, Call_back routine must be called.
      --
      --
      l_person_id_canonical     := FND_NUMBER.number_to_canonical(p_rec.person_id);
      l_assignment_id_canonical := FND_NUMBER.number_to_canonical(p_rec.assignment_id);
      l_start_date_canonical    := FND_DATE.date_to_canonical(p_rec.effective_start_date);
      l_end_date_canonical      := FND_DATE.date_to_canonical(p_rec.effective_end_date);
      --
      -- assign attributes and values for l_parameters.
      --
      --
      wf_event.addparametertolist(
                    p_name          => 'CONTEXT',
                    p_value         => 'POSITION',
                    p_parameterlist => l_parameters);
      wf_event.addparametertolist(
                    p_name          => 'ASSIGNMENTID',
                    p_value         => l_assignment_id_canonical,
                    p_parameterlist => l_parameters);
      wf_event.addparametertolist(
                    p_name          => 'STARTDATE',
                    p_value         => l_start_date_canonical,
                    p_parameterlist => l_parameters);
      wf_event.addparametertolist(
                    p_name          => 'ENDDATE',
                    p_value         => l_end_date_canonical,
                    p_parameterlist => l_parameters);

      -- Call the routine wf_util.call_me_later ()
      --
      hr_utility.set_location('Calling WF routine call_me_later....  ',45);
      WF_UTIL.call_me_later(p_callback   => 'PER_HRWF_SYNCH.call_back',
                            p_when       => trunc(p_rec.effective_start_date),
                            p_parameters => l_parameters);
      --
    end if;
    --
    hr_utility.set_location('Leaving '||l_proc,100);
  --
  end per_asg_wf;
  --
  --
  -- ----------------------------------------------------------------------------
  -- |-----------------------------< per_pds_wf >-------------------------------|
  -- ----------------------------------------------------------------------------
  --
  procedure per_pds_wf(
     p_rec                  in per_periods_of_service%rowtype,
     p_date                 in date default null,
     p_action               in varchar2) is
  --
  l_proc                 varchar2(80) := g_package||'per_pds_wf';
  l_date                 date;
  l_parameters           wf_parameter_list_t;
  l_user_name            wf_local_roles.name%type;
  --
  --
  -- cursors
  --
  cursor role_exists(p_person_id in number) is
    select name
    from   wf_local_roles
    where  orig_system    = 'PER'
    and    orig_system_id = p_person_id
    and rownum = 1; -- This extra WHERE condition is added as per the request of "tpapired"
  --
  begin
  --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    if p_action = 'TERMINATION' then
      -- l_date := p_date;
      l_date := p_date +(1-1/86400); -- bug 4773768
      hr_utility.set_location('Termination.. '||l_proc,20);
    else
      hr_utility.set_location('Reverse Termination.. '||l_proc,20);
      --set the end of time as ATD
      l_date := to_date('31-12-4712', 'DD-MM-YYYY');
      -- set the status a ACTIVE
       wf_event.addparametertolist('orclIsEnabled','ACTIVE',l_parameters); -- 4133057
    end if;
    --
      --
      -- if ROLE is already created, then assign USER_NAME to l_user_name.
      --
      open role_exists(p_rec.person_id);
      fetch role_exists into l_user_name;
      --
      if role_exists%notfound then
         l_user_name := 'PER:'||p_rec.person_id;
      end if;
      --
      close role_exists;
      --
    wf_event.addparametertolist('orclWFOrigSystem','PER',l_parameters);
    wf_event.addparametertolist('orclWFOrigSystemID',p_rec.person_id,l_parameters);
    --l_user_name := 'PER:'||p_rec.person_id;
    wf_event.addparametertolist('USER_NAME',l_user_name,l_parameters);
    --
    hr_utility.set_location('Calling Propagate_role '||l_proc,30);
    wf_local_synch.propagate_role(
                   p_orig_system     => 'PER',
                   p_orig_system_id  => p_rec.person_id,
                   p_attributes      => l_parameters,
                   p_start_date      => p_rec.date_start,
                   p_expiration_date => l_date);

    hr_utility.set_location('Leaving '||l_proc,40);
  --
  end per_pds_wf;
  --
  -- --------------------------------------------------------------------------
  -- |-----------------------------< per_per_wf >------------------------------|
  -- --------------------------------------------------------------------------
    procedure per_per_wf(
       p_rec                  in per_per_shd.g_rec_type,
       p_action               in varchar2) is
       --
       l_rec   per_all_people_f%rowtype;
       --
       l_party_id number(15,0);
       --
       cursor get_party_id(p_person_id in number) is
              select party_id
                from per_all_people_f
               where person_id = p_rec.person_id;
    begin
       -- 3297591 - in case party_id has since been filled... is this needed?
       if p_rec.party_id is null
       then
          open get_party_id(p_rec.person_id);
          fetch get_party_id into l_party_id;
          --
          if get_party_id%notfound then
             l_party_id := NULL;
          end if;
       else
          l_party_id := p_rec.party_id;
       end if;
       -- 3297591 was that needed?
       --
       -- Transfering the argument values from per_per_shd.g_rec_type to
       -- per_all_people_f%rowtype
       --
       l_rec.current_employee_flag := p_rec.current_employee_flag;
       l_rec.current_npw_flag := p_rec.current_npw_flag;
       l_rec.person_id := p_rec.person_id;
       l_rec.party_id := l_party_id;  -- 3297591
       l_rec.effective_start_date := p_rec.effective_start_date;
       l_rec.effective_end_date := p_rec.effective_end_date;
       l_rec.full_name := p_rec.full_name;
       l_rec.correspondence_language := p_rec.correspondence_language;
       l_rec.email_address := p_rec.email_address;
       --
       -- Calling the actual procedure
       per_per_wf(p_rec      => l_rec,
                  p_action   => p_action);

       --
    end per_per_wf;
  --
  -- --------------------------------------------------------------------------
  -- |-----------------------------< per_pds_wf >------------------------------|
  -- --------------------------------------------------------------------------
    procedure per_pds_wf(
       p_person_id            in number,
       p_date                 in date default null,
       p_date_start           in date,
       p_action               in varchar2) is
       --
       l_rec  per_periods_of_service%rowtype;
       --
    begin
       --
       -- Transfering the argument values from local variables to
       -- per_periods_of_service%rowtype
       --
       l_rec.person_id := p_person_id;
       l_rec.date_start := p_date_start;
       --
       -- Calling the actual procedure
       per_pds_wf(p_rec     => l_rec,
                  p_date    => p_date,
                  p_action  => p_action);
       --
    end per_pds_wf;
  --
end per_hrwf_synch;

/
