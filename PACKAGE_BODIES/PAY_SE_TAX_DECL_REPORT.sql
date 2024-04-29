--------------------------------------------------------
--  DDL for Package Body PAY_SE_TAX_DECL_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_TAX_DECL_REPORT" AS
/* $Header: pysetadr.pkb 120.9 2008/03/27 09:01:26 rsengupt noship $ */
   FUNCTION get_archive_payroll_action_id (p_payroll_action_id IN NUMBER)
      RETURN NUMBER
   IS
      l_payroll_action_id   NUMBER;
   BEGIN

      IF p_payroll_action_id IS NULL
      THEN
         BEGIN
            SELECT payroll_action_id
              INTO l_payroll_action_id
              FROM pay_payroll_actions ppa,
                   fnd_conc_req_summary_v fcrs,
                   fnd_conc_req_summary_v fcrs1
             WHERE fcrs.request_id = fnd_global.conc_request_id
               AND fcrs.priority_request_id = fcrs1.priority_request_id
               AND ppa.request_id BETWEEN fcrs1.request_id
                                      AND fcrs.request_id
               AND ppa.request_id = fcrs1.request_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      ELSE
         l_payroll_action_id := p_payroll_action_id;
      END IF;

      RETURN l_payroll_action_id;
   END;

   PROCEDURE get_digit_breakup(
      p_amount IN NUMBER,
      p_digit1 OUT NOCOPY NUMBER,
      p_digit2 OUT NOCOPY NUMBER,
      p_digit3 OUT NOCOPY NUMBER,
      p_digit4 OUT NOCOPY NUMBER,
      p_digit5 OUT NOCOPY NUMBER,
      p_digit6 OUT NOCOPY NUMBER,
      p_digit7 OUT NOCOPY NUMBER,
      p_digit8 OUT NOCOPY NUMBER,
      p_digit9 OUT NOCOPY NUMBER
   )
   IS

   TYPE digits IS
      TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;
     l_digit digits;
     l_count NUMBER :=1;
     l_amount number(9);
   BEGIN
   l_amount:=abs(floor(p_amount));
   FOR I in 1..9 loop
    l_digit(I):=null;
   END loop;

   WHILE l_amount >= 10  LOOP

	SELECT mod(l_amount,10) INTO l_digit(l_count) from dual;
	l_amount:=floor(l_amount/10);
	l_count:=l_count+1;
   END LOOP;

   SELECT floor(l_amount) INTO l_digit(l_count) from dual;
	p_digit1:=l_digit(1);
	p_digit2:=l_digit(2);
	p_digit3:=l_digit(3);
	p_digit4:=l_digit(4);
	p_digit5:=l_digit(5);
	p_digit6:=l_digit(6);
	p_digit7:=l_digit(7);
	p_digit8:=l_digit(8);
	p_digit9:=l_digit(9);
   END get_digit_breakup;

   PROCEDURE get_data (
      p_business_group_id  in varchar2,
      p_payroll_action_id   IN              VARCHAR2,
      p_template_name       IN              VARCHAR2,
      p_xml                 OUT NOCOPY      CLOB
   )
   IS
      /*  Start of declaration*/
      -- Variables needed for the report
      l_sum                 NUMBER;
      l_counter             NUMBER                                            := 1;
      l_payroll_action_id   pay_action_information.action_information1%TYPE;
      l_digit1 NUMBER(1);
      l_digit2 NUMBER(1);
      l_digit3 NUMBER(1);
      l_digit4 NUMBER(1);
      l_digit5 NUMBER(1);
      l_digit6 NUMBER(1);
      l_digit7 NUMBER(1);
      l_digit8 NUMBER(1);
      l_digit9 NUMBER(1);
      l_regular_year NUMBER(4);
      l_65_Year NUMBER(4);
      l_gen_tax_perc NUMBER(5,2);
      l_spl_65_perc NUMBER(5,2);
      l_spl_1937_perc NUMBER(5,2);
      l_spl_25_below_perc NUMBER(5,2);
      l_business_id   NUMBER;
      l_effective_date DATE;
      l_archive varchar2(10);
      l_legal_employer_id NUMBER;
      l_month VARCHAR2(25);
      l_year VARCHAR2(25);
      l_administrative_code VARCHAR2(200);
      l_information VARCHAR2(200);
      l_declaration_due_date DATE;
      l_emb_below_65 NUMBER;
      l_comp_perc NUMBER;
      l_comp_perc_max NUMBER;
      l_ext_comp_perc NUMBER;
      l_ext_comp_perc_max NUMBER;
      l_Pension_Start NUMBER;
      l_Pension_End NUMBER;
      l_temp VARCHAR2(10);
      l_Comp_Emb_Without_LU_Total NUMBER;       -- EOY 2008
      l_Comp_Emb_Without_LU_Total_29 NUMBER;    -- EOY 2008


