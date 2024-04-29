--------------------------------------------------------
--  DDL for Package Body PAY_US_DB_PER_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_DB_PER_SETUP" AS
/* $Header: pyusuelt.pkb 115.7 99/07/17 06:47:16 porting ship  $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ****************************************************************** */
/*
 Name        : pay_us_db_per_setup  (BODY)
 Description : This package defines the procedures required to
               create all 'set up' entities in Personnel.
               That is:
                    Business Groups,
                    HR Organizations,
                    Legal Companies,
                    Positions,
                    Jobs         and
                    Grades.
 Change List
 -----------
 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
( History of pesutupd.pkb, ie. db_per_setup :-
 70.0    19-NOV-92 SZWILLIA             Date Created
 70.2    30-DEC-92 SZWILLIA             Added Person Building blocks
 70.3    04-JAN-93 SZWILLIA             create_applicant and private
                                         function insert_application
 70.4    05-JAN-93 SZWILLIA             Correction for applicant
                                         assignments
 70.5    11-JAN-93 SZWILLIA             Corrected date defaulting
 70.6    11-JAN-93 SZWILLIA             Changed interface to create
                                         business group to accept
                                         structure names not numbers
 70.9    20-JAN-93 SZWILLIA             Corrected error handling.
 70.12   09-MAR-93 SZWILLIA             Made insert_org_information
                                         public and added error checking.
 70.13   11-MAR-93 NKHAN                Added 'exit' to the end          )

*** AUG-93 us_pesutupd.pkb created, ie. copied from pesutupd.pkb ***
 40.1    ??-AUG-93 MSWANSON             Date us_pesutupd.pkb created, ie.
                                        copied from pesutupd.pkb and
                                        altered for US testing.
 40.2    20-AUG-93 RMAMGAIN             Modified Create_business_group
                                        Commented some stuff.
                                        Added more insert in Leg. Company.
 40.3    08-APR-94 AKELLY               Added insert of 'Federal Tax Rules'
                                        'State Tax Rules' and 'Work Schedule'
                                        ddf info. for legal company.
****
 40.0    31-MAY-94 MGILMORE   Renamed.
 40.1    03-JUL-94 AROUSSEL   Tidyied up for 10G install
 40.2    05-OCT-94 RFINE      Changed calls from us_ins_org_info to
                              pay_us_ins_org_info_pkg
 40.3    24-NOV-94 RFINE      Suppressed index on business_group_id
 40.4    01-MAR-95 MSWANSON   Add/Change for EEO and VETS100 system
			      test data creation:
				- create_est_organization,
				- create_eeo_hierarchy,
			        - create_eeo_hierarchy_version,
			        - create_eeo_hierarchy_element.
 40.5	25-JUL-95  AMILLS     Changed tokenised message 'PAY_6361_USER_
			      TABLE_UNIQUE' for the following (Hard coded):
			      'PAY_7687_USER_GRADE_TAB_UNIQUE',
			      'PAY_7688_USER_POS_TAB_UNIQUE',
			      'PAY_7686_USER_JOB_TAB_UNIQUE'
 40.6   26-sep-95  AKELLY     corrected create_est_organizatioN
 40.7	28-SEP-95  AKELLY     Added functions INSERT_WC_FUND, INSERT_WC_RATE,
			      CREATE_WC_CARRIER and CREATE_US_LOCATION.
 40.9   01-NOV-95  JTHURING   Removed error checking from end of script
 110.2	11-SEP-97  khabibul   added suffix _vl to fnd_id_flex_structures as
 			      id_flex_structure_name col is obsolete.
 110.3  19-JAN-99  nbristow   insert into hr_all_organization_units rather
                              than hr_organization_units.
 115.2  24-MAR-99  sdoshi     Flexible Dates Conversion.
 115.3  24-MAR-99  alogue     MLS changes.
 115.4  14-May-1999 mmillmor  multi radix change to working_hours on position
================================================================= */
--
--
 FUNCTION  insert_organization_unit
  ( P_GROUP                           VARCHAR2
   ,P_NAME                            VARCHAR2
   ,P_BUSINESS_GROUP_ID               NUMBER
   ,P_COST_ALLOCATION_KEYFLEX_ID      NUMBER
   ,P_LOCATION_ID                     NUMBER
   ,P_SOFT_CODING_KEYFLEX_ID          NUMBER
   ,P_DATE_FROM                       DATE
   ,P_DATE_TO                         DATE
   ,P_INTERNAL_EXTERNAL_FLAG          VARCHAR2
   ,P_INTERNAL_ADDRESS_LINE           VARCHAR2
   ,P_TYPE                            VARCHAR2
  ) return NUMBER
  IS
--
  l_organization_id NUMBER;
  language     VARCHAR2(4);
--
CURSOR get_languages IS
SELECT language_code
from fnd_languages
where installed_flag in ('I','B');
--
begin
--
  if p_group = 'Y' then null;
  elsif p_business_group_id IS NULL then
        hr_utility.set_message(801,'HR_MANDATORY_PARAMETER');
        hr_utility.set_message_token('PARAMETER_NAME','Business Group');
        hr_utility.raise_error;
  end if;
--
  hr_utility.set_location('pay_us_db_per_setup.insert_organization_unit',1);
--
  SELECT hr_organization_units_s.nextval
  INTO   l_organization_id
  FROM   sys.dual ;
--
  hr_organization.unique_name(p_business_group_id,l_organization_id,p_name);
--
--
  hr_organization.date_range(nvl(p_date_from,trunc(SYSDATE)),p_date_to);
--
--
  hr_utility.set_location('pay_us_db_per_setup.insert_organization_unit',2);
--
  INSERT INTO HR_ALL_ORGANIZATION_UNITS
  (organization_id
  ,business_group_id
  ,cost_allocation_keyflex_id
  ,location_id
  ,soft_coding_keyflex_id
  ,date_from
  ,name
  ,date_to
  ,internal_external_flag
  ,internal_address_line
  ,type
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,created_by
  ,creation_date)
  SELECT l_organization_id
  ,DECODE(p_group,'Y',l_organization_id,p_business_group_id)
  ,p_cost_allocation_keyflex_id
  ,p_location_id
  ,p_soft_coding_keyflex_id
  ,nvl(p_date_from,trunc(SYSDATE))
  ,p_name
  ,p_date_to
  ,p_internal_external_flag
  ,p_internal_address_line
  ,p_type
  ,SYSDATE
  ,0
  ,0
  ,0
  ,SYSDATE
  FROM sys.dual ;
--
  hr_utility.set_location('pay_us_db_per_setup.insert_organization_unit',3);
--
  OPEN get_languages;
--
  LOOP
--
     FETCH get_languages
     INTO language;
     EXIT WHEN get_languages%NOTFOUND;
--
     INSERT INTO HR_ALL_ORGANIZATION_UNITS_TL
     (organization_id
     ,language
     ,source_lang
     ,name
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,created_by
     ,creation_date)
     SELECT l_organization_id
     ,language
     ,userenv('LANG')
     ,p_name
     ,SYSDATE
     ,0
     ,0
     ,0
     ,SYSDATE
     FROM sys.dual ;
--
  END LOOP;
--
  hr_utility.set_location('pay_us_db_per_setup.insert_organization_unit',4);
--
  return l_organization_id;
--
--
 end insert_organization_unit;
