--------------------------------------------------------
--  DDL for Package Body PAY_GB_P11D_EDI_2006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_P11D_EDI_2006" AS
/* $Header: pygbp11d06.pkb 120.13.12000000.4 2007/03/02 10:57:16 kthampan noship $ */
  --type type_output is table of varchar2(255) index by binary_integer;
  /******************* BEGIN PRIVATE FUNCTIONS/PROCEDURES ********************/

  /******************* Assets Transferred (Multi Occurance) ***********************/
  procedure get_asset_transferred(p_person_id  in varchar2,
                                  p_emp_ref    in varchar2,
                                  p_pact_id    in varchar2,
                                  p_edi_rec1  out NOCOPY varchar2,
                                  p_edi_rec2  out NOCOPY varchar2,
                                  p_edi_rec3  out NOCOPY varchar2,
                                  p_edi_rec4  out NOCOPY varchar2,
                                  p_edi_rec5  out NOCOPY varchar2,
                                  p_edi_rec6  out NOCOPY varchar2,
                                  p_edi_rec7  out NOCOPY varchar2,
                                  p_edi_rec8  out NOCOPY varchar2,
                                  p_edi_rec9  out NOCOPY varchar2,
                                  p_edi_rec10 out NOCOPY varchar2,
                                  p_edi_rec11 out NOCOPY varchar2,
                                  p_edi_rec12 out NOCOPY varchar2,
                                  p_edi_rec13 out NOCOPY varchar2,
                                  p_edi_rec14 out NOCOPY varchar2,
                                  p_edi_rec15 out NOCOPY varchar2,
                                  p_edi_rec16 out NOCOPY varchar2,
                                  p_edi_rec17 out NOCOPY varchar2,
                                  p_edi_rec18 out NOCOPY varchar2,
                                  p_edi_rec19 out NOCOPY varchar2,
                                  p_edi_rec20 out NOCOPY varchar2,
                                  p_edi_rec21 out NOCOPY varchar2,
                                  p_edi_rec22 out NOCOPY varchar2)
  is
		 type r_assets is record(
                description       varchar2(70),
                other_description varchar2(70),
                cost_or_mkt_value varchar2(50),
                cash_equivalent   varchar2(50),
                amount_made_good  varchar2(50));

         type t_assets is table of r_assets index by binary_integer;
	 type t_edi_record  is table of varchar2(255) index by binary_integer;

	 edi_record   t_edi_record;
	 assets       t_assets;
         l_total        number;
         l_count        number;
         l_cost         number;
         l_index        number;
         l_edi          number;

         edi_ftx1a           varchar2(6);
         edi_tax1            varchar2(6);
         edi_moa1            varchar2(6);
         edi_currency        varchar2(3);
	 edi_cat             varchar2(18);
         edi_tax_qualifier1  varchar2(3);
         edi_tax_qualifier8  varchar2(3);
         edi_tax_qualifier12 varchar2(3);
         edi_tax_qualifier115 varchar2(3);

         cursor get_data is
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		           use_index(pai_person,pay_action_information_n2)
			   use_index(pai,pay_action_information_n2) */
		sum(to_number(nvl(pai.action_information9,0))) cash_equivalent,
                sum(to_number(nvl(pai.action_information7,0))) cost_or_mkt_value,
                sum(to_number(nvl(pai.action_information8,0))) amount_made_good,
                upper(max(pai.action_information5)) asset_description,
                pay_gb_p11d_magtape.get_description(pai.action_information6,'GB_ASSET_TYPE',
                                                		pai.action_information4) asset_type
         from   per_all_assignments_f   paf,
       	    	pay_assignment_actions  paa,
       	        pay_action_information  pai,
       		pay_action_information  pai_person
	 where  paf.person_id = p_person_id
         and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
	 and    paf.assignment_id = paa.assignment_id
	 and    paa.payroll_action_id = p_pact_id
	 and    pai.action_context_id = paa.assignment_action_id
	 and    pai.action_context_type = 'AAP'
	 and    pai.action_information_category = 'ASSETS TRANSFERRED'
	 and    pai_person.action_context_id = paa.assignment_action_id
	 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
	 and    upper(pai_person.action_information13) = upper(p_emp_ref)
	 and    pai_person.action_context_type = 'AAP'
	 group by pay_gb_p11d_magtape.get_description(pai.action_information6,'GB_ASSET_TYPE',
                                                		pai.action_information4);
  begin
         edi_cat   := rpad('A',18);
         edi_ftx1a := rpad('FTX1A',6);
         edi_moa1  := rpad('MOA1',6);
         edi_tax1  := rpad('TAX1',6);
         edi_currency := 'GBP';
         edi_tax_qualifier1   := rpad('1',3);
         edi_tax_qualifier8   := rpad('8',3);
         edi_tax_qualifier12  := rpad('12',3);
         edi_tax_qualifier115 := rpad('115',3);

         l_total := 0;
         l_count := 0;
         for asset in get_data loop
             if asset.cash_equivalent >= 1 then
                l_count := l_count + 1;
                l_total := l_total + asset.cash_equivalent;
                l_cost  := asset.cash_equivalent + asset.amount_made_good;
                assets(l_count).description      := substr(asset.asset_type,1,70);
                assets(l_count).cost_or_mkt_value:= pay_gb_p11d_magtape.format_edi_currency(l_cost);
                assets(l_count).cash_equivalent  := pay_gb_p11d_magtape.format_edi_currency(asset.cash_equivalent);
                assets(l_count).amount_made_good := pay_gb_p11d_magtape.format_edi_currency(asset.amount_made_good);
                if asset.asset_type = 'OTHER' then
                   assets(l_count).other_description := substr(asset.asset_description,1,70);
                else
                   assets(l_count).other_description := ' ';
                end if;
             end if;
         end loop;

         l_edi := 0;
         --- This can repeat up to 5 times
         for l_index in 1..l_count loop
             l_edi := l_edi + 1;
             edi_record(l_edi) := edi_ftx1a || edi_cat || rpad(assets(l_index).description, 71) ||
			                      rpad(assets(l_index).other_description, 71) || rpad(' ',70) || fnd_global.local_chr(10);
             l_edi := l_edi + 1;
             edi_record(l_edi) := edi_tax1  || edi_tax_qualifier8  || fnd_global.local_chr(10) ||
			                      edi_moa1  || assets(l_index).cost_or_mkt_value || edi_currency || fnd_global.local_chr(10);
			 l_edi := l_edi + 1;
             edi_record(l_edi) := edi_tax1  || edi_tax_qualifier1  || fnd_global.local_chr(10) ||
                                  edi_moa1  || assets(l_index).amount_made_good || edi_currency || fnd_global.local_chr(10);
             l_edi := l_edi + 1;
             edi_record(l_edi) := edi_tax1  || edi_tax_qualifier12 || fnd_global.local_chr(10) ||
                                  edi_moa1  || assets(l_index).cash_equivalent || edi_currency || fnd_global.local_chr(10);
         end loop;

        if (l_total >= 1) then
            edi_cat   := rpad('Q',18);
            l_edi := l_edi + 1;
            edi_record(l_edi) := edi_ftx1a || edi_cat || rpad(' ',71) || rpad(' ',71) || rpad(' ',70) || fnd_global.local_chr(10);
            l_edi := l_edi + 1;
            edi_record(l_edi) := edi_tax1  || edi_tax_qualifier115 || fnd_global.local_chr(10) ||
                                 edi_moa1  || pay_gb_p11d_magtape.format_edi_currency(l_total) || edi_currency || fnd_global.local_chr(10);
         end if;

         -- Maximum output is 22 + 1 edi records
         l_edi := l_edi + 1;
         for l_index in l_edi..23 loop
             edi_record(l_index) := null;
         end loop;

         p_edi_rec1  := edi_record(1);
         p_edi_rec2  := edi_record(2);
         p_edi_rec3  := edi_record(3);
         p_edi_rec4  := edi_record(4);
         p_edi_rec5  := edi_record(5);
         p_edi_rec6  := edi_record(6);
         p_edi_rec7  := edi_record(7);
         p_edi_rec8  := edi_record(8);
         p_edi_rec9  := edi_record(9);
         p_edi_rec10 := edi_record(10);
         p_edi_rec11 := edi_record(11);
         p_edi_rec12 := edi_record(12);
         p_edi_rec13 := edi_record(13);
         p_edi_rec14 := edi_record(14);
         p_edi_rec15 := edi_record(15);
         p_edi_rec16 := edi_record(16);
         p_edi_rec17 := edi_record(17);
         p_edi_rec18 := edi_record(18);
         p_edi_rec19 := edi_record(19);
         p_edi_rec20 := edi_record(20);
         p_edi_rec21 := edi_record(21);
         p_edi_rec22 := edi_record(22);
  end get_asset_transferred;
  /******************* Assets Transferred (Multi Occurance) ***********************/

  /******************* Payment Made For Emp (Multi Occurance) ***********************/
  procedure get_payments_for_emp(p_person_id  in varchar2,
                                 p_emp_ref    in varchar2,
                                 p_pact_id    in varchar2,
                                 p_edi_rec1  out NOCOPY varchar2,
                                 p_edi_rec2  out NOCOPY varchar2,
                                 p_edi_rec3  out NOCOPY varchar2,
                                 p_edi_rec4  out NOCOPY varchar2,
                                 p_edi_rec5  out NOCOPY varchar2,
                                 p_edi_rec6  out NOCOPY varchar2,
                                 p_edi_rec7  out NOCOPY varchar2,
                                 p_edi_rec8  out NOCOPY varchar2,
                                 p_edi_rec9  out NOCOPY varchar2,
                                 p_edi_rec10 out NOCOPY varchar2,
                                 p_edi_rec11 out NOCOPY varchar2,
                                 p_edi_rec12 out NOCOPY varchar2,
                                 p_edi_rec13 out NOCOPY varchar2,
                                 p_edi_rec14 out NOCOPY varchar2,
                                 p_edi_rec15 out NOCOPY varchar2,
                                 p_edi_rec16 out NOCOPY varchar2,
                                 p_edi_rec17 out NOCOPY varchar2)
  is
         type r_payments is record(
         description       varchar2(70),
         cash_equivalent   varchar2(50));

         type t_payments is table of r_payments index by binary_integer;
	 type t_edi_record  is table of varchar2(255) index by binary_integer;

	 edi_record     t_edi_record;
	 payments       t_payments;
         l_total        number;
         l_count        number;
         l_notional     number;
         l_index        number;
         l_edi          number;

         edi_ftx1a            varchar2(6);
         edi_tax1             varchar2(6);
         edi_moa1             varchar2(6);
         edi_currency         varchar2(3);
	 edi_cat              varchar2(18);
         edi_tax_qualifier4   varchar2(3);
         edi_tax_qualifier116 varchar2(3);
         edi_tax_qualifier117 varchar2(3);

         cursor get_data is
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		           use_index(pai_person,pay_action_information_n2)
			   use_index(pai,pay_action_information_n2) */
	        sum(to_number(nvl(pai.action_information7,0))) cash_equivalent,
                sum(to_number(nvl(pai.action_information8,0))) tax_on_notional_payments,
                --UPPER(pai.action_information5) payment_description,
                pay_gb_p11d_magtape.get_description(pai.action_information6,'GB_PAYMENTS_MADE',
                                                 		pai.action_information4) payment_type
         from   per_all_assignments_f   paf,
       	    	pay_assignment_actions  paa,
       		pay_action_information  pai,
       		pay_action_information  pai_person
	 where  paf.person_id = p_person_id
         and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
	 and    paf.assignment_id = paa.assignment_id
	 and    paa.payroll_action_id = p_pact_id
	 and    pai.action_context_id = paa.assignment_action_id
	 and    pai.action_context_type = 'AAP'
	 and    pai.action_information_category = 'PAYMENTS MADE FOR EMP'
	 and    pai_person.action_context_id = paa.assignment_action_id
	 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
	 and    upper(pai_person.action_information13) = upper(p_emp_ref)
	 and    pai_person.action_context_type = 'AAP'
	 group by pay_gb_p11d_magtape.get_description(pai.action_information6,'GB_PAYMENTS_MADE',
                                                 		pai.action_information4);
  begin
         edi_cat   := rpad('B',18);
         edi_ftx1a := rpad('FTX1A',6);
         edi_moa1  := rpad('MOA1',6);
         edi_tax1  := rpad('TAX1',6);
         edi_currency := 'GBP';
         edi_tax_qualifier4   := rpad('4',3);
         edi_tax_qualifier116 := rpad('116',3);
         edi_tax_qualifier117 := rpad('117',3);

         l_total    := 0;
         l_count    := 0;
         l_notional := 0;
         for payment in get_data loop
             l_notional := l_notional + payment.tax_on_notional_payments;
             if payment.cash_equivalent >= 1 then
                l_count := l_count + 1;
                l_total := l_total + payment.cash_equivalent;
                payments(l_count).description    := substr(payment.payment_type,1,70);
                payments(l_count).cash_equivalent:= pay_gb_p11d_magtape.format_edi_currency(payment.cash_equivalent);
             end if;
         end loop;

         l_edi := 0;
         --- This can repeat up to 7 times
         for l_index in 1..l_count loop
             l_edi := l_edi + 1;
             edi_record(l_edi) := edi_ftx1a || edi_cat || rpad(payments(l_index).description, 71) || rpad(' ', 71) || rpad(' ',70) || fnd_global.local_chr(10);
             l_edi := l_edi + 1;
             edi_record(l_edi) := edi_tax1  || edi_tax_qualifier4  || fnd_global.local_chr(10) ||
                                  edi_moa1  || payments(l_index).cash_equivalent || edi_currency || fnd_global.local_chr(10);
         end loop;

	 if (l_total >= 1) then
	    edi_cat   := rpad('R',18);
	    l_edi := l_edi + 1;
            edi_record(l_edi) := edi_ftx1a || edi_cat || rpad(' ',71) || rpad(' ',71) || rpad(' ',70) || fnd_global.local_chr(10);
            l_edi := l_edi + 1;
            edi_record(l_edi) := edi_tax1  || edi_tax_qualifier116 || fnd_global.local_chr(10) ||
                                 edi_moa1  || pay_gb_p11d_magtape.format_edi_currency(l_total) || edi_currency || fnd_global.local_chr(10);
            l_edi := l_edi + 1;
            edi_record(l_edi) := edi_tax1  || edi_tax_qualifier117 || fnd_global.local_chr(10) ||
                                 edi_moa1  || pay_gb_p11d_magtape.format_edi_currency(l_notional) || edi_currency || fnd_global.local_chr(10);
         end if;

         -- Maximum output is 17 + 1 edi records
	 l_edi := l_edi + 1;
         for l_index in l_edi..18 loop
             edi_record(l_index) := null;
         end loop;

         p_edi_rec1  := edi_record(1);
         p_edi_rec2  := edi_record(2);
         p_edi_rec3  := edi_record(3);
         p_edi_rec4  := edi_record(4);
         p_edi_rec5  := edi_record(5);
         p_edi_rec6  := edi_record(6);
         p_edi_rec7  := edi_record(7);
         p_edi_rec8  := edi_record(8);
         p_edi_rec9  := edi_record(9);
         p_edi_rec10 := edi_record(10);
         p_edi_rec11 := edi_record(11);
         p_edi_rec12 := edi_record(12);
         p_edi_rec13 := edi_record(13);
         p_edi_rec14 := edi_record(14);
         p_edi_rec15 := edi_record(15);
         p_edi_rec16 := edi_record(16);
         p_edi_rec17 := edi_record(17);
  end get_payments_for_emp;
  /******************* Payment Made For Emp (Multi Occurance) ***********************/

  /******************* Voucher or Credit Cards (Single Occurance) ***********************/
  procedure get_voucher_n_creditcard(p_person_id in  varchar2,
                                     p_emp_ref   in  varchar2,
                                     p_pact_id   in  varchar2,
				     p_edi_rec1  out NOCOPY varchar2,
                                     p_edi_rec2  out NOCOPY varchar2,
                                     p_edi_rec3  out NOCOPY varchar2,
                                     p_edi_rec4  out NOCOPY varchar2,
                                     p_edi_rec5  out NOCOPY varchar2,
                                     p_edi_rec6  out NOCOPY varchar2,
                                     p_edi_rec7  out NOCOPY varchar2)
  is
         l_cash_equivalent number;
         l_gross_amount    number;
         l_amount_m_good   number;

	 edi_ftx1a           varchar2(6);
         edi_tax1            varchar2(6);
         edi_moa1            varchar2(6);
         edi_currency        varchar2(3);
	 edi_cat             varchar2(18);
	 edi_tax_qualifier1  varchar2(3);
	 edi_tax_qualifier12 varchar2(3);
         edi_tax_qualifier41 varchar2(3);

         cursor get_data is
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		           use_index(pai_person,pay_action_information_n2)
			   use_index(pai,pay_action_information_n2) */
		sum(to_number(nvl(pai.action_information11,0))) cash_equivalent,
                sum(to_number(nvl(pai.action_information6,0)))  gross_amount,
                sum(to_number(nvl(pai.action_information7,0)))  amount_m_good
         from   per_all_assignments_f   paf,
       	    	pay_assignment_actions  paa,
       	        pay_action_information  pai,
       		pay_action_information  pai_person
	 where  paf.person_id = p_person_id
         and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
	 and    paf.assignment_id = paa.assignment_id
	 and    paa.payroll_action_id = p_pact_id
	 and    pai.action_context_id = paa.assignment_action_id
	 and    pai.action_context_type = 'AAP'
	 and    pai.action_information_category = 'VOUCHERS OR CREDIT CARDS'
	 and    pai_person.action_context_id = paa.assignment_action_id
	 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
	 and    upper(pai_person.action_information13) = upper(p_emp_ref)
	 and    pai_person.action_context_type = 'AAP';
  begin
         edi_ftx1a           := rpad('FTX1A',6);
         edi_tax1            := rpad('TAX1',6);
         edi_moa1            := rpad('MOA1',6);
         edi_currency        := 'GBP';
	 edi_cat             := rpad('C',18);
         edi_tax_qualifier1  := rpad('1',3);
         edi_tax_qualifier12 := rpad('12',3);
         edi_tax_qualifier41 := rpad('41',3);

         open get_data;
         fetch get_data into l_cash_equivalent,
                             l_gross_amount,
                             l_amount_m_good;
         close get_data;

         if l_cash_equivalent >= 1 then
            p_edi_rec1  := edi_ftx1a || edi_cat || rpad(' ', 71) || rpad(' ', 71) ||
                           rpad(' ', 70) || fnd_global.local_chr(10);
            p_edi_rec2  := edi_tax1 || edi_tax_qualifier41 || fnd_global.local_chr(10);
            p_edi_rec3  := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_gross_amount) ||
			               edi_currency || fnd_global.local_chr(10);
            p_edi_rec4  := edi_tax1 || edi_tax_qualifier1 || fnd_global.local_chr(10);
            p_edi_rec5  := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_amount_m_good) ||
			               edi_currency || fnd_global.local_chr(10);
            p_edi_rec6  := edi_tax1 || edi_tax_qualifier12 || fnd_global.local_chr(10);
            p_edi_rec7  := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_cash_equivalent) ||
			               edi_currency || fnd_global.local_chr(10);
         end if;
  end get_voucher_n_creditcard;
  /******************* Voucher or Credit Cards (Single Occurance) ***********************/

  /******************* Living Accommodation (Single Occurance) ***********************/
  procedure get_living_accommodation(p_person_id in  varchar2,
                                     p_emp_ref   in  varchar2,
                                     p_pact_id   in  varchar2,
                                     p_edi_rec1  out NOCOPY varchar2,
                                     p_edi_rec2  out NOCOPY varchar2,
                                     p_edi_rec3  out NOCOPY varchar2)
  is
         l_cash_equivalent number;

	 edi_ftx1a           varchar2(6);
         edi_tax1            varchar2(6);
         edi_moa1            varchar2(6);
         edi_currency        varchar2(3);
	 edi_cat             varchar2(18);
	 edi_tax_qualifier12 varchar2(3);

         cursor get_data is
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		           use_index(pai_person,pay_action_information_n2)
			   use_index(pai,pay_action_information_n2) */
		sum(to_number(nvl(pai.action_information10,0))) cash_equivalent
	 from   per_all_assignments_f   paf,
       	    	pay_assignment_actions  paa,
       	        pay_action_information  pai,
       		pay_action_information  pai_person
	 where  paf.person_id = p_person_id
         and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
	 and    paf.assignment_id = paa.assignment_id
	 and    paa.payroll_action_id = p_pact_id
	 and    pai.action_context_id = paa.assignment_action_id
	 and    pai.action_context_type = 'AAP'
	 and    pai.action_information_category = 'LIVING ACCOMMODATION'
	 and    pai_person.action_context_id = paa.assignment_action_id
	 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
	 and    upper(pai_person.action_information13) = upper(p_emp_ref)
	 and    pai_person.action_context_type = 'AAP';
  begin
         edi_ftx1a           := rpad('FTX1A',6);
         edi_tax1            := rpad('TAX1',6);
         edi_moa1            := rpad('MOA1',6);
         edi_currency        := 'GBP';
	 edi_cat             := rpad('D',18);
         edi_tax_qualifier12 := rpad('12',3);

         open get_data;
         fetch get_data into l_cash_equivalent;
         close get_data;

         if l_cash_equivalent >= 1 then
            p_edi_rec1  := edi_ftx1a || edi_cat || rpad(' ', 71) || rpad(' ', 71) ||
                           rpad(' ', 70) || fnd_global.local_chr(10);
            p_edi_rec2  := edi_tax1 || edi_tax_qualifier12 || fnd_global.local_chr(10);
            p_edi_rec3  := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_cash_equivalent) ||
			               edi_currency || fnd_global.local_chr(10);
         end if;
  end get_living_accommodation;
  /******************* Living Accommodation (Single Occurance) ***********************/

  /******************* Mileage Allowance (Single Occurance) ***********************/
  procedure get_mileage_allowance(p_person_id in  varchar2,
                                  p_emp_ref   in  varchar2,
                                  p_pact_id   in  varchar2,
                                  p_edi_rec1  out NOCOPY varchar2,
                                  p_edi_rec2  out NOCOPY varchar2,
                                  p_edi_rec3  out NOCOPY varchar2)
  is
         l_taxable_payments number;

	 edi_ftx1a           varchar2(6);
         edi_tax1            varchar2(6);
         edi_moa1            varchar2(6);
         edi_currency        varchar2(3);
	 edi_cat             varchar2(18);
	 edi_tax_qualifier71 varchar2(3);

         cursor get_data is
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		           use_index(pai_person,pay_action_information_n2)
			   use_index(pai,pay_action_information_n2) */
		sum(to_number(nvl(pai.action_information12,0))) cash_equivalent
	 from   per_all_assignments_f   paf,
       	    	pay_assignment_actions  paa,
       	        pay_action_information  pai,
       		pay_action_information  pai_person
	 where  paf.person_id = p_person_id
         and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
	 and    paf.assignment_id = paa.assignment_id
	 and    paa.payroll_action_id = p_pact_id
	 and    pai.action_context_id = paa.assignment_action_id
	 and    pai.action_context_type = 'AAP'
	 and    pai.action_information_category = 'GB P11D ASSIGNMENT RESULTA'
	 and    pai_person.action_context_id = paa.assignment_action_id
	 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
	 and    upper(pai_person.action_information13) = upper(p_emp_ref)
	 and    pai_person.action_context_type = 'AAP';
  begin
         edi_ftx1a           := rpad('FTX1A',6);
         edi_tax1            := rpad('TAX1',6);
         edi_moa1            := rpad('MOA1',6);
         edi_currency        := 'GBP';
	 edi_cat             := rpad('E',18);
         edi_tax_qualifier71 := rpad('71',3);

         open get_data;
         fetch get_data into l_taxable_payments;
         close get_data;

         if l_taxable_payments >= 1 then
            p_edi_rec1  := edi_ftx1a || edi_cat || rpad(' ', 71) || rpad(' ', 71) ||
                           rpad(' ', 70) || fnd_global.local_chr(10);
            p_edi_rec2  := edi_tax1 || edi_tax_qualifier71 || fnd_global.local_chr(10);
            p_edi_rec3  := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_taxable_payments) ||
			               edi_currency || fnd_global.local_chr(10);
         end if;
  end get_mileage_allowance;
  /******************* Mileage Allowance (Single Occurance) ***********************/

  /******************* Car and Car Fuel (Multi Occurance) ***********************/
  procedure  get_car_or_fuel(p_person_id  in  varchar2,
                             p_emp_ref    in  varchar2,
                             p_pact_id    in  varchar2,
                             p_tax_year   in varchar2,
                             p_ben_count  in  varchar2,
                             p_value1     in out NOCOPY varchar2,
                             p_value2     in out NOCOPY varchar2,
			     p_edi_rec1   out NOCOPY varchar2,
                             p_edi_rec2   out NOCOPY varchar2,
                             p_edi_rec3   out NOCOPY varchar2,
                             p_edi_rec4   out NOCOPY varchar2,
                             p_edi_rec5   out NOCOPY varchar2,
                             p_edi_rec6   out NOCOPY varchar2,
                             p_edi_rec7   out NOCOPY varchar2,
                             p_edi_rec8   out NOCOPY varchar2,
                             p_edi_rec9   out NOCOPY varchar2,
                             p_edi_rec10  out NOCOPY varchar2,
                             p_edi_rec11  out NOCOPY varchar2,
                             p_edi_rec12  out NOCOPY varchar2,
                             p_edi_rec13  out NOCOPY varchar2,
                             p_edi_rec14  out NOCOPY varchar2,
                             p_edi_rec15  out NOCOPY varchar2,
                             p_edi_rec16  out NOCOPY varchar2,
                             p_edi_rec17  out NOCOPY varchar2,
                             p_edi_rec18  out NOCOPY varchar2,
                             p_edi_rec19  out NOCOPY varchar2,
                             p_edi_rec20  out NOCOPY varchar2,
                             p_edi_rec21  out NOCOPY varchar2,
                             p_edi_rec22  out NOCOPY varchar2,
                             p_edi_rec23  out NOCOPY varchar2)
  is
         l_cash_equivalent_for_car     varchar2(35);
         l_cash_equivalent_for_fuel    varchar2(35);
         l_date_free_fuel_withdrawn    varchar2(35);
         l_free_fuel_reinstated        varchar2(35);
         l_co2_emission                varchar2(35);
         l_mileage_band                varchar2(35);
         l_fuel_type                   varchar2(35);
         l_date_first_registered       varchar2(35);
         l_engine_cc_for_fuel_charge   varchar2(35);
         l_benefit_start_date          varchar2(35);
         l_benefit_end_date            varchar2(35);
         l_list_price                  varchar2(35);
         l_tax_year                    varchar2(35);
         l_private_use_payments        varchar2(35);
         l_make_of_car                 varchar2(70);
         l_model                       varchar2(70);
         l_optional_accessories_fitted varchar2(35);
         l_capital_contribution_made   varchar2(35);
         l_withdrawn_date              varchar2(35);
         l_row_num                     number;

	 edi_ftx1a           varchar2(6);
         edi_tax1            varchar2(6);
         edi_moa1            varchar2(6);
         edi_currency        varchar2(3);
	 edi_cat             varchar2(18);
	 edi_att3            varchar2(6);
         edi_att3_qualifier5 varchar2(4);
         edi_tax_qualifier4  varchar2(4);
         edi_tax_qualifier5  varchar2(3);
         edi_tax_qualifier9  varchar2(3);
         edi_tax_qualifier10 varchar2(3);
         edi_tax_qualifier13 varchar2(4);
         edi_tax_qualifier21 varchar2(3);
         edi_tax_qualifier28 varchar2(4);
         edi_tax_qualifier30 varchar2(4);
         edi_tax_qualifier34 varchar2(4);
         edi_tax_qualifier43 varchar2(3);
         edi_tax_qualifier136 varchar2(3);
         edi_dtm2   varchar2(6);
         edi_dtmg   varchar2(4);
         edi_dtm375 varchar2(4);
         edi_dtm488 varchar2(4);
         edi_dtm489 varchar2(4);
         edi_dtm102 varchar2(3);
         edi_tax_year_end   varchar2(10);
         edi_tax_year_start varchar2(10);
         edi_date_from      varchar2(10);
         edi_date_to        varchar2(10);

         cursor get_data(p_benefit_number number) is
         select *
         from   (
                select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		                use_index(pai_person,pay_action_information_n2)
			        use_index(pai,pay_action_information_n2) */
		       rownum as row_num,
                       pai.action_information3  benefit_start_date,
                       pai.action_information4  benefit_end_date,
                       upper(pai.action_information6)  make_of_car,
                       upper(pai.action_information7)  model,
                       pai.action_information8  date_first_registered,
                       pai.action_information9  list_price,
                       pai.action_information10 cash_equivalent_for_car,
                       pai.action_information11 cash_equivalent_for_fuel,
                       upper(pai.action_information12) fuel_type,
                       pai.action_information13 co2_emission,
                       pai.action_information15 optional_accessories,
                       pai.action_information16 capital_contribution,
                       pai.action_information17 private_use_payments,
                       pai.action_information18 engine_cc,
                       pai.action_information26 date_free_fuel_withdrawn,
                       pai.action_information27 free_fuel_reinstated
                from   per_all_assignments_f   paf,
       	    	       pay_assignment_actions  paa,
       		       pay_action_information  pai,
       		       pay_action_information  pai_person
		where  paf.person_id = p_person_id
                and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
		and    paf.assignment_id = paa.assignment_id
		and    paa.payroll_action_id = p_pact_id
		and    pai.action_context_id = paa.assignment_action_id
		and    pai.action_context_type = 'AAP'
		and    pai.action_information_category = 'CAR AND CAR FUEL 2003_04'
		and    pai_person.action_context_id = paa.assignment_action_id
		and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
		and    upper(pai_person.action_information13) = upper(p_emp_ref)
		and    pai_person.action_context_type = 'AAP')
         where  row_num = p_benefit_number;
  begin
         edi_ftx1a           := rpad('FTX1A',6);
         edi_tax1            := rpad('TAX1',6);
         edi_moa1            := rpad('MOA1',6);
         edi_currency        := 'GBP';
	 edi_cat             := rpad('F',18);
         edi_att3            := rpad('ATT3',6);
         edi_att3_qualifier5 := rpad('5',4);
         edi_tax_qualifier4  := rpad('4',4);
         edi_tax_qualifier5  := rpad('5',3);
         edi_tax_qualifier9  := rpad('9',3);
         edi_tax_qualifier10 := rpad('10',3);
         edi_tax_qualifier13 := rpad('13',4);
         edi_tax_qualifier21 := rpad('21',3);
         edi_tax_qualifier28 := rpad('28',4);
         edi_tax_qualifier30 := rpad('30',4);
         edi_tax_qualifier34 := rpad('34',4);
         edi_tax_qualifier43 := rpad('43',3);
         edi_tax_qualifier136:= rpad('136',3);
         edi_dtm2  := rpad('DTM2',6);
         edi_dtmg  := rpad('G',4);
         edi_dtm375:= rpad('375',4);
         edi_dtm488:= rpad('488',4);
         edi_dtm489:= rpad('489',4);
         edi_dtm102:= rpad('102',3);

         l_tax_year := p_tax_year;

         open get_data(to_number(p_ben_count));
         fetch get_data into l_row_num,
	                     l_benefit_start_date,
                             l_benefit_end_date,
                             l_make_of_car,
                             l_model,
                             l_date_first_registered,
                             l_list_price,
                             l_cash_equivalent_for_car,
                             l_cash_equivalent_for_fuel,
                             l_fuel_type,
                             l_co2_emission,
                             l_optional_accessories_fitted,
                             l_capital_contribution_made,
                             l_private_use_payments,
                             l_engine_cc_for_fuel_charge,
                             l_date_free_fuel_withdrawn,
                             l_free_fuel_reinstated;
         close get_data;

         l_cash_equivalent_for_car     := nvl(l_cash_equivalent_for_car,0);
         l_cash_equivalent_for_fuel    := nvl(l_cash_equivalent_for_fuel,0);
         l_optional_accessories_fitted := nvl(l_optional_accessories_fitted,0);
         l_list_price                  := nvl(l_list_price,0);
         l_capital_contribution_made   := nvl(l_capital_contribution_made,0);
         l_private_use_payments        := nvl(l_private_use_payments,0);

         if to_number(l_cash_equivalent_for_car) >= 1 or
            to_number(l_cash_equivalent_for_fuel) >= 1 then
            p_value1 := to_char(to_number(p_value1) + l_cash_equivalent_for_car);
            p_value2 := to_char(to_number(p_value2) + l_cash_equivalent_for_fuel);

            -- l_mileage_band is the non-formatted version of the l_co2_emission
            -- l_mileage_band is use for any validation.
            l_mileage_band := l_co2_emission;

            if (to_date(substr(l_date_first_registered,1,10),'YYYY/MM/DD') >= to_date('1998/01/01','YYYY/MM/DD')) and
               (l_co2_emission is not null and l_fuel_type <> 'BATTERY_ELECTRIC') then
                l_co2_emission := pay_gb_p11d_magtape.round_and_pad(l_co2_emission,3);
            else
                l_co2_emission := ' ';
            end if;

            if (to_date(substr(l_date_first_registered,1,10),'YYYY/MM/DD') <
                to_date('1998/01/01','YYYY/MM/DD') or
               (to_date(substr(l_date_first_registered,1,10),'YYYY/MM/DD') >=
                to_date('1998/01/01','YYYY/MM/DD') and  l_mileage_band is null)) then
                l_engine_cc_for_fuel_charge := pay_gb_p11d_magtape.round_and_pad(l_engine_cc_for_fuel_charge,4);
            else
                l_engine_cc_for_fuel_charge := ' ';
            end if;

            if (to_date(substr(l_date_first_registered,1,10),'YYYY/MM/DD') >=
                to_date('1998/01/01','YYYY/MM/DD')) then
                select decode(l_fuel_type,
                              'BATTERY_ELECTRIC','E',
                              'DIESEL','D',
                              'EURO_IV_DIESEL','L',
                              'HYBRID_ELECTRIC','H',
                              'LPG_CNG','B',
                              'LPG_CNG_PETROL','B',
                              'LPG_CNG_PETROL_CONV','C',
                              'PETROL','P',
                              'D')
                into  l_fuel_type
                from  dual;
            else
                l_fuel_type := ' ';
            end if;

            edi_tax_year_end   := l_tax_year || '0405';
            edi_tax_year_start := to_char(to_number(l_tax_year) - 1) || '0406';
            edi_date_from := substr(l_benefit_start_date,1,4) ||
                          substr(l_benefit_start_date,6,2) ||
                          substr(l_benefit_start_date,9,2);
            edi_date_to   := substr(l_benefit_end_date,1,4) ||
                          substr(l_benefit_end_date,6,2) ||
                          substr(l_benefit_end_date,9,2);

            p_edi_rec1 := edi_ftx1a || edi_cat || rpad(' ', 71) || rpad(' ', 71) || rpad(' ', 70) || fnd_global.local_chr(10);
            p_edi_rec2 := edi_tax1 || edi_tax_qualifier43 || fnd_global.local_chr(10);
            p_edi_rec3 := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_list_price) || edi_currency || fnd_global.local_chr(10);

            if to_number(l_optional_accessories_fitted) > 0 then
               p_edi_rec4 := edi_tax1 || edi_tax_qualifier136 || fnd_global.local_chr(10);
               p_edi_rec5 := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_optional_accessories_fitted) ||
                          edi_currency || fnd_global.local_chr(10);
            end if;

            if to_number(l_capital_contribution_made) > 0 then
	       p_edi_rec6 := edi_tax1 || edi_tax_qualifier21 || fnd_global.local_chr(10);
               p_edi_rec7 := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_capital_contribution_made) ||
                          edi_currency || fnd_global.local_chr(10);
            end if;

            if to_number(l_private_use_payments) > 0 then
               p_edi_rec8 := edi_tax1 || edi_tax_qualifier5 || fnd_global.local_chr(10);
               p_edi_rec9 := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_private_use_payments) || edi_currency || fnd_global.local_chr(10);
            end if;

            p_edi_rec10:= edi_tax1 || edi_tax_qualifier9 || fnd_global.local_chr(10);
            p_edi_rec11:= edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_cash_equivalent_for_car) ||
                       edi_currency || fnd_global.local_chr(10);

            --if (l_co2_emission is not null or l_engine_cc_for_fuel_charge <> ' ') then
            --if to_number(l_cash_equivalent_for_fuel) > 0 then
            if ((l_co2_emission  <> ' ' or l_engine_cc_for_fuel_charge <> ' ') and
                to_number(l_cash_equivalent_for_fuel) > 0
               ) then
               p_edi_rec12 := edi_tax1 || edi_tax_qualifier10 || fnd_global.local_chr(10);
               p_edi_rec13 := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_cash_equivalent_for_fuel) ||
                           edi_currency || fnd_global.local_chr(10);
            end if;

    	    p_edi_rec14:= edi_att3 || edi_att3_qualifier5 || rpad(l_make_of_car || ' ' || l_model,35) || fnd_global.local_chr(10);

            if (to_date(substr(l_date_first_registered,1,10),'YYYY/MM/DD') >=
                to_date('1998/01/01','YYYY/MM/DD') and l_mileage_band is not null and
                to_number(nvl(l_mileage_band,0)) > 0 ) and
			 (l_fuel_type <> 'E') then
                p_edi_rec15 := edi_att3 || edi_tax_qualifier28 || rpad(l_co2_emission,35) || fnd_global.local_chr(10);
            end if;

            if (to_date(substr(l_date_first_registered,1,10),'YYYY/MM/DD') >=
                to_date('1998/01/01','YYYY/MM/DD') and l_mileage_band is null) or
                (l_fuel_type = 'E') then
               p_edi_rec16 := edi_att3 || edi_tax_qualifier30 || rpad(' ',35) || fnd_global.local_chr(10);
            end if;

            if l_engine_cc_for_fuel_charge <> ' ' then
               if l_fuel_type = 'E' then
                  l_engine_cc_for_fuel_charge := '0000';
               end if;
               p_edi_rec17 := edi_att3 || edi_tax_qualifier13 || rpad(l_engine_cc_for_fuel_charge,35) || fnd_global.local_chr(10);
            end if;

            if (to_date(substr(l_date_first_registered,1,10),'YYYY/MM/DD') >=
                to_date('1998/01/01','YYYY/MM/DD')) then
                p_edi_rec18 := edi_att3 || edi_tax_qualifier4 || rpad(l_fuel_type,35) || fnd_global.local_chr(10);
             end if;

             if l_free_fuel_reinstated <> 'N' then
                p_edi_rec19 := edi_att3 || edi_tax_qualifier34 || rpad(' ',35) || fnd_global.local_chr(10);
             end if;

             p_edi_rec20 := edi_dtm2 || edi_dtm375 ||
                            rpad(to_char(to_date(substr(l_date_first_registered,1,10),'YYYY/MM/DD'),'YYYYMMDD'),36) ||
                            edi_dtm102 || fnd_global.local_chr(10);

             if to_number(edi_date_from) > to_number(edi_tax_year_start) then
                p_edi_rec21 := edi_dtm2 || edi_dtm488 || rpad(edi_date_from,36) || edi_dtm102 || fnd_global.local_chr(10);
             end if;

             if to_number(edi_date_to) < to_number(edi_tax_year_end) then
                p_edi_rec22 := edi_dtm2 || edi_dtm489 || rpad(edi_date_to,36) || edi_dtm102 || fnd_global.local_chr(10);
             end if;

             if l_free_fuel_reinstated <> 'N' and to_number(l_cash_equivalent_for_fuel) > 0
                and l_date_free_fuel_withdrawn is not null then
                l_withdrawn_date := substr(l_date_free_fuel_withdrawn,1,4) ||
                                substr(l_date_free_fuel_withdrawn,6,2) ||
                                substr(l_date_free_fuel_withdrawn,9,2);
                p_edi_rec23 := edi_dtm2 || edi_dtmg || rpad(l_withdrawn_date, 36) || edi_dtm102 || fnd_global.local_chr(10);
             end if;
        end if;
  end get_car_or_fuel;
  /******************* Car and Car Fuel (Multi Occurance) ***********************/

  /******************* Car and Car Fuel (Summary) ***********************/
  procedure  get_car_summary(p_value1   in  varchar2,
                             p_value2   in  varchar2,
                             p_edi_rec1 out NOCOPY varchar2,
                             p_edi_rec2 out NOCOPY varchar2,
                             p_edi_rec3 out NOCOPY varchar2,
                             p_edi_rec4 out NOCOPY varchar2,
                             p_edi_rec5 out NOCOPY varchar2)
  is
         edi_ftx1a           varchar2(18);
         edi_tax1            varchar2(6);
         edi_moa1            varchar2(6);
         edi_currency        varchar2(3);
	 edi_cat             varchar2(18);
	 edi_tax_qualifier74 varchar2(3);
	 edi_tax_qualifier75 varchar2(3);
  begin
       edi_cat   := rpad('X',18);
       edi_ftx1a := rpad('FTX1A',6);
       edi_moa1  := rpad('MOA1',6);
       edi_tax1  := rpad('TAX1',6);
       edi_currency := 'GBP';
       edi_tax_qualifier74  := rpad('74',3);
       edi_tax_qualifier75  := rpad('75',3);

       if (to_number(p_value1) >= 1 or
           to_number(p_value2) >= 1)  then

           p_edi_rec1 := edi_ftx1a || edi_cat || rpad(' ',71) || rpad(' ',71) || rpad(' ',70) || fnd_global.local_chr(10);
           p_edi_rec2 := edi_tax1  || edi_tax_qualifier74 || fnd_global.local_chr(10);
           p_edi_rec3 := edi_moa1  || pay_gb_p11d_magtape.format_edi_currency(p_value1) || edi_currency || fnd_global.local_chr(10);
           if to_number(p_value2) >= 0  then
              p_edi_rec4 := edi_tax1  || edi_tax_qualifier75 || fnd_global.local_chr(10);
              p_edi_rec5 := edi_moa1  || pay_gb_p11d_magtape.format_edi_currency(p_value2) || edi_currency || fnd_global.local_chr(10);
           end if;
       end if;
  end get_car_summary;
  /******************* Car and Car Fuel (Summary) ***********************/

  /******************* Vans (Single Occurance) ***********************/
  procedure get_vans(p_person_id in  varchar2,
                     p_emp_ref   in  varchar2,
	    	     p_pact_id   in  varchar2,
                     p_edi_rec1  out NOCOPY varchar2,
                     p_edi_rec2  out NOCOPY varchar2,
                     p_edi_rec3  out NOCOPY varchar2)
  is
         l_cash_equivalent  number;

	 edi_ftx1a           varchar2(6);
         edi_tax1            varchar2(6);
         edi_moa1            varchar2(6);
         edi_currency        varchar2(3);
	 edi_cat             varchar2(18);
	 edi_tax_qualifier12 varchar2(3);

         cursor get_data is
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		           use_index(pai_person,pay_action_information_n2)
			   use_index(pai,pay_action_information_n2) */
		sum(to_number(nvl(pai.action_information15,0))) cash_equivalent
	 from   per_all_assignments_f   paf,
       	    	pay_assignment_actions  paa,
       	        pay_action_information  pai,
       		pay_action_information  pai_person
	 where  paf.person_id = p_person_id
         and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
	 and    paf.assignment_id = paa.assignment_id
	 and    paa.payroll_action_id = p_pact_id
	 and    pai.action_context_id = paa.assignment_action_id
	 and    pai.action_context_type = 'AAP'
	 and    pai.action_information_category = 'VANS 2005'
	 and    pai_person.action_context_id = paa.assignment_action_id
	 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
	 and    upper(pai_person.action_information13) = upper(p_emp_ref)
	 and    pai_person.action_context_type = 'AAP';
  begin
         edi_ftx1a           := rpad('FTX1A',6);
         edi_tax1            := rpad('TAX1',6);
         edi_moa1            := rpad('MOA1',6);
         edi_currency        := 'GBP';
	 edi_cat             := rpad('G',18);
         edi_tax_qualifier12 := rpad('12',3);

         open get_data;
         fetch get_data into l_cash_equivalent;
         close get_data;

         if l_cash_equivalent >= 1 then
            p_edi_rec1  := edi_ftx1a || edi_cat || rpad(' ', 71) || rpad(' ', 71) ||
                           rpad(' ', 70) || fnd_global.local_chr(10);
            p_edi_rec2  := edi_tax1 || edi_tax_qualifier12 || fnd_global.local_chr(10);
            p_edi_rec3  := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_cash_equivalent) ||
			               edi_currency || fnd_global.local_chr(10);
         end if;
  end get_vans;
  /******************* Vans (Single Occurance) ***********************/

  /******************* Interest Free and Low Interest Loan (Multi Occurance) ***********************/
  procedure get_low_int_loan(p_person_id in     varchar2,
                             p_emp_ref   in     varchar2,
                             p_pact_id   in     varchar2,
                             p_ben_count in     varchar2,
                             p_tax_year  in     varchar2,
                             p_value1    in out NOCOPY varchar2,
                             p_edi_rec1  out NOCOPY    varchar2,
                             p_edi_rec2  out NOCOPY    varchar2,
                             p_edi_rec3  out NOCOPY    varchar2,
                             p_edi_rec4  out NOCOPY    varchar2,
                             p_edi_rec5  out NOCOPY    varchar2,
                             p_edi_rec6  out NOCOPY    varchar2,
                             p_edi_rec7  out NOCOPY    varchar2,
                             p_edi_rec8  out NOCOPY    varchar2,
                             p_edi_rec9  out NOCOPY    varchar2)
  is
         l_total_loan            number;
         l_cash_equivalent       number;
         l_date_from             varchar2(10);
         l_date_to               varchar2(10);
         l_date_loan_made        varchar2(50);
         l_date_loan_discharged  varchar2(50);
         l_no_of_borrowers       number;
         l_max_outstanding       number;
         l_total_int_paid        number;
         l_amount_ostd_at_start  number;
         l_amount_ostd_at_end    number;
         l_temp                  number;

         edi_ftx1a           varchar2(6);
         edi_tax1            varchar2(6);
         edi_moa1            varchar2(6);
         edi_currency        varchar2(3);
	 edi_cat             varchar2(18);
	 edi_tax_qualifier2  varchar2(3);
	 edi_tax_qualifier3  varchar2(3);
         edi_tax_qualifier12 varchar2(3);
	 edi_tax_qualifier45 varchar2(3);
	 edi_tax_qualifier72 varchar2(3);
	 edi_qty             varchar2(6);
         edi_qtyg            varchar2(4);
         edi_dtm2            varchar2(6);
         edi_dtm167          varchar2(4);
         edi_dtm168          varchar2(4);
         edi_dtm102          varchar2(3);
         edi_tax_year_start  varchar2(10);
         edi_tax_year_end    varchar2(10);

         cursor get_loan_amount is
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		           use_index(pai_person,pay_action_information_n2)
			   use_index(pai,pay_action_information_n2) */
		sum(to_number(nvl(pai.action_information7,0)))
	 from   per_all_assignments_f   paf,
       	    	pay_assignment_actions  paa,
       		pay_action_information  pai,
       		pay_action_information  pai_person
	 where  paf.person_id = p_person_id
         and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
	 and    paf.assignment_id = paa.assignment_id
	 and    paa.payroll_action_id = p_pact_id
	 and    pai.action_context_id = paa.assignment_action_id
	 and    pai.action_context_type = 'AAP'
	 and    pai.action_information_category = 'INT FREE AND LOW INT LOANS'
	 and    pai_person.action_context_id = paa.assignment_action_id
	 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
	 and    upper(pai_person.action_information13) = upper(p_emp_ref)
	 and    pai_person.action_context_type = 'AAP';

         cursor get_data(p_benefit_number number) is
         select *
         from   (
                 select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
	                  use_index(pai_person,pay_action_information_n2)
		          use_index(pai,pay_action_information_n2) */
		        rownum as row_num,
		        to_number(nvl(pai.action_information5,1)) number_of_borrower,
               		to_number(nvl(pai.action_information6,0)) amount_oustanding_at_5th_april,
               		to_number(nvl(pai.action_information7,0)) maximum_amount_outstanding,
               		to_number(nvl(pai.action_information8,0)) total_interest_paid,
               		pai.action_information9                   date_loan_made,
               		pai.action_information10                  date_loan_discharged,
               		to_number(nvl(pai.action_information11,1))cash_equivalent,
               		to_number(nvl(pai.action_information16,1))amount_outstanding_at_year_end
       		 from   per_all_assignments_f   paf,
       			pay_assignment_actions  paa,
       	    		pay_action_information  pai,
       	    		pay_action_information  pai_person
		 where  paf.person_id = p_person_id
                 and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
		 and    paf.assignment_id = paa.assignment_id
		 and    paa.payroll_action_id = p_pact_id
		 and    pai.action_context_id = paa.assignment_action_id
		 and    pai.action_context_type = 'AAP'
		 and    pai.action_information_category = 'INT FREE AND LOW INT LOANS'
		 and    pai_person.action_context_id = paa.assignment_action_id
		 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
		 and    upper(pai_person.action_information13) = upper(p_emp_ref)
		 and    pai_person.action_context_type = 'AAP')
	 where row_num = p_benefit_number;
  begin

       if to_number(p_value1) < 1 then
          open get_loan_amount;
          fetch get_loan_amount into l_total_loan;
          close get_loan_amount;

          p_value1 := to_char(l_total_loan);
       end if;

       if to_number(p_value1) > 5000 then

          edi_cat   := rpad('H',18);
          edi_ftx1a := rpad('FTX1A',6);
          edi_moa1  := rpad('MOA1',6);
          edi_tax1  := rpad('TAX1',6);
          edi_currency := 'GBP';
          edi_tax_qualifier2   := rpad('2',3);
          edi_tax_qualifier3   := rpad('3',3);
          edi_tax_qualifier12  := rpad('12',3);
          edi_tax_qualifier45  := rpad('45',3);
          edi_tax_qualifier72  := rpad('72',3);
          edi_qty    := rpad('QTY0',6);
          edi_qtyg   := rpad('G',4);
          edi_dtm2   := rpad('DTM2',6);
          edi_dtm167 := rpad('167',4);
          edi_dtm168 := rpad('168',4);
          edi_dtm102 := rpad('102',3);

          open get_data(to_number(p_ben_count));
          fetch get_data into l_temp,
		                      l_no_of_borrowers,
                              l_amount_ostd_at_start,
                              l_max_outstanding,
                              l_total_int_paid ,
                              l_date_loan_made,
                              l_date_loan_discharged,
                              l_cash_equivalent,
                              l_amount_ostd_at_end;
          close get_data;

          if to_number(l_cash_equivalent) > 0 then
             edi_tax_year_start := p_tax_year || '0406';
             edi_tax_year_end   := p_tax_year || '0405';

             if l_date_loan_made is not null then
                l_date_from := substr(l_date_loan_made,1,4) ||
                               substr(l_date_loan_made,6,2) ||
                               substr(l_date_loan_made,9,2);
                if to_number(l_date_from) < to_number(edi_tax_year_start) then
                   l_date_from := ' ';
                end if;
             end if;

             if l_date_loan_discharged is not null then
                l_date_to  := substr(l_date_loan_discharged,1,4) ||
                              substr(l_date_loan_discharged,6,2) ||
                              substr(l_date_loan_discharged,9,2);
                if to_number(l_date_to) > to_number(edi_tax_year_end) then
                   l_date_to := ' ';
                end if;
             end if;

             p_edi_rec1 := edi_ftx1a || edi_cat || rpad(' ', 71) || rpad(' ', 71) || rpad(' ',70) ||  fnd_global.local_chr(10);
             p_edi_rec2 := edi_tax1 || edi_tax_qualifier2  || fnd_global.local_chr(10) || edi_moa1 ||
                           pay_gb_p11d_magtape.format_edi_currency(l_amount_ostd_at_start) || edi_currency || fnd_global.local_chr(10);
             p_edi_rec3 := edi_tax1 || edi_tax_qualifier3  || fnd_global.local_chr(10) || edi_moa1 ||
                           pay_gb_p11d_magtape.format_edi_currency(l_amount_ostd_at_end) || edi_currency || fnd_global.local_chr(10);
             p_edi_rec4 := edi_tax1 || edi_tax_qualifier45 || fnd_global.local_chr(10) || edi_moa1 ||
                           pay_gb_p11d_magtape.format_edi_currency(l_max_outstanding) || edi_currency || fnd_global.local_chr(10);
             p_edi_rec5 := edi_tax1 || edi_tax_qualifier72 || fnd_global.local_chr(10) || edi_moa1 ||
                           pay_gb_p11d_magtape.format_edi_currency(l_total_int_paid) || edi_currency || fnd_global.local_chr(10);
             p_edi_rec6 := edi_tax1 || edi_tax_qualifier12 || fnd_global.local_chr(10) || edi_moa1 ||
                           pay_gb_p11d_magtape.format_edi_currency(l_cash_equivalent) || edi_currency || fnd_global.local_chr(10);

             if l_no_of_borrowers > 1 then
                p_edi_rec7 := edi_qty || edi_qtyg || lpad(l_no_of_borrowers,15,0) || fnd_global.local_chr(10);
             end if;

             if l_date_from <> ' ' then
                p_edi_rec8 := edi_dtm2 || edi_dtm167 ||
                              rpad(to_char(to_date(substr(l_date_loan_made,1,10),'YYYY/MM/DD'),'YYYYMMDD'),36) ||
                              edi_dtm102 || fnd_global.local_chr(10);
             end if;

             if l_date_to <> ' ' then
                p_edi_rec9 := edi_dtm2 || edi_dtm168 ||
                              rpad(to_char(to_date(substr(l_date_loan_discharged,1,10),'YYYY/MM/DD'),'YYYYMMDD'),36) ||
                              edi_dtm102 || fnd_global.local_chr(10);
             end if;
          end if;
       end if;
  end get_low_int_loan;
  /******************* Interest Free and Low Interest Loan (Multi Occurance) ***********************/

  /******************* Private Medical Treatment or Insurance (Single Occurance) ***********************/
  procedure  get_pvt_med_or_ins(p_person_id in  varchar2,
                                p_emp_ref   in  varchar2,
                                p_pact_id   in  varchar2,
			        p_edi_rec1  out NOCOPY varchar2,
                                p_edi_rec2  out NOCOPY varchar2,
                                p_edi_rec3  out NOCOPY varchar2,
                                p_edi_rec4  out NOCOPY varchar2,
                                p_edi_rec5  out NOCOPY varchar2,
                                p_edi_rec6  out NOCOPY varchar2,
                                p_edi_rec7  out NOCOPY varchar2)
  is
         l_cash_equivalent number;
         l_cost_to_you     number;
         l_amount_m_good   number;

         edi_ftx1a           varchar2(6);
         edi_tax1            varchar2(6);
         edi_moa1            varchar2(6);
         edi_currency        varchar2(3);
	 edi_cat             varchar2(18);
	 edi_tax_qualifier1  varchar2(3);
	 edi_tax_qualifier12 varchar2(3);
         edi_tax_qualifier13 varchar2(3);

         cursor get_data is
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
	                  use_index(pai_person,pay_action_information_n2)
		          use_index(pai,pay_action_information_n2) */
		sum(to_number(nvl(pai.action_information7,0))) cash_equivalent,
                sum(to_number(nvl(pai.action_information5,0))) cost_to_you,
                sum(to_number(nvl(pai.action_information6,0))) amount_m_good
         from   per_all_assignments_f   paf,
       	    	pay_assignment_actions  paa,
       	        pay_action_information  pai,
       	        pay_action_information  pai_person
	 where  paf.person_id = p_person_id
         and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
	 and    paf.assignment_id = paa.assignment_id
	 and    paa.payroll_action_id = p_pact_id
	 and    pai.action_context_id = paa.assignment_action_id
	 and    pai.action_context_type = 'AAP'
	 and    pai.action_information_category = 'PVT MED TREATMENT OR INSURANCE'
	 and    pai_person.action_context_id = paa.assignment_action_id
	 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
	 and    upper(pai_person.action_information13) = upper(p_emp_ref)
	 and    pai_person.action_context_type = 'AAP';
  begin
         edi_ftx1a           := rpad('FTX1A',6);
         edi_tax1            := rpad('TAX1',6);
         edi_moa1            := rpad('MOA1',6);
         edi_currency        := 'GBP';
         edi_cat             := rpad('I',18);
         edi_tax_qualifier1  := rpad('1',3);
         edi_tax_qualifier12 := rpad('12',3);
         edi_tax_qualifier13 := rpad('13',3);

         open get_data;
         fetch get_data into l_cash_equivalent,
                             l_cost_to_you,
                             l_amount_m_good;
         close get_data;

         if l_cash_equivalent >= 1 then
            l_cost_to_you := l_cash_equivalent + l_amount_m_good;
         end if;

         if l_cash_equivalent >= 1 then
            p_edi_rec1  := edi_ftx1a || edi_cat || rpad(' ', 71) || rpad(' ', 71) ||
                           rpad(' ', 70) || fnd_global.local_chr(10);
            p_edi_rec2  := edi_tax1 || edi_tax_qualifier13 || fnd_global.local_chr(10);
            p_edi_rec3  := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_cost_to_you) ||
			               edi_currency || fnd_global.local_chr(10);
            p_edi_rec4  := edi_tax1 || edi_tax_qualifier1 || fnd_global.local_chr(10);
            p_edi_rec5  := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_amount_m_good) ||
			               edi_currency || fnd_global.local_chr(10);
            p_edi_rec6  := edi_tax1 || edi_tax_qualifier12 || fnd_global.local_chr(10);
            p_edi_rec7  := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_cash_equivalent) ||
			               edi_currency || fnd_global.local_chr(10);
         end if;
  end get_pvt_med_or_ins;
  /******************* Private Medical Treatment or Insurance (Single Occurance) ***********************/

  /******************* Qualifying Relocation Expenses Payments and Benefits (Single Occurance) ***********************/
  procedure get_relocation(p_person_id in  varchar2,
                           p_emp_ref   in  varchar2,
                           p_pact_id   in  varchar2,
                           p_edi_rec1  out NOCOPY varchar2,
                           p_edi_rec2  out NOCOPY varchar2,
                           p_edi_rec3  out NOCOPY varchar2)
  is
         l_cash_equivalent  number;

	 edi_ftx1a           varchar2(6);
         edi_tax1            varchar2(6);
         edi_moa1            varchar2(6);
         edi_currency        varchar2(3);
	 edi_cat             varchar2(18);
	 edi_tax_qualifier64 varchar2(3);

         cursor get_data is
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		                  use_index(pai_person,pay_action_information_n2)
			          use_index(pai,pay_action_information_n2) */
		sum(to_number(nvl(pai.action_information5,0))) cash_equivalent
         from   per_all_assignments_f   paf,
       	    	pay_assignment_actions  paa,
       	        pay_action_information  pai,
       	        pay_action_information  pai_person
	 where  paf.person_id = p_person_id
         and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
	 and    paf.assignment_id = paa.assignment_id
	 and    paa.payroll_action_id = p_pact_id
	 and    pai.action_context_id = paa.assignment_action_id
	 and    pai.action_context_type = 'AAP'
	 and    pai.action_information_category = 'RELOCATION EXPENSES'
	 and    pai_person.action_context_id = paa.assignment_action_id
	 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
	 and    upper(pai_person.action_information13) = upper(p_emp_ref)
	 and    pai_person.action_context_type = 'AAP';
  begin
         edi_ftx1a           := rpad('FTX1A',6);
         edi_tax1            := rpad('TAX1',6);
         edi_moa1            := rpad('MOA1',6);
         edi_currency        := 'GBP';
	 edi_cat             := rpad('J',18);
         edi_tax_qualifier64 := rpad('64',3);

         open get_data;
         fetch get_data into l_cash_equivalent;
         close get_data;

         if l_cash_equivalent >= 1 then
            p_edi_rec1  := edi_ftx1a || edi_cat || rpad(' ', 71) || rpad(' ', 71) ||
                           rpad(' ', 70) || fnd_global.local_chr(10);
            p_edi_rec2  := edi_tax1 || edi_tax_qualifier64 || fnd_global.local_chr(10);
            p_edi_rec3  := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_cash_equivalent) ||
			               edi_currency || fnd_global.local_chr(10);
         end if;
  end get_relocation;
  /******************* Qualifying Relocation Expenses Payments and Benefits (Single Occurance) ***********************/

  /******************* Services Supplied (Single Occurance) ***********************/
  procedure  get_service_supplied(p_person_id in  varchar2,
                                  p_emp_ref   in  varchar2,
                                  p_pact_id   in  varchar2,
	  		          p_edi_rec1  out NOCOPY varchar2,
                                  p_edi_rec2  out NOCOPY varchar2,
                                  p_edi_rec3  out NOCOPY varchar2,
                                  p_edi_rec4  out NOCOPY varchar2,
                                  p_edi_rec5  out NOCOPY varchar2,
                                  p_edi_rec6  out NOCOPY varchar2,
                                  p_edi_rec7  out NOCOPY varchar2)
  is
         l_cash_equivalent number;
         l_cost_to_you     number;
         l_amount_m_good   number;

         edi_ftx1a           varchar2(6);
         edi_tax1            varchar2(6);
         edi_moa1            varchar2(6);
         edi_currency        varchar2(3);
	 edi_cat             varchar2(18);
	 edi_tax_qualifier1  varchar2(3);
	 edi_tax_qualifier12 varchar2(3);
         edi_tax_qualifier13 varchar2(3);

         cursor get_data is
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
	                  use_index(pai_person,pay_action_information_n2)
		          use_index(pai,pay_action_information_n2) */
		sum(to_number(nvl(pai.action_information7,0))) cash_equivalent,
                sum(to_number(nvl(pai.action_information5,0))) cost_to_you,
                sum(to_number(nvl(pai.action_information6,0))) amount_m_good
         from   per_all_assignments_f   paf,
       	    	pay_assignment_actions  paa,
       	        pay_action_information  pai,
       	        pay_action_information  pai_person
	 where  paf.person_id = p_person_id
         and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
	 and    paf.assignment_id = paa.assignment_id
	 and    paa.payroll_action_id = p_pact_id
	 and    pai.action_context_id = paa.assignment_action_id
	 and    pai.action_context_type = 'AAP'
	 and    pai.action_information_category = 'SERVICES SUPPLIED'
	 and    pai_person.action_context_id = paa.assignment_action_id
	 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
	 and    upper(pai_person.action_information13) = upper(p_emp_ref)
	 and    pai_person.action_context_type = 'AAP';
  begin
         edi_ftx1a           := rpad('FTX1A',6);
         edi_tax1            := rpad('TAX1',6);
         edi_moa1            := rpad('MOA1',6);
         edi_currency        := 'GBP';
         edi_cat             := rpad('K',18);
         edi_tax_qualifier1  := rpad('1',3);
         edi_tax_qualifier12 := rpad('12',3);
         edi_tax_qualifier13 := rpad('13',3);

         open get_data;
         fetch get_data into l_cash_equivalent,
                             l_cost_to_you,
                             l_amount_m_good;
         close get_data;

         if l_cash_equivalent >= 1 then
            l_cost_to_you := l_cash_equivalent + l_amount_m_good;
         end if;

         if l_cash_equivalent >= 1 then
            p_edi_rec1  := edi_ftx1a || edi_cat || rpad(' ', 71) || rpad(' ', 71) ||
                           rpad(' ', 70) || fnd_global.local_chr(10);
            p_edi_rec2  := edi_tax1 || edi_tax_qualifier13 || fnd_global.local_chr(10);
            p_edi_rec3  := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_cost_to_you) ||
			               edi_currency || fnd_global.local_chr(10);
            p_edi_rec4  := edi_tax1 || edi_tax_qualifier1 || fnd_global.local_chr(10);
            p_edi_rec5  := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_amount_m_good) ||
			               edi_currency || fnd_global.local_chr(10);
            p_edi_rec6  := edi_tax1 || edi_tax_qualifier12 || fnd_global.local_chr(10);
            p_edi_rec7  := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_cash_equivalent) ||
			               edi_currency || fnd_global.local_chr(10);
         end if;
  end get_service_supplied;
  /******************* Services Supplied (Single Occurance) ***********************/

  /******************* Assets Placed at The Employee's Disposal (Multi Occurance) ***********************/
  procedure  get_assets_at_emp(p_person_id in  varchar2,
                               p_emp_ref   in  varchar2,
                               p_pact_id   in  varchar2,
                               p_edi_rec1  out NOCOPY varchar2,
                               p_edi_rec2  out NOCOPY varchar2,
                               p_edi_rec3  out NOCOPY varchar2,
                               p_edi_rec4  out NOCOPY varchar2,
                               p_edi_rec5  out NOCOPY varchar2,
                               p_edi_rec6  out NOCOPY varchar2,
                               p_edi_rec7  out NOCOPY varchar2,
                               p_edi_rec8  out NOCOPY varchar2,
                               p_edi_rec9  out NOCOPY varchar2,
                               p_edi_rec10 out NOCOPY varchar2,
                               p_edi_rec11 out NOCOPY varchar2,
                               p_edi_rec12 out NOCOPY varchar2,
                               p_edi_rec13 out NOCOPY varchar2,
                               p_edi_rec14 out NOCOPY varchar2,
                               p_edi_rec15 out NOCOPY varchar2,
                               p_edi_rec16 out NOCOPY varchar2)
  is
         type r_assets is record(
         description       varchar2(70),
         annual_value      varchar2(70),
         cash_equivalent   varchar2(70),
         amount_made_good  varchar2(70));

         type t_assets is table of r_assets index by binary_integer;
         type t_edi_record  is table of varchar2(255) index by binary_integer;

         assets       t_assets;
         edi_record   t_edi_record;
         l_edi        number;
         l_index      number;
         l_count      number;
         l_total      number;
         l_annual     number;

         edi_ftx1a           varchar2(6);
         edi_tax1            varchar2(6);
         edi_moa1            varchar2(6);
         edi_currency        varchar2(3);
         edi_cat             varchar2(18);
         edi_tax_qualifier1  varchar2(3);
         edi_tax_qualifier7  varchar2(3);
         edi_tax_qualifier12 varchar2(3);
         edi_tax_qualifier116 varchar2(3);

         cursor get_data is
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
	                  use_index(pai_person,pay_action_information_n2)
		          use_index(pai,pay_action_information_n2) */
		sum(to_number(nvl(pai.action_information7,0))) annual_value,
       		sum(to_number(nvl(pai.action_information8,0))) amount_made_good,
       	        sum(to_number(nvl(pai.action_information9,0))) cash_equivalent,
          	pay_gb_p11d_magtape.get_description(pai.action_information5,'GB_ASSETS',
                                                 		pai.action_information4) asset_type
         from   per_all_assignments_f   paf,
       	    	pay_assignment_actions  paa,
       	        pay_action_information  pai,
                pay_action_information  pai_person
	 where  paf.person_id = p_person_id
         and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
	 and    paf.assignment_id = paa.assignment_id
	 and    paa.payroll_action_id = p_pact_id
	 and    pai.action_context_id = paa.assignment_action_id
	 and    pai.action_context_type = 'AAP'
	 and    pai.action_information_category = 'ASSETS AT EMP DISPOSAL'
	 and    pai_person.action_context_id = paa.assignment_action_id
	 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
	 and    upper(pai_person.action_information13) = upper(p_emp_ref)
	 and    pai_person.action_context_type = 'AAP'
	 group by pay_gb_p11d_magtape.get_description(pai.action_information5,'GB_ASSETS',
                                                		pai.action_information4);
  begin
         edi_cat   := rpad('L',18);
         edi_ftx1a := rpad('FTX1A',6);
         edi_moa1  := rpad('MOA1',6);
         edi_tax1  := rpad('TAX1',6);
         edi_currency := 'GBP';
         edi_tax_qualifier1   := rpad('1',3);
         edi_tax_qualifier7   := rpad('7',3);
         edi_tax_qualifier12  := rpad('12',3);
         edi_tax_qualifier116 := rpad('116',3);

         l_total := 0;
         l_count := 0;
         for asset in get_data loop
             hr_utility.trace('Asset : ' || asset.asset_type );
             hr_utility.trace('Cash : ' || asset.cash_equivalent );
             if asset.cash_equivalent >= 1 then
                l_count  := l_count + 1;
                l_total  := l_total + asset.cash_equivalent;
                l_annual := asset.cash_equivalent + asset.amount_made_good;
                assets(l_count).description      := substr(asset.asset_type,1,70);
                assets(l_count).annual_value     := pay_gb_p11d_magtape.format_edi_currency(l_annual);
                assets(l_count).cash_equivalent  := pay_gb_p11d_magtape.format_edi_currency(asset.cash_equivalent);
                assets(l_count).amount_made_good := pay_gb_p11d_magtape.format_edi_currency(asset.amount_made_good);
             end if;
         end loop;

         l_edi := 0;
         --- This can repeat up to 7 times
         for l_index in 1..l_count loop
             l_edi := l_edi + 1;
             edi_record(l_edi) := edi_ftx1a || edi_cat || rpad(assets(l_index).description, 71) || rpad(' ', 71) || rpad(' ',70) || fnd_global.local_chr(10);
             l_edi := l_edi + 1;
             edi_record(l_edi) := edi_tax1  || edi_tax_qualifier7  || fnd_global.local_chr(10)   ||
                                  edi_moa1  || assets(l_index).annual_value     || edi_currency || fnd_global.local_chr(10) ||
                                  edi_tax1  || edi_tax_qualifier1  || fnd_global.local_chr(10)   ||
                                  edi_moa1  || assets(l_index).amount_made_good || edi_currency || fnd_global.local_chr(10) ||
                                  edi_tax1  || edi_tax_qualifier12 || fnd_global.local_chr(10)   ||
                                  edi_moa1  || assets(l_index).cash_equivalent  || edi_currency || fnd_global.local_chr(10);
         end loop;

	 if (l_total >= 1) then
	    edi_cat   := rpad('S',18);
	    l_edi := l_edi + 1;
            edi_record(l_edi) := edi_ftx1a || edi_cat || rpad(' ',71) || rpad(' ',71) || rpad(' ',70) || fnd_global.local_chr(10);
            l_edi := l_edi + 1;
            edi_record(l_edi) := edi_tax1  || edi_tax_qualifier116 || fnd_global.local_chr(10) || edi_moa1 ||
                                 pay_gb_p11d_magtape.format_edi_currency(l_total) || edi_currency || fnd_global.local_chr(10);
         end if;

	 -- Maximum output is 16 + 1 edi records
	 l_edi := l_edi + 1;
         for l_index in l_edi..17 loop
             edi_record(l_index) := null;
         end loop;

         p_edi_rec1  := edi_record(1);
         p_edi_rec2  := edi_record(2);
         p_edi_rec3  := edi_record(3);
         p_edi_rec4  := edi_record(4);
         p_edi_rec5  := edi_record(5);
         p_edi_rec6  := edi_record(6);
         p_edi_rec7  := edi_record(7);
         p_edi_rec8  := edi_record(8);
         p_edi_rec9  := edi_record(9);
         p_edi_rec10 := edi_record(10);
         p_edi_rec11 := edi_record(11);
         p_edi_rec12 := edi_record(12);
         p_edi_rec13 := edi_record(13);
         p_edi_rec14 := edi_record(14);
         p_edi_rec15 := edi_record(15);
         p_edi_rec16 := edi_record(16);
  end get_assets_at_emp;
  /******************* Assets Placed at The Employee's Disposal (Multi Occurance) ***********************/

  /******************* Other Items (Multi Occurance) ***********************/
  procedure  get_other_items(p_person_id in  varchar2,
                             p_emp_ref   in  varchar2,
                             p_pact_id   in  varchar2,
                             p_edi_rec1  out NOCOPY varchar2,
                             p_edi_rec2  out NOCOPY varchar2,
                             p_edi_rec3  out NOCOPY varchar2,
                             p_edi_rec4  out NOCOPY varchar2,
                             p_edi_rec5  out NOCOPY varchar2,
                             p_edi_rec6  out NOCOPY varchar2,
                             p_edi_rec7  out NOCOPY varchar2,
                             p_edi_rec8  out NOCOPY varchar2,
                             p_edi_rec9  out NOCOPY varchar2,
                             p_edi_rec10 out NOCOPY varchar2,
                             p_edi_rec11 out NOCOPY varchar2,
                             p_edi_rec12 out NOCOPY varchar2,
                             p_edi_rec13 out NOCOPY varchar2,
                             p_edi_rec14 out NOCOPY varchar2,
                             p_edi_rec15 out NOCOPY varchar2,
                             p_edi_rec16 out NOCOPY varchar2,
                             p_edi_rec17 out NOCOPY varchar2,
                             p_edi_rec18 out NOCOPY varchar2,
                             p_edi_rec19 out NOCOPY varchar2,
                             p_edi_rec20 out NOCOPY varchar2,
                             p_edi_rec21 out NOCOPY varchar2,
                             p_edi_rec22 out NOCOPY varchar2)
  is
         type r_other_items is record(
         description       varchar2(70),
         cost_to_you       varchar2(70),
         cash_equivalent   varchar2(70),
         amount_made_good  varchar2(70));

         type t_other_items is table of r_other_items index by binary_integer;
         type t_edi_record  is table of varchar2(255) index by binary_integer;

         class_1A      t_other_items;
         non_class_1A  t_other_items;
         edi_record     t_edi_record;
         l_edi                number;
         l_index              number;
         o1A_count            number;
         non_1A_count         number;
         l_count              number;
         o1A_total            number;
         non_1a_total         number;
         dir_total            number;
         o1a_desc             varchar2(50);
         non1a_desc           varchar2(50);
         edi_ftx1a            varchar2(6);
         edi_tax1             varchar2(6);
         edi_moa1             varchar2(6);
         edi_currency         varchar2(3);
	 edi_cat              varchar2(18);
	 edi_desc             varchar2(71);
         edi_tax_qualifier56  varchar2(3);
         edi_tax_qualifier57  varchar2(3);
         edi_tax_qualifier58  varchar2(3);
         edi_tax_qualifier109 varchar2(3);
         edi_tax_qualifier110 varchar2(3);
         edi_tax_qualifier111 varchar2(3);
         edi_tax_qualifier118 varchar2(3);
         edi_tax_qualifier119 varchar2(3);
         edi_tax_qualifier120 varchar2(3);

         cursor get_data(p_category varchar2, p_lookup varchar2) is
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
                  use_index(pai_person,pay_action_information_n2)
	          use_index(pai,pay_action_information_n2) */
		sum(to_number(nvl(pai.action_information9,0))) cash_equivalent,
                sum(to_number(nvl(pai.action_information7,0))) cost_to_you,
                sum(to_number(nvl(pai.action_information8,0))) amount_made_good,
                pay_gb_p11d_magtape.get_description(pai.action_information5,
                            p_lookup, pai.action_information4) description
         from   per_all_assignments_f   paf,
       	    	pay_assignment_actions  paa,
       	        pay_action_information  pai,
          	pay_action_information  pai_person
	 where  paf.person_id = p_person_id
         and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
	 and    paf.assignment_id = paa.assignment_id
	 and    paa.payroll_action_id = p_pact_id
	 and    pai.action_context_id = paa.assignment_action_id
	 and    pai.action_context_type = 'AAP'
	 and    pai.action_information_category = p_category
	 and    pai_person.action_context_id = paa.assignment_action_id
	 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
	 and    upper(pai_person.action_information13) = upper(p_emp_ref)
	 and    pai_person.action_context_type = 'AAP'
         group by pay_gb_p11d_magtape.get_description(pai.action_information5,
                            p_lookup, pai.action_information4);
    begin
         edi_cat   := rpad('M',18);
         edi_ftx1a := rpad('FTX1A',6);
         edi_moa1  := rpad('MOA1',6);
         edi_tax1  := rpad('TAX1',6);
         edi_currency := 'GBP';
         edi_desc  := rpad('DESC',71);
         edi_tax_qualifier56  := rpad('56',3);
         edi_tax_qualifier57  := rpad('57',3);
         edi_tax_qualifier58  := rpad('58',3);
         edi_tax_qualifier109 := rpad('109',3);
         edi_tax_qualifier110 := rpad('110',3);
         edi_tax_qualifier111 := rpad('111',3);
         edi_tax_qualifier118 := rpad('118',3);
         edi_tax_qualifier119 := rpad('119',3);
         edi_tax_qualifier120 := rpad('120',3);

         o1A_count := 0;
         o1A_total := 0;
         for o1a in get_data('OTHER ITEMS','GB_OTHER_ITEMS')loop
             if o1a.cash_equivalent >= 1 then
                o1A_count := o1A_count + 1;
                o1A_total := o1A_total + o1a.cash_equivalent;
                class_1A(o1A_count).description      := o1a.description;
                class_1A(o1A_count).cost_to_you      := pay_gb_p11d_magtape.format_edi_currency(o1a.cost_to_you);
                class_1A(o1A_count).cash_equivalent  := pay_gb_p11d_magtape.format_edi_currency(o1a.cash_equivalent);
                class_1A(o1A_count).amount_made_good := pay_gb_p11d_magtape.format_edi_currency(o1a.amount_made_good);
             end if;
         end loop;

         non_1A_count := 0;
         non_1A_total := 0;
         dir_total    := 0;
         for non1a in get_data('OTHER ITEMS NON 1A','GB_OTHER_ITEMS_NON_1A')loop
             if non1a.description = 'DIRECTOR TAX PAID NOT DEDUCTED' then
                dir_total := dir_total + non1a.cash_equivalent;
             else
                if non1a.cash_equivalent >= 1 then
                   non_1A_count := non_1A_count + 1;
                   non_1A_total := non_1A_total + non1a.cash_equivalent;
                   non_class_1A(non_1A_count).description      := non1a.description;
                   non_class_1A(non_1A_count).cost_to_you      := pay_gb_p11d_magtape.format_edi_currency(non1a.cost_to_you);
                   non_class_1A(non_1A_count).cash_equivalent  := pay_gb_p11d_magtape.format_edi_currency(non1a.cash_equivalent);
                   non_class_1A(non_1A_count).amount_made_good := pay_gb_p11d_magtape.format_edi_currency(non1a.amount_made_good);
                end if;
             end if;
         end loop;

         l_count := greatest(o1A_count, non_1A_count);
         l_edi := 0;
         /*** This can repeat up to 6 times ***/
         for l_index in 1..l_count loop
             o1a_desc   := ' ';
             non1a_desc := ' ';
             if l_index <= o1A_count then
                o1a_desc := class_1A(l_index).description;
             end if;
             if l_index <= non_1A_count then
                non1a_desc := non_class_1A(l_index).description;
             end if;
             l_edi := l_edi + 1;
             edi_record(l_edi) := edi_ftx1a || edi_cat || edi_desc || rpad(o1a_desc,71) ||
                                  rpad(non1a_desc,70) || fnd_global.local_chr(10);
             if o1a_desc <> ' ' then
                l_edi := l_edi + 1;
                edi_record(l_edi) := edi_tax1 || edi_tax_qualifier58    || fnd_global.local_chr(10)      || edi_moa1 ||
                                     class_1A(l_index).cost_to_you      || edi_currency || fnd_global.local_chr(10)  ||
                             		 edi_tax1 || edi_tax_qualifier56    || fnd_global.local_chr(10)      || edi_moa1 ||
                             		 class_1A(l_index).amount_made_good || edi_currency || fnd_global.local_chr(10)  ||
                             	 	 edi_tax1 || edi_tax_qualifier57    || fnd_global.local_chr(10)      || edi_moa1 ||
                             		 class_1A(l_index).cash_equivalent  || edi_currency || fnd_global.local_chr(10);
             end if;

             if non1a_desc <> ' ' then
                l_edi := l_edi + 1;
                edi_record(l_edi) := edi_tax1 || edi_tax_qualifier111   || fnd_global.local_chr(10)      || edi_moa1 ||
                             		 non_class_1A(l_index).cost_to_you  || edi_currency || fnd_global.local_chr(10)  ||
                             		 edi_tax1 || edi_tax_qualifier109   || fnd_global.local_chr(10)      || edi_moa1 ||
                             		 non_class_1A(l_index).amount_made_good || edi_currency || fnd_global.local_chr(10)  ||
                             		 edi_tax1 || edi_tax_qualifier110       || fnd_global.local_chr(10)      || edi_moa1 ||
                             		 non_class_1A(l_index).cash_equivalent  || edi_currency || fnd_global.local_chr(10);
             end if;
         end loop;

         if (o1A_total    >= 1 or
             dir_total    >= 1 or
             non_1A_total >= 1   ) then
             edi_cat := rpad('T',18);
             l_edi := l_edi + 1;
             edi_record(l_edi) := edi_ftx1a || edi_cat || rpad(' ',71) || rpad(' ',71) || rpad(' ',70) || fnd_global.local_chr(10);
             l_edi := l_edi + 1;
             edi_record(l_edi) := edi_tax1 || edi_tax_qualifier118 || fnd_global.local_chr(10) || edi_moa1 ||
                                  pay_gb_p11d_magtape.format_edi_currency(o1A_total) || edi_currency || fnd_global.local_chr(10);
             l_edi := l_edi + 1;
             edi_record(l_edi) := edi_tax1 || edi_tax_qualifier119 || fnd_global.local_chr(10) || edi_moa1 ||
                                  pay_gb_p11d_magtape.format_edi_currency(non_1A_total) || edi_currency || fnd_global.local_chr(10);
             l_edi := l_edi + 1;
             edi_record(l_edi) := edi_tax1 || edi_tax_qualifier120 || fnd_global.local_chr(10) || edi_moa1 ||
                                  pay_gb_p11d_magtape.format_edi_currency(dir_total) || edi_currency || fnd_global.local_chr(10);
         end if;

         -- Total output edi record is 22 + 1 records
         l_edi := l_edi + 1;
         for l_index in l_edi..23 loop
             edi_record(l_index) := null;
         end loop;

         p_edi_rec1  := edi_record(1);
         p_edi_rec2  := edi_record(2);
         p_edi_rec3  := edi_record(3);
         p_edi_rec4  := edi_record(4);
         p_edi_rec5  := edi_record(5);
         p_edi_rec6  := edi_record(6);
         p_edi_rec7  := edi_record(7);
         p_edi_rec8  := edi_record(8);
         p_edi_rec9  := edi_record(9);
         p_edi_rec10 := edi_record(10);
         p_edi_rec11 := edi_record(11);
         p_edi_rec12 := edi_record(12);
         p_edi_rec13 := edi_record(13);
         p_edi_rec14 := edi_record(14);
         p_edi_rec15 := edi_record(15);
         p_edi_rec16 := edi_record(16);
         p_edi_rec17 := edi_record(17);
         p_edi_rec18 := edi_record(18);
         p_edi_rec19 := edi_record(19);
         p_edi_rec20 := edi_record(20);
         p_edi_rec21 := edi_record(21);
         p_edi_rec22 := edi_record(22);
  end get_other_items;
  /******************* Other Items (Multi Occurance) ***********************/

  /******************* Expenses Payments Made To or On Behalf of The Employee (Single Occurance) ***********************/
  procedure  get_exp_payment(p_person_id  in  varchar2,
                             p_emp_ref    in  varchar2,
                             p_pact_id   in  varchar2,
                             p_edi_rec1   out NOCOPY varchar2,
                             p_edi_rec2   out NOCOPY varchar2,
                             p_edi_rec3   out NOCOPY varchar2,
                             p_edi_rec4   out NOCOPY varchar2,
                             p_edi_rec5   out NOCOPY varchar2,
                             p_edi_rec6   out NOCOPY varchar2,
                             p_edi_rec7   out NOCOPY varchar2,
                             p_edi_rec8   out NOCOPY varchar2,
                             p_edi_rec9   out NOCOPY varchar2,
                             p_edi_rec10  out NOCOPY varchar2,
                             p_edi_rec11  out NOCOPY varchar2,
                             p_edi_rec12  out NOCOPY varchar2,
                             p_edi_rec13  out NOCOPY varchar2,
                             p_edi_rec14  out NOCOPY varchar2,
                             p_edi_rec15  out NOCOPY varchar2,
                             p_edi_rec16  out NOCOPY varchar2,
                             p_edi_rec17  out NOCOPY varchar2,
                             p_edi_rec18  out NOCOPY varchar2,
                             p_edi_rec19  out NOCOPY varchar2,
                             p_edi_rec20  out NOCOPY varchar2)
  is
	 l_trvlnsubs_cost_to_you      number;
         l_trvlnsubs_amount_made_good number;
         l_trvlnsubs_cash_equivalent  number;
         l_entertain_cost_to_you      number;
         l_entertain_amount_made_good number;
         l_entertain_cash_equivalent  number;
         l_bustrvl_cost_to_you        number;
         l_bustrvl_amount_made_good   number;
         l_bustrvl_cash_equivalent    number;
         l_hometel_cost_to_you        number;
         l_hometel_amount_made_good   number;
         l_hometel_cash_equivalent    number;
         l_nonqreloc_cost_to_you      number;
         l_nonqreloc_amount_made_good number;
         l_nonqreloc_cash_equivalent  number;
         l_other_cost_to_you          number;
         l_other_amount_made_good     number;
         l_other_cash_equivalent      number;
         l_other_description          varchar2(255);
         l_trading_indicator          varchar2(255);
         edi_cat             varchar2(18);
         edi_ftx1a           varchar2(18);
         edi_tax1            varchar2(6);
         edi_moa1            varchar2(6);
         edi_currency        varchar2(3);
         edi_att3            varchar2(6);
	 edi_tax_qualifier3  varchar2(4);
	 edi_tax_qualifier25 varchar2(3);
	 edi_tax_qualifier26 varchar2(3);
	 edi_tax_qualifier27 varchar2(3);
	 edi_tax_qualifier28 varchar2(3);
	 edi_tax_qualifier29 varchar2(3);
	 edi_tax_qualifier30 varchar2(3);
	 edi_tax_qualifier50 varchar2(3);
	 edi_tax_qualifier51 varchar2(3);
	 edi_tax_qualifier52 varchar2(3);
	 edi_tax_qualifier53 varchar2(3);
	 edi_tax_qualifier54 varchar2(3);
	 edi_tax_qualifier55 varchar2(3);
	 edi_tax_qualifier85 varchar2(3);
	 edi_tax_qualifier86 varchar2(3);
	 edi_tax_qualifier87 varchar2(3);
	 edi_tax_qualifier88 varchar2(3);
	 edi_tax_qualifier89 varchar2(3);
	 edi_tax_qualifier90 varchar2(3);

         cursor get_data
         is
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		                  use_index(pai_person,pay_action_information_n2)
			          use_index(pai,pay_action_information_n2) */
		to_number(pai.action_information6)  cost_to_you,
                to_number(pai.action_information7)  amount_m_good,
                to_number(pai.action_information8)  cash_equivalent,
                pay_gb_p11d_magtape.get_description(pai.action_information5,'GB_EXPENSE_TYPE',
                                                    pai.action_information4) expense_type,
                nvl(pai.action_information10,'N') trading_indicator
         from   per_all_assignments_f   paf,
       	    	pay_assignment_actions  paa,
       		    pay_action_information  pai,
       		    pay_action_information  pai_person
		 where  paf.person_id = p_person_id
         and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
		 and    paf.assignment_id = paa.assignment_id
		 and    paa.payroll_action_id = p_pact_id
		 and    pai.action_context_id = paa.assignment_action_id
		 and    pai.action_context_type = 'AAP'
		 and    pai.action_information_category = 'EXPENSES PAYMENTS'
		 and    pai_person.action_context_id = paa.assignment_action_id
		 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
		 and    upper(pai_person.action_information13) = upper(p_emp_ref)
		 and    pai_person.action_context_type = 'AAP';
  begin
        edi_cat      := rpad('N',18);
        edi_ftx1a    := rpad('FTX1A',6);
        edi_moa1     := rpad('MOA1',6);
        edi_tax1     := rpad('TAX1',6);
        edi_currency := 'GBP';
        edi_att3     := rpad('ATT3',6);
        edi_tax_qualifier3   := rpad('3',4);
        edi_tax_qualifier25  := rpad('25',3);
        edi_tax_qualifier26  := rpad('26',3);
        edi_tax_qualifier27  := rpad('27',3);
        edi_tax_qualifier28  := rpad('28',3);
        edi_tax_qualifier29  := rpad('29',3);
        edi_tax_qualifier30  := rpad('30',3);
        edi_tax_qualifier50  := rpad('50',3);
        edi_tax_qualifier51  := rpad('51',3);
        edi_tax_qualifier52  := rpad('52',3);
        edi_tax_qualifier53  := rpad('53',3);
        edi_tax_qualifier54  := rpad('54',3);
        edi_tax_qualifier55  := rpad('55',3);
        edi_tax_qualifier85  := rpad('85',3);
        edi_tax_qualifier86  := rpad('86',3);
        edi_tax_qualifier87  := rpad('87',3);
        edi_tax_qualifier88  := rpad('88',3);
        edi_tax_qualifier89  := rpad('89',3);
        edi_tax_qualifier90  := rpad('90',3);
        l_trvlnsubs_cost_to_you      := 0;
        l_trvlnsubs_amount_made_good := 0;
        l_trvlnsubs_cash_equivalent  := 0;
        l_entertain_cost_to_you      := 0;
        l_entertain_amount_made_good := 0;
        l_entertain_cash_equivalent  := 0;
        l_bustrvl_cost_to_you        := 0;
        l_bustrvl_amount_made_good   := 0;
        l_bustrvl_cash_equivalent    := 0;
        l_hometel_cost_to_you        := 0;
        l_hometel_amount_made_good   := 0;
        l_hometel_cash_equivalent    := 0;
        l_nonqreloc_cost_to_you      := 0;
        l_nonqreloc_amount_made_good := 0;
        l_nonqreloc_cash_equivalent  := 0;
        l_other_cost_to_you          := 0;
        l_other_amount_made_good     := 0;
        l_other_cash_equivalent      := 0;

        l_other_description := ' ';

        for expense in get_data loop
            if expense.expense_type = 'TRAVEL AND SUBSISTENCE' then
               l_trvlnsubs_cost_to_you      := l_trvlnsubs_cost_to_you + expense.cost_to_you;
               l_trvlnsubs_amount_made_good := l_trvlnsubs_amount_made_good + expense.amount_m_good;
               l_trvlnsubs_cash_equivalent  := l_trvlnsubs_cash_equivalent + expense.cash_equivalent;
            elsif expense.expense_type = 'ENTERTAINMENT' then
               l_trading_indicator := expense.trading_indicator;
               l_entertain_cost_to_you      := l_entertain_cost_to_you + expense.cost_to_you;
               l_entertain_amount_made_good := l_entertain_amount_made_good + expense.amount_m_good;
               l_entertain_cash_equivalent  := l_entertain_cash_equivalent + expense.cash_equivalent;
            elsif expense.expense_type = 'ALLOWANCE FOR BUSINESS TRAVEL' then
               l_bustrvl_cost_to_you        := l_bustrvl_cost_to_you + expense.cost_to_you;
               l_bustrvl_amount_made_good   := l_bustrvl_amount_made_good + expense.amount_m_good;
               l_bustrvl_cash_equivalent    := l_bustrvl_cash_equivalent + expense.cash_equivalent;
            elsif expense.expense_type = 'USE OF HOME TELEPHONE' then
               l_hometel_cost_to_you        := l_hometel_cost_to_you + expense.cost_to_you;
               l_hometel_amount_made_good   := l_hometel_amount_made_good + expense.amount_m_good;
               l_hometel_cash_equivalent    := l_hometel_cash_equivalent + expense.cash_equivalent;
            elsif expense.expense_type = 'NON-QUALIFYING RELOCATION' then
               l_nonqreloc_cost_to_you      := l_nonqreloc_cost_to_you + expense.cost_to_you;
               l_nonqreloc_amount_made_good := l_nonqreloc_amount_made_good + expense.amount_m_good;
               l_nonqreloc_cash_equivalent  := l_nonqreloc_cash_equivalent + expense.cash_equivalent;
            else
               if l_other_description <> ' ' then
                   l_other_description := 'MULTIPLE' || rpad(' ',30,' ');
               else
                   l_other_description := expense.expense_type || rpad(' ',30,' ');
               end if;
               l_other_cost_to_you          := l_other_cost_to_you + expense.cost_to_you;
               l_other_amount_made_good     := l_other_amount_made_good + expense.amount_m_good;
               l_other_cash_equivalent      := l_other_cash_equivalent + expense.cash_equivalent;
            end if;
        end loop;

        if (l_trvlnsubs_cash_equivalent >= 1 or
            l_entertain_cash_equivalent >= 1 or
            l_bustrvl_cash_equivalent   >= 1 or
            l_hometel_cash_equivalent   >= 1 or
            l_nonqreloc_cash_equivalent >= 1 or
            l_other_cash_equivalent     >= 1) then

            if l_trvlnsubs_cash_equivalent < 1 then
               l_trvlnsubs_cash_equivalent := 0;
            end if;
            if l_entertain_cash_equivalent < 1 then
               l_entertain_cash_equivalent := 0;
            end if;
            if l_bustrvl_cash_equivalent < 1 then
               l_bustrvl_cash_equivalent := 0;
            end if;
            if l_hometel_cash_equivalent < 1 then
               l_hometel_cash_equivalent := 0;
            end if;
            if l_nonqreloc_cash_equivalent < 1 then
               l_nonqreloc_cash_equivalent := 0;
            end if;
            if l_other_cash_equivalent < 1 then
               l_other_cash_equivalent := 0;
            end if;

            p_edi_rec1  := edi_ftx1a || edi_cat || rpad(rpad(l_other_description,30),71) || rpad(' ',71) ||
                           rpad(' ',70) || fnd_global.local_chr(10);
            p_edi_rec2  := edi_tax1 || edi_tax_qualifier86 || fnd_global.local_chr(10) ||
			               edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_trvlnsubs_cost_to_you) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec3  := edi_tax1 || edi_tax_qualifier85 || fnd_global.local_chr(10) ||
			               edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_trvlnsubs_amount_made_good) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec4  := edi_tax1 || edi_tax_qualifier87 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_trvlnsubs_cash_equivalent)  || edi_currency || fnd_global.local_chr(10);
            p_edi_rec5  := edi_tax1 || edi_tax_qualifier26 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_entertain_cost_to_you) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec6  := edi_tax1 || edi_tax_qualifier25 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_entertain_amount_made_good) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec7  := edi_tax1 || edi_tax_qualifier27 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_entertain_cash_equivalent) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec8  := edi_tax1 || edi_tax_qualifier29 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_bustrvl_cost_to_you) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec9  := edi_tax1 || edi_tax_qualifier28 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_bustrvl_amount_made_good) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec10 := edi_tax1 || edi_tax_qualifier30 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_bustrvl_cash_equivalent) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec11 := edi_tax1 || edi_tax_qualifier89 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_hometel_cost_to_you) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec12 := edi_tax1 || edi_tax_qualifier88 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_hometel_amount_made_good) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec13 := edi_tax1 || edi_tax_qualifier90 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_hometel_cash_equivalent) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec14 := edi_tax1 || edi_tax_qualifier51 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_nonqreloc_cost_to_you) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec15 := edi_tax1 || edi_tax_qualifier50 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_nonqreloc_amount_made_good) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec16 := edi_tax1 || edi_tax_qualifier52 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_nonqreloc_cash_equivalent) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec17 := edi_tax1 || edi_tax_qualifier54 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_other_cost_to_you) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec18 := edi_tax1 || edi_tax_qualifier53 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_other_amount_made_good) || edi_currency || fnd_global.local_chr(10);
            p_edi_rec19 := edi_tax1 || edi_tax_qualifier55 || fnd_global.local_chr(10) ||
                           edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_other_cash_equivalent) || edi_currency || fnd_global.local_chr(10);
            if l_entertain_cash_equivalent >= 1 then
               p_edi_rec20 := edi_att3 || edi_tax_qualifier3 || rpad(l_trading_indicator,35) || fnd_global.local_chr(10);
            end if;
        end if;
  end get_exp_payment;
  /******************* Expenses Payments Made To or On Behalf of The Employee (Single Occurance) ***********************/

  /******************* Mileage Allowance Relief Optional Reporting Scheme (Single Occurance) ***********************/
  procedure  get_marors(p_person_id in  varchar2,
                        p_emp_ref    in varchar2,
                        p_pact_id   in  varchar2,
                        p_edi_rec1  out NOCOPY varchar2,
                        p_edi_rec2  out NOCOPY varchar2,
                        p_edi_rec3  out NOCOPY varchar2)
  is
         l_marors    number;

	 edi_ftx1a            varchar2(6);
         edi_tax1             varchar2(6);
         edi_moa1             varchar2(6);
         edi_currency         varchar2(3);
	 edi_cat              varchar2(18);
	 edi_tax_qualifier121 varchar2(3);

         cursor get_data is
         select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
	          use_index(pai_person,pay_action_information_n2)
	          use_index(pai,pay_action_information_n2) */
		sum(to_number(NVL(pai.action_information7, 0))) mileage_allowance
         from   per_all_assignments_f   paf,
       	    	pay_assignment_actions  paa,
       	        pay_action_information  pai,
       	        pay_action_information  pai_person
	 where  paf.person_id = p_person_id
         and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
	 and    paf.assignment_id = paa.assignment_id
	 and    paa.payroll_action_id = p_pact_id
	 and    pai.action_context_id = paa.assignment_action_id
	 and    pai.action_context_type = 'AAP'
	 and    pai.action_information_category = 'MARORS'
	 and    pai_person.action_context_id = paa.assignment_action_id
	 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
	 and    upper(pai_person.action_information13) = upper(p_emp_ref)
	 and    pai_person.action_context_type = 'AAP';
  begin
         edi_cat   := rpad('U',18);
         edi_ftx1a := rpad('FTX1A',6);
         edi_moa1  := rpad('MOA1',6);
         edi_tax1  := rpad('TAX1',6);
         edi_currency := 'GBP';
         edi_tax_qualifier121  := rpad('121',3);

         open get_data;
         fetch get_data into l_marors;
         close get_data;

         if l_marors <= -1 then
            p_edi_rec1  := edi_ftx1a || edi_cat || rpad(' ', 71) || rpad(' ', 71) ||
                           rpad(' ', 70) || fnd_global.local_chr(10);
            p_edi_rec2  := edi_tax1 || edi_tax_qualifier121 || fnd_global.local_chr(10);
            p_edi_rec3  := edi_moa1 || pay_gb_p11d_magtape.format_edi_currency(l_marors) ||
                           edi_currency || fnd_global.local_chr(10);
         end if;
  end get_marors;
  /******************* Mileage Allowance Relief Optional Reporting Scheme (Single Occurance) ***********************/

  /******************** END PRIVATE FUNCTIONS/PROCEDURES ********************/

  /******************* BEGIN PUBLIC FUNCTIONS/PROCEDURES ********************/
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
		       p_edi_rec6          out NoCopy varchar2) return number
  is
       edi_header_identifier varchar2(4);
       edi_header_version    varchar2(4);
       edi_data_type         varchar2(8);
       edi_data_type_version varchar2(4);
       edi_data_type_release varchar2(1);
       edi_sender_id         varchar2(35);
       edi_recipient_id      varchar2(35);
       edi_test_indicator    varchar2(1);
       edi_urgent_marker     varchar2(1);
       edi_transmission_date varchar2(8);
       edi_transmission_time varchar2(6);
       edi_unique_reference  varchar2(14);
       edi_sender_sub_addr   varchar2(14);
       edi_recipient_s_addr  varchar2(14);
       edi_bgm1              varchar2(6);
       edi_form_type         varchar2(3);
  begin
       edi_header_identifier := '****';
       edi_header_version    := '001A';
       edi_data_type         := rpad('P11D' ||  substr(p_tax_year,3,4),8);
       edi_data_type_version := rpad('1.0',4);
       edi_data_type_release := ' ';
       edi_sender_id         := upper(rpad(p_sender_id,35));
       edi_recipient_id      := rpad('INLAND REVENUE',35);
       edi_test_indicator    := ' ';
       edi_urgent_marker     := ' ';
       edi_transmission_date := substr(p_transmission_date,1,8);
       edi_transmission_time := substr(p_transmission_date,9,6);
       edi_unique_reference  := lpad(p_unique_reference,14,'0');
       edi_sender_sub_addr   := rpad(' ',14);
       edi_recipient_s_addr  := rpad(' ',14);
       edi_bgm1         := rpad('BGM1',6);
       edi_form_type    := rpad('12',3);

       if p_test_transmission = 'Y' then
          edi_test_indicator := '1';
       end if;

       /* Perform EDI validation */
       if (edi_sender_id = ' ' or edi_sender_id is null) then
           p_error_msg1  := ':Sender ID missing.';
           p_missing_val := p_missing_val + 1;
       elsif pay_gb_eoy_magtape.validate_input(edi_sender_id,'FULL_EDI') > 0 then
           p_error_msg1  := ':Sender ID contains illegal character(s)';
           p_error_count := p_error_count + 1;
       end if;

       /* Header Record */
       p_edi_rec1 :=  edi_header_identifier || edi_header_version    || edi_data_type        ||
                      edi_data_type_version || edi_data_type_release || edi_sender_id        ||
                      edi_recipient_id      || edi_test_indicator    || edi_urgent_marker    ||
                      edi_transmission_date || edi_transmission_time || edi_unique_reference ||
                      edi_sender_sub_addr   || edi_recipient_s_addr  || fnd_global.local_chr(10);

       /* BGM1 Record */
       p_edi_rec2 := edi_bgm1 || edi_form_type || fnd_global.local_chr(10);

       return 0;
  end get_header;

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
			 p_edi_rec12        out NoCopy varchar2) return number
  is
       edi_att1                varchar2(6);
       edi_att_qualifier1      varchar2(4);
       edi_att_qualifier7      varchar2(4);
       edi_att_qualifier17     varchar2(4);
       edi_date_qualifier166   varchar2(4);
       edi_date_qualifier243   varchar2(4);
       edi_dtm1                varchar2(6);
       edi_format_qualifier102 varchar2(3);
       edi_format_qualifier602 varchar2(3);
       edi_nad1a               varchar2(6);
       edi_nad1b               varchar2(6);
       edi_party_qualifier_bg  varchar2(4);
       edi_party_qualifier_tc  varchar2(4);
       edi_uns1                varchar2(5);
       edi_addr1               varchar2(255);
       edi_addr2               varchar2(255);
       edi_addr3               varchar2(255);
       edi_addr4               varchar2(255);
       ref_id                  number;
       l_wrap_point            number;
  begin
       edi_att1                := rpad('ATT1',6);
       edi_att_qualifier1      := rpad('1',4);
       edi_att_qualifier7      := rpad('7',4);
       edi_att_qualifier17     := rpad('17',4);
       edi_date_qualifier166   := rpad('166',4);
       edi_date_qualifier243   := rpad('243',4);
       edi_dtm1                := rpad('DTM1',6);
       edi_format_qualifier102 := '102';
       edi_format_qualifier602 := '602';
       edi_nad1a               := rpad('NAD1A',6);
       edi_nad1b               := rpad('NAD1B',6);
       edi_party_qualifier_bg  := rpad('BG',4);
       edi_party_qualifier_tc  := rpad('TC',4);
       edi_uns1                := rpad('UNS1',5);

       edi_addr1 := p_employer_addr;

       if length(edi_addr1) > 35 then
          l_wrap_point := instr(edi_addr1,',', 34 - length(edi_addr1));
          if l_wrap_point = 0 then
             l_wrap_point := 35;
          end if;
          edi_addr2 := ltrim(substr(edi_addr1, 1 + l_wrap_point),' ,');
          edi_addr1 := substr(edi_addr1, 1, l_wrap_point);
       end if;
       if length(edi_addr2) > 35 then
          l_wrap_point := instr(edi_addr2,',', 34 - length(edi_addr2));
          if l_wrap_point = 0 then
             l_wrap_point := 35;
          end if;
          edi_addr3 := ltrim(substr(edi_addr2, 1 + l_wrap_point),' ,');
          edi_addr2 := substr(edi_addr2, 1, l_wrap_point);
       end if;
       if length(edi_addr3) > 35 then
          l_wrap_point := instr(edi_addr3,',', 34 - length(edi_addr2));
          if l_wrap_point = 0 then
             l_wrap_point := 35;
          end if;
          edi_addr4 := ltrim(substr(edi_addr3, 1 + l_wrap_point),' ,');
          edi_addr3 := substr(edi_addr3, 1, l_wrap_point);
       end if;

       /* Perform EDI validation */
       /* Validations are now done at archive level
       if pay_gb_eoy_magtape.validate_input(to_number(substr(p_employer_ref,1,3)),'NUMBER') > 0 then
          p_error_msg1  := ':Tax District ' || substr(p_employer_ref,1,3) || ' is non-numeric';
          p_error_count := p_error_count + 1;
       end if;
       if pay_gb_eoy_magtape.validate_input(p_employer_addr,'EDI_SURNAME') > 0 then
          p_error_msg2  := ':Employers Address contains illegal character(s) for ' ||
                           'Tax Ref : ' || p_employer_ref;
          p_error_count := p_error_count + 1;
       end if;
       if pay_gb_eoy_magtape.validate_input(p_employer_addr,'EDI_SURNAME') > 0 then
          p_error_msg3  := ':Employers Name contains illegal character(s) for ' ||
                           'Tax Ref : ' || p_employer_ref;
          p_error_count := p_error_count + 1;
       end if;
       */

       ref_id :=  to_number(nvl(substr(p_employer_ref,1,3),0));
       if ref_id < 1 or ref_id > 999 then
          p_error_msg1  := ':HMRC Office number ' || substr(p_employer_ref,1,3) || ' must be between 001 to 999';
          p_error_count := p_error_count + 1;
       end if;

       p_edi_rec1 := edi_nad1a           || edi_party_qualifier_bg ||
                     rpad(nvl(edi_addr1,' '), 36) || rpad(nvl(edi_addr2,' '), 36) || rpad(nvl(edi_addr3,' '), 36) ||
                     rpad(nvl(edi_addr4,' '), 36) || rpad(' ', 35)       || fnd_global.local_chr(10);
       p_edi_rec2 := edi_nad1b   || rpad(upper(p_party), 36)  ||
                     rpad(' ',9) || fnd_global.local_chr(10);
       p_edi_rec3 := edi_att1  || edi_att_qualifier1 || rpad(p_submitter_ref,35) || fnd_global.local_chr(10);
       p_edi_rec4 := edi_att1  || edi_att_qualifier7 || rpad(substr(p_employer_ref,5),35)  || fnd_global.local_chr(10);
       p_edi_rec5 := edi_nad1a || edi_party_qualifier_tc || rpad(' ', 179) || fnd_global.local_chr(10);
       p_edi_rec6 := edi_att1  || edi_att_qualifier17 || rpad(substr(p_employer_ref,1,3),35) || fnd_global.local_chr(10);
       p_edi_rec7 := edi_dtm1  || edi_date_qualifier243 || rpad(p_message_date,36) ||
                     edi_format_qualifier102 || fnd_global.local_chr(10);
       p_edi_rec8 := edi_dtm1  || edi_date_qualifier166 || rpad(p_tax_year,36) ||
                     edi_format_qualifier602 || fnd_global.local_chr(10);
       p_edi_rec9 := edi_uns1  || fnd_global.local_chr(10);

       return 0;
  end get_employer;

  function  get_employee(p_person_id     in     varchar2,
  			 p_pact_id       in     varchar2,
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
			 p_edi_rec8      out NoCopy varchar2) return number
  is
       edi_att2                varchar2(6);
       edi_att_qualifier3      varchar2(4);
       edi_att_qualifier11     varchar2(4);
       edi_att_qualifier19     varchar2(4);
       edi_nad2a               varchar2(6);
       edi_nad2b               varchar2(6);
       edi_party_qualifier_bv  varchar2(4);
       l_pact_id               number;
       l_assact_id             number;
       l_ni_number             varchar2(11);
       l_first_name            varchar2(80);
       l_middle_name           varchar2(80);
       l_last_name             varchar2(80);
       l_dir_flag              varchar2(2);
       l_employee_no           varchar2(30);
       l_addr1                 varchar2(255);
       l_addr2                 varchar2(255);
       l_addr3                 varchar2(255);
       l_addr4                 varchar2(255);
       l_addr5                 varchar2(255);

       cursor get_assact_id(p_pact_id number) is
       select action_context_id
       from   pay_assignment_actions paa,
              pay_action_information pai
       where  paa.payroll_action_id = p_pact_id
       and    pai.action_context_id = paa.assignment_action_id
       and    pai.action_information_category = 'ADDRESS DETAILS'
       and    pai.action_information14 = 'Employee Address'
       and    pai.action_information1  = p_person_id
       and    pai.action_context_type = 'AAP';

       cursor get_details(p_act_id number) is
       select NVL(SUBSTR(UPPER(pai_gb.action_information8), 1, 36), ' '),  -- last name
              NVL(SUBSTR(UPPER(pai_gb.action_information6), 1, 36), ' '),  -- first name
              NVL(SUBSTR(UPPER(pai_gb.action_information7), 1, 36), ' '),  -- middle name
              NVL(UPPER(pai_gb.action_information4), 'N'),                 -- dir flag
              NVL(UPPER(pai_gb.action_information11), ' '),               -- emp no
              NVL(UPPER(pai_gb.action_information12), 'NONE'),             -- NI
              NVL(UPPER(pai_person.action_information5), ' '),                    -- addr line 1
              NVL(UPPER(pai_person.action_information6), ' '),                    -- addr line 2
              NVL(UPPER(pai_person.action_information7), ' '),                    -- addr line 3
              NVL(UPPER(pai_person.action_information8), ' '),                    -- addr line 4
              NVL(UPPER(hl.meaning), ' ')                                         -- addr line 5
       from   pay_action_information pai_gb,
              pay_action_information pai_person,
              hr_lookups hl
       where  pai_person.action_context_id = p_act_id
       and    pai_person.action_information_category = 'ADDRESS DETAILS'
       and    pai_person.action_information14 = 'Employee Address'
       and    pai_person.action_context_type = 'AAP'
       and    pai_gb.action_context_id = pai_person.action_context_id
       and    pai_gb.action_information_category = 'GB EMPLOYEE DETAILS'
       and    pai_gb.action_context_type = 'AAP'
       and    hl.lookup_type(+) = 'GB_COUNTY'
       and    hl.lookup_code(+) = pai_person.action_information9;
  begin
       edi_att2                := rpad('ATT2',6);
       edi_att_qualifier3      := rpad('3',4);
       edi_att_qualifier11     := rpad('11',4);
       edi_att_qualifier19     := rpad('19',4);
       edi_nad2a               := rpad('NAD2A',6);
       edi_nad2b               := rpad('NAD2B',6);
       edi_party_qualifier_bv  := rpad('BV',4);

       l_pact_id := p_pact_id;

       open get_assact_id(l_pact_id);
       fetch get_assact_id into l_assact_id;
       close get_assact_id;

       open get_details(l_assact_id);
       fetch get_details into l_last_name,
                              l_first_name,
                              l_middle_name,
                              l_dir_flag,
                              l_employee_no,
                              l_ni_number,
                              l_addr1,
                              l_addr2,
                              l_addr3,
                              l_addr4,
                              l_addr5;
       close get_details;

       if substr(l_ni_number,1,2) = 'TN' then
          l_ni_number := 'NONE';
       end if;

       /* EDI Validations are removed, this is now done at archive level*/
       /*
       if pay_gb_eoy_magtape.validate_input(l_last_name,'EDI_SURNAME') > 0 then
          p_error_msg1  := ':Illegal Character for last name for employee id ' || l_employee_no;
          p_error_count := p_error_count + 1;
       end if;
       if pay_gb_eoy_magtape.validate_input(l_first_name,'EDI_SURNAME') > 0 then
          p_error_msg2  := ':Illegal Character for first name for employee id ' || l_employee_no;
          p_error_count := p_error_count + 1;
       end if;
       if pay_gb_eoy_magtape.validate_input(l_middle_name,'EDI_SURNAME') > 0 then
          p_error_msg3  := ':Illegal Character for middle name for employee id ' || l_employee_no;
          p_error_count := p_error_count + 1;
       end if;
       if pay_gb_eoy_magtape.validate_input(l_addr1,'EDI_SURNAME') > 0 then
          p_error_msg4  := ':Employee id ' || l_employee_no || ' has illegal Character(s) in Address Line1' ;
          p_error_count := p_error_count + 1;
       end if;
       if pay_gb_eoy_magtape.validate_input(l_addr2,'EDI_SURNAME') > 0 then
          p_error_msg5  := ':Employee id ' || l_employee_no || ' has illegal Character(s) in Address Line3' ;
          p_error_count := p_error_count + 1;
       end if;
       if pay_gb_eoy_magtape.validate_input(l_addr3,'EDI_SURNAME') > 0 then
          p_error_msg6  := ':Employee id ' || l_employee_no || ' has illegal Character(s) in Address Line3' ;
          p_error_count := p_error_count + 1;
       end if;
       if pay_gb_eoy_magtape.validate_input(l_addr4,'EDI_SURNAME') > 0 then
          p_error_msg7  := ':Employee id ' || l_employee_no || ' has illegal Character(s) in Address Line4' ;
          p_error_count := p_error_count + 1;
       end if;
       if pay_gb_eoy_magtape.validate_input(l_addr5,'EDI_SURNAME') > 0 then
          p_error_msg8  := ':Employee id ' || l_employee_no || ' has illegal Character(s) in Address Line5' ;
          p_error_count := p_error_count + 1;
       end if;
       */
       p_edi_rec1 :=  edi_nad2a      || edi_party_qualifier_bv ||
                      rpad(upper(rpad(l_addr1,35)),36) || rpad(upper(rpad(l_addr2,35)),36) ||
                      rpad(upper(rpad(l_addr3,35)),36) || rpad(upper(rpad(l_addr4,35)),36) ||
                      rpad(upper(rpad(l_addr5,35)),35) || fnd_global.local_chr(10);
       p_edi_rec2 :=  edi_nad2b  || rpad(l_last_name,36) ||
                      rpad(l_first_name,36) || rpad(l_middle_name,36) ||
                      rpad(' ', 36) || rpad(' ',36) || rpad(' ',9) || fnd_global.local_chr(10);
       p_edi_rec3 :=  edi_att2 || edi_att_qualifier11 || rpad(l_ni_number,35) || fnd_global.local_chr(10);
       p_edi_rec4 :=  edi_att2 || edi_att_qualifier19 || rpad(l_employee_no,35) || fnd_global.local_chr(10);
       if substr(l_dir_flag,1,1) = 'Y' then
          p_edi_rec5 := edi_att2 || edi_att_qualifier3 || rpad(' ',35) || fnd_global.local_chr(10);
       end if;

       return 0;
  end get_employee;

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
                        p_edi_rec30     out NoCopy varchar2) return number
  is
  begin
       if p_benefit_type = 'ASSETS TRANSFERRED' then
          hr_utility.trace('Assets Transferred');
          get_asset_transferred(p_person_id  => p_person_id,
                                p_emp_ref    => p_employer_ref,
                                p_pact_id    => p_pact_id,
                                p_edi_rec1   => p_edi_rec1,
                                p_edi_rec2   => p_edi_rec2,
                                p_edi_rec3   => p_edi_rec3,
                                p_edi_rec4   => p_edi_rec4,
                                p_edi_rec5   => p_edi_rec5,
                                p_edi_rec6   => p_edi_rec6,
                                p_edi_rec7   => p_edi_rec7,
                                p_edi_rec8   => p_edi_rec8,
                                p_edi_rec9   => p_edi_rec9,
                                p_edi_rec10  => p_edi_rec10,
                                p_edi_rec11  => p_edi_rec11,
                                p_edi_rec12  => p_edi_rec12,
                                p_edi_rec13  => p_edi_rec13,
                                p_edi_rec14  => p_edi_rec14,
                                p_edi_rec15  => p_edi_rec15,
                                p_edi_rec16  => p_edi_rec16,
                                p_edi_rec17  => p_edi_rec17,
                                p_edi_rec18  => p_edi_rec18,
                                p_edi_rec19  => p_edi_rec19,
                                p_edi_rec20  => p_edi_rec20,
                                p_edi_rec21  => p_edi_rec21,
                                p_edi_rec22  => p_edi_rec22);
          return 0;
       end if;
       if p_benefit_type = 'PAYMENTS MADE FOR EMP' then
          hr_utility.trace('Payment made for employee');
          get_payments_for_emp(p_person_id  => p_person_id,
                               p_emp_ref    => p_employer_ref,
                               p_pact_id    => p_pact_id,
                               p_edi_rec1   => p_edi_rec1,
                               p_edi_rec2   => p_edi_rec2,
                               p_edi_rec3   => p_edi_rec3,
                               p_edi_rec4   => p_edi_rec4,
                               p_edi_rec5   => p_edi_rec5,
                               p_edi_rec6   => p_edi_rec6,
                               p_edi_rec7   => p_edi_rec7,
                               p_edi_rec8   => p_edi_rec8,
                               p_edi_rec9   => p_edi_rec9,
                               p_edi_rec10  => p_edi_rec10,
                               p_edi_rec11  => p_edi_rec11,
                               p_edi_rec12  => p_edi_rec12,
                               p_edi_rec13  => p_edi_rec13,
                               p_edi_rec14  => p_edi_rec14,
                               p_edi_rec15  => p_edi_rec15,
                               p_edi_rec16  => p_edi_rec16,
                               p_edi_rec17  => p_edi_rec17);
          return 0;
       end if;
       if p_benefit_type = 'VOUCHERS OR CREDIT CARDS' then
          hr_utility.trace('Voucher');
          get_voucher_n_creditcard(p_person_id => p_person_id,
                                   p_emp_ref   => p_employer_ref,
                                   p_pact_id   => p_pact_id,
				   p_edi_rec1  => p_edi_rec1,
                                   p_edi_rec2  => p_edi_rec2,
                                   p_edi_rec3  => p_edi_rec3,
                                   p_edi_rec4  => p_edi_rec4,
                                   p_edi_rec5  => p_edi_rec5,
                                   p_edi_rec6  => p_edi_rec6,
                                   p_edi_rec7  => p_edi_rec7);
	      return 0;
	   end if;
       if p_benefit_type = 'LIVING ACCOMMODATION' then
          hr_utility.trace('Living accommodation');
          get_living_accommodation(p_person_id => p_person_id,
                                   p_emp_ref   => p_employer_ref,
                                   p_pact_id    => p_pact_id,
                                   p_edi_rec1  => p_edi_rec1,
                                   p_edi_rec2  => p_edi_rec2,
                                   p_edi_rec3  => p_edi_rec3);
          return 0;
       end if;
       if p_benefit_type = 'MILEAGE ALLOWANCE AND PPAYMENT' then
          hr_utility.trace('Mileage allowance and prepayment');
          get_mileage_allowance(p_person_id => p_person_id,
                                p_emp_ref   => p_employer_ref,
                                p_pact_id    => p_pact_id,
                                p_edi_rec1  => p_edi_rec1,
                                p_edi_rec2  => p_edi_rec2,
                                p_edi_rec3  => p_edi_rec3);
          return 0;
       end if;
       if p_benefit_type = 'CAR AND CAR FUEL 2003_04' then
          hr_utility.trace('Car');
          get_car_or_fuel(p_person_id  => p_person_id,
                          p_emp_ref    => p_employer_ref,
                          p_pact_id    => p_pact_id,
                          p_tax_year   => p_tax_year,
                          p_ben_count  => p_benefit_count,
                          p_value1     => p_value1,
                          p_value2     => p_value2,
			  p_edi_rec1   => p_edi_rec1,
                          p_edi_rec2   => p_edi_rec2,
                          p_edi_rec3   => p_edi_rec3,
                          p_edi_rec4   => p_edi_rec4,
                          p_edi_rec5   => p_edi_rec5,
                          p_edi_rec6   => p_edi_rec6,
                          p_edi_rec7   => p_edi_rec7,
                          p_edi_rec8   => p_edi_rec8,
                          p_edi_rec9   => p_edi_rec9,
                          p_edi_rec10  => p_edi_rec10,
                          p_edi_rec11  => p_edi_rec11,
                          p_edi_rec12  => p_edi_rec12,
                          p_edi_rec13  => p_edi_rec13,
                          p_edi_rec14  => p_edi_rec14,
                          p_edi_rec15  => p_edi_rec15,
                          p_edi_rec16  => p_edi_rec16,
                          p_edi_rec17  => p_edi_rec17,
                          p_edi_rec18  => p_edi_rec18,
                          p_edi_rec19  => p_edi_rec19,
                          p_edi_rec20  => p_edi_rec20,
                          p_edi_rec21  => p_edi_rec21,
                          p_edi_rec22  => p_edi_rec22,
                          p_edi_rec23  => p_edi_rec23);
            return 0;
	   end if;
       if p_benefit_type = 'VANS 2005' then
          hr_utility.trace('Vans');
          get_vans(p_person_id => p_person_id,
                   p_emp_ref   => p_employer_ref,
                   p_pact_id    => p_pact_id,
                   p_edi_rec1  => p_edi_rec1,
                   p_edi_rec2  => p_edi_rec2,
                   p_edi_rec3  => p_edi_rec3);
          return 0;
       end if;
       if p_benefit_type = 'INT FREE AND LOW INT LOANS' then
          hr_utility.trace('Loans');
          get_low_int_loan(p_person_id  => p_person_id,
                           p_emp_ref    => p_employer_ref,
                           p_pact_id    => p_pact_id,
                           p_ben_count  => p_benefit_count,
                           p_tax_year   => p_tax_year,
                           p_value1     => p_value1,
                           p_edi_rec1   => p_edi_rec1,
                           p_edi_rec2   => p_edi_rec2,
                           p_edi_rec3   => p_edi_rec3,
			   p_edi_rec4   => p_edi_rec4,
			   p_edi_rec5   => p_edi_rec5,
			   p_edi_rec6   => p_edi_rec6,
                           p_edi_rec7   => p_edi_rec7,
                           p_edi_rec8   => p_edi_rec8,
                           p_edi_rec9   => p_edi_rec9);
          return 0;
       end if;
       if p_benefit_type = 'PVT MED TREATMENT OR INSURANCE' then
          hr_utility.trace('Insurance');
          get_pvt_med_or_ins(p_person_id => p_person_id,
                             p_emp_ref   => p_employer_ref,
                             p_pact_id   => p_pact_id,
       			     p_edi_rec1  => p_edi_rec1,
                             p_edi_rec2  => p_edi_rec2,
                             p_edi_rec3  => p_edi_rec3,
                             p_edi_rec4  => p_edi_rec4,
                             p_edi_rec5  => p_edi_rec5,
                             p_edi_rec6  => p_edi_rec6,
                             p_edi_rec7  => p_edi_rec7);
	   return 0;
        end if;
       if p_benefit_type = 'RELOCATION EXPENSES' then
          hr_utility.trace('Relocation expenses');
          get_relocation(p_person_id => p_person_id,
                         p_emp_ref   => p_employer_ref,
                         p_pact_id   => p_pact_id,
			 p_edi_rec1  => p_edi_rec1,
                         p_edi_rec2  => p_edi_rec2,
                         p_edi_rec3  => p_edi_rec3);
          return 0;
       end if;
       if p_benefit_type = 'SERVICES SUPPLIED' then
          hr_utility.trace('Service supplied');
          get_service_supplied(p_person_id => p_person_id,
                               p_emp_ref   => p_employer_ref,
                               p_pact_id   => p_pact_id,
              		       p_edi_rec1  => p_edi_rec1,
                               p_edi_rec2  => p_edi_rec2,
                               p_edi_rec3  => p_edi_rec3,
                               p_edi_rec4  => p_edi_rec4,
                               p_edi_rec5  => p_edi_rec5,
                               p_edi_rec6  => p_edi_rec6,
                               p_edi_rec7  => p_edi_rec7);
          return 0;
       end if;
       if p_benefit_type = 'ASSETS AT EMP DISPOSAL' then
          hr_utility.trace('Assets at employee disposal');
          get_assets_at_emp(p_person_id  => p_person_id,
                            p_emp_ref    => p_employer_ref,
                            p_pact_id    => p_pact_id,
                            p_edi_rec1   => p_edi_rec1,
                            p_edi_rec2   => p_edi_rec2,
                            p_edi_rec3   => p_edi_rec3,
			    p_edi_rec4   => p_edi_rec4,
			    p_edi_rec5   => p_edi_rec5,
			    p_edi_rec6   => p_edi_rec6,
                            p_edi_rec7   => p_edi_rec7,
                            p_edi_rec8   => p_edi_rec8,
                            p_edi_rec9   => p_edi_rec9,
                            p_edi_rec10  => p_edi_rec10,
                            p_edi_rec11  => p_edi_rec11,
                            p_edi_rec12  => p_edi_rec12,
                            p_edi_rec13  => p_edi_rec13,
                            p_edi_rec14  => p_edi_rec14,
                            p_edi_rec15  => p_edi_rec15,
                            p_edi_rec16  => p_edi_rec16);
          return 0;
       end if;
       if p_benefit_type = 'OTHER ITEMS' then
          hr_utility.trace('Other Items');
          get_other_items(p_person_id  => p_person_id,
                          p_emp_ref    => p_employer_ref,
                          p_pact_id    => p_pact_id,
                          p_edi_rec1   => p_edi_rec1,
                          p_edi_rec2   => p_edi_rec2,
                          p_edi_rec3   => p_edi_rec3,
			  p_edi_rec4   => p_edi_rec4,
			  p_edi_rec5   => p_edi_rec5,
			  p_edi_rec6   => p_edi_rec6,
                          p_edi_rec7   => p_edi_rec7,
                          p_edi_rec8   => p_edi_rec8,
                          p_edi_rec9   => p_edi_rec9,
                          p_edi_rec10  => p_edi_rec10,
                          p_edi_rec11  => p_edi_rec11,
                          p_edi_rec12  => p_edi_rec12,
                          p_edi_rec13  => p_edi_rec13,
                          p_edi_rec14  => p_edi_rec14,
                          p_edi_rec15  => p_edi_rec15,
                          p_edi_rec16  => p_edi_rec16,
                          p_edi_rec17  => p_edi_rec17,
                          p_edi_rec18  => p_edi_rec18,
                          p_edi_rec19  => p_edi_rec19,
                          p_edi_rec20  => p_edi_rec20,
                          p_edi_rec21  => p_edi_rec21,
                          p_edi_rec22  => p_edi_rec22);
          return 0;
       end if;
       if p_benefit_type = 'EXPENSES PAYMENTS' then
	  hr_utility.trace('Expenses Payments');
          get_exp_payment(p_person_id  => p_person_id,
                          p_emp_ref    => p_employer_ref,
                          p_pact_id    => p_pact_id,
                          p_edi_rec1   => p_edi_rec1,
                          p_edi_rec2   => p_edi_rec2,
                          p_edi_rec3   => p_edi_rec3,
                          p_edi_rec4   => p_edi_rec4,
                          p_edi_rec5   => p_edi_rec5,
                          p_edi_rec6   => p_edi_rec6,
                          p_edi_rec7   => p_edi_rec7,
                          p_edi_rec8   => p_edi_rec8,
                          p_edi_rec9   => p_edi_rec9,
                          p_edi_rec10  => p_edi_rec10,
                          p_edi_rec11  => p_edi_rec11,
                          p_edi_rec12  => p_edi_rec12,
                          p_edi_rec13  => p_edi_rec13,
                          p_edi_rec14  => p_edi_rec14,
                          p_edi_rec15  => p_edi_rec15,
                          p_edi_rec16  => p_edi_rec16,
                          p_edi_rec17  => p_edi_rec17,
                          p_edi_rec18  => p_edi_rec18,
                          p_edi_rec19  => p_edi_rec19,
                          p_edi_rec20  => p_edi_rec20);
          return 0;
       end if;
       if p_benefit_type = 'MARORS' then
          hr_utility.trace('Marrors');
          get_marors(p_person_id  => p_person_id,
                     p_emp_ref    => p_employer_ref,
                     p_pact_id    => p_pact_id,
                     p_edi_rec1   => p_edi_rec1,
                     p_edi_rec2   => p_edi_rec2,
                     p_edi_rec3   => p_edi_rec3);
          return 0;
       end if;
       return 0;
  end get_benefit;

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
                        p_edi_rec30     out NoCopy varchar2) return number
  is
  begin
       if p_benefit_type = 'CAR AND CAR FUEL 2003_04' then
          get_car_summary(p_value1   => p_value1,
                          p_value2   => p_value2,
                          p_edi_rec1 => p_edi_rec1,
                          p_edi_rec2 => p_edi_rec2,
                          p_edi_rec3 => p_edi_rec3,
                          p_edi_rec4 => p_edi_rec4,
                          p_edi_rec5 => p_edi_rec5);
	  return 0;
       end if;
       return 0;
  end get_summary;

  function  get_footer(p_record_count in  varchar2,
                       p_error_count  in  varchar2,
                       p_missing_val  in  varchar2,
                       p_error_msg1   out NoCopy varchar2,
                       p_error_msg2   out NoCopy varchar2,
                       p_edi_rec1     out NoCopy varchar2,
                       p_edi_rec2     out NoCopy varchar2,
                       p_edi_rec3     out NoCopy varchar2) return number
  is
       edi_cnt1            varchar2(6);
       edi_qty1            varchar2(6);
       edi_uns2            varchar2(5);
       edi_qty_qualifierI  varchar2(4);
  begin
       edi_cnt1            := rpad('CNT1',6);
       edi_qty1            := rpad('QTY1',6);
       edi_uns2            := rpad('UNS2',5);
       edi_qty_qualifierI  := rpad('I',4);

       if to_number(p_error_count) > 0 then
          p_error_msg1 := ':Failing process as invalid characters found in ' ||
                          p_error_count || ' field(s).';
       end if;

       if to_number(p_missing_val) > 0 then
          p_error_msg2 := ':Failing process as there are missing values for ' ||
                          p_missing_val || ' mandatory field(s).';
       end if;

       p_edi_rec1 := edi_uns2 || fnd_global.local_chr(10);
       p_edi_rec2 := edi_qty1 || edi_qty_qualifierI ||
                     lpad(p_record_count,15,'0') || fnd_global.local_chr(10);
       p_edi_rec3 := edi_cnt1 || lpad(p_record_count,18,'0') || fnd_global.local_chr(10);
       return 0;
  end;

  function  get_benefit_name(p_benefit_type in varchar2) return varchar2
  is
       l_benefit_name varchar2(80);
  begin
       select decode(p_benefit_type,
                     'A', 'ASSETS TRANSFERRED',
                     'B', 'PAYMENTS MADE FOR EMP',
                     'C', 'VOUCHERS OR CREDIT CARDS',
                     'D', 'LIVING ACCOMMODATION',
                     'E', 'MILEAGE ALLOWANCE AND PPAYMENT',
                     'F', 'CAR AND CAR FUEL 2003_04',
                     'G', 'VANS 2005',
                     'H', 'INT FREE AND LOW INT LOANS',
                     'I', 'PVT MED TREATMENT OR INSURANCE',
                     'J', 'RELOCATION EXPENSES',
                     'K', 'SERVICES SUPPLIED',
                     'L', 'ASSETS AT EMP DISPOSAL',
                     'M', 'OTHER ITEMS', --  'OTHER ITEMS NON 1A'
                     'N', 'EXPENSES PAYMENTS',
                     'U', 'MARORS')
        into l_benefit_name
        from dual;

        return l_benefit_name;
  end get_benefit_name;

  function  count_occurrence(p_benefit_type  in  varchar2,
                             p_person_id     in  varchar2,
			     p_employer_ref  in  varchar2,
			     p_pact_id       in  varchar2) return number
  is
       l_benefit_type varchar(80);
       l_pact_id      number;
       l_count        number;
       l_count1       number;

       cursor count_occurrence(p_pact_id number,
                               p_benefit_type varchar2) is
       select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
	                  use_index(pai_person,pay_action_information_n2)
		          use_index(pai,pay_action_information_n2) */
       	      count(*)
       from   per_all_assignments_f   paf,
              pay_assignment_actions  paa,
       	      pay_action_information  pai,
       	      pay_action_information  pai_person
       where  paf.person_id = p_person_id
       and    paf.effective_end_date = (select max(paf2.effective_end_date)
                                          from   per_all_assignments_f paf2
                                          where  paf2.assignment_id = paf.assignment_id
                                          and    paf2.person_id = p_person_id)
       and    paf.assignment_id = paa.assignment_id
       and    paa.payroll_action_id = p_pact_id
       and    pai.action_context_id = paa.assignment_action_id
       and    pai.action_context_type = 'AAP'
       and    pai.action_information_category = p_benefit_type
       and    pai_person.action_context_id = paa.assignment_action_id
       and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
       and    upper(pai_person.action_information13) = upper(p_employer_ref)
       and    pai_person.action_context_type = 'AAP';
  begin
       l_pact_id := p_pact_id;

       open count_occurrence(l_pact_id, p_benefit_type);
       fetch count_occurrence into l_count;
       close count_occurrence;
        /**  If Other Item then we also need to check Non 1A Other item as well */
        if  p_benefit_type = 'OTHER ITEMS' then
    		open count_occurrence(l_pact_id,'OTHER ITEMS NON 1A');
       		fetch count_occurrence into l_count1;
       		close count_occurrence;
    		l_count := l_count + l_count1;
        end if;
        return l_count;
  end count_occurrence;

  function  check_occurrence(p_benefit_type in varchar2) return varchar2
  is
       multiple constant varchar2(6) := 'FH';
       single   constant varchar2(15) := 'ABCDEGIJKLMNU';
       ret varchar2(10);
  begin
        ret := translate(p_benefit_type, single || multiple, single);

        if ret is not null then
           ret := 'S';
        else
           ret := 'M';
        end if;

        return ret;
  end check_occurrence;

  function  fetch_total_benefit(p_assact_id     in  number,
                                p_employer_ref  in  varchar2) return number
  is
       l_total  number;
       l_marror number;

       cursor csr_marror is
       select /*+ ORDERED use_nl(paa,pai,pai_person)
                  use_index(pai_person,pay_action_information_n2)
                  use_index(pai,pay_action_information_n2) */
              sum(pai.action_information7)
       from   pay_assignment_actions  paa,
              pay_action_information  pai,
              pay_action_information  pai_person
       where  paa.assignment_action_id = p_assact_id
       and    pai.action_context_id = paa.assignment_action_id
       and    pai.action_context_type = 'AAP'
       and    pai.action_information_category = 'MARORS'
       and    pai_person.action_context_id = paa.assignment_action_id
       and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
       and    pai_person.action_context_type = 'AAP'
       and    upper(pai_person.action_information13) = upper(p_employer_ref);

       cursor csr_benefit is
       select /*+ ORDERED use_nl(paa,pai,pai_a,pai_person)
                    use_index(pai_person,pay_action_information_n2)
                    use_index(pai,pay_action_information_n2)
                    use_index(pai_a,pay_action_information_n2)*/
             sum(decode(pai.action_information_category,
             'ASSETS TRANSFERRED', pai.action_information9,
             'PAYMENTS MADE FOR EMP', pai.action_information7,
             'VOUCHERS OR CREDIT CARDS', pai.action_information11,
             'LIVING ACCOMMODATION', pai.action_information10 + pai.action_information17,
             'MILEAGE ALLOWANCE AND PPAYMENT', pai_a.action_information12,
             'CAR AND CAR FUEL 2003_04', pai.action_information10 + pai.action_information11,
             'VANS 2002_03',pai.action_information15,
             'VANS 2005', pai.action_information15,
             'INT FREE AND LOW INT LOANS', pai.action_information11,
             'PVT MED TREATMENT OR INSURANCE', pai.action_information7,
             'RELOCATION EXPENSES', pai.action_information5,
             'SERVICES SUPPLIED', pai.action_information7,
             'ASSETS AT EMP DISPOSAL', pai.action_information9,
             'OTHER ITEMS', pai.action_information9,
             'OTHER ITEMS NON 1A', pai.action_information9,
             'EXPENSES PAYMENTS', pai.action_information8)) total
       from   pay_assignment_actions  paa,
              pay_action_information  pai,
              pay_action_information  pai_a,
              pay_action_information  pai_person
       where  paa.assignment_action_id = p_assact_id
       and    pai.action_context_id = paa.assignment_action_id
       and    pai.action_context_type = 'AAP'
       and    pai.action_information_category = pai.action_information_category
       and    pai_person.action_context_id = paa.assignment_action_id
       and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
       and    pai_person.action_context_type = 'AAP'
       and    upper(pai_person.action_information13) = upper(p_employer_ref)
       and    pai_a.action_context_id = paa.assignment_action_id
       and    pai_a.action_context_type = 'AAP'
       and    pai_a.action_information_category = 'GB P11D ASSIGNMENT RESULTA';
  begin
       open csr_benefit;
       fetch csr_benefit into l_total;
       close csr_benefit;

       open csr_marror;
       fetch csr_marror into l_marror;
       close csr_marror;

       if l_total > 0 then
          return 1;
       end if;

       if l_marror <> 0 then
          return 1;
       end if;
       return 0;
  end;
  /******************** END PUBLIC FUNCTIONS/PROCEDURES ********************/

END PAY_GB_P11D_EDI_2006;

/
