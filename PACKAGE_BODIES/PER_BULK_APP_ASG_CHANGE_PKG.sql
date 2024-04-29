--------------------------------------------------------
--  DDL for Package Body PER_BULK_APP_ASG_CHANGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BULK_APP_ASG_CHANGE_PKG" AS
/* $Header: peasg03t.pkb 115.13 2004/06/16 01:07:57 adudekul ship $ */
--
-- PRIVATE FUNCTIONS
--
   -- This procedure used during development only
   procedure Message( p_msg in varchar2 ) is
   begin
      --dbms_output.put_line ( p_msg ) ;
      null;
   end message ;
--
-- Name
--  exists_other_active_asg
-- Purpose
--  Returns TRUE if there are other active assignments for this
--  application
-- Arguments
--  p_assignment_id
--
   function exists_other_active_asg ( p_application_id in number,
                p_person_id      in number,
                p_assignment_id  in number )
      return boolean is
   --
   l_return_status boolean ;
   l_dummy_date    date ;
   --
   -- Retrieves the latest end date of any applicant assignment for the
   -- application which is not the current assignment.
   --
   cursor c1 is
     select max(effective_end_date)
     from   per_all_assignments_f
     where  person_id        = p_person_id
     and    application_id   = p_application_id
     and    assignment_id   <> p_assignment_id
     and    assignment_type  = 'A' ;
   begin
     open c1 ;
     fetch c1 into l_dummy_date ;
     close c1 ;
     if (    l_dummy_date is not null
      and l_dummy_date = hr_general.end_of_time ) then
      l_return_status := TRUE ;
     else
      l_return_status := FALSE ;
     end if;
     --
     return( l_return_status ) ;
   --
   end exists_other_active_asg ;
   --
--
-- Name
--   chk_future_asg_changes
-- Purpose
--   Checks whether there are any future assignment changes to
--   the given assignment. If there are any then an error is raised.
-- Arguments
--   p_assignment_id
--
   procedure chk_future_asg_changes ( p_assignment_id in number ) is
   l_dummy number ;
   cursor c1 is
     select 1
     from   per_all_assignments_f  a,
       fnd_sessions           f
     where  a.assignment_id        = p_assignment_id
     and    f.session_id           = userenv('sessionid')
     and    a.effective_start_date > f.effective_date ;
   begin
   --
       message('checking for future assignment changes');
       open c1 ;
       fetch c1 into l_dummy ;
       if c1%found then
      close c1 ;
      hr_utility.set_message ( 801, 'HR_6408_APPS_NO_UPDATE' ) ;
      hr_utility.set_message_token ( 'TYPE' , 'recruiter or status');
      hr_utility.raise_error ;
       end if;
       close c1 ;
   --
   end chk_future_asg_changes ;
--

