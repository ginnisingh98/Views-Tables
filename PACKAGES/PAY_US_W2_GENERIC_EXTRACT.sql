--------------------------------------------------------
--  DDL for Package PAY_US_W2_GENERIC_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_W2_GENERIC_EXTRACT" AUTHID CURRENT_USER as
/* $Header: payusw2genxtract.pkh 120.0.12010000.3 2009/01/04 17:56:48 svannian ship $  */
 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
		PAY_US_W2_GENERIC_EXTRACT

  File
		payusw2genxtract.pkh

  Purpose
		The purpose of this package is to support the YearEnd Generic Interface Extract Process
		This package to include generic dtabase package components may be used for various
                YearEnd process for Extractiing archived Data, Validating and constructing XML element

  Notes

  History

   Date          User Id       Version    Description
   ============================================================================
   08-Nov-06  ppanda        115.0      Initial Version Created
   02-Jan-09  svannian      115.1      Non PA Earning/Withheld tags added.


   ============================================================================*/
 -- Global Variable

    g_number	NUMBER;

 /*******************************************************************
  ** PL/SQL Record to store the archived values for Employee
  *******************************************************************/
  TYPE fed_employee_record IS RECORD
   ( ASSIGNMENT_ACTION_ID			NUMBER
    ,EE_TAX_YEAR					NUMBER
    ,EE_TAX_UNIT_ID					NUMBER
    ,EE_ASSIGNMENT_ID				NUMBER
    ,EE_ASSIGNMENT_NUMBER		VARCHAR2(200)
    ,EE_EMPLOYEE_NUMBER			VARCHAR2(200)
    ,EE_SSN						VARCHAR2(200)
    ,EE_FIRST_NAME					VARCHAR2(200)
    ,EE_MIDDLE_INITIAL				VARCHAR2(200)
    ,EE_LAST_NAME					VARCHAR2(200)
    ,EE_SUFFIX						VARCHAR2(200)
    ,EE_LOCATION_ADDRESS			VARCHAR2(200)
    ,EE_DELIVERY_ADDRESS			VARCHAR2(200)
    ,EE_CITY						VARCHAR2(200)
    ,EE_STATE_ABBREVIATION			VARCHAR2(200)
    ,EE_ZIP_CODE					VARCHAR2(200)
    ,EE_ZIP_CODE_EXTENSION			VARCHAR2(200)
    ,EE_FOREIGN_STATE_PROVINCE	VARCHAR2(200)
    ,EE_FOREIGN_POSTAL_CODE		VARCHAR2(200)
    ,EE_COUNTRY_CODE				VARCHAR2(200)
    ,FIT_GROSS_WAGES				VARCHAR2(200)    -- wages, tips and other compensation
    ,FIT_WITHHELD					VARCHAR2(200)    -- FIT withheld
    ,SS_WAGES						VARCHAR2(200)    -- SS Wages
    ,SS_TAX_WITHHELD				VARCHAR2(200)    -- SS Tax withheld
    ,MEDICARE_WAGES_TIPS			VARCHAR2(200)    -- Medicare Wages/Tips
    ,MEDICARE_TAX_WITHHELD			VARCHAR2(200)    -- Medicare Tax withheld
    ,SS_TIPS						VARCHAR2(200)    -- Social Security Tips
    ,EIC_ADVANCE					VARCHAR2(200)    -- Advanced EIC
    ,W2_DEPENDENT_CARE			VARCHAR2(200)    -- Dependent Care benefits
    ,W2_401K						VARCHAR2(200)    -- deferred compensation contributions to section 401(K)
    ,W2_403B						VARCHAR2(200)    -- deferred compensation contributions to section 403(b)
    ,W2_408K						VARCHAR2(200)    -- deferred compensation contributions to section 408(K)(6)
    ,W2_457						VARCHAR2(200)    -- deferred compensation contributions to section 457(b)
    ,W2_501C						VARCHAR2(200)    -- deferred compensation contributions to section 501(c)(18)(D)
    ,W2_MILITARY_HOUSING			VARCHAR2(200)    -- Military employees basic quarters, subsistence and combat pay
    ,W2_NONQUAL_457				VARCHAR2(200)    -- nonqualified plan section 457 distributions or contributions
    ,W2_HSA						VARCHAR2(200)    -- nonqualified plan not section 457 distributions or contributions
    ,NON_QUAL_NOT_457				VARCHAR2(200)    -- employer cost of premiums for GTL over $50000
    ,W2_NONTAX_COMBAT			VARCHAR2(200)    -- income from the exercise of nonstatutory stock options
    ,W2_GROUP_TERM_LIFE			VARCHAR2(200)    -- ER Health Savings Account
    ,W2_NONQUAL_STOCK			VARCHAR2(200)    -- Nontaxable Combat Pay
    ,W2_NONQUAL_DEF_COMP			VARCHAR2(200)    -- Deferred compensation contributions
    ,W2_ROTH_401K					VARCHAR2(200)    -- Designated Roth Contributions to a section 401(k) plan
    ,W2_ROTH_403B					VARCHAR2(200)    -- Designated Roth Contributions Under a section 403(b) Salary Reduction Agreement
    ,W2_ASG_STATUTORY_EMPLOYEE	VARCHAR2(200)
    ,RETIREMENT_PLAN_INDICATOR		VARCHAR2(200)
    ,W2_TP_SICK_PAY_IND			VARCHAR2(200)
  --
  -- Puertorico based Data
  --
    ,RO_RECORD_IDENTIFIER			VARCHAR2(200)
    ,RO_W2_BOX_8					VARCHAR2(200)    -- allocated tips
    ,RO_UNCOLLECTED_TAX_ON_TIPS	VARCHAR2(200)    -- uncollected employee tax on tips
    ,RO_W2_MSA					VARCHAR2(200)    -- Medical Savings Account
    ,RO_W2_408P					VARCHAR2(200)    -- Simple Retirement Account
    ,RO_W2_ADOPTION				VARCHAR2(200)    -- Qualified adoption expenses
    ,RO_W2_UNCOLL_SS_GTL			VARCHAR2(200)    -- uncollected social security or RRTA tax on GTL insurance over $50000
    ,RO_W2_UNCOLL_MED_GTL			VARCHAR2(200)    -- uncollected medicare tax on GTL insurance over $50,000
    ,RO_W2_409A_NONQUAL_INCOM		VARCHAR2(200)    -- 409A income
    ,RO_CIVIL_STATUS				VARCHAR2(200)
    ,RO_SPOUSE_SSN				VARCHAR2(200)
    ,RO_WAGES_SUBJ_PR_TAX			VARCHAR2(200)
    ,RO_COMM_SUBJ_PR_TAX			VARCHAR2(200)
    ,RO_ALLOWANCE_SUBJ_PR_TAX		VARCHAR2(200)
    ,RO_TIPS_SUBJ_PR_TAX			VARCHAR2(200)
    ,RO_W2_STATE_WAGES			VARCHAR2(200)
    ,RO_PR_TAX_WITHHELD			VARCHAR2(200)
    ,RO_RETIREMENT_CONTRIB			VARCHAR2(200)
  --
  -- RS Record Data
  --
   ,RS_TAXING_ENTITY_CODE			VARCHAR2(200)
   ,RS_OPTIONAL_CODE				VARCHAR2(200)
   ,RS_REPORTING_PERIOD			VARCHAR2(200)
   ,RS_SQWL_UNEMP_INS_WAGES		VARCHAR2(200)
   ,RS_SQWL_UNEMP_TXBL_WAGES	VARCHAR2(200)
   ,RS_WEEKS_WORKED				VARCHAR2(200)
   ,RS_DATE_FIRST_EMPLOYED		VARCHAR2(200)
   ,RS_DATE_OF_SEPARATION			VARCHAR2(200)
   ,RS_STATE_ER_ACCT_NUM			VARCHAR2(200)
   ,RS_STATE_CODE					VARCHAR2(200)
   ,RS_STATE_WAGES				VARCHAR2(200)
   ,RS_SIT_WITHHELD				VARCHAR2(200)
   ,RS_OTHER_STATE_DATA			VARCHAR2(200)
   ,RS_STATE_EIN					VARCHAR2(200)
   ,RS_TAX_TYPE_CODE				VARCHAR2(200)
   ,RS_STATE_CONTROL_NUMBER		VARCHAR2(200)
   ,RS_SUPPLEMENTAL_DATA_1		VARCHAR2(200)
   ,RS_SUPPLEMENTAL_DATA_2		VARCHAR2(200)
 );

 /*******************************************************************
  ** PL/SQL table of record to store the archived values of RCW Record
  *******************************************************************/
  TYPE fed_ee_record_tab IS TABLE OF  fed_employee_record
  INDEX BY BINARY_INTEGER;
  --
  -- Table of Records with Data Type fed_ee_record_tab
  --
  ltr_fed_ee_record		fed_ee_record_tab;

 TYPE validate_data_rec IS RECORD
                         (assingment_action_id	NUMBER
			  ,record_name			VARCHAR2(200)
			  ,field_name			VARCHAR2(200)
			 ,data_type			VARCHAR2(200)
			 ,dbi_Name			VARCHAR2(200)
                         ,data_value			VARCHAR2(200)
			 ,derived_live_data		VARCHAR2(200)	-- D :- Devied	L :- Live
			 ,mandatory_flag		VARCHAR2(200)
			 ,no_of_validation		NUMBER		-- Range between 1 and 3
			 ,validation_type_1		VARCHAR2(200)
			 ,validation_type_2		VARCHAR2(200)
			 ,validation_type_3		VARCHAR2(200)
			 ,validation_status		VARCHAR2(200)
			 ,xml_string			VARCHAR2(32767)
                         );
