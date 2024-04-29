--------------------------------------------------------
--  DDL for Package Body PAY_YEAR_END_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_YEAR_END_EXTRACT" as
/* $Header: payyeext.pkb 115.8 99/10/11 06:38:04 porting ship  $ */
/*
 * ---------------------------------------------------------------------------
   Copyright (c) Oracle Corporation (UK) Ltd 1992.
   All Rights Reserved.
  --
  --
  PRODUCT
    Oracle*Payroll
  NAME
    payyeext.pkb
  NOTES
    GB Year End Extract - populate the year end tables ready for the p35
  PROCEDURES
    Trash - clear down year end tables for this permit
    Extract - populate year end tables for this permit
    --
  MODIFIED
    --
    asnell          23-OCT-1995  Created
    asnell          15-NOV-1995  Where no NI balances exist set to Current Cat
    asnell          17-NOV-1995  Removed hardcoded value for Taxcode fetch
    asnell          23-NOV-1995  Set termination date only if asg is same
                                 period of service and rename table to GB
    asnell          04-DEC-1995  ensured tax detail refs are within BG
    asnell          05-DEC-1995  initialized l_ni_y local variable
    asnell          11-DEC-1995  default taxcode to NI
    asnell          19-DEC-1995  NI Y set on the assignment row live at prev.eoy
    asnell          19-DEC-1995  NI Y Last Year set on latest row only
    asnell          03-MAY-1996  invalid_multiple_asg fix bug + performance fix
    asnell          05-JUN-1996  modified trash logic to cope with permit change
                                 bug 371483
  cbarbier          27-JUN-1996  add check_extract procedure to check if all
                                 payrolls extract have at least one assignment.
  cbarbier          26-JUL-1996  Changed dates definition for Y2000.
  aswong	    08-Aug-1996  Uncomment the exit statement at the end.
    miqbal          26-Sep-1996  Added NIP extraction
    miqbal          07-Oct-1996  Fix for multiple assignment extraction
                                 Fix for NI Y, extraction
                                 Changed NI C Total balance extraction to
                                         NI C Employers total.
  RThirlby          17-Jan-1997  Added new NI categories F, G and S.
  tinekuku          26-Feb-1997  Bug 463778 - Used cursors to do inner/outer
                                 selects for setting NI Balance on primary
                                 asgmts for multiple assignments
  asnell	    08-May-1997  Bug 492246 - Ensure tax reference transfers are
				 also payroll transfers
				 Defaulted Taxcode from element if no run exists
                                 Speeded up latest PAYE action fetch
  aparkes           11-Jul-1997  Added updates to ye_assignments for employee
                                 Address,Start_of_emp.
                                 Added TITLE to extract from per_people_f
                                 Used cursor for SCON NIF, G and S balances.
  amills	    16-Jan-1998  Bug 572938. Added a new update statement
				 'Retrieve element entry update recurring'
				 for update of pay_gb_year_end_assignments
				 where an element entry exists that is the
				 result of an update recurring rule. The
				 logic is altered to check for this rule
				 first before locating run result value,
				 then defaulting to element (non- U.R.R.)
				 value as before.
  aparkes           19-Jan-1998  Used GB Balance direct call package hr_dirbal
                                 for balance fetching.
  arundell	    30-Mar-1998  Fixed bug 639910.  Adjusted the way the last
				 assignment_action_id, previous_year_asg_action_id
				 and the last tax_run_result_id is derived, so
				 that payroll reversals are included.
  hanand            16-Apr-1998  Fixed byg 656417.  Included cases with
                                 termination_type of 'L' for reporting NI_Y_LAST
  asnell            23-Apr-1998  Fixed bug 660289.  Only create SCON balance
                                 entry if results were non zero
  asnell            29-Apr-1998  Fixed bug 662438.  If SCON entry value doesn't
                                 exist on the date find the nearest match
  hanand            04-Jun-1998  Fixed bug 678573.  Changed the cursor
                                 get_scon_bal to include 'Employer' balances.
                                 Setting 'Total' to 'Employer' balance for
                                 category 'S' and all other balances to 0.
  amyers  110.11    06-NOV-1998  Fixed bug 715534. Added status checks to table
                                 PAY_RUN_RESULTS in updates after balances have
                                 been fetched.
  amyers  110.12    23-FEB-1999  Fixed bug 818887. Aggregate rows by scon and
                                 category; takes care of situation where more
                                 then one can be returned.
  scgrant 115.1     20-APR-1999  Multi-radix changes.
  pdavies 115.2     11-OCT-1999  Replaced all occurrences of DBMS_Output.
                                 Put_Line with hr_utility.trace.
*/
--
---------------------------GLOBALS ------------------------------------------
  g_ni_id         number(9);
  g_category_input_id number(9);
  g_scon_input_id number(9);
/* ---------------------------------------------------------------------------
--
--
--                         PROCEDURES                                 --
--
--
-------------------------- PLOG --------------------------------------------*/
procedure PLOG ( p_message IN varchar2 ) is

-- output a message to the process log file
-- currently a cover for dbms.output but may be a cover for a generic function
begin
   hr_utility.trace(rpad(p_message,69)||' '|| TO_CHAR(SYSDATE,'HH24:MI:SS'));
end plog;
/* ----------------------------------------------------------------------------*/
/* ---------------------------- CHECK EXTRACT ---------------------------------*/
/* ----------------------------------------------------------------------------*/
/* This function check if all the payrolls extracted have at least one         */
/* assignment, if they have not, it return false and the extract process abort */
/* ----------------------------------------------------------------------------*/
FUNCTION check_data(
	p_business_group_id	IN	NUMBER,
	p_year			IN	NUMBER,
	p_permit			IN	VARCHAR2	DEFAULT NULL,
	p_tax_district_ref	IN	VARCHAR2	DEFAULT NULL
	)
	RETURN NUMBER
IS
	l_count		NUMBER;
BEGIN
	SELECT 	COUNT(*)
	INTO	l_count
	FROM
		pay_gb_year_end_payrolls pay,
		pay_gb_year_end_assignments ass,
		pay_gb_year_end_values val
	WHERE
		pay.payroll_id = ass.payroll_id
	AND	ass.assignment_id = val.assignment_id
	AND	pay.business_group_id = p_business_group_id
	AND	pay.tax_year = p_year
	AND	pay.permit_number = NVL(p_permit,pay.permit_number)
	AND	pay.tax_reference_number = NVL(SUBSTR(p_tax_district_ref,4,8), pay.tax_reference_number)
	AND	pay.tax_district_reference = NVL(FND_NUMBER.CANONICAL_TO_NUMBER(SUBSTR(p_tax_district_ref,1,3)), pay.tax_district_reference);
	RETURN l_count;
END check_data;

/* ----------------------------------------------------------------------------*/
/* ---------------------------- GET_NEAREST_SCON ------------------------------*/
/* ----------------------------------------------------------------------------*/
/* This function searches for a SCON number to associate with the SCON balance */
/* Balance initialization creates run results prior to the NI row that records */
/* the SCON number. So find a row for the same category after the effective    */
/* date of the owning payroll action.                                          */
/* Priority is next latest SCON input with the same Category                   */
/* down to next latest SCON input regardless of Category                       */
/* ----------------------------------------------------------------------------*/
FUNCTION GET_NEAREST_SCON(
      p_element_entry_id       IN number ,
      p_category               IN varchar2 ,
      p_effective_date         IN date
     ) return varchar2
IS
   CURSOR get_scon is
-- best match is if the category on the entry matches the balance category
-- as a workarround users may have entered scon against a different
-- category. So if no category matches just get the earliest scon value on or
-- after the effective date
	SELECT 	scon.screen_entry_value
	FROM
		pay_element_entry_values_f  scon,
		pay_element_entry_values_f  cat
	WHERE
		scon.element_entry_id = p_element_entry_id
        and     cat.element_entry_id = p_element_entry_id
        and     cat.effective_start_date = scon.effective_start_date
        and     cat.effective_end_date = scon.effective_end_date
        and     scon.input_value_id +0  = g_scon_input_id
        and     cat.input_value_id +0  = g_category_input_id
        and     scon.screen_entry_value is not null
        and     scon.effective_end_date >= p_effective_date
        order by decode(cat.screen_entry_value,p_category,0,1),
                 scon.effective_end_date ;
--

	l_scon		pay_gb_year_end_values.scon%TYPE;
BEGIN
   BEGIN
-- if global ids arent set set them
if g_ni_id is null then
        select element_type_id into g_ni_id from
                pay_element_types_f where element_name = 'NI'
                and p_effective_date between
                    effective_start_date and effective_end_date;
--
        select input_value_id into g_category_input_id from
                pay_input_values_f
		where name = 'Category'
                and element_type_id = g_ni_id
                and p_effective_date between
                    effective_start_date and effective_end_date;
--
        select input_value_id into g_scon_input_id from
                pay_input_values_f
		where name = 'SCON'
                and element_type_id = g_ni_id
                and p_effective_date between
                    effective_start_date and effective_end_date;
                end if;
        end;

      BEGIN
        open get_scon;
        fetch get_scon into l_scon;
        close get_scon;
        exception when no_data_found then l_scon := null;
      END;

	RETURN l_scon;

END get_nearest_scon;

/* --------------------------- trash -----------------------------------    */
/*
NAME
  trash
DESCRIPTION
  clear down year end tables for selected permit
NOTES
*/
procedure trash(p_permit in varchar2  ,
                  p_business_group_id in number,
                  p_tax_district_ref in varchar2,
                  p_year in number) is
  -- housekeeping procedure called pre extract to delete previously extracted
  -- data
  --
  -- delete all the rows in values for this permit , if no permit specified
  -- delete all rows within the business group

l_tax_district_reference pay_gb_year_end_payrolls.tax_district_reference%TYPE;
l_tax_reference_number   pay_gb_year_end_payrolls.tax_reference_number%TYPE;
l_start_year    date;
l_end_year      date;

begin
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.TRASH',2);
--
   l_tax_district_reference := fnd_number.canonical_to_number(substr(p_tax_district_ref,1,3));
   l_tax_reference_number   := substr(ltrim(substr(p_tax_district_ref,
                                                              4,8),'/') ,1,7);
--   set up the statutory start and end year
   l_start_year := to_date('06-04-'||(p_year - 1),'dd-mm-yyyy');
   l_end_year   := to_date('05-04-'||p_year,'dd-mm-yyyy');
