--------------------------------------------------------
--  DDL for Package PAY_US_1099R_MAG_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_1099R_MAG_REPORTING" AUTHID CURRENT_USER AS
/* $Header: pyyep99r.pkh 120.0.12010000.1 2008/07/28 00:02:09 appldev ship $ */
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

    Name        : pay_us_1099r_mag_reporting

    Description : Generate 1099R end of year magnetic reports according to
                  US legislative requirements.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No    Description
    ----        ----     ----    ------    -----------
    01-OCT-98   AHANDA   40.0              Created.
    20-DEC-98   AHANDA   40.4              Changed procedure
                                           US_1099R_State_Process for Changed
                                           to SC format. They have a K
                                           record if SIT > 0
    18-FEB-99   AHANDA   40.5              Changed the order by clause for
                                           the cursor us_1099r_payee and
                                           state_1099r_payee
                                           from 10, 12, 14 to 12, 14, 16
    18-FEB-99   AHANDA   40.6              Added national_identifier to the
                                           cursor us_1099r_payee and
                                           state_1099r_payee
                                           and added it in the order by clause
    28-MAY-99   rthakur  40.7              Added a check for the existence of
                                           a run result
                                           in the same jurisdiction code in the
                                           US_1099R_Payee and STATE_1099R_Payee
                                           cursors. In the 'T' Record the
                                           transmitter information is now
                                           mandatory so removed the nvl.
    27-JUN-99  rthakur	40.8               Changed the check of the run result
                                           code to match the check in the view
                                           PAY_US_EARNINGS_AMOUNTS_V.
    29-JUN-99	rthakur	40.10              Removed the check for the existence
                                           of a run result
                                           in the US_1099R_Payee and
                                           STATE_1099R_Payee cursors as the year
                                           end archiver takes care of this logic
    01-JUL-99   rthakur  40.11             Modified the driving cursors to
                                           utilize the archived jurisdictions,
                                           through the pay_us_arch_mag_xxxx_v
                                           views.
    20-JUL-99   rthakur  40.13             Made major changes to the driving
                                           cursors to report off of the archive
                                           items.
    17-AUG-99   rthakur  40.14             Added the check for assignment
                                           actions in the Payer cursor.
    26-AUG-99   rthakur  40.15             Modified the Payer cursor, previously
                                           we would check the assign actions
                                           only for the Transmitter, we need to
                                           check for all.
    30-AUG-99   rthakur  40.16/17          Fixed the Payer cursor it would not
                                           pick up non-TCC GRE's.
    21-SEP-99   rthakur  115.1             Took the 110.7 of r11 and made the
                                           fnd_date changes.
    01-dec-00   djoshi   115.2             Modified  state_1099r_payee
                                           cursor modified for indiana
    27-AUG-01   ekim     40.20             Added Vendor Information parameters
                                           in us_1099r_transmitter cursor.
    14-NOV-01   jgoswami 115.4             Added MMREF Cursors for State 1099r
                                           Submitter, Payer and Payee.
    30-NOV-01   jgoswami 115.5             Added dbdrv command
    07-DEC-01   jgoswami 115.6             Added fnd_date.date_to_canonical to
                                           MMREF Cursors.
    15-AUG-2002 ahanda   115.7             Changed transmitter cursor to remove
                                           cartesian join
    11-nov-2002 djoshi   115.8             Added parameter to get contact Email
                                           Address to transmitter Cursor
                                           'US_1099R_TRANSMITTER'
    02-dec-2002 djoshi   115.9             Added nvl to the paramter.
    02-dec-2002 djoshi   115.10            Added nocopy to the file
    05-dec-2002 djoshi   115.11            Added combined filer for ID and NE
    07-DEC-2002 ahanda   115.12            Changed from clause to join to main
                                           table instead of secure views.
    30-OCT-2003 jgoswami 115.13 3057115    Added parameter to get payroll_action_id
                                           of 1099r mag to transmitter Cursor
                                           'US_1099R_TRANSMITTER'.It is used in the
                                           get_cprog_parameter_value formula function
    04-NOV-2003 jgoswami 115.14 3113962    added transfer_assignment_action_id parameter
                                           to the cursor US_1099R_Payee, STATE_1099R_Payee
    09-DEC-2003 jgoswami 115.15            Modified state_1099r_mmref_payer cursor
                                           added transfer_emp_code parameter as the
                                           common formula used for 1099r and W2
                                           MMRF_EMPLOYER_RECORD was modified for W2
***************************************************************************
 Cursor for the Fast Formulas are defined below

 US_1099R_TRANSMITTER          - For Transmitter Block
 US_1099R_Payer                - For Payer Block
 US_1099R_Payee                - For Payee Block (for Fedral 1099R)
 STATE_1099R_Payee             - For Payee Block (for State 1099R)
 US_1099R_State_Process        - Allow generation of state totals

***************************************************************************/


 -- 'level_cnt' will allow the cursors to select function results,
 -- whether it is a standard fuction such as to_char or a function
 -- defined in a package (with the correct pragma restriction).

 level_cnt      NUMBER;


