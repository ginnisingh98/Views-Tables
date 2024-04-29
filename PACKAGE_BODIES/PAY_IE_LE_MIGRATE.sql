--------------------------------------------------------
--  DDL for Package Body PAY_IE_LE_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_LE_MIGRATE" AS
/* $Header: pyiemigr.pkb 120.6 2006/01/20 01:05:20 sgajula noship $ */
TYPE balance_rec IS RECORD (
  old_defined_balance_id   NUMBER,
  new_defined_balance_id   NUMBER,
  balance_name             VARCHAR2(150)
                           );

TYPE balance_table   IS TABLE OF balance_rec   INDEX BY BINARY_INTEGER;
g_statutory_balance_table         balance_table;
g_max_balance_index NUMBER := 8;
l_asg_found  varchar2(1) := 'N';
l_stage varchar2(300);

PROCEDURE revert_migration(p_bg_id IN NUMBER) IS
CURSOR c_get_org_details(l_bg_id NUMBER) IS
SELECT hou.name,
       hou.date_from,
       hou.date_to,
       hou.internal_external_flag,
       hoi.*,
       decode(hoi.org_information11,'YY','YY'
                                   ,'Y','YN',
                                   'YYY','YYY'
                                   ,'NN') migrated_flag
FROM   hr_organization_units hou,
       hr_organization_information hoi
WHERE hou.organization_id = l_bg_id
AND   hoi.organization_id = hou.organization_id
AND   hoi.org_information_context = 'IE_ORG_INFORMATION'
AND   NVL(hoi.org_information11,'NN') <> 'NN';

CURSOR c_get_er_details(l_bg_id NUMBER,l_name VARCHAR2) IS
SELECT hou.organization_id,hou.name
FROM   hr_organization_units hou
      ,hr_organization_information hoi1
      ,hr_organization_information hoi2
WHERE  hou.organization_id = hoi1.organization_id
AND    hou.organization_id = hoi2.organization_id
AND    hou.business_group_id = l_bg_id
AND    hoi1.org_information_context  = 'CLASS'
AND    hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
AND    hoi1.org_information2 = 'Y'
AND    hoi2.org_information_context  = 'IE_EMPLOYER_INFO'
AND    hou.name = l_name;


-- Cursor to fetch all the assignment actions in 2005
CURSOR c_get_asg_action(p_bg_id NUMBER,p_tax_unit_id NUMBER) IS
SELECT paa.*,ppa.action_type action_type,ppa.effective_date effective_date,
       ppa.report_type,ppa.report_qualifier
FROM   pay_assignment_actions paa,
       pay_payroll_actions ppa
WHERE  paa.payroll_action_id = ppa.payroll_action_id
AND    paa.action_status = 'C'
AND    ppa.business_group_id = p_bg_id
AND    ppa.action_type in ('R','Q','P','U','I','B','V','X')
AND    (ppa.action_type <> 'X' OR ppa.report_type <> 'P45')
AND to_char(ppa.effective_date,'YYYY') = 2005
AND paa.tax_unit_id = p_tax_unit_id;

-- Procedure for Migrating Assignment action info to be striped by Tax unit ID and Update
-- Action Information PER_YTD with _PER_PAYE_REF_YTD due to bug 4655083
-- Cursor to fetch assignment actions for a payroll

CURSOR c_get_def_bal(p_balance_name VARCHAR2) IS
SELECT def_old.defined_balance_id old_id
      ,def_new.defined_balance_id new_id
  FROM pay_balance_types pbt
      ,pay_balance_dimensions dim_old
      ,pay_balance_dimensions dim_new
      ,pay_defined_balances def_old
      ,pay_defined_balances def_new
WHERE pbt.balance_name = p_balance_name
 AND  dim_old.database_item_suffix = '_PER_PAYE_REF_YTD'
 AND  dim_old.legislation_code = 'IE'
 AND  dim_new.legislation_code = 'IE'
 AND  dim_new.database_item_suffix = '_PER_YTD'
 AND  pbt.legislation_code = 'IE'
 AND  def_old.balance_type_id = pbt.balance_type_id
 AND  def_old.balance_dimension_id = dim_old.balance_dimension_id
 AND  def_new.balance_type_id = pbt.balance_type_id
 AND  def_new.balance_dimension_id = dim_new.balance_dimension_id;

