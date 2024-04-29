--------------------------------------------------------
--  DDL for Package Body PAY_GB_EOY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_EOY" AS
/* $Header: payeoy.pkb 115.3 99/07/17 05:38:23 porting ship  $ */
/* Copyright (c) Oracle Corporation 1995. All rights reserved

  Name          : PAYEOY
  Description   : End of year magnetic tape control process
  Author        : P.Driver
  Date Created  : 17/11/95

 Change List
  -----------
    Date        Name            Vers     Bug No   Description

    +-----------+---------------+--------+-------+-----------------------+
     11-Dec-1995 P.Driver       1.2               System test fixes
     07-MAY-1996 T.Inekuku                        Included formula_type_id
                                                  in get formula id routine
                                                  to make use of index

     30-JUL-1996 J.Alloun                         Added error handling.

     23-SEP-1996 M.Iqbal                          Fix for error in tax calc, and
                                                  super-ann truncating - BUG: 401646

     24-Sep-1996 M.Iqbal                          NIP reporting added
     19-Jun-1997 A.Parkes        40.11    545556  changes due to revised CA51
                                                  (MM3) Jan-97
     25-Feb-1998 A.Parkes        40.12    632451  Removed numeric test on permit
                                                  number from procedure
                                                  create_record_type1
     17-Mar-1998 A.Mills         110.4    641807  Created new function
						  check_special_char that
						  allows for middle names
						  to have chars (exc. 1st char)
						  like '-. This caused type 2
						  BACS error before.
    11-DEC-98  R Simms           110.5            Changed l_assigment length
                                                  to match the table attribute
*/
fetch_new_header  BOOLEAN := TRUE;  -- Shows if new header record needed
process_emps      BOOLEAN := FALSE; -- Shows if get employees records
fin_run           BOOLEAN := FALSE; -- End of run flag
sub_header        BOOLEAN := FALSE; -- Create the record type2 sub
permit_change     BOOLEAN := FALSE; -- set if the permit_no changes
process_dummy     BOOLEAN := FALSE; -- Set if > 4 NI codes are found
g_ni_total        NUMBER(3) := 0;   -- Number of Ni codes found
g_last_ni         NUMBER(3) := 0;   -- Index through NI PL/SQL tables
--
g_permit_no       VARCHAR2(12);     -- The current permit number must be held
g_tax_dist_ref    VARCHAR2(3) :=NULL;
g_business_group_id NUMBER(15):=NULL;
g_payroll_id      NUMBER(15);       -- The current payroll id held between
g_record_index    NUMBER(2) := 0;   -- Counter for mag tape parameters
g_tot_contribs    NUMBER(11):=0;    -- Total contribution by permit_no
g_tot_nip         NUMBER(11):=0;    -- Total NIP deductions
g_tot_tax         NUMBER(12):=0;    -- Total tax by permit_no
g_tot_rec2        NUMBER(7) :=0;    -- Total of record 2's
g_tot_rec2_per    NUMBER(7) :=0;    -- Number of record 2's by permit_no
g_tot_ssp_rec     NUMBER(10):=0;    -- Total ssp recovered by permit_no
g_tot_smp_rec     NUMBER(10):=0;    -- Total smp recovered by permit_no
g_tot_smp_comp    NUMBER(10):=0;    -- Total smp compensated by permit_no
g_tot_super       NUMBER(12):=0;    -- Total superannuation by payroll
g_nic_comp        NUMBER(9) :=0;    -- Nic compensation on smp by permit
g_eoy_mode        VARCHAR2(1):='P'; -- THE eoy mode defaults to partial
--
-- Record type 1 placeholders
g_new_permit_no     VARCHAR2(12);   -- The recently fetched permit number
g_new_payroll_id    NUMBER(15);     -- The recently fetched payroll id
g_tax_district_ref  VARCHAR2(3);
g_tax_ref_no        VARCHAR2(7);
g_tax_district_name VARCHAR2(40);
g_tax_year          VARCHAR2(4);
g_employers_name    VARCHAR2(36);
g_employers_address VARCHAR2(60);
g_econ              VARCHAR2(9);
g_ssp_recovery      NUMBER(10);
g_smp_recovery      NUMBER(10);
g_smp_compensation  NUMBER(10);
--
-- Record type 2 placeholders
g_employee_number           VARCHAR2(14);
g_last_name                 VARCHAR2(20);
g_first_name                VARCHAR2(7);
g_middle_name               VARCHAR2(7);
g_date_of_birth             VARCHAR2(8);
g_national_insurance_number VARCHAR2(9);
g_start_of_emp              VARCHAR2(8);
g_termination_date          VARCHAR2(8);
g_sex                       VARCHAR2(1);
g_address_line1             VARCHAR2(27);
g_address_line2             VARCHAR2(27);
g_address_line3             VARCHAR2(27);
g_address_line4             VARCHAR2(27);
g_full_address              VARCHAR2(108); -- temp var used in address ordering
g_postal_code               VARCHAR2(8);
--
/* PL/SQL table definitions */
--
TYPE scon_typ IS TABLE OF pay_gb_year_end_values.scon%TYPE
    INDEX BY BINARY_INTEGER;
TYPE category_typ IS TABLE OF pay_gb_year_end_values.ni_category_code%TYPE
    INDEX BY BINARY_INTEGER;
TYPE earnings_typ IS TABLE OF pay_gb_year_end_values.earnings%TYPE
    INDEX BY BINARY_INTEGER;
TYPE total_contrib_typ IS TABLE OF
		     pay_gb_year_end_values.total_contributions%TYPE
    INDEX BY BINARY_INTEGER;
TYPE emps_contrib_typ IS TABLE OF
		  pay_gb_year_end_values.employees_contributions%TYPE
    INDEX BY BINARY_INTEGER;
TYPE earnings_cont_out_typ IS TABLE OF
		  pay_gb_year_end_values.earnings_contracted_out%TYPE
    INDEX BY BINARY_INTEGER;
TYPE contribs_cont_out_typ IS TABLE OF
		  pay_gb_year_end_values.contributions_contracted_out%TYPE
    INDEX BY BINARY_INTEGER;
--
scon_tab              scon_typ;
category_tab          category_typ;
earnings_tab          earnings_typ;
total_contrib_tab     total_contrib_typ;
employees_contrib_tab emps_contrib_typ;
earnings_cont_out_tab earnings_cont_out_typ;
contribs_cont_out_tab contribs_cont_out_typ;
--
-- Cursor definitions
--
CURSOR header_cur(cp_permit_no         VARCHAR2
    ,cp_tax_dist_ref      VARCHAR2
    ,cp_tax_ref_no        VARCHAR2
    ,cp_business_group_id NUMBER) IS
SELECT UPPER(a.permit_number)
    ,a.payroll_id
    ,TO_CHAR(a.tax_district_reference)
    ,UPPER(a.tax_reference_number)
    ,UPPER(a.tax_district_name)
    ,NVL(TO_CHAR(a.tax_year-1),'?')
    ,UPPER(a.employers_name)
    ,UPPER(a.employers_address_line)
    ,UPPER(NVL(a.econ,'?'))
    ,nvl(ssp_recovered,0)
    ,nvl(smp_recovered,0)
    ,nvl(smp_compensation,0)
FROM pay_gb_year_end_payrolls a
WHERE a.permit_number = NVL(cp_permit_no,a.permit_number)
AND   a.tax_reference_number =
                NVL(cp_tax_ref_no,a.tax_reference_number)
