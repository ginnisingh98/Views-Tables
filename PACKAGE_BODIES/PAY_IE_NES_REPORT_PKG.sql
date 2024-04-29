--------------------------------------------------------
--  DDL for Package Body PAY_IE_NES_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_NES_REPORT_PKG" AS
/* $Header: pyienes.pkb 120.0.12010000.4 2009/08/25 08:37:24 knadhan noship $ */

g_package	VARCHAR2(50)  := 'PAY_IE_nes_REPORT_PKG.';
EOL		VARCHAR2(5)   := fnd_global.local_chr(10);
l_errflag VARCHAR2(1) := 'N';
error_message boolean;
l_str_Common VARCHAR2(2000);
l_employee_categories VARCHAR(200);
l_nes_exception exception;

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
l_dimension			VARCHAR2(100) := '_ASG_QTD';
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

  g_balance_name(8).balance_name  := 'Voluntary Sickness Insurance';
  g_balance_name(9).balance_name  := 'Staff Housing';
  g_balance_name(10).balance_name  := 'Other Benefits';
  g_balance_name(11).balance_name  := 'Other Subsidies';

  g_balance_name(12).balance_name  := 'IE BIK Company Vehicle';
  g_balance_name(13).balance_name  := 'Normal Working Hours';
  g_balance_name(14).balance_name  := 'Paid Maternity Days';
  g_balance_name(15).balance_name  := 'Paid Other Leave Days';
  g_balance_name(16).balance_name  := 'Paid Sick Leave Days';


  g_balance_name(17).balance_name  := 'IE PRSI Insurable Weeks';
  g_balance_name(18).balance_name  := 'IE PRSI K Term Insurable Weeks';
  g_balance_name(19).balance_name  := 'IE PRSI M Term Insurable Weeks';

  g_balance_name(20).balance_name   := 'Regular EarningsMONTH';
  g_balance_name(21).balance_name   := 'Overtime PaymentsMONTH';

  g_balance_name(22).balance_name   := 'Paid Holiday Hours';
  g_balance_name(23).balance_name   := 'Paid Holiday Days';
  g_balance_name(24).balance_name   := 'Regular Shift Allowance';
  g_balance_name(25).balance_name   := 'Irregular Shift Allowance';
  g_balance_name(26).balance_name   := 'Total Commission';

  hr_utility.set_location('Step = ' || l_proc,30);

  FOR l_index IN 1 .. g_balance_name.COUNT
  LOOP

    IF g_balance_name(l_index).balance_name in ('Regular Shift Allowance','Irregular Shift Allowance','Total Commission'
						,'Paid Overtime Hours','Normal Working Hours') THEN
    l_dimension := '_PER_PAYE_REF_MONTH';
    ELSE
    l_dimension := '_PER_PAYE_REF_YTD';
    END IF;

    hr_utility.set_location('l_index      = ' || l_index,30);
    hr_utility.set_location('balance_name = ' || g_balance_name(l_index).balance_name,30);
    hr_utility.set_location('l_dimension  = ' || l_dimension,30);

    l_index_id := l_index_id+1 ;

    IF g_balance_name(l_index).balance_name ='Regular EarningsMONTH' THEN
    OPEN csr_balance_dimension('Regular Earnings',
                               '_PER_PAYE_REF_MONTH');
    ELSIF g_balance_name(l_index).balance_name ='Overtime PaymentsMONTH' THEN
    OPEN csr_balance_dimension('Overtime Payments',
                               '_PER_PAYE_REF_MONTH');

    ELSE
    OPEN csr_balance_dimension(g_balance_name(l_index).balance_name,
                               l_dimension);
    END IF;

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
            LENGTH(legislative_parameters)
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
					,p_month OUT NOCOPY VARCHAR2
					,p_sample_fraction OUT NOCOPY VARCHAR2
					,p_business_Group_id OUT NOCOPY VARCHAR2
					,p_assignment_set_id OUT NOCOPY VARCHAR2
					,p_occupational_category OUT NOCOPY VARCHAR2
					,p_employer_id OUT NOCOPY VARCHAR2
					,p_report_type OUT NOCOPY VARCHAR2
					,p_declare_date OUT NOCOPY VARCHAR2
					,p_change_add OUT NOCOPY VARCHAR2
					,p_send_emp OUT NOCOPY VARCHAR2
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
    hr_utility.set_location(' Entering PAY_IE_NES_REPORT.get_all_parameters ', 200);

    get_parameters(p_payroll_action_id,'REP_GROUP',p_rep_group);
    get_parameters(p_payroll_action_id,'PAYROLL',p_payroll_id);
    get_parameters(p_payroll_action_id,'YEAR',p_year);
    get_parameters(p_payroll_action_id,'MONTH',p_month);
    get_parameters(p_payroll_action_id,'SAMPLE',p_sample_fraction);
    get_parameters(p_payroll_action_id,'BG_ID',p_business_Group_id);
    get_parameters(p_payroll_action_id,'ASSIGNMENT_SET_ID',p_assignment_set_id);
    get_parameters(p_payroll_action_id,'OCCUPATION',p_occupational_category);
    get_parameters(p_payroll_action_id,'EMPLOYER',p_employer_id);
    get_parameters(p_payroll_action_id,'REPTYPE',p_report_type);
    get_parameters(p_payroll_action_id,'DDATE',p_declare_date);
    get_parameters(p_payroll_action_id,'ADD_CHANGE',p_change_add);
    get_parameters(p_payroll_action_id,'SEND_EMP',p_send_emp);
    get_parameters(p_payroll_action_id,'COMMENTS',p_comments);

hr_utility.set_location(' After last get_parameters call ', 210);

IF p_month in ('01','02','03') THEN
	g_qtr_start_date := to_date('01/01/' || p_year,'DD/MM/RRRR');
	g_qtr_end_date := to_date('31/03/' || p_year,'DD/MM/RRRR');
	p_quarter:=1;
ELSIF p_month in ('04','05','06') THEN
	g_qtr_start_date := to_date('01/04/' || p_year,'DD/MM/RRRR');
	g_qtr_end_date := to_date('30/06/' || p_year,'DD/MM/RRRR');
	p_quarter:=2;
ELSIF p_month in ('07','08','09') THEN
	g_qtr_start_date := to_date('01/07/' || p_year,'DD/MM/RRRR');
	g_qtr_end_date := to_date('30/09/' || p_year,'DD/MM/RRRR');
	p_quarter:=3;
ELSIF p_month in ('10','11','12') THEN
	g_qtr_start_date := to_date('01/10/' || p_year,'DD/MM/RRRR');
	g_qtr_end_date := to_date('31/12/' || p_year,'DD/MM/RRRR');
	p_quarter:=4;
END IF;

hr_utility.set_location(' After populating the Quarter dates. ', 220);



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
hr_utility.set_location(' MONTH = '||p_month,240);
hr_utility.set_location(' SAMPLE = '||p_sample_fraction,240);
hr_utility.set_location(' QUARTER = '||p_quarter,240);
hr_utility.set_location(' ASSIGNMENT_SET_ID = '||p_assignment_set_id,240);
hr_utility.set_location(' OCCUPATION CATEGORY = '||p_occupational_category,240);
hr_utility.set_location(' EMPLOYER = '||p_employer_id,240);
hr_utility.set_location(' REPORT TYPE = '||p_report_type,240);
hr_utility.set_location(' DDATE = '||p_declare_date,240);
hr_utility.set_location(' ADD_CHANGE = '||p_change_add,240);
hr_utility.set_location(' SEND_EMP = '|| p_send_emp,240);
hr_utility.set_location(' COMMENTS = '||p_comments,240);
hr_utility.set_location(' g_qtr_start_date = '||g_qtr_start_date,240);
hr_utility.set_location(' g_qtr_end_date = '||g_qtr_end_date,240);

IF p_occupational_category IS NOT NULL THEN

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

 hr_utility.set_location(' Leaving: PAY_IE_NES_REPORT.get_all_parameters: ', 270);

EXCEPTION
  WHEN Others THEN
    hr_utility.set_location(' Leaving: PAY_IE_nes_REPORT.get_all_parameters with errors: ', 280);
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
 l_month varchar2(50);
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
	    ,null addr4
	    ,null addr5
	    ,hla.TOWN_OR_CITY City
            ,flv.meaning County
            ,hla.COUNTRY Country_Name
            ,hla.REGION_1
             from hr_organization_units hou
                 ,hr_organization_information hoi
                 ,hr_locations_all hla
		 ,fnd_lookup_values flv
              where hoi.org_information_context='IE_EMPLOYER_INFO'
              and hoi.organization_id=c_org_id
              and hoi.organization_id=hou.organization_id
              and hou.business_group_id= c_bg_id
              and hou.location_id=hla.location_id(+)
	      and flv.lookup_type(+) = 'IE_COUNTY'
              and flv.language(+) = 'US'
              and flv.lookup_code(+) = hla.REGION_1;


 CURSOR csr_declarant(c_org_id  hr_organization_information.organization_id%type
                            ,c_bg_id hr_organization_units.business_group_id%type
				    ,p_year varchar2
				    ,p_qtr varchar2) IS
 select hoi.org_information3 cbr_no
       ,hoi.org_information13 person_id
       ,hoi.org_information17 position
       ,hoi.org_information19 email
       ,hoi.org_information20 phone
     from hr_organization_units hou
    ,hr_organization_information hoi
  where hoi.org_information_context='IE_EHECS'
  and hoi.organization_id=c_org_id
  and hoi.organization_id=hou.organization_id
  and hou.business_group_id= c_bg_id
  and hoi.ORG_INFORMATION1 = p_year
  and hoi.ORG_INFORMATION2 = p_qtr;

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

 Type tab_address is table of per_addresses.ADDRESS_LINE1%type index by binary_integer;
 pl_address tab_address;
 pl_address_final tab_address;
 k NUMBER(3) := 0;


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
			,l_month
			,g_sample_fraction
			,g_business_group_id
			,l_assignment_set_id
			,l_occupational_category
			,g_employer_id
			,l_report_type
			,l_declare_date
			,l_change_indicator
			,g_send_emp
			,l_comments);

