--------------------------------------------------------
--  DDL for Package Body PAY_IE_EHECS_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_EHECS_REPORT_PKG" AS
/* $Header: pyieehecs.pkb 120.5.12010000.5 2009/10/06 13:00:57 rsahai ship $ */

g_package	VARCHAR2(50)  := 'PAY_IE_EHECS_REPORT_PKG.';
EOL		VARCHAR2(5)   := fnd_global.local_chr(10);
l_errflag VARCHAR2(1) := 'N';
error_message boolean;
l_str_Common VARCHAR2(2000);
l_employee_categories VARCHAR(200);
l_ehecs_exception exception;

-----------------------------------------------------------------------
-- setup_balance_table
-----------------------------------------------------------------------

PROCEDURE setup_balance_table
IS

CURSOR csr_balance_dimension(p_balance   IN CHAR,
                             p_dimension IN CHAR) IS
SELECT pdb.defined_balance_id
FROM   pay_balance_types pbt,
       pay_balance_dimensions pbd,
       pay_defined_balances pdb
WHERE  pdb.balance_type_id = pbt.balance_type_id
AND    pdb.balance_dimension_id = pbd.balance_dimension_id
AND    pbt.balance_name = p_balance
AND    pbd.database_item_suffix = p_dimension
AND    pbd.legislation_code = 'IE'
AND    pbd.business_group_id is NULL
AND    pbt.legislation_code = 'IE'
AND    pbt.business_group_id is NULL
AND    pdb.legislation_code = 'IE'
AND    pdb.business_group_id is NULL;

l_archive_index		NUMBER       := 0;
l_dimension			VARCHAR2(16) := '_ASG_QTD';
l_max_stat_balance	NUMBER       := 24;
l_index_id			NUMBER       := 0;

l_proc                          VARCHAR2(120) := g_package || 'setup_balance_table';
BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);
  hr_utility.set_location('Step ' || l_proc,20);

  g_balance_name(1).balance_name   := 'Regular Earnings';
  g_balance_name(2).balance_name   := 'Irregular Earnings';
  g_balance_name(3).balance_name   := 'Overtime Payments';
  g_balance_name(4).balance_name   := 'Paid Overtime Hours';
  g_balance_name(5).balance_name   := 'Paid Maternity Hours';
  g_balance_name(6).balance_name   := 'Paid Sick Leave Hours';
  g_balance_name(7).balance_name   := 'Paid Other Leave Hours';
  g_balance_name(8).balance_name   := 'Income Continuance Insurance';
  g_balance_name(9).balance_name   := 'Redundancy Payments';
  g_balance_name(10).balance_name  := 'Employee Related Payments';
  g_balance_name(11).balance_name  := 'Training Subsidies';
  g_balance_name(12).balance_name  := 'Refunds';
  g_balance_name(13).balance_name  := 'Voluntary Sickness Insurance';
  g_balance_name(14).balance_name  := 'Staff Housing';
  g_balance_name(15).balance_name  := 'Other Benefits';
  g_balance_name(16).balance_name  := 'Other Subsidies';
  g_balance_name(17).balance_name  := 'Hourly Rate';
  g_balance_name(18).balance_name  := 'Stock Options and Share Purchase';
  g_balance_name(19).balance_name  := 'IE RBS ER Contribution';
  g_balance_name(20).balance_name  := 'IE PRSA ER Contribution';
  g_balance_name(21).balance_name  := 'IE RAC ER Contribution';
  g_balance_name(22).balance_name  := 'IE PRSI Employer';
  g_balance_name(23).balance_name  := 'IE BIK Company Vehicle';
  g_balance_name(24).balance_name  := 'Normal Working Hours';
/*6856473 */
  g_balance_name(25).balance_name  := 'Paid Maternity Days';
  g_balance_name(26).balance_name  := 'Paid Other Leave Days';
  g_balance_name(27).balance_name  := 'Paid Sick Leave Days';

  /* 6856473 */

  g_balance_name(28).balance_name  := 'Annual Leave and Bank Holiday Hours';
  g_balance_name(29).balance_name  := 'Annual Leave and Bank Holiday Days';

  hr_utility.set_location('Step = ' || l_proc,30);

  FOR l_index IN 1 .. g_balance_name.COUNT
  LOOP

    l_dimension := '_ASG_QTD';
    hr_utility.set_location('l_index      = ' || l_index,30);
    hr_utility.set_location('balance_name = ' || g_balance_name(l_index).balance_name,30);
    hr_utility.set_location('l_dimension  = ' || l_dimension,30);

    l_index_id := l_index_id +1;
    OPEN csr_balance_dimension(g_balance_name(l_index).balance_name,
                               l_dimension);
    FETCH csr_balance_dimension
    INTO	g_def_bal_id(l_index_id).defined_balance_id;
    g_def_bal_id(l_index_id).balance_name := g_balance_name(l_index).balance_name;

    IF csr_balance_dimension%NOTFOUND
    THEN
      g_def_bal_id(l_index_id).defined_balance_id := 0;
    END IF;

    CLOSE csr_balance_dimension;

    hr_utility.set_location('Balance Name = ' || g_def_bal_id(l_index_id).balance_name,30);
    hr_utility.set_location('defined_balance_id = ' || g_def_bal_id(l_index_id).defined_balance_id,30);

  END LOOP;

  hr_utility.set_location('Step ' || l_proc,50);

  hr_utility.set_location('Leaving ' || l_proc,60);

END setup_balance_table;

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
 l_token_name                   VARCHAR2(300); /* 7367314QA */

/*6856473 */

CURSOR csr_comments (
   p_pact_id NUMBER,
   p_token   CHAR
)  IS
SELECT TRIM(SUBSTR
        (
           legislative_parameters,
           DECODE(
           INSTR(
              legislative_parameters,
              p_token
           )--INSTR
           ,0,LENGTH(legislative_parameters),
           INSTR
           (
              legislative_parameters,
              p_token
           )--INSTR 2 DEFAULT FOR DECODE
           )--CLOSE DECODE
            + (LENGTH(p_token) ),--END OF SECOND PARAMETER FOR SUBSTR
            --LENGTH(legislative_parameters)
		--8624704
            DECODE(INSTR(legislative_parameters,'XML_REPORT_TAG'),0, LENGTH(legislative_parameters),
            INSTR(legislative_parameters,'XML_REPORT_TAG') - (INSTR(legislative_parameters,p_token) + LENGTH(p_token)) )
            --8624704
	  )
	 )

	FROM pay_payroll_actions
	WHERE payroll_action_id = p_pact_id;


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
/*6856473 */

   ELSIF p_token_name= 'COMMENTS' THEN
      hr_utility.set_location('comments before replace ' || TO_CHAR(l_token_value), 120);
      l_token_name:=p_token_name||'=';
     OPEN  csr_comments
         (
            p_payroll_action_id,
            l_token_name  /* 7367314QA */
         );
   FETCH csr_comments INTO l_token_value;
   CLOSE csr_comments;
      hr_utility.set_location('comments after replace ' || TO_CHAR(l_token_value), 120);
    p_token_value := l_token_value;
   ELSE
      p_token_value := l_token_value;
	--7367314
      IF p_token_name= 'ADD_CHANGE' THEN
	   IF p_token_value = 'Y' THEN
	      p_token_value := '1' ;
	   ELSE
		p_token_value := '0' ;
	   END IF;
	END IF;
	--7367314
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
					,p_year OUT NOCOPY VARCHAR2
					,p_quarter OUT NOCOPY VARCHAR2
					,p_business_Group_id OUT NOCOPY VARCHAR2
					,p_assignment_set_id OUT NOCOPY VARCHAR2
					,p_occupational_category OUT NOCOPY VARCHAR2
					,p_employer_id OUT NOCOPY VARCHAR2
					,p_report_type OUT NOCOPY VARCHAR2
					,p_declare_date OUT NOCOPY VARCHAR2
					,p_change_add OUT NOCOPY VARCHAR2
					,p_comments OUT NOCOPY VARCHAR2
					)
IS

CURSOR cur_nat_min_wg
IS
SELECT fnd_number.canonical_to_number(global_value)
FROM ff_globals_f
WHERE GLOBAL_NAME = 'IE_NAT_MIN_WAGE_RATE'
AND legislation_code = 'IE'
AND g_archive_effective_date BETWEEN effective_start_date AND effective_end_date;

CURSOR cur_inc_exc_flag
IS
SELECT DISTINCT hasa.include_or_exclude inc_or_exc
FROM
	hr_assignment_set_amendments hasa,
	hr_assignment_sets has
WHERE hasa.assignment_set_id = has.assignment_set_id
AND	has.business_group_id  = p_business_Group_id
AND	has.assignment_set_id  = p_assignment_set_id;

l_occupational_catg VARCHAR2(50);
l_cur_inc_exc_flag_rec cur_inc_exc_flag%rowtype;

 BEGIN
    hr_utility.set_location(' Entering PAY_IE_EHECS_REPORT.get_all_parameters ', 200);

    get_parameters(p_payroll_action_id,'REP_GROUP',p_rep_group);
    get_parameters(p_payroll_action_id,'PAYROLL',p_payroll_id);
    get_parameters(p_payroll_action_id,'YEAR',p_year);
    get_parameters(p_payroll_action_id,'QUARTER',p_quarter);
    get_parameters(p_payroll_action_id,'BG_ID',p_business_Group_id);
    get_parameters(p_payroll_action_id,'ASSIGNMENT_SET_ID',p_assignment_set_id);
    get_parameters(p_payroll_action_id,'OCCUPATION',p_occupational_category);
    get_parameters(p_payroll_action_id,'EMPLOYER',p_employer_id);
    get_parameters(p_payroll_action_id,'REPTYPE',p_report_type);
    get_parameters(p_payroll_action_id,'DDATE',p_declare_date);
    get_parameters(p_payroll_action_id,'ADD_CHANGE',p_change_add);
    get_parameters(p_payroll_action_id,'COMMENTS',p_comments);

hr_utility.set_location(' After last get_parameters call ', 210);

IF p_quarter = '1' THEN
	g_qtr_start_date := to_date('01/01/' || p_year,'DD/MM/RRRR');
	g_qtr_end_date := to_date('31/03/' || p_year,'DD/MM/RRRR');
ELSIF p_quarter = '2' THEN
	g_qtr_start_date := to_date('01/04/' || p_year,'DD/MM/RRRR');
	g_qtr_end_date := to_date('30/06/' || p_year,'DD/MM/RRRR');
ELSIF p_quarter = '3' THEN
	g_qtr_start_date := to_date('01/07/' || p_year,'DD/MM/RRRR');
	g_qtr_end_date := to_date('30/09/' || p_year,'DD/MM/RRRR');
ELSIF p_quarter = '4' THEN
	g_qtr_start_date := to_date('01/10/' || p_year,'DD/MM/RRRR');
	g_qtr_end_date := to_date('31/12/' || p_year,'DD/MM/RRRR');
END IF;

hr_utility.set_location(' After populating the Quarter dates. ', 220);

OPEN cur_nat_min_wg;
FETCH cur_nat_min_wg INTO g_ie_nat_min_wage_rate;
CLOSE cur_nat_min_wg;

hr_utility.set_location(' After cur_nat_min_wg Cursor ', 230);
hr_utility.set_location(' g_ie_nat_min_wage_rate '||g_ie_nat_min_wage_rate, 230);

OPEN cur_inc_exc_flag;
FETCH cur_inc_exc_flag INTO l_cur_inc_exc_flag_rec;
CLOSE cur_inc_exc_flag;

g_exc_inc := l_cur_inc_exc_flag_rec.inc_or_exc;

hr_utility.set_location(' After cur_inc_exc_flag Cursor ', 235);
hr_utility.set_location(' l_cur_inc_exc_flag_rec.inc_or_exc '||l_cur_inc_exc_flag_rec.inc_or_exc, 235);
hr_utility.set_location(' p_business_Group_id = '||p_business_Group_id,240);
hr_utility.set_location(' REP_GROUP = '||p_rep_group,240);
hr_utility.set_location(' PAYROLL = '||p_payroll_id,240);
hr_utility.set_location(' YEAR = '||p_year,240);
hr_utility.set_location(' QUARTER = '||p_quarter,240);
hr_utility.set_location(' ASSIGNMENT_SET_ID = '||p_assignment_set_id,240);
hr_utility.set_location(' OCCUPATION CATEGORY = '||p_occupational_category,240);
hr_utility.set_location(' EMPLOYER = '||p_employer_id,240);
hr_utility.set_location(' REPORT TYPE = '||p_report_type,240);
hr_utility.set_location(' DDATE = '||p_declare_date,240);
hr_utility.set_location(' ADD_CHANGE = '||p_change_add,240);
hr_utility.set_location(' COMMENTS = '||p_comments,240);
hr_utility.set_location(' g_qtr_start_date = '||g_qtr_start_date,240);
hr_utility.set_location(' g_qtr_end_date = '||g_qtr_end_date,240);

IF p_occupational_category IS NOT NULL THEN
	--g_occupational_category_M_C_P :=
	/*NVL(hruserdt.get_table_value(p_business_Group_id,'EHECS_CATG_TAB','MPAP',substr(p_occupational_category,-2,length(p_occupational_category)),g_qtr_start_date),
	NVL(hruserdt.get_table_value(p_business_Group_id,'EHECS_CATG_TAB','CSSW',substr(p_occupational_category,-2,length(p_occupational_category)),g_qtr_start_date),
	hruserdt.get_table_value(p_business_Group_id,'EHECS_CATG_TAB','PTCO',substr(p_occupational_category,-2,length(p_occupational_category)),g_qtr_start_date)));*/

	/*
	NVL(hruserdt.get_table_value(p_business_Group_id,'EHECS_CATG_TAB','Managers',p_occupational_category,g_qtr_start_date),
	NVL(hruserdt.get_table_value(p_business_Group_id,'EHECS_CATG_TAB','Clerical Workers',p_occupational_category,g_qtr_start_date),
	hruserdt.get_table_value(p_business_Group_id,'EHECS_CATG_TAB','Production Workers',p_occupational_category,g_qtr_start_date)));
        */

        SELECT  NVL(hruserdt.get_table_value(p_business_Group_id,'EHECS_CATG_TAB','Managers',p_occupational_category,g_qtr_start_date),
	NVL(hruserdt.get_table_value(p_business_Group_id,'EHECS_CATG_TAB','Clerical Workers',p_occupational_category,g_qtr_start_date),
	hruserdt.get_table_value(p_business_Group_id,'EHECS_CATG_TAB','Production Workers',p_occupational_category,g_qtr_start_date))) ff
	into g_occupational_category_M_C_P
        FROM dual;


END IF;

hr_utility.set_location(' g_occupational_category_M_C_P = '||g_occupational_category_M_C_P,245);

IF p_payroll_id IS NOT NULL THEN
 g_where_clause :=
 ' and papf.payroll_id = '||to_char(p_payroll_id);
ELSE
    g_where_clause :='  and 1=1 ';
END IF;

IF p_occupational_category IS NOT NULL THEN
 g_where_clause1 :=
 ' and paaf.employee_category = '||to_char(g_occupational_category);

ELSE
 g_where_clause1 :='  and 1=1 ';
END IF;

IF p_assignment_set_id IS NOT NULL THEN
 IF l_cur_inc_exc_flag_rec.inc_or_exc = 'I' THEN
  g_where_clause_asg_set := ' AND EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
					  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = paaf.business_group_id
					  AND   has.assignment_set_id = '|| p_assignment_set_id
					  ||' AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = ppf.person_id) ';
 ELSIF l_cur_inc_exc_flag_rec.inc_or_exc = 'E' THEN
  g_where_clause_asg_set  := ' AND NOT EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
					  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = paaf.business_group_id
					  AND   has.assignment_set_id = '|| p_assignment_set_id
					  ||' AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = ppf.person_id) ';
 ELSIF l_cur_inc_exc_flag_rec.inc_or_exc IS NULL THEN
  g_where_clause_asg_set := ' and 1=2 ';
 END IF;
ELSE
  g_where_clause_asg_set := ' and 1=1 ';
END IF;


 hr_utility.set_location(' Inside get_all_parameters:g_where_clause: '||g_where_clause,250);
 hr_utility.set_location(' Inside get_all_parameters:g_where_clause1: '||g_where_clause1,260);
 hr_utility.set_location(' Inside get_all_parameters:g_where_clause1: '||g_where_clause_asg_set,265);

 hr_utility.set_location(' Leaving: PAY_IE_EHECS_REPORT.get_all_parameters: ', 270);

EXCEPTION
  WHEN Others THEN
    hr_utility.set_location(' Leaving: PAY_IE_EHECS_REPORT.get_all_parameters with errors: ', 280);
    Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1215);
END get_all_parameters;

-----------------------------------------------------------------------
-- RANGE_CODE
-----------------------------------------------------------------------
 PROCEDURE range_code(pactid IN NUMBER,
		 sqlstr OUT nocopy VARCHAR2)
 IS
 l_procedure_name   VARCHAR2(100);

 l_year varchar2(50);
 l_quarter varchar2(50);
 l_assignment_set_id varchar2(50);
 l_occupational_category varchar2(50);
 l_report_type varchar2(50);
l_declare_date varchar2(50):=' ';
l_change_indicator varchar2(50):=' ';
l_comments varchar2(300);

 CURSOR  csr_archive_effective_date(pactid NUMBER) IS
     SELECT effective_date
     FROM   pay_payroll_actions
     WHERE  payroll_action_id = pactid;

 CURSOR csr_employer_details(c_org_id  hr_organization_information.organization_id%type
                            ,c_bg_id hr_organization_units.business_group_id%type) IS
     select hou.organization_id org_id
            ,hou.name employer_name
            ,hla.address_line_1 addr1
            ,hla.address_line_2 addr2
            ,hla.address_line_3 addr3
             from hr_organization_units hou
                 ,hr_organization_information hoi
                 ,hr_locations_all hla
              where hoi.org_information_context='IE_EMPLOYER_INFO'
              and hoi.organization_id=c_org_id
              and hoi.organization_id=hou.organization_id
              and hou.business_group_id= c_bg_id
              and hou.location_id=hla.location_id(+);


 CURSOR csr_declarant(c_org_id  hr_organization_information.organization_id%type
                            ,c_bg_id hr_organization_units.business_group_id%type
				    ,p_year varchar2
				    ,p_qtr varchar2) IS
 select hoi.org_information3 cbr_no
       ,hoi.org_information13 person_id
       ,hoi.org_information17 position  -- bug 6850742
       ,hoi.org_information19 email     -- bug 6850742
       ,hoi.org_information20 phone     -- bug 6850742
     from hr_organization_units hou
    ,hr_organization_information hoi
  where hoi.org_information_context='IE_EHECS'
  and hoi.organization_id=c_org_id
  and hoi.organization_id=hou.organization_id
  and hou.business_group_id= c_bg_id
  and hoi.ORG_INFORMATION1 = p_year
  and hoi.ORG_INFORMATION2 = p_qtr;
/*
CURSOR csr_declarant_details(c_person_id per_all_people_f.person_id%type) is
select papf.full_name declarant_name
       ,pav.telephone_number_1 declarant_phone
       ,papf.email_address declarant_email
       ,pap.NAME declarant_position
from per_all_people_f papf
     ,per_all_assignments_f paaf
     ,per_all_positions pap
     ,per_addresses_v pav
where    papf.person_id=c_person_id  ;
      and paaf.person_id=papf.person_id
      and pav.person_id=papf.person_id
     and pap.position_id=paaf.position_id
	and g_archive_effective_date between paaf.effective_start_date and paaf.effective_end_date
	and g_archive_effective_date between papf.effective_start_date and papf.effective_end_date;
*/
/* bug 6850742  */
CURSOR csr_declarant_details(c_person_id per_all_people_f.person_id%type) is
select papf.full_name declarant_name
from per_all_people_f papf
where    papf.person_id=c_person_id  ;


 l_employer_details csr_employer_details%rowtype;
 l_declarant csr_declarant%rowtype;
 l_declarant_details csr_declarant_details%rowtype;
 l_action_info_id NUMBER;
 l_ovn NUMBER;
 l_org_id         hr_organization_units.organization_id%type;
 l_employer_name  hr_organization_units.name%type;

 l_addr1        hr_locations_all.address_line_1%type;
 l_addr2        hr_locations_all.address_line_2%type;
 l_addr3        hr_locations_all.address_line_3%type;
 l_addr4        hr_locations_all.address_line_3%type;
 l_addr5        hr_locations_all.address_line_3%type;
 l_cbr_no       hr_organization_information.org_information3%type;
 l_person_id    hr_organization_information.org_information13%type;
 l_declarant_name per_all_people_f.full_name%type;
 l_declarant_phone        per_all_people_f.office_number%type ;
 l_declarant_email_add    per_all_people_f.email_address%type;
 l_declarant_position     per_all_positions.name%type;


 BEGIN

 l_procedure_name := g_package||'range_code';

 hr_utility.set_location('Entering '||l_procedure_name, 300);
 hr_utility.set_location('pactid '||TO_CHAR(pactid), 300);

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

 hr_utility.set_location('After fetching the g_archive_effective_date '||g_archive_effective_date, 310);

   get_all_parameters(pactid
			,g_rep_group
			,g_payroll_id
			,l_year
			,l_quarter
			,g_business_group_id
			,l_assignment_set_id
			,l_occupational_category
			,g_employer_id
			,l_report_type
			,l_declare_date
			,l_change_indicator
			,l_comments);

g_year := l_year;
g_quarter := l_quarter;
g_occupational_category := l_occupational_category;
g_assignment_set_id := l_assignment_set_id;

 hr_utility.set_location('After fetching the g_archive_effective_date '||g_archive_effective_date, 310);

  setup_balance_table;

 hr_utility.set_location('After the call of setup_balance_table in '||l_procedure_name, 320);

  OPEN csr_employer_details(g_employer_id, g_business_group_id);
  FETCH csr_employer_details INTO l_employer_details;
  CLOSE csr_employer_details;

 hr_utility.set_location('After fetching the csr_employer_details ', 330);

  l_org_id :=		l_employer_details.org_id;
  l_employer_name :=	l_employer_details.employer_name;
  l_addr1 :=		l_employer_details.addr1;
  l_addr2 :=		l_employer_details.addr2;
  l_addr3 :=		l_employer_details.addr3;
  l_addr4 := ' ';
  l_addr5 := ' ';

hr_utility.set_location('After fetching the csr_employer_details l_org_id'||l_org_id, 330);
hr_utility.set_location('After fetching the csr_employer_details l_employer_name'||l_employer_name, 330);
hr_utility.set_location('After fetching the csr_employer_details l_addr1'||l_addr1, 330);
hr_utility.set_location('After fetching the csr_employer_details l_addr2'||l_addr2, 330);
hr_utility.set_location('After fetching the csr_employer_details l_addr3'||l_addr3, 330);

  OPEN csr_declarant(g_employer_id, g_business_group_id, l_year, l_quarter);
  FETCH csr_declarant INTO l_declarant;
  CLOSE csr_declarant;
  l_cbr_no := l_declarant.cbr_no;
  l_person_id :=	l_declarant.person_id;
  l_declarant_position	:= l_declarant.position; -- bug 6850742
  l_declarant_phone	:= l_declarant.phone;    -- bug 6850742
  l_declarant_email_add := l_declarant.email;    -- bug 6850742

hr_utility.set_location('After fetching the csr_declarant ', 340);
hr_utility.set_location('After fetching the l_cbr_no '||l_cbr_no, 340);
hr_utility.set_location('After fetching the l_person_id '||l_person_id, 340);
hr_utility.set_location('l_declarant_position '||l_declarant_position, 340);
hr_utility.set_location('l_declarant_phone '||l_declarant_phone, 340);
hr_utility.set_location('l_declarant_email_add '||l_declarant_email_add, 340);

  OPEN csr_declarant_details(l_person_id);
  FETCH csr_declarant_details into l_declarant_details;
  CLOSE	csr_declarant_details;

 hr_utility.set_location('After fetching the csr_declarant_details ', 350);

  l_declarant_name	:= l_declarant_details.declarant_name;
  /* bug 6850742*/
--  l_declarant_phone	:= l_declarant_details.declarant_phone;
  --l_declarant_email_add := l_declarant_details.declarant_email;
--  l_declarant_position	:= l_declarant_details.declarant_position;

hr_utility.set_location('l_declarant_name '||l_declarant_name, 350);
--hr_utility.set_location('l_declarant_phone '||l_declarant_phone, 350);
--hr_utility.set_location('l_declarant_email_add '||l_declarant_email_add, 350);
--hr_utility.set_location('l_declarant_position '||l_declarant_position, 350);

IF l_employer_name IS NULL THEN
	l_errflag := 'Y';
     --Fnd_file.put_line(FND_FILE.LOG,'Employer name is missing. Please enter it first.' );
     Fnd_file.put_line(FND_FILE.LOG,'You have not entered the employer name. Enter a valid employer name.' );
END IF;
IF l_addr1 IS NULL OR l_addr2 IS NULL THEN
	l_errflag := 'Y';
     --Fnd_file.put_line(FND_FILE.LOG,'Employer Address line 1/2 is missing. Please enter it first.' );
	Fnd_file.put_line(FND_FILE.LOG,'You have not entered a complete address for the employer. Enter a valid address.' );