-- Name
--  chk_asg_status_change
-- Purpose
--   Validates change to assignment status type
--   Checks the following :
--    1. The assignment must not have already ended.
--    2. If this is the first status for the assignment it must be
--       ACTIVE_APL. ie if the datetrack update mode is correction then
--       the current row must not be the first for that assignment.
--    3. If the new system status is TERM_APL then
--         i) There must be no future person changes.
--        ii) Assignment Continuity must not be broken.
-- Arguments
   procedure chk_asg_status_change(p_application_id     in number,
                              p_person_id          in number,
                    p_assignment_id      in number,
               p_per_system_status  in varchar2,
               p_asg_status_type_id in varchar2,
               p_dt_update_mode     in varchar2,
               p_business_group_id  in number ) is
     --
     --
     procedure chk_assignment_current ( p_assignment_id in number ) is
     l_asg_max_end_date   date ;
     -- Retrieve latest end date of assignment
     cursor c1 is
   select max(effective_end_date)
   from   per_all_assignments_f
   where  assignment_id = p_assignment_id ;
     begin
     --
       open c1 ;
       fetch c1 into l_asg_max_end_date ;
       close c1 ;
       --
       if ( l_asg_max_end_date < hr_general.end_of_time ) then
     hr_utility.set_message(801, 'HR_6751_APP_TERM_ALREADY');
     hr_utility.raise_error;
       end if;
     --
     end chk_assignment_current ;
     --
     --
     --
     procedure term_apl_checks ( p_application_id    in number,
             p_person_id         in number,
             p_assignment_id     in number,
             p_business_group_id in number ) is
     l_dummy_date         date ;
     l_effective_date     date ;
     -- Commented out as part of fix to bug 677744.
     -- l_max_end_date       date ;
     --
     -- Check to see whether there any changes to the person table
     -- after the current date
     --
     cursor c1 is
   select f.effective_date
   from   per_people_f  p,
          fnd_sessions  f
   where  p.person_id            = p_person_id
   and    p.effective_start_date > f.effective_date
   and    f.session_id           = userenv('sessionid') ;
     --
     --
     -- Retrieve the effective date
     cursor c3 is
   select effective_date
   from   fnd_sessions
   where  session_id = userenv('sessionid');
     --
     --
     -- This cursor retrieves the day before the earliest start date for
     -- the given assignment
     --
     -- Commented out as part of fix for bug 677744. This cursor is no longer
     -- required.
     -- cursor c4 is
   --  select min(effective_start_date) - 1
        --  from   per_all_assignments_f
   --  where  assignment_id = p_assignment_id  ;
     -- End of this part of fix.
     --
     begin
       --
       -- Check that there are no future person changes.
       --
       open c1 ;
       fetch c1 into l_dummy_date ;
       if ( c1%found ) then
      close c1 ;
      hr_utility.set_message(801,'HR_6382_APP_TERM_FUTURE_PPT');
      hr_utility.set_message_token( 'DATE' , to_char(l_dummy_date));
      hr_utility.raise_error ;
       end if;
       close c1 ;
     --
       --
       -- If there is more than one assignment for the given application
       -- then check that assignment continuity for the application will
       -- not be broken for the application by ending the current assignment
       --
       if ( exists_other_active_asg( p_application_id,
                 p_person_id,
                 p_assignment_id ) ) then
         --
         -- Retrieve the effective date
    open c3  ;
    fetch c3 into l_effective_date ;
    close c3 ;
    --
    -- Commented out as part of fix for bug 677744.
    --
    -- Retrieve the earliest start date - 1 for the current assignment
    -- open c4 ;
    -- fetch c4 into l_max_end_date ;
    -- close c4 ;
         --
         -- Check assignment continuity will not be broken by ending the current
         -- row
    --
    -- The call below was commented out as part of fix for bug 677744.
    -- the line  'p_max_end_date      => l_max_end_date,'
    -- was replaced with 'p_max_end_date      => l_effective_date'
    --
         per_app_asg_pkg.check_assignment_continuity (
      p_business_group_id => p_business_group_id,
      p_assignment_id     => p_assignment_id,
           p_person_id         => p_person_id,
      p_max_end_date      => l_effective_date,
      p_session_date      => l_effective_date ) ;
        --
   -- End of fix.
        end if;
     --
     end term_apl_checks ;
      --
     begin
       --
       chk_assignment_current (p_assignment_id);
       --
     --
     --
     if ( p_per_system_status = 'TERM_APL' ) then
      --
    term_apl_checks(p_application_id,
          p_person_id,
          p_assignment_id,
          p_business_group_id ) ;
      --
     end if;
     --
     end chk_asg_status_change ;
--
-- PUBLIC FUNCTIONS
--
   procedure get_db_defaults ( p_business_group_id      in number,
                          p_grade_structure        in out nocopy number,
                          p_people_group_structure in out nocopy number,
                          p_job_structure          in out nocopy number,
                          p_position_structure     in out nocopy number ) is
   --
   cursor c1 is
    select grade_structure,
      people_group_structure,
      job_structure,
      position_structure
         from   per_business_groups
    where  business_group_id = p_business_group_id ;
   --
   begin

       open c1 ;
       fetch c1 into p_grade_structure,
                     p_people_group_structure,
                     p_job_structure,
                     p_position_structure ;
       close c1 ;

   end get_db_defaults ;
