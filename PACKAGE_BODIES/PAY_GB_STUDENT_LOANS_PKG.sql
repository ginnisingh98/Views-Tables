--------------------------------------------------------
--  DDL for Package Body PAY_GB_STUDENT_LOANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_STUDENT_LOANS_PKG" AS
/* $Header: pygbslco.pkb 120.6 2006/06/20 14:52:54 npershad noship $ */

g_package_functions varchar2(50) := 'pay_gb_student_loans_pkg';
g_asg_id NUMBER;
g_count_main_cto_entry NUMBER := 0;

--
-- Private declarations
--

g_package VARCHAR2(31) := 'PAY_GB_TAX_CREDIT_PKG';

FUNCTION Get_Input_Value_Id(
             p_name in VARCHAR2,
             p_effective_date in DATE
          ) RETURN NUMBER is
l_input_value_id PAY_INPUT_VALUES_F.input_value_id%TYPE;

BEGIN

  SELECT ipv.input_value_id INTO l_input_value_id
  FROM   PAY_INPUT_VALUES_F ipv,
         PAY_ELEMENT_TYPES_F ele
  WHERE  ele.element_name = 'Student Loan'
  and    ele.legislation_code = 'GB'
  AND    ipv.name = p_name
  and    ipv.legislation_code = 'GB'
  AND    ele.element_type_id = ipv.element_type_id
  AND    p_effective_date between ele.effective_start_date
                              and ele.effective_end_date
  AND    p_effective_date between ipv.effective_start_date
                              and ipv.effective_end_date;

RETURN l_input_value_id;

END Get_Input_Value_Id;

--
-- Public Declarations
--

PROCEDURE Fetch_Balances(
            p_assignment_id in PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ID%TYPE,
            p_element_type_id in PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_Id%TYPE,
            p_element_name in PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE,
            p_element_entry_id in PAY_RUN_RESULTS.SOURCE_ID%TYPE,
            p_itd_balance   OUT NOCOPY NUMBER,
            p_ptd_balance   OUT NOCOPY NUMBER
             ) is

cursor c_balance_id(p_name in VARCHAR2) is
  select balance_type_id
  from   pay_balance_types
  where  balance_name = p_name
  and    legislation_code = 'GB';

cursor c_itd_asgact(p_asg in NUMBER,
                    p_ent_id in NUMBER,
                    p_element_type_id in NUMBER) is
 select prr.assignment_action_id,
        prr.source_id
 from   pay_run_results prr,
        pay_element_types_f ele
 where  prr.assignment_action_id in (
 SELECT /*+ use_nl(paa,ppa,ptp,ses) */
        to_number(substr(max(lpad(paa.action_sequence,15,'0')||
                  paa.assignment_action_id),16))
 FROM   pay_assignment_actions paa,
        pay_payroll_actions    ppa,
        per_time_periods       ptp,
        fnd_sessions           ses
 WHERE  paa.assignment_id = p_asg
 AND    paa.action_status = 'C'
 AND    ses.session_id = userenv('sessionid')
 AND    ppa.payroll_action_id = paa.payroll_action_id
 AND    ses.effective_date between ptp.start_date and ptp.end_date
 AND    ppa.time_period_id = ptp.time_period_id
 AND    (paa.source_action_id is not null
         or ppa.action_type in ('I','V','B'))
 AND    ppa.action_type in ('R', 'Q', 'I', 'V', 'B'))
 AND    prr.element_type_id = ele.element_type_id
 AND    prr.source_id = p_ent_id;

cursor c_ptd_asgact(p_asg in NUMBER,
                    p_ent in NUMBER,
                    p_element_type_id in NUMBER) is
select prr.assignment_action_id,
       prr.source_id
from   pay_run_results prr,
       pay_element_types_f ele
where  prr.assignment_action_id in (
SELECT /*+ use_nl(paa,ppa,ptp,ses) */
       to_number(substr(max(lpad(paa.action_sequence,15,'0')||
                 paa.assignment_action_id),16))
FROM   pay_assignment_actions paa,
       pay_payroll_actions    ppa,
       fnd_sessions           ses,
       per_time_periods       ptp
WHERE  paa.assignment_id = p_asg
AND    paa.action_status = 'C'
AND    ses.session_id = userenv('sessionid')
AND    ptp.payroll_id = ppa.payroll_id
AND    ses.effective_date between ptp.start_date and ptp.end_date
AND    ppa.effective_date between ptp.start_date and ptp.end_date
AND    ppa.payroll_action_id = paa.payroll_action_id
AND    (paa.source_action_id is not null
        or ppa.action_type in ('I','V','B'))
AND    ppa.action_type in ('R', 'Q', 'I', 'V', 'B'))
AND    prr.element_type_id = ele.element_type_id
and    ele.element_type_id = p_element_type_id
and    prr.source_id = p_ent;

l_proc VARCHAR(72) := g_package||'.FETCH_BALANCES';
l_itd_action_id PAY_ASSIGNMENT_ACTIONS.assignment_action_id%TYPE;
l_itd_source_id PAY_RUN_RESULTS.source_id%TYPE;
l_ptd_action_id PAY_ASSIGNMENT_ACTIONS.assignment_action_id%TYPE;
l_ptd_source_id PAY_RUN_RESULTS.source_id%TYPE;
l_balance_type_id PAY_BALANCE_TYPES.balance_type_id%TYPE;
l_balance_type_id2 PAY_BALANCE_TYPES.balance_type_id%TYPE;
l_effective_date DATE;
l_name PAY_BALANCE_TYPES.BALANCE_NAME%TYPE;
l_name2 PAY_BALANCE_TYPES.BALANCE_NAME%TYPE;

BEGIN

hr_utility.set_location('Entering..'||l_proc,10);

If p_element_name='Student Loan' then
   l_name := 'Student Loan';
elsif instr(upper(p_element_name),'COURT') >0 then
   l_name := 'Court Order';
elsif instr(upper(p_element_name),'CAO SCOTLAND') >0 then
   l_name := 'CAO Scotland Payments CMA';
   l_name2 := 'CAO Scotland Payments EAS';
elsif instr(upper(p_element_name),'CMA SCOTLAND') >0 then
   l_name := 'CMA Scotland';
elsif instr(upper(p_element_name),'EAS SCOTLAND') >0 then
   l_name := 'EAS Scotland';
end if;

open c_balance_id(l_name);
fetch c_balance_id into l_balance_type_id;
close c_balance_id;

if l_name2 is not null then
  open c_balance_id(l_name2);
  fetch c_balance_id into l_balance_type_id2;
  close c_balance_id;
end if;

open c_ptd_asgact(p_assignment_id,p_element_entry_id,p_element_type_id);
fetch c_ptd_asgact into l_ptd_action_id,l_ptd_source_id;

if c_ptd_asgact%NOTFOUND then

   p_ptd_balance := NULL;
   close c_ptd_asgact;
else
  if l_name = 'Court Order' then
   p_ptd_balance := NVL(hr_gbbal.calc_element_ptd_bal(
                      l_ptd_action_id,
                      l_balance_type_id,
                      l_ptd_source_id),0.00);
  elsif l_name = 'Student Loan' then
   p_ptd_balance := NVL(hr_gbbal.calc_asg_tfr_ptd_action(
                        l_ptd_action_id,
                        l_balance_type_id,
                        NULL),0.00);
  elsif l_name = 'CAO Scotland Payments CMA' then
   p_ptd_balance := NVL(hr_gbbal.calc_asg_proc_ptd_action(
				    l_ptd_action_id,
				    l_balance_type_id,
				    NULL),0.00) +
                    NVL(hr_gbbal.calc_asg_proc_ptd_action(
				    l_ptd_action_id,
				    l_balance_type_id2,
				    NULL),0.00);
  else
   p_ptd_balance := NVL(hr_gbbal.calc_asg_proc_ptd_action(
				    l_ptd_action_id,
				    l_balance_type_id,
				    NULL),0.00);
  end if;
   close c_ptd_asgact;

end if;

