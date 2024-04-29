--------------------------------------------------------
--  DDL for Package PAY_US_MMREF_LOCAL_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_MMREF_LOCAL_XML" AUTHID CURRENT_USER AS
/* $Header: payusw2mmref1xml.pkh 120.0.12010000.3 2009/01/04 17:58:52 svannian ship $ */

/*
 ===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
 Name
		pay_us_mmref_local_xml
 File
                payusw2mmref1xml.pkh

  Purpose

    The purpose of this package is to support the generation of XML for the process
    Local W-2 Generic MMREF-1. This package includes all the cursors, procedures and functions
    used to comply with the payroll CORE multi-thtread enhancement architecture.

    Currently this is not meant for any specific locality magnetic tape.

  Notes
    The generation of each magnetic tape report is a two stage process i.e.
    1.  Check if the year end pre-processor has been run for all the GREs. If not, then error
         out without processing further.
    2.  Create a payroll action for the report. Identify all the assignments to be reported and record
         an assignment action against the payroll action for each one of them.
    3.  Run the "Local W-2 Generic MMREF-1 XML" process to use this package.


 History
 Date                 Author          Verion       Bug         Details
 ============================================================================
 07-NOV-2006   PPANDA     115.0                        Initial Version Created
 02-JAN-2009   SVANNIAN   115.3                        Changed the  local_w2_xml_employee cursor to pick
                                                       up employees with only SD taxes also.
                                                       New Procedure added to check for NON PA Earnings/Withheld.
 ============================================================================
*/

 -- 'level_cnt' will allow the cursors to select function results,
 -- whether it is a standard fuction such as to_char or a function
 -- defined in a package (with the correct pragma restriction).

 level_cnt	NUMBER;

 -- Sets up the tax unit context for the Submitter

 /* Context and Parameter Set in the cursor are

          Context :
          --------------------------------------
          PAYROLL_ACTION_ID - Payroll action Id of Year End Pre-processor
          TAX_UNIT_ID                - Submitter's Tax Unit ID
          ASSIGNMENT_ID           - Required for call to function - context not used
                                                     in the for Submitter
          DATE EARNED              - Always set to Effective date ie. in this case
                                                     for Mag tapes to 31-DEC-YYYY, in case of SQWL
                                                     this will be diffrent.
          Parameters :
          TRANSFER_2678_FILER
   -- Following two parameters added for New locality
          TRANSFER_LOCALITY_CODE
          TRANSFER_STATE_CODE
 */