--
   procedure validate_asg_change ( p_application_id         in number,
                    p_person_id              in number,
                    p_assignment_id          in number,
                    p_status_changed         in boolean,
                    p_new_system_status      in varchar2,
                    p_new_asg_status_type_id in number,
                    p_recruiter_id           in number,
               p_dt_update_mode         in varchar2,
               p_business_group_id      in number) is
   begin
   --
       -- No changes are allowed if there are future assignment changes
       chk_future_asg_changes ( p_assignment_id ) ;
       --
       --
       -- Perform validation specific to the Assignment Status changing
       if ( p_status_changed = TRUE ) then
    chk_asg_status_change ( p_application_id,
             p_person_id,
             p_assignment_id,
             p_new_system_status,
             p_new_asg_status_type_id,
             p_dt_update_mode,
             p_business_group_id) ;
       end if;
   --
   --
   --
   end validate_asg_change ;
   --
   procedure update_row ( p_rowid         in varchar2,
           p_application_id         in number,
           p_person_id              in number,
           p_assignment_id          in number,
           p_status_changed      in boolean,
           p_new_system_status      in varchar2,
           p_new_asg_status_type_id in number,
           p_recruiter_id           in number,
           p_dt_update_mode         in varchar2,
           p_effective_date         in date,
           p_effective_start_date   in date,
           p_validation_start_date  in date,
           p_business_group_id      in number ) is
    --
    l_end_row varchar2(5) := 'FALSE' ; -- Should the assignment row's
                   -- end date be set to the session date
    l_max_asg_end_date date ;

    -- Variables added for fix 3355901
    l_assignment_status_id number;
    l_object_version_number number;

    -- Name
    --  get_max_asg_date
    -- Purpose
    --  Finds the greatest end date for an assignment other than the current
    --  one
    function get_max_asg_date ( p_application_id in number,
            p_person_id      in number,
            p_assignment_id  in number,
            p_effective_date in date ) return date is
    cursor c1 is
       select nvl(max(a.effective_end_date),p_effective_date)
       from   per_all_assignments_f a
       where  a.person_id       = p_person_id
       and    a.application_id  = p_application_id
       and    a.assignment_id  <> p_assignment_id
       and    a.assignment_type = 'A'
       and    p_effective_date between a.effective_start_date
                and     a.effective_end_date ;
    l_return_value date ;
    begin
    --
      open c1 ;
      fetch c1 into l_return_value;
      close c1 ;
      --
      return ( l_return_value ) ;
    --
    end get_max_asg_date ;

    -- Name
    --   term_apl_sec_statuses
    -- Purpose
    --   Called when terminating an assignment.
    --   Ends any current secondary statuses.
    --   Deletes any future secondary statuses.
    -- Arguments
    --    p_assignment_id
    --    p_effective_date
    --
    procedure term_apl_sec_statuses ( p_assignment_id  in number,
                  p_effective_date in date   ) is
    begin
    --
   delete from per_secondary_ass_statuses
   where  assignment_id = p_assignment_id
   and    start_date    > p_effective_date ;
    --
   update per_secondary_ass_statuses
        set    end_date      = p_effective_date
   where  assignment_id = p_assignment_id
   and    p_effective_date between start_date
            and     nvl(end_date,p_effective_date) ;
    end term_apl_sec_statuses ;
    --
    -- Name
    --  delete_pending_letters
    -- Purpose
    --  Removes any pending letter requests lines which are not for the
    --  assignments new status which were automatically generated.
    --  If there are no letter request lines for a given request then
    --  remove the request
    -- Arguments
    --    p_assignment_id
    --    p_assignment_status_type_id
    --    p_business_group_id
    procedure delete_pending_letters ( p_assignment_id             in number,
                   p_assignment_status_type_id in number,
                   p_business_group_id         in number) is
    begin
    --
       delete from per_letter_request_lines l
       where  l.assignment_id              = p_assignment_id
       and    l.assignment_status_type_id <> p_assignment_status_type_id
       and    exists ( select 1
             from   per_letter_requests r
             where  r.letter_request_id = l.letter_request_id
             and    r.request_status    = 'PENDING'
             and    r.auto_or_manual    = 'AUTO' ) ;
       message('DELETED '||to_char(sql%rowcount)||' ROWS FROM REQUEST LINES');
    --
       --
       -- Remove any 'empty' requests in the current business group
       --
       delete from per_letter_requests r
       where  r.business_group_id     = p_business_group_id
       and    r.request_status        = 'PENDING'
       and    r.auto_or_manual        = 'AUTO'
       and not exists ( select 1
         from   per_letter_request_lines l
         where  l.letter_request_id = r.letter_request_id
            ) ;
       message('DELETED '||to_char(sql%rowcount)||' ROWS FROM LETTER REQUESTS');
    --
    end delete_pending_letters ;
    --
    -- Name
    --  delete_events
    -- Purpose
    --  Removes scheduled events,interviews and bookings
    --  for the given assignment. Called when terminating the
    --  assignment.
    -- Arguments
    --  p_assignment_id
    --  p_effective_date
    procedure delete_events ( p_assignment_id in number,
               p_effective_date in date ) is
    begin
    --
      delete from per_bookings b
      where  b.event_id in ( select e.event_id
              from   per_events e
              where  e.assignment_id = p_assignment_id
                             and    e.date_start    > p_effective_date
            ) ;
      --
      delete from per_events e
      where  e.assignment_id  = p_assignment_id
      and    e.date_start     > p_effective_date ;
    --
    end delete_events ;
    --
    -- Name
    --   chk_letters
    -- Purpose
    --   Peforms letter request processing. Used when the assignments status
    --   changes
    -- Arguments
    --
    procedure chk_letters ( p_assignment_id             in number,
                            p_person_id                 in number,
             p_per_system_status         in varchar2,
             p_assignment_status_type_id in number,
             p_business_group_id         in number,
             p_effective_date    in date,
             p_validation_start_date     in date) is

cursor csr_vacancy_id is
Select vacancy_id
From per_all_assignments_f
Where assignment_id = p_assignment_id
And p_effective_date between effective_start_date and effective_end_date;

l_vacancy_id number;
    begin
    --
   --
   -- Remove any pending letters
   --
   delete_pending_letters ( p_assignment_id,
             p_assignment_status_type_id,
             p_business_group_id ) ;
        --
        -- Create any new letter requests for new status
        --
