--------------------------------------------------------
--  DDL for Package PAY_US_MMREF_LOCAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_MMREF_LOCAL" AUTHID CURRENT_USER as
 /* $Header: pyusmmle.pkh 120.0.12000000.1 2007/01/18 02:39:31 appldev noship $ */
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_us_mmref_reporting

  Purpose

    The purpose of this package is to support the generation of local
    Magnetic media in  MMREF - 1 Format. This magnetic tapes are for
    us legilsative requirements. Currently we supprt the CCA and RITA
    Reporting.

  Notes
    The generation of each magnetic tape report is a two stage process i.e.
    1. Check if the year end pre-processor has been run for all the GREs.
       If not, then error out without processing further.
    2. Create a payroll action for the report. Identify all the assignments
       to be reported and record an assignment action against the payroll
       action for each one of them.
    3. Run the generic magnetic tape process which will
       drive off the data created in stage two. This will result in the
       production of a structured ascii file which can be transferred to
       magnetic tape and sent to the relevant authority.


 History
   Date     Author    Verion  Bug           Details
  ---------------------------------------------------------------------------
  22-jan-02 djoshi    115.0                Created
  04-Nov-02 ppanda    115.1                For locality changes made to
                                            get_report_parameters procedure
                                            Cursor lc_mmrf_submitter modified to
                                            have new parameter for State_code and
                                            locality_code
  15-Nov-02 ppanda    115.2                File is gscc compliant
  02-Dec-02 ppanda    115.3                Nocopy hint added to OUT and IN OUT parameters
  28-feb-03 djoshi    115.5                Changed the code for Locals . Cursor
                                           OH_LC_EMPLOYEE was changed.
 ============================================================================*/

 -- 'level_cnt' will allow the cursors to select function results,
 -- whether it is a standard fuction such as to_char or a function
 -- defined in a package (with the correct pragma restriction).

     level_cnt	NUMBER;

 -- Sets up the tax unit context for the Submitter

       /* Context and Parameter Set in the cursor are

          Context :
          --------------------------------------
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
   -- Following two parameters added for New locality
          TRANSFER_LOCALITY_CODE
          TRANSFER_STATE_CODE
 */

/* Transmitter for the Local Megnetic Media in   MMREF Format  */

   CURSOR lc_mmrf_submitter
         IS
     SELECT 'TAX_UNIT_ID=C' , HOI.organization_id,
            'JURISDICTION_CODE=C', SR.jurisdiction_code,
            'TRANSFER_JD=P', SR.jurisdiction_code,
            'ASSIGNMENT_ID=C' , '-1',
            'DATE_EARNED=C', fnd_date.date_to_canonical(ppa.effective_date),
            'TRANSFER_HIGH_COUNT=P', '0',
            'TRANSFER_SCHOOL_DISTRICT=P', '-5',
            'TRANSFER_COUNTY=P', '-1',
            'TRANSFER_2678_FILER=P', HOI.org_information8,
            'PAYROLL_ACTION_ID=C', PPA.payroll_action_id,
            'BUSINESS_GROUP_ID=C',PPA.business_group_id,
            'TRANSFER_LOCALITY_CODE=P',
            pay_us_get_item_data_pkg.GET_CPROG_PARAMETER_VALUE(ppa1.payroll_action_id,
                                                               'LC'),
