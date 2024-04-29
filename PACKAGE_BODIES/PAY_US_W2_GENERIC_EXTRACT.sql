--------------------------------------------------------
--  DDL for Package Body PAY_US_W2_GENERIC_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_W2_GENERIC_EXTRACT" as
/* $Header: payusw2genxtract.pkb 120.0.12010000.10 2009/01/04 17:56:03 svannian ship $  */
 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
		PAY_US_W2_GENERIC_EXTRACT

  File
		payusw2genxtract.pkb

  Purpose
		The purpose of this package is to support the YearEnd Generic Interface Extract Process
		This package to include generic dtabase package components may be used for various
                YearEnd process for Extractiing archived Data, Validating and constructing XML element

  Notes

  History

   Date          User Id       Version    Description
   ============================================================================
   08-Nov-06  ppanda        115.0      Initial Version Created
   16-Jan-07  ppanda        115.3      Tag name CITY_TAX_WITHELD changed to CITY_TAX_WITHHELD
                                       for employee City level data
   24-Sep-08  kagangul	    115.5      Bug 7427138
				       Converted Employee's First Name, Middle Name
				       Last Name and Suffix to Uppercase.
   11-Nov-08  kagangul      115.6      Bug 7438273
				       While creating the Employer's record it should get
				       the details based on the Employers's id not the
				       Transmitter's ID.
   18-Nov-08  kagangul      115.7      Bug No : 7456383
                                       Adding blank State Control Number in the RS Record.
   02-Dec-08  kagangul      115.8      Bug No : 7592972
				       State Code should be passed as two character long Code
				       to the cursor c_locality_jurisdiction
   04-Dec-08  kagangul      115.9      Bug No : 7592972
				       State Code should be passed as two character long Code
				       also to the function hr_us_w2_rep.get_w2_arch_bal and
				       hr_us_w2_rep.get_state_item
   23-Dec-08  kagangul      115.10     Bug No : 7637211
                                       Added Tag EXCEPTION_DETAILS under EXCEPTION Tag at
				       EMPLOYEE level to provide more details on the exception
				       for employees under EXCEPTION=FAILED
   02-Jan-09   svannian      Non PA Earnings/Withheld Tags added.
 ============================================================================*/
--
-- Global Variables
--
    g_proc_name					varchar2(240);
    g_debug						boolean;
    g_document_type					varchar2(50);

  /****************************************************************************
    Name        : HR_UTILITY_TRACE
    Description : This procedure prints debug messages.
  *****************************************************************************/

  PROCEDURE HR_UTILITY_TRACE
  (
      P_TRC_DATA  varchar2
  ) AS
 BEGIN
    IF g_debug THEN
        hr_utility.trace(p_trc_data);
    END IF;
 END HR_UTILITY_TRACE;

FUNCTION convert_special_char( p_data varchar2)
RETURN varchar2 IS
   l_data VARCHAR2(2000);
