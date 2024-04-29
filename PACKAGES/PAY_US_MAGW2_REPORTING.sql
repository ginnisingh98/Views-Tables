--------------------------------------------------------
--  DDL for Package PAY_US_MAGW2_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_MAGW2_REPORTING" AUTHID CURRENT_USER as
 /* $Header: pyyepmw2.pkh 115.13 2002/12/03 03:01:44 ppanda ship $ */
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_us_magw2_reporting

  Purpose
    The purpose of this package is to support the generation of magnetic tape W2
    reports for US legilsative requirements incorporating magtape resilience
	and the new end-of-year design.

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
   25-Jun-98  Vipin Mehta   40.0	 Date created.

   13-Aug-98  Vipin Mehta   40.1	 changed ohstw2_supp and instw2_supp
							 to pick up assignment_action_id
							 from pay_action_interlocks
							 changed  ohstw2_supp and
							 magw2_transmitter to set up an
							 additional parameter
							 (TRANSFER_SCHOOL_DISTRICT) to pass
							 the school district code to
							 W2_TIB4_SUPPLEMENTAL
   11-Jan-99 Vipin Mehta   40.4   Added new parameters to
			 		           magw2_transmitter cursor to support
					           2678 Filing.
   16-jan-99 Vipin Mehta   40.5     Modified magw2_reporting, instw2_supp and
					           ohstw2_supp to fix indiana and ohio

   26-jan-99 VMehta        40.6     Modified w2_high_comp to change
   24-aug-99 djoshi        40.7     Modified ohstw2 to change the table
				                pay_us_arch_mag_county_v to pay_us_acrh_county_sd_v
				                pay_us_arch_mag_city_v to pay_us_arch_mag_city_sd_v
 				                and also changed the state abbv in query from IN
    				                to OH. This is changed for bug 969567
   24-oct-99 djoshi        40.8     changed the oh_in_employee cursor and
				                ohstw2_supp cursor to make them performant.
   22-NOV-99 ahanda       115.5     Took the 110.6 of r11 and made the fnd_date changes.

   24-nov-00 djoshi      115.8      Modified the file for Indiana 'S' record ref. bug
							 1230231.
   10-sep-00 djoshi      115.9      Modified the file for Indiana 'S' record
                                    for persormace

   20-oct-00 djoshi      115.11     Reveted to 115.09
   15-NOV-02 asasthan    115.12     Made file gscc compliant
   02-DEC-02 ppanda      115.13     Made file gscc compliant for nocopy

 ============================================================================*/

 -- 'level_cnt' will allow the cursors to select function results,
 -- whether it is a standard fuction such as to_char or a function
 -- defined in a package (with the correct pragma restriction).

 level_cnt	NUMBER;

 -- Used by Magnetic W2 (TIB4 format).
 --
 -- Sets up the tax unit context for the transmitter
 --
 --

CURSOR magw2_transmitter IS
SELECT 'TAX_UNIT_ID=C' , HOI.organization_id,
       'JURISDICTION_CODE=C', SR.jurisdiction_code,
       'TRANSFER_HIGH_COUNT=P', '0',
       'TRANSFER_SCHOOL_DISTRICT=P', '-1',
       'TRANSFER_COUNTY=P', '-1',
       'TRANSFER_2678_FILER=P', 'N',
       'PAYROLL_ACTION_ID=C', PPA.payroll_action_id
  FROM pay_state_rules SR,
       hr_organization_information HOI,
       pay_payroll_actions PPA
 WHERE HOI.organization_id =
       pay_magtape_generic.get_parameter_value('TRANSFER_TRANS_LEGAL_CO_ID')
   AND SR.state_code  =
	pay_magtape_generic.get_parameter_value('TRANSFER_STATE')
  AND HOI.org_information_context = 'W2 Reporting Rules'
  AND PPA.report_type = 'YREND'
  AND HOI.ORGANIZATION_ID = substr(PPA.legislative_parameters,instr(PPA.legislative_parameters,'TRANSFER_GRE=') + length('TRANSFER_GRE='))
  AND to_char(PPA.effective_date,'YYYY') =
           pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
  AND to_char(PPA.effective_date,'DD-MM') = '31-12'
