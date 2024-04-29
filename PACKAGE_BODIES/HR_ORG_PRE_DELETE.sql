--------------------------------------------------------
--  DDL for Package Body HR_ORG_PRE_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORG_PRE_DELETE" AS
/* $Header: pedelorg.pkb 115.2 99/10/12 23:43:14 porting shi $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ****************************************************************** */
/*
 Name        : hr_org_pre_delete  (BODY)

 Description : This package declares procedures required to test for referential
               integrity errors which could potentially be caused by deleting
               an organization which relationship rows with other tables.
               (Although ORACLE7 does this automatically the message isn't
                vey user friendly).

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
70.0     31-MAR-93 TMATHERS             Date Created.
70.1     01-APR-93 TMATHERS             MOved org_predel_check to peorganz.
70.2     01-APR-93 TMATHERS             Corrected error made by previous change
70.3     05-APR-93 TMATHERS             Change set location message to be
                                        hr_org_predel_check rather than
                                        hr_organization.
70.4     22-APR-93 TMATHERS             Added hr_strong_bg_chk.
70.5     21-Mar-95 TMATHERS             Added extra checks to
                                        hr_org_predel_checks for WWBUG #
                                        267897.
70.10    19-May-97 MBOCUTT   417613     Removed ref. int. check for
					per_organization_list table. Rows
					for the org being delete are now
					automatically removed on delete.
115.1    01-Oct-99 SCNair               Date track position related changes
*/
--------------------- BEGIN: hr_org_predel_check ------------------------------
procedure hr_org_predel_check(p_organization_id INTEGER
                          ,p_business_group_id INTEGER) is
