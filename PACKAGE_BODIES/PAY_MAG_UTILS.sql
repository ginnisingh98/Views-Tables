--------------------------------------------------------
--  DDL for Package Body PAY_MAG_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MAG_UTILS" AS
/* $Header: pymagutl.pkb 120.1 2005/10/10 12:03:21 meshah noship $ */
--
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
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

    Name        : pay_mag_utils

    Description : Contains procedures and functions used by magnetic reports.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No     Description
    ----        ----     ----    ------     -----------
    10-OCT-96   ATAYLOR  40.0               Created.
                                            The messages will have to be replaced
                                            as and when tape becomes unfrozen.
    01-NOV-96   GPERRY   40.1               Added Insert_Lookup for seeding
                                            1099R relevant lookups. Added Write as
                                            a debugging tool for use when testing 1099R
                                            reports on a site or internally.
    06-NOV-96   GPERRY   40.2               Added function date_earned.
    13-NOV-96   GPERRY   40.3               Removed function call to hr_api as not
					    valid on QA database.
    17-DEC-96   HEKIM    40.4               Fixed block definition structure viewer
    26-FEB-97   HEKIM    40.5               Changed message name from HR_ to PAY_
    20-MAR-97   HEKIM    40.6               Added udf_Exists and Delete_udf.
    14-JUL-97   HEKIM    40.7  	            Change message numbers to 5003x range
    29/07/97    mfender  110.2              Corected untranslatable date formats
    08-APR-99   DJOSHI	                    Verfied and converted for Canonical
                                            Complience of Date
    18-jun-1999 achauhan 115.2              replaced dbms_output with
                                            hr_utility.trace
    17-aug-1999 rthakur  115.3              Added function get_parameter.
    07-jan-2000 vmehta   115.4             Modified function get_parameter
                                           to take care of the condition
                                           where the second parameter  is
                                           passed in as null. bug 1069642
    18-jan-2002 fusman   115.5             Changed the default date from 01/01/1996
                                           to 01/01/1901 for p_creation_date,p_last_update_date
                                           and p_effective_date.Also added dbdrv commands.
    02-jul-2002 fusman   115.6             Bug:2296797 Added legislation code.
    25-Apr-2005 sackumar 115.8             Bug 4055762 introduce ltrim,rtrim function
					   in get_parameter function.
*/

-----------------------------------------------------------------------------
-- Name
--   Write
-- Purpose
--   Provides debugging information that can be picked up when running the
--   concurrent process from SRS. Write output to the TEST_1099R table that
--   should exist with the following columns.
--      SEQUENCE NUMBER
--      TEXT     VARCHAR2(240)
--   Due to the fact that the debugging table will not be shipped as part
--   of the installation the write information will be editted out.
-- Arguments
--   p_action     denotes action type (I,D) Insert or Delete
--   p_sequence   denotes sequence number of insertion
--   p_message    denotes message to be written to table
--   p_write_mode denotes whether info is written to table (default is FALSE)
-- Notes
--   For a non-test site this should never write to the TEST_1099R table.
-----------------------------------------------------------------------------
PROCEDURE Write (p_action     IN VARCHAR2,
                 p_sequence   IN NUMBER   DEFAULT NULL,
                 p_message    IN VARCHAR2 DEFAULT NULL,
                 p_write_mode IN BOOLEAN  DEFAULT TRUE ) IS
BEGIN
  --
  IF upper(p_action) = 'D' THEN
    --
    -- Clear down table
    --
    --deLETE FROM TEST_1099R;
    --
    NULL;
    --
  ELSIF upper(p_action) = 'I' THEN
    --
    IF p_write_mode THEN
      --
      -- This if condition decides whether we actually write to the
      -- the table or not. Obviously performance-wise it is better
      -- to not bother but for debgugging purposes this is quite
      -- useful.
      --
      --inSERT INTO TEST_1099R
      --VALUES (p_sequence,p_message);
      --
      NULL;
      --
    END IF;
    --
  END IF;
  --
  -- Commit should be editted out as this will write records to the database
  -- which we do not want to do unless we are testing the report.
  --
  -- COMMIT;
  --
END Write;
--
--
-----------------------------------------------------------------------------
-- Name
--   Date_Earned
-- Purpose
--   Checks if dates are valid for the assignment effective dates and the
--   person effective dates.
-- Arguments
--
-- Notes
--   Used so that only one call is made to the database when comparing the
--   dates of the payroll_action and the report_date.
-----------------------------------------------------------------------------
FUNCTION Date_Earned ( p_report_date              IN DATE,
                       p_assignment_id            IN NUMBER,
                       p_ass_effective_start_date IN DATE,
                       p_ass_effective_end_date   IN DATE,
                       p_per_effective_start_date IN DATE,
                       p_per_effective_end_date   IN DATE) RETURN NUMBER IS
   --
   l_max_assignment_date date;
   --
