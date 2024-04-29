--------------------------------------------------------
--  DDL for Package PER_NEW_HIRE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_NEW_HIRE_PKG" AUTHID CURRENT_USER as
/* $Header: pernhire.pkh 120.1.12010000.2 2008/08/06 09:35:01 ubhat ship $ */

--
-- Changed to return converted characters because of Reports'
-- convert function bug.
-- When running Reports, user have to run in the environment
-- without character conversion, that is, nls_characterset
-- must always be the same as DB characterset.
-- But user do not have to care about this because Reports runs
-- by Concurrent Manager whose nls_characterset is always be the
-- same as DB characterset.
--
procedure char_set_init
(
	p_character_set		in varchar2
);

function ca_e4_record
(
        p_record_identifier     in  varchar2
       ,p_federal_id            in  varchar2
       ,p_sit_company_state_id	in  varchar2
       ,p_branch_code           in  varchar2
       ,p_tax_unit_name         in  varchar2
       ,p_street_address        in  varchar2
       ,p_city                  in  varchar2
       ,p_state                 in  varchar2
       ,p_zip                   in  varchar2
       ,p_zip_extension         in  varchar2 default null
) return varchar2;

function ca_w4_record
(
        p_record_identifier     in  varchar2
       ,p_national_identifier   in  varchar2
       ,p_first_name    	in  varchar2
       ,p_middle_name           in  varchar2
       ,p_last_name             in  varchar2
       ,p_street_address        in  varchar2
       ,p_city                  in  varchar2
       ,p_state                 in  varchar2
       ,p_zip                   in  varchar2
       ,p_zip_extension         in  varchar2 default null
       ,p_date_of_hire          in  date
) return varchar2;

function ca_t4_record
(
	p_record_identifier	in varchar2
	,p_number_of_employee	in number
) return varchar2;

function ny_1a_record
(
        p_record_identifier     in  varchar2
       ,p_creation_date		in  varchar2
       ,p_federal_id            in  varchar2
       ,p_tax_unit_name         in  varchar2
       ,p_street_address        in  varchar2
       ,p_city                  in  varchar2
       ,p_state                 in  varchar2
       ,p_zip                   in  varchar2
) return varchar2;

function ny_1e_record
(
        p_record_identifier     in  varchar2
       ,p_federal_id            in  varchar2
       ,p_tax_unit_name         in  varchar2
       ,p_street_address        in  varchar2
       ,p_city                  in  varchar2
       ,p_state                 in  varchar2
       ,p_zip                   in  varchar2
) return varchar2;

function ny_1h_record
(
        p_record_identifier     in  varchar2
       ,p_national_identifier   in  varchar2
       ,p_first_name    	in  varchar2
       ,p_middle_name           in  varchar2
       ,p_last_name             in  varchar2
       ,p_street_address        in  varchar2
       ,p_city                  in  varchar2
       ,p_state                 in  varchar2
       ,p_zip                   in  varchar2
       ,p_date_of_hire          in  date
) return varchar2;

function ny_1t_record
(
         p_record_identifier	in varchar2
	,p_number_of_employee	in number
) return varchar2;

function ny_1f_record
(
         p_record_identifier	in varchar2
	,p_number_of_employer	in number
) return varchar2;
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
) return varchar2;
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
) return varchar2;

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
) return varchar2;

function tx_t4_record
(
	p_record_identifier	in varchar2
       ,p_number_of_employee	in number
) return varchar2;

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
        ,p_emp_country_name      in  varchar2
        ,p_emp_country_zip       in  varchar2
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
        ,p_loc_country_name      in  varchar2
        ,p_loc_country_zip       in  varchar2
        ,p_opt_address_line1     in  varchar2
        ,p_opt_address_line2     in  varchar2
        ,p_opt_address_line3     in  varchar2
        ,p_opt_city              in  varchar2
        ,p_opt_state             in  varchar2
        ,p_opt_zip               in  varchar2
        ,p_opt_zip_extension     in  varchar2
	,p_opt_country_code      in  varchar2
        ,p_opt_country_name      in  varchar2
        ,p_opt_country_zip       in  varchar2
        ,p_salary                in  varchar2
        ,p_frequency             in  varchar2
) return varchar2;


function a03_ca_new_hire_header return varchar2;
function a03_il_new_hire_header return varchar2;
function a03_tx_new_hire_header return varchar2;
function a03_ny_new_hire_header return varchar2;
function a03_fl_new_hire_header return varchar2;
function a03_al_new_hire_header return varchar2;

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
) return varchar2;

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
        ,p_date_of_hire          in  date
        ,p_federal_id            in  varchar2
        ,p_tax_unit_name         in  varchar2
        ,p_loc_address_line1     in  varchar2
        ,p_loc_address_line2     in  varchar2
        ,p_loc_city              in  varchar2
        ,p_loc_state             in  varchar2
        ,p_loc_zip               in  varchar2
        ,p_loc_zip_extension     in  varchar2
) return varchar2;

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
        ,p_contact_phone         in  varchar2
        ,p_contact_phone_ext     in  varchar2
        ,p_contact_name          in  varchar2
        ,p_multi_state           in  varchar2
) return varchar2;
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
        ,p_contact_phone         in  varchar2
        ,p_contact_phone_ext     in  varchar2
        ,p_contact_name          in  varchar2
        ,p_multi_state           in  varchar2
) return varchar2;

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
        ,p_loc_country_name      in  varchar2
        ,p_loc_country_zip       in  varchar2
) return varchar2;

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
) return varchar2;

PROCEDURE get_location_address
(
	p_location_id   in number
       ,p_address       out nocopy varchar2
       ,p_city          out nocopy varchar2
       ,p_state         out nocopy varchar2
       ,p_zip           out nocopy varchar2
       ,p_zip_extension out nocopy varchar2
);

PROCEDURE get_location_address_3lines
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
);

PROCEDURE get_employee_address
(
	p_person_id  	in number
       ,p_address       out nocopy varchar2
       ,p_city          out nocopy varchar2
       ,p_state         out nocopy varchar2
       ,p_zip           out nocopy varchar2
       ,p_zip_extension out nocopy varchar2
);

PROCEDURE get_employee_address_3lines
(
	p_person_id  	in number
       ,p_address_line1 out nocopy varchar2
       ,p_address_line2 out nocopy varchar2
       ,p_address_line3 out nocopy varchar2
       ,p_city          out nocopy varchar2
       ,p_state         out nocopy varchar2
       ,p_zip           out nocopy varchar2
       ,p_zip_extension out nocopy varchar2
       ,p_country 	out nocopy varchar2
);
--
procedure get_new_hire_contact(
	p_person_id             in number
       ,p_business_group_id     in number
       ,p_report_date           in date
       ,p_contact_name          out nocopy varchar2
       ,p_contact_title         out nocopy varchar2
       ,p_contact_phone         out nocopy varchar2
) ;
end per_new_hire_pkg;

/
