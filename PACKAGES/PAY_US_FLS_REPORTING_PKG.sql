--------------------------------------------------------
--  DDL for Package PAY_US_FLS_REPORTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_FLS_REPORTING_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusflsp.pkh 120.1.12010000.2 2010/01/13 12:30:39 nkjaladi ship $*/
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_fls_reporting_pkg

    Description : Generate FLS periodic magnetic reports according to
                  FLS requirements.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No   Description
    ----        ----     ------  -------  -----------
    12-JAN-2010 nkjaladi 115.13  9164356  Changed record type action_info_rec
                                          added new column sdi1_ee.
                                          Modified cursor definition of
                                          fls_header_wages_rec to include
                                          value 'US STATE2'
    20-JAN-2006 asasthan 115.12  4969824  Changed action cursor
                                          Now uses person_id instead of asg_id
    29-SEP-2004 ahanda   115.11  4092186  Changed cursor fls_header_wages_rec
                                          for MA
    02-SEP-2004 meshah   115.10           Fixed gscc error
    18-AUG-2004 ahanda   115.9   3832605  Changed the driving cursor
                                          and added a new function -
                                          get_jurisdiction_name.
    18-FEB-2004 ssmukher 115.7   3343962  Performance Changes
    06-FEB-2002 ahanda   115.6            Added dbdrv command.
    31-JUL-2001 ahanda   115.5            Added conditions to check for
                                          category and tax_unit_id in
                                          cursor fls_header_wages_rec.
    18-APR-2001 ahanda   115.4            Modified cursor fls_ein_jd_values
                                          to pass FEIN without /, - and space.
    02-APR-2001 ahanda   115.3            Modified functions
                                           - get_tax_exists
                                           - get_fls_agency_code
                                          Removed cursor
                                           - fls_wages_rec
                                          Renamed cursor fls_header_rec
                                          to fls_header_wages_rec
    12-MAR-2001 asasthan 115.2            Modified functions:
                                           - get_fls_agency_code
                                           - get_fls_tax_type_values
                                          Modified cursor fls_header_rec to
                                          have another parameter
                                          TRANSFER_RESIDENT_JD.
    22-FEB-2001 ahanda   115.1            Changed cursors to add function
                                          call.
    28-JAN-2001 ahanda   115.0            Created.

  *******************************************************************/

  /*******************************************************************
  ** Functions used in the FLS Tape Procss
  ** Defining the Functions before cursors as the functions are also
  ** used in cursors.
  *******************************************************************/

  /*******************************************************************
  ** Function to check if the Tax Exists for the Jurisdiction
  ** This function is used for State, County, City and School
  *******************************************************************/
  FUNCTION get_tax_exists( p_jurisdiction_code in varchar2
                          ,p_effective_date    in varchar2
                          ,p_tax_type          in varchar2
                          ,p_tax_type_resp     in varchar2 default NULL
                          )
  RETURN VARCHAR2;

  /*******************************************************************
  ** Function gets the Organization Short Name which is written in
  ** in the Header Record.
  ** The return values in the function function for Org4 and Org5
  ** are hard coded for Oracle In-House Implementation. The function
  ** need to be changed to gets the values from the Org Developer DF
  ** once it is implemented.
  *******************************************************************/
  FUNCTION get_fls_org_information(
                           p_tax_unit_id       in number
                          ,p_payroll_action_id in number
                          ,p_effective_date    in varchar2
                          )
  RETURN VARCHAR2;

  /*******************************************************************
  ** Function gets the FLS agency codes for the passed Vertex
  ** Jurisdiction code and effective date.
  ** The Agency Codes are stored in the JIT table:
  ** - PAY_US_FEDERAL_TAX_INFO_F
  ** - PAY_US_STATE_TAX_INFO_F
  ** - PAY_US_COUNTY_TAX_INFO_F
  ** - PAY_US_CITY_TAX_INFO_F
  *******************************************************************/
  FUNCTION get_fls_agency_code( p_jurisdiction_code     in varchar2
                               ,p_effective_date        in varchar2
                               ,p_resident_jurisdiction in varchar2
                               ,p_tax_type_code         in varchar2
                               )
  RETURN VARCHAR2;

  /*******************************************************************
  ** Function gets the Jurisdiction Code Name for the passed
  ** Jurisdiction code
  *******************************************************************/
  FUNCTION get_jurisdiction_name(p_jurisdiction_code     in varchar2
                                ,p_resident_jurisdiction in varchar2
                                )
  RETURN VARCHAR2;

  /*******************************************************************
  ** This function populates the PL/SQL table with the values for
  ** all Jurisdictions in a GRE. This PL/SQL table is then used to
  ** for getting the values in the Tape.
  *******************************************************************/
  FUNCTION get_fls_jd_values( p_tax_unit_id       in number
                             ,p_payroll_action_id in number
                              )
  RETURN NUMBER;

  /*******************************************************************
  ** The function is used to retreive the values from the PL/SQL
  ** table for the passed FLS tax Type and Jurisdiction Code.
  *******************************************************************/
  FUNCTION get_fls_tax_type_values(
                              p_tax_type       in varchar2
                             ,p_jurisdiction   in varchar2
                             ,p_resident_jurisdiction   in varchar2
                              )
  RETURN VARCHAR2;


  /*******************************************************************/
  -- 'level_cnt' will allow the cursors to select function results,
  -- whether it is a standard fuction such as to_char or a function
  -- defined in a package (with the correct pragma restriction).
  level_cnt      NUMBER;
  /******************************************************************
  ** Driving Cursors for Flat file Generation
  ******************************************************************/

  /*******************************************************************
  ** The cursor retreives all the GRE which should not be in the Tape.
  *******************************************************************/
  cursor fls_ein_jd_values is
    select 'TRANSFER_TAX_UNIT_ID=P',       hoi.organization_id,
           'TRANSFER_TAX_EIN=P',           replace(
                                             replace(
                                                replace(hoi.org_information1,
                                                       '-'),
                                                 '/'),
                                               ' '),
           'TRANSFER_EFFECTIVE_DATE=P',    to_char(ppa.effective_date,'MM/DD/YYYY'),
           'TRANSFER_PAYROLL_ACTION_ID=P', ppa.payroll_action_id
     from  pay_payroll_actions ppa
          ,hr_organization_information hoi
    where ppa.payroll_action_id =
            pay_magtape_generic.get_parameter_value(
                      'TRANSFER_PAYROLL_ACTION_ID')
      and exists (select 'x' from pay_assignment_Actions paa
                   where paa.payroll_action_id = ppa.payroll_action_id
                     and paa.tax_unit_id = hoi.organization_id
                  )
      and hoi.org_information_context = 'Employer Identification'
      ;

  /*******************************************************************
  ** The cursor retreives all the Jurisdictions which should not be
  ** in the Tape. The Tax Unit ID and Payroll Action ID are passed
  ** from the previous cursor.
  **
  ** The cursor retreives all the tax Types which should be
  ** reported in the Tape.
  ** A function is called for State, County and City to check if the
  ** tax exists for that Jurisdiction.
  **
  ** Lookup US_FLS_TAX_TYPES:
  **   The Description columns for the lookup stores the following
  **   information:
  **       First Char: Order in which the Tax Type needs to be reported
  **     Next 2 Chars: When the header need to be printed i.e. agency
  **                   changes at the FEDERAL Level
  **     Next 2 Chars: When the  header need to be printed i.e. agency
  **                   changes at the STATE level. This is not required
  **                   as of now but might be implemented for later.
  **     Next 2 Chars: When the  header need to be printed i.e. agency
  **                   changes at the LOCAL level. This is not required
  **                   as of now but might be implemented for later.
  *******************************************************************/
  cursor fls_header_wages_rec is
    select distinct
          'TRANSFER_JURISDICTION_CODE=P', pai.jurisdiction_code,
          'TRANSFER_RESIDENT_JD=P',
          -- If the length is 11 then we have Resident JD in
          -- action_information30
             decode(length(ltrim(rtrim(pai.action_information30))),
                   11, pai.action_information30),
          'TRANSFER_TAX_TYPE_CODE=P', fcl.lookup_code,
          'TRANSFER_TAX_TYPE_DESC=P', fcl.description
      from pay_action_information pai,
           fnd_common_lookups fcl
     where fcl.lookup_type = 'US_FLS_TAX_TYPES'
       and pai.action_information_category in ('US FEDERAL',
                                               'US STATE',
                                               'US STATE2', --Added #9164356
                                               'US COUNTY',
                                               'US CITY',
                                               'US SCHOOL DISTRICT'
                                               )
       and pai.tax_unit_id = pay_magtape_generic.get_parameter_value(
                                     'TRANSFER_TAX_UNIT_ID')
       and exists (select 'x'
                     from pay_assignment_actions paa
                    where paa.payroll_action_id =
                                pay_magtape_generic.get_parameter_value(
                                     'TRANSFER_PAYROLL_ACTION_ID')
                      and paa.tax_unit_id =
                                pay_magtape_generic.get_parameter_value(
                                     'TRANSFER_TAX_UNIT_ID')
                      and paa.serial_number = pai.action_context_id
                   )
       and pay_us_fls_reporting_pkg.get_tax_exists(
             pai.jurisdiction_code,
             pay_magtape_generic.get_parameter_value
                 ('TRANSFER_EFFECTIVE_DATE'),
             fcl.lookup_code) = 'Y'
      order by pai.jurisdiction_code,
               decode(length(ltrim(rtrim(pai.action_information30))),
                   11, pai.action_information30),
               substr(fcl.description,1,1);



  /*******************************************************************
  ** The cursor gets EE:R and NR records and ER rows to be reported
  ** on the Tax Record.
  *******************************************************************/
  cursor fls_tax_rec is
    select 'TRANSFER_PAYMENT_RESPONSIBILITY=P' , 'EE',
           'TRANSFER_RESIDENCY=P' , 'R'
      from dual
       /* Do not pick EE for FUTA if JD is Federal. Need to
          check JD and Tax Type as FUTA and SUI have the
          same Tax Type i.e. UI */
     where pay_us_fls_reporting_pkg.get_tax_exists(
             pay_magtape_generic.get_parameter_value
                 ('TRANSFER_JURISDICTION_CODE'),
             pay_magtape_generic.get_parameter_value
                 ('TRANSFER_EFFECTIVE_DATE'),
             pay_magtape_generic.get_parameter_value
                 ('TRANSFER_TAX_TYPE_CODE'),
             'EE') = 'Y'
    UNION ALL
    select 'TRANSFER_PAYMENT_RESPONSIBILITY=P' , 'ER',
           'TRANSFER_RESIDENCY=P' , 'R'
      from dual
       /* Return ER for all Jurisdiction where Tax Type is
          not Income Tax, OPT or EIC */
     where pay_magtape_generic.get_parameter_value
            ('TRANSFER_TAX_TYPE_CODE') not in ('IT', 'OPT', 'EIC')
       and pay_us_fls_reporting_pkg.get_tax_exists(
             pay_magtape_generic.get_parameter_value
                 ('TRANSFER_JURISDICTION_CODE'),
             pay_magtape_generic.get_parameter_value
                 ('TRANSFER_EFFECTIVE_DATE'),
             pay_magtape_generic.get_parameter_value
                 ('TRANSFER_TAX_TYPE_CODE'),
             'ER') = 'Y'
    UNION ALL
    select 'TRANSFER_PAYMENT_RESPONSIBILITY=P' , 'EE',
           'TRANSFER_RESIDENCY=P' , 'NR'
      from dual
       /* Check if JD is for local i.e. county_code should not
          be 000, if <> 000 then return true else check if JD
          is is school, if yes then retrun false.
          All other cases return false
        */
     where decode(substr(pay_magtape_generic.get_parameter_value
                  ('TRANSFER_JURISDICTION_CODE'),4,3), '000',
                decode(length(pay_magtape_generic.get_parameter_value
                 ('TRANSFER_JURISDICTION_CODE')), 8, -1, -1),
                1) = 1
       and pay_us_fls_reporting_pkg.get_tax_exists(
             pay_magtape_generic.get_parameter_value
                 ('TRANSFER_JURISDICTION_CODE'),
             pay_magtape_generic.get_parameter_value
                 ('TRANSFER_EFFECTIVE_DATE'),
             pay_magtape_generic.get_parameter_value
                 ('TRANSFER_TAX_TYPE_CODE'),
             'EE') = 'Y'
