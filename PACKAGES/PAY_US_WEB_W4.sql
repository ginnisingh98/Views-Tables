--------------------------------------------------------
--  DDL for Package PAY_US_WEB_W4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_WEB_W4" 
/* $Header: pyuswbw4.pkh 120.7.12010000.2 2009/08/03 16:01:25 kagangul ship $ *
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2000 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material AUTHID CURRENT_USER is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_web_w4

    Description : Contains utility and back end procedures for the W4.

    Uses        :

    Change List
    -----------
    Date        Name    Vers   Description
    ----        ----    ----   -----------
    3-MAR-2000 dscully  110.0  Created.

    24-MAR-2000 dscully 115.0  Created.
    10-APR-2000 dscully 115.1  Added process and itemtype parameters
    11-APR-2001 meshah  115.2  Added procedure get_transaction_values
                               Added procedure check_update_status.
                               New procedure update_w4_info.
                               New parameters in procedure
                               validate_submission and update_tax_records.
    11-APR-2001 meshah  115.3  Removed item_type and added transaction_id
                               iin update_tax_record.
    25-MAY-2001 meshah  115.4  Added one more parameter to validate_submission.
    20-AUG-2001 meshah  115.5  Added two more parameter to validate_submission.
                               Removed procedure check_update_status.
    04-SEP-2001 meshah  115.1  adding p_original_exempt in validate_submission
                               and p_org_filing_status_code ,p_org_allowances
                               and p_org_exempt_status_code to update_tax_records.
    15-OCT-2001 meshah  115.2  Defined a new global variable g_state_list.
    20-DEC-2002 meshah  115.3  added nocopy and dbdrv.
    28-OCT-2003 meshah  115.4  p_exempt_state_list parameters has been
                               added to validate_submission and
                               g_state_exempt_list a new global variable.
    09-APR-2004 meshah  115.5  p_original_aa parameter has been
                               added to validate_submission.
    23-MAY-2005 rsethupa 115.6 Bug 4070034 - Added new parameter p_last_name_diff
                               to procedures validate_submission and
			       update_tax_records
    26-sep-2005 jgoswami 115.7 Bug 4599982 - Added update_alien_tax_records
                               to support pqp calls to old w4 packages.
    17-jan-2006 jgoswami 115.8 Bug 4956850 - added new parameter
                               p_transaction_type and p_source_name to
                               procedure update_tax_records
   11-aug-2006 jgoswami 115.9  Bug 5198005 - Supress W4 Notifications for the
                                W4 forms that are exempt or at a level above 10                                 allowances as IRS does not require Employer to
                                Send it. Based on the value of the DFF the
                                Notification will be sent or suppressed.Default                                 the Notification will be Suppressed.
                                created function get_org_context
    06-sep-2006 jgoswami 115.10 Bug 3852021 - Modified validate_submission
                                changed data type for p_additional_amount,
                                p_original_aa from varchar2 to Number .
    13-AUG-2007  vaprakas 115.10 Bug  6200677 modified
    17-NOV-2007 sudedas  115.12 Added new Function Fed_State_Filing_Status_Match
                                AND Global Variables g_not_matching_state_list
				AND g_nonmatch_cntr.
    03-Aug-2009 kagangul 115.13 Added one global variable 'g_NRA_flag' for tracking
				the FIT_EXEMPT change of a NRA employee.
  *******************************************************************/
  AS

