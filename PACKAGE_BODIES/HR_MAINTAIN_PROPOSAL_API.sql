--------------------------------------------------------
--  DDL for Package Body HR_MAINTAIN_PROPOSAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MAINTAIN_PROPOSAL_API" as
/* $Header: hrpypapi.pkb 120.30.12010000.13 2009/01/16 09:51:09 schowdhu ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_maintain_proposal_api.';  -- Global package name

function get_dt_mode(p_session_date in date,
                     p_element_entry_id  in number)
RETURN varchar2

IS

l_dtmode varchar2(30);

begin

l_dtmode := PQH_GSP_POST_PROCESS.DT_Mode
            (P_EFFECTIVE_DATE    => p_session_date
            ,P_BASE_TABLE_NAME   => 'PAY_ELEMENT_ENTRIES_F'
            ,P_BASE_KEY_COLUMN   => 'ELEMENT_ENTRY_ID'
            ,P_BASE_KEY_VALUE    => p_element_entry_id);

return l_dtmode;
end get_dt_mode;

--------vkodedal 7-mar-07
-----------------------------------------------------------------------------
-- | ---------------------------< update_last_change_date>-----------------
-----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to correct the last_change_date of the next record with the current change date.
--   This procedure is called when a record is inserted, or deleted so that correct last_change_date is maintained
--   in the immediate next proposal.
--   Assignment Id and Change date of the inserted or change date of the proposal previous to the deleted proposal
--   are passed as in parameters.
--
Procedure update_last_change_date(p_assignment_id  in     number
                                  ,p_change_date   in     date) is

cursor csr_next_proposal is
select pay_proposal_id, rowid
	from per_pay_proposals
	where assignment_id = p_assignment_id
	and change_date=(
    select min(change_date)
      from per_pay_proposals
     where assignment_id = p_assignment_id
       and change_date >  p_change_date);

  l_last_change_date per_pay_proposals.last_change_date%TYPE;
  l_pay_proposal_id per_pay_proposals.pay_proposal_id%TYPE;
  l_row_id rowid;
  l_proc varchar2(30):= 'update_last_change_date';

  begin

    hr_utility.set_location('Entering:'||l_proc,5);
    hr_utility.set_location('p_assignment_id:'||p_assignment_id,15);
    hr_utility.set_location('p_change_date:'||p_change_date,25);

    l_last_change_date:=p_change_date;

  	  OPEN csr_next_proposal;
	  FETCH csr_next_proposal into l_pay_proposal_id,l_row_id;

	 hr_utility.set_location('l_pay_proposal_id:'||l_pay_proposal_id,15);

	  if csr_next_proposal%FOUND then
	    hr_utility.set_location('Cursor found:',25);

--added by schowdhu to fix 7205132

	        update per_pay_proposals
		      set last_change_date = l_last_change_date,
                          last_updated_by = fnd_global.user_id,
                          last_update_login = fnd_global.login_id
		          where rowid=l_row_id;

-- commented out by schowdhu to fix 7205132
/*
	        update per_pay_proposals
		      set last_change_date = l_last_change_date
		      where rowid=l_row_id;
*/
	    hr_utility.set_location('Updated successfuly:',35);
	    end if;

	  CLOSE csr_next_proposal;

    hr_utility.set_location('Leaving:'||l_proc,5);

EXCEPTION
  When others then
  --
  -- An unexpected error has occured
  --
    hr_utility.set_location('When Others:'||l_proc,5);
    raise;
  --
end update_last_change_date;
--
--
/* Procedure added to enddate proposed proposals only. Bug#7386307  by schowdhu  */

Procedure end_date_proposed_proposal(p_assignment_id  in     number
                                  ,p_date_to        in     date) is

 Cursor csr_prev_prop_details
  is
  select pay_proposal_id,date_to
  from per_pay_proposals
  where assignment_id = p_assignment_id
  and change_date =(select max(change_date)
  from per_pay_proposals
  where  assignment_id = p_assignment_id
  and change_date < p_date_to+1 and approved = 'N');

  l_date_to per_pay_proposals.date_to%TYPE;
  l_pay_proposal_id per_pay_proposals.pay_proposal_id%TYPE;
  l_proc varchar2(30):= 'end_date_proposed_proposal';

begin

    hr_utility.set_location('Entering:'||l_proc,5);
    hr_utility.set_location('p_assignment_id:'||p_assignment_id,15);
    hr_utility.set_location('p_date_to:'||p_date_to,25);

	  OPEN csr_prev_prop_details;
	  FETCH csr_prev_prop_details into l_pay_proposal_id,l_date_to;

	 hr_utility.set_location('l_pay_proposal_id:'||l_pay_proposal_id,15);
	 hr_utility.set_location('l_date_to:'||l_date_to,25);

	  if csr_prev_prop_details%FOUND then
	    hr_utility.set_location('Cursor found:',35);
	      if  l_date_to is null OR l_date_to > p_date_to  then
	    hr_utility.set_location('About to update',45);
		      update per_pay_proposals
		      set date_to = p_date_to,
                                                          -- added by vkodedal fix for 6831216
		      last_update_date = sysdate,
		      last_updated_by = fnd_global.user_id,
		      last_update_login = fnd_global.login_id
		      -- end of fix
		      where assignment_id = p_assignment_id
		      and pay_proposal_id = l_pay_proposal_id;
	    hr_utility.set_location('Updated successfuly:',85);
	    end if;
	  end if;
	  CLOSE csr_prev_prop_details;

    hr_utility.set_location('Leaving:'||l_proc,5);

end end_date_proposed_proposal;
--
--

/* Procedure added to enddate approved proposals only. Bug#7386307  by schowdhu  */

-- changed by schowdhu for 7673294 05-jan-08

Procedure end_date_approved_proposal(p_assignment_id  in     number
                                  ,p_date_to        in     date
                                  ,p_proposal_id in number default NULL) is

 Cursor csr_prev_prop_details
  is
  select pay_proposal_id, date_to
  from per_pay_proposals
  where assignment_id = p_assignment_id
  and change_date =(select max(change_date)
  from per_pay_proposals
  where  assignment_id = p_assignment_id
  and change_date < p_date_to+1 and approved = 'Y');

  -- cursor added to find the proposed proposals to be deleted
  -- by schowdhu Bug #7386307

cursor get_all_proposed_proposals
is
select pay_proposal_id,object_version_number, business_group_id
from per_pay_proposals
where assignment_id = p_assignment_id
--added for the bug 7673294 to exclude the calling proposal
and pay_proposal_id <> p_proposal_id
and change_date < p_date_to+1
and approved = 'N';

  l_date_to per_pay_proposals.date_to%TYPE;
  l_pay_proposal_id per_pay_proposals.pay_proposal_id%TYPE;
  l_proc varchar2(30):= 'end_date_approved_proposal';
  l_change_date per_pay_proposals.change_date%TYPE;
  l_del_warn                  boolean;

begin

    hr_utility.set_location('Entering:'||l_proc,5);
    hr_utility.set_location('p_assignment_id:'||p_assignment_id,15);
    hr_utility.set_location('p_date_to:'||p_date_to,25);

	  OPEN csr_prev_prop_details;
	  FETCH csr_prev_prop_details into l_pay_proposal_id,l_date_to;

	  if csr_prev_prop_details%FOUND then
	    hr_utility.set_location('Cursor found:',35);
	      if  l_date_to is null OR l_date_to > p_date_to  then
	    hr_utility.set_location('About to update',45);
		      update per_pay_proposals
		      set date_to = p_date_to,
                                                          -- added by vkodedal fix for 6831216
		      last_update_date = sysdate,
		      last_updated_by = fnd_global.user_id,
		      last_update_login = fnd_global.login_id
		      -- end of fix
		      where assignment_id = p_assignment_id
		      and pay_proposal_id = l_pay_proposal_id;
	    hr_utility.set_location('Updated successfuly:',85);
	   end if;
	  end if;
	  CLOSE csr_prev_prop_details;

-- This condition is added to delete the proposed proposals in case it is not yet done from
-- the OA layer. schowdhu - 01-Dec-2008
if(  HR_MAINTAIN_PROPOSAL_API.g_deleted_from_oa = 'N')
then
 hr_utility.set_location('Within delete from OA',90);
-- now delete all the inactivated proposed proposals. Bug#7386307  by schowdhu
	        for a in get_all_proposed_proposals loop
	         hr_maintain_proposal_api.delete_salary_proposal
	   		 (p_pay_proposal_id              =>   a.pay_proposal_id
	   		 ,p_business_group_id           =>    a.business_group_id
	   		 ,p_object_version_number       =>    a.object_version_number
	   		 ,p_salary_warning              =>    l_del_warn);
    		end loop;
end if;

    hr_utility.set_location('Leaving:'||l_proc,100);

end end_date_approved_proposal;
--
--

--
-----------------------------------------------------------------------------
-- | ---------------------------< end_date_salary_proposal>-----------------
-----------------------------------------------------------------------------
--
/* Procedure modified. Bug#7386307  by schowdhu  */

-- changed by schowdhu for 7673294 05-jan-08
  Procedure end_date_salary_proposal(p_assignment_id  in     number
				    ,p_date_to        in     date
				    ,p_proposal_id in number default NULL) is
/*
   Cursor csr_prev_prop_details
    is
    select pay_proposal_id,date_to
    from per_pay_proposals
    where assignment_id = p_assignment_id
    and change_date =(select max(change_date)
    from per_pay_proposals
    where  assignment_id = p_assignment_id
    and change_date < p_date_to+1);

    l_date_to per_pay_proposals.date_to%TYPE;
    l_pay_proposal_id per_pay_proposals.pay_proposal_id%TYPE;
*/
    l_proc varchar2(30):= 'end_date_salary_proposal';
    l_approved per_pay_proposals.approved%TYPE;
-- changed by schowdhu for 7673294 05-jan-08

    Cursor chk_approved_flg
    is
    select approved
    from per_pay_proposals
    where pay_proposal_id = nvl(p_proposal_id, pay_proposal_id)
    and assignment_id = p_assignment_id
    and change_date = p_date_to +1 ;
  begin

      hr_utility.set_location('Entering:'||l_proc,5);
      hr_utility.set_location('p_assignment_id:'||p_assignment_id,15);
      hr_utility.set_location('p_date_to:'||p_date_to,25);
/*
	    OPEN csr_prev_prop_details;
	    FETCH csr_prev_prop_details into l_pay_proposal_id,l_date_to;

	   hr_utility.set_location('l_pay_proposal_id:'||l_pay_proposal_id,15);
	   hr_utility.set_location('l_date_to:'||l_date_to,25);


          if csr_prev_prop_details%FOUND then
            hr_utility.set_location('Cursor found:',35);
              if  l_date_to is null OR l_date_to > p_date_to  then
            hr_utility.set_location('About to update',45);
                      update per_pay_proposals
                      set date_to = p_date_to,
                                                          -- added by vkodedal fix for 6831216
                      last_update_date = sysdate,
                      last_updated_by = fnd_global.user_id,
                      last_update_login = fnd_global.login_id
                      -- end of fix
                      where assignment_id = p_assignment_id
                      and pay_proposal_id = l_pay_proposal_id;
            hr_utility.set_location('Updated successfuly:',85);
            end if;
          end if;
          CLOSE csr_prev_prop_details;
*/
      OPEN chk_approved_flg;
      FETCH chk_approved_flg into l_approved;
      if l_approved = 'N' then
      	end_date_proposed_proposal (p_assignment_id, p_date_to);
      else
-- changed by schowdhu for 7673294 05-jan-08
        end_date_approved_proposal (p_assignment_id, p_date_to, p_proposal_id);
      end if;
      CLOSE chk_approved_flg;

    hr_utility.set_location('Leaving:'||l_proc,5);

end end_date_salary_proposal;



