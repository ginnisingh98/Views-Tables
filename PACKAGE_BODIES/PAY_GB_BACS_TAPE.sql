--------------------------------------------------------
--  DDL for Package Body PAY_GB_BACS_TAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_BACS_TAPE" AS
-- $Header: pytapbac.pkb 120.0.12010000.3 2009/07/17 14:46:33 namgoyal ship $
--
-- ***************************************************************************
--
-- Copyright (c) Oracle Corporation (UK) Ltd 1993.
-- All Rights Reserved.
--
-- PRODUCT
--  Oracle*Payroll
--
-- NAME
--
--
-- DESCRIPTION
--  Magnetic tape format procedure for bacs.
--
/*
OVERVIEW

BACS is submitted via the PYUGEN C program that sets up the Payroll
Action for the mag tape process and its attendent assignment actions.

Parameters:          Mand UK(used in UK or legilative parameter[L]
CONSOLIDATION_SET	Y N     Used in select to set up assignment actions
			  	for unpaid Pre Payment Actions
PAYROLL_ID		N N	select by payroll
START_DATE		N N	only include pre payments from this date
EFFECTIVE_DATE		N Y     end of period?
PAYMENT_TYPE_ID		Y Y	BACS payment type
ORG_PAYMENT_METHOD_ID	N N	us field to output for just one debit account
OVERRIDE_DD_DATE        N Y     BACS processin date
EXPIRATION_DATE         N L     when will the tape expire (for bacs header)
SUBMISSION_NUMBER       N L     Volume Serial Number for Volume/File headers
MEDIA                   N L     if Media=TEL then it indicates no Headers
MULTI_DAY               N L     is this a multi day run
BUREAU                  N L     is this a multi file run for a bureau


The Parameter passed to the PLSQL procedure on its 1st call is the
payroll_action_id. The rest of the parameters update the approprate
columns on the payroll actions table - the legislative parameters
are all stored with there token identifyer(e.g. SUBMISSION_NUMBER=TAPE1
MEDIA=TAPE..) in the legislative parameter column.

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    30-JUN-95   ASNELL        40.0               Created.
    30-JUN-95   NBRISTOW      40.1               Modified to use PL/SQL tables
                                                 to pass parameter and
                                                 and context rule data.

    20-AUG-95   TINEKUKU                         Created routines to get and
						 validate the process date, i.e.                                                 check for weekends and Bank                                                     Holidays.

    30-JUL-96   JALLOUN       40.2               Added error handling.
    26-NOV-97   APARKES       110.1              Bug 572503 removed to_date
                                                 functions in cursor Payment_rule
                                                 in validate_process_date function
                                                 Bug 572935 hr_general.decode_lookup
                                                 used to decode return from get_banks
                                                 cursor.  Same as UK arcs (R10) v40.14
    12-DEC-97   APARKES       110.2   599470     Removed use of to_date in the cursor in
                                                 function check_hols when restricting by
                                                 ROW_LOW_RANGE_OR_NAME as this col may
                                                 contain non-date strings and otherwise
                                                 cause ORA-01858.
    17-FEB-1998 APARKES       110.3              Converted implicit cursors in
                                                 functions validate_process_date
                                                 and get_process_date into
                                                 explicit cursors.
                                      621006     Catered for periods in
                                                 get_process_date.csr_get_period_info
    18-MAR-1998 APARKES       110.4   640915     Changed ADD_MONTHS behaviour in
                                                 get_process_date() for entry days
                                                 at end of short month.
                                                 Prevented validate_process_date()
                                                 overridding to Next Banking Day
                                                 behaviour if no BACS personal payment
                                                 method exists.
    27-APR-1998 APARKES       110.5   648085     Made check for bank holidays
                                                 case insensitive in function
                                                 check_hols
    03-DEC-1998 FDUCHENE      110.6   749168     Changed cursors (see .pkh)
    16-FEB-1999 APARKES       110.7   809367     Made get_process_date treat
                                                 monthly periods the same as
                                                 shorter ones
    07-OCT-1999 PDAVIES       110.8              Replaced all occurrences of
                                                 DBMS_Output.Put_Line with
                                                 hr_utility.trace.
    16-FEB-2000 SMROBINS      115.1   1071880    Handle date parameters in
                                                 canonical format
    24-NOV-2000 AMILLS        115.2   1381231    Added territory_code to get_
                                                 banks cursor as unique key
                                                 pay_payment_types_uk changed.
    05-MAR-2002 KTHAMPAN      115.6   2231983    Change select statement in function check_hols from
                                                 select inst.user_column_instance_id into hols_id
                                                 to select 1 into hols_id
    06-MAR-2002 KTHAMPAN      115.7              Add dbdrv command
    06-MAR-2002 GBUTLER	      115.8		 Changed sql_str declaration in validate_process_date
    						 for UTF8 project.
    11-JUN-2002 KTHAMPAN      115.9   2366717    Removing knowledge of hardcoded id_flex_num.
    09-SEP-2004 KTHAMPAN      115.10             Fix GSCC error
    07-Jul-09   NAMGOYAL     115.12   8505257    Added Cash Management Reconciliation
                                                 function
    17-Jul-09   NAMGOYAL     115.13   8505257    Added Customer extensible User Table logic to
                                                 Cash Management Reconciliation function

*/
--
--
-- Package body:
--
--
--
--
--
      total_body_count             NUMBER;
      total_contra_count           NUMBER;
      count_for_block              NUMBER;
      block_count                  NUMBER;
      org_payment_count            NUMBER;
      p_value                      NUMBER;
      p_payroll_action_id          NUMBER;
      p_assignment_number per_assignments.ASSIGNMENT_NUMBER%TYPE;
      p_personal_payment_method_id NUMBER;
      p_org_payment_method_id      NUMBER;
      p_previous_payment_id        NUMBER;
      total_payment                NUMBER;
      total_payment_footer         NUMBER;
      submission_number      VARCHAR2(6);
      expiration_date        VARCHAR2(30);
      todays_date            VARCHAR2(30);
      final_contra                BOOLEAN;
      fetch_required              BOOLEAN;
      process_date         VARCHAR2(30);
