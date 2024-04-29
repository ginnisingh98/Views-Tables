--------------------------------------------------------
--  DDL for Package Body PAY_TEMPLATE_IVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TEMPLATE_IVS" AS
/* $Header: pyaddivs.pkb 115.2 2003/04/03 17:55:28 ekim ship $ */
/*
Copyright 1996
Oracle Corporation
Redwood Shores, California 94065
USA

Filename     : pyaddivs.pkb

Description  : Design for API enabling addition of an input value
               over the lifetime of an EXISTING element type.

Change History
-----------------
Date        Name       Vers    Bug No   Description
----------- ---------- ------  -------  --------------------------
05-Aug-1996 hparicha   40.0             Created.
06-Jun-1997 sxshah     40.3             Moved Whenever SQLERROR to top.
				                        This script did not compile.!!
03-Apr-2003 ekim       115.2   2886771  Changed hr_utility message to reflect
                                        package name pay_template_ivs rather
                                        than hr_input_values.
                                        Added gscc fix.
======================================================================

I. REQUIREMENTS DEFINITION

An ongoing upgrade issue with US Oracle Payroll has been needing to
change, fix, or enhance template Earnings and Deductions which
ALREADY EXIST on the customer account - ie. a live account.

The solution will be to provide the new or changed functionality
transparently to the customer - without interruption to normal operation
and without (or with minimal) manual intervention from the users.


II. CURRENT DIFFICULTIES, SCOPE DEFINITION

The major diffuculty with enhancing existing elements is the need to
add input values on elements.  The API pay_db_pay_setup.create_input_value
performs a check preventing addition of an input value if run results exist
for the element.  This has resulted in requiring the customer to
a. Rollback all existing payroll runs which included the existing element, OR
b. Create new elements such that the new functionality is enabled, and
replacing the use of existing elements with new ones.

Both options (a) and (b) are less than desirable, passable with
beta-customers, but not acceptable for live customers.

The upgrade solution provided here will enable delivery of new
functionality to existing earnings and deductions WITHOUT requiring
(a) or (b) from the customer.

When new functionality is added to an existing earning or deduction,
the functionality is enabled and will be operational for any NEW payroll
runs and quickpays processed on the customer account.  Any existing runs
on the customer account are left intact but obviously will not have used
the new functionality.  This solution/upgrade will enable the new
functionality to be operational for existing runs which are rolled back
and re-processed.  This is handled by the upgrade which will
add new functionality over the lifetime of the element.


III. TECHNICAL DETAILS

The normal template generation code in packages pygenptx.pkb, pyusuidt.pkb,
pywatgen.pkb will handle the creation of the following rows for the new
input value on deductions templates:
PAY_INPUT_VALUES_F
PAY_BALANCE_FEEDS_F
PAY_FORMULA_RESULT_RULES_F
NOTE: These rows can be created at any time, regardless of existing
payroll runs on the live account.

The package pyusuiet.pkb does the same for earnings templates.

The new New_Input_Value API needs to retrofit [date-effective] rows in
the following tables:
PAY_LINK_INPUT_VALUES_F
PAY_ELEMENT_ENTRY_VALUES_F
PAY_RUN_RESULT_VALUES
NOTE: These are the rows created for and by payroll runs.


IV. ALGORITHM

1a. For the element type having a new input value added, we need to find all
element links...
Date-effective Element Links that exist for the element type on which
the input value is being added:
SELECT	DISTINCT pel.element_link_id
INTO	l_element_link_id
FROM	pay_element_links_f	pel
WHERE	pel.element_type_id	= p_element_type_id
ORDER BY pel.effective_start_date;


1b. For each element link id found in 1a, find the min start and max end date.
SELECT	min(pel.effective_start_date)
INTO	l_link_eff_start
FROM	pay_element_links_f	pel
WHERE	pel.element_link_id	= l_element_link_id;

SELECT	max(pel.effective_end_date)
INTO	l_link_eff_end
FROM	pay_element_links_f	pel
WHERE	pel.element_link_id	= l_element_link_id;


1c. Then create appropriately date-effective link input value row...
Create SINGLE date-effective PAY_LINK_INPUT_VALUES_F row...lasting from
earliest (min) effective_start_date for element link...to latest (max)
eff end date of link...is this ideally the end of time? yes.
INSERT INTO pay_link_input_values_f (
	link_input_value_id,
	element_link_id,
	input_value_id,
	effective_start_date,
	effective_end_date,
	costed_flag,
	default_value,
	max_value,
	min_value,
	warning_or_error
	)
VALUES (
	pay_link_input_values_s.nextval,
	l_element_link_id,
	p_input_value_id, -- ie. id of iv being added
	l_link_eff_start,
	l_link_eff_end,
	p_costed_flag,
	p_default_value,
	p_max_value,
	p_min_value,
	p_warning_or_error
	);


2a. For each link row found in 1a, need to find date-effective
Element Entries that exist for the element link:
SELECT DISTINCT	pee.element_entry_id
INTO	l_element_entry_id
FROM	pay_element_entries_f	pee
WHERE	pee.element_link_id	= l_element_link_id -- ie. link found in 1a.
ORDER BY pee.element_entry_id;


2b. For each entry found in 2a, find all date-effective entry value rows
over the life of the entry.

select	DISTINCT pev.effective_start_date,
	pev.effective_end_date
from	pay_element_entry_values_f	pev
where	pev.element_entry_id	= l_element_entry_id
order by pev.effective_start_date;


2c. For each date-effective row found in 2b, create date-effective
PAY_ELEMENT_ENTRY_VALUES_F row...MULTIPLE ROWS...
INSERT INTO pay_element_entry_values_f (
	element_entry_value_id,
	element_entry_id,
	input_value_id,
	effective_start_date,
	effective_end_date,
	screen_entry_value
	)
VALUES (
	pay_element_entry_values_s.nextval,
	l_element_entry_id,
	p_input_value_id, -- ie. id of iv being added
	l_entry_eff_start,
	l_entry_eff_end,
	nvl(p_default_value, l_screen_entry_value)
	);


3a. Get run results that exist for the element type on which the input value
is being added:
SELECT	DISTINCT prr.run_result_id
INTO	l_run_result_id
FROM	pay_run_results		prr
AND	prr.element_type_id	= p_element_type_id -- ie. ele w/new iv.
ORDER BY prr.run_result_id;


3b. For each run result found in 3a, create PAY_RUN_RESULT_VALUES row...
INSERT INTO pay_run_result_values (
	run_result_id,
	input_value_id,
	result_value
	)
VALUES (
	l_run_result_id,
	p_input_value_id, -- ie. id of iv being added
	nvl(p_default_value, l_run_result_value
	);

======================================================================
*/