Procedure extend_salary_proposal_to_date(p_pay_proposal_id  in     number) is
--
cursor c_pay_proposal is
select assignment_id, change_date, date_to,last_change_date, approved
from per_pay_proposals
where pay_proposal_id = p_pay_proposal_id;
--
cursor c_asg_pay_basis_id(p_assignment_id number, p_date date) is
select pay_basis_id
from per_all_assignments_f
where assignment_id = p_assignment_id
and p_date between effective_start_date and effective_end_date;
--
l_proc    varchar2(72) := g_package||'extend_salary_proposal_to_date';
l_assignment_id         number;
l_deleted_proposal_date date;
l_date_to date;
l_last_change_date date;
l_curr_pay_basis_id  number;
l_prev_pay_basis_id  number;
l_approved   per_pay_proposals.approved%TYPE;
--
begin
  --

  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if (p_pay_proposal_id is not null)
  then
    open c_pay_proposal;
    fetch c_pay_proposal into l_assignment_id, l_deleted_proposal_date, l_date_to,l_last_change_date, l_approved;
    close c_pay_proposal;

    open c_asg_pay_basis_id(l_assignment_id , l_deleted_proposal_date);
    fetch c_asg_pay_basis_id into l_curr_pay_basis_id;
    close c_asg_pay_basis_id;
    --
    hr_utility.set_location('Current pay_basis_id:'||l_curr_pay_basis_id,10);
    --
    --
    open c_asg_pay_basis_id(l_assignment_id , l_deleted_proposal_date-1);
    fetch c_asg_pay_basis_id into l_prev_pay_basis_id;
    close c_asg_pay_basis_id;
    --
    hr_utility.set_location('Previous pay_basis_id:'||l_prev_pay_basis_id,20);
    --

    --
    -- if pay_basis_id for the assignment is different don't extend
    --
    if (l_curr_pay_basis_id is null or l_prev_pay_basis_id is null
        or l_curr_pay_basis_id<>l_prev_pay_basis_id) then
      --
      hr_utility.set_location('Exiting1:'||l_proc,50);
      --
      return;
    end if;
/* changed to adjust the date_to after deletion of a proposal. Bug#7386307  by schowdhu  */
if (l_approved = 'N') then

    update per_pay_proposals
    set date_to = l_date_to,
 -- added by vkodedal fix for 6831216
    last_update_date = sysdate,
    last_updated_by = fnd_global.user_id,
    last_update_login = fnd_global.login_id
 -- end of fix
    where assignment_id = l_assignment_id
    and (l_deleted_proposal_date -1) between change_date and date_to
    and approved = 'N';
 end if;

if (l_approved = 'Y') then

    update per_pay_proposals
    set date_to = l_date_to,
    last_update_date = sysdate,
    last_updated_by = fnd_global.user_id,
    last_update_login = fnd_global.login_id
    where assignment_id = l_assignment_id
    and approved = 'Y'
    and change_date = ( select max(change_date)
    from per_pay_proposals
    where assignment_id = l_assignment_id
    and change_date <  l_deleted_proposal_date
    and approved = 'Y' );

 end if;
/*
   update per_pay_proposals
    set last_change_date = l_last_change_date
    where assignment_id = l_assignment_id
    and change_date =
    (select min(t.change_date)
     from per_pay_proposals t
     where t.assignment_id = l_assignment_id
     and t.change_date > l_deleted_proposal_date
    );
*/

  end if;
  --
  hr_utility.set_location('Exiting2:'||l_proc,50);

  --
end;


--
-- ----------------------------------------------------------------------------
-- |-------------------------< maintain_elements >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This business support process keeps track of the element entries of
-- a proposal, altering them as neccesary.
--
-- Pre Conditions:
--
-- In Parameters:
--   p_pay_proposal_id
--     The pay_proposal_id of the proposal to be altered
--   p_assignment_id
--      The assignment_id of the proposal to be altered
--   p_change_date
--      The date on which the change take effect
--   p_element_entry_id
--      The element entry id of the maintaind element
--   p_proposed_salary
--      The salary to give the element
--
-- Post Success:
--   An element will be inserted or changed  without being committed
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   this is only for calls from the insert_proposal_api
--   and update_proposal_api
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
--
Procedure maintain_elements_bsp(p_pay_proposal_id  in     number
                               ,p_assignment_id    in     number
                               ,p_change_date      in     date
                                ,p_date_to          in     date
                               ,p_element_entry_id in out nocopy number
                               ,p_proposed_salary  in     number) is
--
  l_element_type_id	 pay_element_types_f.element_type_id%TYPE;
  l_input_value_id	 pay_input_values_f.input_value_id%TYPE;
  l_element_link_id	 pay_element_links_f.element_link_id%TYPE;
  l_effective_end_date   date;
  l_effective_start_date date := p_change_date;
  l_first_date date;
  l_last_date  date;
  l_date_to    date;
  l_pay_annualization_factor NUMBER;
  l_payroll_annualization_factor NUMBER;
  l_entry_value NUMBER;
  l_proc    varchar2(72) := g_package||'maintain_elements_bsp';
  l_dummy number;
  l_dummy_v varchar2(300);
  l_entry_value2 NUMBER;
  l_input_value_id2 pay_input_values_f.input_value_id%TYPE;
  l_payroll_value VARCHAR2(80);
  l_next_change_date     per_pay_proposals.change_date%TYPE;
  l_Entry_End_Date       pay_element_entries_f.effective_end_date%TYPE;
  l_pay_basis            per_pay_bases.pay_basis%TYPE;
--
--
cursor csr_get_element_detail is
  select pet.element_type_id,
	 piv.input_value_id,
         ppb.pay_annualization_factor,
         ppb.pay_basis
  from
 	 pay_element_types_f  pet,
	 pay_input_values_f   piv,
	 per_pay_bases        ppb,
	 per_all_assignments_f    asg

  where
	 pet.element_type_id = piv.element_type_id
  and    p_change_date BETWEEN pet.effective_start_date
  and    pet.effective_end_date
  and    piv.input_value_id = ppb.input_value_id
  and    p_change_date BETWEEN piv.effective_start_date
         AND    piv.effective_end_date
  and    ppb.pay_basis_id = asg.pay_basis_id
  and    asg.assignment_id = p_assignment_id
  and    p_change_date   BETWEEN asg.effective_start_date
         AND     asg.effective_end_date;
--
  cursor get_first_date is
    select min(effective_start_date)
    from pay_element_entries_f
    where element_entry_id=p_element_entry_id;

  Cursor get_last_date
  is
  select max(effective_end_date)
    from pay_element_entries_f
    where element_entry_id=p_element_entry_id;
--
  cursor get_existing_date is
  select 1
  from pay_element_entries_f
  where effective_start_date=p_change_date
  and element_entry_id=p_element_entry_id;
--
  cursor get_payroll_element(p_element_type_id NUMBER) is
  select piv.input_value_id
  from pay_input_values_f piv
  , hr_lookups hrl
  where piv.element_type_id=p_element_type_id
  and piv.name=hrl.meaning
  and p_change_date between
  piv.effective_start_date
  and piv.effective_end_date
  and hrl.lookup_type='NAME_TRANSLATIONS'
  and hrl.lookup_code='PAYROLL_VALUE'
  and p_change_date between
  nvl(hrl.start_date_active,p_change_date)
  and nvl(hrl.end_date_active,p_change_date);

  cursor Csr_Entry_End_Date is
  select effective_end_date
  from pay_element_entries_f
  where effective_start_date=p_change_date
  and element_entry_id=p_element_entry_id;
--
  Cursor get_next_approved_change_date
  IS
  select min(change_date)
  from per_pay_proposals
  where assignment_id = p_assignment_id
  and change_date > p_change_date;

  Cursor csr_element_entries
  IS
  select element_entry_id,effective_start_date,effective_end_date
  from pay_element_entries_f
  where effective_end_date between p_change_date and  l_date_to-1
  and element_entry_id = p_element_entry_id;

--
--
  begin
--
    hr_utility.set_location('Entering:'||l_proc,5);
    l_date_to := p_date_to;

    open  csr_get_element_detail;
    fetch csr_get_element_detail into l_element_type_id,
                                      l_input_value_id,
                                      l_pay_annualization_factor,
                                      l_pay_basis;
    if csr_get_element_detail%notfound then
      hr_utility.set_location(l_proc,10);
      close csr_get_element_detail;
      hr_utility.set_message(801,'HR_289855_SAL_ASS_NOT_SAL_ELIG');
      hr_utility.raise_error;
    else
      close csr_get_element_detail;
      per_pay_proposals_populate.get_payroll(p_assignment_id
                                            ,p_change_date
                                            ,l_dummy_v
                                            ,l_payroll_annualization_factor);
--
      hr_utility.set_location(l_proc,15);
--
      if(l_pay_annualization_factor is null and l_pay_basis='PERIOD') then
        l_pay_annualization_factor:=l_payroll_annualization_factor;
      end if;
      l_entry_value:=p_proposed_salary;
      l_entry_value2:=p_proposed_salary
                    *l_pay_annualization_factor
                    /l_payroll_annualization_factor;
--
      if (l_element_type_id IS NULL OR l_input_value_id IS NULL)
       then
        hr_utility.set_location(l_proc,20);
        hr_utility.set_message(801,'HR_289855_SAL_ASS_NOT_SAL_ELIG');
        hr_utility.raise_error;
      else
--
--      get the payroll element if it exists
--
        open get_payroll_element(l_element_type_id);
        fetch get_payroll_element into l_input_value_id2;
        if(get_payroll_element%notfound) then
          hr_utility.set_location(l_proc,25);
          close get_payroll_element;
          l_input_value_id2:=null;
          l_entry_value2:=null;
        else
          close get_payroll_element;
        end if;
--
        if (p_element_entry_id is null) THEN
-- this must be a new entry so do the inserting of the element
--
          hr_utility.set_location(l_proc,30);
          l_element_link_id := hr_entry_api.get_link
                               (p_assignment_id
                               ,l_element_type_id
                               ,p_change_date);
          if l_element_link_id IS NULL then
            hr_utility.set_location(l_proc,35);
            hr_utility.set_message(801,'HR_13016_SAL_ELE_NOT_ELIG');
            hr_utility.raise_error;
          end if;
          hr_utility.set_location(l_proc,40);
          open get_existing_date;
          fetch get_existing_date into l_dummy;
          if(get_existing_date%found) then
              close get_existing_date;
              hr_utility.set_location(l_proc,45);
              hr_utility.set_message(801,'HR_13003_SAL_SAL_CHANGE_EXISTS');
              hr_utility.raise_error;
          else
            close get_existing_date;
--
-- Now we insert an element entry for this proposal
-- by calling the insert_element_entry_api.
--
             hr_utility.set_location(l_proc,50);
             hr_entry_api.insert_element_entry
		      (p_effective_start_date	   =>l_effective_start_date
		      ,p_effective_end_date	   => l_effective_end_date
		      ,p_element_entry_id          => p_element_entry_id
		      ,p_assignment_id		   => p_assignment_id
		      ,p_element_link_id	   => l_element_link_id
		      ,p_creator_type		   => 'SP'
		      ,p_entry_type		   => 'E'
		      ,p_creator_id		   => p_pay_proposal_id
		      ,p_input_value_id1 	   => l_input_value_id
		      ,p_entry_value1		   => l_entry_value
		      ,p_input_value_id2 	   => l_input_value_id2
		      ,p_entry_value2		   => l_entry_value2
		      );
           end if;

         else
             hr_utility.set_location(l_proc,65);
             hr_entry_api.update_element_entry
                   (p_dt_update_mode    => get_dt_mode(p_change_date,p_element_entry_id)
                   ,p_session_date      => p_change_date
                   ,p_check_for_update  => 'Y'
                   ,p_element_entry_id  => p_element_entry_id
                   ,p_creator_type      => 'SP'
                   ,p_creator_id        => p_pay_proposal_id
                   ,p_input_value_id1   => l_input_value_id
                   ,p_entry_value1      => l_entry_value
		           ,p_input_value_id2 	=> l_input_value_id2
        		   ,p_entry_value2      => l_entry_value2
                   );
        end if;

hr_utility.set_location('Effective End Date of the element entry:'||l_effective_end_date,69);

    OPEN get_last_date;
    FETCH get_last_date INTO l_last_date;
    CLOSE get_last_date;

     IF l_date_to > l_last_date THEN

      UPDATE per_pay_proposals
      SET date_to = l_last_date
      WHERE pay_proposal_id = p_pay_proposal_id;

      l_date_to := l_last_date;

     END IF;

        OPEN Csr_Entry_End_Date;
        FETCH Csr_Entry_End_Date into l_Entry_End_Date;
        CLOSE Csr_Entry_End_Date;

    IF l_date_to >  l_Entry_End_Date THEN
            FOR i in csr_element_entries LOOP
            hr_utility.set_location('Inside the loop'||i.effective_start_date,69);
            hr_entry_api.delete_element_entry
                  ('DELETE_NEXT_CHANGE',
                   i.effective_end_date,
                    p_element_entry_id);
            END LOOP;

    ELSIF l_date_to < l_Entry_End_Date THEN
    	hr_entry_api.update_element_entry
                   (p_dt_update_mode    => get_dt_mode(l_date_to+1,p_element_entry_id)
                   ,p_session_date      => l_date_to+1
                   ,p_check_for_update  => 'Y'
                   ,p_element_entry_id  => p_element_entry_id
                   ,p_creator_type      => 'SP'
                   ,p_creator_id        => p_pay_proposal_id
                   ,p_input_value_id1   => l_input_value_id
                   ,p_entry_value1      => 0
        		   ,p_input_value_id2 	=> l_input_value_id2
            	   ,p_entry_value2      => 0
                   );
    ELSE
        hr_utility.set_location('The element entry end date and the date_to are matching',89);
    END IF;  --l_date_to and element entry date comparisons
 end if;
	 end if;

