--------------------------------------------------------
--  DDL for Package Body PAY_NL_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_TAX_PKG" as
/* $Header: pynltax.pkb 120.1.12010000.6 2009/12/21 08:09:47 rsahai ship $ */

          g_package                  varchar2(33) := '  PAY_NL_TAX_PKG.';

FUNCTION chk_contribution_exempt (p_assignment_id IN NUMBER
					,p_date_earned IN DATE
					,p_assignment_action_id IN NUMBER
					,p_marginal_flag OUT nocopy VARCHAR2
					,p_influence_flag OUT nocopy VARCHAR2
					,p_warning OUT nocopy VARCHAR2
					) RETURN NUMBER IS

CURSOR csr_extra_info(c_flex_context IN VARCHAR2) is
Select TARGET.*
From
per_assignment_extra_info  TARGET
,pay_assignment_actions     PAA
,pay_payroll_actions        PACT
,per_time_periods	    TPERIOD
where PAA.assignment_action_id = p_assignment_action_id
AND target.information_type = c_flex_context
AND target.assignment_id = PAA.assignment_id
AND PAA.payroll_action_id = PACT.payroll_action_id
AND PACT.payroll_id = TPERIOD.payroll_id
AND PACT.date_earned between TPERIOD.start_date and TPERIOD.end_date
AND TPERIOD.end_date >= FND_DATE.CANONICAL_TO_DATE(target.AEI_INFORMATION1)
AND TPERIOD.start_date <= nvl(FND_DATE.CANONICAL_TO_DATE(target.AEI_INFORMATION2), TPERIOD.start_date);

/*
CURSOR csr_extra_info_Sm_job(c_flex_context IN VARCHAR2) is
Select TARGET.*
From
per_assignment_extra_info  TARGET
,pay_assignment_actions     PAA
,pay_payroll_actions        PACT
,per_time_periods	    TPERIOD
where PAA.assignment_action_id = p_assignment_action_id
AND target.information_type = c_flex_context
AND target.assignment_id = PAA.assignment_id
AND PAA.payroll_action_id = PACT.payroll_action_id
AND PACT.payroll_id = TPERIOD.payroll_id
AND PACT.date_earned between TPERIOD.start_date and TPERIOD.end_date
AND TPERIOD.end_date >= FND_DATE.CANONICAL_TO_DATE(target.AEI_INFORMATION1)
AND TPERIOD.start_date <= nvl(FND_DATE.CANONICAL_TO_DATE(target.AEI_INFORMATION2), TPERIOD.start_date)
AND to_char(TARGET.aei_information3) = 'F';
*/

/*
SELECT *
FROM per_assignment_extra_info
WHERE assignment_id = p_assignment_id
  AND aei_information_category = c_flex_context;
  --AND p_date_earned between fnd_date.canonical_to_date(aei_information1)
		--and nvl(fnd_date.canonical_to_date(aei_information2),to_Date('31/12/4712','dd/mm/yyyy'));
*/

l_extra_info csr_extra_info%ROWTYPE;
l_marginal_flag varchar2(1):='N';
--l_influence_code varchar2(1):='N';
l_influence_code varchar2(1):='X';
l_zvw_insure  varchar2(1):='N';

BEGIN

OPEN csr_extra_info('NL_MEI');
FETCH csr_extra_info INTO l_extra_info;
IF csr_extra_info%FOUND THEN
 l_marginal_flag:=l_extra_info.AEI_INFORMATION3;
END IF;
CLOSE csr_extra_info;
/*
FOR rec in csr_extra_info_Sm_job('NL_INF')
LOOP
IF csr_extra_info_Sm_job%FOUND THEN
 IF rec.AEI_INFORMATION3='F' THEN
   l_influence_code:='Y';
  END IF;
END IF;
END LOOP;
*/

FOR rec in csr_extra_info('NL_INF')
LOOP
IF csr_extra_info%FOUND THEN
 IF rec.AEI_INFORMATION4='Y' THEN
   l_influence_code:='Y';
 ELSIF rec.AEI_INFORMATION4='N' THEN
   l_influence_code:='N';
 END IF;
END IF;
END LOOP;

FOR rec in csr_extra_info('NL_SII')
LOOP
IF csr_extra_info%FOUND THEN
 IF rec.AEI_INFORMATION15='J' THEN
   l_zvw_insure:='Y';
 END IF;
END IF;
END LOOP;

IF l_influence_code='Y' and l_zvw_insure<>'Y'
THEN
 p_warning:=' Code ZVW Insured should be Insured with 0% due to small jobs';
