--------------------------------------------------------
--  DDL for Package Body PAY_CA_EMP_TAX_INF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_EMP_TAX_INF" as
/* $Header: pycantax.pkb 120.3.12010000.3 2009/03/30 11:55:59 aneghosh ship $ */


procedure  get_province_code (p_assignment_id         in number,
                          p_session_date          in date,
                          p_res_province_code     out nocopy varchar2,
                          p_res_province_name     out nocopy varchar2,
                          p_work_province_code    out nocopy varchar2,
                          p_work_province_name    out nocopy varchar2,
                          p_res_inf_flag              in varchar2,
                          p_work_inf_flag              in varchar2

       ) is

/* Cursor to get the resident state, county and city codes */
cursor csr_get_resident_province is
       select lkp.lookup_code,
              lkp.meaning
       from   PER_ASSIGNMENTS_F   paf,
              PER_ADDRESSES       pa,
              HR_LOOKUPS          lkp
       where  paf.assignment_id         = p_assignment_id
       and    p_session_date between paf.effective_start_date and
                                     paf.effective_end_date
       and    pa.person_id              = paf.person_id
       and    pa.primary_flag           = 'Y'
       and    p_session_date between pa.date_from and
                                     nvl(pa.date_to,p_session_date)
       and    lkp.lookup_code              = pa.region_1
       and    lkp.lookup_type = 'CA_PROVINCE';

cursor csr_get_work_province is
       select lkp.lookup_code,
              lkp.meaning
       from   PER_ASSIGNMENTS_F   paf,
              HR_LOCATIONS        hrl,
              HR_LOOKUPS          lkp
       where  paf.assignment_id         = p_assignment_id
       and    p_session_date between paf.effective_start_date and
                                     paf.effective_end_date
       and    paf.location_id         = hrl.location_id
       and    lkp.lookup_code         = hrl.region_1
       and    lkp.lookup_type = 'CA_PROVINCE';
begin

  hr_utility.set_location('pay_ca_emp_tax_inf.get_work_provinces',1);

  /* Get the resident address details */

  open  csr_get_resident_province;

  fetch csr_get_resident_province into p_res_province_code,
                         p_res_province_name;

  if csr_get_resident_province%NOTFOUND then

     p_res_province_code  := null;
     p_res_province_name  := null;

  end if;

  hr_utility.set_location('get_province_code',2);

  close csr_get_resident_province;

  /* Get the work location details */

  open  csr_get_work_province;

  fetch csr_get_work_province into p_work_province_code,
                                   p_work_province_name;

  if csr_get_work_province%NOTFOUND then

     p_work_province_code   := null;
     p_work_province_name   := null;

  end if;

  hr_utility.set_location('pay_ca_emp_tax_inf.get_work_provinces',3);

  close csr_get_work_province;
end get_province_code;


procedure  create_default_tax_record
                                  (p_assignment_id     in number,
                                   p_effective_start_date out nocopy date,
                                   p_effective_end_date   out nocopy date,
                                   p_effective_date       in date,
                                   p_business_group_id    in number,
                                   p_legislation_code     in varchar2,
                                   p_work_province        in varchar2,
                                   p_ret_code             out nocopy number,
                                   p_ret_text             out nocopy varchar2)
is
   l_emp_fed_tax_inf_id number;
   l_emp_province_tax_inf_id number;
   l_assignment_id   number;
   l_business_group_id   number;
  l_effective_start_date date;
   l_effective_end_date date;
   l_effective_date date;
   l_object_version_number number;
   l_legislation_code varchar2(30);
   l_province_code varchar2(30);

/* Before creating the default tax information for the person following things
should be checked:
1)The person has a primary address
2)The assignmnet has a salary basis, location address, GRE information and
Payroll name.
3)The default tax record is present is already present in the table or not.
  If the default tax record is already present in the system it will not be an
 'INSERT', it will be an 'UPDATE' with proper datetracking
*/

/* get_province_codes(parameter-list) */
begin
l_assignment_id := p_assignment_id;
l_legislation_code := p_legislation_code;
l_business_group_id := p_business_group_id;
 pay_ca_emp_fedtax_inf_api.create_ca_emp_fedtax_inf(
  p_validate                       => false
  ,p_emp_fed_tax_inf_id            => l_emp_fed_tax_inf_id
  ,p_effective_start_date          => l_effective_start_date
  ,p_effective_end_date            => l_effective_end_date
  ,p_legislation_code              => l_legislation_code
  ,p_assignment_id                 => l_assignment_id
  ,p_business_group_id             => l_business_group_id
  ,p_employment_province           => NULL
  ,p_tax_credit_amount             => NULL
  ,p_claim_code                    => NULL
  ,p_basic_exemption_flag          => 'Y'
  ,p_additional_tax                => 0
  ,p_annual_dedn                   => 0
  ,p_total_expense_by_commission    => 0
  ,p_total_remnrtn_by_commission   => 0
  ,p_prescribed_zone_dedn_amt      => 0
  ,p_other_fedtax_credits  => NULL
  ,p_cpp_qpp_exempt_flag           => 'N'
  ,p_fed_exempt_flag               => 'N'
  ,p_ei_exempt_flag                => 'N'
  ,p_tax_calc_method          => NULL
  ,p_fed_override_amount           => 0
  ,p_fed_override_rate             => 0
  ,p_ca_tax_information_category   => NULL
  ,p_ca_tax_information1           => NULL
  ,p_ca_tax_information2           => NULL
  ,p_ca_tax_information3           => NULL
  ,p_ca_tax_information4            => NULL
  ,p_ca_tax_information5            => NULL
  ,p_ca_tax_information6            => NULL
  ,p_ca_tax_information7            => NULL
  ,p_ca_tax_information8            => NULL
  ,p_ca_tax_information9            => NULL
  ,p_ca_tax_information10           => NULL
  ,p_ca_tax_information11           => NULL
  ,p_ca_tax_information12           => NULL
  ,p_ca_tax_information13           => NULL
  ,p_ca_tax_information14           => NULL
  ,p_ca_tax_information15           => NULL
  ,p_ca_tax_information16           => NULL
  ,p_ca_tax_information17           => NULL
  ,p_ca_tax_information18           => NULL
  ,p_ca_tax_information19           => NULL
  ,p_ca_tax_information20           => NULL
  ,p_ca_tax_information21           => NULL
  ,p_ca_tax_information22           => NULL
  ,p_ca_tax_information23           => NULL
  ,p_ca_tax_information24           => NULL
  ,p_ca_tax_information25           => NULL
  ,p_ca_tax_information26           => NULL
  ,p_ca_tax_information27           => NULL
  ,p_ca_tax_information28           => NULL
  ,p_ca_tax_information29           => NULL
  ,p_ca_tax_information30           => NULL
  ,p_object_version_number          => l_object_version_number
  ,p_fed_lsf_amount                 => 0
  ,p_effective_date                => p_effective_date
  ) ;