PROCEDURE new_input_value (
			p_element_type_id	in number,
			p_input_value_id		in number,
			p_costed_flag		in varchar2 default 'N',
			p_default_value		in varchar2 default NULL,
			p_max_value		in varchar2 default NULL,
			p_min_value		in varchar2 default NULL,
			p_warning_or_error	in varchar2 default NULL) is

l_element_link_id	number(9);
l_link_eff_start	date;
l_link_eff_end		date;

l_element_entry_id	number(9);
l_entry_eff_start	date;
l_entry_eff_end		date;
l_screen_entry_value	varchar2(60)	:= NULL;

l_run_result_id		number(9);
l_run_result_value	varchar2(60)	:= NULL;

already_exists		number;
entryval_exists		number;

CURSOR 	get_links (p_ele_id NUMBER) IS
SELECT	pel.element_link_id
FROM		pay_element_links_f	pel
WHERE	pel.element_type_id	= p_ele_id
ORDER BY 	pel.effective_start_date;

CURSOR	get_entries (p_link_id NUMBER) IS
SELECT 	pee.element_entry_id
FROM		pay_element_entries_f	pee
WHERE	pee.element_link_id	= p_link_id
ORDER BY 	pee.element_entry_id;

CURSOR	get_entry_values (p_entry_id NUMBER) IS
select		pev.effective_start_date,
		pev.effective_end_date
from		pay_element_entry_values_f	pev
where		pev.element_entry_id	= p_entry_id
order by 	pev.effective_start_date;

CURSOR	get_results (p_eletype_id NUMBER) IS
SELECT	prr.run_result_id
FROM		pay_run_results		prr
WHERE	prr.element_type_id	= p_eletype_id
ORDER BY 	prr.run_result_id;


BEGIN

/*
1a. For the element type having a new input value added, we need to find all
element links...
Date-effective Element Links that exist for the element type on which
the input value is being added:
*/

OPEN get_links(p_element_type_id);
LOOP

