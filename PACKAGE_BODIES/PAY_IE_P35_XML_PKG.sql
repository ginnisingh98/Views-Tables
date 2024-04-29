--------------------------------------------------------
--  DDL for Package Body PAY_IE_P35_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_P35_XML_PKG" AS
/* $Header: pyiep35p.pkb 120.11.12010000.3 2009/06/22 05:11:17 knadhan ship $ */

-------------------------------------------------------------------------------
-- get_IANA_charset
-------------------------------------------------------------------------------
FUNCTION get_IANA_charset RETURN VARCHAR2 IS
    CURSOR csr_get_iana_charset IS
        SELECT tag
          FROM fnd_lookup_values
         WHERE lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
           AND lookup_code = SUBSTR(USERENV('LANGUAGE'),
                                    INSTR(USERENV('LANGUAGE'), '.') + 1)
           AND language = 'US';

    lv_iana_charset fnd_lookup_values.tag%type;
BEGIN
    OPEN csr_get_iana_charset;
        FETCH csr_get_iana_charset INTO lv_iana_charset;
    CLOSE csr_get_iana_charset;

    hr_utility.trace('IANA Charset = '||lv_iana_charset);
    RETURN (lv_iana_charset);
END get_IANA_charset;
--
	-------------------------------------------------------------------------------
	-- WRITETOCLOB
	--------------------------------------------------------------------------------
	PROCEDURE WritetoCLOB (p_xfdf_string out nocopy clob)
	IS
	  l_str varchar2(240);
	  l_str1 varchar2(6000);
	BEGIN
	-- bug 5852148
       --l_str := '<?xml version="1.0" encoding="UTF-8"?> <P35LFile></P35LFile>';
         l_str := '<?xml version="1.0" encoding="' || get_IANA_charset ||'"?> <P35LFile></P35LFile>';
		dbms_lob.createtemporary(p_xfdf_string,FALSE,DBMS_LOB.CALL);
		dbms_lob.open(p_xfdf_string,dbms_lob.lob_readwrite);
  	    hr_utility.set_location('TableCnt' || to_char(vXMLTable.count),13);
	    IF vXMLTable.count > 0 THEN
		FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
                  -- Bug 4705094
		l_str1 := vXMLTable(ctr_table).xmlString;
		dbms_lob.writeAppend( p_xfdf_string, length(l_str1), l_str1);
		hr_utility.set_location(to_char(ctr_table),15);
		END LOOP;
		ELSE
		  l_str1 := l_str;
		  dbms_lob.writeAppend( p_xfdf_string, length(l_str1), l_str1 );
	   END IF;
	END WritetoCLOB;
	--------------------------------------------------------------------------------
	-- POPULATE_P35_REPORT
	--------------------------------------------------------------------------------
	PROCEDURE populate_p35_rep
	  (p_bg_id IN NUMBER
	   ,p_emp_no IN VARCHAR2
	   ,p_payroll        IN NUMBER
   	   ,p_assignment_set        IN NUMBER
	   ,p_end_date IN VARCHAR2
	   ,p_weeks IN VARCHAR2
   	   ,p_template_name IN VARCHAR2
       ,p_xml         OUT NOCOPY CLOB
	   )IS
	BEGIN
	--hr_utility.TRACE_ON( null, 'IEP35XML' );
	  populate_plsql_table(p_bg_id
			   ,p_emp_no
			   ,p_payroll
   			   ,p_assignment_set
			   ,p_end_date
			   ,p_weeks);
	  WritetoCLOB (p_xml);
	END populate_p35_rep;
	--------------------------------------------------------------------------------
	-- POPULATE_PLSQL_TABLE
	--------------------------------------------------------------------------------
	PROCEDURE populate_plsql_table
	  (p_bg_id IN NUMBER
	   ,p_emp_no IN VARCHAR2
	   ,p_payroll        IN NUMBER
   	   ,p_assignment_set        IN NUMBER
	   ,p_end_date IN VARCHAR2
	    ,p_weeks IN VARCHAR2) IS

     l_start_date DATE;
	l_end_date DATE;
	l_p_payroll number;
	l_assignment_set number;
    l_set_flag	hr_assignment_set_amendments.include_or_exclude%TYPE;

	CURSOR csr_get_flag_from_set
    is
	select distinct hasa.include_or_exclude from hr_assignment_set_amendments hasa, hr_assignment_sets has
	where hasa.assignment_set_id = has.assignment_set_id
	and has.business_group_id = p_bg_id
	and has.assignment_set_id = l_assignment_set;

	CURSOR getPayrollAction IS
      SELECT distinct paa.payroll_action_id, paa.assignment_action_id,
 	    nvl(SUBSTR(pactd.action_information1,1,9),' ') PPSN,
	    -- for bug 5301598
        nvl(SUBSTR(pactd.action_information2,1,12),' ') Works,
        pactd.action_information3 TotIWeeks,
        pactd.action_information4 IClass,
        pactd.action_information5 SClass,
        pactd.action_information6 SWeeks,
        pactd.action_information7 TClass,
        pactd.action_information8 TWeeks,
        pactd.action_information9 FClass,
        pactd.action_information10 FWeeks,
        substr(pactd.action_information11,1,instr(pactd.action_information11,'-',1)-1) FifthClass,
	  substr(pactd.action_information11,instr(pactd.action_information11,'-',1)+1,length(pactd.action_information11)) FifthWeek,
        pactd.action_information12 NetTax,
        pactd.action_information13 TaxPaid,
        pactd.action_information14 EmpPRSI,
        pactd.action_information15 TotPRSI,
        pactd.action_information16 Pay,
        pactd.action_information17 TaxBasis,
        pactd.action_information18 SurName,
        pactd.action_information19 FirstName,
        to_char(to_date(trim(pactd.action_information20),'DD-MM-YYYY'),'DD/MM/YYYY') DOB,
        pactd.action_information21 Address1,
        pactd.action_information22 Address2,
        pactd.action_information23 Address3,
        to_char(to_date(trim(pactd.action_information24),'DD-MM-YYYY'),'DD/MM/YYYY') StartDate,
        decode(to_char(to_date(trim(pactd.action_information25),'DD-MM-YYYY'),'DD/MM/YYYY'),'31/12/4712',null,to_char(to_date(trim(pactd.action_information25),'DD-MM-YYYY'),'DD/MM/YYYY')) EndDate,
        pactd.action_information26 Credit,
        pactd.action_information27
        FROM pay_assignment_actions   paa,
                  pay_payroll_actions      ppa,
 				  pay_assignment_actions  paad,
                  pay_action_information  pactd,
                  pay_action_information   pai,
			per_assignments_f    paaf,
			pay_all_payrolls_f           ppf,
			hr_soft_coding_keyflex   flex
        WHERE paa.payroll_action_id = ppa.payroll_action_id
              AND paa.action_status = 'C'
              AND ppa.action_type ='X'
              AND ppa.business_group_id = p_bg_id
		  AND paa.source_action_id is null
		  AND pai.action_context_id = paa.assignment_action_id
	      AND pai.action_information_category = 'IE P35 DETAIL'
	      AND ppa.report_type = 'IEP35'
	      AND paa.assignment_id = pai.assignment_id
	      AND paaf.assignment_id = paa.assignment_id
          AND paaf.business_group_id = ppa.business_group_id
		  --For Detail Record
		  AND  paad.payroll_action_id = paa.payroll_action_id
          AND pactd.action_information_category   = 'IE P35 DETAIL'
          AND pactd.action_context_type           = 'AAP'
          AND paad.assignment_action_id = pactd.action_context_id
		  AND paad.assignment_action_id = paa.assignment_action_id
  	      --End of Detail Record
	      AND paaf.payroll_id = ppf.payroll_id
      	  AND ppf.effective_start_date <= l_end_date
          AND ppf.effective_end_date >= l_start_date
	      AND flex.soft_coding_keyflex_id = ppf.soft_coding_keyflex_id
	      AND flex.segment4 = p_emp_no
          AND paaf.effective_start_date <= l_end_date
          AND paaf.effective_end_date >= l_start_date
	      AND TO_DATE (
                                  pay_ie_p35.get_parameter (
                                     ppa.payroll_action_id,
                                     'END_DATE'
                                  ),
                                  'YYYY/MM/DD'
                               ) BETWEEN l_start_date AND l_end_date
	      AND (ppf.payroll_id in (select b.payroll_id from per_assignments_f a,per_assignments_f b
				       where a.payroll_id = l_p_payroll
					and a.person_id = b.person_id
					and a.person_id = paaf.person_id
					--bug 6642916
					and a.effective_start_date<= l_end_date
                                         and  a.effective_end_date >= l_start_date) or l_p_payroll is null)
	      AND ((l_assignment_set is not null
	     AND (l_set_flag ='I' AND EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
					 WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = p_bg_id
					  AND   has.assignment_set_id = l_assignment_set
					  AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = paaf.person_id)

		OR l_set_flag = 'E' AND NOT EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
				  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = p_bg_id
					  AND   has.assignment_set_id = l_assignment_set
					  AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = paaf.person_id)))
	  OR l_assignment_set IS NULL)
	  ORDER BY SurName, FirstName;

     CURSOR csr_get_pension_details (p_payroll_action_id NUMBER, p_assignment_action_id NUMBER) IS
     SELECT count(decode(pact.action_information2,0,null,null,null,1)) EMP_RBS,
       sum(to_number(pact.action_information2)) EMP_RBS_BAL,
       count(decode(pact.action_information3,0,null,null,null,1)) EMPR_RBS,
	 sum(to_number(pact.action_information3)) EMPR_RBS_BAL,
       count(decode(pact.action_information4,0,null,null,null,1)) EMP_PRSA,
	 sum(to_number(pact.action_information4)) EMP_PRSA_BAL,
       count(decode(pact.action_information5,0,null,null,null,1)) EMPR_PRSA,
	 sum(to_number(pact.action_information5)) EMPR_PRSA_BAL,
       count(decode(pact.action_information6,0,null,null,null,1)) EMP_RAC,
	 sum(to_number(pact.action_information6)) EMP_RAC_BAL,
	 sum(to_number(pact.action_information1)) TAXABLEBENEFITS,
       count(decode(pact.action_information23,0,null,null,null,1)) EMP_PARKING, /* knadhan */
	 sum(to_number(pact.action_information23)) EMP_PARKING_BAL,
	 sum(to_number(pact.action_information19)) EMP_INCOME_LEVY_BAL,
	 sum(to_number(pact.action_information18)) EMP_GROSS_INCOME
     FROM   pay_assignment_actions  paa
      ,pay_action_information  pact
     WHERE paa.payroll_action_id        = p_payroll_action_id
	 and paa.assignment_action_id = pact.action_context_id
	 and paa.assignment_action_id = p_assignment_action_id
    and   paa.source_action_id         is null
    and   pact.action_information_category  = 'IE P35 ADDITIONAL DETAILS'
    and   pact.action_context_type           = 'AAP';

	CURSOR csr_header_footer_info(p_payroll_action_id NUMBER) IS
	SELECT
          to_char(ppa.request_id),
          p_end_date,
	      to_char(ppa.effective_date,'dd-mm-yyyy'),
          pact.action_information1,
          pact.action_information26 ,
          pact.action_information27 ,
          pact.action_information28 ,
          pact.action_information5 ,
          pact.action_information6 ,
          pact.action_information7 ,
          decode(trim(p_weeks),'Y','1','0'),
	      'Oracle HRMS',
	      'E'
         FROM   pay_payroll_actions                ppa
        ,pay_action_information             pact
        WHERE  ppa.payroll_action_id  = p_payroll_action_id
	  AND    pact.action_context_id = ppa.payroll_action_id
	  AND    pact.action_information_category  = 'ADDRESS DETAILS'
	  AND    pact.action_context_type          = 'PA';

	r_payroll_action_id NUMBER;
	r_assgt_action_id NUMBER;
	l_request_id NUMBER;
	l_tax_year VARCHAR2(30);
	l_date VARCHAR2(30);
	l_empr_no VARCHAR2(50);
	l_empr_name VARCHAR2(150);
    l_contact_name VARCHAR2 (150);
	l_phone VARCHAR2 (30);
	l_addr1 VARCHAR2 (240);
	l_addr2 VARCHAR2 (240);
	l_addr3 VARCHAR2 (240);
	l_week53 VARCHAR2 (15);
	l_payroll VARCHAR2 (50);
	l_currency VARCHAR2 (30);
	l_tot_pay NUMBER := 0;
	l_tot_pay_rnd NUMBER := 0;
    l_tot_tax NUMBER := 0;
	l_tot_prsi NUMBER := 0;
	l_tot_emp_prsi NUMBER := 0;
    l_emp_rbs NUMBER := 0;
    l_emp_rbs_bal NUMBER := 0;
	l_empr_rbs NUMBER := 0;
    l_empr_rbs_bal NUMBER := 0;
	l_emp_prsa NUMBER := 0;
	l_emp_prsa_bal NUMBER := 0;
    l_empr_prsa NUMBER := 0;
	l_empr_prsa_bal NUMBER := 0;
	l_emp_rac NUMBER := 0;
	l_emp_rac_bal NUMBER := 0;
	l_taxable_benefits NUMBER := 0;
	flag NUMBER := 0;
	l_emp_parking NUMBER := 0; /* knadhan */
        l_emp_parking_bal NUMBER := 0;
        l_emp_income_levy_bal NUMBER := 0;
	l_emp_gross_income_bal NUMBER := 0;
	c_pension csr_get_pension_details%ROWTYPE;
    l_cess_date VARCHAR2(30);
    l_initial_class pay_action_information.action_information4%TYPE;

	BEGIN


     -- hr_utility.trace_on(null,'vikp35');
	hr_utility.set_location('Start of Generation...', 1);

   vXMLTable.DELETE;
	vCtr := 1;
	--vXMLTable(vCtr).xmlString := '<?xml version="1.0" encoding="UTF-8"?> <P35LFile>';  -- get_IANA_charset
	vXMLTable(vCtr).xmlString := '<?xml version="1.0" encoding="'|| get_IANA_charset ||'"?> <P35LFile>';
	vCtr := vCtr + 1;
	l_start_date := PAY_IE_P35_XML_PKG.get_start_date();
        -- l_end_date := PAY_IE_P35_XML_PKG.get_end_date();
        l_end_date := fnd_date.canonical_to_date(p_end_date);                              --4641756
        hr_utility.set_location('End Date : '||p_end_date,100);

	IF p_payroll = 0 then
	    l_p_payroll := NULL;
	 ELSE
	    l_p_payroll := p_payroll;
	 END IF;
	IF p_assignment_set = 0 then
	    l_assignment_set := NULL;
	ELSE
	    l_assignment_set := p_assignment_set;
	END IF;
	OPEN csr_get_flag_from_set;
    FETCH csr_get_flag_from_set into l_set_flag;
    CLOSE csr_get_flag_from_set;

	FOR c_action IN getPayrollAction LOOP
	flag := flag + 1;
	hr_utility.set_location('Loop Count ' || to_char(flag), 1);
	hr_utility.set_location('pactid' || to_char(r_payroll_action_id),13);
	IF flag = 1 THEN
    OPEN csr_header_footer_info(c_action.payroll_action_id);
	FETCH csr_header_footer_info into l_request_id, l_tax_year,l_date,l_empr_no,l_empr_name,
	      l_contact_name,l_phone,l_addr1,l_addr2,l_addr3,l_week53,l_payroll,l_currency;
	CLOSE csr_header_footer_info;
    hr_utility.set_location('emprno' || to_char(l_empr_no),13);

	vXMLTable(vCtr).xmlString := '<TaxYear>' || to_char(fnd_date.canonical_to_date(l_tax_year),'YYYY') || '</TaxYear>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<RequestID>' || l_request_id || '</RequestID>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<Date>' || l_date || '</Date>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<EmployerNumber>' || l_empr_no || '</EmployerNumber>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<EmployerName>' || l_empr_name || '</EmployerName>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<ContactName>' || l_contact_name || '</ContactName>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<Phone>' || l_phone || '</Phone>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<Address1><![CDATA[' || l_addr1 || ']]></Address1>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<Address2><![CDATA[' || l_addr2 || ']]></Address2>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<Address3><![CDATA[' || l_addr3 || ']]></Address3>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<Week53>' || l_week53 || '</Week53>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<Payroll>' || l_payroll || '</Payroll>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<Currency>' || l_currency || '</Currency>';
    vCtr := vCtr + 1;
	END IF;
	hr_utility.set_location('Fetching detail...', 3);
	hr_utility.set_location('Fetching Pension...', 3);
	OPEN csr_get_pension_details (c_action.payroll_action_id, c_action.assignment_action_id);
    FETCH csr_get_pension_details into c_pension;
    CLOSE csr_get_pension_details;
	l_emp_rbs := l_emp_rbs +  c_pension.EMP_RBS;
    l_emp_rbs_bal := l_emp_rbs_bal + c_pension.EMP_RBS_BAL;
    l_empr_rbs := l_empr_rbs + c_pension.EMPR_RBS;
	l_empr_rbs_bal := l_empr_rbs_bal +  c_pension.EMPR_RBS_BAL;
    l_emp_prsa := l_emp_prsa + c_pension.EMP_PRSA;
    l_emp_prsa_bal := l_emp_prsa_bal + c_pension.EMP_PRSA_BAL;
	l_empr_prsa := l_empr_prsa + c_pension.EMPR_PRSA;
	l_empr_prsa_bal := l_empr_prsa_bal + c_pension.EMPR_PRSA_BAL;
	l_emp_rac := l_emp_rac + c_pension.EMP_RAC;
	l_emp_rac_bal := l_emp_rac_bal + c_pension.EMP_RAC_BAL;
	l_emp_parking:=l_emp_parking+c_pension.EMP_PARKING; /* knadhan */
        l_emp_parking_bal:=l_emp_parking_bal+c_pension.EMP_PARKING_BAL;
	l_emp_income_levy_bal :=l_emp_income_levy_bal+c_pension.EMP_INCOME_LEVY_BAL;
	l_emp_gross_income_bal :=c_pension.EMP_GROSS_INCOME;
    l_taxable_benefits := l_taxable_benefits + c_pension.TAXABLEBENEFITS;
	hr_utility.set_location('Generating...', 5);
	hr_utility.set_location('TableCnt' || to_char(vXMLTable.count),13);

	l_cess_date:=c_action.EndDate;
	IF trim(l_cess_date) = '31-12-4712' THEN
	  l_cess_date := ' ';
	END IF;
	      hr_utility.set_location('P1..'||c_action.Works,100);
		vXMLTable(vCtr).xmlString := '<G_P35L>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<PPSN>' || (c_action.PPSN) || '</PPSN>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<Works>' || (c_action.Works) || '</Works>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<TotIWeeks>' || (c_action.TotIWeeks) || '</TotIWeeks>';
		hr_utility.set_location('P2..'||c_action.Works,100);
		if instr(c_action.IClass,'-') > 0 then
			l_initial_class := substr(c_action.IClass,1,instr(c_action.IClass,'-',1)-1);
			vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<IClass>' || (l_initial_class) || '</IClass>';
		else
			vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<IClass>' || (c_action.IClass) || '</IClass>';
		end if;
		hr_utility.set_location('P3..'||c_action.Works,100);
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<SClass>' || (c_action.SClass) || '</SClass>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<SWeeks>' || (c_action.SWeeks) || '</SWeeks>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<TClass>' || (c_action.TClass) || '</TClass>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<TWeeks>' || (c_action.TWeeks) || '</TWeeks>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<FClass>' || (c_action.FClass) || '</FClass>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<FWeeks>' || (c_action.FWeeks) || '</FWeeks>';
		hr_utility.set_location('P4..'||c_action.Works,100);
		IF c_action.FifthClass is not null then
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<FifthClass> Note-: PRSI Fifth Class ' || (c_action.FifthClass) || ' with Insurable Weeks </FifthClass>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<Fmessage>' || (c_action.FifthWeek) || ' exists </Fmessage>';
		ELSE
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<FifthClass>' || (c_action.FifthClass) || '</FifthClass>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<Fmessage>' || (c_action.FifthClass) || '</Fmessage>';
		END IF;
		hr_utility.set_location('P5..'||c_action.Works,100);
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<NetTax>' || to_char(to_number(c_action.NetTax),'FM99999999990D00') || '</NetTax>';
    		l_tot_tax := l_tot_tax + to_number(c_action.NetTax);
		vCtr := vCtr + 1;
		vXMLTable(vCtr).xmlString := '<TaxPaid>' || (c_action.TaxPaid) || '</TaxPaid>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<EmpPRSI>' || to_char(to_number(c_action.EmpPRSI),'FM99999999990D00') || '</EmpPRSI>';
		l_tot_emp_prsi := l_tot_emp_prsi + to_number(c_action.EmpPRSI);
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<TotPRSI>' || to_char(to_number(c_action.TotPRSI),'FM99999999990D00') || '</TotPRSI>';
		l_tot_prsi := l_tot_prsi + to_number(c_action.TotPRSI);
		hr_utility.set_location('After Adding....TotPRSI=' || l_tot_prsi, 10);
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<Pay>' || to_char(to_number(c_action.Pay),'FM99999999990D00') || '</Pay>';
		l_tot_pay := l_tot_pay + to_number(c_action.Pay);
		l_tot_pay_rnd := l_tot_pay_rnd + round(to_number(c_action.Pay),0);
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<GrossIncome>' || to_char(l_emp_gross_income_bal,'FM99999999990D00') || '</GrossIncome>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<IncomeLevy>' || to_char(to_number(c_pension.EMP_INCOME_LEVY_BAL),'FM99999999990D00') || '</IncomeLevy>';   /* knadhan 8520684 */
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<TaxBasis>' || (c_action.TaxBasis) || '</TaxBasis>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<SurName><![CDATA[' || (c_action.SurName) || ']]></SurName>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<FirstName><![CDATA[' || (c_action.FirstName) || ']]></FirstName>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<DOB>' || (c_action.DOB) || '</DOB>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<Address><![CDATA[' || (c_action.Address1) || ']]></Address>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<StartDate>' || (c_action.StartDate) || '</StartDate>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<EndDate>' || l_cess_date || '</EndDate>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<Credit>' || to_char(to_number(c_action.Credit),'FM99999999990D00') || '</Credit>';
		vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '</G_P35L>';
		vCtr := vCtr + 1;
		hr_utility.set_location('TableCnt' || to_char(vXMLTable.count),18);
	END LOOP;
	hr_utility.set_location('Generated...', 6);
	IF flag = 0 THEN
  	  vXMLTable(vCtr).xmlString := '<Exception>No Data Found</Exception>';
	  vCtr := vCtr + 1;
	END IF;
	l_emp_parking_bal:=round(to_number(l_emp_parking_bal));
        l_emp_income_levy_bal:=round(to_number(l_emp_income_levy_bal));
	vXMLTable(vCtr).xmlString := '<TotPay>' || to_char(to_number(l_tot_pay),'FM99999999990D00') || '</TotPay>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<TotPayRnd>' || l_tot_pay_rnd || '</TotPayRnd>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<TotTax>' || to_char(to_number(l_tot_tax),'FM99999999990D00') || '</TotTax>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<TotalPRSI>' || to_char(to_number(l_tot_prsi),'FM99999999990D00') || '</TotalPRSI>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<TotEmpPRSI>' || to_char(to_number(l_tot_emp_prsi),'FM99999999990D00') || '</TotEmpPRSI>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<RBSEENum>' || l_emp_rbs || '</RBSEENum>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<RBSEEAmt>' || l_emp_rbs_bal || '</RBSEEAmt>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<RBSERNum>' || l_empr_rbs || '</RBSERNum>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<RBSERAmt>' || l_empr_rbs_bal || '</RBSERAmt>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<PRSAEENum>' || l_emp_prsa || '</PRSAEENum>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<PRSAEEAmt>' || l_emp_prsa_bal || '</PRSAEEAmt>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<PRSAERNum>' || l_empr_prsa || '</PRSAERNum>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<PRSAERAmt>' || l_empr_prsa_bal || '</PRSAERAmt>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<RACEENum>' || l_emp_rac || '</RACEENum>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<RACEEAmt>' || l_emp_rac_bal || '</RACEEAmt>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<TotNotPay>' || l_taxable_benefits || '</TotNotPay>';
        vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<CARPARKNum>' || l_emp_parking || '</CARPARKNum>';   /* knadhan */
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<CARPARKAmt>' || l_emp_parking_bal || '</CARPARKAmt>';
	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '<IncomeLevyAmt>' || l_emp_income_levy_bal || '</IncomeLevyAmt>';

	vXMLTable(vCtr).xmlString := vXMLTable(vCtr).xmlString || '</P35LFile>';
	vCtr := vCtr + 1;

  	hr_utility.set_location('TableCnt' || to_char(vXMLTable.count),13);
   EXCEPTION
      WHEN OTHERS  THEN
	  null;
  END populate_plsql_table;
	--
  FUNCTION get_start_date
      RETURN DATE
   AS
      l_start_date   DATE;
   BEGIN
      SELECT fnd_date.canonical_to_date (
                   SUBSTR (fpov.profile_option_value, 1, 4)
                || '01/01 00:00:00'
             )
        INTO l_start_date
        FROM fnd_profile_option_values fpov, fnd_profile_options fpo
       WHERE fpo.profile_option_id = fpov.profile_option_id
         AND fpo.application_id = fpov.application_id
         AND fpo.profile_option_name = 'PAY_IE_P35_REPORTING_YEAR'
         AND fpov.level_id = 10001
         AND fpov.level_value = 0;

      RETURN l_start_date;
   END get_start_date;


--
   FUNCTION get_end_date
      RETURN DATE
   AS
      l_end_date   DATE;
   BEGIN
      SELECT fnd_date.canonical_to_date (
                   SUBSTR (fpov.profile_option_value, 1, 4)
                || '12/31 23:59:59'
             )
        INTO l_end_date
        FROM fnd_profile_option_values fpov, fnd_profile_options fpo
       WHERE fpo.profile_option_id = fpov.profile_option_id
         AND fpo.application_id = fpov.application_id
         AND fpo.profile_option_name = 'PAY_IE_P35_REPORTING_YEAR'
         AND fpov.level_id = 10001
         AND fpov.level_value = 0;

      RETURN l_end_date;
   END get_end_date;
   --
END PAY_IE_P35_XML_PKG;

/