pay_ca_emp_prvtax_inf_api.create_ca_emp_prvtax_inf
  (p_validate                       => false
  ,p_emp_province_tax_inf_id        => l_emp_province_tax_inf_id
  ,p_effective_start_date          => l_effective_start_date
  ,p_effective_end_date            => l_effective_end_date
  ,p_legislation_code              => l_legislation_code
  ,p_assignment_id                 => l_assignment_id
  ,p_business_group_id             => l_business_group_id
  ,p_province_code                 => p_work_province
  ,p_jurisdiction_code             => NULL
  ,p_tax_credit_amount             => NULL
  ,p_basic_exemption_flag          => 'Y'
  ,p_deduction_code                => NULL
  ,p_extra_info_not_provided       => 'Y'
  ,p_marriage_status               => 'N'
  ,p_no_of_infirm_dependants       => 0
  ,p_non_resident_status           => 'N'
  ,p_disability_status             => 'N'
  ,p_no_of_dependants              => 0
  ,p_annual_dedn                   => 0
  ,p_total_expense_by_commission   => 0
  ,p_total_remnrtn_by_commission   => 0
  ,p_prescribed_zone_dedn_amt      => 0
  ,p_additional_tax                => 0
  ,p_prov_override_rate            => 0
  ,p_prov_override_amount          => 0
  ,p_prov_exempt_flag              => 'N'
  ,p_pmed_exempt_flag              => 'N'
  ,p_wc_exempt_flag                => 'N'
  ,p_qpp_exempt_flag               => 'N'
  ,p_tax_calc_method               => NULL
  ,p_other_tax_credit              => 0
  ,p_ca_tax_information_category   => NULL
  ,p_ca_tax_information1           => NULL
  ,p_ca_tax_information2           => NULL
  ,p_ca_tax_information3            => NULL
  ,p_ca_tax_information4            => NULL
  ,p_ca_tax_information5            => NULL
  ,p_ca_tax_information6            => NULL
  ,p_ca_tax_information7            => NULL
  ,p_ca_tax_information8            => NULL
  ,p_ca_tax_information9            => NULL
  ,p_ca_tax_information10           => NULL
  ,p_ca_tax_information11           => NULL
  ,p_ca_tax_information12           => NULL
  ,p_ca_tax_information13           => NULL
  ,p_ca_tax_information14           => NULL
  ,p_ca_tax_information15           => NULL
  ,p_ca_tax_information16           => NULL
  ,p_ca_tax_information17           => NULL
  ,p_ca_tax_information18           => NULL
  ,p_ca_tax_information19           => NULL
  ,p_ca_tax_information20           => NULL
  ,p_ca_tax_information21           => NULL
  ,p_ca_tax_information22           => NULL
  ,p_ca_tax_information23           => NULL
  ,p_ca_tax_information24           => NULL
  ,p_ca_tax_information25           => NULL
  ,p_ca_tax_information26           => NULL
  ,p_ca_tax_information27           => NULL
  ,p_ca_tax_information28           => NULL
  ,p_ca_tax_information29           => NULL
  ,p_ca_tax_information30           => NULL
  ,p_object_version_number          => l_object_version_number
  ,p_prov_lsp_amount                => 0
  ,p_effective_date                 => p_effective_date
  ,p_ppip_exempt_flag               => 'N'
  ) ;
  hr_utility.set_location('province_code'||l_province_code,999);

commit;

  hr_utility.set_location('pay_ca_emp_tax_inf.create_default_tax_record',99);
/****/
 end create_default_tax_record;

function get_basic_exemption(p_effective_date date,
                             p_province       varchar2 DEFAULT NULL)
return number is
CURSOR sel_inf_val IS
  SELECT fnd_number.canonical_to_number(information_value)
  FROM   pay_ca_legislation_info  pcli
  WHERE  pcli.information_type  =  'BASIC_EXEMPTION_AMOUNT'
  AND   ((p_province IS NULL and pcli.jurisdiction_code is null)
           OR (pcli.jurisdiction_code = p_province))
  AND    p_effective_date  BETWEEN pcli.start_date AND pcli.end_date;

l_basic_exempt_amnt number;
begin
open  sel_inf_val;
fetch sel_inf_val into l_basic_exempt_amnt;
close sel_inf_val;

return l_basic_exempt_amnt;
end get_basic_exemption;

procedure get_min_asg_start_date(p_assignment_id in number,
                                 p_min_start_date out nocopy date) is
cursor csr_min_date is
select min(effective_start_date)
from per_assignments_f paf
where paf.assignment_id   = p_assignment_id
and   paf.assignment_type <> 'A';

l_min_start_date date;
begin

open csr_min_date;
fetch csr_min_date into l_min_start_date;
close csr_min_date;

p_min_start_date := l_min_start_date;

end get_min_asg_start_date;



function get_tax_detail_num
              (p_assignment_id        NUMBER,
               p_effective_start_date DATE,
               p_effective_end_date   DATE,
               p_effective_date       DATE,
               p_info_type            VARCHAR2)
return number is

cursor csr_tax_num is
select
   tax_credit_amount
  ,basic_exemption_flag
  ,additional_tax
  ,annual_dedn
  ,total_expense_by_commission
  ,total_remnrtn_by_commission
  ,prescribed_zone_dedn_amt
  ,fed_override_amount
  ,fed_override_rate
  ,fed_lsf_amount
from pay_ca_emp_fed_tax_info_f peft where
     peft.assignment_id = p_assignment_id and
     p_effective_date between peft.effective_start_date and peft.effective_end_date;

  l_tax_credit_amount   number;
  l_basic_exemption_flag  varchar2(1);
  l_additional_tax       number;
  l_annual_dedn         number;
  l_total_expense_by_commission number;
  l_total_remnrtn_by_commission number;
  l_prescribed_zone_dedn_amt   number;
  l_fed_override_amount   number;
  l_fed_override_rate   number;
  l_fed_lsf_amount   number;

begin

open csr_tax_num;