/* global variables */

   g_state_list    varchar2(10000);
   g_state_exempt_list    varchar2(10000);
   g_not_matching_state_list   VARCHAR2(10000);
   g_nonmatch_cntr  NUMBER;
   g_NRA_flag	CHAR(1);

  PROCEDURE validate_submission(p_filing_status_code IN	VARCHAR2 DEFAULT null,
			 p_additional_amount  IN	NUMBER   DEFAULT null,
			 p_allowances	      IN	VARCHAR2 DEFAULT null,
			 p_exempt_status_code IN	VARCHAR2 DEFAULT null,
			 p_agreement	      IN	VARCHAR2 DEFAULT 'N',
			 p_person_id	      IN	VARCHAR2,
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
                         p_original_aa        IN        NUMBER,
			 p_last_name_diff     IN        VARCHAR2 DEFAULT 'N',
                         p_fit_exempt     OUT nocopy VARCHAR2
                         );
  /******************************************************************
  **
  ** Description:
  **     validates the submitted information and then displays either
  ** the update page with errors or the review page.
  **
  **	 It uses the chk_ procedures of the FED api to validate.  It
  ** does not pass a tax id to the chk_ procedures since it may be updating
  ** multiple fed tax rows and the chk_ procedures don't really care.
  ** The submitted values are more rigorously validated upon updating.
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/

  FUNCTION check_update_status(p_person_id IN	per_people_f.person_id%TYPE)
    	RETURN VARCHAR2;
  /******************************************************************
  **
  ** Description:
  ** 	Checks that employee meets these conditions:
  **		Update Method profile option not set to NONE
  **		No allowance reject dates or overrides for current recs
  **		No future dated changes
  **		Primary assignment is not a retiree asg
  **	If it fails a test, it returns the appropriate error msg
  **	Otherwise, it returns null.
  ** Access Status:
  **     Public
  **
  ******************************************************************/

PROCEDURE update_alien_tax_records(
	p_filing_status_code 	pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE
	,p_allowances 	  	pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE
	,p_additional_amount	pay_us_emp_fed_tax_rules_f.fit_additional_tax%TYPE
	,p_exempt_status_code	pay_us_emp_fed_tax_rules_f.fit_exempt%TYPE
	,p_process              VARCHAR2
	,p_itemtype             VARCHAR2
        ,p_person_id            per_people_f.person_id%TYPE default null
        ,p_effective_date       date      default null
        ,p_source_name          VARCHAR2  default null
			    );
  /******************************************************************
  **
  ** Description: OTF Fed W4 update procedure for alien changes
  **     1. locks all applicable rows
  **     2. update each fed row using fed api
  **	 3. update each state row using state api
  **     4. archive the submission
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/


PROCEDURE update_tax_records(
	 p_filing_status_code 	  pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE
	,p_org_filing_status_code pay_us_emp_fed_tax_rules_f.filing_status_code%TYPE
	,p_allowances 	  	  pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE
	,p_org_allowances 	  pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE
	,p_additional_amount	  pay_us_emp_fed_tax_rules_f.fit_additional_tax%TYPE
	,p_last_name_diff         VARCHAR2 DEFAULT 'N'
	,p_exempt_status_code	  pay_us_emp_fed_tax_rules_f.fit_exempt%TYPE
	,p_org_exempt_status_code pay_us_emp_fed_tax_rules_f.fit_exempt%TYPE
	,p_transaction_id         hr_api_transactions.transaction_id%type
	,p_person_id	          VARCHAR2
        ,p_transaction_type         VARCHAR2
        ,p_source_name              VARCHAR2
        ,p_validate               boolean default false
			    );
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

PROCEDURE get_transaction_values(
              p_trans_id    IN   VARCHAR2  default null,
              p_step_id     IN   VARCHAR2  default null,
              p_out_values  OUT nocopy  VARCHAR2 );

  /******************************************************************
  **
  ** Description: This procedure gets the transaction values that
  **              were inserted while transiting from update page
  **              to review page to be displayed on the review page.
  ** Access Status:
  **     Public
  **
  ******************************************************************/

PROCEDURE update_w4_info(
              p_validate                 in     boolean default false ,
              p_transaction_step_id      in     number);

FUNCTION GET_STATE_LIST(p_person_id IN	per_people_f.person_id%TYPE,
                        p_primary_flag IN varchar2 )
    	RETURN VARCHAR2;

FUNCTION GET_ORG_CONTEXT(p_person_id IN	per_people_f.person_id%TYPE,
                         p_context hr_organization_information.org_information_context%TYPE,
                         p_level        IN VARCHAR2)
    	RETURN VARCHAR2;

-- The following Function has been Added to correct inconsistent behaviour of State W-4
-- For the States that should follow Federal W-4, Filing Status, Allowances etc. should be
-- defaulted from Federal Information for them. Whereas for States that May OR May NOT
-- follow Federal W-4, if Filing Status does not match with State W-4 the information will
-- NOT be copied and an Informational Message will be displayed to Customer.
--
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
RETURN BOOLEAN;
--
--

END pay_us_web_w4;

/