END IF;
IF l_cbr_no IS NULL THEN
	l_errflag := 'Y';
     --Fnd_file.put_line(FND_FILE.LOG,'CBR Number is missing. Please enter it first.' );
     Fnd_file.put_line(FND_FILE.LOG,'You have not entered the CBR Number. Enter a valid CBR Number.' );
END IF;
IF l_declarant_name IS NULL OR l_declarant_phone IS NULL OR
	l_declarant_email_add IS NULL OR l_declarant_position IS NULL THEN
	l_errflag := 'Y';
      --Fnd_file.put_line(FND_FILE.LOG,'Declarant details are missing. Please check for Name, Phone, Email, Position.' );
	Fnd_file.put_line(FND_FILE.LOG,'You have not entered the declaration contact details. Enter the Name, Phone, Email and Position of the declaration contact.' );
END IF;

hr_utility.set_location('l_errflag '||l_errflag, 370);

IF l_errflag = 'Y' THEN
  Fnd_file.put_line(FND_FILE.LOG,'Some mandatory data is misssing.' );
  Raise l_ehecs_exception;
END IF;

hr_utility.set_location('Before entering record for IE_EHECS_HEADER ', 380);

    pay_action_information_api.create_action_information
    ( p_action_information_id => l_action_info_id
    ,p_action_context_id => pactid
    ,p_action_context_type => 'PA'
    ,p_object_version_number => l_ovn
    ,p_effective_date => g_archive_effective_date --g_end_date
    ,p_source_id => NULL
    ,p_source_text => NULL
    ,p_action_information_category => 'IE_EHECS_HEADER'
    ,p_action_information6  => l_year
    ,p_action_information7  => l_quarter
    ,p_action_information8  => l_report_type
    ,p_action_information9  => 'Oracle HRMS'			--SOFTWARE NAME (HARD CODED)
    ,p_action_information10 => '1.0'				--SOFTWARE VERSION(HARD CODED)
    ,p_action_information11 => 'Oracle Corporation'		--VENDOR NAME
    ,p_action_information12 => '870-4000-900'			--'870.4000.900'		      --VENDOR PHONE	--7367314
    ,p_action_information13 => l_org_id
    ,p_action_information14 => l_employer_name
    ,p_action_information15 => l_addr1
    ,p_action_information16 => l_addr2
    ,p_action_information17 => l_addr3
    ,p_action_information18 => l_addr4
    ,p_action_information19 => l_addr5
    ,p_action_information20 => l_change_indicator --parameter
    ,p_action_information21 => l_cbr_no
    ,p_action_information22 => l_declarant_name
    ,p_action_information23 => l_declarant_phone
    ,p_action_information24 => l_declarant_email_add
    ,p_action_information25 => l_declare_date
    ,p_action_information26 => l_declarant_position
    );

hr_utility.set_location('After entering record for IE_EHECS_HEADER ', 390);

hr_utility.set_location('Leaving '||l_procedure_name, 400);

 EXCEPTION
 WHEN l_ehecs_exception THEN
    Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,410);
    error_message := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','EHECS Report errors out. Some mandatory values are missing.');
 WHEN Others THEN
    Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,410);
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

 l_ass_check  varchar2(1);
 l_csr_already_archived pay_element_entry_values_f.screen_entry_value%TYPE := 'N';
 BEGIN

 hr_utility.set_location('Entering PAY_IE_EHECS_REPORT_PKG.assignment_action_code',500);

-- Get all the parameters
/*6978389 */
hr_utility.set_location('Before get_all_parameters',501);
get_all_parameters(pactid
			,g_rep_group
			,g_payroll_id
			,g_year
			,g_quarter
			,g_business_group_id
			,g_assignment_set_id
			,g_occupational_category
			,g_employer_id
			,g_report_type
			,g_declare_date
			,g_change_indicator
			,g_comments);
hr_utility.set_location('after get_all_parameters',502);
hr_utility.set_location(' g_qtr_start_date = '||g_qtr_start_date,505);
hr_utility.set_location(' g_qtr_end_date = '||g_qtr_end_date,505);
hr_utility.set_location(' g_business_group_id = '||g_business_group_id,505);
hr_utility.set_location(' g_employer_id = '||g_employer_id,505);

 --g_start_date := fnd_date.canonical_to_date(l_start_date);
 --g_end_date := fnd_date.canonical_to_date(l_end_date);

-- g_pact_id := pactid;

 --hr_utility.set_location('after get_all_parameter called',225);
 --hr_utility.set_location('report start date= '||g_start_date,300);

hr_utility.set_location('Before building the dynamic query.',510);
/* 6856486   modified the employment_category 's IN condition to a value fetch from USER TABLE EHECS_ASG_CATG_TAB */
l_select_str :='select distinct paaf.assignment_id asgid
from                        per_all_assignments_f paaf,
                            per_all_people_f ppf,
                            pay_all_payrolls_f papf,
                            pay_payroll_actions ppa,
   				    hr_soft_coding_keyflex scl
where                       paaf.business_group_id = '|| g_business_group_id
                            ||' and papf.business_group_id = paaf.business_group_id '
				    ||' and paaf.effective_start_date <= '||''''||g_qtr_end_date||''''
				    ||' and paaf.effective_end_date >= '||''''||g_qtr_start_date||''''
				    ||' and paaf.person_id = ppf.person_id '
				    ||' and paaf.employment_category = '
			--	    ||' IN ('||'''FT'''||','||'''FR'''||','||'''PT'''||','||'''PR'''||','||'''AT'''||') '
                            ||'nvl(hruserdt.get_table_value(paaf.business_group_id,'||''''||'EHECS_ASG_CATG_TAB'||''''||','||''''||'Full_Time'||''''||',paaf.EMPLOYMENT_CATEGORY,'||''''||g_qtr_start_date||''''||')'
			    ||      ',nvl(hruserdt.get_table_value(paaf.business_group_id,'||''''||'EHECS_ASG_CATG_TAB'||''''||','||''''||'Part_Time'||''''||',paaf.EMPLOYMENT_CATEGORY,'||''''||g_qtr_start_date||''''||')'
			    ||	    ',  hruserdt.get_table_value(paaf.business_group_id,'||''''||'EHECS_ASG_CATG_TAB'||''''||','||''''||'Apprentice_Trainee'||''''||',paaf.EMPLOYMENT_CATEGORY,'||''''||g_qtr_start_date||''''||')'
			    ||	' ))'

			    ||' and ppf.person_id between '|| stperson || ' and ' || endperson
				    ||g_where_clause1
				    ||' and ppa.payroll_action_id = '||pactid
                            ||' and papf.payroll_id = paaf.payroll_id '
                            ||' and papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id '
				    ||' and scl.segment4 = to_char('||g_employer_id||') '
				    ||g_where_clause
				    ||g_where_clause_asg_set
          		          ||' Order by paaf.assignment_id';

hr_utility.set_location('After building the dynamic query.',520);

/*6978389 */
Fnd_file.put_line(FND_FILE.LOG,'Dynamic Query:'||l_select_str );

OPEN csr_get_asg FOR l_select_str; -- ref cursor
 LOOP
	hr_utility.set_location(' Inside ass action code, inside loop for ref cursor',530);
	FETCH csr_get_asg INTO l_assg_id;
	EXIT WHEN csr_get_asg%NOTFOUND;
		SELECT pay_assignment_actions_s.nextval
		INTO lockingactid
		FROM dual;

	hr_utility.set_location('assignment_action_code, the assignment id finally picked up: '||l_assg_id, 540);
		-- Insert assignment into PAY_ASSIGNMENT_ACTIONS TABLE
		/*	hr_nonrun_asact.insact(lockingactid => lockingactid
					,assignid     => l_assg_id
					,pactid       => pactid
					,chunk        => chunk
					,greid        => NULL);
		*/

		-- Insert assignment into PAY_TEMP_OBJECT_ACTION TABLE.
	hr_utility.set_location(' Before hr_nonrun_asact.insact call',550);
		hr_nonrun_asact.insact(lockingactid => lockingactid
				,assignid     =>    l_assg_id       --asgrec.assignment_id        --
				,object_id    =>    l_assg_id       --asgrec.assignment_id        --
				,pactid       => pactid
				,chunk        => chunk
				,greid        => NULL);
				--,p_transient_action => TRUE);
	hr_utility.set_location(' After hr_nonrun_asact.insact call',560);

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

  BEGIN

   hr_utility.set_location('Entering: PAY_IE_EHECS_REPORT_PKG.archive_init: ',600);

   OPEN csr_archive_effective_date(p_payroll_action_id);
   FETCH csr_archive_effective_date
   INTO  g_archive_effective_date;
   CLOSE csr_archive_effective_date;

   hr_utility.set_location('Before calling get_all_parameters ',610);

 get_all_parameters(p_payroll_action_id
			,g_rep_group
			,g_payroll_id
			,g_year
			,g_quarter
			,g_business_group_id
			,g_assignment_set_id
			,g_occupational_category
			,g_employer_id
			,g_report_type
			,g_declare_date
			,g_change_indicator
			,g_comments);

   hr_utility.set_location('After calling get_all_parameters ',620);

setup_balance_table;

   hr_utility.set_location('After calling setup_balance_table ',630);

    hr_utility.set_location(' Leaving PAY_IE_EHECS_REPORT_PKG.archive_init', 640);

EXCEPTION
WHEN Others THEN
hr_utility.set_location(' Leaving PAY_IE_EHECS_REPORT_PKG.archive_init with errors', 650);
Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1211);

END archive_init;
 -----------------------------------------------------------------------
-- ARCHIVE_DATA
-----------------------------------------------------------------------
 PROCEDURE archive_data(p_assactid in number,
                        p_effective_date in date)
 IS

 BEGIN

  hr_utility.set_location(' Entering PAY_IE_EHECS_REPORT_PKG.ARCHIVE_CODE: ',700);
  hr_utility.set_location('g_pact_id '||TO_CHAR(g_pact_id),700);
  hr_utility.set_location('p_assignment_action_id '||TO_CHAR(p_assactid),700);

NUll;

  hr_utility.set_location(' Leaving PAY_IE_EHECS_REPORT_PKG.ARCHIVE_CODE: ',700);

END archive_data;

PROCEDURE ehecs_main_proc(p_business_group_id IN VARCHAR2
				  ,p_payroll_action_id IN NUMBER
				  ,p_assignment_id IN NUMBER
				  ,p_person_id IN NUMBER)
IS

CURSOR cur_valid_asg(c_assignment_id NUMBER, c_person_id NUMBER)
IS
SELECT distinct paaf.assignment_id, paaf.person_id, paaf.payroll_id,
	--decode(paaf.EMPLOYMENT_CATEGORY,'FT','F','FR','F','PR','P','PT','P',paaf.EMPLOYMENT_CATEGORY) EMP_CATG,
   /* 6856486 */
        decode(paaf.EMPLOYMENT_CATEGORY
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Full_Time',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'F'
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Part_Time',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'P'
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Apprentice_Trainee',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'AT'
	) EMP_CATG,

	/*
	NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Managers',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),paaf.effective_start_date),
	NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','CSSW',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),paaf.effective_start_date),
	  hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Production Workers',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),paaf.effective_start_date)
	  )
	) EHECS_CATG*/
	NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Managers',paaf.EMPLOYEE_CATEGORY,g_qtr_start_date),
	NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Clerical Workers',paaf.EMPLOYEE_CATEGORY,g_qtr_start_date),
	  hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Production Workers',paaf.EMPLOYEE_CATEGORY,g_qtr_start_date)
	  )
	) EHECS_CATG
	, paaf.effective_start_date
	,normal_hours normal_hours                /*6856473*/
	,frequency frequency                      /*6856473*/
	,hourly_salaried_code hourly_or_salaried  /*6856473*/
FROM
per_all_assignments_f paaf
WHERE paaf.assignment_id = c_assignment_id
and paaf.person_id = c_person_id
and paaf.effective_start_date <= g_qtr_end_date
and paaf.effective_end_date >= g_qtr_start_date
and assignment_status_type_id in (SELECT assignment_status_type_id
                           FROM per_assignment_status_types
                          WHERE per_system_status = 'ACTIVE_ASSIGN'
                            AND active_flag       = 'Y')/*6856473 to filter the terminated assingment*/
ORDER BY paaf.effective_start_date desc;

l_valid_asg_rec cur_valid_asg%ROWTYPE;

CURSOR cur_valid_asg_act(p_asg_id NUMBER, p_payroll_id NUMBER)
IS
SELECT /*+ USE_NL(paa, ppa) */
	 max(paa.assignment_action_id) assignment_action_id
FROM   pay_assignment_actions paa,
	 pay_payroll_actions    ppa
WHERE  paa.assignment_id  = p_asg_id
AND    ppa.payroll_action_id = paa.payroll_action_id
AND    (paa.source_action_id is not null or ppa.action_type in ('I','V','B'))
AND    ppa.effective_date between g_qtr_start_date and g_qtr_end_date
--bug 7294966
/*					   (  select max(pay_advice_date)
						from per_time_periods
						where payroll_id = p_payroll_id
						and pay_advice_date <= g_qtr_end_date
					   )
*/
--bug 7294966
AND    ppa.action_type in ('R', 'Q', 'I', 'V','B')
AND    paa.action_status = 'C'
HAVING max(paa.assignment_action_id) IS NOT NULL;

l_valid_asg_act_rec cur_valid_asg_act%ROWTYPE;

/*6856473 added the cursor and the variables */
CURSOR csr_hours_per_day(c_org_id  hr_organization_information.organization_id%type
                            ,c_bg_id hr_organization_units.business_group_id%type
			 ) IS
 select hoi.org_information18 hrs_per_day
     from hr_organization_units hou
    ,hr_organization_information hoi
  where hoi.org_information_context='IE_EHECS'
  and hoi.organization_id=c_org_id
  and hoi.organization_id=hou.organization_id
  and hou.business_group_id= c_bg_id;
--l_hours_per_day csr_hours_per_day%rowtype;
l_hours_per_day varchar2(10);
l_org_id hr_organization_units.organization_id%type;
l_normal_hours per_all_assignments_f.normal_hours%type;
l_frequency    per_all_assignments_f.frequency%type;

--------------------------- Variables which will hold the Balance Values.
l_regwg_bal_val	Number := 0;
l_irrb_bal_val	Number := 0;
l_ovrt_bal_val	Number := 0;
l_othr_bal_val	Number := 0;
l_chrs_bal_val    number := 0;
l_mat_bal_val	Number := 0;
l_sic_bal_val	Number := 0;
l_otl_bal_val	Number := 0;
l_incct_bal_val	Number := 0;
l_red_bal_val	Number := 0;
l_otsoc_bal_val	Number := 0;
l_tr_sub_bal_val  Number := 0;
l_refund_bal_val  Number := 0;
l_vhi_bal_val	Number := 0;
l_hse_bal_val	Number := 0;
l_otben_bal_val	Number := 0;
l_ot_sub_bal_val  Number := 0;
l_nmw_bal_val	Number := 0;
l_stks_bal_val	Number := 0;
l_rbs_er_bal_val	Number := 0;
l_prsa_er_bal_val Number := 0;
l_rac_er_bal_val	Number := 0;
l_prsi_bal_val	Number := 0;
l_bik_veh_bal_val Number := 0;

l_pen_bal_val_tot Number := 0;
l_lap_bal_val_tot Number := 0;
l_app_wg_bal_val_tot Number := 0;
l_ssec_bal_val_tot Number := 0;

l_nmw_count Number := 0;

/* 6856473 */
l_al_bal_val number:=0;
--------------------------- Variables which will hold the Balance Values.

BEGIN
    hr_utility.set_location(' Entering PAY_IE_EHECS_REPORT_PKG.ehecs_main_proc', 800);

/*6856473*/
hr_utility.set_location(' before calling get parameters ', 800);

get_parameters(p_payroll_action_id,'EMPLOYER',l_org_id);
hr_utility.set_location(' before  cursor csr_hours_per_day and org_id '||l_org_id, 801);
OPEN csr_hours_per_day(l_org_id,p_business_group_id);
FETCH csr_hours_per_day INTO l_hours_per_day;
CLOSE csr_hours_per_day;

hr_utility.set_location(' AFTER  cursor csr_hours_per_day  '||l_hours_per_day, 801);

hr_utility.set_location(' Before Cursor cur_valid_asg', 810);

OPEN cur_valid_asg(p_assignment_id, p_person_id);
FETCH cur_valid_asg INTO l_valid_asg_rec;
--EXIT WHEN cur_valid_asg%NOTFOUND;
    hr_utility.set_location(' Inside Cursor cur_valid_asg', 820);
    hr_utility.set_location(' l_valid_asg_rec.assignment_id '||l_valid_asg_rec.assignment_id, 820);
    hr_utility.set_location(' l_valid_asg_rec.payroll_id '||l_valid_asg_rec.payroll_id, 820);

    hr_utility.set_location(' Before Cursor cur_valid_asg_act', 830);

  OPEN cur_valid_asg_act(l_valid_asg_rec.assignment_id, l_valid_asg_rec.payroll_id);
  FETCH cur_valid_asg_act INTO l_valid_asg_act_rec;

  hr_utility.set_location(' Inside Cursor cur_valid_asg_act', 840);

  IF cur_valid_asg_act%FOUND THEN
     --IF l_valid_asg_act_rec.assignment_action_id IS NOT NULL
     --THEN
		FOR bal_index IN 1..g_def_bal_id.COUNT
		LOOP
			IF g_def_bal_id(bal_index).balance_name   = 'Regular Earnings' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_regwg_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_regwg_bal_val '|| l_regwg_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name   = 'Irregular Earnings' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_irrb_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_irrb_bal_val '|| l_irrb_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name   = 'Overtime Payments' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_ovrt_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_ovrt_bal_val '|| l_ovrt_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name   = 'Paid Overtime Hours' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_othr_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_othr_bal_val '|| l_othr_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name   = 'Normal Working Hours' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);



/*6856473 added if conditions to check for salaried code*/

hr_utility.set_location(' l_valid_asg_rec.normal_hours '||l_valid_asg_rec.normal_hours, 850);
hr_utility.set_location(' l_valid_asg_rec.frequency '||l_valid_asg_rec.frequency, 850);
hr_utility.set_location(' l_valid_asg_rec.hourly_or_salaried '||l_valid_asg_rec.hourly_or_salaried, 850);

	IF(l_valid_asg_rec.hourly_or_salaried='S')
	THEN

		        IF(l_valid_asg_rec.frequency='D')
			THEN
			     l_chrs_bal_val:=nvl(l_valid_asg_rec.normal_hours,0)*91;
			ELSIF(l_valid_asg_rec.frequency='M')
			THEN
			     l_chrs_bal_val:=nvl(l_valid_asg_rec.normal_hours,0)*3;

			ELSIF(l_valid_asg_rec.frequency='W')
			THEN
			     l_chrs_bal_val:=nvl(l_valid_asg_rec.normal_hours,0)*13;
			ELSIF(l_valid_asg_rec.frequency='Y')
			THEN
			     l_chrs_bal_val:=(nvl(l_valid_asg_rec.normal_hours,0))/4;
                        END IF;
	      /* ELSE
	       l_errflag := 'Y';
               Fnd_file.put_line(FND_FILE.LOG,'Ensure that Normal hours value is not null at the assignment level of person'||p_person_id );
	       Raise l_ehecs_exception;
	       END IF;
	       */
	ELSE
				l_chrs_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
       END IF;
hr_utility.set_location(' l_chrs_bal_val '|| l_chrs_bal_val, 850);
--Bug # 6774024
			ELSIF (g_def_bal_id(bal_index).balance_name   = 'Paid Maternity Hours') THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_mat_bal_val := nvl(l_mat_bal_val,0)
				+
				PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);/*6856473*/

hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);

hr_utility.set_location(' l_mat_bal_val '|| l_mat_bal_val, 850);
			ELSIF (g_def_bal_id(bal_index).balance_name   = 'Paid Sick Leave Hours' ) THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_sic_bal_val :=
				nvl(l_sic_bal_val,0)
				+
				PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);/*6856473*/

hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_sic_bal_val '|| l_sic_bal_val, 850);
			ELSIF (g_def_bal_id(bal_index).balance_name   = 'Paid Other Leave Hours' ) THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_otl_bal_val :=
				l_otl_bal_val
				+
				PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);/*6856473*/

hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_otl_bal_val '|| l_otl_bal_val, 850);

/*6856473 added checks for balances Paid Maternity Days, Paid Sick Leave Days and Paid Other Leave Days*/

                        ELSIF (g_def_bal_id(bal_index).balance_name   = 'Paid Maternity Days') THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_mat_bal_val :=
				nvl(l_mat_bal_val,0)
				+
				PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null)*l_hours_per_day;

hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);

hr_utility.set_location(' l_mat_bal_val '|| l_mat_bal_val, 850);
			ELSIF ( g_def_bal_id(bal_index).balance_name   = 'Paid Sick Leave Days') THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_sic_bal_val :=
				nvl(l_sic_bal_val,0)
				+
				PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null)*l_hours_per_day;
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_sic_bal_val '|| l_sic_bal_val, 850);
			ELSIF ( g_def_bal_id(bal_index).balance_name   = 'Paid Other Leave Days') THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_otl_bal_val :=
				nvl(l_otl_bal_val,0)
                                +
				PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null)*l_hours_per_day
							;
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);

hr_utility.set_location(' l_otl_bal_val '|| l_otl_bal_val, 850);

			ELSIF g_def_bal_id(bal_index).balance_name   = 'Income Continuance Insurance' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_incct_bal_val :=  PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_incct_bal_val '|| l_incct_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name   = 'Redundancy Payments' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_red_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_red_bal_val '|| l_red_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name  = 'Employee Related Payments' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_otsoc_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_otsoc_bal_val '|| l_otsoc_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name  = 'Training Subsidies' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_tr_sub_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_tr_sub_bal_val '|| l_tr_sub_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name  = 'Refunds' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_refund_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_refund_bal_val '|| l_refund_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name  = 'Voluntary Sickness Insurance' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_vhi_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_vhi_bal_val '|| l_vhi_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name  = 'Staff Housing' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_hse_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_hse_bal_val '|| l_hse_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name  = 'Other Benefits' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_otben_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_otben_bal_val '|| l_otben_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name  = 'Other Subsidies' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_ot_sub_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_ot_sub_bal_val '|| l_ot_sub_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name  = 'Hourly Rate' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

		/*		l_nmw_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
               */
	                        l_nmw_bal_val:=( NVL(l_regwg_bal_val,0) + NVL(l_irrb_bal_val,0));
hr_utility.set_location(' l_nmw_bal_val '|| l_nmw_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name  = 'Stock Options and Share Purchase' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_stks_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_stks_bal_val '|| l_stks_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name  = 'IE RBS ER Contribution' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_rbs_er_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_rbs_er_bal_val '|| l_rbs_er_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name  = 'IE PRSA ER Contribution' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_prsa_er_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_prsa_er_bal_val '|| l_prsa_er_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name  = 'IE RAC ER Contribution' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_rac_er_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_rac_er_bal_val '|| l_rac_er_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name  = 'IE PRSI Employer' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_prsi_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_prsi_bal_val '|| l_prsi_bal_val, 850);
			ELSIF g_def_bal_id(bal_index).balance_name  = 'IE BIK Company Vehicle' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);

				l_bik_veh_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);

hr_utility.set_location(' l_bik_veh_bal_val '|| l_bik_veh_bal_val, 850);

/* 6856473 */
                      ELSIF g_def_bal_id(bal_index).balance_name  = 'Annual Leave and Bank Holiday Hours' THEN
hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);
				l_al_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_al_bal_val  '|| l_al_bal_val, 850);
                      ELSIF ( g_def_bal_id(bal_index).balance_name   = 'Annual Leave and Bank Holiday Days') THEN
hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_valid_asg_act_rec.assignment_action_id '||l_valid_asg_act_rec.assignment_action_id, 850);
				l_al_bal_val :=
				nvl(l_al_bal_val,0)
                                +
				PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_valid_asg_act_rec.assignment_action_id,
							g_employer_id,
							null,
							null,
							null,
							null,
							null)*l_hours_per_day
							;
hr_utility.set_location(' l_al_bal_val  '|| l_al_bal_val, 850);

			END IF;
		END LOOP;






		IF l_chrs_bal_val > 0 THEN
		  IF (l_nmw_bal_val / l_chrs_bal_val) <= g_ie_nat_min_wage_rate THEN
		   l_nmw_count := l_nmw_count + 1;
		  END IF;
		 END IF;
hr_utility.set_location(' l_nmw_count '|| l_nmw_count , 860);

		l_pen_bal_val_tot := NVL(l_rbs_er_bal_val,0) + NVL(l_prsa_er_bal_val,0) + NVL(l_rac_er_bal_val,0);