END IF;

p_marginal_flag:= l_marginal_flag;
p_influence_flag:= l_influence_code;

return 1;
END chk_contribution_exempt;

FUNCTION get_age_payroll_period(p_assignment_id   IN  NUMBER
                               ,p_payroll_id      IN  NUMBER
                               ,p_date_earned     IN  DATE) RETURN NUMBER IS
  --
  -- Local variables
  --
  l_proc                 VARCHAR2(120) := g_package || 'get_age_payroll_period';
  l_period_start_date    DATE;
  l_period_end_date      DATE;
  l_dob                  DATE;
  l_age_last_day_month   NUMBER;
  --
  v_last_name varchar2(100);
  v_asg_number varchar2(50);

  --
  -- Cursor get_period_dates
  --
  CURSOR get_period_dates IS
  SELECT ptp.start_date     start_date
        ,ptp.end_date       end_date
  FROM   per_time_periods   ptp
  WHERE  ptp.payroll_id=p_payroll_id
  AND p_date_earned    BETWEEN ptp.start_date AND ptp.end_date;
  --
  -- Cursor get_db
  --
  CURSOR get_dob IS
  SELECT date_of_birth,per.last_name,paf.assignment_number
  FROM   per_all_people_f per
        ,per_all_assignments_f paf
  WHERE  per.person_id      = paf.person_id
  AND    paf.assignment_id  = p_assignment_id
  AND    p_date_earned       BETWEEN per.effective_start_date AND per.effective_end_date
  AND    p_date_earned       BETWEEN paf.effective_start_date AND paf.effective_end_date;
  --
BEGIN
  --
  --  hr_utility.set_location('Entering:'|| l_proc, 5);

  --
  OPEN get_period_dates;
    FETCH get_period_dates INTO l_period_start_date,l_period_end_date;
  CLOSE get_period_dates;
  --
  --
  --
  OPEN get_dob;
      FETCH get_dob INTO l_dob,v_last_name,v_asg_number;
  CLOSE get_dob;

  hr_utility.set_location('- Name   = '|| v_last_name, 5);
  hr_utility.set_location('- Asg No = '|| v_asg_number, 5);

  l_age_last_day_month := TRUNC(MONTHS_BETWEEN(last_day(p_date_earned),l_dob)/12);

  IF l_dob >= l_period_start_date AND l_dob <= l_period_end_date THEN
    RETURN(TRUNC(MONTHS_BETWEEN(l_period_end_date,l_dob)/12));
  ELSE
    IF l_age_last_day_month >= 65 THEN
    	RETURN l_age_last_day_month;
    ELSE
    	RETURN(TRUNC(MONTHS_BETWEEN(p_date_earned,l_dob)/12));
    END IF;
  END IF;
  --
  --  hr_utility.set_location('-l_dob = '|| l_dob, 5);
  --
END get_age_payroll_period;
  --
  --


  FUNCTION check_age_payroll_period(p_person_id   IN  NUMBER
                                 ,p_payroll_id      IN  NUMBER
                                 ,p_date_earned     IN  DATE) RETURN NUMBER IS
    --
    -- Local variables
    --
    l_proc                 VARCHAR2(120) := g_package || 'get_age_payroll_period';
    l_period_start_date    DATE;
    l_period_end_date      DATE;
    l_dob                  DATE;
    --
    -- Cursor get_period_dates
    --
    CURSOR get_period_dates IS
    SELECT ptp.start_date     start_date
          ,ptp.end_date       end_date
    FROM   per_time_periods   ptp
    WHERE  ptp.payroll_id=p_payroll_id
    AND p_date_earned    BETWEEN ptp.start_date AND ptp.end_date;
    --
    -- Cursor get_db
    --
    CURSOR get_dob IS
    SELECT date_of_birth
    FROM   per_all_people_f per
    WHERE  per.person_id      = p_person_id
    AND    p_date_earned       BETWEEN per.effective_start_date AND per.effective_end_date;

    --
  BEGIN

    OPEN get_period_dates;
      FETCH get_period_dates INTO l_period_start_date,l_period_end_date;
    CLOSE get_period_dates;
    --
    --
    --
    OPEN get_dob;
        FETCH get_dob INTO l_dob;
    CLOSE get_dob;


    IF l_dob >= l_period_start_date AND l_dob <= l_period_end_date THEN
      RETURN(TRUNC(MONTHS_BETWEEN(l_period_end_date,l_dob)/12));
    ELSE
      RETURN(TRUNC(MONTHS_BETWEEN(p_date_earned,l_dob)/12));
    END IF;
    --
    --