UNION ALL
SELECT 'TAX_UNIT_ID=C', HOI.organization_id,
  'JURISDICTION_CODE=C', 'DUMMY_VALUE',
  'TRANSFER_HIGH_COUNT=P', '0',
  'TRANSFER_SCHOOL_DISTRICT=P', '-1',
  'TRANSFER_COUNTY=P', '-1',
  'TRANSFER_2678_FILER=P', HOI.org_information8,
  'PAYROLL_ACTION_ID=C',ppa.payroll_action_id -- payroll_action_id of YREND
FROM hr_organization_information HOI,
     pay_payroll_actions PPA
WHERE HOI.organization_id =
 	 pay_magtape_generic.get_parameter_value('TRANSFER_TRANS_LEGAL_CO_ID')
  AND pay_magtape_generic.get_parameter_value('TRANSFER_STATE') = 'FED'
  AND HOI.org_information_context = 'W2 Reporting Rules'
  AND PPA.report_type = 'YREND'
  AND HOI.ORGANIZATION_ID = substr(PPA.legislative_parameters,instr(PPA.legislative_parameters,'TRANSFER_GRE=') + length('TRANSFER_GRE='))
  AND to_char(PPA.effective_date,'YYYY') =
           pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
  AND to_char(PPA.effective_date,'DD-MM') = '31-12';

 --
 -- Used by Magnetic W2 (TIB4 format).
 --
 -- Sets up the tax unit context for each employer to be reported on NB. sets
 -- up a parameter holding the tax unit identifier which can then be used by
 -- subsequent cursors to restrict to employees within the employer.
 --
 --

CURSOR magw2_employer IS
SELECT DISTINCT 'PAYROLL_ACTION_ID=C', ppa.payroll_action_id,
  'TAX_UNIT_ID=C'  , AA.tax_unit_id,
  'TAX_UNIT_ID=P'  , AA.tax_unit_id,
  'TAX_UNIT_NAME=P'  , fai.value
FROM ff_archive_item_contexts  faic,
     ff_archive_items          fai,
     ff_contexts               ffc,
     ff_database_items         fdi,
     pay_payroll_actions       ppa,
     pay_assignment_actions     AA
WHERE AA.payroll_action_id = pay_magtape_generic.get_parameter_value
				   ('TRANSFER_PAYROLL_ACTION_ID')
AND   ppa.report_type = 'YREND'
AND to_char(ppa.effective_date,'YYYY') =
           pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
AND to_char(ppa.effective_date,'DD-MM') = '31-12'
AND   AA.tax_unit_id = substr(ppa.legislative_parameters,instr(ppa.legislative_parameters,'TRANSFER_GRE=') + length('TRANSFER_GRE='))
AND   fdi.user_name = 'A_TAX_UNIT_NAME'
AND   ffc.context_name = 'TAX_UNIT_ID'
AND   ppa.payroll_action_id = fai.context1
AND   fdi.user_entity_id = fai.user_entity_id
AND   fai.archive_item_id = faic.archive_item_id
AND   faic.context_id = ffc.context_id
AND   faic.context = AA.tax_unit_id
order by fai.value;
 --
 -- Used by Magnetic W2 (TIB4 format).
 --
 -- Sets up the assignment_action_id, assignment_id, and date_earned contexts
 -- for an employee. The date_earned context is set to be the least of the
 -- end of the period being reported and the maximum end date of the
 -- assignment. This ensures that personal information ie. name etc... is
 -- current relative to the period being reported on.
 --

CURSOR magw2_employee IS
SELECT 'ASSIGNMENT_ACTION_ID=C', AI.locked_action_id, -- YREND assignment action
  'ASSIGNMENT_ID=C', AA.assignment_id,
  'DATE_EARNED=C', fnd_date.date_to_canonical(pay_magtape_generic.date_earned
			(PA.effective_date, AA.assignment_id))