-- Cursor to fetch the Action Information Details
CURSOR c_get_act_info(p_context_id NUMBER,p_defbal_id NUMBER) IS
SELECT pai.action_information_id,pai.object_version_number,pai.source_id,pai.action_information4
FROM  pay_action_information pai
WHERE pai.action_context_id = p_context_id
  AND pai.action_information1 = p_defbal_id
  AND pai.action_context_type = 'AAP'
  AND pai.action_information_category = 'EMEA BALANCES';
l_old_id NUMBER;
l_new_id NUMBER;
l_act_info_id NUMBER;
l_ovn NUMBER;
l_source_id NUMBER;
l_value NUMBER;
l_old_value VARCHAR2(50);
l_object_version_number NUMBER;

begin

-- Setup the balance Table
g_statutory_balance_table(1).balance_name := 'IE Taxable Pay';
g_statutory_balance_table(2).balance_name := 'IE Net Tax';
g_statutory_balance_table(3).balance_name := 'IE PRSI Employee';
g_statutory_balance_table(4).balance_name := 'IE PRSI K Employee Lump Sum';
g_statutory_balance_table(5).balance_name := 'IE PRSI M Employee Lump Sum';
g_statutory_balance_table(6).balance_name := 'IE PRSI Employer';
g_statutory_balance_table(7).balance_name := 'IE PRSI K Employer Lump Sum';
g_statutory_balance_table(8).balance_name := 'IE PRSI M Employer Lump Sum';

FOR l_index in 1 .. g_max_balance_index LOOP
l_old_id := NULL;
l_new_id := NULL;

 OPEN c_get_def_bal(g_statutory_balance_table(l_index).balance_name);
 FETCH c_get_def_bal INTO l_old_id,l_new_id;
 g_statutory_balance_table(l_index).old_defined_balance_id := l_old_id;
 g_statutory_balance_table(l_index).new_defined_balance_id := l_new_id;
 CLOSE c_get_def_bal;

END LOOP;
-- Balance setup ends here


FOR v_er_bg in c_get_org_details(p_bg_id) LOOP
  FOR v_er_le in c_get_er_details(p_bg_id,v_er_bg.org_information8) LOOP

      FOR v_assact IN c_get_asg_action(p_bg_id,v_er_le.organization_id)       LOOP

      	  UPDATE pay_assignment_actions paa
      	  SET tax_unit_id = NULL
      	  WHERE paa.assignment_action_id = v_assact.assignment_action_id;


      	  IF (v_assact.report_type = 'IEPS' AND v_assact.report_qualifier = 'IE'
      	      AND v_assact.source_action_id IS NULL) THEN



	     FOR l_index in 1 .. g_max_balance_index LOOP
	       l_act_info_id := NULL;
	       l_ovn := NULL;
	       l_source_id := NULL;
	       l_value := 0;
	       OPEN c_get_act_info(v_assact.assignment_action_id,g_statutory_balance_table(l_index).old_defined_balance_id);
	       FETCH c_get_act_info INTO l_act_info_id,l_ovn,l_source_id,l_old_value;
	       CLOSE c_get_act_info;
	       IF l_act_info_id IS NOT NULL THEN
	        l_value := pay_balance_pkg.get_value(g_statutory_balance_table(l_index).new_defined_balance_id,
	                                             l_source_id,v_er_le.organization_id,NULL,NULL,NULL,NULL,NULL);
	        IF l_value <> 0 THEN
			pay_action_information_api.update_action_information
					   (p_action_information_id => l_act_info_id
					    ,p_object_version_number => l_ovn
					    ,p_action_information1  => g_statutory_balance_table(l_index).new_defined_balance_id
					    ,p_action_information4  => fnd_number.number_to_canonical(l_value)
					   );

	        END IF;

	       END IF;
	     END LOOP;
      	  END IF;

  END LOOP;

  BEGIN
      l_object_version_number := v_er_bg.object_version_number;
        HR_ORGanization_api.update_org_information
          (
            p_validate                => FALSE,
            p_effective_date          => sysdate,
            p_org_information_id      => v_er_bg.org_information_id,
            p_org_info_type_code      => 'IE_ORG_INFORMATION',
            p_org_information2        => v_er_bg.org_information2,
            p_org_information11       => 'Y',
            p_object_version_number   => l_object_version_number
          );
    EXCEPTION
      WHEN OTHERS
       THEN
       ROLLBACK;
     raise_application_error(-20001, sqlerrm);
    END;

COMMIT;
END LOOP;
END LOOP;
END revert_migration;

PROCEDURE migrate_asg_act_actinfo_tu(p_bg_id NUMBER,p_org_id NUMBER,p_payroll_id NUMBER,p_start_date DATE,p_end_date DATE,p_migrate_archive_data varchar2,p_p45_migrated NUMBER) IS

