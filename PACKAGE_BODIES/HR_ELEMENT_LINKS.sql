--------------------------------------------------------
--  DDL for Package Body HR_ELEMENT_LINKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ELEMENT_LINKS" as
/* $Header: pyelelnk.pkb 115.2 99/07/17 05:58:54 porting ship  $ */
--
 /*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1989 Oracle Corporation UK Ltd.,                *
   *                   Richmond, England.                           *
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
   ******************************************************************
--
    Name        : hr_element_links
--
    Description : This package holds procedures and functions related to the
                  following tables :
			PAY_ELEMENT_LINKS_F
--
    Uses        : hr_element_links
		  hr_input_values
    Used By     : n/a
--
    Test List
    ---------
    Procedure                     Name       Date        Test Id Status
    +----------------------------+----------+-----------+-------+--------------+
    chk_mutual_exclusivity        M Dyer     19-Jan-1993   1     Complete
    chk_mutual_exclusivity        M Dyer     20-Jan-1993   2     Complete
    +----------------------------+----------+-----------+-------+--------------+
    chk_element_links		  M Dyer     08-Feb-1993   1	 Complete
    chk_element_links		  M Dyer     21-Apr-1993   2	 Complete
    chk_element_links		  M Dyer     29-Apr-1993   3	 Complete
    +----------------------------+----------+-----------+-------+--------------+
    chk_upd_element_links	  M Dyer     08-Feb-1993   1	 Complete
    chk_upd_element_links	  M Dyer     21-Apr-1993   1	 Complete
    +----------------------------+----------+-----------+-------+--------------+
    chk_del_element_links	  M Dyer     09-Feb-1993   1	 Complete
    chk_del_element_links	  M Dyer     26-Mar-1993   2	 Complete
    +----------------------------+----------+-----------+-------+--------------+
    ins_3p_element_link		  M Dyer     09-Feb-1993   1	 Complete
    +----------------------------+----------+-----------+-------+--------------+
    upd_3p_element_links	  M Dyer     09-Feb-1993   1	 Complete
    +----------------------------+----------+-----------+-------+--------------+
    del_3p_element_links	  M Dyer     09-Feb-1993   1	 Complete
--
--
--
    Change List
    -----------
    Date         Name          Vers    Bug No     Description
    +-----------+-------------+-------+----------+-----------------------------+
     20-jan-1993  M Dyer         		  Increased length of local
						  variables on segment values
						  for mutual exclusivity.
     08-Feb-1993  M Dyer	30.1		  Added chk_element_links
						  and chk_upd_element_links
     09-Feb-1993  M Dyer	30.2		  Added chk_del_element_link
						  ins_3p_element_link
						  upd_3p_element_links
					   	  del_3p_element_links
     17-Feb-93    J.S.Hobbs     30.10             Altered insert_alu and
						  create_standard_entries_el.
     03-Mar-1993  J.S.Hobbs     30.11             Removed get_termination_date,
						  get_entry_start_date_qc and
						  create_rec_element_entry.
						  They all exist in hrentmnt
						  package.
     26-Mar-1993  M Dyer	30.12		  No delete allowed for element
						  links that have recurring
						  additional entries.
     21-Apr-1993  M Dyer	30.13		  Changes made to chk_element
						_links for distributed element
						_s.
     29-Apr-1993		30.14		Change made to chk_element_links
						to calculate end date.
     07-Jun-1993  J.S.Hobbs     30.23           Corrected
						create_standard_entries_el.
     21-Jun-1993  M Dyer	30.24		changes made to chk_mutual
						exclusivity to return end date
						of link. Now called from
						chk_element_link.
     22-Jul-1993  M Dyer	30.25   B112	If the costable type is
						distributed then the pay value
						only can be costed.
    					B113	If the costable type is
						distributed then an empty
						distribution set cannot be
						selected.
     17-Sep-1993  J.S.Hobbs     40.01/  B230/   Replaced
				30.28   X26	hrentmnt.get_termination_date
						with a call to
					    hr_entry.entry_asg_pay_link_dates
						as it is more comprehensive.
    05-Oct-1993  M Kaddir      40.2     X21       Changed chk_element_link
                                                  and chk_mutual_exclusivity
                                                  to include two new link
                                                  criteria:
                                                  -  Employment Category and
                                                  -  Pay Basis
    22-Oct-1993  J.S.Hobbs     40.3              -Changed ins_3p_element_link
						  to cope with two new
						  criteria ie. PAY_BASIS_ID and
						  EMPLOYMENT_CATEGORY.
                                                 -Removed
						  create_standard_entries_el
						  and recoded in hrentmnt with
						  a new prcoedure called
						  maintain_entries_el.
                                                 -Changed insert_alu so that
						  it uses
					  hr_entry.entry_asg_pay_link_dates.
	25-Jan-94 N Simpson			- Changed chk_mutual_exclusivity
						  to restrict element links
						  checked to the user's
						  business group. G525
	17-Feb-94 N Simpson		  Added procedure link_flag_updated and 						modified upd_3p_element_link
						to allow update of standard
						link flag from No to Yes, thus
						allowing changes to be made to
						the input value defaults before
						the creation of standard entries
	1 Mar 94	N Simpson B400		-- Added check that all
						mandatory input values have
						defaults, before creating
						standard entries.
--
	4 May 95	N Simpson B280150	Included location check in
						chk_mutual_exclusivity. The
						flag had been set but was not
						included in the test for
						exclusivity.
    ###########################################################################
--
    04-Mar-1994  C.Swan                           Moved from 10.0 as a result
                                                  of the 10->10G merge.
    07-Mar-1994  C.Swan                           Removed leading "####" from
                                                  above line, due to
                                                  Autoinstall objecting.
--
	23 Mar 94	N Simpson	B445	amended set_locations which
						incorrectly stated the package
						name, and added an extra
						set_location call
    23-Nov-1994  J.S.Hobbs  G1707  Replaced fnd_common_lookups with hr_lookups.
    24-Nov-1994  R.M.Fine   G1725  Suppressed index on business_group_id
    07-Feb-1996  N.Simpson  G336502 Redirected some procedures to the new package
				    pay_element_links_pkg. This will fix the bug
				    and avoid the need for dual maintenance in
				    the future. Ideally, this package will
				    eventually be dropped completely.
    24-FEB-1999  J. Moyano  115.1   MLS changes. Procedures upd_3p_element_links
                                    and chk_link_input_values affected.
                                    Has this package been drooped already?

                                                                             */