/*
  NAME
    hr_org_predel_check
  DESCRIPTION
    Battery of tests to see if an organization may be deleted.
  PARAMETERS
    p_organization_id  : Organization Id of Organization to be deleted.
    p_business_group_id   : Business Group id of rganization to be deleted.
*/
--
-- Storage Variable.
--
l_test_func varchar2(60);
--
begin
-- If the organization id equals the business group id then
-- it is a business group and so do all relavant checks for Business group.
if p_organization_id = p_business_group_id then
	begin
		begin
		-- Do Any rows Exist in PER_PEOPLE_F.
		hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check'
                                       ,1);
		select '1'
		into l_test_func
		from sys.dual
		where exists ( select 1
		from PER_PEOPLE_F x
		where x.business_group_id = p_business_group_id);
		--
		if SQL%ROWCOUNT >0 THEN
		  hr_utility.set_message(801,'HR_6130_ORG_PEOPLE_EXIST');
		  hr_utility.raise_error;
		end if;
		exception
		when NO_DATA_FOUND THEN
		  null;
		end;
		--
		begin
		-- Do Any rows Exist in HR_ORGANIZATION_UNITS.
		hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check'
                                       ,2);
		select '1'
		into l_test_func
		from sys.dual
		where exists ( select 1
		from HR_ORGANIZATION_UNITS x
		where x.business_group_id = p_business_group_id
      and   x.organization_id  <> p_business_group_id);
		--
		if SQL%ROWCOUNT >0 THEN
		  hr_utility.set_message(801,'HR_6571_ORG_ORG_EXIST');
		  hr_utility.raise_error;
		end if;
		exception
		when NO_DATA_FOUND THEN
		  null;
		end;
		--
		begin
		-- Do Any rows Exist in PER_JOBS.
		hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check'
                                       ,3);
		select '1'
		into l_test_func
		from sys.dual
		where exists ( select 1
		from PER_JOBS x
		where x.business_group_id = p_business_group_id);
		--
		if SQL%ROWCOUNT >0 THEN
		  hr_utility.set_message(801,'HR_6131_ORG_JOBS_EXIST');
		  hr_utility.raise_error;
		end if;
		exception
		when NO_DATA_FOUND THEN
		  null;
		end;
		--
		begin
                --
                -- Changed 02-Oct-99 SCNair (per_positions to hr_all_positions_f) date tracked pos. req.
                --
		-- Do Any rows Exist in HR_ALL_POSITIONS_F.
		hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check'
                                       ,4);
		select '1'
		into l_test_func
		from sys.dual
		where exists ( select 1
		from HR_ALL_POSITIONS_F x
		where x.business_group_id = p_business_group_id);
		--
		if SQL%ROWCOUNT >0 THEN
		  hr_utility.set_message(801,'HR_6557_ORG_POSITIONS_EXIST');
		  hr_utility.raise_error;
		end if;
		exception
		when NO_DATA_FOUND THEN
		  null;
		end;
		--
		begin
		-- Do Any rows Exist in PER_BUDGET_VALUES.
		hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check'
                                       ,5);
		select '1'
		into l_test_func
		from sys.dual
		where exists ( select 1
		from PER_BUDGET_VALUES x
		where x.business_group_id = p_business_group_id);
		--
		if SQL%ROWCOUNT >0 THEN
		  hr_utility.set_message(801,'HR_6558_ORG_BUDGET_VAL_EXIST');
		  hr_utility.raise_error;
		end if;
		exception
		when NO_DATA_FOUND THEN
		  null;
		end;
		--
		begin
		-- Do Any rows Exist in PER_RECRUITMENT_ACTIVITIES.
		hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check'
                                       ,6);
		select '1'
		into l_test_func
		from sys.dual
		where exists ( select 1
		from PER_RECRUITMENT_ACTIVITIES x
		where x.business_group_id = p_business_group_id);
		--
		if SQL%ROWCOUNT >0 THEN
		  hr_utility.set_message(801,'HR_6568_ORG_RECRUIT_ACTS_EXIST');
		  hr_utility.raise_error;
		end if;
		exception
		when NO_DATA_FOUND THEN
		  null;
		end;
		--
		begin
		-- Do Any rows Exist in PER_ORG_STRUCTURE_ELEMENTS.
		hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check'
                                       ,7);
		select '1'
		into l_test_func
		from sys.dual
		where exists ( select 1
		from PER_ORG_STRUCTURE_ELEMENTS x
		where x.business_group_id = p_business_group_id);
		--
		if SQL%ROWCOUNT >0 THEN
		  hr_utility.set_message(801,'HR_6569_ORG_IN_HIERARCHY');
		  hr_utility.raise_error;
		end if;
		exception
		when NO_DATA_FOUND THEN
		  null;
		end;
	end;
end if;
--
-- Now do all Organization specific checks.
begin
--
-- Changed 02-Oct-99 SCNair (per_positions to hr_all_positions_f) date tracked position requirement
--
-- Do Any rows Exist in HR_ALL_POSITIONS_F.
hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check',8);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from HR_ALL_POSITIONS_F x
where x.organization_id = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6557_ORG_POSITIONS_EXIST');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
--
begin
-- Do Any rows Exist in PER_ORG_STRUCTURE_ELEMENTS.
hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check',9);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_ORG_STRUCTURE_ELEMENTS x
where x.organization_id_child = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6569_ORG_IN_HIERARCHY');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Do Any rows Exist in PER_ORG_STRUCTURE_ELEMENTS.
hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check',10);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_ORG_STRUCTURE_ELEMENTS x
where x.organization_id_parent = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6569_ORG_IN_HIERARCHY');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check',11);
  select '1'
  into l_test_func
  from sys.dual   where exists ( select 1
        from per_assignments_f x
        where x.source_organization_id = p_organization_id);
  if SQL%ROWCOUNT >0 THEN
    hr_utility.set_message(801,'HR_7333_ORG_ASSIGNMENTS_EXIST');

    hr_utility.raise_error;
  end if;
exception
  when NO_DATA_FOUND THEN
    null;
end;
--
begin
hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check',12);
  select '1'
  into l_test_func
  from sys.dual   where exists ( select 1
        from per_assignments_f x
        where x.organization_id = p_organization_id);
  if SQL%ROWCOUNT >0 THEN
    hr_utility.set_message(801,'HR_7333_ORG_ASSIGNMENTS_EXIST');
    hr_utility.raise_error;
  end if;