-- Cursor to fetch all the assignment actions in 2005
CURSOR c_get_asg_action(p_bg_id NUMBER,p_payroll_id NUMBER,p_start_date DATE,p_end_date DATE) IS
SELECT distinct paa.*,ppa.action_type action_type,ppa.effective_date effective_date,
       ppa.report_type,ppa.report_qualifier,asg.person_id person_id
FROM   pay_assignment_actions paa,
       pay_payroll_actions ppa,
       per_all_assignments_f asg
WHERE  paa.payroll_action_id = ppa.payroll_action_id
AND    paa.action_status = 'C'
AND    ppa.effective_date between p_start_date and p_end_date
AND    paa.assignment_id = asg.assignment_id
--AND    ppa.effective_date between asg.effective_start_date and asg.effective_end_date
AND    asg.payroll_id = p_payroll_id
AND    ppa.business_group_id = p_bg_id
AND    (
         (p_migrate_archive_data = 'N' and ppa.action_type in ('R','Q','P','U','I','B','V')) or
         (p_migrate_archive_data = 'Y' and ppa.action_type in ('R','Q','P','U','I','B','V','X'))
       )
-- AND    ppa.action_type in ('R','Q','P','U','I','B','V','X')
AND    (ppa.action_type <> 'X' OR ppa.report_type <> 'P45' OR p_p45_migrated = 1)
AND to_char(ppa.effective_date,'YYYY') = 2005
AND paa.tax_unit_id IS NULL
ORDER BY ppa.action_type ASC,
         ppa.report_qualifier,
         ppa.report_type,
         paa.assignment_id,
         paa.assignment_action_id DESC;

-- Cursor to fetch the Action Information Details
CURSOR c_get_act_info(p_context_id NUMBER,p_defbal_id NUMBER) IS
SELECT pai.action_information_id,pai.object_version_number,pai.source_id,pai.action_information4
FROM  pay_action_information pai
WHERE pai.action_context_id = p_context_id
  AND pai.action_information1 = p_defbal_id
  AND pai.action_context_type = 'AAP'
  AND pai.action_information_category = 'EMEA BALANCES';

-- Cursor to fetch the action information details
CURSOR c_get_action_info(p_asg_action_id NUMBER,p_act_info_cat VARCHAR2) IS
SELECT pai.action_information_id,pai.object_version_number
 FROM  pay_action_information pai
WHERE  pai.action_context_id = p_asg_action_id
  AND  pai.action_information_category = p_act_info_cat;

-- Cursor to fetch the Commencement Date of the Employee
CURSOR c_get_comm_date(p_asg_action_id NUMBER) IS
SELECT act_inf.action_information11
FROM   pay_action_information act_inf
WHERE  act_inf.action_context_id = p_asg_action_id
AND    act_inf.action_information_category = 'EMPLOYEE DETAILS'
AND    act_inf.action_context_type = 'AAP';


l_asg_id NUMBER := -1;
l_act_info_id NUMBER;
l_ovn NUMBER;
l_source_id NUMBER;
l_value NUMBER;
l_old_value VARCHAR2(50);
l_object_version_number NUMBER;
l_comm_date VARCHAR2(30);