TYPE validate_data_record_tab IS TABLE OF validate_data_rec
                                                        INDEX BY BINARY_INTEGER;
validate_data_record  validate_data_record_tab;

--
-- This procedure would be used to populate the Tag used for RA Data Record
--
PROCEDURE populate_ra_data_tag;

PROCEDURE  populate_arch_transmitter (
						p_payroll_action_id	IN NUMBER
						,p_tax_unit_id		IN NUMBER
						,p_date_earned		IN DATE
						,p_reporting_year	IN VARCHAR2
						,p_jurisdiction_code	IN VARCHAR2
						,p_state_code		IN NUMBER
						,p_state_abbreviation	IN VARCHAR2
						,p_locality_code		IN VARCHAR2
						,status			IN VARCHAR2
						,p_final_string		OUT NOCOPY VARCHAR2
							     );
--
-- This procedure would be used to populate the Tag used for RE Record
--
PROCEDURE populate_re_data_tag;
--
-- This procedure would be used to populate the PL/Table used for
-- storing RE or Employer record Data

PROCEDURE  populate_arch_employer (
						p_payroll_action_id	IN NUMBER
						,p_tax_unit_id		IN NUMBER
						,p_date_earned		IN DATE
						,p_reporting_year	IN VARCHAR2
						,p_jurisdiction_code	IN VARCHAR2
						,p_state_code		IN NUMBER
						,p_state_abbreviation	IN VARCHAR2
						,p_locality_code		IN VARCHAR2
						,status			IN VARCHAR2
						,p_final_string		OUT NOCOPY VARCHAR2
							);

