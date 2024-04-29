--------------------------------------------------------
--  DDL for Package PAY_GB_P11D_EDI_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_P11D_EDI_CONTROL" AUTHID CURRENT_USER AS
/* $Header: pygbp11dc.pkh 120.13.12010000.3 2010/02/22 11:48:47 krreddy ship $ */

  level_cnt     NUMBER; -- required by the generic magtape procedure.

  function  fetch_total_benefit(p_assact_id     in  number,
                                p_pact_id       in  number,
                                p_employer_ref  in  varchar2) return number;

  -- CURSOR --
  cursor csr_p11d_header is
  select 'TAX_YEAR=P',pay_gb_p11d_magtape.get_parameters(
                      pay_magtape_generic.get_parameter_value('ARCH_PAYROLL_ACTION_ID'),'Rep_Run'),
         'TEST_SUBMISSION=P',pay_magtape_generic.get_parameter_value('TEST_SUBMISSION'),
         'TRANSMISSION_DATE=P',to_char(sysdate,'YYYYMMDDHHMMSS'),
         'PAYROLL_ACTION_ID=P',pay_magtape_generic.get_parameter_value('ARCH_PAYROLL_ACTION_ID')
  from dual;

  cursor csr_p11d_employer is
  select 'TAX_OFFICE_NAME=P',     NVL(UPPER(action_information4), ' '),
         'TAX_OFFICE_PHONE_NO=P', NVL(UPPER(action_information5), ' '),
         'EMPLOYERS_REF_NO=P',    NVL(UPPER(action_information6), ' '),
         'EMPLOYERS_NAME=P',      NVL(UPPER(action_information7), ' '),
         'EMPLOYERS_ADDRESS=P',   NVL(UPPER(action_information8), ' '),
         'MESSAGE_DATE=P',        to_char(sysdate,'YYYYMMDD'),
         'PARTY_NAME=P',          pay_gb_p11d_magtape.get_parameters(
                                  pay_magtape_generic.get_parameter_value('ARCH_PAYROLL_ACTION_ID'),
                                  'PARTY_NAME',action_information6),
         'SENDER_ID=P',           pay_gb_p11d_magtape.get_parameters(
                                  pay_magtape_generic.get_parameter_value('ARCH_PAYROLL_ACTION_ID'),'SENDER_ID',
                                  action_information6),
         'UNIQUE_REFERENCE=P',    to_number(pay_gb_p11d_magtape.get_parameters(
                                  pay_magtape_generic.get_parameter_value('ARCH_PAYROLL_ACTION_ID'),'REQUEST_ID')),
         'SUBMITTER_REF_NO=P',    pay_gb_p11d_magtape.get_parameters(
                                  pay_magtape_generic.get_parameter_value('ARCH_PAYROLL_ACTION_ID'),'SUBMITTER_REF_NO',
                                  action_information6)
  from   pay_assignment_actions paa,
         pay_action_information pai
  where  paa.payroll_action_id = pay_magtape_generic.get_parameter_value('ARCH_PAYROLL_ACTION_ID')
  and    pai.action_context_id = paa.assignment_action_id
  and    pai.action_information_category = 'EMEA PAYROLL INFO'
  and    pai.action_context_type = 'AAP'
  and    (pay_magtape_generic.get_parameter_value('TAX_REFERENCE') is null
          or
          upper(pai.action_information6) = upper(pay_magtape_generic.get_parameter_value('TAX_REFERENCE')))
  group by 'TAX_OFFICE_NAME=P',     NVL(UPPER(action_information4), ' '),
           'TAX_OFFICE_PHONE_NO=P', NVL(UPPER(action_information5), ' '),
           'EMPLOYERS_REF_NO=P',    NVL(UPPER(action_information6), ' '),
           'EMPLOYERS_NAME=P',      NVL(UPPER(action_information7), ' '),
           'EMPLOYERS_ADDRESS=P',   NVL(UPPER(action_information8), ' '),
           'MESSAGE_DATE=P',        to_char(sysdate,'YYYYMMDD'),
           'PARTY_NAME=P',          pay_gb_p11d_magtape.get_parameters(
                                    pay_magtape_generic.get_parameter_value('ARCH_PAYROLL_ACTION_ID'),
                                    'PARTY_NAME',action_information6),
           'SENDER_ID=P',           pay_gb_p11d_magtape.get_parameters(
                                    pay_magtape_generic.get_parameter_value('ARCH_PAYROLL_ACTION_ID'),'SENDER_ID',
                                    action_information6),
           'UNIQUE_REFERENCE=P',    to_number(pay_gb_p11d_magtape.get_parameters(
                                    pay_magtape_generic.get_parameter_value('ARCH_PAYROLL_ACTION_ID'),'REQUEST_ID')),
           'SUBMITTER_REF_NO=P',    pay_gb_p11d_magtape.get_parameters(
                                    pay_magtape_generic.get_parameter_value('ARCH_PAYROLL_ACTION_ID'),'SUBMITTER_REF_NO',
                                    action_information6);


  cursor csr_p11d_employee is
  select /*+ ORDERED use_nl(paa,pai)
             use_index(pai,pay_action_information_n2)*/
         'PERSON_ID=P',pai.action_information10
  from   pay_assignment_actions paa,
         pay_action_information pai
  where  paa.payroll_action_id = pay_magtape_generic.get_parameter_value('ARCH_PAYROLL_ACTION_ID')
  and    pai.action_context_id = paa.assignment_action_id
  and    pai.action_information_category = 'GB EMPLOYEE DETAILS'
  and    pai.action_context_type = 'AAP'
  and    upper(pai.action_information13) = upper(pay_magtape_generic.get_parameter_value('EMPLOYERS_REF_NO'))
  and    pay_gb_p11d_edi_control.fetch_total_benefit(paa.assignment_action_id,
                                                     paa.payroll_action_id,
                                                     pai.action_information13) > 0
  group by 'PERSON_ID=P',pai.action_information10;

  cursor csr_p11d_benefit is
  select 'BENEFIT_TYPE=P', cat
  from   (
         select cat
         from  (
		 -- Benefit from this select may occur only 1 time
         -- Benefit from this select may occur only 1 time
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		           use_index(pai_person,pay_action_information_n2)
				   use_index(pai,pay_action_information_n2) */
                   decode(pai.action_information_category,
                  'ASSETS TRANSFERRED',        'A',
                  'PAYMENTS MADE FOR EMP',     'B',
                  'VOUCHERS OR CREDIT CARDS',  'C',
                  'LIVING ACCOMMODATION',      'D',
                  'MILEAGE ALLOWANCE AND PPAYMENT', 'E',
                  'VANS 2007',                      'G', -- EOY 2008
                  'VANS 2005',                      'G',
                  'VANS 2002_03',                   'G',
                  'PVT MED TREATMENT OR INSURANCE', 'I',
                  'RELOCATION EXPENSES',            'J',
                  'SERVICES SUPPLIED',              'K',
                  'ASSETS AT EMP DISPOSAL',         'L',
                  'OTHER ITEMS',                    'M',
                  'OTHER ITEMS NON 1A',             'M',
                  'EXPENSES PAYMENTS',              'N',
                  'MARORS',                         'U') cat
		  from   per_all_assignments_f   paf,
       	  	   	 pay_assignment_actions  paa,
       		     pay_action_information  pai,
       		     pay_action_information  pai_person
		  where  paf.person_id = pay_magtape_generic.get_parameter_value('PERSON_ID')
                  and    paf.effective_end_date = (select max(paf2.effective_end_date)
		                                   from   per_all_assignments_f paf2
		                                   where  paf2.assignment_id = paf.assignment_id
                                                   and    paf2.person_id = pay_magtape_generic.get_parameter_value('PERSON_ID'))
		  and    paf.assignment_id = paa.assignment_id
		  and    paa.payroll_action_id = pay_magtape_generic.get_parameter_value('ARCH_PAYROLL_ACTION_ID')
		  and    pai.action_context_id = paa.assignment_action_id
		  and    pai.action_context_type = 'AAP'
		  and    pai.action_information_category = pai.action_information_category
		  and    pai_person.action_context_id = paa.assignment_action_id
		  and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
		  and    upper(pai_person.action_information13) = upper(pay_magtape_generic.get_parameter_value('EMPLOYERS_REF_NO'))
		  and    pai_person.action_context_type = 'AAP')
  		 group by cat -- pai.action_information_category
  		 union all  -- Benefit from this select may occur more than 1 time or
  		            -- it has a special layout/format - ie Expenses Payments.
  		 select  /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		           use_index(pai_person,pay_action_information_n2)
				   use_index(pai,pay_action_information_n2) */
         		decode(pai.action_information_category,
                  'CAR AND CAR FUEL 2003_04',   'F',
                  'INT FREE AND LOW INT LOANS', 'H')  cat
  		 from   per_all_assignments_f   paf,
       	        pay_assignment_actions  paa,
       	        pay_action_information  pai,
       	        pay_action_information  pai_person
		 where  paf.person_id = pay_magtape_generic.get_parameter_value('PERSON_ID')
                 and    paf.effective_end_date = (select max(paf2.effective_end_date)
		                                   from   per_all_assignments_f paf2
		                                   where  paf2.assignment_id = paf.assignment_id
                                                   and    paf2.person_id = pay_magtape_generic.get_parameter_value('PERSON_ID'))
		 and    paf.assignment_id = paa.assignment_id
		 and    paa.payroll_action_id = pay_magtape_generic.get_parameter_value('ARCH_PAYROLL_ACTION_ID')
		 and    pai.action_context_id = paa.assignment_action_id
		 and    pai.action_context_type = 'AAP'
		 and    pai.action_information_category = pai.action_information_category
		 and    pai_person.action_context_id = paa.assignment_action_id
		 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
		 and    upper(pai_person.action_information13) = upper(pay_magtape_generic.get_parameter_value('EMPLOYERS_REF_NO'))
		 and    pai_person.action_context_type = 'AAP')
  where cat in ('A',
                'B',
                'C',
                'D',
                'E',
                'F',
                'G',
                'H',
                'I',
                'J',
                'K',
                'L',
                'M',
                'N',
                'U')
  order by cat;

  function  get_header(p_sender_id         in     varchar2,
                       p_transmission_date in     varchar2,
                       p_test_transmission in     varchar2,
                       p_unique_reference  in     varchar2,
                       p_tax_year          in     varchar2,
                       p_missing_val       in out NoCopy number,
                       p_error_count       in out NoCopy number,
                       p_error_msg1        out NoCopy varchar2,
                       p_error_msg2        out NoCopy varchar2,
                       p_error_msg3        out NoCopy varchar2,
                       p_error_msg4        out NoCopy varchar2,
                       p_error_msg5        out NoCopy varchar2,
                       p_error_msg6        out NoCopy varchar2,
                       p_edi_rec1          out NoCopy varchar2,
                       p_edi_rec2          out NoCopy varchar2,
                       p_edi_rec3          out NoCopy varchar2,
                       p_edi_rec4          out NoCopy varchar2,
                       p_edi_rec5          out NoCopy varchar2,
                       p_edi_rec6          out NoCopy varchar2) return number;

  function  get_employer(p_tax_office_name  in     varchar2,
                         p_tax_phone_no     in     varchar2,
                         p_employer_ref     in     varchar2,
                         p_employer_name    in     varchar2,
                         p_employer_addr    in     varchar2,
                         p_submitter_ref    in     varchar2,
                         p_message_date     in     varchar2,
                         p_tax_year         in     varchar2,
                         p_party            in     varchar2,
                         p_error_count      in out NoCopy number,
                         p_error_msg1       out NoCopy varchar2,
                         p_error_msg2       out NoCopy varchar2,
                         p_error_msg3       out NoCopy varchar2,
                         p_error_msg4       out NoCopy varchar2,
                         p_error_msg5       out NoCopy varchar2,
                         p_error_msg6       out NoCopy varchar2,
                         p_error_msg7       out NoCopy varchar2,
                         p_error_msg8       out NoCopy varchar2,
                         p_error_msg9       out NoCopy varchar2,
                         p_edi_rec1         out NoCopy varchar2,
                         p_edi_rec2         out NoCopy varchar2,
                         p_edi_rec3         out NoCopy varchar2,
                         p_edi_rec4         out NoCopy varchar2,
                         p_edi_rec5         out NoCopy varchar2,
                         p_edi_rec6         out NoCopy varchar2,
                         p_edi_rec7         out NoCopy varchar2,
                         p_edi_rec8         out NoCopy varchar2,
                         p_edi_rec9         out NoCopy varchar2,
                         p_edi_rec10        out NoCopy varchar2,
                         p_edi_rec11        out NoCopy varchar2,
                         p_edi_rec12        out NoCopy varchar2) return number;

  function  get_employee(p_person_id     in         varchar2,
                         p_pact_id       in         varchar2,
                         p_tax_year      in         varchar2,
                         p_error_count   in out NoCopy number,
                         p_error_msg1    out NoCopy varchar2,
                         p_error_msg2    out NoCopy varchar2,
                         p_error_msg3    out NoCopy varchar2,
                         p_error_msg4    out NoCopy varchar2,
                         p_error_msg5    out NoCopy varchar2,
                         p_error_msg6    out NoCopy varchar2,
                         p_error_msg7    out NoCopy varchar2,
                         p_error_msg8    out NoCopy varchar2,
                         p_edi_rec1      out NoCopy varchar2,
                         p_edi_rec2      out NoCopy varchar2,
                         p_edi_rec3      out NoCopy varchar2,
                         p_edi_rec4      out NoCopy varchar2,
                         p_edi_rec5      out NoCopy varchar2,
                         p_edi_rec6      out NoCopy varchar2,
                         p_edi_rec7      out NoCopy varchar2,
                         p_edi_rec8      out NoCopy varchar2) return number;

  function  get_benefit(p_benefit_type  in  varchar2,
                        p_person_id     in  varchar2,
                        p_employer_ref  in  varchar2,
                        p_tax_year      in  varchar2,
                        p_benefit_count in  varchar2,
                        p_pact_id       in  varchar2,
                        p_value1        in out NoCopy varchar2,
                        p_value2        in out NoCopy varchar2,
                        p_value3        in out NoCopy varchar2,
                        p_value4        in out NoCopy varchar2,
                        p_value5        in out NoCopy varchar2,
                        p_value6        in out NoCopy varchar2,
                        p_value7        in out NoCopy varchar2,
                        p_value8        in out NoCopy varchar2,
                        p_value9        in out NoCopy varchar2,
                        p_value10       in out NoCopy varchar2,
                        p_value11       in out NoCopy varchar2,
                        p_value12       in out NoCopy varchar2,
                        p_value13       in out NoCopy varchar2,
                        p_value14       in out NoCopy varchar2,
                        p_value15       in out NoCopy varchar2,
                        p_value16       in out NoCopy varchar2,
                        p_value17       in out NoCopy varchar2,
                        p_value18       in out NoCopy varchar2,
                        p_value19       in out NoCopy varchar2,
                        p_value20       in out NoCopy varchar2,
                        p_value21       in out NoCopy varchar2,
                        p_value22       in out NoCopy varchar2,
                        p_value23       in out NoCopy varchar2,
                        p_value24       in out NoCopy varchar2,
                        p_value25       in out NoCopy varchar2,
                        p_value26       in out NoCopy varchar2,
                        p_value27       in out NoCopy varchar2,
                        p_value28       in out NoCopy varchar2,
                        p_value29       in out NoCopy varchar2,
                        p_value30       in out NoCopy varchar2,
                        p_edi_rec1      out NoCopy varchar2,
                        p_edi_rec2      out NoCopy varchar2,
                        p_edi_rec3      out NoCopy varchar2,
                        p_edi_rec4      out NoCopy varchar2,
                        p_edi_rec5      out NoCopy varchar2,
                        p_edi_rec6      out NoCopy varchar2,
                        p_edi_rec7      out NoCopy varchar2,
                        p_edi_rec8      out NoCopy varchar2,
                        p_edi_rec9      out NoCopy varchar2,
                        p_edi_rec10     out NoCopy varchar2,
                        p_edi_rec11     out NoCopy varchar2,
                        p_edi_rec12     out NoCopy varchar2,
                        p_edi_rec13     out NoCopy varchar2,
                        p_edi_rec14     out NoCopy varchar2,
                        p_edi_rec15     out NoCopy varchar2,
                        p_edi_rec16     out NoCopy varchar2,
                        p_edi_rec17     out NoCopy varchar2,
                        p_edi_rec18     out NoCopy varchar2,
                        p_edi_rec19     out NoCopy varchar2,
                        p_edi_rec20     out NoCopy varchar2,
                        p_edi_rec21     out NoCopy varchar2,
                        p_edi_rec22     out NoCopy varchar2,
                        p_edi_rec23     out NoCopy varchar2,
                        p_edi_rec24     out NoCopy varchar2,
                        p_edi_rec25     out NoCopy varchar2,
                        p_edi_rec26     out NoCopy varchar2,
                        p_edi_rec27     out NoCopy varchar2,
                        p_edi_rec28     out NoCopy varchar2,
                        p_edi_rec29     out NoCopy varchar2,
                        p_edi_rec30     out NoCopy varchar2) return number;

  function  get_summary(p_benefit_type  in varchar2,
                        p_tax_year      in varchar2,
                        p_value1        in varchar2,
                        p_value2        in varchar2,
                        p_value3        in varchar2,
                        p_value4        in varchar2,
                        p_value5        in varchar2,
                        p_value6        in varchar2,
                        p_value7        in varchar2,
                        p_value8        in varchar2,
                        p_value9        in varchar2,
                        p_value10       in varchar2,
                        p_value11       in varchar2,
                        p_value12       in varchar2,
                        p_value13       in varchar2,
                        p_value14       in varchar2,
                        p_value15       in varchar2,
                        p_value16       in varchar2,
                        p_value17       in varchar2,
                        p_value18       in varchar2,
                        p_value19       in varchar2,
                        p_value20       in varchar2,
                        p_value21       in varchar2,
                        p_value22       in varchar2,
                        p_value23       in varchar2,
                        p_value24       in varchar2,
                        p_value25       in varchar2,
                        p_value26       in varchar2,
                        p_value27       in varchar2,
                        p_value28       in varchar2,
                        p_value29       in varchar2,
                        p_value30       in varchar2,
                        p_edi_rec1      out NoCopy varchar2,
                        p_edi_rec2      out NoCopy varchar2,
                        p_edi_rec3      out NoCopy varchar2,
                        p_edi_rec4      out NoCopy varchar2,
                        p_edi_rec5      out NoCopy varchar2,
                        p_edi_rec6      out NoCopy varchar2,
                        p_edi_rec7      out NoCopy varchar2,
                        p_edi_rec8      out NoCopy varchar2,
                        p_edi_rec9      out NoCopy varchar2,
                        p_edi_rec10     out NoCopy varchar2,
                        p_edi_rec11     out NoCopy varchar2,
                        p_edi_rec12     out NoCopy varchar2,
                        p_edi_rec13     out NoCopy varchar2,
                        p_edi_rec14     out NoCopy varchar2,
                        p_edi_rec15     out NoCopy varchar2,
                        p_edi_rec16     out NoCopy varchar2,
                        p_edi_rec17     out NoCopy varchar2,
                        p_edi_rec18     out NoCopy varchar2,
                        p_edi_rec19     out NoCopy varchar2,
                        p_edi_rec20     out NoCopy varchar2,
                        p_edi_rec21     out NoCopy varchar2,
                        p_edi_rec22     out NoCopy varchar2,
                        p_edi_rec23     out NoCopy varchar2,
                        p_edi_rec24     out NoCopy varchar2,
                        p_edi_rec25     out NoCopy varchar2,
                        p_edi_rec26     out NoCopy varchar2,
                        p_edi_rec27     out NoCopy varchar2,
                        p_edi_rec28     out NoCopy varchar2,
                        p_edi_rec29     out NoCopy varchar2,
                        p_edi_rec30     out NoCopy varchar2) return number;

  function  get_footer(p_tax_year     in     varchar2,
                       p_record_count in     varchar2,
                       p_error_count  in     varchar2,
                       p_missing_val  in     varchar2,
                       p_error_msg1   out NoCopy varchar2,
                       p_error_msg2   out NoCopy varchar2,
                       p_edi_rec1     out NoCopy varchar2,
                       p_edi_rec2     out NoCopy varchar2,
                       p_edi_rec3     out NoCopy varchar2) return number;

  function  count_occurrence(p_benefit_type  in  varchar2,
                             p_person_id     in  varchar2,
                             p_employer_ref  in  varchar2,
                             p_tax_year      in  varchar2,
                             p_pact_id       in  varchar2) return number;

  function  check_occurrence(p_benefit_type in varchar2,
                             p_tax_year     in varchar2) return varchar2;

  function  get_benefit_name(p_benefit_type in varchar2,
                             p_tax_year     in varchar2) return varchar2;

END PAY_GB_P11D_EDI_CONTROL;

/