-- Cursor to set up tax unit and jurisdiction contexts for each transmitter rec.
-- When we run for a State the Jurisdiction is set for the context otherwise it is set
-- to a dummy value for federal.

Cursor us_1099r_transmitter is
  select 'TAX_UNIT_ID=C',               ffaic.context, -- hoi.organization_id,
         'JURISDICTION_CODE=C',         'NOT_USED_FOR_FED',
         'PAYROLL_ACTION_ID=C',         ppa.payroll_action_id, -- YREND ARCHIVER
         'TRANSFER_TRANSMITTER_CONTROL_CODE=P', fai2.value,  -- hoi.org_information2,
         'TRANSFER_CONTACT_NAME=P',     hoi.org_information9,  --  nvl(hoi.org_information9, '$$'),
         'TRANSFER_CONTACT_NO=P',       hoi.org_information10,   --  nvl(hoi.org_information10, '$$')
         'TRANSFER_CONTACT_EMAIL=P', nvl(hoi.org_information20,' '),
         'TRANSFER_YREND_PAY_ACT_ID=P', ppa.payroll_action_id, -- YREND ARCHIVER
         'TRANSFER_PAYROLL_ACTION_ID=P', ppa2.payroll_action_id, --  1099R Payroll Action Id
         'VENDOR_INDICATOR=P', hoi.org_information11,
         'VENDOR_NAME=P', hoi.org_information12,
         'VENDOR_ADDRESS=P', hoi.org_information13,
         'VENDOR_CITY=P', hoi.org_information14,
         'VENDOR_STATE=P', hoi.org_information15,
         'VENDOR_ZIP=P', hoi.org_information16,
         'VENDOR_CONTACT_NAME=P', hoi.org_information17,
         'VENDOR_CONTACT_PHONE=P', hoi.org_information18,
         'VENDOR_CONTACT_EMAIL=P', hoi.org_information19
   from  hr_organization_information hoi,
         ff_contexts ffc,
         ff_user_entities fue,  -- A_US_1099R_TRANSMITTER_INDICATOR
         ff_user_entities fue2, -- A_US_1099R_TRANSMITTER_CODE
         ff_archive_item_contexts ffaic,
         pay_payroll_actions ppa, -- YREND Preprocessor
         pay_payroll_actions ppa2, -- 1099R Payroll Action Id
         ff_archive_items fai,  -- Transmitter Indicator
         ff_archive_items fai2  -- Transmitter code
   where ppa2.payroll_action_id
           = Pay_Magtape_Generic.Get_Parameter_Value('TRANSFER_PAYROLL_ACTION_ID')
     and ppa.report_type = 'YREND'
     and ppa.effective_date = ppa2.effective_date
     and ppa.business_group_id + 0 = ppa2.business_group_id
     and ppa.action_status = 'C'
     and rtrim(ltrim(Pay_Mag_Utils.Get_Parameter('TRANSFER_TRANS_LEGAL_CO_ID','TRANSFER_ALL_PAYERS',ppa2.legislative_parameters))) =
         ffaic.context
     and ppa.payroll_action_id = fai.context1
     and fai.context1 = fai2.context1
     and fue2.user_entity_name = 'A_US_1099R_TRANSMITTER_CODE'
     and fue2.user_entity_id = fai2.user_entity_id
     and fue.user_entity_name = 'A_US_1099R_TRANSMITTER_INDICATOR'
     and fue.user_entity_id = fai.user_entity_id
     and fai.value  ='Y'
     and ffc.context_name = 'TAX_UNIT_ID'
     and ffc.context_id = ffaic.context_id
     and ffaic.archive_item_id = fai.archive_item_id
     /* changed back to original due to  CBO issue */
     /* and hoi.organization_id =  ffaic.context   */
     /* Commented to avoid cartesian join issue */
     /* and hoi.organization_id
           = Pay_Magtape_Generic.Get_Parameter_Value('TRANSFER_TRANS_LEGAL_CO_ID') */
     and hoi.organization_id = rtrim(ltrim(Pay_Mag_Utils.Get_Parameter(
                                                              'TRANSFER_TRANS_LEGAL_CO_ID',
                                                              'TRANSFER_ALL_PAYERS',
                                                              ppa2.legislative_parameters)))
     and hoi.org_information_context = '1099R Magnetic Report Rules'
     -- and hoi.org_information1 = 'Y'
     and Pay_Magtape_Generic.Get_Parameter_Value ('TRANSFER_STATE') ='FED'
  UNION
   select 'TAX_UNIT_ID=C',              ffaic.context,  -- hoi.organization_id,
          'JURISDICTION_CODE=C',        psr.jurisdiction_code,
          'PAYROLL_ACTION_ID=C',        ppa.payroll_action_id,  -- YREND ARCHIVER
          'TRANSFER_TRANSMITTER_CONTROL_CODE=P', fai2.value,  -- hoi.org_information2,
          'TRANSFER_CONTACT_NAME=P',    hoi.org_information9,   --  nvl(hoi.org_information9,'$$'),
          'TRANSFER_CONTACT_NO=P',      hoi.org_information10,  --  nvl(hoi.org_information10,'$$')
          'TRANSFER_CONTACT_EMAIL=P', nvl(hoi.org_information20,' '),
          'TRANSFER_YREND_PAY_ACT_ID=P', ppa.payroll_action_id,  -- YREND ARCHIVER
         'TRANSFER_PAYROLL_ACTION_ID=P', ppa2.payroll_action_id, --  1099R Payroll Action Id
         'VENDOR_INDICATOR=P', hoi.org_information11,
         'VENDOR_NAME=P', hoi.org_information12,
         'VENDOR_ADDRESS=P', hoi.org_information13,
         'VENDOR_CITY=P', hoi.org_information14,
         'VENDOR_STATE=P', hoi.org_information15,
         'VENDOR_ZIP=P', hoi.org_information16,
         'VENDOR_CONTACT_NAME=P', hoi.org_information17,
         'VENDOR_CONTACT_PHONE=P', hoi.org_information18,
         'VENDOR_CONTACT_EMAIL=P', hoi.org_information19
     from hr_organization_information  hoi,
          pay_state_rules psr,
          ff_contexts ffc,
          ff_user_entities fue,  -- A_US_1099R_TRANSMITTER_INDICATOR
          ff_user_entities fue2, -- A_US_1099R_TRANSMITTER_CODE
          ff_archive_item_contexts ffaic,
          pay_payroll_actions ppa, -- YREND Preprocessor
          pay_payroll_actions ppa2, -- 1099R Payroll Action Id
          ff_archive_items fai,  -- INDICATOR
          ff_archive_items fai2  -- Transmitter code
    where ppa2.payroll_action_id = Pay_Magtape_Generic.Get_Parameter_Value('TRANSFER_PAYROLL_ACTION_ID')
     and ppa.report_type = 'YREND'
     and ppa.effective_date = ppa2.effective_date
     and ppa.business_group_id + 0 = ppa2.business_group_id
     and ppa.action_status = 'C'
     and rtrim(ltrim(Pay_Mag_Utils.Get_Parameter('TRANSFER_TRANS_LEGAL_CO_ID','TRANSFER_ALL_PAYERS',ppa2.legislative_parameters))) =
         ffaic.context
     and ppa.payroll_action_id = fai.context1
     and fai.context1 = fai2.context1
     and fue2.user_entity_name = 'A_US_1099R_TRANSMITTER_CODE'
     and fue2.user_entity_id = fai2.user_entity_id
     and fue.user_entity_name = 'A_US_1099R_TRANSMITTER_INDICATOR'
     and fue.user_entity_id = fai.user_entity_id
     and fai.value  ='Y'
     and ffc.context_name = 'TAX_UNIT_ID'
     and ffc.context_id = ffaic.context_id
     and ffaic.archive_item_id = fai.archive_item_id
     /* changed back to original due to  CBO issue */
     /* and hoi.organization_id =  ffaic.context   */
     /* Commented to avoid cartesian join issue */
     /* and hoi.organization_id
           = Pay_Magtape_Generic.Get_Parameter_Value('TRANSFER_TRANS_LEGAL_CO_ID') */
     and hoi.organization_id = rtrim(ltrim(Pay_Mag_Utils.Get_Parameter(
                                                              'TRANSFER_TRANS_LEGAL_CO_ID',
                                                              'TRANSFER_ALL_PAYERS',
                                                              ppa2.legislative_parameters)))
     and hoi.org_information_context = '1099R Magnetic Report Rules'
     -- and hoi.org_information1 = 'Y'
     and psr.state_code  = Pay_Magtape_Generic.Get_Parameter_Value('TRANSFER_STATE');