--
      CURSOR bacs_assignments( p_payroll_action_id NUMBER)
      IS
      SELECT ppp.org_payment_method_id,
             ppp.personal_payment_method_id,
             ppp.value,
             pa.assignment_number
      FROM   pay_assignment_actions paa,
             pay_pre_payments ppp,
             per_assignments pa
      WHERE  paa.payroll_action_id = p_payroll_action_id
      AND    ppp.pre_payment_id = paa.pre_payment_id
      AND    paa.assignment_id = pa.assignment_id
      ORDER BY ppp.org_payment_method_id, pa.assignment_number;
--
--
--
    PROCEDURE new_formula IS
--
      select_count         VARCHAR2(11);
--
--
      FUNCTION get_formula_id(p_formula_name IN VARCHAR2) RETURN INTEGER IS
               p_formula_id INTEGER;
      BEGIN
      hr_utility.set_location('bacsmgtp.get_formula_id',1);
      SELECT DISTINCT formula_id
      INTO p_formula_id
      FROM   ff_formulas_f
      WHERE formula_name = p_formula_name;
      hr_utility.set_location('bacsmgtp.formula_id',p_formula_id);
--
      RETURN p_formula_id;
--
      END get_formula_id;
--
      FUNCTION get_todays_date  RETURN VARCHAR2 IS
               todays_date VARCHAR2(30);
      BEGIN
      hr_utility.set_location('bacsmgtp.get_todays_date',1);
      todays_date := to_char(sysdate,'YYYY/MM/DD HH24:MI:SS');
      RETURN todays_date;
      END get_todays_date;
--
      FUNCTION get_session_date RETURN VARCHAR2 IS
               p_session_date VARCHAR2(30);
      BEGIN
      hr_utility.set_location('bacsmgtp.get_session_date',1);
      SELECT to_char(effective_date,'YYYY/MM/DD HH24:MI:SS')
      INTO p_session_date
      from fnd_sessions
      where session_id = userenv('sessionid');
--
      RETURN p_session_date;
--
      END get_session_date;
--
      FUNCTION get_expiration_date(p_payroll_action_id IN VARCHAR2)
                                                       RETURN VARCHAR2 is
               p_expiration_date VARCHAR2(30);
	BEGIN
	hr_utility.set_location('bacsmgtp.get_expiration_date',1);
        select nvl(substr(LEGISLATIVE_PARAMETERS,
                 decode(instr(LEGISLATIVE_PARAMETERS,'EXPIRATION_DATE='),
                        '0', null,
                    instr(LEGISLATIVE_PARAMETERS,'EXPIRATION_DATE='))+16,11),
                 to_char(add_months(sysdate,2),'YYYY/MM/DD HH24:MI:SS') ) Expiration_date
                 into    p_expiration_date
                 from    pay_payroll_actions
                 where   PAYROLL_ACTION_ID = p_payroll_action_id;
--
      RETURN p_expiration_date;
--
      END get_expiration_date;
