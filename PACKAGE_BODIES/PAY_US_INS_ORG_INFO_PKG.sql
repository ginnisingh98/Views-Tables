--------------------------------------------------------
--  DDL for Package Body PAY_US_INS_ORG_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_INS_ORG_INFO_PKG" AS
/* $Header: pyusiorg.pkb 115.1 99/07/17 06:44:44 porting shi $ */
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
l_dummy varchar2(1);
--
begin
--
  hr_utility.trace('Entered insert_org_information');
  --
  hr_utility.set_location('pay_us_ins_org_info_pkg.insert_org_information',1);
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
  hr_utility.set_location('pay_us_ins_org_info_pkg.insert_org_information',5);
  SELECT organization_id
  INTO   l_organization_id
  FROM   hr_all_organization_units
  WHERE  organization_id = p_organization_id;
--
  hr_utility.set_location('pay_us_ins_org_info_pkg.insert_org_information',8);
  if p_org_information_context = 'CLASS' then
     SELECT lookup_code
     INTO   l_org_information1
     FROM   hr_lookups
     WHERE  lookup_type = 'ORG_CLASS'
     AND    lookup_code = p_org_information1;
     --
     l_org_information_type := p_org_information_context;
  else
hr_utility.trace('Entered Else');
     l_org_information1 := p_org_information1;
  begin
--
--
hr_utility.trace('p_org_information1 '||p_org_information1);
hr_utility.trace('p_org_information_context '||p_org_information_context);
hr_utility.trace('l_organization_id '||to_char(l_organization_id));
--
--
  hr_utility.set_location('pay_us_ins_org_info_pkg.insert_org_information',10);
SELECT 'x' INTO l_dummy from dual;
--  SELECT oit.org_information_type
--  INTO   l_org_information_type
--  FROM   hr_organization_information hoi
--  ,      hr_org_info_types_by_class  tbc
--  ,      hr_org_information_types    oit
--  WHERE  oit.org_information_type = p_org_information_context
--  AND    oit.org_information_type = tbc.org_information_type
--  AND    tbc.org_classification   = hoi.org_information1
--  AND    hoi.org_information_context = 'CLASS'
--  AND    hoi.organization_id         = l_organization_id;
  --
hr_utility.trace('l_org_information_type '||l_org_information_type);
  exception when NO_DATA_FOUND then
     hr_utility.trace('In No Data Found');
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','insert_org_information');
     hr_utility.set_message_token('STEP','10');
     hr_utility.raise_error;
  end;
  --
  end if;
  --
  begin
  hr_utility.set_location('pay_us_ins_org_info_pkg.insert_org_information',15);
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
  hr_utility.set_location('pay_us_ins_org_info_pkg.insert_org_information',20);
  SELECT hr_organization_information_s.nextval
  INTO   l_org_information_id
  FROM   sys.dual;
  --
--  hr_utility.trace('l_org_information_id is ' || to_char(l_org_information_id));
--  hr_utility.trace('p_organization_id is ' || to_char(p_organization_id));
 hr_utility.trace('l_organization_id is ' || to_char(l_organization_id));
 hr_utility.trace('l_org_information1 is ' || l_org_information1);
 hr_utility.trace('l_org_information_type is ' || l_org_information_type);
 hr_utility.trace('l_check is ' || l_check);
  hr_utility.set_location('pay_us_ins_org_info_pkg.insert_org_information',25);
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
  hr_utility.set_location('pay_us_ins_org_info_pkg.insert_org_information',30);
  hr_utility.trace('before return');
  return l_org_information_id;
  hr_utility.trace('after return');
--
--
  end insert_org_information;
--
--
end pay_us_ins_org_info_pkg;

/