open c_itd_asgact(p_assignment_id,p_element_entry_id,p_element_type_id);
fetch c_itd_asgact into l_itd_action_id,l_itd_source_id;

if c_itd_asgact%NOTFOUND then
   p_itd_balance := NULL;
   close c_itd_asgact;
else
  if l_name = 'Court Order' then
   p_itd_balance := NVL(hr_gbbal.calc_element_itd_bal(
                      l_itd_action_id,
                      l_balance_type_id,
                      l_itd_source_id),0.00);
  elsif l_name = 'Student Loan' then

/* Use the same variables, even though they are really for itd,
   and let the balance retrieval code handle the expiration */

   p_itd_balance := NVL(hr_gbbal.calc_asg_td_ytd_action(
                         l_itd_action_id,
                         l_balance_type_id,
                         NULL),0.00);
  else

/* There are no ITD or YTD for Scottish Court Orders so set the
   itd balance to null */

   p_itd_balance := null;
  end if;
   close c_itd_asgact;
end if;

hr_utility.set_location('leaving..'||l_proc,20);

END Fetch_Balances;

PROCEDURE Update_Court_Order(
            p_datetrack_update_mode in     varchar2
           ,p_effective_date        in     date
           ,p_business_group_id     in     number
           ,p_element_entry_id      in     number
           ,p_object_version_number in out nocopy number
           ,p_subpriority           in     number
           ,p_effective_start_date     out nocopy date
           ,p_effective_end_date       out nocopy date) is

l_update_warning BOOLEAN;

BEGIN

py_element_entry_api.update_element_entry(
    p_validate => FALSE,
    p_datetrack_update_mode => p_datetrack_update_mode,
    p_effective_date => p_effective_date,
    p_business_group_id => p_business_group_id,
    p_element_entry_id => p_element_entry_id,
    p_object_version_number => p_object_version_number,
    p_subpriority => p_subpriority,
    P_EFFECTIVE_START_DATE      =>p_effective_start_date,
    P_EFFECTIVE_END_DATE        =>p_effective_end_date,
    P_UPDATE_WARNING            =>l_update_warning);
--
-- Done the update
--

END Update_Court_Order;

PROCEDURE Create_Student_Loan(
           P_EFFECTIVE_DATE         in     Date,
           P_BUSINESS_GROUP_ID      in     Number,
           P_ASSIGNMENT_ID          in     Number,
           P_START_DATE             in     Varchar2,
           P_END_DATE               in     Varchar2,
           P_SUBPRIORITY            in     Number,
           P_EFFECTIVE_START_DATE      out nocopy Date,
           P_EFFECTIVE_END_DATE        out nocopy Date,
           P_ELEMENT_ENTRY_ID          out nocopy Number,
           P_OBJECT_VERSION_NUMBER     out nocopy Number) is

cursor c_effective_date is
   select effective_date
   from   fnd_sessions
   where  session_id = userenv('sessionid');

cursor c_element_type is
   select element_type_id
   from   pay_element_types_f
   where  element_name = 'Student Loan'
   and legislation_code = 'GB';

l_element_link_id PAY_ELEMENT_LINKS_F.ELEMENT_LINK_ID%TYPE;
l_element_id PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID%TYPE;
l_create_warning BOOLEAN;
l_effective_date DATE;

BEGIN

--
-- Obtain the element link using the element type and
-- the assignment (payroll)
--
/* this is not needed, instead use the effective date passed
in the parameter
open  c_effective_date;
fetch c_effective_date into l_effective_date;
close c_effective_date;
*/
l_effective_date := P_EFFECTIVE_DATE;
open  c_element_type;
fetch c_element_type into l_element_id;
close c_element_type;

l_element_link_id := hr_entry_api.get_link(
							    p_assignment_id,
							    l_element_id,
							    l_effective_date);
--
-- Create the entry
--
py_element_entry_api.create_element_entry(
 P_VALIDATE                  =>FALSE,
 P_EFFECTIVE_DATE            =>p_effective_date,
 P_BUSINESS_GROUP_ID         =>p_business_group_id,
 P_ORIGINAL_ENTRY_ID         =>NULL,
 P_ASSIGNMENT_ID             =>p_assignment_id,
 P_ELEMENT_LINK_ID           =>l_element_link_id,
 P_ENTRY_TYPE                =>'E',
 P_COST_ALLOCATION_KEYFLEX_ID=>NULL,
 P_UPDATING_ACTION_ID        =>NULL,
 P_COMMENT_ID                =>NULL,
 P_REASON                    =>NULL,
 P_TARGET_ENTRY_ID           =>NULL,
 P_SUBPRIORITY               =>P_SUBPRIORITY,
 P_DATE_EARNED               =>NULL,
 P_PERSONAL_PAYMENT_METHOD_ID=>NULL,
 P_ATTRIBUTE_CATEGORY        =>NULL,
 P_ATTRIBUTE1                =>NULL,
 P_ATTRIBUTE2                =>NULL,
 P_ATTRIBUTE3                =>NULL,
 P_ATTRIBUTE4                =>NULL,
 P_ATTRIBUTE5                =>NULL,
 P_ATTRIBUTE6                =>NULL,
 P_ATTRIBUTE7                =>NULL,
 P_ATTRIBUTE8                =>NULL,
 P_ATTRIBUTE9                =>NULL,
 P_ATTRIBUTE10               =>NULL,
 P_ATTRIBUTE11               =>NULL,
 P_ATTRIBUTE12               =>NULL,
 P_ATTRIBUTE13               =>NULL,
 P_ATTRIBUTE14               =>NULL,
 P_ATTRIBUTE15               =>NULL,
 P_ATTRIBUTE16               =>NULL,
 P_ATTRIBUTE17               =>NULL,
 P_ATTRIBUTE18               =>NULL,
 P_ATTRIBUTE19               =>NULL,
 P_ATTRIBUTE20               =>NULL,
 P_INPUT_VALUE_ID1           =>Get_Input_Value_Id('Start Date',
                                            p_effective_date),
 P_INPUT_VALUE_ID2           =>Get_Input_Value_Id('End Date',
                                            p_effective_date),
 P_INPUT_VALUE_ID3           =>NULL,
 P_INPUT_VALUE_ID4           =>NULL,
 P_INPUT_VALUE_ID5           =>NULL,
 P_INPUT_VALUE_ID6           =>NULL,
 P_INPUT_VALUE_ID7           =>NULL,
 P_INPUT_VALUE_ID8           =>NULL,
 P_INPUT_VALUE_ID9           =>NULL,
 P_INPUT_VALUE_ID10          =>NULL,
 P_INPUT_VALUE_ID11          =>NULL,
 P_INPUT_VALUE_ID12          =>NULL,
 P_INPUT_VALUE_ID13          =>NULL,
 P_INPUT_VALUE_ID14          =>NULL,
 P_INPUT_VALUE_ID15          =>NULL,
 P_ENTRY_VALUE1              =>p_start_date,
 P_ENTRY_VALUE2              =>p_end_date,
 P_ENTRY_VALUE3              =>NULL,
 P_ENTRY_VALUE4              =>NULL,
 P_ENTRY_VALUE5              =>NULL,
 P_ENTRY_VALUE6              =>NULL,
 P_ENTRY_VALUE7              =>NULL,
 P_ENTRY_VALUE8              =>NULL,
 P_ENTRY_VALUE9              =>NULL,
 P_ENTRY_VALUE10             =>NULL,
 P_ENTRY_VALUE11             =>NULL,
 P_ENTRY_VALUE12             =>NULL,
 P_ENTRY_VALUE13             =>NULL,
 P_ENTRY_VALUE14             =>NULL,
 P_ENTRY_VALUE15             =>NULL,
 P_EFFECTIVE_START_DATE      =>p_effective_start_date,
 P_EFFECTIVE_END_DATE        =>p_effective_end_date,
 P_ELEMENT_ENTRY_ID          =>p_element_entry_id,
 P_OBJECT_VERSION_NUMBER     =>p_object_version_number,
 P_CREATE_WARNING            =>l_create_warning);

END Create_Student_Loan;

--
-- -------------------- Delete Process ----------------------
--