BEGIN
      l_data := trim(p_data);
      l_data := REPLACE(l_data, '&' , '&' || 'amp;');
      l_data := REPLACE(l_data, '<'     , '&' || 'lt;');
      l_data := REPLACE(l_data, '>'     , '&' || 'gt;');
      l_data := REPLACE(l_data, ''''    , '&' || 'apos;');
      l_data := REPLACE(l_data, '"'     , '&' || 'quot;');
   RETURN l_data;
END  convert_special_char;


--
-- This procedure would be used to populate the Tag used for RA Data Record
--
PROCEDURE populate_ra_data_tag
IS
	i			number;
BEGIN

	ltr_ra_data_tag(1) := 'TR_REC_IDENTIFIER';
	ltr_ra_data_tag(2) :='TR_EIN';
	ltr_ra_data_tag(3) :='TR_PIN';
	ltr_ra_data_tag(4) :='RESUB_INDICATOR';
	ltr_ra_data_tag(5) :='RESUB_WFID';
	ltr_ra_data_tag(6) :='SOFTWARE_CODE';
	ltr_ra_data_tag(7) :='COMPANY_NAME';
	ltr_ra_data_tag(8) :='LOCATION_ADDRESS';
	ltr_ra_data_tag(9) :='TR_DELIVERY_ADDRESS';
	ltr_ra_data_tag(10) :='TR_CITY';
	ltr_ra_data_tag(11) :='TR_STATE_ABBREVIATION';
	ltr_ra_data_tag(12) :='TR_ZIP_CODE';
	ltr_ra_data_tag(13) :='TR_ZIP_CODE_EXTENSION';
	ltr_ra_data_tag(14) :='TR_FOREIGN_STATE_PROVINCE';
	ltr_ra_data_tag(15) :='TR_FOREIGN_POSTAL_CODE';
	ltr_ra_data_tag(16) :='TR_COUNTRY_CODE';
	ltr_ra_data_tag(17) :='SUBMITTER_NAME';
	ltr_ra_data_tag(18) :='CP_LOCATION_ADDRESS';
	ltr_ra_data_tag(19) :='CP_DELIVERY_ADDRESS';
	ltr_ra_data_tag(20) :='CP_CITY';
	ltr_ra_data_tag(21) :='CP_STATE_ABBREVIATION';
	ltr_ra_data_tag(22) :='CP_ZIP_CODE';
	ltr_ra_data_tag(23) :='CP_ZIP_CODE_EXTENSION';
	ltr_ra_data_tag(24) :='CP_FOREIGN_STATE_PROVINCE';
	ltr_ra_data_tag(25) :='CP_FOREIGN_POSTAL_CODE';
	ltr_ra_data_tag(26) :='CP_COUNTRY_CODE';
	ltr_ra_data_tag(27) :='CONTACT_NAME';
	ltr_ra_data_tag(28) :='CONTACT_PHONE_NUMBER';
	ltr_ra_data_tag(29) :='CONTACT_PHONE_EXTENSION';
	ltr_ra_data_tag(30) :='CONTACT_EMAIL';
	ltr_ra_data_tag(31) :='CONTACT_FAX	';
	ltr_ra_data_tag(32) :='METHOD_OF_NOTIFICATION';
	ltr_ra_data_tag(33) :='PREPARER_CODE';
	--
        -- Following Loop structure used to debug the Tag Values
	--
	FOR I IN 1 .. g_ra_no_of_tag	 LOOP
		HR_UTILITY_TRACE('Tag'||to_char(i)|| ' : '||ltr_ra_data_tag(i));
	END LOOP;
END populate_ra_data_tag;


--
-- This Procedue would be used to fetch all the submitter/transmitter releated data
-- All the data would then be populated into a global pl/sql based table for construting XML
--
PROCEDURE  populate_arch_transmitter (	p_payroll_action_id 	NUMBER
								,p_tax_unit_id		NUMBER
								,p_date_earned		DATE
								,p_reporting_year	VARCHAR2
								,p_jurisdiction_code	VARCHAR2
								,p_state_code		NUMBER
								,p_state_abbreviation	VARCHAR2
								,p_locality_code		VARCHAR2
								,status			VARCHAR2
								,p_final_string		OUT NOCOPY VARCHAR2
								)
AS
--{
--
-- Declaration of Index Value that will be used for storing and fetching Submitter level Data
-- from the global pl/sql table maintained for submitter level data
--
TR_REC_IDENTIFIER				NUMBER := 1;
TR_EIN						NUMBER := 2;
TR_PIN						NUMBER := 3;
RESUB_INDICATOR				NUMBER := 4;
RESUB_WFID					NUMBER := 5;
SOFTWARE_CODE				NUMBER := 6;
COMPANY_NAME				NUMBER := 7;
LOCATION_ADDRESS			NUMBER := 8;
TR_DELIVERY_ADDRESS			NUMBER := 9;
TR_CITY						NUMBER := 10;
TR_STATE_ABBREVIATION		NUMBER := 11;
TR_ZIP_CODE					NUMBER := 12;
TR_ZIP_CODE_EXTENSION		NUMBER := 13;
TR_FOREIGN_STATE_PROVINCE	NUMBER := 14;
TR_FOREIGN_POSTAL_CODE		NUMBER := 15;
TR_COUNTRY_CODE			NUMBER := 16;
SUBMITTER_NAME				NUMBER := 17;
CP_LOCATION_ADDRESS			NUMBER := 18;
CP_DELIVERY_ADDRESS			NUMBER := 19;
CP_CITY						NUMBER := 20;
CP_STATE_ABBREVIATION		NUMBER := 21;
CP_ZIP_CODE					NUMBER := 22;
CP_ZIP_CODE_EXTENSION		NUMBER := 23;
CP_FOREIGN_STATE_PROVINCE	NUMBER := 24;
CP_FOREIGN_POSTAL_CODE		NUMBER := 25;
CP_COUNTRY_CODE			NUMBER := 26;
CONTACT_NAME				NUMBER := 27;
CONTACT_PHONE_NUMBER		NUMBER := 28;
CONTACT_PHONE_EXTENSION	NUMBER := 29;
CONTACT_EMAIL				NUMBER := 30;
CONTACT_FAX					NUMBER := 31;
METHOD_OF_NOTIFICATION		NUMBER := 32;
PREPARER_CODE				NUMBER := 33;


--
-- Local Variables required for Employer/Contact person Data
--
l_payroll_action_id		number;
l_assignment_id			number;
l_date_earned			date;
l_tax_unit_id			number;
l_input_report_type		varchar2(200)	:= 'W2';
l_input_report_type_format	varchar2(200)	:= 'MMREF';
l_input_record_name		varchar2(200)	:= 'RA';
l_effective_date			varchar2(200);
l_item_name			varchar2(200);
l_input_report_qualifier	varchar2(200);

/* Submitter Input Variables for fetching Submitter Data */

input_sbmtr_name		varchar2(200) ;
input_sbmtr_1			varchar2(200) ;
input_sbmtr_2			varchar2(200)	;
input_sbmtr_3			varchar2(200)	;
input_sbmtr_4			varchar2(200)	;
input_sbmtr_5			varchar2(200) ;
input_sbmtr_validiate_flag	varchar2(200) ;
sbmtr_exclude_output_flag	varchar2(200) ;
-- Output
sbmtr_out_1			varchar2(200) := ' ';
sbmtr_out_2			varchar2(200) := ' ';
sbmtr_out_3			varchar2(200) := ' ';
sbmtr_out_4			varchar2(200) := ' ';
sbmtr_out_5			varchar2(200) := ' ';
sbmtr_out_6			varchar2(200) := ' ';
sbmtr_out_7			varchar2(200) := ' ';
sbmtr_out_8			varchar2(200) := ' ';
sbmtr_out_9			varchar2(200) := ' ';
sbmtr_out_10			varchar2(200) := ' ';

/* Local Variables for Company Information */
input_empr_name			varchar2(200);
input_empr_1				varchar2(200);
input_empr_2				varchar2(200) := ' ';
input_empr_3				varchar2(200) := ' ';
input_empr_4				varchar2(200) := ' ';
input_empr_5				varchar2(200) := ' ';
empr_validate_flag			varchar2(200) := 'Y';
empr_exclude_output_flag		varchar2(200) := 'N';
empr_out_1				varchar2(200) := ' ';
empr_out_2				varchar2(200) := ' ';
empr_out_3				varchar2(200) := ' ';
empr_out_4				varchar2(200) := ' ';
empr_out_5				varchar2(200) := ' ';
empr_out_6				varchar2(200) := ' ';
empr_out_7				varchar2(200) := ' ';
empr_out_8				varchar2(200) := ' ';
empr_out_9				varchar2(200) := ' ';
empr_out_10				varchar2(200) := ' ';

/* Local Variables for CONTACT INFORMATION Input */
input_cnti_name			varchar2(200);
input_cnti_1			varchar2(200);
input_cnti_2			varchar2(200);
input_cnti_3			varchar2(200);
input_cnti_4			varchar2(200);
input_cnti_5			varchar2(200);
input_cnti_validate_flag	varchar2(200);
cnti_exclude_output_flag	varchar2(200);
cnti_out_1				varchar2(200) := ' ';
cnti_out_2				varchar2(200) := ' ';
cnti_out_3				varchar2(200) := ' ';
cnti_out_4				varchar2(200) := ' ';
cnti_out_5				varchar2(200) := ' ';
cnti_out_6				varchar2(200) := ' ';
cnti_out_7				varchar2(200) := ' ';
cnti_out_8				varchar2(200) := ' ';
cnti_out_9				varchar2(200) := ' ';
cnti_out_10			varchar2(200) := ' ';

i					number	:=0;
j					number	:=0;
--PL Table used for storing and manipulating DataBaseItem used for
-- Submitter level information
TYPE RA_UE_REC IS RECORD (
						ue_name       varchar2(200),
						ue_value	     varchar2(200)
						 );

TYPE ra_ue_record IS TABLE OF ra_ue_rec
			INDEX BY BINARY_INTEGER;
ltr_ue_name_table ra_ue_record;
l_number_ra_dbi			NUMBER := 6;

--
-- RA Record Data Item Tags
--

submitter_data				varchar2(200);
employer_data				varchar2(200);
contact_data				varchar2(200);

-- SRS Parameter

l_srs_trns_pin				varchar2(200);
l_srs_trns_tlcn				varchar2(200);
l_srs_resub_indicator			varchar2(200);

-- Derived Local Variables
l_resub_indicator			varchar2(200);
l_reporting_date				varchar2(200);

l_err						boolean := FALSE;
l_validate					varchar2(100);
l_validated_EIN				varchar2(200);

l_final_xml_string			varchar2(32767);
l_last_xml					CLOB;
l_is_temp_final_xml			varchar2(2);
l_output_location			varchar2(100);
l_instr_template				varchar2(100);
EOL						varchar2(10);

/* End of Variable Declarations */
BEGIN
--{
--
-- Fetch all Context or Parameters set at the Transmitter Cursor
--
--l_tax_unit_id			:=  pay_magtape_generic.get_parameter_value('TAX_UNIT_ID');
--l_payroll_action_id		:= pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
--l_date_earned			:=  pay_magtape_generic.get_parameter_value('DATE_EARNED');
--l_reporting_date		:=  '31-DEC-'||pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR');

l_tax_unit_id			:=  p_tax_unit_id;
l_payroll_action_id		:=  p_payroll_action_id;
l_date_earned			:=  p_date_earned;
l_reporting_date			:=  '31-DEC-'||p_reporting_year;
l_effective_date			:=  l_reporting_date;

--
-- Fetch SRS Parameter
--
l_srs_trns_pin			:= pay_magtape_generic.get_parameter_value('TRNS_PIN');
l_srs_trns_tlcn			:= pay_magtape_generic.get_parameter_value('TRNS_TLCN');

l_input_report_qualifier	:= pay_magtape_generic.get_parameter_value('TRANSFER_STATE');

--
-- Fetch Archived Values of various DBIs used in submitter Record
--

i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_TAX_UNIT_EMPLOYER_IDENTIFICATION_NUMBER';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_TAX_UNIT_NAME';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_W2_REPORTING_RULES_ORG_COMPANY_NAME';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_W2_REPORTING_RULES_ORG_CONTACT_NAME';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_W2_REPORTING_RULES_ORG_NOTIFICATION_METHOD';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_W2_REPORTING_RULES_ORG_PREPARER';

if ltr_ue_name_table.count > 0 then
           for j in ltr_ue_name_table.first .. ltr_ue_name_table.last
	   loop
		ltr_ue_name_table(j).ue_value := hr_us_w2_rep.get_w2_tax_unit_item (l_tax_unit_id,
														                   l_payroll_action_id,
									                                                           ltr_ue_name_table(j).ue_name);
           end loop;
end if;

/* =========================================================
   Get Submitted Information to be used for extracting MMREF-1 RA record type
   ========================================================== */
input_sbmtr_name			:=  'ER_ADDRESS';
input_sbmtr_1				:= pay_magtape_generic.get_parameter_value('TRANSFER_TRANS_LEGAL_CO_ID');
input_sbmtr_validiate_flag	:= 'Y';
sbmtr_exclude_output_flag	:= 'N';

 submitter_data := pay_us_reporting_utils_pkg.get_item_data(
								NULL,		-- Assignment Id  (Not Used at RA record)
								l_date_earned,
								l_tax_unit_id,
								l_reporting_date,
								input_sbmtr_name,
								l_input_report_type,
								l_input_report_type_format,
								l_input_report_qualifier,
								l_input_record_name,
								input_sbmtr_1,
								input_sbmtr_2,
								input_sbmtr_3,
								input_sbmtr_4,
								input_sbmtr_5,
								input_sbmtr_validiate_flag,
								sbmtr_exclude_output_flag,
								sbmtr_out_1,
								sbmtr_out_2,
								sbmtr_out_3,
								sbmtr_out_4,
								sbmtr_out_5,
								sbmtr_out_6,
								sbmtr_out_7,
								sbmtr_out_8,
								sbmtr_out_9,
								sbmtr_out_10);


/* ==================================================
   Get Employer or transmitter Company Information releated Submitter
   ================================================== */

input_empr_name		:= 'CR_ADDRESS';
input_empr_1			:= ltr_ue_name_table(3).ue_value;

employer_data := pay_us_reporting_utils_pkg.get_item_data(
								NULL,		-- Assignment Id  (Not Used at RA record)
								l_date_earned,
								l_tax_unit_id,
								l_reporting_date,
								input_empr_name,
								l_input_report_type,
								l_input_report_type_format,
								l_input_report_qualifier,
								l_input_record_name,
								input_empr_1,
								input_empr_2,
								input_empr_3,
								input_empr_4,
								input_empr_5,
								empr_validate_flag,
								empr_exclude_output_flag,
								empr_out_1,
								empr_out_2,
								empr_out_3,
								empr_out_4,
								empr_out_5,
								empr_out_6,
								empr_out_7,
								empr_out_8,
								empr_out_9,
								empr_out_10);

/* ========================================================
   Fetch Information of Contact Person  submitting the Lcoal W-2 Magnetic Tape
   ========================================================= */
input_cnti_name			:= 'CR_PERSON';
                                                     -- A_LC_W2_REPORTING_RULES_ORG_CONTACT_NAME
input_cnti_1				:= ltr_ue_name_table(4).ue_value;
input_cnti_validate_flag		:= 'Y';
cnti_exclude_output_flag		:= 'N';

contact_data := pay_us_reporting_utils_pkg.get_item_data(
								NULL,	-- Assignment Id  (Not Used at RA record)
								l_date_earned,
								l_tax_unit_id,
								l_reporting_date,
								input_cnti_name,
								l_input_report_type,
								l_input_report_type_format,
								l_input_report_qualifier,
								l_input_record_name,
								input_cnti_1,
								input_cnti_2,
								input_cnti_3,
								input_cnti_4,
								input_cnti_5,
								input_cnti_validate_flag,
								cnti_exclude_output_flag,
								cnti_out_1,
								cnti_out_2,
								cnti_out_3,
								cnti_out_4,
								cnti_out_5,
								cnti_out_6,
								cnti_out_7,
								cnti_out_8,
								cnti_out_9,
								cnti_out_10);
    --
    -- Pouplate All the Tags to be used for RA record Data Items
    --
    pay_us_w2_generic_extract.populate_ra_data_tag;


/* Record Identifier */
	g_ra_record(TR_REC_IDENTIFIER).submitter_data	:= 'RA';
	g_ra_record(TR_REC_IDENTIFIER).submitter_tag	:= ltr_ra_data_tag(TR_REC_IDENTIFIER);

/* Submitter Employer Identification Number(EIN) */
    --
    --  EIN Validation
    --
          l_validated_EIN :=
             pay_us_report_data_validation.validate_W2_EIN( 'FED',
											      l_input_record_name,
											      ltr_ue_name_table(1).ue_value,
											      empr_out_10,
											      empr_validate_flag,
											      l_err
											    );
        g_submitter_ein := 	l_validated_EIN;
	g_ra_record(TR_EIN).submitter_data	:= l_validated_EIN;
	                                                                    --ltr_ue_name_table(1).ue_value;
	g_ra_record(TR_EIN).submitter_tag	:= ltr_ra_data_tag(TR_EIN);

/* Personal Identification Number (PIN) */
	g_ra_record(TR_PIN).submitter_data	:= l_srs_trns_pin;
	g_ra_record(TR_PIN).submitter_tag	:= ltr_ra_data_tag(TR_PIN);

/* Resub Indicator */
	IF length(l_srs_trns_tlcn) > 0
	THEN
		l_resub_indicator  :=  '1';
	ELSE
		l_resub_indicator  := '0';
	END IF;
	g_ra_record(RESUB_INDICATOR).submitter_data	:= l_resub_indicator;
	g_ra_record(RESUB_INDICATOR).submitter_tag	:= ltr_ra_data_tag(RESUB_INDICATOR);

/* Resub TLCN */
	g_ra_record(RESUB_WFID).submitter_data	:= l_srs_trns_tlcn;
	g_ra_record(RESUB_WFID).submitter_tag	:= ltr_ra_data_tag(RESUB_WFID);
/* Software Code */
	g_ra_record(SOFTWARE_CODE).submitter_data	:= '99';
	g_ra_record(SOFTWARE_CODE).submitter_tag		:= ltr_ra_data_tag(SOFTWARE_CODE);
/* Company Name */
	g_ra_record(COMPANY_NAME).submitter_data	:= empr_out_10;
	g_ra_record(COMPANY_NAME).submitter_tag	:= ltr_ra_data_tag(COMPANY_NAME);
/* Company, Location Address */
	g_ra_record(LOCATION_ADDRESS).submitter_data	:= empr_out_1;
	g_ra_record(LOCATION_ADDRESS).submitter_tag	:= ltr_ra_data_tag(LOCATION_ADDRESS);
/* Company, Delivery Address */
	g_ra_record(TR_DELIVERY_ADDRESS).submitter_data	:= empr_out_2;
	g_ra_record(TR_DELIVERY_ADDRESS).submitter_tag	:= ltr_ra_data_tag(TR_DELIVERY_ADDRESS);
/* Company, City */
	g_ra_record(TR_CITY).submitter_data	:= empr_out_3;
	g_ra_record(TR_CITY).submitter_tag	:= 'TR_CITY';
/* Company, State Abbreviation */
	g_ra_record(TR_STATE_ABBREVIATION).submitter_data := empr_out_4;
	g_ra_record(TR_STATE_ABBREVIATION).submitter_tag	 := ltr_ra_data_tag(TR_STATE_ABBREVIATION);
/* Desc: Company, Zip Code */
	g_ra_record(TR_ZIP_CODE).submitter_data		:= empr_out_5;
	g_ra_record(TR_ZIP_CODE).submitter_tag		:= 'TR_ZIP_CODE';
/* Desc: Company, Zip Code Extension */
	g_ra_record(TR_ZIP_CODE_EXTENSION).submitter_data		:= empr_out_6;
	g_ra_record(TR_ZIP_CODE_EXTENSION).submitter_tag		:= ltr_ra_data_tag(TR_ZIP_CODE_EXTENSION);
/* Company, Foreign State or Province */
	g_ra_record(TR_FOREIGN_STATE_PROVINCE).submitter_data	:= empr_out_7;
	g_ra_record(TR_FOREIGN_STATE_PROVINCE).submitter_tag		:= ltr_ra_data_tag(TR_FOREIGN_STATE_PROVINCE);
/* Company, Foreign Postal Code */
	g_ra_record(TR_FOREIGN_POSTAL_CODE).submitter_data	:= empr_out_8;
	g_ra_record(TR_FOREIGN_POSTAL_CODE).submitter_tag	:= ltr_ra_data_tag(TR_FOREIGN_POSTAL_CODE);
/* Company, Country Code */
	g_ra_record(TR_COUNTRY_CODE).submitter_data	:= empr_out_9;
	g_ra_record(TR_COUNTRY_CODE).submitter_tag	:= ltr_ra_data_tag(TR_COUNTRY_CODE);
/* Submitter Name */
	g_ra_record(SUBMITTER_NAME).submitter_data	:= ltr_ue_name_table(2).ue_value;
	g_ra_record(SUBMITTER_NAME).submitter_tag		:= ltr_ra_data_tag(SUBMITTER_NAME);
/* Submitter, Location Address */
	g_ra_record(CP_LOCATION_ADDRESS).submitter_data	:= sbmtr_out_1;
	g_ra_record(CP_LOCATION_ADDRESS).submitter_tag	:= ltr_ra_data_tag(CP_LOCATION_ADDRESS);
/* Submitter, Delivery Address */
	g_ra_record(CP_DELIVERY_ADDRESS).submitter_data	:= sbmtr_out_2;
	g_ra_record(CP_DELIVERY_ADDRESS).submitter_tag	:= ltr_ra_data_tag(CP_DELIVERY_ADDRESS);
/* Submitter, City */
	g_ra_record(CP_CITY).submitter_data	:= sbmtr_out_3;
	g_ra_record(CP_CITY).submitter_tag	:= ltr_ra_data_tag(CP_CITY);
/* Submitter, State Abbreviation */
	g_ra_record(CP_STATE_ABBREVIATION).submitter_data  := sbmtr_out_4;
	g_ra_record(CP_STATE_ABBREVIATION).submitter_tag	  := ltr_ra_data_tag(CP_STATE_ABBREVIATION);
/* Submitter, Zip Code */
	g_ra_record(CP_ZIP_CODE).submitter_data  := sbmtr_out_5;
	g_ra_record(CP_ZIP_CODE).submitter_tag	  := ltr_ra_data_tag(CP_ZIP_CODE);
/* Submitter, Zip Code Extension */
	g_ra_record(CP_ZIP_CODE_EXTENSION).submitter_data  := sbmtr_out_6;
	g_ra_record(CP_ZIP_CODE_EXTENSION).submitter_tag	  := ltr_ra_data_tag(CP_ZIP_CODE_EXTENSION);
/* Submitter, Foreign State or Province */
	g_ra_record(CP_FOREIGN_STATE_PROVINCE).submitter_data  := sbmtr_out_7;
	g_ra_record(CP_FOREIGN_STATE_PROVINCE).submitter_tag	  := ltr_ra_data_tag(CP_FOREIGN_STATE_PROVINCE);
/* Submitter, Foreign Postal Code */
	g_ra_record(CP_FOREIGN_POSTAL_CODE).submitter_data  := sbmtr_out_8;
	g_ra_record(CP_FOREIGN_POSTAL_CODE).submitter_tag    := ltr_ra_data_tag(CP_FOREIGN_POSTAL_CODE);
/* Submitter, Country Code */
	g_ra_record(CP_COUNTRY_CODE).submitter_data  := sbmtr_out_8;
	g_ra_record(CP_COUNTRY_CODE).submitter_tag    := ltr_ra_data_tag(CP_COUNTRY_CODE);
/* Contact Name */
	g_ra_record(CONTACT_NAME).submitter_data  := cnti_out_1;
	g_ra_record(CONTACT_NAME).submitter_tag    := ltr_ra_data_tag(CONTACT_NAME);
/* Contact Phone Number */
	g_ra_record(CONTACT_PHONE_NUMBER).submitter_data  := cnti_out_2;
	g_ra_record(CONTACT_PHONE_NUMBER).submitter_tag    := ltr_ra_data_tag(CONTACT_PHONE_NUMBER);
/* Contact Phone Extension */
	g_ra_record(CONTACT_PHONE_EXTENSION).submitter_data  := cnti_out_3;
	g_ra_record(CONTACT_PHONE_EXTENSION).submitter_tag    := ltr_ra_data_tag(CONTACT_PHONE_EXTENSION);
/* Contact E-Mail */
	g_ra_record(CONTACT_EMAIL).submitter_data  := cnti_out_4;
	g_ra_record(CONTACT_EMAIL).submitter_tag    := ltr_ra_data_tag(CONTACT_EMAIL);
/* Contact FAX */
	g_ra_record(CONTACT_FAX).submitter_data  := cnti_out_5;
	g_ra_record(CONTACT_FAX).submitter_tag    := ltr_ra_data_tag(CONTACT_FAX);
/* Perferred Method of Problem Notification Code */
	g_ra_record(METHOD_OF_NOTIFICATION).submitter_data  := ltr_ue_name_table(5).ue_value;
	g_ra_record(METHOD_OF_NOTIFICATION).submitter_tag    := ltr_ra_data_tag(METHOD_OF_NOTIFICATION);
/* Preparer Code */
	g_ra_record(PREPARER_CODE).submitter_data  := ltr_ue_name_table(6).ue_value;
	g_ra_record(PREPARER_CODE).submitter_tag    := ltr_ra_data_tag(PREPARER_CODE);

 /*
       Consturct XML Elements  using all the RA record data items stored in the
       '<?xml version="1.0" encoding="UTF-8" ?>'|| EOL ||
 */
	SELECT fnd_global.local_chr(13) || fnd_global.local_chr(10) INTO EOL
           FROM dual;

        l_final_xml_string :=  '<TRANSMITTER>'||EOL;

	FOR I IN 1 .. g_ra_no_of_tag	 LOOP
		l_final_xml_string := l_final_xml_string || '<'||g_ra_record(I).submitter_tag||'>'||
                                                     convert_special_char(g_ra_record(I).submitter_data)
						     ||'</'||g_ra_record(I).submitter_tag||'>'|| EOL;
--                HR_UTILITY_TRACE(l_final_xml_string);
	END LOOP;
        HR_UTILITY_TRACE(l_final_xml_string);
	p_final_string := l_final_xml_string;
	--pay_us_mmref_local_xml.write_to_magtape_lob(l_final_xml_string);
        --pay_core_files.write_to_magtape_lob(l_final_xml_string);
--}
END populate_arch_transmitter;  -- End of Procedure populate_arch_transmitter

--
-- This Procedue would be used to fetch all the Employer releated data for yearEnd reporting
-- All the data would then be populated into a global pl/sql based table for constructing XML
--

--
-- This procedure would be used to populate the Tag used for RE Data Record
--
PROCEDURE populate_re_data_tag
IS

i			number;

BEGIN

	ltr_re_data_tag(1)   := 'ER_RECORD_IDENTIFIER';
	ltr_re_data_tag(2)   := 'ER_TAX_YEAR';
	ltr_re_data_tag(3)   := 'ER_AGENT_INDICATOR_CODE';
	ltr_re_data_tag(4)   := 'ER_EIN';
	ltr_re_data_tag(5)   := 'ER_AGENT_EIN';
	ltr_re_data_tag(6)   := 'ER_TERMINATE_BUSINESS_IND';
	ltr_re_data_tag(7)   := 'ESTABLISHMENT_NUMBER';
	ltr_re_data_tag(8)   := 'ER_OTHER_EIN';
	ltr_re_data_tag(9)   := 'ER_NAME';
	ltr_re_data_tag(10) := 'ER_ADDRESS';
	ltr_re_data_tag(11) := 'ER_DELIVERY_ADDRESS';
	ltr_re_data_tag(12) := 'ER_CITY';
	ltr_re_data_tag(13) := 'ER_STATE_ABBREVIATION';
	ltr_re_data_tag(14) := 'ER_ZIP_CODE';
	ltr_re_data_tag(15) := 'ER_ZIP_CODE_EXTENSION';
	ltr_re_data_tag(16) := 'ER_FOREIGN_STATE_PROVINCE';
	ltr_re_data_tag(17) := 'ER_FOREIGN_POSTAL_CODE';
	ltr_re_data_tag(18) := 'ER_COUNTRY_CODE';
	ltr_re_data_tag(19) := 'ER_EMPLOYMENT_CODE';
	ltr_re_data_tag(20) := 'ER_TAX_JD_CODE';
	ltr_re_data_tag(21) := 'ER_THIRD_PARTY_SICK_PAY_IND';
	ltr_re_data_tag(22) := 'ER_SS_EE_WAGE_BASE';
	ltr_re_data_tag(23) := 'ER_SS_EE_WAGE_RATE';
	ltr_re_data_tag(24) := 'ER_1099R_TRANSMITTER_CODE';
	ltr_re_data_tag(25) := 'ER_1099R_TRANSMITTER_INDICATOR';
	ltr_re_data_tag(26) := 'ER_1099R_BUREAU_INDICATOR';
	ltr_re_data_tag(27) := 'ER_1099R_COMBINED_FILER';
	ltr_re_data_tag(28) := 'ER_SIT_COMPANY_STATE_ID';
	ltr_re_data_tag(29) := 'ER_SUI_COMPANY_STATE_ID';
	ltr_re_data_tag(30) := 'ER_FIPS_CODE_JD	';
	ltr_re_data_tag(31) := 'ER_GOVT_EMPLOYER';
	ltr_re_data_tag(32) := 'ER_TYPE_OF_EMPLOYMENT	';
	ltr_re_data_tag(33) := 'ER_BLOCKING_FACTOR';
	ltr_re_data_tag(34) := 'ER_W2_2678_FILER';
	ltr_re_data_tag(35) := 'ER_COMPANY_NAME';
	ltr_re_data_tag(36) := 'ER_CONTACT_NAME';
	ltr_re_data_tag(37) := 'ER_NOTIFICATION_METHOD';
	ltr_re_data_tag(38) := 'ER_PREPARER';
	--
        -- Following Loop structure used to debug the Tag Values
	--
	FOR I IN ltr_re_data_tag.first .. ltr_re_data_tag.last 	 LOOP
		HR_UTILITY_TRACE('Tag'||to_char(i)|| ' : '||ltr_re_data_tag(i));
	END LOOP;

END populate_re_data_tag;

--
-- This Procedue would be used to fetch all the employer/Tax Unit releated data
-- All the data would then be populated into a global pl/sql based table for construting XML
--
PROCEDURE  populate_arch_employer(
						p_payroll_action_id 	NUMBER
						,p_tax_unit_id		NUMBER
						,p_date_earned		DATE
						,p_reporting_year	VARCHAR2
						,p_jurisdiction_code	VARCHAR2
						,p_state_code		NUMBER
						,p_state_abbreviation	VARCHAR2
						,p_locality_code		VARCHAR2
						,status			VARCHAR2
						,p_final_string		OUT NOCOPY VARCHAR2
							)
AS
--{
--
-- Declaration of Index Value that will be used for storing and fetching Employer level Data
-- from the global pl/sql table maintained for employer or Tax Unit level data
--

ER_RECORD_IDENTIFIER				NUMBER  :=	1;
ER_TAX_YEAR						NUMBER  :=	2;
ER_AGENT_INDICATOR_CODE			NUMBER  :=	3;
ER_EIN							NUMBER  :=	4;
ER_AGENT_EIN					NUMBER  :=	5;
ER_TERMINATE_BUSINESS_IND		NUMBER  :=	6;
ESTABLISHMENT_NUMBER			NUMBER  :=	7;
ER_OTHER_EIN					NUMBER  :=	8;
ER_NAME							NUMBER  :=	9;
ER_ADDRESS						NUMBER  :=	10;
ER_DELIVERY_ADDRESS				NUMBER  :=	11;
ER_CITY							NUMBER  :=	12;
ER_STATE_ABBREVIATION			NUMBER  :=	13;
ER_ZIP_CODE						NUMBER  :=	14;
ER_ZIP_CODE_EXTENSION			NUMBER  :=	15;
ER_FOREIGN_STATE_PROVINCE		NUMBER  :=	16;
ER_FOREIGN_POSTAL_CODE			NUMBER  :=	17;
ER_COUNTRY_CODE				NUMBER  :=	18;
ER_EMPLOYMENT_CODE			NUMBER  :=	19;
ER_TAX_JD_CODE					NUMBER  :=	20;
ER_THIRD_PARTY_SICK_PAY_IND		NUMBER  :=	21;
ER_SS_EE_WAGE_BASE				NUMBER  :=	22;
ER_SS_EE_WAGE_RATE				NUMBER  :=	23;
ER_1099R_TRANSMITTER_CODE		NUMBER  :=	24;
ER_1099R_TRANSMITTER_INDICATOR	NUMBER  :=	25;
ER_1099R_BUREAU_INDICATOR		NUMBER  :=	26;
ER_1099R_COMBINED_FILER			NUMBER  :=	27;
ER_SIT_COMPANY_STATE_ID			NUMBER  :=	28;
ER_SUI_COMPANY_STATE_ID			NUMBER  :=	29;
ER_FIPS_CODE_JD					NUMBER  :=	30;
ER_GOVT_EMPLOYER				NUMBER  :=	31;
ER_TYPE_OF_EMPLOYMENT			NUMBER  :=	32;
ER_BLOCKING_FACTOR				NUMBER  :=	33;
ER_W2_2678_FILER					NUMBER  :=	34;
ER_COMPANY_NAME				NUMBER  :=	35;
ER_CONTACT_NAME				NUMBER  :=	36;
ER_NOTIFICATION_METHOD			NUMBER  :=	37;
ER_PREPARER					NUMBER  :=	38;

--
-- Local Variables required for Employer/Contact person Data
--
l_payroll_action_id			number;
l_assignment_id				number;
l_date_earned				date;
l_tax_unit_id				number;
l_input_report_type		        varchar2(200)	:= 'W2';
l_input_report_type_format		varchar2(200)	:= 'MMREF';
l_input_record_name			varchar2(200)	:= 'RE';
l_effective_date				varchar2(200);
l_item_name				varchar2(200);
l_input_report_qualifier		varchar2(200);

/* Local Variables for Company Information */
input_empr_name			varchar2(200);
input_empr_1				varchar2(200);
input_empr_2				varchar2(200) := ' ';
input_empr_3				varchar2(200) := ' ';
input_empr_4				varchar2(200) := ' ';
input_empr_5				varchar2(200) := ' ';
empr_validate_flag			varchar2(200) := 'Y';
empr_exclude_output_flag		varchar2(200) := 'N';
empr_out_1				varchar2(200) := ' ';
empr_out_2				varchar2(200) := ' ';
empr_out_3				varchar2(200) := ' ';
empr_out_4				varchar2(200) := ' ';
empr_out_5				varchar2(200) := ' ';
empr_out_6				varchar2(200) := ' ';
empr_out_7				varchar2(200) := ' ';
empr_out_8				varchar2(200) := ' ';
empr_out_9				varchar2(200) := ' ';
empr_out_10				varchar2(200) := ' ';

i						number	:=0;
j						number	:=0;
--PL Table used for storing and manipulating DataBaseItem used for
-- Submitter level information
TYPE re_ue_rec IS RECORD (
						ue_name       varchar2(200),
						ue_value	     varchar2(200)
					   );
TYPE re_ue_record IS TABLE OF re_ue_rec
				INDEX BY BINARY_INTEGER;
ltr_ue_name_table re_ue_record;
l_number_re_dbi			number := 6;

employer_data			varchar2(200);

-- SRS Parameter

l_srs_trns_pin			varchar2(200);
l_srs_trns_tlcn			varchar2(200);
l_srs_resub_indicator		varchar2(200);

-- Derived Local Variables
l_resub_indicator		varchar2(200);
l_reporting_date			varchar2(200);

l_err					boolean := FALSE;
l_validate				varchar2(100);
l_validated_EIN			varchar2(200);

l_final_xml_string		VARCHAR2(32767);
l_last_xml				CLOB;
l_is_temp_final_xml		VARCHAR2(2);
l_output_location		VARCHAR2(100);
l_instr_template			VARCHAR2(100);
EOL					VARCHAR2(10);

/* End of Variable Declarations */
BEGIN
--{
--
-- Fetch all Context or Parameters set at the Transmitter Cursor
--
--l_tax_unit_id		:=  pay_magtape_generic.get_parameter_value('TAX_UNIT_ID');
--l_payroll_action_id	:= pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
--l_date_earned		:=  pay_magtape_generic.get_parameter_value('DATE_EARNED');
--l_reporting_date	:=  '31-DEC-'||pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR');

l_tax_unit_id		:=  p_tax_unit_id;
/* Bug 7438273 Start */
l_tax_unit_id		:=  pay_magtape_generic.get_parameter_value('TAX_UNIT_ID');
/* Bug 7438273 End */
l_payroll_action_id	:=  p_payroll_action_id;
l_date_earned		:=  p_date_earned;
l_reporting_date		:=  '31-DEC-'||p_reporting_year;
l_effective_date		:=  l_reporting_date;

--
-- Fetch SRS Parameter
--
l_srs_trns_pin			:= pay_magtape_generic.get_parameter_value('TRNS_PIN');
l_srs_trns_tlcn			:= pay_magtape_generic.get_parameter_value('TRNS_TLCN');

l_input_report_qualifier	:= pay_magtape_generic.get_parameter_value('TRANSFER_STATE');

i := 0;
--
-- Fetch Archived Values of various DBIs used in submitter Record
--
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_TAX_UNIT_EMPLOYER_IDENTIFICATION_NUMBER';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_W2_REPORTING_RULES_ORG_TERMINATED_GRE_INDICATOR';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_W2_REPORTING_RULES_ORG_OTHER_EIN';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_TAX_UNIT_NAME';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_TAX_UNIT_COUNTRY_CODE';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_W2_REPORTING_RULES_ORG_TAX_JURISDICTION';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_W2_REPORTING_RULES_ORG_THIRD_PARTY_SICK_PAY';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_SS_EE_WAGE_BASE';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_SS_EE_WAGE_RATE';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_US_1099R_TRANSMITTER_CODE';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_US_1099R_TRANSMITTER_INDICATOR';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_US_1099R_BUREAU_INDICATOR';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_US_1099R_COMBINED_FED_STATE_FILER';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_STATE_TAX_RULES_ORG_SIT_COMPANY_STATE_ID';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_STATE_TAX_RULES_ORG_SUI_COMPANY_STATE_ID';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_FIPS_CODE_JD';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_FEDERAL_TAX_RULES_ORG_GOVERNMENT_EMPLOYER';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_FEDERAL_TAX_RULES_ORG_TYPE_OF_EMPLOYMENT';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_W2_REPORTING_RULES_ORG_BLOCKING_FACTOR';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_W2_REPORTING_RULES_ORG_W2_2678_FILER';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_W2_REPORTING_RULES_ORG_COMPANY_NAME';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_W2_REPORTING_RULES_ORG_CONTACT_NAME';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_W2_REPORTING_RULES_ORG_NOTIFICATION_METHOD';
i := i +1;
ltr_ue_name_table(i).ue_name	:= 'A_LC_W2_REPORTING_RULES_ORG_PREPARER';

if ltr_ue_name_table.count > 0 then
           for j in ltr_ue_name_table.first .. ltr_ue_name_table.last
	   loop
		ltr_ue_name_table(j).ue_value := hr_us_w2_rep.get_w2_tax_unit_item (l_tax_unit_id,
														      l_payroll_action_id,
									                                              ltr_ue_name_table(j).ue_name);
           end loop;
end if;

/* ==================================================
   Get Employer or transmitter Company Information releated Submitter
   ================================================== */

input_empr_name		:= 'ER_ADDRESS';
input_empr_1			:= ltr_ue_name_table(4).ue_value;

employer_data := pay_us_reporting_utils_pkg.get_item_data(
								NULL,		-- Assignment Id  (Not Used at RE record)
								l_date_earned,
								l_tax_unit_id,
								l_reporting_date,
								input_empr_name,
								l_input_report_type,
								l_input_report_type_format,
								l_input_report_qualifier,
								l_input_record_name,
								input_empr_1,
								input_empr_2,
								input_empr_3,
								input_empr_4,
								input_empr_5,
								empr_validate_flag,
								empr_exclude_output_flag,
								empr_out_1,
								empr_out_2,
								empr_out_3,
								empr_out_4,
								empr_out_5,
								empr_out_6,
								empr_out_7,
								empr_out_8,
								empr_out_9,
								empr_out_10);

    --
    -- Pouplate All the Tags to be used for RE record Data Items
    --

    pay_us_w2_generic_extract.populate_re_data_tag;

    /* Initialize with Default Value */

	FOR I IN ltr_re_data_tag.first .. ltr_re_data_tag.last
	LOOP
		g_re_record(I).employer_data	:= ' ';
		g_re_record(I).employer_tag	:= ltr_re_data_tag(I);
	END LOOP;

/* Record Identifier */
	g_re_record(ER_RECORD_IDENTIFIER).employer_data	:= 'RE';
	g_re_record(ER_RECORD_IDENTIFIER).employer_tag	:= ltr_re_data_tag(ER_RECORD_IDENTIFIER);

/* Tax Year */
	g_re_record(ER_TAX_YEAR).employer_data := p_reporting_year;
	g_re_record(ER_TAX_YEAR).employer_tag	 := ltr_re_data_tag(ER_TAX_YEAR);

/*	Agent Indicator Code
	Employer - Agent(EIN)
	Agent for EIN                                      */
	--
	--  EIN Validation
	--
	l_validated_EIN :=
			pay_us_report_data_validation.validate_W2_EIN( 'FED',
											      l_input_record_name,
											      ltr_ue_name_table(1).ue_value,
											      empr_out_10,
											      empr_validate_flag,
											      l_err
											    );
        /* If Employer is 2678 Filer Agent EIN is reported otherwise Not */
	IF ltr_ue_name_table(20).ue_value = 'Y'
	THEN
        --{
		g_re_record(ER_AGENT_INDICATOR_CODE).employer_data := ltr_ue_name_table(20).ue_value;
		g_re_record(ER_AGENT_INDICATOR_CODE).employer_tag	 := ltr_re_data_tag(ER_AGENT_INDICATOR_CODE);

		g_re_record(ER_EIN).employer_data	:= l_validated_EIN;
		g_re_record(ER_EIN).employer_tag	:= ltr_re_data_tag(ER_EIN);

		g_re_record(ER_AGENT_EIN).employer_data	:= g_submitter_ein;
		g_re_record(ER_AGENT_EIN).employer_tag	:= ltr_re_data_tag(ER_AGENT_EIN);

        --}
	ELSE
	--{
		g_re_record(ER_AGENT_INDICATOR_CODE).employer_data	:= ' ';
		g_re_record(ER_AGENT_INDICATOR_CODE).employer_tag	:= ltr_re_data_tag(ER_AGENT_INDICATOR_CODE);

		g_re_record(ER_EIN).employer_data	:= l_validated_EIN;
		g_re_record(ER_EIN).employer_tag	:= ltr_re_data_tag(ER_EIN);

		g_re_record(ER_AGENT_EIN).employer_data	:= ' ';
		g_re_record(ER_AGENT_EIN).employer_tag	:= ltr_re_data_tag(ER_AGENT_EIN);
	--}
	END IF;
/* Terminating Business Indicator               */
	g_re_record(ER_TERMINATE_BUSINESS_IND).employer_data	:=ltr_ue_name_table(2).ue_value;
	g_re_record(ER_TERMINATE_BUSINESS_IND).employer_tag	:= ltr_re_data_tag(ER_TERMINATE_BUSINESS_IND);

/* Establishment Number                         */
	g_re_record(ESTABLISHMENT_NUMBER).employer_data	:=' ';
	g_re_record(ESTABLISHMENT_NUMBER).employer_tag	:= ltr_re_data_tag(ESTABLISHMENT_NUMBER);

/* Other EIN                                   */
	g_re_record(ER_OTHER_EIN).employer_data	:=ltr_ue_name_table(3).ue_value;
	g_re_record(ER_OTHER_EIN).employer_tag	:= ltr_re_data_tag(ER_OTHER_EIN);

/* Employer Name                                */
	g_re_record(ER_NAME).employer_data	:=ltr_ue_name_table(4).ue_value;
	g_re_record(ER_NAME).employer_tag	:= ltr_re_data_tag(ER_NAME);

/* Employer, Location Address                  */
	g_re_record(ER_ADDRESS).employer_data	:=empr_out_1;
	g_re_record(ER_ADDRESS).employer_tag	:= ltr_re_data_tag(ER_ADDRESS);

/* Employer, Delivery Address                   */
	g_re_record(ER_DELIVERY_ADDRESS).employer_data	:= empr_out_2;
	g_re_record(ER_DELIVERY_ADDRESS).employer_tag	:= ltr_re_data_tag(ER_DELIVERY_ADDRESS);

/* Employer, City                               */
	g_re_record(ER_CITY).employer_data	:= empr_out_3;
	g_re_record(ER_CITY).employer_tag	:= ltr_re_data_tag(ER_CITY);

/* Employer, State Abbreviation                 */
	g_re_record(ER_STATE_ABBREVIATION).employer_data	:= empr_out_4;
	g_re_record(ER_STATE_ABBREVIATION).employer_tag	:= ltr_re_data_tag(ER_STATE_ABBREVIATION);

/* Employer, Zip Code                           */
	g_re_record(ER_ZIP_CODE).employer_data	:= empr_out_5;
	g_re_record(ER_ZIP_CODE).employer_tag	:= ltr_re_data_tag(ER_ZIP_CODE);

/* Employer, Zip Code Extension                 */
	g_re_record(ER_ZIP_CODE_EXTENSION).employer_data	:= empr_out_6;
	g_re_record(ER_ZIP_CODE_EXTENSION).employer_tag	:= ltr_re_data_tag(ER_ZIP_CODE_EXTENSION);

/* Employer, Foriegn State or Province          */
	g_re_record(ER_FOREIGN_STATE_PROVINCE).employer_data	:= empr_out_7;
	g_re_record(ER_FOREIGN_STATE_PROVINCE).employer_tag	:= ltr_re_data_tag(ER_FOREIGN_STATE_PROVINCE);

/* Employer, Foriegn Postal Code                */
	g_re_record(ER_FOREIGN_POSTAL_CODE).employer_data	:= empr_out_8;
	g_re_record(ER_FOREIGN_POSTAL_CODE).employer_tag	:= ltr_re_data_tag(ER_FOREIGN_POSTAL_CODE);

/* Employer, Country Code                       */
	g_re_record(ER_COUNTRY_CODE).employer_data	:= empr_out_9;
	g_re_record(ER_COUNTRY_CODE).employer_tag	:= ltr_re_data_tag(ER_COUNTRY_CODE);

/* Employment Code                              */
-- ltr_ue_name_table(17).ue_value has  A_LC_FEDERAL_TAX_RULES_ORG_GOVERNMENT_EMPLOYER

	g_re_record(ER_GOVT_EMPLOYER).employer_data :=ltr_ue_name_table(17).ue_value;
	g_re_record(ER_GOVT_EMPLOYER).employer_tag   := ltr_re_data_tag(ER_GOVT_EMPLOYER);

    	g_re_record(ER_TYPE_OF_EMPLOYMENT).employer_data :=ltr_ue_name_table(18).ue_value;
	g_re_record(ER_TYPE_OF_EMPLOYMENT).employer_tag   := ltr_re_data_tag(ER_TYPE_OF_EMPLOYMENT);

    IF ltr_ue_name_table(17).ue_value = 'N' THEN
	g_re_record(ER_EMPLOYMENT_CODE).employer_data := ltr_ue_name_table(18).ue_value;
	g_re_record(ER_EMPLOYMENT_CODE).employer_tag	  := ltr_re_data_tag(ER_EMPLOYMENT_CODE);
    ELSE
	g_re_record(ER_EMPLOYMENT_CODE).employer_data := 'R' ;
	g_re_record(ER_EMPLOYMENT_CODE).employer_tag	  := ltr_re_data_tag(ER_EMPLOYMENT_CODE);
    END IF;

/* Tax Jurisdiction Code         */
    IF ltr_ue_name_table(6).ue_value = 'P' THEN
	g_re_record(ER_TAX_JD_CODE).employer_data := ltr_ue_name_table(6).ue_value;
	g_re_record(ER_TAX_JD_CODE).employer_tag	  := ltr_re_data_tag(ER_TAX_JD_CODE);
    ELSE
	g_re_record(ER_TAX_JD_CODE).employer_data	:= ' ' ;
	g_re_record(ER_TAX_JD_CODE).employer_tag	:= ltr_re_data_tag(ER_TAX_JD_CODE);
    END IF;

/* Third Party Sick Pay Indicator               */
    IF ltr_ue_name_table(7).ue_value = 'Y' THEN
	g_re_record(ER_THIRD_PARTY_SICK_PAY_IND).employer_data := '1';
	g_re_record(ER_THIRD_PARTY_SICK_PAY_IND).employer_tag	  := ltr_re_data_tag(ER_THIRD_PARTY_SICK_PAY_IND);
    ELSE
	g_re_record(ER_THIRD_PARTY_SICK_PAY_IND).employer_data	:= '0' ;
	g_re_record(ER_THIRD_PARTY_SICK_PAY_IND).employer_tag	:= ltr_re_data_tag(ER_THIRD_PARTY_SICK_PAY_IND);
    END IF;

/* Social Security Wage Base */
    g_re_record(ER_SS_EE_WAGE_BASE).employer_data	:= ltr_ue_name_table(8).ue_value ;
    g_re_record(ER_SS_EE_WAGE_BASE).employer_tag	:= ltr_re_data_tag(ER_SS_EE_WAGE_BASE);

/* Social Security Wage Base Rate*/
    g_re_record(ER_SS_EE_WAGE_RATE).employer_data	:= ltr_ue_name_table(9).ue_value ;
    g_re_record(ER_SS_EE_WAGE_RATE).employer_tag	:= ltr_re_data_tag(ER_SS_EE_WAGE_RATE);

/* 1099R Transmitter Code*/
    g_re_record(ER_1099R_TRANSMITTER_CODE).employer_data	:= ltr_ue_name_table(10).ue_value ;
    g_re_record(ER_1099R_TRANSMITTER_CODE).employer_tag	:= ltr_re_data_tag(ER_1099R_TRANSMITTER_CODE);

/* 1099R Transmitter Indicator */
    g_re_record(ER_1099R_TRANSMITTER_INDICATOR).employer_data	:= ltr_ue_name_table(11).ue_value ;
    g_re_record(ER_1099R_TRANSMITTER_INDICATOR).employer_tag	:= ltr_re_data_tag(ER_1099R_TRANSMITTER_INDICATOR);

/* 1099R Transmitter Bureau Indicator */
    g_re_record(ER_1099R_BUREAU_INDICATOR).employer_data	:= ltr_ue_name_table(12).ue_value ;
    g_re_record(ER_1099R_BUREAU_INDICATOR).employer_tag	:= ltr_re_data_tag(ER_1099R_BUREAU_INDICATOR);

/* 1099R Combined Federal and State Filer */
    g_re_record(ER_1099R_COMBINED_FILER).employer_data	:= ltr_ue_name_table(13).ue_value ;
    g_re_record(ER_1099R_COMBINED_FILER).employer_tag	:= ltr_re_data_tag(ER_1099R_COMBINED_FILER);

/* State SIT Company Id number  */
    g_re_record(ER_SIT_COMPANY_STATE_ID).employer_data	:= ltr_ue_name_table(14).ue_value ;
    g_re_record(ER_SIT_COMPANY_STATE_ID).employer_tag	:= ltr_re_data_tag(ER_SIT_COMPANY_STATE_ID);

/* State SUI Company Id number  */
    g_re_record(ER_SUI_COMPANY_STATE_ID).employer_data	:= ltr_ue_name_table(15).ue_value ;
    g_re_record(ER_SUI_COMPANY_STATE_ID).employer_tag	:= ltr_re_data_tag(ER_SUI_COMPANY_STATE_ID);

/* FIPS Jurisdiction Code  */
    g_re_record(ER_FIPS_CODE_JD).employer_data	:= ltr_ue_name_table(16).ue_value ;
    g_re_record(ER_FIPS_CODE_JD).employer_tag	:= ltr_re_data_tag(ER_FIPS_CODE_JD);

/* Blocking Factor  */
    g_re_record(ER_BLOCKING_FACTOR).employer_data	:= ltr_ue_name_table(19).ue_value ;
    g_re_record(ER_BLOCKING_FACTOR).employer_tag	:= ltr_re_data_tag(ER_BLOCKING_FACTOR);

/* W2 2678 Filer */
    g_re_record(ER_W2_2678_FILER).employer_data	:= ltr_ue_name_table(20).ue_value ;
    g_re_record(ER_W2_2678_FILER).employer_tag	:= ltr_re_data_tag(ER_W2_2678_FILER);

/* Company Name */
    g_re_record(ER_COMPANY_NAME).employer_data	:= ltr_ue_name_table(21).ue_value ;
    g_re_record(ER_COMPANY_NAME).employer_tag	:= ltr_re_data_tag(ER_COMPANY_NAME);

/* Cotact Name */
    g_re_record(ER_CONTACT_NAME).employer_data	:= ltr_ue_name_table(22).ue_value ;
    g_re_record(ER_CONTACT_NAME).employer_tag	:= ltr_re_data_tag(ER_CONTACT_NAME);

/* Perferred Method of Problem Notification Code */
    g_re_record(ER_NOTIFICATION_METHOD).employer_data	:= ltr_ue_name_table(23).ue_value ;
    g_re_record(ER_NOTIFICATION_METHOD).employer_tag		:= ltr_re_data_tag(ER_NOTIFICATION_METHOD);

/* Preparer Code */
    g_re_record(ER_PREPARER).employer_data				:= ltr_ue_name_table(24).ue_value ;
    g_re_record(ER_PREPARER).employer_tag				:= ltr_re_data_tag(ER_PREPARER);

    SELECT fnd_global.local_chr(13) || fnd_global.local_chr(10) INTO EOL
       FROM dual;

    l_final_xml_string :=  '<EMPLOYER>'||EOL;

    FOR I IN 1 .. g_ra_no_of_tag	 LOOP
		l_final_xml_string := l_final_xml_string || '<'||g_re_record(I).employer_tag||'>'||
                                                     convert_special_char(g_re_record(I).employer_data)
						     ||'</'||g_re_record(I).employer_tag||'>'|| EOL;
--                HR_UTILITY_TRACE(l_final_xml_string);
    END LOOP;
    HR_UTILITY_TRACE(l_final_xml_string);
    p_final_string := l_final_xml_string;
--pay_us_mmref_local_xml.write_to_magtape_lob(l_final_xml_string);
--pay_core_files.write_to_magtape_lob(l_final_xml_string);
--}
END populate_arch_employer;  -- End of Procedure populate_arch_employer


--
-- This procedure would be used to populate the Tag used for RW, RO, RS Data Record
--
PROCEDURE populate_ee_data_tag
IS
	i	number;
BEGIN

	ltr_ee_data_tag(1) := 'RW_RECORD_IDENTIFIER';
	ltr_ee_data_tag(2) := 'EE_SSN';
	ltr_ee_data_tag(3) := 'EE_FIRST_NAME';
	ltr_ee_data_tag(4) := 'EE_MIDDLE_INITIAL';
	ltr_ee_data_tag(5) := 'EE_LAST_NAME';
	ltr_ee_data_tag(6) := 'EE_SUFFIX';
	ltr_ee_data_tag(7) := 'EE_LOCATION_ADDRESS';
	ltr_ee_data_tag(8) := 'EE_DELIVERY_ADDRESS';
	ltr_ee_data_tag(9) := 'EE_CITY';
	ltr_ee_data_tag(10) := 'EE_STATE_ABBREVIATION';
	ltr_ee_data_tag(11) := 'EE_ZIP_CODE';
	ltr_ee_data_tag(12) := 'EE_ZIP_CODE_EXTENSION';
	ltr_ee_data_tag(13) := 'EE_FOREIGN_STATE_PROVINCE';
	ltr_ee_data_tag(14) := 'EE_FOREIGN_POSTAL_CODE';
	ltr_ee_data_tag(15) := 'EE_COUNTRY_CODE';
	ltr_ee_data_tag(16) := 'FIT_GROSS_WAGES';
	ltr_ee_data_tag(17) := 'FIT_WITHHELD';
	ltr_ee_data_tag(18) := 'SS_WAGES';
	ltr_ee_data_tag(19) := 'SS_TAX_WITHHELD';
	ltr_ee_data_tag(20) := 'MEDICARE_WAGES_TIPS';
	ltr_ee_data_tag(21) := 'MEDICARE_TAX_WITHHELD';
	ltr_ee_data_tag(22) := 'SS_TIPS';
	ltr_ee_data_tag(23) := 'EIC_ADVANCE';
	ltr_ee_data_tag(24) := 'W2_DEPENDENT_CARE';
	ltr_ee_data_tag(25) := 'W2_401K ';
	ltr_ee_data_tag(26) := 'W2_403B';
	ltr_ee_data_tag(27) := 'W2_408K ';
	ltr_ee_data_tag(28) := 'W2_457';
	ltr_ee_data_tag(29) := 'W2_501C';
	ltr_ee_data_tag(30) := 'W2_MILITARY_HOUSING';
	ltr_ee_data_tag(31) := 'W2_NONQUAL_457';
	ltr_ee_data_tag(32) := 'W2_HSA';
	ltr_ee_data_tag(33) := 'NON_QUAL_NOT_457';
	ltr_ee_data_tag(34) := 'W2_NONTAX_COMBAT';
	ltr_ee_data_tag(35) := 'W2_GROUP_TERM_LIFE';
	ltr_ee_data_tag(36) := 'W2_NONQUAL_STOCK';
	ltr_ee_data_tag(37) := 'W2_NONQUAL_DEF_COMP';
	ltr_ee_data_tag(38) := 'W2_ROTH_401K';
	ltr_ee_data_tag(39) := 'W2_ROTH_403B';
	ltr_ee_data_tag(40) := 'W2_ASG_STATUTORY_EMPLOYEE';
	ltr_ee_data_tag(41) := 'RETIREMENT_PLAN_INDICATOR';
	ltr_ee_data_tag(42) := 'W2_TP_SICK_PAY_IND';
	ltr_ee_data_tag(43) := 'RO_RECORD_IDENTIFIER';
	ltr_ee_data_tag(44) := 'RO_W2_BOX_8';
	ltr_ee_data_tag(45) := 'RO_UNCOLLECT_TAX_ON_TIPS';
	ltr_ee_data_tag(46) := 'RO_W2_MSA';
	ltr_ee_data_tag(47) := 'RO_W2_408P';
	ltr_ee_data_tag(48) := 'RO_W2_ADOPTION';
	ltr_ee_data_tag(49) := 'RO_W2_UNCOLL_SS_GTL';
	ltr_ee_data_tag(50) := 'RO_W2_UNCOLL_MED_GTL';
	ltr_ee_data_tag(51) := 'RO_W2_409A_NONQUAL_INCOM';
	ltr_ee_data_tag(52) := 'RO_CIVIL_STATUS';
	ltr_ee_data_tag(53) := 'RO_SPOUSE_SSN';
	ltr_ee_data_tag(54) := 'RO_WAGES_SUBJ_PR_TAX';
	ltr_ee_data_tag(55) := 'RO_COMM_SUBJ_PR_TAX';
	ltr_ee_data_tag(56) := 'RO_ALLOWANCE_SUBJ_PR_TAX';
	ltr_ee_data_tag(57) := 'RO_TIPS_SUBJ_PR_TAX';
	ltr_ee_data_tag(58) := 'RO_W2_STATE_WAGES';
	ltr_ee_data_tag(59) := 'RO_PR_TAX_WITHHELD';
	ltr_ee_data_tag(60) := 'RO_RETIREMENT_CONTRIB';
	ltr_ee_data_tag(61) := 'RS_TAXING_ENTITY_CODE';
	ltr_ee_data_tag(62) := 'RS_OPTIONAL_CODE';
	ltr_ee_data_tag(63) := 'RS_REPORTING_PERIOD';
	ltr_ee_data_tag(64) := 'RS_SQWL_UNEMP_INS_WAGES';
	ltr_ee_data_tag(65) := 'RS_SQWL_UNEMP_TXBL_WAGES';
	ltr_ee_data_tag(66) := 'RS_WEEKS_WORKED';
	ltr_ee_data_tag(67) := 'RS_DATE_FIRST_EMPLOYED';
	ltr_ee_data_tag(68) := 'RS_DATE_OF_SEPARATION';
	ltr_ee_data_tag(69) := 'RS_STATE_ER_ACCT_NUM';
	ltr_ee_data_tag(70) := 'RS_STATE_CODE';
	ltr_ee_data_tag(71) := 'RS_STATE_WAGES';
	ltr_ee_data_tag(72) := 'RS_SIT_WITHHELD';
	ltr_ee_data_tag(73) := 'RS_OTHER_STATE_DATA';
	ltr_ee_data_tag(74) := 'RS_STEIC_ADVANCE';
	ltr_ee_data_tag(75) := 'RS_SUI_EE_WITHHELD';
	ltr_ee_data_tag(76) := 'RS_SDI_EE_WITHHELD';
	ltr_ee_data_tag(77) := 'RS_SUPPLEMENTAL_DATA_1';
	ltr_ee_data_tag(78) := 'RS_SUPPLEMENTAL_DATA_2';
	ltr_ee_data_tag(79) := 'FIT_WITHHELD_THIRD_PARTY';
	/* Bug 7456383 : RS_STATE_CONTROL_NUMBER */
	ltr_ee_data_tag(80) := 'RS_STATE_CONTROL_NUMBER';
	--
        -- Following Loop structure used to debug the Tag Values
	--
	FOR I IN ltr_ee_data_tag.first .. ltr_ee_data_tag.last
	LOOP
		HR_UTILITY_TRACE('Tag'||to_char(i)|| ' : '|| ltr_ee_data_tag(i));
	END LOOP;
END populate_ee_data_tag;

--
-- This procedure would be used to populate the Tag used for Employee level Locality Data
--
PROCEDURE populate_ee_locality_tag
IS
	i	number;
BEGIN
-- ltr_ee_locality_tag
	ltr_ee_locality_tag(1) := 'CITY_JURISDICTION';
	ltr_ee_locality_tag(2) := 'CITY_NAME';
	ltr_ee_locality_tag(3) := 'COUNTY_NAME';
	ltr_ee_locality_tag(4) := 'TAX_TYPE';
	ltr_ee_locality_tag(5) := 'CITY_CODE';
	ltr_ee_locality_tag(6) := 'CITY_WAGES';
	ltr_ee_locality_tag(7) := 'CITY_TAX_WITHHELD';

	/* 2180670 */
	ltr_ee_locality_tag(14) := 'CITY_RS_WITHHELD';
	ltr_ee_locality_tag(15) := 'CITY_WK_WITHHELD';
	ltr_ee_locality_tag(16) := 'CITY_RS_WAGES';
	ltr_ee_locality_tag(17) := 'NON_STATE_EARNINGS';
	ltr_ee_locality_tag(18) := 'NON_STATE_WITHHELD';

	-- Bug # 6117216 SD Reporting Changes START
        ltr_ee_locality_tag(8) := 'SD_JURISDICTION';
        ltr_ee_locality_tag(9) := 'SD_NAME';
        ltr_ee_locality_tag(10) := 'TAX_TYPE';
        ltr_ee_locality_tag(11) := 'SD_CODE';
        ltr_ee_locality_tag(12) := 'SD_WAGES';
        ltr_ee_locality_tag(13) := 'SD_TAX_WITHHELD';
	-- Bug # 6117216 SD Reporting Changes END

        -- Following Loop structure used to debug the Tag Values
	--
	FOR I IN ltr_ee_locality_tag.first .. ltr_ee_locality_tag.last
	LOOP
		HR_UTILITY_TRACE('Tag'||to_char(i)|| ' : '|| ltr_ee_locality_tag(i));
	END LOOP;
END populate_ee_locality_tag;

--
-- This Procedue would be used to fetch all the employee releated data
-- All the data would then be populated into a global pl/sql based table for
-- construting XML
--
PROCEDURE  populate_arch_employee(
						p_payroll_action_id 			NUMBER
						,p_ye_assignment_action_id	NUMBER
						,p_tax_unit_id				NUMBER
						,p_assignment_id			NUMBER
						,p_date_earned				DATE
						,p_reporting_year			VARCHAR2
						,p_jurisdiction_code			VARCHAR2
						,p_state_code				NUMBER
						,p_state_abbreviation		VARCHAR2
						,p_locality_code			VARCHAR2
						,status					VARCHAR2
						,p_final_string				OUT NOCOPY VARCHAR2
							)
AS
--{
--
-- Declaration of Index Value that will be used for storing and fetching Employer level Data
-- from the global pl/sql table maintained for employer or Tax Unit level data
--
RW_RECORD_IDENTIFIER			NUMBER :=1;
EE_SSN							NUMBER :=2;
EE_FIRST_NAME					NUMBER :=3;
EE_MIDDLE_INITIAL				NUMBER :=4;
EE_LAST_NAME					NUMBER :=5;
EE_SUFFIX						NUMBER :=6;
EE_LOCATION_ADDRESS			NUMBER :=7;
EE_DELIVERY_ADDRESS			NUMBER :=8;
EE_CITY							NUMBER :=9;
EE_STATE_ABBREVIATION		NUMBER :=10;
EE_ZIP_CODE					NUMBER :=11;
EE_ZIP_CODE_EXTENSION		NUMBER :=12;
EE_FOREIGN_STATE_PROVINCE	NUMBER :=13;
EE_FOREIGN_POSTAL_CODE		NUMBER :=14;
EE_COUNTRY_CODE				NUMBER :=15;
FIT_GROSS_WAGES				NUMBER :=16;
FIT_WITHHELD					NUMBER :=17;
SS_WAGES						NUMBER :=18;
SS_TAX_WITHHELD				NUMBER :=19;
MEDICARE_WAGES_TIPS			NUMBER :=20;
MEDICARE_TAX_WITHHELD		NUMBER :=21;
SS_TIPS							NUMBER :=22;
EIC_ADVANCE					NUMBER :=23;
W2_DEPENDENT_CARE			NUMBER :=24;
W2_401K 						NUMBER :=25;
W2_403B						NUMBER :=26;
W2_408K 						NUMBER :=27;
W2_457							NUMBER :=28;
W2_501C						NUMBER :=29;
W2_MILITARY_HOUSING			NUMBER :=30;
W2_NONQUAL_457				NUMBER :=31;
W2_HSA							NUMBER :=32;
NON_QUAL_NOT_457			NUMBER :=33;
W2_NONTAX_COMBAT			NUMBER :=34;
W2_GROUP_TERM_LIFE			NUMBER :=35;
W2_NONQUAL_STOCK			NUMBER :=36;
W2_NONQUAL_DEF_COMP		NUMBER :=37;
W2_ROTH_401K					NUMBER :=38;
W2_ROTH_403B					NUMBER :=39;
W2_ASG_STATUTORY_EMPLOYEE	NUMBER :=40;
RETIREMENT_PLAN_INDICATOR	NUMBER :=41;
W2_TP_SICK_PAY_IND			NUMBER :=42;
RO_RECORD_IDENTIFIER			NUMBER :=43;
RO_W2_BOX_8					NUMBER :=44;
RO_UNCOLLECT_TAX_ON_TIPS	NUMBER :=45;
RO_W2_MSA						NUMBER :=46;
RO_W2_408P						NUMBER :=47;
RO_W2_ADOPTION				NUMBER :=48;
RO_W2_UNCOLL_SS_GTL			NUMBER :=49;
RO_W2_UNCOLL_MED_GTL		NUMBER :=50;
RO_W2_409A_NONQUAL_INCOM	NUMBER :=51;
RO_CIVIL_STATUS				NUMBER :=52;
RO_SPOUSE_SSN					NUMBER :=53;
RO_WAGES_SUBJ_PR_TAX		NUMBER :=54;
RO_COMM_SUBJ_PR_TAX			NUMBER :=55;
RO_ALLOWANCE_SUBJ_PR_TAX	NUMBER :=56;
RO_TIPS_SUBJ_PR_TAX			NUMBER :=57;
RO_W2_STATE_WAGES			NUMBER :=58;
RO_PR_TAX_WITHHELD			NUMBER :=59;
RO_RETIREMENT_CONTRIB		NUMBER :=60;
RS_TAXING_ENTITY_CODE		NUMBER :=61;
RS_OPTIONAL_CODE				NUMBER :=62;
RS_REPORTING_PERIOD			NUMBER :=63;
RS_SQWL_UNEMP_INS_WAGES	NUMBER :=64;
RS_SQWL_UNEMP_TXBL_WAGES	NUMBER :=65;
RS_WEEKS_WORKED				NUMBER :=66;
RS_DATE_FIRST_EMPLOYED		NUMBER :=67;
RS_DATE_OF_SEPARATION		NUMBER :=68;
RS_STATE_ER_ACCT_NUM		NUMBER :=69;
RS_STATE_CODE					NUMBER :=70;
RS_STATE_WAGES				NUMBER :=71;
RS_SIT_WITHHELD				NUMBER :=72;
RS_OTHER_STATE_DATA			NUMBER :=73;
RS_STEIC_ADVANCE				NUMBER :=74;
RS_SUI_EE_WITHHELD			NUMBER :=75;
RS_SDI_EE_WITHHELD			NUMBER :=76;
RS_SUPPLEMENTAL_DATA_1		NUMBER :=77;
RS_SUPPLEMENTAL_DATA_2		NUMBER :=78;
FIT_WITHHELD_THIRD_PARTY	NUMBER :=79;
/* Bug 7456383 : RS_STATE_CONTROL_NUMBER */
RS_STATE_CONTROL_NUMBER		NUMBER :=80;
--
-- Local Variables required for Employee
--
l_payroll_action_id			NUMBER;
l_assignment_id			NUMBER;
l_date_earned				DATE;
l_tax_unit_id				NUMBER;


/* Local Variables for EMPLOYEE INFORMATION Input   */
input_empe_name			VARCHAR2(200)	:= 'EE_ADDRESS';
input_empe_1				VARCHAR2(200)	:= ' ';
input_empe_2				VARCHAR2(200)	:= ' ';
input_empe_3				VARCHAR2(200)	:= ' ';
input_empe_4				VARCHAR2(200)	:= ' ';
input_empe_5              		VARCHAR2(200)	:= ' ';
input_empe_validate_flag	VARCHAR2(200) := 'Y';
/* Local Variables for EMPLOYEE INFORMATION Output  */
empe_exclude_output_flag	VARCHAR2(200)	:= 'N';
empe_out_1				VARCHAR2(200)	:= ' ';
empe_out_2				VARCHAR2(200)	:= ' ';
empe_out_3				VARCHAR2(200)	:= ' ';
empe_out_4				VARCHAR2(200)	:= ' ';
empe_out_5				VARCHAR2(200)	:= ' ';
empe_out_6				VARCHAR2(200)	:= ' ';
empe_out_7				VARCHAR2(200)	:= ' ';
empe_out_8				VARCHAR2(200)	:= ' ';
empe_out_9				VARCHAR2(200)	:= ' ';
empe_out_10				VARCHAR2(200)	:= ' ';

l_input_report_type		        VARCHAR2(200)	:= 'W2';
l_input_report_type_format	VARCHAR2(200)	:= 'MMREF';
l_input_record_name		VARCHAR2(200)	:= 'RW';
l_effective_date			VARCHAR2(200);
l_item_name				VARCHAR2(200);
l_input_report_qualifier		VARCHAR2(200);
i						NUMBER	:=0;
j						NUMBER	:=0;
--PL Table used for storing and manipulating DataBaseItem used for
-- Submitter level information
TYPE ee_ue_rec IS RECORD (
						ue_name			varchar2(200),
						ue_data_level		varchar2(200),
						ue_value			varchar2(200),
						data_type			varchar2(200),
						mandatory		varchar2(200),
						negative_check	varchar2(200)
						);
TYPE ee_ue_record IS TABLE OF ee_ue_rec
				INDEX BY BINARY_INTEGER;
ltr_ue_name_table ee_ue_record;

l_number_ee_dbi			NUMBER := 6;

employee_data				VARCHAR2(200);

-- SRS Parameter

l_srs_trns_pin				VARCHAR2(200);
l_srs_trns_tlcn				VARCHAR2(200);
l_srs_resub_indicator		VARCHAR2(200);

-- Derived Local Variables
l_resub_indicator			VARCHAR2(200);
l_reporting_date			VARCHAR2(200);
l_reporting_period			VARCHAR2(200);

l_err						BOOLEAN := FALSE;
l_validate				VARCHAR2(100);
l_validated_EIN			VARCHAR2(200);

l_final_xml_string			VARCHAR2(32767);
l_data_item_xml			VARCHAR2(32767);
l_last_xml				CLOB;
l_is_temp_final_xml		VARCHAR2(2);
l_output_location			VARCHAR2(100);
l_instr_template			VARCHAR2(100);
EOL						VARCHAR2(10);
l_status					VARCHAR2(200) := 'SUCCESS';
/* Bug 7637211 : Start */
l_status_description		VARCHAR2(1500) ;
/* Bug 7637211 : End */

--
-- RCO Record
--
/* initalize parameters for Bal Call for Puerto Rico */
ro_input_2					VARCHAR2(200);
ro_input_3					VARCHAR2(200);
ro_input_4					VARCHAR2(200);
ro_input_5					VARCHAR2(200);
ro_validate					VARCHAR2(200)	:= 'Y';
ro_exlude_from_out			VARCHAR2(200)	:= 'N';
out_terr_taxabable_allow_per	VARCHAR2(200);
out_terr_taxabale_com_per		VARCHAR2(200);
out_terr_taxabale_tips_per		VARCHAR2(200);
out_sit_with_per				VARCHAR2(200);
out_w2_state_wages			VARCHAR2(200);
ro_out_6						VARCHAR2(200);
ro_out_7						VARCHAR2(200);
ro_out_8						VARCHAR2(200);
ro_out_9						VARCHAR2(200);
ro_out_10					VARCHAR2(200);
out_ret_contrib_perjdgreytd		VARCHAR2(200);
nout_ret_contrib_perjdgreytd		NUMBER := 0;
nout_terr_taxabable_allow_per	NUMBER := 0;
nout_terr_taxabale_com_per		NUMBER := 0;
nout_terr_taxabale_tips_per		NUMBER := 0;
nout_sit_with_per				NUMBER := 0;
nout_total_w2_state_wages		NUMBER := 0;
nout_wages_subject				NUMBER := 0;
l_zero_ro_record				VARCHAR2(200) := 'N';
l_tax_tax_jurisdiction			VARCHAR2(200) := ' ';

/* RS Record Local Varialbes */
l_state_wages					NUMBER := 0;

Cursor c_locality_jurisdiction	(c_asgn_act_id		NUMBER,
						 c_state_code		VARCHAR2,
						 c_locality_code	VARCHAR2)
IS
SELECT  faic1.context   Jurisdiction_code
  FROM	pay_assignment_actions	 paa,		-- YREND PAA
		pay_payroll_actions	 ppa,		-- YREND PPA
		ff_contexts			 fc1,   	-- FOR CITY CONTEXT
		ff_archive_items		 fai1,		-- CITY
		ff_archive_item_contexts	 faic1, 	-- CITY_CONTEXT
		ff_database_items		 fdi1  		--DATABASE_ITEMS FOR CITY_WITHHELD
 WHERE paa.assignment_action_id	= c_asgn_act_id
   AND ppa.payroll_action_id			= paa.payroll_action_id
   AND fc1.context_name				= 'JURISDICTION_CODE'
   AND faic1.context_id				= fc1.context_id
   AND fdi1.user_name				= 'A_CITY_WITHHELD_PER_JD_GRE_YTD'
   AND fdi1.user_entity_id			= fai1.user_entity_id
   AND fai1.context1				= paa.assignment_action_id
   AND fai1.archive_item_id			= faic1.archive_item_id
   AND ltrim(rtrim(faic1.context))		like c_state_code||'%'
   AND c_locality_code				IS NULL
   AND rtrim(ltrim(fai1.value))		<> '0'
   AND EXISTS ( SELECT 'x' from pay_us_city_tax_info_f puctif
			     WHERE puctif.jurisdiction_code	= ltrim(rtrim(faic1.context))
				AND puctif.effective_start_date	<    ppa.effective_date
				AND puctif.effective_end_date	>=   ppa.effective_date
			 )
UNION
SELECT  faic1.context   Jurisdiction_code
  FROM	pay_assignment_actions		paa,		-- YREND PAA
		pay_payroll_actions		ppa,		-- YREND PPA
		ff_contexts				fc1,   	-- FOR CITY CONTEXT
		ff_archive_items			fai1,		-- CITY
		ff_archive_item_contexts		faic1, 	-- CITY_CONTEXT
		ff_database_items			fdi1  		--DATABASE_ITEMS FOR CITY_WITHHELD
 WHERE paa.assignment_action_id	= c_asgn_act_id
   AND ppa.payroll_action_id			= paa.payroll_action_id
   AND fc1.context_name				= 'JURISDICTION_CODE'
   AND faic1.context_id				= fc1.context_id
   AND fdi1.user_name				= 'A_CITY_WITHHELD_PER_JD_GRE_YTD'
   AND fdi1.user_entity_id			= fai1.user_entity_id
   AND fai1.context1				= paa.assignment_action_id
   AND fai1.archive_item_id			= faic1.archive_item_id
   AND substr(ltrim(rtrim(faic1.context)),1,2)	= c_state_code
   AND substr(ltrim(rtrim(faic1.context)),8,4)	= substr(c_locality_code,8,4)
   AND c_locality_code				IS NOT NULL
   AND rtrim(ltrim(fai1.value))		<> '0'
   AND EXISTS ( SELECT 'x' from pay_us_city_tax_info_f puctif
			     WHERE puctif.jurisdiction_code	= ltrim(rtrim(faic1.context))
				AND puctif.effective_start_date	<    ppa.effective_date
				AND puctif.effective_end_date	>=   ppa.effective_date
			 )
	-- Bug # 6117216 SD Reporting Changes START
UNION
SELECT  faic1.context   Jurisdiction_code
  FROM  pay_assignment_actions   paa,           -- YREND PAA
                pay_payroll_actions      ppa,           -- YREND PPA
                ff_contexts                      fc1,           -- FOR CITY CONTEXT
                ff_archive_items                 fai1,          -- CITY
                ff_archive_item_contexts         faic1,         -- CITY_CONTEXT
                ff_database_items                fdi1           --DATABASE_ITEMS FOR CITY_WITHHELD
 WHERE paa.assignment_action_id = c_asgn_act_id
   AND ppa.payroll_action_id                    = paa.payroll_action_id
   AND fc1.context_name                         = 'JURISDICTION_CODE'
   AND faic1.context_id                         = fc1.context_id
   AND fdi1.user_name                           = 'A_SCHOOL_WITHHELD_PER_JD_GRE_YTD'
   AND fdi1.user_entity_id                      = fai1.user_entity_id
   AND fai1.context1                            = paa.assignment_action_id
   AND fai1.archive_item_id                     = faic1.archive_item_id
   AND   ltrim(rtrim(faic1.context))	like c_state_code||'%'
                 AND   (c_locality_code IS NULL OR
		              ( c_locality_code IS NOT NULL
			        AND EXISTS ( SELECT 'x' from PAY_US_CITY_SCHOOL_DSTS puctif
                                                WHERE
                                                puctif.state_code = c_state_code
                                                and puctif.state_code ||'-'||
					                            puctif.county_code || '-'|| puctif.city_code = c_locality_code
					                            and c_state_code || '-'|| puctif.school_dst_code = ltrim(rtrim(faic1.context))

                                                 )
                                )
                              )
    AND rtrim(ltrim(fai1.value))         <> '0' ;

	-- Bug # 6117216 SD Reporting Changes END



l_locality_code			VARCHAR2(200);
l_jurisdiction_code			VARCHAR2(200);
l_city_name				VARCHAR2(200);
l_county_name				VARCHAR2(200);
l_tax_type				VARCHAR2(200);
l_city_code				VARCHAR2(200);
l_city_wages				VARCHAR2(200);
l_city_tax_withheld			VARCHAR2(200);
on_visa                     varchar2(5);
non_state_res                  varchar2(5);

CITY_JURISDICTION		NUMBER := 1;
CITY_NAME				NUMBER := 2;
COUNTY_NAME			NUMBER := 3;
TAX_TYPE				NUMBER := 4;
CITY_CODE				NUMBER := 5;
CITY_WAGES			NUMBER := 6;
CITY_TAX_WITHHELD		NUMBER := 7;
CITY_RS_WITHHELD NUMBER := 8 ;
CITY_WK_WITHHELD NUMBER := 9;
CITY_RS_WAGES NUMBER := 10 ;
NON_STATE_EARNINGS NUMBER := 11 ;
NON_STATE_WITHHELD NUMBER := 12 ;

--PL Table used for storing and manipulating DataBaseItem used for
-- Employee level locality Data
TYPE ee_locality_ue_rec IS RECORD (
						ue_name			varchar2(200),
						ue_data_level		varchar2(200),
						ue_value			varchar2(200),
						data_type			varchar2(200),
						mandatory		varchar2(200),
						negative_check	varchar2(200)
						);
TYPE ee_locality_ue_record IS TABLE OF ee_locality_ue_rec
						  INDEX BY BINARY_INTEGER;
ltr_ue_locality ee_locality_ue_record;
k						NUMBER	:= 0;

CURSOR c_city_data(c_jurisdiction_code	VARCHAR2,
						 c_effective_date		VARCHAR2)
IS
	SELECT	c.city_name		city_name,
			n.county_name		county_name,
			'C'				tax_type,
			a.city_information1	city_code
 from	pay_us_city_tax_info_f	a,
		pay_us_city_names		c,
		pay_us_counties		n
 where sysdate between a.effective_start_date and a.effective_end_date
   and a.jurisdiction_code	= c_jurisdiction_code
   and c.primary_flag		= 'Y'
   and a.city_tax			= 'Y'
   and c.city_code			= substr(a.jurisdiction_code,8,4)
   and c.county_code		= substr(a.jurisdiction_code,4,3)
   and c.state_code			= substr(a.jurisdiction_code,1,2)
   and c.county_code		= n.county_code
   and c.state_code			= n.state_code;

	-- Bug # 6117216 SD Reporting Changes START
CURSOR  c_sd_data (c_jurisdiction_code    VARCHAR2)
IS
        SELECT  distinct c.school_dst_name,
                        'SD' tax_type,
                        substr(c_jurisdiction_code,4,5) city_code
 from   pay_us_city_school_dsts c
 where c.school_dst_code    = substr(c_jurisdiction_code,4,5)
   and c.state_code         = substr(c_jurisdiction_code,1,2);
	-- Bug # 6117216 SD Reporting Changes END

/* End of Variable Declarations */
BEGIN
--{
--
-- Fetch all Context or Parameters set at the Transmitter Cursor
--

l_tax_unit_id		:=  p_tax_unit_id;
l_payroll_action_id	:=  p_payroll_action_id;
l_date_earned		:=  p_date_earned;
l_reporting_date	:=  '31-DEC-'||p_reporting_year;
l_effective_date	:=  l_reporting_date;
l_reporting_period	:= '12' || p_reporting_year;

--
-- Fetch SRS Parameter
--
l_srs_trns_pin			:= pay_magtape_generic.get_parameter_value('TRNS_PIN');
l_srs_trns_tlcn			:= pay_magtape_generic.get_parameter_value('TRNS_TLCN');

l_input_report_qualifier	:= pay_magtape_generic.get_parameter_value('TRANSFER_STATE');

ltr_ue_name_table.delete;
i := 0;
--
-- Fetch Archived Values of various DBIs used in submitter Record
--
i := i +1;
ltr_ue_name_table(i).ue_name := 'A_PER_NATIONAL_IDENTIFIER';	-- AI		1
ltr_ue_name_table(i).ue_data_level := 'PER';
i := i +1;
ltr_ue_name_table(i).ue_name := 'A_PER_FIRST_NAME';				-- AI		2
ltr_ue_name_table(i).ue_data_level := 'PER';
i := i +1;
ltr_ue_name_table(i).ue_name := 'A_PER_MIDDLE_NAMES' ;			--AI		3
ltr_ue_name_table(i).ue_data_level := 'PER';
i := i +1;
ltr_ue_name_table(i).ue_name := 'A_PER_LAST_NAME';				--AI		4
ltr_ue_name_table(i).ue_data_level := 'PER';
i := i +1;
ltr_ue_name_table(i).ue_name := 'A_PER_SUFFIX';					--AI		5
ltr_ue_name_table(i).ue_data_level := 'PER';
i := i +1;
ltr_ue_name_table(i).ue_name := 'A_GROSS_EARNINGS_PER_GRE_YTD'; --AI	6
ltr_ue_name_table(i).ue_data_level :='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check := 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name := 'A_FIT_WITHHELD_PER_GRE_YTD';	--AI		7
ltr_ue_name_table(i).ue_data_level :='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check := 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name := 'A_SS_EE_TAXABLE_PER_GRE_YTD';	--AI		8
ltr_ue_name_table(i).ue_data_level :='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check := 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name := 'A_SS_EE_WITHHELD_PER_GRE_YTD';	  --AI	9
ltr_ue_name_table(i).ue_data_level :='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check := 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name := 'A_MEDICARE_EE_TAXABLE_PER_GRE_YTD';	--AI	10
ltr_ue_name_table(i).ue_data_level :='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check := 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name := 'A_MEDICARE_EE_WITHHELD_PER_GRE_YTD'; --AI	11
ltr_ue_name_table(i).ue_data_level :='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check := 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_BOX_7_PER_GRE_YTD';	--AI	12
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_EIC_ADVANCE_PER_GRE_YTD';	--AI	13
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_DEPENDENT_CARE_PER_GRE_YTD';	--AI	14
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_401K_PER_GRE_YTD';		--AI	15
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_403B_PER_GRE_YTD';		--AI	16
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_408K_PER_GRE_YTD';		--AI	17
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_457_PER_GRE_YTD';		--AI	18
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_501C_PER_GRE_YTD';		--AI	19
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_NONQUAL_PLAN_PER_GRE_YTD';	--AI	20
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_NONQUAL_457_PER_GRE_YTD';	--AI	21
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_GROUP_TERM_LIFE_PER_GRE_YTD';  --AI	22
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_NONQUAL_STOCK_PER_GRE_YTD';  --AI	23
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_ASG_STATUTORY_EMPLOYEE';  --AI	24
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_PENSION_PLAN_PER_GRE_YTD';  --AI	25
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_DEF_COMP_401K_PER_GRE_YTD';  --AI	26
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_FIT_3RD_PARTY_PER_GRE_YTD';  --AI	27
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_LC_W2_REPORTING_RULES_ORG_THIRD_PARTY_SICK_PAY';  --AI	28
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_REGULAR_EARNINGS_PER_GRE_YTD';  --AI	29
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD';  --AI	 30
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_DEF_COMP_401K_PER_GRE_YTD';  --AI	31
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_DEF_COMP_401K_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD';  --AI	32
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_SECTION_125_PER_GRE_YTD';  --AI		33
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_SECTION_125_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD';  --AI		34
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_DEPENDENT_CARE_PER_GRE_YTD';  --AI		35
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_DEPENDENT_CARE_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD';  --AI		36
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD'; -- AI 37
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_TP_SICK_PAY_PER_GRE_YTD';  --AI		38
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_NONTAX_COMBAT_PER_GRE_YTD';  --AI		39
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_NONQUAL_DEF_COMP_PER_GRE_YTD';  --AI		40
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_ROTH_401K_PER_GRE_YTD';  --AI		41
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_ROTH_403B_PER_GRE_YTD';  --AI		42
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_PRE_TAX_DEDUCTIONS_PER_GRE_YTD';  --AI		43
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD';  --AI		44
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD';  --AI	45
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

-- RO Record Archived Data Item
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_BOX_8_PER_GRE_YTD';  --AI	46
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_UNCOLL_SS_TAX_TIPS_PER_GRE_YTD';  --AI	47
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_UNCOLL_MED_TIPS_PER_GRE_YTD';  --AI	48
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_MSA_PER_GRE_YTD';  --AI	49
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_408P_PER_GRE_YTD';  --AI	50
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_ADOPTION_PER_GRE_YTD';  --AI	51
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_UNCOLL_SS_GTL_PER_GRE_YTD';  --AI	52
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_UNCOLL_MED_GTL_PER_GRE_YTD';  --AI	53
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_409A_NONQUAL_INCOME_PER_GRE_YTD';  --AI	54
ltr_ue_name_table(i).ue_data_level	:='FED';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

--
--  Following User Entities are used for RS record
--

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_EMP_PER_HIRE_DATE';  --AI	55
ltr_ue_name_table(i).ue_data_level	:= 'PER';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_EMP_PER_SEPARATION_DATE';  --AI	56
ltr_ue_name_table(i).ue_data_level	:= 'PER';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_STATE_ASG_FILING_STATUS_CODE';  --AI	57
ltr_ue_name_table(i).ue_data_level	:= 'PER';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_SCL_ASG_US_WORK_SCHEDULE';  --AI	58
ltr_ue_name_table(i).ue_data_level	:= 'PER';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_ASG_HOURS';  --AI	59
ltr_ue_name_table(i).ue_data_level	:= 'PER';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_ASG_FREQ';  --AI	60
ltr_ue_name_table(i).ue_data_level	:= 'PER';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_SCL_ASG_US_NJ_PLAN_ID';  --AI	61
ltr_ue_name_table(i).ue_data_level	:= 'PER';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_STATE_ASG_WITHHOLDING_ALLOWANCES';  --AI	62
ltr_ue_name_table(i).ue_data_level	:= 'PER';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD';  	--AI	63
ltr_ue_name_table(i).ue_data_level	:= 'STATE';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD';  	--AI	64
ltr_ue_name_table(i).ue_data_level	:= 'STATE';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_YTD';  	--AI	65
ltr_ue_name_table(i).ue_data_level	:= 'STATE';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_YTD';  	--AI	66
ltr_ue_name_table(i).ue_data_level	:= 'STATE';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_W2_STATE_WAGES';  					--AI	67
ltr_ue_name_table(i).ue_data_level	:= 'STATE';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_SIT_WITHHELD_PER_JD_GRE_YTD';  		--AI	68
ltr_ue_name_table(i).ue_data_level	:= 'STATE';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_STEIC_ADVANCE_PER_JD_GRE_YTD';  		--AI	69
ltr_ue_name_table(i).ue_data_level	:= 'STATE';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_SUI_EE_WITHHELD_PER_JD_GRE_YTD';  		--AI	70
ltr_ue_name_table(i).ue_data_level	:= 'STATE';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_SDI_EE_WITHHELD_PER_JD_GRE_YTD';  		--AI	71
ltr_ue_name_table(i).ue_data_level	:= 'STATE';
ltr_ue_name_table(i).data_type		:='AMT';
ltr_ue_name_table(i).negative_check	:= 'Y';

--
-- Fetch GRE level archived data  to be used in State level Record
--
i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_FIPS_CODE_JD';  		--AI	72
ltr_ue_name_table(i).ue_data_level	:= 'GRE';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_STATE_TAX_RULES_ORG_SIT_COMPANY_STATE_ID';  		--AI	73
ltr_ue_name_table(i).ue_data_level	:= 'GRE';

i := i +1;
ltr_ue_name_table(i).ue_name		:= 'A_STATE_TAX_RULES_ORG_SUI_COMPANY_STATE_ID';  		--AI	74
ltr_ue_name_table(i).ue_data_level	:= 'GRE';

--
-- End of setting User Entities to PL/Table
--

HR_UTILITY_TRACE('DBI  Count '||to_char(ltr_ue_name_table.count));
HR_UTILITY_TRACE('YE Archive Assignment Action Id '||
					to_char(p_ye_assignment_action_id));

IF ltr_ue_name_table.count > 0 then
           FOR j IN ltr_ue_name_table.first .. ltr_ue_name_table.last
	   LOOP
		IF ltr_ue_name_table(j).ue_data_level = 'PER'
		THEN
			ltr_ue_name_table(j).ue_value :=
				hr_us_w2_rep.get_per_item(	p_ye_assignment_action_id,
										ltr_ue_name_table(j).ue_name);
		ELSIF ltr_ue_name_table(J).ue_data_level ='FED'  THEN
		         ltr_ue_name_table(j).ue_value := hr_us_w2_rep.get_w2_arch_bal(
							 p_ye_assignment_action_id
							,ltr_ue_name_table(j).ue_name
							,p_tax_unit_id
							,'00-000-0000'
							, 0);
                        IF ( ltr_ue_name_table(j).data_type = 'AMT'  AND
                               to_number(ltr_ue_name_table(j).ue_value) < 0)
			THEN
				l_status	:= 'FAILED';
				/* Bug 7637211 : Start */
				l_status_description := SUBSTR(l_status_description || 'Archive Item ' || ltr_ue_name_table(j).ue_name || ' has negative balance(' || to_number(ltr_ue_name_table(j).ue_value) || '). ',1,1500);
				/* Bug 7637211 : End */
			END IF;
		ELSIF ltr_ue_name_table(J).ue_data_level ='STATE'  THEN
		         ltr_ue_name_table(j).ue_value :=
			                hr_us_w2_rep.get_w2_arch_bal(
							 p_ye_assignment_action_id
							,ltr_ue_name_table(j).ue_name
							,p_tax_unit_id
							/* Bug 7592972 : State Code should be passed as
							two character long code
							,p_state_code||'-000-0000'*/
							,lpad(p_state_code,2,'0')||'-000-0000'
							, 2);
                        IF ( ltr_ue_name_table(j).data_type = 'AMT'  AND
                               to_number(ltr_ue_name_table(j).ue_value) < 0)
			THEN
				l_status	:= 'FAILED';
				/* Bug 7637211 : Start */
				l_status_description := SUBSTR(l_status_description || 'Archive Item ' || ltr_ue_name_table(j).ue_name || ' has negative balance(' || to_number(ltr_ue_name_table(j).ue_value) || '). ',1,1500);
				/* Bug 7637211 : End */
			END IF;
		ELSIF ltr_ue_name_table(J).ue_data_level ='GRE'  THEN
		         ltr_ue_name_table(j).ue_value :=
				hr_us_w2_rep.get_state_item(
							p_tax_unit_id,
							/* Bug 7592972 : State Code should be passed as
							two character long code
							p_state_code||'-000-0000',*/
							lpad(p_state_code,2,'0')||'-000-0000',
							p_payroll_action_id,
							ltr_ue_name_table(j).ue_name);
                ELSE
			ltr_ue_name_table(j).ue_value := ' ';
		END IF;
                HR_UTILITY_TRACE('DBI ' || ltr_ue_name_table(J).ue_data_level ||
						      ' -('||to_char(j)|| ') : < '||ltr_ue_name_table(j).ue_name||
		                                              ' >   VALUE  : < '|| ltr_ue_name_table(j).ue_value||' >');
           END LOOP;
           HR_UTILITY_TRACE('Status of Employee Record ' || l_status);
END IF;

/* ==================================================
   Get Employer or transmitter Company Information releated Submitter
   ================================================== */
employee_data := pay_us_reporting_utils_pkg.get_item_data(
								p_assignment_id,
								l_date_earned,
								l_tax_unit_id,
								l_reporting_date,
								input_empe_name,
								l_input_report_type,
								l_input_report_type_format,
								l_input_report_qualifier,
								l_input_record_name,
								input_empe_1,
								input_empe_2,
								input_empe_3,
								input_empe_4,
								input_empe_5,
								input_empe_validate_flag,
								empe_exclude_output_flag,
								empe_out_1,
								empe_out_2,
								empe_out_3,
								empe_out_4,
								empe_out_5,
								empe_out_6,
								empe_out_7,
								empe_out_8,
								empe_out_9,
								empe_out_10);

    --
    -- Pouplate All the Tags to be used for RE record Data Items
    --
    pay_us_w2_generic_extract.populate_ee_data_tag;

    SELECT fnd_global.local_chr(13) || fnd_global.local_chr(10) INTO EOL
       FROM dual;

    /* Initialize with Default Value */

	FOR I IN ltr_ee_data_tag.first .. ltr_ee_data_tag.last
	LOOP
		g_ee_record(I).employee_data	:= ' ';
		g_ee_record(I).employee_tag	:= ltr_ee_data_tag(I);
	END LOOP;

/* Deriving all data Items that are used for RW record */

/* Record Identifier */
	g_ee_record(RW_RECORD_IDENTIFIER).employee_data	:= 'RW';
        HR_UTILITY_TRACE(g_ee_record(1).employee_tag || ' :  '
					||  g_ee_record(RW_RECORD_IDENTIFIER).employee_data);
/* Employee, Social Security Number (SSN) */
	g_ee_record(EE_SSN).employee_data	:=
								ltr_ue_name_table(1).ue_value;
        HR_UTILITY_TRACE(g_ee_record(EE_SSN).employee_tag || ' :  '
					||  g_ee_record(EE_SSN).employee_data);

/* Employee, First Name */
	/* Bug 7427138 */
	--g_ee_record(EE_FIRST_NAME).employee_data := ltr_ue_name_table(2).ue_value;
	g_ee_record(EE_FIRST_NAME).employee_data := upper(ltr_ue_name_table(2).ue_value);
        HR_UTILITY_TRACE(g_ee_record(EE_FIRST_NAME).employee_tag || ' :  '
					||  g_ee_record(EE_FIRST_NAME).employee_data);

/* Employee, Middle Name or Initial */
	/* Bug 7427138 */
	--g_ee_record(EE_MIDDLE_INITIAL).employee_data := ltr_ue_name_table(3).ue_value;
	g_ee_record(EE_MIDDLE_INITIAL).employee_data := upper(ltr_ue_name_table(3).ue_value);
        HR_UTILITY_TRACE(g_ee_record(EE_MIDDLE_INITIAL).employee_tag || ' :  '
					||  g_ee_record(EE_MIDDLE_INITIAL).employee_data);

/* Employee, Last Name */
	/* Bug 7427138 */
	--g_ee_record(EE_LAST_NAME).employee_data := ltr_ue_name_table(4).ue_value;
	g_ee_record(EE_LAST_NAME).employee_data	:= upper(ltr_ue_name_table(4).ue_value);
        HR_UTILITY_TRACE(g_ee_record(EE_LAST_NAME).employee_tag || ' :  '
					||  g_ee_record(EE_LAST_NAME).employee_data);

/* Employee, Name Suffix */
	/* Bug 7427138 */
	--g_ee_record(EE_SUFFIX).employee_data := ltr_ue_name_table(5).ue_value;
	g_ee_record(EE_SUFFIX).employee_data := upper(ltr_ue_name_table(5).ue_value);
        HR_UTILITY_TRACE(g_ee_record(EE_SUFFIX).employee_tag || ' :  '
					||  g_ee_record(EE_SUFFIX).employee_data);

/* Employee, Location Address */
	g_ee_record(EE_LOCATION_ADDRESS).employee_data	:= empe_out_1;
        HR_UTILITY_TRACE(g_ee_record(EE_LOCATION_ADDRESS).employee_tag || ' :  '
					||  g_ee_record(EE_LOCATION_ADDRESS).employee_data);

/* Pos:  88   Len:  22   Desc: Employee, Delivery Address */
	g_ee_record(EE_DELIVERY_ADDRESS).employee_data	:= empe_out_2;
        HR_UTILITY_TRACE(g_ee_record(EE_DELIVERY_ADDRESS).employee_tag || ' :  '
					||  g_ee_record(EE_DELIVERY_ADDRESS).employee_data);

/* Employee, City */
	g_ee_record(EE_CITY).employee_data	:= empe_out_3;
        HR_UTILITY_TRACE(g_ee_record(EE_CITY).employee_tag || ' :  '
					||  g_ee_record(EE_CITY).employee_data);

/* Employee, State Abbreviation */
	g_ee_record(EE_STATE_ABBREVIATION).employee_data	:= empe_out_4;
        HR_UTILITY_TRACE(g_ee_record(EE_STATE_ABBREVIATION).employee_tag || ' :  '
					||  g_ee_record(EE_STATE_ABBREVIATION).employee_data);

/* Employee, Zip Code */
	g_ee_record(EE_ZIP_CODE).employee_data	:= empe_out_5;
        HR_UTILITY_TRACE(g_ee_record(EE_ZIP_CODE).employee_tag || ' :  '
					||  g_ee_record(EE_ZIP_CODE).employee_data);

/* Employee, Zip Code Extension */
	g_ee_record(EE_ZIP_CODE_EXTENSION).employee_data	:=
												empe_out_6;
        HR_UTILITY_TRACE(g_ee_record(EE_ZIP_CODE_EXTENSION).employee_tag || ' :  '
					||  g_ee_record(EE_ZIP_CODE_EXTENSION).employee_data);

/* Employee, Foreign State - Province */
	g_ee_record(EE_FOREIGN_STATE_PROVINCE).employee_data
												:= empe_out_7;
        HR_UTILITY_TRACE(g_ee_record(EE_FOREIGN_STATE_PROVINCE).employee_tag || ' :  '
					||  g_ee_record(EE_FOREIGN_STATE_PROVINCE).employee_data);

/* Employee, Foreign Postal Code */
	g_ee_record(EE_FOREIGN_POSTAL_CODE).employee_data
												:= empe_out_8;
        HR_UTILITY_TRACE(g_ee_record(EE_FOREIGN_POSTAL_CODE).employee_tag || ' :  '
					||  g_ee_record(EE_FOREIGN_STATE_PROVINCE).employee_data);

/* Pos: 186   Len:   2   Desc: Employee, Country Code */
	g_ee_record(EE_COUNTRY_CODE).employee_data
												:= empe_out_9;
        HR_UTILITY_TRACE(g_ee_record(EE_COUNTRY_CODE).employee_tag || ' :  '
					||  g_ee_record(EE_COUNTRY_CODE).employee_data);

/* Pos: 188   Len:  11   Desc: Wages, Tips and Other Compensation */
	g_ee_record(FIT_GROSS_WAGES).employee_data	:=
				to_char(to_number(ltr_ue_name_table(29).ue_value) +
				to_number(ltr_ue_name_table(37).ue_value) +
				to_number(ltr_ue_name_table(30).ue_value) -
				to_number(ltr_ue_name_table(43).ue_value) +
				to_number(ltr_ue_name_table(44).ue_value) +
				to_number(ltr_ue_name_table(45).ue_value));

        HR_UTILITY_TRACE(g_ee_record(FIT_GROSS_WAGES).employee_tag || ' :  '
					||  g_ee_record(FIT_GROSS_WAGES).employee_data);

/*
FIT_GROSS_WAGES = A_REGULAR_EARNINGS_PER_GRE_YTD +
              A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD +
              A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD -
              A_PRE_TAX_DEDUCTIONS_PER_GRE_YTD +
              A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD +
              A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD
*/

/* Federal Income Tax Withheld */
	g_ee_record(FIT_WITHHELD).employee_data	:= ltr_ue_name_table(7).ue_value;
        HR_UTILITY_TRACE(g_ee_record(FIT_WITHHELD).employee_tag || ' :  '
					||  g_ee_record(FIT_WITHHELD).employee_data);

/* Pos: 210   Len:  11   Desc: Social Security Wages
     SS_WAGES :=  A_SS_EE_TAXABLE_PER_GRE_YTD
                              - A_W2_BOX_7_PER_GRE_YTD
*/
	g_ee_record(SS_WAGES).employee_data	:= to_char(to_number(ltr_ue_name_table(8).ue_value)
						-  to_number(ltr_ue_name_table(12).ue_value));
        HR_UTILITY_TRACE(g_ee_record(SS_WAGES).employee_tag || ' :  '
					||  g_ee_record(SS_WAGES).employee_data);

/* Social Security Tax Withheld */
	g_ee_record(SS_TAX_WITHHELD).employee_data	:= ltr_ue_name_table(9).ue_value;

/* Medicare Wages and Tips */
	g_ee_record(MEDICARE_WAGES_TIPS).employee_data	:= ltr_ue_name_table(10).ue_value;

/* Medicare Tax Withheld */
	g_ee_record(MEDICARE_TAX_WITHHELD).employee_data	:= ltr_ue_name_table(11).ue_value;

/* Social Security Tips */
	g_ee_record(SS_TIPS).employee_data	:= ltr_ue_name_table(12).ue_value;

/* Advance Earned Income Credit */
	g_ee_record(EIC_ADVANCE).employee_data	:= ltr_ue_name_table(13).ue_value;

/* Dependent Care Benefits */
	g_ee_record(W2_DEPENDENT_CARE).employee_data	:= ltr_ue_name_table(14).ue_value;
        HR_UTILITY_TRACE(g_ee_record(W2_DEPENDENT_CARE).employee_tag || ' :  '
					||  g_ee_record(W2_DEPENDENT_CARE).employee_data);

/* Deferred Compensation Contributions to Section 401(k) */
	g_ee_record(W2_401K).employee_data	:= ltr_ue_name_table(15).ue_value;

/* Deferred Compensation Contributions to Section 403(b) */
	g_ee_record(W2_403B).employee_data	:= ltr_ue_name_table(16).ue_value;

/* Deferred Compensation Contributions to Section 408(k)(6) */
	g_ee_record(W2_408K).employee_data	:= ltr_ue_name_table(17).ue_value;

/* Deferred Compensation Contributions to Section 457(b) */
	g_ee_record(W2_457).employee_data	:= ltr_ue_name_table(18).ue_value;
        HR_UTILITY_TRACE(g_ee_record(W2_457).employee_tag || ' :  '
					||  g_ee_record(W2_457).employee_data);

/* Deferred Compensation Contributions to Section 501(c)(18)(D) */
	g_ee_record(W2_501C).employee_data	:= ltr_ue_name_table(19).ue_value;

/* Military Employees Basic Ouarters, Subsistence and Combat Pay
	Not Used
*/
	g_ee_record(W2_MILITARY_HOUSING).employee_data	:= '0';

/* Non-qualified Plan Section 457 Distributions or Contributions */
	g_ee_record(W2_NONQUAL_457).employee_data	:= ltr_ue_name_table(21).ue_value;

/* ER Contibutions to Health Savings Acct
/* Bug 3680056 - New field
   Added function call to fetch the DBI value for the ER contrib to HSA
   input_rwrc_38 = to_char(trunc(get_ff_archive_value('A_W2_HSA_PER_GRE_YTD') * 100))*/
	g_ee_record(W2_HSA).employee_data	:= '0';

/* Non-qualified Plan Not Section 457 Distributions or Contributions */
/* Non Qual Plan not 457 is Nonqual Plan - Nonqaul 457
     (A_W2_NONQUAL_PLAN_PER_GRE_YTD -
      A_W2_NONQUAL_457_PER_GRE_YTD )
*/
	g_ee_record(NON_QUAL_NOT_457).employee_data	:=
								to_char(to_number(ltr_ue_name_table(20).ue_value) -
									     to_number(ltr_ue_name_table(21).ue_value));
        HR_UTILITY_TRACE(g_ee_record(NON_QUAL_NOT_457).employee_tag || ' :  '
					||  g_ee_record(NON_QUAL_NOT_457).employee_data);

/* Non-Taxable Combat Pay (Not for Puerto Rico) */
	g_ee_record(W2_NONTAX_COMBAT).employee_data	:= ltr_ue_name_table(39).ue_value;

/* Employer Cost of Premiums for Group Term Life Insruance over $50,000  */
	g_ee_record(W2_GROUP_TERM_LIFE).employee_data	:= ltr_ue_name_table(22).ue_value;

/* Income from the Exercise of Nonstatutory  Stock Option - Optional for 2001 */
	g_ee_record(W2_NONQUAL_STOCK).employee_data	:= ltr_ue_name_table(23).ue_value;

/* Deferrals Under a Section 409A Non-Qualified Deferred Comp Plan (Not for PR) */
	g_ee_record(W2_NONQUAL_DEF_COMP).employee_data	:= ltr_ue_name_table(40).ue_value;

/* Designated Roth Contributions to a section 401(k) Plan */
	g_ee_record(W2_ROTH_401K).employee_data	:= ltr_ue_name_table(41).ue_value;
        HR_UTILITY_TRACE(g_ee_record(W2_ROTH_401K).employee_tag || ' :  '
					||  g_ee_record(W2_ROTH_401K).employee_data);

/* Designated Roth Contributions Und sec 403(b) Plan */
	g_ee_record(W2_ROTH_403B).employee_data	:= ltr_ue_name_table(42).ue_value;
        HR_UTILITY_TRACE(g_ee_record(W2_ROTH_403B).employee_tag || ' :  '
					||  g_ee_record(W2_ROTH_403B).employee_data);

/* Statutory Employee Indicator   */
    IF ltr_ue_name_table(24).ue_value = 'Y' THEN
	g_ee_record(W2_ASG_STATUTORY_EMPLOYEE).employee_data	:= '1';
    ELSE
	g_ee_record(W2_ASG_STATUTORY_EMPLOYEE).employee_data	:= '0';
    END IF;
        HR_UTILITY_TRACE(g_ee_record(W2_ASG_STATUTORY_EMPLOYEE).employee_tag || ' :  '
					||  g_ee_record(W2_ASG_STATUTORY_EMPLOYEE).employee_data);

/* Retirement Plan Indicator    */
IF (( to_number(ltr_ue_name_table(25).ue_value) > 0) OR
     ( to_number(ltr_ue_name_table(15).ue_value) > 0) OR
     ( to_number(ltr_ue_name_table(16).ue_value) > 0) OR
     ( to_number(ltr_ue_name_table(17).ue_value) > 0) OR
     ( to_number(ltr_ue_name_table(19).ue_value) > 0))
THEN
	g_ee_record(RETIREMENT_PLAN_INDICATOR).employee_data	:= '1';
ELSE
	g_ee_record(RETIREMENT_PLAN_INDICATOR).employee_data	:= '0';
END IF;
        HR_UTILITY_TRACE(g_ee_record(RETIREMENT_PLAN_INDICATOR).employee_tag || ' :  '
					||  g_ee_record(RETIREMENT_PLAN_INDICATOR).employee_data);

/* Third-Party Sick Pay Indicator */
IF to_number(ltr_ue_name_table(38).ue_value) > 0
THEN
	g_ee_record(W2_TP_SICK_PAY_IND).employee_data	:= '1';
ELSE
	g_ee_record(W2_TP_SICK_PAY_IND).employee_data	:= '0';
END IF;
        HR_UTILITY_TRACE(g_ee_record(W2_TP_SICK_PAY_IND).employee_tag || ' :  '
					  ||  g_ee_record(W2_TP_SICK_PAY_IND).employee_data);

/* Income Tax Withheld by Third Party Payer
    This balance is not reported in RW record but summ total is reported at the GRE level in RT record
 */
	g_ee_record(FIT_WITHHELD_THIRD_PARTY).employee_data := ltr_ue_name_table(27).ue_value;
	HR_UTILITY_TRACE(g_ee_record(FIT_WITHHELD_THIRD_PARTY).employee_tag || ' :  '
				 	   ||  g_ee_record(FIT_WITHHELD_THIRD_PARTY).employee_data);

/* RO Record Data Items fetched to build XML components */
out_ret_contrib_perjdgreytd :=
pay_us_reporting_utils_pkg.Get_Territory_Values(
                   p_ye_assignment_action_id,
                   p_tax_unit_id,
                   l_reporting_date,
                  l_input_report_type,
                   l_input_report_type_format,
                   'FED',
                   'RO',
                   empe_out_10,	-- Employee Number
                   ro_input_2,
                   ro_input_3,
                   ro_input_4,
                   ro_input_5,
                   ro_validate,
                   ro_exlude_from_out,
                   out_terr_taxabable_allow_per,
                   out_terr_taxabale_com_per,
                   out_terr_taxabale_tips_per,
                   out_sit_with_per,
                   out_w2_state_wages,
                   ro_out_6,
                   ro_out_7,
                   ro_out_8,
                   ro_out_9,
                   ro_out_10);

nout_ret_contrib_perjdgreytd		:= to_number(out_ret_contrib_perjdgreytd) ;
nout_terr_taxabable_allow_per		:= to_number(out_terr_taxabable_allow_per);
nout_terr_taxabale_com_per		:= to_number(out_terr_taxabale_com_per);
nout_terr_taxabale_tips_per		:= to_number(out_terr_taxabale_tips_per);
nout_sit_with_per				:= to_number(out_sit_with_per);
nout_total_w2_state_wages		:= to_number(out_w2_state_wages);
nout_wages_subject				:=	( nout_total_w2_state_wages -
								  nout_terr_taxabale_tips_per -
								  nout_terr_taxabable_allow_per -
								  nout_terr_taxabale_com_per );

/*  RO record  balance is = 0 */
IF        to_number(ltr_ue_name_table(46).ue_value) = 0	--A_W2_BOX_8_PER_GRE_YTD
  AND to_number(ltr_ue_name_table(47).ue_value) = 0	--A_W2_UNCOLL_SS_TAX_TIPS_PER_GRE_YTD
  AND to_number(ltr_ue_name_table(48).ue_value) = 0	--A_W2_UNCOLL_MED_TIPS_PER_GRE_YTD
  AND to_number(ltr_ue_name_table(49).ue_value) = 0	--A_W2_MSA_PER_GRE_YTD
  AND to_number(ltr_ue_name_table(50).ue_value) = 0	--A_W2_408P_PER_GRE_YTD
  AND to_number(ltr_ue_name_table(51).ue_value) = 0	--A_W2_ADOPTION_PER_GRE_YTD
  AND to_number(ltr_ue_name_table(52).ue_value) = 0	--A_W2_UNCOLL_SS_GTL_PER_GRE_YTD
  AND to_number(ltr_ue_name_table(53).ue_value) = 0	--A_W2_UNCOLL_MED_GTL_PER_GRE_YTD
  AND to_number(ltr_ue_name_table(54).ue_value) = 0	--A_W2_409A_NONQUAL_INCOME_PER_GRE_YTD  = 0  /* Bug 4737567 */
  AND nout_wages_subject				= 0
  AND nout_total_w2_state_wages			= 0
  AND nout_terr_taxabale_tips_per			= 0
  AND nout_ret_contrib_perjdgreytd		= 0
  AND nout_terr_taxabable_allow_per		= 0
  AND nout_sit_with_per				= 0
THEN
	 l_zero_ro_record := 'Y';
 Else
	l_zero_ro_record  := 'N';
END IF;

/* RO Record Identifier */
	g_ee_record(RO_RECORD_IDENTIFIER).employee_data	:= 'RO';
	HR_UTILITY_TRACE(g_ee_record(RO_RECORD_IDENTIFIER).employee_tag || ' :  '
					||  g_ee_record(RO_RECORD_IDENTIFIER).employee_data);

/* Allocated Tips                               */
	g_ee_record(RO_W2_BOX_8).employee_data	:= ltr_ue_name_table(46).ue_value;
        HR_UTILITY_TRACE(g_ee_record(RO_W2_BOX_8).employee_tag || ' :  '
					||  g_ee_record(RO_W2_BOX_8).employee_data);

/* Uncollected Employee Tax on Tips             */
	g_ee_record(RO_UNCOLLECT_TAX_ON_TIPS).employee_data	:=
									to_char(to_number(ltr_ue_name_table(47).ue_value) +
									             to_number(ltr_ue_name_table(48).ue_value));
        HR_UTILITY_TRACE(g_ee_record(RO_UNCOLLECT_TAX_ON_TIPS).employee_tag || ' :  '
					||  g_ee_record(RO_UNCOLLECT_TAX_ON_TIPS).employee_data);

/****************************************************************************/
/* Locations 34 to 66 Do not apply to Puerto Rico, Virgin Islands, American */
/*                    Samoa, Guam, or Northern Mariana Islands, Employees.  */
/****************************************************************************/
/* Medical Savings Account                      */
	g_ee_record(RO_W2_MSA).employee_data	:=
									ltr_ue_name_table(49).ue_value;
        HR_UTILITY_TRACE(g_ee_record(RO_W2_MSA).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_W2_MSA).employee_data);

/* Simple Retirement Account                    */
	g_ee_record(RO_W2_408P).employee_data	:=
									ltr_ue_name_table(50).ue_value;
        HR_UTILITY_TRACE(g_ee_record(RO_W2_408P).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_W2_408P).employee_data);

/* Qualified Adoption Expenses                  */
	g_ee_record(RO_W2_ADOPTION).employee_data	:=
									ltr_ue_name_table(51).ue_value;
        HR_UTILITY_TRACE(g_ee_record(RO_W2_ADOPTION).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_W2_ADOPTION).employee_data);
/****************************************************************************/
/* Uncollected Social Security or RPTA Tax on Cost
                               of Group Term Life Insurance Over $50,000    */
	g_ee_record(RO_W2_UNCOLL_SS_GTL).employee_data	:=
									ltr_ue_name_table(52).ue_value;
        HR_UTILITY_TRACE(g_ee_record(RO_W2_UNCOLL_SS_GTL).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_W2_UNCOLL_SS_GTL).employee_data);
/* Uncollected Medicare Tax on Cost of Group Term Life Insurance Over $50,000  */
	g_ee_record(RO_W2_UNCOLL_MED_GTL).employee_data	:=
									ltr_ue_name_table(53).ue_value;
        HR_UTILITY_TRACE(g_ee_record(RO_W2_UNCOLL_MED_GTL).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_W2_UNCOLL_MED_GTL).employee_data);
/* Income Under Sec 409A on Non-Qual Def Comp Plan */
	g_ee_record(RO_W2_409A_NONQUAL_INCOM).employee_data	:=
									ltr_ue_name_table(54).ue_value;
        HR_UTILITY_TRACE(g_ee_record(RO_W2_409A_NONQUAL_INCOM).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_W2_409A_NONQUAL_INCOM).employee_data);

 /****************************************************************************/
/* Locations 265 to 362 are for Puerto Rico Employees ONLY.                 */
/****************************************************************************/
/* Civil Status                                 */

	l_tax_tax_jurisdiction	:=
		 hr_us_w2_rep.get_w2_tax_unit_item (p_tax_unit_id,
								           p_payroll_action_id,
									   'A_LC_W2_REPORTING_RULES_ORG_TAX_JURISDICTION');
        HR_UTILITY_TRACE('Tax Jurisdiction Code	 '||l_tax_tax_jurisdiction);

	IF l_tax_tax_jurisdiction = 'P'  THEN
		g_ee_record(RO_CIVIL_STATUS).employee_data	:=  ro_out_6;
	ELSE
		g_ee_record(RO_CIVIL_STATUS).employee_data	:=  ' ';
	END IF;
	HR_UTILITY_TRACE(g_ee_record(RO_CIVIL_STATUS).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_CIVIL_STATUS).employee_data);

/* Spouse Social Security Number (SSN)          */
	g_ee_record(RO_SPOUSE_SSN).employee_data	:= ro_out_7;
	HR_UTILITY_TRACE(g_ee_record(RO_SPOUSE_SSN).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_SPOUSE_SSN).employee_data);

/* Wages Subject to Puerto Rico Tax             */
	g_ee_record(RO_WAGES_SUBJ_PR_TAX).employee_data	:= to_char(nout_wages_subject);
	HR_UTILITY_TRACE(g_ee_record(RO_WAGES_SUBJ_PR_TAX).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_WAGES_SUBJ_PR_TAX).employee_data);

/* Commissions Subject to Puerto Rico Tax       */
	g_ee_record(RO_COMM_SUBJ_PR_TAX).employee_data	:= to_char(nout_terr_taxabale_com_per);
	HR_UTILITY_TRACE(g_ee_record(RO_COMM_SUBJ_PR_TAX).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_COMM_SUBJ_PR_TAX).employee_data);

/* Allowances Subject to Puerto Rico Tax        */
	g_ee_record(RO_ALLOWANCE_SUBJ_PR_TAX).employee_data	:= to_char(nout_terr_taxabable_allow_per);
	HR_UTILITY_TRACE(g_ee_record(RO_ALLOWANCE_SUBJ_PR_TAX).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_ALLOWANCE_SUBJ_PR_TAX).employee_data);

/* Tips Subject to Puerto Rico Tax              */
	g_ee_record(RO_TIPS_SUBJ_PR_TAX).employee_data	:= to_char(nout_terr_taxabale_tips_per);
	HR_UTILITY_TRACE(g_ee_record(RO_TIPS_SUBJ_PR_TAX).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_TIPS_SUBJ_PR_TAX).employee_data);

/* Total Wages, Commissions, Tips, and Allowances  Subject to Puerto Rico Tax  */
	g_ee_record(RO_W2_STATE_WAGES).employee_data	:= to_char(nout_total_w2_state_wages);
	HR_UTILITY_TRACE(g_ee_record(RO_W2_STATE_WAGES).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_W2_STATE_WAGES).employee_data);

/* Puerto Rico Tax Withheld                     */
	g_ee_record(RO_PR_TAX_WITHHELD).employee_data	:= to_char(nout_sit_with_per);
	HR_UTILITY_TRACE(g_ee_record(RO_PR_TAX_WITHHELD).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_PR_TAX_WITHHELD).employee_data);

/* Retirement Fund Annual Contributions         */
	g_ee_record(RO_RETIREMENT_CONTRIB).employee_data	:= to_char(nout_ret_contrib_perjdgreytd);
	HR_UTILITY_TRACE(g_ee_record(RO_RETIREMENT_CONTRIB).employee_tag || ' :  '
				 	   ||  g_ee_record(RO_RETIREMENT_CONTRIB).employee_data);

/* Formating RS Record Data Items */

/* Retirement Fund Annual Contributions         */
	g_ee_record(RS_TAXING_ENTITY_CODE).employee_data	:= ' ';
	HR_UTILITY_TRACE(g_ee_record(RS_TAXING_ENTITY_CODE).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_TAXING_ENTITY_CODE).employee_data);

/* Optional Code         */
	g_ee_record(RS_OPTIONAL_CODE).employee_data	:= ' ';
	HR_UTILITY_TRACE(g_ee_record(RS_OPTIONAL_CODE).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_OPTIONAL_CODE).employee_data);

/* Reporting Period         */
	g_ee_record(RS_REPORTING_PERIOD).employee_data	:= l_reporting_period;
	HR_UTILITY_TRACE(g_ee_record(RS_REPORTING_PERIOD).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_REPORTING_PERIOD).employee_data);

/* State Quarterly Unemployment Insurance Total Wages         */
	g_ee_record(RS_SQWL_UNEMP_INS_WAGES).employee_data	:= '0';
	HR_UTILITY_TRACE(g_ee_record(RS_SQWL_UNEMP_INS_WAGES).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_SQWL_UNEMP_INS_WAGES).employee_data);

/* State Quarterly Unemployment Total Taxable Wages  */
	g_ee_record(RS_SQWL_UNEMP_TXBL_WAGES).employee_data	:= '0';
	HR_UTILITY_TRACE(g_ee_record(RS_SQWL_UNEMP_TXBL_WAGES).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_SQWL_UNEMP_TXBL_WAGES).employee_data);

/* Number of Weeks Worked */
	g_ee_record(RS_WEEKS_WORKED).employee_data	:= ' ';
	HR_UTILITY_TRACE(g_ee_record(RS_WEEKS_WORKED).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_WEEKS_WORKED).employee_data);

/* Date First Employed */
	g_ee_record(RS_DATE_FIRST_EMPLOYED).employee_data	:= ltr_ue_name_table(55).ue_value;
	HR_UTILITY_TRACE(g_ee_record(RS_DATE_FIRST_EMPLOYED).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_DATE_FIRST_EMPLOYED).employee_data);

/* Date of Separation */
	g_ee_record(RS_DATE_OF_SEPARATION).employee_data	:= NVL(trim(ltr_ue_name_table(56).ue_value),' ');
	HR_UTILITY_TRACE(g_ee_record(RS_DATE_OF_SEPARATION).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_DATE_OF_SEPARATION).employee_data);

/* State Employer Account Number */
	g_ee_record(RS_STATE_ER_ACCT_NUM).employee_data	:=
									replace(replace(nvl(replace(ltr_ue_name_table(73).ue_value,' '), ' ')  ,'-'),'/');
	HR_UTILITY_TRACE(g_ee_record(RS_STATE_ER_ACCT_NUM).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_STATE_ER_ACCT_NUM).employee_data);

/* State Code */

	g_ee_record(RS_STATE_CODE).employee_data	:= ltr_ue_name_table(72).ue_value;
	HR_UTILITY_TRACE(g_ee_record(RS_STATE_CODE).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_STATE_CODE).employee_data);

/* State Taxable Wages
			A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD +
			A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD  -
			A_SIT_PRE_TAX_REDNS_PER_JD_GRE_YTD
*/
	l_state_wages	:=	to_number(ltr_ue_name_table(63).ue_value) +
					to_number(ltr_ue_name_table(64).ue_value) -
					to_number(ltr_ue_name_table(65).ue_value);

	g_ee_record(RS_STATE_WAGES).employee_data	:= to_char(l_state_wages);
	HR_UTILITY_TRACE(g_ee_record(RS_STATE_WAGES).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_STATE_WAGES).employee_data);

/* SIT Withheld */
	g_ee_record(RS_SIT_WITHHELD).employee_data := ltr_ue_name_table(68).ue_value;
	HR_UTILITY_TRACE(g_ee_record(RS_SIT_WITHHELD).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_SIT_WITHHELD).employee_data);

/* Other State Data*/
	g_ee_record(RS_OTHER_STATE_DATA).employee_data := ' ';
	HR_UTILITY_TRACE(g_ee_record(RS_OTHER_STATE_DATA).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_OTHER_STATE_DATA).employee_data);

/* State EIC Advance*/
	g_ee_record(RS_STEIC_ADVANCE).employee_data :=ltr_ue_name_table(69).ue_value;
	HR_UTILITY_TRACE(g_ee_record(RS_STEIC_ADVANCE).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_STEIC_ADVANCE).employee_data);

/* SUI Employee Withheld */
	g_ee_record(RS_SUI_EE_WITHHELD).employee_data := ltr_ue_name_table(70).ue_value;
	HR_UTILITY_TRACE(g_ee_record(RS_SUI_EE_WITHHELD).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_SUI_EE_WITHHELD).employee_data);

/* SDI Employee Withheld */
	g_ee_record(RS_SDI_EE_WITHHELD).employee_data := ltr_ue_name_table(71).ue_value;
	HR_UTILITY_TRACE(g_ee_record(RS_SDI_EE_WITHHELD).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_SDI_EE_WITHHELD).employee_data);

/* Supplemental Data 1 */
	g_ee_record(RS_SUPPLEMENTAL_DATA_1).employee_data := ' ';
	HR_UTILITY_TRACE(g_ee_record(RS_SUPPLEMENTAL_DATA_1).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_SUPPLEMENTAL_DATA_1).employee_data);

/* Supplemental Data 2 */
	g_ee_record(RS_SUPPLEMENTAL_DATA_2).employee_data := ' ';
	HR_UTILITY_TRACE(g_ee_record(RS_SUPPLEMENTAL_DATA_2).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_SUPPLEMENTAL_DATA_2).employee_data);

/* Bug 7456383 : RS_STATE_CONTROL_NUMBER */
	g_ee_record(RS_STATE_CONTROL_NUMBER).employee_data := ' ';
	HR_UTILITY_TRACE(g_ee_record(RS_STATE_CONTROL_NUMBER).employee_tag || ' :  '
				 	   ||  g_ee_record(RS_STATE_CONTROL_NUMBER).employee_data);

--
-- Locality Data Items
--
HR_UTILITY_TRACE('Processing Locality Level Data for the Employee');

IF p_locality_code = 'NULL' THEN
	l_locality_code := NULL;
ELSE
	l_locality_code	:= p_locality_code;
END IF;
--
-- Delete the PL Table used for storing Locality Level Data for the Employee
--
	ltr_local_record.delete;
	ltr_ue_locality.delete;
	i := 0;
	k := 0;

	k := k +1;
	ltr_ue_locality(k).ue_name		:= 'A_CITY_SUBJ_NWHABLE_PER_JD_GRE_YTD';		--Local AI	1
	ltr_ue_locality(k).ue_data_level	:='CITY';
	ltr_ue_locality(k).data_type		:='AMT';
	ltr_ue_locality(k).negative_check	:= 'Y';

	k := k +1;
	ltr_ue_locality(k).ue_name		:= 'A_CITY_SUBJ_WHABLE_PER_JD_GRE_YTD';		--Local AI	2
	ltr_ue_locality(k).ue_data_level	:='CITY';
	ltr_ue_locality(k).data_type		:='AMT';
	ltr_ue_locality(k).negative_check	:= 'Y';

	k := k +1;
	ltr_ue_locality(k).ue_name		:= 'A_CITY_PRE_TAX_REDNS_PER_JD_GRE_YTD';	--Local AI	3
	ltr_ue_locality(k).ue_data_level	:='CITY';
	ltr_ue_locality(k).data_type		:='AMT';
	ltr_ue_locality(k).negative_check	:= 'Y';

	k := k +1;
	ltr_ue_locality(k).ue_name		:= 'A_CITY_WITHHELD_PER_JD_GRE_YTD';			--Local AI	4
	ltr_ue_locality(k).ue_data_level	:='CITY';
	ltr_ue_locality(k).data_type		:='AMT';
	ltr_ue_locality(k).negative_check	:= 'Y';

	-- Bug # 6117216 SD Reporting Changes START

        k := k +1;
        ltr_ue_locality(k).ue_name              := 'A_SCHOOL_LOCAL_WAGES';      --Local AI      5  for SD
        ltr_ue_locality(k).ue_data_level        :='CITY SCHOOL';
        ltr_ue_locality(k).data_type            :='AMT';
        ltr_ue_locality(k).negative_check       := 'Y';

        k := k +1;
        ltr_ue_locality(k).ue_name              := 'A_SCHOOL_WITHHELD_PER_JD_GRE_YTD';                  --Local AI      6  for SD
        ltr_ue_locality(k).ue_data_level        :='CITY SCHOOL';
        ltr_ue_locality(k).data_type            :='AMT';
        ltr_ue_locality(k).negative_check       := 'Y';

     /* 2180670 */
        	k := k +1;
	ltr_ue_locality(k).ue_name		:= 'A_CITY_RS_WITHHELD_PER_JD_GRE_YTD';			--Local AI	7
	ltr_ue_locality(k).ue_data_level	:='CITY';
	ltr_ue_locality(k).data_type		:='AMT';
	ltr_ue_locality(k).negative_check	:= 'Y';

	      	k := k +1;
	ltr_ue_locality(k).ue_name		:= 'A_CITY_WK_WITHHELD_PER_JD_GRE_YTD';			--Local AI	8
	ltr_ue_locality(k).ue_data_level	:='CITY';
	ltr_ue_locality(k).data_type		:='AMT';
	ltr_ue_locality(k).negative_check	:= 'Y';
	      	k := k +1;
	ltr_ue_locality(k).ue_name		:= 'A_CITY_RS_REDUCED_SUBJECT_PER_JD_GRE_YTD';			--Local AI	9
	ltr_ue_locality(k).ue_data_level	:='CITY';
	ltr_ue_locality(k).data_type		:='AMT';
	ltr_ue_locality(k).negative_check	:= 'Y';



	HR_UTILITY_TRACE('YE Assignment_Action_Id '|| to_char(p_ye_assignment_action_id));
	HR_UTILITY_TRACE('State	Code	'|| lpad(p_state_code,2,'0'));
	HR_UTILITY_TRACE('Locality Code	'|| l_locality_code);

        OPEN	c_locality_jurisdiction(p_ye_assignment_action_id,
					/* Bug 7592972 : State Code should be passed as two character
					long Code to the cursor c_locality_jurisdiction
					p_state_code,*/
					lpad(p_state_code,2,'0'),
					l_locality_code);
        LOOP
		l_jurisdiction_code := NULL;
		FETCH c_locality_jurisdiction  INTO  l_jurisdiction_code;
		HR_UTILITY_TRACE('Processing Jurisdiction	'|| l_jurisdiction_code);
		EXIT WHEN c_locality_jurisdiction%NOTFOUND;
		IF l_jurisdiction_code IS NOT NULL
		THEN
		--{
		--
		-- Fetching locality level archived data for employee
		--
		IF ltr_ue_locality.count > 0 then
			FOR j IN ltr_ue_locality.first .. ltr_ue_locality.last
			LOOP
				IF ltr_ue_locality(j).ue_data_level ='CITY'  THEN
					ltr_ue_locality(j).ue_value := hr_us_w2_rep.get_w2_arch_bal(
											p_ye_assignment_action_id
											,ltr_ue_locality(j).ue_name
											,p_tax_unit_id
											,l_jurisdiction_code
											, 11);
					IF ( ltr_ue_locality(j).data_type = 'AMT'  AND
						to_number(ltr_ue_locality(j).ue_value) < 0)
					THEN
						l_status	:= 'FAILED';
						/* Bug 7637211 : Start */
						l_status_description := SUBSTR(l_status_description || 'Archive Item ' || ltr_ue_locality(j).ue_name || ' has negative balance(' || to_number(ltr_ue_locality(j).ue_value) || '). ',1,1500);
						/* Bug 7637211 : End */
					END IF;

			 ELSIF ltr_ue_locality(j).ue_data_level ='CITY SCHOOL'  THEN
			       ltr_ue_locality(j).ue_value := hr_us_w2_rep.get_w2_arch_bal(
                                                                        p_ye_assignment_action_id
                                                                        ,ltr_ue_locality(j).ue_name
                                                                        ,p_tax_unit_id
                                                                        ,l_jurisdiction_code
                                                                        ,8);
                        IF ( ltr_ue_locality(j).data_type = 'AMT'  AND
                                to_number(ltr_ue_locality(j).ue_value) < 0)
                        THEN
                                l_status        := 'FAILED';
				/* Bug 7637211 : Start */
				l_status_description := SUBSTR(l_status_description || 'Archive Item ' || ltr_ue_locality(j).ue_name || ' has negative balance(' || to_number(ltr_ue_locality(j).ue_value) || '). ',1,1500);
				/* Bug 7637211 : End */
                        END IF;

			ELSE
			ltr_ue_locality(j).ue_value := '0';
			END IF;
			HR_UTILITY_TRACE('DBI ' || ltr_ue_locality(J).ue_data_level ||
					      ' -('||to_char(j)|| ') : < ' || ltr_ue_locality(j).ue_name||
		                                      ' >   VALUE  : < '|| ltr_ue_locality(j).ue_value||' >');

			END LOOP;
		END IF;

		IF length(l_jurisdiction_code) > 9 THEN

		OPEN	c_city_data(l_jurisdiction_code
						  ,p_date_earned);
                FETCH c_city_data  INTO	l_city_name,
								l_county_name,
								l_tax_type,
								l_city_code;
		CLOSE c_city_data;
		-- Derive City Wages
		l_city_wages		:=	ltr_ue_locality(1).ue_value +
							ltr_ue_locality(2).ue_value -
							ltr_ue_locality(3).ue_value;
		-- City Tax Withheld
		l_city_tax_withheld	:=	ltr_ue_locality(4).ue_value;

		i := to_number(substr(l_jurisdiction_code,1,2) ||
					substr(l_jurisdiction_code,4,3) ||
					substr(l_jurisdiction_code,8,4) );

HR_UTILITY.trace('l_jurisdiction_code' || l_jurisdiction_code);
on_visa := 'N';
non_state_res := 'N';

		IF ltr_local_record.EXISTS(i) THEN
		--{
                    NULL;
                 --}
		ELSE
  		    ltr_local_record(i).jurisdiction		:= l_jurisdiction_code;
  		    ltr_local_record(i).city_name		:= l_city_name;
  		    ltr_local_record(i).county_name		:= l_county_name;
  		    ltr_local_record(i).tax_type		:= l_tax_type;
  		    ltr_local_record(i).locality_code	:= l_city_code;
  		    ltr_local_record(i).locality_wages	:= l_city_wages;
  		    ltr_local_record(i).locality_tax		:= l_city_tax_withheld;
  		    /* 2180670 */
  		     ltr_local_record(i).city_rs_tax   := ltr_ue_locality(7).ue_value;
  		    ltr_local_record(i).city_wk_tax    := ltr_ue_locality(8).ue_value;
  		    ltr_local_record(i).city_rs_wages   := ltr_ue_locality(9).ue_value;
  		     if l_jurisdiction_code = '39-003-3040' then

            PAY_US_MMREF_LOCAL_XML.local_non_pa_emp_data( l_payroll_action_id ,
                        p_assignment_id ,
                        on_visa ,
                        non_state_res ,
                        p_reporting_year  );

            if   on_visa = 'Y' or non_state_res = 'Y' then

  		    ltr_local_record(i).non_state_earnings := l_city_wages ;
  		    ltr_local_record(i).non_state_withheld := l_city_tax_withheld ;
  		    else
  		    ltr_local_record(i).non_state_earnings := '0' ;
  		    ltr_local_record(i).non_state_withheld := '0' ;
 		    end if ;
        else
  		   ltr_local_record(i).non_state_earnings := '0' ;
	       ltr_local_record(i).non_state_withheld := '0' ;
        end if ;
		END IF;


        ELSE

                OPEN    c_sd_data(l_jurisdiction_code);
                FETCH c_sd_data  INTO   l_city_name,  -- using city name for sd name
                                                                l_tax_type,
                                                                l_city_code;
                CLOSE c_sd_data;

        l_city_wages := ltr_ue_locality(5).ue_value;

        l_city_tax_withheld := ltr_ue_locality(6).ue_value;

                i := to_number(substr(l_jurisdiction_code,1,2) ||
                                        substr(l_jurisdiction_code,4,5));

        IF ltr_local_record.EXISTS(i) THEN
                --{
                    NULL;
                 --}
                ELSE
                    ltr_local_record(i).jurisdiction    := l_jurisdiction_code;
                    ltr_local_record(i).city_name               := l_city_name;
                    ltr_local_record(i).tax_type                := l_tax_type;
                    ltr_local_record(i).locality_code   := l_city_code;
                    ltr_local_record(i).locality_wages  := l_city_wages;
                    ltr_local_record(i).locality_tax    := l_city_tax_withheld;
                END IF;


		HR_UTILITY_TRACE('Locality Jurisdiction		:' || ltr_local_record(i).jurisdiction);
		HR_UTILITY_TRACE('		     City Name		:' || ltr_local_record(i).city_name);
		HR_UTILITY_TRACE('		     County Name	:' || ltr_local_record(i).county_name);
		HR_UTILITY_TRACE('		     Tax Type		:' || ltr_local_record(i).tax_type);
		HR_UTILITY_TRACE('		     City Code		:' || ltr_local_record(i).locality_code);
		HR_UTILITY_TRACE('		     City Wages		:' || ltr_local_record(i).locality_wages);
		HR_UTILITY_TRACE('		     City Withheld	:' || ltr_local_record(i).locality_tax);
	--}
       END IF;
       END IF;

     END LOOP;
     close c_locality_jurisdiction;

	-- Bug # 6117216 SD Reporting Changes END

      l_final_xml_string := '';
	l_final_xml_string :=  '<EMPLOYEE>' ||
					'<EXCEPTION>' || l_status || '</EXCEPTION>'|| EOL
					/* Bug 7637211 : Start */
					|| '<EXCEPTION_DETAILS>' || l_status_description || '</EXCEPTION_DETAILS>'|| EOL
					/* Bug 7637211 : End */
					|| '<RW>';
     BEGIN
	FOR I IN 1 .. 42	 LOOP
	        l_data_item_xml  :=  '<'||g_ee_record(I).employee_tag||'>'||
                                                     convert_special_char(nvl(g_ee_record(I).employee_data,' '))
						     ||'</'||g_ee_record(I).employee_tag||'>'|| EOL;
		l_final_xml_string := l_final_xml_string || l_data_item_xml;
		HR_UTILITY_TRACE(l_data_item_xml);
	END LOOP;
	/*
            This got added for FIT Withheld at 3rd Party Payer
	    This Balance is not reported in RW record but total is reported in RT record
	 */
        l_data_item_xml  :=  '<'||g_ee_record(FIT_WITHHELD_THIRD_PARTY).employee_tag||'>'||
                                                     convert_special_char(nvl(g_ee_record(FIT_WITHHELD_THIRD_PARTY).employee_data,' '))
						     ||'</'||g_ee_record(FIT_WITHHELD_THIRD_PARTY).employee_tag||'>'|| EOL;
	l_final_xml_string := l_final_xml_string || l_data_item_xml;
	HR_UTILITY_TRACE(l_data_item_xml);

	l_final_xml_string :=  l_final_xml_string   || '</RW>' || EOL;
	EXCEPTION
	WHEN OTHERS THEN
			HR_UTILITY_TRACE('Error Encountered While formating RW Record Data Item');
     END;
	HR_UTILITY_TRACE(' RW Record Formatted Successfully  Length '|| length(l_final_xml_string));

        /* Merge RO Record Data Compoents to XML Construct */
	l_final_xml_string := l_final_xml_string
						|| '<'||convert_special_char(g_ee_record(43).employee_data)||'>';
		IF  l_zero_ro_record = 'Y' THEN
			l_final_xml_string := l_final_xml_string
						|| '<ZERO_VALUE>Y</ZERO_VALUE>' || EOL;
		ELSE
			l_final_xml_string := l_final_xml_string
						|| '<ZERO_VALUE>N</ZERO_VALUE>' || EOL;
		END IF;

	BEGIN
	    FOR I IN 44 .. 60
	    LOOP
		l_data_item_xml :=  '<'||g_ee_record(I).employee_tag||'>'||
                                                     convert_special_char(nvl(g_ee_record(I).employee_data,' '))
						     ||'</'||g_ee_record(I).employee_tag||'>'|| EOL;
		HR_UTILITY_TRACE(l_data_item_xml);
		l_final_xml_string := l_final_xml_string || l_data_item_xml;
	    END LOOP;
	    l_final_xml_string :=  l_final_xml_string   ||  '</' || convert_special_char(g_ee_record(43).employee_data)
	                                                   || '>' || EOL;
	    EXCEPTION
	    WHEN OTHERS THEN
			HR_UTILITY_TRACE('Error Encountered While formating RO Record Data Item');
	END;
	HR_UTILITY_TRACE(' RO Record Formatted Successfully  Length '|| length(l_final_xml_string));

        /* Merge RS Record Data Compoents to XML Construct */
	l_final_xml_string := l_final_xml_string || '<RS>';
	BEGIN
	    FOR I IN 61 .. 78
	    LOOP
		l_data_item_xml :=  '<'||g_ee_record(I).employee_tag||'>'||
                                                     convert_special_char(nvl(g_ee_record(I).employee_data,' '))
						     ||'</'||g_ee_record(I).employee_tag||'>'|| EOL;
		HR_UTILITY_TRACE(l_data_item_xml);
		l_final_xml_string := l_final_xml_string || l_data_item_xml;
	    END LOOP;

	    /* Bug 7456383 : RS_STATE_CONTROL_NUMBER */
	    l_data_item_xml :=  '<'||g_ee_record(RS_STATE_CONTROL_NUMBER).employee_tag||'>'||
                                convert_special_char(nvl(g_ee_record(RS_STATE_CONTROL_NUMBER).employee_data,' '))||
				'</'||g_ee_record(RS_STATE_CONTROL_NUMBER).employee_tag||'>'|| EOL;
	    HR_UTILITY_TRACE(l_data_item_xml);
	    l_final_xml_string := l_final_xml_string || l_data_item_xml;

	    l_final_xml_string :=  l_final_xml_string   ||  '</RS>' || EOL;

	    EXCEPTION
	    WHEN OTHERS THEN
			HR_UTILITY_TRACE('Error Encountered While formating RS Record Data Item');
	END;
	HR_UTILITY_TRACE(' RS Record Formatted Successfully  Length '|| length(l_final_xml_string));
	--
	-- Following Procedure will initialize Locality Data Item Tags
	--
	populate_ee_locality_tag;

	HR_UTILITY_TRACE(' Formating Locality Records for Employee ');
--	l_final_xml_string := l_final_xml_string || '<CITY>';

	IF ltr_local_record.COUNT >= 1
	THEN
        --{
	   i	:= NULL;
	   j    := ltr_local_record.COUNT;
	   k	:= 0;
           i := ltr_local_record.FIRST;
	   l_data_item_xml := '';
           WHILE i IS NOT NULL
	   LOOP
                 IF (ltr_local_record(i).jurisdiction IS NOT NULL)
		 THEN
		 --{
			k := k + 1;

	-- Bug # 6117216 SD Reporting Changes START

                IF length(ltr_local_record(i).jurisdiction) < 9 THEN
                        l_data_item_xml :=  '<SD>'||
                                                    '<'|| ltr_ee_locality_tag(8)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).jurisdiction ,' '))
                                                     ||'</'|| ltr_ee_locality_tag(8)||'>'|| EOL
                                                     || '<'|| ltr_ee_locality_tag(9)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).city_name ,' '))
                                                     ||'</'|| ltr_ee_locality_tag(9)||'>'|| EOL
                                                     || '<'|| ltr_ee_locality_tag(10)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).tax_type ,' '))
                                                     ||'</'|| ltr_ee_locality_tag(10)||'>'|| EOL
                                                     || '<'|| ltr_ee_locality_tag(11)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).locality_code ,' '))
                                                     ||'</'|| ltr_ee_locality_tag(11)||'>'|| EOL
                                                     || '<'|| ltr_ee_locality_tag(12)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).locality_wages ,' '))
                                                     ||'</'|| ltr_ee_locality_tag(12)||'>'|| EOL
                                                     || '<'|| ltr_ee_locality_tag(13)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).locality_tax ,' '))
                                                     ||'</'|| ltr_ee_locality_tag(13)||'>'|| EOL
                                                     ||'</SD>' || EOL;
                        HR_UTILITY_TRACE('SD XML '|| l_data_item_xml);

                ELSE    l_data_item_xml :=  '<CITY>'||
			                            '<'|| ltr_ee_locality_tag(CITY_JURISDICTION)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).jurisdiction ,' '))
						     ||'</'|| ltr_ee_locality_tag(CITY_JURISDICTION)||'>'|| EOL
						     || '<'|| ltr_ee_locality_tag(CITY_NAME)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).city_name ,' '))
						     ||'</'|| ltr_ee_locality_tag(CITY_NAME)||'>'|| EOL
						     || '<'|| ltr_ee_locality_tag(COUNTY_NAME)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).county_name ,' '))
						     ||'</'|| ltr_ee_locality_tag(COUNTY_NAME)||'>'|| EOL
						     || '<'|| ltr_ee_locality_tag(TAX_TYPE)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).tax_type ,' '))
						     ||'</'|| ltr_ee_locality_tag(TAX_TYPE)||'>'|| EOL
						     || '<'|| ltr_ee_locality_tag(CITY_CODE)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).locality_code ,' '))
						     ||'</'|| ltr_ee_locality_tag(CITY_CODE)||'>'|| EOL
						     || '<'|| ltr_ee_locality_tag(CITY_WAGES)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).locality_wages ,' '))
						     ||'</'|| ltr_ee_locality_tag(CITY_WAGES)||'>'|| EOL
						     || '<'|| ltr_ee_locality_tag(CITY_TAX_WITHHELD)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).locality_tax ,' '))
						     ||'</'|| ltr_ee_locality_tag(CITY_TAX_WITHHELD)||'>'|| EOL
						      || '<'|| ltr_ee_locality_tag(14)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).city_rs_tax ,' '))
						     ||'</'|| ltr_ee_locality_tag(14)||'>'|| EOL
						      || '<'|| ltr_ee_locality_tag(15)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).city_wk_tax ,' '))
						     ||'</'|| ltr_ee_locality_tag(15)||'>'|| EOL
						      || '<'|| ltr_ee_locality_tag(16)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).city_rs_wages ,' '))
						     ||'</'|| ltr_ee_locality_tag(16)||'>'|| EOL
						      || '<'|| ltr_ee_locality_tag(17)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).NON_STATE_EARNINGS ,' '))
						     ||'</'|| ltr_ee_locality_tag(17)||'>'|| EOL
				             || '<'|| ltr_ee_locality_tag(18)||'>'||
                                                     convert_special_char(nvl(ltr_local_record(i).NON_STATE_WITHHELD ,' '))
						     ||'</'|| ltr_ee_locality_tag(18)||'>'|| EOL
						     ||'</CITY>' || EOL; -- 2180670
			HR_UTILITY_TRACE('Locality XML '|| l_data_item_xml);
		--}
		END IF;

	-- Bug # 6117216 SD Reporting Changes END

		END IF;
		i := ltr_local_record.NEXT(i);
		l_final_xml_string :=  l_final_xml_string   ||  l_data_item_xml;
           END LOOP;
        --}
        END IF;	-- ltr_local_record.COUNT >= 1

	l_final_xml_string :=  l_final_xml_string   || '</EMPLOYEE>' || EOL;
        p_final_string := l_final_xml_string;
--}
EXCEPTION
WHEN OTHERS THEN
	HR_UTILITY_TRACE('Error Encountered in procedure populate_arch_employee');
END populate_arch_employee;  -- End of Procedure populate_arch_employee


BEGIN
--    hr_utility.trace_on(null, 'USLOCALW2');
    g_proc_name	 := 'pay_us_w2_generic_extract.';
    g_debug		 := hr_utility.debug_enabled;
    g_document_type	 := 'LOCAL_W2_XML';
END pay_us_w2_generic_extract;

/