--
 /*
 NAME
	chk_mutual_exclusivity
 DESCRIPTION
	This function checks that the elements are mutually exclusive. This
	means that all links to an element must be guaranteed to be exclusive
	of eachother. If they are not then there is a danger that someone
	will be assigned to the same element twice in different ways
 NOTES
   	18-JUN-1993 M Dyer:
	Date out parameter added. This returns the latest date on which the
	element is still mutually exclusive. The validation end date will be
	returned if the link is found to be exclusive of all other links. The
	procedure will be called from chk_element_links which brings it into
	line with the other validation procedures.
	07-FEB-1996 N Simpson
	Removed code and redirected to new package pay_element_links_pkg to
	avoid dual maintenance.
 */
--
PROCEDURE
	chk_mutual_exclusivity(p_element_type_id 	in number,
			p_element_link_id		in number,
			p_validation_start_date 	in date,
			p_validation_end_date		in date,
			p_greatest_end_date		out date,
			p_organization_id		in number,
			p_people_group_id		in number,
			p_job_id			in number,
			p_position_id			in number,
			p_grade_id			in number,
			p_location_id 			in number,
			p_link_to_all_payrolls_flag	in varchar2,
			p_payroll_id			in number,
                        p_employment_category           in varchar2,
                        p_pay_basis_id                  in number,
			p_business_group_id		in number)  is
--
begin
--
p_greatest_end_date := pay_element_links_pkg.max_end_date (
	--
	p_element_type_id,
	p_element_link_id,
	p_validation_start_date,
	p_validation_end_date,
	p_organization_id,
	p_people_group_id,
	p_job_id,
	p_position_id,
	p_grade_id,
	p_location_id,
	p_link_to_all_payrolls_flag,
	p_payroll_id,
	p_employment_category,
	p_pay_basis_id,
	p_business_group_id);
	--
end chk_mutual_exclusivity;
--
--
 /*
 NAME
       get_greatest_end_date  (OBSOLETE)
*/
--
FUNCTION	get_greatest_end_date(p_element_type_id	 in number,
				      p_business_group_id in number,
				      p_link_to_all_payrolls_flag in varchar2,
				      p_payroll_id in number,
				      p_greatest_link_date in date)
						return date is
--
proc_name CONSTANT varchar2(40) := 'hr_element_links.get_greatest_end_date';
--
begin
--
hr_utility.set_location( proc_name, 1);
--
-- This procedure is obsolete. The call should be redirected to
-- pay_element_links_pkg.max_end_date. Left error message in case there are any outstanding
-- calls that I missed.
--
hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
hr_utility.set_message_token ('PROCEDURE',proc_name);
hr_utility.set_message_token ('STEP','1');
hr_utility.raise_error;
--
end get_greatest_end_date;
--
 /*
 NAME
	chk_element_links
 DESCRIPTION
	This procedure checks to see if any distributed links are themselves in
	distribution sets
 */