PROCEDURE Delete_Student_Loan(
            p_datetrack_mode in VARCHAR2
           ,p_element_entry_id in NUMBER
           ,p_effective_date in DATE
           ,p_object_version_number in NUMBER) IS

 l_object_version_number NUMBER;
 l_effective_start_date DATE;
 l_effective_end_date DATE;
 l_delete_warning BOOLEAN;

BEGIN

l_object_version_number := p_object_version_number;

py_element_entry_api.delete_element_entry(
    p_validate => FALSE,
    p_datetrack_delete_mode => p_datetrack_mode,
    p_effective_date => p_effective_date,
    p_element_entry_id => p_element_entry_id,
    p_object_version_number => l_object_version_number,
    p_effective_start_date => l_effective_start_date,
    p_effective_end_date => l_effective_end_date,
    p_delete_warning => l_delete_warning
    );

END Delete_Student_Loan;

PROCEDURE Update_Student_Loan(
            p_datetrack_update_mode in     varchar2
           ,p_effective_date        in     date
           ,p_business_group_id     in     number
           ,p_element_entry_id      in     number
           ,p_object_version_number in out nocopy number
           ,p_start_date            in     VARCHAR2
           ,p_end_date              in     VARCHAR2
           ,p_subpriority           in     number
           ,p_effective_start_date     out nocopy date
           ,p_effective_end_date       out nocopy date) is

l_update_warning BOOLEAN;

BEGIN

py_element_entry_api.update_element_entry(
    p_validate => FALSE,
    p_datetrack_update_mode => p_datetrack_update_mode,
    p_effective_date => p_effective_date,
    p_business_group_id => p_business_group_id,
    p_element_entry_id => p_element_entry_id,
    p_object_version_number => p_object_version_number,
    P_INPUT_VALUE_ID1           =>Get_Input_Value_Id('Start Date',
                                               p_effective_date),
    P_INPUT_VALUE_ID2           =>Get_Input_Value_Id('End Date',
                                               p_effective_date),
    P_SUBPRIORITY               =>p_subpriority,
    P_ENTRY_VALUE1              =>p_start_date,
    P_ENTRY_VALUE2              =>p_end_date,
    P_EFFECTIVE_START_DATE      =>p_effective_start_date,
    P_EFFECTIVE_END_DATE        =>p_effective_end_date,
    P_UPDATE_WARNING            =>l_update_warning);
--
-- Done the update
--
END Update_Student_Loan;


/*Added below functions for bug fix 3336452*/