exception
  when NO_DATA_FOUND THEN
    null;
end;
--
begin
hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check',13);
  select '1'
  into l_test_func
  from sys.dual   where exists ( select 1
        from per_recruitment_activities x
        where x.run_by_organization_id = p_organization_id);
  if SQL%ROWCOUNT >0 THEN
    hr_utility.set_message(801,'HR_7336_ORG_REC_ACT_EXIST');
    hr_utility.raise_error;
  end if;
exception
  when NO_DATA_FOUND THEN
    null;
end;
--
begin
hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check',14);
  select '1'
  into l_test_func
  from sys.dual   where exists ( select 1
        from per_vacancies x
        where x.organization_id = p_organization_id);
  if SQL%ROWCOUNT >0 THEN
    hr_utility.set_message(801,'HR_7337_ORG_VACANCIES');
    hr_utility.raise_error;
  end if;
exception
  when NO_DATA_FOUND THEN
    null;
end;
--
begin
hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check',15);
  select '1'
  into l_test_func
  from sys.dual   where exists ( select 1
        from per_events x
        where x.organization_run_by_id = p_organization_id);
  if SQL%ROWCOUNT >0 THEN
    hr_utility.set_message(801,'HR_7334_ORG_EVENTS_EXIST');
    hr_utility.raise_error;
  end if;
exception
  when NO_DATA_FOUND THEN
    null;
end;
--
begin
hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check',16);
  select '1'
  into l_test_func
  from sys.dual   where exists ( select 1
        from pay_element_links_f x
        where x.organization_id = p_organization_id);
  if SQL%ROWCOUNT >0 THEN
    hr_utility.set_message(801,'HR_7330_ORG_LINKS_EXIST');
    hr_utility.raise_error;
  end if;
exception
  when NO_DATA_FOUND THEN
    null;
end;
--
begin
hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check',16);
  select '1'
  into l_test_func
  from sys.dual   where exists ( select 1
        from pay_payrolls_f x
        where x.organization_id = p_organization_id);
  if SQL%ROWCOUNT >0 THEN
    hr_utility.set_message(801,'HR_7331_ORG_PAYROLLS_EXIST');
    hr_utility.raise_error;
  end if;
exception
  when NO_DATA_FOUND THEN
    null;
end;
--
begin
hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check',17);
  select '1'
  into l_test_func
  from sys.dual   where exists ( select 1
        from pay_wc_funds x
        where x.carrier_id = p_organization_id);
  if SQL%ROWCOUNT >0 THEN
    hr_utility.set_message(801,'HR_7332_WC_FUNDS_EXIST');
    hr_utility.raise_error;
  end if;
exception
  when NO_DATA_FOUND THEN
    null;
end;
--
begin
hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check',18);
  select '1'
  into l_test_func
  from sys.dual   where exists ( select 1
        from per_budget_elements x
        where x.organization_id = p_organization_id);
  if SQL%ROWCOUNT >0 THEN
    hr_utility.set_message(801,'HR_7335_ORG_BUDGET_ELEMENTS');
    hr_utility.raise_error;
  end if;
exception
  when NO_DATA_FOUND THEN
    null;
end;
--
begin
hr_utility.set_location('hr_org_pre_delete.hr_org_predel_check',20);
  select '1'
  into l_test_func
  from sys.dual   where exists ( select 1
        from per_security_profiles x
        where x.organization_id = p_organization_id);
  if SQL%ROWCOUNT >0 THEN
    hr_utility.set_message(801,'HR_7339_ORG_SEC_PROFILE');
    hr_utility.raise_error;
  end if;
exception
  when NO_DATA_FOUND THEN
    null;