/* Transmitter for the Local Megnetic Media in   MMREF Format  */

   CURSOR local_w2_xml_transmitter
         IS
     SELECT	'PAYROLL_ACTION_ID=P',		PPA.payroll_action_id,
                        'TR_TAX_UNIT_ID=P' ,			HOI.organization_id,
			'TR_DATE_EARNED=P',		PPA.effective_date,
			'TRANSFER_2678_FILER=P',	HOI.org_information8,
			'BUSINESS_GROUP_ID=P',		PPA.business_group_id,
			'TRANSFER_LOCALITY_CODE=P',
					pay_us_get_item_data_pkg.GET_CPROG_PARAMETER_VALUE(ppa1.payroll_action_id,
																		    'LC'),
			'TRANSFER_STATE_CODE=P', substr(sr.jurisdiction_code,1,2),
			'ROOT_XML_TAG=P',			'<LOCAL_W2_EXTRACT>'
       FROM	pay_state_rules			SR,
			hr_organization_information	HOI,
			pay_payroll_actions		PPA,
			pay_payroll_actions		PPA1
      WHERE PPA1.payroll_action_id	= pay_magtape_generic.get_parameter_value
								('TRANSFER_PAYROLL_ACTION_ID')
           AND ppa1.effective_date		=   ppa.effective_date
	   AND ppa1.report_qualifier		=   'LOCAL'
	   AND HOI.organization_id		=
                         pay_magtape_generic.get_parameter_value('TRANSFER_TRANS_LEGAL_CO_ID')
           AND SR.state_code			=
                          pay_magtape_generic.get_parameter_value('TRANSFER_STATE')
           AND HOI.org_information_context = 'W2 Reporting Rules'
           AND PPA.report_type			= 'YREND'
           AND HOI.ORGANIZATION_ID	 =
			substr(PPA.legislative_parameters,instr(PPA.legislative_parameters,'TRANSFER_GRE=')
				+ length('TRANSFER_GRE='))
           AND to_char(PPA.effective_date,'YYYY') =
			 pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
           AND to_char(PPA.effective_date,'DD-MM') = '31-12';

      /* Context and Parameter Set in the cursor are
          Parameters :
          ----------------------------------------------------
          TAX_UNIT_ID			- Tax Unit ID of GRE
          PAYROLL_ACTION_ID	- Payroll action Id of Year End Pre-processor
          TAX_UNIT_NAME		- Name of GRE
      */
 --
   CURSOR local_w2_xml_Employer
   IS
   SELECT DISTINCT
                   'PAYROLL_ACTION_ID=P',	ppa.payroll_action_id,
                   'TAX_UNIT_ID=P'  ,			AA.tax_unit_id,
                   'TAX_UNIT_NAME=P',		hou.name
     FROM	 hr_all_organization_units	hou,
		 pay_payroll_actions		ppa,
	 	 pay_assignment_actions	aa
    WHERE aa.payroll_action_id		= pay_magtape_generic.get_parameter_value
								('TRANSFER_PAYROLL_ACTION_ID')
         AND ppa.report_type		= 'YREND'
         AND to_char(ppa.effective_date, 'YYYY') =
                  pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
         AND to_char(ppa.effective_date,'DD-MM') = '31-12'
         AND aa.tax_unit_id			= substr(ppa.legislative_parameters,
								instr(ppa.legislative_parameters,
								'TRANSFER_GRE=') + length('TRANSFER_GRE='))
         AND hou.organization_id		= AA.tax_unit_id
    ORDER BY hou.name;
 --
 --
 -- Sets up the assignment_action_id, assignment_id, and date_earned contexts
 -- for an employee. The date_earned context is set to be the least of the
 -- end of the period being reported and the maximum end date of the
 -- assignment. This ensures that personal information ie. name etc... is
 -- current relative to the period being reported on.
 --
   CURSOR local_w2_xml_employee
       IS
   SELECT DISTINCT
	'TRANSFER_ACT_ID=P', 		AA.assignment_action_id
    FROM	ff_archive_items			FAI,
		ff_contexts				FC,  -- JD
		ff_database_items			FDI,
		ff_archive_item_contexts		FAIC,
		per_all_people_f			PE,
		per_all_assignments_f		SS,
		pay_action_interlocks		AI,
		pay_assignment_actions		AA1,	-- for YE Archiver Assignment Actions
		pay_assignment_actions		AA,
		pay_payroll_actions			PA
    WHERE PA.payroll_action_id		= pay_magtape_generic.get_parameter_value
				                                 ('TRANSFER_PAYROLL_ACTION_ID')
	AND AA.payroll_action_id		= PA.payroll_action_id
	AND AI.locking_action_id		= AA.assignment_action_id
        AND AA.tax_unit_id			= pay_magtape_generic.get_parameter_value
                                                                   ('TAX_UNIT_ID')
	AND SS.assignment_id			= AA.assignment_id
	AND PE.person_id				= SS.person_id
	AND pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id)
	               BETWEEN SS.effective_start_date and SS.effective_end_date
	AND pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id)
	               BETWEEN PE.effective_start_date and PE.effective_end_date
	AND AI.locked_action_id		= fai.context1
	AND AI.locked_action_id		= AA1.assignment_action_id
	AND fdi.user_name				= 'A_CITY_WITHHELD_PER_JD_GRE_YTD'
	AND fdi.user_entity_id			= fai.user_entity_id
	AND faic.archive_item_id			= fai.archive_item_id
	AND fc.context_name			= 'JURISDICTION_CODE'
	AND faic.context_id				= fc.context_id
	AND substr(rtrim(ltrim(faic.context)),1,2) =
               pay_magtape_generic.get_parameter_value('TRANSFER_STATE_CODE')
	AND value					<> '0'
	AND ( pay_magtape_generic.get_parameter_value('TRANSFER_LOCALITY_CODE') = 'NULL'
                OR
		( pay_magtape_generic.get_parameter_value('TRANSFER_LOCALITY_CODE') <> 'NULL'
		  AND  EXISTS
			(    SELECT '1'
				FROM pay_us_city_tax_info_f puctif
			      WHERE substr(rtrim(ltrim(faic.context)),1,2)||'-000-'||substr(rtrim(ltrim(faic.context)),8,4)   =
					     substr(puctif.jurisdiction_code,1,2)||'-000-'||substr(puctif.jurisdiction_code,8,4)
				AND puctif.effective_start_date <  PA.effective_date
			        AND puctif.effective_end_date   >= PA.effective_date
			        AND substr(puctif.jurisdiction_code,1,2)||'-000-'||substr(puctif.jurisdiction_code,8,4) =
                                         substr(pay_magtape_generic.get_parameter_value('TRANSFER_LOCALITY_CODE'),1,2) ||'-000-'||
					 substr(pay_magtape_generic.get_parameter_value('TRANSFER_LOCALITY_CODE'),8,11)
                              )
	                )
                )
    union all
    SELECT DISTINCT
	  'TRANSFER_ACT_ID=P', 		AA.assignment_action_id
    FROM	ff_archive_items			FAI,
		ff_contexts				FC,  -- JD
		ff_database_items			FDI,
		ff_archive_item_contexts		FAIC,
		per_all_people_f			PE,
		per_all_assignments_f		SS,
		pay_action_interlocks		AI,
		pay_assignment_actions		AA1,	-- for YE Archiver Assignment Actions
		pay_assignment_actions		AA,
		pay_payroll_actions			PA
    WHERE PA.payroll_action_id		= pay_magtape_generic.get_parameter_value
				                                 ('TRANSFER_PAYROLL_ACTION_ID')
	  AND AA.payroll_action_id		= PA.payroll_action_id
	  AND AI.locking_action_id		= AA.assignment_action_id
        AND AA.tax_unit_id			= pay_magtape_generic.get_parameter_value
                                                                   ('TAX_UNIT_ID')
	  AND SS.assignment_id			= AA.assignment_id
	  AND PE.person_id				= SS.person_id
	  AND pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id)
	               BETWEEN SS.effective_start_date and SS.effective_end_date
	  AND pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id)
	               BETWEEN PE.effective_start_date and PE.effective_end_date
	  AND AI.locked_action_id		= fai.context1
	  AND AI.locked_action_id		= AA1.assignment_action_id
	  AND fdi.user_name				= 'A_SCHOOL_WITHHELD_PER_JD_GRE_YTD'
	  AND fdi.user_entity_id			= fai.user_entity_id
	  AND faic.archive_item_id			= fai.archive_item_id
	  AND fc.context_name			= 'JURISDICTION_CODE'
	  AND faic.context_id				= fc.context_id
	  AND substr(rtrim(ltrim(faic.context)),1,2) =
               pay_magtape_generic.get_parameter_value('TRANSFER_STATE_CODE')
	  AND value					<> '0'
	  AND ( pay_magtape_generic.get_parameter_value('TRANSFER_LOCALITY_CODE') = 'NULL'
                OR
		( pay_magtape_generic.get_parameter_value('TRANSFER_LOCALITY_CODE') <> 'NULL'
		  AND  EXISTS
			(    SELECT '1'
			 from PAY_US_CITY_SCHOOL_DSTS puctif
                                                WHERE
                                                puctif.state_code = pay_magtape_generic.get_parameter_value('TRANSFER_STATE_CODE')
                                                and puctif.state_code ||'-'||
					                            puctif.county_code || '-'|| puctif.city_code = pay_magtape_generic.get_parameter_value('TRANSFER_LOCALITY_CODE')
					                            and pay_magtape_generic.get_parameter_value('TRANSFER_STATE_CODE') || '-'|| puctif.school_dst_code = ltrim(rtrim(faic.context))
                              )
	                )
                )
                ;