/*Function to get the tax district Reference*/
FUNCTION  get_tax_ref(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS

   CURSOR get_asg_tax_ref IS
   SELECT scl.segment1
   FROM   hr_soft_coding_keyflex scl,
          fnd_sessions fs,
          pay_payrolls_f ppf,
          per_all_assignments_f paaf
   WHERE  paaf.assignment_id = p_assignment_id
   AND    fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
   AND    ppf.payroll_id = paaf.payroll_id
   AND    fs.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_Date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;

   l_asg_tax_ref hr_soft_coding_keyflex.segment1%TYPE;
   l_proc VARCHAR2(50);


BEGIN
      l_proc := g_package_functions || 'get_tax_ref';
      -- Get tax reference of current assignment.
      hr_utility.set_location('Entering ' || l_proc,10);

      OPEN  get_asg_tax_ref;
      FETCH get_asg_tax_ref INTO l_asg_tax_ref;
      CLOSE get_asg_tax_ref;

      hr_utility.set_location('Leaving         ' || l_proc,30);

      RETURN l_asg_tax_ref;

END  get_tax_ref;

/*Function to get the Input value Id's*/
FUNCTION  get_input_value(p_ele_name IN VARCHAR2, p_iv_name IN VARCHAR2) RETURN NUMBER IS

   CURSOR get_input_value_ids IS
   SELECT piv.input_value_id
   FROM   fnd_sessions fs,
          pay_element_types_f pet,
          pay_input_values_f piv
   WHERE  fs.session_id = userenv('sessionid')
   AND    pet.element_name = p_ele_name
   AND    pet.business_group_id IS NULL
   AND    pet.legislation_code = 'GB'
   AND    fs.effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
   AND    pet.element_type_id = piv.element_type_id
   AND    piv.name = p_iv_name
   AND    piv.business_group_id IS NULL
   AND    piv.legislation_code = 'GB'
   AND    fs.effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date;

   l_cto_input_id NUMBER;
   l_proc  VARCHAR2(50);

BEGIN
           l_proc := g_package_functions || 'get_input_value';
           hr_utility.set_location('Entering ' || l_proc,10);

           OPEN get_input_value_ids;
	   FETCH get_input_value_ids INTO l_cto_input_id;
	   CLOSE get_input_value_ids;

           hr_utility.set_location('Leaving         ' || l_proc,30);
	   RETURN l_cto_input_id;

END get_input_value;

/*Function to get person id*/
FUNCTION get_person_id(p_assignment_id IN NUMBER) RETURN NUMBER IS

   CURSOR get_person(p_assignment_id IN NUMBER) IS
   SELECT person_id
   FROM   per_all_assignments_f paaf,
          fnd_sessions fs
   WHERE  fs.session_id = userenv('sessionid')
   AND    paaf.assignment_id =p_assignment_id
   AND    fs.effective_date between paaf.effective_start_date and paaf.effective_end_date;

   l_per_id NUMBER;
   l_proc VARCHAR2(50);
BEGIN

     l_proc := g_package_functions || 'get_person_id';
     hr_utility.set_location('Entering         ' || l_proc,10);
     OPEN  get_person(p_assignment_id);
     FETCH get_person INTO l_per_id;
     CLOSE get_person;

      hr_utility.set_location('Leaving         ' || l_proc,30);
     RETURN l_per_id;
END get_person_id;

/*Function to get the current frequency of the assignment*/
FUNCTION get_current_freq(p_assignment_id IN NUMBER,
                          p_date_earned   IN DATE,
			  p_reference     IN VARCHAR2
			  ) RETURN NUMBER IS

   CURSOR get_freq IS
   SELECT ptpt.number_per_fiscal_year
   FROM   per_all_assignments_f papf,
          pay_all_payrolls_f pap,
	  per_time_period_types  ptpt
   WHERE  papf.assignment_id = p_assignment_id
   AND    p_date_earned BETWEEN papf.effective_start_date and papf.effective_end_date
   AND    pap.payroll_id = papf.payroll_id
   AND    p_date_earned BETWEEN pap.effective_start_date and pap.effective_end_date
   AND    pap.period_type=ptpt.period_type;

   l_freq per_time_period_types.number_per_fiscal_year%TYPE;
   l_proc VARCHAR2(50) ;

BEGIN
   l_proc := g_package_functions || 'get_current_freq';
   hr_utility.set_location('Entering         ' || l_proc,10);

   OPEN get_freq;
   FETCH get_freq INTO l_freq;
   CLOSE get_freq;

   hr_utility.set_location('Leaving         ' || l_proc,30);
   RETURN l_freq;
END get_current_freq;

/*Function to get the current pay date of the assignment*/
FUNCTION get_current_pay_date(p_assignment_id IN NUMBER
                             ,p_date_earned IN  DATE
			     ,p_reference     IN VARCHAR2
			     ) RETURN DATE IS

   CURSOR get_curr_pay_date  IS
   SELECT nvl(ptp.regular_payment_date , to_date('01-01-0001','DD-MM-YYYY'))
   FROM   per_all_assignments_f papf,
          pay_all_payrolls_f pap,
	  per_time_periods   ptp
   WHERE  papf.assignment_id = p_assignment_id
   AND    p_date_earned BETWEEN papf.effective_start_date and papf.effective_end_date
   AND    pap.payroll_id = papf.payroll_id
   AND    p_date_earned BETWEEN pap.effective_start_date and pap.effective_end_date
   AND    pap.payroll_id=ptp.payroll_id
   AND    p_date_earned BETWEEN ptp.start_date and ptp.end_date;

  l_current_pay_date  DATE;
  l_proc VARCHAR2(50);

BEGIN
   l_proc := g_package_functions || 'get_current_pay_date';
   hr_utility.set_location('Entering         ' || l_proc,10);
   OPEN get_curr_pay_date;
   FETCH get_curr_pay_date INTO l_current_pay_date;
   CLOSE get_curr_pay_date;

   hr_utility.set_location('Leaving         ' || l_proc,30);
   RETURN l_current_pay_date;

END get_current_pay_date;

/*Function to count the number of Main CTO Entries*/
FUNCTION count_main_cto_entry(p_assignment_id IN NUMBER,
                              p_date_earned   IN DATE,
			      p_reference     IN VARCHAR2) RETURN NUMBER IS

   l_count NUMBER := 0;
   l_count_n NUMBER :=0;
   l_count_null NUMBER :=0;
   g_cto_main_iv_id NUMBER;
   g_cto_ntpp_main_iv_id NUMBER;
   l_asg_tax_ref hr_soft_coding_keyflex.segment1%TYPE;
   g_cto_main_ref_id NUMBER;
   g_cto_ntpp_main_ref_id NUMBER;
   l_person_id  NUMBER;
   l_count_total NUMBER;

   CURSOR get_main_count(p_asg_tax_ref IN VARCHAR2,p_person_id IN NUMBER,p_entry_value IN VARCHAR2) IS
   SELECT /*+ ORDERED use_nl(papf, paaf1, paaf2, ppf, piv1, piv2, peef1, peef2, scl)*/
         count(*) cnt
   from  per_all_people_f papf,
         per_all_assignments_f paaf1,
         per_all_assignments_f paaf2,
         pay_all_payrolls_f ppf,
         pay_input_values_f piv1 ,
         pay_input_values_f piv2,
         pay_element_entries_f peef1,
             pay_element_entries_f peef2,
         pay_element_entry_values_f peev1,
         pay_element_entry_values_f peev2,
             hr_soft_coding_keyflex scl
   where papf.person_id   = p_person_id
   and   papf.person_id   = paaf1.person_id
   and   papf.person_id   = paaf2.person_id
   -- and    paaf1.person_id     = paaf2.person_id  -- redundant
   and   ppf.payroll_id = paaf2.payroll_id
   and   ppf.payroll_id = paaf1.payroll_id
   AND   scl.segment1 = p_asg_tax_ref
   and   piv1.input_value_id in (g_cto_main_ref_id,g_cto_ntpp_main_ref_id)
   and   piv2.input_value_id   in (g_cto_main_iv_id, g_cto_ntpp_main_iv_id)
   and   piv1.input_value_id = peev1.input_value_id
   and   piv2.input_value_id = peev2.input_value_id
   AND   paaf1.assignment_id = peef1.assignment_id
   AND   paaf2.assignment_id = peef2.assignment_id
   and   peef1.element_entry_id = peef2.element_entry_id
   and   peev1.element_entry_id = peev2.element_entry_id
   and   piv1.element_type_id   = piv2.element_type_id
   AND   peef1.element_entry_id = peev1.element_entry_id
   AND   peef2.element_entry_id = peev2.element_entry_id -- AND    fs.session_id = userenv('sessionid')
   AND   p_date_earned BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND   p_date_earned BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND   p_date_earned BETWEEN peev1.effective_start_date AND peev1.effective_end_date
   AND   p_date_earned BETWEEN peev2.effective_start_date AND peev2.effective_end_date
   AND   p_date_earned BETWEEN peef1.effective_start_date AND peef1.effective_end_date
   AND   p_date_earned BETWEEN peef2.effective_start_date AND peef2.effective_end_date
   AND   p_date_earned BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND   p_date_earned BETWEEN piv1.effective_start_date AND piv1.effective_end_date
   AND   p_date_earned BETWEEN piv2.effective_start_date AND piv2.effective_end_date
   AND   p_date_earned BETWEEN papf.effective_start_date AND papf.effective_end_date
   AND   ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND   scl.segment1 = p_asg_tax_ref
   and   peev1.screen_entry_value =  p_reference
   group by peev1.screen_entry_value,peev2.screen_entry_Value

   having ( peev2.screen_entry_Value =p_entry_value) ;


   CURSOR get_main_entry_count(p_asg_tax_ref IN VARCHAR2,p_person_id IN NUMBER) IS
   SELECT /*+ ORDERED use_nl(papf, paaf1, paaf2, ppf, piv1, piv2, peef1, peef2, scl)*/
         count(*) cnt
   from   per_all_people_f papf,
          per_all_assignments_f paaf1,
          per_all_assignments_f paaf2,
          pay_all_payrolls_f ppf,
          pay_input_values_f piv1 ,
          pay_input_values_f piv2,
          pay_element_entries_f peef1,
          pay_element_entries_f peef2,
          pay_element_entry_values_f peev1,
          pay_element_entry_values_f peev2,
          hr_soft_coding_keyflex scl
   where  papf.person_id   = p_person_id
   and    papf.person_id   = paaf1.person_id
   and    papf.person_id   = paaf2.person_id
   -- and    paaf1.person_id     = paaf2.person_id  -- redundant
   and    ppf.payroll_id = paaf2.payroll_id
   and    ppf.payroll_id = paaf1.payroll_id
   AND    scl.segment1 = p_asg_tax_ref
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   and    piv1.input_value_id in (g_cto_main_ref_id,g_cto_ntpp_main_ref_id)
   and    piv2.input_value_id in (g_cto_main_iv_id, g_cto_ntpp_main_iv_id)
   and    piv1.input_value_id = peev1.input_value_id
   and    piv2.input_value_id = peev2.input_value_id
   AND    paaf1.assignment_id = peef1.assignment_id
   AND    paaf2.assignment_id = peef2.assignment_id
   and    peef1.element_entry_id = peef2.element_entry_id
   and    peev1.element_entry_id = peev2.element_entry_id
   and    piv1.element_type_id   = piv2.element_type_id
   AND    peef1.element_entry_id = peev1.element_entry_id
   AND    peef2.element_entry_id = peev2.element_entry_id -- AND    fs.session_id = userenv('sessionid')
   AND    p_date_earned BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND    p_date_earned BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND    p_date_earned BETWEEN peev1.effective_start_date AND peev1.effective_end_date
   AND    p_date_earned BETWEEN peev2.effective_start_date AND peev2.effective_end_date
   AND    p_date_earned BETWEEN peef1.effective_start_date AND peef1.effective_end_date
   AND    p_date_earned BETWEEN peef2.effective_start_date AND peef2.effective_end_date
   AND    p_date_earned BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND    p_date_earned BETWEEN piv1.effective_start_date AND piv1.effective_end_date
   AND    p_date_earned BETWEEN piv2.effective_start_date AND piv2.effective_end_date
   AND    p_date_earned BETWEEN papf.effective_start_date AND papf.effective_end_date
   and    peev1.screen_entry_value =  p_reference
   group by peev1.screen_entry_value;


   --
   CURSOR chk_prim_asg(p_asg_tax_ref IN VARCHAR2) IS
   SELECT 1 cnt
   FROM   per_all_assignments_f paaf1,
          per_all_assignments_f paaf2,
          pay_all_payrolls_f ppf,
          hr_soft_coding_keyflex scl,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev
   WHERE  paaf1.assignment_id = p_assignment_id
   AND    p_date_earned BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND    paaf1.person_id = paaf2.person_id
   AND    nvl(paaf2.primary_flag, 'N') = 'Y'
   AND    p_date_earned BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND    paaf2.payroll_id = ppf.payroll_id
   AND    p_date_earned BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    scl.segment1 = p_asg_tax_ref
   AND    paaf2.assignment_id = peef.assignment_id
   AND    p_date_earned BETWEEN peef.effective_start_date AND peef.effective_end_date
   AND    peef.element_entry_id = peev.element_entry_id
   AND    p_date_earned BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND    peev.input_value_id IN (g_cto_main_ref_id,g_cto_ntpp_main_ref_id)
   AND    nvl(peev.SCREEN_ENTRY_VALUE, 'N') = p_reference;

   --
   l_proc VARCHAR2(50);
BEGIN

    l_proc := g_package_functions || 'count_main_cto_entry';
    hr_utility.set_location('Entering         ' || l_proc,10);

    /*Get tax reference of current assignment*/
    l_asg_tax_ref:= get_tax_ref(p_assignment_id);

   /*Get Input value id*/
    g_cto_main_iv_id       := get_input_value('Court Order','Main CTO Entry');
    g_cto_ntpp_main_iv_id  := get_input_value('Court Order NTPP','Main CTO Entry');

    g_cto_main_ref_id      := get_input_value('Court Order','Reference');
    g_cto_ntpp_main_ref_id := get_input_value('Court Order NTPP','Reference');

    /*Get Person Id*/
    l_person_id := get_person_id(p_assignment_id);


   OPEN  get_main_count(l_asg_tax_ref,l_person_id,'Y');
   FETCH get_main_count INTO l_count;
   CLOSE get_main_count;
   --

   IF l_count = 0 THEN
      OPEN  get_main_count(l_asg_tax_ref,l_person_id,'N');
      FETCH get_main_count INTO l_count;
      OPEN get_main_entry_count(l_asg_tax_ref,l_person_id);
      FETCH get_main_entry_count INTO l_count_total;
      CLOSE get_main_entry_count;
      CLOSE get_main_count;
      if l_count=l_count_total then
         l_count := 0;
      else
         OPEN chk_prim_asg(l_asg_tax_ref);
         FETCH chk_prim_asg INTO l_count;
         IF chk_prim_asg%NOTFOUND THEN
            l_count := 0;
         END IF;
         CLOSE chk_prim_asg;

      end if;
      --
   END IF;
   --
   g_count_main_cto_entry := l_count;
   --
   hr_utility.set_location('Leaving         ' || l_proc,30);
   RETURN l_count;

END count_main_cto_entry;

FUNCTION get_main_cto_pay_date(p_assignment_id IN NUMBER,
                               p_date_earned   IN DATE,
			       p_reference     IN VARCHAR2
			      ) RETURN DATE IS


l_asg_tax_ref hr_soft_coding_keyflex.segment1%TYPE;
l_asg_payroll_id pay_payrolls_f.payroll_id%TYPE;
l_asg_period_start_date per_time_periods.start_date%TYPE;
g_cto_main_iv_id NUMBER;
g_cto_ntpp_main_iv_id NUMBER;
g_cto_main_ref_id NUMBER;
g_cto_ntpp_main_ref_id NUMBER;
l_person_id  NUMBER;


CURSOR get_asg_period_start_date IS
SELECT ptp.start_date
FROM   per_time_periods ptp
WHERE  ptp.payroll_id = l_asg_payroll_id
AND    p_date_earned =ptp.regular_payment_date;

CURSOR get_main_payroll_id(p_asg_tax_ref VARCHAR2,p_person_id NUMBER) is
SELECT ppf.payroll_id
FROM   per_all_assignments_f paaf1,
       per_all_assignments_f paaf2,
       pay_all_payrolls_f ppf,
       hr_soft_coding_keyflex scl,
       pay_element_entries_f peef,
       pay_element_entry_values_f peev,
       pay_element_entry_values_f peev1,
       per_all_people_f papf
WHERE
       p_date_earned BETWEEN  paaf1.effective_start_date and paaf1.effective_end_date
AND    paaf1.person_id = paaf2.person_id
AND    p_date_earned BETWEEN  paaf2.effective_start_date and paaf2.effective_end_date
AND    paaf2.payroll_id = ppf.payroll_id
AND    p_date_earned BETWEEN  ppf.effective_start_date and ppf.effective_end_date
AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
AND    scl.segment1 = p_asg_tax_ref
AND    paaf2.assignment_id = peef.assignment_id
AND    p_date_earned BETWEEN  peef.effective_start_date and peef.effective_end_date
AND    peef.element_entry_id = peev.element_entry_id
AND    p_date_earned BETWEEN  peev.effective_start_date and peev.effective_end_date
AND    peev.input_value_id IN (g_cto_main_iv_id, g_cto_ntpp_main_iv_id)
AND    peev1.input_value_id IN (g_cto_main_ref_id,g_cto_ntpp_main_ref_id)
AND    nvl(peev.SCREEN_ENTRY_VALUE, 'N') = 'Y'
AND    nvl(peev1.SCREEN_ENTRY_VALUE, 'N') = p_reference
AND    peev.element_entry_id=peev1.element_entry_id
AND    p_date_earned BETWEEN peev1.effective_start_date AND peev1.effective_end_date
AND    p_date_earned BETWEEN papf.effective_start_date AND papf.effective_end_date
AND    papf.person_id   = p_person_id
AND    papf.person_id   = paaf1.person_id
AND    papf.person_id   = paaf2.person_id;


CURSOR get_prim_payroll_id(p_asg_tax_ref VARCHAR2) IS
   SELECT ppf.payroll_id
   FROM   per_all_assignments_f paaf1,
          per_all_assignments_f paaf2,
          pay_all_payrolls_f ppf,
          hr_soft_coding_keyflex scl,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev
   WHERE  paaf1.assignment_id = p_assignment_id
   AND    p_date_earned BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND    paaf1.person_id = paaf2.person_id
   AND    nvl(paaf2.primary_flag, 'N') = 'Y'
   AND    p_date_earned BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND    paaf2.payroll_id = ppf.payroll_id
   AND    p_date_earned BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    scl.segment1 = p_asg_tax_ref
   AND    paaf2.assignment_id = peef.assignment_id
   AND    p_date_earned BETWEEN peef.effective_start_date AND peef.effective_end_date
   AND    peef.element_entry_id = peev.element_entry_id
   AND    p_date_earned BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND    peev.input_value_id IN (g_cto_main_iv_id, g_cto_ntpp_main_iv_id);

 l_payroll_id NUMBER;
 l_pay_date   DATE;
 l_count NUMBER := 0;


CURSOR get_pay_date(p_payroll_id IN NUMBER)  IS
SELECT nvl(ptp.regular_payment_date , to_date('01-01-0001','DD-MM-YYYY'))
FROM   per_time_periods ptp
WHERE  p_date_earned BETWEEN ptp.start_date and ptp.end_date
AND    ptp.payroll_id =p_payroll_id;

l_proc VARCHAR2(50);

BEGIN
    l_proc := g_package_functions || 'get_main_cto_pay_date';
    hr_utility.set_location('Entering         ' || l_proc,10);
    l_asg_tax_ref:= get_tax_ref(p_assignment_id);

    l_person_id := get_person_id(p_assignment_id);

   /*Get Input value id*/
    g_cto_main_iv_id       := get_input_value('Court Order','Main CTO Entry');
    g_cto_ntpp_main_iv_id  := get_input_value('Court Order NTPP','Main CTO Entry');

    g_cto_main_ref_id      := get_input_value('Court Order','Reference');
    g_cto_ntpp_main_ref_id := get_input_value('Court Order NTPP','Reference');

   OPEN   get_asg_period_start_date;
   FETCH  get_asg_period_start_date into l_asg_period_start_date;
   CLOSE  get_asg_period_start_date;

   --
   IF nvl(p_assignment_id, -1) <> nvl(g_asg_id, -999) THEN
      l_count := count_main_cto_entry(p_assignment_id,p_date_earned,p_reference);
   ELSE
      l_count := g_count_main_cto_entry;
   END IF;

   --
   IF nvl(l_count, 0) = 1 THEN
      --
      OPEN  get_main_payroll_id(l_asg_tax_ref,l_person_id);
      FETCH get_main_payroll_id INTO l_payroll_id;

      IF get_main_payroll_id%NOTFOUND THEN
         l_payroll_id := NULL;
      END IF;
      CLOSE get_main_payroll_id;
      --
      IF l_payroll_id IS NULL THEN
         OPEN get_prim_payroll_id(l_asg_tax_ref);
         FETCH get_prim_payroll_id INTO l_payroll_id;
         IF get_prim_payroll_id%NOTFOUND THEN
            l_payroll_id := NULL;
         END IF;
         CLOSE get_prim_payroll_id;
      END IF;
      --
      IF l_payroll_id IS NULL THEN
         RETURN  to_date('01-01-0001', 'DD-MM-YYYY');
      ELSE
         OPEN get_pay_date(l_payroll_id);
         FETCH get_pay_date INTO l_pay_date;

         IF get_pay_date%NOTFOUND THEN
            l_pay_date := to_date('01-01-0001', 'DD-MM-YYYY');
         END IF;
         CLOSE get_pay_date;
      END IF;
   ELSE

      l_pay_date :=  to_date('01-01-0001', 'DD-MM-YYYY');
   END IF;
   --
   hr_utility.set_location('Leaving         ' || l_proc,30);
   RETURN l_pay_date;

END get_main_cto_pay_date;



FUNCTION get_main_cto_freq(p_assignment_id IN NUMBER,
                           p_date_earned   IN DATE,
			   p_reference     IN VARCHAR2
			   ) RETURN NUMBER IS

   --
   l_asg_tax_ref hr_soft_coding_keyflex.segment1%TYPE;
   l_person_id NUMBER;
   g_cto_main_iv_id NUMBER;
   g_cto_ntpp_main_iv_id NUMBER;
   g_cto_main_ref_id NUMBER;
   g_cto_ntpp_main_ref_id NUMBER;

   --
CURSOR get_main_payroll_id(p_asg_tax_ref VARCHAR2, p_person_id NUMBER) IS
SELECT ppf.payroll_id
FROM   per_all_assignments_f paaf1,
       per_all_assignments_f paaf2,
       pay_all_payrolls_f ppf,
       hr_soft_coding_keyflex scl,
       pay_element_entries_f peef,
       pay_element_entry_values_f peev,
       pay_element_entry_values_f peev1,
       per_all_people_f papf
WHERE  p_date_earned BETWEEN  paaf1.effective_start_date and paaf1.effective_end_date
AND    paaf1.person_id = paaf2.person_id
AND    p_date_earned BETWEEN  paaf2.effective_start_date and paaf2.effective_end_date
AND    paaf2.payroll_id = ppf.payroll_id
AND    p_date_earned BETWEEN  ppf.effective_start_date and ppf.effective_end_date
AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
AND    scl.segment1 = p_asg_tax_ref
AND    paaf2.assignment_id = peef.assignment_id
AND    p_date_earned BETWEEN  peef.effective_start_date and peef.effective_end_date
AND    peef.element_entry_id = peev.element_entry_id
AND    p_date_earned BETWEEN  peev.effective_start_date and peev.effective_end_date
AND    peev.input_value_id IN (g_cto_main_iv_id, g_cto_ntpp_main_iv_id)
AND    peev1.input_value_id IN (g_cto_main_ref_id,g_cto_ntpp_main_ref_id)
AND    nvl(peev.SCREEN_ENTRY_VALUE, 'N') = 'Y'
AND    nvl(peev1.SCREEN_ENTRY_VALUE, 'N') = p_reference
AND    peev.element_entry_id=peev1.element_entry_id
AND    p_date_earned BETWEEN peev1.effective_start_date AND peev1.effective_end_date
AND    p_date_earned BETWEEN papf.effective_start_date AND papf.effective_end_date
AND    papf.person_id   = p_person_id
AND    papf.person_id   = paaf1.person_id
AND    papf.person_id   = paaf2.person_id;
   --
   CURSOR get_prim_payroll_id(p_asg_tax_ref VARCHAR2) IS
   SELECT ppf.payroll_id
   FROM fnd_sessions fs,
          per_all_assignments_f paaf1,
          per_all_assignments_f paaf2,
          pay_all_payrolls_f ppf,
          hr_soft_coding_keyflex scl,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev
   WHERE  paaf1.assignment_id = p_assignment_id
   AND    fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND    paaf1.person_id = paaf2.person_id
   AND    nvl(paaf2.primary_flag, 'N') = 'Y'
   AND    fs.effective_date BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND    paaf2.payroll_id = ppf.payroll_id
   AND    fs.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    scl.segment1 = p_asg_tax_ref
   AND    paaf2.assignment_id = peef.assignment_id
   AND    fs.effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
   AND    peef.element_entry_id = peev.element_entry_id
   AND    fs.effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND    peev.input_value_id IN (g_cto_main_iv_id, g_cto_ntpp_main_iv_id);
   --
   l_payroll_id NUMBER;
   l_freq       NUMBER;
   l_count NUMBER := 0;

   --
   CURSOR get_freq IS
   SELECT number_per_fiscal_year
   FROM   per_time_periods ptp,
          per_time_period_types ptpt
   WHERE  p_date_earned BETWEEN ptp.start_date AND ptp.end_Date
   AND    ptp.payroll_id = l_payroll_id
   AND    ptp.period_type = ptpt.period_type;
   --

    l_proc VARCHAR2(50);
BEGIN
   --
      l_proc := g_package_functions || 'get_main_cto_freq';
      hr_utility.set_location('Entering         ' || l_proc,10);

      -- Get tax ref of current asg.
      l_asg_tax_ref:= get_tax_ref(p_assignment_id);
      l_person_id := get_person_id(p_assignment_id);

      /*Get Input value id*/
      g_cto_main_iv_id       := get_input_value('Court Order','Main CTO Entry');
      g_cto_ntpp_main_iv_id  := get_input_value('Court Order NTPP','Main CTO Entry');

      g_cto_main_ref_id      := get_input_value('Court Order','Reference');
      g_cto_ntpp_main_ref_id := get_input_value('Court Order NTPP','Reference');
   --
   IF nvl(p_assignment_id, -1) <> nvl(g_asg_id, -999) THEN

      l_count := count_main_cto_entry(p_assignment_id,p_date_earned,p_reference);
   ELSE
      l_count := g_count_main_cto_entry;
   END IF;
   --
   IF nvl(l_count, 0) = 1 THEN

      OPEN  get_main_payroll_id(l_asg_tax_ref,l_person_id);
      FETCH get_main_payroll_id INTO l_payroll_id;
      IF get_main_payroll_id%NOTFOUND THEN

         l_payroll_id := NULL;
      END IF;
      CLOSE get_main_payroll_id;
      --
      IF l_payroll_id IS NULL THEN

         OPEN get_prim_payroll_id(l_asg_tax_ref);
         FETCH get_prim_payroll_id INTO l_payroll_id;
         IF get_prim_payroll_id%NOTFOUND THEN
            l_payroll_id := NULL;
         END IF;
         CLOSE get_prim_payroll_id;
      END IF;
      --
      IF l_payroll_id IS NULL THEN
         RETURN null;
      ELSE
         OPEN get_freq;
         FETCH get_freq INTO l_freq;
         IF get_freq%NOTFOUND THEN
            l_freq := 0;
         END IF;
         CLOSE get_freq;
      END IF;
      --
   ELSE

      l_freq := 0;
   END IF;
   --
   hr_utility.set_location('Leaving         ' || l_proc,30);
   RETURN l_freq;

END get_main_cto_freq;


FUNCTION get_main_entry_values(p_assignment_id IN NUMBER,
                              p_date_earned IN DATE,
			      p_reference     IN VARCHAR2,
                              p_input_value_name IN VARCHAR2,
                              p_count OUT NOCOPY NUMBER
			      ) RETURN VARCHAR2 IS

   --
   l_asg_tax_ref hr_soft_coding_keyflex.segment1%TYPE;
   --

   l_cto_iv_id    NUMBER;
   l_cto_ntpp_iv_id NUMBER;

   g_cto_main_iv_id NUMBER;
   g_cto_ntpp_main_iv_id NUMBER;
   g_cto_main_ref_id NUMBER;
   g_cto_ntpp_main_ref_id NUMBER;
   l_person_id NUMBER;

   CURSOR get_main_entry_id(p_asg_tax_ref VARCHAR2,p_person_id  NUMBER) IS
   SELECT peef.element_entry_id
   FROM   per_all_assignments_f paaf1,
          per_all_assignments_f paaf2,
          pay_all_payrolls_f ppf,
          hr_soft_coding_keyflex scl,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev,
	  pay_element_entry_values_f peev1,
	  per_all_people_f  papf
   WHERE  --paaf1.assignment_id = p_assignment_id AND
          p_date_earned BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND    paaf1.person_id = paaf2.person_id
   AND    p_date_earned BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND    paaf2.payroll_id = ppf.payroll_id
   AND    p_date_earned BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    scl.segment1 = p_asg_tax_ref
   AND    paaf2.assignment_id = peef.assignment_id
   AND    p_date_earned BETWEEN peef.effective_start_date AND peef.effective_end_date
   AND    peef.element_entry_id = peev.element_entry_id
   AND    p_date_earned BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND    peev.input_value_id IN (g_cto_main_iv_id, g_cto_ntpp_main_iv_id)
   AND    peev1.input_value_id IN (g_cto_main_ref_id,g_cto_ntpp_main_ref_id)
   AND    nvl(peev.SCREEN_ENTRY_VALUE, 'N') = 'Y'
   AND    nvl(peev1.SCREEN_ENTRY_VALUE, 'N') = p_reference
   AND    peev1.element_entry_id=peev.element_entry_id
   AND    p_date_earned BETWEEN peev1.effective_start_date AND peev1.effective_end_date
   AND    peef.target_entry_id IS NULL
   AND    papf.person_id =p_person_id
   AND    p_date_earned BETWEEN papf.effective_start_date AND papf.effective_end_date
   AND    papf.person_id   = paaf1.person_id
   AND    papf.person_id   = paaf2.person_id;

   --
   CURSOR chk_prim_entry_id(p_asg_tax_ref VARCHAR2) IS
   SELECT peef.element_entry_id
   FROM
          per_all_assignments_f paaf1,
          per_all_assignments_f paaf2,
          pay_all_payrolls_f ppf,
          hr_soft_coding_keyflex scl,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev
   WHERE  paaf1.assignment_id = p_assignment_id
   AND    p_date_earned BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND    paaf1.person_id = paaf2.person_id
   AND    nvl(paaf2.primary_flag, 'N') = 'Y'
   AND    p_date_earned BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND    paaf2.payroll_id = ppf.payroll_id
   AND    p_date_earned BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    scl.segment1 = p_asg_tax_ref
   AND    paaf2.assignment_id = peef.assignment_id
   AND    p_date_earned BETWEEN peef.effective_start_date AND peef.effective_end_date
   AND    peef.element_entry_id = peev.element_entry_id
   AND    p_date_earned BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND    peev.input_value_id IN (g_cto_main_ref_id, g_cto_ntpp_main_ref_id)
   AND    peef.target_entry_id IS NULL
   AND    nvl(peev.SCREEN_ENTRY_VALUE, 'N') = p_reference;
   --
   l_entry_id NUMBER;


    CURSOR get_value IS
    SELECT peev.screen_entry_value
    FROM   pay_element_entry_values_f peev
    WHERE  p_date_earned BETWEEN peev.effective_start_date and peev.effective_end_date
    AND    peev.element_entry_id = l_entry_id
    AND    peev.input_value_id  IN (l_cto_iv_id, l_cto_ntpp_iv_id);

   l_value  pay_element_entry_values_f.screen_entry_value%TYPE;
   l_count NUMBER;
   l_proc VARCHAR2(50);

BEGIN

      l_proc := g_package_functions || 'get_main_entry_values';
      hr_utility.set_location('Entering         ' || l_proc,10);

   -- Get tax ref of current asg.
      l_asg_tax_ref:= get_tax_ref(p_assignment_id);
      l_person_id := get_person_id(p_assignment_id);
   --
   IF nvl(p_assignment_id, -1) <> nvl(g_asg_id, -999) THEN

      l_count := count_main_cto_entry(p_assignment_id,p_date_earned,p_reference);
   ELSE
      l_count := g_count_main_cto_entry;
   END IF;

   p_count := l_count;
   --
   IF nvl(l_count, 0) = 1 THEN


	   /*Get Input value id*/
           g_cto_main_iv_id := get_input_value('Court Order','Main CTO Entry');
	   g_cto_ntpp_main_iv_id := get_input_value('Court Order NTPP','Main CTO Entry');
	   g_cto_main_ref_id := get_input_value('Court Order','Reference');
           g_cto_ntpp_main_ref_id := get_input_value('Court Order NTPP','Reference');

	   l_cto_iv_id := get_input_value('Court Order',p_input_value_name);
           l_cto_ntpp_iv_id := get_input_value('Court Order NTPP',p_input_value_name);


	      OPEN get_main_entry_id(l_asg_tax_ref,l_person_id);
	      FETCH get_main_entry_id INTO l_entry_id;

	      IF get_main_entry_id%NOTFOUND THEN

		 OPEN chk_prim_entry_id(l_asg_tax_ref);
		 FETCH chk_prim_entry_id INTO l_entry_id;
		 CLOSE chk_prim_entry_id;

	      END IF;
	      CLOSE get_main_entry_id;
	      --
	      OPEN get_value;
	      FETCH get_value INTO l_value;
	      CLOSE get_value;
	      --
	   ELSE
	      l_value := NULL;
	   END IF;
   --
           hr_utility.set_location('Leaving         ' || l_proc,30);
   RETURN l_value;

END get_main_entry_values;

FUNCTION get_main_initial_debt(p_assignment_id IN NUMBER,
                               p_date_earned   IN DATE,
			       p_reference     IN VARCHAR2
			       ) RETURN NUMBER IS

l_value NUMBER;
l_count NUMBER;
l_proc VARCHAR2(50);

BEGIN

    l_proc := g_package_functions || 'get_main_initial_debt';
    hr_utility.set_location('Entering         ' || l_proc,10);
    l_value := nvl(to_number(get_main_entry_values(p_assignment_id,p_date_earned,p_reference,'Initial Debt',l_count)),0);
    hr_utility.set_location('Leaving         ' || l_proc,30);

    RETURN l_value;


END get_main_initial_debt;

FUNCTION get_main_fee(p_assignment_id IN NUMBER,
                      p_date_earned   IN DATE,
	              p_reference     IN VARCHAR2
		      ) RETURN NUMBER IS

l_value NUMBER;
l_count NUMBER;
l_proc VARCHAR2(50);

BEGIN
    l_proc := g_package_functions || 'get_main_fee';
    hr_utility.set_location('Entering         ' || l_proc,10);
    l_value := nvl(to_number(get_main_entry_values(p_assignment_id,p_date_earned,p_reference,'Fee',l_count)),0);
    hr_utility.set_location('Leaving         ' || l_proc,30);


    RETURN l_value;


END get_main_fee;

FUNCTION check_ref(p_assignment_id IN NUMBER,
                   p_date_earned   IN DATE,
                   p_reference     IN VARCHAR2
		   ) RETURN VARCHAR2 IS

l_main_ref  pay_element_entry_values_f.screen_entry_value%TYPE;
l_count NUMBER;
l_proc VARCHAR2(50);

BEGIN
        l_proc := g_package_functions || 'check_ref';
	hr_utility.set_location('Entering         ' || l_proc,10);
        l_main_ref := nvl(get_main_entry_values(p_assignment_id,p_date_earned,p_reference,'Reference',l_count),'Unknown');


       IF nvl(l_count, 0) = 1 and l_main_ref = p_reference then
          -- Valid reference
          RETURN  'Y';
       ELSE
          -- Invalid reference
	  IF l_main_ref = 'Unknown' THEN
              RETURN   'K';
	  ELSE
              RETURN   'N';
	  END IF;
       END IF;

       hr_utility.set_location('Leaving         ' || l_proc,30);

END check_ref;


FUNCTION get_main_entry_value(p_assignment_id IN NUMBER,
                                   p_date_earned   IN DATE,
                                   p_reference     IN VARCHAR2
		                   ) RETURN VARCHAR2 is


   g_cto_main_iv_id NUMBER;
   g_cto_ntpp_main_iv_id NUMBER;
   l_asg_tax_ref hr_soft_coding_keyflex.segment1%TYPE;
   g_cto_main_ref_id NUMBER;
   g_cto_ntpp_main_ref_id NUMBER;
   l_main_entry_value VARCHAR2(10);

   CURSOR get_main_value(p_asg_tax_ref IN VARCHAR2) IS
   SELECT /*+ ORDERED use_nl(paaf1, paaf2, ppf, piv1, piv2, peef1, peef2, scl)*/
        peev2.screen_entry_value main_entry_value
   from per_all_assignments_f paaf1,
        per_all_assignments_f paaf2,
        pay_all_payrolls_f ppf,
        pay_input_values_f piv1 ,
        pay_input_values_f piv2,
        pay_element_entries_f peef1,
        pay_element_entries_f peef2,
        pay_element_entry_values_f peev1,
        pay_element_entry_values_f peev2 ,
        hr_soft_coding_keyflex scl
  where paaf1.assignment_id = p_assignment_id
  AND   paaf2.assignment_id = paaf1.assignment_id
  and   paaf2.payroll_id = ppf.payroll_id
  and   paaf1.payroll_id = ppf.payroll_id
  AND   peef1.assignment_id = paaf1.assignment_id
  AND   peef2.assignment_id = paaf2.assignment_id
  and   piv1.input_value_id in (g_cto_main_ref_id,g_cto_ntpp_main_ref_id)
  and   piv2.input_value_id in (g_cto_main_iv_id, g_cto_ntpp_main_iv_id)
  and   piv1.input_value_id = peev1.input_value_id
  and   piv2.input_value_id = peev2.input_value_id
  and   peef1.element_entry_id = peef2.element_entry_id
  and   peev1.element_entry_id = peev2.element_entry_id
  and   piv1.element_type_id   = piv2.element_type_id
  AND   peef1.element_entry_id = peev1.element_entry_id
  AND   peef2.element_entry_id = peev2.element_entry_id
  AND   p_date_earned BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
  AND   p_date_earned BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
  AND   p_date_earned BETWEEN peev1.effective_start_date AND peev1.effective_end_date
  AND   p_date_earned BETWEEN peev2.effective_start_date AND peev2.effective_end_date
  AND   p_date_earned BETWEEN peef1.effective_start_date AND peef1.effective_end_date
  AND   p_date_earned BETWEEN peef2.effective_start_date AND peef2.effective_end_date
  AND   p_date_earned BETWEEN piv1.effective_start_date AND piv1.effective_end_date
  AND   p_date_earned BETWEEN piv2.effective_start_date AND piv2.effective_end_date
  AND   ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
  AND   scl.segment1 = p_asg_tax_ref
  and   peev1.screen_entry_value = p_reference;

  l_proc VARCHAR2(50);

BEGIN

    l_proc := g_package_functions || 'get_main_entry_value';
    hr_utility.set_location('Entering         ' || l_proc,10);

   /*Get tax reference of current assignment*/
    l_asg_tax_ref:= get_tax_ref(p_assignment_id);


   /*Get Input value id*/
    g_cto_main_iv_id       := get_input_value('Court Order','Main CTO Entry');
    g_cto_ntpp_main_iv_id  := get_input_value('Court Order NTPP','Main CTO Entry');

    g_cto_main_ref_id      := get_input_value('Court Order','Reference');
    g_cto_ntpp_main_ref_id := get_input_value('Court Order NTPP','Reference');

   OPEN  get_main_value(l_asg_tax_ref);
   FETCH get_main_value INTO l_main_entry_value;
   CLOSE get_main_value;

    hr_utility.set_location('Leaving         ' || l_proc,30);
    RETURN l_main_entry_value;

END get_main_entry_value;


/*Added for bug fix 4395503*/
FUNCTION entry_exists( p_element_entry_id in number
		      ,p_date_earned      in date
		      ,p_asg_action_id    in number
                      ,p_reference        in varchar2) RETURN VARCHAR2
		      IS
--
	v_exists	        VARCHAR2(100)	:= 'N';
	v_reversed	        VARCHAR2(1)	:= 'N';
	v_message               varchar2(10)    := 'N';
	v_value                 varchar2(100)   := 'Unknown';

	CURSOR csr_get_reference
	IS
	SELECT nvl(prrv.result_value,'Unknown')
	FROM   pay_run_results prr,
	       pay_run_result_values prrv,
	       pay_assignment_actions pac,
	       pay_input_values_f piv ,
	       pay_payroll_actions ppa
	WHERE  prr.run_result_id = prrv.run_result_id
	AND    prr.entry_type = 'E'
	AND    PRR.source_type		IN ('E', 'I')
	AND    prr.source_id = p_element_entry_id
	AND    pac.assignment_action_id = prr.assignment_action_id
	AND    pac.action_status in ('C')
	and    ppa.action_type in ('R','Q')
	AND    ppa.payroll_action_id		= pac.payroll_action_id
	AND    pac.assignment_action_id = (SELECT max(pac1.assignment_action_id)
					   FROM  pay_assignment_actions pac1,
						 pay_run_results prr1,
						 pay_payroll_actions ppa1
					   WHERE pac1.assignment_action_id <> p_asg_action_id
					   AND   pac1.assignment_action_id = prr1.assignment_action_id
				           AND   ppa1.payroll_action_id		= pac1.payroll_action_id
					   AND   prr1.source_id = p_element_entry_id
					   AND   pac1.action_status in ('C')
					   and   ppa1.action_type in ('R','Q')
					   and   prr1.entry_type = 'E'
					   AND   PRR1.source_type IN ('E', 'I') )
	AND   piv.legislation_code = 'GB'
	AND   piv.name = 'Reference'
	AND   piv.input_value_id = prrv.input_value_id
	AND   p_date_earned between piv.effective_start_date and piv.effective_end_date ;


	CURSOR   csr_get_results
	IS
	SELECT	PRR.run_result_id
	FROM	pay_run_results		PRR,
		pay_assignment_actions	ASA,
		pay_payroll_actions	PPA
	WHERE   PRR.source_id           = p_element_entry_id
	AND     PRR.source_type		IN ('E', 'I')
	AND     PRR.status		in ('P', 'PA', 'R', 'O')
	AND	ASA.assignment_action_id	= PRR.assignment_action_id
	AND     asa.action_status in ( 'C')
	and     ppa.action_type in ('R','Q')
	AND	PPA.payroll_action_id		= ASA.payroll_action_id
	-- Check whether the run_result has been revered.
	AND     not exists (SELECT null
			    FROM pay_run_results prr2
			    WHERE prr2.source_id = PRR.run_result_id
			    AND prr2.source_type in ('R', 'V'));
	--

	l_proc VARCHAR2(100);

BEGIN
--
	 l_proc := g_package_functions || 'entry_exists';
	 hr_utility.set_location('Entering         ' || l_proc,10);

 IF p_date_earned >= to_date('06-04-2006','DD-MM-YYYY') then

	OPEN  csr_get_results;
	FETCH csr_get_results INTO v_exists;

	IF csr_get_results%NOTFOUND THEN

	    IF (p_reference is null or p_reference = 'Unknown') THEN
		v_message := 'X';
	    ELSE
		v_message := 'Y';
	    END IF;

        ELSE

	    OPEN  csr_get_reference;
	    FETCH csr_get_reference INTO v_value;

	    IF v_value = p_reference THEN
		v_message := 'Y';
	    ELSE
		v_message := 'N';
	    END IF;
	    CLOSE csr_get_reference;

	END IF;
	CLOSE csr_get_results;

	RETURN v_message;
ELSE
        v_message := 'Y';
	RETURN v_message;
END IF;

hr_utility.set_location('Leaving         ' || l_proc,30);

EXCEPTION when NO_DATA_FOUND then
	  hr_utility.set_location('entry_exists', 30);
	  RETURN v_message;
	--
END entry_exists;

END PAY_GB_STUDENT_LOANS_PKG;

/
