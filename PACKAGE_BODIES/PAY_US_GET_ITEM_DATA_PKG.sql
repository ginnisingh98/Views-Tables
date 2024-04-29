--------------------------------------------------------
--  DDL for Package Body PAY_US_GET_ITEM_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_GET_ITEM_DATA_PKG" AS
/* $Header: pyusgitd.pkb 120.3.12010000.3 2010/03/19 14:32:54 emunisek ship $  */

 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+

  Name
    pay_us_get_item_data_pkg

  Purpose
    The purpose of this package is to derive data and Validate data to support
    the generation of magnetic tape W2 / SQWL reports for US legilsative
    requirements.

    This mainly derives following data for W2 / SQWL
            Contact Person Information
            Employer Address
            Employee Address
            Contact Person Address

   Notes
    Referenced By:  Package  pay_us_reporting_utils_pkg

   Notes

   History
   14-Jul-03  ppanda      115.0                Created
   11-Sep-03  ppanda      115.2                A new column added to record structure person_name_address
                                                  This change is the result of YE report requirements for
                                                  country short name
                                   3137594     An error message was being printed on W2 Register which was
                                                  misleading for multiple primary address for a person
                                                  Refer bug description for details
   29-Sep-03  ppanda      115.3                A change made in GET_PERSON_NAME_ADDRESS function
                                               For MMREF while fetching a persons Address it was erroring
                                                   due to multiple address when person is terminated and
                                                   address changed after termination
   10-Nov-03  ppanda      115.4    2587381     W2C addded to the report type
   26-DEC-03  jgoswami    115.7                modified the cursors for person_address
                                               which return more than one address found.
                                               added assignment_type = 'E' condition in
                                               where clause, i.e. assignment is of type Employee
   29-DEC-03  jgoswami    115.8    3341291     modified the cursors for address which was
                                               missing fnd_territories in sql and joining
                                               directly to fnd_territories_tl. added where condition
                                               for checking user language.
   05-JAN-04  ppanda      115.10   3141296     When Country code is not for the address code assumes its a US
                                               address to set the per_addresses.region_2 as the state for
                                               the employee address

   03-NOV-04  asasthan   115.11   2694998   Formatting of contact name.
   03-NOV-04  asasthan   115.13   2694998   Removed more characters
   18-aug-06  kvsankar   115.14   4939049   Modified the following cursors to
                                            retrieve the country code from the
                                            lookup 'PQP_US_COUNTRY_TRANSLATE'
                                             * get_mmref_name_address
                                             * get_mmref_name_address_eod
                                             * get_report_name_address
                                             * get_report_name_address_eod
   23-AUG-06  sausingh   115.14   4939049  Modified the following cursors to
					   retrieve the country code from the
					   lookup 'PQP_US_COUNTRY_TRANSLATE'
					   or TABLE HR_LOCATIONS_ALL depending on condition
					   * get_organization_name_address
   21-Sep-06  ppanda     115.15            Following cursors were opened but not closed.
                                             * get_mmref_name_address_eod
                                             * get_report_name_address_eod
                                           These open cusrors were causing problem in Federal W-2 Magnetic
                                           media to fail with Too many Cursors opened
   07-DEC-07 vmkulkar    115.16   6644795  Updated get_contact_person_info to capture Title
				  6648007  using 'CS_PERSON'.
   05-Mar-10 emunisek    115.17   9356178  Made changes to call overloaded function format_mmref_address
                                           of Package pay_us_mmrf_w2_format_record from function GET_MMREF_EMPLOYER_ADDRESS
					   to accommodate the Florida SQWL Requirement for PhoneNumber
******************************************************************************/
 -- Global Variable
    g_number	NUMBER;
    l_return    varchar2(100);
    end_date    date := to_date('31/12/4712','DD/MM/YYYY');



/*   --------------------------------------------------------------
Name       : GET_CONTACT_PERSON_INFO
Purpose    : Purpose of this function is to get contact person details
                 required for Submitter Record
Parameters :
             p_effective_date -
                 This parameter indicates the year for the function.
             p_item_name   -  'CR_PERSON'
                identifies Contact Persons details in the Submitter record.
             p_report_type - This parameter will have the type of the report.
                               eg: 'W2' or 'SQWL'
             p_format -    This parameter will have the format to be printed
                          on W2. eg:'MMREF'
             p_record_name -  This parameter will have the particular
                              record name. eg: RA,RF,RE,RT etc.
             p_validate - This parameter will check whether it wants to
                          validate the error condition or override the checking.
                                'N'- Override
                                'Y'- Check
             p_exclude_from_output - This parameter gives the information on
                          whether the record has to be printed or not.
                              'Y'- Do not print.
                              'N'- Print.
             p_person_id                IN  person_id of Contact Person
             p_contact_prsn_name        OUT Contact Person Name          --out_1
             p_contact_prsn_phone       OUT Contact Person Phone         --out_2
             p_contact_prsn_extension   OUT Contact Person Extension     --out_3
             p_contact_prsn_email       OUT Contact Person Email         --out_4
             p_contact_prsn_fax         OUT Contact Person Fax           --out_5
             p_contact_prsn_first_name  OUT Contact Person First  Name   --out_6
             p_contact_prsn_middle_name OUT Contact Person Middle Name   --out_7
             p_contact_prsn_last_name   OUT Contact Person Last   Name   --out_8

   Error checking

   Special Note  :
----------------------------------------------------------------   */
FUNCTION GET_CONTACT_PERSON_INFO(
                   p_assignment_id            IN  number,
                   p_date_earned              IN  date,
                   p_tax_unit_id              IN  number,
                   p_effective_date           IN  varchar2,
                   p_item_name                IN  varchar2,
                   p_report_type              IN  varchar2,
                   p_format                   IN  varchar2,
                   p_report_qualifier         IN  varchar2,
                   p_record_name              IN  varchar2,
                   p_person_id                IN  varchar2,
                   p_validate                 IN  varchar2,
                   p_exclude_from_output      OUT nocopy varchar2,
                   p_contact_prsn_name        OUT nocopy varchar2,
                   p_contact_prsn_phone       OUT nocopy varchar2,
                   p_contact_prsn_extension   OUT nocopy varchar2,
                   p_contact_prsn_email       OUT nocopy varchar2,
                   p_contact_prsn_fax         OUT nocopy varchar2,
                   p_contact_prsn_first_name  OUT nocopy varchar2,
                   p_contact_prsn_middle_name OUT nocopy varchar2,
                   p_contact_prsn_last_name   OUT nocopy varchar2
                    ) RETURN VARCHAR2  IS