cursor csr_Tax_Decl (csr_v_pa_id IN VARCHAR2)
IS
SELECT pai.action_information3 Organization_Name,
pai.action_information4 Month,
pai.action_information5 Year,
pai.action_information8 Declaration_Due_Date,
pai.action_information6 Administrative_Code,
pai.action_information7 Information,
pai1.action_information3 Organization_Number,
fnd_number.canonical_to_number(pai1.action_information4) Reduction,
fnd_number.canonical_to_number(pai1.action_information7) Code,
fnd_number.canonical_to_number(pai1.action_information8) Canada,
fnd_number.canonical_to_number(pai1.action_information9) Special_Canada,
-- fnd_number.canonical_to_number(pai1.action_information10) Comp_Support,      -- EOY 2008
-- fnd_number.canonical_to_number(pai1.action_information11) Comp_Support_5,    -- EOY 2008
fnd_number.canonical_to_number(pai1.action_information12) Ext_Comp_Support,
fnd_number.canonical_to_number(pai1.action_information13) Ext_Comp_Support_10,
fnd_number.canonical_to_number(pai1.action_information14) Pension,
fnd_number.canonical_to_number(pai1.action_information15) Ded_Pension,
fnd_number.canonical_to_number(pai1.action_information16) Interest,
fnd_number.canonical_to_number(pai1.action_information17) Ded_Interest,
pai1.action_information18 Contact,
pai1.action_information19 Phone,
fnd_number.canonical_to_number(pai1.action_information20) Certain_Insurances,       --EOY 2008
fnd_number.canonical_to_number(pai1.action_information21) Certain_Insurances_29,    --EOY 2008
fnd_number.canonical_to_number(pai2.action_information3) Gross_Pay,
fnd_number.canonical_to_number(pai2.action_information4) Benefit,
fnd_number.canonical_to_number(pai2.action_information5) Total_Basis_Employer_Tax,
fnd_number.canonical_to_number(pai2.action_information6) Regular_Taxable_Base,
fnd_number.canonical_to_number(pai2.action_information7) Regular_Tax,
fnd_number.canonical_to_number(pai2.action_information8) Special_65_Taxable_Base,
fnd_number.canonical_to_number(pai2.action_information9) Special_65_Tax,
fnd_number.canonical_to_number(pai2.action_information10) Special_1937_Taxable_Base,
fnd_number.canonical_to_number(pai2.action_information11) Special_1937_Tax,
fnd_number.canonical_to_number(pai2.action_information12) Total_Employer_Tax,
fnd_number.canonical_to_number(pai2.action_information13) Taxable_Base,
fnd_number.canonical_to_number(pai2.action_information14) Employee_Tax,
fnd_number.canonical_to_number(pai2.action_information15) Tax_Deduction,
fnd_number.canonical_to_number(pai2.action_information16) Deducted_Tax_Pay,
fnd_number.canonical_to_number(pai2.action_information17) Comp_Without_LU,
fnd_number.canonical_to_number(pai2.action_information18) Comp_Without_LU_29,
fnd_number.canonical_to_number(pai2.action_information19) Comp_Without_LU_65_above,
fnd_number.canonical_to_number(pai2.action_information20) Comp_Without_LU_29_65_above,
fnd_number.canonical_to_number(pai2.action_information21) Special_25_below_Taxable_Base,
fnd_number.canonical_to_number(pai2.action_information22) Special_25_below_Tax,
fnd_number.canonical_to_number(pai2.action_information23) Comp_Without_LU_25_below,     -- EOY 2008
fnd_number.canonical_to_number(pai2.action_information24) Comp_Without_LU_29_25_below   -- EOY 2008
FROM
pay_action_information pai,
pay_payroll_actions ppa,
pay_action_information pai1,
pay_action_information pai2
WHERE
pai.action_context_id = ppa.payroll_action_id
AND ppa.payroll_action_id =csr_v_pa_id
AND pai.action_context_id = pai1.action_context_id
AND pai1.action_context_id= pai2.action_context_id
AND pai2.action_context_id=pai1.action_context_id
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'INF'
AND pai1.action_information1 = 'PYSETADA'
AND pai1.action_information_category = 'EMEA REPORT INFORMATION'
AND pai.action_context_type = 'PA'
AND pai.action_information1 = 'PYSETADA'
AND pai.action_information_category = 'EMEA REPORT DETAILS'
AND pai2.action_context_type = 'PA'
AND pai2.action_information1 = 'PYSETADA'
AND pai2.action_information_category = 'EMEA REPORT INFORMATION'
AND pai2.action_information2 = 'BAL';

