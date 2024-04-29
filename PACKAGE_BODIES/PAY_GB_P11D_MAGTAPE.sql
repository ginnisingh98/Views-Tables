--------------------------------------------------------
--  DDL for Package Body PAY_GB_P11D_MAGTAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_P11D_MAGTAPE" as
/* $Header: pygbpdtp.pkb 120.4.12000000.2 2007/04/05 10:24:24 kthampan noship $ */
/*===========================================================================+
|               Copyright (c) 1993 Oracle Corporation                       |
|                  Redwood Shores, California, USA                          |
|                       All rights reserved.                                |
+============================================================================
 Name
    PAY_GB_P11D_MAGTAPE
  Purpose

    This is a UK Specific payroll package.
  Notes

  History
==============================================================================*/
--
-- Globals
   g_package   CONSTANT VARCHAR2(20) := 'pay_gb_p11d_magtape.';

--
   function get_parameters (p_payroll_action_id in number,
                            p_token_name        in varchar2,
                            p_tax_ref           in varchar2 default null)return varchar2
   is
      cursor csr_parameter_info(p_pact_id   number,
                                p_token     char)
      is
      select substr(legislative_parameters,
                    instr(legislative_parameters, p_token) + (length (p_token) + 1),
                    (decode(instr (legislative_parameters, ' ', instr (legislative_parameters, p_token)),
                    0, decode (instr (legislative_parameters, p_token),0, .5,length (legislative_parameters)),
                    instr (legislative_parameters, ' ', instr (legislative_parameters, p_token)) -
                    (instr (legislative_parameters, p_token) + (length (p_token) + 1))))),
             business_group_id,
             request_id,
             start_date,
             effective_date   -- this will be the benefit end date
      from pay_payroll_actions
      where payroll_action_id = p_pact_id;

      cursor csr_org_info(p_business_group_id number,
                          p_tax_ref           varchar2)
      is
      select org.org_information11,
             substr(org.org_information3,1,36),
             org.org_information13
      from   hr_organization_information org
      where  org.organization_id = p_business_group_id
      and    upper(org.org_information1) = upper(p_tax_ref)
      and    org.org_information_context = 'Tax Details References';

      cursor csr_count_taxref(p_pact_id number)
      is
      select count(*),
             action_information6
      from   pay_assignment_actions paa,
             pay_action_information pai
      where  paa.payroll_action_id = p_pact_id
      and    pai.action_context_id = paa.assignment_action_id
      and    pai.action_information_category = 'EMEA PAYROLL INFO'
      and    pai.action_context_type = 'AAP'
      group by action_information6;

      l_business_group_id    VARCHAR2(20);
      l_benefit_start_date   VARCHAR2(20);
      l_benefit_end_date     VARCHAR2(20);
      l_party_name           VARCHAR2(36);
      l_request_id           VARCHAR2(50);
      l_sender_id            VARCHAR2(50);
      l_submitter_id         VARCHAR2(50);
      l_token_value          VARCHAR2(50);
      l_proc                 VARCHAR2(50) := g_package || 'get_parameters';
      l_tax_ref              VARCHAR2(50);
      l_count                NUMBER;
   begin
      hr_utility.set_location ('Entering ' || l_proc, 10);
      hr_utility.set_location ('Step ' || l_proc, 20);
      hr_utility.set_location ('p_token_name = ' || p_token_name, 20);
      open csr_parameter_info (p_payroll_action_id, p_token_name);
      fetch csr_parameter_info into l_token_value,
                                    l_business_group_id,
                                    l_request_id,
                                    l_benefit_start_date,
                                    l_benefit_end_date;
      close csr_parameter_info;

      if p_token_name = 'BG_ID'
      then
         l_token_value := l_business_group_id;
      elsif p_token_name = 'REQUEST_ID'
      then
         l_token_value := l_request_id;
      elsif p_token_name = 'SENDER_ID' or p_token_name = 'PARTY_NAME' or p_token_name = 'SUBMITTER_REF_NO'
      then
         open csr_count_taxref(p_payroll_action_id);
         loop
             fetch csr_count_taxref into  l_count, l_tax_ref;
             exit when csr_count_taxref%notfound;
         end loop;
         l_count := csr_count_taxref%rowcount;
         close csr_count_taxref;

         if l_count = 1 then
             open  csr_org_info(l_business_group_id,l_tax_ref);
             fetch csr_org_info into l_sender_id,
                                     l_party_name,
                                     l_submitter_id;
             close csr_org_info;
         else
             open  csr_org_info(l_business_group_id,nvl(p_tax_ref,l_tax_ref));
             fetch csr_org_info into l_sender_id,
                                     l_party_name,
                                     l_submitter_id;
             close csr_org_info;
         end if;
         if p_token_name = 'SENDER_ID'
         then
           l_token_value := l_sender_id;
         elsif p_token_name = 'PARTY_NAME'
         then
           l_token_value := l_party_name;
         elsif p_token_name = 'SUBMITTER_REF_NO'
         then
           l_token_value := l_submitter_id;
         end if;
      elsif p_token_name = 'BENEFIT_START_DATE'
      then
         l_token_value := fnd_date.date_to_canonical (l_benefit_start_date);
      elsif p_token_name = 'BENEFIT_END_DATE'
      then
        l_token_value := fnd_date.date_to_canonical (l_benefit_end_date);
      else
         l_token_value := l_token_value;
      end if;

      hr_utility.set_location ('l_token_value = ' || l_token_value, 60);
      hr_utility.set_location ('Leaving         ' || l_proc, 70);
      return l_token_value;
   end get_parameters;

   PROCEDURE range_cursor (
      pactid   IN       NUMBER,
      sqlstr   OUT   NOCOPY VARCHAR2
   )
   IS
      l_proc   CONSTANT VARCHAR2(35) := g_package || 'range_cursor';
   BEGIN
      --
      hr_utility.set_location ('Entering: ' || l_proc, 1);
      --
      -- Note: There must be one and only one entry of :payroll_action_id in
      -- the string, and the statement must be, order by person_id
      --
      sqlstr := 'SELECT DISTINCT person_id
             FROM   per_people_f ppf,
                    pay_payroll_actions ppa
             WHERE  ppa.payroll_action_id = :payroll_action_id
             AND    ppa.business_group_id +0= ppf.business_group_id
             ORDER BY ppf.person_id';

      hr_utility.set_location ('Leaving ' || l_proc, 20);
      --
  END range_cursor;