--
--
 FUNCTION  create_business_group
  ( P_GROUP                           VARCHAR2  DEFAULT 'Y'
   ,P_NAME                            VARCHAR2
   ,P_DATE_FROM                       DATE
   ,P_DATE_TO                         DATE      DEFAULT null
   ,P_INTERNAL_ADDRESS_LINE           VARCHAR2  DEFAULT null
   ,P_DEFAULT_START_TIME              VARCHAR2  DEFAULT '08:00'
   ,P_DEFAULT_END_TIME                VARCHAR2  DEFAULT '17:30'
   ,P_WORKING_HOURS                   VARCHAR2  DEFAULT '37.5'
   ,P_FREQUENCY                       VARCHAR2  DEFAULT 'W'
   ,P_SHORT_NAME                      VARCHAR2
   ,P_METHOD_OF_GENERATION_EMP_NUM    VARCHAR2  DEFAULT 'A'
   ,P_METHOD_OF_GENERATION_APL_NUM    VARCHAR2  DEFAULT 'A'
   ,P_GRADE_STRUCTURE                 VARCHAR2  DEFAULT 'Grade Flexfield'
   ,P_PEOPLE_GROUP_STRUCTURE          VARCHAR2
                                        DEFAULT 'People Group Flexfield'
   ,P_JOB_STRUCTURE                   VARCHAR2  DEFAULT 'Job Flexfield'
   ,P_COST_ALLOCATION_STRUCTURE       VARCHAR2
                                        DEFAULT 'Cost Allocation Flexfield'
   ,P_POSITION_STRUCTURE              VARCHAR2  DEFAULT 'Position Flexfield'
   ,P_LEGISLATION_CODE                VARCHAR2  DEFAULT 'US'
   ,P_CURRENCY_CODE                   VARCHAR2  DEFAULT 'USD'
   ,P_FISCAL_YEAR_START               VARCHAR2  DEFAULT null
   ,P_ASSIGNMENT_STATUS_1             VARCHAR2  DEFAULT null
   ,P_ASSIGNMENT_STATUS_2             VARCHAR2  DEFAULT null
   ,P_EMPLOYMENT_CATEGORY_1	      VARCHAR2  DEFAULT null
   ,P_EMPLOYMENT_CATEGORY_2	      VARCHAR2  DEFAULT null
  ) return NUMBER
  IS
--
  l_business_group_id   NUMBER;
  l_org_information_id  NUMBER;
  l_position_num        NUMBER;
  l_grade_num           NUMBER;
  l_job_num             NUMBER;
  l_people_group_num    NUMBER;
  l_cost_allocation_num NUMBER;
--
  begin
--
--
  hr_utility.set_location('pay_us_db_per_setup.create_business_group',1);
  SELECT id_flex_num
  INTO   l_position_num
  FROM   fnd_id_flex_structures_vl
  WHERE  id_flex_code = 'POS'
  AND    id_flex_structure_name = p_position_structure;
--
  hr_utility.set_location('pay_us_db_per_setup.create_business_group',2);
  SELECT id_flex_num
  INTO   l_grade_num
  FROM   fnd_id_flex_structures_vl
  WHERE  id_flex_code = 'GRD'
  AND    id_flex_structure_name = p_grade_structure;
--
  hr_utility.set_location('pay_us_db_per_setup.create_business_group',3);
  SELECT id_flex_num
  INTO   l_job_num
  FROM   fnd_id_flex_structures_vl
  WHERE  id_flex_code = 'JOB'
  AND    id_flex_structure_name = p_job_structure;
--
  hr_utility.set_location('pay_us_db_per_setup.create_business_group',4);
  SELECT id_flex_num
  INTO   l_people_group_num
  FROM   fnd_id_flex_structures_vl
  WHERE  id_flex_code = 'GRP'
  AND    id_flex_structure_name = p_people_group_structure;
--
  hr_utility.set_location('pay_us_db_per_setup.create_business_group',5);
  SELECT id_flex_num
  INTO   l_cost_allocation_num
  FROM   fnd_id_flex_structures_vl
  WHERE  id_flex_code = 'COST'
  AND    id_flex_structure_name = p_cost_allocation_structure;
--
  hr_utility.set_location('pay_us_db_per_setup.create_business_group',6);
  l_business_group_id := insert_organization_unit('Y'
                                                 ,p_name
                                                 ,null
                                                 ,null
                                                 ,null
                                                 ,null
                                                 ,p_date_from
                                                 ,p_date_to
                                                 ,'INT'
                                                 ,p_internal_address_line
                                                 ,null);
--
--
  hr_utility.set_location('pay_us_db_per_setup.create_business_group',7);
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                                                 l_business_group_id
                                                ,'CLASS'
                                                ,'HR_BG'
                                                ,'Y'
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
--
--
  hr_utility.set_location('pay_us_db_per_setup.create_business_group',8);
   l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                                                l_business_group_id
                                               ,'CLASS'
                                               ,'HR_ORG'
                                               ,'Y'
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null);
--
--
  hr_utility.set_location('pay_us_db_per_setup.create_business_group',9);
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                                                 l_business_group_id
                                                ,'Business Group Information'
                                                ,p_short_name
                                                ,p_method_of_generation_emp_num
                                                ,p_method_of_generation_apl_num
                                                ,l_grade_num
                                                ,l_people_group_num
                                                ,l_job_num
                                                ,l_cost_allocation_num
                                                ,l_position_num
                                                ,p_legislation_code
                                                ,p_currency_code
                                                ,p_fiscal_year_start
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
--
--
  hr_utility.set_location('pay_us_db_per_setup.create_business_group',10);
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                                                 l_business_group_id
                                                ,'Work Day Information'
                                                ,p_default_start_time
                                                ,p_default_end_time
                                                ,p_working_hours
                                                ,p_frequency
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
--
-- Reporting Categories and Reporting Statuses are for use in VETS-100
-- System Test
--
  hr_utility.set_location('pay_us_db_per_setup.create_business_group',11);
--
if p_employment_category_1 is not null then
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                                                 l_business_group_id
                                                ,'Reporting Categories'
                                                ,p_employment_category_1
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
end if;
--
--
  hr_utility.set_location('pay_us_db_per_setup.create_business_group',12);
if p_employment_category_2 is not null then
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                                                 l_business_group_id
                                                ,'Reporting Categories'
                                                ,p_employment_category_2
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
end if;
--
--
  hr_utility.set_location('pay_us_db_per_setup.create_business_group',13);
if p_assignment_status_1 is not null then
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                                                 l_business_group_id
                                                ,'Reporting Statuses'
                                                ,p_assignment_status_1
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
end if;
--
--
  hr_utility.set_location('pay_us_db_per_setup.create_business_group',14);
if p_assignment_status_2 is not null then
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                                                 l_business_group_id
                                                ,'Reporting Statuses'
                                                ,p_assignment_status_2
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
end if;
--
--
  return l_business_group_id;
--
--
 end create_business_group;
--
--
 FUNCTION  create_per_organization
  ( P_NAME                            VARCHAR2
   ,P_BUSINESS_GROUP                  VARCHAR2
   ,P_DATE_FROM                       DATE
   ,P_DATE_TO                         DATE      DEFAULT null
   ,P_INTERNAL_ADDRESS_LINE           VARCHAR2  DEFAULT null
   ,P_DEFAULT_START_TIME              VARCHAR2  DEFAULT '08:00'
   ,P_DEFAULT_END_TIME                VARCHAR2  DEFAULT '17:30'
   ,P_WORKING_HOURS                   VARCHAR2  DEFAULT '37.5'
   ,P_FREQUENCY                       VARCHAR2  DEFAULT 'W'
   ,P_INTERNAL_EXTERNAL_FLAG          VARCHAR2  DEFAULT 'INT'
   ,P_TYPE                            VARCHAR2  DEFAULT null
   ,P_LOCATION_ID                     NUMBER    DEFAULT null
  ) return NUMBER
  IS
--
  l_organization_id    NUMBER;
  l_org_information_id NUMBER;
  l_business_group_id  NUMBER;
--
  begin
--
--
hr_utility.trace('Entered Create_Per_Organization ');
  hr_utility.set_location('pay_us_db_per_setup.create_per_organization',1);
--
  SELECT business_group_id
  INTO   l_business_group_id
  FROM   per_business_groups
  WHERE  name = p_business_group;
--
  l_organization_id  := insert_organization_unit('N'
                                                 ,p_name
                                                 ,l_business_group_id
                                                 ,null
                                                 ,p_location_id
                                                 ,null
                                                 ,p_date_from
                                                 ,p_date_to
                                                 ,p_internal_external_flag
                                                 ,p_internal_address_line
                                                 ,p_type);
