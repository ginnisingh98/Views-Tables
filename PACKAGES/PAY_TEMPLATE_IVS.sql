--------------------------------------------------------
--  DDL for Package PAY_TEMPLATE_IVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TEMPLATE_IVS" AUTHID CURRENT_USER AS
/* $Header: pyaddivs.pkh 115.2 2003/04/03 18:03:24 ekim ship $ */

/*
Copyright 1996
Oracle Corporation
Redwood Shores, California 94065
USA

Filename    : pyaddivs.pkh

Description : API enabling addition of an input value
              over the lifetime of an EXISTING element type.

Change History
---------------
Date         Name        Vers   Bug No   Description
-----------  ----------  -----  -------  -----------------------------------
05-Aut-1996  hparicha    40.0            Created.
10-Jul-1997  mfender     110.1           added error checking.
03-Apr-2003  ekim        115.2           gscc warning fix.


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

For the element type having a new input value added, we need to find all
element links...

1a. Date-effective Element Links that exist for the element type on which
the input value is being added:
SELECT	pel.element_link_id,
	pel.effective_start_date,
	pel.effective_end_date,
	...
INTO	l_element_link_id,
	l_effective_start_date,
	l_effective_end_date,
	...
FROM	pay_element_links_f	pel,
	pay_input_values_f	piv
WHERE	piv.input_value_id	= p_iv_id -- ie. id of iv being added
AND	pel.element_type_id	= piv.element_type_id
ORDER BY pel.effective_start_date;


1b. Create SINGLE date-effective PAY_LINK_INPUT_VALUES_F row...lasting from
earliest (min) effective_start_date for element link...to latest (max)
eff end date of link...is this ideally the end of time? yes.
INSERT INTO pay_link_input_values_f (
	element_link_id
	input_value_id,
	effective_start_date,
	effective_end_date,
	...
	)
VALUES (
	l_element_link_id,
	p_iv_id, -- ie. id of iv being added
	l_effective_start_date,
	l_effective_end_date,
	...
	);


2a. For each link row found in 1a, need to find date-effective
Element Entries that exist for the element link:
SELECT	pee.element_entry_id,
	pee.effective_start_date,
	pee.effective_end_date,
	...
INTO	l_element_entry_id,
	l_effective_start_date,
	l_effective_end_date,
	...
FROM	pay_element_entries_f	pee
WHERE	pee.element_link_id	= l_element_link_id -- ie. link found in 1a.
ORDER BY pee.effective_start_date;


2b. Create date-effective PAY_ELEMENT_ENTRY_VALUES_F row...MULTIPLE ROWS.
INSERT INTO pay_element_entry_values_f (
	element_entry_id
	input_value_id,
	effective_start_date,
	effective_end_date,
	screen_entry_value,
	...
	)
VALUES (
	l_element_entry_id,
	p_iv_id, -- ie. id of iv being added
	l_effective_start_date,
	l_effective_end_date,
	l_screen_entry_value, -- ie. = NULL or do we need to handle default
  					values and mandatory input values?
	...
	);


3a. Run Results that exist for the element type on which the input value
is being added:
SELECT	prr.run_result_id
INTO	l_run_result_id
FROM	pay_run_results		prr
AND	prr.element_type_id	= l_element_type_id -- ie. ele w/new iv.
ORDER BY prr.run_result_id;


3b. Create PAY_RUN_RESULT_VALUES row...
INSERT INTO pay_run_results (
	run_result_id,
	input_value_id,
	result_value
	)
VALUES (
	l_run_result_id,
	p_iv_id, -- ie. id of iv being added
	l_value  -- ie. = NULL

======================================================================
*/

PROCEDURE chk_input_value(p_element_type_id      in number,
                          p_legislation_code     in varchar2,
                          p_val_start_date       in date,
                          p_val_end_date         in date,
                          p_insert_update_flag   in varchar2,
                          p_input_value_id       in number,
                          p_rowid                in varchar2,
                          p_recurring_flag       in varchar2,
                          p_mandatory_flag       in varchar2,
                          p_hot_default_flag     in varchar2,
                          p_standard_link_flag   in varchar2,
                          p_classification_type  in varchar2,
                          p_name                 in varchar2,
                          p_uom                  in varchar2,
                          p_min_value            in varchar2,
                          p_max_value            in varchar2,
                          p_default_value        in varchar2,
                          p_lookup_type          in varchar2,
                          p_formula_id           in number,
                          p_generate_db_items_flag in varchar2,
                          p_warning_or_error       in varchar2);

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
				p_startup_mode		in varchar2);

PROCEDURE new_input_value (
			p_element_type_id	in number,
			p_input_value_id	in number,
			p_costed_flag		in varchar2 default 'N',
			p_default_value		in varchar2 default NULL,
			p_max_value		in varchar2 default NULL,
			p_min_value		in varchar2 default NULL,
			p_warning_or_error	in varchar2 default NULL);

END pay_template_ivs;

 

/
