--------------------------------------------------------
--  DDL for Package Body PAY_US_EXTRA_PER_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_EXTRA_PER_INFO_LEG_HOOK" AS
/* $Header: pyusnra.pkb 120.1.12010000.2 2008/08/06 08:34:54 ubhat ship $ */
/*  +======================================================================+
    |                Copyright (c) 2003 Oracle Corporation                 |
    |                   Redwood Shores, California, USA                    |
    |                        All rights reserved.                          |
    +======================================================================+
    Package Name        : PAY_US_EXTRA_PER_INFO_LEG_HOOK
    Package File Name   : pyusnra.pkb

    Description : This package will be called from Before Process Hook
                  hr_person_extra_info_api.create_person_extra_info and
		  hr_person_extra_info_api.update_person_extra_info for US
                  legislation. It is used to check for the Non Resident Status
		  of the employee and do the necessary checks .
    Change List:
    ------------
     Name          Date        Version   Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    vaprakas       7-DEC-2006  115.0  5601735  Created.
    rnestor        22-Feb-2008 115.2  6794488   Removed FIT check

*/

procedure person_check_nra_status_create(P_PERSON_ID in NUMBER
,P_INFORMATION_TYPE in VARCHAR2
,P_PEI_INFORMATION_CATEGORY in VARCHAR2
,P_PEI_INFORMATION5 in VARCHAR2
,P_PEI_INFORMATION9 in VARCHAR2)

is
l_filing_status_code         varchar2(2);
l_information_type           per_people_extra_info.information_type%TYPE;
l_pei_information_category   per_people_extra_info.pei_information_category%TYPE;
l_pei_information5           per_people_extra_info.pei_information5%TYPE;
l_pei_information9           per_people_extra_info.pei_information9%TYPE;
l_person_id	                 per_people_f.person_id%TYPE;
l_withholding_allowances     pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE;
l_fit_exempt                 pay_us_emp_fed_tax_rules_f.fit_exempt%TYPE;
l_wa_fed                     pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE;
l_assignment_id              per_all_assignments_f.assignment_id%TYPE;
l_student_flag               varchar2(3);
l_student                    per_people_extra_info.pei_information1%TYPE;
l_business_apprentice        per_people_extra_info.pei_information2%TYPE;


cursor csr_chk_student_status is
          select pei_information1,pei_information2
            from per_people_extra_info
           where person_id=l_person_id
             and information_type like 'PER_US_ADDITIONAL_DETAILS'
             and pei_information_category like 'PER_US_ADDITIONAL_DETAILS'
             and (pei_information1 = 'Y' or pei_information2 = 'Y');


CURSOR get_assignment_id(p_person_id NUMBER) is
SELECT distinct assignment_id
FROM per_all_assignments_f paf ,per_all_people_f ppf
      WHERE paf.person_id=ppf.person_id
      and ppf.person_id=p_person_id
      and paf.primary_flag='Y';

CURSOR get_wa_fed(p_assignment_id NUMBER)
IS
SELECT WITHHOLDING_ALLOWANCES
FROM pay_us_emp_fed_tax_rules_f fetr
WHERE  fetr.assignment_id=p_assignment_id
and fetr.effective_start_date <=(select sysdate from dual)
and fetr.effective_end_date >=(select sysdate from dual);

CURSOR get_fsc_fed(p_assignment_id NUMBER)
IS
SELECT FILING_STATUS_CODE
FROM pay_us_emp_fed_tax_rules_f fetr
WHERE  fetr.assignment_id=p_assignment_id
and fetr.effective_start_date <=(select sysdate from dual)
and fetr.effective_end_date >=(select sysdate from dual);

CURSOR get_fitexempt_fed(p_assignment_id NUMBER)
IS
SELECT FIT_EXEMPT
FROM pay_us_emp_fed_tax_rules_f fetr
WHERE  fetr.assignment_id=p_assignment_id
and fetr.effective_start_date <=(select sysdate from dual)
and fetr.effective_end_date >=(select sysdate from dual);