--            substr(PPA1.legislative_parameters,instr(PPA1.legislative_parameters,'LOCALITY_CODE=')
--                                                       + length('LOCALITY_CODE=')),
            'TRANSFER_STATE_CODE=P', substr(sr.jurisdiction_code,1,2)
       FROM pay_state_rules SR,
            hr_organization_information HOI,
            pay_payroll_actions PPA,
            pay_payroll_actions PPA1
      WHERE PPA1.payroll_action_id = pay_magtape_generic.get_parameter_value
                                     ('TRANSFER_PAYROLL_ACTION_ID')
        AND ppa1.effective_date =   ppa.effective_date
        --AND ppa1.report_qualifier = sr.state_code
        --CPE
        AND substr(ppa1.report_qualifier,1,2) = sr.state_code
        AND HOI.organization_id =
            pay_magtape_generic.get_parameter_value('TRANSFER_TRANS_LEGAL_CO_ID')
        AND SR.state_code  =
            pay_magtape_generic.get_parameter_value('TRANSFER_STATE')
        AND HOI.org_information_context = 'W2 Reporting Rules'
        AND PPA.report_type = 'YREND'
        AND HOI.ORGANIZATION_ID =
            substr(PPA.legislative_parameters,instr(PPA.legislative_parameters,'TRANSFER_GRE=')
             + length('TRANSFER_GRE='))
        AND to_char(PPA.effective_date,'YYYY') =
            pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
        AND to_char(PPA.effective_date,'DD-MM') = '31-12';



       /* Context and Parameter Set in the cursor are

          Context :
          --------------------------------------
          TAX_UNIT_ID       - Tax Unit ID of GRE
          PAYROLL_ACTION_ID - Payroll action Id of Year End Pre-processor

          Parameters :
          TAX_UNIT_ID        - Id of the GRE
          TAX_UNIT_NAME      - Name of GRE
        */

 --
 --
 --

   CURSOR lc_mmrf_employer
       IS
   SELECT DISTINCT 'PAYROLL_ACTION_ID=C', ppa.payroll_action_id,
                   'TAX_UNIT_ID=C'  , AA.tax_unit_id,
                   'TAX_UNIT_ID=P'  , AA.tax_unit_id,
                   'TAX_UNIT_NAME=P'  , hou.name,
                   'TRANSFER_EMP_CODE=P', 'R'
    FROM
          hr_all_organization_units     hou,
          pay_payroll_actions       ppa,
          pay_assignment_actions     AA
    WHERE AA.payroll_action_id = pay_magtape_generic.get_parameter_value
                                   ('TRANSFER_PAYROLL_ACTION_ID')
    AND ppa.report_type = 'YREND'
    AND to_char(ppa.effective_date,'YYYY') =
        pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
    AND to_char(ppa.effective_date,'DD-MM') = '31-12'
    AND  AA.tax_unit_id =
         substr(ppa.legislative_parameters,
                instr(ppa.legislative_parameters,
                'TRANSFER_GRE=') + length('TRANSFER_GRE='))
    AND   hou.organization_id  = AA.tax_unit_id
    order by hou.name;



--
 --
 -- Sets up the assignment_action_id, assignment_id, and date_earned contexts
 -- for an employee. The date_earned context is set to be the least of the
 -- end of the period being reported and the maximum end date of the
 -- assignment. This ensures that personal information ie. name etc... is
 -- current relative to the period being reported on.
 --


   CURSOR lc_mmrf_employee
       IS
   SELECT
         'ASSIGNMENT_ACTION_ID=C', AI.locked_action_id, -- YREND assignment action
          'ASSIGNMENT_ID=C', AA.assignment_id,
          'DATE_EARNED=C',
          fnd_date.date_to_canonical(pay_magtape_generic.date_earned(PA.effective_date,
            AA.assignment_id)),
          'JURISDICTION_CODE=C',
            pay_magtape_generic.get_parameter_value('TRANSFER_JD'),
          'YE_ASSIGNMENT_ACTION_ID=P',AI.locked_action_id
    FROM  per_all_people_f           PE,
          per_all_assignments_f      SS,
          pay_action_interlocks  AI,
          pay_assignment_actions AA,
          pay_payroll_actions    PA
    WHERE PA.payroll_action_id = pay_magtape_generic.get_parameter_value
                        ('TRANSFER_PAYROLL_ACTION_ID') AND
          AA.payroll_action_id = PA.payroll_action_id AND
          AA.tax_unit_id = pay_magtape_generic.get_parameter_value
                        ('TAX_UNIT_ID') AND
          AI.locking_action_id  = AA.assignment_action_id AND
          SS.assignment_id     = AA.assignment_id AND
          PE.person_id         = SS.person_id AND
          pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id) BETWEEN
                        SS.effective_start_date and SS.effective_end_date AND
          pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id) BETWEEN
                        PE.effective_start_date and PE.effective_end_date
    ORDER BY PE.last_name, PE.first_name, PE.middle_names;


/* RITA and CCA Cursor */


