--------------------------------------------------------
--  DDL for Package PAY_US_W2C_REPORTING_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_W2C_REPORTING_UTILS" AUTHID CURRENT_USER as
 /* $Header: payusw2creputils.pkh 120.0.12010000.1 2008/07/27 21:57:06 appldev ship $ */
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_us_w2c_reporting_utils

  File Name
    payusw2creputils.pkh

  Purpose
    The purpose of this package is to support the generation of magnetic tape
    in MMREF - 2 Format. This magnetic tapes are for US legilsative requirements.


  Notes
    The generation of each Federal W-2c magnetic tape report is a two stage
    process i.e.

    1. Check if the "Employee W-2c Report" is not run for a "W-2c Pre-Process".
       If not, then error out without processing further.

    2. Create a payroll action for the report. Identify all the assignments
       to be reported and record an assignment action against the payroll action
       for each one of them.

    3. Run the generic magnetic tape process which will drive off the data
       created in stage two. This will result in the production of a structured
       ascii file which can be transferred to magnetic tape and sent to the
       relevant authority.

  History
   Date     Author    Verion  Bug           Details
  ---------------------------------------------------------------------------
  22-OCT-03 ppanda    115.0   2587381       Created
  09-DEC-03 ppanda    115.2   3304932       w2c_mmrf2_employee cursor changed to
                                            to avoid duplicate RCW or employee wage record
                                            due to multiple Employee W-2c Report
 ============================================================================*/

 -- 'level_cnt' will allow the cursors to select function results,
 -- whether it is a standard fuction such as to_char or a function
 -- defined in a package (with the correct pragma restriction).

     level_cnt	NUMBER;

 /*  This cursor is for W-2c Magnetic Media Submitter

     Context and Parameter Set in the cursor are

      Context :
          TAX_UNIT_ID       - Submitter's Tax Unit ID
          JURISDICTION_CODE - Set to Dummy Value as This is federal Cursor
          ASSIGNMENT_ID     - Required for call to function - context not used
                              in the for Submitter
          Date Earned       - Always set to Effective date ie. in this case
                              for Mag tapes to 31-DEC-YYYY, in case of SQWL
                              this will be diffrent.
          PAYROLL_ACTION_ID - Payroll action Id of Year End Pre-processor

       Parameters :
          Transfer_HIGH_COUNT
          TRANSFER_SCHOOL_DISTRICT
          TRANSFER_COUNTY
          TRANSFER_2678_FILER

 */

  CURSOR w2c_mmrf2_submitter
         IS
     SELECT 'TAX_UNIT_ID=C',              HOI.organization_id,
            'JURISDICTION_CODE=C',        'DUMMY_VALUE',
            'TRANSFER_JD=P',              'DUMMY_VALUE',
            'ASSIGNMENT_ID=C',            '-1',
            'DATE_EARNED=C',              fnd_date.date_to_canonical(ppa.effective_date),
            'PAYROLL_ACTION_ID=C',        ppa.payroll_action_id, -- payroll_action_id of YREND
            'TRANSFER_HIGH_COUNT=P',      '0',
            'TRANSFER_SCHOOL_DISTRICT=P', '-1',
            'TRANSFER_COUNTY=P',          '-1',
            'TRANSFER_2678_FILER=P',      HOI.org_information8,
            'TRANSFER_LOCALITY_CODE=P',   'DUMMY'
        FROM hr_organization_information HOI,
             pay_payroll_actions PPA
       WHERE HOI.organization_id =
             pay_magtape_generic.get_parameter_value('TRANSFER_TRANS_LEGAL_CO_ID')
         AND pay_magtape_generic.get_parameter_value('TRANSFER_STATE') = 'FED'
         AND HOI.org_information_context = 'W2 Reporting Rules'
         AND PPA.report_type = 'YREND'
         AND HOI.ORGANIZATION_ID =
          substr(PPA.legislative_parameters,instr(PPA.legislative_parameters,'TRANSFER_GRE=') + length('TRANSFER_GRE='))
         AND to_char(PPA.effective_date,'YYYY') =
             pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
         AND to_char(PPA.effective_date,'DD-MM') = '31-12';

 --
 -- Sets up the tax unit context for each employer to be reported on W-2c Mag.
 -- sets up a parameter holding the tax unit identifier which can then be used
 -- by subsequent cursors to restrict to employees within the employer.
 --
 /* Context and Parameter  in the cursor are
    Payroll_action_id table looks for value related to Year End pre-processor
    while the pay_assignment_actions looks for assignment actions of Mag. tapes
     Context :
          TAX_UNIT_ID       - Submitter's Tax Unit ID
          JURISDICTION_CODE - Set to Dummy Value as This is federal Cursor
          ASSIGNMENT_ID     - Required for call to function - context not used
                              in the for Submitter
          Date Earned       - Always set to Effective date ie. in this case
                              for Mag tapes to 31-DEC-YYYY, in case of SQWL
                              this will be diffrent.
          PAYROLL_ACTION_ID - Payroll action Id of Year End Pre-processor

       Parameters :
          TAX_UNIT_ID  -      To be used in subsequent cusrsor
 */

CURSOR w2c_mmrf2_employer IS
SELECT DISTINCT 'PAYROLL_ACTION_ID=C', ppa.payroll_action_id,
                'TAX_UNIT_ID=C',       paa.tax_unit_id,
                'TAX_UNIT_ID=P',       paa.tax_unit_id,
                'TAX_UNIT_NAME=P',     hou.name
