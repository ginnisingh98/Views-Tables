--------------------------------------------------------
--  DDL for Package Body PAY_FI_PSTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_PSTR" as
   /* $Header: pyfipstr.pkb 120.0.12000000.1 2007/04/26 12:12:32 dbehera noship $ */
   procedure populate_details (
      p_business_group_id   in              number,
      p_payroll_action_id   in              varchar2,
      p_template_name       in              varchar2,
      p_xml                 out nocopy      clob
   ) is
      --
        --
        /*Cursor to fetch Header Information */
      cursor csr_get_hdr_info (
         p_payroll_action_id   number
      ) is
         select action_information2 business_group_id, action_information3 legal_employer_id,
                action_information4
                      legal_employer_name, action_information5 legal_empl_y_num,
                action_information6 local_unit_id, action_information7 local_unit_name, action_information8 local_unit_sd_no,
                action_information9
                      year, effective_date
           from pay_action_information pai
          where action_context_type = 'PA'
            and action_context_id = p_payroll_action_id
            and action_information_category = 'EMEA REPORT DETAILS'
            and action_information1 = 'PYFIPSTA';

      rl_hdr_info                      csr_get_hdr_info%rowtype;

      cursor csr_get_local_unit_details (
         p_payroll_action_id   number
      ) is
         select action_information3 business_group_id, action_information4 legal_employer_id,
                action_information5
                      local_unit_id, action_information6 local_unit_name, action_information7 local_unit_sd_no,
                action_information8
                      address_line_1, action_information9 address_line_2, action_information10 address_line_3,
                action_information11
                      country, action_information12 postal_code, effective_date
           from pay_action_information pai
          where action_context_type = 'PA'
            and action_context_id = p_payroll_action_id
            and action_information_category = 'EMEA REPORT INFORMATION'
            and action_information1 = 'PYFIPSTA'
            -- and action_information6 = 'FI Local Unit1'
            and action_information2 = 'LU_DETAILS';

      rl_local_unit_detail             csr_get_local_unit_details%rowtype;

      cursor cst_get_emp_count (
         p_payroll_action_id   varchar2,
         p_legal_employer      varchar2,
         p_local_unit_id       varchar2
      ) is
         select count (*)
           from pay_payroll_actions paa, pay_assignment_actions assg, pay_action_information pai
          where paa.payroll_action_id = p_payroll_action_id
            and assg.payroll_action_id = paa.payroll_action_id
            and pai.action_context_id = assg.assignment_action_id
            and pai.action_context_type = 'AAP'
            and pai.action_information_category = 'EMEA REPORT INFORMATION'
            and pai.action_information1 = 'PYFIPSTA'
            and action_information2 = 'PERSON DETAILS'
            and pai.action_information20 = p_local_unit_id;

       /* Cursor to fetch Detail Information */
      --
      --
      cursor csr_get_detail_info (
         p_payroll_action_id   number,
         p_local_unit_id       varchar2
      ) is
         select   action_information3 person_id, action_information4 pin, action_information5 emp_name,
                  action_information6
                        employee_number, action_information7 salary_basis, action_information8 tax_card_type,
                  action_information9
                        tax_municipality, action_information10 base_rate, action_information11 additional_rate,
                  action_information12
                        yearly_income_limit, action_information13 actual_tax_days,
                  action_information14 insurance_salary, action_information15 address_line1,
                  action_information16
                        address_line2, action_information17 address_line3, action_information18 postal_code,
                  action_information19
                        country, fnd_date.canonical_to_date (action_information21) date_of_birth,
                  action_information22
                        job_name, action_information23 permanent_address_line1,
                  action_information24 permanent_address_line2, action_information25 permanent_address_line3,
                  action_information26
                        permanent_postal_code, action_information27 permanent_country
             from pay_payroll_actions paa, pay_assignment_actions assg, pay_action_information pai
            where paa.payroll_action_id = p_payroll_action_id
              and assg.payroll_action_id = paa.payroll_action_id
              and pai.action_context_id = assg.assignment_action_id
              and pai.action_context_type = 'AAP'
              and pai.action_information_category = 'EMEA REPORT INFORMATION'
              and action_information1 = 'PYFIPSTA'
              and action_information2 = 'PERSON DETAILS'
              and action_information20 = p_local_unit_id
         --     and action_information3 = to_char(20435)
         order by to_number (person_id);

      cursor csr_get_payroll_detais (
         p_payroll_action_id   number,
         p_person_id           varchar2
      ) is
         select   action_information4 payroll_id, action_information5 pay_period,
                  fnd_date.canonical_to_date (action_information6)
                        pay_period_start_date,
                  fnd_date.canonical_to_date (action_information7) pay_period_end_date, action_information8 period_type,
                  fnd_number.canonical_to_number (action_information9)
                        salary_income,
                  fnd_number.canonical_to_number (action_information10) benefits_in_kind, action_information11 benefit_type,
                  fnd_number.canonical_to_number (action_information12)
                        benefit_monetary_value,
                  fnd_number.canonical_to_number (action_information13) sal_sub_tax,
                  fnd_number.canonical_to_number (action_information14)
                        tax_amount,
                  fnd_number.canonical_to_number (action_information15) net_salary,
                  fnd_number.canonical_to_number (action_information16)
                        deductions_b_tax,
                  fnd_number.canonical_to_number (action_information17) external_compensation,
                  fnd_number.canonical_to_number (action_information18)
                        time_period_id,
                  fnd_number.canonical_to_number (action_information19) pension,
                  fnd_number.canonical_to_number (action_information20)
                        unemployment_insurance,
                  fnd_number.canonical_to_number (action_information21) trade_union_fee,
                  fnd_number.canonical_to_number (action_information22)
                        car_benefit
             from pay_payroll_actions paa, pay_assignment_actions assg, pay_action_information pai
            where paa.payroll_action_id = p_payroll_action_id
              and assg.payroll_action_id = paa.payroll_action_id
              and pai.action_context_id = assg.assignment_action_id
              and pai.action_context_type = 'AAP'
              and pai.action_information_category = 'EMEA REPORT INFORMATION'
              and action_information1 = 'PYFIPSTA'
              and action_information2 = 'Payroll Details'
              and action_information3 = p_person_id
         order by time_period_id asc;

      cursor csr_get_benefits (
         p_payroll_action_id   number,
         p_person_id           varchar2
      ) is
         select   fnd_date.canonical_to_date (action_information6) pay_period_start_date,
                  fnd_date.canonical_to_date (action_information7)
                        pay_period_end_date, action_information11 benefit_type,
                  fnd_number.canonical_to_number (action_information12)
                        benefit_value
             from pay_payroll_actions paa, pay_assignment_actions assg, pay_action_information pai
            where paa.payroll_action_id = p_payroll_action_id
              and assg.payroll_action_id = paa.payroll_action_id
              and pai.action_context_id = assg.assignment_action_id
              and pai.action_context_type = 'AAP'
              and pai.action_information_category = 'EMEA REPORT INFORMATION'
              and action_information1 = 'PYFIPSTA'
              and action_information2 = 'Benefit Details'
              and action_information3 = p_person_id
              and action_information11 is not null
         --group by action_information18,action_information5,action_information6,action_information7,action_information8,action_information11,action_information21
         order by benefit_type; --, to_number(nvl(benefits_in_kind,0)) desc;
      cursor csr_get_car_benefit (
         p_payroll_action_id   number,
         p_person_id           varchar2
      ) is
         select   fnd_date.canonical_to_date (action_information6) car_pay_period_start_date,
                  fnd_date.canonical_to_date (action_information7)
                        car_pay_period_end_date,
                  action_information19 input_value_name, action_information20 input_value,
                  action_information22
                        input_value_uom
             from pay_payroll_actions paa, pay_assignment_actions assg, pay_action_information pai
            where paa.payroll_action_id = p_payroll_action_id
              and assg.payroll_action_id = paa.payroll_action_id
              and pai.action_context_id = assg.assignment_action_id
              and pai.action_context_type = 'AAP'
              and pai.action_information_category = 'EMEA REPORT INFORMATION'
              and action_information1 = 'PYFIPSTA'
              and action_information2 = 'Car Benefit Details'
              and action_information3 = p_person_id
              and action_information19 is not null
         order by car_pay_period_start_date; --, to_number(nvl(benefits_in_kind,0)) desc;
      --      rl_csr_get_payroll_total   csr_get_payroll_total%rowtype;
      l_counter                        number                               := 0;
      l_count                          number                               := 0;
      l_payroll_action_id              number;
      xml_ctr                          number;
      l_report_date                    date;
      l_total_count                    number;
      l_pay_period                     number;
      l_salary_income_total            number;
      l_benefits_in_kind_total         number;
      l_benefit_monetary_value_total   number;
      l_sal_sub_tax_total              number;
      l_tax_amount_total               number;
      l_deductions_b_tax_total         number;
      l_net_salary_total               number;
      l_pension_total                  number;
      l_unemployment_insurance_total   number;
      l_trade_union_fee_total          number;
      l_external_compensation_total    number;
      l_car_benefit_start_date         date;
      l_car_benefit_total              number;
   begin
      if p_payroll_action_id is null then
         begin
            select payroll_action_id
              into l_payroll_action_id
              from pay_payroll_actions ppa, fnd_conc_req_summary_v fcrs, fnd_conc_req_summary_v fcrs1
             where fcrs.request_id = fnd_global.conc_request_id
               and fcrs.priority_request_id = fcrs1.priority_request_id
               and ppa.request_id between fcrs1.request_id and fcrs.request_id
               and ppa.request_id = fcrs1.request_id;
         exception
            when others then
               null;
         end;
      else
         l_payroll_action_id := p_payroll_action_id;
      end if;

      select sysdate
        into l_report_date
        from dual;

      open csr_get_hdr_info (l_payroll_action_id);
      fetch csr_get_hdr_info into rl_hdr_info;
      close csr_get_hdr_info;
      --
      xml_tab (l_counter).tagname := 'LEGAL_EMPLOYER_NAME';
      xml_tab (l_counter).tagvalue := rl_hdr_info.legal_employer_name;
      l_counter := l_counter + 1;
      --
      xml_tab (l_counter).tagname := 'EFFECTIVE_DATE';
      xml_tab (l_counter).tagvalue := rl_hdr_info.effective_date;
      l_counter := l_counter + 1;

      if rl_hdr_info.local_unit_name is not null then
         --
         xml_tab (l_counter).tagname := 'ORG_NAME';
         xml_tab (l_counter).tagvalue := rl_hdr_info.local_unit_name;
         l_counter := l_counter + 1;
      --
      else
         --
         xml_tab (l_counter).tagname := 'ORG_NAME';
         xml_tab (l_counter).tagvalue := rl_hdr_info.legal_employer_name;
         l_counter := l_counter + 1;
      --
      end if;

      --
      xml_tab (l_counter).tagname := 'YEAR';
      xml_tab (l_counter).tagvalue := rl_hdr_info.year;
      l_counter := l_counter + 1;
      --
      xml_tab (l_counter).tagname := 'REPORT_DATE';
      xml_tab (l_counter).tagvalue := l_report_date;
      l_counter := l_counter + 1;
      --
      xml_tab (l_counter).tagname := 'LOCAL_UNIT_NAME';
      xml_tab (l_counter).tagvalue := rl_hdr_info.local_unit_name;
      l_counter := l_counter + 1;

      --
      for l_get_local_unit_detail in csr_get_local_unit_details (l_payroll_action_id)
      loop
         l_total_count := 0;
         open cst_get_emp_count (l_payroll_action_id, rl_hdr_info.legal_employer_id, l_get_local_unit_detail.local_unit_id);
         fetch cst_get_emp_count into l_total_count;
         close cst_get_emp_count;

         if l_total_count > 0 then
            xml_tab (l_counter).tagname := 'LU_NAME';
            xml_tab (l_counter).tagvalue := l_get_local_unit_detail.local_unit_name;
            l_counter := l_counter + 1;
            --
            xml_tab (l_counter).tagname := 'LEGAL_EMP_NAME';
            xml_tab (l_counter).tagvalue := rl_hdr_info.legal_employer_name;
            l_counter := l_counter + 1;
            --
            xml_tab (l_counter).tagname := 'ORG_ADD_LINE1';
            xml_tab (l_counter).tagvalue := l_get_local_unit_detail.address_line_1;
            l_counter := l_counter + 1;
            --
            xml_tab (l_counter).tagname := 'ORG_ADD_LINE2';
            xml_tab (l_counter).tagvalue := l_get_local_unit_detail.address_line_2;
            l_counter := l_counter + 1;
            --
            xml_tab (l_counter).tagname := 'ORG_ADD_LINE3';
            xml_tab (l_counter).tagvalue := l_get_local_unit_detail.address_line_3;
            l_counter := l_counter + 1;
            --
            xml_tab (l_counter).tagname := 'ORG_POSTAL_CODE';
            xml_tab (l_counter).tagvalue := l_get_local_unit_detail.postal_code;
            l_counter := l_counter + 1;
            --
            xml_tab (l_counter).tagname := 'ORG_COUNTRY';
            xml_tab (l_counter).tagvalue := l_get_local_unit_detail.country;
            l_counter := l_counter + 1;

            for i in csr_get_detail_info (l_payroll_action_id, l_get_local_unit_detail.local_unit_id)
            loop
               xml_tab (l_counter).tagname := 'EMPLOYEE_NUMBER';
               xml_tab (l_counter).tagvalue := i.employee_number;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'EMP_PIN';
               xml_tab (l_counter).tagvalue := i.pin;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'FULL_NAME';
               xml_tab (l_counter).tagvalue := i.emp_name;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'DATE_OF_BIRTH';
               xml_tab (l_counter).tagvalue := i.date_of_birth;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'JOB';
               xml_tab (l_counter).tagvalue := i.job_name;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'SALARY_BASIS';
               xml_tab (l_counter).tagvalue := i.salary_basis;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'TAX_CARD_TYPE';
               xml_tab (l_counter).tagvalue := i.tax_card_type;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'TAX_MUNICIPALITY';
               xml_tab (l_counter).tagvalue := i.tax_municipality;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'BASE_RATE';
               xml_tab (l_counter).tagvalue := i.base_rate;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'ADDITIONAL_RATE';
               xml_tab (l_counter).tagvalue := i.additional_rate;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'ADDITIONAL_RATE';
               xml_tab (l_counter).tagvalue := i.additional_rate;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'YEARLY_INCOME_LIMIT';
               xml_tab (l_counter).tagvalue := i.yearly_income_limit;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'ACTUAL_TAX_DAYS';
               xml_tab (l_counter).tagvalue := i.actual_tax_days;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'INSURANCE_SALARY';
               xml_tab (l_counter).tagvalue := i.insurance_salary;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'PER_ADDRESS_LINE1';
               xml_tab (l_counter).tagvalue := i.permanent_address_line1;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'PER_ADDRESS_LINE2';
               xml_tab (l_counter).tagvalue := i.permanent_address_line2;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'PER_ADDRESS_LINE3';
               xml_tab (l_counter).tagvalue := i.permanent_address_line3;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'PER_COUNTRY_CODE';
               xml_tab (l_counter).tagvalue := i.permanent_country;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'PER_POSTAL_CODE';
               xml_tab (l_counter).tagvalue := i.permanent_postal_code;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'ADDRESS_LINE1';
               xml_tab (l_counter).tagvalue := i.address_line1;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'ADDRESS_LINE2';
               xml_tab (l_counter).tagvalue := i.address_line2;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'ADDRESS_LINE3';
               xml_tab (l_counter).tagvalue := i.address_line3;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'COUNTRY_CODE';
               xml_tab (l_counter).tagvalue := i.country;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'POSTAL_CODE';
               xml_tab (l_counter).tagvalue := i.postal_code;
               l_counter := l_counter + 1;
               l_salary_income_total := 0;
               l_benefits_in_kind_total := 0;
               l_benefit_monetary_value_total := 0;
               l_sal_sub_tax_total := 0;
               l_tax_amount_total := 0;
               l_deductions_b_tax_total := 0;
               l_net_salary_total := 0;
               l_pension_total := 0;
               l_unemployment_insurance_total := 0;
               l_trade_union_fee_total := 0;
               l_external_compensation_total := 0;
               l_car_benefit_total := 0;

               for j in csr_get_payroll_detais (l_payroll_action_id, i.person_id)
               loop
                  xml_tab (l_counter).tagname := 'PAY_PERIOD';
                  xml_tab (l_counter).tagvalue := j.pay_period;
                  l_counter := l_counter + 1;