rg_Tax_Decl csr_Tax_Decl%rowtype;
CURSOR csr_global(csr_v_global VARCHAR2,csr_v_effective_date DATE )IS
SELECT nvl(fnd_number.canonical_to_number(global_value),0) FROM ff_globals_f WHERE GLOBAL_NAME=csr_v_global --'SE_EMPLOYER_TAX_PERC'
	and csr_v_effective_date --p_effective_date
	BETWEEN effective_start_date AND
	effective_end_date;

BEGIN

      hr_utility.set_location ('Entered Procedure GETDATA', 10);

      l_payroll_action_id :=
                          get_archive_payroll_action_id (p_payroll_action_id);

      PAY_SE_TAX_DECL.GET_ALL_PARAMETERS(
		 p_payroll_action_id
		,l_business_id
		,l_effective_date
		,l_archive
 		,l_legal_employer_id
 		,l_month
		,l_year
		,l_administrative_code
		,l_information
        ,l_declaration_due_date
            ) ;
      OPEN csr_Tax_Decl(l_payroll_action_id);
        FETCH csr_Tax_Decl INTO rg_Tax_Decl;
      CLOSE csr_Tax_Decl;
	l_regular_Year:=rg_Tax_Decl.Year-65;
	l_65_Year:=l_regular_Year-1;
	l_Pension_Start:=rg_Tax_Decl.Year-25;
	l_Pension_End:=rg_Tax_Decl.Year-19;
	 fnd_file.put_line(fnd_file.LOG,'before globals');
	 fnd_file.put_line(fnd_file.LOG,'l_effective_date'||l_effective_date);
	 OPEN csr_global('SE_EMPLOYER_TAX_PERC',l_effective_date);
		FETCH csr_global INTO l_temp; --l_gen_tax_perc;
	 CLOSE csr_global;
 	 fnd_file.put_line(fnd_file.LOG,'l_temp'||l_temp);
	 l_gen_tax_perc:=l_temp;
	 fnd_file.put_line(fnd_file.LOG,'l_gen_tax_perc'||l_gen_tax_perc);
	 fnd_file.put_line(fnd_file.LOG,'after globals');

	 OPEN csr_global('SE_SIT_AGE_ABOVE_65',l_effective_date);
		FETCH csr_global INTO l_spl_65_perc;
	 CLOSE csr_global;

	 OPEN csr_global('SE_SIT_BORN_BEFORE_YEAR_LIMIT',l_effective_date);
		FETCH csr_global INTO l_spl_1937_perc;
	 CLOSE csr_global;

	 OPEN csr_global('SE_SIT_AGE_BELOW_25',l_effective_date);
		FETCH csr_global INTO l_spl_25_below_perc;
	 CLOSE csr_global;

	 OPEN csr_global('SE_EMBASSY_BELOW_65',l_effective_date);
		FETCH csr_global INTO l_emb_below_65;
	 CLOSE csr_global;

	 OPEN csr_global('SE_COMPANY_PERC',l_effective_date);
		FETCH csr_global INTO l_comp_perc;
	 CLOSE csr_global;

	 OPEN csr_global('SE_COMPANY_PERC_MAX',l_effective_date);
		FETCH csr_global INTO l_comp_perc_max;
	 CLOSE csr_global;

	 OPEN csr_global('SE_EXT_COMPANY_PERC',l_effective_date);
		FETCH csr_global INTO l_ext_comp_perc;
	 CLOSE csr_global;

	 OPEN csr_global('SE_EXT_COMPANY_PERC_MAX',l_effective_date);
		FETCH csr_global INTO l_ext_comp_perc_max;
	 CLOSE csr_global;

/*****************************************************************************************************/
/************************ Calculation of Companies/Embassies Vaues ***********************************/
/******************************************************************************************************/
       l_Comp_Emb_Without_LU_Total := rg_Tax_Decl.Certain_Insurances + rg_Tax_Decl.Comp_Without_LU_25_below
                                        + rg_Tax_Decl.Comp_Without_LU_65_above + rg_Tax_Decl.Comp_Without_LU ;

      l_Comp_Emb_Without_LU_Total_29 := rg_Tax_Decl.Certain_Insurances_29 + rg_Tax_Decl.Comp_Without_LU_29_25_below
                                         + rg_Tax_Decl.Comp_Without_LU_29_65_above + rg_Tax_Decl.Comp_Without_LU_29 ;