hr_utility.trace('Called insert_information_unit from CPO');
--
--
--
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(l_organization_id
                                                ,'CLASS'
                                                ,'HR_ORG'
                                                ,'Y'
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
hr_utility.trace('Called insert_org_information once from CPO');
--
--
--
hr_utility.trace('p_default_start_time '||p_default_start_time);

  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(l_organization_id
                                                ,'Work Day Information'
                                                ,p_default_start_time
                                                ,p_default_end_time
                                                ,p_working_hours
                                                ,p_frequency
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
hr_utility.trace('Called insert_org_information twice from CPO');
--
  return l_organization_id;
--
 end create_per_organization;
--
--
-- Creates an organization which is an Establishment Only (ie. not a GRE too)
--
--
 FUNCTION  create_est_organization
  ( P_NAME                            VARCHAR2
   ,P_BUSINESS_GROUP                  VARCHAR2
   ,P_DATE_FROM                       DATE
   ,P_DATE_TO                         DATE      DEFAULT null
   ,P_INTERNAL_ADDRESS_LINE           VARCHAR2  DEFAULT null
   ,P_INTERNAL_EXTERNAL_FLAG          VARCHAR2  DEFAULT 'INT'
   ,P_TYPE                            VARCHAR2  DEFAULT null
   ,P_LOCATION_ID                     NUMBER    DEFAULT null
   ,P_EEO1_UNIT_NUMBER			NUMBER    DEFAULT null
   ,P_VETS100_UNIT_NUMBER			NUMBER    DEFAULT null
   ,P_REPORTING_NAME			VARCHAR2  DEFAULT null
   ,P_VETS100_REPORTING_NAME			VARCHAR2  DEFAULT null
   ,P_SIC				NUMBER    DEFAULT null
   ,P_ACTIVITY_LINE1			VARCHAR2  DEFAULT null
   ,P_ACTIVITY_LINE2			VARCHAR2  DEFAULT null
   ,P_ACTIVITY_LINE3			VARCHAR2  DEFAULT null
   ,P_ACTIVITY_LINE4			VARCHAR2  DEFAULT null
   ,P_APPRENTICES_EMPLOYED		VARCHAR2  DEFAULT null

  ) return NUMBER
  IS
--
  l_organization_id    NUMBER;
  l_org_information_id NUMBER;
  l_business_group_id  NUMBER;
--
  begin
--
--
hr_utility.trace('Entered Create_Est_Organization ');
  hr_utility.set_location('pay_us_db_per_setup.create_per_organization',1);
--
  SELECT business_group_id
  INTO   l_business_group_id
  FROM   per_business_groups
  WHERE  name = p_business_group;
--
  l_organization_id  := insert_organization_unit('N'
                                                 ,p_name
                                                 ,l_business_group_id
                                                 ,null
                                                 ,p_location_id
                                                 ,null
                                                 ,p_date_from
                                                 ,p_date_to
                                                 ,p_internal_external_flag
                                                 ,p_internal_address_line
                                                 ,p_type);
hr_utility.trace('Called insert_information_unit from CEO');
--
-- Add new classification : HR_ESTAB
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                                                 l_organization_id
                                                ,'CLASS'
                                                ,'HR_ESTAB'
                                                ,'Y'
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
--
--
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information
                                                (l_organization_id
                                                ,'CLASS'
                                                ,'HR_ORG'
                                                ,'Y'
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
hr_utility.trace('Called insert_org_information once from CEO');
--
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information
                                                (l_organization_id
                                                ,'Establishment EEO-1 Filing'
                                                ,'Y'
                                                ,p_eeo1_unit_number
                                                ,p_reporting_name
                                                ,p_sic
                                                ,p_activity_line1
                                                ,p_activity_line2
                                                ,p_activity_line3
                                                ,p_activity_line4
                                                ,null
                                                ,p_apprentices_employed
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
if p_vets100_unit_number is not null then
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information
                                                (l_organization_id
                                                ,'Establishment VETS-100 Filing'
                                                ,p_vets100_unit_number
                                                ,p_vets100_reporting_name
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,p_apprentices_employed
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
end if;
--
  return l_organization_id;
--
 end create_est_organization;
--
--
 FUNCTION  create_pay_legal_company
  ( P_NAME                            VARCHAR2
   ,P_BUSINESS_GROUP                  VARCHAR2
   ,P_DATE_FROM                       DATE
   ,P_DATE_TO                         DATE      DEFAULT null
   ,P_INTERNAL_ADDRESS_LINE           VARCHAR2  DEFAULT null
   ,P_LOCATION_ID                     NUMBER    DEFAULT null
   ,P_COMPANY_FEDERAL_IDENTIFIER      VARCHAR2  DEFAULT null
   ,P_NACHA_COMPANY_NAME              VARCHAR2  DEFAULT null
   ,P_NACHA_IDENTIFIER                VARCHAR2  DEFAULT null
   ,P_NACHA_DISCRETIONARY_CODE        VARCHAR2  DEFAULT null
   ,P_SS_SELF_ADJUST_METHOD           VARCHAR2  DEFAULT null
   ,P_MED_SELF_ADJUST_METHOD          VARCHAR2  DEFAULT null
   ,P_FUTA_SELF_ADJUST_METHOD         VARCHAR2  DEFAULT null
   ,P_TYPE_OF_EMPLOYMENT              VARCHAR2  DEFAULT null
   ,P_TAX_GROUP                       VARCHAR2  DEFAULT null
   ,P_SUPPLEMENTAL_CALC_METHOD        VARCHAR2  DEFAULT null
   ,P_WORK_SCHEDULE_TABLE            VARCHAR2  DEFAULT 'COMPANY WORK SCHEDULES'
   ,P_WORK_SCHEDULE_NAME              VARCHAR2  DEFAULT null
   ,P_EEO1_UNIT_NUMBER                     VARCHAR2  DEFAULT null
   ,P_VETS100_UNIT_NUMBER			NUMBER    DEFAULT null
   ,P_REPORTING_NAME                  VARCHAR2  DEFAULT null
   ,P_VETS100_REPORTING_NAME                  VARCHAR2  DEFAULT null
   ,P_SIC                             VARCHAR2  DEFAULT null
   ,P_ACTIVITY_LINE1                  VARCHAR2  DEFAULT null
   ,P_ACTIVITY_LINE2                  VARCHAR2  DEFAULT null
   ,P_ACTIVITY_LINE3                  VARCHAR2  DEFAULT null
   ,P_ACTIVITY_LINE4                  VARCHAR2  DEFAULT null
   ,P_APPRENTICES_EMPLOYED            VARCHAR2  DEFAULT null
   ,P_EEO1_IDENTIFICATION_NUMBER      VARCHAR2  DEFAULT null
   ,P_VETS100_COMPANY_NUMBER          VARCHAR2  DEFAULT null
   ,P_DUN_AND_BRADSTREET_NUMBER       VARCHAR2  DEFAULT null
   ,P_GRE_REPORTING_NAME              VARCHAR2  DEFAULT null
   ,P_AFFILIATED                      VARCHAR2  DEFAULT null
   ,P_GOVERNMENT_CONTRACTOR           VARCHAR2  DEFAULT null
   ,P_ORG_TYPE	                      VARCHAR2  DEFAULT null
  ) return NUMBER
  IS
--
  l_legal_company_id   NUMBER;
  l_org_information_id NUMBER;
  l_business_group_id  NUMBER;
--
  begin
--
  hr_utility.set_location('pay_us_db_per_setup.create_pay_legal_company',1);
--
  SELECT business_group_id
  INTO   l_business_group_id
  FROM   hr_all_organization_units
  WHERE  name = p_business_group
  and    business_group_id + 0 = organization_id;
--
  l_legal_company_id := insert_organization_unit('N'
                                                 ,p_name
                                                 ,l_business_group_id
                                                 ,null
                                                 ,p_location_id
                                                 ,null
                                                 ,p_date_from
                                                 ,p_date_to
                                                 ,'INT'
                                                 ,p_internal_address_line
                                                 ,p_org_type);
--
--
--
  hr_utility.set_location('pay_us_db_per_setup.create_pay_legal_company',2);
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                                                 l_legal_company_id
                                                ,'CLASS'
                                                ,'HR_ORG'
                                                ,'Y'
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
--
--
--
  hr_utility.set_location('pay_us_db_per_setup.create_pay_legal_company',3);
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                                                 l_legal_company_id
                                                ,'CLASS'
                                                ,'HR_LEGAL'
                                                ,'Y'
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
--
--
if P_NAME = 'Swanson I.T.' then
--
-- Add new classification : HR_ESTAB this org is a GRE/EST combo
--
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                                                 l_legal_company_id
                                                ,'CLASS'
                                                ,'HR_ESTAB'
                                                ,'Y'
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
--
       l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                           l_legal_company_id
                           ,'Establishment EEO-1 Filing' -- context
                           ,null     -- used to be Establishment flag
                           ,P_EEO1_UNIT_NUMBER
                           ,P_REPORTING_NAME
                           ,P_SIC
                           ,P_ACTIVITY_LINE1
                           ,P_ACTIVITY_LINE2
                           ,P_ACTIVITY_LINE3
                           ,P_ACTIVITY_LINE4
                           ,P_APPRENTICES_EMPLOYED
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null);
-- Enter row for VETS-100
       l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                           l_legal_company_id
                           ,'Establishment VETS-100 Filing' -- context
                           ,P_VETS100_UNIT_NUMBER
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null);
   end if;
--
-- Modified RMAMGAIN
-- Modified MSWANSON 'Nacha' to 'NACHA'.
  hr_utility.set_location('pay_us_db_per_setup.create_pay_legal_company',4);
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                                                 l_legal_company_id
                                                ,'NACHA Rules'
                                                ,P_NACHA_COMPANY_NAME
                                                ,'220'
                                                ,'PPD'
                                                ,P_NACHA_IDENTIFIER
                                                ,P_NACHA_DISCRETIONARY_CODE
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
--
-- Inserted by RMAMGAIN
   hr_utility.set_location('pay_us_db_per_setup.create_pay_legal_company',5);
   l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                               l_legal_company_id
                              ,'Multiple Worksite Reporting' -- context
                                          ,'Y' -- transmitter_flag
                            ,'Contact Person1' -- position
                            ,'415-506-7000'    -- telephone
                                       ,'2807' -- extension
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null);
-- Inserted By RMAMGAIN
   hr_utility.set_location('pay_us_db_per_setup.create_pay_legal_company',6);
   l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                           l_legal_company_id
                         ,'W2 Reporting Rules' -- context
                                          ,'Y' -- transmitter_flag
                                    ,'SEQUENT' -- computer
                                         ,'SL' -- internal_labelling
                                         ,'16' -- tape_density
                                        ,'ASC' -- tape_rec_code
                                        ,'512' -- blocking_factor
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null
                                               ,null);
-- Inserted by RMAMGAIN
   hr_utility.set_location('pay_us_db_per_setup.create_pay_legal_company',7);
   l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                           l_legal_company_id
                           ,'Employer Identification' -- context
                           ,P_COMPANY_FEDERAL_IDENTIFIER
                           ,P_COMPANY_FEDERAL_IDENTIFIER
                           ,P_NAME
                           ,'POSITION'
                           ,'415-506-7000'
                           ,'512'
                           ,fnd_number.canonical_to_number(l_legal_company_id)
                           ,'Address'
                           ,'Regular'
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null);
-- Inserted by AKELLY
   hr_utility.set_location('pay_us_db_per_setup.create_pay_legal_company',8);
   l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                             l_legal_company_id
                             ,'Work Schedule'  -- context
                             ,P_WORK_SCHEDULE_TABLE
                             ,P_WORK_SCHEDULE_TABLE
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null);
-- Inserted by AKELLY
   hr_utility.set_location('pay_us_db_per_setup.create_pay_legal_company',9);
   if P_SS_SELF_ADJUST_METHOD IS NULL
      and P_MED_SELF_ADJUST_METHOD IS NULL
      and P_FUTA_SELF_ADJUST_METHOD IS NULL
      and P_TYPE_OF_EMPLOYMENT IS NULL
      and P_TAX_GROUP IS NULL
      and P_SUPPLEMENTAL_CALC_METHOD IS NULL then
       null;
   else
       l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                           l_legal_company_id
                           ,'Federal Tax Rules' -- context
                           ,P_SS_SELF_ADJUST_METHOD
                           ,P_MED_SELF_ADJUST_METHOD
                           ,P_FUTA_SELF_ADJUST_METHOD
                           ,P_TYPE_OF_EMPLOYMENT
                           ,P_TAX_GROUP
                           ,P_SUPPLEMENTAL_CALC_METHOD
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null);
   end if;