--
PROCEDURE 	chk_element_links(p_element_type_id 	in number,
                                  p_element_link_id     in number,
				  p_val_start_date	in date,
				  p_val_end_date	in out date,
				  p_business_group_id	in number,
				  p_legislation_code 	in varchar2,
				  p_costable_type	in varchar2,
                        	  p_organization_id     in number,
                        	  p_people_group_id     in number,
                        	  p_job_id              in number,
                        	  p_position_id         in number,
                        	  p_grade_id            in number,
                        	  p_location_id         in number,
				  p_payroll_id		in number,
				  p_link_to_all_payrolls_flag in varchar2,
				  p_element_set_id	in number,
				  p_balancing_keyflex_id in number,
				  p_classification_id	in number,
                                  p_employment_category in varchar2,
                                  p_pay_basis_id        in number) is
--
	l_validation_ok varchar2(1) := 'Y';
	l_max_element_date date;
	l_max_payroll_date date;
begin
--
        Hr_utility.set_location('hr_element_links.chk_element_links', 1);
--
  -- Element links cannot be distributed if the element is part of a
  -- distribution set.
  if p_costable_type = 'D' then
--
	hr_utility.set_location('hr_element_links.chk_element_links', 2);
--
	if p_element_set_id is null then
--
             hr_utility.set_message(801,'PAY_6699_LINK_NO_DIST_SET');
             hr_utility.raise_error;
--
	end if;
--
	begin
--
        select 'N'
	into l_validation_ok
	from sys.dual
	where exists
		(select 1
		 from pay_element_set_members esm,
		 pay_element_sets es
		 where esm.element_type_id = p_element_type_id
		 and es.element_set_id = esm.element_set_id
		 and es.element_set_type = 'D');
--
	exception
		when NO_DATA_FOUND then NULL;
        end;
--
	if l_validation_ok = 'N' then
             hr_utility.set_message(801,'PAY_6462_LINK_DIST_IN_DIST');
             hr_utility.raise_error;
	end if;
--
  -- The distribution set must be credit or debit according to what the
  -- primary classification is of the element.
--
	begin
--
	select 'N'
	into l_validation_ok
	from sys.dual
	where exists
		(select 1
		from pay_element_set_members esm,
		pay_element_classifications ec,
		pay_element_classifications ec2
		where ec.classification_id = p_classification_id
		and esm.element_set_id = p_element_set_id
		and ec2.classification_id = esm.classification_id
		and ec2.costing_debit_or_credit <> ec.costing_debit_or_credit);
--
	exception
		when NO_DATA_FOUND then null;
	end;
--
	if l_validation_ok = 'N' then
             hr_utility.set_message(801,'PAY_6700_LINK_CRE_OR_DEB');
             hr_utility.raise_error;
	end if;
--
  -- If the link is distributed then the distribution set must have some
  -- Elements in it.
--
	begin
--
	select 'N'
	into l_validation_ok
	from pay_element_sets es
	where es.element_set_id = p_element_set_id
	and exists
		(select 1
		from pay_element_set_members esm,
		pay_element_types_f et
		where es.element_set_id = esm.element_set_id
		and esm.element_type_id = et.element_type_id
		and p_val_start_date between
			et.effective_start_date and et.effective_end_date);
--
	exception
		when NO_DATA_FOUND then
                hr_utility.set_message(801,'PAY_6916_LINK_EMPTY_DIST_SET');
                hr_utility.raise_error;
	end;
    end if;
--
  -- If the link is costed, Fixed costed or Distributed then the balancing
  -- keyflex must be populated.
--
    if (p_costable_type <> 'N') and
    (p_balancing_keyflex_id is null) then
--
             hr_utility.set_message(801,'PAY_6698_LINK_BAL_KEYFLEX_MAN');
             hr_utility.raise_error;
--
    end if;
--
  -- Determine the greatest end date of the element link
--
	p_val_end_date := pay_element_links_pkg.max_end_date (
			p_element_type_id,
                        p_element_link_id,
                        p_val_start_date,
                        p_val_end_date,
                        p_organization_id,
                        p_people_group_id,
                        p_job_id,
                        p_position_id,
                        p_grade_id,
                        p_location_id,
                        p_link_to_all_payrolls_flag,
                        p_payroll_id,
                        p_employment_category,
                        p_pay_basis_id,
			p_business_group_id);
--
end chk_element_links;
--
--
 /*
 NAME
	chk_upd_element_links
 DESCRIPTION
	The costable type of a link can only be updated over all time if there
	are no entries in existence for this link.
 */
--
PROCEDURE	chk_upd_element_links(p_element_link_id	in number,
				      p_update_mode 	in varchar2,
				      p_val_start_date  in date,
				      p_val_end_date	in date,
				      p_old_costable_type in varchar2,
				      p_costable_type   in varchar2) is
--
	l_validation_ok varchar2(1) := 'Y';
	l_validation_not_ok varchar2(1) := 'N';
--
begin
  -- We need to check to see if costable type is begin updated.
  -- This cannot happen if there are any entries in existence for this link
  -- and must happen over all time for the link.