CURSOR oh_lc_employee
    IS
SELECT
       'JURISDICTION_CODE=C',ltrim(rtrim(faic.context)),
       'TRANSFER_YE_JURISDICTION_CODE=P',ltrim(rtrim(faic.context)),
       'TRANSFER_YE_REC_TYPE=P','1'
  from
       ff_archive_items fai,
       ff_contexts fc,  -- JD
       ff_database_items fdi,
       ff_archive_item_contexts faic, -- JD
       pay_payroll_actions ppa,
       pay_assignment_actions paa
where
      paa.assignment_action_id =
      pay_magtape_generic.get_parameter_value('YE_ASSIGNMENT_ACTION_ID')
  and paa.assignment_action_id = fai.context1
  and fdi.user_name = 'A_CITY_WITHHELD_PER_JD_GRE_YTD'
  and fdi.user_entity_id = fai.user_entity_id
  and faic.archive_item_id = fai.archive_item_id
  and fc.context_name = 'JURISDICTION_CODE'
  and faic.context_id = fc.context_id
  and value <> '0'
  and paa.payroll_action_id = ppa.payroll_action_id
  and exists
  (
    /* Code has to join like becuase puctif is not
        maintained as truely date tracked table
     */
    SELECT '1'
      FROM pay_us_city_tax_info_f puctif
     WHERE rtrim(ltrim(faic.context)) = puctif.jurisdiction_code
       AND puctif.effective_start_date <  ppa.effective_date
       AND puctif.effective_end_date   >= ppa.effective_date
       AND puctif.city_information1 like
                  pay_magtape_generic.get_parameter_value('TRANSFER_LOCALITY_CODE')||'%'
   )
order by faic.context ;



FUNCTION bal_db_item
(
	p_db_item_name VARCHAR2
) RETURN NUMBER;

PROCEDURE get_report_parameters
(
	p_pactid    		IN      NUMBER,
	p_year_start		IN OUT	nocopy DATE,
	p_year_end		IN OUT	nocopy DATE,
	p_state_abbrev		IN OUT	nocopy VARCHAR2,
	p_state_code		IN OUT	nocopy VARCHAR2,
	p_report_type		IN OUT	nocopy VARCHAR2,
	p_business_group_id	IN OUT	nocopy NUMBER,
-- Following parameter added for Locality Code
        p_locality_code         IN OUT  nocopy VARCHAR2
);

FUNCTION get_balance_value (
	p_balance_name		VARCHAR2,
	p_tax_unit_id		NUMBER,
	p_state_abbrev		VARCHAR2,
	p_assignment_id		NUMBER,
	p_effective_date	DATE
) RETURN NUMBER;

FUNCTION preprocess_check
(
	p_pactid 		NUMBER,
	p_year_start		DATE,
	p_year_end		DATE,
	p_business_group_id	NUMBER,
	p_state_abbrev		VARCHAR2,
	p_state_code		VARCHAR2,
	p_report_type		VARCHAR2
) RETURN BOOLEAN;

PROCEDURE range_cursor (
	p_pactid        	IN	NUMBER,
	p_sqlstr        	OUT	nocopy VARCHAR2
);

PROCEDURE create_assignment_act(
	p_pactid        	IN NUMBER,
	p_stperson 	        IN NUMBER,
	p_endperson             IN NUMBER,
	p_chunk 	        IN NUMBER );

FUNCTION check_er_data (
        p_pactid                NUMBER,
        p_ein_user_id           NUMBER
) RETURN varchar2;


FUNCTION check_state_er_data (
        p_pactid                NUMBER,
        p_tax_unit              NUMBER,
        p_jurisdictions         varchar2
) RETURN varchar2;


PROCEDURE archive_eoy_data(
        p_pactid               IN NUMBER,
        p_tax_id               IN NUMBER );


PROCEDURE archive_state_eoy_data(
        p_pactid               IN NUMBER,
        p_tax_id               IN NUMBER,
        p_state_code           IN VARCHAR2);

FUNCTION check_state_data (
        p_payroll_action_id     NUMBER,
        p_transfer_state        varchar2
) RETURN varchar2;


END pay_us_mmref_local;

 

/
