--------------------------------------------------------
--  DDL for Package Body PER_IE_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IE_ORG_INFO" AS
/* $Header: peieorgp.pkb 120.5 2008/02/14 13:59:35 knadhan noship $ */

--Procedure to validate that PAYE references defined at BG level are unique.
PROCEDURE validate_uniqueness(p_org_info_id        NUMBER
                             ,p_business_group_id  VARCHAR2
                             ,p_org_information2   VARCHAR2
                             ,p_effective_date     DATE
                             ) is

   CURSOR  get_unique is
       SELECT 'x', hoi.org_information2
       FROM   hr_organization_information hoi,
	      hr_all_organization_units hou
       WHERE  hoi.org_information_context ='IE_ORG_INFORMATION'
       AND    hou.organization_id = hoi.organization_id
       AND    hoi.org_information2 = p_org_information2
       AND    hou.business_group_id =p_business_group_id
       AND    (p_org_info_id IS NULL OR hoi.org_information_id <> p_org_info_id)
       AND    p_effective_date <= nvl(hou.date_to,to_Date('4712/12/31','YYYY/MM/DD'))
       AND exists (select 1 from hr_organization_information hoi1
                where  hoi1.org_information1 = 'HR_BG'
		and hoi1.org_information_context = 'CLASS'
                and    hoi1.organization_id = hoi.organization_id
		and    hoi1.org_information2='Y');



    l_check_flag varchar2(1);
    l_paye_ref_no hr_organization_information.org_information2%type;

BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'IE') THEN

    l_check_flag   := null;

    open  get_unique;
    fetch get_unique into l_check_flag, l_paye_ref_no;
    close get_unique;

    if l_check_flag = 'x' then
        hr_utility.set_message(800,'HR_IE_PAYE_UNIQUE_ERROR');
        hr_utility.raise_error;
    end if;

  END IF; /* Added for GSI Bug 5472781 */

END validate_uniqueness;

-- Changes for 4369280
--Procedure to validate that PAYE references defined at Legal Employer are unique in the BG.
PROCEDURE validate_employer(p_org_info_id        NUMBER
                           ,p_business_group_id  VARCHAR2
                           ,p_org_information2   VARCHAR2
                           ,p_effective_date     DATE
                           ) is

   CURSOR  get_unique is
       SELECT 'x', hoi.org_information2
       FROM   hr_organization_information hoi,
	      hr_all_organization_units hou
       WHERE  hoi.org_information_context ='IE_EMPLOYER_INFO'
       AND    hou.organization_id = hoi.organization_id
       AND    hoi.org_information2 = p_org_information2
       AND    hou.business_group_id =p_business_group_id
       AND    (p_org_info_id IS NULL OR hoi.org_information_id <> p_org_info_id)
       AND    p_effective_date <= nvl(hou.date_to,to_Date('4712/12/31','YYYY/MM/DD'))
       AND exists (select 1 from hr_organization_information hoi1
                where  hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
		and hoi1.org_information_context = 'CLASS'
                and    hoi1.organization_id = hoi.organization_id
		and    hoi1.org_information2='Y');



    l_check_flag varchar2(1);
    l_paye_ref_no hr_organization_information.org_information2%type;

BEGIN

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'IE') THEN

    l_check_flag   := null;

    open  get_unique;
    fetch get_unique into l_check_flag, l_paye_ref_no;
    close get_unique;

    if l_check_flag = 'x' then
        hr_utility.set_message(800,'HR_IE_PAYE_UNIQUE_ERROR');
        hr_utility.raise_error;
    end if;

  END IF; /* Added for GSI Bug 5472781 */

END validate_employer;

-- New Procedure Added to validate the CBR Number for IE EHECS Report.
PROCEDURE PROC_CBR_NO(p_cbr_no in varchar2) is
l_total number(25):=0;
l_original_total number(25):=0;
l_count number(10):=8;
l_check_digit VARCHAR2(10);
l_trace number(2):=1;
l_flag boolean:=TRUE;
l_last_digit char(1);
cursor c_cbr_no is select cbr from (select substr(p_cbr_no ,level-0,1) cbr
from dual
connect by level<length(p_cbr_no));
l_cbr_no c_cbr_no%rowtype;