/*****************************************************************************************************/

         hr_utility.set_location ('Before populating pl/sql table', 70);
         gplsqltable (l_counter).tagname := 'START';
         gplsqltable (l_counter).tagvalue := 'START';
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'EMP_TAX';
         gplsqltable (l_counter).tagvalue := l_gen_tax_perc;
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'SPL_65';
         gplsqltable (l_counter).tagvalue := l_spl_65_perc;
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'SPL_1937';
         gplsqltable (l_counter).tagvalue := l_spl_1937_perc;
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'SE_65_BELOW';
         gplsqltable (l_counter).tagvalue := l_emb_below_65;
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'SE_25_BELOW';
         gplsqltable (l_counter).tagvalue := l_spl_25_below_perc;
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'SE_COMP_PERC';
         gplsqltable (l_counter).tagvalue := l_comp_perc;
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'SE_COMP_PERC_MAX';
         gplsqltable (l_counter).tagvalue := l_comp_perc_max;
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'SE_EX_COMP_PERC';
         gplsqltable (l_counter).tagvalue := l_ext_comp_perc;
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'SE_EX_COMP_PERC_MAX';
         gplsqltable (l_counter).tagvalue := l_ext_comp_perc_max;
         l_counter :=   l_counter
                      + 1;

	 gplsqltable (l_counter).tagname := 'Organization_Name';
         gplsqltable (l_counter).tagvalue :=
                                          TO_CHAR (rg_Tax_Decl.Organization_Name);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'Organization_Number';
         gplsqltable (l_counter).tagvalue :=
                                       TO_CHAR(rg_tax_Decl.Organization_Number);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'Declaration_Due_Date';
         gplsqltable (l_counter).tagvalue :=
                                           TO_CHAR(rg_Tax_Decl.Declaration_Due_Date);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'Month';
         gplsqltable (l_counter).tagvalue :=
                                           TO_CHAR(rg_Tax_Decl.Month);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'Year';
         gplsqltable (l_counter).tagvalue := TO_CHAR(rg_Tax_Decl.Year);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'l_Regular_Year';
         gplsqltable (l_counter).tagvalue := TO_CHAR(l_Regular_Year);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'l_65_Year';
         gplsqltable (l_counter).tagvalue := TO_CHAR(l_65_Year);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Pension_Start';
         gplsqltable (l_counter).tagvalue := TO_CHAR(l_Pension_Start);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Pension_End';
         gplsqltable (l_counter).tagvalue := TO_CHAR(l_Pension_End);
         l_counter :=   l_counter
                      + 1;
         get_digit_breakup(rg_tax_Decl.Gross_Pay,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Gp1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Gp2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Gp3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Gp4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Gp5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Gp6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Gp7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Gp8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Gp9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
 	 get_digit_breakup(rg_tax_Decl.Benefit,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Tb1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Tb2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Tb3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Tb4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Tb5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Tb6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Tb7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Tb8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Tb9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Reduction,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Cr1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Total_Basis_Employer_Tax,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Eb1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Eb2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Eb3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Eb4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Eb5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Eb6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Eb7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Eb8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Eb9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Reduction,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Cr1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cr9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Regular_Taxable_Base,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Rb1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rb2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rb3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rb4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rb5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rb6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rb7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rb8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rb9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Regular_Tax,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Rt1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rt2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rt3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rt4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rt5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rt6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rt7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rt8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Rt9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Special_65_Taxable_Base,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'B651';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B652';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B653';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B654';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B655';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B656';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B657';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B658';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B659';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Special_65_Tax,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'T651';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T652';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T653';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T654';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T655';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T656';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T657';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T658';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T659';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;

/*****************************************************************************************************************/
/************ Removed With respect to 2008 Year End changes  ****************************************************/
/*****************************************************************************************************************

	 get_digit_breakup(rg_tax_Decl.Special_1937_Taxable_Base,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'B371';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B372';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B373';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B374';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B375';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B376';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B377';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B378';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B379';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Special_1937_Tax,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'T371';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T372';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T373';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T374';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T375';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T376';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T377';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T378';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T379';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
****************************************************************************************************************
*****************************************************************************************************************/
	 get_digit_breakup(l_Comp_Emb_Without_LU_Total,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'C1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'C2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'C3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'C4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'C5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'C6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'C7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'C8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'C9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(l_Comp_Emb_Without_LU_Total_29,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Cp1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cp2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cp3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cp4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cp5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cp6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cp7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cp8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cp9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Code';
         gplsqltable (l_counter).tagvalue := TO_CHAR (rg_tax_Decl.Code);
         l_counter :=   l_counter
                      + 1;

	 --
	 get_digit_breakup(rg_tax_Decl.Comp_Without_LU_25_below,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Cw1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cw2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cw3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cw4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cw5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cw6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cw7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cw8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cw9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Comp_Without_LU_29_25_below,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Cwp1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cwp2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cwp3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cwp4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cwp5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cwp6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cwp7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cwp8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cwp9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;

	 --
get_digit_breakup(rg_tax_Decl.Canada,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Ca1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ca2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ca3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ca4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ca5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ca6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ca7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ca8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ca9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Special_Canada,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Cc1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cc2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cc3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cc4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cc5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cc6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cc7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cc8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cc9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
/***************************************************************************************************************/
/************************ Removed with respect to 2008 Year End Changes ****************************************/
/**************************************************************************************************************

	get_digit_breakup(rg_tax_Decl.Comp_Support,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Cs1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cs2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cs3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cs4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cs5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cs6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cs7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cs8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Cs9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;

	 get_digit_breakup(rg_tax_Decl.Comp_Support_5,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Ds1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
****************************************************************************************************************/
/***************************************************************************************************************/
	 get_digit_breakup(rg_tax_Decl.Ext_Comp_Support,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Es1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Es2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Es3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Es4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Es5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Es6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Es7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Es8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Es9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;

/***************************************************************************************************************/
/************************* removed With respect to EOY 2008 ****************************************************/
/************************************************************************************************************
         get_digit_breakup(rg_tax_Decl.Comp_Support_5,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Ds1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Ds9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;

*************************************************************************************************************/
/************************************************************************************************************/
	 get_digit_breakup(rg_tax_Decl.Ext_Comp_Support_10,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'De1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'De2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'De3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'De4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'De5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'De6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'De7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'De8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'De9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Total_Employer_Tax,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Et1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Et2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Et3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Et4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Et5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Et6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Et7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Et8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Et9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Taxable_Base,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Bt1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Bt2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Bt3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Bt4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Bt5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Bt6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Bt7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Bt8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Bt9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Employee_Tax,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Be1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Be2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Be3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Be4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Be5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Be6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Be7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Be8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Be9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Pension,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'P1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'P2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'P3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'P4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'P5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'P6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'P7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'P8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'P9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Ded_Pension,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Dp1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dp2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dp3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dp4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dp5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dp6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dp7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dp8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dp9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Interest,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'I1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'I2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'I3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'I4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'I5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'I6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'I7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'I8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'I9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Ded_Interest,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Di1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Di2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Di3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Di4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Di5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Di6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Di7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Di8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Di9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Tax_Deduction,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Db1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Db2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Db3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Db4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Db5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Db6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Db7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Db8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Db9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Deducted_Tax_Pay,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Dt1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dt2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dt3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dt4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dt5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dt6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dt7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dt8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Dt9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup((trunc(rg_tax_Decl.Deducted_Tax_Pay) + trunc(rg_tax_Decl.Total_Employer_Tax)),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'Std1';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Std2';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Std3';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Std4';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Std5';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Std6';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Std7';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Std8';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'Std9';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Special_25_below_Taxable_Base,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'B251';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B252';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B253';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B254';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B255';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B256';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B257';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B258';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'B259';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
	 get_digit_breakup(rg_tax_Decl.Special_25_below_Tax,l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9);
	 gplsqltable (l_counter).tagname := 'T251';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T252';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T253';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T254';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T255';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T256';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T257';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T258';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gplsqltable (l_counter).tagname := 'T259';
         gplsqltable (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;

         gplsqltable (l_counter).tagname := 'Information';
         gplsqltable (l_counter).tagvalue := TO_CHAR (rg_tax_Decl.Information);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'Contact';
         gplsqltable (l_counter).tagvalue :=
                                            TO_CHAR (rg_Tax_Decl.Contact);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'Phone';
         gplsqltable (l_counter).tagvalue := TO_CHAR (rg_Tax_Decl.Phone);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'Administrative_Code';
         gplsqltable (l_counter).tagvalue :=
                                       TO_CHAR (rg_Tax_Decl.Administrative_Code);
         l_counter :=   l_counter
                      + 1;


         gplsqltable (l_counter).tagname := 'END';
         gplsqltable (l_counter).tagvalue := 'END';
         l_counter :=   l_counter
                      + 1;

      writetoclob (p_xml);
      --INSERT INTO raaj VALUES (p_xml);
      fnd_file.put_line(fnd_file.LOG,'p_xml'||p_xml);

   END get_data;
-----------------------------------------------------------------------------------------------------------------
   PROCEDURE writetoclob (p_xfdf_clob OUT NOCOPY CLOB)
   IS
      l_xfdf_string   CLOB;
      l_str1          VARCHAR2 (1000);
      l_str2          VARCHAR2 (20);
      l_str3          VARCHAR2 (20);
      l_str4          VARCHAR2 (20);
      l_str5          VARCHAR2 (20);
      l_str6          VARCHAR2 (30);
      l_str7          VARCHAR2 (1000);
      l_str8          VARCHAR2 (240);
      l_str9          VARCHAR2 (240);
      l_str10         VARCHAR2 (20);
      l_str11         VARCHAR2 (20);
      current_index   PLS_INTEGER;
      l_counter       PLS_INTEGER;
   BEGIN

      hr_utility.set_location ('Entering WritetoCLOB ', 70);
      l_str1 := '<?xml version="1.0" encoding="UTF-8"?> <ROOT>';
      l_str2 := '<';
      l_str3 := '>';
      l_str4 := '</';
      l_str5 := '>';
      l_str6 := '</ROOT>';
      l_str7 := '<?xml version="1.0" encoding="UTF-8"?> <ROOT></ROOT>';
      l_str10 := '<TAXDECL>';
      l_str11 := '</TAXDECL>';

BEGIN
dbms_lob.createtemporary(l_xfdf_string, FALSE, dbms_lob.CALL);

END;

      dbms_lob.OPEN(l_xfdf_string, DBMS_LOB.lob_readwrite);

      current_index := 0;

      IF gplsqltable.COUNT > 0
      THEN
         DBMS_LOB.writeappend(l_xfdf_string, LENGTH (l_str1), l_str1);
         FOR table_counter IN gplsqltable.FIRST .. gplsqltable.LAST
         LOOP

            l_str8 := gplsqltable (table_counter).tagname;
            l_str9 := gplsqltable (table_counter).tagvalue;
            IF l_str9 = 'END'
            THEN
               DBMS_LOB.writeappend (l_xfdf_string,
                  LENGTH (l_str11),
                  l_str11
               );
            ELSIF l_str9 = 'START'
            THEN
               DBMS_LOB.writeappend (
                  l_xfdf_string,
                  LENGTH (l_str10),
                  l_str10
               );
            ELSIF l_str9 IS NOT NULL
            THEN
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str9), l_str9);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);
            ELSE
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);
            END IF;
         END LOOP;
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str6), l_str6);
      ELSE
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str7), l_str7);
      END IF;
      p_xfdf_clob := l_xfdf_string;
      hr_utility.set_location ('Leaving WritetoCLOB ', 70);
      hr_utility.set_location ('Leaving WritetoCLOB ', 70);


   END writetoclob;
  -------------------------------------------------------------------------------------------------------------------------
   PROCEDURE GET_XML