BEGIN
      for v_assact IN c_get_asg_action(p_bg_id,
                                       p_payroll_id,
                                       p_start_date,
                                       p_end_date
                                      )       LOOP

          IF l_asg_found = 'N' THEN
	  fnd_file.put_line(FND_FILE.LOG,'                                                     ');
	  fnd_file.put_line(FND_FILE.LOG,'                                                     ');
          fnd_file.put_line(FND_FILE.LOG,'Assignment Action Migartion Details');
          fnd_file.put_line(FND_FILE.LOG,'                                                     ');
          fnd_file.put_line(FND_FILE.LOG,rpad(lpad('Assignment ID',14),16)||'        '||'Action Type'||'      '||'Effective Date'||'      '||'Report Type');
            l_asg_found := 'Y';
          END IF;

          l_stage := 'Update Asg Action' || v_assact.assignment_action_id;
          fnd_file.put_line(FND_FILE.LOG,rpad(lpad(v_assact.assignment_id,11),16)||'        '||rpad(lpad(v_assact.action_type,6),11)||'      '||rpad(lpad(v_assact.effective_date,11),14)||'      '||rpad(lpad(v_assact.report_type,8),11));
         -- Update the assignment actions
      	  UPDATE pay_assignment_actions paa
      	  SET tax_unit_id = p_org_id
      	  WHERE paa.assignment_action_id = v_assact.assignment_action_id;

       IF (v_assact.report_type = 'P45' AND v_assact.report_qualifier = 'IE' AND v_assact.source_action_id IS NULL) THEN
         FOR v_get_act_info IN c_get_action_info(v_assact.assignment_action_id,'IE EMPLOYEE DETAILS') LOOP
                l_object_version_number := v_get_act_info.object_version_number;
                l_act_info_id := v_get_act_info.action_information_id;
                l_comm_date := NULL;

                OPEN c_get_comm_date(v_assact.assignment_action_id);
                FETCH c_get_comm_date INTO l_comm_date;
                CLOSE c_get_comm_date;

                IF l_comm_date IS NOT NULL THEN

          l_stage := 'Update Employee Details' || v_assact.assignment_action_id || ' date '|| l_comm_date;
          fnd_file.put_line(FND_FILE.LOG,'Updating Commencement Date to '||l_comm_date);
			pay_action_information_api.update_action_information
					   (p_action_information_id => l_act_info_id
					    ,p_object_version_number => l_object_version_number
					    ,p_action_information30  => l_comm_date
					   );
                END IF;
        END LOOP;

             FOR v_get_act_info IN c_get_action_info(v_assact.assignment_action_id,'IE P45 INFORMATION') LOOP
                l_object_version_number := v_get_act_info.object_version_number;
                l_act_info_id := v_get_act_info.action_information_id;

	              l_stage := 'Update P45 Information' || v_assact.assignment_action_id || ' person '|| v_assact.person_id;
	                        fnd_file.put_line(FND_FILE.LOG,'Updating Person ID to '||v_assact.person_id);
			pay_action_information_api.update_action_information
					   (p_action_information_id => l_act_info_id
					    ,p_object_version_number => l_object_version_number
					    ,p_action_information8  => v_assact.person_id
					   );

             END LOOP;


      END IF;
      	  IF (v_assact.report_type = 'IEPS' AND v_assact.report_qualifier = 'IE'
      	      AND v_assact.source_action_id IS NULL) THEN
      	    IF v_assact.assignment_id <> l_asg_id THEN
             l_stage := 'Update Action Information' || v_assact.assignment_action_id;

	     FOR l_index in 1 .. g_max_balance_index LOOP
	       l_act_info_id := NULL;
	       l_ovn := NULL;
	       l_source_id := NULL;
	       l_value := 0;

	       OPEN c_get_act_info(v_assact.assignment_action_id,g_statutory_balance_table(l_index).old_defined_balance_id);
	       FETCH c_get_act_info INTO l_act_info_id,l_ovn,l_source_id,l_old_value;
	       CLOSE c_get_act_info;

	       IF l_act_info_id IS NOT NULL THEN
	        l_value := pay_balance_pkg.get_value(g_statutory_balance_table(l_index).new_defined_balance_id,
	                                             l_source_id,p_org_id,NULL,NULL,NULL,NULL,NULL);
	        IF l_value <> 0 THEN
			pay_action_information_api.update_action_information
					   (p_action_information_id => l_act_info_id
					    ,p_object_version_number => l_ovn
					    ,p_action_information1  => g_statutory_balance_table(l_index).new_defined_balance_id
					    ,p_action_information4  => fnd_number.number_to_canonical(l_value)
					   );
fnd_file.put_line(FND_FILE.LOG,'Updating Balance '|| g_statutory_balance_table(l_index).balance_name || ' with value ='|| fnd_number.number_to_canonical(l_value) || ' from Old Value '|| l_old_value ||' Asg action = '|| v_assact.assignment_action_id);

	        END IF;

	       END IF;

	     END LOOP;

      	    END IF;


      	    l_asg_id := v_assact.assignment_id;

      	  END IF;
      END LOOP;

END migrate_asg_act_actinfo_tu;

PROCEDURE migrate_data(errbuf OUT NOCOPY VARCHAR2,
                       retcode OUT NOCOPY VARCHAR2,
                       p_bg_id IN NUMBER) IS

/* Cursor Fetch Non-Migrated Employer Details defined at BG Level */
CURSOR c_get_org_details(l_bg_id NUMBER,l_p45_migrated NUMBER) IS
SELECT hou.name,
       hou.date_from,
       hou.date_to,
       hou.internal_external_flag,
       hoi.*,
       decode(hoi.org_information11,'YY','YY'
                                   ,'Y','YN',
                                   'YYY','YYY'
                                   ,'NN') migrated_flag
