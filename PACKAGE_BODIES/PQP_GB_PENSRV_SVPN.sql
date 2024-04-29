--------------------------------------------------------
--  DDL for Package Body PQP_GB_PENSRV_SVPN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PENSRV_SVPN" AS
/* $Header: pqpgbpsispn.pkb 120.4 2008/01/09 03:59:44 rlingama noship $ */

-- Globals

g_package_name           VARCHAR2(100);
g_legislation_code        per_business_groups.legislation_code%TYPE   := 'GB';
g_business_group_id       NUMBER      := NULL;
g_svpn_flag               VARCHAR2(4);
g_eff_start_date          DATE := to_date('31-07-2007','DD-MM-YYYY');
g_eff_end_date            DATE;
g_asg_membership_context  VARCHAR2(30);
g_asg_membership_col      VARCHAR2(30);

--
--  This Function is used to check whther the assignment is eligible for to
--  generate service period number
--
 FUNCTION chk_emp_eligibility(p_assignment_id IN NUMBER
				              ) RETURN DATE
 IS
 l_query    VARCHAR2(2000);
 l_value    DATE := NULL;

 TYPE base_table_ref_typ IS REF CURSOR;
 cur_get_value       base_table_ref_typ;

 BEGIN

   l_query := 'select max(effective_start_date)'||' '||
              'from per_all_assignments_f '||' '||
              'where business_group_id = '||g_business_group_id||' '||
              'and assignment_id = '||p_assignment_id||' '||
              'and effective_start_date <= to_date('''||TO_CHAR(g_eff_end_date,'dd/mm/yyyy')||''',''dd/mm/yyyy'') '||' '||
              'and effective_end_date >= to_date('''||TO_CHAR(g_eff_start_date,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'||' '||
              'and '||g_asg_membership_col||' '||'IS NOT NULL'||' ';

    IF g_asg_membership_context <> 'Global Data Elements' THEN
          l_query := l_query||
                  'and ASS_ATTRIBUTE_CATEGORY = '''||g_asg_membership_context||''''||' ';
    END IF;

    OPEN cur_get_value FOR l_query;
    FETCH cur_get_value INTO l_value;
    CLOSE cur_get_value;

    RETURN l_value;

 END;

-- This procedure is used to generate service period numbers.
-- ----------------------------------------------------------------------------
-- |-------------------------< derive_svpn >--------------------------|
-- ----------------------------------------------------------------------------
 PROCEDURE derive_svpn( errbuf      OUT NOCOPY VARCHAR2,
                        retcode     OUT NOCOPY VARCHAR2,
                        p_business_group_id IN NUMBER,
                        p_eff_end_date      IN VARCHAR2,
                        p_execution_mode    IN VARCHAR2)
 IS

-- Cursor to fetch all assignments

   CURSOR csr_fetch_all_assignments (c_eff_end_date IN Date)
   IS
   SELECT DISTINCT papf.national_identifier,papf.person_id,paaf.assignment_id,
          ppos.period_of_service_id,papf.employee_number,paaf.assignment_number
   FROM  per_all_people_f papf,
         per_all_assignments_f paaf,
	 per_periods_of_service ppos
   WHERE papf.business_group_id = g_business_group_id
   AND   papf.effective_start_date <= c_eff_end_date
   AND   papf.effective_end_date >= g_eff_start_date
   AND   papf.person_id = ppos.person_id
   AND   NVL(ppos.final_process_date,g_eff_start_date ) >= g_eff_start_date
   AND   ppos.period_of_service_id = paaf.period_of_service_id
   AND   paaf.PRIMARY_FLAG = 'Y'
   AND   paaf.business_group_id = g_business_group_id
   AND   paaf.effective_start_date <= c_eff_end_date
   AND   paaf.effective_end_date >= g_eff_start_date
   AND   paaf.effective_start_date = PQP_GB_PENSRV_SVPN.chk_emp_eligibility(paaf.assignment_id)
   ORDER BY papf.national_identifier,ppos.period_of_service_id;

-- Cursor to fetch Maintain Service period Number flag

   CURSOR csr_svpn_maintain_flag
   IS
   SELECT pcv_information4
   FROM  pqp_configuration_values pcv,
         pqp_configuration_types pct
   WHERE pcv.pcv_information_category = pct.configuration_type
   AND   pct.configuration_type = 'PQP_GB_PENSERVER_PAYPOINT_INFO'
   AND   pcv.business_group_id = g_business_group_id;

-- Cursor to fetch pension scheme eligibility configuration values

   CURSOR csr_pensrv_eligibility
   IS
   SELECT pcv_information1,pcv_information2
   FROM  pqp_configuration_values pcv,
         pqp_configuration_types pct
   WHERE pcv.pcv_information_category = pct.configuration_type
   AND   pct.configuration_type = 'PQP_GB_PENSERVER_ELIGBLTY_CONF'
   AND   pcv.business_group_id = g_business_group_id;

-- Cursor to fetch EIT information for Penserver Service Period Number

   CURSOR cur_get_eit_info(c_assignment_id NUMBER)
   IS
   SELECT aei_information_category
   FROM  per_assignment_Extra_info
   WHERE assignment_id = c_assignment_id
   AND   aei_information_category = 'PQP_GB_PENSERV_SVPN';

-- Local variables

   l_procedure_name    VARCHAR2(100);
   l_old_NI_number     VARCHAR2(100);
   l_new_NI_number     VARCHAR2(100);
   l_spn               NUMBER;
   l_assignment_extra_info_id NUMBER;
   l_aei_information_category VARCHAR2(100);
   l_object_version_number    NUMBER;
   l_eff_start_date           DATE;
   l_eff_end_date             DATE;
   l_execution_mode          BOOLEAN;

   l_tp_ni_increment          NUMBER :=1;

   TYPE character_data_table IS TABLE OF VARCHAR2(280)
                             INDEX BY BINARY_INTEGER;
   l_ni_number         character_data_table;
   l_person_number     character_data_table;
   l_assignment_number character_data_table;
   l_spn_number        character_data_table;

 BEGIN

   l_procedure_name := '.derive_svpn';

   hr_utility.set_location('Entering ' || g_package_name || l_procedure_name,0);

   fnd_file.put_line(fnd_file.log,'Entering ' || g_package_name || l_procedure_name);
   --fnd_file.put_line(fnd_file.log,'p_business_group_id  '||p_business_group_id);
   --fnd_file.put_line(fnd_file.log,'p_eff_end_date       '||p_eff_end_date);
   --fnd_file.put_line(fnd_file.log,'p_execution_mode     '||p_execution_mode);

   g_business_group_id := p_business_group_id;
   g_eff_end_date := fnd_date.canonical_to_date(p_eff_end_date);

   IF g_eff_end_date < g_eff_start_date THEN
     fnd_file.put_line(fnd_file.log,'Effective End Date should be greater than or equal to 31-JUL-2007.');
   ELSE
   OPEN csr_svpn_maintain_flag;
   FETCH csr_svpn_maintain_flag INTO g_svpn_flag;
   CLOSE csr_svpn_maintain_flag;

   hr_utility.set_location('g_svpn_flag'||g_svpn_flag,10);

   -- Checking whether Maintain Service period flag is enabled or not.

   IF g_svpn_flag = 'Yes' THEN

     fnd_file.put_line(fnd_file.log,'Maintain Service Period Number flag is set to Yes for the configuration PAYPOINT and CUTOVER INFORMATION.
                                    Concurrent Process will be executed to set the SPN only when the flag is not set to Yes.');
   ELSE

     OPEN csr_pensrv_eligibility;
     FETCH csr_pensrv_eligibility INTO g_asg_membership_context,
                                       g_asg_membership_col;
     CLOSE csr_pensrv_eligibility;

     --fnd_file.put_line(fnd_file.log,'g_asg_membership_context'||g_asg_membership_context);
     --fnd_file.put_line(fnd_file.log,'g_asg_membership_col    '||g_asg_membership_col);

     -- Checking whether Pension Scheme Eligibility Configuration is configured or not

     IF g_asg_membership_context IS NULL
        OR
        g_asg_membership_col IS NULL
     THEN
        fnd_file.put_line(fnd_file.log,'Assignment Flexfield Context and Assignment Flexfield Column Name is
                                        Not configured under Pension Scheme Eligibilty Configuration for Penserver Interfaces.');
     END IF;
   END IF;

  -- IF Pension Scheme Eligibility Configuration is configured successfully the proceed

   IF g_asg_membership_context IS NOT NULL AND g_asg_membership_col IS NOT NULL
   THEN
     l_spn := 1;

     --fnd_file.put_line(fnd_file.log,' g_eff_end_date '|| g_eff_end_date );

    -- Service Period Number details writing into the out put file

     fnd_file.put_line(FND_FILE.OUTPUT,'------------------------------------------------------------------------------------------------------------------------------------');
     fnd_file.put_line(FND_FILE.OUTPUT,'                           Service Period Number details for employees in Business group: '||rpad(g_business_group_id,30));
     fnd_file.put_line(FND_FILE.OUTPUT,'                                                   report date : '|| sysdate);
     fnd_file.put_line(FND_FILE.OUTPUT,'------------------------------------------------------------------------------------------------------------------------------------');
     fnd_file.put_line(FND_FILE.OUTPUT,'                                                                                ');
     fnd_file.put_line(FND_FILE.OUTPUT, rpad('National Identifier',20)||'  '||rpad('Person Number',20)||'  '||rpad('Assignment Number',20)||'  '||rpad('Service Period Number',22));
     fnd_file.put_line(FND_FILE.OUTPUT,'------------------------------------------------------------------------------------------------------------------------------------');

     -- For each assignment checking whether the assignment is eligible for genertion of service period number
     -- and generting SPN for valid assignments

     FOR l_query_re IN csr_fetch_all_assignments (g_eff_end_date) LOOP

       l_new_NI_number := l_query_re.national_identifier;
       IF l_old_NI_number = l_new_NI_number THEN
          l_spn := l_spn + 1;
       ELSIF l_old_NI_number <> l_new_NI_number OR l_old_NI_number IS NULL THEN
          l_spn := 1;
       END IF;

        l_old_NI_number := l_new_NI_number;

        l_aei_information_category := null;

        OPEN cur_get_eit_info(l_query_re.assignment_id);
        FETCH cur_get_eit_info INTO l_aei_information_category;
        CLOSE cur_get_eit_info;

        -- Checking whether EIT for this assignment exists or not

        IF l_aei_information_category IS NULL THEN

           IF l_query_re.national_identifier IS NOT NULL
           AND UPPER(SUBSTR(l_query_re.national_identifier,1,2)) <> 'TN' THEN
                fnd_file.put_line(FND_FILE.OUTPUT,rpad(l_query_re.national_identifier,20)||'  '||rpad(l_query_re.employee_number,20)||'  '||
                rpad(l_query_re.assignment_number,20)||'  '||rpad(lpad(l_spn,2,'0'),20));
           ELSE
             l_spn := NULL;
             IF l_query_re.national_identifier IS NULL THEN
		l_query_re.national_identifier := 'No NI Number';
             END IF;
                l_ni_number(l_tp_ni_increment) := l_query_re.national_identifier;
                l_person_number(l_tp_ni_increment) := l_query_re.employee_number;
                l_assignment_number(l_tp_ni_increment) := l_query_re.assignment_number;
                l_spn_number(l_tp_ni_increment) := l_spn;
                l_tp_ni_increment := l_tp_ni_increment + 1;
           END IF;

           -- Checking whether the execution mode is commit or not
           IF p_execution_mode = 'Commit' THEN
                 l_execution_mode := FALSE;
           ELSE
                 l_execution_mode := TRUE;
           END IF; -- end of p_execution_mode

             IF l_spn IS NOT NULL THEN
                -- inserting service period number
                HR_ASSIGNMENT_EXTRA_INFO_API.create_assignment_extra_info(p_validate => l_execution_mode
		                                             ,p_assignment_id    => l_query_re.assignment_id
                                                             ,p_information_type         => 'PQP_GB_PENSERV_SVPN'
                                                             ,p_aei_information_category => 'PQP_GB_PENSERV_SVPN'
                                                             ,p_aei_information1         => lpad(l_spn,2,'0')
                                                             ,p_assignment_extra_info_id => l_assignment_extra_info_id
                                                             ,p_object_version_number    => l_object_version_number);
             END IF; -- end of l_spn
        END IF; -- end of l_aei_information_category
    END LOOP;

     -- writing warning heading in to the out put file
     fnd_file.put_line(FND_FILE.OUTPUT,rpad(' ',20));
     fnd_file.put_line(FND_FILE.OUTPUT,'Warnings: SPN is not set for the following employees');
     fnd_file.put_line(FND_FILE.OUTPUT,rpad('---------',20));

     FOR i in 1 .. l_tp_ni_increment-1 LOOP
         fnd_file.put_line(FND_FILE.OUTPUT,rpad(l_ni_number(i),20)||'  '||rpad(l_person_number(i),20)||'  '||
         rpad(l_assignment_number(i),20)||'  '||rpad(lpad(l_spn_number(i),2,'0'),20));
     END LOOP;
   END IF;
  END IF; -- end for checking whether start date is greater than end date
   fnd_file.put_line(fnd_file.log,'Leaving ' || g_package_name || l_procedure_name);

   EXCEPTION
     WHEN others
     THEN
       fnd_file.put_line(fnd_file.log,g_package_name || l_procedure_name);
       fnd_file.put_line(fnd_file.log,'ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));

       RAISE;
 END derive_svpn;

BEGIN
 g_package_name := 'pqp_gb_pensrv_svpn';
END pqp_gb_pensrv_svpn;


/