/*
1b. For each element link id found in 1a, find the min start and max end date.
*/

  FETCH get_links
  INTO  l_element_link_id;
  EXIT WHEN get_links%NOTFOUND;

  SELECT	min(pel.effective_start_date)
  INTO	l_link_eff_start
  FROM	pay_element_links_f	pel
  WHERE	pel.element_link_id	= l_element_link_id;

  SELECT	max(pel.effective_end_date)
  INTO	l_link_eff_end
  FROM	pay_element_links_f	pel
  WHERE	pel.element_link_id	= l_element_link_id;

/*
1c. Then create appropriately date-effective link input value row...
Create SINGLE date-effective PAY_LINK_INPUT_VALUES_F row...lasting from
earliest (min) effective_start_date for element link...to latest (max)
eff end date of link...is this ideally the end of time? yes.
*/

/*
Check if link_input_value already exists before inserting...
if it does, do nothing...all this tells us is the upgrade has
already been attempted for this element...and the input value has
already been added successfully to this point.
*/

  already_exists := hr_template_existence.upg_link_iv_exists(
			p_element_link_id	=> l_element_link_id,
			p_input_val_id		=> p_input_value_id);

  if already_exists = 0 then

    INSERT INTO pay_link_input_values_f (
	link_input_value_id,
	element_link_id,
	input_value_id,
	effective_start_date,
	effective_end_date,
	costed_flag,
	default_value,
	max_value,
	min_value,
	warning_or_error
	)
    VALUES (
	pay_link_input_values_s.nextval,
	l_element_link_id,
	p_input_value_id,
	l_link_eff_start,
	l_link_eff_end,
	p_costed_flag,
	p_default_value,
	p_max_value,
	p_min_value,
	p_warning_or_error
	);

--    dbms_output.put_line('Added link input val: link = '||l_element_link_id||' iv = '||p_input_value_id);

  end if;

/*
2a. For each link row found in 1a, need to find date-effective
Element Entries that exist for the element link:
*/

  OPEN get_entries(l_element_link_id);
  LOOP

/*
2b. For each entry found in 2a, find all date-effective entry value rows
over the life of the entry.
*/

    FETCH get_entries
    INTO  l_element_entry_id;
    EXIT WHEN get_entries%NOTFOUND;

    OPEN get_entry_values(l_element_entry_id);
    LOOP

/*
2c. For each date-effective row found in 2b, create date-effective
PAY_ELEMENT_ENTRY_VALUES_F row...MULTIPLE ROWS...
*/

      FETCH get_entry_values
      INTO  l_entry_eff_start,
            l_entry_eff_end;
      EXIT WHEN get_entry_values%NOTFOUND;

/*
Check if entry value already exists for this iv.  If so, do nothing.
*/

      already_exists := hr_template_existence.upg_entry_val_exists(
			p_element_entry_id	=> l_element_entry_id,
			p_input_val_id		=> p_input_value_id);

      if already_exists = 0 then

        INSERT INTO pay_element_entry_values_f (
	element_entry_value_id,
	element_entry_id,
	input_value_id,
	effective_start_date,
	effective_end_date,
	screen_entry_value
	)
        VALUES (
	pay_element_entry_values_s.nextval,
	l_element_entry_id,
	p_input_value_id,
	l_entry_eff_start,
	l_entry_eff_end,
	nvl(p_default_value, l_screen_entry_value)
	);

--       dbms_output.put_line('Added entry val: entry = '||l_element_entry_id||' iv = '||p_input_value_id);

      else

        select count(0)
        into   entryval_exists
        from   pay_element_entry_values_f
        where  element_entry_value_id = already_exists
        and    effective_start_date = l_entry_eff_start;

        if entryval_exists = 0 then

          INSERT INTO pay_element_entry_values_f (
	  element_entry_value_id,
  	  element_entry_id,
	  input_value_id,
	  effective_start_date,
	  effective_end_date,
	  screen_entry_value
  	  )
          VALUES (
	  already_exists,
	  l_element_entry_id,
	  p_input_value_id,
	  l_entry_eff_start,
	  l_entry_eff_end,
	  nvl(p_default_value, l_screen_entry_value)
	  );

--         dbms_output.put_line('Added entry val: entry = '||l_element_entry_id||' iv = '||p_input_value_id);

       end if;

      end if;

    END LOOP; -- get_entry_values
    CLOSE get_entry_values;

  END LOOP; -- get_entries
  CLOSE get_entries;