-- Cursor to fetch Contact person Name and Email Address
--
CURSOR get_person_infm(c_person_id   per_all_people_f.person_id%TYPE,
                       c_date_earned date)
IS
SELECT ppf.first_name ||' '||ppf.middle_names||' '||ppf.last_name,
       ppf.email_address,
       ppf.first_name,
       ppf.middle_names,
       ppf.last_name,
       ppf.title
FROM   per_all_people_f ppf
WHERE  ppf.person_id = c_person_id
AND    c_date_earned BETWEEN ppf.effective_start_date
                     AND ppf.effective_end_date;

-- Cursor to fetch Contact person Phone and Fax #
--
CURSOR get_phone_fax(c_person_id per_all_people_f.person_id%TYPE,
                     c_date      date)
IS
SELECT phone_number,
       phone_type
FROM   per_phones
WHERE  parent_id = c_person_id
AND    c_date BETWEEN date_from
              AND nvl(date_to,end_Date)
AND    parent_table = 'PER_ALL_PEOPLE_F';

c_item_name     varchar2(100);
l_valid_address boolean;
l_person_id     varchar2(50);
l_full_name     per_all_people_f.full_name%TYPE     := '';
l_first_name    per_all_people_f.first_name%TYPE    := '';
l_middle_name   per_all_people_f.middle_names%TYPE  := '';
l_last_name     per_all_people_f.last_name%TYPE     := '';
l_phone         per_phones.phone_number%TYPE        := '';
l_extension     varchar2(5)                         := '';
l_phone_type    per_phones.phone_type%TYPE          := '';
l_fax           per_phones.phone_number%TYPE        := '';
l_email         per_all_people_f.email_address%TYPE := '';
l_title         per_all_people_f.title%TYPE         := '';

BEGIN

   IF p_item_name = 'CS_PERSON' THEN
	c_item_name := 'CS_PERSON';
   ELSE
	c_item_name := 'CR_PERSON';
   END IF;

   l_valid_address:=FALSE;
   hr_utility.trace('Fetching Contact Person Information CR_PERSON');
   l_person_id:=replace(p_person_id,' ');
   OPEN get_person_infm(to_number(l_person_id),
                        p_date_earned);

   FETCH get_person_infm INTO l_full_name,
                              l_email,
                              l_first_name,
                              l_middle_name,
                              l_last_name,
			      l_title;

   IF get_person_infm%NOTFOUND THEN
--{
      p_contact_prsn_name      :=l_full_name;
      p_contact_prsn_phone     :=l_phone;
      p_contact_prsn_extension :=l_extension;
      p_contact_prsn_email     :=l_email;
      hr_utility.trace('Contact person information not found');
--}
   ELSIF get_person_infm%FOUND THEN
--{
      p_contact_prsn_name        := l_full_name;
      p_contact_prsn_email       := l_email;
      p_contact_prsn_first_name  := l_first_name;
      p_contact_prsn_middle_name := l_middle_name;
      p_contact_prsn_last_name   := l_last_name;

      l_title := trim(replace(l_title,'.'));

--
-- Fetching Contact Person Phone and Fax
--
      OPEN get_phone_fax(to_number(l_person_id),
                         p_date_earned);
      LOOP
         FETCH get_phone_fax INTO l_phone,
                                  l_phone_type;
         EXIT WHEN get_phone_fax%NOTFOUND;

         IF l_phone_type = 'W1' THEN     -- Work Phone
            p_contact_prsn_phone :=
              replace(pay_us_reporting_utils_pkg.Character_check(l_phone),'-');
            hr_utility.trace('Contact person PHONE Found.'||p_contact_prsn_phone);
         ELSIF l_phone_type = 'WF' THEN  -- Work Fax
            p_contact_prsn_fax :=
              replace(pay_us_reporting_utils_pkg.Character_check(l_phone),'-');
            hr_utility.trace('Contact Person Fax found.'||p_contact_prsn_fax);
         END IF;

      END LOOP; /* get_phone_fax */
      CLOSE get_phone_fax;
      p_contact_prsn_phone :=
        replace(replace(replace
               (replace(replace(replace(replace(replace
                (upper(p_contact_prsn_phone),
                 'E'),'X'),'T'),' '),'.'),'('),')'),'-');
      p_contact_prsn_extension :=
        rpad(nvl(substr(p_contact_prsn_phone,11,5),' '),5);  --Extension
      p_contact_prsn_phone :=
        rpad(substr(nvl(p_contact_prsn_phone,' '),1,10),15); --Phone number
      hr_utility.trace('Contact person PHONE Extension '||p_contact_prsn_extension);
--}
      IF c_item_name <> 'CS_PERSON' THEN   -- For title

      IF p_report_type IN ( 'W2', 'W2C') THEN