-- Cursor to set up the tax unit context for each employer being reported. Sets
-- up a parameter holding the tax unit identifier which can then be used by
-- subsequent cursors to restrict to employees within the employer.
-- Added an exists clause to check for the existance of an assignment action for
-- the Payer GRE. A GRE can be the transmitter without any employees. In that case
-- we don't want to print any payer records.
-- We have to have all the joins to ppa and ppa2 otherwise we will pick up duplicate rows.
-- When we pull from ff_archive_items we have to make sure the context1 is the YREND archiver
-- for the GRE othwerise we get duplicates.

Cursor US_1099R_Payer is

  select  'TAX_UNIT_ID=C'           ,  ffaic2.context,  -- hoi.organization_id,
          'PAYROLL_ACTION_ID=C'     ,  ffai2.context1,
          'TAX_UNIT_ID=P'           ,  ffaic2.context,  -- hoi.organization_id,
          'TRANSFER_TAX_UNIT_NAME=P',  ffai3.value      -- hou.name
     from -- hr_organization_information hoi,
          -- hr_organization_units hou,
          ff_contexts ffc,
          ff_user_entities ffue,
          ff_user_entities ffue2,
          ff_archive_items ffai,  -- TCC
          ff_archive_items ffai2, -- Tax Unit Id
          ff_archive_items ffai3, -- Tax Unit Name
          ff_archive_item_contexts ffaic,
          ff_archive_item_contexts ffaic2,
          pay_payroll_actions ppa,
          pay_payroll_actions ppa2
    where ffai.context1 =  Pay_Magtape_Generic.Get_Parameter_value('TRANSFER_YREND_PAY_ACT_ID')
      and ffai.archive_item_id = ffaic.archive_item_id
      and ffue.user_entity_id = ffai.user_entity_id
      and ffue.user_entity_name = 'A_US_1099R_TRANSMITTER_CODE'
      and ffc.context_name = 'TAX_UNIT_ID'
      and ffaic.context_id = ffc.context_id
      and ffai2.user_entity_id = ffai.user_entity_id
      and ffai2.value = ffai.value
      and ffai2.archive_item_id = ffaic2.archive_item_id
      and ffai2.context1 = ppa.payroll_action_id
      and ppa2.payroll_action_id = ffai.context1
      and ppa.report_type = 'YREND'
      and ppa2.business_group_id + 0 = ppa.business_group_id + 0
      and ppa2.effective_date = ppa.effective_date
      and ffue2.user_entity_name = 'A_TAX_UNIT_NAME'
      and ffue2.user_entity_id = ffai3.user_entity_id
      and ffai3.context1 = ffai2.context1
      and ffaic2.context_id = ffc.context_id
      and (Pay_Magtape_Generic.Get_Parameter_value('TRANSFER_ALL_PAYERS') = 'Y'
           OR ffaic2.context = Pay_Magtape_Generic.Get_Parameter_Value('TRANSFER_TRANS_LEGAL_CO_ID'))
      and exists (select 'Y' from pay_assignment_actions paa
          where paa.payroll_action_id = Pay_Magtape_Generic.Get_Parameter_Value('TRANSFER_PAYROLL_ACTION_ID')
          and paa.tax_unit_id = ffaic2.context)
      order by ffai3.value;