END LOOP; -- get_links
CLOSE get_links;

/*
3a. Get run results that exist for the element type on which the input value
is being added:
*/

OPEN get_results(p_element_type_id);
LOOP

/*
3b. For each run result found in 3a, create PAY_RUN_RESULT_VALUES row...
*/

  FETCH get_results
  INTO  l_run_result_id;
  EXIT WHEN get_results%NOTFOUND;

/*
Check if run result values already exist for this iv. If so, do nothing.
*/

  already_exists := hr_template_existence.upg_result_val_exists(
			p_run_result_id		=> l_run_result_id,
			p_input_val_id		=> p_input_value_id);

  if already_exists = 0 then

    INSERT INTO pay_run_result_values (
	run_result_id,
	input_value_id,
	result_value
	)
    VALUES (
	l_run_result_id,
	p_input_value_id,
	nvl(p_default_value, l_run_result_value)
	);

--    dbms_output.put_line('Added run result val: result = '||l_run_result_id||' iv = '||p_input_value_id);

  end if;

END LOOP; -- get_results
CLOSE get_results;

END new_input_value;










--
 /*
 NAME
  ins_3p_input_values
 DESCRIPTION
  This procedure controls the third party inserts when an input value is
  created manually. (Rather than being created at the same time as an element
  type.) It calls the procedures create_link_input_value and
  hr_balances.ins_balance_feed.

  NOTE: This procedure has been copied from hr_input_values package.
  For purposes of upgrading template earnings and deductions, we do not
  need to call the link input value and balance feed api - so these have been
  commented out.  The upgrade procedure will handle adding these rows
  appropriately over the lifetime of the element type being upgraded.
  */
--
PROCEDURE	ins_3p_input_values(p_val_start_date	in date,
				p_val_end_date		in date,
				p_element_type_id	in number,
				p_primary_classification_id in number,
				p_input_value_id	in number,
				p_default_value		in varchar2,
				p_max_value		in varchar2,
				p_min_value		in varchar2,
				p_warning_or_error_flag	in varchar2,
				p_input_value_name	in varchar2,
				p_db_items_flag		in varchar2,
				p_costable_type	   	in varchar2,
				p_hot_default_flag	in varchar2,
				p_business_group_id	in number,
				p_legislation_code	in varchar2,
				p_startup_mode		in varchar2) is
--
	l_pay_value_name	varchar2(80);
--
--
 begin
--
	hr_utility.set_location('pay_template_ivs.ins_3p_input_values', 1);
/*
--
  -- Obtain Pay value name from translation table.
	l_pay_value_name :=
		hr_input_values.get_pay_value_name(p_legislation_code);
--
  -- Call function to insert new link input value
	hr_input_values.create_link_input_value('INSERT_INPUT_VALUE',
				  NULL,
				  p_input_value_id	   ,
				  p_input_value_name	   ,
				  NULL,
				  p_val_start_date  ,
				  p_val_end_date    ,
				  p_default_value	   ,
				  p_max_value		   ,
				  p_min_value		   ,
				  p_warning_or_error_flag  ,
				  p_hot_default_flag	   ,
				  p_legislation_code	   ,
				  l_pay_value_name	   ,
				  p_element_type_id        );
--
*/

/*
-- A balance feed will be inserted if a new pay value is created.
   if p_input_value_name = l_pay_value_name then
	hr_balances.ins_balance_feed('INS_PER_PAY_VALUE',
			  p_input_value_id,
			  NULL,
			  p_primary_classification_id,
			  NULL,NULL,NULL,NULL,
			  p_val_start_date,
			  p_business_group_id,
			  p_legislation_code,
			  p_startup_mode);
--
    end if;
*/
--
    if p_db_items_flag = 'Y' then
--
  -- Create database items
--
    	hrdyndbi.create_input_value_dict(
			p_input_value_id,
			p_val_start_date);
--
    end if;

end ins_3p_input_values;
--


 /*
 NAME
 chk_input_value
 DESCRIPTION
  Checks attributes of inserted and update input values for concurrence
  with business rules.

  NOTE: This procedure has been copied from hr_input_values package.
  For purposes of upgrading template earnings and deductions, we do not
  need to check for existing element entries or run results - so these checks
  have been commented out.  The upgrade procedure will handle adding these
  rows appropriately over the lifetime of the element type being upgraded.
 */
