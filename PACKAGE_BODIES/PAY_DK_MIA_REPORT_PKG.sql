--------------------------------------------------------
--  DDL for Package Body PAY_DK_MIA_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_MIA_REPORT_PKG" as
/* $Header: pydkmiar.pkb 120.0 2006/01/18 05:20:27 pgopal noship $ */

--Global parameters
 g_package                  CONSTANT varchar2(33) := 'PAY_DK_MIA_REPORT_PKG.';

-----------------------------------------------------------------------------
--RANGE CODE
-----------------------------------------------------------------------------
PROCEDURE range_cursor(p_payroll_action_id     IN  NUMBER,
                       p_sqlstr OUT NOCOPY VARCHAR2)
IS
BEGIN
	p_sqlstr := 'SELECT 1 FROM dual WHERE to_char(:payroll_action_id) = dummy';
END range_cursor;

-----------------------------------------------------------------------------
--ASSIGNMENT ACTION CODE
-----------------------------------------------------------------------------
PROCEDURE assignment_action_code(
                          pactid    IN NUMBER,
                          stperson  IN NUMBER,
                          endperson IN NUMBER,
                          chunk     IN NUMBER)
IS
BEGIN
	null;
END assignment_action_code;


 -----------------------------------------------------------------------------
 -- GET_PARAMETER  used in SQL to decode legislative parameters
 -----------------------------------------------------------------------------
FUNCTION get_parameter(
                 p_parameter_string  IN VARCHAR2
                ,p_token             IN VARCHAR2
                ,p_segment_number    IN NUMBER DEFAULT NULL ) RETURN VARCHAR2
 IS
   l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
   l_start_pos  NUMBER;
   l_delimiter  varchar2(1);
   l_proc VARCHAR2(60);

 BEGIN
   l_delimiter :=' ';
   l_proc := g_package||' get parameter ';
   l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');

   IF l_start_pos = 0 THEN
     l_delimiter := '|';
     l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
   END IF;

   IF l_start_pos <> 0 THEN
     l_start_pos := l_start_pos + length(p_token||'=');
     l_parameter := substr(p_parameter_string,
                           l_start_pos,
                           instr(p_parameter_string||' ',
                           ',',l_start_pos)
                           - l_start_pos);

     IF p_segment_number IS NOT NULL THEN
       l_parameter := ':'||l_parameter||':';
       l_parameter := substr(l_parameter,
                             instr(l_parameter,':',1,p_segment_number)+1,
                             instr(l_parameter,':',1,p_segment_number+1) -1
                             - instr(l_parameter,':',1,p_segment_number));
     END IF;

   END IF;

   RETURN l_parameter;
 END get_parameter;


FUNCTION get_cp_parameter(
                              p_payroll_action_id   NUMBER
			     ,p_token_name          VARCHAR2) RETURN VARCHAR2 AS

CURSOR csr_parameter_info(p_pact_id IN NUMBER) IS
SELECT legislative_parameters
FROM   pay_payroll_actions
WHERE  payroll_action_id = p_pact_id;

l_token_value   VARCHAR2(50);
l_parameter  pay_payroll_actions.legislative_parameters%TYPE ;
l_delimiter  varchar2(1);
l_start_pos  NUMBER;

BEGIN
--
  l_parameter   := NULL;
  l_delimiter   :=',';
  hr_utility.set_location('p_token_name = ' || p_token_name,20);

  OPEN csr_parameter_info(p_payroll_action_id);
  FETCH csr_parameter_info INTO l_parameter;
  CLOSE csr_parameter_info;

  l_start_pos := instr(l_parameter,p_token_name||'=');
  IF l_start_pos = 0 THEN
    l_delimiter := '|';
    l_start_pos := instr(l_parameter,p_token_name||'=');
  END IF;

  IF l_start_pos <> 0 THEN
   l_start_pos := l_start_pos + length(p_token_name||'=');
    l_token_value := substr(l_parameter,
                          l_start_pos,
                          instr(l_parameter||' ',
                          l_delimiter,l_start_pos)
                          - l_start_pos);
   END IF;
--
     l_token_value := trim(l_token_value);
     l_token_value := l_token_value || ' ';

     if length(l_token_value) = 1 then
        l_token_value :='-1';
     else
	l_token_value := trim(l_token_value);
     end if;

--
  hr_utility.set_location('l_token_value = ' || l_token_value,20);
  hr_utility.set_location('Leaving         ' || 'get_parameters',30);

  RETURN l_token_value;
END get_cp_parameter;


FUNCTION get_period_dates(
                 p_payroll_id          IN VARCHAR2
		,p_payroll_action_id   IN VARCHAR2
                ,p_start_date          OUT NOCOPY VARCHAR2
                ,p_end_date            OUT NOCOPY VARCHAR2
                ,p_direct_dd_date      OUT NOCOPY VARCHAR2)RETURN VARCHAR2 AS

cursor csr_get_eff_date(l_payroll_action_id  IN NUMBER) is
select effective_date from pay_payroll_actions
where payroll_action_id = l_payroll_action_id;