--
      FUNCTION get_submission_number(p_payroll_action_id IN VARCHAR2)
                                                       RETURN VARCHAR2 is
               p_submission_number VARCHAR2(6);
	BEGIN
	hr_utility.set_location('bacsmgtp.get_submission_number',1);
        select
               nvl(substr(LEGISLATIVE_PARAMETERS,
                  decode(instr(LEGISLATIVE_PARAMETERS,'SUBMISSION_NUMBER='),
                        '0', null,
                    instr(LEGISLATIVE_PARAMETERS,'SUBMISSION_NUMBER='))+18,6),
                  'NOLABL') Submission_number
                  into    p_submission_number
                  from pay_payroll_actions
                  where PAYROLL_ACTION_ID = p_payroll_action_id;
--
hr_utility.set_location('bacsmgtp.get_submission_number',2);
      RETURN p_submission_number;
--
      END get_submission_number;
--
--
      FUNCTION get_process_date(p_payroll_action_id IN VARCHAR2)
                                                       RETURN VARCHAR2 is
               p_process_date VARCHAR2(30);
	BEGIN
	hr_utility.set_location('bacsmgtp.get_process_date',1);
        hr_utility.trace('payroll_action_id='||p_payroll_action_id);
        BEGIN
        select
 		to_char(OVERRIDING_DD_DATE ,'YYYY/MM/DD HH24:MI:SS') effdate
		into p_process_date
               from pay_payroll_actions
               where PAYROLL_ACTION_ID = p_payroll_action_id;
--
      EXCEPTION when others then
              hr_utility.set_message(801, 'Other error in get_process_date f');
              hr_utility.raise_error;
        END;
--
hr_utility.set_location('bacsmgtp.get_process_date'||p_process_date,2);
      RETURN p_process_date;
--
      END get_process_date;
--
--
--    Because our Bacs data is de-normalized I have to cheat and just select
--    one row.
      FUNCTION get_org_context(p_payroll_action_id IN NUMBER) RETURN INTEGER IS
                   p_org_payment_method_id INTEGER;
      BEGIN
      hr_utility.set_location('bacsmgtp.get_org_context',1);
      SELECT  ppp.org_payment_method_id
      INTO      p_org_payment_method_id
      FROM   pay_assignment_actions paa, pay_pre_payments ppp
      WHERE  paa.payroll_action_id = p_payroll_action_id
      AND    ppp.pre_payment_id = paa.pre_payment_id
      AND    ROWNUM = 1
      ORDER BY ppp.org_payment_method_id;
      hr_utility.set_location('org_context',p_org_payment_method_id);
      RETURN p_org_payment_method_id;
      END get_org_context;
--
    BEGIN
-- temporary trace AS set trace on and delay for a while to set up pipemon
--IF NOT bacs_assignments %ISOPEN  THEN
--hr_utility.trace_on;
-- declare loop_counter number;
--begin
--loop_counter := 1;
--while loop_counter < 500000 LOOP
--loop_counter := loop_counter +1;
--END LOOP;
--end;
--end if;
-- end temporary trace AS
--
      -- Reserved positions
      pay_mag_tape.internal_prm_names(1)    := 'NO_OF_PARAMETERS';
      pay_mag_tape.internal_prm_names(2)    := 'NEW_FORMULA_ID';
--
      pay_mag_tape.internal_cxt_names(1)  := 'Number_of_contexts';
      -- Initial value
      pay_mag_tape.internal_cxt_values(1)  := 1;
--
--
      IF NOT bacs_assignments %ISOPEN  THEN                -- New file
      hr_utility.set_location('bacsmgtp.new_formula',1);
--
        total_body_count   := 0;                            -- Initial value
        total_contra_count := 0;
        count_for_block    := 0;
        org_payment_count  := 0;
        block_count        := 1;
        fetch_required     := TRUE;
        pay_mag_tape.internal_cxt_names(2)   := 'ORG_PAY_METHOD_ID';
        pay_mag_tape.internal_cxt_names(3)   := 'DATE_EARNED';
        pay_mag_tape.internal_cxt_values(1)  := 3;
        pay_mag_tape.internal_cxt_values(3)  := get_session_date;
--
        pay_mag_tape.internal_prm_values(1)  := 7;
        pay_mag_tape.internal_prm_values(2)   := get_formula_id('BACS_HEADER');
--
-- AS it looks like we have 3 parms so try this
        if pay_mag_tape.internal_prm_names(3) = 'PAYROLL_ACTION_ID'
	then p_payroll_action_id := to_number(
                                      pay_mag_tape.internal_prm_values(3));
        end if;
hr_utility.set_location('bacsmgtp.payroll_action_id',p_payroll_action_id);
--
 	 expiration_date := get_expiration_date(p_payroll_action_id);
 	 submission_number := get_submission_number(p_payroll_action_id);
   	 process_date    := get_process_date(p_payroll_action_id);
         pay_mag_tape.internal_cxt_values(2) :=
                                       get_org_context(p_payroll_action_id);
         p_previous_payment_id := get_org_context(p_payroll_action_id);