--
--
	hr_utility.set_location('hr_element_links.chk_upd_element_links', 1);
--
  If p_old_costable_type <> p_costable_type then
	if p_update_mode <> 'CORRECTION' then
             hr_utility.set_message(801,'PAY_6466_LINK_NO_COST_UPD2');
             hr_utility.raise_error;
	end if;
--
	begin
--
	select 'N'
	into l_validation_ok
	from sys.dual
	where exists
		(select 1
		from pay_element_entries_f ee
		where p_element_link_id = ee.element_link_id);
--
	exception
		when NO_DATA_FOUND then NULL;
	end;
--
	if l_validation_ok = 'N' then
             hr_utility.set_message(801,'PAY_6465_LINK_NO_COST_UPD1');
             hr_utility.raise_error;
	end if;
--
--
	hr_utility.set_location('hr_element_links.chk_upd_element_links', 2);
--
	begin
--
           select 'Y'
           into l_validation_not_ok
           from sys.dual
           where p_val_start_date =
                (select min(effective_start_date)
                from pay_element_links_f
                where p_element_link_id = element_link_id)
           and p_val_end_date =
                (select max(effective_end_date)
                from pay_element_links_f
                where p_element_link_id = element_link_id);
--
	exception
		when NO_DATA_FOUND then NULL;
	end;
--
        if l_validation_not_ok = 'N' then
             hr_utility.set_message(801,'PAY_6466_LINK_NO_COST_UPD2');
             hr_utility.raise_error;
        end if;
    end if;
--
end chk_upd_element_links;
--
--
 /*
 NAME
	chk_del_element_links
 DESCRIPTION
	This procedure checks to see whether element links can be deleted.
	They cannot be deleted if there are any non recurring entries in the
	validation period. They can be deleted if any recurring entries exist
	but this will result in these entries being lost forever and a warning
	message will be given to this effect.
 */
--
PROCEDURE	chk_del_element_link(p_element_link_id	in varchar2,
				     p_val_start_date	in date,
				     p_val_end_date 	in date,
				     p_warning_message  in out varchar2) is
--
	l_delete_ok	varchar2(1) := 'Y';
--
begin
--
	hr_utility.set_location('hr_element_links.chk_del_element_link', 1);
--
--
  -- No delete is allowed if there are non-recurring entries in the validation
  -- period.
    begin
--
    select 'N'
    into l_delete_ok
    from sys.dual
    where exists
	(select 1
	from pay_element_types_f et,
	     pay_element_entries_f ee,
	     pay_element_links_f el
	where p_element_link_id = el.element_link_id
	and   el.element_type_id = et.element_type_id
	and   et.processing_type = 'N'
	and   ee.element_link_id = el.element_link_id
	and   p_val_start_date <= ee.effective_end_date
	and   p_val_end_date >= ee.effective_start_date);
--
	exception
		when NO_DATA_FOUND then NULL;
	end;
--
        if l_delete_ok = 'N' then
             hr_utility.set_message(801,'PAY_6467_LINK_NO_DEL_LINKS');
             hr_utility.raise_error;
        end if;
--
  -- Even if the element type is recurring there may have been additional
  -- entries created. These will prevent delete.
--
  begin
--
    select 'N'
    into l_delete_ok
    from sys.dual
    where exists
        (select 1
	 from pay_element_entries_f ee
	 where p_element_link_id = ee.element_link_id
	and   ee.entry_type = 'D'
        and   p_val_start_date <= ee.effective_end_date
        and   p_val_end_date >= ee.effective_start_date);
--
	exception
		when NO_DATA_FOUND then NULL;
	end;
--
	if l_delete_ok = 'N' then
             hr_utility.set_message(801,'PAY_6639_LINK_NO_DEL_ADD_ENTRY');
             hr_utility.raise_error;
	end if;
--
end chk_del_element_link;
--
 PROCEDURE insert_alu(p_mode                  varchar2,
		      p_id_flex_num           number,
		      p_business_group_id     number,
		      p_people_group_id       number,
		      p_element_link_id       number,
		      p_assignment_id         number,
		      p_effective_start_date  date,
		      p_effective_end_date    date) is
--
begin
--
 pay_asg_link_usages_pkg.insert_ALU (
	--
	p_business_group_id,
	p_people_group_id,
	p_element_link_id,
	p_effective_start_date,
	p_effective_end_date);
	--
 end insert_alu;
--
--
 /*
 NAME
	ins_costing_segments
 DESCRIPTION
	This procedure will update the pay_cost_allocation_keyflex table with
	the concatenated costing keyflexes. It should always be called when
	a new costed, fixed or distributed element link is created and also
	when one of these fields have been updated.
	*/