fetch csr_tax_num into
   l_tax_credit_amount
  ,l_basic_exemption_flag
  ,l_additional_tax
  ,l_annual_dedn
  ,l_total_expense_by_commission
  ,l_total_remnrtn_by_commission
  ,l_prescribed_zone_dedn_amt
  ,l_fed_override_amount
  ,l_fed_override_rate
  ,l_fed_lsf_amount ;

if csr_tax_num%NOTFOUND then

  l_tax_credit_amount := NULL;
  l_basic_exemption_flag := 'Y';
  l_additional_tax   := 0.0;
  l_annual_dedn   := 0.0;
  l_total_expense_by_commission := 0.0;
  l_total_remnrtn_by_commission := 0.0;
  l_prescribed_zone_dedn_amt   := 0.0;
  l_fed_override_amount   := 0.0;
  l_fed_override_rate   := 0.0;
  l_fed_lsf_amount  := 0.0;
end if;
if  p_info_type = 'TCA' then

  if l_tax_credit_amount is null and l_basic_exemption_flag = 'Y' then

   select fnd_number.canonical_to_number(information_value)
   into  l_tax_credit_amount
   from  pay_ca_legislation_info  pcli
   where pcli.information_type    =  'BASIC_EXEMPTION_AMOUNT'
   and   pcli.jurisdiction_code IS NULL
   and   p_effective_date between pcli.start_date and pcli.end_date;

  end if;
 return l_tax_credit_amount;
--
elsif p_info_type = 'ADDTAX' then
 return l_additional_tax;
--
elsif p_info_type = 'ANNDED' then
 return l_annual_dedn;
--
elsif p_info_type =  'PZDN' then
 return l_prescribed_zone_dedn_amt;
--
elsif p_info_type =   'EXPCOMM' then
  return l_total_expense_by_commission;
--
elsif p_info_type = 'REMCOMM' then
  return l_total_remnrtn_by_commission;
--
elsif p_info_type = 'OVERRIDERATE' then
  return l_fed_override_rate;
--
elsif p_info_type = 'OVERRIDEAMNT' then
  return l_fed_override_amount ;
--
elsif p_info_type = 'LSF' then
  return l_fed_lsf_amount ;
--
end if;
end get_tax_detail_num;

function get_tax_detail_char(p_assignment_id in Number,
               p_effective_start_date in date,
               p_effective_end_date in date,
               p_effective_date in date,
               p_info_type  in VARCHAR2)
return VARCHAR2 is
cursor csr_tax_char is
select
  cpp_qpp_exempt_flag
  ,fed_exempt_flag
  ,ei_exempt_flag
  ,tax_calc_method
from pay_ca_emp_fed_tax_info_f peft where
     peft.assignment_id = p_assignment_id and
     p_effective_date between peft.effective_start_date and peft.effective_end_date;

CURSOR csr_get_default_province IS
select pcp.province_abbrev, '70-'||pcp.province_code||'-0000' geocode
from per_assignments_f  paf,
     hr_locations       hl,
     pay_ca_provinces_v pcp
where paf.assignment_id = p_assignment_id
and   p_effective_date between paf.effective_start_date
                           and paf.effective_end_date
and   paf.location_id = hl.location_id
and   hl.region_1 = pcp.province_abbrev;

CURSOR csr_get_override_province IS
select pcp.province_abbrev, '70-'||pcp.province_code||'-0000'  geocode
from pay_ca_emp_fed_tax_info_f  pf,
     pay_ca_provinces_v pcp
where p_effective_date between pf.effective_start_date
                           and pf.effective_end_date
and   pf.employment_province = pcp.province_abbrev
and   pf.assignment_id = p_assignment_id;


  l_employment_province  varchar2(30);
  l_cpp_qpp_exempt_flag       varchar2(1);
  l_fed_exempt_flag          varchar2(1);
  l_ei_exempt_flag          varchar2(1);
  l_tax_calc_method        varchar2(30);
  l_geocode                varchar2(30);
begin

--Get the province of employments

IF  p_info_type = 'GEOCODE' OR p_info_type = 'EMPPROV' THEN
  OPEN csr_get_override_province;
  FETCH csr_get_override_province INTO l_employment_province, l_geocode;
  IF csr_get_override_province%NOTFOUND THEN
    OPEN csr_get_default_province;
    FETCH csr_get_default_province INTO l_employment_province, l_geocode;
    IF csr_get_default_province%NOTFOUND THEN
          l_employment_province := NULL;
          l_geocode := '00-000-0000';
    END IF;
    CLOSE csr_get_default_province;
  END IF;
  CLOSE csr_get_override_province;

ELSE

  l_geocode := '00-000-0000';

END IF;

open csr_tax_char;
fetch csr_tax_char into
   l_cpp_qpp_exempt_flag
  ,l_fed_exempt_flag
  ,l_ei_exempt_flag
  ,l_tax_calc_method;

if csr_tax_char%NOTFOUND then
  l_cpp_qpp_exempt_flag := 'N';
  l_fed_exempt_flag     := 'N';
  l_ei_exempt_flag    := 'N';
  l_tax_calc_method   := NULL;
end if;

if p_info_type = 'EMPPROV' then
 return l_employment_province;
--
elsif p_info_type = 'GEOCODE' then
 return l_geocode;
--
elsif p_info_type = 'FEDEXEMPT' then
 return l_fed_exempt_flag;
--
elsif p_info_type = 'EIEXEMPT' then
 return l_ei_exempt_flag;
--
elsif p_info_type =   'PPEXEMPT' then
 return l_cpp_qpp_exempt_flag;
--
elsif p_info_type = 'CALCMETHOD' then
  return l_tax_calc_method;
--
end if;
close csr_tax_char;
end get_tax_detail_char;

--
function get_tax_detail_dfs(p_assignment_id in Number,
               p_effective_start_date in date,
               p_effective_end_date in date,
               p_effective_date in date,
               p_info_type  in VARCHAR2)

return varchar2 is

cursor csr_tax_dfs is
select
ca_tax_information1
from pay_ca_emp_fed_tax_info_f peft where
     peft.assignment_id = p_assignment_id and
     p_effective_date between
     peft.effective_start_date and peft.effective_end_date and
     ca_tax_information_category = 'FED' ;

  l_ca_tax_information1  varchar2(1);
begin

open csr_tax_dfs;

fetch csr_tax_dfs into
  l_ca_tax_information1;

if csr_tax_dfs%NOTFOUND then
  l_ca_tax_information1 := 'N';
end if;

if  p_info_type = 'STATINDIAN' then
 return l_ca_tax_information1;