FROM   hr_organization_units hou,
       hr_organization_information hoi
WHERE hou.organization_id = l_bg_id
AND   hoi.organization_id = hou.organization_id
AND   hoi.org_information_context = 'IE_ORG_INFORMATION'
AND  (
      ( nvl(hoi.org_information11,'NN') <> 'YY' AND l_p45_migrated = 0) OR
      ( nvl(hoi.org_information11,'NN') <> 'YYY' AND l_p45_migrated = 1)
     );

-- Cursor to fetch date-tracked payroll records for an Employer
CURSOR c_get_payroll_details(p_bg_id NUMBER,p_tax_ref VARCHAR2,p_paye_ref VARCHAR2) IS
 SELECT scl.id_flex_num id_flex_num,scl.segment2 segment2,
        scl.segment1 segment1,scl.segment3 segment3,
        pap.*
 FROM   pay_all_payrolls_f pap,
        hr_soft_coding_keyflex scl
 WHERE  pap.business_group_id = p_bg_id
 AND    pap.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
 AND    scl.segment1 = p_tax_ref
 AND    scl.segment3 = p_paye_ref
 AND    scl.segment4 IS NULL;

/* Cursor to fetch the migrated employers in the bg */
CURSOR c_get_er_details(l_bg_id number,l_name varchar2) IS
SELECT hou.organization_id,hou.name
FROM   hr_organization_units hou
      ,hr_organization_information hoi1
      ,hr_organization_information hoi2
WHERE  hou.organization_id = hoi1.organization_id
AND    hou.organization_id = hoi2.organization_id
AND    hou.business_group_id = l_bg_id
AND    hoi1.org_information_context  = 'CLASS'
AND    hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
AND    hoi1.org_information2 = 'Y'
AND    hoi2.org_information_context  = 'IE_EMPLOYER_INFO'
AND    hou.name = l_name;

-- Cursor to fetch non-migrated P45 actions
CURSOR c_get_prl_p35_details(p_bg_id number,p_tax_unit_id number) IS
SELECT  papf.payroll_id,papf.payroll_name,papf.effective_start_date,papf.effective_end_date
FROM pay_all_payrolls_f papf
    ,hr_soft_coding_keyflex hsck
WHERE papf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
  AND papf.business_group_id = p_bg_id
  AND hsck.segment4 = to_char(p_tax_unit_id);

-- Procedure for Migrating Assignment action info to be striped by Tax unit ID and Update
-- Action Information PER_YTD with _PER_PAYE_REF_YTD due to bug 4655083
-- Cursor to fetch assignment actions for a payroll

CURSOR c_get_def_bal(p_balance_name VARCHAR2) IS
SELECT def_old.defined_balance_id old_id
      ,def_new.defined_balance_id new_id
  FROM pay_balance_types pbt
      ,pay_balance_dimensions dim_old
      ,pay_balance_dimensions dim_new
      ,pay_defined_balances def_old
      ,pay_defined_balances def_new
WHERE pbt.balance_name = p_balance_name
 AND  dim_old.database_item_suffix = '_PER_YTD'
 AND  dim_old.legislation_code = 'IE'
 AND  dim_new.legislation_code = 'IE'
 AND  dim_new.database_item_suffix = '_PER_PAYE_REF_YTD'
 AND  pbt.legislation_code = 'IE'
 AND  def_old.balance_type_id = pbt.balance_type_id
 AND  def_old.balance_dimension_id = dim_old.balance_dimension_id
 AND  def_new.balance_type_id = pbt.balance_type_id
 AND  def_new.balance_dimension_id = dim_new.balance_dimension_id;

 CURSOR c_p45_applied IS
 SELECT 1
 FROM FND_DESCR_FLEX_COLUMN_USAGES
 WHERE DESCRIPTIVE_FLEXFIELD_NAME = 'Action Information DF'
 AND DESCRIPTIVE_FLEX_CONTEXT_CODE = 'IE P45 INFORMATION'
 AND APPLICATION_COLUMN_NAME = 'ACTION_INFORMATION8'
 AND END_USER_COLUMN_NAME = 'Person ID';

p_org_id NUMBER;
l_object_version_number NUMBER;
l_duplicate_org_warning BOOLEAN;
l_scl_keyflex_id NUMBER;
l_concat_segments hr_soft_coding_keyflex.concatenated_segments%TYPE;
l_payroll_id NUMBER;
l_start_date date;
l_end_date  date;
l_comment_id NUMBER;
l_org_information_id NUMBER;
l_status BOOLEAN;
l_no_data_found varchar2(1);
l_pay_found  varchar2(1);
l_old_id NUMBER;
l_new_id NUMBER;
l_p45_migrated number;