BEGIN
   --
   -- Bring back maximum effective end date for the assignment we are
   -- dealing with.
   --
 SELECT MAX(paf.effective_end_date)
   INTO   l_max_assignment_date
   FROM   per_assignments_f paf
   WHERE  paf.assignment_id = p_assignment_id;
   --
   IF l_max_assignment_date < p_report_date AND
      l_max_assignment_date >= p_ass_effective_start_date AND
      l_max_assignment_date <= p_ass_effective_end_date AND
      l_max_assignment_date >= p_per_effective_start_date AND
      l_max_assignment_date <= p_per_effective_end_date THEN
      --
      -- Dates are valid for this person so return true
      --
      RETURN 1;
      --
   ELSIF p_report_date <= l_max_assignment_date AND
      p_report_date >= p_ass_effective_start_date AND
      p_report_date <= p_ass_effective_end_date AND
      p_report_date >= p_per_effective_start_date AND
      p_report_date <= p_per_effective_end_date THEN
      --
      RETURN 1;
      --
   ELSE
      --
      RETURN 0;
      --
   END IF;
   --
END Date_Earned;
--
--
--
-----------------------------------------------------------------------------
-- Name
--   Lookup_Formula
-- Purpose
--   Given a formula name it returns its id.
-- Arguments
-- Notes
-----------------------------------------------------------------------------
--
FUNCTION Lookup_Formula ( p_session_date	DATE,
			  p_business_group_id 	NUMBER,
			  p_legislation_code  	VARCHAR2,
			  p_formula_name      	VARCHAR2) RETURN NUMBER IS
--
-- Local variables
--
	l_formula_id 	NUMBER;
--
-- Cursor to get the formula id for the specified formula.
--
CURSOR csr_formula IS
  SELECT formula_id
  FROM   ff_formulas_f
  WHERE  legislation_code  = p_legislation_code
  AND    formula_name  = UPPER(p_formula_name)
  AND    p_session_date  BETWEEN effective_start_date
			 AND effective_end_date;
--
BEGIN
   --
   OPEN csr_formula;
   --
   hr_utility.set_location('pay_mag_utils.lookup_formula',1);
   --
   FETCH csr_formula INTO l_formula_id;
   --
   hr_utility.set_location('pay_mag_utils.lookup_formula',2);
   --
   -- If formula not found, then raise exception in calling package.
   --
   IF csr_formula%NOTFOUND THEN
      --
      CLOSE csr_formula;
      --
      hr_utility.set_message(801,'PAY_50030_1099R_NO_FF');
      RAISE hr_utility.hr_error;
      --
   ELSE
     --
     CLOSE csr_formula;
     RETURN (l_formula_id);
     --
   END IF;
   --
END Lookup_Formula;
--
--
-- --------------------------------------------------------------------------
-- Name
--   Lookup_Format
-- Purpose
--   Find the format to be applied when generating the report.
-- Arguments
--   p_period_end
--   p_report_type
--   p_state
-- Notes
-- --------------------------------------------------------------------------
--
FUNCTION Lookup_Format (p_period_end  IN DATE,
			p_report_type IN VARCHAR2,
			p_state       IN VARCHAR2) RETURN VARCHAR2 IS
   --
   CURSOR csr_format IS
      SELECT report_format
      FROM   pay_report_format_mappings_f
      WHERE  report_type = p_report_type
      AND    report_qualifier = p_state
      AND    p_period_end BETWEEN effective_start_date AND effective_end_date;
   --
   l_format varchar2(30);
   --
BEGIN
   --
   hr_utility.set_location('pay_mag_utils.lookup_format',1);
   --
   -- In the case of a yearly report, period end will be the same as year end.
   --
   OPEN csr_format;
   FETCH csr_format INTO l_format;
   --
   IF csr_format%NOTFOUND THEN
      --
      CLOSE csr_format;
      hr_utility.set_message(801,'PAY_50031_1099R_REP_FMT');
      RAISE hr_utility.hr_error;
      --
   ELSE
     --
     CLOSE csr_format;
     --
   END IF;
   --
   RETURN (l_format);
   --