--{
--
-- This procedure formats contact information fields specific to W2 reporting
--
         hr_utility.trace('Formatting Contact Person Info for W2 reporting ');
         pay_us_mmrf_w2_format_record.format_w2_contact_prsn_info(
                                         p_report_qualifier,
                                         p_record_name,
                                         p_validate,
                                         p_exclude_from_output,
                                         p_contact_prsn_name,
                                         p_contact_prsn_phone,
                                         p_contact_prsn_extension,
                                         p_contact_prsn_email,
                                         p_contact_prsn_fax,
                                         p_contact_prsn_first_name,
                                         p_contact_prsn_middle_name,
                                         p_contact_prsn_last_name
                                        );
--}
         hr_utility.trace('Contact Person info formatted for W2 reporting ');
      ELSIF p_report_type = 'SQWL' THEN
--{
--
-- This procedure formats contact information fields specific to SQWL reporting
--
         hr_utility.trace('Formatting Contact Person Info for SQWL reporting ');
         pay_us_mmrf_sqwl_format_record.format_sqwl_contact_prsn_info(
                                         p_report_qualifier,
                                         p_record_name,
                                         p_validate,
                                         p_exclude_from_output,
                                         p_contact_prsn_name,
                                         p_contact_prsn_phone,
                                         p_contact_prsn_extension,
                                         p_contact_prsn_email,
                                         p_contact_prsn_fax,
                                         p_contact_prsn_first_name,
                                         p_contact_prsn_middle_name,
                                         p_contact_prsn_last_name
                                        );
--}
      END IF;

     ELSE       -- For title

	p_contact_prsn_email := l_title;  -- Only for Mary Land State W2 RV Record

	/* vmkulkar - Contact person Title should we displayed in the MD RV Record.
	So using p_contact_prsn_email(out4) for passing TITLE back to the formula.
	ITEM NAME used is 'CS_PERSON'  */

     END IF;  -- For title

      hr_utility.trace('Contact Person Information found. Full Name = '
                         ||p_contact_prsn_name);
   END IF;   --get_person_infm%NOTFOUND
   CLOSE get_person_infm;
   return p_contact_prsn_name;
 END GET_CONTACT_PERSON_INFO;
--
-- End of Function that derives Contact Person Information
--

--
-- Function to Get Employee Address
--
/*
    Parameters :
               p_effective_date -
                           This parameter indicates the year for the function.
               p_item_name   -  'EE_ADDRESS'
                                identifies Employee Address required for
                                Employee record.
               p_report_type - This parameter will have the type of the report.
                               eg: 'W2' or 'SQWL'
               p_format -    This parameter will have the format to be printed
                          on W2. eg:'MMREF'
               p_record_name - This parameter will have the particular
                               record name. eg: RE
               p_validate - This parameter will check whether it wants to
                            validate the error condition or override the
                            checking.
                                'N'- Override
                                'Y'- Check
               p_exclude_from_output -
                           This parameter gives the information on
                           whether the record has to be printed or not.
                           'Y'- Do not print.
                           'N'- Print.
              p_input_2 - Application Session Date this would be used to
                          fetch the address
              sp_out_1 -  This out parameter returns Employee Location Address
              sp_out_2 -  This out parameter returns Employee Deliver Address
              sp_out_3 -  This out parameter returns Employee City
              sp_out_4 -  This out parameter returns State
              sp_out_5 -  This out parameter returns Zip Code
              sp_out_6 -  This out parameter returns Zip Code Extension
              sp_out_7 -  This out parameter returns Foreign State/Province
              sp_out_8 -  This out parameter returns Foreign Postal Code
              sp_out_9 -  This out parameter returns Foreign Country Code
              sp_out_10 - This parameter is returns  Employee Number
*/
FUNCTION GET_MMREF_EMPLOYEE_ADDRESS(
                   p_assignment_id        IN  number,
                   p_date_earned          IN  date,
                   p_tax_unit_id          IN  number,
                   p_effective_date       IN  varchar2,
                   p_item_name            IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_input_1              IN  varchar2,
                   p_input_2              IN  varchar2,
                   p_input_3              IN  varchar2,
                   p_input_4              IN  varchar2,
                   p_input_5              IN  varchar2,
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   sp_out_6               OUT nocopy varchar2,
                   sp_out_7               OUT nocopy varchar2,
                   sp_out_8               OUT nocopy varchar2,
                   sp_out_9               OUT nocopy varchar2,
                   sp_out_10              OUT nocopy varchar2
                                   ) RETURN VARCHAR2 IS
-- Local Variable Declaration
--

c_item_name           varchar2(40);
c_tax_unit_id         hr_all_organization_units.organization_id%TYPE;
l_organization_name   hr_organization_units.name%TYPE;
l_person_id           number(10);
l_locality_company_id varchar2(50);
lr_employee_addr      pay_us_get_item_data_pkg.person_name_address;
l_effective_date      date;
l_input_2             varchar2(200);
BEGIN
   hr_utility.trace('In function GET_MMREF_EMPLOYEE_ADDRESS');
   c_item_name:='EE_ADDRESS';
--
-- This change is made for Mag W-2 reporting purpose
-- For W2, SQWL and 1099R Mag was not reporting address change beyond
-- period end date. This change of effective date is intended to fix
-- the address issue
--
   l_input_2 := ltrim(rtrim(p_input_2));
   if l_input_2 is not null then
      l_effective_date := fnd_date.canonical_TO_DATE(l_input_2);
   else
      l_effective_date := p_effective_date;
   end if;
   hr_utility.trace('In function GET_MMREF_EMPLOYEE_ADDRESS');
--
   lr_employee_addr :=
      pay_us_get_item_data_pkg.GET_PERSON_NAME_ADDRESS(
                            p_report_type,
                            l_person_id,
                            p_assignment_id,
                            p_date_earned,
                            l_effective_date,
                            p_validate,
                            p_record_name);
   hr_utility.trace('Employee '||lr_employee_addr.full_name ||' Info found ');
   hr_utility.trace('Formatting Employee Address for '||p_report_type
                               ||' Reporting ');