begin
hr_utility.trace('Entering PAY_US_EXTRA_PER_INFO_LEG_HOOK.person_check_nra_status_create');

l_person_id := P_PERSON_ID;
l_information_type := P_INFORMATION_TYPE;
l_pei_information_category := P_PEI_INFORMATION_CATEGORY;
l_pei_information5 := P_PEI_INFORMATION5;
l_pei_information9 := P_PEI_INFORMATION9;
l_student_flag :='No';


open get_assignment_id(P_PERSON_ID);
fetch get_assignment_id into l_assignment_id;
close get_assignment_id;

open get_wa_fed(l_assignment_id);
fetch get_wa_fed into l_wa_fed;
close get_wa_fed;

open get_fsc_fed(l_assignment_id);
fetch get_fsc_fed into l_filing_status_code;
close get_fsc_fed;

open get_fitexempt_fed(l_assignment_id);
fetch get_fitexempt_fed into l_fit_exempt;
close get_fitexempt_fed;

open csr_chk_student_status;
fetch csr_chk_student_status into l_student,l_business_apprentice;
if csr_chk_student_status%FOUND
        then l_student_flag :='Yes';
end if;
close csr_chk_student_status;

if l_information_type like 'PER_US_ADDITIONAL_DETAILS'
and l_pei_information_category like 'PER_US_ADDITIONAL_DETAILS'
and l_pei_information5 like 'N'
and l_pei_information9 not in ('US')
then
      if l_wa_fed > 1 and not ((l_student_flag ='Yes' and l_pei_information9 ='IN') or l_pei_information9 in ('CA','MX','KS'))
            then
            fnd_message.set_name('PAY', 'PAY_US_CHK_W4_ALLOWANCES');
            fnd_message.raise_error;
      end if;
            if l_filing_status_code <> '01'
            then
            fnd_message.set_name('PAY', 'PAY_US_CHK_W4_FILING_STATUS');
	    fnd_message.raise_error;
      end if;
      /*  Bug 6794488
	  if (l_fit_exempt = 'Y')
            then
            fnd_message.set_name('PAY', 'PAY_US_CHK_W4_EXEMPTIONS');
	    fnd_message.raise_error;
      end if; */
end if;

hr_utility.trace('Leaving PAY_US_EXTRA_PER_INFO_LEG_HOOK.person_check_nra_status_create');

end person_check_nra_status_create;


procedure person_check_nra_status_update(P_PERSON_EXTRA_INFO_ID in NUMBER
,P_PEI_INFORMATION_CATEGORY in VARCHAR2
,P_PEI_INFORMATION1 in VARCHAR2
,P_PEI_INFORMATION2 in VARCHAR2
,P_PEI_INFORMATION5 in VARCHAR2
,P_PEI_INFORMATION9 in VARCHAR2)

is
l_filing_status_code         varchar2(2);
l_person_id                  per_all_people_f.person_id%TYPE;
l_information_type           per_people_extra_info.information_type%TYPE;/* stores per us additional details*/
l_pei_information_category   per_people_extra_info.pei_information_category%TYPE;/* stores per us additional details*/
l_information_type_1         per_people_extra_info.information_type%TYPE;/* stores per us student details*/
l_pei_information_category_1 per_people_extra_info.pei_information_category%TYPE;/* stores per us student details*/
l_pei_information1           per_people_extra_info.pei_information1%TYPE;
l_pei_information2           per_people_extra_info.pei_information2%TYPE;
l_pei_information5           per_people_extra_info.pei_information5%TYPE;
l_pei_information9           per_people_extra_info.pei_information9%TYPE;
l_pei_information9_1         per_people_extra_info.pei_information9%TYPE;
l_person_extra_info_id	     per_people_extra_info.person_extra_info_id%TYPE;
l_withholding_allowances     pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE;
l_wa_fed                     pay_us_emp_fed_tax_rules_f.withholding_allowances%TYPE;
l_fit_exempt                 pay_us_emp_fed_tax_rules_f.fit_exempt%TYPE;
l_assignment_id              per_all_assignments_f.assignment_id%TYPE;
l_student_flag               varchar2(3);
l_student                    per_people_extra_info.pei_information1%TYPE;
l_business_apprentice        per_people_extra_info.pei_information2%TYPE;

