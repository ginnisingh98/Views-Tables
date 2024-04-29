--------------------------------------------------------
--  DDL for Package Body PER_NEW_HIRE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_NEW_HIRE_PKG" as
/* $Header: pernhire.pkb 120.7.12010000.7 2009/08/21 11:28:09 lbodired ship $      */
/*
REM +======================================================================+
REM |                Copyright (c) 2002 Oracle Corporation                 |
REM |                   Redwood Shores, California, USA                    |
REM |                        All rights reserved.                          |
REM +======================================================================+
REM Package Body Name : per_new_hire_pkg
REM Package File Name : pernhire.pkb
REM Description       : This package defines procedures/functions that
REM                     are used for new hire electrical file
REM
REM Change List:
REM ------------
REM
REM Name        Date         Version Bug     Text
REM ----------- ----------   ------- ------- -------------------------------
REM ynegoro     12-Dec-2002  115.0   1057968 Created.
REM ynegoro     13-Dec-2002  115.1           Fixed GSCC Compliance
REM ynegoro     19-Dec-2002  115.2           Added get_new_hire_contact
REM ynegoro     20-Dec-2002  115.3           Changed get_location_address
REM ynegoro     15-Jan-2003  115.4   2753923 Changed get_employee_address
REM                                                  get_location_address
REM                                          to get address_line3
REM ynegoro     22-Jan-2003  115.5   2753923 Changed a03_fl_new_hire_record
REM                                          'YYYYMMDD' to 'MMDDYYYY'
REM ynegoro     28-Jan-2003  115.6           Support Canadian Province
REM ynegoro     29-Jan-2003  115.7   2775157 Omit hyphens in CA SIT
REM ynegoro     30-Jan-2003  115.8           Replace comman to space for a03
REM ynegoro     11-Mar-2003  115.9           Modified ny_1t_record and
REM                                          ny_1f_record from 118 to 119
REM                                          for blank field
REM vbanner     30-Dec-2003  115.10  3316519 Modified get_new_hire_contact
REM                                          to restrict contact title
REM                                          out parameter to 60 characters
REM ynegoro     03-Nov-2004  115.11  2919553 Changed c_new_hire_record cursor
REM                                          to pikc up latest person name
REM ynegoro     23-DEC-2004          4095015 Changed tx_new_hire_record
REM ynegoro     30-DEC-2004                  Added tx_r4_record
REM ynegoro     23-JUN-2005  115.12  Added p_state_of_hire to a03_tx_record
REM                                  and tx_new_hire_record
REM ynegoro     20-JUL-2005  115.13  4504074 Added nvl to v_ssn
REM ynegoro     25-JUL-2005  115.15  3954955 Changed a format CCYY to YYYY for TX
REM trugless    12-JAN-2006  115.16  4912696 Modified cursor  c_new_hire_record
REM                                          to use tables instead of views
REM                                          to reduce shared memory use.
REM ssouresr    20-APR-2006  115.17  5169671 Modified the fnc il_new_hire_record
REM                                          so that a missing middle name does not
REM                                          invalidate record positions in file
REM rpasumar    08-MAR-2007 115.18 5893234   Changed the version number from 1:00 to 1.00
REM                                           in the procedure, fl_new_hire_record.
REM jdevasah    09-JUL-2007 115.19 6155091   Modified address procedures in order to
REM                                          handle US International address style
REM swamukhe  20-JUN-2005  115.20 5069465 Modified the l_buffer for CA and NY states to
REM                                                insert a line feed.
REM swamukhe  26-MAY-2008 115.25	Modified the date format for TX from 'YYYYMMDD' to
REM                                                  'MMDDYYYY'
REM lbodired  21-AUG-2009  115.26       Modified the 'fl_new_hire_record' function to
REM                                     insert carriage return
REM ========================================================================

*/
--
-- Global variables and Constants.
--
g_character_set		varchar2(80);
g_package_name		constant varchar2(30) := 'per_new_hire_pkg';

g_e4_code 		varchar2(2) := 'E4';
g_w4_code 		varchar2(2) := 'W4';
g_t4_code 		varchar2(2) := 'T4';
g_eol                   varchar2(1) := fnd_global.local_chr(10) ;
g_delimiter             varchar2(1) := ',';

/****************************************************************
 * This procedure sets character_set to out put file            *
 *                                                              *
 *                                                              *
 ****************************************************************/
procedure char_set_init
(
	 p_character_set	in varchar2
)
is
	l_api_name	varchar2(61) := g_package_name || '.char_set_init';
	l_package_name	varchar2(30) := g_package_name;
begin
  --
  --hr_utility.trace_on(null,'NEWHIRE');
  hr_utility.set_location('Entering:' ||l_api_name,10);
	--
	-- Check mandatory argument.
	--
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_character_set',
		p_argument_value	=> p_character_set);
	--
	-- Initialize global variables.
	--
	g_character_set := p_character_set;
	--
  hr_utility.set_location(l_api_name,20);
--
  hr_utility.set_location('Leaving.... :' || l_api_name,50);
end char_set_init;

/****************************************************************
 * This procedure formats California E4 record                  *
 *                                                              *
 *                                                              *
 ****************************************************************/
function ca_e4_record
(
        p_record_identifier     in  varchar2
       ,p_federal_id            in  varchar2
       ,p_sit_company_state_id  in  varchar2
       ,p_branch_code           in  varchar2
       ,p_tax_unit_name         in  varchar2
       ,p_street_address        in  varchar2
       ,p_city                  in  varchar2
       ,p_state                 in  varchar2
       ,p_zip                   in  varchar2
       ,p_zip_extension         in  varchar2 default null
) return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.ca_e4_record';
	l_buffer	varchar2(2000);
        v_sit           varchar2(40);
	p_end_of_rec varchar2(2000);
begin

  hr_utility.set_location('Entering:' ||l_api_name,10);

	--
	-- Check mandatory argument.
	--
	hr_api.mandatory_arg_error(
		p_api_name		=> l_api_name,
		p_argument		=> 'p_record_identifier',
		p_argument_value	=> p_record_identifier);

  hr_utility.set_location(l_api_name,11);
  hr_utility.trace('p_federal_id=           ' || p_federal_id);
  hr_utility.trace('p_sit_company_state_id= ' || p_sit_company_state_id);

        v_sit := replace(p_sit_company_state_id,'-',null);

  hr_utility.trace('v_sit_company_state_id= ' || v_sit);

  hr_utility.trace('p_tax_unit_name=        ' || p_tax_unit_name);
  hr_utility.trace('p_street_address=       ' || p_street_address);
  hr_utility.trace('p_city=                 ' || p_city);
  hr_utility.trace('p_state=                ' || p_state);
  hr_utility.trace('p_zip=                  ' || p_zip);
  hr_utility.trace('p_zip_extension=        ' || p_zip_extension);

  hr_utility.set_location(l_api_name,30);

	--
	-- format new hire rocord
	--

	p_end_of_rec := fnd_global.local_chr(13)||fnd_global.local_chr(10);

	l_buffer := upper(p_record_identifier ||
			rpad(p_federal_id,9,' ') ||
			rpad(nvl(v_sit,'0'),8,'0') ||
			rpad(nvl(p_branch_code,' '),3,' ') ||
			rpad(nvl(p_tax_unit_name,' '),45,' ') ||
			rpad(p_street_address,40,' ') ||
			rpad(p_city,25,' ') ||
			rpad(p_state,2,' ') ||
			rpad(p_zip,5,' ') ||
			rpad(nvl(p_zip_extension,' '),4,' ') ||
			lpad(' ',32,' '))||p_end_of_rec ;


  hr_utility.set_location('Leaving.... :' || l_api_name,40);

	return convert(l_buffer,g_character_set);
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,70);
--		fnd_message.set_name('PER','HR_ERROR');
--		fnd_message.set_token('SQL',g_ca_e4_sql);
--		fnd_message.raise_error;
                raise;
end ca_e4_record;

/****************************************************************
 * This procedure formats California W4 record                  *
 *                                                              *
 *                                                              *
 ****************************************************************/
function ca_w4_record
(
  p_record_identifier     in  varchar2
 ,p_national_identifier   in  varchar2
 ,p_first_name            in  varchar2
 ,p_middle_name           in  varchar2
 ,p_last_name             in  varchar2
 ,p_street_address        in  varchar2
 ,p_city                  in  varchar2
 ,p_state                 in  varchar2
 ,p_zip                   in  varchar2
 ,p_zip_extension         in  varchar2
 ,p_date_of_hire          in  date
) return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.ca_w4_record';
	l_buffer	varchar2(2000);
        v_ssn           varchar(9);
	p_end_of_rec varchar2(2000);
begin
  hr_utility.set_location('Entering:' ||l_api_name,10);

  hr_utility.trace('p_record_identifier=   ' || p_record_identifier);
  hr_utility.trace('p_national_identifier= ' || p_national_identifier);

  v_ssn := substr(p_national_identifier,1,3) || substr(p_national_identifier,5,2) || substr(p_national_identifier,8,4);

  hr_utility.trace('v_ssn=                 ' || v_ssn);

  hr_utility.trace('p_first_name=          ' || p_first_name);

  hr_utility.trace('p_middle_name=         ' || p_middle_name);
  hr_utility.trace('p_last_name=           ' || p_last_name);

  hr_utility.trace('p_street_address=      ' || p_street_address);
  hr_utility.trace('p_city=                ' || p_city);
  hr_utility.trace('p_state=               ' || p_state);
  hr_utility.trace('p_zip=                 ' || p_zip);
  hr_utility.trace('p_zip_extension=       ' || p_zip_extension);
  hr_utility.trace('p_date_of_hire=          ' || to_char(p_date_of_hire));

	--
	-- format new hire rocord
	--

	p_end_of_rec := fnd_global.local_chr(13)||fnd_global.local_chr(10);

	l_buffer := upper(
                p_record_identifier ||
		rpad(nvl(v_ssn,' '),9,' ') ||    -- BUG4504074
		rpad(nvl(p_first_name,' '),16,' ') ||
		rpad(nvl(p_middle_name,' '),1,' ') ||
		rpad(p_last_name,30,' ') ||
		rpad(nvl(p_street_address,' '),40,' ') ||
		rpad(nvl(p_city,' '),25,' ') ||
		rpad(nvl(p_state,' '),2,' ') ||
		rpad(nvl(p_zip,' '),5,' ') ||
		rpad(nvl(p_zip_extension,' '),4,' ') ||
                nvl(to_char(p_date_of_hire,'YYYYMMDD'),'        ') ||
		lpad(' ',33,' '))||p_end_of_rec;

  hr_utility.trace('l_buffer = ' || l_buffer);


  hr_utility.set_location('Leaving.... :' || l_api_name,60);

	return convert(l_buffer,g_character_set);
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,70);
                raise;
end ca_w4_record;
--
/****************************************************************
 * This procedure formats California T4 record                  *
 *                                                              *
 *                                                              *
 ****************************************************************/
FUNCTION ca_t4_record
(
         p_record_identifier 		in varchar2
	,p_number_of_employee		in number
) return varchar2
IS
	l_api_name	varchar2(61) := g_package_name || '.ca_t4_record';
	l_buffer	varchar2(2000);
	p_end_of_rec varchar2(2000);
begin
  --
  hr_utility.set_location('Entering:' ||l_api_name,10);

  hr_utility.trace('p_record_identifier=   ' || p_record_identifier);
  hr_utility.trace('p_number_of_emplyee =    ' || p_number_of_employee);

	--
	-- format new hire rocord
	--

	p_end_of_rec := fnd_global.local_chr(13)||fnd_global.local_chr(10);

	l_buffer := upper(
                p_record_identifier ||
		lpad(to_char(p_number_of_employee),11,'0') ||
		lpad(' ',162,' '))||p_end_of_rec;

  hr_utility.set_location(l_api_name,20);

	return convert(l_buffer,g_character_set);
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,30);
		raise;
end ca_t4_record;
--
/****************************************************************
 * This procedure formats NEW YORK 1A record for Transmitter    *
 *                                                              *
 *                                                              *
 ****************************************************************/
function ny_1a_record
(
        p_record_identifier     in  varchar2
       ,p_creation_date         in  varchar2
       ,p_federal_id            in  varchar2
       ,p_tax_unit_name         in  varchar2
       ,p_street_address        in  varchar2
       ,p_city                  in  varchar2
       ,p_state                 in  varchar2
       ,p_zip                   in  varchar2
) return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.ny_1a_record';
	l_buffer	varchar2(2000);
	p_end_of_rec varchar2(2000);