hr_utility.set_location(' g_rep_group  '|| TO_CHAR(g_rep_group) , 300);
hr_utility.set_location(' g_payroll_id  '|| TO_CHAR(g_payroll_id) , 300);
hr_utility.set_location(' l_year  '|| TO_CHAR(l_year) , 300);
hr_utility.set_location(' l_month  '|| TO_CHAR(l_month) , 300);
hr_utility.set_location(' g_sample_fraction  '|| TO_CHAR(g_sample_fraction) , 300);
hr_utility.set_location(' l_quarter  '|| TO_CHAR(l_quarter) , 300);
hr_utility.set_location(' g_business_group_id  '|| TO_CHAR(g_business_group_id) , 300);
hr_utility.set_location(' l_assignment_set_id  '|| TO_CHAR(l_assignment_set_id) , 300);
hr_utility.set_location(' l_occupational_category  '|| TO_CHAR(l_occupational_category) , 300);
hr_utility.set_location(' g_employer_id  '|| TO_CHAR(g_employer_id) , 300);
hr_utility.set_location(' l_report_type  '|| TO_CHAR(l_report_type) , 300);
hr_utility.set_location(' l_declare_date  '|| TO_CHAR(l_declare_date) , 300);
hr_utility.set_location(' l_change_indicator  '|| TO_CHAR(l_change_indicator) , 300);
hr_utility.set_location(' g_send_emp  '|| TO_CHAR(g_send_emp) , 300);
hr_utility.set_location(' l_comments  '|| l_comments , 300);

g_year := l_year;
g_quarter := l_quarter;
g_month:=l_month;
g_occupational_category := l_occupational_category;
g_assignment_set_id := l_assignment_set_id;

 hr_utility.set_location('before the  call of setup_balance_table in '||l_procedure_name, 320);
  setup_balance_table;

 hr_utility.set_location('After the call of setup_balance_table in '||l_procedure_name, 320);

  OPEN csr_employer_details(g_employer_id, g_business_group_id);
  FETCH csr_employer_details INTO l_employer_details;
  CLOSE csr_employer_details;

 hr_utility.set_location('After fetching the csr_employer_details ', 330);

  l_org_id :=		l_employer_details.org_id;
  l_employer_name :=	l_employer_details.employer_name;
/*
  l_addr1 :=		l_employer_details.addr1;
  l_addr2 :=		l_employer_details.addr2;
  l_addr3 :=		l_employer_details.addr3;
  l_addr4 := ' ';
  l_addr5 := ' '; */

  hr_utility.set_location(' Before deleting the PL table pl_address. ',1100);
pl_address.delete;

pl_address(1) := l_employer_details.addr1;
pl_address(2) := l_employer_details.addr2;
pl_address(3) := l_employer_details.addr3;
pl_address(4) := l_employer_details.City;
pl_address(5) := l_employer_details.COUNTY;
pl_address(6) := l_employer_details.Country_Name;


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

/*	l_employer_details.addr1 := NULL;
	l_employer_details.addr2 := NULL;
	l_employer_details.addr3 := NULL;
	l_employer_details.addr4 := NULL;
        l_employer_details.addr5 := NULL;  */

	  FOR l in 1..pl_address_final.LAST
	  LOOP
	hr_utility.set_location(' Inside the loop of PL table pl_address_final',1100);
	    BEGIN
		    IF l = 1 THEN
	hr_utility.set_location(' employer address .addr1 ',1100);
		     l_addr1 := pl_address_final(1);
	hr_utility.set_location('employer address .addr1 ',1101);
		    END IF;
		    --
		    IF l = 2 THEN
	hr_utility.set_location(' employer address.addr2 ',1102);
		     l_addr2 := pl_address_final(2);
	hr_utility.set_location(' employer address .addr2 ',1103);
		    END IF;
		    --
		    IF l = 3 THEN
	hr_utility.set_location(' employer address.addr3 ',1104);
		     l_addr3 := pl_address_final(3);
	hr_utility.set_location(' employer address .addr3 ',1105);
		    END IF;
		    --
		    IF l = 4 THEN
	hr_utility.set_location(' l_person_details.addr4 ',1106);
		     l_addr4 := pl_address_final(4);
	hr_utility.set_location(' employer address .addr4 ',1107);
		    END IF;
                    IF l = 5 THEN
	hr_utility.set_location(' l_person_details.addr5 ',1106);
		     l_addr5 := pl_address_final(5);
	hr_utility.set_location(' employer address .addr5 ',1107);
		    END IF;
	    EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		NULL;
	    END;
	  END LOOP;
  END IF;
hr_utility.set_location(' After Re Initializing the cursor record l_person_details with actual values. ',1100);

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


hr_utility.set_location('l_declarant_name '||l_declarant_name, 350);

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
  Raise l_nes_exception;
END IF;

hr_utility.set_location('Before entering record for IE_NES_HEADER ', 380);

    pay_action_information_api.create_action_information
    ( p_action_information_id => l_action_info_id
    ,p_action_context_id => pactid
    ,p_action_context_type => 'PA'
    ,p_object_version_number => l_ovn
    ,p_effective_date => g_archive_effective_date --g_end_date
    ,p_source_id => NULL
    ,p_source_text => NULL
    ,p_action_information_category => 'IE_NES_HEADER'
    ,p_action_information6  => l_year
    ,p_action_information7  => l_month
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

hr_utility.set_location('After entering record for IE_NES_HEADER ', 390);

hr_utility.set_location('Leaving '||l_procedure_name, 400);

 EXCEPTION
 WHEN l_nes_exception THEN
    Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,410);
    error_message := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','NES Report errors out. Some mandatory values are missing.');
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
    l_select_str1 VARCHAR2(3000);
    lockingactid NUMBER;
    l_valid_assg boolean := False;
    l_file_type pay_element_entry_values_f.screen_entry_value%TYPE;
    l_submitted pay_element_entry_values_f.screen_entry_value%TYPE;
    l_element_name varchar2(50);

    l_total_count NUMBER;
    l_total_sample NUMBER;
    TYPE asg_ref IS REF CURSOR;
    csr_get_asg asg_ref;
    csr_get_asg1 asg_ref;

 l_ass_check  varchar2(1);
 l_csr_already_archived pay_element_entry_values_f.screen_entry_value%TYPE := 'N';
 BEGIN

 hr_utility.set_location('Entering PAY_IE_NES_REPORT_PKG.assignment_action_code',500);

-- Get all the parameters
/*6978389 */
hr_utility.set_location('Before get_all_parameters',501);
get_all_parameters(pactid
			,g_rep_group
			,g_payroll_id
			,g_year
			,g_quarter
			,g_month
			,g_sample_fraction
			,g_business_group_id
			,g_assignment_set_id
			,g_occupational_category
			,g_employer_id
			,g_report_type
			,g_declare_date
			,g_change_indicator
			,g_send_emp
			,g_comments);
hr_utility.set_location('after get_all_parameters',502);
hr_utility.set_location(' g_qtr_start_date = '||g_qtr_start_date,505);
hr_utility.set_location(' g_qtr_end_date = '||g_qtr_end_date,505);
hr_utility.set_location(' g_business_group_id = '||g_business_group_id,505);
hr_utility.set_location(' g_employer_id = '||g_employer_id,505);

g_reference_start_date:=to_date('01'||'/'||g_month||'/'||g_year,'dd/mm/yyyy');
g_reference_end_date:=add_months(to_date('01'||'/'||g_month||'/'||g_year,'dd/mm/yyyy'),1)-1;

hr_utility.set_location(' g_reference_start_date = '|| g_reference_start_date,505);
hr_utility.set_location(' g_reference_end_date = '|| g_reference_end_date,505);

l_select_str1 :='select count (distinct paaf.assignment_id )
from                        per_all_assignments_f paaf,
                            per_all_people_f ppf,
                            pay_all_payrolls_f papf,
                            pay_payroll_actions ppa,
			    pay_assignment_actions paa,
   				    hr_soft_coding_keyflex scl