--
                  xml_tab (l_counter).tagname := 'PAY_PERIOD_START_DATE';
                  xml_tab (l_counter).tagvalue := j.pay_period_start_date;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'PAY_PERIOD_END_DATE';
                  xml_tab (l_counter).tagvalue := j.pay_period_end_date;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'SALARY_INCOME';
                  xml_tab (l_counter).tagvalue := j.salary_income;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'BENEFITS_IN_KIND';
                  xml_tab (l_counter).tagvalue := j.benefits_in_kind;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'CAR_BENFIT';
                  xml_tab (l_counter).tagvalue := j.car_benefit;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'BENEFIT_TYPE';
                  xml_tab (l_counter).tagvalue := j.benefit_type;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'DEDUCTIONS_B_TAX';
                  xml_tab (l_counter).tagvalue := j.deductions_b_tax;
                  l_counter := l_counter + 1;
                            --
                  /* Standard Deductions */
                  xml_tab (l_counter).tagname := 'PENSION';
                  xml_tab (l_counter).tagvalue := j.pension;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'UNEMP_INSURANCE';
                  xml_tab (l_counter).tagvalue := j.unemployment_insurance;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'TRADE_UNION_FEE';
                  xml_tab (l_counter).tagvalue := j.trade_union_fee;
                  l_counter := l_counter + 1;
                            --
                  /* End of Standard Deductions */
                  xml_tab (l_counter).tagname := 'EXTERNAL_COMPENSATION';
                  xml_tab (l_counter).tagvalue := j.external_compensation;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'BENEFIT_MONETARY_VALUE';
                  xml_tab (l_counter).tagvalue := j.benefit_monetary_value;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'SAL_SUBJECT_TAX';
                  xml_tab (l_counter).tagvalue := j.sal_sub_tax;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'TAX_AMOUNT';
                  xml_tab (l_counter).tagvalue := j.tax_amount;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'NET_SALARY';
                  xml_tab (l_counter).tagvalue := j.net_salary;
                  l_counter := l_counter + 1;
                  l_salary_income_total := l_salary_income_total + j.salary_income;
                  l_benefits_in_kind_total := l_benefits_in_kind_total + j.benefits_in_kind;
                  -- l_benefit_monetary_value_total    :=0;
                  l_sal_sub_tax_total := l_sal_sub_tax_total + j.sal_sub_tax;
                  l_tax_amount_total := l_tax_amount_total + j.tax_amount;
                  l_deductions_b_tax_total := l_deductions_b_tax_total + j.deductions_b_tax;
                  l_net_salary_total := l_net_salary_total + j.net_salary;
                  l_pension_total := l_pension_total + j.pension;
                  l_unemployment_insurance_total := l_unemployment_insurance_total + j.unemployment_insurance;
                  l_trade_union_fee_total := l_trade_union_fee_total + j.trade_union_fee;
                  l_external_compensation_total := l_external_compensation_total + j.external_compensation;
                  l_car_benefit_total := l_car_benefit_total + j.car_benefit;
               end loop;

               --
               xml_tab (l_counter).tagname := 'SALARY_INCOME_TOTAL';
               xml_tab (l_counter).tagvalue := l_salary_income_total;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'BENEFITS_IN_KIND_TOTAL';
               xml_tab (l_counter).tagvalue := l_benefits_in_kind_total;
               l_counter := l_counter + 1;
               xml_tab (l_counter).tagname := 'CAR_BENEFIT_TOTAL';
               xml_tab (l_counter).tagvalue := l_car_benefit_total;
               l_counter := l_counter + 1;
                   --
               /*    xml_tab (l_counter).tagname := 'BENEFIT_MONETARY_VALUE_TOTAL';
               xml_tab (l_counter).tagvalue :=
                         rl_csr_get_payroll_total.benefit_monetary_value_total;
               l_counter := l_counter + 1;*/
                   --
               xml_tab (l_counter).tagname := 'SAL_SUB_TAX_TOTAL';
               xml_tab (l_counter).tagvalue := l_sal_sub_tax_total;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'TAX_AMOUNT_TOTAL';
               xml_tab (l_counter).tagvalue := l_tax_amount_total;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'DEDUCTIONS_B_TAX_TOTAL';
               xml_tab (l_counter).tagvalue := l_deductions_b_tax_total;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'NET_SALARY_TOTAL';
               xml_tab (l_counter).tagvalue := l_net_salary_total;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'PENSION_TOTAL';
               xml_tab (l_counter).tagvalue := l_pension_total;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'UNEMPLOYMENT_INSURANCE_TOTAL';
               xml_tab (l_counter).tagvalue := l_unemployment_insurance_total;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'TRADE_UNION_FEE_TOTAL';
               xml_tab (l_counter).tagvalue := l_trade_union_fee_total;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'EXTERNAL_COMPENSATION_TOTAL';
               xml_tab (l_counter).tagvalue := l_external_compensation_total;
               l_counter := l_counter + 1;

               for l_get_benefit in csr_get_benefits (l_payroll_action_id, i.person_id)
               loop -- Start Loop for Benefits
                  xml_tab (l_counter).tagname := 'BENEFIT_NAME';
                  xml_tab (l_counter).tagvalue := l_get_benefit.benefit_type;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'BENEFIT_PAY_PERIOD_START_DATE';
                  xml_tab (l_counter).tagvalue := l_get_benefit.pay_period_start_date;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'BENEFIT_PAY_PERIOD_END_DATE';
                  xml_tab (l_counter).tagvalue := l_get_benefit.pay_period_end_date;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'BENEFIT_VALUE';
                  xml_tab (l_counter).tagvalue := l_get_benefit.benefit_value;
                  l_counter := l_counter + 1;