/*   CURSOR local_w2_xml_employee
       IS
   SELECT DISTINCT
	'TRANSFER_ACT_ID=P', 			AA.assignment_action_id,
	'YE_ASSIGNMENT_ACTION_ID=P',	AA1.assignment_action_id,  -- YREND assignment action
	'YE_TAX_UNIT_ID=P',				AA1.TAX_UNIT_ID,
	'EE_ASSIGNMENT_ID=P',			AA.assignment_id,
	'EE_DATE_EARNED=P', 			pay_magtape_generic.date_earned(PA.effective_date,
													                     AA.assignment_id),
	'EE_LOCALITY_JD_CODE=P', 	substr(ltrim(rtrim(faic.context)),1,2)||'-000-'||substr(ltrim(rtrim(faic.context)),8,4)
    FROM	ff_archive_items			FAI,
		ff_contexts				FC,  -- JD
		ff_database_items			FDI,
		ff_archive_item_contexts		FAIC,
		per_all_people_f			PE,
		per_all_assignments_f		SS,
		pay_action_interlocks		AI,
		pay_assignment_actions		AA1,	-- for YE Archiver Assignment Actions
		pay_assignment_actions		AA,
		pay_payroll_actions			PA
    WHERE PA.payroll_action_id		= pay_magtape_generic.get_parameter_value
				                                 ('TRANSFER_PAYROLL_ACTION_ID')
         AND AA.payroll_action_id		= PA.payroll_action_id
	 AND AI.locking_action_id		= AA.assignment_action_id
	 AND SS.assignment_id			= AA.assignment_id
	 AND PE.person_id				= SS.person_id
	 AND pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id)
	               BETWEEN SS.effective_start_date and SS.effective_end_date
	 AND pay_magtape_generic.date_earned(PA.effective_date,AA.assignment_id)
	               BETWEEN PE.effective_start_date and PE.effective_end_date
      AND AI.locked_action_id			= fai.context1
      AND AI.locked_action_id			= AA1.assignment_action_id
      AND fdi.user_name				= 'A_CITY_WITHHELD_PER_JD_GRE_YTD'
      AND fdi.user_entity_id			= fai.user_entity_id
      AND faic.archive_item_id			= fai.archive_item_id
      AND fc.context_name			= 'JURISDICTION_CODE'
      AND faic.context_id				= fc.context_id
      AND substr(rtrim(ltrim(faic.context)),1,2) =
               substr(pay_magtape_generic.get_parameter_value('TRANSFER_LOCALITY_CODE'),1,2)
      AND value					<> '0'
      AND ( pay_magtape_generic.get_parameter_value('TRANSFER_LOCALITY_CODE') IS NULL
                OR   ( pay_magtape_generic.get_parameter_value('TRANSFER_LOCALITY_CODE') IS NOT NULL
                          AND  EXISTS
                              (    SELECT '1'
			              FROM pay_us_city_tax_info_f puctif
		                   WHERE substr(rtrim(ltrim(faic.context)),1,2)||'-000-'||substr(rtrim(ltrim(faic.context)),8,4)   =
				       	         substr(puctif.jurisdiction_code,1,2)||'-000-'||substr(puctif.jurisdiction_code,8,4)
			                AND puctif.effective_start_date <  PA.effective_date
			                AND puctif.effective_end_date   >= PA.effective_date
			                AND substr(puctif.jurisdiction_code,1,2)||'-000-'||substr(puctif.jurisdiction_code,8,4) =
                                                 substr(pay_magtape_generic.get_parameter_value('TRANSFER_LOCALITY_CODE'),1,2) ||'-000-'||
					         substr(pay_magtape_generic.get_parameter_value('TRANSFER_LOCALITY_CODE'),8,11)
                              )
	                  )
                );
*/

  CURSOR local_w2_xml_curr_act_id  IS
     SELECT 'TRANSFER_ACT_ID=P',
		    pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
     FROM DUAL;