--
-- Format Employee Address for W2 / SQWL
--
   pay_us_mmrf_w2_format_record.format_mmref_address (
                   lr_employee_addr.full_name,
                   l_locality_company_id,
                   lr_employee_addr.employee_number,
                   lr_employee_addr.addr_line_1,
                   lr_employee_addr.addr_line_2,
                   lr_employee_addr.addr_line_3,
                   lr_employee_addr.city,
                   lr_employee_addr.province_state,
                   lr_employee_addr.postal_code,
                   lr_employee_addr.country,
                   lr_employee_addr.region_1,
                   lr_employee_addr.region_2,
                   lr_employee_addr.valid_address,
                   p_item_name,
                   p_report_type,
                   p_record_name,
                   p_validate,
                   p_input_1,
                   p_exclude_from_output,
                   sp_out_1,
                   sp_out_2,
                   sp_out_3,
                   sp_out_4,
                   sp_out_5,
                   sp_out_6,
                   sp_out_7,
                   sp_out_8,
                   sp_out_9,
                   sp_out_10
                   );
   RETURN sp_out_1;
END GET_MMREF_EMPLOYEE_ADDRESS;
-- End of function to fetch Employee Address used for W2/SQWL reporting
--

--
-- Function GET_ER_ADDRESS  to Get Employer Address
--
/*
    Parameters :
               p_effective_date -
                           This parameter indicates the year for the function.
               p_item_name   -  'ER_ADDRESS'
                                identifies Employee Address required for
                                Employee record.
               p_report_type - This parameter will have the type of the report.
                               eg: 'W2' or 'SQWL'
               p_format -    This parameter will have the format to be printed
                          on W2. eg:'MMREF'
               p_record_name - This parameter will have the particular
                               record name. eg: RE
               p_validate - This parameter will check whether it wants to
                            validate the error condition or override the
                            checking.
                                'N'- Override
                                'Y'- Check
               p_exclude_from_output -
                           This parameter gives the information on
                           whether the record has to be printed or not.
                           'Y'- Do not print.
                           'N'- Print.
              sp_out_1 -  This out parameter returns Employer Location Address
              sp_out_2 -  This out parameter returns Employer Deliver Address
              sp_out_3 -  This out parameter returns Employer City
              sp_out_4 -  This out parameter returns State
              sp_out_5 -  This out parameter returns Zip Code
              sp_out_6 -  This out parameter returns Zip Code Extension
              sp_out_7 -  This out parameter returns Foreign State/Province
              sp_out_8 -  This out parameter returns Locality Company ID
                             (Currently only Philadelphia Local W2 uses this)
              sp_out_9 -  This out parameter returns Foreign Country Code
              sp_out_10 - This parameter is returns  Organization Name
*/
FUNCTION GET_MMREF_EMPLOYER_ADDRESS (
                   p_assignment_id        IN  number,
                   p_date_earned          IN  date,
                   p_tax_unit_id          IN  number,
                   p_effective_date       IN  varchar2,
                   p_item_name            IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_input_1              IN  varchar2,
                   p_input_2              IN  varchar2,
                   p_input_3              IN  varchar2,
                   p_input_4              IN  varchar2,
                   p_input_5              IN  varchar2,
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   sp_out_6               OUT nocopy varchar2,
                   sp_out_7               OUT nocopy varchar2,
                   sp_out_8               OUT nocopy varchar2,
                   sp_out_9               OUT nocopy varchar2,
                   sp_out_10              OUT nocopy varchar2
                    ) RETURN VARCHAR2  IS

/* Philadelphi Locality Company Id */
CURSOR get_locality_company_id(c_tax_unit_id hr_organization_units.organization_id%type)
IS
select org_information2
from  hr_organization_information hoi
        WHERE hoi.organization_id = c_tax_unit_id
          and hoi.org_information_context = 'Local Tax Rules'
          AND hoi.org_information1 = '39-101-3000';

c_tax_unit_id   hr_all_organization_units.organization_id%TYPE;
c_item_name     varchar2(40);
l_emp_number    varchar2(40);
l_locality_company_id varchar2(50);
lr_employer_addr pay_us_get_item_data_pkg.organization_name_address;
BEGIN
   hr_utility.trace('FUNCTION GET_MMREF_EMPLOYER_ADDRESS for Employer Address');
   c_tax_unit_id := p_tax_unit_id;
   c_item_name   := 'ER_ADDRESS';

   hr_utility.trace('Tax Unit Id  = '||to_char(c_tax_unit_id));
   /* This would be used for Philadelphia locality only
      subsequently this can be enhanced to generalise for any locality */

   IF p_input_1 = 'PHILA' THEN
      hr_utility.trace('Fetch Locality_Company_Id ...');
      OPEN get_locality_company_id(c_tax_unit_id);
      FETCH get_locality_company_id INTO l_locality_company_id;
      CLOSE get_locality_company_id ;
      hr_utility.trace('ER_ADDRESS Locality_Company_Id ...'||
                        l_locality_company_id );
   END IF;
   lr_employer_addr :=
      pay_us_get_item_data_pkg.get_organization_name_address(
                                   c_tax_unit_id,
                                   p_effective_date,
                                   p_validate,
                                   p_record_name);
--
-- Format Employere Address for W2/SQWL reporting
--
-- For the case of FL SQWL, phone number is required,so calling an overloaded function
-- Changes made for Bug9356178

if (p_item_name='ER_ADDRESS' and p_report_type='SQWL' and p_format='MMREF'
    and p_report_qualifier='FL_SQWL' and p_record_name='RE')