--
               end loop; --End loop for benefits
               -- Start Loop for Car Benefit
               l_car_benefit_start_date := null;

               for l_car_benefit in csr_get_car_benefit (l_payroll_action_id, i.person_id)
               loop
                  if l_car_benefit_start_date is null or l_car_benefit_start_date <> l_car_benefit.car_pay_period_start_date then
                     xml_tab (l_counter).tagname := 'CAR_PAY_PERIOD_START_DATE';
                     xml_tab (l_counter).tagvalue := l_car_benefit.car_pay_period_start_date;
                     l_counter := l_counter + 1;
                     --
                     xml_tab (l_counter).tagname := 'CAR_PAY_PERIOD_END_DATE';
                     xml_tab (l_counter).tagvalue := l_car_benefit.car_pay_period_end_date;
                     l_counter := l_counter + 1;
                     l_car_benefit_start_date := l_car_benefit.car_pay_period_start_date;
                  --
                  end if;

                  xml_tab (l_counter).tagname := 'INPUT_VALUE_NAME';
                  xml_tab (l_counter).tagvalue := l_car_benefit.input_value_name;
                  l_counter := l_counter + 1;
                  --
                  --
                  xml_tab (l_counter).tagname := 'UOM';
                  xml_tab (l_counter).tagvalue := l_car_benefit.input_value_uom;
                  l_counter := l_counter + 1;
                  --
                  --
                  xml_tab (l_counter).tagname := 'INPUT_VALUE';
                  xml_tab (l_counter).tagvalue := l_car_benefit.input_value;
                  l_counter := l_counter + 1;
               end loop;
            end loop;
         end if;
      end loop;

      writetoclob (p_xml);
   exception
      when others then
         fnd_file.put_line (fnd_file.log, 'Inside Exception');
         fnd_file.put_line (fnd_file.log, 'Error is - ' || sqlcode);
   end;

   procedure writetoclob (
      p_xfdf_clob   out nocopy   clob
   ) is
      l_xfdf_string    clob;
      l_str1           varchar2 (1000);
      l_str2           varchar2 (20);
      l_str3           varchar2 (20);
      l_str4           varchar2 (20);
      l_str5           varchar2 (20);
      l_str6           varchar2 (30);
      l_str7           varchar2 (1000);
      l_str8           varchar2 (240);
      l_str9           varchar2 (240);
      l_str10          varchar2 (20);
      l_str11          varchar2 (20);
      l_str12          varchar2 (30);
      l_str13          varchar2 (30);
      l_str14          varchar2 (30);
      l_str15          varchar2 (30);
      l_str16          varchar2 (30);
      l_str17          varchar2 (30);
      l_str18          varchar2 (50);
      l_str19          varchar2 (30);
      l_str20          varchar2 (50);
      l_str21          varchar2 (30);
      l_str22          varchar2 (50);
      l_str23          varchar2 (30);
      l_str24          varchar2 (30);
      l_str25          varchar2 (30);
      l_str26          varchar2 (30);
      l_str27          varchar2 (30);
      l_str28          varchar2 (30);
      l_str29          varchar2 (30);
      l_str30          varchar2 (30);
      l_str31          varchar2 (30);
      l_iana_charset   varchar2 (30);
      current_index    pls_integer;
   begin
      --  hr_utility.set_location ('Entering WritetoCLOB ', 10);
      l_iana_charset := hr_fi_utility.get_iana_charset;
      l_str1 := '<?xml version="1.0" encoding="' || l_iana_charset || '"?> <ROOT><PAACR>';
      l_str2 := '<';
      l_str3 := '>';
      l_str4 := '</';
      l_str5 := '>';
      l_str6 := '</PAACR></ROOT>';
      l_str7 := '<?xml version="1.0" encoding="' || l_iana_charset || '"?> <ROOT></ROOT>';
      l_str10 := '<PAACR>';
      l_str11 := '</PAACR>';
      l_str12 := '<FILE_HEADER_START>';
      l_str13 := '</FILE_HEADER_START>';
      l_str14 := '<LE_RECORD>';
      l_str15 := '</LE_RECORD>';
      l_str16 := '<EMP_RECORD>';
      l_str17 := '</EMP_RECORD>';
      l_str18 := '<PAY_RECORD>';
      l_str19 := '</PAY_RECORD>';
      l_str20 := '<PAY_TOTAL_RECORD>';
      l_str21 := '</PAY_TOTAL_RECORD>';
      l_str22 := '<LU_DETAIL>';
      l_str23 := '</LU_DETAIL>';
      l_str24 := '<BENEFIT_TYPE_INFO>';
      l_str25 := '</BENEFIT_TYPE_INFO>';
      l_str26 := '<BENEFIT_DETAIL>';
      l_str27 := '</BENEFIT_DETAIL>';
      l_str28 := '<CAR_BEN_PAY_PERIOD>';
      l_str29 := '</CAR_BEN_PAY_PERIOD>';
      dbms_lob.createtemporary (l_xfdf_string, false , dbms_lob.call);
      dbms_lob.open (l_xfdf_string, dbms_lob.lob_readwrite);
      current_index := 0;

      if xml_tab.count > 0 then
         dbms_lob.writeappend (l_xfdf_string, length (l_str1), l_str1);
         dbms_lob.writeappend (l_xfdf_string, length (l_str12), l_str12);

         for table_counter in xml_tab.first .. xml_tab.last
         loop
            l_str8 := xml_tab (table_counter).tagname;
            l_str9 := xml_tab (table_counter).tagvalue;

            if l_str8 = 'LEGAL_EMPLOYER_NAME' then
               dbms_lob.writeappend (l_xfdf_string, length (l_str14), l_str14);
            elsif l_str8 = 'LU_NAME' then
               dbms_lob.writeappend (l_xfdf_string, length (l_str22), l_str22);
            elsif l_str8 = 'EMPLOYEE_NUMBER' then
               dbms_lob.writeappend (l_xfdf_string, length (l_str16), l_str16);
            elsif l_str8 = 'SALARY_INCOME_TOTAL' then
               dbms_lob.writeappend (l_xfdf_string, length (l_str20), l_str20);
            elsif l_str8 = 'PAY_PERIOD' then
               dbms_lob.writeappend (l_xfdf_string, length (l_str18), l_str18);
            elsif l_str8 = 'BENEFIT_NAME' then
               dbms_lob.writeappend (l_xfdf_string, length (l_str24), l_str24);
            elsif l_str8 = 'CAR_PAY_PERIOD_START_DATE' then
               dbms_lob.writeappend (l_xfdf_string, length (l_str28), l_str28);
            elsif l_str8 = 'INPUT_VALUE_NAME' then
               dbms_lob.writeappend (l_xfdf_string, length (l_str26), l_str26);
            end if;

            if l_str9 is not null then
               l_str9 := '<![CDATA[' || l_str9 || ']]>';
               dbms_lob.writeappend (l_xfdf_string, length (l_str2), l_str2);
               dbms_lob.writeappend (l_xfdf_string, length (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, length (l_str3), l_str3);
               dbms_lob.writeappend (l_xfdf_string, length (l_str9), l_str9);
               dbms_lob.writeappend (l_xfdf_string, length (l_str4), l_str4);
               dbms_lob.writeappend (l_xfdf_string, length (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, length (l_str5), l_str5);
            else
               dbms_lob.writeappend (l_xfdf_string, length (l_str2), l_str2);
               dbms_lob.writeappend (l_xfdf_string, length (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, length (l_str3), l_str3);
               dbms_lob.writeappend (l_xfdf_string, length (l_str4), l_str4);
               dbms_lob.writeappend (l_xfdf_string, length (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, length (l_str5), l_str5);
            end if;

            if l_str8 = 'LOCAL_UNIT_NAME' then
               dbms_lob.writeappend (l_xfdf_string, length (l_str15), l_str15);
            end if;

            if l_str8 = 'NET_SALARY' then
               dbms_lob.writeappend (l_xfdf_string, length (l_str19), l_str19);
            elsif l_str8 = 'EXTERNAL_COMPENSATION_TOTAL' then
               /* if    xml_tab.last = table_counter
            or xml_tab (table_counter + 1).tagname <> 'PAY_PERIOD' then
            dbms_lob.writeappend (
               l_xfdf_string,
               length (l_str17),
               l_str17
            );
         end if;*/
               dbms_lob.writeappend (l_xfdf_string, length (l_str21), l_str21);

               if xml_tab.last = table_counter then
                  dbms_lob.writeappend (l_xfdf_string, length (l_str17), l_str17);
                  dbms_lob.writeappend (l_xfdf_string, length (l_str23), l_str23);
               elsif xml_tab (table_counter + 1).tagname <> 'BENEFIT_NAME' then
                  dbms_lob.writeappend (l_xfdf_string, length (l_str17), l_str17);

                  if xml_tab (table_counter + 1).tagname <> 'EMPLOYEE_NUMBER' then
                     dbms_lob.writeappend (l_xfdf_string, length (l_str23), l_str23);
                  end if;
               /*    dbms_lob.writeappend (
                          l_xfdf_string,
                          length (l_str23),
                          l_str23
                       );*/
               end if;
            elsif l_str8 = 'BENEFIT_VALUE' then
               dbms_lob.writeappend (l_xfdf_string, length (l_str25), l_str25);

               if xml_tab.last = table_counter then
                  dbms_lob.writeappend (l_xfdf_string, length (l_str17), l_str17);
                  dbms_lob.writeappend (l_xfdf_string, length (l_str23), l_str23);
               elsif xml_tab (table_counter + 1).tagname not in ('BENEFIT_NAME', 'CAR_PAY_PERIOD_START_DATE') then --'EMPLOYEE_NUMBER' then
                  dbms_lob.writeappend (l_xfdf_string, length (l_str17), l_str17);
		  if xml_tab (table_counter + 1).tagname = 'LU_NAME' then
		     dbms_lob.writeappend (l_xfdf_string, length (l_str23), l_str23);
		  end if;
               end if;
            elsif l_str8 = 'INPUT_VALUE' then
               dbms_lob.writeappend (l_xfdf_string, length (l_str27), l_str27);

               if xml_tab.last = table_counter then
                  dbms_lob.writeappend (l_xfdf_string, length (l_str29), l_str29);
                  dbms_lob.writeappend (l_xfdf_string, length (l_str17), l_str17);
                  dbms_lob.writeappend (l_xfdf_string, length (l_str23), l_str23);
               elsif xml_tab (table_counter + 1).tagname = 'CAR_PAY_PERIOD_START_DATE' then
                  /*  dbms_lob.writeappend (
                     l_xfdf_string,
                     length (l_str25),
                     l_str25
                  );*/
                  dbms_lob.writeappend (l_xfdf_string, length (l_str29), l_str29);
               elsif xml_tab (table_counter + 1).tagname not in ('INPUT_VALUE_NAME', 'CAR_PAY_PERIOD_START_DATE') then --'EMPLOYEE_NUMBER' then
                  dbms_lob.writeappend (l_xfdf_string, length (l_str29), l_str29);
                  dbms_lob.writeappend (l_xfdf_string, length (l_str17), l_str17);
		  if xml_tab (table_counter + 1).tagname = 'LU_NAME' then
		     dbms_lob.writeappend (l_xfdf_string, length (l_str23), l_str23);
		  end if;
               end if;
            end if;
         end loop;

         dbms_lob.writeappend (l_xfdf_string, length (l_str13), l_str13);
         dbms_lob.writeappend (l_xfdf_string, length (l_str6), l_str6);
      else
         dbms_lob.writeappend (l_xfdf_string, length (l_str7), l_str7);
      end if;

      p_xfdf_clob := l_xfdf_string;
      hr_utility.set_location ('Leaving WritetoCLOB ', 20);
      fnd_file.put_line (fnd_file.log, 'XML Part');
   end writetoclob;
end pay_fi_pstr;

/