--changes for Position Control check on Salary proposal
   pqh_psf_bus.chk_position_budget( p_assignment_id => p_assignment_id
                                   ,p_element_type_id => l_element_type_id
                                   ,p_input_value_id  => l_input_value_id
                                   ,p_effective_date  => p_change_date
                                   ,p_called_from    => 'SAL');
--End changes for position control rule on sal proposal
--
  hr_utility.set_location('Leaving:'||l_proc,70);
  end maintain_elements_bsp;
--
-- ----------------------------------------------------------------------------
-- |----------------------< insert_salary_proposal >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure insert_salary_proposal(
  p_pay_proposal_id              out nocopy number,
  p_assignment_id                in number,
  p_business_group_id            in number,
  p_change_date                  in date,        -- Bug 918219
  p_comments                     in varchar2,
  p_next_sal_review_date         in date,
  p_proposal_reason              in varchar2,
  p_proposed_salary_n            in number,
  p_forced_ranking               in number,
  p_date_to			 in date,
  p_performance_review_id        in number,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_object_version_number        out nocopy number,
  p_multiple_components          in varchar2, -- 918219
  p_approved                     in varchar2, -- 918219
  p_validate                     in boolean,
  p_element_entry_id             in out nocopy number,
  p_inv_next_sal_date_warning	 out nocopy boolean,
  p_proposed_salary_warning      out nocopy boolean,
  p_approved_warning             out nocopy boolean,
  p_payroll_warning		 out nocopy boolean ) is
--

-- changed by schowdhu for bug #7693247 16-jan-2009
-- included p_change_date as input param

Cursor next_change_date(p_change_date DATE)
IS
select min(change_date)
from per_pay_proposals
where assignment_id = p_assignment_id
and  change_date > p_change_date
and approved = p_approved;

  l_proc    varchar2(72) := g_package||'insert_salary_proposal';
  l_pay_proposal_id              per_pay_proposals.pay_proposal_id%TYPE;
  l_change_date                  per_pay_proposals.change_date%TYPE;
  l_date_to                      per_pay_proposals.date_to%TYPE;
  l_next_sal_review_date         per_pay_proposals.next_sal_review_date%TYPE;
  l_object_version_number        per_pay_proposals.object_version_number%TYPE;
  l_element_entry_id             pay_element_entries_f.element_entry_id%TYPE;
  l_inv_next_sal_date_warning	 boolean;
  l_proposed_salary_warning      boolean;
  l_approved_warning             boolean;
  l_payroll_warning		         boolean;
  l_temp_element_entry_id        number := p_element_entry_id;
  l_payroll_value                number;
  l_next_change_date            per_pay_proposals.change_date%TYPE;

--
--
  begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
-- Issue a savepoint
--
  savepoint insert_salary_proposal;
--
-- Truncate dates
  l_change_date               := trunc(p_change_date);
  l_next_sal_review_date      := trunc(p_next_sal_review_date);

  l_date_to          := p_date_to;

if l_date_to is null or l_date_to = hr_general.end_of_time then

    OPEN next_change_date(l_change_date);
    fetch next_change_date into l_next_change_date;
    close next_change_date;

    if l_next_change_date is null then
     l_date_to:= hr_general.end_of_time;
    else
     l_date_to := l_next_change_date-1;
    end if;

  end if;