--Cursor to set up the assignment_action_id, assignment_id, and date_earned
--and Jurisdiction contexts for an employee. The date_earned context is set
--to be the least of the end of the period being reported and the maximum
--end date of the assignment.
--This ensures that personal information is current relative to the period
--being reported on.

Cursor us_1099r_payee is
   select 'ASSIGNMENT_ACTION_ID=C'          , pai.locked_action_id,  -- YREND Pre-Processor aaid
          'ASSIGNMENT_ID=C'                 , paa.assignment_id,
          'JURISDICTION_CODE=C'             , pec.jurisdiction_code,
          'TRANSFER_JURISDICTION_CODE=P'    , pec.jurisdiction_code,
          'DATE_EARNED=C'                   , fnd_date.date_to_canonical(Pay_Magtape_Generic.Date_Earned
                                                (ppa.effective_date,
                                                 paa.assignment_id)),
          'TRANSFER_LAST_NAME=P'            , pay_mag_utils.get_parameter('TRANSFER_LN','TRANSFER_FN', ffai.value),
          'TRANSFER_FIRST_NAME=P'           , pay_mag_utils.get_parameter('TRANSFER_FN','TRANSFER_MN', ffai.value),
          'TRANSFER_MIDDLE_NAMES=P'         , pay_mag_utils.get_parameter('TRANSFER_MN','TRANSFER_SSN', ffai.value),
          'TRANSFER_NATIONAL_IDENTIFIER=P'  , pay_mag_utils.get_parameter('TRANSFER_SSN', '', ffai.value),
          'TRANSFER_ASSIGNMENT_ACTION_ID=P' , pai.locked_action_id  -- YREND Pre-Processor aaid
    from  pay_us_arch_mag_county_v pec, -- pay_us_emp_county_tax_rules_f pec,
          per_all_people_f       ppf,
          ff_user_entities       ffue,
          ff_archive_items       ffai,
          pay_action_interlocks  pai,
          per_all_assignments_f  paf,
          pay_assignment_actions paa,
          pay_payroll_actions    ppa
    where pai.locking_action_id = paa.assignment_action_id
      and ppa.payroll_action_id = Pay_Magtape_Generic.Get_Parameter_Value
                                   ('TRANSFER_PAYROLL_ACTION_ID')
      and ppa.payroll_action_id = paa.payroll_action_id
      and paf.assignment_id     = paa.assignment_id
      and paa.tax_unit_id = Pay_Magtape_Generic.Get_Parameter_Value
                                   ('TAX_UNIT_ID')
      and ffue.user_entity_name = 'A_PER_1099R_NAME'
      and ffue.user_entity_id = ffai.user_entity_id
      and ffai.context1 = pai.locked_action_id  -- YREND pre-process aaid
 --   and paa.assignment_action_id = pai.locking_action_id  /* duplicate of the first where statement */
      and ppf.person_id         = paf.person_id
 --     and pec.assignment_id     = paa.assignment_id
      and pec.assignment_action_id = pai.locked_action_id
 --     and pay_magtape_generic.date_earned(ppa.effective_date, paa.assignment_id) between
 --                      pec.effective_start_date AND pec.effective_end_date
      and Pay_Mag_Utils.Date_Earned(ppa.effective_date,
                                    paa.assignment_id,
                                    paf.effective_start_date,
                                    paf.effective_end_date,
                                    ppf.effective_start_date,
                                    ppf.effective_end_date) = 1
   UNION ALL
   select 'ASSIGNMENT_ACTION_ID=C'         , pai.locked_action_id,
          'ASSIGNMENT_ID=C'                , paa.assignment_id,
          'JURISDICTION_CODE=C'            , pes.jurisdiction_code,
          'TRANSFER_JURISDICTION_CODE=P'   , pes.jurisdiction_code,
          'DATE_EARNED=C'                  , fnd_date.date_to_canonical(Pay_Magtape_Generic.Date_Earned
                                               (ppa.effective_date,
                                                paa.assignment_id)),
          'TRANSFER_LAST_NAME=P'           , pay_mag_utils.get_parameter('TRANSFER_LN','TRANSFER_FN', ffai.value),
          'TRANSFER_FIRST_NAME=P'          , pay_mag_utils.get_parameter('TRANSFER_FN','TRANSFER_MN', ffai.value),
          'TRANSFER_MIDDLE_NAMES=P'        , pay_mag_utils.get_parameter('TRANSFER_MN','TRANSFER_SSN', ffai.value),
          'TRANSFER_NATIONAL_IDENTIFIER=P' , pay_mag_utils.get_parameter('TRANSFER_SSN', '', ffai.value),
          'TRANSFER_ASSIGNMENT_ACTION_ID=P' , pai.locked_action_id  -- YREND Pre-Processor aaid
    from  pay_us_arch_mag_state_v pes, -- pay_us_emp_state_tax_rules_f pes,
          per_all_people_f       ppf,
          ff_user_entities       ffue,
          ff_archive_items       ffai,
          pay_action_interlocks  pai,
          per_all_assignments_f  paf,
          pay_assignment_actions paa,
          pay_payroll_actions    ppa
    where pai.locking_action_id = paa.assignment_action_id
      and ppa.payroll_action_id = Pay_Magtape_Generic.Get_Parameter_Value
                                   ('TRANSFER_PAYROLL_ACTION_ID')
      and ppa.payroll_action_id = paa.payroll_action_id
      and paf.assignment_id     = paa.assignment_id
      and paa.tax_unit_id = Pay_Magtape_Generic.Get_Parameter_Value
                                   ('TAX_UNIT_ID')
      and ffue.user_entity_name = 'A_PER_1099R_NAME'
      and ffue.user_entity_id = ffai.user_entity_id
      and ffai.context1 = pai.locked_action_id  -- YREND pre-process aaid
   --   and paa.assignment_action_id = pai.locking_action_id
      and ppf.person_id         = paf.person_id
   --   and pes.assignment_id     = paa.assignment_id
      and pes.assignment_action_id = pai.locked_action_id
      and not exists (select null from pay_us_arch_mag_county_v -- pay_us_emp_county_tax_rules_f
                       -- where state_code = pes.state_code
                          where substr(jurisdiction_code,1,2) = substr(pes.jurisdiction_code,1,2)
                          and assignment_action_id = pes.assignment_action_id )
   --   and pay_magtape_generic.date_earned(ppa.effective_date, paa.assignment_id) between
   --                    pes.effective_start_date AND pes.effective_end_date
      and Pay_Mag_Utils.Date_Earned(ppa.effective_date,
                                    paa.assignment_id,
                                    paf.effective_start_date,
                                    paf.effective_end_date,
                                    ppf.effective_start_date,
                                    ppf.effective_end_date) = 1
      ORDER BY 12, 14, 16, 18 ; --last_name, first_name, middle_names, national_identifier;



