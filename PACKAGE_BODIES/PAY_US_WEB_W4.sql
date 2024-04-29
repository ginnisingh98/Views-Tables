--------------------------------------------------------
--  DDL for Package Body PAY_US_WEB_W4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_WEB_W4" 
/* $Header: pyuswbw4.pkb 120.18.12010000.8 2009/08/03 15:54:25 kagangul ship $ *
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2000 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_web_w4

    Description : Contains utility and back end procedures for the
		  online W4 Form.

    Uses        :

    Change List
    -----------
    Date        Name    Vers   Description
    ----        ----    ----   -----------
    3-MAR-2000 dscully  110.0  Created.

    24-MAR-2000 dscully 115.0  Created.
    10-APR-2000 dscully 115.1  Added itemtype and process parameters
    01-JUN-2000 dscully 115.2  Changed calls from row handlers to bpi.
    22-JUN-2000 dscully 115.6  Fixed bug caused by fed and states having
			       different codes to mean the same filing status
    28-JUN-2000 dscully 115.7  Fixed bug caused by Arizona defaulting not
			       by law but by the needs of our system
			       Fixed bug caused by benefits assignments being
			       marked primary.
			       Added GRE to audit table so when audit
			       report is run it uses the real GRE value
			       at that date, not the current one.
    19-FEB-2001 meshah  115.8  Changed update_tax_records to insert one
                               record for Federal and State each.
    02-MAR-2001 meshah  115.9  now inserting source3 in pay_stat_trans_audit
                               and attribute_category = W4 State for state
                               records.
    05-MAR-2001 meshah  115.10 Bug 1668926 is fixed now. We need to check the
                               filing status and exemptions between federal and
                               state records before updating state information.
                               Now inserting source3 for federal also.
    15-MAR-2001 meshah  115.11 Now truncating transaction_date before inserting
                               in the pay_stat_trans_audit table.
    27-APR-2001 meshah  115.12 Made changes to the package so that the same
                               package works with the new techstack.
                               1. Added procedure check_update_status.
                               2. Removed the checking from the cursors to get
                                  retiree employees also.
                               3. New parameters and additional logic in procedure
                                  validate_submission and update_tax_records.
                               4. New procedure get_transaction_values.
                               5. New procedure update_w4_info.
                               6. Removed the old calls to review and confirmation
                                  page also the old workflow is removed.
    03-MAY-2001 meshah  115.13 Commented the code where we check if the field id
                               displayed or not in validate_submission procedure.
    07-MAY-2001 meshah  115.14 Now getting the business group id for the person
                               changes made in update_tax_record.
    11-MAY-2001 meshah  115.15 new parameter to validate_submission and
                               new function GET_STATE_LIST.
    11-MAY-2001 meshah  115.16 new source4 and source4_type for State record
                               in update_tax_record.Also removed item_type and
                               added transaction_id.
    23-MAY-2001 meshah  115.17 added a order by clause in get_transaction_values.
    25-MAY-2001 meshah  115.18 New parameter in validate_submission, inserting
                               filing_status_code into transaction table.
                               In get_transaction_values fetching one more
                               value of filing_status_code.
    02-AUG-2001 meshah  115.19 setting the value of l_exempt_status_code to
                               Yes or No in validate_submission.
                               setting the value of l_exempt to Y or N in
                               update_w4_info.
                               Updated update_tax_record, cursor c_fed_tax_rows
                               now selecting paf.primary_flag and depending
                               on the value of the primary flag inserting
                               parent_transaction_id.
    20-AUG-2001 meshah  115.20 Added two more parameter to validate_submission.
                               Removed procedure check_update_status.
    04-SEP-2001 meshah  115.01 adding p_original_exempt. showing message if
                               there is a change in filing status or allowances
                               or exempt status. for this we are now saving
                               the actual Filing status, allowances and exempt
                               satus in transaction tables. changed update_tax_records
                               also.
    10-SEP-2001 meshah  115.02 changed the field name from FitAdditionalTax to
                               TaxString and AgreementFlag to Agreementflag
                               because the names changed in AK.
                               bugs 1986371 and 1983167.
    20-SEP-2001 meshah  115.03 setting l_state_count = 1 when the cursor fetched
                               a record. Depending on the value of l_state_count
                               we print the state message. bug#2004478.
    01-OCT-2001 meshah  115.04 Bug 2006653. Now selecting sit_additional_amount
                               in c_state_tax_record cursor in update_tax_record
                               procedure and updating with the same value.
                               Bug 2015129. In update_tax_record we are now
                               opening the state cursor within the Fed cursor
                               and passing the assignment_id from fed to state.
                               Bug 2015300. Now checking for all the values that
                               are returned from the profile value. (None,null,
                               Primary and All).
    15-OCT-2001 meshah  115.05 bug 2027211, now while validating the record we are
                               calling the update_tax_records procedure to insert
                               the record and also to check if the state will be
                               changed, if yes then set the global variable g_state_list.
                               bug 2038691. Commented the checking for the start
                               and end date with sysdate and the 31-dec-4712.
    20-DEC-2002 meshah  115.06 added index hints for c_excess_over_state and
                               c_future_state_recs cursors for 1159.
                               also added nocopy and dbdrv.
    28-OCT-2003 meshah  115.08 p_exempt_state_list parameters has been
                               added to validate_submission. Function
                               get_state_list has been modified.
                               update_tax_records and validate_submission
                               have been changed to get the states that
                               do not default the exempt status from federal.
                               Bug 3151569. Also now we are updating the
                               transaction values if transaction exists.
    24-Nov-2003 meshah         We insert only those states that are affected
                               by the W4 change.
    04-DEC-2003 meshah  115.09 defaulting cu_sit_exempt to l_state_exempt when
                               the state does not default from federal for
                               exempt status.
    09-DEC-2003 meshah  115.10 made changes to the code since the filing status
                               have been changed for certain states. Example
                               AZ, LA, MA, WV these states don't have a
                               equvivalent code for Married at federal.
                               PROCEDURE update_tax_records has been updated.
    09-APR-2004 meshah  115.11 p_original_aa parameter has been added to procedure
                               validate_submission. Also now we are storing
                               original additional amount in the transaction
                               since we are using a VO to display before and after
                               values in the Review Page.
    07-MAR-2005 meshah  115.12 for bug 4225569 removed the checking for
                               SUI_WAGEBASE_OVERRIDE from function
                               check_update_status.
                               Also added SUI_WAGEBASE_OVERRIDE in
                               update_tax_records so that the same amount
                               gets updated when update the state records.
    23-MAY-2005 rsethupa 115.13 Bug 4070034: Changes to insert new field
                                P_LAST_NAME_DIFF in Audit Table
    16-JUN-2005 rsethupa 115.14 Bug 4204103: Added check for comparing the no. of
                                Tax Exemptions at the Fed and State level
    26-sep-2005 jgoswami 115.15 Bug 4599982 - Added update_alien_tax_records
                               to support pqp calls to old w4 packages.
    26-oct-2005 jgoswami 115.16 Bug 4671389  modified update_tax_records.
    03-nov-2005 jgoswami 115.17 Bug 4671389  modified update_tax_records.
    03-dec-2005 jgoswami 115.18 Bug 4707873  when SUPPLEMENTAL rate for FIT/SIT
                                override is enetred then error message should
                                not be received.
    17-jan-2006 jgoswami 115.19 Bug 4956850 - added new parameter
                               p_transaction_type and p_source_name to
                               procedure update_tax_records

    30-jun-2006 jgoswami 115.21 Bug 5334081 - Not changing state Filing Status
                                to Federal Filing Status when State Does Not
                                Follow Federal. Arizona does NOT use marital
                                status in calculating SIT , they have % of FIT
                                which the employee elects.

    11-aug-2006 jgoswami 115.22 Bug 5198005 - Suppress W4 Notifications for the
                                W4 forms that are exempt or at a level above 10
                                allowances as IRS does not require Employer to
                                Send it. Based on the value of the DFF the
                                Notification will be sent or suppressed. Default
                                the Notification will be Suppressed.
                                Similarly Information message on Review page is
                                also suppressed.
                                Created function get_org_context.

    06-sep-2006 jgoswami 115.23 Bug 3852021 - Modified validate_submission
                                changed data type for p_additional_amount,
                                p_original_aa from varchar2 to Number .

    05-dec-2006 vaprakas 115.24 Bug 5607135 - Modified the procedure
				validate submission to implement check for NRAs.
    13-AUG-2007 vaprakas Bug 6200677 modified
    17-Nov-2007 sudedas  SS W4  Added Function Fed_State_Filing_Status_Match
                                Modified update_tax_records,
				update_w4_info,
				validate_submission.
    19-Nov-2007 sudedas 6333947 Included Changes for this bug.
    21-Nov-2007 sudedas         Changed update_tax_records, Addl Tax Defaulted.
    28-Nov-2007 sudedas         Fixed some issues identified during QA
                        115.30  Fixed Informational Message Display Issue.
    19-May-2008 Pannapur 115.31  Modified update_tax_records to Fix Bug no 7005814
    28-may-2008 asgugupt  115.32  Modified for bug no 7121877
   04-Nov-2008 Pannapur 115.33  Modified for Bug no 7521930
    20-Apr-2009 kagangul 115.34 Bug# 7524676 : Online W4 should not change the Filing
				Status for Arkansas. Employee need to submit AR4EC for the same.
    29-May-2009 kagangul 115.35 Bug# 8518956 : Kansas employee need to submit K-4 State Tax Form,
				shouldn't follow Federal.
				Also changing the way solution was provided for Bug# 7524676
				in the previous version 115.34.
    22-Jun-2009 kagangul 115.36 Bug# 6346579
				Changing the line
				"nvl(stif.sta_information9,'N') exmpt_status_state_as_fed" to
				"nvl(stif.sta_information9,'Y') exmpt_status_state_as_fed"
				as we don't deliver this inforamtion. However this change
				shouldn't introduce any unwanted side effects as we use
				"Fed_State_Filing_Status_Match" function to check whether
				state should follow the federal before updating state records.
    03-Aug-2009 kagangul 115.37 Added code to check if FIT Exempt is being enabled by a NRA
				employee in which case 'Fed_State_Filing_Status_Match' should
				return False irrespective of the State the employee belongs to.
				Also, for other employees making sure it displays the proper message.
  *******************************************************************/
  AS

  /******************************************************************
  ** private package global declarations
  ******************************************************************/
  gv_package_name          VARCHAR2(50) := 'pay_us_web_w4';

-- The following Function has been Added to correct inconsistent behaviour of State W-4
-- For the States that should follow Federal W-4, Filing Status, Allowances etc. should be
-- defaulted from Federal Information for them. Whereas for States that May OR May NOT
-- follow Federal W-4, if Filing Status does not match with State W-4 the information will
-- NOT be copied and an Informational Message will be displayed to Customer.
--