then

 pay_us_mmrf_w2_format_record.format_mmref_address (
                   lr_employer_addr.org_name,
                   l_locality_company_id,
                   l_emp_number,
                   lr_employer_addr.addr_line_1,
                   lr_employer_addr.addr_line_2,
                   lr_employer_addr.addr_line_3,
                   lr_employer_addr.city,
                   lr_employer_addr.province_state,
                   lr_employer_addr.postal_code,
                   lr_employer_addr.country,
                   lr_employer_addr.region_1,
                   lr_employer_addr.region_2,
                   lr_employer_addr.phone_number,
                   lr_employer_addr.valid_address,
                   p_item_name,
                   p_report_type,
                   p_record_name,
                   p_validate,
                   p_input_1,
                   p_exclude_from_output,
                   sp_out_1,
                   sp_out_2,
                   sp_out_3,
                   sp_out_4,
                   sp_out_5,
                   sp_out_6,
                   sp_out_7,
                   sp_out_8,
                   sp_out_9,
                   sp_out_10
                   );

else

   pay_us_mmrf_w2_format_record.format_mmref_address (
                   lr_employer_addr.org_name,
                   l_locality_company_id,
                   l_emp_number,
                   lr_employer_addr.addr_line_1,
                   lr_employer_addr.addr_line_2,
                   lr_employer_addr.addr_line_3,
                   lr_employer_addr.city,
                   lr_employer_addr.province_state,
                   lr_employer_addr.postal_code,
                   lr_employer_addr.country,
                   lr_employer_addr.region_1,
                   lr_employer_addr.region_2,
                   lr_employer_addr.valid_address,
                   p_item_name,
                   p_report_type,
                   p_record_name,
                   p_validate,
                   p_input_1,
                   p_exclude_from_output,
                   sp_out_1,
                   sp_out_2,
                   sp_out_3,
                   sp_out_4,
                   sp_out_5,
                   sp_out_6,
                   sp_out_7,
                   sp_out_8,
                   sp_out_9,
                   sp_out_10
                   );

end if;

   RETURN sp_out_1;
END  GET_MMREF_EMPLOYER_ADDRESS;
--End of Function to fetch Employer Addres used by W2/SQWL
--

--
-- This function used to fetch Person Name and Address
-- For MMREF Assignment_id  and Effective_Date/Date Earn are Input
-- For all other reporting need Person_id and Effective date are Input
--                     Parameter Description
-- p_report_type       (i.e. MMREF, REPORT)
-- p_person_id         Person Id
-- p_assignment_id     Assignment_id
-- p_period_end_date   For W2 report/MMREF this would be the  End of Year Date
--                     For SQWL this would be end of Quater Date
--                     For other reports this would be address effective date
-- p_effective_date    Session effective Date for processing reports
-- p_validate          Flag for Validation to be performed or skipped
-- p_source_type       For MMREF purpose this would be the value of Mag Record
--                            (i.e. RA, RE, RW, RS etc.)
--                     For other Report this would be 'REPORT'


FUNCTION GET_PERSON_NAME_ADDRESS(
                   p_report_type          IN  varchar2,
                   p_person_id            IN  number,
                   p_assignment_id        IN  number,
                   p_period_end_date      IN  date,
                   p_effective_date       IN  date,
                   p_validate             IN  varchar2,
                   p_source_type          IN  varchar2)
             RETURN person_name_address
AS

lr_person_name_address person_name_address;

--
-- This cursor would be used for W2, SQWL and 1099R mag
--
CURSOR get_mmref_person_name
           (c_assignment_id  per_all_assignments_f.assignment_id%type,
            c_effective_date date)
IS
SELECT  ppf.full_name       ,
        ppf.employee_number
from   per_all_assignments_f  assign
,      per_all_people_f       ppf
where  ASSIGN.assignment_id   = c_assignment_id
and    c_effective_date BETWEEN ASSIGN.effective_start_date
                            AND ASSIGN.effective_end_date
and    assign.person_id       = ppf.person_id
and    assign.assignment_type = 'E'
and    c_effective_date BETWEEN ppf.effective_start_date
                            AND ppf.effective_end_date;

--
-- This cursor would be used for W2, SQWL, 1099R mag
--
CURSOR get_mmref_name_address
           (c_assignment_id  per_all_assignments_f.assignment_id%type,
            c_effective_date date)
IS
SELECT  ppf.full_name       ,
        ppf.employee_number ,
        addr.address_line1  ,
        addr.address_line2  ,
        addr.address_line3  ,
        addr.town_or_city   ,
        decode(NVL(addr.country,'US'), 'CA', addr.region_1,
                                       'US', addr.region_2, addr.region_1 )
                                       Province_or_state,
        addr.postal_code    ,
        substr(hrt.meaning,-2),
        fttl.territory_short_name,
        addr.region_1       ,
        addr.region_2       ,
        'Y'  valid_address
from   per_all_assignments_f  assign
,      per_addresses          addr
,      per_all_people_f       ppf
,      fnd_territories_tl     fttl
,      fnd_territories        ftt
,      hr_lookups             hrt
where  ASSIGN.assignment_id   = c_assignment_id
and    c_effective_date BETWEEN ASSIGN.effective_start_date
                            AND ASSIGN.effective_end_date
and    assign.person_id       = ppf.person_id
and    assign.assignment_type = 'E'
and    c_effective_date BETWEEN ppf.effective_start_date
                            AND ppf.effective_end_date
and    addr.person_id         = ASSIGN.person_id
and    addr.primary_flag      = 'Y'
and    NVL(addr.country,'US') = ftt.territory_code
and    ftt.territory_code     = fttl.territory_code
and    fttl.language          = USERENV('LANG')
and    hrt.lookup_code        = ftt.territory_code
and    hrt.lookup_type        = 'PQP_US_COUNTRY_TRANSLATE'
and    c_effective_date BETWEEN ADDR.date_from
                            AND nvl(ADDR.date_to,end_date);