hr_utility.set_location(' l_pen_bal_val_tot '|| l_pen_bal_val_tot , 870);

		IF l_valid_asg_rec.EMP_CATG = 'AT' THEN
			l_app_wg_bal_val_tot := NVL(l_regwg_bal_val,0)  + NVL(l_ovrt_bal_val,0)  + NVL(l_irrb_bal_val,0);
			l_lap_bal_val_tot	   := NVL(l_mat_bal_val,0)    + NVL(l_sic_bal_val,0)   + NVL(l_otl_bal_val,0);
			l_ssec_bal_val_tot   := NVL(l_prsi_bal_val,0)   + NVL(l_incct_bal_val,0)
						    + NVL(l_red_bal_val,0)    + NVL(l_otsoc_bal_val,0);

			hr_utility.set_location(' l_app_wg_bal_val_tot '|| l_app_wg_bal_val_tot , 880);
			hr_utility.set_location(' l_lap_bal_val_tot '|| l_lap_bal_val_tot , 880);
			hr_utility.set_location(' l_ssec_bal_val_tot '|| l_ssec_bal_val_tot , 880);
		END IF;
	-- END IF;  --assignment action ID
  END IF;
  CLOSE cur_valid_asg_act;

hr_utility.set_location(' Before Inserting PAY_US_RPT_TOTALS', 890);
hr_utility.set_location(' VALUE OF EMP_CATG'||l_valid_asg_rec.EMP_CATG, 890);

	INSERT INTO PAY_US_RPT_TOTALS
	(BUSINESS_GROUP_ID
	,ATTRIBUTE1		--payroll_action_id
	,ATTRIBUTE2		--Assignment_id
	,ATTRIBUTE3		--EHECS_CATG		M(Managers)/C(Clerk)/P(Production Wrk)
	,ATTRIBUTE4		--EMP_CATG			F(full)/P(Part)/AT(Apprnt)
	,ATTRIBUTE5		--l_nmw_bal_val		Hourly Rate
	,ATTRIBUTE6		--l_regwg_bal_val		Regular Earning
	,ATTRIBUTE7		--l_ovrt_bal_val		Overtime Payments
	,ATTRIBUTE8		--l_irrb_bal_val		Irregular Earnings
	,ATTRIBUTE9		--l_app_wg_bal_val_tot	Irregular Earnings + Regular Earning + Overtime Payments
	,ATTRIBUTE10	--l_chrs_bal_val		Normal Working Hours
	,ATTRIBUTE11	--l_othr_bal_val		Paid Overtime Hours
	,ATTRIBUTE12	--l_nmw_count           Count for National Min Wage
	,ATTRIBUTE13	--l_mat_bal_val		Paid Maternity Leave
	,ATTRIBUTE14	--l_sic_bal_val		Paid Sick leave Hours
	,ATTRIBUTE15	--l_otl_bal_val		Paid Other Leave Hours
	,ATTRIBUTE16	--l_lap_bal_val_tot	l_mat_bal_val + l_sic_bal_val + l_otl_bal_val
	,ATTRIBUTE17	--l_pen_bal_val_tot	(IE RBS + IE PRSA + IE RAC) ER Contri
	,ATTRIBUTE18	--l_prsi_bal_val		IE PRSI Employer
	,ATTRIBUTE19	--l_incct_bal_val		Income Continuance Insurance
	,ATTRIBUTE20	--l_red_bal_val		Redundancy Payments
	,ATTRIBUTE21	--l_otsoc_bal_val		Employee Related Payments
	,ATTRIBUTE22	--l_ssec_bal_val_tot	l_prsi_bal_val+l_incct_bal_val+l_red_bal_val+l_otsoc_bal_val
	,ATTRIBUTE23	--l_bik_veh_bal_val	IE BIK Company Vehicle
	,ATTRIBUTE24	--l_stks_bal_val		Stock Options and Share Purchase.
	,ATTRIBUTE25	--l_vhi_bal_val		Voluntary Sickness Insurance
	,ATTRIBUTE26	--l_hse_bal_val		Staff Housing
	,ATTRIBUTE27	--l_otben_bal_val		Other Benifits
	,ATTRIBUTE28	--l_tr_sub_bal_val	Training Subsidies
	,ATTRIBUTE29	--l_ot_sub_bal_val	Other Subsidies
	,ATTRIBUTE30	--l_refund_bal_val	Refunds
	,ATTRIBUTE31	--l_rbs_er_bal_val	IE RBS ER Contribution
	,ATTRIBUTE32	--l_prsa_er_bal_val	IE PRSA ER Contribution
	,ATTRIBUTE33	--l_rac_er_bal_val	IE RAC ER Contribution
	,ATTRIBUTE34    --l_al_bal_val          Annual Leave and Bank Holidays  (both hours and days)          6856473
	)
	VALUES
	(p_business_group_id
	,p_payroll_action_id
	,l_valid_asg_rec.assignment_id
	,l_valid_asg_rec.EHECS_CATG
	,l_valid_asg_rec.EMP_CATG
	,l_nmw_bal_val
	,l_regwg_bal_val
	,l_ovrt_bal_val
	,l_irrb_bal_val
	,l_app_wg_bal_val_tot
	,l_chrs_bal_val
	,l_othr_bal_val
	,l_nmw_count
	,l_mat_bal_val
	,l_sic_bal_val
	,l_otl_bal_val
	,l_lap_bal_val_tot
	,l_pen_bal_val_tot
	,l_prsi_bal_val
	,l_incct_bal_val
	,l_red_bal_val
	,l_otsoc_bal_val
	,l_ssec_bal_val_tot
	,l_bik_veh_bal_val
	,l_stks_bal_val
	,l_vhi_bal_val
	,l_hse_bal_val
	,l_otben_bal_val
	,l_tr_sub_bal_val
	,l_ot_sub_bal_val
	,l_refund_bal_val
	,l_rbs_er_bal_val
	,l_prsa_er_bal_val
	,l_rac_er_bal_val
	,l_al_bal_val      -- 6856473
	 );

hr_utility.set_location(' After Inserting PAY_US_RPT_TOTALS', 900);

CLOSE cur_valid_asg;

hr_utility.set_location(' Leaving PAY_IE_EHECS_REPORT_PKG.ehecs_main_proc', 910);

END;

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
Hr_Utility.set_location('Entering: PAY_IE_EHECS_REPORT_PKG.c2b',1000);
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

Hr_Utility.set_location('Leaving: PAY_IE_EHECS_REPORT_PKG.c2b',1010);
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

l_person_id per_all_people_f.person_id%TYPE;
l_assignment_id per_all_assignments_f.assignment_id%TYPE;
l_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE;
l_object_action_id pay_temp_object_actions.object_action_id%TYPE;

CURSOR C_Perid_Asgid(p_payroll_action_id NUMBER, p_object_action_id NUMBER)  IS
	SELECT DISTINCT ppf.person_id, paa.assignment_id
	FROM per_all_people_f         ppf
	,per_all_assignments_f        paa
	,pay_payroll_actions          ppa
	,pay_temp_object_actions      ptoa
	WHERE paa.business_group_id = ppa.business_group_id
	AND paa.person_id = ppf.person_id
	AND ppa.payroll_action_id = p_payroll_action_id
	AND paa.business_group_id = g_business_Group_id
	AND ppa.payroll_action_id = ptoa.payroll_action_id
	AND ptoa.Object_id	  = paa.assignment_id
	AND ptoa.object_action_id = p_object_action_id;

BEGIN
hr_utility.set_location(' Entering: pay_ie_p45part3_p46_pkg_test.gen_body_xml: ', 2000);

l_payroll_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
l_object_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID');

OPEN C_Perid_Asgid(l_payroll_action_id, l_object_action_id);
FETCH C_Perid_Asgid into l_person_id, l_assignment_id;
CLOSE C_Perid_Asgid;

hr_utility.set_location('l_person_id '||TO_CHAR(l_person_id),2010);
hr_utility.set_location('l_assignment_id '||TO_CHAR(l_assignment_id),2010);
hr_utility.set_location('l_payroll_action_id '||TO_CHAR(l_payroll_action_id),2010);
hr_utility.set_location('l_object_action_id '||TO_CHAR(l_object_action_id),2010);

hr_utility.set_location('befiore calling Ehecs_main_proc ',2020);

ehecs_main_proc(	g_business_Group_id
			,l_payroll_action_id
			,l_assignment_id
			,l_person_id);

hr_utility.set_location('befiore calling Ehecs_main_proc ',2030);

hr_utility.set_location(' Leaving: pay_ie_p45part3_p46_pkg_test.gen_body_xml: ', 2040);

EXCEPTION
WHEN Others THEN
	Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,2050);
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
	action_information6 year,
	action_information7 quarter,
	action_information8 report_type,
	action_information9 software_name,
	action_information10 software_version,
	action_information11 vendor_name,
	action_information12 Vendor_phone,
	action_information13 org_id,
	action_information14 employer_name,
        action_information15 addr1,
	action_information16 addr2,
	action_information17 addr3,
	action_information18 addr4,
	action_information19 addr5,
	action_information20 change_indicator,
	action_information21 cbr_no,
	action_information22 declarant_name,
	action_information23 declarant_phone,
	action_information24 declarant_email,
	action_information25 declare_date,
	action_information26 declarant_position
	FROM    pay_action_information
	WHERE   action_context_id = c_pact_id
	AND     action_context_type = 'PA'
	AND     action_information_category ='IE_EHECS_HEADER';

	l_header c_get_header%rowtype;
	l_payroll_action_id number;

BEGIN
	l_proc := g_package || 'gen_header_xml';
	hr_utility.set_location ('Entering '||l_proc,1500);

	l_payroll_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
	hr_utility.set_location('Inside PAY_IE_EHECS_REPORT_PKG.gen_header_xml,l_payroll_action_id: '||l_payroll_action_id,300);

	OPEN c_get_header(l_payroll_action_id);
	FETCH c_get_header into l_header;
	CLOSE c_get_header;

	l_string := l_string || '<EHECS' ;					--7367314
	l_string := l_string || ' Yr="'|| l_header.year ||'"';
	l_string := l_string || ' Qtr="'|| l_header.quarter ||'"'  ;
	l_string := l_string || ' TypRt="'|| l_header.report_type||'"';
        l_string := l_string || ' SoftwareName="'|| l_header.software_name||'"';
	l_string := l_string || ' SoftwareVersion="'|| l_header.software_version||'"';
	l_string := l_string || ' VendorName="'|| l_header.vendor_name||'"';
	l_string := l_string || ' VendorPhone="'|| l_header.vendor_phone ||'">'||EOL ;

	l_string := l_string || '<Company>'||EOL ;

	l_string := l_string || ' <Name>'|| substr(l_header.employer_name,1,80)||'</Name>' ;
	l_string := l_string || ' <Addr1>'|| substr(l_header.addr1,1,80)||'</Addr1>';
	l_string := l_string || ' <Addr2>'|| substr(l_header.addr2,1,80)||'</Addr2>';
	l_string := l_string || ' <Addr3>'|| substr(l_header.addr3,1,80)||'</Addr3>';
	l_string := l_string || ' <Addr4>'|| substr(l_header.addr4,1,80)||'</Addr4>';
	l_string := l_string || ' <Addr5>'|| substr(l_header.addr5,1,80)||'</Addr5>';
	l_string := l_string || ' <ChgAd>'|| substr(l_header.change_indicator,1,20)||'</ChgAd>';
	l_string := l_string || ' <CBR>'||substr(l_header.cbr_no,1,12)||'</CBR>' ;

	l_string := l_string ||'</Company>'||EOL ;

      l_string := l_string || '<Declaration>'||EOL ;
   	l_string := l_string || ' <Contact>'|| substr(l_header.declarant_name,1,40) ||'</Contact>';
	l_string := l_string || ' <Phone>'|| substr(l_header.declarant_phone,1,14) ||'</Phone>' ;
	l_string := l_string || ' <Email>'|| substr(l_header.declarant_email,1,80) ||'</Email>';
	--l_string := l_string || ' <Date>'|| l_header.declare_date ||'</Date>';
	l_string := l_string || ' <Date>'|| to_char(fnd_date.canonical_to_date(l_header.declare_date),'DDMMYYYY') ||'</Date>'; /* 7367314QA */
	l_string := l_string || ' <Position>'||l_header.declarant_position||'</Position>';

      l_string := l_string ||'</Declaration>'||EOL ;
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
 l_string  varchar2(32767) := NULL;
 l_clob PAY_FILE_DETAILS.FILE_FRAGMENT%TYPE;
 l_blob PAY_FILE_DETAILS.BLOB_FILE_FRAGMENT%TYPE;
l_buf  VARCHAR2(2000);
l_proc VARCHAR2(100);

CURSOR cur_get_totals (c_pact_id NUMBER)
IS
SELECT
EHECS_CATG,
--SUM(decode(EMP_CATG,'P',sum_nmw_bal_val,'F',sum_nmw_bal_val)) nmw_pt_ft_mg_cl_ot
SUM(decode(EMP_CATG,'P',sum_nmw_count_val,'F',sum_nmw_count_val)) nmw_pt_ft_mg_cl_ot

,SUM(decode(EMP_CATG,'F',sum_regwg_bal_val)) regwg_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'F',sum_ovrt_bal_val)) ovrt_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'F',sum_irrb_bal_val)) irrb_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_regwg_bal_val)) regwg_pt_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_ovrt_bal_val)) ovrt_pt_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_irrb_bal_val)) irrb_pt_mg_cl_ot
,SUM(decode(EMP_CATG,'AT',sum_regwg_bal_val)) regwg_at_mg_cl_ot
,SUM(decode(EMP_CATG,'AT',sum_ovrt_bal_val)) ovrt_at_mg_cl_ot
,SUM(decode(EMP_CATG,'AT',sum_irrb_bal_val)) irrb_at_mg_cl_ot

,SUM(decode(EMP_CATG,'AT',sum_app_wg_bal_val_tot)) appwg_at_mg_cl_ot

,SUM(decode(EMP_CATG,'F',sum_chrs_bal_val)) chrs_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_chrs_bal_val)) chrs_pt_mg_cl_ot
,SUM(decode(EMP_CATG,'AT',sum_chrs_bal_val)) chrs_at_mg_cl_ot
,SUM(decode(EMP_CATG,'F',sum_othr_bal_val)) othr_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_othr_bal_val)) othr_pt_mg_cl_ot
,SUM(decode(EMP_CATG,'AT',sum_othr_bal_val)) othr_at_mg_cl_ot

,SUM(decode(EMP_CATG,'F',sum_al_bal_val)) al_ft_mg_cl_ot   -- 6856473
,SUM(decode(EMP_CATG,'P',sum_al_bal_val)) al_pt_mg_cl_ot   -- 6856473
,SUM(decode(EMP_CATG,'AT',sum_al_bal_val)) al_at_mg_cl_ot  -- 6856473

,SUM(decode(EMP_CATG,'F',sum_mat_bal_val)) mat_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'F',sum_sic_bal_val)) sic_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'F',sum_otl_bal_val)) otl_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_mat_bal_val)) mat_pt_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_sic_bal_val)) sic_pt_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_otl_bal_val)) otl_pt_mg_cl_ot
,SUM(decode(EMP_CATG,'AT',sum_mat_bal_val)) mat_at_mg_cl_ot
,SUM(decode(EMP_CATG,'AT',sum_sic_bal_val)) sic_at_mg_cl_ot
,SUM(decode(EMP_CATG,'AT',sum_otl_bal_val)) otl_at_mg_cl_ot

,SUM(decode(EMP_CATG,'AT',sum_lap_bal_val_tot)) lap_at_mg_cl_ot

,SUM(sum_pen_bal_val_tot) pen_pt_ft_at_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_prsi_bal_val,'F',sum_prsi_bal_val)) prsi_pt_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_incct_bal_val,'F',sum_incct_bal_val)) incct_pt_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_red_bal_val,'F',sum_red_bal_val)) red_pt_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_otsoc_bal_val,'F',sum_otsoc_bal_val)) otsoc_pt_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'AT',sum_prsi_bal_val)) prsi_at_mg_cl_ot
,SUM(decode(EMP_CATG,'AT',sum_incct_bal_val)) incct_at_mg_cl_ot
,SUM(decode(EMP_CATG,'AT',sum_red_bal_val)) red_at_mg_cl_ot
,SUM(decode(EMP_CATG,'AT',sum_otsoc_bal_val)) otsoc_at_mg_cl_ot

,SUM(decode(EMP_CATG,'AT',sum_ssec_bal_val_tot)) ssec_at_mg_cl_ot

,SUM(decode(EMP_CATG,'P',sum_bik_veh_bal_val,'F',sum_bik_veh_bal_val)) car_pt_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_stks_bal_val,'F',sum_stks_bal_val)) stks_pt_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_vhi_bal_val,'F',sum_vhi_bal_val)) vhi_pt_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_hse_bal_val,'F',sum_hse_bal_val)) hse_pt_ft_mg_cl_ot
,SUM(decode(EMP_CATG,'P',sum_otben_bal_val,'F',sum_otben_bal_val)) otben_pt_ft_mg_cl_ot
,SUM(sum_tr_sub_bal_val) trsub_all
,SUM(sum_ot_sub_bal_val) otsub_all
,SUM(sum_refund_bal_val) rfund_all
FROM
(
	SELECT
	 ATTRIBUTE3	EHECS_CATG
	,ATTRIBUTE4	EMP_CATG
	--,SUM(fnd_number.canonical_to_number(ATTRIBUTE5))	sum_nmw_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE12))	sum_nmw_count_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE6))	sum_regwg_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE7))	sum_ovrt_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE8))	sum_irrb_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE9))	sum_app_wg_bal_val_tot
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE10))	sum_chrs_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE11))	sum_othr_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE13))	sum_mat_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE14))	sum_sic_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE15))	sum_otl_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE16))	sum_lap_bal_val_tot
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE17))	sum_pen_bal_val_tot
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE18))	sum_prsi_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE19))	sum_incct_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE20))	sum_red_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE21))	sum_otsoc_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE22))	sum_ssec_bal_val_tot
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE23))	sum_bik_veh_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE24))	sum_stks_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE25))	sum_vhi_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE26))	sum_hse_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE27))	sum_otben_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE28))	sum_tr_sub_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE29))	sum_ot_sub_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE30))	sum_refund_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE31))	sum_rbs_er_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE32))	sum_prsa_er_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE33))	sum_rac_er_bal_val
	,SUM(fnd_number.canonical_to_number(ATTRIBUTE34))	sum_al_bal_val	-- 6856473
	FROM PAY_US_RPT_TOTALS
	WHERE ATTRIBUTE1 = to_char(c_pact_id)
	AND ATTRIBUTE3 IS NOT NULL
	AND ATTRIBUTE4 IS NOT NULL
	GROUP BY ATTRIBUTE3, ATTRIBUTE4
)
GROUP BY EHECS_CATG;

l_get_totals_rec cur_get_totals%rowtype;
l_get_totals_empty_rec cur_get_totals%rowtype;

Type tab_get_totals is table of cur_get_totals%rowtype index by varchar2(10);
l_tab_get_totals tab_get_totals;

l_appwgmg Number := 0;
l_appwgcl Number := 0;
l_appwgot Number := 0;

l_lapmg Number := 0;
l_lapcl Number := 0;
l_lapot Number := 0;

l_ssecapmg Number := 0;
l_ssecapcl Number := 0;
l_ssecapot Number := 0;

----------------------Override
CURSOR cur_get_Override_totals (c_org_id Number, c_bg_id Number)
IS
SELECT
EHECS_CATG,
SUM(decode(EMP_CATG,'P',l_nmw,'F',l_nmw)) l_sum_nmw
,SUM(decode(EMP_CATG,'F',l_regwg)) l_sum_regwg_ft
,SUM(decode(EMP_CATG,'F',l_ovrt)) l_sum_ovrt_ft
,SUM(decode(EMP_CATG,'F',l_irrb)) l_sum_irrb_ft
,SUM(decode(EMP_CATG,'P',l_regwg)) l_sum_regwg_pt
,SUM(decode(EMP_CATG,'P',l_ovrt)) l_sum_ovrt_pt
,SUM(decode(EMP_CATG,'P',l_irrb)) l_sum_irrb_pt

,SUM(decode(EMP_CATG,'AT',l_regwg)) l_sum_regwg_at
,SUM(decode(EMP_CATG,'AT',l_ovrt)) l_sum_ovrt_at
,SUM(decode(EMP_CATG,'AT',l_irrb)) l_sum_irrb_at

,SUM(decode(EMP_CATG,'F',l_chrs)) l_sum_chrs_ft
,SUM(decode(EMP_CATG,'P',l_chrs)) l_sum_chrs_pt
,SUM(decode(EMP_CATG,'AT',l_chrs)) l_sum_chrs_at

,SUM(decode(EMP_CATG,'F',l_othr)) l_sum_othr_ft
,SUM(decode(EMP_CATG,'P',l_othr)) l_sum_othr_pt
,SUM(decode(EMP_CATG,'AT',l_othr)) l_sum_othr_at

,SUM(decode(EMP_CATG,'F',l_al)) l_sum_al_ft
,SUM(decode(EMP_CATG,'F',l_mat)) l_sum_mat_ft
,SUM(decode(EMP_CATG,'F',l_sic)) l_sum_sic_ft
,SUM(decode(EMP_CATG,'F',l_otl)) l_sum_otl_ft
,SUM(decode(EMP_CATG,'P',l_al)) l_sum_al_pt
,SUM(decode(EMP_CATG,'P',l_mat)) l_sum_mat_pt
,SUM(decode(EMP_CATG,'P',l_sic)) l_sum_sic_pt
,SUM(decode(EMP_CATG,'P',l_otl)) l_sum_otl_pt

,SUM(decode(EMP_CATG,'AT',l_al)) l_sum_al_at
,SUM(decode(EMP_CATG,'AT',l_mat)) l_sum_mat_at
,SUM(decode(EMP_CATG,'AT',l_sic)) l_sum_sic_at
,SUM(decode(EMP_CATG,'AT',l_otl)) l_sum_otl_at

,SUM(decode(EMP_CATG,'P',l_incc,'F',l_incc)) l_sum_incc_pt_ft
,SUM(decode(EMP_CATG,'P',l_red,'F',l_red)) l_sum_red_pt_ft
,SUM(decode(EMP_CATG,'P',l_otsoc,'F',l_otsoc)) l_sum_otsoc_pt_ft

,SUM(decode(EMP_CATG,'AT',l_incc)) l_sum_incc_at
,SUM(decode(EMP_CATG,'AT',l_red)) l_sum_red_at
,SUM(decode(EMP_CATG,'AT',l_otsoc)) l_sum_otsoc_at

,SUM(decode(EMP_CATG,'P',l_stks,'F',l_stks)) l_sum_stks_pt_ft

,SUM(decode(EMP_CATG,'P',l_vhi,'F',l_vhi)) l_sum_vhi_pt_ft
,SUM(decode(EMP_CATG,'P',l_hse,'F',l_hse)) l_sum_hse_pt_ft

,SUM(decode(EMP_CATG,'P',l_otben,'F',l_otben)) l_sum_otben_ft
FROM
(
  select
       --decode(hoi.org_information1,'MPAP','M','CSSW','C','PTCO','P')  EHECS_CATG
	 decode(hoi.org_information1,'Managers','M','Clerical Workers','C','Production Workers','P')  EHECS_CATG
	,decode(hoi.org_information2,'FR','F','PR','P',hoi.org_information2) EMP_CATG
	,SUM(fnd_number.canonical_to_number(hoi.org_information3))  l_nmw
	,SUM(fnd_number.canonical_to_number(hoi.org_information4))  l_regwg
	,SUM(fnd_number.canonical_to_number(hoi.org_information5))  l_ovrt
	,SUM(fnd_number.canonical_to_number(hoi.org_information6))  l_irrb
	,SUM(fnd_number.canonical_to_number(hoi.org_information12)) l_chrs
	,SUM(fnd_number.canonical_to_number(hoi.org_information7))  l_othr
	,SUM(fnd_number.canonical_to_number(hoi.org_information8))  l_al
	,SUM(fnd_number.canonical_to_number(hoi.org_information9))  l_mat
	,SUM(fnd_number.canonical_to_number(hoi.org_information10)) l_sic
	,SUM(fnd_number.canonical_to_number(hoi.org_information11)) l_otl
	--,SUM(fnd_number.canonical_to_number(hoi.org_information13)) l_prsi
	,SUM(fnd_number.canonical_to_number(hoi.org_information14)) l_incc
	,SUM(fnd_number.canonical_to_number(hoi.org_information15)) l_red
	,SUM(fnd_number.canonical_to_number(hoi.org_information16)) l_otsoc
	,SUM(fnd_number.canonical_to_number(hoi.org_information17)) l_stks
	,SUM(fnd_number.canonical_to_number(hoi.org_information18)) l_vhi
	,SUM(fnd_number.canonical_to_number(hoi.org_information19)) l_hse
	,SUM(fnd_number.canonical_to_number(hoi.org_information20)) l_otben
  from hr_organization_units hou
	,hr_organization_information hoi
  where hoi.org_information_context='IE_EHECS_OVERRIDE'
	and hoi.organization_id=c_org_id
	and hoi.organization_id=hou.organization_id
	and hou.business_group_id= c_bg_id
	and hoi.org_information1 IS NOT NULL
	and hoi.org_information2 IS NOT NULL
	--and decode(hoi.org_information1,'MPAP','M','CSSW','C','PTCO','P') = NVL(g_occupational_category_M_C_P,decode(hoi.org_information1,'MPAP','M','CSSW','C','PTCO','P'))
	and decode(hoi.org_information1,'Managers','M','Clerical Workers','C','Production Workers','P') = NVL(g_occupational_category_M_C_P,decode(hoi.org_information1,'Managers','M','Clerical Workers','C','Production Workers','P'))
	and fnd_date.canonical_to_date(hoi.org_information13) between g_qtr_start_date and g_qtr_end_date
  --group by decode(hoi.org_information1,'MPAP','M','CSSW','C','PTCO','P'),
  group by decode(hoi.org_information1,'Managers','M','Clerical Workers','C','Production Workers','P'),
	decode(hoi.org_information2,'FR','F','PR','P',hoi.org_information2)
)
GROUP BY EHECS_CATG;