end;
--
end hr_org_predel_check;
--------------------- END: hr_org_predel_check ---------------------------------
--
--------------------- BEGIN: hr_strong_bg_chk ------------------------------
procedure hr_strong_bg_chk(
p_organization_id INTEGER) is
/*
  NAME
    hr_strong_bg_chk
  DESCRIPTION
    Test to see whether an Organization can become a business group.
  PARAMETERS
    p_organization_id : Id of Organization to be updated to business group.
*/
-- Storage Variable.
l_test_func varchar2(60);
--
begin
--

begin
-- Doing check on PAY_ELEMENT_LINKS_F.
hr_utility.set_location('hr_org_pre_delete.hr_strong_bg_chk',1);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PAY_ELEMENT_LINKS_F x
where x.ORGANIZATION_ID = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6719_BG_ELE_LINK');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Doing check on PAY_PAYROLLS_F.
hr_utility.set_location('hr_org_pre_delete.hr_strong_bg_chk',2);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PAY_PAYROLLS_F x
where x.ORGANIZATION_ID = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6717_BG_PAYROLL_EXIST');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Doing check on PER_ASSIGNMENTS_F.
hr_utility.set_location('hr_org_pre_delete.hr_strong_bg_chk',3);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_ASSIGNMENTS_F x
where x.SOURCE_ORGANIZATION_ID = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6718_BG_ASS_EXIST');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Doing check on PER_ASSIGNMENTS_F.
hr_utility.set_location('hr_org_pre_delete.hr_strong_bg_chk',4);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_ASSIGNMENTS_F x
where x.ORGANIZATION_ID = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6718_BG_ASS_EXIST');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Doing check on PER_BUDGET_ELEMENTS.
hr_utility.set_location('hr_org_pre_delete.hr_strong_bg_chk',5);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_BUDGET_ELEMENTS x
where x.ORGANIZATION_ID = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6720_BG_BUDGET_ELE_EXIST');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Doing check on PER_EVENTS.
hr_utility.set_location('hr_org_pre_delete.hr_strong_bg_chk',6);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_EVENTS x
where x.ORGANIZATION_RUN_BY_ID = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6721_BG_EVENTS_EXIST');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Doing check on PER_ORG_STRUCTURE_ELEMENTS.
hr_utility.set_location('hr_org_pre_delete.hr_strong_bg_chk',7);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_ORG_STRUCTURE_ELEMENTS x
where x.ORGANIZATION_ID_PARENT = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6722_BG_ORG_HIER');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Doing check on PER_ORG_STRUCTURE_ELEMENTS.
hr_utility.set_location('hr_org_pre_delete.hr_strong_bg_chk',8);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_ORG_STRUCTURE_ELEMENTS x
where x.ORGANIZATION_ID_CHILD = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6722_BG_ORG_HIER');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
--
-- Changed 02-Oct-99 SCNair (per_positions to hr_all_positions_f) date tracked position requirement
--
-- Doing check on HR_ALL_POSITIONS_F.
hr_utility.set_location('hr_org_pre_delete.hr_strong_bg_chk',9);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from HR_ALL_POSITIONS_F x
where x.ORGANIZATION_ID = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6726_BG_POS_EXIST');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Doing check on PER_RECRUITMENT_ACTIVITIES.
hr_utility.set_location('hr_org_pre_delete.hr_strong_bg_chk',10);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_RECRUITMENT_ACTIVITIES x
where x.RUN_BY_ORGANIZATION_ID = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6723_BG_REC_ACT_EXIST');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Doing check on PER_SECURITY_PROFILES.
hr_utility.set_location('hr_org_pre_delete.hr_strong_bg_chk',11);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_SECURITY_PROFILES x
where x.ORGANIZATION_ID = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6724_BG_SEC_PROF_EXIST');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
begin
-- Doing check on PER_VACANCIES.
hr_utility.set_location('hr_org_pre_delete.hr_strong_bg_chk',12);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from PER_VACANCIES x
where x.ORGANIZATION_ID = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6725_BG_VAC_EXIST');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
end hr_strong_bg_chk;
--------------------- END: hr_strong_bg_chk -----------------------------------
END hr_org_pre_delete;

/