-- This is the state specific version of US_1099R_Payee
cursor state_1099r_payee is
   select 'ASSIGNMENT_ACTION_ID=C'         , pai.locked_action_id,
          'ASSIGNMENT_ID=C'                , paa.assignment_id,
          'JURISDICTION_CODE=C'            , pec.jurisdiction_code,
          'TRANSFER_JURISDICTION_CODE=P'   , pec.jurisdiction_code,
          'DATE_EARNED=C'                  , fnd_date.date_to_canonical(Pay_Magtape_Generic.Date_Earned
                                               (ppa.effective_date,
                                                paa.assignment_id)),
          'TRANSFER_LAST_NAME=P'           , pay_mag_utils.get_parameter('TRANSFER_LN','TRANSFER_FN', ffai.value),
          'TRANSFER_FIRST_NAME=P'          , pay_mag_utils.get_parameter('TRANSFER_FN','TRANSFER_MN', ffai.value),
          'TRANSFER_MIDDLE_NAMES=P'        , pay_mag_utils.get_parameter('TRANSFER_MN','TRANSFER_SSN', ffai.value),
          'TRANSFER_NATIONAL_IDENTIFIER=P' , pay_mag_utils.get_parameter('TRANSFER_SSN', '', ffai.value),
          'TRANSFER_ASSIGNMENT_ACTION_ID=P' , pai.locked_action_id  -- YREND Pre-Processor aaid
    from  pay_us_arch_mag_county_v pec,  -- pay_us_emp_county_tax_rules_f pec,
          per_all_people_f       ppf,
          ff_user_entities       ffue,
          ff_archive_items       ffai,
          pay_action_interlocks  pai,
          per_all_assignments_f  paf,
          pay_assignment_actions paa,
          pay_payroll_actions    ppa,
          pay_us_states          pus
    where ppa.payroll_action_id = Pay_Magtape_Generic.Get_Parameter_Value
                                   ('TRANSFER_PAYROLL_ACTION_ID')
      and ppa.payroll_action_id = paa.payroll_action_id
      and paf.assignment_id     = paa.assignment_id
      and ppf.person_id         = paf.person_id
      and paa.assignment_action_id = pai.locking_action_id
   --   and pec.assignment_id     = paa.assignment_id
      and pec.assignment_action_id = pai.locked_action_id
   --   and pec.state_code = pus.state_code
      and ffue.user_entity_name = 'A_PER_1099R_NAME'
      and ffue.user_entity_id = ffai.user_entity_id
      and ffai.context1 = pai.locked_action_id  -- YREND pre-process aaid
      and substr(pec.jurisdiction_code,1,2) = pus.state_code
      and paa.tax_unit_id = Pay_Magtape_Generic.Get_Parameter_Value
                                   ('TAX_UNIT_ID')
      and pus.state_abbrev= Pay_Magtape_Generic.Get_Parameter_Value
                                   ('TRANSFER_STATE')
   --   and pay_magtape_generic.date_earned(ppa.effective_date, paa.assignment_id) between
   --                    pec.effective_start_date AND pec.effective_end_date
      and Pay_Mag_Utils.Date_Earned(ppa.effective_date,
                                    paa.assignment_id,
                                    paf.effective_start_date,
                                    paf.effective_end_date,
                                    ppf.effective_start_date,
                                    ppf.effective_end_date) = 1
      /* if the state is Indiana we use this cursor for getting the Supplemental Records */
   UNION ALL
   select 'ASSIGNMENT_ACTION_ID=C'         , pai.locked_action_id,
          'ASSIGNMENT_ID=C'                , paa.assignment_id,
          'JURISDICTION_CODE=C'            , pes.jurisdiction_code,
          'TRANSFER_JURISDICTION_CODE=P'   , pes.jurisdiction_code,
          'DATE_EARNED=C'                  , fnd_date.date_to_canonical(Pay_Magtape_Generic.Date_Earned
                                               (ppa.effective_date,
                                                paa.assignment_id)),
          'TRANSFER_LAST_NAME=P'           , pay_mag_utils.get_parameter('TRANSFER_LN','TRANSFER_FN', ffai.value),
          'TRANSFER_FIRST_NAME=P'          , pay_mag_utils.get_parameter('TRANSFER_FN','TRANSFER_MN', ffai.value),
          'TRANSFER_MIDDLE_NAMES=P'        , pay_mag_utils.get_parameter('TRANSFER_MN','TRANSFER_SSN', ffai.value),
          'TRANSFER_NATIONAL_IDENTIFIER=P' , pay_mag_utils.get_parameter('TRANSFER_SSN', '', ffai.value),
          'TRANSFER_ASSIGNMENT_ACTION_ID=P' , pai.locked_action_id  -- YREND Pre-Processor aaid
    from  pay_us_arch_mag_state_v pes,  -- pay_us_emp_state_tax_rules_f pes,
          per_all_people_f       ppf,
          ff_user_entities       ffue,
          ff_archive_items       ffai,
          pay_action_interlocks  pai,
          per_all_assignments_f  paf,
          pay_assignment_actions paa,
          pay_payroll_actions    ppa,
          pay_us_states          pus
    where ppa.payroll_action_id = Pay_Magtape_Generic.Get_Parameter_Value
                                   ('TRANSFER_PAYROLL_ACTION_ID')
      and ppa.payroll_action_id = paa.payroll_action_id
      and paf.assignment_id     = paa.assignment_id
      and ppf.person_id         = paf.person_id
      and paa.assignment_action_id = pai.locking_action_id
    --  and pes.assignment_id     = paa.assignment_id
      and pes.assignment_action_id = pai.locked_action_id
    --  and pes.state_code = pus.state_code
      and substr(pes.jurisdiction_code,1,2) = pus.state_code
      and ffue.user_entity_name = 'A_PER_1099R_NAME'
      and ffue.user_entity_id = ffai.user_entity_id
      and ffai.context1 = pai.locked_action_id  -- YREND pre-process aaid
      and not exists (select null from pay_us_arch_mag_county_v  -- pay_us_emp_county_tax_rules_f
                       -- where state_code = pes.state_code
                         where substr(jurisdiction_code,1,2) = substr(pes.jurisdiction_code,1,2)
                       --  and assignment_id = pes.assignment_id
                         and assignment_action_id = pes.assignment_action_id)
    --   and pay_magtape_generic.date_earned(ppa.effective_date, paa.assignment_id) between
    --                   pes.effective_start_date AND pes.effective_end_date
      and paa.tax_unit_id = Pay_Magtape_Generic.Get_Parameter_Value
                                   ('TAX_UNIT_ID')
      and pus.state_abbrev= Pay_Magtape_Generic.Get_Parameter_Value
                                   ('TRANSFER_STATE')
      and Pay_Mag_Utils.Date_Earned(ppa.effective_date,
                                    paa.assignment_id,
                                    paf.effective_start_date,
                                    paf.effective_end_date,
                                    ppf.effective_start_date,
                                    ppf.effective_end_date) = 1
      /* if the state is Indiana we use this cursor for getting the Supplemental Records */
   ORDER BY 12, 14, 16, 18 ; --last_name, first_name, middle_names, national_identifier;