--
--
--
   PROCEDURE action_creation (
      pactid      IN   NUMBER,
      stperson    IN   NUMBER,
      endperson   IN   NUMBER,
      chunk       IN   NUMBER
   )
   IS
--
      CURSOR csr_assignments (
         v_archive_payroll_action_id   NUMBER,
         v_tax_ref                     VARCHAR2
      )
      is
        select /*+ ordered
                  use_nl(paa,pai_person)
                  use_index(pai_person,pay_action_information_n2) */
               distinct paa.assignment_id
        from   pay_assignment_actions paa,
               pay_action_information pai_person,
               pay_action_information pai_emp
        where  paa.payroll_action_id = v_archive_payroll_action_id
        and    pai_person.action_context_id = paa.assignment_action_id
        and    pai_person.action_information_category = 'ADDRESS DETAILS'
        and    pai_person.action_information14 = 'Employee Address'
        and    pai_person.action_information1 between stperson and endperson
        and    pai_person.action_context_type = 'AAP'
        and    pai_emp.action_context_id = paa.assignment_action_id
        and    pai_emp.action_context_type = 'AAP'
        and    pai_emp.action_information_category = 'EMEA PAYROLL INFO'
        and    (v_tax_ref is null
                or
                pai_emp.action_information6 = v_tax_ref)
        order by paa.assignment_id;

--
      l_ass_act_id               pay_assignment_actions.assignment_action_id%TYPE;
      l_proc                     CONSTANT VARCHAR2(35) := g_package || 'action_creation';
      l_arch_payroll_action_id   pay_payroll_actions.payroll_action_id%TYPE;
      l_tax_ref                  varchar2(30);
   BEGIN
--
      hr_utility.set_location ('Entering: ' || l_proc, 1);
--
      l_arch_payroll_action_id := get_parameters (pactid, 'ARCH_PAYROLL_ACTION_ID');
      l_tax_ref := get_parameters (pactid, 'TAX_REFERENCE');

      hr_utility.set_location ('arch pay action id ' || l_arch_payroll_action_id, 1);