l_get_override_totals_rec cur_get_override_totals%rowtype;
l_get_ovrrd_tot_empty_rec cur_get_override_totals%rowtype;

Type tab_get_override_totals is table of cur_get_override_totals%rowtype index by varchar2(10);
l_tab_get_override_totals tab_get_override_totals;

------------------------------

CURSOR c_get_part1(c_pact_id NUMBER) IS
	SELECT
	NVL(action_information1,0) l_fst_ft_mg,
	NVL(action_information2,0) l_fst_ft_cl,
	NVL(action_information3,0) l_fst_ft_ot,
	NVL(action_information4,0) l_lst_ft_mg,
	NVL(action_information5,0) l_lst_ft_cl,
	NVL(action_information6,0) l_lst_ft_ot,
	NVL(action_information7,0) l_hire_ft_mg,
	NVL(action_information8,0) l_hire_ft_cl,
	NVL(action_information9,0) l_hire_ft_ot,
	NVL(action_information10,0) l_fst_pt_mg,
	NVL(action_information11,0) l_fst_pt_cl,
	NVL(action_information12,0) l_fst_pt_ot,
	NVL(action_information13,0) l_lst_pt_mg,
	NVL(action_information14,0) l_lst_pt_cl,
	NVL(action_information15,0) l_lst_pt_ot,
	NVL(action_information16,0) l_hire_pt_mg,
	NVL(action_information17,0) l_hire_pt_cl,
	NVL(action_information18,0) l_hire_pt_ot,
	NVL(action_information19,0) l_app_mg,
	NVL(action_information20,0) l_app_cl,
	NVL(action_information21,0) l_app_ot,
	NVL(action_information22,0) l_not_payroll_mg,
	NVL(action_information23,0) l_not_payroll_cl,
	NVL(action_information24,0) l_not_payroll_ot,
	NVL(action_information25,0) l_vac_mg,
	NVL(action_information26,0) l_vac_cl,
	NVL(action_information27,0) l_vac_ot,
	NVL(action_information28,0) l_min_paid_mg,
	NVL(action_information29,0) l_min_paid_cl,
	NVL(action_information30,0) l_min_paid_ot
	FROM    pay_action_information
	WHERE   action_context_id = c_pact_id
	AND     action_context_type = 'PA'
	AND     action_information_category ='IE_EHECS_PART1';



	CURSOR c_get_part2(c_pact_id NUMBER) IS
	SELECT
	ROUND(NVL(action_information1,0)) l_reg_wg_ft_mg,
	ROUND(NVL(action_information2,0)) l_reg_wg_ft_cl,
	ROUND(NVL(action_information3,0)) l_reg_wg_ft_ot,
	ROUND(NVL(action_information4,0)) l_ot_paid_ft_mg,
	ROUND(NVL(action_information5,0)) l_ot_paid_ft_cl,
	ROUND(NVL(action_information6,0)) l_ot_paid_ft_ot,
	ROUND(NVL(action_information7,0)) l_irr_bonus_ft_mg,
	ROUND(NVL(action_information8,0)) l_irr_bonus_ft_cl,
	ROUND(NVL(action_information9,0)) l_irr_bonus_ft_ot,
	ROUND(NVL(action_information10,0)) l_reg_wg_pt_mg,
	ROUND(NVL(action_information11,0)) l_reg_wg_pt_cl,
	ROUND(NVL(action_information12,0)) l_reg_wg_pt_ot,
	ROUND(NVL(action_information13,0)) l_ot_paid_pt_mg,
	ROUND(NVL(action_information14,0)) l_ot_paid_pt_cl,
	ROUND(NVL(action_information15,0)) l_ot_paid_pt_ot,
	ROUND(NVL(action_information16,0)) l_irr_bonus_pt_mg,
	ROUND(NVL(action_information17,0)) l_irr_bonus_pt_cl,
	ROUND(NVL(action_information18,0)) l_irr_bonus_pt_ot,
	ROUND(NVL(action_information19,0)) l_tot_wg_app_mg,
	ROUND(NVL(action_information20,0)) l_tot_wg_app_cl,
	ROUND(NVL(action_information21,0)) l_tot_wg_app_ot
	FROM    pay_action_information
	WHERE   action_context_id = c_pact_id
	AND     action_context_type = 'PA'
	AND     action_information_category ='IE_EHECS_PART2';

CURSOR c_get_part3(c_pact_id NUMBER) IS
	SELECT
	ROUND(NVL(action_information1,0)) l_contracted_hrs_paid_ft_mg,
	ROUND(NVL(action_information2,0)) l_contracted_hrs_paid_ft_cl,
	ROUND(NVL(action_information3,0)) l_contracted_hrs_paid_ft_ot,
	ROUND(NVL(action_information4,0)) l_ot_hrs_paid_ft_mg,
	ROUND(NVL(action_information5,0)) l_ot_hrs_paid_ft_cl,
	ROUND(NVL(action_information6,0)) l_ot_hrs_paid_ft_ot,
	ROUND(NVL(action_information7,0)) l_contracted_hrs_paid_pt_mg,
	ROUND(NVL(action_information8,0)) l_contracted_hrs_paid_pt_cl,
	ROUND(NVL(action_information9,0)) l_contracted_hrs_paid_pt_ot,
	ROUND(NVL(action_information10,0)) l_ot_hrs_paid_pt_mg,
	ROUND(NVL(action_information11,0)) l_ot_hrs_paid_pt_cl,
	ROUND(NVL(action_information12,0)) l_ot_hrs_paid_pt_ot,
	ROUND(NVL(action_information13,0)) l_contracted_hrs_paid_app_mg,
	ROUND(NVL(action_information14,0)) l_contracted_hrs_paid_app_cl,
	ROUND(NVL(action_information15,0)) l_contracted_hrs_paid_app_ot,
	ROUND(NVL(action_information16,0)) l_ot_hrs_paid_app_mg,
	ROUND(NVL(action_information17,0)) l_ot_hrs_paid_app_cl,
	ROUND(NVL(action_information18,0)) l_ot_hrs_paid_app_ot
	FROM    pay_action_information
	WHERE   action_context_id = c_pact_id
	AND     action_context_type = 'PA'
	AND     action_information_category ='IE_EHECS_PART3';

CURSOR c_get_part4(c_pact_id NUMBER) IS
	SELECT
	ROUND(NVL(action_information1,0)) l_ann_leave_ft_mg,
	ROUND(NVL(action_information2,0))l_ann_leave_ft_cl,
	ROUND(NVL(action_information3,0)) l_ann_leave_ft_ot,
	ROUND(NVL(action_information4,0)) l_mat_leave_ft_mg,
	ROUND(NVL(action_information5,0)) l_mat_leave_ft_cl,
	ROUND(NVL(action_information6,0)) l_mat_leave_ft_ot,
	ROUND(NVL(action_information7,0)) l_sck_leave_ft_mg,
	ROUND(NVL(action_information8,0)) l_sck_leave_ft_cl,
	ROUND(NVL(action_information9,0)) l_sck_leave_ft_ot,
	ROUND(NVL(action_information10,0)) l_other_leave_ft_mg,
	ROUND(NVL(action_information11,0)) l_other_leave_ft_cl,
	ROUND(NVL(action_information12,0)) l_other_leave_ft_ot,
	ROUND(NVL(action_information13,0)) l_ann_leave_pt_mg,
	ROUND(NVL(action_information14,0)) l_ann_leave_pt_cl,
	ROUND(NVL(action_information15,0)) l_ann_leave_pt_ot,
	ROUND(NVL(action_information16,0)) l_mat_leave_pt_mg,
	ROUND(NVL(action_information17,0)) l_mat_leave_pt_cl,
	ROUND(NVL(action_information18,0)) l_mat_leave_pt_ot,
	ROUND(NVL(action_information19,0)) l_sck_leave_pt_mg,
	ROUND(NVL(action_information20,0)) l_sck_leave_pt_cl,
	ROUND(NVL(action_information21,0)) l_sck_leave_pt_ot,
	ROUND(NVL(action_information22,0)) l_other_leave_pt_mg,
	ROUND(NVL(action_information23,0)) l_other_leave_pt_cl,
	ROUND(NVL(action_information24,0)) l_other_leave_pt_ot,
	ROUND(NVL(action_information25,0)) l_all_paid_leave_app_mg,
	ROUND(NVL(action_information26,0)) l_all_paid_leave_app_cl,
	ROUND(NVL(action_information27,0)) l_all_paid_leave_app_ot
	FROM    pay_action_information
	WHERE   action_context_id = c_pact_id
	AND     action_context_type = 'PA'
	AND     action_information_category ='IE_EHECS_PART4';

CURSOR c_get_part7(c_pact_id NUMBER) IS
	SELECT
	ROUND(NVL(action_information1,0)) l_employer_prsi_mg,
	ROUND(NVL(action_information2,0)) l_employer_prsi_cl,
	ROUND(NVL(action_information3,0)) l_employer_prsi_ot,
	ROUND(NVL(action_information4,0)) l_continuance_income_mg,
	ROUND(NVL(action_information5,0)) l_continuance_income_cl,
	ROUND(NVL(action_information6,0)) l_continuance_income_ot,
	ROUND(NVL(action_information7,0)) l_redundacny_paid_mg,
	ROUND(NVL(action_information8,0)) l_redundacny_paid_cl,
	ROUND(NVL(action_information9,0)) l_redundacny_paid_ot,
	ROUND(NVL(action_information10,0)) l_other_paid_mg,
	ROUND(NVL(action_information11,0)) l_other_paid_cl,
	ROUND(NVL(action_information12,0)) l_other_paid_ot,
	ROUND(NVL(action_information13,0)) l_ssc_contributions_app_mg,
	ROUND(NVL(action_information14,0)) l_ssc_contributions_app_cl,
	ROUND(NVL(action_information15,0)) l_ssc_contributions_app_ot
	FROM    pay_action_information
	WHERE   action_context_id = c_pact_id
	AND     action_context_type = 'PA'
	AND     action_information_category ='IE_EHECS_PART7';

CURSOR c_get_part8(c_pact_id NUMBER) IS
	SELECT
	ROUND(NVL(action_information1,0)) l_company_car_mg,
	ROUND(NVL(action_information2,0)) l_company_car_cl,
	ROUND(NVL(action_information3,0)) l_company_car_ot,
	ROUND(NVL(action_information4,0)) l_stock_options_mg,
	ROUND(NVL(action_information5,0)) l_stock_options_cl,
	ROUND(NVL(action_information6,0)) l_stock_options_ot,
	ROUND(NVL(action_information7,0)) l_vol_sick_insurance_mg,
	ROUND(NVL(action_information8,0)) l_vol_sick_insurance_cl,
	ROUND(NVL(action_information9,0)) l_vol_sick_insurance_ot,
	ROUND(NVL(action_information10,0)) l_staff_housing_mg,
	ROUND(NVL(action_information11,0)) l_staff_housing_cl,
	ROUND(NVL(action_information12,0)) l_staff_housing_ot,
	ROUND(NVL(action_information13,0)) l_other_benefits_mg,
	ROUND(NVL(action_information14,0)) l_other_benefits_cl,
	ROUND(NVL(action_information15,0)) l_other_benefits_ot
	FROM    pay_action_information
	WHERE   action_context_id = c_pact_id
	AND     action_context_type = 'PA'
	AND     action_information_category ='IE_EHECS_PART8';

CURSOR c_get_part_all_other(c_pact_id NUMBER) IS
	SELECT
	ROUND(NVL(action_information1,0)) l_employer_pension_mg,
	ROUND(NVL(action_information2,0)) l_employer_pension_cl,
	ROUND(NVL(action_information3,0)) l_employer_pension_ot,
	ROUND(NVL(action_information4,0)) l_employer_liability_premium,
	ROUND(NVL(action_information5,0)) l_employer_training_costs,
	ROUND(NVL(action_information6,0)) l_other_expenditure,
	ROUND(NVL(action_information7,0)) l_training_subsudies,
	ROUND(NVL(action_information8,0)) l_other_subsidies,
	ROUND(NVL(action_information9,0)) l_refunds,
	action_information10 l_comment_line1,
	action_information11 l_comment_line2,
	action_information12 l_comment_line3
	FROM    pay_action_information
	WHERE   action_context_id = c_pact_id
	AND     action_context_type = 'PA'
	AND     action_information_category ='IE_EHECS_ALL_OTHER';

l_data_part1 c_get_part1%rowtype;
l_data_part2 c_get_part2%rowtype;
l_data_part3 c_get_part3%rowtype;
l_data_part4 c_get_part4%rowtype;
l_data_part7 c_get_part7%rowtype;
l_data_part8 c_get_part8%rowtype;
l_data_part_all_other c_get_part_all_other%rowtype;

l_payroll_action_id NUMBER;
--l_asg_action_id NUMBER;
l_action_info_id NUMBER;
l_ovn NUMBER;

CURSOR csr_ehecs_eit(c_org_id  hr_organization_information.organization_id%type
                           ,c_bg_id hr_organization_units.business_group_id%type
				   ,p_year VARCHAR2
				   ,p_qtr VARCHAR2) IS
select hoi.org_information1 Year,
	hoi.org_information2 Qtr,
	hoi.org_information3 CBR,
	hoi.org_information4 avg_mgr_not_pyrl,
	hoi.org_information5 avg_clk_not_pyrl,
	hoi.org_information6 avg_prod_not_pyrl,
	hoi.org_information7 Job_Vac_Mgr,
	hoi.org_information8 Job_Vac_clk,
	hoi.org_information9 Job_Vac_prod,
	hoi.org_information10 Tot_empr_Lblt_Ins,
	hoi.org_information11 Trng_cost,
	hoi.org_information12 Lbr_Expdtr,
	hoi.org_information13 Declarant,
	hoi.org_information14 Trng_subsidy,
	hoi.org_information15 otr_subsidy,
	hoi.org_information16 refunds
from	hr_organization_units hou
	,hr_organization_information hoi
where hoi.org_information_context='IE_EHECS'
	and hoi.organization_id=c_org_id
	and hoi.organization_id=hou.organization_id
	and hou.business_group_id= c_bg_id
	and hoi.ORG_INFORMATION1 = p_year
	and hoi.ORG_INFORMATION2 = p_qtr;

l_csr_ehecs_eit csr_ehecs_eit%rowtype;


CURSOR csr_part1_qtr_start
IS
SELECT COUNT(1) tot, EMP_CATG, EHECS_CATG
FROM
(
SELECT
--decode(count(1),0,0,1) cnt,
distinct
--decode(paaf.EMPLOYMENT_CATEGORY,'FT','F','FR','F','PR','P','PT','P',paaf.EMPLOYMENT_CATEGORY) EMP_CATG,
 /* 6856486 */

 decode(paaf.EMPLOYMENT_CATEGORY
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Full_Time',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'F'
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Part_Time',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'P'
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Apprentice_Trainee',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'AT'
	) EMP_CATG,
/*
NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','MPAP',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),g_qtr_start_date),
    NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','CSSW',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),g_qtr_start_date),
        hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','PTCO',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),g_qtr_start_date)
        )
    ) EHECS_CATG, */
NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Managers',paaf.EMPLOYEE_CATEGORY,g_qtr_start_date),
NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Clerical Workers',paaf.EMPLOYEE_CATEGORY,g_qtr_start_date),
  hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Production Workers',paaf.EMPLOYEE_CATEGORY,g_qtr_start_date)
  )
) EHECS_CATG,
paaf.assignment_id
from
per_all_assignments_f paaf,
pay_all_payrolls_f papf,
hr_soft_coding_keyflex scl
where
paaf.business_group_id = g_business_group_id
and paaf.payroll_id is not null
and paaf.payroll_id = nvl(g_payroll_id,paaf.payroll_id)
and paaf.payroll_id = papf.payroll_id
and papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
and scl.segment4 = g_employer_id
and paaf.employee_category = nvl(g_occupational_category,paaf.employee_category)
/*
and (	select min(ptp.pay_advice_date)
	from per_time_periods ptp
	where ptp.payroll_id = paaf.payroll_id
	and ptp.pay_advice_date >= g_qtr_start_date
    )
*/
--and g_qtr_start_date between paaf.effective_start_date and paaf.effective_end_date
--and paaf.effective_start_date between g_qtr_start_date and g_qtr_end_date
and paaf.effective_start_date <= g_qtr_end_date  --g_qtr_start_date  --bug 7294966
--
AND ((g_assignment_set_id is not null
	     AND (g_exc_inc ='I' AND EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
					  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = g_business_group_id
					  AND   has.assignment_set_id = g_assignment_set_id
					  AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = paaf.person_id)
		OR g_exc_inc = 'E' AND NOT EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
					  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = g_business_group_id
					  AND   has.assignment_set_id = g_assignment_set_id
					  AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = paaf.person_id
					  )))
	  OR g_assignment_set_id IS NULL)
--
and exists (SELECT paa.assignment_action_id child_assignment_action_id,
       prt.run_method run_type
FROM   pay_assignment_actions paa,
       pay_run_types_f prt
WHERE  paa.run_type_id = prt.run_type_id
AND    prt.run_method IN ('N','P')
AND    g_qtr_start_date BETWEEN prt.effective_start_date AND prt.effective_end_date
AND    paa.assignment_action_id = (SELECT /*+ USE_NL(paa, ppa) */
				          fnd_number.canonical_to_number(max(paa.assignment_action_id)) child_assignment_action_id
				   FROM   pay_assignment_actions paa,
					  pay_payroll_actions    ppa
				   WHERE
					paa.assignment_id = paaf.assignment_id
					AND    ppa.payroll_action_id = paa.payroll_action_id
					AND    (paa.source_action_id is not null or ppa.action_type in ('I','V','B'))
					AND    ppa.effective_date = (select min(regular_payment_date)   --min(pay_advice_date) --bug 7294966
							from per_time_periods
							where payroll_id = paaf.payroll_id
							--and pay_advice_date >= g_qtr_start_date
							and regular_payment_date >= g_qtr_start_date   --bug 7294966
							)
					AND    ppa.action_type in ('R', 'Q', 'I', 'V','B')
					AND    paa.action_status = 'C'
					AND ppa.effective_date between paaf.effective_start_date AND  paaf.effective_end_date))	--Bug 7294966 QA
/*group by
decode(paaf.EMPLOYMENT_CATEGORY,'FT','F','FR','F','PR','P','PT','P',paaf.EMPLOYMENT_CATEGORY),
NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','MPAP',paaf.EMPLOYEE_CATEGORY,paaf.effective_start_date),
    NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','CSSW',paaf.EMPLOYEE_CATEGORY,paaf.effective_start_date),
    hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','PTCO',paaf.EMPLOYEE_CATEGORY,paaf.effective_start_date)
    )), paaf.person_id */
)
GROUP BY EMP_CATG, EHECS_CATG;

l_part1_qtr_start csr_part1_qtr_start%rowtype;

CURSOR csr_part1_qtr_end
IS
SELECT COUNT(1) tot, EMP_CATG, EHECS_CATG
FROM
(
SELECT
--decode(count(1),0,0,1) cnt,
distinct
--decode(paaf.EMPLOYMENT_CATEGORY,'FT','F','FR','F','PR','P','PT','P',paaf.EMPLOYMENT_CATEGORY) EMP_CATG,

/* 6856486 */

 decode(paaf.EMPLOYMENT_CATEGORY
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Full_Time',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'F'
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Part_Time',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'P'
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Apprentice_Trainee',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'AT'
	) EMP_CATG,
/*
NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','MPAP',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),g_qtr_end_date),
    NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','CSSW',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),g_qtr_end_date),
        hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','PTCO',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),g_qtr_end_date)
        )
    ) EHECS_CATG, */
NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Managers',paaf.EMPLOYEE_CATEGORY,g_qtr_end_date),
NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Clerical Workers',paaf.EMPLOYEE_CATEGORY,g_qtr_end_date),
  hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Production Workers',paaf.EMPLOYEE_CATEGORY,g_qtr_end_date)
  )
) EHECS_CATG,
paaf.assignment_id
from
per_all_assignments_f paaf,
pay_all_payrolls_f papf,
hr_soft_coding_keyflex scl
where
paaf.business_group_id = g_business_group_id
and paaf.payroll_id is not null
and paaf.payroll_id = nvl(g_payroll_id,paaf.payroll_id)
and paaf.payroll_id = papf.payroll_id
and papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
and scl.segment4 = g_employer_id
and paaf.employee_category = nvl(g_occupational_category,paaf.employee_category)
/*
and (	select max(ptp.pay_advice_date)
	from per_time_periods ptp
	where ptp.payroll_id = paaf.payroll_id
	and ptp.pay_advice_date <= g_qtr_end_date
    )
*/
--and g_qtr_start_date between paaf.effective_start_date and paaf.effective_end_date
--and paaf.effective_start_date between g_qtr_start_date and g_qtr_end_date
and paaf.effective_start_date <= g_qtr_end_date
--
AND ((g_assignment_set_id is not null
	     AND (g_exc_inc ='I' AND EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
					  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = g_business_group_id
					  AND   has.assignment_set_id = g_assignment_set_id
					  AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = paaf.person_id)
		OR g_exc_inc = 'E' AND NOT EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
					  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = g_business_group_id
					  AND   has.assignment_set_id = g_assignment_set_id
					  AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = paaf.person_id
					  )))
	  OR g_assignment_set_id IS NULL)
--
and exists (SELECT paa.assignment_action_id child_assignment_action_id,
       prt.run_method run_type
FROM   pay_assignment_actions paa,
       pay_run_types_f prt
WHERE  paa.run_type_id = prt.run_type_id
AND    prt.run_method IN ('N','P')
AND    g_qtr_start_date BETWEEN prt.effective_start_date AND prt.effective_end_date
AND    paa.assignment_action_id = (SELECT /*+ USE_NL(paa, ppa) */
				          fnd_number.canonical_to_number(max(paa.assignment_action_id)) child_assignment_action_id
				   FROM   pay_assignment_actions paa,
					  pay_payroll_actions    ppa
				   WHERE
					paa.assignment_id = paaf.assignment_id
					AND    ppa.payroll_action_id = paa.payroll_action_id
					AND    (paa.source_action_id is not null or ppa.action_type in ('I','V','B'))
					AND    ppa.effective_date = (select  max(regular_payment_date)  --max(pay_advice_date)  --bug 7294966
							from per_time_periods
							where payroll_id = paaf.payroll_id
							--and pay_advice_date <= g_qtr_end_date
							and regular_payment_date <= g_qtr_end_date    --bug 7294966
							)
					AND    ppa.action_type in ('R', 'Q', 'I', 'V','B')
					AND    paa.action_status = 'C'
					AND    ppa.effective_date between paaf.effective_start_date AND  paaf.effective_end_date))	--Bug 7294966 QA
/*
group by
decode(paaf.EMPLOYMENT_CATEGORY,'FT','F','FR','F','PR','P','PT','P',paaf.EMPLOYMENT_CATEGORY),
NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','MPAP',paaf.EMPLOYEE_CATEGORY,paaf.effective_start_date),
    NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','CSSW',paaf.EMPLOYEE_CATEGORY,paaf.effective_start_date),
    hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','PTCO',paaf.EMPLOYEE_CATEGORY,paaf.effective_start_date)
    )), paaf.person_id
*/
)
GROUP BY EMP_CATG, EHECS_CATG;

l_part1_qtr_end csr_part1_qtr_end%ROWTYPE;

CURSOR csr_part1_hire_qtr
IS
SELECT COUNT(1) tot, EMP_CATG, EHECS_CATG
FROM
(
SELECT
--decode(count(1),0,0,1) cnt,
distinct
--decode(paaf.EMPLOYMENT_CATEGORY,'FT','F','FR','F','PR','P','PT','P',paaf.EMPLOYMENT_CATEGORY) EMP_CATG,
/* 6856486 */

 decode(paaf.EMPLOYMENT_CATEGORY
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Full_Time',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'F'
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Part_Time',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'P'
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Apprentice_Trainee',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'AT'
	) EMP_CATG,
/*
NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','MPAP',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),paaf.effective_start_date),
    NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','CSSW',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),paaf.effective_start_date),
        hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','PTCO',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),paaf.effective_start_date)
        )
    ) EHECS_CATG, */
NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Managers',paaf.EMPLOYEE_CATEGORY,g_qtr_end_date),
    NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Clerical Workers',paaf.EMPLOYEE_CATEGORY,g_qtr_end_date),
        hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Production Workers',paaf.EMPLOYEE_CATEGORY,g_qtr_end_date)
        )
    ) EHECS_CATG,