-- Cursor to allow generation of state totals by assignment
-- for payers participating in Combined Filing.
Cursor US_1099R_State_Process IS
   select distinct 'TRANSFER_STATE_NAME=P', hlk.lookup_code
     from fnd_common_lookups  hlk,
          hr_organization_information hoi
    where hoi.organization_id = Pay_Magtape_Generic.Get_Parameter_Value
                                       ('TRANSFER_TRANS_LEGAL_CO_ID')
      and hoi.org_information4 = 'Y'
      and hoi.org_information_context = '1099R Magnetic Report Rules'
      and hlk.lookup_type = '1099R_US_COMBINED_FILER_STATES'
      and Pay_Magtape_Generic.Get_Parameter_Value
                           ('TRANSFER_STATE') = 'FED'
   UNION ALL
   select 'TRANSFER_STATE_NAME=P', 'SC'
     from dual
    where Pay_Magtape_Generic.Get_Parameter_Value
                           ('TRANSFER_STATE') = 'SC'
 UNION ALL
   select 'TRANSFER_STATE_NAME=P', 'ID'
     from dual
    where Pay_Magtape_Generic.Get_Parameter_Value
                           ('TRANSFER_STATE') = 'ID'
 UNION ALL
   select 'TRANSFER_STATE_NAME=P', 'NE'
     from dual
    where Pay_Magtape_Generic.Get_Parameter_Value
                           ('TRANSFER_STATE') = 'NE'