PROCEDURE	ins_costing_segments(
				     p_cost_allocation_keyflex_id varchar2,
				     p_displayed_cost_keyflex varchar2,
				     p_balancing_keyflex_id varchar2,
				     p_displayed_balancing_keyflex varchar2) is
--
begin
--
  -- We only need to do the updating if there is a costing keyflex there.
--
    if p_cost_allocation_keyflex_id is not null then
--
	update pay_cost_allocation_keyflex
	set concatenated_segments = p_displayed_cost_keyflex
	where cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
	and concatenated_segments is null;
--
    end if;
--
    if p_balancing_keyflex_id is not null then
--
	update pay_cost_allocation_keyflex
	set concatenated_segments = p_displayed_balancing_keyflex
	where cost_allocation_keyflex_id = p_balancing_keyflex_id
	and concatenated_segments is null;
--
    end if;
--
end ins_costing_segments;
--
 /*
 NAME
	ins_3p_element_link
 DESCRIPTION
	This procedure inserts link input values when an element link is
	created. It will also insert Assignment link usages and Standard
	recurring entries.
 */
--
procedure ins_3p_element_link
(
 p_element_link_id	     in number,
 p_element_type_id	     in number,
 p_val_start_date	     in date,
 p_val_end_date		     in date,
 p_standard_link_flag	     in varchar2,
 p_payroll_id		     in number,
 p_link_to_all_payrolls_flag in varchar2,
 p_job_id		     in number,
 p_grade_id		     in number,
 p_position_id		     in number,
 p_organization_id	     in number,
 p_people_group_id	     in number,
 p_location_id		     in number,
 p_pay_basis_id              in number,
 p_employment_category       in varchar2,
 p_qual_age		     in number,
 p_qual_length_of_service    in number,
 p_qual_units		     in varchar2,
 p_costable_type	     in varchar2,
 p_pay_value_name	     in varchar2,
 p_id_flex_num		     in number,
 p_business_group_id	     in number,
 p_legislation_code	     in varchar2
) is
--
-- Cursor returns a row if a mandatory input value for a standard link has no
-- default value
--
cursor csr_link_defaults is
	select	1
	from	pay_link_input_values_f	LINK,
		pay_input_values_f	TYPE
	where	link.element_link_id	= p_element_link_id
	and	link.input_value_id	= type.input_value_id
	and	type.mandatory_flag	= 'Y'
	and	p_standard_link_flag	= 'Y'
	and	((link.default_value is null and type.hot_default_flag = 'N')
		or (type.default_value is null and link.default_value is null
			and type.hot_default_flag = 'Y'));
--
v_dummy	number;
--
begin
--
	hr_utility.set_location('hr_element_links.ins_3p_element_link', 1);
--
  -- Call create link input value
        hr_input_values.create_link_input_value(
                        'INSERT_LINK',
                        p_element_link_id,
                        NULL,
                        NULL,
                        p_costable_type,
                        p_val_start_date,
                        p_val_end_date,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        p_legislation_code,
                        p_pay_value_name,
			p_element_type_id);
--
--
	hr_utility.set_location('hr_element_links.ins_3p_element_link', 2);
--
 pay_asg_link_usages_pkg.insert_ALU (
	--
	p_business_group_id,
	p_people_group_id,
	p_element_link_id,
	p_val_start_date,
	p_val_end_date);
--
--
	hr_utility.set_location('hr_element_links.ins_3p_element_link', 3);
--
-- Error if standard link has a mandatory input value with no default.
--
 open csr_link_defaults;
 fetch csr_link_defaults into v_dummy;
 if csr_link_defaults%found then
   hr_utility.set_message (801,'HR_7095_INPVAL_NO_STD_DEFLT');
   hr_utility.raise_error;
 end if;
 close csr_link_defaults;
--
	hr_utility.set_location('hr_element_links.ins_3p_element_link', 4);
--
-- Create standard entries
--
 if p_standard_link_flag = 'Y' then
   hrentmnt.maintain_entries_el
     (p_business_group_id,
      p_element_link_id,
      p_element_type_id,
      p_val_start_date,
      p_val_end_date,
      p_payroll_id,
      p_link_to_all_payrolls_flag,
      p_job_id,
      p_grade_id,
      p_position_id,
      p_organization_id,
      p_location_id,
      p_pay_basis_id,
      p_employment_category,
      p_people_group_id);
 end if;
--
end ins_3p_element_link;
--
--
 /*
 NAME
	upd_3p_element_link
 DESCRIPTION
	This procedure updates the costing flag on the link input values
	according to the costable type on the element link.
 */