end if;

end get_tax_detail_dfs;

--


function get_prov_tax_detail_num(p_assignment_id in Number,
               p_effective_start_date in date,
               p_effective_end_date in date,
               p_effective_date in date,
               p_province_abbrev in varchar2,
               p_info_type  in VARCHAR2)
return number is

cursor csr_tax_num is
select
  tax_credit_amount
  ,basic_exemption_flag
  ,no_of_infirm_dependants
  ,no_of_dependants
  ,annual_dedn
  ,total_expense_by_commission
  ,total_remnrtn_by_commission
  ,prescribed_zone_dedn_amt
  ,additional_tax
  ,prov_override_rate
  ,prov_override_amount
  ,prov_lsp_amount
from pay_ca_emp_prov_tax_info_f pept where
     pept.assignment_id = p_assignment_id and
     p_effective_date between pept.effective_start_date and pept.effective_end_date and
     pept.province_code = p_province_abbrev;

  l_tax_credit_amount   number;
  l_basic_exemption_flag  varchar2(1);
  l_no_of_infirm_dependants    number;
  l_no_of_dependants    number;
  l_annual_dedn         number;
  l_additional_tax       number;
  l_total_expense_by_commission number;
  l_total_remnrtn_by_commission number;
  l_prov_override_amount   number;
  l_prov_override_rate   number;
  l_prescribed_zone_dedn_amt   number;
  l_prov_lsp_amount   number;

begin

open csr_tax_num;

fetch csr_tax_num into
  l_tax_credit_amount
  ,l_basic_exemption_flag
  ,l_no_of_infirm_dependants
  ,l_no_of_dependants
  ,l_annual_dedn
  ,l_total_expense_by_commission
  ,l_total_remnrtn_by_commission
  ,l_prescribed_zone_dedn_amt
  ,l_additional_tax
  ,l_prov_override_rate
  ,l_prov_override_amount
  ,l_prov_lsp_amount ;

if csr_tax_num%NOTFOUND then

  l_tax_credit_amount       := NULL;
  l_basic_exemption_flag    := 'Y';
  l_no_of_infirm_dependants := 0;
  l_no_of_dependants        := 0;
  l_annual_dedn             := 0.0;
  l_additional_tax          := 0.0;
  l_total_expense_by_commission := 0.0;
  l_total_remnrtn_by_commission := 0.0;
  l_prov_override_amount        := 0.0;
  l_prov_override_rate          := 0.0;
  l_prescribed_zone_dedn_amt    := 0.0;
  l_prov_lsp_amount  		:= 0.0;

end if;

if  p_info_type = 'TCA' then

  if l_tax_credit_amount is null and l_basic_exemption_flag = 'Y' then

   select fnd_number.canonical_to_number(information_value)
   into l_tax_credit_amount
   from pay_ca_legislation_info  pcli
   where pcli.information_type =  'BASIC_EXEMPTION_AMOUNT'
   and   pcli.jurisdiction_code = p_province_abbrev
   and p_effective_date  between pcli.start_date and pcli.end_date;

  end if;
 return l_tax_credit_amount;
--
elsif p_info_type = 'NUMDEP' then
 return l_no_of_dependants;
--
elsif p_info_type = 'INFDEP' then
 return l_no_of_infirm_dependants;
--
elsif p_info_type = 'ADDTAX' then
 return l_additional_tax;
--
elsif p_info_type = 'ANNDED' then
 return l_annual_dedn;
--
elsif p_info_type =   'EXPCOMM' then
  return l_total_expense_by_commission;
--
elsif p_info_type = 'REMCOMM' then
  return l_total_remnrtn_by_commission;
--
elsif p_info_type = 'PZDN' then
  return l_prescribed_zone_dedn_amt;
--
elsif p_info_type = 'OVERRIDERATE' then
  return l_prov_override_rate;
--
elsif p_info_type = 'OVERRIDEAMNT' then
  return l_prov_override_amount ;
--
elsif p_info_type = 'LSP' then
  return l_prov_lsp_amount ;
--
end if;
end get_prov_tax_detail_num;

function get_prov_tax_detail_char(p_assignment_id in Number,
               p_effective_start_date in date,
               p_effective_end_date in date,
               p_effective_date in date,
               p_province_abbrev in varchar2,
               p_info_type  in VARCHAR2)
return VARCHAR2 is

cursor csr_prov_tax_char is
select
  jurisdiction_code
  , extra_info_not_provided
  , marriage_status
  , non_resident_status
  , disability_status
  ,prov_exempt_flag
  ,pmed_exempt_flag
  ,wc_exempt_flag
  ,qpp_exempt_flag
  ,tax_calc_method
  ,ppip_exempt_flag
from pay_ca_emp_prov_tax_info_f pept where
     pept.assignment_id = p_assignment_id and
     p_effective_date between pept.effective_start_date and pept.effective_end_date and
     pept.province_code = p_province_abbrev;

   l_jurisdiction_code   varchar2(11);
   l_extra_info_not_provided   varchar2(11);
   l_marriage_status   varchar2(30);
   l_non_resident_status   varchar2(30);
   l_disability_status    varchar2(30);
   l_prov_exempt_flag   varchar2(30);
   l_pmed_exempt_flag   varchar2(30);
   l_wc_exempt_flag    varchar2(30);
   l_qpp_exempt_flag    varchar2(30);
   l_tax_calc_method    varchar2(30);
   l_ppip_exempt_flag    varchar2(30);

begin
open csr_prov_tax_char;
fetch csr_prov_tax_char into
  l_jurisdiction_code
  ,l_extra_info_not_provided
  ,l_marriage_status
  ,l_non_resident_status
  ,l_disability_status
  ,l_prov_exempt_flag
  ,l_pmed_exempt_flag
  ,l_wc_exempt_flag
  ,l_qpp_exempt_flag
  ,l_tax_calc_method
  ,l_ppip_exempt_flag;

if csr_prov_tax_char%NOTFOUND then

  l_extra_info_not_provided := 'Y';
  l_marriage_status     := NULL;
  l_non_resident_status := NULL;
  l_disability_status   := NULL;
  l_prov_exempt_flag    := NULL;
  l_pmed_exempt_flag    := NULL;
  l_wc_exempt_flag      := NULL;
  l_tax_calc_method     := NULL;
  l_ppip_exempt_flag    := NULL;

end if;


if p_info_type = 'NOTPROV' then
 return l_extra_info_not_provided;
--
elsif p_info_type = 'MARRIED' then
 return l_marriage_status;
