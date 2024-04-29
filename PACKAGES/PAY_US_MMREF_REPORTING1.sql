--------------------------------------------------------
--  DDL for Package PAY_US_MMREF_REPORTING1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_MMREF_REPORTING1" AUTHID CURRENT_USER AS
 /* $Header: payusmmrfrec1.pkh 120.0.12000000.1 2007/02/26 05:52:20 sausingh noship $ */
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_us_mmref_reporting

  Purpose
    The purpose of this package is to support the generation of magnetic tape
    in MMREF - 1 Format. This magnetic tapes are for US legilsative requirements
    incorporating magtape resilience and the new end-of-year design.

  Notes
    The generation of each magnetic tape report is a two stage process i.e.
    1. Check if the year end pre-processor has been run for all the GREs
	   and the assignments. If not, then error out without processing further.
    2. Create a payroll action for the report. Identify all the assignments
       to be reported and record an assignment action against the payroll action
       for each one of them.
    3. Run the generic magnetic tape process which will
       drive off the data created in stage two. This will result in the
       production of a structured ascii file which can be transferred to
       magnetic tape and sent to the relevant authority.

  History
  Date        Author   Verion  Bug      Details
  ----------- -------- ------- -------- -------------------------------------
  14-sep-2001 djoshi   115.0            Created
  18-sep-2001 djoshi   115.1            Added the changes for Smart
                                        Archive calls
  20-sep-2001 djoshi   115.2            Added function check_gre_data
                                        and removed all ref. to all tables
  16-nov-2001 djoshi   115.3            Added the changes for State
                                        Magnetic Tapes
  03-dec-2001 djoshi   115.6            Changed the file for dbdrv postion
                                        and employee cursor
  05-dec-2001 djoshi   115.7            Added function to chech state tax rules
  22-jan-2002 djoshi   115.8            Added check_file for GSCC
  14-Nov-2002 ppanda   115.9            Added transfer_locality_code to driving
                                        cursor for Fed and State submitter
                                        The new column added for Local W-2 Mag
                                        changes
  02-Dec-2002 ppanda   115.10           Nocopy hint added to OUT and IN OUT
                                        parameters
  20-Jan-2003 ppanda   115.11  2736928  For PuertoRico a new Employee Cursor
                                        created to have sorting order as Last Name,
                                        First Name, Middle Name, Person_ID
                                        This new sorting order is used due to
                                        generation of Control number for each
                                        employee depending on the starting Control
                                        Number defined at the GRE level.
  15-Nov-2003 tmehra   115.12  2219097  Made changes to mmrf_employer
                                        and mmrf_employee cursor for
                                        FED W2 employment_code requirement
  20-Nov-2003 tmehra   115.13           Changed the parameter name from
                                        EMP_CODE to TRANSFER_EMP_CODE
  26-Nov-2003 tmehra   115.14  2219097  Added a new function for Govt
                                        Employer W2 changes
                                           - get_report_category
  26-Nov-2003 tmehra   115.15           Added two new cursors
                                           - govt_mmrf_employer
                                           - govt_mmrf_employee
  02-Dec-2003 tmehra   115.16           Modified govt_mmrf_employee cursor.
  03-Dec-2003 tmehra   115.17           Modified govt_mmrf_employer cursor.
  28-DEC-2004 ahanda   115.19           Changed employee cursor for performance
  04-JAN-2004 ahanda   115.20           Changed per_assignments_f to
                                        per_all_assignments_f
  =============================================================================*/

  -- 'level_cnt' will allow the cursors to select function results,
  -- whether it is a standard fuction such as to_char or a function
  -- defined in a package (with the correct pragma restriction).
  level_cnt NUMBER;

  --
  -- Sets up the tax unit context for the Submitter
  --
  /* Transmitter for the State MMREF tape  */
  CURSOR state_mmrf_submitter IS
     SELECT 'TAX_UNIT_ID=C' , HOI.organization_id,
            'JURISDICTION_CODE=C', SR.jurisdiction_code,
             'TRANSFER_JD=P', SR.jurisdiction_code,
            'ASSIGNMENT_ID=C' , '-1',
            'DATE_EARNED=C', fnd_date.date_to_canonical(ppa.effective_date),
            'TRANSFER_HIGH_COUNT=P', '0',
            'TRANSFER_SCHOOL_DISTRICT=P', '-1',
            'TRANSFER_COUNTY=P', '-1',
            'TRANSFER_2678_FILER=P', HOI.org_information8,
            'PAYROLL_ACTION_ID=C', PPA.payroll_action_id,
            'BUSINESS_GROUP_ID=C',PPA.business_group_id,
            'TRANSFER_LOCALITY_CODE=P', 'DUMMY'
       FROM pay_state_rules SR,
            hr_organization_information HOI,
            pay_payroll_actions PPA,
            pay_payroll_actions PPA1
      WHERE PPA1.payroll_action_id = pay_magtape_generic.get_parameter_value
                                     ('TRANSFER_PAYROLL_ACTION_ID')
        AND ppa1.effective_date =   ppa.effective_date
        AND ppa1.report_qualifier = sr.state_code
        AND HOI.organization_id =
            pay_magtape_generic.get_parameter_value('TRANSFER_TRANS_LEGAL_CO_ID')
        AND SR.state_code  =
            pay_magtape_generic.get_parameter_value('TRANSFER_STATE')
        AND HOI.org_information_context = 'W2 Reporting Rules'
        AND PPA.report_type = 'YREND'
        AND HOI.ORGANIZATION_ID
                   = substr(PPA.legislative_parameters,
                            instr(PPA.legislative_parameters,
                                  'TRANSFER_GRE=') + length('TRANSFER_GRE='))
        AND to_char(PPA.effective_date,'YYYY')
                   = pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
        AND to_char(PPA.effective_date,'DD-MM') = '31-12';

  /* Context and Parameter Set in the cursor are
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
          TRANSFER_LOCALITY_CODE  (Added for Local Mag Tape changes)
  */
  CURSOR fed_mmrf_submitter IS
     SELECT 'TAX_UNIT_ID=C', HOI.organization_id,
            'JURISDICTION_CODE=C', 'DUMMY_VALUE',
            'TRANSFER_JD=P',  'DUMMY_VALUE',
            'ASSIGNMENT_ID=C'  , '-1',
            'DATE_EARNED=C', fnd_date.date_to_canonical(ppa.effective_date),
            'TRANSFER_HIGH_COUNT=P', '0',
            'TRANSFER_SCHOOL_DISTRICT=P', '-1',
            'TRANSFER_COUNTY=P', '-1',
            'TRANSFER_2678_FILER=P', HOI.org_information8,
            'PAYROLL_ACTION_ID=C',ppa.payroll_action_id, -- payroll_action_id of YREND
            'TRANSFER_LOCALITY_CODE=P', 'DUMMY'
        FROM hr_organization_information HOI,
             pay_payroll_actions PPA
       WHERE HOI.organization_id =
             pay_magtape_generic.get_parameter_value('TRANSFER_TRANS_LEGAL_CO_ID')
         AND pay_magtape_generic.get_parameter_value('TRANSFER_STATE') = 'FED'
         AND HOI.org_information_context = 'W2 Reporting Rules'
         AND PPA.report_type = 'YREND'
         AND HOI.ORGANIZATION_ID
                   = substr(PPA.legislative_parameters,
                            instr(PPA.legislative_parameters,
                                  'TRANSFER_GRE=') + length('TRANSFER_GRE='))
         AND to_char(PPA.effective_date,'YYYY')
                   = pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
         AND to_char(PPA.effective_date,'DD-MM') = '31-12';

  --
  -- Sets up the tax unit context for each employer to be reported on NB. sets
  -- up a parameter holding the tax unit identifier which can then be used by
  -- subsequent cursors to restrict to employees within the employer.
  --
  --
  /* Context and Parameter  in the cursor are
           Payroll_action_id table looks for value related to Year End pre-
           processor while the pay_assignment_actions looks for
           assignment actions of Mag. tapes
        Context :
          TAX_UNIT_ID - Submitter's Tax Unit ID
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
  CURSOR mmrf_employer IS
     SELECT DISTINCT
            'PAYROLL_ACTION_ID=C', ppa.payroll_action_id,
            'TAX_UNIT_ID=C'  , AA.tax_unit_id,
            'TAX_UNIT_ID=P'  , AA.tax_unit_id,
            'TAX_UNIT_NAME=P'  , hou.name,
            'TRANSFER_EMP_CODE=P', 'R'
       FROM hr_all_organization_units hou,
            pay_payroll_actions       ppa,
            pay_assignment_actions    AA
      WHERE AA.payroll_action_id = pay_magtape_generic.get_parameter_value
                                   ('TRANSFER_PAYROLL_ACTION_ID')
        AND ppa.report_type = 'YREND'
        AND to_char(ppa.effective_date,'YYYY')
                   = pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
        AND to_char(ppa.effective_date,'DD-MM') = '31-12'
        AND AA.tax_unit_id
                   = substr(ppa.legislative_parameters,
                            instr(ppa.legislative_parameters,
                                  'TRANSFER_GRE=') + length('TRANSFER_GRE='))
        AND hou.organization_id  = AA.tax_unit_id
     order by hou.name;

  CURSOR mmrf_employer_multi IS
     SELECT DISTINCT
            'PAYROLL_ACTION_ID=C', ppa.payroll_action_id,
            'TAX_UNIT_ID=C'  , AA.tax_unit_id,
            'TAX_UNIT_ID=P'  , AA.tax_unit_id,
            'TAX_UNIT_NAME=P'  , hou.name,
            'TRANSFER_EMP_CODE=P', 'R',
            'TRANSFER_TAX_UNIT_ID=P', AA.tax_unit_id
       FROM hr_all_organization_units hou,
            pay_payroll_actions       ppa,
            pay_assignment_actions    AA
      WHERE AA.payroll_action_id = pay_magtape_generic.get_parameter_value
                                   ('TRANSFER_PAYROLL_ACTION_ID')
        AND ppa.report_type = 'YREND'
        AND to_char(ppa.effective_date,'YYYY')
                   = pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
        AND to_char(ppa.effective_date,'DD-MM') = '31-12'
        AND AA.tax_unit_id
                   = substr(ppa.legislative_parameters,
                            instr(ppa.legislative_parameters,
                                  'TRANSFER_GRE=') + length('TRANSFER_GRE='))
        AND hou.organization_id  = AA.tax_unit_id
     order by hou.name;


  CURSOR govt_mmrf_employer IS
     SELECT DISTINCT
            'PAYROLL_ACTION_ID=C', ppa.payroll_action_id,
            'PAYROLL_ACTION_ID=P', ppa.payroll_action_id,
            'TAX_UNIT_ID=C'  , AA.tax_unit_id,
            'TAX_UNIT_ID=P'  , AA.tax_unit_id,
            'TAX_UNIT_NAME=P', hou.name,
            'TRANSFER_EMP_CODE=P'     , 'R'
       FROM hr_all_organization_units hou,
            pay_payroll_actions       ppa,
            pay_assignment_actions    AA
      WHERE AA.payroll_action_id = pay_magtape_generic.get_parameter_value
                                   ('TRANSFER_PAYROLL_ACTION_ID')
        AND ppa.report_type = 'YREND'
        AND to_char(ppa.effective_date,'YYYY')
                   = pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
        AND to_char(ppa.effective_date,'DD-MM') = '31-12'
        AND AA.tax_unit_id
                   = substr(ppa.legislative_parameters,
                            instr(ppa.legislative_parameters,
                                  'TRANSFER_GRE=') + length('TRANSFER_GRE='))
        AND hou.organization_id  = AA.tax_unit_id
     UNION ALL
     SELECT DISTINCT
            'PAYROLL_ACTION_ID=C', ppa.payroll_action_id,
            'PAYROLL_ACTION_ID=P', ppa.payroll_action_id,
            'TAX_UNIT_ID=C'  , AA.tax_unit_id,
            'TAX_UNIT_ID=P'  , AA.tax_unit_id,
            'TAX_UNIT_NAME=P', hou.name,
            'TRANSFER_EMP_CODE=P'     , 'Q'
       FROM hr_all_organization_units     hou,
            pay_payroll_actions           ppa,
            pay_assignment_actions        AA
      WHERE AA.payroll_action_id = pay_magtape_generic.get_parameter_value
                                   ('TRANSFER_PAYROLL_ACTION_ID')
        AND ppa.report_type = 'YREND'
        AND to_char(ppa.effective_date,'YYYY')
                   = pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
        AND to_char(ppa.effective_date,'DD-MM') = '31-12'
        AND AA.tax_unit_id
                   = substr(ppa.legislative_parameters,
                            instr(ppa.legislative_parameters,
                                  'TRANSFER_GRE=') + length('TRANSFER_GRE='))
        AND hou.organization_id  = AA.tax_unit_id
     order by 8;


  --
  -- Sets up the assignment_action_id, assignment_id, and date_earned contexts
  -- for an employee. The date_earned context is set to be the least of the
  -- end of the period being reported and the maximum end date of the
  -- assignment. This ensures that personal information ie. name etc... is
  -- current relative to the period being reported on.
  --

   CURSOR mmrf_employee_main IS
/*     SELECT 'TRANSFER_ACT_ID=P',
           pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_ACT_ID')
     FROM DUAL;
  */
    SELECT 'TRANSFER_ACT_ID=P', paa.assignment_action_id
    FROM   pay_assignment_actions paa
    WHERE  paa.payroll_action_id =
         pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
     AND paa.tax_unit_id =
     pay_magtape_generic.get_parameter_value('TRANSFER_TAX_UNIT_ID');



  CURSOR mmrf_employee IS
     SELECT 'ASSIGNMENT_ACTION_ID=C', AI.locked_action_id, -- YREND assignment action
            'ASSIGNMENT_ID=C', AA.assignment_id,
            'DATE_EARNED=C', fnd_date.date_to_canonical(pay_magtape_generic.date_earned
                                    (PA.effective_date, AA.assignment_id)),
            'JURISDICTION_CODE=C',pay_magtape_generic.get_parameter_value('TRANSFER_JD'),
            'YE_ASSIGNMENT_ACTION_ID=P',AI.locked_action_id
       FROM per_all_people_f           PE,
            per_all_assignments_f      SS,
            pay_action_interlocks  AI,
            pay_assignment_actions AA,
            pay_payroll_actions    PA
      WHERE PA.payroll_action_id = pay_magtape_generic.get_parameter_value
                                    ('TRANSFER_PAYROLL_ACTION_ID')
        AND AA.payroll_action_id = PA.payroll_action_id
        AND AA.tax_unit_id = pay_magtape_generic.get_parameter_value
                                    ('TAX_UNIT_ID')
        AND AI.locking_action_id  = AA.assignment_action_id
        AND SS.assignment_id     = AA.assignment_id
        AND PE.person_id         = SS.person_id
        AND SS.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_all_assignments_f paf2
                     where paf2.assignment_id = SS.assignment_id
                     and paf2.effective_start_date <= PA.effective_date
                     and paf2.assignment_type = 'E')
        AND SS.effective_end_date >= PA.start_date
        AND SS.assignment_type = 'E'
        AND LEAST(SS.effective_end_date, PA.effective_date)
                between PE.effective_start_date and PE.effective_end_date
     ORDER BY PE.last_name, PE.first_name, PE.middle_names;


  CURSOR govt_mmrf_employee IS
     SELECT 'ASSIGNMENT_ACTION_ID=C', AI.locked_action_id, -- YREND assignment action
            'ASSIGNMENT_ID=C', AA.assignment_id,
            'DATE_EARNED=C', fnd_date.date_to_canonical(pay_magtape_generic.date_earned
                                    (PA.effective_date, AA.assignment_id)),
            'JURISDICTION_CODE=C',pay_magtape_generic.get_parameter_value('TRANSFER_JD'),
            'YE_ASSIGNMENT_ACTION_ID=P',AI.locked_action_id
       FROM per_all_people_f       PE,
            per_all_assignments_f  SS,
            pay_action_interlocks  AI,
            pay_assignment_actions AA,
            pay_assignment_actions paa,
            pay_payroll_actions    PA,
            ff_archive_items       arch,
            ff_user_entities       fue
      WHERE PA.payroll_action_id = pay_magtape_generic.get_parameter_value
                                     ('TRANSFER_PAYROLL_ACTION_ID')
        AND AA.payroll_action_id = PA.payroll_action_id
        AND AA.tax_unit_id = pay_magtape_generic.get_parameter_value
                                     ('TAX_UNIT_ID')
        AND AI.locking_action_id  = AA.assignment_action_id
        AND SS.assignment_id     = AA.assignment_id
        AND PE.person_id         = SS.person_id
        AND SS.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_all_assignments_f paf2
                     where paf2.assignment_id = SS.assignment_id
                     and paf2.effective_start_date <= PA.effective_date
                     and paf2.assignment_type = 'E')
        AND SS.effective_end_date >= PA.start_date
        AND SS.assignment_type = 'E'
        AND LEAST(SS.effective_end_date, PA.effective_date)
                between PE.effective_start_date and PE.effective_end_date
        AND paa.payroll_action_id  = pay_magtape_generic.get_parameter_value
                                       ('PAYROLL_ACTION_ID')
        AND paa.assignment_id      = AA.assignment_id
        AND arch.context1          = paa.assignment_action_id
        AND arch.user_entity_id    = fue.user_entity_id
        AND fue.user_entity_name   = 'A_ASG_GRE_EMPLOYMENT_TYPE_CODE'
        AND arch.value             =  pay_magtape_generic.get_parameter_value
                                       ('TRANSFER_EMP_CODE')
     ORDER BY PE.last_name, PE.first_name, PE.middle_names;


  /* This Cursor Added to fix Bug # 2736928
     Additional Sort Parameter Person_ID added to the Employee Cursor
     This change made to generate serial number */

  CURSOR mmrf_pr_employee IS
     SELECT 'ASSIGNMENT_ACTION_ID=C', AI.locked_action_id, -- YREND assignment action
            'ASSIGNMENT_ID=C', AA.assignment_id,
            'DATE_EARNED=C', fnd_date.date_to_canonical(pay_magtape_generic.date_earned
                               (PA.effective_date, AA.assignment_id)),
            'JURISDICTION_CODE=C',pay_magtape_generic.get_parameter_value('TRANSFER_JD'),
            'YE_ASSIGNMENT_ACTION_ID=P',AI.locked_action_id
       FROM per_all_people_f       PE,
            per_all_assignments_f  SS,
            pay_action_interlocks  AI,
            pay_assignment_actions AA,
            pay_payroll_actions    PA
      WHERE PA.payroll_action_id = pay_magtape_generic.get_parameter_value
                                     ('TRANSFER_PAYROLL_ACTION_ID')
        AND AA.payroll_action_id = PA.payroll_action_id
        AND AA.tax_unit_id = pay_magtape_generic.get_parameter_value
                               ('TAX_UNIT_ID')
        AND AI.locking_action_id  = AA.assignment_action_id
        AND SS.assignment_id     = AA.assignment_id
        AND PE.person_id         = SS.person_id
        AND SS.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_all_assignments_f paf2
                     where paf2.assignment_id = SS.assignment_id
                     and paf2.effective_start_date <= PA.effective_date
                     and paf2.assignment_type = 'E')
        AND SS.effective_end_date >= PA.start_date
        AND SS.assignment_type = 'E'
        AND LEAST(SS.effective_end_date, PA.effective_date)
                between PE.effective_start_date and PE.effective_end_date
     ORDER BY PE.last_name, PE.first_name, PE.middle_names,PE.person_id;


  /* Indiana has multiple RS record. This RS record will Report Locality
     Wages for Employee. We are currently interested in getting only
     the JD code for all Indiana County.
  */
  CURSOR IN_LOCAL_MMRF_EMPLOYEE IS
     SELECT 'JURISDICTION_CODE=C', rtrim(ltrim(faic.context)),
            'TRANSFER_YE_JURISDICTION_CODE=P', ltrim(rtrim(faic.context))
       from ff_archive_items fai,
            ff_contexts fc,  -- JD
            ff_database_items fdi,
            ff_archive_item_contexts faic, -- JD
            pay_assignment_actions paa
      where paa.assignment_action_id
                = pay_magtape_generic.get_parameter_value('YE_ASSIGNMENT_ACTION_ID')
        and paa.assignment_action_id = fai.context1
        and fdi.user_name = 'A_COUNTY_WITHHELD_PER_JD_GRE_YTD'
        and fdi.user_entity_id = fai.user_entity_id
        and faic.archive_item_id = fai.archive_item_id
        and fc.context_name = 'JURISDICTION_CODE'
        and faic.context_id = fc.context_id
        and value <> '0'
        and faic.context like '15%'
     order by faic.context;


  /* Ohio Cursor */
  CURSOR OH_LOCAL_MMRF_EMPLOYEE IS
     SELECT 'JURISDICTION_CODE=C',ltrim(rtrim(faic.context)),
            'TRANSFER_YE_JURISDICTION_CODE=P',ltrim(rtrim(faic.context))
       from ff_archive_items fai,
            ff_contexts fc,  -- JD
            ff_database_items fdi,
            ff_archive_item_contexts faic, -- JD
            pay_assignment_actions paa
      where paa.assignment_action_id =
                 pay_magtape_generic.get_parameter_value('YE_ASSIGNMENT_ACTION_ID')
        and paa.assignment_action_id = fai.context1
        and (fdi.user_name = 'A_SCHOOL_WITHHELD_PER_JD_GRE_YTD' OR
             fdi.user_name = 'A_CITY_WITHHELD_PER_JD_GRE_YTD'   OR
             fdi.user_name = 'A_COUNTY_WITHHELD_PER_JD_GRE_YTD')
        and fdi.user_entity_id = fai.user_entity_id
        and faic.archive_item_id = fai.archive_item_id
        and fc.context_name = 'JURISDICTION_CODE'
        and faic.context_id = fc.context_id
        and value <> '0'
        and faic.context like '36%'
     order by faic.context ;



     CURSOR mmrf_employee_act IS
     SELECT 'TRANSFER_ACT_ID=P',
           pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_ACT_ID'),
            'PAYROLL_ACTION_ID=C',pay_magtape_generic.get_parameter_value
                                    ('TRANSFER_PAYROLL_ACTION_ID'),
            'ASSIGNMENT_ACTION_ID=C', AI.locked_action_id, -- YREND assignment action
            'ASSIGNMENT_ID=C', AA.assignment_id,
            'DATE_EARNED=C', fnd_date.date_to_canonical(pay_magtape_generic.date_earned
                                    (PA.effective_date, AA.assignment_id)),
            'JURISDICTION_CODE=C',pay_magtape_generic.get_parameter_value('TRANSFER_JD'),
            'YE_ASSIGNMENT_ACTION_ID=P',AI.locked_action_id,
            'TAX_UNIT_ID=C',AA.TAX_UNIT_ID
       FROM per_all_people_f           PE,
            per_all_assignments_f      SS,
            pay_action_interlocks  AI,
            pay_assignment_actions AA,
            pay_payroll_actions    PA
      WHERE PA.payroll_action_id = pay_magtape_generic.get_parameter_value
                                    ('TRANSFER_PAYROLL_ACTION_ID')
        AND aa.assignment_action_id =            pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_ACT_ID')
        AND AA.payroll_action_id = PA.payroll_action_id
        AND AI.locking_action_id  = AA.assignment_action_id
        AND SS.assignment_id     = AA.assignment_id
        AND PE.person_id         = SS.person_id
        AND SS.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_all_assignments_f paf2
                     where paf2.assignment_id = SS.assignment_id
                     and paf2.effective_start_date <= PA.effective_date
                     and paf2.assignment_type = 'E')
        AND SS.effective_end_date >= PA.start_date
        AND SS.assignment_type = 'E'
        AND LEAST(SS.effective_end_date, PA.effective_date)
                between PE.effective_start_date and PE.effective_end_date
     ORDER BY aa.tax_unit_id, PE.last_name, PE.first_name, PE.middle_names;




  FUNCTION bal_db_item(p_db_item_name VARCHAR2)
  RETURN NUMBER;

  PROCEDURE get_report_parameters(
	p_pactid    		IN      NUMBER,
	p_year_start		IN OUT	nocopy DATE,
	p_year_end		IN OUT	nocopy DATE,
	p_state_abbrev		IN OUT	nocopy VARCHAR2,
	p_state_code		IN OUT	nocopy VARCHAR2,
	p_report_type		IN OUT	nocopy VARCHAR2,
	p_business_group_id	IN OUT	nocopy NUMBER);

  FUNCTION get_balance_value(
	p_balance_name		VARCHAR2,
	p_tax_unit_id		NUMBER,
	p_state_abbrev		VARCHAR2,
	p_assignment_id		NUMBER,
	p_effective_date	DATE)
  RETURN NUMBER;

  FUNCTION preprocess_check(
	p_pactid 		NUMBER,
	p_year_start		DATE,
	p_year_end		DATE,
	p_business_group_id	NUMBER,
	p_state_abbrev		VARCHAR2,
	p_state_code		VARCHAR2,
	p_report_type		VARCHAR2)
  RETURN BOOLEAN;

  PROCEDURE range_cursor(
	p_pactid        	IN	   NUMBER,
	p_sqlstr        	OUT nocopy VARCHAR2);

  PROCEDURE create_assignment_act(
	p_pactid        	IN NUMBER,
	p_stperson 	        IN NUMBER,
	p_endperson             IN NUMBER,
	p_chunk 	        IN NUMBER );

  FUNCTION check_er_data(
        p_pactid                NUMBER,
        p_ein_user_id           NUMBER)
  RETURN varchar2;


  FUNCTION check_state_er_data(
        p_pactid                NUMBER,
        p_tax_unit              NUMBER,
        p_jurisdictions         varchar2)
  RETURN varchar2;


  PROCEDURE archive_eoy_data(
        p_pactid               IN NUMBER,
        p_tax_id               IN NUMBER );

  PROCEDURE archive_state_eoy_data(
        p_pactid               IN NUMBER,
        p_tax_id               IN NUMBER,
        p_state_code           IN VARCHAR2);

  FUNCTION check_state_data(
        p_payroll_action_id     NUMBER,
        p_transfer_state        varchar2)
  RETURN varchar2;

  FUNCTION get_report_category(p_business_group_id number,
                             p_effective_date    date)
  RETURN varchar2;

  FUNCTION set_application_error(p_state varchar2,
                                 p_error varchar2
                               )
  RETURN varchar2;

END pay_us_mmref_reporting1;

 

/