l_migrate_archive_data varchar2(1);

BEGIN

retcode := 0;
l_p45_migrated := 0;

fnd_file.put_line(FND_FILE.OUTPUT,'----------------------------------------------------------------------------------------------------');
fnd_file.put_line(FND_FILE.OUTPUT,'                             Migration Details ');
fnd_file.put_line(FND_FILE.OUTPUT,'----------------------------------------------------------------------------------------------------');
fnd_file.put_line(FND_FILE.OUTPUT,'                                                                                ');
fnd_file.put_line(FND_FILE.OUTPUT,'                                                                                ');

fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------------------------------------------------');
fnd_file.put_line(FND_FILE.LOG,'                               Migration Details ');
fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------------------------------------------------');
fnd_file.put_line(FND_FILE.LOG,'                                                                                ');
fnd_file.put_line(FND_FILE.LOG,'                                                                                ');

l_no_data_found := 'Y';

-- Setup the balance Table
g_statutory_balance_table(1).balance_name := 'IE Taxable Pay';
g_statutory_balance_table(2).balance_name := 'IE Net Tax';
g_statutory_balance_table(3).balance_name := 'IE PRSI Employee';
g_statutory_balance_table(4).balance_name := 'IE PRSI K Employee Lump Sum';
g_statutory_balance_table(5).balance_name := 'IE PRSI M Employee Lump Sum';
g_statutory_balance_table(6).balance_name := 'IE PRSI Employer';
g_statutory_balance_table(7).balance_name := 'IE PRSI K Employer Lump Sum';
g_statutory_balance_table(8).balance_name := 'IE PRSI M Employer Lump Sum';

FOR l_index in 1 .. g_max_balance_index LOOP
l_old_id := NULL;
l_new_id := NULL;

 OPEN c_get_def_bal(g_statutory_balance_table(l_index).balance_name);
 FETCH c_get_def_bal INTO l_old_id,l_new_id;
 g_statutory_balance_table(l_index).old_defined_balance_id := l_old_id;
 g_statutory_balance_table(l_index).new_defined_balance_id := l_new_id;
 CLOSE c_get_def_bal;

END LOOP;
-- Balance setup ends here

OPEN c_p45_applied;
FETCH c_p45_applied INTO l_p45_migrated;
CLOSE c_p45_applied;

 /* Organization Migration Start here */
FOR v_org IN c_get_org_details(p_bg_id,l_p45_migrated) LOOP
BEGIN


fnd_file.put_line(FND_FILE.LOG,'                                                                                ');
fnd_file.put_line(FND_FILE.LOG,'                                                                                ');
fnd_file.put_line(FND_FILE.LOG,'                Migration Details for Org '||v_org.org_information8);
fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------------------------------------------------');

fnd_file.put_line(FND_FILE.LOG,'     ');
fnd_file.put_line(FND_FILE.LOG,'Organization Level Migartion Details');
fnd_file.put_line(FND_FILE.LOG,'     ');

IF l_no_data_found = 'Y' THEN
	l_no_data_found := 'N';
fnd_file.put_line(FND_FILE.OUTPUT,rpad(lpad('Org Id',7),20)||'          '||rpad('Name',40)||'           '||rpad('Paye Ref Number',15)||'        '||rpad('Migrated',10));
fnd_file.put_line(FND_FILE.OUTPUT,' ');
END IF;

-- If Employer is not migrated Call this 'NN'