--
-- Process Logic
--
  l_element_entry_id          := p_element_entry_id;



  -- Call Before Process User Hook for insert_salary_proposal
  --
  begin
    hr_maintain_proposal_bk1.insert_salary_proposal_b
      (
       p_assignment_id                => p_assignment_id,
       p_business_group_id            => p_business_group_id,
       p_change_date                  => l_change_date,
       p_comments                     => p_comments,
       p_next_sal_review_date         => l_next_sal_review_date,
       p_proposal_reason              => p_proposal_reason,
       p_proposed_salary_n            => p_proposed_salary_n,
       p_forced_ranking               => p_forced_ranking,
       p_date_to		      => l_date_to,
       p_performance_review_id        => p_performance_review_id,
       p_attribute_category           => p_attribute_category,
       p_attribute1                   => p_attribute1,
       p_attribute2                   => p_attribute2,
       p_attribute3                   => p_attribute3,
       p_attribute4                   => p_attribute4,
       p_attribute5                   => p_attribute5,
       p_attribute6                   => p_attribute6,
       p_attribute7                   => p_attribute7,
       p_attribute8                   => p_attribute8,
       p_attribute9                   => p_attribute9,
       p_attribute10                  => p_attribute10,
       p_attribute11                  => p_attribute11,
       p_attribute12                  => p_attribute12,
       p_attribute13                  => p_attribute13,
       p_attribute14                  => p_attribute14,
       p_attribute15                  => p_attribute15,
       p_attribute16                  => p_attribute16,
       p_attribute17                  => p_attribute17,
       p_attribute18                  => p_attribute18,
       p_attribute19                  => p_attribute19,
       p_attribute20                  => p_attribute20,
       p_multiple_components          => p_multiple_components,
       p_approved                     => p_approved,
       p_element_entry_id             => p_element_entry_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'INSERT_SALARY_PROPOSAL'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of the before hook for insert_salary_proposal
  --
  end;
  --
  --
  -- End Date Previous Salary Proposal with p_change_date-1
    --
   --added by vkodedal to fix 6001309
   --
    hr_general.g_data_migrator_mode := 'Y';
    --

    /* Salary proposals to be end dated depending upon the
       status of the calling proposal. Bug#7386307  by schowdhu
     */

    if (p_approved = 'N') then
       end_date_proposed_proposal(p_assignment_id, p_change_date-1);
      else
-- changed by schowdhu for 7673294 05-jan-08
      end_date_approved_proposal(p_assignment_id => p_assignment_id
                                ,p_date_to => p_change_date-1
                                ,p_proposal_id => NULL);

    end if;

      --added by schowdhu to fix 7205132
    	update_last_change_date(p_assignment_id, p_change_date);

   hr_general.g_data_migrator_mode := 'N';
  ----------vkodedal 7-mar-07
  --
  --  Update the last_change_date for the next proposal
  --
      --commented out by schowdhu to fix 7205132
--	update_last_change_date(p_assignment_id, p_change_date);

  per_pyp_ins.ins
		     (p_pay_proposal_id		=> l_pay_proposal_id
		     ,p_assignment_id		=> p_assignment_id
		     ,p_business_group_id	=> p_business_group_id
		     ,p_change_date		=> l_change_date
                     ,p_comments                => p_comments
                     ,p_next_sal_review_date    => l_next_sal_review_date
		     ,p_proposal_reason		=> p_proposal_reason
                     ,p_proposed_salary_n       => p_proposed_salary_n
                     ,p_forced_ranking          => p_forced_ranking
        	     ,p_date_to			=> l_date_to
                     ,p_performance_review_id   => p_performance_review_id
                     ,p_attribute_category      => p_attribute_category
                     ,p_attribute1              => p_attribute1
                     ,p_attribute2              => p_attribute2
                     ,p_attribute3              => p_attribute3
                     ,p_attribute4              => p_attribute4
                     ,p_attribute5              => p_attribute5
                     ,p_attribute6              => p_attribute6
                     ,p_attribute7              => p_attribute7
                     ,p_attribute8              => p_attribute8
                     ,p_attribute9              => p_attribute9
                     ,p_attribute10             => p_attribute10
                     ,p_attribute11             => p_attribute11
                     ,p_attribute12             => p_attribute12
                     ,p_attribute13             => p_attribute13
                     ,p_attribute14             => p_attribute14
                     ,p_attribute15             => p_attribute15
                     ,p_attribute16             => p_attribute16
                     ,p_attribute17             => p_attribute17
                     ,p_attribute18             => p_attribute18
                     ,p_attribute19             => p_attribute19
                     ,p_attribute20             => p_attribute20
                     ,p_object_version_number	=> l_object_version_number
    		     ,p_multiple_components	=> p_multiple_components
	   	     ,p_approved		=> p_approved
	   	     ,p_validate		=> false
		     ,p_inv_next_sal_date_warning
					=> l_inv_next_sal_date_warning
		     ,p_proposed_salary_warning
		     			=> l_proposed_salary_warning
		     ,p_approved_warning
					=> l_approved_warning
		     ,p_payroll_warning
					=> l_payroll_warning
		     );
--
-- Now maintain element entries;
--
--  Added by ggnanagu
--  To get the element entry id, if its passed as null
--
  if l_element_entry_id is null then
    per_pay_proposals_populate.GET_ELEMENT_ID(p_assignment_id     => p_assignment_id,
                           p_business_group_id => p_business_group_id,
                           p_change_date       => p_change_date,
                           p_payroll_value       => l_payroll_value,
                           p_element_entry_id    =>  l_element_entry_id);
  end if;
--
   hr_utility.set_location(l_proc,20);
   if(p_approved='Y') then
    hr_utility.set_location(l_proc,30);
--  parameter p_element_entry_id is change to l_element_entry_id to fix the bug#3488239.
    maintain_elements_bsp(l_pay_proposal_id
                      ,p_assignment_id
                      ,p_change_date
		      ,l_date_to
                      ,l_element_entry_id
                      ,p_proposed_salary_n);
   end if;
--
  hr_utility.set_location(l_proc, 40);
--
  -- Call After Process User Hook for insert_salary_proposal
  --
  begin
    hr_maintain_proposal_bk1.insert_salary_proposal_a
      (
       p_pay_proposal_id              => l_pay_proposal_id,
       p_assignment_id                => p_assignment_id,
       p_business_group_id            => p_business_group_id,
       p_change_date                  => l_change_date,
       p_comments                     => p_comments,
       p_next_sal_review_date         => l_next_sal_review_date,
       p_proposal_reason              => p_proposal_reason,
       p_proposed_salary_n            => p_proposed_salary_n,
       p_forced_ranking               => p_forced_ranking,
       p_date_to		      => l_date_to,
       p_performance_review_id        => p_performance_review_id,
       p_attribute_category           => p_attribute_category,
       p_attribute1                   => p_attribute1,
       p_attribute2                   => p_attribute2,
       p_attribute3                   => p_attribute3,
       p_attribute4                   => p_attribute4,
       p_attribute5                   => p_attribute5,
       p_attribute6                   => p_attribute6,
       p_attribute7                   => p_attribute7,
       p_attribute8                   => p_attribute8,
       p_attribute9                   => p_attribute9,
       p_attribute10                  => p_attribute10,
       p_attribute11                  => p_attribute11,
       p_attribute12                  => p_attribute12,
       p_attribute13                  => p_attribute13,
       p_attribute14                  => p_attribute14,
       p_attribute15                  => p_attribute15,
       p_attribute16                  => p_attribute16,
       p_attribute17                  => p_attribute17,
       p_attribute18                  => p_attribute18,
       p_attribute19                  => p_attribute19,
       p_attribute20                  => p_attribute20,
       p_object_version_number        => l_object_version_number,
       p_multiple_components          => p_multiple_components,
       p_approved                     => p_approved,
       p_element_entry_id             => l_element_entry_id,
       p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning,
       p_proposed_salary_warning      => l_proposed_salary_warning,
       p_approved_warning             => l_approved_warning,
       p_payroll_warning              => l_payroll_warning
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'INSERT_SALARY_PROPOSAL'
        ,p_hook_type   => 'AP'
        );
 --
  -- End of after hook for insert_salary_proposal
  --
  end;
--
-- If we are validating then raise the Validate_Enabled exception
--
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  -- Set OUT parameters
  --
  p_pay_proposal_id              := l_pay_proposal_id;
  p_object_version_number        := l_object_version_number;
  p_element_entry_id             := l_element_entry_id;
  p_inv_next_sal_date_warning	 := l_inv_next_sal_date_warning;
  p_proposed_salary_warning      := l_proposed_salary_warning;
  p_approved_warning             := l_approved_warning;
  p_payroll_warning		 := l_payroll_warning;
  --
  hr_utility.set_location('Leaving: '||l_proc,50);
--
  Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO insert_salary_proposal;
  --
  -- Only set output warning arguments
  -- (Any key or derived arguments must be set to null
  -- when validation only mode is being used.)
  --
  p_pay_proposal_id              := null;
  p_object_version_number        := null;
  p_inv_next_sal_date_warning	 := l_inv_next_sal_date_warning;
  p_proposed_salary_warning      := l_proposed_salary_warning;
  p_approved_warning             := l_approved_warning;
  p_payroll_warning		 := l_payroll_warning;

  p_element_entry_id             := l_temp_element_entry_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
  When others then
  --
  -- A validation or unexpected error has occured
  --
  ROLLBACK TO insert_salary_proposal;
  p_pay_proposal_id              := null;
  p_object_version_number        := null;
  p_inv_next_sal_date_warning	 := null;
  p_proposed_salary_warning      := null;
  p_approved_warning             := null;
  p_payroll_warning		 := null;
  p_element_entry_id             := l_temp_element_entry_id;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  raise;
  --
  end insert_salary_proposal;
--
-- ----------------------------------------------------------------------------
-- |----------------------< insert_salary_proposal >--------------------------|
-------------------------------------------------------------------------------
-----------------------  Without the new date_to parameter  -------------------
-------------------------------------------------------------------------------
--
Procedure insert_salary_proposal(
  p_pay_proposal_id              out nocopy number,
  p_assignment_id                in number,
  p_business_group_id            in number,
  p_change_date                  in date,        -- Bug 918219
  p_comments                     in varchar2,
  p_next_sal_review_date         in date,
  p_proposal_reason              in varchar2,
  p_proposed_salary_n            in number,
  p_forced_ranking               in number,
  p_performance_review_id        in number,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_object_version_number        out nocopy number,
  p_multiple_components          in varchar2, -- 918219
  p_approved                     in varchar2, -- 918219
  p_validate                     in boolean,
  p_element_entry_id             in out nocopy number,
  p_inv_next_sal_date_warning	 out nocopy boolean,
  p_proposed_salary_warning      out nocopy boolean,
  p_approved_warning             out nocopy boolean,
  p_payroll_warning		 out nocopy boolean ) is
--
--
  begin
  hr_maintain_proposal_api.insert_salary_proposal
    (p_pay_proposal_id              => p_pay_proposal_id
    ,p_assignment_id                => p_assignment_id
    ,p_business_group_id            => p_business_group_id
    ,p_change_date                  => p_change_date
    ,p_comments                     => p_comments
    ,p_next_sal_review_date         => p_next_sal_review_date
    ,p_proposal_reason              => p_proposal_reason
    ,p_proposed_salary_n            => p_proposed_salary_n
    ,p_forced_ranking               => p_forced_ranking
    ,p_date_to			    => null
    ,p_performance_review_id        => p_performance_review_id
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
    ,p_object_version_number        => p_object_version_number
    ,p_multiple_components          => p_multiple_components
    ,p_approved                     => p_approved
    ,p_validate                     => p_validate
    ,p_element_entry_id             => p_element_entry_id
    ,p_inv_next_sal_date_warning    => p_inv_next_sal_date_warning
    ,p_proposed_salary_warning      => p_proposed_salary_warning
    ,p_approved_warning             => p_approved_warning
    ,p_payroll_warning              => p_payroll_warning
    );
  --
  end insert_salary_proposal;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_salary_proposal >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_salary_proposal(
  p_pay_proposal_id              in number,
  p_change_date                  in date,
  p_comments                     in varchar2,
  p_next_sal_review_date         in date,
  p_proposal_reason              in varchar2,
  p_proposed_salary_n            in number,
  p_forced_ranking               in number,
  p_date_to			 in date,
  p_performance_review_id        in number,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_object_version_number        in out nocopy number,
  p_multiple_components          in varchar2,
  p_approved                     in varchar2,
  p_validate                     in boolean,
  p_inv_next_sal_date_warning    out nocopy boolean,
  p_proposed_salary_warning	 out nocopy boolean,
  p_approved_warning	         out nocopy boolean,
  p_payroll_warning              out nocopy boolean) is
--
  l_proc    varchar2(72) := g_package||'update_salary_proposal';
  l_element_type_id	         pay_element_types_f.element_type_id%TYPE;
  l_input_value_id               pay_input_values_f.input_value_id%TYPE;
  l_element_link_id              pay_element_links_f.element_link_id%TYPE;
  l_element_entry_id             pay_element_entries_f.element_entry_id%TYPE;
  l_change_date                  per_pay_proposals.change_date%TYPE;
  l_next_sal_review_date         per_pay_proposals.next_sal_review_date%TYPE;
  l_next_change_date             per_pay_proposals.change_date%TYPE;
  l_date_to                      per_pay_proposals.date_to%TYPE;
  l_object_version_number        per_pay_proposals.object_version_number%TYPE;
  l_inv_next_sal_date_warning    boolean;
  l_proposed_salary_warning	 boolean;
  l_approved_warning	         boolean;
  l_payroll_warning	         boolean;
  l_assignment_id                per_pay_proposals.assignment_id%TYPE;
  l_proposed_salary_n            per_pay_proposals.proposed_salary_n%TYPE;
  l_temp_ovn   number := p_object_version_number;
--
--

Cursor get_assignment_id
is
select assignment_id
from per_pay_proposals
where pay_proposal_id = p_pay_proposal_id;

cursor get_element IS
  select pee.element_entry_id
  ,      pyp.assignment_id
  from   pay_element_entries_f pee
  ,      per_pay_proposals pyp
  where  pyp.pay_proposal_id=p_pay_proposal_id
  and    pee.assignment_id=pyp.assignment_id
  and    NVL(l_change_date,to_date('31-12-4127','DD-MM-YYYY')) between
         pee.effective_start_date and pee.effective_end_date
  and    pee.creator_type='SP';

-- changes the cursor to add approved = p_approve  schowdhu - 04-Dec-2008
-- changed by schowdhu for bug #7693247 16-jan-2009
-- included p_change_date as input param

Cursor next_change_date(p_change_date DATE)
IS
select min(change_date)
from per_pay_proposals pro
where assignment_id = l_assignment_id
and  change_date > p_change_date
and approved = p_approved;

--
  begin

    hr_utility.set_location('Entering:'||l_proc,5);
--
-- Issue a savepoint
--
  savepoint update_salary_proposal;
--
  --
  -- get the old record details
  --
  per_pyp_shd.lck
  (p_pay_proposal_id       => p_pay_proposal_id
  ,p_object_version_number => p_object_version_number);
  --
  if p_change_date = hr_api.g_date then
    l_change_date:=per_pyp_shd.g_old_rec.change_date;
  else
    l_change_date               := trunc(p_change_date);
  end if;
--

 l_date_to          := p_date_to;

OPEN get_assignment_id;
fetch get_assignment_id into l_assignment_id;
CLOSE get_assignment_id;
-- changed if condition schowdhu - 04-Dec-2008

if l_date_to is null or l_date_to = hr_general.end_of_time then

    OPEN next_change_date(l_change_date);
    fetch next_change_date into l_next_change_date;
    close next_change_date;

    if l_next_change_date is null then
     l_date_to:= hr_general.end_of_time;
    else
     l_date_to := l_next_change_date-1;
    end if;

  end if;


  l_next_sal_review_date    := trunc(p_next_sal_review_date);
--
-- Process Logic
--
  l_object_version_number   := p_object_version_number;
--
  -- Call Before Process User Hook for update_salary_proposal
  --
  begin
    hr_maintain_proposal_bk2.update_salary_proposal_b
      (
       p_pay_proposal_id              => p_pay_proposal_id,
       p_change_date                  => l_change_date,
       p_comments                     => p_comments,
       p_next_sal_review_date         => l_next_sal_review_date,
       p_proposal_reason              => p_proposal_reason,
       p_proposed_salary_n            => p_proposed_salary_n,
       p_forced_ranking               => p_forced_ranking,
       p_date_to		      => l_date_to,
       p_performance_review_id        => p_performance_review_id,
       p_attribute_category           => p_attribute_category,
       p_attribute1                   => p_attribute1,
       p_attribute2                   => p_attribute2,
       p_attribute3                   => p_attribute3,
       p_attribute4                   => p_attribute4,
       p_attribute5                   => p_attribute5,
       p_attribute6                   => p_attribute6,
       p_attribute7                   => p_attribute7,
       p_attribute8                   => p_attribute8,
       p_attribute9                   => p_attribute9,
       p_attribute10                  => p_attribute10,
       p_attribute11                  => p_attribute11,
       p_attribute12                  => p_attribute12,
       p_attribute13                  => p_attribute13,
       p_attribute14                  => p_attribute14,
       p_attribute15                  => p_attribute15,
       p_attribute16                  => p_attribute16,
       p_attribute17                  => p_attribute17,
       p_attribute18                  => p_attribute18,
       p_attribute19                  => p_attribute19,
       p_attribute20                  => p_attribute20,
       p_object_version_number        => p_object_version_number,
       p_multiple_components          => p_multiple_components,
       p_approved                     => p_approved
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SALARY_PROPOSAL'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of the before hook for update_salary_proposal
  --
  end;

 /* logic added to end date salary proposals accordingly while
    updating a proposal Bug#7386307  by schowdhu
  */

  hr_general.g_data_migrator_mode := 'Y';
  --
  if (p_approved = 'N') then
     end_date_proposed_proposal(l_assignment_id, l_change_date-1);
  else
   -- when the underlying salary basis changes update_salary_proposal
   -- is called without p_approved. Bug#7386307  by schowdhu
     end_date_approved_proposal(l_assignment_id, l_change_date-1, p_pay_proposal_id);
  end if;

    update_last_change_date(l_assignment_id, l_change_date);
--
 hr_general.g_data_migrator_mode := 'N';
--
  per_pyp_upd.upd
		     (p_pay_proposal_id		=> p_pay_proposal_id
                     ,p_comments                => p_comments
                     ,p_change_date             => l_change_date
                     ,p_next_sal_review_date    => l_next_sal_review_date
		     ,p_proposal_reason		=> p_proposal_reason
		     ,p_proposed_salary_n       => p_proposed_salary_n
                     ,p_forced_ranking          => p_forced_ranking
		     ,p_date_to			=> l_date_to
                     ,p_performance_review_id   => p_performance_review_id
                     ,p_attribute_category      => p_attribute_category
                     ,p_attribute1              => p_attribute1
                     ,p_attribute2              => p_attribute2
                     ,p_attribute3              => p_attribute3
                     ,p_attribute4              => p_attribute4
                     ,p_attribute5              => p_attribute5
                     ,p_attribute6              => p_attribute6
                     ,p_attribute7              => p_attribute7
                     ,p_attribute8              => p_attribute8
                     ,p_attribute9              => p_attribute9
                     ,p_attribute10             => p_attribute10
                     ,p_attribute11             => p_attribute11
                     ,p_attribute12             => p_attribute12
                     ,p_attribute13             => p_attribute13
                     ,p_attribute14             => p_attribute14
                     ,p_attribute15             => p_attribute15
                     ,p_attribute16             => p_attribute16
                     ,p_attribute17             => p_attribute17
                     ,p_attribute18             => p_attribute18
                     ,p_attribute19             => p_attribute19
                     ,p_attribute20             => p_attribute20
                     ,p_object_version_number	=> l_object_version_number
                     ,p_multiple_components     => p_multiple_components
		     ,p_approved		=> p_approved
		     ,p_validate		=> false
		     ,p_inv_next_sal_date_warning
					=> l_inv_next_sal_date_warning
		     ,p_proposed_salary_warning => l_proposed_salary_warning
		     ,p_approved_warning        => l_approved_warning
                     ,p_payroll_warning         => l_payroll_warning
		     );

 -- Now we maintain an element entry for this proposal
 -- by calling the maintain_elements_bsp.
 --
    hr_utility.set_location(l_proc,10);

    if(p_approved='Y') then
      hr_utility.set_location(l_proc,15);
      open get_element;
      fetch get_element into l_element_entry_id,l_assignment_id;
      if get_element%found then
        close get_element;
        hr_utility.set_location(l_proc,20);
        --
        if p_proposed_salary_n = hr_api.g_number then
          l_proposed_salary_n:=per_pyp_shd.g_old_rec.proposed_salary_n;
        else
          l_proposed_salary_n:=p_proposed_salary_n;
        end if;
        maintain_elements_bsp(p_pay_proposal_id
                             ,l_assignment_id
                             ,l_change_date
			     ,l_date_to
                             ,l_element_entry_id
                             ,l_proposed_salary_n);
      else
        hr_utility.set_location(l_proc,25);
        l_element_entry_id := null;
        select pyp.assignment_id
        into l_assignment_id
        from   per_pay_proposals pyp
        where  pyp.pay_proposal_id=p_pay_proposal_id;
        if p_proposed_salary_n = hr_api.g_number then
          l_proposed_salary_n:=per_pyp_shd.g_old_rec.proposed_salary_n;
        else
          l_proposed_salary_n:=p_proposed_salary_n;
        end if;
        maintain_elements_bsp(p_pay_proposal_id
                             ,l_assignment_id
                             ,l_change_date
			     ,l_date_to
                             ,l_element_entry_id
                             ,l_proposed_salary_n);
        close get_element;
      end if;
    end if;

--
  -- Call After Process User Hook for update_salary_proposal
  --
  begin
    hr_maintain_proposal_bk2.update_salary_proposal_a
     (
      p_pay_proposal_id              => p_pay_proposal_id,
      p_change_date                  => l_change_date,
      p_comments                     => p_comments,
      p_next_sal_review_date         => l_next_sal_review_date,
      p_proposal_reason              => p_proposal_reason,
      p_proposed_salary_n            => p_proposed_salary_n,
      p_forced_ranking               => p_forced_ranking,
      p_date_to			     => l_date_to,
      p_performance_review_id        => p_performance_review_id,
      p_attribute_category           => p_attribute_category,
      p_attribute1                   => p_attribute1,
      p_attribute2                   => p_attribute2,
      p_attribute3                   => p_attribute3,
      p_attribute4                   => p_attribute4,
      p_attribute5                   => p_attribute5,
      p_attribute6                   => p_attribute6,
      p_attribute7                   => p_attribute7,
      p_attribute8                   => p_attribute8,
      p_attribute9                   => p_attribute9,
      p_attribute10                  => p_attribute10,
      p_attribute11                  => p_attribute11,
      p_attribute12                  => p_attribute12,
      p_attribute13                  => p_attribute13,
      p_attribute14                  => p_attribute14,
      p_attribute15                  => p_attribute15,
      p_attribute16                  => p_attribute16,
      p_attribute17                  => p_attribute17,
      p_attribute18                  => p_attribute18,
      p_attribute19                  => p_attribute19,
      p_attribute20                  => p_attribute20,
      p_object_version_number        => l_object_version_number,
      p_multiple_components          => p_multiple_components,
      p_approved                     => p_approved,
      p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning,
      p_proposed_salary_warning	     => l_proposed_salary_warning,
      p_approved_warning             => l_approved_warning,
      p_payroll_warning              => l_payroll_warning
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SALARY_PROPOSAL'
        ,p_hook_type   => 'AP'
       );
  --
  -- End of the after hook for update_salary_proposal
  --
  end;
  --
-- If we are validating then raise the Validate_Enabled exception
--
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  -- Set OUT parameters
  --
  p_object_version_number        := l_object_version_number;
  p_inv_next_sal_date_warning    := l_inv_next_sal_date_warning;
  p_proposed_salary_warning	 := l_proposed_salary_warning;
  p_approved_warning	         := l_approved_warning;
  p_payroll_warning	         := l_payroll_warning;
 --
  hr_utility.set_location('Leaving: '||l_proc,20);
--
  Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
  ROLLBACK TO update_salary_proposal;
  --
  -- Only set output warning arguments
  -- (Any key or derived arguments must be set to null
  -- when validation only mode is being used.)
  --
  p_inv_next_sal_date_warning    := l_inv_next_sal_date_warning;
  p_proposed_salary_warning	 := l_proposed_salary_warning;
  p_approved_warning	         := l_approved_warning;
  p_payroll_warning	         := l_payroll_warning;
  p_object_version_number        := l_temp_ovn;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 25);
  --
  When others then
  --
  -- A validation or unexpected error has occured
  --
  ROLLBACK TO update_salary_proposal;
  p_inv_next_sal_date_warning    := null;
  p_proposed_salary_warning	 := null;
  p_approved_warning	         := null;
  p_payroll_warning	         := null;
  p_object_version_number        := l_temp_ovn;
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  raise;
  --
  end update_salary_proposal;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_salary_proposal >--------------------------|
-- ----------------------------------------------------------------------------
-----------------------  Without the new date_to parameter --------------------
-- ----------------------------------------------------------------------------
--
Procedure update_salary_proposal(
  p_pay_proposal_id              in number,
  p_change_date                  in date,
  p_comments                     in varchar2,
  p_next_sal_review_date         in date,
  p_proposal_reason              in varchar2,
  p_proposed_salary_n            in number,
  p_forced_ranking               in number,
  p_performance_review_id        in number,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_object_version_number        in out nocopy number,
  p_multiple_components          in varchar2,
  p_approved                     in varchar2,
  p_validate                     in boolean,
  p_inv_next_sal_date_warning    out nocopy boolean,
  p_proposed_salary_warning	 out nocopy boolean,
  p_approved_warning	         out nocopy boolean,
  p_payroll_warning              out nocopy boolean) is
--
--
 Cursor csr_date_to
  IS
  select date_to
  from per_pay_proposals
  where pay_proposal_id = p_pay_proposal_id;

  l_date_to PER_PAY_PROPOSALS.date_to%TYPE default null;

  begin

    OPEN csr_date_to;
    FETCH csr_date_to into l_date_to;
    CLOSE csr_date_to;

  hr_maintain_proposal_api.update_salary_proposal
    (p_pay_proposal_id              => p_pay_proposal_id
    ,p_change_date                  => p_change_date
    ,p_comments                     => p_comments
    ,p_next_sal_review_date         => p_next_sal_review_date
    ,p_proposal_reason              => p_proposal_reason
    ,p_proposed_salary_n            => p_proposed_salary_n
    ,p_forced_ranking               => p_forced_ranking
    ,p_date_to			    => l_date_to
    ,p_performance_review_id        => p_performance_review_id
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
    ,p_object_version_number        => p_object_version_number
    ,p_multiple_components          => p_multiple_components
    ,p_approved                     => p_approved
    ,p_validate                     => p_validate
    ,p_inv_next_sal_date_warning    => p_inv_next_sal_date_warning
    ,p_proposed_salary_warning      => p_proposed_salary_warning
    ,p_approved_warning             => p_approved_warning
    ,p_payroll_warning              => p_payroll_warning
    );
  --
  end update_salary_proposal;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< approve_salary_proposal >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure approve_salary_proposal(
  p_pay_proposal_id              in number,
  p_change_date                  in date,
  p_proposed_salary_n            in number,
  p_object_version_number        in out nocopy number,
  p_validate                     in boolean,
  p_inv_next_sal_date_warning    out nocopy boolean,
  p_proposed_salary_warning	 out nocopy boolean,
  p_approved_warning	         out nocopy boolean,
  p_payroll_warning              out nocopy boolean,
  p_error_text                   out nocopy varchar2) is
--
  l_proc    varchar2(72) := g_package||'approve_salary_proposal';
  l_change_date                  per_pay_proposals.change_date%TYPE;
  l_object_version_number        per_pay_proposals.object_version_number%TYPE;
  l_element_entry_id             pay_element_entries_f.element_entry_id%TYPE;
  l_inv_next_sal_date_warning    boolean;
  l_proposed_salary_warning	 boolean;
  l_approved_warning	         boolean;
  l_payroll_warning	         boolean;
  l_error_text                   varchar2(72);
  l_assignment_id                per_pay_proposals.assignment_id%type;
  l_proposed_salary_n            per_pay_proposals.proposed_salary_n%TYPE;
  l_date_to			 per_pay_proposals.date_to%TYPE;
  l_temp_ovn   number := p_object_version_number;
--
--
-- cursor get_element IS
--   select pee.element_entry_id
--   ,      pyp.assignment_id
--   from   pay_element_entries_f pee
--   ,      per_pay_proposals pyp
--   where  pyp.pay_proposal_id=p_pay_proposal_id
--   and    pee.assignment_id=pyp.assignment_id
--   and    NVL(l_change_date,to_date('31-12-4127','DD-MM-YYYY')) between
--          pee.effective_start_date and pee.effective_end_date
--   and    pee.creator_type='SP';
--
-- Bug 1732348 Fix

cursor get_element IS
  select pee.element_entry_id
  from   pay_element_entries_f pee
  where  pee.assignment_id=l_assignment_id
  and    NVL(l_change_date,to_date('31-12-4127','DD-MM-YYYY')) between
         pee.effective_start_date and pee.effective_end_date
  and    pee.creator_type='SP';

cursor csr_get_date_to
is
select date_to
from per_pay_proposals
where pay_proposal_id = p_pay_proposal_id;

  begin
    hr_utility.set_location('Entering:'||l_proc,5);
--
-- Issue a savepoint
--
  savepoint approve_salary_proposal;
  --
  -- Process Logic
  --
  l_object_version_number     := p_object_version_number;
  --
  -- get the old record details
  --
  per_pyp_shd.lck
  (p_pay_proposal_id       => p_pay_proposal_id
  ,p_object_version_number => p_object_version_number);
  --
  if p_change_date = hr_api.g_date then
    l_change_date:=per_pyp_shd.g_old_rec.change_date;
  else
    l_change_date               := trunc(p_change_date);
  end if;
  --
  -- Call Before Process User Hook for approve_salary_proposal
  --
  begin
    hr_maintain_proposal_bk3.approve_salary_proposal_b
      (
       p_pay_proposal_id              => p_pay_proposal_id,
       p_change_date                  => l_change_date,
       p_proposed_salary_n            => p_proposed_salary_n,
       p_object_version_number        => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'APPROVE_SALARY_PROPOSAL'
        ,p_hook_type   => 'BP'
       );
  --
  -- End of the after hook for approve_salary_proposal
  --
  end;
  --
--
/* last approved proposal is end-dated if proposals are
   approved through SalMgmt screen. Bug#7386307  by schowdhu
*/
	l_assignment_id:=per_pyp_shd.g_old_rec.assignment_id;
--
  	if (nvl(per_pyp_shd.g_old_rec.approved,'N')<>'Y') then
  	   end_date_approved_proposal(l_assignment_id, l_change_date-1, p_pay_proposal_id);
 	end if;
  	update_last_change_date(l_assignment_id, l_change_date);
--

  if(nvl(per_pyp_shd.g_old_rec.approved,'N')<>'Y') THEN
--
-- only do this if the salary is not approved.
--
    per_pyp_upd.upd
		     (p_pay_proposal_id		=> p_pay_proposal_id
                     ,p_change_date             => l_change_date
                     ,p_object_version_number	=> l_object_version_number
                     ,p_proposed_salary_n       => p_proposed_salary_n
		     ,p_approved		=> 'Y'
		     ,p_validate		=> false
		     ,p_inv_next_sal_date_warning
					=> l_inv_next_sal_date_warning
		     ,p_proposed_salary_warning => l_proposed_salary_warning
		     ,p_approved_warning 	=> l_approved_warning
                     ,p_payroll_warning         => l_payroll_warning
		     );

 -- Now we maintain an element entry for this proposal
 -- by calling the maintain_elements_bsp.
 --
     hr_utility.set_location(l_proc,10);
 --
-- Bug 1732348 Fix
    l_assignment_id:=per_pyp_shd.g_old_rec.assignment_id;
    open get_element;
    fetch get_element into l_element_entry_id; -- ,l_assignment_id;
    close get_element;
--
  --
    if p_proposed_salary_n = hr_api.g_number then
      l_proposed_salary_n:=per_pyp_shd.g_old_rec.proposed_salary_n;
    else
      l_proposed_salary_n:=p_proposed_salary_n;
    end if;
    --
    maintain_elements_bsp(p_pay_proposal_id
                         ,l_assignment_id
                         ,l_change_date
			 ,l_date_to
                         ,l_element_entry_id
                         ,l_proposed_salary_n);
--
--
  end if;
--
--
--
  -- Call After Process User Hook for approve_salary_proposal
  --
  begin
    hr_maintain_proposal_bk3.approve_salary_proposal_a
      (
       p_pay_proposal_id              => p_pay_proposal_id,
       p_change_date                  => l_change_date,
       p_proposed_salary_n            => p_proposed_salary_n,
       p_object_version_number        => l_object_version_number,
       p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning,
       p_proposed_salary_warning      => l_proposed_salary_warning,
       p_approved_warning             => l_approved_warning,
       p_payroll_warning              => l_payroll_warning,
       p_error_text                   => l_error_text
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'APPROVE_SALARY_PROPOSAL'
        ,p_hook_type   => 'AP'
        );
  --
  -- End of the after hook for update_salary_proposal
  --
  end;
  --
-- If we are validating then raise the Validate_Enabled exception
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  --
  -- Set OUT parameters
  --
  p_object_version_number        := l_object_version_number;
  p_inv_next_sal_date_warning    := l_inv_next_sal_date_warning;
  p_proposed_salary_warning	 := l_proposed_salary_warning;
  p_approved_warning	         := l_approved_warning;
  p_payroll_warning              := l_payroll_warning;
  p_error_text                   := l_error_text;
  --
  hr_utility.set_location('Leaving: '||l_proc,15);
--
  Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO approve_salary_proposal;
    --
  -- Only set output warning arguments
  -- (Any key or derived arguments must be set to null
  -- when validation only mode is being used.)
  --
  p_inv_next_sal_date_warning    := l_inv_next_sal_date_warning;
  p_proposed_salary_warning	 := l_proposed_salary_warning;
  p_approved_warning	         := l_approved_warning;
  p_payroll_warning              := l_payroll_warning;
  p_error_text                   := null;
  p_object_version_number        := l_temp_ovn;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
  When others then
  --
  -- A validation or unexpected error has occured
  --
    ROLLBACK TO approve_salary_proposal;
  --
  -- Reset IN OUT and set OUT parameters.
  p_inv_next_sal_date_warning    := null;
  p_proposed_salary_warning	 := null;
  p_approved_warning	         := null;
  p_payroll_warning              := null;
  p_object_version_number        := l_temp_ovn;
  p_error_text  := sqlerrm;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 25);