--    UNION ALL
--    select 'TRANSFER_PAYMENT_RESPONSIBILITY=P' , 'ER',
--           'TRANSFER_RESIDENCY=P' , 'NR'
--      from dual
--       /* Return ER/NR for all local JD where Tax Type is
--          not Income Tax or EIC */
--     where pay_magtape_generic.get_parameter_value
--            ('TRANSFER_TAX_TYPE_CODE') not in ('IT', 'EIC')
--         and decode(substr(pay_magtape_generic.get_parameter_value
--                  ('TRANSFER_JURISDICTION_CODE'),4,3), '000',
--                decode(length(pay_magtape_generic.get_parameter_value
--                 ('TRANSFER_JURISDICTION_CODE')), 8, 1, -1),
--                1) = 1
;


  /*******************************************************************
  ** Range Code to pick all the distinct assignment_ids which
  ** are to be reported.
  *******************************************************************/
  PROCEDURE range_cursor( p_payroll_action_id  in number
                         ,p_sql_string        out nocopy varchar2); -- Bug 3343962

  /*******************************************************************
  ** Action Creation Code to create assignment actions for all the
  ** the assignment_ids which are to be reported.
  *******************************************************************/
  PROCEDURE action_creation( p_payroll_action_id in number
                            ,p_start_person      in number
                            ,p_end_person        in number
                            ,p_chunk             in number);


  /*******************************************************************
  ** PL/SQL Record to store the archived values.
  *******************************************************************/
  TYPE action_info_rec IS RECORD
   ( jurisdiction_code    pay_action_information.jurisdiction_code%type
    ,action_information1  NUMBER(14,2) := 0
    ,action_information2  NUMBER(14,2) := 0
    ,action_information3  NUMBER(14,2) := 0
    ,action_information4  NUMBER(14,2) := 0
    ,action_information5  NUMBER(14,2) := 0
    ,action_information6  NUMBER(14,2) := 0
    ,action_information7  NUMBER(14,2) := 0
    ,action_information8  NUMBER(14,2) := 0
    ,action_information9  NUMBER(14,2) := 0
    ,action_information10 NUMBER(14,2) := 0
    ,action_information11 NUMBER(14,2) := 0
    ,action_information12 NUMBER(14,2) := 0
    ,action_information13 NUMBER(14,2) := 0
    ,action_information14 NUMBER(14,2) := 0
    ,action_information15 NUMBER(14,2) := 0
    ,action_information16 NUMBER(14,2) := 0
    ,action_information17 NUMBER(14,2) := 0
    ,action_information18 NUMBER(14,2) := 0
    ,action_information19 NUMBER(14,2) := 0
    ,action_information20 NUMBER(14,2) := 0
    ,action_information21 NUMBER(14,2) := 0
    ,action_information22 NUMBER(14,2) := 0
    ,action_information23 NUMBER(14,2) := 0
    ,action_information24 NUMBER(14,2) := 0
    ,action_information25 NUMBER(14,2) := 0
    ,action_information26 NUMBER(14,2) := 0
    ,action_information27 NUMBER(14,2) := 0
    ,action_information28 NUMBER(14,2) := 0
    ,action_information29 NUMBER(14,2) := 0
    ,action_information30 VARCHAR2(100)
    ,sdi1_ee              NUMBER(14,2) := 0 -- Added for Bug#9164356
    );

  /*******************************************************************
  ** PL/SQL table of record to store the archived values.
  *******************************************************************/
  TYPE action_info_tab IS TABLE OF
    action_info_rec
  INDEX BY BINARY_INTEGER;

  ltr_action_info action_info_tab;

END pay_us_fls_reporting_pkg;

/