--
elsif p_info_type = 'NONRES' then
 return l_non_resident_status;
--
elsif p_info_type = 'DISABLE' then
 return l_disability_status;
--
elsif p_info_type =  'PROVEXEMPT' then
 return l_prov_exempt_flag;
--
elsif p_info_type =  'PMEDEXEMPT' then
 return l_pmed_exempt_flag;
--
elsif p_info_type =  'WCBEXEMPT' then
 return l_wc_exempt_flag;
--
elsif p_info_type =  'QPPEXEMPT' then
 return l_qpp_exempt_flag;
--
elsif p_info_type = 'CALCMETHOD' then
  return l_tax_calc_method;
--
elsif p_info_type =  'PPIPEXEMPT' then
 return l_ppip_exempt_flag;
--
end if;
 close csr_prov_tax_char;
end get_prov_tax_detail_char;

--

function get_prov_tax_detail_dfs(p_assignment_id in Number,
               p_effective_start_date in date,
               p_effective_end_date in date,
               p_effective_date in date,
               p_province_abbrev in varchar2,
               p_info_type  in VARCHAR2)
return VARCHAR2 is
cursor csr_prov_tax_dfs is
select
ca_tax_information1,
ca_tax_information2
from pay_ca_emp_prov_tax_info_f pept where
     pept.assignment_id = p_assignment_id and
     p_effective_date between
     pept.effective_start_date and pept.effective_end_date and
--     ca_tax_information_category =  p_province_abbrev;
     ca_tax_information_category =  'PROV'  and
     p_province_abbrev           =  province_code;

  l_ca_tax_information1  varchar2(1);
  l_ca_tax_information2  varchar2(1);
begin

/*The value for the Indian status flex field should only be considered in the
  provincial tax calculation if the province is one of the three provinces below */

if p_province_abbrev <> 'NT' and
   p_province_abbrev <> 'NU' and
   p_province_abbrev <> 'QC'  then

/* If the province is Manitoba then return the over 65 flag */

     if p_province_abbrev = 'MB' then

          open csr_prov_tax_dfs;

          fetch csr_prov_tax_dfs into
           l_ca_tax_information1,
           l_ca_tax_information2;

          if csr_prov_tax_dfs%NOTFOUND then
           l_ca_tax_information2 := 'N';
          end if;

          close csr_prov_tax_dfs;
     else
          l_ca_tax_information2 := 'N';
     end if;

     l_ca_tax_information1 := 'N';

else
     open csr_prov_tax_dfs;

     fetch csr_prov_tax_dfs into
      l_ca_tax_information1,
      l_ca_tax_information2;

     if csr_prov_tax_dfs%NOTFOUND then
      l_ca_tax_information1 := 'N';
     end if;

     close csr_prov_tax_dfs;

     l_ca_tax_information2 := 'N';

end if;

if     p_info_type = 'STATINDIAN' then
    return l_ca_tax_information1;
elsif  p_info_type = 'OVER65' then
    return l_ca_tax_information2;
end if;

end get_prov_tax_detail_dfs;

--

function get_address(p_person_id       in Number,
                     p_effective_date  in date,
                     address_line_no   in number
                    ) return VARCHAR2 is
cursor csr_address( p_person_id      in number,
                    p_effective_date in date) is

select substr(addr.address_line1,1,37)		,
       substr(addr.address_line2,1,37)		,
       substr(addr.address_line3,1,37)		,
       rtrim(substr(addr.town_or_city,1,23))  ||' '||addr.region_1||' '||addr.postal_code
from   per_addresses             addr
WHERE  addr.person_id		= p_person_id
AND    addr.primary_flag	= 'Y'
AND    p_effective_date between
                      addr.date_from and nvl(addr.date_to, p_effective_date);

l_emp_addr_line1  varchar2(80);
l_emp_addr_line2  varchar2(80);
l_emp_addr_line3  varchar2(80);
l_emp_addr_line4  varchar2(180);
l_emp_addr_line   varchar2(180);

begin

  open csr_address(p_person_id,p_effective_date);

  fetch csr_address into l_emp_addr_line1,
                         l_emp_addr_line2,
                         l_emp_addr_line3,
                         l_emp_addr_line4;

  if csr_address%NOTFOUND then
   l_emp_addr_line1 := 'ADDRESS NOT IN THE FILE';
   l_emp_addr_line2 := 'ADDRESS NOT IN THE FILE';
   l_emp_addr_line3 := 'ADDRESS NOT IN THE FILE';
   l_emp_addr_line4 := 'ADDRESS NOT IN THE FILE';
  end if;
  close csr_address;
--
  if address_line_no = 1 then
   l_emp_addr_line := l_emp_addr_line1;
  elsif address_line_no = 2 then
   l_emp_addr_line := l_emp_addr_line2;
  elsif address_line_no = 3 then
   l_emp_addr_line := l_emp_addr_line3;
  elsif address_line_no = 4 then
   l_emp_addr_line := l_emp_addr_line4;
  end if;

return l_emp_addr_line;

end get_address;

function get_salary_basis(p_salary_basis_id in Number)
return VARCHAR2 is
cursor csr_salary_basis(l_pay_basis_id in number) is
select pay_basis from per_pay_bases
where pay_basis_id = l_pay_basis_id;

l_salary_basis varchar2(30);
begin
  open csr_salary_basis(p_salary_basis_id);
  fetch csr_salary_basis into l_salary_basis;
  if csr_salary_basis%NOTFOUND then
   l_salary_basis := 'NOT FOUND';
  end if;
  close csr_salary_basis;
  return l_salary_basis;
end get_salary_basis;


function get_base_salary(p_assignment_id   in Number,
                         p_effective_date  in date,
                         p_salary_basis_id in number)
return VARCHAR2 is
cursor csr_base_salary(l_assignment_id  in number,
                       l_effective_date in date,
                       l_input_value_id in number) is
select decode(instr(peev.screen_entry_value,'.'),
                     0,
                     peev.screen_entry_value|| '.00',
                     peev.screen_entry_value
             )
from   pay_element_entries_f      pee,
       pay_element_entry_values_f peev,
       pay_input_values_f         piv
WHERE  l_effective_date
       between pee.effective_start_date AND pee.effective_end_date
AND    pee.element_entry_id = peev.element_entry_id
AND    pee.entry_type = 'E'
AND    pee.assignment_id = l_assignment_id
AND    l_effective_date
       between  peev.effective_start_date and peev.effective_end_date