END Lookup_Format;
--
--
-----------------------------------------------------------------------------
-- Name
--   Bal_db_Item
-- Purpose
--   Given the name of a balance DB item as would be seen in a fast formula
--   it returns the defined_balance_id of the balance it represents.
-- Arguments
-- 	p_db_item_name		Item name
-- Notes
--   A defined balance_id is required by the PLSQL balance function.
-----------------------------------------------------------------------------
--
FUNCTION Bal_db_Item ( p_db_item_name VARCHAR2 ) RETURN NUMBER IS
   --
   -- Cursor to get the defined_balance_id for the specified balance db item.
   --
   CURSOR csr_defined_balance IS
      SELECT fnd_number.canonical_to_number(ue.creator_id)
      FROM   ff_database_items di,
    	     ff_user_entities  ue
      WHERE  di.user_name = p_db_item_name
      AND    ue.user_entity_id = di.user_entity_id
      AND    ue.creator_type = 'B'
      AND    ue.legislation_code = 'US'; /* Bug: 2296797 */
   --
   l_defined_balance_id 	NUMBER;
   --
BEGIN
   --
   OPEN csr_defined_balance;
   --
   FETCH csr_defined_balance INTO l_defined_balance_id;
   --
   IF csr_defined_balance%notfound THEN
     --
     CLOSE csr_defined_balance;
     hr_utility.set_message(801,'PAY_50032_1099R_BAL_DB');
     RAISE hr_utility.hr_error;
     --
   ELSE
     CLOSE csr_defined_balance;
   END IF;
   --
   RETURN (l_defined_balance_id);
   --
END Bal_db_Item;
--

--
-----------------------------------------------------------------------------
-- Name
--   Lookup_Jurisdiction_Code
-- Purpose
--   Given a state code ie. AL it returns the jurisdiction code that
--   represents that state.
-- Arguments
--   	p_state
-- Notes
-----------------------------------------------------------------------------
--
FUNCTION Lookup_Jurisdiction_Code ( p_state VARCHAR2 ) RETURN VARCHAR2 IS
--
-- Get the jurisdiction_code for the specified state code.
--
CURSOR csr_jurisdiction_code IS
   SELECT sr.jurisdiction_code
   FROM   pay_state_rules sr
   WHERE  sr.state_code = p_state;
--
l_jurisdiction_code pay_state_rules.jurisdiction_code%type;
--
BEGIN
   --
   OPEN csr_jurisdiction_code;
   FETCH csr_jurisdiction_code INTO l_jurisdiction_code;
   --
   IF csr_jurisdiction_code%NOTFOUND THEN
      --
     CLOSE csr_jurisdiction_code;
     hr_utility.set_message(801,'PAY_50033_1099R_JU_CODE');
     RAISE hr_utility.hr_error;
  ELSE
    --
    CLOSE csr_jurisdiction_code;
    --
  END IF;
  --
  RETURN (l_jurisdiction_code);
  --
END Lookup_Jurisdiction_Code;
--

--
-----------------------------------------------------------------------------
-- Name
--   Check_Report_Unique
-- Purpose
--   Makes sure that a report has not already been run which overlaps with
--   the report being started.
-- Arguments
-- Notes
--  Each report is uniquely defined by the EFFECTIVE_DATE and the
--  LEGISLATIVE_PARAMETERS of the payroll action. The LEGISLATIVE_PARAMETERS
--  is set to report_type || '-' || p_state.  In order to resubmit this report
--  we need to add transmitter legal company id onto the LEGISLATIVE PARAMETERS.
--  To ensure that a report with a for the same state and same period is not run
--  for different transmitters.  I added the '%' to where clause.
-----------------------------------------------------------------------------
--
PROCEDURE Check_Report_Unique (	p_business_group_id IN NUMBER,
				p_period_end        IN DATE,
				p_report_type       in VARCHAR2,
				p_state             in VARCHAR2 ) IS
   --
   CURSOR csr_payroll_action IS
      SELECT payroll_action_id
      FROM   pay_payroll_actions ppa
      WHERE  ppa.business_group_id = p_business_group_id
      AND    ppa.effective_date    = p_period_end
      AND    ppa.legislative_parameters like
		'USMAGTAPE'|| '-' ||
		lpad(p_report_type, 5)||'-'||
	        lpad(p_state, 5) || '%';
   --
   l_payroll_action_id 	NUMBER;
   --
BEGIN
   --
   hr_utility.set_location('pay_mag_utils.check_report_unique',1);
   --
   OPEN csr_payroll_action;
   --
   FETCH csr_payroll_action INTO l_payroll_action_id;
   --
   IF csr_payroll_action%found THEN
      --
      CLOSE csr_payroll_action;
      hr_utility.set_message(801,'PAY_50034_1099R_REP_RUN');
      RAISE hr_utility.hr_error;
      --
   ELSE
      CLOSE csr_payroll_action;
   END IF;
--
END Check_Report_Unique;
--