FROM  per_people_f           PE,
      per_assignments_f      SS,
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

 --
 -- Used by most states for State W2.
 --
 -- Sets up the tax unit context for each employer to be reported on NB. sets
 -- up a parameter holding the tax unit identifier which can then be used by
 -- subsequent cursors to restrict to employees within the employer.  The
 -- payroll action id context is used for the Archive DB Items.
 -- The Date_Earned Context is used for balances with dimensions of
 --  "GRE_JD_QTD"  -- Notably Pennsylvania SUI_EE_GROSS.  Added join to payroll
 --  action table.

CURSOR st_magw2_employer IS
SELECT DISTINCT 'PAYROLL_ACTION_ID=C', PA.payroll_action_id,
                'TAX_UNIT_ID=C'      , AA.tax_unit_id,
                'TAX_UNIT_ID=P'      , AA.tax_unit_id,
                'JURISDICTION_CODE=C', SR.jurisdiction_code,
                'DATE_EARNED=C'      , fnd_date.date_to_canonical(PA.effective_date),
                'BUSINESS_GROUP_ID=C', PA.business_group_id
FROM  pay_state_rules        SR,
      pay_payroll_actions    PA,
      pay_assignment_actions AA,
      pay_payroll_actions        PA1
WHERE  PA1.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
AND  AA.payroll_action_id = pay_magtape_generic.get_parameter_value
		   ('TRANSFER_PAYROLL_ACTION_ID')
  AND  AA.serial_number IS NULL
  AND  PA.report_type = 'YREND'
  AND  AA.tax_unit_id = substr(PA.legislative_parameters,instr(PA.legislative_parameters,'TRANSFER_GRE=') + length('TRANSFER_GRE='))
  AND to_char(PA.effective_date,'YYYY') =
           pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
  AND to_char(PA.effective_date,'DD-MM') = '31-12'
  AND SR.state_code = ltrim(rtrim(PA1.report_qualifier));

 --
 -- Used by Magnetic W2 (TIB4 format).
 --

CURSOR st_magw2_employee IS
SELECT 'ASSIGNMENT_ACTION_ID=C', AI.locked_action_id,
  'ASSIGNMENT_ID=C', AA.assignment_id,
  'DATE_EARNED=C', fnd_date.date_to_canonical(pay_magtape_generic.date_earned
			(PA.effective_date, AA.assignment_id)),
  'JURISDICTION_CODE=C', SR.jurisdiction_code
FROM  per_people_f           PE,
      per_assignments_f      SS,
      pay_state_rules	     SR,
      pay_action_interlocks  AI,
      pay_assignment_actions AA,
      pay_payroll_actions    PA
WHERE PA.payroll_action_id = pay_magtape_generic.get_parameter_value
			('TRANSFER_PAYROLL_ACTION_ID') AND
  AA.payroll_action_id = PA.payroll_action_id AND
  AA.tax_unit_id = pay_magtape_generic.get_parameter_value
			('TAX_UNIT_ID') AND
  AI.locking_action_id  =  AA.assignment_action_id AND
  AA.serial_number IS NULL AND
  SR.state_code = ltrim(rtrim(PA.report_qualifier)) AND
  SS.assignment_id = AA.assignment_id AND
  PE.person_id = SS.person_id AND
  pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id) BETWEEN
			SS.effective_start_date AND SS.effective_end_date AND
  pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id) BETWEEN
			PE.effective_start_date AND PE.effective_end_date
ORDER BY PE.last_name, PE.first_name, PE.middle_names;

 --

CURSOR oh_in_employee IS
SELECT 'ASSIGNMENT_ACTION_ID=C', AI.locked_action_id,
  'ASSIGNMENT_ACTION_ID=P', AI.locking_action_id,
  'ASSIGNMENT_ID=C', AA.assignment_id,
  'DATE_EARNED=C', fnd_date.date_to_canonical(pay_magtape_generic.date_earned
			(PA.effective_date, AA.assignment_id)),
  'YREND_ASSIGNMENT_ACTION_ID=P',AI.locked_action_id,
  'YREND_ASSIGNMENT_ID=P',AA.assignment_id,
  'DATE_EARNED=P', fnd_date.date_to_canonical(pay_magtape_generic.date_earned
                        (PA.effective_date, AA.assignment_id))