--  raise;
  --
end approve_salary_proposal;
--
-------------------------------------------------------------------------------
-- |----------------------< delete_salary_proposal >--------------------------|
-- ----------------------------------------------------------------------------
--
/* procedure to delete a complete salary proposal, including it's components
*/
Procedure delete_salary_proposal(p_pay_proposal_id       in number
                                ,p_business_group_id     in number
                                ,p_object_version_number in number
                                ,p_validate              in boolean
                                ,p_salary_warning        out nocopy boolean) is
--
  l_salary_warning       boolean;
  l_proc    varchar2(72) := g_package||'delete_salary_proposal';
  l_element_entry_id	 pay_element_entries_f.element_entry_id%TYPE;
  l_change_date date;
  v_zap_entry            boolean;
  v_delete_next_change   boolean;
  v_zap VARCHAR2(1):='N';
  l_approved   per_pay_proposals.approved%TYPE;
  l_future_element_entries number;
  l_assignment_id number;
  l_last_change_date date;
--
  cursor components is
  select ppc.component_id
  ,      ppc.object_version_number
  from   per_pay_proposal_components ppc
  where  ppc.pay_proposal_id=p_pay_proposal_id
  and    ppc.business_group_id=p_business_group_id;

  cursor elements is
  select pee.element_entry_id
  ,      pro.change_date
  from   per_pay_proposals_v2 pro
  ,      pay_element_entries_f pee
  where  pro.pay_proposal_id=p_pay_proposal_id
  and    pro.assignment_id=pee.assignment_id
  and    pee.creator_type='SP'
  and    pro.change_date between pee.effective_start_date
  and pee.effective_end_date;

  Cursor csr_future_element_entries(p_change_date in date,p_element_entry_id in number)
  IS
  select count(*)
  from pay_element_entries_f
  where element_entry_id = p_element_entry_id
  and effective_start_date > p_change_date;

  Cursor csr_proposal_details
  IS
  select approved, last_change_date, assignment_id
  from per_pay_proposals
  where pay_proposal_id =  p_pay_proposal_id;


  begin
    hr_utility.set_location('Entering:'||l_proc,5);