--
--
        total_payment := 0;
        total_payment_footer :=0;
        final_contra := FALSE;
        pay_mag_tape.internal_prm_names(3) := 'TRANSFER_EXPIRATION_DATE';
        pay_mag_tape.internal_prm_values(3) := expiration_date;
        pay_mag_tape.internal_prm_names(4) := 'TRANSFER_SUBMISSION_NUMBER';
        pay_mag_tape.internal_prm_values(4) := submission_number;
        pay_mag_tape.internal_prm_names(5) := 'TRANSFER_BACS_PROCESS_DATE';
        pay_mag_tape.internal_prm_values(5) := process_date;
        pay_mag_tape.internal_prm_names(6) := 'TRANSFER_SELECT_COUNT';
        pay_mag_tape.internal_prm_values(6) :=  '0001';
        pay_mag_tape.internal_prm_names(7) := 'TRANSFER_TODAYS_DATE';
        pay_mag_tape.internal_prm_values(7) := get_todays_date;
--
        OPEN bacs_assignments ( p_payroll_action_id);
--
      ELSE
      hr_utility.set_location('bacsmgtp.new_formula',2);
--
      IF fetch_required = TRUE then
          FETCH bacs_assignments INTO
                p_org_payment_method_id,
                p_personal_payment_method_id,
                p_value,
                p_assignment_number;
      END IF;
--
--
      IF bacs_assignments %FOUND THEN
        IF p_org_payment_method_id = p_previous_payment_id
             THEN
          hr_utility.set_location('bacsmgtp.new_formula',3);
          pay_mag_tape.internal_prm_values(1)  := 4;
          pay_mag_tape.internal_prm_values(2)  := get_formula_id('BACS_BODY');
          pay_mag_tape.internal_prm_names(2)   := 'NEW_FORMULA_ID';
          pay_mag_tape.internal_prm_names(3)   := 'TRANSFER_VALUE' ;
          pay_mag_tape.internal_prm_values(3)  := p_value * 100;
          pay_mag_tape.internal_prm_names(4)   := 'TRANSFER_ASSIGN_NO';
          pay_mag_tape.internal_prm_values(4)  := p_assignment_number;
          pay_mag_tape.internal_cxt_names(2) := 'ORG_PAY_METHOD_ID';
          pay_mag_tape.internal_cxt_names(3) := 'DATE_EARNED';
          pay_mag_tape.internal_cxt_values(2):= p_org_payment_method_id;
          pay_mag_tape.internal_cxt_values(3):= get_session_date;
          pay_mag_tape.internal_cxt_values(1):= 4;
          pay_mag_tape.internal_cxt_names(4) := 'PER_PAY_METHOD_ID';
          pay_mag_tape.internal_cxt_values(4):= p_personal_payment_method_id;
          org_payment_count := org_payment_count + 1;
          total_body_count  := total_body_count + 1;
          total_payment   := (p_value * 100) + total_payment;
          total_payment_footer := (p_value * 100) + total_payment_footer;
          p_previous_payment_id := p_org_payment_method_id;
          fetch_required := TRUE;
--
-- Check for the block size
--
          IF count_for_block = 20 then
            hr_utility.set_location('bacsmgtp.new_formula',4);
            block_count := block_count + 1;
            count_for_block := 1;
          ELSE count_for_block := count_for_block + 1;
            hr_utility.set_location('bacsmgtp.new_formula',5);
          END IF;
--
        ELSE
          hr_utility.set_location('bacsmgtp.new_formula',6);
          pay_mag_tape.internal_prm_values(1) := 5;
          pay_mag_tape.internal_prm_values(2) := get_formula_id('BACS_CONTRA');
          pay_mag_tape.internal_prm_names(2)  := 'NEW_FORMULA_ID';
          pay_mag_tape.internal_prm_names(3)  := 'TRANSFER_TOTAL_PAYMENT';
          pay_mag_tape.internal_prm_values(3) := total_payment;
          pay_mag_tape.internal_prm_names(4)  := 'TRANSFER_PAYMENT_COUNT';
          pay_mag_tape.internal_prm_values(4) := org_payment_count;
          pay_mag_tape.internal_prm_names(5)  := 'TRANSFER_LAST_CONTRA';
          pay_mag_tape.internal_prm_values(5) := 'N';
          pay_mag_tape.internal_cxt_values(1) := 3;
          pay_mag_tape.internal_cxt_names(2)  := 'ORG_PAY_METHOD_ID';
          pay_mag_tape.internal_cxt_values(2) := p_previous_payment_id;
          pay_mag_tape.internal_cxt_names(3)  := 'DATE_EARNED';
          pay_mag_tape.internal_cxt_values(3) := get_session_date;
          total_contra_count := total_contra_count + 1;
          count_for_block  :=count_for_block + 1;
          p_previous_payment_id := p_org_payment_method_id;
          org_payment_count := 0;
          total_payment    := 0;
          fetch_required := FALSE;
        END IF;