begin

  hr_utility.set_location('Entering...:' ||l_api_name,10);

  hr_utility.trace('p_record_identifier= ' || p_record_identifier);
  hr_utility.trace('p_federal_id=        ' || p_federal_id);
  hr_utility.trace('p_tax_unit_name=     ' || p_tax_unit_name);
  hr_utility.trace('p_street_address=    ' || p_street_address);
  hr_utility.trace('p_city=              ' || p_city);
  hr_utility.trace('p_state=             ' || p_state);
  hr_utility.trace('p_zip=               ' || p_zip);

  hr_utility.set_location(l_api_name,30);

	--
	-- format new hire rocord
	--

	p_end_of_rec := fnd_global.local_chr(13)||fnd_global.local_chr(10);

	l_buffer := upper(p_record_identifier ||
	                p_creation_date ||
			rpad(nvl(p_federal_id,' '),11,' ') ||
			rpad(nvl(p_tax_unit_name,' '),40,' ') ||
			rpad(nvl(p_street_address,' '),30,' ') ||
			rpad(nvl(p_city,' '),18,' ') ||
			rpad(nvl(p_state,' '),2,' ') ||
			rpad(nvl(p_zip,' '),9,' ') ||
			lpad(' ',10,' '))||p_end_of_rec;


  hr_utility.set_location('Leaving.... :' || l_api_name,40);

	return convert(l_buffer,g_character_set);
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,70);
                raise;
end ny_1a_record;
--
/****************************************************************
 * This procedure formats NEW YORK 1E record for Employer       *
 *                                                              *
 *                                                              *
 ****************************************************************/
function ny_1e_record
(
        p_record_identifier     in  varchar2
       ,p_federal_id            in  varchar2
       ,p_tax_unit_name         in  varchar2
       ,p_street_address        in  varchar2
       ,p_city                  in  varchar2
       ,p_state                 in  varchar2
       ,p_zip                   in  varchar2
) return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.ny_1e_record';
	l_buffer	varchar2(2000);
	p_end_of_rec varchar2(2000);
begin

  hr_utility.set_location('Entering:' ||l_api_name,10);

  hr_utility.trace('p_record_identifier= ' || p_record_identifier);
  hr_utility.trace('p_federal_id=        ' || p_federal_id);
  hr_utility.trace('p_tax_unit_name=     ' || p_tax_unit_name);
  hr_utility.trace('p_street_address=    ' || p_street_address);
  hr_utility.trace('p_city=              ' || p_city);
  hr_utility.trace('p_state=             ' || p_state);
  hr_utility.trace('p_zip=               ' || p_zip);

  hr_utility.set_location(l_api_name,30);

	--
	-- format new hire rocord
	--

	p_end_of_rec := fnd_global.local_chr(13)||fnd_global.local_chr(10);

	l_buffer := upper(p_record_identifier ||
			lpad(' ',4,' ') ||
			rpad(nvl(p_federal_id,' '),11,' ') ||
                        ' ' ||  -- blank 1
			rpad(nvl(p_tax_unit_name,' '),40,' ') ||
                        ' ' ||  -- blank 1
			rpad(nvl(p_street_address,' '),30,' ') ||
			rpad(nvl(p_city,' '),18,' ') ||
			rpad(nvl(p_state,' '),2,' ') ||
			rpad(nvl(p_zip,' '),9,' ') ||
			lpad(' ',10,' '))||p_end_of_rec;


  hr_utility.set_location('Leaving.... :' || l_api_name,40);

	return convert(l_buffer,g_character_set);
exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,70);
                raise;
end ny_1e_record;
--
--
/****************************************************************
 * This procedure formats NEW YORK 1H record for Employee       *
 *                                                              *
 *                                                              *
 ****************************************************************/
function ny_1h_record
(
  p_record_identifier     in  varchar2
 ,p_national_identifier   in  varchar2
 ,p_first_name            in  varchar2
 ,p_middle_name           in  varchar2
 ,p_last_name             in  varchar2
 ,p_street_address        in  varchar2
 ,p_city                  in  varchar2
 ,p_state                 in  varchar2
 ,p_zip                   in  varchar2
 ,p_date_of_hire          in  date
) return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.ny_1h_record';
	l_buffer	varchar2(2000);
        v_ssn           varchar(9);
	p_end_of_rec varchar2(2000);
begin
  hr_utility.set_location('Entering:' ||l_api_name,10);

  hr_utility.trace('p_record_identifier=   ' || p_record_identifier);
  hr_utility.trace('p_national_identifier= ' || p_national_identifier);

  v_ssn := substr(p_national_identifier,1,3) || substr(p_national_identifier,5,2) || substr(p_national_identifier,8,4);

  hr_utility.trace('v_ssn=                 ' || v_ssn);
  hr_utility.trace('p_first_name=          ' || p_first_name);
  hr_utility.trace('p_middle_name=         ' || p_middle_name);
  hr_utility.trace('p_last_name=           ' || p_last_name);

  hr_utility.trace('p_street_address=      ' || p_street_address);
  hr_utility.trace('p_city=                ' || p_city);
  hr_utility.trace('p_state=               ' || p_state);
  hr_utility.trace('p_zip=                 ' || p_zip);
  hr_utility.trace('p_date_of_hire=          ' || to_char(p_date_of_hire));

	--
	-- format new hire rocord
	--

       p_end_of_rec := fnd_global.local_chr(13)||fnd_global.local_chr(10);

	l_buffer := upper(
                p_record_identifier ||
		rpad(nvl(v_ssn,' '),9,' ') ||  -- BUG4504074
                rpad((p_last_name || ',' || nvl(p_first_name,'') || ' ' ||
                     nvl(substr(p_middle_name,1,1),'')),28,' ') ||
		rpad(nvl(p_street_address,' '),30,' ') ||
		rpad(nvl(p_city,' '),18,' ') ||
		rpad(nvl(p_state,' '),2,' ') ||
		rpad(nvl(p_zip,' '),5,' ') ||
		' ' ||  -- blank 1
                rpad(nvl(to_char(p_date_of_hire,'MMDDRR'),' '),6,' ') ||
		lpad(' ',27,' '))||p_end_of_rec;

  hr_utility.trace('l_buffer = ' || l_buffer);


  hr_utility.set_location('Leaving.... :' || l_api_name,60);

	return convert(l_buffer,g_character_set);
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,70);
                raise;
end ny_1h_record;
--
/****************************************************************
 * This procedure formats NEW YORK 1T record                    *
 *                                                              *
 *                                                              *
 ****************************************************************/
FUNCTION ny_1t_record
(
         p_record_identifier 		in varchar2
	,p_number_of_employee		in number
) return varchar2
IS
	l_api_name	varchar2(61) := g_package_name || '.ny_1t_record';
	l_buffer	varchar2(2000);
	p_end_of_rec varchar2(2000);
begin
  --
  hr_utility.set_location('Entering:' ||l_api_name,10);

  hr_utility.trace('p_number_of_emplyee =   ' || p_number_of_employee);

	--
	-- format new hire rocord
	--

	p_end_of_rec := fnd_global.local_chr(13)||fnd_global.local_chr(10);

	l_buffer := upper(
                p_record_identifier ||
		lpad(to_char(p_number_of_employee),7,' ') ||
		lpad(' ',119,' '))||p_end_of_rec;

  hr_utility.set_location(l_api_name,20);

	return convert(l_buffer,g_character_set);
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,30);
		raise;
end ny_1t_record;
--
/****************************************************************
 * This procedure formats NEW YORK 1F record                    *
 *                                                              *
 *                                                              *
 ****************************************************************/
FUNCTION ny_1f_record
(
         p_record_identifier 		in varchar2
	,p_number_of_employer		in number
) return varchar2
IS
	l_api_name	varchar2(61) := g_package_name || '.ny_1f_record';
	l_buffer	varchar2(2000);
	p_end_of_rec varchar2(2000);
begin
  --
  hr_utility.set_location('Entering:' ||l_api_name,10);

  hr_utility.trace('p_number_of_emplyer =   ' || p_number_of_employer);

	--
	-- format new hire rocord
	--

	p_end_of_rec := fnd_global.local_chr(13)||fnd_global.local_chr(10);

	l_buffer := upper(
                p_record_identifier ||
		lpad(to_char(p_number_of_employer),7,' ') ||
		lpad(' ',119,' '))||p_end_of_rec;

  hr_utility.set_location(l_api_name,20);

	return convert(l_buffer,g_character_set);
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,30);
		raise;
end ny_1f_record;
--
/****************************************************************
 * This procedure formats FLORIDA New Hire record               *
 *                                                              *
 *                                                              *
 ****************************************************************/
function fl_new_hire_record
(
         p_record_identifier     in  varchar2
 	,p_first_name            in  varchar2
 	,p_middle_name           in  varchar2
 	,p_last_name             in  varchar2
 	,p_national_identifier   in  varchar2
        ,p_emp_address_line1     in  varchar2
        ,p_emp_address_line2     in  varchar2
        ,p_emp_address_line3     in  varchar2
 	,p_emp_city              in  varchar2
 	,p_emp_state             in  varchar2
 	,p_emp_zip               in  varchar2
 	,p_emp_zip_extension     in  varchar2
 	,p_emp_country_code      in  varchar2
 	,p_date_of_birth         in  date
 	,p_date_of_hire          in  date
 	,p_state_of_hire         in  varchar2
        ,p_federal_id            in  varchar2
        ,p_sit_company_state_id  in  varchar2
        ,p_tax_unit_name         in  varchar2
        ,p_loc_address_line1     in  varchar2
        ,p_loc_address_line2     in  varchar2
        ,p_loc_address_line3     in  varchar2
        ,p_loc_city              in  varchar2
        ,p_loc_state             in  varchar2
 	,p_loc_zip               in  varchar2
 	,p_loc_zip_extension     in  varchar2
 	,p_loc_country_code      in  varchar2
 	,p_loc_phone             in  varchar2
 	,p_loc_phone_extension   in  varchar2
 	,p_loc_contact           in  varchar2
        ,p_opt_address_line1     in  varchar2
        ,p_opt_address_line2     in  varchar2
        ,p_opt_address_line3     in  varchar2
        ,p_opt_city              in  varchar2
        ,p_opt_state             in  varchar2
 	,p_opt_zip               in  varchar2
 	,p_opt_zip_extension     in  varchar2
 	,p_opt_country_code      in  varchar2
 	,p_opt_phone             in  varchar2
 	,p_opt_phone_extension   in  varchar2
 	,p_opt_contact           in  varchar2
 	,p_multi_state           in  varchar2
) return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.fl_new_hire_record';
	l_buffer	varchar2(2000);
        v_ssn           varchar(9);
        l_phone         varchar(10);
        l_opt_phone     varchar(10);
	--bug#8791766
	p_end_of_rec varchar2(2000);