--
-----------------------------------------------------------------------------
-- Name
--   Error_Payroll_Action
-- Purpose
--   Sets the status of a payroll action to 'E'rror.
-- Arguments
--	p_payroll_action_id
-- Notes
--   This should only be used when the magnetic report has failed.
-----------------------------------------------------------------------------
--
PROCEDURE Error_Payroll_Action ( p_payroll_action_id NUMBER ) IS
--
BEGIN
   --
   -- Set the payroll action status to Error if report has failed.
   --
   hr_utility.set_location('pay_mag_utils.error_payroll_action',1);
   --
   UPDATE pay_payroll_actions pa
   SET    pa.action_status = 'E'
   WHERE  pa.payroll_action_id = p_payroll_action_id;
   --
   COMMIT;
   --
END Error_Payroll_Action;
--

--
-----------------------------------------------------------------------------
-- Name
--   Update_Action_Statuses
-- Purpose
--   Sets the payroll action to 'C'omplete. Sets all successful assignment
--   actions to 'C'omplete.
-- Arguments
-- Notes
--   This should only be used when the magnetic report has successfully run.
--   All the assignment actions are set to 'U'nprocessed before processing
--   starts. If an error occurs with an assignment action then it is set to
--   'E'rror by the magnetic tape process. Having finished processing, all
--   assignment actions left with a status of 'U'nprocessed are assumed to
--   be successful and therefore set to 'C'omplete.
-----------------------------------------------------------------------------
--
PROCEDURE Update_Action_Status ( p_payroll_action_id NUMBER ) IS
--
BEGIN
   --
   -- Sets the payroll action to a status of 'C'omplete.
   --
   hr_utility.set_location('pay_mag_utils.update_action_status',1);
   --
   UPDATE pay_payroll_actions pa
   SET    pa.action_status = 'C'
   WHERE  pa.payroll_action_id = p_payroll_action_id;
   --
   -- Sets all successfully processed assignment actions to 'C'omplete.
   --
   hr_utility.set_location('pay_mag_utils.update_action_status',2);
   --
   UPDATE pay_assignment_actions aa
   SET    aa.action_status = 'C'
   WHERE  aa.payroll_action_id = p_payroll_action_id
   AND    aa.action_status = 'U';
   --
   COMMIT;
   --
END Update_Action_Status;
--

--
-----------------------------------------------------------------------------
-- Name
--   Create_Payroll_Action
-- Purpose
--   Creates a payroll action identifying the production of a particular
--   magnetic tape report e.g. Federal 1099R. The list of people to be
--   reported on is created as assignment actions for the payroll action.
-- Arguments
-- Notes
--   The effective_date of the payroll action identifies the end of the
--   period being reported i.e. end of tax year or end of a quarter. The
--   legislative parameter is used to uniquely identify the report.
-----------------------------------------------------------------------------
--
FUNCTION Create_Payroll_Action (  p_report_type       IN  VARCHAR2,
  				  p_state	      IN  VARCHAR2,
  				  p_trans_legal_co_id IN  VARCHAR2,
  				  p_business_group_id IN  NUMBER,
  				  p_period_end        IN  DATE,
				  p_param_text        IN  VARCHAR2
							  DEFAULT NULL ) RETURN NUMBER IS
   --
   l_payroll_action_id pay_payroll_actions.payroll_action_id%type;
   --

   l_legislative_parms     VARCHAR2(240);
BEGIN
   --
   -- Get the next payroll_action_id value from the sequence.
   --
   hr_utility.set_location('pay_mag_utils.create_payroll_action',1);
   --
   select pay_payroll_actions_s.nextval
   into   l_payroll_action_id
   from   sys.dual;
   --
   -- Create a payroll action dated as of the end of the period being reported
   -- on. Populate the legislative parameter to identify the report being run.
   --
   hr_utility.set_location('pay_mag_utils.create_payroll_action',2);
   --
   if p_report_type = '1099R' then
   l_legislative_parms := 'USMAGTAPE'|| '-' ||
    		          lpad(p_report_type,5) || '-' ||
    		          lpad(p_state,5) || '-' ||
    		          lpad(p_trans_legal_co_id, 5) || p_param_text;
   else
   l_legislative_parms := 'USMAGTAPE'|| '-' ||
    		          lpad(p_report_type,5) || '-' ||
    		          lpad(p_state,5) || '-' ||
    		          lpad(p_trans_legal_co_id, 5);
   end if;
   --
   --
   INSERT INTO pay_payroll_actions
   		(payroll_action_id,
   		 action_type,
   		 business_group_id,
   		 action_population_status,
   		 action_status,
   		 effective_date,
   		 date_earned,
   		 legislative_parameters,
   		 object_version_number )
   VALUES
   		( l_payroll_action_id,
   		  'X',  -- (X) Magnetic Report
   		  p_business_group_id,
   		  'U',  -- (U)npopulated
   		  'U',  -- (U)nprocessed
   		  p_period_end,
   		  p_period_end,
   		  l_legislative_parms,
   		  1);
   --
   hr_utility.set_location('pay_mag_utils.create_payroll_action',3);
   --
   -- Return payroll action id of new row.
   --
   RETURN (l_payroll_action_id);
   --