(
	p_business_group_id				IN NUMBER,
	p_payroll_action_id       				IN  VARCHAR2 ,
  	p_template_name					IN VARCHAR2,
	p_xml 								OUT NOCOPY CLOB
	)
   IS
      /*  Start of declaration*/
      -- Variables needed for the report
      l_sum                 NUMBER;
      l_counter             NUMBER                                            := 1;
      l_payroll_action_id   pay_action_information.action_information1%TYPE;
      l_xfdf_string CLOB;
      l_str1 varchar2(2000);

cursor csr_Tax_Decl (csr_v_pa_id IN VARCHAR2)
IS
SELECT pai.action_information3 Organization_Name,
pai.action_information4 Month,
pai.action_information5 Year,
pai.action_information8 Declaration_Due_Date,
pai.action_information6 Administrative_Code,
pai.action_information7 Information,
pai1.action_information3 Organization_Number,
fnd_number.canonical_to_number(pai1.action_information4) Reduction,
pai1.action_information7 Code,
fnd_number.canonical_to_number(pai1.action_information8) Canada,
fnd_number.canonical_to_number(pai1.action_information9) Special_Canada,
-- fnd_number.canonical_to_number(pai1.action_information10) Comp_Support,  -- EOY 2008
-- fnd_number.canonical_to_number(pai1.action_information11) Comp_Support_5,  -- EOY 2008
fnd_number.canonical_to_number(pai1.action_information12) Ext_Comp_Support,
fnd_number.canonical_to_number(pai1.action_information13) Ext_Comp_Support_10,
fnd_number.canonical_to_number(pai1.action_information14) Pension,
fnd_number.canonical_to_number(pai1.action_information15) Ded_Pension,
fnd_number.canonical_to_number(pai1.action_information16) Interest,
fnd_number.canonical_to_number(pai1.action_information17) Ded_Interest,
pai1.action_information18 Contact,
pai1.action_information19 Phone,
fnd_number.canonical_to_number(pai1.action_information20) Certain_Insurances,    --EOY 2008
fnd_number.canonical_to_number(pai1.action_information21) Certain_Insurances_29, -- EOY 2008
fnd_number.canonical_to_number(pai2.action_information3) Gross_Pay,
fnd_number.canonical_to_number(pai2.action_information4) Benefit,
fnd_number.canonical_to_number(pai2.action_information5) Total_Basis_Employer_Tax,
fnd_number.canonical_to_number(pai2.action_information6) Regular_Taxable_Base,
fnd_number.canonical_to_number(pai2.action_information7) Regular_Tax,
fnd_number.canonical_to_number(pai2.action_information8) Special_65_Taxable_Base,
fnd_number.canonical_to_number(pai2.action_information9) Special_65_Tax,
fnd_number.canonical_to_number(pai2.action_information10) Special_1937_Taxable_Base,
fnd_number.canonical_to_number(pai2.action_information11) Special_1937_Tax,
fnd_number.canonical_to_number(pai2.action_information12) Total_Employer_Tax,
fnd_number.canonical_to_number(pai2.action_information13) Taxable_Base,
fnd_number.canonical_to_number(pai2.action_information14) Employee_Tax,
fnd_number.canonical_to_number(pai2.action_information15) Tax_Deduction,
fnd_number.canonical_to_number(pai2.action_information16) Deducted_Tax_Pay,
fnd_number.canonical_to_number(pai2.action_information17) Comp_Without_LU,
fnd_number.canonical_to_number(pai2.action_information18) Comp_Without_LU_29,
fnd_number.canonical_to_number(pai2.action_information19) Comp_Without_LU_65_below,
fnd_number.canonical_to_number(pai2.action_information20) Comp_Without_LU_29_65_below,
fnd_number.canonical_to_number(pai2.action_information21) Special_25_below_Taxable_Base,
fnd_number.canonical_to_number(pai2.action_information22) Special_25_below_Tax,
fnd_number.canonical_to_number(pai2.action_information23) Comp_Without_LU_25_below,     -- EOY 2008
fnd_number.canonical_to_number(pai2.action_information24) Comp_Without_LU_29_25_below   -- EOY 2008
FROM
pay_action_information pai,
pay_payroll_actions ppa,
pay_action_information pai1,
pay_action_information pai2
WHERE
pai.action_context_id = ppa.payroll_action_id
AND ppa.payroll_action_id =csr_v_pa_id
AND pai.action_context_id = pai1.action_context_id
AND pai1.action_context_id= pai2.action_context_id
AND pai2.action_context_id=pai1.action_context_id
AND pai1.action_context_type='PA'
AND pai1.action_information2 = 'INF'
AND pai1.action_information1 = 'PYSETADA'
AND pai1.action_information_category = 'EMEA REPORT INFORMATION'
AND pai.action_context_type = 'PA'
AND pai.action_information1 = 'PYSETADA'
AND pai.action_information_category = 'EMEA REPORT DETAILS'
AND pai2.action_context_type = 'PA'
AND pai2.action_information1 = 'PYSETADA'
AND pai2.action_information_category = 'EMEA REPORT INFORMATION'
AND pai2.action_information2 = 'BAL';