--
PROCEDURE	upd_3p_element_links(p_element_link_id	in number,
				     p_val_start_date	in date,
				     p_val_end_date	in date,
				     p_pay_value_name 	in varchar2,
				     p_old_costable_type  in varchar2,
				     p_costable_type	in varchar2,
					p_payroll_id		number,
					p_business_group_id	number,
					p_location_id		number,
					p_grade_id		number,
					p_link_to_all_payrolls_flag	varchar2,
					p_organization_id	number,
					p_position_id		number,
					p_job_id		number,
					p_element_type_id	number,
					p_pay_basis_id		number,
					p_employment_category	number,
					p_people_group_id	number,
					p_old_link_flag	in varchar2,
					p_link_flag	in varchar2) is
--
begin
  -- If the costable type is updated from costed or Fixed to Distributed or
  -- not costed then we need to make all the link input values not costed.
--
	hr_utility.set_location('hr_element_links.upd_3p_element_link', 1);
--
  if (p_old_costable_type = 'C' or p_old_costable_type = 'F')
	and (p_costable_type = 'D' or p_costable_type = 'N') then
--
	update pay_link_input_values_f
	set costed_flag = 'N'
	where costed_flag = 'Y'
	and p_element_link_id = element_link_id;
--
  -- If the costable type is changed from non_costed or distributed to fixed or
  -- costed then the pay_value will become costed.
  elsif (p_old_costable_type = 'D' or p_old_costable_type = 'N') and
	(p_costable_type = 'F' or p_costable_type = 'C') then
--
	update pay_link_input_values_f liv
	set liv.costed_flag = 'Y'
	where p_element_link_id = liv.element_link_id
	and liv.input_value_id =
		(select iv.input_value_id
		from pay_input_values_f_tl iv_tl,
                     pay_input_values_f iv
		where liv.input_value_id = iv.input_value_id
                and iv.input_value_id = iv_tl.input_value_id
		and iv_tl.name = p_pay_value_name
                and userenv('LANG') = iv_tl.language
		and p_val_start_date between
		iv.effective_start_date and iv.effective_end_date);
--
  end if;
--
	hr_utility.set_location('hr_element_links.upd_3p_element_link', 2);
--
--  Create standard entries if standard link flag is updated to 'Y'
--
  if p_old_link_flag = 'N' and p_link_flag = 'Y' then
    hr_element_links.link_flag_updated (p_element_link_id);
    hrentmnt.maintain_entries_el
     (p_business_group_id,
      p_element_link_id,
      p_element_type_id,
      p_val_start_date,
      p_val_end_date,
      p_payroll_id,
      p_link_to_all_payrolls_flag,
      p_job_id,
      p_grade_id,
      p_position_id,
      p_organization_id,
      p_location_id,
      p_pay_basis_id,
      p_employment_category,
      p_people_group_id);
  end if;
--
end upd_3p_element_links;
--
PROCEDURE	delete_entry_values(
                                p_element_entry_id       in number,
                                p_delete_mode           in varchar2,
				p_val_session_date	in date,
                                p_val_start_date        in date,
                                p_val_end_date          in date) is
--
begin
--
 if p_delete_mode = 'ZAP' then
--
	delete from pay_element_entry_values_f
	where element_entry_id = p_element_entry_id;
--
 elsif p_delete_mode = 'DELETE' then
--
--
	hr_utility.set_location('hr_element_links.entry_values', 1);
--
	-- delete all future records
	delete from pay_element_entry_values_f
	where element_entry_id = p_element_entry_id
	and effective_start_date > p_val_session_date;
--
	-- update current records so that the end date is the session date
    	update pay_element_entry_values_f
    	set effective_end_date = p_val_session_date
    	where element_entry_id = p_element_entry_id
    	and p_val_session_date between
	effective_start_date and effective_end_date;
--
end if;
--
 -- Element entry_values will not be 'opened up' on delete next change
--
end delete_entry_values;
--
 /*
 NAME
	del_3p_element_link
 DESCRIPTION
	This procedure deletes link input values in line with the deletion on
	element link. It will also delete Assignment link usages and recurring
	entries.
 */
--
PROCEDURE	del_3p_element_links(
				p_element_link_id 	in number,
				p_delete_mode		in varchar2,
				p_val_session_date	in date,
				p_val_start_date	in date,
				p_val_end_date		in date,
				p_id_flex_num		in number,
				p_business_group_id	in number,
				p_people_group_id	in number) is
--
	v_end_of_time	date := to_date('31/12/4712','DD/MM/YYYY');
	v_alu_start_date date;
	v_alu_end_date date;
--
	l_on_final_record 	varchar2(1) := 'N';
  -- Cursor to select all the entries which are available for delete
  -- This will lock these records and determine which entry values are
  -- Going to be deleted.
  CURSOR 	get_element_entries(
				p_element_link_id 	number,
				p_val_start_date	date,
				p_val_end_date		date) is
		select ee.element_entry_id element_entry_id,
		       ee.effective_start_date start_date,
		       ee.effective_end_date end_date
		from pay_element_entries_f ee
		where p_element_link_id = ee.element_link_id
		and p_val_start_date <= ee.effective_end_date
		and p_val_end_date >= ee.effective_start_date
		for update;