;

--MMREF Cursors
-- Cursor to set up tax unit and jurisdiction contexts for each transmitter rec.
-- When we run for a State the Jurisdiction is set for the context otherwise it is set
-- to a dummy value for federal.
 CURSOR state_1099r_mmref_transmitter IS
SELECT 'TAX_UNIT_ID=C' , HOI.organization_id,
            'JURISDICTION_CODE=C', SR.jurisdiction_code,
            'TRANSFER_JD=P', SR.jurisdiction_code,
            'ASSIGNMENT_ID=C' , '-1',
            'DATE_EARNED=C', fnd_date.date_to_canonical(ppa.effective_date),
            'TRANSFER_HIGH_COUNT=P', '0',
            'TRANSFER_SCHOOL_DISTRICT=P', '-1',
            'TRANSFER_COUNTY=P', '-1',
            'TRANSFER_2678_FILER=P', 'N',
            'PAYROLL_ACTION_ID=C', PPA.payroll_action_id,
            'TRANSFER_LOCALITY_CODE=P', 'DUMMY',
            'BUSINESS_GROUP_ID=C',PPA.business_group_id
       FROM pay_state_rules SR,
            hr_organization_information HOI,
            pay_payroll_actions PPA,
            pay_payroll_actions PPA1
      WHERE PPA1.payroll_action_id = pay_magtape_generic.get_parameter_value
                                     ('TRANSFER_PAYROLL_ACTION_ID')
        AND ppa1.effective_date =   ppa.effective_date
        AND ppa1.report_qualifier = sr.state_code
        AND HOI.organization_id =
            pay_magtape_generic.get_parameter_value('TRANSFER_TRANS_LEGAL_CO_ID')
        AND SR.state_code  =
            pay_magtape_generic.get_parameter_value('TRANSFER_STATE')
       AND HOI.org_information_context = '1099R Magnetic Report Rules'
        AND PPA.report_type = 'YREND'
        AND HOI.ORGANIZATION_ID =
            substr(PPA.legislative_parameters,instr(PPA.legislative_parameters,'TRANSFER_GRE=')+ length('TRANSFER_GRE='))
        AND to_char(PPA.effective_date,'YYYY') =
            pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
        AND to_char(PPA.effective_date,'DD-MM') = '31-12';