--
--
--    I need to call the CONTRA record again if it is the
--    last call before doing the padding and the footer
      ELSE
        IF final_contra = FALSE THEN
          pay_mag_tape.internal_prm_values(1) := 5;
          pay_mag_tape.internal_prm_values(2) := get_formula_id('BACS_CONTRA');
          pay_mag_tape.internal_prm_names(2)  := 'NEW_FORMULA_ID';
          pay_mag_tape.internal_prm_names(3)  := 'TRANSFER_TOTAL_PAYMENT';
          pay_mag_tape.internal_prm_values(3) := total_payment;
          pay_mag_tape.internal_prm_names(4)  := 'TRANSFER_PAYMENT_COUNT';
          pay_mag_tape.internal_prm_values(4) := org_payment_count;
          pay_mag_tape.internal_prm_names(5)  := 'TRANSFER_LAST_CONTRA';
          pay_mag_tape.internal_prm_values(5) := 'Y';
          pay_mag_tape.internal_cxt_values(1) := 3;
          pay_mag_tape.internal_cxt_names(2)  := 'ORG_PAY_METHOD_ID';
          pay_mag_tape.internal_cxt_values(2) := p_previous_payment_id;
          pay_mag_tape.internal_cxt_names(3)  := 'DATE_EARNED';
          pay_mag_tape.internal_cxt_values(3) := get_session_date;
          total_contra_count := total_contra_count + 1;
          count_for_block  :=count_for_block + 1;
          final_contra :=TRUE;
        ELSE
        hr_utility.set_location('bacsmgtp.new_formula',8);
           IF count_for_block < 20 then
             hr_utility.set_location('bacsmgtp.new_formula',9);
             pay_mag_tape.internal_prm_values(1) :=2;
             pay_mag_tape.internal_prm_names(2)  := 'NEW_FORMULA_ID';
             pay_mag_tape.internal_prm_values(2) :=
                                                get_formula_id('BACS_PADDING');
             count_for_block:= count_for_block + 1;
           ELSE
--           Padding finished - Now write footer,
--
             hr_utility.set_location('bacsmgtp.new_formula',10);
             pay_mag_tape.internal_cxt_values(1) := 3;
             pay_mag_tape.internal_cxt_names(2)  := 'ORG_PAY_METHOD_ID';
             pay_mag_tape.internal_cxt_values(2) := p_org_payment_method_id;
             pay_mag_tape.internal_cxt_names(3)  := 'DATE_EARNED';
             pay_mag_tape.internal_cxt_values(3) := get_session_date;
             pay_mag_tape.internal_prm_values(1)   := 6;
             pay_mag_tape.internal_prm_values(2)   :=
                                             get_formula_id('BACS_FOOTER');
             pay_mag_tape.internal_prm_names(2)    := 'NEW_FORMULA_ID';
             pay_mag_tape.internal_prm_names(3)    :=
                                                'TRANSFER_EXPIRATION_DATE';
             pay_mag_tape.internal_prm_values(3)   := expiration_date;
             pay_mag_tape.internal_prm_names(4)    :=
                                                'TRANSFER_SUBMISSION_NUMBER';
             pay_mag_tape.internal_prm_values(4)   := submission_number;
             pay_mag_tape.internal_prm_names(5)    := 'TRANSFER_BODY_COUNT';
             pay_mag_tape.internal_prm_values(5)   := total_body_count;
             pay_mag_tape.internal_prm_names(6)    := 'TRANSFER_BLOCK_COUNT';
             pay_mag_tape.internal_prm_values(6)   := block_count;
             pay_mag_tape.internal_prm_names(7)    := 'TRANSFER_TODAYS_DATE';
             pay_mag_tape.internal_prm_values(7)   := get_todays_date;
             pay_mag_tape.internal_prm_names(8)    := 'TRANSFER_TOTAL_PAYMENT';
             pay_mag_tape.internal_prm_values(8)   := total_payment_footer;
             pay_mag_tape.internal_prm_names(9)    := 'TRANSFER_CONTRA_COUNT';
             pay_mag_tape.internal_prm_values(9)   := total_contra_count;
--
             CLOSE bacs_assignments;
           END IF;
--
        END IF;
