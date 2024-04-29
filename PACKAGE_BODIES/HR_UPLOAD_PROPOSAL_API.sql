--------------------------------------------------------
--  DDL for Package Body HR_UPLOAD_PROPOSAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_UPLOAD_PROPOSAL_API" as
/* $Header: hrpypapi.pkb 120.30.12010000.13 2009/01/16 09:51:09 schowdhu ship $ */
--
-- Package Variables
--
g_package  	varchar2(33) := 'hr_upload_proposal_api.';
MAX_COMP_NO 	number(10) := 10;
--
-- define plsql table types
--
TYPE t_of_number2  is table of
per_pay_proposal_components.change_percentage%TYPE
index by binary_integer;
--
TYPE t_of_number  is table of
per_pay_proposal_components.component_id%TYPE
index by binary_integer;
--
TYPE t_of_char is table of
per_pay_proposal_components.component_reason%TYPE
index by binary_integer;

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

	        update per_pay_proposals
		      set last_change_date = l_last_change_date
		      where rowid=l_row_id;
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
-----------------------------------------------------------------------------
-- | ---------------------------< end_date_proposed_proposal>-----------------
-----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to end date the proposed proposals
--   which exists prior to the p_date_to. It is called for
--   proposed proposals only.
--
-- Procedure added to enddate proposed proposals only. Bug#7386307  by schowdhu

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
-----------------------------------------------------------------------------
-- | ---------------------------< end_date_approved_proposal>-----------------
-----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to end date the approved proposals
--   which exists prior to the p_date_to. It is called for
--   approved proposals only. All the proposed proposals
--   prior to the p_date_to will be deleted.
--
-- Procedure added to enddate approved proposals only. Bug#7386307  by schowdhu

-- changed by schowdhu for 7673294 05-jan-08
Procedure end_date_approved_proposal(p_assignment_id  in     number
                                    ,p_date_to        in     date
                                    ,p_pay_proposal_id in number default null) is

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
and pay_proposal_id <> p_pay_proposal_id
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
-----------------------------------------------------------------------------
-- | ---------------------------< end_date_salary_proposal>-----------------
-----------------------------------------------------------------------------
--
/* Procedure modified. Bug#7386307  by schowdhu  */

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

-----------------------------------------------------------------------------
-- | ---------------------------< create_sql_table>--------------------------
-----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to initialise 5 sql_tables.
--   the plsql_tables are the out parameters.
--
--
procedure create_sql_table
  (p_component_reason_1		   in	varchar2 default null
  ,p_change_amount_1		   in   number   default null
  ,p_change_percentage_1	   in   number   default null
  ,p_component_id_1		   in   number   default null
  ,p_approved_1			   in   varchar2
  ,p_object_version_number_1	   in	number   default null
  --
  ,p_component_reason_2            in   varchar2 default null
  ,p_change_amount_2		   in   number   default null
  ,p_change_percentage_2	   in   number   default null
  ,p_component_id_2		   in   number   default null
  ,p_approved_2			   in   varchar2
  ,p_object_version_number_2	   in	number   default null
  --
  ,p_component_reason_3            in   varchar2 default null
  ,p_change_amount_3		   in   number   default null
  ,p_change_percentage_3	   in   number   default null
  ,p_component_id_3		   in   number   default null
  ,p_approved_3			   in   varchar2
  ,p_object_version_number_3	   in	number   default null
  --
  ,p_component_reason_4            in   varchar2 default null
  ,p_change_amount_4		   in   number   default null
  ,p_change_percentage_4	   in   number   default null
  ,p_component_id_4		   in   number   default null
  ,p_approved_4			   in   varchar2
  ,p_object_version_number_4	   in	number   default null
  --
  ,p_component_reason_5            in   varchar2 default null
  ,p_change_amount_5		   in   number   default null
  ,p_change_percentage_5	   in   number   default null
  ,p_component_id_5		   in   number   default null
  ,p_approved_5			   in   varchar2
  ,p_object_version_number_5	   in	number   default null
  --
  ,p_component_reason_6            in   varchar2 default null
  ,p_change_amount_6		   in   number   default null
  ,p_change_percentage_6	   in   number   default null
  ,p_component_id_6		   in   number   default null
  ,p_approved_6			   in   varchar2
  ,p_object_version_number_6	   in	number   default null
  --
  ,p_component_reason_7            in   varchar2 default null
  ,p_change_amount_7		   in   number   default null
  ,p_change_percentage_7	   in   number   default null
  ,p_component_id_7		   in   number   default null
  ,p_approved_7			   in   varchar2
  ,p_object_version_number_7	   in	number   default null
  --
  ,p_component_reason_8            in   varchar2 default null
  ,p_change_amount_8		   in   number   default null
  ,p_change_percentage_8	   in   number   default null
  ,p_component_id_8		   in   number   default null
  ,p_approved_8			   in   varchar2
  ,p_object_version_number_8	   in	number   default null
  --
  ,p_component_reason_9            in   varchar2 default null
  ,p_change_amount_9		   in   number   default null
  ,p_change_percentage_9	   in   number   default null
  ,p_component_id_9		   in   number   default null
  ,p_approved_9			   in   varchar2
  ,p_object_version_number_9	   in	number   default null
  --
  ,p_component_reason_10           in   varchar2 default null
  ,p_change_amount_10		   in   number   default null
  ,p_change_percentage_10	   in   number   default null
  ,p_component_id_10		   in   number   default null
  ,p_approved_10		   in   varchar2
  ,p_object_version_number_10	   in	number   default null
  ,p_comp_reason_table		   out nocopy  t_of_char
  ,p_change_amount_table	   out nocopy  t_of_number2
  ,p_change_percentage_table	   out nocopy  t_of_number2
  ,p_comp_id_table		   out nocopy  t_of_number
  ,p_approved_table		   out nocopy  t_of_char
  ,p_ovn_table			   out nocopy  t_of_number
  ) is
  --
  --
  begin
  --
  p_comp_reason_table(1)   := p_component_reason_1;
  p_comp_reason_table(2)   := p_component_reason_2;
  p_comp_reason_table(3)   := p_component_reason_3;
  p_comp_reason_table(4)   := p_component_reason_4;
  p_comp_reason_table(5)   := p_component_reason_5;
  p_comp_reason_table(6)   := p_component_reason_6;
  p_comp_reason_table(7)   := p_component_reason_7;
  p_comp_reason_table(8)   := p_component_reason_8;
  p_comp_reason_table(9)   := p_component_reason_9;
  p_comp_reason_table(10)  := p_component_reason_10;
  --
  p_change_amount_table(1) := p_change_amount_1;
  p_change_amount_table(2) := p_change_amount_2;
  p_change_amount_table(3) := p_change_amount_3;
  p_change_amount_table(4) := p_change_amount_4;
  p_change_amount_table(5) := p_change_amount_5;
  p_change_amount_table(6) := p_change_amount_6;
  p_change_amount_table(7) := p_change_amount_7;
  p_change_amount_table(8) := p_change_amount_8;
  p_change_amount_table(9) := p_change_amount_9;
  p_change_amount_table(10):= p_change_amount_10;
  --
  p_change_percentage_table(1) := p_change_percentage_1;
  p_change_percentage_table(2) := p_change_percentage_2;
  p_change_percentage_table(3) := p_change_percentage_3;
  p_change_percentage_table(4) := p_change_percentage_4;
  p_change_percentage_table(5) := p_change_percentage_5;
  p_change_percentage_table(6) := p_change_percentage_6;
  p_change_percentage_table(7) := p_change_percentage_7;
  p_change_percentage_table(8) := p_change_percentage_8;
  p_change_percentage_table(9) := p_change_percentage_9;
  p_change_percentage_table(10):= p_change_percentage_10;
  --
  p_ovn_table(1)	       := p_object_version_number_1;
  p_ovn_table(2)	       := p_object_version_number_2;
  p_ovn_table(3)	       := p_object_version_number_3;
  p_ovn_table(4)	       := p_object_version_number_4;
  p_ovn_table(5)	       := p_object_version_number_5;
  p_ovn_table(6)	       := p_object_version_number_6;
  p_ovn_table(7)	       := p_object_version_number_7;
  p_ovn_table(8)	       := p_object_version_number_8;
  p_ovn_table(9)	       := p_object_version_number_9;
  p_ovn_table(10)	       := p_object_version_number_10;
  --
  p_approved_table(1)	       := p_approved_1;
  p_approved_table(2)	       := p_approved_2;
  p_approved_table(3)	       := p_approved_3;
  p_approved_table(4)	       := p_approved_4;
  p_approved_table(5)	       := p_approved_5;
  p_approved_table(6)	       := p_approved_6;
  p_approved_table(7)	       := p_approved_7;
  p_approved_table(8)	       := p_approved_8;
  p_approved_table(9)	       := p_approved_9;
  p_approved_table(10)	       := p_approved_10;
  --
  p_comp_id_table(1)	       := p_component_id_1;
  p_comp_id_table(2)	       := p_component_id_2;
  p_comp_id_table(3)	       := p_component_id_3;
  p_comp_id_table(4)	       := p_component_id_4;
  p_comp_id_table(5)	       := p_component_id_5;
  p_comp_id_table(6)	       := p_component_id_6;
  p_comp_id_table(7)	       := p_component_id_7;
  p_comp_id_table(8)	       := p_component_id_8;
  p_comp_id_table(9)	       := p_component_id_9;
  p_comp_id_table(10)	       := p_component_id_10;
  --
  end create_sql_table;
  --
  -------------------------------------------------------------------------
  --| -----------------------< get_value >---------------------------------
  ------------------------------------------------------------------------
  --
  -- Description:
  --   this function takes a plsql_table and an integer as it argument
  --   and it returns a number format NUMBER(9,2)
  --   This function is used when the local parameter need to be initilased
  --   with procedure parameter.
  --
  --
  function get_value(p_table t_of_number2  ,i number) return number is
  begin
     return p_table(i);
  end get_value;