begin

  hr_utility.set_location('Entering...: ' || l_api_name,10);

  hr_utility.trace('p_record_identifier= ' || p_record_identifier);

  hr_utility.trace('p_first_name=       ' || p_first_name);
  hr_utility.trace('p_middle_name=      ' || p_middle_name);
  hr_utility.trace('p_last_name=        ' || p_last_name);

  v_ssn := substr(p_national_identifier,1,3) || substr(p_national_identifier,5,2) || substr(p_national_identifier,8,4);

  hr_utility.trace('v_ssn=               ' || v_ssn);
  hr_utility.trace('p_emp_address_line1= ' || p_emp_address_line1);
  hr_utility.trace('p_emp_address_line2= ' || p_emp_address_line2);
  hr_utility.trace('p_emp_address_line3= ' || p_emp_address_line3);
  hr_utility.trace('p_emp_city=          ' || p_emp_city);
  hr_utility.trace('p_emp_state=         ' || p_emp_state);
  hr_utility.trace('p_emp_zip=           ' || p_emp_zip);
  hr_utility.trace('p_emp_zip_extension= ' || p_emp_zip_extension);
  hr_utility.trace('p_emp_country_code= '  || p_emp_country_code);
  hr_utility.trace('p_date_of_birth=     ' || p_date_of_birth);
  hr_utility.trace('p_date_of_hire=        ' || p_date_of_hire);

  hr_utility.trace('p_federal_id=        ' || p_federal_id);
  hr_utility.trace('p_sit_company_state_id=' || p_sit_company_state_id);
  hr_utility.trace('p_tax_unit_name=     ' || p_tax_unit_name);
  hr_utility.trace('p_loc_address_line1= ' || p_loc_address_line1);
  hr_utility.trace('p_loc_address_line2= ' || p_loc_address_line2);
  hr_utility.trace('p_loc_address_line3= ' || p_loc_address_line3);
  hr_utility.trace('p_loc_city=          ' || p_loc_city);
  hr_utility.trace('p_loc_state=         ' || p_loc_state);
  hr_utility.trace('p_loc_zip=           ' || p_loc_zip);
  hr_utility.trace('p_loc_zip_extension= ' || p_loc_zip_extension);
  hr_utility.trace('p_loc_country_code=  ' || p_loc_country_code);
  hr_utility.trace('p_loc_phone=         ' || p_loc_phone);

  l_phone :=  replace(replace(replace(replace(replace(nvl(p_loc_phone,' '),'(',null),'-',null),'.',null),')',null),' ',null);

  hr_utility.trace('l_phone=              ' || l_phone);
  hr_utility.trace('p_loc_contact=        ' || p_loc_contact);

  l_opt_phone :=  replace(replace(replace(replace(replace(nvl(p_opt_phone,' '),'(',null),'-',null),'.',null),')',null),' ',null);

  hr_utility.trace('l_opt_phone=         ' || l_opt_phone);
  hr_utility.trace('p_multi_state=       ' || p_multi_state);
  hr_utility.set_location(l_api_name,30);
  --bug#8791766
  p_end_of_rec := fnd_global.local_chr(13)||fnd_global.local_chr(10);
	--
	-- format new hire rocord
	--
	l_buffer :=     p_record_identifier || -- 'FL Newhire Record'
			'1.00' ||
                	rpad(nvl(p_first_name,' '),16,' ')  ||
                	rpad(nvl(p_middle_name,' '),16,' ') ||
                	rpad(nvl(p_last_name,' '),30,' ') ||
			rpad(nvl(v_ssn,' '),9,' ') ||
			rpad(nvl(p_emp_address_line1,' '),40,' ') ||
			rpad(nvl(p_emp_address_line2,' '),40,' ') ||
			rpad(nvl(p_emp_address_line3,' '),40,' ') ||
			rpad(nvl(p_emp_city,' '),25,' ') ||
			rpad(nvl(p_emp_state,' '),2,' ') ||
			rpad(nvl(p_emp_zip,' '),20,' ') ||
			rpad(nvl(p_emp_zip_extension,' '),4,' ') ||
			rpad(nvl(p_emp_country_code,' '),2,' ') ||
			nvl(to_char(p_date_of_birth,'MMDDYYYY'),'        ') ||
			nvl(to_char(p_date_of_hire,'MMDDYYYY'),'        ')	||
			'  ' ||  -- rpad(nvl(p_state_of_hire,' '),2,' ') ||
			'  ' ||		-- filler blank 2
			rpad(nvl(p_federal_id,' '),9,' ') ||
			rpad(nvl(p_sit_company_state_id,' '),12,' ') ||
			rpad(nvl(p_tax_unit_name,' '),45,' ') ||
			rpad(nvl(p_loc_address_line1,' '),40,' ') ||
			rpad(nvl(p_loc_address_line2,' '),40,' ') ||
			rpad(nvl(p_loc_address_line3,' '),40,' ') ||
			rpad(nvl(p_loc_city,' '),25,' ') ||
			rpad(nvl(p_loc_state,' '),2,' ') ||
			rpad(nvl(p_loc_zip,' '),20,' ') ||
			rpad(nvl(p_loc_zip_extension,' '),4,' ') ||
			rpad(nvl(p_loc_country_code,' '),2,' ') ||
			rpad(nvl(l_phone,' '),10,' ') ||
			rpad(nvl(p_loc_phone_extension,' '),6,' ') ||
			rpad(nvl(p_loc_contact,' '),20,' ') ||
			rpad(nvl(p_opt_address_line1,' '),40,' ') ||
			rpad(nvl(p_opt_address_line2,' '),40,' ') ||
			rpad(nvl(p_opt_address_line3,' '),40,' ') ||
			rpad(nvl(p_opt_city,' '),25,' ') ||
			rpad(nvl(p_opt_state,' '),2,' ') ||
			rpad(nvl(p_opt_zip,' '),20,' ') ||
			rpad(nvl(p_opt_zip_extension,' '),4,' ') ||
			rpad(nvl(p_opt_country_code,' '),2,' ') ||
			rpad(nvl(l_opt_phone,' '),10,' ') ||
			rpad(nvl(p_opt_phone_extension,' '),6,' ') ||
			rpad(nvl(p_opt_contact,' '),20,' ') ||
 			' ' || 		-- filler blank 1
			rpad(nvl(p_multi_state,' '),1,' ') ||
			--bug#8791766
			rpad(' ',30,' ')||p_end_of_rec;   -- filler blank 30


  hr_utility.set_location('Leaving.... :' || l_api_name,40);

	return convert(l_buffer,g_character_set);
  exception
	when others then
  		hr_utility.set_location('Leaving.... with ERROR :' || l_api_name,200);
                raise;
end fl_new_hire_record;
--
/****************************************************************
 * This procedure formats ILLINOIS New Hire record              *
 *                                                              *
 *                                                              *
 ****************************************************************/
function il_new_hire_record
(
         p_record_identifier     in  varchar2
 	,p_national_identifier   in  varchar2
 	,p_first_name            in  varchar2
 	,p_middle_name           in  varchar2
 	,p_last_name             in  varchar2
        ,p_emp_address_line1     in  varchar2
        ,p_emp_address_line2     in  varchar2
 	,p_emp_city              in  varchar2
 	,p_emp_state             in  varchar2
 	,p_emp_zip               in  varchar2
 	,p_emp_zip_extension     in  varchar2
 	,p_date_of_hire          in  date
        ,p_federal_id            in  varchar2
        ,p_tax_unit_name         in  varchar2
        ,p_loc_address_line1     in  varchar2
        ,p_loc_address_line2     in  varchar2
        ,p_loc_city              in  varchar2
        ,p_loc_state             in  varchar2
 	,p_loc_zip               in  varchar2
 	,p_loc_zip_extension     in  varchar2
        ,p_opt_address_line1     in  varchar2
        ,p_opt_address_line2     in  varchar2
        ,p_opt_city              in  varchar2
        ,p_opt_state             in  varchar2
 	,p_opt_zip               in  varchar2
 	,p_opt_zip_extension     in  varchar2
) return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.il_new_hire_record';
	l_buffer	varchar2(2000);
        v_ssn           varchar(9);
begin

  hr_utility.set_location('Entering...: ' ||l_api_name,10);

  hr_utility.trace('p_record_identifier= ' ||p_record_identifier);
  v_ssn := substr(p_national_identifier,1,3) || substr(p_national_identifier,5,2) || substr(p_national_identifier,8,4);

  hr_utility.trace('v_ssn=               ' ||v_ssn);

  hr_utility.trace('p_emp_address_line1= ' || p_emp_address_line1);
  hr_utility.trace('p_emp_address_line2= ' || p_emp_address_line2);
  hr_utility.trace('p_emp_city=          ' || p_emp_city);
  hr_utility.trace('p_emp_state=         ' || p_emp_state);
  hr_utility.trace('p_emp_zip=           ' || p_emp_zip);
  hr_utility.trace('p_emp_zip_extension= ' || p_emp_zip_extension);
  hr_utility.trace('p_date_of_hire=        ' || p_date_of_hire);

  hr_utility.trace('p_federal_id=        ' || p_federal_id);
  hr_utility.trace('p_tax_unit_name=     ' || p_tax_unit_name);
  hr_utility.trace('p_loc_address_line1= ' || p_loc_address_line1);
  hr_utility.trace('p_loc_address_line2= ' || p_loc_address_line2);
  hr_utility.trace('p_loc_city=          ' || p_loc_city);
  hr_utility.trace('p_loc_state=         ' || p_loc_state);
  hr_utility.trace('p_loc_zip=           ' || p_loc_zip);
  hr_utility.trace('p_loc_zip_extension= ' || p_loc_zip_extension);

  hr_utility.set_location(l_api_name,30);
	--
	-- format new hire rocord
	--
	l_buffer :=     p_record_identifier || -- 'W4'
			rpad(nvl(v_ssn,' '),9,' ') ||
                	rpad(nvl(p_first_name,' '),16,' ')  ||
                	rpad(nvl(p_middle_name,' '),16,' ') ||
                	rpad(nvl(p_last_name,' '),30,' ') ||
			rpad(nvl(p_emp_address_line1,' '),40,' ') ||
			rpad(nvl(p_emp_address_line2,' '),40,' ') ||
			rpad(' ',40,' ') ||
			rpad(nvl(p_emp_city,' '),25,' ') ||
			rpad(nvl(p_emp_state,' '),2,' ') ||
			rpad(nvl(p_emp_zip,' '),5,' ') ||
			rpad(nvl(p_emp_zip_extension,' '),4,' ') ||
			rpad(' ',42,' ') ||
			rpad(' ',8,' ') ||
			nvl(to_char(p_date_of_hire,'YYYYMMDD'),'        ')	||
			'  ' || 		-- 2 blank
			rpad(nvl(p_federal_id,' '),9,' ') ||
			rpad(' ',12,' ') ||
			rpad(nvl(p_tax_unit_name,' '),45,' ') ||
			rpad(nvl(p_loc_address_line1,' '),40,' ') ||
			rpad(nvl(p_loc_address_line2,' '),40,' ') ||
			rpad(' ',40,' ') ||
			rpad(nvl(p_loc_city,' '),25,' ') ||
			rpad(nvl(p_loc_state,' '),2,' ') ||
			rpad(nvl(p_loc_zip,' '),5,' ') ||
			rpad(nvl(p_loc_zip_extension,' '),4,' ') ||
			rpad(' ',42,' ') ||
			rpad(nvl(p_opt_address_line1,' '),40,' ') ||
			rpad(nvl(p_opt_address_line2,' '),40,' ') ||
			rpad(' ',40,' ') ||
			rpad(nvl(p_opt_city,' '),25,' ') ||
			rpad(nvl(p_opt_state,' '),2,' ') ||
			rpad(nvl(p_opt_zip,' '),5,' ') ||
			rpad(nvl(p_opt_zip_extension,' '),4,' ') ||
			rpad(' ',42,' ') ||
			rpad(' ',50,' ') ;



  hr_utility.set_location('Leaving.... :' || l_api_name,100);

	return convert(l_buffer,g_character_set);
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,200);
                raise;
end il_new_hire_record;

-- sjawid al

function al_new_hire_record
(
         p_national_identifier   in  varchar2
        ,p_dir_acc_number        in  varchar2
        ,p_date_of_hire          in  date
        ,p_indicator             in  varchar2
        ,p_first_name            in  varchar2
        ,p_middle_name           in  varchar2
        ,p_last_name             in  varchar2
        ,p_emp_address_line1     in  varchar2
	,p_emp_address_line2     in  varchar2
	,p_emp_address_line3     in  varchar2
        ,p_emp_city              in  varchar2
        ,p_emp_state             in  varchar2
        ,p_emp_zip               in  varchar2
        ,p_emp_zip_extension     in  varchar2
        ,p_federal_id            in  varchar2
	,p_tax_unit_name               in  varchar2
	,p_loc_address_line1            in  varchar2
	,p_loc_address_line2            in  varchar2
	,p_loc_address_line3            in  varchar2
	,p_loc_city               in  varchar2
	,p_loc_state               in  varchar2
	,p_loc_zip               in  varchar2
        ,p_blanks                in  varchar2
) return varchar2
is
 l_api_name	varchar2(61) := g_package_name || '.al_new_hire_record';
 l_buffer	varchar2(2000);
 v_ssn           varchar(9);
    function format_text(p_text in varchar2,p_length in number) return varchar2
    is
    begin
     return (rpad(nvl(p_text,' '),p_length,' ') );
    end format_text;
begin
v_ssn := substr(p_national_identifier,1,3) || substr(p_national_identifier,5,2) || substr(p_national_identifier,8,4);

 	l_buffer := format_text(v_ssn,9)||  --Social Security Number
	            -- format_text(p_dir_acc_number,10)||
		    lpad(nvl(p_dir_acc_number,' '),10,'0')|| --Account Number**
		    format_text(to_char(p_date_of_hire,'MMDDYY'),6)|| --Activity Date
		    format_text(p_indicator,'1')|| --Indicator
		    format_text(p_last_name||'/'||p_first_name||'/'||p_middle_name||' '||substr(p_middle_name,1,1),27)|| --Employee's Name
		    format_text(p_emp_address_line1||' '||p_emp_address_line2||' '||p_emp_address_line3,30)|| --Employee's Street Address
		    format_text(p_emp_city,20)|| --Employee's City Name
		    format_text(p_emp_state,2)|| --Employee's State Name
		    format_text(p_emp_zip||p_emp_zip_extension,9)||--Employee's ZIP + 4 ZIP Code
		    format_text(p_federal_id,9)||  --Employer's FEIN
		    format_text(p_tax_unit_name,20)|| --Employer's name
		    format_text(p_loc_address_line1||' '||p_loc_address_line2||' '||p_loc_address_line3,14)|| --employers address
		    format_text(p_loc_city,11)|| --employers city
		    format_text(p_loc_state,2)|| --employers state
		    format_text(p_loc_zip,5)|| --employers zip
		    format_text(' ',25);

        return l_buffer;