--
      END IF;
 END IF;

END new_formula;
--
FUNCTION check_hols(date_in DATE, sql_str VARCHAR2) return boolean IS
  status_flag varchar2(1);
  hols_id number(4);
  date_in_char varchar2(12);
  begin
--
  date_in_char:=to_char(date_in,'DD-MON-YYYY');
  hr_utility.trace('Check for Bank Holiday in '||sql_str||'.  Date: '||date_in_char);
  select  1 into hols_id
   from   pay_user_column_instances_f inst,
          pay_user_rows_f row1,
          pay_user_columns col1,
          pay_user_tables tab1
   where tab1.user_table_name = 'BANK_HOLIDAYS'
    and  tab1.business_group_id is null
    and  tab1.legislation_code = 'GB'
    and  row1.user_table_id = tab1.user_table_id
    and  col1.user_table_id = tab1.user_table_id
    and  col1.user_column_name = sql_str
    and  inst.user_column_id = col1.user_column_id
    and  inst.user_row_id = row1.user_row_id
    and  upper(row1.ROW_LOW_RANGE_OR_NAME) = date_in_char;
--
    return false;
--
    EXCEPTION
      when no_data_found then
        hr_utility.trace('no data returned');
        return true;
      when too_many_rows then
        hr_utility.trace('Too many rows returned');
        return false;
end check_hols;
----
FUNCTION main_routine (date1 DATE, sql_str VARCHAR2) RETURN DATE IS
--
  valdate                 VARCHAR2(11);
  return_date             DATE         := date1;
  not_holiday_date        boolean      := false;
  date_returned           boolean      := true;
  added_value             number(3)    := 0;
  date_ok                 boolean;
  BEGIN
--
  date_ok := false;
  hr_utility.trace('MAIN ROUTINE ENTERED');
  while not date_ok
     loop
        valdate := to_char( return_date,'D');
        added_value    := 0;
        IF valdate = '1' then
           added_value := -2;
        end if;
        if valdate = '7' then
           added_value := -1;
        end if;
--
        return_date := return_date + added_value;
--
        hr_utility.trace(valdate||' '||added_value);
        hr_utility.trace( to_char( return_date, 'day-DD-MON-YYYY'));
--
        date_returned := check_hols(return_date, sql_str);
--
        if date_returned = false then
           hr_utility.trace('date is a holiday');
           return_date :=  return_date - 1;
           date_ok := false;
        else
           hr_utility.trace('date is not a holiday');
           hr_utility.trace( to_char(return_date, 'day-DD-MON-YYYY'));
           date_ok := true;
         end if;
--
         if date_ok then
            exit;
         end if;
      end loop;
      RETURN return_date;
  END main_routine;
--
--
FUNCTION get_process_date(p_assignment_action_id in number,
                   	      p_entry_date           in date)
         return date is
--
  CURSOR csr_get_default_date IS
    select  default_dd_date
      from  pay_assignment_actions paa,
            pay_payroll_actions ppa,
            per_time_periods ptp
     where  paa.assignment_action_id =
            p_assignment_action_id
       and  ppa.payroll_action_id =
            paa.payroll_action_id
       and  ptp.time_period_id = ppa.time_period_id;
--
  CURSOR csr_get_period_info IS
    select  ppa.effective_date,
            ptp.end_date,
            decode(tpr.basic_period_type,'CM',tpr.periods_per_period,0)
      from  per_time_period_rules tpr,
            per_time_period_types tpt,
            per_time_periods ptp,
            pay_payroll_actions ppa,
            pay_assignment_actions paa
     where  paa.assignment_action_id = p_assignment_action_id
       and  ppa.payroll_action_id = paa.payroll_action_id
       and  ptp.time_period_id = ppa.time_period_id
       and  ptp.period_type = tpt.period_type
       and  tpt.number_per_fiscal_year = tpr.number_per_fiscal_year;
--
  l_dd_date           DATE;
  l_eff_date          DATE;
  l_period_end        DATE;
  l_months_in_period  number(2);   -- number of months in the period if basic
                                   -- period is calender month, else set to 0
  l_mth_diff          number(8,2); -- difference in the dates
  l_day_diff          number(2);   -- difference between the days