--
-- Inserted by MSWANSON
   hr_utility.set_location('pay_us_db_per_setup.create_pay_legal_company',10);
--
-- Inserted by MSWANSON
   hr_utility.set_location('pay_us_db_per_setup.create_pay_legal_company',10);
       l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                           l_legal_company_id
                           ,'EEO-1 Filing' -- context
                           ,P_EEO1_IDENTIFICATION_NUMBER
                           ,P_DUN_AND_BRADSTREET_NUMBER
                           ,P_GRE_REPORTING_NAME
                           ,P_AFFILIATED
                           ,P_GOVERNMENT_CONTRACTOR
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null);
--
-- Add data for VETS-100
--
       l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                           l_legal_company_id
                           ,'VETS-100 Filing' -- context
                           ,P_VETS100_COMPANY_NUMBER
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null
                           ,null);
--
  return l_legal_company_id;
--
  end create_pay_legal_company;
--
--
-- Create EEO Reporting Hierarchies
--
--
FUNCTION create_eeo_hierarchy
  (p_hierarchy_name               VARCHAR2
  ,p_business_group_id            NUMBER
  ,p_primary_structure_flag       VARCHAR2
  ) RETURN NUMBER
IS
--
l_organization_structure_id  NUMBER;
--
begin
--
SELECT per_org_structure_versions_s.nextval
INTO   l_organization_structure_id
FROM   sys.dual;
--
INSERT INTO per_organization_structures
  (organization_structure_id
  ,business_group_id
  ,name
  ,primary_structure_flag
  )
VALUES
  (l_organization_structure_id
  ,p_business_group_id
  ,p_hierarchy_name
  ,p_primary_structure_flag
  );
--
return l_organization_structure_id;
end create_eeo_hierarchy;
--
--
FUNCTION create_eeo_hierarchy_version
  (p_business_group_id          NUMBER
  ,p_date_from                    VARCHAR2
  ,p_organization_structure_id    NUMBER
  ,p_version_number               NUMBER
  ) return NUMBER
IS
--
l_org_structure_version_id   NUMBER;
--
begin
--
--
SELECT per_org_structure_versions_s.nextval
INTO   l_org_structure_version_id
FROM   sys.dual;
--
--
INSERT INTO per_org_structure_versions
  (org_structure_version_id
  ,business_group_id
  ,organization_structure_id
  ,date_from
  ,version_number
  )
VALUES
  (l_org_structure_version_id
  ,p_business_group_id
  ,p_organization_structure_id
  ,fnd_date.canonical_to_date(p_date_from)
  ,p_version_number
  );
--
return l_org_structure_version_id;
end create_eeo_hierarchy_version;
--
--
FUNCTION create_eeo_hierarchy_element
  (p_business_group_id        NUMBER
  ,p_organization_id_parent   NUMBER
  ,p_org_structure_version_id NUMBER
  ,p_organization_id_child    NUMBER
  ) RETURN NUMBER
IS
--
--
begin
--
--
INSERT INTO per_org_structure_elements
  (org_structure_element_id
  ,business_group_id
  ,organization_id_parent
  ,org_structure_version_id
  ,organization_id_child
  )
VALUES
  (per_org_structure_elements_s.nextval
  ,p_business_group_id
  ,p_organization_id_parent
  ,p_org_structure_version_id
  ,p_organization_id_child
  );
--
return(1);
end create_eeo_hierarchy_element;
--
--
--
--
-- create_company_state_rules added by AKELLY
--
PROCEDURE create_company_state_rules
  (p_legal_company_id             IN NUMBER
  ,p_state_code                   IN VARCHAR2
  ,p_sui_company_state_id         IN VARCHAR2
  ,p_sit_company_state_id         IN VARCHAR2
  ,p_sui_self_adjust_method       IN VARCHAR2 DEFAULT null
  ,p_sdi_self_adjust_method       IN VARCHAR2 DEFAULT null
  ,p_sui_er_experience_rate_1     IN VARCHAR2 DEFAULT null
  ,p_sui_er_experience_rate_2     IN VARCHAR2 DEFAULT null
  ,p_wc_carrier_name              IN VARCHAR2 DEFAULT null
  ,p_employers_liability_rate     IN VARCHAR2 DEFAULT null
  ,p_experience_modification_rate IN VARCHAR2 DEFAULT null
  ,p_premium_discount_rate        IN VARCHAR2 DEFAULT null
  )
  IS
  l_org_information_id NUMBER;