--
  -- delete all the rows in values for this permit , if no permit specified
  -- delete all the rows for this tax_district_reference else if no
  -- tax_district_reference specified delete all rows within the business group
     delete from pay_gb_year_end_values v where exists (
       select '1' from 	pay_gb_year_end_assignments ye_asg,
			pay_payrolls_f p,
       			hr_soft_coding_keyflex flex,
			hr_organization_information org
       where p.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
       and   org.ORG_INFORMATION_CONTEXT = 'Tax Details References'
       and   org.org_information1 = flex.segment1
       and   p.business_group_id = p_business_group_id
       and   org.organization_id = p_business_group_id
       and   nvl(p_permit,substr(flex.segment10,1,12)) =
						substr(flex.segment10,1,12)
       and   nvl(l_tax_district_reference,substr(flex.segment1,1,3)) =
					        substr(flex.segment1,1,3)
       and   nvl(l_tax_reference_number,
		substr(ltrim(substr(org_information1,4,8),'/') ,1,7)) =
       		substr(ltrim(substr(org_information1,4,8),'/') ,1,7)
	and   l_end_year between
	      p.effective_start_date and p.effective_end_date
       and   ye_asg.payroll_id = p.payroll_id
       and   v.assignment_id = ye_asg.assignment_id
       and   v.effective_end_date = ye_asg.effective_end_date);
  --
	plog ( '_  value rows deleted '||to_char(SQL%ROWCOUNT));

  hr_utility.set_location('PAY_YEAR_END_EXTRACT.TRASH',4);
  -- delete all the rows in assignments for this permit , if no permit specified
  -- delete all the rows for this tax_district_reference else if no
  -- tax_district_reference specified delete all rows within the business group
     delete from pay_gb_year_end_assignments ye_asg where exists (
       select '1' from pay_payrolls_f p,
       hr_soft_coding_keyflex flex, hr_organization_information org
       where p.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
       and   org.ORG_INFORMATION_CONTEXT = 'Tax Details References'
       and   org.org_information1 = flex.segment1
       and   p.business_group_id = p_business_group_id
       and   org.organization_id = p_business_group_id
       and   nvl(p_permit,substr(flex.segment10,1,12)) =
						substr(flex.segment10,1,12)
       and   nvl(l_tax_district_reference,substr(flex.segment1,1,3)) =
					        substr(flex.segment1,1,3)
       and   nvl(l_tax_reference_number,
		substr(ltrim(substr(org_information1,4,8),'/') ,1,7)) =
       		substr(ltrim(substr(org_information1,4,8),'/') ,1,7)
	and   l_end_year between
	      p.effective_start_date and p.effective_end_date
       and   ye_asg.payroll_id = p.payroll_id);
  --
	plog ( '_  assignment rows deleted '||to_char(SQL%ROWCOUNT));

  hr_utility.set_location('PAY_YEAR_END_EXTRACT.TRASH',6);
  -- delete all the rows in payrolls for this permit , if no permit specified
  -- delete all the rows for this tax_district_reference else if no
  -- tax_district_reference specified delete all rows within the business group
     delete from pay_gb_year_end_payrolls ye_roll
       where exists ( select '1' from pay_payrolls_f p,
       hr_soft_coding_keyflex flex, hr_organization_information org
       where p.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
       and   org.ORG_INFORMATION_CONTEXT = 'Tax Details References'
       and   org.org_information1 = flex.segment1
       and   p.business_group_id = p_business_group_id
       and   org.organization_id = p_business_group_id
       and   nvl(p_permit,substr(flex.segment10,1,12)) =
						substr(flex.segment10,1,12)
       and   nvl(l_tax_district_reference,substr(flex.segment1,1,3)) =
					        substr(flex.segment1,1,3)
       and   nvl(l_tax_reference_number,
		substr(ltrim(substr(org_information1,4,8),'/') ,1,7)) =
       		substr(ltrim(substr(org_information1,4,8),'/') ,1,7)
	and   l_end_year between
	      p.effective_start_date and p.effective_end_date
       and   ye_roll.payroll_id = p.payroll_id);

	plog ( '_  payroll rows deleted '||to_char(SQL%ROWCOUNT));

     commit;

end trash;
--
--
--------------------------- extract -----------------------------------
/*
NAME
  extract
DESCRIPTION
  populate the eoy tables
NOTES
*/
procedure extract(p_permit in varchar2  ,
                  p_business_group_id in number,
		  p_tax_district_ref in varchar2,
                  p_year in number,
                  p_request_id in number,
                  p_niy in varchar2,
                  p_retcode out number ,
                  p_errbuf out varchar2
                   ) is
  --
  --
--   ensure the whole of the year_end_all table is populated even if
--   selecting on 1 permit, as there may be other payrolls on the selected
--   assignments

-- declare local cursors
-- get the defined balance id for specified balance and dimension
   CURSOR get_defined_balance_id
                 (p_balance_name varchar2, p_dimension_name varchar2) is
--
        select defined_balance_id
        from pay_defined_balances db,
             pay_balance_types    b,
             pay_balance_dimensions d
             where b.balance_name = p_balance_name
             and   d.dimension_name = p_dimension_name
             and   db.balance_type_id = b.balance_type_id
             and   db.balance_dimension_id = d.balance_dimension_id;

   CURSOR get_people is
--      fetch all the person rows
        select assignment_id, effective_end_date, sex, payroll_id,
          previous_year_asg_action_id, last_asg_action_id, termination_type
        from pay_gb_year_end_assignments
        where request_id = p_request_id;
--

   CURSOR get_invalid_multiple_asg is
--      fetch any ye_asg rows that have people with assignments in different
--      permits but within the same tax reference

	select ye_asg.rowid ye_asg_rowid
		from pay_gb_year_end_assignments ye_asg
                    , pay_gb_year_end_payrolls ye_roll
	where exists ( select person_id
			from per_assignments_f asg,
       		             pay_gb_year_end_payrolls    yep2
		   where  yep2.payroll_id = ye_asg.payroll_id
		   and yep2.TAX_REFERENCE_NUMBER = ye_roll.TAX_REFERENCE_NUMBER
                   and yep2.PERMIT_NUMBER <> ye_roll.PERMIT_NUMBER
		   and asg.effective_start_date < ye_roll.end_year
		   and asg.effective_end_date >= ye_roll.START_YEAR
		   and ye_asg.person_id = asg.person_id)
        and MULTIPLE_ASG_FLAG is not null
	and ye_asg.payroll_id = ye_roll.payroll_id
        and request_id = p_request_id;
--
   CURSOR get_multi_asg_people is
--      fetch all the person rows
        select assignment_id, effective_end_date, sex, payroll_id,
               previous_year_asg_action_id, last_asg_action_id, termination_type
        from pay_gb_year_end_assignments
        where request_id = p_request_id
          and eoy_primary_flag = 'Y';
--
--
    CURSOR get_multi_asg_prim_details(l_asg_id number)  is
--       fetch any multiple assignment details for to be given to the
--        primary assignment
                  select yea_prim.assignment_id  s_asg_id,
                yea_prim.effective_end_date  s_end_date,
                yev.ni_category_code s_ni_cat_code,
                'M',
                sum(yev.EARNINGS) s_earnings,
                sum(yev.TOTAL_CONTRIBUTIONS) s_tot_con,
                sum(yev.EMPLOYEES_CONTRIBUTIONS) s_ees_con,
                sum(yev.EARNINGS_CONTRACTED_OUT) s_earnings_co,
                sum(yev.CONTRIBUTIONS_CONTRACTED_OUT) s_con_co
          from pay_gb_year_end_assignments yea_prim,
               pay_gb_year_end_assignments ye_asg,
               pay_gb_year_end_values yev,
               pay_gb_year_end_payrolls yep_prim,
               pay_gb_year_end_payrolls ye_roll
             where yea_prim.eoy_primary_flag = 'Y'
             and   ye_asg.person_id = yea_prim.person_id
             and   yea_prim.payroll_id = yep_prim.payroll_id
             and   ye_asg.payroll_id = ye_roll.payroll_id
             and   ye_asg.assignment_id = yev.assignment_id
             and   ye_asg.effective_end_date = yev.effective_end_date
             and   yep_prim.tax_reference_number = ye_roll.tax_reference_number
             and   (yev.total_contributions <> 0 or yev.ni_category_code = 'X')
             and   yea_prim.assignment_id = l_asg_id
             and   yea_prim.request_id = p_request_id
                     group by   yea_prim.assignment_id,
                                yea_prim.effective_end_date,
                                yev.ni_category_code;
--
--
   CURSOR get_scon_bal(cp_l_asg_id number, cp_inp_val number, cp_element_type number) is