--
 -- Sets up the tax unit context for each employer to be reported on NB. sets
 -- up a parameter holding the tax unit identifier which can then be used by
 -- subsequent cursors to restrict to employees within the employer.
 --
 --
       /* Context and Parameter  in the cursor are
           Payroll_action_id table looks for value related to Year End pre-
           processor while the pay_assignment_actions looks for
          assignment actions of Mag. tapes
        Context :
          TAX_UNIT_ID - Submitter's Tax Unit ID
          JURISDICTION_CODE - Set to Dummy Value as This is federal Cursor
          ASSIGNMENT_ID     - Required for call to function - context not used
                              in the for Submitter
          Date Earned       - Always set to Effective date ie. in this case
                              for Mag tapes to 31-DEC-YYYY, in case of SQWL
                              this will be diffrent.
          PAYROLL_ACTION_ID - Payroll action Id of Year End Pre-processor

       Parameters :
          TAX_UNIT_ID  -      To be used in subsequent cusrsor
      */



CURSOR state_1099r_mmref_payer IS
SELECT DISTINCT 'PAYROLL_ACTION_ID=C', ppa.payroll_action_id,
  'TAX_UNIT_ID=C'  , AA.tax_unit_id,
  'TAX_UNIT_ID=P'  , AA.tax_unit_id,
  'TAX_UNIT_NAME=P'  , hou.name,
  'TRANSFER_EMP_CODE=P', 'R'
FROM
     hr_all_organization_units     hou,
     pay_payroll_actions       ppa,
     pay_assignment_actions     AA
WHERE AA.payroll_action_id = pay_magtape_generic.get_parameter_value
                                   ('TRANSFER_PAYROLL_ACTION_ID')
AND   ppa.report_type = 'YREND'
AND to_char(ppa.effective_date,'YYYY') =
           pay_magtape_generic.get_parameter_value('TRANSFER_REPORTING_YEAR')
AND to_char(ppa.effective_date,'DD-MM') = '31-12'
AND   AA.tax_unit_id = substr(ppa.legislative_parameters,instr(ppa.legislative_parameters,'TRANSFER_GRE=') + length('TRANSFER_GRE='))
AND   hou.organization_id  = AA.tax_unit_id
order by hou.name;


 --Sets up the assignment_action_id, assignment_id, and date_earned contexts
 -- for an employee. The date_earned context is set to be the least of the
 -- end of the period being reported and the maximum end date of the
 -- assignment. This ensures that personal information ie. name etc... is
 -- current relative to the period being reported on.
 --
CURSOR state_1099r_mmref_payee IS
SELECT
  'ASSIGNMENT_ACTION_ID=C', AI.locked_action_id, -- YREND assignment action
  'ASSIGNMENT_ID=C', AA.assignment_id,
  'DATE_EARNED=C', fnd_date.date_to_canonical( pay_magtape_generic.date_earned (PA.effective_date, AA.assignment_id)),
  'JURISDICTION_CODE=C',pay_magtape_generic.get_parameter_value('TRANSFER_JD'),
  'YE_ASSIGNMENT_ACTION_ID=P',AI.locked_action_id
FROM  per_all_people_f           PE,
      per_all_assignments_f      SS,
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


/****************************************************************************
Function and Procedures used in the PAY_REPORT_FORMAT_MAPPINGS_F
are defined below.

Range_cursor               - Picks the valid 1099R persons
mag_1099r_action_creation  - Creates Assignment Action id for the Valid
                             person who need to be reported in the 1099R

****************************************************************************/

Procedure get_selection_information (
       p_payroll_action_id  in number,
       p_year_start        out nocopy date,
       p_year_end          out nocopy date,
       p_state_code        out nocopy varchar2,
       p_state_abbrev      out nocopy varchar2,
       p_report_type       out nocopy varchar2,
       p_business_group_id out nocopy number,
       p_tax_unit_id	   out nocopy number,
       p_trans_cont_code   out nocopy varchar2,
       p_yrend_ppa_id      out nocopy number);

Function get_balance_value (
        p_balance_name    in varchar2,
        p_tax_unit_id     in number,
        p_state_abbrev    in varchar2,
        p_assignment_id   in number,
        p_effective_date  in date) RETURN NUMBER;

Function preprocess_check (
        p_payroll_action_id  in number,
        p_year_start         in date,
        p_year_end           in date,
        p_business_group_id  in number,
        p_state_abbrev       in varchar2,
        p_state_code         in varchar2,
        p_report_type        in varchar2,
		p_tax_unit_id 		 in number,
		p_trans_cont_code    in varchar2) RETURN BOOLEAN;

Procedure range_cursor (
         p_payroll_action_id  in number,
         p_sql_string        out nocopy varchar2);

Procedure mag_1099r_action_creation (
      p_payroll_action_id in number,
      p_start_person      in number,
      p_end_person        in number,
      p_chunk             in number);


end pay_us_1099r_mag_reporting;

/