rg_Tax_Decl csr_Tax_Decl%rowtype;

CURSOR csr_month(csr_v_month varchar2) IS
SELECT decode(trim(csr_v_month),'JANUARY','01',
	'FEBRUARY','02',
	'MARCH','03',
	'APRIL','04',
	'MAY','05',
	'JUNE','06',
	'JULY','07',
	'AUGUST','08',
	'SEPTEMBER','09',
	'OCTOBER','10',
	'NOVEMBER','11',
	'DECEMBER','12') FROM dual;


l_month varchar2(5);
l_full_month varchar2(25);
BEGIN
    fnd_file.put_line (fnd_file.LOG, 'Entering into GET_XML');
	hr_utility.set_location ('Entered Procedure GETDATA', 10);

	l_payroll_action_id :=
                          get_archive_payroll_action_id (p_payroll_action_id);

	OPEN csr_Tax_Decl(l_payroll_action_id);
		FETCH csr_Tax_Decl INTO rg_Tax_Decl;
	CLOSE csr_Tax_Decl;

	--l_regular_Year:=rg_Tax_Decl.Year-65;
	--l_65_Year:=l_regular_Year-1;

	 l_full_month:=	rg_Tax_Decl.Month;

	 OPEN csr_month(l_full_month);
		FETCH csr_month INTO l_month;
	 CLOSE csr_month;

	/*Generate an xml string*/
	dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
	dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);

	 				/*Generate an xml string*/
				dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
				dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);

			/*	 l_str1 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?>
				<Skjema xmlns:brreg="http://www.brreg.no/or" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				tittel="Terminoppgave for  arbeidsgiveravgift og forskuddstrekk." gruppeid="52" spesifikasjonsnummer="4578"
				skjemanummer="669" etatid="974761076" blankettnummer="RF-1037">';
				dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );*/

	l_str1 := '<?xml version="1.0" encoding="ISO-8859-1"?>

   	<!--DOCTYPE eSKDUpload PUBLIC "-//Skatteverket, Sweden//DTD Skatteverket
       eSKDUpload-DTD Version 3.0//SV"
       "https://www1.skatteverket.se/demoeskd/eSKDUpload_3p0.dtd"-->
   	<eSKDUpload Version="3.0">';

	/*<Skjema xmlns:brreg="http://www.brreg.no/or" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	tittel="Terminoppgave for  arbeidsgiveravgift og forskuddstrekk." gruppeid="52" spesifikasjonsnummer="4578"
	skjemanummer="669" etatid="974761076" blankettnummer="RF-1037">';*/

	dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );
	 l_str1:='<OrgNr>'||  (rg_Tax_Decl.Organization_Number)||'</OrgNr>
		<Ag>
			<Period>'||(rg_Tax_Decl.Year)||l_month||'</Period>
			<LonBrutto>'||substr(trunc(rg_tax_Decl.Gross_Pay),1,12)||'</LonBrutto>
			<Forman>'||substr(trunc(rg_tax_Decl.Benefit),1,12)||'</Forman>
			<AvdrKostn>'||substr(trunc(rg_tax_Decl.Reduction),1,12)||'</AvdrKostn>
			<SumUlagAvg>'||substr(trunc(rg_tax_Decl.Total_Basis_Employer_Tax),1,12)||'</SumUlagAvg>
			<UlagAvgHel>'||substr(trunc(rg_tax_Decl.Regular_Taxable_Base),1,12)||'</UlagAvgHel>
			<AvgHel>'||substr(trunc(rg_tax_Decl.Regular_Tax),1,12)||'</AvgHel>
			<UlagAvgAldersp>'||substr(trunc(rg_tax_Decl.Special_25_below_Taxable_Base),1,12)||'</UlagAvgAldersp>
			<AvgAldersp>'||substr(trunc(rg_tax_Decl.Special_25_below_Tax),1,12)||'</AvgAldersp>
			<UlagAlderspSkLon>'||substr(trunc(rg_tax_Decl.Special_65_Taxable_Base),1,12)||'</UlagAlderspSkLon>
			<AvgAlderspSkLo>'||substr(trunc(rg_tax_Decl.Special_65_Tax),1,12)||'</AvgAlderspSkLo>
			<UlagSkLonSarsk>'||substr(trunc(rg_tax_Decl.Special_1937_Taxable_Base),1,12)||'</UlagSkLonSarsk>
			<SkLonSarsk>'||substr(trunc(rg_tax_Decl.Special_1937_Tax),1,12)||'</SkLonSarsk>
			<UlagAvgAmbassad>'||substr(trunc(rg_tax_Decl.Comp_Without_LU),1,12)||'</UlagAvgAmbassad>
			<AvgAmbassad>'||substr(trunc(rg_tax_Decl.Comp_Without_LU_29),1,12)||'</AvgAmbassad>
			<KodAmerika>'||substr(trunc(rg_tax_Decl.Code),1,12)||'</KodAmerika>
			<UlagAvgAmerika>'||substr(trunc(rg_tax_Decl.Canada),1,12)||'</UlagAvgAmerika>
			<AvgAmerika>'||substr(trunc(rg_tax_Decl.Special_Canada),1,12)||'</AvgAmerika>
			<UlagStodUtvidgat>'||substr(trunc(rg_tax_Decl.Ext_Comp_Support),1,12)||'</UlagStodUtvidgat>
			<AvdrStodUtvidgat>'||substr(trunc(rg_tax_Decl.Ext_Comp_Support_10),1,12)||'</AvdrStodUtvidgat>
			<SumAvgBetala>'||substr(trunc(rg_tax_Decl.Total_Employer_Tax),1,12)||'</SumAvgBetala>
			<UlagSkAvdrLo>'||substr(trunc(rg_tax_Decl.Taxable_Base),1,12)||'</UlagSkAvdrLo>
			<SkAvdrLon>'||substr(trunc(rg_tax_Decl.Employee_Tax),1,12)||'</SkAvdrLon>
			<UlagSkAvdrPension>'||substr(trunc(rg_tax_Decl.Pension),1,12)||'</UlagSkAvdrPension>
			<SkAvdrPension>'||substr(trunc(rg_tax_Decl.Ded_Pension),1,12)||'</SkAvdrPension>
			<UlagSkAvdrRanta>'||substr(trunc(rg_tax_Decl.Interest),1,12)||'</UlagSkAvdrRanta>
			<SkAvdrRanta>'||substr(trunc(rg_tax_Decl.Ded_Interest),1,12)||'</SkAvdrRanta>
			<UlagSumSkAvdr>'||substr(trunc(rg_tax_Decl.Tax_Deduction),1,12)||'</UlagSumSkAvdr>
			<SumSkAvdr>'||substr(trunc(rg_tax_Decl.Deducted_Tax_Pay),1,12)||'</SumSkAvdr>
			<TextUpplysningAg>'||substr(rg_tax_Decl.Information,1,400)||'</TextUpplysningAg>
		</Ag>
	</eSKDUpload>';
	dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );

	hr_utility.set_location('Inside GETDATA',30);

	p_xml := l_xfdf_string;

	hr_utility.set_location('Leaving GETDATA',40);

END GET_XML;

-------------------------------------------------------------------------------------------------------------------------
END PAY_SE_TAX_DECL_REPORT;


/