end al_new_hire_record;
-- sjawid end al
--
/****************************************************************
 * This procedure formats Texas T4 record                       *
 *                                                              *
 *                                                              *
 ****************************************************************/
FUNCTION tx_t4_record
(
         p_record_identifier 		in varchar2
	,p_number_of_employee		in number
) return varchar2
IS
	l_api_name	varchar2(61) := g_package_name || '.tx_t4_record';
	l_buffer	varchar2(2000);
begin
  --
  hr_utility.set_location('Entering:' ||l_api_name,10);

  hr_utility.trace('p_record_identifier=   ' || p_record_identifier);
  hr_utility.trace('p_number_of_emplyee =  ' || p_number_of_employee);

	--
	-- format new hire rocord
	--
	l_buffer := upper(
                p_record_identifier ||
		lpad(to_char(p_number_of_employee),11,'0') ||
		lpad(' ',788,' '));

  hr_utility.set_location(l_api_name,20);

	return convert(l_buffer,g_character_set);
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,30);
		raise;
end tx_t4_record;
--
/****************************************************************
 * This procedure formats TEXAS New Hire record                 *
 *                                                              *
 *                                                              *
 ****************************************************************/
function tx_new_hire_record
(
         p_record_identifier     in  varchar2
 	,p_national_identifier   in  varchar2
 	,p_first_name            in  varchar2
 	,p_middle_name           in  varchar2
 	,p_last_name             in  varchar2
        ,p_emp_address_line1     in  varchar2
        ,p_emp_address_line2     in  varchar2
 	,p_emp_city              in  varchar2
 	,p_emp_state             in  varchar2
 	,p_emp_zip               in  varchar2
 	,p_emp_zip_extension     in  varchar2
 	,p_emp_country_code      in  varchar2
 	,p_emp_country_name	 in  varchar2
 	,p_emp_country_zip	 in  varchar2
 	,p_date_of_birth         in  date
 	,p_date_of_hire          in  date
 	,p_state_of_hire	 in  varchar2
        ,p_federal_id            in  varchar2
        ,p_state_ein             in  varchar2
        ,p_tax_unit_name         in  varchar2
        ,p_loc_address_line1     in  varchar2
        ,p_loc_address_line2     in  varchar2
        ,p_loc_address_line3     in  varchar2
        ,p_loc_city              in  varchar2
        ,p_loc_state             in  varchar2
 	,p_loc_zip               in  varchar2
 	,p_loc_zip_extension     in  varchar2
 	,p_loc_country_code      in  varchar2
 	,p_loc_country_name	 in  varchar2
 	,p_loc_country_zip	 in  varchar2
        ,p_opt_address_line1     in  varchar2
        ,p_opt_address_line2     in  varchar2
        ,p_opt_address_line3     in  varchar2
        ,p_opt_city              in  varchar2
        ,p_opt_state             in  varchar2
 	,p_opt_zip               in  varchar2
 	,p_opt_zip_extension     in  varchar2
 	,p_opt_country_code      in  varchar2
 	,p_opt_country_name	 in  varchar2
 	,p_opt_country_zip	 in  varchar2
 	,p_salary       	 in  varchar2
 	,p_frequency       	 in  varchar2
) return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.tx_new_hire_record';
	l_buffer	varchar2(2000);
        v_ssn           varchar(9);
begin

  hr_utility.set_location('Entering...: ' || l_api_name,10);

  hr_utility.trace('p_record_identifier= ' || p_record_identifier);
  hr_utility.trace('p_federal_id=        ' || p_federal_id);
  hr_utility.trace('p_tax_unit_name=     ' || p_tax_unit_name);
  v_ssn := substr(p_national_identifier,1,3) || substr(p_national_identifier,5,2) || substr(p_national_identifier,8,4);

  hr_utility.trace('v_ssn=               ' || v_ssn);
  hr_utility.trace('p_first_name       = ' || p_first_name);
  hr_utility.trace('p_middle_name      = ' || p_middle_name);
  hr_utility.trace('p_last_name        = ' || p_last_name);
  hr_utility.trace('p_emp_address_line1= ' || p_emp_address_line1);
  hr_utility.trace('p_emp_address_line2= ' || p_emp_address_line2);
  hr_utility.trace('p_emp_city=          ' || p_emp_city);
  hr_utility.trace('p_emp_state=         ' || p_emp_state);
  hr_utility.trace('p_emp_zip=           ' || p_emp_zip);
  hr_utility.trace('p_emp_zip_extension= ' || p_emp_zip_extension);
  hr_utility.trace('p_date_of_birth=     ' || p_date_of_birth);
  hr_utility.trace('p_date_of_hire=      ' || p_date_of_hire);
  hr_utility.trace('p_state_of_hire=     ' || p_state_of_hire);

  hr_utility.trace('p_loc_address_line1= ' || p_loc_address_line1);
  hr_utility.trace('p_loc_address_line2= ' || p_loc_address_line2);
  hr_utility.trace('p_loc_address_line3= ' || p_loc_address_line3);
  hr_utility.trace('p_loc_city=          ' || p_loc_city);
  hr_utility.trace('p_loc_state=         ' || p_loc_state);
  hr_utility.trace('p_loc_zip=           ' || p_loc_zip);
  hr_utility.trace('p_loc_zip_extension= ' || p_loc_zip_extension);

  hr_utility.trace('p_salary=            ' || p_salary);
  hr_utility.trace('p_frequency=         ' || p_frequency);

  hr_utility.set_location(l_api_name,30);

	--
	-- format new hire rocord
	--
	l_buffer :=     upper(
			p_record_identifier || -- 'W4'
			rpad(nvl(v_ssn,' '),9,' ') ||   -- BUG4504074
                	rpad(nvl(p_first_name,' '),16,' ')  ||
                	rpad(nvl(p_middle_name,' '),16,' ') ||
                	rpad(nvl(p_last_name,' '),30,' ') ||
			rpad(nvl(p_emp_address_line1,' '),40,' ') ||
			rpad(nvl(p_emp_address_line2,' '),40,' ') ||
			rpad(' ',40,' ') ||
			rpad(nvl(p_emp_city,' '),25,' ') ||
			rpad(nvl(p_emp_state,' '),2,' ') ||
			rpad(nvl(p_emp_zip,' '),5,' ') ||
			rpad(nvl(p_emp_zip_extension,' '),4,' ') ||
			rpad(nvl(p_emp_country_code,' '),2,' ') ||
			rpad(nvl(p_emp_country_name,' '),25,' ') ||
			rpad(nvl(p_emp_country_zip,' '),15,' ') ||
			-- nvl(to_char(p_date_of_birth,'YYYYMMDD'),'        ') || -- BUG3954955
			-- nvl(to_char(p_date_of_hire,'YYYYMMDD'),'        ') || -- BUG3954955
			nvl(to_char(p_date_of_birth,'MMDDYYYY'),'        ') || -- BUG 8515583
			nvl(to_char(p_date_of_hire,'MMDDYYYY'),'        ') || -- BUG 8515583
			rpad(nvl(p_state_of_hire,' '),2,' ') ||
			rpad(nvl(p_federal_id,' '),9,' ') ||
			rpad(nvl(p_state_ein,' '),12,' ') ||
			rpad(nvl(p_tax_unit_name,' '),45,' ') ||
			rpad(nvl(p_loc_address_line1,' '),40,' ') ||
			rpad(nvl(p_loc_address_line2,' '),40,' ') ||
			rpad(nvl(p_loc_address_line3,' '),40,' ') ||
			rpad(nvl(p_loc_city,' '),25,' ') ||
			rpad(nvl(p_loc_state,' '),2,' ') ||
			rpad(nvl(p_loc_zip,' '),5,' ') ||
			rpad(nvl(p_loc_zip_extension,' '),4,' ') ||
			rpad(nvl(p_loc_country_code,' '),2,' ') ||
			rpad(nvl(p_loc_country_name,' '),25,' ') ||
			rpad(nvl(p_loc_country_zip,' '),15,' ') ||
			rpad(nvl(p_opt_address_line1,' '),40,' ') ||
			rpad(nvl(p_opt_address_line2,' '),40,' ') ||
			rpad(nvl(p_opt_address_line3,' '),40,' ') ||
			rpad(nvl(p_opt_city,' '),25,' ') ||
			rpad(nvl(p_opt_state,' '),2,' ') ||
			rpad(nvl(p_opt_zip,' '),5,' ') ||
			rpad(nvl(p_opt_zip_extension,' '),4,' ') ||
			rpad(nvl(p_opt_country_code,' '),2,' ') ||
			rpad(nvl(p_opt_country_name,' '),25,' ') ||
			rpad(nvl(p_opt_country_zip,' '),15,' ') ||
			rpad(' ',10,' ') ||
			rpad(' ',9) ||  -- rpad(nvl(p_salary,' '),9,'0') ||
			' ' ||          -- rpad(nvl(p_frequency,' '),1,' ') ||
			rpad(' ',30,' ')) ;


  hr_utility.set_location('Leaving.... :' || l_api_name,100);


	return convert(l_buffer,g_character_set);
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,200);
                raise;
end tx_new_hire_record;
--
/****************************************************************
 * This procedure formats a03 FL new hire audit report          *
 *                                                              *
 *                                                              *
 ****************************************************************/
function a03_fl_new_hire_header
return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.a03_fl_new_hire_header';
	l_buffer	varchar2(2000);
begin
  --
  hr_utility.set_location('Entering...: ' || l_api_name,10);
  l_buffer := 	'First Name' || g_delimiter ||
		'Middle Name'  || g_delimiter ||
		'Last Name' || g_delimiter ||
   	 	'Social Security Number' || g_delimiter ||
		'Employee Address Line 1' || g_delimiter ||
		'Employee Address Line 2' || g_delimiter ||
		'Employee Address Line 3' || g_delimiter ||
		'Employee City' || g_delimiter ||
		'Employee State' || g_delimiter ||
		'Employee Zip' || g_delimiter ||
		'Employee Zip Extension' || g_delimiter ||
		'Employee Country Code' || g_delimiter ||
		'Date of Birth' || g_delimiter ||
		'Date of Hire' || g_delimiter ||
		'State of Hire' || g_delimiter ||
		'FEIN' || g_delimiter ||
		'State SUI' || g_delimiter ||
		'Employer Name' || g_delimiter ||
		'Employer Address Line 1' || g_delimiter ||
		'Employer Address Line 2' 	 || g_delimiter ||
		'Employer Address Line 3' 	 || g_delimiter ||
		'Employer City' || g_delimiter ||
		'Employer State' || g_delimiter ||
		'Employer Zip' || g_delimiter ||
		'Employer Zip Extension' || g_delimiter ||
		'Employer Country Code' || g_delimiter ||
		'Employer Phone' || g_delimiter ||
		'Employer Contact' || g_delimiter ||
		'Multi-State Indicator' ||
      		g_eol;

  hr_utility.set_location('Leaving.... :' || l_api_name,100);

	return l_buffer;
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,200);
                raise;
end a03_fl_new_hire_header;
--
/****************************************************************
 * This procedure formats a03 Florida new hire audit report     *
 *                                                              *
 *                                                              *
 ****************************************************************/
function a03_fl_new_hire_record
(
 	 p_national_identifier   in  varchar2
 	,p_first_name            in  varchar2
 	,p_middle_name           in  varchar2
 	,p_last_name             in  varchar2
        ,p_emp_address_line1     in  varchar2
        ,p_emp_address_line2     in  varchar2
        ,p_emp_address_line3     in  varchar2
 	,p_emp_city              in  varchar2
 	,p_emp_state             in  varchar2
 	,p_emp_zip               in  varchar2
 	,p_emp_zip_extension     in  varchar2
 	,p_emp_country_code      in  varchar2
 	,p_date_of_birth         in  date
 	,p_date_of_hire          in  date
        ,p_state_of_hire         in  varchar2
        ,p_federal_id            in  varchar2
        ,p_state_ein             in  varchar2
        ,p_tax_unit_name         in  varchar2
        ,p_loc_address_line1     in  varchar2
        ,p_loc_address_line2     in  varchar2
        ,p_loc_address_line3     in  varchar2
        ,p_loc_city              in  varchar2
        ,p_loc_state             in  varchar2
 	,p_loc_zip               in  varchar2
 	,p_loc_zip_extension     in  varchar2
 	,p_loc_country_code      in  varchar2
 	,p_contact_phone	 in  varchar2
 	,p_contact_phone_ext	 in  varchar2
 	,p_contact_name		 in  varchar2
 	,p_multi_state		 in  varchar2
) return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.a03_fl_new_hire_record';
	l_buffer	varchar2(2000);
        v_ssn           varchar(9);