where                       paaf.business_group_id = '|| g_business_group_id
                            ||' and papf.business_group_id = paaf.business_group_id and '
				||''''|| g_reference_end_date||''''||'  between   paaf.effective_start_date  and paaf.effective_end_date '
				||' and paaf.person_id = ppf.person_id '
				||' and paaf.assignment_status_type_id in (SELECT assignment_status_type_id '
                                                                   ||'  FROM per_assignment_status_types '
                                                                   ||'  WHERE per_system_status = '||'''ACTIVE_ASSIGN'''
                                                                   ||'   AND active_flag       = '||'''Y'''||') '
                                ||' and paaf.primary_flag= '||'''Y'''
				    ||' and paaf.employment_category = '
			--	    ||' IN ('||'''FT'''||','||'''FR'''||','||'''PT'''||','||'''PR'''||','||'''AT'''||') '
                            ||'nvl(hruserdt.get_table_value(paaf.business_group_id,'||''''||'EHECS_ASG_CATG_TAB'||''''||','||''''||'Full_Time'||''''||',paaf.EMPLOYMENT_CATEGORY,'||''''||g_qtr_start_date||''''||')'
			    ||      ',nvl(hruserdt.get_table_value(paaf.business_group_id,'||''''||'EHECS_ASG_CATG_TAB'||''''||','||''''||'Part_Time'||''''||',paaf.EMPLOYMENT_CATEGORY,'||''''||g_qtr_start_date||''''||')'
			    ||	    ',  hruserdt.get_table_value(paaf.business_group_id,'||''''||'EHECS_ASG_CATG_TAB'||''''||','||''''||'Apprentice_Trainee'||''''||',paaf.EMPLOYMENT_CATEGORY,'||''''||g_qtr_start_date||''''||')'
			    ||	' ))'

			    ||' and ppf.person_id between '|| stperson || ' and ' || endperson
				    ||g_where_clause1
				    ||' and ppa.payroll_action_id = paa.payroll_action_id '
				    ||' and paa.assignment_id=paaf.assignment_id'
				    ||' and (paa.source_action_id is not null or ppa.action_type in ('||'''I'''||','||'''V'''||','||'''B'''||'))'
				    ||' and ppa.effective_date <='||''''||g_reference_end_date||''''
				    ||' and ppa.effective_date >='||''''||g_reference_start_date||''''
				    ||' and paa.action_status = '||'''C'''
				    ||' and ppa.action_type in ('||'''R'''||','||'''Q'''||','||'''I'''||','
				    ||'''V'''||','||'''B'''||')'
                            ||' and papf.payroll_id = paaf.payroll_id '
                            ||' and papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id '
				    ||' and scl.segment4 = to_char('||g_employer_id||') '
				    ||g_where_clause
				    ||g_where_clause_asg_set
          		          ||' Order by paaf.assignment_id';


hr_utility.set_location(' before cursor l_total_count' || l_total_count,530);
OPEN csr_get_asg1 FOR l_select_str1;
FETCH csr_get_asg1 INTO l_total_count;
CLOSE csr_get_asg1;
hr_utility.set_location(' after fetch l_total_count' || l_total_count,530);
hr_utility.set_location(' g_sample_fraction' || g_sample_fraction,530);
l_total_sample:= round(l_total_count /g_sample_fraction);
hr_utility.set_location(' l_total_sample' || l_total_sample,530);


hr_utility.set_location('Before building the dynamic query.',510);
/* 6856486   modified the employment_category 's IN condition to a value fetch from USER TABLE EHECS_ASG_CATG_TAB */
l_select_str :='select asgid from (
                                   select asgid,round(mod(dbms_random.value*'||g_sample_fraction||','||g_sample_fraction||')) serial '
                               || 'from ( '
                               || 'select distinct paaf.assignment_id asgid
from                        per_all_assignments_f paaf,
                            per_all_people_f ppf,
                            pay_all_payrolls_f papf,
                            pay_payroll_actions ppa,
			    pay_assignment_actions paa,
   				    hr_soft_coding_keyflex scl
where                       paaf.business_group_id = '|| g_business_group_id
                            ||' and papf.business_group_id = paaf.business_group_id and '
				||''''|| g_reference_end_date||''''||'  between   paaf.effective_start_date  and paaf.effective_end_date '
				||' and paaf.person_id = ppf.person_id '
				||' and paaf.assignment_status_type_id in (SELECT assignment_status_type_id '
                                                                   ||'  FROM per_assignment_status_types '
                                                                   ||'  WHERE per_system_status = '||'''ACTIVE_ASSIGN'''
                                                                   ||'   AND active_flag       = '||'''Y'''||') '
                                ||' and paaf.primary_flag= '||'''Y'''
				    ||' and paaf.employment_category = '
			--	    ||' IN ('||'''FT'''||','||'''FR'''||','||'''PT'''||','||'''PR'''||','||'''AT'''||') '
                            ||'nvl(hruserdt.get_table_value(paaf.business_group_id,'||''''||'EHECS_ASG_CATG_TAB'||''''||','||''''||'Full_Time'||''''||',paaf.EMPLOYMENT_CATEGORY,'||''''||g_qtr_start_date||''''||')'
			    ||      ',nvl(hruserdt.get_table_value(paaf.business_group_id,'||''''||'EHECS_ASG_CATG_TAB'||''''||','||''''||'Part_Time'||''''||',paaf.EMPLOYMENT_CATEGORY,'||''''||g_qtr_start_date||''''||')'
			    ||	    ',  hruserdt.get_table_value(paaf.business_group_id,'||''''||'EHECS_ASG_CATG_TAB'||''''||','||''''||'Apprentice_Trainee'||''''||',paaf.EMPLOYMENT_CATEGORY,'||''''||g_qtr_start_date||''''||')'
			    ||	' ))'

			    ||' and ppf.person_id between '|| stperson || ' and ' || endperson
				    ||g_where_clause1
				    ||' and ppa.payroll_action_id = paa.payroll_action_id '
				    ||' and paa.assignment_id=paaf.assignment_id'
				    ||' and (paa.source_action_id is not null or ppa.action_type in ('||'''I'''||','||'''V'''||','||'''B'''||'))'
				    ||' and ppa.effective_date <='||''''||g_reference_end_date||''''
				    ||' and ppa.effective_date >='||''''||g_reference_start_date||''''
				    ||' and paa.action_status = '||'''C'''
				    ||' and ppa.action_type in ('||'''R'''||','||'''Q'''||','||'''I'''||','
				    ||'''V'''||','||'''B'''||')'
                            ||' and papf.payroll_id = paaf.payroll_id '
                            ||' and papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id '
				    ||' and scl.segment4 = to_char('||g_employer_id||') '
				    ||g_where_clause
				    ||g_where_clause_asg_set
          		          ||' Order by paaf.assignment_id'
				  ||' ))'
                          ||' where rownum<='||l_total_sample
			  ||' order by    serial';


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

	hr_utility.set_location(' Before hr_nonrun_asact.insact call',550);
		hr_nonrun_asact.insact(lockingactid => lockingactid
					,assignid     => l_assg_id
					,pactid       => pactid
					,chunk        => chunk
					,greid        => NULL);
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

   hr_utility.set_location('Entering: PAY_IE_nes_REPORT_PKG.archive_init: ',600);

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
			,g_month
			,g_sample_fraction
			,g_business_group_id
			,g_assignment_set_id
			,g_occupational_category
			,g_employer_id
			,g_report_type
			,g_declare_date
			,g_change_indicator
			,g_send_emp
			,g_comments);

   hr_utility.set_location('After calling get_all_parameters ',620);

setup_balance_table;

   hr_utility.set_location('After calling setup_balance_table ',630);

    hr_utility.set_location(' Leaving PAY_IE_NESS_REPORT_PKG.archive_init', 640);

EXCEPTION
WHEN Others THEN
hr_utility.set_location(' Leaving PAY_IE_nes_REPORT_PKG.archive_init with errors', 650);
Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1211);

END archive_init;
 -----------------------------------------------------------------------
-- ARCHIVE_DATA
-----------------------------------------------------------------------
 PROCEDURE archive_data(p_assactid in number,
                        p_effective_date in date)
 IS

CURSOR cur_get_pactid(p_cess_aact pay_assignment_actions.assignment_action_id%TYPE) IS
 SELECT distinct paa.payroll_action_id,paa.assignment_id,paaf.person_id
   FROM pay_assignment_actions paa
       ,per_all_assignments_f paaf
 WHERE  paa.assignment_action_id = p_cess_aact
    and paa.assignment_id=paaf.assignment_id;


 CURSOR cur_assignment_action(c_person_id number,
                              c_till_date date)is
SELECT fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
      paa.assignment_action_id),16))
FROM pay_assignment_actions paa
    ,pay_payroll_actions ppa
    ,per_all_assignments_f paaf
    ,pay_all_payrolls_f papf
    ,hr_soft_coding_keyflex scl
WHERE paaf.person_id=c_person_id
  AND paa.assignment_id=paaf.assignment_id
  AND paa.payroll_action_id=ppa.payroll_action_id
  AND ppa.action_type in ('Q','B','R','I','V')
  AND paa.action_status ='C'
  AND paa.source_action_id is not null
  AND ppa.effective_date<= c_till_date
  AND papf.payroll_id=paaf.payroll_id
  AND papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
  AND scl.segment4 = to_char(g_employer_id);

CURSOR cur_assignment_action_ytd(c_person_id number)is
SELECT fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
      paa.assignment_action_id),16))
FROM pay_assignment_actions paa
    ,pay_payroll_actions ppa
    ,per_all_assignments_f paaf
    ,pay_all_payrolls_f papf
    ,hr_soft_coding_keyflex scl
WHERE paaf.person_id=c_person_id
  AND paa.assignment_id=paaf.assignment_id
  AND paa.payroll_action_id=ppa.payroll_action_id
  AND ppa.action_type in ('Q','B','R','I','V')
  AND paa.action_status ='C'
  AND paa.source_action_id is not null
  AND papf.payroll_id=paaf.payroll_id
  AND papf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
  AND scl.segment4 = to_char(g_employer_id);


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