--
 PROCEDURE chk_input_value(p_element_type_id         in number,
			   p_legislation_code	     in varchar2,
                           p_val_start_date     in date,
                           p_val_end_date       in date,
			   p_insert_update_flag	     in varchar2,
			   p_input_value_id          in number,
			   p_rowid                   in varchar2,
			   p_recurring_flag          in varchar2,
			   p_mandatory_flag	     in varchar2,
			   p_hot_default_flag	     in varchar2,
			   p_standard_link_flag	     in varchar2,
			   p_classification_type     in varchar2,
			   p_name                    in varchar2,
			   p_uom                     in varchar2,
			   p_min_value               in varchar2,
			   p_max_value               in varchar2,
			   p_default_value           in varchar2,
			   p_lookup_type             in varchar2,
			   p_formula_id              in number,
			   p_generate_db_items_flag  in varchar2,
			   p_warning_or_error        in varchar2) is
--
 v_validation_check  varchar2(1);
v_num_input_values  number;
l_pay_value_name	varchar2(80);
--
 begin
   hr_utility.set_location('pay_template_ivs.chk_input_value', 1);
--
	-- get pay value name
	l_pay_value_name := hr_input_values.get_pay_value_name
				(p_legislation_code);
--
  -- payments type 'Pay Values' must have uom of money
--
  if p_name = l_pay_value_name and
     p_classification_type = 'N' and
     p_uom <> 'M' then
--
   	hr_utility.set_message(801,'');
   	hr_utility.raise_error;
--
  end if;

	hr_utility.set_location('pay_template_ivs.chk_input_value', 10);
--
  if p_insert_update_flag = 'INSERT' then
  -- Make sure that a maximum of 6 input values can be created
  begin
--
   select count(distinct iv.input_value_id)
   into   v_num_input_values
   from   pay_input_values_f iv
   where  iv.element_type_id = p_element_type_id
   and	  p_val_start_date between
	iv.effective_start_date and iv.effective_end_date;
--
  exception
   when NO_DATA_FOUND then NULL;
  end;
  if v_num_input_values >= 6 then
--
   hr_utility.set_message(801,'PAY_6167_INPVAL_ONLY_6');
   hr_utility.raise_error;
--
  end if;
--
/*
  v_validation_check := 'Y';
--
  -- no entries can be in existence
  -- during the validation period
  -- for the other input values.
  -- This check only needs to be done on insert not on updatE
--
  	begin
--
    	select 'N'
    	into v_validation_check
    	from sys.dual
    	where exists
		(select 1
		from 	pay_element_links_f el,
			pay_element_entries_f ee
		where 	p_element_type_id = el.element_type_id
		and	el.element_link_id = ee.element_link_id
		and 	ee.effective_end_date >= p_val_start_date
		and	ee.effective_start_date <= p_val_end_date);
--
  	exception
  	 when NO_DATA_FOUND then NULL;
  	end;
--
  	if v_validation_check = 'N' then
--
  	 hr_utility.set_message(801,'PAY_6197_INPVAL_NO_ENTRY');
  	 hr_utility.raise_error;
--
  	end if;
--
	hr_utility.set_location('pay_template_ivs.chk_input_value', 20);
--
*/

    end if;-- In INSERT mode
--
  -- Make sure that the input value name is unique within the element
  -- This will ensure also that only one PAY_VALUE can be used.
  begin
	select 'N'
	into v_validation_check
	from sys.dual
	where exists
	(select 1
	from pay_input_values_f
	where element_type_id = p_element_type_id
	and input_value_id <> p_input_value_id
	and upper(p_name) = upper(name));
--
  exception
	when NO_DATA_FOUND then NULL;
  end;

	hr_utility.set_location('pay_template_ivs.chk_input_value', 40);
--
  if v_validation_check = 'N' then
--
   hr_utility.set_message(801,'PAY_6168_INPVAL_DUP_NAME');
   hr_utility.raise_error;
--
  end if;
--
  -- Hot defaulted values must be mandatory.
--
  if (p_hot_default_flag = 'Y' and p_mandatory_flag = 'N') then
--
     hr_utility.set_message(801,'PAY_6609_ELEMENT_HOT_DEF_MAN');
     hr_utility.raise_error;
--
  end if;