--
-- This procedure would be used to populate the Tag used for RW, RO and RS Data Item Tags
--
PROCEDURE populate_ee_data_tag;

PROCEDURE populate_arch_employee(
						p_payroll_action_id 		NUMBER
						,p_ye_assignment_action_id	NUMBER
						,p_tax_unit_id				NUMBER
						,p_assignment_id			NUMBER
						,p_date_earned			DATE
						,p_reporting_year			VARCHAR2
						,p_jurisdiction_code		VARCHAR2
						,p_state_code				NUMBER
						,p_state_abbreviation		VARCHAR2
						,p_locality_code			VARCHAR2
						,status					VARCHAR2
						,p_final_string				OUT NOCOPY VARCHAR2
							);


FUNCTION convert_special_char( p_data varchar2)
		     RETURN varchar2;


TYPE submitter_rec IS RECORD
                         ( submitter_tag		varchar2(200),
			   submitter_data	varchar2(200));

 /*******************************************************************
  ** PL/SQL table of record to store the archived values of RA Record DataItems
  *******************************************************************/
  TYPE submitter_record IS TABLE OF  submitter_rec
					  INDEX BY BINARY_INTEGER;
  --
  -- Table of Records with Data Type submitter_record
  --
 g_ra_record			submitter_record;

--
--PL Table used for storing the RA record Data Item Tags
--
TYPE   ra_dataitem_tag      IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
ltr_ra_data_tag				ra_dataitem_tag;