END Create_Payroll_Action;
--

--
-----------------------------------------------------------------------------
-- Name
--   Create_Assignment_Action
-- Purpose
--   Create an assignment action for each person to be reported on within the
--   magnetic tape report identified by the parent payroll action.
-- Arguments
-- Notes
-----------------------------------------------------------------------------
--
FUNCTION Create_Assignment_Action ( p_payroll_action_id IN NUMBER,
  				    p_assignment_id     IN NUMBER,
  				    p_tax_unit_id       IN NUMBER )
							   RETURN NUMBER IS
   --
   -- Cursor to fetch the newly created assignment_action_id. There could
   -- be several assignment actions for the same assignment and the only way
   -- to find the newly created one is to fetch the one that has not had the
   -- tax_unit_id updated yet.
   --
   CURSOR csr_assignment_action IS
     SELECT aa.assignment_action_id
     FROM   pay_assignment_actions aa
     WHERE  aa.payroll_action_id = p_payroll_action_id
     AND    aa.assignment_id     = p_assignment_id
     AND    aa.tax_unit_id   IS NULL;
   --
   -- Local variables.
   --
   l_assignment_action_id pay_assignment_actions.assignment_action_id%type;
   --
BEGIN
   --
   hr_utility.set_location('pay_mag_utils.create_assignment_action',1);
   --
   -- Create assignment action to identify a specific person's inclusion in the
   -- magnetic tape report identified by the parent payroll action. The
   -- assignment action has to be sequenced within the other assignment actions
   -- according to the date of the payroll action so that the derivation of
   -- any balances based on the assignment action is correct.
   --
   hrassact.inassact(p_payroll_action_id, p_assignment_id);
   --
   -- Get the assignment_action_id of the newly created assignment action.
   --
   hr_utility.set_location('pay_mag_utils.create_assignment_action',2);
   --
   OPEN  csr_assignment_action;
   FETCH csr_assignment_action INTO l_assignment_action_id;
   CLOSE csr_assignment_action;
   --
   UPDATE pay_assignment_actions aa
   SET    aa.tax_unit_id = p_tax_unit_id
   WHERE  aa.assignment_action_id = l_assignment_action_id;
   --
   hr_utility.set_location('pay_mag_utils.create_assignment_action',3);
   --
   -- Return id of new row.
   --
   RETURN (l_assignment_action_id);
   --
END Create_Assignment_Action;
--

--
-----------------------------------------------------------------------------
-- Name
--   Insert_Lookups
-- Purpose
--   Inserts lookups into the hr_lookups table. It firstly checks if the lookup
--   exists before inserting it thus avoiding duplication.
-- Arguments
--   p_lookup_code - lookup code to add
--   p_lookup_type - lookup type to add
--   p_meaning     - lookup code meaning
--   Rest are defaulted.
-----------------------------------------------------------------------------
PROCEDURE Insert_Lookup
  (p_lookup_code      in varchar2,
   p_lookup_type      in varchar2,
   p_application_id   in number default 800,
   p_created_by       in number default 1,
   p_creation_date    in date default to_date('01/01/1901','DD/MM/YYYY'),
   p_enabled_flag     in varchar2 default 'Y',
   p_last_updated_by  in number default 1,
   p_last_update_date in date default to_date('01/01/1901','DD/MM/YYYY'),
   p_meaning          in varchar2,
   p_effective_date   in date default to_date('01/01/1901','DD/MM/YYYY')) IS
  --
  l_dummy VARCHAR2(1);
  --
  CURSOR c1 IS
    SELECT NULL
    FROM   HR_LOOKUPS HR
    WHERE  HR.lookup_type = p_lookup_type
    AND    HR.lookup_code = p_lookup_code;
  --
BEGIN
  --
  OPEN c1;
    --
    FETCH c1 INTO l_dummy;
    IF c1%notfound THEN
      --
      -- insert the lookup
      --
      INSERT INTO hr_lookups
        (lookup_code,
         lookup_type,
         application_id,
         created_by,
         creation_date,
         enabled_flag,
         last_updated_by,
           last_update_date,
         meaning)
      VALUES
        (p_lookup_code,
         p_lookup_type,
         p_application_id,
         p_created_by,
         p_creation_date,
         p_enabled_flag,
         p_last_updated_by,
         p_last_update_date,
         p_meaning);
      --
    END IF;
    --
  CLOSE c1;
  --
END Insert_Lookup;
--