begin

  hr_utility.set_location('Entering...: ' || l_api_name,10);

  hr_utility.trace('p_federal_id=        ' || p_federal_id);
  hr_utility.trace('p_tax_unit_name=     ' || p_tax_unit_name);
  v_ssn := substr(p_national_identifier,1,3) || substr(p_national_identifier,5,2) || substr(p_national_identifier,8,4);

  hr_utility.trace('v_ssn=               ' || v_ssn);
  hr_utility.trace('p_first_name=        ' || p_first_name);
  hr_utility.trace('p_middle_name=       ' || p_middle_name);
  hr_utility.trace('p_last_name=         ' || p_last_name);
  hr_utility.trace('p_emp_address_line1= ' || p_emp_address_line1);
  hr_utility.trace('p_emp_address_line2= ' || p_emp_address_line2);
  hr_utility.trace('p_emp_city=          ' || p_emp_city);
  hr_utility.trace('p_emp_state=         ' || p_emp_state);
  hr_utility.trace('p_emp_zip=           ' || p_emp_zip);
  hr_utility.trace('p_emp_zip_extension= ' || p_emp_zip_extension);
  hr_utility.trace('p_date_of_birth=     ' || p_date_of_birth);
  hr_utility.trace('p_date_of_hire=      ' || p_date_of_hire);

  hr_utility.trace('p_loc_address_line1= ' || p_loc_address_line1);
  hr_utility.trace('p_loc_address_line2= ' || p_loc_address_line2);
  hr_utility.trace('p_loc_city=          ' || p_loc_city);
  hr_utility.trace('p_loc_state=         ' || p_loc_state);
  hr_utility.trace('p_loc_zip=           ' || p_loc_zip);
  hr_utility.trace('p_loc_zip_extension= ' || p_loc_zip_extension);
  hr_utility.trace('p_contact_phone =    ' || p_contact_phone);
  hr_utility.trace('p_contact_name =     ' || p_contact_name);


  hr_utility.set_location(l_api_name,30);

	--
	-- format new hire rocord
	--
	l_buffer :=     replace(nvl(p_first_name,''),',',' ')  || g_delimiter ||
                	replace(nvl(p_middle_name,''),',',' ') || g_delimiter ||
                	replace(p_last_name,',',' ') || g_delimiter ||
			v_ssn || g_delimiter ||
			replace(nvl(p_emp_address_line1,' '),',',' ') || g_delimiter ||
			replace(nvl(p_emp_address_line2,' '),',',' ') || g_delimiter ||
			replace(nvl(p_emp_address_line3,' '),',',' ') || g_delimiter ||
			replace(nvl(p_emp_city,' '),',',' ') || g_delimiter ||
			nvl(p_emp_state,' ') || g_delimiter ||
			nvl(p_emp_zip,' ') || g_delimiter ||
			nvl(p_emp_zip_extension,' ') || g_delimiter ||
			nvl(p_emp_country_code,' ') || g_delimiter ||
			nvl(to_char(p_date_of_birth,'MMDDYYYY'),' ')	|| g_delimiter ||
			nvl(to_char(p_date_of_hire,'MMDDYYYY'),' ')	|| g_delimiter ||
		        nvl(p_state_of_hire,' ') || g_delimiter ||
			nvl(p_federal_id,' ') || g_delimiter ||
			nvl(p_state_ein,' ') || g_delimiter ||
			replace(nvl(p_tax_unit_name,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_address_line1,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_address_line2,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_address_line3,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_city,' '),',',' ') || g_delimiter ||
			nvl(p_loc_state,' ') || g_delimiter ||
			nvl(p_loc_zip,' ') || g_delimiter ||
			nvl(p_loc_zip_extension,' ') || g_delimiter ||
			nvl(p_loc_country_code,' ') || g_delimiter ||
			nvl(p_contact_phone,' ') || g_delimiter ||
			replace(nvl(p_contact_name,' '),',',' ') || g_delimiter ||
			nvl(p_multi_state,' ') ||
                        g_eol;

  hr_utility.set_location('Leaving.... :' || l_api_name,100);

	return l_buffer;
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,200);
                raise;
end a03_fl_new_hire_record;
--

-- al audit report

function a03_al_new_hire_header
return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.a03_al_new_hire_header';
	l_buffer	varchar2(2000);
begin
  --
  hr_utility.set_location('Entering...: ' || l_api_name,10);
  l_buffer := 	'First Name' || g_delimiter ||
		'Middle Name'  || g_delimiter ||
		'Last Name' || g_delimiter ||
   	 	'Social Security Number' || g_delimiter ||
		'Employee Address Line 1' || g_delimiter ||
		'Employee Address Line 2' || g_delimiter ||
		'Employee Address Line 3' || g_delimiter ||
		'Employee City' || g_delimiter ||
		'Employee State' || g_delimiter ||
		'Employee Zip' || g_delimiter ||
		'Employee Zip Extension' || g_delimiter ||
		'Employee Country Code' || g_delimiter ||
		'Date of Birth' || g_delimiter ||
		'Date of Hire' || g_delimiter ||
		'State of Hire' || g_delimiter ||
		'FEIN' || g_delimiter ||
		'State SUI' || g_delimiter ||
		'Employer Name' || g_delimiter ||
		'Employer Address Line 1' || g_delimiter ||
		'Employer Address Line 2' 	 || g_delimiter ||
		'Employer Address Line 3' 	 || g_delimiter ||
		'Employer City' || g_delimiter ||
		'Employer State' || g_delimiter ||
		'Employer Zip' || g_delimiter ||
		'Employer Zip Extension' || g_delimiter ||
		'Employer Country Code' || g_delimiter ||
		'Employer Phone' || g_delimiter ||
		'Employer Contact' || g_delimiter ||
		'Multi-State Indicator' ||
      		g_eol;

  hr_utility.set_location('Leaving.... :' || l_api_name,100);

	return l_buffer;
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,200);
                raise;
end a03_al_new_hire_header;


function a03_al_new_hire_record
(
 	 p_national_identifier   in  varchar2
 	,p_first_name            in  varchar2
 	,p_middle_name           in  varchar2
 	,p_last_name             in  varchar2
        ,p_emp_address_line1     in  varchar2
        ,p_emp_address_line2     in  varchar2
        ,p_emp_address_line3     in  varchar2
 	,p_emp_city              in  varchar2
 	,p_emp_state             in  varchar2
 	,p_emp_zip               in  varchar2
 	,p_emp_zip_extension     in  varchar2
 	,p_emp_country_code      in  varchar2
 	,p_date_of_birth         in  date
 	,p_date_of_hire          in  date
        ,p_state_of_hire         in  varchar2
        ,p_federal_id            in  varchar2
        ,p_state_ein             in  varchar2
        ,p_tax_unit_name         in  varchar2
        ,p_loc_address_line1     in  varchar2
        ,p_loc_address_line2     in  varchar2
        ,p_loc_address_line3     in  varchar2
        ,p_loc_city              in  varchar2
        ,p_loc_state             in  varchar2
 	,p_loc_zip               in  varchar2
 	,p_loc_zip_extension     in  varchar2
 	,p_loc_country_code      in  varchar2
 	,p_contact_phone	 in  varchar2
 	,p_contact_phone_ext	 in  varchar2
 	,p_contact_name		 in  varchar2
 	,p_multi_state		 in  varchar2
) return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.a03_al_new_hire_record';
	l_buffer	varchar2(2000);
        v_ssn           varchar(9);
begin

  hr_utility.set_location('Entering...: ' || l_api_name,10);

  hr_utility.trace('p_federal_id=        ' || p_federal_id);
  hr_utility.trace('p_tax_unit_name=     ' || p_tax_unit_name);
  v_ssn := substr(p_national_identifier,1,3) || substr(p_national_identifier,5,2) || substr(p_national_identifier,8,4);

  hr_utility.trace('v_ssn=               ' || v_ssn);
  hr_utility.trace('p_first_name=        ' || p_first_name);
  hr_utility.trace('p_middle_name=       ' || p_middle_name);
  hr_utility.trace('p_last_name=         ' || p_last_name);
  hr_utility.trace('p_emp_address_line1= ' || p_emp_address_line1);
  hr_utility.trace('p_emp_address_line2= ' || p_emp_address_line2);
  hr_utility.trace('p_emp_city=          ' || p_emp_city);
  hr_utility.trace('p_emp_state=         ' || p_emp_state);
  hr_utility.trace('p_emp_zip=           ' || p_emp_zip);
  hr_utility.trace('p_emp_zip_extension= ' || p_emp_zip_extension);
  hr_utility.trace('p_date_of_birth=     ' || p_date_of_birth);
  hr_utility.trace('p_date_of_hire=      ' || p_date_of_hire);

  hr_utility.trace('p_loc_address_line1= ' || p_loc_address_line1);
  hr_utility.trace('p_loc_address_line2= ' || p_loc_address_line2);
  hr_utility.trace('p_loc_city=          ' || p_loc_city);
  hr_utility.trace('p_loc_state=         ' || p_loc_state);
  hr_utility.trace('p_loc_zip=           ' || p_loc_zip);
  hr_utility.trace('p_loc_zip_extension= ' || p_loc_zip_extension);
  hr_utility.trace('p_contact_phone =    ' || p_contact_phone);
  hr_utility.trace('p_contact_name =     ' || p_contact_name);


  hr_utility.set_location(l_api_name,30);

	--
	-- format new hire rocord
	--
	l_buffer :=     replace(nvl(p_first_name,''),',',' ')  || g_delimiter ||
                	replace(nvl(p_middle_name,''),',',' ') || g_delimiter ||
                	replace(p_last_name,',',' ') || g_delimiter ||
			v_ssn || g_delimiter ||
			replace(nvl(p_emp_address_line1,' '),',',' ') || g_delimiter ||
			replace(nvl(p_emp_address_line2,' '),',',' ') || g_delimiter ||
			replace(nvl(p_emp_address_line3,' '),',',' ') || g_delimiter ||
			replace(nvl(p_emp_city,' '),',',' ') || g_delimiter ||
			nvl(p_emp_state,' ') || g_delimiter ||
			nvl(p_emp_zip,' ') || g_delimiter ||
			nvl(p_emp_zip_extension,' ') || g_delimiter ||
			nvl(p_emp_country_code,' ') || g_delimiter ||
			nvl(to_char(p_date_of_birth,'MMDDYYYY'),' ')	|| g_delimiter ||
			nvl(to_char(p_date_of_hire,'MMDDYYYY'),' ')	|| g_delimiter ||
		        nvl(p_state_of_hire,' ') || g_delimiter ||
			nvl(p_federal_id,' ') || g_delimiter ||
			nvl(p_state_ein,' ') || g_delimiter ||
			replace(nvl(p_tax_unit_name,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_address_line1,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_address_line2,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_address_line3,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_city,' '),',',' ') || g_delimiter ||
			nvl(p_loc_state,' ') || g_delimiter ||
			nvl(p_loc_zip,' ') || g_delimiter ||
			nvl(p_loc_zip_extension,' ') || g_delimiter ||
			nvl(p_loc_country_code,' ') || g_delimiter ||
			nvl(p_contact_phone,' ') || g_delimiter ||
			replace(nvl(p_contact_name,' '),',',' ') || g_delimiter ||
			nvl(p_multi_state,' ') ||
                        g_eol;

  hr_utility.set_location('Leaving.... :' || l_api_name,100);

	return l_buffer;
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,200);
                raise;
end a03_al_new_hire_record;
--

/****************************************************************
 * This procedure formats a03 IL new hire audit report          *
 *                                                              *
 *                                                              *
 ****************************************************************/
function a03_il_new_hire_header
return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.a03_il_new_hire_header';
	l_buffer	varchar2(2000);
begin
  --
  hr_utility.set_location('Entering...: ' || l_api_name,10);
  l_buffer := 	'Social Security Number' || g_delimiter ||
  	 	'First Name' || g_delimiter ||
		'Middle Name'  || g_delimiter ||
		'Last Name' || g_delimiter ||
		'Employee Address Line 1' || g_delimiter ||
		'Employee Address Line 2' || g_delimiter ||
		'Employee City' || g_delimiter ||
		'Employee State' || g_delimiter ||
		'Employee Zip' || g_delimiter ||
		'Employee Zip Extension' || g_delimiter ||
		'Date of Hire' || g_delimiter ||
		'FEIN' || g_delimiter ||
		'Employer Name' || g_delimiter ||
		'Employer Address Line 1' || g_delimiter ||
		'Employer Address Line 2' 	 || g_delimiter ||
		'Employer City' || g_delimiter ||
		'Employer State' || g_delimiter ||
		'Employer Zip' || g_delimiter ||
		'Employer Zip Extension' || g_delimiter ||
  		g_eol;

  hr_utility.set_location('Leaving.... :' || l_api_name,100);

	return l_buffer;
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,200);
                raise;