FROM  per_people_f           PE,
      per_assignments_f      SS,
      pay_action_interlocks	 AI,
      pay_assignment_actions AA,
      pay_payroll_actions PA
WHERE PA.payroll_action_id = pay_magtape_generic.get_parameter_value
			('TRANSFER_PAYROLL_ACTION_ID') AND
  AA.payroll_action_id = PA.payroll_action_id AND
  AA.tax_unit_id    = pay_magtape_generic.get_parameter_value
			('TAX_UNIT_ID') AND
  AI.locking_action_id  = AA.assignment_action_id AND
  AA.serial_number     IS NULL AND
  SS.assignment_id     = AA.assignment_id AND
  PE.person_id         = SS.person_id AND
  pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id) BETWEEN
			SS.effective_start_date AND SS.effective_end_date AND
  pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id) BETWEEN
			PE.effective_start_date AND PE.effective_end_date
ORDER BY PE.last_name, PE.first_name, PE.middle_names;



CURSOR  instw2_supp
    IS
SELECT  'TRANSFER_ASS_ACTION_ID=C', pay_magtape_generic.get_parameter_value('YREND_ASSIGNMENT_ACTION_ID'),
        'ASSIGNMENT_ACTION_ID=C', pay_magtape_generic.get_parameter_value('YREND_ASSIGNMENT_ACTION_ID'),
        'ASSIGNMENT_ID=C', pay_magtape_generic.get_parameter_value('YREND_ASSIGNMENT_ID'),
        'DATE_EARNED=C', pay_magtape_generic.get_parameter_value('DATE_EARNED'),
        'TRANSFER_COUNTY=P', substr(PLV.jurisdiction,4,3),
        'JURISDICTION_CODE=C', PLV.jurisdiction
FROM    pay_us_w2_locality_v plv
where   plv.assignment_action_id =  pay_magtape_generic.get_parameter_value('YREND_ASSIGNMENT_ACTION_ID')
        and   plv.TAX_UNIT_ID = pay_magtape_generic.get_parameter_value('TAX_UNIT_ID')
        and   plv.tax_type = 'COUNTY'
        and   plv.state_abbrev = 'IN'
        and   W2_BOX_21 > 0

UNION ALL

SELECT  'TRANSFER_ASS_ACTION_ID=C',pay_magtape_generic.get_parameter_value('YREND_ASSIGNMENT_ACTION_ID'),
        'ASSIGNMENT_ACTION_ID=C', pay_magtape_generic.get_parameter_value('YREND_ASSIGNMENT_ACTION_ID'),
        'ASSIGNMENT_ID=C', pay_magtape_generic.get_parameter_value('YREND_ASSIGNMENT_ID'),
        'DATE_EARNED=C',pay_magtape_generic.get_parameter_value('DATE_EARNED'),
        'TRANSFER_COUNTY=P', '-1',
        'JURISDICTION_CODE=C',psv.jurisdiction_code
 FROM   pay_us_arch_mag_state_v PSV
WHERE
        PSV.assignment_action_id =  pay_magtape_generic.get_parameter_value('YREND_ASSIGNMENT_ACTION_ID') AND
        PSV.state_abbrev = 'IN' AND
        ( NOT EXISTS
              (
                SELECT 'y'
                  FROM pay_us_arch_mag_county_v pcv
                 WHERE substr(pcv.jurisdiction_code,1,2) = substr(psv.jurisdiction_code,1,2) AND
                       pcv.assignment_action_id  = pay_magtape_generic.get_parameter_value('YREND_ASSIGNMENT_ACTION_ID')
               )
           OR (0 = (SELECT NVL(sum(W2_BOX_21),0)
                      FROM pay_us_w2_locality_v plv
                     WHERE plv.assignment_action_id =  pay_magtape_generic.get_parameter_value('YREND_ASSIGNMENT_ACTION_ID')
                       AND plv.TAX_UNIT_ID = pay_magtape_generic.get_parameter_value('TAX_UNIT_ID')
                       AND plv.tax_type = 'COUNTY'
                       AND plv.state_abbrev = 'IN'
                       AND substr(plv.jurisdiction,1,2) = substr(PSV.jurisdiction_code,1,2)
                   )
               )
   );