END check_age_payroll_period;
  --
  -- Function get_age_calendar_year determines the age of an employee on their birthday,
  -- which occurs in a specified calendar year and return the value.
  --
FUNCTION get_age_calendar_year(p_assignment_id   IN  NUMBER
                              ,p_date_earned     IN  DATE) RETURN NUMBER IS
  --
  -- Local variables
  --
  l_proc                 VARCHAR2(120) := g_package || 'get_age_calendar_year';
  l_dob                  DATE;
  l_last_date_tax_year   VARCHAR2(12):='31-12-';
  --
  -- Cursor get_db
  --
  CURSOR get_dob IS
  SELECT date_of_birth
  FROM   per_all_people_f per
        ,per_all_assignments_f paf
  WHERE  per.person_id      = paf.person_id
  AND    paf.assignment_id  = p_assignment_id
  AND    p_date_earned       BETWEEN per.effective_start_date AND per.effective_end_date
  AND    p_date_earned       BETWEEN paf.effective_start_date AND paf.effective_end_date;

  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  OPEN get_dob;
      FETCH get_dob INTO l_dob;
  CLOSE get_dob;
  --
  --Added Code to default DOB to current Date
  l_dob := NVL(l_dob,p_date_earned);
  l_last_date_tax_year := l_last_date_tax_year || to_char(p_date_earned,' YYYY');
  --
  RETURN(TRUNC(MONTHS_BETWEEN(to_date(l_last_date_tax_year,'DD-MM-YYYY'),l_dob)/12));
  --
END get_age_calendar_year;
--
--
FUNCTION get_age_system_date(p_assignment_id   IN  NUMBER
                             ,p_date_earned     IN  DATE) RETURN NUMBER IS
  --
  -- Local variables
  --
  l_dob                  DATE;
  l_system_date 	 DATE :=p_date_earned;
  --
  -- Cursor get_db
  --
  CURSOR get_dob IS
  SELECT date_of_birth
  FROM   per_all_people_f per
        ,per_all_assignments_f paf
  WHERE  per.person_id      = paf.person_id
  AND    paf.assignment_id  = p_assignment_id
  AND    l_system_date       BETWEEN per.effective_start_date AND per.effective_end_date
  AND    l_system_date       BETWEEN paf.effective_start_date AND paf.effective_end_date;

  --
BEGIN
  --
  --Code to default DOB to current Date
  l_system_date := NVL(l_system_date,sysdate);
  --
  OPEN get_dob;
      FETCH get_dob INTO l_dob;
  CLOSE get_dob;
  --
  l_dob := NVL(l_dob,l_system_date);
  --
  RETURN(TRUNC(MONTHS_BETWEEN(l_system_date,l_dob)/12));
  --
END get_age_system_date;
--
--
FUNCTION chk_lbr_tx_indicator (p_person_id number,p_assignment_id number)
				return	boolean is
--
--
-- Cursor get_lbr_tx_red_ind
--
   CURSOR get_lbr_tx_red_ind(p_person_id number,p_assignment_id number) IS
   SELECT scl.segment7
   FROM hr_soft_coding_keyflex scl,per_all_assignments_f paa,fnd_sessions ses
   WHERE
     paa.person_id=p_person_id and
     paa.assignment_id <> nvl(p_assignment_id,-1) and
     scl.soft_coding_keyflex_id=paa.soft_coding_keyflex_id and
     scl.segment7='Y' and
     ses.effective_date between nvl (paa.effective_start_date,sysdate) and
     nvl(paa.effective_end_date,sysdate) and
     ses.session_id = userenv ('sessionid');
--
-- Local variables
--
     l_proc      varchar2(72) := g_package || '.get_org_data_items';
     l_indicator varchar2(6);
     l_person_id number;
     l_found boolean:=TRUE;
--
--
BEGIN
	 OPEN  get_lbr_tx_red_ind(p_person_id,p_assignment_id);
	 FETCH get_lbr_tx_red_ind into l_indicator;
	 IF get_lbr_tx_red_ind%NOTFOUND THEN
	 l_found:=FALSE;
	 END IF;
	 close get_lbr_tx_red_ind;
	return l_found;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	l_found:=FALSE;
	return l_found;
        when others then
        hr_utility.set_location('Exception :'||l_proc||SQLERRM(SQLCODE),999);
END chk_lbr_tx_indicator;

