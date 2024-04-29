--------------------------------------------------------
--  DDL for Package Body PAY_IE_P45PART3_P46_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_P45PART3_P46_PKG" AS
/* $Header: pyiep45p3p46.pkb 120.0.12010000.4 2008/11/12 13:00:08 rsahai ship $ */
g_package	VARCHAR2(50)  := 'pay_ie_p45part3_p46_pkg.';
EOL		VARCHAR2(5)   := fnd_global.local_chr(10);
l_errflag VARCHAR2(1) := 'N';
l_p45_exception exception;
error_message boolean;
/*-----------------------------------------------------
				TEST_XML
-----------------------------------------------------*/

FUNCTION test_XML(P_STRING VARCHAR2) RETURN VARCHAR2 AS
	l_string varchar2(1000);

	FUNCTION replace_xml_symbols(pp_string IN VARCHAR2)
	RETURN VARCHAR2
	AS

	ll_string   VARCHAR2(1000);

	BEGIN


	ll_string :=  pp_string;

	ll_string := replace(ll_string, '&', '&amp;');
	ll_string := replace(ll_string, '<', '&#60;');
	ll_string := replace(ll_string, '>', '&#62;');
	ll_string := replace(ll_string, '''','&apos;');
	ll_string := replace(ll_string, '"', '&quot;');

	RETURN ll_string;
	EXCEPTION when no_data_found then
	null;
	END replace_xml_symbols;

begin
	l_string := p_string;
	l_string := replace_xml_symbols(l_string);
--7529405
	l_string := pay_ie_p35_magtape.test_XML(l_string);
/*
	l_string := replace(l_string,COMPOSE ('A'|| UNISTR('\0301')),'&#193;');
	l_string := replace(l_string,COMPOSE ('E'|| UNISTR('\0301')),'&#201;');
	l_string := replace(l_string,COMPOSE ('I'|| UNISTR('\0301')),'&#205;');
	l_string := replace(l_string,COMPOSE ('O'|| UNISTR('\0301')),'&#211;');
	l_string := replace(l_string,COMPOSE ('U'|| UNISTR('\0301')),'&#218;');
	l_string := replace(l_string,COMPOSE ('a'|| UNISTR('\0301')),'&#225;');
	l_string := replace(l_string,COMPOSE ('e'|| UNISTR('\0301')),'&#233;');
	l_string := replace(l_string,COMPOSE ('i'|| UNISTR('\0301')),'&#237;');
	l_string := replace(l_string,COMPOSE ('o'|| UNISTR('\0301')),'&#243;');
	l_string := replace(l_string,COMPOSE ('u'|| UNISTR('\0301')),'&#250;');
*/
	--l_string := replace_xml_symbols(l_string);
--7529405

RETURN l_string;
END ;

-----------------------------------------------------------------------
-- GET_PARAMETERS
-----------------------------------------------------------------------
 PROCEDURE get_parameters
(
   p_payroll_action_id IN  NUMBER,
   p_token_name        IN  VARCHAR2,
   p_token_value       out nocopy VARCHAR2
)  IS

 CURSOR csr_parameter_info
(
   p_pact_id NUMBER,
   p_token   CHAR
)  IS

    SELECT TRIM(SUBSTR
        (
           legislative_parameters,
           DECODE(INSTR
           (
              legislative_parameters,
              p_token
           ),0,LENGTH(legislative_parameters),INSTR
           (
              legislative_parameters,
              p_token
           )) + (LENGTH(p_token) + 1),
	DECODE(INSTR
          (
             legislative_parameters,
             ' ',
             INSTR
             (
                legislative_parameters,
                p_token
             )),0,LENGTH(legislative_parameters),INSTR
          (
             legislative_parameters,
             ' ',
             INSTR
             (
                legislative_parameters,
                p_token
             )))
           -
           (
              INSTR
              (
                 legislative_parameters,
                 p_token
              )  + LENGTH(p_token)
           )
        )),
	TRIM(business_group_id)
	   FROM pay_payroll_actions
	   WHERE payroll_action_id = p_pact_id;

 l_business_group_id            VARCHAR2(300);
 l_token_value                  VARCHAR2(300);
 l_proc                         VARCHAR2(50) := g_package ||'get_parameters';

 BEGIN

   hr_utility.set_location('Entering ' || l_proc, 100);
   hr_utility.set_location('p_token_name ' || TO_CHAR(p_token_name), 110);

   OPEN  csr_parameter_info
         (
            p_payroll_action_id,
            p_token_name
         );
   FETCH csr_parameter_info INTO l_token_value, l_business_group_id;
   CLOSE csr_parameter_info;

   hr_utility.set_location('l_token_value ' || TO_CHAR(l_token_value), 115);
   hr_utility.set_location('l_business_group_id ' || TO_CHAR(l_business_group_id), 120);

   IF p_token_name = 'BG_ID' THEN
      p_token_value := l_business_group_id;
      hr_utility.set_location('p_token_name '||p_token_name,125);
   ELSE
      p_token_value := l_token_value;
	  hr_utility.set_location('p_token_name '||p_token_name,130);
   END IF;

   hr_utility.set_location('Leaving         ' || l_proc, 135);
--
 EXCEPTION
   WHEN others THEN
   hr_utility.set_location('Leaving' || l_proc,140);
   p_token_value := NULL;
--
 END get_parameters;
-----------------------------------------------------------------------
-- GET_ALL_PARAMETERS
-----------------------------------------------------------------------
 PROCEDURE get_all_parameters(p_payroll_action_id IN   NUMBER
					,p_rep_group OUT NOCOPY VARCHAR2
					,p_payroll_id OUT NOCOPY VARCHAR2
					,p_start_date OUT NOCOPY VARCHAR2
					,p_end_date OUT NOCOPY VARCHAR2
					,p_file_type OUT NOCOPY VARCHAR2
					,p_business_Group_id OUT NOCOPY VARCHAR2
					,p_person_id OUT NOCOPY VARCHAR2
					,p_employer_id OUT NOCOPY VARCHAR2)
  IS

 BEGIN
	hr_utility.set_location(' Entering pay_ie_p45p3_p46_pkg.get_all_parameters ', 145);

	get_parameters(p_payroll_action_id,'BG_ID',p_business_Group_id);
	--get_parameters(p_payroll_action_id,'ORG_STR_VER_ID',P_Org_Struct_Version_Id);
	get_parameters(p_payroll_action_id,'REP_GROUP',p_rep_group);
	get_parameters(p_payroll_action_id,'EMPLOYER',p_employer_id);
	get_parameters(p_payroll_action_id,'PAYROLL',p_payroll_id);
	get_parameters(p_payroll_action_id,'EMPLOYEE',p_person_id);
	get_parameters(p_payroll_action_id,'FILE_TYPE',p_file_type);
	get_parameters(p_payroll_action_id,'START_DATE',p_start_date);
	get_parameters(p_payroll_action_id,'END_DATE',p_end_date);

	hr_utility.set_location(' p_business_Group_id = '||p_business_Group_id,150);
	hr_utility.set_location(' REP_GROUP = '||p_rep_group,155);
	hr_utility.set_location(' EMPLOYER = '||p_employer_id,160);
	hr_utility.set_location(' PAYROLL = '||p_payroll_id,165);
	hr_utility.set_location(' EMPLOYEE = '||p_person_id,170);
	hr_utility.set_location(' FILE_TYPE = '|| p_file_type,175);
	hr_utility.set_location(' START_DATE = '||p_start_date,180);
	hr_utility.set_location(' END_DATE = '||p_end_date,185);


    IF p_person_id IS NOT NULL THEN
         g_where_clause1 :=
      	' and ppf.person_id = '||to_char(p_person_id);
    ELSE
          g_where_clause1 :='  and 1=1 ';
    END IF;

    IF p_payroll_id IS NOT NULL THEN
       g_where_clause :=
       ' and papf.payroll_id = '||to_char(p_payroll_id);
    ELSE
          g_where_clause :='  and 1=1 ';
    END IF;

 hr_utility.set_location(' Inside get_all_parameters:g_where_clause: '||g_where_clause,190);
 hr_utility.set_location(' Inside get_all_parameters:g_where_clause1: '||g_where_clause1,195);
 --hr_utility.set_location(' Inside get_all_parameters:g_where_clause1: '||g_where_clause1,200);
 hr_utility.set_location(' Leaving: pay_ie_p45p3_p46_pkg.get_all_parameters: ', 205);

EXCEPTION
  WHEN Others THEN
    Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1215);
END get_all_parameters;
-----------------------------------------------------------------------
-- RANGE_CODE
-----------------------------------------------------------------------
 PROCEDURE range_code(pactid IN NUMBER,
		 sqlstr OUT nocopy VARCHAR2)
 IS
 l_procedure_name   VARCHAR2(100);

 l_start_date VARCHAR2(50);
 l_end_date VARCHAR2(50);

 CURSOR  csr_archive_effective_date(pactid NUMBER) IS
     SELECT effective_date
     FROM   pay_payroll_actions
     WHERE  payroll_action_id = pactid;

 CURSOR csr_employer_details(c_org_id  hr_organization_information.organization_id%type
                            ,c_bg_id hr_organization_units.business_group_id%type) IS
     select hoi.org_information2 regst_no
            ,hou.name employer_name
            ,hoi.org_information3 trade_name
            ,hla.address_line_1 addr1
            ,hla.address_line_2 addr2
            ,hla.address_line_3 addr3
            ,hoi.org_information4 contact_name
            ,hla.telephone_number_1 telphone_no
		,hla.telephone_number_2 fax
            from hr_organization_units hou
                ,hr_organization_information hoi
                ,hr_locations_all hla
              where hoi.org_information_context='IE_EMPLOYER_INFO'
              and hoi.organization_id=c_org_id
              and hoi.organization_id=hou.organization_id
              and hou.business_group_id= c_bg_id
              and hou.location_id=hla.location_id(+);

 l_employer_details csr_employer_details%rowtype;
 l_action_info_id NUMBER;
 l_ovn NUMBER;
 l_regst_no   hr_organization_information.org_information2%type;
 l_trade_name hr_organization_information.org_information3%type;
 l_employer_name  hr_organization_units.name%type;
 l_addr1     hr_locations_all.address_line_1%type;
 l_addr2     hr_locations_all.address_line_2%type;
 l_addr3     hr_locations_all.address_line_3%type;
 l_contact_name  hr_organization_information.org_information4%type;
 l_telphone_no   hr_locations_all.telephone_number_1%type;
 l_fax_no   hr_locations_all.telephone_number_2%type;

 BEGIN

 l_procedure_name := g_package||'range_code';

 hr_utility.set_location('Entering '||l_procedure_name, 200);
 hr_utility.set_location('pactid '||TO_CHAR(pactid), 200);

 sqlstr := ' select distinct p.person_id'                                       ||
             ' from   per_people_f p,'                                        ||
                    ' pay_payroll_actions pa'                                     ||
             ' where  pa.payroll_action_id = :payroll_action_id'                  ||
             ' and    p.business_group_id = pa.business_group_id'                 ||
             ' order by p.person_id';

-------------

   OPEN csr_archive_effective_date(pactid);
   FETCH csr_archive_effective_date
   INTO  g_archive_effective_date;
   CLOSE csr_archive_effective_date;

   get_all_parameters(pactid
            ,g_rep_group
            ,g_payroll_id
            ,l_start_date
            ,l_end_date
            ,g_file_type
            ,g_business_group_id
            ,g_person_id
            ,g_employer_id);

  g_start_date := fnd_date.canonical_to_date(l_start_date);
  g_end_date := fnd_date.canonical_to_date(l_end_date);

  OPEN csr_employer_details(g_employer_id, g_business_group_id);
  FETCH csr_employer_details INTO l_employer_details;
  CLOSE csr_employer_details;

  l_regst_no :=		l_employer_details.regst_no;
  l_trade_name :=		l_employer_details.trade_name;
  l_employer_name :=	l_employer_details.employer_name;
  l_addr1 :=		l_employer_details.addr1;
  l_addr2 :=		l_employer_details.addr2;
  l_addr3 :=		l_employer_details.addr3;
  l_contact_name :=	l_employer_details.contact_name;
  l_telphone_no :=	l_employer_details.telphone_no;
  l_fax_no :=		l_employer_details.fax;

IF l_regst_no IS NOT NULL AND l_employer_name IS NOT NULL THEN
    l_errflag := 'N';
    pay_action_information_api.create_action_information
    ( p_action_information_id => l_action_info_id
    ,p_action_context_id => pactid
    ,p_action_context_type => 'PA'
    ,p_object_version_number => l_ovn
    ,p_effective_date => g_end_date
    ,p_source_id => NULL
    ,p_source_text => NULL
    ,p_action_information_category => 'IE P45P3 P46 EMPLOYER'
    ,p_action_information6  => l_regst_no
    ,p_action_information7  => l_employer_name
    ,p_action_information8  => l_trade_name
    ,p_action_information9  => l_addr1
    ,p_action_information10 => l_addr2
    ,p_action_information11 => l_addr3
    ,p_action_information12 => l_contact_name
    ,p_action_information13 => l_telphone_no
    ,p_action_information14 => l_fax_no);

ELSIF l_regst_no IS NULL THEN
	Fnd_file.put_line(FND_FILE.LOG,'Employer Registered Number is missing ');
	l_errflag := 'Y';
ELSIF l_employer_name IS NULL THEN
	Fnd_file.put_line(FND_FILE.LOG,'Employer Name is missing ');
	l_errflag := 'Y';
END IF;

IF l_errflag = 'Y' THEN
      Fnd_file.put_line(FND_FILE.LOG,'P45P3 Process Failed. Some mandatory parametors are missing. Please check the whole log for details.');
	Raise l_p45_exception;
END IF;


hr_utility.set_location(' g_start_date: '||g_start_date, 205);
hr_utility.set_location(' g_end_date: '||g_end_date, 205);
hr_utility.set_location('Leaving '||l_procedure_name, 215);

 EXCEPTION
 WHEN l_p45_exception THEN
    Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1223);
    error_message := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','P46 part3 XML Process errors out.');
 WHEN Others THEN
    Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1223);
 END range_code;
 -----------------------------------------------------------------------
-- ASSIGNMENT_ACTION_CODE
-----------------------------------------------------------------------

PROCEDURE assignment_action_code(pactid in number,
					   stperson in number,
					   endperson in number,
					   chunk in number)
IS
    l_assg_id per_assignments_f.assignment_id%TYPE;
    l_person_id Number;
    l_assignment_number per_all_assignments_f.assignment_number%type;
    l_period_of_service_id per_all_assignments_f.period_of_service_id%type;

    l_prev_person_id Number := 0;
    l_prev_period_of_service_id per_all_assignments_f.period_of_service_id%type := 0;

    l_start_date VARCHAR2(50);
    l_end_date VARCHAR2(50);
    l_select_str VARCHAR2(3000);
    lockingactid NUMBER;
    l_valid_assg boolean := False;
    l_file_type pay_element_entry_values_f.screen_entry_value%TYPE;
    l_submitted pay_element_entry_values_f.screen_entry_value%TYPE;
    l_element_name varchar2(50);
    TYPE asg_ref IS REF CURSOR;
    csr_get_asg asg_ref;

 -- Cursor to check already archived assignment
 /*CURSOR csr_already_archived (p_assg_id number) IS
        SELECT nvl(peev.screen_entry_value,'N')
            FROM pay_element_types_f pet,
              pay_input_values_f piv,
              pay_element_entries_f pee,
              pay_element_entry_values_f peev,
              per_all_assignments_f paa
              WHERE pet.element_name='IE P45P3_P46 Information'
              AND piv.name='P45P3 Or P46 Processed'
              AND pet.element_type_id=piv.element_type_id
              AND paa.assignment_id=p_assg_id
              AND pee.element_type_id=pet.element_type_id
              AND pee.assignment_id=paa.assignment_id
              AND pee.element_entry_id=peev.element_entry_id
              AND piv.input_value_id=peev.input_value_id
              --AND peev.effective_start_date between g_start_date and g_end_date
              --AND pee.effective_start_date between g_start_date and g_end_date
		  Order by paa.assignment_id; */
             --FOR UPDATE OF screen_entry_value;

	-- Cursor to check already archived assignment
	CURSOR csr_already_archived (p_assg_id number, p_bg_id in number)
	IS
	select 'Y'
	FROM
	pay_payroll_actions ppa,
	pay_assignment_actions paa,
	PAY_ACTION_INFORMATION pai
	WHERE
	paa.payroll_action_id = ppa.payroll_action_id
	AND ppa.action_type = 'X'
	AND ppa.business_group_id = p_bg_id
	AND ppa.action_status = 'C'
	AND ppa.report_type = 'IE_P45P3_P46'
	AND ppa.report_qualifier = 'IE'
	and pai.action_context_id = paa.assignment_action_id
	and pai.action_information_category = 'IE_P45P3_P46_DETAILS'
	AND paa.assignment_id = p_assg_id
	AND pai.action_context_type = 'AAP';

   --cursor to check the file type(P45/P46) of the assignment
 CURSOR csr_scr_ent_val(c_asg_id IN Number,c_element_name in varchar2)  IS
        SELECT peev.screen_entry_value P45P3_P46_Processed
            FROM pay_element_types_f pet,
                 pay_input_values_f piv,
                 pay_element_entries_f pee,
                 pay_element_entry_values_f peev
                 WHERE pet.element_name = 'IE P45P3_P46 Information'
                 and piv.name =c_element_name
                 and pet.legislation_code = 'IE'
                 and piv.element_type_id=pet.element_type_id
                 and pee.element_type_id=pet.element_type_id
                 and pee.assignment_id =c_asg_id
                 --and pee.effective_start_date between g_start_date and g_end_date
                 and peev.element_entry_id=pee.element_entry_id
                 and peev.input_value_id=piv.input_value_id;
                 --and peev.effective_start_date between g_start_date and g_end_date

    --and peev.screen_entry_value=g_file_type_v;
      --to check wheteher the employee has an assg with the paye ref before
/* CURSOR csr_ass_check (c_assignment_id IN Number, p_person_id IN Number) IS
        select 'X'
            from per_all_assignments_f paa
            where paa.assignment_id=c_assignment_id
            and not exists
            (select 1
		 from per_all_assignments_f paaf, pay_all_payrolls_f papf, hr_soft_coding_keyflex scl
		 where paaf.person_id=paa.person_id
             and paaf.effective_start_date < paa.effective_start_date
             and paaf.effective_end_date > g_end_date
             and paaf.organization_id=paa.organization_id
		 and paaf.person_id = p_person_id
		 AND paaf.payroll_id = papf.payroll_id
		 AND papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
		 AND scl.segment4 = to_char(g_employer_id)
		 ); */

 l_ass_check  varchar2(1);
 l_csr_already_archived pay_element_entry_values_f.screen_entry_value%TYPE := 'N';
 BEGIN
 hr_utility.set_location('Entering pay_ie_p45p3_p46_pkg.assignment_action_code',220);

-- Get all the parameters
   get_all_parameters(pactid
            ,g_rep_group
            ,g_payroll_id
            ,l_start_date
            ,l_end_date
            ,g_file_type
            ,g_business_group_id
            ,g_person_id
            ,g_employer_id);

 g_start_date := fnd_date.canonical_to_date(l_start_date);
 g_end_date := fnd_date.canonical_to_date(l_end_date);
 g_pact_id := pactid;

 hr_utility.set_location('after get_all_parameter called',225);
 hr_utility.set_location('report start date= '||g_start_date,300);

  -- Query to fetch assignment_id.
 /*l_select_str :=    'select distinct paaf.assignment_id, ppf.person_id from
                            per_all_assignments_f paaf,
                            per_all_people_f ppf,
                            pay_all_payrolls_f papf,
                            pay_payroll_actions ppa,
	   		          hr_soft_coding_keyflex scl
                            where paaf.business_group_id = '|| g_business_group_id
                            ||' and paaf.effective_start_date between '||''''||g_start_date||''''||' and '
                            ||''''||g_end_date||''''
				    ||' and paaf.person_id = ppf.person_id '
                            ||' and ppf.person_id between '|| stperson || ' AND ' || endperson
                            ||g_where_clause1
                            ||' and papf.business_group_id = paaf.business_group_id '
                            ||' and ppa.payroll_action_id = '||pactid
                            ||' and papf.payroll_id = paaf.payroll_id '
                            ||' and papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id '
				    ||' and scl.segment4 = to_char('||g_employer_id||') '
                            ||g_where_clause
				    ||' Order by paaf.assignment_id '; */

  -- Query to fetch assignment_id.
 l_select_str :=    'select distinct paaf.assignment_id asgid, ppf.person_id perid, pps.period_of_service_id, paaf.assignment_number
				    from
                            per_all_assignments_f paaf,
                            per_all_people_f ppf,
                            pay_all_payrolls_f papf,
                            pay_payroll_actions ppa,
	   		          hr_soft_coding_keyflex scl,
				    per_periods_of_service pps
                            where paaf.business_group_id = '|| g_business_group_id
                            ||' and paaf.effective_start_date between '||''''||g_start_date||''''||' and '
                            ||''''||g_end_date||''''
				    ||' and paaf.person_id = ppf.person_id '
                            ||' and ppf.person_id between '|| stperson || ' AND ' || endperson
                            ||g_where_clause1
                            ||' and papf.business_group_id = paaf.business_group_id '
                            ||' and ppa.payroll_action_id = '||pactid
                            ||' and papf.payroll_id = paaf.payroll_id '
                            ||' and papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id '
				    ||' and scl.segment4 = to_char('||g_employer_id||') '
                            ||g_where_clause
				    ||' and pps.person_id = ppf.person_id '
				    ||' and pps.business_group_id = paaf.business_group_id '
				    ||' and pps.period_of_service_id = paaf.period_of_service_id '
				    ||' and pps.date_start between '||''''||g_start_date||''''||' and '||''''||g_end_date||''''
				    ||' and paaf.effective_start_date between pps.date_start and '||''''||g_end_date||''''
				    ||' Order by ppf.person_id, paaf.assignment_number, paaf.assignment_id ';

hr_utility.set_location('l_select_str'||l_select_str,225);

/*
    OPEN csr_get_asg FOR l_select_str; -- ref cursor
     LOOP
       hr_utility.set_location(' Inside ass action code, inside loop for ref cursor',230);
       FETCH csr_get_asg INTO l_assg_id, l_person_id;
       EXIT WHEN csr_get_asg%NOTFOUND;
       hr_utility.set_location(' Inside ass action code,l_assg_id: '||l_assg_id,235);
        -- Check if the report is already run for this assignment, dont run it again
        l_csr_already_archived := NULL;
        l_ass_check :=NULL;
        l_valid_assg  := False;
       OPEN csr_already_archived(l_assg_id);
       FETCH csr_already_archived INTO l_csr_already_archived;
     --  EXIT WHEN csr_already_archived%NOTFOUND;
       CLOSE csr_already_archived;
       hr_utility.set_location(' l_csr_already_archived: '||l_csr_already_archived,240);
       IF l_csr_already_archived ='N' THEN  -- means report has not run previously
         OPEN csr_ass_check(l_assg_id, l_person_id);
         FETCH csr_ass_check into l_ass_check;
         CLOSE csr_ass_check;
        hr_utility.set_location('any assg before:'||l_ass_check, 250);
        IF (l_ass_check='X') THEN --THERE R NO ASSG BEFORE
           l_element_name :='Already Submitted';
              OPEN csr_scr_ent_val(l_assg_id,l_element_name);
              --hr_utility.set_location(' Inside ass action code, inside loop for ref cursor',250);
              FETCH csr_scr_ent_val INTO l_submitted;
              hr_utility.set_location(' Inside ass action code, inside loop for ref cursor'||l_submitted,250);
              CLOSE csr_scr_ent_val;
          IF (l_submitted='N') then --not submitted online
                l_element_name :='P45P3 Or P46';
                OPEN csr_scr_ent_val(l_assg_id,l_element_name);
                FETCH csr_scr_ent_val INTO l_file_type;
                hr_utility.set_location(' Inside ass action code, inside loop for ref cursor'||l_file_type,245);
                CLOSE csr_scr_ent_val;
            IF (g_file_type='P46' AND l_file_type='Y') THEN --file type is p46
                l_valid_assg := TRUE;
            END IF;  --file type is p46
            IF (g_file_type='P45P3' AND l_file_type='N') THEN   --file type is p45p3
                   l_valid_assg := TRUE;
            END IF;  --file type is p45p3
          END IF; --not submitted online
        END IF; --THERE R NO ASSG BEFORE
    IF (l_valid_assg = TRUE) THEN
      hr_utility.set_location('inserting into ASSIGNMENT_ACTIONS', 255);
      SELECT pay_assignment_actions_s.nextval
            INTO lockingactid
            FROM dual;
      hr_utility.set_location('assignment_action_code, the assignment id finally picked up: '||l_assg_id, 1083);
                 -- Insert assignment into PAY_ASSIGNMENT_ACTIONS TABLE
      hr_nonrun_asact.insact(lockingactid => lockingactid
                                   ,assignid     => l_assg_id
                                   ,pactid       => pactid
                                   ,chunk        => chunk
                                   ,greid        => NULL);
    END IF; -- processing of assignment
   -- UPDATE pay_element_entry_values_f SET screen_entry_value='Y' WHERE CURRENT OF csr_already_archived;
        --ELSE
    -- hr_utility.set_location('assignment_action_code, the assignment id finally',980);
    END IF; -- Already processed assignment check

     END LOOP;-- ref cursor
 */
l_prev_person_id := 0;
l_prev_period_of_service_id := 0;

 OPEN csr_get_asg FOR l_select_str; -- ref cursor
 LOOP
	hr_utility.set_location(' Inside ass action code, inside loop for ref cursor',230);
	FETCH csr_get_asg INTO l_assg_id, l_person_id, l_period_of_service_id, l_assignment_number;
	EXIT WHEN csr_get_asg%NOTFOUND;

	hr_utility.set_location(' l_assg_id: '||l_assg_id,235);
	hr_utility.set_location(' l_person_id: '||l_person_id,235);
	hr_utility.set_location(' l_period_of_service_id: '||l_period_of_service_id,235);
	hr_utility.set_location(' l_assignment_number: '||l_assignment_number,235);
	hr_utility.set_location(' l_prev_person_id: '||l_prev_person_id,235);
	hr_utility.set_location(' l_prev_period_of_service_id: '||l_prev_period_of_service_id,235);

	--IF l_prev_person_id <> l_person_id and l_prev_period_of_service_id <> l_period_of_service_id THEN
	IF l_prev_period_of_service_id <> l_period_of_service_id THEN
	l_valid_assg  := False;
	l_csr_already_archived := 'N';
	l_submitted := 'Y';
	l_file_type := NULL;

	OPEN csr_already_archived(l_assg_id,g_business_group_id);
	FETCH csr_already_archived INTO l_csr_already_archived;
	CLOSE csr_already_archived;

	hr_utility.set_location(' l_csr_already_archived: '||l_csr_already_archived,240);
	   --
	   IF l_csr_already_archived ='N' THEN  -- means report has not run previously

		hr_utility.set_location('any assg before:'||l_ass_check, 250);
		l_element_name :='Already Submitted';

		OPEN csr_scr_ent_val(l_assg_id,l_element_name);
		--hr_utility.set_location(' Inside ass action code, inside loop for ref cursor',250);
		FETCH csr_scr_ent_val INTO l_submitted;
		hr_utility.set_location(' Inside ass action code, inside loop for ref cursor'||l_submitted,250);
		CLOSE csr_scr_ent_val;
		--
		hr_utility.set_location('any assg before:'||l_ass_check, 250);
		IF (l_submitted='N') then --not submitted online
			l_element_name :='P45P3 Or P46';
			OPEN csr_scr_ent_val(l_assg_id,l_element_name);
			FETCH csr_scr_ent_val INTO l_file_type;
			hr_utility.set_location(' Inside ass action code, inside loop for ref cursor'||l_file_type,245);
			CLOSE csr_scr_ent_val;

			IF (g_file_type='P46' AND l_file_type='Y') THEN --file type is p46
			  l_valid_assg := TRUE;
			ELSIF (g_file_type='P45P3' AND l_file_type='N') THEN --file type is p45p3
			  l_valid_assg := TRUE;
			END IF;
		END IF; --not submitted online
		--

		IF (l_valid_assg = TRUE) THEN
			hr_utility.set_location('inserting into ASSIGNMENT_ACTIONS', 255);
			SELECT pay_assignment_actions_s.nextval
			INTO lockingactid
			FROM dual;

			hr_utility.set_location('assignment_action_code, the assignment id finally picked up: '||l_assg_id, 1083);
			-- Insert assignment into PAY_ASSIGNMENT_ACTIONS TABLE
			hr_nonrun_asact.insact(lockingactid => lockingactid
						,assignid     => l_assg_id
						,pactid       => pactid
						,chunk        => chunk
						,greid        => NULL);
		END IF; -- processing of assignment
		--
	   END IF;	-- Already processed assignment check
	END IF;	-- If a person with more assignments having same period of service then pick only once.
	l_prev_person_id := l_person_id;
	l_prev_period_of_service_id := l_period_of_service_id;
	--
 END LOOP;-- ref cursor

 END assignment_action_code;
 -----------------------------------------------------------------------
-- ARCHIVE_INIT
-----------------------------------------------------------------------

 PROCEDURE archive_init(p_payroll_action_id IN NUMBER)
 IS
 l_start_date VARCHAR2(50);
 l_end_date VARCHAR2(50);


 CURSOR  csr_archive_effective_date(pactid NUMBER) IS
     SELECT effective_date
     FROM   pay_payroll_actions
     WHERE  payroll_action_id = pactid;

 /*
 CURSOR csr_employer_details(c_org_id  hr_organization_information.organization_id%type
                            ,c_bg_id hr_organization_units.business_group_id%type) IS
     select hoi.org_information2 regst_no
            ,hou.name employer_name
            ,hoi.org_information3 trade_name
            ,hla.address_line_1 addr1
            ,hla.address_line_2 addr2
            ,hla.address_line_3 addr3
            ,hoi.org_information4 contact_name
            ,hla.telephone_number_1 telphone_no
		,hla.telephone_number_2 fax
            from hr_organization_units hou
                ,hr_organization_information hoi
                ,hr_locations_all hla
              where hoi.org_information_context='IE_EMPLOYER_INFO'
              and hoi.organization_id=c_org_id
              and hoi.organization_id=hou.organization_id
              and hou.business_group_id= c_bg_id
              and hou.location_id=hla.location_id(+);

 l_employer_details csr_employer_details%rowtype;
 l_action_info_id NUMBER;
 l_ovn NUMBER;
 l_regst_no   hr_organization_information.org_information2%type;
 l_trade_name hr_organization_information.org_information3%type;
 l_employer_name  hr_organization_units.name%type;
 l_addr1     hr_locations_all.address_line_1%type;
 l_addr2     hr_locations_all.address_line_2%type;
 l_addr3     hr_locations_all.address_line_3%type;
 l_contact_name  hr_organization_information.org_information4%type;
 l_telphone_no   hr_locations_all.telephone_number_1%type;
 l_fax_no   hr_locations_all.telephone_number_2%type;
 */
  BEGIN
   hr_utility.set_location('Entering: pay_ie_p45p3_p46_pkg.archive_init: ',940);

   OPEN csr_archive_effective_date(p_payroll_action_id);
   FETCH csr_archive_effective_date
   INTO  g_archive_effective_date;
   CLOSE csr_archive_effective_date;

   get_all_parameters(p_payroll_action_id
            ,g_rep_group
            ,g_payroll_id
            ,l_start_date
            ,l_end_date
            ,g_file_type
            ,g_business_group_id
            ,g_person_id
            ,g_employer_id);

  g_start_date := fnd_date.canonical_to_date(l_start_date);
  g_end_date := fnd_date.canonical_to_date(l_end_date);

/*
  OPEN csr_employer_details(g_employer_id, g_business_group_id);
  FETCH csr_employer_details INTO l_employer_details;
  CLOSE csr_employer_details;
  l_regst_no := l_employer_details.regst_no;
  l_trade_name:= l_employer_details.trade_name;
  l_employer_name:= l_employer_details.employer_name;
  l_addr1:= l_employer_details.addr1;
  l_addr2:= l_employer_details.addr2;
  l_addr3:= l_employer_details.addr3;
  l_contact_name := l_employer_details.contact_name;
  l_telphone_no:= l_employer_details.telphone_no;
  l_fax_no:= l_employer_details.fax;

    pay_action_information_api.create_action_information
    ( p_action_information_id => l_action_info_id
    ,p_action_context_id => p_payroll_action_id
    ,p_action_context_type => 'PA'
    ,p_object_version_number => l_ovn
    ,p_effective_date => g_end_date
    ,p_source_id => NULL
    ,p_source_text => NULL
    ,p_action_information_category => 'IE P45P3 P46 EMPLOYER'
    ,p_action_information6  => l_regst_no
    ,p_action_information7  => l_employer_name
    ,p_action_information8  => l_trade_name
    ,p_action_information9  => l_addr1
    ,p_action_information10 => l_addr2
    ,p_action_information11 => l_addr3
    ,p_action_information12 => l_contact_name
    ,p_action_information13 => l_telphone_no
    ,p_action_information14 => l_fax_no);
*/
    hr_utility.set_location(' g_start_date: '||g_start_date, 945);
    hr_utility.set_location(' g_end_date: '||g_end_date, 950);
    hr_utility.set_location(' pay_ie_p45p3_p46_pkg.archive_init', 955);

    EXCEPTION
      WHEN Others THEN
        Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1211);

 END archive_init;
 -----------------------------------------------------------------------
-- ARCHIVE_DATA
-----------------------------------------------------------------------
 PROCEDURE archive_data(p_assactid in number,
                        p_effective_date in date)
 IS
 CURSOR csr_get_assg_detail(passactid IN NUMBER)IS
  SELECT piv.name input_name,peev.screen_entry_value input_value
  FROM pay_element_types_f pet,
      pay_input_values_f piv,
      pay_element_entries_f pee,
      pay_element_entry_values_f peev,
      per_all_assignments_f paa,
      pay_assignment_actions paac
  WHERE pet.element_name in ('IE P45P3_P46 Information','IE P45 Information')
              --AND piv.name='P45P3 Or P46 Processed'
              AND pet.element_type_id=piv.element_type_id
              AND paa.assignment_id=paac.assignment_id
              AND pee.element_type_id=pet.element_type_id
              AND pee.assignment_id=paa.assignment_id
              AND pee.element_entry_id=peev.element_entry_id
              AND piv.input_value_id=peev.input_value_id
              AND paac.assignment_action_id=passactid;
              --AND peev.effective_start_date between g_start_date and g_end_date
              --AND peev.effective_end_date > g_end_date;

 CURSOR csr_person_details(passactid IN NUMBER) IS
    SELECT	   ppf.national_identifier ppsn
              ,ppf.first_name firstname
		  ,ppf.last_name surname
		  ,ppf.effective_start_date emp_start_date
              ,pa.address_line1 addr1
              ,pa.address_line2 addr2
              ,pa.address_line3 addr3
              ,paa.assignment_number unit
              --,pap.period_type frequency
		  ,decode(pap.period_type,'Lunar Month','W',decode(instr(pap.period_type,'Week'),0,'M','W')) frequency
-- Bug# 7005067
		  ,NULL addr4
		  ,pa.TOWN_OR_CITY City
		  --,substr(pa.DERIVED_LOCALE,1,instr(pa.DERIVED_LOCALE,',',-1)-1) COUNTY
		  ,flv.meaning COUNTY
		  ,pc.NAME Country_Name
		  ,pa.country
-- Bug# 7005067
    FROM per_all_people_f ppf,
              per_addresses pa,
              per_all_assignments_f paa,
              pay_all_payrolls_f pap,
              pay_assignment_actions ppaa,
		  pa_country_v pc,						-- Bug# 7005067
  		  fnd_lookup_values flv						-- Bug# 7005067
    WHERE ppaa.assignment_action_id=passactid
              AND ppaa.assignment_id=paa.assignment_id
              AND paa.person_id=ppf.person_id
              AND ppf.person_id=pa.person_id(+)
              AND pap.payroll_id=paa.payroll_id
              AND pap.business_group_id=paa.business_group_id
              AND ppf.business_group_id=paa.business_group_id
		  AND pa.country = pc.country_code (+)		-- Bug# 7005067
              AND pa.style(+) LIKE 'IE%'				--6817160
		  AND pa.primary_flag(+) = 'Y'
		  AND flv.lookup_type(+) = 'IE_COUNTY'		-- Bug# 7005067
		  AND flv.language(+) = 'US'				-- Bug# 7005067
		  AND flv.lookup_code(+) = pa.region_1		-- Bug# 7005067
		  AND ppf.effective_start_date between pa.date_from(+) and nvl(pa.date_to, p_effective_date)
		  AND paa.effective_start_date between ppf.effective_start_date and ppf.effective_end_date
		  AND paa.effective_start_date = (select min(paa1.effective_start_date)
								from per_all_assignments_f paa1
								where paa1.assignment_id = paa.assignment_id
								and paa1.effective_start_date between g_start_date and g_end_date );

 TYPE r_get_assg_detail IS RECORD (i_name pay_input_values_f.name%type,
                                 i_value pay_element_entry_values_f.screen_entry_value%type);
 TYPE t_get_assg_detail IS TABLE OF r_get_assg_detail INDEX BY Binary_Integer;
/*
 CURSOR csr_archive_processed(passactid IN NUMBER) IS
 SELECT peev.screen_entry_value
    from pay_element_types_f pet,
         pay_input_values_f piv,
         pay_element_entries_f pee,
         pay_element_entry_values_f peev,
         per_all_assignments_f paa,
         pay_assignment_actions paac
          WHERE pet.element_name = 'IE P45P3_P46 Information'
              AND piv.name='P45P3 Or P46 Processed'
              AND pet.element_type_id=piv.element_type_id
              AND paa.assignment_id=paac.assignment_id
              AND pee.element_type_id=pet.element_type_id
              AND pee.assignment_id=paa.assignment_id
              AND pee.element_entry_id=peev.element_entry_id
              AND piv.input_value_id=peev.input_value_id
              AND paac.assignment_action_id=passactid
              FOR UPDATE OF screen_entry_value;
 */

 l_per_emp_start_date varchar2(50);

 l_archive_processed pay_element_entry_values_f.screen_entry_value%type;
 l_get_assg_detail t_get_assg_detail;
 l_person_details csr_person_details%rowtype;

 i number ;
 l_pay_to_date pay_element_entry_values_f.screen_entry_value%type;
 l_tax_to_date pay_element_entry_values_f.screen_entry_value%type;
 l_pay_employment pay_element_entry_values_f.screen_entry_value%type;
 l_tax_employment pay_element_entry_values_f.screen_entry_value%type;
 l_paye_employer pay_element_entry_values_f.screen_entry_value%type;
 l_emp_start_date pay_element_entry_values_f.screen_entry_value%type;
 l_emp_end_date pay_element_entry_values_f.screen_entry_value%type;
 l_action_info_id NUMBER(15);
 l_ovn  NUMBER;
 l_refund varchar2(10);

-- Bug# 7005067
 Type tab_address is table of per_addresses.ADDRESS_LINE1%type index by binary_integer;
 pl_address tab_address;
 pl_address_final tab_address;
 k NUMBER(3) := 0;
-- Bug# 7005067

 BEGIN
  hr_utility.set_location(' Entering pay_ie_p45p3_p46_pkg.ARCHIVE_CODE: ',1100);
  hr_utility.set_location('g_pact_id '||TO_CHAR(g_pact_id),1105);
  hr_utility.set_location('p_assignment_action_id '||TO_CHAR(p_assactid),1110);

  OPEN csr_person_details(p_assactid);
  FETCH csr_person_details into l_person_details;
  CLOSE csr_person_details;

-- Bug# 7005067
hr_utility.set_location(' Before deleting the PL table pl_address. ',1100);
  pl_address.delete;

hr_utility.set_location(' Initializing the PL table pl_address. ',1100);
  pl_address(1) := l_person_details.addr1;
  pl_address(2) := l_person_details.addr2;
  pl_address(3) := l_person_details.addr3;
  pl_address(4) := l_person_details.City;
  pl_address(5) := l_person_details.COUNTY;
  pl_address(6) := l_person_details.Country_Name;

hr_utility.set_location(' pl_address.COUNT: '||pl_address.COUNT,1100);

hr_utility.set_location(' pl_address(1): '||pl_address(1),1100);
hr_utility.set_location(' pl_address(2): '||pl_address(2),1100);
hr_utility.set_location(' pl_address(3): '||pl_address(3),1100);
hr_utility.set_location(' pl_address(4): '||pl_address(4),1100);
hr_utility.set_location(' pl_address(5): '||pl_address(5),1100);
hr_utility.set_location(' pl_address(6): '||pl_address(6),1100);

hr_utility.set_location(' Before deleting the PL table pl_address_final. ',1100);
  pl_address_final.delete;
hr_utility.set_location(' Initializing the PL table pl_address_final. ',1100);

  FOR j in 1..pl_address.LAST
  LOOP
   IF pl_address(j) IS NOT NULL THEN
	k:=k+1;
	pl_address_final(k) := pl_address(j);
	hr_utility.set_location('pl_address_final'||k||'--'||pl_address_final(k),1100);
   END IF;
  END LOOP;

hr_utility.set_location(' Re Initializing the record l_person_details. ',1100);



hr_utility.set_location(' Re Initializing the cursor record l_person_details with actual values. ',1100);
hr_utility.set_location(' pl_address_final.COUNT: '||pl_address_final.COUNT,1100);

  IF pl_address_final.COUNT > 0 THEN

	l_person_details.addr1 := NULL;
	l_person_details.addr2 := NULL;
	l_person_details.addr3 := NULL;
	l_person_details.addr4 := NULL;

	  FOR l in 1..pl_address_final.LAST
	  LOOP
	hr_utility.set_location(' Inside the loop of PL table pl_address_final',1100);
	    BEGIN
		    IF l = 1 THEN
	hr_utility.set_location(' l_person_details.addr1 ',1100);
		     l_person_details.addr1 := pl_address_final(1);
	hr_utility.set_location(' l_person_details.addr1 ',1101);
		    END IF;
		    --
		    IF l = 2 THEN
	hr_utility.set_location(' l_person_details.addr2 ',1102);
		     l_person_details.addr2 := pl_address_final(2);
	hr_utility.set_location(' l_person_details.addr2 ',1103);
		    END IF;
		    --
		    IF l = 3 THEN
	hr_utility.set_location(' l_person_details.addr3 ',1104);
		     l_person_details.addr3 := pl_address_final(3);
	hr_utility.set_location(' l_person_details.addr3 ',1105);
		    END IF;
		    --
		    IF l = 4 THEN
	hr_utility.set_location(' l_person_details.addr4 ',1106);
		     l_person_details.addr4 := pl_address_final(4);
	hr_utility.set_location(' l_person_details.addr4 ',1107);
		    END IF;
	    EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		NULL;
	    END;
	  END LOOP;
  END IF;
hr_utility.set_location(' After Re Initializing the cursor record l_person_details with actual values. ',1100);
-- Bug# 7005067

  l_per_emp_start_date := fnd_date.date_to_canonical(l_person_details.emp_start_date);

  i:=1;
  l_refund :='false';
  OPEN csr_get_assg_detail(p_assactid);
   LOOP
    hr_utility.set_location(' Inside ass action code, inside loop for ref cursor',230);
    FETCH csr_get_assg_detail INTO l_get_assg_detail(i).i_name,l_get_assg_detail(i).i_value;
    i:=i+1;
    EXIT WHEN csr_get_assg_detail%notfound;
   END LOOP;
  CLOSE csr_get_assg_detail;

  FOR i IN l_get_assg_detail.first..l_get_assg_detail.last
    LOOP
     CASE WHEN l_get_assg_detail(i).i_name='Pay To Date' THEN
              l_pay_to_date:=l_get_assg_detail(i).i_value;
          WHEN l_get_assg_detail(i).i_name='Tax Deducted To Date' THEN
              l_tax_to_date:=l_get_assg_detail(i).i_value;
          WHEN l_get_assg_detail(i).i_name='Pay This Employment' THEN
              l_pay_employment:=l_get_assg_detail(i).i_value;
          WHEN  l_get_assg_detail(i).i_name='Tax This Employment' THEN
            IF l_get_assg_detail(i).i_value<0 THEN
                l_refund:='true';
            END IF;
              l_tax_employment:=abs(l_get_assg_detail(i).i_value);
          WHEN l_get_assg_detail(i).i_name='PAYE Previous Employer' THEN
              l_paye_employer:=l_get_assg_detail(i).i_value;
          WHEN l_get_assg_detail(i).i_name='Previous Employment Start Date' THEN
              l_emp_start_date:=l_get_assg_detail(i).i_value;
          WHEN l_get_assg_detail(i).i_name='Previous Employment End Date'THEN
              l_emp_end_date:=l_get_assg_detail(i).i_value;
         ELSE
          null;
     END CASE;
    END LOOP;
    hr_utility.set_location('archive data',1200);
   --
   -- archive the details
   IF  l_person_details.ppsn IS NOT NULL
   AND l_person_details.surname IS NOT NULL
   AND l_person_details.firstname IS NOT NULL
   AND l_person_details.emp_start_date IS NOT NULL
   AND (g_file_type = 'P45P3' AND l_emp_end_date IS NOT NULL AND l_paye_employer IS NOT NULL
        OR (g_file_type = 'P46' AND l_person_details.addr1 IS NOT NULL
				        AND l_person_details.addr2 IS NOT NULL
	     )
	 )
   THEN
	l_errflag := 'N';
	     pay_action_information_api.create_action_information (
		   p_action_information_id        =>  l_action_info_id
		 , p_action_context_id            =>  p_assactid
		 , p_action_context_type          =>  'AAP'
		 , p_object_version_number        =>  l_ovn
		 , p_effective_date               =>  g_archive_effective_date
		 , p_source_id                    =>  NULL
		 , p_source_text                  =>  NULL
		 , p_action_information_category  =>  'IE_P45P3_P46_DETAILS'
		 , p_action_information6          =>  g_file_type
		 , p_action_information7          =>  l_person_details.ppsn
		 , p_action_information8          =>  l_person_details.surname
		 , p_action_information9          =>  l_person_details.firstname
		 , p_action_information10         =>  l_person_details.addr1
		 , p_action_information11         =>  l_person_details.addr2
		 , p_action_information12         =>  l_person_details.addr3
		 , p_action_information13         =>  l_person_details.addr4
		 , p_action_information14         =>  l_per_emp_start_date  --l_person_details.emp_start_date
		 , p_action_information15         =>  l_person_details.unit
		 , p_action_information16         =>  l_person_details.frequency
		 , p_action_information17         =>  l_emp_start_date
		 , p_action_information18         =>  l_emp_end_date
		 , p_action_information19         =>  l_pay_to_date
		 , p_action_information20         =>  l_tax_to_date
		 , p_action_information21         =>  l_pay_employment
		 , p_action_information22         =>  l_tax_employment
		 , p_action_information23         =>  l_refund
		 , p_action_information24         =>  l_paye_employer
		 );

		 hr_utility.set_location('after archive data',1200);
	ELSIF l_person_details.ppsn IS NULL THEN
		Fnd_file.put_line(FND_FILE.LOG,'Employee PPSN number is missing. Assignment Number: '||l_person_details.unit);
		l_errflag := 'Y';
	ELSIF l_person_details.surname IS NULL THEN
		Fnd_file.put_line(FND_FILE.LOG,'Employee Surname is missing. Assignment Number: '||l_person_details.unit);
		l_errflag := 'Y';
	ELSIF l_person_details.firstname IS NULL THEN
		Fnd_file.put_line(FND_FILE.LOG,'Employee Firstname is missing. Assignment Number: '||l_person_details.unit);
		l_errflag := 'Y';
	ELSIF l_person_details.emp_start_date IS NULL THEN
		Fnd_file.put_line(FND_FILE.LOG,'Employee New Employment commencement date is missing. Assignment Number: '||l_person_details.unit);
		l_errflag := 'Y';
	ELSIF g_file_type = 'P46' AND l_person_details.addr1 IS NULL THEN
		Fnd_file.put_line(FND_FILE.LOG,'Employee address line one is missing. Assignment Number: '||l_person_details.unit);
		l_errflag := 'Y';
	ELSIF g_file_type = 'P46' AND l_person_details.addr2 IS NULL THEN
		Fnd_file.put_line(FND_FILE.LOG,'Employee address line two is missing. Assignment Number: '||l_person_details.unit);
		l_errflag := 'Y';
	ELSIF g_file_type = 'P45P3' AND l_emp_end_date IS NULL THEN
		Fnd_file.put_line(FND_FILE.LOG,'Employee Previous employment leaving date is missing. Assignment Number: '||l_person_details.unit);
		l_errflag := 'Y';
	ELSIF g_file_type = 'P45P3' AND l_paye_employer IS NULL THEN
		Fnd_file.put_line(FND_FILE.LOG,'Employee Previous employment PAYE Ref. Number is missing. Assignment Number: '||l_person_details.unit);
		l_errflag := 'Y';
	END IF;

If l_errflag = 'Y' THEN
	Fnd_file.put_line(FND_FILE.LOG,'P45P3 Process Failed. Some mandatory parametors are missing. Please check the whole log for details.');
	raise l_p45_exception;
END IF;

/*
OPEN csr_archive_processed(p_assactid);
fetch csr_archive_processed into l_archive_processed;
UPDATE pay_element_entry_values_f set screen_entry_value='Y'
 WHERE CURRENT OF csr_archive_processed;
 close csr_archive_processed;
*/    --
  hr_utility.set_location('Leaving archive ',20);
  --update pay_element_entries_f set screen_entry_value='Y' where
Exception
WHEN l_p45_exception THEN
    Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1223);
    error_message := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','P46 part3 XML Process errors out');
END archive_data;
 -----------------------------------------------------------------------
--C2B
-----------------------------------------------------------------------
FUNCTION c2b( c IN CLOB ) RETURN BLOB
-- typecasts CLOB to BLOB (binary conversion)
IS
pos PLS_INTEGER := 1;
buffer RAW( 32767 );
res BLOB;
lob_len PLS_INTEGER := DBMS_LOB.getLength( c );
BEGIN
Hr_Utility.set_location('Entering: pay_ie_p45p3_p46_pkg.c2b',260);
DBMS_LOB.createTemporary( res, TRUE );
DBMS_LOB.OPEN( res, DBMS_LOB.LOB_ReadWrite );


LOOP
buffer := UTL_RAW.cast_to_raw( DBMS_LOB.SUBSTR( c, 16000, pos ) );

IF UTL_RAW.LENGTH( buffer ) > 0 THEN
DBMS_LOB.writeAppend( res, UTL_RAW.LENGTH( buffer ), buffer );
END IF;

pos := pos + 16000;
EXIT WHEN pos > lob_len;
END LOOP;

Hr_Utility.set_location('Leaving: pay_ie_p45p3_p46_pkg.c2b',265);
RETURN res; -- res is OPEN here
END c2b;
-----------------------------------------------------------------------
-- GEN_BODY_XML
-----------------------------------------------------------------------

PROCEDURE gen_body_xml
  IS
 l_string  varchar2(32767) := NULL;
 l_clob PAY_FILE_DETAILS.FILE_FRAGMENT%TYPE;
 l_blob PAY_FILE_DETAILS.BLOB_FILE_FRAGMENT%TYPE;

CURSOR c_action_information(c_action_type VARCHAR2, c_asg_act_id NUMBER) IS
    SELECT
	action_information6 form_type,
	action_information7 ppsn,
	action_information8 surname,
	action_information9 firstname,
	action_information10 addr1,
	action_information11 addr2,
	action_information12 addr3,
	action_information13 addr4,
	action_information14 emp_start_dt,
	action_information15 unit,
    action_information16 frequency,
	action_information17 prv_emp_strt_dt,
	action_information18 prv_emp_end_dt,
	trim(to_char(fnd_number.canonical_to_number(nvl(action_information19,0)) ,'99999990.99')) paya,
	trim(to_char(fnd_number.canonical_to_number(nvl(action_information20,0)) ,'99999990.99')) taxa,
	trim(to_char(fnd_number.canonical_to_number(action_information21) ,'99999990.99')) payb,
	trim(to_char(fnd_number.canonical_to_number(action_information22) ,'99999990.99')) taxb,
	action_information23 refunded,
	action_information24 paye_regst
	FROM pay_action_information
    WHERE
	action_information_category = c_action_type
    AND Action_context_id 	    = c_asg_act_id;

l_emp_information c_action_information%ROWTYPE;
l_payroll_action_id NUMBER;
l_asg_action_id NUMBER;

l_sur_name varchar2(1000);
l_first_name varchar2(1000);

--7529405
l_addressline1 varchar2(100);
l_addressline2 varchar2(100);
l_addressline3 varchar2(100);
l_addressline4 varchar2(100);
--7529405

BEGIN
hr_utility.set_location(' Entering: pay_ie_p45part3_p46_pkg_test.gen_body_xml: ', 270);

l_payroll_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
l_asg_action_id  := pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID');

hr_utility.set_location('l_payroll_action_id '||TO_CHAR(l_payroll_action_id),275);
hr_utility.set_location('l_asg_action_id '||TO_CHAR(l_asg_action_id),280);

FOR l_emp_information IN c_action_information('IE_P45P3_P46_DETAILS',l_asg_action_id)
	LOOP
	hr_utility.set_location('Inside IE P45P3 P46',285);
     IF(	g_file_type='P45P3') THEN
	    l_emp_information.addr1:=NULL;
	    l_emp_information.addr2:=NULL;
	    l_emp_information.addr3:=NULL;
	    l_emp_information.addr4:=NULL;
     END IF;

	l_sur_name		:= test_XML(substr(l_emp_information.surname,1,20));
	l_first_name	:= test_XML(substr(l_emp_information.firstname,1,20));
--7529405
	l_addressline1 := test_XML(substr(l_emp_information.addr1,1,35));
	l_addressline2 := test_XML(substr(l_emp_information.addr2,1,35));
	l_addressline3 := test_XML(substr(l_emp_information.addr3,1,35));
	l_addressline4 := test_XML(substr(l_emp_information.addr4,1,35));
--7529405
   	l_string := l_string ||'<P45P3 formtype="'||l_emp_information.form_type||'">'||EOL;
	--
	l_string := l_string || '<Employee';
	l_string := l_string || ' ppsn="'||l_emp_information.ppsn||'"';
	l_string := l_string || ' surname="'||l_sur_name||'"';
	l_string := l_string || ' firstname="'||l_first_name||'"';
--7529405
      l_string := l_string || ' addressline1="'||l_addressline1||'"';
	l_string := l_string || ' addressline2="'||l_addressline2||'"';
	l_string := l_string || ' addressline3="'||l_addressline3||'"';
	l_string := l_string || ' addressline4="'||l_addressline4||'"/>'||EOL ;
--7529405
	--l_string := l_string || '</Employee>'||EOL ;
	--
	l_string := l_string || '<NewEmployment';
	l_string := l_string || ' datecommencement="'||to_char(fnd_date.canonical_to_date(l_emp_information.emp_start_dt),'DD/MM/YYYY')||'"';
	l_string := l_string || ' unit="'||substr(l_emp_information.unit,1,12)||'"';
	l_string := l_string || ' freq="'||l_emp_information.frequency||'"/>'||EOL ;
	--l_string := l_string || '</NewEmployment>'||EOL ;
	--
	IF l_emp_information.form_type = 'P45P3' THEN
	l_string := l_string || '<PrevEmployment';
	l_string := l_string || ' datecommencement="'||to_char(fnd_date.canonical_to_date(l_emp_information.prv_emp_strt_dt),'DD/MM/YYYY')||'"';
	l_string := l_string || ' datecessation="'||to_char(fnd_date.canonical_to_date(l_emp_information.prv_emp_end_dt),'DD/MM/YYYY')||'"';
	l_string := l_string || ' paya="'||l_emp_information.paya||'"';
	l_string := l_string || ' taxa="'||l_emp_information.taxa||'"';
	l_string := l_string || ' payb="'||l_emp_information.payb||'"';
	l_string := l_string || ' taxb="'||l_emp_information.taxb||'"';
	l_string := l_string || ' refunded="'||l_emp_information.refunded||'"';
	l_string := l_string || ' payeregistered="'||l_emp_information.paye_regst||'"/>'||EOL ;
	END IF;
--	l_string := l_string || '</PrevEmployment>'||EOL ;
	--
--	l_string := l_string || <formtype>||l_emp_information.action_information6||'</formtype>';
	--
	l_string := l_string ||'</P45P3>'||EOL ;
	--
END LOOP;

hr_utility.set_location('Before leaving gen_body_xml: length(l_string) = '||length(l_string),290);
l_clob := l_clob||l_string;

IF l_clob IS NOT NULL THEN
	l_blob := c2b(l_clob);
	pay_core_files.write_to_magtape_lob(l_blob);
END IF;

EXCEPTION
WHEN Others THEN
	Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1213);
END gen_body_xml;
-----------------------------------------------------------------------
-- GEN_HEADER_XML
-----------------------------------------------------------------------
PROCEDURE gen_header_xml
IS
	l_string  varchar2(32767) := NULL;
	l_clob PAY_FILE_DETAILS.FILE_FRAGMENT%TYPE;
	l_blob PAY_FILE_DETAILS.BLOB_FILE_FRAGMENT%TYPE;

	l_proc VARCHAR2(100);
	l_buf  VARCHAR2(2000);

	CURSOR c_get_header(c_pact_id NUMBER) IS
	SELECT
	action_information6 regt_no,
	action_information7 emplyr_name,
	action_information8 trade_name,
	action_information9 addr1,
	action_information10 addr2,
	action_information11 addr3,
	action_information12 contact_name,
	action_information13 phone,
	action_information14 fax
	FROM    pay_action_information
	WHERE   action_context_id = c_pact_id
	AND     action_context_type = 'PA'
	AND     action_information_category ='IE P45P3 P46 EMPLOYER';

	l_header c_get_header%rowtype;
	l_payroll_action_id number;

l_currency		VARCHAR2(1) := 'E';
l_product		VARCHAR2(25):= 'ORACLE';
l_formversion	VARCHAR2(1) := '1';
l_language		VARCHAR2(1) := 'E';

--7529405
l_er_name		VARCHAR2(100);
l_er_tradename	VARCHAR2(100);
l_er_address1	VARCHAR2(100);
l_er_address2	VARCHAR2(100);
l_er_address3	VARCHAR2(100);
l_er_contact	VARCHAR2(100);
--7529405

BEGIN
	l_proc := g_package || 'gen_header_xml';
	hr_utility.set_location ('Entering '||l_proc,1500);

	l_payroll_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
	hr_utility.set_location('Inside pay_ie_p45p3_p46_pkg.gen_header_xml,l_payroll_action_id: '||l_payroll_action_id,300);

	OPEN c_get_header(l_payroll_action_id);
	FETCH c_get_header into l_header;
	CLOSE c_get_header;

--7529405
	l_er_name		:= test_XML(substr(l_header.emplyr_name,1,30));
	l_er_tradename	:= test_XML(substr(l_header.trade_name,1,30));
	l_er_address1	:= test_XML(substr(l_header.addr1,1,30));
	l_er_address2	:= test_XML(substr(l_header.addr2,1,30));
	l_er_address3	:= test_XML(substr(l_header.addr3,1,30));
	l_er_contact	:= test_XML(substr(l_header.contact_name,1,20));
--7529405

	l_string := l_string || '<P45P3File' ;
	l_string := l_string || ' currency="'|| l_currency ||'"';
	l_string := l_string || ' product="'|| l_product ||'"'  ;
	l_string := l_string || ' formversion="'|| l_formversion||'"';
	l_string := l_string || ' language="'|| l_language ||'">'||EOL ;

	l_string := l_string || '<Employer'||EOL ;

	l_string := l_string || ' number="'||substr(l_header.regt_no,1,8)||'"';
--7529405
	l_string := l_string || ' name="'||l_er_name||'"';
	l_string := l_string || ' tradename="'||l_er_tradename||'"';
	l_string := l_string || ' address1="'||l_er_address1||'"';
	l_string := l_string || ' address2="'||l_er_address2||'"';
	l_string := l_string || ' address3="'||l_er_address3||'"';
	l_string := l_string || ' contact="'||l_er_contact||'"';
--7529405
	l_string := l_string || ' phone="'||substr(l_header.phone,1,12)||'"';
	l_string := l_string || ' fax="'||substr(l_header.fax,1,12)||'"/>'||EOL ;

--	l_string := l_string || '</Employer>'||EOL ;

	l_clob := l_clob||l_string;
	IF l_clob IS NOT NULL THEN
	  l_blob := c2b(l_clob);
	  pay_core_files.write_to_magtape_lob(l_blob);
	END IF;

EXCEPTION
WHEN Others THEN
Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1214);

END gen_header_xml;
-----------------------------------------------------------------------
-- GEN_FOOTER_XML
-----------------------------------------------------------------------
PROCEDURE gen_footer_xml
IS
	l_buf  VARCHAR2(2000);
	l_proc VARCHAR2(100);
begin
	l_proc := g_package || 'gen_footer_xml';
	hr_utility.set_location ('Entering '||l_proc, 1520);
	--
	--l_buf := l_buf || '<FOOTER>'||EOL ;
	--l_buf := l_buf || '</FOOTER>'||EOL ;
	l_buf := l_buf || '</P45P3File>'||EOL ;
	--
	pay_core_files.write_to_magtape_lob(l_buf);
	hr_utility.set_location ('Leaving '||l_proc, 1530);

end gen_footer_xml;

END PAY_IE_P45PART3_P46_PKG;

/