begin
if length(p_cbr_no)<>10  then
hr_utility.set_message(800,'HR_IE_CBR_VALIDATION');
hr_utility.raise_error;
end if;

 OPEN c_cbr_no;
 FETCH c_cbr_no INTO l_cbr_no;
 LOOP
	EXIT WHEN c_cbr_no%NOTFOUND;

	if(l_trace=1 and l_cbr_no.cbr<>'E') then
	l_flag:=false;
        hr_utility.set_message(800,'HR_IE_CBR_VALIDATION');
        hr_utility.raise_error;
	end if;

	if(l_trace=2 and l_cbr_no.cbr<>'N') then
	l_flag:=false;
         hr_utility.set_message(800,'HR_IE_CBR_VALIDATION');
        hr_utility.raise_error;
	end if;

IF(l_trace>=3) then
if(l_cbr_no.cbr in ('1','2','3','4','5','6','7','8','9','0')) then
  l_original_total:=l_original_total+to_number(l_cbr_no.cbr)*l_count;
  l_count:=l_count-1;
ELSE
 hr_utility.set_message(800,'HR_IE_CBR_VALIDATION');
 hr_utility.raise_error;
end if;
end if;
l_trace:=l_trace+1;
FETCH c_cbr_no INTO l_cbr_no;
end loop;

l_total:=(trunc(l_original_total/11))*11-l_original_total;

l_check_digit:=11-abs(l_total);
if(l_check_digit='10') then
 l_check_digit:=0;
 elsif(l_check_digit='11') then
 l_check_digit:='-';
 end if;
l_last_digit:=substr(p_cbr_no,length(p_cbr_no ),1);

if(l_last_digit<>l_check_digit) then
  hr_utility.set_message(800,'HR_IE_CBR_VALIDATION');
  hr_utility.raise_error;
end if;

end proc_cbr_no;
--


PROCEDURE CREATE_IE_ORG_INFO(p_org_info_type_code    VARCHAR2
                            ,p_org_information2      VARCHAR2
				    ,p_org_information3      VARCHAR2
                            ,p_organization_id       NUMBER
                            ,p_effective_date        DATE
                            ) is

CURSOR get_business_group is
    SELECT business_group_id
    from hr_all_organization_units
    where organization_id=p_organization_id;

l_business_group_id     hr_all_organization_units.business_group_id%TYPE;
BEGIN

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'IE') THEN

	OPEN get_business_group;
	FETCH get_business_group into l_business_group_id;
	CLOSE get_business_group;


	   IF p_org_info_type_code  = 'IE_ORG_INFORMATION' THEN
	        IF p_org_information2 is not null THEN
	            validate_uniqueness(null,l_business_group_id,p_org_information2,p_effective_date);
	        END IF;
	   ELSIF  p_org_info_type_code  = 'IE_EMPLOYER_INFO' THEN
	        IF p_org_information2 is not null THEN
	            validate_employer(null,l_business_group_id,p_org_information2,p_effective_date);
	        END IF;
         ELSIF p_org_info_type_code  = 'IE_EHECS' THEN
	       IF p_org_information3 is not null THEN
                 proc_cbr_no(p_org_information3);
		 END IF;
	   END IF;

  END IF; /* Added for GSI Bug 5472781 */

END CREATE_IE_ORG_INFO;


PROCEDURE UPDATE_IE_ORG_INFO(p_org_info_type_code   VARCHAR2
                            ,p_org_information2     VARCHAR2
				    ,p_org_information3     VARCHAR2
                            ,p_org_information_id   NUMBER
                            ,p_effective_date       DATE
                            ) is

CURSOR get_business_group is
    SELECT business_group_id
    from hr_all_organization_units hou,hr_organization_information hoi
    where hoi.org_information_id=p_org_information_id
    and   hoi.organization_id=hou.organization_id;