CURSOR cur_valid_asg(c_assignment_id NUMBER, c_person_id NUMBER)
IS
SELECT distinct paaf.assignment_id, paaf.person_id, paaf.payroll_id,
	--decode(paaf.EMPLOYMENT_CATEGORY,'FT','F','FR','F','PR','P','PT','P',paaf.EMPLOYMENT_CATEGORY) EMP_CATG,
   /* 6856486 */
        decode(paaf.EMPLOYMENT_CATEGORY
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Full_Time',paaf.EMPLOYMENT_CATEGORY,g_reference_start_date),'F'
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Part_Time',paaf.EMPLOYMENT_CATEGORY,g_reference_start_date),'P'
	,hruserdt.get_table_value(paaf.business_group_id,'EHECS_ASG_CATG_TAB','Apprentice_Trainee',paaf.EMPLOYMENT_CATEGORY,g_reference_start_date),'AT'
	) EMP_CATG,

	NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Managers',paaf.EMPLOYEE_CATEGORY,g_reference_start_date),
	NVL(hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Clerical Workers',paaf.EMPLOYEE_CATEGORY,g_reference_start_date),
	  hruserdt.get_table_value(paaf.business_group_id,'EHECS_CATG_TAB','Production Workers',paaf.EMPLOYEE_CATEGORY,g_reference_start_date)
	  )
	) EHECS_CATG
	, paaf.effective_start_date
	,normal_hours normal_hours                /*6856473*/
	,frequency frequency                      /*6856473*/
	,hourly_salaried_code hourly_or_salaried  /*6856473*/
	,substr(paaf.EMPLOYEE_CATEGORY,-2,length(paaf.EMPLOYEE_CATEGORY)) status_code
	,paaf.assignment_number assignment_number
FROM
per_all_assignments_f paaf
WHERE paaf.assignment_id = c_assignment_id
and paaf.person_id = c_person_id
and paaf.effective_start_date <= g_reference_start_date
and paaf.effective_end_date >= g_reference_end_date
and assignment_status_type_id in (SELECT assignment_status_type_id
                           FROM per_assignment_status_types
                          WHERE per_system_status = 'ACTIVE_ASSIGN'
                            AND active_flag       = 'Y')/*6856473 to filter the terminated assingment*/
ORDER BY paaf.effective_start_date desc;


CURSOR csr_employee_details(cp_person_id in number,
                            cp_effective_date in date) is
   select papf.full_name full_name,
       papf.national_identifier PPS,
       pa.address_line1 address_line1,
       pa.address_line2 address_line2,
       pa.address_line3 address_line3,
       null address_line4,
       null address_line5,
       pa.town_or_city city ,
       flv.meaning County,
       pa.country  Country
        from per_addresses pa,
	     per_all_people_f papf,
	     fnd_lookup_values flv
       where  papf.person_id = cp_person_id
         and  papf.person_id=pa.person_id(+)
         and pa.primary_flag (+)= 'Y' --is address primary ?
         and pa.date_from(+) <= cp_effective_date
         and nvl(pa.date_to, cp_effective_date) >= cp_effective_date
         and flv.lookup_type(+) = 'IE_COUNTY'
         and flv.language(+) = 'US'
         and flv.lookup_code(+) = pa.REGION_1;

CURSOR csr_input_value_id(p_element_name CHAR,
                            p_value_name   CHAR) IS
  SELECT piv.input_value_id
  FROM   pay_input_values_f piv,
         pay_element_types_f pet
  WHERE  piv.element_type_id = pet.element_type_id
  AND    pet.legislation_code = 'IE'
  AND    pet.element_name = p_element_name
  AND    piv.name = p_value_name;

CURSOR csr_ness_action_details(c_assignment_action_id NUMBER) is
SELECT ppa.payroll_action_id pact_id,
ppa.date_earned date_earned
FROM  pay_payroll_actions ppa,
      pay_assignment_actions paa
WHERE paa.assignment_action_id=c_assignment_action_id
  AND paa.payroll_action_id=ppa.payroll_action_id;

cursor csr_get_periods(c_start_date in date,
                   c_end_date in date,
		   c_payroll_action_id in number) is
select ptp.period_type period_type,
       count(ptp.period_num) pay_periods
from
  pay_payroll_actions ppa
, per_time_periods ptp
, per_time_period_types tptype
WHERE ppa.payroll_action_id=c_payroll_action_id
AND   ptp.payroll_id=ppa.payroll_id
AND   ptp.period_type = tptype.period_type
AND   ptp.end_date between
c_start_date  and c_end_date
Group by ptp.period_type ;


l_ness_action_details csr_ness_action_details%ROWTYPE;
l_input_value_id   NUMBER;
l_input_value_id1   NUMBER;
l_employee_details csr_employee_details%ROWTYPE;

l_address_line1        hr_locations_all.address_line_1%type;
l_address_line2       hr_locations_all.address_line_2%type;
l_address_line3        hr_locations_all.address_line_3%type;
l_address_line4        hr_locations_all.address_line_3%type;
l_address_line5        hr_locations_all.address_line_3%type;

l_id_reference   per_all_assignments_f.assignment_number%TYPE:=NULL;

l_valid_asg_rec cur_valid_asg%ROWTYPE;
l_hours_per_day varchar2(10);
l_org_id hr_organization_units.organization_id%type;
l_normal_hours per_all_assignments_f.normal_hours%type;
l_frequency    per_all_assignments_f.frequency%type;

Type tab_address is table of per_addresses.ADDRESS_LINE1%type index by binary_integer;
 pl_address tab_address;
 pl_address_final tab_address;
 k NUMBER(3) := 0;

--------------------------- Variables which will hold the Balance Values.
l_regwg_bal_val	Number := 0;
l_irrb_bal_val	Number := 0;
l_ovrt_bal_val	Number := 0;
l_regwg_bal_val_ptd	Number := 0;

l_ovrt_bal_val_ptd	Number := 0;

l_reg_shft_allnce_bal_val  NUMBER :=0;
l_ireg_shft_allnce_bal_val  NUMBER :=0;
l_tot_shft_allnce_bal_val  NUMBER :=0;
l_holi_bal_val  NUMBER :=0;
l_tot_comm_bal_val NUMBER:=0;

l_othr_bal_val	Number := 0;
l_chrs_bal_val    number := 0;
l_mat_bal_val	Number := 0;
l_sic_bal_val	Number := 0;
l_otl_bal_val	Number := 0;
l_vhi_bal_val	Number := 0;
l_hse_bal_val	Number := 0;
l_otben_bal_val	Number := 0;
l_ot_sub_bal_val  Number := 0;
l_bik_veh_bal_val Number := 0;
l_pen_bal_val_tot Number := 0;
l_lap_bal_val_tot Number := 0;
l_app_wg_bal_val_tot Number := 0;
l_ssec_bal_val_tot Number := 0;
l_nmw_count Number := 0;
l_total_weeks Number:=0;



l_payroll_action_id number;
l_assignment_id number;
l_person_id number;
l_reference_date date;
l_ness_assignment_action number;
l_ness_assignment_action_ytd number;
l_action_info_id NUMBER;
l_ovn NUMBER;

l_ann_earning Number;
l_ann_bik NUMBER;
l_other_absence NUMBER;
l_gross_earning NUMBER;
l_prsi_class   VARCHAR2(10);
l_prsi_subclass   VARCHAR2(10);
l_period_type per_time_periods.period_type%type;
l_pay_periods number;
l_freq_pay NUMBER;
l_employement_type NUMBER;
l_ref_period_pay NUMBER;
l_ref_period_hours NUMBER;

l_str_Common VARCHAR2(2000);
l_errflag VARCHAR2(1) := 'N';
--------------------------- Variables which will hold the Balance Values.

BEGIN

hr_utility.set_location(' Entering PAY_IE_nes_REPORT_PKG.ARCHIVE_CODE: ',700);

hr_utility.set_location('p_assignment_action_id '||TO_CHAR(p_assactid),700);
OPEN cur_get_pactid(p_assactid);
FETCH cur_get_pactid INTO l_payroll_action_id,l_assignment_id,l_person_id;
CLOSE cur_get_pactid;

hr_utility.set_location('l_payroll_action_id '||TO_CHAR(l_payroll_action_id),700);
hr_utility.set_location('l_payroll_action_id '||TO_CHAR(l_assignment_id),700);
l_reference_date:=add_months(to_date('01'||'/'||g_month||'/'||g_year,'dd/mm/yyyy'),1)-1;

hr_utility.set_location('l_reference_date '|| l_reference_date,700);


/*6856473*/
hr_utility.set_location(' before calling get parameters ', 800);
hr_utility.set_location('Before get_all_parameters',501);
get_all_parameters(l_payroll_action_id
			,g_rep_group
			,g_payroll_id
			,g_year
			,g_quarter
			,g_month
			,g_sample_fraction
			,g_business_group_id
			,g_assignment_set_id
			,g_occupational_category
			,g_employer_id
			,g_report_type
			,g_declare_date
			,g_change_indicator
			,g_send_emp
			,g_comments);
hr_utility.set_location('after get_all_parameters',502);

OPEN cur_assignment_action(l_person_id,l_reference_date);
FETCH cur_assignment_action INTO l_ness_assignment_action;
CLOSE cur_assignment_action;