FUNCTION Fed_State_Filing_Status_Match(
			p_state_code    IN pay_us_states.state_code%TYPE
		       ,p_state_org_filing_status_code  IN pay_us_emp_state_tax_rules_f.filing_status_code%TYPE
		       ,p_fed_org_filing_status_code    IN pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE
		       ,p_fed_org_wa              IN pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE
		       ,p_state_org_wa            IN pay_us_emp_state_tax_rules_f.withholding_allowances%TYPE
		       ,p_fed_exmpt_cnt           IN NUMBER
		       ,p_state_empt_cnt          IN NUMBER
		       ,p_new_filing_status_code  IN OUT NOCOPY pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE
		       )
 RETURN BOOLEAN IS

  CURSOR cur_state_name(p_st_cd IN VARCHAR2) IS
  SELECT state_name
  FROM pay_us_states
  WHERE state_code = p_st_cd;

  CURSOR cur_filing_status_meaning(p_state_code VARCHAR2
                                  ,p_filing_status_code VARCHAR2) IS
  SELECT meaning
  FROM   hr_lookups
  WHERE  lookup_type = 'US_FS_'||p_state_code
  AND    lpad(lookup_code,2,'0') = p_filing_status_code
  AND    application_id = 800
  AND    enabled_flag = 'Y';

  lv_state_name   pay_us_states.state_name%TYPE;
  lv_fed_03_meaning  hr_lookups.meaning%TYPE;
  lv_state_fs_meaning hr_lookups.meaning%TYPE;
  lv_state_04_fs_meaning hr_lookups.meaning%TYPE;

  BEGIN
	hr_utility.trace('Entering Into '||gv_package_name||'.Fed_State_Filing_Status_Match');
	hr_utility.trace('p_state_code := '||p_state_code);
	hr_utility.trace('p_state_org_filing_status_code := '||p_state_org_filing_status_code);
	hr_utility.trace('p_fed_org_filing_status_code := '||p_fed_org_filing_status_code);
	hr_utility.trace('p_fed_org_wa := '||p_fed_org_wa);
	hr_utility.trace('p_state_org_wa := '||p_state_org_wa);
	hr_utility.trace('p_fed_exmpt_cnt := '||p_fed_exmpt_cnt);
	hr_utility.trace('p_state_empt_cnt := '||p_state_empt_cnt);
	hr_utility.trace('p_new_filing_status_code := '||p_new_filing_status_code);

        lv_fed_03_meaning := REPLACE(UPPER('Married, but Withhold at Higher Single Rate'), ',');

        OPEN cur_state_name(p_state_code);
	FETCH cur_state_name INTO lv_state_name;
	CLOSE cur_state_name;

	hr_utility.trace('lv_state_name := '||lv_state_name);

        OPEN cur_filing_status_meaning(p_state_code
	                              ,p_state_org_filing_status_code) ;
        FETCH cur_filing_status_meaning INTO lv_state_fs_meaning;
	CLOSE cur_filing_status_meaning;

	hr_utility.trace('lv_state_fs_meaning := '||lv_state_fs_meaning);

        OPEN cur_filing_status_meaning(p_state_code
	                              ,'04') ;
        FETCH cur_filing_status_meaning INTO lv_state_04_fs_meaning;
	CLOSE cur_filing_status_meaning;

	hr_utility.trace('lv_state_04_fs_meaning := '||lv_state_04_fs_meaning);

	/* Bug 6346579 : Start. NRA employee trying to enable FIT Exempt. No need to proceed. */
	IF (g_NRA_flag = 'Y') THEN
	   IF INSTR(NVL(g_not_matching_state_list, '0'), lv_state_name) = 0 THEN
	      IF g_not_matching_state_list IS NOT NULL THEN
	         g_not_matching_state_list := g_not_matching_state_list || ', ' ||lv_state_name;
	      ELSE
		 g_not_matching_state_list := g_not_matching_state_list || ' '||lv_state_name;
	      END IF;
	      g_nonmatch_cntr := g_nonmatch_cntr + 1;
	   END IF;
	   hr_utility.trace('g_nonmatch_cntr := '|| g_nonmatch_cntr);
	   hr_utility.trace('Not Going to Update State Info From Federal.');
	   RETURN FALSE;
	END IF;
	/* Bug 6346579 : End */

       /* Bug # 8518956 : Kansas employee need to submit K-4 State Tax Form, shouldn't follow Federal.
          Hence removing State Code '17' from the below condition */
       /* IF p_state_code IN ('06','08','13','17', '24', '27', '28', '32', '35', '37', '38', '40', '41', '45') THEN */
       IF p_state_code IN ('06','08','13', '24', '27', '28', '32', '35', '37', '38', '40', '41', '45') THEN
       -- For States that should Follow Federal
	  IF p_fed_org_filing_status_code <> p_new_filing_status_code THEN
               -- Filing Status Changed during Transaction

               IF (p_state_org_filing_status_code = p_fed_org_filing_status_code
		  AND p_state_org_wa = p_fed_org_wa
		  AND p_state_empt_cnt = p_fed_exmpt_cnt) THEN

			IF p_new_filing_status_code = '03' THEN
			 /* Modified for bug no 7521930*/
			     IF p_state_code NOT IN ('27','38','41','45') THEN
			     	p_new_filing_status_code := '04';
			      hr_utility.trace('p_new_filing_status_code 1 := ' ||p_new_filing_status_code);
			      RETURN TRUE;
			      ELSE
			       hr_utility.trace('p_new_filing_status_code 1 := ' ||p_new_filing_status_code);
			       RETURN TRUE;
			     END IF ;

			ELSE
			      hr_utility.trace('p_new_filing_status_code 2 := ' ||p_new_filing_status_code);
			      RETURN TRUE;
			END IF;

		ELSIF (p_fed_org_filing_status_code = '03' AND p_state_org_filing_status_code = '04'
		      AND p_state_org_wa = p_fed_org_wa
		      AND p_state_empt_cnt = p_fed_exmpt_cnt) THEN
			hr_utility.trace('p_new_filing_status_code 2 := ' ||p_new_filing_status_code);
			RETURN TRUE;
	        ELSE
			IF INSTR(NVL(g_not_matching_state_list, '0'), lv_state_name) = 0 THEN

			IF g_not_matching_state_list IS NOT NULL THEN
				g_not_matching_state_list := g_not_matching_state_list || ', ' ||lv_state_name;
			ELSE
				g_not_matching_state_list := g_not_matching_state_list || ' '||lv_state_name;
			END IF;
			g_nonmatch_cntr := g_nonmatch_cntr + 1;
			END IF;

			p_new_filing_status_code := p_state_org_filing_status_code ;
                        hr_utility.trace('p_new_filing_status_code 3 := ' || p_new_filing_status_code);
			hr_utility.trace('g_nonmatch_cntr := '|| g_nonmatch_cntr);
			hr_utility.trace('Not Going to Update State Info From Federal.');
			RETURN FALSE;
	        END IF;

	 ELSIF p_fed_org_filing_status_code = p_new_filing_status_code THEN

	   IF (p_state_org_filing_status_code = p_fed_org_filing_status_code
	       AND p_state_org_wa = p_fed_org_wa
	       AND p_state_empt_cnt = p_fed_exmpt_cnt) OR

              (p_fed_org_filing_status_code = '03' AND p_state_org_filing_status_code = '04'
		AND p_state_org_wa = p_fed_org_wa
		AND p_state_empt_cnt = p_fed_exmpt_cnt) THEN

		      p_new_filing_status_code := p_state_org_filing_status_code;
		      hr_utility.trace('p_new_filing_status_code 4 := ' ||p_new_filing_status_code);
		      RETURN TRUE;
            ELSE
		IF INSTR(NVL(g_not_matching_state_list, '0'), lv_state_name) = 0 THEN

		IF g_not_matching_state_list IS NOT NULL THEN
			g_not_matching_state_list := g_not_matching_state_list || ', ' ||lv_state_name;
		ELSE
			g_not_matching_state_list := g_not_matching_state_list || ' '||lv_state_name;
		END IF;
		g_nonmatch_cntr := g_nonmatch_cntr + 1;
		END IF;

		p_new_filing_status_code := p_state_org_filing_status_code ;
		hr_utility.trace('p_new_filing_status_code 4 := ' || p_new_filing_status_code);
		hr_utility.trace('g_nonmatch_cntr := '|| g_nonmatch_cntr);
		hr_utility.trace('Not Going to Update State Info From Federal.');

		RETURN FALSE;
            END IF;
	  END IF; -- p_fed_org_filing_status_code <> p_new_filing_status_code

     /*  Bug # 7524676
	 Online W4 should not change the Filing Status for Arkansas.
	 Employee need to submit AR4EC for the same. Hence removed state code '04'
	 from the following condition
	 ELSIF p_state_code IN ('04', '05', '19', '22', '31', '46', '49', '50') THEN */

     ELSIF p_state_code IN ('05', '19', '22', '31', '46', '49', '50') THEN
     -- For States that May or May Not Follow Federal

	    IF p_fed_org_filing_status_code <> p_new_filing_status_code THEN
                -- Filing Status Changed during Transaction

                IF p_state_code NOT IN ( '19', '22' ) THEN
		-- LA and MA are Exceptions (Different Filing Status Codes for "Single (01)"/"Married (02)"

			IF ((p_state_org_filing_status_code = p_fed_org_filing_status_code) OR
			    (p_fed_org_filing_status_code = '03'  AND
			     REPLACE(UPPER(lv_state_fs_meaning), ',') = lv_fed_03_meaning)
			   AND p_state_org_wa = p_fed_org_wa
			   AND p_state_empt_cnt = p_fed_exmpt_cnt) THEN

			      IF p_new_filing_status_code IN ('01', '02') THEN
				 RETURN TRUE;
			      ELSIF p_new_filing_status_code = '03' AND
			            REPLACE(UPPER(lv_state_04_fs_meaning), ',') = lv_fed_03_meaning THEN
				    p_new_filing_status_code := '04';
				    RETURN TRUE;
			      ELSIF p_new_filing_status_code = '03' THEN
				   IF INSTR(NVL(g_not_matching_state_list, '0'), lv_state_name) = 0 THEN

					IF g_not_matching_state_list IS NOT NULL THEN
						g_not_matching_state_list := g_not_matching_state_list || ', ' ||lv_state_name;
					ELSE
						g_not_matching_state_list := g_not_matching_state_list || ' '||lv_state_name;
					END IF;
					g_nonmatch_cntr := g_nonmatch_cntr + 1;
				   END IF;
				  p_new_filing_status_code := p_state_org_filing_status_code ;
				  hr_utility.trace('g_nonmatch_cntr 2 := '||g_nonmatch_cntr);
				  hr_utility.trace('p_state_org_filing_status_code := '||p_state_org_filing_status_code);
		                  hr_utility.trace('Not Going to Update State Info From Federal.');
				  RETURN FALSE;
			      END IF;
			 ELSE
			   IF INSTR(NVL(g_not_matching_state_list, '0'), lv_state_name) = 0 THEN

				IF g_not_matching_state_list IS NOT NULL THEN
					g_not_matching_state_list := g_not_matching_state_list || ', ' ||lv_state_name;
				ELSE
					g_not_matching_state_list := g_not_matching_state_list || ' '||lv_state_name;
				END IF;
				g_nonmatch_cntr := g_nonmatch_cntr + 1;
			   END IF;
			  p_new_filing_status_code := p_state_org_filing_status_code ;
			  hr_utility.trace('g_nonmatch_cntr 2 := '||g_nonmatch_cntr);
			  hr_utility.trace('p_state_org_filing_status_code := '||p_state_org_filing_status_code);
	                  hr_utility.trace('Not Going to Update State Info From Federal.');
			  RETURN FALSE;

			 END IF;

		ELSIF p_state_code = '19' THEN -- For LA, Single --> '02', Married --> '03'

			IF ((p_state_org_filing_status_code = p_fed_org_filing_status_code) OR
                            (p_fed_org_filing_status_code = '01' AND p_state_org_filing_status_code = '02') OR
                            (p_fed_org_filing_status_code = '02' AND p_state_org_filing_status_code = '03'))
			AND p_state_org_wa = p_fed_org_wa
			AND p_state_empt_cnt = p_fed_exmpt_cnt THEN


			      IF p_new_filing_status_code = '01' THEN
			         p_new_filing_status_code := '02';
				 RETURN TRUE;
			      ELSIF p_new_filing_status_code = '02' THEN
			         p_new_filing_status_code := '03';
				 RETURN TRUE;

			      ELSIF p_new_filing_status_code = '03' THEN
				   IF INSTR(NVL(g_not_matching_state_list, '0'), lv_state_name) = 0 THEN

					IF g_not_matching_state_list IS NOT NULL THEN
						g_not_matching_state_list := g_not_matching_state_list || ', ' ||lv_state_name;
					ELSE
						g_not_matching_state_list := g_not_matching_state_list || ' '||lv_state_name;
					END IF;
					g_nonmatch_cntr := g_nonmatch_cntr + 1;
				   END IF;
				  p_new_filing_status_code := p_state_org_filing_status_code ;
				  hr_utility.trace('g_nonmatch_cntr 2 := '||g_nonmatch_cntr);
				  hr_utility.trace('p_state_org_filing_status_code := '||p_state_org_filing_status_code);
	                          hr_utility.trace('Not Going to Update State Info From Federal.');
				  RETURN FALSE;
			      END IF;
			 ELSE
				   IF INSTR(NVL(g_not_matching_state_list, '0'), lv_state_name) = 0 THEN

					IF g_not_matching_state_list IS NOT NULL THEN
						g_not_matching_state_list := g_not_matching_state_list || ', ' ||lv_state_name;
					ELSE
						g_not_matching_state_list := g_not_matching_state_list || ' '||lv_state_name;
					END IF;
					g_nonmatch_cntr := g_nonmatch_cntr + 1;
				   END IF;
				  p_new_filing_status_code := p_state_org_filing_status_code ;
				  hr_utility.trace('g_nonmatch_cntr 2 := '||g_nonmatch_cntr);
				  hr_utility.trace('p_state_org_filing_status_code := '||p_state_org_filing_status_code);
				  hr_utility.trace('Not Going to Update State Info From Federal.');
				  RETURN FALSE;
		         END IF;

	        ELSIF p_state_code = '22' THEN -- For MA, Single (04), Married (04) --> Other than Head of Household

			IF ((p_state_org_filing_status_code = p_fed_org_filing_status_code) OR
                            (p_fed_org_filing_status_code = '01' AND p_state_org_filing_status_code = '04') OR
                            (p_fed_org_filing_status_code = '02' AND p_state_org_filing_status_code = '04'))
			AND p_state_org_wa = p_fed_org_wa
			AND p_state_empt_cnt = p_fed_exmpt_cnt THEN


			      IF p_new_filing_status_code = '01' THEN
			         p_new_filing_status_code := '04';
				 RETURN TRUE;
			      ELSIF p_new_filing_status_code = '02' THEN
			         p_new_filing_status_code := '04';
				 RETURN TRUE;

			      ELSIF p_new_filing_status_code = '03' THEN
				   IF INSTR(NVL(g_not_matching_state_list, '0'), lv_state_name) = 0 THEN

					IF g_not_matching_state_list IS NOT NULL THEN
						g_not_matching_state_list := g_not_matching_state_list || ', ' ||lv_state_name;
					ELSE
						g_not_matching_state_list := g_not_matching_state_list || ' '||lv_state_name;
					END IF;
					g_nonmatch_cntr := g_nonmatch_cntr + 1;
				   END IF;
				  p_new_filing_status_code := p_state_org_filing_status_code ;
				  hr_utility.trace('g_nonmatch_cntr 2 := '||g_nonmatch_cntr);
				  hr_utility.trace('p_state_org_filing_status_code := '||p_state_org_filing_status_code);
				  hr_utility.trace('Not Going to Update State Info From Federal.');
				  RETURN FALSE;
			      END IF;
			 ELSE
				   IF INSTR(NVL(g_not_matching_state_list, '0'), lv_state_name) = 0 THEN

					IF g_not_matching_state_list IS NOT NULL THEN
						g_not_matching_state_list := g_not_matching_state_list || ', ' ||lv_state_name;
					ELSE
						g_not_matching_state_list := g_not_matching_state_list || ' '||lv_state_name;
					END IF;
					g_nonmatch_cntr := g_nonmatch_cntr + 1;
				   END IF;
				  p_new_filing_status_code := p_state_org_filing_status_code ;
				  hr_utility.trace('g_nonmatch_cntr 2 := '||g_nonmatch_cntr);
				  hr_utility.trace('p_state_org_filing_status_code := '||p_state_org_filing_status_code);
				  RETURN FALSE;
		         END IF;

		END IF; -- p_state_code NOT IN ('19', '22)

	 ELSIF p_fed_org_filing_status_code = p_new_filing_status_code THEN

		   IF ((p_state_org_filing_status_code = p_fed_org_filing_status_code) OR
		    (p_fed_org_filing_status_code = '03'  AND
		     REPLACE(UPPER(lv_state_fs_meaning), ',') = lv_fed_03_meaning)
		    AND p_state_org_wa = p_fed_org_wa
		    AND p_state_empt_cnt = p_fed_exmpt_cnt) OR
		      (p_fed_org_filing_status_code = '01' AND p_state_org_filing_status_code = '02'
			AND p_state_org_wa = p_fed_org_wa
			AND p_state_empt_cnt = p_fed_exmpt_cnt
			AND p_state_code = '19') OR
		      (p_fed_org_filing_status_code = '02' AND p_state_org_filing_status_code = '03'
			AND p_state_org_wa = p_fed_org_wa
			AND p_state_empt_cnt = p_fed_exmpt_cnt
			AND p_state_code = '19') OR
		      (p_fed_org_filing_status_code = '01' AND p_state_org_filing_status_code = '04'
			AND p_state_org_wa = p_fed_org_wa
			AND p_state_empt_cnt = p_fed_exmpt_cnt
			AND p_state_code = '22') OR
		      (p_fed_org_filing_status_code = '02' AND p_state_org_filing_status_code = '04'
			AND p_state_org_wa = p_fed_org_wa
			AND p_state_empt_cnt = p_fed_exmpt_cnt
			AND p_state_code = '22')
			THEN

			      p_new_filing_status_code := p_state_org_filing_status_code;
			      hr_utility.trace('p_new_filing_status_code 4 := ' ||p_new_filing_status_code);
			      RETURN TRUE;
		    ELSE

			   IF INSTR(NVL(g_not_matching_state_list, '0'), lv_state_name) = 0 THEN

				IF g_not_matching_state_list IS NOT NULL THEN
					g_not_matching_state_list := g_not_matching_state_list || ', ' ||lv_state_name;
				ELSE
					g_not_matching_state_list := g_not_matching_state_list || ' '||lv_state_name;
				END IF;
				g_nonmatch_cntr := g_nonmatch_cntr + 1;
			   END IF;
			   p_new_filing_status_code := p_state_org_filing_status_code ;
			   hr_utility.trace('g_nonmatch_cntr 3 := '||g_nonmatch_cntr);
			   hr_utility.trace('p_state_org_filing_status_code := '||p_state_org_filing_status_code);
			   RETURN FALSE;

		     END IF;
	   END IF; -- p_fed_org_filing_status_code <> p_new_filing_status_code
	ELSE
               IF INSTR(NVL(g_not_matching_state_list, '0'), lv_state_name) = 0 THEN

			IF g_not_matching_state_list IS NOT NULL THEN
				g_not_matching_state_list := g_not_matching_state_list || ', ' ||lv_state_name;
			ELSE
				g_not_matching_state_list := g_not_matching_state_list || ' '||lv_state_name;
			END IF;
			g_nonmatch_cntr := g_nonmatch_cntr + 1;
		END IF;
		p_new_filing_status_code := p_state_org_filing_status_code ;

	        hr_utility.trace('g_nonmatch_cntr 2 := '||g_nonmatch_cntr);
		RETURN FALSE;
	END IF; -- State Following Federal Or NOT

  END Fed_State_Filing_Status_Match;

  FUNCTION check_update_status(p_person_id IN	per_people_f.person_id%TYPE)
  	RETURN VARCHAR2
 /******************************************************************
  **
  ** Description:
  **     checks whether person meets update allowed status
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/
  IS

     l_primary_only 	VARCHAR2(1);

     CURSOR c_excess_over_fed IS
	select 	'x'
	from	per_assignments_f paf,
		pay_us_emp_fed_tax_rules_f ftr
	where 	paf.person_id = p_person_id
	  and	ftr.assignment_id = paf.assignment_id
	  and   paf.assignment_type = 'E'
	  and	decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
	  and	trunc(sysdate) between ftr.effective_start_date and
                                       ftr.effective_end_date
	  and	trunc(sysdate) between paf.effective_start_date and
                                       paf.effective_end_date
	  and	(ftr.excessive_wa_reject_date is not null
		 or nvl(ftr.fit_override_rate,0) <> 0
 -- bug 4707873 --or nvl(ftr.supp_tax_override_rate,0) <> 0
		 or nvl(ftr.fit_override_amount,0) <> 0);

     CURSOR c_excess_over_state IS
	select 	/*+ INDEX (stif pay_us_state_tax_info_f_n1) */ 'x'
	from	per_assignments_f paf,
		pay_us_emp_state_tax_rules_f str,
		pay_us_state_tax_info_f stif
	where 	paf.person_id = p_person_id
	  and 	paf.assignment_type = 'E'
	  and	str.assignment_id = paf.assignment_id
	  and	stif.state_code = str.state_code
	  and	stif.sta_information7 like 'Y%'
	  and	decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
	  and	trunc(sysdate) between str.effective_start_date and
                                       str.effective_end_date
	  and	trunc(sysdate) between paf.effective_start_date and
                                       paf.effective_end_date
	  and	(str.excessive_wa_reject_date is not null
		 or nvl(str.sit_override_amount,0) <> 0
		 or nvl(str.sit_override_rate,0) <> 0
		 --or nvl(str.sui_wage_base_override_amount,0) <> 0
 -- bug 4707873 --or nvl(str.supp_tax_override_rate,0) <> 0
                );

     CURSOR c_future_fed_recs IS
	select 'x'
	from	per_assignments_f paf,
		pay_us_emp_fed_tax_rules_f ftr
	where	paf.person_id = p_person_id
	  and   paf.assignment_type = 'E'
	  and	ftr.assignment_id = paf.assignment_id
	  and	decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
	  and  	ftr.effective_start_date > trunc(sysdate)
	  and	trunc(sysdate) between paf.effective_start_date and
                                       paf.effective_end_date;

     CURSOR c_future_state_recs IS
	select /*+ INDEX (stif pay_us_state_tax_info_f_n1) */ 'x'
	from	per_assignments_f paf,
		pay_us_emp_state_tax_rules_f str,
		pay_us_state_tax_info_f stif
	where	paf.person_id = p_person_id
	  and	str.assignment_id = paf.assignment_id
	  and	paf.assignment_type = 'E'
	  and	decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
	  and	stif.state_code = str.state_code
 	  and	stif.sta_information7 like 'Y%'
	  and  	str.effective_start_date > trunc(sysdate)
	  and	trunc(sysdate) between paf.effective_start_date and
                                       paf.effective_end_date
	  and	trunc(sysdate) between stif.effective_start_date and
                                       stif.effective_end_date;

     curs_dummy 	VARCHAR2(1);
     lv_update_method	VARCHAR2(30);

  BEGIN

     hr_utility.trace('Entering ' || gv_package_name || '.check_update_status');


     lv_update_method := fnd_profile.value('HR_OTF_UPDATE_METHOD');
     hr_utility.trace('OTF Update Method = ' || lv_update_method);

     -- check for update method set to NONE
     hr_utility.trace('Testing PROFILE HR_OTF_UPDATE_METHOD');

     if lv_update_method = 'PRIMARY' then
	l_primary_only := 'Y';

     elsif lv_update_method = 'ALL' then
	l_primary_only := 'N';

     else -- update_method = NONE or null
          -- we always default the value to primary
        l_primary_only := 'Y';

     end if;

     hr_utility.trace('Passed PROFILE HR_OTF_UPDATE_METHOD');

     -- check for excessive wa reject date or override amounts
     -- Note: we don't actually check the date of the reject, just
     --	 	it's existence shuts the employee out

     hr_utility.trace('Testing FED_EXCESSIVE_WA_REJECT_DATE/OVERRIDES');
     open c_excess_over_fed;
     fetch c_excess_over_fed into curs_dummy;

     if c_excess_over_fed%FOUND then
	hr_utility.trace('Failed on FED_EXCESSIVE_WA_REJECT_DATE/OVERRIDES');
	close c_excess_over_fed;
	return ('PAY-PAY_US_OTF_REJECT_DATE_OR_OVER');
     end if;

     close c_excess_over_fed;
     hr_utility.trace('Passed FED_EXCESSIVE_WA_REJECT_DATE/OVERRIDES');

     hr_utility.trace('Testing STATE_EXCESSIVE_WA_REJECT_DATE/OVERRIDES');
     open c_excess_over_state;
     fetch c_excess_over_state into curs_dummy;

     if c_excess_over_state%FOUND then
	hr_utility.trace('Failed on STATE_EXCESSIVE_WA_REJECT_DATE/OVERRIDES');
	close c_excess_over_state;
	return  ('PAY-PAY_US_OTF_REJECT_DATE_OR_OVER');
     end if;
     close c_excess_over_state;
     hr_utility.trace('Passed STATE_EXCESSIVE_WA_REJECT_DATE/OVERRIDES');


     -- check for any future dated changes in non-retiree asgs for both state and fed

     hr_utility.trace('Testing FED_FUTURE_DATED_CHANGES');
     open c_future_fed_recs;
     fetch c_future_fed_recs into curs_dummy;
     if c_future_fed_recs%FOUND then
	hr_utility.trace('Failed on FED_FUTURE_DATED_CHANGES');
     	return ('PAY-PAY_US_OTF_FUTURE_RECORDS');
     end if;

     close c_future_fed_recs;
     hr_utility.trace('Passed FED_FUTURE_DATED_CHANGES');

     hr_utility.trace('Testing STATE_FUTURE_DATED_CHANGES');
     open c_future_state_recs;
     fetch c_future_state_recs into curs_dummy;
     if c_future_state_recs%FOUND then
	hr_utility.trace('Failed on STATE_FUTURE_DATED_CHANGES');
	return ('PAY-PAY_US_OTF_FUTURE_RECORDS');
     end if;

     close c_future_state_recs;
     hr_utility.trace('Passed STATE_FUTURE_DATED_CHANGES');

     -- if we've reached this point, then allow update
     hr_utility.trace('Leaving ' || gv_package_name || '.check_update_status');
     return null;

   EXCEPTION
	WHEN OTHERS THEN
             return null;

end check_update_status;


  PROCEDURE validate_submission(p_filing_status_code IN	VARCHAR2 DEFAULT null,
			 --p_additional_amount  IN	VARCHAR2 DEFAULT null,
			 p_additional_amount  IN	NUMBER   DEFAULT null,
			 p_allowances	      IN	VARCHAR2 DEFAULT null,
			 p_exempt_status_code IN	VARCHAR2 DEFAULT null,
			 p_agreement	      IN	VARCHAR2 DEFAULT 'N',
                         p_person_id          IN        VARCHAR2,
                         p_error              OUT nocopy VARCHAR2,
                         p_errorcnt           OUT nocopy INTEGER,
                         p_itemtype           IN        VARCHAR2,
                         p_itemkey            IN        VARCHAR2,
                         p_activity_id        IN        NUMBER,
                         p_state_list         OUT nocopy VARCHAR2,
                         p_over_allowance     OUT nocopy VARCHAR2,
                         p_exempt_exception   OUT nocopy VARCHAR2,
                         p_original_fs        IN        VARCHAR2,
                         p_original_wa        IN        VARCHAR2,
                         p_original_exempt    IN        VARCHAR2,
                         p_exempt_state_list  OUT nocopy VARCHAR2,
                         --p_original_aa        IN        VARCHAR2,
                         p_original_aa        IN        NUMBER,
			 p_last_name_diff     IN        VARCHAR2 DEFAULT 'N',
                         p_fit_exempt     OUT nocopy VARCHAR2
			 )

  /******************************************************************
  **
  ** Description:
  **     validates the submitted values using the API chk_ procedures
  **	 for fed and state tax rules
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/
  AS
	ln_add_tax	        pay_us_emp_fed_tax_rules_f.fit_additional_tax%TYPE;
	l_additional_tax	pay_us_emp_fed_tax_rules_f.fit_additional_tax%TYPE;
	l_allowances		pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE;
	l_filing_status_code	pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE;
	l_exempt_status_code	pay_us_emp_fed_tax_rules_f.fit_exempt%TYPE;
	ln_person_id		per_people_f.person_id%TYPE;
	ln_business_group_id	per_people_f.business_group_id%TYPE;
	ln_organization_id	hr_organization_information.organization_id%TYPE;
	lr_org_info_rec   	hr_organization_information%ROWTYPE;
--	lrr_item_rec	        pay_us_misc_web.item_attr_rec;
	lv_has_errors		VARCHAR2(1) := 'N';
	lv_update_error_msg	VARCHAR2(10000);
	lv_state_list		VARCHAR2(10000);
	ln_state_count		INTEGER;
	l_primary_only		VARCHAR2(1);
        l_agreement             VARCHAR2(1);
        l_last_name_diff_flag   VARCHAR2(1);
        l_error                 VARCHAR2(10000) := null;
        l_num                   INTEGER := 0;
        lv_trans_type           VARCHAR2(50);
        lv_source_name          VARCHAR2(50);
        lv_context              VARCHAR2(50);
        lv_level                VARCHAR2(50);
        lv_notify               VARCHAR2(100);

        l_review_region         VARCHAR2(80);
        common_exception        EXCEPTION;

	lv_update_method	   VARCHAR2(30) := 'PRIMARY' ;
        l_transaction_id           hr_api_transactions.transaction_id%type;
        l_transaction_step_id      hr_api_transaction_steps.transaction_step_id%type;
        l_transaction_value_id     hr_api_transaction_values.transaction_value_id%type;
        l_step_obj_version_number  hr_api_transaction_steps.object_version_number%type;
        transaction_value_fs       VARCHAR2(80);

        CURSOR c_fed_allowance_limit is
                select  fed_information1
                from    pay_us_federal_tax_info_f
                where   fed_information_category = 'ALLOWANCES LIMIT'
                and     trunc(sysdate) between effective_start_date and effective_end_date;

        l_fed_allowance_limit  pay_us_federal_tax_info_f.fed_information1%type;

        cursor get_function_info ( p_item_type HR_API_TRANSACTION_STEPS.item_type%TYPE
                                  ,p_item_key HR_API_TRANSACTION_STEPS.item_key%TYPE ) is
              select fff.function_id, fff.function_name
              from fnd_form_functions_vl fff
              where fff.function_name = ( select iav.text_value
                                          from wf_item_attribute_values iav
                                          where iav.item_type = p_item_type
                                            and iav.item_key = p_item_key
                                            and iav.name = 'P_CALLED_FROM') ;

        lv_process_name   hr_api_transactions.process_name%TYPE;
        l_function_id     hr_api_transactions.function_id%TYPE;
        l_function_name   fnd_form_functions_vl.function_name%TYPE default null;
        lv_transaction_type   varchar2(20);

	--added by vaprakas 11/21/06  Bug 5607135
        cursor csr_chk_NRA_status
            is
            select information_type,pei_information_category,pei_information5,pei_information9
            from per_people_extra_info where person_id=p_person_id
                          and information_type like 'PER_US_ADDITIONAL_DETAILS'
                          and pei_information_category like 'PER_US_ADDITIONAL_DETAILS'
                          and pei_information5 like 'N'
                          and pei_information9 not in ('US');

        cursor csr_chk_student_status
            is
            select pei_information1,pei_information2
            from per_people_extra_info where person_id=p_person_id
                          and information_type like 'PER_US_ADDITIONAL_DETAILS'
                          and pei_information_category like 'PER_US_ADDITIONAL_DETAILS'
			  and (pei_information1 = 'Y'
                          or pei_information2 = 'Y');


	l_information_type           per_people_extra_info.information_type%TYPE;
	l_pei_information_category   per_people_extra_info.pei_information_category%TYPE;
	l_pei_information5           per_people_extra_info.pei_information5%TYPE;
	l_pei_information9           per_people_extra_info.pei_information9%TYPE;
	l_student_flag               varchar2(3);
	l_student                    per_people_extra_info.pei_information1%TYPE;
	l_business_apprentice        per_people_extra_info.pei_information2%TYPE;

	ln_prev_comma_position       NUMBER;
	ln_comma_position            NUMBER;
	lv_notmatch_state            pay_us_states.state_name%TYPE;


  BEGIN

 	hr_utility.trace('Entering '|| gv_package_name || '.validate_submission');
	hr_utility.trace('p_filing_status_code = ' || p_filing_status_code);
	hr_utility.trace('p_exempt_status_code = ' || p_exempt_status_code);
	hr_utility.trace('p_allowances = ' || p_allowances);
	hr_utility.trace('p_additional_amount = ' || p_additional_amount);
	hr_utility.trace('p_itemtype = ' || p_itemtype);
	hr_utility.trace('p_itemkey = ' || p_itemkey);
	hr_utility.trace('p_activity_id = ' || p_activity_id);
	hr_utility.trace('p_last_name_diff = ' || p_last_name_diff);
	hr_utility.trace('p_agreement = ' || p_agreement);
        hr_utility.trace('p_person_id = ' || p_person_id);
	hr_utility.trace('p_original_fs = ' || p_original_fs);
	hr_utility.trace('p_original_wa = ' || p_original_wa);
	hr_utility.trace('p_original_exempt = ' || p_original_exempt);
	hr_utility.trace('p_original_aa = ' || p_original_aa);

-- first this is we clear the global value of g_state_list before we continue
-- this will ensure we get the fresh list everytime a user comes back from the
-- review page.

        g_state_list := null;
        g_state_exempt_list := null;

	g_not_matching_state_list := NULL;
	g_nonmatch_cntr := 0;


        ln_person_id := to_number(p_person_id);
        p_fit_exempt:= null;

	-- validate filing status

	BEGIN
	   hr_utility.trace('Checking filing status');
	   -- next call the api chk_procedure
	   -- we call it with a null id to insure that it is validated
	   -- withhout having to worry about calling api_updating
	   -- we also provide the sysdate and end-of-time as the validation
	   -- dates since we do updates on the sysdate and only if there are
	   -- no future dated records.
	   pay_fed_bus.chk_filing_status_code(
			p_emp_fed_tax_rule_id    => null
			,p_filing_status_code    => p_filing_status_code
			,p_effective_date        => trunc(sysdate)
			,p_validation_start_date => trunc(sysdate)
			,p_validation_end_date   => to_date('31/12/4712','DD/MM/YYYY')
				);
	EXCEPTION
	   WHEN OTHERS then
		hr_utility.trace('Rejecting Filing Status');

                if l_error is null then
                   l_error := 'PAY-PAY_FILING_STATUS_ERROR-FilingStatusCode';
                else
                   l_error := l_error||';'||'PAY-PAY_FILING_STATUS_ERROR-FilingStatusCode';
                end if;

                l_num := l_num + 1;
                lv_has_errors := 'Y';
	END;

-- validate allowances
	BEGIN
	   hr_utility.trace('Checking total allowances');
	   -- First we convert it into a NUMBER

   	   l_allowances := to_number(nvl(p_allowances,0),'999');

	   hr_utility.trace('l_allowances = ' || to_char(l_allowances));

           if l_allowances < 0 then
              raise VALUE_ERROR;
           end if;

	   -- next call the api chk_procedure
	   pay_fed_bus.chk_withholding_allowances(
			p_emp_fed_tax_rule_id      => null
			,p_withholding_allowances  => l_allowances
			);
	EXCEPTION
	   WHEN VALUE_ERROR then
	 	hr_utility.trace('Rejecting Total Allowances - number err');

                if l_error is null then
                   l_error := 'PAY-PAY_US_OTF_FED_WA_NUMBER-WithholdingAllowances';
                else
                   l_error := l_error||';'||'PAY-PAY_US_OTF_FED_WA_NUMBER-WithholdingAllowances';
                end if;

                l_num := l_num + 1;
		lv_has_errors := 'Y';

	   WHEN OTHERS then
		hr_utility.trace('Reject Total Allowances - api err');

                if l_error is null then
                   l_error := 'PAY-PAY_PLSQL_ERROR-WithholdingAllowances';
                else
                   l_error := l_error||';'||'PAY-PAY_PLSQL_ERROR-WithholdingAllowances';
                end if;

                l_num := l_num + 1;
        	lv_has_errors := 'Y';
	END;

-- Check the Organization Level and/or Business Group Level Context
--is Set for W4 Notifications.
-- Organization Level Context
   lv_context := 'US_ORG_REP_PREFERENCES';
   lv_level := 'ORG';

   lv_notify := get_org_context(ln_person_id, lv_context,lv_level);

   hr_utility.trace('ORG get_org_context lv_notify = '||lv_notify);
   if lv_notify = 'NOTFOUND' then
      -- Business Group Level Context
         lv_context := 'US_BG_REP_PREFERENCES';
         lv_level := 'BG';
         lv_notify := get_org_context(ln_person_id, lv_context,lv_level);
         hr_utility.trace('BG get_org_context lv_notify = '||lv_notify);
    end if;


-- Also check if the allowance entered by the user is > to the federal allowance limit.

     open c_fed_allowance_limit;
     fetch c_fed_allowance_limit into l_fed_allowance_limit;
     close c_fed_allowance_limit;

     hr_utility.trace('b4 checking lv_notify = '||lv_notify);

   --------------- added by vaprakas bug 5601735
   l_student_flag :='No';

   open csr_chk_student_status;
   fetch csr_chk_student_status into l_student,l_business_apprentice;
   if csr_chk_student_status%FOUND
	then l_student_flag :='Yes';
   end if;
   close csr_chk_student_status;


   open csr_chk_NRA_status;
   fetch csr_chk_NRA_status into l_information_type,l_pei_information_category,l_pei_information5,l_pei_information9;
	if csr_chk_NRA_status%FOUND
		then
       		if to_number(l_allowances)>1 and not
                   (l_pei_information9 in ('CA','MX','KS') or (l_student_flag ='Yes' and l_pei_information9 = 'IN'))
			then
			if l_error is null
				then
				l_error := 'PAY-PAY_US_CHK_NRA_W4_ALLOWANCES-WithholdingAllowances';
				else
				l_error := l_error||';'||'PAY-PAY_US_CHK_NRA_W4_ALLOWANCES-WithholdingAllowances';
			end if;
		l_num := l_num + 1;
		lv_has_errors := 'Y';
		end if;

		if p_filing_status_code <> '01'
		then
			if l_error is null
				then
				l_error := 'PAY-PAY_US_CHK_NRA_FILING_STATUS-FilingStatusCode';
				else
			        l_error := l_error||';'||'PAY-PAY_US_CHK_NRA_FILING_STATUS-FilingStatusCode';
			end if;
		l_num := l_num + 1;
        	lv_has_errors := 'Y';
		end if;

		if p_exempt_status_code ='on'
                then
--modified for bug 7121877
                        p_fit_exempt := hr_util_misc_web.return_msg_text('PAY_US_CHK_NRA_FIT_EXEMPTIONS','PAY');
--modified for bug 7121877
			/* Bug 6346579 : Added the following to track the NRA employee trying to
					 enable FIT Exempt.*/
			g_NRA_flag := 'Y';
                end if;
        end if;
   close csr_chk_NRA_status;
   ---------------- Added by vaprakas Bug 5607135

     if lv_notify <> 'Y' then
        p_over_allowance := null;
     else
     if (l_fed_allowance_limit is not null) and
              (to_number(l_allowances) > to_number(l_fed_allowance_limit) ) then

        p_over_allowance := hr_util_misc_web.return_msg_text('PAY_US_OTF_W4_FED_OVERALLOW','PAY');

     end if;
     end if;

-- validate additional tax
	BEGIN
	   hr_utility.trace('Checking Additional Tax');

	   ln_add_tax := nvl(p_additional_amount,0);

	   hr_utility.trace('ln_add_tax value is : '||ln_add_tax);
	   l_additional_tax := ln_add_tax;
	   hr_utility.trace('l_additional_tax value is : '|| l_additional_tax);

           if l_additional_tax < 0 then
              raise value_error;
           end if;

-- next call the api chk_procedure
	   pay_fed_bus.chk_fit_additional_tax(
			p_emp_fed_tax_rule_id => null
		       ,p_fit_additional_tax  => l_additional_tax
			);
	EXCEPTION
	   WHEN VALUE_ERROR then
		hr_utility.trace('Rejecting add. tax - number err');

                if l_error is null then
                   l_error := 'PAY-PAY_US_OTF_FED_ADD_TAX_NUMBER-TaxString';
                else
                   l_error := l_error||';'||'PAY-PAY_US_OTF_FED_ADD_TAX_NUMBER-TaxString';
                end if;

                l_num := l_num + 1;
		lv_has_errors := 'Y';

	   WHEN OTHERS then
		hr_utility.trace('Rejecting add. tax - api err');

                if l_error is null then
                   l_error := 'PAY-PAY_PLSQL_ERROR-TaxString';
                else
                   l_error := l_error||';'||'PAY-PAY_PLSQL_ERROR-TaxString';
                end if;

                l_num := l_num + 1;
		lv_has_errors := 'Y';
	END;

-- validate exempt status code

	hr_utility.trace('Checking exempt status');
	-- the only validation we do is replace a 'N' for null
	if p_exempt_status_code = 'on' then
	   l_exempt_status_code := 'Yes';

           if lv_notify <> 'Y' then
              p_exempt_exception := null;
           else
              p_exempt_exception := hr_util_misc_web.return_msg_text('PAYSSW4_EXEMPT_MSG','PAY');
           end if;
	else
	   l_exempt_status_code := 'No';
	end if;

-- validate the agreement prompt
	hr_utility.trace('Checking agreement flag');

        if p_agreement = 'on' then
           l_agreement := 'Y';
        else
	   hr_utility.trace('Rejecting agreement flag');

           if l_error is null then
              l_error := 'PAY-PAY_US_OTF_AGREE_ERROR-Agreementflag';
           else
              l_error := l_error||';'||'PAY-PAY_US_OTF_AGREE_ERROR-Agreementflag';
           end if;

           l_num := l_num + 1;
	   lv_has_errors := 'Y';
	end if;

-- validate the Last name Different Flag
        hr_utility.trace('Checking Last Name Different flag');

        if p_last_name_diff = 'on' then
           l_last_name_diff_flag := 'Y';
        else
	   l_last_name_diff_flag := 'N';
        end if;


-- If we have errors at this point, we go back to the update page
	if lv_has_errors = 'Y' then

           p_errorcnt := l_num ;
           p_error := l_error;

           hr_utility.trace('Error string : '|| p_error);
	   hr_utility.trace('Number of Errors : '|| to_char(p_errorcnt));
	   hr_utility.trace('Validation Error - returning to Update');

           raise common_exception;

	end if;

--
        lv_trans_type   := 'ONLINE_TAX_FORMS';
        lv_source_name  := 'ONLINE W4 FORM';

-- at this point we try to insert record and if sucessful then rollback the record
-- if not then we will get en error. We pass in the validate_flag as TRUE so we
-- will not commit any data in the table now.

        update_tax_records(p_filing_status_code     => p_filing_status_code,
                           p_org_filing_status_code => p_original_fs,
                           p_allowances             => l_allowances,
                           p_org_allowances         => p_original_wa,
                           p_additional_amount      => l_additional_tax,
			   p_last_name_diff         => l_last_name_diff_flag,
                           p_exempt_status_code     => substr(l_exempt_status_code,1,1),
                           p_org_exempt_status_code => substr(p_original_exempt,1,1),
                           p_transaction_id         => null,
                           p_person_id              => ln_person_id,
                           p_transaction_type       => lv_trans_type,
                           p_source_name            => lv_source_name,
                           --p_update_method          => lv_update_method,
                           p_validate               => TRUE );

	   hr_utility.trace('The global state list is : '|| g_state_list);
	   hr_utility.trace('The global state exempt list is : '|| g_state_exempt_list);

	   -- Forming Proper Message Text

	   IF g_nonmatch_cntr > 0 then

		hr_utility.trace('The global Not Matching list is : '|| g_not_matching_state_list);
	        hr_utility.trace('Final g_nonmatch_cntr := ' || g_nonmatch_cntr);

	      ln_prev_comma_position := 0;
	      FOR i IN 1..g_nonmatch_cntr
	      LOOP
	          ln_comma_position := INSTR(g_not_matching_state_list, ',', 1, i);
		  hr_utility.trace('i := ' || i);
		  hr_utility.trace('ln_comma_position := ' || ln_comma_position);

		  IF ln_comma_position = 0 THEN
		     ln_comma_position := LENGTH(g_not_matching_state_list) + 1;
		  END IF;
		  hr_utility.trace('ln_comma_position := ' || ln_comma_position);
		  hr_utility.trace('ln_prev_comma_position := ' || ln_prev_comma_position);

		  lv_notmatch_state := LTRIM(RTRIM(SUBSTR(g_not_matching_state_list, (ln_prev_comma_position + 1), (ln_comma_position - ln_prev_comma_position - 1))));
		  hr_utility.trace('lv_notmatch_state := ' || lv_notmatch_state);

		  IF INSTR(g_state_list, lv_notmatch_state) <> 0 THEN
                     IF INSTR(g_state_list, lv_notmatch_state || ',') <> 0 THEN
		        g_state_list := REPLACE(g_state_list, lv_notmatch_state || ',');
		     ELSE
		        g_state_list := REPLACE(g_state_list, lv_notmatch_state );
		     END IF;
		  END IF;
		  IF INSTR(g_state_exempt_list, lv_notmatch_state) <> 0 THEN
                     IF INSTR(g_state_exempt_list, lv_notmatch_state || ',') <> 0 THEN
		        g_state_exempt_list := REPLACE(g_state_exempt_list, lv_notmatch_state || ',');
		     ELSE
		        g_state_exempt_list := REPLACE(g_state_exempt_list, lv_notmatch_state );
		     END IF;
		  END IF;
		  hr_utility.trace('Success ' || i);
		  ln_prev_comma_position := ln_comma_position;
		END LOOP;
                g_not_matching_state_list := hr_util_misc_web.return_msg_text('PAY_US_OTF_NOTMATCHING_STATES','PAY')
					   || g_not_matching_state_list;

	     END IF;

	   IF g_state_list IS NOT NULL THEN
	      g_state_list := g_state_list || g_not_matching_state_list;
	   END IF;
	   IF g_state_exempt_list IS NOT NULL THEN
	      g_state_exempt_list := g_state_exempt_list || g_not_matching_state_list;
	   END IF;
	   IF (g_state_list IS NULL
              AND g_state_exempt_list IS NULL
              AND g_not_matching_state_list IS NOT NULL) THEN
		g_state_list := g_not_matching_state_list;
	   END IF;

           p_state_list := g_state_list;

           if substr(l_exempt_status_code,1,1) <> substr(p_original_exempt,1,1) and
              p_filing_status_code = p_original_fs and
              l_allowances = p_original_wa then

              p_exempt_state_list := null;
           else
              p_exempt_state_list := g_state_exempt_list;
           end if;

           hr_utility.trace('The global state list is : '|| g_state_list);
           hr_utility.trace('The global state exempt list is : '|| g_state_exempt_list);


/* If we have come so far that means we have no errors. So insert data
   into hr_api_transactions, hr_api_transaction_steps and hr_api_transaction_values.
   Need to insert data into these tables to store OLD and NEW values for W4. These
   OLD and NEW values are used in the review page. */

-- First the hr_api_transactions table

    l_transaction_id :=  hr_transaction_ss.get_transaction_id(p_itemtype, p_itemkey);

 if l_transaction_id is null then /* transaction does not exists */

    hr_utility.trace('l_transaction_id is null INSERTING');

/*
    hr_transaction_api.create_transaction( p_creator_person_id => ln_person_id ,
                                           p_transaction_privilege => 'PRIVATE',
                                           p_transaction_id => l_transaction_id);
*/
       If p_itemtype is not null and p_itemkey is not null then

          OPEN get_function_info(p_item_type => p_itemtype,
                                 p_item_key => p_itemkey);

          FETCH get_function_info into l_function_id, l_function_name;
             IF(get_function_info%notfound) then
                CLOSE get_function_info;
             END if;
             close get_function_info;
       end if; /* item_type  , Item key */

       If p_itemtype is not null and p_itemkey is not null then
          lv_transaction_type := 'WF';
       else
          lv_transaction_type := 'NWF';
       end if;

       lv_process_name := wf_engine.GetItemAttrText(p_itemtype
                                                   ,p_itemkey
                                                   ,'PROCESS_NAME');

/* create transaction */

       hr_transaction_api.create_transaction(
                    p_creator_person_id      => ln_person_id
                   ,p_transaction_privilege  => 'PRIVATE'
                   ,p_transaction_id         => l_transaction_id
                   ,p_function_id            =>l_function_id
                   ,p_transaction_ref_table  => 'HR_API_TRANSACTIONS'
                   ,p_transaction_type       =>lv_transaction_type
                   ,p_selected_person_id     =>ln_person_id
                   ,p_item_type              =>p_itemtype
                   ,p_item_key               =>p_itemkey
                   ,p_transaction_effective_date=>sysdate
                   ,p_process_name           =>lv_process_name
                    );

-- hr_api_transaction_steps

       hr_transaction_api.create_transaction_step(
                           p_creator_person_id     => ln_person_id,
                           p_transaction_id        => l_transaction_id,
                           p_api_name              => gv_package_name||'.update_w4_info',
                           p_item_type             => p_itemtype,
                           p_item_key              => p_itemkey,
                           p_activity_id           => p_activity_id,
                           p_transaction_step_id   => l_transaction_step_id,
                           p_object_version_number => l_step_obj_version_number);

-- set the transaction_id attribute value in the workflow.
        wf_engine.setitemattrtext ( itemtype  => p_itemtype,
                                    itemkey   => p_itemkey,
                                    aname     => 'TRANSACTION_ID',
                                    avalue    => l_transaction_id);

 else /* transaction exists */

     hr_utility.trace('l_transaction_id : '|| l_transaction_id);
     select transaction_step_id into l_transaction_step_id
     from HR_API_TRANSACTION_STEPS
     where transaction_id = l_transaction_id;

 end if;

-- hr_api_transaction_values

-- Filing Status Meaning
-- get the filing status meaning to store in the transaction_value table

    hr_utility.trace('After END IF');

   select fcl.meaning Meaning into transaction_value_fs
   from fnd_common_lookups fcl
   where fcl.lookup_type = 'US_FIT_FILING_STATUS'
     and fcl.lookup_code = p_filing_status_code ;

   hr_transaction_api.set_varchar2_value (
                        p_transaction_step_id  => l_transaction_step_id
                       ,p_person_id            => ln_person_id
                       ,p_name                 => 'P_FILING_STATUS'
                       ,p_value                => transaction_value_fs ) ;

-- Filing Status Code
   hr_transaction_api.set_varchar2_value (
                        p_transaction_step_id        => l_transaction_step_id
                       ,p_person_id                  => ln_person_id
                       ,p_name                       => 'P_FS_CODE'
                       ,p_value                      => p_filing_status_code ) ;

-- Original Filing Status Code
   hr_transaction_api.set_varchar2_value (
                        p_transaction_step_id        => l_transaction_step_id
                       ,p_person_id                  => ln_person_id
                       ,p_name                       => 'P_ORG_FS_CODE'
                       ,p_value                      => p_original_fs ) ;

   select fcl.meaning Meaning into transaction_value_fs
   from fnd_common_lookups fcl
   where fcl.lookup_type = 'US_FIT_FILING_STATUS'
     and fcl.lookup_code = p_original_fs ;
   hr_utility.trace('transaction_step_id = ' || l_transaction_step_id);
   hr_transaction_api.set_varchar2_value (
                        p_transaction_step_id  => l_transaction_step_id
                       ,p_person_id            => ln_person_id
                       ,p_name                 => 'P_ORG_FILING_STATUS'
                       ,p_value                => transaction_value_fs ) ;

-- Allowances
   hr_transaction_api.set_number_value (
                        p_transaction_step_id        => l_transaction_step_id
                       ,p_person_id                  => ln_person_id
                       ,p_name                       => 'P_ALLOWANCES'
                       ,p_value                      => l_allowances ) ;

-- Original Allowances
   hr_transaction_api.set_number_value (
                        p_transaction_step_id        => l_transaction_step_id
                       ,p_person_id                  => ln_person_id
                       ,p_name                       => 'P_ORG_ALLOWANCES'
                       ,p_value                      => p_original_wa ) ;

-- Additional Tax
   hr_transaction_api.set_number_value (
                        p_transaction_step_id        => l_transaction_step_id
                       ,p_person_id                  => ln_person_id
                       ,p_name                       => 'P_ADDITIONAL_TAX'
                       ,p_value                      => ln_add_tax);

-- Original Additional Tax
   hr_transaction_api.set_number_value (
                        p_transaction_step_id        => l_transaction_step_id
                       ,p_person_id                  => ln_person_id
                       ,p_name                       => 'P_ORG_ADDITIONAL_TAX'
                       ,p_value                      => p_original_aa);


-- Exempt
   hr_transaction_api.set_varchar2_value (
                        p_transaction_step_id        => l_transaction_step_id
                       ,p_person_id                  => ln_person_id
                       ,p_name                       => 'P_EXEMPT'
                       ,p_value                      => l_exempt_status_code ) ;

-- Original Exempt
   hr_transaction_api.set_varchar2_value (
                        p_transaction_step_id        => l_transaction_step_id
                       ,p_person_id                  => ln_person_id
                       ,p_name                       => 'P_ORG_EXEMPT'
                       ,p_value                      => p_original_exempt ) ;

-- P_REVIEW_PROC_CALL
   l_review_region :=     WF_ENGINE.GetActivityAttrText( itemtype  => p_itemtype,
                                                         itemkey   => p_itemkey,
                                                         actid     => p_activity_id,
                                                         aname     => 'HR_REVIEW_REGION_ITEM');


   hr_transaction_api.set_varchar2_value (
                        p_transaction_step_id        => l_transaction_step_id
                       ,p_person_id                  => ln_person_id
                       ,p_name                       => 'P_REVIEW_PROC_CALL'
                       ,p_value                      => l_review_region ) ;

-- P_REVIEW_ACTID
   hr_transaction_api.set_varchar2_value (
                        p_transaction_step_id        => l_transaction_step_id
                       ,p_person_id                  => ln_person_id
                       ,p_name                       => 'P_REVIEW_ACTID'
                       ,p_value                      => p_activity_id ) ;

-- P_LAST_NAME_DIFF
   hr_transaction_api.set_varchar2_value (
                        p_transaction_step_id        => l_transaction_step_id
                       ,p_person_id                  => ln_person_id
                       ,p_name                       => 'P_LAST_NAME_DIFF'
                       ,p_value                      => l_last_name_diff_flag ) ;

   hr_utility.trace('B4 Commit');
   commit;

	hr_utility.trace('Leaving ' || gv_package_name || '.validate_submission');

  EXCEPTION

        When common_exception then
              hr_utility.trace('In exception common_exception');
              return;

        When no_data_found then
              hr_utility.trace('In exception no_data_found');
              return;


	WHEN OTHERS THEN
           hr_utility.trace(gv_package_name || '.validate_submission FATAL ERROR');
	   hr_utility.trace(SQLERRM || ' ' || SQLCODE);

	   l_error := l_error ||';'||'PAY-'||gv_package_name || '.validate_submission'||
				     SQLERRM || ' ' ||SQLCODE||'-Dummy';

           return;


  END validate_submission;

/*************************************************************************************

 ** get_transaction_values procedure gets the transaction_values from
 ** hr_transaction_values.
 ** This procedure accepts transaction_id, transaction_step_id as IN variables.
 ** First check is made to see if Transaction Id is not null, if not null then get
 ** step id and fetch values else check for step id and fetch values on step id.
 **
 ** this we use it in the review page to show the old and the new value. We get the
 ** values by passing the transaction_step_id. The output is concatenated and passed
 ** out as a string.
 ************************************************************************************/

PROCEDURE get_transaction_values(
             p_trans_id    IN   VARCHAR2 Default null,
             p_step_id     IN   VARCHAR2 Default null,
             p_out_values  OUT nocopy VARCHAR2 )  IS

l_step_id        hr_api_transaction_steps.transaction_step_id%type;

CURSOR c_trans_values IS

       select v.datatype,v.name,v.varchar2_value,number_value
       from hr_api_transaction_values v
       where v.transaction_step_id = l_step_id
       order by transaction_value_id;

l_datatype       hr_api_transaction_values.datatype%type;
l_name           hr_api_transaction_values.name%type;
l_varchar2_value hr_api_transaction_values.varchar2_value%type;
l_number_value   hr_api_transaction_values.number_value%type;

common_exception EXCEPTION;
BEGIN

      hr_utility.trace('Transaction Id is : '|| p_trans_id);
      hr_utility.trace('Transaction Step Id is : '|| p_step_id);

      if (p_trans_id is null and p_step_id is null) then
         p_out_values := 'Error: Please enter Transaction Id or Transaction Step Id';
         raise common_exception;
      end if;

      if (p_trans_id is not null and p_step_id is null) then

         select transaction_step_id  into l_step_id
         from hr_api_transaction_steps
         where transaction_id = to_number(p_trans_id);

      else
         l_step_id := to_number(p_step_id);

      end if;

         open c_trans_values;
         loop
         exit when c_trans_values%NOTFOUND;
          fetch c_trans_values into l_datatype,l_name,l_varchar2_value,l_number_value;

             if l_datatype = 'VARCHAR2' and l_name = 'P_FILING_STATUS' then
                  p_out_values := l_varchar2_value;
             elsif l_datatype = 'VARCHAR2' and l_name = 'P_FS_CODE' then
                  p_out_values := p_out_values||';'||l_varchar2_value;
             elsif l_datatype = 'NUMBER' and l_name = 'P_ALLOWANCES' then
                  p_out_values := p_out_values||';'||l_number_value;
             elsif l_datatype = 'NUMBER' and l_name = 'P_ADDITIONAL_TAX' then
                  p_out_values := p_out_values||';'||l_number_value;
             elsif l_datatype = 'VARCHAR2' and l_name = 'P_EXEMPT' then
                  p_out_values := p_out_values||';'||l_varchar2_value;
             end if;

         end loop;
         close c_trans_values;

      hr_utility.trace('The out value is : '|| p_out_values);

exception when common_exception then

      hr_utility.trace('Error: Please enter Transaction Id or Transaction Step Id');
         return;


END;


PROCEDURE update_alien_tax_records(
		p_filing_status_code 	pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE
	       ,p_allowances 	  	pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE
	       ,p_additional_amount	pay_us_emp_fed_tax_rules_f.fit_additional_tax%TYPE
	       ,p_exempt_status_code	pay_us_emp_fed_tax_rules_f.fit_exempt%TYPE
	       ,p_process		VARCHAR2
	       ,p_itemtype		VARCHAR2
               ,p_person_id             per_people_f.person_id%TYPE default null
               ,p_effective_date        date      default null
               ,p_source_name           VARCHAR2  default null
			    )
  /******************************************************************
  **
  ** Description: OTF Fed W4 update procedure
  **     1. locks all applicable rows
  **     2. update each fed row using fed api
  **	 3. update each state row using state api
  **     4. archive the submission
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/
  IS
	ln_person_id 			per_people_f.person_id%TYPE;
	ln_business_group_id		per_people_f.business_group_id%TYPE;
	ln_parent_audit_id		pay_stat_trans_audit.stat_trans_audit_id%TYPE;
	ln_assignment_id		per_assignments_f.assignment_id%TYPE;
	ln_gre_id			hr_organization_units.organization_id%TYPE;
	ln_fed_tax_rule_id		pay_us_emp_fed_tax_rules_f.emp_fed_tax_rule_id%TYPE;
	ln_state_tax_rule_id		pay_us_emp_state_tax_rules_f.emp_state_tax_rule_id%TYPE;
	ld_old_start_date		pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
	ld_start_date			pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
	ld_end_date			pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
	lv_org_filing_status_code	pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE;
	lv_filing_status_code		pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE;
	lv_additional_tax	pay_us_emp_fed_tax_rules_f.fit_additional_tax%TYPE;
	lv_org_allowances		pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE;
	lv_allowances		pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE;
	lv_org_exempt_status_code	pay_us_emp_fed_tax_rules_f.fit_exempt%TYPE;
	lv_exempt_status_code	pay_us_emp_fed_tax_rules_f.fit_exempt%TYPE;
        lv_last_name_diff_flag   VARCHAR2(1);
	lv_state_name			pay_us_states.state_name%TYPE;
	lv_state_code			pay_us_states.state_code%TYPE;
	lv_state_default_code		VARCHAR2(30);
	lv_context			pay_stat_trans_audit.audit_information_category%TYPE;
	ln_dummy			NUMBER(15);
	lb_comma_flag			boolean := false;
	lv_datetrack_mode		VARCHAR2(30);
	lv_update_method		VARCHAR2(30);
	l_primary_only			VARCHAR2(1);
	lv_state_list			VARCHAR2(1000);
	lv_update_error_msg		VARCHAR2(10000);
	e_no_records			EXCEPTION;
	e_no_update_allowed		EXCEPTION;
	e_date_error			EXCEPTION;
--
        ld_effective_date               date;
        lv_trans_type                   VARCHAR2(50);
        lv_source_name                  VARCHAR2(50);
--
   BEGIN

        lv_filing_status_code := p_filing_status_code;
        lv_org_filing_status_code := NULL;
        ln_person_id := p_person_id;
        lv_allowances := p_allowances;
        lv_org_allowances := NULL;
        lv_additional_tax := p_additional_amount;
        lv_last_name_diff_flag := 'Y';
        lv_exempt_status_code     := p_exempt_status_code;
        lv_org_exempt_status_code := NULL;

	-- set a savepoint before we do anything
	SAVEPOINT update_alien_tax_records;

-- jatin
        if p_source_name = 'PQP_US_ALIEN_WINDSTAR' then

           ln_person_id         := p_person_id;
           ln_business_group_id := hr_util_misc_web.get_business_group_id(ln_person_id);
           lv_update_method     := 'PRIMARY';
           ld_effective_date    := trunc(p_effective_date);
           lv_trans_type        := 'US_TAX_FORMS';
           lv_source_name       := p_source_name;

        end if;


        update_tax_records(p_filing_status_code     => p_filing_status_code,
                           p_org_filing_status_code => lv_org_filing_status_code,
                           p_allowances             => lv_allowances,
                           p_org_allowances         => lv_org_allowances,
                           p_additional_amount      => lv_additional_tax,
			   p_last_name_diff         => lv_last_name_diff_flag,
                           p_exempt_status_code     => lv_exempt_status_code,
                           p_org_exempt_status_code => lv_org_exempt_status_code,
                           p_transaction_id         => null,
                           p_person_id              => ln_person_id,
                           p_transaction_type       => lv_trans_type,
                           p_source_name            => lv_source_name,
                           --p_update_method          => lv_update_method,
                           p_validate               => FALSE );

   EXCEPTION
	WHEN OTHERS THEN
		rollback to update_alien_tax_records;

                raise_application_error(-20001,'Fatal Error while commit');

   END update_alien_tax_records;


PROCEDURE update_tax_records(
	     p_filing_status_code       pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE
	    ,p_org_filing_status_code   pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE
	    ,p_allowances 	        pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE
	    ,p_org_allowances 	        pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE
	    ,p_additional_amount        pay_us_emp_fed_tax_rules_f.fit_additional_tax%TYPE
	    ,p_last_name_diff           VARCHAR2 DEFAULT 'N'
            ,p_exempt_status_code       pay_us_emp_fed_tax_rules_f.fit_exempt%TYPE
            ,p_org_exempt_status_code   pay_us_emp_fed_tax_rules_f.fit_exempt%TYPE
	    ,p_transaction_id	        hr_api_transactions.transaction_id%type
            ,p_person_id                VARCHAR2
            ,p_transaction_type         VARCHAR2
            ,p_source_name              VARCHAR2
            --,p_update_method            VARCHAR2
            ,p_validate                 boolean default false
			    )
  /******************************************************************
  **
  ** Description: OTF Fed W4 update procedure
  **     1. locks all applicable rows
  **     2. update each fed row using fed api
  **	 3. update each state row using state api
  **     4. archive the submission
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/
  IS
	ln_person_id 			per_people_f.person_id%TYPE;
	ln_business_group_id		per_people_f.business_group_id%TYPE;
	ln_parent_audit_id		pay_stat_trans_audit.stat_trans_audit_id%TYPE;
	ln_assignment_id		per_assignments_f.assignment_id%TYPE;
	ln_gre_id			hr_organization_units.organization_id%TYPE;
	ln_fed_tax_rule_id		pay_us_emp_fed_tax_rules_f.emp_fed_tax_rule_id%TYPE;
	ln_state_tax_rule_id		pay_us_emp_state_tax_rules_f.emp_state_tax_rule_id%TYPE;
	ld_old_start_date		pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
	ld_start_date			pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
	ld_end_date			pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
	lv_filing_status_code		pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE;
	lv_state_filing_status_code 	pay_us_emp_state_tax_rules_f.filing_status_code%TYPE;
	cu_state_filing_status_code 	pay_us_emp_state_tax_rules_f.filing_status_code%TYPE;
	cu_state_wa	                pay_us_emp_state_tax_rules_f.withholding_allowances%TYPE;
	cu_sit_exempt	                pay_us_emp_state_tax_rules_f.sit_exempt%TYPE;
	ln_state_addtional_tax	        pay_us_emp_state_tax_rules_f.sit_additional_tax%TYPE;

        cu_sui_wage_base_override_amt   pay_us_emp_state_tax_rules_f.sui_wage_base_override_amount%TYPE;
	lv_state_name			pay_us_states.state_name%TYPE;
	lv_state_code			pay_us_states.state_code%TYPE;
	lv_state_default_code		VARCHAR2(30);
	lv_state_exempt_code		pay_us_state_tax_info_f.sta_information9%TYPE;
	lv_context			pay_stat_trans_audit.audit_information_category%TYPE;
	ln_dummy			NUMBER(15);
	lb_comma_flag			boolean := false;
	lv_datetrack_mode		VARCHAR2(30);
	lv_update_method		VARCHAR2(30) := 'PRIMARY';
	l_exempt_status_code		VARCHAR2(2);
	l_primary_only			VARCHAR2(1);
	lv_state_list			VARCHAR2(1000);
	lv_update_error_msg		VARCHAR2(10000);
	e_no_records			EXCEPTION;
	e_no_update_allowed		EXCEPTION;
	e_date_error			EXCEPTION;
        l_primary_flag                  per_assignments_f.primary_flag%TYPE;

        l_state_exempt                  varchar2(15);

        lv_filing_status_changed       boolean := false;
        lv_state_fs_changed            boolean := false;
        lv_allowance_changed           boolean := false;
        lv_exempt_changed              boolean := false;
        lv_insert_flag                 boolean := false;

        lv_fit_exempt                  NUMBER(15);
	lv_futa_tax_exempt             NUMBER(15);
	lv_medicare_tax_exempt         NUMBER(15);
	lv_ss_tax_exempt               NUMBER(15);

	lv_sit_exempt                  NUMBER(15);
	lv_sui_exempt                  NUMBER(15);
	lv_sdi_exempt                  NUMBER(15);
	lv_wc_exempt                   NUMBER(15);

	lv_fed_exemptions_count        NUMBER(15);
	lv_state_exemptions_count      NUMBER(15);
        lv_trans_type                   VARCHAR2(50);
        lv_source_name                  VARCHAR2(50);
	lv_filing_status_code_o        pay_us_emp_state_tax_rules_f.filing_status_code%TYPE;

/*
	CURSOR c_fed_tax_rows IS
		select	ftr.emp_fed_tax_rule_id,
                        ftr.filing_status_code,
                        ftr.withholding_allowances,
      			ftr.object_version_number,
			ftr.effective_start_date,
			paf.assignment_id,
			hsck.segment1,
                        paf.primary_flag,
			decode(ftr.fit_exempt,'Y',1,0),
			decode(ftr.futa_tax_exempt,'Y',1,0),
			decode(ftr.medicare_tax_exempt,'Y',1,0),
			decode(ftr.ss_tax_exempt,'Y',1,0)
    		from	pay_us_emp_fed_tax_rules_f ftr, per_assignments_f paf,
			hr_soft_coding_keyflex hsck
    		where	paf.person_id = ln_person_id
		  and	paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
		  and 	paf.assignment_id = ftr.assignment_id
		  and	paf.assignment_type = 'E'
		  and   decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
		  and 	trunc(sysdate) between paf.effective_start_date and
                                               paf.effective_end_date
    		  and	trunc(sysdate) between ftr.effective_start_date and
                                               ftr.effective_end_date
                order by paf.assignment_id
    		for update nowait;
*/

	CURSOR c_fed_tax_rows IS
	       select ftr.*,
		      hsck.segment1 gre_id,
                      paf.primary_flag primary_flag,
                      trunc(sysdate) cur_sysdate,
		      decode(ftr.fit_exempt,'Y',1,0) fit_exempt_count,
		      decode(ftr.futa_tax_exempt,'Y',1,0) futa_tax_exempt_count,
		      decode(ftr.medicare_tax_exempt,'Y',1,0) medicare_tax_exempt_count,
		      decode(ftr.ss_tax_exempt,'Y',1,0) ss_tax_exempt_count
    		from  pay_us_emp_fed_tax_rules_f ftr
                     ,per_assignments_f paf
                     ,hr_soft_coding_keyflex hsck
    	       where  paf.person_id = ln_person_id
		 and  paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
		 and  paf.assignment_id = ftr.assignment_id
		 and  paf.assignment_type = 'E'
		 and  decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
		 and  trunc(sysdate) between paf.effective_start_date and
                                             paf.effective_end_date
    		 and  trunc(sysdate) between ftr.effective_start_date and
                                             ftr.effective_end_date
               order by paf.assignment_id
    		 for update nowait;

l_fed_tax_rec   c_fed_tax_rows%rowtype;

/*
	CURSOR c_state_tax_rows(curvar_assignment_id per_assignments_f.assignment_id%TYPE) IS
		select	str.emp_state_tax_rule_id,
      			str.object_version_number,
			str.effective_start_date,
                        str.filing_status_code,
                        str.withholding_allowances,
                        str.sit_additional_tax,
			pus.state_name,
			pus.state_code,
			paf.assignment_id,
			stif.sta_information7,
			hsck.segment1
                       ,str.sit_exempt
                       ,nvl(stif.sta_information9,'N')  -- does the exempt status default from federal
                       ,str.sui_wage_base_override_amount
		       ,decode(str.sit_exempt,'Y',1,0)
		       ,decode(str.sui_exempt,'Y',1,0)
		       ,decode(str.sdi_exempt,'Y',1,0)
		       ,decode(str.wc_exempt,'Y',1,0)
    		from	pay_us_emp_state_tax_rules_f str, per_assignments_f paf,
			pay_us_state_tax_info_f stif, pay_us_states pus,
			hr_soft_coding_keyflex hsck
    		where	paf.person_id = ln_person_id
                  and   paf.assignment_id = curvar_assignment_id
		  and 	paf.assignment_id = str.assignment_id
		  and	paf.assignment_type = 'E'
		  and	paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
		  and 	decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
		  and	str.state_code = stif.state_code
		  and 	str.state_code = pus.state_code
		  and	stif.sta_information7 like 'Y%'
		  and 	trunc(sysdate) between stif.effective_start_date and
                                               stif.effective_end_date
		  and 	trunc(sysdate) between paf.effective_start_date and
                                               paf.effective_end_date
    		  and	trunc(sysdate) between str.effective_start_date and
                                               str.effective_end_date
    		for update nowait;
*/

	CURSOR c_state_tax_rows(curvar_assignment_id per_assignments_f.assignment_id%TYPE) IS
       	 select  str.*
		,pus.state_name
		,stif.sta_information7 state_as_fed
		,hsck.segment1 gre_id
		/* Bug# 6346579 : Changing the default value to 'Y' */
                --,nvl(stif.sta_information9,'N') exmpt_status_state_as_fed  -- does the exempt status default from federal
		,nvl(stif.sta_information9,'Y') exmpt_status_state_as_fed  -- does the exempt status default from federal
                ,trunc(sysdate) cur_sysdate
                ,decode(str.sit_exempt,'Y',1,0) sit_exempt_count
		,decode(str.sui_exempt,'Y',1,0) sui_exempt_count
		,decode(str.sdi_exempt,'Y',1,0) sdi_exempt_count
		,decode(str.wc_exempt,'Y',1,0)  wc_exempt_count
    	from    pay_us_emp_state_tax_rules_f str, per_assignments_f paf,
		pay_us_state_tax_info_f stif, pay_us_states pus,
		hr_soft_coding_keyflex hsck
    	where	paf.person_id = ln_person_id
          and   paf.assignment_id = curvar_assignment_id
	  and 	paf.assignment_id = str.assignment_id
	  and	paf.assignment_type = 'E'
	  and	paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
	  and 	decode(l_primary_only,'Y',paf.primary_flag,'Y') = 'Y'
	  and	str.state_code = stif.state_code
	  and 	str.state_code = pus.state_code
	  and	stif.sta_information7 like 'Y%'
	  and 	trunc(sysdate) between stif.effective_start_date and
                                       stif.effective_end_date
	  and 	trunc(sysdate) between paf.effective_start_date and
                                       paf.effective_end_date
    	  and	trunc(sysdate) between str.effective_start_date and
                                       str.effective_end_date
    	for update nowait;

l_state_tax_rec   c_state_tax_rows%rowtype;

  BEGIN

	hr_utility.trace('Entering ' || gv_package_name || '.update_tax_records');

	-- set a savepoint before we do anything
	SAVEPOINT update_tax_records;

        -- get transaction type and source name
        lv_trans_type := p_transaction_type;
        lv_source_name := p_source_name;

	-- validate session and get person id

        ln_person_id := p_person_id;
	ln_business_group_id := hr_util_misc_web.get_business_group_id(ln_person_id);

	-- get the update method
        if lv_source_name = 'PQP_US_ALIEN_WINDSTAR' then
           lv_update_method :=  'PRIMARY';
        else
           lv_update_method := fnd_profile.value('HR_OTF_UPDATE_METHOD');
        end if;

        if lv_update_method = 'PRIMARY' then
           l_primary_only := 'Y';

        elsif lv_update_method = 'ALL' then
           l_primary_only := 'N';

        else -- update_method = NONE or null
             -- we always default the value to primary
           l_primary_only := 'Y';

        end if;

	lv_fed_exemptions_count := 0;
	lv_state_exemptions_count := 0;

	hr_utility.trace('Update Method = ' || lv_update_method);

	lv_filing_status_code := p_filing_status_code;

	-- lock records
	hr_utility.trace(gv_package_name||'.update_tax_records - Locking Employee Tax Records');
	open c_fed_tax_rows;

        loop      /* Federal cursor loop */

	-- start by updating the fed tax records

       /*
	    FETCH c_fed_tax_rows INTO ln_fed_tax_rule_id,cu_fed_filing_status_code,
                                  cu_fed_withholding_allowances,
                                  ln_ovn,ld_old_start_date, ln_assignment_id,
                                  ln_gre_id,l_primary_flag,
				  lv_fit_exempt, lv_futa_tax_exempt,
				  lv_medicare_tax_exempt, lv_ss_tax_exempt;
       */
            l_fed_tax_rec := null;

            FETCH c_fed_tax_rows INTO l_fed_tax_rec;

	    exit when  c_fed_tax_rows%NOTFOUND;

            -- count the no. of Federal Tax Exemptions
	    lv_fed_exemptions_count := l_fed_tax_rec.fit_exempt_count
	                             + l_fed_tax_rec.futa_tax_exempt_count
				     + l_fed_tax_rec.medicare_tax_exempt_count
				     + l_fed_tax_rec.ss_tax_exempt_count ;

	    hr_utility.trace(gv_package_name ||'.update_tax_records - BEFORE FED UPDATE');

	    -- We insert using datetrack mode of UPDATE
	    -- future dated records will cause an error
	    -- if the old start date = sysdate, we perform a correction instead

	    --if ld_old_start_date = trunc(sysdate) then
	    if l_fed_tax_rec.effective_start_date = trunc(sysdate) then
		lv_datetrack_mode := 'CORRECTION';
	    else
		lv_datetrack_mode := 'UPDATE';
	    end if;

	    hr_utility.trace('Updating Fed Record ID = ' || to_char(ln_fed_tax_rule_id));

/*
	    pay_federal_tax_rule_api.update_fed_tax_rule
				(p_emp_fed_tax_rule_id 	  => ln_fed_tax_rule_id
				,p_withholding_allowances => p_allowances
				,p_fit_additional_tax	  => p_additional_amount
				,p_filing_status_code	  => lv_filing_status_code
				,p_fit_exempt		  => p_exempt_status_code
				,p_object_version_number  => ln_ovn
				,p_effective_start_date   => ld_start_date
				,p_effective_end_date	  => ld_end_date
				,p_effective_date	  => trunc(sysdate)
				,p_datetrack_update_mode  => lv_datetrack_mode
                                ,p_validate               => p_validate
				);

*/
   -- Calling api for all parameters.

 pay_federal_tax_rule_api.update_fed_tax_rule(
                 p_validate                  =>p_validate
                ,p_effective_date            =>l_fed_tax_rec.cur_sysdate
                ,p_datetrack_update_mode     =>lv_datetrack_mode
                ,p_emp_fed_tax_rule_id       =>l_fed_tax_rec.emp_fed_tax_rule_id
                ,p_object_version_number     =>l_fed_tax_rec.object_version_number
                ,p_sui_state_code            =>l_fed_tax_rec.sui_state_code
                ,p_additional_wa_amount      =>l_fed_tax_rec.additional_wa_amount
                ,p_filing_status_code        =>lv_filing_status_code
                ,p_fit_override_amount       =>l_fed_tax_rec.fit_override_amount
                ,p_fit_override_rate         =>l_fed_tax_rec.fit_override_rate
                ,p_withholding_allowances    =>p_allowances
                ,p_cumulative_taxation       =>l_fed_tax_rec.cumulative_taxation
                ,p_eic_filing_status_code    =>l_fed_tax_rec.eic_filing_status_code
                ,p_fit_additional_tax        =>p_additional_amount
                ,p_fit_exempt                =>p_exempt_status_code
                ,p_futa_tax_exempt           =>l_fed_tax_rec.futa_tax_exempt
                ,p_medicare_tax_exempt       =>l_fed_tax_rec.medicare_tax_exempt
                ,p_ss_tax_exempt             =>l_fed_tax_rec.ss_tax_exempt
                ,p_statutory_employee        =>l_fed_tax_rec.statutory_employee
                ,p_w2_filed_year             =>l_fed_tax_rec.w2_filed_year
                ,p_supp_tax_override_rate    =>l_fed_tax_rec.supp_tax_override_rate
                ,p_excessive_wa_reject_date  =>l_fed_tax_rec.excessive_wa_reject_date
                ,p_attribute_category        =>l_fed_tax_rec.attribute_category
                ,p_attribute1                =>l_fed_tax_rec.attribute1
                ,p_attribute2                =>l_fed_tax_rec.attribute2
                ,p_attribute3                =>l_fed_tax_rec.attribute3
                ,p_attribute4                =>l_fed_tax_rec.attribute4
                ,p_attribute5                =>l_fed_tax_rec.attribute5
                ,p_attribute6                =>l_fed_tax_rec.attribute6
                ,p_attribute7                =>l_fed_tax_rec.attribute7
                ,p_attribute8                =>l_fed_tax_rec.attribute8
                ,p_attribute9                =>l_fed_tax_rec.attribute9
                ,p_attribute10               =>l_fed_tax_rec.attribute10
                ,p_attribute11               =>l_fed_tax_rec.attribute11
                ,p_attribute12               =>l_fed_tax_rec.attribute12
                ,p_attribute13               =>l_fed_tax_rec.attribute13
                ,p_attribute14               =>l_fed_tax_rec.attribute14
                ,p_attribute15               =>l_fed_tax_rec.attribute15
                ,p_attribute16               =>l_fed_tax_rec.attribute16
                ,p_attribute17               =>l_fed_tax_rec.attribute17
                ,p_attribute18               =>l_fed_tax_rec.attribute18
                ,p_attribute19               =>l_fed_tax_rec.attribute19
                ,p_attribute20               =>l_fed_tax_rec.attribute20
                ,p_attribute21               =>l_fed_tax_rec.attribute21
                ,p_attribute22               =>l_fed_tax_rec.attribute22
                ,p_attribute23               =>l_fed_tax_rec.attribute23
                ,p_attribute24               =>l_fed_tax_rec.attribute24
                ,p_attribute25               =>l_fed_tax_rec.attribute25
                ,p_attribute26               =>l_fed_tax_rec.attribute26
                ,p_attribute27               =>l_fed_tax_rec.attribute27
                ,p_attribute28               =>l_fed_tax_rec.attribute28
                ,p_attribute29               =>l_fed_tax_rec.attribute29
                ,p_attribute30               =>l_fed_tax_rec.attribute30
                ,p_fed_information_category  =>l_fed_tax_rec.fed_information_category
                ,p_fed_information1          =>l_fed_tax_rec.fed_information1
                ,p_fed_information2          =>l_fed_tax_rec.fed_information2
                ,p_fed_information3          =>l_fed_tax_rec.fed_information3
                ,p_fed_information4          =>l_fed_tax_rec.fed_information4
                ,p_fed_information5          =>l_fed_tax_rec.fed_information5
                ,p_fed_information6          =>l_fed_tax_rec.fed_information6
                ,p_fed_information7          =>l_fed_tax_rec.fed_information7
                ,p_fed_information8          =>l_fed_tax_rec.fed_information8
                ,p_fed_information9          =>l_fed_tax_rec.fed_information9
                ,p_fed_information10         =>l_fed_tax_rec.fed_information10
                ,p_fed_information11         =>l_fed_tax_rec.fed_information11
                ,p_fed_information12         =>l_fed_tax_rec.fed_information12
                ,p_fed_information13         =>l_fed_tax_rec.fed_information13
                ,p_fed_information14         =>l_fed_tax_rec.fed_information14
                ,p_fed_information15         =>l_fed_tax_rec.fed_information15
                ,p_fed_information16         =>l_fed_tax_rec.fed_information16
                ,p_fed_information17         =>l_fed_tax_rec.fed_information17
                ,p_fed_information18         =>l_fed_tax_rec.fed_information18
                ,p_fed_information19         =>l_fed_tax_rec.fed_information19
                ,p_fed_information20         =>l_fed_tax_rec.fed_information20
                ,p_fed_information21         =>l_fed_tax_rec.fed_information21
                ,p_fed_information22         =>l_fed_tax_rec.fed_information22
                ,p_fed_information23         =>l_fed_tax_rec.fed_information23
                ,p_fed_information24         =>l_fed_tax_rec.fed_information24
                ,p_fed_information25         =>l_fed_tax_rec.fed_information25
                ,p_fed_information26         =>l_fed_tax_rec.fed_information26
                ,p_fed_information27         =>l_fed_tax_rec.fed_information27
                ,p_fed_information28         =>l_fed_tax_rec.fed_information28
                ,p_fed_information29         =>l_fed_tax_rec.fed_information29
                ,p_fed_information30         =>l_fed_tax_rec.fed_information30
                ,p_effective_start_date      =>ld_start_date
                ,p_effective_end_date        =>ld_end_date
                );
	    -- we insert a row into the transaction table to show the change
            -- to this assignment


 /* we want to get the transaction id of the primary assignment and update
    that id for all the corresponding transactions hence we need to check
    for the primary flag.  */

        if l_fed_tax_rec.primary_flag = 'Y' then

	       hr_utility.trace('Primary Flag is = ' || l_fed_tax_rec.primary_flag);
             pay_aud_ins.ins(
	  		 p_effective_date => l_fed_tax_rec.cur_sysdate
	  	 	,p_transaction_type => lv_trans_type --'ONLINE_TAX_FORMS'
	  		,p_transaction_date => l_fed_tax_rec.cur_sysdate
	  		,p_transaction_effective_date => l_fed_tax_rec.cur_sysdate
	  		,p_business_group_id => ln_business_group_id
	  		,p_transaction_subtype => 'W4'
  			,p_person_id => ln_person_id
			,p_assignment_id => l_fed_tax_rec.assignment_id
  			,p_source1 => '00-000-0000'
  			,p_source1_type => 'JURISDICTION'
			,p_source2 => fnd_number.number_to_canonical(l_fed_tax_rec.gre_id)
			,p_source2_type => 'GRE'
                        ,p_source3 => lv_source_name --'ONLINE W4 FORM'
                        ,p_source3_type => 'SOURCE_NAME'
                        ,p_source4 => p_transaction_id
                        ,p_source4_type => 'TRANSACTION_ID'
                        ,p_audit_information_category => 'W4 FED'
                        ,p_audit_information1 => lv_filing_status_code
                        ,p_audit_information2 => fnd_number.number_to_canonical(p_allowances)
                        ,p_audit_information3 => fnd_number.number_to_canonical(p_additional_amount)
                        ,p_audit_information4 => p_exempt_status_code
			,p_audit_information5 => p_last_name_diff
			,p_transaction_parent_id => ln_dummy
  			,p_stat_trans_audit_id => ln_parent_audit_id
  			,p_object_version_number => l_fed_tax_rec.object_version_number
  		    );

	       hr_utility.trace('Executed pay_aud_ins.ins ' );
        else /* l_primary_flag */

                     /* reversing ln_dummy and ln_parent_audit_id */

	      hr_utility.trace('Primary Flag is = ' || l_fed_tax_rec.primary_flag);
             pay_aud_ins.ins(
	  		 p_effective_date => l_fed_tax_rec.cur_sysdate
	  	 	,p_transaction_type => lv_trans_type --'ONLINE_TAX_FORMS'
	  		,p_transaction_date => l_fed_tax_rec.cur_sysdate
	  		,p_transaction_effective_date => l_fed_tax_rec.cur_sysdate
	  		,p_business_group_id => ln_business_group_id
	  		,p_transaction_subtype => 'W4'
  			,p_person_id => ln_person_id
			,p_assignment_id => l_fed_tax_rec.assignment_id
  			,p_source1 => '00-000-0000'
  			,p_source1_type => 'JURISDICTION'
			,p_source2 => fnd_number.number_to_canonical(l_fed_tax_rec.gre_id)
			,p_source2_type => 'GRE'
                        ,p_source3 => lv_source_name --'ONLINE W4 FORM'
                        ,p_source3_type => 'SOURCE_NAME'
                        ,p_source4 => p_transaction_id
                        ,p_source4_type => 'TRANSACTION_ID'
                        ,p_audit_information_category => 'W4 FED'
                        ,p_audit_information1 => lv_filing_status_code
                        ,p_audit_information2 => fnd_number.number_to_canonical(p_allowances)
                        ,p_audit_information3 => fnd_number.number_to_canonical(p_additional_amount)
                        ,p_audit_information4 => p_exempt_status_code
			,p_audit_information5 => p_last_name_diff
			,p_transaction_parent_id => ln_parent_audit_id
  			,p_stat_trans_audit_id => ln_dummy
  			,p_object_version_number => l_fed_tax_rec.object_version_number
  	        	);

         end if; /* l_primary_flag */

/* Commenting this for bug 2038691
	    -- as a sanity check we make sure that the dates are right
		if (ld_start_date <> trunc(sysdate)) or
		   (ld_end_date <> to_date('31/12/4712','DD/MM/YYYY')) then
                        hr_utility.trace('ld_start_date is : '|| ld_start_date);
                        hr_utility.trace('trunc(sysdate) is : '|| trunc(sysdate));
                        hr_utility.trace('ld_end_date is : '|| ld_end_date);
                        hr_utility.trace('Date sanity checking');
			raise e_date_error;
		end if;
Commenting this for bug 2038691*/

	-- next we update all state tax records for this assignment id.
	-- we don't update the amount withheld, because it is probably of a different magnitude
	-- then the state taxes.

        -- We will update state record only if the one of the following has changed.

           /* to update state tax Yes or No */

	    hr_utility.trace('p_filing_status_code = ' || p_filing_status_code);
	    hr_utility.trace('p_org_filing_status_code = ' || p_org_filing_status_code);

	    hr_utility.trace('p_allowances = ' || p_allowances);
	    hr_utility.trace('p_org_allowances = ' || p_org_allowances);

	    hr_utility.trace('p_exempt_status_code = ' || p_exempt_status_code);
	    hr_utility.trace('p_org_exempt_status_code = ' || p_org_exempt_status_code);

            if ((p_filing_status_code <> p_org_filing_status_code ) OR
                (p_allowances <> p_org_allowances) OR
                (p_exempt_status_code <> p_org_exempt_status_code) ) then

               hr_utility.trace('*** Updating State Record *** ' );

               if p_filing_status_code <> p_org_filing_status_code then

                  lv_filing_status_changed := TRUE;

               end if;

               if p_allowances <> p_org_allowances then

                  lv_allowance_changed := TRUE;

               end if;

               if p_exempt_status_code <> p_org_exempt_status_code then

                  lv_exempt_changed := TRUE;

               end if;

               open c_state_tax_rows(l_fed_tax_rec.assignment_id);

               loop   /* State tax cursor */

/*
	           FETCH c_state_tax_rows INTO ln_state_tax_rule_id,
                                    ln_ovn,ld_old_start_date,
                                    cu_state_filing_status_code,
                                    cu_state_wa,ln_state_addtional_tax,
                                    lv_state_name, lv_state_code,
                                    ln_assignment_id,
                                    lv_state_default_code, ln_gre_id
                                   ,cu_sit_exempt, lv_state_exempt_code,
                                    cu_sui_wage_base_override_amt,
				    lv_sit_exempt, lv_sui_exempt,
				    lv_sdi_exempt, lv_wc_exempt;
*/
	           FETCH c_state_tax_rows INTO l_state_tax_rec;


                   exit when c_state_tax_rows%NOTFOUND;

                   hr_utility.trace('Fetched state : '|| l_state_tax_rec.state_code );
                   hr_utility.trace(' FS : '|| l_state_tax_rec.filing_status_code ||
                                    ' WA : '|| to_char(l_state_tax_rec.withholding_allowances) );

		   -- count the no. of State Tax Exemptions
             lv_state_exemptions_count := l_state_tax_rec.sit_exempt_count
		                                + l_state_tax_rec.sui_exempt_count
		                                + l_state_tax_rec.sdi_exempt_count
		                                + l_state_tax_rec.wc_exempt_count;

	           hr_utility.trace(gv_package_name||'.update_tax_records-BEFORE STATE UPDATE');

		   if l_state_tax_rec.effective_start_date = l_state_tax_rec.cur_sysdate then
		      lv_datetrack_mode := 'CORRECTION';
		   else
		      lv_datetrack_mode := 'UPDATE';
		   end if;


                   /* Before we update the state tax records, need to check if the
                      filing status and withholding allowances are same at federal
                      and state level, if not then we should not update the state
                      tax records. If this is the first time then we will update
                      the state records also. Bug 1668926.

                      Check fed = state FS and WA */

	           hr_utility.trace('cu_state_fs_code = ' || l_state_tax_rec.filing_status_code);
	           hr_utility.trace('cu_fed_fs_code   = ' || l_fed_tax_rec.filing_status_code);

	           hr_utility.trace('cu_state_wa   = ' || l_state_tax_rec.withholding_allowances);
	           hr_utility.trace('cu_fed_wa     = ' || l_fed_tax_rec.withholding_allowances);

                   hr_utility.trace('lv_fed_exemptions_count = ' || lv_fed_exemptions_count);
		   hr_utility.trace('lv_state_exemptions_count = ' || lv_state_exemptions_count);

		   lv_filing_status_code_o := p_filing_status_code;

                   /*if (l_state_tax_rec.filing_status_code = l_fed_tax_rec.filing_status_code and
                       l_state_tax_rec.withholding_allowances = l_fed_tax_rec.withholding_allowances and
		       lv_fed_exemptions_count = lv_state_exemptions_count) OR
                      (l_state_tax_rec.filing_status_code = '01' and
                       l_fed_tax_rec.filing_status_code = '03' and
                       l_state_tax_rec.withholding_allowances = l_fed_tax_rec.withholding_allowances and
		       lv_fed_exemptions_count = lv_state_exemptions_count) then*/

		   -- Replacing by Function Call
		   IF Fed_State_Filing_Status_Match(l_state_tax_rec.state_code
		                                    ,l_state_tax_rec.filing_status_code
						    ,l_fed_tax_rec.filing_status_code
						    ,l_fed_tax_rec.withholding_allowances
						    ,l_state_tax_rec.withholding_allowances
						    ,lv_fed_exemptions_count
						    ,lv_state_exemptions_count
						    ,lv_filing_status_code_o) THEN

                       if p_validate then
	                  hr_utility.trace('B4 g_state_list = ' || g_state_list);
                          g_state_list := get_state_list(ln_person_id,l_primary_only);
	                  hr_utility.trace('g_state_list = ' || g_state_list);
	                  hr_utility.trace('g_state_exempt_list = ' || g_state_exempt_list);

                       end if;

                      /* allow update of state tax record(s).
                         We pass null as the id because if we passed the
                         id we would need to call some other functions to set
                         up certain globals, etc.  This will be done when the
                         update procedure does its validation, so we take the
                         quick way here. */

                      lv_state_filing_status_code := lv_filing_status_code_o;

		      -- Following Check NO MORE required
		      /*
		      if lv_state_filing_status_code = '03' then

                         lv_state_filing_status_code := '01';
                         -- fed '03' maps to state '01'

                      else
                      */
                        BEGIN

		             pay_sta_bus.chk_filing_status_code(
 				    p_emp_state_tax_rule_id => null
				   ,p_state_code            => l_state_tax_rec.state_code
				   ,p_filing_status_code    => lv_state_filing_status_code
				   ,p_effective_date        => l_state_tax_rec.cur_sysdate
				   ,p_validation_start_date => l_state_tax_rec.cur_sysdate
				   ,p_validation_end_date   => to_date('31/12/4712','DD/MM/YYYY')
							);
                        EXCEPTION WHEN OTHERS THEN
                          -- if the federal filing status is not valid for state then
                          -- do not change the filing status code.
				lv_state_filing_status_code := l_state_tax_rec.filing_status_code;
		        END;

	              -- end if; /* lv_state_filing_status_code = '03' */

                      if lv_state_filing_status_code <> l_state_tax_rec.filing_status_code then

                         lv_state_fs_changed := TRUE;

                      end if;

		     hr_utility.trace('Updating State Record ID = ' || to_char(l_state_tax_rec.emp_state_tax_rule_id));

/* Check the state exempt code here -- If the code Y then default the exempt code from federal
   else do not replace the exempt code */

                     /* We check the state exempt code ie. can we default the federal exempt code to the
                        state */

                     -- Bug # 6333947
                     lv_state_exempt_code := l_state_tax_rec.exmpt_status_state_as_fed;

                     if lv_state_exempt_code = 'Y' then
                        -- we can default the federal code
                        l_state_exempt := p_exempt_status_code;
                     else
                        -- we cannot default
                        l_state_exempt := NVL(l_state_tax_rec.sit_exempt, 'N');
                     end if;

		     hr_utility.trace('*** l_state_exempt = ' || l_state_exempt);
		     hr_utility.trace('*** p_exempt_status_code = ' || p_exempt_status_code);
		     hr_utility.trace('*** cu_sit_exempt = ' || l_state_tax_rec.sit_exempt);


                     --If lv_filing_status_changed or lv_allowance_changed then
                   /*  If lv_state_fs_changed or lv_allowance_changed then

                         lv_insert_flag := TRUE;

                     elsif lv_exempt_changed and lv_state_exempt_code = 'Y' then

                         lv_insert_flag := TRUE;

                     end if;*/


    /* Modified for bug no 7005814 */
                     --If lv_filing_status_changed or lv_allowance_changed then
                     If lv_state_fs_changed  then

                         lv_insert_flag := TRUE;

                     elsif lv_exempt_changed and lv_state_exempt_code = 'Y' then

                         lv_insert_flag := TRUE;
                    elsif  lv_allowance_changed then
                         if (l_state_exempt <> p_exempt_status_code  and p_allowances = 0) then
                            lv_insert_flag := FALSE;
                          else
                            lv_insert_flag := TRUE;
                          end if;
                     end if;
    /* Modified for bug no 7005814 */

                if lv_insert_flag then /* mehul */

                   hr_utility.trace('Update state info : '|| l_state_tax_rec.emp_state_tax_rule_id);
/*
		     pay_state_tax_rule_api.update_state_tax_rule
				(p_emp_state_tax_rule_id  => l_state_tax_rec.emp_state_tax_rule_id
				,p_withholding_allowances => p_allowances
				,p_sit_additional_tax	  => ln_state_addtional_tax
				,p_filing_status_code	  => lv_state_filing_status_code
				--,p_sit_exempt		  => p_exempt_status_code
				,p_sit_exempt		  => l_state_exempt
				,p_object_version_number  => ln_ovn
				,p_effective_start_date   => ld_start_date
				,p_effective_end_date	  => ld_end_date
				,p_effective_date	  => trunc(sysdate)
				,p_datetrack_update_mode  => lv_datetrack_mode
                ,p_validate               => p_validate
                ,p_sui_wage_base_override_amoun => l_state_tax_rec.sui_wage_base_override_amt
				);
*/
pay_state_tax_rule_api.update_state_tax_rule(
              p_validate                       =>p_validate
             ,p_effective_date                 =>l_state_tax_rec.cur_sysdate
             ,p_datetrack_update_mode          =>lv_datetrack_mode
             ,p_emp_state_tax_rule_id          =>l_state_tax_rec.emp_state_tax_rule_id
             ,p_object_version_number          =>l_state_tax_rec.object_version_number
             ,p_additional_wa_amount           =>l_state_tax_rec.additional_wa_amount
             ,p_filing_status_code             =>lv_state_filing_status_code
             ,p_remainder_percent              =>l_state_tax_rec.remainder_percent
             ,p_secondary_wa                   =>l_state_tax_rec.secondary_wa
             ,p_sit_additional_tax             =>p_additional_amount -- l_state_tax_rec.sit_additional_tax
             ,p_sit_override_amount            =>l_state_tax_rec.sit_override_amount
             ,p_sit_override_rate              =>l_state_tax_rec.sit_override_rate
             ,p_withholding_allowances         =>p_allowances
             ,p_excessive_wa_reject_date       =>l_state_tax_rec.excessive_wa_reject_date
             ,p_sdi_exempt                     =>l_state_tax_rec.sdi_exempt
             ,p_sit_exempt                     =>l_state_exempt
             ,p_sit_optional_calc_ind          =>l_state_tax_rec.sit_optional_calc_ind
             ,p_state_non_resident_cert        =>l_state_tax_rec.state_non_resident_cert
             ,p_sui_exempt                     =>l_state_tax_rec.sui_exempt
             ,p_wc_exempt                      =>l_state_tax_rec.wc_exempt
             ,p_sui_wage_base_override_amoun   =>l_state_tax_rec.sui_wage_base_override_amount
             ,p_supp_tax_override_rate         =>l_state_tax_rec.supp_tax_override_rate
             ,p_attribute_category             =>l_state_tax_rec.attribute_category
             ,p_attribute1                     =>l_state_tax_rec.attribute1
             ,p_attribute2                     =>l_state_tax_rec.attribute2
             ,p_attribute3                     =>l_state_tax_rec.attribute3
             ,p_attribute4                     =>l_state_tax_rec.attribute4
             ,p_attribute5                     =>l_state_tax_rec.attribute5
             ,p_attribute6                     =>l_state_tax_rec.attribute6
             ,p_attribute7                     =>l_state_tax_rec.attribute7
             ,p_attribute8                     =>l_state_tax_rec.attribute8
             ,p_attribute9                     =>l_state_tax_rec.attribute9
             ,p_attribute10                    =>l_state_tax_rec.attribute10
             ,p_attribute11                    =>l_state_tax_rec.attribute11
             ,p_attribute12                    =>l_state_tax_rec.attribute12
             ,p_attribute13                    =>l_state_tax_rec.attribute13
             ,p_attribute14                    =>l_state_tax_rec.attribute14
             ,p_attribute15                    =>l_state_tax_rec.attribute15
             ,p_attribute16                    =>l_state_tax_rec.attribute16
             ,p_attribute17                    =>l_state_tax_rec.attribute17
             ,p_attribute18                    =>l_state_tax_rec.attribute18
             ,p_attribute19                    =>l_state_tax_rec.attribute19
             ,p_attribute20                    =>l_state_tax_rec.attribute20
             ,p_attribute21                    =>l_state_tax_rec.attribute21
             ,p_attribute22                    =>l_state_tax_rec.attribute22
             ,p_attribute23                    =>l_state_tax_rec.attribute23
             ,p_attribute24                    =>l_state_tax_rec.attribute24
             ,p_attribute25                    =>l_state_tax_rec.attribute25
             ,p_attribute26                    =>l_state_tax_rec.attribute26
             ,p_attribute27                    =>l_state_tax_rec.attribute27
             ,p_attribute28                    =>l_state_tax_rec.attribute28
             ,p_attribute29                    =>l_state_tax_rec.attribute29
             ,p_attribute30                    =>l_state_tax_rec.attribute30
             ,p_sta_information_category       =>l_state_tax_rec.sta_information_category
             ,p_sta_information1               =>l_state_tax_rec.sta_information1
             ,p_sta_information2               =>l_state_tax_rec.sta_information2
             ,p_sta_information3               =>l_state_tax_rec.sta_information3
             ,p_sta_information4               =>l_state_tax_rec.sta_information4
             ,p_sta_information5               =>l_state_tax_rec.sta_information5
             ,p_sta_information6               =>l_state_tax_rec.sta_information6
             ,p_sta_information7               =>l_state_tax_rec.sta_information7
             ,p_sta_information8               =>l_state_tax_rec.sta_information8
             ,p_sta_information9               =>l_state_tax_rec.sta_information9
             ,p_sta_information10              =>l_state_tax_rec.sta_information10
             ,p_sta_information11              =>l_state_tax_rec.sta_information11
             ,p_sta_information12              =>l_state_tax_rec.sta_information12
             ,p_sta_information13              =>l_state_tax_rec.sta_information13
             ,p_sta_information14              =>l_state_tax_rec.sta_information14
             ,p_sta_information15              =>l_state_tax_rec.sta_information15
             ,p_sta_information16              =>l_state_tax_rec.sta_information16
             ,p_sta_information17              =>l_state_tax_rec.sta_information17
             ,p_sta_information18              =>l_state_tax_rec.sta_information18
             ,p_sta_information19              =>l_state_tax_rec.sta_information19
             ,p_sta_information20              =>l_state_tax_rec.sta_information20
             ,p_sta_information21              =>l_state_tax_rec.sta_information21
             ,p_sta_information22              =>l_state_tax_rec.sta_information22
             ,p_sta_information23              =>l_state_tax_rec.sta_information23
             ,p_sta_information24              =>l_state_tax_rec.sta_information24
             ,p_sta_information25              =>l_state_tax_rec.sta_information25
             ,p_sta_information26              =>l_state_tax_rec.sta_information26
             ,p_sta_information27              =>l_state_tax_rec.sta_information27
             ,p_sta_information28              =>l_state_tax_rec.sta_information28
             ,p_sta_information29              =>l_state_tax_rec.sta_information29
             ,p_sta_information30              =>l_state_tax_rec.sta_information30
             ,p_effective_start_date           =>ld_start_date
             ,p_effective_end_date             =>ld_end_date
            );

		-- when we insert into the transaction audit table, we only show
		-- where the child record is different from the parent record
		-- therefore, if state filing status <> fed filing status we
		-- store it, otherwise there is nothing stored except the child
		-- record info

		     lv_context := 'W4 State';
                     hr_utility.trace('State Context is : ' || lv_context);

		-- insert a row in the transaction table
		     pay_aud_ins.ins(
	  		 p_effective_date => l_state_tax_rec.cur_sysdate
	  	 	,p_transaction_type => lv_trans_type --'ONLINE_TAX_FORMS'
	  		,p_transaction_date => l_state_tax_rec.cur_sysdate
	  		,p_transaction_effective_date => l_state_tax_rec.cur_sysdate
	  		,p_business_group_id => ln_business_group_id
	  		,p_transaction_subtype => 'W4'
  			,p_person_id => ln_person_id
			,p_assignment_id => l_state_tax_rec.assignment_id
  			,p_source1 => l_state_tax_rec.state_code || '-000-0000'
  			,p_source1_type => 'JURISDICTION'
			,p_source2 => fnd_number.number_to_canonical(l_state_tax_rec.gre_id)
			,p_source2_type => 'GRE'
                        ,p_source3 => lv_source_name --'ONLINE W4 FORM'
                        ,p_source3_type => 'SOURCE_NAME'
                        ,p_source4 => p_transaction_id
                        ,p_source4_type => 'TRANSACTION_ID'
			,p_audit_information_category => lv_context
			,p_audit_information1 => lv_state_filing_status_code
                        ,p_audit_information2 => fnd_number.number_to_canonical(p_allowances)
                        ,p_audit_information3 => fnd_number.number_to_canonical(NVL(l_state_tax_rec.sit_additional_tax, 0))
                        --,p_audit_information4 => p_exempt_status_code
                        ,p_audit_information4 => NVL(l_state_exempt, 'N') -- Bug# 6333947
			,p_transaction_parent_id => ln_parent_audit_id
  			,p_stat_trans_audit_id => ln_dummy
  			,p_object_version_number => l_state_tax_rec.object_version_number
  			);

                    hr_utility.trace('State Context is : ' || lv_context ||' after insert ');

        end if; /* mehul */
/* Commenting this for bug 2038691
		-- as a sanity check we make sure that the dates are right
		    if (ld_start_date <> trunc(sysdate)) or
		       (ld_end_date <> to_date('31/12/4712','DD/MM/YYYY')) then

		       raise e_date_error;
		    end if;
Commenting this for bug 2038691*/

                   end if;  -- Check fed = state FS and WA
               end LOOP;   /* State tax cursor */

               close c_state_tax_rows;

            end if; /* to update state tax Yes or No */

        end LOOP; /* Federal cursor loop */

        close c_fed_tax_rows;

	-- all updates and processes have been successful if we are here
	-- so we commit
        if p_validate then
           rollback to update_tax_records;
        else
	   commit;
        end if;

	hr_utility.trace('Leaving ' || gv_package_name || '.update_tax_records');


   EXCEPTION
	WHEN OTHERS THEN
		rollback to update_tax_records;

                raise_application_error(-20001,'Fatal Error while commit');


   end update_tax_records;

PROCEDURE update_w4_info(
             p_validate               in boolean default false ,
             p_transaction_step_id    in number) IS

Cursor c_trans_value is

             select datatype,name,varchar2_value,number_value
             from hr_api_transaction_values
             where transaction_step_id = p_transaction_step_id
             order by transaction_value_id;

Cursor c_trans_step is

             select transaction_id, creator_person_id
             from hr_api_transaction_steps
             where transaction_step_id = p_transaction_step_id;

l_datatype       hr_api_transaction_values.datatype%type;
l_name           hr_api_transaction_values.name%type;
l_varchar2_value hr_api_transaction_values.varchar2_value%type;
l_number_value   hr_api_transaction_values.number_value%type;

l_filing_status  hr_api_transaction_values.varchar2_value%type;

l_filing_status_code pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE;

l_allowances     hr_api_transaction_values.number_value%type;
l_add_tax        hr_api_transaction_values.number_value%type;
l_exempt         hr_api_transaction_values.varchar2_value%type;

l_org_filing_status_code pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE;
l_org_allowances     hr_api_transaction_values.number_value%type;
l_org_exempt         hr_api_transaction_values.varchar2_value%type;
l_last_name_diff     hr_api_transaction_values.varchar2_value%TYPE;

l_item_type      hr_api_transaction_steps.item_type%type;
l_item_key       hr_api_transaction_steps.item_key%type;
l_activity_id    hr_api_transaction_steps.activity_id%type;
l_person_id      hr_api_transaction_steps.creator_person_id%type;

l_transaction_id hr_api_transaction_steps.transaction_id%type;

lv_trans_type    VARCHAR2(50);
lv_source_name   VARCHAR2(50);

begin
        hr_utility.trace('Entering package update_w4_info ');
        hr_utility.trace('p_transaction_step_id is : ' || p_transaction_step_id );

        open c_trans_step;
        fetch c_trans_step into l_transaction_id,l_person_id;
        close c_trans_step;

        open c_trans_value;
        loop
          exit when c_trans_value%NOTFOUND;
          fetch c_trans_value into l_datatype, l_name, l_varchar2_value, l_number_value;
            if l_datatype = 'VARCHAR2' and l_name = 'P_FS_CODE' then
               l_filing_status_code := l_varchar2_value;

            elsif l_datatype = 'VARCHAR2' and l_name = 'P_ORG_FS_CODE' then
               l_org_filing_status_code := l_varchar2_value;

            elsif l_datatype = 'NUMBER' and l_name = 'P_ALLOWANCES' then
               l_allowances := l_number_value;

            elsif l_datatype = 'NUMBER' and l_name = 'P_ORG_ALLOWANCES' then
               l_org_allowances := l_number_value;

            elsif l_datatype = 'NUMBER' and l_name = 'P_ADDITIONAL_TAX' then
               l_add_tax := l_number_value;

            elsif l_datatype = 'VARCHAR2' and l_name = 'P_EXEMPT' then
               l_exempt := l_varchar2_value;
               if l_exempt = 'No' then
                  l_exempt := 'N';
               else
                  l_exempt := 'Y';
               end if;

            elsif l_datatype = 'VARCHAR2' and l_name = 'P_ORG_EXEMPT' then
               l_org_exempt := l_varchar2_value;
               if l_org_exempt = 'No' then
                  l_org_exempt := 'N';
               else
                  l_org_exempt := 'Y';
               end if;
	    -- Bug# 6468114
            elsif l_datatype = 'VARCHAR2' and l_name = 'P_LAST_NAME_DIFF' then
               l_last_name_diff := l_varchar2_value;
            end if;

        end loop;
        close c_trans_value;

        hr_utility.trace(' Transaction Id is   : '|| to_char(l_transaction_id));
        hr_utility.trace(' Person Id is   : '|| to_char(l_person_id));

        hr_utility.trace(' Filing Status is  : '|| l_filing_status_code);
        hr_utility.trace(' Allowances are    : '|| to_char(l_allowances));
        hr_utility.trace(' Additional Tax is : '|| to_char(l_add_tax));
        hr_utility.trace(' Exempt Status is  : '|| l_exempt);

        lv_trans_type   := 'ONLINE_TAX_FORMS';
        lv_source_name  := 'ONLINE W4 FORM';

        update_tax_records(p_filing_status_code     => l_filing_status_code,
                           p_org_filing_status_code => l_org_filing_status_code,
                           p_allowances             => l_allowances,
                           p_org_allowances         => l_org_allowances,
                           p_additional_amount      => l_add_tax,
			   p_last_name_diff         => l_last_name_diff, --'N',
                           p_exempt_status_code     => l_exempt,
                           p_org_exempt_status_code => l_org_exempt,
                           p_transaction_id         => l_transaction_id,
                           p_person_id              => l_person_id,
                           p_transaction_type       => lv_trans_type,
                           p_source_name            => lv_source_name,
                           p_validate               => p_validate);

        hr_utility.trace('Leaving package update_w4_info ');
End;

FUNCTION get_state_list(p_person_id    IN per_people_f.person_id%TYPE,
                        p_primary_flag IN varchar2 )

        RETURN VARCHAR2    IS

        CURSOR c_state_tax_rows IS
                select  pus.state_name,
                        stif.sta_information7,
                        /*nvl(stif.sta_information9,'N') : Bug 6346579 */
			nvl(stif.sta_information9,'Y')
                from    pay_us_emp_state_tax_rules_f str,
                        per_assignments_f paf,
                        pay_us_state_tax_info_f stif,
                        pay_us_states pus,
                        hr_soft_coding_keyflex hsck
                where   paf.person_id = p_person_id
                  and   paf.assignment_id = str.assignment_id
                  and   paf.assignment_type = 'E'
                  and   paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
                  and   decode(p_primary_flag,'Y',paf.primary_flag,'Y') = 'Y'
                  and   str.state_code = stif.state_code
                  and   str.state_code = pus.state_code
                  and   stif.sta_information7 like 'Y%'
                  and   trunc(sysdate) between stif.effective_start_date and
                                               stif.effective_end_date
                  and   trunc(sysdate) between paf.effective_start_date and
                                               paf.effective_end_date
                  and   trunc(sysdate) between str.effective_start_date and
                                               str.effective_end_date;

lv_state_list     VARCHAR2(300);
--lv_state_exempt_list     VARCHAR2(300);

lb_comma_flag     BOOLEAN := false;
lb_ex_comma_flag  BOOLEAN := false;

LV_STATE_NAME     varchar2(50);

lv_state_default_code   varchar2(10);
lv_state_exempt_code    varchar2(10);

l_state_count           number(3) := 0 ;
l_state_exempt_count    number(3) := 0 ;

Begin
        hr_utility.trace('Entering get_state_list');

        lv_state_list := hr_util_misc_web.return_msg_text('PAY_US_OTF_STATE_LIST','PAY');
        g_state_exempt_list := hr_util_misc_web.return_msg_text('PAY_US_OTF_EXEMPT_STATE_LIST','PAY');

        OPEN c_state_tax_rows;
        LOOP
            exit when c_state_tax_rows%NOTFOUND;

            FETCH c_state_tax_rows INTO lv_state_name, lv_state_default_code,lv_state_exempt_code;

              --hr_utility.trace('state is --> '|| lv_state_name ||' Code is --> '|| lv_state_default_code||' Exempt Code is --> '|| lv_state_exempt_code);
                -- append the name to the state list to the message
                -- we do not append it if the code is 'Y QUIET'
                -- instr(lv_state_list,lv_state_name) will ensure that the state
                -- is appended only once to the list.

                if instr(lv_state_list,lv_state_name) = 0 and lv_state_default_code = 'Y'
                   and lv_state_exempt_code = 'Y' then

                        if lb_comma_flag then
                                lv_state_list := lv_state_list || ', ' ||lv_state_name;
                        else
                                lb_comma_flag := true;
                                lv_state_list := lv_state_list || ' '||lv_state_name;
                        end if;
                   l_state_count := 1;

                end if;

                if instr(g_state_exempt_list,lv_state_name) = 0 and lv_state_exempt_code = 'N' then
                        if lb_ex_comma_flag then
                                g_state_exempt_list := g_state_exempt_list || ', ' ||lv_state_name;
                        else
                                lb_ex_comma_flag := true;
                                g_state_exempt_list := g_state_exempt_list || ' '||lv_state_name;
                        end if;
                   l_state_exempt_count := 1;

                end if;
        END LOOP;
        close c_state_tax_rows;

        if l_state_count = 0 then

           lv_state_list := null;
        end if;

        if l_state_exempt_count = 0 then

           g_state_exempt_list := null;
        end if;

        hr_utility.trace('Leaving get_state_list');
        return lv_state_list;

End;

FUNCTION get_org_context(p_person_id    IN per_people_f.person_id%TYPE,
                         p_context hr_organization_information.org_information_context%TYPE,
                         p_level        IN VARCHAR2)

        RETURN VARCHAR2 IS

        CURSOR c_person_info IS
                select  ppf.business_group_id,
                        paf.organization_id,
                        paf.assignment_id,
                        ppf.person_id,
                        ppf.employee_number,
                        ppf.national_identifier,
                        ppf.full_name
                from    per_people_f ppf,
                        per_assignments_f paf
                where   ppf.person_id = p_person_id
                  and   paf.person_id = ppf.person_id
                  and   paf.assignment_type = 'E'
                  and   paf.primary_flag = 'Y'
                  and   trunc(sysdate) between paf.effective_start_date and
                                               paf.effective_end_date
                  and   trunc(sysdate) between ppf.effective_start_date and
                                               ppf.effective_end_date;

        CURSOR c_org_context(ln_organization_id hr_organization_information.organization_id%TYPE) IS
		select 	nvl(hoi.ORG_INFORMATION2,'N') ORG_INFORMATION2
		from	hr_organization_information hoi
                where   hoi.org_information_context = p_context
                and     hoi.organization_id = ln_organization_id;

        lv_proc varchar2(80);
	lr_person_info_rec	c_person_info%ROWTYPE;
        lr_org_info_rec         c_org_context%rowtype;
        lv_result               varchar2(80);

Begin
	lv_proc	:= gv_package_name || '.get_org_context';

        hr_utility.trace('Entering '||lv_proc);

   OPEN c_person_info;
   FETCH c_person_info INTO lr_person_info_rec;

   if c_person_info%notfound then
      CLOSE c_person_info;
      raise no_data_found;
   ELSE
      close c_person_info;
   end if;

        hr_utility.trace('lr_person_info_rec.organization_id = '||lr_person_info_rec.organization_id);
        hr_utility.trace('lr_person_info_rec.business_group_id = '||lr_person_info_rec.business_group_id);

   if p_level = 'BG' then
      OPEN c_org_context(lr_person_info_rec.business_group_id);
      FETCH c_org_context INTO lr_org_info_rec;
          if c_org_context%notfound  then
                   lv_result := 'NOTFOUND';
          else
                   lv_result := lr_org_info_rec.org_information2;
          end if;
      CLOSE c_org_context;
   elsif  p_level ='ORG'then
      OPEN c_org_context(lr_person_info_rec.organization_id);
      FETCH c_org_context INTO lr_org_info_rec;
          if c_org_context%notfound  then
                   lv_result := 'NOTFOUND';
          else
                   lv_result := lr_org_info_rec.org_information2;
          end if;
      CLOSE c_org_context;
   end if;

        hr_utility.trace('lr_org_info_rec.org_information2 = '||lr_org_info_rec.org_information2);
        hr_utility.trace('lv_result = '||lv_result);

        hr_utility.trace('Leaving '||lv_proc);
   return lv_result;

exception
   when no_data_found then
   hr_utility.trace('Person Data not Found');
   hr_utility.trace('In Exception '||lv_proc);

End get_org_context;

 /* Uncomment following two lines for debug */
--  begin
--  hr_utility.trace_on(null,'pyuswbw4');

END pay_us_web_w4;

/