--
--
  -------------------------------------------------------------------------
  --| -----------------------< get_value >---------------------------------
  ------------------------------------------------------------------------
  --
  -- Description:
  --   this function takes a plsql_table and an integer as it argument
  --   and it returns a number.
  --   This function is used when the local parameter need to be initilased
  --   with procedure parameter.
  --
  --
  function get_value(p_table t_of_number  ,i number) return number is
  begin
     return p_table(i);
  end get_value;
--
--
  -------------------------------------------------------------------------
  --| -----------------------< get_value >---------------------------------
  ------------------------------------------------------------------------
  --
  -- Description:
  --   this function takes a plsql_table and an integer as it argument
  --   and it returns a varchar2.
  --   This function is used when the local parameter need to be initilased
  --   with procedure parameter.
  --
  --
  function get_value(p_table t_of_char  ,i number) return varchar2 is
  begin
     return p_table(i);
  end get_value;
--
----------------------------------------------------------------------------
--|-------------------------< is_component_exist >---------------------------
---------------------------------------------------------------------------
  -- Description
  -- This function loops through all the components and check if they
  -- are not null. This function returns true if one or more components
  -- are not null otherwise it returns false.
  --
  function is_component_exist
	     (
	      p_change_amount_table	t_of_number2
	     ,p_change_percentage_table t_of_number2
	     ) return boolean is
  --
  l_out		boolean := false;
  begin
    --
    for i in 1 .. MAX_COMP_NO
    LOOP
      if (
	  p_change_amount_table(i) IS NOT NULL OR
	  p_change_percentage_table(i) IS NOT NULL) then
	  l_out :=  true;
      end if;
    end loop;
    --
    return l_out;
   end is_component_exist;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< upload_salary_proposal >----------------------|