OPEN cur_assignment_action_ytd(l_person_id);
FETCH cur_assignment_action_ytd INTO l_ness_assignment_action_ytd;
CLOSE cur_assignment_action_ytd;
hr_utility.set_location(' l_ness_assignment_action  '|| l_ness_assignment_action, 801);
OPEN csr_hours_per_day(g_employer_id,g_business_group_id);
FETCH csr_hours_per_day INTO l_hours_per_day;
CLOSE csr_hours_per_day;

hr_utility.set_location(' AFTER  cursor csr_hours_per_day  '||l_hours_per_day, 801);

hr_utility.set_location(' Before  cursor cur_valid_asg  ', 801);
OPEN cur_valid_asg(l_assignment_id, l_person_id);
FETCH cur_valid_asg INTO l_valid_asg_rec;
CLOSE cur_valid_asg;
hr_utility.set_location(' after  cursor cur_valid_asg  ', 801);


IF l_ness_assignment_action IS NOT NULL
THEN
hr_utility.set_location(' Entered if condition  ', 801);

hr_utility.set_location('  Before cursor csr_input_value_id', 890);

OPEN csr_input_value_id('IE PRSI Detail','Contribution Class');
FETCH csr_input_value_id INTO l_input_value_id;
CLOSE csr_input_value_id;

OPEN csr_input_value_id('IE PRSI Detail','Subclass');
FETCH csr_input_value_id INTO l_input_value_id1;
CLOSE csr_input_value_id;

hr_utility.set_location('  after cursor csr_input_value_id', 890);
hr_utility.set_location('  l_input_value_id'|| l_input_value_id , 890);
hr_utility.set_location('  l_input_value_id1'|| l_input_value_id1 , 890);

hr_utility.set_location('  Before cursor csr_ness_action_details', 890);
OPEN csr_ness_action_details(l_ness_assignment_action);
FETCH csr_ness_action_details INTO l_ness_action_details;
CLOSE csr_ness_action_details;
hr_utility.set_location('  l_ness_action_details.date_earned'|| l_ness_action_details.date_earned, 890);
hr_utility.set_location('  after cursor csr_date_earned', 890);


l_prsi_class:= pay_ie_archive_detail_pkg.get_tax_details (
                                p_run_assignment_action_id => l_ness_assignment_action
                               ,p_input_value_id           => l_input_value_id
                               ,p_date_earned              => to_char(l_ness_action_details.date_earned, 'rrrr/mm/dd'));

l_prsi_subclass:= pay_ie_archive_detail_pkg.get_tax_details (
                                p_run_assignment_action_id => l_ness_assignment_action
                               ,p_input_value_id           => l_input_value_id1
                               ,p_date_earned              => to_char(l_ness_action_details.date_earned, 'rrrr/mm/dd'));

hr_utility.set_location('  l_prsi_class' || l_prsi_class, 890);
hr_utility.set_location('  l_prsi_subclass' || l_prsi_subclass, 890);
l_prsi_class := l_prsi_class||l_prsi_subclass;
hr_utility.set_location('  l_prsi_class' || l_prsi_class, 890);

OPEN csr_get_periods(g_reference_start_date,g_reference_end_date,l_ness_action_details.pact_id);
FETCH csr_get_periods INTO l_period_type,l_pay_periods;
CLOSE csr_get_periods;

hr_utility.set_location('  l_period_type' || l_period_type, 890);
hr_utility.set_location('  l_pay_periods' || l_pay_periods, 890);

IF l_period_type='Week' THEN
l_freq_pay:=1;
   IF l_pay_periods<=4 THEN
     l_ref_period_pay:=1;
   ELSIF l_pay_periods=5 THEN
     l_ref_period_pay:=3;
   END IF;

ELSIF l_period_type='Bi-Week' THEN
l_freq_pay:=2;
   IF l_pay_periods<=2 THEN
     l_ref_period_pay:=1;
   ELSIF l_pay_periods=3 THEN
     l_ref_period_pay:=4;
   END IF;
ELSIF l_period_type='Lunar Month' THEN
l_freq_pay:=3;
l_ref_period_pay:=1;
ELSIF l_period_type='Calendar Month' THEN
l_freq_pay:=4;
l_ref_period_pay:=2;
ELSIF l_period_type='Lunar Month' and l_pay_periods=5 THEN
l_freq_pay:=5;
l_ref_period_pay:=3;
END IF;

/*
IF l_ref_period_pay NOT in(1,2,3,4) THEN
l_ref_period_pay:=5;
END IF;
*/
		FOR bal_index IN 1..g_def_bal_id.COUNT
		LOOP
		hr_utility.set_location(' Enteredfor loop '||bal_index, 801);
		hr_utility.set_location(' before gloabnl tableand count  '|| to_char(g_def_bal_id.COUNT) , 801);
                hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '|| to_char(g_def_bal_id(bal_index).balance_name), 801);
	 	hr_utility.set_location(' g_def_bal_id(bal_index).defined_balance_id  '||to_char( g_def_bal_id(bal_index).defined_balance_id), 801);
		hr_utility.set_location(' before gloabnl table ', 801);

			IF g_def_bal_id(bal_index).balance_name   = 'Regular Earnings' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_regwg_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
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
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_irrb_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
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
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_ovrt_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
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
hr_utility.set_location(' l_ness_assignment_action '||l_ness_assignment_action, 850);

				l_othr_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action,
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
hr_utility.set_location(' l_ness_assignment_action '||l_ness_assignment_action, 850);





	IF(l_valid_asg_rec.hourly_or_salaried='S')
	THEN

		        IF(l_valid_asg_rec.frequency='D')
			THEN
			   IF l_period_type='Calendar Month' THEN
                               l_ref_period_hours:=1;
			       l_chrs_bal_val:=nvl(l_valid_asg_rec.normal_hours,0)*((g_reference_end_date - g_reference_start_date)+1);

                   hr_utility.set_location(' ((g_reference_end_date - g_reference_start_date)+1) '|| ((g_reference_end_date - g_reference_start_date)+1), 850);
			     ELSIF l_period_type='Week' THEN
                               l_ref_period_hours:=1;
			       l_chrs_bal_val:=nvl(l_valid_asg_rec.normal_hours,0)*7;
			     ELSIF l_period_type='Bi-Week' THEN
			       l_ref_period_hours:=1;
			       l_chrs_bal_val:=nvl(l_valid_asg_rec.normal_hours,0)*14;
			     ELSIF l_period_type='Lunar Month' THEN
                                l_ref_period_hours:=1;
				l_chrs_bal_val:=nvl(l_valid_asg_rec.normal_hours,0)*7*l_pay_periods;
			     END IF;

			ELSIF(l_valid_asg_rec.frequency='M')
			THEN
			     l_ref_period_hours:=2;
			     l_chrs_bal_val:=nvl(l_valid_asg_rec.normal_hours,0);

			ELSIF(l_valid_asg_rec.frequency='W')
			THEN
			     IF l_period_type='Calendar Month' THEN
                               l_ref_period_hours:=1;
			       l_chrs_bal_val:=nvl(l_valid_asg_rec.normal_hours,0)*4;
			     ELSIF l_period_type='Week' THEN
                               l_ref_period_hours:=1;
			       l_chrs_bal_val:=nvl(l_valid_asg_rec.normal_hours,0)*1;
			     ELSIF l_period_type='Bi-Week' THEN
			       l_ref_period_hours:=1;
			       l_chrs_bal_val:=nvl(l_valid_asg_rec.normal_hours,0)*2;
			     ELSIF l_period_type='Lunar Month' THEN
                                IF l_pay_periods=4 THEN
                                l_ref_period_hours:=1;
				ELSIF l_pay_periods=5 THEN
                                 l_ref_period_hours:=3;
				END IF;
				l_chrs_bal_val:=nvl(l_valid_asg_rec.normal_hours,0)*l_pay_periods;
			     END IF;

			ELSIF(l_valid_asg_rec.frequency='Y')
			THEN
			     l_chrs_bal_val:=(nvl(l_valid_asg_rec.normal_hours,0))/12;
                        END IF;
	      /* ELSE
	       l_errflag := 'Y';
               Fnd_file.put_line(FND_FILE.LOG,'Ensure that Normal hours value is not null at the assignment level of person'||p_person_id );
	       Raise l_nes_exception;
	       END IF;
	       */
	ELSE
				l_chrs_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
				l_ref_period_hours:=l_ref_period_pay;
       END IF;
hr_utility.set_location(' l_chrs_bal_val '|| l_chrs_bal_val, 850);
--Bug # 6774024
			ELSIF (g_def_bal_id(bal_index).balance_name   = 'Paid Maternity Hours') THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_mat_bal_val := nvl(l_mat_bal_val,0)
				+
				NVL(PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
							g_employer_id,
							null,
							null,
							null,
							null,
							null),0);

hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);

hr_utility.set_location(' l_mat_bal_val '|| l_mat_bal_val, 850);
			ELSIF (g_def_bal_id(bal_index).balance_name   = 'Paid Sick Leave Hours' ) THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_sic_bal_val :=
				nvl(l_sic_bal_val,0)
				+
				NVL(PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
							g_employer_id,
							null,
							null,
							null,
							null,
							null),0);

hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_sic_bal_val '|| l_sic_bal_val, 850);
			ELSIF (g_def_bal_id(bal_index).balance_name   = 'Paid Other Leave Hours' ) THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_otl_bal_val :=
				NVl(l_otl_bal_val,0)
				+
				NVL(PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
							g_employer_id,
							null,
							null,
							null,
							null,
							null),0);

hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_otl_bal_val '|| l_otl_bal_val, 850);