open csr_vacancy_id;
fetch csr_vacancy_id into l_vacancy_id;
if csr_vacancy_id%NOTFOUND then null;
end if;
close csr_vacancy_id;
--
   per_applicant_pkg.check_for_letter_requests(p_business_group_id,
                      p_per_system_status,
                      p_assignment_status_type_id,
                      p_person_id,
                      p_assignment_id,
                      p_effective_date,
                      p_validation_start_date,
                                                    l_vacancy_id) ;
        --
    end chk_letters ;
    --
    begin   -- main procedure starts here
    --
    --
    --  Check that the update is still OK
    --
        validate_asg_change ( p_application_id,
               p_person_id,
               p_assignment_id,
               p_status_changed,
               p_new_system_status,
               p_new_asg_status_type_id,
               p_recruiter_id,
               p_dt_update_mode,
               p_business_group_id);
    --
    --
    --  Update the row
    --  If the user is updating the status to TERM_APL then
    --  set the end date on the row but don't change the status.
    --
    if  ( p_status_changed and p_new_system_status = 'TERM_APL' ) then
      l_end_row := 'TRUE' ;
    end if ;
    --
    update per_all_assignments_f
    set    assignment_status_type_id = decode( l_end_row,
                      'TRUE',
                      assignment_status_type_id,
                      p_new_asg_status_type_id ),
      recruiter_id              = p_recruiter_id,
      effective_start_date      = p_effective_start_date,
      effective_end_date        = decode(l_end_row,
                     'TRUE',
                      p_effective_date,
                      effective_end_date )
    where rowid = p_rowid ;
    --
    -- Perform 3rd party updates if the status is being changed
    --
    if ( p_status_changed  = TRUE ) then
    --
    -- Fix for bug 3355901 Start
    IRC_ASG_STATUS_API.create_irc_asg_status
                ( p_validate                   => FALSE
                , p_assignment_id              => p_assignment_id
                , p_assignment_status_type_id  => p_new_asg_status_type_id
                , p_status_change_date         => p_effective_date
                , p_assignment_status_id       => l_assignment_status_id
                , p_object_version_number      => l_object_version_number
                 );
    -- Fix for bug 3355901 End
    --
      if ( p_new_system_status = 'TERM_APL' ) then
       --
     if ( not exists_other_active_asg( p_application_id,
                   p_person_id,
                   p_assignment_id ) ) then
       --
            -- Terminate the Application
       --
       message('TERMINATING APPLICATION');
       l_max_asg_end_date := get_max_asg_date( p_application_id,
                      p_person_id,
                      p_assignment_id,
                      p_effective_date ) ;
            --
       per_applications_pkg.maintain_ppt_term ( p_business_group_id,
                       p_person_id,
                       l_max_asg_end_date,
                       hr_general.end_of_time,
                       null,
                       null ) ;
            --
       update per_applications
       set    date_end       = l_max_asg_end_date
       where  application_id = p_application_id ;

            -- Bug fix for 1222139
            --
            -- Now maintain the PTU data...
            --
-- PTU Changes
--            hr_per_type_usage_internal.maintain_ptu(
--                  p_action => 'TERM_APL',
--                  p_person_id => p_person_id,
--                  p_actual_termination_date => l_max_asg_end_date);
--
-- Changed p_System_person_type from EX_EMP to EX_APL
-- as part of fix for bug 2330287
--
hr_per_type_usage_internal.maintain_person_type_usage
(  p_effective_date         => l_max_asg_end_date+1
  ,p_person_id              => p_person_id
  ,p_person_type_id         =>
                        hr_person_type_usage_info.get_default_person_type_id
                                (p_business_group_id    => p_business_group_id
                                ,p_system_person_type   => 'EX_APL')
  ,p_datetrack_update_mode  => 'UPDATE');


-- PTU Changes
       --
            --
     end if;
     --
     message('REMOVE SECONDARY STATUSES');
     term_apl_sec_statuses( p_assignment_id,
             p_effective_date ) ;
     --
     message('REMOVE BOOKINGS,INTERVIEWS AND EVENTS');
     delete_events ( p_assignment_id,
                p_effective_date ) ;
      end if;
      --
      message('DO LETTERS PROCESSING');
      chk_letters ( p_assignment_id             => p_assignment_id,
                    p_person_id                 => p_person_id,
          p_per_system_status         => p_new_system_status,
          p_assignment_status_type_id => p_new_asg_status_type_id,
          p_business_group_id         => p_business_group_id,
          p_effective_date    => p_effective_date,
          p_validation_start_date     => p_validation_start_date ) ;
    --
    end if ;
   end update_row ;
--
END PER_BULK_APP_ASG_CHANGE_PKG ;

/