--
-----------------------------------------------------------------------------
--
-- Name
--   Get_Dates
-- Purpose
--   Dates are dependent on the report being run i.e. a 1099R report shows
--   information for a tax year.
-- Arguments
-- Notes
-----------------------------------------------------------------------------
--
PROCEDURE Get_Dates ( 	p_report_type   	VARCHAR2,
  			p_year          	VARCHAR2,
  			p_year_start    IN OUT nocopy DATE,
  			p_year_end      IN OUT nocopy DATE,
  			p_rep_year      IN OUT nocopy VARCHAR2  ) IS
   --
BEGIN
   --
   -- 1099R is a yearly report where the identifier indicates the year
   -- eg. 1995. The expected values for the example should be
   --
   -- p_year_start        01-JAN-1995
   -- p_year_end          31-DEC-1995
   -- p_reporting_year    1995
   --
   hr_utility.set_location('pay_mag_utils.get_dates',1);
   --
   IF p_report_type = '1099R' THEN
      --
      hr_utility.set_location('pay_mag_utils.get_dates',2);
      --
      p_rep_year      := p_year;
      --
   END IF;
   --
   hr_utility.set_location('pay_mag_utils.get_dates',3);
   --
   p_year_start := to_date('01-01-'||p_rep_year, 'DD-MM-YYYY');
   p_year_end   := to_date('31-12-'||p_rep_year, 'DD-MM-YYYY');
   --
END Get_Dates;
--
----------------------------------------------------------------------------------------
-- Name
--   set_titles
-- Purpose
--   Writes titles to the screen for the block_name, main_block, next_block, formula
-- Arguments
--   p_report_format
----------------------------------------------------------------------------------------
--
PROCEDURE Set_Titles (p_report_format in varchar2) is
  --
  l_string varchar2(80);
  --
BEGIN
  --
  -- Put report title on screen
  --
  hr_utility.trace('****************************************************');
  hr_utility.trace('Report Format '||p_report_format);
  hr_utility.trace('****************************************************');
  --
  -- Put headings on screen
  --

  l_string := 'Block Name'||
              '               '||
              'Main'||
              ' '||
              'Next Block'||
              '               '||
              'Formula';
  hr_utility.trace(l_string);
  --
  l_string := '----------'||
              '               '||
              '----'||
              ' '||
              '----------'||
              '               '||
              '-------';
  hr_utility.trace(l_string);
  --
END Set_Titles;
--
/*^L*/
----------------------------------------------------------------------------------------
-- Name
--   format_output
-- Purpose
--   Formats report output for report format block structure
-- Arguments
--   p_block_name
--   p_main_block
--   p_next_block
--   p_formula
----------------------------------------------------------------------------------------
--
PROCEDURE Format_Output(p_block_name in varchar2,
                        p_main_block in varchar2,
                        p_next_block in varchar2,
                        p_formula    in varchar2) is
  --
  l_string varchar2(200) := '';
  l_formula varchar2(50);
  --
BEGIN
  --
  -- Format output as per the titles defined in Set_Titles
  -- The code looks more complex than it is but all we are ensuring is that
  -- we get a very tabular look to the output.
  --
  g_message := 'Inserting format for '||p_block_name;
  --
  hr_utility.trace('Inserting format for '||p_block_name);
  --
  l_formula := substr(p_formula,1,25);
  l_string := concat(l_string,p_block_name);
  l_string := concat(l_string,lpad(p_main_block,26-length(p_block_name),' '));
  l_string := concat(l_string,lpad(p_next_block,5-length(p_main_block)
                     +length(p_next_block),' '));
  l_string := concat(l_string,lpad(l_formula,25-length(p_next_block)
                     +length(l_formula),' '));
  hr_utility.trace(l_string);
  --
END Format_Output;

/*^L*/
----------------------------------------------------------------------------------------
-- Name
--   recurse_block_structure
-- Purpose
--   This procedure recursively looks up and down a block structure hierarchy and
--   obtains the structure of the block definition.
-- Arguments
--   p_magnetc_block_id
----------------------------------------------------------------------------------------
--
PROCEDURE Recurse_Block_Structure (p_magnetic_block_id number) is
  --
  CURSOR c_structure IS
    SELECT pmb.block_name block_name,
           pmb.main_block_flag main_block_flag,
           pmb2.block_name next_block_name,
           pmr.next_block_id next_block_id,
           ff.formula_name formula_name
    FROM   pay_magnetic_blocks pmb,
           pay_magnetic_records pmr,
           pay_magnetic_blocks pmb2,
           ff_formulas_f ff
    WHERE  pmb.magnetic_block_id = p_magnetic_block_id
    AND    pmb.magnetic_block_id = pmr.magnetic_block_id
    AND    pmr.next_block_id     = pmb2.magnetic_block_id (+)
    AND    pmr.formula_id        = ff.formula_id
    ORDER  by pmr.sequence;
  --