/*6856473 added checks for balances Paid Maternity Days, Paid Sick Leave Days and Paid Other Leave Days*/

                        ELSIF (g_def_bal_id(bal_index).balance_name   = 'Paid Maternity Days') THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_mat_bal_val :=
				nvl(l_mat_bal_val,0)
				+
				NVL(PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
							g_employer_id,
							null,
							null,
							null,
							null,
							null),0)*l_hours_per_day;

hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);

hr_utility.set_location(' l_mat_bal_val '|| l_mat_bal_val, 850);
			ELSIF ( g_def_bal_id(bal_index).balance_name   = 'Paid Sick Leave Days') THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_sic_bal_val :=
				nvl(l_sic_bal_val,0)
				+
				NVL(PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
							g_employer_id,
							null,
							null,
							null,
							null,
							null),0)*l_hours_per_day;
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_sic_bal_val '|| l_sic_bal_val, 850);
			ELSIF ( g_def_bal_id(bal_index).balance_name   = 'Paid Other Leave Days') THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_otl_bal_val :=
				nvl(l_otl_bal_val,0)
                                +
				NVL(PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
							g_employer_id,
							null,
							null,
							null,
							null,
							null),0)*l_hours_per_day
							;
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);

hr_utility.set_location(' l_otl_bal_val '|| l_otl_bal_val, 850);


			ELSIF g_def_bal_id(bal_index).balance_name  = 'Voluntary Sickness Insurance' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_vhi_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
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
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_hse_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
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
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_otben_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
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
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_ot_sub_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_ot_sub_bal_val '|| l_ot_sub_bal_val, 850);



			ELSIF g_def_bal_id(bal_index).balance_name  = 'IE BIK Company Vehicle' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_bik_veh_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);

hr_utility.set_location(' l_bik_veh_bal_val '|| l_bik_veh_bal_val, 850);



                     ELSIF g_def_bal_id(bal_index).balance_name   = 'IE PRSI Insurable Weeks' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_total_weeks :=
				nvl(l_total_weeks,0)
				+
				NVL(PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
							g_employer_id,
							null,
							null,
							null,
							null,
							null),0);
hr_utility.set_location(' l_total_weeks '|| l_total_weeks, 850);
                      ELSIF g_def_bal_id(bal_index).balance_name   = 'IE PRSI K Term Insurable Weeks' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_total_weeks :=
				nvl(l_total_weeks,0)
				+
				NVL(PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
							g_employer_id,
							null,
							null,
							null,
							null,
							null),0);
hr_utility.set_location(' l_total_weeks '|| l_total_weeks, 850);
                      ELSIF g_def_bal_id(bal_index).balance_name   = 'IE PRSI M Term Insurable Weeks' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_total_weeks :=
				nvl(l_total_weeks,0)
				+
				NVL(PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
							g_employer_id,
							null,
							null,
							null,
							null,
							null),0);
hr_utility.set_location(' l_total_weeks '|| l_total_weeks, 850);
                       ELSIF g_def_bal_id(bal_index).balance_name   = 'Regular EarningsMONTH' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action '||l_ness_assignment_action, 850);

				l_regwg_bal_val_ptd := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_regwg_bal_val_ptd '|| l_regwg_bal_val_ptd, 850);

			ELSIF g_def_bal_id(bal_index).balance_name   = 'Overtime PaymentsMONTH' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action '||l_ness_assignment_action, 850);

				l_ovrt_bal_val_ptd := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_ovrt_bal_val_ptd '|| l_ovrt_bal_val_ptd, 850);
                       ELSIF g_def_bal_id(bal_index).balance_name   = 'Regular Shift Allowance' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action '||l_ness_assignment_action, 850);

				l_reg_shft_allnce_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_reg_shft_allnce_bal_val '|| l_reg_shft_allnce_bal_val, 850);
                       ELSIF g_def_bal_id(bal_index).balance_name   = 'Irregular Shift Allowance' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action '||l_ness_assignment_action, 850);

				l_ireg_shft_allnce_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_ireg_shft_allnce_bal_val '|| l_ireg_shft_allnce_bal_val, 850);
                       ELSIF g_def_bal_id(bal_index).balance_name   = 'Paid Holiday Hours' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_holi_bal_val :=
				NVL(l_holi_bal_val,0)
				+
				NVL(PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
							g_employer_id,
							null,
							null,
							null,
							null,
							null),0);
hr_utility.set_location(' l_holi_bal_val '|| l_holi_bal_val, 850);
                      ELSIF g_def_bal_id(bal_index).balance_name   = 'Paid Holiday Days' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action_ytd '|| l_ness_assignment_action_ytd, 850);

				l_holi_bal_val :=
				NVL(l_holi_bal_val,0)
				+
				NVL(PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action_ytd,
							g_employer_id,
							null,
							null,
							null,
							null,
							null),0)*l_hours_per_day;
hr_utility.set_location(' l_holi_bal_val '|| l_holi_bal_val, 850);
                       ELSIF g_def_bal_id(bal_index).balance_name   = 'Total Commission' THEN

hr_utility.set_location(' Inside balance Loop ', 850);
hr_utility.set_location(' g_def_bal_id(bal_index).balance_name '||g_def_bal_id(bal_index).balance_name, 850);
hr_utility.set_location(' l_ness_assignment_action '||l_ness_assignment_action, 850);

				l_tot_comm_bal_val := PAY_BALANCE_PKG.GET_VALUE(g_def_bal_id(bal_index).defined_balance_id,
							l_ness_assignment_action,
							g_employer_id,
							null,
							null,
							null,
							null,
							null);
hr_utility.set_location(' l_tot_comm_bal_val '|| l_tot_comm_bal_val, 850);

			END IF;
		END LOOP;


       l_tot_shft_allnce_bal_val := NVL(l_reg_shft_allnce_bal_val,0) + NVL(l_ireg_shft_allnce_bal_val,0);


       l_ann_earning := NVL(l_regwg_bal_val,0) + NVL(l_irrb_bal_val,0) + NVL(l_ovrt_bal_val,0)
                      + NVL(l_bik_veh_bal_val,0) + NVL(l_vhi_bal_val,0) + NVL(l_hse_bal_val,0)
		      + NVL(l_otben_bal_val,0) + NVL(l_ot_sub_bal_val,0);

       l_ann_bik    :=	NVL(l_bik_veh_bal_val,0) + NVL(l_vhi_bal_val,0) + NVL(l_hse_bal_val,0)
		      + NVL(l_otben_bal_val,0) + NVL(l_ot_sub_bal_val,0);


       l_other_absence:= NVL(l_mat_bal_val,0) + NVL(l_sic_bal_val,0) + NVL(l_otl_bal_val,0);

       l_gross_earning:= NVL(l_regwg_bal_val_ptd,0) +  NVL(l_ovrt_bal_val_ptd,0)
                        + NVL(l_tot_shft_allnce_bal_val,0) + NVL(l_tot_comm_bal_val,0) ;



  END IF;



hr_utility.set_location(' VALUE OF EMP_CATG'||l_valid_asg_rec.EMP_CATG, 890);


OPEN csr_employee_details(l_person_id,g_archive_effective_date);
FETCH csr_employee_details INTO l_employee_details;
CLOSE csr_employee_details;

IF g_send_emp='Y' THEN

 hr_utility.set_location(' Before deleting the PL table pl_address. ',1100);
pl_address.delete;

pl_address(1) := l_employee_details.address_line1;
pl_address(2) := l_employee_details.address_line2;
pl_address(3) := l_employee_details.address_line3;
pl_address(4) := l_employee_details.City;
pl_address(5) := l_employee_details.COUNTY;
pl_address(6) := l_employee_details.Country;


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

    l_employee_details.address_line1:=NULL;
    l_employee_details.address_line2:=NULL;
    l_employee_details.address_line3:=NULL;
    l_employee_details.address_line4:=NULL;
    l_employee_details.address_line5:=NULL;

	  FOR l in 1..pl_address_final.LAST
	  LOOP
	hr_utility.set_location(' Inside the loop of PL table pl_address_final',1100);
	    BEGIN
		    IF l = 1 THEN
	hr_utility.set_location(' employee address .addr1 ',1100);
		     l_employee_details.address_line1 := pl_address_final(1);
	hr_utility.set_location('employee address .addr1 ',1101);
		    END IF;
		    --
		    IF l = 2 THEN
	hr_utility.set_location(' employee address.addr2 ',1102);
		     l_employee_details.address_line2 := pl_address_final(2);
	hr_utility.set_location(' employee address .addr2 ',1103);
		    END IF;
		    --
		    IF l = 3 THEN
	hr_utility.set_location(' employee address.addr3 ',1104);
		     l_employee_details.address_line3 := pl_address_final(3);
	hr_utility.set_location(' employee address .addr3 ',1105);
		    END IF;
		    --
		    IF l = 4 THEN
	hr_utility.set_location(' employee address.addr4 ',1106);
		     l_employee_details.address_line4 := pl_address_final(4);
	hr_utility.set_location(' employee address.addr5 ',1107);
		    END IF;
                    IF l = 5 THEN
	hr_utility.set_location(' employee address.addr5 ',1106);
		     l_employee_details.address_line5 := pl_address_final(5);
	hr_utility.set_location(' eemployee address.addr5',1107);
		    END IF;
	    EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		NULL;
	    END;
	  END LOOP;
  END IF;
  hr_utility.set_location(' After Re Initializing the cursor record l_person_details with actual values. ',1100);
 ELSE
    l_employee_details.address_line1:=NULL;
    l_employee_details.address_line2:=NULL;
    l_employee_details.address_line3:=NULL;
    l_employee_details.address_line4:=NULL;
    l_employee_details.address_line5:=NULL;

 END IF;

 IF (l_employee_details.PPS IS NULL) THEN
 l_id_reference:=l_valid_asg_rec.assignment_number;
 ELSE
 l_id_reference:=NULL;
 END IF;

 IF l_valid_asg_rec.EMP_CATG = 'F' THEN
 l_employement_type:=1;
 ELSIF l_valid_asg_rec.EMP_CATG = 'P' THEN
 l_employement_type:=2;
 ELSIF l_valid_asg_rec.EMP_CATG = 'AT' THEN
 l_employement_type:=3;
 END IF;
 hr_utility.set_location(' l_id_reference '|| l_id_reference,1100);