--ORDER BY 12;


--

CURSOR ohstw2_supp IS
SELECT  'ASSIGNMENT_ACTION_ID=C', AA.assignment_action_id,
  'ASSIGNMENT_ID=C', AA.assignment_id,
  'DATE_EARNED=C', fnd_date.date_to_canonical(pay_magtape_generic.date_earned
		(PA.effective_date, AA.assignment_id)),
 'TRANSFER_SCHOOL_DISTRICT=P',substr(PMV.jurisdiction_code,4,5),
  'JURISDICTION_CODE=C', PMV.jurisdiction_code
FROM
  pay_us_states PUS,
  pay_us_arch_mag_county_sd_v PMV,
  pay_payroll_actions PA,
  pay_assignment_actions AA

WHERE
  AA.assignment_action_id = pay_magtape_generic.get_parameter_value('YREND_ASSIGNMENT_ACTION_ID') AND
  AA.payroll_action_id = PA.payroll_action_id AND
  AA.tax_unit_id = pay_magtape_generic.get_parameter_value('TAX_UNIT_ID') AND
  PMV.assignment_action_id = AA.assignment_action_id AND
  substr(PMV.jurisdiction_code,1,2) = pus.state_code AND
  pus.state_abbrev = 'OH'
  AND (EXISTS(
             SELECT 'y'
             FROM  dual
             where hr_us_w2_rep.get_w2_arch_bal(aa.assignment_action_id,'A_SCHOOL_WITHHELD_PER_JD_GRE_YTD',
                                                 aa.tax_unit_id,pmv.jurisdiction_code,8) > 0))
UNION ALL
SELECT  'ASSIGNMENT_ACTION_ID=C', AA.assignment_action_id,
  'ASSIGNMENT_ID=C', AA.assignment_id,
  'DATE_EARNED=C', fnd_date.date_to_canonical(pay_magtape_generic.date_earned
		(PA.effective_date, AA.assignment_id)),
 'TRANSFER_SCHOOL_DISTRICT=P', substr(PMC.jurisdiction_code,4,5),
 'JURISDICTION_CODE=C', PMC.jurisdiction_code
FROM
  pay_us_states PUS,
  pay_us_arch_mag_city_sd_v PMC,
  pay_assignment_actions AA,
  pay_payroll_actions PA
WHERE

  AA.assignment_action_id = pay_magtape_generic.get_parameter_value
		('YREND_ASSIGNMENT_ACTION_ID') AND
AA.payroll_action_id = PA.payroll_action_id AND
  AA.tax_unit_id = pay_magtape_generic.get_parameter_value ('TAX_UNIT_ID') AND
  PMC.assignment_action_id = AA.assignment_action_id AND
  substr(PMC.jurisdiction_code,1,2) = PUS.state_code AND
  PUS.state_abbrev = 'OH'
  AND (EXISTS(
              SELECT 'y'
             FROM  dual
             where hr_us_w2_rep.get_w2_arch_bal(aa.assignment_action_id,'A_SCHOOL_WITHHELD_PER_JD_GRE_YTD',
                                                 aa.tax_unit_id,pmc.jurisdiction_code,8) > 0))
UNION ALL
SELECT  'ASSIGNMENT_ACTION_ID=C', AA.assignment_action_id,
  'ASSIGNMENT_ID=C', AA.assignment_id,
  'DATE_EARNED=C', fnd_date.date_to_canonical(pay_magtape_generic.date_earned
		(PA.effective_date, AA.assignment_id)),
 'TRANSFER_SCHOOL_DISTRICT=P', '-1',
  'JURISDICTION_CODE=C', PSV.jurisdiction_code
FROM
  pay_us_states PUS,
  pay_us_arch_mag_state_v PSV,
  pay_assignment_actions AA,
  pay_payroll_actions PA