CURSOR GET_XML_VER IS
    SELECT 'ROOT_XML_TAG=P',
           '<LOCAL_MAG>',
           'PAYROLL_ACTION_ID=P',
           pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_PAYROLL_ACTION_ID')
      FROM dual;

FUNCTION bal_db_item
(
    p_db_item_name VARCHAR2
)   RETURN NUMBER;

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
	p_balance_name	VARCHAR2,
	p_tax_unit_id		NUMBER,
	p_state_abbrev	VARCHAR2,
	p_assignment_id	NUMBER,
	p_effective_date	DATE
) RETURN NUMBER;

  /****************************************************************************
    Name        : RANGE_CURSOR
    Description : This procedure prepares range of persons to be processed for process
                        Local YearEnd Interface Extract
  *****************************************************************************/
PROCEDURE range_cursor (
	p_pactid        	IN	NUMBER,
	p_sqlstr        	OUT	nocopy VARCHAR2
);


PROCEDURE create_assignment_act(
	p_pactid        	IN NUMBER,
	p_stperson 	IN NUMBER,
	p_endperson    IN NUMBER,
	p_chunk 	        IN NUMBER );

CURSOR LOCAL_CURR_ACT_ID IS
     SELECT 'TRANSFER_ACT_ID=P',
                     pay_magtape_generic.get_parameter_value( 'TRANSFER_ACT_ID' )
        FROM DUAL;

