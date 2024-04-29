--------------------------------------------------------
--  DDL for Package PAY_YEAR_END_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_YEAR_END_EXTRACT" AUTHID CURRENT_USER as
/* $Header: payyeext.pkh 115.2 99/07/17 05:40:40 porting ship  $ */
/*
 * ---------------------------------------------------------------------------
   Copyright (c) Oracle Corporation (UK) Ltd 1992.
   All Rights Reserved.
  --
  --
  PRODUCT
    Oracle*Payroll
  NAME
    payyeext.pkh
  NOTES
    GB Year End Extract - populate the year end tables ready for the p35
    --
EOY EXTRACT

Table Structure:		Key	Reference Attributes
Pay_year_end_payrolls  		Payroll
					Tax_reference
					Permit
					Business_group

Pay_year_end_assignments	Assignment, Effective_end_date
					Payroll
					Request
					Multi_Assignment Indicator
					Last_Asg_Action
					Last_Year_Last_Asg_action
					Tax_Run_Result

Pay_year_end_values		Assignment,
				Effective_end_date,
				Reportable
				NI Category

Extract Design:
0) Delete from  year end tables for the permit
	0.1	delete all rows in values for this Permit,
		 or if no Permit is specified for the tax ref
		or if no tax ref specified for business group.
	0.2	delete all rows in Assignments for this Permit, Tax Reference
		 or Business_group
	0.3	delete all rows from Payrolls for this Permit , Tax Reference
		 or Business Group

1) Populate pay_year_end_payrolls
	set up the payrolls with the start and end dates for the year from
	per_time_periods note populate all permits for the Payrolls table
	- we need to know the start and end of the year for all payrolls
	within the bg

2) Populate Pay_year_end_assignments
	2.1     Insert rows to extract
			asg_id
			payroll_id
			effective_end_date
			request_id
			assignment_number
			person_id
			organization_id
			location_id
			people_group_id
		select all the assignments for a particular Permit, note only
		latest date effective row is required-the Permit(via Payroll_id)
		for that row dictates where it is to be reported even if the
		assignment has been on more than one payroll in the year. The
		exception is where Tax Reference transfers have occurred - these
		are reported separately as though they were terminations. Some
		assignments may have been terminated in the previous year but
		reported at this year end as they incurred NI Y -set up ASG rows
		for these cases - some of these rows will be deleted later after
		the NI Y has been fetched as 0.

	2.1.1	find the latest assignment within payroll year
	2.1.2	add assignment rows for tax reference changes
                set termination_date = effective_end_date
                set termination_type = 'R' meaning tax Reference Transfer


	2.2	Set effective_start_date for each row
	2.2.1	If extract is for all permits
			:Set effective_start_date from prior ASG row
	2.2.2	else	:set effective_start_date from base table
	note the effective_start_date remains unset for people with no transfer

	2.3	set dates to retrieve balances from
	2.3.1	Find the last action current year
		(set last_asg_action_id,last_effective_date)
			Completed actions for runs, quickpay,
                 	balance adjustments, balance initialization

	2.4	Fetch Person Information as of end of year
		last_name			substr(1,20)
		first_name			substr(1,7)
		middle_name			substr(1,7)
		date_of_birth			ddmmyy
		expense_check_send_to_address
		national_insurance_number	national_identifier(1,9)
		sex 				substr(1,1)
		pensioner_indicator		P if per_information4 = 'Y'
		director_indicator		D if per_information1 = 'Y'
		ni_period_type			per_information9(1,30)

	2.5     set termination date if its within the 2 years dependent
		on whether the last date processed is within the
		effective_start_date and effective_end_date ( ie
		cater for rehires) set termination date for tax
		reference transfers to effective_end_date

	2.6	Find the last action last year
		(set previous_year_asg_action_id,previous_year_effective_date]-
			only needed for NI Y balance so filter if possible)


	2.7	Set Assignment Balances [ASSIGNMENT LOOP for each row in ASG do]
	2.7.1	Fetch NI Y
	2.7.1.1	get NI Y _asg_stat_ytd using previous_year_asg_action_id
	2.7.1.2	if no NI Y balance get NI Y Last Year _asg_stat_ytd
						using last_asg_action_id
	2.7.1.3	if no NI Y balance and no last_asg_action_id then
							delete the person row
	2.7.1.4	insert into Values the NI Y row

	2.7.2	Fetch NI A using last_asg_action_id
	2.7.2.1	get NI A Total _asg_td_ytd
	2.7.2.2	if NI A Total exists get NI A _asg_td_ytd
	2.7.2.3	if NI A Total exists get NI A Able_asg_td_ytd
	2.7.2.4	if NI A Total exists insert into Values the NI A row

	2.7.3	Fetch NI B as for NI A only check Female employees

	2.7.4	Fetch NI C
	2.7.4.1	get NI C Total _asg_td_ytd using last_asg_action_id
	2.7.4.2	if NI C Total exists insert into Values the NI C row

	2.7.5	Fetch NI D using last_asg_action_id
	2.7.5.1	get NI D Total _asg_td_ytd
	2.7.5.2	if NI D Total exists get NI D _asg_td_ytd
	2.7.5.3	if NI D Total exists get NI D Able_asg_td_ytd
	2.7.5.4	if NI D Total exists get NI D CO Able_asg_td_ytd
	2.7.5.5	if NI D Total exists get NI D CO_asg_td_ytd
	2.7.5.4	if NI D Total exists insert into Values the NI D row

	2.7.6	Fetch NI E as for NI A only check Female employees

	2.7.7	fetch Assignment balances using last_asg_action_id
			smp			SMP Total_asg_td_ytd (females)
			ssp			SSP Total_asg_td_ytd
			gross_pay		Gross Pay_asg_td_ytd
			tax_paid		PAYE_asg_td_ytd
			superannuation_paid	Superannuation Total_asg_td_ytd
			widows and orphans	Widows and Orphans_asg_td_ytd
			taxable_pay		Taxable_pay_asg_td_ytd
		update ASG row with balances
	[end ASSIGNMENT LOOP]

	2.8	Tax information is picked up the last time it was calculated
	2.8.1	check  PAYE was updated in last_asg_action_id[tax_run_result_id]
	2.8.2	if not - look for the last PAYE result[tax_result_id]
	2.8.3	set 	tax_code			Tax Code
			w1_m1_indicator			Tax Basis
			previous_taxable_pay		Pay Previous
			previous_tax_paid		Tax Previous



	2.9	Reset codes on the ASG table
		week_53_indicator		53(3), 54(4), 56(6) from
						Payrolls.max_period_number
		w1m1_indicator			number_per_fiscal = 1,2,4,6,12,
								24 M else W
		tax_refund			if tax_paid < 0
		tax_paid			make +ve
		superannuation_refund		if superannuation_paid < 0
		superannuation_paid		make +ve



3) Re-assign NI Values for multiple assignments
	3.1	check that multiple assignments don't span permits -report error

	3.2	sum the values balances for all the assignments associated with 			the eoy_primary assignment( set reportable flag)

	3.3	mark the balances for secondary assignments as non reportable

	3.4	insert the X rows for non primary multiple assignments
               {issue do we need X rows for all assignments with no NI figures?}



  MODIFIED
    --
    asnell          23-OCT-1995  Created
    asnell          28-APR-1998  BUG 662438 Scon number fetch for Initialized
				 balances
  --
 * ---------------------------------------------------------------------------
 */
--
  -- output a message on the process log
procedure PLOG ( p_message IN varchar2 );

  -- housekeeping procedure called pre extract to delete previously extracted
  -- data

procedure trash(p_permit in varchar2  ,
                  p_business_group_id in number,
		  p_tax_district_ref in varchar2,
                  p_year in number) ;

  -- populate the eoy tables
procedure extract(p_permit in varchar2  ,
                  p_business_group_id in number,
		  p_tax_district_ref in varchar2,
                  p_year in number,
                  p_request_id in number,
                  p_niy in varchar2,
                  p_retcode out number ,
                  p_errbuf out varchar2
                  ) ;
--
  function get_nearest_scon
     (
      p_element_entry_id       IN number ,
      p_category               IN varchar2 ,
      p_effective_date         IN date
     ) return varchar2;
pragma restrict_references (get_nearest_scon, WNDS);
--


end pay_year_end_extract;

 

/