WHERE
  AA.assignment_action_id = pay_magtape_generic.get_parameter_value
		('YREND_ASSIGNMENT_ACTION_ID') AND
  AA.payroll_action_id = PA.payroll_action_id AND
  AA.tax_unit_id = pay_magtape_generic.get_parameter_value ('TAX_UNIT_ID') AND
  PSV.assignment_action_id = AA.assignment_action_id AND
  substr(PSV.jurisdiction_code,1,2) = PUS.state_code AND
  PUS.state_abbrev = 'OH'
  AND (
        ( 0 =
                  (SELECT nvl(sum(W2_BOX_21),0)
                  FROM pay_us_w2_locality_v plv
                  where plv.assignment_action_id = AA.assignment_action_id
                  and   plv.TAX_UNIT_ID = pay_magtape_generic.get_parameter_value('TAX_UNIT_ID')
                  and   plv.tax_type = 'COUNTY SCHOOL'
                  and   plv.state_abbrev = 'OH'
                  and   substr(plv.jurisdiction,1,2) = substr(PSV.jurisdiction_code,1,2)))
       or ( 0 =
                  (SELECT nvl(sum(W2_BOX_21),0)
                  FROM pay_us_w2_locality_v plv
                  where plv.assignment_action_id = AA.assignment_action_id
                  and   plv.TAX_UNIT_ID = pay_magtape_generic.get_parameter_value('TAX_UNIT_ID')
                  and   plv.tax_type = 'CITY SCHOOL'
                  and   plv.state_abbrev = 'OH'
                  and   substr(plv.jurisdiction,1,2) = substr(PSV.jurisdiction_code,1,2)))
      )
ORDER BY 10;

--
-- Cursor for handling Highly Compensated People
--

CURSOR w2_high_comp IS
SELECT 'TRANSFER_MESSAGE=P',
 tuv.name || '-' || ppf.full_name||'('||ppf.employee_number||')'||fnd_global.local_chr(10)
FROM per_people_f           ppf,
  per_assignments_f      paf,
  pay_assignment_actions paa,
  hr_tax_units_v tuv,
  pay_payroll_actions    ppa
WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value
	   ('TRANSFER_PAYROLL_ACTION_ID') AND
  paa.payroll_action_id = ppa.payroll_action_id AND
  paa.tax_unit_id = tuv.tax_unit_id and
  paa.assignment_id = paf.assignment_id AND
  paf.person_id = ppf.person_id AND
  ppa.effective_date BETWEEN
		paf.effective_start_date AND paf.effective_end_date AND
  ppa.effective_date BETWEEN
		ppf.effective_start_date AND ppf.effective_end_date AND
  paa.serial_number IS NOT NULL
  order by tuv.name;

 --

FUNCTION bal_db_item
(
	p_db_item_name VARCHAR2
) RETURN NUMBER;

PROCEDURE get_report_parameters
(
	p_pactid    		IN		NUMBER,
	p_year_start		IN OUT	nocopy DATE,
	p_year_end		IN OUT	nocopy DATE,
	p_state_abbrev		IN OUT	nocopy VARCHAR2,
	p_state_code		IN OUT	nocopy VARCHAR2,
	p_report_type		IN OUT	nocopy VARCHAR2,
	p_business_group_id	IN OUT	nocopy NUMBER
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
	p_pactid 				NUMBER,
	p_year_start			DATE,
	p_year_end				DATE,
	p_business_group_id		NUMBER,
	p_state_abbrev			VARCHAR2,
	p_state_code			VARCHAR2,
	p_report_type			VARCHAR2
) RETURN BOOLEAN;

PROCEDURE range_cursor (
	p_pactid	IN	NUMBER,
	p_sqlstr	OUT	nocopy VARCHAR2
);

PROCEDURE create_assignment_act(
	p_pactid 	IN NUMBER,
	p_stperson 	IN NUMBER,
	p_endperson IN NUMBER,
	p_chunk 	IN NUMBER );

END pay_us_magw2_reporting;

 

/