end a03_il_new_hire_header;
--
/****************************************************************
 * This procedure formats a03 IL new hire audit report          *
 *                                                              *
 *                                                              *
 ****************************************************************/
function a03_il_new_hire_record
(
 	 p_national_identifier   in  varchar2
 	,p_first_name            in  varchar2
 	,p_middle_name           in  varchar2
 	,p_last_name             in  varchar2
        ,p_emp_address_line1     in  varchar2
        ,p_emp_address_line2     in  varchar2
 	,p_emp_city              in  varchar2
 	,p_emp_state             in  varchar2
 	,p_emp_zip               in  varchar2
 	,p_emp_zip_extension     in  varchar2
 	,p_date_of_hire	         in  date
        ,p_federal_id            in  varchar2
        ,p_tax_unit_name         in  varchar2
        ,p_loc_address_line1     in  varchar2
        ,p_loc_address_line2     in  varchar2
        ,p_loc_city              in  varchar2
        ,p_loc_state             in  varchar2
 	,p_loc_zip               in  varchar2
 	,p_loc_zip_extension     in  varchar2
) return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.a03_il_new_hire_record';
	l_buffer	varchar2(2000);
        v_ssn           varchar(9);
begin

  hr_utility.set_location('Entering...: ' || l_api_name,10);

  hr_utility.trace('p_federal_id=        ' || p_federal_id);
  hr_utility.trace('p_tax_unit_name=     ' || p_tax_unit_name);
  v_ssn := substr(p_national_identifier,1,3) || substr(p_national_identifier,5,2) || substr(p_national_identifier,8,4);

  hr_utility.trace('v_ssn=               ' || v_ssn);
  hr_utility.trace('p_first_name=        ' || p_first_name);
  hr_utility.trace('p_middle_name=       ' || p_middle_name);
  hr_utility.trace('p_last_name=         ' || p_last_name);
  hr_utility.trace('p_emp_address_line1= ' || p_emp_address_line1);
  hr_utility.trace('p_emp_address_line2= ' || p_emp_address_line2);
  hr_utility.trace('p_emp_city=          ' || p_emp_city);
  hr_utility.trace('p_emp_state=         ' || p_emp_state);
  hr_utility.trace('p_emp_zip=           ' || p_emp_zip);
  hr_utility.trace('p_emp_zip_extension= ' || p_emp_zip_extension);
  hr_utility.trace('p_date_of_birth=     ' || p_date_of_hire);

  hr_utility.set_location(l_api_name,30);

	--
	-- format new hire rocord
	--
	l_buffer :=     v_ssn || g_delimiter ||
			replace(nvl(p_first_name,''),',',' ')  || g_delimiter ||
                	replace(nvl(p_middle_name,''),',',' ') || g_delimiter ||
                	replace(p_last_name,',',' ') || g_delimiter ||
			replace(nvl(p_emp_address_line1,' '),',',' ') || g_delimiter ||
			replace(nvl(p_emp_address_line2,' '),',',' ') || g_delimiter ||
			replace(nvl(p_emp_city,' '),',',' ') || g_delimiter ||
			nvl(p_emp_state,' ') || g_delimiter ||
			nvl(p_emp_zip,' ') || g_delimiter ||
			nvl(p_emp_zip_extension,' ') || g_delimiter ||
			nvl(to_char(p_date_of_hire,'YYYYMMDD'),' ')	|| g_delimiter ||
			nvl(p_federal_id,' ') || g_delimiter ||
			replace(nvl(p_tax_unit_name,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_address_line1,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_address_line2,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_city,' '),',',' ') || g_delimiter ||
			nvl(p_loc_state,' ') || g_delimiter ||
			nvl(p_loc_zip,' ') || g_delimiter ||
			nvl(p_loc_zip_extension,' ') ||
                        g_eol;

  hr_utility.set_location('Leaving.... :' || l_api_name,100);

	return l_buffer;
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,200);
                raise;
end a03_il_new_hire_record;
--
--
/****************************************************************
 * This procedure formats a03 TX new hire audit report          *
 *                                                              *
 *                                                              *
 ****************************************************************/
function a03_tx_new_hire_header
return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.a03_tx_new_hire_header';
	l_buffer	varchar2(2000);
begin
  --
  hr_utility.set_location('Entering...: ' || l_api_name,10);
  l_buffer := 	upper(
		'Social Security Number' || g_delimiter ||
  	 	'First Name' || g_delimiter ||
		'Middle Name'  || g_delimiter ||
		'Last Name' || g_delimiter ||
		'Employee Address Line 1' || g_delimiter ||
		'Employee Address Line 2' || g_delimiter ||
		'Employee Address Line 3' || g_delimiter ||
		'Employee City' || g_delimiter ||
		'Employee State' || g_delimiter ||
		'Employee Zip' || g_delimiter ||
		'Employee Zip Extension' || g_delimiter ||
		'Employee Foreign Country Code' || g_delimiter ||
	--      'Employee Foreign Country Name' || g_delimiter ||
		'Employee Foreign Zip' || g_delimiter ||
		'Date of Birth' || g_delimiter ||
		'Date of Hire' || g_delimiter ||
		'State of Hire' || g_delimiter ||
		'FEIN' || g_delimiter ||
		'State EIN' || g_delimiter ||
		'Employer Name' || g_delimiter ||
		'Employer Address Line 1' || g_delimiter ||
		'Employer Address Line 2' 	 || g_delimiter ||
		'Employer Address Line 3' 	 || g_delimiter ||
		'Employer City' || g_delimiter ||
		'Employer State' || g_delimiter ||
		'Employer Zip' || g_delimiter ||
		'Employer Zip Extension' || g_delimiter ||
	--	'Employer Foreign Country Code' || g_delimiter ||
	--	'Employer Foreign Country Name' || g_delimiter ||
	--	'Employer Foreign Country Zip' ||
  		g_eol);

  hr_utility.set_location('Leaving.... :' || l_api_name,100);

	return l_buffer;
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,200);
                raise;
end a03_tx_new_hire_header;
--
/****************************************************************
 * This procedure formats a03 TX new hire audit report          *
 *                                                              *
 *                                                              *
 ****************************************************************/
function a03_tx_new_hire_record
(
 	 p_national_identifier   in  varchar2
 	,p_first_name            in  varchar2
 	,p_middle_name           in  varchar2
 	,p_last_name             in  varchar2
        ,p_emp_address_line1     in  varchar2
        ,p_emp_address_line2     in  varchar2
        ,p_emp_address_line3     in  varchar2
 	,p_emp_city              in  varchar2
 	,p_emp_state             in  varchar2
 	,p_emp_zip               in  varchar2
 	,p_emp_zip_extension     in  varchar2
 	,p_emp_country_code      in  varchar2
 	,p_emp_country_name      in  varchar2
 	,p_emp_country_zip       in  varchar2
 	,p_date_of_birth         in  date
 	,p_date_of_hire	         in  date
 	,p_state_of_hire         in  varchar2
        ,p_federal_id            in  varchar2
        ,p_state_ein             in  varchar2
        ,p_tax_unit_name         in  varchar2
        ,p_loc_address_line1     in  varchar2
        ,p_loc_address_line2     in  varchar2
        ,p_loc_address_line3     in  varchar2
        ,p_loc_city              in  varchar2
        ,p_loc_state             in  varchar2
 	,p_loc_zip               in  varchar2
 	,p_loc_zip_extension     in  varchar2
 	,p_loc_country_code      in  varchar2
 	,p_loc_country_name      in  varchar2
 	,p_loc_country_zip       in  varchar2
) return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.a03_tx_new_hire_record';
	l_buffer	varchar2(2000);
        v_ssn           varchar(9);
begin

  hr_utility.set_location('Entering...: ' || l_api_name,10);

  hr_utility.trace('p_federal_id=        ' || p_federal_id);
  hr_utility.trace('p_tax_unit_name=     ' || p_tax_unit_name);
  v_ssn := substr(p_national_identifier,1,3) || substr(p_national_identifier,5,2) || substr(p_national_identifier,8,4);

  hr_utility.trace('v_ssn=               ' || v_ssn);
  hr_utility.trace('p_first_name=        ' || p_first_name);
  hr_utility.trace('p_middle_name=       ' || p_middle_name);
  hr_utility.trace('p_last_name=         ' || p_last_name);
  hr_utility.trace('p_emp_address_line1= ' || p_emp_address_line1);
  hr_utility.trace('p_emp_address_line2= ' || p_emp_address_line2);
  hr_utility.trace('p_emp_address_line3= ' || p_emp_address_line2);
  hr_utility.trace('p_emp_city=          ' || p_emp_city);
  hr_utility.trace('p_emp_state=         ' || p_emp_state);
  hr_utility.trace('p_emp_zip=           ' || p_emp_zip);
  hr_utility.trace('p_emp_zip_extension= ' || p_emp_zip_extension);
  hr_utility.trace('p_date_of_birth=     ' || p_date_of_hire);
  hr_utility.trace('p_date_of_hire=      ' || p_date_of_hire);
  hr_utility.trace('p_state_of_hire=     ' || p_state_of_hire);

  hr_utility.set_location(l_api_name,30);

	--
	-- format new hire rocord
	--
	l_buffer :=     upper(
			v_ssn || g_delimiter ||
			replace(nvl(p_first_name,' '),',',' ')  || g_delimiter ||
                	replace(nvl(p_middle_name,' '),',',' ') || g_delimiter ||
                	replace(p_last_name,',',' ') || g_delimiter ||
			replace(nvl(p_emp_address_line1,' '),',',' ') || g_delimiter ||
			replace(nvl(p_emp_address_line2,' '),',',' ') || g_delimiter ||
			replace(nvl(p_emp_address_line3,' '),',',' ') || g_delimiter ||
			replace(nvl(p_emp_city,' '),',',' ') || g_delimiter ||
			nvl(p_emp_state,' ') || g_delimiter ||
			nvl(p_emp_zip,' ') || g_delimiter ||
			nvl(p_emp_zip_extension,' ') || g_delimiter ||
			nvl(p_emp_country_code,' ') || g_delimiter ||
	--		nvl(p_emp_country_name,' ') || g_delimiter ||
			nvl(p_emp_country_zip,' ') || g_delimiter ||
			-- nvl(to_char(p_date_of_birth,'YYYYMMDD'),' ')	|| g_delimiter ||   -- BUG3954955
			-- nvl(to_char(p_date_of_hire,'YYYYMMDD'),' ')	|| g_delimiter ||   -- BUG3954955
			nvl(to_char(p_date_of_birth,'MMDDYYYY'),' ')	|| g_delimiter ||   -- BUG 8515583
			nvl(to_char(p_date_of_hire,'MMDDYYYY'),' ')	|| g_delimiter ||   -- BUG 8515583
			nvl(p_state_of_hire,' ') || g_delimiter ||
			nvl(p_federal_id,' ') || g_delimiter ||
			nvl(p_state_ein,' ') || g_delimiter ||
			replace(nvl(p_tax_unit_name,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_address_line1,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_address_line2,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_address_line3,' '),',',' ') || g_delimiter ||
			replace(nvl(p_loc_city,' '),',',' ') || g_delimiter ||
			nvl(p_loc_state,' ') || g_delimiter ||
			nvl(p_loc_zip,' ') || g_delimiter ||
			nvl(p_loc_zip_extension,' ')  || g_delimiter ||
                        g_eol);

  hr_utility.set_location('Leaving.... :' || l_api_name,100);

	return l_buffer;
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,200);
                raise;
end a03_tx_new_hire_record;


/****************************************************************
 * This procedure formats a03 new hire CA audit report          *
 *                                                              *
 *                                                              *
 ****************************************************************/
function a03_ca_new_hire_header
return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.a03_ca_new_hire_header';
	l_buffer	varchar2(2000);
begin
  --
  hr_utility.set_location('Entering...: ' || l_api_name,10);
  l_buffer := 	'SOCIAL SECURITY NUMBER' || g_delimiter ||
              	'FIRST NAME' || g_delimiter ||
		'MIDDLE INITIAL'  || g_delimiter ||
		'LAST NAME' || g_delimiter ||
		'EMPLOYEE STREET ADDRESS' || g_delimiter ||
		'EMPLOYEE CITY' || g_delimiter ||
		'EMPLOYEE STATE' || g_delimiter ||
		'EMPLOYEE ZIP' || g_delimiter ||
		'EMPLOYEE ZIP EXTENSION' || g_delimiter ||
		'DATE OF HIRE' ||
  		g_eol;

  hr_utility.set_location('Leaving.... :' || l_api_name,100);

	return l_buffer;
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,200);
                raise;
end a03_ca_new_hire_header;
--
/****************************************************************
 * This procedure formats a03 CA new hire audit report          *
 *                                                              *
 *                                                              *
 ****************************************************************/