--
-- Nof of Tags used RA Records Data Items
--
g_ra_no_of_tag				number := 33;
--
-- This is to store Submitter Employer Identification Number
--
g_submitter_ein				varchar2(200);

 /* ========================================================
    ** PL/SQL table of record to store the archived values of RE Record DataItems
    ========================================================= */
TYPE employer_rec IS RECORD
                         ( employer_tag		varchar2(200),
			   employer_data	varchar2(200));

  TYPE employer_record IS	TABLE OF	employer_rec
						INDEX BY	BINARY_INTEGER;
  --
  -- Table of Records with Data Type employer_record
  --
 g_re_record			employer_record;

--
--PL Table used for storing the RE record Data Item Tags
--
TYPE   re_dataitem_tag      IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
ltr_re_data_tag				re_dataitem_tag;

--
-- Nof of Tags used RA Records Data Items
--
g_re_no_of_tag				number := 38;


 /* ==================================================================
    ** PL/SQL table of record to store the archived values of RW, RO and RS Record DataItems
    ================================================================== */
TYPE employee_rec IS RECORD
                         ( employee_tag		varchar2(200),
			   employee_data		varchar2(200));

  TYPE employee_record IS	TABLE OF	employee_rec
						INDEX BY	BINARY_INTEGER;
  --
  -- Table of Records with Data Type employee_record
  --
 g_ee_record			employee_record;

--
--PL Table used for storing the RE record Data Item Tags
--
TYPE   ee_dataitem_tag      IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
ltr_ee_data_tag				ee_dataitem_tag;

--
-- Nof of Tags used RW, RO and RS Records Data Items
--
g_ee_no_of_tag				number := 78;

--
-- This table structure is used to store locality level data
--
TYPE l_local_rec IS RECORD(
        jurisdiction			VARCHAR2(15),
	      city_name			VARCHAR2(100),
	      county_name		VARCHAR2(100),
        tax_type			VARCHAR2(100),
	      locality_code		VARCHAR2(100),
	      locality_wages		VARCHAR2(100),
        locality_tax			VARCHAR2(100),
        city_rs_tax varchar2(100),
        city_wk_tax varchar2(100),
        city_rs_wages varchar2(100),
        non_state_earnings varchar2(100),
        non_state_withheld varchar2(100));

TYPE l_local_table IS TABLE OF l_local_rec
                     INDEX BY BINARY_INTEGER;
ltr_local_record     l_local_table;

TYPE city_rec IS RECORD
                         ( city_tag		varchar2(200),
			   city_data	varchar2(200));

  TYPE ee_city_record IS	TABLE OF	city_rec
						INDEX BY	BINARY_INTEGER;
  --
  -- Table of Records with Data Type ee_city_record
  --
 g_city_record			ee_city_record;

--
--PL Table used for storing the Employee level locality Data Item Tags
--
TYPE   ee_locality_tag      IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
ltr_ee_locality_tag	ee_locality_tag;

--
-- Nof of Tags used RW, RO and RS Records Data Items
--
g_no_of_locality_tag		number := 7;



END pay_us_w2_generic_extract;

/