FUNCTION get_payroll_prd(p_payroll_id number)
			RETURN VARCHAR2 IS
--
--
-- Cursor get_pay_prd
--
    CURSOR get_pay_prd(p_payroll_id NUMBER) IS
       SELECT pp.period_type
       FROM pay_payrolls_f pp,fnd_sessions ses
       WHERE
       pp.payroll_id=p_payroll_id and
       ses.effective_date between nvl(pp.effective_start_date,ses.effective_date) and
       nvl(pp.effective_end_date,ses.effective_date) and
      ses.session_id=userenv('sessionid');
--
-- Local variables
--
    l_pay_prd VARCHAR2(50);
    l_proc     varchar2(72) := g_package || '.get_org_data_items';
--
BEGIN
      OPEN get_pay_prd(p_payroll_id);
      FETCH get_pay_prd into l_pay_prd;
      return l_pay_prd;
      EXCEPTION
           when others then
               hr_utility.set_location('Exception :'||l_proc||SQLERRM(SQLCODE),999);
--
END get_payroll_prd;

PROCEDURE chk_tax_code (p_tax_code in varchar2,
                           p_pay_num in number,
                           p_1_digit out nocopy varchar2,
                           p_2_digit out nocopy varchar2,
                           p_3_digit out nocopy varchar2,
                           p_valid out nocopy boolean
                          ) IS
--
-- Local variables
--
    l_proc     varchar2(72);
    l_temp     number:= p_tax_code;
--
    BEGIN

    p_valid:=TRUE;
--hr_utility.set_location('tax code'||p_tax_code||'len'||length(p_tax_code),999);
    IF length(p_tax_code) <> 3 then
    	p_valid:=false;
    ELSE
		    p_1_digit:=to_number(substr(p_tax_code,1,1));
		    p_2_digit:=to_number(substr(p_tax_code,2,1));
		    p_3_digit:=to_number(substr(p_tax_code,3,1));

		    if p_1_digit not in(0,3,5,6,7,2,9) or p_2_digit not in(1,2) or p_3_digit<>p_pay_num then
		      p_valid:=FALSE;
		    end if;
		    if p_1_digit in (2,9) then
		     p_valid:=TRUE;
		     end if;
    END IF;
END chk_tax_code;

PROCEDURE get_period_type_code(p_payroll_prd in varchar2,p_period_type out nocopy varchar2,p_period_code out nocopy number) is
--
BEGIN
--
	IF p_payroll_prd = 'Quarter' THEN
		p_period_type :='1 - Quarterly';
		p_period_code :=1;
	ELSIF p_payroll_prd ='Calendar Month' THEN
		p_period_type :='2 - Monthly';
		p_period_code :=2;
	ELSIF p_payroll_prd = 'Week' THEN
		p_period_type :='3 - Weekly';
		p_period_code :=3;
	ELSIF p_payroll_prd = 'Lunar Month' THEN
		p_period_type :='4 - Four Weekly';
		p_period_code :=4;
	END IF;
END get_period_type_code;
--
PROCEDURE set_spl_inds(  p_spl_ind1 in varchar2
                        ,p_spl_ind2 in varchar2
                        ,p_spl_ind3 in varchar2
                        ,p_spl_ind4 in varchar2
                        ,p_spl_ind5 in varchar2
                        ,p_spl_ind6 in varchar2
                        ,p_spl_ind7 in varchar2
                        ,p_spl_ind8 in varchar2
                        ,p_spl_ind9 in varchar2
                        ,p_spl_ind10 in varchar2
                        ,p_spl_ind11 in varchar2
                        ,p_spl_ind12 in varchar2
                        ,p_spl_ind13 in varchar2
                        ,l_set out nocopy boolean
                        ,p_spl_ind out nocopy varchar2) IS
--
-- Local variables
--
    l_spl_ind varchar2(40):=null;
    i number:=1;
--
--Function to check if the special indicator is entered more than once
--
   FUNCTION chk_not_exists (p_segment varchar2)RETURN BOOLEAN Is
    l_flag BOOLEAN:=true;
    i number:=1;
BEGIN
    WHILE i < 26 LOOP
    if substr(p_spl_ind,i,i) is not null then
       if p_segment=substr(p_spl_ind,i,2) then
            l_flag:=false;
       end if;
    end if;
    i:=i+2;
    END LOOP;
    return l_flag;