CURSOR LOCAL_MAG_ASG_ACT IS
    SELECT  'TRANSFER_ACT_ID=P',  paa.assignment_action_id
      FROM pay_assignment_actions paa
     WHERE payroll_action_id = pay_magtape_generic.get_parameter_value(
                                                                   'TRANSFER_PAYROLL_ACTION_ID');
--
-- Follwing Procedures are used for constructing XML for Submitter or RA  Record
--
PROCEDURE transmitter_record_start;

PROCEDURE transmitter_record_end;

--
-- Follwing Procedures are used for constructing XML for Employer or RE Record
--
PROCEDURE local_w2_xml_employer_start;

PROCEDURE local_w2_xml_employer_end;

--
-- Follwing Procedures are used for constructing XML for Employee
--
PROCEDURE local_w2_xml_employee_build;


 /****************************************************************************
    Name        : WRITE_TO_MAGTAPE_LOB
    Description : This procedure appends passed BLOB parameter to
                  pay_mag_tape.g_blob_value
  *****************************************************************************/

  PROCEDURE WRITE_TO_MAGTAPE_LOB(p_blob BLOB);

  /****************************************************************************
    Name        : WRITE_TO_MAGTAPE_LOB
    Description : This procedure appends passed varchar2 parameter to
                  pay_mag_tape.g_blob_value
  *****************************************************************************/

  PROCEDURE WRITE_TO_MAGTAPE_LOB(p_data varchar2);

  FUNCTION GET_PARAMETER(name		IN VARCHAR2,
						parameter_list	IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE local_non_pa_emp_data(p_pactid IN varchar2,
                                p_assignment_id IN varchar2 ,
                                on_visa in out nocopy varchar2,
                                non_pa_res in out nocopy varchar2 ,
                                p_reporting_year In varchar2);

END pay_us_mmref_local_xml;

/