--      fetch the scon balances for NI F, NI G and/or NI S
select substr(bal.balance_name,4,1) cat_code,
       substr(HR_GENERAL.DECODE_LOOKUP('GB_SCON',decode(substr(bal.balance_name,4,1),
               'F',nvl(max(EV_SCON.screen_entry_value),
                   pay_year_end_extract.get_nearest_scon(
                   max(EV_SCON.element_entry_id),'F',max(PACT.effective_date))),
               'G',nvl(max(EV_SCON.screen_entry_value),
                   pay_year_end_extract.get_nearest_scon(
                   max(EV_SCON.element_entry_id),'G',max(PACT.effective_date))),
               'S',nvl(max(EV_SCON.screen_entry_value),
                   pay_year_end_extract.get_nearest_scon(
                   max(EV_SCON.element_entry_id),'S',max(PACT.effective_date))),
               null)),1,9) scon,
       100*nvl(sum(decode(substr(bal.balance_name,6),'Able',
	fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0) able,
       100*nvl(sum(decode(substr(bal.balance_name,6),'Total',
	fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0) Total,
       100*nvl(sum(decode(substr(bal.balance_name,6),'Employee',
	fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0) Employee,
       --
       -- Bug Fix 678573 Start
       --
       100*nvl(sum(decode(substr(bal.balance_name,6),'Employer',
	fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0) Employer,
       --
       -- Bug Fix 678573 End
       --
       100*nvl(sum(decode(substr(bal.balance_name,6),'CO Able',
	fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0) CO_able,
       100*nvl(sum(decode(substr(bal.balance_name,6),'CO',
	fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale,0)),0) CO
        from pay_balance_feeds_f     FEED
       ,pay_balance_types        BAL
       ,pay_run_result_values    TARGET
       ,pay_run_results          RR
       ,pay_element_entry_values_f EV_SCON
       ,pay_element_entries_f    E_NI
       ,pay_element_links_f      EL_NI
       ,pay_payroll_actions      PACT
       ,pay_assignment_actions   ASSACT
       ,pay_payroll_actions      BACT
       ,per_time_periods         BPTP
       ,per_time_periods         PPTP
       ,pay_assignment_actions   BAL_ASSACT
where  BAL_ASSACT.assignment_action_id = cp_l_asg_id
and    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
and    FEED.balance_type_id    = BAL.balance_type_id
and    BAL.balance_name	       like 'NI%'
and    substr(BAL.balance_name,4,1) in ('F','G','S')
and    FEED.input_value_id     = TARGET.input_value_id
and    TARGET.run_result_id    = RR.run_result_id
and    nvl(TARGET.result_value,'0') <> '0'
and    RR.assignment_action_id = ASSACT.assignment_action_id
and    E_NI.assignment_id      = BAL_ASSACT.assignment_id
and    EV_SCON.input_value_id  +
       decode(EV_SCON.element_entry_id,null,0,0) = cp_inp_val
and    EV_SCON.element_entry_id = E_NI.element_entry_id
and    EL_NI.element_link_id    = E_NI.element_link_id
and    EL_NI.element_type_id    = cp_element_type
and    PACT.effective_date between
	E_NI.effective_start_date and E_NI.effective_end_date
and    PACT.effective_date between
	EL_NI.effective_start_date and EL_NI.effective_end_date
and    PACT.effective_date between
	EV_SCON.effective_start_date and EV_SCON.effective_end_date
and    ASSACT.payroll_action_id = PACT.payroll_action_id
and    PACT.effective_date between
          FEED.effective_start_date and FEED.effective_end_date
and    RR.status in ('P','PA')
and    BPTP.time_period_id = BACT.time_period_id
and    PPTP.time_period_id = PACT.time_period_id
and    PPTP.regular_payment_date >= /* fin year start */
               ( to_date('06-04-' || to_char( to_number(
                 to_char( BPTP.regular_payment_date,'YYYY'))
          +  decode(sign( BPTP.regular_payment_date - to_date('06-04-'
              || to_char(BPTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY'))
and    PACT.effective_date >=
       /* find the latest td payroll transfer date - compare each of the */
       /* assignment rows with its predecessor looking for the payroll   */
       /* that had a different tax district at that date */
       ( select nvl(max(ASS.effective_start_date),
	fnd_date.canonical_to_date('01-01-0001'))
	from per_assignments_f 	ASS
	,pay_payrolls_f         NROLL
       	,hr_soft_coding_keyflex	FLEX
	,per_assignments_f 	PASS  /* previous assignment */
       	,pay_payrolls_f         PROLL
       	,hr_soft_coding_keyflex PFLEX
	where ASS.assignment_id = BAL_ASSACT.assignment_id
	and NROLL.payroll_id = ASS.payroll_id
	and ASS.effective_start_date between
		NROLL.effective_start_date and NROLL.effective_end_date
	and NROLL.soft_coding_keyflex_id = FLEX.soft_coding_keyflex_id
	and ASS.assignment_id = PASS.assignment_id
	and PASS.effective_end_date = (ASS.effective_start_date - 1)
	and ASS.effective_start_date <= BACT.effective_date
	and PROLL.payroll_id = PASS.payroll_id
	and ASS.effective_start_date between
		PROLL.effective_start_date and PROLL.effective_end_date
	and PROLL.soft_coding_keyflex_id = PFLEX.soft_coding_keyflex_id
        and ASS.payroll_id <> PASS.payroll_id
	and FLEX.segment1 <> PFLEX.segment1
  )
and    ASSACT.action_sequence <= BAL_ASSACT.action_sequence
and    ASSACT.assignment_id = BAL_ASSACT.assignment_id
group by EV_SCON.screen_entry_value, substr(bal.balance_name,4,1)
order by EV_SCON.screen_entry_value, substr(bal.balance_name,4,1);
--
--
  l_tax_district_reference pay_gb_year_end_payrolls.tax_district_reference%TYPE;
  l_tax_reference_number   pay_gb_year_end_payrolls.tax_reference_number%TYPE;
  l_start_year    date;
  l_end_year      date;
  l_niy           number(9);
  l_niy_id        number(9);
  l_niy_ly_id     number(9);
  l_ni_tot	number(9);
  l_ni_ees	number(9);
  l_ni_able	number(9);
  l_ni_co_able	number(9);
  l_ni_co		number(9);
  l_nia_able_id   number(9);
  l_nia_id        number(9);
  l_nia_tot_id    number(9);
  l_nib_able_id   number(9);
  l_nib_id        number(9);
  l_nib_tot_id    number(9);
  l_nic_tot_id    number(9);
  l_nid_able_id   number(9);
  l_nid_id        number(9);
  l_nid_tot_id    number(9);
  l_nid_co_able_id number(9);
  l_nid_co_id     number(9);
  l_nie_able_id   number(9);
  l_nie_id        number(9);
  l_nie_tot_id    number(9);
  l_nie_co_able_id number(9);
  l_nie_co_id     number(9);
  l_nif_tot_id    number(9);
  l_nig_tot_id    number(9);
  l_nis_tot_id    number(9);
  l_nip_id        number(9);
  l_nip           number(9);
  l_ssp           number(9);
  l_smp           number(9);
  l_gross         number(9);
  l_paye          number(9);
  l_super         number(9);
  l_widow         number(9);
  l_taxable       number(9);
  l_ssp_id        number(9);
  l_smp_id        number(9);
  l_gross_id      number(9);
  l_paye_id       number(9);
  l_super_id      number(9);
  l_widow_id      number(9);
  l_taxable_id    number(9);
  l_paye_details_id number(9);
  l_max_run_result_id number(9);
  l_ni_id         number(9);
  l_category_input_id number(9);
  l_scon_input_id number(9);
  l_error_text    varchar2(132);
  l_count         number(9);
  l_count_values  number(9);
  l_earnings      number(9);
  l_asg_id        number(9);
--
  tax_dist_ref_error        exception; -- raised when l_tax_district_reference
--                                        has incorrect format
--

begin  -- ( extract

  plog('Year End Extract - Permit(' ||p_permit||')');
  plog('_                  BG('     ||to_char(p_business_group_id)||')');
  plog('_                  Tax_Ref('||p_tax_district_ref||')');
  plog('_                  NI_Y('||p_niy||')');
  plog('_                  Year('   ||to_char(p_year)||')');
  plog('_                  Request('||to_char(p_request_id)||')');
--
--  Check tax_district_reference input is valid (ie. numeric) else raise error
begin
  l_tax_district_reference := fnd_number.canonical_to_number(substr(p_tax_district_ref,1,3));
  if l_tax_district_reference < 0 then raise value_error; end if;
exception
  when value_error then
    raise tax_dist_ref_error;
end;
--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',1);
-- delete old data
  plog ( '_ Delete previous extracted rows for this selection   ');
  pay_year_end_extract.trash(p_permit,p_business_group_id,
                                  p_tax_district_ref,p_year);

begin  -- ( setup ids
--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',2);

   p_retcode := 1; -- default extract to success
--   l_tax_district_reference := fnd_number.canonical_to_number(substr(p_tax_district_ref,1,3));
   l_tax_reference_number   := substr(ltrim(substr(p_tax_district_ref,
                                                              4,8),'/') ,1,7);

--      set up the statutory start and end year
	l_start_year := to_date('06-04-'||(p_year - 1),'dd-mm-yyyy');
	l_end_year   := to_date('05-04-'||p_year,'dd-mm-yyyy');
--
--      find the defined balance id's for balance / dimension combos
        open get_defined_balance_id('NI Y','_ASG_STAT_YTD');
        fetch get_defined_balance_id into l_niy_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI Y Last Year','_ASG_STAT_YTD');
        fetch get_defined_balance_id into l_niy_ly_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI A Able','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nia_able_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI A Employee','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nia_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI A Total','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nia_tot_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI B Able','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nib_able_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI B Employee','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nib_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI B Total','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nib_tot_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI C Employer','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nic_tot_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI D Able','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nid_able_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI D Employee','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nid_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI D Total','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nid_tot_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI D CO Able','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nid_co_able_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI D CO','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nid_co_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI E Able','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nie_able_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI E Employee','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nie_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI E Total','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nie_tot_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI E CO Able','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nie_co_able_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI E CO','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nie_co_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI F Total','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nif_tot_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI G Total','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nig_tot_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NI S Employer','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nis_tot_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('NIC Holiday','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_nip_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('SSP Total','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_ssp_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('SMP Total','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_smp_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('Gross Pay','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_gross_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('PAYE','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_paye_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('Superannuation Total','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_super_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('Widows and Orphans','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_widow_id;
        close get_defined_balance_id;
--
        open get_defined_balance_id('Taxable Pay','_ASG_TD_YTD');
        fetch get_defined_balance_id into l_taxable_id;
        close get_defined_balance_id;
--
        select element_type_id into l_paye_details_id from
                pay_element_types_f where element_name = 'PAYE Details'
                and l_end_year between
                    effective_start_date and effective_end_date;
--
        select 10 * pay_run_results_s.nextval
               into l_max_run_result_id
               from dual;
--
        select element_type_id into l_ni_id from
                pay_element_types_f where element_name = 'NI'
                and l_end_year between
                    effective_start_date and effective_end_date;
--
        select input_value_id into l_category_input_id from
                pay_input_values_f
		where name = 'Category'
                and element_type_id = l_ni_id
                and l_end_year between
                    effective_start_date and effective_end_date;
--
        select input_value_id into l_scon_input_id from
                pay_input_values_f
		where name = 'SCON'
                and element_type_id = l_ni_id
                and l_end_year between
                    effective_start_date and effective_end_date;
--
end; -- ) setup ids

/* populate pay_gb_year_end_payrolls table for each payroll */
/* ISSUE - check ACCOUNTS_OFFICE_REF looks like its disabled */
--     pick up SCL segments and Tax Reference Info
--     sometime the tax reference is delimited by a '/' remove this */
begin -- ( insert pay_gb_year_end_payrolls
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',4);
insert into pay_gb_year_end_payrolls
       ( BUSINESS_GROUP_ID,
         PAYROLL_ID,
         PERMIT_NUMBER,
         PAYROLL_NAME,
         TAX_DISTRICT_REFERENCE,
         TAX_REFERENCE_NUMBER ,
         TAX_DISTRICT_NAME ,
         TAX_YEAR,
         EMPLOYERS_NAME,
         EMPLOYERS_ADDRESS_LINE,
         ECON ,
         SMP_RECOVERED,
         SMP_COMPENSATION,
         SSP_RECOVERED )
select p.business_group_id               business_group_id,
       p.payroll_id			 PAYROLL_ID,
       substr(flex.segment10,1,12)       PERMIT_NUMBER,
       p.payroll_name			 PAYROLL_NAME,
       substr(flex.segment1,1,3)         TAX_DISTRICT_REFERENCE,
       substr(ltrim(substr(org_information1,4,8),'/') ,1,7) TAX_REFERENCE,
       substr(org.org_information2 ,1,40) TAX_DISTRICT_NAME,
       p_year                            TAX_YEAR,
       substr(org.org_information3,1,36) EMPLOYERS_NAME,
       substr(org.org_information4,1,60) EMPLOYERS_ADDRESS_LINE,
       substr(org.org_information7,1,9)  ECON,
       flex.segment11 * 100	         SMP_RECOVERED,
       flex.segment12 * 100              SMP_COMPENSATION,
       flex.segment13 * 100              SSP_RECOVERED
	from pay_payrolls_f p,
	hr_soft_coding_keyflex flex, hr_organization_information org
	where p.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
	and   org.ORG_INFORMATION_CONTEXT = 'Tax Details References'
	and   org.org_information1 = flex.segment1
        and   p.business_group_id = p_business_group_id
        and   org.organization_id = p_business_group_id
	and   l_end_year between
	      p.effective_start_date and p.effective_end_date
	and not exists ( select null from pay_gb_year_end_payrolls ye_roll
                 where ye_roll.payroll_id = p.payroll_id ) ;
--
--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',6);
-- set the start and end dates for the payroll year
update pay_gb_year_end_payrolls ye_roll
set ( START_YEAR, END_YEAR ,PERIOD_TYPE, MAX_PERIOD_NUMBER) =
( select min(start_date), max(end_date), max(PERIOD_TYPE), max(PERIOD_NUM)
               from per_time_periods ptp
               where PTP.payroll_id = ye_roll.payroll_id
                and PTP.regular_payment_date between
                                      l_start_year and l_end_year);
--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',8);
-- set the start and end dates for the previous payroll year
update pay_gb_year_end_payrolls ye_roll
 set ( START_PREVIOUS_YEAR, END_PREVIOUS_YEAR ) =
( select min(start_date), max(end_date) from per_time_periods ptp
               where PTP.payroll_id = ye_roll.payroll_id
                and PTP.regular_payment_date between
                        add_months(l_start_year,-12)
                    and add_months(l_end_year,-12));
--
commit;
   plog ( '_ pay_gb_year_end_payrolls data populated  '||to_char(SQL%ROWCOUNT));


end;  --  ) insert pay_gb_year_end_payrolls

begin -- ( insert assignments
-- select all the assignments for a particular permit
-- note we only want the last date effective row - the permit on the
-- payroll for this dictates where it is reported even if the assignment
-- has been on more than one payroll in the year. The exception to this
-- is where tax district/reference transfers have occurred
-- find the latest assignment row this payroll year
-- add any assignment rows that are for tax reference changes
-- pick up latest effective end date and latest payroll
-- don't pick up null permits and if ni y is not reportable only pick up
-- current year assignments
--
--
--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',12);
  hr_utility.trace( 'extract the latest assignments ' );
insert into pay_gb_year_end_assignments (
            assignment_id,
            payroll_id,
            effective_end_date,
            request_id ,
            extract_date,
            assignment_number,
            person_id,
            organization_id,
            location_id,
            people_group_id)
select      ass.assignment_id,
            ass.payroll_id,
            ass.effective_end_date,
            p_request_id,
            sysdate ,
            ass.assignment_number,
            ass.person_id,
            ass.organization_id,
            ass.location_id,
            ass.people_group_id
       from per_assignments_f  ASS,
            pay_gb_year_end_payrolls   ye_roll
       where ASS.payroll_id = ye_roll.payroll_id
/* 2 years scan to pick up NI Y last year - note we don't need to
   worry about transfers for NI Y as it uses the STAT_YTD dimension */
       and ASS.effective_end_date >=
             decode(p_niy,'N', ye_roll.START_YEAR,
             nvl(ye_roll.START_PREVIOUS_YEAR,ye_roll.START_YEAR))
       and ASS.effective_start_date <= ye_roll.END_YEAR
       and not exists ( select 1 from per_assignments_f ass2,
                                      pay_gb_year_end_payrolls ye_roll2
                          where ass.assignment_id = ass2.assignment_id
                          and ass2.payroll_id = ye_roll2.payroll_id
                          and ass2.effective_end_date > ass.effective_end_date
                          and ass2.effective_end_date >=
                                        decode(p_niy,'N', ye_roll2.START_YEAR,
                          nvl(ye_roll2.START_PREVIOUS_YEAR,ye_roll2.START_YEAR))
                          and ass2.effective_start_date <= ye_roll2.END_YEAR)
         and exists
         ( select yep2.payroll_id from pay_gb_year_end_payrolls yep2
              where ass.payroll_id = yep2.payroll_id
              and yep2.permit_number = nvl(p_permit,nvl(yep2.permit_number,'x'))
               and   nvl(l_tax_district_reference,yep2.tax_district_reference) =
                                                    yep2.tax_district_reference
                 and   nvl(l_tax_reference_number,yep2.tax_reference_number) =
                                                    yep2.tax_reference_number
                and yep2.business_group_id = p_business_group_id);
       plog ( '_ assignments extracted '||to_char(SQL%ROWCOUNT));
--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',13);
  hr_utility.trace( 'extract the tax reference transfer asgs' );
-- revised the select to only extract payroll transfers and
-- to check the tax reference is different date effective the start date of new
-- asg assumption here is that the old payroll still exists the day after transfer
insert into pay_gb_year_end_assignments (
            assignment_id,
            payroll_id,
            effective_end_date,
            request_id ,
            extract_date,
            termination_date,
            termination_type,
            assignment_number,
            person_id,
            organization_id,
            location_id,
            people_group_id)
select      pass.assignment_id,
            pass.payroll_id,
            pass.effective_end_date,
            p_request_id,
            sysdate,
            pass.effective_end_date termination_date,
            'R' termination_type,
            ass.assignment_number,
            ass.person_id,
            ass.organization_id,
            ass.location_id,
            ass.people_group_id
        from per_assignments_f  ASS
        ,pay_payrolls_f         NROLL
        ,hr_soft_coding_keyflex FLEX
        ,per_assignments_f      PASS
        ,pay_payrolls_f         PROLL
        ,hr_soft_coding_keyflex PFLEX
        ,pay_gb_year_end_payrolls       ye_roll
        where  NROLL.payroll_id = ASS.payroll_id
        and ye_roll.payroll_id = PASS.payroll_id
        and ASS.effective_start_date between
                NROLL.effective_start_date and NROLL.effective_end_date
        and NROLL.soft_coding_keyflex_id = FLEX.soft_coding_keyflex_id
        and ASS.assignment_id = PASS.assignment_id
        and PASS.effective_end_date = (ASS.effective_start_date - 1)
       and PASS.effective_end_date >= ye_roll.START_YEAR
       and PASS.effective_start_date <= ye_roll.END_YEAR
        and PROLL.payroll_id = PASS.payroll_id
        and ASS.effective_start_date between
                PROLL.effective_start_date and PROLL.effective_end_date
        and PROLL.soft_coding_keyflex_id = PFLEX.soft_coding_keyflex_id
        and ASS.payroll_id <> PASS.payroll_id
        and FLEX.segment1 <> PFLEX.segment1
        and not exists ( select '1' from pay_gb_year_end_assignments ye_asg
                     where ye_asg.assignment_id      = pass.assignment_id
                     and   ye_asg.effective_end_date = pass.effective_end_date )
        and exists ( select null from pay_gb_year_end_payrolls ye_roll
                   where ye_roll.payroll_id = pass.payroll_id
                 and ye_roll.permit_number = nvl(p_permit,ye_roll.permit_number)
              and nvl(l_tax_district_reference,ye_roll.tax_district_reference) =
                                                  ye_roll.tax_district_reference
                  and nvl(l_tax_reference_number,ye_roll.tax_reference_number) =
                                                    ye_roll.tax_reference_number
                   and ye_roll.business_group_id = p_business_group_id);
     plog ( '_ tax ref transfer assignments extracted '||to_char(SQL%ROWCOUNT));
--
/* we need a condition here - if the extract is for all permits we */
/* do a quick set effective start date by looking at the prior row on */
/* the ye_asg table. If we are extracting for a particular permit we can't */
/* rely on the person records being on the table so set the start date */
/* from the base table */
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',14);
  hr_utility.trace( 'set the effective_start_date for transfers' );
  if p_permit is null and p_tax_district_ref is null then -- [ for null permit
     update pay_gb_year_end_assignments ye_asg set ( effective_start_date ) =
       (select max(effective_end_date) + 1 from pay_gb_year_end_assignments yea2
                where yea2.assignment_id = ye_asg.assignment_id
                and   yea2.effective_end_date < ye_asg.effective_end_date )
                where ye_asg.request_id = p_request_id;

   plog ( '_ transfers effective_start_date quick set '||to_char(SQL%ROWCOUNT));
--
                      else
/* slow effective start date set */
/* big overhead here is testing the value of tax reference date effective
as of the payroll transfer - could we instead assume that tax reference
on the payroll is not updated mid year? If so the following is simplified */
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',16);
	update pay_gb_year_end_assignments ye_asg set ( effective_start_date ) =
	( select max(ASS.effective_start_date)
                              from per_assignments_f  ASS
                              ,pay_payrolls_f         NROLL
                              ,hr_soft_coding_keyflex FLEX
                              ,per_assignments_f      PASS
                              ,pay_payrolls_f         PROLL
                              ,hr_soft_coding_keyflex PFLEX
                              ,pay_gb_year_end_payrolls      ye_roll
                  where ass.assignment_id = ye_asg.assignment_id
                    and  ass.effective_start_date < ye_asg.effective_end_date
                    and  NROLL.payroll_id = ASS.payroll_id
                    and ye_roll.payroll_id = PASS.payroll_id
                    and ASS.effective_start_date between
                       NROLL.effective_start_date and NROLL.effective_end_date
                  and NROLL.soft_coding_keyflex_id = FLEX.soft_coding_keyflex_id
                   and ASS.assignment_id = PASS.assignment_id
                   and PASS.effective_end_date = (ASS.effective_start_date - 1)
                   and PASS.effective_end_date >= ye_roll.START_YEAR
                   and PASS.effective_start_date <= ye_roll.END_YEAR
                   and PROLL.payroll_id = PASS.payroll_id
		   and PASS.payroll_id <> ASS.payroll_id
                   and ASS.effective_start_date between
                         PROLL.effective_start_date and PROLL.effective_end_date
                 and PROLL.soft_coding_keyflex_id = PFLEX.soft_coding_keyflex_id
                    and FLEX.segment1 <> PFLEX.segment1 )
	where ye_asg.request_id = p_request_id
	and ye_asg.effective_start_date is null;
--
       plog ( '_ transfers effective_start_date set '||to_char(SQL%ROWCOUNT));
			end if; -- ] null permit
--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',18);
  hr_utility.trace( 'find the last action from the current year' );
UPDATE PAY_GB_YEAR_END_ASSIGNMENTS ye_asg
	SET (LAST_ASG_ACTION_ID, LAST_EFFECTIVE_DATE) = (
	  select 	assact.assignment_action_id,
			pact.effective_date
	  from    	pay_payroll_actions    pact,
			pay_assignment_actions assact
	  where		assact.payroll_action_id = pact.payroll_action_id
	  and		ye_asg.assignment_id = assact.assignment_id
	  and		ye_asg.request_id = p_request_id
	  and     	assact.action_sequence =
		(
		select max(assact2.action_sequence)
		from    pay_assignment_actions assact2,
			pay_payroll_actions    pact2,
			pay_gb_year_end_payrolls  ye_roll
		where   assact2.assignment_id = ye_asg.assignment_id
       		and     assact2.payroll_action_id = pact2.payroll_action_id
       		and     pact2.payroll_id  = ye_roll.payroll_id
       		and     pact2.action_type in ( 'Q','R','B','I')
       		and     assact2.action_status = 'C'
       		and     pact2.effective_date <= ye_asg.effective_end_date
       		and     pact2.effective_date between
               		      nvl(ye_asg.effective_start_date,ye_roll.START_YEAR)
		     	and       ye_roll.END_YEAR
       		and not exists(
			select '1'
			from	pay_action_interlocks pai,
				pay_assignment_actions assact3,
				pay_payroll_actions pact3
			where   pai.locked_action_id = assact2.assignment_action_id
			and     pai.locking_action_id = assact3.assignment_action_id
			and     pact3.payroll_action_id = assact3.payroll_action_id
			and     pact3.action_type = 'V'
			and     assact3.action_status = 'C'))
)
WHERE ye_asg.request_id = p_request_id;
       plog ( '_ latest assignment_action found '||to_char(SQL%ROWCOUNT));
--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',20);
  hr_utility.trace( 'Pick up person details as of stat_end_date' );
update pay_gb_year_end_assignments ye_asg set
 ( LAST_NAME, FIRST_NAME, MIDDLE_NAME, DATE_OF_BIRTH, TITLE,
   EXPENSE_CHECK_SEND_TO_ADDRESS, NATIONAL_INSURANCE_NUMBER, SEX,
   PENSIONER_INDICATOR, MULTIPLE_ASG_FLAG) =
( select substr(last_name, 1,20) LAST_NAME,
         substr(FIRST_NAME, 1,16) FIRST_NAME,
         substr(MIDDLE_NAMES,1,7) MIDDLE_NAMES,
         DATE_OF_BIRTH,  TITLE,
        substr(EXPENSE_CHECK_SEND_TO_ADDRESS,1,1) EXPENSE_CHECK_SENT_TO_ADDRESS,
         substr(NATIONAL_IDENTIFIER,1,9) NATIONAL_IDENTIFIER,
         substr(SEX,1,1) SEX ,
         decode(substr(PER_INFORMATION4,1,1),'Y','P',' ') PENSIONER_INDICATOR,
         decode(PER_INFORMATION9,'Y','Y',null) MULTIPLE_ASG_FLAG -- MII
         from per_people_f per
         where per.person_id = ye_asg.person_id
         and ye_asg.request_id = p_request_id
         and l_end_year between
             per.effective_start_date and per.effective_end_date )
where ye_asg.request_id = p_request_id;
       plog ( '_ pick up person details '||to_char(SQL%ROWCOUNT));
--
-- was this employee ever a director this year
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',22);
  hr_utility.trace( 'set director indicator ' );
update pay_gb_year_end_assignments ye_asg set ( DIRECTOR_INDICATOR ) =
         ( select 'D' from dual where exists ( select '1' from
                      per_people_f per
                      where ye_asg.person_id           = per.person_id
                      and per.effective_start_date    <= l_end_year
                      and per.effective_end_date      >= l_start_year
                      and substr(PER_INFORMATION2,1,1) = 'Y'))
where ye_asg.request_id = p_request_id;
       plog ( '_ set director indicator '||to_char(SQL%ROWCOUNT));

--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',24);
  hr_utility.trace( 'set termination date' );
update pay_gb_year_end_assignments ye_asg
    set ( termination_date, termination_type ) =
	(select actual_termination_date ,'L'
       		from per_periods_of_service pos,
                     per_assignments_f asg,
            	     pay_gb_year_end_payrolls ye_roll
	where pos.person_id = ye_asg.person_id
        and ye_asg.assignment_id = asg.assignment_id
        and ye_asg.effective_end_date = asg.effective_end_date
        and asg.period_of_service_id = pos.period_of_service_id
	and ye_asg.payroll_id = ye_roll.payroll_id
        and pos.actual_termination_date is not null
	and nvl(pos.LAST_STANDARD_PROCESS_DATE,pos.actual_termination_date)
          between
       	  nvl(ye_asg.effective_start_date,
		nvl(ye_roll.start_previous_year,ye_roll.start_year))
       	 and least(ye_asg.effective_end_date,ye_roll.end_year))
where ye_asg.request_id = p_request_id
and exists ( select 1
       		from per_periods_of_service pos,
                     per_assignments_f asg,
            	     pay_gb_year_end_payrolls ye_roll
	where pos.person_id = ye_asg.person_id
        and ye_asg.assignment_id = asg.assignment_id
        and ye_asg.effective_end_date = asg.effective_end_date
        and asg.period_of_service_id = pos.period_of_service_id
	and ye_asg.payroll_id = ye_roll.payroll_id
        and pos.actual_termination_date is not null
	and nvl(pos.LAST_STANDARD_PROCESS_DATE,pos.actual_termination_date)
          between
       	  nvl(ye_asg.effective_start_date,
		nvl(ye_roll.start_previous_year,ye_roll.start_year))
       	 and least(ye_asg.effective_end_date,ye_roll.end_year))
;
       plog ( '_ pick up termination date '||to_char(SQL%ROWCOUNT));
--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',25);
  hr_utility.trace( 'Set start of Employment' );
--
update pay_gb_year_end_assignments ye_asg
    set (start_of_emp) =
(select pos.date_start
       from per_periods_of_service pos,
                 per_assignments_f asg,
               pay_gb_year_end_payrolls ye_roll
where pos.person_id = ye_asg.person_id
        and ye_asg.assignment_id = asg.assignment_id
        and ye_asg.effective_end_date = asg.effective_end_date
        and asg.period_of_service_id = pos.period_of_service_id
        and ye_asg.payroll_id = ye_roll.payroll_id
        and pos.date_start between l_start_year and l_end_year)
where ye_asg.request_id = p_request_id
and exists ( select 1
       from per_periods_of_service pos,
                 per_assignments_f asg,
                 pay_gb_year_end_payrolls ye_roll
where pos.person_id = ye_asg.person_id
        and ye_asg.assignment_id = asg.assignment_id
        and ye_asg.effective_end_date = asg.effective_end_date
        and asg.period_of_service_id = pos.period_of_service_id
        and ye_asg.payroll_id = ye_roll.payroll_id
        and pos.date_start between l_start_year and l_end_year)
;
       plog ( '_ picked up '||to_char(SQL%ROWCOUNT) || ' Start dates');
--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',26);
  hr_utility.trace( 'Set Addresses' );
--
	update pay_gb_year_end_assignments ye_asg
   set (address_line1, address_line2, address_line3, town_or_city,
        county, postal_code) = (
   	select pad.address_line1,
   	       pad.address_line2,
           pad.address_line3,
   	       pad.town_or_city,
   	       SUBSTR(l.meaning,1,27) county,
   	       SUBSTR(pad.postal_code,1,8)
   	from   per_addresses pad,
   	       hr_lookups l
   	where  pad.person_id = ye_asg.person_id
   	and    pad.primary_flag = 'Y'
   	and    l.lookup_type(+) = 'GB_COUNTY'
   	and    l.lookup_code(+) = pad.region_1
   	and    sysdate between nvl(pad.date_from, sysdate)
   	                   and nvl(pad.date_to,   sysdate))
   where ye_asg.request_id = p_request_id;
   plog ( '_ picked up '||to_char(SQL%ROWCOUNT) || ' Addresses');

--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',27);
  hr_utility.trace( 'find the last action for last year' );
--
if p_niy = 'Y' then -- [ report NIY
UPDATE PAY_GB_YEAR_END_ASSIGNMENTS ye_asg
	SET (PREVIOUS_YEAR_ASG_ACTION_ID, PREVIOUS_YEAR_EFFECTIVE_DATE) = (
	  select 	assact.assignment_action_id,
			pact.effective_date
	  from    	pay_payroll_actions    pact,
			pay_assignment_actions assact
	  where		assact.payroll_action_id = pact.payroll_action_id
	  and		ye_asg.assignment_id = assact.assignment_id
	  and		ye_asg.request_id = p_request_id
	  and     	assact.action_sequence =
		(
		select max(assact2.action_sequence)
		from    pay_assignment_actions assact2,
			pay_payroll_actions    pact2,
			pay_gb_year_end_payrolls  ye_roll
		where   assact2.assignment_id = ye_asg.assignment_id
       		and     assact2.payroll_action_id = pact2.payroll_action_id
       		and     pact2.payroll_id  = ye_roll.payroll_id
       		and     pact2.action_type in ( 'Q','R','B','I')
       		and     assact2.action_status = 'C'
       		and     pact2.effective_date <= ye_asg.effective_end_date
       		and     pact2.effective_date between
               		      nvl(ye_asg.effective_start_date,ye_roll.START_PREVIOUS_YEAR)
		     	and       ye_roll.END_PREVIOUS_YEAR
       		and not exists(
			select '1'
			from	pay_action_interlocks pai,
				pay_assignment_actions assact3,
				pay_payroll_actions pact3
			where   pai.locked_action_id = assact2.assignment_action_id
			and     pai.locking_action_id = assact3.assignment_action_id
			and     pact3.payroll_action_id = assact3.payroll_action_id
			and     pact3.action_type = 'V'
			and     assact3.action_status = 'C'))
)
WHERE ye_asg.request_id = p_request_id;
  plog ( '_ last years latest assignment_action found '||to_char(SQL%ROWCOUNT));

   end if; -- ] report NIY
--
end; -- ) insert people

begin  -- ( insert balances
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',28);
  l_count := 0;
  for l_people in get_people loop -- { person loop
    l_count_values  := 0;  -- count the number of rows inserted into values for each
    l_niy           := 0;  -- initialize ni_y amount
    if p_niy = 'Y' then -- [ report NIY
      -- get the NI Y balance for each person
      if l_people.PREVIOUS_YEAR_ASG_ACTION_ID is not null then -- [ LY_ACTION
        hr_utility.trace( 'PREVIOUS_YEAR_ASG_ACTION_ID:'||
                             l_people.PREVIOUS_YEAR_ASG_ACTION_ID);
		    l_niy := 100 * hr_dirbal.get_balance(l_people.PREVIOUS_YEAR_ASG_ACTION_ID,
		                                             l_niy_id);
        l_count := l_count + 1;
      end if; -- ] LY_ACTION
      --
      --   if there is no NI Y in last year and this is the latest assignment row
      --   for this assignment (ie not a Reference Transfer row) then check for
      --   NI Y Last Year. Only the latest row to avoid double counting since
      --   ASG_STAT_YTD goes across reference transfers unlike ASG_TD_YTD
      if l_niy = 0  and l_people.LAST_ASG_ACTION_ID is not null
                    and ( l_people.termination_type is null
                         or l_people.termination_type = 'L' ) then -- [
        -- get the NI Y Last Year balance
	      l_niy := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_niy_ly_id);
        l_count := l_count + 1;
      end if; -- ]
--
      -- delete rows for last year that have no NI Y
      if ( l_niy is null or l_niy = 0 ) -- [
        and l_people.LAST_ASG_ACTION_ID is null then
        delete from pay_gb_year_end_assignments
        where assignment_id = l_people.assignment_id
        and   effective_end_date = l_people.effective_end_date;
      end if;  -- ]
--
      --  populate NI Y eoy values
      if l_niy <> 0 then -- [
        insert into pay_gb_year_end_values
        (ASSIGNMENT_ID,EFFECTIVE_END_DATE,NI_CATEGORY_CODE,REPORTABLE,
        TOTAL_CONTRIBUTIONS)
        values (
              l_people.assignment_id,
              l_people.effective_end_date,
              'Y'  ,
              'Y',
              l_niy );
      end if; -- ]
      -- MII
    else -- report NIY is not 'Y'
      if (l_people.LAST_ASG_ACTION_ID is null) then
        delete from pay_gb_year_end_assignments
        where assignment_id = l_people.assignment_id
        and   effective_end_date = l_people.effective_end_date;
      end if;
    end if; -- ] report NIY
--
    -- get the rest of the NI balances
    if l_people.LAST_ASG_ACTION_ID is not null then -- [ action exist
      hr_utility.trace( 'LAST_ASG_ACTION_ID:'||to_char(l_people.LAST_ASG_ACTION_ID));
-- populate NI A rows
      -- get the NI A Total Balance
      l_ni_tot := 0;
      l_ni_ees := 0;
      l_ni_able := 0;
      l_ni_tot := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nia_tot_id);
      l_count := l_count + 1;
--      if there is a total get the NI A and Able Balance
      if l_ni_tot <> 0 then -- [ A total exists
        l_ni_ees  := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nia_id);
        l_ni_able := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nia_able_id);
        l_count := l_count + 2;
--      populate year end values
        insert into pay_gb_year_end_values
          (ASSIGNMENT_ID,EFFECTIVE_END_DATE,NI_CATEGORY_CODE, REPORTABLE,
          EARNINGS,TOTAL_CONTRIBUTIONS,EMPLOYEES_CONTRIBUTIONS)
        values (
   		    l_people.assignment_id,
   		    l_people.effective_end_date,
   		    'A'  ,'Y',
    	    l_ni_able,
   		    l_ni_tot,
   		    l_ni_ees );
        l_count_values := l_count_values + 1;
      end if; -- ] total exists
-- populate NI B rows
      -- get the NI B Total Balance
      if l_people.sex = 'F' then -- [ cat B for Females only
        l_ni_tot := 0;
        l_ni_ees := 0;
        l_ni_able := 0;
        l_ni_tot := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nib_tot_id);
        l_count := l_count + 1;
--        if there is a total get the NI B and Able Balance
        if l_ni_tot <> 0 then -- [ B Total Exists
          l_ni_ees  := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nib_id);
          l_ni_able := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nib_able_id);
          l_count := l_count + 2;
--          populate year end values
          insert into pay_gb_year_end_values
            (ASSIGNMENT_ID,EFFECTIVE_END_DATE,NI_CATEGORY_CODE, REPORTABLE,
            EARNINGS,TOTAL_CONTRIBUTIONS,EMPLOYEES_CONTRIBUTIONS)
          values (
            l_people.assignment_id,
            l_people.effective_end_date,
            'B'  ,'Y',
            l_ni_able,
            l_ni_tot,
            l_ni_ees );
          l_count_values := l_count_values + 1;
        end if; -- ] B Total Exists
      end if; -- ] cat B for Females only
-- populate NI C rows
      l_ni_tot := 0;
      -- get the NI C Total Balance
      l_ni_tot := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nic_tot_id);
      l_count := l_count + 1;
--    populate year end values
      if l_ni_tot <> 0 then -- [ C Total exists
        insert into pay_gb_year_end_values
          (ASSIGNMENT_ID,EFFECTIVE_END_DATE,NI_CATEGORY_CODE, REPORTABLE,
          TOTAL_CONTRIBUTIONS)
        values (
          l_people.assignment_id,
          l_people.effective_end_date,
          'C'  ,'Y',
          l_ni_tot);
        l_count_values := l_count_values + 1;
      end if; -- ] C total Exists
-- populate NI D rows
--    get the NI D Total Balance
      l_ni_tot	:= 0;
      l_ni_ees	:= 0;
      l_ni_able	:= 0;
      l_ni_co_able	:= 0;
      l_ni_co		:= 0;
--
      l_ni_tot := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nid_tot_id);
      l_count := l_count + 1;
--      if there is a total get the NI D , CO and Able Balance
      if l_ni_tot <> 0 then -- [ D Total exists
        l_ni_ees  := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nid_id);
        l_ni_able := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nid_able_id);
        l_ni_co_able := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nid_co_able_id);
        l_ni_co   := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nid_co_id);
        l_count := l_count + 4;
--        populate year end values
      	insert into pay_gb_year_end_values
          (ASSIGNMENT_ID,EFFECTIVE_END_DATE,NI_CATEGORY_CODE, REPORTABLE,
          EARNINGS,TOTAL_CONTRIBUTIONS,EMPLOYEES_CONTRIBUTIONS,
          EARNINGS_CONTRACTED_OUT,CONTRIBUTIONS_CONTRACTED_OUT)
        values (
   		    l_people.assignment_id,
   		    l_people.effective_end_date,
   		    'D'  ,'Y',
    	    l_ni_able,
   		    l_ni_tot,
   		    l_ni_ees,
          l_ni_co_able,
          l_ni_co );
    		l_count_values := l_count_values + 1;
      end if; -- ]  D Total Exists
-- populate NI E rows
--    get the NI E Total Balance
      if l_people.sex = 'F' then -- [ cat E for Females only
        l_ni_tot	:= 0;
        l_ni_ees	:= 0;
        l_ni_able	:= 0;
        l_ni_co_able	:= 0;
        l_ni_co		:= 0;
        l_ni_tot := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nie_tot_id);
      	l_count := l_count + 1;
--        if there is a total get the NI E , CO and Able Balance
        if l_ni_tot <> 0 then -- [ E Total exists
          l_ni_ees  := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nie_id);
          l_ni_able := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nie_able_id);
          l_ni_co_able := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nie_co_able_id);
          l_ni_co   := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nie_co_id);
          l_count := l_count + 4;
--        populate year end values
      	  insert into pay_gb_year_end_values
            (ASSIGNMENT_ID,EFFECTIVE_END_DATE,NI_CATEGORY_CODE, REPORTABLE,
            EARNINGS,TOTAL_CONTRIBUTIONS,EMPLOYEES_CONTRIBUTIONS,
            EARNINGS_CONTRACTED_OUT,CONTRIBUTIONS_CONTRACTED_OUT)
          values (
     		    l_people.assignment_id,
     		    l_people.effective_end_date,
     		    'E'  ,'Y',
      	    l_ni_able,
     		    l_ni_tot,
     		    l_ni_ees,
            l_ni_co_able,
            l_ni_co );
          l_count_values := l_count_values + 1;
        end if;  -- ] E total exists
      end if; -- ] cat E for Females only
-- populate NI F, NI G and/or NI S rows
--    sum the NI F/G/S Total Balances
      l_ni_tot        := 0;
      l_ni_tot := hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nif_tot_id) +
                  hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nig_tot_id) +
                  hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_nis_tot_id);
      l_count := l_count + 3;
--    if there is a total get the balance
      if l_ni_tot <> 0 then -- [ F/G/S Total(s) exist(s)
--      open cursor and populate year end values
        declare
          wk_assignment_id number(10);
          wk_effective_end_date date;
          wk_cat_code varchar2(1);
          wk_able number(15,2) := 0;
          wk_Total number(15,2) := 0;
          wk_Employee number(15,2) := 0;
          wk_CO_able number(15,2) := 0;
          wk_CO number(15,2) := 0;
          wk_scon varchar2(20);
          wk_first_pass_yn varchar2(1) := 'Y';
        begin
          for scon_bal_rec in get_scon_bal(l_people.last_asg_action_id,
                                           l_scon_input_id, l_ni_id)
          loop
            if wk_first_pass_yn = 'Y'
            then
              wk_cat_code := scon_bal_rec.cat_code;
              wk_scon := scon_bal_rec.scon;
              wk_first_pass_yn := 'N';
            end if;
            --
            -- Bug Fix 678573 Start
            --
            if scon_bal_rec.cat_code = 'S' then
              scon_bal_rec.able := null;
              scon_bal_rec.Total := scon_bal_rec.Employer;
              scon_bal_rec.Employee := null;
              scon_bal_rec.CO_able := null;
              scon_bal_rec.CO := null;
            end if;
            --
            -- Bug Fix 678573 End
            --
            if wk_cat_code <> scon_bal_rec.cat_code or
              wk_scon <> scon_bal_rec.scon
            then
              insert into pay_gb_year_end_values
               (ASSIGNMENT_ID,EFFECTIVE_END_DATE,NI_CATEGORY_CODE, REPORTABLE,
                EARNINGS,TOTAL_CONTRIBUTIONS,EMPLOYEES_CONTRIBUTIONS,
                EARNINGS_CONTRACTED_OUT,CONTRIBUTIONS_CONTRACTED_OUT,SCON)
              values (
                l_people.assignment_id,
                l_people.effective_end_date,
                wk_cat_code,
                'Y',
                wk_able,
                wk_Total,
                wk_Employee,
                wk_CO_able,
                wk_CO,
                wk_scon);

              l_count := l_count + 4;
              wk_able := 0;
              wk_Total := 0;
              wk_Employee := 0;
              wk_CO_able := 0;
              wk_CO := 0;
            end if;
            wk_able := wk_able + nvl(scon_bal_rec.able, 0);
            wk_Total := wk_Total + nvl(scon_bal_rec.Total, 0);
            wk_Employee := wk_Employee + nvl(scon_bal_rec.Employee, 0);
            wk_CO_able := wk_CO_able + nvl(scon_bal_rec.CO_able, 0);
            wk_CO := wk_CO + nvl(scon_bal_rec.CO, 0);
            wk_cat_code := scon_bal_rec.cat_code;
            wk_scon := scon_bal_rec.scon;
            /*four balances (able,Employee,CO_able & CO) fetched - even*/
            /* though not necessary for NIS.                           */
            /* Also no gender check performed for NIG                  */
            l_count_values := l_count_values + 1;  /*one row inserted*/
          end loop;
          --
          if wk_first_pass_yn = 'N'
          then
            insert into pay_gb_year_end_values
             (ASSIGNMENT_ID,EFFECTIVE_END_DATE,NI_CATEGORY_CODE, REPORTABLE,
              EARNINGS,TOTAL_CONTRIBUTIONS,EMPLOYEES_CONTRIBUTIONS,
              EARNINGS_CONTRACTED_OUT,CONTRIBUTIONS_CONTRACTED_OUT,SCON)
            values (
              l_people.assignment_id,
              l_people.effective_end_date,
              wk_cat_code,
              'Y',
              wk_able,
              wk_Total,
              wk_Employee,
              wk_CO_able,
              wk_CO,
              wk_scon);
          end if;
        end;
      end if; -- ]  F/G/S Total(s) Exist(s)
--
      l_nip := 0;
      if l_nip_id <> 0 then
        l_nip := 100 * hr_dirbal.get_balance (l_people.LAST_ASG_ACTION_ID,l_nip_id);
        if l_nip <> 0 then
          insert into pay_gb_year_end_values
          (
            ASSIGNMENT_ID,
            EFFECTIVE_END_DATE,
            NI_CATEGORY_CODE,
            REPORTABLE,
            TOTAL_CONTRIBUTIONS
          )
          values
          (
            l_people.assignment_id,
            l_people.effective_end_date,
            'P',
            'Y',
            l_nip
          );
        end if;  -- l_nip <> 0
        l_count_values := l_count_values + 1;
      end if;  -- l_nip_id <> 0
--
--    if no values rows have been inserted set up a row with the current category
      if l_count_values = 0 then -- [ no category balances
        insert into pay_gb_year_end_values
          (ASSIGNMENT_ID,EFFECTIVE_END_DATE,NI_CATEGORY_CODE,REPORTABLE)
        select l_people.assignment_id,
          l_people.effective_end_date,
          SCREEN_ENTRY_VALUE,
          'Y'
        from pay_element_entries_f e,
          pay_element_entry_values_f v,
          pay_gb_year_end_payrolls ye_roll,
          pay_element_links_f link
      	where e.assignment_id = l_people.assignment_id
          and   v.input_value_id + 0 = l_category_input_id
          and   link.element_type_id = l_ni_id
          and   e.element_link_id = link.element_link_id
          and   e.element_entry_id = v.element_entry_id
          and   l_people.payroll_id = ye_roll.payroll_id
          and   least(l_people.effective_end_date,ye_roll.end_year)
            between link.effective_start_date and link.effective_end_date
          and   least(l_people.effective_end_date,ye_roll.end_year)
            between e.effective_start_date and e.effective_end_date
          and   least(l_people.effective_end_date,ye_roll.end_year)
            between v.effective_start_date and v.effective_end_date;
      end if; -- ] no category balances
-- populate the person balances
      if l_people.sex = 'F' then -- [ Maternity for females only
        l_smp   := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_smp_id);
        l_count := l_count + 1;
      else l_smp := 0;
      end if; -- ] Maternity for females only
      l_ssp   := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_ssp_id);
      l_gross := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_gross_id);
      l_paye  := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_paye_id);
      l_super := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_super_id);
      l_widow := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_widow_id);
      l_taxable := 100 * hr_dirbal.get_balance(l_people.LAST_ASG_ACTION_ID,l_taxable_id);
      l_count := l_count + 6;
      update pay_gb_year_end_assignments ye_asg set
     		SSP   			= l_ssp,
     		SMP 			= l_smp,
     		GROSS_PAY 		= l_gross,
     		TAX_PAID 		= l_paye,
     		SUPERANNUATION_PAID	= l_super,
     		WIDOWS_AND_ORPHANS 	= l_widow,
     		TAXABLE_PAY 		= l_taxable
      where assignment_id      = l_people.assignment_id
      and   effective_end_date = l_people.effective_end_date;
    end if;  -- ] action exists
  end loop; -- } person loop
  plog ( '_ balances fetched '||to_char(l_count));
