--------------------------------------------------------
--  DDL for Package Body PAY_CONTACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CONTACT_PKG" AS
/* $Header: pypaycon.pkb 120.0 2005/05/29 07:16:02 appldev noship $ */
--
FUNCTION populate_pay_contact_details(p_assignment_id     in number
                                     ,p_business_group_id in number
                                     ,p_effective_date    in date
                                     ,p_contact_name      in varchar2
                                     ,p_phone             in varchar2
                                     ,p_email             in varchar2
                                         )
RETURN number IS
--
CURSOR c_contact_details(p_asg_id   number
                        ,p_bg_id    number
                        ,p_eff_date date)
is
SELECT aei.assignment_extra_info_id
,      aei.aei_information1
,      aei.aei_information2
,      aei.aei_information3
FROM per_assignment_extra_info aei
,    per_all_assignments_f paf
WHERE aei.assignment_id = p_asg_id
AND   aei.information_type = 'PAYROLL_CONTACT'
AND   aei.aei_information_category = 'PAYROLL_CONTACT'
AND   paf.assignment_id = aei.assignment_id
AND   paf.business_group_id = p_bg_id
AND   p_eff_date between paf.effective_start_date
                     and paf.effective_end_date;
--
l_extra_info_id per_assignment_extra_info.ASSIGNMENT_EXTRA_INFO_ID%type;
l_aei_name per_assignment_extra_info.aei_information1%type;
l_aei_phone per_assignment_extra_info.aei_information2%type;
l_aei_emial per_assignment_extra_info.aei_information3%type;
--
BEGIN
hr_utility.trace('p_ass_id: '||to_char(p_assignment_id));
hr_utility.trace('pbg_id: '||to_char(p_business_group_id));
hr_utility.trace('eff-date: '||to_char(p_effective_date,'yyyy/mm/dd'));
--
OPEN c_contact_details(p_assignment_id, p_business_group_id, p_effective_date);
FETCH c_contact_details into l_extra_info_id, l_aei_name, l_aei_phone,
                             l_aei_emial;
IF c_contact_details%NOTFOUND THEN
  hr_utility.trace('row not found so insert');
  CLOSE c_contact_details;

  --
  -- insert details
  --
  insert into per_assignment_extra_info
  (ASSIGNMENT_EXTRA_INFO_ID
  ,ASSIGNMENT_ID
  ,INFORMATION_TYPE
  ,AEI_INFORMATION_CATEGORY
  ,AEI_INFORMATION1
  ,AEI_INFORMATION2
  ,AEI_INFORMATION3)
  select per_assignment_extra_info_s.nextval
  ,      p_assignment_id
  ,      'PAYROLL_CONTACT'
  ,      'PAYROLL_CONTACT'
  ,      p_contact_name
  ,      p_phone
  ,      p_email
  from dual
  where not exists (select 1
                    from per_all_assignments_f paf
                    ,    per_assignment_extra_info aei
                    where paf.assignment_id = aei.assignment_id
                    and   paf.business_group_id = p_business_group_id
                    and   paf.assignment_id = p_assignment_id
                    and   aei.aei_information_category = 'PAYROLL_CONTACT');
  --
  select per_assignment_extra_info_s.currval
  into l_extra_info_id
  from dual;
  --
ELSE
  hr_utility.trace('row found so update');
  CLOSE c_contact_details;
  --
  -- contact details exist, check if any changes
  --
  if p_contact_name <> l_aei_name
  or p_phone <> l_aei_phone
  or p_email <> l_aei_phone then
  --
  -- a change in details so update
  --
    update per_assignment_extra_info
    set aei_information1 = p_contact_name
    ,   aei_information2 = p_phone
    ,   aei_information3 = p_email
    where assignment_extra_info_id = l_extra_info_id
    and   information_type = 'PAYROLL_CONTACT'
    and   aei_information_category = 'PAYROLL_CONTACT';
    --
  end if; -- no changes so do not do anything
END IF;
--
return l_extra_info_id;
--
END populate_pay_contact_details;
--
END pay_contact_pkg;

/
