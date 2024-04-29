--------------------------------------------------------
--  DDL for Package Body PER_DB_PER_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DB_PER_SETUP" AS
/* $Header: pesetupd.pkb 115.6 1999/11/16 06:47:46 pkm ship      $ */
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
 Name        : per_db_per_setup  (BODY)

 Description : This package defines the procedures required to
               create all 'set up' entities in Personnel.
               That is:

                    Business Groups,
                    HR Organizations,
                    Legal Companies,
                    Positions,
                    Jobs         and
                    Grades.

 It is used during regression testing

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
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
 70.13   11-MAR-93 NKHAN                Added 'exit' to the end
 70.17   25-AUG-93 PGOLDTHO             Reference to ORG_CLASSIFICATIONS
                                        changed to read ORG_CLASS.
 70.20   23-NOV-94 RFINE                Suppressed index on business_group_id
 70.20   25-JUL-95 AForte		Changed tokenised message
					PAY_6361_USER_TABLE_UNIQUE
					to hard coded message
					PAY_7686_USER_JOB_TAB_UNIQUE,
					PAY_7683_USER_POS_TABLE_UNIQUE,
					PAY_7687_USER_GRADE_TAB_UNIQUE
 70.23   17-NOV-95 JTHURING             Removed ampersand from change history -
                                        this was causing an
                                        "expected symbol name is missing" error
 70.24   02-JUL-96 DKERR		Year2000:Made date_from/date_to
					parameters on insert_organization_unit
					dates instead of varchar2
 110.1   05-AUG-97 ALOGUE               Change fnd_id_flex_structures
                                        to fnd_id_flex_structures_vl
 115.1   19-NOV-98 ALOGUE               Change to insert_organization_unit
                                        to insert into  hr_all_organization_units
                                        and hr_all_organization_units_tl.
 115.2   30-NOV-98 ALOGUE               Amend change to insert_organization_unit
                                        as business_group_id not in
                                        HR_ALL_ORGANIZATION_UNITS_TL.
 115.4   14-May-19099 mmillmor          multi-radix fix to working_hours on position
 115.5   05-Oct-1999  SCNair            Date track position related changes
 115.6   16-Nov-1999  pzwalker          changed call
                                        hr_dt_position_api.create_dt_position
                                        to hr_position_api.create_position
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
  hr_utility.set_location('per_db_per_setup.insert_organization_unit',1);
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
--
  hr_utility.set_location('per_db_per_setup.insert_organization_unit',2);
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
--
  return l_organization_id;
--
--
 end insert_organization_unit;
--
--
 FUNCTION  insert_org_information
  ( P_ORGANIZATION_ID                 NUMBER
   ,P_ORG_INFORMATION_CONTEXT         VARCHAR2
   ,P_ORG_INFORMATION1                VARCHAR2
   ,P_ORG_INFORMATION2                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION3                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION4                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION5                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION6                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION7                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION8                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION9                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION10               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION11               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION12               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION13               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION14               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION15               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION16               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION17               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION18               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION19               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION20               VARCHAR2 DEFAULT null
  ) return NUMBER
  IS
--
  l_org_information_id NUMBER;
  l_organization_id    NUMBER;
  l_org_information1   VARCHAR2(150);
  l_org_information_type VARCHAR2(40);
  l_check                VARCHAR2(1);
--
begin
--
  hr_utility.trace('Entered insert_org_information');
  --
  hr_utility.set_location('per_db_per_setup.insert_org_information',1);
  if p_organization_id IS NULL
     OR p_org_information_context IS NULL
      OR p_org_information1 IS NULL
   then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','insert_org_information');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;
--
  hr_utility.set_location('per_db_per_setup.insert_org_information',5);
  SELECT organization_id
  INTO   l_organization_id
  FROM   hr_organization_units
  WHERE  organization_id = p_organization_id;