end; -- ) insert balances
--
--
begin -- ( update non bal info
/* most people will have had paye calculated on the last run - pick these up */
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',30);
  hr_utility.trace( 'see if tax was calculated on the last run of the year' );
update pay_gb_year_end_assignments ye_asg set ( TAX_RUN_RESULT_ID ) =
(select RUN_RESULT_ID from pay_run_results r
        where r.element_type_id = l_paye_details_id
        and   r.status in ('P', 'PA')
        and   r.assignment_action_id = ye_asg.LAST_ASG_ACTION_ID )
where ye_asg.request_id = p_request_id;
plog ( '_ find out if the latest action computed PAYE '||to_char(SQL%ROWCOUNT));
--
/* if there are any who have no tax update find the latest update */
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',32);
  hr_utility.trace( 'find the latest tax calculation in the year' );
update pay_gb_year_end_assignments ye_asg set ( TAX_RUN_RESULT_ID ) =
(select r.RUN_RESULT_ID
from	pay_assignment_actions assact,
	pay_run_results	r
where	r.element_type_id+0 = l_paye_details_id + decode(assact.assignment_id,null,0,0)
and	r.assignment_action_id = assact.assignment_action_id
and     r.status in ('P', 'PA')
and	assact.assignment_id = ye_asg.assignment_id
and	assact.action_sequence = (
	select	max(assact2.action_sequence)
	from 	pay_assignment_actions assact2,
            	pay_payroll_actions pact,
            	pay_gb_year_end_payrolls ye_roll
       	where  	assact2.assignment_id = ye_asg.assignment_id
       	and   	ye_roll.payroll_id = pact.payroll_id
       	and   	pact.payroll_action_id = assact2.payroll_action_id
       	and   	pact.effective_date between ye_roll.start_year and ye_roll.end_year
       	and   	ye_asg.tax_run_result_id is null
       	and   	ye_asg.last_asg_action_id is not null /*run this year */
       	and   	pact.effective_date <= ye_asg.LAST_EFFECTIVE_DATE
					)
)
where ye_asg.TAX_RUN_RESULT_ID is null
and   ye_asg.last_asg_action_id is not null /* there has been a run this year */
and ye_asg.request_id = p_request_id;
  plog ( '_ find the latest action that computed PAYE '||to_char(SQL%ROWCOUNT));
--
-- Get the details from the element entry on the added criteria that
-- there exists an updating action id on the element_entry. In other words,
-- this was achieved using an Update Recurring rule.
--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',33);
  hr_utility.trace( 'Retrieve element entry update recurring');
update pay_gb_year_end_assignments ye_asg set
( TAX_CODE, W1_M1_INDICATOR,PREVIOUS_TAXABLE_PAY,PREVIOUS_TAX_PAID) =
(select max(decode(iv.name,'Tax Code',SCREEN_ENTRY_VALUE,null)) Tax_code,
        max(decode(iv.name,'Tax Basis',SCREEN_ENTRY_VALUE,null)) Tax_Basis,
        100 * fnd_number.canonical_to_number(max(decode(iv.name,'Pay Previous',
                            SCREEN_ENTRY_VALUE,null))) Pay_previous,
        100 * fnd_number.canonical_to_number(max(decode(iv.name,'Tax Previous',
                            SCREEN_ENTRY_VALUE,null))) Tax_previous
               from pay_element_entries_f e,
                    pay_element_entry_values_f v,
                    pay_gb_year_end_payrolls ye_roll,
                    pay_input_values_f iv,
                    pay_element_links_f link
                where e.assignment_id = ye_asg.assignment_id
                and   link.element_type_id = l_paye_details_id
                and   e.element_link_id = link.element_link_id
                and   e.element_entry_id = v.element_entry_id
                and   iv.input_value_id = v.input_value_id
                and   ye_asg.payroll_id = ye_roll.payroll_id
		and   e.updating_action_id is not null
                and   least(ye_asg.effective_end_date,ye_roll.end_year)
                  between link.effective_start_date and link.effective_end_date
                and   least(ye_asg.effective_end_date,ye_roll.end_year)
                  between e.effective_start_date and e.effective_end_date
                and   least(ye_asg.effective_end_date,ye_roll.end_year)
                  between iv.effective_start_date and iv.effective_end_date
                and   least(ye_asg.effective_end_date,ye_roll.end_year)
                  between v.effective_start_date and v.effective_end_date)
where  ye_asg.request_id = p_request_id;
       plog ( '_ default tax details set '||to_char(SQL%ROWCOUNT));
--
-- If there is no tax code forthcoming from the last query, retrieve the
-- details using the run result.
--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',34);
  hr_utility.trace( 'update taxcode with last taxcode used' );
update pay_gb_year_end_assignments ye_asg set
( TAX_CODE, W1_M1_INDICATOR,PREVIOUS_TAXABLE_PAY,PREVIOUS_TAX_PAID) =
(select max(decode(name,'Tax Code',result_value,null)) Tax_code,
	max(decode(name,'Tax Basis',result_value,null)) Tax_Basis,
	100 * fnd_number.canonical_to_number(max(decode(name,'Pay Previous',result_value,null))) Pay_previous,
	100 * fnd_number.canonical_to_number(max(decode(name,'Tax Previous',result_value,null))) Tax_previous
from pay_input_values_f v,
     pay_run_result_values rrv
     where rrv.RUN_RESULT_ID = ye_asg.TAX_RUN_RESULT_ID
     and v.INPUT_VALUE_ID = rrv.INPUT_VALUE_ID
     and v.element_type_id = l_paye_details_id )
where ye_asg.tax_code is null
and   ye_asg.request_id = p_request_id;
       plog ( '_ tax code set '||to_char(SQL%ROWCOUNT));
--
-- If there is still no tax code, use the element entry query without the
-- update recurring criteria.
--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',35);
  hr_utility.trace( 'default taxcode to element entry if no tax calc run');
update pay_gb_year_end_assignments ye_asg set
( TAX_CODE, W1_M1_INDICATOR,PREVIOUS_TAXABLE_PAY,PREVIOUS_TAX_PAID) =
(select max(decode(iv.name,'Tax Code',SCREEN_ENTRY_VALUE,null)) Tax_code,
        max(decode(iv.name,'Tax Basis',SCREEN_ENTRY_VALUE,null)) Tax_Basis,
        100 * fnd_number.canonical_to_number(max(decode(iv.name,'Pay Previous',
                            SCREEN_ENTRY_VALUE,null))) Pay_previous,
        100 * fnd_number.canonical_to_number(max(decode(iv.name,'Tax Previous',
			    SCREEN_ENTRY_VALUE,null))) Tax_previous
               from pay_element_entries_f e,
                    pay_element_entry_values_f v,
                    pay_gb_year_end_payrolls ye_roll,
                    pay_input_values_f iv,
                    pay_element_links_f link
                where e.assignment_id = ye_asg.assignment_id
                and   link.element_type_id = l_paye_details_id
                and   e.element_link_id = link.element_link_id
                and   e.element_entry_id = v.element_entry_id
                and   iv.input_value_id = v.input_value_id
                and   ye_asg.payroll_id = ye_roll.payroll_id
                and   least(ye_asg.effective_end_date,ye_roll.end_year)
                  between link.effective_start_date and link.effective_end_date
                and   least(ye_asg.effective_end_date,ye_roll.end_year)
                  between e.effective_start_date and e.effective_end_date
                and   least(ye_asg.effective_end_date,ye_roll.end_year)
                  between iv.effective_start_date and iv.effective_end_date
                and   least(ye_asg.effective_end_date,ye_roll.end_year)
                  between v.effective_start_date and v.effective_end_date)
where ye_asg.tax_code is null
and   ye_asg.request_id = p_request_id;
       plog ( '_ default tax details set '||to_char(SQL%ROWCOUNT));
--
--
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',36);
  hr_utility.trace( 'reset codes on Year End Assignment table' );
update pay_gb_year_end_assignments ye_asg set
 (   WEEK_53_INDICATOR, W1_M1_INDICATOR, TAX_REFUND, TAX_PAID,
     SUPERANNUATION_REFUND, SUPERANNUATION_PAID, TAX_CODE ) =
( select
   decode(ye_roll.MAX_PERIOD_NUMBER,53,'3',54,'4',56,'6',' ') WEEK_53_INDICATOR,
   decode(ye_asg.W1_M1_INDICATOR,'C',' ',decode(ptpt.NUMBER_PER_FISCAL_YEAR,
       1,'M',2,'M',4,'M',6,'M',12,'M',24,'M','W'))        W1_M1_INDICATOR,
   decode(sign(ye_asg.TAX_PAID),-1,'R',' ') 	          TAX_REFUND,
   ye_asg.TAX_PAID * sign(ye_asg.TAX_PAID)     	          TAX_PAID,
   decode(sign(ye_asg.SUPERANNUATION_PAID),-1,'R',' ')    SUPERANNUATION_REFUND,
   ye_asg.SUPERANNUATION_PAID *
                         sign(ye_asg.SUPERANNUATION_PAID) SUPERANNUATION_PAID,
   nvl(ye_asg.TAX_CODE,'NI') 				  TAX_CODE
  from pay_gb_year_end_payrolls ye_roll,
       per_time_period_types ptpt
  where ye_roll.payroll_id = ye_asg.payroll_id
  and ye_roll.period_type  = ptpt.period_type
  and ye_asg.request_id = p_request_id )
where ye_asg.request_id = p_request_id;
       plog ( '_ reset codes '||to_char(SQL%ROWCOUNT));
--
--
-- multiple assignment logic
-- function that fires when permit is specified that checks whether any
--    multiple assignmnet people have all their assignments extracted within
--    the one permit - if not error
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',40);
  hr_utility.trace( 'check that multiple asgs dont span permits');

     if p_permit is not null then -- [ permit not null

	     for l_invalid_masg in get_invalid_multiple_asg loop -- { invalid

                    select substr('EMPNO:'||ASSIGNMENT_NUMBER||
                                ' '||LAST_NAME||
                ' has multiple assignments on more than one permit',1,132) mess
                                into l_error_text
                         from pay_gb_year_end_assignments
                         where rowid = l_invalid_masg.ye_asg_rowid
                         and rownum = 1;

                         hr_utility.trace(l_error_text);
               p_retcode  := 0;
               p_errbuf   := 'multiple assignments found in more than 1 permit';

		end loop; --  }   invalid

       plog ( '_ check multi asgs. span permits '||to_char(SQL%ROWCOUNT));
         end if; -- ] permit not null

--  identify which of the person records are the eoy primary rows
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',42);
  hr_utility.trace( 'find the multiple asgs primary assignment for NI');
   update pay_gb_year_end_assignments pp
	   set eoy_primary_flag = 'Y' where pp.rowid = ( select
      		substr(max(lpad(gross_pay,9,'0')||p.rowid),-18)
	      from pay_gb_year_end_assignments p,
       		    pay_gb_year_end_payrolls ye_roll,
       		    pay_gb_year_end_payrolls yep2
       		    	where p.person_id   = pp.person_id
       	       		and   ye_roll.payroll_id  = p.payroll_id
       		    	and   yep2.payroll_id = pp.payroll_id
       		  and  ye_roll.tax_reference_number  = yep2.tax_reference_number
       		    	and   p.MULTIPLE_ASG_FLAG is not null )
  	  and 	pp.MULTIPLE_ASG_FLAG is not null
   	  and   pp.request_id = p_request_id;
       plog ( '_ for multi asgs. assign a primary asg '||to_char(SQL%ROWCOUNT));

--  insert a summation of all the values rows against the primary
--             ensure the effective_end_date is reset to the primary's
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',44);
  hr_utility.trace( 'put all the NI Contribs on the primary assignment');
-- Thad
   l_count := 0;
   for asg_rec in get_multi_asg_people loop
       for l_asg_details in get_multi_asg_prim_details(asg_rec.assignment_id)
       loop
           insert into pay_gb_year_end_values
                 (ASSIGNMENT_ID,EFFECTIVE_END_DATE,NI_CATEGORY_CODE,REPORTABLE,
                  EARNINGS,TOTAL_CONTRIBUTIONS,EMPLOYEES_CONTRIBUTIONS,
                  EARNINGS_CONTRACTED_OUT,CONTRIBUTIONS_CONTRACTED_OUT)
	   values (l_asg_details.s_asg_id, l_asg_details.s_end_date,
                   l_asg_details.s_ni_cat_code,
                   'M' , l_asg_details.s_earnings,
                   l_asg_details.s_tot_con, l_asg_details.s_ees_con,
                   l_asg_details.s_earnings_co, l_asg_details.s_con_co
                  );
          l_count := l_count + 1;
       end loop;
    end loop;
 plog ( '_ for multi asgs. set NI Balances on Primary '||to_char(l_count));

--  set not reportable values to N on multiple assignmnet rows
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',46);
  hr_utility.trace( 'set reportable to N on secondary assignments');
  update pay_gb_year_end_values yev set REPORTABLE = 'N'
  where reportable = 'Y'
  and exists ( select '1' from pay_gb_year_end_assignments ye_asg
               where ye_asg.MULTIPLE_ASG_FLAG is not null
               and   ye_asg.assignment_id = yev.assignment_id
               and   ye_asg.effective_end_date = yev.effective_end_date
               and   ye_asg.request_id = p_request_id );

 plog ('_ for multi asgs. set NI Balances to non reportable on Non P Asgs '
                                              ||to_char(SQL%ROWCOUNT));
--  insert x rows on non primaries
  hr_utility.set_location('PAY_YEAR_END_EXTRACT.EXTRACT',48);
  hr_utility.trace( 'set category to X where no values row exists ');
	insert into pay_gb_year_end_values
	( ASSIGNMENT_ID,EFFECTIVE_END_DATE,NI_CATEGORY_CODE,REPORTABLE)
	select ye_asg.assignment_id, ye_asg.effective_end_date ,'X','Y'
		from pay_gb_year_end_assignments ye_asg
		where not exists ( select '1' from pay_gb_year_end_values yev
    				  where ye_asg.assignment_id = yev.assignment_id
			 and ye_asg.effective_end_date = yev.effective_end_date
                                 and yev.reportable <> 'N')
          and   ye_asg.request_id = p_request_id;
plog ('_ set category to X where no values row exists '||to_char(SQL%ROWCOUNT));
commit;

end; -- ) update non bal info
plog ('PAY_YEAR_END_EXTRACT completed ');

-- check data extracted --
/*
plog ('Start CHECK TEMPORARY TABLES ');
IF check_data(p_business_group_id, p_year, p_permit, p_tax_district_ref)=0 THEN
        p_retcode := 0;
        p_errbuf := 'TEMPORARY TABLE references a payroll without assignment';
        plog ('CHECK TEMPORARY TABLES completed with error');
ELSE
        plog ('CHECK TEMPORARY TABLES completed ');
END IF;
*/
exception
  when tax_dist_ref_error then
    p_retcode := 0;
    p_errbuf := 'Above';
    plog ('Invalid Format for Tax District Reference: Must be three numerics');
end; -- ) end extract
--
--
end pay_year_end_extract;

/