IF v_org.migrated_flag = 'NN' THEN

	            l_stage := 'Create Organization  ' ||v_org.org_information8 ;
	  	fnd_file.put_line(FND_FILE.LOG,'Organization Name    =>   '|| v_org.org_information8);
	  	fnd_file.put_line(FND_FILE.LOG,'Date From            =>   '|| v_org.date_from);
	  	fnd_file.put_line(FND_FILE.LOG,'Date To              =>   '|| v_org.date_to);
	  	fnd_file.put_line(FND_FILE.LOG,'Int Or Ext Flag      =>   '|| v_org.internal_external_flag);

	       -- Create new Organization
	         HR_ORGANIZATION_API.create_organization(
	  		 p_validate                       => FALSE
	  		,p_effective_date                 => sysdate
	  		,p_business_group_id              => p_bg_id
	  		,p_name			          => v_org.org_information8
	  		,p_date_from                      => v_org.date_from
	  		,p_date_to                        => v_org.date_to
	  		,p_internal_external_flag         => v_org.internal_external_flag
	  		,p_organization_id                => p_org_id
	  		,p_object_version_number          => l_object_version_number
	  		,p_duplicate_org_warning          => l_duplicate_org_warning
	       						    );

	  	fnd_file.put_line(FND_FILE.LOG,'Organization Id      =>   '|| p_org_id);

	   -- Attach classification Legal Employer
                    l_stage := 'Create Classification  ' || v_org.org_information8;
	      HR_ORGANIZATION_API.create_org_class_internal(
	      p_validate      		=> FALSE
	     ,p_effective_date  	=> sysdate
	     ,p_organization_id 	=> p_org_id
	     ,p_org_classif_code 	=> 'HR_LEGAL_EMPLOYER'
	     ,p_classification_enabled  => 'Y'
	     ,p_org_information_id	=> l_org_information_id
	     ,p_object_version_number	=> l_object_version_number
	     );
		fnd_file.put_line(FND_FILE.LOG,'Classification       =>   Legal Employer');

                    l_stage := 'Create Org Information ' || v_org.org_information8;
	  fnd_file.put_line(FND_FILE.LOG,'Information Type     =>   IE_EMPLOYER_INFO');
	  fnd_file.put_line(FND_FILE.LOG,'Tax District Number  =>   '||   v_org.Org_Information1);
	  fnd_file.put_line(FND_FILE.LOG,'PAYE Ref Number      =>   '||   v_org.Org_Information2);
	  fnd_file.put_line(FND_FILE.LOG,'Employer Trade Name  =>   '||   v_org.Org_Information9);
	  fnd_file.put_line(FND_FILE.LOG,'ER Tax Ref Contact   =>   '||   v_org.Org_Information6);
	  fnd_file.put_line(FND_FILE.LOG,'                                                     ');
	  fnd_file.put_line(FND_FILE.LOG,'                                                     ');

	  -- Create new extra Information for the Legal Employer
           HR_ORGanization_api.create_org_information(
                   p_validate             => FALSE,
		   p_effective_date       => sysdate,
		   p_Org_Information_Id   => l_org_information_id,
		   p_Org_Info_type_code   => 'IE_EMPLOYER_INFO',
		   p_Organization_Id      => p_org_id,
		   p_Org_Information1     => v_org.Org_Information1,
		   p_Org_Information2     => v_org.Org_Information2,
		   p_Org_Information3     => v_org.Org_Information9,
		   p_Org_Information4     => v_org.Org_Information6,
		   p_object_version_number => l_object_version_number
		                                   );

                    l_pay_found := 'N';
                    l_migrate_archive_data := 'N';

     /* Payroll Migration Start here */
      for v_payroll in c_get_payroll_details(p_bg_id,v_org.Org_Information1,v_org.Org_Information2) LOOP

      	    IF l_pay_found = 'N' THEN
      	       l_pay_found := 'Y';
	fnd_file.put_line(FND_FILE.LOG,'Payroll Level Migartion Details');
	fnd_file.put_line(FND_FILE.LOG,'                                                     ');
      	    END IF;
                          l_stage := 'Create Soft Coding Keyflex' || v_payroll.payroll_name;

  	  fnd_file.put_line(FND_FILE.LOG,'Payroll Name   =>   '||   v_payroll.payroll_name);
  	  fnd_file.put_line(FND_FILE.LOG,'Start Date     =>   '||   v_payroll.effective_start_date);
  	  fnd_file.put_line(FND_FILE.LOG,'End Date       =>   '||   v_payroll.effective_end_date);

      				hr_kflex_utility.ins_or_sel_keyflex_comb
				(p_appl_short_name	    =>  'PER'
				,p_flex_code		    =>  'SCL'
				,p_flex_num		    =>  v_payroll.id_flex_num
		--		,p_segment1		    =>  v_payroll.segment1
				,p_segment2		    =>  v_payroll.segment2
		--		,p_segment3                 =>  v_payroll.segment3
				,p_segment4                 =>  p_org_id
				,p_ccid		            =>  l_scl_keyflex_id
				,p_concat_segments_out      =>  l_concat_segments);
	l_payroll_id := v_payroll.payroll_id;
	l_object_version_number := v_payroll.object_version_number;

	                  l_stage := 'Update Payroll '||v_payroll.payroll_name;
	                    -- Update the payroll
				pay_payroll_api.update_payroll
					(
					  p_validate                 => FALSE,
					  p_effective_date           => v_payroll.effective_start_date,
					  p_datetrack_mode           => 'CORRECTION',
					  p_payroll_id               => l_payroll_id,
					  p_object_version_number    => l_object_version_number,
					  p_soft_coding_keyflex_id   => l_scl_keyflex_id,
					  p_prl_effective_start_date => l_start_date,
					  p_prl_effective_end_date   => l_end_date,
					  p_comment_id               => l_comment_id
					);

  	  fnd_file.put_line(FND_FILE.LOG,'New Employer   =>   '||   v_org.org_information8);

	  l_asg_found := 'N';

       /* Assignment migration starts here */
     migrate_asg_act_actinfo_tu(p_bg_id,p_org_id,l_payroll_id,v_payroll.effective_start_date,v_payroll.effective_end_date,l_migrate_archive_data,l_p45_migrated);
         /* Assignment Migration Ends here */

      END LOOP;

      l_migrate_archive_data := 'Y';

      for v_payroll in c_get_prl_p35_details(p_bg_id,p_org_id) LOOP

        /* Assignment migration starts here */
        migrate_asg_act_actinfo_tu(p_bg_id,p_org_id,l_payroll_id,v_payroll.effective_start_date,v_payroll.effective_end_date,l_migrate_archive_data,l_p45_migrated);
        /* Assignment Migration Ends here */

      END LOOP;
      /* Payroll Migration Ends here */
 ELSE