--
  hr_utility.set_location('per_db_per_setup.insert_org_information',8);
  if p_org_information_context = 'CLASS' then
     SELECT lookup_code
     INTO   l_org_information1
     FROM   hr_lookups
     WHERE  lookup_type = 'ORG_CLASS'
     AND    lookup_code = p_org_information1;
     --
     l_org_information_type := p_org_information_context;
  else
     l_org_information1 := p_org_information1;
  begin
  hr_utility.set_location('per_db_per_setup.insert_org_information',10);
  SELECT oit.org_information_type
  INTO   l_org_information_type
  FROM   hr_organization_information hoi
  ,      hr_org_info_types_by_class  tbc
  ,      hr_org_information_types    oit
  WHERE  oit.org_information_type = p_org_information_context
  AND    oit.org_information_type = tbc.org_information_type
  AND    tbc.org_classification   = hoi.org_information1
  AND    hoi.org_information_context = 'CLASS'
  AND    hoi.organization_id         = l_organization_id;
  --
  exception when NO_DATA_FOUND then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','insert_org_information');
     hr_utility.set_message_token('STEP','10');
     hr_utility.raise_error;
  end;
  --
  end if;
  --
  begin
  hr_utility.set_location('per_db_per_setup.insert_org_information',15);
  SELECT 'Y'
  INTO   l_check
  FROM   hr_organization_information
  WHERE  organization_id = l_organization_id
  AND    org_information_context = l_org_information_type
  AND    org_information1        = l_org_information1;
  --
  if l_check = 'Y' then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','insert_org_information');
     hr_utility.set_message_token('STEP','15');
     hr_utility.raise_error;
  end if;
  --
  exception when NO_DATA_FOUND then null;
  end;
  --
  hr_utility.set_location('per_db_per_setup.insert_org_information',20);
  SELECT hr_organization_information_s.nextval
  INTO   l_org_information_id
  FROM   sys.dual;
  --
  hr_utility.set_location('per_db_per_setup.insert_org_information',25);
  INSERT INTO HR_ORGANIZATION_INFORMATION
  (org_information_id
  ,organization_id
  ,attribute_category
  ,org_information_context
  ,org_information1
  ,org_information2
  ,org_information3
  ,org_information4
  ,org_information5
  ,org_information6
  ,org_information7
  ,org_information8
  ,org_information9
  ,org_information10
  ,org_information11
  ,org_information12
  ,org_information13
  ,org_information14
  ,org_information15
  ,org_information16
  ,org_information17
  ,org_information18
  ,org_information19
  ,org_information20
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,created_by
  ,creation_date)
  SELECT l_org_information_id
  ,hou.organization_id
  ,p_org_information_context
  ,p_org_information_context
  ,p_org_information1
  ,p_org_information2
  ,p_org_information3
  ,p_org_information4
  ,p_org_information5
  ,p_org_information6
  ,p_org_information7
  ,p_org_information8
  ,p_org_information9
  ,p_org_information10
  ,p_org_information11
  ,p_org_information12
  ,p_org_information13
  ,p_org_information14
  ,p_org_information15
  ,p_org_information16
  ,p_org_information17
  ,p_org_information18
  ,p_org_information19
  ,p_org_information20
  ,hou.last_update_date
  ,hou.last_updated_by
  ,hou.last_update_login
  ,hou.created_by
  ,hou.creation_date
  FROM  hr_organization_units hou
  WHERE hou.organization_id = p_organization_id;
--
  return l_org_information_id;
--
--
  end insert_org_information;
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
   ,P_GRADE_STRUCTURE                 VARCHAR2  DEFAULT 'Grade Volume Data'
   ,P_PEOPLE_GROUP_STRUCTURE          VARCHAR2
                                        DEFAULT 'People Group Volume Data'
   ,P_JOB_STRUCTURE                   VARCHAR2  DEFAULT 'Job Volume Data'
   ,P_COST_ALLOCATION_STRUCTURE       VARCHAR2
                                        DEFAULT 'Cost Allocation Volume Data'
   ,P_POSITION_STRUCTURE              VARCHAR2  DEFAULT 'Position Volume Data'
   ,P_LEGISLATION_CODE                VARCHAR2  DEFAULT 'GB'
   ,P_CURRENCY_CODE                   VARCHAR2  DEFAULT 'GBP'
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
  hr_utility.set_location('per_db_per_setup.create_business_group',1);
  SELECT id_flex_num
  INTO   l_position_num
  FROM   fnd_id_flex_structures_vl
  WHERE  id_flex_code = 'POS'
  AND    id_flex_structure_name = p_position_structure;