/* This cursor checks whether any information exists for the employee that he is either a student or business apprentice*/
cursor csr_chk_student_status is
            select pei_information1,pei_information2
            from per_people_extra_info
                        where person_id=l_person_id
                          and information_type like 'PER_US_ADDITIONAL_DETAILS'
                          and pei_information_category like 'PER_US_ADDITIONAL_DETAILS'
                          and (pei_information1 = 'Y' or pei_information2 = 'Y');

CURSOR get_assignment_id(p_person_id NUMBER)
IS
SELECT distinct assignment_id
FROM per_all_assignments_f paf ,per_all_people_f ppf
      WHERE paf.person_id=ppf.person_id
      and ppf.person_id=p_person_id
      and paf.primary_flag='Y';


CURSOR get_person_id(p_person_extra_info_id NUMBER)
IS
SELECT person_id
FROM per_people_extra_info pei
WHERE pei.person_extra_info_id=p_person_extra_info_id;


CURSOR get_information_type(p_person_extra_info_id NUMBER)
IS
SELECT information_type
FROM per_people_extra_info pei
WHERE pei.person_extra_info_id=p_person_extra_info_id;

CURSOR get_wa_fed(p_assignment_id NUMBER)
IS
SELECT WITHHOLDING_ALLOWANCES
FROM pay_us_emp_fed_tax_rules_f fetr
WHERE  fetr.assignment_id=p_assignment_id
and fetr.effective_start_date <=(select sysdate from dual)
and fetr.effective_end_date >=(select sysdate from dual);

CURSOR get_fsc_fed(p_assignment_id NUMBER)
IS
SELECT FILING_STATUS_CODE
FROM pay_us_emp_fed_tax_rules_f fetr
WHERE  fetr.assignment_id=p_assignment_id
and fetr.effective_start_date <=(select sysdate from dual)
and fetr.effective_end_date >=(select sysdate from dual);

CURSOR get_fitexempt_fed(p_assignment_id NUMBER)
IS
SELECT FIT_EXEMPT
FROM pay_us_emp_fed_tax_rules_f fetr
WHERE  fetr.assignment_id=p_assignment_id
and fetr.effective_start_date <=(select sysdate from dual)
and fetr.effective_end_date >=(select sysdate from dual);



begin
hr_utility.trace('Entering PAY_US_EXTRA_PER_INFO_LEG_HOOK.person_check_nra_status_update');

l_person_extra_info_id := P_PERSON_EXTRA_INFO_ID;
l_pei_information_category := P_PEI_INFORMATION_CATEGORY;
l_pei_information1 := P_PEI_INFORMATION1; /*student status*/
l_pei_information2 := P_PEI_INFORMATION2; /*business apprenctice */
l_pei_information5 := P_PEI_INFORMATION5; /*residentioal status*/
l_pei_information9 := P_PEI_INFORMATION9; /*country information*/
l_student_flag :='No'; /* assuming the person is not a student */


open get_person_id(P_PERSON_EXTRA_INFO_ID);
fetch get_person_id into l_person_id;
close get_person_id;

open get_information_type(P_PERSON_EXTRA_INFO_ID);
fetch get_information_type into l_information_type;
close get_information_type;

open get_assignment_id(l_person_id);
fetch get_assignment_id into l_assignment_id;
close get_assignment_id;

open get_wa_fed(l_assignment_id);
fetch get_wa_fed into l_wa_fed;
close get_wa_fed;

open get_fsc_fed(l_assignment_id);
fetch get_fsc_fed into l_filing_status_code;
close get_fsc_fed;