AND    peev.input_value_id+0 = piv.input_value_id
AND    l_effective_date
between    piv.effective_start_date AND piv.effective_end_date
AND    piv.input_value_id = l_input_value_id;

cursor csr_input_value_id(l_pay_basis_id in number) is
select input_value_id from per_pay_bases
where pay_basis_id = l_pay_basis_id;

l_base_salary varchar2(30);
l_input_value_id number;
begin

  open csr_input_value_id(p_salary_basis_id);
  fetch csr_input_value_id into l_input_value_id;
  if csr_input_value_id%NOTFOUND then
   l_base_salary := 'NOT ENTERED';
  else
     open csr_base_salary(p_assignment_id,
                          p_effective_date,
                          l_input_value_id) ;
     fetch csr_base_salary into l_base_salary;
     if csr_base_salary%NOTFOUND then
      l_base_salary := 'NOT ENTERED';
     end if;
     close csr_base_salary;
  end if;
  close csr_input_value_id;
--
  return l_base_salary;
end get_base_salary;

function get_summary_info(p_assignment_action_id       in Number,
                          p_information_type           in varchar2,
                          p_dimension                  in varchar2
                    ) return number is
l_value number;
begin
 if p_information_type <> 'DEDUCTIONS_SUMM' then
   select  decode(p_dimension,'CURRENT',amount_current,'YTD',amount_ytd)
   into l_value
   from pay_ca_soe_summ_balances_v pcs
   where pcs.assignment_action_id = p_assignment_action_id
   and   pcs.base_bal_name = decode(p_information_type,'GROSS_PAY_SUMM', /*balance_name changed to base_bal_name against bug#5169734*/
                                                      'Gross Pay',
                                                      'TAXABLE_BENEFIT_SUMM',
                                                      'Taxable Benefits',
                                                      'GROSS_EARNINGS_SUMM',
                                                      'Gross Earnings',
                                                      'TAXES_SUMM',
                                                      'Tax Deductions',
                                                      'NET_PAY_SUMM',
                                                      'Payments');
  else
   select  sum(decode(p_dimension,'CURRENT',amount_current,'YTD',amount_ytd))
   into l_value
   from pay_ca_soe_summ_balances_v pcs
   where pcs.assignment_action_id = p_assignment_action_id
   and   pcs.balance_name in (
                         'Pre Tax Deductions',
                         'Involuntary Deductions',
                         'Voluntary Deductions'
                                );
 end if;
return l_value;
EXCEPTION
when no_data_found
then return 0;

end get_summary_info;

function check_age_under18_or_over70(p_payroll_action_id in Number,
                         p_date_of_birth in Date) return VARCHAR2  is
l_check_age 	VARCHAR2(1);
l_effective_date Date;
-- Get

 CURSOR csr_get_effective_date(l_payroll_action_id in Number) IS
 SELECT effective_date
   FROM pay_payroll_actions
  WHERE payroll_action_id = l_payroll_action_id;

begin
l_check_age := 'N';

	open csr_get_effective_date(p_payroll_action_id);
	  fetch csr_get_effective_date into l_effective_date;
	close csr_get_effective_date;

	if (( add_months(trunc(p_date_of_birth,'MONTH'),(18*12)+1)) <= l_effective_date ) then
		if ( l_effective_date >= ( add_months(trunc(p_date_of_birth,'MONTH'),(70*12)+1))) then
   			l_check_age := 'Y';
        	else
   			l_check_age := 'N';
        	end if;
	else
		l_check_age := 'Y';

	end if;

return l_check_age;
end check_age_under18_or_over70;

function check_age_under18(p_payroll_action_id in Number,
                         p_date_of_birth in Date) return VARCHAR2  is
l_check_age 	VARCHAR2(1);
l_effective_date Date;
-- Get

 CURSOR csr_get_effective_date(l_payroll_action_id in Number) IS
 SELECT effective_date
   FROM pay_payroll_actions
  WHERE payroll_action_id = l_payroll_action_id;

begin
l_check_age := 'N';

	open csr_get_effective_date(p_payroll_action_id);
	  fetch csr_get_effective_date into l_effective_date;
	close csr_get_effective_date;

	if (( add_months(trunc(p_date_of_birth,'MONTH'),(18*12)+1)) <= l_effective_date ) then
   		l_check_age := 'N';
	else
		l_check_age := 'Y';

	end if;

return l_check_age;
end check_age_under18;


function retro_across_calendar_years (p_element_entry_id  in number,
                                      p_payroll_action_id in number)
return varchar2 is

 l_creator_type         varchar2(30);
 l_source_id            number;
 l_source_asg_action_id number;
 l_originating_date     date;
 l_current_date         date;
 l_check_years         varchar2(1);

 cursor csr_get_current_date is
 select effective_date
 from pay_payroll_actions
 where payroll_action_id = p_payroll_action_id;

 cursor csr_get_ele_entry_info is
 select creator_type, source_id, source_asg_action_id
 from pay_element_entries_f
 where element_entry_id = p_element_entry_id;

 cursor csr_get_orig_date_rr(l_run_result_id in number) is
 select ppa.effective_date
 from pay_run_results prr,
      pay_assignment_actions paa,
      pay_payroll_actions ppa
 where prr.run_result_id = l_run_result_id
 and prr.assignment_action_id = paa.assignment_action_id
 and paa.payroll_action_id = ppa.payroll_action_id;

 cursor csr_get_orig_date_asgact(l_asg_action_id in number) is
 select ppa.effective_date
 from pay_assignment_actions paa,
      pay_payroll_actions ppa
 where paa.assignment_action_id = l_asg_action_id
 and ppa.payroll_action_id = paa.payroll_action_id;

begin

  open csr_get_current_date;
  fetch csr_get_current_date
  into l_current_date;
  close csr_get_current_date;

  open csr_get_ele_entry_info;
  fetch csr_get_ele_entry_info
  into l_creator_type, l_source_id, l_source_asg_action_id;
  close csr_get_ele_entry_info;

  if l_creator_type = 'RR' then

    open csr_get_orig_date_rr(l_source_id);
    fetch csr_get_orig_date_rr
    into l_originating_date;
    close csr_get_orig_date_rr;

    if to_char(l_originating_date,'YYYY') = to_char(l_current_date,'YYYY') then
      l_check_years := 'N';
    else
      l_check_years := 'Y';
    end if;

  elsif l_creator_type = 'EE' then

    open csr_get_orig_date_asgact(l_source_asg_action_id);
    fetch csr_get_orig_date_asgact
    into l_originating_date;
    close csr_get_orig_date_asgact;

    if to_char(l_originating_date,'YYYY') = to_char(l_current_date,'YYYY') then
      l_check_years := 'N';
    else
      l_check_years := 'Y';
    end if;

  else
    l_check_years := 'N';
  end if;

  return l_check_years;