--
  begin
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information(
                              p_legal_company_id
                             ,'State Tax Rules'  -- context
                             ,p_state_code
                             ,p_sui_company_state_id
                             ,p_sit_company_state_id
                             ,p_sui_self_adjust_method
                             ,p_sdi_self_adjust_method
                             ,p_sui_er_experience_rate_1
                             ,p_sui_er_experience_rate_2
                             ,p_wc_carrier_name
                             ,p_employers_liability_rate
                             ,p_experience_modification_rate
                             ,p_premium_discount_rate
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null
                             ,null);
  end create_company_state_rules;
--
--
FUNCTION create_job
  (p_default                VARCHAR2  DEFAULT 'Y'
  ,p_name                   VARCHAR2
  ,p_business_group         VARCHAR2
  ,p_date_from              DATE
  ,p_date_to                DATE      DEFAULT null
  ,p_segment1               VARCHAR2  DEFAULT null
  ,p_segment2               VARCHAR2  DEFAULT null
  ,p_segment3               VARCHAR2  DEFAULT null
  ,p_segment4               VARCHAR2  DEFAULT null
  ,p_segment5               VARCHAR2  DEFAULT null
  ,p_segment6               VARCHAR2  DEFAULT null
  ,p_segment7               VARCHAR2  DEFAULT null
  ,p_segment8               VARCHAR2  DEFAULT null
  ,p_segment9               VARCHAR2  DEFAULT null
  ,p_segment10              VARCHAR2  DEFAULT null
  ,p_segment11              VARCHAR2  DEFAULT null
  ,p_segment12              VARCHAR2  DEFAULT null
  ,p_segment13              VARCHAR2  DEFAULT null
  ,p_segment14              VARCHAR2  DEFAULT null
  ,p_segment15              VARCHAR2  DEFAULT null
  ,p_segment16              VARCHAR2  DEFAULT null
  ,p_segment17              VARCHAR2  DEFAULT null
  ,p_segment18              VARCHAR2  DEFAULT null
  ,p_segment19              VARCHAR2  DEFAULT null
  ,p_segment20              VARCHAR2  DEFAULT null
  ,p_segment21              VARCHAR2  DEFAULT null
  ,p_segment22              VARCHAR2  DEFAULT null
  ,p_segment23              VARCHAR2  DEFAULT null
  ,p_segment24              VARCHAR2  DEFAULT null
  ,p_segment25              VARCHAR2  DEFAULT null
  ,p_segment26              VARCHAR2  DEFAULT null
  ,p_segment27              VARCHAR2  DEFAULT null
  ,p_segment28              VARCHAR2  DEFAULT null
  ,p_segment29              VARCHAR2  DEFAULT null
  ,p_segment30              VARCHAR2  DEFAULT null
  ,p_context                VARCHAR2  DEFAULT null
  ,p_eeo_category           VARCHAR2  DEFAULT null
  ) return NUMBER
  --
  IS
  --
  -- local variables for create_job
     --
     l_job_id       NUMBER;
     l_business_group_id NUMBER;
     l_structure_num     NUMBER;
     l_segment1          VARCHAR2(60);
     l_job_definition_id  NUMBER;
     --
  --
  PROCEDURE unique_name
  (p_business_group_id NUMBER, p_job_id VARCHAR2, p_job_name VARCHAR2)
  IS
  --
    job_check VARCHAR2(1);
  --
  begin
  --
  --
    SELECT 'Y'
    INTO   job_check
    FROM   per_jobs jb
    WHERE (jb.job_id <> p_job_id
       OR  p_job_id IS NULL)
    AND    p_job_name  = jb.name
     AND   p_business_group_id = jb.business_group_id + 0;
  --
    if job_check = 'Y' then
     hr_utility.set_message(801,'PAY_7686_USER_JOB_TAB_UNIQUE');
     hr_utility.raise_error;
    end if;
  --
    exception
     when NO_DATA_FOUND then null ;
  --
  --
  end unique_name;
  --
  FUNCTION insert_job_definition return NUMBER IS
  --
  l_job_definition_id NUMBER;
  --
    begin
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_job_definition',1);
  --
    SELECT per_job_definitions_s.nextval
    INTO   l_job_definition_id
    FROM   sys.dual;
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_job_definition',2);
  --
    INSERT INTO per_job_definitions
    (JOB_DEFINITION_ID
    ,ID_FLEX_NUM
    ,SUMMARY_FLAG
    ,ENABLED_FLAG
    ,START_DATE_ACTIVE
    ,END_DATE_ACTIVE
    ,SEGMENT1
    ,SEGMENT2
    ,SEGMENT3
    ,SEGMENT4
    ,SEGMENT5
    ,SEGMENT6
    ,SEGMENT7
    ,SEGMENT8
    ,SEGMENT9
    ,SEGMENT10
    ,SEGMENT11
    ,SEGMENT12
    ,SEGMENT13
    ,SEGMENT14
    ,SEGMENT15
    ,SEGMENT16
    ,SEGMENT17
    ,SEGMENT18
    ,SEGMENT19
    ,SEGMENT20
    ,SEGMENT21
    ,SEGMENT22
    ,SEGMENT23
    ,SEGMENT24
    ,SEGMENT25
    ,SEGMENT26
    ,SEGMENT27
    ,SEGMENT28
    ,SEGMENT29
    ,SEGMENT30)
   values
   (l_job_definition_id
   ,l_structure_num
   ,'Y'
   ,'N'
   ,fnd_date.canonical_to_date(fnd_date.date_to_canonical(p_date_from))
   ,fnd_date.canonical_to_date(fnd_date.date_to_canonical(p_date_to))
   ,l_segment1                               -- p_name for default jobs
   ,p_segment2
   ,p_segment3
   ,p_segment4
   ,p_segment5
   ,p_segment6
   ,p_segment7
   ,p_segment8
   ,p_segment9
   ,p_segment10
   ,p_segment11
   ,p_segment12
   ,p_segment13
   ,p_segment14
   ,p_segment15
   ,p_segment16
   ,p_segment17
   ,p_segment18
   ,p_segment19
   ,p_segment20
   ,p_segment21
   ,p_segment22
   ,p_segment23
   ,p_segment24
   ,p_segment25
   ,p_segment26
   ,p_segment27
   ,p_segment28
   ,p_segment29
   ,p_segment30
  );
  --
  --
    return l_job_definition_id;
  --
  end insert_job_definition;
  --
  --
  FUNCTION  insert_job RETURN NUMBER IS
  --
    l_job_id NUMBER;
  --
    begin
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_job',1);
  --
    SELECT per_jobs_s.nextval
    INTO   l_job_id
    FROM   sys.dual;
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_job',2);
  --
    unique_name(l_business_group_id,l_job_id, p_name);
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_job',3);
  --
    INSERT INTO per_jobs
    (JOB_ID
    ,BUSINESS_GROUP_ID
    ,JOB_DEFINITION_ID
    ,DATE_FROM
    ,DATE_TO
    ,NAME
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_LOGIN
    ,CREATED_BY
    ,CREATION_DATE
    ,JOB_INFORMATION_CATEGORY
    ,JOB_INFORMATION1
    )
    values
    (l_job_id
    ,l_business_group_id
    ,l_job_definition_id
    ,p_date_from
    ,p_date_to
    ,p_name
    ,SYSDATE
    ,0
    ,0
    ,0
    ,SYSDATE
    ,p_context
    ,p_eeo_category
    );
  --
  --
    return l_job_id;
  --
    end insert_job;
  --
  begin  -- FUNCTION create_job
  --
  --
    hr_utility.set_location('pay_us_db_per_setup.create_job',1);
    --
    SELECT business_group_id
    ,      job_structure
    INTO   l_business_group_id
    ,      l_structure_num
    FROM   per_business_groups
    WHERE  name = p_business_group
    AND    business_group_id + 0 <> 0;
  --
  --
  -- set SEGMENT1 to name if creating a default job
  --
    if p_default = 'Y' then
       l_segment1 := p_name ;
    else l_segment1 := p_segment1 ;
    end if;
  --
    l_job_definition_id := insert_job_definition;
    --
    l_job_id := insert_job;
  --
    return l_job_id;
  --
  --
  end create_job;