l_business_group_id     hr_all_organization_units.business_group_id%TYPE;
BEGIN

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'IE') THEN

    OPEN get_business_group;
    FETCH get_business_group into l_business_group_id;
    CLOSE get_business_group;

    IF p_org_info_type_code  = 'IE_ORG_INFORMATION' THEN
    -- Changed to check whether org_information2 is updated 4369280
         IF (p_org_information2 is not null and p_org_information2 <> hr_api.g_varchar2) THEN
            validate_uniqueness(p_org_information_id,l_business_group_id,p_org_information2,p_effective_date);
        END IF;
    ELSIF  p_org_info_type_code  = 'IE_EMPLOYER_INFO' THEN
        IF (p_org_information2 <> hr_api.g_varchar2) THEN
            validate_employer(p_org_information_id,l_business_group_id,p_org_information2,p_effective_date);
        END IF;
    ELSIF p_org_info_type_code  = 'IE_EHECS' THEN
	 IF (p_org_information3 <> hr_api.g_varchar2) THEN
	     proc_cbr_no(p_org_information3);
	 END IF;
    END IF;

  END IF; /* Added for GSI Bug 5472781 */

END UPDATE_IE_ORG_INFO;


PROCEDURE CREATE_IE_ASG_INFO(P_PERSON_ID     NUMBER
			    ,P_PAYROLL_ID    NUMBER
			    ,p_organization_id NUMBER
			    ,P_EFFECTIVE_DATE  DATE)

is
BEGIN
NULL;

END CREATE_IE_ASG_INFO;

PROCEDURE UPDATE_IE_ASG_INFO(P_ASSIGNMENT_ID     NUMBER
			    ,P_PAYROLL_ID    NUMBER
			    ,p_organization_id NUMBER
			    ,P_EFFECTIVE_DATE  DATE)

is
CURSOR get_business_group is
    SELECT business_group_id
    from hr_all_organization_units
    where organization_id=p_organization_id;

cursor csr_chk_er_change(p_payroll_id number,
                         p_segment4 varchar2,
                         p_assignment_id number,
                         p_effective_date date) IS

    select 1
    from dual
    where exists(select NULL
                 from per_all_assignments_f paa,
                      pay_all_payrolls_f pap,
                      hr_soft_coding_keyflex scl
                 where paa.payroll_id = pap.payroll_id
                 and p_effective_date not between paa.effective_start_date and paa.effective_end_date
                 and paa.assignment_id = p_assignment_id
                 and pap.payroll_id <> p_payroll_id
                 and pap.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
                 and scl.segment4 <> p_segment4
                 and paa.effective_start_date <= pap.effective_end_date
                 and paa.effective_end_date >= pap.effective_start_date
                );

        cursor csr_get_paye_ref(p_payroll_id number,
				p_business_group_id number,
				p_effective_date date) is
        select sck.segment4
	from hr_soft_coding_keyflex sck
	    ,pay_all_payrolls_f pay
	where pay.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
	and   pay.payroll_id = p_payroll_id
        and   P_EFFECTIVE_DATE between pay.effective_start_date and pay.effective_end_date
	and   pay.business_group_id=p_business_group_id;

     l_old_paye_ref hr_soft_coding_keyflex.segment4%TYPE;
     l_new_paye_ref hr_soft_coding_keyflex.segment4%TYPE;
     l_prim_payroll_id per_all_assignments_f.payroll_id%TYPE;
     l_new_payroll_id per_all_assignments_f.payroll_id%TYPE;
     l_person_id per_all_people_f.person_id%type;
     l_assignment_id per_all_assignments_f.assignment_id%type;
     l_business_group_id     hr_all_organization_units.business_group_id%TYPE;
     l_er_exists number;

BEGIN

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'IE') THEN

	l_er_exists := 0;
	OPEN get_business_group;
	FETCH get_business_group into l_business_group_id;
	CLOSE get_business_group;

                   l_assignment_id  := p_assignment_id;
		   l_new_payroll_id := P_PAYROLL_ID;


		   open csr_get_paye_ref(l_new_payroll_id,l_business_group_id,p_effective_date);
                   fetch csr_get_paye_ref into l_new_paye_ref;
		   close csr_get_paye_ref;

		   OPEN csr_chk_er_change(l_new_payroll_id,l_new_paye_ref,l_assignment_id,p_effective_date);
		   FETCH csr_chk_er_change into l_er_exists;
		   CLOSE csr_chk_er_change;

		   IF(l_er_exists = 1) THEN

			hr_utility.set_message(800,'HR_IE_ASG_PAYE_DIFF_ERROR');
			hr_utility.raise_error;
		   END IF;

  END IF; /* Added for GSI Bug 5472781 */

END UPDATE_IE_ASG_INFO;

-------------------------

END PER_IE_ORG_INFO;

/