--
BEGIN
--
  if p_entry_date = hr_general.start_of_time then
    open csr_get_default_date;
    fetch csr_get_default_date into l_dd_date;
    close csr_get_default_date;
  else
    open csr_get_period_info;
    fetch csr_get_period_info into l_eff_date,
                                   l_period_end, l_months_in_period;
    close csr_get_period_info;
    if l_months_in_period <= 1 then
      -- period is shorter than calendar month
      -- use same month as effective date
      l_mth_diff := MONTHS_BETWEEN(l_eff_date, p_entry_date);
      if to_number(to_char(p_entry_date,'DD')) <=
            to_number(to_char(l_eff_date,'DD')) then
        l_dd_date := ADD_MONTHS(p_entry_date, floor(l_mth_diff));
      else
        l_dd_date := ADD_MONTHS(p_entry_date, ceil(l_mth_diff));
      end if;
    else
      -- find the difference b/w the dates, add appropriate no. of periods
      l_mth_diff := MONTHS_BETWEEN(l_period_end, p_entry_date)/l_months_in_period;
      l_dd_date := ADD_MONTHS(p_entry_date, floor(l_mth_diff)*l_months_in_period);
      -- floor used to cater for future entry dates
    end if;
    -- change ADD_MONTHS behaviour for entry days at end of short month 640915
    l_day_diff:=to_number(to_char(l_dd_date,'dd')) -
                      to_number(to_char(p_entry_date,'dd'));
    l_dd_date := l_dd_date - greatest(0,l_day_diff);
  end if;
  RETURN l_dd_date;
end get_process_date;
--
FUNCTION validate_process_date(p_assignment_action_id in number,
                               p_process_date           in date)
         return date is
--
  CURSOR csr_get_details is
      select  paa.assignment_id, ppa.effective_date
        from  pay_payroll_actions ppa,
              pay_assignment_actions paa
        where paa.assignment_action_id = p_assignment_action_id
          and ppa.payroll_action_id = paa.payroll_action_id;
--
  CURSOR get_banks IS
     select  pea.segment8
        from  pay_org_payment_methods_f pop,
              pay_personal_payment_methods_f ppp,
              pay_assignment_actions paa,
              pay_external_accounts pea,
              pay_payment_types ppt
        where paa.assignment_action_id =
                p_assignment_action_id
        and   ppp.assignment_id =
                paa.assignment_id
        and   pea.external_account_id =
                ppp.external_account_id
        and   pop.org_payment_method_id =
                ppp.org_payment_method_id
        and   ppt.payment_type_id =
                pop.payment_type_id +0
        and   ppt.payment_type_name = 'BACS Tape'
        and   ppt.territory_code = 'GB';
--
  CURSOR payment_rule(param1 DATE, param2 NUMBER) IS
     SELECT target.SEGMENT9
        FROM    hr_soft_coding_keyflex target,
                fnd_id_flex_structures  FNDID,
                per_assignments_f ASSIGN,
                pay_payrolls_f PAYROLL
        WHERE   param1 BETWEEN ASSIGN.effective_start_date
                       AND ASSIGN.effective_end_date
             AND ASSIGN.assignment_id = param2
             AND target.id_flex_num = FNDID.id_flex_num
             AND FNDID.id_flex_structure_code = 'GB_STATUTORY_INFO.'
             AND target.enabled_flag = 'Y'
             AND PAYROLL.payroll_id = ASSIGN.payroll_id
             AND param1 BETWEEN PAYROLL.effective_start_date
                        AND PAYROLL.effective_end_date
             AND target.soft_coding_keyflex_id =
                 PAYROLL.soft_coding_keyflex_id;
--
  proc_date               DATE;
  eff_date                DATE;
  dd_date                 DATE      := p_process_date;
  sql_str                 pay_external_accounts.segment8%TYPE;
  lowest_dd_date          DATE         := dd_date;
  assignmt_id             number;
  scl_pay_gb_bacs_pay_rule VARCHAR2(1) := 'N';
--
BEGIN
--
  open csr_get_details;
  fetch csr_get_details into assignmt_id, eff_date;
  close csr_get_details;
  hr_utility.trace('Display effective date');
  hr_utility.trace(eff_date);
  hr_utility.trace('Display assignment id');
  hr_utility.trace(assignmt_id);
--
  hr_utility.trace('Display company payment rule');
--
     open payment_rule(eff_date, assignmt_id);
     loop
       fetch payment_rule into scl_pay_gb_bacs_pay_rule;
       exit when payment_rule%NOTFOUND;
     end loop;
     close payment_rule;
--
     hr_utility.trace(scl_pay_gb_bacs_pay_rule);
     if scl_pay_gb_bacs_pay_rule = 'P' then
       hr_utility.trace('GET DEPOSIT DATE');
       hr_utility.trace( to_char(dd_date, 'day-DD-MON-YYYY'));