--
--
FUNCTION create_position
  (p_default                VARCHAR2  DEFAULT 'Y'
  ,p_name                   VARCHAR2
  ,p_business_group         VARCHAR2
  ,p_date_effective         DATE
  ,p_date_end               DATE      DEFAULT null
  ,p_job                    VARCHAR2
  ,p_organization           VARCHAR2
  ,p_location               VARCHAR2  DEFAULT null
  ,p_time_normal_start      VARCHAR2  DEFAULT '08:00'
  ,p_time_normal_finish     VARCHAR2  DEFAULT '17:30'
  ,p_working_hours          NUMBER    DEFAULT 37.5
  ,p_frequency              VARCHAR2  DEFAULT 'W'
  ,p_probation_period       VARCHAR2  DEFAULT null
  ,p_probation_units        VARCHAR2  DEFAULT null
  ,p_relief_position        VARCHAR2  DEFAULT null
  ,p_replacement_required   VARCHAR2  DEFAULT 'N'
  ,p_successor_position     VARCHAR2  DEFAULT null
  ,p_segment1               VARCHAR2  DEFAULT null
  ,p_segment2               VARCHAR2  DEFAULT null
  ,p_segment3               VARCHAR2  DEFAULT null
  ,p_segment4               VARCHAR2  DEFAULT null
  ,p_segment5               VARCHAR2  DEFAULT null
  ,p_segment6               VARCHAR2  DEFAULT null
  ,p_segment7               VARCHAR2  DEFAULT null
  ,p_segment8               VARCHAR2  DEFAULT null
  ,p_segment9               VARCHAR2  DEFAULT null
  ,p_segment10              VARCHAR2  DEFAULT null
  ,p_segment11              VARCHAR2  DEFAULT null
  ,p_segment12              VARCHAR2  DEFAULT null
  ,p_segment13              VARCHAR2  DEFAULT null
  ,p_segment14              VARCHAR2  DEFAULT null
  ,p_segment15              VARCHAR2  DEFAULT null
  ,p_segment16              VARCHAR2  DEFAULT null
  ,p_segment17              VARCHAR2  DEFAULT null
  ,p_segment18              VARCHAR2  DEFAULT null
  ,p_segment19              VARCHAR2  DEFAULT null
  ,p_segment20              VARCHAR2  DEFAULT null
  ,p_segment21              VARCHAR2  DEFAULT null
  ,p_segment22              VARCHAR2  DEFAULT null
  ,p_segment23              VARCHAR2  DEFAULT null
  ,p_segment24              VARCHAR2  DEFAULT null
  ,p_segment25              VARCHAR2  DEFAULT null
  ,p_segment26              VARCHAR2  DEFAULT null
  ,p_segment27              VARCHAR2  DEFAULT null
  ,p_segment28              VARCHAR2  DEFAULT null
  ,p_segment29              VARCHAR2  DEFAULT null
  ,p_segment30              VARCHAR2  DEFAULT null
  ,p_comments		    LONG     DEFAULT NULL
  ) return NUMBER
  --
  IS
  --
  -- local variables for create_position
     --
     l_position_id       NUMBER;
     l_business_group_id NUMBER;
     l_structure_num     NUMBER;
     l_segment1          VARCHAR2(60);
     l_job_id            NUMBER;
     l_organization_id   NUMBER;
     l_location_id       NUMBER;
     l_position_definition_id  NUMBER;
     l_relief_position_id      NUMBER;
     l_successor_position_id   NUMBER;
     --
  --
  PROCEDURE unique_name
  (p_business_group_id NUMBER, p_position_id VARCHAR2, p_position_name VARCHAR2)
  IS
  --
    pos_check VARCHAR2(1);
  --
  begin
  --
  --
    SELECT 'Y'
    INTO   pos_check
    FROM   per_positions pos
    WHERE (pos.position_id <> p_position_id
       OR  p_position_id IS NULL)
    AND    p_position_name  = pos.name
    AND    p_business_group_id = pos.business_group_id + 0;
  --
    if pos_check = 'Y' then
     hr_utility.set_message(801,'PAY_7688_USER_POS_TAB_UNIQUE');
     hr_utility.raise_error;
    end if;
  --
    exception
     when NO_DATA_FOUND then null ;
  --
  --
  end unique_name;
  --
  FUNCTION insert_pos_definition return NUMBER IS
  --
  l_pos_definition_id NUMBER;
  --
    begin
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_pos_definition',1);
  --
    SELECT per_position_definitions_s.nextval
    INTO   l_pos_definition_id
    FROM   sys.dual;
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_pos_definition',2);
  --
    INSERT INTO per_position_definitions
    (POSITION_DEFINITION_ID
    ,ID_FLEX_NUM
    ,SUMMARY_FLAG
    ,ENABLED_FLAG
    ,START_DATE_ACTIVE
    ,END_DATE_ACTIVE
    ,SEGMENT1
    ,SEGMENT2
    ,SEGMENT3
    ,SEGMENT4
    ,SEGMENT5
    ,SEGMENT6
    ,SEGMENT7
    ,SEGMENT8
    ,SEGMENT9
    ,SEGMENT10
    ,SEGMENT11
    ,SEGMENT12
    ,SEGMENT13
    ,SEGMENT14
    ,SEGMENT15
    ,SEGMENT16
    ,SEGMENT17
    ,SEGMENT18
    ,SEGMENT19
    ,SEGMENT20
    ,SEGMENT21
    ,SEGMENT22
    ,SEGMENT23
    ,SEGMENT24
    ,SEGMENT25
    ,SEGMENT26
    ,SEGMENT27
    ,SEGMENT28
    ,SEGMENT29
    ,SEGMENT30)
   values
   (l_pos_definition_id
   ,l_structure_num
   ,'Y'
   ,'N'
   ,p_date_effective
   ,p_date_end
   ,l_segment1                          -- p_name for a default position
   ,p_segment2
   ,p_segment3
   ,p_segment4
   ,p_segment5
   ,p_segment6
   ,p_segment7
   ,p_segment8
   ,p_segment9
   ,p_segment10
   ,p_segment11
   ,p_segment12
   ,p_segment13
   ,p_segment14
   ,p_segment15
   ,p_segment16
   ,p_segment17
   ,p_segment18
   ,p_segment19
   ,p_segment20
   ,p_segment21
   ,p_segment22
   ,p_segment23
   ,p_segment24
   ,p_segment25
   ,p_segment26
   ,p_segment27
   ,p_segment28
   ,p_segment29
   ,p_segment30
  );
  --
  --
    return l_pos_definition_id;
  --
  end insert_pos_definition;
  --
  --
  FUNCTION  insert_position RETURN NUMBER IS
  --
    l_position_id NUMBER;
  --
    begin
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_position',1);
  --
    SELECT per_positions_s.nextval
    INTO   l_position_id
    FROM   sys.dual;
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_position',2);
  --
    unique_name(l_business_group_id, l_position_id, p_name);
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_position',3);
  --
    INSERT INTO per_positions
    (POSITION_ID
    ,BUSINESS_GROUP_ID
    ,JOB_ID
    ,ORGANIZATION_ID
    ,LOCATION_ID
    ,POSITION_DEFINITION_ID
    ,DATE_EFFECTIVE
    ,DATE_END
    ,FREQUENCY
    ,NAME
    ,PROBATION_PERIOD
    ,PROBATION_PERIOD_UNITS
    ,RELIEF_POSITION_ID
    ,REPLACEMENT_REQUIRED_FLAG
    ,SUCCESSOR_POSITION_ID
    ,TIME_NORMAL_FINISH
    ,TIME_NORMAL_START
    ,WORKING_HOURS
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_LOGIN
    ,CREATED_BY
    ,CREATION_DATE
    ,COMMENTS)
    values
    (l_position_id
    ,l_business_group_id
    ,l_job_id
    ,l_organization_id
    ,l_location_id
    ,l_position_definition_id
    ,p_date_effective
    ,p_date_end
    ,p_frequency
    ,p_name
    ,p_probation_period
    ,p_probation_units
    ,l_relief_position_id
    ,p_replacement_required
    ,l_successor_position_id
    ,p_time_normal_finish
    ,p_time_normal_start
    ,p_working_hours
    ,SYSDATE
    ,0
    ,0
    ,0
    ,SYSDATE
    ,p_comments);
  --
  --
    return l_position_id;
  --
    end insert_position;
  --
  begin  -- FUNCTION create_position
  --
  --
    --
    hr_utility.set_location('pay_us_db_per_setup.create_position',1);
    --
    SELECT business_group_id
    ,      position_structure
    INTO   l_business_group_id
    ,      l_structure_num
    FROM   per_business_groups
    WHERE  name = p_business_group
    AND    business_group_id + 0 <> 0;
  --
    hr_utility.set_location('pay_us_db_per_setup.create_position',2);
    --
    SELECT job_id
    INTO   l_job_id
    FROM   per_jobs
    WHERE  name = p_job
    AND    business_group_id + 0 = l_business_group_id;
  --
    hr_utility.set_location('pay_us_db_per_setup.create_position',3);
    --
    SELECT organization_id
    INTO   l_organization_id
    FROM   per_organization_units
    WHERE  name  = p_organization
    AND    business_group_id + 0 = l_business_group_id;
  --
    begin
    --
    hr_utility.set_location('pay_us_db_per_setup.create_position',4);
    --
    SELECT location_id
    INTO   l_location_id
    FROM   hr_locations
    WHERE  location_code = p_location;
    --
    hr_utility.set_location('pay_us_db_per_setup.create_position',5);
    --
    SELECT position_id
    INTO   l_relief_position_id
    FROM   per_positions
    WHERE  name          = p_relief_position;
    --
    hr_utility.set_location('pay_us_db_per_setup.create_position',6);
    --
    SELECT position_id
    INTO   l_successor_position_id
    FROM   per_positions
    WHERE  name          = p_successor_position;
    --
    exception when NO_DATA_FOUND then null;
    end;
  --
  -- set SEGMENT1 to name if creating a default position
  --
    if p_default = 'Y' then
       l_segment1 := p_name ;
    else l_segment1 := p_segment1 ;
    end if;
  --
    l_position_definition_id := insert_pos_definition;
    --
    l_position_id := insert_position;
  --
    return l_position_id;
  --
  --
  end create_position;