--
-- This cursor would be used for W2 and SQWL when person address not found
-- for the given effective_date. This cursor will fetch employee current
-- primary address
--
CURSOR get_mmref_name_address_eod
           (c_assignment_id  per_all_assignments_f.assignment_id%type)
IS
SELECT  ppf.full_name       ,
        ppf.employee_number ,
        addr.address_line1  ,
        addr.address_line2  ,
        addr.address_line3  ,
        addr.town_or_city   ,
        decode(NVL(addr.country,'US'), 'CA', addr.region_1,
                                      'US', addr.region_2, addr.region_1 )
                                      Province_or_state,
        addr.postal_code    ,
        substr(hrt.meaning,-2) ,
        fttl.territory_short_name,
        addr.region_1       ,
        addr.region_2       ,
        'Y'  valid_address
FROM   per_all_assignments_f  ASSIGN
,      per_addresses          ADDR
,      per_all_people_f       PPF
,      fnd_territories_tl     fttl
,      fnd_territories        ftt
,      hr_lookups             hrt
where  ASSIGN.assignment_id   = c_assignment_id
and    ASSIGN.person_id       = ppf.person_id
and    assign.assignment_type = 'E'
and    ADDR.person_id         = ASSIGN.person_id
and    NVL(addr.country,'US') = ftt.territory_code
and    ftt.territory_code     = fttl.territory_code
and    hrt.lookup_code       = ftt.territory_code
and    hrt.lookup_type        = 'PQP_US_COUNTRY_TRANSLATE'
and    fttl.language          = USERENV('LANG')
and    ADDR.primary_flag      = 'Y'
and    addr.date_to is NULL
order by addr.address_id desc;

--
--  For any report that needs to fetch person name and address inputing
--  person_id and effective date.
--
CURSOR get_report_name_address
          (c_person_id      per_all_people_f.person_id%type,
           c_effective_date date)
IS
SELECT  ppf.full_name       ,
        ppf.employee_number ,
        addr.address_line1  ,
        addr.address_line2  ,
        addr.address_line3  ,
        addr.town_or_city   ,
        decode(NVL(addr.country,'US'), 'CA', addr.region_1,
                                       'US', addr.region_2, addr.region_1 )
                                       Province_or_state,
        addr.postal_code    ,
        substr(hrt.meaning,-2),
        fttl.territory_short_name,
        addr.region_1       ,
        addr.region_2       ,
        'Y'  valid_address
FROM   per_addresses          ADDR
,      per_all_people_f       PPF
,      fnd_territories_tl     fttl
,      fnd_territories        ftt
,      hr_lookups             hrt
where  ppf.person_id          = c_person_id
and    c_effective_date BETWEEN ppf.effective_start_date
                            AND ppf.effective_end_date
and    ADDR.person_id         = ppf.person_id
and    ADDR.primary_flag      = 'Y'
and    NVL(addr.country,'US') = ftt.territory_code
and    ftt.territory_code     = fttl.territory_code
and    hrt.lookup_code        = ftt.territory_code
and    hrt.lookup_type        = 'PQP_US_COUNTRY_TRANSLATE'
and    fttl.language          = USERENV('LANG')
and    c_effective_date BETWEEN ADDR.date_from
                            AND nvl(ADDR.date_to, end_date);
--
-- Get Person address for eod (i.e. end of date)
-- This would be used by most of Year end report to fetch person
-- address when effective date is greater then period_end_date
-- for instance for W2, if effective_date is greater then year end date
-- this will b
CURSOR get_report_name_address_eod
          (c_person_id      per_all_people_f.person_id%type)
IS
SELECT ppf.full_name       ,
       ppf.employee_number ,
       addr.address_line1  ,
       addr.address_line2  ,
       addr.address_line3  ,
       addr.town_or_city   ,
       decode(NVL(addr.country,'US'), 'CA', addr.region_1,
                                      'US', addr.region_2, addr.region_1 )
                                      Province_or_state,
       addr.postal_code    ,
       substr(hrt.meaning,-2),
       fttl.territory_short_name,
       addr.region_1       ,
       addr.region_2       ,
       'Y'  valid_address
FROM   per_addresses       addr
,      per_all_people_f    ppf
,      fnd_territories_tl  fttl
,      fnd_territories     ftt
,      hr_lookups          hrt
where  ppf.person_id          = c_person_id
and    addr.person_id         = ppf.person_id
and    addr.primary_flag      = 'Y'
and    NVL(addr.country,'US') = ftt.territory_code
and    ftt.territory_code     = fttl.territory_code
and    hrt.lookup_code       = ftt.territory_code
and    hrt.lookup_type        = 'PQP_US_COUNTRY_TRANSLATE'
and    fttl.language          = USERENV('LANG')
and    addr.date_to is NULL
order by addr.address_id desc;

--
-- This cursor would be used for W2, 1099R report to fetch Person Name
-- and Employee Number
CURSOR get_report_person_name
           (c_person_id      per_all_people_f.person_id%type,
            c_effective_date date)
IS
SELECT  ppf.full_name       ,
        ppf.employee_number
from   per_all_people_f       ppf
where  ppf.person_id = c_person_id
and    c_effective_date BETWEEN ppf.effective_start_date
                            AND ppf.effective_end_date;