hr_utility.set_location(' Before Inserting in to IE_NES_EMPLOYEE_INFORMATION ', 890);
pay_action_information_api.create_action_information
    ( p_action_information_id => l_action_info_id
    ,p_action_context_id => p_assactid
    ,p_action_context_type => 'AAP'
    ,p_object_version_number => l_ovn
    ,p_effective_date => g_archive_effective_date --g_end_date
    ,p_source_id => NULL
    ,p_source_text => NULL
    ,p_action_information_category => 'IE_NES_EMPLOYEE_INFORMATION'
    ,p_action_information1  => l_employee_details.full_name   -- Full name
    ,p_action_information2  => l_employee_details.PPS    -- PPS
    ,p_action_information3  => substr(l_id_reference,1,9)   -- Reference id
    ,p_action_information4  => l_employee_details.address_line1    -- addressline_1
    ,p_action_information5  => l_employee_details.address_line2    -- addressline_2
    ,p_action_information6  => l_employee_details.address_line3    -- addressline_3
    ,p_action_information7  => l_employee_details.address_line4    -- addressline_4
    ,p_action_information8  => l_employee_details.address_line5    -- addressline_5

    );

hr_utility.set_location(' After Inserting in to IE_NES_EMPLOYEE_INFORMATION ', 890);


IF l_ann_earning < NVL(l_irrb_bal_val,0) + NVL(l_ann_bik,0) THEN
l_errflag := 'Y';
Fnd_file.put_line(FND_FILE.LOG,'The Annual Earnings is less than the sum of Irregular Bonuses and Annual Benefit In Kind for Assignment' ||l_assignment_id);
END IF;

IF l_gross_earning>0 and NVL(l_chrs_bal_val,0)<=0 THEN
l_errflag := 'Y';
Fnd_file.put_line(FND_FILE.LOG,'Paid Hours should be greater than Zero for Gross Earnings greater than Zero' || l_person_id);
END IF;

IF l_gross_earning=0 and NVL(l_chrs_bal_val,0)<>0 THEN
l_errflag := 'Y';
Fnd_file.put_line(FND_FILE.LOG,'Paid Hours should be Zero for Gross Earnings equal than Zero' || l_person_id);
END IF;

IF NVL(l_chrs_bal_val,0) < NVL(l_othr_bal_val,0) THEN
l_errflag := 'Y';
Fnd_file.put_line(FND_FILE.LOG,'Paid Hours should be greater than or equal to Overtime Hours' || l_person_id);
END IF;


IF l_gross_earning< NVL(l_tot_comm_bal_val,0) + NVL(l_tot_shft_allnce_bal_val,0) + NVL(l_ovrt_bal_val,0) THEN
Fnd_file.put_line(FND_FILE.LOG,'Gross Earnings must be greater than the sum of Total Commission, Shift Allowance and Overtime Earnings' ||l_assignment_id);
END IF;

-----------------------------------------------------

IF NVL(l_ovrt_bal_val_ptd,0)=0 and  NVL(l_othr_bal_val,0)<>0 THEN
l_errflag := 'Y';
Fnd_file.put_line(FND_FILE.LOG,'Overtime Hours should be zero for Overtime Earnings equal to 0' || l_person_id);
END IF;

IF NVL(l_ovrt_bal_val_ptd,0)>0 and  NVL(l_othr_bal_val,0)<=0 THEN
l_errflag := 'Y';
Fnd_file.put_line(FND_FILE.LOG,'Overtime Hours should be greater than zero for Overtime Earnings greater than 0' || l_person_id);
END IF;

IF NVL(l_ovrt_bal_val_ptd,0)<=0 and  NVL(l_othr_bal_val,0)>0 THEN
l_errflag := 'Y';
Fnd_file.put_line(FND_FILE.LOG,'Overtime Earnings should be greater than zero for Overtime Hours greater than 0' || l_person_id);
END IF;


hr_utility.set_location(' Before Inserting in to IE_NES_PART1 ', 890);
pay_action_information_api.create_action_information
    ( p_action_information_id => l_action_info_id
    ,p_action_context_id => p_assactid
    ,p_action_context_type => 'AAP'
    ,p_object_version_number => l_ovn
    ,p_effective_date => g_archive_effective_date --g_end_date
    ,p_source_id => NULL
    ,p_source_text => NULL
    ,p_action_information_category => 'IE_NES_PART1'
    ,p_action_information1  => lpad(round(l_ann_earning),7,0)   -- Annual Earnings (l_regwg_bal_val+l_irrb_bal_val+l_ovrt_bal_val+l_bik_veh_bal_val+l_vhi_bal_val+l_hse_bal_val+l_otben_bal_val+l_ot_sub_bal_val)
    ,p_action_information2  => lpad(round(l_irrb_bal_val),7,0)   -- irregular bonuses (l_irrb_bal_val)
    ,p_action_information3  => lpad(round(l_ann_bik),7,0)   -- Annual Benefit in Kind( l_bik_veh_bal_val+l_vhi_bal_val+l_hse_bal_val+l_otben_bal_val+l_ot_sub_bal_val)
    ,p_action_information4  => lpad(l_total_weeks,2,0)   -- NO of Weeks ( sum of IE PRSI Insurable Weeks + IE PRSI K Term Insurable Weeks + IE PRSI M Term Insurable Weeks)
    ,p_action_information5 => lpad(to_char(to_number(l_holi_bal_val),'FM999D0'),5,0)  -- Paid Holidays
    ,p_action_information6 => lpad(to_char(to_number(l_other_absence),'FM999D0'),5,0) -- Other Absence (l_mat_bal_val + l_sic_bal_val + l_otl_bal_val)
    ,p_action_information7 => l_employement_type    -- Employment Type
    ,p_action_information8 => l_freq_pay    -- Frequency Pay
    ,p_action_information9 => l_ref_period_pay    -- Ref Period pay
    ,p_action_information10 => l_valid_asg_rec.status_code   -- Status Code (l_valid_asg_rec.status_code)
    ,p_action_information11 => lpad(round(l_gross_earning),6,0)       -- Gross Earnings( l_regwg_bal_val_ptd +  l_ovrt_bal_val_ptd + l_reg_shft_allnce_bal_val + l_ireg_shft_allnce_bal_val)
    ,p_action_information12 => lpad(round(l_ovrt_bal_val_ptd),6,0)        -- Overtime Earnings( l_ovrt_bal_val )
    ,p_action_information13 => lpad(round(l_tot_shft_allnce_bal_val),6,0)   -- Shift allowance (l_reg_shft_allnce_bal_val + l_ireg_shft_allnce_bal_val)
    ,p_action_information14 => lpad(round(l_tot_comm_bal_val),6,0)   -- Total Commission (l_regwg_bal_val + l_reg_shft_allnce_bal_val)
    ,p_action_information15 => l_prsi_class          -- PRSI Class
    ,p_action_information16 => l_ref_period_hours   -- Ref Period Hours
    ,p_action_information17 => lpad(to_char(to_number(l_chrs_bal_val),'FM999D0'),5,0) -- Contracted Hours (l_chrs_bal_val)
    ,p_action_information18 => lpad(to_char(to_number(l_othr_bal_val),'FM999D0'),5,0) -- Overtime Hours (l_othr_bal_val)
    );
hr_utility.set_location(' After Inserting in to IE_NES_PART1 ', 890);




l_str_common := 'The report completed with validation warning(s). Do not submit the generated XML file '
		    ||'as it may not be in the correct format. You can, however, modify and use the template output.';

IF l_errflag = 'Y' THEN
   Fnd_file.put_line(FND_FILE.LOG,l_str_common);
   error_message := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',
			  'NES Report completed with validation warning(s).');
END IF;


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
Hr_Utility.set_location('Entering: PAY_IE_NES_REPORT_PKG.c2b',1000);
DBMS_LOB.createTemporary( res, TRUE );
DBMS_LOB.OPEN( res, DBMS_LOB.LOB_ReadWrite );


LOOP
buffer := UTL_RAW.cast_to_raw( DBMS_LOB.SUBSTR( c, 16000, pos ) );

IF UTL_RAW.LENGTH( buffer ) > 0 THEN
DBMS_LOB.writeAppend( res, UTL_RAW.LENGTH( buffer ), buffer );
END IF;

pos := pos +  16000;
EXIT WHEN pos > lob_len;
END LOOP;

Hr_Utility.set_location('Leaving: PAY_IE_NES_REPORT_PKG.c2b',1010);
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

l_buf  VARCHAR2(2000);
l_proc VARCHAR2(100);