END chk_not_exists;
--
BEGIN
    if (p_spl_ind1 is not null) then
      if(chk_not_exists(p_spl_ind1)) then
         p_spl_ind:=p_spl_ind||p_spl_ind1;
      else
         l_set:=true;
      end if;
    end if;
 --
    if (p_spl_ind2 is not null) then
          if(chk_not_exists(p_spl_ind2)) then
             p_spl_ind:=p_spl_ind||p_spl_ind2;
          else
             l_set:=true;
          end if;
    end if;
 --
    if (p_spl_ind3 is not null) then
          if(chk_not_exists(p_spl_ind3)) then
             p_spl_ind:=p_spl_ind||p_spl_ind3;
          else
             l_set:=true;
          end if;
    end if;
 --
    if (p_spl_ind4 is not null) then
          if(chk_not_exists(p_spl_ind4)) then
             p_spl_ind:=p_spl_ind||p_spl_ind4;
          else
             l_set:=true;
          end if;
    end if;
  --
  --
    if (p_spl_ind5 is not null) then
          if(chk_not_exists(p_spl_ind5)) then
             p_spl_ind:=p_spl_ind||p_spl_ind5;
          else
             l_set:=true;
          end if;
    end if;
  --
    if (p_spl_ind6 is not null) then
          if(chk_not_exists(p_spl_ind6)) then
             p_spl_ind:=p_spl_ind||p_spl_ind6;
          else
             l_set:=true;
          end if;
    end if;
  --
    if (p_spl_ind7 is not null) then
          if(chk_not_exists(p_spl_ind7)) then
             p_spl_ind:=p_spl_ind||p_spl_ind7;
          else
             l_set:=true;
          end if;
    end if;
  --
    if (p_spl_ind8 is not null) then
          if(chk_not_exists(p_spl_ind8)) then
             p_spl_ind:=p_spl_ind||p_spl_ind8;
          else
             l_set:=true;
          end if;
    end if;
  --
    if (p_spl_ind9 is not null) then
          if(chk_not_exists(p_spl_ind9)) then
             p_spl_ind:=p_spl_ind||p_spl_ind9;
          else
             l_set:=true;
          end if;
    end if;
  --
    if (p_spl_ind10 is not null) then
          if(chk_not_exists(p_spl_ind10)) then
             p_spl_ind:=p_spl_ind||p_spl_ind10;
          else
             l_set:=true;
          end if;
    end if;
  --
    if (p_spl_ind11 is not null) then
          if(chk_not_exists(p_spl_ind11)) then
             p_spl_ind:=p_spl_ind||p_spl_ind11;
          else
             l_set:=true;
          end if;
    end if;
  --
    if (p_spl_ind12 is not null) then
          if(chk_not_exists(p_spl_ind12)) then
             p_spl_ind:=p_spl_ind||p_spl_ind12;
          else
             l_set:=true;
          end if;
    end if;
  --
    if (p_spl_ind13 is not null) then
          if(chk_not_exists(p_spl_ind13)) then
             p_spl_ind:=p_spl_ind||p_spl_ind13;
          else
             l_set:=true;
          end if;
    end if;
  --
  --

 END set_spl_inds;

 PROCEDURE get_spl_inds( p_spl_ind in  varchar2
                         ,p_spl_ind1 out nocopy varchar2
                         ,p_spl_ind2 out nocopy varchar2
                         ,p_spl_ind3 out nocopy varchar2
                         ,p_spl_ind4 out nocopy varchar2
                         ,p_spl_ind5 out nocopy varchar2
                         ,p_spl_ind6 out nocopy varchar2
                         ,p_spl_ind7 out nocopy varchar2
                         ,p_spl_ind8 out nocopy varchar2
                         ,p_spl_ind9 out nocopy varchar2
                         ,p_spl_ind10 out nocopy varchar2
                         ,p_spl_ind11 out nocopy varchar2
                         ,p_spl_ind12 out nocopy varchar2
                         ,p_spl_ind13 out nocopy varchar2
                         ) IS
--
-- Local variables
--
    l_spl_ind varchar2(40):=p_spl_ind;
--
 begin
     p_spl_ind1:=substr(p_spl_ind,1,2);
     p_spl_ind2:=substr(p_spl_ind,3,2);
     p_spl_ind3:=substr(p_spl_ind,5,2);
     p_spl_ind4:=substr(p_spl_ind,7,2);
     p_spl_ind5:=substr(p_spl_ind,9,2);
     p_spl_ind6:=substr(p_spl_ind,11,2);
     p_spl_ind7:=substr(p_spl_ind,13,2);
     p_spl_ind8:=substr(p_spl_ind,15,2);
     p_spl_ind9:=substr(p_spl_ind,17,2);
     p_spl_ind10:=substr(p_spl_ind,19,2);
     p_spl_ind11:=substr(p_spl_ind,21,2);
     p_spl_ind12:=substr(p_spl_ind,23,2);
     p_spl_ind13:=substr(p_spl_ind,25,2);
 END get_spl_inds;