l_addr_count          number(10)  := 0;
l_valid_address       varchar2(3) := 'N';
l_emp_number          per_all_people_f.employee_number%type;
l_full_name           per_all_people_f.full_name%TYPE;
/*
l_address_line_1      per_addresses.address_line1%type;
l_address_line_2      per_addresses.address_line2%type;
l_address_line_3      per_addresses.address_line3%type;
l_city                per_addresses.town_or_city%type;
l_region_1            per_addresses.region_1%TYPE;
l_region_2            per_addresses.region_2%TYPE;
l_postal_code         per_addresses.postal_code%TYPE;
l_country             per_addresses.country%type;
*/
l_too_many_adr_token3 varchar2(50):='More than one address found';
l_token2              varchar2(50);
l_effective_date      date;
l_record              varchar2(50);
l_report_type         varchar2(50);
l_name_count          number := 0;
BEGIN
l_addr_count         := 0;
l_valid_address      := 'N';
if p_period_end_date > p_effective_date then
   l_effective_date := p_period_end_date;
else
   l_effective_date := p_effective_date;
end if;
--
hr_utility.trace('Date Earned or Period End Date   '||to_char(p_period_end_date,'dd-mon-yyyy'));
hr_utility.trace('Date Effective or Session Date   '||to_char(l_effective_date,'dd-mon-yyyy'));
--
if p_report_type IN ('W2','SQWL','1099R','W2C') then
   l_report_type := 'MMREF';
else
   l_report_type := p_report_type;
end if;