open get_fitexempt_fed(l_assignment_id);
fetch get_fitexempt_fed into l_fit_exempt;
close get_fitexempt_fed;

/*
hr_utility.trace('l_person_id '||l_person_id);
hr_utility.trace('l_information_type '||l_information_type);
hr_utility.trace('l_assignment_id '||l_assignment_id);
hr_utility.trace('l_wa_fed '||l_wa_fed);
hr_utility.trace('l_filing_status_code '||l_filing_status_code);
hr_utility.trace('l_fit_exempt '||l_fit_exempt);
*/

/* if person is a student or a business appprentice his records are selected */
   open csr_chk_student_status;
   fetch csr_chk_student_status into l_student,l_business_apprentice;
   if csr_chk_student_status%FOUND /* checking setting the student flag to yes*/
	then
    l_student_flag :='Yes';
    l_information_type_1 :='PER_US_ADDITIONAL_DETAILS';
    l_pei_information_category_1 :='PER_US_ADDITIONAL_DETAILS';

    select pei_information9 into l_pei_information9_1 /* select find the country of the persosn */
                          from per_people_extra_info where person_id=l_person_id
                          and information_type like 'PER_US_ADDITIONAL_DETAILS'
                          and pei_information_category like 'PER_US_ADDITIONAL_DETAILS';
    end if;
   close csr_chk_student_status;


l_pei_information1:=l_student; /** will be 'y' if the person is a student or a business apprentce */
l_pei_information2:=l_business_apprentice; /* other wise wil be 'N' */

if l_information_type_1 like 'PER_US_ADDITIONAL_DETAILS'
and l_pei_information_category_1 like 'PER_US_ADDITIONAL_DETAILS'
and
	(nvl(P_pei_information1,'N')='N' and l_student = 'Y' and nvl(P_pei_information2,'N')='N')
	or
	(nvl(P_pei_information2,'N')='N' and l_business_apprentice ='Y' and nvl(P_pei_information1,'N')='N')
	then
	if l_wa_fed > 1 and l_pei_information9_1 ='IN'
	then fnd_message.set_name('PAY', 'PAY_US_CHK_W4_ALLOWANCES');
    fnd_message.raise_error;
	end if;
end if;

/*
hr_utility.trace('l_student_flag '||l_student_flag);
hr_utility.trace('l_information_type '||l_information_type);
hr_utility.trace('l_pei_information_category '||l_pei_information_category);
hr_utility.trace('l_pei_information5 '||l_pei_information5);
hr_utility.trace('l_pei_information9 '||l_pei_information9);
hr_utility.trace('l_filing_status_code '||l_filing_status_code);
hr_utility.trace('l_fit_exempt '||l_fit_exempt);
*/

if l_information_type like 'PER_US_ADDITIONAL_DETAILS'
and l_pei_information_category like 'PER_US_ADDITIONAL_DETAILS'
and l_pei_information5 like 'N'
and l_pei_information9 not in ('US')
then
      if l_wa_fed > 1 and not ((l_student_flag ='Yes' and l_pei_information9 ='IN') or l_pei_information9 in ('CA','MX','KS'))
            then
            fnd_message.set_name('PAY', 'PAY_US_CHK_W4_ALLOWANCES');
            fnd_message.raise_error;
      end if;
            if l_filing_status_code <> '01'
            then
            fnd_message.set_name('PAY', 'PAY_US_CHK_W4_FILING_STATUS');
	    fnd_message.raise_error;
      end if;
      /* Bug 6794488
	   if (l_fit_exempt = 'Y')
            then
            fnd_message.set_name('PAY', 'PAY_US_CHK_W4_EXEMPTIONS');
	    fnd_message.raise_error;
      end if; */
end if;

hr_utility.trace('Leaving PAY_US_EXTRA_PER_INFO_LEG_HOOK.person_check_nra_status_update');

end person_check_nra_status_update;

end PAY_US_EXTRA_PER_INFO_LEG_HOOK ;

/