l_person_id per_all_people_f.person_id%TYPE;
l_assignment_id per_all_assignments_f.assignment_id%TYPE;
l_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE;
l_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE;

cursor csr_nes_emp_info (c_pact_id NUMBER) IS
SELECT
	action_information1 full_name,
	action_information2 ppsn,
	action_information3 reference_id,
	action_information4 address_line1,
	action_information5 address_line2,
	action_information6 address_line3,
	action_information7 address_line4,
	action_information8 address_line5

	FROM    pay_action_information
	WHERE   action_context_id = c_pact_id
	AND     action_context_type = 'AAP'
	AND     action_information_category ='IE_NES_EMPLOYEE_INFORMATION';


cursor csr_nes_part1 (c_pact_id NUMBER) IS
SELECT
	NVL(action_information1,0) annual_earning,
	NVL(action_information2,0) irreg_earning,
	NVL(action_information3,0) annual_bik,
	NVL(action_information4,0) no_of_weeks,
	NVL(action_information5,0) paid_holiday,
	NVL(action_information6,0) other_absence,
	NVL(action_information7,0) employment_type,
	NVL(action_information8,0) freq_pay,
	NVL(action_information9,0) ref_period_pay,
	NVL(action_information10,0) status_code,
	NVL(action_information11,0) gross_earning,
	NVL(action_information12,0) overtime_earning,
	NVL(action_information13,0) shift_allowance,
	NVL(action_information14,0) total_commission,
	NVL(action_information15,0) prsi_class,
	NVL(action_information16,0) ref_period_hours,
	NVL(action_information17,0) contracted_hours,
	NVL(action_information18,0) overtime_hours
	FROM    pay_action_information
	WHERE   action_context_id = c_pact_id
	AND     action_context_type = 'AAP'
	AND     action_information_category ='IE_NES_PART1';

l_csr_nes_emp_info csr_nes_emp_info%ROWTYPE;
l_csr_nes_part1 csr_nes_part1%ROWTYPE;


BEGIN
hr_utility.set_location(' Entering: PAY_IE_NES_REPORT_PKG.gen_body_xml: ', 2000);

l_payroll_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
l_assignment_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID');

OPEN csr_nes_emp_info(l_assignment_action_id);
FETCH csr_nes_emp_info INTO l_csr_nes_emp_info;
CLOSE csr_nes_emp_info;

OPEN csr_nes_part1(l_assignment_action_id);
FETCH csr_nes_part1 INTO l_csr_nes_part1;
CLOSE csr_nes_part1;

l_string := l_string || '<Data>'||EOL ;
l_string := l_string || ' <Full_Name>'|| l_csr_nes_emp_info.full_name ||'</Full_Name>' ;
l_string := l_string || ' <PPS>'|| l_csr_nes_emp_info.ppsn ||'</PPS>' ;
l_string := l_string || ' <Id_Reference>'|| l_csr_nes_emp_info.reference_id ||'</Id_Reference>' ;
l_string := l_string || ' <Annual_Earnings>'|| l_csr_nes_part1.annual_earning ||'</Annual_Earnings>' ;
l_string := l_string || ' <Irregular_Bonuses>'|| l_csr_nes_part1.irreg_earning ||'</Irregular_Bonuses>' ;
l_string := l_string || ' <Annual_Benefit_In_Kind>'|| l_csr_nes_part1.annual_bik ||'</Annual_Benefit_In_Kind>' ;
l_string := l_string || ' <No_Of_Weeks>'|| l_csr_nes_part1.no_of_weeks ||'</No_Of_Weeks>' ;
l_string := l_string || ' <Paid_Holidays>'|| l_csr_nes_part1.paid_holiday ||'</Paid_Holidays>' ;
l_string := l_string || ' <Other_Absence>'|| l_csr_nes_part1.other_absence ||'</Other_Absence>' ;
l_string := l_string || ' <Employment_Type>'|| l_csr_nes_part1.employment_type ||'</Employment_Type>' ;
l_string := l_string || ' <Frequency_Pay>'|| l_csr_nes_part1.freq_pay ||'</Frequency_Pay>' ;
l_string := l_string || ' <Ref_Period_Pay>'|| l_csr_nes_part1.ref_period_pay ||'</Ref_Period_Pay>' ;
l_string := l_string || ' <Status_Code>'|| l_csr_nes_part1.status_code ||'</Status_Code>' ;
l_string := l_string || ' <Gross_Earnings>'|| l_csr_nes_part1.gross_earning ||'</Gross_Earnings>' ;
l_string := l_string || ' <Overtime_Earnings>'|| l_csr_nes_part1.overtime_earning ||'</Overtime_Earnings>' ;
l_string := l_string || ' <Shift_Allowance>'|| l_csr_nes_part1.shift_allowance ||'</Shift_Allowance>' ;
l_string := l_string || ' <Total_Commission>'|| l_csr_nes_part1.total_commission ||'</Total_Commission>' ;
l_string := l_string || ' <PRSI_Class>'|| l_csr_nes_part1.prsi_class ||'</PRSI_Class>' ;
l_string := l_string || ' <Ref_Period_Hours>'|| l_csr_nes_part1.ref_period_hours ||'</Ref_Period_Hours>' ;
l_string := l_string || ' <Contracted_Hours>'|| l_csr_nes_part1.contracted_hours ||'</Contracted_Hours>' ;
l_string := l_string || ' <Overtime_Hours>'|| l_csr_nes_part1.overtime_hours ||'</Overtime_Hours>' ;
l_string := l_string || ' <Addr1_Employee >'|| l_csr_nes_emp_info.address_line1 ||'</Addr1_Employee >' ;
l_string := l_string || ' <Addr2_Employee >'|| l_csr_nes_emp_info.address_line2 ||'</Addr2_Employee >' ;
l_string := l_string || ' <Addr3_Employee >'|| l_csr_nes_emp_info.address_line3 ||'</Addr3_Employee >' ;
l_string := l_string || ' <Addr4_Employee >'|| l_csr_nes_emp_info.address_line4 ||'</Addr4_Employee >' ;
l_string := l_string || ' <Addr5_Employee >'|| l_csr_nes_emp_info.address_line5 ||'</Addr5_Employee >' ;
l_string := l_string ||'</Data>'||EOL ;

l_clob := l_clob||l_string;
	IF l_clob IS NOT NULL THEN
	  l_blob := c2b(l_clob);
	  pay_core_files.write_to_magtape_lob(l_blob);
	END IF;

hr_utility.set_location(' Leaving: PAY_IE_NES_REPORT_PKG.gen_body_xml: ', 2040);

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
	action_information7 month,
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
	AND     action_information_category ='IE_NES_HEADER';

	CURSOR c_total_sample(c_pact_id NUMBER) IS
	SELECT count(*)
	FROM pay_assignment_actions paa,
	     pay_action_information pai
        WHERE paa.payroll_action_id=c_pact_id
	  AND paa.source_action_id is null
	  AND pai.action_context_id=paa.assignment_action_id
	  AND pai.action_information_category='IE_NES_PART1';

	l_header c_get_header%rowtype;
	l_payroll_action_id number;
	l_total_sample NUMBER(10);

BEGIN
	l_proc := g_package || 'gen_header_xml';
	hr_utility.set_location ('Entering '||l_proc,1500);

	l_payroll_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
	hr_utility.set_location('Inside PAY_IE_NES_REPORT_PKG.gen_header_xml,l_payroll_action_id: '||l_payroll_action_id,300);

	OPEN c_get_header(l_payroll_action_id);
	FETCH c_get_header into l_header;
	CLOSE c_get_header;

	OPEN c_total_sample(l_payroll_action_id);
	FETCH c_total_sample INTO l_total_sample;
	CLOSE c_total_sample;
	l_string := l_string || '<NES' ;
	l_string := l_string || ' Yr="'|| l_header.year ||'"';
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
	l_string := l_string || ' <Total_Sample>'|| l_total_sample ||'</Total_Sample>' ;
	l_string := l_string ||'</Company>'||EOL ;

      l_string := l_string || '<Declaration>'||EOL ;
   	l_string := l_string || ' <Contact>'|| substr(l_header.declarant_name,1,40) ||'</Contact>';
	l_string := l_string || ' <Phone>'|| substr(l_header.declarant_phone,1,14) ||'</Phone>' ;
	l_string := l_string || ' <Email>'|| substr(l_header.declarant_email,1,80) ||'</Email>';
	l_string := l_string || ' <Date>'|| to_char(fnd_date.canonical_to_date(l_header.declare_date),'DDMMYYYY') ||'</Date>';
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

begin
l_string:=l_string || '<Comment>' || '<![CDATA[' || g_comments || ']]>' || '</Comment>';
l_string := l_string ||'</NES>'||EOL ;

l_clob := l_clob||l_string;

IF l_clob IS NOT NULL THEN
	l_blob := c2b(l_clob);
	pay_core_files.write_to_magtape_lob(l_blob);
END IF;

EXCEPTION
WHEN Others THEN
Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1214);
l_string := l_string ||'</NES>'||EOL ;
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
 l_procedure_name   VARCHAR2(100):='denit';

begin

 hr_utility.set_location('before the  call of setup_balance_table in  '||l_procedure_name, 320);
  setup_balance_table;

 hr_utility.set_location('After the call of setup_balance_table in '||l_procedure_name, 320);
end archive_deinit;
END PAY_IE_NES_REPORT_PKG;

/
