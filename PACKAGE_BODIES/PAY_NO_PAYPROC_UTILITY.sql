--------------------------------------------------------
--  DDL for Package Body PAY_NO_PAYPROC_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_PAYPROC_UTILITY" AS
 /* $Header: pynopprocu.pkb 120.0 2005/05/29 10:52:25 appldev noship $ */

l_package    CONSTANT VARCHAR2(20):= 'PAY_NO_PAYPROC.';

FUNCTION get_payment_method_id   (
                             p_payroll_id IN number,
			     p_effective_date in date
                             ) return number IS

cursor csr_payment_method_id
is
select paf.DEFAULT_PAYMENT_METHOD_ID
from pay_payrolls_f paf
where paf.payroll_id = p_payroll_id
  and p_effective_date between paf.effective_start_date and paf.effective_end_date;

l_payment_method_id          pay_payrolls_f.DEFAULT_PAYMENT_METHOD_ID%TYPE;

 begin

 open csr_payment_method_id;
 fetch csr_payment_method_id into l_payment_method_id;
 close csr_payment_method_id;

 RETURN l_payment_method_id;

 end get_payment_method_id;
 -------------------------------------------------------------------------------------------------------------------------------------------------------------
 FUNCTION get_account_no   (
                             p_personal_method_id  in number,
			     p_payroll_id in number,
			     p_effective_date in date
                             ) return number
IS

cursor csr_payment
is
select ppm.external_account_id
from pay_personal_payment_methods_f ppm
where ppm.personal_payment_method_id=p_personal_method_id
 and p_effective_date between ppm.effective_start_date and ppm.effective_end_date;

cursor csr_payment_method_id
is
select paf.DEFAULT_PAYMENT_METHOD_ID
from pay_payrolls_f paf
where paf.payroll_id = p_payroll_id
 and p_effective_date between paf.effective_start_date and paf.effective_end_date;

  l_payment                   pay_personal_payment_methods_f.external_account_id%TYPE;
  l_personal_method_id        pay_payrolls_f.DEFAULT_PAYMENT_METHOD_ID%TYPE;
  l_account_id                pay_personal_payment_methods_f.external_account_id%TYPE;



 begin

if p_personal_method_id is null then

     open csr_payment;
     fetch csr_payment into l_payment;
     close csr_payment;
     return l_payment;
else
     open csr_payment_method_id;
     fetch csr_payment_method_id into l_personal_method_id;
     close csr_payment_method_id;

      select ppm.external_account_id into l_account_id
      from pay_personal_payment_methods_f ppm
      where ppm.personal_payment_method_id=l_personal_method_id
        and p_effective_date between ppm.effective_start_date and ppm.effective_end_date;

         RETURN l_account_id;
end if;

 end get_account_no;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION get_payment_invoice_or_mass   (
                             p_personal_method_id  in number,
			     p_payroll_id in number,
			     p_effective_date in date
                             ) return number
IS

cursor csr_payment
is
select ppm.external_account_id
from pay_personal_payment_methods_f ppm
where ppm.personal_payment_method_id=p_personal_method_id
  and p_effective_date between ppm.effective_start_date and ppm.effective_end_date;


 l_payment              pay_personal_payment_methods_f.external_account_id%TYPE;


 begin

if p_personal_method_id is not null then

     open csr_payment;
     fetch csr_payment into l_payment;
     close csr_payment;

     if l_payment is null then
       RETURN 2; -- invoice
     else
       RETURN 1; -- Mass
     end if;

else
      RETURN 2; -- invoice
end if;

 end get_payment_invoice_or_mass;
----------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION get_parameter(
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
  l_delimiter   :=' ';

  hr_utility.set_location('p_token_name = ' || p_token_name,20);
  OPEN csr_parameter_info(p_payroll_action_id);
  FETCH csr_parameter_info INTO l_parameter;
  CLOSE csr_parameter_info;
  l_start_pos := instr(' '||l_parameter,l_delimiter||p_token_name||'=');
 IF l_start_pos = 0 THEN
    l_delimiter := '|';
    l_start_pos := instr(' '||l_parameter,l_delimiter||p_token_name||'=');
  end if;
  IF l_start_pos <> 0 THEN
   l_start_pos := l_start_pos + length(p_token_name||'=');
    l_token_value := substr(l_parameter,
                          l_start_pos,
                          instr(l_parameter||' ',
                          l_delimiter,l_start_pos)
                          - l_start_pos);
                          end if;
--
     l_token_value := trim(l_token_value);
--
  hr_utility.set_location('l_token_value = ' || l_token_value,20);
  hr_utility.set_location('Leaving         ' || 'get_parameters',30);

  RETURN l_token_value;

END get_parameter;
--------------------------------------------------------------------------------------------------------

end  PAY_NO_PAYPROC_UTILITY;

/
