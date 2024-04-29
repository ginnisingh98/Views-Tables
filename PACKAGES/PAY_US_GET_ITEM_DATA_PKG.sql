--------------------------------------------------------
--  DDL for Package PAY_US_GET_ITEM_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_GET_ITEM_DATA_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusgitd.pkh 120.0.12010000.2 2010/03/19 14:35:01 emunisek ship $  */

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

    Referenced By:  Package  pay_us_reporting_utils_pkg

   Notes

   History
   Date       Developer   Ver      Bug #       Description
   ---------  ---------   ------   ---------   ---------------------------------------------------------
   14-Jul-03  ppanda      115.0                Created
   11-Sep-03  ppanda      115.2                A new column added to record structure person_name_address
                                                  This change is the result of YE report requirements for
                                                  country short name
   19-Mar-10  emunisek    115.5    9356178     Added phone_number field in the organization_name_address type
*/

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
                    ) RETURN VARCHAR2;
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
                       ) RETURN VARCHAR2;
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
FUNCTION get_mmref_employer_address (
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
                         ) RETURN VARCHAR2;
--{
-- This record structure is used for Person/Employee Address
-- MMREF Reporting and YE reports would use this record data type
--
TYPE person_name_address IS RECORD (
     full_name        per_all_people_f.full_name%type       := NULL,
     employee_number  per_all_people_f.employee_number%type := NULL,
     addr_line_1      per_addresses.address_line1%type      := NULL,
     addr_line_2      per_addresses.address_line2%type      := NULL,
     addr_line_3      per_addresses.address_line3%type      := NULL,
     city             per_addresses.town_or_city%type       := NULL,
     province_state   varchar2(240)                         := NULL,
     postal_code      varchar2(240)                         := NULL,
     country          varchar2(240)                         := NULL,
     country_name     varchar2(240)                         := NULL,
     region_1         per_addresses.region_1%type           := NULL,
     region_2         per_addresses.region_2%type           := NULL,
     valid_address    varchar2(3)                           := 'N');
--
-- Function to get Person/Employee  Address
--
FUNCTION GET_PERSON_NAME_ADDRESS(
                   p_report_type          IN  varchar2,
                   p_person_id            IN  number,
                   p_assignment_id        IN  number,
                   p_period_end_date      IN  date,
                   p_effective_date       IN  date,
                   p_validate             IN  varchar2,
                   p_source_type          IN  varchar2)
             RETURN person_name_address;
--}
--{
-- This record structure is used for Organization Address
-- MMREF Reporting and YE reports would use this record data type
--  Added phone_number field in the organization_name_address type for Bug#9356178
TYPE organization_name_address IS RECORD (
     org_name         hr_organization_units.name%type      := NULL,
     addr_line_1      hr_locations_all.address_line_1%type := NULL,
     addr_line_2      hr_locations_all.address_line_2%type := NULL,
     addr_line_3      hr_locations_all.address_line_3%type := NULL,
     city             hr_locations_all.town_or_city%type   := NULL,
     province_state   varchar2(240)                        := NULL,
     postal_code      varchar2(240)                        := NULL,
     country          varchar2(240)                        := NULL,
     region_1         hr_locations_all.region_1%type       := NULL,
     region_2         hr_locations_all.region_2%type       := NULL,
     phone_number     hr_locations_all.telephone_number_1%type :=NULL,
     valid_address    varchar2(3)                          := 'N');
--
-- Function to get Organization/Employer  Address
--
FUNCTION GET_ORGANIZATION_NAME_ADDRESS(
                   p_organization_id      IN  number,
                   p_effective_date       IN  date,
                   p_validate             IN  varchar2,
                   p_source_type          IN  varchar2)
            RETURN organization_name_address;
--}
--{
--
-- Function to get Concurrent Program Parameter Value
--
FUNCTION GET_CPROG_PARAMETER_VALUE(
                   p_mag_payroll_action_id IN  varchar2,      -- Context
                   p_parameter_name        IN  varchar2)
         RETURN varchar2;
--}
--
--BEGIN
--hr_utility.trace_on(null,'GETITEMDATA');
END pay_us_get_item_data_pkg;
--End of Package Specification

/
