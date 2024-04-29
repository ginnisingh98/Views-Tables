--------------------------------------------------------
--  DDL for Package PAY_US_MWR_REPORTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_MWR_REPORTING_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusmwrp.pkh 120.0.12000000.1 2007/01/18 02:39:58 appldev noship $ */
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

    Name        : pay_us_mwr_reporting_pkg

    Description : Generate the multi worksite magnetic report.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No   Description
    ----        ----     ------  -------  -----------
    08-FEB-2001 tclewis   115.0            Created.
    24-DEC-2002 tclewis   115.9            Added NOCOPY
    26-DEC-2003 tclewis   115.10           Added index hint to
  *******************************************************************/

  /******************************************************************
  ** Global variables used by the file generation code.
  ******************************************************************/
  estab_count   number := 0;
  est_id        number := -88888;  -- setting the default value to -88888
  state_abbrev    varchar(2) := '00';  -- setting the default value to -88888


  /******************************************************************
  ** Driving Cursors file Generation
  ******************************************************************/
cursor US_MWR_SETUP is
select 'PAYROLL_ACTION_ID=C',       ppa.payroll_action_id
from pay_payroll_actions    ppa  -- MWR payroll action
where ppa.payroll_action_id        = Pay_Magtape_Generic.Get_Parameter_Value(
                                      'TRANSFER_PAYROLL_ACTION_ID'); --  MWR payroll action


cursor US_MWR_STATE_GRE is
select /*+    INDEX (HOI3 HR_ORGANIZATION_INFORMATIO_FK2)
              ORDERED */
       DISTINCT 'TRANSFER_FIPS_CODE=P',      psr.fips_code,         --  state code
                'TRANSFER_STATE_ABBREV=P',   psr.state_code,
                'TRANSFER_EIN=P',            NVL(hoi2.org_information1,'0'),  -- Federal EIN
                'TRANSFER_SUI_CODE=P',       hoi3.org_information2,         -- STATE SUI code.
                'TRANSFER_REPORTING_YEAR=P', to_char(ppa1.effective_date,'yyyy'),
                'TRANSFER_OUTPUT_QTR=P',     to_char(ppa2.effective_date,'Q')
from
 PAY_PAYROLL_ACTIONS PPA2,    -- MWR payroll action
 PAY_ASSIGNMENT_ACTIONS PAA2, -- MWR assignment action
 PAY_ASSIGNMENT_ACTIONS PAA1, -- SQWL assignment action
 PAY_PAYROLL_ACTIONS PPA1,    -- SQWL payroll action
 PAY_STATE_RULES PSR,
 HR_ORGANIZATION_INFORMATION HOI1, -- gre / legal entity classification
 HR_ORGANIZATION_INFORMATION HOI2, -- Federal employer Identification
 HR_ORGANIZATION_INFORMATION HOI3  -- state SUI code.
where ppa2.payroll_action_id        = Pay_Magtape_Generic.Get_Parameter_Value(
                                      'TRANSFER_PAYROLL_ACTION_ID') --  MWR payroll action
and   ppa2.payroll_action_id       = paa2.payroll_action_id
       -- paa2.serial_number store sqwl locked action
and   paa2.serial_number           = paa1.assignment_action_id
and   paa1.payroll_action_id       = ppa1.payroll_action_id
and   ppa1.report_type             = 'SQWL'
and   ppa1.business_group_id       = ppa2.business_group_id
and   ppa1.report_qualifier        = psr.state_code
and   paa1.tax_unit_id             = hoi1.organization_id
and   hoi1.org_information_context = 'CLASS'
and   hoi1.org_information1        = 'HR_LEGAL'
and   hoi1.org_information2        = 'Y'    --  Gre Legal entity is active
and   paa2.tax_unit_id             = hoi2.organization_id
and   hoi2.org_information_context = 'Employer Identification'
and   paa2.tax_unit_id             = hoi3.organization_id
and   hoi3.org_information_context = 'State Tax Rules'
      -- ppa1.report_qualifier is SQWL state code.
and   hoi3.org_information1        = ppa1.report_qualifier
order by psr.state_code, NVL(hoi2.org_information1,'0');



  cursor US_MWR_ESTABLISHMENT is
Select 'TRANSFER_ADDRESS=P'      ,SUBSTR(loc.address_line_1 ||
                                  decode(NVL(LENGTH(loc.address_line_2),0),0,' ',', '
                                  || loc.address_line_2) ||
                                  decode(NVL(LENGTH(loc.address_line_3),0),0,' ', ', '
                                  || loc.address_line_3),  1,  35)
       ,'TRANSFER_CITY=P'        ,loc.town_or_city
       ,'TRANSFER_STATE=P'       ,loc.region_2
       ,'TRANSFER_ZIP=P'         ,loc.postal_code
       ,'TRANSFER_LEGAL_NAME=P'  ,NVL(hoi.org_information1,hou.name)
       ,'TRANSFER_RPT_UNIT_NO=P' ,lei.lei_information1
       ,'TRANSFER_TRADE_NAME=P'  ,lei.lei_information2
       ,'TRANSFER_WRKSIT_DESC=P' ,lei.lei_information3
       ,'TRANSFER_COMNT_1=P'     ,lei.lei_information4
       ,'TRANSFER_COMNT_2=P'     ,lei.lei_information5
       ,'TRANSFER_COMNT_3=P'     ,lei.lei_information6
       ,'TRANSFER_COMMENTS=P'     ,lei.lei_information7
       ,'TRANSFER_EST_ID=P'      ,pghn2.entity_id
       ,'TRANSFER_REC_COUNT=P'   ,pay_us_mwr_reporting_pkg.estab_count
       ,'TRANSFER_HEADER=P'      ,pay_us_mwr_reporting_pkg.est_id