--
      FOR asgrec IN csr_assignments (l_arch_payroll_action_id,l_tax_ref)
      LOOP
         --
         -- Create the assignment_action to represent the preson / tax unit combination
         --
         SELECT pay_assignment_actions_s.nextval
           INTO l_ass_act_id
           FROM dual;
         --
         -- insert into pay_assignment_actions.
         hr_utility.set_location ('assignment id ' || asgrec.assignment_id, 1);

         hr_nonrun_asact.insact (l_ass_act_id, asgrec.assignment_id, pactid, chunk, NULL);

      END LOOP;

--
      hr_utility.set_location (' Leaving: ' || l_proc, 100);
--
--    hr_utility.trace_off;

   END action_creation;
--
--

  Function format_edi_currency (
     l_input_value varchar2
     )
  return varchar2
  is
  l_output_value       varchar2(36);
  l_input_value_number number;
  begin
     l_input_value_number := to_number(l_input_value);
     l_input_value_number := l_input_value_number * 100;
     if sign(l_input_value_number) = -1
     then
       l_input_value_number := l_input_value_number * -1;
       l_output_value := '-' || lpad(to_char(l_input_value_number),34,'0');
     else
       l_output_value := lpad(to_char(l_input_value_number),35,'0');
     end if;
     l_output_value := l_output_value || ' ';
     return l_output_value;

   Exception
    when others then
    fnd_file.put_line (fnd_file.LOG, 'Error: ' || sqlerrm);
    fnd_file.put_line (fnd_file.LOG, 'input_value ' ||l_input_value );

    fnd_message.raise_error;
 end;

   Function round_and_pad (
      l_input_value varchar2,
      l_cut_to_size number
      )
   return varchar2
   is
   l_output_value varchar2(10);
   l_input_value_number number;
   begin
      l_input_value_number := to_number(l_input_value);
      select
      decode(sign(l_input_value),
            1,lpad(trunc(l_input_value),l_cut_to_size,0),
            0,lpad(trunc(l_input_value),l_cut_to_size,0),
            -1,'-' || lpad(trunc(abs(l_input_value)),l_cut_to_size-1,0)
            ) into l_output_value
      from dual;
      return l_output_value;
   Exception
    when others then
    fnd_file.put_line (fnd_file.LOG, 'Error: ' || sqlerrm);
    fnd_file.put_line (fnd_file.LOG, 'input_value ' ||l_input_value );
    fnd_file.put_line (fnd_file.LOG, 'cut to size ' ||l_cut_to_size);

    fnd_message.raise_error;
   end;

   Function get_description (
      l_lookup_code varchar2,
      l_lookup_type varchar2,
      l_effective_date varchar2
      )
   return varchar2
   is
   l_description fnd_lookup_values.DESCRIPTION%type;
   begin
/*        select upper(description) into l_description
        from fnd_lookup_values flv
        where flv.lookup_type = l_lookup_type
        and flv.lookup_code = l_lookup_code
        and flv.ENABLED_FLAG = 'Y'
        and fnd_date.canonical_to_date(l_effective_date) between
            nvl(flv.START_DATE_ACTIVE,
                fnd_date.canonical_to_date(l_effective_date)) and
            nvl(flv.END_DATE_ACTIVE,
            fnd_date.canonical_to_date(l_effective_date));*/
/*Bug No. 3237648*/
/*Fetching from hr_lookups instead of fnd_lookup_values*/
        select upper(description) into l_description
        from hr_lookups hlu
        where hlu.lookup_type = l_lookup_type
        and hlu.lookup_code = l_lookup_code
        and hlu.ENABLED_FLAG = 'Y'
        and fnd_date.canonical_to_date(l_effective_date) between
            nvl(hlu.START_DATE_ACTIVE,
                fnd_date.canonical_to_date(l_effective_date)) and
            nvl(hlu.END_DATE_ACTIVE,
            fnd_date.canonical_to_date(l_effective_date));

        return l_description;
   exception
        when Others then
            fnd_file.put_line (fnd_file.LOG, 'Error: ' || sqlerrm);
            fnd_file.put_line (fnd_file.LOG, 'effective date ' ||l_effective_date );
            fnd_file.put_line (fnd_file.LOG, 'lookup_type ' ||l_lookup_type );
            fnd_file.put_line (fnd_file.LOG, 'lookup_code ' ||l_lookup_code );

            fnd_message.raise_error;
   end;
END;   -- Package Body PAY_GB_P11D_MAGTAPE

/