-- ----------------------------------------------------------------------------
--
procedure upload_salary_proposal
  (p_validate                      in     boolean
  ,p_change_date                   in     date
  ,p_business_group_id             in     number
  ,p_assignment_id		   in     number
  ,p_proposed_salary               in     number
  ,p_proposal_reason		   in     varchar2
  ,p_next_sal_review_date          in     date       -- Bug 1620922
  ,p_forced_ranking                in     number
  ,p_date_to			   in     date
  ,p_pay_proposal_id               in out nocopy number
  ,p_object_version_number         in out nocopy number
  --
  ,p_component_reason_1		   in     varchar2
  ,p_change_amount_1		   in     number
  ,p_change_percentage_1	   in     number
  ,p_approved_1			   in 	  varchar2
  ,p_component_id_1		   in out nocopy number
  ,p_ppc_object_version_number_1   in out nocopy number
  --
  ,p_component_reason_2		   in     varchar2
  ,p_change_amount_2		   in     number
  ,p_change_percentage_2	   in     number
  ,p_approved_2			   in 	  varchar2
  ,p_component_id_2		   in out nocopy number
  ,p_ppc_object_version_number_2   in out nocopy number
  --
  ,p_component_reason_3		   in     varchar2
  ,p_change_amount_3		   in     number
  ,p_change_percentage_3	   in     number
  ,p_approved_3			   in 	  varchar2
  ,p_component_id_3		   in out nocopy number
  ,p_ppc_object_version_number_3   in out nocopy number
  --
  ,p_component_reason_4		   in     varchar2
  ,p_change_amount_4		   in     number
  ,p_change_percentage_4	   in     number
  ,p_approved_4			   in 	  varchar2
  ,p_component_id_4		   in out nocopy number
  ,p_ppc_object_version_number_4   in out nocopy number
  --
  ,p_component_reason_5		   in     varchar2
  ,p_change_amount_5		   in     number
  ,p_change_percentage_5	   in     number
  ,p_approved_5			   in 	  varchar2
  ,p_component_id_5		   in out nocopy number
  ,p_ppc_object_version_number_5   in out nocopy number
  --
  ,p_component_reason_6		   in     varchar2
  ,p_change_amount_6		   in     number
  ,p_change_percentage_6	   in     number
  ,p_approved_6			   in 	  varchar2
  ,p_component_id_6		   in out nocopy number
  ,p_ppc_object_version_number_6   in out nocopy number
  --
  ,p_component_reason_7		   in     varchar2
  ,p_change_amount_7		   in     number
  ,p_change_percentage_7	   in     number
  ,p_approved_7			   in 	  varchar2
  ,p_component_id_7		   in out nocopy number
  ,p_ppc_object_version_number_7   in out nocopy number
  --
  ,p_component_reason_8		   in     varchar2
  ,p_change_amount_8		   in     number
  ,p_change_percentage_8	   in     number
  ,p_approved_8			   in 	  varchar2
  ,p_component_id_8		   in out nocopy number
  ,p_ppc_object_version_number_8   in out nocopy number
  --
  ,p_component_reason_9		   in     varchar2
  ,p_change_amount_9		   in     number
  ,p_change_percentage_9	   in     number
  ,p_approved_9			   in 	  varchar2
  ,p_component_id_9		   in out nocopy number
  ,p_ppc_object_version_number_9   in out nocopy number
  --
  ,p_component_reason_10	   in     varchar2
  ,p_change_amount_10		   in     number
  ,p_change_percentage_10	   in     number
  ,p_approved_10		   in 	  varchar2
  ,p_component_id_10		   in out nocopy number
  ,p_ppc_object_version_number_10  in out nocopy number
  --
  ,p_pyp_proposed_sal_warning      out nocopy boolean
  ,p_additional_comp_warning       out nocopy boolean
  --
  /* Added for Desc flex support for Web ADI */
  ,p_attribute_category            in varchar2   default null
  ,p_attribute1                    in varchar2   default null
  ,p_attribute2                    in varchar2   default null
  ,p_attribute3                    in varchar2   default null
  ,p_attribute4                    in varchar2   default null
  ,p_attribute5                    in varchar2   default null
  ,p_attribute6                    in varchar2   default null
  ,p_attribute7                    in varchar2   default null
  ,p_attribute8                    in varchar2   default null
  ,p_attribute9                    in varchar2   default null
  ,p_attribute10                   in varchar2   default null
  ,p_attribute11                   in varchar2   default null
  ,p_attribute12                   in varchar2   default null
  ,p_attribute13                   in varchar2   default null
  ,p_attribute14                   in varchar2   default null
  ,p_attribute15                   in varchar2   default null
  ,p_attribute16                   in varchar2   default null
  ,p_attribute17                   in varchar2   default null
  ,p_attribute18                   in varchar2   default null
  ,p_attribute19                   in varchar2   default null
  ,p_attribute20                   in varchar2   default null
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc    varchar2(72) := g_package||'upload_salary_proposal';
  l_is_component_not_null	boolean;
  l_component_cal 	 	boolean := false;
  l_inv_next_sal_date_warning 	boolean;
  l_inv_next_perf_date_warning 	boolean;
  l_approved_warning		boolean;
  l_payroll_warning		boolean;
  l_proposed_salary_warning     boolean;
  l_last_proposed_salary  per_pay_proposals.proposed_salary_n%TYPE;
  l_pay_proposal_id	  per_pay_proposals.pay_proposal_id%TYPE;
  l_object_version_number per_pay_proposals.object_version_number%TYPE;
  l_pyp_proposed_sal_warning    boolean;
  l_additional_comp_warning 	boolean;
  l_autoApprove               varchar2(1); --added by vkodedal 08-Oct-2007 ER auto Approve first proposal
  l_approved                  VARCHAR2(1);
  --
  --
  l_proposed_salary	per_pay_proposals.proposed_salary_n%TYPE;
  l_proposed_salary_db  per_pay_proposals.proposed_salary_n%TYPE;
  l_change_date		per_pay_proposals.change_date%TYPE;
  l_multiple_components per_pay_proposals.multiple_components%TYPE;
  l_pyp_approved	per_pay_proposals.approved%TYPE;
  l_proposal_reason	per_pay_proposals.proposal_reason%TYPE;
  l_pyp_object_version_number
			per_pay_proposals.object_version_number%TYPE;
  --
  l_change_amount     per_pay_proposal_components.change_amount_n%TYPE;
  l_change_percentage per_pay_proposal_components.change_percentage%TYPE;
  l_component_reason  per_pay_proposal_components.component_reason%TYPE;
  l_ppc_approved      per_pay_proposal_components.approved%TYPE;
  l_ppc_object_version_number
               	      per_pay_proposal_components.object_version_number%TYPE;
  --
  l_change_amount_in     per_pay_proposal_components.change_amount_n%TYPE;
  l_change_percentage_in per_pay_proposal_components.change_percentage%TYPE;
  l_component_reason_in	 per_pay_proposal_components.component_reason%TYPE;
  l_approved_in		 per_pay_proposal_components.approved%TYPE;
  l_object_version_number_in
		 per_pay_proposal_components.object_version_number%TYPE;
  l_component_id_in      per_pay_proposal_components.component_id%TYPE;
  l_component_sum	 number(20,6):=0;
  l_total_component_sum  number (20,6):=0;
  l_comp_update		 boolean := false;
  l_prop_update		 boolean := false;
  --
  l_pyp_pay_pro_id	per_pay_proposals.pay_proposal_id%TYPE:=
			p_pay_proposal_id;
  l_pyp_ovn	        per_pay_proposals.object_version_number%TYPE:=
			p_object_version_number;
  --
  l_component_id_1	per_pay_proposal_components.component_id%TYPE:=
			p_component_id_1;
  l_ppc_ovn_1	per_pay_proposal_components.object_version_number%TYPE:=
			p_ppc_object_version_number_1;
  --
  l_component_id_2	per_pay_proposal_components.component_id%TYPE:=
			p_component_id_2;
  l_ppc_ovn_2	per_pay_proposal_components.object_version_number%TYPE:=
			p_ppc_object_version_number_2;
  --
  l_component_id_3	per_pay_proposal_components.component_id%TYPE:=
			p_component_id_3;
  l_ppc_ovn_3 	per_pay_proposal_components.object_version_number%TYPE:=
			p_ppc_object_version_number_3;
  --
  l_component_id_4	per_pay_proposal_components.component_id%TYPE:=
			p_component_id_4;
  l_ppc_ovn_4	per_pay_proposal_components.object_version_number%TYPE:=
			p_ppc_object_version_number_4;
  --
  l_component_id_5	per_pay_proposal_components.component_id%TYPE:=
			p_component_id_5;
  l_ppc_ovn_5	per_pay_proposal_components.object_version_number%TYPE:=
			p_ppc_object_version_number_5;
  --
  l_component_id_6	per_pay_proposal_components.component_id%TYPE:=
			p_component_id_6;
  l_ppc_ovn_6	per_pay_proposal_components.object_version_number%TYPE:=
			p_ppc_object_version_number_6;
  --
  l_component_id_7 	per_pay_proposal_components.component_id%TYPE:=
			p_component_id_7;
  l_ppc_ovn_7	per_pay_proposal_components.object_version_number%TYPE:=
			p_ppc_object_version_number_7;
  --
  l_component_id_8	per_pay_proposal_components.component_id%TYPE:=
			p_component_id_8;
  l_ppc_ovn_8	per_pay_proposal_components.object_version_number%TYPE:=
			p_ppc_object_version_number_8;
  --
  l_component_id_9	per_pay_proposal_components.component_id%TYPE:=
			p_component_id_9;
  l_ppc_ovn_9	per_pay_proposal_components.object_version_number%TYPE:=
			p_ppc_object_version_number_9;
  --
  l_component_id_10 	per_pay_proposal_components.component_id%TYPE:=
			p_component_id_10;
  l_ppc_ovn_10	per_pay_proposal_components.object_version_number%TYPE:=
			p_ppc_object_version_number_10;


  lt_pay_proposal_id         number     :=    p_pay_proposal_id;
  lt_object_version_number   number	:=    p_object_version_number;
  lt_component_id_1	     number	:=    p_component_id_1;
  lt_ppc_ovn_1 		     number	:=    p_ppc_object_version_number_1;
  lt_component_id_2	     number	:=    p_component_id_2;
  lt_ppc_ovn_2 	 	     number	:=    p_ppc_object_version_number_2;
  lt_component_id_3	     number	:=    p_component_id_3;
  lt_ppc_ovn_3 	             number	:=    p_ppc_object_version_number_3;
  lt_component_id_4	     number	:=    p_component_id_4;
  lt_ppc_ovn_4   	     number	:=    p_ppc_object_version_number_4;
  lt_component_id_5	     number	:=    p_component_id_5;
  lt_ppc_ovn_5 	             number	:=    p_ppc_object_version_number_5;
  lt_component_id_6	     number	:=    p_component_id_6;
  lt_ppc_ovn_6 		     number	:=    p_ppc_object_version_number_6;
  lt_component_id_7	     number	:=    p_component_id_7;
  lt_ppc_ovn_7 	             number	:=    p_ppc_object_version_number_7;
  lt_component_id_8	     number	:=    p_component_id_8;
  lt_ppc_ovn_8 		     number	:=    p_ppc_object_version_number_8;
  lt_component_id_9	     number	:=    p_component_id_9;
  lt_ppc_ovn_9 	             number	:=    p_ppc_object_version_number_9;
  lt_component_id_10	     number	:=    p_component_id_10;
  lt_ppc_ovn_10		     number	:=    p_ppc_object_version_number_10;
  l_date_to        PER_PAY_PROPOSALS.DATE_TO%TYPE;
  l_next_change_date PER_PAY_PROPOSALS.CHANGE_DATE%TYPE;
  --
  -- plsql table types
  --
  l_comp_reason_table		t_of_char;
  l_comp_id_table		t_of_number;
  l_ovn_table			t_of_number;
  l_approved_table		t_of_char;
  l_change_amount_table		t_of_number2;
  l_change_percentage_table	t_of_number2;
  --
  -- elements
  --
  l_next_sal_review_date per_pay_proposals.next_sal_review_date%TYPE;

  l_element_type_id	 pay_element_types_f.element_type_id%TYPE;
  l_input_value_id	 pay_input_values_f.input_value_id%TYPE;
  l_element_link_id	 pay_element_links_f.element_link_id%TYPE;
  l_element_entry_id	 pay_element_entries_f.element_entry_id%TYPE;
  l_trunc_date           date := p_change_date;
  l_effective_end_date   date;
  l_effective_start_date date := l_trunc_date;
  --
  -- Cursor to get the sum of all the components for a salary proposal.
  -- This cursor is used to ensure that all the components are accounted for.
  -- For example, if a user has more than ten components then this
  -- business process processes the first 10 and add any additionals as well.
  --
  cursor csr_sum_of_components
     (c_pay_proposal_id per_pay_proposals.pay_proposal_id%TYPE) is
  select sum(change_amount_n)
  from   per_pay_proposal_components
  where  pay_proposal_id 	= c_pay_proposal_id;

  --
  --
  -- Cursor to get the element_type and input value details
  -- this cursor is used when the first proposal gets approved.
  --
  cursor csr_get_element_detail is
  select pet.element_type_id,
	 piv.input_value_id
  from
 	 pay_element_types_f  pet,
	 pay_input_values_f   piv,
	 per_pay_bases        ppb,
	 per_all_assignments_f    asg

  where
	 pet.element_type_id = piv.element_type_id
  and    l_trunc_date BETWEEN pet.effective_start_date
  and    pet.effective_end_date
  and    piv.input_value_id = ppb.input_value_id
  and    l_trunc_date BETWEEN piv.effective_start_date
         AND    piv.effective_end_date
  and    ppb.pay_basis_id = asg.pay_basis_id
  and    asg.assignment_id = p_assignment_id
  and    l_trunc_date   BETWEEN asg.effective_start_date
         AND     asg.effective_end_date;
  --
  -- cursor to get the last_proposed_salary which has been approved.
  --
  cursor csr_get_last_approved_salary is
   select proposed_salary_n
   from   per_pay_proposals
   where  assignment_id = p_assignment_id
   and    change_date < l_trunc_date
   order  by change_date desc;
   --
   -- Cursor to get the proposal details
   --
   cursor csr_get_proposal_detail is
   select change_date,
	  proposed_salary_n,
	  multiple_components,
	  approved,
	  proposal_reason,
	  object_version_number
   from   per_pay_proposals
   where  assignment_id     = p_assignment_id
   and    pay_proposal_id   = p_pay_proposal_id
   and    business_group_id = p_business_group_id;
   --
   -- cursor to get the component details
   --
   cursor csr_get_component_detail
   (c_component_id per_pay_proposal_components.component_id%TYPE) is
   select component_reason,
	  change_amount_n,
	  change_percentage,
	  approved,
	  object_version_number
   from   per_pay_proposal_components
   where  component_id 		= c_component_id
   and    business_group_id 	= p_business_group_id;
   --
-- changed by schowdhu for bug #7693247 16-jan-2009
-- included p_change_date as input param
Cursor next_change_date(p_change_date DATE)
IS
select min(change_date)
from per_pay_proposals
where assignment_id = p_assignment_id
and  change_date > p_change_date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint upload_salary_proposal;
  --
  -- initialise the local  parameters
  --
  l_proposed_salary          := p_proposed_salary;
  l_pay_proposal_id          := p_pay_proposal_id;
  l_object_version_number    := p_object_version_number ;
  l_component_id_1           := p_component_id_1;
  l_ppc_ovn_1                := p_ppc_object_version_number_1;
  l_component_id_2           := p_component_id_2;
  l_ppc_ovn_2                := p_ppc_object_version_number_2;
  l_component_id_3           := p_component_id_3;
  l_ppc_ovn_3                := p_ppc_object_version_number_3;
  l_component_id_4           := p_component_id_4;
  l_ppc_ovn_4                := p_ppc_object_version_number_4;
  l_component_id_5           := p_component_id_5;
  l_ppc_ovn_5                := p_ppc_object_version_number_5;
  l_component_id_6           := p_component_id_6;
  l_ppc_ovn_6                := p_ppc_object_version_number_6;
  l_component_id_7           := p_component_id_7;
  l_ppc_ovn_7                := p_ppc_object_version_number_7;
  l_component_id_8           := p_component_id_8;
  l_ppc_ovn_8                := p_ppc_object_version_number_8;
  l_component_id_9           := p_component_id_9;
  l_ppc_ovn_9                := p_ppc_object_version_number_9;
  l_component_id_10          := p_component_id_10;
  l_ppc_ovn_10               := p_ppc_object_version_number_10;

  -- Truncate the time portion
  --
  l_change_date	         := trunc(p_change_date);
  l_next_sal_review_date := trunc(p_next_sal_review_date);
  --
  -- Call Before Process User Hook upload_salary_proposal
  --

 l_date_to          := p_date_to;

  if l_date_to is null then

    OPEN next_change_date(l_change_date);
    fetch next_change_date into l_next_change_date;
    close next_change_date;

    if l_next_change_date is null then
     l_date_to:= hr_general.end_of_time;
    else
     l_date_to := l_next_change_date-1;
    end if;

  end if;

  begin
    hr_upload_proposal_bk1.upload_salary_proposal_b
      (
       p_change_date                   => l_change_date
      ,p_business_group_id             => p_business_group_id
      ,p_assignment_id                 => p_assignment_id
      ,p_proposed_salary               => p_proposed_salary
      ,p_proposal_reason               => p_proposal_reason
      ,p_next_sal_review_date          => l_next_sal_review_date  -- Bug 1620922
      ,p_forced_ranking                => p_forced_ranking
      ,p_date_to		       => l_date_to
      ,p_pay_proposal_id               => p_pay_proposal_id
      ,p_object_version_number         => p_object_version_number
      --
      ,p_component_reason_1            => p_component_reason_1
      ,p_change_amount_1               => p_change_amount_1
      ,p_change_percentage_1           => p_change_percentage_1
      ,p_approved_1                    => p_approved_1
      ,p_component_id_1	               => p_component_id_1
      ,p_ppc_object_version_number_1   => p_ppc_object_version_number_1
      --
      ,p_component_reason_2            => p_component_reason_2
      ,p_change_amount_2               => p_change_amount_2
      ,p_change_percentage_2           => p_change_percentage_2
      ,p_approved_2                    => p_approved_2
      ,p_component_id_2	               => p_component_id_2
      ,p_ppc_object_version_number_2   => p_ppc_object_version_number_2
      --
      ,p_component_reason_3            => p_component_reason_3
      ,p_change_amount_3               => p_change_amount_3
      ,p_change_percentage_3           => p_change_percentage_3
      ,p_approved_3                    => p_approved_3
      ,p_component_id_3	               => p_component_id_3
      ,p_ppc_object_version_number_3   => p_ppc_object_version_number_3
      --
      ,p_component_reason_4            => p_component_reason_4
      ,p_change_amount_4               => p_change_amount_4
      ,p_change_percentage_4           => p_change_percentage_4
      ,p_approved_4                    => p_approved_4
      ,p_component_id_4	               => p_component_id_4
      ,p_ppc_object_version_number_4   => p_ppc_object_version_number_4
      --
      ,p_component_reason_5            => p_component_reason_5
      ,p_change_amount_5               => p_change_amount_5
      ,p_change_percentage_5           => p_change_percentage_5
      ,p_approved_5                    => p_approved_5
      ,p_component_id_5	               => p_component_id_5
      ,p_ppc_object_version_number_5   => p_ppc_object_version_number_5
      --
      ,p_component_reason_6            => p_component_reason_6
      ,p_change_amount_6               => p_change_amount_6
      ,p_change_percentage_6           => p_change_percentage_6
      ,p_approved_6                    => p_approved_6
      ,p_component_id_6	               => p_component_id_6
      ,p_ppc_object_version_number_6   => p_ppc_object_version_number_6
      --
      ,p_component_reason_7            => p_component_reason_7
      ,p_change_amount_7               => p_change_amount_7
      ,p_change_percentage_7           => p_change_percentage_7
      ,p_approved_7                    => p_approved_7
      ,p_component_id_7	               => p_component_id_7
      ,p_ppc_object_version_number_7   => p_ppc_object_version_number_7
      --
      ,p_component_reason_8            => p_component_reason_8
      ,p_change_amount_8               => p_change_amount_8
      ,p_change_percentage_8           => p_change_percentage_8
      ,p_approved_8                    => p_approved_8
      ,p_component_id_8	               => p_component_id_8
      ,p_ppc_object_version_number_8   => p_ppc_object_version_number_8
      --
      ,p_component_reason_9            => p_component_reason_9
      ,p_change_amount_9               => p_change_amount_9
      ,p_change_percentage_9           => p_change_percentage_9
      ,p_approved_9                    => p_approved_9
      ,p_component_id_9	               => p_component_id_9
      ,p_ppc_object_version_number_9   => p_ppc_object_version_number_9
      --
      ,p_component_reason_10           => p_component_reason_10
      ,p_change_amount_10              => p_change_amount_10
      ,p_change_percentage_10          => p_change_percentage_10
      ,p_approved_10                   => p_approved_10
      ,p_component_id_10               => p_component_id_10
      ,p_ppc_object_version_number_10  => p_ppc_object_version_number_10
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPLOAD_SALARY_PROPOSAL'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of API User Hook for the before hook of upload_salary_proposal
  --
  end;
  --
  -- make a table from the components parameter
  --
  create_sql_table
    (p_component_reason_1	=> p_component_reason_1
    ,p_change_amount_1		=> p_change_amount_1
    ,p_change_percentage_1	=> p_change_percentage_1
    ,p_component_id_1		=> p_component_id_1
    ,p_approved_1		=> p_approved_1
    ,p_object_version_number_1  => p_ppc_object_version_number_1
    --
    ,p_component_reason_2       => p_component_reason_2
    ,p_change_amount_2		=> p_change_amount_2
    ,p_change_percentage_2	=> p_change_percentage_2
    ,p_component_id_2		=> p_component_id_2
    ,p_approved_2		=> p_approved_2
    ,p_object_version_number_2  => p_ppc_object_version_number_2
    --
    ,p_component_reason_3       => p_component_reason_3
    ,p_change_amount_3		=> p_change_amount_3
    ,p_change_percentage_3	=> p_change_percentage_3
    ,p_component_id_3		=> p_component_id_3
    ,p_approved_3		=> p_approved_3
    ,p_object_version_number_3  => p_ppc_object_version_number_3
    --
    ,p_component_reason_4       => p_component_reason_4
    ,p_change_amount_4		=> p_change_amount_4
    ,p_change_percentage_4	=> p_change_percentage_4
    ,p_component_id_4		=> p_component_id_4
    ,p_approved_4		=> p_approved_4
    ,p_object_version_number_4  => p_ppc_object_version_number_4
    --
    ,p_component_reason_5       => p_component_reason_5
    ,p_change_amount_5		=> p_change_amount_5
    ,p_change_percentage_5	=> p_change_percentage_5
    ,p_component_id_5		=> p_component_id_5
    ,p_approved_5		=> p_approved_5
    ,p_object_version_number_5  => p_ppc_object_version_number_5
    --
    ,p_component_reason_6       => p_component_reason_6
    ,p_change_amount_6		=> p_change_amount_6
    ,p_change_percentage_6	=> p_change_percentage_6
    ,p_component_id_6		=> p_component_id_6
    ,p_approved_6		=> p_approved_6
    ,p_object_version_number_6  => p_ppc_object_version_number_6
    --
    ,p_component_reason_7       => p_component_reason_7
    ,p_change_amount_7		=> p_change_amount_7
    ,p_change_percentage_7	=> p_change_percentage_7
    ,p_component_id_7		=> p_component_id_7
    ,p_approved_7		=> p_approved_7
    ,p_object_version_number_7  => p_ppc_object_version_number_7
    --
    ,p_component_reason_8       => p_component_reason_8
    ,p_change_amount_8		=> p_change_amount_8
    ,p_change_percentage_8	=> p_change_percentage_8
    ,p_component_id_8		=> p_component_id_8
    ,p_approved_8		=> p_approved_8
    ,p_object_version_number_8  => p_ppc_object_version_number_8
    --
    ,p_component_reason_9       => p_component_reason_9
    ,p_change_amount_9		=> p_change_amount_9
    ,p_change_percentage_9	=> p_change_percentage_9
    ,p_component_id_9		=> p_component_id_9
    ,p_approved_9		=> p_approved_9
    ,p_object_version_number_9  => p_ppc_object_version_number_9
    --
    ,p_component_reason_10      => p_component_reason_10
    ,p_change_amount_10		=> p_change_amount_10
    ,p_change_percentage_10	=> p_change_percentage_10
    ,p_component_id_10		=> p_component_id_10
    ,p_approved_10		=> p_approved_10
    ,p_object_version_number_10 => p_ppc_object_version_number_10
    --
    ,p_comp_reason_table  	=> l_comp_reason_table
    ,p_change_amount_table 	=> l_change_amount_table
    ,p_change_percentage_table  => l_change_percentage_table
    ,p_comp_id_table		=> l_comp_id_table
    ,p_approved_table		=> l_approved_table
    ,p_ovn_table		=> l_ovn_table
    );

  --
  -- The following parameter is used to verify whether any
  -- components is set for a salary_proposal
  --
  l_is_component_not_null := is_component_exist
			       (
			       l_change_amount_table
			       ,l_change_percentage_table
			       );
  hr_utility.set_location(l_proc, 10);
  --
  -- get the last salary proposal.
  --
  open csr_get_last_approved_salary;
  fetch  csr_get_last_approved_salary into l_last_proposed_salary;
  if   csr_get_last_approved_salary%notfound then
       hr_utility.set_location(l_proc, 15);
       --
       -- this means that, this is the first proposal, hence apply
       -- create proposal (i.e.first) or update proposal depending
       -- on the value of the l_pay_proposal_id
       --
       if (l_pay_proposal_id is null) then
	  --
	  --
          -- raise the component error if any of the components
	  -- were set. Note: the first proposal has no components.
	  --
          if (l_is_component_not_null) then
	      hr_utility.set_location(l_proc, 20);
	      close csr_get_last_approved_salary;
	      hr_utility.set_message(801,'HR_51312_PPC_COMP_NOT_ALLOWED');
	      hr_utility.raise_error;
          end if;
          --
	  if (l_trunc_date IS NULL AND p_proposed_salary IS NULL AND
	      p_proposal_reason IS NULL ) then
	      --
	      -- this means that no action need to be taken for this record
	      --
	      hr_utility.set_location(l_proc, 25);
	      --
          else
                 --
                 -- p_next_sal_review_date is being set to null if it is
		 -- defaulted to EOT
		 if l_next_sal_review_date = hr_api.g_date then
		    l_next_sal_review_date := null;
		 end if;
		 --
		 -- This means that the record need to be inserted
		 -- Note that the proposal gets approved automatically,
		 -- because it is the first proposal.
		 --
	         hr_utility.set_location(l_proc, 30);
                 l_multiple_components := 'N';
	         --
	         -- insert an unapproved single component salary proposal
	         -- record in per_pay_proposal_table using the row_handler
	         --
	           --vkodedal 05-Oct-2007 ER to satisfy satutory requirement
	           --Retain auto approve first proposal functionality if profile is null or set to Yes
	           l_approved :='N';
	                     l_autoApprove:=fnd_profile.value('HR_AUTO_APPROVE_FIRST_PROPOSAL');
	                     if(l_autoApprove is null or l_autoApprove ='Y') then
	                     hr_utility.set_location(l_proc, 32);
	                     l_approved:='Y';
	                     end if;
	         per_pyp_ins.ins
		     (p_pay_proposal_id		=> l_pay_proposal_id
		     ,p_assignment_id		=> p_assignment_id
		     ,p_business_group_id	=> p_business_group_id
		     ,p_change_date		=> l_change_date
		     ,p_proposed_salary_n       => p_proposed_salary
		     ,p_proposal_reason		=> p_proposal_reason
                     ,p_next_sal_review_date    => l_next_sal_review_date -- Bug 1620922
                     ,p_forced_ranking          => p_forced_ranking
		     ,p_date_to			=> l_date_to
		     ,p_approved		=> l_approved
		     ,p_multiple_components	=> l_multiple_components
		     ,p_inv_next_sal_date_warning
					=> l_inv_next_sal_date_warning
                     ,p_object_version_number
					=> l_pyp_object_version_number
		     ,p_proposed_salary_warning
		     			=> l_proposed_salary_warning
		     ,p_approved_warning
					=> l_approved_warning
		     ,p_payroll_warning
					=> l_payroll_warning
                     ,p_attribute_category  => p_attribute_category
                     ,p_attribute1  => p_attribute1
                     ,p_attribute2  => p_attribute2
                     ,p_attribute3  => p_attribute3
                     ,p_attribute4  => p_attribute4
                     ,p_attribute5  => p_attribute5
                     ,p_attribute6  => p_attribute6
                     ,p_attribute7  => p_attribute7
                     ,p_attribute8  => p_attribute8
                     ,p_attribute9  => p_attribute9
                     ,p_attribute10  => p_attribute10
                     ,p_attribute11  => p_attribute11
                     ,p_attribute12  => p_attribute12
                     ,p_attribute13  => p_attribute13
                     ,p_attribute14  => p_attribute14
                     ,p_attribute15  => p_attribute15
                     ,p_attribute16  => p_attribute16
                     ,p_attribute17  => p_attribute17
                     ,p_attribute18  => p_attribute18
                     ,p_attribute19  => p_attribute19
                     ,p_attribute20  => p_attribute20
		     );

		     if (l_approved='Y') then
                 --
		 -- Now maintain element entries;
		 --
		 open  csr_get_element_detail;
		 fetch csr_get_element_detail into l_element_type_id,
		 l_input_value_id;
		 if csr_get_element_detail%notfound then
	            hr_utility.set_location(l_proc,35);
		    close csr_get_element_detail;
		    hr_utility.set_message(801,'HR_289855_SAL_ASS_NOT_SAL_ELIG');
		    hr_utility.raise_error;
		 else
		    close csr_get_element_detail;
		    if (l_element_type_id IS NULL OR l_input_value_id IS NULL)
                       then
		       hr_utility.set_location(l_proc,40);
		       hr_utility.set_message
                                    (801,'HR_289855_SAL_ASS_NOT_SAL_ELIG');
		       hr_utility.raise_error;
                    else
		       l_element_link_id := hr_entry_api.get_link
						     (p_assignment_id
						     ,l_element_type_id
		  				     ,l_trunc_date);
                       if l_element_link_id IS NULL then
			  hr_utility.set_message
                                     (801,'HR_13016_SAL_ELE_NOT_ELIG');
			  hr_utility.raise_error;
                       end if;
                       --
		       -- Now we insert an element entry for this proposal
		       -- by calling the insert_element_entry_api.
		       --
		       hr_entry_api.insert_element_entry
		      (p_effective_start_date	   => l_effective_start_date
		      ,p_effective_end_date	   => l_effective_end_date
		      ,p_element_entry_id          => l_element_entry_id
		      ,p_assignment_id		   => p_assignment_id
		      ,p_element_link_id	   => l_element_link_id
		      ,p_creator_type		   => 'SP'
		      ,p_entry_type		   => 'E'
		      ,p_creator_id		   => l_pay_proposal_id
		      ,p_input_value_id1 	   => l_input_value_id
		      ,p_entry_value1		   => p_proposed_salary
		      );
--changes for Position Control check on Salary proposal
   pqh_psf_bus.chk_position_budget( p_assignment_id => p_assignment_id
                                   ,p_element_type_id => l_element_type_id
                                   ,p_input_value_id  => l_input_value_id
                                   ,p_effective_date  => p_change_date
                                   ,p_called_from    => 'SAL');
--End changes for position control rule on sal proposal
--
                    end if;
                 --
                 end if;
      end if;
	  end if;
	  --
       end if;
       --
     else  -- This salary proposal is not the only one.
         --
         -- this is when the an unapproved proposal exists. Therefore
         -- the proposal is not the first one.
      --
      if (l_pay_proposal_id is NOT NULL) then
         --
         -- get the proposal details and check that the proposal has not
         -- been changed through the HRMS
         --
         open csr_get_proposal_detail;
         fetch csr_get_proposal_detail into l_change_date,l_proposed_salary_db,
         l_multiple_components,l_pyp_approved,l_proposal_reason,
         l_pyp_object_version_number;
	 if csr_get_proposal_detail%notfound then
	    hr_utility.set_location(l_proc,45);
	    close  csr_get_proposal_detail;
	    hr_utility.set_message(801,'HR_51310_PPC_INVAL_PRO_ID');
            hr_utility.raise_error;
         else
	    close  csr_get_proposal_detail;
	   --
	   -- check that the object version number is the same (the record has
	   -- not been changed since it has been out via the HRMS)
	   --
	   if (l_pyp_object_version_number <> p_object_version_number) then
	      hr_utility.set_location(l_proc,50);
	      hr_utility.set_message(801,'HR_51348_PYP_RECORD_CHG');
	      hr_utility.raise_error;
           end if;
       	   --
	   -- Check that the proposal is multiple or single component.
	   -- if it is single_component and some components exists then
	   -- raise error.
	   --
	   if (l_multiple_components = 'N') then
	      if (l_is_component_not_null) then
	         hr_utility.set_location(l_proc,55);
	         hr_utility.set_message(801,'HR_51312_PPC_COMP_NOT_ALLOWED');
	         hr_utility.raise_error;
              else
		 --
	         -- check that the change_date has not been updated
		 -- This extra check is done here since the update api has
		 -- no change_date parameter. And since the usermay change
		 -- the change date we need to do this validation before
		 -- calling the update routine
		 --
		 if (l_trunc_date <> l_change_date) then
		   hr_utility.set_location(l_proc,60);
		   hr_utility.set_message(801,'HR_51349_PYP_CNT_UPD_CHG_DATE');
		   hr_utility.raise_error;
		 end if;
		 --
		 --
		 -- update the salary proposal
		 --
		 per_pyp_upd.upd
		     (p_pay_proposal_id		=> l_pay_proposal_id
		     ,p_proposal_reason		=> p_proposal_reason
                     ,p_next_sal_review_date    => l_next_sal_review_date  -- Bug 1620922
		     ,p_proposed_salary_n       => p_proposed_salary
                     ,p_forced_ranking          => p_forced_ranking
		     ,p_validate		=> false
                     ,p_object_version_number 	=> l_pyp_object_version_number
		     ,p_inv_next_sal_date_warning
					=> l_inv_next_sal_date_warning
		     ,p_proposed_salary_warning => l_proposed_salary_warning
		     ,p_approved_warning  	=> l_approved_warning
                     ,p_payroll_warning         => l_payroll_warning
                     ,p_attribute_category  => p_attribute_category
                     ,p_attribute1  => p_attribute1
                     ,p_attribute2  => p_attribute2
                     ,p_attribute3  => p_attribute3
                     ,p_attribute4  => p_attribute4
                     ,p_attribute5  => p_attribute5
                     ,p_attribute6  => p_attribute6
                     ,p_attribute7  => p_attribute7
                     ,p_attribute8  => p_attribute8
                     ,p_attribute9  => p_attribute9
                     ,p_attribute10  => p_attribute10
                     ,p_attribute11  => p_attribute11
                     ,p_attribute12  => p_attribute12
                     ,p_attribute13  => p_attribute13
                     ,p_attribute14  => p_attribute14
                     ,p_attribute15  => p_attribute15
                     ,p_attribute16  => p_attribute16
                     ,p_attribute17  => p_attribute17
                     ,p_attribute18  => p_attribute18
                     ,p_attribute19  => p_attribute19
                     ,p_attribute20  => p_attribute20
		     );
                 --
	         hr_utility.set_location(l_proc,65);
	      --
	      end if;
          else
	       --
	       -- l_multiple_components = 'Y'
	       -- This is when the proposal has multiple components.
	       -- We need to calculate the sum of the components in this case
	       --
	       hr_utility.set_location(l_proc,70);
	       l_component_cal		:= TRUE;
	       --
          end if;
	   --
         end if;    -- end of  csr_get_proposal_detail notfound
      else
	  --  l_pay_proposal is null
	  --
	  -- This is when the proposal is not the first proposal and it has not
	  -- already existed( i.e. it  need to be created).
          -- first of all we need to determine whether the proposal is of type
	  -- multiple components or not. This is done by checking the components.
	  --
	  hr_utility.set_location(l_proc,75);
	  if (l_is_component_not_null) then
	       l_multiple_components 	:= 'Y';
	       l_component_cal		:= TRUE;
	       hr_utility.set_location(l_proc,80);
          else l_multiple_components	:= 'N';
	       hr_utility.set_location(l_proc,85);
	  --
	  end if;
	     --
	     if l_next_sal_review_date = hr_api.g_date then
		l_next_sal_review_date := null;
	     end if;

	     -- insert an unapproved single component salary proposal record in
	     -- per_pay_proposals table using the row_handler
	     --
             end_date_salary_proposal(p_assignment_id  => p_assignment_id
                                  ,p_date_to        => p_change_date-1);
----------vkodedal 7-mar-07
--  Update the last_change_date for the next proposal
--
	update_last_change_date(p_assignment_id, p_change_date);

	     per_pyp_ins.ins
		     (p_pay_proposal_id		=> l_pay_proposal_id
		     ,p_assignment_id		=> p_assignment_id
		     ,p_business_group_id	=> p_business_group_id
		     ,p_change_date		=> l_change_date
		     ,p_proposal_reason		=> p_proposal_reason
                     ,p_next_sal_review_date    => l_next_sal_review_date  -- Bug 1620922
		     ,p_proposed_salary_n       => p_proposed_salary
                     ,p_forced_ranking          => p_forced_ranking
		     ,p_date_to			=> l_date_to
		     ,p_approved		=> 'N'
		     ,p_multiple_components	=> l_multiple_components
                     ,p_object_version_number	=> l_pyp_object_version_number
		     ,p_validate		=> false
		     ,p_inv_next_sal_date_warning
						=> l_inv_next_sal_date_warning
		     ,p_proposed_salary_warning
						=> l_proposed_salary_warning
		     ,p_approved_warning
						=> l_approved_warning
		     ,p_payroll_warning
						=> l_payroll_warning
						--vkodedal 03-Sep-07 -fix for 6244195 -webadi issue -dff not getting uploaded
					 ,p_attribute_category  => p_attribute_category
                     ,p_attribute1  => p_attribute1
                     ,p_attribute2  => p_attribute2
                     ,p_attribute3  => p_attribute3
                     ,p_attribute4  => p_attribute4
                     ,p_attribute5  => p_attribute5
                     ,p_attribute6  => p_attribute6
                     ,p_attribute7  => p_attribute7
                     ,p_attribute8  => p_attribute8
                     ,p_attribute9  => p_attribute9
                     ,p_attribute10  => p_attribute10
                     ,p_attribute11  => p_attribute11
                     ,p_attribute12  => p_attribute12
                     ,p_attribute13  => p_attribute13
                     ,p_attribute14  => p_attribute14
                     ,p_attribute15  => p_attribute15
                     ,p_attribute16  => p_attribute16
                     ,p_attribute17  => p_attribute17
                     ,p_attribute18  => p_attribute18
                     ,p_attribute19  => p_attribute19
                     ,p_attribute20  => p_attribute20
		     );
              --
	      hr_utility.set_location(l_proc,90);
	      --
    end if;   -- l_pay_proposal_id is not null
     --
  end if;  -- csr_get_last_approved_salary not found
  --
  if (csr_get_last_approved_salary%isopen) then
      close csr_get_last_approved_salary;
      hr_utility.set_location(l_proc,95);
  end if;
  --
  if (csr_get_proposal_detail%isopen) then
     close csr_get_proposal_detail;
     hr_utility.set_location(l_proc,100);
  end if;
 --
 -- Now loop round the components and insert the components followed by
 -- updating the appropriate proposal
 --
 if(l_component_cal = true and l_last_proposed_salary IS NOT NULL) then
    hr_utility.set_location(l_proc,105);
    for i in 1 .. MAX_COMP_NO
    loop
      --
      -- set the value of the local parameters to be the appropriate
      -- component value.
      --
      l_comp_update	         := false;
      l_change_amount_in         := get_value(l_change_amount_table,i);
      l_change_percentage_in     := get_value(l_change_percentage_table,i);
      l_component_reason_in      := get_value(l_comp_reason_table, i);
      l_component_id_in          := get_value(l_comp_id_table, i);
      l_approved_in	         := get_value(l_approved_table,i);
      l_object_version_number_in := get_value(l_ovn_table,i);


      if (l_component_id_in IS NOT NULL ) then
        hr_utility.set_location(l_proc,110);
        open csr_get_component_detail (l_component_id_in);
        fetch csr_get_component_detail into l_component_reason, l_change_amount,
        l_change_percentage,l_ppc_approved, l_ppc_object_version_number;
	if csr_get_component_detail%notfound then
	   close csr_get_component_detail;
	   hr_utility.set_location(l_proc,115);
	   hr_utility.set_message(801,'HR_51319_PPC_INVAL_COMP_ID');
	   hr_utility.raise_error;
        else
   	   close csr_get_component_detail;
	   hr_utility.set_location(l_proc,120);
	   --
	   -- check that the record has not been changed since last time.
	   --
	   if (l_ppc_object_version_number <> l_object_version_number_in) then
	     hr_utility.set_location(l_proc,125);
	     hr_utility.set_message(801,'HR_51455_PPC_RECORD_CHANGED');
	     hr_utility.raise_error;
           end if;
	   --
	   -- Do nothing if the component has not changed at all.
	   --
             if (l_component_reason  = l_component_reason_in AND
		 nvl(l_change_amount,hr_api.g_number)
                     = nvl(l_change_amount_in,hr_api.g_number)    AND
		 nvl(l_change_percentage,hr_api.g_number)
                     = nvl(l_change_percentage_in,hr_api.g_number) AND
		 l_ppc_approved      = l_approved_in ) then
		 --
		 -- this means that the component has not changed
		 -- we just adding the amount.
		 --
	         hr_utility.set_location(l_proc,130);
		 l_component_sum
		    := l_component_sum + l_change_amount;
	     --
            elsif (l_component_reason = l_component_reason_in AND
		     nvl(l_change_amount,hr_api.g_number)
                     = nvl(l_change_amount_in,hr_api.g_number)    AND
		     nvl(l_change_percentage,hr_api.g_number)
                     = nvl(l_change_percentage_in,hr_api.g_number) AND
		     l_ppc_approved        <> l_approved_in ) then
		   --
		   -- this means that the component approval status has changed.
		   -- We need to update the record.Set the update flag to true.
		   --
		   --
		     l_component_sum
		         := l_component_sum + l_change_amount;
		     l_comp_update := true;
		     --
	             hr_utility.set_location(l_proc,135);
		    --
		    -- issue an error if updating an approved component
		    --
             elsif (l_ppc_approved = 'Y' AND
		     (l_component_reason    <> l_component_reason_in OR
		      nvl(l_change_amount,hr_api.g_number)
                      <> nvl(l_change_amount_in,hr_api.g_number)    OR
		      nvl(l_change_percentage,hr_api.g_number)
                      <> nvl(l_change_percentage_in,hr_api.g_number))) then
		      hr_utility.set_location(l_proc,140);
		      hr_utility.set_message(801,'HR_51454_PPC_CANT_UPD_COMP');
		      hr_utility.raise_error;
              elsif (l_ppc_approved = 'N') then
		--
		-- This is when the component is not already approved and some
		-- changes has taken place, hence we need to update or delete
		-- the record as appropriate.
		--
		if (l_change_amount_in  IS NULL) then
		   if(l_change_percentage_in IS NOT NULL AND
		     l_change_percentage_in <> 0) then
		     --
		     -- calculate the component_sum from the change_percentage
		     -- and update the record.
		     --
	             hr_utility.set_location(l_proc,145);
		     l_component_sum := l_component_sum +
		     l_last_proposed_salary
			* l_change_percentage_in /100;
		     --
		     -- Set the l_comp_update and l_prop_update to true.
		     -- update the record and set the approved flag to Y
		     --
		       l_prop_update := true;
		       l_comp_update := true;
		       hr_utility.set_location(l_proc,150);
                   else
		     --
		     -- the change_amount and the change percentage are
		     -- both null, this means that the component need to
		     -- be deleted
		     --
		     per_ppc_del.del
		       (p_component_id 		 => l_component_id_in
			,p_object_version_number => l_object_version_number_in
			,p_validate              => false
			);
		     --
		     -- subtract the previous change_amount from the component_sum
		     --
		     l_component_sum
                         := l_component_sum - l_change_amount;

		     l_prop_update := true;
                     --
                     hr_utility.set_location(l_proc,155);
		     --
                  end if; -- l_change_percentage IS NOT NULL
                else
                   --
		   -- this is when the change_amount is not null
		   -- first sum up the component and then update the component
		   --
		   l_component_sum
		   := l_component_sum + l_change_amount_in;
		   --
		   -- Set the comp_update and prop_update to true
		   --
 		   l_comp_update := true;
		   l_prop_update := true;
		   hr_utility.set_location(l_proc,160);
                end if; -- l_change_amount_is not null
		--
	     end if;
             --
	     -- Now update the component if the l_comp_update is true
	     --
	     if (l_comp_update) then
		 per_ppc_upd.upd
		  (p_component_id	=> l_component_id_in
		   ,p_component_reason  => l_component_reason_in
		   ,p_change_amount_n	=> l_change_amount_in
		   ,p_change_percentage	=> l_change_percentage_in
		   ,p_approved		=> l_approved_in
		   ,p_object_version_number => l_object_version_number_in
		   ,p_validate		=> false
		   );
		 hr_utility.set_location(l_proc, 165);
	     end if;
	   --
         end if;   -- csr_get_component_details
	 --
       else /* l_component_id_in IS NOT NULL*/
            --
	    -- component_id is null. Therefore, we are inserting a new
	    -- record in the db.
	    --
	    if (l_change_amount_in IS NOT NULL OR
	       (l_change_percentage_in IS NOT NULL AND
		l_change_percentage_in <> 0)) then

		l_comp_update := true;
		l_prop_update := true;
	      if (l_change_amount_in IS NOT NULL ) then
                 l_component_sum := l_component_sum +
                 l_change_amount_in;
	       	 hr_utility.set_location(l_proc, 170);
              else
		 if (l_change_percentage_in IS NOT NULL) then
		   l_component_sum := l_component_sum +
		   l_last_proposed_salary *
                            l_change_percentage_in /100;
		   hr_utility.set_location(l_proc, 175);
                 end if;
		 --
              end if;
	       --
	      per_ppc_ins.ins
	        (p_component_id	       	 => l_component_id_in
		,p_pay_proposal_id	 => l_pay_proposal_id
		,p_business_group_id	 => p_business_group_id
	        ,p_component_reason	 => l_component_reason_in
		,p_change_amount_n	 => l_change_amount_in
		,p_change_percentage	 => l_change_percentage_in
		,p_approved		 => l_approved_in
		,p_object_version_number => l_object_version_number_in
		,p_validate		 => false
		);
		hr_utility.set_location(l_proc, 180);
		--
            end if;
     end if; -- the l_component_id is null
     --
     -- Set the output parameters
     --
     if (i = 1) then
	l_component_id_1 := l_component_id_in;
	l_ppc_ovn_1 := l_object_version_number_in;
     elsif (i= 2) then
	l_component_id_2 := l_component_id_in;
	l_ppc_ovn_2 := l_object_version_number_in;
     elsif (i= 3) then
	l_component_id_3 := l_component_id_in;
	l_ppc_ovn_3 := l_object_version_number_in;
     elsif (i= 4) then
	l_component_id_4 := l_component_id_in;
	l_ppc_ovn_4 := l_object_version_number_in;
     elsif (i= 5) then
	l_component_id_5 := l_component_id_in;
	l_ppc_ovn_5 := l_object_version_number_in;
     elsif (i= 6) then
	l_component_id_6 := l_component_id_in;
	l_ppc_ovn_6 := l_object_version_number_in;
     elsif (i= 7) then
	l_component_id_7 := l_component_id_in;
	l_ppc_ovn_7 := l_object_version_number_in;
     elsif (i= 8) then
	l_component_id_8 := l_component_id_in;
	l_ppc_ovn_8 := l_object_version_number_in;
     elsif (i= 9) then
	l_component_id_9 := l_component_id_in;
	l_ppc_ovn_9 := l_object_version_number_in;
     elsif (i= 10) then
	l_component_id_10 := l_component_id_in;
	l_ppc_ovn_10 := l_object_version_number_in;
     --
     end if;
   --
   end LOOP;
 --
 -- Now we need to update the pay_proposal table
 -- We need to double check that there is no other components exists other
 -- than those ten which we processed above. This is done by getting
 -- the sum of all the existing components.
 --
 --
 open csr_sum_of_components (l_pay_proposal_id);
 fetch csr_sum_of_components into l_total_component_sum;
 if csr_sum_of_components%found then
    close csr_sum_of_components;
    --
    -- check that the component sum from the above calculation
    -- is the same as the total_component_sum from the cursor.
    -- If they are not the same then set the inofrmational parameter
    -- to TRUE.
    --
    if (l_total_component_sum <> l_component_sum) then
	p_additional_comp_warning := TRUE;
    else
       p_additional_comp_warning := FALSE;
    end if;
    --
    l_proposed_salary := l_total_component_sum + l_last_proposed_salary;
  end if;
 --
 -- update the salary proposal if the l_prop_update is true;
 --
if (l_prop_update) then
   per_pyp_upd.upd
     (p_pay_proposal_id			=> l_pay_proposal_id
     ,p_proposal_reason			=> p_proposal_reason
     ,p_next_sal_review_date            => l_next_sal_review_date  -- Bug 1620922
     ,p_proposed_salary_n		=> l_proposed_salary
     ,p_forced_ranking                  => p_forced_ranking
     ,p_object_version_number		=> l_pyp_object_version_number
     ,p_inv_next_sal_date_warning       => l_inv_next_sal_date_warning
     ,p_proposed_salary_warning		=> l_proposed_salary_warning
     ,p_approved_warning		=> l_approved_warning
     ,p_payroll_warning                 => l_payroll_warning
     ,p_validate			=> false
     );
    --
    hr_utility.set_location(l_proc, 185);
end if;
 end if;   -- L_component_cal
 --
 -- Call After Process User Hook upload_salary_proposal
 --
  begin
    hr_upload_proposal_bk1.upload_salary_proposal_a
      (
       p_change_date                   => l_change_date
      ,p_business_group_id             => p_business_group_id
      ,p_assignment_id                 => p_assignment_id
      ,p_proposed_salary               => p_proposed_salary
      ,p_proposal_reason               => p_proposal_reason
      ,p_next_sal_review_date          => l_next_sal_review_date  -- Bug 1620922
      ,p_forced_ranking                => p_forced_ranking
      ,p_date_to		       => l_date_to
      ,p_pay_proposal_id               => l_pay_proposal_id
      ,p_object_version_number         => l_pyp_object_version_number
      --
      ,p_component_reason_1            => p_component_reason_1
      ,p_change_amount_1               => p_change_amount_1
      ,p_change_percentage_1           => p_change_percentage_1
      ,p_approved_1                    => p_approved_1
      ,p_component_id_1	               => l_component_id_1
      ,p_ppc_object_version_number_1   => l_ppc_ovn_1
      --
      ,p_component_reason_2            => p_component_reason_2
      ,p_change_amount_2               => p_change_amount_2
      ,p_change_percentage_2           => p_change_percentage_2
      ,p_approved_2                    => p_approved_2
      ,p_component_id_2	               => l_component_id_2
      ,p_ppc_object_version_number_2   => l_ppc_ovn_2
      --
      ,p_component_reason_3            => p_component_reason_3
      ,p_change_amount_3               => p_change_amount_3
      ,p_change_percentage_3           => p_change_percentage_3
      ,p_approved_3                    => p_approved_3
      ,p_component_id_3	               => l_component_id_3
      ,p_ppc_object_version_number_3   => l_ppc_ovn_3
      --
      ,p_component_reason_4            => p_component_reason_4
      ,p_change_amount_4               => p_change_amount_4
      ,p_change_percentage_4           => p_change_percentage_4
      ,p_approved_4                    => p_approved_4
      ,p_component_id_4	               => l_component_id_4
      ,p_ppc_object_version_number_4   => l_ppc_ovn_4
      --
      ,p_component_reason_5            => p_component_reason_5
      ,p_change_amount_5               => p_change_amount_5
      ,p_change_percentage_5           => p_change_percentage_5
      ,p_approved_5                    => p_approved_5
      ,p_component_id_5	               => l_component_id_5
      ,p_ppc_object_version_number_5   => l_ppc_ovn_5
      --
      ,p_component_reason_6            => p_component_reason_6
      ,p_change_amount_6               => p_change_amount_6
      ,p_change_percentage_6           => p_change_percentage_6
      ,p_approved_6                    => p_approved_6
      ,p_component_id_6	               => l_component_id_6
      ,p_ppc_object_version_number_6   => l_ppc_ovn_6
      --
      ,p_component_reason_7            => p_component_reason_7
      ,p_change_amount_7               => p_change_amount_7
      ,p_change_percentage_7           => p_change_percentage_7
      ,p_approved_7                    => p_approved_7
      ,p_component_id_7	               => l_component_id_7
      ,p_ppc_object_version_number_7   => l_ppc_ovn_7
      --
      ,p_component_reason_8            => p_component_reason_8
      ,p_change_amount_8               => p_change_amount_8
      ,p_change_percentage_8           => p_change_percentage_8
      ,p_approved_8                    => p_approved_8
      ,p_component_id_8	               => l_component_id_8
      ,p_ppc_object_version_number_8   => l_ppc_ovn_8
      --
      ,p_component_reason_9            => p_component_reason_9
      ,p_change_amount_9               => p_change_amount_9
      ,p_change_percentage_9           => p_change_percentage_9
      ,p_approved_9                    => p_approved_9
      ,p_component_id_9	               => l_component_id_9
      ,p_ppc_object_version_number_9   => l_ppc_ovn_9
      --
      ,p_component_reason_10           => p_component_reason_10
      ,p_change_amount_10              => p_change_amount_10
      ,p_change_percentage_10          => p_change_percentage_10
      ,p_approved_10                   => p_approved_10
      ,p_component_id_10               => l_component_id_10
      ,p_ppc_object_version_number_10  => l_ppc_ovn_10
      ,p_pyp_proposed_sal_warning      => l_pyp_proposed_sal_warning
      ,p_additional_comp_warning       => l_additional_comp_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPLOAD_SALARY_PROPOSAL'
        ,p_hook_type   => 'AP'
        );
  --
  -- End of API User Hook for the after hook of upload_salary_proposal
  --
  end;
  --
 -- when in validation only mode raise the Validate_Enabled exception
 --
 if p_validate then
    raise hr_api.validate_enabled;
 end if;
 --
 -- Set output parameters
 --
   p_pay_proposal_id             := l_pay_proposal_id;
   p_object_version_number       := l_pyp_object_version_number;
   p_pyp_proposed_sal_warning    := l_proposed_salary_warning;
   p_additional_comp_warning     := l_additional_comp_warning;
   p_component_id_1              := l_component_id_1;
   p_ppc_object_version_number_1 := l_ppc_ovn_1;
   p_component_id_2              := l_component_id_2;
   p_ppc_object_version_number_2 := l_ppc_ovn_2;
   p_component_id_3              := l_component_id_3;
   p_ppc_object_version_number_3 := l_ppc_ovn_3;
   p_component_id_4              := l_component_id_4;
   p_ppc_object_version_number_4 := l_ppc_ovn_4;
   p_component_id_5              := l_component_id_5;
   p_ppc_object_version_number_5 := l_ppc_ovn_5;
   p_component_id_6              := l_component_id_6;
   p_ppc_object_version_number_6 := l_ppc_ovn_6;
   p_component_id_7              := l_component_id_7;
   p_ppc_object_version_number_7 := l_ppc_ovn_7;
   p_component_id_8              := l_component_id_8;
   p_ppc_object_version_number_8 := l_ppc_ovn_8;
   p_component_id_9              := l_component_id_9;
   p_ppc_object_version_number_9 := l_ppc_ovn_9;
   p_component_id_10             := l_component_id_10;
   p_ppc_object_version_number_10:= l_ppc_ovn_10;

 --
 hr_utility.set_location(' Leaving:'||l_proc, 190);
 exception
   when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     ROLLBACK TO upload_salary_proposal;
     --
     -- Only set output warning arguments
     -- (Any key or derived arguments must be set to its initial
     -- value  when validation only mode is being used.)
     --
     p_pyp_proposed_sal_warning     := l_proposed_salary_warning;
     p_additional_comp_warning      := l_additional_comp_warning;
     p_pay_proposal_id              := lt_pay_proposal_id;
     p_object_version_number        := lt_object_version_number;

     p_component_id_1              := lt_component_id_1;
     p_ppc_object_version_number_1 := lt_ppc_ovn_1;
     p_component_id_2              := lt_component_id_2;
     p_ppc_object_version_number_2 := lt_ppc_ovn_2;
     p_component_id_3              := lt_component_id_3;
     p_ppc_object_version_number_3 := lt_ppc_ovn_3;
     p_component_id_4              := lt_component_id_4;
     p_ppc_object_version_number_4 := lt_ppc_ovn_4;
     p_component_id_5              := lt_component_id_5;
     p_ppc_object_version_number_5 := lt_ppc_ovn_5;
     p_component_id_6              := lt_component_id_6;
     p_ppc_object_version_number_6 := lt_ppc_ovn_6;
     p_component_id_7              := lt_component_id_7;
     p_ppc_object_version_number_7 := lt_ppc_ovn_7;
     p_component_id_8              := lt_component_id_8;
     p_ppc_object_version_number_8 := lt_ppc_ovn_8;
     p_component_id_9              := lt_component_id_9;
     p_ppc_object_version_number_9 := lt_ppc_ovn_9;
     p_component_id_10             := lt_component_id_10;
     p_ppc_object_version_number_10:= lt_ppc_ovn_10;
    --
  hr_utility.set_location(' Leaving:'||l_proc, 195);
  --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part part of fix to bug 632474
    --
    ROLLBACK TO upload_salary_proposal;
  --
  -- Reset IN OUT and set OUT parameters.
  p_pay_proposal_id             := lt_pay_proposal_id;
  p_object_version_number       := lt_object_version_number;
  p_pyp_proposed_sal_warning    := null;
  p_additional_comp_warning     := null;
  p_component_id_1              := lt_component_id_1;
  p_ppc_object_version_number_1 := lt_ppc_ovn_1;
  p_component_id_2              := lt_component_id_2;
  p_ppc_object_version_number_2 := lt_ppc_ovn_2;
  p_component_id_3              := lt_component_id_3;
  p_ppc_object_version_number_3 := lt_ppc_ovn_3;
  p_component_id_4              := lt_component_id_4;
  p_ppc_object_version_number_4 := lt_ppc_ovn_4;
  p_component_id_5              := lt_component_id_5;
  p_ppc_object_version_number_5 := lt_ppc_ovn_5;
  p_component_id_6              := lt_component_id_6;
  p_ppc_object_version_number_6 := lt_ppc_ovn_6;
  p_component_id_7              := lt_component_id_7;
  p_ppc_object_version_number_7 := lt_ppc_ovn_7;
  p_component_id_8              := lt_component_id_8;
  p_ppc_object_version_number_8 := lt_ppc_ovn_8;
  p_component_id_9              := lt_component_id_9;
  p_ppc_object_version_number_9 := lt_ppc_ovn_9;
  p_component_id_10             := lt_component_id_10;
  p_ppc_object_version_number_10:= lt_ppc_ovn_10;
    raise;
    --
    -- End of fix.
    --
end upload_salary_proposal;
--
end hr_upload_proposal_api;

/