function a03_ca_new_hire_record
(
 	 p_national_identifier   in  varchar2
 	,p_first_name            in  varchar2
 	,p_middle_name           in  varchar2
 	,p_last_name             in  varchar2
        ,p_emp_address_line      in  varchar2
 	,p_emp_city              in  varchar2
 	,p_emp_state             in  varchar2
 	,p_emp_zip               in  varchar2
 	,p_emp_zip_extension     in  varchar2
 	,p_date_of_hire          in  date
) return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.a03_ca_new_hire_record';
	l_buffer	varchar2(2000);
        v_ssn           varchar(9);
begin

  hr_utility.set_location('Entering...: ' || l_api_name,10);

  v_ssn := substr(p_national_identifier,1,3) || substr(p_national_identifier,5,2) || substr(p_national_identifier,8,4);

  hr_utility.trace('v_ssn=               ' || v_ssn);
  hr_utility.trace('p_first_name=        ' || p_first_name);
  hr_utility.trace('p_middle_name=       ' || p_middle_name);
  hr_utility.trace('p_last_name=         ' || p_last_name);
  hr_utility.trace('p_emp_address_line = ' || p_emp_address_line);
  hr_utility.trace('p_emp_city=          ' || p_emp_city);
  hr_utility.trace('p_emp_state=         ' || p_emp_state);
  hr_utility.trace('p_emp_zip=           ' || p_emp_zip);
  hr_utility.trace('p_emp_zip_extension= ' || p_emp_zip_extension);
  hr_utility.trace('p_date_of_hire=     ' || p_date_of_hire);

  hr_utility.set_location(l_api_name,30);

	--
	-- format new hire rocord
	--
	l_buffer :=     upper(
			v_ssn || g_delimiter ||
                	replace(nvl(p_first_name,''),',',' ')  || g_delimiter ||
                	replace(nvl(substr(p_middle_name,1,1),''),',',' ') || g_delimiter ||
                	replace(p_last_name,',',' ') || g_delimiter ||
			replace(nvl(p_emp_address_line,' '),',',' ') || g_delimiter ||
			replace(nvl(p_emp_city,' '),',',' ') || g_delimiter ||
			nvl(p_emp_state,' ') || g_delimiter ||
			nvl(p_emp_zip,' ') || g_delimiter ||
			nvl(p_emp_zip_extension,' ') || g_delimiter ||
			nvl(to_char(p_date_of_hire,'YYYYMMDD'),' ') ||
                        g_eol
                        );

  hr_utility.set_location('Leaving.... :' || l_api_name,100);

	return l_buffer;
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,200);
                raise;
end a03_ca_new_hire_record;
--
/****************************************************************
 * This procedure formats a03 NY new hire audit report          *
 *                                                              *
 *                                                              *
 ****************************************************************/
function a03_ny_new_hire_header
return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.a03_ny_new_hire_header';
	l_buffer	varchar2(2000);
begin
  --
  hr_utility.set_location('Entering...: ' || l_api_name,10);
  l_buffer := 	upper(
		'Social Security Number' || g_delimiter ||
  		'Last Name' || g_delimiter ||
  		'First Name' || g_delimiter ||
  		'Middle Initial' || g_delimiter ||
		'Employee Street Address' || g_delimiter ||
		'Employee City' || g_delimiter ||
		'Employee State' || g_delimiter ||
		'Employee Zip' || g_delimiter ||
		'Hire Date' || g_delimiter ||
  		g_eol);

  hr_utility.set_location('Leaving.... :' || l_api_name,100);

	return l_buffer;
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,200);
                raise;
end a03_ny_new_hire_header;
--
/****************************************************************
 * This procedure formats a03 NY new hire audit report          *
 *                                                              *
 *                                                              *
 ****************************************************************/
function a03_ny_new_hire_record
(
 	 p_national_identifier   in  varchar2
 	,p_first_name            in  varchar2
 	,p_middle_name           in  varchar2
 	,p_last_name             in  varchar2
        ,p_emp_address_line      in  varchar2
 	,p_emp_city              in  varchar2
 	,p_emp_state             in  varchar2
 	,p_emp_zip               in  varchar2
 	,p_date_of_hire          in  date
) return varchar2
is
	l_api_name	varchar2(61) := g_package_name || '.a03_ny_new_hire_record';
	l_buffer	varchar2(2000);
        v_ssn           varchar(9);
begin

  hr_utility.set_location('Entering...: ' || l_api_name,10);

  v_ssn := substr(p_national_identifier,1,3) || substr(p_national_identifier,5,2) || substr(p_national_identifier,8,4);

  hr_utility.trace('v_ssn=               ' || v_ssn);
  hr_utility.trace('p_first_name=        ' || p_first_name);
  hr_utility.trace('p_middle_name=       ' || p_middle_name);
  hr_utility.trace('p_last_name=         ' || p_last_name);
  hr_utility.trace('p_emp_address_line = ' || p_emp_address_line);
  hr_utility.trace('p_emp_city=          ' || p_emp_city);
  hr_utility.trace('p_emp_state=         ' || p_emp_state);
  hr_utility.trace('p_emp_zip=           ' || p_emp_zip);
  hr_utility.trace('p_date_of_hire=      ' || p_date_of_hire);

  hr_utility.set_location(l_api_name,30);

	--
	-- format new hire rocord
	--
	l_buffer :=     upper(
			v_ssn || g_delimiter ||
                        replace(p_last_name,',',' ') || g_delimiter ||
                        replace(nvl(p_first_name,''),',',' ') || g_delimiter ||
                        replace(nvl(substr(p_middle_name,1,1),''),',',' ') || g_delimiter ||
			replace(nvl(p_emp_address_line,' '),',',' ') || g_delimiter ||
			replace(nvl(p_emp_city,' '),',',' ') || g_delimiter ||
			nvl(p_emp_state,' ') || g_delimiter ||
			nvl(p_emp_zip,' ') || g_delimiter ||
			nvl(to_char(p_date_of_hire,'MMDDYY'),' ') ||
                        g_eol);

  hr_utility.set_location('Leaving.... :' || l_api_name,100);

	return l_buffer;
  exception
	when others then
  		hr_utility.set_location('Leaving.... :' || l_api_name,200);
                raise;
end a03_ny_new_hire_record;
--

/****************************************************************
 * This procedure retrieves location address                    *
 *                                                              *
 *                                                              *
 ****************************************************************/
procedure get_location_address
(
     p_location_id   in number
    ,p_address       out nocopy varchar2
    ,p_city          out nocopy varchar2
    ,p_state         out nocopy varchar2
    ,p_zip           out nocopy varchar2
    ,p_zip_extension out nocopy varchar2
) IS
--
l_api_name	varchar2(61) := g_package_name || '.get_location_address';
f_address 	varchar2(300) := NULL;
f_city    	varchar2(48)  := NULL;
f_state   	varchar2(50)  := NULL;
f_zip     	varchar2(20)  := NULL;
f_zip_extension varchar2(4)   := NULL;
v_index         number(5);
--
v_address_line_1        hr_locations.address_line_1%TYPE;
v_address_line_2        hr_locations.address_line_2%TYPE;
v_address_line_3        hr_locations.address_line_3%TYPE;
v_town_or_city          hr_locations.town_or_city%TYPE;
v_region_2              hr_locations.region_2%TYPE;
v_region_1              hr_locations.region_1%TYPE;
v_style                 hr_locations.style%TYPE;
v_postal_code           hr_locations.postal_code%TYPE;
--
cursor get_location_record is
  select address_line_1, address_line_2, address_line_3,
         town_or_city, region_1, region_2, postal_code ,style
  from hr_locations
  where  location_id = p_location_id;
--
begin
--
hr_utility.set_location('Entering :' || l_api_name, 5);
hr_utility.trace('location_id is ' || to_char(p_location_id));
--
  open get_location_record;
--
  fetch get_location_record into v_address_line_1, v_address_line_2,
        v_address_line_3, v_town_or_city, v_region_1
        ,v_region_2, v_postal_code ,v_style;
--
  hr_utility.set_location(l_api_name, 10);
--
  if get_location_record%found
  then
--
    if v_address_line_1 is not null
    then
      f_address := v_address_line_1;
    end if;
--
    hr_utility.set_location(l_api_name, 11);
    if v_address_line_2 is not null
    then
      f_address := f_address || ' ' || v_address_line_2;
    end if;
--
    hr_utility.set_location(l_api_name, 12);
    if v_address_line_3 is not null
    then
       f_address := f_address || ' ' || v_address_line_3;
    end if;
   hr_utility.trace('street address is '|| f_address);
--
    hr_utility.set_location(l_api_name, 13);
    if v_town_or_city is not null
    then
       f_city:= rpad(v_town_or_city,48,' ');
    end if;
   hr_utility.trace('city is '|| f_city);
--
    if (v_style = 'US' or v_style = 'US_GLB') and v_region_2 is not null
    then
      f_state := v_region_2;
    elsif v_style = 'CA' and v_region_1 is not null then
      f_state := v_region_1;
    end if;
   hr_utility.trace('state is '|| f_state);
--
    if v_postal_code is not null
    then
      f_zip := v_postal_code;
      v_index := instr(v_postal_code,'-') ;
      if (v_index <> 0)
      then
        f_zip := substr(v_postal_code,1,5);
        f_zip_extension := substr(v_postal_code,v_index+1,4);
      else
        f_zip_extension := null;
      end if;
    end if;
   hr_utility.trace('postal code is '|| f_zip);
   hr_utility.trace('postal code extension is '|| f_zip_extension);


--
    close get_location_record;
--
	hr_utility.set_location(l_api_name, 20);

    p_address := f_address;
    p_city := f_city;
    p_state := f_state;
    p_zip := f_zip;
    p_zip_extension := f_zip_extension;
--
  end if;
--
  hr_utility.set_location('Leaving ..' || l_api_name, 100);

exception
        when others then
                hr_utility.trace('Error in ' || l_api_name);
                hr_utility.set_location(l_api_name, 30);
--
end get_location_address;
/****************************************************************
 * This procedure retrieves location address                    *
 * address_line1,address_line2,address_line3                    *
 *                                                              *
 ****************************************************************/
procedure get_location_address_3lines
(
     p_location_id   in number
    ,p_address_line1 out nocopy varchar2
    ,p_address_line2 out nocopy varchar2
    ,p_address_line3 out nocopy varchar2
    ,p_city          out nocopy varchar2
    ,p_state         out nocopy varchar2
    ,p_zip           out nocopy varchar2
    ,p_zip_extension out nocopy varchar2
    ,p_country       out nocopy varchar2
) IS
--
l_api_name	varchar2(61) := g_package_name || '.get_location_address_3lines';
f_address_line1	varchar2(300) := NULL;
f_address_line2	varchar2(300) := NULL;
f_address_line3	varchar2(300) := NULL;
f_city    	varchar2(48)  := NULL;
f_state   	varchar2(50)  := NULL;
f_zip     	varchar2(20)  := NULL;
f_zip_extension varchar2(4)   := NULL;
v_index         number(5);
--
v_address_line_1        hr_locations.address_line_1%TYPE;
v_address_line_2        hr_locations.address_line_2%TYPE;
v_address_line_3        hr_locations.address_line_3%TYPE;
v_town_or_city          hr_locations.town_or_city%TYPE;
v_region_2              hr_locations.region_2%TYPE;
v_region_1              hr_locations.region_1%TYPE;
v_postal_code           hr_locations.postal_code%TYPE;
v_country               hr_locations.country%TYPE;
v_style	                hr_locations.style%TYPE;
--
cursor get_location_record is
  select address_line_1, address_line_2, address_line_3,
         town_or_city, region_1, region_2, postal_code
         ,country,style
  from hr_locations
  where  location_id = p_location_id;
--
begin
--
hr_utility.set_location('Entering :' || l_api_name, 5);
hr_utility.trace('location_id is ' || to_char(p_location_id));
--
  open get_location_record;
--
  fetch get_location_record into v_address_line_1, v_address_line_2,
        v_address_line_3, v_town_or_city, v_region_1,v_region_2
        , v_postal_code ,v_country, v_style;
--
hr_utility.set_location(l_api_name, 10);
--
  if get_location_record%found
  then
--
    if v_address_line_1 is not null
    then
      f_address_line1 := v_address_line_1;
      hr_utility.trace('address_line1 is '|| f_address_line1);
    end if;
--
hr_utility.set_location(l_api_name, 11);
    if v_address_line_2 is not null
    then
      f_address_line2 := v_address_line_2;
      hr_utility.trace('address_line2 is '|| f_address_line2);
    end if;
--
hr_utility.set_location(l_api_name, 12);
    if v_address_line_3 is not null
    then
      f_address_line3 := v_address_line_3;
      hr_utility.trace('address_line3 is '|| f_address_line3);
    end if;