cursor csr_get_period_dates(l_payroll_id IN NUMBER, l_effective_date IN DATE) is
select to_char(start_date,'YYYYMMDD'), to_char(end_date,'YYYYMMDD'), to_char(default_dd_date,'YYYYMMDD')
from per_time_periods
where payroll_id = l_payroll_id
and l_effective_date between start_date and end_date;

l_payroll_id NUMBER;
l_payroll_action_id NUMBER;
l_effective_date DATE;
l_start_date VARCHAR2(8);
l_end_date VARCHAR2(8);
l_direct_dd_date VARCHAR2(8);

begin
l_payroll_id := to_number(p_payroll_id);
l_payroll_action_id := to_number(p_payroll_action_id);

open csr_get_eff_date(l_payroll_action_id);
fetch csr_get_eff_date into l_effective_date;
close csr_get_eff_date;

open csr_get_period_dates(l_payroll_id,l_effective_date);
fetch csr_get_period_dates into l_start_date,l_end_date,l_direct_dd_date;
close csr_get_period_dates;

p_start_date := l_start_date;
p_end_date := l_end_date;
p_direct_dd_date := l_direct_dd_date;
return '1';

exception
when others then
  return '0';

end get_period_dates;

/*
FUNCTION get_payroll_period(
                 p_payroll_id          IN VARCHAR2
		,p_payroll_action_id   IN VARCHAR2)RETURN VARCHAR2 AS

cursor csr_get_eff_date(l_payroll_action_id  IN NUMBER) is
select effective_date from pay_payroll_actions
where payroll_action_id = l_payroll_action_id;

cursor csr_get_payroll_period(l_payroll_id IN NUMBER, l_effective_date IN DATE) is
select period_name,period_num
from per_time_periods
where payroll_id = l_payroll_id
and l_effective_date between start_date and end_date;

l_payroll_id NUMBER(9);
l_payroll_action_id NUMBER(9);
l_effective_date DATE;
l_period_name VARCHAR2(70);
l_period_num NUMBER(15);
l_year varchar2(10);
l_pp varchar2(5);
l_period VARCHAR2(20);

begin
l_payroll_id := to_number(p_payroll_id);
l_payroll_action_id := to_number(p_payroll_action_id);

open csr_get_eff_date(l_payroll_action_id);
fetch csr_get_eff_date into l_effective_date;
close csr_get_eff_date;

open csr_get_payroll_period(l_payroll_id,l_effective_date);
fetch csr_get_payroll_period into l_period_name,l_period_num;
close csr_get_payroll_period;

l_year := substr(l_period_name,1,10);
l_year := substr(l_year, instr(l_year,' ')+1,4);

if l_period_num <= 9 then
   l_pp := substr('0'||ltrim(rtrim(to_char(l_period_num))),1,2);
else
   l_pp := substr(ltrim(rtrim(to_char(l_period_num))),1,2);
end if;

l_period := l_year || l_pp;
l_period := substr(l_period,1,6);
return l_period;

end get_payroll_period;
*/