from per_gen_hierarchy pgh
     ,per_gen_hierarchy_versions pghv
     ,per_gen_hierarchy_nodes    pghn   -- parent organization
     ,per_gen_hierarchy_nodes    pghn2  -- establishment organizations
     ,hr_organization_information hoi
     ,hr_organization_units     hou
     ,hr_locations                loc
     ,hr_location_extra_info     lei
where pgh.hierarchy_id = Pay_Magtape_Generic.Get_Parameter_Value(
                      'TRANSFER_HIERARCHY_ID')                   --parameter p_hierarchy_id
and   pghv.HIERARCHY_VERSION_id = Pay_Magtape_Generic.Get_Parameter_Value(
                      'TRANSFER_HIERARCHY_VERSION')         --parameter p_hierarchy_verision_number
and   pgh.hierarchy_id = pghv.hierarchy_id
and   pghv.hierarchy_version_id = pghn.hierarchy_version_id
and   pghn.node_type                 = 'PAR'
and   pghn.entity_id            = hou.organization_id
and   hou.business_group_id     =  pgh.business_group_id
and   hou.organization_id       = hoi.organization_id
and   hoi.org_information_context = 'MWR_Info'
and   pghv.hierarchy_version_id   = pghn2.hierarchy_version_id
and   pghn.business_group_id       = pghn2.business_group_id
and   pghn2.node_type            = 'EST'
and   pghn2.entity_id              = loc.location_id
and   loc.region_2                 = Pay_Magtape_Generic.Get_Parameter_Value(
                      'TRANSFER_STATE_ABBREV')
and   loc.location_id              = lei.location_id
and   lei.information_type         = 'Multi Work Site Information'
UNION ALL
Select 'TRANSFER_ADDRESS=P'      ,NULL
       ,'TRANSFER_CITY=P'        ,NULL
       ,'TRANSFER_STATE=P'       ,NULL
       ,'TRANSFER_ZIP=P'         ,NULL
       ,'TRANSFER_LEGAL_NAME=P'  ,'No Worksite defined for earnings'
       ,'TRANSFER_RPT_UNIT_NO=P' ,'99999'
       ,'TRANSFER_TRADE_NAME=P'  ,'No Worksite defined for earnings'
       ,'TRANSFER_WRKSIT_DESC=P' ,'No Worksite defined for earnings'
       ,'TRANSFER_COMNT_1=P'     ,NULL
       ,'TRANSFER_COMNT_2=P'     ,NULL
       ,'TRANSFER_COMNT_3=P'     ,NULL
       ,'TRANSFER_COMMENTS=P'     ,NULL
       ,'TRANSFER_EST_ID=P'      ,'-99999'
       ,'TRANSFER_REC_COUNT=P'   ,pay_us_mwr_reporting_pkg.estab_count
       ,'TRANSFER_HEADER=P'      ,pay_us_mwr_reporting_pkg.est_id
From DUAL;
-- NEED TO ADD UNION ALL TO THIS CURSOR.

  /*******************************************************************/
  -- 'level_cnt' will allow the cursors to select function results,
  -- whether it is a standard fuction such as to_char or a function
  -- defined in a package (with the correct pragma restriction).
 /*******************************************************************/
  level_cnt      NUMBER;



  FUNCTION get_mwr_values(p_payroll_action_id  number
                          ,p_fips_code          in varchar2
                          ,p_sui_id             in varchar2
                          ,p_est_id             in varchar2
                          ,p_fed_ein            in varchar2
                              )
  RETURN varchar2;

  FUNCTION derive_sui_id ( p_state_code         in varchar2
                          ,p_sui_id             in varchar2
                         )
  RETURN varchar2;

  FUNCTION REMOVE_RPT_TOTALS(p_payroll_action_id  number)
  RETURN NUMBER;


  PROCEDURE range_cursor( p_payroll_action_id  in number
                         ,p_sql_string        out NOCOPY varchar2);

  PROCEDURE action_creation( p_payroll_action_id in number
                            ,p_start_assignment  in number
                            ,p_end_assignment    in number
                            ,p_chunk             in number);

  FUNCTION LOAD_RPT_TOTALS( p_payroll_action_id  number)
  RETURN NUMBER;

  FUNCTION update_global_values(p_estab_ID number,
                                p_state_abbrev varchar2)
  RETURN NUMBER;


END pay_us_mwr_reporting_pkg;

 

/