--
hr_utility.set_location(l_api_name, 13);
    if v_town_or_city is not null
    then
       f_city:= rpad(v_town_or_city,48,' ');
    end if;
   hr_utility.trace('city is '|| f_city);
--
    if (v_style = 'US' or v_style = 'US_GLB') and v_region_2 is not null
    then
      f_state := v_region_2;
    elsif v_style = 'CA' and v_region_1 is not null then
      f_state := v_region_1;
    end if;
   hr_utility.trace('state is '|| f_state);
--
    if v_country = 'US'
    then
      if v_postal_code is not null
      then
        f_zip := v_postal_code;
        v_index := instr(v_postal_code,'-') ;
        if (v_index <> 0)
        then
          f_zip := substr(v_postal_code,1,5);
          f_zip_extension := substr(v_postal_code,v_index+1,4);
        else
          f_zip_extension := null;
        end if;
      end if;
      p_country := '  ';
    else
      f_zip := v_postal_code;
      f_zip_extension := null;
    end if;
   hr_utility.trace('country code is '|| v_country);
   hr_utility.trace('postal code is '|| f_zip);
   hr_utility.trace('postal code extension is '|| f_zip_extension);


--
    close get_location_record;
--
	hr_utility.set_location(l_api_name, 20);

    p_address_line1 := f_address_line1;
    p_address_line2 := f_address_line2;
    p_address_line3 := f_address_line3;
    p_city := f_city;
    p_state := f_state;
    p_zip := f_zip;
    p_zip_extension := f_zip_extension;
    p_country := v_country;
--
  end if;
--
  hr_utility.set_location('Leaving ..' || l_api_name, 100);

exception
        when others then
                hr_utility.trace('Error in ' || l_api_name);
                hr_utility.set_location(l_api_name, 30);
--
end get_location_address_3lines;
--
/****************************************************************
 * This procedure retrieves employee address                    *
 *                                                              *
 *                                                              *
 ****************************************************************/
procedure get_employee_address
(
     p_person_id     in number
    ,p_address       out nocopy varchar2
    ,p_city          out nocopy varchar2
    ,p_state         out nocopy varchar2
    ,p_zip           out nocopy varchar2
    ,p_zip_extension out nocopy varchar2
) IS
--
l_api_name	varchar2(61) := g_package_name || '.get_employee_address';
f_address 	varchar2(300) := NULL;
f_city    	varchar2(48)  := NULL;
f_state   	varchar2(50)  := NULL;
f_zip    	varchar2(20)  := NULL;
f_zip_extension varchar2(4)   := NULL;
v_index         number(5);
--
-- address_record  per_addresses%rowtype;
--
v_address_line1		per_addresses.address_line1%TYPE;
v_address_line2		per_addresses.address_line2%TYPE;
v_address_line3		per_addresses.address_line3%TYPE;
v_town_or_city		per_addresses.town_or_city%TYPE;
v_region_2		per_addresses.region_2%TYPE;
v_region_1		per_addresses.region_1%TYPE;
v_postal_code		per_addresses.postal_code%TYPE;
v_country		per_addresses.country%TYPE;
v_style			per_addresses.style%TYPE;
--
cursor get_address_record is
  select address_line1, address_line2, address_line3,
	 town_or_city, region_1, region_2, postal_code
         ,style
  from 	 per_addresses
  where  person_id = p_person_id
  and 	 primary_flag = 'Y'
  and    nvl(date_to, sysdate) >= sysdate;
--
begin
--
hr_utility.set_location(l_api_name, 0);
--
  open get_address_record;
--
  fetch get_address_record into v_address_line1, v_address_line2,
	v_address_line3, v_town_or_city, v_region_1
        ,v_region_2, v_postal_code,v_style;
--
hr_utility.set_location(l_api_name, 5);
--
  if get_address_record%found
  then
--
    if v_address_line1 is not null
    then
      f_address := v_address_line1;
    end if;
--
    if v_address_line2 is not null
    then
      f_address := f_address || ' ' || v_address_line2;
    end if;
--
    if v_address_line3 is not null
    then
       f_address := f_address || ' ' || v_address_line3;
    end if;
--
   hr_utility.trace('Person Address is '|| f_address);

    if v_town_or_city is not null
    then
       f_city:= rpad(v_town_or_city,31,' ');
    end if;
   hr_utility.trace('city is '|| f_city);
--
    if (v_style = 'US' or v_style = 'US_GLB') and v_region_2 is not null
    then
      f_state := v_region_2;
    elsif v_style = 'CA' and v_region_1 is not null then
      f_state := v_region_1;
    end if;
   hr_utility.trace('state is '|| f_state);
--
    if v_postal_code is not null
    then
      f_zip := v_postal_code;
      v_index := instr(v_postal_code,'-') ;
      if (v_index <> 0)
      then
        f_zip := substr(v_postal_code,1,5);
        f_zip_extension := substr(v_postal_code,v_index+1,4);
      else
        f_zip_extension := null;
      end if;
    end if;
   hr_utility.trace('country code is '|| v_country);
   hr_utility.trace('postal code is '|| f_zip);
   hr_utility.trace('postal extension code is '|| f_zip_extension);

--
hr_utility.set_location(l_api_name, 10);
    close get_address_record;
--
--
    p_address := f_address;
    p_city := f_city;
    p_state := f_state;
    p_zip := f_zip;
    p_zip_extension := f_zip_extension;
--
  end if;
--
hr_utility.set_location('Leaving...:' || l_api_name, 50);
--
exception when NO_DATA_FOUND then NULL;
--
end get_employee_address;
--
/****************************************************************
 * This procedure retrieves employee address                    *
 * address_line1,address_line2,address_line3                    *
 *                                                              *
 ****************************************************************/
procedure get_employee_address_3lines
(
     p_person_id     in number
    ,p_address_line1 out nocopy varchar2
    ,p_address_line2 out nocopy varchar2
    ,p_address_line3 out nocopy varchar2
    ,p_city          out nocopy varchar2
    ,p_state         out nocopy varchar2
    ,p_zip           out nocopy varchar2
    ,p_zip_extension out nocopy varchar2
    ,p_country       out nocopy varchar2
) IS
--
l_api_name	varchar2(61) := g_package_name || '.get_employee_address_3lines';
f_address_line1	varchar2(300) := NULL;
f_address_line2	varchar2(300) := NULL;
f_address_line3	varchar2(300) := NULL;
f_city    	varchar2(48)  := NULL;
f_state   	varchar2(50)  := NULL;
f_zip    	varchar2(20)  := NULL;
f_zip_extension varchar2(4)   := NULL;
v_index         number(5);
--
-- address_record  per_addresses%rowtype;
--
v_address_line1		per_addresses.address_line1%TYPE;
v_address_line2		per_addresses.address_line2%TYPE;
v_address_line3		per_addresses.address_line3%TYPE;
v_town_or_city		per_addresses.town_or_city%TYPE;
v_region_2		per_addresses.region_2%TYPE;
v_region_1		per_addresses.region_1%TYPE;
v_postal_code		per_addresses.postal_code%TYPE;
v_country		per_addresses.country%TYPE;
v_style			per_addresses.style%TYPE;
--
cursor get_address_record is
  select address_line1, address_line2, address_line3,
	 town_or_city, region_1, region_2
         , postal_code ,country ,style
  from 	 per_addresses
  where  person_id = p_person_id
  and 	 primary_flag = 'Y'
  and    nvl(date_to, sysdate) >= sysdate;
--
begin
--
hr_utility.set_location(l_api_name, 0);
--
  open get_address_record;
--
  fetch get_address_record into v_address_line1, v_address_line2,
	v_address_line3, v_town_or_city, v_region_1,v_region_2
        , v_postal_code ,v_country,v_style;
--
hr_utility.set_location(l_api_name, 5);
--
  if get_address_record%found
  then
--
    if v_address_line1 is not null
    then
      f_address_line1 := v_address_line1;
      hr_utility.trace('address_line1 is '|| f_address_line1);
    end if;
--
    if v_address_line2 is not null
    then
      f_address_line2 := v_address_line2;
      hr_utility.trace('address_line2 is '|| f_address_line2);
    end if;
--
    if v_address_line3 is not null
    then
      f_address_line3 := v_address_line3;
      hr_utility.trace('address_line3 is '|| f_address_line3);
    end if;
--

    if v_town_or_city is not null
    then
       f_city:= rpad(v_town_or_city,31,' ');
    end if;
   hr_utility.trace('city is '|| f_city);
--
    if (v_style = 'US' or v_style = 'US_GLB') and v_region_2 is not null
    then
      f_state := v_region_2;
    elsif v_style = 'CA' and v_region_1 is not null then
      f_state := v_region_1;
    end if;
   hr_utility.trace('state is '|| f_state);
--
    if v_country = 'US'
    then
      if v_postal_code is not null
      then
        f_zip := v_postal_code;
        v_index := instr(v_postal_code,'-') ;
        if (v_index <> 0)
        then
          f_zip := substr(v_postal_code,1,5);
          f_zip_extension := substr(v_postal_code,v_index+1,4);
        else
          f_zip_extension := null;
        end if;
      end if;
      p_country := '  ';
    else
      f_zip := v_postal_code;
      f_zip_extension := null;
    end if;
   hr_utility.trace('country code is '|| v_country);
   hr_utility.trace('postal code is '|| f_zip);
   hr_utility.trace('postal extension code is '|| f_zip_extension);

--
hr_utility.set_location(l_api_name, 10);
    close get_address_record;
--
--
    p_address_line1 := f_address_line1;
    p_address_line2 := f_address_line2;
    p_address_line3 := f_address_line3;
    p_city := f_city;
    p_state := f_state;
    p_zip := f_zip;
    p_zip_extension := f_zip_extension;
    p_country := v_country;
--
  end if;
--
hr_utility.set_location('Leaving...:' || l_api_name, 50);
--
exception when NO_DATA_FOUND then NULL;
--
end get_employee_address_3lines;
--
--
/****************************************************************
 * This procedure retrieves employer contact                    *
 * name, title,phone                                            *
 *                                                              *
 ****************************************************************/
procedure get_new_hire_contact( p_person_id             in number,
                                p_business_group_id     in number,
                                p_report_date           in date,
                                p_contact_name          out nocopy varchar2,
                                p_contact_title         out nocopy varchar2,
                                p_contact_phone         out nocopy varchar2
                              ) IS
--
l_api_name		varchar2(61) := g_package_name || '.get_new_hire_contact';
v_contact_name          varchar2(240); --per_people_f.full_name%TYPE;
v_contact_title         varchar2(700); --per_jobs.name%TYPE;
v_contact_phone         varchar2(60); -- per_people_f.work_telephone%TYPE;

CURSOR c_new_hire_record IS
 Select  ppf.first_name || ' ' || ppf.last_name,
                 job.name,
                 ppf.work_telephone
         From
                 --per_people_f          ppf, --view bug 4912696
                  per_all_people_f       ppf,  --table
                 --per_assignments_f     paf, --view bug 4912696
                 per_all_assignments_f   paf, --table
                 per_jobs                job
         Where
                 ppf.person_id                   = p_person_id
         And     ppf.business_group_id + 0       = p_business_group_id
         And     p_report_date   between paf.effective_start_date
                                 and     paf.effective_end_date
         And     ppf.person_id                   = paf.person_id
         And     paf.assignment_type             = 'E'
         And     paf.primary_flag                = 'Y'
         And     p_report_date   between paf.effective_start_date
                                 and     paf.effective_end_date
         -- BUG2919553
         And     ppf.effective_start_date =
                      (select max(ppf1.effective_start_date)
                       from per_all_people_f ppf1  --table bug 4912696
                       where ppf1.person_id = ppf.person_id
                       and   ppf1.effective_start_date <= p_report_date
                      )
         -- End of BUG2919553
         And     paf.job_id      = job.job_id(+);

--
begin
--
hr_utility.set_location('Entering....:' || l_api_name,10);
--
OPEN c_new_hire_record;
--LOOP
        FETCH c_new_hire_record INTO v_contact_name, v_contact_title, v_contact_phone;
--
        p_contact_name  := substr(v_contact_name,1,60);
        p_contact_title := substr(v_contact_title,1,60);
        p_contact_phone := substr(v_contact_phone,1,60);
--
--      EXIT WHEN c_new_hire_record%NOTFOUND;
--END LOOP;

CLOSE c_new_hire_record;
--
hr_utility.trace('Contact name : '||v_contact_name);
hr_utility.trace('Contact title : '||v_contact_title);
hr_utility.set_location('Leaving....:' || l_api_name ,100);
--
exception
        when no_data_found then
                hr_utility.set_location('Error found in ' || l_api_name,20);
                NULL;
        when others then
                hr_utility.set_location('Error found in ' || l_api_name,30);
--
end get_new_hire_contact;
--
--
end per_new_hire_pkg;

/