paaf.assignment_id,
pps.period_of_service_id
from
per_all_assignments_f paaf,
pay_all_payrolls_f papf,
hr_soft_coding_keyflex scl,
per_periods_of_service pps
where
paaf.business_group_id = g_business_group_id
and paaf.payroll_id is not null
and paaf.payroll_id = nvl(g_payroll_id,paaf.payroll_id)
and paaf.payroll_id = papf.payroll_id
and papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
and scl.segment4 = g_employer_id
and paaf.employee_category = nvl(g_occupational_category,paaf.employee_category)
and pps.person_id = paaf.person_id
and pps.business_group_id = paaf.business_group_id
and pps.period_of_service_id = paaf.period_of_service_id
and pps.date_start between g_qtr_start_date And g_qtr_end_date
and paaf.effective_start_date between pps.date_start and g_qtr_end_date
--
AND ((g_assignment_set_id is not null
	     AND (g_exc_inc ='I' AND EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
					  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = g_business_group_id
					  AND   has.assignment_set_id = g_assignment_set_id
					  AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = paaf.person_id)
		OR g_exc_inc = 'E' AND NOT EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
					  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = g_business_group_id
					  AND   has.assignment_set_id = g_assignment_set_id
					  AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = paaf.person_id
					  )))
	  OR g_assignment_set_id IS NULL)
--
--and g_qtr_start_date between paaf.effective_start_date and paaf.effective_end_date
/*
and (	select min(ptp.pay_advice_date)
	from per_time_periods ptp
	where ptp.payroll_id = paaf.payroll_id
	and ptp.pay_advice_date >= g_qtr_start_date
    )
*/
/*
and g_qtr_start_date between paaf.effective_start_date and paaf.effective_end_date
and exists (SELECT paa.assignment_action_id child_assignment_action_id,
       prt.run_method run_type
FROM   pay_assignment_actions paa,
       pay_run_types_f prt
WHERE  paa.run_type_id = prt.run_type_id
AND    prt.run_method IN ('N','P')
AND    g_qtr_start_date BETWEEN prt.effective_start_date AND prt.effective_end_date
AND    paa.assignment_action_id = (SELECT /*+ USE_NL(paa, ppa)
				          fnd_number.canonical_to_number(max(paa.assignment_action_id)) child_assignment_action_id
				   FROM   pay_assignment_actions paa,
					  pay_payroll_actions    ppa
				   WHERE
					paa.assignment_id = paaf.assignment_id
					AND    ppa.payroll_action_id = paa.payroll_action_id
					AND    (paa.source_action_id is not null or ppa.action_type in ('I','V'))
					AND    ppa.effective_date between (select min(pay_advice_date)
									from per_time_periods
									where payroll_id = paaf.payroll_id
									and pay_advice_date >= g_qtr_start_date
									)
								  AND g_qtr_end_date
					AND    ppa.action_type in ('R', 'Q', 'I', 'V')
					AND    paa.action_status = 'C'))

group by
decode(paaf.employment_category,'FT','F','FR','F','PR','P','PT','P',paaf.employment_category),

NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','MPAP',paaf.EMPLOYEE_CATEGORY,paaf.effective_start_date),
    NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','CSSW',paaf.EMPLOYEE_CATEGORY,paaf.effective_start_date),
    hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','PTCO',paaf.EMPLOYEE_CATEGORY,paaf.effective_start_date)
    )), paaf.person_id, pps.period_of_service_id
*/
)
GROUP BY EMP_CATG, EHECS_CATG;

l_part1_hire_qtr csr_part1_hire_qtr%ROWTYPE;

CURSOR csr_all_payrolls
IS
select distinct papf.payroll_id
from
per_all_assignments_f paaf,
pay_all_payrolls_f papf,
hr_soft_coding_keyflex scl
where
paaf.business_group_id = g_business_group_id
and paaf.payroll_id is not null
and paaf.payroll_id = nvl(g_payroll_id,paaf.payroll_id)
and paaf.payroll_id = papf.payroll_id
and papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
and scl.segment4 = g_employer_id
and paaf.employee_category = nvl(g_occupational_category,paaf.employee_category)
--and paaf.employment_category = 'AT'	--Apprentice
 /* 6856486 */
and paaf.employment_category=hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Apprentice_Trainee',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date)
and paaf.effective_start_date <= g_qtr_end_date
and paaf.effective_end_date >= g_qtr_start_date;


CURSOR csr_period_dates(p_payroll_id Number)
IS
select pay_advice_date
from per_time_periods ptp
where ptp.payroll_id = p_payroll_id
and ptp.pay_advice_date between g_qtr_start_date and g_qtr_end_date;


CURSOR csr_app_mgr_clk_pro(p_payroll_id Number, p_period_date date)
IS
SELECT COUNT(1) tot, EMP_CATG, EHECS_CATG
FROM
(
SELECT
distinct
--decode(paaf.EMPLOYMENT_CATEGORY,'FT','F','FR','F','PR','P','PT','P',paaf.EMPLOYMENT_CATEGORY) EMP_CATG,
/* 6856486 */
 decode(paaf.EMPLOYMENT_CATEGORY
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Full_Time',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'F'
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Part_Time',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'P'
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Apprentice_Trainee',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date),'AT'
	) EMP_CATG,
/*
NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','MPAP',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),paaf.effective_start_date),
    NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','CSSW',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),paaf.effective_start_date),
        hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','PTCO',substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)),paaf.effective_start_date)
        )
    ) EHECS_CATG, */
NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Managers',paaf.EMPLOYEE_CATEGORY,g_qtr_start_date),
    NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Clerical Workers',paaf.EMPLOYEE_CATEGORY,g_qtr_start_date),
        hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Production Workers',paaf.EMPLOYEE_CATEGORY,g_qtr_start_date)
        )
    ) EHECS_CATG,
paaf.assignment_id
from
per_all_assignments_f paaf,
pay_all_payrolls_f papf,
hr_soft_coding_keyflex scl
where
paaf.business_group_id = g_business_group_id
and paaf.payroll_id is not null
and paaf.payroll_id = p_payroll_id
and paaf.payroll_id = papf.payroll_id
and papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
and scl.segment4 = g_employer_id
and paaf.employee_category = nvl(g_occupational_category,paaf.employee_category)
--and paaf.employment_category = 'AT'
 /* 6856486 */
and paaf.employment_category=hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Apprentice_Trainee',paaf.EMPLOYMENT_CATEGORY,g_qtr_start_date)
and paaf.effective_start_date <= g_qtr_end_date
and paaf.effective_end_date >= g_qtr_start_date
--
AND ((g_assignment_set_id is not null
	     AND (g_exc_inc ='I' AND EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
					  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = g_business_group_id
					  AND   has.assignment_set_id = g_assignment_set_id
					  AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = paaf.person_id)
		OR g_exc_inc = 'E' AND NOT EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
					  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = g_business_group_id
					  AND   has.assignment_set_id = g_assignment_set_id
					  AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = paaf.person_id
					  )))
	  OR g_assignment_set_id IS NULL)
--
and exists (SELECT paa.assignment_action_id child_assignment_action_id,
       prt.run_method run_type
FROM   pay_assignment_actions paa,
       pay_run_types_f prt
WHERE  paa.run_type_id = prt.run_type_id
AND    prt.run_method IN ('N','P')
AND    g_qtr_start_date BETWEEN prt.effective_start_date AND prt.effective_end_date
AND    paa.assignment_action_id = (SELECT /*+ USE_NL(paa, ppa) */
				          fnd_number.canonical_to_number(max(paa.assignment_action_id)) child_assignment_action_id
				   FROM   pay_assignment_actions paa,
					    pay_payroll_actions    ppa
				   WHERE
					paa.assignment_id = paaf.assignment_id
					AND    ppa.payroll_action_id = paa.payroll_action_id
					AND    (paa.source_action_id is not null or ppa.action_type in ('I','V','B'))
					AND    ppa.effective_date = p_period_date
					AND    ppa.action_type in ('R', 'Q', 'I', 'V','B')
					AND    paa.action_status = 'C'))
)
GROUP BY EMP_CATG, EHECS_CATG;

l_fst_ft_mg number := 0;
l_fst_pt_mg number := 0;

l_fst_ft_cl number := 0;
l_fst_pt_cl number := 0;

l_fst_ft_ot number := 0;
l_fst_pt_ot number := 0;

l_lst_ft_mg number := 0;
l_lst_pt_mg number := 0;

l_lst_ft_cl number := 0;
l_lst_pt_cl number := 0;

l_lst_ft_ot number := 0;
l_lst_pt_ot number := 0;

l_hire_ft_mg number := 0;
l_hire_pt_mg number := 0;

l_hire_ft_cl number := 0;
l_hire_pt_cl number := 0;

l_hire_ft_ot number := 0;
l_hire_pt_ot number := 0;

l_number_of_periods Number := 0;
l_cnt_app_mgr Number := 0;
l_cnt_app_clk Number := 0;
l_cnt_app_oth Number := 0;

l_cnt_app_mgr_final Number := 0;
l_cnt_app_clk_final Number := 0;
l_cnt_app_oth_final Number := 0;

l_is_gt_0 Varchar2(100);

begin

hr_utility.set_location('entering pay_ie_ehecs_report_pkg,gen_footer ',3000);

l_payroll_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
hr_utility.set_location('l_payroll_action_id. '||TO_CHAR(l_payroll_action_id),3010);


l_tab_get_totals.delete;
hr_utility.set_location('After deleting l_tab_get_totals pltable ',3020);

--Initializing to prevent the no data found error
l_tab_get_totals('M') := l_get_totals_empty_rec;
l_tab_get_totals('C') := l_get_totals_empty_rec;
l_tab_get_totals('P') := l_get_totals_empty_rec;

hr_utility.set_location('After initializing l_tab_get_totals pltable ',3030);

open cur_get_totals(l_payroll_action_id);
loop
  fetch cur_get_totals into l_get_totals_rec;
  EXIT WHEN cur_get_totals%NOTFOUND;
  hr_utility.set_location('Inside cursor cur_get_totals.',3031);
  l_tab_get_totals(l_get_totals_rec.ehecs_catg) := l_get_totals_rec;
end loop;
close cur_get_totals;

hr_utility.set_location('After cursor cur_get_totals ',3040);

-- Override Values.
l_tab_get_override_totals.delete;
hr_utility.set_location('After deleting l_tab_get_override_totals pltable ',3050);

--Initializing to prevent the no data found error
l_tab_get_override_totals('M') := l_get_ovrrd_tot_empty_rec;
l_tab_get_override_totals('C') := l_get_ovrrd_tot_empty_rec;
l_tab_get_override_totals('P') := l_get_ovrrd_tot_empty_rec;

hr_utility.set_location('After initializing l_tab_get_override_totals pltable ',3060);

open cur_get_override_totals(g_employer_id,g_business_group_id);
loop
  fetch cur_get_override_totals into l_get_override_totals_rec;
  EXIT WHEN cur_get_override_totals%NOTFOUND;
  hr_utility.set_location('Inside cursor cur_get_override_totals.',3061);
  l_tab_get_override_totals(l_get_override_totals_rec.ehecs_catg) := l_get_override_totals_rec;
end loop;
close cur_get_override_totals;

hr_utility.set_location('After Cursor cur_get_override_totals ',3070);

OPEN csr_ehecs_eit(g_employer_id, g_business_group_id, g_year, g_quarter);
FETCH csr_ehecs_eit INTO l_csr_ehecs_eit;
CLOSE csr_ehecs_eit;

hr_utility.set_location('After Cursor csr_ehecs_eit ',3080);

OPEN csr_part1_qtr_start;
LOOP
FETCH csr_part1_qtr_start INTO l_part1_qtr_start;
EXIT WHEN csr_part1_qtr_start%NOTFOUND;
hr_utility.set_location('Inside Cursor csr_part1_qtr_start ',3085);
hr_utility.set_location('l_part1_qtr_start.EMP_CATG '||l_part1_qtr_start.EMP_CATG,3086);
hr_utility.set_location('l_part1_qtr_start.EHECS_CATG '||l_part1_qtr_start.EHECS_CATG,3087);

	IF l_part1_qtr_start.EMP_CATG = 'F' AND l_part1_qtr_start.EHECS_CATG = 'M' THEN
		l_fst_ft_mg := l_part1_qtr_start.tot;
	ELSIF l_part1_qtr_start.EMP_CATG = 'F' AND l_part1_qtr_start.EHECS_CATG = 'C' THEN
		l_fst_ft_cl := l_part1_qtr_start.tot;
	ELSIF l_part1_qtr_start.EMP_CATG = 'F' AND l_part1_qtr_start.EHECS_CATG = 'P' THEN
		l_fst_ft_ot := l_part1_qtr_start.tot;
	ELSIF l_part1_qtr_start.EMP_CATG = 'P' AND l_part1_qtr_start.EHECS_CATG = 'M' THEN
		l_fst_pt_mg := l_part1_qtr_start.tot;
	ELSIF l_part1_qtr_start.EMP_CATG = 'P' AND l_part1_qtr_start.EHECS_CATG = 'C' THEN
		l_fst_pt_cl := l_part1_qtr_start.tot;
	ELSIF l_part1_qtr_start.EMP_CATG = 'P' AND l_part1_qtr_start.EHECS_CATG = 'P' THEN
		l_fst_pt_ot := l_part1_qtr_start.tot;
	END IF;
END LOOP;
CLOSE csr_part1_qtr_start;

hr_utility.set_location('l_fst_ft_mg'||l_fst_ft_mg,3085);
hr_utility.set_location('l_fst_ft_cl'||l_fst_ft_cl,3085);
hr_utility.set_location('l_fst_ft_ot'||l_fst_ft_ot,3085);
hr_utility.set_location('l_fst_pt_mg'||l_fst_pt_mg,3085);
hr_utility.set_location('l_fst_pt_cl'||l_fst_pt_cl,3085);
hr_utility.set_location('l_fst_pt_ot'||l_fst_pt_ot,3085);


hr_utility.set_location('After Cursor csr_part1_qtr_start ',3090);

OPEN csr_part1_qtr_end;
LOOP
FETCH csr_part1_qtr_end INTO l_part1_qtr_end;
EXIT WHEN csr_part1_qtr_end%NOTFOUND;
hr_utility.set_location('Inside Cursor csr_part1_qtr_end ',3091);
hr_utility.set_location('l_part1_qtr_end.EMP_CATG '||l_part1_qtr_end.EMP_CATG,3092);
hr_utility.set_location('l_part1_qtr_end.EHECS_CATG  '||l_part1_qtr_end.EHECS_CATG,3093);

	IF l_part1_qtr_end.EMP_CATG = 'F' AND l_part1_qtr_end.EHECS_CATG = 'M' THEN
		l_lst_ft_mg := l_part1_qtr_end.tot;
	ELSIF l_part1_qtr_end.EMP_CATG = 'F' AND l_part1_qtr_end.EHECS_CATG = 'C' THEN
		l_lst_ft_cl := l_part1_qtr_end.tot;
	ELSIF l_part1_qtr_end.EMP_CATG = 'F' AND l_part1_qtr_end.EHECS_CATG = 'P' THEN
		l_lst_ft_ot := l_part1_qtr_end.tot;
	ELSIF l_part1_qtr_end.EMP_CATG = 'P' AND l_part1_qtr_end.EHECS_CATG = 'M' THEN
		l_lst_pt_mg := l_part1_qtr_end.tot;
	ELSIF l_part1_qtr_end.EMP_CATG = 'P' AND l_part1_qtr_end.EHECS_CATG = 'C' THEN
		l_lst_pt_cl := l_part1_qtr_end.tot;
	ELSIF l_part1_qtr_end.EMP_CATG = 'P' AND l_part1_qtr_end.EHECS_CATG = 'P' THEN
		l_lst_pt_ot := l_part1_qtr_end.tot;
	END IF;
END LOOP;
CLOSE csr_part1_qtr_end;

hr_utility.set_location('l_lst_ft_mg'||l_lst_ft_mg,3095);
hr_utility.set_location('l_lst_ft_cl'||l_lst_ft_cl,3095);
hr_utility.set_location('l_lst_ft_ot'||l_lst_ft_ot,3095);
hr_utility.set_location('l_lst_pt_mg'||l_lst_pt_mg,3095);
hr_utility.set_location('l_lst_pt_cl'||l_lst_pt_cl,3095);
hr_utility.set_location('l_lst_pt_ot'||l_lst_pt_ot,3095);

hr_utility.set_location('After Cursor csr_part1_qtr_end ',3100);

OPEN csr_part1_hire_qtr;
LOOP
FETCH csr_part1_hire_qtr INTO l_part1_hire_qtr;
EXIT WHEN csr_part1_hire_qtr%NOTFOUND;
hr_utility.set_location('Inside Cursor csr_part1_hire_qtr ',3101);
hr_utility.set_location('l_part1_hire_qtr.EMP_CATG '||l_part1_hire_qtr.EMP_CATG,3102);
hr_utility.set_location('l_part1_hire_qtr.EHECS_CATG  '||l_part1_hire_qtr.EHECS_CATG,3103);

	IF l_part1_hire_qtr.EMP_CATG = 'F' AND l_part1_hire_qtr.EHECS_CATG = 'M' THEN
		l_hire_ft_mg := l_part1_hire_qtr.tot;
	ELSIF l_part1_hire_qtr.EMP_CATG = 'F' AND l_part1_hire_qtr.EHECS_CATG = 'C' THEN
		l_hire_ft_cl := l_part1_hire_qtr.tot;
	ELSIF l_part1_hire_qtr.EMP_CATG = 'F' AND l_part1_hire_qtr.EHECS_CATG = 'P' THEN
		l_hire_ft_ot := l_part1_hire_qtr.tot;
	ELSIF l_part1_hire_qtr.EMP_CATG = 'P' AND l_part1_hire_qtr.EHECS_CATG = 'M' THEN
		l_hire_pt_mg := l_part1_hire_qtr.tot;
	ELSIF l_part1_hire_qtr.EMP_CATG = 'P' AND l_part1_hire_qtr.EHECS_CATG = 'C' THEN
		l_hire_pt_cl := l_part1_hire_qtr.tot;
	ELSIF l_part1_hire_qtr.EMP_CATG = 'P' AND l_part1_hire_qtr.EHECS_CATG = 'P' THEN
		l_hire_pt_ot := l_part1_hire_qtr.tot;
	END IF;
END LOOP;
CLOSE csr_part1_hire_qtr;

hr_utility.set_location('l_hire_ft_mg'||l_hire_ft_mg,3095);
hr_utility.set_location('l_hire_ft_cl'||l_hire_ft_cl,3095);
hr_utility.set_location('l_hire_ft_ot'||l_hire_ft_ot,3095);
hr_utility.set_location('l_hire_pt_mg'||l_hire_pt_mg,3095);
hr_utility.set_location('l_hire_pt_cl'||l_hire_pt_cl,3095);
hr_utility.set_location('l_hire_pt_ot'||l_hire_pt_ot,3095);

hr_utility.set_location('After Cursor csr_part1_hire_qtr ',3110);

l_cnt_app_mgr_final := 0;
l_cnt_app_clk_final := 0;
l_cnt_app_oth_final := 0;

hr_utility.set_location('Before Cursor csr_all_payrolls ',3130);

FOR pyr_index IN csr_all_payrolls
LOOP
hr_utility.set_location('Inside Cursor csr_all_payrolls ',3140);
	l_number_of_periods := 0;
	FOR prd_index IN csr_period_dates(pyr_index.payroll_id)
	LOOP
hr_utility.set_location('Inside Cursor csr_period_dates ',3150);
hr_utility.set_location('l_number_of_periods '||l_number_of_periods,3150);
		l_number_of_periods := l_number_of_periods + 1;
		FOR asg_index IN csr_app_mgr_clk_pro(pyr_index.payroll_id, prd_index.pay_advice_date)
		LOOP
hr_utility.set_location('Inside Cursor csr_app_mgr_clk_pro ',3160);
hr_utility.set_location('asg_index.EHECS_CATG '||asg_index.EHECS_CATG,3160);
hr_utility.set_location('l_cnt_app_mgr '||l_cnt_app_mgr,3160);
hr_utility.set_location('l_cnt_app_clk '||l_cnt_app_clk,3160);
hr_utility.set_location('l_cnt_app_oth '||l_cnt_app_oth,3160);
hr_utility.set_location('asg_index.tot '||asg_index.tot,3160);

			IF asg_index.EHECS_CATG = 'M' THEN
				l_cnt_app_mgr := l_cnt_app_mgr + asg_index.tot;
			ELSIF asg_index.EHECS_CATG = 'C' THEN
				l_cnt_app_clk := l_cnt_app_clk + asg_index.tot;
			ELSIF asg_index.EHECS_CATG = 'P' THEN
				l_cnt_app_oth := l_cnt_app_oth + asg_index.tot;
			END IF;
		END LOOP;
	END LOOP;

	IF l_number_of_periods > 0 THEN
	hr_utility.set_location('Inside IF l_number_of_periods > 0 before ',3170);
	hr_utility.set_location('l_cnt_app_mgr_final '||l_cnt_app_mgr_final,3170);
	hr_utility.set_location('l_cnt_app_mgr '||l_cnt_app_mgr,3170);

	hr_utility.set_location('l_cnt_app_clk_final '||l_cnt_app_clk_final,3170);
	hr_utility.set_location('l_cnt_app_clk '||l_cnt_app_clk,3170);

	hr_utility.set_location('l_cnt_app_oth_final '||l_cnt_app_oth_final,3170);
	hr_utility.set_location('l_cnt_app_oth '||l_cnt_app_oth,3170);

		l_cnt_app_mgr_final := l_cnt_app_mgr_final + ROUND(l_cnt_app_mgr/l_number_of_periods);
		l_cnt_app_clk_final := l_cnt_app_clk_final + ROUND(l_cnt_app_clk/l_number_of_periods);
		l_cnt_app_oth_final := l_cnt_app_oth_final + ROUND(l_cnt_app_oth/l_number_of_periods);

	hr_utility.set_location('Inside IF l_number_of_periods > 0 after ',3170);
	hr_utility.set_location('l_cnt_app_mgr_final '||l_cnt_app_mgr_final,3170);
	hr_utility.set_location('l_cnt_app_clk_final '||l_cnt_app_clk_final,3170);
	hr_utility.set_location('l_cnt_app_oth_final '||l_cnt_app_oth_final,3170);
	END IF;

END LOOP;


hr_utility.set_location('l_payroll_action_id. '||TO_CHAR(l_payroll_action_id),3180);
hr_utility.set_location('Before Inserting IE_EHECS_PART1 ',3190);

    pay_action_information_api.create_action_information
    ( p_action_information_id => l_action_info_id
    ,p_action_context_id => l_payroll_action_id
    ,p_action_context_type => 'PA'
    ,p_object_version_number => l_ovn
    ,p_effective_date => g_archive_effective_date --g_end_date
    ,p_source_id => NULL
    ,p_source_text => NULL
    ,p_action_information_category => 'IE_EHECS_PART1'
    ,p_action_information1 =>  l_fst_ft_mg
    ,p_action_information2 =>  l_fst_ft_cl
    ,p_action_information3 =>  l_fst_ft_ot
    ,p_action_information4 =>  l_lst_ft_mg
    ,p_action_information5 =>  l_lst_ft_cl
    ,p_action_information6  => l_lst_ft_ot
    ,p_action_information7  => l_hire_ft_mg
    ,p_action_information8  => l_hire_ft_cl
    ,p_action_information9  => l_hire_ft_ot
    ,p_action_information10 => l_fst_pt_mg
    ,p_action_information11 => l_fst_pt_cl
    ,p_action_information12 => l_fst_pt_ot
    ,p_action_information13 => l_lst_pt_mg
    ,p_action_information14 => l_lst_pt_cl
    ,p_action_information15 => l_lst_pt_ot
    ,p_action_information16 => l_hire_pt_mg
    ,p_action_information17 => l_hire_pt_cl
    ,p_action_information18 => l_hire_pt_ot
    ,p_action_information19 => l_cnt_app_mgr_final
    ,p_action_information20 => l_cnt_app_clk_final
    ,p_action_information21 => l_cnt_app_oth_final
    ,p_action_information22 => l_csr_ehecs_eit.avg_mgr_not_pyrl
    ,p_action_information23 => l_csr_ehecs_eit.avg_clk_not_pyrl
    ,p_action_information24 => l_csr_ehecs_eit.avg_prod_not_pyrl
    ,p_action_information25 => l_csr_ehecs_eit.Job_Vac_Mgr
    ,p_action_information26 => l_csr_ehecs_eit.Job_Vac_clk
    ,p_action_information27 => l_csr_ehecs_eit.Job_Vac_prod
    ,p_action_information28 => NVL(l_tab_get_override_totals('M').l_sum_nmw,l_tab_get_totals('M').nmw_pt_ft_mg_cl_ot)
    ,p_action_information29 => NVL(l_tab_get_override_totals('C').l_sum_nmw,l_tab_get_totals('C').nmw_pt_ft_mg_cl_ot)
    ,p_action_information30 => NVL(l_tab_get_override_totals('P').l_sum_nmw,l_tab_get_totals('P').nmw_pt_ft_mg_cl_ot)
    );