--
begin
--
	hr_utility.set_location('hr_element_links.del_3p_element_link', 1);
--
  for entry_rec in get_element_entries(
	                        p_element_link_id,
                                p_val_start_date,
                                p_val_end_date) loop
--
	hr_element_links.delete_entry_values(
				entry_rec.element_entry_id,
				p_delete_mode,
				p_val_session_date,
				entry_rec.start_date,
				entry_rec.end_date);
  end loop;
--
--
 if p_delete_mode = 'ZAP' then
--
	delete from pay_link_input_values_f
	where element_link_id = p_element_link_id;
--
	delete from pay_element_entries_f
	where element_link_id = p_element_link_id;
--
	delete from pay_assignment_link_usages_f
	where element_link_id = p_element_link_id;
--
 elsif p_delete_mode = 'DELETE' then
--
--
	hr_utility.set_location('hr_element_links.del_3p_element_link', 2);
--
	-- delete all future records
	delete from pay_link_input_values_f
	where element_link_id = p_element_link_id
	and effective_start_date > p_val_session_date;
--
	-- update current records so that the end date is the session date
    	update pay_link_input_values_f
    	set effective_end_date = p_val_session_date
    	where element_link_id = p_element_link_id
    	and p_val_session_date between
	effective_start_date and effective_end_date;
--
--
	hr_utility.set_location('hr_element_links.del_3p_element_link', 3);
--
--
	-- delete all future records
	delete from pay_element_entries_f
	where element_link_id = p_element_link_id
	and effective_start_date > p_val_session_date;
--
	-- update current records so that the end date is the session date
    	update pay_element_entries_f
    	set effective_end_date = p_val_session_date
    	where element_link_id = p_element_link_id
    	and p_val_session_date between
	effective_start_date and effective_end_date;
--
	hr_utility.set_location('hr_element_links.del_3p_element_link', 4);
--
	-- delete all future records
	delete from pay_assignment_link_usages_f
	where element_link_id = p_element_link_id
	and effective_start_date > p_val_session_date;
--
	-- update current records so that the end date is the session date
    	update pay_assignment_link_usages_f
    	set effective_end_date = p_val_session_date
    	where element_link_id = p_element_link_id
    	and p_val_session_date between
	effective_start_date and effective_end_date;
--
 -- DELETE_NEXT_CHANGE will only affect the input value records if we are on
 -- The final record of the element link. In this case the final input value
 -- records will need to be extended to the end of time.
 -- Element entries will not be 'opened up' on delete next change
--
 elsif p_delete_mode = 'DELETE_NEXT_CHANGE' then
--
--
	hr_utility.set_location('hr_element_links.del_3p_element_link', 5);
--
 begin
--
   select 'Y'
   into l_on_final_record
   from pay_element_links_f et1
   where p_element_link_id = et1.element_link_id
   and p_val_session_date between
	et1.effective_start_date and et1.effective_end_date
   and et1.effective_end_date =
	(select max(et2.effective_end_date)
	from pay_element_links_f et2
	where p_element_link_id = et2.element_link_id);
--
 exception
    when NO_DATA_FOUND then NULL;
 end;
--
    if l_on_final_record = 'Y' then
--
--
	hr_utility.set_location('hr_element_links.del_3p_element_link', 5);
--
	update pay_link_input_values_f iv1
	set iv1.effective_end_date = p_val_end_date
	where p_element_link_id = iv1.element_link_id
	and iv1.effective_end_date =
		(select max(iv2.effective_end_date)
		from pay_link_input_values_f iv2
		where iv2.link_input_value_id  = iv1.link_input_value_Id);
--
   end if;
--
 -- If we are to do 'NEXT_CHANGE_DELETE' on the ALUs we need to delete all ALUs
 -- and re_insert them.
--
  delete from pay_assignment_link_usages_f
  where element_link_id = p_element_link_id;
--
  select min(effective_start_date), greatest(max(effective_end_date),p_val_end_date)
  into v_alu_start_date, v_alu_end_date
  from pay_element_links_f
  where element_link_id = p_element_link_id;
--
--
 pay_asg_link_usages_pkg.insert_ALU (
	--
	p_business_group_id,
	p_people_group_id,
	p_element_link_id,
	v_alu_start_date,
	v_alu_end_date);
--
-- No 'FUTURE_CHANGE_DELETE' allowed.
--
   end if;
--
end del_3p_element_links;
--
/*	TITLE
	chk_link_input_values
	DESCRIPTION
	This procedure checks against the corresponding input value to ensure
	that the validation is correct for the link input value. This includes
	hot defaulted values.
*/
--
PROCEDURE	chk_link_input_values(
			p_input_value_id in numbeR,
			p_legislation_code in varchar2,
			p_costable_type in varchar2,
			p_costed_flag	in varchar2,
			p_validation_start_date in datE,
			p_validation_end_date in datE,
			p_min_value in varchar2,
			P_Max_value in varchar2,
			p_default_value in varchar2,
			p_warning_or_error in varchar2) is