--
  -- Hot defaulted values must have default, max and min less than 59
  -- characters. This is to allow for the inclusion of quotes around the
  -- values when they are displayed at the lower level
  if (p_hot_default_flag = 'Y') and
     ((length(p_default_value) > 58) or
      (length(p_min_value) > 58) or
      (length(p_max_value) > 58)) then
--
     hr_utility.set_message(801,'PAY_6616_INPVAL_HOT_LESS_58');
     hr_utility.raise_error;
--
  end if;
--
  -- If the element is nonrecurring then do not allow any non-numeric input
  -- values to have create db items set to 'Y' ie. cannot specify Date or
  -- Character. This is so that they can be summed on the entity horizon
  if ((p_recurring_flag = 'N' and
       p_generate_db_items_flag = 'Y') and
       ((p_uom = 'C') or
	(p_uom like 'D%'))) then
--
   hr_utility.set_message(801,'PAY_6169_INPVAL_ONLY_NUM');
   hr_utility.raise_error;
--
  end if;
--
  -- Makes sure that the validation specified for the input value is correct
  -- ie. it can either be formula and default OR
  -- lookup type and default OR default and
  -- min / max
  if p_formula_id is not NULL then
--
   if (p_lookup_type is not NULL or
       p_min_value is not NULL or
       p_max_value is not NULL or
       p_warning_or_error is NULL) then
--
    hr_utility.set_message(801,'PAY_6905_INPVAL_FORMULA_VAL');
    hr_utility.raise_error;
--
   end if;
--
	hr_utility.set_location('pay_template_ivs.chk_input_value', 50);
--
   elsif p_lookup_type is not NULL then
--
    if (p_min_value is not NULL or
	p_max_value is not NULL or
	p_formula_id is not NULL or
	p_warning_or_error is not NULL) then
--
     hr_utility.set_message(801,'PAY_6906_INPVAL_LOOKUP_VAL');
     hr_utility.raise_error;
--
    end if;
	hr_utility.set_location('pay_template_ivs.chk_input_value', 60);
--
--
   elsif (p_min_value is not NULL or p_max_value is not NULL) then
--
    if (p_lookup_type is not NULL or
	p_formula_id is not NULL) then
--
     hr_utility.set_message(801,'PAY_6907_INPVAL_MIN_MAX_VAL');
     hr_utility.raise_error;
--
    elsif (p_warning_or_error is null) then
--
     hr_utility.set_message(801,'PAY_6907_INPVAL_MIN_MAX_VAL');
     hr_utility.raise_error;
--
    end if;

  end if;
--
    if (p_warning_or_error is not null and
    p_min_value is null and
    p_max_value is null and
    p_formula_id is null) then
--
     hr_utility.set_message(801,'PAY_6908_INPVAL_ERROR_VAL');
     hr_utility.raise_error;
--
    end if;
	hr_utility.set_location('pay_template_ivs.chk_input_value', 70);
--
  -- Mkae sure that when lookup validation is being used that the default when
  -- specified is valid for the lookup type
--
--
  if (p_lookup_type is not NULL and p_default_value is not NULL) then
	hr_utility.set_location('pay_template_ivs.chk_input_value', 80);
--
   begin
--
    v_validation_check := 'Y';
--
    select 'N'
    into   v_validation_check
    from   sys.dual
    where  not exists(select 1
		      from   hr_lookups
		      where  lookup_type = p_lookup_type
			and  lookup_code = p_default_value);
--
   exception
    when NO_DATA_FOUND then NULL;
   end;
--
	hr_utility.set_location('pay_template_ivs.chk_input_value', 90);
--
   if v_validation_check = 'N' then
--
    hr_utility.set_message(801,'PAY_6171_INPVAL_NO_LOOKUP');
    hr_utility.raise_error;
--
   end if;
--
  end if;
--

/*
  -- No new input values can be created if there are any run results existing
  -- for this element
	begin
--
	select 'N'
	into v_validation_check
	from sys.dual
	where exists
		(select 1
		from pay_run_results rr
		where rr.element_type_id = p_element_type_id);
--
	exception
		when NO_DATA_FOUND then null;
	end;
--
	if v_validation_check = 'N' then
        	hr_utility.set_message(801,'PAY_6913_INPVAL_NO_INS_RUN_RES');
        	hr_utility.raise_error;
  	end if;
*/

 end chk_input_value;
--


END pay_template_ivs;

/