--
--
FUNCTION create_grade
  (p_default                VARCHAR2  DEFAULT 'Y'
  ,p_name                   VARCHAR2
  ,p_business_group         VARCHAR2
  ,p_date_from              DATE
  ,p_date_to                DATE      DEFAULT null
  ,p_sequence               VARCHAR2  DEFAULT null
  ,p_segment1               VARCHAR2  DEFAULT null
  ,p_segment2               VARCHAR2  DEFAULT null
  ,p_segment3               VARCHAR2  DEFAULT null
  ,p_segment4               VARCHAR2  DEFAULT null
  ,p_segment5               VARCHAR2  DEFAULT null
  ,p_segment6               VARCHAR2  DEFAULT null
  ,p_segment7               VARCHAR2  DEFAULT null
  ,p_segment8               VARCHAR2  DEFAULT null
  ,p_segment9               VARCHAR2  DEFAULT null
  ,p_segment10              VARCHAR2  DEFAULT null
  ,p_segment11              VARCHAR2  DEFAULT null
  ,p_segment12              VARCHAR2  DEFAULT null
  ,p_segment13              VARCHAR2  DEFAULT null
  ,p_segment14              VARCHAR2  DEFAULT null
  ,p_segment15              VARCHAR2  DEFAULT null
  ,p_segment16              VARCHAR2  DEFAULT null
  ,p_segment17              VARCHAR2  DEFAULT null
  ,p_segment18              VARCHAR2  DEFAULT null
  ,p_segment19              VARCHAR2  DEFAULT null
  ,p_segment20              VARCHAR2  DEFAULT null
  ,p_segment21              VARCHAR2  DEFAULT null
  ,p_segment22              VARCHAR2  DEFAULT null
  ,p_segment23              VARCHAR2  DEFAULT null
  ,p_segment24              VARCHAR2  DEFAULT null
  ,p_segment25              VARCHAR2  DEFAULT null
  ,p_segment26              VARCHAR2  DEFAULT null
  ,p_segment27              VARCHAR2  DEFAULT null
  ,p_segment28              VARCHAR2  DEFAULT null
  ,p_segment29              VARCHAR2  DEFAULT null
  ,p_segment30              VARCHAR2  DEFAULT null
  ) return NUMBER
  --
  IS
  --
  -- local variables for create_grade
     --
     l_grade_id       NUMBER;
     l_business_group_id NUMBER;
     l_structure_num     NUMBER;
     l_segment1          VARCHAR2(60);
     l_grade_definition_id  NUMBER;
     --
  --
  --
  PROCEDURE unique_name
  (p_business_group_id NUMBER, p_grade_id VARCHAR2, p_grade_name VARCHAR2)
  IS
  --
    grd_check VARCHAR2(1);
  --
  begin
  --
  --
    SELECT 'Y'
    INTO   grd_check
    FROM   per_grades grd
    WHERE (grd.grade_id <> p_grade_id
       OR  p_grade_id IS NULL)
    AND    p_grade_name  = grd.name
    AND    p_business_group_id = grd.business_group_id + 0;
  --
    if grd_check = 'Y' then
     hr_utility.set_message(801,'PAY_7687_USER_GRADE_TAB_UNIQUE');
     hr_utility.raise_error;
    end if;
  --
    exception
     when NO_DATA_FOUND then null ;
  --
  --
  end unique_name;
  --
  --
  FUNCTION insert_grade_definition return NUMBER IS
  --
  l_grade_definition_id NUMBER;
  --
    begin
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_grade_definition',1);
  --
    SELECT per_grade_definitions_s.nextval
    INTO   l_grade_definition_id
    FROM   sys.dual;
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_grade_definition',2);
  --
    INSERT INTO per_grade_definitions
    (GRADE_DEFINITION_ID
    ,ID_FLEX_NUM
    ,SUMMARY_FLAG
    ,ENABLED_FLAG
    ,START_DATE_ACTIVE
    ,END_DATE_ACTIVE
    ,SEGMENT1
    ,SEGMENT2
    ,SEGMENT3
    ,SEGMENT4
    ,SEGMENT5
    ,SEGMENT6
    ,SEGMENT7
    ,SEGMENT8
    ,SEGMENT9
    ,SEGMENT10
    ,SEGMENT11
    ,SEGMENT12
    ,SEGMENT13
    ,SEGMENT14
    ,SEGMENT15
    ,SEGMENT16
    ,SEGMENT17
    ,SEGMENT18
    ,SEGMENT19
    ,SEGMENT20
    ,SEGMENT21
    ,SEGMENT22
    ,SEGMENT23
    ,SEGMENT24
    ,SEGMENT25
    ,SEGMENT26
    ,SEGMENT27
    ,SEGMENT28
    ,SEGMENT29
    ,SEGMENT30)
   values
   (l_grade_definition_id
   ,l_structure_num
   ,'Y'
   ,'N'
   ,p_date_from
   ,p_date_to
   ,l_segment1                               -- p_name for default grades
   ,p_segment2
   ,p_segment3
   ,p_segment4
   ,p_segment5
   ,p_segment6
   ,p_segment7
   ,p_segment8
   ,p_segment9
   ,p_segment10
   ,p_segment11
   ,p_segment12
   ,p_segment13
   ,p_segment14
   ,p_segment15
   ,p_segment16
   ,p_segment17
   ,p_segment18
   ,p_segment19
   ,p_segment20
   ,p_segment21
   ,p_segment22
   ,p_segment23
   ,p_segment24
   ,p_segment25
   ,p_segment26
   ,p_segment27
   ,p_segment28
   ,p_segment29
   ,p_segment30
  );
  --
  --
    return l_grade_definition_id;
  --
  end insert_grade_definition;
  --
  --
  FUNCTION  insert_grade RETURN NUMBER IS
  --
    l_grade_id NUMBER;
  --
    begin
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_grade',1);
  --
    SELECT per_grades_s.nextval
    INTO   l_grade_id
    FROM   sys.dual;
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_grade',2);
  --
    unique_name(l_business_group_id, l_grade_id, p_name);
  --
    hr_utility.set_location('pay_us_db_per_setup.insert_grade',3);
  --
    INSERT INTO per_grades
    (GRADE_ID
    ,BUSINESS_GROUP_ID
    ,GRADE_DEFINITION_ID
    ,DATE_FROM
    ,DATE_TO
    ,NAME
    ,SEQUENCE
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_LOGIN
    ,CREATED_BY
    ,CREATION_DATE)
    SELECT
     l_grade_id
    ,l_business_group_id
    ,l_grade_definition_id
    ,p_date_from
    ,p_date_to
    ,p_name
    ,nvl(p_sequence,nvl(max(pg.sequence),0) + 1)
    ,SYSDATE
    ,0
    ,0
    ,0
    ,SYSDATE
    FROM  per_grades pg
    WHERE pg.business_group_id + 0 = l_business_group_id ;
  --
  --
    return l_grade_id;
  --
    end insert_grade;
  --
  begin  -- FUNCTION create_grade
  --
  --
    hr_utility.set_location('pay_us_db_per_setup.create_grade',1);
    --
    SELECT business_group_id
    ,      grade_structure
    INTO   l_business_group_id
    ,      l_structure_num
    FROM   per_business_groups
    WHERE  name = p_business_group
    AND    business_group_id + 0 <> 0;
  --
  --
  -- set SEGMENT1 to name if creating a default grade
  --
    if p_default = 'Y' then
       l_segment1 := p_name ;
    else l_segment1 := p_segment1 ;
    end if;
  --
    l_grade_definition_id := insert_grade_definition;
    --
    l_grade_id := insert_grade;
  --
    return l_grade_id;
  --
  --
  end create_grade;