--
	L_Validation_check	varchar2(1) := 'N';
	proc_name COnstant 	VArchar2(40) := 'chk_link_input_values';
--
  -- Cursor to select details of input values.
CURSOR get_input_value(p_input_value	number,
			p_validation_start_date date,
			p_validation_end_date date) iS
    	select iV.Lookup_type lookup_typE,
		iv_tl.name name,
		iv.formula_id formula_iD,
		iv.default_value default_valuE,
		iv.min_value min_valuE,
		iv.max_value max_valuE,
		iv.hot_default_flag hot_default_flag
	from    pay_input_values_f_tl iv_tl,
                pay_input_values_f iv
	where 	iv.input_value_id = iv_tl.input_value_id
        and     iv.input_value_id = p_input_value_id
        and     userenv('LANG') = iv_tl.language
	and 	iv.effective_start_date <= p_validation_end_date
	and 	iv.effective_end_date >= p_validation_start_date;
begiN
--
	hr_utility.set_location(proc_name, 1);
	hr_utility.trace(to_char(p_validation_start_date));
	hr_utility.trace(to_char(p_validation_end_date));
--
  -- First we need to get some details about the input value.
--
    FOR iv_rec in get_input_value(p_input_value_id,
					p_validation_start_date,
					p_validation_end_date) loop
	-- We have retrieved a date-tracked record from the input values
	-- now we need to check it for validity.
	-- First, if formula or lookuP vaLIDation is specified then there can be
	-- no MAX or min
	if ((iV_rec.formula_iD is not null) or
	   (iv_rec.lookup_typE Is not null)) and
		   ((P_max_value is not NULL) or
		   (p_min_value is not NULL)) THEN
--
		    HR_utility.sET_message(801, 'PAY_6170_INPVAL_VAL_COMB');
		    hr_utility.raise_error;
--
	end if;
--
	hr_utility.set_location(proc_name, 2);
	-- if there is a default specified for a lookup validated input value
	-- then we must check to see if it is valid.
	if (iv_rec.lookup_type is not null) and
	   (p_default_value is not null) then
--
	    begin
--
		select 'Y' into
		l_validation_check
		from sys.dual
		where exists
			(select 1
			from  hr_lookups
			where lookup_type = iv_rec.lookup_type
			and lookup_code  = p_default_value);
--
	    exception
		when NO_DATA_FOUND then null;
	    end;
--
	    if L_Validation_check = 'N' then
--
		    HR_utility.set_message(801, 'PAY_6171_INPVAL_NO_LOOKUP');
		    hr_utility.raise_error;
--
	    end if;
--
	end if;
--
	hr_utility.set_location(proc_name, 3);
  -- If the hot default flag is yes we need to check for the max, min and
  -- default values being less than 59 characters. This is to allow for
  -- quotes being put round them at the lower level
  if (iv_rec.hot_default_flag = 'Y') and
     ((length(p_default_value) > 58) or
      (length(p_min_value) > 58) or
      (length(p_max_value) > 58)) then
--
     hr_utility.set_message(801,'PAY_6616_INPVAL_HOT_LESS_58');
     hr_utility.raise_error;
--
  end if;
--
	   -- If the costable type is 'D' then only the pay value can be
	   -- be costed
	   if p_costable_type = 'D' and
		iv_rec.name <> hr_input_values.get_pay_value_name
					(p_legislation_code) and
		p_costed_flag = 'Y' then
--
                    HR_utility.set_message(801, 'PAY_6404_INPVAL_NO_COST_LINK');
                    hr_utility.raise_error;
--
           end if;
--
	end loop;
--
	-- if either max or min is entered then there must be a warning or error
	-- flag
	if ((p_min_value is not null) or
	   (p_max_value is not null)) and
	   (p_warning_or_error is null) then
--
		    HR_utility.set_message(801, 'PAY_6170_INPVAL_VAL_COMB');
		    hr_utility.raise_error;
--
	end if;
--
end chk_link_input_values;
--
procedure LINK_FLAG_UPDATED (p_link_id	number) is
--
v_dummy	number(1);
--
cursor csr_element_entries is
	select	1
	from	pay_element_entries_f
	where	element_link_id	= p_link_id;
--
begin
--
open csr_element_entries;
fetch csr_element_entries into v_dummy;
if csr_element_entries%found then
  close csr_element_entries;
  hr_utility.set_message (801,'HR_7089_ELEMENTS_ENTRIES_EXIST');
  hr_utility.raise_error;
end if;
close csr_element_entries;
--
end link_flag_updated;
--
end hr_element_links;

/
