--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_API" as
/* $Header: peasgapi.pkb 120.20.12010000.16 2010/04/29 12:29:11 sudsahu ship $ */
--
-- Package Variables
--
g_package  CONSTANT varchar2(33) := '  hr_assignment_api.';
g_debug boolean := hr_utility.debug_enabled;
--
----------------------------------------------------------------------------
-- |----------------------< update_pgp_concat_segs >------------------------|
----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   When required this procedure updates the pay_people_groups table after
--   the flexfield segments have been inserted to keep the concatenated
--   segment string up-to-date.
--
-- Prerequisites:
--   A row must exist in the pay_people_groups table for the
--   given people_group_id.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_people_group_id              Yes  number   The primary key
--   p_group_name                   Yes  varchar2 The concatenated segments
--
-- Post Success:
--   If required the row is updated and committed.
--
-- Post Failure:
--   The procedure will raise an error.
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
procedure update_pgp_concat_segs
  (p_people_group_id              in     number
  ,p_group_name                   in     varchar2
  ) is
  --
  CURSOR csr_chk_pgp is
    SELECT null
      FROM pay_people_groups
     where people_group_id = p_people_group_id
       and (group_name     <> p_group_name
        or group_name is null);
  --
  l_exists  varchar2(30);
  l_proc   varchar2(72) := g_package||'update_pgp_concat_segs';
  --
  procedure update_pgp_concat_segs_auto
    (p_people_group_id              in     number
    ,p_group_name                   in     varchar2
    ) is
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
    CURSOR csr_pgp_lock is
      SELECT null
        FROM pay_people_groups
       where people_group_id = p_people_group_id
         for update nowait;
    --
    l_exists  varchar2(30);
    l_proc    varchar2(72) := g_package||'update_pgp_concat_segs_auto';
    l_group_name1    varchar2(2000); --added for bug#7601790
    --
  begin
    if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
    end if;
    --
    -- The outer procedure has already establish that an update is
    -- required. This sub-procedure uses an autonomous transaction
    -- to ensure that any commits do not impact the main transaction.
    -- If the row is successfully locked then continue and update the
    -- row. If the row cannot be locked then another transaction must
    -- be performing the update. So it is acceptable for this
    -- transaction to silently trap the error and continue.
    --
    -- Note: It is necessary to perform the lock test because in
    -- a batch data upload scenario multiple sessions could be
    -- attempting to insert or update the same Key Flexfield
    -- combination at the same time. Just directly updating the row,
    -- without first locking, can cause sessions to hang and reduce
    -- batch throughput.
    --
    open csr_pgp_lock;
    fetch csr_pgp_lock into l_exists;
    if csr_pgp_lock%found then
      close csr_pgp_lock;

      if g_debug then
      hr_utility.set_location(l_proc, 20);
      end if;

      --
      -- Bug#7601790
      -- Added the code to check whether p_group_name is greater
      -- than 240 characters. If yes, only first 240 characters
      -- are updated into the table pay_people_groups
      --
      -- fix for Bug#7601790 starts

      l_group_name1:=p_group_name;
      if length(p_group_name) > 240 then
         l_group_name1:=substr(p_group_name,1,240);
      end if;

      -- fix for Bug#7601790 ends
      --
      -- Lock obtained by this transaction, updating the concatenated
      -- segment string should be performed.
      --
      update pay_people_groups
         --set group_name      = p_group_name  fix for Bug#7601790
         set group_name      = l_group_name1
       where people_group_id = p_people_group_id
         and (group_name     <> p_group_name
          or group_name is null);
      --
      -- Commit this change so the change is immediately visible to
      -- other transactions. Also ensuring that it is not undone if
      -- the main transaction is rolled back. This commit is only
      -- acceptable inside an API because it is being performed inside
      -- an autonomous transaction and AOL code has previously
      -- inserted the Key Flexfield combination row in another
      -- autonomous transaction.
      commit;
    else
      close csr_pgp_lock;
      rollback; -- Added for bug 3578845.
    end if;
    --
    if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 30);
    end if;

  Exception
    When HR_Api.Object_Locked then
      --
      -- This autonomous transaction was unable to lock the row.
      -- It can be assumed that another transaction has locked the
      -- row and is performing the update. Hence the error can
      -- be suppressed without raising it to the end user.
      --
      rollback; -- Added for bug 3578845.
      hr_utility.set_location('Leaving:'|| l_proc, 40);
  end update_pgp_concat_segs_auto;
begin
--
  if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- First find out if it is necessary to update the concatenated
  -- segment string column. This select is being done to avoid the
  -- performance unnecessary overhead of set-up an autonomous
  -- transaction when an update is not required. Updates are only
  -- expected immediately after the combination row was first inserted.
  --
  open csr_chk_pgp;
  fetch csr_chk_pgp into l_exists;
  if csr_chk_pgp%found then
    close csr_chk_pgp;
    update_pgp_concat_segs_auto
      (p_people_group_id => p_people_group_id
      ,p_group_name      => p_group_name
      );
  else
    close csr_chk_pgp;
  end if;
  --
 if g_debug then
  hr_utility.set_location('Leaving:'|| l_proc, 20);
 end if;
  --
end update_pgp_concat_segs;
--
-- Start of fix for bug 6008188
----------------------------------------------------------------------------
-- |----------------------< reverse_term_apln >------------------------|
----------------------------------------------------------------------------
-- {Start Of Comments}
--

-- Description:
--   This procedure is used to reverse the termination of an applicant at
-- application level.
--
-- Prerequisites:
--   data must exists in the table per_all_assignments_f for an Person
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_effective_date			yes        Effective date
--  p_business_group_id			yes        Business Group id
--  p_assignment_id			yes	   Assignment id
--   p_person_id			yes	   Person id of the person
-- p_status_change_reason               No         Reason for reverse termination .
--
-- Post Success:
--   The row is updated
--
-- Post Failure:
--   The procedure will raise an error.
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}

PROCEDURE reverse_term_apln ( p_effective_date date ,p_business_group_id number ,
                               p_assignment_id number, p_person_id number,
			       p_status_change_reason   in  varchar2 default null
			       ,p_return_status out nocopy varchar2) is
-- declare all cursors and variables
l_proc               varchar2(72);
l_date_end          date;
l_asg_end_date      date;
l_cost_warning      boolean;
l_assignment_status_id number;
l_date_recieved date;
l_eot date := hr_api.g_eot;
l_ass_status varchar2(20);
l_dummy varchar2(10);
l_asg_status_id  number;
l_object_version_number number;
l_ptu_date_end date;
l_application_id number;
l_asg_start_date date;
l_ovn number;

l_validation_start_date  date;
l_validation_end_date date;


cursor c1 is
select date_end ,date_received, application_id
from per_applications papp
where application_id =
           ( select distinct (application_id)
         from per_all_assignments_f
            where assignment_id = p_assignment_id and
                business_group_id = p_business_group_id )
for update nowait;

cursor c2 is
  select 1
  from per_all_assignments_f a
  where assignment_id = p_assignment_id
  and exists
       (select null
        from   per_assignment_status_types b
        where  b.per_system_status in ('TERM_APL','ACTIVE_ASSIGN')
        and    a.assignment_status_type_id = b.assignment_status_type_id) ;

cursor c3(p_date_end date) is
  SELECT 1
  FROM   PER_ALL_PEOPLE_F PAPF
  WHERE  PAPF.PERSON_ID = P_PERSON_ID
  AND    PAPF.EFFECTIVE_START_DATE > p_DATE_END + 1 ;


cursor csr_ptu_row (p_date_received in date ) is
select   ptu.effective_start_date
from  per_person_type_usages_f ptu
      ,per_person_types ppt
where    ptu.person_id = p_person_id
and   ptu.effective_start_date > p_date_received
and   ptu.person_type_id = ppt.person_type_id
and     ppt.system_person_type = 'EX_APL'
order by ptu.effective_start_date;

--start changes for bug 7217475

cursor csr_chk_bg_exists is
 select 1
 from per_business_groups
 where business_group_id = p_business_group_id;

cursor csr_chk_person_exists is
 select 1
 from per_all_people_f
 where business_group_id = p_business_group_id
  and person_id = p_person_id
  and p_effective_date between effective_start_date and effective_end_date;

cursor csr_chk_asg_exists is
 select 1
 from per_all_assignments_f
 where business_group_id = p_business_group_id
  and person_id = p_person_id
  and assignment_id = p_assignment_id;
  --and p_effective_date between effective_start_date and effective_end_date;
  -- Commented above condition for Bug#9049586

l_bg_exists number;
l_person_exists number;
l_asg_exists number;

--end changes for bug 7217475

-- end of declaration

begin
--            l_proc := 'REVERSE_TERM_APLN';
 p_return_status:='S';

 --start changes for bug 7217475
 --
 -- hr_multi_message.enable_message_list;
 hr_utility.set_location('Entering:'|| l_proc, 10);

 --
 open csr_chk_bg_exists;
 fetch csr_chk_bg_exists into l_bg_exists;
 if csr_chk_bg_exists%notfound then
  hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
  hr_utility.raise_error;
 end if;
 close csr_chk_bg_exists;
 --
 hr_utility.set_location('REVERSE_TERM_APLN - p_business_group_id:'|| p_business_group_id, 10);

 --
 open csr_chk_person_exists;
 fetch csr_chk_person_exists into l_person_exists;
 if csr_chk_person_exists%notfound then
  hr_utility.set_message(800,'HR_52786_SUC_CHK_PERSON_EXISTS');
  hr_utility.raise_error;
 end if;
 close csr_chk_person_exists;
 --
 hr_utility.set_location('REVERSE_TERM_APLN - p_person_id:'|| p_person_id, 10);

 --
 open csr_chk_asg_exists;
 fetch csr_chk_asg_exists into l_asg_exists;
 if csr_chk_asg_exists%notfound then
    hr_utility.set_message(801,'HR_52360_ASG_DOES_NOT_EXIST');
    hr_utility.raise_error;
 end if;
 close csr_chk_asg_exists;
 --

 hr_utility.set_location('REVERSE_TERM_APLN - p_assignment_id:'|| p_assignment_id, 10);

 --
 if p_status_change_reason is not null then
  if hr_api.not_exists_in_dt_hr_lookups
   (p_effective_date        => p_effective_date
    ,p_validation_start_date => p_effective_date
    ,p_validation_end_date   => p_effective_date
    ,p_lookup_type           => 'APL_ASSIGN_REASON'
    ,p_lookup_code           =>  p_status_change_reason
    )
  then
   hr_utility.set_message(801, 'HR_51229_ASG_INV_AASG_CH_REAS');
   hr_utility.raise_error;
  end if;
 end if;
 --

 hr_multi_message.enable_message_list;
 --end changes for bug 7217475

 -- check whether the Person is an Applicant or an Ex-applicant
 open c1;
 fetch c1 into l_date_end ,l_date_recieved, l_application_id;
 --close c1;
 --


--  hr_multi_message.enable_message_list;


  --fnd_message.set_name ( 'PER', 'HR_6385_APP_TERM_FUT_CHANGES' );
  --fnd_message.raise_error ;
  --  hr_utility.set_message(801,'HR_6385_APP_TERM_FUT_CHANGES' );
  --  hr_utility.raise_error ;
  --fnd_message.set_token('ATTRIBUTE_NAME','ERROR');
  -- hr_multi_message.add (p_associated_column1 => 'ATTR_NAME'
   --                      , p_message_type  => hr_multi_message.g_error_msg);



 hr_utility.set_location('REVERSE_TERM_APLN - p_effective_date:'|| p_effective_date, 10);
 hr_utility.set_location('REVERSE_TERM_APLN - l_date_end:'|| l_date_end, 10);


 select effective_start_date, effective_end_date,object_version_number into l_asg_start_date,l_asg_end_date,l_ovn
 from per_all_assignments_f
 where assignment_id = p_assignment_id
 and effective_end_date = (select max(effective_end_date)
 from per_all_assignments_f
 where assignment_id = p_assignment_id );

 hr_utility.set_location('REVERSE_TERM_APLN - l_asg_end_date:'|| l_asg_end_date, 20);

   select assignment_status_type_id into l_assignment_status_id
   from per_all_assignments_f
   where assignment_id = p_assignment_id
   and effective_end_date = l_asg_end_date ;

 hr_utility.set_location('REVERSE_TERM_APLN - l_assignment_status_id:'|| l_assignment_status_id, 30);

if l_date_end is null then
  --  then the person is currently an Applicant with any flavour of persontype
   hr_utility.set_location('REVERSE_TERM_APLN - Entering:'|| l_proc, 40);
 open c2;
 fetch c2 into l_dummy;
 if c2%found then
    close c2 ;
    fnd_message.set_name ( 'PAY', 'HR_6083_APP_ASS_APPL_STAT_END' );
    app_exception.raise_exception ;
 end if;
 close c2;
-- make the data in the other tables ( namely tax records , secondary assignments statuses , letter requests )
--to be in sync with the  assignments data

 hr_utility.set_location('Entering:'|| l_proc, 50);
 hr_assignment.tidy_up_ref_int ( p_assignment_id,
                                 'FUTURE',
                                  null,
                                  l_asg_end_date,
                                  null,
                                  null,
                                 l_cost_warning ) ;
-- clean up the letter requests.
 per_app_asg_pkg.cleanup_letters
   (p_assignment_id => p_assignment_id);
    hr_utility.set_location('Entering:'|| l_proc, 60);

-- calling the IRC packages to maintain the IRC Assignment Statuses


       IRC_ASG_STATUS_API.create_irc_asg_status
           ( p_validate                   => FALSE
           , p_assignment_id              => p_assignment_id
            , p_assignment_status_type_id  => l_assignment_status_id
           , p_status_change_date         =>  p_effective_date
           , p_assignment_status_id       => l_asg_status_id
           , p_object_version_number      => l_object_version_number
	   ,p_status_change_reason         => p_status_change_reason
            );

-- now update the assignments table
-- we must lock the row before we update it

per_asg_shd.lck (p_effective_date =>l_asg_end_date ,
     p_datetrack_mode => 'CORRECTION',
     p_assignment_id  =>p_assignment_id,
     p_object_version_number =>l_ovn,
     p_validation_start_date =>l_validation_start_date,
     p_validation_end_date => l_validation_end_date);


 hr_utility.set_location('Entering:'|| l_proc, 70);

   update per_all_assignments_f
   set effective_end_date =  l_eot
   where assignment_id = p_assignment_id
      and person_id=p_person_id
      and business_group_id= p_business_group_id
      and effective_end_date = l_asg_end_date;

hr_utility.set_location(' Leaving : '||l_proc  ,80);


 else  --  CASE  2

 hr_utility.set_location('Entering:'|| l_proc, 90);

 -- Person is currently an Ex-Applicant with any falvour of Person Type
-- Check if the person is currently hired as Emp with that Assignment if so raise an error

PER_APPLICATIONS_PKG .cancel_chk_current_emp(p_person_id  => p_person_id ,
                                             p_business_group_id => p_business_group_id ,
                                              p_date_end          => l_date_end );

 hr_utility.set_location('Entering:'|| l_proc, 100);

 --Check for Future Person type changes

 open c3(l_date_end) ;
 fetch c3 into l_dummy ;
 if c3%found then
    close c3 ;
    fnd_message.set_name ( 'PER', 'HR_6385_APP_TERM_FUT_CHANGES' );
    hr_utility.set_message(801,'HR_6385_APP_TERM_FUT_CHANGES' );
    hr_multi_message.add (p_associated_column1 => 'ATTR_NAME'
                         , p_message_type  => hr_multi_message.g_error_msg);

    hr_utility.raise_error ;
 end if;
 close c3 ;

  hr_utility.set_location('Entering:'|| l_proc, 110);

-- Maintain the Person data by deleting the Ex-Appl Record and the same with PTU Data.

  DELETE FROM per_all_people_f papf
   WHERE       papf.person_id               = p_person_id
   AND         papf.business_group_id + 0   = p_Business_group_id
   AND         papf.effective_start_date    = l_date_end + 1;
--

 hr_utility.set_location('REVERSE_TERM_APLN - l_date_end:'|| l_date_end, 120);

    UPDATE  per_all_people_f papf
    SET     papf.effective_end_date  = l_eot
    WHERE   papf.person_id           = p_person_id
    AND     papf.BUSINESS_GROUP_ID + 0  = p_Business_group_id
    AND     papf.effective_end_date  = l_date_end;

     hr_utility.set_location('Entering:'|| l_proc, 130);

  hr_utility.set_location('REVERSE_TERM_APLN - l_date_recieved:'|| l_date_recieved, 140);
    hr_utility.set_location('REVERSE_TERM_APLN - l_application_id:'|| l_application_id, 140);

 open csr_ptu_row (l_date_recieved );
     fetch csr_ptu_row into l_ptu_date_end;
     close csr_ptu_row;

  hr_utility.set_location('REVERSE_TERM_APLN - l_ptu_date_end:'|| l_ptu_date_end, 150);

 hr_per_type_usage_internal.cancel_person_type_usage
     (
        p_effective_date         => l_ptu_date_end
       ,p_person_id              => p_person_id
       ,p_system_person_type     => 'EX_APL'
     );

       hr_utility.set_location('Entering:'|| l_proc, 160);

-- Make a call to the IRC packages to maintain the IRC Assignment Statuses hr_utility.set_location('PER_APPLICATIONS_PKG.maintain_irc_ass_status', 30);

irc_asg_status_api.create_irc_asg_status
                (p_validate                => FALSE,
                 p_assignment_id              => p_assignment_id,
                 p_assignment_status_type_id  => l_assignment_status_id,
                 p_status_change_date         => p_effective_date,
                 p_assignment_status_id       => l_asg_status_id,
                 p_object_version_number      => l_object_version_number,
		 p_status_change_reason         => p_status_change_reason);

hr_utility.set_location('Entering:'|| l_proc, 170);

-- make the data in the other tables ( namely tax records , secondary assignments statuses , letter requests )
--to be in sync with the  assignments data

 hr_assignment.tidy_up_ref_int ( p_assignment_id,
                                 'FUTURE',
                                  null,
                                  l_asg_end_date,
                                  null,
                                  null,
                                 l_cost_warning ) ;
-- clean up the letter requests.
hr_utility.set_location('Entering:'|| l_proc, 180);

 per_app_asg_pkg.cleanup_letters
   (p_assignment_id => p_assignment_id);

    UPDATE PER_APPLICATIONS
    SET date_end =null
    where APPLICATION_ID =l_application_id
          and person_id= p_person_id ;

-- now update the assignments table
-- we must lock the row before we update it

per_asg_shd.lck (p_effective_date =>l_asg_end_date ,
     p_datetrack_mode => 'CORRECTION',
     p_assignment_id  =>p_assignment_id,
     p_object_version_number =>l_ovn,
     p_validation_start_date =>l_validation_start_date,
     p_validation_end_date => l_validation_end_date);


   update per_all_assignments_f
   set effective_end_date =  l_eot
   where assignment_id = p_assignment_id
      and person_id=p_person_id
      and business_group_id= p_business_group_id
        and effective_end_date = l_asg_end_date;

   hr_utility.set_location('Entering:'|| l_proc, 190);
end if;
close c1;
p_return_status := hr_multi_message.get_return_status_disable;
EXCEPTION

when hr_multi_message.error_message_exist then

    p_return_status:='E';
    hr_utility.set_location(' Leaving:' || l_proc, 30);
when others then
  if c1%isopen then
   close c1;
  end if;
  p_return_status:='E';
  hr_utility.set_location('Entering:'|| l_proc, 200);
  raise; --uncommented for bug 7217475
end;
--
--
-- end of fix for bug 6008188
----------------------------------------------------------------------------
-- |----------------------< update_scl_concat_segs >------------------------|
----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure updates the hr_soft_coding_keyflex table after the flexfield
--   segments have been inserted to keep the concatenated segment field up to
--   date.
--
-- Prerequisites:
--   A row must exist in the hr_soft_coding_keyflex table for p_soft_coding_keyflex_id
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_soft_coding_keyflex_id       Yes  number   The primary key
--   p_concatenated_segments        Yes  varchar2 The concatenated segments
--
-- Post Success:
--   The row is updated
--
-- Post Failure:
--   The procedure will raise an error.
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
procedure update_scl_concat_segs
  (p_soft_coding_keyflex_id       in     number
  ,p_concatenated_segments        in     varchar2
  ) is
  --
  --
  CURSOR csr_chk_scl is
    SELECT null
      FROM 	hr_soft_coding_keyflex
     where  soft_coding_keyflex_id =  p_soft_coding_keyflex_id
       and (concatenated_segments  <> p_concatenated_segments
        or concatenated_segments is null);
  --
  l_exists  varchar2(30);
  l_proc   varchar2(72) := g_package||'update_scl_concat_segs ';
  --
  procedure update_scl_concat_segs_auto
   ( p_soft_coding_keyflex_id       in     number
    ,p_concatenated_segments        in     varchar2
   ) is
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
    CURSOR csr_scl_lock is
      SELECT null
       FROM 	hr_soft_coding_keyflex
       where  soft_coding_keyflex_id =  p_soft_coding_keyflex_id
         for update nowait;
    --
    l_exists  varchar2(30);
    l_proc    varchar2(72) := g_package||'update_scl_concat_segs_auto';
    --
  begin
    if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
    end if;
    --
    -- The outer procedure has already establish that an update is
    -- required. This sub-procedure uses an autonomous transaction
    -- to ensure that any commits do not impact the main transaction.
    -- If the row is successfully locked then continue and update the
    -- row. If the row cannot be locked then another transaction must
    -- be performing the update. So it is acceptable for this
    -- transaction to silently trap the error and continue.
    --
    -- Note: It is necessary to perform the lock test because in
    -- a batch data upload scenario multiple sessions could be
    -- attempting to insert or update the same Key Flexfield
    -- combination at the same time. Just directly updating the row,
    -- without first locking, can cause sessions to hang and reduce
    -- batch throughput.
    --
    open csr_scl_lock;
    fetch csr_scl_lock into l_exists;
    if csr_scl_lock%found then
      close csr_scl_lock;

      if g_debug then
      hr_utility.set_location(l_proc, 20);
      end if;
      --
      -- Lock obtained by this transaction, updating the concatenated
      -- segment string should be performed.
      --
      update  hr_soft_coding_keyflex
  	  set     concatenated_segments  = p_concatenated_segments
  	  where   soft_coding_keyflex_id = p_soft_coding_keyflex_id
         and (concatenated_segments   <> p_concatenated_segments
          or  concatenated_segments is null);
      --
      -- Commit this change so the change is immediately visible to
      -- other transactions. Also ensuring that it is not undone if
      -- the main transaction is rolled back. This commit is only
      -- acceptable inside an API because it is being performed inside
      -- an autonomous transaction and AOL code has previously
      -- inserted the Key Flexfield combination row in another
      -- autonomous transaction.
      commit;
    else
      close csr_scl_lock;
      rollback; -- Added for bug 3578845.
    end if;
    --
    if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 30);
    end if;

  Exception
    When HR_Api.Object_Locked then
      --
      -- This autonomous transaction was unable to lock the row.
      -- It can be assumed that another transaction has locked the
      -- row and is performing the update. Hence the error can
      -- be suppressed without raising it to the end user.
      --
      rollback; -- Added for bug 3578845.
      hr_utility.set_location('Leaving:'|| l_proc, 40);
  end update_scl_concat_segs_auto;
begin
--
  if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- First find out if it is necessary to update the concatenated
  -- segment string column. This select is being done to avoid the
  -- performance unnecessary overhead of set-up an autonomous
  -- transaction when an update is not required. Updates are only
  -- expected immediately after the combination row was first inserted.
  --
  open csr_chk_scl;
  fetch csr_chk_scl into l_exists;
  if csr_chk_scl%found then
    close csr_chk_scl;
    update_scl_concat_segs_auto
      (p_soft_coding_keyflex_id  => p_soft_coding_keyflex_id
      ,p_concatenated_segments   => p_concatenated_segments
      );
  else
    close csr_chk_scl;
  end if;
  --
 if g_debug then
  hr_utility.set_location('Leaving:'|| l_proc, 20);
 end if;
  --
end update_scl_concat_segs;
-----------------------------------------------------------------------
-- | ---------------<validate_SCL > --------------------------------| --
-----------------------------------------------------------------------
--
-- Start of fix for bug 2622747
procedure validate_SCL (
   p_validate                     in     boolean
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_concatenated_segments           out nocopy varchar2
  ,p_concat_segments              in     varchar2
  ,p_segment1                     in     varchar2
  ,p_segment2                     in     varchar2
  ,p_segment3                     in     varchar2
  ,p_segment4                     in     varchar2
  ,p_segment5                     in     varchar2
  ,p_segment6                     in     varchar2
  ,p_segment7                     in     varchar2
  ,p_segment8                     in     varchar2
  ,p_segment9                     in     varchar2
  ,p_segment10                    in     varchar2
  ,p_segment11                    in     varchar2
  ,p_segment12                    in     varchar2
  ,p_segment13                    in     varchar2
  ,p_segment14                    in     varchar2
  ,p_segment15                    in     varchar2
  ,p_segment16                    in     varchar2
  ,p_segment17                    in     varchar2
  ,p_segment18                    in     varchar2
  ,p_segment19                    in     varchar2
  ,p_segment20                    in     varchar2
  ,p_segment21                    in     varchar2
  ,p_segment22                    in     varchar2
  ,p_segment23                    in     varchar2
  ,p_segment24                    in     varchar2
  ,p_segment25                    in     varchar2
  ,p_segment26                    in     varchar2
  ,p_segment27                    in     varchar2
  ,p_segment28                    in     varchar2
  ,p_segment29                    in     varchar2
  ,p_segment30                    in     varchar2
  )
 AS
  --
  -- Local Variables
  --
  --
  l_proc                         VARCHAR2(72) := g_package||'validate_scl';
  l_soft_coding_keyflex_id per_all_assignments_f.soft_coding_keyflex_id%TYPE := p_soft_coding_keyflex_id;
  l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_old_conc_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_flex_num               fnd_id_flex_segments.id_flex_num%TYPE;
  l_scl_null_ind               number(1) := 0;

  l_scl_segment1               varchar2(60) := p_segment1;
  l_scl_segment2               varchar2(60) := p_segment2;
  l_scl_segment3               varchar2(60) := p_segment3;
  l_scl_segment4               varchar2(60) := p_segment4;
  l_scl_segment5               varchar2(60) := p_segment5;
  l_scl_segment6               varchar2(60) := p_segment6;
  l_scl_segment7               varchar2(60) := p_segment7;
  l_scl_segment8               varchar2(60) := p_segment8;
  l_scl_segment9               varchar2(60) := p_segment9;
  l_scl_segment10              varchar2(60) := p_segment10;
  l_scl_segment11              varchar2(60) := p_segment11;
  l_scl_segment12              varchar2(60) := p_segment12;
  l_scl_segment13              varchar2(60) := p_segment13;
  l_scl_segment14              varchar2(60) := p_segment14;
  l_scl_segment15              varchar2(60) := p_segment15;
  l_scl_segment16              varchar2(60) := p_segment16;
  l_scl_segment17              varchar2(60) := p_segment17;
  l_scl_segment18              varchar2(60) := p_segment18;
  l_scl_segment19              varchar2(60) := p_segment19;
  l_scl_segment20              varchar2(60) := p_segment20;
  l_scl_segment21              varchar2(60) := p_segment21;
  l_scl_segment22              varchar2(60) := p_segment22;
  l_scl_segment23              varchar2(60) := p_segment23;
  l_scl_segment24              varchar2(60) := p_segment24;
  l_scl_segment25              varchar2(60) := p_segment25;
  l_scl_segment26              varchar2(60) := p_segment26;
  l_scl_segment27              varchar2(60) := p_segment27;
  l_scl_segment28              varchar2(60) := p_segment28;
  l_scl_segment29              varchar2(60) := p_segment29;
  l_scl_segment30              varchar2(60) := p_segment30;

  --
  -- Cursor Defination.
  --
  cursor csr_get_soft_coding_keyflex is
    select asg.soft_coding_keyflex_id
      from per_all_assignments_f asg
     where asg.assignment_id = p_assignment_id
       and p_effective_date  between asg.effective_start_date
                           and     asg.effective_end_date;

  --
  cursor csr_scl_idsel is
    select plr.rule_mode                       id_flex_num
    from   pay_legislation_rules               plr,
           per_business_groups_perf            pgr
    where  plr.legislation_code                = pgr.legislation_code
    and    pgr.business_group_id               = p_business_group_id
    and    plr.rule_type                       = 'S'
    and    exists
          (select 1
           from   fnd_segment_attribute_values fsav
           where  fsav.id_flex_num             = plr.rule_mode
           and    fsav.application_id          = 800
           and    fsav.id_flex_code            = 'SCL'
           and    fsav.segment_attribute_type  = 'ASSIGNMENT'
           and    fsav.attribute_value         = 'Y')
    and    exists
          (select 1
           from   pay_legislation_rules        plr2
           where  plr2.legislation_code        = plr.legislation_code
           and    plr2.rule_type               = 'SDL'
           and    plr2.rule_mode               = 'A') ;
  --
  --
  cursor c_scl_segments is
     select concatenated_segments,
	    segment1,
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
     from   hr_soft_coding_keyflex
     where  soft_coding_keyflex_id = l_soft_coding_keyflex_id;

--
--  Start of Fix for Bug 2643451
     l_old_conc_segs      hr_soft_coding_keyflex.concatenated_segments%TYPE;
     l_old_scl_segments   c_scl_segments%rowtype;
--  End of Fix for Bug 2643451
--


  BEGIN

 if g_debug then
 hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;

 l_old_conc_segments:=p_concat_segments;

  --
  -- Issue a savepoint.
  --
  savepoint validate_SCL;
  --

  --
  -- If SCL ID is passed then
  -- Select Segments from SCL table
  --

    if l_soft_coding_keyflex_id is not null
    then
       l_scl_null_ind := 1;
       open c_scl_segments;
       fetch c_scl_segments into l_old_conc_segs,
				 l_scl_segment1,
                                 l_scl_segment2,
                                 l_scl_segment3,
                                 l_scl_segment4,
                                 l_scl_segment5,
                                 l_scl_segment6,
                                 l_scl_segment7,
                                 l_scl_segment8,
                                 l_scl_segment9,
                                 l_scl_segment10,
                                 l_scl_segment11,
                                 l_scl_segment12,
                                 l_scl_segment13,
                                 l_scl_segment14,
                                 l_scl_segment15,
                                 l_scl_segment16,
                                 l_scl_segment17,
                                 l_scl_segment18,
                                 l_scl_segment19,
                                 l_scl_segment20,
                                 l_scl_segment21,
                                 l_scl_segment22,
                                 l_scl_segment23,
                                 l_scl_segment24,
                                 l_scl_segment25,
                                 l_scl_segment26,
                                 l_scl_segment27,
                                 l_scl_segment28,
                                 l_scl_segment29,
                                 l_scl_segment30;
    close c_scl_segments;
  else
    l_scl_null_ind := 0;
 if g_debug then
    hr_utility.set_location(l_proc, 16);
 end if;
  end if;




 if l_scl_null_ind = 0
 then
       open csr_get_soft_coding_keyflex;
         fetch csr_get_soft_coding_keyflex into l_soft_coding_keyflex_id;


 if g_debug then
        hr_utility.set_location('SCL ID' ||l_soft_coding_keyflex_id, 10);
 end if;
       --
       if csr_get_soft_coding_keyflex%NOTFOUND then
         close csr_get_soft_coding_keyflex;
         hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
         hr_utility.raise_error;
 --
 -- Start of Fix for bug 2643451
 --
     else
       if l_soft_coding_keyflex_id is not null then
        open c_scl_segments;
        fetch c_scl_segments into l_old_scl_segments;
        close c_scl_segments;
       end if;
 --
 -- End of Fix for Bug 2643451
 --
     end if;

       --
       close csr_get_soft_coding_keyflex;


    -- Start of Fix for Bug 2643451
    -- Start of Fix for   Bug 2548555
     --
     if   nvl(l_scl_segment1,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment1 ,hr_api.g_varchar2)
       or nvl(l_scl_segment2,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment2 ,hr_api.g_varchar2)
       or nvl(l_scl_segment3,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment3 ,hr_api.g_varchar2)
       or nvl(l_scl_segment4,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment4 ,hr_api.g_varchar2)
       or nvl(l_scl_segment5,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment5 ,hr_api.g_varchar2)
       or nvl(l_scl_segment6,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment6 ,hr_api.g_varchar2)
       or nvl(l_scl_segment7,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment7 ,hr_api.g_varchar2)
       or nvl(l_scl_segment8,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment8 ,hr_api.g_varchar2)
       or nvl(l_scl_segment9,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment9 ,hr_api.g_varchar2)
       or nvl(l_scl_segment10,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment10 ,hr_api.g_varchar2)
       or nvl(l_scl_segment11,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment11 ,hr_api.g_varchar2)
       or nvl(l_scl_segment12,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment12 ,hr_api.g_varchar2)
       or nvl(l_scl_segment13,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment13 ,hr_api.g_varchar2)
       or nvl(l_scl_segment14,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment14 ,hr_api.g_varchar2)
       or nvl(l_scl_segment15,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment15 ,hr_api.g_varchar2)
       or nvl(l_scl_segment16,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment16 ,hr_api.g_varchar2)
       or nvl(l_scl_segment17,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment17 ,hr_api.g_varchar2)
       or nvl(l_scl_segment18,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment18 ,hr_api.g_varchar2)
       or nvl(l_scl_segment19,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment19 ,hr_api.g_varchar2)
       or nvl(l_scl_segment20,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment20 ,hr_api.g_varchar2)
       or nvl(l_scl_segment21,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment21 ,hr_api.g_varchar2)
       or nvl(l_scl_segment22,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment22 ,hr_api.g_varchar2)
       or nvl(l_scl_segment23,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment23 ,hr_api.g_varchar2)
       or nvl(l_scl_segment24,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment24 ,hr_api.g_varchar2)
       or nvl(l_scl_segment25,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment25 ,hr_api.g_varchar2)
       or nvl(l_scl_segment26,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment26 ,hr_api.g_varchar2)
       or nvl(l_scl_segment27,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment27 ,hr_api.g_varchar2)
       or nvl(l_scl_segment28,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment28 ,hr_api.g_varchar2)
       or nvl(l_scl_segment29,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment29 ,hr_api.g_varchar2)
       or nvl(l_scl_segment30,hr_api.g_varchar2) <> nvl(l_old_scl_segments.segment30 ,hr_api.g_varchar2)
       -- bug 944911
       -- changed p_concatenated_segments to p_concat_segments
        or nvl(p_concat_segments,hr_api.g_varchar2) <> nvl(l_old_scl_segments.concatenated_segments ,hr_api.g_varchar2)
 --
 -- End of Fix for Bug 2548555
 -- End of Fix for Bug 2643451
 --


       then
           open csr_scl_idsel;
           fetch csr_scl_idsel into l_flex_num;

 if g_debug then
           hr_utility.set_location('SCL_ID_SEL'||l_flex_num, 10);
 end if;
           --
           if csr_scl_idsel%NOTFOUND then
              close csr_scl_idsel;

              if   l_scl_segment1 is not null
                or l_scl_segment2 is not null
                or l_scl_segment3 is not null
                or l_scl_segment4 is not null
                or l_scl_segment5 is not null
                or l_scl_segment6 is not null
                or l_scl_segment7 is not null
                or l_scl_segment8 is not null
                or l_scl_segment9 is not null
                or l_scl_segment10 is not null
                or l_scl_segment11 is not null
                or l_scl_segment12 is not null
                or l_scl_segment13 is not null
                or l_scl_segment14 is not null
                or l_scl_segment15 is not null
                or l_scl_segment16 is not null
                or l_scl_segment17 is not null
                or l_scl_segment18 is not null
                or l_scl_segment19 is not null
                or l_scl_segment20 is not null
                or l_scl_segment21 is not null
                or l_scl_segment22 is not null
                or l_scl_segment23 is not null
                or l_scl_segment24 is not null
                or l_scl_segment25 is not null
                or l_scl_segment26 is not null
                or l_scl_segment27 is not null
                or l_scl_segment28 is not null
                or l_scl_segment29 is not null
                or l_scl_segment30 is not null
                or p_concat_segments is not null
              then
              --
              hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
              hr_utility.set_message_token('PROCEDURE', l_proc);
              hr_utility.set_message_token('STEP','6');
              hr_utility.raise_error;
              end if;
           else -- csr_scl_idsel is found
              close csr_scl_idsel;
              --
              -- Process Logic
              --
              --
              -- Update or select the soft_coding_keyflex_id
              --
              hr_kflex_utility.upd_or_sel_keyflex_comb
              (p_appl_short_name        => 'PER'
              ,p_flex_code              => 'SCL'
              ,p_flex_num               => l_flex_num
              ,p_segment1               => l_scl_segment1
              ,p_segment2               => l_scl_segment2
              ,p_segment3               => l_scl_segment3
              ,p_segment4               => l_scl_segment4
              ,p_segment5               => l_scl_segment5
              ,p_segment6               => l_scl_segment6
              ,p_segment7               => l_scl_segment7
              ,p_segment8               => l_scl_segment8
              ,p_segment9               => l_scl_segment9
              ,p_segment10              => l_scl_segment10
              ,p_segment11              => l_scl_segment11
              ,p_segment12              => l_scl_segment12
              ,p_segment13              => l_scl_segment13
              ,p_segment14              => l_scl_segment14
              ,p_segment15              => l_scl_segment15
              ,p_segment16              => l_scl_segment16
              ,p_segment17              => l_scl_segment17
              ,p_segment18              => l_scl_segment18
              ,p_segment19              => l_scl_segment19
              ,p_segment20              => l_scl_segment20
              ,p_segment21              => l_scl_segment21
              ,p_segment22              => l_scl_segment22
              ,p_segment23              => l_scl_segment23
              ,p_segment24              => l_scl_segment24
              ,p_segment25              => l_scl_segment25
              ,p_segment26              => l_scl_segment26
              ,p_segment27              => l_scl_segment27
              ,p_segment28              => l_scl_segment28
              ,p_segment29              => l_scl_segment29
              ,p_segment30              => l_scl_segment30
              ,p_concat_segments_in     => l_old_conc_segments
              ,p_ccid                   => l_soft_coding_keyflex_id
              ,p_concat_segments_out    => l_concatenated_segments
              );
              --
              -- update the combinations column
              --
 if g_debug then
              hr_utility.set_location(l_proc, 17);
 end if;
              update_scl_concat_segs
              (p_soft_coding_keyflex_id  => l_soft_coding_keyflex_id
              ,p_concatenated_segments   => l_concatenated_segments
              );
             --
           end if; -- csr_scl_idsel%NOTFOUND
           --
       end if;  -- l_scl_segment1 <> hr_api.g_varchar2
       --
 end if; -- l_soft_coding_key_flex_id is null

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

 --
 -- Setting Output Variables
 --
  p_concatenated_segments        := l_concatenated_segments;
  p_soft_coding_keyflex_id       := l_soft_coding_keyflex_id;


EXCEPTION
  when hr_api.validate_enabled then
     ROLLBACK TO validate_SCL;

     p_concatenated_segments  := l_old_conc_segments;

     if l_scl_null_ind = 0
     then
       p_soft_coding_keyflex_id  := null;
     end if;

  when others then
    --
    -- A validation or unexpected error has occurred

    IF csr_get_soft_coding_keyflex%isopen then
       close csr_get_soft_coding_keyflex;
    END IF;

    IF 	csr_scl_idsel%isOpen then
       close csr_scl_idsel;
    END IF;

    IF 	c_scl_segments%isOpen then
       close c_scl_segments;
    END IF;

    RAISE;

END validate_SCL;

-- End of fix for Bug 2622747

-- -----------------------------------------------------------------------------
-- |--------------------------< last_apl_asg >---------------------------------|
-- -----------------------------------------------------------------------------
--

-- {Start of Comments}
--
-- Description:
--   Determines if the assignment is the last applicant assignment on a given
--   date
--
-- Prerequisites:
--   None
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_assignment_id                Yes  number   Assignment id
--   p_effective_date               Yes  date     Effective date
--
-- Post Success:
--   A boolean indicator signifying if the assignment is the last applicant
--   assignment on the effective date is returned.
--
-- Post Failure:
--   An error is raised
--
-- Access Status:
--   Internal Development Use Only
--
-- {End of Comments}
--
FUNCTION last_apl_asg
  (p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN BOOLEAN
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) ;
  --
  l_last_apl_asg                 BOOLEAN;
  --
  -- Local cursors
  --
  CURSOR csr_last_apl_asg
    (p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
    ,p_effective_date               IN     DATE
    )
  IS
    SELECT as2.assignment_id
      FROM per_all_assignments_f as2
          ,per_all_assignments_f as1
     WHERE as2.person_id = as1.person_id
       AND as2.assignment_type = as1.assignment_type
       AND csr_last_apl_asg.p_effective_date BETWEEN as2.effective_start_date
                                                 AND as2.effective_end_date
       AND as2.assignment_id <> as1.assignment_id
       AND as1.assignment_id = csr_last_apl_asg.p_assignment_id;
  l_last_apl_asg_rec             csr_last_apl_asg%ROWTYPE;
--
BEGIN
  --
 if g_debug then
  l_proc := g_package||'last_apl_asg';
  hr_utility.set_location('Entering:'||l_proc,10);
 end if;
  --
  -- If another applicant assignment exists on this date
  -- then this is NOT the last applicant assignment
  --
  OPEN csr_last_apl_asg
    (p_assignment_id                => p_assignment_id
    ,p_effective_date               => p_effective_date
    );
  FETCH csr_last_apl_asg INTO l_last_apl_asg_rec;
  l_last_apl_asg := csr_last_apl_asg%NOTFOUND;
  CLOSE csr_last_apl_asg;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,10);
 end if;
  --
  RETURN(l_last_apl_asg);
--
EXCEPTION
  WHEN OTHERS
  THEN
    IF csr_last_apl_asg%ISOPEN
    THEN
      CLOSE csr_last_apl_asg;
    END IF;
    RAISE;
--
END last_apl_asg;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< activate_emp_asg >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure activate_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date     -- default value removed. Bug 2364484
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_change_reason                in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date             date;
  --
  -- Out variables
  --
  l_effective_start_date       per_all_assignments_f.effective_start_date%TYPE;
  l_object_version_number      per_all_assignments_f.object_version_number%TYPE;
  l_effective_end_date         per_all_assignments_f.effective_end_date%TYPE;
  --
  lv_object_version_number     number := p_object_version_number ;
  --
  l_proc                       varchar2(72);
  --
begin
 if g_debug then
  l_proc := g_package||'activate_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  --
  l_object_version_number := p_object_version_number;
  --
  -- Corrected assignment from trunc(l_effective_date) to
  -- trunc(p_effective_date). RMF 25-Aug-97.
  --
  l_effective_date        := trunc(p_effective_date);
  --
  -- Issue a savepoint.
  --
  savepoint activate_emp_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Validation in addition to Table Handlers
  --
  -- None required.
  --
  -- Process Logic
  --
  --
  -- Start of API User Hook for the before hook of activate_emp_asg.
  --
  begin
     hr_assignment_bk6.activate_emp_asg_b
          (p_effective_date               => l_effective_date
          ,p_datetrack_update_mode        => p_datetrack_update_mode
          ,p_assignment_id                => p_assignment_id
          ,p_change_reason                => p_change_reason
          ,p_object_version_number        => p_object_version_number
          ,p_assignment_status_type_id    => p_assignment_status_type_id
          );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'ACTIVATE_EMP_ASG',
          p_hook_type         => 'BP'
         );
  end;
  --
  -- Update employee assignment.
  --
  hr_assignment_internal.update_status_type_emp_asg
    (p_effective_date               => l_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_change_reason                => p_change_reason
    ,p_object_version_number        => l_object_version_number
    ,p_expected_system_status       => 'ACTIVE_ASSIGN'
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Start of API User Hook for the after hook of activate_emp_asg.
  --
  begin
     hr_assignment_bk6.activate_emp_asg_a
           (p_effective_date               => l_effective_date
           ,p_datetrack_update_mode        => p_datetrack_update_mode
           ,p_assignment_id                => p_assignment_id
           ,p_change_reason                => p_change_reason
           ,p_object_version_number        => l_object_version_number
           ,p_assignment_status_type_id    => p_assignment_status_type_id
           ,p_effective_start_date         => l_effective_start_date
           ,p_effective_end_date           => l_effective_end_date
           );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'ACTIVATE_EMP_ASG',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of activate_emp_asg.
  --
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
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 100);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO activate_emp_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := p_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number   := lv_object_version_number ;
    p_effective_start_date    := null ;
    p_effective_end_date      := null ;

    ROLLBACK TO activate_emp_asg;
    raise;
    --
    -- End of fix.
    --
end activate_emp_asg;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< activate_cwk_asg >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure activate_cwk_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_change_reason                in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date             date;
  --
  -- Out variables
  --
  l_effective_start_date       per_all_assignments_f.effective_start_date%TYPE;
  l_object_version_number      per_all_assignments_f.object_version_number%TYPE;
  l_effective_end_date         per_all_assignments_f.effective_end_date%TYPE;
  --
  lv_object_version_number     number := p_object_version_number ;
  --
  l_proc                       varchar2(72);
  --
begin
 if g_debug then
  l_proc := g_package||'activate_cwk_asg';
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  --
  l_object_version_number := p_object_version_number;
  --
  -- Corrected assignment from trunc(l_effective_date) to
  -- trunc(p_effective_date). RMF 25-Aug-97.
  --
  l_effective_date        := trunc(p_effective_date);
  --
  -- Issue a savepoint.
  --
  savepoint activate_cwk_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Validation in addition to Table Handlers
  --
  -- None required.
  --
  -- Process Logic
  --
  --
  -- Start of API User Hook for the before hook of activate_cwk_asg.
  --
  begin
     hr_assignment_bkj.activate_cwk_asg_b
          (p_effective_date               => l_effective_date
          ,p_datetrack_update_mode        => p_datetrack_update_mode
          ,p_assignment_id                => p_assignment_id
          ,p_change_reason                => p_change_reason
          ,p_object_version_number        => p_object_version_number
          ,p_assignment_status_type_id    => p_assignment_status_type_id
          );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'ACTIVATE_CWK_ASG',
          p_hook_type         => 'BP'
         );
  end;
  --
  -- Update contingent worker assignment.
  --
  hr_assignment_internal.update_status_type_cwk_asg
    (p_effective_date               => l_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_change_reason                => p_change_reason
    ,p_object_version_number        => l_object_version_number
    ,p_expected_system_status       => 'ACTIVE_CWK'
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Start of API User Hook for the after hook of activate_cwk_asg.
  --
  begin
     hr_assignment_bkj.activate_cwk_asg_a
           (p_effective_date               => l_effective_date
           ,p_datetrack_update_mode        => p_datetrack_update_mode
           ,p_assignment_id                => p_assignment_id
           ,p_change_reason                => p_change_reason
           ,p_object_version_number        => l_object_version_number
           ,p_assignment_status_type_id    => p_assignment_status_type_id
           ,p_effective_start_date         => l_effective_start_date
           ,p_effective_end_date           => l_effective_end_date
           );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'ACTIVATE_CWK_ASG',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of activate_cwk_asg.
  --
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
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 100);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO activate_cwk_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := p_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number := lv_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    ROLLBACK TO activate_cwk_asg;
    raise;
    --
    -- End of fix.
    --
end activate_cwk_asg;
--
-- ----------------------------------------------------------------------------
-- |---------------------< actual_termination_cwk_asg >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure actual_termination_cwk_asg
  (p_validate                     in     boolean
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_assignment_status_type_id    in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_pay_proposal_warning            out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_asg_future_changes_warning boolean := FALSE;
  l_pay_proposal_warning       boolean := FALSE;
  l_effective_end_date         per_all_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_all_assignments_f.effective_start_date%TYPE;
  l_entries_changed_warning    varchar2(1) := 'N';
  l_object_version_number      per_all_assignments_f.object_version_number%TYPE;
  --
  l_assignment_status_type_id
                               per_all_assignments_f.assignment_status_type_id%TYPE;
  l_assignment_type            per_all_assignments_f.assignment_type%TYPE;
  l_asg_business_group_id      per_all_assignments_f.business_group_id%TYPE;
  l_exists                     varchar2(1);
  l_last_standard_process_date
                       per_periods_of_service.last_standard_process_date%TYPE;
  l_actual_termination_date
		       per_periods_of_service.actual_termination_date%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_payroll_id                 per_all_assignments_f.payroll_id%TYPE;
  l_per_system_status      per_assignment_status_types.per_system_status%TYPE;
  l_primary_flag               per_all_assignments_f.primary_flag%TYPE;
  l_proc                       varchar2(72)
                               := g_package || 'actual_termination_cwk_asg';
  --
  lv_object_version_number     number := p_object_version_number ;
  --
  cursor csr_get_asg_details is
    select asg.assignment_type
         , asg.payroll_id
         , asg.primary_flag
         , bus.business_group_id
         , bus.legislation_code
      from per_all_assignments_f   asg
	     , per_business_groups_perf bus
     where asg.assignment_id         = p_assignment_id
       and l_actual_termination_date between asg.effective_start_date
                                     and     asg.effective_end_date
       and bus.business_group_id+0    = asg.business_group_id;
  --
  cursor csr_invalid_term_assign is
    select null
      from per_all_assignments_f           asg
         , per_assignment_status_types ast
     where asg.assignment_id             =  p_assignment_id
       and asg.effective_end_date        >= l_actual_termination_date
       and ast.assignment_status_type_id =  asg.assignment_status_type_id
       and ast.per_system_status         =  'TERM_CWK_ASG';
  --
  cursor csr_get_period_end_date is
    select tpe.end_date
      from per_time_periods tpe
     where tpe.payroll_id            = l_payroll_id
       and l_actual_termination_date between tpe.start_date
                                     and     tpe.end_date;
  --
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  l_assignment_status_type_id := p_assignment_status_type_id;
  l_object_version_number     := p_object_version_number;
  l_actual_termination_date   := trunc(p_actual_termination_date);
  --
  -- Issue a savepoint.
  --
  savepoint actual_termination_cwk_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Validation in addition to Table Handlers
  --
  -- Get assignment and business group details for validation.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'assignment_id'
     ,p_argument_value => p_assignment_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'actual_termination_date'
     ,p_argument_value => l_actual_termination_date
     );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  open  csr_get_asg_details;
  fetch csr_get_asg_details
   into l_assignment_type
      , l_payroll_id
      , l_primary_flag
      , l_asg_business_group_id
      , l_legislation_code;
  --
  if csr_get_asg_details%NOTFOUND
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 30);
 end if;
    --
    close csr_get_asg_details;
    --
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_asg_details;
  --
  -- Start of API User Hook for the before hook of actual_termination_cwk_asg.
  --
  begin
     hr_assignment_bkk.actual_termination_cwk_asg_b
       (p_assignment_id                 =>  p_assignment_id
       ,p_object_version_number         =>  p_object_version_number
       ,p_actual_termination_date       =>  l_actual_termination_date
       ,p_assignment_status_type_id     =>  p_assignment_status_type_id
       ,p_business_group_id             =>  l_asg_business_group_id
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'ACTUAL_TERMINATION_CWK_ASG',
          p_hook_type         => 'BP'
         );
  end;
  --
  -- End of API User Hook for the before hook of actual_termination_cwk_asg.
  --
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;
  --
  -- The assignment must not be a primary assignment.
  --
  if l_primary_flag <> 'N'
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 50);
 end if;
    --
    hr_utility.set_message(801,'HR_7999_ASG_INV_PRIM_ASG');
    hr_utility.raise_error;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 60);
 end if;
  --
  -- The assignment must be a contingent worker assignment.
  --
  if l_assignment_type <> 'C'
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 70);
 end if;
    --
    hr_utility.set_message('PER','HR_289616_ASG_NOT_CWK');
    hr_utility.raise_error;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 80);
 end if;
  --
  -- The assignment status type must not already be TERM_CWK_ASSIGN on
  -- or after the actual termination date.
  --
  open  csr_invalid_term_assign;
  fetch csr_invalid_term_assign
   into l_exists;
  --
  if csr_invalid_term_assign%FOUND
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 90);
 end if;
    --
    close csr_invalid_term_assign;
    --
    hr_utility.set_message('PER','HR_289617_ASG_ALREADY_TERM');
    hr_utility.raise_error;
  end if;
  --
  close csr_invalid_term_assign;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 100);
 end if;
  --
  -- Process Logic
  --
  -- If p_assignment_status_type_id is g_number then derive it's default value,
  -- otherwise validate it.
  --
  per_asg_bus1.chk_assignment_status_type
    (p_assignment_status_type_id => l_assignment_status_type_id
    ,p_business_group_id         => l_asg_business_group_id
    ,p_legislation_code          => l_legislation_code
    ,p_expected_system_status    => 'TERM_ASSIGN'  --Fix for bug 8337789.
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 110);
 end if;
  --
  -- Derive the last standard process date.
  --
  -- Bug 1711085. VS. 27-MAR-01. Commented out the code associated with
  -- disabling last_standard_process  for US legislature.
  --
  -- if l_legislation_code = 'US'
  -- then
    --
 if g_debug then
     hr_utility.set_location(l_proc, 120);
 end if;
    --
    -- l_last_standard_process_date := l_actual_termination_date;
  -- else
    --
 if g_debug then
    hr_utility.set_location(l_proc, 130);
 end if;
    --
    if l_payroll_id is not null
    then
      --
 if g_debug then
      hr_utility.set_location(l_proc, 140);
 end if;
      --
      -- Assignment is assigned to a payroll, so set the last standard process
      -- to date to the payroll's period end date as of the actual termination
      -- date.
      --
      open  csr_get_period_end_date;
      fetch csr_get_period_end_date
       into l_last_standard_process_date;
      --
      if csr_get_period_end_date%NOTFOUND then
        --
 if g_debug then
        hr_utility.set_location(l_proc, 150);
 end if;
        --
        -- No payroll period found for the actual termination date.
        --
        close csr_get_period_end_date;
        --
        hr_utility.set_message(801,'HR_51003_ASG_INV_NO_TERM_PRD');
        hr_utility.raise_error;
      end if;
      --
      close csr_get_period_end_date;
      --
 if g_debug then
      hr_utility.set_location(l_proc, 160);
 end if;
    else
      --
 if g_debug then
      hr_utility.set_location(l_proc, 170);
 end if;
      --
      -- Assignment is not assigned to a payroll, so set the last standard
      -- process date to the actual termination date.
      --
      l_last_standard_process_date := l_actual_termination_date;
    end if;
  -- end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 180);
 end if;
  --
  -- Call the business support process to update assignment and maintain the
  -- element entries. We call this procedure for contingent workers
  -- because they are processed in the same way as employees.
  --
  hr_assignment_internal.actual_term_cwk_asg
    (p_assignment_id              => p_assignment_id
    ,p_object_version_number      => l_object_version_number
    ,p_actual_termination_date    => l_actual_termination_date
    ,p_last_standard_process_date => l_last_standard_process_date
    ,p_assignment_status_type_id  => l_assignment_status_type_id
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    ,p_asg_future_changes_warning => l_asg_future_changes_warning
    ,p_entries_changed_warning    => l_entries_changed_warning
    ,p_pay_proposal_warning       => l_pay_proposal_warning
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 190);
 end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  --
  -- Start of API User Hook for the after hook of actual_termination_cwk_asg.
  -- Local vars are passed in for all OUT parms because the hook needs to
  -- be placed before the validate check and therefore before the code that
  -- sets all out parms.
  --
  begin
     hr_assignment_bkk.actual_termination_cwk_asg_a
       (p_assignment_id                 =>  p_assignment_id
       ,p_object_version_number         =>  l_object_version_number
       ,p_actual_termination_date       =>  l_actual_termination_date
       ,p_assignment_status_type_id     =>  p_assignment_status_type_id
       ,p_effective_start_date          =>  l_effective_start_date
       ,p_effective_end_date            =>  l_effective_end_date
       ,p_asg_future_changes_warning    =>  l_asg_future_changes_warning
       ,p_entries_changed_warning       =>  l_entries_changed_warning
       ,p_pay_proposal_warning          =>  l_pay_proposal_warning
       ,p_business_group_id             =>  l_asg_business_group_id
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'ACTUAL_TERMINATION_CWK_ASG',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of actual_termination_cwk_asg.
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_asg_future_changes_warning := l_asg_future_changes_warning;
  p_effective_end_date         := l_effective_end_date;
  p_effective_start_date       := l_effective_start_date;
  p_entries_changed_warning    := l_entries_changed_warning;
  p_pay_proposal_warning       := l_pay_proposal_warning;
  p_object_version_number      := l_object_version_number;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 200);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO actual_termination_cwk_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_asg_future_changes_warning := l_asg_future_changes_warning;
    p_effective_end_date         := null;
    p_effective_start_date       := null;
    p_entries_changed_warning    := l_entries_changed_warning;
    p_pay_proposal_warning       := l_pay_proposal_warning;
    p_object_version_number      := p_object_version_number;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number := lv_object_version_number;
    p_effective_start_date       := null ;
    p_effective_end_date         := null ;
    p_asg_future_changes_warning  := null ;
    p_entries_changed_warning     := null ;
    p_pay_proposal_warning        := null ;

    ROLLBACK TO actual_termination_cwk_asg;
    raise;
    --
end actual_termination_cwk_asg;
--
-- ----------------------------------------------------------------------------
-- |------------------------< final_process_cwk_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure final_process_cwk_asg
  (p_validate                     in     boolean
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_final_process_date           in     date
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_asg_future_changes_warning boolean := FALSE;
  l_effective_end_date         per_all_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_all_assignments_f.effective_start_date%TYPE;
  l_entries_changed_warning    varchar2(1) := 'N';
  l_object_version_number      per_all_assignments_f.object_version_number%TYPE;
  l_org_now_no_manager_warning boolean := FALSE;
  --
  l_assignment_type            per_all_assignments_f.assignment_type%TYPE;
  l_primary_flag               per_all_assignments_f.primary_flag%TYPE;
  l_proc                       varchar2(72)
                                     := g_package || 'final_process_cwk_asg';
  l_actual_termination_date    date;
  l_final_process_date         date;
  l_max_asg_end_date           date;
  --
  lv_object_version_number     number := p_object_version_number ;
  --
  cursor csr_get_derived_details is
    select asg.assignment_type
         , asg.primary_flag
      from per_all_assignments_f      asg
     where asg.assignment_id        = p_assignment_id
       and l_final_process_date     between asg.effective_start_date
                                    and     asg.effective_end_date;
  --
  cursor csr_valid_term_assign is
    select min(asg.effective_start_date) - 1
      from per_all_assignments_f           asg
     where asg.assignment_id             = p_assignment_id
       and exists ( select null
		    from per_assignment_status_types ast
		    where ast.assignment_status_type_id
		     = asg.assignment_status_type_id
                     and ast.per_system_status = 'TERM_CWK_ASG');

--
  cursor csr_invalid_term_assign is
    select max(asg.effective_end_date)
      from per_all_assignments_f           asg
     where asg.assignment_id      = p_assignment_id
       and exists ( select null
		    from per_assignment_status_types ast
		    where ast.assignment_status_type_id
		     = asg.assignment_status_type_id
                     and ast.per_system_status = 'TERM_CWK_ASG');

--
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  l_object_version_number := p_object_version_number;
  l_final_process_date    := trunc(p_final_process_date);
  --
  -- Issue a savepoint.
  --
  savepoint final_process_cwk_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Validation in addition to Table Handlers
  --
  -- Get assignment and business group details for validation.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'assignment_id'
     ,p_argument_value => p_assignment_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'final_process_date'
     ,p_argument_value => l_final_process_date
     );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  open  csr_get_derived_details;
  fetch csr_get_derived_details
   into l_assignment_type
      , l_primary_flag;
  --
  if csr_get_derived_details%NOTFOUND
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 30);
 end if;
    --
    close csr_get_derived_details;
    --
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;
  --
  -- Start of API User Hook for the before hook of final_process_cwk_asg.
  --
  begin
     hr_assignment_bkh.final_process_cwk_asg_b
       (p_assignment_id                 =>  p_assignment_id
       ,p_object_version_number         =>  p_object_version_number
       ,p_final_process_date            =>  l_final_process_date
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'FINAL_PROCESS_CWK_ASG',
          p_hook_type         => 'BP'
         );
  end;
  --
  --
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;
  --
  -- The assignment must not be a primary assignment.
  --
  if l_primary_flag <> 'N'
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 50);
 end if;
    --
    hr_utility.set_message(801,'HR_7999_ASG_INV_PRIM_ASG');
    hr_utility.raise_error;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 60);
 end if;
  --
  -- The assignment must be an contingent worker assignment.
  --
  if l_assignment_type <> 'C'
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 70);
 end if;
    --
    hr_utility.set_message('PER','HR_289616_ASG_NOT_CWK');
    hr_utility.raise_error;
  end if;

  -- Ensure that the assignment has not been terminated previously

  --
  open  csr_invalid_term_assign;
  fetch csr_invalid_term_assign
   into l_max_asg_end_date;
  close csr_invalid_term_assign;

  --
  if l_max_asg_end_date <> hr_api.g_eot
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 90);
 end if;
    --
    hr_utility.set_message(801,'HR_7962_PDS_INV_FP_CHANGE');
    hr_utility.raise_error;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 80);
 end if;
  --
  -- Ensure that the the final process date is on or after the actual
  -- termination date by checking that the assignment status is
  -- TERM_CWK_ASG for the day after the final process date.
  --
    --Fix for bug 8337789 starts here.
/*  open  csr_valid_term_assign;
  fetch csr_valid_term_assign
   into l_actual_termination_date;
  close csr_valid_term_assign;

  --
  if l_actual_termination_date is null
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 90);
 end if;
    --
    hr_utility.set_message(801,'HR_51007_ASG_INV_NOT_ACT_TERM');
    hr_utility.raise_error;
  end if;
  */

 l_actual_termination_date:=l_final_process_date;

  --Fix for bug 8337789 ends here.

  if l_final_process_date < l_actual_termination_date then

 if g_debug then
    hr_utility.set_location(l_proc, 95);
 end if;

    -- This error message has been set temporarily

    hr_utility.set_message(801,'HR_7963_PDS_INV_FP_BEFORE_ATT');
    hr_utility.raise_error;
  end if;
  --
  --
 if g_debug then
  hr_utility.set_location(l_proc, 100);
 end if;
  --
  -- Process Logic
  --
  -- Call the business support process to update assignment and maintain the
  -- element entries. Here we call the emp procedure because processing
  -- for a contingent worker is identical from this point.
  --
  hr_assignment_internal.final_process_cwk_asg
    (p_assignment_id              => p_assignment_id
    ,p_object_version_number      => l_object_version_number
    ,p_final_process_date         => l_final_process_date
    ,p_actual_termination_date    => l_actual_termination_date
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
    ,p_asg_future_changes_warning => l_asg_future_changes_warning
    ,p_entries_changed_warning    => l_entries_changed_warning
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 110);
 end if;
  --
  -- Start of API User Hook for the after hook of final_process_cwk_asg.
  --
  begin
     hr_assignment_bkh.final_process_cwk_asg_a
        (p_assignment_id                 =>     p_assignment_id
        ,p_object_version_number         =>     l_object_version_number
        ,p_final_process_date            =>     p_final_process_date
        ,p_effective_start_date          =>     l_effective_start_date
        ,p_effective_end_date            =>     l_effective_end_date
        ,p_org_now_no_manager_warning    =>     l_org_now_no_manager_warning
        ,p_asg_future_changes_warning    =>     l_asg_future_changes_warning
        ,p_entries_changed_warning       =>     l_entries_changed_warning
        );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'FINAL_PROCESS_CWK_ASG',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of final_process_cwk_asg.
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_asg_future_changes_warning := l_asg_future_changes_warning;
  p_effective_end_date         := l_effective_end_date;
  p_effective_start_date       := l_effective_start_date;
  p_entries_changed_warning    := l_entries_changed_warning;
  p_object_version_number      := l_object_version_number;
  p_org_now_no_manager_warning := l_org_now_no_manager_warning;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 300);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO final_process_cwk_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_asg_future_changes_warning := l_asg_future_changes_warning;
    p_effective_end_date         := null;
    p_effective_start_date       := null;
    p_entries_changed_warning    := l_entries_changed_warning;
    p_org_now_no_manager_warning := l_org_now_no_manager_warning;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number := lv_object_version_number;

    p_effective_start_date           := null;
    p_effective_end_date              := null;
    p_org_now_no_manager_warning      := null;
    p_asg_future_changes_warning      := null;
    p_entries_changed_warning         := null;

    ROLLBACK TO final_process_cwk_asg;
    raise;
    --
    -- End of fix.
    --
end final_process_cwk_asg;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< suspend_cwk_asg >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure suspend_cwk_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_change_reason                in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date             date;
  --
  -- Out variables
  --
  l_effective_end_date         per_all_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_all_assignments_f.effective_start_date%TYPE;
  l_object_version_number      per_all_assignments_f.object_version_number%TYPE;
  --
  l_proc                       varchar2(72);
  --
begin
 if g_debug then
  l_proc := g_package||'suspend_cwk_asg';
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  --
  l_object_version_number := p_object_version_number;
  --
  -- Issue a savepoint.
  --
  savepoint suspend_cwk_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Initialise local variable - added 25-Aug-97. RMF.
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validation in addition to Table Handlers
  --
  -- None required.
  --
  -- Process Logic
  --
  -- Start of API User Hook for the before hook of suspend_cwk_asg.
  --
  begin
     hr_assignment_bkl.suspend_cwk_asg_b
       (p_effective_date               => l_effective_date
       ,p_datetrack_update_mode        => p_datetrack_update_mode
       ,p_assignment_id                => p_assignment_id
       ,p_change_reason                => p_change_reason
       ,p_object_version_number        => p_object_version_number
       ,p_assignment_status_type_id    => p_assignment_status_type_id
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'SUSPEND_CWK_ASG',
          p_hook_type         => 'BP'
         );
  end;
  --
  --
  -- Update contingent worker assignment.
  --
  hr_assignment_internal.update_status_type_cwk_asg
    (p_effective_date               => l_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_change_reason                => p_change_reason
    ,p_object_version_number        => l_object_version_number
    ,p_expected_system_status       => 'SUSP_CWK_ASG'
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Start of API User Hook for the after hook of suspend_cwk_asg.
  --
  begin
     hr_assignment_bkl.suspend_cwk_asg_a
        (p_effective_date               => l_effective_date
        ,p_datetrack_update_mode        => p_datetrack_update_mode
        ,p_assignment_id                => p_assignment_id
        ,p_change_reason                => p_change_reason
        ,p_object_version_number        => l_object_version_number
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date
        );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'SUSPEND_CWK_ASG',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of suspend_cwk_asg.
  --
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
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 100);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO suspend_cwk_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := p_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO suspend_cwk_asg;
    raise;
    --
    -- End of fix.
    --
end suspend_cwk_asg;
--
-- ----------------------------------------------------------------------------
-- |---------------------< actual_termination_emp_asg >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure actual_termination_emp_asg
  (p_validate                     in     boolean
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_assignment_status_type_id    in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_pay_proposal_warning            out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_asg_future_changes_warning boolean := FALSE;
  l_pay_proposal_warning       boolean := FALSE;
  l_effective_end_date         per_all_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_all_assignments_f.effective_start_date%TYPE;
  l_entries_changed_warning    varchar2(1) := 'N';
  l_object_version_number      per_all_assignments_f.object_version_number%TYPE;
  --
  l_assignment_status_type_id
                               per_all_assignments_f.assignment_status_type_id%TYPE;
  l_assignment_type            per_all_assignments_f.assignment_type%TYPE;
  l_asg_business_group_id      per_all_assignments_f.business_group_id%TYPE;
  l_exists                     varchar2(1);
  l_last_standard_process_date
                       per_periods_of_service.last_standard_process_date%TYPE;
  l_actual_termination_date
		       per_periods_of_service.actual_termination_date%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_payroll_id                 per_all_assignments_f.payroll_id%TYPE;
  l_per_system_status      per_assignment_status_types.per_system_status%TYPE;
  l_primary_flag               per_all_assignments_f.primary_flag%TYPE;
  l_proc                       varchar2(72)
                               := g_package || 'actual_termination_emp_asg';
  --
  lv_object_version_number     number := p_object_version_number ;
  --
  cursor csr_get_asg_details is
    select asg.assignment_type
         , asg.payroll_id
         , asg.primary_flag
         , bus.business_group_id
         , bus.legislation_code
      from per_all_assignments_f   asg
	     , per_business_groups_perf bus
     where asg.assignment_id         = p_assignment_id
       and l_actual_termination_date between asg.effective_start_date
                                     and     asg.effective_end_date
       and bus.business_group_id+0     = asg.business_group_id;
  --
  cursor csr_invalid_term_assign is
    select null
      from per_all_assignments_f           asg
         , per_assignment_status_types ast
     where asg.assignment_id             =  p_assignment_id
       and asg.effective_end_date        >= l_actual_termination_date
       and ast.assignment_status_type_id =  asg.assignment_status_type_id
       and ast.per_system_status         =  'TERM_ASSIGN';
  --
  cursor csr_get_period_end_date is
    select tpe.end_date
      from per_time_periods tpe
     where tpe.payroll_id            = l_payroll_id
       and l_actual_termination_date between tpe.start_date
                                     and     tpe.end_date;
  --
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  l_assignment_status_type_id := p_assignment_status_type_id;
  l_object_version_number     := p_object_version_number;
  l_actual_termination_date   := trunc(p_actual_termination_date);
  --
  -- Issue a savepoint.
  --
  savepoint actual_termination_emp_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Validation in addition to Table Handlers
  --
  -- Get assignment and business group details for validation.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'assignment_id'
     ,p_argument_value => p_assignment_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'actual_termination_date'
     ,p_argument_value => l_actual_termination_date
     );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  open  csr_get_asg_details;
  fetch csr_get_asg_details
   into l_assignment_type
      , l_payroll_id
      , l_primary_flag
      , l_asg_business_group_id
      , l_legislation_code;
  --
  if csr_get_asg_details%NOTFOUND
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 30);
 end if;
    --
    close csr_get_asg_details;
    --
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_asg_details;
  --
  -- Start of API User Hook for the before hook of actual_termination_emp_asg.
  --
  begin
     hr_assignment_bk4.actual_termination_emp_asg_b
       (p_assignment_id                 =>  p_assignment_id
       ,p_object_version_number         =>  p_object_version_number
       ,p_actual_termination_date       =>  l_actual_termination_date
       ,p_assignment_status_type_id     =>  p_assignment_status_type_id
       ,p_business_group_id             =>  l_asg_business_group_id
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'ACTUAL_TERMINATION_EMP_ASG',
          p_hook_type         => 'BP'
         );
  end;
  --
  -- End of API User Hook for the before hook of actual_termination_emp_asg.
  --
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;
  --
  -- The assignment must not be a primary assignment.
  --
  if l_primary_flag <> 'N'
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 50);
 end if;
    --
    hr_utility.set_message(801,'HR_7999_ASG_INV_PRIM_ASG');
    hr_utility.raise_error;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 60);
 end if;
  --
  -- The assignment must be an employee assignment.
  --
  if l_assignment_type <> 'E'
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 70);
 end if;
    --
    hr_utility.set_message(801,'HR_7948_ASG_ASG_NOT_EMP');
    hr_utility.raise_error;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 80);
 end if;
  --
  -- The assignment status type must not already be TERM_ASSIGN on or after
  -- the actual termination date.
  --
  open  csr_invalid_term_assign;
  fetch csr_invalid_term_assign
   into l_exists;
  --
  if csr_invalid_term_assign%FOUND
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 90);
 end if;
    --
    close csr_invalid_term_assign;
    --
    hr_utility.set_message(800,'PER_52108_ASG_INV_TERM_ASSIGN');
    hr_utility.raise_error;
  end if;
  --
  close csr_invalid_term_assign;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 100);
 end if;
  --
  -- Process Logic
  --
  -- If p_assignment_status_type_id is g_number then derive it's default value,
  -- otherwise validate it.
  --
  per_asg_bus1.chk_assignment_status_type
    (p_assignment_status_type_id => l_assignment_status_type_id
    ,p_business_group_id         => l_asg_business_group_id
    ,p_legislation_code          => l_legislation_code
    ,p_expected_system_status    => 'TERM_ASSIGN'
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 110);
 end if;
  --
  -- Derive the last standard process date.
  --
  -- Bug 1711085. VS. 27-MAR-01. Commented out the code associated with
  -- disabling last_standard_process  for US legislature.
  --
  -- if l_legislation_code = 'US'
  -- then
    --
 if g_debug then
     hr_utility.set_location(l_proc, 120);
 end if;
    --
    -- l_last_standard_process_date := l_actual_termination_date;
  -- else
    --
 if g_debug then
    hr_utility.set_location(l_proc, 130);
 end if;
    --
    if l_payroll_id is not null
    then
      --
 if g_debug then
      hr_utility.set_location(l_proc, 140);
 end if;
      --
      -- Assignment is assigned to a payroll, so set the last standard process
      -- to date to the payroll's period end date as of the actual termination
      -- date.
      --
      open  csr_get_period_end_date;
      fetch csr_get_period_end_date
       into l_last_standard_process_date;
      --
      if csr_get_period_end_date%NOTFOUND then
        --
 if g_debug then
        hr_utility.set_location(l_proc, 150);
 end if;
        --
        -- No payroll period found for the actual termination date.
        --
        close csr_get_period_end_date;
        --
        hr_utility.set_message(801,'HR_51003_ASG_INV_NO_TERM_PRD');
        hr_utility.raise_error;
      end if;
      --
      close csr_get_period_end_date;
      --
 if g_debug then
      hr_utility.set_location(l_proc, 160);
 end if;
    else
      --
 if g_debug then
      hr_utility.set_location(l_proc, 170);
 end if;
      --
      -- Assignment is not assigned to a payroll, so set the last standard
      -- process date to the actual termination date.
      --
      l_last_standard_process_date := l_actual_termination_date;
    end if;
  -- end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 180);
 end if;
  --
  -- Call the business support process to update assignment and maintain the
  -- element entries.
  --
  hr_assignment_internal.actual_term_emp_asg_sup
    (p_assignment_id              => p_assignment_id
    ,p_object_version_number      => l_object_version_number
    ,p_actual_termination_date    => l_actual_termination_date
    ,p_last_standard_process_date => l_last_standard_process_date
    ,p_assignment_status_type_id  => l_assignment_status_type_id
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    ,p_asg_future_changes_warning => l_asg_future_changes_warning
    ,p_entries_changed_warning    => l_entries_changed_warning
    ,p_pay_proposal_warning       => l_pay_proposal_warning
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 190);
 end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  --
  -- Start of API User Hook for the after hook of actual_termination_emp_asg.
  -- Local vars are passed in for all OUT parms because the hook needs to
  -- be placed before the validate check and therefore before the code that
  -- sets all out parms.
  --
  begin
     hr_assignment_bk4.actual_termination_emp_asg_a
       (p_assignment_id                 =>  p_assignment_id
       ,p_object_version_number         =>  l_object_version_number
       ,p_actual_termination_date       =>  l_actual_termination_date
       ,p_assignment_status_type_id     =>  p_assignment_status_type_id
       ,p_effective_start_date          =>  l_effective_start_date
       ,p_effective_end_date            =>  l_effective_end_date
       ,p_asg_future_changes_warning    =>  l_asg_future_changes_warning
       ,p_entries_changed_warning       =>  l_entries_changed_warning
       ,p_pay_proposal_warning          =>  l_pay_proposal_warning
       ,p_business_group_id             =>  l_asg_business_group_id
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'ACTUAL_TERMINATION_EMP_ASG',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of actual_termination_emp_asg.
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_asg_future_changes_warning := l_asg_future_changes_warning;
  p_effective_end_date         := l_effective_end_date;
  p_effective_start_date       := l_effective_start_date;
  p_entries_changed_warning    := l_entries_changed_warning;
  p_pay_proposal_warning       := l_pay_proposal_warning;
  p_object_version_number      := l_object_version_number;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 200);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO actual_termination_emp_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_asg_future_changes_warning := l_asg_future_changes_warning;
    p_effective_end_date         := null;
    p_effective_start_date       := null;
    p_entries_changed_warning    := l_entries_changed_warning;
    p_pay_proposal_warning       := l_pay_proposal_warning;
    p_object_version_number      := p_object_version_number;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number := lv_object_version_number;
    p_effective_start_date        := null;
    p_effective_end_date          := null;
    p_asg_future_changes_warning  := null;
    p_entries_changed_warning     := null;
    p_pay_proposal_warning        := null;

    ROLLBACK TO actual_termination_emp_asg;
    raise;
    --
    -- End of fix.
    --
end actual_termination_emp_asg;
--
-- 70.2 change end.
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_secondary_emp_asg >--OLD---------------------|
-- ----------------------------------------------------------------------------
--
-- This is the 'old' interface which now simply calls the
-- 'new' interface and passes nulls for the new parms and
-- assigns local variables to capture the new outs.
--
procedure create_secondary_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_supervisor_id                in     number
  ,p_special_ceiling_step_id      in     number
  ,p_pay_basis_id                 in     number
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_employment_category          in     varchar2
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_scl_segment1                 in     varchar2
  ,p_scl_segment2                 in     varchar2
  ,p_scl_segment3                 in     varchar2
  ,p_scl_segment4                 in     varchar2
  ,p_scl_segment5                 in     varchar2
  ,p_scl_segment6                 in     varchar2
  ,p_scl_segment7                 in     varchar2
  ,p_scl_segment8                 in     varchar2
  ,p_scl_segment9                 in     varchar2
  ,p_scl_segment10                in     varchar2
  ,p_scl_segment11                in     varchar2
  ,p_scl_segment12                in     varchar2
  ,p_scl_segment13                in     varchar2
  ,p_scl_segment14                in     varchar2
  ,p_scl_segment15                in     varchar2
  ,p_scl_segment16                in     varchar2
  ,p_scl_segment17                in     varchar2
  ,p_scl_segment18                in     varchar2
  ,p_scl_segment19                in     varchar2
  ,p_scl_segment20                in     varchar2
  ,p_scl_segment21                in     varchar2
  ,p_scl_segment22                in     varchar2
  ,p_scl_segment23                in     varchar2
  ,p_scl_segment24                in     varchar2
  ,p_scl_segment25                in     varchar2
  ,p_scl_segment26                in     varchar2
  ,p_scl_segment27                in     varchar2
  ,p_scl_segment28                in     varchar2
  ,p_scl_segment29                in     varchar2
  ,p_scl_segment30                in     varchar2
   -- Bug 944911
   -- Added scl_concat_segments and amended scl_concatenated_segments
   -- to be an out instead of in out
  ,p_scl_concat_segments    	  in 	 varchar2
  ,p_pgp_segment1                 in     varchar2
  ,p_pgp_segment2                 in     varchar2
  ,p_pgp_segment3                 in     varchar2
  ,p_pgp_segment4                 in     varchar2
  ,p_pgp_segment5                 in     varchar2
  ,p_pgp_segment6                 in     varchar2
  ,p_pgp_segment7                 in     varchar2
  ,p_pgp_segment8                 in     varchar2
  ,p_pgp_segment9                 in     varchar2
  ,p_pgp_segment10                in     varchar2
  ,p_pgp_segment11                in     varchar2
  ,p_pgp_segment12                in     varchar2
  ,p_pgp_segment13                in     varchar2
  ,p_pgp_segment14                in     varchar2
  ,p_pgp_segment15                in     varchar2
  ,p_pgp_segment16                in     varchar2
  ,p_pgp_segment17                in     varchar2
  ,p_pgp_segment18                in     varchar2
  ,p_pgp_segment19                in     varchar2
  ,p_pgp_segment20                in     varchar2
  ,p_pgp_segment21                in     varchar2
  ,p_pgp_segment22                in     varchar2
  ,p_pgp_segment23                in     varchar2
  ,p_pgp_segment24                in     varchar2
  ,p_pgp_segment25                in     varchar2
  ,p_pgp_segment26                in     varchar2
  ,p_pgp_segment27                in     varchar2
  ,p_pgp_segment28                in     varchar2
  ,p_pgp_segment29                in     varchar2
  ,p_pgp_segment30                in     varchar2
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
  ,p_pgp_concat_segments	  in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_group_name                      out nocopy varchar2
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
-- As advised renaming p_scl_concatenated_segments to p_concatenated_segments
-- This has been done through out the procedures
  ,p_concatenated_segments           out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number  -- bug 2359997
  ,p_people_group_id              in out nocopy number  -- bug 2359997
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_assignment_id          per_all_assignments_f.assignment_id%TYPE;
  l_soft_coding_keyflex_id per_all_assignments_f.soft_coding_keyflex_id%TYPE
  := p_soft_coding_keyflex_id;  -- bug 2359997
  l_people_group_id        per_all_assignments_f.people_group_id%TYPE
  := p_people_group_id; -- bug 2359997
  l_object_version_number  per_all_assignments_f.object_version_number%TYPE;
  l_effective_start_date   per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date     per_all_assignments_f.effective_end_date%TYPE;
  l_assignment_sequence    per_all_assignments_f.assignment_sequence%TYPE;
  l_assignment_number      per_all_assignments_f.assignment_number%TYPE;
  l_comment_id             per_all_assignments_f.comment_id%TYPE;
  l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_old_scl_conc_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_group_name             pay_people_groups.group_name%TYPE;
  l_old_group_name         pay_people_groups.group_name%TYPE;
  l_other_manager_warning  boolean;
  l_effective_date         date;
  l_date_probation_end     per_all_assignments_f.date_probation_end%TYPE;
  l_flex_num               fnd_id_flex_segments.id_flex_num%TYPE;
  l_scl_flex_num           fnd_id_flex_segments.id_flex_num%TYPE;
  l_grp_flex_num           fnd_id_flex_segments.id_flex_num%TYPE;
  --
  l_business_group_id    per_business_groups.business_group_id%TYPE;
  l_legislation_code     per_business_groups.legislation_code%TYPE;
  l_period_of_service_id per_all_assignments_f.period_of_service_id%TYPE;
  l_proc                 varchar2(72);
  l_session_id           number;
  l_cagr_grade_def_id    number;
  l_cagr_concatenated_segments number;
  --
--
begin
--
 if g_debug then
  l_proc := g_package||'create_secondary_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  l_assignment_number := p_assignment_number;
  --
  -- Call the new code
  --
  hr_assignment_api.create_secondary_emp_asg(
   p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_person_id                    => p_person_id
  ,p_organization_id              => p_organization_id
  ,p_grade_id                     => p_grade_id
  ,p_position_id                  => p_position_id
  ,p_job_id                       => p_job_id
  ,p_assignment_status_type_id    => p_assignment_status_type_id
  ,p_payroll_id                   => p_payroll_id
  ,p_location_id                  => p_location_id
  ,p_supervisor_id                => p_supervisor_id
  ,p_special_ceiling_step_id      => p_special_ceiling_step_id
  ,p_pay_basis_id                 => p_pay_basis_id
  ,p_assignment_number            => l_assignment_number
  ,p_change_reason                => p_change_reason
  ,p_comments                     => p_comments
  ,p_date_probation_end           => p_date_probation_end
  ,p_default_code_comb_id         => p_default_code_comb_id
  ,p_employment_category          => p_employment_category
  ,p_frequency                    => p_frequency
  ,p_internal_address_line        => p_internal_address_line
  ,p_manager_flag                 => p_manager_flag
  ,p_normal_hours                 => p_normal_hours
  ,p_perf_review_period           => p_perf_review_period
  ,p_perf_review_period_frequency => p_perf_review_period_frequency
  ,p_probation_period             => p_probation_period
  ,p_probation_unit               => p_probation_unit
  ,p_sal_review_period            => p_sal_review_period
  ,p_sal_review_period_frequency  => p_sal_review_period_frequency
  ,p_set_of_books_id              => p_set_of_books_id
  ,p_source_type                  => p_source_type
  ,p_time_normal_finish           => p_time_normal_finish
  ,p_time_normal_start            => p_time_normal_start
  ,p_bargaining_unit_code         => p_bargaining_unit_code
  ,p_labour_union_member_flag     => p_labour_union_member_flag
  ,p_hourly_salaried_code         => p_hourly_salaried_code
  ,p_ass_attribute_category       => p_ass_attribute_category
  ,p_ass_attribute1               => p_ass_attribute1
  ,p_ass_attribute2               => p_ass_attribute2
  ,p_ass_attribute3               => p_ass_attribute3
  ,p_ass_attribute4               => p_ass_attribute4
  ,p_ass_attribute5               => p_ass_attribute5
  ,p_ass_attribute6               => p_ass_attribute6
  ,p_ass_attribute7               => p_ass_attribute7
  ,p_ass_attribute8               => p_ass_attribute8
  ,p_ass_attribute9               => p_ass_attribute9
  ,p_ass_attribute10              => p_ass_attribute10
  ,p_ass_attribute11              => p_ass_attribute11
  ,p_ass_attribute12              => p_ass_attribute12
  ,p_ass_attribute13              => p_ass_attribute13
  ,p_ass_attribute14              => p_ass_attribute14
  ,p_ass_attribute15              => p_ass_attribute15
  ,p_ass_attribute16              => p_ass_attribute16
  ,p_ass_attribute17              => p_ass_attribute17
  ,p_ass_attribute18              => p_ass_attribute18
  ,p_ass_attribute19              => p_ass_attribute19
  ,p_ass_attribute20              => p_ass_attribute20
  ,p_ass_attribute21              => p_ass_attribute21
  ,p_ass_attribute22              => p_ass_attribute22
  ,p_ass_attribute23              => p_ass_attribute23
  ,p_ass_attribute24              => p_ass_attribute24
  ,p_ass_attribute25              => p_ass_attribute25
  ,p_ass_attribute26              => p_ass_attribute26
  ,p_ass_attribute27              => p_ass_attribute27
  ,p_ass_attribute28              => p_ass_attribute28
  ,p_ass_attribute29              => p_ass_attribute29
  ,p_ass_attribute30              => p_ass_attribute30
  ,p_title                        => p_title
  ,p_scl_segment1                 => p_scl_segment1
  ,p_scl_segment2                 => p_scl_segment2
  ,p_scl_segment3                 => p_scl_segment3
  ,p_scl_segment4                 => p_scl_segment4
  ,p_scl_segment5                 => p_scl_segment5
  ,p_scl_segment6                 => p_scl_segment6
  ,p_scl_segment7                 => p_scl_segment7
  ,p_scl_segment8                 => p_scl_segment8
  ,p_scl_segment9                 => p_scl_segment9
  ,p_scl_segment10                => p_scl_segment10
  ,p_scl_segment11                => p_scl_segment11
  ,p_scl_segment12                => p_scl_segment12
  ,p_scl_segment13                => p_scl_segment13
  ,p_scl_segment14                => p_scl_segment14
  ,p_scl_segment15                => p_scl_segment15
  ,p_scl_segment16                => p_scl_segment16
  ,p_scl_segment17                => p_scl_segment17
  ,p_scl_segment18                => p_scl_segment18
  ,p_scl_segment19                => p_scl_segment19
  ,p_scl_segment20                => p_scl_segment20
  ,p_scl_segment21                => p_scl_segment21
  ,p_scl_segment22                => p_scl_segment22
  ,p_scl_segment23                => p_scl_segment23
  ,p_scl_segment24                => p_scl_segment24
  ,p_scl_segment25                => p_scl_segment25
  ,p_scl_segment26                => p_scl_segment26
  ,p_scl_segment27                => p_scl_segment27
  ,p_scl_segment28                => p_scl_segment28
  ,p_scl_segment29                => p_scl_segment29
  ,p_scl_segment30                => p_scl_segment30
  ,p_scl_concat_segments          => p_scl_concat_segments
  ,p_pgp_segment1                 => p_pgp_segment1
  ,p_pgp_segment2                 => p_pgp_segment2
  ,p_pgp_segment3                 => p_pgp_segment3
  ,p_pgp_segment4                 => p_pgp_segment4
  ,p_pgp_segment5                 => p_pgp_segment5
  ,p_pgp_segment6                 => p_pgp_segment6
  ,p_pgp_segment7                 => p_pgp_segment7
  ,p_pgp_segment8                 => p_pgp_segment8
  ,p_pgp_segment9                 => p_pgp_segment9
  ,p_pgp_segment10                => p_pgp_segment10
  ,p_pgp_segment11                => p_pgp_segment11
  ,p_pgp_segment12                => p_pgp_segment12
  ,p_pgp_segment13                => p_pgp_segment13
  ,p_pgp_segment14                => p_pgp_segment14
  ,p_pgp_segment15                => p_pgp_segment15
  ,p_pgp_segment16                => p_pgp_segment16
  ,p_pgp_segment17                => p_pgp_segment17
  ,p_pgp_segment18                => p_pgp_segment18
  ,p_pgp_segment19                => p_pgp_segment19
  ,p_pgp_segment20                => p_pgp_segment20
  ,p_pgp_segment21                => p_pgp_segment21
  ,p_pgp_segment22                => p_pgp_segment22
  ,p_pgp_segment23                => p_pgp_segment23
  ,p_pgp_segment24                => p_pgp_segment24
  ,p_pgp_segment25                => p_pgp_segment25
  ,p_pgp_segment26                => p_pgp_segment26
  ,p_pgp_segment27                => p_pgp_segment27
  ,p_pgp_segment28                => p_pgp_segment28
  ,p_pgp_segment29                => p_pgp_segment29
  ,p_pgp_segment30                => p_pgp_segment30
  ,p_pgp_concat_segments          => p_pgp_concat_segments
  ,p_contract_id                  => null
  ,p_establishment_id             => null
  ,p_collective_agreement_id      => null
  ,p_cagr_id_flex_num             => null
  ,p_cag_segment1                 => null
  ,p_cag_segment2                 => null
  ,p_cag_segment3                 => null
  ,p_cag_segment4                 => null
  ,p_cag_segment5                 => null
  ,p_cag_segment6                 => null
  ,p_cag_segment7                 => null
  ,p_cag_segment8                 => null
  ,p_cag_segment9                 => null
  ,p_cag_segment10                => null
  ,p_cag_segment11                => null
  ,p_cag_segment12                => null
  ,p_cag_segment13                => null
  ,p_cag_segment14                => null
  ,p_cag_segment15                => null
  ,p_cag_segment16                => null
  ,p_cag_segment17                => null
  ,p_cag_segment18                => null
  ,p_cag_segment19                => null
  ,p_cag_segment20                => null
  ,p_grade_ladder_pgm_id          => null
  ,p_supervisor_assignment_id     => null
  ,p_cagr_grade_def_id            => l_cagr_grade_def_id
  ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
  ,p_assignment_id                => l_assignment_id
  ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
  ,p_people_group_id              => l_people_group_id
  ,p_object_version_number        => l_object_version_number
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ,p_assignment_sequence          => l_assignment_sequence
  ,p_comment_id                   => l_comment_id
  ,p_concatenated_segments        => l_concatenated_segments
  ,p_group_name                   => l_group_name
  ,p_other_manager_warning        => l_other_manager_warning
   );
  --
  -- Set remaining output arguments
  --
  p_assignment_id          := l_assignment_id;
  p_soft_coding_keyflex_id := l_soft_coding_keyflex_id;
  p_people_group_id        := l_people_group_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_assignment_sequence    := l_assignment_sequence;
  p_comment_id             := l_comment_id;
  p_concatenated_segments  := l_concatenated_segments;
  p_group_name             := l_group_name;
  p_other_manager_warning  := l_other_manager_warning;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 50);
 end if;
end create_secondary_emp_asg;
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_secondary_emp_asg >-NEW----------------------|
-- ----------------------------------------------------------------------------
--
-- This is the new interface that contains the extra parms
-- for collective agreements and contracts.
-- added new parameters notice_period, units, employee_category,
-- work_at_home and job_source on 05-OCT-01
--
procedure create_secondary_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_supervisor_id                in     number
  ,p_special_ceiling_step_id      in     number
  ,p_pay_basis_id                 in     number
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_employment_category          in     varchar2
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_scl_segment1                 in     varchar2
  ,p_scl_segment2                 in     varchar2
  ,p_scl_segment3                 in     varchar2
  ,p_scl_segment4                 in     varchar2
  ,p_scl_segment5                 in     varchar2
  ,p_scl_segment6                 in     varchar2
  ,p_scl_segment7                 in     varchar2
  ,p_scl_segment8                 in     varchar2
  ,p_scl_segment9                 in     varchar2
  ,p_scl_segment10                in     varchar2
  ,p_scl_segment11                in     varchar2
  ,p_scl_segment12                in     varchar2
  ,p_scl_segment13                in     varchar2
  ,p_scl_segment14                in     varchar2
  ,p_scl_segment15                in     varchar2
  ,p_scl_segment16                in     varchar2
  ,p_scl_segment17                in     varchar2
  ,p_scl_segment18                in     varchar2
  ,p_scl_segment19                in     varchar2
  ,p_scl_segment20                in     varchar2
  ,p_scl_segment21                in     varchar2
  ,p_scl_segment22                in     varchar2
  ,p_scl_segment23                in     varchar2
  ,p_scl_segment24                in     varchar2
  ,p_scl_segment25                in     varchar2
  ,p_scl_segment26                in     varchar2
  ,p_scl_segment27                in     varchar2
  ,p_scl_segment28                in     varchar2
  ,p_scl_segment29                in     varchar2
  ,p_scl_segment30                in     varchar2
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
  ,p_scl_concat_segments    	  in 	 varchar2
  ,p_pgp_segment1                 in     varchar2
  ,p_pgp_segment2                 in     varchar2
  ,p_pgp_segment3                 in     varchar2
  ,p_pgp_segment4                 in     varchar2
  ,p_pgp_segment5                 in     varchar2
  ,p_pgp_segment6                 in     varchar2
  ,p_pgp_segment7                 in     varchar2
  ,p_pgp_segment8                 in     varchar2
  ,p_pgp_segment9                 in     varchar2
  ,p_pgp_segment10                in     varchar2
  ,p_pgp_segment11                in     varchar2
  ,p_pgp_segment12                in     varchar2
  ,p_pgp_segment13                in     varchar2
  ,p_pgp_segment14                in     varchar2
  ,p_pgp_segment15                in     varchar2
  ,p_pgp_segment16                in     varchar2
  ,p_pgp_segment17                in     varchar2
  ,p_pgp_segment18                in     varchar2
  ,p_pgp_segment19                in     varchar2
  ,p_pgp_segment20                in     varchar2
  ,p_pgp_segment21                in     varchar2
  ,p_pgp_segment22                in     varchar2
  ,p_pgp_segment23                in     varchar2
  ,p_pgp_segment24                in     varchar2
  ,p_pgp_segment25                in     varchar2
  ,p_pgp_segment26                in     varchar2
  ,p_pgp_segment27                in     varchar2
  ,p_pgp_segment28                in     varchar2
  ,p_pgp_segment29                in     varchar2
  ,p_pgp_segment30                in     varchar2
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
  ,p_pgp_concat_segments	  in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_collective_agreement_id      in     number
  ,p_cagr_id_flex_num             in     number
  ,p_cag_segment1                 in     varchar2
  ,p_cag_segment2                 in     varchar2
  ,p_cag_segment3                 in     varchar2
  ,p_cag_segment4                 in     varchar2
  ,p_cag_segment5                 in     varchar2
  ,p_cag_segment6                 in     varchar2
  ,p_cag_segment7                 in     varchar2
  ,p_cag_segment8                 in     varchar2
  ,p_cag_segment9                 in     varchar2
  ,p_cag_segment10                in     varchar2
  ,p_cag_segment11                in     varchar2
  ,p_cag_segment12                in     varchar2
  ,p_cag_segment13                in     varchar2
  ,p_cag_segment14                in     varchar2
  ,p_cag_segment15                in     varchar2
  ,p_cag_segment16                in     varchar2
  ,p_cag_segment17                in     varchar2
  ,p_cag_segment18                in     varchar2
  ,p_cag_segment19                in     varchar2
  ,p_cag_segment20                in     varchar2
  ,p_notice_period		  in	 number
  ,p_notice_period_uom		  in     varchar2
  ,p_employee_category		  in     varchar2
  ,p_work_at_home		  in	 varchar2
  ,p_job_post_source_name         in     varchar2
  ,p_grade_ladder_pgm_id          in     number
  ,p_supervisor_assignment_id     in     number
  ,p_group_name                      out nocopy varchar2
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
-- As advised renaming p_scl_concatenated_segments to p_concatenated_segments
-- This has been done through out the procedures
  ,p_concatenated_segments           out nocopy varchar2
  ,p_cagr_grade_def_id            in out nocopy number  -- bug 2359997
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number  -- bug 2359997
  ,p_people_group_id              in out nocopy number  -- bug 2359997
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_assignment_id          per_all_assignments_f.assignment_id%TYPE;
  l_soft_coding_keyflex_id per_all_assignments_f.soft_coding_keyflex_id%TYPE
  := p_soft_coding_keyflex_id;  -- bug 2359997 added initialization
  l_people_group_id        per_all_assignments_f.people_group_id%TYPE
  := p_people_group_id;    -- bug 2359997 added initialization
  l_cagr_grade_def_id      per_cagr_grades_def.cagr_grade_def_id%TYPE
  := p_cagr_grade_def_id;   -- bug 2359997, added this local variable
  l_object_version_number  per_all_assignments_f.object_version_number%TYPE;
  l_effective_start_date   per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date     per_all_assignments_f.effective_end_date%TYPE;
  l_assignment_sequence    per_all_assignments_f.assignment_sequence%TYPE;
  l_assignment_number      per_all_assignments_f.assignment_number%TYPE;
  l_comment_id             per_all_assignments_f.comment_id%TYPE;
  l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_old_scl_conc_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_group_name             pay_people_groups.group_name%TYPE;
  l_old_group_name         pay_people_groups.group_name%TYPE;
  l_other_manager_warning  boolean;
  l_effective_date         date;
  l_date_probation_end     per_all_assignments_f.date_probation_end%TYPE;
  l_flex_num               fnd_id_flex_segments.id_flex_num%TYPE;
  l_scl_flex_num           fnd_id_flex_segments.id_flex_num%TYPE;
  l_grp_flex_num           fnd_id_flex_segments.id_flex_num%TYPE;
  l_hourly_salaried_warning boolean;
  l_proc                 varchar2(72);
--
begin
--
 if g_debug then
  l_proc := g_package||'create_secondary_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  l_assignment_number := p_assignment_number;
  --
  -- Call the new code
  --
  hr_assignment_api.create_secondary_emp_asg(
   p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_person_id                    => p_person_id
  ,p_organization_id              => p_organization_id
  ,p_grade_id                     => p_grade_id
  ,p_position_id                  => p_position_id
  ,p_job_id                       => p_job_id
  ,p_assignment_status_type_id    => p_assignment_status_type_id
  ,p_payroll_id                   => p_payroll_id
  ,p_location_id                  => p_location_id
  ,p_supervisor_id                => p_supervisor_id
  ,p_special_ceiling_step_id      => p_special_ceiling_step_id
  ,p_pay_basis_id                 => p_pay_basis_id
  ,p_assignment_number            => l_assignment_number
  ,p_change_reason                => p_change_reason
  ,p_comments                     => p_comments
  ,p_date_probation_end           => p_date_probation_end
  ,p_default_code_comb_id         => p_default_code_comb_id
  ,p_employment_category          => p_employment_category
  ,p_frequency                    => p_frequency
  ,p_internal_address_line        => p_internal_address_line
  ,p_manager_flag                 => p_manager_flag
  ,p_normal_hours                 => p_normal_hours
  ,p_perf_review_period           => p_perf_review_period
  ,p_perf_review_period_frequency => p_perf_review_period_frequency
  ,p_probation_period             => p_probation_period
  ,p_probation_unit               => p_probation_unit
  ,p_sal_review_period            => p_sal_review_period
  ,p_sal_review_period_frequency  => p_sal_review_period_frequency
  ,p_set_of_books_id              => p_set_of_books_id
  ,p_source_type                  => p_source_type
  ,p_time_normal_finish           => p_time_normal_finish
  ,p_time_normal_start            => p_time_normal_start
  ,p_bargaining_unit_code         => p_bargaining_unit_code
  ,p_labour_union_member_flag     => p_labour_union_member_flag
  ,p_hourly_salaried_code         => p_hourly_salaried_code
  ,p_notice_period                => p_notice_period
  ,p_notice_period_uom            => p_notice_period_uom
  ,p_employee_category            => p_employee_category
  ,p_work_at_home                 => p_work_at_home
  ,p_job_post_source_name         => p_job_post_source_name
  ,p_ass_attribute_category       => p_ass_attribute_category
  ,p_ass_attribute1               => p_ass_attribute1
  ,p_ass_attribute2               => p_ass_attribute2
  ,p_ass_attribute3               => p_ass_attribute3
  ,p_ass_attribute4               => p_ass_attribute4
  ,p_ass_attribute5               => p_ass_attribute5
  ,p_ass_attribute6               => p_ass_attribute6
  ,p_ass_attribute7               => p_ass_attribute7
  ,p_ass_attribute8               => p_ass_attribute8
  ,p_ass_attribute9               => p_ass_attribute9
  ,p_ass_attribute10              => p_ass_attribute10
  ,p_ass_attribute11              => p_ass_attribute11
  ,p_ass_attribute12              => p_ass_attribute12
  ,p_ass_attribute13              => p_ass_attribute13
  ,p_ass_attribute14              => p_ass_attribute14
  ,p_ass_attribute15              => p_ass_attribute15
  ,p_ass_attribute16              => p_ass_attribute16
  ,p_ass_attribute17              => p_ass_attribute17
  ,p_ass_attribute18              => p_ass_attribute18
  ,p_ass_attribute19              => p_ass_attribute19
  ,p_ass_attribute20              => p_ass_attribute20
  ,p_ass_attribute21              => p_ass_attribute21
  ,p_ass_attribute22              => p_ass_attribute22
  ,p_ass_attribute23              => p_ass_attribute23
  ,p_ass_attribute24              => p_ass_attribute24
  ,p_ass_attribute25              => p_ass_attribute25
  ,p_ass_attribute26              => p_ass_attribute26
  ,p_ass_attribute27              => p_ass_attribute27
  ,p_ass_attribute28              => p_ass_attribute28
  ,p_ass_attribute29              => p_ass_attribute29
  ,p_ass_attribute30              => p_ass_attribute30
  ,p_title                        => p_title
  ,p_scl_segment1                 => p_scl_segment1
  ,p_scl_segment2                 => p_scl_segment2
  ,p_scl_segment3                 => p_scl_segment3
  ,p_scl_segment4                 => p_scl_segment4
  ,p_scl_segment5                 => p_scl_segment5
  ,p_scl_segment6                 => p_scl_segment6
  ,p_scl_segment7                 => p_scl_segment7
  ,p_scl_segment8                 => p_scl_segment8
  ,p_scl_segment9                 => p_scl_segment9
  ,p_scl_segment10                => p_scl_segment10
  ,p_scl_segment11                => p_scl_segment11
  ,p_scl_segment12                => p_scl_segment12
  ,p_scl_segment13                => p_scl_segment13
  ,p_scl_segment14                => p_scl_segment14
  ,p_scl_segment15                => p_scl_segment15
  ,p_scl_segment16                => p_scl_segment16
  ,p_scl_segment17                => p_scl_segment17
  ,p_scl_segment18                => p_scl_segment18
  ,p_scl_segment19                => p_scl_segment19
  ,p_scl_segment20                => p_scl_segment20
  ,p_scl_segment21                => p_scl_segment21
  ,p_scl_segment22                => p_scl_segment22
  ,p_scl_segment23                => p_scl_segment23
  ,p_scl_segment24                => p_scl_segment24
  ,p_scl_segment25                => p_scl_segment25
  ,p_scl_segment26                => p_scl_segment26
  ,p_scl_segment27                => p_scl_segment27
  ,p_scl_segment28                => p_scl_segment28
  ,p_scl_segment29                => p_scl_segment29
  ,p_scl_segment30                => p_scl_segment30
  ,p_scl_concat_segments          => p_scl_concat_segments
  ,p_pgp_segment1                 => p_pgp_segment1
  ,p_pgp_segment2                 => p_pgp_segment2
  ,p_pgp_segment3                 => p_pgp_segment3
  ,p_pgp_segment4                 => p_pgp_segment4
  ,p_pgp_segment5                 => p_pgp_segment5
  ,p_pgp_segment6                 => p_pgp_segment6
  ,p_pgp_segment7                 => p_pgp_segment7
  ,p_pgp_segment8                 => p_pgp_segment8
  ,p_pgp_segment9                 => p_pgp_segment9
  ,p_pgp_segment10                => p_pgp_segment10
  ,p_pgp_segment11                => p_pgp_segment11
  ,p_pgp_segment12                => p_pgp_segment12
  ,p_pgp_segment13                => p_pgp_segment13
  ,p_pgp_segment14                => p_pgp_segment14
  ,p_pgp_segment15                => p_pgp_segment15
  ,p_pgp_segment16                => p_pgp_segment16
  ,p_pgp_segment17                => p_pgp_segment17
  ,p_pgp_segment18                => p_pgp_segment18
  ,p_pgp_segment19                => p_pgp_segment19
  ,p_pgp_segment20                => p_pgp_segment20
  ,p_pgp_segment21                => p_pgp_segment21
  ,p_pgp_segment22                => p_pgp_segment22
  ,p_pgp_segment23                => p_pgp_segment23
  ,p_pgp_segment24                => p_pgp_segment24
  ,p_pgp_segment25                => p_pgp_segment25
  ,p_pgp_segment26                => p_pgp_segment26
  ,p_pgp_segment27                => p_pgp_segment27
  ,p_pgp_segment28                => p_pgp_segment28
  ,p_pgp_segment29                => p_pgp_segment29
  ,p_pgp_segment30                => p_pgp_segment30
  ,p_pgp_concat_segments          => p_pgp_concat_segments
  ,p_contract_id                  => p_contract_id
  ,p_establishment_id             => p_establishment_id
  ,p_collective_agreement_id      => p_collective_agreement_id
  ,p_cagr_id_flex_num             => p_cagr_id_flex_num
  ,p_cag_segment1                 => p_cag_segment1
  ,p_cag_segment2                 => p_cag_segment2
  ,p_cag_segment3                 => p_cag_segment3
  ,p_cag_segment4                 => p_cag_segment4
  ,p_cag_segment5                 => p_cag_segment5
  ,p_cag_segment6                 => p_cag_segment6
  ,p_cag_segment7                 => p_cag_segment7
  ,p_cag_segment8                 => p_cag_segment8
  ,p_cag_segment9                 => p_cag_segment9
  ,p_cag_segment10                => p_cag_segment10
  ,p_cag_segment11                => p_cag_segment11
  ,p_cag_segment12                => p_cag_segment12
  ,p_cag_segment13                => p_cag_segment13
  ,p_cag_segment14                => p_cag_segment14
  ,p_cag_segment15                => p_cag_segment15
  ,p_cag_segment16                => p_cag_segment16
  ,p_cag_segment17                => p_cag_segment17
  ,p_cag_segment18                => p_cag_segment18
  ,p_cag_segment19                => p_cag_segment19
  ,p_cag_segment20                => p_cag_segment20
  ,p_cagr_grade_def_id            => l_cagr_grade_def_id -- bug 2359997
  ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
  ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
  ,p_supervisor_assignment_id     => p_supervisor_assignment_id
  ,p_assignment_id                => l_assignment_id
  ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
  ,p_people_group_id              => l_people_group_id
  ,p_object_version_number        => l_object_version_number
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ,p_assignment_sequence          => l_assignment_sequence
  ,p_comment_id                   => l_comment_id
  ,p_concatenated_segments        => l_concatenated_segments
  ,p_group_name                   => l_group_name
  ,p_other_manager_warning        => l_other_manager_warning
  ,p_hourly_salaried_warning      => l_hourly_salaried_warning
   );
  --
  -- Set remaining output arguments
  --
  p_assignment_id           := l_assignment_id;
  p_soft_coding_keyflex_id  := l_soft_coding_keyflex_id;
  p_people_group_id         := l_people_group_id;
  p_cagr_grade_def_id       := l_cagr_grade_def_id;  -- bug 2359997 added
  p_object_version_number   := l_object_version_number;
  p_effective_start_date    := l_effective_start_date;
  p_effective_end_date      := l_effective_end_date;
  p_assignment_sequence     := l_assignment_sequence;
  p_comment_id              := l_comment_id;
  p_concatenated_segments   := l_concatenated_segments;
  p_group_name              := l_group_name;
  p_other_manager_warning   := l_other_manager_warning;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 50);
 end if;
end create_secondary_emp_asg;
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_secondary_emp_asg >-NEW2---------------------|
-- ----------------------------------------------------------------------------
--
--   This is the new Overloded procedure to include p_hourly_salaried_warning
--   parameter
--
procedure create_secondary_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_supervisor_id                in     number
  ,p_special_ceiling_step_id      in     number
  ,p_pay_basis_id                 in     number
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_employment_category          in     varchar2
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_scl_segment1                 in     varchar2
  ,p_scl_segment2                 in     varchar2
  ,p_scl_segment3                 in     varchar2
  ,p_scl_segment4                 in     varchar2
  ,p_scl_segment5                 in     varchar2
  ,p_scl_segment6                 in     varchar2
  ,p_scl_segment7                 in     varchar2
  ,p_scl_segment8                 in     varchar2
  ,p_scl_segment9                 in     varchar2
  ,p_scl_segment10                in     varchar2
  ,p_scl_segment11                in     varchar2
  ,p_scl_segment12                in     varchar2
  ,p_scl_segment13                in     varchar2
  ,p_scl_segment14                in     varchar2
  ,p_scl_segment15                in     varchar2
  ,p_scl_segment16                in     varchar2
  ,p_scl_segment17                in     varchar2
  ,p_scl_segment18                in     varchar2
  ,p_scl_segment19                in     varchar2
  ,p_scl_segment20                in     varchar2
  ,p_scl_segment21                in     varchar2
  ,p_scl_segment22                in     varchar2
  ,p_scl_segment23                in     varchar2
  ,p_scl_segment24                in     varchar2
  ,p_scl_segment25                in     varchar2
  ,p_scl_segment26                in     varchar2
  ,p_scl_segment27                in     varchar2
  ,p_scl_segment28                in     varchar2
  ,p_scl_segment29                in     varchar2
  ,p_scl_segment30                in     varchar2
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
  ,p_scl_concat_segments    	  in 	 varchar2
  ,p_pgp_segment1                 in     varchar2
  ,p_pgp_segment2                 in     varchar2
  ,p_pgp_segment3                 in     varchar2
  ,p_pgp_segment4                 in     varchar2
  ,p_pgp_segment5                 in     varchar2
  ,p_pgp_segment6                 in     varchar2
  ,p_pgp_segment7                 in     varchar2
  ,p_pgp_segment8                 in     varchar2
  ,p_pgp_segment9                 in     varchar2
  ,p_pgp_segment10                in     varchar2
  ,p_pgp_segment11                in     varchar2
  ,p_pgp_segment12                in     varchar2
  ,p_pgp_segment13                in     varchar2
  ,p_pgp_segment14                in     varchar2
  ,p_pgp_segment15                in     varchar2
  ,p_pgp_segment16                in     varchar2
  ,p_pgp_segment17                in     varchar2
  ,p_pgp_segment18                in     varchar2
  ,p_pgp_segment19                in     varchar2
  ,p_pgp_segment20                in     varchar2
  ,p_pgp_segment21                in     varchar2
  ,p_pgp_segment22                in     varchar2
  ,p_pgp_segment23                in     varchar2
  ,p_pgp_segment24                in     varchar2
  ,p_pgp_segment25                in     varchar2
  ,p_pgp_segment26                in     varchar2
  ,p_pgp_segment27                in     varchar2
  ,p_pgp_segment28                in     varchar2
  ,p_pgp_segment29                in     varchar2
  ,p_pgp_segment30                in     varchar2
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
  ,p_pgp_concat_segments	  in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_collective_agreement_id      in     number
  ,p_cagr_id_flex_num             in     number
  ,p_cag_segment1                 in     varchar2
  ,p_cag_segment2                 in     varchar2
  ,p_cag_segment3                 in     varchar2
  ,p_cag_segment4                 in     varchar2
  ,p_cag_segment5                 in     varchar2
  ,p_cag_segment6                 in     varchar2
  ,p_cag_segment7                 in     varchar2
  ,p_cag_segment8                 in     varchar2
  ,p_cag_segment9                 in     varchar2
  ,p_cag_segment10                in     varchar2
  ,p_cag_segment11                in     varchar2
  ,p_cag_segment12                in     varchar2
  ,p_cag_segment13                in     varchar2
  ,p_cag_segment14                in     varchar2
  ,p_cag_segment15                in     varchar2
  ,p_cag_segment16                in     varchar2
  ,p_cag_segment17                in     varchar2
  ,p_cag_segment18                in     varchar2
  ,p_cag_segment19                in     varchar2
  ,p_cag_segment20                in     varchar2
  ,p_notice_period		  in	 number
  ,p_notice_period_uom		  in     varchar2
  ,p_employee_category		  in     varchar2
  ,p_work_at_home		  in	 varchar2
  ,p_job_post_source_name         in     varchar2
  ,p_grade_ladder_pgm_id          in     number
  ,p_supervisor_assignment_id     in     number
  ,p_group_name                      out nocopy varchar2
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
-- As advised renaming p_scl_concatenated_segments to p_concatenated_segments
-- This has been done through out the procedures
  ,p_concatenated_segments           out nocopy varchar2
  ,p_cagr_grade_def_id            in out nocopy number  -- bug 2359997
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number  -- bug 2359997
  ,p_people_group_id              in out nocopy number  -- bug 2359997
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_assignment_id           per_all_assignments_f.assignment_id%TYPE;
  l_soft_coding_keyflex_id  per_all_assignments_f.soft_coding_keyflex_id%TYPE
  := p_soft_coding_keyflex_id;
  l_people_group_id         per_all_assignments_f.people_group_id%TYPE
  := p_people_group_id;
  l_object_version_number   per_all_assignments_f.object_version_number%TYPE;
  l_effective_start_date    per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date      per_all_assignments_f.effective_end_date%TYPE;
  l_assignment_sequence     per_all_assignments_f.assignment_sequence%TYPE;
  l_assignment_number       per_all_assignments_f.assignment_number%TYPE;
  l_comment_id              per_all_assignments_f.comment_id%TYPE;
  l_concatenated_segments   hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_old_scl_conc_segments   hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_group_name              pay_people_groups.group_name%TYPE;
  l_old_group_name          pay_people_groups.group_name%TYPE;
  l_other_manager_warning   boolean;
  l_hourly_salaried_warning boolean;
  l_effective_date          date;
  l_date_probation_end      per_all_assignments_f.date_probation_end%TYPE;
  l_flex_num                fnd_id_flex_segments.id_flex_num%TYPE;
  l_scl_flex_num            fnd_id_flex_segments.id_flex_num%TYPE;
  l_grp_flex_num            fnd_id_flex_segments.id_flex_num%TYPE;
  --
  l_business_group_id       per_business_groups.business_group_id%TYPE;
  l_legislation_code        per_business_groups.legislation_code%TYPE;
  l_period_of_service_id    per_all_assignments_f.period_of_service_id%TYPE;
  l_proc                    varchar2(72) := g_package||
  'create_secondary_emp_asg';
  l_session_id              number;
  l_cagr_grade_def_id       per_cagr_grades_def.cagr_grade_def_id%TYPE
  := p_cagr_grade_def_id;
  l_cagr_concatenated_segments varchar2(2000);

  l_gsp_post_process_warning varchar2(2000); -- bug 2999562
--
begin
--
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  l_assignment_number := p_assignment_number;
  --
  -- Call the new code
  --
  hr_assignment_api.create_secondary_emp_asg(
   p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_person_id                    => p_person_id
  ,p_organization_id              => p_organization_id
  ,p_grade_id                     => p_grade_id
  ,p_position_id                  => p_position_id
  ,p_job_id                       => p_job_id
  ,p_assignment_status_type_id    => p_assignment_status_type_id
  ,p_payroll_id                   => p_payroll_id
  ,p_location_id                  => p_location_id
  ,p_supervisor_id                => p_supervisor_id
  ,p_special_ceiling_step_id      => p_special_ceiling_step_id
  ,p_pay_basis_id                 => p_pay_basis_id
  ,p_assignment_number            => l_assignment_number
  ,p_change_reason                => p_change_reason
  ,p_comments                     => p_comments
  ,p_date_probation_end           => p_date_probation_end
  ,p_default_code_comb_id         => p_default_code_comb_id
  ,p_employment_category          => p_employment_category
  ,p_frequency                    => p_frequency
  ,p_internal_address_line        => p_internal_address_line
  ,p_manager_flag                 => p_manager_flag
  ,p_normal_hours                 => p_normal_hours
  ,p_perf_review_period           => p_perf_review_period
  ,p_perf_review_period_frequency => p_perf_review_period_frequency
  ,p_probation_period             => p_probation_period
  ,p_probation_unit               => p_probation_unit
  ,p_sal_review_period            => p_sal_review_period
  ,p_sal_review_period_frequency  => p_sal_review_period_frequency
  ,p_set_of_books_id              => p_set_of_books_id
  ,p_source_type                  => p_source_type
  ,p_time_normal_finish           => p_time_normal_finish
  ,p_time_normal_start            => p_time_normal_start
  ,p_bargaining_unit_code         => p_bargaining_unit_code
  ,p_labour_union_member_flag     => p_labour_union_member_flag
  ,p_hourly_salaried_code         => p_hourly_salaried_code
  ,p_notice_period                => p_notice_period
  ,p_notice_period_uom            => p_notice_period_uom
  ,p_employee_category            => p_employee_category
  ,p_work_at_home                 => p_work_at_home
  ,p_job_post_source_name         => p_job_post_source_name
  ,p_ass_attribute_category       => p_ass_attribute_category
  ,p_ass_attribute1               => p_ass_attribute1
  ,p_ass_attribute2               => p_ass_attribute2
  ,p_ass_attribute3               => p_ass_attribute3
  ,p_ass_attribute4               => p_ass_attribute4
  ,p_ass_attribute5               => p_ass_attribute5
  ,p_ass_attribute6               => p_ass_attribute6
  ,p_ass_attribute7               => p_ass_attribute7
  ,p_ass_attribute8               => p_ass_attribute8
  ,p_ass_attribute9               => p_ass_attribute9
  ,p_ass_attribute10              => p_ass_attribute10
  ,p_ass_attribute11              => p_ass_attribute11
  ,p_ass_attribute12              => p_ass_attribute12
  ,p_ass_attribute13              => p_ass_attribute13
  ,p_ass_attribute14              => p_ass_attribute14
  ,p_ass_attribute15              => p_ass_attribute15
  ,p_ass_attribute16              => p_ass_attribute16
  ,p_ass_attribute17              => p_ass_attribute17
  ,p_ass_attribute18              => p_ass_attribute18
  ,p_ass_attribute19              => p_ass_attribute19
  ,p_ass_attribute20              => p_ass_attribute20
  ,p_ass_attribute21              => p_ass_attribute21
  ,p_ass_attribute22              => p_ass_attribute22
  ,p_ass_attribute23              => p_ass_attribute23
  ,p_ass_attribute24              => p_ass_attribute24
  ,p_ass_attribute25              => p_ass_attribute25
  ,p_ass_attribute26              => p_ass_attribute26
  ,p_ass_attribute27              => p_ass_attribute27
  ,p_ass_attribute28              => p_ass_attribute28
  ,p_ass_attribute29              => p_ass_attribute29
  ,p_ass_attribute30              => p_ass_attribute30
  ,p_title                        => p_title
  ,p_scl_segment1                 => p_scl_segment1
  ,p_scl_segment2                 => p_scl_segment2
  ,p_scl_segment3                 => p_scl_segment3
  ,p_scl_segment4                 => p_scl_segment4
  ,p_scl_segment5                 => p_scl_segment5
  ,p_scl_segment6                 => p_scl_segment6
  ,p_scl_segment7                 => p_scl_segment7
  ,p_scl_segment8                 => p_scl_segment8
  ,p_scl_segment9                 => p_scl_segment9
  ,p_scl_segment10                => p_scl_segment10
  ,p_scl_segment11                => p_scl_segment11
  ,p_scl_segment12                => p_scl_segment12
  ,p_scl_segment13                => p_scl_segment13
  ,p_scl_segment14                => p_scl_segment14
  ,p_scl_segment15                => p_scl_segment15
  ,p_scl_segment16                => p_scl_segment16
  ,p_scl_segment17                => p_scl_segment17
  ,p_scl_segment18                => p_scl_segment18
  ,p_scl_segment19                => p_scl_segment19
  ,p_scl_segment20                => p_scl_segment20
  ,p_scl_segment21                => p_scl_segment21
  ,p_scl_segment22                => p_scl_segment22
  ,p_scl_segment23                => p_scl_segment23
  ,p_scl_segment24                => p_scl_segment24
  ,p_scl_segment25                => p_scl_segment25
  ,p_scl_segment26                => p_scl_segment26
  ,p_scl_segment27                => p_scl_segment27
  ,p_scl_segment28                => p_scl_segment28
  ,p_scl_segment29                => p_scl_segment29
  ,p_scl_segment30                => p_scl_segment30
  ,p_scl_concat_segments          => p_scl_concat_segments
  ,p_pgp_segment1                 => p_pgp_segment1
  ,p_pgp_segment2                 => p_pgp_segment2
  ,p_pgp_segment3                 => p_pgp_segment3
  ,p_pgp_segment4                 => p_pgp_segment4
  ,p_pgp_segment5                 => p_pgp_segment5
  ,p_pgp_segment6                 => p_pgp_segment6
  ,p_pgp_segment7                 => p_pgp_segment7
  ,p_pgp_segment8                 => p_pgp_segment8
  ,p_pgp_segment9                 => p_pgp_segment9
  ,p_pgp_segment10                => p_pgp_segment10
  ,p_pgp_segment11                => p_pgp_segment11
  ,p_pgp_segment12                => p_pgp_segment12
  ,p_pgp_segment13                => p_pgp_segment13
  ,p_pgp_segment14                => p_pgp_segment14
  ,p_pgp_segment15                => p_pgp_segment15
  ,p_pgp_segment16                => p_pgp_segment16
  ,p_pgp_segment17                => p_pgp_segment17
  ,p_pgp_segment18                => p_pgp_segment18
  ,p_pgp_segment19                => p_pgp_segment19
  ,p_pgp_segment20                => p_pgp_segment20
  ,p_pgp_segment21                => p_pgp_segment21
  ,p_pgp_segment22                => p_pgp_segment22
  ,p_pgp_segment23                => p_pgp_segment23
  ,p_pgp_segment24                => p_pgp_segment24
  ,p_pgp_segment25                => p_pgp_segment25
  ,p_pgp_segment26                => p_pgp_segment26
  ,p_pgp_segment27                => p_pgp_segment27
  ,p_pgp_segment28                => p_pgp_segment28
  ,p_pgp_segment29                => p_pgp_segment29
  ,p_pgp_segment30                => p_pgp_segment30
  ,p_pgp_concat_segments          => p_pgp_concat_segments
  ,p_contract_id                  => p_contract_id
  ,p_establishment_id             => p_establishment_id
  ,p_collective_agreement_id      => p_collective_agreement_id
  ,p_cagr_id_flex_num             => p_cagr_id_flex_num
  ,p_cag_segment1                 => p_cag_segment1
  ,p_cag_segment2                 => p_cag_segment2
  ,p_cag_segment3                 => p_cag_segment3
  ,p_cag_segment4                 => p_cag_segment4
  ,p_cag_segment5                 => p_cag_segment5
  ,p_cag_segment6                 => p_cag_segment6
  ,p_cag_segment7                 => p_cag_segment7
  ,p_cag_segment8                 => p_cag_segment8
  ,p_cag_segment9                 => p_cag_segment9
  ,p_cag_segment10                => p_cag_segment10
  ,p_cag_segment11                => p_cag_segment11
  ,p_cag_segment12                => p_cag_segment12
  ,p_cag_segment13                => p_cag_segment13
  ,p_cag_segment14                => p_cag_segment14
  ,p_cag_segment15                => p_cag_segment15
  ,p_cag_segment16                => p_cag_segment16
  ,p_cag_segment17                => p_cag_segment17
  ,p_cag_segment18                => p_cag_segment18
  ,p_cag_segment19                => p_cag_segment19
  ,p_cag_segment20                => p_cag_segment20
  ,p_cagr_grade_def_id            => l_cagr_grade_def_id -- bug 2359997
  ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
  ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
  ,p_supervisor_assignment_id     => p_supervisor_assignment_id
  ,p_assignment_id                => l_assignment_id
  ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
  ,p_people_group_id              => l_people_group_id
  ,p_object_version_number        => l_object_version_number
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ,p_assignment_sequence          => l_assignment_sequence
  ,p_comment_id                   => l_comment_id
  ,p_concatenated_segments        => l_concatenated_segments
  ,p_group_name                   => l_group_name
  ,p_other_manager_warning        => l_other_manager_warning
  ,p_hourly_salaried_warning      => l_hourly_salaried_warning
  ,p_gsp_post_process_warning     => l_gsp_post_process_warning -- bug 2999562
   );
  --
  -- Set remaining output arguments
  --
  p_assignment_id               := l_assignment_id;
  p_soft_coding_keyflex_id      := l_soft_coding_keyflex_id;
  p_people_group_id             := l_people_group_id;
  p_object_version_number       := l_object_version_number;
  p_effective_start_date        := l_effective_start_date;
  p_effective_end_date          := l_effective_end_date;
  p_assignment_sequence         := l_assignment_sequence;
  p_comment_id                  := l_comment_id;
  p_concatenated_segments       := l_concatenated_segments;
  p_group_name                  := l_group_name;
  p_other_manager_warning       := l_other_manager_warning;
  p_cagr_grade_def_id           := l_cagr_grade_def_id;
  p_cagr_concatenated_segments  := l_cagr_concatenated_segments;
  p_hourly_salaried_warning     := l_hourly_salaried_warning;
  --
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 50);
 end if;
end create_secondary_emp_asg;
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_secondary_emp_asg >-NEW3---------------------|
-- ----------------------------------------------------------------------------
--
--   This is the new Overloded procedure to include p_post_process_warning_msg
--   out parameter
--
procedure create_secondary_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_supervisor_id                in     number
  ,p_special_ceiling_step_id      in     number
  ,p_pay_basis_id                 in     number
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_employment_category          in     varchar2
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_scl_segment1                 in     varchar2
  ,p_scl_segment2                 in     varchar2
  ,p_scl_segment3                 in     varchar2
  ,p_scl_segment4                 in     varchar2
  ,p_scl_segment5                 in     varchar2
  ,p_scl_segment6                 in     varchar2
  ,p_scl_segment7                 in     varchar2
  ,p_scl_segment8                 in     varchar2
  ,p_scl_segment9                 in     varchar2
  ,p_scl_segment10                in     varchar2
  ,p_scl_segment11                in     varchar2
  ,p_scl_segment12                in     varchar2
  ,p_scl_segment13                in     varchar2
  ,p_scl_segment14                in     varchar2
  ,p_scl_segment15                in     varchar2
  ,p_scl_segment16                in     varchar2
  ,p_scl_segment17                in     varchar2
  ,p_scl_segment18                in     varchar2
  ,p_scl_segment19                in     varchar2
  ,p_scl_segment20                in     varchar2
  ,p_scl_segment21                in     varchar2
  ,p_scl_segment22                in     varchar2
  ,p_scl_segment23                in     varchar2
  ,p_scl_segment24                in     varchar2
  ,p_scl_segment25                in     varchar2
  ,p_scl_segment26                in     varchar2
  ,p_scl_segment27                in     varchar2
  ,p_scl_segment28                in     varchar2
  ,p_scl_segment29                in     varchar2
  ,p_scl_segment30                in     varchar2
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
  ,p_scl_concat_segments    	  in 	 varchar2
  ,p_pgp_segment1                 in     varchar2
  ,p_pgp_segment2                 in     varchar2
  ,p_pgp_segment3                 in     varchar2
  ,p_pgp_segment4                 in     varchar2
  ,p_pgp_segment5                 in     varchar2
  ,p_pgp_segment6                 in     varchar2
  ,p_pgp_segment7                 in     varchar2
  ,p_pgp_segment8                 in     varchar2
  ,p_pgp_segment9                 in     varchar2
  ,p_pgp_segment10                in     varchar2
  ,p_pgp_segment11                in     varchar2
  ,p_pgp_segment12                in     varchar2
  ,p_pgp_segment13                in     varchar2
  ,p_pgp_segment14                in     varchar2
  ,p_pgp_segment15                in     varchar2
  ,p_pgp_segment16                in     varchar2
  ,p_pgp_segment17                in     varchar2
  ,p_pgp_segment18                in     varchar2
  ,p_pgp_segment19                in     varchar2
  ,p_pgp_segment20                in     varchar2
  ,p_pgp_segment21                in     varchar2
  ,p_pgp_segment22                in     varchar2
  ,p_pgp_segment23                in     varchar2
  ,p_pgp_segment24                in     varchar2
  ,p_pgp_segment25                in     varchar2
  ,p_pgp_segment26                in     varchar2
  ,p_pgp_segment27                in     varchar2
  ,p_pgp_segment28                in     varchar2
  ,p_pgp_segment29                in     varchar2
  ,p_pgp_segment30                in     varchar2
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
  ,p_pgp_concat_segments	  in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_collective_agreement_id      in     number
  ,p_cagr_id_flex_num             in     number
  ,p_cag_segment1                 in     varchar2
  ,p_cag_segment2                 in     varchar2
  ,p_cag_segment3                 in     varchar2
  ,p_cag_segment4                 in     varchar2
  ,p_cag_segment5                 in     varchar2
  ,p_cag_segment6                 in     varchar2
  ,p_cag_segment7                 in     varchar2
  ,p_cag_segment8                 in     varchar2
  ,p_cag_segment9                 in     varchar2
  ,p_cag_segment10                in     varchar2
  ,p_cag_segment11                in     varchar2
  ,p_cag_segment12                in     varchar2
  ,p_cag_segment13                in     varchar2
  ,p_cag_segment14                in     varchar2
  ,p_cag_segment15                in     varchar2
  ,p_cag_segment16                in     varchar2
  ,p_cag_segment17                in     varchar2
  ,p_cag_segment18                in     varchar2
  ,p_cag_segment19                in     varchar2
  ,p_cag_segment20                in     varchar2
  ,p_notice_period		  in	 number
  ,p_notice_period_uom		  in     varchar2
  ,p_employee_category		  in     varchar2
  ,p_work_at_home		  in	 varchar2
  ,p_job_post_source_name         in     varchar2
  ,p_grade_ladder_pgm_id          in     number
  ,p_supervisor_assignment_id     in     number
  ,p_group_name                      out nocopy varchar2
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
-- As advised renaming p_scl_concatenated_segments to p_concatenated_segments
-- This has been done through out the procedures
  ,p_concatenated_segments           out nocopy varchar2
  ,p_cagr_grade_def_id            in out nocopy number  -- bug 2359997
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number  -- bug 2359997
  ,p_people_group_id              in out nocopy number  -- bug 2359997
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ,p_gsp_post_process_warning        out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_assignment_id           per_all_assignments_f.assignment_id%TYPE;
  l_soft_coding_keyflex_id  per_all_assignments_f.soft_coding_keyflex_id%TYPE
  := p_soft_coding_keyflex_id;
  l_people_group_id         per_all_assignments_f.people_group_id%TYPE
  := p_people_group_id;
  l_object_version_number   per_all_assignments_f.object_version_number%TYPE;
  l_effective_start_date    per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date      per_all_assignments_f.effective_end_date%TYPE;
  l_assignment_sequence     per_all_assignments_f.assignment_sequence%TYPE;
  l_assignment_number       per_all_assignments_f.assignment_number%TYPE;
  l_comment_id              per_all_assignments_f.comment_id%TYPE;
  l_concatenated_segments   hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_old_scl_conc_segments   hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_group_name              pay_people_groups.group_name%TYPE;
  l_old_group_name          pay_people_groups.group_name%TYPE;
  l_other_manager_warning   boolean;
  l_hourly_salaried_warning boolean;
  l_effective_date          date;
  l_date_probation_end      per_all_assignments_f.date_probation_end%TYPE;
  l_flex_num                fnd_id_flex_segments.id_flex_num%TYPE;
  l_scl_flex_num            fnd_id_flex_segments.id_flex_num%TYPE;
  l_grp_flex_num            fnd_id_flex_segments.id_flex_num%TYPE;
  --
  l_business_group_id       per_business_groups.business_group_id%TYPE;
  l_legislation_code        per_business_groups.legislation_code%TYPE;
  l_period_of_service_id    per_all_assignments_f.period_of_service_id%TYPE;
  l_proc                    varchar2(72) := g_package||
  'create_secondary_emp_asg';
  l_session_id              number;
  l_cagr_grade_def_id       per_cagr_grades_def.cagr_grade_def_id%TYPE
  := p_cagr_grade_def_id;
  l_cagr_concatenated_segments varchar2(2000);

  l_gsp_post_process_warning   varchar2(2000); -- bug 2999562
  --
  -- bug 2359997 new variables to indicate whether key flex id parameters
  -- enter the program with a value.
  --
  l_pgp_null_ind               number(1) := 0;
  l_scl_null_ind               number(1) := 0;
  l_cag_null_ind               number(1) := 0;
  --
  -- Bug 2359997 new variables for derived values where key flex id is known.
  --
  l_scl_segment1               varchar2(60) := p_scl_segment1;
  l_scl_segment2               varchar2(60) := p_scl_segment2;
  l_scl_segment3               varchar2(60) := p_scl_segment3;
  l_scl_segment4               varchar2(60) := p_scl_segment4;
  l_scl_segment5               varchar2(60) := p_scl_segment5;
  l_scl_segment6               varchar2(60) := p_scl_segment6;
  l_scl_segment7               varchar2(60) := p_scl_segment7;
  l_scl_segment8               varchar2(60) := p_scl_segment8;
  l_scl_segment9               varchar2(60) := p_scl_segment9;
  l_scl_segment10              varchar2(60) := p_scl_segment10;
  l_scl_segment11              varchar2(60) := p_scl_segment11;
  l_scl_segment12              varchar2(60) := p_scl_segment12;
  l_scl_segment13              varchar2(60) := p_scl_segment13;
  l_scl_segment14              varchar2(60) := p_scl_segment14;
  l_scl_segment15              varchar2(60) := p_scl_segment15;
  l_scl_segment16              varchar2(60) := p_scl_segment16;
  l_scl_segment17              varchar2(60) := p_scl_segment17;
  l_scl_segment18              varchar2(60) := p_scl_segment18;
  l_scl_segment19              varchar2(60) := p_scl_segment19;
  l_scl_segment20              varchar2(60) := p_scl_segment20;
  l_scl_segment21              varchar2(60) := p_scl_segment21;
  l_scl_segment22              varchar2(60) := p_scl_segment22;
  l_scl_segment23              varchar2(60) := p_scl_segment23;
  l_scl_segment24              varchar2(60) := p_scl_segment24;
  l_scl_segment25              varchar2(60) := p_scl_segment25;
  l_scl_segment26              varchar2(60) := p_scl_segment26;
  l_scl_segment27              varchar2(60) := p_scl_segment27;
  l_scl_segment28              varchar2(60) := p_scl_segment28;
  l_scl_segment29              varchar2(60) := p_scl_segment29;
  l_scl_segment30              varchar2(60) := p_scl_segment30;
  --
  l_pgp_segment1               varchar2(60) := p_pgp_segment1;
  l_pgp_segment2               varchar2(60) := p_pgp_segment2;
  l_pgp_segment3               varchar2(60) := p_pgp_segment3;
  l_pgp_segment4               varchar2(60) := p_pgp_segment4;
  l_pgp_segment5               varchar2(60) := p_pgp_segment5;
  l_pgp_segment6               varchar2(60) := p_pgp_segment6;
  l_pgp_segment7               varchar2(60) := p_pgp_segment7;
  l_pgp_segment8               varchar2(60) := p_pgp_segment8;
  l_pgp_segment9               varchar2(60) := p_pgp_segment9;
  l_pgp_segment10              varchar2(60) := p_pgp_segment10;
  l_pgp_segment11              varchar2(60) := p_pgp_segment11;
  l_pgp_segment12              varchar2(60) := p_pgp_segment12;
  l_pgp_segment13              varchar2(60) := p_pgp_segment13;
  l_pgp_segment14              varchar2(60) := p_pgp_segment14;
  l_pgp_segment15              varchar2(60) := p_pgp_segment15;
  l_pgp_segment16              varchar2(60) := p_pgp_segment16;
  l_pgp_segment17              varchar2(60) := p_pgp_segment17;
  l_pgp_segment18              varchar2(60) := p_pgp_segment18;
  l_pgp_segment19              varchar2(60) := p_pgp_segment19;
  l_pgp_segment20              varchar2(60) := p_pgp_segment20;
  l_pgp_segment21              varchar2(60) := p_pgp_segment21;
  l_pgp_segment22              varchar2(60) := p_pgp_segment22;
  l_pgp_segment23              varchar2(60) := p_pgp_segment23;
  l_pgp_segment24              varchar2(60) := p_pgp_segment24;
  l_pgp_segment25              varchar2(60) := p_pgp_segment25;
  l_pgp_segment26              varchar2(60) := p_pgp_segment26;
  l_pgp_segment27              varchar2(60) := p_pgp_segment27;
  l_pgp_segment28              varchar2(60) := p_pgp_segment28;
  l_pgp_segment29              varchar2(60) := p_pgp_segment29;
  l_pgp_segment30              varchar2(60) := p_pgp_segment30;
  --
  l_cag_segment1               varchar2(60) := p_cag_segment1;
  l_cag_segment2               varchar2(60) := p_cag_segment2;
  l_cag_segment3               varchar2(60) := p_cag_segment3;
  l_cag_segment4               varchar2(60) := p_cag_segment4;
  l_cag_segment5               varchar2(60) := p_cag_segment5;
  l_cag_segment6               varchar2(60) := p_cag_segment6;
  l_cag_segment7               varchar2(60) := p_cag_segment7;
  l_cag_segment8               varchar2(60) := p_cag_segment8;
  l_cag_segment9               varchar2(60) := p_cag_segment9;
  l_cag_segment10              varchar2(60) := p_cag_segment10;
  l_cag_segment11              varchar2(60) := p_cag_segment11;
  l_cag_segment12              varchar2(60) := p_cag_segment12;
  l_cag_segment13              varchar2(60) := p_cag_segment13;
  l_cag_segment14              varchar2(60) := p_cag_segment14;
  l_cag_segment15              varchar2(60) := p_cag_segment15;
  l_cag_segment16              varchar2(60) := p_cag_segment16;
  l_cag_segment17              varchar2(60) := p_cag_segment17;
  l_cag_segment18              varchar2(60) := p_cag_segment18;
  l_cag_segment19              varchar2(60) := p_cag_segment19;
  l_cag_segment20              varchar2(60) := p_cag_segment20;
  --
  lv_assignment_number         varchar2(2000) := p_assignment_number ;
  lv_cagr_grade_def_id         number         := p_cagr_grade_def_id ;
  lv_soft_coding_keyflex_id    number         := p_soft_coding_keyflex_id ;
  lv_people_group_id           number         := p_people_group_id ;

  --
  cursor csr_get_derived_details is
    select bus.business_group_id
         , bus.legislation_code
      from per_all_people_f    per
         , per_business_groups_perf bus
     where per.person_id         = p_person_id
     and   l_effective_date      between per.effective_start_date
                                 and     per.effective_end_date
     and   bus.business_group_id = per.business_group_id;
  --
  cursor csr_get_period_of_service is
    select asg.period_of_service_id
      from per_all_assignments_f asg
     where asg.person_id    = p_person_id
     and   l_effective_date between asg.effective_start_date
                            and     asg.effective_end_date
     and   asg.primary_flag = 'Y'
  --
  -- Start of Bug: 2288629.
     and   asg.assignment_type = 'E';
  -- End  of  Bug: 2288629.
  --
  --
  -- the cursor csr_grp_idsel selects the valid id_flex_num
  -- (grp keyflex) for the specified business group
  --
  cursor csr_grp_idsel is
    select people_group_structure
      from per_business_groups_perf
      where business_group_id = l_business_group_id;
  --
  --
  -- the cursor csr_scl_idsel selects the valid id_flex_num
  -- (scl keyflex) for the specified business group
  --
  cursor csr_scl_idsel is
    select plr.rule_mode                       id_flex_num
    from   pay_legislation_rules               plr
    where  plr.legislation_code                = l_legislation_code
    and    plr.rule_type                       = 'S'
    and    exists
          (select 1
           from   fnd_segment_attribute_values fsav
           where  fsav.id_flex_num             = plr.rule_mode
           and    fsav.application_id          = 800
           and    fsav.id_flex_code            = 'SCL'
           and    fsav.segment_attribute_type  = 'ASSIGNMENT'
           and    fsav.attribute_value         = 'Y')
    and    exists
          (select 1
           from   pay_legislation_rules        plr2
           where  plr2.legislation_code        = l_legislation_code
           and    plr2.rule_type               = 'SDL'
           and    plr2.rule_mode               = 'A') ;
  --
  --
  -- bug 2359997 get pay_people_group segment values where
  -- people_group_id is known
  --
  cursor c_pgp_segments is
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
     from   pay_people_groups
     where  people_group_id = l_people_group_id;
  --
  -- bug 2359997 get hr_soft_coding_keyflex segment values where
  -- soft_coding_keyflex_id is known
  --
  cursor c_scl_segments is
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
     from   hr_soft_coding_keyflex
     where  soft_coding_keyflex_id = l_soft_coding_keyflex_id;
  --
  -- bug 2359997 get per_cagr_grades_def segment values where
  -- cagr_grade_def_id is known
  --
  cursor c_cag_segments is
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
            segment20
     from   per_cagr_grades_def
     where  cagr_grade_def_id = l_cagr_grade_def_id;
--
begin
--
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  -- Issue a savepoint.
  --
  -- Truncate the parameter p_effective_date and p_date_probation_end
  -- into local variables
  --
  l_effective_date := trunc(p_effective_date);
  l_date_probation_end := trunc(p_date_probation_end);
  --
  -- Bug 944911
  -- Amended p_scl_concatenated_segments to p_scl_concat_segments
  -- to be an out instead of in out
  l_old_scl_conc_segments:=p_scl_concat_segments;
  -- Bug 944911
  -- Made p_group_name to be out param
  -- and add p_concat_segment to be IN
  -- in case of sec_asg alone made p_pgp_concat_segments as in param
  -- Replaced p_group_name by p_pgp_concat_segments
  l_old_group_name:=p_pgp_concat_segments;
  --
  -- Bug 2359997 - if p_people_group_id enters with
  -- a value then get segment values from pay_people_groups.
  -- Do the same with the key flex ids for hr_soft_coding_keyflex and
  -- per_cagr_grades_def
  --
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  if l_people_group_id is not null
  then
     l_pgp_null_ind := 1;
     --
     open c_pgp_segments;
       fetch c_pgp_segments into l_pgp_segment1,
                                 l_pgp_segment2,
                                 l_pgp_segment3,
                                 l_pgp_segment4,
                                 l_pgp_segment5,
                                 l_pgp_segment6,
                                 l_pgp_segment7,
                                 l_pgp_segment8,
                                 l_pgp_segment9,
                                 l_pgp_segment10,
                                 l_pgp_segment11,
                                 l_pgp_segment12,
                                 l_pgp_segment13,
                                 l_pgp_segment14,
                                 l_pgp_segment15,
                                 l_pgp_segment16,
                                 l_pgp_segment17,
                                 l_pgp_segment18,
                                 l_pgp_segment19,
                                 l_pgp_segment20,
                                 l_pgp_segment21,
                                 l_pgp_segment22,
                                 l_pgp_segment23,
                                 l_pgp_segment24,
                                 l_pgp_segment25,
                                 l_pgp_segment26,
                                 l_pgp_segment27,
                                 l_pgp_segment28,
                                 l_pgp_segment29,
                                 l_pgp_segment30;
     close c_pgp_segments;
  else
     l_pgp_null_ind := 0;
  end if;
  --
  --  use cursor c_scl_segments to bring back segment values if
  --  l_soft_coding_keyflex has a value.
  if l_soft_coding_keyflex_id is not null
  then
     l_scl_null_ind := 1;
     open c_scl_segments;
       fetch c_scl_segments into l_scl_segment1,
                                 l_scl_segment2,
                                 l_scl_segment3,
                                 l_scl_segment4,
                                 l_scl_segment5,
                                 l_scl_segment6,
                                 l_scl_segment7,
                                 l_scl_segment8,
                                 l_scl_segment9,
                                 l_scl_segment10,
                                 l_scl_segment11,
                                 l_scl_segment12,
                                 l_scl_segment13,
                                 l_scl_segment14,
                                 l_scl_segment15,
                                 l_scl_segment16,
                                 l_scl_segment17,
                                 l_scl_segment18,
                                 l_scl_segment19,
                                 l_scl_segment20,
                                 l_scl_segment21,
                                 l_scl_segment22,
                                 l_scl_segment23,
                                 l_scl_segment24,
                                 l_scl_segment25,
                                 l_scl_segment26,
                                 l_scl_segment27,
                                 l_scl_segment28,
                                 l_scl_segment29,
                                 l_scl_segment30;
     close c_scl_segments;
  else
     l_scl_null_ind := 0;
  end if;
  --
  -- if cagr_grade_def_id has a value then use it to get segment values using
  -- cursor cag_segments
  --
  if l_cagr_grade_def_id is not null
  then
     l_cag_null_ind := 1;
     open c_cag_segments;
       fetch c_cag_segments into l_cag_segment1,
                                 l_cag_segment2,
                                 l_cag_segment3,
                                 l_cag_segment4,
                                 l_cag_segment5,
                                 l_cag_segment6,
                                 l_cag_segment7,
                                 l_cag_segment8,
                                 l_cag_segment9,
                                 l_cag_segment10,
                                 l_cag_segment11,
                                 l_cag_segment12,
                                 l_cag_segment13,
                                 l_cag_segment14,
                                 l_cag_segment15,
                                 l_cag_segment16,
                                 l_cag_segment17,
                                 l_cag_segment18,
                                 l_cag_segment19,
                                 l_cag_segment20;
     close c_cag_segments;
  else
     l_cag_null_ind := 0;
  end if;
  --
  savepoint create_secondary_emp_asg;
  --
  begin
  --
    --
    -- Start of API User Hook for the before hook of create_secondary_emp_asg
    --
    hr_assignment_bk1.create_secondary_emp_asg_b
      (p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
      ,p_organization_id              => p_organization_id
      ,p_grade_id                     => p_grade_id
      ,p_position_id                  => p_position_id
      ,p_job_id                       => p_job_id
      ,p_assignment_status_type_id    => p_assignment_status_type_id
      ,p_payroll_id                   => p_payroll_id
      ,p_location_id                  => p_location_id
      ,p_supervisor_id                => p_supervisor_id
      ,p_special_ceiling_step_id      => p_special_ceiling_step_id
      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_assignment_number            => p_assignment_number
      ,p_change_reason                => p_change_reason
      ,p_comments                     => p_comments
      ,p_date_probation_end           => l_date_probation_end
      ,p_default_code_comb_id         => p_default_code_comb_id
      ,p_employment_category          => p_employment_category
      ,p_frequency                    => p_frequency
      ,p_internal_address_line        => p_internal_address_line
      ,p_manager_flag                 => p_manager_flag
      ,p_normal_hours                 => p_normal_hours
      ,p_perf_review_period           => p_perf_review_period
      ,p_perf_review_period_frequency => p_perf_review_period_frequency
      ,p_probation_period             => p_probation_period
      ,p_probation_unit               => p_probation_unit
      ,p_sal_review_period            => p_sal_review_period
      ,p_sal_review_period_frequency  => p_sal_review_period_frequency
      ,p_set_of_books_id              => p_set_of_books_id
      ,p_source_type                  => p_source_type
      ,p_time_normal_finish           => p_time_normal_finish
      ,p_time_normal_start            => p_time_normal_start
      ,p_bargaining_unit_code         => p_bargaining_unit_code
      ,p_labour_union_member_flag     => p_labour_union_member_flag
      ,p_hourly_salaried_code         => p_hourly_salaried_code
      ,p_ass_attribute_category       => p_ass_attribute_category
      ,p_ass_attribute1               => p_ass_attribute1
      ,p_ass_attribute2               => p_ass_attribute2
      ,p_ass_attribute3               => p_ass_attribute3
      ,p_ass_attribute4               => p_ass_attribute4
      ,p_ass_attribute5               => p_ass_attribute5
      ,p_ass_attribute6               => p_ass_attribute6
      ,p_ass_attribute7               => p_ass_attribute7
      ,p_ass_attribute8               => p_ass_attribute8
      ,p_ass_attribute9               => p_ass_attribute9
      ,p_ass_attribute10              => p_ass_attribute10
      ,p_ass_attribute11              => p_ass_attribute11
      ,p_ass_attribute12              => p_ass_attribute12
      ,p_ass_attribute13              => p_ass_attribute13
      ,p_ass_attribute14              => p_ass_attribute14
      ,p_ass_attribute15              => p_ass_attribute15
      ,p_ass_attribute16              => p_ass_attribute16
      ,p_ass_attribute17              => p_ass_attribute17
      ,p_ass_attribute18              => p_ass_attribute18
      ,p_ass_attribute19              => p_ass_attribute19
      ,p_ass_attribute20              => p_ass_attribute20
      ,p_ass_attribute21              => p_ass_attribute21
      ,p_ass_attribute22              => p_ass_attribute22
      ,p_ass_attribute23              => p_ass_attribute23
      ,p_ass_attribute24              => p_ass_attribute24
      ,p_ass_attribute25              => p_ass_attribute25
      ,p_ass_attribute26              => p_ass_attribute26
      ,p_ass_attribute27              => p_ass_attribute27
      ,p_ass_attribute28              => p_ass_attribute28
      ,p_ass_attribute29              => p_ass_attribute29
      ,p_ass_attribute30              => p_ass_attribute30
      ,p_title                        => p_title
       --
       -- Bug 2359997
       -- Amended p_scl/pgp/cag_segments to be l_scl/pgp/cag_segments
       --
      ,p_scl_segment1                 => l_scl_segment1
      ,p_scl_segment2                 => l_scl_segment2
      ,p_scl_segment3                 => l_scl_segment3
      ,p_scl_segment4                 => l_scl_segment4
      ,p_scl_segment5                 => l_scl_segment5
      ,p_scl_segment6                 => l_scl_segment6
      ,p_scl_segment7                 => l_scl_segment7
      ,p_scl_segment8                 => l_scl_segment8
      ,p_scl_segment9                 => l_scl_segment9
      ,p_scl_segment10                => l_scl_segment10
      ,p_scl_segment11                => l_scl_segment11
      ,p_scl_segment12                => l_scl_segment12
      ,p_scl_segment13                => l_scl_segment13
      ,p_scl_segment14                => l_scl_segment14
      ,p_scl_segment15                => l_scl_segment15
      ,p_scl_segment16                => l_scl_segment16
      ,p_scl_segment17                => l_scl_segment17
      ,p_scl_segment18                => l_scl_segment18
      ,p_scl_segment19                => l_scl_segment19
      ,p_scl_segment20                => l_scl_segment20
      ,p_scl_segment21                => l_scl_segment21
      ,p_scl_segment22                => l_scl_segment22
      ,p_scl_segment23                => l_scl_segment23
      ,p_scl_segment24                => l_scl_segment24
      ,p_scl_segment25                => l_scl_segment25
      ,p_scl_segment26                => l_scl_segment26
      ,p_scl_segment27                => l_scl_segment27
      ,p_scl_segment28                => l_scl_segment28
      ,p_scl_segment29                => l_scl_segment29
      ,p_scl_segment30                => l_scl_segment30
      --
      -- Bug 944911
      -- Amended p_scl_concatenated_Segments by p_scl_concat_segments
      --
      ,p_scl_concat_segments          => l_old_scl_conc_segments
      ,p_pgp_segment1                 => l_pgp_segment1
      ,p_pgp_segment2                 => l_pgp_segment2
      ,p_pgp_segment3                 => l_pgp_segment3
      ,p_pgp_segment4                 => l_pgp_segment4
      ,p_pgp_segment5                 => l_pgp_segment5
      ,p_pgp_segment6                 => l_pgp_segment6
      ,p_pgp_segment7                 => l_pgp_segment7
      ,p_pgp_segment8                 => l_pgp_segment8
      ,p_pgp_segment9                 => l_pgp_segment9
      ,p_pgp_segment10                => l_pgp_segment10
      ,p_pgp_segment11                => l_pgp_segment11
      ,p_pgp_segment12                => l_pgp_segment12
      ,p_pgp_segment13                => l_pgp_segment13
      ,p_pgp_segment14                => l_pgp_segment14
      ,p_pgp_segment15                => l_pgp_segment15
      ,p_pgp_segment16                => l_pgp_segment16
      ,p_pgp_segment17                => l_pgp_segment17
      ,p_pgp_segment18                => l_pgp_segment18
      ,p_pgp_segment19                => l_pgp_segment19
      ,p_pgp_segment20                => l_pgp_segment20
      ,p_pgp_segment21                => l_pgp_segment21
      ,p_pgp_segment22                => l_pgp_segment22
      ,p_pgp_segment23                => l_pgp_segment23
      ,p_pgp_segment24                => l_pgp_segment24
      ,p_pgp_segment25                => l_pgp_segment25
      ,p_pgp_segment26                => l_pgp_segment26
      ,p_pgp_segment27                => l_pgp_segment27
      ,p_pgp_segment28                => l_pgp_segment28
      ,p_pgp_segment29                => l_pgp_segment29
      ,p_pgp_segment30                => l_pgp_segment30
      --
      -- Bug 944911
      -- Replaced p_group_name with p_pgp_concat_segments
      --
      ,p_pgp_concat_segments          => l_old_group_name
      ,p_contract_id                  => p_contract_id
      ,p_establishment_id             => p_establishment_id
      ,p_collective_agreement_id      => p_collective_agreement_id
      ,p_cagr_id_flex_num             => p_cagr_id_flex_num
      ,p_cag_segment1                 => l_cag_segment1
      ,p_cag_segment2                 => l_cag_segment2
      ,p_cag_segment3                 => l_cag_segment3
      ,p_cag_segment4                 => l_cag_segment4
      ,p_cag_segment5                 => l_cag_segment5
      ,p_cag_segment6                 => l_cag_segment6
      ,p_cag_segment7                 => l_cag_segment7
      ,p_cag_segment8                 => l_cag_segment8
      ,p_cag_segment9                 => l_cag_segment9
      ,p_cag_segment10                => l_cag_segment10
      ,p_cag_segment11                => l_cag_segment11
      ,p_cag_segment12                => l_cag_segment12
      ,p_cag_segment13                => l_cag_segment13
      ,p_cag_segment14                => l_cag_segment14
      ,p_cag_segment15                => l_cag_segment15
      ,p_cag_segment16                => l_cag_segment16
      ,p_cag_segment17                => l_cag_segment17
      ,p_cag_segment18                => l_cag_segment18
      ,p_cag_segment19                => l_cag_segment19
      ,p_cag_segment20                => l_cag_segment20
      ,p_notice_period		      => p_notice_period
      ,p_notice_period_uom	      => p_notice_period_uom
      ,p_employee_category	      => p_employee_category
      ,p_work_at_home		      => p_work_at_home
      ,p_job_post_source_name	      => p_job_post_source_name
      ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
      ,p_supervisor_assignment_id     => p_supervisor_assignment_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SECONDARY_EMP_ASG'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_secondary_emp_asg
  --
  end;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Validation in addition to Table Handlers
  --
  -- Get person details.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'effective_date'
     ,p_argument_value => l_effective_date
     );
  --
  -- Record the value of in out parameters
  --
  l_assignment_number := p_assignment_number;
  --
  open  csr_get_derived_details;
  fetch csr_get_derived_details
   into l_business_group_id
      , l_legislation_code;
  --
  if csr_get_derived_details%NOTFOUND then
    --
    close csr_get_derived_details;
    --
 if g_debug then
    hr_utility.set_location(l_proc, 15);
 end if;
    --
    hr_utility.set_message(801,'HR_7432_ASG_INVALID_PERSON');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Process Logic
  --
  -- Get period of service from primary assignment.
  --
  open  csr_get_period_of_service;
  fetch csr_get_period_of_service
   into l_period_of_service_id;
  --
  if csr_get_period_of_service%NOTFOUND then
    --
    close csr_get_period_of_service;
    --
 if g_debug then
    hr_utility.set_location(l_proc, 25);
 end if;
    --
    hr_utility.set_message(801,'HR_7436_ASG_NO_PRIM_ASS');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_period_of_service;
 if g_debug then
  hr_utility.set_location(l_proc, 26);
 end if;
  --
  -- insert the profile options and effective date for the flexfield
  -- validation to work
  --
  hr_kflex_utility.set_profiles
  (p_business_group_id => l_business_group_id
  ,p_assignment_id     => l_assignment_id
  ,p_organization_id   => p_organization_id
  ,p_location_id       => p_location_id);
  --
  hr_kflex_utility.set_session_date
  (p_effective_date => l_effective_date
  ,p_session_id     => l_session_id);
  --
  open csr_grp_idsel;
  fetch csr_grp_idsel into l_grp_flex_num;
    if csr_grp_idsel%NOTFOUND then
       close csr_grp_idsel;
          hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE', l_proc);
          hr_utility.set_message_token('STEP','5');
          hr_utility.raise_error;
    else
      close csr_grp_idsel;
    end if;
 if g_debug then
  hr_utility.set_location(l_proc, 27);
 end if;
  --
  --
  -- Bug 2359997 - if key flex parameters have a value then derive segment
  -- values from them
  --
  if l_scl_null_ind = 0
  then
    if l_scl_segment1 is not null
    or l_scl_segment2 is not null
    or l_scl_segment3 is not null
    or l_scl_segment4 is not null
    or l_scl_segment5 is not null
    or l_scl_segment6 is not null
    or l_scl_segment7 is not null
    or l_scl_segment8 is not null
    or l_scl_segment9 is not null
    or l_scl_segment10 is not null
    or l_scl_segment11 is not null
    or l_scl_segment12 is not null
    or l_scl_segment13 is not null
    or l_scl_segment14 is not null
    or l_scl_segment15 is not null
    or l_scl_segment16 is not null
    or l_scl_segment17 is not null
    or l_scl_segment18 is not null
    or l_scl_segment19 is not null
    or l_scl_segment20 is not null
    or l_scl_segment21 is not null
    or l_scl_segment22 is not null
    or l_scl_segment23 is not null
    or l_scl_segment24 is not null
    or l_scl_segment25 is not null
    or l_scl_segment26 is not null
    or l_scl_segment27 is not null
    or l_scl_segment28 is not null
    or l_scl_segment29 is not null
    or l_scl_segment30 is not null
    --
    -- Bug 944911
    -- Added this clause
    --
    --
    or p_scl_concat_segments is not null
    then
      open csr_scl_idsel;
      fetch csr_scl_idsel into l_scl_flex_num;
      if csr_scl_idsel%NOTFOUND
      then
        close csr_scl_idsel;
 if g_debug then
        hr_utility.set_location(l_proc, 28);
 end if;
        --
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP','10');
        hr_utility.raise_error;
      else
        close csr_scl_idsel;
        --
        --
 if g_debug then
        hr_utility.set_location(l_proc, 30);
 end if;
        --
        -- Insert or select the soft_coding_keyflex_id
        --
        hr_kflex_utility.ins_or_sel_keyflex_comb
        (p_appl_short_name        => 'PER'
        ,p_flex_code              => 'SCL'
        ,p_flex_num               => l_scl_flex_num
        ,p_segment1               => l_scl_segment1
        ,p_segment2               => l_scl_segment2
        ,p_segment3               => l_scl_segment3
        ,p_segment4               => l_scl_segment4
        ,p_segment5               => l_scl_segment5
        ,p_segment6               => l_scl_segment6
        ,p_segment7               => l_scl_segment7
        ,p_segment8               => l_scl_segment8
        ,p_segment9               => l_scl_segment9
        ,p_segment10              => l_scl_segment10
        ,p_segment11              => l_scl_segment11
        ,p_segment12              => l_scl_segment12
        ,p_segment13              => l_scl_segment13
        ,p_segment14              => l_scl_segment14
        ,p_segment15              => l_scl_segment15
        ,p_segment16              => l_scl_segment16
        ,p_segment17              => l_scl_segment17
        ,p_segment18              => l_scl_segment18
        ,p_segment19              => l_scl_segment19
        ,p_segment20              => l_scl_segment20
        ,p_segment21              => l_scl_segment21
        ,p_segment22              => l_scl_segment22
        ,p_segment23              => l_scl_segment23
        ,p_segment24              => l_scl_segment24
        ,p_segment25              => l_scl_segment25
        ,p_segment26              => l_scl_segment26
        ,p_segment27              => l_scl_segment27
        ,p_segment28              => l_scl_segment28
        ,p_segment29              => l_scl_segment29
        ,p_segment30              => l_scl_segment30
        ,p_concat_segments_in     => l_old_scl_conc_segments
        ,p_ccid                   => l_soft_coding_keyflex_id
        ,p_concat_segments_out    => l_concatenated_segments
        );
        --
        -- update the combinations column
        --
        update_scl_concat_segs  -- shd this be available for when id known.
        (p_soft_coding_keyflex_id  => l_soft_coding_keyflex_id
        ,p_concatenated_segments   => l_concatenated_segments
        );
      --
      end if; --  if csr_scl_idsel%NOTFOUND
    --
    end if; -- l_scl_segment1 is not null
  --
  end if; -- bug 2359997 if soft coding key flex id came in null
  --
  --
  if l_pgp_null_ind = 0
  then
    --
    -- Insert or select the people_group_id.
    --
    hr_kflex_utility.ins_or_sel_keyflex_comb
    (p_appl_short_name        => 'PAY'
    ,p_flex_code              => 'GRP'
    ,p_flex_num               => l_grp_flex_num
    ,p_segment1               => l_pgp_segment1
    ,p_segment2               => l_pgp_segment2
    ,p_segment3               => l_pgp_segment3
    ,p_segment4               => l_pgp_segment4
    ,p_segment5               => l_pgp_segment5
    ,p_segment6               => l_pgp_segment6
    ,p_segment7               => l_pgp_segment7
    ,p_segment8               => l_pgp_segment8
    ,p_segment9               => l_pgp_segment9
    ,p_segment10              => l_pgp_segment10
    ,p_segment11              => l_pgp_segment11
    ,p_segment12              => l_pgp_segment12
    ,p_segment13              => l_pgp_segment13
    ,p_segment14              => l_pgp_segment14
    ,p_segment15              => l_pgp_segment15
    ,p_segment16              => l_pgp_segment16
    ,p_segment17              => l_pgp_segment17
    ,p_segment18              => l_pgp_segment18
    ,p_segment19              => l_pgp_segment19
    ,p_segment20              => l_pgp_segment20
    ,p_segment21              => l_pgp_segment21
    ,p_segment22              => l_pgp_segment22
    ,p_segment23              => l_pgp_segment23
    ,p_segment24              => l_pgp_segment24
    ,p_segment25              => l_pgp_segment25
    ,p_segment26              => l_pgp_segment26
    ,p_segment27              => l_pgp_segment27
    ,p_segment28              => l_pgp_segment28
    ,p_segment29              => l_pgp_segment29
    ,p_segment30              => l_pgp_segment30
    ,p_concat_segments_in     => l_old_group_name
    ,p_ccid                   => l_people_group_id
    ,p_concat_segments_out    => l_group_name
    );
    --
 if g_debug then
    hr_utility.set_location(l_proc, 35);
 end if;
  --
  end if;  -- bug 2359997 end if people group id null
  --
  -- update the combinations column
  --
  update_pgp_concat_segs
  (p_people_group_id        => l_people_group_id
  ,p_group_name             => l_group_name
  );
  --
  --
  if l_cag_null_ind = 0
  then
    --
    -- select or insert the Collective Agreement grade
    --
    hr_cgd_ins.ins_or_sel
    (p_segment1               => l_cag_segment1
    ,p_segment2               => l_cag_segment2
    ,p_segment3               => l_cag_segment3
    ,p_segment4               => l_cag_segment4
    ,p_segment5               => l_cag_segment5
    ,p_segment6               => l_cag_segment6
    ,p_segment7               => l_cag_segment7
    ,p_segment8               => l_cag_segment8
    ,p_segment9               => l_cag_segment9
    ,p_segment10              => l_cag_segment10
    ,p_segment11              => l_cag_segment11
    ,p_segment12              => l_cag_segment12
    ,p_segment13              => l_cag_segment13
    ,p_segment14              => l_cag_segment14
    ,p_segment15              => l_cag_segment15
    ,p_segment16              => l_cag_segment16
    ,p_segment17              => l_cag_segment17
    ,p_segment18              => l_cag_segment18
    ,p_segment19              => l_cag_segment19
    ,p_segment20              => l_cag_segment20
    ,p_id_flex_num            => p_cagr_id_flex_num
    ,p_business_group_id      => l_business_group_id
    ,p_cagr_grade_def_id      => l_cagr_grade_def_id
    ,p_concatenated_segments  => l_cagr_concatenated_segments
     );
  --
  end if; -- l_cag_null_ind = 0 bug 2359997
  --
 if g_debug then
  hr_utility.set_location(l_proc, 35);
 end if;
  --
  --
  -- Insert secondary assignment
  --
  hr_assignment_internal.create_emp_asg
    (p_effective_date               => l_effective_date
    ,p_legislation_code             => l_legislation_code
    ,p_business_group_id            => l_business_group_id
    ,p_person_id                    => p_person_id
    ,p_organization_id              => p_organization_id
    ,p_primary_flag                 => 'N'
    ,p_period_of_service_id         => l_period_of_service_id
    ,p_grade_id                     => p_grade_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_special_ceiling_step_id      => p_special_ceiling_step_id
    ,p_people_group_id              => l_people_group_id
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comments                     => p_comments
    ,p_date_probation_end           => l_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_employment_category          => p_employment_category
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_notice_period		    => p_notice_period
    ,p_notice_period_uom	    => p_notice_period_uom
    ,p_employee_category	    => p_employee_category
    ,p_work_at_home		    => p_work_at_home
    ,p_job_post_source_name	    => p_job_post_source_name
    ,p_title                        => p_title
    ,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    ,p_collective_agreement_id      => p_collective_agreement_id
    ,p_cagr_id_flex_num             => p_cagr_id_flex_num
    ,p_cagr_grade_def_id            => l_cagr_grade_def_id
    ,p_assignment_id                => l_assignment_id
    ,p_object_version_number        => l_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_assignment_sequence          => l_assignment_sequence
    ,p_comment_id                   => l_comment_id
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
  --
  -- add rows to the security table if it is a current assignment.
  --
  if(l_effective_date <= sysdate) then
    hr_security_internal.add_to_person_list(l_effective_date,l_assignment_id);
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_secondary_emp_asg
    --
    -- Bug 944911
    -- No amendments required for outs as the values carried forward
    -- Adding the 2 additional ins - p_concat_segments and p_pgp_concat_segments
    -- Both with the same value as passed to _b proc
    hr_assignment_bk1.create_secondary_emp_asg_a
      (p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
      ,p_organization_id              => p_organization_id
      ,p_grade_id                     => p_grade_id
      ,p_position_id                  => p_position_id
      ,p_job_id                       => p_job_id
      ,p_assignment_status_type_id    => p_assignment_status_type_id
      ,p_payroll_id                   => p_payroll_id
      ,p_location_id                  => p_location_id
      ,p_supervisor_id                => p_supervisor_id
      ,p_special_ceiling_step_id      => p_special_ceiling_step_id
      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_assignment_number            => p_assignment_number
      ,p_change_reason                => p_change_reason
      ,p_comments                     => p_comments
      ,p_date_probation_end           => l_date_probation_end
      ,p_default_code_comb_id         => p_default_code_comb_id
      ,p_employment_category          => p_employment_category
      ,p_frequency                    => p_frequency
      ,p_internal_address_line        => p_internal_address_line
      ,p_manager_flag                 => p_manager_flag
      ,p_normal_hours                 => p_normal_hours
      ,p_perf_review_period           => p_perf_review_period
      ,p_perf_review_period_frequency => p_perf_review_period_frequency
      ,p_probation_period             => p_probation_period
      ,p_probation_unit               => p_probation_unit
      ,p_sal_review_period            => p_sal_review_period
      ,p_sal_review_period_frequency  => p_sal_review_period_frequency
      ,p_set_of_books_id              => p_set_of_books_id
      ,p_source_type                  => p_source_type
      ,p_time_normal_finish           => p_time_normal_finish
      ,p_time_normal_start            => p_time_normal_start
      ,p_bargaining_unit_code         => p_bargaining_unit_code
      ,p_labour_union_member_flag     => p_labour_union_member_flag
      ,p_hourly_salaried_code         => p_hourly_salaried_code
      ,p_ass_attribute_category       => p_ass_attribute_category
      ,p_ass_attribute1               => p_ass_attribute1
      ,p_ass_attribute2               => p_ass_attribute2
      ,p_ass_attribute3               => p_ass_attribute3
      ,p_ass_attribute4               => p_ass_attribute4
      ,p_ass_attribute5               => p_ass_attribute5
      ,p_ass_attribute6               => p_ass_attribute6
      ,p_ass_attribute7               => p_ass_attribute7
      ,p_ass_attribute8               => p_ass_attribute8
      ,p_ass_attribute9               => p_ass_attribute9
      ,p_ass_attribute10              => p_ass_attribute10
      ,p_ass_attribute11              => p_ass_attribute11
      ,p_ass_attribute12              => p_ass_attribute12
      ,p_ass_attribute13              => p_ass_attribute13
      ,p_ass_attribute14              => p_ass_attribute14
      ,p_ass_attribute15              => p_ass_attribute15
      ,p_ass_attribute16              => p_ass_attribute16
      ,p_ass_attribute17              => p_ass_attribute17
      ,p_ass_attribute18              => p_ass_attribute18
      ,p_ass_attribute19              => p_ass_attribute19
      ,p_ass_attribute20              => p_ass_attribute20
      ,p_ass_attribute21              => p_ass_attribute21
      ,p_ass_attribute22              => p_ass_attribute22
      ,p_ass_attribute23              => p_ass_attribute23
      ,p_ass_attribute24              => p_ass_attribute24
      ,p_ass_attribute25              => p_ass_attribute25
      ,p_ass_attribute26              => p_ass_attribute26
      ,p_ass_attribute27              => p_ass_attribute27
      ,p_ass_attribute28              => p_ass_attribute28
      ,p_ass_attribute29              => p_ass_attribute29
      ,p_ass_attribute30              => p_ass_attribute30
      ,p_title                        => p_title
      ,p_scl_segment1                 => l_scl_segment1
      ,p_scl_segment2                 => l_scl_segment2
      ,p_scl_segment3                 => l_scl_segment3
      ,p_scl_segment4                 => l_scl_segment4
      ,p_scl_segment5                 => l_scl_segment5
      ,p_scl_segment6                 => l_scl_segment6
      ,p_scl_segment7                 => l_scl_segment7
      ,p_scl_segment8                 => l_scl_segment8
      ,p_scl_segment9                 => l_scl_segment9
      ,p_scl_segment10                => l_scl_segment10
      ,p_scl_segment11                => l_scl_segment11
      ,p_scl_segment12                => l_scl_segment12
      ,p_scl_segment13                => l_scl_segment13
      ,p_scl_segment14                => l_scl_segment14
      ,p_scl_segment15                => l_scl_segment15
      ,p_scl_segment16                => l_scl_segment16
      ,p_scl_segment17                => l_scl_segment17
      ,p_scl_segment18                => l_scl_segment18
      ,p_scl_segment19                => l_scl_segment19
      ,p_scl_segment20                => l_scl_segment20
      ,p_scl_segment21                => l_scl_segment21
      ,p_scl_segment22                => l_scl_segment22
      ,p_scl_segment23                => l_scl_segment23
      ,p_scl_segment24                => l_scl_segment24
      ,p_scl_segment25                => l_scl_segment25
      ,p_scl_segment26                => l_scl_segment26
      ,p_scl_segment27                => l_scl_segment27
      ,p_scl_segment28                => l_scl_segment28
      ,p_scl_segment29                => l_scl_segment29
      ,p_scl_segment30                => l_scl_segment30
      --
      -- Bug 944911
      -- Amended p_scl_concatenated_segments to p_concatenated_segments
      --
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_pgp_segment1                 => l_pgp_segment1
      ,p_pgp_segment2                 => l_pgp_segment2
      ,p_pgp_segment3                 => l_pgp_segment3
      ,p_pgp_segment4                 => l_pgp_segment4
      ,p_pgp_segment5                 => l_pgp_segment5
      ,p_pgp_segment6                 => l_pgp_segment6
      ,p_pgp_segment7                 => l_pgp_segment7
      ,p_pgp_segment8                 => l_pgp_segment8
      ,p_pgp_segment9                 => l_pgp_segment9
      ,p_pgp_segment10                => l_pgp_segment10
      ,p_pgp_segment11                => l_pgp_segment11
      ,p_pgp_segment12                => l_pgp_segment12
      ,p_pgp_segment13                => l_pgp_segment13
      ,p_pgp_segment14                => l_pgp_segment14
      ,p_pgp_segment15                => l_pgp_segment15
      ,p_pgp_segment16                => l_pgp_segment16
      ,p_pgp_segment17                => l_pgp_segment17
      ,p_pgp_segment18                => l_pgp_segment18
      ,p_pgp_segment19                => l_pgp_segment19
      ,p_pgp_segment20                => l_pgp_segment20
      ,p_pgp_segment21                => l_pgp_segment21
      ,p_pgp_segment22                => l_pgp_segment22
      ,p_pgp_segment23                => l_pgp_segment23
      ,p_pgp_segment24                => l_pgp_segment24
      ,p_pgp_segment25                => l_pgp_segment25
      ,p_pgp_segment26                => l_pgp_segment26
      ,p_pgp_segment27                => l_pgp_segment27
      ,p_pgp_segment28                => l_pgp_segment28
      ,p_pgp_segment29                => l_pgp_segment29
      ,p_pgp_segment30                => l_pgp_segment30
      ,p_contract_id                  => p_contract_id
      ,p_establishment_id             => p_establishment_id
      ,p_collective_agreement_id      => p_collective_agreement_id
      ,p_cagr_id_flex_num             => p_cagr_id_flex_num
      ,p_cag_segment1                 => l_cag_segment1
      ,p_cag_segment2                 => l_cag_segment2
      ,p_cag_segment3                 => l_cag_segment3
      ,p_cag_segment4                 => l_cag_segment4
      ,p_cag_segment5                 => l_cag_segment5
      ,p_cag_segment6                 => l_cag_segment6
      ,p_cag_segment7                 => l_cag_segment7
      ,p_cag_segment8                 => l_cag_segment8
      ,p_cag_segment9                 => l_cag_segment9
      ,p_cag_segment10                => l_cag_segment10
      ,p_cag_segment11                => l_cag_segment11
      ,p_cag_segment12                => l_cag_segment12
      ,p_cag_segment13                => l_cag_segment13
      ,p_cag_segment14                => l_cag_segment14
      ,p_cag_segment15                => l_cag_segment15
      ,p_cag_segment16                => l_cag_segment16
      ,p_cag_segment17                => l_cag_segment17
      ,p_cag_segment18                => l_cag_segment18
      ,p_cag_segment19                => l_cag_segment19
      ,p_cag_segment20                => l_cag_segment20
      ,p_notice_period		      => p_notice_period
      ,p_notice_period_uom	      => p_notice_period_uom
      ,p_employee_category	      => p_employee_category
      ,p_work_at_home		      => p_work_at_home
      ,p_job_post_source_name	      => p_job_post_source_name
      ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
      ,p_supervisor_assignment_id     => p_supervisor_assignment_id
      ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
      ,p_cagr_grade_def_id            => l_cagr_grade_def_id
      ,p_group_name                   => l_group_name
      ,p_assignment_id                => l_assignment_id
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_people_group_id              => l_people_group_id
      ,p_object_version_number        => l_object_version_number
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_assignment_sequence          => l_assignment_sequence
      ,p_comment_id                   => l_comment_id
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_hourly_salaried_warning      => l_hourly_salaried_warning
      --
      -- Bug 944911
      -- Replaced p_group_name with p_pgp_concat_segments
      --
      ,p_pgp_concat_segments          => l_old_group_name
      --
      -- Bug 944911
      -- Amended p_scl_concatenated_Segments by p_scl_concat_segments
      --
      ,p_scl_concat_segments          => l_old_scl_conc_segments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SECONDARY_EMP_ASG'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_secondary_emp_asg
    --
  end;

  --
  -- call pqh post process procedure -- bug 2999562
  --
  pqh_gsp_post_process.call_pp_from_assignments(
      p_effective_date    => p_effective_date
     ,p_assignment_id     => l_assignment_id    -- BUG 3336246
     ,p_date_track_mode   => NULL
     ,p_warning_mesg      => l_gsp_post_process_warning
  );

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set remaining output arguments
  --
  p_assignment_id          := l_assignment_id;
  p_soft_coding_keyflex_id := l_soft_coding_keyflex_id;
  p_people_group_id        := l_people_group_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_assignment_sequence    := l_assignment_sequence;
  p_comment_id             := l_comment_id;
  p_concatenated_segments  := l_concatenated_segments;
  p_group_name             := l_group_name;
  p_other_manager_warning  := l_other_manager_warning;
  p_cagr_grade_def_id           := l_cagr_grade_def_id;
  p_cagr_concatenated_segments  := l_cagr_concatenated_segments;
  p_hourly_salaried_warning     := l_hourly_salaried_warning;
  p_gsp_post_process_warning    := l_gsp_post_process_warning; -- bug 2999562
  --
  -- remove data from the session table
  hr_kflex_utility.unset_session_date
  (p_session_id     => l_session_id);
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 50);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_secondary_emp_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_assignment_number      := l_assignment_number;
    p_assignment_id          := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_assignment_sequence    := null;
    p_comment_id             := null;
    p_concatenated_segments  := l_old_scl_conc_segments;  -- Bug 944911
    p_group_name             := l_old_group_name;
    p_other_manager_warning  := l_other_manager_warning;
    p_hourly_salaried_warning     := l_hourly_salaried_warning;
    --
    p_cagr_concatenated_segments  := null;
    --
    -- bug 2359997 only re-set to null if key flex ids came in as null.
    --
    if l_pgp_null_ind = 0
    then
       p_people_group_id           := null;
    end if;
    if l_scl_null_ind = 0
    then
       p_soft_coding_keyflex_id    := null;
    end if;
    if l_cag_null_ind = 0
    then
       p_cagr_grade_def_id         := null;
    end if;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_assignment_number      := lv_assignment_number ;
    p_cagr_grade_def_id      := lv_cagr_grade_def_id ;
    p_soft_coding_keyflex_id := lv_soft_coding_keyflex_id ;
    p_people_group_id        := lv_people_group_id ;

    p_object_version_number      := null;
    p_effective_start_date       := null;
    p_effective_end_date         := null;
    p_assignment_sequence        := null;
    p_comment_id                 := null;
    p_other_manager_warning      := null;
    p_hourly_salaried_warning    := null;
    p_cagr_concatenated_segments := null;
    p_assignment_id              := null;
    p_concatenated_segments      := null;
    p_group_name                 := null;
    p_gsp_post_process_warning   := null;

    ROLLBACK TO create_secondary_emp_asg;
    raise;
    --
    -- End of fix.
    --
end create_secondary_emp_asg;
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_secondary_cwk_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_secondary_cwk_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_assignment_number            in out nocopy varchar2
  ,p_assignment_category          in     varchar2
  ,p_assignment_status_type_id    in     number
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_default_code_comb_id         in     number
  ,p_establishment_id             in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_job_id                       in     number
  ,p_labour_union_member_flag     in     varchar2
  ,p_location_id                  in     number
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_position_id                  in     number
  ,p_grade_id                     in     number
  ,p_project_title                in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_supervisor_id                in     number
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_title                        in     varchar2
  ,p_vendor_assignment_number     in     varchar2
  ,p_vendor_employee_number       in     varchar2
  ,p_vendor_id                    in     number
  ,p_vendor_site_id               in     number
  ,p_po_header_id                 in     number
  ,p_po_line_id                   in     number
  ,p_projected_assignment_end     in     date
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_attribute21                  in     varchar2
  ,p_attribute22                  in     varchar2
  ,p_attribute23                  in     varchar2
  ,p_attribute24                  in     varchar2
  ,p_attribute25                  in     varchar2
  ,p_attribute26                  in     varchar2
  ,p_attribute27                  in     varchar2
  ,p_attribute28                  in     varchar2
  ,p_attribute29                  in     varchar2
  ,p_attribute30                  in     varchar2
  ,p_pgp_segment1                 in     varchar2
  ,p_pgp_segment2                 in     varchar2
  ,p_pgp_segment3                 in     varchar2
  ,p_pgp_segment4                 in     varchar2
  ,p_pgp_segment5                 in     varchar2
  ,p_pgp_segment6                 in     varchar2
  ,p_pgp_segment7                 in     varchar2
  ,p_pgp_segment8                 in     varchar2
  ,p_pgp_segment9                 in     varchar2
  ,p_pgp_segment10                in     varchar2
  ,p_pgp_segment11                in     varchar2
  ,p_pgp_segment12                in     varchar2
  ,p_pgp_segment13                in     varchar2
  ,p_pgp_segment14                in     varchar2
  ,p_pgp_segment15                in     varchar2
  ,p_pgp_segment16                in     varchar2
  ,p_pgp_segment17                in     varchar2
  ,p_pgp_segment18                in     varchar2
  ,p_pgp_segment19                in     varchar2
  ,p_pgp_segment20                in     varchar2
  ,p_pgp_segment21                in     varchar2
  ,p_pgp_segment22                in     varchar2
  ,p_pgp_segment23                in     varchar2
  ,p_pgp_segment24                in     varchar2
  ,p_pgp_segment25                in     varchar2
  ,p_pgp_segment26                in     varchar2
  ,p_pgp_segment27                in     varchar2
  ,p_pgp_segment28                in     varchar2
  ,p_pgp_segment29                in     varchar2
  ,p_pgp_segment30                in     varchar2
  ,p_scl_segment1                 in     varchar2
  ,p_scl_segment2                 in     varchar2
  ,p_scl_segment3                 in     varchar2
  ,p_scl_segment4                 in     varchar2
  ,p_scl_segment5                 in     varchar2
  ,p_scl_segment6                 in     varchar2
  ,p_scl_segment7                 in     varchar2
  ,p_scl_segment8                 in     varchar2
  ,p_scl_segment9                 in     varchar2
  ,p_scl_segment10                in     varchar2
  ,p_scl_segment11                in     varchar2
  ,p_scl_segment12                in     varchar2
  ,p_scl_segment13                in     varchar2
  ,p_scl_segment14                in     varchar2
  ,p_scl_segment15                in     varchar2
  ,p_scl_segment16                in     varchar2
  ,p_scl_segment17                in     varchar2
  ,p_scl_segment18                in     varchar2
  ,p_scl_segment19                in     varchar2
  ,p_scl_segment20                in     varchar2
  ,p_scl_segment21                in     varchar2
  ,p_scl_segment22                in     varchar2
  ,p_scl_segment23                in     varchar2
  ,p_scl_segment24                in     varchar2
  ,p_scl_segment25                in     varchar2
  ,p_scl_segment26                in     varchar2
  ,p_scl_segment27                in     varchar2
  ,p_scl_segment28                in     varchar2
  ,p_scl_segment29                in     varchar2
  ,p_scl_segment30                in     varchar2
  ,p_scl_concat_segments          in     varchar2
  ,p_pgp_concat_segments	  in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_people_group_id                 out nocopy number
  ,p_people_group_name               out nocopy varchar2
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ,p_soft_coding_keyflex_id          out nocopy number) IS
  --
  -- Declare LOCAL Variables
  --
  l_proc                    VARCHAR2(72) := g_package||'create_secondary_cwk_asg';
  l_effective_date          DATE;
  l_old_scl_conc_segments   hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_old_group_name          pay_people_groups.group_name%TYPE;
  l_assignment_number       per_all_assignments_f.assignment_number%TYPE;
  l_other_manager_warning   BOOLEAN;
  l_hourly_salaried_warning BOOLEAN;
  l_assignment_id           per_all_assignments_f.assignment_id%TYPE;
  l_soft_coding_keyflex_id  per_all_assignments_f.soft_coding_keyflex_id%TYPE;
  l_people_group_id         per_all_assignments_f.people_group_id%TYPE;
  l_object_version_number   per_all_assignments_f.object_version_number%TYPE;
  l_effective_start_date    per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date      per_all_assignments_f.effective_end_date%TYPE;
  l_assignment_sequence     per_all_assignments_f.assignment_sequence%TYPE;
  l_comment_id              per_all_assignments_f.comment_id%TYPE;
  l_concatenated_segments   hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_group_name              pay_people_groups.group_name%TYPE;
  l_session_id              NUMBER;
  l_business_group_id       per_business_groups.business_group_id%TYPE;
  l_legislation_code        per_business_groups.legislation_code%TYPE;
  l_pop_date_start          DATE;
  --l_date_probation_end      per_all_assignments_f.date_probation_end%TYPE;
  l_flex_num                fnd_id_flex_segments.id_flex_num%TYPE;
  l_scl_flex_num            fnd_id_flex_segments.id_flex_num%TYPE;
  l_grp_flex_num            fnd_id_flex_segments.id_flex_num%TYPE;
  l_vendor_id               NUMBER := p_vendor_id;
  l_vendor_site_id          NUMBER := p_vendor_site_id;
  l_po_header_id            NUMBER := p_po_header_id;
  l_vendor_id_temp          NUMBER;
  l_vendor_site_id_temp     NUMBER;
  l_grade_id                NUMBER := Null; -- Bug 3545065
  --
  lv_assignment_number      varchar2(2000) :=   p_assignment_number ;
  --
  -- Declare Cursors
  --
  cursor csr_get_derived_details is
    select bus.business_group_id
         , bus.legislation_code
      from per_all_people_f    per
         , per_business_groups_perf bus
     where per.person_id         = p_person_id
     and   l_effective_date      between per.effective_start_date
                                 and     per.effective_end_date
     and   bus.business_group_id = per.business_group_id;
  --
  cursor csr_get_period_of_placement is
    select asg.period_of_placement_date_start
      from per_all_assignments_f asg
     where asg.person_id    = p_person_id
     and   l_effective_date between asg.effective_start_date
                            and     asg.effective_end_date
     and   asg.primary_flag = 'Y'
     and asg.assignment_type = 'C'; -- Bug fix 3266813
  --
  -- the cursor csr_grp_idsel selects the valid id_flex_num
  -- (grp keyflex) for the specified business group
  --
  cursor csr_grp_idsel is
    select people_group_structure
      from per_business_groups_perf
      where business_group_id = l_business_group_id;
  --
  --
  -- the cursor csr_scl_idsel selects the valid id_flex_num
  -- (scl keyflex) for the specified business group
  --
  cursor csr_scl_idsel is
    select plr.rule_mode                       id_flex_num
    from   pay_legislation_rules               plr
    where  plr.legislation_code                = l_legislation_code
    and    plr.rule_type                       = 'S'
    and    exists
          (select 1
           from   fnd_segment_attribute_values fsav
           where  fsav.id_flex_num             = plr.rule_mode
           and    fsav.application_id          = 800
           and    fsav.id_flex_code            = 'SCL'
           and    fsav.segment_attribute_type  = 'ASSIGNMENT'
           and    fsav.attribute_value         = 'Y')
    and    exists
          (select 1
           from   pay_legislation_rules        plr2
           where  plr2.legislation_code        = l_legislation_code
           and    plr2.rule_type               = 'SDL'
           and    plr2.rule_mode               = 'A') ;
  --

BEGIN
  --
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  -- Issue a savepoint.
  --
  -- Truncate the parameter p_effective_date and p_date_probation_end
  -- into local variables
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Bug 944911
  -- Amended p_scl_concatenated_segments to p_scl_concat_segments
  -- to be an out instead of in out
  --
  l_old_scl_conc_segments := p_scl_concat_segments;
  --
  -- Bug 944911
  -- Made p_group_name to be out param
  -- and add p_concat_segment to be IN
  -- in case of sec_asg alone made p_pgp_concat_segments as in param
  -- Replaced p_group_name by p_pgp_concat_segments
  --
  l_old_group_name := p_pgp_concat_segments;
  --
  SAVEPOINT create_secondary_cwk_asg;
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of create_secondary_emp_asg
    --
    hr_assignment_bkn.create_secondary_cwk_asg_b
      (p_effective_date               => l_effective_date
      ,p_business_group_id            => p_business_group_id
      ,p_person_id                    => p_person_id
      ,p_organization_id              => p_organization_id
      ,p_assignment_number            => p_assignment_number
      ,p_assignment_category          => p_assignment_category
      ,p_assignment_status_type_id    => p_assignment_status_type_id
      ,p_change_reason                => p_change_reason
      ,p_comments                     => p_comments
      ,p_default_code_comb_id         => p_default_code_comb_id
      ,p_establishment_id             => p_establishment_id
      ,p_frequency                    => p_frequency
      ,p_internal_address_line        => p_internal_address_line
      ,p_job_id                       => p_job_id
      ,p_labour_union_member_flag     => p_labour_union_member_flag
      ,p_location_id                  => p_location_id
      ,p_manager_flag                 => p_manager_flag
      ,p_normal_hours                 => p_normal_hours
      ,p_position_id                  => p_position_id
      ,p_grade_id                     => l_grade_id -- Bug 3545065
      ,p_project_title                => p_project_title
      ,p_set_of_books_id              => p_set_of_books_id
      ,p_source_type                  => p_source_type
      ,p_supervisor_id                => p_supervisor_id
      ,p_time_normal_finish           => p_time_normal_finish
      ,p_time_normal_start            => p_time_normal_start
      ,p_title                        => p_title
      ,p_vendor_assignment_number     => p_vendor_assignment_number
      ,p_vendor_employee_number       => p_vendor_employee_number
      ,p_vendor_id                    => p_vendor_id
      ,p_vendor_site_id               => p_vendor_site_id
      ,p_po_header_id                 => p_po_header_id
      ,p_po_line_id                   => p_po_line_id
      ,p_projected_assignment_end     => p_projected_assignment_end
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
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30
   	  ,p_scl_concat_segments          => l_old_scl_conc_segments
      ,p_pgp_segment1                 => p_pgp_segment1
      ,p_pgp_segment2                 => p_pgp_segment2
      ,p_pgp_segment3                 => p_pgp_segment3
      ,p_pgp_segment4                 => p_pgp_segment4
      ,p_pgp_segment5                 => p_pgp_segment5
      ,p_pgp_segment6                 => p_pgp_segment6
      ,p_pgp_segment7                 => p_pgp_segment7
      ,p_pgp_segment8                 => p_pgp_segment8
      ,p_pgp_segment9                 => p_pgp_segment9
      ,p_pgp_segment10                => p_pgp_segment10
      ,p_pgp_segment11                => p_pgp_segment11
      ,p_pgp_segment12                => p_pgp_segment12
      ,p_pgp_segment13                => p_pgp_segment13
      ,p_pgp_segment14                => p_pgp_segment14
      ,p_pgp_segment15                => p_pgp_segment15
      ,p_pgp_segment16                => p_pgp_segment16
      ,p_pgp_segment17                => p_pgp_segment17
      ,p_pgp_segment18                => p_pgp_segment18
      ,p_pgp_segment19                => p_pgp_segment19
      ,p_pgp_segment20                => p_pgp_segment20
      ,p_pgp_segment21                => p_pgp_segment21
      ,p_pgp_segment22                => p_pgp_segment22
      ,p_pgp_segment23                => p_pgp_segment23
      ,p_pgp_segment24                => p_pgp_segment24
      ,p_pgp_segment25                => p_pgp_segment25
      ,p_pgp_segment26                => p_pgp_segment26
      ,p_pgp_segment27                => p_pgp_segment27
      ,p_pgp_segment28                => p_pgp_segment28
      ,p_pgp_segment29                => p_pgp_segment29
      ,p_pgp_segment30                => p_pgp_segment30
      ,p_scl_segment1                 => p_scl_segment1
      ,p_scl_segment2                 => p_scl_segment2
      ,p_scl_segment3                 => p_scl_segment3
      ,p_scl_segment4                 => p_scl_segment4
      ,p_scl_segment5                 => p_scl_segment5
      ,p_scl_segment6                 => p_scl_segment6
      ,p_scl_segment7                 => p_scl_segment7
      ,p_scl_segment8                 => p_scl_segment8
      ,p_scl_segment9                 => p_scl_segment9
      ,p_scl_segment10                => p_scl_segment10
      ,p_scl_segment11                => p_scl_segment11
      ,p_scl_segment12                => p_scl_segment12
      ,p_scl_segment13                => p_scl_segment13
      ,p_scl_segment14                => p_scl_segment14
      ,p_scl_segment15                => p_scl_segment15
      ,p_scl_segment16                => p_scl_segment16
      ,p_scl_segment17                => p_scl_segment17
      ,p_scl_segment18                => p_scl_segment18
      ,p_scl_segment19                => p_scl_segment19
      ,p_scl_segment20                => p_scl_segment20
      ,p_scl_segment21                => p_scl_segment21
      ,p_scl_segment22                => p_scl_segment22
      ,p_scl_segment23                => p_scl_segment23
      ,p_scl_segment24                => p_scl_segment24
      ,p_scl_segment25                => p_scl_segment25
      ,p_scl_segment26                => p_scl_segment26
      ,p_scl_segment27                => p_scl_segment27
      ,p_scl_segment28                => p_scl_segment28
      ,p_scl_segment29                => p_scl_segment29
      ,p_scl_segment30                => p_scl_segment30
      ,p_pgp_concat_segments          => l_old_group_name
      ,p_supervisor_assignment_id     => p_supervisor_assignment_id
      );
    --
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SECONDARY_CWK_ASG'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_secondary_emp_asg
    --
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Validation in addition to Table Handlers
  --
  -- Get person details.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'effective_date'
     ,p_argument_value => l_effective_date
     );
  --
  -- Record the value of in out parameters
  --
  l_assignment_number := p_assignment_number;
  --
  OPEN  csr_get_derived_details;
  FETCH csr_get_derived_details
   INTO l_business_group_id
      , l_legislation_code;
  --
  if csr_get_derived_details%NOTFOUND then
    --
    close csr_get_derived_details;
    --
 if g_debug then
    hr_utility.set_location(l_proc, 15);
 end if;
    --
    hr_utility.set_message(801,'HR_7432_ASG_INVALID_PERSON');
    hr_utility.raise_error;
	--
  end if;
  --
  close csr_get_derived_details;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Process Logic
  --
  -- Get period of service from primary assignment.
  --
  OPEN  csr_get_period_of_placement;
  FETCH csr_get_period_of_placement INTO l_pop_date_start;
  --
  IF csr_get_period_of_placement%NOTFOUND THEN
    --
    CLOSE csr_get_period_of_placement;
    --
 if g_debug then
    hr_utility.set_location(l_proc, 25);
 end if;
    --
	hr_utility.set_message(801,'HR_7436_ASG_NO_PRIM_ASS');
    hr_utility.raise_error;
	--
  END IF;
  --
  CLOSE csr_get_period_of_placement;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 26);
 end if;
  --
  -- insert the profile options and effective date for the flexfield
  -- validation to work
  --
  hr_kflex_utility.set_profiles
    (p_business_group_id => l_business_group_id
    ,p_assignment_id     => l_assignment_id
    ,p_organization_id   => p_organization_id
    ,p_location_id       => p_location_id);
  --
  hr_kflex_utility.set_session_date
    (p_effective_date => l_effective_date
    ,p_session_id     => l_session_id);
  --
  open csr_grp_idsel;
  fetch csr_grp_idsel into l_grp_flex_num;
  --
  if csr_grp_idsel%NOTFOUND then
    --
    close csr_grp_idsel;
	--
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
	--
  else
    --
    close csr_grp_idsel;
	--
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 27);
 end if;
  --
  if   p_scl_segment1 is not null
    or p_scl_segment2 is not null
    or p_scl_segment3 is not null
    or p_scl_segment4 is not null
    or p_scl_segment5 is not null
    or p_scl_segment6 is not null
    or p_scl_segment7 is not null
    or p_scl_segment8 is not null
    or p_scl_segment9 is not null
    or p_scl_segment10 is not null
    or p_scl_segment11 is not null
    or p_scl_segment12 is not null
    or p_scl_segment13 is not null
    or p_scl_segment14 is not null
    or p_scl_segment15 is not null
    or p_scl_segment16 is not null
    or p_scl_segment17 is not null
    or p_scl_segment18 is not null
    or p_scl_segment19 is not null
    or p_scl_segment20 is not null
    or p_scl_segment21 is not null
    or p_scl_segment22 is not null
    or p_scl_segment23 is not null
    or p_scl_segment24 is not null
    or p_scl_segment25 is not null
    or p_scl_segment26 is not null
    or p_scl_segment27 is not null
    or p_scl_segment28 is not null
    or p_scl_segment29 is not null
    or p_scl_segment30 is not null
    or p_scl_concat_segments is not null then
	--
    open csr_scl_idsel;
    fetch csr_scl_idsel into l_scl_flex_num;
	--
    if csr_scl_idsel%NOTFOUND then
	  --
      close csr_scl_idsel;
	  --
 if g_debug then
      hr_utility.set_location(l_proc, 28);
 end if;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','10');
      hr_utility.raise_error;
	  --
    else
	  --
      close csr_scl_idsel;
      --
 if g_debug then
      hr_utility.set_location(l_proc, 30);
 end if;
      --
      -- Insert or select the soft_coding_keyflex_id
      --
      hr_kflex_utility.ins_or_sel_keyflex_comb
        (p_appl_short_name        => 'PER'
        ,p_flex_code              => 'SCL'
        ,p_flex_num               => l_scl_flex_num
        ,p_segment1               => p_scl_segment1
        ,p_segment2               => p_scl_segment2
        ,p_segment3               => p_scl_segment3
        ,p_segment4               => p_scl_segment4
        ,p_segment5               => p_scl_segment5
        ,p_segment6               => p_scl_segment6
        ,p_segment7               => p_scl_segment7
        ,p_segment8               => p_scl_segment8
        ,p_segment9               => p_scl_segment9
        ,p_segment10              => p_scl_segment10
        ,p_segment11              => p_scl_segment11
        ,p_segment12              => p_scl_segment12
        ,p_segment13              => p_scl_segment13
        ,p_segment14              => p_scl_segment14
        ,p_segment15              => p_scl_segment15
        ,p_segment16              => p_scl_segment16
        ,p_segment17              => p_scl_segment17
        ,p_segment18              => p_scl_segment18
        ,p_segment19              => p_scl_segment19
        ,p_segment20              => p_scl_segment20
        ,p_segment21              => p_scl_segment21
        ,p_segment22              => p_scl_segment22
        ,p_segment23              => p_scl_segment23
        ,p_segment24              => p_scl_segment24
        ,p_segment25              => p_scl_segment25
        ,p_segment26              => p_scl_segment26
        ,p_segment27              => p_scl_segment27
        ,p_segment28              => p_scl_segment28
        ,p_segment29              => p_scl_segment29
        ,p_segment30              => p_scl_segment30
        ,p_concat_segments_in     => l_old_scl_conc_segments
        ,p_ccid                   => l_soft_coding_keyflex_id
        ,p_concat_segments_out    => l_concatenated_segments);
      --
      -- update the combinations column
      --
      update_scl_concat_segs
      (p_soft_coding_keyflex_id  => l_soft_coding_keyflex_id
      ,p_concatenated_segments   => l_concatenated_segments
      );
      --
    end if;
    --
  end if;
  --
  -- Insert of select the people_group_id.
  --
  hr_kflex_utility.ins_or_sel_keyflex_comb
    (p_appl_short_name        => 'PAY'
    ,p_flex_code              => 'GRP'
    ,p_flex_num               => l_grp_flex_num
    ,p_segment1               => p_pgp_segment1
    ,p_segment2               => p_pgp_segment2
    ,p_segment3               => p_pgp_segment3
    ,p_segment4               => p_pgp_segment4
    ,p_segment5               => p_pgp_segment5
    ,p_segment6               => p_pgp_segment6
    ,p_segment7               => p_pgp_segment7
    ,p_segment8               => p_pgp_segment8
    ,p_segment9               => p_pgp_segment9
    ,p_segment10              => p_pgp_segment10
    ,p_segment11              => p_pgp_segment11
    ,p_segment12              => p_pgp_segment12
    ,p_segment13              => p_pgp_segment13
    ,p_segment14              => p_pgp_segment14
    ,p_segment15              => p_pgp_segment15
    ,p_segment16              => p_pgp_segment16
    ,p_segment17              => p_pgp_segment17
    ,p_segment18              => p_pgp_segment18
    ,p_segment19              => p_pgp_segment19
    ,p_segment20              => p_pgp_segment20
    ,p_segment21              => p_pgp_segment21
    ,p_segment22              => p_pgp_segment22
    ,p_segment23              => p_pgp_segment23
    ,p_segment24              => p_pgp_segment24
    ,p_segment25              => p_pgp_segment25
    ,p_segment26              => p_pgp_segment26
    ,p_segment27              => p_pgp_segment27
    ,p_segment28              => p_pgp_segment28
    ,p_segment29              => p_pgp_segment29
    ,p_segment30              => p_pgp_segment30
    ,p_concat_segments_in     => l_old_group_name
    ,p_ccid                   => l_people_group_id
    ,p_concat_segments_out    => l_group_name
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 35);
 end if;

  --
  -- Default the PO Header if the line is passed in and the
  -- header is not.
  --
  IF p_po_line_id IS NOT NULL AND l_po_header_id IS NULL THEN

    l_po_header_id := get_po_for_line
      (p_po_line_id => p_po_line_id);

  END IF;

  --
  -- Default the Supplier if the Site is entered and Supplier is not.
  --
  IF l_vendor_site_id IS NOT NULL AND l_vendor_id IS NULL THEN

    l_vendor_id := get_supplier_for_site
      (p_vendor_site_id => l_vendor_site_id);

  END IF;

  --
  -- Default the supplier details if they are not entered and a
  -- PO is given.
  --
  IF l_po_header_id IS NOT NULL
  AND (l_vendor_id IS NULL OR l_vendor_site_id IS NULL) THEN

    --
    -- Copy the variables temporarily so that if one or the
    -- other values are passed in, the below call does not
    -- override them.  A single call is made because it is
    -- more performant.
    --
    get_supplier_info_for_po
      (p_po_header_id   => l_po_header_id
      ,p_vendor_id      => l_vendor_id_temp
      ,p_vendor_site_id => l_vendor_site_id_temp);

    IF l_vendor_id IS NULL THEN
      l_vendor_id := l_vendor_id_temp;
    END IF;

    IF l_vendor_site_id IS NULL THEN
      l_vendor_site_id := l_vendor_site_id_temp;
    END IF;

  END IF;

 if g_debug then
  hr_utility.set_location(l_proc, 37);
 end if;

  --
  -- update the combinations column
  --
  update_pgp_concat_segs
    (p_people_group_id        => l_people_group_id
    ,p_group_name             => l_group_name);
  --
  -- select or insert the Collective Agreement grade
  --
  /*
  hr_cgd_ins.ins_or_sel
    (p_segment1               => p_cag_segment1
    ,p_segment2               => p_cag_segment2
    ,p_segment3               => p_cag_segment3
    ,p_segment4               => p_cag_segment4
    ,p_segment5               => p_cag_segment5
    ,p_segment6               => p_cag_segment6
    ,p_segment7               => p_cag_segment7
    ,p_segment8               => p_cag_segment8
    ,p_segment9               => p_cag_segment9
    ,p_segment10              => p_cag_segment10
    ,p_segment11              => p_cag_segment11
    ,p_segment12              => p_cag_segment12
    ,p_segment13              => p_cag_segment13
    ,p_segment14              => p_cag_segment14
    ,p_segment15              => p_cag_segment15
    ,p_segment16              => p_cag_segment16
    ,p_segment17              => p_cag_segment17
    ,p_segment18              => p_cag_segment18
    ,p_segment19              => p_cag_segment19
    ,p_segment20              => p_cag_segment20
    ,p_id_flex_num            => p_cagr_id_flex_num
    ,p_business_group_id      => l_business_group_id
    ,p_cagr_grade_def_id      => l_cagr_grade_def_id
    ,p_concatenated_segments  => l_cagr_concatenated_segments);
	*/
  --
  -- Insert secondary assignment
  --
  hr_assignment_internal.create_cwk_asg
    (p_validate                     => p_validate
    ,p_effective_date               => l_effective_date
    ,p_business_group_id            => l_business_group_id
    ,p_legislation_code             => l_legislation_code
    ,p_person_id                    => p_person_id
    ,p_placement_date_start         => l_pop_date_start
    ,p_organization_id              => p_organization_id
    ,p_primary_flag                 => 'N'
    ,p_assignment_number            => l_assignment_number
    ,p_assignment_category          => null
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_change_reason                => p_change_reason
    ,p_comments                     => p_comments
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_employment_category          => p_assignment_category
    ,p_establishment_id             => p_establishment_id
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_job_id                       => p_job_id
    ,p_labor_union_member_flag      => p_labour_union_member_flag
    ,p_location_id                  => p_location_id
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_position_id                  => p_position_id
    -- Bug 3545065, Grade should not be maintained for CWK asg
    -- ,p_grade_id                     => p_grade_id
    ,p_project_title                => p_project_title
    ,p_title                        => p_title
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_supervisor_id                => p_supervisor_id
    ,p_time_normal_start            => p_time_normal_start
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_vendor_assignment_number     => p_vendor_assignment_number
    ,p_vendor_employee_number       => p_vendor_employee_number
    ,p_vendor_id                    => l_vendor_id
    ,p_vendor_site_id               => l_vendor_site_id
    ,p_po_header_id                 => l_po_header_id
    ,p_po_line_id                   => p_po_line_id
    ,p_projected_assignment_end     => p_projected_assignment_end
    ,p_people_group_id              => l_people_group_id
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_ass_attribute_category       => p_attribute_category
    ,p_ass_attribute1               => p_attribute1
    ,p_ass_attribute2               => p_attribute2
    ,p_ass_attribute3               => p_attribute3
    ,p_ass_attribute4               => p_attribute4
    ,p_ass_attribute5               => p_attribute5
    ,p_ass_attribute6               => p_attribute6
    ,p_ass_attribute7               => p_attribute7
    ,p_ass_attribute8               => p_attribute8
    ,p_ass_attribute9               => p_attribute9
    ,p_ass_attribute10              => p_attribute10
    ,p_ass_attribute11              => p_attribute11
    ,p_ass_attribute12              => p_attribute12
    ,p_ass_attribute13              => p_attribute13
    ,p_ass_attribute14              => p_attribute14
    ,p_ass_attribute15              => p_attribute15
    ,p_ass_attribute16              => p_attribute16
    ,p_ass_attribute17              => p_attribute17
    ,p_ass_attribute18              => p_attribute18
    ,p_ass_attribute19              => p_attribute19
    ,p_ass_attribute20              => p_attribute20
    ,p_ass_attribute21              => p_attribute21
    ,p_ass_attribute22              => p_attribute22
    ,p_ass_attribute23              => p_attribute23
    ,p_ass_attribute24              => p_attribute24
    ,p_ass_attribute25              => p_attribute25
    ,p_ass_attribute26              => p_attribute26
    ,p_ass_attribute27              => p_attribute27
    ,p_ass_attribute28              => p_attribute28
    ,p_ass_attribute29              => p_attribute29
    ,p_ass_attribute30              => p_attribute30
    ,p_assignment_id                => l_assignment_id
    ,p_object_version_number        => l_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_assignment_sequence          => l_assignment_sequence
    ,p_comment_id                   => l_comment_id
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
  --
  -- add rows to the security table if it is a current assignment.
  --
  if(l_effective_date <= sysdate) then
    --
    hr_security_internal.add_to_person_list(l_effective_date,l_assignment_id);
	--
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of create_secondary_emp_asg
    --
    -- Bug 944911
    -- No amendments required for outs as the values carried forward
    -- Adding the 2 additional ins - p_concat_segments and p_pgp_concat_segments
    -- Both with the same value as passed to _b proc
	--
    hr_assignment_bkn.create_secondary_cwk_asg_a
      (p_effective_date               => l_effective_date
      ,p_business_group_id            => p_business_group_id
      ,p_person_id                    => p_person_id
      ,p_organization_id              => p_organization_id
      ,p_assignment_number            => l_assignment_number
      ,p_assignment_category          => p_assignment_category
      ,p_assignment_status_type_id    => p_assignment_status_type_id
      ,p_change_reason                => p_change_reason
      ,p_comments                     => p_comments
      ,p_default_code_comb_id         => p_default_code_comb_id
      ,p_establishment_id             => p_establishment_id
      ,p_frequency                    => p_frequency
      ,p_internal_address_line        => p_internal_address_line
      ,p_job_id                       => p_job_id
      ,p_labour_union_member_flag     => p_labour_union_member_flag
      ,p_location_id                  => p_location_id
      ,p_manager_flag                 => p_manager_flag
      ,p_normal_hours                 => p_normal_hours
      ,p_position_id                  => p_position_id
      ,p_grade_id                     => l_grade_id -- Bug 3545065
      ,p_project_title                => p_project_title
      ,p_set_of_books_id              => p_set_of_books_id
      ,p_source_type                  => p_source_type
      ,p_supervisor_id                => p_supervisor_id
      ,p_time_normal_finish           => p_time_normal_finish
      ,p_time_normal_start            => p_time_normal_start
      ,p_title                        => p_title
      ,p_vendor_assignment_number     => p_vendor_assignment_number
      ,p_vendor_employee_number       => p_vendor_employee_number
      ,p_vendor_id                    => l_vendor_id
      ,p_vendor_site_id               => l_vendor_site_id
      ,p_po_header_id                 => l_po_header_id
      ,p_po_line_id                   => p_po_line_id
      ,p_projected_assignment_end     => p_projected_assignment_end
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
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30
      ,p_scl_concat_segments          => l_old_scl_conc_segments
      ,p_pgp_segment1                 => p_pgp_segment1
      ,p_pgp_segment2                 => p_pgp_segment2
      ,p_pgp_segment3                 => p_pgp_segment3
      ,p_pgp_segment4                 => p_pgp_segment4
      ,p_pgp_segment5                 => p_pgp_segment5
      ,p_pgp_segment6                 => p_pgp_segment6
      ,p_pgp_segment7                 => p_pgp_segment7
      ,p_pgp_segment8                 => p_pgp_segment8
      ,p_pgp_segment9                 => p_pgp_segment9
      ,p_pgp_segment10                => p_pgp_segment10
      ,p_pgp_segment11                => p_pgp_segment11
      ,p_pgp_segment12                => p_pgp_segment12
      ,p_pgp_segment13                => p_pgp_segment13
      ,p_pgp_segment14                => p_pgp_segment14
      ,p_pgp_segment15                => p_pgp_segment15
      ,p_pgp_segment16                => p_pgp_segment16
      ,p_pgp_segment17                => p_pgp_segment17
      ,p_pgp_segment18                => p_pgp_segment18
      ,p_pgp_segment19                => p_pgp_segment19
      ,p_pgp_segment20                => p_pgp_segment20
      ,p_pgp_segment21                => p_pgp_segment21
      ,p_pgp_segment22                => p_pgp_segment22
      ,p_pgp_segment23                => p_pgp_segment23
      ,p_pgp_segment24                => p_pgp_segment24
      ,p_pgp_segment25                => p_pgp_segment25
      ,p_pgp_segment26                => p_pgp_segment26
      ,p_pgp_segment27                => p_pgp_segment27
      ,p_pgp_segment28                => p_pgp_segment28
      ,p_pgp_segment29                => p_pgp_segment29
      ,p_pgp_segment30                => p_pgp_segment30
      ,p_scl_segment1                 => p_scl_segment1
      ,p_scl_segment2                 => p_scl_segment2
      ,p_scl_segment3                 => p_scl_segment3
      ,p_scl_segment4                 => p_scl_segment4
      ,p_scl_segment5                 => p_scl_segment5
      ,p_scl_segment6                 => p_scl_segment6
      ,p_scl_segment7                 => p_scl_segment7
      ,p_scl_segment8                 => p_scl_segment8
      ,p_scl_segment9                 => p_scl_segment9
      ,p_scl_segment10                => p_scl_segment10
      ,p_scl_segment11                => p_scl_segment11
      ,p_scl_segment12                => p_scl_segment12
      ,p_scl_segment13                => p_scl_segment13
      ,p_scl_segment14                => p_scl_segment14
      ,p_scl_segment15                => p_scl_segment15
      ,p_scl_segment16                => p_scl_segment16
      ,p_scl_segment17                => p_scl_segment17
      ,p_scl_segment18                => p_scl_segment18
      ,p_scl_segment19                => p_scl_segment19
      ,p_scl_segment20                => p_scl_segment20
      ,p_scl_segment21                => p_scl_segment21
      ,p_scl_segment22                => p_scl_segment22
      ,p_scl_segment23                => p_scl_segment23
      ,p_scl_segment24                => p_scl_segment24
      ,p_scl_segment25                => p_scl_segment25
      ,p_scl_segment26                => p_scl_segment26
      ,p_scl_segment27                => p_scl_segment27
      ,p_scl_segment28                => p_scl_segment28
      ,p_scl_segment29                => p_scl_segment29
      ,p_scl_segment30                => p_scl_segment30
      ,p_pgp_concat_segments          => l_old_group_name
      ,p_assignment_id                => l_assignment_id
      ,p_object_version_number        => l_object_version_number
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_assignment_sequence          => l_assignment_sequence
      ,p_comment_id                   => l_comment_id
      ,p_people_group_id              => l_people_group_id
      ,p_people_group_name            => l_group_name
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_hourly_salaried_warning      => l_hourly_salaried_warning
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_supervisor_assignment_id     => p_supervisor_assignment_id
      );
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
	  --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SECONDARY_CWK_ASG'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_secondary_emp_asg
    --
  END;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
	--
  END IF;
  --
  -- Set remaining output arguments
  --
  p_assignment_number          := l_assignment_number;
  p_assignment_id              := l_assignment_id;
  p_soft_coding_keyflex_id     := l_soft_coding_keyflex_id;
  p_people_group_id            := l_people_group_id;
  p_object_version_number      := l_object_version_number;
  p_effective_start_date       := l_effective_start_date;
  p_effective_end_date         := l_effective_end_date;
  p_assignment_sequence        := l_assignment_sequence;
  p_comment_id                 := l_comment_id;
  p_people_group_name          := l_group_name;
  p_other_manager_warning      := l_other_manager_warning;
  p_hourly_salaried_warning    := l_hourly_salaried_warning;
  --
  -- remove data from the session table
  --
  hr_kflex_utility.unset_session_date
    (p_session_id     => l_session_id);
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 999);
 end if;
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_secondary_cwk_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_assignment_number       := l_assignment_number;
    p_assignment_id           := NULL;
    p_soft_coding_keyflex_id  := NULL;
    p_people_group_id         := NULL;
    p_object_version_number   := NULL;
    p_effective_start_date    := NULL;
    p_effective_end_date      := NULL;
    p_assignment_sequence     := NULL;
    p_comment_id              := NULL;
    p_people_group_name       := l_old_group_name;
    p_other_manager_warning   := l_other_manager_warning;
    p_hourly_salaried_warning := l_hourly_salaried_warning;
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_assignment_number := lv_assignment_number ;

    p_assignment_id             := NULL;
    p_object_version_number     := NULL;
    p_effective_start_date      := NULL;
    p_effective_end_date        := NULL;
    p_assignment_sequence       := NULL;
    p_comment_id                := NULL;
    p_people_group_id           := NULL;
    p_people_group_name         := NULL;
    p_other_manager_warning     := NULL;
    p_hourly_salaried_warning   := NULL;
    p_soft_coding_keyflex_id    := NULL;

    ROLLBACK TO create_secondary_cwk_asg;
    RAISE;
    --
    -- End of fix.
    --
END create_secondary_cwk_asg;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_supplier_info_for_po >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE get_supplier_info_for_po
  (p_po_header_id                 IN            NUMBER
  ,p_vendor_id                       OUT NOCOPY NUMBER
  ,p_vendor_site_id                  OUT NOCOPY NUMBER)
IS

  l_proc              VARCHAR2(72)  :=  g_package||'get_supplier_info_for_po';

  --
  -- Fetch the Supplier and Supplier Site.
  --
  CURSOR csr_get_supplier_info IS
  SELECT poh.vendor_id
        ,poh.vendor_site_id
  FROM   po_temp_labor_headers_v poh
  WHERE  poh.po_header_id = p_po_header_id;

BEGIN

  IF g_debug THEN
    hr_utility.set_location('Entering: ' || l_proc, 10);
  END IF;

  --
  -- If the header is not null, fetch the Supplier info.
  --
  IF p_po_header_id IS NOT NULL THEN

    IF g_debug THEN
      hr_utility.set_location(l_proc, 20);
    END IF;

    OPEN  csr_get_supplier_info;
    FETCH csr_get_supplier_info INTO p_vendor_id
                                    ,p_vendor_site_id;
    CLOSE csr_get_supplier_info;

  END IF;

  IF g_debug THEN
    hr_utility.set_location('Leaving: ' || l_proc, 999);
  END IF;

END get_supplier_info_for_po;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_supplier_for_site >-----------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_supplier_for_site
  (p_vendor_site_id               IN     NUMBER)
RETURN NUMBER IS

  l_proc              VARCHAR2(72)  :=  g_package||'get_supplier_for_site';
  l_vendor_id         NUMBER;

  --
  -- Fetch the Supplier and Supplier Site.
  --
  CURSOR csr_get_supplier IS
  SELECT povs.vendor_id
  FROM   po_vendor_sites_all povs
  WHERE  povs.vendor_site_id = p_vendor_site_id;

BEGIN

  IF g_debug THEN
    hr_utility.set_location('Entering: ' || l_proc, 10);
  END IF;

  --
  -- If the Supplier Site is not null, fetch the Supplier.
  --
  IF p_vendor_site_id IS NOT NULL THEN

    IF g_debug THEN
      hr_utility.set_location(l_proc, 20);
    END IF;

    OPEN  csr_get_supplier;
    FETCH csr_get_supplier INTO l_vendor_id;
    CLOSE csr_get_supplier;

  END IF;

  IF g_debug THEN
    hr_utility.set_location('Leaving: ' || l_proc, 999);
  END IF;

  RETURN l_vendor_id;

END get_supplier_for_site;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_po_for_line >-----------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_po_for_line
  (p_po_line_id                   IN     NUMBER)
RETURN NUMBER IS

  l_proc              VARCHAR2(72)  :=  g_package||'get_po_for_line';
  l_po_header_id      NUMBER;

  --
  -- Fetch the Purchase Order given a line.
  --
  CURSOR csr_get_po IS
  SELECT pol.po_header_id
  FROM   po_temp_labor_lines_v pol
  WHERE  pol.po_line_id = p_po_line_id;

BEGIN

  IF g_debug THEN
    hr_utility.set_location('Entering: ' || l_proc, 10);
  END IF;

  --
  -- If the PO Line is not null, fetch the PO (header).
  --
  IF p_po_line_id IS NOT NULL THEN

    IF g_debug THEN
      hr_utility.set_location(l_proc, 20);
    END IF;

    OPEN  csr_get_po;
    FETCH csr_get_po INTO l_po_header_id;
    CLOSE csr_get_po;

  END IF;

  IF g_debug THEN
    hr_utility.set_location('Leaving: ' || l_proc, 999);
  END IF;

  RETURN l_po_header_id;

END get_po_for_line;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_job_for_po_line >-------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_job_for_po_line
  (p_po_line_id                   IN     NUMBER)
RETURN NUMBER IS

  l_proc              VARCHAR2(72)  :=  g_package||'get_job_for_po_line';
  l_job_id            NUMBER;

  --
  -- Fetch the Purchase Order given a line.
  --
  CURSOR csr_get_job IS
  SELECT pol.job_id
  FROM   po_temp_labor_lines_v pol
  WHERE  pol.po_line_id = p_po_line_id;

BEGIN

  IF g_debug THEN
    hr_utility.set_location('Entering: ' || l_proc, 10);
  END IF;

  --
  -- If the PO Line is not null, fetch the Job.
  --
  IF p_po_line_id IS NOT NULL THEN

    IF g_debug THEN
      hr_utility.set_location(l_proc, 20);
    END IF;

    OPEN  csr_get_job;
    FETCH csr_get_job INTO l_job_id;
    CLOSE csr_get_job;

  END IF;

  IF g_debug THEN
    hr_utility.set_location('Leaving: ' || l_proc, 999);
  END IF;

  RETURN l_job_id;

END get_job_for_po_line;
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_gb_secondary_emp_asg >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_gb_secondary_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_supervisor_id                in     number
  ,p_special_ceiling_step_id      in     number
  ,p_pay_basis_id                 in     number
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_employment_category          in     varchar2
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_pgp_segment1                 in     varchar2
  ,p_pgp_segment2                 in     varchar2
  ,p_pgp_segment3                 in     varchar2
  ,p_pgp_segment4                 in     varchar2
  ,p_pgp_segment5                 in     varchar2
  ,p_pgp_segment6                 in     varchar2
  ,p_pgp_segment7                 in     varchar2
  ,p_pgp_segment8                 in     varchar2
  ,p_pgp_segment9                 in     varchar2
  ,p_pgp_segment10                in     varchar2
  ,p_pgp_segment11                in     varchar2
  ,p_pgp_segment12                in     varchar2
  ,p_pgp_segment13                in     varchar2
  ,p_pgp_segment14                in     varchar2
  ,p_pgp_segment15                in     varchar2
  ,p_pgp_segment16                in     varchar2
  ,p_pgp_segment17                in     varchar2
  ,p_pgp_segment18                in     varchar2
  ,p_pgp_segment19                in     varchar2
  ,p_pgp_segment20                in     varchar2
  ,p_pgp_segment21                in     varchar2
  ,p_pgp_segment22                in     varchar2
  ,p_pgp_segment23                in     varchar2
  ,p_pgp_segment24                in     varchar2
  ,p_pgp_segment25                in     varchar2
  ,p_pgp_segment26                in     varchar2
  ,p_pgp_segment27                in     varchar2
  ,p_pgp_segment28                in     varchar2
  ,p_pgp_segment29                in     varchar2
  ,p_pgp_segment30                in     varchar2
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
  ,p_pgp_concat_segments	  in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_group_name                      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_people_group_id                 out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Assigned the value p_assignment_number for fix of #2823013
  l_assignment_number  per_all_assignments_f.assignment_number%TYPE := p_assignment_number;
  l_effective_date     date;
  l_legislation_code   per_business_groups.legislation_code%TYPE;
  l_proc               varchar2(72);
  --
  -- Declare dummy variables
  l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_soft_coding_keyflex_id per_all_assignments_f.soft_coding_keyflex_id%TYPE;
  --
  -- Declare cursors
  --
  cursor csr_legislation is
    select null
    from per_all_assignments_f paf,
         per_business_groups_perf pbg
    where paf.person_id = p_person_id
    and   l_effective_date between paf.effective_start_date
                           and     paf.effective_end_date
    and   pbg.business_group_id = paf.business_group_id
    and   pbg.legislation_code = 'GB';
  --
  --
begin
 if g_debug then
 l_proc := g_package||'create_gb_secondary_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Initialise local variable
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validation in addition to Table Handlers
  --
  -- Ensure that the employee is within a GB business group
  --
  open csr_legislation;
  fetch csr_legislation
  into l_legislation_code;
  if csr_legislation%notfound then
    close csr_legislation;
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE', 'GB');
    hr_utility.raise_error;
  end if;
  close csr_legislation;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Call create_secondary_emp_asg
  --
-- Bug 944911
-- Amended param p_scl_concatenated_segments to p_concatenated_segments
  hr_assignment_api.create_secondary_emp_asg
  (p_validate                     =>     p_validate
  ,p_effective_date               =>     l_effective_date
  ,p_person_id                    =>     p_person_id
  ,p_organization_id              =>     p_organization_id
  ,p_grade_id                     =>     p_grade_id
  ,p_position_id                  =>     p_position_id
  ,p_job_id                       =>     p_job_id
  ,p_assignment_status_type_id    =>     p_assignment_status_type_id
  ,p_payroll_id                   =>     p_payroll_id
  ,p_location_id                  =>     p_location_id
  ,p_supervisor_id                =>     p_supervisor_id
  ,p_special_ceiling_step_id      =>     p_special_ceiling_step_id
  ,p_pay_basis_id                 =>     p_pay_basis_id
  ,p_assignment_number            =>     l_assignment_number
  ,p_change_reason                =>     p_change_reason
  ,p_comments                     =>     p_comments
  ,p_date_probation_end           =>     trunc(p_date_probation_end)
  ,p_default_code_comb_id         =>     p_default_code_comb_id
  ,p_employment_category          =>     p_employment_category
  ,p_frequency                    =>     p_frequency
  ,p_internal_address_line        =>     p_internal_address_line
  ,p_manager_flag                 =>     p_manager_flag
  ,p_normal_hours                 =>     p_normal_hours
  ,p_perf_review_period           =>     p_perf_review_period
  ,p_perf_review_period_frequency =>     p_perf_review_period_frequency
  ,p_probation_period             =>     p_probation_period
  ,p_probation_unit               =>     p_probation_unit
  ,p_sal_review_period            =>     p_sal_review_period
  ,p_sal_review_period_frequency  =>     p_sal_review_period_frequency
  ,p_set_of_books_id              =>     p_set_of_books_id
  ,p_source_type                  =>     p_source_type
  ,p_time_normal_finish           =>     p_time_normal_finish
  ,p_time_normal_start            =>     p_time_normal_start
  ,p_bargaining_unit_code         =>     p_bargaining_unit_code
  ,p_labour_union_member_flag     =>     p_labour_union_member_flag
  ,p_hourly_salaried_code         =>     p_hourly_salaried_code
  ,p_ass_attribute_category       =>     p_ass_attribute_category
  ,p_ass_attribute1               =>     p_ass_attribute1
  ,p_ass_attribute2               =>     p_ass_attribute2
  ,p_ass_attribute3               =>     p_ass_attribute3
  ,p_ass_attribute4               =>     p_ass_attribute4
  ,p_ass_attribute5               =>     p_ass_attribute5
  ,p_ass_attribute6               =>     p_ass_attribute6
  ,p_ass_attribute7               =>     p_ass_attribute7
  ,p_ass_attribute8               =>     p_ass_attribute8
  ,p_ass_attribute9               =>     p_ass_attribute9
  ,p_ass_attribute10              =>     p_ass_attribute10
  ,p_ass_attribute11              =>     p_ass_attribute11
  ,p_ass_attribute12              =>     p_ass_attribute12
  ,p_ass_attribute13              =>     p_ass_attribute13
  ,p_ass_attribute14              =>     p_ass_attribute14
  ,p_ass_attribute15              =>     p_ass_attribute15
  ,p_ass_attribute16              =>     p_ass_attribute16
  ,p_ass_attribute17              =>     p_ass_attribute17
  ,p_ass_attribute18              =>     p_ass_attribute18
  ,p_ass_attribute19              =>     p_ass_attribute19
  ,p_ass_attribute20              =>     p_ass_attribute20
  ,p_ass_attribute21              =>     p_ass_attribute21
  ,p_ass_attribute22              =>     p_ass_attribute22
  ,p_ass_attribute23              =>     p_ass_attribute23
  ,p_ass_attribute24              =>     p_ass_attribute24
  ,p_ass_attribute25              =>     p_ass_attribute25
  ,p_ass_attribute26              =>     p_ass_attribute26
  ,p_ass_attribute27              =>     p_ass_attribute27
  ,p_ass_attribute28              =>     p_ass_attribute28
  ,p_ass_attribute29              =>     p_ass_attribute29
  ,p_ass_attribute30              =>     p_ass_attribute30
  ,p_title                        =>     p_title
  ,p_pgp_segment1                 =>     p_pgp_segment1
  ,p_pgp_segment2                 =>     p_pgp_segment2
  ,p_pgp_segment3                 =>     p_pgp_segment3
  ,p_pgp_segment4                 =>     p_pgp_segment4
  ,p_pgp_segment5                 =>     p_pgp_segment5
  ,p_pgp_segment6                 =>     p_pgp_segment6
  ,p_pgp_segment7                 =>     p_pgp_segment7
  ,p_pgp_segment8                 =>     p_pgp_segment8
  ,p_pgp_segment9                 =>     p_pgp_segment9
  ,p_pgp_segment10                =>     p_pgp_segment10
  ,p_pgp_segment11                =>     p_pgp_segment11
  ,p_pgp_segment12                =>     p_pgp_segment12
  ,p_pgp_segment13                =>     p_pgp_segment13
  ,p_pgp_segment14                =>     p_pgp_segment14
  ,p_pgp_segment15                =>     p_pgp_segment15
  ,p_pgp_segment16                =>     p_pgp_segment16
  ,p_pgp_segment17                =>     p_pgp_segment17
  ,p_pgp_segment18                =>     p_pgp_segment18
  ,p_pgp_segment19                =>     p_pgp_segment19
  ,p_pgp_segment20                =>     p_pgp_segment20
  ,p_pgp_segment21                =>     p_pgp_segment21
  ,p_pgp_segment22                =>     p_pgp_segment22
  ,p_pgp_segment23                =>     p_pgp_segment23
  ,p_pgp_segment24                =>     p_pgp_segment24
  ,p_pgp_segment25                =>     p_pgp_segment25
  ,p_pgp_segment26                =>     p_pgp_segment26
  ,p_pgp_segment27                =>     p_pgp_segment27
  ,p_pgp_segment28                =>     p_pgp_segment28
  ,p_pgp_segment29                =>     p_pgp_segment29
  ,p_pgp_segment30                =>     p_pgp_segment30
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
-- Amended call - added new param p_pgp_concat_segments
  ,p_pgp_concat_segments          =>     p_pgp_concat_segments
  ,p_group_name                   =>     p_group_name
  ,p_assignment_id                =>     p_assignment_id
  ,p_soft_coding_keyflex_id       =>     l_soft_coding_keyflex_id
  ,p_people_group_id              =>     p_people_group_id
  ,p_object_version_number        =>     p_object_version_number
  ,p_effective_start_date         =>     p_effective_start_date
  ,p_effective_end_date           =>     p_effective_end_date
  ,p_assignment_sequence          =>     p_assignment_sequence
  ,p_comment_id                   =>     p_comment_id
  ,p_concatenated_segments        =>     l_concatenated_segments
  ,p_other_manager_warning        =>     p_other_manager_warning
  ,p_supervisor_assignment_id     =>     p_supervisor_assignment_id
  );
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
 end if;
  --
  end create_gb_secondary_emp_asg;

--
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_gb_secondary_emp_asg >-----------------------|
-- ----------------------------------------------------------------------------
--   Overloded procedure to include p_hourly_salaried_warning
--
procedure create_gb_secondary_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_supervisor_id                in     number
  ,p_special_ceiling_step_id      in     number
  ,p_pay_basis_id                 in     number
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_employment_category          in     varchar2
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_pgp_segment1                 in     varchar2
  ,p_pgp_segment2                 in     varchar2
  ,p_pgp_segment3                 in     varchar2
  ,p_pgp_segment4                 in     varchar2
  ,p_pgp_segment5                 in     varchar2
  ,p_pgp_segment6                 in     varchar2
  ,p_pgp_segment7                 in     varchar2
  ,p_pgp_segment8                 in     varchar2
  ,p_pgp_segment9                 in     varchar2
  ,p_pgp_segment10                in     varchar2
  ,p_pgp_segment11                in     varchar2
  ,p_pgp_segment12                in     varchar2
  ,p_pgp_segment13                in     varchar2
  ,p_pgp_segment14                in     varchar2
  ,p_pgp_segment15                in     varchar2
  ,p_pgp_segment16                in     varchar2
  ,p_pgp_segment17                in     varchar2
  ,p_pgp_segment18                in     varchar2
  ,p_pgp_segment19                in     varchar2
  ,p_pgp_segment20                in     varchar2
  ,p_pgp_segment21                in     varchar2
  ,p_pgp_segment22                in     varchar2
  ,p_pgp_segment23                in     varchar2
  ,p_pgp_segment24                in     varchar2
  ,p_pgp_segment25                in     varchar2
  ,p_pgp_segment26                in     varchar2
  ,p_pgp_segment27                in     varchar2
  ,p_pgp_segment28                in     varchar2
  ,p_pgp_segment29                in     varchar2
  ,p_pgp_segment30                in     varchar2
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
  ,p_pgp_concat_segments	  in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_group_name                      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_people_group_id                 out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Assigned the value p_assignment_number for fix of #2823013
  l_assignment_number  per_all_assignments_f.assignment_number%TYPE := p_assignment_number;
  l_effective_date     date;
  l_legislation_code   per_business_groups.legislation_code%TYPE;
  l_proc               varchar2(72);
  --
  -- Declare dummy variables
  l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_soft_coding_keyflex_id per_all_assignments_f.soft_coding_keyflex_id%TYPE;
  --
  -- Declare cursors
  --
  cursor csr_legislation is
    select null
    from per_all_assignments_f paf,
         per_business_groups_perf pbg
    where paf.person_id = p_person_id
    and   l_effective_date between paf.effective_start_date
                           and     paf.effective_end_date
    and   pbg.business_group_id = paf.business_group_id
    and   pbg.legislation_code = 'GB';
  --
  --
begin
 if g_debug then
 l_proc := g_package||'create_gb_secondary_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Initialise local variable
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validation in addition to Table Handlers
  --
  -- Ensure that the employee is within a GB business group
  --
  open csr_legislation;
  fetch csr_legislation
  into l_legislation_code;
  if csr_legislation%notfound then
    close csr_legislation;
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE', 'GB');
    hr_utility.raise_error;
  end if;
  close csr_legislation;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Call create_secondary_emp_asg
  --
-- Bug 944911
-- Amended param p_scl_concatenated_segments to p_concatenated_segments
  hr_assignment_api.create_secondary_emp_asg
  (p_validate                     =>     p_validate
  ,p_effective_date               =>     l_effective_date
  ,p_person_id                    =>     p_person_id
  ,p_organization_id              =>     p_organization_id
  ,p_grade_id                     =>     p_grade_id
  ,p_position_id                  =>     p_position_id
  ,p_job_id                       =>     p_job_id
  ,p_assignment_status_type_id    =>     p_assignment_status_type_id
  ,p_payroll_id                   =>     p_payroll_id
  ,p_location_id                  =>     p_location_id
  ,p_supervisor_id                =>     p_supervisor_id
  ,p_special_ceiling_step_id      =>     p_special_ceiling_step_id
  ,p_pay_basis_id                 =>     p_pay_basis_id
  ,p_assignment_number            =>     l_assignment_number
  ,p_change_reason                =>     p_change_reason
  ,p_comments                     =>     p_comments
  ,p_date_probation_end           =>     trunc(p_date_probation_end)
  ,p_default_code_comb_id         =>     p_default_code_comb_id
  ,p_employment_category          =>     p_employment_category
  ,p_frequency                    =>     p_frequency
  ,p_internal_address_line        =>     p_internal_address_line
  ,p_manager_flag                 =>     p_manager_flag
  ,p_normal_hours                 =>     p_normal_hours
  ,p_perf_review_period           =>     p_perf_review_period
  ,p_perf_review_period_frequency =>     p_perf_review_period_frequency
  ,p_probation_period             =>     p_probation_period
  ,p_probation_unit               =>     p_probation_unit
  ,p_sal_review_period            =>     p_sal_review_period
  ,p_sal_review_period_frequency  =>     p_sal_review_period_frequency
  ,p_set_of_books_id              =>     p_set_of_books_id
  ,p_source_type                  =>     p_source_type
  ,p_time_normal_finish           =>     p_time_normal_finish
  ,p_time_normal_start            =>     p_time_normal_start
  ,p_bargaining_unit_code         =>     p_bargaining_unit_code
  ,p_labour_union_member_flag     =>     p_labour_union_member_flag
  ,p_hourly_salaried_code         =>     p_hourly_salaried_code
  ,p_ass_attribute_category       =>     p_ass_attribute_category
  ,p_ass_attribute1               =>     p_ass_attribute1
  ,p_ass_attribute2               =>     p_ass_attribute2
  ,p_ass_attribute3               =>     p_ass_attribute3
  ,p_ass_attribute4               =>     p_ass_attribute4
  ,p_ass_attribute5               =>     p_ass_attribute5
  ,p_ass_attribute6               =>     p_ass_attribute6
  ,p_ass_attribute7               =>     p_ass_attribute7
  ,p_ass_attribute8               =>     p_ass_attribute8
  ,p_ass_attribute9               =>     p_ass_attribute9
  ,p_ass_attribute10              =>     p_ass_attribute10
  ,p_ass_attribute11              =>     p_ass_attribute11
  ,p_ass_attribute12              =>     p_ass_attribute12
  ,p_ass_attribute13              =>     p_ass_attribute13
  ,p_ass_attribute14              =>     p_ass_attribute14
  ,p_ass_attribute15              =>     p_ass_attribute15
  ,p_ass_attribute16              =>     p_ass_attribute16
  ,p_ass_attribute17              =>     p_ass_attribute17
  ,p_ass_attribute18              =>     p_ass_attribute18
  ,p_ass_attribute19              =>     p_ass_attribute19
  ,p_ass_attribute20              =>     p_ass_attribute20
  ,p_ass_attribute21              =>     p_ass_attribute21
  ,p_ass_attribute22              =>     p_ass_attribute22
  ,p_ass_attribute23              =>     p_ass_attribute23
  ,p_ass_attribute24              =>     p_ass_attribute24
  ,p_ass_attribute25              =>     p_ass_attribute25
  ,p_ass_attribute26              =>     p_ass_attribute26
  ,p_ass_attribute27              =>     p_ass_attribute27
  ,p_ass_attribute28              =>     p_ass_attribute28
  ,p_ass_attribute29              =>     p_ass_attribute29
  ,p_ass_attribute30              =>     p_ass_attribute30
  ,p_title                        =>     p_title
  ,p_pgp_segment1                 =>     p_pgp_segment1
  ,p_pgp_segment2                 =>     p_pgp_segment2
  ,p_pgp_segment3                 =>     p_pgp_segment3
  ,p_pgp_segment4                 =>     p_pgp_segment4
  ,p_pgp_segment5                 =>     p_pgp_segment5
  ,p_pgp_segment6                 =>     p_pgp_segment6
  ,p_pgp_segment7                 =>     p_pgp_segment7
  ,p_pgp_segment8                 =>     p_pgp_segment8
  ,p_pgp_segment9                 =>     p_pgp_segment9
  ,p_pgp_segment10                =>     p_pgp_segment10
  ,p_pgp_segment11                =>     p_pgp_segment11
  ,p_pgp_segment12                =>     p_pgp_segment12
  ,p_pgp_segment13                =>     p_pgp_segment13
  ,p_pgp_segment14                =>     p_pgp_segment14
  ,p_pgp_segment15                =>     p_pgp_segment15
  ,p_pgp_segment16                =>     p_pgp_segment16
  ,p_pgp_segment17                =>     p_pgp_segment17
  ,p_pgp_segment18                =>     p_pgp_segment18
  ,p_pgp_segment19                =>     p_pgp_segment19
  ,p_pgp_segment20                =>     p_pgp_segment20
  ,p_pgp_segment21                =>     p_pgp_segment21
  ,p_pgp_segment22                =>     p_pgp_segment22
  ,p_pgp_segment23                =>     p_pgp_segment23
  ,p_pgp_segment24                =>     p_pgp_segment24
  ,p_pgp_segment25                =>     p_pgp_segment25
  ,p_pgp_segment26                =>     p_pgp_segment26
  ,p_pgp_segment27                =>     p_pgp_segment27
  ,p_pgp_segment28                =>     p_pgp_segment28
  ,p_pgp_segment29                =>     p_pgp_segment29
  ,p_pgp_segment30                =>     p_pgp_segment30
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
-- Amended call - added new param p_pgp_concat_segments
  ,p_pgp_concat_segments          =>     p_pgp_concat_segments
  ,p_group_name                   =>     p_group_name
  ,p_assignment_id                =>     p_assignment_id
  ,p_soft_coding_keyflex_id       =>     l_soft_coding_keyflex_id
  ,p_people_group_id              =>     p_people_group_id
  ,p_object_version_number        =>     p_object_version_number
  ,p_effective_start_date         =>     p_effective_start_date
  ,p_effective_end_date           =>     p_effective_end_date
  ,p_assignment_sequence          =>     p_assignment_sequence
  ,p_comment_id                   =>     p_comment_id
  ,p_concatenated_segments        =>     l_concatenated_segments
  ,p_other_manager_warning        =>     p_other_manager_warning
  ,p_hourly_salaried_warning      =>     p_hourly_salaried_warning
  ,p_cagr_grade_def_id            =>     p_cagr_grade_def_id
  ,p_cagr_concatenated_segments   =>     p_cagr_concatenated_segments
  ,p_supervisor_assignment_id     =>     p_supervisor_assignment_id
  );
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
 end if;
  --
  end create_gb_secondary_emp_asg;

--
-- ----------------------------------------------------------------------------
-- |---------------------< create_us_secondary_emp_asg >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_us_secondary_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_supervisor_id                in     number
  ,p_special_ceiling_step_id      in     number
  ,p_pay_basis_id                 in     number
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_employment_category          in     varchar2
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_tax_unit                     in     varchar2
  ,p_timecard_approver            in     varchar2
  ,p_timecard_required            in     varchar2
  ,p_work_schedule                in     varchar2
  ,p_shift                        in     varchar2
  ,p_spouse_salary                in     varchar2
  ,p_legal_representative         in     varchar2
  ,p_wc_override_code             in     varchar2
  ,p_eeo_1_establishment          in     varchar2
  ,p_pgp_segment1                 in     varchar2
  ,p_pgp_segment2                 in     varchar2
  ,p_pgp_segment3                 in     varchar2
  ,p_pgp_segment4                 in     varchar2
  ,p_pgp_segment5                 in     varchar2
  ,p_pgp_segment6                 in     varchar2
  ,p_pgp_segment7                 in     varchar2
  ,p_pgp_segment8                 in     varchar2
  ,p_pgp_segment9                 in     varchar2
  ,p_pgp_segment10                in     varchar2
  ,p_pgp_segment11                in     varchar2
  ,p_pgp_segment12                in     varchar2
  ,p_pgp_segment13                in     varchar2
  ,p_pgp_segment14                in     varchar2
  ,p_pgp_segment15                in     varchar2
  ,p_pgp_segment16                in     varchar2
  ,p_pgp_segment17                in     varchar2
  ,p_pgp_segment18                in     varchar2
  ,p_pgp_segment19                in     varchar2
  ,p_pgp_segment20                in     varchar2
  ,p_pgp_segment21                in     varchar2
  ,p_pgp_segment22                in     varchar2
  ,p_pgp_segment23                in     varchar2
  ,p_pgp_segment24                in     varchar2
  ,p_pgp_segment25                in     varchar2
  ,p_pgp_segment26                in     varchar2
  ,p_pgp_segment27                in     varchar2
  ,p_pgp_segment28                in     varchar2
  ,p_pgp_segment29                in     varchar2
  ,p_pgp_segment30                in     varchar2
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
  ,p_pgp_concat_segments	  in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_group_name                      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_people_group_id                 out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
-- Bug 944911
-- Amended p_concatenated_segments to out from in out
-- added new param p_concat_segments in
  ,p_concatenated_segments           out nocopy varchar2
  ,p_concat_segments              in     varchar2
  ,p_other_manager_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Declare variables
  --
  -- WWBUG 2539685
  l_assignment_number  per_all_assignments_f.assignment_number%TYPE := p_assignment_number;
  l_effective_date     date;
  --
  l_business_group_id  per_business_groups.business_group_id%TYPE;
  l_legislation_code   per_business_groups.legislation_code%TYPE;
  l_proc               varchar2(72);
  --
  -- Declare cursors
  --
  cursor csr_legislation is
    select null
    from per_all_assignments_f paf,
         per_business_groups_perf pbg
    where paf.person_id = p_person_id
    and   l_effective_date between paf.effective_start_date
                           and     paf.effective_end_date
    and   pbg.business_group_id = paf.business_group_id
    and   pbg.legislation_code = 'US';
  --
  --
begin
 if g_debug then
 l_proc := g_package||'create_secondary_us_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Initialise local variable
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validation in addition to Table Handlers
  --
  -- Ensure that the employee is within a US business group
  --
  open csr_legislation;
  fetch csr_legislation
  into l_legislation_code;
  if csr_legislation%notfound then
    close csr_legislation;
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE', 'US');
    hr_utility.raise_error;
  end if;
  close csr_legislation;
  --
  --
  -- Call create_secondary_emp_asg
  --
-- Bug 944911
-- Added new param p_concat_segments in
-- made p_concatenated_segments to be out only
-- Amended p_scl_concatenated_segments to be p_concatenated_segments

  hr_assignment_api.create_secondary_emp_asg
  (p_validate                     =>     p_validate
  ,p_effective_date               =>     l_effective_date
  ,p_person_id                    =>     p_person_id
  ,p_organization_id              =>     p_organization_id
  ,p_grade_id                     =>     p_grade_id
  ,p_position_id                  =>     p_position_id
  ,p_job_id                       =>     p_job_id
  ,p_assignment_status_type_id    =>     p_assignment_status_type_id
  ,p_payroll_id                   =>     p_payroll_id
  ,p_location_id                  =>     p_location_id
  ,p_supervisor_id                =>     p_supervisor_id
  ,p_special_ceiling_step_id      =>     p_special_ceiling_step_id
  ,p_pay_basis_id                 =>     p_pay_basis_id
  ,p_assignment_number            =>     l_assignment_number
  ,p_change_reason                =>     p_change_reason
  ,p_comments                     =>     p_comments
  ,p_date_probation_end           =>     trunc(p_date_probation_end)
  ,p_default_code_comb_id         =>     p_default_code_comb_id
  ,p_employment_category          =>     p_employment_category
  ,p_frequency                    =>     p_frequency
  ,p_internal_address_line        =>     p_internal_address_line
  ,p_manager_flag                 =>     p_manager_flag
  ,p_normal_hours                 =>     p_normal_hours
  ,p_perf_review_period           =>     p_perf_review_period
  ,p_perf_review_period_frequency =>     p_perf_review_period_frequency
  ,p_probation_period             =>     p_probation_period
  ,p_probation_unit               =>     p_probation_unit
  ,p_sal_review_period            =>     p_sal_review_period
  ,p_sal_review_period_frequency  =>     p_sal_review_period_frequency
  ,p_set_of_books_id              =>     p_set_of_books_id
  ,p_source_type                  =>     p_source_type
  ,p_time_normal_finish           =>     p_time_normal_finish
  ,p_time_normal_start            =>     p_time_normal_start
  ,p_bargaining_unit_code         =>     p_bargaining_unit_code
  ,p_labour_union_member_flag     =>     p_labour_union_member_flag
  ,p_hourly_salaried_code         =>     p_hourly_salaried_code
  ,p_ass_attribute_category       =>     p_ass_attribute_category
  ,p_ass_attribute1               =>     p_ass_attribute1
  ,p_ass_attribute2               =>     p_ass_attribute2
  ,p_ass_attribute3               =>     p_ass_attribute3
  ,p_ass_attribute4               =>     p_ass_attribute4
  ,p_ass_attribute5               =>     p_ass_attribute5
  ,p_ass_attribute6               =>     p_ass_attribute6
  ,p_ass_attribute7               =>     p_ass_attribute7
  ,p_ass_attribute8               =>     p_ass_attribute8
  ,p_ass_attribute9               =>     p_ass_attribute9
  ,p_ass_attribute10              =>     p_ass_attribute10
  ,p_ass_attribute11              =>     p_ass_attribute11
  ,p_ass_attribute12              =>     p_ass_attribute12
  ,p_ass_attribute13              =>     p_ass_attribute13
  ,p_ass_attribute14              =>     p_ass_attribute14
  ,p_ass_attribute15              =>     p_ass_attribute15
  ,p_ass_attribute16              =>     p_ass_attribute16
  ,p_ass_attribute17              =>     p_ass_attribute17
  ,p_ass_attribute18              =>     p_ass_attribute18
  ,p_ass_attribute19              =>     p_ass_attribute19
  ,p_ass_attribute20              =>     p_ass_attribute20
  ,p_ass_attribute21              =>     p_ass_attribute21
  ,p_ass_attribute22              =>     p_ass_attribute22
  ,p_ass_attribute23              =>     p_ass_attribute23
  ,p_ass_attribute24              =>     p_ass_attribute24
  ,p_ass_attribute25              =>     p_ass_attribute25
  ,p_ass_attribute26              =>     p_ass_attribute26
  ,p_ass_attribute27              =>     p_ass_attribute27
  ,p_ass_attribute28              =>     p_ass_attribute28
  ,p_ass_attribute29              =>     p_ass_attribute29
  ,p_ass_attribute30              =>     p_ass_attribute30
  ,p_title                        =>     p_title
  ,p_scl_segment1                 =>     p_tax_unit
  ,p_scl_segment2                 =>     p_timecard_approver
  ,p_scl_segment3                 =>     p_timecard_required
  ,p_scl_segment4                 =>     p_work_schedule
  ,p_scl_segment5                 =>     p_shift
  ,p_scl_segment6                 =>     p_spouse_salary
  ,p_scl_segment7                 =>     p_legal_representative
  ,p_scl_segment8                 =>     p_wc_override_code
  ,p_scl_segment9                 =>     p_eeo_1_establishment
  ,p_pgp_segment1                 =>     p_pgp_segment1
  ,p_pgp_segment2                 =>     p_pgp_segment2
  ,p_pgp_segment3                 =>     p_pgp_segment3
  ,p_pgp_segment4                 =>     p_pgp_segment4
  ,p_pgp_segment5                 =>     p_pgp_segment5
  ,p_pgp_segment6                 =>     p_pgp_segment6
  ,p_pgp_segment7                 =>     p_pgp_segment7
  ,p_pgp_segment8                 =>     p_pgp_segment8
  ,p_pgp_segment9                 =>     p_pgp_segment9
  ,p_pgp_segment10                =>     p_pgp_segment10
  ,p_pgp_segment11                =>     p_pgp_segment11
  ,p_pgp_segment12                =>     p_pgp_segment12
  ,p_pgp_segment13                =>     p_pgp_segment13
  ,p_pgp_segment14                =>     p_pgp_segment14
  ,p_pgp_segment15                =>     p_pgp_segment15
  ,p_pgp_segment16                =>     p_pgp_segment16
  ,p_pgp_segment17                =>     p_pgp_segment17
  ,p_pgp_segment18                =>     p_pgp_segment18
  ,p_pgp_segment19                =>     p_pgp_segment19
  ,p_pgp_segment20                =>     p_pgp_segment20
  ,p_pgp_segment21                =>     p_pgp_segment21
  ,p_pgp_segment22                =>     p_pgp_segment22
  ,p_pgp_segment23                =>     p_pgp_segment23
  ,p_pgp_segment24                =>     p_pgp_segment24
  ,p_pgp_segment25                =>     p_pgp_segment25
  ,p_pgp_segment26                =>     p_pgp_segment26
  ,p_pgp_segment27                =>     p_pgp_segment27
  ,p_pgp_segment28                =>     p_pgp_segment28
  ,p_pgp_segment29                =>     p_pgp_segment29
  ,p_pgp_segment30                =>     p_pgp_segment30
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
-- Added new param p_pgp_concat_segments
  ,p_pgp_concat_segments	  =>	 p_pgp_concat_segments
  ,p_group_name                   =>     p_group_name
  ,p_assignment_id                =>     p_assignment_id
  ,p_soft_coding_keyflex_id       =>     p_soft_coding_keyflex_id
  ,p_people_group_id              =>     p_people_group_id
  ,p_object_version_number        =>     p_object_version_number
  ,p_effective_start_date         =>     p_effective_start_date
  ,p_effective_end_date           =>     p_effective_end_date
  ,p_assignment_sequence          =>     p_assignment_sequence
  ,p_comment_id                   =>     p_comment_id
  ,p_concatenated_segments        =>     p_concatenated_segments
  ,p_scl_concat_segments          =>     p_concat_segments
  ,p_other_manager_warning        =>     p_other_manager_warning
  ,p_supervisor_assignment_id     =>     p_supervisor_assignment_id
  );
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
 end if;
  --
  end create_us_secondary_emp_asg;

--
-- ----------------------------------------------------------------------------
-- |---------------------< create_us_secondary_emp_asg >-----------------------|
-- ----------------------------------------------------------------------------
--   Overloded procedure to include p_hourly_salaried_warning
--
procedure create_us_secondary_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_supervisor_id                in     number
  ,p_special_ceiling_step_id      in     number
  ,p_pay_basis_id                 in     number
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_employment_category          in     varchar2
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_tax_unit                     in     varchar2
  ,p_timecard_approver            in     varchar2
  ,p_timecard_required            in     varchar2
  ,p_work_schedule                in     varchar2
  ,p_shift                        in     varchar2
  ,p_spouse_salary                in     varchar2
  ,p_legal_representative         in     varchar2
  ,p_wc_override_code             in     varchar2
  ,p_eeo_1_establishment          in     varchar2
  ,p_pgp_segment1                 in     varchar2
  ,p_pgp_segment2                 in     varchar2
  ,p_pgp_segment3                 in     varchar2
  ,p_pgp_segment4                 in     varchar2
  ,p_pgp_segment5                 in     varchar2
  ,p_pgp_segment6                 in     varchar2
  ,p_pgp_segment7                 in     varchar2
  ,p_pgp_segment8                 in     varchar2
  ,p_pgp_segment9                 in     varchar2
  ,p_pgp_segment10                in     varchar2
  ,p_pgp_segment11                in     varchar2
  ,p_pgp_segment12                in     varchar2
  ,p_pgp_segment13                in     varchar2
  ,p_pgp_segment14                in     varchar2
  ,p_pgp_segment15                in     varchar2
  ,p_pgp_segment16                in     varchar2
  ,p_pgp_segment17                in     varchar2
  ,p_pgp_segment18                in     varchar2
  ,p_pgp_segment19                in     varchar2
  ,p_pgp_segment20                in     varchar2
  ,p_pgp_segment21                in     varchar2
  ,p_pgp_segment22                in     varchar2
  ,p_pgp_segment23                in     varchar2
  ,p_pgp_segment24                in     varchar2
  ,p_pgp_segment25                in     varchar2
  ,p_pgp_segment26                in     varchar2
  ,p_pgp_segment27                in     varchar2
  ,p_pgp_segment28                in     varchar2
  ,p_pgp_segment29                in     varchar2
  ,p_pgp_segment30                in     varchar2
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
  ,p_pgp_concat_segments	  in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_group_name                      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_people_group_id                 out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
-- Bug 944911
-- Amended p_concatenated_segments to out from in out
-- added new param p_concat_segments in
  ,p_concatenated_segments           out nocopy varchar2
  ,p_concat_segments                 in     varchar2
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Declare variables
  --
  -- Assigned the value p_assignment_number for fix of #2823013
  l_assignment_number  per_all_assignments_f.assignment_number%TYPE := p_assignment_number;
  l_effective_date     date;
  --
  l_business_group_id  per_business_groups.business_group_id%TYPE;
  l_legislation_code   per_business_groups.legislation_code%TYPE;
  l_proc               varchar2(72);
  --
  -- Declare cursors
  --
  cursor csr_legislation is
    select null
    from per_all_assignments_f paf,
         per_business_groups_perf pbg
    where paf.person_id = p_person_id
    and   l_effective_date between paf.effective_start_date
                           and     paf.effective_end_date
    and   pbg.business_group_id = paf.business_group_id
    and   pbg.legislation_code = 'US';
  --
  --
begin
 if g_debug then
 l_proc := g_package||'create_secondary_us_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Initialise local variable
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validation in addition to Table Handlers
  --
  -- Ensure that the employee is within a US business group
  --
  open csr_legislation;
  fetch csr_legislation
  into l_legislation_code;
  if csr_legislation%notfound then
    close csr_legislation;
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE', 'US');
    hr_utility.raise_error;
  end if;
  close csr_legislation;
  --
  --
  -- Call create_secondary_emp_asg
  --
-- Bug 944911
-- Added new param p_concat_segments in
-- made p_concatenated_segments to be out only
-- Amended p_scl_concatenated_segments to be p_concatenated_segments

  hr_assignment_api.create_secondary_emp_asg
  (p_validate                     =>     p_validate
  ,p_effective_date               =>     l_effective_date
  ,p_person_id                    =>     p_person_id
  ,p_organization_id              =>     p_organization_id
  ,p_grade_id                     =>     p_grade_id
  ,p_position_id                  =>     p_position_id
  ,p_job_id                       =>     p_job_id
  ,p_assignment_status_type_id    =>     p_assignment_status_type_id
  ,p_payroll_id                   =>     p_payroll_id
  ,p_location_id                  =>     p_location_id
  ,p_supervisor_id                =>     p_supervisor_id
  ,p_special_ceiling_step_id      =>     p_special_ceiling_step_id
  ,p_pay_basis_id                 =>     p_pay_basis_id
  ,p_assignment_number            =>     l_assignment_number
  ,p_change_reason                =>     p_change_reason
  ,p_comments                     =>     p_comments
  ,p_date_probation_end           =>     trunc(p_date_probation_end)
  ,p_default_code_comb_id         =>     p_default_code_comb_id
  ,p_employment_category          =>     p_employment_category
  ,p_frequency                    =>     p_frequency
  ,p_internal_address_line        =>     p_internal_address_line
  ,p_manager_flag                 =>     p_manager_flag
  ,p_normal_hours                 =>     p_normal_hours
  ,p_perf_review_period           =>     p_perf_review_period
  ,p_perf_review_period_frequency =>     p_perf_review_period_frequency
  ,p_probation_period             =>     p_probation_period
  ,p_probation_unit               =>     p_probation_unit
  ,p_sal_review_period            =>     p_sal_review_period
  ,p_sal_review_period_frequency  =>     p_sal_review_period_frequency
  ,p_set_of_books_id              =>     p_set_of_books_id
  ,p_source_type                  =>     p_source_type
  ,p_time_normal_finish           =>     p_time_normal_finish
  ,p_time_normal_start            =>     p_time_normal_start
  ,p_bargaining_unit_code         =>     p_bargaining_unit_code
  ,p_labour_union_member_flag     =>     p_labour_union_member_flag
  ,p_hourly_salaried_code         =>     p_hourly_salaried_code
  ,p_ass_attribute_category       =>     p_ass_attribute_category
  ,p_ass_attribute1               =>     p_ass_attribute1
  ,p_ass_attribute2               =>     p_ass_attribute2
  ,p_ass_attribute3               =>     p_ass_attribute3
  ,p_ass_attribute4               =>     p_ass_attribute4
  ,p_ass_attribute5               =>     p_ass_attribute5
  ,p_ass_attribute6               =>     p_ass_attribute6
  ,p_ass_attribute7               =>     p_ass_attribute7
  ,p_ass_attribute8               =>     p_ass_attribute8
  ,p_ass_attribute9               =>     p_ass_attribute9
  ,p_ass_attribute10              =>     p_ass_attribute10
  ,p_ass_attribute11              =>     p_ass_attribute11
  ,p_ass_attribute12              =>     p_ass_attribute12
  ,p_ass_attribute13              =>     p_ass_attribute13
  ,p_ass_attribute14              =>     p_ass_attribute14
  ,p_ass_attribute15              =>     p_ass_attribute15
  ,p_ass_attribute16              =>     p_ass_attribute16
  ,p_ass_attribute17              =>     p_ass_attribute17
  ,p_ass_attribute18              =>     p_ass_attribute18
  ,p_ass_attribute19              =>     p_ass_attribute19
  ,p_ass_attribute20              =>     p_ass_attribute20
  ,p_ass_attribute21              =>     p_ass_attribute21
  ,p_ass_attribute22              =>     p_ass_attribute22
  ,p_ass_attribute23              =>     p_ass_attribute23
  ,p_ass_attribute24              =>     p_ass_attribute24
  ,p_ass_attribute25              =>     p_ass_attribute25
  ,p_ass_attribute26              =>     p_ass_attribute26
  ,p_ass_attribute27              =>     p_ass_attribute27
  ,p_ass_attribute28              =>     p_ass_attribute28
  ,p_ass_attribute29              =>     p_ass_attribute29
  ,p_ass_attribute30              =>     p_ass_attribute30
  ,p_title                        =>     p_title
  ,p_scl_segment1                 =>     p_tax_unit
  ,p_scl_segment2                 =>     p_timecard_approver
  ,p_scl_segment3                 =>     p_timecard_required
  ,p_scl_segment4                 =>     p_work_schedule
  ,p_scl_segment5                 =>     p_shift
  ,p_scl_segment6                 =>     p_spouse_salary
  ,p_scl_segment7                 =>     p_legal_representative
  ,p_scl_segment8                 =>     p_wc_override_code
  ,p_scl_segment9                 =>     p_eeo_1_establishment
  ,p_pgp_segment1                 =>     p_pgp_segment1
  ,p_pgp_segment2                 =>     p_pgp_segment2
  ,p_pgp_segment3                 =>     p_pgp_segment3
  ,p_pgp_segment4                 =>     p_pgp_segment4
  ,p_pgp_segment5                 =>     p_pgp_segment5
  ,p_pgp_segment6                 =>     p_pgp_segment6
  ,p_pgp_segment7                 =>     p_pgp_segment7
  ,p_pgp_segment8                 =>     p_pgp_segment8
  ,p_pgp_segment9                 =>     p_pgp_segment9
  ,p_pgp_segment10                =>     p_pgp_segment10
  ,p_pgp_segment11                =>     p_pgp_segment11
  ,p_pgp_segment12                =>     p_pgp_segment12
  ,p_pgp_segment13                =>     p_pgp_segment13
  ,p_pgp_segment14                =>     p_pgp_segment14
  ,p_pgp_segment15                =>     p_pgp_segment15
  ,p_pgp_segment16                =>     p_pgp_segment16
  ,p_pgp_segment17                =>     p_pgp_segment17
  ,p_pgp_segment18                =>     p_pgp_segment18
  ,p_pgp_segment19                =>     p_pgp_segment19
  ,p_pgp_segment20                =>     p_pgp_segment20
  ,p_pgp_segment21                =>     p_pgp_segment21
  ,p_pgp_segment22                =>     p_pgp_segment22
  ,p_pgp_segment23                =>     p_pgp_segment23
  ,p_pgp_segment24                =>     p_pgp_segment24
  ,p_pgp_segment25                =>     p_pgp_segment25
  ,p_pgp_segment26                =>     p_pgp_segment26
  ,p_pgp_segment27                =>     p_pgp_segment27
  ,p_pgp_segment28                =>     p_pgp_segment28
  ,p_pgp_segment29                =>     p_pgp_segment29
  ,p_pgp_segment30                =>     p_pgp_segment30
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
-- Added new param p_pgp_concat_segments
  ,p_pgp_concat_segments	  =>	 p_pgp_concat_segments
  ,p_group_name                   =>     p_group_name
  ,p_assignment_id                =>     p_assignment_id
  ,p_soft_coding_keyflex_id       =>     p_soft_coding_keyflex_id
  ,p_people_group_id              =>     p_people_group_id
  ,p_object_version_number        =>     p_object_version_number
  ,p_effective_start_date         =>     p_effective_start_date
  ,p_effective_end_date           =>     p_effective_end_date
  ,p_assignment_sequence          =>     p_assignment_sequence
  ,p_comment_id                   =>     p_comment_id
  ,p_concatenated_segments        =>     p_concatenated_segments
  ,p_scl_concat_segments          =>     p_concat_segments
  ,p_other_manager_warning        =>     p_other_manager_warning
  ,p_hourly_salaried_warning      =>     p_hourly_salaried_warning
  ,p_cagr_grade_def_id            =>     p_cagr_grade_def_id
  ,p_cagr_concatenated_segments   =>     p_cagr_concatenated_segments
  ,p_supervisor_assignment_id     =>     p_supervisor_assignment_id
  );
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
 end if;
  --
  end create_us_secondary_emp_asg;

--
-- ----------------------------------------------------------------------------
-- |------------------------< final_process_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure final_process_emp_asg
  (p_validate                     in     boolean
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_final_process_date           in     date
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_asg_future_changes_warning boolean := FALSE;
  l_effective_end_date         per_all_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_all_assignments_f.effective_start_date%TYPE;
  l_entries_changed_warning    varchar2(1) := 'N';
  l_object_version_number      per_all_assignments_f.object_version_number%TYPE;
  l_org_now_no_manager_warning boolean := FALSE;
  --
  l_assignment_type            per_all_assignments_f.assignment_type%TYPE;
  l_primary_flag               per_all_assignments_f.primary_flag%TYPE;
  l_proc                       varchar2(72)
                                     := g_package || 'final_process_emp_asg';
  l_actual_termination_date    date;
  l_final_process_date         date;
  l_max_asg_end_date           date;
  --
  lv_object_version_number     number := p_object_version_number ;
  --
  cursor csr_get_derived_details is
    select asg.assignment_type
         , asg.primary_flag
      from per_all_assignments_f      asg
     where asg.assignment_id        = p_assignment_id
       and l_final_process_date     between asg.effective_start_date
                                    and     asg.effective_end_date;
  --
  cursor csr_valid_term_assign is
    select min(asg.effective_start_date) - 1
      from per_all_assignments_f           asg
     where asg.assignment_id             = p_assignment_id
       and exists ( select null
		    from per_assignment_status_types ast
		    where ast.assignment_status_type_id
		     = asg.assignment_status_type_id
                     and ast.per_system_status = 'TERM_ASSIGN');

--
  cursor csr_invalid_term_assign is
    select max(asg.effective_end_date)
      from per_all_assignments_f           asg
     where asg.assignment_id      = p_assignment_id
       and exists ( select null
		    from per_assignment_status_types ast
		    where ast.assignment_status_type_id
		     = asg.assignment_status_type_id
                     and ast.per_system_status = 'TERM_ASSIGN');

--
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  l_object_version_number := p_object_version_number;
  l_final_process_date    := trunc(p_final_process_date);
  --
  -- Issue a savepoint.
  --
  savepoint final_process_emp_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Validation in addition to Table Handlers
  --
  -- Get assignment and business group details for validation.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'assignment_id'
     ,p_argument_value => p_assignment_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'final_process_date'
     ,p_argument_value => l_final_process_date
     );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  open  csr_get_derived_details;
  fetch csr_get_derived_details
   into l_assignment_type
      , l_primary_flag;
  --
  if csr_get_derived_details%NOTFOUND
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 30);
 end if;
    --
    close csr_get_derived_details;
    --
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;
  --
  -- Start of API User Hook for the before hook of final_process_emp_asg.
  --
  begin
     hr_assignment_bka.final_process_emp_asg_b
       (p_assignment_id                 =>  p_assignment_id
       ,p_object_version_number         =>  p_object_version_number
       ,p_final_process_date            =>  l_final_process_date
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'FINAL_PROCESS_EMP_ASG',
          p_hook_type         => 'BP'
         );
  end;
  --
  --
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;
  --
  -- The assignment must not be a primary assignment.
  --
  if l_primary_flag <> 'N'
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 50);
 end if;
    --
    hr_utility.set_message(801,'HR_7999_ASG_INV_PRIM_ASG');
    hr_utility.raise_error;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 60);
 end if;
  --
  -- The assignment must be an employee assignment.
  --
  if l_assignment_type <> 'E'
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 70);
 end if;
    --
    hr_utility.set_message(801,'HR_7948_ASG_ASG_NOT_EMP');
    hr_utility.raise_error;
  end if;

  -- Ensure that the assignment has not been terminated previously

  --
  open  csr_invalid_term_assign;
  fetch csr_invalid_term_assign
   into l_max_asg_end_date;
  close csr_invalid_term_assign;

  --
  if l_max_asg_end_date <> hr_api.g_eot
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 90);
 end if;
    --
    hr_utility.set_message(801,'HR_7962_PDS_INV_FP_CHANGE');
    hr_utility.raise_error;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 80);
 end if;
  --
  -- Ensure that the the final process date is on or after the actual
  -- termination date by checking that the assignment status is TERM_ASSIGN for
  -- the day after the final process date.
  --
  open  csr_valid_term_assign;
  fetch csr_valid_term_assign
   into l_actual_termination_date;
  close csr_valid_term_assign;

  --
  if l_actual_termination_date is null
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 90);
 end if;
    --
    hr_utility.set_message(801,'HR_51007_ASG_INV_NOT_ACT_TERM');
    hr_utility.raise_error;
  end if;

  if l_final_process_date < l_actual_termination_date then

 if g_debug then
    hr_utility.set_location(l_proc, 95);
 end if;

    -- This error message has been set temporarily

    hr_utility.set_message(801,'HR_7963_PDS_INV_FP_BEFORE_ATT');
    hr_utility.raise_error;
  end if;
  --
  --
 if g_debug then
  hr_utility.set_location(l_proc, 100);
 end if;
  --
  -- Process Logic
  --
  -- Call the business support process to update assignment and maintain the
  -- element entries.
  --
  hr_assignment_internal.final_process_emp_asg_sup
    (p_assignment_id              => p_assignment_id
    ,p_object_version_number      => l_object_version_number
    ,p_final_process_date         => l_final_process_date
    ,p_actual_termination_date    => l_actual_termination_date
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
    ,p_asg_future_changes_warning => l_asg_future_changes_warning
    ,p_entries_changed_warning    => l_entries_changed_warning
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 110);
 end if;
  --
  -- Start of API User Hook for the after hook of final_process_emp_asg.
  --
  begin
     hr_assignment_bka.final_process_emp_asg_a
        (p_assignment_id                 =>     p_assignment_id
        ,p_object_version_number         =>     l_object_version_number
        ,p_final_process_date            =>     p_final_process_date
        ,p_effective_start_date          =>     l_effective_start_date
        ,p_effective_end_date            =>     l_effective_end_date
        ,p_org_now_no_manager_warning    =>     l_org_now_no_manager_warning
        ,p_asg_future_changes_warning    =>     l_asg_future_changes_warning
        ,p_entries_changed_warning       =>     l_entries_changed_warning
        );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'FINAL_PROCESS_EMP_ASG',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of final_process_emp_asg.
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_asg_future_changes_warning := l_asg_future_changes_warning;
  p_effective_end_date         := l_effective_end_date;
  p_effective_start_date       := l_effective_start_date;
  p_entries_changed_warning    := l_entries_changed_warning;
  p_object_version_number      := l_object_version_number;
  p_org_now_no_manager_warning := l_org_now_no_manager_warning;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 300);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO final_process_emp_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_asg_future_changes_warning := l_asg_future_changes_warning;
    p_effective_end_date         := null;
    p_effective_start_date       := null;
    p_entries_changed_warning    := l_entries_changed_warning;
    p_org_now_no_manager_warning := l_org_now_no_manager_warning;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number := lv_object_version_number;

    p_effective_start_date            := null;
    p_effective_end_date              := null;
    p_org_now_no_manager_warning      := null;
    p_asg_future_changes_warning      := null;
    p_entries_changed_warning         := null;


    ROLLBACK TO final_process_emp_asg;
    raise;
    --
    -- End of fix.
    --
end final_process_emp_asg;
--
-- 70.4 change end.
--
-- ----------------------------------------------------------------------------
-- |---------------------------< suspend_emp_asg >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure suspend_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_change_reason                in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date             date;
  --
  -- Out variables
  --
  l_effective_end_date         per_all_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_all_assignments_f.effective_start_date%TYPE;
  l_object_version_number      per_all_assignments_f.object_version_number%TYPE;
  --
  lv_object_version_number     number := p_object_version_number ;
  --
  l_proc                       varchar2(72);
  --
begin
 if g_debug then
 l_proc := g_package||'suspend_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  --
  l_object_version_number := p_object_version_number;
  --
  -- Issue a savepoint.
  --
  savepoint suspend_emp_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Initialise local variable - added 25-Aug-97. RMF.
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validation in addition to Table Handlers
  --
  -- None required.
  --
  -- Process Logic
  --
  -- Start of API User Hook for the before hook of suspend_emp_asg.
  --
  begin
     hr_assignment_bk7.suspend_emp_asg_b
       (p_effective_date               => l_effective_date
       ,p_datetrack_update_mode        => p_datetrack_update_mode
       ,p_assignment_id                => p_assignment_id
       ,p_change_reason                => p_change_reason
       ,p_object_version_number        => p_object_version_number
       ,p_assignment_status_type_id    => p_assignment_status_type_id
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'SUSPEND_EMP_ASG',
          p_hook_type         => 'BP'
         );
  end;
  --
  --
  -- Update employee assignment.
  --
  hr_assignment_internal.update_status_type_emp_asg
    (p_effective_date               => l_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_change_reason                => p_change_reason
    ,p_object_version_number        => l_object_version_number
    ,p_expected_system_status       => 'SUSP_ASSIGN'
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Start of API User Hook for the after hook of suspend_emp_asg.
  --
  begin
     hr_assignment_bk7.suspend_emp_asg_a
        (p_effective_date               => l_effective_date
        ,p_datetrack_update_mode        => p_datetrack_update_mode
        ,p_assignment_id                => p_assignment_id
        ,p_change_reason                => p_change_reason
        ,p_object_version_number        => l_object_version_number
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date
        );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'SUSPEND_EMP_ASG',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of suspend_emp_asg.
  --
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
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 100);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO suspend_emp_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := p_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number := lv_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    ROLLBACK TO suspend_emp_asg;
    raise;
    --
    -- End of fix.
    --
end suspend_emp_asg;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_emp_asg >-OLD--------------------------|
-- ----------------------------------------------------------------------------
-- This is the old procedure that simply calls the new updated
-- procedure passing in nulls for the new in parms and trapping
-- new out parms in local variables.
--
procedure update_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_segment1                     in     varchar2
  ,p_segment2                     in     varchar2
  ,p_segment3                     in     varchar2
  ,p_segment4                     in     varchar2
  ,p_segment5                     in     varchar2
  ,p_segment6                     in     varchar2
  ,p_segment7                     in     varchar2
  ,p_segment8                     in     varchar2
  ,p_segment9                     in     varchar2
  ,p_segment10                    in     varchar2
  ,p_segment11                    in     varchar2
  ,p_segment12                    in     varchar2
  ,p_segment13                    in     varchar2
  ,p_segment14                    in     varchar2
  ,p_segment15                    in     varchar2
  ,p_segment16                    in     varchar2
  ,p_segment17                    in     varchar2
  ,p_segment18                    in     varchar2
  ,p_segment19                    in     varchar2
  ,p_segment20                    in     varchar2
  ,p_segment21                    in     varchar2
  ,p_segment22                    in     varchar2
  ,p_segment23                    in     varchar2
  ,p_segment24                    in     varchar2
  ,p_segment25                    in     varchar2
  ,p_segment26                    in     varchar2
  ,p_segment27                    in     varchar2
  ,p_segment28                    in     varchar2
  ,p_segment29                    in     varchar2
  ,p_segment30                    in     varchar2
-- Bug fix for 944911
-- p_concatenated_segments has been changed from in out to out
-- Added new param p_concat_segments as in param
  ,p_concat_segments              in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_concatenated_segments           out nocopy varchar2
  ,p_soft_coding_keyflex_id       in out nocopy number -- bug 2359997
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_comment_id             per_all_assignments_f.comment_id%TYPE;
  l_effective_start_date   per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date     per_all_assignments_f.effective_end_date%TYPE;
  l_object_version_number  per_all_assignments_f.object_version_number%TYPE;
  l_no_managers_warning    boolean;
  l_other_manager_warning  boolean;
  l_soft_coding_keyflex_id per_all_assignments_f.soft_coding_keyflex_id%TYPE
  := p_soft_coding_keyflex_id; -- bug 2359997
  l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_old_conc_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_effective_date         date;
  l_date_probation_end     per_all_assignments_f.date_probation_end%TYPE;
  l_flex_num               fnd_id_flex_segments.id_flex_num%TYPE;
  l_organization_id        per_all_assignments_f.organization_id%type;
  l_location_id            per_all_assignments_f.location_id%type;
  l_cagr_grade_def_id      per_cagr_grades_def.cagr_grade_def_id%TYPE;
  l_cagr_concatenated_segments varchar2(2000);
  l_proc                       varchar2(72);
  --
  begin
  --
  l_object_version_number := p_object_version_number;
  --
 if g_debug then
 l_proc := g_package||'update_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  ---- Call the new code
 hr_assignment_api.update_emp_asg
  (p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => p_datetrack_update_mode
  ,p_assignment_id                => p_assignment_id
  ,p_object_version_number        => l_object_version_number
  ,p_supervisor_id                => p_supervisor_id
  ,p_assignment_number            => p_assignment_number
  ,p_change_reason                => p_change_reason
  ,p_comments                     => p_comments
  ,p_date_probation_end           => p_date_probation_end
  ,p_default_code_comb_id         => p_default_code_comb_id
  ,p_frequency                    => p_frequency
  ,p_internal_address_line        => p_internal_address_line
  ,p_manager_flag                 => p_manager_flag
  ,p_normal_hours                 => p_normal_hours
  ,p_perf_review_period           => p_perf_review_period
  ,p_perf_review_period_frequency => p_perf_review_period_frequency
  ,p_probation_period             => p_probation_period
  ,p_probation_unit               => p_probation_unit
  ,p_sal_review_period            => p_sal_review_period
  ,p_sal_review_period_frequency  => p_sal_review_period_frequency
  ,p_set_of_books_id              => p_set_of_books_id
  ,p_source_type                  => p_source_type
  ,p_time_normal_finish           => p_time_normal_finish
  ,p_time_normal_start            => p_time_normal_start
  ,p_bargaining_unit_code         => p_bargaining_unit_code
  ,p_labour_union_member_flag     => p_labour_union_member_flag
  ,p_hourly_salaried_code         => p_hourly_salaried_code
  ,p_ass_attribute_category       => p_ass_attribute_category
  ,p_ass_attribute1               => p_ass_attribute1
  ,p_ass_attribute2               => p_ass_attribute2
  ,p_ass_attribute3               => p_ass_attribute3
  ,p_ass_attribute4               => p_ass_attribute4
  ,p_ass_attribute5               => p_ass_attribute5
  ,p_ass_attribute6               => p_ass_attribute6
  ,p_ass_attribute7               => p_ass_attribute7
  ,p_ass_attribute8               => p_ass_attribute8
  ,p_ass_attribute9               => p_ass_attribute9
  ,p_ass_attribute10              => p_ass_attribute10
  ,p_ass_attribute11              => p_ass_attribute11
  ,p_ass_attribute12              => p_ass_attribute12
  ,p_ass_attribute13              => p_ass_attribute13
  ,p_ass_attribute14              => p_ass_attribute14
  ,p_ass_attribute15              => p_ass_attribute15
  ,p_ass_attribute16              => p_ass_attribute16
  ,p_ass_attribute17              => p_ass_attribute17
  ,p_ass_attribute18              => p_ass_attribute18
  ,p_ass_attribute19              => p_ass_attribute19
  ,p_ass_attribute20              => p_ass_attribute20
  ,p_ass_attribute21              => p_ass_attribute21
  ,p_ass_attribute22              => p_ass_attribute22
  ,p_ass_attribute23              => p_ass_attribute23
  ,p_ass_attribute24              => p_ass_attribute24
  ,p_ass_attribute25              => p_ass_attribute25
  ,p_ass_attribute26              => p_ass_attribute26
  ,p_ass_attribute27              => p_ass_attribute27
  ,p_ass_attribute28              => p_ass_attribute28
  ,p_ass_attribute29              => p_ass_attribute29
  ,p_ass_attribute30              => p_ass_attribute30
  ,p_title                        => p_title
  ,p_segment1                     => p_segment1
  ,p_segment2                     => p_segment2
  ,p_segment3                     => p_segment3
  ,p_segment4                     => p_segment4
  ,p_segment5                     => p_segment5
  ,p_segment6                     => p_segment6
  ,p_segment7                     => p_segment7
  ,p_segment8                     => p_segment8
  ,p_segment9                     => p_segment9
  ,p_segment10                    => p_segment10
  ,p_segment11                    => p_segment11
  ,p_segment12                    => p_segment12
  ,p_segment13                    => p_segment13
  ,p_segment14                    => p_segment14
  ,p_segment15                    => p_segment15
  ,p_segment16                    => p_segment16
  ,p_segment17                    => p_segment17
  ,p_segment18                    => p_segment18
  ,p_segment19                    => p_segment19
  ,p_segment20                    => p_segment20
  ,p_segment21                    => p_segment21
  ,p_segment22                    => p_segment22
  ,p_segment23                    => p_segment23
  ,p_segment24                    => p_segment24
  ,p_segment25                    => p_segment25
  ,p_segment26                    => p_segment26
  ,p_segment27                    => p_segment27
  ,p_segment28                    => p_segment28
  ,p_segment29                    => p_segment29
  ,p_segment30                    => p_segment30
  ,p_concat_segments              => p_concat_segments
  ,p_contract_id                  => hr_api.g_number
  ,p_establishment_id             => hr_api.g_number
  ,p_collective_agreement_id      => hr_api.g_number
  ,p_cagr_id_flex_num             => hr_api.g_number
  ,p_cag_segment1                 => hr_api.g_varchar2
  ,p_cag_segment2                 => hr_api.g_varchar2
  ,p_cag_segment3                 => hr_api.g_varchar2
  ,p_cag_segment4                 => hr_api.g_varchar2
  ,p_cag_segment5                 => hr_api.g_varchar2
  ,p_cag_segment6                 => hr_api.g_varchar2
  ,p_cag_segment7                 => hr_api.g_varchar2
  ,p_cag_segment8                 => hr_api.g_varchar2
  ,p_cag_segment9                 => hr_api.g_varchar2
  ,p_cag_segment10                => hr_api.g_varchar2
  ,p_cag_segment11                => hr_api.g_varchar2
  ,p_cag_segment12                => hr_api.g_varchar2
  ,p_cag_segment13                => hr_api.g_varchar2
  ,p_cag_segment14                => hr_api.g_varchar2
  ,p_cag_segment15                => hr_api.g_varchar2
  ,p_cag_segment16                => hr_api.g_varchar2
  ,p_cag_segment17                => hr_api.g_varchar2
  ,p_cag_segment18                => hr_api.g_varchar2
  ,p_cag_segment19                => hr_api.g_varchar2
  ,p_cag_segment20                => hr_api.g_varchar2
  ,p_cagr_grade_def_id            => l_cagr_grade_def_id
  ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
  ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
  ,p_comment_id                   => l_comment_id
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ,p_concatenated_segments        => l_concatenated_segments
  ,p_no_managers_warning          => l_no_managers_warning
  ,p_other_manager_warning        => l_other_manager_warning
  ,p_supervisor_assignment_id     => p_supervisor_assignment_id
);

  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  p_soft_coding_keyflex_id := l_soft_coding_keyflex_id;
  p_comment_id             := l_comment_id;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_concatenated_segments  := l_concatenated_segments;
  p_no_managers_warning    := l_no_managers_warning;
  p_other_manager_warning  := l_other_manager_warning;

  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
 end if;
end update_emp_asg;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_emp_asg >--NEW--------------------------|
-- ----------------------------------------------------------------------------
--
-- This is an overloaded procedure to include new parms
-- for collective agreements and contracts
-- added new parameters notice_period, units, employee_category,
-- work_at_home and job_source on 05-OCT-01
--
procedure update_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_assignment_status_type_id    in     number
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_segment1                     in     varchar2
  ,p_segment2                     in     varchar2
  ,p_segment3                     in     varchar2
  ,p_segment4                     in     varchar2
  ,p_segment5                     in     varchar2
  ,p_segment6                     in     varchar2
  ,p_segment7                     in     varchar2
  ,p_segment8                     in     varchar2
  ,p_segment9                     in     varchar2
  ,p_segment10                    in     varchar2
  ,p_segment11                    in     varchar2
  ,p_segment12                    in     varchar2
  ,p_segment13                    in     varchar2
  ,p_segment14                    in     varchar2
  ,p_segment15                    in     varchar2
  ,p_segment16                    in     varchar2
  ,p_segment17                    in     varchar2
  ,p_segment18                    in     varchar2
  ,p_segment19                    in     varchar2
  ,p_segment20                    in     varchar2
  ,p_segment21                    in     varchar2
  ,p_segment22                    in     varchar2
  ,p_segment23                    in     varchar2
  ,p_segment24                    in     varchar2
  ,p_segment25                    in     varchar2
  ,p_segment26                    in     varchar2
  ,p_segment27                    in     varchar2
  ,p_segment28                    in     varchar2
  ,p_segment29                    in     varchar2
  ,p_segment30                    in     varchar2
-- Bug fix for 944911
-- p_concatenated_segments has been changed from in out to out
-- Added new param p_concat_segments as in param
  ,p_concat_segments              in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_collective_agreement_id      in     number
  ,p_cagr_id_flex_num             in     number
  ,p_cag_segment1                 in     varchar2
  ,p_cag_segment2                 in     varchar2
  ,p_cag_segment3                 in     varchar2
  ,p_cag_segment4                 in     varchar2
  ,p_cag_segment5                 in     varchar2
  ,p_cag_segment6                 in     varchar2
  ,p_cag_segment7                 in     varchar2
  ,p_cag_segment8                 in     varchar2
  ,p_cag_segment9                 in     varchar2
  ,p_cag_segment10                in     varchar2
  ,p_cag_segment11                in     varchar2
  ,p_cag_segment12                in     varchar2
  ,p_cag_segment13                in     varchar2
  ,p_cag_segment14                in     varchar2
  ,p_cag_segment15                in     varchar2
  ,p_cag_segment16                in     varchar2
  ,p_cag_segment17                in     varchar2
  ,p_cag_segment18                in     varchar2
  ,p_cag_segment19                in     varchar2
  ,p_cag_segment20                in     varchar2
  ,p_notice_period		  in     number
  ,p_notice_period_uom	      	  in     varchar2
  ,p_employee_category	          in     varchar2
  ,p_work_at_home		  in     varchar2
  ,p_job_post_source_name	  in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_cagr_grade_def_id            in out nocopy number -- bug 2359997
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_soft_coding_keyflex_id       in out nocopy number -- bug 2359997
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_comment_id              per_all_assignments_f.comment_id%TYPE;
  l_effective_start_date    per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date      per_all_assignments_f.effective_end_date%TYPE;
  l_object_version_number   per_all_assignments_f.object_version_number%TYPE;
  l_no_managers_warning     boolean;
  l_other_manager_warning   boolean;
  l_hourly_salaried_warning boolean;
  l_soft_coding_keyflex_id  per_all_assignments_f.soft_coding_keyflex_id%TYPE
  := p_soft_coding_keyflex_id; -- bug 2359997
  l_concatenated_segments   hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_old_conc_segments       hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_effective_date          date;
  l_date_probation_end      per_all_assignments_f.date_probation_end%TYPE;
  l_flex_num                fnd_id_flex_segments.id_flex_num%TYPE;
  l_organization_id         per_all_assignments_f.organization_id%type;
  l_location_id             per_all_assignments_f.location_id%type;
  l_cagr_grade_def_id       per_cagr_grades_def.cagr_grade_def_id%TYPE
  := p_cagr_grade_def_id;   -- bug 2359997
  l_cagr_id_flex_num        per_cagr_grades_def.id_flex_num%TYPE;
  l_cagr_concatenated_segments varchar2(2000);
  l_proc                       varchar2(72);

  begin
  --
  l_object_version_number := p_object_version_number;
  --
 if g_debug then
  l_proc := g_package||'update_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  ---- Call the new code
  -- Added notice_period through to job_post_source_name in this call as they
  -- were missing
  -- see bug 2122535 for details
  --
 hr_assignment_api.update_emp_asg
  (p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => p_datetrack_update_mode
  ,p_assignment_id                => p_assignment_id
  ,p_object_version_number        => l_object_version_number
  ,p_supervisor_id                => p_supervisor_id
  ,p_assignment_number            => p_assignment_number
  ,p_change_reason                => p_change_reason
  ,p_assignment_status_type_id    => p_assignment_status_type_id
  ,p_comments                     => p_comments
  ,p_date_probation_end           => p_date_probation_end
  ,p_default_code_comb_id         => p_default_code_comb_id
  ,p_frequency                    => p_frequency
  ,p_internal_address_line        => p_internal_address_line
  ,p_manager_flag                 => p_manager_flag
  ,p_normal_hours                 => p_normal_hours
  ,p_perf_review_period           => p_perf_review_period
  ,p_perf_review_period_frequency => p_perf_review_period_frequency
  ,p_probation_period             => p_probation_period
  ,p_probation_unit               => p_probation_unit
  ,p_sal_review_period            => p_sal_review_period
  ,p_sal_review_period_frequency  => p_sal_review_period_frequency
  ,p_set_of_books_id              => p_set_of_books_id
  ,p_source_type                  => p_source_type
  ,p_time_normal_finish           => p_time_normal_finish
  ,p_time_normal_start            => p_time_normal_start
  ,p_bargaining_unit_code         => p_bargaining_unit_code
  ,p_labour_union_member_flag     => p_labour_union_member_flag
  ,p_hourly_salaried_code         => p_hourly_salaried_code
  ,p_ass_attribute_category       => p_ass_attribute_category
  ,p_ass_attribute1               => p_ass_attribute1
  ,p_ass_attribute2               => p_ass_attribute2
  ,p_ass_attribute3               => p_ass_attribute3
  ,p_ass_attribute4               => p_ass_attribute4
  ,p_ass_attribute5               => p_ass_attribute5
  ,p_ass_attribute6               => p_ass_attribute6
  ,p_ass_attribute7               => p_ass_attribute7
  ,p_ass_attribute8               => p_ass_attribute8
  ,p_ass_attribute9               => p_ass_attribute9
  ,p_ass_attribute10              => p_ass_attribute10
  ,p_ass_attribute11              => p_ass_attribute11
  ,p_ass_attribute12              => p_ass_attribute12
  ,p_ass_attribute13              => p_ass_attribute13
  ,p_ass_attribute14              => p_ass_attribute14
  ,p_ass_attribute15              => p_ass_attribute15
  ,p_ass_attribute16              => p_ass_attribute16
  ,p_ass_attribute17              => p_ass_attribute17
  ,p_ass_attribute18              => p_ass_attribute18
  ,p_ass_attribute19              => p_ass_attribute19
  ,p_ass_attribute20              => p_ass_attribute20
  ,p_ass_attribute21              => p_ass_attribute21
  ,p_ass_attribute22              => p_ass_attribute22
  ,p_ass_attribute23              => p_ass_attribute23
  ,p_ass_attribute24              => p_ass_attribute24
  ,p_ass_attribute25              => p_ass_attribute25
  ,p_ass_attribute26              => p_ass_attribute26
  ,p_ass_attribute27              => p_ass_attribute27
  ,p_ass_attribute28              => p_ass_attribute28
  ,p_ass_attribute29              => p_ass_attribute29
  ,p_ass_attribute30              => p_ass_attribute30
  ,p_title                        => p_title
  ,p_segment1                     => p_segment1
  ,p_segment2                     => p_segment2
  ,p_segment3                     => p_segment3
  ,p_segment4                     => p_segment4
  ,p_segment5                     => p_segment5
  ,p_segment6                     => p_segment6
  ,p_segment7                     => p_segment7
  ,p_segment8                     => p_segment8
  ,p_segment9                     => p_segment9
  ,p_segment10                    => p_segment10
  ,p_segment11                    => p_segment11
  ,p_segment12                    => p_segment12
  ,p_segment13                    => p_segment13
  ,p_segment14                    => p_segment14
  ,p_segment15                    => p_segment15
  ,p_segment16                    => p_segment16
  ,p_segment17                    => p_segment17
  ,p_segment18                    => p_segment18
  ,p_segment19                    => p_segment19
  ,p_segment20                    => p_segment20
  ,p_segment21                    => p_segment21
  ,p_segment22                    => p_segment22
  ,p_segment23                    => p_segment23
  ,p_segment24                    => p_segment24
  ,p_segment25                    => p_segment25
  ,p_segment26                    => p_segment26
  ,p_segment27                    => p_segment27
  ,p_segment28                    => p_segment28
  ,p_segment29                    => p_segment29
  ,p_segment30                    => p_segment30
  ,p_concat_segments              => p_concat_segments
  ,p_contract_id                  => p_contract_id
  ,p_establishment_id             => p_establishment_id
  ,p_collective_agreement_id      => p_collective_agreement_id
  ,p_cagr_id_flex_num             => p_cagr_id_flex_num
  ,p_cag_segment1                 => p_cag_segment1
  ,p_cag_segment2                 => p_cag_segment2
  ,p_cag_segment3                 => p_cag_segment3
  ,p_cag_segment4                 => p_cag_segment4
  ,p_cag_segment5                 => p_cag_segment5
  ,p_cag_segment6                 => p_cag_segment6
  ,p_cag_segment7                 => p_cag_segment7
  ,p_cag_segment8                 => p_cag_segment8
  ,p_cag_segment9                 => p_cag_segment9
  ,p_cag_segment10                => p_cag_segment10
  ,p_cag_segment11                => p_cag_segment11
  ,p_cag_segment12                => p_cag_segment12
  ,p_cag_segment13                => p_cag_segment13
  ,p_cag_segment14                => p_cag_segment14
  ,p_cag_segment15                => p_cag_segment15
  ,p_cag_segment16                => p_cag_segment16
  ,p_cag_segment17                => p_cag_segment17
  ,p_cag_segment18                => p_cag_segment18
  ,p_cag_segment19                => p_cag_segment19
  ,p_cag_segment20                => p_cag_segment20
  ,p_notice_period                => p_notice_period
  ,p_notice_period_uom            => p_notice_period_uom
  ,p_employee_category            => p_employee_category
  ,p_work_at_home                 => p_work_at_home
  ,p_job_post_source_name	  => p_job_post_source_name
  ,p_cagr_grade_def_id            => l_cagr_grade_def_id
  ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
  ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
  ,p_comment_id                   => l_comment_id
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ,p_concatenated_segments        => l_concatenated_segments
  ,p_no_managers_warning          => l_no_managers_warning
  ,p_other_manager_warning        => l_other_manager_warning
  ,p_hourly_salaried_warning      => l_hourly_salaried_warning
  ,p_supervisor_assignment_id     => p_supervisor_assignment_id
);
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  p_soft_coding_keyflex_id := l_soft_coding_keyflex_id;
  p_comment_id             := l_comment_id;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_concatenated_segments  := l_concatenated_segments;
  p_no_managers_warning    := l_no_managers_warning;
  p_other_manager_warning  := l_other_manager_warning;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
 end if;
end update_emp_asg;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_emp_asg >--NEW2-------------------------|
-- ----------------------------------------------------------------------------
--
-- This is an overloaded procedure to include new parms
-- for collective agreements and contracts
-- added new parameters notice_period, units, employee_category,
-- work_at_home and job_source on 05-OCT-01
--
procedure update_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_assignment_status_type_id    in     number
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_segment1                     in     varchar2
  ,p_segment2                     in     varchar2
  ,p_segment3                     in     varchar2
  ,p_segment4                     in     varchar2
  ,p_segment5                     in     varchar2
  ,p_segment6                     in     varchar2
  ,p_segment7                     in     varchar2
  ,p_segment8                     in     varchar2
  ,p_segment9                     in     varchar2
  ,p_segment10                    in     varchar2
  ,p_segment11                    in     varchar2
  ,p_segment12                    in     varchar2
  ,p_segment13                    in     varchar2
  ,p_segment14                    in     varchar2
  ,p_segment15                    in     varchar2
  ,p_segment16                    in     varchar2
  ,p_segment17                    in     varchar2
  ,p_segment18                    in     varchar2
  ,p_segment19                    in     varchar2
  ,p_segment20                    in     varchar2
  ,p_segment21                    in     varchar2
  ,p_segment22                    in     varchar2
  ,p_segment23                    in     varchar2
  ,p_segment24                    in     varchar2
  ,p_segment25                    in     varchar2
  ,p_segment26                    in     varchar2
  ,p_segment27                    in     varchar2
  ,p_segment28                    in     varchar2
  ,p_segment29                    in     varchar2
  ,p_segment30                    in     varchar2
-- Bug fix for 944911
-- p_concatenated_segments has been changed from in out to out
-- Added new param p_concat_segments as in param
  ,p_concat_segments              in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_collective_agreement_id      in     number
  ,p_cagr_id_flex_num             in     number
  ,p_cag_segment1                 in     varchar2
  ,p_cag_segment2                 in     varchar2
  ,p_cag_segment3                 in     varchar2
  ,p_cag_segment4                 in     varchar2
  ,p_cag_segment5                 in     varchar2
  ,p_cag_segment6                 in     varchar2
  ,p_cag_segment7                 in     varchar2
  ,p_cag_segment8                 in     varchar2
  ,p_cag_segment9                 in     varchar2
  ,p_cag_segment10                in     varchar2
  ,p_cag_segment11                in     varchar2
  ,p_cag_segment12                in     varchar2
  ,p_cag_segment13                in     varchar2
  ,p_cag_segment14                in     varchar2
  ,p_cag_segment15                in     varchar2
  ,p_cag_segment16                in     varchar2
  ,p_cag_segment17                in     varchar2
  ,p_cag_segment18                in     varchar2
  ,p_cag_segment19                in     varchar2
  ,p_cag_segment20                in     varchar2
  ,p_notice_period		  in     number
  ,p_notice_period_uom	      	  in     varchar2
  ,p_employee_category	          in     varchar2
  ,p_work_at_home		  in     varchar2
  ,p_job_post_source_name	  in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_cagr_grade_def_id            in out nocopy number -- bug 2359997
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_soft_coding_keyflex_id       in out nocopy number -- bug 2359997
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_comment_id             per_all_assignments_f.comment_id%TYPE;
  l_effective_start_date   per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date     per_all_assignments_f.effective_end_date%TYPE;
  l_object_version_number  per_all_assignments_f.object_version_number%TYPE;
  l_no_managers_warning    boolean;
  l_other_manager_warning  boolean;
  l_soft_coding_keyflex_id per_all_assignments_f.soft_coding_keyflex_id%TYPE
  := p_soft_coding_keyflex_id;  -- bug 2359997
  l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_old_conc_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_effective_date         date;
  l_date_probation_end     per_all_assignments_f.date_probation_end%TYPE;
  l_flex_num               fnd_id_flex_segments.id_flex_num%TYPE;
  l_organization_id        per_all_assignments_f.organization_id%type;
  l_location_id            per_all_assignments_f.location_id%type;
  l_cagr_grade_def_id      per_cagr_grades_def.cagr_grade_def_id%TYPE
  := p_cagr_grade_def_id;  -- bug 2359997
  l_cagr_id_flex_num       per_cagr_grades_def.id_flex_num%TYPE;
  l_cagr_concatenated_segments varchar2(2000);
  l_hourly_salaried_warning boolean;
  l_gsp_post_process_warning varchar2(2000); -- bug 2999562
  --
  -- Internal working variables
  --
  l_assignment_type            per_all_assignments_f.assignment_type%TYPE;
  l_business_group_id          per_business_groups.business_group_id%TYPE;
  l_payroll_id_updated         boolean;
  l_people_group_id            per_all_assignments_f.people_group_id%TYPE;
  l_org_now_no_manager_warning boolean;
  l_validation_start_date      per_all_assignments_f.effective_start_date%TYPE;
  l_validation_end_date        per_all_assignments_f.effective_end_date%TYPE;
  l_proc                       varchar2(72) := g_package||'update_emp_asg';
  l_session_id                 number;
  l_unused_start_date          date;
  l_unused_end_date            date;
  l_old_asg_status per_assignment_status_types.per_system_status%type;
  l_new_asg_status per_assignment_status_types.per_system_status%type;

begin
 --
  l_object_version_number := p_object_version_number;

 if g_debug then
  hr_utility.set_location(' Entering:'||l_proc, 10);
 end if;
  --
  -- Call the new code
  -- Added p_gsp_post_process_warning
  --
  hr_assignment_api.update_emp_asg
  (p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => p_datetrack_update_mode
  ,p_assignment_id                => p_assignment_id
  ,p_object_version_number        => l_object_version_number
  ,p_supervisor_id                => p_supervisor_id
  ,p_assignment_number            => p_assignment_number
  ,p_change_reason                => p_change_reason
  ,p_assignment_status_type_id    => p_assignment_status_type_id
  ,p_comments                     => p_comments
  ,p_date_probation_end           => p_date_probation_end
  ,p_default_code_comb_id         => p_default_code_comb_id
  ,p_frequency                    => p_frequency
  ,p_internal_address_line        => p_internal_address_line
  ,p_manager_flag                 => p_manager_flag
  ,p_normal_hours                 => p_normal_hours
  ,p_perf_review_period           => p_perf_review_period
  ,p_perf_review_period_frequency => p_perf_review_period_frequency
  ,p_probation_period             => p_probation_period
  ,p_probation_unit               => p_probation_unit
  ,p_sal_review_period            => p_sal_review_period
  ,p_sal_review_period_frequency  => p_sal_review_period_frequency
  ,p_set_of_books_id              => p_set_of_books_id
  ,p_source_type                  => p_source_type
  ,p_time_normal_finish           => p_time_normal_finish
  ,p_time_normal_start            => p_time_normal_start
  ,p_bargaining_unit_code         => p_bargaining_unit_code
  ,p_labour_union_member_flag     => p_labour_union_member_flag
  ,p_hourly_salaried_code         => p_hourly_salaried_code
  ,p_ass_attribute_category       => p_ass_attribute_category
  ,p_ass_attribute1               => p_ass_attribute1
  ,p_ass_attribute2               => p_ass_attribute2
  ,p_ass_attribute3               => p_ass_attribute3
  ,p_ass_attribute4               => p_ass_attribute4
  ,p_ass_attribute5               => p_ass_attribute5
  ,p_ass_attribute6               => p_ass_attribute6
  ,p_ass_attribute7               => p_ass_attribute7
  ,p_ass_attribute8               => p_ass_attribute8
  ,p_ass_attribute9               => p_ass_attribute9
  ,p_ass_attribute10              => p_ass_attribute10
  ,p_ass_attribute11              => p_ass_attribute11
  ,p_ass_attribute12              => p_ass_attribute12
  ,p_ass_attribute13              => p_ass_attribute13
  ,p_ass_attribute14              => p_ass_attribute14
  ,p_ass_attribute15              => p_ass_attribute15
  ,p_ass_attribute16              => p_ass_attribute16
  ,p_ass_attribute17              => p_ass_attribute17
  ,p_ass_attribute18              => p_ass_attribute18
  ,p_ass_attribute19              => p_ass_attribute19
  ,p_ass_attribute20              => p_ass_attribute20
  ,p_ass_attribute21              => p_ass_attribute21
  ,p_ass_attribute22              => p_ass_attribute22
  ,p_ass_attribute23              => p_ass_attribute23
  ,p_ass_attribute24              => p_ass_attribute24
  ,p_ass_attribute25              => p_ass_attribute25
  ,p_ass_attribute26              => p_ass_attribute26
  ,p_ass_attribute27              => p_ass_attribute27
  ,p_ass_attribute28              => p_ass_attribute28
  ,p_ass_attribute29              => p_ass_attribute29
  ,p_ass_attribute30              => p_ass_attribute30
  ,p_title                        => p_title
  ,p_segment1                     => p_segment1
  ,p_segment2                     => p_segment2
  ,p_segment3                     => p_segment3
  ,p_segment4                     => p_segment4
  ,p_segment5                     => p_segment5
  ,p_segment6                     => p_segment6
  ,p_segment7                     => p_segment7
  ,p_segment8                     => p_segment8
  ,p_segment9                     => p_segment9
  ,p_segment10                    => p_segment10
  ,p_segment11                    => p_segment11
  ,p_segment12                    => p_segment12
  ,p_segment13                    => p_segment13
  ,p_segment14                    => p_segment14
  ,p_segment15                    => p_segment15
  ,p_segment16                    => p_segment16
  ,p_segment17                    => p_segment17
  ,p_segment18                    => p_segment18
  ,p_segment19                    => p_segment19
  ,p_segment20                    => p_segment20
  ,p_segment21                    => p_segment21
  ,p_segment22                    => p_segment22
  ,p_segment23                    => p_segment23
  ,p_segment24                    => p_segment24
  ,p_segment25                    => p_segment25
  ,p_segment26                    => p_segment26
  ,p_segment27                    => p_segment27
  ,p_segment28                    => p_segment28
  ,p_segment29                    => p_segment29
  ,p_segment30                    => p_segment30
  ,p_concat_segments              => p_concat_segments
  ,p_contract_id                  => p_contract_id
  ,p_establishment_id             => p_establishment_id
  ,p_collective_agreement_id      => p_collective_agreement_id
  ,p_cagr_id_flex_num             => p_cagr_id_flex_num
  ,p_cag_segment1                 => p_cag_segment1
  ,p_cag_segment2                 => p_cag_segment2
  ,p_cag_segment3                 => p_cag_segment3
  ,p_cag_segment4                 => p_cag_segment4
  ,p_cag_segment5                 => p_cag_segment5
  ,p_cag_segment6                 => p_cag_segment6
  ,p_cag_segment7                 => p_cag_segment7
  ,p_cag_segment8                 => p_cag_segment8
  ,p_cag_segment9                 => p_cag_segment9
  ,p_cag_segment10                => p_cag_segment10
  ,p_cag_segment11                => p_cag_segment11
  ,p_cag_segment12                => p_cag_segment12
  ,p_cag_segment13                => p_cag_segment13
  ,p_cag_segment14                => p_cag_segment14
  ,p_cag_segment15                => p_cag_segment15
  ,p_cag_segment16                => p_cag_segment16
  ,p_cag_segment17                => p_cag_segment17
  ,p_cag_segment18                => p_cag_segment18
  ,p_cag_segment19                => p_cag_segment19
  ,p_cag_segment20                => p_cag_segment20
  ,p_notice_period                => p_notice_period
  ,p_notice_period_uom            => p_notice_period_uom
  ,p_employee_category            => p_employee_category
  ,p_work_at_home                 => p_work_at_home
  ,p_job_post_source_name	  => p_job_post_source_name
  ,p_cagr_grade_def_id            => l_cagr_grade_def_id
  ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
  ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
  ,p_comment_id                   => l_comment_id
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ,p_concatenated_segments        => l_concatenated_segments
  ,p_no_managers_warning          => l_no_managers_warning
  ,p_other_manager_warning        => l_other_manager_warning
  ,p_hourly_salaried_warning      => l_hourly_salaried_warning
  ,p_gsp_post_process_warning     => l_gsp_post_process_warning
  ,p_supervisor_assignment_id     => p_supervisor_assignment_id
); -- bug 2999562

  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  p_soft_coding_keyflex_id := l_soft_coding_keyflex_id;
  p_comment_id             := l_comment_id;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_concatenated_segments  := l_concatenated_segments;
  p_no_managers_warning    := l_no_managers_warning;
  p_other_manager_warning  := l_other_manager_warning;
  p_cagr_grade_def_id          := l_cagr_grade_def_id;
  p_cagr_concatenated_segments := l_cagr_concatenated_segments;
  p_hourly_salaried_warning    := l_hourly_salaried_warning;
  --
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
 end if;
end update_emp_asg;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_emp_asg >--NEW3-------------------------|
-- ----------------------------------------------------------------------------
--
-- This is an overloaded procedure to include p_gsp_post_process_warning
-- OUT parameter.
--
procedure update_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_assignment_status_type_id    in     number
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_projected_assignment_end     in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_segment1                     in     varchar2
  ,p_segment2                     in     varchar2
  ,p_segment3                     in     varchar2
  ,p_segment4                     in     varchar2
  ,p_segment5                     in     varchar2
  ,p_segment6                     in     varchar2
  ,p_segment7                     in     varchar2
  ,p_segment8                     in     varchar2
  ,p_segment9                     in     varchar2
  ,p_segment10                    in     varchar2
  ,p_segment11                    in     varchar2
  ,p_segment12                    in     varchar2
  ,p_segment13                    in     varchar2
  ,p_segment14                    in     varchar2
  ,p_segment15                    in     varchar2
  ,p_segment16                    in     varchar2
  ,p_segment17                    in     varchar2
  ,p_segment18                    in     varchar2
  ,p_segment19                    in     varchar2
  ,p_segment20                    in     varchar2
  ,p_segment21                    in     varchar2
  ,p_segment22                    in     varchar2
  ,p_segment23                    in     varchar2
  ,p_segment24                    in     varchar2
  ,p_segment25                    in     varchar2
  ,p_segment26                    in     varchar2
  ,p_segment27                    in     varchar2
  ,p_segment28                    in     varchar2
  ,p_segment29                    in     varchar2
  ,p_segment30                    in     varchar2
-- Bug fix for 944911
-- p_concatenated_segments has been changed from in out to out
-- Added new param p_concat_segments as in param
  ,p_concat_segments              in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_collective_agreement_id      in     number
  ,p_cagr_id_flex_num             in     number
  ,p_cag_segment1                 in     varchar2
  ,p_cag_segment2                 in     varchar2
  ,p_cag_segment3                 in     varchar2
  ,p_cag_segment4                 in     varchar2
  ,p_cag_segment5                 in     varchar2
  ,p_cag_segment6                 in     varchar2
  ,p_cag_segment7                 in     varchar2
  ,p_cag_segment8                 in     varchar2
  ,p_cag_segment9                 in     varchar2
  ,p_cag_segment10                in     varchar2
  ,p_cag_segment11                in     varchar2
  ,p_cag_segment12                in     varchar2
  ,p_cag_segment13                in     varchar2
  ,p_cag_segment14                in     varchar2
  ,p_cag_segment15                in     varchar2
  ,p_cag_segment16                in     varchar2
  ,p_cag_segment17                in     varchar2
  ,p_cag_segment18                in     varchar2
  ,p_cag_segment19                in     varchar2
  ,p_cag_segment20                in     varchar2
  ,p_notice_period		  in     number
  ,p_notice_period_uom	      	  in     varchar2
  ,p_employee_category	          in     varchar2
  ,p_work_at_home		  in     varchar2
  ,p_job_post_source_name	  in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_cagr_grade_def_id            in out nocopy number -- bug 2359997
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_soft_coding_keyflex_id       in out nocopy number -- bug 2359997
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ,p_gsp_post_process_warning        out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_comment_id             per_all_assignments_f.comment_id%TYPE;
  l_effective_start_date   per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date     per_all_assignments_f.effective_end_date%TYPE;
  l_object_version_number  per_all_assignments_f.object_version_number%TYPE;
  l_no_managers_warning    boolean;
  l_other_manager_warning  boolean;
  l_soft_coding_keyflex_id per_all_assignments_f.soft_coding_keyflex_id%TYPE
  := p_soft_coding_keyflex_id;  -- bug 2359997
  l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_old_conc_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_effective_date         date;
  l_date_probation_end     per_all_assignments_f.date_probation_end%TYPE;
  l_flex_num               fnd_id_flex_segments.id_flex_num%TYPE;
  l_organization_id        per_all_assignments_f.organization_id%type;
  l_location_id            per_all_assignments_f.location_id%type;
  l_cagr_grade_def_id      per_cagr_grades_def.cagr_grade_def_id%TYPE
  := p_cagr_grade_def_id;  -- bug 2359997
  l_cagr_id_flex_num       per_cagr_grades_def.id_flex_num%TYPE;
  l_cagr_concatenated_segments varchar2(2000);
  l_hourly_salaried_warning boolean;
  l_gsp_post_process_warning varchar2(2000); -- bug 2999562
  --
  -- Internal working variables
  --
  l_assignment_type            per_all_assignments_f.assignment_type%TYPE;
  l_business_group_id          per_business_groups.business_group_id%TYPE;
  l_payroll_id_updated         boolean;
  l_people_group_id            per_all_assignments_f.people_group_id%TYPE;
  l_org_now_no_manager_warning boolean;
  l_validation_start_date      per_all_assignments_f.effective_start_date%TYPE;
  l_validation_end_date        per_all_assignments_f.effective_end_date%TYPE;
  l_proc                       varchar2(72) := g_package||'update_emp_asg';
  l_session_id                 number;
  l_unused_start_date          date;
  l_unused_end_date            date;
  l_old_asg_status per_assignment_status_types.per_system_status%type;
  l_new_asg_status per_assignment_status_types.per_system_status%type;
  --
  -- bug 2359997 new variables to indicate whether key flex id parameters
  -- enter the program with a value.
  --
  --l_scl_null_ind               number(1) := 0;
  l_cag_null_ind               number(1) := 0;
  --
  -- bug 2359997 new variables for derived values where key flex id is known.
  --
  l_scl_segment1               varchar2(60) := p_segment1;
  l_scl_segment2               varchar2(60) := p_segment2;
  l_scl_segment3               varchar2(60) := p_segment3;
  l_scl_segment4               varchar2(60) := p_segment4;
  l_scl_segment5               varchar2(60) := p_segment5;
  l_scl_segment6               varchar2(60) := p_segment6;
  l_scl_segment7               varchar2(60) := p_segment7;
  l_scl_segment8               varchar2(60) := p_segment8;
  l_scl_segment9               varchar2(60) := p_segment9;
  l_scl_segment10              varchar2(60) := p_segment10;
  l_scl_segment11              varchar2(60) := p_segment11;
  l_scl_segment12              varchar2(60) := p_segment12;
  l_scl_segment13              varchar2(60) := p_segment13;
  l_scl_segment14              varchar2(60) := p_segment14;
  l_scl_segment15              varchar2(60) := p_segment15;
  l_scl_segment16              varchar2(60) := p_segment16;
  l_scl_segment17              varchar2(60) := p_segment17;
  l_scl_segment18              varchar2(60) := p_segment18;
  l_scl_segment19              varchar2(60) := p_segment19;
  l_scl_segment20              varchar2(60) := p_segment20;
  l_scl_segment21              varchar2(60) := p_segment21;
  l_scl_segment22              varchar2(60) := p_segment22;
  l_scl_segment23              varchar2(60) := p_segment23;
  l_scl_segment24              varchar2(60) := p_segment24;
  l_scl_segment25              varchar2(60) := p_segment25;
  l_scl_segment26              varchar2(60) := p_segment26;
  l_scl_segment27              varchar2(60) := p_segment27;
  l_scl_segment28              varchar2(60) := p_segment28;
  l_scl_segment29              varchar2(60) := p_segment29;
  l_scl_segment30              varchar2(60) := p_segment30;
  --
  l_cag_segment1               varchar2(60) := p_cag_segment1;
  l_cag_segment2               varchar2(60) := p_cag_segment2;
  l_cag_segment3               varchar2(60) := p_cag_segment3;
  l_cag_segment4               varchar2(60) := p_cag_segment4;
  l_cag_segment5               varchar2(60) := p_cag_segment5;
  l_cag_segment6               varchar2(60) := p_cag_segment6;
  l_cag_segment7               varchar2(60) := p_cag_segment7;
  l_cag_segment8               varchar2(60) := p_cag_segment8;
  l_cag_segment9               varchar2(60) := p_cag_segment9;
  l_cag_segment10              varchar2(60) := p_cag_segment10;
  l_cag_segment11              varchar2(60) := p_cag_segment11;
  l_cag_segment12              varchar2(60) := p_cag_segment12;
  l_cag_segment13              varchar2(60) := p_cag_segment13;
  l_cag_segment14              varchar2(60) := p_cag_segment14;
  l_cag_segment15              varchar2(60) := p_cag_segment15;
  l_cag_segment16              varchar2(60) := p_cag_segment16;
  l_cag_segment17              varchar2(60) := p_cag_segment17;
  l_cag_segment18              varchar2(60) := p_cag_segment18;
  l_cag_segment19              varchar2(60) := p_cag_segment19;
  l_cag_segment20              varchar2(60) := p_cag_segment20;
  --
  lv_object_version_number     number := p_object_version_number ;
  lv_cagr_grade_def_id         number := p_cagr_grade_def_id ;
  lv_soft_coding_keyflex_id    number := p_soft_coding_keyflex_id ;
  --
  l_projected_assignment_end date;--fix for bug 6595592.
  cursor csr_old_asg_status is
  select ast.per_system_status
  from per_assignment_status_types ast,
       per_all_assignments_f asg
  where ast.assignment_status_type_id = asg.assignment_status_type_id
  and   asg.assignment_id = p_assignment_id
  and   l_effective_date between asg.effective_start_date
        and asg.effective_end_date;
  --
  cursor csr_new_asg_status is
  select ast.per_system_status
  from per_assignment_status_types ast
  where ast.assignment_status_type_id = p_assignment_status_type_id;
  --
  cursor csr_get_assignment_type is
    select asg.assignment_type
         , asg.business_group_id
         -- , asg.soft_coding_keyflex_id -- bug 2359997
         , asg.organization_id
         , asg.location_id
      from per_all_assignments_f asg
     where asg.assignment_id = p_assignment_id
       and l_effective_date  between asg.effective_start_date
                             and     asg.effective_end_date;
  --
/* Added By Fs
  cursor csr_get_soft_coding_keyflex is  -- bug 2359997
    select asg.soft_coding_keyflex_id
      from per_all_assignments_f asg
     where asg.assignment_id = p_assignment_id
       and l_effective_date  between asg.effective_start_date
                             and     asg.effective_end_date;
  --
  cursor csr_scl_idsel is
    select plr.rule_mode                       id_flex_num
    from   pay_legislation_rules               plr,
           per_business_groups_perf            pgr
    where  plr.legislation_code                = pgr.legislation_code
    and    pgr.business_group_id               = l_business_group_id
    and    plr.rule_type                       = 'S'
    and    exists
          (select 1
           from   fnd_segment_attribute_values fsav
           where  fsav.id_flex_num             = plr.rule_mode
           and    fsav.application_id          = 800
           and    fsav.id_flex_code            = 'SCL'
           and    fsav.segment_attribute_type  = 'ASSIGNMENT'
           and    fsav.attribute_value         = 'Y')
    and    exists
          (select 1
           from   pay_legislation_rules        plr2
           where  plr2.legislation_code        = plr.legislation_code
           and    plr2.rule_type               = 'SDL'
           and    plr2.rule_mode               = 'A') ;
  --
  -- bug 2359997 get hr_soft_coding_keyflex segment values where
  -- soft_coding_keyflex_id is known
  --
  cursor c_scl_segments is
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
     from   hr_soft_coding_keyflex
     where  soft_coding_keyflex_id = l_soft_coding_keyflex_id;
  END */
  --
  -- bug 2359997 get per_cagr_grades_def segment values where
  -- cagr_grade_def_id is known
  --
  cursor c_cag_segments is
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
            segment20
     from   per_cagr_grades_def
     where  cagr_grade_def_id = l_cagr_grade_def_id;
--
--
begin
--
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
 if g_debug then
  hr_utility.set_location('XXX'||l_proc||'/'||p_concat_segments,6);
 end if;
  --
  -- Truncate date and date_probation_end values,
  -- effectively removing time element.
  --
  l_effective_date     := trunc(p_effective_date);
  l_date_probation_end := trunc(p_date_probation_end);
  --
  l_object_version_number := p_object_version_number;
  --
  -- Bug 944911 - changed p_concatenated_segments to p_concat_segments
  --
  l_old_conc_segments:=p_concat_segments;
  --
  -- Issue a savepoint.
  --
  savepoint update_emp_asg;
  --
  --  bug 2359997 use cursor c_scl_segments to bring back segment values if
  --  l_soft_coding_keyflex_id has a value.
  --
/* Added By FS
  if l_soft_coding_keyflex_id is not null
  then
     l_scl_null_ind := 1;
     open c_scl_segments;
     fetch c_scl_segments into l_scl_segment1,
                               l_scl_segment2,
                               l_scl_segment3,
                               l_scl_segment4,
                               l_scl_segment5,
                               l_scl_segment6,
                               l_scl_segment7,
                               l_scl_segment8,
                               l_scl_segment9,
                               l_scl_segment10,
                               l_scl_segment11,
                               l_scl_segment12,
                               l_scl_segment13,
                               l_scl_segment14,
                               l_scl_segment15,
                               l_scl_segment16,
                               l_scl_segment17,
                               l_scl_segment18,
                               l_scl_segment19,
                               l_scl_segment20,
                               l_scl_segment21,
                               l_scl_segment22,
                               l_scl_segment23,
                               l_scl_segment24,
                               l_scl_segment25,
                               l_scl_segment26,
                               l_scl_segment27,
                               l_scl_segment28,
                               l_scl_segment29,
                               l_scl_segment30;
    close c_scl_segments;
  else
    l_scl_null_ind := 0;
  end if;
Added by FS */
  --
  -- if cagr_grade_def_id has a value then use it to get segment values using
  -- cursor cag_segments
  --
  if l_cagr_grade_def_id is not null
  then
    l_cag_null_ind := 1;
    open c_cag_segments;
      fetch c_cag_segments into l_cag_segment1,
                                l_cag_segment2,
                                l_cag_segment3,
                                l_cag_segment4,
                                l_cag_segment5,
                                l_cag_segment6,
                                l_cag_segment7,
                                l_cag_segment8,
                                l_cag_segment9,
                                l_cag_segment10,
                                l_cag_segment11,
                                l_cag_segment12,
                                l_cag_segment13,
                                l_cag_segment14,
                                l_cag_segment15,
                                l_cag_segment16,
                                l_cag_segment17,
                                l_cag_segment18,
                                l_cag_segment19,
                                l_cag_segment20;
    close c_cag_segments;
  else
    l_cag_null_ind := 0;
  end if;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_emp_asg
    --
    hr_assignment_bk2.update_emp_asg_b
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => p_datetrack_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_supervisor_id                => p_supervisor_id
      ,p_assignment_number            => p_assignment_number
      ,p_change_reason                => p_change_reason
      ,p_assignment_status_type_id    => p_assignment_status_type_id
      ,p_comments                     => p_comments
      ,p_date_probation_end           => l_date_probation_end
      ,p_default_code_comb_id         => p_default_code_comb_id
      ,p_frequency                    => p_frequency
      ,p_internal_address_line        => p_internal_address_line
      ,p_manager_flag                 => p_manager_flag
      ,p_normal_hours                 => p_normal_hours
      ,p_perf_review_period           => p_perf_review_period
      ,p_perf_review_period_frequency => p_perf_review_period_frequency
      ,p_probation_period             => p_probation_period
      ,p_probation_unit               => p_probation_unit
      ,p_projected_assignment_end     => p_projected_assignment_end
      ,p_sal_review_period            => p_sal_review_period
      ,p_sal_review_period_frequency  => p_sal_review_period_frequency
      ,p_set_of_books_id              => p_set_of_books_id
      ,p_source_type                  => p_source_type
      ,p_time_normal_finish           => p_time_normal_finish
      ,p_time_normal_start            => p_time_normal_start
      ,p_bargaining_unit_code         => p_bargaining_unit_code
      ,p_labour_union_member_flag     => p_labour_union_member_flag
      ,p_hourly_salaried_code         => p_hourly_salaried_code
      ,p_ass_attribute_category       => p_ass_attribute_category
      ,p_ass_attribute1               => p_ass_attribute1
      ,p_ass_attribute2               => p_ass_attribute2
      ,p_ass_attribute3               => p_ass_attribute3
      ,p_ass_attribute4               => p_ass_attribute4
      ,p_ass_attribute5               => p_ass_attribute5
      ,p_ass_attribute6               => p_ass_attribute6
      ,p_ass_attribute7               => p_ass_attribute7
      ,p_ass_attribute8               => p_ass_attribute8
      ,p_ass_attribute9               => p_ass_attribute9
      ,p_ass_attribute10              => p_ass_attribute10
      ,p_ass_attribute11              => p_ass_attribute11
      ,p_ass_attribute12              => p_ass_attribute12
      ,p_ass_attribute13              => p_ass_attribute13
      ,p_ass_attribute14              => p_ass_attribute14
      ,p_ass_attribute15              => p_ass_attribute15
      ,p_ass_attribute16              => p_ass_attribute16
      ,p_ass_attribute17              => p_ass_attribute17
      ,p_ass_attribute18              => p_ass_attribute18
      ,p_ass_attribute19              => p_ass_attribute19
      ,p_ass_attribute20              => p_ass_attribute20
      ,p_ass_attribute21              => p_ass_attribute21
      ,p_ass_attribute22              => p_ass_attribute22
      ,p_ass_attribute23              => p_ass_attribute23
      ,p_ass_attribute24              => p_ass_attribute24
      ,p_ass_attribute25              => p_ass_attribute25
      ,p_ass_attribute26              => p_ass_attribute26
      ,p_ass_attribute27              => p_ass_attribute27
      ,p_ass_attribute28              => p_ass_attribute28
      ,p_ass_attribute29              => p_ass_attribute29
      ,p_ass_attribute30              => p_ass_attribute30
      ,p_title                        => p_title
      ,p_segment1                     => l_scl_segment1
      ,p_segment2                     => l_scl_segment2
      ,p_segment3                     => l_scl_segment3
      ,p_segment4                     => l_scl_segment4
      ,p_segment5                     => l_scl_segment5
      ,p_segment6                     => l_scl_segment6
      ,p_segment7                     => l_scl_segment7
      ,p_segment8                     => l_scl_segment8
      ,p_segment9                     => l_scl_segment9
      ,p_segment10                    => l_scl_segment10
      ,p_segment11                    => l_scl_segment11
      ,p_segment12                    => l_scl_segment12
      ,p_segment13                    => l_scl_segment13
      ,p_segment14                    => l_scl_segment14
      ,p_segment15                    => l_scl_segment15
      ,p_segment16                    => l_scl_segment16
      ,p_segment17                    => l_scl_segment17
      ,p_segment18                    => l_scl_segment18
      ,p_segment19                    => l_scl_segment19
      ,p_segment20                    => l_scl_segment20
      ,p_segment21                    => l_scl_segment21
      ,p_segment22                    => l_scl_segment22
      ,p_segment23                    => l_scl_segment23
      ,p_segment24                    => l_scl_segment24
      ,p_segment25                    => l_scl_segment25
      ,p_segment26                    => l_scl_segment26
      ,p_segment27                    => l_scl_segment27
      ,p_segment28                    => l_scl_segment28
      ,p_segment29                    => l_scl_segment29
      ,p_segment30                    => l_scl_segment30
      -- Bug 944911
      -- Amended p_concatendated_segments by p_concat_segments
      ,p_concat_segments              => l_old_conc_segments
      ,p_contract_id                  => p_contract_id
      ,p_establishment_id             => p_establishment_id
      ,p_collective_agreement_id      => p_collective_agreement_id
      ,p_cagr_id_flex_num             => p_cagr_id_flex_num
      ,p_cag_segment1                 => l_cag_segment1
      ,p_cag_segment2                 => l_cag_segment2
      ,p_cag_segment3                 => l_cag_segment3
      ,p_cag_segment4                 => l_cag_segment4
      ,p_cag_segment5                 => l_cag_segment5
      ,p_cag_segment6                 => l_cag_segment6
      ,p_cag_segment7                 => l_cag_segment7
      ,p_cag_segment8                 => l_cag_segment8
      ,p_cag_segment9                 => l_cag_segment9
      ,p_cag_segment10                => l_cag_segment10
      ,p_cag_segment11                => l_cag_segment11
      ,p_cag_segment12                => l_cag_segment12
      ,p_cag_segment13                => l_cag_segment13
      ,p_cag_segment14                => l_cag_segment14
      ,p_cag_segment15                => l_cag_segment15
      ,p_cag_segment16                => l_cag_segment16
      ,p_cag_segment17                => l_cag_segment17
      ,p_cag_segment18                => l_cag_segment18
      ,p_cag_segment19                => l_cag_segment19
      ,p_cag_segment20                => l_cag_segment20
      ,p_notice_period		      => p_notice_period
      ,p_notice_period_uom	      => p_notice_period_uom
      ,p_employee_category	      => p_employee_category
      ,p_work_at_home		      => p_work_at_home
      ,p_job_post_source_name	      => p_job_post_source_name
      ,p_supervisor_assignment_id     => p_supervisor_assignment_id
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EMP_ASG'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_emp_asg
    --
  end;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Validation in addition to Table Handlers
  --
  -- Get assignment type.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_assignment_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => l_effective_date);
  --
  open  csr_get_assignment_type;
  fetch csr_get_assignment_type
   into l_assignment_type
      , l_business_group_id
      -- , l_soft_coding_keyflex_id  -- bug 2359997
      , l_organization_id
      , l_location_id;
  --
  if csr_get_assignment_type%NOTFOUND then
    close csr_get_assignment_type;
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_assignment_type;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  if l_assignment_type <> 'E' then
    hr_utility.set_message(801,'HR_7948_ASG_ASG_NOT_EMP');
    hr_utility.raise_error;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 21);
 end if;
  --
  --added validation for bug 1867720
  --
  if p_assignment_status_type_id <> hr_api.g_number then
    open csr_old_asg_status;
    fetch csr_old_asg_status into l_old_asg_status;
    close csr_old_asg_status;
    --
    open csr_new_asg_status;
    fetch csr_new_asg_status into l_new_asg_status;
      if csr_new_asg_status%notfound
        OR (csr_new_asg_status%found AND l_old_asg_status <> l_new_asg_status)
      then
      fnd_message.set_name('PER','HR_7949_ASG_DIF_SYSTEM_TYPE');
      fnd_message.set_token('SYSTYPE',l_old_asg_status);
      fnd_message.raise_error;
    end if;
    close csr_new_asg_status;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 21);
 end if;
  --
  -- insert the profile options and effective date for the flexfield
  -- validation to work
  --
  if g_debug then
   hr_utility.set_location('EMP Asg B Profile:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);
   hr_utility.set_location('EMP Asg l_organization_id:' || l_organization_id, 13163);
  end if;
  hr_kflex_utility.set_profiles
  (p_business_group_id => l_business_group_id
  ,p_assignment_id     => p_assignment_id
  ,p_organization_id   => NVL(per_qh_maintain_update.p_qh_organization_id,l_organization_id)  -- Fix For Bug # 8238220
  ,p_location_id       => l_location_id);
  --
  per_qh_maintain_update.p_qh_organization_id := NULL;   --- Added For Bug # 8238220
  hr_kflex_utility.set_session_date
  (p_effective_date => l_effective_date
  ,p_session_id     => l_session_id);
  if g_debug then
      hr_utility.set_location('EMP Asg A Profile:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);
  end if;
  --
  -- Bug 944911
  -- Added to next 2 ifs check for p_concatenated_segments also
  --
    --
  -- Update or select the soft_coding_keyflex_id
  --
/* Added By Fs
  if l_scl_null_ind = 0 -- bug 2359997 added this if statement
                        -- soft coding keyflex id came in null
  then
     open csr_get_soft_coding_keyflex;  -- bug 2359997 get soft coding keyflex
       fetch csr_get_soft_coding_keyflex
        into l_soft_coding_keyflex_id;
     --
     if csr_get_soft_coding_keyflex%NOTFOUND then
       close csr_get_soft_coding_keyflex;
       hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
       hr_utility.raise_error;
     end if;
     --
     close csr_get_soft_coding_keyflex;
     --
    -- Start of Fix for   Bug 2548555
     --
     if   nvl(l_scl_segment1,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment2,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment3,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment4,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment5,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment6,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment7,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment8,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment9,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment10,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment11,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment12,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment13,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment14,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment15,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment16,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment17,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment18,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment19,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment20,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment21,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment22,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment23,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment24,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment25,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment26,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment27,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment28,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment29,'x') <> hr_api.g_varchar2
       or nvl(l_scl_segment30,'x') <> hr_api.g_varchar2
       -- bug 944911
       -- changed p_concatenated_segments to p_concat_segments
       or nvl(p_concat_segments,'x') <> hr_api.g_varchar2
 --
 -- End of Fix for Bug 2548555
 --
    then
       open csr_scl_idsel;
       fetch csr_scl_idsel into l_flex_num;
       --
       if csr_scl_idsel%NOTFOUND
       then
         close csr_scl_idsel;
         if   l_scl_segment1 is not null
           or l_scl_segment2 is not null
           or l_scl_segment3 is not null
           or l_scl_segment4 is not null
           or l_scl_segment5 is not null
           or l_scl_segment6 is not null
           or l_scl_segment7 is not null
           or l_scl_segment8 is not null
           or l_scl_segment9 is not null
           or l_scl_segment10 is not null
           or l_scl_segment11 is not null
           or l_scl_segment12 is not null
           or l_scl_segment13 is not null
           or l_scl_segment14 is not null
           or l_scl_segment15 is not null
           or l_scl_segment16 is not null
           or l_scl_segment17 is not null
           or l_scl_segment18 is not null
           or l_scl_segment19 is not null
           or l_scl_segment20 is not null
           or l_scl_segment21 is not null
           or l_scl_segment22 is not null
           or l_scl_segment23 is not null
           or l_scl_segment24 is not null
           or l_scl_segment25 is not null
           or l_scl_segment26 is not null
           or l_scl_segment27 is not null
           or l_scl_segment28 is not null
           or l_scl_segment29 is not null
           or l_scl_segment30 is not null
           or p_concat_segments is not null
         then
            --
            hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE', l_proc);
            hr_utility.set_message_token('STEP','5');
            hr_utility.raise_error;
         end if;
      else -- csr_scl_idsel is found
         close csr_scl_idsel;
         --
         -- Process Logic
         --
         --
         -- Update or select the soft_coding_keyflex_id
         --
         hr_kflex_utility.upd_or_sel_keyflex_comb
           (p_appl_short_name        => 'PER'
           ,p_flex_code              => 'SCL'
           ,p_flex_num               => l_flex_num
           ,p_segment1               => l_scl_segment1
           ,p_segment2               => l_scl_segment2
           ,p_segment3               => l_scl_segment3
           ,p_segment4               => l_scl_segment4
           ,p_segment5               => l_scl_segment5
           ,p_segment6               => l_scl_segment6
           ,p_segment7               => l_scl_segment7
           ,p_segment8               => l_scl_segment8
           ,p_segment9               => l_scl_segment9
           ,p_segment10              => l_scl_segment10
           ,p_segment11              => l_scl_segment11
           ,p_segment12              => l_scl_segment12
           ,p_segment13              => l_scl_segment13
           ,p_segment14              => l_scl_segment14
           ,p_segment15              => l_scl_segment15
           ,p_segment16              => l_scl_segment16
           ,p_segment17              => l_scl_segment17
           ,p_segment18              => l_scl_segment18
           ,p_segment19              => l_scl_segment19
           ,p_segment20              => l_scl_segment20
           ,p_segment21              => l_scl_segment21
           ,p_segment22              => l_scl_segment22
           ,p_segment23              => l_scl_segment23
           ,p_segment24              => l_scl_segment24
           ,p_segment25              => l_scl_segment25
           ,p_segment26              => l_scl_segment26
           ,p_segment27              => l_scl_segment27
           ,p_segment28              => l_scl_segment28
           ,p_segment29              => l_scl_segment29
           ,p_segment30              => l_scl_segment30
           ,p_concat_segments_in     => l_old_conc_segments
           ,p_ccid                   => l_soft_coding_keyflex_id
           ,p_concat_segments_out    => l_concatenated_segments
           );
          --
          -- update the combinations column
          --
          update_scl_concat_segs
          (p_soft_coding_keyflex_id  => l_soft_coding_keyflex_id
          ,p_concatenated_segments   => l_concatenated_segments
          );
       --
       end if; -- csr_scl_idsel%NOTFOUND
    --
    end if;  -- l_scl_segment1 <> hr_api.g_varchar2
  --
  end if; -- l_soft_coding_key_flex_id is null
  --
Added By FS */


--
-- Start of fix for Bug 2622747
--
 if g_debug then
   hr_utility.set_location('EMP Asg B V_SCL:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);
 end if;
  validate_SCL (
   p_validate                     => FALSE --Changed from p_validate to false for fix of #3180527
  ,p_assignment_id                => p_assignment_id
  ,p_effective_date               => l_effective_date
  ,p_business_group_id            => l_business_group_id
  ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
  ,p_concatenated_segments        => l_concatenated_segments
  ,p_concat_segments              => NULL
  ,p_segment1                     => l_scl_segment1
  ,p_segment2                     => l_scl_segment2
  ,p_segment3                     => l_scl_segment3
  ,p_segment4                     => l_scl_segment4
  ,p_segment5                     => l_scl_segment5
  ,p_segment6                     => l_scl_segment6
  ,p_segment7                     => l_scl_segment7
  ,p_segment8                     => l_scl_segment8
  ,p_segment9                     => l_scl_segment9
  ,p_segment10                    => l_scl_segment10
  ,p_segment11                    => l_scl_segment11
  ,p_segment12                    => l_scl_segment12
  ,p_segment13                    => l_scl_segment13
  ,p_segment14                    => l_scl_segment14
  ,p_segment15                    => l_scl_segment15
  ,p_segment16                    => l_scl_segment16
  ,p_segment17                    => l_scl_segment17
  ,p_segment18                    => l_scl_segment18
  ,p_segment19                    => l_scl_segment19
  ,p_segment20                    => l_scl_segment20
  ,p_segment21                    => l_scl_segment21
  ,p_segment22                    => l_scl_segment22
  ,p_segment23                    => l_scl_segment23
  ,p_segment24                    => l_scl_segment24
  ,p_segment25                    => l_scl_segment25
  ,p_segment26                    => l_scl_segment26
  ,p_segment27                    => l_scl_segment27
  ,p_segment28                    => l_scl_segment28
  ,p_segment29                    => l_scl_segment29
  ,p_segment30                    => l_scl_segment30
  );
--End of fix for Bug 2622747
  --
  if g_debug then
    hr_utility.set_location('EMP Asg A V_SCL:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 23);
 end if;
  --
  --
  -- Update or select the cagr_grade_def_id
  --
  -- need to call the lck procedure early, to fetch the
  -- old value of cagr_id_flex_num
  -- before passing it into the hr_cgd_upd.upd_or_sel function.
  -- This is because the user may be updating a grade definition,
  -- but not changing
  -- or specifying the cagr_id_flex_num (ie the grade structure).
  -- Also, need to fetch the old cagr_grade_def_id, as
  -- the user may be updating some
  -- segments, and not changing others.
  -- Passing cagr_grade_id into the hr_cgd_upd.upd_or_sel
  -- function allows that function to derive the old values.
  --
  l_cagr_id_flex_num  := p_cagr_id_flex_num;
  --
  if (p_cagr_id_flex_num  = hr_api.g_number)
  then
     per_asg_shd.lck
      (p_effective_date          => l_effective_date,
       -- Bug 3430504. Pass l_effective_date in place of p_effective_date.
       p_datetrack_mode          => p_datetrack_update_mode,
       p_assignment_id           => p_assignment_id,
       p_object_version_number   => p_object_version_number,
       p_validation_start_date   => l_unused_start_date,
       p_validation_end_date     => l_unused_end_date
       );
     l_cagr_id_flex_num := per_asg_shd.g_old_rec.cagr_id_flex_num;
     -- l_cagr_grade_def_id := per_asg_shd.g_old_rec.cagr_grade_def_id;
     -- commented out for bug 2359997
  end if;
  --
  --
  -- Bug 4003788   added the check for the cagr_id_flex_num also
  if l_cag_null_ind = 0  and l_cagr_id_flex_num is not null -- bug 2359997
  then
     l_cagr_grade_def_id := per_asg_shd.g_old_rec.cagr_grade_def_id;
     --
     hr_cgd_upd.upd_or_sel
     (p_segment1               => l_cag_segment1
     ,p_segment2               => l_cag_segment2
     ,p_segment3               => l_cag_segment3
     ,p_segment4               => l_cag_segment4
     ,p_segment5               => l_cag_segment5
     ,p_segment6               => l_cag_segment6
     ,p_segment7               => l_cag_segment7
     ,p_segment8               => l_cag_segment8
     ,p_segment9               => l_cag_segment9
     ,p_segment10              => l_cag_segment10
     ,p_segment11              => l_cag_segment11
     ,p_segment12              => l_cag_segment12
     ,p_segment13              => l_cag_segment13
     ,p_segment14              => l_cag_segment14
     ,p_segment15              => l_cag_segment15
     ,p_segment16              => l_cag_segment16
     ,p_segment17              => l_cag_segment17
     ,p_segment18              => l_cag_segment18
     ,p_segment19              => l_cag_segment19
     ,p_segment20              => l_cag_segment20
     ,p_id_flex_num            => l_cagr_id_flex_num
     ,p_business_group_id      => l_business_group_id
     ,p_cagr_grade_def_id      => l_cagr_grade_def_id
     ,p_concatenated_segments  => l_cagr_concatenated_segments
      );
     --
 if g_debug then
     hr_utility.set_location(l_proc, 24);
 end if;
     --
  end if; --  l_cagr_grade_def_id is null
  --
 if g_debug then
  hr_utility.set_location(l_proc, 25);
 end if;

  -- fix for bug 6595592 starts here.
    if (p_projected_assignment_end = to_char(hr_api.g_date) OR p_projected_assignment_end = hr_api.g_varchar2) then   --fix for 6862763
     l_projected_assignment_end :=hr_api.g_date;
    else
     l_projected_assignment_end :=p_projected_assignment_end;
    end if;
 -- fix for bug 6595592 ends here.
  --
  --
  -- Update assignment.
  --
  if g_debug then
    hr_utility.set_location('EMP Asg B UPD:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);
  end if;
  per_asg_upd.upd
    (p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => l_business_group_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comment_id                   => l_comment_id
    ,p_comments                     => p_comments
    ,p_date_probation_end           => l_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_projected_assignment_end     => l_projected_assignment_end -- fix for bug 6595592.
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_notice_period		    => p_notice_period
    ,p_notice_period_uom	    => p_notice_period_uom
    ,p_employee_category	    => p_employee_category
    ,p_work_at_home		    => p_work_at_home
    ,p_job_post_source_name	    => p_job_post_source_name
    ,p_title                        => p_title
    ,p_payroll_id_updated           => l_payroll_id_updated
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_no_managers_warning          => l_no_managers_warning
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_validation_start_date        => l_validation_start_date
    ,p_validation_end_date          => l_validation_end_date
    ,p_object_version_number        => l_object_version_number
    ,p_effective_date               => l_effective_date
    ,p_datetrack_mode               => p_datetrack_update_mode
    ,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    ,p_collective_agreement_id      => p_collective_agreement_id
    ,p_cagr_grade_def_id            => l_cagr_grade_def_id
    ,p_cagr_id_flex_num             => p_cagr_id_flex_num
    ,p_validate                     => FALSE
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
  --
  if g_debug then
     hr_utility.set_location('EMP Asg A UPD:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 25);
 end if;
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_emp_asg
    --
    hr_assignment_bk2.update_emp_asg_a
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => p_datetrack_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_supervisor_id                => p_supervisor_id
      ,p_assignment_number            => p_assignment_number
      ,p_change_reason                => p_change_reason
      ,p_assignment_status_type_id    => p_assignment_status_type_id
      ,p_comments                     => p_comments
      ,p_date_probation_end           => l_date_probation_end
      ,p_default_code_comb_id         => p_default_code_comb_id
      ,p_frequency                    => p_frequency
      ,p_internal_address_line        => p_internal_address_line
      ,p_manager_flag                 => p_manager_flag
      ,p_normal_hours                 => p_normal_hours
      ,p_perf_review_period           => p_perf_review_period
      ,p_perf_review_period_frequency => p_perf_review_period_frequency
      ,p_probation_period             => p_probation_period
      ,p_probation_unit               => p_probation_unit
      ,p_projected_assignment_end     => p_projected_assignment_end
      ,p_sal_review_period            => p_sal_review_period
      ,p_sal_review_period_frequency  => p_sal_review_period_frequency
      ,p_set_of_books_id              => p_set_of_books_id
      ,p_source_type                  => p_source_type
      ,p_time_normal_finish           => p_time_normal_finish
      ,p_time_normal_start            => p_time_normal_start
      ,p_bargaining_unit_code         => p_bargaining_unit_code
      ,p_labour_union_member_flag     => p_labour_union_member_flag
      ,p_hourly_salaried_code         => p_hourly_salaried_code
      ,p_ass_attribute_category       => p_ass_attribute_category
      ,p_ass_attribute1               => p_ass_attribute1
      ,p_ass_attribute2               => p_ass_attribute2
      ,p_ass_attribute3               => p_ass_attribute3
      ,p_ass_attribute4               => p_ass_attribute4
      ,p_ass_attribute5               => p_ass_attribute5
      ,p_ass_attribute6               => p_ass_attribute6
      ,p_ass_attribute7               => p_ass_attribute7
      ,p_ass_attribute8               => p_ass_attribute8
      ,p_ass_attribute9               => p_ass_attribute9
      ,p_ass_attribute10              => p_ass_attribute10
      ,p_ass_attribute11              => p_ass_attribute11
      ,p_ass_attribute12              => p_ass_attribute12
      ,p_ass_attribute13              => p_ass_attribute13
      ,p_ass_attribute14              => p_ass_attribute14
      ,p_ass_attribute15              => p_ass_attribute15
      ,p_ass_attribute16              => p_ass_attribute16
      ,p_ass_attribute17              => p_ass_attribute17
      ,p_ass_attribute18              => p_ass_attribute18
      ,p_ass_attribute19              => p_ass_attribute19
      ,p_ass_attribute20              => p_ass_attribute20
      ,p_ass_attribute21              => p_ass_attribute21
      ,p_ass_attribute22              => p_ass_attribute22
      ,p_ass_attribute23              => p_ass_attribute23
      ,p_ass_attribute24              => p_ass_attribute24
      ,p_ass_attribute25              => p_ass_attribute25
      ,p_ass_attribute26              => p_ass_attribute26
      ,p_ass_attribute27              => p_ass_attribute27
      ,p_ass_attribute28              => p_ass_attribute28
      ,p_ass_attribute29              => p_ass_attribute29
      ,p_ass_attribute30              => p_ass_attribute30
      ,p_title                        => p_title
      ,p_segment1                     => l_scl_segment1
      ,p_segment2                     => l_scl_segment2
      ,p_segment3                     => l_scl_segment3
      ,p_segment4                     => l_scl_segment4
      ,p_segment5                     => l_scl_segment5
      ,p_segment6                     => l_scl_segment6
      ,p_segment7                     => l_scl_segment7
      ,p_segment8                     => l_scl_segment8
      ,p_segment9                     => l_scl_segment9
      ,p_segment10                    => l_scl_segment10
      ,p_segment11                    => l_scl_segment11
      ,p_segment12                    => l_scl_segment12
      ,p_segment13                    => l_scl_segment13
      ,p_segment14                    => l_scl_segment14
      ,p_segment15                    => l_scl_segment15
      ,p_segment16                    => l_scl_segment16
      ,p_segment17                    => l_scl_segment17
      ,p_segment18                    => l_scl_segment18
      ,p_segment19                    => l_scl_segment19
      ,p_segment20                    => l_scl_segment20
      ,p_segment21                    => l_scl_segment21
      ,p_segment22                    => l_scl_segment22
      ,p_segment23                    => l_scl_segment23
      ,p_segment24                    => l_scl_segment24
      ,p_segment25                    => l_scl_segment25
      ,p_segment26                    => l_scl_segment26
      ,p_segment27                    => l_scl_segment27
      ,p_segment28                    => l_scl_segment28
      ,p_segment29                    => l_scl_segment29
      ,p_segment30                    => l_scl_segment30
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_comment_id                   => l_comment_id
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_no_managers_warning          => l_no_managers_warning
      ,p_other_manager_warning        => l_other_manager_warning
      -- Bug 944911
      -- Added the new input param
      ,p_concat_segments              => l_old_conc_segments
      ,p_contract_id                  => p_contract_id
      ,p_establishment_id             => p_establishment_id
      ,p_collective_agreement_id      => p_collective_agreement_id
      ,p_cagr_id_flex_num             => p_cagr_id_flex_num
      ,p_cag_segment1                 => l_cag_segment1
      ,p_cag_segment2                 => l_cag_segment2
      ,p_cag_segment3                 => l_cag_segment3
      ,p_cag_segment4                 => l_cag_segment4
      ,p_cag_segment5                 => l_cag_segment5
      ,p_cag_segment6                 => l_cag_segment6
      ,p_cag_segment7                 => l_cag_segment7
      ,p_cag_segment8                 => l_cag_segment8
      ,p_cag_segment9                 => l_cag_segment9
      ,p_cag_segment10                => l_cag_segment10
      ,p_cag_segment11                => l_cag_segment11
      ,p_cag_segment12                => l_cag_segment12
      ,p_cag_segment13                => l_cag_segment13
      ,p_cag_segment14                => l_cag_segment14
      ,p_cag_segment15                => l_cag_segment15
      ,p_cag_segment16                => l_cag_segment16
      ,p_cag_segment17                => l_cag_segment17
      ,p_cag_segment18                => l_cag_segment18
      ,p_cag_segment19                => l_cag_segment19
      ,p_cag_segment20                => l_cag_segment20
      ,p_notice_period		      => p_notice_period
      ,p_notice_period_uom	      => p_notice_period_uom
      ,p_employee_category	      => p_employee_category
      ,p_work_at_home		      => p_work_at_home
      ,p_job_post_source_name	      => p_job_post_source_name
      ,p_cagr_grade_def_id            => l_cagr_grade_def_id
      ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
      ,p_hourly_salaried_warning      => l_hourly_salaried_warning
      ,p_supervisor_assignment_id     => p_supervisor_assignment_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EMP_ASG'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_emp_asg
    --
  end;

  --
  -- call pqh post process procedure -- bug 2999562
  --
  pqh_gsp_post_process.call_pp_from_assignments(
      p_effective_date    => p_effective_date
     ,p_assignment_id     => p_assignment_id
     ,p_date_track_mode   => p_datetrack_update_mode
     ,p_warning_mesg      => l_gsp_post_process_warning
  );

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
  p_soft_coding_keyflex_id := l_soft_coding_keyflex_id;
  p_comment_id             := l_comment_id;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_concatenated_segments  := l_concatenated_segments;
  p_no_managers_warning    := l_no_managers_warning;
  p_other_manager_warning  := l_other_manager_warning;
  p_cagr_grade_def_id          := l_cagr_grade_def_id;
  p_cagr_concatenated_segments := l_cagr_concatenated_segments;
  p_hourly_salaried_warning    := l_hourly_salaried_warning;
  p_gsp_post_process_warning   := l_gsp_post_process_warning; -- bug 2999562
  --
  -- remove data from the session table
  hr_kflex_utility.unset_session_date
    (p_session_id     => l_session_id);
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  hr_utility.set_location('EMP Asg Leaving:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_emp_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := p_object_version_number;
    p_comment_id             := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_concatenated_segments  := l_old_conc_segments;
    p_no_managers_warning    := l_no_managers_warning;
    p_other_manager_warning  := l_other_manager_warning;
    p_cagr_concatenated_segments := null;
    p_hourly_salaried_warning    := l_hourly_salaried_warning;
    p_soft_coding_keyflex_id     := l_soft_coding_keyflex_id;
    p_gsp_post_process_warning   := l_gsp_post_process_warning; -- bug 2999562
    --
    -- bug 2359997 only re-set to null if key flex ids came in as null.
    --
    --
    if l_cag_null_ind = 0
    then
       p_cagr_grade_def_id       := null;
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number      := lv_object_version_number ;
    p_cagr_grade_def_id          := lv_cagr_grade_def_id ;
    p_soft_coding_keyflex_id     := lv_soft_coding_keyflex_id ;

    p_cagr_concatenated_segments     := null;
    p_concatenated_segments          := null;
    p_comment_id                     := null;
    p_effective_start_date           := null;
    p_effective_end_date             := null;
    p_no_managers_warning            := null;
    p_other_manager_warning          := null;
    p_hourly_salaried_warning        := null;
    p_gsp_post_process_warning       := null;

    ROLLBACK TO update_emp_asg;
    raise;
    --
    -- End of fix.
    --
end update_emp_asg;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_cwk_asg >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cwk_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_category          in     varchar2
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_default_code_comb_id         in     number
  ,p_establishment_id             in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_project_title		  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_supervisor_id                in     number
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_title                        in     varchar2
  ,p_vendor_assignment_number     in     varchar2
  ,p_vendor_employee_number       in     varchar2
  ,p_vendor_id                    in     number
  ,p_vendor_site_id               in     number
  ,p_po_header_id                 in     number
  ,p_po_line_id                   in     number
  ,p_projected_assignment_end     in     date
  ,p_assignment_status_type_id    in     number
  ,p_concat_segments              in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_attribute21                  in     varchar2
  ,p_attribute22                  in     varchar2
  ,p_attribute23                  in     varchar2
  ,p_attribute24                  in     varchar2
  ,p_attribute25                  in     varchar2
  ,p_attribute26                  in     varchar2
  ,p_attribute27                  in     varchar2
  ,p_attribute28                  in     varchar2
  ,p_attribute29                  in     varchar2
  ,p_attribute30                  in     varchar2
  ,p_scl_segment1                 in     varchar2
  ,p_scl_segment2                 in     varchar2
  ,p_scl_segment3                 in     varchar2
  ,p_scl_segment4                 in     varchar2
  ,p_scl_segment5                 in     varchar2
  ,p_scl_segment6                 in     varchar2
  ,p_scl_segment7                 in     varchar2
  ,p_scl_segment8                 in     varchar2
  ,p_scl_segment9                 in     varchar2
  ,p_scl_segment10                in     varchar2
  ,p_scl_segment11                in     varchar2
  ,p_scl_segment12                in     varchar2
  ,p_scl_segment13                in     varchar2
  ,p_scl_segment14                in     varchar2
  ,p_scl_segment15                in     varchar2
  ,p_scl_segment16                in     varchar2
  ,p_scl_segment17                in     varchar2
  ,p_scl_segment18                in     varchar2
  ,p_scl_segment19                in     varchar2
  ,p_scl_segment20                in     varchar2
  ,p_scl_segment21                in     varchar2
  ,p_scl_segment22                in     varchar2
  ,p_scl_segment23                in     varchar2
  ,p_scl_segment24                in     varchar2
  ,p_scl_segment25                in     varchar2
  ,p_scl_segment26                in     varchar2
  ,p_scl_segment27                in     varchar2
  ,p_scl_segment28                in     varchar2
  ,p_scl_segment29                in     varchar2
  ,p_scl_segment30                in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_comment_id                      out nocopy number
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_concatenated_segments           out nocopy varchar2
  ,p_hourly_salaried_warning         out nocopy boolean) IS
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_org_now_no_manager_warning BOOLEAN;
  l_effective_start_date       per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date         per_all_assignments_f.effective_end_date%TYPE;
  l_comment_id                 per_all_assignments_f.comment_id%TYPE;
  l_no_managers_warning        BOOLEAN;
  l_other_manager_warning      BOOLEAN;
  l_object_version_number      per_all_assignments_f.object_version_number%TYPE;
  l_soft_coding_keyflex_id     per_all_assignments_f.soft_coding_keyflex_id%TYPE;
  l_concatenated_segments      hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_old_conc_segments          hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_hourly_salaried_warning    BOOLEAN;
  l_session_id                 NUMBER;
  l_flex_num                   fnd_id_flex_segments.id_flex_num%TYPE;
  l_payroll_id_updated         BOOLEAN;
  --
  -- Internal working variables
  --
  l_proc                       VARCHAR2(72) := g_package||'update_cwk_asg';
  l_effective_date             DATE;
  l_projected_assignment_end   DATE;
  l_organization_id            per_all_assignments_f.organization_id%TYPE;
  l_business_group_id          per_business_groups.business_group_id%TYPE;
  l_assignment_type            per_all_assignments_f.assignment_type%TYPE;
  l_location_id                per_all_assignments_f.location_id%TYPE;
  l_old_asg_status             per_assignment_status_types.per_system_status%TYPE;
  l_new_asg_status             per_assignment_status_types.per_system_status%TYPE;
  l_cagr_grade_def_id          NUMBER;
  l_validation_start_date      per_all_assignments_f.effective_start_date%TYPE;
  l_validation_end_date        per_all_assignments_f.effective_end_date%TYPE;
  l_po_header_id               NUMBER := p_po_header_id;
  l_vendor_id                  NUMBER := p_vendor_id;
  --
  /*
  l_old_conc_segments          hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_date_probation_end         per_all_assignments_f.date_probation_end%TYPE;
  l_assignment_type            per_all_assignments_f.assignment_type%TYPE;
  l_people_group_id            per_all_assignments_f.people_group_id%TYPE;
  l_unused_start_date          date;
  l_unused_end_date            date;
  */
  --
  lv_object_version_number     number := p_object_version_number ;
  --
  cursor csr_old_asg_status is
    select ast.per_system_status
    from   per_assignment_status_types ast,
           per_all_assignments_f asg
    where  ast.assignment_status_type_id = asg.assignment_status_type_id
    and    asg.assignment_id             = p_assignment_id
    and    l_effective_date between asg.effective_start_date and asg.effective_end_date;
  --
  cursor csr_new_asg_status is
    select ast.per_system_status
    from   per_assignment_status_types ast
    where  ast.assignment_status_type_id = p_assignment_status_type_id;
  --
  cursor csr_get_assignment_type is
    select asg.assignment_type
         , asg.business_group_id
         , asg.soft_coding_keyflex_id
         , asg.organization_id
         , asg.location_id
      from per_all_assignments_f asg
     where asg.assignment_id = p_assignment_id
       and l_effective_date  between asg.effective_start_date
                             and     asg.effective_end_date;
  --
  cursor csr_scl_idsel is
    select plr.rule_mode            id_flex_num
    from   pay_legislation_rules    plr,
           per_business_groups_perf pgr
    where  plr.legislation_code  = pgr.legislation_code
    and    pgr.business_group_id = l_business_group_id
    and    plr.rule_type         = 'CWK_S'
    and    exists
          (select 1
           from   fnd_segment_attribute_values fsav
           where  fsav.id_flex_num             = plr.rule_mode
           and    fsav.application_id          = 800
           and    fsav.id_flex_code            = 'SCL'
           and    fsav.segment_attribute_type  = 'ASSIGNMENT'
           and    fsav.attribute_value         = 'Y')
    and    exists
          (select 1
           from   pay_legislation_rules        plr2
           where  plr2.legislation_code        = plr.legislation_code
           and    plr2.rule_type               = 'CWK_SDL'
           and    plr2.rule_mode               = 'A') ;

	      --start code for bug 6961562
		l_installed          boolean;
		l_po_installed      VARCHAR2(1);
		l_industry           VARCHAR2(1);
		l_vendor_id_1      number default null;
		l_vendor_site_id_1      number default null;

		cursor po_cwk is
		select vendor_id,vendor_site_id from
		per_all_assignments_f paf
		where paf.assignment_id = p_assignment_id
		and nvl(l_effective_date,sysdate) between paf.effective_start_date
		and paf.effective_end_date;
	     --end code for bug 6961562

  --
BEGIN
  --
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  -- Truncate date and date_probation_end values, effectively removing time element.
  --
  l_effective_date     := trunc(p_effective_date);
  l_projected_assignment_end := trunc(p_projected_assignment_end);
  --
  l_object_version_number := p_object_version_number;
  --
  -- Bug 944911 - changed p_concatenated_segments to p_concat_segments
  --
  l_old_conc_segments := p_concat_segments;
  --
  -- Issue a savepoint.
  --
  SAVEPOINT update_cwk_asg;
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of update_emp_asg
    --
    hr_assignment_bkm.update_cwk_asg_b
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => p_datetrack_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_assignment_category		  => p_assignment_category
      ,p_assignment_number            => p_assignment_number
      ,p_change_reason                => p_change_reason
      ,p_comments                     => p_comments
      ,p_default_code_comb_id         => p_default_code_comb_id
      ,p_establishment_id             => p_establishment_id
      ,p_frequency                    => p_frequency
      ,p_internal_address_line        => p_internal_address_line
      ,p_labour_union_member_flag     => p_labour_union_member_flag
      ,p_manager_flag                 => p_manager_flag
      ,p_normal_hours                 => p_normal_hours
      ,p_project_title				  => p_project_title
      ,p_set_of_books_id              => p_set_of_books_id
      ,p_source_type                  => p_source_type
      ,p_supervisor_id                => p_supervisor_id
      ,p_time_normal_finish           => p_time_normal_finish
      ,p_time_normal_start            => p_time_normal_start
      ,p_title                        => p_title
      ,p_vendor_assignment_number     => p_vendor_assignment_number
      ,p_vendor_employee_number       => p_vendor_employee_number
      ,p_vendor_id                    => p_vendor_id
      ,p_vendor_site_id               => p_vendor_site_id
      ,p_po_header_id                 => p_po_header_id
      ,p_po_line_id                   => p_po_line_id
      ,p_projected_assignment_end     => l_projected_assignment_end
      ,p_assignment_status_type_id    => p_assignment_status_type_id
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
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30
      ,p_scl_segment1                 => p_scl_segment1
      ,p_scl_segment2                 => p_scl_segment2
      ,p_scl_segment3                 => p_scl_segment3
      ,p_scl_segment4                 => p_scl_segment4
      ,p_scl_segment5                 => p_scl_segment5
      ,p_scl_segment6                 => p_scl_segment6
      ,p_scl_segment7                 => p_scl_segment7
      ,p_scl_segment8                 => p_scl_segment8
      ,p_scl_segment9                 => p_scl_segment9
      ,p_scl_segment10                => p_scl_segment10
      ,p_scl_segment11                => p_scl_segment11
      ,p_scl_segment12                => p_scl_segment12
      ,p_scl_segment13                => p_scl_segment13
      ,p_scl_segment14                => p_scl_segment14
      ,p_scl_segment15                => p_scl_segment15
      ,p_scl_segment16                => p_scl_segment16
      ,p_scl_segment17                => p_scl_segment17
      ,p_scl_segment18                => p_scl_segment18
      ,p_scl_segment19                => p_scl_segment19
      ,p_scl_segment20                => p_scl_segment20
      ,p_scl_segment21                => p_scl_segment21
      ,p_scl_segment22                => p_scl_segment22
      ,p_scl_segment23                => p_scl_segment23
      ,p_scl_segment24                => p_scl_segment24
      ,p_scl_segment25                => p_scl_segment25
      ,p_scl_segment26                => p_scl_segment26
      ,p_scl_segment27                => p_scl_segment27
      ,p_scl_segment28                => p_scl_segment28
      ,p_scl_segment29                => p_scl_segment29
      ,p_scl_segment30                => p_scl_segment30
      ,p_supervisor_assignment_id     => p_supervisor_assignment_id
      );
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
	  --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CWK_ASG'
        ,p_hook_type   => 'BP'
        );
      --
      -- End of API User Hook for the before hook of update_emp_asg
      --
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Validation in addition to Table Handlers
  --
  -- Get assignment type.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_assignment_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => l_effective_date);
  --
  OPEN  csr_get_assignment_type;
  FETCH csr_get_assignment_type
   INTO l_assignment_type
      , l_business_group_id
      , l_soft_coding_keyflex_id
      , l_organization_id
      , l_location_id;
  --
  IF csr_get_assignment_type%NOTFOUND THEN
    --
    CLOSE csr_get_assignment_type;
	--
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
	--
  END IF;
  --
  CLOSE csr_get_assignment_type;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  IF l_assignment_type <> 'C' THEN
    --
	hr_utility.set_message(801,'HR_289575_ASG_ASG_NOT_EMP');
    hr_utility.raise_error;
	--
  END IF;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 21);
 end if;
  --
  --added validation for bug 1867720
  --
  IF p_assignment_status_type_id <> hr_api.g_number THEN
    --
    OPEN csr_old_asg_status;
    FETCH csr_old_asg_status INTO l_old_asg_status;
    CLOSE csr_old_asg_status;
    --
    OPEN csr_new_asg_status;
    FETCH csr_new_asg_status INTO l_new_asg_status;
	--
    IF csr_new_asg_status%notfound OR
	  (csr_new_asg_status%found AND l_old_asg_status <> l_new_asg_status) THEN
	  --
      fnd_message.set_name('PER','HR_7949_ASG_DIF_SYSTEM_TYPE');
      fnd_message.set_token('SYSTYPE',l_old_asg_status);
      fnd_message.raise_error;
	  --
    END IF;
	--
    CLOSE csr_new_asg_status;
	--
  END IF;
  --
  -- insert the profile options and effective date for the flexfield
  -- validation to work
  --
  hr_kflex_utility.set_profiles
    (p_business_group_id => l_business_group_id
    ,p_assignment_id     => p_assignment_id
    ,p_organization_id   => l_organization_id
    ,p_location_id       => l_location_id);
  --
  hr_kflex_utility.set_session_date
    (p_effective_date => l_effective_date
    ,p_session_id     => l_session_id);
  --
  -- Bug 944911
  -- Added to next 2 ifs check for p_concatenated_segments also
  --
  if   p_scl_segment1 <> hr_api.g_varchar2
    or p_scl_segment2 <> hr_api.g_varchar2
    or p_scl_segment3 <> hr_api.g_varchar2
    or p_scl_segment4 <> hr_api.g_varchar2
    or p_scl_segment5 <> hr_api.g_varchar2
    or p_scl_segment6 <> hr_api.g_varchar2
    or p_scl_segment7 <> hr_api.g_varchar2
    or p_scl_segment8 <> hr_api.g_varchar2
    or p_scl_segment9 <> hr_api.g_varchar2
    or p_scl_segment10 <> hr_api.g_varchar2
    or p_scl_segment11 <> hr_api.g_varchar2
    or p_scl_segment12 <> hr_api.g_varchar2
    or p_scl_segment13 <> hr_api.g_varchar2
    or p_scl_segment14 <> hr_api.g_varchar2
    or p_scl_segment15 <> hr_api.g_varchar2
    or p_scl_segment16 <> hr_api.g_varchar2
    or p_scl_segment17 <> hr_api.g_varchar2
    or p_scl_segment18 <> hr_api.g_varchar2
    or p_scl_segment19 <> hr_api.g_varchar2
    or p_scl_segment20 <> hr_api.g_varchar2
    or p_scl_segment21 <> hr_api.g_varchar2
    or p_scl_segment22 <> hr_api.g_varchar2
    or p_scl_segment23 <> hr_api.g_varchar2
    or p_scl_segment24 <> hr_api.g_varchar2
    or p_scl_segment25 <> hr_api.g_varchar2
    or p_scl_segment26 <> hr_api.g_varchar2
    or p_scl_segment27 <> hr_api.g_varchar2
    or p_scl_segment28 <> hr_api.g_varchar2
    or p_scl_segment29 <> hr_api.g_varchar2
    or p_scl_segment30 <> hr_api.g_varchar2
    -- bug 944911
    -- changed p_concatenated_segments to p_concat_segments
    or p_concat_segments <> hr_api.g_varchar2 then
    --
    OPEN csr_scl_idsel;
    FETCH csr_scl_idsel INTO l_flex_num;
    --
    IF csr_scl_idsel%NOTFOUND THEN
	  --
      CLOSE csr_scl_idsel;
	  --
      if   p_scl_segment1 is not null
        or p_scl_segment2 is not null
        or p_scl_segment3 is not null
        or p_scl_segment4 is not null
        or p_scl_segment5 is not null
        or p_scl_segment6 is not null
        or p_scl_segment7 is not null
        or p_scl_segment8 is not null
        or p_scl_segment9 is not null
        or p_scl_segment10 is not null
        or p_scl_segment11 is not null
        or p_scl_segment12 is not null
        or p_scl_segment13 is not null
        or p_scl_segment14 is not null
        or p_scl_segment15 is not null
        or p_scl_segment16 is not null
        or p_scl_segment17 is not null
        or p_scl_segment18 is not null
        or p_scl_segment19 is not null
        or p_scl_segment20 is not null
        or p_scl_segment21 is not null
        or p_scl_segment22 is not null
        or p_scl_segment23 is not null
        or p_scl_segment24 is not null
        or p_scl_segment25 is not null
        or p_scl_segment26 is not null
        or p_scl_segment27 is not null
        or p_scl_segment28 is not null
        or p_scl_segment29 is not null
        or p_scl_segment30 is not null
        or p_concat_segments is not null then
        --
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP','5');
        hr_utility.raise_error;
		--
      END IF;
	  --
    ELSE
	  --
      CLOSE csr_scl_idsel;
      --
      -- Process Logic
      --
      -- Update or select the soft_coding_keyflex_id
      --
      hr_kflex_utility.upd_or_sel_keyflex_comb
      (p_appl_short_name        => 'PER'
      ,p_flex_code              => 'SCL'
      ,p_flex_num               => l_flex_num
      ,p_segment1               => p_scl_segment1
      ,p_segment2               => p_scl_segment2
      ,p_segment3               => p_scl_segment3
      ,p_segment4               => p_scl_segment4
      ,p_segment5               => p_scl_segment5
      ,p_segment6               => p_scl_segment6
      ,p_segment7               => p_scl_segment7
      ,p_segment8               => p_scl_segment8
      ,p_segment9               => p_scl_segment9
      ,p_segment10              => p_scl_segment10
      ,p_segment11              => p_scl_segment11
      ,p_segment12              => p_scl_segment12
      ,p_segment13              => p_scl_segment13
      ,p_segment14              => p_scl_segment14
      ,p_segment15              => p_scl_segment15
      ,p_segment16              => p_scl_segment16
      ,p_segment17              => p_scl_segment17
      ,p_segment18              => p_scl_segment18
      ,p_segment19              => p_scl_segment19
      ,p_segment20              => p_scl_segment20
      ,p_segment21              => p_scl_segment21
      ,p_segment22              => p_scl_segment22
      ,p_segment23              => p_scl_segment23
      ,p_segment24              => p_scl_segment24
      ,p_segment25              => p_scl_segment25
      ,p_segment26              => p_scl_segment26
      ,p_segment27              => p_scl_segment27
      ,p_segment28              => p_scl_segment28
      ,p_segment29              => p_scl_segment29
      ,p_segment30              => p_scl_segment30
      ,p_concat_segments_in     => l_old_conc_segments
      ,p_ccid                   => l_soft_coding_keyflex_id
      ,p_concat_segments_out    => l_concatenated_segments
      );
      --
      -- update the combinations column
      --
      update_scl_concat_segs
        (p_soft_coding_keyflex_id  => l_soft_coding_keyflex_id
        ,p_concatenated_segments   => l_concatenated_segments);
      --
    END IF;
  --
  END IF;

 if g_debug then
  hr_utility.set_location(l_proc, 22);
 end if;

  --
  -- Default the PO Header if the line is passed in and the
  -- header is not.
  --
  IF p_po_line_id IS NOT NULL AND l_po_header_id IS NULL THEN

    l_po_header_id := get_po_for_line
      (p_po_line_id => p_po_line_id);

  END IF;

  --
  -- Default the Supplier if the Site is entered and Supplier is not.
  --
  IF p_vendor_site_id IS NOT NULL AND l_vendor_id IS NULL THEN

    l_vendor_id := get_supplier_for_site
      (p_vendor_site_id => p_vendor_site_id);

  END IF;


   --start code for bug 6961562
  -- PO
  l_installed := fnd_installation.get(appl_id => 210
		,dep_appl_id => 210
          ,status => l_po_installed
          ,industry => l_industry);

  if l_po_installed <> 'N' then
    open po_cwk;
    fetch po_cwk into l_vendor_id_1,l_vendor_site_id_1;
    if po_cwk%found then
    if (l_vendor_id_1 <> p_vendor_id)
    or (l_vendor_site_id_1 <> p_vendor_site_id) then
	PO_HR_INTERFACE_PVT.is_Supplier_Updatable( p_assignment_id => p_assignment_id,
                                               p_effective_date => l_effective_date );
        end if;
     end if;
     close po_cwk;
  end if;
  --end code for bug 6961562


 if g_debug then
  hr_utility.set_location(l_proc, 23);
 end if;

  /*
  --
 if g_debug then
  hr_utility.set_location(l_proc, 24);
 end if;
  --
  -- Update or select the cagr_grade_def_id
  --
  -- need to call the lck procedure early, to fetch the old value of cagr_id_flex_num
  -- before passing it into the hr_cgd_upd.upd_or_sel function.
  -- This is because the user may be updating a grade definition, but not changing
  -- or specifying the cagr_id_flex_num (ie the grade structure).
  -- Also, need to fetch the old cagr_grade_def_id, as the user may be updating some
  -- segments, and not changing others. Passing cagr_grade_id into the hr_cgd_upd.upd_or_sel
  -- function allows that function to derive the old values.
  --
  l_cagr_id_flex_num  := p_cagr_id_flex_num;
   --
  If (p_cagr_id_flex_num  = hr_api.g_number) THEN
    --
    per_asg_shd.lck
      (p_effective_date          => l_effective_date,
       -- Bug 3430504. Pass l_effective_date in place of p_effective_date.
       p_datetrack_mode          => p_datetrack_update_mode,
       p_assignment_id           => p_assignment_id,
       p_object_version_number   => p_object_version_number,
       p_validation_start_date   => l_unused_start_date,
       p_validation_end_date     => l_unused_end_date
       );
	--
    l_cagr_id_flex_num := per_asg_shd.g_old_rec.cagr_id_flex_num;
    l_cagr_grade_def_id := per_asg_shd.g_old_rec.cagr_grade_def_id;
	--
  End if;
  --
  hr_cgd_upd.upd_or_sel
    (p_segment1               => p_cag_segment1
    ,p_segment2               => p_cag_segment2
    ,p_segment3               => p_cag_segment3
    ,p_segment4               => p_cag_segment4
    ,p_segment5               => p_cag_segment5
    ,p_segment6               => p_cag_segment6
    ,p_segment7               => p_cag_segment7
    ,p_segment8               => p_cag_segment8
    ,p_segment9               => p_cag_segment9
    ,p_segment10              => p_cag_segment10
    ,p_segment11              => p_cag_segment11
    ,p_segment12              => p_cag_segment12
    ,p_segment13              => p_cag_segment13
    ,p_segment14              => p_cag_segment14
    ,p_segment15              => p_cag_segment15
    ,p_segment16              => p_cag_segment16
    ,p_segment17              => p_cag_segment17
    ,p_segment18              => p_cag_segment18
    ,p_segment19              => p_cag_segment19
    ,p_segment20              => p_cag_segment20
    ,p_id_flex_num            => l_cagr_id_flex_num
    ,p_business_group_id      => l_business_group_id
    ,p_cagr_grade_def_id      => l_cagr_grade_def_id
    ,p_concatenated_segments  => l_cagr_concatenated_segments);
  --
  */
 if g_debug then
  hr_utility.set_location(l_proc, 25);
 end if;
  --
  -- Update assignment.
  --
  per_asg_upd.upd
    (p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => l_business_group_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_assignment_number            => p_assignment_number
    ,p_employment_category          => p_assignment_category
    ,p_change_reason                => p_change_reason
    ,p_comment_id                   => l_comment_id
    ,p_comments                     => p_comments
    --,p_date_probation_end           => l_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_project_title                => p_project_title
    --,p_perf_review_period           => p_perf_review_period
    --,p_perf_review_period_frequency => p_perf_review_period_frequency
    --,p_probation_period             => p_probation_period
    --,p_probation_unit               => p_probation_unit
    --,p_sal_review_period            => p_sal_review_period
    --,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    --,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    --,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_attribute_category
    ,p_ass_attribute1               => p_attribute1
    ,p_ass_attribute2               => p_attribute2
    ,p_ass_attribute3               => p_attribute3
    ,p_ass_attribute4               => p_attribute4
    ,p_ass_attribute5               => p_attribute5
    ,p_ass_attribute6               => p_attribute6
    ,p_ass_attribute7               => p_attribute7
    ,p_ass_attribute8               => p_attribute8
    ,p_ass_attribute9               => p_attribute9
    ,p_ass_attribute10              => p_attribute10
    ,p_ass_attribute11              => p_attribute11
    ,p_ass_attribute12              => p_attribute12
    ,p_ass_attribute13              => p_attribute13
    ,p_ass_attribute14              => p_attribute14
    ,p_ass_attribute15              => p_attribute15
    ,p_ass_attribute16              => p_attribute16
    ,p_ass_attribute17              => p_attribute17
    ,p_ass_attribute18              => p_attribute18
    ,p_ass_attribute19              => p_attribute19
    ,p_ass_attribute20              => p_attribute20
    ,p_ass_attribute21              => p_attribute21
    ,p_ass_attribute22              => p_attribute22
    ,p_ass_attribute23              => p_attribute23
    ,p_ass_attribute24              => p_attribute24
    ,p_ass_attribute25              => p_attribute25
    ,p_ass_attribute26              => p_attribute26
    ,p_ass_attribute27              => p_attribute27
    ,p_ass_attribute28              => p_attribute28
    ,p_ass_attribute29              => p_attribute29
    ,p_ass_attribute30              => p_attribute30
    --,p_notice_period		        => p_notice_period
    --,p_notice_period_uom	        => p_notice_period_uom
    --,p_employee_category	        => p_employee_category
    --,p_work_at_home		            => p_work_at_home
    --,p_job_post_source_name	        => p_job_post_source_name
    ,p_title                        => p_title
    ,p_vendor_assignment_number     => p_vendor_assignment_number
    ,p_vendor_employee_number       => p_vendor_employee_number
    ,p_vendor_id                    => l_vendor_id
    ,p_vendor_site_id               => p_vendor_site_id
    ,p_po_header_id                 => l_po_header_id
    ,p_po_line_id                   => p_po_line_id
    ,p_projected_assignment_end     => l_projected_assignment_end
    ,p_payroll_id_updated           => l_payroll_id_updated
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_no_managers_warning          => l_no_managers_warning
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_validation_start_date        => l_validation_start_date
    ,p_validation_end_date          => l_validation_end_date
    ,p_object_version_number        => l_object_version_number
    ,p_effective_date               => l_effective_date
    ,p_datetrack_mode               => p_datetrack_update_mode
    --,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    --,p_collective_agreement_id      => p_collective_agreement_id
    ,p_cagr_grade_def_id            => l_cagr_grade_def_id
    --,p_cagr_id_flex_num             => p_cagr_id_flex_num
    ,p_validate                     => FALSE
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 26);
 end if;
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of update_cwk_asg
    --
    hr_assignment_bkm.update_cwk_asg_a
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => p_datetrack_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_assignment_category		  => p_assignment_category
      ,p_assignment_number            => p_assignment_number
      ,p_change_reason                => p_change_reason
      ,p_comments                     => p_comments
      ,p_default_code_comb_id         => p_default_code_comb_id
      ,p_establishment_id             => p_establishment_id
      ,p_frequency                    => p_frequency
      ,p_internal_address_line        => p_internal_address_line
      ,p_labour_union_member_flag     => p_labour_union_member_flag
      ,p_manager_flag                 => p_manager_flag
      ,p_normal_hours                 => p_normal_hours
      ,p_project_title				  => p_project_title
      ,p_set_of_books_id              => p_set_of_books_id
      ,p_source_type                  => p_source_type
      ,p_supervisor_id                => p_supervisor_id
      ,p_time_normal_finish           => p_time_normal_finish
      ,p_time_normal_start            => p_time_normal_start
      ,p_title                        => p_title
      ,p_vendor_assignment_number     => p_vendor_assignment_number
      ,p_vendor_employee_number       => p_vendor_employee_number
      ,p_vendor_id                    => l_vendor_id
      ,p_vendor_site_id               => p_vendor_site_id
      ,p_po_header_id                 => l_po_header_id
      ,p_po_line_id                   => p_po_line_id
      ,p_projected_assignment_end     => l_projected_assignment_end
      ,p_assignment_status_type_id    => p_assignment_status_type_id
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
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30
      ,p_scl_segment1                 => p_scl_segment1
      ,p_scl_segment2                 => p_scl_segment2
      ,p_scl_segment3                 => p_scl_segment3
      ,p_scl_segment4                 => p_scl_segment4
      ,p_scl_segment5                 => p_scl_segment5
      ,p_scl_segment6                 => p_scl_segment6
      ,p_scl_segment7                 => p_scl_segment7
      ,p_scl_segment8                 => p_scl_segment8
      ,p_scl_segment9                 => p_scl_segment9
      ,p_scl_segment10                => p_scl_segment10
      ,p_scl_segment11                => p_scl_segment11
      ,p_scl_segment12                => p_scl_segment12
      ,p_scl_segment13                => p_scl_segment13
      ,p_scl_segment14                => p_scl_segment14
      ,p_scl_segment15                => p_scl_segment15
      ,p_scl_segment16                => p_scl_segment16
      ,p_scl_segment17                => p_scl_segment17
      ,p_scl_segment18                => p_scl_segment18
      ,p_scl_segment19                => p_scl_segment19
      ,p_scl_segment20                => p_scl_segment20
      ,p_scl_segment21                => p_scl_segment21
      ,p_scl_segment22                => p_scl_segment22
      ,p_scl_segment23                => p_scl_segment23
      ,p_scl_segment24                => p_scl_segment24
      ,p_scl_segment25                => p_scl_segment25
      ,p_scl_segment26                => p_scl_segment26
      ,p_scl_segment27                => p_scl_segment27
      ,p_scl_segment28                => p_scl_segment28
      ,p_scl_segment29                => p_scl_segment29
      ,p_scl_segment30                => p_scl_segment30
      ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_comment_id                   => l_comment_id
      ,p_no_managers_warning          => l_no_managers_warning
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_hourly_salaried_warning      => l_hourly_salaried_warning
      ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
	  --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CWK_ASG'
        ,p_hook_type   => 'AP'
        );
      --
      -- End of API User Hook for the after hook of update_cwk_asg
      --
  END;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
	--
  END IF;
  --
  -- Set all output arguments
  --
  p_object_version_number   := l_object_version_number;
  p_soft_coding_keyflex_id  := l_soft_coding_keyflex_id;
  p_comment_id              := l_comment_id;
  p_effective_start_date    := l_effective_start_date;
  p_effective_end_date      := l_effective_end_date;
  p_concatenated_segments   := l_concatenated_segments;
  p_no_managers_warning     := l_no_managers_warning;
  p_other_manager_warning   := l_other_manager_warning;
  p_hourly_salaried_warning := l_hourly_salaried_warning;
  --
  -- remove data from the session table
  --
  hr_kflex_utility.unset_session_date
    (p_session_id     => l_session_id);
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 999);
 end if;
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_cwk_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number      := p_object_version_number;
    p_soft_coding_keyflex_id     := null;
    p_comment_id                 := null;
    p_effective_start_date       := null;
    p_effective_end_date         := null;
    p_concatenated_segments      := l_old_conc_segments;
    p_no_managers_warning        := l_no_managers_warning;
    p_other_manager_warning      := l_other_manager_warning;
    p_hourly_salaried_warning    := l_hourly_salaried_warning;
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number := lv_object_version_number;

    p_org_now_no_manager_warning      := null;
    p_effective_start_date            := null;
    p_effective_end_date              := null;
    p_comment_id                      := null;
    p_no_managers_warning             := null;
    p_other_manager_warning           := null;
    p_soft_coding_keyflex_id          := null;
    p_concatenated_segments           := null;
    p_hourly_salaried_warning         := null;

    ROLLBACK TO update_cwk_asg;
    RAISE;
    --
    -- End of fix.
    --
END update_cwk_asg;
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_cwk_asg_criteria >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cwk_asg_criteria
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_called_from_mass_update      in     boolean
  ,p_object_version_number        in out nocopy number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  --
  -- p_payroll_id included for future phases of cwk
  --
  --,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_organization_id              in     number
  --
  -- p_pay_basis_id for future phases of cwk
  --
  ,p_pay_basis_id                 in     number
  ,p_segment1                     in     varchar2
  ,p_segment2                     in     varchar2
  ,p_segment3                     in     varchar2
  ,p_segment4                     in     varchar2
  ,p_segment5                     in     varchar2
  ,p_segment6                     in     varchar2
  ,p_segment7                     in     varchar2
  ,p_segment8                     in     varchar2
  ,p_segment9                     in     varchar2
  ,p_segment10                    in     varchar2
  ,p_segment11                    in     varchar2
  ,p_segment12                    in     varchar2
  ,p_segment13                    in     varchar2
  ,p_segment14                    in     varchar2
  ,p_segment15                    in     varchar2
  ,p_segment16                    in     varchar2
  ,p_segment17                    in     varchar2
  ,p_segment18                    in     varchar2
  ,p_segment19                    in     varchar2
  ,p_segment20                    in     varchar2
  ,p_segment21                    in     varchar2
  ,p_segment22                    in     varchar2
  ,p_segment23                    in     varchar2
  ,p_segment24                    in     varchar2
  ,p_segment25                    in     varchar2
  ,p_segment26                    in     varchar2
  ,p_segment27                    in     varchar2
  ,p_segment28                    in     varchar2
  ,p_segment29                    in     varchar2
  ,p_segment30                    in     varchar2
  ,p_concat_segments              in     varchar2
  ,p_people_group_name               out nocopy varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_people_group_id                 out nocopy number
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_spp_delete_warning              out nocopy boolean
  --
  -- p_entries_changed_warning included for future phases of cwk
  --
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_tax_district_changed_warning    out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_effective_end_date           per_all_assignments_f.effective_end_date%TYPE;
  l_effective_start_date         per_all_assignments_f.effective_start_date%TYPE;
  l_entries_changed_warning      varchar2(1) := 'N';
  l_people_group_name            pay_people_groups.group_name%TYPE;
  l_old_group_name               pay_people_groups.group_name%TYPE;
  l_no_managers_warning          boolean;
  l_object_version_number        per_all_assignments_f.object_version_number%TYPE;
  l_org_now_no_manager_warning   boolean;
  l_other_manager_warning        boolean;
  l_hourly_salaried_warning      boolean;
  l_payroll_id_updated           boolean;
  l_people_group_id              per_all_assignments_f.people_group_id%TYPE;
  l_spp_delete_warning           boolean := false; -- Bug 3545065
  l_tax_district_changed_warning boolean;
  l_flex_num                     fnd_id_flex_segments.id_flex_num%TYPE;
  --
  l_api_updating                 boolean;
  l_business_group_id            per_all_assignments_f.business_group_id%TYPE;
  l_comment_id                   per_all_assignments_f.comment_id%TYPE;
  l_entries_changed              varchar2(1);
  l_legislation_code             per_business_groups.legislation_code%TYPE;
  l_new_payroll_id               per_all_assignments_f.payroll_id%TYPE;
  l_proc                         varchar2(72) :=
                                       g_package || 'update_cwk_asg_criteria';
  l_validation_end_date          date;
  l_validation_start_date        date;
  l_effective_date               date;
  l_element_entry_id             number;
  l_organization_id              per_all_assignments_f.organization_id%type;
  l_location_id                  per_all_assignments_f.location_id%type;
  l_session_id                   number;
  l_assignment_type              per_all_assignments_f.assignment_type%TYPE;
  --
  lv_object_version_number     number := p_object_version_number ;
  l_grade_id                   number := Null; -- Bug 3545065
  --

  cursor csr_get_legislation_code is
    select bus.legislation_code
      from per_business_groups_perf bus
     where bus.business_group_id = l_business_group_id;
  --
  cursor csr_get_salary is
  select element_entry_id
  from   pay_element_entries_f
  where  assignment_id = p_assignment_id
  and    creator_type = 'SP'
  and    l_validation_start_date between
         effective_start_date and effective_end_date;
  --
  cursor csr_grp_idsel is
  select bus.people_group_structure
  from  per_business_groups_perf bus
  where bus.business_group_id = l_business_group_id;
  --
  cursor get_sec_date_range is
  select asg.effective_start_date
  ,      asg.effective_end_date
  from   per_all_assignments_f asg
  where  asg.assignment_id=p_assignment_id
  and   ((sysdate between asg.effective_start_date
          and asg.effective_end_date)
         or
         (sysdate<asg.effective_start_date
          and not exists
          (select 1
           from per_all_assignments_f asg2
           where asg2.person_id=asg.person_id
           and asg2.period_of_service_id=asg.period_of_service_id
           and asg2.effective_start_date<asg.effective_start_date)
         )
        );
  --
  cursor csr_get_assignment_type is
    select asg.assignment_type
      from per_all_assignments_f asg
     where asg.assignment_id = p_assignment_id
       and l_effective_date  between asg.effective_start_date
                             and     asg.effective_end_date;
  --
  l_sec_effective_start_date date;
  l_sec_effective_end_date date;
  --
  l_dt_update_mode     VARCHAR2(30);
  l_new_dt_update_mode VARCHAR2(30);
  --
  -- Start of bug 3553286
  l_job_id                       number := p_job_id;
  l_org_id                       number := p_organization_id;
  -- End of 3553286
BEGIN
  --
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
   IF p_called_from_mass_update THEN
    --
    if g_debug then
      hr_utility.set_location(l_proc,40);
    end if;
    --
    l_dt_update_mode     := 'CORRECTION';
    l_new_dt_update_mode := p_datetrack_update_mode;
    --
  ELSE
    --
    if g_debug then
      hr_utility.set_location(l_proc,50);
    end if;
    --
    l_dt_update_mode     := p_datetrack_update_mode;
    l_new_dt_update_mode := p_datetrack_update_mode;
    --
  END IF;
  --
  -- Truncate the p_effective_date value to remove time element.
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Bug 944911
  -- Made p_group_name to be out param
  -- and add p_concat_segment to be IN
  -- in case of sec_asg alone made p_pgp_concat_segments as in param
  -- Replaced p_group_name by p_concat_segments
  --
  l_old_group_name := p_concat_segments;
  --
  -- Issue a savepoint.
  --
  SAVEPOINT update_cwk_asg_criteria;
  --
  -- Check assignment is a cwk assignment
  --
  OPEN  csr_get_assignment_type;
  FETCH csr_get_assignment_type INTO l_assignment_type;
  --
  IF csr_get_assignment_type%NOTFOUND THEN
    --
    CLOSE csr_get_assignment_type;
	--
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
	--
  END IF;
  --
  CLOSE csr_get_assignment_type;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  IF l_assignment_type <> 'C' THEN
    --
	hr_utility.set_message(801,'HR_289575_ASG_ASG_NOT_EMP');
    hr_utility.raise_error;
	--
  END IF;
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of update_emp_asg_criteria
    --
    hr_assignment_bko.update_cwk_asg_criteria_b
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => l_dt_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_grade_id                     => l_grade_id -- Bug 3545065
      ,p_position_id                  => p_position_id
      ,p_job_id                       => p_job_id
      --,p_payroll_id                   => p_payroll_id
      ,p_location_id                  => p_location_id
      ,p_organization_id              => p_organization_id
      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_segment1                     => p_segment1
      ,p_segment2                     => p_segment2
      ,p_segment3                     => p_segment3
      ,p_segment4                     => p_segment4
      ,p_segment5                     => p_segment5
      ,p_segment6                     => p_segment6
      ,p_segment7                     => p_segment7
      ,p_segment8                     => p_segment8
      ,p_segment9                     => p_segment9
      ,p_segment10                    => p_segment10
      ,p_segment11                    => p_segment11
      ,p_segment12                    => p_segment12
      ,p_segment13                    => p_segment13
      ,p_segment14                    => p_segment14
      ,p_segment15                    => p_segment15
      ,p_segment16                    => p_segment16
      ,p_segment17                    => p_segment17
      ,p_segment18                    => p_segment18
      ,p_segment19                    => p_segment19
      ,p_segment20                    => p_segment20
      ,p_segment21                    => p_segment21
      ,p_segment22                    => p_segment22
      ,p_segment23                    => p_segment23
      ,p_segment24                    => p_segment24
      ,p_segment25                    => p_segment25
      ,p_segment26                    => p_segment26
      ,p_segment27                    => p_segment27
      ,p_segment28                    => p_segment28
      ,p_segment29                    => p_segment29
      ,p_segment30                    => p_segment30
      ,p_concat_segments              => l_old_group_name);
  --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
	  --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CWK_ASG_CRITERIA'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_emp_cwk_criteria
    --
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  l_object_version_number := p_object_version_number;
  --
  -- Validation in addition to Table Handlers
  --
  -- Retrieve current assignment details from database.
  --
  l_api_updating := per_asg_shd.api_updating
    (p_assignment_id         => p_assignment_id
    ,p_effective_date        => l_effective_date
    ,p_object_version_number => l_object_version_number);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  IF NOT l_api_updating THEN
    --
 if g_debug then
    hr_utility.set_location(l_proc, 30);
 end if;
    --
    -- As this is an updating API, the assignment should already exist.
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
	--
  ELSE
    --
 if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    l_people_group_id := per_asg_shd.g_old_rec.people_group_id;
	--
  END IF;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 50);
 end if;
  --
  -- Check that the assignment is an employee assignment.
  --
  IF per_asg_shd.g_old_rec.assignment_type <> 'C' THEN
    --
 if g_debug then
    hr_utility.set_location(l_proc, 60);
 end if;
    --
	hr_utility.set_message(801, 'HR_289575_ASG_ASG_NOT_EMP');
    hr_utility.raise_error;
	--
  END IF;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 70);
 end if;
  --
  -- Process Logic
  --
  -- Populate l_business_group_id from g_old_rec for cursor csr_grp_idsel
  --
  l_business_group_id := per_asg_shd.g_old_rec.business_group_id;
  --
  -- Start of bug fix 3553286
  -- This procedure will return the job_id and organization_id of a position
  --
  if (p_called_from_mass_update = TRUE and p_position_id is not null) then
     if (l_job_id is null) or (l_org_id is null) then
         hr_psf_shd.get_position_job_org(p_position_id, p_effective_date,
                                         l_job_id, l_org_id);
     end if;
  end if;
  -- End of 3553286
  -- insert the profile options and effective date for the flexfield
  -- validation to work
  --
  --
  IF (l_org_id = hr_api.g_number) THEN -- Bug 3553286
    --
    l_organization_id:=per_asg_shd.g_old_rec.organization_id;
    --
  ELSE
    --
    l_organization_id := l_org_id; -- Bug 3553286
	--
  END IF;
  --
  IF (p_location_id=hr_api.g_number) THEN
    --
    l_location_id:=per_asg_shd.g_old_rec.location_id;
	--
  ELSE
    --
    l_location_id:=p_location_id;
	--
  END IF;
  --
  hr_kflex_utility.set_profiles
    (p_business_group_id => l_business_group_id
    ,p_assignment_id     => p_assignment_id
    ,p_organization_id   => l_organization_id
    ,p_location_id       => l_location_id);
  --
  hr_kflex_utility.set_session_date
    (p_effective_date => l_effective_date
    ,p_session_id     => l_session_id);
  --
  OPEN csr_grp_idsel;
  FETCH csr_grp_idsel INTO l_flex_num;
  --
  IF csr_grp_idsel%NOTFOUND THEN
    --
    CLOSE csr_grp_idsel;
	--
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
	--
  END IF;
  --
  CLOSE csr_grp_idsel;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 120);
 end if;
  --
  -- Maintain the people group key flexfields.
  --
  -- Only call the flex code if a non-default value(includng null) is passed
  -- to the procedure.
  --
  if     nvl(p_segment1,'X')  <> hr_api.g_varchar2
      or nvl(p_segment2,'X')  <> hr_api.g_varchar2
      or nvl(p_segment3,'X')  <> hr_api.g_varchar2
      or nvl(p_segment4,'X')  <> hr_api.g_varchar2
      or nvl(p_segment5,'X')  <> hr_api.g_varchar2
      or nvl(p_segment6,'X')  <> hr_api.g_varchar2
      or nvl(p_segment7,'X')  <> hr_api.g_varchar2
      or nvl(p_segment8,'X')  <> hr_api.g_varchar2
      or nvl(p_segment9,'X')  <> hr_api.g_varchar2
      or nvl(p_segment10,'X') <> hr_api.g_varchar2
      or nvl(p_segment11,'X') <> hr_api.g_varchar2
      or nvl(p_segment12,'X') <> hr_api.g_varchar2
      or nvl(p_segment13,'X') <> hr_api.g_varchar2
      or nvl(p_segment14,'X') <> hr_api.g_varchar2
      or nvl(p_segment15,'X') <> hr_api.g_varchar2
      or nvl(p_segment16,'X') <> hr_api.g_varchar2
      or nvl(p_segment17,'X') <> hr_api.g_varchar2
      or nvl(p_segment18,'X') <> hr_api.g_varchar2
      or nvl(p_segment19,'X') <> hr_api.g_varchar2
      or nvl(p_segment20,'X') <> hr_api.g_varchar2
      or nvl(p_segment21,'X') <> hr_api.g_varchar2
      or nvl(p_segment22,'X') <> hr_api.g_varchar2
      or nvl(p_segment23,'X') <> hr_api.g_varchar2
      or nvl(p_segment24,'X') <> hr_api.g_varchar2
      or nvl(p_segment25,'X') <> hr_api.g_varchar2
      or nvl(p_segment26,'X') <> hr_api.g_varchar2
      or nvl(p_segment27,'X') <> hr_api.g_varchar2
      or nvl(p_segment28,'X') <> hr_api.g_varchar2
      or nvl(p_segment29,'X') <> hr_api.g_varchar2
      or nvl(p_segment30,'X') <> hr_api.g_varchar2
      or nvl(l_old_group_name,'X') <> hr_api.g_varchar2 THEN
    --
    hr_kflex_utility.upd_or_sel_keyflex_comb
    (p_appl_short_name        => 'PAY'
    ,p_flex_code              => 'GRP'
    ,p_flex_num               => l_flex_num
    ,p_segment1               => p_segment1
    ,p_segment2               => p_segment2
    ,p_segment3               => p_segment3
    ,p_segment4               => p_segment4
    ,p_segment5               => p_segment5
    ,p_segment6               => p_segment6
    ,p_segment7               => p_segment7
    ,p_segment8               => p_segment8
    ,p_segment9               => p_segment9
    ,p_segment10              => p_segment10
    ,p_segment11              => p_segment11
    ,p_segment12              => p_segment12
    ,p_segment13              => p_segment13
    ,p_segment14              => p_segment14
    ,p_segment15              => p_segment15
    ,p_segment16              => p_segment16
    ,p_segment17              => p_segment17
    ,p_segment18              => p_segment18
    ,p_segment19              => p_segment19
    ,p_segment20              => p_segment20
    ,p_segment21              => p_segment21
    ,p_segment22              => p_segment22
    ,p_segment23              => p_segment23
    ,p_segment24              => p_segment24
    ,p_segment25              => p_segment25
    ,p_segment26              => p_segment26
    ,p_segment27              => p_segment27
    ,p_segment28              => p_segment28
    ,p_segment29              => p_segment29
    ,p_segment30              => p_segment30
    ,p_concat_segments_in     => l_old_group_name
    ,p_ccid                   => l_people_group_id
    ,p_concat_segments_out    => l_people_group_name);
	--
  END IF;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 130);
 end if;
  --
  -- update the combinations column
  --
  update_pgp_concat_segs
    (p_people_group_id        => l_people_group_id
    ,p_group_name             => l_people_group_name);
  --
  -- Update assignment.
  --
  per_asg_upd.upd
    (p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => l_business_group_id
    -- Bug 3545065, Grade should not be maintained for CWK asg
    -- ,p_grade_id                     => p_grade_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => l_job_id -- Bug 3553286
	--
	-- Removed until used in a later phase of cwk
	--
    --,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_organization_id              => l_org_id -- Bug 3553286
    ,p_people_group_id              => l_people_group_id
	--
	-- Removed until used in a later phase of cwk
	--
    --,p_pay_basis_id                 => p_pay_basis_id
    ,p_comment_id                   => l_comment_id
    ,p_payroll_id_updated           => l_payroll_id_updated
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_no_managers_warning          => l_no_managers_warning
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_validation_start_date        => l_validation_start_date
    ,p_validation_end_date          => l_validation_end_date
    ,p_object_version_number        => l_object_version_number
    ,p_effective_date               => l_effective_date
    ,p_datetrack_mode               => l_dt_update_mode
    ,p_validate                     => FALSE
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 140);
 end if;
  --
  -- add to the security lists if neccesary
  --
  OPEN get_sec_date_range;
  FETCH get_sec_date_range INTO l_sec_effective_start_date
                               ,l_sec_effective_end_date;
  CLOSE get_sec_date_range;
  --
  IF l_effective_date BETWEEN l_sec_effective_start_date AND
                              l_sec_effective_end_date THEN
    --
    IF (per_asg_shd.g_old_rec.organization_id = l_business_group_id AND
      l_org_id <> l_business_group_id) THEN -- Bug 3553286
      --
      hr_security_internal.clear_from_person_list
                            (per_asg_shd.g_old_rec.person_id);
      --
    END IF;
	--
    hr_security_internal.add_to_person_list(l_effective_date,p_assignment_id);
	--
  END IF;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 145);
 end if;
  --
  -- Bug 560185 fix starts
  --
  -- Delete the SP element entry if there is one when the pay_basis
  -- changes
  --
  --
  --Pay Basis functionality is not included in the 1st phase
  --of non payrolled worker. As a result this code has been commented
  --out, but left in as it is likely to form part of a later phase
  --
  /*
  IF (p_pay_basis_id <> hr_api.g_number or
      p_pay_basis_id is null ) and
     (nvl(p_pay_basis_id,hr_api.g_number) <>
      nvl(per_asg_shd.g_old_rec.pay_basis_id, hr_api.g_number))
  then
    open csr_get_salary;
    fetch csr_get_salary into l_element_entry_id;
    if csr_get_salary%found then
      close csr_get_salary;
      --
      hr_entry_api.delete_element_entry
        ('DELETE'
        ,l_validation_start_date - 1
        ,l_element_entry_id);
      --
      l_entries_changed_warning := 'S';
    else
       close csr_get_salary;
    end if;
  end if;
  */
  --
  -- Maintain standard element entries for this assignment.
  --
  -- Payroll functionality is not included in the 1st phase
  -- of non payrolled worker. As a result this code has been commented
  -- out, but left in as it is likely to form part of a later phase
  --
  /*
  if p_payroll_id = hr_api.g_number
   then
     --
 if g_debug then
     hr_utility.set_location(l_proc, 150);
 end if;
     --
     l_new_payroll_id := per_asg_shd.g_old_rec.payroll_id;
  else
     --
 if g_debug then
     hr_utility.set_location(l_proc, 160);
 end if;
     --
     l_new_payroll_id := p_payroll_id;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 170);
 end if;
  --
  hrentmnt.maintain_entries_asg
    (p_assignment_id                => p_assignment_id
    ,p_old_payroll_id               => per_asg_shd.g_old_rec.payroll_id
    ,p_new_payroll_id               => l_new_payroll_id
    ,p_business_group_id            => l_business_group_id
    ,p_operation                    => 'ASG_CRITERIA'
    ,p_actual_term_date             => null
    ,p_last_standard_date           => null
    ,p_final_process_date           => null
    ,p_dt_mode                      => p_datetrack_update_mode
    ,p_validation_start_date        => l_validation_start_date
    ,p_validation_end_date          => l_validation_end_date
    ,p_entries_changed              => l_entries_changed
    );
  --
  -- Bug 630826 fix ends
  --
 if g_debug then
  hr_utility.set_location(l_proc, 180);
 end if;
  --
  if l_entries_changed_warning <> 'S' then
    l_entries_changed_warning := nvl(l_entries_changed, 'N');
  end if;
  */
  --
  -- Bug 3545065, Grade should not be maintained for CWK asg
  /*
  IF (per_asg_shd.g_old_rec.grade_id IS NOT NULL AND
      p_grade_id IS NULL) OR
	 (per_asg_shd.g_old_rec.grade_id IS NOT NULL AND
	  p_grade_id IS NOT NULL AND
	  per_asg_shd.g_old_rec.grade_id <> p_grade_id AND
	  p_grade_id <> hr_api.g_number) THEN
    --
 if g_debug then
    hr_utility.set_location(l_proc, 190);
 end if;
    --
    -- Maintain spinal point placements.
    --
    hr_assignment_internal.maintain_spp_asg
      (p_assignment_id                => p_assignment_id
      ,p_datetrack_mode               => l_new_dt_update_mode
      ,p_validation_start_date        => l_validation_start_date
      ,p_validation_end_date          => l_validation_end_date
      ,p_grade_id		              => p_grade_id
      ,p_spp_delete_warning           => l_spp_delete_warning);
    --
  ELSE
    --
 if g_debug then
    hr_utility.set_location(l_proc, 200);
 end if;
    --
    -- No SPPs to maintain.
    --
    l_spp_delete_warning := FALSE;
	--
  END IF;
  --
  */
  -- End of bug 3545065
  --
 if g_debug then
  hr_utility.set_location(l_proc, 210);
 end if;
  --
  -- IF GB legislation and payroll has changed, then delete latest balance
  -- values,
  --
  OPEN  csr_get_legislation_code;
  FETCH csr_get_legislation_code INTO l_legislation_code;
  --
  IF csr_get_legislation_code%NOTFOUND THEN
    --
    CLOSE csr_get_legislation_code;
    --
 if g_debug then
    hr_utility.set_location(l_proc, 220);
 end if;
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '215');
    hr_utility.raise_error;
	--
  END IF;
  --
  CLOSE csr_get_legislation_code;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 230);
 end if;
  --
  IF  l_legislation_code = 'GB' AND l_payroll_id_updated THEN
    --
 if g_debug then
    hr_utility.set_location(l_proc, 240);
 end if;
    --
    -- Delete latest balance values.
    --
    py_gb_asg.payroll_transfer
      (p_assignment_id => p_assignment_id);
    --
    -- When GB legislation, and the business group and the payroll has changed,
    -- set the Print P45 flag on the assignments extra info flexfield, and set
    -- the changed tax district warning out parameter.
    -- This functionality will be supported at a later date.
    --
    l_tax_district_changed_warning := FALSE;
	--
  ELSE
    --
 if g_debug then
    hr_utility.set_location(l_proc, 250);
 end if;
    --
    l_tax_district_changed_warning := FALSE;
	--
  END IF;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 260);
 end if;
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of update_emp_asg_criteria
    --
    hr_assignment_bko.update_cwk_asg_criteria_a
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => l_dt_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_grade_id                     => p_grade_id -- Bug 3545065
      ,p_position_id                  => p_position_id
      ,p_job_id                       => l_job_id -- Bug 3553286
      --,p_payroll_id                   => p_payroll_id
      ,p_location_id                  => p_location_id
      ,p_organization_id              => l_org_id -- Bug 3553286
      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_segment1                     => p_segment1
      ,p_segment2                     => p_segment2
      ,p_segment3                     => p_segment3
      ,p_segment4                     => p_segment4
      ,p_segment5                     => p_segment5
      ,p_segment6                     => p_segment6
      ,p_segment7                     => p_segment7
      ,p_segment8                     => p_segment8
      ,p_segment9                     => p_segment9
      ,p_segment10                    => p_segment10
      ,p_segment11                    => p_segment11
      ,p_segment12                    => p_segment12
      ,p_segment13                    => p_segment13
      ,p_segment14                    => p_segment14
      ,p_segment15                    => p_segment15
      ,p_segment16                    => p_segment16
      ,p_segment17                    => p_segment17
      ,p_segment18                    => p_segment18
      ,p_segment19                    => p_segment19
      ,p_segment20                    => p_segment20
      ,p_segment21                    => p_segment21
      ,p_segment22                    => p_segment22
      ,p_segment23                    => p_segment23
      ,p_segment24                    => p_segment24
      ,p_segment25                    => p_segment25
      ,p_segment26                    => p_segment26
      ,p_segment27                    => p_segment27
      ,p_segment28                    => p_segment28
      ,p_segment29                    => p_segment29
      ,p_segment30                    => p_segment30
      ,p_people_group_name            => l_people_group_name
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_people_group_id              => l_people_group_id
      ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_spp_delete_warning           => l_spp_delete_warning
      ,p_entries_changed_warning      => l_entries_changed_warning
      ,p_tax_district_changed_warning => l_tax_district_changed_warning
      ,p_concat_segments              => l_old_group_name);
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
	  --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CWK_ASG_CRITERIA'
        ,p_hook_type   => 'AP');
      --
      -- End of API User Hook for the after hook of update_emp_asg_criteria
      --
  END;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
	--
  END IF;
  --
  -- Set all output arguments
  --
  p_effective_end_date           := l_effective_end_date;
  p_effective_start_date         := l_effective_start_date;
  p_people_group_id              := l_people_group_id;
  p_people_group_name            := l_people_group_name;
  p_entries_changed_warning      := l_entries_changed_warning;
  p_object_version_number        := l_object_version_number;
  p_org_now_no_manager_warning   := l_org_now_no_manager_warning;
  p_other_manager_warning        := l_other_manager_warning;
  p_spp_delete_warning           := l_spp_delete_warning;
  p_tax_district_changed_warning := l_tax_district_changed_warning;
  --
  --
  -- remove data from the session table
  --
  hr_kflex_utility.unset_session_date
    (p_session_id     => l_session_id);
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 999);
 end if;
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_cwk_asg_criteria;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_end_date           := NULL;
    p_effective_start_date         := NULL;
    p_entries_changed_warning      := l_entries_changed_warning;
    p_people_group_name                   := l_old_group_name;
    p_object_version_number        := p_object_version_number;
    p_org_now_no_manager_warning   := l_org_now_no_manager_warning;
    p_other_manager_warning        := l_other_manager_warning;
    p_people_group_id              := NULL;
    p_spp_delete_warning           := l_spp_delete_warning;
    p_tax_district_changed_warning := l_tax_district_changed_warning;
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number := lv_object_version_number;

    ROLLBACK TO update_cwk_asg_criteria;
    RAISE;
    --
    -- End of fix.
    --
END update_cwk_asg_criteria;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_gb_emp_asg >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_gb_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72);
  l_effective_date             date;
  l_soft_coding_keyflex_id     per_all_assignments_f.soft_coding_keyflex_id%TYPE;
  l_concatenated_segments      varchar2(2000);
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_cagr_concatenated_segments varchar2(300);
  l_cagr_grade_def_id	       number;
  --
  --
begin
 if g_debug then
  l_proc := g_package||'update_gb_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Call the overloaded procedure
  --
  hr_assignment_api.update_gb_emp_asg
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_supervisor_id                => p_supervisor_id
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_title                        => p_title
    ,p_cagr_grade_def_id 	    => l_cagr_grade_def_id
    ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_comment_id                   => p_comment_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_concatenated_segments        => l_concatenated_segments
    ,p_no_managers_warning          => p_no_managers_warning
    ,p_other_manager_warning        => p_other_manager_warning
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 20);
 end if;
end update_gb_emp_asg;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_gb_emp_asg >------ OVERLOADED ---------|
-- ----------------------------------------------------------------------------
--
-- added new parameters notice_period, units, employee_category,
-- work_at_home and job_source on 05-OCT-01

procedure update_gb_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_collective_agreement_id      in     number
  ,p_cagr_id_flex_num             in     number
  ,p_notice_period		  in     number
  ,p_notice_period_uom	      	  in     varchar2
  ,p_employee_category	          in     varchar2
  ,p_work_at_home		  in     varchar2
  ,p_job_post_source_name	  in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72);
  l_effective_date             date;
  l_soft_coding_keyflex_id     per_all_assignments_f.soft_coding_keyflex_id%TYPE;
  l_concatenated_segments      varchar2(2000);
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  --
  cursor check_legislation
    (c_assignment_id  per_all_assignments_f.assignment_id%TYPE,
     c_effective_date date
    )
  is
    select bgp.legislation_code
    from per_all_assignments_f asg,
         per_business_groups_perf bgp
    where asg.business_group_id = bgp.business_group_id
    and   asg.assignment_id     = c_assignment_id
    and   c_effective_date
      between effective_start_date and effective_end_date;
  --
begin
 if g_debug then
  l_proc := g_package||'update_gb_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Truncate date variables
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validate in addition to Table Handlers
  --
  -- Check that the assignment exists.
  --
  open check_legislation(p_assignment_id, l_effective_date);
  fetch check_legislation into l_legislation_code;
  if check_legislation%notfound then
    close check_legislation;
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close check_legislation;
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Call update_emp_asg business process
  --
  hr_assignment_api.update_emp_asg
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_supervisor_id                => p_supervisor_id
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_notice_period		    => p_notice_period
    ,p_notice_period_uom	    => p_notice_period_uom
    ,p_employee_category	    => p_employee_category
    ,p_work_at_home		    => p_work_at_home
    ,p_job_post_source_name	    => p_job_post_source_name
    ,p_title                        => p_title
    ,p_contract_id		    => p_contract_id
    ,p_establishment_id		    => p_establishment_id
    ,p_collective_agreement_id	    => p_collective_agreement_id
    ,p_cagr_id_flex_num		    => p_cagr_id_flex_num
    ,p_cagr_grade_def_id	    => p_cagr_grade_def_id
    ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_comment_id                   => p_comment_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_concatenated_segments        => l_concatenated_segments
    ,p_no_managers_warning          => p_no_managers_warning
    ,p_other_manager_warning        => p_other_manager_warning
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end if;
end update_gb_emp_asg;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_gb_emp_asg >------ OVERLOADED ---------|
-- ----------------------------------------------------------------------------
--
-- added new OUT parameter p_hourly_salaried_warning


procedure update_gb_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_collective_agreement_id      in     number
  ,p_cagr_id_flex_num             in     number
  ,p_notice_period		  in     number
  ,p_notice_period_uom	      	  in     varchar2
  ,p_employee_category	          in     varchar2
  ,p_work_at_home		  in     varchar2
  ,p_job_post_source_name	  in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72);
  l_effective_date             date;
  l_soft_coding_keyflex_id     per_all_assignments_f.soft_coding_keyflex_id%TYPE;
  l_concatenated_segments      varchar2(2000);
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  --
  cursor check_legislation
    (c_assignment_id  per_all_assignments_f.assignment_id%TYPE,
     c_effective_date date
    )
  is
    select bgp.legislation_code
    from per_all_assignments_f asg,
         per_business_groups_perf bgp
    where asg.business_group_id = bgp.business_group_id
    and   asg.assignment_id     = c_assignment_id
    and   c_effective_date
      between effective_start_date and effective_end_date;
  --
begin
 if g_debug then
  l_proc := g_package||'update_gb_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Truncate date variables
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validate in addition to Table Handlers
  --
  -- Check that the assignment exists.
  --
  open check_legislation(p_assignment_id, l_effective_date);
  fetch check_legislation into l_legislation_code;
  if check_legislation%notfound then
    close check_legislation;
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close check_legislation;
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Call update_emp_asg business process
  --
  hr_assignment_api.update_emp_asg
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_supervisor_id                => p_supervisor_id
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_notice_period		    => p_notice_period
    ,p_notice_period_uom	    => p_notice_period_uom
    ,p_employee_category	    => p_employee_category
    ,p_work_at_home		    => p_work_at_home
    ,p_job_post_source_name	    => p_job_post_source_name
    ,p_title                        => p_title
    ,p_contract_id		    => p_contract_id
    ,p_establishment_id		    => p_establishment_id
    ,p_collective_agreement_id	    => p_collective_agreement_id
    ,p_cagr_id_flex_num		    => p_cagr_id_flex_num
    ,p_cagr_grade_def_id	    => p_cagr_grade_def_id
    ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_comment_id                   => p_comment_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_concatenated_segments        => l_concatenated_segments
    ,p_no_managers_warning          => p_no_managers_warning
    ,p_other_manager_warning        => p_other_manager_warning
    ,p_hourly_salaried_warning      => p_hourly_salaried_warning
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end if;
end update_gb_emp_asg;

-- End of OVERLOADED procedure update_gb_emp_asg
-- ----------------------------------------------------------------------------
-- |--------------------------< update_us_emp_asg -- OLD >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_us_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_tax_unit                     in     varchar2
  ,p_timecard_approver            in     varchar2
  ,p_timecard_required            in     varchar2
  ,p_work_schedule                in     varchar2
  ,p_shift                        in     varchar2
  ,p_spouse_salary                in     varchar2
  ,p_legal_representative         in     varchar2
  ,p_wc_override_code             in     varchar2
  ,p_eeo_1_establishment          in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_comment_id                      out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
-- Bug 944911
-- Amended p_concatenated_segments to be out
-- Added p_concat_segments  - in param
  ,p_concatenated_segments           out nocopy varchar2
  ,p_concat_segments              in     varchar2
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72);
  l_effective_date             date;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_cagr_grade_def_id	       number;
  l_cagr_concatenated_segments number;

  --
begin
 if g_debug then
  l_proc := g_package||'update_us_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Call the overloaded procedure update_us_emp_asg
  --
  hr_assignment_api.update_emp_asg
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_supervisor_id                => p_supervisor_id
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_title                        => p_title
    ,p_segment1                     => p_tax_unit
    ,p_segment2                     => p_timecard_approver
    ,p_segment3                     => p_timecard_required
    ,p_segment4                     => p_work_schedule
    ,p_segment5                     => p_shift
    ,p_segment6                     => p_spouse_salary
    ,p_segment7                     => p_legal_representative
    ,p_segment8                     => p_wc_override_code
    ,p_segment9                     => p_eeo_1_establishment
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_comment_id                   => p_comment_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    -- Bug 1889914
    ,p_cagr_grade_def_id	    => l_cagr_grade_def_id
    ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
-- Bug 944911
-- Added new param
    ,p_concatenated_segments        => p_concatenated_segments
    ,p_concat_segments              => p_concat_segments
    ,p_no_managers_warning          => p_no_managers_warning
    ,p_other_manager_warning        => p_other_manager_warning
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end if;
end update_us_emp_asg;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_us_emp_asg --NEW>----------------------|
-- ----------------------------------------------------------------------------
--
-- added new parameters notice_period, units, employee_category,
-- work_at_home and job_source on 05-OCT-01

procedure update_us_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_tax_unit                     in     varchar2
  ,p_timecard_approver            in     varchar2
  ,p_timecard_required            in     varchar2
  ,p_work_schedule                in     varchar2
  ,p_shift                        in     varchar2
  ,p_spouse_salary                in     varchar2
  ,p_legal_representative         in     varchar2
  ,p_wc_override_code             in     varchar2
  ,p_eeo_1_establishment          in     varchar2
  -- Added for bug 1889914
  ,p_contract_id		  in     number
  ,p_establishment_id		  in 	 number
  ,p_collective_agreement_id	  in     number
  ,p_cagr_id_flex_num		  in     number
  ,p_notice_period		  in     number
  ,p_notice_period_uom	      	  in     varchar2
  ,p_employee_category	          in     varchar2
  ,p_work_at_home		  in     varchar2
  ,p_job_post_source_name	  in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_cagr_grade_def_id		     out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  -- End 1889914
  ,p_comment_id                      out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
-- Bug 944911
-- Amended p_concatenated_segments to be out
-- Added p_concat_segments  - in param
  ,p_concatenated_segments           out nocopy varchar2
  ,p_concat_segments              in     varchar2
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72);
  l_effective_date             date;
  l_legislation_code           per_business_groups.legislation_code%TYPE;

  --
  cursor check_legislation
    (c_assignment_id  per_all_assignments_f.assignment_id%TYPE,
     c_effective_date date
    )
  is
    select bgp.legislation_code
    from per_all_assignments_f asg,
         per_business_groups_perf bgp
    where asg.business_group_id = bgp.business_group_id
    and   asg.assignment_id     = c_assignment_id
    and   c_effective_date
      between effective_start_date and effective_end_date;
  --
begin
 if g_debug then
  l_proc := g_package||'update_us_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Truncate date variables
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validate in addition to Table Handlers
  --
  -- Check that the assignment exists.
  --
  open check_legislation(p_assignment_id, l_effective_date);
  fetch check_legislation into l_legislation_code;
  if check_legislation%notfound then
    close check_legislation;
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close check_legislation;
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Check that the legislation of the specified business group is 'US'.
  --
  if l_legislation_code <> 'US' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','US');
    hr_utility.raise_error;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Call update_emp_asg business process
  --
  hr_assignment_api.update_emp_asg
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_supervisor_id                => p_supervisor_id
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_title                        => p_title
    ,p_contract_id		    => p_contract_id
    ,p_establishment_id		    => p_establishment_id
    ,p_collective_agreement_id	    => p_collective_agreement_id
    ,p_cagr_id_flex_num		    => p_cagr_id_flex_num
    ,p_notice_period		    => p_notice_period
    ,p_notice_period_uom	    => p_notice_period_uom
    ,p_employee_category	    => p_employee_category
    ,p_work_at_home		    => p_work_at_home
    ,p_job_post_source_name	    => p_job_post_source_name
    ,p_segment1                     => p_tax_unit
    ,p_segment2                     => p_timecard_approver
    ,p_segment3                     => p_timecard_required
    ,p_segment4                     => p_work_schedule
    ,p_segment5                     => p_shift
    ,p_segment6                     => p_spouse_salary
    ,p_segment7                     => p_legal_representative
    ,p_segment8                     => p_wc_override_code
    ,p_segment9                     => p_eeo_1_establishment
    ,p_cagr_grade_def_id	    => p_cagr_grade_def_id
    ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_comment_id                   => p_comment_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
-- Bug 944911
-- Added new param
    ,p_concatenated_segments        => p_concatenated_segments
    ,p_concat_segments              => p_concat_segments
    ,p_no_managers_warning          => p_no_managers_warning
    ,p_other_manager_warning        => p_other_manager_warning
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end if;
end update_us_emp_asg;
-- End of update_us_emp_asg OVERLOADED procedure

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_us_emp_asg --NEW2 >--------------------|
-- ----------------------------------------------------------------------------
--
-- added new parameters p_hourly_salaried_warning


procedure update_us_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_tax_unit                     in     varchar2
  ,p_timecard_approver            in     varchar2
  ,p_timecard_required            in     varchar2
  ,p_work_schedule                in     varchar2
  ,p_shift                        in     varchar2
  ,p_spouse_salary                in     varchar2
  ,p_legal_representative         in     varchar2
  ,p_wc_override_code             in     varchar2
  ,p_eeo_1_establishment          in     varchar2
  -- Added for bug 1889914
  ,p_contract_id		  in     number
  ,p_establishment_id		  in 	 number
  ,p_collective_agreement_id	  in     number
  ,p_cagr_id_flex_num		  in     number
  ,p_notice_period		  in     number
  ,p_notice_period_uom	      	  in     varchar2
  ,p_employee_category	          in     varchar2
  ,p_work_at_home		  in     varchar2
  ,p_job_post_source_name	  in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_cagr_grade_def_id		     out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  -- End 1889914
  ,p_comment_id                      out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
-- Bug 944911
-- Amended p_concatenated_segments to be out
-- Added p_concat_segments  - in param
  ,p_concatenated_segments           out nocopy varchar2
  ,p_concat_segments              in     varchar2
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72);
  l_effective_date             date;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_gsp_post_process_warning   varchar2(2000); -- bug 2999562

  --
  cursor check_legislation
    (c_assignment_id  per_all_assignments_f.assignment_id%TYPE,
     c_effective_date date
    )
  is
    select bgp.legislation_code
    from per_all_assignments_f asg,
         per_business_groups_perf bgp
    where asg.business_group_id = bgp.business_group_id
    and   asg.assignment_id     = c_assignment_id
    and   c_effective_date
      between effective_start_date and effective_end_date;
  --
begin
 if g_debug then
  l_proc := g_package||'update_us_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Truncate date variables
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validate in addition to Table Handlers
  --
  -- Check that the assignment exists.
  --
  open check_legislation(p_assignment_id, l_effective_date);
  fetch check_legislation into l_legislation_code;
  if check_legislation%notfound then
    close check_legislation;
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close check_legislation;
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Check that the legislation of the specified business group is 'US'.
  --
  if l_legislation_code <> 'US' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','US');
    hr_utility.raise_error;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Call update_emp_asg business process
  --
  hr_assignment_api.update_emp_asg
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_supervisor_id                => p_supervisor_id
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_title                        => p_title
    ,p_contract_id		    => p_contract_id
    ,p_establishment_id		    => p_establishment_id
    ,p_collective_agreement_id	    => p_collective_agreement_id
    ,p_cagr_id_flex_num		    => p_cagr_id_flex_num
    ,p_notice_period		    => p_notice_period
    ,p_notice_period_uom	    => p_notice_period_uom
    ,p_employee_category	    => p_employee_category
    ,p_work_at_home		    => p_work_at_home
    ,p_job_post_source_name	    => p_job_post_source_name
    ,p_segment1                     => p_tax_unit
    ,p_segment2                     => p_timecard_approver
    ,p_segment3                     => p_timecard_required
    ,p_segment4                     => p_work_schedule
    ,p_segment5                     => p_shift
    ,p_segment6                     => p_spouse_salary
    ,p_segment7                     => p_legal_representative
    ,p_segment8                     => p_wc_override_code
    ,p_segment9                     => p_eeo_1_establishment
    ,p_cagr_grade_def_id	    => p_cagr_grade_def_id
    ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_comment_id                   => p_comment_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
-- Bug 944911
-- Added new param
    ,p_concatenated_segments        => p_concatenated_segments
    ,p_concat_segments              => p_concat_segments
    ,p_no_managers_warning          => p_no_managers_warning
    ,p_other_manager_warning        => p_other_manager_warning
    ,p_hourly_salaried_warning      => p_hourly_salaried_warning
    ,p_gsp_post_process_warning     => l_gsp_post_process_warning -- bug 2999562
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end if;
end update_us_emp_asg;
-- End of update_us_emp_asg OVERLOADED procedure

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_us_emp_asg --NEW3 >--------------------|
-- ----------------------------------------------------------------------------
--
-- added new parameters p_gsp_post_process_warning


procedure update_us_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_hourly_salaried_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_tax_unit                     in     varchar2
  ,p_timecard_approver            in     varchar2
  ,p_timecard_required            in     varchar2
  ,p_work_schedule                in     varchar2
  ,p_shift                        in     varchar2
  ,p_spouse_salary                in     varchar2
  ,p_legal_representative         in     varchar2
  ,p_wc_override_code             in     varchar2
  ,p_eeo_1_establishment          in     varchar2
  -- Added for bug 1889914
  ,p_contract_id		  in     number
  ,p_establishment_id		  in 	 number
  ,p_collective_agreement_id	  in     number
  ,p_cagr_id_flex_num		  in     number
  ,p_notice_period		  in     number
  ,p_notice_period_uom	      	  in     varchar2
  ,p_employee_category	          in     varchar2
  ,p_work_at_home		  in     varchar2
  ,p_job_post_source_name	  in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_cagr_grade_def_id		     out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  -- End 1889914
  ,p_comment_id                      out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
-- Bug 944911
-- Amended p_concatenated_segments to be out
-- Added p_concat_segments  - in param
  ,p_concatenated_segments           out nocopy varchar2
  ,p_concat_segments              in     varchar2
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ,p_gsp_post_process_warning        out nocopy varchar2
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72);
  l_effective_date             date;
  l_legislation_code           per_business_groups.legislation_code%TYPE;

  --
  cursor check_legislation
    (c_assignment_id  per_all_assignments_f.assignment_id%TYPE,
     c_effective_date date
    )
  is
    select bgp.legislation_code
    from per_all_assignments_f asg,
         per_business_groups_perf bgp
    where asg.business_group_id = bgp.business_group_id
    and   asg.assignment_id     = c_assignment_id
    and   c_effective_date
      between effective_start_date and effective_end_date;
  --
begin
 if g_debug then
  l_proc := g_package||'update_us_emp_asg';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Truncate date variables
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validate in addition to Table Handlers
  --
  -- Check that the assignment exists.
  --
  open check_legislation(p_assignment_id, l_effective_date);
  fetch check_legislation into l_legislation_code;
  if check_legislation%notfound then
    close check_legislation;
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close check_legislation;
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Check that the legislation of the specified business group is 'US'.
  --
  if l_legislation_code <> 'US' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','US');
    hr_utility.raise_error;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Call update_emp_asg business process
  --
  hr_assignment_api.update_emp_asg
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_supervisor_id                => p_supervisor_id
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comments                     => p_comments
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_title                        => p_title
    ,p_contract_id		    => p_contract_id
    ,p_establishment_id		    => p_establishment_id
    ,p_collective_agreement_id	    => p_collective_agreement_id
    ,p_cagr_id_flex_num		    => p_cagr_id_flex_num
    ,p_notice_period		    => p_notice_period
    ,p_notice_period_uom	    => p_notice_period_uom
    ,p_employee_category	    => p_employee_category
    ,p_work_at_home		    => p_work_at_home
    ,p_job_post_source_name	    => p_job_post_source_name
    ,p_segment1                     => p_tax_unit
    ,p_segment2                     => p_timecard_approver
    ,p_segment3                     => p_timecard_required
    ,p_segment4                     => p_work_schedule
    ,p_segment5                     => p_shift
    ,p_segment6                     => p_spouse_salary
    ,p_segment7                     => p_legal_representative
    ,p_segment8                     => p_wc_override_code
    ,p_segment9                     => p_eeo_1_establishment
    ,p_cagr_grade_def_id	    => p_cagr_grade_def_id
    ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_comment_id                   => p_comment_id
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
-- Bug 944911
-- Added new param
    ,p_concatenated_segments        => p_concatenated_segments
    ,p_concat_segments              => p_concat_segments
    ,p_no_managers_warning          => p_no_managers_warning
    ,p_other_manager_warning        => p_other_manager_warning
    ,p_hourly_salaried_warning      => p_hourly_salaried_warning
    ,p_gsp_post_process_warning     => p_gsp_post_process_warning
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end if;
end update_us_emp_asg;
-- End of update_us_emp_asg OVERLOADED procedure

--
-- ----------------------------------------------------------------------------
-- |---------------------< update_emp_asg_criteria -- OLD>---------------------|
-- ----------------------------------------------------------------------------
--

procedure update_emp_asg_criteria
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_validate                     in     boolean
  ,p_called_from_mass_update      in     boolean
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_organization_id              in     number
  ,p_pay_basis_id                 in     number
  ,p_segment1                     in     varchar2
  ,p_segment2                     in     varchar2
  ,p_segment3                     in     varchar2
  ,p_segment4                     in     varchar2
  ,p_segment5                     in     varchar2
  ,p_segment6                     in     varchar2
  ,p_segment7                     in     varchar2
  ,p_segment8                     in     varchar2
  ,p_segment9                     in     varchar2
  ,p_segment10                    in     varchar2
  ,p_segment11                    in     varchar2
  ,p_segment12                    in     varchar2
  ,p_segment13                    in     varchar2
  ,p_segment14                    in     varchar2
  ,p_segment15                    in     varchar2
  ,p_segment16                    in     varchar2
  ,p_segment17                    in     varchar2
  ,p_segment18                    in     varchar2
  ,p_segment19                    in     varchar2
  ,p_segment20                    in     varchar2
  ,p_segment21                    in     varchar2
  ,p_segment22                    in     varchar2
  ,p_segment23                    in     varchar2
  ,p_segment24                    in     varchar2
  ,p_segment25                    in     varchar2
  ,p_segment26                    in     varchar2
  ,p_segment27                    in     varchar2
  ,p_segment28                    in     varchar2
  ,p_segment29                    in     varchar2
  ,p_segment30                    in     varchar2
  ,p_employment_category          in     varchar2
-- Bug 944911
-- Amended p_group_name to out
-- Added new param p_pgp_concat_segments - for sec asg procs
-- for others added p_concat_segments
  ,p_concat_segments              in     varchar2
  ,p_grade_ladder_pgm_id          in     number
  ,p_supervisor_assignment_id     in     number
  ,p_people_group_id              in out nocopy number --bug 2359997
  ,p_object_version_number        in out nocopy number
  ,p_special_ceiling_step_id      in out nocopy number
  ,p_group_name                      out nocopy varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_spp_delete_warning              out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_tax_district_changed_warning    out nocopy boolean
  ) is

    --
    -- Declare cursors and local variables
    --
    -- Out variables
    --
    l_effective_end_date           per_all_assignments_f.effective_end_date%TYPE;
    l_effective_start_date         per_all_assignments_f.effective_start_date%TYPE;
    l_entries_changed_warning      varchar2(1) := 'N';
    l_group_name                   pay_people_groups.group_name%TYPE;
    l_object_version_number        per_all_assignments_f.object_version_number%TYPE;
    l_org_now_no_manager_warning   boolean;
    l_other_manager_warning        boolean;
    l_people_group_id              per_all_assignments_f.people_group_id%TYPE
                                   := p_people_group_id; -- bug 2359997
    l_special_ceiling_step_id      per_all_assignments_f.special_ceiling_step_id%TYPE
                                   := p_special_ceiling_step_id; --3485599
    l_spp_delete_warning           boolean;
    l_tax_district_changed_warning boolean;

    l_soft_coding_keyflex_id       number;
    l_concatenated_segments	   hr_soft_coding_keyflex.concatenated_segments%TYPE;
    l_contract_id		   number;
    l_establishment_id		   number;
    l_scl_segment1		   varchar2(60);
    l_proc                         varchar2(72) := g_package||'update_emp_asg_criteria';

    -- Start of fix 3553286
    -- Bug 2656155
    --p_jobid                        number := p_job_id;
    --p_org_id                       number := p_organization_id;
    --
    -- End of 3553286

 BEGIN

    l_object_version_number := p_object_version_number;
    --
 if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;

 -- Start of fix 3553286
 -- Start of bug fix 2656155
 -- This procedure will return the job_id and organization_id of a position
 --
 -- Bug 3005283 : Starts here
 -- Description : This code should not be executed if position_id is null, otherwise org_id/job_id will be
 -- set to NULL if position_id is not passed to this procedure.  So added IF condition to check for that if
 -- position_id is not null and it is called from Mass Update form.
 --
 --  if (p_called_from_mass_update = TRUE and p_position_id is not null) then
 --    if (p_jobid is null) or (p_org_id is null) then
 --       hr_psf_shd.get_position_job_org(p_position_id, p_effective_date,
 --                                       p_jobid, p_org_id);
 --    end if;
 --   end if;
 --
 -- Bug 3005283 : Ends here.
 --
 -- End of fix 2656155
 -- End of fix 3553286

    --
    -- Calling New Overloaded Procedure
    --

    hr_assignment_api.update_emp_asg_criteria
      (p_validate                     =>  p_validate
      ,p_effective_date               =>  p_effective_date
      ,p_datetrack_update_mode        =>  p_datetrack_update_mode
      ,p_called_from_mass_update      =>  p_called_from_mass_update
      ,p_assignment_id                =>  p_assignment_id
      ,p_object_version_number        =>  l_object_version_number
      ,p_grade_id                     =>  p_grade_id
      ,p_position_id                  =>  p_position_id
      ,p_job_id                       =>  p_job_id -- Bug 2656155 -- 3553286
      ,p_payroll_id                   =>  p_payroll_id
      ,p_location_id                  =>  p_location_id
      ,p_special_ceiling_step_id      =>  l_special_ceiling_step_id
      ,p_organization_id              =>  p_organization_id -- Bug 2656155 -- 3553286
      ,p_pay_basis_id                 =>  p_pay_basis_id
      ,p_segment1                     =>  p_segment1
      ,p_segment2                     =>  p_segment2
      ,p_segment3                     =>  p_segment3
      ,p_segment4                     =>  p_segment4
      ,p_segment5                     =>  p_segment5
      ,p_segment6                     =>  p_segment6
      ,p_segment7                     =>  p_segment7
      ,p_segment8                     =>  p_segment8
      ,p_segment9                     =>  p_segment9
      ,p_segment10                    =>  p_segment10
      ,p_segment11                    =>  p_segment11
      ,p_segment12                    =>  p_segment12
      ,p_segment13                    =>  p_segment13
      ,p_segment14                    =>  p_segment14
      ,p_segment15                    =>  p_segment15
      ,p_segment16                    =>  p_segment16
      ,p_segment17                    =>  p_segment17
      ,p_segment18                    =>  p_segment18
      ,p_segment19                    =>  p_segment19
      ,p_segment20                    =>  p_segment20
      ,p_segment21                    =>  p_segment21
      ,p_segment22                    =>  p_segment22
      ,p_segment23                    =>  p_segment23
      ,p_segment24                    =>  p_segment24
      ,p_segment25                    =>  p_segment25
      ,p_segment26                    =>  p_segment26
      ,p_segment27                    =>  p_segment27
      ,p_segment28                    =>  p_segment28
      ,p_segment29                    =>  p_segment29
      ,p_segment30                    =>  p_segment30
      ,p_concat_segments              =>  p_concat_segments
      ,p_grade_ladder_pgm_id          =>  p_grade_ladder_pgm_id
      ,p_supervisor_assignment_id     =>  p_supervisor_assignment_id
      ,p_group_name                   =>  l_group_name
      ,p_employment_category          =>  p_employment_category
      ,p_effective_start_date         =>  l_effective_start_date
      ,p_effective_end_date           =>  l_effective_end_date
      ,p_people_group_id              =>  l_people_group_id
      ,p_org_now_no_manager_warning   =>  l_org_now_no_manager_warning
      ,p_other_manager_warning        =>  l_other_manager_warning
      ,p_spp_delete_warning           =>  l_spp_delete_warning
      ,p_entries_changed_warning      =>  l_entries_changed_warning
      ,p_tax_district_changed_warning =>  l_tax_district_changed_warning
      ,p_soft_coding_keyflex_id       =>  l_soft_coding_keyflex_id
      ,p_concatenated_segments        =>  l_concatenated_segments
--2689059: changed the following: must pass hr_api defaults to NEW update API
      ,p_contract_id                  =>  hr_api.g_number  --l_contract_id
      ,p_establishment_id             =>  hr_api.g_number  --l_establishment_id
      ,p_scl_segment1                 =>  hr_api.g_varchar2  --l_scl_segment1
      ) ;


      --
      -- Set all output arguments
      --
      p_effective_end_date           := l_effective_end_date;
      p_effective_start_date         := l_effective_start_date;
      p_people_group_id              := l_people_group_id;
      p_group_name                   := l_group_name;
      p_entries_changed_warning      := l_entries_changed_warning;
      p_object_version_number        := l_object_version_number;
      p_org_now_no_manager_warning   := l_org_now_no_manager_warning;
      p_other_manager_warning        := l_other_manager_warning;
      p_special_ceiling_step_id      := l_special_ceiling_step_id;
      p_spp_delete_warning           := l_spp_delete_warning;
      p_tax_district_changed_warning := l_tax_district_changed_warning;

 if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 20);
 end if;

End update_emp_asg_criteria;


-- ----------------------------------------------------------------------------
-- |---------------------< update_emp_asg_criteria-- NEW >---------------------|
-- ----------------------------------------------------------------------------
--

procedure update_emp_asg_criteria
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_validate                     in     boolean
  ,p_called_from_mass_update      in     boolean
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_organization_id              in     number
  ,p_pay_basis_id                 in     number
  ,p_segment1                     in     varchar2
  ,p_segment2                     in     varchar2
  ,p_segment3                     in     varchar2
  ,p_segment4                     in     varchar2
  ,p_segment5                     in     varchar2
  ,p_segment6                     in     varchar2
  ,p_segment7                     in     varchar2
  ,p_segment8                     in     varchar2
  ,p_segment9                     in     varchar2
  ,p_segment10                    in     varchar2
  ,p_segment11                    in     varchar2
  ,p_segment12                    in     varchar2
  ,p_segment13                    in     varchar2
  ,p_segment14                    in     varchar2
  ,p_segment15                    in     varchar2
  ,p_segment16                    in     varchar2
  ,p_segment17                    in     varchar2
  ,p_segment18                    in     varchar2
  ,p_segment19                    in     varchar2
  ,p_segment20                    in     varchar2
  ,p_segment21                    in     varchar2
  ,p_segment22                    in     varchar2
  ,p_segment23                    in     varchar2
  ,p_segment24                    in     varchar2
  ,p_segment25                    in     varchar2
  ,p_segment26                    in     varchar2
  ,p_segment27                    in     varchar2
  ,p_segment28                    in     varchar2
  ,p_segment29                    in     varchar2
  ,p_segment30                    in     varchar2
  ,p_employment_category          in     varchar2
-- Bug 944911
-- Amended p_group_name to out
-- Added new param p_pgp_concat_segments - for sec asg procs
-- for others added p_concat_segments
  ,p_concat_segments              in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_scl_segment1                 in     varchar2
  ,p_grade_ladder_pgm_id          in     number
  ,p_supervisor_assignment_id     in     number
  ,p_object_version_number        in out nocopy number
  ,p_special_ceiling_step_id      in out nocopy number
  ,p_people_group_id              in out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_group_name                      out nocopy varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_spp_delete_warning              out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_tax_district_changed_warning    out nocopy boolean
  ,p_concatenated_segments           out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_effective_end_date           per_all_assignments_f.effective_end_date%TYPE;
  l_effective_start_date         per_all_assignments_f.effective_start_date%TYPE;
  l_entries_changed_warning      varchar2(1) := 'N';
  l_group_name                   pay_people_groups.group_name%TYPE;
  l_old_group_name               pay_people_groups.group_name%TYPE;
  l_no_managers_warning          boolean;
  l_object_version_number        per_all_assignments_f.object_version_number%TYPE;
  l_org_now_no_manager_warning   boolean;
  l_other_manager_warning        boolean;
  l_hourly_salaried_warning      boolean;
  l_payroll_id_updated           boolean;
  l_people_group_id              per_all_assignments_f.people_group_id%TYPE
                                 := p_people_group_id; -- bug 2359997
  l_special_ceiling_step_id      per_all_assignments_f.special_ceiling_step_id%TYPE
                                 := p_special_ceiling_step_id; -- bug 3485599
  l_spp_delete_warning           boolean;
  l_tax_district_changed_warning boolean;
  l_flex_num                     fnd_id_flex_segments.id_flex_num%TYPE;
  --
  l_api_updating                 boolean;
  l_business_group_id            per_all_assignments_f.business_group_id%TYPE;
  l_comment_id                   per_all_assignments_f.comment_id%TYPE;
  l_entries_changed              varchar2(1);
  l_legislation_code             per_business_groups.legislation_code%TYPE;
  l_new_payroll_id               per_all_assignments_f.payroll_id%TYPE;
  l_proc                         varchar2(72) :=
                                 g_package || 'update_emp_asg_criteria';

-- Start of Fix for Bug 2622747
  l_soft_coding_keyflex_id per_all_assignments_f.soft_coding_keyflex_id%TYPE := p_soft_coding_keyflex_id;
  l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_old_conc_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
-- End of Fix for Bug 2622747

  l_gsp_post_process_warning varchar2(2000); -- bug 2999562

 BEGIN

    l_object_version_number := p_object_version_number;
    --
 if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;

    --
    -- Calling New Overloaded Procedure
    --

    hr_assignment_api.update_emp_asg_criteria
      (p_validate                     =>  p_validate
      ,p_effective_date               =>  p_effective_date
      ,p_datetrack_update_mode        =>  p_datetrack_update_mode
      ,p_called_from_mass_update      =>  p_called_from_mass_update
      ,p_assignment_id                =>  p_assignment_id
      ,p_object_version_number        =>  l_object_version_number
      ,p_grade_id                     =>  p_grade_id
      ,p_position_id                  =>  p_position_id
      ,p_job_id                       =>  p_job_id
      ,p_payroll_id                   =>  p_payroll_id
      ,p_location_id                  =>  p_location_id
      ,p_special_ceiling_step_id      =>  l_special_ceiling_step_id
      ,p_organization_id              =>  p_organization_id
      ,p_pay_basis_id                 =>  p_pay_basis_id
      ,p_segment1                     =>  p_segment1
      ,p_segment2                     =>  p_segment2
      ,p_segment3                     =>  p_segment3
      ,p_segment4                     =>  p_segment4
      ,p_segment5                     =>  p_segment5
      ,p_segment6                     =>  p_segment6
      ,p_segment7                     =>  p_segment7
      ,p_segment8                     =>  p_segment8
      ,p_segment9                     =>  p_segment9
      ,p_segment10                    =>  p_segment10
      ,p_segment11                    =>  p_segment11
      ,p_segment12                    =>  p_segment12
      ,p_segment13                    =>  p_segment13
      ,p_segment14                    =>  p_segment14
      ,p_segment15                    =>  p_segment15
      ,p_segment16                    =>  p_segment16
      ,p_segment17                    =>  p_segment17
      ,p_segment18                    =>  p_segment18
      ,p_segment19                    =>  p_segment19
      ,p_segment20                    =>  p_segment20
      ,p_segment21                    =>  p_segment21
      ,p_segment22                    =>  p_segment22
      ,p_segment23                    =>  p_segment23
      ,p_segment24                    =>  p_segment24
      ,p_segment25                    =>  p_segment25
      ,p_segment26                    =>  p_segment26
      ,p_segment27                    =>  p_segment27
      ,p_segment28                    =>  p_segment28
      ,p_segment29                    =>  p_segment29
      ,p_segment30                    =>  p_segment30
      ,p_concat_segments              =>  p_concat_segments
      ,p_grade_ladder_pgm_id          =>  p_grade_ladder_pgm_id
      ,p_supervisor_assignment_id     =>  p_supervisor_assignment_id
      ,p_employment_category          =>  p_employment_category
      ,p_contract_id                  =>  p_contract_id
      ,p_establishment_id             =>  p_establishment_id
      ,p_scl_segment1                 =>  p_scl_segment1
      ,p_group_name                   =>  l_group_name
      ,p_effective_start_date         =>  l_effective_start_date
      ,p_effective_end_date           =>  l_effective_end_date
      ,p_people_group_id              =>  l_people_group_id
      ,p_org_now_no_manager_warning   =>  l_org_now_no_manager_warning
      ,p_other_manager_warning        =>  l_other_manager_warning
      ,p_spp_delete_warning           =>  l_spp_delete_warning
      ,p_entries_changed_warning      =>  l_entries_changed_warning
      ,p_tax_district_changed_warning =>  l_tax_district_changed_warning
      ,p_soft_coding_keyflex_id       =>  l_soft_coding_keyflex_id
      ,p_concatenated_segments        =>  l_concatenated_segments
      ,p_gsp_post_process_warning     =>  l_gsp_post_process_warning -- bug 2999562
      ) ;

  --
  -- Set all output arguments
  --
  p_effective_end_date           := l_effective_end_date;
  p_effective_start_date         := l_effective_start_date;
  p_people_group_id              := l_people_group_id;
  p_group_name                   := l_group_name;
  p_entries_changed_warning      := l_entries_changed_warning;
  p_object_version_number        := l_object_version_number;
  p_org_now_no_manager_warning   := l_org_now_no_manager_warning;
  p_other_manager_warning        := l_other_manager_warning;
  p_special_ceiling_step_id      := l_special_ceiling_step_id;
  p_spp_delete_warning           := l_spp_delete_warning;
  p_tax_district_changed_warning := l_tax_district_changed_warning;
  --
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 997);
 end if;
  --
end update_emp_asg_criteria;
-- ----------------------------------------------------------------------------
-- |---------------------< update_emp_asg_criteria-- NEW2 >-------------------|
-- ----------------------------------------------------------------------------
--

procedure update_emp_asg_criteria
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_validate                     in     boolean
  ,p_called_from_mass_update      in     boolean
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_organization_id              in     number
  ,p_pay_basis_id                 in     number
  ,p_segment1                     in     varchar2
  ,p_segment2                     in     varchar2
  ,p_segment3                     in     varchar2
  ,p_segment4                     in     varchar2
  ,p_segment5                     in     varchar2
  ,p_segment6                     in     varchar2
  ,p_segment7                     in     varchar2
  ,p_segment8                     in     varchar2
  ,p_segment9                     in     varchar2
  ,p_segment10                    in     varchar2
  ,p_segment11                    in     varchar2
  ,p_segment12                    in     varchar2
  ,p_segment13                    in     varchar2
  ,p_segment14                    in     varchar2
  ,p_segment15                    in     varchar2
  ,p_segment16                    in     varchar2
  ,p_segment17                    in     varchar2
  ,p_segment18                    in     varchar2
  ,p_segment19                    in     varchar2
  ,p_segment20                    in     varchar2
  ,p_segment21                    in     varchar2
  ,p_segment22                    in     varchar2
  ,p_segment23                    in     varchar2
  ,p_segment24                    in     varchar2
  ,p_segment25                    in     varchar2
  ,p_segment26                    in     varchar2
  ,p_segment27                    in     varchar2
  ,p_segment28                    in     varchar2
  ,p_segment29                    in     varchar2
  ,p_segment30                    in     varchar2
  ,p_employment_category          in     varchar2
-- Bug 944911
-- Amended p_group_name to out
-- Added new param p_pgp_concat_segments - for sec asg procs
-- for others added p_concat_segments
  ,p_concat_segments              in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_scl_segment1                 in     varchar2
  ,p_grade_ladder_pgm_id          in     number
  ,p_supervisor_assignment_id     in     number
  ,p_object_version_number        in out nocopy number
  ,p_special_ceiling_step_id      in out nocopy number
  ,p_people_group_id              in out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_group_name                      out nocopy varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_spp_delete_warning              out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_tax_district_changed_warning    out nocopy boolean
  ,p_concatenated_segments           out nocopy varchar2
  ,p_gsp_post_process_warning        out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_effective_end_date           per_all_assignments_f.effective_end_date%TYPE;
  l_effective_start_date         per_all_assignments_f.effective_start_date%TYPE;
  l_entries_changed_warning      varchar2(1) := 'N';
  l_group_name                   pay_people_groups.group_name%TYPE;
  l_old_group_name               pay_people_groups.group_name%TYPE;
  l_no_managers_warning          boolean;
  l_object_version_number        per_all_assignments_f.object_version_number%TYPE;
  l_org_now_no_manager_warning   boolean;
  l_other_manager_warning        boolean;
  l_hourly_salaried_warning      boolean;
  l_payroll_id_updated           boolean;
  l_people_group_id              per_all_assignments_f.people_group_id%TYPE
                                 := p_people_group_id; -- bug 2359997
  l_special_ceiling_step_id      per_all_assignments_f.special_ceiling_step_id%TYPE;
  l_spp_delete_warning           boolean;
  l_tax_district_changed_warning boolean;
  l_flex_num                     fnd_id_flex_segments.id_flex_num%TYPE;
  l_gsp_post_process_warning     varchar2(2000); -- bug2999562
  --
  l_api_updating                 boolean;
  l_business_group_id            per_all_assignments_f.business_group_id%TYPE;
  l_comment_id                   per_all_assignments_f.comment_id%TYPE;
  l_entries_changed              varchar2(1);
  l_legislation_code             per_business_groups.legislation_code%TYPE;
  l_new_payroll_id               per_all_assignments_f.payroll_id%TYPE;
  l_proc                         varchar2(72) :=
                                 g_package || 'update_emp_asg_criteria';
  l_validation_end_date          date;
  l_validation_start_date        date;
  l_effective_date               date;
  l_element_entry_id             number;
  l_organization_id              per_all_assignments_f.organization_id%type;
  l_location_id                  per_all_assignments_f.location_id%type;
  l_session_id                   number;
  l_step_id                      per_spinal_point_steps_f.step_id%TYPE;

-- Start of Fix for Bug 2622747
  l_soft_coding_keyflex_id per_all_assignments_f.soft_coding_keyflex_id%TYPE := p_soft_coding_keyflex_id;
  l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_old_conc_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
-- End of Fix for Bug 2622747

  --
  -- bug 2359997 new variable to indicate whether people group key flex
  -- entered with a value.
  --
  l_pgp_null_ind               number(1) := 0;
  --
  -- bug 2359997 new variables for derived values where key flex id is known.
  --
  --
  l_pgp_segment1               varchar2(60) := p_segment1;
  l_pgp_segment2               varchar2(60) := p_segment2;
  l_pgp_segment3               varchar2(60) := p_segment3;
  l_pgp_segment4               varchar2(60) := p_segment4;
  l_pgp_segment5               varchar2(60) := p_segment5;
  l_pgp_segment6               varchar2(60) := p_segment6;
  l_pgp_segment7               varchar2(60) := p_segment7;
  l_pgp_segment8               varchar2(60) := p_segment8;
  l_pgp_segment9               varchar2(60) := p_segment9;
  l_pgp_segment10              varchar2(60) := p_segment10;
  l_pgp_segment11              varchar2(60) := p_segment11;
  l_pgp_segment12              varchar2(60) := p_segment12;
  l_pgp_segment13              varchar2(60) := p_segment13;
  l_pgp_segment14              varchar2(60) := p_segment14;
  l_pgp_segment15              varchar2(60) := p_segment15;
  l_pgp_segment16              varchar2(60) := p_segment16;
  l_pgp_segment17              varchar2(60) := p_segment17;
  l_pgp_segment18              varchar2(60) := p_segment18;
  l_pgp_segment19              varchar2(60) := p_segment19;
  l_pgp_segment20              varchar2(60) := p_segment20;
  l_pgp_segment21              varchar2(60) := p_segment21;
  l_pgp_segment22              varchar2(60) := p_segment22;
  l_pgp_segment23              varchar2(60) := p_segment23;
  l_pgp_segment24              varchar2(60) := p_segment24;
  l_pgp_segment25              varchar2(60) := p_segment25;
  l_pgp_segment26              varchar2(60) := p_segment26;
  l_pgp_segment27              varchar2(60) := p_segment27;
  l_pgp_segment28              varchar2(60) := p_segment28;
  l_pgp_segment29              varchar2(60) := p_segment29;
  l_pgp_segment30              varchar2(60) := p_segment30;

-- Start of Fix for Bug 2622747
  l_scl_segment1               varchar2(60) := p_scl_segment1;
  l_scl_segment2               varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment3               varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment4               varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment5               varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment6               varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment7               varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment8               varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment9               varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment10              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment11              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment12              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment13              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment14              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment15              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment16              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment17              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment18              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment19              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment20              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment21              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment22              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment23              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment24              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment25              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment26              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment27              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment28              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment29              varchar2(60) := hr_api.g_varchar2 ;
  l_scl_segment30              varchar2(60) := hr_api.g_varchar2 ;
  --
  lv_object_version_number        number := p_object_version_number ;
  lv_special_ceiling_step_id      number := p_special_ceiling_step_id ;
  lv_people_group_id              number := p_people_group_id ;
  lv_soft_coding_keyflex_id       number := p_soft_coding_keyflex_id ;
  --

-- End of Fix for Bug 2622747
  l_element_entry_id1             number;  -- bug 4464072
  --
  -- bug 2359997 get pay_people_group segment values where
  -- people_group_id is known
  --
  cursor c_pgp_segments is
     select group_name,    --4103321
            segment1,
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
     from   pay_people_groups
     where  people_group_id = l_people_group_id;
  --
  cursor csr_get_legislation_code is
    select bus.legislation_code
      from per_business_groups_perf bus
     where bus.business_group_id = l_business_group_id;
  --
  cursor csr_get_salary is
  select element_entry_id
  from   pay_element_entries_f
  where  assignment_id = p_assignment_id
  and    creator_type = 'SP'
  and    l_validation_start_date between
         effective_start_date and effective_end_date;

-- start of fix for  bug 4464072
cursor csr_chk_rec_exists is
  select element_entry_id
  from   pay_element_entries_f
  where  assignment_id = p_assignment_id
  and    creator_type = 'SP'
  and    (l_validation_start_date - 1) between
         effective_start_date and effective_end_date;

-- end of fix for bug 4464072
  --
  cursor csr_grp_idsel is
  select bus.people_group_structure
  from  per_business_groups_perf bus
  where bus.business_group_id = l_business_group_id;
  --
  cursor get_sec_date_range is
  select asg.effective_start_date
  ,      asg.effective_end_date
  from   per_all_assignments_f asg
  where  asg.assignment_id=p_assignment_id
  and   ((sysdate between asg.effective_start_date
          and asg.effective_end_date)
         or
         (sysdate<asg.effective_start_date
          and not exists
          (select 1
           from per_all_assignments_f asg2
           where asg2.person_id=asg.person_id
           and asg2.period_of_service_id=asg.period_of_service_id
           and asg2.effective_start_date<asg.effective_start_date)
         )
        );
  --
  cursor csr_chk_grade_and_ceiling is
    select sps.step_id
    from   per_spinal_point_steps_f sps,
           per_grade_spines_f pgs
    where  pgs.grade_id       = p_grade_id
    and    pgs.grade_spine_id = sps.grade_spine_id
    and    sps.step_id        = p_special_ceiling_step_id;
  --
  l_sec_effective_start_date date;
  l_sec_effective_end_date date;
  --
  l_dt_update_mode     VARCHAR2(30);
  l_new_dt_update_mode VARCHAR2(30);
  --
  -- Start of bug 3553286
  l_job_id                       number := p_job_id;
  l_org_id                       number := p_organization_id;
  -- End of 3553286
  --
  -- Start of 4103321
    l_old_pgp_segments   c_pgp_segments%rowtype;
    l_old_conc_segs      pay_people_groups.group_name%type;
  -- End of 4103321
  --
begin
  if g_debug then
   hr_utility.set_location('Entering:'|| l_proc, 30);
  end if;

  --
  -- Truncate the p_effective_date value to remove time element.
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Bug 944911
  -- Made p_group_name to be out param
  -- and add p_concat_segment to be IN
  -- in case of sec_asg alone made p_pgp_concat_segments as in param
  -- Replaced p_group_name by p_concat_segments
  --
  l_old_group_name := p_concat_segments;
  --
  -- Added as part of fix for bug 2473971
  --
  IF p_called_from_mass_update THEN
    --
    if g_debug then
      hr_utility.set_location(l_proc,40);
    end if;
    --
    l_dt_update_mode     := 'CORRECTION';
    l_new_dt_update_mode := p_datetrack_update_mode;
    --
  ELSE
    --
    if g_debug then
      hr_utility.set_location(l_proc,50);
    end if;
    --
    l_dt_update_mode     := p_datetrack_update_mode;
    l_new_dt_update_mode := p_datetrack_update_mode;
    --
  END IF;
  --
  -- Bug 2359997 - if p_people_group_id enters with
  -- a value then get segment values from pay_people_groups.
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
  --
  if l_people_group_id is null
  then
     l_pgp_null_ind := 0;
  else
    -- get segment values
     open c_pgp_segments;
      fetch c_pgp_segments into l_old_conc_segs,   -- 4103321
                                l_pgp_segment1,
                                l_pgp_segment2,
                                l_pgp_segment3,
                                l_pgp_segment4,
                                l_pgp_segment5,
                                l_pgp_segment6,
                                l_pgp_segment7,
                                l_pgp_segment8,
                                l_pgp_segment9,
                                l_pgp_segment10,
                                l_pgp_segment11,
                                l_pgp_segment12,
                                l_pgp_segment13,
                                l_pgp_segment14,
                                l_pgp_segment15,
                                l_pgp_segment16,
                                l_pgp_segment17,
                                l_pgp_segment18,
                                l_pgp_segment19,
                                l_pgp_segment20,
                                l_pgp_segment21,
                                l_pgp_segment22,
                                l_pgp_segment23,
                                l_pgp_segment24,
                                l_pgp_segment25,
                                l_pgp_segment26,
                                l_pgp_segment27,
                                l_pgp_segment28,
                                l_pgp_segment29,
                                l_pgp_segment30;
     close c_pgp_segments;
     l_pgp_null_ind := 1;
  end if;


  --
  -- Issue a savepoint.
  --
  savepoint update_emp_asg_criteria;
  --
  begin
  --
    -- Start of API User Hook for the before hook of update_emp_asg_criteria
    --
    hr_assignment_bk3.update_emp_asg_criteria_b
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => l_dt_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_grade_id                     => p_grade_id
      ,p_position_id                  => p_position_id
      ,p_job_id                       => p_job_id
      ,p_payroll_id                   => p_payroll_id
      ,p_location_id                  => p_location_id
      ,p_special_ceiling_step_id      => p_special_ceiling_step_id
      ,p_organization_id              => p_organization_id
      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_segment1                     => l_pgp_segment1
      ,p_segment2                     => l_pgp_segment2
      ,p_segment3                     => l_pgp_segment3
      ,p_segment4                     => l_pgp_segment4
      ,p_segment5                     => l_pgp_segment5
      ,p_segment6                     => l_pgp_segment6
      ,p_segment7                     => l_pgp_segment7
      ,p_segment8                     => l_pgp_segment8
      ,p_segment9                     => l_pgp_segment9
      ,p_segment10                    => l_pgp_segment10
      ,p_segment11                    => l_pgp_segment11
      ,p_segment12                    => l_pgp_segment12
      ,p_segment13                    => l_pgp_segment13
      ,p_segment14                    => l_pgp_segment14
      ,p_segment15                    => l_pgp_segment15
      ,p_segment16                    => l_pgp_segment16
      ,p_segment17                    => l_pgp_segment17
      ,p_segment18                    => l_pgp_segment18
      ,p_segment19                    => l_pgp_segment19
      ,p_segment20                    => l_pgp_segment20
      ,p_segment21                    => l_pgp_segment21
      ,p_segment22                    => l_pgp_segment22
      ,p_segment23                    => l_pgp_segment23
      ,p_segment24                    => l_pgp_segment24
      ,p_segment25                    => l_pgp_segment25
      ,p_segment26                    => l_pgp_segment26
      ,p_segment27                    => l_pgp_segment27
      ,p_segment28                    => l_pgp_segment28
      ,p_segment29                    => l_pgp_segment29
      ,p_segment30                    => l_pgp_segment30
       --
       -- Bug 944911
       -- Amended p_group_name to p_concat_segments
       --
      ,p_concat_segments              => l_old_group_name
      ,p_employment_category          => p_employment_category
-- Start of Fix for Bug 2622747
      ,p_contract_id                  => p_contract_id
      ,p_establishment_id             => p_establishment_id
      );
-- End of Fix for Bug 2622747

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EMP_ASG_CRITERIA'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_emp_asg_criteria
    --
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 70);
  end if;
  --
  l_object_version_number := p_object_version_number;
  --
  -- Validation in addition to Table Handlers
  --
  -- Retrieve current assignment details from database.
  --
  l_api_updating := per_asg_shd.api_updating
    (p_assignment_id         => p_assignment_id
    ,p_effective_date        => l_effective_date
    ,p_object_version_number => l_object_version_number);
  --
  if g_debug then
   hr_utility.set_location(l_proc, 80);
  end if;
  --
  if not l_api_updating
  then
    --
    if g_debug then
      hr_utility.set_location(l_proc, 90);
    end if;
    --
    -- As this is an updating API, the assignment should already exist.
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
    -- else
    --
    if g_debug then
      hr_utility.set_location(l_proc, 100);
    end if;
    --
    -- l_people_group_id := per_asg_shd.g_old_rec.people_group_id; bug 2359997
  end if;
  --
  if g_debug then
   hr_utility.set_location(l_proc, 110);
  end if;
  --
  -- Check that the assignment is an employee assignment.
  --
  if per_asg_shd.g_old_rec.assignment_type <> 'E'
  then
    --
    if g_debug then
      hr_utility.set_location(l_proc, 120);
    end if;
    --
    hr_utility.set_message(801, 'HR_7948_ASG_ASG_NOT_EMP');
    hr_utility.raise_error;
  end if;
  --
  if g_debug then
   hr_utility.set_location(l_proc, 130);
  end if;
  --
  -- Removed as part of fix for bug
  --
  -- Process Logic
  --
  -- bug 2473971
  --
  -- Set special_ceiling_step_id to null if grade_id is being changed or is
  -- null.
  --
  --   if  per_asg_shd.g_old_rec.grade_id <> p_grade_id
  --       or p_grade_id is null
  --   then
  --     --
  --     --
  --     l_special_ceiling_step_id := null;
  --   else
  --     --
  --     --
  --     if p_special_ceiling_step_id = hr_api.g_number then
  --       --
  --       --
  --       l_special_ceiling_step_id := per_asg_shd.g_old_rec.special_ceiling_step_id;
  --       else
  --       --
  --       --
  --       l_special_ceiling_step_id := p_special_ceiling_step_id;
  --      end if;
  --     --
  --   end if;
  --
  --
  -- Process Logic
  --
  -- bug 2473971 and reworked to include
  -- cursor check as part of fix for bug 2564704
  --
  -- If the grade has been changed and the special ceiling
  -- id is populated then check that the ceiling id
  -- is for the grade.
  --
  --  Bug 348599 Added the condition to
  --  allow updation of p_ceiling_step_id even though
  --  the grade is assigned to assignment but not passed
  --  to api.
  --
  if (per_asg_shd.g_old_rec.grade_id <> p_grade_id AND
      p_grade_id <> hr_api.g_number AND -- 3485599
      p_special_ceiling_step_id IS NOT NULL) then
    --
    if g_debug then
      hr_utility.set_location(l_proc, 140);
    end if;
    --
    open csr_chk_grade_and_ceiling;
    fetch csr_chk_grade_and_ceiling into l_step_id;
    --
    -- If the ceiling id is not for the new grade then
    -- set the ceiling to be null
    --
    if csr_chk_grade_and_ceiling%NOTFOUND then
      --
      if g_debug then
        hr_utility.set_location(l_proc, 150);
      end if;
      --
      close csr_chk_grade_and_ceiling;
      --
      l_special_ceiling_step_id := NULL;
    --
    -- if the ceiling id is for the grade
    -- then set the local variable to the parameter.
    --
    else
      --
      if g_debug then
        hr_utility.set_location(l_proc, 160);
      end if;
      --
      close csr_chk_grade_and_ceiling;
      --
      l_special_ceiling_step_id := p_special_ceiling_step_id;
      --
    end if;
  --
  --  Set special_ceiling_step_id to null if grade_id
  --  is being changed or is null.
  --
  elsif p_grade_id is null then
    --
    if g_debug then
      hr_utility.set_location(l_proc, 170);
    end if;
    --
    l_special_ceiling_step_id := null;
    --
  else
    --
    if g_debug then
       hr_utility.set_location(l_proc, 180);
    end if;
    --
    if p_special_ceiling_step_id = hr_api.g_number then
      --
      if g_debug then
        hr_utility.set_location(l_proc, 190);
      end if;
      --
      l_special_ceiling_step_id := per_asg_shd.g_old_rec.special_ceiling_step_id;
      --
    else
      --
      if g_debug then
        hr_utility.set_location(l_proc, 200);
      end if;
      --
      l_special_ceiling_step_id := p_special_ceiling_step_id;
      --
    end if;
    --
  end if;
  if g_debug then
    hr_utility.set_location(l_proc, 210);
  end if;
  --
  -- Populate l_business_group_id from g_old_rec for cursor csr_grp_idsel
  --
  l_business_group_id := per_asg_shd.g_old_rec.business_group_id;
  --
  -- Start of bug fix 3553286
  -- This procedure will return the job_id and organization_id of a position
  --
  if (p_called_from_mass_update = TRUE and p_position_id is not null) then
     if (l_job_id is null) or (l_org_id is null) then
         hr_psf_shd.get_position_job_org(p_position_id, p_effective_date,
                                         l_job_id, l_org_id);
     end if;
  end if;
  -- End of 3553286
  -- insert the profile options and effective date for the flexfield
  -- validation to work
  --
  --
  if (l_org_id = hr_api.g_number) then -- Bug 3553286
    l_organization_id:=per_asg_shd.g_old_rec.organization_id;
  else
    l_organization_id:= l_org_id; -- Bug 3553286
  end if;
  --
  if (p_location_id=hr_api.g_number) then
    l_location_id:=per_asg_shd.g_old_rec.location_id;
  else
    l_location_id:=p_location_id;
  end if;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 220);
  end if;
  --
  hr_kflex_utility.set_profiles
  (p_business_group_id => l_business_group_id
  ,p_assignment_id     => p_assignment_id
  ,p_organization_id   => l_organization_id
  ,p_location_id       => l_location_id);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 230);
  end if;
  --
  hr_kflex_utility.set_session_date
  (p_effective_date => l_effective_date
  ,p_session_id     => l_session_id);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 240);
  end if;
  --
  open csr_grp_idsel;
  fetch csr_grp_idsel
  into l_flex_num;
    if csr_grp_idsel%NOTFOUND then
       close csr_grp_idsel;
          hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE', l_proc);
          hr_utility.set_message_token('STEP','5');
          hr_utility.raise_error;
     end if;
  close csr_grp_idsel;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 250);
 end if;
  --
  -- Maintain the people group key flexfields.
  --
  -- Only call the flex code if a non-default value(includng null) is passed
  -- to the procedure.
  --
    --
  if  l_pgp_null_ind = 0 -- bug 2359997
  then
    --
    l_people_group_id := per_asg_shd.g_old_rec.people_group_id;
    -- 4103321 modified the if statement

    if l_people_group_id is not null then
       open c_pgp_segments;
       fetch c_pgp_segments into l_old_pgp_segments;
       close c_pgp_segments;
    end if;
    --
    if   nvl(p_segment1, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment1, hr_api.g_varchar2)
      or nvl(p_segment2, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment2, hr_api.g_varchar2)
      or nvl(p_segment3, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment3, hr_api.g_varchar2)
      or nvl(p_segment4, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment4, hr_api.g_varchar2)
      or nvl(p_segment5, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment5, hr_api.g_varchar2)
      or nvl(p_segment6, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment6, hr_api.g_varchar2)
      or nvl(p_segment7, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment7, hr_api.g_varchar2)
      or nvl(p_segment8, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment8, hr_api.g_varchar2)
      or nvl(p_segment9, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment9, hr_api.g_varchar2)
      or nvl(p_segment10, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment10, hr_api.g_varchar2)
      or nvl(p_segment11, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment11, hr_api.g_varchar2)
      or nvl(p_segment12, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment12, hr_api.g_varchar2)
      or nvl(p_segment13, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment13, hr_api.g_varchar2)
      or nvl(p_segment14, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment14, hr_api.g_varchar2)
      or nvl(p_segment15, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment15, hr_api.g_varchar2)
      or nvl(p_segment16, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment16, hr_api.g_varchar2)
      or nvl(p_segment17, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment17, hr_api.g_varchar2)
      or nvl(p_segment18, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment18, hr_api.g_varchar2)
      or nvl(p_segment19, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment19, hr_api.g_varchar2)
      or nvl(p_segment20, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment20, hr_api.g_varchar2)
      or nvl(p_segment21, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment21, hr_api.g_varchar2)
      or nvl(p_segment22, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment22, hr_api.g_varchar2)
      or nvl(p_segment23, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment23, hr_api.g_varchar2)
      or nvl(p_segment24, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment24, hr_api.g_varchar2)
      or nvl(p_segment25, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment25, hr_api.g_varchar2)
      or nvl(p_segment26, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment26, hr_api.g_varchar2)
      or nvl(p_segment27, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment27, hr_api.g_varchar2)
      or nvl(p_segment28, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment28, hr_api.g_varchar2)
      or nvl(p_segment29, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment29, hr_api.g_varchar2)
      or nvl(p_segment30, hr_api.g_varchar2) <> nvl(l_old_pgp_segments.segment30, hr_api.g_varchar2)
      or nvl(l_old_group_name,hr_api.g_varchar2) <> nvl(l_old_pgp_segments.group_name, hr_api.g_varchar2)
      or l_people_group_id is  null -- fix for bug 4633742.
    then
      hr_kflex_utility.upd_or_sel_keyflex_comb
      (p_appl_short_name              => 'PAY'
      ,p_flex_code                    => 'GRP'
      ,p_flex_num                     => l_flex_num
      ,p_segment1                     => l_pgp_segment1
      ,p_segment2                     => l_pgp_segment2
      ,p_segment3                     => l_pgp_segment3
      ,p_segment4                     => l_pgp_segment4
      ,p_segment5                     => l_pgp_segment5
      ,p_segment6                     => l_pgp_segment6
      ,p_segment7                     => l_pgp_segment7
      ,p_segment8                     => l_pgp_segment8
      ,p_segment9                     => l_pgp_segment9
      ,p_segment10                    => l_pgp_segment10
      ,p_segment11                    => l_pgp_segment11
      ,p_segment12                    => l_pgp_segment12
      ,p_segment13                    => l_pgp_segment13
      ,p_segment14                    => l_pgp_segment14
      ,p_segment15                    => l_pgp_segment15
      ,p_segment16                    => l_pgp_segment16
      ,p_segment17                    => l_pgp_segment17
      ,p_segment18                    => l_pgp_segment18
      ,p_segment19                    => l_pgp_segment19
      ,p_segment20                    => l_pgp_segment20
      ,p_segment21                    => l_pgp_segment21
      ,p_segment22                    => l_pgp_segment22
      ,p_segment23                    => l_pgp_segment23
      ,p_segment24                    => l_pgp_segment24
      ,p_segment25                    => l_pgp_segment25
      ,p_segment26                    => l_pgp_segment26
      ,p_segment27                    => l_pgp_segment27
      ,p_segment28                    => l_pgp_segment28
      ,p_segment29                    => l_pgp_segment29
      ,p_segment30                    => l_pgp_segment30
      ,p_concat_segments_in           => l_old_group_name
      ,p_ccid                         => l_people_group_id
      ,p_concat_segments_out          => l_group_name
      );
    --
    --end if;--fix for bug 4633742.
    --
 if g_debug then
    hr_utility.set_location(l_proc, 260);
 end if;
    --
    -- update the combinations column
    --
    update_pgp_concat_segs
    (p_people_group_id        => l_people_group_id
    ,p_group_name             => l_group_name
    );
  --
  end if;
end if;--fix for bug 4633742.
  --
 if g_debug then
  hr_utility.set_location(l_proc, 270);
 end if;
  --
--
-- Start of fix for Bug 2622747
--
  validate_SCL (
   p_validate                     => FALSE -- Changed from p_validate to FALSE for fix of #3180527
  ,p_assignment_id                => p_assignment_id
  ,p_effective_date               => l_effective_date
  ,p_business_group_id            => l_business_group_id
  ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
  ,p_concatenated_segments        => l_concatenated_segments
  ,p_concat_segments              => NULL
  ,p_segment1                     => l_scl_segment1
  ,p_segment2                     => l_scl_segment2
  ,p_segment3                     => l_scl_segment3
  ,p_segment4                     => l_scl_segment4
  ,p_segment5                     => l_scl_segment5
  ,p_segment6                     => l_scl_segment6
  ,p_segment7                     => l_scl_segment7
  ,p_segment8                     => l_scl_segment8
  ,p_segment9                     => l_scl_segment9
  ,p_segment10                    => l_scl_segment10
  ,p_segment11                    => l_scl_segment11
  ,p_segment12                    => l_scl_segment12
  ,p_segment13                    => l_scl_segment13
  ,p_segment14                    => l_scl_segment14
  ,p_segment15                    => l_scl_segment15
  ,p_segment16                    => l_scl_segment16
  ,p_segment17                    => l_scl_segment17
  ,p_segment18                    => l_scl_segment18
  ,p_segment19                    => l_scl_segment19
  ,p_segment20                    => l_scl_segment20
  ,p_segment21                    => l_scl_segment21
  ,p_segment22                    => l_scl_segment22
  ,p_segment23                    => l_scl_segment23
  ,p_segment24                    => l_scl_segment24
  ,p_segment25                    => l_scl_segment25
  ,p_segment26                    => l_scl_segment26
  ,p_segment27                    => l_scl_segment27
  ,p_segment28                    => l_scl_segment28
  ,p_segment29                    => l_scl_segment29
  ,p_segment30                    => l_scl_segment30
  );
--End of fix for Bug 2622747
  --
  -- Update assignment.
  --
  per_asg_upd.upd
    (p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => l_business_group_id
    ,p_grade_id                     => p_grade_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => l_job_id -- Bug 3553286 p_job_id
    ,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_special_ceiling_step_id      => l_special_ceiling_step_id
    ,p_organization_id              => l_org_id -- Bug 3553286 p_organization_id
    ,p_people_group_id              => l_people_group_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_comment_id                   => l_comment_id
    ,p_employment_category          => p_employment_category
    ,p_payroll_id_updated           => l_payroll_id_updated
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_no_managers_warning          => l_no_managers_warning
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_validation_start_date        => l_validation_start_date
    ,p_validation_end_date          => l_validation_end_date
    ,p_object_version_number        => l_object_version_number
    ,p_effective_date               => l_effective_date
    ,p_datetrack_mode               => l_dt_update_mode
    ,p_validate                     => FALSE
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 280);
 end if;
  --
  -- add to the security lists if neccesary
  --
  open get_sec_date_range;
  fetch get_sec_date_range into l_sec_effective_start_date,
                                l_sec_effective_end_date;
  close get_sec_date_range;
  --
  if l_effective_date between l_sec_effective_start_date
  and l_sec_effective_end_date then
    if (per_asg_shd.g_old_rec.organization_id = l_business_group_id
    and l_org_id <> l_business_group_id) then  -- Bug 3553286
      hr_security_internal.clear_from_person_list
                           (per_asg_shd.g_old_rec.person_id);
    end if;
    hr_security_internal.add_to_person_list(l_effective_date,p_assignment_id);
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 290);
 end if;
  --
  -- Bug 560185 fix starts
  --
  -- Delete the SP element entry if there is one when the pay_basis
  -- changes
  --
  if (p_pay_basis_id <> hr_api.g_number or
      p_pay_basis_id is null ) and
     (nvl(p_pay_basis_id,hr_api.g_number) <>
      nvl(per_asg_shd.g_old_rec.pay_basis_id, hr_api.g_number))
  then
 -- start of bug fix 4464072
 -- commented out the following part and newly defined

  /*  open csr_get_salary;
    fetch csr_get_salary into l_element_entry_id;
    if csr_get_salary%found then
      close csr_get_salary;
      --
      hr_entry_api.delete_element_entry
        ('DELETE'
        ,l_validation_start_date - 1
        ,l_element_entry_id);
      --
      l_entries_changed_warning := 'S';
    else
       close csr_get_salary;
    end if;
  end if; */

 open csr_get_salary;
    fetch csr_get_salary into l_element_entry_id;
    if csr_get_salary%found then
      close csr_get_salary;

      open csr_chk_rec_exists;
      fetch csr_chk_rec_exists into l_element_entry_id1;

  if csr_chk_rec_exists%found then
      close csr_chk_rec_exists;

      --
      hr_entry_api.delete_element_entry
        ('DELETE'
        ,l_validation_start_date - 1
        ,l_element_entry_id);

      else

      close csr_chk_rec_exists;

       hr_entry_api.delete_element_entry
        ('ZAP'
        ,l_validation_start_date
        ,l_element_entry_id);

 end if;

      l_entries_changed_warning := 'S';
    else
       close csr_get_salary;
    end if;
  end if;
  --
  -- end of fix for bug 4464072
  --
  -- Bug 560185 fix ends
  --
  -- Maintain standard element entries for this assignment.
  --
  -- Bug 638026 fix starts
  --
  if p_payroll_id = hr_api.g_number
   then
     --
 if g_debug then
     hr_utility.set_location(l_proc, 300);
 end if;
     --
     l_new_payroll_id := per_asg_shd.g_old_rec.payroll_id;
   else
     --
 if g_debug then
     hr_utility.set_location(l_proc, 310);
 end if;
     --
     l_new_payroll_id := p_payroll_id;
   end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 320);
 end if;
  --
  hr_utility.set_location('p_old_pg_id :'||to_char(per_asg_shd.g_old_rec.payroll_id),325);
  hr_utility.set_location('p_new_pg_id :'||to_char(l_people_group_id),325);
  --
  hrentmnt.maintain_entries_asg
    (p_assignment_id                => p_assignment_id
    ,p_old_payroll_id               => per_asg_shd.g_old_rec.payroll_id
    ,p_new_payroll_id               => l_new_payroll_id
    ,p_business_group_id            => l_business_group_id
    ,p_operation                    => 'ASG_CRITERIA'
    ,p_actual_term_date             => null
    ,p_last_standard_date           => null
    ,p_final_process_date           => null
    ,p_dt_mode                      => l_new_dt_update_mode
    ,p_validation_start_date        => l_validation_start_date
    ,p_validation_end_date          => l_validation_end_date
    ,p_entries_changed              => l_entries_changed
    ,p_old_people_group_id          => per_asg_shd.g_old_rec.people_group_id
    ,p_new_people_group_id          => l_people_group_id
    );
  --
  -- Bug 630826 fix ends
  --
 if g_debug then
  hr_utility.set_location(l_proc, 330);
 end if;
  --
  if l_entries_changed_warning <> 'S' then
    l_entries_changed_warning := nvl(l_entries_changed, 'N');
  end if;
  --
  IF    (    per_asg_shd.g_old_rec.grade_id is not null
         AND p_grade_id is null)
     OR (    per_asg_shd.g_old_rec.grade_id is not null
         AND p_grade_id is not null
         AND per_asg_shd.g_old_rec.grade_id <> p_grade_id
         AND p_grade_id <> hr_api.g_number)
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 340);
 end if;
    --
    -- Maintain spinal point placements.
    --
    hr_assignment_internal.maintain_spp_asg
      (p_assignment_id                => p_assignment_id
      ,p_datetrack_mode               => l_new_dt_update_mode
      ,p_validation_start_date        => l_validation_start_date
      ,p_validation_end_date          => l_validation_end_date
      ,p_grade_id		                   => p_grade_id
      ,p_spp_delete_warning           => l_spp_delete_warning
      );
  else
    --
 if g_debug then
    hr_utility.set_location(l_proc, 350);
 end if;
    --
    -- No SPPs to maintain.
    --
    l_spp_delete_warning := FALSE;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 360);
 end if;
  --
  -- IF GB legislation and payroll has changed, then delete latest balance
  -- values,
  --
  open  csr_get_legislation_code;
  fetch csr_get_legislation_code
   into l_legislation_code;
  --
  if csr_get_legislation_code%NOTFOUND then
    --
    close csr_get_legislation_code;
    --
 if g_debug then
    hr_utility.set_location(l_proc, 370);
 end if;
    --
    -- This should never happen!
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '215');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_legislation_code;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 380);
 end if;
  --
  if  l_legislation_code = 'GB'
  and l_payroll_id_updated
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 390);
 end if;
    --
    -- Delete latest balance values.
    --
    py_gb_asg.payroll_transfer
      (p_assignment_id => p_assignment_id);
    --
    -- When GB legislation, and the business group and the payroll has changed,
    -- set the Print P45 flag on the assignments extra info flexfield, and set
    -- the changed tax district warning out parameter.
    -- This functionality will be supported at a later date.
    --
    l_tax_district_changed_warning := FALSE;
  else
    --
 if g_debug then
    hr_utility.set_location(l_proc, 400);
 end if;
    --
    l_tax_district_changed_warning := FALSE;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 410);
 end if;
  --
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_emp_asg_criteria
    --
    hr_assignment_bk3.update_emp_asg_criteria_a
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => l_dt_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_grade_id                     => p_grade_id
      ,p_position_id                  => p_position_id
      ,p_job_id                       => l_job_id -- Bug 3553286 p_job_id
      ,p_payroll_id                   => p_payroll_id
      ,p_location_id                  => p_location_id
      ,p_special_ceiling_step_id      => p_special_ceiling_step_id
      ,p_organization_id              => l_org_id -- Bug 3553286 p_organization_id
      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_segment1                     => l_pgp_segment1
      ,p_segment2                     => l_pgp_segment2
      ,p_segment3                     => l_pgp_segment3
      ,p_segment4                     => l_pgp_segment4
      ,p_segment5                     => l_pgp_segment5
      ,p_segment6                     => l_pgp_segment6
      ,p_segment7                     => l_pgp_segment7
      ,p_segment8                     => l_pgp_segment8
      ,p_segment9                     => l_pgp_segment9
      ,p_segment10                    => l_pgp_segment10
      ,p_segment11                    => l_pgp_segment11
      ,p_segment12                    => l_pgp_segment12
      ,p_segment13                    => l_pgp_segment13
      ,p_segment14                    => l_pgp_segment14
      ,p_segment15                    => l_pgp_segment15
      ,p_segment16                    => l_pgp_segment16
      ,p_segment17                    => l_pgp_segment17
      ,p_segment18                    => l_pgp_segment18
      ,p_segment19                    => l_pgp_segment19
      ,p_segment20                    => l_pgp_segment20
      ,p_segment21                    => l_pgp_segment21
      ,p_segment22                    => l_pgp_segment22
      ,p_segment23                    => l_pgp_segment23
      ,p_segment24                    => l_pgp_segment24
      ,p_segment25                    => l_pgp_segment25
      ,p_segment26                    => l_pgp_segment26
      ,p_segment27                    => l_pgp_segment27
      ,p_segment28                    => l_pgp_segment28
      ,p_segment29                    => l_pgp_segment29
      ,p_segment30                    => l_pgp_segment30
      ,p_group_name                   => l_group_name
      ,p_employment_category          => p_employment_category
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_people_group_id              => l_people_group_id
      ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_spp_delete_warning           => l_spp_delete_warning
      ,p_entries_changed_warning      => l_entries_changed_warning
      ,p_tax_district_changed_warning => l_tax_district_changed_warning
       --
       -- Bug 944911
       -- Added the new in param
       --
      ,p_concat_segments              => l_old_group_name
-- Start of Fix for Bug 2622747
      ,p_contract_id                  => p_contract_id
      ,p_establishment_id             => p_establishment_id
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_scl_segment1                 => l_scl_segment1
-- End of Fix for Bug 2622747
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EMP_ASG_CRITERIA'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_emp_asg_criteria
    --
  end;

  --
  -- call pqh post process procedure -- bug 2999562
  --
  pqh_gsp_post_process.call_pp_from_assignments(
      p_effective_date    => p_effective_date
     ,p_assignment_id     => p_assignment_id
     ,p_date_track_mode   => p_datetrack_update_mode
     ,p_warning_mesg      => l_gsp_post_process_warning
  );

  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_effective_end_date           := l_effective_end_date;
  p_effective_start_date         := l_effective_start_date;
  p_people_group_id              := l_people_group_id;
  p_group_name                   := l_group_name;
  p_entries_changed_warning      := l_entries_changed_warning;
  p_object_version_number        := l_object_version_number;
  p_org_now_no_manager_warning   := l_org_now_no_manager_warning;
  p_other_manager_warning        := l_other_manager_warning;
  p_special_ceiling_step_id      := l_special_ceiling_step_id;
  p_spp_delete_warning           := l_spp_delete_warning;
  p_tax_district_changed_warning := l_tax_district_changed_warning;
  p_gsp_post_process_warning     := l_gsp_post_process_warning; -- bug 2999562
  --
  --
  -- remove data from the session table
  hr_kflex_utility.unset_session_date
    (p_session_id     => l_session_id);
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 997);
 end if;
  --
exception
  when hr_api.validate_enabled then
    --
 if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 998);
 end if;
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_emp_asg_criteria;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_end_date           := null;
    p_effective_start_date         := null;
    p_entries_changed_warning      := l_entries_changed_warning;
    p_group_name                   := l_old_group_name;
    p_object_version_number        := p_object_version_number;
    p_org_now_no_manager_warning   := l_org_now_no_manager_warning;
    p_other_manager_warning        := l_other_manager_warning;
    p_people_group_id              := null;
    p_special_ceiling_step_id      := p_special_ceiling_step_id;
    p_spp_delete_warning           := l_spp_delete_warning;
    p_tax_district_changed_warning := l_tax_district_changed_warning;
    p_concatenated_segments        := l_concatenated_segments;
    p_soft_coding_keyflex_id       := l_soft_coding_keyflex_id;
    p_gsp_post_process_warning     := l_gsp_post_process_warning; -- bug 2999562
    --
    if l_pgp_null_ind = 0   -- bug 2359997 only re-set to null if
                            -- p_people_group_id came in as null.
    then
       p_people_group_id    := null;
    end if;
    --
  when others then
    --
 if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 999);
 end if;
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number        := lv_object_version_number ;
    p_special_ceiling_step_id      := lv_special_ceiling_step_id ;
    p_people_group_id              := lv_people_group_id ;
    p_soft_coding_keyflex_id       := lv_soft_coding_keyflex_id ;

    p_group_name                      := null;
    p_effective_start_date            := null;
    p_effective_end_date              := null;
    p_org_now_no_manager_warning      := null;
    p_other_manager_warning           := null;
    p_spp_delete_warning              := null;
    p_entries_changed_warning         := null;
    p_tax_district_changed_warning    := null;
    p_concatenated_segments           := null;
    p_gsp_post_process_warning        := null;

    ROLLBACK TO update_emp_asg_criteria;
    raise;
    --
    -- End of fix.
    --
end update_emp_asg_criteria;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_apl_asg >------------------------------|
-- ----------------------------------------------------------------------------
--
-- added new parameters notice_period, units, employee_category,
-- work_at_home and job_source on 05-OCT-01

procedure update_apl_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_recruiter_id                 in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_person_referred_by_id        in     number
  ,p_supervisor_id                in     number
  ,p_special_ceiling_step_id      in     number
  ,p_recruitment_activity_id      in     number
  ,p_source_organization_id       in     number
  ,p_organization_id              in     number
  ,p_vacancy_id                   in     number
  ,p_pay_basis_id                 in     number
  ,p_application_id               in     number
  ,p_change_reason                in     varchar2
  ,p_assignment_status_type_id    in     number
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_employment_category          in     varchar2
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_scl_segment1                 in     varchar2
  ,p_scl_segment2                 in     varchar2
  ,p_scl_segment3                 in     varchar2
  ,p_scl_segment4                 in     varchar2
  ,p_scl_segment5                 in     varchar2
  ,p_scl_segment6                 in     varchar2
  ,p_scl_segment7                 in     varchar2
  ,p_scl_segment8                 in     varchar2
  ,p_scl_segment9                 in     varchar2
  ,p_scl_segment10                in     varchar2
  ,p_scl_segment11                in     varchar2
  ,p_scl_segment12                in     varchar2
  ,p_scl_segment13                in     varchar2
  ,p_scl_segment14                in     varchar2
  ,p_scl_segment15                in     varchar2
  ,p_scl_segment16                in     varchar2
  ,p_scl_segment17                in     varchar2
  ,p_scl_segment18                in     varchar2
  ,p_scl_segment19                in     varchar2
  ,p_scl_segment20                in     varchar2
  ,p_scl_segment21                in     varchar2
  ,p_scl_segment22                in     varchar2
  ,p_scl_segment23                in     varchar2
  ,p_scl_segment24                in     varchar2
  ,p_scl_segment25                in     varchar2
  ,p_scl_segment26                in     varchar2
  ,p_scl_segment27                in     varchar2
  ,p_scl_segment28                in     varchar2
  ,p_scl_segment29                in     varchar2
  ,p_scl_segment30                in     varchar2
-- Bug 944911
-- Amended p_scl_concatenated_segments to be an out instead of in out
-- Added p_scl_concat_segments ( in param )
-- Amended p_scl_concatenated_segments to be p_concatenated_segments
  ,p_scl_concat_segments          in     varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_pgp_segment1                 in     varchar2
  ,p_pgp_segment2                 in     varchar2
  ,p_pgp_segment3                 in     varchar2
  ,p_pgp_segment4                 in     varchar2
  ,p_pgp_segment5                 in     varchar2
  ,p_pgp_segment6                 in     varchar2
  ,p_pgp_segment7                 in     varchar2
  ,p_pgp_segment8                 in     varchar2
  ,p_pgp_segment9                 in     varchar2
  ,p_pgp_segment10                in     varchar2
  ,p_pgp_segment11                in     varchar2
  ,p_pgp_segment12                in     varchar2
  ,p_pgp_segment13                in     varchar2
  ,p_pgp_segment14                in     varchar2
  ,p_pgp_segment15                in     varchar2
  ,p_pgp_segment16                in     varchar2
  ,p_pgp_segment17                in     varchar2
  ,p_pgp_segment18                in     varchar2
  ,p_pgp_segment19                in     varchar2
  ,p_pgp_segment20                in     varchar2
  ,p_pgp_segment21                in     varchar2
  ,p_pgp_segment22                in     varchar2
  ,p_pgp_segment23                in     varchar2
  ,p_pgp_segment24                in     varchar2
  ,p_pgp_segment25                in     varchar2
  ,p_pgp_segment26                in     varchar2
  ,p_pgp_segment27                in     varchar2
  ,p_pgp_segment28                in     varchar2
  ,p_pgp_segment29                in     varchar2
  ,p_pgp_segment30                in     varchar2
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
  ,p_concat_segments              in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_collective_agreement_id      in     number
  ,p_cagr_id_flex_num             in     number
  ,p_cag_segment1                 in     varchar2
  ,p_cag_segment2                 in     varchar2
  ,p_cag_segment3                 in     varchar2
  ,p_cag_segment4                 in     varchar2
  ,p_cag_segment5                 in     varchar2
  ,p_cag_segment6                 in     varchar2
  ,p_cag_segment7                 in     varchar2
  ,p_cag_segment8                 in     varchar2
  ,p_cag_segment9                 in     varchar2
  ,p_cag_segment10                in     varchar2
  ,p_cag_segment11                in     varchar2
  ,p_cag_segment12                in     varchar2
  ,p_cag_segment13                in     varchar2
  ,p_cag_segment14                in     varchar2
  ,p_cag_segment15                in     varchar2
  ,p_cag_segment16                in     varchar2
  ,p_cag_segment17                in     varchar2
  ,p_cag_segment18                in     varchar2
  ,p_cag_segment19                in     varchar2
  ,p_cag_segment20                in     varchar2
  ,p_notice_period		  in     number
  ,p_notice_period_uom	      	  in     varchar2
  ,p_employee_category	          in     varchar2
  ,p_work_at_home		  in     varchar2
  ,p_job_post_source_name	  in     varchar2
  ,p_posting_content_id           in     number
  ,p_applicant_rank               in     number
  ,p_grade_ladder_pgm_id          in     number
  ,p_supervisor_assignment_id     in     number
  ,p_cagr_grade_def_id            in out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_comment_id                      out nocopy number
  ,p_people_group_id              in out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
 ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_comment_id                 per_all_assignments_f.comment_id%TYPE;
  l_business_group_id          per_all_assignments_f.business_group_id%TYPE;
  l_effective_start_date       per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date         per_all_assignments_f.effective_end_date%TYPE;
  l_dummy_payroll              boolean;
  l_dummy_manager1             boolean;
  l_dummy_manager2             boolean;
  l_dummy_manager3             boolean;
  l_hourly_salaried_warning    boolean;
  l_validation_start_date      per_all_assignments_f.effective_start_date%TYPE;
  l_validation_end_date        per_all_assignments_f.effective_end_date%TYPE;
  l_object_version_number      per_all_assignments_f.object_version_number%TYPE;
  l_effective_date             date;
  l_date_probation_end         date;
  l_flex_num                   fnd_id_flex_segments.id_flex_num%TYPE;
  l_organization_id            per_all_assignments_f.organization_id%type;
  l_location_id                per_all_assignments_f.location_id%type;
  l_cagr_grade_def_id          per_cagr_grades_def.cagr_grade_def_id%TYPE         := p_cagr_grade_def_id;
  l_cagr_id_flex_num           per_cagr_grades_def.id_flex_num%TYPE;
  l_unused_start_date          date;
  l_unused_end_date            date;
  l_cagr_concatenated_segments varchar2(2000);
  --
  -- Internal working variables
  --
  l_assignment_status_id       number;
  l_asg_status_ovn             number;
  --
  l_people_group_id            per_all_assignments_f.people_group_id%TYPE         := p_people_group_id;
  l_group_name                 pay_people_groups.group_name%TYPE;
  l_old_group_name             pay_people_groups.group_name%TYPE;
  l_soft_coding_keyflex_id     per_all_assignments_f.soft_coding_keyflex_id%TYPE  := p_soft_coding_keyflex_id;
  l_scl_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE  ;
  l_old_scl_conc_segments hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_proc                       varchar2(72) := g_package||'update_apl_asg';
  l_api_updating               boolean;
  l_session_id                 number;
  l_old_asg_status per_assignment_status_types.per_system_status%type;
  l_new_asg_status per_assignment_status_types.per_system_status%type;
  --
  -- bug 2230915 new variables to indicate whether key flex id parameters
  -- enter the program with a value.
  --
  l_pgp_null_ind               number(1) := 0;
  l_scl_null_ind               number(1) := 0;
  l_cag_null_ind               number(1) := 0;
  --
  -- bug 2230915 new variables for derived values where key flex id is known.
  --
  l_scl_segment1               varchar2(60) := p_scl_segment1;
  l_scl_segment2               varchar2(60) := p_scl_segment2;
  l_scl_segment3               varchar2(60) := p_scl_segment3;
  l_scl_segment4               varchar2(60) := p_scl_segment4;
  l_scl_segment5               varchar2(60) := p_scl_segment5;
  l_scl_segment6               varchar2(60) := p_scl_segment6;
  l_scl_segment7               varchar2(60) := p_scl_segment7;
  l_scl_segment8               varchar2(60) := p_scl_segment8;
  l_scl_segment9               varchar2(60) := p_scl_segment9;
  l_scl_segment10              varchar2(60) := p_scl_segment10;
  l_scl_segment11              varchar2(60) := p_scl_segment11;
  l_scl_segment12              varchar2(60) := p_scl_segment12;
  l_scl_segment13              varchar2(60) := p_scl_segment13;
  l_scl_segment14              varchar2(60) := p_scl_segment14;
  l_scl_segment15              varchar2(60) := p_scl_segment15;
  l_scl_segment16              varchar2(60) := p_scl_segment16;
  l_scl_segment17              varchar2(60) := p_scl_segment17;
  l_scl_segment18              varchar2(60) := p_scl_segment18;
  l_scl_segment19              varchar2(60) := p_scl_segment19;
  l_scl_segment20              varchar2(60) := p_scl_segment20;
  l_scl_segment21              varchar2(60) := p_scl_segment21;
  l_scl_segment22              varchar2(60) := p_scl_segment22;
  l_scl_segment23              varchar2(60) := p_scl_segment23;
  l_scl_segment24              varchar2(60) := p_scl_segment24;
  l_scl_segment25              varchar2(60) := p_scl_segment25;
  l_scl_segment26              varchar2(60) := p_scl_segment26;
  l_scl_segment27              varchar2(60) := p_scl_segment27;
  l_scl_segment28              varchar2(60) := p_scl_segment28;
  l_scl_segment29              varchar2(60) := p_scl_segment29;
  l_scl_segment30              varchar2(60) := p_scl_segment30;
  --
  l_pgp_segment1               varchar2(60) := p_pgp_segment1;
  l_pgp_segment2               varchar2(60) := p_pgp_segment2;
  l_pgp_segment3               varchar2(60) := p_pgp_segment3;
  l_pgp_segment4               varchar2(60) := p_pgp_segment4;
  l_pgp_segment5               varchar2(60) := p_pgp_segment5;
  l_pgp_segment6               varchar2(60) := p_pgp_segment6;
  l_pgp_segment7               varchar2(60) := p_pgp_segment7;
  l_pgp_segment8               varchar2(60) := p_pgp_segment8;
  l_pgp_segment9               varchar2(60) := p_pgp_segment9;
  l_pgp_segment10              varchar2(60) := p_pgp_segment10;
  l_pgp_segment11              varchar2(60) := p_pgp_segment11;
  l_pgp_segment12              varchar2(60) := p_pgp_segment12;
  l_pgp_segment13              varchar2(60) := p_pgp_segment13;
  l_pgp_segment14              varchar2(60) := p_pgp_segment14;
  l_pgp_segment15              varchar2(60) := p_pgp_segment15;
  l_pgp_segment16              varchar2(60) := p_pgp_segment16;
  l_pgp_segment17              varchar2(60) := p_pgp_segment17;
  l_pgp_segment18              varchar2(60) := p_pgp_segment18;
  l_pgp_segment19              varchar2(60) := p_pgp_segment19;
  l_pgp_segment20              varchar2(60) := p_pgp_segment20;
  l_pgp_segment21              varchar2(60) := p_pgp_segment21;
  l_pgp_segment22              varchar2(60) := p_pgp_segment22;
  l_pgp_segment23              varchar2(60) := p_pgp_segment23;
  l_pgp_segment24              varchar2(60) := p_pgp_segment24;
  l_pgp_segment25              varchar2(60) := p_pgp_segment25;
  l_pgp_segment26              varchar2(60) := p_pgp_segment26;
  l_pgp_segment27              varchar2(60) := p_pgp_segment27;
  l_pgp_segment28              varchar2(60) := p_pgp_segment28;
  l_pgp_segment29              varchar2(60) := p_pgp_segment29;
  l_pgp_segment30              varchar2(60) := p_pgp_segment30;
  --
  l_cag_segment1               varchar2(60) := p_cag_segment1;
  l_cag_segment2               varchar2(60) := p_cag_segment2;
  l_cag_segment3               varchar2(60) := p_cag_segment3;
  l_cag_segment4               varchar2(60) := p_cag_segment4;
  l_cag_segment5               varchar2(60) := p_cag_segment5;
  l_cag_segment6               varchar2(60) := p_cag_segment6;
  l_cag_segment7               varchar2(60) := p_cag_segment7;
  l_cag_segment8               varchar2(60) := p_cag_segment8;
  l_cag_segment9               varchar2(60) := p_cag_segment9;
  l_cag_segment10              varchar2(60) := p_cag_segment10;
  l_cag_segment11              varchar2(60) := p_cag_segment11;
  l_cag_segment12              varchar2(60) := p_cag_segment12;
  l_cag_segment13              varchar2(60) := p_cag_segment13;
  l_cag_segment14              varchar2(60) := p_cag_segment14;
  l_cag_segment15              varchar2(60) := p_cag_segment15;
  l_cag_segment16              varchar2(60) := p_cag_segment16;
  l_cag_segment17              varchar2(60) := p_cag_segment17;
  l_cag_segment18              varchar2(60) := p_cag_segment18;
  l_cag_segment19              varchar2(60) := p_cag_segment19;
  l_cag_segment20              varchar2(60) := p_cag_segment20;
  --
  lv_object_version_number     number := p_object_version_number ;
  lv_cagr_grade_def_id         number := p_cagr_grade_def_id ;
  lv_people_group_id           number := p_people_group_id ;
  lv_soft_coding_keyflex_id    number := p_soft_coding_keyflex_id ;

  --
  cursor csr_old_asg_status is
  select ast.per_system_status
  from per_assignment_status_types ast,
       per_all_assignments_f asg
  where ast.assignment_status_type_id = asg.assignment_status_type_id
  and   asg.assignment_id = p_assignment_id
  and   l_effective_date between asg.effective_start_date and asg.effective_end_date;
  --
  cursor csr_new_asg_status is
  select ast.per_system_status
  from per_assignment_status_types ast
  where ast.assignment_status_type_id = p_assignment_status_type_id;
  --
  --
  cursor csr_grp_idsel is
    select bus.people_group_structure
     from  per_business_groups_perf bus
     where bus.business_group_id = l_business_group_id;
  --
  cursor csr_scl_idsel is
    select plr.rule_mode                       id_flex_num
    from   pay_legislation_rules               plr,
           per_business_groups_perf            pgr
    where  plr.legislation_code                = pgr.legislation_code
    and    pgr.business_group_id               = l_business_group_id
    and    plr.rule_type                       = 'S'
    and    exists
          (select 1
           from   fnd_segment_attribute_values fsav
           where  fsav.id_flex_num             = plr.rule_mode
           and    fsav.application_id          = 800
           and    fsav.id_flex_code            = 'SCL'
           and    fsav.segment_attribute_type  = 'ASSIGNMENT'
           and    fsav.attribute_value         = 'Y')
    and    exists
          (select 1
           from   pay_legislation_rules        plr2
           where  plr2.legislation_code        = plr.legislation_code
           and    plr2.rule_type               = 'SDL'
           and    plr2.rule_mode               = 'A') ;
  --
  cursor get_sec_date_range is
     select asg.effective_start_date
     ,      asg.effective_end_date
     from   per_all_assignments_f asg
     where  asg.assignment_id=p_assignment_id
     and   ((sysdate between asg.effective_start_date
            and asg.effective_end_date)
            or
           (sysdate<asg.effective_start_date
            and not exists
            (select 1
             from per_all_assignments_f asg2
             where asg2.person_id=asg.person_id
             and asg2.application_id=asg.application_id
             and asg2.effective_start_date<asg.effective_start_date)
             )
            );
  --
  l_sec_effective_start_date date;
  l_sec_effective_end_date date;
  --
  -- bug 2230915 get pay_people_group segment values where
  -- people_group_id is known
  --
  cursor c_pgp_segments is
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
     from   pay_people_groups
     where  people_group_id = l_people_group_id;
  --
  -- bug 2230915 get hr_soft_coding_keyflex segment values where
  -- soft_coding_keyflex_id is known
  --
  cursor c_scl_segments is
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
     from   hr_soft_coding_keyflex
     where  soft_coding_keyflex_id = l_soft_coding_keyflex_id;
  --
  -- bug 2230915 get per_cagr_grades_def segment values where
  -- cagr_grade_def_id is known
  --
  cursor c_cag_segments is
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
            segment20
     from   per_cagr_grades_def
     where  cagr_grade_def_id = l_cagr_grade_def_id;
--
-- fix for bug 5938120 starts here.
l_assignment_id          per_all_assignments_f.assignment_id%TYPE;

cursor csr_get_assign(csr_person_id number) is
select assignment_id
from per_all_assignments_f
where person_id=csr_person_id
and business_group_id=l_business_group_id
and l_effective_date between effective_start_date and effective_end_date
and assignment_type not in ('B','O'); -- added for the bug 6925339
-- fix for bug 5938120 ends here.
--
begin
--
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  --Truncate the parameter p_effective_date to a local variable
  --
  l_effective_date       := trunc(p_effective_date);
  l_date_probation_end   := trunc(p_date_probation_end);
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
-- Replaced p_group_name by p_concat_segments
  l_old_group_name       := p_concat_segments;
-- Bug 944911
-- Amended p_scl_concatenated_segments to p_scl_concat_segments
  l_old_scl_conc_segments := p_scl_concat_segments;
  --
  -- Issue a savepoint.
  --
  savepoint update_apl_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  l_object_version_number := p_object_version_number;
  --
  -- Validation in addition to Table Handlers
  --
  -- Check mandatory arguments
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_assignment_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => l_effective_date);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_update_mode'
    ,p_argument_value => p_datetrack_update_mode);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'object_version_number'
    ,p_argument_value => l_object_version_number);
  --
  -- Retrieve current assignment details from database.
  --
  l_api_updating := per_asg_shd.api_updating
    (p_assignment_id         => p_assignment_id
    ,p_effective_date        => l_effective_date
    ,p_object_version_number => l_object_version_number);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  if not l_api_updating
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    -- As this is an updating API, the assignment should already exist.
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  -- Populate l_business_group_id from g_old_rec for cursor csr_grp_idsel
  -- Populate l_people_group_id from g_old_rec for upd_or_sel_key_flex
  -- 2230915 only populate l_people_group_id from g_old_rec
  -- if p_people_group_id did not enter with a value.  If it did enter with
  -- a value then get segment values from pay_people_groups.
  -- Do the same with the key flex ids for hr_soft_coding_keyflex and
  -- per_cagr_grades_def
  --
  l_business_group_id := per_asg_shd.g_old_rec.business_group_id;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 45);
 end if;
  --
  if l_people_group_id is null
  then
    --
    l_people_group_id := per_asg_shd.g_old_rec.people_group_id;
    l_pgp_null_ind := 0;
  else
    -- get segment values
    open c_pgp_segments;
      fetch c_pgp_segments into l_pgp_segment1,
                                l_pgp_segment2,
                                l_pgp_segment3,
                                l_pgp_segment4,
                                l_pgp_segment5,
                                l_pgp_segment6,
                                l_pgp_segment7,
                                l_pgp_segment8,
                                l_pgp_segment9,
                                l_pgp_segment10,
                                l_pgp_segment11,
                                l_pgp_segment12,
                                l_pgp_segment13,
                                l_pgp_segment14,
                                l_pgp_segment15,
                                l_pgp_segment16,
                                l_pgp_segment17,
                                l_pgp_segment18,
                                l_pgp_segment19,
                                l_pgp_segment20,
                                l_pgp_segment21,
                                l_pgp_segment22,
                                l_pgp_segment23,
                                l_pgp_segment24,
                                l_pgp_segment25,
                                l_pgp_segment26,
                                l_pgp_segment27,
                                l_pgp_segment28,
                                l_pgp_segment29,
                                l_pgp_segment30;
    close c_pgp_segments;
  end if;
  --  use cursor c_scl_segments to bring back segment values if
  --  l_soft_coding_keyflex_id has a value.
  if l_soft_coding_keyflex_id is not null
  then
    l_scl_null_ind := 1;
    open c_scl_segments;
      fetch c_scl_segments into l_scl_segment1,
                               l_scl_segment2,
                               l_scl_segment3,
                               l_scl_segment4,
                               l_scl_segment5,
                               l_scl_segment6,
                               l_scl_segment7,
                               l_scl_segment8,
                               l_scl_segment9,
                               l_scl_segment10,
                               l_scl_segment11,
                               l_scl_segment12,
                               l_scl_segment13,
                               l_scl_segment14,
                               l_scl_segment15,
                               l_scl_segment16,
                               l_scl_segment17,
                               l_scl_segment18,
                               l_scl_segment19,
                               l_scl_segment20,
                               l_scl_segment21,
                               l_scl_segment22,
                               l_scl_segment23,
                               l_scl_segment24,
                               l_scl_segment25,
                               l_scl_segment26,
                               l_scl_segment27,
                               l_scl_segment28,
                               l_scl_segment29,
                               l_scl_segment30;
    close c_scl_segments;
  else
    l_scl_null_ind := 0;
  end if;
  --
  -- if cagr_grade_def_id has a value then use it to get segment values using
  -- cursor cag_segments
  --
  if l_cagr_grade_def_id is not null
  then
    l_cag_null_ind := 1;
    open c_cag_segments;
      fetch c_cag_segments into l_cag_segment1,
                                l_cag_segment2,
                                l_cag_segment3,
                                l_cag_segment4,
                                l_cag_segment5,
                                l_cag_segment6,
                                l_cag_segment7,
                                l_cag_segment8,
                                l_cag_segment9,
                                l_cag_segment10,
                                l_cag_segment11,
                                l_cag_segment12,
                                l_cag_segment13,
                                l_cag_segment14,
                                l_cag_segment15,
                                l_cag_segment16,
                                l_cag_segment17,
                                l_cag_segment18,
                                l_cag_segment19,
                                l_cag_segment20;
    close c_cag_segments;
  else
    l_cag_null_ind := 0;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 60);
 end if;
  --
  -- Check that the assignment is an applicant assignment.
  --
  if per_asg_shd.g_old_rec.assignment_type <> 'A'
  then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 70);
 end if;
    --
    hr_utility.set_message(801, 'HR_51036_ASG_ASG_NOT_APL');
    hr_utility.raise_error;
  end if;
  --
  -- Start of API User Hook for the before hook of update_apl_asg.
  --
  begin
      hr_assignment_bk5.update_apl_asg_b
       (p_effective_date               =>     l_effective_date
       ,p_datetrack_update_mode        =>     p_datetrack_update_mode
       ,p_assignment_id                =>     p_assignment_id
       ,p_object_version_number        =>     p_object_version_number
       ,p_grade_id                     =>     p_grade_id
       ,p_job_id                       =>     p_job_id
       ,p_payroll_id                   =>     p_payroll_id
       ,p_location_id                  =>     p_location_id
       ,p_organization_id              =>     p_organization_id
       ,p_position_id                  =>     p_position_id
       ,p_application_id               =>     p_application_id
       ,p_special_ceiling_step_id      =>     p_special_ceiling_step_id
       ,p_recruiter_id                 =>     p_recruiter_id
       ,p_recruitment_activity_id      =>     p_recruitment_activity_id
       ,p_vacancy_id                   =>     p_vacancy_id
       ,p_pay_basis_id                 =>     p_pay_basis_id
       ,p_person_referred_by_id        =>     p_person_referred_by_id
       ,p_supervisor_id                =>     p_supervisor_id
       ,p_source_organization_id       =>     p_source_organization_id
       ,p_change_reason                =>     p_change_reason
       ,p_assignment_status_type_id    =>     p_assignment_status_type_id
       ,p_internal_address_line        =>     p_internal_address_line
       ,p_default_code_comb_id         =>     p_default_code_comb_id
       ,p_employment_category          =>     p_employment_category
       ,p_frequency                    =>     p_frequency
       ,p_manager_flag                 =>     p_manager_flag
       ,p_normal_hours                 =>     p_normal_hours
       ,p_perf_review_period           =>     p_perf_review_period
       ,p_perf_review_period_frequency =>     p_perf_review_period_frequency
       ,p_probation_period             =>     p_probation_period
       ,p_probation_unit               =>     p_probation_unit
       ,p_sal_review_period            =>     p_sal_review_period
       ,p_sal_review_period_frequency  =>     p_sal_review_period_frequency
       ,p_set_of_books_id              =>     p_set_of_books_id
       ,p_source_type                  =>     p_source_type
       ,p_time_normal_finish           =>     p_time_normal_finish
       ,p_time_normal_start            =>     p_time_normal_start
       ,p_bargaining_unit_code         =>     p_bargaining_unit_code
       ,p_comments                     =>     p_comments
       ,p_date_probation_end           =>     l_date_probation_end
       ,p_title                        =>     p_title
       ,p_ass_attribute_category       =>     p_ass_attribute_category
       ,p_ass_attribute1               =>     p_ass_attribute1
       ,p_ass_attribute2               =>     p_ass_attribute2
       ,p_ass_attribute3               =>     p_ass_attribute3
       ,p_ass_attribute4               =>     p_ass_attribute4
       ,p_ass_attribute5               =>     p_ass_attribute5
       ,p_ass_attribute6               =>     p_ass_attribute6
       ,p_ass_attribute7               =>     p_ass_attribute7
       ,p_ass_attribute8               =>     p_ass_attribute8
       ,p_ass_attribute9               =>     p_ass_attribute9
       ,p_ass_attribute10              =>     p_ass_attribute10
       ,p_ass_attribute11              =>     p_ass_attribute11
       ,p_ass_attribute12              =>     p_ass_attribute12
       ,p_ass_attribute13              =>     p_ass_attribute13
       ,p_ass_attribute14              =>     p_ass_attribute14
       ,p_ass_attribute15              =>     p_ass_attribute15
       ,p_ass_attribute16              =>     p_ass_attribute16
       ,p_ass_attribute17              =>     p_ass_attribute17
       ,p_ass_attribute18              =>     p_ass_attribute18
       ,p_ass_attribute19              =>     p_ass_attribute19
       ,p_ass_attribute20              =>     p_ass_attribute20
       ,p_ass_attribute21              =>     p_ass_attribute21
       ,p_ass_attribute22              =>     p_ass_attribute22
       ,p_ass_attribute23              =>     p_ass_attribute23
       ,p_ass_attribute24              =>     p_ass_attribute24
       ,p_ass_attribute25              =>     p_ass_attribute25
       ,p_ass_attribute26              =>     p_ass_attribute26
       ,p_ass_attribute27              =>     p_ass_attribute27
       ,p_ass_attribute28              =>     p_ass_attribute28
       ,p_ass_attribute29              =>     p_ass_attribute29
       ,p_ass_attribute30              =>     p_ass_attribute30
       ,p_scl_segment1                 =>     l_scl_segment1
       ,p_scl_segment2                 =>     l_scl_segment2
       ,p_scl_segment3                 =>     l_scl_segment3
       ,p_scl_segment4                 =>     l_scl_segment4
       ,p_scl_segment5                 =>     l_scl_segment5
       ,p_scl_segment6                 =>     l_scl_segment6
       ,p_scl_segment7                 =>     l_scl_segment7
       ,p_scl_segment8                 =>     l_scl_segment8
       ,p_scl_segment9                 =>     l_scl_segment9
       ,p_scl_segment10                =>     l_scl_segment10
       ,p_scl_segment11                =>     l_scl_segment11
       ,p_scl_segment12                =>     l_scl_segment12
       ,p_scl_segment13                =>     l_scl_segment13
       ,p_scl_segment14                =>     l_scl_segment14
       ,p_scl_segment15                =>     l_scl_segment15
       ,p_scl_segment16                =>     l_scl_segment16
       ,p_scl_segment17                =>     l_scl_segment17
       ,p_scl_segment18                =>     l_scl_segment18
       ,p_scl_segment19                =>     l_scl_segment19
       ,p_scl_segment20                =>     l_scl_segment20
       ,p_scl_segment21                =>     l_scl_segment21
       ,p_scl_segment22                =>     l_scl_segment22
       ,p_scl_segment23                =>     l_scl_segment23
       ,p_scl_segment24                =>     l_scl_segment24
       ,p_scl_segment25                =>     l_scl_segment25
       ,p_scl_segment26                =>     l_scl_segment26
       ,p_scl_segment27                =>     l_scl_segment27
       ,p_scl_segment28                =>     l_scl_segment28
       ,p_scl_segment29                =>     l_scl_segment29
       ,p_scl_segment30                =>     l_scl_segment30
-- Bug 944911
-- Amended p_scl_concatenated_segments to be p_scl_concat_segments
       ,p_scl_concat_segments          =>     l_old_scl_conc_segments
       ,p_pgp_segment1                 =>     l_pgp_segment1
       ,p_pgp_segment2                 =>     l_pgp_segment2
       ,p_pgp_segment3                 =>     l_pgp_segment3
       ,p_pgp_segment4                 =>     l_pgp_segment4
       ,p_pgp_segment5                 =>     l_pgp_segment5
       ,p_pgp_segment6                 =>     l_pgp_segment6
       ,p_pgp_segment7                 =>     l_pgp_segment7
       ,p_pgp_segment8                 =>     l_pgp_segment8
       ,p_pgp_segment9                 =>     l_pgp_segment9
       ,p_pgp_segment10                =>     l_pgp_segment10
       ,p_pgp_segment11                =>     l_pgp_segment11
       ,p_pgp_segment12                =>     l_pgp_segment12
       ,p_pgp_segment13                =>     l_pgp_segment13
       ,p_pgp_segment14                =>     l_pgp_segment14
       ,p_pgp_segment15                =>     l_pgp_segment15
       ,p_pgp_segment16                =>     l_pgp_segment16
       ,p_pgp_segment17                =>     l_pgp_segment17
       ,p_pgp_segment18                =>     l_pgp_segment18
       ,p_pgp_segment19                =>     l_pgp_segment19
       ,p_pgp_segment20                =>     l_pgp_segment20
       ,p_pgp_segment21                =>     l_pgp_segment21
       ,p_pgp_segment22                =>     l_pgp_segment22
       ,p_pgp_segment23                =>     l_pgp_segment23
       ,p_pgp_segment24                =>     l_pgp_segment24
       ,p_pgp_segment25                =>     l_pgp_segment25
       ,p_pgp_segment26                =>     l_pgp_segment26
       ,p_pgp_segment27                =>     l_pgp_segment27
       ,p_pgp_segment28                =>     l_pgp_segment28
       ,p_pgp_segment29                =>     l_pgp_segment29
       ,p_pgp_segment30                =>     l_pgp_segment30
       ,p_contract_id                  =>     p_contract_id
       ,p_establishment_id             =>     p_establishment_id
       ,p_collective_agreement_id      =>     p_collective_agreement_id
       ,p_cagr_id_flex_num             =>     p_cagr_id_flex_num
       ,p_cag_segment1                 =>     l_cag_segment1
       ,p_cag_segment2                 =>     l_cag_segment2
       ,p_cag_segment3                 =>     l_cag_segment3
       ,p_cag_segment4                 =>     l_cag_segment4
       ,p_cag_segment5                 =>     l_cag_segment5
       ,p_cag_segment6                 =>     l_cag_segment6
       ,p_cag_segment7                 =>     l_cag_segment7
       ,p_cag_segment8                 =>     l_cag_segment8
       ,p_cag_segment9                 =>     l_cag_segment9
       ,p_cag_segment10                =>     l_cag_segment10
       ,p_cag_segment11                =>     l_cag_segment11
       ,p_cag_segment12                =>     l_cag_segment12
       ,p_cag_segment13                =>     l_cag_segment13
       ,p_cag_segment14                =>     l_cag_segment14
       ,p_cag_segment15                =>     l_cag_segment15
       ,p_cag_segment16                =>     l_cag_segment16
       ,p_cag_segment17                =>     l_cag_segment17
       ,p_cag_segment18                =>     l_cag_segment18
       ,p_cag_segment19                =>     l_cag_segment19
       ,p_cag_segment20                =>     l_cag_segment20
       ,p_notice_period		       =>     p_notice_period
       ,p_notice_period_uom	       =>     p_notice_period_uom
       ,p_employee_category	       =>     p_employee_category
       ,p_work_at_home		       =>     p_work_at_home
       ,p_job_post_source_name	       =>     p_job_post_source_name
       ,p_posting_content_id           =>     p_posting_content_id
       ,p_applicant_rank               =>     p_applicant_rank

-- Bug 944911
-- Amended p_group_name to p_concat_segments
       ,p_concat_segments              =>     l_old_group_name
       ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
       ,p_supervisor_assignment_id     => p_supervisor_assignment_id
 );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_APL_ASG',
          p_hook_type         => 'BP'
         );
  end;
  --
  --
 if g_debug then
  hr_utility.set_location(l_proc, 80);
 end if;
  --
  --added validation for bug 1867720
  --
  if p_assignment_status_type_id <> hr_api.g_number then
    open csr_old_asg_status;
    fetch csr_old_asg_status into l_old_asg_status;
    close csr_old_asg_status;
    --
    open csr_new_asg_status;
    fetch csr_new_asg_status into l_new_asg_status;
      if csr_new_asg_status%notfound
        OR (csr_new_asg_status%found AND l_old_asg_status <> l_new_asg_status)
      then
       fnd_message.set_name('PER','HR_7949_ASG_DIF_SYSTEM_TYPE');
       fnd_message.set_token('SYSTYPE',l_old_asg_status);
       fnd_message.raise_error;
      end if;
    close csr_new_asg_status;
  end if;
  --
  --
  -- insert the profile options and effective date for the flexfield
  -- validation to work
  --
  if (p_organization_id=hr_api.g_number) then
    l_organization_id:=per_asg_shd.g_old_rec.organization_id;
  else
    l_organization_id:=p_organization_id;
  end if;
  --
  if (p_location_id=hr_api.g_number) then
    l_location_id:=per_asg_shd.g_old_rec.location_id;
  else
    l_location_id:=p_location_id;
  end if;
  --
  hr_kflex_utility.set_profiles
  (p_business_group_id => l_business_group_id
  ,p_assignment_id     => p_assignment_id
  ,p_organization_id   => l_organization_id
  ,p_location_id       => l_location_id);
  --
  hr_kflex_utility.set_session_date
  (p_effective_date => l_effective_date
  ,p_session_id     => l_session_id);
  --
  -- Maintain the people group key flexfields.
  --
  open csr_grp_idsel;
  fetch csr_grp_idsel
  into l_flex_num;
     if csr_grp_idsel%NOTFOUND then
       close csr_grp_idsel;
          hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE', l_proc);
          hr_utility.set_message_token('STEP','10');
          hr_utility.raise_error;
     end if;
  close csr_grp_idsel;
  --
  if l_pgp_null_ind = 0
  then
    hr_kflex_utility.upd_or_sel_keyflex_comb
      (p_appl_short_name        => 'PAY'
      ,p_flex_code              => 'GRP'
      ,p_flex_num               => l_flex_num
      ,p_segment1               => l_pgp_segment1
      ,p_segment2               => l_pgp_segment2
      ,p_segment3               => l_pgp_segment3
      ,p_segment4               => l_pgp_segment4
      ,p_segment5               => l_pgp_segment5
      ,p_segment6               => l_pgp_segment6
      ,p_segment7               => l_pgp_segment7
      ,p_segment8               => l_pgp_segment8
      ,p_segment9               => l_pgp_segment9
      ,p_segment10              => l_pgp_segment10
      ,p_segment11              => l_pgp_segment11
      ,p_segment12              => l_pgp_segment12
      ,p_segment13              => l_pgp_segment13
      ,p_segment14              => l_pgp_segment14
      ,p_segment15              => l_pgp_segment15
      ,p_segment16              => l_pgp_segment16
      ,p_segment17              => l_pgp_segment17
      ,p_segment18              => l_pgp_segment18
      ,p_segment19              => l_pgp_segment19
      ,p_segment20              => l_pgp_segment20
      ,p_segment21              => l_pgp_segment21
      ,p_segment22              => l_pgp_segment22
      ,p_segment23              => l_pgp_segment23
      ,p_segment24              => l_pgp_segment24
      ,p_segment25              => l_pgp_segment25
      ,p_segment26              => l_pgp_segment26
      ,p_segment27              => l_pgp_segment27
      ,p_segment28              => l_pgp_segment28
      ,p_segment29              => l_pgp_segment29
      ,p_segment30              => l_pgp_segment30
      ,p_concat_segments_in     => l_old_group_name
      ,p_ccid                   => l_people_group_id
      ,p_concat_segments_out    => l_group_name
      );
  end if;
  --
  -- update the combinations column
  --
  update_pgp_concat_segs
    (p_people_group_id        => l_people_group_id
    ,p_group_name             => l_group_name
  );
  --
  -- Update or select the soft_coding_keyflex_id
  --
  if l_soft_coding_keyflex_id is null
  then
     if   l_scl_segment1 <> hr_api.g_varchar2
       or l_scl_segment2 <> hr_api.g_varchar2
       or l_scl_segment3 <> hr_api.g_varchar2
       or l_scl_segment4 <> hr_api.g_varchar2
       or l_scl_segment5 <> hr_api.g_varchar2
       or l_scl_segment6 <> hr_api.g_varchar2
       or l_scl_segment7 <> hr_api.g_varchar2
       or l_scl_segment8 <> hr_api.g_varchar2
       or l_scl_segment9 <> hr_api.g_varchar2
       or l_scl_segment10 <> hr_api.g_varchar2
       or l_scl_segment11 <> hr_api.g_varchar2
       or l_scl_segment12 <> hr_api.g_varchar2
       or l_scl_segment13 <> hr_api.g_varchar2
       or l_scl_segment14 <> hr_api.g_varchar2
       or l_scl_segment15 <> hr_api.g_varchar2
       or l_scl_segment16 <> hr_api.g_varchar2
       or l_scl_segment17 <> hr_api.g_varchar2
       or l_scl_segment18 <> hr_api.g_varchar2
       or l_scl_segment19 <> hr_api.g_varchar2
       or l_scl_segment20 <> hr_api.g_varchar2
       or l_scl_segment21 <> hr_api.g_varchar2
       or l_scl_segment22 <> hr_api.g_varchar2
       or l_scl_segment23 <> hr_api.g_varchar2
       or l_scl_segment24 <> hr_api.g_varchar2
       or l_scl_segment25 <> hr_api.g_varchar2
       or l_scl_segment26 <> hr_api.g_varchar2
       or l_scl_segment27 <> hr_api.g_varchar2
       or l_scl_segment28 <> hr_api.g_varchar2
       or l_scl_segment29 <> hr_api.g_varchar2
       or l_scl_segment30 <> hr_api.g_varchar2
       --
       -- Bug 944911
       -- Added this additional check
       or p_scl_concat_segments <> hr_api.g_varchar2
     then
       -- gets flex num id from pay_legislation_rules and
       -- per_business_groups_perf
       --
       open csr_scl_idsel;
       fetch csr_scl_idsel into l_flex_num;
       --
       if csr_scl_idsel%NOTFOUND
       then
          close csr_scl_idsel;
          if   l_scl_segment1 is not null
            or l_scl_segment2 is not null
            or l_scl_segment3 is not null
            or l_scl_segment4 is not null
            or l_scl_segment5 is not null
            or l_scl_segment6 is not null
            or l_scl_segment7 is not null
            or l_scl_segment8 is not null
            or l_scl_segment9 is not null
            or l_scl_segment10 is not null
            or l_scl_segment11 is not null
            or l_scl_segment12 is not null
            or l_scl_segment13 is not null
            or l_scl_segment14 is not null
            or l_scl_segment15 is not null
            or l_scl_segment16 is not null
            or l_scl_segment17 is not null
            or l_scl_segment18 is not null
            or l_scl_segment19 is not null
            or l_scl_segment20 is not null
            or l_scl_segment21 is not null
            or l_scl_segment22 is not null
            or l_scl_segment23 is not null
            or l_scl_segment24 is not null
            or l_scl_segment25 is not null
            or l_scl_segment26 is not null
            or l_scl_segment27 is not null
            or l_scl_segment28 is not null
            or l_scl_segment29 is not null
            or l_scl_segment30 is not null
            --
            -- Bug 944911
            -- Added this additional check
            or p_scl_concat_segments is not null
          then
             hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE', l_proc);
             hr_utility.set_message_token('STEP','5');
             hr_utility.raise_error;
          end if;  -- p_scl_segment1 is not null
       else -- csr_scl_idsel is found
          close csr_scl_idsel;
          --
          -- Process Logic
          --
          --
          -- Update or select the soft_coding_keyflex_id
          --
          hr_kflex_utility.upd_or_sel_keyflex_comb
            (p_appl_short_name        => 'PER'
            ,p_flex_code              => 'SCL'
            ,p_flex_num               => l_flex_num
            ,p_segment1               => l_scl_segment1
            ,p_segment2               => l_scl_segment2
            ,p_segment3               => l_scl_segment3
            ,p_segment4               => l_scl_segment4
            ,p_segment5               => l_scl_segment5
            ,p_segment6               => l_scl_segment6
            ,p_segment7               => l_scl_segment7
            ,p_segment8               => l_scl_segment8
            ,p_segment9               => l_scl_segment9
            ,p_segment10              => l_scl_segment10
            ,p_segment11              => l_scl_segment11
            ,p_segment12              => l_scl_segment12
            ,p_segment13              => l_scl_segment13
            ,p_segment14              => l_scl_segment14
            ,p_segment15              => l_scl_segment15
            ,p_segment16              => l_scl_segment16
            ,p_segment17              => l_scl_segment17
            ,p_segment18              => l_scl_segment18
            ,p_segment19              => l_scl_segment19
            ,p_segment20              => l_scl_segment20
            ,p_segment21              => l_scl_segment21
            ,p_segment22              => l_scl_segment22
            ,p_segment23              => l_scl_segment23
            ,p_segment24              => l_scl_segment24
            ,p_segment25              => l_scl_segment25
            ,p_segment26              => l_scl_segment26
            ,p_segment27              => l_scl_segment27
            ,p_segment28              => l_scl_segment28
            ,p_segment29              => l_scl_segment29
            ,p_segment30              => l_scl_segment30
            ,p_concat_segments_in     => l_old_scl_conc_segments
            ,p_ccid                   => l_soft_coding_keyflex_id
            ,p_concat_segments_out    => l_scl_concatenated_segments
            );
            --
            -- update the combinations column
            --
            update_scl_concat_segs
            (p_soft_coding_keyflex_id  => l_soft_coding_keyflex_id
            ,p_concatenated_segments   => l_scl_concatenated_segments
            );
         --
        end if;  -- csr_scl_idsel%NOTFOUND
      --
     end if; -- l_scl_segment1 <> hr_api.g_varchar2
   --
  end if; -- l_soft_coding_key_flex_id is null
  --
  -- need to call the lck procedure early, to fetch the old value of
  -- cagr_id_flex_num
  -- before passing it into the hr_cgd_upd.upd_or_sel function.
  -- This is because the user may be updating a grade definition,
  -- but not changing
  -- or specifying the cagr_id_flex_num (ie the grade structure).
  -- Also, need to fetch the old cagr_grade_def_id, as the
  -- user may be updating some
  -- segments, and not changing others. Passing cagr_grade_id
  -- into the hr_cgd_upd.upd_or_sel
  -- function allows that function to derive the old values.
  --
  l_cagr_id_flex_num  := p_cagr_id_flex_num;
  --
  if (p_cagr_id_flex_num  = hr_api.g_number) THEN
    per_asg_shd.lck
      (p_effective_date          => l_effective_date,
       -- Bug 3430504. Pass l_effective_date in place of p_effective_date.
       p_datetrack_mode          => p_datetrack_update_mode,
       p_assignment_id           => p_assignment_id,
       p_object_version_number   => p_object_version_number,
       p_validation_start_date   => l_unused_start_date,
       p_validation_end_date     => l_unused_end_date
       );
    l_cagr_id_flex_num := per_asg_shd.g_old_rec.cagr_id_flex_num;
    --l_cagr_grade_def_id := per_asg_shd.g_old_rec.cagr_grade_def_id;
  end if;
  --
  if l_cag_null_ind = 0
  then
     l_cagr_grade_def_id := per_asg_shd.g_old_rec.cagr_grade_def_id;
     --
     hr_cgd_upd.upd_or_sel
     (p_segment1               => l_cag_segment1
     ,p_segment2               => l_cag_segment2
     ,p_segment3               => l_cag_segment3
     ,p_segment4               => l_cag_segment4
     ,p_segment5               => l_cag_segment5
     ,p_segment6               => l_cag_segment6
     ,p_segment7               => l_cag_segment7
     ,p_segment8               => l_cag_segment8
     ,p_segment9               => l_cag_segment9
     ,p_segment10              => l_cag_segment10
     ,p_segment11              => l_cag_segment11
     ,p_segment12              => l_cag_segment12
     ,p_segment13              => l_cag_segment13
     ,p_segment14              => l_cag_segment14
     ,p_segment15              => l_cag_segment15
     ,p_segment16              => l_cag_segment16
     ,p_segment17              => l_cag_segment17
     ,p_segment18              => l_cag_segment18
     ,p_segment19              => l_cag_segment19
     ,p_segment20              => l_cag_segment20
     ,p_id_flex_num            => l_cagr_id_flex_num
     ,p_business_group_id      => per_asg_shd.g_old_rec.business_group_id
     ,p_cagr_grade_def_id      => l_cagr_grade_def_id
     ,p_concatenated_segments  => l_cagr_concatenated_segments
     );
     --
 if g_debug then
     hr_utility.set_location(l_proc, 90);
 end if;
     --
  end if; --  l_cagr_grade_def_id is null
  --
 if g_debug then
  hr_utility.set_location(l_proc, 95);
 end if;
  --
  -- Update assignment.
  --
  per_asg_upd.upd
    (p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => l_business_group_id
    ,p_grade_id                     => p_grade_id
    ,p_job_id                       => p_job_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_organization_id              => p_organization_id
    ,p_people_group_id              => l_people_group_id
    ,p_position_id                  => p_position_id
    ,p_application_id               => p_application_id
    ,p_special_ceiling_step_id      => p_special_ceiling_step_id
    ,p_recruiter_id                 => p_recruiter_id
    ,p_recruitment_activity_id      => p_recruitment_activity_id
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_person_referred_by_id        => p_person_referred_by_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_source_organization_id       => p_source_organization_id
    ,p_change_reason                => p_change_reason
    ,p_internal_address_line        => p_internal_address_line
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_employment_category          => p_employment_category
    ,p_frequency                    => p_frequency
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_comments                     => p_comments
    ,p_date_probation_end           => l_date_probation_end
    ,p_title                        => p_title
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    ,p_collective_agreement_id      => p_collective_agreement_id
    ,p_cagr_grade_def_id            => l_cagr_grade_def_id
    ,p_cagr_id_flex_num             => l_cagr_id_flex_num
    ,p_notice_period		    => p_notice_period
    ,p_notice_period_uom	    => p_notice_period_uom
    ,p_employee_category	    => p_employee_category
    ,p_work_at_home		    => p_work_at_home
    ,p_job_post_source_name	    => p_job_post_source_name
    ,p_payroll_id_updated           => l_dummy_payroll
    ,p_other_manager_warning        => l_dummy_manager1
    ,p_no_managers_warning          => l_dummy_manager2
    ,p_org_now_no_manager_warning   => l_dummy_manager3
    ,p_comment_id                   => l_comment_id
    ,p_validation_start_date        => l_validation_start_date
    ,p_validation_end_date          => l_validation_end_date
    ,p_object_version_number        => l_object_version_number
    ,p_effective_date               => l_effective_date
    ,p_datetrack_mode               => p_datetrack_update_mode
    ,p_validate                     => FALSE
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    ,p_applicant_rank               => p_applicant_rank
    ,p_posting_content_id           => p_posting_content_id
    ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
  --
  -- ***** Start new code for bug 2276928 **************
  -- modified the below if condition for bug 7657734
  IF (per_asg_shd.g_old_rec.assignment_status_type_id<>p_assignment_status_type_id AND
      p_assignment_status_type_id<>hr_api.g_number)
  -- modified for bug 9496344
    OR ( ( p_change_reason is null OR (p_change_reason <> hr_api.g_varchar2)) AND
         ( nvl(per_asg_shd.g_old_rec.change_reason, hr_api.g_varchar2) <>
           nvl(p_change_reason, hr_api.g_varchar2))) THEN
  -- end of 9496344
    IRC_ASG_STATUS_API.create_irc_asg_status
    (p_assignment_id                => p_assignment_id
     , p_assignment_status_type_id  => p_assignment_status_type_id
     , p_status_change_date         => p_effective_date
     , p_status_change_reason       => p_change_reason   -- Bug 2676934
     , p_assignment_status_id       => l_assignment_status_id
     , p_object_version_number      => l_asg_status_ovn);
  end if;
  -- ***** End new code for bug 2276928 **************
  --
  -- Fix for bug 3680947 starts here.
  -- When the vacancy is changes, move the letter request line to a letter request
  -- with that vacancy.
  -- When the assignemnt status is changed, create new letter request lines.
  --
  IF (per_asg_shd.g_old_rec.assignment_status_type_id<>p_assignment_status_type_id
    AND p_assignment_status_type_id<>hr_api.g_number
   )
   OR
   ( nvl(per_asg_shd.g_old_rec.vacancy_id,-1) <> nvl(p_vacancy_id,-1) AND
     nvl(p_vacancy_id,-1) <> hr_api.g_number
   ) THEN
  --
  IF ( nvl(per_asg_shd.g_old_rec.vacancy_id,-1) <> nvl(p_vacancy_id,-1) AND
     nvl(p_vacancy_id,-1) <> hr_api.g_number ) THEN
    --
    delete from per_letter_request_lines plrl
    where plrl.assignment_id = p_assignment_id
    and   plrl.assignment_status_type_id = p_assignment_status_type_id
    and   exists
         (select null
          from per_letter_requests plr
          where plr.letter_request_id = plrl.letter_request_id
          and   plr.request_status = 'PENDING'
          and   plr.auto_or_manual = 'AUTO');
    --
 END IF;
  --
  per_app_asg_pkg.cleanup_letters
        ( p_assignment_id => p_assignment_id);
  --
  --
    delete from per_letter_requests plr
    where  plr.business_group_id     = l_business_group_id
    and    plr.request_status        = 'PENDING'
    and    plr.auto_or_manual        = 'AUTO'
    and not exists
     ( select 1
	   from   per_letter_request_lines plrl
	   where  plrl.letter_request_id = plr.letter_request_id
      ) ;
   --
   per_applicant_pkg.check_for_letter_requests
    (p_business_group_id            => l_business_group_id
    ,p_per_system_status            => null
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_person_id                    => per_asg_shd.g_old_rec.person_id
    ,p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_validation_start_date        => l_effective_start_date
    ,p_vacancy_id 		            => p_vacancy_id
    );
   --
 END IF;
  --
  -- Fix for bug 3680947 ends here.
  --
  -- insert in to security lists if neccesary
  --
  --
  open get_sec_date_range;
  fetch get_sec_date_range into l_sec_effective_start_date,
                                l_sec_effective_end_date;
  close get_sec_date_range;
  --
  if l_effective_date between l_sec_effective_start_date
                          and l_sec_effective_end_date
  then
     if(per_asg_shd.g_old_rec.organization_id = l_business_group_id
       and p_organization_id <> l_business_group_id)
     then
        hr_security_internal.clear_from_person_list
                                             (per_asg_shd.g_old_rec.person_id);
     end if;
  --fix for bug 5938120 starts here
     open csr_get_assign(per_asg_shd.g_old_rec.person_id);
     LOOP
     fetch csr_get_assign into l_assignment_id;
     exit when csr_get_assign%NOTFOUND;
     hr_security_internal.add_to_person_list(l_effective_date,l_assignment_id);
     end loop;
     --fix for bug 5938120 ends here
  end if;
  --
  -- Start of API User Hook for the after hook of suspend_emp_asg.
  --
  begin
     hr_assignment_bk5.update_apl_asg_a
       (p_effective_date               =>     l_effective_date
       ,p_datetrack_update_mode        =>     p_datetrack_update_mode
       ,p_assignment_id                =>     p_assignment_id
       ,p_object_version_number        =>     l_object_version_number
       ,p_grade_id                     =>     p_grade_id
       ,p_job_id                       =>     p_job_id
       ,p_payroll_id                   =>     p_payroll_id
       ,p_location_id                  =>     p_location_id
       ,p_organization_id              =>     p_organization_id
       ,p_position_id                  =>     p_position_id
       ,p_application_id               =>     p_application_id
       ,p_special_ceiling_step_id      =>     p_special_ceiling_step_id
       ,p_recruiter_id                 =>     p_recruiter_id
       ,p_recruitment_activity_id      =>     p_recruitment_activity_id
       ,p_soft_coding_keyflex_id       =>     l_soft_coding_keyflex_id
       ,p_vacancy_id                   =>     p_vacancy_id
       ,p_pay_basis_id                 =>     p_pay_basis_id
       ,p_person_referred_by_id        =>     p_person_referred_by_id
       ,p_supervisor_id                =>     p_supervisor_id
       ,p_source_organization_id       =>     p_source_organization_id
       ,p_change_reason                =>     p_change_reason
       ,p_assignment_status_type_id    =>     p_assignment_status_type_id
       ,p_internal_address_line        =>     p_internal_address_line
       ,p_default_code_comb_id         =>     p_default_code_comb_id
       ,p_employment_category          =>     p_employment_category
       ,p_frequency                    =>     p_frequency
       ,p_manager_flag                 =>     p_manager_flag
       ,p_normal_hours                 =>     p_normal_hours
       ,p_perf_review_period           =>     p_perf_review_period
       ,p_perf_review_period_frequency =>     p_perf_review_period_frequency
       ,p_probation_period             =>     p_probation_period
       ,p_probation_unit               =>     p_probation_unit
       ,p_sal_review_period            =>     p_sal_review_period
       ,p_sal_review_period_frequency  =>     p_sal_review_period_frequency
       ,p_set_of_books_id              =>     p_set_of_books_id
       ,p_source_type                  =>     p_source_type
       ,p_time_normal_finish           =>     p_time_normal_finish
       ,p_time_normal_start            =>     p_time_normal_start
       ,p_bargaining_unit_code         =>     p_bargaining_unit_code
       ,p_comments                     =>     p_comments
       ,p_date_probation_end           =>     l_date_probation_end
       ,p_title                        =>     p_title
       ,p_ass_attribute_category       =>     p_ass_attribute_category
       ,p_ass_attribute1               =>     p_ass_attribute1
       ,p_ass_attribute2               =>     p_ass_attribute2
       ,p_ass_attribute3               =>     p_ass_attribute3
       ,p_ass_attribute4               =>     p_ass_attribute4
       ,p_ass_attribute5               =>     p_ass_attribute5
       ,p_ass_attribute6               =>     p_ass_attribute6
       ,p_ass_attribute7               =>     p_ass_attribute7
       ,p_ass_attribute8               =>     p_ass_attribute8
       ,p_ass_attribute9               =>     p_ass_attribute9
       ,p_ass_attribute10              =>     p_ass_attribute10
       ,p_ass_attribute11              =>     p_ass_attribute11
       ,p_ass_attribute12              =>     p_ass_attribute12
       ,p_ass_attribute13              =>     p_ass_attribute13
       ,p_ass_attribute14              =>     p_ass_attribute14
       ,p_ass_attribute15              =>     p_ass_attribute15
       ,p_ass_attribute16              =>     p_ass_attribute16
       ,p_ass_attribute17              =>     p_ass_attribute17
       ,p_ass_attribute18              =>     p_ass_attribute18
       ,p_ass_attribute19              =>     p_ass_attribute19
       ,p_ass_attribute20              =>     p_ass_attribute20
       ,p_ass_attribute21              =>     p_ass_attribute21
       ,p_ass_attribute22              =>     p_ass_attribute22
       ,p_ass_attribute23              =>     p_ass_attribute23
       ,p_ass_attribute24              =>     p_ass_attribute24
       ,p_ass_attribute25              =>     p_ass_attribute25
       ,p_ass_attribute26              =>     p_ass_attribute26
       ,p_ass_attribute27              =>     p_ass_attribute27
       ,p_ass_attribute28              =>     p_ass_attribute28
       ,p_ass_attribute29              =>     p_ass_attribute29
       ,p_ass_attribute30              =>     p_ass_attribute30
       ,p_scl_segment1                 =>     l_scl_segment1
       ,p_scl_segment2                 =>     l_scl_segment2
       ,p_scl_segment3                 =>     l_scl_segment3
       ,p_scl_segment4                 =>     l_scl_segment4
       ,p_scl_segment5                 =>     l_scl_segment5
       ,p_scl_segment6                 =>     l_scl_segment6
       ,p_scl_segment7                 =>     l_scl_segment7
       ,p_scl_segment8                 =>     l_scl_segment8
       ,p_scl_segment9                 =>     l_scl_segment9
       ,p_scl_segment10                =>     l_scl_segment10
       ,p_scl_segment11                =>     l_scl_segment11
       ,p_scl_segment12                =>     l_scl_segment12
       ,p_scl_segment13                =>     l_scl_segment13
       ,p_scl_segment14                =>     l_scl_segment14
       ,p_scl_segment15                =>     l_scl_segment15
       ,p_scl_segment16                =>     l_scl_segment16
       ,p_scl_segment17                =>     l_scl_segment17
       ,p_scl_segment18                =>     l_scl_segment18
       ,p_scl_segment19                =>     l_scl_segment19
       ,p_scl_segment20                =>     l_scl_segment20
       ,p_scl_segment21                =>     l_scl_segment21
       ,p_scl_segment22                =>     l_scl_segment22
       ,p_scl_segment23                =>     l_scl_segment23
       ,p_scl_segment24                =>     l_scl_segment24
       ,p_scl_segment25                =>     l_scl_segment25
       ,p_scl_segment26                =>     l_scl_segment26
       ,p_scl_segment27                =>     l_scl_segment27
       ,p_scl_segment28                =>     l_scl_segment28
       ,p_scl_segment29                =>     l_scl_segment29
       ,p_scl_segment30                =>     l_scl_segment30
       --
       -- Amended p_scl_concatenated_segments to be p_concatenated_segments
       -- Bug 944911
       ,p_concatenated_segments        =>     l_scl_concatenated_segments
       ,p_pgp_segment1                 =>     l_pgp_segment1
       ,p_pgp_segment2                 =>     l_pgp_segment2
       ,p_pgp_segment3                 =>     l_pgp_segment3
       ,p_pgp_segment4                 =>     l_pgp_segment4
       ,p_pgp_segment5                 =>     l_pgp_segment5
       ,p_pgp_segment6                 =>     l_pgp_segment6
       ,p_pgp_segment7                 =>     l_pgp_segment7
       ,p_pgp_segment8                 =>     l_pgp_segment8
       ,p_pgp_segment9                 =>     l_pgp_segment9
       ,p_pgp_segment10                =>     l_pgp_segment10
       ,p_pgp_segment11                =>     l_pgp_segment11
       ,p_pgp_segment12                =>     l_pgp_segment12
       ,p_pgp_segment13                =>     l_pgp_segment13
       ,p_pgp_segment14                =>     l_pgp_segment14
       ,p_pgp_segment15                =>     l_pgp_segment15
       ,p_pgp_segment16                =>     l_pgp_segment16
       ,p_pgp_segment17                =>     l_pgp_segment17
       ,p_pgp_segment18                =>     l_pgp_segment18
       ,p_pgp_segment19                =>     l_pgp_segment19
       ,p_pgp_segment20                =>     l_pgp_segment20
       ,p_pgp_segment21                =>     l_pgp_segment21
       ,p_pgp_segment22                =>     l_pgp_segment22
       ,p_pgp_segment23                =>     l_pgp_segment23
       ,p_pgp_segment24                =>     l_pgp_segment24
       ,p_pgp_segment25                =>     l_pgp_segment25
       ,p_pgp_segment26                =>     l_pgp_segment26
       ,p_pgp_segment27                =>     l_pgp_segment27
       ,p_pgp_segment28                =>     l_pgp_segment28
       ,p_pgp_segment29                =>     l_pgp_segment29
       ,p_pgp_segment30                =>     l_pgp_segment30
       ,p_contract_id                  =>     p_contract_id
       ,p_establishment_id             =>     p_establishment_id
       ,p_collective_agreement_id      =>     p_collective_agreement_id
       ,p_cagr_id_flex_num             =>     l_cagr_id_flex_num
       ,p_cag_segment1                 =>     l_cag_segment1
       ,p_cag_segment2                 =>     l_cag_segment2
       ,p_cag_segment3                 =>     l_cag_segment3
       ,p_cag_segment4                 =>     l_cag_segment4
       ,p_cag_segment5                 =>     l_cag_segment5
       ,p_cag_segment6                 =>     l_cag_segment6
       ,p_cag_segment7                 =>     l_cag_segment7
       ,p_cag_segment8                 =>     l_cag_segment8
       ,p_cag_segment9                 =>     l_cag_segment9
       ,p_cag_segment10                =>     l_cag_segment10
       ,p_cag_segment11                =>     l_cag_segment11
       ,p_cag_segment12                =>     l_cag_segment12
       ,p_cag_segment13                =>     l_cag_segment13
       ,p_cag_segment14                =>     l_cag_segment14
       ,p_cag_segment15                =>     l_cag_segment15
       ,p_cag_segment16                =>     l_cag_segment16
       ,p_cag_segment17                =>     l_cag_segment17
       ,p_cag_segment18                =>     l_cag_segment18
       ,p_cag_segment19                =>     l_cag_segment19
       ,p_cag_segment20                =>     l_cag_segment20
       ,p_notice_period		       =>     p_notice_period
       ,p_notice_period_uom	       =>     p_notice_period_uom
       ,p_employee_category	       =>     p_employee_category
       ,p_work_at_home		       =>     p_work_at_home
       ,p_job_post_source_name	       =>     p_job_post_source_name
       ,p_cagr_grade_def_id            =>     l_cagr_grade_def_id
       ,p_cagr_concatenated_segments   =>     l_cagr_concatenated_segments
       ,p_group_name                   =>     l_group_name
       ,p_comment_id                   =>     l_comment_id
       ,p_people_group_id              =>     l_people_group_id
       ,p_effective_start_date         =>     l_effective_start_date
       ,p_effective_end_date           =>     l_effective_end_date
       ,p_applicant_rank               =>     p_applicant_rank
       ,p_posting_content_id           =>     p_posting_content_id
       --
       -- Bug 944911
       -- Added the 2 additional IN param
       -- Bug 944911
       -- Amended p_group_name to p_concat_segments
       --
       ,p_concat_segments              =>     l_old_group_name
       --
       -- Bug 944911
       -- Amended p_scl_concatenated_segments to be p_scl_concat_segments
       ,p_scl_concat_segments          =>     l_old_scl_conc_segments
       ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
       ,p_supervisor_assignment_id     => p_supervisor_assignment_id
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_APL_ASG',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of suspend_emp_asg.
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
-- Bug 944911
-- Amended p_scl_concatenated_segments to be p_concatenated_segments
  p_object_version_number  := l_object_version_number;
  p_comment_id             := l_comment_id;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_people_group_id        := l_people_group_id;
  p_soft_coding_keyflex_id := l_soft_coding_keyflex_id;
  p_concatenated_segments  := l_scl_concatenated_segments;
  p_group_name             := l_group_name;
  --
  p_cagr_grade_def_id          := l_cagr_grade_def_id;
  p_cagr_concatenated_segments := l_cagr_concatenated_segments;
  --
  -- remove data from the session table
  hr_kflex_utility.unset_session_date
    (p_session_id     => l_session_id);
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 6);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_apl_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := p_object_version_number;
    p_comment_id             := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    -- bug 2230915 only re-set to null if key flex ids came in as null.
    --
    if l_scl_null_ind = 0
    then
       p_soft_coding_keyflex_id  := null;
    end if;
    --
    if l_pgp_null_ind = 0
    then
       p_people_group_id         := null;
    end if;
    --
    if l_cag_null_ind = 0
    then
       p_cagr_grade_def_id       := null;
    end if;
    --
    -- Bug 944911
    -- Amended scl_concatenated_segments to be concatenated_segments
    p_concatenated_segments := l_old_scl_conc_segments;
    p_group_name            := l_old_group_name;
    p_cagr_concatenated_segments := null;
    --
    --
    when others then
       --
       -- A validation or unexpected error has occurred
       --
       -- Added as part of fix to bug 632479
       --
       p_object_version_number     := lv_object_version_number ;
       p_cagr_grade_def_id         := lv_cagr_grade_def_id ;
       p_people_group_id           := lv_people_group_id ;
       p_soft_coding_keyflex_id    := lv_soft_coding_keyflex_id ;

       p_concatenated_segments      := null;
       p_cagr_concatenated_segments := null;
       p_group_name                 := null;
       p_comment_id                 := null;
       p_effective_start_date       := null;
       p_effective_end_date         := null;

       ROLLBACK TO update_apl_asg;
       raise;
       --
       -- End of fix.
       --
end update_apl_asg;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_apl_asg >-----R11-----------------------|
-- ----------------------------------------------------------------------------
--
-- This is an overloaded procedure to include new parms
-- for contracts and collective agreements
--
procedure update_apl_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_grade_id                     in     number
  ,p_job_id                       in     number
  ,p_location_id                  in     number
  ,p_organization_id              in     number
  ,p_position_id                  in     number
  ,p_application_id               in     number
  ,p_recruiter_id                 in     number
  ,p_recruitment_activity_id      in     number
  ,p_vacancy_id                   in     number
  ,p_person_referred_by_id        in     number
  ,p_supervisor_id                in     number
  ,p_source_organization_id       in     number
  ,p_change_reason                in     varchar2
  ,p_frequency                    in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_title                        in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_segment1                     in     varchar2
  ,p_segment2                     in     varchar2
  ,p_segment3                     in     varchar2
  ,p_segment4                     in     varchar2
  ,p_segment5                     in     varchar2
  ,p_segment6                     in     varchar2
  ,p_segment7                     in     varchar2
  ,p_segment8                     in     varchar2
  ,p_segment9                     in     varchar2
  ,p_segment10                    in     varchar2
  ,p_segment11                    in     varchar2
  ,p_segment12                    in     varchar2
  ,p_segment13                    in     varchar2
  ,p_segment14                    in     varchar2
  ,p_segment15                    in     varchar2
  ,p_segment16                    in     varchar2
  ,p_segment17                    in     varchar2
  ,p_segment18                    in     varchar2
  ,p_segment19                    in     varchar2
  ,p_segment20                    in     varchar2
  ,p_segment21                    in     varchar2
  ,p_segment22                    in     varchar2
  ,p_segment23                    in     varchar2
  ,p_segment24                    in     varchar2
  ,p_segment25                    in     varchar2
  ,p_segment26                    in     varchar2
  ,p_segment27                    in     varchar2
  ,p_segment28                    in     varchar2
  ,p_segment29                    in     varchar2
  ,p_segment30                    in     varchar2
-- Bug 944911
-- Amended p_concat_segments to be an in instead of in out
-- Added p_concatenated_segments to be out
-- Reverting back changes as this for compatibilty with v11
  --,p_concat_segments              in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_concatenated_segments           in out nocopy varchar2
  ,p_comment_id                      out nocopy number
  ,p_people_group_id                 out nocopy number  -- in out?
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
 ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_comment_id                 per_all_assignments_f.comment_id%TYPE;
  l_effective_start_date       per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date         per_all_assignments_f.effective_end_date%TYPE;
  l_dummy_payroll              boolean;
  l_dummy_manager1             boolean;
  l_dummy_manager2             boolean;
  l_dummy_manager3             boolean;
  l_validation_start_date      per_all_assignments_f.effective_start_date%TYPE;
  l_validation_end_date        per_all_assignments_f.effective_end_date%TYPE;
  l_object_version_number      per_all_assignments_f.object_version_number%TYPE;
  l_effective_date             date;
  l_date_probation_end         date;
  l_flex_num                   fnd_id_flex_segments.id_flex_num%TYPE;
  l_concatenated_segments      hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_cagr_concatenated_segments varchar2(2000);
  l_cagr_grade_def_id          per_cagr_grades_def.cagr_grade_def_id%TYPE;
--

-- Bug 944911
-- added an new var to handle in and out
  l_concat_segments      hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_soft_coding_keyflex_id      hr_soft_coding_keyflex.soft_coding_keyflex_id%TYPE;
  --
  -- Internal working variables
  --
  l_business_group_id          per_business_groups.business_group_id%TYPE;
  l_people_group_id            per_all_assignments_f.people_group_id%TYPE;
  l_group_name                 pay_people_groups.group_name%TYPE;
  l_proc                       varchar2(72);
  l_api_updating               boolean;
  --
begin
 if g_debug then
  l_proc := g_package||'update_apl_asg';
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  l_object_version_number := p_object_version_number ;
-- bug 944911
-- made concatenated to concat
-- changing p_concat to p_concatenated
  l_concat_segments := p_concatenated_segments;
  --
  -- Call the new code
-- bug 944911
-- made no changes to p_group_name as it is out , while in is
  hr_assignment_api.update_apl_asg(
   p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => p_datetrack_update_mode
  ,p_assignment_id                => p_assignment_id
  ,p_object_version_number        => l_object_version_number
  ,p_grade_id                     => p_grade_id
  ,p_job_id                       => p_job_id
  ,p_location_id                  => p_location_id
  ,p_organization_id              => p_organization_id
  ,p_position_id                  => p_position_id
  ,p_application_id               => p_application_id
  ,p_recruiter_id                 => p_recruiter_id
  ,p_recruitment_activity_id      => p_recruitment_activity_id
  ,p_vacancy_id                   => p_vacancy_id
  ,p_person_referred_by_id        => p_person_referred_by_id
  ,p_supervisor_id                => p_supervisor_id
  ,p_source_organization_id       => p_source_organization_id
  ,p_change_reason                => p_change_reason
  ,p_frequency                    => p_frequency
  ,p_manager_flag                 => p_manager_flag
  ,p_normal_hours                 => p_normal_hours
  ,p_probation_period             => p_probation_period
  ,p_probation_unit               => p_probation_unit
  ,p_source_type                  => p_source_type
  ,p_time_normal_finish           => p_time_normal_finish
  ,p_time_normal_start            => p_time_normal_start
  ,p_comments                     => p_comments
  ,p_date_probation_end           => p_date_probation_end
  ,p_title                        => p_title
  ,p_ass_attribute_category       => p_ass_attribute_category
  ,p_ass_attribute1               => p_ass_attribute1
  ,p_ass_attribute2               => p_ass_attribute2
  ,p_ass_attribute3               => p_ass_attribute3
  ,p_ass_attribute4               => p_ass_attribute4
  ,p_ass_attribute5               => p_ass_attribute5
  ,p_ass_attribute6               => p_ass_attribute6
  ,p_ass_attribute7               => p_ass_attribute7
  ,p_ass_attribute8               => p_ass_attribute8
  ,p_ass_attribute9               => p_ass_attribute9
  ,p_ass_attribute10              => p_ass_attribute10
  ,p_ass_attribute11              => p_ass_attribute11
  ,p_ass_attribute12              => p_ass_attribute12
  ,p_ass_attribute13              => p_ass_attribute13
  ,p_ass_attribute14              => p_ass_attribute14
  ,p_ass_attribute15              => p_ass_attribute15
  ,p_ass_attribute16              => p_ass_attribute16
  ,p_ass_attribute17              => p_ass_attribute17
  ,p_ass_attribute18              => p_ass_attribute18
  ,p_ass_attribute19              => p_ass_attribute19
  ,p_ass_attribute20              => p_ass_attribute20
  ,p_ass_attribute21              => p_ass_attribute21
  ,p_ass_attribute22              => p_ass_attribute22
  ,p_ass_attribute23              => p_ass_attribute23
  ,p_ass_attribute24              => p_ass_attribute24
  ,p_ass_attribute25              => p_ass_attribute25
  ,p_ass_attribute26              => p_ass_attribute26
  ,p_ass_attribute27              => p_ass_attribute27
  ,p_ass_attribute28              => p_ass_attribute28
  ,p_ass_attribute29              => p_ass_attribute29
  ,p_ass_attribute30              => p_ass_attribute30
  ,p_scl_segment1                     => p_segment1
  ,p_scl_segment2                     => p_segment2
  ,p_scl_segment3                     => p_segment3
  ,p_scl_segment4                     => p_segment4
  ,p_scl_segment5                     => p_segment5
  ,p_scl_segment6                     => p_segment6
  ,p_scl_segment7                     => p_segment7
  ,p_scl_segment8                     => p_segment8
  ,p_scl_segment9                     => p_segment9
  ,p_scl_segment10                    => p_segment10
  ,p_scl_segment11                    => p_segment11
  ,p_scl_segment12                    => p_segment12
  ,p_scl_segment13                    => p_segment13
  ,p_scl_segment14                    => p_segment14
  ,p_scl_segment15                    => p_segment15
  ,p_scl_segment16                    => p_segment16
  ,p_scl_segment17                    => p_segment17
  ,p_scl_segment18                    => p_segment18
  ,p_scl_segment19                    => p_segment19
  ,p_scl_segment20                    => p_segment20
  ,p_scl_segment21                    => p_segment21
  ,p_scl_segment22                    => p_segment22
  ,p_scl_segment23                    => p_segment23
  ,p_scl_segment24                    => p_segment24
  ,p_scl_segment25                    => p_segment25
  ,p_scl_segment26                    => p_segment26
  ,p_scl_segment27                    => p_segment27
  ,p_scl_segment28                    => p_segment28
  ,p_scl_segment29                    => p_segment29
  ,p_scl_segment30                    => p_segment30
  ,p_comment_id                   => l_comment_id
  ,p_people_group_id              => l_people_group_id
  ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ,p_group_name                   => l_group_name
  ,p_scl_concat_segments    => l_concat_segments
  ,p_concatenated_segments    => l_concatenated_segments
  ,p_cagr_grade_def_id            =>     l_cagr_grade_def_id
  ,p_cagr_concatenated_segments   =>     l_cagr_concatenated_segments
  ,p_supervisor_assignment_id     => p_supervisor_assignment_id
  );
  -- Set all output arguments
  -- Ignore the overloaded out arguments
  --
  p_object_version_number  := l_object_version_number;
  p_comment_id             := l_comment_id;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_people_group_id        := l_people_group_id;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 6);
 end if;
end update_apl_asg;
--
-- OLD
-- ----------------------------------------------------------------------------
-- |---------------------< create_secondary_apl_asg >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_secondary_apl_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_recruiter_id                 in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_person_referred_by_id        in     number
  ,p_supervisor_id                in     number
  ,p_special_ceiling_step_id      in     number
  ,p_recruitment_activity_id      in     number
  ,p_source_organization_id       in     number
  ,p_vacancy_id                   in     number
  ,p_pay_basis_id                 in     number
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_employment_category          in     varchar2
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_scl_segment1                 in     varchar2
  ,p_scl_segment2                 in     varchar2
  ,p_scl_segment3                 in     varchar2
  ,p_scl_segment4                 in     varchar2
  ,p_scl_segment5                 in     varchar2
  ,p_scl_segment6                 in     varchar2
  ,p_scl_segment7                 in     varchar2
  ,p_scl_segment8                 in     varchar2
  ,p_scl_segment9                 in     varchar2
  ,p_scl_segment10                in     varchar2
  ,p_scl_segment11                in     varchar2
  ,p_scl_segment12                in     varchar2
  ,p_scl_segment13                in     varchar2
  ,p_scl_segment14                in     varchar2
  ,p_scl_segment15                in     varchar2
  ,p_scl_segment16                in     varchar2
  ,p_scl_segment17                in     varchar2
  ,p_scl_segment18                in     varchar2
  ,p_scl_segment19                in     varchar2
  ,p_scl_segment20                in     varchar2
  ,p_scl_segment21                in     varchar2
  ,p_scl_segment22                in     varchar2
  ,p_scl_segment23                in     varchar2
  ,p_scl_segment24                in     varchar2
  ,p_scl_segment25                in     varchar2
  ,p_scl_segment26                in     varchar2
  ,p_scl_segment27                in     varchar2
  ,p_scl_segment28                in     varchar2
  ,p_scl_segment29                in     varchar2
  ,p_scl_segment30                in     varchar2
  ,p_scl_concat_segments          in     varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_pgp_segment1                 in     varchar2
  ,p_pgp_segment2                 in     varchar2
  ,p_pgp_segment3                 in     varchar2
  ,p_pgp_segment4                 in     varchar2
  ,p_pgp_segment5                 in     varchar2
  ,p_pgp_segment6                 in     varchar2
  ,p_pgp_segment7                 in     varchar2
  ,p_pgp_segment8                 in     varchar2
  ,p_pgp_segment9                 in     varchar2
  ,p_pgp_segment10                in     varchar2
  ,p_pgp_segment11                in     varchar2
  ,p_pgp_segment12                in     varchar2
  ,p_pgp_segment13                in     varchar2
  ,p_pgp_segment14                in     varchar2
  ,p_pgp_segment15                in     varchar2
  ,p_pgp_segment16                in     varchar2
  ,p_pgp_segment17                in     varchar2
  ,p_pgp_segment18                in     varchar2
  ,p_pgp_segment19                in     varchar2
  ,p_pgp_segment20                in     varchar2
  ,p_pgp_segment21                in     varchar2
  ,p_pgp_segment22                in     varchar2
  ,p_pgp_segment23                in     varchar2
  ,p_pgp_segment24                in     varchar2
  ,p_pgp_segment25                in     varchar2
  ,p_pgp_segment26                in     varchar2
  ,p_pgp_segment27                in     varchar2
  ,p_pgp_segment28                in     varchar2
  ,p_pgp_segment29                in     varchar2
  ,p_pgp_segment30                in     varchar2
  ,p_concat_segments		  in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_collective_agreement_id      in     number
  ,p_cagr_id_flex_num             in     number
  ,p_cag_segment1                 in     varchar2
  ,p_cag_segment2                 in     varchar2
  ,p_cag_segment3                 in     varchar2
  ,p_cag_segment4                 in     varchar2
  ,p_cag_segment5                 in     varchar2
  ,p_cag_segment6                 in     varchar2
  ,p_cag_segment7                 in     varchar2
  ,p_cag_segment8                 in     varchar2
  ,p_cag_segment9                 in     varchar2
  ,p_cag_segment10                in     varchar2
  ,p_cag_segment11                in     varchar2
  ,p_cag_segment12                in     varchar2
  ,p_cag_segment13                in     varchar2
  ,p_cag_segment14                in     varchar2
  ,p_cag_segment15                in     varchar2
  ,p_cag_segment16                in     varchar2
  ,p_cag_segment17                in     varchar2
  ,p_cag_segment18                in     varchar2
  ,p_cag_segment19                in     varchar2
  ,p_cag_segment20                in     varchar2
  ,p_notice_period		  in	 number
  ,p_notice_period_uom		  in     varchar2
  ,p_employee_category		  in     varchar2
  ,p_work_at_home		  in	 varchar2
  ,p_job_post_source_name         in     varchar2
  ,p_applicant_rank               in     number
  ,p_posting_content_id           in     number
  ,p_grade_ladder_pgm_id          in     number
  ,p_supervisor_assignment_id     in     number
  ,p_cagr_grade_def_id            in out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_people_group_id              in out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ) is
  l_warning boolean;
BEGIN
 create_secondary_apl_asg
  (p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_person_id                    => p_person_id
  ,p_organization_id              => p_organization_id
  ,p_recruiter_id                 => p_recruiter_id
  ,p_grade_id                     => p_grade_id
  ,p_position_id                  =>  p_position_id
  ,p_job_id                       => p_job_id
  ,p_assignment_status_type_id    => p_assignment_status_type_id
  ,p_payroll_id                   => p_payroll_id
  ,p_location_id                  => p_location_id
  ,p_person_referred_by_id        => p_person_referred_by_id
  ,p_supervisor_id                => p_supervisor_id
  ,p_special_ceiling_step_id      => p_special_ceiling_step_id
  ,p_recruitment_activity_id      => p_recruitment_activity_id
  ,p_source_organization_id       => p_source_organization_id
  ,p_vacancy_id                   => p_vacancy_id
  ,p_pay_basis_id                 => p_pay_basis_id
  ,p_change_reason                => p_change_reason
  ,p_comments                     => p_comments
  ,p_date_probation_end           => p_date_probation_end
  ,p_default_code_comb_id         => p_default_code_comb_id
  ,p_employment_category          => p_employment_category
  ,p_frequency                    => p_frequency
  ,p_internal_address_line        => p_internal_address_line
  ,p_manager_flag                 => p_manager_flag
  ,p_normal_hours                 => p_normal_hours
  ,p_perf_review_period           => p_perf_review_period
  ,p_perf_review_period_frequency => p_perf_review_period_frequency
  ,p_probation_period             => p_probation_period
  ,p_probation_unit               => p_probation_unit
  ,p_sal_review_period            => p_sal_review_period
  ,p_sal_review_period_frequency  => p_sal_review_period_frequency
  ,p_set_of_books_id              => p_set_of_books_id
  ,p_source_type                  => p_source_type
  ,p_time_normal_finish           => p_time_normal_finish
  ,p_time_normal_start            => p_time_normal_start
  ,p_bargaining_unit_code         => p_bargaining_unit_code
  ,p_ass_attribute_category       => p_ass_attribute_category
  ,p_ass_attribute1               => p_ass_attribute1
  ,p_ass_attribute2               => p_ass_attribute2
  ,p_ass_attribute3               => p_ass_attribute3
  ,p_ass_attribute4               => p_ass_attribute4
  ,p_ass_attribute5               => p_ass_attribute5
  ,p_ass_attribute6               => p_ass_attribute6
  ,p_ass_attribute7               => p_ass_attribute7
  ,p_ass_attribute8               => p_ass_attribute8
  ,p_ass_attribute9               => p_ass_attribute9
  ,p_ass_attribute10              => p_ass_attribute10
  ,p_ass_attribute11              => p_ass_attribute11
  ,p_ass_attribute12              => p_ass_attribute12
  ,p_ass_attribute13              => p_ass_attribute13
  ,p_ass_attribute14              => p_ass_attribute14
  ,p_ass_attribute15              => p_ass_attribute15
  ,p_ass_attribute16              => p_ass_attribute16
  ,p_ass_attribute17              => p_ass_attribute17
  ,p_ass_attribute18              => p_ass_attribute18
  ,p_ass_attribute19              => p_ass_attribute19
  ,p_ass_attribute20              => p_ass_attribute20
  ,p_ass_attribute21              => p_ass_attribute21
  ,p_ass_attribute22              => p_ass_attribute22
  ,p_ass_attribute23              => p_ass_attribute23
  ,p_ass_attribute24              => p_ass_attribute24
  ,p_ass_attribute25              => p_ass_attribute25
  ,p_ass_attribute26              => p_ass_attribute26
  ,p_ass_attribute27              => p_ass_attribute27
  ,p_ass_attribute28              => p_ass_attribute28
  ,p_ass_attribute29              => p_ass_attribute29
  ,p_ass_attribute30              => p_ass_attribute30
  ,p_title                        => p_title
  ,p_scl_segment1                 => p_scl_segment1
  ,p_scl_segment2                 => p_scl_segment2
  ,p_scl_segment3                 => p_scl_segment3
  ,p_scl_segment4                 => p_scl_segment4
  ,p_scl_segment5                 => p_scl_segment5
  ,p_scl_segment6                 => p_scl_segment6
  ,p_scl_segment7                 => p_scl_segment7
  ,p_scl_segment8                 => p_scl_segment8
  ,p_scl_segment9                 => p_scl_segment9
  ,p_scl_segment10                => p_scl_segment10
  ,p_scl_segment11                => p_scl_segment11
  ,p_scl_segment12                => p_scl_segment12
  ,p_scl_segment13                => p_scl_segment13
  ,p_scl_segment14                => p_scl_segment14
  ,p_scl_segment15                => p_scl_segment15
  ,p_scl_segment16                => p_scl_segment16
  ,p_scl_segment17                => p_scl_segment17
  ,p_scl_segment18                => p_scl_segment18
  ,p_scl_segment19                => p_scl_segment19
  ,p_scl_segment20                => p_scl_segment20
  ,p_scl_segment21                => p_scl_segment21
  ,p_scl_segment22                => p_scl_segment22
  ,p_scl_segment23                => p_scl_segment23
  ,p_scl_segment24                => p_scl_segment24
  ,p_scl_segment25                => p_scl_segment25
  ,p_scl_segment26                => p_scl_segment26
  ,p_scl_segment27                => p_scl_segment27
  ,p_scl_segment28                => p_scl_segment28
  ,p_scl_segment29                => p_scl_segment29
  ,p_scl_segment30                => p_scl_segment30
  ,p_scl_concat_segments          => p_scl_concat_segments
  ,p_concatenated_segments        => p_concatenated_segments
  ,p_pgp_segment1                 => p_pgp_segment1
  ,p_pgp_segment2                 => p_pgp_segment2
  ,p_pgp_segment3                 => p_pgp_segment3
  ,p_pgp_segment4                 => p_pgp_segment4
  ,p_pgp_segment5                 => p_pgp_segment5
  ,p_pgp_segment6                 => p_pgp_segment6
  ,p_pgp_segment7                 => p_pgp_segment7
  ,p_pgp_segment8                 => p_pgp_segment8
  ,p_pgp_segment9                 => p_pgp_segment9
  ,p_pgp_segment10                => p_pgp_segment10
  ,p_pgp_segment11                => p_pgp_segment11
  ,p_pgp_segment12                => p_pgp_segment12
  ,p_pgp_segment13                => p_pgp_segment13
  ,p_pgp_segment14                => p_pgp_segment14
  ,p_pgp_segment15                => p_pgp_segment15
  ,p_pgp_segment16                => p_pgp_segment16
  ,p_pgp_segment17                => p_pgp_segment17
  ,p_pgp_segment18                => p_pgp_segment18
  ,p_pgp_segment19                => p_pgp_segment19
  ,p_pgp_segment20                => p_pgp_segment20
  ,p_pgp_segment21                => p_pgp_segment21
  ,p_pgp_segment22                => p_pgp_segment22
  ,p_pgp_segment23                => p_pgp_segment23
  ,p_pgp_segment24                => p_pgp_segment24
  ,p_pgp_segment25                => p_pgp_segment25
  ,p_pgp_segment26                => p_pgp_segment26
  ,p_pgp_segment27                => p_pgp_segment27
  ,p_pgp_segment28                => p_pgp_segment28
  ,p_pgp_segment29                => p_pgp_segment29
  ,p_pgp_segment30                => p_pgp_segment30
  ,p_concat_segments		      => p_concat_segments
  ,p_contract_id                  => p_contract_id
  ,p_establishment_id             => p_establishment_id
  ,p_collective_agreement_id      => p_collective_agreement_id
  ,p_cagr_id_flex_num             => p_cagr_id_flex_num
  ,p_cag_segment1                 => p_cag_segment1
  ,p_cag_segment2                 => p_cag_segment2
  ,p_cag_segment3                 => p_cag_segment3
  ,p_cag_segment4                 => p_cag_segment4
  ,p_cag_segment5                 => p_cag_segment5
  ,p_cag_segment6                 => p_cag_segment6
  ,p_cag_segment7                 => p_cag_segment7
  ,p_cag_segment8                 => p_cag_segment8
  ,p_cag_segment9                 => p_cag_segment9
  ,p_cag_segment10                => p_cag_segment10
  ,p_cag_segment11                => p_cag_segment11
  ,p_cag_segment12                => p_cag_segment12
  ,p_cag_segment13                => p_cag_segment13
  ,p_cag_segment14                => p_cag_segment14
  ,p_cag_segment15                => p_cag_segment15
  ,p_cag_segment16                => p_cag_segment16
  ,p_cag_segment17                => p_cag_segment17
  ,p_cag_segment18                => p_cag_segment18
  ,p_cag_segment19                => p_cag_segment19
  ,p_cag_segment20                => p_cag_segment20
  ,p_notice_period		          => p_notice_period
  ,p_notice_period_uom		      => p_notice_period_uom
  ,p_employee_category		      => p_employee_category
  ,p_work_at_home		          => p_work_at_home
  ,p_job_post_source_name         => p_job_post_source_name
  ,p_applicant_rank               => p_applicant_rank
  ,p_posting_content_id           => p_posting_content_id
  ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
  ,p_supervisor_assignment_id     => p_supervisor_assignment_id
  ,p_cagr_grade_def_id            => p_cagr_grade_def_id
  ,p_cagr_concatenated_segments   => p_cagr_concatenated_segments
  ,p_group_name                   => p_group_name
  ,p_assignment_id                => p_assignment_id
  ,p_people_group_id              => p_people_group_id
  ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
  ,p_comment_id                   => p_comment_id
  ,p_object_version_number        => p_object_version_number
  ,p_effective_start_date         => p_effective_start_date
  ,p_effective_end_date           => p_effective_end_date
  ,p_assignment_sequence          => p_assignment_sequence
  ,p_appl_override_warning        => l_warning
  );

END;
-- NEW
-- ----------------------------------------------------------------------------
-- |---------------------< create_secondary_apl_asg >-------------------------|
-- ----------------------------------------------------------------------------
-- NEW
procedure create_secondary_apl_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_recruiter_id                 in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_person_referred_by_id        in     number
  ,p_supervisor_id                in     number
  ,p_special_ceiling_step_id      in     number
  ,p_recruitment_activity_id      in     number
  ,p_source_organization_id       in     number
  ,p_vacancy_id                   in     number
  ,p_pay_basis_id                 in     number
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_employment_category          in     varchar2
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_scl_segment1                 in     varchar2
  ,p_scl_segment2                 in     varchar2
  ,p_scl_segment3                 in     varchar2
  ,p_scl_segment4                 in     varchar2
  ,p_scl_segment5                 in     varchar2
  ,p_scl_segment6                 in     varchar2
  ,p_scl_segment7                 in     varchar2
  ,p_scl_segment8                 in     varchar2
  ,p_scl_segment9                 in     varchar2
  ,p_scl_segment10                in     varchar2
  ,p_scl_segment11                in     varchar2
  ,p_scl_segment12                in     varchar2
  ,p_scl_segment13                in     varchar2
  ,p_scl_segment14                in     varchar2
  ,p_scl_segment15                in     varchar2
  ,p_scl_segment16                in     varchar2
  ,p_scl_segment17                in     varchar2
  ,p_scl_segment18                in     varchar2
  ,p_scl_segment19                in     varchar2
  ,p_scl_segment20                in     varchar2
  ,p_scl_segment21                in     varchar2
  ,p_scl_segment22                in     varchar2
  ,p_scl_segment23                in     varchar2
  ,p_scl_segment24                in     varchar2
  ,p_scl_segment25                in     varchar2
  ,p_scl_segment26                in     varchar2
  ,p_scl_segment27                in     varchar2
  ,p_scl_segment28                in     varchar2
  ,p_scl_segment29                in     varchar2
  ,p_scl_segment30                in     varchar2
-- Bug 944911
-- Amended p_scl_concatenated_segments to be an out instead of in out
-- Added new param p_scl_concat_segments
-- Amended p_scl_concatenated_segments to be p_concatenated_segments
  ,p_scl_concat_segments          in     varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_pgp_segment1                 in     varchar2
  ,p_pgp_segment2                 in     varchar2
  ,p_pgp_segment3                 in     varchar2
  ,p_pgp_segment4                 in     varchar2
  ,p_pgp_segment5                 in     varchar2
  ,p_pgp_segment6                 in     varchar2
  ,p_pgp_segment7                 in     varchar2
  ,p_pgp_segment8                 in     varchar2
  ,p_pgp_segment9                 in     varchar2
  ,p_pgp_segment10                in     varchar2
  ,p_pgp_segment11                in     varchar2
  ,p_pgp_segment12                in     varchar2
  ,p_pgp_segment13                in     varchar2
  ,p_pgp_segment14                in     varchar2
  ,p_pgp_segment15                in     varchar2
  ,p_pgp_segment16                in     varchar2
  ,p_pgp_segment17                in     varchar2
  ,p_pgp_segment18                in     varchar2
  ,p_pgp_segment19                in     varchar2
  ,p_pgp_segment20                in     varchar2
  ,p_pgp_segment21                in     varchar2
  ,p_pgp_segment22                in     varchar2
  ,p_pgp_segment23                in     varchar2
  ,p_pgp_segment24                in     varchar2
  ,p_pgp_segment25                in     varchar2
  ,p_pgp_segment26                in     varchar2
  ,p_pgp_segment27                in     varchar2
  ,p_pgp_segment28                in     varchar2
  ,p_pgp_segment29                in     varchar2
  ,p_pgp_segment30                in     varchar2
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
  ,p_concat_segments		  in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_collective_agreement_id      in     number
  ,p_cagr_id_flex_num             in     number
  ,p_cag_segment1                 in     varchar2
  ,p_cag_segment2                 in     varchar2
  ,p_cag_segment3                 in     varchar2
  ,p_cag_segment4                 in     varchar2
  ,p_cag_segment5                 in     varchar2
  ,p_cag_segment6                 in     varchar2
  ,p_cag_segment7                 in     varchar2
  ,p_cag_segment8                 in     varchar2
  ,p_cag_segment9                 in     varchar2
  ,p_cag_segment10                in     varchar2
  ,p_cag_segment11                in     varchar2
  ,p_cag_segment12                in     varchar2
  ,p_cag_segment13                in     varchar2
  ,p_cag_segment14                in     varchar2
  ,p_cag_segment15                in     varchar2
  ,p_cag_segment16                in     varchar2
  ,p_cag_segment17                in     varchar2
  ,p_cag_segment18                in     varchar2
  ,p_cag_segment19                in     varchar2
  ,p_cag_segment20                in     varchar2
  ,p_notice_period		  in	 number
  ,p_notice_period_uom		  in     varchar2
  ,p_employee_category		  in     varchar2
  ,p_work_at_home		  in	 varchar2
  ,p_job_post_source_name         in     varchar2
  ,p_applicant_rank               in     number
  ,p_posting_content_id           in     number
  ,p_grade_ladder_pgm_id          in     number
  ,p_supervisor_assignment_id     in     number
  ,p_cagr_grade_def_id            in out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_people_group_id              in out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_appl_override_warning           OUT NOCOPY boolean  -- 3652025
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_assignment_id          per_all_assignments_f.assignment_id%TYPE;
  l_people_group_id        per_all_assignments_f.people_group_id%TYPE := p_people_group_id;
  l_object_version_number  per_all_assignments_f.object_version_number%TYPE;
  l_effective_start_date   per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date     per_all_assignments_f.effective_end_date%TYPE;
  l_assignment_sequence    per_all_assignments_f.assignment_sequence%TYPE;
  l_comment_id             per_all_assignments_f.comment_id%TYPE;
  l_group_name             pay_people_groups.group_name%TYPE;
  l_old_group_name         pay_people_groups.group_name%TYPE;
  --
  l_application_id         per_applications.application_id%TYPE;
  l_business_group_id      per_business_groups.business_group_id%TYPE;
  l_legislation_code       per_business_groups.legislation_code%TYPE;
  l_period_of_service_id   per_all_assignments_f.period_of_service_id%TYPE;
  l_proc                 varchar2(72) := g_package||'create_secondary_apl_asg';
  l_effective_date         date;
  l_date_probation_end     date;
  l_soft_coding_keyflex_id per_all_assignments_f.soft_coding_keyflex_id%TYPE := p_soft_coding_keyflex_id;
  l_scl_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE  ;
  l_old_scl_conc_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_flex_num                   fnd_id_flex_segments.id_flex_num%TYPE;
  l_session_id             number;
  l_cagr_grade_def_id      per_cagr_grades_def.cagr_grade_def_id%TYPE := p_cagr_grade_def_id;
  l_cagr_concatenated_segments varchar2(2000);
  l_appl_date_end          per_applications.date_end%TYPE;
  --
  -- bug 2230915 new variables to indicate whether key flex id parameters
  -- enter the program with a value.
  --
  l_pgp_null_ind               number(1) := 0;
  l_scl_null_ind               number(1) := 0;
  l_cag_null_ind               number(1) := 0;
  --
  -- Bug 2230915 new variables for derived values where key flex id is known.
  --
  l_scl_segment1               varchar2(60) := p_scl_segment1;
  l_scl_segment2               varchar2(60) := p_scl_segment2;
  l_scl_segment3               varchar2(60) := p_scl_segment3;
  l_scl_segment4               varchar2(60) := p_scl_segment4;
  l_scl_segment5               varchar2(60) := p_scl_segment5;
  l_scl_segment6               varchar2(60) := p_scl_segment6;
  l_scl_segment7               varchar2(60) := p_scl_segment7;
  l_scl_segment8               varchar2(60) := p_scl_segment8;
  l_scl_segment9               varchar2(60) := p_scl_segment9;
  l_scl_segment10              varchar2(60) := p_scl_segment10;
  l_scl_segment11              varchar2(60) := p_scl_segment11;
  l_scl_segment12              varchar2(60) := p_scl_segment12;
  l_scl_segment13              varchar2(60) := p_scl_segment13;
  l_scl_segment14              varchar2(60) := p_scl_segment14;
  l_scl_segment15              varchar2(60) := p_scl_segment15;
  l_scl_segment16              varchar2(60) := p_scl_segment16;
  l_scl_segment17              varchar2(60) := p_scl_segment17;
  l_scl_segment18              varchar2(60) := p_scl_segment18;
  l_scl_segment19              varchar2(60) := p_scl_segment19;
  l_scl_segment20              varchar2(60) := p_scl_segment20;
  l_scl_segment21              varchar2(60) := p_scl_segment21;
  l_scl_segment22              varchar2(60) := p_scl_segment22;
  l_scl_segment23              varchar2(60) := p_scl_segment23;
  l_scl_segment24              varchar2(60) := p_scl_segment24;
  l_scl_segment25              varchar2(60) := p_scl_segment25;
  l_scl_segment26              varchar2(60) := p_scl_segment26;
  l_scl_segment27              varchar2(60) := p_scl_segment27;
  l_scl_segment28              varchar2(60) := p_scl_segment28;
  l_scl_segment29              varchar2(60) := p_scl_segment29;
  l_scl_segment30              varchar2(60) := p_scl_segment30;
  --
  l_pgp_segment1               varchar2(60) := p_pgp_segment1;
  l_pgp_segment2               varchar2(60) := p_pgp_segment2;
  l_pgp_segment3               varchar2(60) := p_pgp_segment3;
  l_pgp_segment4               varchar2(60) := p_pgp_segment4;
  l_pgp_segment5               varchar2(60) := p_pgp_segment5;
  l_pgp_segment6               varchar2(60) := p_pgp_segment6;
  l_pgp_segment7               varchar2(60) := p_pgp_segment7;
  l_pgp_segment8               varchar2(60) := p_pgp_segment8;
  l_pgp_segment9               varchar2(60) := p_pgp_segment9;
  l_pgp_segment10              varchar2(60) := p_pgp_segment10;
  l_pgp_segment11              varchar2(60) := p_pgp_segment11;
  l_pgp_segment12              varchar2(60) := p_pgp_segment12;
  l_pgp_segment13              varchar2(60) := p_pgp_segment13;
  l_pgp_segment14              varchar2(60) := p_pgp_segment14;
  l_pgp_segment15              varchar2(60) := p_pgp_segment15;
  l_pgp_segment16              varchar2(60) := p_pgp_segment16;
  l_pgp_segment17              varchar2(60) := p_pgp_segment17;
  l_pgp_segment18              varchar2(60) := p_pgp_segment18;
  l_pgp_segment19              varchar2(60) := p_pgp_segment19;
  l_pgp_segment20              varchar2(60) := p_pgp_segment20;
  l_pgp_segment21              varchar2(60) := p_pgp_segment21;
  l_pgp_segment22              varchar2(60) := p_pgp_segment22;
  l_pgp_segment23              varchar2(60) := p_pgp_segment23;
  l_pgp_segment24              varchar2(60) := p_pgp_segment24;
  l_pgp_segment25              varchar2(60) := p_pgp_segment25;
  l_pgp_segment26              varchar2(60) := p_pgp_segment26;
  l_pgp_segment27              varchar2(60) := p_pgp_segment27;
  l_pgp_segment28              varchar2(60) := p_pgp_segment28;
  l_pgp_segment29              varchar2(60) := p_pgp_segment29;
  l_pgp_segment30              varchar2(60) := p_pgp_segment30;
  --
  l_cag_segment1               varchar2(60) := p_cag_segment1;
  l_cag_segment2               varchar2(60) := p_cag_segment2;
  l_cag_segment3               varchar2(60) := p_cag_segment3;
  l_cag_segment4               varchar2(60) := p_cag_segment4;
  l_cag_segment5               varchar2(60) := p_cag_segment5;
  l_cag_segment6               varchar2(60) := p_cag_segment6;
  l_cag_segment7               varchar2(60) := p_cag_segment7;
  l_cag_segment8               varchar2(60) := p_cag_segment8;
  l_cag_segment9               varchar2(60) := p_cag_segment9;
  l_cag_segment10              varchar2(60) := p_cag_segment10;
  l_cag_segment11              varchar2(60) := p_cag_segment11;
  l_cag_segment12              varchar2(60) := p_cag_segment12;
  l_cag_segment13              varchar2(60) := p_cag_segment13;
  l_cag_segment14              varchar2(60) := p_cag_segment14;
  l_cag_segment15              varchar2(60) := p_cag_segment15;
  l_cag_segment16              varchar2(60) := p_cag_segment16;
  l_cag_segment17              varchar2(60) := p_cag_segment17;
  l_cag_segment18              varchar2(60) := p_cag_segment18;
  l_cag_segment19              varchar2(60) := p_cag_segment19;
  l_cag_segment20              varchar2(60) := p_cag_segment20;
  --
  lv_cagr_grade_def_id         number := p_cagr_grade_def_id ;
  lv_people_group_id           number := p_people_group_id ;
  lv_soft_coding_keyflex_id    number := p_people_group_id ;
  --
  l_applicant_number          per_all_people_f.applicant_number%TYPE;
  l_per_object_version_number per_all_people_f.object_version_number%TYPE;
  l_appl_override_warning     boolean;
  l_per_effective_start_date  per_all_people_f.effective_start_date%TYPE;
  l_per_effective_end_date    per_all_people_f.effective_end_date%TYPE;
  l_apl_object_version_number per_applications.object_version_number%TYPE;
  --

  cursor csr_get_derived_details is
    select bus.business_group_id
         , bus.legislation_code
         , per.applicant_number, per.object_version_number  --3652025
      from per_all_people_f    per
         , per_business_groups_perf bus
     where per.person_id         = p_person_id
     and   l_effective_date      between per.effective_start_date
                                 and     per.effective_end_date
     and   bus.business_group_id = per.business_group_id;
  --
  -- 3652025 >>
  cursor csr_get_application is
   select apl.application_id, apl.date_end
     from per_applications apl
    where apl.person_id = p_person_id
      and l_effective_date between apl.date_received
                               and nvl(apl.date_end,hr_api.g_eot);
  -- <<
  cursor csr_get_apl_asg is
    select asg.application_id
      from per_all_assignments_f asg
     where asg.person_id    = p_person_id
     and   l_effective_date between asg.effective_start_date
                            and     asg.effective_end_date
     and   asg.assignment_type = 'A';
  --
  --
  cursor csr_grp_idsel is
    select bus.people_group_structure
     from  per_business_groups_perf bus
     where bus.business_group_id = l_business_group_id;
  --
  cursor csr_scl_idsel is
    select plr.rule_mode                       id_flex_num
    from   pay_legislation_rules               plr,
           per_business_groups_perf            pgr
    where  plr.legislation_code                = pgr.legislation_code
    and    pgr.business_group_id               = l_business_group_id
    and    plr.rule_type                       = 'S'
    and    exists
          (select 1
           from   fnd_segment_attribute_values fsav
           where  fsav.id_flex_num             = plr.rule_mode
           and    fsav.application_id          = 800
           and    fsav.id_flex_code            = 'SCL'
           and    fsav.segment_attribute_type  = 'ASSIGNMENT'
           and    fsav.attribute_value         = 'Y')
    and    exists
          (select 1
           from   pay_legislation_rules        plr2
           where  plr2.legislation_code        = plr.legislation_code
           and    plr2.rule_type               = 'SDL'
           and    plr2.rule_mode               = 'A') ;
  --
  --
  -- bug 2230915 get pay_people_group segment values where
  -- people_group_id is known
  --
  cursor c_pgp_segments is
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
     from   pay_people_groups
     where  people_group_id = l_people_group_id;
  --
  -- bug 2230915 get hr_soft_coding_keyflex segment values where
  -- soft_coding_keyflex_id is known
  --
  cursor c_scl_segments is
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
     from   hr_soft_coding_keyflex
     where  soft_coding_keyflex_id = l_soft_coding_keyflex_id;
  --
  -- bug 2230915 get per_cagr_grades_def segment values where
  -- cagr_grade_def_id is known
  --
  cursor c_cag_segments is
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
            segment20
     from   per_cagr_grades_def
     where  cagr_grade_def_id = l_cagr_grade_def_id;
  --
  l_assignment_status_type_id  per_all_assignments_f.assignment_status_type_id%TYPE;
--
begin
--
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  -- Truncate date value p_effective_date to remove time element.
  --
  l_effective_date := trunc(p_effective_date);
  l_date_probation_end := trunc(p_date_probation_end);
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
-- replaced p_group_name by p_concat_segments
  l_old_group_name       := p_concat_segments;
-- Bug 944911
-- Amended p_scl_concatenated_segments to p_scl_concat_segments
  l_old_scl_conc_segments := p_scl_concat_segments;
  --
  -- Issue a savepoint.
  --
  savepoint create_secondary_apl_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Validation in addition to Table Handlers
  --
  -- Get person details.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'effective_date'
     ,p_argument_value => l_effective_date
     );
  --
  -- Validate the person_id exists, if it does get the business group and
  -- legislation code.
  --
  open  csr_get_derived_details;
  fetch csr_get_derived_details
   into l_business_group_id
      , l_legislation_code, l_applicant_number, l_per_object_version_number;
  --
  if csr_get_derived_details%NOTFOUND then
    --
    close csr_get_derived_details;
    --
 if g_debug then
    hr_utility.set_location(l_proc, 15);
 end if;
    --
    hr_utility.set_message(801,'HR_7432_ASG_INVALID_PERSON');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;
  --
  -- Bug 2230915 - if p_people_group_id enters with
  -- a value then get segment values from pay_people_groups.
  -- Do the same with the key flex ids for hr_soft_coding_keyflex and
  -- per_cagr_grades_def
  --
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  if l_people_group_id is not null
  then
     l_pgp_null_ind := 1;
     --
     open c_pgp_segments;
       fetch c_pgp_segments into l_pgp_segment1,
                                 l_pgp_segment2,
                                 l_pgp_segment3,
                                 l_pgp_segment4,
                                 l_pgp_segment5,
                                 l_pgp_segment6,
                                 l_pgp_segment7,
                                 l_pgp_segment8,
                                 l_pgp_segment9,
                                 l_pgp_segment10,
                                 l_pgp_segment11,
                                 l_pgp_segment12,
                                 l_pgp_segment13,
                                 l_pgp_segment14,
                                 l_pgp_segment15,
                                 l_pgp_segment16,
                                 l_pgp_segment17,
                                 l_pgp_segment18,
                                 l_pgp_segment19,
                                 l_pgp_segment20,
                                 l_pgp_segment21,
                                 l_pgp_segment22,
                                 l_pgp_segment23,
                                 l_pgp_segment24,
                                 l_pgp_segment25,
                                 l_pgp_segment26,
                                 l_pgp_segment27,
                                 l_pgp_segment28,
                                 l_pgp_segment29,
                                 l_pgp_segment30;
     close c_pgp_segments;
  else
     l_pgp_null_ind := 0;
  end if;
  --  use cursor c_scl_segments to bring back segment values if
  --  l_soft_coding_keyflex has a value.
  if l_soft_coding_keyflex_id is not null
  then
     l_scl_null_ind := 1;
     open c_scl_segments;
       fetch c_scl_segments into l_scl_segment1,
                                 l_scl_segment2,
                                 l_scl_segment3,
                                 l_scl_segment4,
                                 l_scl_segment5,
                                 l_scl_segment6,
                                 l_scl_segment7,
                                 l_scl_segment8,
                                 l_scl_segment9,
                                 l_scl_segment10,
                                 l_scl_segment11,
                                 l_scl_segment12,
                                 l_scl_segment13,
                                 l_scl_segment14,
                                 l_scl_segment15,
                                 l_scl_segment16,
                                 l_scl_segment17,
                                 l_scl_segment18,
                                 l_scl_segment19,
                                 l_scl_segment20,
                                 l_scl_segment21,
                                 l_scl_segment22,
                                 l_scl_segment23,
                                 l_scl_segment24,
                                 l_scl_segment25,
                                 l_scl_segment26,
                                 l_scl_segment27,
                                 l_scl_segment28,
                                 l_scl_segment29,
                                 l_scl_segment30;
     close c_scl_segments;
  else
     l_scl_null_ind := 0;
  end if;
  --
  -- if cagr_grade_def_id has a value then use it to get segment values using
  -- cursor cag_segments
  --
  if l_cagr_grade_def_id is not null
  then
     l_cag_null_ind := 1;
     open c_cag_segments;
       fetch c_cag_segments into l_cag_segment1,
                                 l_cag_segment2,
                                 l_cag_segment3,
                                 l_cag_segment4,
                                 l_cag_segment5,
                                 l_cag_segment6,
                                 l_cag_segment7,
                                 l_cag_segment8,
                                 l_cag_segment9,
                                 l_cag_segment10,
                                 l_cag_segment11,
                                 l_cag_segment12,
                                 l_cag_segment13,
                                 l_cag_segment14,
                                 l_cag_segment15,
                                 l_cag_segment16,
                                 l_cag_segment17,
                                 l_cag_segment18,
                                 l_cag_segment19,
                                 l_cag_segment20;
     close c_cag_segments;
  else
     l_cag_null_ind := 0;
  end if;
  --
  -- Start of API User Hook for the before hook of create_secondary_apl_asg.
  --
  begin
     hr_assignment_bk8.create_secondary_apl_asg_b
       (p_effective_date               =>     l_effective_date
       ,p_person_id                    =>     p_person_id
       ,p_organization_id              =>     p_organization_id
       ,p_recruiter_id                 =>     p_recruiter_id
       ,p_grade_id                     =>     p_grade_id
       ,p_position_id                  =>     p_position_id
       ,p_job_id                       =>     p_job_id
       ,p_payroll_id                   =>     p_payroll_id
       ,p_assignment_status_type_id    =>     p_assignment_status_type_id
       ,p_location_id                  =>     p_location_id
       ,p_person_referred_by_id        =>     p_person_referred_by_id
       ,p_supervisor_id                =>     p_supervisor_id
       ,p_special_ceiling_step_id      =>     p_special_ceiling_step_id
       ,p_recruitment_activity_id      =>     p_recruitment_activity_id
       ,p_source_organization_id       =>     p_source_organization_id
       ,p_vacancy_id                   =>     p_vacancy_id
       ,p_pay_basis_id                 =>     p_pay_basis_id
       ,p_change_reason                =>     p_change_reason
       ,p_internal_address_line        =>     p_internal_address_line
       ,p_comments                     =>     p_comments
       ,p_date_probation_end           =>     l_date_probation_end
       ,p_default_code_comb_id         =>     p_default_code_comb_id
       ,p_employment_category          =>     p_employment_category
       ,p_frequency                    =>     p_frequency
       ,p_manager_flag                 =>     p_manager_flag
       ,p_normal_hours                 =>     p_normal_hours
       ,p_perf_review_period           =>     p_perf_review_period
       ,p_perf_review_period_frequency =>     p_perf_review_period_frequency
       ,p_probation_period             =>     p_probation_period
       ,p_probation_unit               =>     p_probation_unit
       ,p_sal_review_period            =>     p_sal_review_period
       ,p_sal_review_period_frequency  =>     p_sal_review_period_frequency
       ,p_set_of_books_id              =>     p_set_of_books_id
       ,p_source_type                  =>     p_source_type
       ,p_time_normal_finish           =>     p_time_normal_finish
       ,p_time_normal_start            =>     p_time_normal_start
       ,p_bargaining_unit_code         =>     p_bargaining_unit_code
       ,p_ass_attribute_category       =>     p_ass_attribute_category
       ,p_ass_attribute1               =>     p_ass_attribute1
       ,p_ass_attribute2               =>     p_ass_attribute2
       ,p_ass_attribute3               =>     p_ass_attribute3
       ,p_ass_attribute4               =>     p_ass_attribute4
       ,p_ass_attribute5               =>     p_ass_attribute5
       ,p_ass_attribute6               =>     p_ass_attribute6
       ,p_ass_attribute7               =>     p_ass_attribute7
       ,p_ass_attribute8               =>     p_ass_attribute8
       ,p_ass_attribute9               =>     p_ass_attribute9
       ,p_ass_attribute10              =>     p_ass_attribute10
       ,p_ass_attribute11              =>     p_ass_attribute11
       ,p_ass_attribute12              =>     p_ass_attribute12
       ,p_ass_attribute13              =>     p_ass_attribute13
       ,p_ass_attribute14              =>     p_ass_attribute14
       ,p_ass_attribute15              =>     p_ass_attribute15
       ,p_ass_attribute16              =>     p_ass_attribute16
       ,p_ass_attribute17              =>     p_ass_attribute17
       ,p_ass_attribute18              =>     p_ass_attribute18
       ,p_ass_attribute19              =>     p_ass_attribute19
       ,p_ass_attribute20              =>     p_ass_attribute20
       ,p_ass_attribute21              =>     p_ass_attribute21
       ,p_ass_attribute22              =>     p_ass_attribute22
       ,p_ass_attribute23              =>     p_ass_attribute23
       ,p_ass_attribute24              =>     p_ass_attribute24
       ,p_ass_attribute25              =>     p_ass_attribute25
       ,p_ass_attribute26              =>     p_ass_attribute26
       ,p_ass_attribute27              =>     p_ass_attribute27
       ,p_ass_attribute28              =>     p_ass_attribute28
       ,p_ass_attribute29              =>     p_ass_attribute29
       ,p_ass_attribute30              =>     p_ass_attribute30
       ,p_title                        =>     p_title
       --
       -- Bug 2230915
       -- Amended p_scl/pgp/cag_segments to be l_scl/pgp/cag_segments
       --
       ,p_scl_segment1                 =>     l_scl_segment1
       ,p_scl_segment2                 =>     l_scl_segment2
       ,p_scl_segment3                 =>     l_scl_segment3
       ,p_scl_segment4                 =>     l_scl_segment4
       ,p_scl_segment5                 =>     l_scl_segment5
       ,p_scl_segment6                 =>     l_scl_segment6
       ,p_scl_segment7                 =>     l_scl_segment7
       ,p_scl_segment8                 =>     l_scl_segment8
       ,p_scl_segment9                 =>     l_scl_segment9
       ,p_scl_segment10                =>     l_scl_segment10
       ,p_scl_segment11                =>     l_scl_segment11
       ,p_scl_segment12                =>     l_scl_segment12
       ,p_scl_segment13                =>     l_scl_segment13
       ,p_scl_segment14                =>     l_scl_segment14
       ,p_scl_segment15                =>     l_scl_segment15
       ,p_scl_segment16                =>     l_scl_segment16
       ,p_scl_segment17                =>     l_scl_segment17
       ,p_scl_segment18                =>     l_scl_segment18
       ,p_scl_segment19                =>     l_scl_segment19
       ,p_scl_segment20                =>     l_scl_segment20
       ,p_scl_segment21                =>     l_scl_segment21
       ,p_scl_segment22                =>     l_scl_segment22
       ,p_scl_segment23                =>     l_scl_segment23
       ,p_scl_segment24                =>     l_scl_segment24
       ,p_scl_segment25                =>     l_scl_segment25
       ,p_scl_segment26                =>     l_scl_segment26
       ,p_scl_segment27                =>     l_scl_segment27
       ,p_scl_segment28                =>     l_scl_segment28
       ,p_scl_segment29                =>     l_scl_segment29
       ,p_scl_segment30                =>     l_scl_segment30
       --
       -- Bug 944911
       -- Amended p_scl_concatenated_segments to be p_scl_concat_segments
       --
       ,p_scl_concat_segments          =>     l_old_scl_conc_segments
       ,p_pgp_segment1                 =>     l_pgp_segment1
       ,p_pgp_segment2                 =>     l_pgp_segment2
       ,p_pgp_segment3                 =>     l_pgp_segment3
       ,p_pgp_segment4                 =>     l_pgp_segment4
       ,p_pgp_segment5                 =>     l_pgp_segment5
       ,p_pgp_segment6                 =>     l_pgp_segment6
       ,p_pgp_segment7                 =>     l_pgp_segment7
       ,p_pgp_segment8                 =>     l_pgp_segment8
       ,p_pgp_segment9                 =>     l_pgp_segment9
       ,p_pgp_segment10                =>     l_pgp_segment10
       ,p_pgp_segment11                =>     l_pgp_segment11
       ,p_pgp_segment12                =>     l_pgp_segment12
       ,p_pgp_segment13                =>     l_pgp_segment13
       ,p_pgp_segment14                =>     l_pgp_segment14
       ,p_pgp_segment15                =>     l_pgp_segment15
       ,p_pgp_segment16                =>     l_pgp_segment16
       ,p_pgp_segment17                =>     l_pgp_segment17
       ,p_pgp_segment18                =>     l_pgp_segment18
       ,p_pgp_segment19                =>     l_pgp_segment19
       ,p_pgp_segment20                =>     l_pgp_segment20
       ,p_pgp_segment21                =>     l_pgp_segment21
       ,p_pgp_segment22                =>     l_pgp_segment22
       ,p_pgp_segment23                =>     l_pgp_segment23
       ,p_pgp_segment24                =>     l_pgp_segment24
       ,p_pgp_segment25                =>     l_pgp_segment25
       ,p_pgp_segment26                =>     l_pgp_segment26
       ,p_pgp_segment27                =>     l_pgp_segment27
       ,p_pgp_segment28                =>     l_pgp_segment28
       ,p_pgp_segment29                =>     l_pgp_segment29
       ,p_pgp_segment30                =>     l_pgp_segment30
       --
       -- Bug 944911
       -- Amended p_group_name to be p_concat_segments
       --
       ,p_concat_segments              => l_old_group_name
       ,p_business_group_id            => l_business_group_id
       ,p_contract_id                  => p_contract_id
       ,p_establishment_id             => p_establishment_id
       ,p_collective_agreement_id      => p_collective_agreement_id
       ,p_cagr_id_flex_num             => p_cagr_id_flex_num
       ,p_cag_segment1                 => l_cag_segment1
       ,p_cag_segment2                 => l_cag_segment2
       ,p_cag_segment3                 => l_cag_segment3
       ,p_cag_segment4                 => l_cag_segment4
       ,p_cag_segment5                 => l_cag_segment5
       ,p_cag_segment6                 => l_cag_segment6
       ,p_cag_segment7                 => l_cag_segment7
       ,p_cag_segment8                 => l_cag_segment8
       ,p_cag_segment9                 => l_cag_segment9
       ,p_cag_segment10                => l_cag_segment10
       ,p_cag_segment11                => l_cag_segment11
       ,p_cag_segment12                => l_cag_segment12
       ,p_cag_segment13                => l_cag_segment13
       ,p_cag_segment14                => l_cag_segment14
       ,p_cag_segment15                => l_cag_segment15
       ,p_cag_segment16                => l_cag_segment16
       ,p_cag_segment17                => l_cag_segment17
       ,p_cag_segment18                => l_cag_segment18
       ,p_cag_segment19                => l_cag_segment19
       ,p_cag_segment20                => l_cag_segment20
       ,p_notice_period		       => p_notice_period
       ,p_notice_period_uom	       => p_notice_period_uom
       ,p_employee_category	       => p_employee_category
       ,p_work_at_home		       => p_work_at_home
       ,p_job_post_source_name	       => p_job_post_source_name
       ,p_applicant_rank               => p_applicant_rank
       ,p_posting_content_id           => p_posting_content_id
       ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
       ,p_supervisor_assignment_id     => p_supervisor_assignment_id
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_SECONDARY_APL_ASG',
          p_hook_type         => 'BP'
         );
  end;
  --
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Process Logic
  --
  -- Get the application_id from an existing applicant assignment for the
  -- person specified. If no applicant assignment exists then this person
  -- cannot be an applicant.
  --
  -- 3652025 >>
  --open  csr_get_apl_asg;
  --fetch csr_get_apl_asg
   --into l_application_id;
  --
  open csr_get_application;
  fetch csr_get_application into l_application_id, l_appl_date_end;

  if csr_get_application%NOTFOUND then
    --
    close csr_get_application;
    --
    if g_debug then
       hr_utility.set_location(l_proc, 25);
    end if;
    --
    hr_utility.set_message(801,'HR_51231_ASG_MISSING_ASG');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_application;
  -- <<
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  --
  -- insert the profile options and effective date for the flexfield
  -- validation to work
  --
  --
  hr_kflex_utility.set_profiles
  (p_business_group_id => l_business_group_id
  ,p_assignment_id     => l_assignment_id
  ,p_organization_id   => p_organization_id
  ,p_location_id       => p_location_id);
  --
  hr_kflex_utility.set_session_date
  (p_effective_date => l_effective_date
  ,p_session_id     => l_session_id);
  --
  -- Maintain the people group key flexfields.
  --
  open csr_grp_idsel;
  fetch csr_grp_idsel
  into l_flex_num;
     if csr_grp_idsel%NOTFOUND then
       close csr_grp_idsel;
          hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE', l_proc);
          hr_utility.set_message_token('STEP','10');
          hr_utility.raise_error;
     end if;
  close csr_grp_idsel;
  --
  --
  -- Maintain the people group key flexfields.
  --
  open csr_grp_idsel;
  fetch csr_grp_idsel
  into l_flex_num;
     if csr_grp_idsel%NOTFOUND then
       close csr_grp_idsel;
          hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE', l_proc);
          hr_utility.set_message_token('STEP','10');
          hr_utility.raise_error;
     end if;
  close csr_grp_idsel;
  --
  -- Bug 2230915 - if key flex parameters have a value then derive segment
  -- values from them
  --
  if l_people_group_id is null
  then
     --
     hr_kflex_utility.upd_or_sel_keyflex_comb
       (p_appl_short_name        => 'PAY'
       ,p_flex_code              => 'GRP'
       ,p_flex_num               => l_flex_num
       ,p_segment1               => l_pgp_segment1
       ,p_segment2               => l_pgp_segment2
       ,p_segment3               => l_pgp_segment3
       ,p_segment4               => l_pgp_segment4
       ,p_segment5               => l_pgp_segment5
       ,p_segment6               => l_pgp_segment6
       ,p_segment7               => l_pgp_segment7
       ,p_segment8               => l_pgp_segment8
       ,p_segment9               => l_pgp_segment9
       ,p_segment10              => l_pgp_segment10
       ,p_segment11              => l_pgp_segment11
       ,p_segment12              => l_pgp_segment12
       ,p_segment13              => l_pgp_segment13
       ,p_segment14              => l_pgp_segment14
       ,p_segment15              => l_pgp_segment15
       ,p_segment16              => l_pgp_segment16
       ,p_segment17              => l_pgp_segment17
       ,p_segment18              => l_pgp_segment18
       ,p_segment19              => l_pgp_segment19
       ,p_segment20              => l_pgp_segment20
       ,p_segment21              => l_pgp_segment21
       ,p_segment22              => l_pgp_segment22
       ,p_segment23              => l_pgp_segment23
       ,p_segment24              => l_pgp_segment24
       ,p_segment25              => l_pgp_segment25
       ,p_segment26              => l_pgp_segment26
       ,p_segment27              => l_pgp_segment27
       ,p_segment28              => l_pgp_segment28
       ,p_segment29              => l_pgp_segment29
       ,p_segment30              => l_pgp_segment30
       ,p_concat_segments_in     => l_old_group_name
       ,p_ccid                   => l_people_group_id
       ,p_concat_segments_out    => l_group_name
       );
  end if;
  --
  -- update the combinations column
  --
  update_pgp_concat_segs
    (p_people_group_id        => l_people_group_id
    ,p_group_name             => l_group_name
    );
  --
  -- select or insert the Collective Agreement grade
  --
 if g_debug then
  hr_utility.set_location(l_proc, 36);
 end if;
  --
  if l_cagr_grade_def_id is null
  then
     hr_cgd_ins.ins_or_sel
     (p_segment1               => l_cag_segment1
     ,p_segment2               => l_cag_segment2
     ,p_segment3               => l_cag_segment3
     ,p_segment4               => l_cag_segment4
     ,p_segment5               => l_cag_segment5
     ,p_segment6               => l_cag_segment6
     ,p_segment7               => l_cag_segment7
     ,p_segment8               => l_cag_segment8
     ,p_segment9               => l_cag_segment9
     ,p_segment10              => l_cag_segment10
     ,p_segment11              => l_cag_segment11
     ,p_segment12              => l_cag_segment12
     ,p_segment13              => l_cag_segment13
     ,p_segment14              => l_cag_segment14
     ,p_segment15              => l_cag_segment15
     ,p_segment16              => l_cag_segment16
     ,p_segment17              => l_cag_segment17
     ,p_segment18              => l_cag_segment18
     ,p_segment19              => l_cag_segment19
     ,p_segment20              => l_cag_segment20
     ,p_id_flex_num            => p_cagr_id_flex_num
     ,p_business_group_id      => l_business_group_id
     ,p_cagr_grade_def_id      => l_cagr_grade_def_id
     ,p_concatenated_segments  => l_cagr_concatenated_segments
      );
  end if;
     --
  if l_soft_coding_keyflex_id is null
  then
     --
     if   l_scl_segment1 is not null
       or l_scl_segment2 is not null
       or l_scl_segment3 is not null
       or l_scl_segment4 is not null
       or l_scl_segment5 is not null
       or l_scl_segment6 is not null
       or l_scl_segment7 is not null
       or l_scl_segment8 is not null
       or l_scl_segment9 is not null
       or l_scl_segment10 is not null
       or l_scl_segment11 is not null
       or l_scl_segment12 is not null
       or l_scl_segment13 is not null
       or l_scl_segment14 is not null
       or l_scl_segment15 is not null
       or l_scl_segment16 is not null
       or l_scl_segment17 is not null
       or l_scl_segment18 is not null
       or l_scl_segment19 is not null
       or l_scl_segment20 is not null
       or l_scl_segment21 is not null
       or l_scl_segment22 is not null
       or l_scl_segment23 is not null
       or l_scl_segment24 is not null
       or l_scl_segment25 is not null
       or l_scl_segment26 is not null
       or l_scl_segment27 is not null
       or l_scl_segment28 is not null
       or l_scl_segment29 is not null
       or l_scl_segment30 is not null
       --
       -- bug 944911
       -- Added this additional check
       --
       or p_scl_concat_segments is not null
     then
        open csr_scl_idsel;
        fetch csr_scl_idsel into l_flex_num;
        if csr_scl_idsel%NOTFOUND
        then
           close csr_scl_idsel;
 if g_debug then
           hr_utility.set_location(l_proc, 28);
 end if;
           --
           hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
           hr_utility.set_message_token('PROCEDURE', l_proc);
           hr_utility.set_message_token('STEP','10');
           hr_utility.raise_error;
        else
           close csr_scl_idsel;
           --
           --
 if g_debug then
           hr_utility.set_location(l_proc, 30);
 end if;
           --
           -- Insert or select the soft_coding_keyflex_id
           --
           hr_kflex_utility.ins_or_sel_keyflex_comb
           (p_appl_short_name        => 'PER'
           ,p_flex_code              => 'SCL'
           ,p_flex_num               => l_flex_num
           ,p_segment1               => l_scl_segment1
           ,p_segment2               => l_scl_segment2
           ,p_segment3               => l_scl_segment3
           ,p_segment4               => l_scl_segment4
           ,p_segment5               => l_scl_segment5
           ,p_segment6               => l_scl_segment6
           ,p_segment7               => l_scl_segment7
           ,p_segment8               => l_scl_segment8
           ,p_segment9               => l_scl_segment9
           ,p_segment10              => l_scl_segment10
           ,p_segment11              => l_scl_segment11
           ,p_segment12              => l_scl_segment12
           ,p_segment13              => l_scl_segment13
           ,p_segment14              => l_scl_segment14
           ,p_segment15              => l_scl_segment15
           ,p_segment16              => l_scl_segment16
           ,p_segment17              => l_scl_segment17
           ,p_segment18              => l_scl_segment18
           ,p_segment19              => l_scl_segment19
           ,p_segment20              => l_scl_segment20
           ,p_segment21              => l_scl_segment21
           ,p_segment22              => l_scl_segment22
           ,p_segment23              => l_scl_segment23
           ,p_segment24              => l_scl_segment24
           ,p_segment25              => l_scl_segment25
           ,p_segment26              => l_scl_segment26
           ,p_segment27              => l_scl_segment27
           ,p_segment28              => l_scl_segment28
           ,p_segment29              => l_scl_segment29
           ,p_segment30              => l_scl_segment30
           ,p_concat_segments_in     => l_old_scl_conc_segments
           ,p_ccid                   => l_soft_coding_keyflex_id
           ,p_concat_segments_out    => l_scl_concatenated_segments
           );
           --
           -- update the combinations column
           --
           update_scl_concat_segs
           (p_soft_coding_keyflex_id  => l_soft_coding_keyflex_id
           ,p_concatenated_segments   => l_scl_concatenated_segments
           );
        --
       end if;
     --
    end if;
   --
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 35);
 end if;
  --
  -- 3652025: if application is end dated then call internal procedure
  --
  if l_appl_date_end is not null then
  --
  -- Application is end dated
  --
      if g_debug then
        hr_utility.set_location(l_proc, 40);
      end if;

      hr_applicant_internal.create_applicant_anytime
        (p_effective_date                => l_effective_date
        ,p_person_id                     => p_person_id
        ,p_applicant_number              => l_applicant_number
        ,p_per_object_version_number     => l_per_object_version_number
        ,p_vacancy_id                    => p_vacancy_id
        ,p_person_type_id                => null
        ,p_assignment_status_type_id     => p_assignment_status_type_id
        ,p_application_id                => l_application_id
        ,p_assignment_id                 => l_assignment_id
        ,p_apl_object_version_number     => l_apl_object_version_number
        ,p_asg_object_version_number     => l_object_version_number
        ,p_assignment_sequence           => l_assignment_sequence
        ,p_per_effective_start_date      => l_per_effective_start_date
        ,p_per_effective_end_date        => l_per_effective_end_date
        ,p_appl_override_warning         => l_appl_override_warning
        );

      if g_debug then
        hr_utility.set_location(l_proc, 45);
      end if;
      --
      -- 3972045: If p_assignment_status_type_id is null, derive default status for
      -- person's business group.
      --
      if p_assignment_status_type_id is null then
         per_people3_pkg.get_default_person_type
           (p_required_type     => 'ACTIVE_APL'
           ,p_business_group_id => l_business_group_id
           ,p_legislation_code  => l_legislation_code
           ,p_person_type       => l_assignment_status_type_id
          );
      else
         l_assignment_status_type_id := p_assignment_status_type_id;
      end if;
      --
      hr_assignment_api.update_apl_asg
            (p_validate                    => FALSE
            ,p_effective_date              => l_effective_date
            ,p_datetrack_update_mode       => hr_api.g_correction
            ,p_assignment_id               => l_assignment_id
            ,p_object_version_number       => l_object_version_number
            ,p_recruiter_id                => p_recruiter_id
            ,p_grade_id                    => p_grade_id
            ,p_position_id                 => p_position_id
            ,p_job_id                      => p_job_id
            ,p_payroll_id                  => p_payroll_id
            ,p_location_id                 => p_location_id
            ,p_person_referred_by_id       => p_person_referred_by_id
            ,p_supervisor_id               => p_supervisor_id
            ,p_special_ceiling_step_id     => p_special_ceiling_step_id
            ,p_recruitment_activity_id     => p_recruitment_activity_id
            ,p_source_organization_id      => p_source_organization_id
            ,p_organization_id             => p_organization_id
            ,p_vacancy_id                  => p_vacancy_id
            ,p_pay_basis_id                => p_pay_basis_id
            ,p_application_id              => l_application_id
            ,p_change_reason               => p_change_reason
            ,p_assignment_status_type_id   => l_assignment_status_type_id
            ,p_comments                    => p_comments
            ,p_date_probation_end          => l_date_probation_end
            ,p_default_code_comb_id        => p_default_code_comb_id
            ,p_employment_category         => p_employment_category
            ,p_frequency                    => p_frequency
            ,p_internal_address_line        => p_internal_address_line
            ,p_manager_flag                 => p_manager_flag
            ,p_normal_hours                 => p_normal_hours
            ,p_perf_review_period           => p_perf_review_period
            ,p_perf_review_period_frequency => p_perf_review_period_frequency
            ,p_probation_period             => p_probation_period
            ,p_probation_unit               => p_probation_unit
            ,p_sal_review_period            => p_sal_review_period
            ,p_sal_review_period_frequency  => p_sal_review_period_frequency
            ,p_set_of_books_id              => p_set_of_books_id
            ,p_source_type                  => p_source_type
            ,p_time_normal_finish           => p_time_normal_finish
            ,p_time_normal_start            => p_time_normal_start
            ,p_bargaining_unit_code         => p_bargaining_unit_code
            ,p_ass_attribute_category       => p_ass_attribute_category
            ,p_ass_attribute1               => p_ass_attribute1
            ,p_ass_attribute2               => p_ass_attribute2
            ,p_ass_attribute3               => p_ass_attribute3
            ,p_ass_attribute4               => p_ass_attribute4
            ,p_ass_attribute5               => p_ass_attribute5
            ,p_ass_attribute6               => p_ass_attribute6
            ,p_ass_attribute7               => p_ass_attribute7
            ,p_ass_attribute8               => p_ass_attribute8
            ,p_ass_attribute9               => p_ass_attribute9
            ,p_ass_attribute10              => p_ass_attribute10
            ,p_ass_attribute11              => p_ass_attribute11
            ,p_ass_attribute12              => p_ass_attribute12
            ,p_ass_attribute13              => p_ass_attribute13
            ,p_ass_attribute14              => p_ass_attribute14
            ,p_ass_attribute15              => p_ass_attribute15
            ,p_ass_attribute16              => p_ass_attribute16
            ,p_ass_attribute17              => p_ass_attribute17
            ,p_ass_attribute18              => p_ass_attribute18
            ,p_ass_attribute19              => p_ass_attribute19
            ,p_ass_attribute20              => p_ass_attribute20
            ,p_ass_attribute21              => p_ass_attribute21
            ,p_ass_attribute22              => p_ass_attribute22
            ,p_ass_attribute23              => p_ass_attribute23
            ,p_ass_attribute24              => p_ass_attribute24
            ,p_ass_attribute25              => p_ass_attribute25
            ,p_ass_attribute26              => p_ass_attribute26
            ,p_ass_attribute27              => p_ass_attribute27
            ,p_ass_attribute28              => p_ass_attribute28
            ,p_ass_attribute29              => p_ass_attribute29
            ,p_ass_attribute30              => p_ass_attribute30
            ,p_scl_segment1                 =>     l_scl_segment1
            ,p_scl_segment2                 =>     l_scl_segment2
            ,p_scl_segment3                 =>     l_scl_segment3
            ,p_scl_segment4                 =>     l_scl_segment4
            ,p_scl_segment5                 =>     l_scl_segment5
            ,p_scl_segment6                 =>     l_scl_segment6
            ,p_scl_segment7                 =>     l_scl_segment7
            ,p_scl_segment8                 =>     l_scl_segment8
            ,p_scl_segment9                 =>     l_scl_segment9
            ,p_scl_segment10                =>     l_scl_segment10
            ,p_scl_segment11                =>     l_scl_segment11
            ,p_scl_segment12                =>     l_scl_segment12
            ,p_scl_segment13                =>     l_scl_segment13
            ,p_scl_segment14                =>     l_scl_segment14
            ,p_scl_segment15                =>     l_scl_segment15
            ,p_scl_segment16                =>     l_scl_segment16
            ,p_scl_segment17                =>     l_scl_segment17
            ,p_scl_segment18                =>     l_scl_segment18
            ,p_scl_segment19                =>     l_scl_segment19
            ,p_scl_segment20                =>     l_scl_segment20
            ,p_scl_segment21                =>     l_scl_segment21
            ,p_scl_segment22                =>     l_scl_segment22
            ,p_scl_segment23                =>     l_scl_segment23
            ,p_scl_segment24                =>     l_scl_segment24
            ,p_scl_segment25                =>     l_scl_segment25
            ,p_scl_segment26                =>     l_scl_segment26
            ,p_scl_segment27                =>     l_scl_segment27
            ,p_scl_segment28                => l_scl_segment28
            ,p_scl_segment29                => l_scl_segment29
            ,p_scl_segment30                => l_scl_segment30
            ,p_scl_concat_segments          => l_old_scl_conc_segments
            ,p_concatenated_segments        => l_scl_concatenated_segments
            ,p_pgp_segment1                 =>     l_pgp_segment1
            ,p_pgp_segment2                 =>     l_pgp_segment2
            ,p_pgp_segment3                 =>     l_pgp_segment3
            ,p_pgp_segment4                 =>     l_pgp_segment4
            ,p_pgp_segment5                 =>     l_pgp_segment5
            ,p_pgp_segment6                 =>     l_pgp_segment6
            ,p_pgp_segment7                 =>     l_pgp_segment7
            ,p_pgp_segment8                 =>     l_pgp_segment8
            ,p_pgp_segment9                 =>     l_pgp_segment9
            ,p_pgp_segment10                =>     l_pgp_segment10
            ,p_pgp_segment11                =>     l_pgp_segment11
            ,p_pgp_segment12                =>     l_pgp_segment12
            ,p_pgp_segment13                =>     l_pgp_segment13
            ,p_pgp_segment14                =>     l_pgp_segment14
            ,p_pgp_segment15                =>     l_pgp_segment15
            ,p_pgp_segment16                =>     l_pgp_segment16
            ,p_pgp_segment17                =>     l_pgp_segment17
            ,p_pgp_segment18                =>     l_pgp_segment18
            ,p_pgp_segment19                =>     l_pgp_segment19
            ,p_pgp_segment20                =>     l_pgp_segment20
            ,p_pgp_segment21                =>     l_pgp_segment21
            ,p_pgp_segment22                =>     l_pgp_segment22
            ,p_pgp_segment23                =>     l_pgp_segment23
            ,p_pgp_segment24                =>     l_pgp_segment24
            ,p_pgp_segment25                =>     l_pgp_segment25
            ,p_pgp_segment26                =>     l_pgp_segment26
            ,p_pgp_segment27                =>     l_pgp_segment27
            ,p_pgp_segment28                =>     l_pgp_segment28
            ,p_pgp_segment29                =>     l_pgp_segment29
            ,p_pgp_segment30                =>     l_pgp_segment30
            ,p_concat_segments              => l_old_group_name
            ,p_contract_id                  => p_contract_id
            ,p_establishment_id             => p_establishment_id
            ,p_collective_agreement_id      => p_collective_agreement_id
            ,p_cagr_id_flex_num             => p_cagr_id_flex_num
            ,p_cag_segment1                 => l_cag_segment1
            ,p_cag_segment2                 => l_cag_segment2
            ,p_cag_segment3                 => l_cag_segment3
            ,p_cag_segment4                 => l_cag_segment4
            ,p_cag_segment5                 => l_cag_segment5
            ,p_cag_segment6                 => l_cag_segment6
            ,p_cag_segment7                 => l_cag_segment7
            ,p_cag_segment8                 => l_cag_segment8
            ,p_cag_segment9                 => l_cag_segment9
            ,p_cag_segment10                => l_cag_segment10
            ,p_cag_segment11                => l_cag_segment11
            ,p_cag_segment12                => l_cag_segment12
            ,p_cag_segment13                => l_cag_segment13
            ,p_cag_segment14                => l_cag_segment14
            ,p_cag_segment15                => l_cag_segment15
            ,p_cag_segment16                => l_cag_segment16
            ,p_cag_segment17                => l_cag_segment17
            ,p_cag_segment18                => l_cag_segment18
            ,p_cag_segment19                => l_cag_segment19
            ,p_cag_segment20                => l_cag_segment20
            ,p_title                        => p_title
            ,p_notice_period                    => p_notice_period
            ,p_notice_period_uom                => p_notice_period_uom
            ,p_employee_category                => p_employee_category
            ,p_work_at_home                         => p_work_at_home
            ,p_job_post_source_name             => p_job_post_source_name
            ,p_cagr_grade_def_id            => l_cagr_grade_def_id
            ,p_effective_start_date         => l_effective_start_date
            ,p_effective_end_date           => l_effective_end_date
            ,p_comment_id                   => l_comment_id
            ,p_applicant_rank               => p_applicant_rank
            ,p_posting_content_id           => p_posting_content_id
            ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
            ,p_supervisor_assignment_id     => p_supervisor_assignment_id
            ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
            ,p_group_name                   => l_group_name
            ,p_people_group_id              => l_people_group_id
            ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
         );

      if g_debug then
        hr_utility.set_location(l_proc, 50);
      end if;
  else -- application is not end dated
  --
  -- Insert secondary assignment
  --
    hr_assignment_internal.create_apl_asg
    (p_effective_date               => l_effective_date
    ,p_legislation_code             => l_legislation_code
    ,p_business_group_id            => l_business_group_id
    ,p_person_id                    => p_person_id
    ,p_organization_id              => p_organization_id
    ,p_application_id               => l_application_id
    ,p_recruiter_id                 => p_recruiter_id
    ,p_grade_id                     => p_grade_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_person_referred_by_id        => p_person_referred_by_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_special_ceiling_step_id      => p_special_ceiling_step_id
    ,p_recruitment_activity_id      => p_recruitment_activity_id
    ,p_source_organization_id       => p_source_organization_id
    ,p_people_group_id              => l_people_group_id
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_change_reason                => p_change_reason
    ,p_comments                     => p_comments
    ,p_date_probation_end           => l_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_employment_category          => p_employment_category
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_title                        => p_title
    ,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    ,p_collective_agreement_id      => p_collective_agreement_id
    ,p_cagr_id_flex_num             => p_cagr_id_flex_num
    ,p_notice_period		    => p_notice_period
    ,p_notice_period_uom	    => p_notice_period_uom
    ,p_employee_category	    => p_employee_category
    ,p_work_at_home		    => p_work_at_home
    ,p_job_post_source_name	    => p_job_post_source_name
    ,p_cagr_grade_def_id            => l_cagr_grade_def_id
    ,p_assignment_id                => l_assignment_id
    ,p_object_version_number        => l_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_assignment_sequence          => l_assignment_sequence
    ,p_comment_id                   => l_comment_id
    ,p_applicant_rank               => p_applicant_rank
    ,p_posting_content_id           => p_posting_content_id
    ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;

  end if; -- application is end dated?
  --
  -- add to the security list if neccesary
  --
  if(l_effective_date<=sysdate) then
    hr_security_internal.add_to_person_list(l_effective_date,l_assignment_id);
  end if;
  --
  --
  -- Start of API User Hook for the after hook of create_secondary_apl_asg.
  --
  begin
     hr_assignment_bk8.create_secondary_apl_asg_a
       (p_effective_date               =>     l_effective_date
       ,p_person_id                    =>     p_person_id
       ,p_organization_id              =>     p_organization_id
       ,p_recruiter_id                 =>     p_recruiter_id
       ,p_grade_id                     =>     p_grade_id
       ,p_position_id                  =>     p_position_id
       ,p_job_id                       =>     p_job_id
       ,p_payroll_id                   =>     p_payroll_id
       ,p_assignment_status_type_id    =>     p_assignment_status_type_id
       ,p_location_id                  =>     p_location_id
       ,p_person_referred_by_id        =>     p_person_referred_by_id
       ,p_supervisor_id                =>     p_supervisor_id
       ,p_special_ceiling_step_id      =>     p_special_ceiling_step_id
       ,p_recruitment_activity_id      =>     p_recruitment_activity_id
       ,p_source_organization_id       =>     p_source_organization_id
       ,p_vacancy_id                   =>     p_vacancy_id
       ,p_pay_basis_id                 =>     p_pay_basis_id
       ,p_change_reason                =>     p_change_reason
       ,p_internal_address_line        =>     p_internal_address_line
       ,p_comments                     =>     p_comments
       ,p_date_probation_end           =>     l_date_probation_end
       ,p_default_code_comb_id         =>     p_default_code_comb_id
       ,p_employment_category          =>     p_employment_category
       ,p_frequency                    =>     p_frequency
       ,p_manager_flag                 =>     p_manager_flag
       ,p_normal_hours                 =>     p_normal_hours
       ,p_perf_review_period           =>     p_perf_review_period
       ,p_perf_review_period_frequency =>     p_perf_review_period_frequency
       ,p_probation_period             =>     p_probation_period
       ,p_probation_unit               =>     p_probation_unit
       ,p_sal_review_period            =>     p_sal_review_period
       ,p_sal_review_period_frequency  =>     p_sal_review_period_frequency
       ,p_set_of_books_id              =>     p_set_of_books_id
       ,p_source_type                  =>     p_source_type
       ,p_time_normal_finish           =>     p_time_normal_finish
       ,p_time_normal_start            =>     p_time_normal_start
       ,p_bargaining_unit_code         =>     p_bargaining_unit_code
       ,p_ass_attribute_category       =>     p_ass_attribute_category
       ,p_ass_attribute1               =>     p_ass_attribute1
       ,p_ass_attribute2               =>     p_ass_attribute2
       ,p_ass_attribute3               =>     p_ass_attribute3
       ,p_ass_attribute4               =>     p_ass_attribute4
       ,p_ass_attribute5               =>     p_ass_attribute5
       ,p_ass_attribute6               =>     p_ass_attribute6
       ,p_ass_attribute7               =>     p_ass_attribute7
       ,p_ass_attribute8               =>     p_ass_attribute8
       ,p_ass_attribute9               =>     p_ass_attribute9
       ,p_ass_attribute10              =>     p_ass_attribute10
       ,p_ass_attribute11              =>     p_ass_attribute11
       ,p_ass_attribute12              =>     p_ass_attribute12
       ,p_ass_attribute13              =>     p_ass_attribute13
       ,p_ass_attribute14              =>     p_ass_attribute14
       ,p_ass_attribute15              =>     p_ass_attribute15
       ,p_ass_attribute16              =>     p_ass_attribute16
       ,p_ass_attribute17              =>     p_ass_attribute17
       ,p_ass_attribute18              =>     p_ass_attribute18
       ,p_ass_attribute19              =>     p_ass_attribute19
       ,p_ass_attribute20              =>     p_ass_attribute20
       ,p_ass_attribute21              =>     p_ass_attribute21
       ,p_ass_attribute22              =>     p_ass_attribute22
       ,p_ass_attribute23              =>     p_ass_attribute23
       ,p_ass_attribute24              =>     p_ass_attribute24
       ,p_ass_attribute25              =>     p_ass_attribute25
       ,p_ass_attribute26              =>     p_ass_attribute26
       ,p_ass_attribute27              =>     p_ass_attribute27
       ,p_ass_attribute28              =>     p_ass_attribute28
       ,p_ass_attribute29              =>     p_ass_attribute29
       ,p_ass_attribute30              =>     p_ass_attribute30
       ,p_title                        =>     p_title
       ,p_scl_segment1                 =>     l_scl_segment1
       ,p_scl_segment2                 =>     l_scl_segment2
       ,p_scl_segment3                 =>     l_scl_segment3
       ,p_scl_segment4                 =>     l_scl_segment4
       ,p_scl_segment5                 =>     l_scl_segment5
       ,p_scl_segment6                 =>     l_scl_segment6
       ,p_scl_segment7                 =>     l_scl_segment7
       ,p_scl_segment8                 =>     l_scl_segment8
       ,p_scl_segment9                 =>     l_scl_segment9
       ,p_scl_segment10                =>     l_scl_segment10
       ,p_scl_segment11                =>     l_scl_segment11
       ,p_scl_segment12                =>     l_scl_segment12
       ,p_scl_segment13                =>     l_scl_segment13
       ,p_scl_segment14                =>     l_scl_segment14
       ,p_scl_segment15                =>     l_scl_segment15
       ,p_scl_segment16                =>     l_scl_segment16
       ,p_scl_segment17                =>     l_scl_segment17
       ,p_scl_segment18                =>     l_scl_segment18
       ,p_scl_segment19                =>     l_scl_segment19
       ,p_scl_segment20                =>     l_scl_segment20
       ,p_scl_segment21                =>     l_scl_segment21
       ,p_scl_segment22                =>     l_scl_segment22
       ,p_scl_segment23                =>     l_scl_segment23
       ,p_scl_segment24                =>     l_scl_segment24
       ,p_scl_segment25                =>     l_scl_segment25
       ,p_scl_segment26                =>     l_scl_segment26
       ,p_scl_segment27                =>     l_scl_segment27
       ,p_scl_segment28                =>     l_scl_segment28
       ,p_scl_segment29                =>     l_scl_segment29
       ,p_scl_segment30                =>     l_scl_segment30
-- Bug 944911
-- Amended p_scl_concatenated_segments to be p_concatenated_segments
       ,p_concatenated_segments        =>     l_scl_concatenated_segments
       ,p_pgp_segment1                 =>     l_pgp_segment1
       ,p_pgp_segment2                 =>     l_pgp_segment2
       ,p_pgp_segment3                 =>     l_pgp_segment3
       ,p_pgp_segment4                 =>     l_pgp_segment4
       ,p_pgp_segment5                 =>     l_pgp_segment5
       ,p_pgp_segment6                 =>     l_pgp_segment6
       ,p_pgp_segment7                 =>     l_pgp_segment7
       ,p_pgp_segment8                 =>     l_pgp_segment8
       ,p_pgp_segment9                 =>     l_pgp_segment9
       ,p_pgp_segment10                =>     l_pgp_segment10
       ,p_pgp_segment11                =>     l_pgp_segment11
       ,p_pgp_segment12                =>     l_pgp_segment12
       ,p_pgp_segment13                =>     l_pgp_segment13
       ,p_pgp_segment14                =>     l_pgp_segment14
       ,p_pgp_segment15                =>     l_pgp_segment15
       ,p_pgp_segment16                =>     l_pgp_segment16
       ,p_pgp_segment17                =>     l_pgp_segment17
       ,p_pgp_segment18                =>     l_pgp_segment18
       ,p_pgp_segment19                =>     l_pgp_segment19
       ,p_pgp_segment20                =>     l_pgp_segment20
       ,p_pgp_segment21                =>     l_pgp_segment21
       ,p_pgp_segment22                =>     l_pgp_segment22
       ,p_pgp_segment23                =>     l_pgp_segment23
       ,p_pgp_segment24                =>     l_pgp_segment24
       ,p_pgp_segment25                =>     l_pgp_segment25
       ,p_pgp_segment26                =>     l_pgp_segment26
       ,p_pgp_segment27                =>     l_pgp_segment27
       ,p_pgp_segment28                =>     l_pgp_segment28
       ,p_pgp_segment29                =>     l_pgp_segment29
       ,p_pgp_segment30                =>     l_pgp_segment30
       ,p_group_name                   =>     l_group_name
       ,p_assignment_id                =>     l_assignment_id
       ,p_object_version_number        =>     l_object_version_number
       ,p_effective_start_date         =>     l_effective_start_date
       ,p_effective_end_date           =>     l_effective_end_date
       ,p_assignment_sequence          =>     l_assignment_sequence
       ,p_comment_id                   =>     l_comment_id
       ,p_people_group_id              =>     l_people_group_id
       ,p_soft_coding_keyflex_id       =>     l_soft_coding_keyflex_id
       ,p_business_group_id            =>     l_business_group_id
       ,p_contract_id                  => p_contract_id
       ,p_establishment_id             => p_establishment_id
       ,p_collective_agreement_id      => p_collective_agreement_id
       ,p_cagr_id_flex_num             => p_cagr_id_flex_num
       ,p_cag_segment1                 => l_cag_segment1
       ,p_cag_segment2                 => l_cag_segment2
       ,p_cag_segment3                 => l_cag_segment3
       ,p_cag_segment4                 => l_cag_segment4
       ,p_cag_segment5                 => l_cag_segment5
       ,p_cag_segment6                 => l_cag_segment6
       ,p_cag_segment7                 => l_cag_segment7
       ,p_cag_segment8                 => l_cag_segment8
       ,p_cag_segment9                 => l_cag_segment9
       ,p_cag_segment10                => l_cag_segment10
       ,p_cag_segment11                => l_cag_segment11
       ,p_cag_segment12                => l_cag_segment12
       ,p_cag_segment13                => l_cag_segment13
       ,p_cag_segment14                => l_cag_segment14
       ,p_cag_segment15                => l_cag_segment15
       ,p_cag_segment16                => l_cag_segment16
       ,p_cag_segment17                => l_cag_segment17
       ,p_cag_segment18                => l_cag_segment18
       ,p_cag_segment19                => l_cag_segment19
       ,p_cag_segment20                => l_cag_segment20
       ,p_notice_period		       => p_notice_period
       ,p_notice_period_uom	       => p_notice_period_uom
       ,p_employee_category	       => p_employee_category
       ,p_work_at_home		       => p_work_at_home
       ,p_job_post_source_name	       => p_job_post_source_name
       ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
       ,p_cagr_grade_def_id            => l_cagr_grade_def_id
-- Added the 2 new in params
-- Bug 944911
-- Amended p_scl_concatenated_segments to be p_scl_concat_segments
       ,p_scl_concat_segments          => l_old_scl_conc_segments
-- Bug 944911
-- Amended p_group_name to be p_concat_segments
       ,p_concat_segments              => l_old_group_name
       ,p_applicant_rank               => p_applicant_rank
       ,p_posting_content_id           => p_posting_content_id
       ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
       ,p_supervisor_assignment_id     => p_supervisor_assignment_id
 );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_SECONDARY_APL_ASG',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of create_secondary_apl_asg.
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set remaining output arguments
  --
  p_assignment_id          := l_assignment_id;
  p_people_group_id        := l_people_group_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_assignment_sequence    := l_assignment_sequence;
  p_comment_id             := l_comment_id;
  p_group_name             := l_group_name;
  p_soft_coding_keyflex_id := l_soft_coding_keyflex_id;
  p_appl_override_warning  := l_appl_override_warning; -- 3652025
-- Bug 944911
-- Amended p_scl_concatenated_segments to be p_concatenated_segments
  p_concatenated_segments  := l_scl_concatenated_segments;
  p_cagr_grade_def_id           := l_cagr_grade_def_id;
  p_cagr_concatenated_segments  := l_cagr_concatenated_segments;

  --
  --
  -- remove data from the session table
  hr_kflex_utility.unset_session_date
    (p_session_id     => l_session_id);
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 50);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_secondary_apl_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_assignment_id          := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_assignment_sequence    := null;
    p_comment_id             := null;
    --
    -- bug 2230915 only re-set to null if key flex ids came in as null.
    --
    if l_pgp_null_ind = 0
    then
       p_people_group_id           := null;
    end if;
    --
    p_group_name                   := l_old_group_name;
    --
    if l_scl_null_ind = 0
    then
       p_soft_coding_keyflex_id    := null;
    end if;
    --
    --Bug 944911
    p_concatenated_segments        := l_old_scl_conc_segments;
    --
    if l_cag_null_ind = 0
    then
       p_cagr_grade_def_id         := null;
    end if;
    --
    p_cagr_concatenated_segments   := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --

    p_cagr_grade_def_id         := lv_cagr_grade_def_id ;
    p_people_group_id           := lv_people_group_id ;
    p_soft_coding_keyflex_id    := lv_people_group_id ;

    p_concatenated_segments           := null;
    p_cagr_concatenated_segments      := null;
    p_group_name                      := null;
    p_assignment_id                   := null;
    p_comment_id                      := null;
    p_object_version_number           := null;
    p_effective_start_date            := null;
    p_effective_end_date              := null;
    p_assignment_sequence             := null;

    ROLLBACK TO create_secondary_apl_asg;
    raise;
    --
    -- End of fix.
    --
end create_secondary_apl_asg;
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_secondary_apl_asg >--R11---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_secondary_apl_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_recruiter_id                 in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_assignment_status_type_id    in     number
  ,p_location_id                  in     number
  ,p_person_referred_by_id        in     number
  ,p_supervisor_id                in     number
  ,p_recruitment_activity_id      in     number
  ,p_source_organization_id       in     number
  ,p_vacancy_id                   in     number
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_frequency                    in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_segment1                     in     varchar2
  ,p_segment2                     in     varchar2
  ,p_segment3                     in     varchar2
  ,p_segment4                     in     varchar2
  ,p_segment5                     in     varchar2
  ,p_segment6                     in     varchar2
  ,p_segment7                     in     varchar2
  ,p_segment8                     in     varchar2
  ,p_segment9                     in     varchar2
  ,p_segment10                    in     varchar2
  ,p_segment11                    in     varchar2
  ,p_segment12                    in     varchar2
  ,p_segment13                    in     varchar2
  ,p_segment14                    in     varchar2
  ,p_segment15                    in     varchar2
  ,p_segment16                    in     varchar2
  ,p_segment17                    in     varchar2
  ,p_segment18                    in     varchar2
  ,p_segment19                    in     varchar2
  ,p_segment20                    in     varchar2
  ,p_segment21                    in     varchar2
  ,p_segment22                    in     varchar2
  ,p_segment23                    in     varchar2
  ,p_segment24                    in     varchar2
  ,p_segment25                    in     varchar2
  ,p_segment26                    in     varchar2
  ,p_segment27                    in     varchar2
  ,p_segment28                    in     varchar2
  ,p_segment29                    in     varchar2
  ,p_segment30                    in     varchar2
-- Bug 944911
-- Made p_group_name to be out param
-- and add p_concat_segment to be IN
-- in case of sec_asg alone made p_pgp_concat_segments as in param
-- Reverting changes are it is for R11
  -- ,p_concat_segments              in     varchar2
  ,p_supervisor_assignment_id     in     number
  ,p_group_name                   in out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_people_group_id                 out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_assignment_id          per_all_assignments_f.assignment_id%TYPE;
  l_people_group_id        per_all_assignments_f.people_group_id%TYPE;
  l_object_version_number  per_all_assignments_f.object_version_number%TYPE;
  l_effective_start_date   per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date     per_all_assignments_f.effective_end_date%TYPE;
  l_assignment_sequence    per_all_assignments_f.assignment_sequence%TYPE;
  l_comment_id             per_all_assignments_f.comment_id%TYPE;
  l_group_name             pay_people_groups.group_name%TYPE;
  l_flex_num	           fnd_id_flex_segments.id_flex_num%TYPE;
  l_application_id         per_applications.application_id%TYPE;
  l_business_group_id      per_business_groups.business_group_id%TYPE;
  l_legislation_code       per_business_groups.legislation_code%TYPE;
  l_period_of_service_id   per_all_assignments_f.period_of_service_id%TYPE;
  l_proc                   varchar2(72);
  l_soft_coding_keyflex_id per_all_assignments_f.soft_coding_keyflex_id%TYPE;
  l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_effective_date         date;
  l_date_probation_end     date;
  l_cagr_concatenated_segments varchar2(3000);
  l_cagr_grade_def_id      number;

  --
begin
  --
 if g_debug then
 l_proc := g_package||'create_secondary_apl_asg';
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
   -- Call the new code
-- Bug 944911
-- No change to call point as all outs are present while the ins have defaults
  hr_assignment_api.create_secondary_apl_asg(
   p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_person_id                    => p_person_id
  ,p_organization_id              => p_organization_id
  ,p_recruiter_id                 => p_recruiter_id
  ,p_grade_id                     => p_grade_id
  ,p_position_id                  => p_position_id
  ,p_job_id                       => p_job_id
  ,p_assignment_status_type_id    => p_assignment_status_type_id
  ,p_location_id                  => p_location_id
  ,p_person_referred_by_id        => p_person_referred_by_id
  ,p_supervisor_id                => p_supervisor_id
  ,p_recruitment_activity_id      => p_recruitment_activity_id
  ,p_source_organization_id       => p_source_organization_id
  ,p_vacancy_id                   => p_vacancy_id
  ,p_change_reason                => p_change_reason
  ,p_comments                     => p_comments
  ,p_date_probation_end           => p_date_probation_end
  ,p_frequency                    => p_frequency
  ,p_manager_flag                 => p_manager_flag
  ,p_normal_hours                 => p_normal_hours
  ,p_probation_period             => p_probation_period
  ,p_probation_unit               => p_probation_unit
  ,p_source_type                  => p_source_type
  ,p_time_normal_finish           => p_time_normal_finish
  ,p_time_normal_start            => p_time_normal_start
  ,p_ass_attribute_category       => p_ass_attribute_category
  ,p_ass_attribute1               => p_ass_attribute1
  ,p_ass_attribute2               => p_ass_attribute2
  ,p_ass_attribute3               => p_ass_attribute3
  ,p_ass_attribute4               => p_ass_attribute4
  ,p_ass_attribute5               => p_ass_attribute5
  ,p_ass_attribute6               => p_ass_attribute6
  ,p_ass_attribute7               => p_ass_attribute7
  ,p_ass_attribute8               => p_ass_attribute8
  ,p_ass_attribute9               => p_ass_attribute9
  ,p_ass_attribute10              => p_ass_attribute10
  ,p_ass_attribute11              => p_ass_attribute11
  ,p_ass_attribute12              => p_ass_attribute12
  ,p_ass_attribute13              => p_ass_attribute13
  ,p_ass_attribute14              => p_ass_attribute14
  ,p_ass_attribute15              => p_ass_attribute15
  ,p_ass_attribute16              => p_ass_attribute16
  ,p_ass_attribute17              => p_ass_attribute17
  ,p_ass_attribute18              => p_ass_attribute18
  ,p_ass_attribute19              => p_ass_attribute19
  ,p_ass_attribute20              => p_ass_attribute20
  ,p_ass_attribute21              => p_ass_attribute21
  ,p_ass_attribute22              => p_ass_attribute22
  ,p_ass_attribute23              => p_ass_attribute23
  ,p_ass_attribute24              => p_ass_attribute24
  ,p_ass_attribute25              => p_ass_attribute25
  ,p_ass_attribute26              => p_ass_attribute26
  ,p_ass_attribute27              => p_ass_attribute27
  ,p_ass_attribute28              => p_ass_attribute28
  ,p_ass_attribute29              => p_ass_attribute29
  ,p_ass_attribute30              => p_ass_attribute30
  ,p_title                        => p_title
  ,p_pgp_segment1                     => p_segment1
  ,p_pgp_segment2                     => p_segment2
  ,p_pgp_segment3                     => p_segment3
  ,p_pgp_segment4                     => p_segment4
  ,p_pgp_segment5                     => p_segment5
  ,p_pgp_segment6                     => p_segment6
  ,p_pgp_segment7                     => p_segment7
  ,p_pgp_segment8                     => p_segment8
  ,p_pgp_segment9                     => p_segment9
  ,p_pgp_segment10                    => p_segment10
  ,p_pgp_segment11                    => p_segment11
  ,p_pgp_segment12                    => p_segment12
  ,p_pgp_segment13                    => p_segment13
  ,p_pgp_segment14                    => p_segment14
  ,p_pgp_segment15                    => p_segment15
  ,p_pgp_segment16                    => p_segment16
  ,p_pgp_segment17                    => p_segment17
  ,p_pgp_segment18                    => p_segment18
  ,p_pgp_segment19                    => p_segment19
  ,p_pgp_segment20                    => p_segment20
  ,p_pgp_segment21                    => p_segment21
  ,p_pgp_segment22                    => p_segment22
  ,p_pgp_segment23                    => p_segment23
  ,p_pgp_segment24                    => p_segment24
  ,p_pgp_segment25                    => p_segment25
  ,p_pgp_segment26                    => p_segment26
  ,p_pgp_segment27                    => p_segment27
  ,p_pgp_segment28                    => p_segment28
  ,p_pgp_segment29                    => p_segment29
  ,p_pgp_segment30                    => p_segment30
  ,p_assignment_id                => l_assignment_id
  ,p_people_group_id              => l_people_group_id
  ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
  ,p_comment_id                   => l_comment_id
  ,p_object_version_number        => l_object_version_number
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ,p_group_name                   => l_group_name
-- Bug 944911
  ,p_concatenated_segments    => l_concatenated_segments
  ,p_assignment_sequence          => l_assignment_sequence
  ,p_cagr_grade_def_id            => l_cagr_grade_def_id
  ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
  ,p_supervisor_assignment_id     => p_supervisor_assignment_id
  );
  -- Set remaining output arguments
  -- Ignore the new out parameters
  --
  p_assignment_id          := l_assignment_id;
  p_people_group_id        := l_people_group_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_assignment_sequence    := l_assignment_sequence;
  p_comment_id             := l_comment_id;
  p_group_name             := l_group_name;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 50);
 end if;
end create_secondary_apl_asg;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< offer_apl_asg >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure offer_apl_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number
  ,p_change_reason                in     varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number_orig number;
  l_effective_date             date;
  --
  -- Out variables
  --
  l_object_version_number  per_all_assignments_f.object_version_number%TYPE;
  l_effective_start_date   per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date     per_all_assignments_f.effective_end_date%TYPE;
  --
  lv_object_version_number     number := p_object_version_number ;
  --
  l_proc                 varchar2(72);
  --
begin
 if g_debug then
  l_proc := g_package||'offer_apl_asg';
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  -- Initialise local variable - added 25-Aug-97. RMF.
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Issue a savepoint.
  --
  savepoint offer_apl_asg;
  --
  -- Preserve IN OUT parameters for later use
  --
  l_object_version_number_orig := p_object_version_number;
  l_object_version_number      := p_object_version_number;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Process Logic
  --
  --
  -- Start of API User Hook for the before hook of offer_apl_asg.
  --
  begin
     hr_assignment_bk9.offer_apl_asg_b
       (p_effective_date               =>     l_effective_date
       ,p_datetrack_update_mode        =>     p_datetrack_update_mode
       ,p_assignment_id                =>     p_assignment_id
       ,p_object_version_number        =>     p_object_version_number
       ,p_assignment_status_type_id    =>     p_assignment_status_type_id
       ,p_change_reason                =>     p_change_reason
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'OFFER_APL_ASG',
          p_hook_type         => 'BP'
         );
  end;
  --
  hr_assignment_internal.update_status_type_apl_asg
      (p_effective_date            => l_effective_date
      ,p_datetrack_update_mode     => p_datetrack_update_mode
      ,p_assignment_id             => p_assignment_id
      ,p_object_version_number     => l_object_version_number
      ,p_expected_system_status    => 'OFFER'
      ,p_assignment_status_type_id => p_assignment_status_type_id
      ,p_change_reason             => p_change_reason
      ,p_effective_start_date      => l_effective_start_date
      ,p_effective_end_date        => l_effective_end_date
      );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Start of API User Hook for the after hook of offer_apl_asg.
  --
  begin
     hr_assignment_bk9.offer_apl_asg_a
       (p_effective_date               =>     l_effective_date
       ,p_datetrack_update_mode        =>     p_datetrack_update_mode
       ,p_assignment_id                =>     p_assignment_id
       ,p_object_version_number        =>     l_object_version_number
       ,p_assignment_status_type_id    =>     p_assignment_status_type_id
       ,p_change_reason                =>     p_change_reason
       ,p_effective_start_date         =>     l_effective_start_date
       ,p_effective_end_date           =>     l_effective_end_date
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'OFFER_APL_ASG',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of offer_apl_asg.
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set remaining output arguments
  --
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
 --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 50);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO offer_apl_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number_orig;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number := lv_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    ROLLBACK TO offer_apl_asg;
    raise;
    --
    -- End of fix.
    --
end offer_apl_asg;
--

-- ----------------------------------------------------------------------------
-- |---------------------------< accept_apl_asg >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure accept_apl_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number
  ,p_change_reason                in     varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number_orig number;
  l_effective_date             date;
  --
  -- Out variables
  --
  l_object_version_number  per_all_assignments_f.object_version_number%TYPE;
  l_effective_start_date   per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date     per_all_assignments_f.effective_end_date%TYPE;
  --
  lv_object_version_number     number := p_object_version_number ;
  --
l_proc                 varchar2(72);
  --
begin
 if g_debug then
 l_proc := g_package||'accept_apl_asg';
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  --
  l_effective_date := trunc(p_effective_date);
  --
    savepoint accept_apl_asg;
  --
  -- Preserve IN OUT parameters for later use
  --
  l_object_version_number_orig := p_object_version_number;
  l_object_version_number      := p_object_version_number;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  --
  -- Process Logic
  --
  -- Start of API User Hook for the before hook of accept_apl_asg.
  --
  begin
     hr_assignment_bkb.accept_apl_asg_b
       (p_effective_date               =>     l_effective_date
       ,p_datetrack_update_mode        =>     p_datetrack_update_mode
       ,p_assignment_id                =>     p_assignment_id
       ,p_object_version_number        =>     p_object_version_number
       ,p_assignment_status_type_id    =>     p_assignment_status_type_id
       ,p_change_reason                =>     p_change_reason
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'ACCEPT_APL_ASG',
          p_hook_type         => 'BP'
         );
  end;
  -- End of API User Hook for the before hook of accept_apl_asg.

  --
  hr_assignment_internal.update_status_type_apl_asg
      (p_effective_date            => l_effective_date
      ,p_datetrack_update_mode     => p_datetrack_update_mode
      ,p_assignment_id             => p_assignment_id
    ,p_object_version_number     => l_object_version_number
      ,p_expected_system_status    => 'ACCEPTED'
      ,p_assignment_status_type_id => p_assignment_status_type_id
      ,p_change_reason             => p_change_reason
      ,p_effective_start_date      => l_effective_start_date
      ,p_effective_end_date        => l_effective_end_date
      );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Start of API User Hook for the after hook of accept_apl_asg.
  --
  begin
     hr_assignment_bkb.accept_apl_asg_a
       (p_effective_date               =>     l_effective_date
       ,p_datetrack_update_mode        =>     p_datetrack_update_mode
       ,p_assignment_id                =>     p_assignment_id
       ,p_object_version_number        =>     l_object_version_number
       ,p_assignment_status_type_id    =>     p_assignment_status_type_id
       ,p_change_reason                =>     p_change_reason
       ,p_effective_start_date         =>     l_effective_start_date
       ,p_effective_end_date           =>     l_effective_end_date
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'OFFER_APL_ASG',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of accept_apl_asg.
  --

--
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set remaining output arguments
  --
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
 --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 50);
 end if;
exception
  when hr_api.validate_enabled then
-- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO accept_apl_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number_orig;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

  When others then

    p_object_version_number := lv_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

      ROLLBACK TO accept_apl_asg;
       raise;
end accept_apl_asg;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< activate_apl_asg >-----------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE activate_apl_asg
  (p_validate                     IN     BOOLEAN
  ,p_effective_date               IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_assignment_status_type_id    IN     per_assignment_status_types.assignment_status_type_id%TYPE
  ,p_change_reason                IN     per_all_assignments_f.change_reason%TYPE
  ,p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  )
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72);
  --
  l_effective_date               DATE;
  --
  l_object_version_number        CONSTANT per_all_assignments_f.object_version_number%TYPE := p_object_version_number;
  --
  l_expected_system_status       per_assignment_status_types.per_system_status%TYPE    := 'ACTIVE_APL';
  l_effective_start_date         per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date           per_all_assignments_f.effective_end_date%TYPE;
 --
 lv_object_version_number     number := p_object_version_number ;
 --
--
BEGIN
  --
 if g_debug then
  l_proc := g_package||'activate_apl_asg';
  hr_utility.set_location('Entering:'||l_proc,10);
 end if;
  --
  -- Truncate all date parameters passed in
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Issue savepoint
  --
  SAVEPOINT activate_apl_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc,20);
 end if;
  --
  -- Call Before Process User Hook
  --
  BEGIN
     hr_assignment_bkc.activate_apl_asg_b
       (p_effective_date               => l_effective_date
       ,p_datetrack_update_mode        => p_datetrack_update_mode
       ,p_assignment_id                => p_assignment_id
       ,p_object_version_number        => p_object_version_number
       ,p_assignment_status_type_id    => p_assignment_status_type_id
       ,p_change_reason                => p_change_reason
       );
  EXCEPTION
     WHEN hr_api.cannot_find_prog_unit
     THEN
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'ACTIVATE_APL_ASG',
          p_hook_type         => 'BP'
         );
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc,30);
 end if;
  --
  -- Call business support process to update status type
  --
  hr_assignment_internal.update_status_type_apl_asg
    (p_effective_date               => l_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_expected_system_status       => l_expected_system_status
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_change_reason                => p_change_reason
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc,40);
 end if;
  --
  -- Call After Process User Hook
  --
  BEGIN
     hr_assignment_bkc.activate_apl_asg_a
       (p_effective_date               => l_effective_date
       ,p_datetrack_update_mode        => p_datetrack_update_mode
       ,p_assignment_id                => p_assignment_id
       ,p_object_version_number        => p_object_version_number
       ,p_assignment_status_type_id    => p_assignment_status_type_id
       ,p_change_reason                => p_change_reason
       ,p_effective_start_date         => l_effective_start_date
       ,p_effective_end_date           => l_effective_end_date
       );
  EXCEPTION
     WHEN hr_api.cannot_find_prog_unit
     THEN
       hr_api.cannot_find_prog_unit_error
         (p_module_name => 'ACTIVATE_APL_ASG',
          p_hook_type   => 'AP'
         );
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc,50);
 end if;
  --
  -- When in validation only mode raise validate_enabled exception
  --
  IF p_validate
  THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set OUT parameters
  --
  p_effective_start_date         := l_effective_start_date;
  p_effective_end_date           := l_effective_end_date;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,100);
 end if;
--
EXCEPTION
  WHEN hr_api.validate_enabled
  THEN
    --
    -- In validation only mode
    -- Rollback to savepoint
    -- Set relevant output warning arguments
    -- Reset any key or derived arguments
    --
    ROLLBACK TO activate_apl_asg;
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := NULL;
    p_effective_end_date           := NULL;
  --
  WHEN OTHERS
  THEN
    --
    -- Validation or unexpected error occured
    -- Rollback to savepoint
    -- Re-raise exception
    --
    p_object_version_number := lv_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    ROLLBACK TO activate_apl_asg;
    RAISE;
--
END activate_apl_asg;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< terminate_apl_asg >-----------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE terminate_apl_asg
  (p_validate                     IN     BOOLEAN
  ,p_effective_date               IN     DATE
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_status_type_id    IN  per_all_assignments_f.assignment_status_type_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  )
IS
BEGIN
   hr_assignment_api.terminate_apl_asg
  (p_validate                   => p_validate
  ,p_effective_date             => p_effective_date
  ,p_assignment_id              => p_assignment_id
  ,p_assignment_status_type_id  => p_assignment_status_type_id
  ,p_object_version_number      => p_object_version_number
  ,p_effective_start_date       => p_effective_start_date
  ,p_effective_end_date         => p_effective_end_date
  ,p_change_reason              => NULL -- 4066579
  );
END;
--
-- -----------------------------------------------------------------------------
-- |-----------------------< terminate_apl_asg(NEW) >---------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE terminate_apl_asg
  (p_validate                     IN     BOOLEAN
  ,p_effective_date               IN     DATE
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_status_type_id    IN  per_all_assignments_f.assignment_status_type_id%TYPE
  ,p_change_reason                IN  per_all_assignments_f.change_reason%TYPE -- 4066579
  ,p_status_change_comments       IN  irc_assignment_statuses.status_change_comments%TYPE  -- bug 8732296
  ,p_object_version_number        IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  )
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'terminate_apl_asg';
  --
  l_effective_date               DATE;
  --
  l_object_version_number        CONSTANT per_all_assignments_f.object_version_number%TYPE := p_object_version_number;
  --
  l_effective_start_date         per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date           per_all_assignments_f.effective_end_date%TYPE;
  --
  l_assignment_status_type_id    per_all_assignments_f.assignment_status_type_id%TYPE;
  l_business_group_id            hr_all_organization_units.organization_id%TYPE;
  l_validation_start_date        DATE;
  l_validation_end_date          DATE;
  l_org_now_no_manager_warning   BOOLEAN;
  --
  lv_object_version_number     number;
  --
  l_assignment_status_id  irc_assignment_statuses.assignment_status_id%type;
  l_asg_status_ovn        irc_assignment_statuses.object_version_number%type;
  -- 3652025 >>
  l_new_application_id          per_applications.application_id%TYPE;
  l_fut_asg_start_date          date;
  l_fut_asg_end_date            date;
  l_comment_id                  number;
  l_payroll_id_updated          boolean;
  l_other_manager_warning       boolean;
  l_no_managers_warning         boolean;
  l_asg_ovn                     number;
  l_asg_eff_date                date;
  l_hourly_salaried_warning     boolean;
  l_manager_terminates varchar2(1); -- added for bug 7577823
  l_user_id varchar2(250); -- added for bug 7577823

  -- <<
  -- Local cursors
  --
  -- fix for bug 7577823 starts
CURSOR csr_applicant_userid
    (p_assignment_id                IN
     per_all_assignments_f.assignment_id%TYPE
    ,p_effective_date               IN     DATE
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
and paf.assignment_id=p_assignment_id
and usr.user_id = fnd_global.user_id;
-- fix for bug 7577823 ends

  CURSOR csr_assignments
    (p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
    ,p_effective_date               IN     DATE
    )
  IS
    SELECT asg.assignment_type
          ,asg.business_group_id
          ,bus.legislation_code
          ,person_id ,effective_end_date, application_id
	  ,asg.assignment_status_type_id --7229710
      FROM per_all_assignments_f asg
          ,per_business_groups_perf bus
     WHERE asg.assignment_id = p_assignment_id
       AND bus.business_group_id = asg.business_group_id
       AND p_effective_date BETWEEN asg.effective_start_date
                                AND asg.effective_end_date;
  -- 3652025 >>
  CURSOR csr_get_current_apl_asg(cp_asg_id number, cp_effective_date date) IS
    SELECT as2.assignment_id, as2.effective_start_date
          ,as2.effective_end_date
    FROM per_all_assignments_f as2
        ,per_all_assignments_f as1
    WHERE as2.person_id = as1.person_id
    AND as2.assignment_type = as1.assignment_type
    AND cp_effective_date BETWEEN as2.effective_start_date
                             AND as2.effective_end_date
    AND as2.assignment_id <> as1.assignment_id
    AND as1.assignment_id = cp_asg_id;
  --
  CURSOR csr_get_future_apl_asg(cp_asg_id number, cp_effective_date date) IS
    SELECT as2.assignment_id, as2.business_group_id
         , as2.effective_start_date, as2.effective_end_date
         , as2.application_id, as2.person_id, as2.object_version_number
    FROM per_all_assignments_f as2
        ,per_all_assignments_f as1
    WHERE as2.person_id = as1.person_id
    AND as2.assignment_type = as1.assignment_type
    AND as2.effective_start_date > cp_effective_date
    AND as2.assignment_id <> as1.assignment_id
    AND as1.assignment_id = cp_asg_id
    ORDER BY as2.effective_start_date, as2.assignment_id ASC;
  --
  CURSOR csr_appl_details(cp_application_id number) IS
     select *
       from per_applications
      where application_id = cp_application_id;

  --  <<
  l_assignment            csr_assignments%ROWTYPE;
  l_fut_asg               csr_get_future_apl_asg%ROWTYPE;  -- 3652025 >>
  l_cur_asg               csr_get_current_apl_asg%ROWTYPE;
  l_appl_details          csr_appl_details%ROWTYPE;
  l_apl_object_version_number number;
  l_per_effective_start_date  date;
  l_per_effective_end_date    date; -- <<
  l_mx_end_dated              date;
  l_min_no_end_dated          date;
  --
  -- ----------------------------------------------------------------------- +
  -- ----------------------------------------------------------------------- +
  procedure end_assignment is
   --fix for bug 7229710 Start here.
   l_vacancy_id                   number;
   l_person_id number;

    Cursor csr_vacancy_id(l_assg_id number) is
Select vacancy_id
From per_all_assignments_f
Where assignment_id = l_assg_id
And p_effective_date between effective_start_date and effective_end_date;

cursor csr_person_id(l_assg_id number) is
select person_id
from per_all_assignments_f
where assignment_id=l_assg_id;
  --fix for bug 7229710 Ends here.

  begin
  per_asg_del.del
    (p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => l_effective_date
    ,p_datetrack_mode               => hr_api.g_delete
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => l_business_group_id
    ,p_validation_start_date        => l_validation_start_date
    ,p_validation_end_date          => l_validation_end_date
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    );
    --
    if g_debug then
    hr_utility.set_location(l_proc,70);
    end if;
    --
    per_asg_bus1.chk_assignment_status_type
      (p_assignment_status_type_id => l_assignment_status_type_id
      ,p_business_group_id         => l_assignment.business_group_id
      ,p_legislation_code          => l_assignment.legislation_code
      ,p_expected_system_status    => 'TERM_APL'
      );
    --fix for bug 7229710 Start here.
    delete from per_letter_request_lines plrl
    where plrl.assignment_id = p_assignment_id
    and   plrl.assignment_status_type_id = l_assignment.assignment_status_type_id
    and   exists
         (select null
          from per_letter_requests plr
          where plr.letter_request_id = plrl.letter_request_id
          and   plr.request_status = 'PENDING'
          and   plr.auto_or_manual = 'AUTO');

  per_app_asg_pkg.cleanup_letters
    (p_assignment_id => p_assignment_id);
  --
  -- Check if a letter request is necessary for the assignment.
  --
open csr_vacancy_id(p_assignment_id);
fetch csr_vacancy_id into l_vacancy_id;
if csr_vacancy_id%NOTFOUND then null;
end if;
close csr_vacancy_id;

open csr_person_id(p_assignment_id);
fetch csr_person_id into l_person_id;
if csr_person_id%NOTFOUND then null;
end if;
close csr_person_id;


  per_applicant_pkg.check_for_letter_requests
    (p_business_group_id            => l_assignment.business_group_id
    ,p_per_system_status            => null
    ,p_assignment_status_type_id    => l_assignment_status_type_id
    ,p_person_id                    => l_person_id
    ,p_assignment_id                => p_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_validation_start_date        => l_validation_start_date
    ,p_vacancy_id 		    => l_vacancy_id
    );
 --fix for bug 7229710 Ends here.

    IRC_ASG_STATUS_API.create_irc_asg_status
         (p_assignment_id               => p_assignment_id
         , p_assignment_status_type_id  => l_assignment_status_type_id
         , p_status_change_date         => p_effective_date
         , p_assignment_status_id       => l_assignment_status_id
         , p_status_change_reason       => p_change_reason -- 4066579
         , p_status_change_comments     => p_status_change_comments -- 8732296
         , p_object_version_number      => l_asg_status_ovn);

    --fix for bug 7577823 starts
        OPEN csr_applicant_userid
    (p_assignment_id                => p_assignment_id
    ,p_effective_date               => p_effective_date
    );
    FETCH csr_applicant_userid INTO l_user_id;
    IF csr_applicant_userid%NOTFOUND
    THEN
     l_manager_terminates:='Y';
    END IF;
    CLOSE csr_applicant_userid;
    hr_utility.set_location('l_user_id: '||l_user_id,71);
    hr_utility.set_location('g_user_id: '||fnd_global.user_id,72);
    if l_user_id=fnd_global.user_id then
      l_manager_terminates:='N';
    else
      l_manager_terminates:='Y';
    end if;
    --fix for bug 7577823 ends

    --
    -- Close the offers (if any) for this applicant
    --
/*   IRC_OFFERS_API.close_offer
       ( p_validate                   => p_validate
        ,p_effective_date             => p_effective_date
        ,p_applicant_assignment_id    => p_assignment_id
        ,p_change_reason              => 'WITHDRAWAL'
       );
*/ -- Commmented for bug 7577823
   --
   -- When an offer gets closed upon termination of application by manager
   -- incorrect offer close reason is displayed as 'Applicant Withdrew
   -- their Application'. It should be 'Manager Terminated Application'.
   -- Bug 7577823 handles this case.
   --
--fix for bug 7577823 starts
     if l_manager_terminates = 'Y' then
       IRC_OFFERS_API.close_offer
       ( p_validate                   => p_validate
        ,p_effective_date             => p_effective_date
        ,p_applicant_assignment_id    => p_assignment_id
        ,p_change_reason              => 'MGR_TERMINATE_APPL'
       );
      else
        IRC_OFFERS_API.close_offer
       ( p_validate                   => p_validate
        ,p_effective_date             => p_effective_date
        ,p_applicant_assignment_id    => p_assignment_id
        ,p_change_reason              => 'WITHDRAWAL'
       );
      end if;
--fix for bug 7577823 ends

  end end_assignment;
  --
BEGIN
  --
 if g_debug then
  hr_utility.set_location('Entering:'||l_proc,10);
 end if;
  --
  -- Ensure mandatory arguments have been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'assignment_id'
    ,p_argument_value               => p_assignment_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  -- Truncate all date parameters passed in
  --
  l_effective_date := TRUNC(p_effective_date);
  l_assignment_status_type_id  := p_assignment_status_type_id;
  lv_object_version_number     := p_object_version_number ;
  --
  -- Issue savepoint
  --
  SAVEPOINT terminate_apl_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc,20);
 end if;
  --
  -- Call Before Process User Hook
  --
  BEGIN
    hr_assignment_bkd.terminate_apl_asg_b
      (p_effective_date               => l_effective_date
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit
    THEN
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'TERMINATE_APL_ASG'
         ,p_hook_type         => 'B'
         );
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc,30);
 end if;
  --
  -- Retrieve derived assignment details
  --
  OPEN csr_assignments
    (p_assignment_id                => p_assignment_id
    ,p_effective_date               => l_effective_date
    );
  FETCH csr_assignments INTO l_assignment;
  IF csr_assignments%NOTFOUND
  THEN
    CLOSE csr_assignments;
    hr_utility.set_message(801,'HR_52360_ASG_DOES_NOT_EXIST');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_assignments;
  --
 if g_debug then
  hr_utility.set_location(l_proc,40);
 end if;
  --
  -- Ensure this is an applicant assignment
  --
  IF l_assignment.assignment_type <> 'A'
  THEN
    hr_utility.set_message(801,'HR_51036_ASG_ASG_NOT_APL');
    hr_utility.raise_error;
  END IF;
  --
 if g_debug then
  hr_utility.set_location(l_proc,50);
 end if;
  --
  -- 3652025 >> Ensure this is not the last applicant assignment
  --
  --IF last_apl_asg
  --  (p_assignment_id                => p_assignment_id
  --  ,p_effective_date               => l_effective_date + 1
  --  )
  --THEN
    --
  --  hr_utility.set_message(800,'HR_7987_PER_INV_TYPE_CHANGE');
  --  hr_utility.raise_error;
  --
  --END IF; <<
  --
  open csr_get_current_apl_asg(p_assignment_id, l_effective_date+1);
  fetch csr_get_current_apl_asg into l_cur_asg;
  if csr_get_current_apl_asg%NOTFOUND then -- no current
    if g_debug then
        hr_utility.set_location(l_proc,60);
    end if;
    --
    close csr_get_current_apl_asg;
    open csr_get_future_apl_asg(p_assignment_id, l_effective_date);
    fetch csr_get_future_apl_asg into l_fut_asg;
    if csr_get_future_apl_asg%NOTFOUND then -- no current, no future
        close csr_get_future_apl_asg;
        hr_utility.set_message(800,'HR_7987_PER_INV_TYPE_CHANGE');
        hr_utility.raise_error;
    else                                    -- no current, yes future
        if g_debug then
            hr_utility.set_location(l_proc,62);
        end if;
        hr_utility.trace('  ex_apl date  = '||to_char(l_effective_date+1));
        hr_utility.trace('  apl date = '||to_char(l_fut_asg.effective_start_date));
        -- End assignment
        end_assignment;
        -- update the person and PTU records
        hr_applicant_internal.upd_person_ex_apl_and_apl(
              p_business_group_id           => l_fut_asg.business_group_id
             ,p_person_id                   => l_fut_asg.person_id
             ,p_ex_apl_effective_date       => l_effective_date+1
             ,p_apl_effective_date          => l_fut_asg.effective_start_date
             ,p_per_effective_start_date    => l_per_effective_start_date
             ,p_per_effective_end_date      => l_per_effective_end_date);
        --
        -- terminate current application
        --
        hr_utility.trace('   terminate current application on '||to_char(l_effective_date));
        --
        UPDATE per_applications
           SET date_end = l_effective_date
          where application_id = l_fut_asg.application_id;
        --
        open csr_appl_details(l_fut_asg.application_id);
        fetch csr_appl_details into l_appl_details;
        close csr_appl_details;
        -- create new application for future assignments
        per_apl_ins.ins
              (p_application_id            => l_new_application_id
              ,p_business_group_id         => l_fut_asg.business_group_id
              ,p_person_id                 => l_fut_asg.person_id
              ,p_date_received             => l_fut_asg.effective_start_date
              ,p_object_version_number     => l_apl_object_version_number
              ,p_effective_date            => l_fut_asg.effective_start_date
              ,p_comments                => l_appl_details.comments
              ,p_current_employer        => l_appl_details.current_employer
              ,p_projected_hire_date     => l_appl_details.projected_hire_date
              ,p_successful_flag         => l_appl_details.successful_flag
              ,p_termination_reason      => l_appl_details.termination_reason
              ,p_request_id              => l_appl_details.request_id
              ,p_program_application_id  => l_appl_details.program_application_id
              ,p_program_id              => l_appl_details.program_id
              ,p_program_update_date     => l_appl_details.program_update_date
              ,p_appl_attribute_category => l_appl_details.appl_attribute_category
              ,p_appl_attribute1         => l_appl_details.appl_attribute1
              ,p_appl_attribute2         => l_appl_details.appl_attribute2
              ,p_appl_attribute3         => l_appl_details.appl_attribute3
              ,p_appl_attribute4         => l_appl_details.appl_attribute4
              ,p_appl_attribute5         => l_appl_details.appl_attribute5
              ,p_appl_attribute6         => l_appl_details.appl_attribute6
              ,p_appl_attribute7         => l_appl_details.appl_attribute7
              ,p_appl_attribute8         => l_appl_details.appl_attribute8
              ,p_appl_attribute9         => l_appl_details.appl_attribute9
              ,p_appl_attribute10        => l_appl_details.appl_attribute10
              ,p_appl_attribute11        => l_appl_details.appl_attribute11
              ,p_appl_attribute12        => l_appl_details.appl_attribute12
              ,p_appl_attribute13        => l_appl_details.appl_attribute13
              ,p_appl_attribute14        => l_appl_details.appl_attribute14
              ,p_appl_attribute15        => l_appl_details.appl_attribute15
              ,p_appl_attribute16        => l_appl_details.appl_attribute16
              ,p_appl_attribute17        => l_appl_details.appl_attribute17
              ,p_appl_attribute18        => l_appl_details.appl_attribute18
              ,p_appl_attribute19        => l_appl_details.appl_attribute19
              ,p_appl_attribute20        => l_appl_details.appl_attribute20
              );
        hr_utility.trace('   new application ID = '||to_char(l_new_application_id));

        -- update future assignments with new application ID
        hr_utility.trace('   update all future assignments');
        -- update first assignment found
        l_asg_ovn := l_fut_asg.object_version_number;
        l_asg_eff_date := trunc(l_fut_asg.effective_start_date);
        --
        hr_utility.trace('    => asg id = '||l_fut_asg.assignment_id);
        hr_utility.trace('    =>     SD = '||to_char(l_fut_asg.effective_start_date));
        hr_utility.trace('    =>     ED = '||to_char(l_fut_asg.effective_end_date));
        per_asg_upd.upd
            (p_assignment_id                => l_fut_asg.assignment_id
            ,p_effective_start_date         => l_fut_asg.effective_start_date
            ,p_effective_end_date           => l_fut_asg.effective_end_date
            ,p_business_group_id            => l_fut_asg.business_group_id
            ,p_comment_id                   => l_comment_id
            ,p_application_id               => l_new_application_id  -- override exsiting appl id
            ,p_payroll_id_updated           => l_payroll_id_updated
            ,p_other_manager_warning        => l_other_manager_warning
            ,p_no_managers_warning          => l_no_managers_warning
            ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
            ,p_validation_start_date        => l_validation_start_date
            ,p_validation_end_date          => l_validation_end_date
            ,p_object_version_number        => l_asg_ovn
            ,p_effective_date               => l_asg_eff_date
            ,p_datetrack_mode               => hr_api.g_correction
            ,p_validate                     => FALSE
            ,p_hourly_salaried_warning      => l_hourly_salaried_warning);
        -- update all other future assignments
        hr_utility.trace('  update all other assignments');
        LOOP
          fetch csr_get_future_apl_asg into l_fut_asg;
          exit when csr_get_future_apl_asg%NOTFOUND;
             l_asg_ovn := l_fut_asg.object_version_number;
             l_asg_eff_date := trunc(l_fut_asg.effective_start_date);
             per_asg_upd.upd
                (p_assignment_id                => l_fut_asg.assignment_id
                ,p_effective_start_date         => l_fut_asg.effective_start_date
                ,p_effective_end_date           => l_fut_asg.effective_end_date
                ,p_business_group_id            => l_fut_asg.business_group_id
                ,p_comment_id                   => l_comment_id
                ,p_application_id               => l_new_application_id
                ,p_payroll_id_updated           => l_payroll_id_updated
                ,p_other_manager_warning        => l_other_manager_warning
                ,p_no_managers_warning          => l_no_managers_warning
                ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
                ,p_validation_start_date        => l_validation_start_date
                ,p_validation_end_date          => l_validation_end_date
                ,p_object_version_number        => l_asg_ovn
                ,p_effective_date               => l_asg_eff_date
                ,p_datetrack_mode               => hr_api.g_correction
                ,p_validate                     => FALSE
                ,p_hourly_salaried_warning      => l_hourly_salaried_warning);
        END LOOP;
        --
        close csr_get_future_apl_asg;
        if g_debug then
            hr_utility.set_location(l_proc,68);
        end if;


    end if;
  else -- yes current
    close csr_get_current_apl_asg;
    if l_cur_asg.effective_end_date < hr_general.end_of_time then
      --
      -- current assignment is end dated
      --
      if g_debug then
          hr_utility.set_location(l_proc,100);
      end if;
      select max(effective_end_date) into l_mx_end_dated
        from per_assignments_f
       where person_id = l_assignment.person_id
         and assignment_type = 'A'
         and effective_end_date < hr_general.end_of_time
         and assignment_id <> p_assignment_id;
      --
      select min(effective_start_date) into l_min_no_end_dated
        from per_assignments_f
       where person_id = l_assignment.person_id
         and assignment_type = 'A'
         and effective_end_date = hr_general.end_of_time
         and assignment_id <> p_assignment_id;
      --
      if l_mx_end_dated is not null then -- if A
        --
        if l_min_no_end_dated is not null then -- if B
          --
          if l_mx_end_dated + 1 = l_min_no_end_dated then -- if C
            --
            -- end assignment as normal
            if g_debug then
                hr_utility.set_location(l_proc,110);
            end if;
            end_assignment;
            --
          else -- else C
            if l_min_no_end_dated <= l_mx_end_dated then -- if D
              --
              end_assignment; -- terminate assignment as normal.
            else -- else D
              -- this means person becomes ex-apl after "max end date"
              -- 1. End assignment as normal
              -- 2. Transform person onto EX-APL after "max end date" and before "min sd"
              -- 3. Create new application and update all future applicant assignments
              --    on "min sd"
              if g_debug then
                  hr_utility.set_location(l_proc,120);
              end if;
              -- End assignment
              end_assignment;
              -- update the person and PTU records
              hr_applicant_internal.upd_person_ex_apl_and_apl(
                    p_business_group_id           => l_assignment.business_group_id
                   ,p_person_id                   => l_assignment.person_id
                   ,p_ex_apl_effective_date       => l_mx_end_dated+1
                   ,p_apl_effective_date          => l_min_no_end_dated
                   ,p_per_effective_start_date    => l_per_effective_start_date
                   ,p_per_effective_end_date      => l_per_effective_end_date);
              --
              -- terminate current application
              --
              hr_utility.trace('   terminate current application on '||to_char(l_mx_end_dated));
              --
              UPDATE per_applications
                 SET date_end = l_mx_end_dated
                where application_id = l_assignment.application_id;
              --
              open csr_appl_details(l_assignment.application_id);
              fetch csr_appl_details into l_appl_details;
              close csr_appl_details;
              -- create new application for future assignments
              per_apl_ins.ins
                    (p_application_id            => l_new_application_id
                    ,p_business_group_id         => l_assignment.business_group_id
                    ,p_person_id                 => l_assignment.person_id
                    ,p_date_received             => l_min_no_end_dated
                    ,p_object_version_number     => l_apl_object_version_number
                    ,p_effective_date            => l_min_no_end_dated
                    ,p_comments                => l_appl_details.comments
                    ,p_current_employer        => l_appl_details.current_employer
                    ,p_projected_hire_date     => l_appl_details.projected_hire_date
                    ,p_successful_flag         => l_appl_details.successful_flag
                    ,p_termination_reason      => l_appl_details.termination_reason
                    ,p_request_id              => l_appl_details.request_id
                    ,p_program_application_id  => l_appl_details.program_application_id
                    ,p_program_id              => l_appl_details.program_id
                    ,p_program_update_date     => l_appl_details.program_update_date
                    ,p_appl_attribute_category => l_appl_details.appl_attribute_category
                    ,p_appl_attribute1         => l_appl_details.appl_attribute1
                    ,p_appl_attribute2         => l_appl_details.appl_attribute2
                    ,p_appl_attribute3         => l_appl_details.appl_attribute3
                    ,p_appl_attribute4         => l_appl_details.appl_attribute4
                    ,p_appl_attribute5         => l_appl_details.appl_attribute5
                    ,p_appl_attribute6         => l_appl_details.appl_attribute6
                    ,p_appl_attribute7         => l_appl_details.appl_attribute7
                    ,p_appl_attribute8         => l_appl_details.appl_attribute8
                    ,p_appl_attribute9         => l_appl_details.appl_attribute9
                    ,p_appl_attribute10        => l_appl_details.appl_attribute10
                    ,p_appl_attribute11        => l_appl_details.appl_attribute11
                    ,p_appl_attribute12        => l_appl_details.appl_attribute12
                    ,p_appl_attribute13        => l_appl_details.appl_attribute13
                    ,p_appl_attribute14        => l_appl_details.appl_attribute14
                    ,p_appl_attribute15        => l_appl_details.appl_attribute15
                    ,p_appl_attribute16        => l_appl_details.appl_attribute16
                    ,p_appl_attribute17        => l_appl_details.appl_attribute17
                    ,p_appl_attribute18        => l_appl_details.appl_attribute18
                    ,p_appl_attribute19        => l_appl_details.appl_attribute19
                    ,p_appl_attribute20        => l_appl_details.appl_attribute20
                    );
              hr_utility.trace('   new application ID = '||to_char(l_new_application_id));

              -- update future assignments with new application ID
              hr_utility.trace('   update all future assignments');
              -- update first assignment found
              open csr_get_future_apl_asg(p_assignment_id, l_mx_end_dated+1);
              fetch csr_get_future_apl_asg into l_fut_asg;
              l_asg_ovn := l_fut_asg.object_version_number;
              l_asg_eff_date := trunc(l_fut_asg.effective_start_date);
              --
              hr_utility.trace('    => asg id = '||l_fut_asg.assignment_id);
              hr_utility.trace('    =>     SD = '||to_char(l_fut_asg.effective_start_date));
              hr_utility.trace('    =>     ED = '||to_char(l_fut_asg.effective_end_date));
              per_asg_upd.upd
                  (p_assignment_id                => l_fut_asg.assignment_id
                  ,p_effective_start_date         => l_fut_asg.effective_start_date
                  ,p_effective_end_date           => l_fut_asg.effective_end_date
                  ,p_business_group_id            => l_fut_asg.business_group_id
                  ,p_comment_id                   => l_comment_id
                  ,p_application_id               => l_new_application_id  -- override exsiting appl id
                  ,p_payroll_id_updated           => l_payroll_id_updated
                  ,p_other_manager_warning        => l_other_manager_warning
                  ,p_no_managers_warning          => l_no_managers_warning
                  ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
                  ,p_validation_start_date        => l_validation_start_date
                  ,p_validation_end_date          => l_validation_end_date
                  ,p_object_version_number        => l_asg_ovn
                  ,p_effective_date               => l_asg_eff_date
                  ,p_datetrack_mode               => hr_api.g_correction
                  ,p_validate                     => FALSE
                  ,p_hourly_salaried_warning      => l_hourly_salaried_warning);
              -- update all other future assignments
              hr_utility.trace('  update all other assignments');
              LOOP
                fetch csr_get_future_apl_asg into l_fut_asg;
                exit when csr_get_future_apl_asg%NOTFOUND;
                   l_asg_ovn := l_fut_asg.object_version_number;
                   l_asg_eff_date := trunc(l_fut_asg.effective_start_date);
                   per_asg_upd.upd
                      (p_assignment_id                => l_fut_asg.assignment_id
                      ,p_effective_start_date         => l_fut_asg.effective_start_date
                      ,p_effective_end_date           => l_fut_asg.effective_end_date
                      ,p_business_group_id            => l_fut_asg.business_group_id
                      ,p_comment_id                   => l_comment_id
                      ,p_application_id               => l_new_application_id
                      ,p_payroll_id_updated           => l_payroll_id_updated
                      ,p_other_manager_warning        => l_other_manager_warning
                      ,p_no_managers_warning          => l_no_managers_warning
                      ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
                      ,p_validation_start_date        => l_validation_start_date
                      ,p_validation_end_date          => l_validation_end_date
                      ,p_object_version_number        => l_asg_ovn
                      ,p_effective_date               => l_asg_eff_date
                      ,p_datetrack_mode               => hr_api.g_correction
                      ,p_validate                     => FALSE
                      ,p_hourly_salaried_warning      => l_hourly_salaried_warning);
              END LOOP;
              --
              close csr_get_future_apl_asg;
              if g_debug then
                  hr_utility.set_location(l_proc,150);
              end if;
              --
            end if; -- end if D
          end if; -- end if C
          --
        else-- else B
          -- assignment being terminated is the only one available
          -- 1. End assignment as normal
          -- 2. Transform person onto EX-APL on "max end date" + 1
          if g_debug then
              hr_utility.set_location(l_proc,160);
          end if;
          null; -- not implemented.
        end if; -- end if B
        --
      else -- else A
        --
        if g_debug then
            hr_utility.set_location(l_proc,170);
        end if;

      end if; -- end if A
    else
       if g_debug then
           hr_utility.set_location(l_proc,180);
       end if;
       -- terminate assignment as normal
       end_assignment;
    end if;

  end if; -- end "yes current"
  --
  if g_debug then
    hr_utility.set_location(l_proc,200);
  end if;
  --
  -- Call After Process User Hook
  --
  BEGIN
    hr_assignment_bkd.terminate_apl_asg_a
      (p_effective_date               => l_effective_date
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit
    THEN
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'TERMINATE_APL_ASG'
         ,p_hook_type         => 'A'
         );
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc,300);
 end if;
  --
  -- When in validation only mode raise validate enabled exception
  --
  IF p_validate
  THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set OUT parameters
  --
  p_effective_start_date         := l_effective_start_date;
  p_effective_end_date           := l_effective_end_date;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,1000);
 end if;
--
EXCEPTION
  WHEN hr_api.validate_enabled
  THEN
    --
    -- In validation only mode
    -- Rollback to savepoint
    -- Set relevant output warning arguments
    -- Reset any key or derived arguments
    --
    ROLLBACK TO terminate_apl_asg;
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := NULL;
    p_effective_end_date           := NULL;
  --
  WHEN OTHERS
  THEN
    --
    -- Validation or unexpected error occured
    -- Rollback to savepoint
    -- Re-raise exception
    p_object_version_number := lv_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    ROLLBACK TO terminate_apl_asg;
    RAISE;
--
END terminate_apl_asg;
--
--
PROCEDURE set_new_primary_asg
  (p_validate                    IN     BOOLEAN
  ,p_effective_date              IN     DATE
  ,p_person_id                   IN     per_all_people_f.person_id%TYPE
  ,p_assignment_id               IN     per_all_assignments_f.assignment_id%TYPE
  ,p_object_version_number       IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_effective_start_date           OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date             OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  )
IS
  --
  -- Local Variables
  --
  l_proc                        VARCHAR2(72) := g_package||'set_new_primary_asg';
  --
  l_effective_date              DATE;
  l_object_version_number       CONSTANT per_all_assignments_f.object_version_number%TYPE := p_object_version_number;
  l_effective_start_date        per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date          per_all_assignments_f.effective_end_date%TYPE;
  --
  lv_object_version_number     number := p_object_version_number ;
  --
  -- Local cursors
  --
  CURSOR csr_new_assignment
    (p_assignment_id               IN     per_all_assignments_f.assignment_id%TYPE
    ,p_effective_date              IN     DATE
    )
  IS
    SELECT asg.object_version_number
          ,asg.assignment_type
          ,asg.period_of_service_id
          ,asg.person_id
          ,asg.primary_flag
          ,asg.effective_start_date
          ,asg.effective_end_date
          ,MAX(mxa.effective_end_date) AS max_effective_end_date
          ,pds.actual_termination_date
      FROM per_all_assignments_f asg
          ,per_all_assignments_f mxa
          ,per_periods_of_service pds
     WHERE pds.period_of_service_id(+) = asg.period_of_service_id
       AND mxa.assignment_id = asg.assignment_id
       AND asg.assignment_id = csr_new_assignment.p_assignment_id
       AND csr_new_assignment.p_effective_date BETWEEN asg.effective_start_date
                                                   AND asg.effective_end_date
  GROUP BY asg.object_version_number
          ,asg.assignment_type
          ,asg.period_of_service_id
          ,asg.person_id
          ,asg.primary_flag
          ,asg.effective_start_date
          ,asg.effective_end_date
          ,pds.actual_termination_date;
  l_new_assignment               csr_new_assignment%ROWTYPE;
  --
  CURSOR csr_old_assignment
    (p_person_id                  IN     per_all_people_f.person_id%TYPE
    ,p_effective_date             IN     DATE
    )
  IS
    SELECT asg.assignment_id
          ,asg.period_of_service_id
          ,asg.assignment_type
          ,asg.primary_flag
          ,asg.person_id
          ,asg.effective_start_date
          ,asg.effective_end_date
      FROM per_all_assignments_f asg
     WHERE asg.person_id = csr_old_assignment.p_person_id
       AND csr_old_assignment.p_effective_date BETWEEN asg.effective_start_date
                                                   AND asg.effective_end_date
       AND asg.primary_flag = 'Y'
       AND asg.assignment_type = 'E';
 l_old_assignment               csr_old_assignment%ROWTYPE;
--
BEGIN
  --
 if g_debug then
  hr_utility.set_location('Entering:'||l_proc,10);
 end if;
  --
  -- Ensure mandatory parameters have been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'person_id'
    ,p_argument_value               => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'assignment_id'
    ,p_argument_value               => p_assignment_id
    );
  --
  -- Truncate all date parameters
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Issue Savepoint
  --
  SAVEPOINT set_new_primary_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc,20);
 end if;
  --
  -- Call Before Process User Hook
  --
  BEGIN
    hr_assignment_bke.set_new_primary_asg_b
      (p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit
    THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'SET_NEW_PRIMARY_ASG'
        ,p_hook_type   => 'BP'
        );
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc,30);
 end if;
  --
  -- Retrieve old primary assignment details
  --
  OPEN csr_old_assignment
    (p_person_id      => p_person_id
    ,p_effective_date => l_effective_date
    );
  FETCH csr_old_assignment INTO l_old_assignment;
  IF csr_old_assignment%NOTFOUND
  THEN
    CLOSE csr_old_assignment;
    hr_utility.set_message(800,'HR_51253_PYP_ASS__NOT_VALID');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_old_assignment;
  --
 if g_debug then
  hr_utility.set_location(l_proc,40);
 end if;
  --
  -- Retrieve new primary assignment details
  --
  OPEN csr_new_assignment
    (p_assignment_id  => p_assignment_id
    ,p_effective_date => l_effective_date
    );
  FETCH csr_new_assignment INTO l_new_assignment;
  IF csr_new_assignment%NOTFOUND
  THEN
    CLOSE csr_new_assignment;
    hr_utility.set_message(800,'HR_51253_PYP_ASS__NOT_VALID');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_new_assignment;
  --
 if g_debug then
  hr_utility.set_location(l_proc,50);
 end if;
  --
  -- Validate assignment selected to be new primary
  --
  IF l_new_assignment.person_id <> p_person_id
  THEN
    hr_utility.set_message(801,'HR_51253_PYP_ASS__NOT_VALID');
    hr_utility.raise_error;
  END IF;
  IF l_new_assignment.assignment_type <> 'E'
  THEN
    hr_utility.set_message(801,'HR_7948_ASG_ASG_NOT_EMP');
    hr_utility.raise_error;
  END IF;
  IF l_new_assignment.primary_flag = 'Y'
  THEN
    hr_utility.set_message(801,'HR_7999_ASG_INV_PRIM_ASG');
    hr_utility.raise_error;
  END IF;
  IF l_new_assignment.max_effective_end_date <> NVL(l_new_assignment.actual_termination_date,hr_api.g_eot)
  THEN
    hr_utility.set_message(800,'HR_6438_EMP_ASS_NOT_CONTIN');
    hr_utility.raise_error;
  END IF;
  --
 if g_debug then
  hr_utility.set_location(l_proc,60);
 end if;
  --
  -- End the previous primary assignment
  --
  -- # 2468916: This should be executed after creating NEW primary
  -- assignment. This call is replaced by do_primary_update proc.
  --
  -- hr_assignment.update_primary
  --  (p_assignment_id        => l_old_assignment.assignment_id
  --  ,p_period_of_service_id => l_old_assignment.period_of_service_id
  --  ,p_new_primary_ass_id   => p_assignment_id
  --  ,p_sdate                => l_effective_date
  --  ,p_new_primary_flag     => 'Y'
  --  ,p_mode                 => hr_api.g_update
  --  ,p_last_updated_by      => TO_NUMBER(NULL)
  --  ,p_last_update_login    => TO_NUMBER(NULL)
  --   );
  --
 if g_debug then
  hr_utility.set_location(l_proc,70);
 end if;
  --
  -- Start the new primary assignment
  --
  hr_assignment.update_primary
    (p_assignment_id        => l_old_assignment.assignment_id        -- #2468916:instead of p_assignment_id
    ,p_period_of_service_id => l_old_assignment.period_of_service_id -- #2468916:instead of new.
    ,p_new_primary_ass_id   => p_assignment_id
    ,p_sdate                => l_effective_date
    ,p_new_primary_flag     => 'Y'
    ,p_mode                 => hr_api.g_update
    ,p_last_updated_by      => TO_NUMBER(NULL)
    ,p_last_update_login    => TO_NUMBER(NULL)
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc,75);
 end if;
  --
  -- #2468916: End previous assignment
  --
     hr_assignment.do_primary_update(l_old_assignment.assignment_id   --p_assignment_id
                       ,l_effective_date -- p_sdate
                       ,'N'              -- primary flag
                       ,'N'              -- current asg
                       ,TO_NUMBER(NULL)  --p_last_updated_by
                       ,TO_NUMBER(NULL)  --p_last_update_login
                       );
  -- end #2468916
  --
 if g_debug then
  hr_utility.set_location(l_proc,80);
 end if;
  --
  -- Retrieve new primary assignment details
  --
  OPEN csr_new_assignment
    (p_assignment_id  => p_assignment_id
    ,p_effective_date => l_effective_date
    );
  FETCH csr_new_assignment INTO l_new_assignment;
  IF csr_new_assignment%NOTFOUND
  THEN
    CLOSE csr_new_assignment;
    hr_utility.set_message(800,'HR_51253_PYP_ASS__NOT_VALID');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_new_assignment;
  --
 if g_debug then
  hr_utility.set_location(l_proc,90);
 end if;
  --
  -- Call After Process User Hook
  --
  BEGIN
    hr_assignment_bke.set_new_primary_asg_a
      (p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => l_new_assignment.object_version_number
      ,p_effective_start_date         => l_new_assignment.effective_start_date
      ,p_effective_end_date           => l_new_assignment.effective_end_date
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit
    THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'SET_NEW_PRIMARY_ASG'
        ,p_hook_type   => 'AP'
        );
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc,100);
 end if;
  --
  -- When in validation only mode raise validate enabled exception
  --
  IF p_validate
  THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set OUT parameters
  --
  p_object_version_number := l_new_assignment.object_version_number;
  p_effective_start_date  := l_new_assignment.effective_start_date;
  p_effective_end_date    := l_new_assignment.effective_end_date;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,1000);
 end if;
--
EXCEPTION
  WHEN hr_api.validate_enabled
  THEN
    --
    -- In validation only mode
    -- Rollback to savepoint
    -- Set relevant output warning parmeters
    -- Reset any key or derived values
    --
    ROLLBACK TO set_new_primary_asg;
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := NULL;
    p_effective_end_date    := NULL;
  --
  WHEN OTHERS
  THEN
    --
    -- Validation or unexpected error
    -- Rollback to savepoint
    -- Re-raise exception
    --
    p_object_version_number := lv_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    ROLLBACK TO set_new_primary_asg;
    RAISE;
--
END set_new_primary_asg;
--
PROCEDURE set_new_primary_cwk_asg
  (p_validate                    IN     BOOLEAN
  ,p_effective_date              IN     DATE
  ,p_person_id                   IN     per_all_people_f.person_id%TYPE
  ,p_assignment_id               IN     per_all_assignments_f.assignment_id%TYPE
  ,p_object_version_number       IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_effective_start_date           OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date             OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  )
IS
  --
  -- Local Variables
  --
  l_proc                        VARCHAR2(72) := g_package||'set_new_primary_cwk_asg';
  --
  l_effective_date              DATE;
  l_object_version_number       CONSTANT per_all_assignments_f.object_version_number%TYPE := p_object_version_number;
  l_effective_start_date        per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date          per_all_assignments_f.effective_end_date%TYPE;
  --
  lv_object_version_number     number := p_object_version_number ;
  --
  -- Local cursors
  --
  CURSOR csr_new_assignment
    (p_assignment_id               IN     per_all_assignments_f.assignment_id%TYPE
    ,p_effective_date              IN     DATE) IS
    SELECT asg.object_version_number
          ,asg.assignment_type
          ,asg.period_of_placement_date_start
          ,asg.person_id
          ,asg.primary_flag
          ,asg.effective_start_date
          ,asg.effective_end_date
          ,MAX(mxa.effective_end_date) AS max_effective_end_date
          ,pop.actual_termination_date
      FROM per_all_assignments_f asg
          ,per_all_assignments_f mxa
          ,per_periods_of_placement pop
     WHERE pop.person_id  (+) = asg.person_id
	   AND pop.date_start (+) = asg.period_of_placement_date_start
       AND mxa.assignment_id = asg.assignment_id
       AND asg.assignment_id = csr_new_assignment.p_assignment_id
       AND csr_new_assignment.p_effective_date BETWEEN asg.effective_start_date
                                                   AND asg.effective_end_date
  GROUP BY asg.object_version_number
          ,asg.assignment_type
          ,asg.period_of_placement_date_start
          ,asg.person_id
          ,asg.primary_flag
          ,asg.effective_start_date
          ,asg.effective_end_date
          ,pop.actual_termination_date;
  --
  CURSOR csr_old_assignment
    (p_person_id       IN     per_all_people_f.person_id%TYPE
    ,p_effective_date  IN     DATE) IS
    SELECT asg.assignment_id
          ,asg.assignment_type
          ,asg.period_of_placement_date_start
          ,asg.primary_flag
          ,asg.person_id
          ,asg.effective_start_date
          ,asg.effective_end_date
      FROM per_all_assignments_f asg
     WHERE asg.person_id = csr_old_assignment.p_person_id
       AND csr_old_assignment.p_effective_date BETWEEN asg.effective_start_date
                                                   AND asg.effective_end_date
       AND asg.primary_flag = 'Y'
       AND asg.assignment_type = 'C';
 --
 l_old_assignment csr_old_assignment%ROWTYPE;
 l_new_assignment csr_new_assignment%ROWTYPE;
  --
BEGIN
  --
 if g_debug then
  hr_utility.set_location('Entering:'||l_proc,10);
 end if;
  --
  -- Ensure mandatory parameters have been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'person_id'
    ,p_argument_value               => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'assignment_id'
    ,p_argument_value               => p_assignment_id
    );
  --
  -- Truncate all date parameters
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Issue Savepoint
  --
  SAVEPOINT set_new_primary_cwk_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc,20);
 end if;
  --
  -- Call Before Process User Hook
  --
  BEGIN
    --
    hr_assignment_bki.set_new_primary_cwk_asg_b
      (p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number);
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'set_new_primary_cwk_asg'
        ,p_hook_type   => 'BP');
      --
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc,30);
 end if;
  --
  -- Retrieve old primary assignment details
  --
  OPEN csr_old_assignment
    (p_person_id      => p_person_id
    ,p_effective_date => l_effective_date);
  --
  FETCH csr_old_assignment INTO l_old_assignment;
  --
  IF csr_old_assignment%NOTFOUND THEN
    --
    CLOSE csr_old_assignment;
    --
    hr_utility.set_message(800,'HR_51253_PYP_ASS__NOT_VALID');
    hr_utility.raise_error;
	--
  END IF;
  --
  CLOSE csr_old_assignment;
  --
 if g_debug then
  hr_utility.set_location(l_proc,40);
 end if;
  --
  -- Retrieve new primary assignment details
  --
  OPEN csr_new_assignment
    (p_assignment_id  => p_assignment_id
    ,p_effective_date => l_effective_date);
  --
  FETCH csr_new_assignment INTO l_new_assignment;
  --
  IF csr_new_assignment%NOTFOUND THEN
    --
    CLOSE csr_new_assignment;
	--
    hr_utility.set_message(800,'HR_51253_PYP_ASS__NOT_VALID');
    hr_utility.raise_error;
	--
  END IF;
  --
  CLOSE csr_new_assignment;
  --
 if g_debug then
  hr_utility.set_location(l_proc,50);
 end if;
  --
  -- Validate assignment selected to be new primary
  --
  IF l_new_assignment.person_id <> p_person_id THEN
    --
    hr_utility.set_message(801,'HR_51253_PYP_ASS__NOT_VALID');
    hr_utility.raise_error;
	--
  END IF;
  --
  IF l_new_assignment.assignment_type <> 'C' THEN
    --
	--hr_utility.set_message(801,'HR_7948_ASG_ASG_NOT_EMP');
    hr_utility.set_message(801,'XXX');
    hr_utility.raise_error;
	--
  END IF;
  --
  IF l_new_assignment.primary_flag = 'Y' THEN
    --
    hr_utility.set_message(801,'HR_7999_ASG_INV_PRIM_ASG');
    hr_utility.raise_error;
	--
  END IF;
  --
  IF l_new_assignment.max_effective_end_date <>
     NVL(l_new_assignment.actual_termination_date,hr_api.g_eot) THEN
    --
    hr_utility.set_message(800,'HR_6438_EMP_ASS_NOT_CONTIN');
    hr_utility.raise_error;
	--
  END IF;
  --
 if g_debug then
  hr_utility.set_location(l_proc,60);
 end if;
  --
  -- End the previous primary assignment
  --
  hr_assignment.update_primary_cwk
    (p_assignment_id        => l_old_assignment.assignment_id
    ,p_person_id            => p_person_id
    ,p_pop_date_start       => l_old_assignment.period_of_placement_date_start
    ,p_new_primary_ass_id   => p_assignment_id
    ,p_sdate                => l_effective_date
    ,p_new_primary_flag     => 'Y'
    ,p_mode                 => hr_api.g_update
    ,p_last_updated_by      => TO_NUMBER(NULL)
    ,p_last_update_login    => TO_NUMBER(NULL)
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc,70);
 end if;
  --
  -- Start the new primary assignment
  --
  hr_assignment.update_primary_cwk
    (p_assignment_id        => p_assignment_id
    ,p_person_id            => p_person_id
    ,p_pop_date_start       => l_new_assignment.period_of_placement_date_start
    ,p_new_primary_ass_id   => p_assignment_id
    ,p_sdate                => l_effective_date
    ,p_new_primary_flag     => 'Y'
    ,p_mode                 => hr_api.g_update
    ,p_last_updated_by      => TO_NUMBER(NULL)
    ,p_last_update_login    => TO_NUMBER(NULL)
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc,80);
 end if;
  --
  -- Retrieve new primary assignment details
  --
  OPEN csr_new_assignment
    (p_assignment_id  => p_assignment_id
    ,p_effective_date => l_effective_date);
  --
  FETCH csr_new_assignment INTO l_new_assignment;
  --
  IF csr_new_assignment%NOTFOUND THEN
    --
    CLOSE csr_new_assignment;
    --
    hr_utility.set_message(800,'HR_51253_PYP_ASS__NOT_VALID');
    hr_utility.raise_error;
	--
  END IF;
  --
  CLOSE csr_new_assignment;
  --
 if g_debug then
  hr_utility.set_location(l_proc,90);
 end if;
  --
  -- Call After Process User Hook
  --
  BEGIN
    --
    hr_assignment_bki.set_new_primary_cwk_asg_a
      (p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => l_new_assignment.object_version_number
      ,p_effective_start_date         => l_new_assignment.effective_start_date
      ,p_effective_end_date           => l_new_assignment.effective_end_date);
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'set_new_primary_cwk_asg'
        ,p_hook_type   => 'AP');
      --
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc,100);
 end if;
  --
  -- When in validation only mode raise validate enabled exception
  --
  IF p_validate THEN
    --
    RAISE hr_api.validate_enabled;
	--
  END IF;
  --
  -- Set OUT parameters
  --
  p_object_version_number := l_new_assignment.object_version_number;
  p_effective_start_date  := l_new_assignment.effective_start_date;
  p_effective_end_date    := l_new_assignment.effective_end_date;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,999);
 end if;
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- In validation only mode
    -- Rollback to savepoint
    -- Set relevant output warning parmeters
    -- Reset any key or derived values
    --
    ROLLBACK TO set_new_primary_cwk_asg;
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := NULL;
    p_effective_end_date    := NULL;
    --
  WHEN OTHERS THEN
    --
    -- Validation or unexpected error
    -- Rollback to savepoint
    -- Re-raise exception
    --
    p_object_version_number := lv_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    ROLLBACK TO set_new_primary_cwk_asg;
    RAISE;
    --
END set_new_primary_cwk_asg;
--
--
-- -----------------------------------------------------------------------------
-- |--------------------------< interview1_apl_asg >---------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE interview1_apl_asg
  (p_validate                     IN     BOOLEAN
  ,p_effective_date               IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_assignment_status_type_id    IN     per_assignment_status_types.assignment_status_type_id%TYPE
  ,p_change_reason                IN     per_all_assignments_f.change_reason%TYPE
  ,p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  )
IS
  --
  -- Local variables
  --
  l_proc                       VARCHAR2(72);
  --
  l_effective_date             DATE;
  --
  l_object_version_number      CONSTANT per_all_assignments_f.object_version_number%TYPE := p_object_version_number;
  --
  l_expected_system_status     per_assignment_status_types.per_system_status%TYPE := 'INTERVIEW1';
  l_effective_start_date       per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date         per_all_assignments_f.effective_end_date%TYPE;
--
  lv_object_version_number     number := p_object_version_number ;
--
BEGIN
  --
 if g_debug then
  l_proc := g_package||'interview1_apl_asg';
  hr_utility.set_location('Entering:'||l_proc,10);
 end if;
  --
  -- Truncate all date parameters passed in
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Issue savepoint
  --
  SAVEPOINT interview1_apl_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc,20);
 end if;
  --
  -- Call Before Process User Hook
  --
  BEGIN
     hr_assignment_bkf.interview1_apl_asg_b
       (p_effective_date               => l_effective_date
       ,p_datetrack_update_mode        => p_datetrack_update_mode
       ,p_assignment_id                => p_assignment_id
       ,p_object_version_number        => p_object_version_number
       ,p_assignment_status_type_id    => p_assignment_status_type_id
       ,p_change_reason                => p_change_reason
       );
  EXCEPTION
     WHEN hr_api.cannot_find_prog_unit
     THEN
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'INTERVIEW1_APL_ASG',
          p_hook_type         => 'BP'
         );
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc,30);
 end if;
  --
  -- Call business support process to update status type
  --
  hr_assignment_internal.update_status_type_apl_asg
    (p_effective_date               => l_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_expected_system_status       => l_expected_system_status
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_change_reason                => p_change_reason
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc,40);
 end if;
  --
  -- Call After Process User Hook
  --
  BEGIN
     hr_assignment_bkf.interview1_apl_asg_a
       (p_effective_date               => l_effective_date
       ,p_datetrack_update_mode        => p_datetrack_update_mode
       ,p_assignment_id                => p_assignment_id
       ,p_object_version_number        => p_object_version_number
       ,p_assignment_status_type_id    => p_assignment_status_type_id
       ,p_change_reason                => p_change_reason
       ,p_effective_start_date         => l_effective_start_date
       ,p_effective_end_date           => l_effective_end_date
       );
  EXCEPTION
     WHEN hr_api.cannot_find_prog_unit
     THEN
       hr_api.cannot_find_prog_unit_error
         (p_module_name => 'INTERVIEW1_APL_ASG',
          p_hook_type   => 'AP'
         );
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc,50);
 end if;
  --
  -- When in validation only mode raise validate_enabled exception
  --
  IF p_validate
  THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set OUT parameters
  --
  p_effective_start_date         := l_effective_start_date;
  p_effective_end_date           := l_effective_end_date;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,100);
 end if;
--
EXCEPTION
  WHEN hr_api.validate_enabled
  THEN
    --
    -- In validation only mode
    -- Rollback to savepoint
    -- Set relevant output warning arguments
    -- Reset any key or derived arguments
    --
    ROLLBACK TO interview1_apl_asg;
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := NULL;
    p_effective_end_date           := NULL;
  --
  WHEN OTHERS
  THEN
    --
    -- Validation or unexpected error occured
    -- Rollback to savepoint
    -- Re-raise exception
    --
    p_object_version_number := lv_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    ROLLBACK TO interview1_apl_asg;
    RAISE;
--
END interview1_apl_asg;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< interview2_apl_asg >---------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE interview2_apl_asg
  (p_validate                     IN     BOOLEAN
  ,p_effective_date               IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_assignment_status_type_id    IN     per_assignment_status_types.assignment_status_type_id%TYPE
  ,p_change_reason                IN     per_all_assignments_f.change_reason%TYPE
  ,p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  )
IS
  --
  -- Local variables
  --
  l_proc                       VARCHAR2(72);
  --
  l_effective_date             DATE;
  --
  l_object_version_number      CONSTANT per_all_assignments_f.object_version_number%TYPE := p_object_version_number;
  --
  l_expected_system_status     per_assignment_status_types.per_system_status%TYPE := 'INTERVIEW2';
  l_effective_start_date       per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date         per_all_assignments_f.effective_end_date%TYPE;
--
  lv_object_version_number     number := p_object_version_number ;
--
BEGIN
  --
 if g_debug then
  l_proc := g_package||'interview2_apl_asg';
  hr_utility.set_location('Entering:'||l_proc,10);
 end if;
  --
  -- Truncate all date parameters passed in
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Issue savepoint
  --
  SAVEPOINT interview2_apl_asg;
  --
 if g_debug then
  hr_utility.set_location(l_proc,20);
 end if;
  --
  -- Call Before Process User Hook
  --
  BEGIN
     hr_assignment_bkg.interview2_apl_asg_b
       (p_effective_date               => l_effective_date
       ,p_datetrack_update_mode        => p_datetrack_update_mode
       ,p_assignment_id                => p_assignment_id
       ,p_object_version_number        => p_object_version_number
       ,p_assignment_status_type_id    => p_assignment_status_type_id
       ,p_change_reason                => p_change_reason
       );
  EXCEPTION
     WHEN hr_api.cannot_find_prog_unit
     THEN
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'INTERVIEW2_APL_ASG',
          p_hook_type         => 'BP'
         );
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc,30);
 end if;
  --
  -- Call business support process to update status type
  --
  hr_assignment_internal.update_status_type_apl_asg
    (p_effective_date               => l_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_expected_system_status       => l_expected_system_status
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_change_reason                => p_change_reason
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc,40);
 end if;
  --
  -- Call After Process User Hook
  --
  BEGIN
     hr_assignment_bkg.interview2_apl_asg_a
       (p_effective_date               => l_effective_date
       ,p_datetrack_update_mode        => p_datetrack_update_mode
       ,p_assignment_id                => p_assignment_id
       ,p_object_version_number        => p_object_version_number
       ,p_assignment_status_type_id    => p_assignment_status_type_id
       ,p_change_reason                => p_change_reason
       ,p_effective_start_date         => l_effective_start_date
       ,p_effective_end_date           => l_effective_end_date
       );
  EXCEPTION
     WHEN hr_api.cannot_find_prog_unit
     THEN
       hr_api.cannot_find_prog_unit_error
         (p_module_name => 'INTERVIEW2_APL_ASG',
          p_hook_type   => 'AP'
         );
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc,50);
 end if;
  --
  -- When in validation only mode raise validate_enabled exception
  --
  IF p_validate
  THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set OUT parameters
  --
  p_effective_start_date         := l_effective_start_date;
  p_effective_end_date           := l_effective_end_date;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,100);
 end if;
--
EXCEPTION
  WHEN hr_api.validate_enabled
  THEN
    --
    -- In validation only mode
    -- Rollback to savepoint
    -- Set relevant output warning arguments
    -- Reset any key or derived arguments
    --
    ROLLBACK TO interview2_apl_asg;
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := NULL;
    p_effective_end_date           := NULL;
  --
  WHEN OTHERS
  THEN
    --
    -- Validation or unexpected error occured
    -- Rollback to savepoint
    -- Re-raise exception
    --
    p_object_version_number := lv_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    ROLLBACK TO interview2_apl_asg;
    RAISE;
--
END interview2_apl_asg;
--
--
-- -----------------------------------------------------------------------------
-- |--------------------------< delete_assignment >-----------------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE delete_assignment
  (p_validate                     IN     boolean default false
  ,p_effective_date               IN     DATE
  ,p_datetrack_mode               IN     VARCHAR2
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  ,p_loc_change_tax_issues           OUT NOCOPY boolean
  ,p_delete_asg_budgets              OUT NOCOPY boolean
  ,p_org_now_no_manager_warning      OUT NOCOPY boolean
  ,p_element_salary_warning          OUT NOCOPY boolean
  ,p_element_entries_warning         OUT NOCOPY boolean
  ,p_spp_warning                     OUT NOCOPY boolean
  ,P_cost_warning                    OUT NOCOPY Boolean
  ,p_life_events_exists   	     OUT NOCOPY Boolean
  ,p_cobra_coverage_elements         OUT NOCOPY Boolean
  ,p_assgt_term_elements             OUT NOCOPY Boolean)
IS
  l_effective_date date;
  l_validate boolean;
  --
  l_proc    varchar2(72) := g_package||'delete_assignment';
  asg_type  varchar2(10);
  --
  cursor get_asgt_type is
     select assignment_type
       from per_all_assignments_f
      where assignment_id = p_assignment_id
        and p_effective_date between effective_start_date and effective_end_date;
  --
BEGIN
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 5);
    hr_utility.set_location('p_effective_date:'|| to_char(p_effective_date,'DD/MM/YYYY'), 5);
    hr_utility.set_location('p_assignment_id :'|| p_assignment_id, 5);
  end if;
  --
  l_effective_date  := trunc(p_effective_date);
  l_validate        := p_validate ;
  --
  -- Issue a savepoint.
  --
  savepoint hr_delete_assignment;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  open get_asgt_type;
  fetch get_asgt_type into asg_type;
  if get_asgt_type%notfound then
     close get_asgt_type;
  else
      --
      close get_asgt_type;
      if asg_type = 'B' then
         if g_debug then
            hr_utility.set_location('Selected assignment is of type Benifit', 10);
         end if;
         --
         fnd_message.set_name('PER', 'HR_449746_DEL_BEN_ASG');
         fnd_message.raise_error;
      end if;
      --
  end if;
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_assignment
    --
    hr_assignment_bkp.delete_assignment_b
      (p_effective_date               => l_effective_date
      ,p_assignment_id                => p_assignment_id
      ,p_datetrack_mode               => p_datetrack_mode
      );
    --
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ASSIGNMENT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_assignment
    --
  end;
  --
  per_asg_del.del(
     p_validate                     =>  p_validate
    ,p_assignment_id                =>  p_assignment_id
    ,p_effective_date               =>  p_effective_date
    ,p_datetrack_mode               =>  p_datetrack_mode
    ,p_object_version_number        =>  p_object_version_number
    ,p_effective_start_date         =>  p_effective_start_date
    ,p_effective_end_date           =>  p_effective_end_date
    ,p_loc_change_tax_issues        =>  p_loc_change_tax_issues
    ,p_delete_asg_budgets           =>  p_delete_asg_budgets
    ,p_org_now_no_manager_warning   =>  p_org_now_no_manager_warning
    ,p_element_salary_warning       =>  p_element_salary_warning
    ,p_element_entries_warning      =>  p_element_entries_warning
    ,p_spp_warning                  =>  p_spp_warning
    ,P_cost_warning                 =>  P_cost_warning
    ,p_life_events_exists           =>  p_life_events_exists
    ,p_cobra_coverage_elements      =>  p_cobra_coverage_elements
    ,p_assgt_term_elements          =>  p_assgt_term_elements );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_assignment
    --
    hr_assignment_bkp.delete_assignment_a
      (p_effective_date               => l_effective_date
      ,p_assignment_id                => p_assignment_id
      ,p_datetrack_mode               => p_datetrack_mode
      ,p_loc_change_tax_issues        => p_loc_change_tax_issues
      ,p_delete_asg_budgets           => p_delete_asg_budgets
      ,p_org_now_no_manager_warning   => p_org_now_no_manager_warning
      ,p_element_salary_warning       => p_element_salary_warning
      ,p_element_entries_warning      => p_element_entries_warning
      ,p_spp_warning                  => p_spp_warning
      ,P_cost_warning                 => P_cost_warning
      ,p_life_events_exists           => p_life_events_exists
      ,p_cobra_coverage_elements      => p_cobra_coverage_elements
      ,p_assgt_term_elements          => p_assgt_term_elements );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ASSIGNMENT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_person
    --
  end;
  --

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 100);
  end if;
  --
  exception
   when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    p_loc_change_tax_issues          := null;
    p_delete_asg_budgets             := null;
    p_org_now_no_manager_warning     := null;
    p_element_salary_warning         := null;
    p_element_entries_warning        := null;
    p_spp_warning                    := null;
    P_cost_warning                   := null;
    p_life_events_exists   	     := null;
    p_cobra_coverage_elements        := null;
    p_assgt_term_elements            := null;
    --
    ROLLBACK TO hr_delete_assignment;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    p_loc_change_tax_issues          := null;
    p_delete_asg_budgets             := null;
    p_org_now_no_manager_warning     := null;
    p_element_salary_warning         := null;
    p_element_entries_warning        := null;
    p_spp_warning                    := null;
    P_cost_warning                   := null;
    p_life_events_exists   	     := null;
    p_cobra_coverage_elements        := null;
    p_assgt_term_elements            := null;
    --
    ROLLBACK TO hr_delete_assignment;
    raise;
  --
END; -- End of delete_assignment Procedure
--
END hr_assignment_api;

/