--
FUNCTION INSERT_WC_FUND( P_BUSINESS_GROUP_ID NUMBER,
                      P_CARRIER_ID        NUMBER,
                      P_LOCATION_ID       NUMBER DEFAULT NULL,
                      P_STATE_CODE        VARCHAR2) return NUMBER IS
--
   l_fund_id	number(15);
BEGIN
--
  hr_utility.trace('Entered insert_wc_fund');
  hr_utility.set_location('scltstdat.insert_wc_fund',1);
--
   SELECT PAY_WC_FUNDS_S.NEXTVAL
   INTO   l_fund_id
   FROM   DUAL;
--
  hr_utility.set_location('scltstdat.insert_wc_fund',5);
--
   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;
--
  hr_utility.set_location('scltstdat.insert_wc_fund',10);
--
   INSERT INTO PAY_WC_FUNDS
      (FUND_ID, BUSINESS_GROUP_ID, CARRIER_ID, LOCATION_ID, STATE_CODE)
   VALUES
      (L_FUND_ID, P_BUSINESS_GROUP_ID, P_CARRIER_ID, P_LOCATION_ID,
       P_STATE_CODE);
--
  hr_utility.set_location('scltstdat.insert_wc_fund',15);
--
  return l_fund_id;
--
END INSERT_WC_FUND;
--
--
FUNCTION insert_wc_rate
	(p_fund_id	NUMBER
	,p_business_group_id	NUMBER
	,p_rate			NUMBER
	) return NUMBER
	IS
--
  l_wc_code	NUMBER;
--
BEGIN
--
  hr_utility.trace('Entered insert_wc_rate');
  hr_utility.set_location('scltstdat.insert_wc_rate',1);
--
   SELECT PAY_WC_RATES_S.NEXTVAL
   INTO   l_wc_code
   FROM   DUAL;
--
  hr_utility.set_location('scltstdat.insert_wc_rate',5);
--
   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;
--
  hr_utility.set_location('scltstdat.insert_wc_rate',10);
--
  INSERT INTO
  pay_wc_rates
  (wc_code
  ,fund_id
  ,business_group_id
  ,rate
  ,created_by
  ,creation_date
  ,last_updated_by
  ,last_update_date
  ,last_update_login )
  VALUES
  (l_wc_code
  ,p_fund_id
  ,p_business_group_id
  ,p_rate
  ,0
  ,sysdate
  ,0
  ,sysdate
  ,0 );
--
  hr_utility.set_location('scltstdat.insert_wc_rate',15);
--
  return l_wc_code;
--
end insert_wc_rate;
--
--
FUNCTION create_us_location
  ( p_location_code		VARCHAR2
   ,p_address_line_1		VARCHAR2
   ,p_address_line_2		VARCHAR2 default null
   ,p_address_line_3            VARCHAR2 default null
   ,p_town_or_city		VARCHAR2 default null
   ,p_county			VARCHAR2 default null
   ,p_state			VARCHAR2 default null
   ,p_zip_code			VARCHAR2 default null
   ,p_telephone			VARCHAR2 default null
   ,p_fax			VARCHAR2 default null
  ) return NUMBER
  IS
--
  l_location_id		NUMBER(15);
--
BEGIN
--
  hr_utility.trace('Entered Create_us_location');
  hr_utility.set_location('scltstdat.create_us_location',1);
--
  select hr_locations_s.nextval
  into   l_location_id
  from   sys.dual;
--
  hr_utility.set_location('scltstdat.create_us_location',5);
--
  INSERT INTO hr_locations
  (location_id
  ,entered_by
  ,location_code
  ,address_line_1
  ,address_line_2
  ,address_line_3
  ,town_or_city
  ,region_1
  ,region_2
  ,postal_code
  ,telephone_number_1
  ,telephone_number_2
  ,country
  ,style
  ,created_by
  ,creation_date
  ,last_updated_by
  ,last_update_date
  ,last_update_login
  )
  values
  (l_location_id
  ,0
  ,p_location_code
  ,p_address_line_1
  ,p_address_line_2
  ,p_address_line_3
  ,p_town_or_city
  ,p_county
  ,p_state
  ,p_zip_code
  ,p_telephone
  ,p_fax
  ,'US'
  ,'US'
  ,0
  ,sysdate
  ,0
  ,sysdate
  ,0 );
--
  hr_utility.set_location('scltstdat.create_us_location',10);
--
  return l_location_id;
--
end create_us_location;
--
--
FUNCTION  create_wc_carrier
  ( P_NAME                            VARCHAR2
   ,P_BUSINESS_GROUP                  VARCHAR2
   ,P_DATE_FROM                       DATE
   ,P_DATE_TO                         DATE      DEFAULT null
   ,P_INTERNAL_ADDRESS_LINE           VARCHAR2  DEFAULT null
   ,P_INTERNAL_EXTERNAL_FLAG          VARCHAR2  DEFAULT 'INT'
   ,P_TYPE                            VARCHAR2  DEFAULT null
   ,P_LOCATION_ID                     NUMBER    DEFAULT null
  ) return NUMBER
  IS
--
  l_wc_carrier_id    NUMBER;
  l_org_information_id NUMBER;
  l_business_group_id  NUMBER;
--
  begin
--
--
hr_utility.trace('Entered Create_wc_carrier');
  hr_utility.set_location('scltstdat.create_wc_carrier',1);
--
  SELECT business_group_id
  INTO   l_business_group_id
  FROM   per_business_groups
  WHERE  name = p_business_group;
--
  l_wc_carrier_id  := pay_us_db_per_setup.insert_organization_unit
						('N'
                                                 ,p_name
                                                 ,l_business_group_id
                                                 ,null
                                                 ,p_location_id
                                                 ,null
                                                 ,p_date_from
                                                 ,p_date_to
                                                 ,p_internal_external_flag
                                                 ,p_internal_address_line
                                                 ,p_type);
hr_utility.trace('Called insert_information_unit from create_wc_carrier');
--
--
  l_org_information_id := pay_us_ins_org_info_pkg.insert_org_information
						(l_wc_carrier_id
                                                ,'CLASS'
                                                ,'US_WC_CARRIER'
                                                ,'Y'
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null
                                                ,null);
hr_utility.trace('Called create_wc_carrier');
--
--
  return l_wc_carrier_id;
--
 end create_wc_carrier;
--
--
end pay_us_db_per_setup;

/