FROM
     hr_all_organization_units hou,
     pay_payroll_actions       ppa,
     pay_assignment_actions    paa
WHERE paa.payroll_action_id = pay_magtape_generic.get_parameter_value
                                   ('TRANSFER_PAYROLL_ACTION_ID')
  AND ppa.report_type = 'YREND'
  AND to_char(ppa.effective_date,'YYYY') =
      pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
  AND to_char(ppa.effective_date,'DD-MM') = '31-12'
  AND paa.tax_unit_id =
      substr(ppa.legislative_parameters,instr(ppa.legislative_parameters,'TRANSFER_GRE=') + length('TRANSFER_GRE='))
  AND hou.organization_id  = paa.tax_unit_id
order by hou.name;

 --
 -- Used by W-2c Magnetic Media in MMREF-2 format
 --
 -- Sets up the assignment_action_id, assignment_id, and date_earned contexts
 -- for an employee. The date_earned context is set to be the least of the
 -- end of the period being reported and the maximum end date of the
 -- assignment. This ensures that personal information ie. name etc... is
 -- current relative to the period being reported on.
 --

CURSOR w2c_mmrf2_employee IS
SELECT 'ASSIGNMENT_ACTION_ID=C',    to_number(substr(AA.serial_number,1,15)),    -- latest W2c Pre-Process Assignment Action Id
       'ASSIGNMENT_ID=C',           AA.assignment_id,
       'DATE_EARNED=C',             fnd_date.date_to_canonical(
                                    pay_magtape_generic.date_earned(PA.effective_date, AA.assignment_id)),
       'JURISDICTION_CODE=C',       pay_magtape_generic.get_parameter_value('TRANSFER_JD'),
       'TRANSFER_OLD_ASG_ACTID=P',  to_number(substr(AA.serial_number,16,15)),   -- Originally Reported Assignment Action Id
       'TRANSFER_NEW_ASG_ACTID=P',  to_number(substr(AA.serial_number,1,15)),     -- Corrected Assignment Action Id
       'TRANSFER_TAX_UNIT_ID=P',    AA.tax_unit_id
  FROM per_all_people_f       PE,
       per_all_assignments_f  SS,
       pay_assignment_actions AA,
       pay_payroll_actions    PA
 WHERE PA.payroll_action_id  = pay_magtape_generic.get_parameter_value
                                     ('TRANSFER_PAYROLL_ACTION_ID')
   AND AA.payroll_action_id  = PA.payroll_action_id
   AND AA.tax_unit_id        = pay_magtape_generic.get_parameter_value('TAX_UNIT_ID')
   AND SS.assignment_id      = AA.assignment_id
   AND PE.person_id          = SS.person_id
   AND pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id)
                   BETWEEN SS.effective_start_date and SS.effective_end_date
   AND pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id)
                   BETWEEN PE.effective_start_date and PE.effective_end_date
   AND exists (select 'x'  from pay_action_interlocks  pai,
                                pay_assignment_actions paa1,
                                pay_payroll_actions    ppa1
                where paa1.assignment_action_id = AA.assignment_action_id
                  and paa1.assignment_action_id = pai.locking_action_id
                  and ppa1.payroll_action_id    = paa1.payroll_action_id)
 ORDER BY PE.last_name, PE.first_name, PE.middle_names;


FUNCTION bal_db_item (p_db_item_name IN VARCHAR2
                     ) RETURN NUMBER;

PROCEDURE get_payroll_action_info
                               (p_payroll_action_id     in      number,
                                p_start_date            in out  nocopy date,
                                p_end_date              in out  nocopy date,
                                p_report_type           in out  nocopy varchar2,
                                p_report_qualifier      in out  nocopy varchar2,
                                p_business_group_id     in out  nocopy number
                               );


FUNCTION get_balance_value (p_balance_name		    IN VARCHAR2,
                        	p_tax_unit_id		    IN NUMBER,
                        	p_state_abbrev		    IN VARCHAR2,
                        	p_assignment_id		    IN NUMBER,
                        	p_effective_date	    IN DATE
                           ) RETURN NUMBER;

PROCEDURE get_eoy_action_info(p_eoy_effective_date in         date
                             ,p_eoy_tax_unit_id    in         number
                             ,p_assignment_id      in         number
                             ,p_eoy_pactid         out nocopy number
                             ,p_eoy_asg_actid      out nocopy number
                             );

FUNCTION preprocess_check  (p_pactid 		    IN NUMBER,
                            p_year_start	    IN DATE,
                            p_year_end		    IN DATE,
                            p_business_group_id	    IN NUMBER
                           ) RETURN BOOLEAN;

 /*******************************************************************
  ** Range Code to pick all the distinct assignment_ids
  ** that need to be marked as submitted to governement.
  *******************************************************************/
  PROCEDURE w2c_mag_range_cursor( p_payroll_action_id  in         number
                                 ,p_sqlstr             out nocopy varchar2);

  /*******************************************************************
  ** Action Creation Code to create assignment actions for all the
  ** the assignment_ids that need to be marked as submitted to governement
  *******************************************************************/
  PROCEDURE w2c_mag_action_creation( p_payroll_action_id    in number
                                    ,p_start_person_id      in number
                                    ,p_end_person_id        in number
                                    ,p_chunk                in number);

END pay_us_w2c_reporting_utils;

/