FOR v_p35_org IN c_get_er_details(p_bg_id,v_org.org_information8) LOOP
   p_org_id := v_p35_org.organization_id;
  l_migrate_archive_data := 'N';

   FOR v_p35_prl IN c_get_prl_p35_details(p_bg_id,v_p35_org.organization_id) LOOP
     migrate_asg_act_actinfo_tu(p_bg_id,v_p35_org.organization_id,v_p35_prl.payroll_id,v_p35_prl.effective_start_date,v_p35_prl.effective_end_date,l_migrate_archive_data,l_p45_migrated);
   END LOOP;

   l_migrate_archive_data := 'Y';
   FOR v_p35_prl IN c_get_prl_p35_details(p_bg_id,v_p35_org.organization_id) LOOP
     migrate_asg_act_actinfo_tu(p_bg_id,v_p35_org.organization_id,v_p35_prl.payroll_id,v_p35_prl.effective_start_date,v_p35_prl.effective_end_date,l_migrate_archive_data,l_p45_migrated);
   END LOOP;
END LOOP;

 END IF;

      l_stage := 'Set Migration Status '||v_org.org_information8;
      l_object_version_number := v_org.object_version_number;
      -- Set the Employer Information as migrated
      HR_ORGanization_api.update_org_information
        (
          p_validate                => FALSE,
          p_effective_date          => sysdate,
          p_org_information_id      => v_org.org_information_id,
          p_org_info_type_code      => 'IE_ORG_INFORMATION',
          p_org_information2        => v_org.org_information2,
          p_org_information11       => 'YYY',
          p_object_version_number   => l_object_version_number
        );

 -- If Employer is not migrated Ends here

 -- Migrate P35 for this Employer

fnd_file.put_line(FND_FILE.OUTPUT,rpad(lpad(p_org_id,7),20)||'          '||rpad(v_org.org_information8,40)||'           '|| rpad(v_org.Org_Information2,15)||'        '||rpad('Yes',10));

     	COMMIT;
  -- ROLLBACK;

EXCEPTION
      	WHEN OTHERS THEN
fnd_file.put_line(FND_FILE.LOG,'                                                                                ');
      	fnd_file.put_line(FND_FILE.LOG,'Error in '||l_stage);
      	fnd_file.put_line(FND_FILE.LOG,sqlerrm);
      	ROLLBACK;


fnd_file.put_line(FND_FILE.OUTPUT,rpad(lpad('*****',7),20)||'          '||rpad(v_org.org_information8,40)||'           '|| rpad(v_org.Org_Information2,15)||'        '||rpad('No',10));

  /* Set the program completion status to Warning */
  l_status := FND_CONCURRENT.SET_COMPLETION_STATUS
               (
                status => 'WARNING',
                message => 'Please Check the Log File for more details'
               );


  END;

END LOOP;
/* Organization Migration Ends here */

if l_no_data_found = 'Y' THEN
fnd_file.put_line(FND_FILE.OUTPUT,'The data has been successfully migrated. There is no data to migrate.');
end if;


END migrate_data;

END pay_ie_le_migrate;

/