--
  hr_utility.set_location('per_db_per_setup.create_business_group',2);
  SELECT id_flex_num
  INTO   l_grade_num
  FROM   fnd_id_flex_structures_vl
  WHERE  id_flex_code = 'GRD'
  AND    id_flex_structure_name = p_grade_structure;
--
  hr_utility.set_location('per_db_per_setup.create_business_group',3);
  SELECT id_flex_num
  INTO   l_job_num
  FROM   fnd_id_flex_structures_vl
  WHERE  id_flex_code = 'JOB'
  AND    id_flex_structure_name = p_job_structure;
--
  hr_utility.set_location('per_db_per_setup.create_business_group',4);
  SELECT id_flex_num
  INTO   l_people_group_num
  FROM   fnd_id_flex_structures_vl
  WHERE  id_flex_code = 'GRP'
  AND    id_flex_structure_name = p_people_group_structure;
--
  hr_utility.set_location('per_db_per_setup.create_business_group',5);
  SELECT id_flex_num
  INTO   l_cost_allocation_num
  FROM   fnd_id_flex_structures_vl
  WHERE  id_flex_code = 'COST'
  AND    id_flex_structure_name = p_cost_allocation_structure;
--
  hr_utility.set_location('per_db_per_setup.create_business_group',6);
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
  hr_utility.set_location('per_db_per_setup.create_business_group',7);
  l_org_information_id := per_db_per_setup.insert_org_information(
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
--  hr_utility.set_location('per_db_per_setup.create_business_group',8);
--   l_org_information_id := per_db_per_setup.insert_org_information(
--                                               l_business_group_id
--                                              ,'CLASS'
--                                              ,'HR_ORG'
--                                              ,'Y'
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null
--                                              ,null);
--
--
  hr_utility.set_location('per_db_per_setup.create_business_group',9);
  l_org_information_id := per_db_per_setup.insert_org_information(
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
  hr_utility.set_location('per_db_per_setup.create_business_group',10);
  l_org_information_id := per_db_per_setup.insert_org_information(
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
  hr_utility.set_location('per_db_per_setup.create_per_organization',1);
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
--
--
--
  l_org_information_id := per_db_per_setup.insert_org_information(l_organization_id
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
  l_org_information_id := per_db_per_setup.insert_org_information(l_organization_id
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
--
--
  return l_organization_id;
--
 end create_per_organization;
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
  ) return NUMBER
  IS
--
  l_legal_company_id   NUMBER;
  l_org_information_id NUMBER;
  l_business_group_id  NUMBER;
--
  begin
--
  hr_utility.set_location('per_db_per_setup.create_pay_legal_company',1);
--
  SELECT business_group_id
  INTO   l_business_group_id
  FROM   per_business_groups
  WHERE  name = p_business_group;
--
  l_legal_company_id := insert_organization_unit('N'
                                                 ,p_name
                                                 ,l_business_group_id
                                                 ,null
                                                 ,p_location_id
                                                 ,null
                                                 ,p_date_from
                                                 ,p_date_to
                                                 ,null
                                                 ,p_internal_address_line
                                                 ,null);
--
--
--
  l_org_information_id := per_db_per_setup.insert_org_information(
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
  l_org_information_id := per_db_per_setup.insert_org_information(
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
  l_org_information_id := per_db_per_setup.insert_org_information(
                                                 l_legal_company_id
                                                ,'Legal Company Information'
                                                ,p_company_federal_identifier
                                                ,p_nacha_company_name
                                                ,p_nacha_identifier
                                                ,p_nacha_discretionary_code
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
  return l_legal_company_id;
--
  end create_pay_legal_company;
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
    hr_utility.set_location('per_db_per_setup.insert_job_definition',1);
  --
    SELECT per_job_definitions_s.nextval
    INTO   l_job_definition_id
    FROM   sys.dual;
  --
    hr_utility.set_location('per_db_per_setup.insert_job_definition',2);
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
   ,to_date(p_date_from,'DD-MON-YYYY')
   ,to_date(p_date_to,'DD-MON-YYYY')
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
    hr_utility.set_location('per_db_per_setup.insert_job',1);
  --
    SELECT per_jobs_s.nextval
    INTO   l_job_id
    FROM   sys.dual;
  --
    hr_utility.set_location('per_db_per_setup.insert_job',2);
  --
    unique_name(l_business_group_id,l_job_id, p_name);
  --
    hr_utility.set_location('per_db_per_setup.insert_job',3);
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
    ,CREATION_DATE)
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
    ,SYSDATE);
  --
  --
    return l_job_id;
  --
    end insert_job;
  --
  begin  -- FUNCTION create_job
  --
  --
    hr_utility.set_location('per_db_per_setup.create_job',1);
    --
    SELECT business_group_id
    ,      job_structure
    INTO   l_business_group_id
    ,      l_structure_num
    FROM   per_business_groups
    WHERE  name = p_business_group
    AND    business_group_id <> 0;
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
  ) return NUMBER
  --
  IS
  --
    cursor c0 (p_name VARCHAR2) is
        SELECT position_id
        FROM   hr_positions_f
        WHERE  name = p_name
        AND    effective_end_date = to_date('31124712', 'ddmmyyyy');
  -- local variables for create_position
     --
     l_position_id             NUMBER;
     l_business_group_id       NUMBER;
     l_structure_num           NUMBER;
     l_segment1                VARCHAR2(60);
     l_name                    VARCHAR2(255);
     l_job_id                  NUMBER;
     l_organization_id         NUMBER;
     l_effective_start_date    DATE;
     l_effective_end_date      DATE;
     l_object_version_number   NUMBER;
     l_location_id             NUMBER;
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
  -- Changed 05-Oct-99 SCNair (per_positions to hr_all_positions_f) Date tracked Position Req
  --
    SELECT 'Y'
    INTO   pos_check
    FROM   hr_all_positions_f pos
    WHERE (pos.position_id <> p_position_id
       OR  p_position_id IS NULL)
    AND    p_position_name  = pos.name
    AND    p_business_group_id = pos.business_group_id + 0;
  --
    if pos_check = 'Y' then
     hr_utility.set_message(801,'PAY_7683_USER_POS_TABLE_UNIQUE');
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
    hr_utility.set_location('per_db_per_setup.insert_pos_definition',1);
  --
    SELECT per_position_definitions_s.nextval
    INTO   l_pos_definition_id
    FROM   sys.dual;
  --
    hr_utility.set_location('per_db_per_setup.insert_pos_definition',2);
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
    hr_utility.set_location('per_db_per_setup.insert_position',1);
  --
  --  Changed 05-Oct-99 SCNair change insert as an API call
  --
  --  SELECT per_positions_s.nextval
  --  INTO   l_position_id
  --  FROM   sys.dual;
  --
    hr_utility.set_location('per_db_per_setup.insert_position',2);
  --
    unique_name(l_business_group_id, l_position_id, p_name);
  --
    hr_utility.set_location('per_db_per_setup.insert_position',3);
  --
  --  INSERT INTO per_positions
  --  (POSITION_ID
  --  ,BUSINESS_GROUP_ID
  --  ,JOB_ID
  --  ,ORGANIZATION_ID
  --  ,LOCATION_ID
  --  ,POSITION_DEFINITION_ID
  --  ,DATE_EFFECTIVE
  --  ,DATE_END
  --  ,FREQUENCY
  --  ,NAME
  --  ,PROBATION_PERIOD
  --  ,PROBATION_PERIOD_UNITS
  --  ,RELIEF_POSITION_ID
  --  ,REPLACEMENT_REQUIRED_FLAG
  --  ,SUCCESSOR_POSITION_ID
  --  ,TIME_NORMAL_FINISH
  --  ,TIME_NORMAL_START
  --  ,WORKING_HOURS
  --  ,LAST_UPDATE_DATE
  --  ,LAST_UPDATED_BY
  --  ,LAST_UPDATE_LOGIN
  --  ,CREATED_BY
  --  ,CREATION_DATE)
  --  values
  --  (l_position_id
  --  ,l_business_group_id
  --  ,l_job_id
  --  ,l_organization_id
  --  ,l_location_id
  --  ,l_position_definition_id
  --  ,p_date_effective
  --  ,p_date_end
  --  ,p_frequency
  --  ,p_name
  --  ,p_probation_period
  --  ,p_probation_units
  --  ,l_relief_position_id
  --  ,p_replacement_required
  --  ,l_successor_position_id
  --  ,p_time_normal_finish
  --  ,p_time_normal_start
  --  ,p_working_hours
  --  ,SYSDATE
  --  ,0
  --  ,0
  --  ,0
  --  ,SYSDATE);
  --
  --
  hr_position_api.create_position(
    p_position_id            	 => l_position_id,
    p_effective_start_date    	 => l_effective_start_date,
    p_effective_end_date	 => l_effective_end_date,
    p_position_definition_id     => l_position_definition_id,
    p_name                       => l_name,
    p_object_version_number   	 => l_object_version_number,
    p_position_type		 => 'NONE',
    p_job_id                     => l_job_id,
    p_organization_id            => l_organization_id ,
    p_effective_date	   	 => p_date_effective,
    p_date_effective             => p_date_effective,
    p_validate                   => false,
    p_business_group_id          => l_business_group_id,
    p_location_id                => l_location_id,
    p_relief_position_id         => l_relief_position_id,
    p_successor_position_id      => l_successor_position_id,
    p_date_end                   => p_date_end,
    p_frequency                  => p_frequency,
    p_probation_period           => p_probation_period,
    p_probation_period_unit_cd   => p_probation_units,
    p_replacement_required_flag  => p_replacement_required,
    p_working_hours              => p_working_hours,
/*
    p_status                     => l_status,
    p_comments			 => l_comments,
    p_attribute_category         => l_attribute_category,
    p_attribute1                 => l_attribute1,
    p_attribute2                 => l_attribute2,
    p_attribute3                 => l_attribute3,
    p_attribute4                 => l_attribute4,
    p_attribute5                 => l_attribute5,
    p_attribute6                 => l_attribute6,
    p_attribute7                 => l_attribute7,
    p_attribute8                 => l_attribute8,
    p_attribute9                 => l_attribute9,
    p_attribute10                => l_attribute10,
    p_attribute11                => l_attribute11,
    p_attribute12                => l_attribute12,
    p_attribute13                => l_attribute13,
    p_attribute14                => l_attribute14,
    p_attribute15                => l_attribute15,
    p_attribute16                => l_attribute16,
    p_attribute17                => l_attribute17,
    p_attribute18                => l_attribute18,
    p_attribute19                => l_attribute19,
    p_attribute20                => l_attribute20,
    p_attribute21                => l_attribute21,
    p_attribute22                => l_attribute22,
    p_attribute23                => l_attribute23,
    p_attribute24                => l_attribute24,
    p_attribute25                => l_attribute25,
    p_attribute26                => l_attribute26,
    p_attribute27                => l_attribute27,
    p_attribute28                => l_attribute28,
    p_attribute29                => l_attribute29,
    p_attribute30                => l_attribute30,
    p_concat_segments		 => l_segment,
    p_request_id                 => l_request_id,
    p_program_application_id     => l_program_application_id,
    p_program_id                 => l_program_id,
    p_program_update_date        => l_program_update_date
*/
    p_segment1                   => l_segment1,
    p_segment2                   => p_segment2,
    p_segment3                   => p_segment3,
    p_segment4                   => p_segment4,
    p_segment5                   => p_segment5,
    p_segment6                   => p_segment6,
    p_segment7                   => p_segment7,
    p_segment8                   => p_segment8,
    p_segment9                   => p_segment9,
    p_segment10                  => p_segment10,
    p_segment11                  => p_segment11,
    p_segment12                  => p_segment12,
    p_segment13                  => p_segment13,
    p_segment14                  => p_segment14,
    p_segment15                  => p_segment15,
    p_segment16                  => p_segment16,
    p_segment17                  => p_segment17,
    p_segment18                  => p_segment18,
    p_segment19                  => p_segment19,
    p_segment20                  => p_segment20,
    p_segment21                  => p_segment21,
    p_segment22                  => p_segment22,
    p_segment23                  => p_segment23,
    p_segment24                  => p_segment24,
    p_segment25                  => p_segment25,
    p_segment26                  => p_segment26,
    p_segment27                  => p_segment27,
    p_segment28                  => p_segment28,
    p_segment29                  => p_segment29,
    p_segment30                  => p_segment30
);

    return l_position_id;
  --
    end insert_position;
  --
  begin  -- FUNCTION create_position
  --
  --
    --
    hr_utility.set_location('per_db_per_setup.create_position',1);
    --
    SELECT business_group_id
    ,      position_structure
    INTO   l_business_group_id
    ,      l_structure_num
    FROM   per_business_groups
    WHERE  name = p_business_group
    AND    business_group_id <> 0;
  --
    hr_utility.set_location('per_db_per_setup.create_position',2);
    --
    SELECT job_id
    INTO   l_job_id
    FROM   per_jobs
    WHERE  name = p_job
    AND    business_group_id + 0 = l_business_group_id;
  --
    hr_utility.set_location('per_db_per_setup.create_position',3);
    --
    SELECT organization_id
    INTO   l_organization_id
    FROM   per_organization_units
    WHERE  name  = p_organization
    AND    business_group_id + 0 = l_business_group_id;
  --
    begin
    --
    hr_utility.set_location('per_db_per_setup.create_position',4);
    --
    SELECT location_id
    INTO   l_location_id
    FROM   hr_locations
    WHERE  location_code = p_location;
    --
    hr_utility.set_location('per_db_per_setup.create_position',5);
    --
    --
    open c0(p_relief_position);
       fetch c0 into l_relief_position_id;
    close c0;
    hr_utility.set_location('per_db_per_setup.create_position',6);
    open c0(p_successor_position);
       fetch c0 into l_successor_position_id;
    close c0;
  --
  --  SELECT position_id
  -- INTO   l_successor_position_id
  --  FROM   per_positions
  --  WHERE  name          = p_successor_position;
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
    hr_utility.set_location('per_db_per_setup.insert_grade_definition',1);
  --
    SELECT per_grade_definitions_s.nextval
    INTO   l_grade_definition_id
    FROM   sys.dual;
  --
    hr_utility.set_location('per_db_per_setup.insert_grade_definition',2);
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
    hr_utility.set_location('per_db_per_setup.insert_grade',1);
  --
    SELECT per_grades_s.nextval
    INTO   l_grade_id
    FROM   sys.dual;
  --
    hr_utility.set_location('per_db_per_setup.insert_grade',2);
  --
    unique_name(l_business_group_id, l_grade_id, p_name);
  --
    hr_utility.set_location('per_db_per_setup.insert_grade',3);
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
    hr_utility.set_location('per_db_per_setup.create_grade',1);
    --
    SELECT business_group_id
    ,      grade_structure
    INTO   l_business_group_id
    ,      l_structure_num
    FROM   per_business_groups
    WHERE  name = p_business_group
    AND    business_group_id <> 0;
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
--
end per_db_per_setup;

/