hr_utility.set_location('After Inserting IE_EHECS_PART1 ',3200);

l_appwgmg :=   NVL(l_tab_get_override_totals('M').l_sum_regwg_at,NVL(l_tab_get_totals('M').regwg_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('M').l_sum_ovrt_at,NVL(l_tab_get_totals('M').ovrt_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('M').l_sum_irrb_at,NVL(l_tab_get_totals('M').irrb_at_mg_cl_ot,0));

l_appwgcl :=   NVL(l_tab_get_override_totals('C').l_sum_regwg_at,NVL(l_tab_get_totals('C').regwg_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('C').l_sum_ovrt_at,NVL(l_tab_get_totals('C').ovrt_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('C').l_sum_irrb_at,NVL(l_tab_get_totals('C').irrb_at_mg_cl_ot,0));

l_appwgot :=   NVL(l_tab_get_override_totals('P').l_sum_regwg_at,NVL(l_tab_get_totals('P').regwg_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('P').l_sum_ovrt_at,NVL(l_tab_get_totals('P').ovrt_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('P').l_sum_irrb_at,NVL(l_tab_get_totals('P').irrb_at_mg_cl_ot,0));

hr_utility.set_location('Before Inserting IE_EHECS_PART2 ',3210);

    pay_action_information_api.create_action_information
    ( p_action_information_id => l_action_info_id
    ,p_action_context_id => l_payroll_action_id
    ,p_action_context_type => 'PA'
    ,p_object_version_number => l_ovn
    ,p_effective_date => g_archive_effective_date  --g_end_date
    ,p_source_id => NULL
    ,p_source_text => NULL
    ,p_action_information_category => 'IE_EHECS_PART2'
    ,p_action_information1 => NVL(l_tab_get_override_totals('M').l_sum_regwg_ft,NVL(l_tab_get_totals('M').regwg_ft_mg_cl_ot,0))
    ,p_action_information2 => NVL(l_tab_get_override_totals('C').l_sum_regwg_ft,NVL(l_tab_get_totals('C').regwg_ft_mg_cl_ot,0))
    ,p_action_information3 => NVL(l_tab_get_override_totals('P').l_sum_regwg_ft,NVL(l_tab_get_totals('P').regwg_ft_mg_cl_ot,0))
    ,p_action_information4 => NVL(l_tab_get_override_totals('M').l_sum_ovrt_ft,NVL(l_tab_get_totals('M').ovrt_ft_mg_cl_ot,0))
    ,p_action_information5 => NVL(l_tab_get_override_totals('C').l_sum_ovrt_ft,NVL(l_tab_get_totals('C').ovrt_ft_mg_cl_ot,0))
    ,p_action_information6  => NVL(l_tab_get_override_totals('P').l_sum_ovrt_ft,NVL(l_tab_get_totals('P').ovrt_ft_mg_cl_ot,0))
    ,p_action_information7  => NVL(l_tab_get_override_totals('M').l_sum_irrb_ft,NVL(l_tab_get_totals('M').irrb_ft_mg_cl_ot,0))
    ,p_action_information8  => NVL(l_tab_get_override_totals('C').l_sum_irrb_ft,NVL(l_tab_get_totals('C').irrb_ft_mg_cl_ot,0))
    ,p_action_information9  => NVL(l_tab_get_override_totals('P').l_sum_irrb_ft,NVL(l_tab_get_totals('P').irrb_ft_mg_cl_ot,0))
    ,p_action_information10 => NVL(l_tab_get_override_totals('M').l_sum_regwg_pt,NVL(l_tab_get_totals('M').regwg_pt_mg_cl_ot,0))
    ,p_action_information11 => NVL(l_tab_get_override_totals('C').l_sum_regwg_pt,NVL(l_tab_get_totals('C').regwg_pt_mg_cl_ot,0))
    ,p_action_information12 => NVL(l_tab_get_override_totals('P').l_sum_regwg_pt,NVL(l_tab_get_totals('P').regwg_pt_mg_cl_ot,0))
    ,p_action_information13 => NVL(l_tab_get_override_totals('M').l_sum_ovrt_pt,NVL(l_tab_get_totals('M').ovrt_pt_mg_cl_ot,0))
    ,p_action_information14 => NVL(l_tab_get_override_totals('C').l_sum_ovrt_pt,NVL(l_tab_get_totals('C').ovrt_pt_mg_cl_ot,0))
    ,p_action_information15 => NVL(l_tab_get_override_totals('P').l_sum_ovrt_pt,NVL(l_tab_get_totals('P').ovrt_pt_mg_cl_ot,0))
    ,p_action_information16 => NVL(l_tab_get_override_totals('M').l_sum_irrb_pt,NVL(l_tab_get_totals('M').irrb_pt_mg_cl_ot,0))
    ,p_action_information17 => NVL(l_tab_get_override_totals('C').l_sum_irrb_pt,NVL(l_tab_get_totals('C').irrb_pt_mg_cl_ot,0))
    ,p_action_information18 => NVL(l_tab_get_override_totals('P').l_sum_irrb_pt,NVL(l_tab_get_totals('P').irrb_pt_mg_cl_ot,0))
    ,p_action_information19 => l_appwgmg
    ,p_action_information20 => l_appwgcl
    ,p_action_information21 => l_appwgot
    );

hr_utility.set_location('After Inserting IE_EHECS_PART2 ',3220);

    pay_action_information_api.create_action_information
    ( p_action_information_id => l_action_info_id
    ,p_action_context_id => l_payroll_action_id
    ,p_action_context_type => 'PA'
    ,p_object_version_number => l_ovn
    ,p_effective_date => g_archive_effective_date --g_end_date
    ,p_source_id => NULL
    ,p_source_text => NULL
    ,p_action_information_category => 'IE_EHECS_PART3'
    ,p_action_information1  => NVL(l_tab_get_override_totals('M').l_sum_chrs_ft,NVL(l_tab_get_totals('M').chrs_ft_mg_cl_ot,0))
    ,p_action_information2  => NVL(l_tab_get_override_totals('C').l_sum_chrs_ft,NVL(l_tab_get_totals('C').chrs_ft_mg_cl_ot,0))
    ,p_action_information3  => NVL(l_tab_get_override_totals('P').l_sum_chrs_ft,NVL(l_tab_get_totals('P').chrs_ft_mg_cl_ot,0))
    ,p_action_information4  => NVL(l_tab_get_override_totals('M').l_sum_othr_ft,NVL(l_tab_get_totals('M').othr_ft_mg_cl_ot,0))
    ,p_action_information5  => NVL(l_tab_get_override_totals('C').l_sum_othr_ft,NVL(l_tab_get_totals('C').othr_ft_mg_cl_ot,0))
    ,p_action_information6  => NVL(l_tab_get_override_totals('P').l_sum_othr_ft,NVL(l_tab_get_totals('P').othr_ft_mg_cl_ot,0))
    ,p_action_information7  => NVL(l_tab_get_override_totals('M').l_sum_chrs_pt,NVL(l_tab_get_totals('M').chrs_pt_mg_cl_ot,0))
    ,p_action_information8  => NVL(l_tab_get_override_totals('C').l_sum_chrs_pt,NVL(l_tab_get_totals('C').chrs_pt_mg_cl_ot,0))
    ,p_action_information9  => NVL(l_tab_get_override_totals('P').l_sum_chrs_pt,NVL(l_tab_get_totals('P').chrs_pt_mg_cl_ot,0))
    ,p_action_information10 => NVL(l_tab_get_override_totals('M').l_sum_othr_pt,NVL(l_tab_get_totals('M').othr_pt_mg_cl_ot,0))
    ,p_action_information11 => NVL(l_tab_get_override_totals('C').l_sum_othr_pt,NVL(l_tab_get_totals('C').othr_pt_mg_cl_ot,0))
    ,p_action_information12 => NVL(l_tab_get_override_totals('P').l_sum_othr_pt,NVL(l_tab_get_totals('P').othr_pt_mg_cl_ot,0))
    ,p_action_information13 => NVL(l_tab_get_override_totals('M').l_sum_chrs_at,NVL(l_tab_get_totals('M').chrs_at_mg_cl_ot,0))
    ,p_action_information14 => NVL(l_tab_get_override_totals('C').l_sum_chrs_at,NVL(l_tab_get_totals('C').chrs_at_mg_cl_ot,0))
    ,p_action_information15 => NVL(l_tab_get_override_totals('P').l_sum_chrs_at,NVL(l_tab_get_totals('P').chrs_at_mg_cl_ot,0))
    ,p_action_information16 => NVL(l_tab_get_override_totals('M').l_sum_othr_at,NVL(l_tab_get_totals('M').othr_at_mg_cl_ot,0))
    ,p_action_information17 => NVL(l_tab_get_override_totals('C').l_sum_othr_at,NVL(l_tab_get_totals('C').othr_at_mg_cl_ot,0))
    ,p_action_information18 => NVL(l_tab_get_override_totals('P').l_sum_othr_at,NVL(l_tab_get_totals('P').othr_at_mg_cl_ot,0))
    );

hr_utility.set_location('After Inserting IE_EHECS_PART3 ',3230);

/* 6856473 */
hr_utility.set_location(' l_tab_get_totals:M.al_at_mg_cl_ot  ' || l_tab_get_totals('M').al_at_mg_cl_ot,3230);
hr_utility.set_location(' l_tab_get_totals:C.al_at_mg_cl_ot  ' || l_tab_get_totals('C').al_at_mg_cl_ot,3230);
hr_utility.set_location(' l_tab_get_totals:P.al_at_mg_cl_ot  ' || l_tab_get_totals('P').al_at_mg_cl_ot,3230);


l_lapmg :=   NVL(l_tab_get_override_totals('M').l_sum_al_at,NVL(l_tab_get_totals('M').al_at_mg_cl_ot,0))  -- 6856473
	     + NVL(l_tab_get_override_totals('M').l_sum_mat_at,NVL(l_tab_get_totals('M').mat_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('M').l_sum_sic_at,NVL(l_tab_get_totals('M').sic_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('M').l_sum_otl_at,NVL(l_tab_get_totals('M').otl_at_mg_cl_ot,0));

l_lapcl :=   NVL(l_tab_get_override_totals('C').l_sum_al_at,NVL(l_tab_get_totals('C').al_at_mg_cl_ot,0)) -- 6856473
	     + NVL(l_tab_get_override_totals('C').l_sum_mat_at,NVL(l_tab_get_totals('C').mat_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('C').l_sum_sic_at,NVL(l_tab_get_totals('C').sic_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('C').l_sum_otl_at,NVL(l_tab_get_totals('C').otl_at_mg_cl_ot,0));

l_lapot :=   NVL(l_tab_get_override_totals('P').l_sum_al_at,NVL(l_tab_get_totals('P').al_at_mg_cl_ot,0)) -- 6856473
	     + NVL(l_tab_get_override_totals('P').l_sum_mat_at,NVL(l_tab_get_totals('P').mat_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('P').l_sum_sic_at,NVL(l_tab_get_totals('P').sic_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('P').l_sum_otl_at,NVL(l_tab_get_totals('P').otl_at_mg_cl_ot,0));

hr_utility.set_location('Before Inserting IE_EHECS_PART4 ',3240);

/* 6856473 */
hr_utility.set_location(' l_tab_get_totals:M.al_ft_mg_cl_ot  ' || l_tab_get_totals('M').al_ft_mg_cl_ot,3230);
hr_utility.set_location(' l_tab_get_totals:C.al_ft_mg_cl_ot  ' || l_tab_get_totals('C').al_ft_mg_cl_ot,3230);
hr_utility.set_location(' l_tab_get_totals:P.al_ft_mg_cl_ot  ' || l_tab_get_totals('P').al_ft_mg_cl_ot,3230);


hr_utility.set_location(' l_tab_get_totals:M.al_pt_mg_cl_ot  ' || l_tab_get_totals('M').al_pt_mg_cl_ot,3230);
hr_utility.set_location(' l_tab_get_totals:C.al_pt_mg_cl_ot  ' || l_tab_get_totals('C').al_pt_mg_cl_ot,3230);
hr_utility.set_location(' l_tab_get_totals:Pal_pt_mg_cl_ot  ' || l_tab_get_totals('P').al_pt_mg_cl_ot,3230);
    pay_action_information_api.create_action_information
    ( p_action_information_id => l_action_info_id
    ,p_action_context_id => l_payroll_action_id
    ,p_action_context_type => 'PA'
    ,p_object_version_number => l_ovn
    ,p_effective_date => g_archive_effective_date --g_end_date
    ,p_source_id => NULL
    ,p_source_text => NULL
    ,p_action_information_category => 'IE_EHECS_PART4'
    ,p_action_information1  => NVL(l_tab_get_override_totals('M').l_sum_al_ft,NVL(l_tab_get_totals('M').al_ft_mg_cl_ot,0)) -- 6856473
    ,p_action_information2  => NVL(l_tab_get_override_totals('C').l_sum_al_ft,NVL(l_tab_get_totals('C').al_ft_mg_cl_ot,0)) -- 6856473
    ,p_action_information3  => NVL(l_tab_get_override_totals('P').l_sum_al_ft,NVL(l_tab_get_totals('P').al_ft_mg_cl_ot,0)) -- 6856473
    ,p_action_information4  => NVL(l_tab_get_override_totals('M').l_sum_mat_ft,NVL(l_tab_get_totals('M').mat_ft_mg_cl_ot,0))
    ,p_action_information5  => NVL(l_tab_get_override_totals('C').l_sum_mat_ft,NVL(l_tab_get_totals('C').mat_ft_mg_cl_ot,0))
    ,p_action_information6  => NVL(l_tab_get_override_totals('P').l_sum_mat_ft,NVL(l_tab_get_totals('P').mat_ft_mg_cl_ot,0))
    ,p_action_information7  => NVL(l_tab_get_override_totals('M').l_sum_sic_ft,NVL(l_tab_get_totals('M').sic_ft_mg_cl_ot,0))
    ,p_action_information8  => NVL(l_tab_get_override_totals('C').l_sum_sic_ft,NVL(l_tab_get_totals('C').sic_ft_mg_cl_ot,0))
    ,p_action_information9  => NVL(l_tab_get_override_totals('P').l_sum_sic_ft,NVL(l_tab_get_totals('P').sic_ft_mg_cl_ot,0))
    ,p_action_information10 => NVL(l_tab_get_override_totals('M').l_sum_otl_ft,NVL(l_tab_get_totals('M').otl_ft_mg_cl_ot,0))
    ,p_action_information11 => NVL(l_tab_get_override_totals('C').l_sum_otl_ft,NVL(l_tab_get_totals('C').otl_ft_mg_cl_ot,0))
    ,p_action_information12 => NVL(l_tab_get_override_totals('P').l_sum_otl_ft,NVL(l_tab_get_totals('P').otl_ft_mg_cl_ot,0))
    ,p_action_information13 => NVL(l_tab_get_override_totals('M').l_sum_al_pt,NVL(l_tab_get_totals('M').al_pt_mg_cl_ot,0)) -- 6856473
    ,p_action_information14 => NVL(l_tab_get_override_totals('C').l_sum_al_pt,NVL(l_tab_get_totals('C').al_pt_mg_cl_ot,0)) -- 6856473
    ,p_action_information15 => NVL(l_tab_get_override_totals('P').l_sum_al_pt,NVL(l_tab_get_totals('P').al_pt_mg_cl_ot,0)) -- 6856473
    ,p_action_information16 => NVL(l_tab_get_override_totals('M').l_sum_mat_pt,NVL(l_tab_get_totals('M').mat_pt_mg_cl_ot,0))
    ,p_action_information17 => NVL(l_tab_get_override_totals('C').l_sum_mat_pt,NVL(l_tab_get_totals('C').mat_pt_mg_cl_ot,0))
    ,p_action_information18 => NVL(l_tab_get_override_totals('P').l_sum_mat_pt,NVL(l_tab_get_totals('P').mat_pt_mg_cl_ot,0))
    ,p_action_information19 => NVL(l_tab_get_override_totals('M').l_sum_sic_pt,NVL(l_tab_get_totals('M').sic_pt_mg_cl_ot,0))
    ,p_action_information20 => NVL(l_tab_get_override_totals('C').l_sum_sic_pt,NVL(l_tab_get_totals('C').sic_pt_mg_cl_ot,0))
    ,p_action_information21 => NVL(l_tab_get_override_totals('P').l_sum_sic_pt,NVL(l_tab_get_totals('P').sic_pt_mg_cl_ot,0))
    ,p_action_information22 => NVL(l_tab_get_override_totals('M').l_sum_otl_pt,NVL(l_tab_get_totals('M').otl_pt_mg_cl_ot,0))
    ,p_action_information23 => NVL(l_tab_get_override_totals('C').l_sum_otl_pt,NVL(l_tab_get_totals('C').otl_pt_mg_cl_ot,0))
    ,p_action_information24 => NVL(l_tab_get_override_totals('P').l_sum_otl_pt,NVL(l_tab_get_totals('P').otl_pt_mg_cl_ot,0))
    ,p_action_information25 => l_lapmg
    ,p_action_information26 => l_lapcl
    ,p_action_information27 => l_lapot
);

hr_utility.set_location('After Inserting IE_EHECS_PART4 ',3250);

l_ssecapmg :=   NVL(l_tab_get_totals('M').prsi_at_mg_cl_ot,0)
	     + NVL(l_tab_get_override_totals('M').l_sum_incc_at,NVL(l_tab_get_totals('M').incct_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('M').l_sum_red_at,NVL(l_tab_get_totals('M').red_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('M').l_sum_otsoc_at,NVL(l_tab_get_totals('M').otsoc_at_mg_cl_ot,0));

l_ssecapcl :=    NVL(l_tab_get_totals('C').prsi_at_mg_cl_ot,0)
	     + NVL(l_tab_get_override_totals('C').l_sum_incc_at,NVL(l_tab_get_totals('C').incct_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('C').l_sum_red_at,NVL(l_tab_get_totals('C').red_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('C').l_sum_otsoc_at,NVL(l_tab_get_totals('C').otsoc_at_mg_cl_ot,0));

l_ssecapot :=   NVL(l_tab_get_totals('P').prsi_at_mg_cl_ot,0)
	     + NVL(l_tab_get_override_totals('P').l_sum_incc_at,NVL(l_tab_get_totals('P').incct_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('P').l_sum_red_at,NVL(l_tab_get_totals('P').red_at_mg_cl_ot,0))
	     + NVL(l_tab_get_override_totals('P').l_sum_otsoc_at,NVL(l_tab_get_totals('P').otsoc_at_mg_cl_ot,0));

hr_utility.set_location('Before Inserting IE_EHECS_PART7 ',3260);

    pay_action_information_api.create_action_information
    ( p_action_information_id => l_action_info_id
    ,p_action_context_id => l_payroll_action_id
    ,p_action_context_type => 'PA'
    ,p_object_version_number => l_ovn
    ,p_effective_date => g_archive_effective_date --g_end_date
    ,p_source_id => NULL
    ,p_source_text => NULL
    ,p_action_information_category => 'IE_EHECS_PART7'
    ,p_action_information1 => NVL(l_tab_get_totals('M').prsi_pt_ft_mg_cl_ot,0)
    ,p_action_information2 => NVL(l_tab_get_totals('C').prsi_pt_ft_mg_cl_ot,0)
    ,p_action_information3 => NVL(l_tab_get_totals('P').prsi_pt_ft_mg_cl_ot,0)
    ,p_action_information4 => NVL(l_tab_get_override_totals('M').l_sum_incc_pt_ft,NVL(l_tab_get_totals('M').incct_pt_ft_mg_cl_ot,0))
    ,p_action_information5 => NVL(l_tab_get_override_totals('C').l_sum_incc_pt_ft,NVL(l_tab_get_totals('C').incct_pt_ft_mg_cl_ot,0))
    ,p_action_information6  => NVL(l_tab_get_override_totals('P').l_sum_incc_pt_ft,NVL(l_tab_get_totals('P').incct_pt_ft_mg_cl_ot,0))
    ,p_action_information7  => NVL(l_tab_get_override_totals('M').l_sum_red_pt_ft,NVL(l_tab_get_totals('M').red_pt_ft_mg_cl_ot,0))
    ,p_action_information8  => NVL(l_tab_get_override_totals('C').l_sum_red_pt_ft,NVL(l_tab_get_totals('C').red_pt_ft_mg_cl_ot,0))
    ,p_action_information9  => NVL(l_tab_get_override_totals('P').l_sum_red_pt_ft,NVL(l_tab_get_totals('P').red_pt_ft_mg_cl_ot,0))
    ,p_action_information10 => NVL(l_tab_get_override_totals('M').l_sum_otsoc_pt_ft,NVL(l_tab_get_totals('M').otsoc_pt_ft_mg_cl_ot,0))
    ,p_action_information11 => NVL(l_tab_get_override_totals('C').l_sum_otsoc_pt_ft,NVL(l_tab_get_totals('C').otsoc_pt_ft_mg_cl_ot,0))
    ,p_action_information12 => NVL(l_tab_get_override_totals('P').l_sum_otsoc_pt_ft,NVL(l_tab_get_totals('P').otsoc_pt_ft_mg_cl_ot,0))
    ,p_action_information13 => l_ssecapmg
    ,p_action_information14 => l_ssecapcl
    ,p_action_information15 => l_ssecapot
    );

hr_utility.set_location('After Inserting IE_EHECS_PART7 ',3270);

    pay_action_information_api.create_action_information
    ( p_action_information_id => l_action_info_id
    ,p_action_context_id => l_payroll_action_id
    ,p_action_context_type => 'PA'
    ,p_object_version_number => l_ovn
    ,p_effective_date => g_archive_effective_date --g_end_date
    ,p_source_id => NULL
    ,p_source_text => NULL
    ,p_action_information_category => 'IE_EHECS_PART8'
    ,p_action_information1 => NVL(l_tab_get_totals('M').car_pt_ft_mg_cl_ot,0)
    ,p_action_information2 => NVL(l_tab_get_totals('C').car_pt_ft_mg_cl_ot,0)
    ,p_action_information3 => NVL(l_tab_get_totals('P').car_pt_ft_mg_cl_ot,0)
    ,p_action_information4 => NVL(l_tab_get_override_totals('M').l_sum_stks_pt_ft,NVL(l_tab_get_totals('M').stks_pt_ft_mg_cl_ot,0))
    ,p_action_information5 => NVL(l_tab_get_override_totals('C').l_sum_stks_pt_ft,NVL(l_tab_get_totals('C').stks_pt_ft_mg_cl_ot,0))
    ,p_action_information6  => NVL(l_tab_get_override_totals('P').l_sum_stks_pt_ft,NVL(l_tab_get_totals('P').stks_pt_ft_mg_cl_ot,0))
    ,p_action_information7  => NVL(l_tab_get_override_totals('M').l_sum_vhi_pt_ft,NVL(l_tab_get_totals('M').vhi_pt_ft_mg_cl_ot,0))
    ,p_action_information8  => NVL(l_tab_get_override_totals('C').l_sum_vhi_pt_ft,NVL(l_tab_get_totals('C').vhi_pt_ft_mg_cl_ot,0))
    ,p_action_information9  => NVL(l_tab_get_override_totals('P').l_sum_vhi_pt_ft,NVL(l_tab_get_totals('P').vhi_pt_ft_mg_cl_ot,0))
    ,p_action_information10 => NVL(l_tab_get_override_totals('M').l_sum_hse_pt_ft,NVL(l_tab_get_totals('M').hse_pt_ft_mg_cl_ot,0))
    ,p_action_information11 => NVL(l_tab_get_override_totals('C').l_sum_hse_pt_ft,NVL(l_tab_get_totals('C').hse_pt_ft_mg_cl_ot,0))
    ,p_action_information12 => NVL(l_tab_get_override_totals('P').l_sum_hse_pt_ft,NVL(l_tab_get_totals('P').hse_pt_ft_mg_cl_ot,0))
    ,p_action_information13 => NVL(l_tab_get_override_totals('M').l_sum_otben_ft,NVL(l_tab_get_totals('M').otben_pt_ft_mg_cl_ot,0))
    ,p_action_information14 => NVL(l_tab_get_override_totals('C').l_sum_otben_ft,NVL(l_tab_get_totals('C').otben_pt_ft_mg_cl_ot,0))
    ,p_action_information15 => NVL(l_tab_get_override_totals('P').l_sum_otben_ft,NVL(l_tab_get_totals('P').otben_pt_ft_mg_cl_ot,0))
    );

hr_utility.set_location('After Inserting IE_EHECS_PART8 ',3270);

    pay_action_information_api.create_action_information
    ( p_action_information_id => l_action_info_id
    ,p_action_context_id => l_payroll_action_id
    ,p_action_context_type => 'PA'
    ,p_object_version_number => l_ovn
    ,p_effective_date => g_archive_effective_date --g_end_date
    ,p_source_id => NULL
    ,p_source_text => NULL
    ,p_action_information_category => 'IE_EHECS_ALL_OTHER'
    ,p_action_information1  => NVL(l_tab_get_totals('M').pen_pt_ft_at_mg_cl_ot,0)
    ,p_action_information2  => NVL(l_tab_get_totals('C').pen_pt_ft_at_mg_cl_ot,0)
    ,p_action_information3  => NVL(l_tab_get_totals('P').pen_pt_ft_at_mg_cl_ot,0)
    ,p_action_information4  => l_csr_ehecs_eit.Tot_empr_Lblt_Ins
    ,p_action_information5  => l_csr_ehecs_eit.Trng_cost
    ,p_action_information6  => l_csr_ehecs_eit.Lbr_Expdtr		  --using index M below as all indexes wud hv same value
    ,p_action_information7  => NVL(l_csr_ehecs_eit.Trng_subsidy,NVL(l_tab_get_totals('M').trsub_all,0))
    ,p_action_information8  => NVL(l_csr_ehecs_eit.otr_subsidy,NVL(l_tab_get_totals('M').otsub_all,0))
    ,p_action_information9  => NVL(l_csr_ehecs_eit.refunds,NVL(l_tab_get_totals('M').rfund_all,0))
    ,p_action_information10 => NULL	-- not used
    ,p_action_information11 => NULL -- not used
    ,p_action_information12 => NULL -- not used
    );
hr_utility.set_location('After Inserting IE_EHECS_ALL_OTHER ',3280);

OPEN c_get_part1(l_payroll_action_id);
FETCH c_get_part1 INTO l_data_part1;
CLOSE c_get_part1;
hr_utility.set_location('After c_get_part1',3281);
OPEN c_get_part2(l_payroll_action_id);
FETCH c_get_part2 INTO l_data_part2;
CLOSE c_get_part2;

hr_utility.set_location('After c_get_part2',3281);
OPEN c_get_part3(l_payroll_action_id);
FETCH c_get_part3 INTO l_data_part3;
CLOSE c_get_part3;

hr_utility.set_location('After c_get_part3',3281);
OPEN c_get_part4(l_payroll_action_id);
FETCH c_get_part4 INTO l_data_part4;
CLOSE c_get_part4;

hr_utility.set_location('After c_get_part4',3281);
OPEN c_get_part7(l_payroll_action_id);
FETCH c_get_part7 INTO l_data_part7;
CLOSE c_get_part7;

hr_utility.set_location('After c_get_part7',3281);
OPEN c_get_part8(l_payroll_action_id);
FETCH c_get_part8 INTO l_data_part8;
CLOSE c_get_part8;

hr_utility.set_location('After c_get_part8',3281);
OPEN  c_get_part_all_other(l_payroll_action_id);
FETCH c_get_part_all_other INTO l_data_part_all_other;
CLOSE c_get_part_all_other;

hr_utility.set_location('After c_get_partall ote',3281);

hr_utility.set_location('After Fetching ALL Cursors.',3280);

--for l_data_part1 in c_get_part1(l_payroll_action_id)
--loop

l_errflag := 'N';
l_is_gt_0 := ' is greater than 0.';

-------------------Section A: Full time and part time managers, professionals and associate professionals:
l_employee_categories := 'managers, professionals and associate professionals';

IF l_data_part1.l_fst_ft_mg >0 OR l_data_part1.l_lst_ft_mg > 0 THEN
l_str_common := 'An entry exists for full time ' || l_employee_categories ||' employed at the first day of the quarter or the last day of the quarter.';
   --
   IF l_data_part2.l_reg_wg_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories || l_is_gt_0);
     --||' must be > 0 '||l_str_common);
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories || l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories || l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --

END IF;


IF l_data_part2.l_reg_wg_ft_mg > 0 THEN
l_str_common := 'An entry exists for regular wages and salaries for full time '|| l_employee_categories;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories || l_is_gt_0 );

   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories || l_is_gt_0 );

   END IF;

END IF;

IF l_data_part2.l_irr_bonus_ft_mg > 0 THEN
l_str_common := 'An entry exists for irregular bonuses and allowances for full time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;
--
IF l_data_part2.l_ot_paid_ft_mg > 0 THEN
l_str_common := 'An entry exists for overtime for full time '|| l_employee_categories ;
   --
   IF l_data_part2.l_reg_wg_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_ot_hrs_paid_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid overtime hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;
--
IF l_data_part3.l_contracted_hrs_paid_ft_mg > 0 THEN
l_str_common := 'An entry exists for contracted hours for full time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;
--

IF l_data_part3.l_ot_hrs_paid_ft_mg > 0 THEN
l_str_common := 'An entry exists for overtime hours for full time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part2.l_ot_paid_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Overtime - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF (l_data_part4.l_ann_leave_ft_mg >0 OR l_data_part4.l_mat_leave_ft_mg > 0 OR
    l_data_part4.l_sck_leave_ft_mg >0 OR l_data_part4.l_other_leave_ft_mg >0 ) THEN
l_str_common := 'An entry exists for Annual Leave and Bank Holidays or Maternity Leave or Sick Leave or Other Leave- full time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF (l_data_part1.l_fst_pt_mg >0 OR l_data_part1.l_lst_pt_mg > 0 ) THEN
l_str_common := 'An entry exists for part time '|| l_employee_categories||' employed at '
||' the first day of the quarter or the last day of the quarter.';
   --
   IF l_data_part2.l_reg_wg_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
    --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF l_data_part2.l_reg_wg_pt_mg > 0 THEN
l_str_common := 'An entry exists for regular wages and salaries for part time '|| l_employee_categories;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF l_data_part2.l_irr_bonus_pt_mg > 0 THEN
l_str_common := 'An entry exists for irregular bonuses and allowances for part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF l_data_part2.l_ot_paid_pt_mg > 0 THEN
l_str_common := 'An entry exists for overtime for part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_ot_hrs_paid_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid overtime hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

IF l_data_part3.l_contracted_hrs_paid_pt_mg > 0 THEN
l_str_common := 'An entry exists for paid contracted hours for part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

IF l_data_part3.l_ot_hrs_paid_pt_mg > 0 THEN
l_str_common := 'An entry exists for overtime hours for part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

IF l_data_part_all_other.l_employer_pension_mg > 0 THEN
l_str_common := ' An entry exists for Employers contributions to pension funds for '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_mg = 0 AND l_data_part2.l_reg_wg_pt_mg = 0 AND l_data_part2.l_tot_wg_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries for any one of them - full time / part time / apprentice/trainee '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_mg = 0 AND l_data_part3.l_contracted_hrs_paid_pt_mg = 0 AND l_data_part3.l_contracted_hrs_paid_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours for any one of them - full time / part time / apprentice/trainee '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_mg = 0 AND l_data_part4.l_ann_leave_pt_mg = 0 AND l_data_part4.l_all_paid_leave_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays for any one of them - full time / part time / apprentice/trainee '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

IF ( l_data_part7.l_employer_prsi_mg > 0 OR l_data_part7.l_continuance_income_mg > 0 OR
     l_data_part7.l_redundacny_paid_mg > 0 OR l_data_part7.l_other_paid_mg > 0 ) THEN
l_str_common := 'An entry exists for Social Security Contributions for full time and part time '|| l_employee_categories||' employees.';

   IF l_data_part2.l_reg_wg_ft_mg = 0 AND l_data_part2.l_reg_wg_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_mg = 0 AND l_data_part3.l_contracted_hrs_paid_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_mg = 0 AND l_data_part4.l_ann_leave_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END If;

IF (l_data_part8.l_company_car_mg > 0 OR l_data_part8.l_stock_options_mg > 0 OR
    l_data_part8.l_vol_sick_insurance_mg > 0 OR l_data_part8.l_staff_housing_mg > 0 OR
    l_data_part8.l_other_benefits_mg > 0 ) THEN
l_str_common := ' An entry exists for Other Benefits to Employees - full time and part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_mg = 0 AND l_data_part2.l_reg_wg_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_mg = 0 AND l_data_part3.l_contracted_hrs_paid_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_mg = 0 AND l_data_part4.l_ann_leave_pt_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;
----------------Section B: Full and part time clerical, sales and service workers:
l_employee_categories := 'clerical, sales and service workers';

IF l_data_part1.l_fst_ft_cl >0 OR l_data_part1.l_lst_ft_cl > 0 THEN
l_str_common := 'as full time ' || l_employee_categories ||' employed at the first day of the quarter or the last day of the quarter exists ';
   --
   IF l_data_part2.l_reg_wg_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --

END IF;

IF l_data_part2.l_reg_wg_ft_cl > 0 THEN
l_str_common := 'An entry exists for regular wages and salaries for full time '|| l_employee_categories;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --

END IF;

IF l_data_part2.l_irr_bonus_ft_cl > 0 THEN
l_str_common := 'An entry exists for irregular bonuses and allowances for full time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;
--
IF l_data_part2.l_ot_paid_ft_cl > 0 THEN
l_str_common := 'An entry exists for overtime for full time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_ot_hrs_paid_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid overtime hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;
--
IF l_data_part3.l_contracted_hrs_paid_ft_cl > 0 THEN
l_str_common := 'An entry exists for contracted hours for full time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;
--

IF l_data_part3.l_ot_hrs_paid_ft_cl > 0 THEN
l_str_common := 'An entry exists for overtime hours for full time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part2.l_ot_paid_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Overtime - full time '|| l_employee_categories|| l_is_gt_0 );
    -- ||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF (l_data_part4.l_ann_leave_ft_cl >0 OR l_data_part4.l_mat_leave_ft_cl > 0 OR
    l_data_part4.l_sck_leave_ft_cl >0 OR l_data_part4.l_other_leave_ft_cl >0 ) THEN
l_str_common := 'An entry exists for Annual Leave and Bank Holidays or Maternity Leave or Sick Leave or Other Leave- full time '|| l_employee_categories;

   --
   IF l_data_part2.l_reg_wg_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF (l_data_part1.l_fst_pt_cl >0 OR l_data_part1.l_lst_pt_cl > 0 ) THEN
l_str_common := 'An entry exists for part time '|| l_employee_categories ||' employed at '
||' the first day of the quarter or the last day of the quarter.';
   --
   IF l_data_part2.l_reg_wg_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF l_data_part2.l_reg_wg_pt_cl > 0 THEN
l_str_common := 'An entry exists for regular wages and salaries for part time '|| l_employee_categories;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF l_data_part2.l_irr_bonus_pt_cl > 0 THEN
l_str_common := 'An entry exists for irregular bonuses and allowances for part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF l_data_part2.l_ot_paid_pt_cl > 0 THEN
l_str_common := 'An entry exists for overtime for part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_ot_hrs_paid_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid overtime hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

IF l_data_part3.l_contracted_hrs_paid_pt_cl > 0 THEN
l_str_common := 'An entry exists for paid contracted hours for part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

IF l_data_part3.l_ot_hrs_paid_pt_cl > 0 THEN
l_str_common := 'An entry exists for overtime hours for part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

IF l_data_part_all_other.l_employer_pension_cl > 0 THEN
l_str_common := ' An entry exists for Employers contributions to pension funds for '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_cl = 0 AND l_data_part2.l_reg_wg_pt_cl = 0 AND l_data_part2.l_tot_wg_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries for any one of them - full time / part time / apprentice/trainee '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_cl = 0 AND l_data_part3.l_contracted_hrs_paid_pt_cl = 0 AND l_data_part3.l_contracted_hrs_paid_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours for any one of them - full time / part time / apprentice/trainee '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_cl = 0 AND l_data_part4.l_ann_leave_pt_cl = 0 AND l_data_part4.l_all_paid_leave_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays for any one of them - full time / part time / apprentice/trainee '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

IF ( l_data_part7.l_employer_prsi_cl > 0 OR l_data_part7.l_continuance_income_cl > 0 OR
     l_data_part7.l_redundacny_paid_cl > 0 OR l_data_part7.l_other_paid_cl > 0 ) THEN
l_str_common := 'An entry exists for Social Security Contributions for full time and part time '|| l_employee_categories||' employees.';

   IF l_data_part2.l_reg_wg_ft_cl = 0 AND l_data_part2.l_reg_wg_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_cl = 0 AND l_data_part3.l_contracted_hrs_paid_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_cl = 0 AND l_data_part4.l_ann_leave_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END If;

IF (l_data_part8.l_company_car_cl > 0 OR l_data_part8.l_stock_options_cl > 0 OR
    l_data_part8.l_vol_sick_insurance_cl > 0 OR l_data_part8.l_staff_housing_cl > 0 OR
    l_data_part8.l_other_benefits_cl > 0 ) THEN
l_str_common := 'An entry exists for Other Benefits to Employees - full time and part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_cl = 0 AND l_data_part2.l_reg_wg_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_cl = 0 AND l_data_part3.l_contracted_hrs_paid_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_cl = 0 AND l_data_part4.l_ann_leave_pt_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

----------------Section C: Full and part time production, transport, craft, tradespersons and other manual workers:
l_employee_categories := 'production, transport, craft, tradespersons and other manual workers';

IF l_data_part1.l_fst_ft_ot >0 OR l_data_part1.l_lst_ft_ot > 0 THEN
l_str_common := 'An entry exists for full time ' || l_employee_categories ||' employed at the first day of the quarter or the last day of the quarter.';
   --
   IF l_data_part2.l_reg_wg_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --
   --
END IF;

IF l_data_part2.l_reg_wg_ft_ot > 0 THEN
l_str_common := 'An entry exists for regular wages and salaries for full time '|| l_employee_categories;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --
   --
END IF;

IF l_data_part2.l_irr_bonus_ft_ot > 0 THEN
l_str_common := 'An entry exists for irregular bonuses and allowances for full time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;
--
IF l_data_part2.l_ot_paid_ft_ot > 0 THEN
l_str_common := 'An entry exists for overtime for full time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_ot_hrs_paid_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid overtime hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;
--
IF l_data_part3.l_contracted_hrs_paid_ft_ot > 0 THEN
l_str_common := 'An entry exists for contracted hours for full time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;
--

IF l_data_part3.l_ot_hrs_paid_ft_ot > 0 THEN
l_str_common := 'An entry exists for overtime hours for full time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part2.l_ot_paid_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Overtime - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF (l_data_part4.l_ann_leave_ft_ot >0 OR l_data_part4.l_mat_leave_ft_ot > 0 OR
    l_data_part4.l_sck_leave_ft_ot >0 OR l_data_part4.l_other_leave_ft_ot >0 ) THEN
l_str_common := 'An entry exists for Annual Leave and Bank Holidays or Maternity Leave or Sick Leave or Other Leave- full time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - full time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF (l_data_part1.l_fst_pt_ot >0 OR l_data_part1.l_lst_pt_ot > 0 ) THEN
l_str_common := 'An entry exists for part time '|| l_employee_categories ||' employed at '
||' the first day of the quarter or the last day of the quarter.';
   --
   IF l_data_part2.l_reg_wg_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF l_data_part2.l_reg_wg_pt_ot > 0 THEN
l_str_common := 'An entry exists for regular wages and salaries for part time '|| l_employee_categories;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF l_data_part2.l_irr_bonus_pt_ot > 0 THEN
l_str_common := 'An entry exists for irregular bonuses and allowances for part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

IF l_data_part2.l_ot_paid_pt_ot > 0 THEN
l_str_common := 'An entry exists for overtime for part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_ot_hrs_paid_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid overtime hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

IF l_data_part3.l_contracted_hrs_paid_pt_ot > 0 THEN
l_str_common := 'An entry exists for paid contracted hours for part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

IF l_data_part3.l_ot_hrs_paid_pt_ot > 0 THEN
l_str_common := 'An entry exists for overtime hours for part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours - part time '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

IF l_data_part_all_other.l_employer_pension_ot > 0 THEN
l_str_common := ' An entry exists for Employers contributions to pension funds for '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_ot = 0 AND l_data_part2.l_reg_wg_pt_ot = 0 AND l_data_part2.l_tot_wg_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries for any one of them - full time / part time / apprentice/trainee '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_ot = 0 AND l_data_part3.l_contracted_hrs_paid_pt_ot = 0 AND l_data_part3.l_contracted_hrs_paid_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours for any one of them - full time / part time / apprentice/trainee '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_ot = 0 AND l_data_part4.l_ann_leave_pt_ot = 0 AND l_data_part4.l_all_paid_leave_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays for any one of them - full time / part time / apprentice/trainee '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

IF ( l_data_part7.l_employer_prsi_ot > 0 OR l_data_part7.l_continuance_income_ot > 0 OR
     l_data_part7.l_redundacny_paid_ot > 0 OR l_data_part7.l_other_paid_ot > 0 ) THEN
l_str_common := ' An entry exists for Social Security Contributions for full time and part time '|| l_employee_categories||' employees ';

   IF l_data_part2.l_reg_wg_ft_ot = 0 AND l_data_part2.l_reg_wg_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_ot = 0 AND l_data_part3.l_contracted_hrs_paid_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_ot = 0 AND l_data_part4.l_ann_leave_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END If;

IF (l_data_part8.l_company_car_ot > 0 OR l_data_part8.l_stock_options_ot > 0 OR
    l_data_part8.l_vol_sick_insurance_ot > 0 OR l_data_part8.l_staff_housing_ot > 0 OR
    l_data_part8.l_other_benefits_ot > 0 ) THEN
l_str_common := 'An entry exists for Other Benefits to Employees - full time and part time '|| l_employee_categories;
   --
   IF l_data_part2.l_reg_wg_ft_ot = 0 AND l_data_part2.l_reg_wg_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Regular wages and salaries for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   --
   IF l_data_part3.l_contracted_hrs_paid_ft_ot = 0 AND l_data_part3.l_contracted_hrs_paid_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_ann_leave_ft_ot = 0 AND l_data_part4.l_ann_leave_pt_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Annual Leave and Bank Holidays for any one of them - full time / part time '|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

----------------Section D: Apprentices/Trainees:
l_employee_categories := 'apprentice/trainee managers, professionals and associate professionals';

IF l_data_part1.l_app_mg >0  THEN
l_str_common := 'An entry exists for the average number of '||l_employee_categories;
   --
   IF l_data_part2.l_tot_wg_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --
END IF;

IF l_data_part2.l_tot_wg_app_mg > 0 THEN
l_str_common := 'An entry exists for total wages and salaries for '|| l_employee_categories;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --
END IF;

IF l_data_part3.l_contracted_hrs_paid_app_mg > 0 THEN
l_str_common := 'An entry exists for paid contracted hours for '|| l_employee_categories;
   --
   IF l_data_part2.l_tot_wg_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

--
IF l_data_part3.l_ot_hrs_paid_app_mg > 0 THEN
l_str_common := 'An entry exists for overtime hours for '|| l_employee_categories ;
   --
   IF l_data_part2.l_tot_wg_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

--
IF l_data_part4.l_all_paid_leave_app_mg > 0 THEN
l_str_common := 'An entry exists for All paid leave for '|| l_employee_categories;
   --
   IF l_data_part2.l_tot_wg_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contract hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;
--

IF l_data_part7.l_ssc_contributions_app_mg > 0 THEN
l_str_common := 'An entry exists for total social security contributions for '|| l_employee_categories;
   --
   IF l_data_part2.l_tot_wg_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_mg = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;
-------------

l_employee_categories := 'apprentice/trainee clerical, sales and service workers';

IF l_data_part1.l_app_cl > 0  THEN
l_str_common := 'An entry exists for the average number of '||l_employee_categories;
   --
   IF l_data_part2.l_tot_wg_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --
END IF;

IF l_data_part2.l_tot_wg_app_cl > 0 THEN
l_str_common := 'An entry exists for total wages and salaries for '|| l_employee_categories;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --
END IF;

IF l_data_part3.l_contracted_hrs_paid_app_cl > 0 THEN
l_str_common := 'An entry exists for paid contracted hours for '|| l_employee_categories;
   --
   IF l_data_part2.l_tot_wg_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

--
IF l_data_part3.l_ot_hrs_paid_app_cl > 0 THEN
l_str_common := 'An entry exists for overtime hours for '|| l_employee_categories ;
   --
   IF l_data_part2.l_tot_wg_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

--
IF l_data_part4.l_all_paid_leave_app_cl > 0 THEN
l_str_common := 'An entry exists for All paid leave for '|| l_employee_categories;
   --
   IF l_data_part2.l_tot_wg_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contract hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;
--

IF l_data_part7.l_ssc_contributions_app_cl > 0 THEN
l_str_common := 'An entry exists for total social security contributions for '|| l_employee_categories;
   --
   IF l_data_part2.l_tot_wg_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_cl = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;
-------------
l_employee_categories := 'apprentice/trainee production, transport, craft, tradespersons and other manual workers';

IF l_data_part1.l_app_ot > 0  THEN
l_str_common := 'An entry exists for the average number of '||l_employee_categories;
   --
   IF l_data_part2.l_tot_wg_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --
END IF;

IF l_data_part2.l_tot_wg_app_ot > 0 THEN
l_str_common := 'An entry exists for total wages and salaries for '|| l_employee_categories;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common);
   END IF;
   --
END IF;

IF l_data_part3.l_contracted_hrs_paid_app_ot > 0 THEN
l_str_common := 'An entry exists for paid contracted hours for '|| l_employee_categories;
   --
   IF l_data_part2.l_tot_wg_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;

--
IF l_data_part3.l_ot_hrs_paid_app_ot > 0 THEN
l_str_common := 'An entry exists for overtime hours for '|| l_employee_categories ;
   --
   IF l_data_part2.l_tot_wg_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;

--
IF l_data_part4.l_all_paid_leave_app_ot > 0 THEN
l_str_common := 'An entry exists for All paid leave for '|| l_employee_categories;
   --
   IF l_data_part2.l_tot_wg_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contract hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
END IF;
--

IF l_data_part7.l_ssc_contributions_app_ot > 0 THEN
l_str_common := 'An entry exists for total social security contributions for '|| l_employee_categories;
   --
   IF l_data_part2.l_tot_wg_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Total wages and salaries '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part3.l_contracted_hrs_paid_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that Paid contracted hours '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
   --
   IF l_data_part4.l_all_paid_leave_app_ot = 0 THEN
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,'Ensure that All paid leave '|| l_employee_categories|| l_is_gt_0 );
     --||' must be > 0 '||l_str_common );
   END IF;
END IF;


-----Section E: The total of all paid hours not worked cannot exceed the total of paid contracted hours for any given category of employees

IF (  l_data_part4.l_ann_leave_ft_mg + l_data_part4.l_mat_leave_ft_mg +
       l_data_part4.l_sck_leave_ft_mg + l_data_part4.l_other_leave_ft_mg ) >
       l_data_part3.l_contracted_hrs_paid_ft_mg THEN

	 l_str_common := 'Ensure that the sum of annual leave, maternity leave, sick leave and other leave for all full time'
	 ||' managers, professionals and associate professional employees is less than total paid'
	 ||' contracted hours for all full time managers, professional and associate professional employees.';
       l_errflag := 'Y';
       Fnd_file.put_line(FND_FILE.LOG,l_str_common);
END IF;

IF (l_data_part4.l_ann_leave_ft_cl + l_data_part4.l_mat_leave_ft_cl +
    l_data_part4.l_sck_leave_ft_cl + l_data_part4.l_other_leave_ft_cl) >
    l_data_part3.l_contracted_hrs_paid_ft_cl THEN

     l_str_common := 'Ensure that the sum of annual leave, maternity leave, sick leave and other leave for all full time'
     ||' clerical, sales and service workers is less than or equal to total paid contracted hours for'
     ||' all full time clerical, sales and service workers.';
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,l_str_common);
END IF;

IF (l_data_part4.l_ann_leave_ft_ot + l_data_part4.l_mat_leave_ft_ot +
   l_data_part4.l_sck_leave_ft_ot + l_data_part4.l_other_leave_ft_ot  ) >
   l_data_part3.l_contracted_hrs_paid_ft_ot THEN

     l_str_common := 'Ensure that the sum of annual leave, maternity leave, sick leave and other leave for all full time'
     ||' production, transport, craft, tradespersons and other manual workers is less than or equal to'
     ||' the total of paid contracted hours for all full time production, transport, craft, tradespersons and other manual workers.';
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,l_str_common);
END IF;

IF (l_data_part4.l_ann_leave_pt_mg + l_data_part4.l_mat_leave_pt_mg +
    l_data_part4.l_sck_leave_pt_mg + l_data_part4.l_other_leave_pt_mg) >
    l_data_part3.l_contracted_hrs_paid_pt_mg THEN

     l_str_common := 'Ensure that the sum of annual leave, maternity leave, sick leave and other leave for all part time managers,'
     ||' professionals and associate professional employees is less than or equal to total paid contracted hours for'
     ||' all part time managers, professional and associate professional employees.';
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,l_str_common);

END IF;

IF (l_data_part4.l_ann_leave_pt_cl + l_data_part4.l_mat_leave_pt_cl +
    l_data_part4.l_sck_leave_pt_cl + l_data_part4.l_other_leave_pt_cl) >
    l_data_part3.l_contracted_hrs_paid_pt_cl THEN

     l_str_common := 'The sum of annual leave, maternity leave, sick leave and other leave for all part time clerical,'
     ||' sales and service workers must be less than or equal to total paid contracted hours for all part time clerical,'
     ||' sales and service workers.';
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,l_str_common);
END IF;

IF ( l_data_part4.l_ann_leave_pt_ot + l_data_part4.l_mat_leave_pt_ot +
     l_data_part4.l_sck_leave_pt_ot + l_data_part4.l_other_leave_pt_ot) >
     l_data_part3.l_contracted_hrs_paid_pt_ot THEN

     l_str_common := 'Ensure that the sum of annual leave, maternity leave, sick leave and other leave for all part time production, '
     ||' transport, craft, tradespersons and other manual workers is less than or equal to the total of paid contracted '
     ||' hours for all part time production, transport, craft, tradespersons and other manual workers.';
     l_errflag := 'Y';
     Fnd_file.put_line(FND_FILE.LOG,l_str_common);
END IF;

IF ( l_data_part4.l_ann_leave_pt_ot + l_data_part4.l_mat_leave_pt_ot +
     l_data_part4.l_sck_leave_pt_ot + l_data_part4.l_other_leave_pt_ot) >
     l_data_part3.l_contracted_hrs_paid_pt_ot THEN
	l_errflag := 'Y';
     l_str_common := 'Ensure that the sum of annual leave, maternity leave, sick leave and other leave for all part time production,'
     ||' transport, craft, tradespersons and other manual workers is less than or equal to the total of paid contracted '
     ||' hours for all part time production, transport, craft, tradespersons and other manual workers.';
     Fnd_file.put_line(FND_FILE.LOG,l_str_common);
END IF;

IF l_data_part4.l_all_paid_leave_app_mg > l_data_part3.l_contracted_hrs_paid_app_mg THEN
	l_errflag := 'Y';
     l_str_common := 'Ensure that all paid leave for apprentice/trainee managers, professionals and associate professional employees '
     ||'is less than or equal to total paid contracted hours for all apprentice/trainee managers, professionals and '
     ||' associate professionals.';
     Fnd_file.put_line(FND_FILE.LOG,l_str_common);
END IF;

IF l_data_part4.l_all_paid_leave_app_cl > l_data_part3.l_contracted_hrs_paid_app_cl THEN
	l_errflag := 'Y';
     l_str_common := 'Ensure that all paid leave for apprentice/trainee clerical, sales and service workers is less than'
     ||' or equal to total paid contracted hours for all apprentice/trainee clerical, sales and service workers.';
     Fnd_file.put_line(FND_FILE.LOG,l_str_common);
END IF;

IF l_data_part4.l_all_paid_leave_app_ot > l_data_part3.l_contracted_hrs_paid_app_ot THEN
	l_errflag := 'Y';
     l_str_common := 'Ensure that all paid leave for apprentice/trainee production, transport, craft, tradespersons and other '
     ||' manual workers is less than or equal to total paid contracted hours for all apprentice/trainee '
     ||' production, transport, craft, tradespersons and other manual workers.';
     Fnd_file.put_line(FND_FILE.LOG,l_str_common);
END IF;

--6922250
/*
IF l_errflag = 'Y' THEN
    Raise l_ehecs_exception;
END IF;
*/

  l_string:='<Data>';
  l_string:=l_string || '<FstFtMg>'  || l_data_part1.l_fst_ft_mg || '</FstFtMg>';
  l_string:=l_string || '<FstFtCl>'  || l_data_part1.l_fst_ft_cl || '</FstFtCl>';
  l_string:=l_string || '<FstFtOt>'  || l_data_part1.l_fst_ft_ot || '</FstFtOt>';
  l_string:=l_string || '<LstFtMg>'  || l_data_part1.l_lst_ft_mg || '</LstFtMg>';
  l_string:=l_string || '<LstFtCl>'  || l_data_part1.l_lst_ft_cl || '</LstFtCl>';
  l_string:=l_string || '<LstFtOt>'	 || l_data_part1.l_lst_ft_ot || '</LstFtOt>';
  l_string:=l_string || '<HireFtMg>' || l_data_part1.l_hire_ft_mg || '</HireFtMg>';
  l_string:=l_string || '<HireFtCl>' || l_data_part1.l_hire_ft_cl || '</HireFtCl>';
  l_string:=l_string || '<HireFtOt>' || l_data_part1.l_hire_ft_ot || '</HireFtOt>';
  l_string:=l_string || '<FstPtMg>' || l_data_part1.l_fst_pt_mg || '</FstPtMg>';
  l_string:=l_string || '<FstPtCl>' || l_data_part1.l_fst_pt_cl || '</FstPtCl>';
  l_string:=l_string || '<FstPtOt>' || l_data_part1.l_fst_pt_ot || '</FstPtOt>';
  l_string:=l_string || '<LstPtMg>' || l_data_part1.l_lst_pt_mg || '</LstPtMg>';
  l_string:=l_string || '<LstPtCl>' || l_data_part1.l_lst_pt_cl || '</LstPtCl>';
  l_string:=l_string || '<LstPtOt>' || l_data_part1.l_lst_pt_ot || '</LstPtOt>';
  l_string:=l_string || '<HirePtMg>' || l_data_part1.l_hire_pt_mg || '</HirePtMg>';
  l_string:=l_string || '<HirePtCl>' || l_data_part1.l_hire_pt_cl || '</HirePtCl>';
  l_string:=l_string || '<HirePtOt>' || l_data_part1.l_hire_pt_ot || '</HirePtOt>';
  l_string:=l_string || '<AppMg>' || l_data_part1.l_app_mg || '</AppMg>';
  l_string:=l_string || '<AppCl>' || l_data_part1.l_app_cl || '</AppCl>';
  l_string:=l_string || '<AppOt>' || l_data_part1.l_app_ot || '</AppOt>';
  l_string:=l_string || '<OtPerMg>' || l_data_part1.l_not_payroll_mg || '</OtPerMg>';
  l_string:=l_string || '<OtPerCl>' || l_data_part1.l_not_payroll_cl || '</OtPerCl>';
  l_string:=l_string || '<OtPerOt>' || l_data_part1.l_not_payroll_ot || '</OtPerOt>';
  l_string:=l_string || '<VacMg>' || l_data_part1.l_vac_mg || '</VacMg>';
  l_string:=l_string || '<VacCl>' || l_data_part1.l_vac_cl || '</VacCl>';
  l_string:=l_string || '<VacOt>' || l_data_part1.l_vac_ot || '</VacOt>';
  l_string:=l_string || '<NMWMg>' || l_data_part1.l_min_paid_mg || '</NMWMg>';
  l_string:=l_string || '<NMWCl>' || l_data_part1.l_min_paid_cl || '</NMWCl>';
  l_string:=l_string || '<NMWOt>' || l_data_part1.l_min_paid_ot || '</NMWOt>';

--end loop;

hr_utility.set_location('Before completing the l_data_part1: length(l_string) = '||length(l_string),3300);
l_clob := l_clob||l_string;

IF l_clob IS NOT NULL THEN
	l_blob := c2b(l_clob);
	pay_core_files.write_to_magtape_lob(l_blob);
END IF;

l_string:='';
l_clob:='';

--for l_data_part2 in c_get_part2(l_payroll_action_id)
--loop
hr_utility.set_location('entering c_get_part2 ',280);
  l_string:=l_string || '<RegWgFtMg>' || l_data_part2.l_reg_wg_ft_mg || '</RegWgFtMg>';
  l_string:=l_string || '<RegWgFtCl>' || l_data_part2.l_reg_wg_ft_cl || '</RegWgFtCl>';
  l_string:=l_string || '<RegWgFtOt>' || l_data_part2.l_reg_wg_ft_ot || '</RegWgFtOt>';
  l_string:=l_string || '<OvrtFtMg>' || l_data_part2.l_ot_paid_ft_mg || '</OvrtFtMg>';
  l_string:=l_string || '<OvrtFtCl>' || l_data_part2.l_ot_paid_ft_cl || '</OvrtFtCl>';
  l_string:=l_string || '<OvrtFtOt>' || l_data_part2.l_ot_paid_ft_ot || '</OvrtFtOt>';
  l_string:=l_string || '<IrrBFtMg>' || l_data_part2.l_irr_bonus_ft_mg || '</IrrBFtMg>';
  l_string:=l_string || '<IrrBFtCl>' || l_data_part2.l_irr_bonus_ft_cl || '</IrrBFtCl>';
  l_string:=l_string || '<IrrBFtOt>' || l_data_part2.l_irr_bonus_ft_ot || '</IrrBFtOt>';
  l_string:=l_string || '<RegWgPtMg>' || l_data_part2.l_reg_wg_pt_mg || '</RegWgPtMg>';
  l_string:=l_string || '<RegWgPtCl>' || l_data_part2.l_reg_wg_pt_cl || '</RegWgPtCl>';
  l_string:=l_string || '<RegWgPtOt>' || l_data_part2.l_reg_wg_pt_ot || '</RegWgPtOt>';
  l_string:=l_string || '<OvrtPtMg>' || l_data_part2.l_ot_paid_pt_mg || '</OvrtPtMg>';
  l_string:=l_string || '<OvrtPtCl>' || l_data_part2.l_ot_paid_pt_cl || '</OvrtPtCl>';
  l_string:=l_string || '<OvrtPtOt>' || l_data_part2.l_ot_paid_pt_ot || '</OvrtPtOt>';
  l_string:=l_string || '<IrrBPtMg>' || l_data_part2.l_irr_bonus_pt_mg || '</IrrBPtMg>';
  l_string:=l_string || '<IrrBPtCl>' || l_data_part2.l_irr_bonus_pt_cl || '</IrrBPtCl>';
  l_string:=l_string || '<IrrBPtOt>' || l_data_part2.l_irr_bonus_pt_ot || '</IrrBPtOt>';
  l_string:=l_string || '<AppWgMg>' || l_data_part2.l_tot_wg_app_mg || '</AppWgMg>';
  l_string:=l_string || '<AppWgCl>' || l_data_part2.l_tot_wg_app_cl || '</AppWgCl>';
  l_string:=l_string || '<AppWgOt>' || l_data_part2.l_tot_wg_app_ot || '</AppWgOt>';
--  end loop;

  hr_utility.set_location('Before completing the l_data_part2: length(l_string) = '||length(l_string),3310);
l_clob := l_clob||l_string;

IF l_clob IS NOT NULL THEN
	l_blob := c2b(l_clob);
	pay_core_files.write_to_magtape_lob(l_blob);
END IF;

l_string:='';
l_clob:='';
--for l_data_part3 in c_get_part3(l_payroll_action_id)
--loop
hr_utility.set_location('entering c_get_part3 ',280);
   l_string:=l_string || '<CHrsFtMg>' || l_data_part3.l_contracted_hrs_paid_ft_mg || '</CHrsFtMg>';
  l_string:=l_string || '<CHrsFtCl>' || l_data_part3.l_contracted_hrs_paid_ft_cl || '</CHrsFtCl>';
  l_string:=l_string || '<CHrsFtOt>' || l_data_part3.l_contracted_hrs_paid_ft_ot || '</CHrsFtOt>';
  l_string:=l_string || '<OTHrFtMg>' || l_data_part3.l_ot_hrs_paid_ft_mg || '</OTHrFtMg>';
  l_string:=l_string || '<OTHrFtCl>' || l_data_part3.l_ot_hrs_paid_ft_cl || '</OTHrFtCl>';
  l_string:=l_string || '<OTHrFtOt>' || l_data_part3.l_ot_hrs_paid_ft_ot || '</OTHrFtOt>';
  l_string:=l_string || '<CHrsPtMg>' || l_data_part3.l_contracted_hrs_paid_pt_mg || '</CHrsPtMg>';
  l_string:=l_string || '<CHrsPtCl>' || l_data_part3.l_contracted_hrs_paid_pt_cl || '</CHrsPtCl>';
  l_string:=l_string || '<CHrsPtOt>' || l_data_part3.l_contracted_hrs_paid_pt_ot || '</CHrsPtOt>';
  l_string:=l_string || '<OTHrPtMg>' || l_data_part3.l_ot_hrs_paid_pt_mg || '</OTHrPtMg>';
  l_string:=l_string || '<OTHrPtCl>' || l_data_part3.l_ot_hrs_paid_pt_cl || '</OTHrPtCl>';
  l_string:=l_string || '<OTHrPtOt>' || l_data_part3.l_ot_hrs_paid_pt_ot || '</OTHrPtOt>';
  l_string:=l_string || '<CHrsApMg>' || l_data_part3.l_contracted_hrs_paid_app_mg || '</CHrsApMg>';
  l_string:=l_string || '<CHrsApCl>' || l_data_part3.l_contracted_hrs_paid_app_cl || '</CHrsApCl>';
  l_string:=l_string || '<CHrsApOt>' || l_data_part3.l_contracted_hrs_paid_app_ot || '</CHrsApOt>';
  l_string:=l_string || '<OTHrApMg>' || l_data_part3.l_ot_hrs_paid_app_mg || '</OTHrApMg>';
  l_string:=l_string || '<OTHrApCl>' || l_data_part3.l_ot_hrs_paid_app_cl || '</OTHrApCl>';
  l_string:=l_string || '<OTHrApOt>' || l_data_part3.l_ot_hrs_paid_app_ot || '</OTHrApOt>';
--  end loop;

hr_utility.set_location('Before completing the l_data_part3: length(l_string) = '||length(l_string),3320);
l_clob := l_clob||l_string;

IF l_clob IS NOT NULL THEN
	l_blob := c2b(l_clob);
	pay_core_files.write_to_magtape_lob(l_blob);
END IF;

l_string:='';
l_clob:='';
--for l_data_part4 in c_get_part4(l_payroll_action_id)
--loop
hr_utility.set_location('entering c_get_part4 ',280);
  l_string:=l_string || '<ALFtMg>'  || l_data_part4.l_ann_leave_ft_mg || '</ALFtMg>';
  l_string:=l_string || '<ALFtCl>'  || l_data_part4.l_ann_leave_ft_cl || '</ALFtCl>';
  l_string:=l_string || '<ALFtOt>'  || l_data_part4.l_ann_leave_ft_ot || '</ALFtOt>';
  l_string:=l_string || '<MatFtMg>' || l_data_part4.l_mat_leave_ft_mg || '</MatFtMg>';
  l_string:=l_string || '<MatFtCl>' || l_data_part4.l_mat_leave_ft_cl || '</MatFtCl>';
  l_string:=l_string || '<MatFtOt>' || l_data_part4.l_mat_leave_ft_ot || '</MatFtOt>';
  l_string:=l_string || '<SicFtMg>' || l_data_part4.l_sck_leave_ft_mg || '</SicFtMg>';
  l_string:=l_string || '<SicFtCl>' || l_data_part4.l_sck_leave_ft_cl || '</SicFtCl>';
  l_string:=l_string || '<SicFtOt>' || l_data_part4.l_sck_leave_ft_ot || '</SicFtOt>';
  l_string:=l_string || '<OtLFtMg>' || l_data_part4.l_other_leave_ft_mg || '</OtLFtMg>';
  l_string:=l_string || '<OtLFtCl>' || l_data_part4.l_other_leave_ft_cl || '</OtLFtCl>';
  l_string:=l_string || '<OtLFtOt>' || l_data_part4.l_other_leave_ft_ot || '</OtLFtOt>';
  l_string:=l_string || '<ALPtMg>'  || l_data_part4.l_ann_leave_pt_mg || '</ALPtMg>';
  l_string:=l_string || '<ALPtCl>'  || l_data_part4.l_ann_leave_pt_cl || '</ALPtCl>';
  l_string:=l_string || '<ALPtOt>'  || l_data_part4.l_ann_leave_pt_ot || '</ALPtOt>';
  l_string:=l_string || '<MatPtMg>' || l_data_part4.l_mat_leave_pt_mg || '</MatPtMg>';
  l_string:=l_string || '<MatPtCl>' || l_data_part4.l_mat_leave_pt_cl || '</MatPtCl>';
  l_string:=l_string || '<MatPtOt>' || l_data_part4.l_mat_leave_pt_ot || '</MatPtOt>';
  l_string:=l_string || '<SicPtMg>' || l_data_part4.l_sck_leave_pt_mg || '</SicPtMg>';
  l_string:=l_string || '<SicPtCl>' || l_data_part4.l_sck_leave_pt_cl || '</SicPtCl>';
  l_string:=l_string || '<SicPtOt>' || l_data_part4.l_sck_leave_pt_ot || '</SicPtOt>';
  l_string:=l_string || '<OtLPtMg>' || l_data_part4.l_other_leave_pt_mg || '</OtLPtMg>';
  l_string:=l_string || '<OtLPtCl>' || l_data_part4.l_other_leave_pt_cl || '</OtLPtCl>';
  l_string:=l_string || '<OtLPtOt>' || l_data_part4.l_other_leave_pt_ot || '</OtLPtOt>';
  l_string:=l_string || '<LApMg>'   || l_data_part4.l_all_paid_leave_app_mg || '</LApMg>';
  l_string:=l_string || '<LApCl>'   || l_data_part4.l_all_paid_leave_app_cl || '</LApCl>';
  l_string:=l_string || '<LApOt>'   || l_data_part4.l_all_paid_leave_app_ot || '</LApOt>';
--end loop;

hr_utility.set_location('Before completing the l_data_part4: length(l_string) = '||length(l_string),3330);
l_clob := l_clob||l_string;

IF l_clob IS NOT NULL THEN
	l_blob := c2b(l_clob);
	pay_core_files.write_to_magtape_lob(l_blob);
END IF;

/*
open  c_get_part_all_other(l_payroll_action_id);
fetch c_get_part_all_other into l_data_part_all_other;
close c_get_part_all_other;
*/

l_string:='';
l_clob:='';

  l_string:=l_string || '<PenMg>'  || l_data_part_all_other.l_employer_pension_mg || '</PenMg>';
  l_string:=l_string || '<PenCl>'  || l_data_part_all_other.l_employer_pension_cl || '</PenCl>';
  l_string:=l_string || '<PenOt>'  || l_data_part_all_other.l_employer_pension_ot || '</PenOt>';
  l_string:=l_string || '<LibIns>' || l_data_part_all_other.l_employer_liability_premium || '</LibIns>';

--for l_data_part7 in c_get_part7(l_payroll_action_id)
--loop
hr_utility.set_location('entering c_get_part7 ',280);
  l_string:=l_string || '<PRSIMg>'	|| l_data_part7.l_employer_prsi_mg || '</PRSIMg>';
  l_string:=l_string || '<PRSICl>'	|| l_data_part7.l_employer_prsi_cl || '</PRSICl>';
  l_string:=l_string || '<PRSIOt>'	|| l_data_part7.l_employer_prsi_ot || '</PRSIOt>';
  l_string:=l_string || '<IncCtMg>' || l_data_part7.l_continuance_income_mg || '</IncCtMg>';
  l_string:=l_string || '<IncCtCl>' || l_data_part7.l_continuance_income_cl || '</IncCtCl>';
  l_string:=l_string || '<IncCtOt>' || l_data_part7.l_continuance_income_ot || '</IncCtOt>';
  l_string:=l_string || '<RedMg>'	|| l_data_part7.l_redundacny_paid_mg || '</RedMg>';
  l_string:=l_string || '<RedCl>'	|| l_data_part7.l_redundacny_paid_cl || '</RedCl>';
  l_string:=l_string || '<RedOt>'	|| l_data_part7.l_redundacny_paid_ot || '</RedOt>';
  l_string:=l_string || '<OtSocMg>' || l_data_part7.l_other_paid_mg || '</OtSocMg>';
  l_string:=l_string || '<OtSocCl>' || l_data_part7.l_other_paid_cl || '</OtSocCl>';
  l_string:=l_string || '<OtSocOt>' || l_data_part7.l_other_paid_ot || '</OtSocOt>';
  l_string:=l_string || '<SSecApMg>' || l_data_part7.l_ssc_contributions_app_mg || '</SSecApMg>';
  l_string:=l_string || '<SSecApCl>' || l_data_part7.l_ssc_contributions_app_cl || '</SSecApCl>';
  l_string:=l_string || '<SSecApOt>' || l_data_part7.l_ssc_contributions_app_ot || '</SSecApOt>';
--end loop;

hr_utility.set_location('Before completing the l_data_part7: length(l_string) = '||length(l_string),3340);
l_clob := l_clob||l_string;

IF l_clob IS NOT NULL THEN
	l_blob := c2b(l_clob);
	pay_core_files.write_to_magtape_lob(l_blob);
END IF;
l_string:='';
l_clob:='';
--for l_data_part8 in c_get_part8(l_payroll_action_id)
--loop
hr_utility.set_location('entering c_get_part8 ',280);
   l_string:=l_string || '<CarMg>' || l_data_part8.l_company_car_mg || '</CarMg>';
  l_string:=l_string || '<CarCl>' || l_data_part8.l_company_car_cl || '</CarCl>';
  l_string:=l_string || '<CarOt>' || l_data_part8.l_company_car_ot || '</CarOt>';
  l_string:=l_string || '<StksMg>' || l_data_part8.l_stock_options_mg || '</StksMg>';
  l_string:=l_string || '<StksCl>' || l_data_part8.l_stock_options_cl || '</StksCl>';
  l_string:=l_string || '<StksOt>' || l_data_part8.l_stock_options_ot || '</StksOt>';
  l_string:=l_string || '<VHIMg>' || l_data_part8.l_vol_sick_insurance_mg || '</VHIMg>';
  l_string:=l_string || '<VHICl>' || l_data_part8.l_vol_sick_insurance_cl || '</VHICl>';
  l_string:=l_string || '<VHIOt>' || l_data_part8.l_vol_sick_insurance_ot || '</VHIOt>';
  l_string:=l_string || '<HseMg>' || l_data_part8.l_staff_housing_mg || '</HseMg>';
  l_string:=l_string || '<HseCl>' || l_data_part8.l_staff_housing_cl || '</HseCl>';
  l_string:=l_string || '<HseOt>' || l_data_part8.l_staff_housing_ot || '</HseOt>';
  l_string:=l_string || '<OtBenMg>' || l_data_part8.l_other_benefits_mg || '</OtBenMg>';
  l_string:=l_string || '<OtBenCl>' || l_data_part8.l_other_benefits_cl || '</OtBenCl>';
  l_string:=l_string || '<OtBenOt>' || l_data_part8.l_other_benefits_ot || '</OtBenOt>';
--end loop;

hr_utility.set_location('Before completing the l_data_part8: length(l_string) = '||length(l_string),3350);

/*
for l_data_part_all_other in c_get_part_all_other(l_payroll_action_id)
loop
*/
hr_utility.set_location('entering c_get_part others ',280);
  l_string:=l_string || '<TrExp>' || l_data_part_all_other.l_employer_training_costs || '</TrExp>';
  l_string:=l_string || '<OtExp>' || l_data_part_all_other.l_other_expenditure || '</OtExp>';
  l_string:=l_string || '<TrSub>' || l_data_part_all_other.l_training_subsudies || '</TrSub>';
  l_string:=l_string || '<OtSub>' || l_data_part_all_other.l_other_subsidies || '</OtSub>';
  l_string:=l_string || '<Rfund>' || l_data_part_all_other.l_refunds || '</Rfund>';
  --l_string:=l_string || '<FstFtMg>' || l_data_part_all_other.l_comment_line2 || '</FstFtMg>';
  --l_string:=l_string || '<FstFtMg>' || l_data_part_all_other.l_comment_line3 || '</FstFtMg>';
/*end loop;*/
l_string:=l_string||'</Data>';

/*
l_string:=l_string || '<comment>' || l_data_part_all_other.l_comment_line1 ||
                                         l_data_part_all_other.l_comment_line2 ||
					 l_data_part_all_other.l_comment_line2 || '</comment>';
*/
l_string:=l_string || '<Comment>' || '<![CDATA[' || g_comments || ']]>' || '</Comment>';		--7367314

l_string := l_string ||'</EHECS>'||EOL ;	--7367314
hr_utility.set_location('Before completing the l_data_part_all_other: length(l_string) = '||length(l_string),3360);

l_clob := l_clob||l_string;

IF l_clob IS NOT NULL THEN
	l_blob := c2b(l_clob);
	pay_core_files.write_to_magtape_lob(l_blob);
END IF;
	--l_buf := l_buf || '</EHECS>'||EOL ;

--6922250
l_str_common := 'The report completed with validation warning(s). Do not submit the generated XML file '
		    ||'as it may not be in the correct format. You can, however, modify and use the template output.';

IF l_errflag = 'Y' THEN
   Fnd_file.put_line(FND_FILE.LOG,l_str_common);
   error_message := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',
			  'EHECS Report completed with validation warning(s).');
END IF;


EXCEPTION
WHEN l_ehecs_exception THEN
	Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1223);
	l_string := l_string ||'</EHECS>'||EOL ;		--7367314
	l_clob := l_clob||l_string;
	IF l_clob IS NOT NULL THEN
		l_blob := c2b(l_clob);
		pay_core_files.write_to_magtape_lob(l_blob);
	END IF;
	error_message := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','EHECS Report errors out.');
WHEN Others THEN
	Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,3370);
	l_string := l_string ||'</EHECS>'||EOL ;		--7367314
	l_clob := l_clob||l_string;
	IF l_clob IS NOT NULL THEN
		l_blob := c2b(l_clob);
		pay_core_files.write_to_magtape_lob(l_blob);
	END IF;

end gen_footer_xml;

procedure archive_deinit(pactid IN NUMBER)
 IS
 l_action_info_id NUMBER;
 l_ovn NUMBER;
begin
 null;
end archive_deinit;
END PAY_IE_EHECS_REPORT_PKG;

/