AND   a.tax_district_reference =
			          NVL(cp_tax_dist_ref,a.tax_district_reference)
AND   a.business_group_id = NVL(cp_business_group_id,
			                           a.business_group_id)
AND EXISTS (SELECT '1'
      FROM pay_gb_year_end_assignments b
      WHERE a.payroll_id = b.payroll_id)
ORDER BY a.permit_number,a.payroll_id;
--
CURSOR emps_cur(cp_payroll_id NUMBER) IS
      SELECT SUBSTR(UPPER(a.assignment_number),1,14)
        ,NVL(UPPER(a.last_name),' ')
        ,UPPER(SUBSTR(a.first_name,1,7))
        ,UPPER(a.middle_name)
        ,NVL(fnd_date.date_to_canonical(a.date_of_birth),' ')
        ,NVL(UPPER(a.sex),' ')
        ,decode(a.address_line1,'','',rpad(upper(a.address_line1),27))
        ,decode(a.address_line2,'','',rpad(upper(a.address_line2),27))
        ,ltrim(rpad(UPPER(NVL(a.town_or_city,a.address_line3)),27))
        ,decode(a.county,'','',rpad(UPPER(a.county),27))
        ,NVL(UPPER(a.postal_code),' ')
        ,NVL(UPPER(a.tax_code),' ')
        ,NVL(UPPER(a.w1_m1_indicator),' ')
        ,NVL(UPPER(a.national_insurance_number), ' ')
        ,NVL(a.ssp,0)
        ,NVL(a.smp,0)
        ,NVL(a.gross_pay,0)
        ,decode(a.tax_refund, 'R', NVL(-1*a.tax_paid,0), NVL(a.tax_paid,0))
        ,NVL(UPPER(a.tax_refund),' ')
        ,NVL(a.previous_taxable_pay,0)
        ,NVL(a.previous_tax_paid,0)
        ,NVL(fnd_date.date_to_canonical(a.start_of_emp),' ')
        ,fnd_date.date_to_canonical(a.termination_date)
        ,100*(NVL(TRUNC(a.superannuation_paid/100),0))
        ,NVL(UPPER(a.superannuation_refund),' ')
        ,NVL(ROUND(a.widows_and_orphans/100),0)
        ,NVL(UPPER(a.week_53_indicator),' ')
        ,NVL(a.taxable_pay,0)
        ,NVL(UPPER(a.pensioner_indicator),' ')
        ,NVL(UPPER(a.director_indicator),' ')
        ,a.assignment_id
        ,a.effective_end_date
      FROM pay_gb_year_end_assignments a
		WHERE a.payroll_id    = cp_payroll_id
		ORDER BY a.last_name, a.first_name;
--
CURSOR emp_values(cp_assignment_id NUMBER
		 ,cp_effective_date DATE) IS
		 SELECT NVL(UPPER(a.scon),' ')                scon
		       ,UPPER(a.ni_category_code)             cat_code
		       ,NVL(TRUNC(a.earnings/100),0)          earnings
		       ,NVL(a.total_contributions,0)         tot_cont
		       ,NVL(a.employees_contributions,0)      emps_cont
		       ,NVL(TRUNC(a.earnings_contracted_out/100),0) earnings_out
		       ,NVL(a.contributions_contracted_out,0) cont_out
      FROM pay_gb_year_end_values a
		  WHERE a.assignment_id      = cp_assignment_id
		  AND   a.effective_end_date = cp_effective_date
		  AND   a.reportable        <> 'N';
--
CURSOR econ_chk(cp_permit_no          VARCHAR2
	       ,cp_tax_dist_ref       VARCHAR2
	       ,cp_tax_ref_no         VARCHAR2
	       ,cp_business_group_id NUMBER) IS
          SELECT '1'
          FROM pay_gb_year_end_values a
	       WHERE a.ni_category_code IN ('D','E')
	       AND (a.assignment_id,a.effective_end_date) IN
            (SELECT b.assignment_id,b.effective_end_date
		      FROM pay_gb_year_end_assignments b
		          ,pay_gb_year_end_payrolls    c
            WHERE c.permit_number = NVL(cp_permit_no, c.permit_number)
		        AND   c.tax_reference_number =
                           NVL(cp_tax_ref_no,c.tax_reference_number)
		        AND c.tax_district_reference =
                           NVL(cp_tax_dist_ref,c.tax_district_reference)
              AND c.business_group_id    = NVL(cp_business_group_id,
		                                           c.business_group_id)
              AND   c.payroll_id            = b.payroll_id
		        AND   rownum < 5);
--
FUNCTION get_formula_id(p_formula_name VARCHAR2) RETURN INTEGER IS
-- Get the formula id from the formula name
p_formula_id INTEGER;
CURSOR form IS SELECT a.formula_id
	       FROM   ff_formulas_f a,
                      ff_formula_types t
	       WHERE a.formula_name = p_formula_name
                 AND a.formula_type_id = t.formula_type_id
                 AND t.formula_type_name = 'Oracle Payroll';
BEGIN
  OPEN form;
  FETCH form INTO p_formula_id;
  CLOSE form;
  RETURN p_formula_id;
END;
--
FUNCTION check_number(p_check_digit CHAR) RETURN BOOLEAN IS
BEGIN
  IF p_check_digit BETWEEN '0' AND '9' THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
--
FUNCTION check_char(p_check_digit CHAR) RETURN BOOLEAN IS
BEGIN
  IF p_check_digit BETWEEN 'A' AND 'Z' THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