--
       sql_str := NULL;
       open get_banks;
       loop
         fetch get_banks into sql_str;
         if get_banks%FOUND or get_banks%ROWCOUNT = 0 then
           if sql_str is NULL then
             sql_str := 'England';
           else
             sql_str := hr_general.decode_lookup('GB_COUNTRY',sql_str);
           end if;
           dd_date := main_routine (dd_date, sql_str);
           if dd_date < lowest_dd_date then
             lowest_dd_date := dd_date;
           end if;
         end if;
         exit when get_banks%NOTFOUND;
       end loop;
       close get_banks;
     end if;
     dd_date := lowest_dd_date;
     proc_date := dd_date - 1;
     sql_str := 'England';
     hr_utility.trace('GET PROCESS DATE');
     hr_utility.trace( to_char(proc_date, 'day-DD-MON-YYYY'));
     proc_date := main_routine (proc_date, sql_str);
     hr_utility.trace( to_char(dd_date, 'day-DD-MON-YYYY'));
     hr_utility.trace( to_char(proc_date, 'day-DD-MON-YYYY'));
     hr_utility.trace(' Lowest DATE');
     hr_utility.trace( to_char(lowest_dd_date, 'day-DD-MON-YYYY'));
     RETURN proc_date;
  END validate_process_date;

 --Cash Management Reconciliation function
 FUNCTION f_get_eft_recon_data (p_effective_date       IN DATE,
			        p_identifier_name       IN VARCHAR2,
                   		p_payroll_action_id	IN NUMBER,
				p_payment_type_id	IN NUMBER,
				p_org_payment_method_id	IN NUMBER,
				p_personal_payment_method_id	IN NUMBER,
				p_assignment_action_id	IN NUMBER,
				p_pre_payment_id	IN NUMBER,
				p_delimiter_string   	IN VARCHAR2)
 RETURN VARCHAR2
 IS

   CURSOR c_get_bus_grp
   IS
     Select business_group_id
     From pay_payroll_actions
     Where payroll_action_id = p_payroll_action_id;

   CURSOR c_get_trx_date
   IS
     Select overriding_dd_date
     From pay_payroll_actions
     Where payroll_action_id = p_payroll_action_id;

   CURSOR c_get_conc_ident
   IS
     Select ext.segment3, --Sort Code
            ext.segment4 --Acc Num
     From pay_external_accounts ext,
	  pay_org_payment_methods_f org
     Where  org.org_payment_method_id = p_org_payment_method_id
       and  p_effective_date between org.effective_start_date and org.effective_end_date
       and  org.external_account_id = ext.external_account_id;

   l_business_grp_id     NUMBER;
   l_usr_fnc_name        VARCHAR2(5000):= NULL;
   l_return_value	 VARCHAR2(80) := NULL;
   l_trx_date            Date;
   l_sort_code           VARCHAR2(30);
   l_acc_num             VARCHAR2(30);

 BEGIN

   OPEN c_get_bus_grp;
   FETCH c_get_bus_grp INTO l_business_grp_id;
   CLOSE c_get_bus_grp;

   SELECT hruserdt.get_table_value(l_business_grp_id,
                                   'GB_EFT_RECONC_FUNC',
                                   'RECONCILIATION',
		                   'FUNCTION NAME',
                                   p_effective_date)
    INTO l_usr_fnc_name
    FROM dual;

   IF l_usr_fnc_name IS NOT NULL
   THEN
	     EXECUTE IMMEDIATE 'select '||l_usr_fnc_name||'(:1,:2,:3,:4,:5,:6,:7,:8,:9) from dual'
	     INTO l_return_value
	     USING p_effective_date ,
                   p_identifier_name,
	           p_payroll_action_id,
		   p_payment_type_id,
		   p_org_payment_method_id,
		   p_personal_payment_method_id,
		   p_assignment_action_id,
		   p_pre_payment_id,
		   p_delimiter_string ;
   ELSE
       IF UPPER(p_identifier_name) = 'TRANSACTION_DATE'
       THEN
	         OPEN c_get_trx_date;
	         FETCH c_get_trx_date INTO l_trx_date;
                 CLOSE c_get_trx_date;

	         l_return_value := to_char(l_trx_date, 'yyyy/mm/dd');

       ELSIF UPPER(p_identifier_name) = 'TRANSACTION_GROUP'
       THEN
           l_return_value := p_payroll_action_id;

       ELSIF UPPER(p_identifier_name) = 'CONCATENATED_IDENTIFIERS'
       THEN
            OPEN c_get_conc_ident;
	    FETCH c_get_conc_ident INTO l_sort_code,l_acc_num;
            CLOSE c_get_conc_ident;

	    l_return_value := 'BACS'||p_delimiter_string||l_sort_code||p_delimiter_string||l_acc_num;

       END IF;
   END IF;

   RETURN l_return_value;

END f_get_eft_recon_data;

--
END pay_gb_bacs_tape;

/