BEGIN
  --
  -- Start recursive procedure to create block structure hierarchy
  --
  FOR ee IN c_structure LOOP
    --
    EXIT WHEN c_structure%notfound;
    --
    hr_utility.trace(ee.block_name);
    --
    -- We have to ensure that the next_block_name does not have a null
    -- value as otherwise our formatting which uses lengths of items to
    -- ensure correct padding will not work correctly. To get around this
    -- problem we just assign a space to the passed parameter.
    --
    Format_Output(ee.block_name,
                  ee.main_block_flag,
                  nvl(ee.next_block_name,' '),
                  ee.formula_name);
    --
    IF ee.next_block_id IS NOT NULL THEN
       Recurse_Block_Structure(ee.next_block_id);
    END IF;
    --
  END LOOP;
  --
END Recurse_Block_Structure;
/*^L*/
----------------------------------------------------------------------------------------
-- Name
-- Org_Info_Exists
-- Purpose
--   Checks if p_org_info_type exists in HR_ORG_INFORMATION_TYPES
-- Arguments
--    p_org_info_type
----------------------------------------------------------------------------------------
FUNCTION  Org_Info_Exists ( p_org_info_type IN VARCHAR2) RETURN BOOLEAN IS
--
  l_dummy varchar2(1);
  --
  -- Cursor to check for an existance of the report format in pay_magnetic_blocks
  -- table.
  --
  CURSOR c_org_exists IS
    SELECT null
    FROM   HR_ORG_INFORMATION_TYPES hoit
    WHERE  hoit.org_information_type = p_org_info_type;
  --
BEGIN
  --
  -- Steps to check for valid report format are as follows :
  --   1) Open cursor
  --   2) Attempt fetch of record
  --   3) If fetch fails then raise NO_DATA_FOUND, this can be handled
  --      by our exception handler in the main procedure.
  --   4) Otherwise processing continues
  --
  OPEN c_org_exists;
    --
    FETCH c_org_exists INTO l_dummy;
    --
    IF c_org_exists%notfound THEN
      --
      CLOSE c_org_exists;
      return(FALSE);
      --
    ELSE
      --
      CLOSE c_org_exists;
      return(TRUE);
      --
    END IF;
End  Org_Info_Exists;
--
/*^L*/
----------------------------------------------------------------------------------------
--
PROCEDURE Report_Exists (p_report_format in varchar2) is
  --
  l_dummy varchar2(1);
  --
  -- Cursor to check for an existance of the report format in pay_magnetic_blocks
  -- table.
  --
  CURSOR c_report_exists IS
    SELECT null
    FROM   pay_magnetic_blocks pmb
    WHERE  pmb.report_format = p_report_format;
  --
BEGIN
  --
  -- Steps to check for valid report format are as follows :
  --   1) Open cursor
  --   2) Attempt fetch of record
  --   3) If fetch fails then raise NO_DATA_FOUND, this can be handled
  --      by our exception handler in the main procedure.
  --   4) Otherwise processing continues
  --
  OPEN c_report_exists;
    --
    FETCH c_report_exists INTO l_dummy;
    --
    IF c_report_exists%notfound THEN
      --
      CLOSE c_report_exists;
      --
      -- raise NO_DATA_FOUND to force flow back to calling procedure
      --
      RAISE NO_DATA_FOUND;
      --
    END IF;
    --
  CLOSE c_report_exists;
  --
End Report_Exists;
--
/*^L*/
----------------------------------------------------------------------------------------
-- Name
--   main
-- Purpose
--   Calls supporting procedures to display block information on the screen.
-- Arguments
--   None
-- Notes
----------------------------------------------------------------------------------------
--
     PROCEDURE Main(p_report_format in varchar2) IS
  --
  l_magnetic_block_id number;
  --
  -- This cursor returns the magnetic block id of the starting (main block) of
  -- the report format to be produced.
  --
  CURSOR c_magnetic_block_id IS
    SELECT pmb.magnetic_block_id
    FROM   pay_magnetic_blocks pmb
    WHERE  pmb.report_format = p_report_format
    AND    pmb.main_block_flag = 'Y';
  --