--

FUNCTION get_age_hire_date(p_business_group_id   IN  NUMBER
                               ,p_assignment_id      IN  NUMBER
                               ,p_date_earned     IN  DATE) RETURN NUMBER IS
--
  -- Local variables
  --
  l_dob                  DATE;
  l_hire_date 	         DATE;

  --Cursor to get hire date

  CURSOR get_hire_date IS
  SELECT date_start from
  per_periods_of_service pps,
  per_all_assignments_f paa
  where pps.person_id = paa.person_id
  and paa.assignment_id = p_assignment_id
  and pps.business_group_id = p_business_group_id
  and paa.business_group_id = p_business_group_id
  and p_date_earned between date_start and nvl(actual_termination_date,hr_general.end_of_time)
  and p_date_earned between paa.effective_start_date and paa.effective_end_date;
  --
  -- Cursor to get_dob
  --
  CURSOR get_dob IS
  SELECT date_of_birth
  FROM   per_all_people_f pap,
         per_all_assignments_f paa
  where  paa.person_id = pap.person_id
  and paa.assignment_id = p_assignment_id
  And p_date_earned between pap.effective_start_date and pap.effective_end_date
  and p_date_earned between paa.effective_start_date and paa.effective_end_date
  And pap.business_Group_id = p_business_group_id
  and paa.business_Group_id = p_business_group_id;

  l_age varchar2(10);


  --
BEGIN
  OPEN get_dob;
  FETCH get_dob INTO l_dob;
  CLOSE get_dob;
  --
  OPEN get_hire_date;
  FETCH get_hire_date INTO l_hire_date;
  CLOSE get_hire_date;
  --
  RETURN (TRUNC(MONTHS_BETWEEN(l_hire_date,l_dob)/12));
  --
END get_age_hire_date;

  FUNCTION check_age_date_paid(p_assignment_id   IN  NUMBER
                                 ,p_payroll_id      IN  NUMBER
                                 ,p_payroll_action_id    IN  NUMBER) RETURN NUMBER IS
    --
    -- Local variables
    --
    l_proc                 VARCHAR2(120) := g_package || 'check_age_date_paid';
    l_period_start_date    DATE;
    l_period_end_date      DATE;
    l_dob                  DATE;
    l_date_paid            DATE;
    --
    -- Cursor to get the date paid
    --
    Cursor get_paid_date IS
    SELECT effective_date
    FROM PAY_PAYROLL_ACTIONS
    WHERE payroll_action_id = p_payroll_action_id;

    --
    -- Cursor get_period_dates
    --
    CURSOR get_period_dates IS
    SELECT ptp.start_date     start_date
          ,ptp.end_date       end_date
    FROM   per_time_periods   ptp
    WHERE  ptp.payroll_id=p_payroll_id
    AND l_date_paid    BETWEEN ptp.start_date AND ptp.end_date;
    --
    -- Cursor get_db
    --
  CURSOR get_dob IS
  SELECT date_of_birth
  FROM   per_all_people_f per
        ,per_all_assignments_f paf
  WHERE  per.person_id      = paf.person_id
  AND    paf.assignment_id  = p_assignment_id
  AND    l_date_paid       BETWEEN per.effective_start_date AND per.effective_end_date
  AND    l_date_paid       BETWEEN paf.effective_start_date AND paf.effective_end_date;

    --
  BEGIN

    OPEN get_paid_date;
      FETCH get_paid_date INTO l_date_paid;
    CLOSE get_paid_date;

    OPEN get_period_dates;
      FETCH get_period_dates INTO l_period_start_date,l_period_end_date;
    CLOSE get_period_dates;
    --
    --
    --
    OPEN get_dob;
        FETCH get_dob INTO l_dob;
    CLOSE get_dob;


    IF l_dob >= l_period_start_date AND l_dob <= l_period_end_date THEN
      RETURN(TRUNC(MONTHS_BETWEEN(l_period_end_date,l_dob)/12));
    ELSE
      RETURN(TRUNC(MONTHS_BETWEEN(l_date_paid,l_dob)/12));
    END IF;
    --
    --
END check_age_date_paid;

END PAY_NL_TAX_PKG;

/