end retro_across_calendar_years;

/*****************************************************************************
Delete_fed_tax_rule procedure calls
    pay_ca_emp_fedtax_inf_api.delete_ca_emp_fedtax_inf procedure for updating
    Effective_End_Date of tax records in PAY_CA_EMP_FED_TAX_INFO_F table.

    pay_ca_emp_prvtax_inf_api.delete_ca_emp_prvtax_inf procedure for updating
    Effective_End_Date of tax records in PAY_CA_EMP_PROV_TAX_INFO_F table.

*****************************************************************************/

procedure delete_fed_tax_rule
  (p_effective_date                 in     date
  ,p_datetrack_delete_mode          in     varchar2
  ,p_assignment_id                  in     number
  ,p_delete_routine                 in     varchar2
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := 'delete_fed_tax_rule';
  l_effective_date             date;
  l_emp_prov_tax_inf_id        pay_ca_emp_prov_tax_info_f.emp_province_tax_inf_id%TYPE;
  l_emp_fed_tax_inf_id         pay_ca_emp_fed_tax_info_f.emp_fed_tax_inf_id%TYPE;
  l_effective_start_date       pay_ca_emp_fed_tax_info_f.effective_start_date%TYPE;
  l_effective_end_date         pay_ca_emp_fed_tax_info_f.effective_end_date%TYPE;
  l_object_version_number      pay_ca_emp_fed_tax_info_f.object_version_number%TYPE;
  l_tmp_effective_start_date   pay_ca_emp_fed_tax_info_f.effective_start_date%TYPE;
  l_tmp_effective_end_date     pay_ca_emp_fed_tax_info_f.effective_end_date%TYPE;
  l_tmp_object_version_number  pay_ca_emp_fed_tax_info_f.object_version_number%TYPE;
  --
  l_exit_quietly          exception;
  --
  cursor csr_fed_rule is
    select fed.emp_fed_tax_inf_id, fed.object_version_number
    from   pay_ca_emp_fed_tax_info_f fed
    where  fed.assignment_id = p_assignment_id
    and    l_effective_date between fed.effective_start_date
                                and fed.effective_end_date;
  --
  cursor csr_prov_rule is
    select sta.emp_province_tax_inf_id, sta.object_version_number
    from   pay_ca_emp_prov_tax_info_f sta
    where  sta.assignment_id = p_assignment_id
    and    l_effective_date between sta.effective_start_date
                                and sta.effective_end_date;
  --
  --
begin
  --
  --
  hr_utility.set_location(' Entering: '||'pay_ca_emp_tax_inf'||l_proc, 10);
  l_effective_date := trunc(p_effective_date);
  --
  -- Validate that a federal tax rule exists for this assignment
  --
  open csr_fed_rule;
  fetch csr_fed_rule into l_emp_fed_tax_inf_id, l_object_version_number;
  if csr_fed_rule%notfound then
    close csr_fed_rule;
    raise l_exit_quietly;
  end if;
  close csr_fed_rule;

  hr_utility.set_location(l_proc, 20);
  --
  if p_datetrack_delete_mode NOT IN ('ZAP', 'DELETE') then
    hr_utility.set_message(801, 'HR_7204_DT_DEL_MODE_INVALID');
    hr_utility.raise_error;
  end if;
  --
  -- Validate that this routine is called from Assignment code
  --

  hr_utility.set_location(l_proc, 30);

  if nvl(p_delete_routine,'X') <> 'ASSIGNMENT' then
    hr_utility.set_message(801, 'HR_6674_PAY_ASSIGN');
    hr_utility.raise_error;
  end if;
  --
  open csr_prov_rule;
  loop
    fetch csr_prov_rule into l_emp_prov_tax_inf_id, l_tmp_object_version_number;
    exit when csr_prov_rule%notfound;
    --
    --  Call delete_tax_rules API here passing in l_assignment_id, l_state_code
    pay_ca_emp_prvtax_inf_api.delete_ca_emp_prvtax_inf(
                    p_validate              => NULL -- check whether NULL is correct.
                   ,p_emp_province_tax_inf_id   => l_emp_prov_tax_inf_id
                   ,p_effective_start_date  => l_tmp_effective_start_date
                   ,p_effective_end_date    => l_tmp_effective_end_date
                   ,p_object_version_number => l_tmp_object_version_number
                   ,p_effective_date        => l_effective_date
                   ,p_datetrack_mode        => p_datetrack_delete_mode
                   );

    --
  end loop;
  close csr_prov_rule;

  hr_utility.set_location(l_proc, 40);
  --
  -- Need to check whether this procedure should be called
/*  maintain_wc(
                   p_emp_fed_tax_rule_id    => l_emp_fed_tax_inf_id
                  ,p_effective_start_date   => l_effective_start_date
                  ,p_effective_end_date     => l_effective_end_date
                  ,p_effective_date         => l_effective_date
                  ,p_datetrack_mode         => p_datetrack_delete_mode
                  );
*/
  --
  --pay_fed_del.del(p_emp_fed_tax_rule_id     => l_emp_fed_tax_inf_id
  pay_ca_emp_fedtax_inf_api.delete_ca_emp_fedtax_inf(
                  p_validate              => NULL  -- check whether NULL is correct.
                 ,p_emp_fed_tax_inf_id      => l_emp_fed_tax_inf_id
                 ,p_effective_start_date    => l_effective_start_date
                 ,p_effective_end_date      => l_effective_end_date
                 ,p_object_version_number   => l_object_version_number
                 ,p_effective_date          => l_effective_date
                 ,p_datetrack_mode          => p_datetrack_delete_mode
                 );
  --
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Set all output arguments
  --
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving: '||'pay_ca_emp_tax_inf'||l_proc, 60);
  --
exception
  --
  when l_exit_quietly then
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := null;
    --
    hr_utility.set_location(' Leaving:'||'pay_ca_emp_tax_inf'||l_proc, 70);
    --
    --
end delete_fed_tax_rule;

/*****************************************************************************
    Maintain_ca_employee_taxes procedure fetches Assignment_id
    values for the given period_of_service_id
    and calls Delete_fed_tax_rule procedure.
*****************************************************************************/

procedure maintain_ca_employee_taxes
(  p_period_of_service_id           in  number,
   p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2  default null
  ,p_delete_routine                 in  varchar2  default null
 ) is

  TYPE assign_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  --
  -- Declare cursors and local variables
  --
  l_proc               varchar2(72) := 'maintain_ca_employee_taxes';
  l_counter                    number := 0;
  l_effective_date             date;
  l_assignment_id              per_assignments_f.assignment_id%TYPE;
  l_fed_object_version_number
                          pay_ca_emp_fed_tax_info_f.object_version_number%TYPE;
  l_fed_eff_start_date    pay_ca_emp_fed_tax_info_f.effective_start_date%TYPE;
  l_fed_eff_end_date      pay_ca_emp_fed_tax_info_f.effective_end_date%TYPE;
  l_temp_num              number;
  l_cnt                   number;
  l_assignment_tbl        assign_tbl_type;

  l_exit_quietly          exception;
  --
-- rmonge Bug fix 3599825.

  cursor csr_asg_id(p_csr_assignment_id number) is
    select null
    from per_assignments_f  asg,
        hr_organization_information bus
    where asg.assignment_id    = p_csr_assignment_id
    and bus.organization_id  = asg.business_group_id
    and bus.org_information9  = 'CA'
    and bus.org_information_context = 'Business Group Information'
    and p_effective_date  between asg.effective_start_date
                              and asg.effective_end_date ;

  cursor csr_adr_asg_id is
    select asg.assignment_id
    from   per_assignments_f asg,
           per_periods_of_service pps
    where  asg.person_id = pps.person_id
    and     pps.period_of_service_id = p_period_of_service_id
    and    p_effective_date between asg.effective_start_date
                                and asg.effective_end_date;
  --
  --
begin
  --
  hr_utility.set_location('Entering: '||'pay_ca_emp_tax_inf'||l_proc, 10);
  --
  l_effective_date := trunc(p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- First check if geocode has been installed or not. If no geocodes
  -- installed then return because there is nothing to be done by this
  -- procedure
  if hr_general.chk_maintain_tax_records = 'N' then
     raise l_exit_quietly;
  end if;

  hr_utility.set_location(l_proc, 30);

  if p_datetrack_mode NOT IN ('ZAP',
                              'DELETE',
                              'UPDATE',
                              'CORRECTION',
                              'UPDATE_OVERRIDE',
                              'UPDATE_CHANGE_INSERT') then
    hr_utility.set_message(801, 'HR_7204_DT_DEL_MODE_INVALID');
    hr_utility.raise_error;
  elsif p_datetrack_mode in ('ZAP', 'DELETE') then
    hr_utility.set_location(l_proc, 40);
    --
      l_cnt := 0;
      for l_assgn_rec in csr_adr_asg_id loop
        l_cnt := l_cnt + 1;
        l_assignment_tbl(l_cnt) := l_assgn_rec.assignment_id;
      end loop;

    --

    hr_utility.set_location('number of assignments '||l_assignment_tbl.count, 45);

    for l_cnt in 1..l_assignment_tbl.last loop
      open csr_asg_id(l_assignment_tbl(l_cnt));
      fetch csr_asg_id into l_temp_num;
      if csr_asg_id%notfound then
        close csr_asg_id;
        hr_utility.set_message(801,'PAY_7702_PDT_VALUE_NOT_FOUND');
        hr_utility.raise_error;
      end if;
      close csr_asg_id;
      --
      hr_utility.set_location(l_proc, 50);
      hr_utility.set_location('assignment id '||l_assignment_tbl(l_cnt), 55);
      delete_fed_tax_rule(
                        p_effective_date         => l_effective_date
                       ,p_datetrack_delete_mode  => p_datetrack_mode
                       ,p_assignment_id          => l_assignment_tbl(l_cnt)
                       ,p_delete_routine         => p_delete_routine
                       ,p_effective_start_date   => l_fed_eff_start_date
                       ,p_effective_end_date     => l_fed_eff_end_date
                       ,p_object_version_number  => l_fed_object_version_number
                       );
    end loop;

  end if;  -- datetrack mode is ZAP?
  --
  hr_utility.set_location(' Leaving:'||'pay_ca_emp_tax_inf'||l_proc, 60);
 --
exception
  --
  when l_exit_quietly then
    hr_utility.set_location(' Leaving:'||'pay_ca_emp_tax_inf'||l_proc, 70);
  --
end maintain_ca_employee_taxes;

procedure delete_tax_record
( p_period_of_service_id     in  number,
  p_final_process_date       in  date) is

  -- Declare cursors and local variables
  --
  l_proc               varchar2(72) := 'delete_tax_record';

begin

  --
  hr_utility.set_location('Entering: '||'pay_ca_emp_tax_inf'||l_proc, 10);
  --

    maintain_ca_employee_taxes
    (  p_period_of_service_id     => p_period_of_service_id,
       p_effective_date           => p_final_process_date,
       p_datetrack_mode           => 'DELETE',
       p_delete_routine           => 'ASSIGNMENT'
     );

  hr_utility.set_location('Leaving: '||'pay_ca_emp_tax_inf'||l_proc, 20);

exception
  --
  when others then
    hr_utility.set_location(' Leaving:'||'pay_ca_emp_tax_inf'||l_proc, 30);
  --
end delete_tax_record;

/* The following function is used for determining whether an employee assignment is
EI exempted or not. This function is invoked by the ROE Magnetic Media to determine whether
Box 17b earnings need to be added to insurable earnings or not. */

function check_ei_exempt(p_roe_assignment_id in Number,
                         p_roe_date in Date) return VARCHAR2  is
l_ei_flag 	VARCHAR2(1);
l_assignment_id NUMBER;
l_roe_end_date DATE;


CURSOR csr_get_ei_flag_17b(l_assignment_id in Number,l_roe_end_date Date) IS
select NVL(ei_exempt_flag,'N')
from pay_ca_emp_fed_tax_info_f peft where
     peft.assignment_id = l_assignment_id

AND l_roe_end_date between peft.effective_start_date and peft.effective_end_date;


begin
l_ei_flag := 'N';

open csr_get_ei_flag_17b(p_roe_assignment_id,p_roe_date);
fetch csr_get_ei_flag_17b into l_ei_flag;
IF csr_get_ei_flag_17b%NOTFOUND THEN
	l_ei_flag := 'N';
END IF;
close csr_get_ei_flag_17b;


return l_ei_flag;
end check_ei_exempt;


end pay_ca_emp_tax_inf;

/