BEGIN
  -- **************************************************************************
  --                               FORMAT EXISTS
  -- **************************************************************************
  --
  -- This procedure checks if the format for the report we want to view
  -- actually exists.
  --
  hr_utility.trace('Attempting to see if '||p_report_format||' exists');
  --
  g_message := 'Attempting to see if '||p_report_format||' exists';
  --
  Report_Exists(p_report_format);
  --
  -- *************************************************************************
  --                                 SET TITLES
  -- *************************************************************************
  --
  -- This procedure displays titles and headings for the report for which we are
  -- displaying the format.
  --
  hr_utility.trace('Setting Titles');
  --
  g_message := 'Setting Titles';
  --
  Set_Titles(p_report_format);
  --
  -- *************************************************************************
  --                              RECURSE BLOCK STRUCTURE
  -- *************************************************************************
  --
  -- If the report exists we can start by calling the recursive procedure in
  -- order to output the definition of the report. The steps to do this are
  -- as follows :
  --   1) Get Magnetic Block ID of main block for report format
  --   2) Pass this ID to Recurse_Block_Structure procedure
  --   3) The procedure will then recursively go down its hierarchy and print
  --      out the report format.
  --
  hr_utility.trace('Attempting to get main block for '||p_report_format);
  --
  g_message := 'Attempting to get main block for '||p_report_format;
  --
  OPEN c_magnetic_block_id;
    --
    FETCH c_magnetic_block_id INTO l_magnetic_block_id;
    --
    IF c_magnetic_block_id%notfound THEN
      --
      CLOSE c_magnetic_block_id;
      --
      -- Raise error as there is no magnetic block that is the main block so
      -- structure can not be defined.
      --
      RAISE NO_DATA_FOUND;
      --
    END IF;
    --
  CLOSE c_magnetic_block_id;
  --
  hr_utility.trace('Starting recursive call to produce format of '||p_report_format);
  --
  g_message := 'Starting recursive call to produce format of '||p_report_format;
  --
  Recurse_Block_Structure(l_magnetic_block_id);
  --
  -- *************************************************************************
  --                              END
  -- *************************************************************************
  --
EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
  --
  hr_utility.trace(g_message||' - ORA '||to_char(SQLCODE));
  hr_utility.trace(g_message||' - ORA '||to_char(SQLCODE));
  --
  WHEN OTHERS THEN
  --
  hr_utility.trace(g_message||' - ORA '||to_char(SQLCODE));
  hr_utility.trace(g_message||' - ORA '||to_char(SQLCODE));
  --
END Main;
--
----------------------------------------------------------------------------------------
-- Name
--   udf_Exists
-- Purpose
--   This procedure checks to see if udf is already stored in ff_functions
-- Arguments
--  p_udf_nam
----------------------------------------------------------------------------------------
FUNCTION udf_Exists (p_udf_name in varchar2) RETURN NUMBER IS

l_udf_id number(9) := 0;

begin

select function_id
into   l_udf_id
from   ff_functions
where  upper(name) = upper(p_udf_name)
and    business_group_id is null
and    legislation_code = 'US';

return l_udf_id;
     --
     exception
     when no_data_found then
          return 0;
     --
end udf_Exists;
--
----------------------------------------------------------------------------------------
-- Name
--    Delete_udf
-- Purpose
--   removes udf from ff_function_parameters,ff_function_context_usages, ff_functions
-- Arguments
--  p_udf_nam
----------------------------------------------------------------------------------------

PROCEDURE Delete_udf (p_udf_name in varchar2) IS
l_udf_id number(9) := 0;

begin
l_udf_id  := udf_exists(p_udf_name);

if l_udf_id <> 0 then
   delete from ff_function_parameters
   where  function_id = l_udf_id;

   delete from ff_function_context_usages
   where  function_id = l_udf_id;

   delete from ff_functions
   where  function_id = l_udf_id;
end if;

end Delete_udf;

--
----------------------------------------------------------------------------------------
-- Name
--   get_parameter
-- Purpose
--   returns parameters from a parameter list
-- Arguments
--  name
--  parameter_lis
----------------------------------------------------------------------------------------

FUNCTION get_parameter(name in varchar2,
				   end_name in varchar2,
	                  parameter_list varchar2) return varchar2
is
start_ptr number;
end_ptr   number;
token_val ff_archive_items.value%type;
par_value ff_archive_items.value%type;

begin
--
token_val := name||'=';
--
start_ptr := instr(parameter_list, token_val) + length(token_val);
end_ptr := instr(parameter_list, end_name, start_ptr);
--
/* if there are spaces use then length of the string + 1*/
/*
   Bug 1069642: if end_name is passed in as null, end_ptr will
   be null and this will cause substr to not return a value.
   nvl is being used to correct the situation
*/
if nvl(end_ptr, 0) = 0 then
end_ptr := length(parameter_list)+1;
end if;
--
/* Did we find the token */
if instr(parameter_list, token_val) = 0 then
par_value := NULL;
else
par_value := LTRIM(RTRIM(substr(parameter_list, start_ptr, end_ptr - start_ptr)));
end if;
--
return par_value;
--
end get_parameter;

END Pay_Mag_Utils;

/