if l_report_type = 'MMREF' THEN
--{
   open get_mmref_name_address(p_assignment_id,
                               l_effective_date);
   LOOP
     FETCH get_mmref_name_address INTO lr_person_name_address;
     l_addr_count := get_mmref_name_address%ROWCOUNT;
     EXIT WHEN l_addr_count > 1 or get_mmref_name_address%NOTFOUND;
   END LOOP;
   CLOSE get_mmref_name_address;
   if l_addr_count = 0 then
      open get_mmref_name_address_eod(p_assignment_id);
      loop
        fetch get_mmref_name_address_eod INTO lr_person_name_address;
        l_addr_count := get_mmref_name_address_eod%ROWCOUNT;
        exit when l_addr_count > 1 or get_mmref_name_address_eod%NOTFOUND;
      end loop;
      close get_mmref_name_address_eod;
      if l_addr_count = 0 then
         open get_mmref_person_name(p_assignment_id,
                                    l_effective_date);
         LOOP
            FETCH get_mmref_person_name INTO l_full_name,
                                             l_emp_number;
            lr_person_name_address.full_name       := l_full_name;
            lr_person_name_address.employee_number := l_emp_number;
            l_name_count := get_mmref_person_name%ROWCOUNT;
            EXIT WHEN l_name_count > 1 or get_mmref_person_name%NOTFOUND;
         END LOOP;
         CLOSE get_mmref_person_name;
         l_token2 := 'No Address found for Employee number '||
                                 lr_person_name_address.employee_number;
      elsif l_addr_count > 1 then
            l_addr_count := 1;
      end if;
   end if;
   l_record := p_source_type|| ' record';
--}
else
--{
   open get_report_name_address(p_person_id,
                                l_effective_date);
   LOOP
     FETCH get_report_name_address INTO lr_person_name_address;
     l_addr_count := get_report_name_address%ROWCOUNT;
     EXIT WHEN l_addr_count > 1 or get_report_name_address%NOTFOUND;
   END LOOP;
   if l_addr_count > 1 then
      l_addr_count := 1;
   end if;
   CLOSE get_report_name_address;
   if l_addr_count = 0 then
--{
      open get_report_name_address_eod(p_person_id);
      loop
        fetch get_report_name_address_eod INTO lr_person_name_address;
        l_addr_count := get_report_name_address_eod%ROWCOUNT;
        exit when l_addr_count > 1 or get_report_name_address_eod%NOTFOUND;
      end loop;
      close get_report_name_address_eod;
      if l_addr_count = 0 then
         open get_report_person_name(p_person_id,
                                     l_effective_date);
         LOOP
            FETCH get_report_person_name INTO l_full_name,
                                              l_emp_number;
            lr_person_name_address.full_name       := l_full_name;
            lr_person_name_address.employee_number := l_emp_number;
            l_name_count := get_report_person_name%ROWCOUNT;
            EXIT WHEN l_name_count > 1 or get_report_person_name%NOTFOUND;
         END LOOP;
         CLOSE get_report_person_name;
         l_token2 := 'No Address found for Employee number '||
                                 lr_person_name_address.employee_number;
         l_record := p_source_type;
      elsif l_addr_count > 1 then
            l_addr_count := 1;
      end if;
--}
   end if;
END IF;-- p_report_type
-- This is validate person Address
IF P_validate = 'Y' THEN
--{
   IF l_addr_count = 0 THEN
      hr_utility.trace('WARNING: Employee Address not found ');
      l_valid_address := 'N';
      pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT_WARNING','A');
      pay_core_utils.push_token('record_name',l_record);
      pay_core_utils.push_token('name_or_number',
                             lr_person_name_address.employee_number);
      pay_core_utils.push_token('description',l_token2);
   ELSIF l_addr_count > 1 THEN
      hr_utility.trace('Too many rows for the address');
      l_valid_address := 'N';
      pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT_WARNING','A');
      pay_core_utils.push_token('record_name',l_record);
      pay_core_utils.push_token('name_or_number',
                             lr_person_name_address.employee_number);
      pay_core_utils.push_token('description',l_too_many_adr_token3);
   ELSIF l_addr_count = 1 THEN
      l_valid_address:= 'Y';
      hr_utility.trace('Single Primary Valid Address Found ..'||l_valid_address);
   END IF;
--}
ELSE
   l_valid_address:= 'Y';
END IF; --p_validate
lr_person_name_address.valid_address := l_valid_address;
return lr_person_name_address;
END GET_PERSON_NAME_ADDRESS;
--
-- This function may be used to fetch Organization Name and Address
-- by inputing organization_id and Effective Date
--
FUNCTION GET_ORGANIZATION_NAME_ADDRESS(
                   p_organization_id      IN  number,
                   p_effective_date       IN  date,
                   p_validate             IN  varchar2,
                   p_source_type          IN  varchar2)
            RETURN organization_name_address
IS
CURSOR get_organization_name_address
           (c_organization_id hr_organization_units.organization_id%type,
            c_effective_date  date)
IS
SELECT hou.name org_name ,
       hl.address_line_1,
       hl.address_line_2,
       hl.address_line_3,
       hl.town_or_city,
       decode(hl.country, 'CA', hl.region_1,
                          'US', hl.region_2, hl.region_1) Province_or_state,
       hl.postal_code,

      nvl(substr(hrl.meaning, -2),hl.country) country_code,
       hl.region_1,
       hl.region_2,
       hl.telephone_number_1,
       'Y' valid_address
FROM   hr_locations_all hl,
       hr_lookups hrl,
       hr_all_organization_units hou
WHERE  hou.organization_id = c_organization_id
AND    hl.location_id = hou.location_id
AND    nvl(hl.inactive_date,end_date)>= c_effective_date
AND    hrl.lookup_code (+)=hl.country
AND    lookup_type  (+)='PQP_US_COUNTRY_TRANSLATE';
lr_org_name_address   pay_us_get_item_data_pkg.organization_name_address;
l_addr_count          number(10)  := 0;
l_valid_address       varchar2(3) := 'N';
l_too_many_adr_token3 varchar2(50):='More than one address found';
l_token2              varchar2(50);
l_effective_date      date;
l_record              varchar2(50);

BEGIN
--{
   open get_organization_name_address(p_organization_id,
                                      p_effective_date);
   LOOP
     FETCH get_organization_name_address INTO lr_org_name_address;
     l_addr_count := get_organization_name_address%ROWCOUNT;
     EXIT WHEN l_addr_count > 1 or get_organization_name_address%NOTFOUND;
   END LOOP;
   CLOSE get_organization_name_address;
   IF p_validate = 'Y' THEN
--{
      IF l_addr_count = 0 THEN
         l_token2 := 'No data found for GRE ID '||to_char(p_organization_id);
         pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
         pay_core_utils.push_token('record_name',p_source_type||' record');
         pay_core_utils.push_token('description',l_token2);
         l_valid_address:='N';
         hr_utility.trace('ER_ADDRESS No data found for Tax_Unit_Id = '
                                                 ||to_char(p_organization_id));
      ELSIF l_addr_count > 1 THEN
         hr_utility.trace('Too many rows for the address');
         l_valid_address := 'N';
         pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','A');
         pay_core_utils.push_token('record_name',p_source_type||' record');
         pay_core_utils.push_token('description',l_too_many_adr_token3);
       ELSIF l_addr_count = 1  THEN
         hr_utility.trace('ER_ADDRESS Employer Address Found ');
         l_valid_address:='Y';
       END IF;
--}
   END IF;
--}
lr_org_name_address.valid_address := l_valid_address;
return lr_org_name_address;
END GET_ORGANIZATION_NAME_ADDRESS;

-- End of Function used to fetch Name and address of person
--{
-- Function to get Concurrent Program Parameter Value for a given Payroll_Action_ID
-- This function requires following
FUNCTION GET_CPROG_PARAMETER_VALUE( p_mag_payroll_action_id    varchar2,
                                    p_parameter_name           varchar2)
         RETURN varchar2 IS

-- This cursor would be used to fetch first parameter value
-- in legislative_prameters for a given Payroll_action_id
cursor c_get_legislative_parameter( c_payroll_action_id number)
     IS
 select  legislative_parameters
   from  pay_payroll_Actions
  where payroll_action_id = c_payroll_action_id;

parameter_list  varchar2(2000);
start_ptr                number;
end_ptr                  number;
token_val                pay_payroll_actions.legislative_parameters%type;
par_value                pay_payroll_actions.legislative_parameters%type;
l_payroll_action_id      pay_payroll_actions.payroll_action_id%type;
BEGIN
--l_payroll_action_id := pay_magtape_generic.get_parameter_value
--                                     ('TRANSFER_PAYROLL_ACTION_ID');
--
     l_payroll_action_id := to_number(p_mag_payroll_action_id);
--   Fetch Legislative_parameter for given Payroll_Action_Id
--
--     open c_get_legislative_parameter(p_mag_payroll_action_id);
     open c_get_legislative_parameter(l_payroll_action_id);
     loop
         fetch c_get_legislative_parameter INTO parameter_list;
         exit when  c_get_legislative_parameter%NOTFOUND;
     end loop;
     close c_get_legislative_parameter;
--
     token_val := p_parameter_name||'=';
--
     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);

hr_utility.trace('Magnetic Process Payroll_Action_Id '||to_char(l_payroll_action_id));
--hr_utility.trace('Prameter List '||parameter_list);
--hr_utility.trace('Token Value   '||token_val);
--hr_utility.trace('Start Ptr     '||to_char(start_ptr));
--hr_utility.trace('End Ptr       '||to_char(end_ptr));
--
     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;
--
     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;
--
     if instr(par_value,'/') <>  0  then
        par_value := par_value || ' 00:00:00';
     end if;
--
     if par_value IS NULL then
        par_value := 'NULL';
     end if;
--
hr_utility.trace('Parameter Value Returned '||par_value);
     return par_value;
END GET_CPROG_PARAMETER_VALUE;
--}
--
--BEGIN
--hr_utility.trace_on(null,'GETITEMDATA');
END pay_us_get_item_data_pkg; --End of Package Body

/