FUNCTION get_taxable_pay
   (p_assignment_action_id     IN  VARCHAR2) RETURN NUMBER as
     /* cursor to get defined balance id */

     cursor csr_get_defined_balance_id(p_balance_name IN VARCHAR2, p_dbi_suffix IN VARCHAR2) is
     SELECT pdb.defined_balance_id
     FROM   pay_defined_balances      pdb
            ,pay_balance_types         pbt
            ,pay_balance_dimensions    pbd
      WHERE  pbd.database_item_suffix = p_dbi_suffix
      AND    pbd.legislation_code = 'DK'
      AND    pbt.balance_name = p_balance_name
      AND    pbt.legislation_code = 'DK'
      AND    pdb.balance_type_id = pbt.balance_type_id
      AND    pdb.balance_dimension_id = pbd.balance_dimension_id
      AND    pdb.legislation_code = 'DK';

   l_defined_balance_id         NUMBER;
   l_balance_name		VARCHAR2(30);
   l_dbi_suffix			VARCHAR2(30);
   l_taxable_pay	        NUMBER;

 BEGIN
   l_balance_name :='Taxable Pay';
   l_dbi_suffix := '_ASG_PTD';

   open csr_get_defined_balance_id(l_balance_name,l_dbi_suffix);
   fetch csr_get_defined_balance_id into l_defined_balance_id;
   close csr_get_defined_balance_id;

   l_defined_balance_id := NVL(l_defined_balance_id,0);
   l_taxable_pay := pay_balance_pkg.get_value(l_defined_balance_id,p_assignment_action_id);

 RETURN l_taxable_pay ;
 END get_taxable_pay;


 FUNCTION get_sp_name(p_business_group_id IN NUMBER) RETURN VARCHAR2 as

 CURSOR csr_get_sp_name(p_business_group_id NUMBER) is
 SELECT name from hr_organization_units where organization_id =
		 (select organization_id from hr_organization_information where org_information_context = 'DK_SERVICE_PROVIDER_DETAILS')
		 and business_group_id = p_business_group_id;

  l_sp_name VARCHAR2(50);

  begin
  OPEN csr_get_sp_name(p_business_group_id);
  FETCH csr_get_sp_name INTO l_sp_name;

  IF csr_get_sp_name%NOTFOUND then
     l_sp_name := '-1';
  END IF;

  CLOSE csr_get_sp_name;

  RETURN l_sp_name;

  END get_sp_name;

  FUNCTION get_sp_details(p_payroll_action_id IN number
			 ,p_cvr_no OUT NOCOPY varchar2
			 ,p_sp_name OUT NOCOPY varchar2
			 ,p_org_address OUT NOCOPY varchar2
			 ,p_town OUT NOCOPY varchar2) RETURN VARCHAR2 as

 CURSOR csr_get_sp_details(p_payroll_action_id NUMBER) is
 SELECT hou.name , hoi.ORG_INFORMATION1,
        substr((loc.ADDRESS_LINE_1||' '||loc.ADDRESS_LINE_2||' '||loc.ADDRESS_LINE_3),1,40),
	substr((loc.POSTAL_CODE ||' ' || loc.TOWN_OR_CITY),1,40)
 from hr_organization_units hou, hr_organization_information hoi, hr_locations loc
 where hou.business_group_id = get_business_group_id(p_payroll_action_id) -- change the bg id
 AND hoi.organization_id = hou.organization_id
 and hoi.org_information_context='DK_SERVICE_PROVIDER_DETAILS'
 and hou.location_id=loc.location_id;

 l_cvr_no VARCHAR2(8);
 l_sp_name VARCHAR2(40);
 l_org_address varchar2(40);
 l_town varchar2(40);

 BEGIN
 OPEN csr_get_sp_details(p_payroll_action_id);
 FETCH csr_get_sp_details INTO l_sp_name,l_cvr_no,l_org_address,l_town;
 IF csr_get_sp_details%NOTFOUND then
    l_cvr_no :='-1';
    l_sp_name :='-1';
    l_org_address :='-1';
    l_town :='-1';
 END IF;

 CLOSE csr_get_sp_details;
 p_cvr_no := l_cvr_no;
 p_sp_name := l_sp_name;
 p_org_address := l_org_address;
 p_town := l_town;


 RETURN '1';

 END get_sp_details;


FUNCTION get_business_group_id(p_payroll_action_id IN number) RETURN NUMBER as
  CURSOR csr_get_bg_id(p_payroll_action_id number) is
  SELECT business_group_id
  FROM pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;

  l_bg_id NUMBER(15);

  begin
  OPEN csr_get_bg_id(p_payroll_action_id);
  FETCH csr_get_bg_id INTO l_bg_id;
  CLOSE csr_get_bg_id;

  RETURN l_bg_id;

  END get_business_group_id;


  FUNCTION get_dd_date(p_payroll_id IN NUMBER,
		       p_effective_date IN DATE) RETURN VARCHAR2 as

  CURSOR csr_get_dd_date(p_payroll_id NUMBER,p_effective_date DATE) is
  SELECT TO_CHAR(to_date(substr(legislative_parameters,instr(legislative_parameters,'=')+1,10),'YYYY/MM/DD'),'YYYYMMDD')
  FROM pay_payroll_actions
  where payroll_action_id = (select min(payroll_action_id) from pay_payroll_actions
			     where payroll_id = p_payroll_id
			     and action_type ='M'
			     AND action_status ='C'
			     AND p_effective_date BETWEEN start_date AND effective_date);


  l_dd_date VARCHAR2(8);

  BEGIN

  OPEN csr_get_dd_date(p_payroll_id,p_effective_date);
  FETCH csr_get_dd_date INTO l_dd_date;

  IF csr_get_dd_date%NOTFOUND then
     l_dd_date := lpad(' ',8);
  END IF;

  CLOSE csr_get_dd_date;

  RETURN l_dd_date;

  END get_dd_date;


  FUNCTION check_termination_date(p_start_date varchar2,
				  p_end_date varchar2,
				  p_termination_date varchar2) RETURN varchar2 as

  CURSOR csr_check_termination(p_start_date DATE,p_end_date DATE,p_termination_date DATE) is
  SELECT '1' FROM dual
  WHERE p_termination_date BETWEEN p_start_date AND p_end_date;

  l_start_date DATE;
  l_end_date DATE;
  l_termination_date DATE;
  l_value varchar2(1);
  --l_return number;

  begin

  l_start_date := to_date(p_start_date,'YYYYMMDD');
  l_end_date:= to_date(p_end_date,'YYYYMMDD');
  l_termination_date := to_date(p_termination_date,'YYYYMMDD');

  OPEN csr_check_termination(l_start_date,l_end_date,l_termination_date);
  FETCH csr_check_termination INTO l_value;
  IF csr_check_termination%NOTFOUND then
     l_value := '0';
  END if;
  CLOSE csr_check_termination;


  RETURN l_value;

  END check_termination_date;


END PAY_DK_MIA_REPORT_PKG;


/