--
FUNCTION check_special_char(p_check_digit CHAR) RETURN BOOLEAN IS
BEGIN
  IF p_check_digit BETWEEN 'A' AND 'Z'
  OR p_check_digit in ('''', '-', '.') THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
--
FUNCTION f_middle_name(p_middle_name VARCHAR2) RETURN VARCHAR2 IS
l_index      NUMBER(2):=1;
l_local_char VARCHAR2(1);
l_middle_name VARCHAR2(7);
BEGIN
  -- Set the return variable at the start
  -- It may be overwritten if validation fails
  l_middle_name := p_middle_name;
  l_local_char := SUBSTR(l_middle_name,l_index,1);
  IF (NOT check_char(l_local_char)) AND l_local_char <> ' ' THEN
    -- first char is not a character or space
    l_middle_name := '?';
    hr_utility.set_location('eoy_body.eoy',270);
  ELSIF l_local_char = ' ' AND LENGTH(p_middle_name) > 1 THEN
    -- Proceed to 2nd character
    l_index := 2;
    WHILE l_middle_name <> '?' AND l_index <= 7 LOOP
      -- Check up to the seventh character
      hr_utility.set_location('eoy_body.eoy',271);
      l_local_char := SUBSTR(p_middle_name,l_index,1);
      IF l_local_char <> ' ' THEN
        -- Character is not a space so fail
        hr_utility.trace('The failed char is '||l_local_char);
        l_middle_name := '?';
        hr_utility.set_location('eoy_body.eoy',272);
      END IF;
      l_index := l_index + 1;
    END LOOP;
  ELSIF check_char(l_local_char) AND LENGTH(p_middle_name) > 1 THEN
    -- Proceed to 2nd character
    l_index := 2;
    WHILE l_middle_name <> '?' AND l_index <= 7 LOOP
      -- Check up to the seventh character
      l_local_char := SUBSTR(p_middle_name,l_index,1);
      IF l_local_char <> ' ' AND (NOT check_special_char(l_local_char)) THEN
        -- Character is not a space or special char (inc. .-' ) so fail
        l_middle_name := '?';
      END IF;
      l_index := l_index + 1;
    END LOOP;
  END IF;
  RETURN(l_middle_name);
END;
--
FUNCTION f_last_name(p_last_name VARCHAR2) RETURN VARCHAR2 IS
l_index    NUMBER(2):=1;
l_local_char VARCHAR2(1);
l_last_name  VARCHAR2(20);
BEGIN
  -- Save the last name for the return clause
  -- This value will be changed if validation fails
  l_last_name := p_last_name;
  l_local_char := SUBSTR(l_last_name,1,1);
  IF NOT check_char(l_local_char) THEN
    hr_utility.set_location('eoy_body.eoy',160);
    l_last_name := '?';
  ELSE
    /* Start at the second character */
    l_index := 2;
    hr_utility.set_location('eoy_body.eoy',170);
    -- Check last_name
    WHILE l_last_name <> '?' AND l_index <= 4 LOOP
      hr_utility.set_location('eoy_body.eoy',180);
      l_local_char := SUBSTR(l_last_name,l_index,1);
      IF (NOT check_char(l_local_char))  AND
	                 (l_local_char NOT IN ('''','-',' ','.')) THEN
        hr_utility.trace('The failed char is '||l_local_char);
        l_last_name := '?';
        hr_utility.set_location('eoy_body.eoy',190);
      END IF;
      hr_utility.set_location('eoy_body.eoy',240);
      l_index := l_index + 1;
    END LOOP;
  END IF;
  RETURN(l_last_name);
END;
--
--
PROCEDURE mag_tape_init(p_no NUMBER) IS
-- The initialization of the record type formulae
-- and number of parameters
BEGIN
  /* Reserved parameter names */
  pay_mag_tape.internal_prm_names(1) := 'NO_OF_PARAMETERS';
  pay_mag_tape.internal_prm_names(2) := 'NEW_FORMULA_ID';
  pay_mag_tape.internal_prm_names(3) := 'TRANSFER_TYPE1_ERRORS';
  pay_mag_tape.internal_prm_names(4) := 'TRANSFER_TYPE2_ERRORS';
  IF p_no = 1 THEN
    /* Record type 1 */
    pay_mag_tape.internal_prm_values(1) := 13;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('MAG_RECORD1');
  ELSIF p_no = 2 THEN
    /* Record type 2 */
    pay_mag_tape.internal_prm_values(1) := 63;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('MAG_RECORD2');
    /* Reset the record index to start at the third parameter */
  ELSIF p_no = 3 THEN
    /* Sub-header */
--  hr_utility.trace('record index is '||to_char(g_record_index));
    pay_mag_tape.internal_prm_values(1) := 6;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('MAG_RECORD3');
  ELSIF p_no = 4 THEN
    /* Permit total */
--  hr_utility.trace('record index is '||to_char(g_record_index));
    pay_mag_tape.internal_prm_values(1) := 15;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('MAG_RECORD4');
  ELSIF p_no = 5 THEN
    /* End of record */
--  hr_utility.trace('record index is '||to_char(g_record_index));
    pay_mag_tape.internal_prm_values(1) := 7;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('MAG_RECORD5');
  ELSIF p_no = 6 THEN
    /* Dummy record */
    pay_mag_tape.internal_prm_values(1) := 2;
    pay_mag_tape.internal_prm_values(2) := get_formula_id('MAG_RECORD6');
  END IF;
  -- Set parameter count to start at transfer_type1_errors
  g_record_index := 5;
END;
--
PROCEDURE mag_tape_interface(p_name   VARCHAR2
			    ,p_values VARCHAR2) IS
/* The interface to the magnetic tape writer process */
BEGIN
 pay_mag_tape.internal_prm_names(g_record_index)  := p_name;
 pay_mag_tape.internal_prm_values(g_record_index) := p_values;
 /* Inc the parameter table index */
 g_record_index := g_record_index +1;
END;
--
PROCEDURE mag_tape_interface(p_name   VARCHAR2
			    ,p_values NUMBER) IS
/* The interface to the magnetic tape writer process */
BEGIN
  pay_mag_tape.internal_prm_names(g_record_index)  := p_name;
  pay_mag_tape.internal_prm_values(g_record_index) := p_values;
  g_record_index := g_record_index +1;
END;
--
PROCEDURE p_mag_form_clear IS
/* This procedure will clear the NI2 to NI4 records for the
   employee. This will stop any earlier records appearing in
   later records.       */
BEGIN
  FOR l_index IN 2..4 LOOP
    mag_tape_interface('SCON'||TO_CHAR(l_index) ,' ');
    mag_tape_interface('NI_CATEGORY_CODE'||
                                 TO_CHAR(l_index),' ');
    mag_tape_interface('EARNINGS'||TO_CHAR(l_index) ,'0');
    mag_tape_interface('TOTAL_CONTRIBUTIONS'||l_index,'0');
    mag_tape_interface('EMPLOYEES_CONTRIBUTIONS'|| TO_CHAR(l_index),'0');
    mag_tape_interface('EARNINGS_CONTRACTED_OUT'|| TO_CHAR(l_index),'0');
    mag_tape_interface('CONTRIBUTIONS_CONTRACTED_OUT'||TO_CHAR(l_index),'0');
  END LOOP;
END;
--
PROCEDURE create_record_type1 IS
l_index      NUMBER :=0;
l_local_char VARCHAR2(1);
l_result     VARCHAR2(1);
BEGIN
        -- Now start validating the record type 1
        hr_utility.set_location('eoy_body.eoy',600);
        -- Initialise the record type 1 parameters
        hr_utility.trace('Writing record type 1');
        mag_tape_init(1);
         -- Pass the record fields as paramteres to the mag tape process
        hr_utility.trace('Record type1 passed eoy_mode '||g_eoy_mode);
        mag_tape_interface('EOY_MODE',g_eoy_mode);
        mag_tape_interface('PERMIT_NO',NVL(g_new_permit_no,'?'));
--
        /* Field must be three numeric characters */
        BEGIN
          g_tax_district_ref := FND_number.CANONICAL_TO_NUMBER(g_tax_district_ref);
        EXCEPTION
          WHEN VALUE_ERROR THEN
	    -- Any non-numeric characters will raise an exception
            g_tax_district_ref := '?';
            hr_utility.set_location('eoy_body.eoy',610);
        END;
        mag_tape_interface('TAX_DISTRICT_REF' ,NVL(g_tax_district_ref,'?'));
--
        /* First char must be alphanumeric only */
        IF NOT check_number(SUBSTR(g_tax_ref_no,1,1)) THEN
          IF NOT check_char(SUBSTR(g_tax_ref_no,1,1)) THEN
            hr_utility.set_location('eoy_body.eoy',620);
	    g_tax_ref_no := '?';
          END IF;
        END IF;
        /* Start at the second character */
        l_index := 2;
        /* Next 5 may be alphanumeric, space, oblique or brackets */
        WHILE g_tax_ref_no <> '?' AND l_index <= LENGTH(g_tax_ref_no) LOOP
	  l_local_char := SUBSTR(g_tax_ref_no,l_index,1);
	  IF NOT check_number(l_local_char) AND
	     NOT check_char(l_local_char) AND
	    l_local_char NOT IN (' ','/','\','(',')')  THEN
               hr_utility.set_location('eoy_body.eoy',630);
	       g_tax_ref_no := '?';
          END IF;
	  l_index := l_index + 1;
        END LOOP;
        mag_tape_interface('TAX_REF_NO',g_tax_ref_no);
        mag_tape_interface('TAX_DISTRICT_NAME',g_tax_district_name);
        mag_tape_interface('TAX_YEAR',g_tax_year);
        mag_tape_interface('EMPLOYERS_NAME',NVL(g_employers_name,'?'));
        mag_tape_interface('EMPLOYERS_ADDRESS',NVL(g_employers_address,'?'));
--
	IF NOT(econ_chk%ISOPEN) THEN
	  OPEN econ_chk(g_permit_no
		       ,g_tax_dist_ref
		       ,g_tax_ref_no
		       ,g_business_group_id);
        END IF;
	  FETCH econ_chk INTO l_result;
	  IF l_result IS NULL THEN
	    -- No econ is needed as less than 5 contracted out employees
	    IF g_econ = '?' THEN
	      -- If NVL forced a ? then overwrite to a space
	      g_econ := ' ';
	    END IF;
     ELSE
       -- Econ must be present
	    IF g_econ = '?' THEN
	      -- If NVL forced a ? then overwrite to '?2'
	      g_econ := '?2';
	    ELSE
         /* Econ 1st digit must be 'E', the next 7 between 0 and 9 */
         /* and the last between 'A' and 'Z'                       */
         g_econ:=rpad(g_econ,9);
         -- prevent SUBSTR in loop from returning null to l_local_char
         IF SUBSTR(g_econ,1,1) <> 'E' THEN
   	      g_econ := '?1';
            hr_utility.set_location('eoy_body.eoy',640);
         END IF;
         l_index := 2;
         WHILE g_econ <> '?1' AND l_index <= 9 LOOP
   	      l_local_char := SUBSTR(g_econ,l_index,1);
   	      IF NOT check_number(l_local_char) AND l_index <= 8 THEN
               g_econ := '?1';
               hr_utility.set_location('eoy_body.eoy',650);
            END IF;
   	      IF NOT check_char(l_local_char) AND (l_index = 9) THEN
               g_econ := '?1';
               hr_utility.set_location('eoy_body.eoy',660);
            END IF;
   	      l_index := l_index + 1;
         END LOOP;
       END IF;
     END IF;
     mag_tape_interface('ECON',g_econ);
END;
--
PROCEDURE create_sub_header IS
BEGIN
  hr_utility.set_location('eoy_body.eoy',500);
  hr_utility.trace('Writting record type 2 subheader');
  mag_tape_init(3);
  mag_tape_interface('EOY_MODE',g_eoy_mode);
  mag_tape_interface('SUB_TOTAL','SUBTOTAL');
  hr_utility.set_location('eoy_body.eoy',510);
END;
--
PROCEDURE create_record_type3 IS
--
l_space_field       VARCHAR2(20) :=NULL; -- Used for space filled values
l_tot_refund        VARCHAR2(1)  :=NULL; -- Set to 'R' if tax refund
--
BEGIN
  hr_utility.trace('Writing record type 3');
  mag_tape_init(4);
  mag_tape_interface('EOY_MODE',g_eoy_mode);
  mag_tape_interface('PERMIT_NO',g_permit_no);  -- For inclusion in Error Messages
  mag_tape_interface('TOTAL_CONTRIBUTIONS',NVL(g_tot_contribs,0));
  g_tot_contribs := 0;
  hr_utility.trace('The tot tax is '||to_char(g_tot_tax));
  mag_tape_interface('TOTAL_TAX',NVL(ABS(g_tot_tax),0));
  IF SIGN(g_tot_tax) = -1 THEN
    -- The tax is a refund so set the refund status
    l_tot_refund := 'R';
  ELSE
    l_tot_refund := ' ';
  END IF;
  hr_utility.trace('The tot refund is '||l_tot_refund||'.');
  mag_tape_interface('TOTAL_TAX_REFUND',l_tot_refund);
  g_tot_tax := 0;
  mag_tape_interface('TOTAL_RECORDS',NVL(g_tot_rec2_per,0));
  -- Now add to the total record 2 count
  g_tot_rec2     := g_tot_rec2 + NVL(g_tot_rec2_per,0);
  hr_utility.trace('The per record is '||to_char(g_tot_rec2_per));
  hr_utility.trace('The current grand tot is '||to_char(g_tot_rec2));
  g_tot_rec2_per := 0;
  mag_tape_interface('TOTAL_SSP',NVL(g_tot_ssp_rec,0));
  -- Copy across new values to the variables
--  g_tot_ssp_rec := g_ssp_recovery;
  g_tot_ssp_rec := 0;
  l_space_field := NULL;
  -- The field will have to be padded with spaces in the
  -- formulae
  FOR l_index IN 1..9 LOOP
    l_space_field := l_space_field||' ';
  END LOOP;
  mag_tape_interface('SPARE_FIELD',l_space_field);
  mag_tape_interface('TOTAL_NIP',NVL(g_tot_nip, 0));
  g_tot_nip := 0;
  mag_tape_interface('TOTAL_SMP',NVL(g_tot_smp_rec,0));
--  g_tot_smp_rec := g_smp_recovery;
  g_tot_smp_rec := 0;
  mag_tape_interface('TOTAL_SMP_COMP',NVL(g_tot_smp_comp,0));
--  g_tot_smp_comp := g_smp_compensation;
  g_tot_smp_comp := 0;
END;
--
PROCEDURE p_create_dummy(l_tab_index NUMBER
      		        ,l_no_nis    NUMBER) IS
--
l_local_date        DATE;                 -- Used to hold a converted char
--
BEGIN
  /* Now create a dummy record type 2 */
  /* This is for the extra NI details for an employee */
  mag_tape_init(2);
  mag_tape_interface('EOY_MODE',g_eoy_mode);
  mag_tape_interface('EMPLOYEE_NUMBER',NVL(g_employee_number,' '));
  hr_utility.trace('The employee is '||g_employee_number);
--
  g_last_name := f_last_name(g_last_name);
  hr_utility.set_location('eoy_body.eoy',530);
  mag_tape_interface('LAST_NAME',NVL(g_last_name,'?'));
--
  -- Check first name
  IF g_first_name IS NOT NULL AND
			 NOT(check_char(SUBSTR(g_first_name,1,1))) THEN
    g_first_name := '?';
    hr_utility.set_location('eoy_body.eoy',540);
  END IF;
  mag_tape_interface('FIRST_NAME',NVL(g_first_name,'?'));
--
  -- Check middle_name
  IF g_middle_name IS NOT NULL THEN
    g_middle_name := f_middle_name(g_middle_name);
  END IF;-- middle null check
  hr_utility.set_location('eoy_body.eoy',550);
--
  mag_tape_interface('MIDDLE_NAME',NVL(g_middle_name,' '));
  mag_tape_interface('DATE_OF_BIRTH',g_date_of_birth);
  mag_tape_interface('GENDER',g_sex);
  mag_tape_interface('ADDRESS_LINE1',g_address_line1);
  mag_tape_interface('ADDRESS_LINE2',g_address_line2);
  mag_tape_interface('ADDRESS_LINE3',g_address_line3);
  mag_tape_interface('ADDRESS_LINE4',g_address_line4);
  mag_tape_interface('POSTAL_CODE',g_postal_code);
  mag_tape_interface('TAX_CODE','NI');
  mag_tape_interface('W1_M1',' ');
  mag_tape_interface('NI_NO',g_national_insurance_number);
--
--    Send the first record from the pl/sql tables to the mag tape
--
  mag_tape_interface('SCON1',scon_tab(l_tab_index + 1));
  mag_tape_interface('NI_CATEGORY_CODE1',category_tab(l_tab_index + 1));
  mag_tape_interface('EARNINGS1',earnings_tab(l_tab_index+1));
  mag_tape_interface('TOTAL_CONTRIBUTIONS1',total_contrib_tab(l_tab_index+1));
  mag_tape_interface('EMPLOYEES_CONTRIBUTIONS1',
				        employees_contrib_tab(l_tab_index+1));
  mag_tape_interface('EARNINGS_CONTRACTED_OUT1',
					earnings_cont_out_tab(l_tab_index+1));
  mag_tape_interface('CONTRIBUTIONS_CONTRACTED_OUT1',
			                contribs_cont_out_tab(l_tab_index+1));
  mag_tape_interface('SSP','0');
  mag_tape_interface('SMP','0');
  mag_tape_interface('GROSS_PAY','0');
  mag_tape_interface('TAX_PAID','0');
  hr_utility.set_location('eoy_body.eoy',560);
  mag_tape_interface('TAX_REFUND',' ');
  mag_tape_interface('PREVIOUS_TAXABLE_PAY','0');
--
  mag_tape_interface('PREVIOUS_TAX_PAID','0');
--
  mag_tape_interface('DATE_OF_STARTING',g_start_of_emp);
  BEGIN
    IF g_termination_date IS NOT NULL THEN
      l_local_date := FND_DATE.CANONICAL_TO_DATE(g_termination_date);
    END IF;
  EXCEPTION
    WHEN value_error THEN
      g_termination_date := '?';
      hr_utility.set_location('eoy_body.eoy',570);
  END;
  mag_tape_interface('TERMINATION_DATE',NVL(g_termination_date,' '));
  mag_tape_interface('SUPERANNUATION','0');
--
  mag_tape_interface('SUPERANNUATION_REFUND',' ');
  mag_tape_interface('WIDOWS_ORPHANS','0');
--
  mag_tape_interface('WEEK_53',' ');
  mag_tape_interface('TAXABLE_PAY','0');
--
  mag_tape_interface('PENSIONER_INDICATOR',' ');
  mag_tape_interface('DIRECTOR_INDICATOR',' ');
  hr_utility.set_location('eoy_body.eoy',580);
--
--
  hr_utility.trace('Start is '||to_char(l_tab_index+2));
  hr_utility.trace('End is '||to_char(l_no_nis));
  -- This will clear any previous values out
  p_mag_form_clear;
  FOR l_index IN l_tab_index+2..l_tab_index+l_no_nis LOOP
    hr_utility.trace('Index is now '||to_char(l_index));
    mag_tape_interface('SCON'||TO_CHAR(l_index),scon_tab(l_index));
    mag_tape_interface('NI_CATEGORY_CODE'||
                                 TO_CHAR(l_index),category_tab(l_index));
    mag_tape_interface('EARNINGS'||TO_CHAR(l_index)
                                                 ,earnings_tab(l_index));
    mag_tape_interface('TOTAL_CONTRIBUTIONS'||l_index
				            ,total_contrib_tab(l_index));
    mag_tape_interface('EMPLOYEES_CONTRIBUTIONS'||
			TO_CHAR(l_index),employees_contrib_tab(l_index));
    mag_tape_interface('EARNINGS_CONTRACTED_OUT'||
	                TO_CHAR(l_index),earnings_cont_out_tab(l_index));
    mag_tape_interface('CONTRIBUTIONS_CONTRACTED_OUT'||
			TO_CHAR(l_index),contribs_cont_out_tab(l_index));
    hr_utility.set_location('eoy_body.eoy',590);
  END LOOP;
  hr_utility.set_location('eoy_body.eoy',595);
END;
--
PROCEDURE get_parameters(p_permit_no         IN OUT VARCHAR2
			,p_eoy_mode          IN OUT VARCHAR2
			,p_tax_dist_ref      IN OUT VARCHAR2
			,p_tax_ref_no        IN OUT VARCHAR2
			,p_business_group_id IN OUT VARCHAR2) IS
BEGIN
  -- Get the parameters passed to the module
  -- Permit number first
  IF pay_mag_tape.internal_prm_names(3) = 'PERMIT' THEN
    hr_utility.set_location('eoy_body.eoy',400);
    -- Trap if the permit number was left null in parameters
    BEGIN
      p_permit_no := pay_mag_tape.internal_prm_values(3);
    EXCEPTION
      WHEN no_data_found THEN
         hr_utility.set_location('eoy_body.eoy',410);
         hr_utility.trace('No permit found');
	 p_permit_no := NULL;
    END;
    hr_utility.set_location('eoy_body.eoy',420);
  END IF;
  -- EOY MODE parameter
  IF pay_mag_tape.internal_prm_names(4) = 'EOY_MODE' THEN
    -- Trap if the eoy_mode was left null in parameters
    hr_utility.set_location('eoy_body.eoy',430);
    BEGIN
      p_eoy_mode := UPPER(pay_mag_tape.internal_prm_values(4));
    EXCEPTION
      WHEN no_data_found THEN
	-- Parameter left null so only P35 required
        hr_utility.set_location('eoy_body.eoy',440);
        hr_utility.trace('No eoy mode found');
        p_eoy_mode  := 'P';
    END;
    hr_utility.set_location('eoy_body.eoy',450);
    hr_utility.trace('EOY mode is '||p_eoy_mode);
  END IF;
  -- The tax district reference
  IF pay_mag_tape.internal_prm_names(5) = 'TAX_DISTRICT_REFERENCE' THEN
    -- Trap if the tax_dist_ref was left null in parameters
    hr_utility.set_location('eoy_body.eoy',460);
    BEGIN
      p_tax_dist_ref := SUBSTR(pay_mag_tape.internal_prm_values(5),1,3);
      p_tax_ref_no   := LTRIM(
			      SUBSTR(pay_mag_tape.internal_prm_values(5),4)
			      , '/');
    EXCEPTION
      WHEN no_data_found THEN
	-- Parameter left null
        hr_utility.set_location('eoy_body.eoy',470);
        hr_utility.trace('No tax dist ref found');
        p_tax_dist_ref := NULL;
    END;
  END IF;
  -- The Business_group_id
  IF pay_mag_tape.internal_prm_names(6) = 'BUSINESS_GROUP_ID' THEN
    -- Trap if the tax_dist_ref was left null in parameters
    hr_utility.set_location('eoy_body.eoy',480);
    BEGIN
      p_business_group_id := pay_mag_tape.internal_prm_values(6);
    EXCEPTION
      WHEN no_data_found THEN
	-- Parameter left null
        hr_utility.set_location('eoy_body.eoy',490);
        hr_utility.trace('No business group id found');
        p_business_group_id := NULL;
    END;
  END IF;
  hr_utility.set_location('eoy_body.eoy',495);
EXCEPTION
  WHEN no_data_found THEN
-- If this is raised then either the permit number and/or eoy_mode was
-- not entered as a parameter
   hr_utility.set_location('eoy_body.eoy',499);
   g_permit_no         := NVL(p_permit_no,NULL);
   p_eoy_mode          := NVL(p_eoy_mode,'P');
   p_tax_dist_ref      := NVL(p_tax_dist_ref,NULL);
   p_tax_ref_no        := NVL(p_tax_ref_no,NULL);
   p_business_group_id := NVL(p_business_group_id,NULL);
   hr_utility.trace('In exception handler get_parameters');
END;
--
-- START HERE
--
PROCEDURE eoy IS
--
-- Record type 2 placeholders
l_tax_code                  VARCHAR2(5);
l_w1_m1_indicator           VARCHAR2(1);
l_ssp                       NUMBER(6);
l_smp                       NUMBER(7);
l_gross_pay                 NUMBER(9);
l_tax_paid                  NUMBER(9);
l_tax_refund                VARCHAR2(1);
l_previous_taxable_pay      NUMBER(9);
l_previous_tax_paid         NUMBER(9);
l_superannuation_paid       NUMBER(9);
l_superannuation_refund     VARCHAR2(1);
l_widows_and_orphans        NUMBER(9);
l_week_53_indicator         VARCHAR2(1);
l_taxable_pay               NUMBER(9);
l_pension_indicator         VARCHAR2(1);
l_director_indicator        VARCHAR2(1);
l_assignment_id             pay_gb_year_end_assignments.assignment_id%TYPE;
l_effective_date            DATE;
--
-- General purpose variables
l_index             NUMBER(3) :=0;        -- General purpose loop counter
l_index2            NUMBER(3) :=0;        -- General purpose loop counter
l_plsql_index       NUMBER(3) :=0;        -- Index of the pl/sql tables
l_local_char        VARCHAR2(1);          -- Holds a char for testing
l_local_date        DATE;                 -- Used to hold a converted char
l_space_field       VARCHAR2(500):=NULL;  -- Used for space filled values
l_tot_refund        VARCHAR2(1):=NULL;    -- Set to 'R' if tax refund
--
BEGIN
  hr_utility.set_location('eoy_body.eoy',0);
--
-- Start checking for record type 1
--
  IF fetch_new_header THEN
    hr_utility.set_location('eoy_body.eoy',10);
    -- A Record type 1 is required
    IF NOT (header_cur%ISOPEN) THEN
      hr_utility.set_location('eoy_body.eoy',20);
      -- Get any parameters that have been sent
      get_parameters(g_permit_no
		    ,g_eoy_mode
		    ,g_tax_dist_ref
		    ,g_tax_ref_no
		    ,g_business_group_id);
      hr_utility.trace('The passed in Mode is '||g_eoy_mode||'@');
      hr_utility.trace('The passed in dist is '||g_tax_dist_ref||'@');
      hr_utility.trace('The passed in ref is '||g_tax_ref_no||'@');
      hr_utility.trace('The passed in business is '||g_business_group_id||'@');
      -- First time in so clear the error type counts
      pay_mag_tape.internal_prm_values(3) := 0;
      pay_mag_tape.internal_prm_values(4) := 0;
      OPEN header_cur(g_permit_no
		     ,g_tax_dist_ref
		     ,g_tax_ref_no
		     ,g_business_group_id);
    END IF;
    IF NOT(permit_change) THEN
    -- Get record from EOY table as next record
    -- for record type 1 required
      hr_utility.trace('1 The global Permit is '||g_permit_no);
      hr_utility.trace('1 The global Payroll is '||g_payroll_id);
      FETCH header_cur INTO g_new_permit_no
        ,g_new_payroll_id
        ,g_tax_district_ref
        ,g_tax_ref_no
        ,g_tax_district_name
        ,g_tax_year
        ,g_employers_name
        ,g_employers_address
        ,g_econ
        ,g_ssp_recovery
        ,g_smp_recovery
        ,g_smp_compensation;
      IF header_cur%NOTFOUND THEN
        -- No more records found so end of run
        hr_utility.set_location('eoy_body.eoy',30);
        IF g_tot_rec2_per > 0 THEN
      	  -- If at least one record has been found then create
      	  -- a permit total
          create_record_type3;
        ELSE
          -- No records found for permit create dummy record
          mag_tape_init(6);
        END IF;
        fetch_new_header := FALSE;
        process_emps     := FALSE;
        sub_header       := FALSE;
        fin_run          := TRUE;
        /* A fetch of a new header is due to the first fetch or
           change of permit or payroll */
      ELSIF g_new_permit_no <> NVL(g_permit_no,g_new_permit_no) THEN
        --
        -- The permit has changed so construct the record type 3
        --
        hr_utility.trace('2 Fetched Permit is '||g_new_permit_no);
        hr_utility.trace('2 Fetched Payroll_id is '||g_new_payroll_id);
        create_record_type3;
        -- Save required values in globals
        g_permit_no  := g_new_permit_no;
        g_payroll_id := g_new_payroll_id;
        permit_change := TRUE;
        -- Close the type 2 cursor so it will be re-opened with
        -- the new parameters
        CLOSE emps_cur;
        hr_utility.set_location('eoy_body.eoy',40);
      ELSE
        -- No permit change so add new smp and smp values to totals
        g_tot_ssp_rec  := g_tot_ssp_rec + g_ssp_recovery;
        g_tot_smp_rec  := g_tot_smp_rec + g_smp_recovery;
        g_tot_smp_comp := g_tot_smp_comp + g_smp_compensation;
        hr_utility.trace('3 Fetched Permit is '||g_new_permit_no);
        hr_utility.trace('3 Fetched Payroll_id is '||g_new_payroll_id);
        IF g_new_payroll_id <> NVL(g_payroll_id,g_new_payroll_id) THEN
          -- The payroll_id has changed in permit_no
          g_payroll_id := g_new_payroll_id;
          -- Write the sub_header and then get the employee details
          create_sub_header;
          -- Close the type 2 cursor so it will be re-opened with
          -- the new parameters
          CLOSE emps_cur;
          fetch_new_header := FALSE;
          permit_change    := FALSE;
          process_emps     := TRUE;
          hr_utility.set_location('eoy_body.eoy',45);
        ELSE
          hr_utility.trace('No payroll or permit change ');
          hr_utility.trace('4 Fetched Permit is '||g_new_permit_no);
          hr_utility.trace('4 Fetched Payroll_id is '||g_new_payroll_id);
          -- Save required values in globals
          g_permit_no  := g_new_permit_no;
          g_payroll_id := g_new_payroll_id;
          create_record_type1;
          fetch_new_header := FALSE;
          sub_header := TRUE;
          hr_utility.set_location('eoy_body.eoy',50);
        END IF;
      END IF;
    ELSE
      -- Change of permit so create a type 1 record from old values
      permit_change := FALSE;
      create_record_type1;
      fetch_new_header := FALSE;
      sub_header := TRUE;
      -- 1st record with this permit so set totals to new smp and ssp values
      g_tot_ssp_rec  := g_ssp_recovery;
      g_tot_smp_rec  := g_smp_recovery;
      g_tot_smp_comp := g_smp_compensation;
      hr_utility.set_location('eoy_body.eoy',60);
    END IF;
--
-- Check if sub-header required
--
  ELSIF sub_header THEN
    create_sub_header;
    hr_utility.set_location('eoy_body.eoy',70);
    sub_header   := FALSE;
    process_emps := TRUE;
--
-- Check for a dummy record 2 needed when more than 4 Ni cats exist for
-- a single employee
--
  ELSIF process_dummy THEN
    -- A special record type 2
    -- More than 4 more NI categories exist for the employee
    hr_utility.set_location('eoy_body.eoy',700);
    IF g_ni_total - g_last_ni > 4 THEN
      p_create_dummy(g_last_ni,4);
      g_last_ni := g_last_ni + 4;
    ELSE
      -- Less than 4 more NI categories exist for the employee
      p_create_dummy(g_last_ni,g_ni_total-g_last_ni);
      g_last_ni     := 0;
      g_ni_total    := 0;
      -- Reset the flags to continue processing any further employees
      process_emps  := TRUE;
      process_dummy := FALSE;
    END IF;
--
-- Check for processing record type 2
--
  ELSIF process_emps THEN
    -- Record type 2 required
    hr_utility.set_location('eoy_body.eoy',100);
    hr_utility.trace('The emp permit_no is '||g_permit_no);
    hr_utility.trace('The emp payroll_id is '||to_char(g_payroll_id));
    IF NOT (emps_cur%ISOPEN) THEN
      hr_utility.set_location('eoy_body.eoy',110);
      OPEN emps_cur(g_payroll_id);
    END IF;
    FETCH emps_cur INTO g_employee_number
      ,g_last_name
      ,g_first_name
      ,g_middle_name
      ,g_date_of_birth
      ,g_sex
      ,g_address_line1
      ,g_address_line2
      ,g_address_line3
      ,g_address_line4
      ,g_postal_code
      ,l_tax_code
      ,l_w1_m1_indicator
      ,g_national_insurance_number
      ,l_ssp
      ,l_smp
      ,l_gross_pay
      ,l_tax_paid
      ,l_tax_refund
      ,l_previous_taxable_pay
      ,l_previous_tax_paid
      ,g_start_of_emp
      ,g_termination_date
      ,l_superannuation_paid
      ,l_superannuation_refund
      ,l_widows_and_orphans
      ,l_week_53_indicator
      ,l_taxable_pay
      ,l_pension_indicator
      ,l_director_indicator
      ,l_assignment_id
      ,l_effective_date;
    IF emps_cur%NOTFOUND THEN
--
--    End of record type 2
--
--    Set escape from this section
      hr_utility.set_location('eoy_body.eoy',130);
      /* Each call of this package must return 1 record even */
	    /* if its only a dummy formula call to do so           */
      mag_tape_init(6);
      fetch_new_header:= TRUE;
      process_emps    := FALSE;
    ELSE
--
--  Fetch all the ni contributions for each employee
--  in one hit.
--
      l_index := 1;
      hr_utility.set_location('eoy_body.eoy',140);
      FOR emp_values_rec IN emp_values(l_assignment_id,l_effective_date)
      LOOP
        scon_tab(l_index)                := emp_values_rec.scon;
        category_tab(l_index)            := emp_values_rec.cat_code;
        earnings_tab(l_index)            := emp_values_rec.earnings;
        total_contrib_tab(l_index)       := emp_values_rec.tot_cont;
        -- g_tot_contribs := g_tot_contribs + emp_values_rec.tot_cont;
        employees_contrib_tab(l_index)   := emp_values_rec.emps_cont;
        earnings_cont_out_tab(l_index)   := emp_values_rec.earnings_out;
        contribs_cont_out_tab(l_index)   := emp_values_rec.cont_out;
--
        if (emp_values_rec.cat_code) = 'P' then
           g_tot_nip := g_tot_nip + emp_values_rec.tot_cont;
        else
           g_tot_contribs := g_tot_contribs + emp_values_rec.tot_cont;
        end if;  -- IF NI CODE = 'P'
-- Perform SCON error checking if NI F/G/S
        if category_tab(l_index) in ('F','G','S') then
          if scon_tab(l_index) = ' ' then
            /* if nvl forced a ' ' then overwrite with ?1 */
            scon_tab(l_index) := '?1';
          else  /* check format */
            /* 1st char must be A or S, followed by 7 numerics, then one alpha */
            if SUBSTR(scon_tab(l_index),1,1) NOT IN ('A','S') then
              scon_tab(l_index) := '?2';
            end if;
            l_index2:=2;
            scon_tab(l_index):=rpad(scon_tab(l_index),9);
            -- prevent SUBSTR in loop from returning null to l_local_char
            WHILE scon_tab(l_index) <> '?2' AND l_index2 <= 9 LOOP
              l_local_char := SUBSTR(scon_tab(l_index),l_index2,1);
              IF NOT check_number(l_local_char) AND l_index2 <= 8 THEN
                 scon_tab(l_index) := '?2';
              END IF;
              IF NOT check_char(l_local_char) AND (l_index2 = 9) THEN
                 scon_tab(l_index) := '?2';
              END IF;
              l_index2 := l_index2 + 1;
            END LOOP;
          end if;
        end if; -- if F/G/S
-- end of SCON error check
        l_index := l_index + 1;
      END LOOP;
      /* Keep the total number of NI category codes for the employee */
      /* If > 5 then raise warning in the mag tape log file          */
      g_ni_total := l_index - 1;
      IF l_index < 5 THEN
        /* Even if no category codes exist the fields must be */
        /* defaulted and written to the mag tape.             */
        FOR l_plsql_index IN l_index..4 LOOP
          scon_tab(l_plsql_index)                := ' ';
          category_tab(l_plsql_index)            := ' ';
          earnings_tab(l_plsql_index)            := 0;
          total_contrib_tab(l_plsql_index)       := 0;
          employees_contrib_tab(l_plsql_index)   := 0;
          earnings_cont_out_tab(l_plsql_index)   := 0;
          contribs_cont_out_tab(l_plsql_index)   := 0;
        END LOOP;
        hr_utility.set_location('eoy_body.eoy',150);
      END IF;
      /* Create a type 2 record */
      /* Set up the no of parameters and the formula professor */
      hr_utility.trace('Writting record type 2');
      mag_tape_init(2);
      /* Now create a record type 2 */
      mag_tape_interface('EOY_MODE',g_eoy_mode);
      mag_tape_interface('EMPLOYEE_NUMBER',NVL(g_employee_number,' '));
--
      g_last_name := f_last_name(g_last_name);
      hr_utility.set_location('eoy_body.eoy',250);
      mag_tape_interface('LAST_NAME',NVL(g_last_name,'?'));
--
      -- Check first name
      IF g_first_name IS NOT NULL AND
			 NOT(check_char(SUBSTR(g_first_name,1,1))) THEN
        g_first_name := '?';
        hr_utility.set_location('eoy_body.eoy',260);
      END IF;
      mag_tape_interface('FIRST_NAME',NVL(g_first_name,'?'));
--
      -- Check middle_name
      IF g_middle_name IS NOT NULL THEN
        g_middle_name := f_middle_name(g_middle_name);
      END IF;-- middle null check
      hr_utility.set_location('eoy_body.eoy',275);
--
      mag_tape_interface('MIDDLE_NAME',NVL(g_middle_name,' '));
      mag_tape_interface('DATE_OF_BIRTH',g_date_of_birth);
      mag_tape_interface('GENDER',g_sex);
--  Order Address lines to push nulls to end, using g_full_address as
--  a temporary variable.
      g_full_address := rpad(nvl(g_address_line1||g_address_line2||
                          g_address_line3||g_address_line4,' '),108);
--  Split into 4 and pass them to formula
      g_address_line1:=substr(g_full_address,1,27);
      g_address_line2:=substr(g_full_address,28,27);
      g_address_line3:=substr(g_full_address,55,27);
      g_address_line4:=substr(g_full_address,82);
      mag_tape_interface('ADDRESS_LINE1',g_address_line1);
      mag_tape_interface('ADDRESS_LINE2',g_address_line2);
      mag_tape_interface('ADDRESS_LINE3',g_address_line3);
      mag_tape_interface('ADDRESS_LINE4',g_address_line4);
--
      mag_tape_interface('POSTAL_CODE',g_postal_code);
      mag_tape_interface('TAX_CODE',l_tax_code);
      mag_tape_interface('W1_M1',l_w1_m1_indicator);
      mag_tape_interface('NI_NO',g_national_insurance_number);
--
--    Send the first record from the pl/sql tables to the mag tape
--
      mag_tape_interface('SCON1',scon_tab(1));
      mag_tape_interface('NI_CATEGORY_CODE1',category_tab(1));
      mag_tape_interface('EARNINGS1',earnings_tab(1));
      mag_tape_interface('TOTAL_CONTRIBUTIONS1',total_contrib_tab(1));
      mag_tape_interface('EMPLOYEES_CONTRIBUTIONS1',
					 employees_contrib_tab(1));
      mag_tape_interface('EARNINGS_CONTRACTED_OUT1',
					 earnings_cont_out_tab(1));
      mag_tape_interface('CONTRIBUTIONS_CONTRACTED_OUT1',
			                 contribs_cont_out_tab(1));
      mag_tape_interface('SSP',l_ssp);
      mag_tape_interface('SMP',l_smp);
      mag_tape_interface('GROSS_PAY',l_gross_pay);
      mag_tape_interface('TAX_PAID',ABS(l_tax_paid));
      g_tot_tax := g_tot_tax + l_tax_paid;
      hr_utility.set_location('eoy_body.eoy',280);
--
      IF l_tax_refund NOT IN ('R',' ') THEN
	 l_tax_refund := '?';
         hr_utility.set_location('eoy_body.eoy',290);
      END IF;
      mag_tape_interface('TAX_REFUND',l_tax_refund);
      mag_tape_interface('PREVIOUS_TAXABLE_PAY',
					      l_previous_taxable_pay);
--
      mag_tape_interface('PREVIOUS_TAX_PAID',
					      l_previous_tax_paid);
--
      mag_tape_interface('DATE_OF_STARTING',g_start_of_emp);
      BEGIN
      	IF g_termination_date IS NOT NULL THEN
      	  l_local_date := FND_DATE.CANONICAL_TO_DATE(g_termination_date);
      	END IF;
      EXCEPTION
      	WHEN value_error THEN
      	   g_termination_date := '?';
            hr_utility.set_location('eoy_body.eoy',300);
      END;
      mag_tape_interface('TERMINATION_DATE',NVL(g_termination_date,' '));
      mag_tape_interface('SUPERANNUATION',l_superannuation_paid);
--
      IF l_superannuation_refund NOT IN ('R',' ') THEN
	 l_superannuation_refund := '?';
         hr_utility.set_location('eoy_body.eoy',310);
      END IF;
      mag_tape_interface('SUPERANNUATION_REFUND',
					      l_superannuation_refund);
      mag_tape_interface('WIDOWS_ORPHANS',
					     l_widows_and_orphans);
--
      IF l_week_53_indicator NOT IN ('3','4','6',' ') THEN
	      l_week_53_indicator := '?';
         hr_utility.set_location('eoy_body.eoy',320);
      END IF;
      mag_tape_interface('WEEK_53', l_week_53_indicator);
      mag_tape_interface('TAXABLE_PAY',l_taxable_pay);
--
      IF l_pension_indicator NOT IN ('P',' ') THEN
	      l_pension_indicator := '?';
         hr_utility.set_location('eoy_body.eoy',330);
      END IF;
      mag_tape_interface('PENSIONER_INDICATOR', l_pension_indicator);
--
      IF l_director_indicator NOT IN ('D',' ') THEN
	 l_director_indicator := '?';
         hr_utility.set_location('eoy_body.eoy',340);
      END IF;
      mag_tape_interface('DIRECTOR_INDICATOR', l_director_indicator);
      hr_utility.set_location('eoy_body.eoy',350);
--
--    Now send up to 3 of the remaining contribution records to mag tape
--    If they do not exist they have been defaulted
--
      FOR l_index IN 2..4 LOOP
        mag_tape_interface('SCON'||TO_CHAR(l_index),scon_tab(l_index));
        mag_tape_interface('NI_CATEGORY_CODE'||
                          TO_CHAR(l_index) ,category_tab(l_index));
        mag_tape_interface('EARNINGS'||TO_CHAR(l_index)
                                             	    ,earnings_tab(l_index));
        mag_tape_interface('TOTAL_CONTRIBUTIONS'||l_index
					       ,total_contrib_tab(l_index));
        mag_tape_interface('EMPLOYEES_CONTRIBUTIONS'||
			TO_CHAR(l_index), employees_contrib_tab(l_index));
        mag_tape_interface('EARNINGS_CONTRACTED_OUT'||
	                TO_CHAR(l_index), earnings_cont_out_tab(l_index));
        mag_tape_interface('CONTRIBUTIONS_CONTRACTED_OUT'||
			TO_CHAR(l_index), contribs_cont_out_tab(l_index));
        hr_utility.set_location('eoy_body.eoy',360);
      END LOOP;
      -- Running count of all employee records
      g_tot_rec2_per := g_tot_rec2_per + 1;
      -- Now check the number of NI categories found for this employee
      IF g_ni_total > 4 THEN
        hr_utility.trace('The employee is '||g_employee_number);
        hr_utility.set_location('eoy_body.eoy',365);
	-- More than four so set flags for creation of dummy record
	process_emps := FALSE;
	process_dummy := TRUE;
	-- Index in PL/SQL tables set to the last record selected
	g_last_ni     := 4;
      END IF;
      hr_utility.set_location('eoy_body.eoy',370);
--
    END IF; /* End of create type 2 record */
  ELSIF fin_run THEN
--
-- Start the end of tape procedure
--
    hr_utility.trace('Writting record type 4');
    hr_utility.set_location('eoy_body.eoy',600);
    mag_tape_init(5);
    mag_tape_interface('EOY_MODE',g_eoy_mode);
    mag_tape_interface('TOTAL_RECORDS',g_tot_rec2);
    hr_utility.trace('The tot record is '||to_char(g_tot_rec2));
    mag_tape_interface('END_OF_DATA','END OF DATA');
    hr_utility.set_location('eoy_body.eoy',610);
    IF header_cur%ISOPEN THEN
      CLOSE header_cur;
    END IF;
    IF emps_cur%ISOPEN THEN
      CLOSE emps_cur;
    END IF;
  END IF;
  hr_utility.set_location('eoy_body.eoy',999);
END;
--
END;

/