--
--
-- Issue a savepoint
--
  savepoint delete_salary_proposal;
--
--
  -- Call Before Process User Hook for delete_salary_proposal
  --
  begin
    hr_maintain_proposal_bk4.delete_salary_proposal_b
      (
       p_pay_proposal_id        => p_pay_proposal_id
       ,p_business_group_id     => p_business_group_id
       ,p_object_version_number => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SALARY_PROPOSAL'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of the before hook for delete_salary_proposal
  --
  end;
  --
--
-- first of all delete all of the components
--
    FOR l_components IN components LOOP
      per_ppc_del.del(p_component_id=>l_components.component_id
                     ,p_object_version_number=>l_components.object_version_number
                     ,p_validation_strength=>'WEAK'
                     ,p_validate=>FALSE);
    END LOOP;
    hr_utility.set_location(l_proc,10);

    OPEN Csr_proposal_details;
    fetch Csr_proposal_details into l_approved,l_last_change_date, l_assignment_id;
    close Csr_proposal_details;
--
  if l_approved = 'Y' then

   open elements;
   fetch elements into l_element_entry_id,l_change_date;
   close elements;
--
-- delete the element entries
--
    if (l_element_entry_id is not null) then
       --
       hr_utility.set_location(l_proc,15);
       begin
       --
         select 'Y'
         into   v_zap
         from sys.dual
         where exists
         (select 1
          from sys.dual
          where l_change_date =
                (select min(effective_start_date)
                 from pay_element_entries_f
                 where element_entry_id = l_element_entry_id));
          --
          exception
          when no_data_found
           then
             v_delete_next_change := TRUE;
             hr_utility.set_location(l_proc,20);
          --
        end;
        --
        v_zap_entry := (v_zap = 'Y');
    end if;

   end if;
    --
    -- Extend date_to of previous Salary Proposal
    --added by vkodedal to fix 6001309
  hr_general.g_data_migrator_mode := 'Y';
  --
    extend_salary_proposal_to_date(p_pay_proposal_id);
  --

-- added by schowdhu to fix 7205132
  update_last_change_date(l_assignment_id, l_last_change_date);

  hr_general.g_data_migrator_mode := 'N';
  --
--

-- then delete the proposal
--
    hr_utility.set_location(l_proc,25);
    per_pyp_del.del(p_pay_proposal_id=>p_pay_proposal_id
                   ,p_object_version_number=>p_object_version_number
                   ,p_validate=>FALSE
                   ,p_salary_warning=>l_salary_warning);
   --

  if l_approved = 'Y' then
   if (v_zap_entry = TRUE)
    then

    OPEN csr_future_element_entries(l_change_date,l_element_entry_id);
    FETCH csr_future_element_entries into l_future_element_entries;
    CLOSE csr_future_element_entries;

     if l_future_element_entries > 0 then

      hr_utility.set_message(800,'PER_SAL_FIRST_PROPOSAL_DELETE');
      hr_utility.raise_error;

     end if;


     hr_utility.set_location(l_proc,30);
     -- call API to zap entry
     hr_entry_api.delete_element_entry
       ('ZAP',
         l_change_date,
         l_element_entry_id);
   elsif (v_delete_next_change = TRUE)
    then
     hr_utility.set_location(l_proc,35);
     -- Call API to do a 'DELETE_NEXT_CHANGE'
     hr_entry_api.delete_element_entry
                  ('DELETE_NEXT_CHANGE',
                   l_change_date - 1,
                   l_element_entry_id);
   end if;
  end if;
--
  -- Call After Process User Hook for delete_salary_proposal
  --
  begin
    hr_maintain_proposal_bk4.delete_salary_proposal_a
      (
       p_pay_proposal_id        => p_pay_proposal_id
       ,p_business_group_id     => p_business_group_id
       ,p_object_version_number => p_object_version_number
       ,p_salary_warning        => l_salary_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SALARY_PROPOSAL'
        ,p_hook_type   => 'AP'
        );
  --
  -- End of the after hook for delete_salary_proposal
  --
  end;
  --
  ----------vkodedal 7-mar-07
  --  Update the last_change_date for the next proposal
--
--    commented out by schowdhu to fix 7205132
--	update_last_change_date(l_assignment_id, l_last_change_date);
--
-- If we are validating then raise the Validate_Enabled exception
--
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  -- Set OUT parameters
  --
  p_salary_warning := l_salary_warning;
  --
  hr_utility.set_location('Leaving: '||l_proc,40);
--
  Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_salary_proposal;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_salary_warning  := l_salary_warning;

  When others then
  --
  -- A validation or unexpected error has occured
  --
    ROLLBACK TO delete_salary_proposal;
    p_salary_warning  := null;
    raise;
--
end delete_salary_proposal;

--
--
-- ----------------------------------------------------------------------------
-- |---------------------< insert_proposal_component >------------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_proposal_component(
  p_component_id                 out nocopy number,
  p_pay_proposal_id              in number,
  p_business_group_id            in number,
  p_approved                     in varchar2,
  p_component_reason             in varchar2,
  p_change_amount_n              in number,
  p_change_percentage            in number,
  p_comments                     in varchar2,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_validation_strength          in varchar2,
  p_object_version_number        out nocopy number,
  p_validate                     in boolean
  ) is
--
  l_proc    varchar2(72) := g_package||'insert_proposal_component';
  l_component_id            per_pay_proposal_components.component_id%TYPE;
  l_object_version_number   per_pay_proposal_components.object_version_number%TYPE;
--
  begin
    hr_utility.set_location('Entering:'||l_proc,5);
--
--
-- Issue a savepoint
--
  savepoint insert_proposal_components;
--
--
  -- Call Before Process User Hook for insert_proposal_components
  --
  begin
    hr_maintain_proposal_bk5.insert_proposal_component_b
      (
       p_pay_proposal_id              => p_pay_proposal_id,
       p_business_group_id            => p_business_group_id,
       p_approved                     => p_approved,
       p_component_reason             => p_component_reason,
       p_change_amount_n              => p_change_amount_n,
       p_change_percentage            => p_change_percentage,
       p_comments                     => p_comments,
       p_attribute_category           => p_attribute_category,
       p_attribute1                   => p_attribute1,
       p_attribute2                   => p_attribute2,
       p_attribute3                   => p_attribute3,
       p_attribute4                   => p_attribute4,
       p_attribute5                   => p_attribute5,
       p_attribute6                   => p_attribute6,
       p_attribute7                   => p_attribute7,
       p_attribute8                   => p_attribute8,
       p_attribute9                   => p_attribute9,
       p_attribute10                  => p_attribute10,
       p_attribute11                  => p_attribute11,
       p_attribute12                  => p_attribute12,
       p_attribute13                  => p_attribute13,
       p_attribute14                  => p_attribute14,
       p_attribute15                  => p_attribute15,
       p_attribute16                  => p_attribute16,
       p_attribute17                  => p_attribute17,
       p_attribute18                  => p_attribute18,
       p_attribute19                  => p_attribute19,
       p_attribute20                  => p_attribute20,
       p_validation_strength          => p_validation_strength
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'INSERT_PROPOSAL_COMPONENTS'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of the after hook for insert_proposal_components
  --
  end;
  --
--
    per_ppc_ins.ins (
      p_component_id           => l_component_id
     ,p_pay_proposal_id        => p_pay_proposal_id
     ,p_business_group_id      => p_business_group_id
     ,p_approved               => p_approved
     ,p_component_reason       => p_component_reason
     ,p_change_amount_n        => p_change_amount_n
     ,p_change_percentage      => p_change_percentage
     ,p_comments               => p_comments
     ,p_attribute_category     => p_attribute_category
     ,p_attribute1             => p_attribute1
     ,p_attribute2             => p_attribute2
     ,p_attribute3             => p_attribute3
     ,p_attribute4             => p_attribute4
     ,p_attribute5             => p_attribute5
     ,p_attribute6             => p_attribute6
     ,p_attribute7             => p_attribute7
     ,p_attribute8             => p_attribute8
     ,p_attribute9             => p_attribute9
     ,p_attribute10            => p_attribute10
     ,p_attribute11            => p_attribute11
     ,p_attribute12            => p_attribute12
     ,p_attribute13            => p_attribute13
     ,p_attribute14            => p_attribute14
     ,p_attribute15            => p_attribute15
     ,p_attribute16            => p_attribute16
     ,p_attribute17            => p_attribute17
     ,p_attribute18            => p_attribute18
     ,p_attribute19            => p_attribute19
     ,p_attribute20            => p_attribute20
     ,p_object_version_number  => l_object_version_number
     ,p_validation_strength    => p_validation_strength
     ,p_validate               => FALSE);
--
--
  -- Call After Process User Hook for insert_proposal_components
  --
  begin
    hr_maintain_proposal_bk5.insert_proposal_component_a
      (
       p_component_id                 => l_component_id,
       p_pay_proposal_id              => p_pay_proposal_id,
       p_business_group_id            => p_business_group_id,
       p_approved                     => p_approved,
       p_component_reason             => p_component_reason,
       p_change_amount_n              => p_change_amount_n,
       p_change_percentage            => p_change_percentage,
       p_comments                     => p_comments,
       p_attribute_category           => p_attribute_category,
       p_attribute1                   => p_attribute1,
       p_attribute2                   => p_attribute2,
       p_attribute3                   => p_attribute3,
       p_attribute4                   => p_attribute4,
       p_attribute5                   => p_attribute5,
       p_attribute6                   => p_attribute6,
       p_attribute7                   => p_attribute7,
       p_attribute8                   => p_attribute8,
       p_attribute9                   => p_attribute9,
       p_attribute10                  => p_attribute10,
       p_attribute11                  => p_attribute11,
       p_attribute12                  => p_attribute12,
       p_attribute13                  => p_attribute13,
       p_attribute14                  => p_attribute14,
       p_attribute15                  => p_attribute15,
       p_attribute16                  => p_attribute16,
       p_attribute17                  => p_attribute17,
       p_attribute18                  => p_attribute18,
       p_attribute19                  => p_attribute19,
       p_attribute20                  => p_attribute20,
       p_validation_strength          => p_validation_strength,
       p_object_version_number        => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'INSERT_PROPOSAL_COMPONENTS'
        ,p_hook_type   => 'AP'
       	);
  --
  -- End of the after hook for insert_proposal_components
  --
  end;
  --
-- If we are validating then raise the Validate_Enabled exception
--
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  -- Set OUT parameters
  --
  p_component_id                 := l_component_id;
  p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location('Leaving: '||l_proc,10);
--
  Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO insert_proposal_components;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  p_component_id                 := null;
  p_object_version_number        := null;
  --
  When others then
  --
  -- A validation or unexpected error has occured
  --
    ROLLBACK TO insert_proposal_components;
    -- Set OUT parameters.
    p_component_id                 := null;
    p_object_version_number        := null;
    raise;
--
  end insert_proposal_component;
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_proposal_component >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_proposal_component(
  p_component_id                 in number,
  p_approved                     in varchar2,
  p_component_reason             in varchar2,
  p_change_amount_n              in number,
  p_change_percentage            in number,
  p_comments                     in varchar2,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_validation_strength          in varchar2,
  p_object_version_number        in out nocopy number,
  p_validate                     in boolean
  ) is
--
  l_proc    varchar2(72) := g_package||'update_proposal_component';
  l_object_version_number   per_pay_proposal_components.object_version_number%TYPE;
  l_temp_ovn   number := p_object_version_number;
--
  begin
    hr_utility.set_location('Entering:'||l_proc,10);
--
--
-- Issue a savepoint
--
  savepoint update_proposal_components;
--
-- Process Logic
--
  l_object_version_number        := p_object_version_number;
--
  -- Call Before Process User Hook for update_proposal_components
  --
  begin
    hr_maintain_proposal_bk6.update_proposal_component_b
      (
       p_component_id                 => p_component_id,
       p_approved                     => p_approved,
       p_component_reason             => p_component_reason,
       p_change_amount_n              => p_change_amount_n,
       p_change_percentage            => p_change_percentage,
       p_comments                     => p_comments,
       p_attribute_category           => p_attribute_category,
       p_attribute1                   => p_attribute1,
       p_attribute2                   => p_attribute2,
       p_attribute3                   => p_attribute3,
       p_attribute4                   => p_attribute4,
       p_attribute5                   => p_attribute5,
       p_attribute6                   => p_attribute6,
       p_attribute7                   => p_attribute7,
       p_attribute8                   => p_attribute8,
       p_attribute9                   => p_attribute9,
       p_attribute10                  => p_attribute10,
       p_attribute11                  => p_attribute11,
       p_attribute12                  => p_attribute12,
       p_attribute13                  => p_attribute13,
       p_attribute14                  => p_attribute14,
       p_attribute15                  => p_attribute15,
       p_attribute16                  => p_attribute16,
       p_attribute17                  => p_attribute17,
       p_attribute18                  => p_attribute18,
       p_attribute19                  => p_attribute19,
       p_attribute20                  => p_attribute20,
       p_validation_strength          => p_validation_strength,
       p_object_version_number        => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PROPOSAL_COMPONENTS'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of the after hook for update_proposal_components
  --
  end;
  --
--
    per_ppc_upd.upd (
      p_component_id           => p_component_id
     ,p_approved               => p_approved
     ,p_component_reason       => p_component_reason
     ,p_change_amount_n        => p_change_amount_n
     ,p_change_percentage      => p_change_percentage
     ,p_comments               => p_comments
     ,p_attribute_category     => p_attribute_category
     ,p_attribute1             => p_attribute1
     ,p_attribute2             => p_attribute2
     ,p_attribute3             => p_attribute3
     ,p_attribute4             => p_attribute4
     ,p_attribute5             => p_attribute5
     ,p_attribute6             => p_attribute6
     ,p_attribute7             => p_attribute7
     ,p_attribute8             => p_attribute8
     ,p_attribute9             => p_attribute9
     ,p_attribute10            => p_attribute10
     ,p_attribute11            => p_attribute11
     ,p_attribute12            => p_attribute12
     ,p_attribute13            => p_attribute13
     ,p_attribute14            => p_attribute14
     ,p_attribute15            => p_attribute15
     ,p_attribute16            => p_attribute16
     ,p_attribute17            => p_attribute17
     ,p_attribute18            => p_attribute18
     ,p_attribute19            => p_attribute19
     ,p_attribute20            => p_attribute20
     ,p_object_version_number  => l_object_version_number
     ,p_validation_strength    => p_validation_strength
     ,p_validate               => FALSE);
--
--
  -- Call After Process User Hook for update_proposal_components
  --
  begin
    hr_maintain_proposal_bk6.update_proposal_component_a
      (
       p_component_id                 => p_component_id,
       p_approved                     => p_approved,
       p_component_reason             => p_component_reason,
       p_change_amount_n              => p_change_amount_n,
       p_change_percentage            => p_change_percentage,
       p_comments                     => p_comments,
       p_attribute_category           => p_attribute_category,
       p_attribute1                   => p_attribute1,
       p_attribute2                   => p_attribute2,
       p_attribute3                   => p_attribute3,
       p_attribute4                   => p_attribute4,
       p_attribute5                   => p_attribute5,
       p_attribute6                   => p_attribute6,
       p_attribute7                   => p_attribute7,
       p_attribute8                   => p_attribute8,
       p_attribute9                   => p_attribute9,
       p_attribute10                  => p_attribute10,
       p_attribute11                  => p_attribute11,
       p_attribute12                  => p_attribute12,
       p_attribute13                  => p_attribute13,
       p_attribute14                  => p_attribute14,
       p_attribute15                  => p_attribute15,
       p_attribute16                  => p_attribute16,
       p_attribute17                  => p_attribute17,
       p_attribute18                  => p_attribute18,
       p_attribute19                  => p_attribute19,
       p_attribute20                  => p_attribute20,
       p_validation_strength          => p_validation_strength,
       p_object_version_number        => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PROPOSAL_COMPONENTS'
        ,p_hook_type   => 'AP'
        );
  --
  -- End of the after hook for update_proposal_components
  --
  end;
  --
-- If we are validating then raise the Validate_Enabled exception
--
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  -- Set OUT parameters
  --
  p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
--
  Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_proposal_components;
    p_object_version_number        := l_temp_ovn;

  When others then
  --
  -- A validation or unexpected error has occured
  --
    ROLLBACK TO update_proposal_components;
    p_object_version_number        := l_temp_ovn;
  hr_utility.set_location(' Leaving:'||l_proc, 25);
    raise;
--
  end update_proposal_component;
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_proposal_component >------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_proposal_component(
  p_component_id                       in number,
  p_validation_strength                in varchar2,
  p_object_version_number              in number,
  p_validate                           in boolean) is
--
  l_proc    varchar2(72) := g_package||'delete_proposal_component';
--
  begin
    hr_utility.set_location('Entering:'||l_proc,5);
--
--
-- Issue a savepoint
--
  savepoint delete_proposal_components;
--
--
  -- Call Before Process User Hook for delete_proposal_components
  --
  begin
    hr_maintain_proposal_bk7.delete_proposal_component_b
      (
       p_component_id                       => p_component_id,
       p_validation_strength                => p_validation_strength,
       p_object_version_number              => p_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PROPOSAL_COMPONENTS'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of the after hook for delete_proposal_components
  --
  end;
  --
--
    per_ppc_del.del
      (p_component_id              => p_component_id
      ,p_object_version_number     => p_object_version_number
      ,p_validation_strength       => p_validation_strength
      ,p_validate                  => FALSE);
--
--
  -- Call After Process User Hook for approve_salary_proposal
  --
  begin
    hr_maintain_proposal_bk7.delete_proposal_component_a
      (
       p_component_id                       => p_component_id,
       p_validation_strength                => p_validation_strength,
       p_object_version_number              => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PROPOSAL_COMPONENTS'
        ,p_hook_type   => 'AP'
        );
  --
  -- End of the after hook for delete_proposal_components
  --
  end;
  --
-- If we are validating then raise the Validate_Enabled exception
--
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location('Leaving: '||l_proc,10);
--
  Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_proposal_components;
  When others then
  --
  -- A validation or unexpected error has occured
  --
    ROLLBACK TO delete_proposal_components;
    raise;
--
  end delete_proposal_component;
--
-- ----------------------------------------------------------------------------
-- |---------------------< cre_or_upd_salary_proposal >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure cre_or_upd_salary_proposal(
  p_validate                     in boolean,
  p_pay_proposal_id              in out nocopy number,
  p_object_version_number        in out nocopy number,
  p_business_group_id            in number,
  p_assignment_id                in number,
  p_change_date                  in date,
  p_comments                     in varchar2,
  p_next_sal_review_date         in date,
  p_proposal_reason              in varchar2,
  p_proposed_salary_n            in number,
  p_forced_ranking               in number,
  p_date_to		         in date,
  p_performance_review_id        in number,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_multiple_components          in varchar2,
  p_approved                     in varchar2,
  p_inv_next_sal_date_warning    out nocopy boolean,
  p_proposed_salary_warning	 out nocopy boolean,
  p_approved_warning	         out nocopy boolean,
  p_payroll_warning	         out nocopy boolean
) as
  l_proc    varchar2(72) := g_package||'cre_or_upd_salary_proposal';
  l_api_updating boolean;
  l_pyp_rec per_pyp_shd.g_rec_type;
  l_null_pyp_rec per_pyp_shd.g_rec_type;
  l_inv_next_sal_date_warning    boolean;
  l_proposed_salary_warning	 boolean;
  l_approved_warning	         boolean;
  l_payroll_warning	         boolean;
  l_element_entry_id             number;
  l_dummy                        number;
  l_pay_proposal_id              number;
  l_object_version_number	 number;
  l_date_to 			 date := p_date_to;
  l_autoApprove               varchar2(1); --added by vkodedal 10-Apr-2008 ER auto Approve first proposal
  l_temp_ovn   number := p_object_version_number;
  l_temp_pay_proposal_id number := p_pay_proposal_id;
  --
  cursor first_proposal is
  select 1 from per_pay_proposals
  where assignment_id=p_assignment_id;
  --
  cursor asg_type is
  select asg.assignment_type
  from per_all_assignments_f asg
  where asg.assignment_id=p_assignment_id
  and p_change_date between asg.effective_start_date
      and asg.effective_end_date;
  --
  l_asg_type per_all_assignments_f.assignment_type%type;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint cre_or_upd_salary_proposal;
  --

  -- Remember IN OUT parameters.

  l_pay_proposal_id        :=  p_pay_proposal_id;
  l_object_version_number  :=  p_object_version_number;

  l_api_updating := per_pyp_shd.api_updating
       (p_pay_proposal_id        => p_pay_proposal_id
       ,p_object_version_number  => p_object_version_number);
  hr_utility.set_location(l_proc, 20);

  if (l_api_updating and l_date_to = hr_api.g_date) then
    l_date_to := hr_general.end_of_time;
  end if;

  --
  -- set the record
  --
  l_pyp_rec :=
  per_pyp_shd.convert_args
  (p_pay_proposal_id
  ,p_assignment_id
  ,p_business_group_id
  ,p_change_date
  ,p_comments
  ,null
  ,p_next_sal_review_date
  ,p_proposal_reason
  ,p_proposed_salary_n
  ,p_forced_ranking
  ,l_date_to
  ,p_performance_review_id
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_object_version_number
  ,p_multiple_components
  ,p_approved
  );
  if not l_api_updating then
    --
    -- set g_old_rec to null
    --
    per_pyp_shd.g_old_rec:=l_null_pyp_rec;
    hr_utility.set_location(l_proc, 30);
    --
    -- convert the null values
    --
    hr_utility.set_location(l_proc, 40);
    per_pyp_upd.convert_defs(l_pyp_rec);
    --
    hr_utility.set_location(l_proc, 45);
    --
    open first_proposal;
    fetch first_proposal into l_dummy;
    if first_proposal%notfound then
      close first_proposal;
      l_pyp_rec.multiple_components:='N';
      open asg_type;
      fetch asg_type into l_asg_type;
      close asg_type;
      if l_asg_type='E' then
  --vkodedal 10-Apr-2008 ER to satisfy satutory requirement
--Retain auto approve first proposal functionality if profile is null or set to Yes

        l_autoApprove:=fnd_profile.value('HR_AUTO_APPROVE_FIRST_PROPOSAL');
         if(l_autoApprove is null or l_autoApprove ='Y') then
          hr_utility.set_location(l_proc, 47);
	        l_pyp_rec.approved:='Y';
         end if;

      else
        l_pyp_rec.approved:='N';
      end if;
    else
      close first_proposal;
    end if;
    -- insert the data
    --
    hr_utility.set_location(l_proc, 50);
    hr_maintain_proposal_api.insert_salary_proposal
    (p_pay_proposal_id           => l_pyp_rec.pay_proposal_id
    ,p_assignment_id             => l_pyp_rec.assignment_id
    ,p_business_group_id         => l_pyp_rec.business_group_id
    ,p_change_date               => l_pyp_rec.change_date
    ,p_comments                  => l_pyp_rec.comments
    ,p_next_sal_review_date      => l_pyp_rec.next_sal_review_date
    ,p_proposal_reason           => l_pyp_rec.proposal_reason
    ,p_proposed_salary_n         => l_pyp_rec.proposed_salary_n
    ,p_forced_ranking            => l_pyp_rec.forced_ranking
    ,p_date_to			 => l_pyp_rec.date_to
    ,p_performance_review_id     => l_pyp_rec.performance_review_id
    ,p_attribute_category        => l_pyp_rec.attribute_category
    ,p_attribute1                => l_pyp_rec.attribute1
    ,p_attribute2                => l_pyp_rec.attribute2
    ,p_attribute3                => l_pyp_rec.attribute3
    ,p_attribute4                => l_pyp_rec.attribute4
    ,p_attribute5                => l_pyp_rec.attribute5
    ,p_attribute6                => l_pyp_rec.attribute6
    ,p_attribute7                => l_pyp_rec.attribute7
    ,p_attribute8                => l_pyp_rec.attribute8
    ,p_attribute9                => l_pyp_rec.attribute9
    ,p_attribute10               => l_pyp_rec.attribute10
    ,p_attribute11               => l_pyp_rec.attribute11
    ,p_attribute12               => l_pyp_rec.attribute12
    ,p_attribute13               => l_pyp_rec.attribute13
    ,p_attribute14               => l_pyp_rec.attribute14
    ,p_attribute15               => l_pyp_rec.attribute15
    ,p_attribute16               => l_pyp_rec.attribute16
    ,p_attribute17               => l_pyp_rec.attribute17
    ,p_attribute18               => l_pyp_rec.attribute18
    ,p_attribute19               => l_pyp_rec.attribute19
    ,p_attribute20               => l_pyp_rec.attribute20
    ,p_object_version_number     => l_pyp_rec.object_version_number
    ,p_multiple_components       => nvl(l_pyp_rec.multiple_components,'N')
    ,p_approved                  => nvl(l_pyp_rec.approved,'N')
    ,p_validate                  => FALSE
    ,p_element_entry_id          => l_element_entry_id
    ,p_inv_next_sal_date_warning => l_inv_next_sal_date_warning
    ,p_proposed_salary_warning   => l_proposed_salary_warning
    ,p_approved_warning          => l_approved_warning
    ,p_payroll_warning           => l_payroll_warning
    );
    hr_utility.set_location(l_proc, 60);
  else
  --
  -- updating not inserting
  --
    hr_utility.set_location(l_proc, 70);
    per_pyp_shd.lck
      (p_pay_proposal_id           => p_pay_proposal_id
      ,p_object_version_number     => p_object_version_number);
    --
    -- convert the null values
    --
    hr_utility.set_location(l_proc, 80);
    per_pyp_upd.convert_defs(l_pyp_rec);
    --
    -- update the data
    --
    hr_utility.set_location(l_proc, 90);
    --
    hr_maintain_proposal_api.update_salary_proposal
    (p_pay_proposal_id           => l_pyp_rec.pay_proposal_id
    ,p_change_date               => l_pyp_rec.change_date
    ,p_comments                  => l_pyp_rec.comments
    ,p_next_sal_review_date      => l_pyp_rec.next_sal_review_date
    ,p_proposal_reason           => l_pyp_rec.proposal_reason
    ,p_proposed_salary_n         => l_pyp_rec.proposed_salary_n
    ,p_forced_ranking            => l_pyp_rec.forced_ranking
    ,p_date_to                   => l_pyp_rec.date_to
    ,p_performance_review_id     => l_pyp_rec.performance_review_id
    ,p_attribute_category        => l_pyp_rec.attribute_category
    ,p_attribute1                => l_pyp_rec.attribute1
    ,p_attribute2                => l_pyp_rec.attribute2
    ,p_attribute3                => l_pyp_rec.attribute3
    ,p_attribute4                => l_pyp_rec.attribute4
    ,p_attribute5                => l_pyp_rec.attribute5
    ,p_attribute6                => l_pyp_rec.attribute6
    ,p_attribute7                => l_pyp_rec.attribute7
    ,p_attribute8                => l_pyp_rec.attribute8
    ,p_attribute9                => l_pyp_rec.attribute9
    ,p_attribute10               => l_pyp_rec.attribute10
    ,p_attribute11               => l_pyp_rec.attribute11
    ,p_attribute12               => l_pyp_rec.attribute12
    ,p_attribute13               => l_pyp_rec.attribute13
    ,p_attribute14               => l_pyp_rec.attribute14
    ,p_attribute15               => l_pyp_rec.attribute15
    ,p_attribute16               => l_pyp_rec.attribute16
    ,p_attribute17               => l_pyp_rec.attribute17
    ,p_attribute18               => l_pyp_rec.attribute18
    ,p_attribute19               => l_pyp_rec.attribute19
    ,p_attribute20               => l_pyp_rec.attribute20
    ,p_object_version_number     => l_pyp_rec.object_version_number
    ,p_multiple_components       => l_pyp_rec.multiple_components
    ,p_approved                  => l_pyp_rec.approved
    ,p_validate                  => FALSE
    ,p_inv_next_sal_date_warning => l_inv_next_sal_date_warning
    ,p_proposed_salary_warning   => l_proposed_salary_warning
    ,p_approved_warning          => l_approved_warning
    ,p_payroll_warning           => l_payroll_warning
    );
    --
    hr_utility.set_location(l_proc, 100);
    --
  end if;
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(l_proc, 110);
  --
  p_pay_proposal_id           := l_pyp_rec.pay_proposal_id;
  p_object_version_number     := l_pyp_rec.object_version_number;
  p_inv_next_sal_date_warning := l_inv_next_sal_date_warning;
  p_proposed_salary_warning   := l_proposed_salary_warning;
  p_approved_warning          := l_approved_warning;
  p_payroll_warning           := l_payroll_warning;
  --
  hr_utility.set_location('Leaving:'||l_proc, 120);
  --
exception
  when hr_api.validate_enabled then
    rollback to cre_or_upd_salary_proposal;
    p_pay_proposal_id           := null;
    p_object_version_number     := null;
    p_inv_next_sal_date_warning := l_inv_next_sal_date_warning;
    p_proposed_salary_warning   := l_proposed_salary_warning;
    p_approved_warning          := l_approved_warning;
    p_payroll_warning           := l_payroll_warning;
    hr_utility.set_location('Leaving:'||l_proc, 130);
  when others then
    rollback to cre_or_upd_salary_proposal;
    -- Reset IN OUT and OUT parameters.
    p_pay_proposal_id        :=  l_temp_pay_proposal_id;
    p_object_version_number  :=  l_temp_ovn;
    p_inv_next_sal_date_warning := null;
    p_proposed_salary_warning   := null;
    p_approved_warning          := null;
    p_payroll_warning           := null;
    hr_utility.set_location('Leaving:'||l_proc, 140);
    raise;
  --
end cre_or_upd_salary_proposal;
--
-- ----------------------------------------------------------------------------
-- |---------------------< cre_or_upd_salary_proposal >-----------------------|
--  ---------------------------------------------------------------------------
--  ------------------    Without the new date_to parameter  ------------------
-- ----------------------------------------------------------------------------
--
procedure cre_or_upd_salary_proposal(
  p_validate                     in boolean,
  p_pay_proposal_id              in out nocopy number,
  p_object_version_number        in out nocopy number,
  p_business_group_id            in number,
  p_assignment_id                in number,
  p_change_date                  in date,
  p_comments                     in varchar2,
  p_next_sal_review_date         in date,
  p_proposal_reason              in varchar2,
  p_proposed_salary_n            in number,
  p_forced_ranking               in number,
  p_performance_review_id        in number,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_multiple_components          in varchar2,
  p_approved                     in varchar2,
  p_inv_next_sal_date_warning    out nocopy boolean,
  p_proposed_salary_warning	 out nocopy boolean,
  p_approved_warning	         out nocopy boolean,
  p_payroll_warning	         out nocopy boolean
) as



 Cursor csr_date_to
  IS
  select date_to
  from per_pay_proposals
  where pay_proposal_id = p_pay_proposal_id;

  l_date_to PER_PAY_PROPOSALS.date_to%TYPE default null;

begin

  if p_pay_proposal_id is not null  then

    OPEN csr_date_to;
    FETCH csr_date_to into l_date_to;
    CLOSE csr_date_to;

    end if;

  hr_maintain_proposal_api.cre_or_upd_salary_proposal
    (p_validate                     => p_validate
    ,p_pay_proposal_id              => p_pay_proposal_id
    ,p_object_version_number        => p_object_version_number
    ,p_business_group_id            => p_business_group_id
    ,p_assignment_id                => p_assignment_id
    ,p_change_date                  => p_change_date
    ,p_comments                     => p_comments
    ,p_next_sal_review_date         => p_next_sal_review_date
    ,p_proposal_reason              => p_proposal_reason
    ,p_proposed_salary_n            => p_proposed_salary_n
    ,p_forced_ranking               => p_forced_ranking
    ,p_date_to			    => null
    ,p_performance_review_id        => p_performance_review_id
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
    ,p_multiple_components          => p_multiple_components
    ,p_approved                     => p_approved
    ,p_inv_next_sal_date_warning    => p_inv_next_sal_date_warning
    ,p_proposed_salary_warning      => p_proposed_salary_warning
    ,p_approved_warning             => p_approved_warning
    ,p_payroll_warning              => p_payroll_warning
    );
  --
end cre_or_upd_salary_proposal;
--
--
-------------------------------------------------------------------------------
-- |----------------------< delete_salary_history >---------------------------|
-- ----------------------------------------------------------------------------
--
/* Procedure to delete salary proposals and components
   of an assignment before a given date.

  Parameters:
   p_assignment_id      Assignment Id
   p_date               Date
*/
Procedure delete_salary_history( p_assignment_id      in number
                                ,p_date               in date) is
--
  l_salary_warning       boolean;
  l_proc    varchar2(72) := g_package||'delete_salary_history';
  l_change_date date;
--
  cursor c_del_salary_proposals( p_assignment_id      in number
                                ,p_date     in date) is
  select pay_proposal_id, business_group_id, object_version_number
  from per_pay_proposals
  where assignment_id = p_assignment_id
  and change_date <
        (select max(change_date)
         from per_pay_proposals
         where assignment_id = p_assignment_id
         and change_date <= p_date
        );
--
  cursor components(p_pay_proposal_id number, p_business_group_id number) is
  select ppc.component_id
  ,      ppc.object_version_number
  from   per_pay_proposal_components ppc
  where  ppc.pay_proposal_id=p_pay_proposal_id
  and    ppc.business_group_id=p_business_group_id;
--
  begin
    hr_utility.set_location('Entering:'||l_proc,5);
    --
    --
    -- Issue a savepoint
    --
    savepoint delete_salary_history;
    --
    --
    FOR r_del_sp in c_del_salary_proposals( p_assignment_id ,p_date)
    LOOP
      hr_utility.set_location('Inside loop salary_proposal - '||
                             r_del_sp.pay_proposal_id||l_proc,10);
      --
      -- first of all delete all of the components
      --
      FOR l_components IN components(r_del_sp.pay_proposal_id,
                                   r_del_sp.business_group_id)
      LOOP
        hr_utility.set_location('Inside loop component - '||
                             l_components.component_id||l_proc,15);
        per_ppc_del.del(p_component_id=>l_components.component_id
                   ,p_object_version_number=>l_components.object_version_number
                   ,p_validation_strength=>'WEAK'
                   ,p_validate=>FALSE);
      END LOOP;
      hr_utility.set_location(l_proc,20);
      --
      -- Update CWB table that created/updated the salary proposal
      --
      update BEN_CWB_PERSON_RATES
      set PAY_PROPOSAL_ID = null
      where PAY_PROPOSAL_ID = r_del_sp.pay_proposal_id;
      --
      -- Delete Salary Proposal
      --
      delete per_pay_proposals
      where pay_proposal_id = r_del_sp.pay_proposal_id;
      --
      hr_utility.set_location(l_proc,25);
      --
    END LOOP;
    hr_utility.set_location('Exiting:'||l_proc,50);
  EXCEPTION
  When others then
  --
  -- A validation or unexpected error has occured
  --
    hr_utility.set_location('When Others:'||l_proc,55);
    ROLLBACK TO delete_salary_proposal;
    raise;
  --
  --
  end;
--
end hr_maintain_proposal_api;


/
