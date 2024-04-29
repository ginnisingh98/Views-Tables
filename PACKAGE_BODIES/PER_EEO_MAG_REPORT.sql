--------------------------------------------------------
--  DDL for Package Body PER_EEO_MAG_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EEO_MAG_REPORT" AS
/* $Header: peeeomag.pkb 120.16.12010000.6 2009/10/05 09:31:51 lbodired ship $ */

g_package  VARCHAR2(33) := '  per_eeo_mag_report.';  -- Global package name

TYPE org_rec IS RECORD
  (org_name           VARCHAR2(20) DEFAULT ' ',
   company_number_1   VARCHAR2(27) DEFAULT ' ',
   l_status_code_2    VARCHAR2(5) DEFAULT ' ',
   form_type          VARCHAR2(5),
   c1_over_100_13     VARCHAR2(5) DEFAULT ' ',
   c2_affiliated_14   VARCHAR2(5) DEFAULT ' ',
   gov_contract_15       VARCHAR2(1)  DEFAULT ' ',
   duns_16               VARCHAR2(20) DEFAULT ' ',
   l_d1_payroll_period_18 VARCHAR2(21) DEFAULT ' ',
   apprentices_emp_19    VARCHAR2(1)  DEFAULT ' ',
   sic_20                VARCHAR2(14) DEFAULT ' ',
   naics_21              VARCHAR2(16) DEFAULT ' ',
   title_cert_off_22  VARCHAR2(50) DEFAULT ' ',
   name_cert_off_23   VARCHAR2(50) DEFAULT ' ',
   tel_num_24         VARCHAR2(20) DEFAULT ' ',
   fax_num_25         VARCHAR2(10) DEFAULT ' ',
   email_26           VARCHAR2(40) DEFAULT ' ',
   par_ent_org_id     number(15) DEFAULT NULL
   );

l_org_rec org_rec;

TYPE con_rec IS RECORD
  (a_1_total_mfc   NUMBER DEFAULT 0
   );
l_con_rec con_rec;


 TYPE estab_rec IS RECORD
  (unit_number_3         VARCHAR2(50) DEFAULT ' ',
   unit_name_4           VARCHAR2(70) DEFAULT ' ',
   unit_address_req_5    VARCHAR2(200) DEFAULT ' ',
   unit_address_6        VARCHAR2(200) DEFAULT ' ',
   city_7                VARCHAR2(50) DEFAULT ' ',
   state_8               VARCHAR2(40) DEFAULT ' ',
   zip_code_9            VARCHAR2(40) DEFAULT ' ',
   zip_code_last_4_10    VARCHAR2(4)  DEFAULT ' ',
   reported_last_year_11 VARCHAR2(1)  DEFAULT '2',
   ein_12                VARCHAR2(19) DEFAULT ' ',
   gov_contract_15       VARCHAR2(1)  DEFAULT ' ',
   duns_16               VARCHAR2(20) DEFAULT ' ',
   county_17             VARCHAR2(38) DEFAULT ' ',
   apprentices_emp_19    VARCHAR2(1)  DEFAULT ' ',
   sic_20                VARCHAR2(14) DEFAULT ' ',
   naics_21              VARCHAR2(16) DEFAULT ' ',
   hq                    VARCHAR2(1)  DEFAULT ' ',
   max_count             VARCHAR2(1)  DEFAULT ' ',
   --
   a_1_hl_male NUMBER(6) DEFAULT 0,
   b_1_hl_female NUMBER(6) DEFAULT 0,
   c_1_white_male NUMBER(6) DEFAULT 0,
   d_1_black_male NUMBER(6) DEFAULT 0,
   e_1_latin_male NUMBER(6) DEFAULT 0,
   f_1_aspac_male NUMBER(6) DEFAULT 0,
   g_1_ameri_male NUMBER(6) DEFAULT 0,
   h_1_tmraces_male NUMBER(6) DEFAULT 0,
   i_1_white_fem  NUMBER(6) DEFAULT 0,
   j_1_black_fem  NUMBER(6) DEFAULT 0,
   k_1_latin_fem  NUMBER(6) DEFAULT 0,
   l_1_aspac_fem  NUMBER(6) DEFAULT 0,
   m_1_ameri_fem  NUMBER(6) DEFAULT 0,
   n_1_tmraces_female NUMBER(6) DEFAULT 0,
   o_1_total_cat NUMBER(7) DEFAULT 0,
   --
   a_2_hl_male NUMBER(6) DEFAULT 0,
   b_2_hl_female NUMBER(6) DEFAULT 0,
   c_2_white_male NUMBER(6) DEFAULT 0,
   d_2_black_male NUMBER(6) DEFAULT 0,
   e_2_latin_male NUMBER(6) DEFAULT 0,
   f_2_aspac_male NUMBER(6) DEFAULT 0,
   g_2_ameri_male NUMBER(6) DEFAULT 0,
   h_2_tmraces_male NUMBER(6) DEFAULT 0,
   i_2_white_fem  NUMBER(6) DEFAULT 0,
   j_2_black_fem  NUMBER(6) DEFAULT 0,
   k_2_latin_fem  NUMBER(6) DEFAULT 0,
   l_2_aspac_fem  NUMBER(6) DEFAULT 0,
   m_2_ameri_fem  NUMBER(6) DEFAULT 0,
   n_2_tmraces_female NUMBER(6) DEFAULT 0,
   o_2_total_cat NUMBER(7) DEFAULT 0,
   --
   a_3_hl_male NUMBER(6) DEFAULT 0,
   b_3_hl_female NUMBER(6) DEFAULT 0,
   c_3_white_male NUMBER(6) DEFAULT 0,
   d_3_black_male NUMBER(6) DEFAULT 0,
   e_3_latin_male NUMBER(6) DEFAULT 0,
   f_3_aspac_male NUMBER(6) DEFAULT 0,
   g_3_ameri_male NUMBER(6) DEFAULT 0,
   h_3_tmraces_male NUMBER(6) DEFAULT 0,
   i_3_white_fem  NUMBER(6) DEFAULT 0,
   j_3_black_fem  NUMBER(6) DEFAULT 0,
   k_3_latin_fem  NUMBER(6) DEFAULT 0,
   l_3_aspac_fem  NUMBER(6) DEFAULT 0,
   m_3_ameri_fem  NUMBER(6) DEFAULT 0,
   n_3_tmraces_female NUMBER(6) DEFAULT 0,
   o_3_total_cat NUMBER(7) DEFAULT 0,
   --
   a_4_hl_male NUMBER(6) DEFAULT 0,
   b_4_hl_female NUMBER(6) DEFAULT 0,
   c_4_white_male NUMBER(6) DEFAULT 0,
   d_4_black_male NUMBER(6) DEFAULT 0,
   e_4_latin_male NUMBER(6) DEFAULT 0,
   f_4_aspac_male NUMBER(6) DEFAULT 0,
   g_4_ameri_male NUMBER(6) DEFAULT 0,
   h_4_tmraces_male NUMBER(6) DEFAULT 0,
   i_4_white_fem  NUMBER(6) DEFAULT 0,
   j_4_black_fem  NUMBER(6) DEFAULT 0,
   k_4_latin_fem  NUMBER(6) DEFAULT 0,
   l_4_aspac_fem  NUMBER(6) DEFAULT 0,
   m_4_ameri_fem  NUMBER(6) DEFAULT 0,
   n_4_tmraces_female NUMBER(6) DEFAULT 0,
   o_4_total_cat NUMBER(7) DEFAULT 0,
   --
  a_5_hl_male NUMBER(6) DEFAULT 0,
   b_5_hl_female NUMBER(6) DEFAULT 0,
   c_5_white_male NUMBER(6) DEFAULT 0,
   d_5_black_male NUMBER(6) DEFAULT 0,
   e_5_latin_male NUMBER(6) DEFAULT 0,
   f_5_aspac_male NUMBER(6) DEFAULT 0,
   g_5_ameri_male NUMBER(6) DEFAULT 0,
   h_5_tmraces_male NUMBER(6) DEFAULT 0,
   i_5_white_fem  NUMBER(6) DEFAULT 0,
   j_5_black_fem  NUMBER(6) DEFAULT 0,
   k_5_latin_fem  NUMBER(6) DEFAULT 0,
   l_5_aspac_fem  NUMBER(6) DEFAULT 0,
   m_5_ameri_fem  NUMBER(6) DEFAULT 0,
   n_5_tmraces_female NUMBER(6) DEFAULT 0,
   o_5_total_cat NUMBER(7) DEFAULT 0,
   --
   a_6_hl_male NUMBER(6) DEFAULT 0,
   b_6_hl_female NUMBER(6) DEFAULT 0,
   c_6_white_male NUMBER(6) DEFAULT 0,
   d_6_black_male NUMBER(6) DEFAULT 0,
   e_6_latin_male NUMBER(6) DEFAULT 0,
   f_6_aspac_male NUMBER(6) DEFAULT 0,
   g_6_ameri_male NUMBER(6) DEFAULT 0,
   h_6_tmraces_male NUMBER(6) DEFAULT 0,
   i_6_white_fem  NUMBER(6) DEFAULT 0,
   j_6_black_fem  NUMBER(6) DEFAULT 0,
   k_6_latin_fem  NUMBER(6) DEFAULT 0,
   l_6_aspac_fem  NUMBER(6) DEFAULT 0,
   m_6_ameri_fem  NUMBER(6) DEFAULT 0,
   n_6_tmraces_female NUMBER(6) DEFAULT 0,
   o_6_total_cat NUMBER(7) DEFAULT 0,
   --
   a_7_hl_male NUMBER(6) DEFAULT 0,
   b_7_hl_female NUMBER(6) DEFAULT 0,
   c_7_white_male NUMBER(6) DEFAULT 0,
   d_7_black_male NUMBER(6) DEFAULT 0,
   e_7_latin_male NUMBER(6) DEFAULT 0,
   f_7_aspac_male NUMBER(6) DEFAULT 0,
   g_7_ameri_male NUMBER(6) DEFAULT 0,
   h_7_tmraces_male NUMBER(6) DEFAULT 0,
   i_7_white_fem  NUMBER(6) DEFAULT 0,
   j_7_black_fem  NUMBER(6) DEFAULT 0,
   k_7_latin_fem  NUMBER(6) DEFAULT 0,
   l_7_aspac_fem  NUMBER(6) DEFAULT 0,
   m_7_ameri_fem  NUMBER(6) DEFAULT 0,
   n_7_tmraces_female NUMBER(6) DEFAULT 0,
   o_7_total_cat NUMBER(7) DEFAULT 0,
   --
   a_8_hl_male NUMBER(6) DEFAULT 0,
   b_8_hl_female NUMBER(6) DEFAULT 0,
   c_8_white_male NUMBER(6) DEFAULT 0,
   d_8_black_male NUMBER(6) DEFAULT 0,
   e_8_latin_male NUMBER(6) DEFAULT 0,
   f_8_aspac_male NUMBER(6) DEFAULT 0,
   g_8_ameri_male NUMBER(6) DEFAULT 0,
   h_8_tmraces_male NUMBER(6) DEFAULT 0,
   i_8_white_fem  NUMBER(6) DEFAULT 0,
   j_8_black_fem  NUMBER(6) DEFAULT 0,
   k_8_latin_fem  NUMBER(6) DEFAULT 0,
   l_8_aspac_fem  NUMBER(6) DEFAULT 0,
   m_8_ameri_fem  NUMBER(6) DEFAULT 0,
   n_8_tmraces_female NUMBER(6) DEFAULT 0,
   o_8_total_cat NUMBER(7) DEFAULT 0,
   --
  a_9_hl_male NUMBER(6) DEFAULT 0,
   b_9_hl_female NUMBER(6) DEFAULT 0,
   c_9_white_male NUMBER(6) DEFAULT 0,
   d_9_black_male NUMBER(6) DEFAULT 0,
   e_9_latin_male NUMBER(6) DEFAULT 0,
   f_9_aspac_male NUMBER(6) DEFAULT 0,
   g_9_ameri_male NUMBER(6) DEFAULT 0,
   h_9_tmraces_male NUMBER(6) DEFAULT 0,
   i_9_white_fem  NUMBER(6) DEFAULT 0,
   j_9_black_fem  NUMBER(6) DEFAULT 0,
   k_9_latin_fem  NUMBER(6) DEFAULT 0,
   l_9_aspac_fem  NUMBER(6) DEFAULT 0,
   m_9_ameri_fem  NUMBER(6) DEFAULT 0,
   n_9_tmraces_female NUMBER(6) DEFAULT 0,
   o_9_total_cat NUMBER(7) DEFAULT 0,
   --
   a_10_hl_male NUMBER(6) DEFAULT 0,
   b_10_hl_female NUMBER(6) DEFAULT 0,
   c_10_white_male NUMBER(6) DEFAULT 0,
   d_10_black_male NUMBER(6) DEFAULT 0,
   e_10_latin_male NUMBER(6) DEFAULT 0,
   f_10_aspac_male NUMBER(6) DEFAULT 0,
   g_10_ameri_male NUMBER(6) DEFAULT 0,
   h_10_tmraces_male NUMBER(6) DEFAULT 0,
   i_10_white_fem  NUMBER(6) DEFAULT 0,
   j_10_black_fem  NUMBER(6) DEFAULT 0,
   k_10_latin_fem  NUMBER(6) DEFAULT 0,
   l_10_aspac_fem  NUMBER(6) DEFAULT 0,
   m_10_ameri_fem  NUMBER(6) DEFAULT 0,
   n_10_tmraces_female NUMBER(6) DEFAULT 0,
   o_10_total_cat NUMBER(7) DEFAULT 0,
   --
   a_10_grand_total NUMBER(6) DEFAULT 0,
   b_10_grand_total NUMBER(6) DEFAULT 0,
   c_10_grand_total NUMBER(6) DEFAULT 0,
   d_10_grand_total NUMBER(6) DEFAULT 0,
   e_10_grand_total NUMBER(6) DEFAULT 0,
   f_10_grand_total NUMBER(6) DEFAULT 0,
   g_10_grand_total NUMBER(6) DEFAULT 0,
   h_10_grand_total NUMBER(6) DEFAULT 0,
   i_10_grand_total NUMBER(6) DEFAULT 0,
   j_10_grand_total NUMBER(6) DEFAULT 0,
   k_10_grand_total NUMBER(6) DEFAULT 0,
   l_10_grand_total NUMBER(6) DEFAULT 0,
   m_10_grand_total NUMBER(6) DEFAULT 0,
   n_10_grand_total NUMBER(6) DEFAULT 0,
   o_10_grand_total NUMBER(7) DEFAULT 0);
--
l_estab_rec estab_rec;
l_consol_rec estab_rec;
l_holder_rec estab_rec;
l_estab_rec_blank estab_rec;


l_hierarchy_name NUMBER;
l_hierarchy_version_num NUMBER;
l_parent_org_id NUMBER;
l_parent_node_id NUMBER;
g_message_text VARCHAR2(240);
l_report_year VARCHAR2(4);
l_prev_year_filed VARCHAR2(4);
l_total NUMBER := 0;


PROCEDURE set_org_details(p_hierarchy_version_id IN NUMBER,
                          p_business_group_id IN NUMBER,
                          p_start_date IN DATE,
                          p_end_date IN DATE) IS


  CURSOR c_org_details IS
    SELECT SUBSTR(hou.name,1,20)   org_name,
           SUBSTR(hoi1.org_information2,1,27) company_number_1,
           decode(hoi1.org_information3,'Y',1,2) c2_affiliated_14,
           decode(hoi3.org_information5,'Y',1,2) gov_contract_15,
           SUBSTR(hoi3.org_information4,1,20)  duns_16,
           decode(hoi3.org_information6,'Y',1,2) apprentices_emp_19,
           SUBSTR(hoi3.org_information1,1,14) sic_20,
           SUBSTR(hoi3.org_information2,1,16) naics_21,
           SUBSTR(hoi2.org_information2,1,50) title_cert_off_22,
           SUBSTR(hoi2.org_information1,1,50) name_cert_off_23,
           SUBSTR(hoi2.org_information10,1,20) tel_num_24,
           SUBSTR(hoi2.org_information14,1,10) fax_num_25,
           SUBSTR(hoi2.org_information15,1,40) email_26,
           hoi1.organization_id par_ent_org_id
     FROM  per_gen_hierarchy_nodes pgn,
           hr_all_organization_units hou,
           hr_organization_information hoi1,
           hr_organization_information hoi2,
           hr_organization_information hoi3
    WHERE  pgn.hierarchy_version_id = p_hierarchy_version_id
    AND    pgn.node_type = 'PAR'
    AND    hou.organization_id = p_business_group_id
    AND    pgn.business_group_id = p_business_group_id
    AND    hou.organization_id = pgn.business_group_id --BUG3646445
    AND    hoi3.org_information_context  = 'VETS_EEO_Dup'
    AND    hoi3.organization_id = pgn.entity_id
    AND    hoi2.org_information_context  = 'EEO_REPORT'
    AND    hoi2.organization_id = hou.organization_id
    AND    hoi1.org_information_context  = 'EEO_Spec'
    AND    hoi1.organization_id = pgn.entity_id;

  -- find out if over 100 people IN company for 13
  CURSOR c_max IS
     SELECT count('num_emps')
       FROM per_all_assignments_f paf
      WHERE paf.business_group_id = p_business_group_id
        AND paf.primary_flag = 'Y'
        AND paf.assignment_type = 'E'
        AND p_start_date > paf.effective_start_date
        AND p_end_date < paf.effective_end_date
        AND paf.location_id IN
           (SELECT entity_id
            FROM   per_gen_hierarchy_nodes
            WHERE  hierarchy_version_id = p_hierarchy_version_id
            );

  l_max NUMBER;

BEGIN --set_org_details

  OPEN c_org_details;
  FETCH c_org_details INTO l_org_rec.org_name,
                             l_org_rec.company_number_1,
                             l_org_rec.c2_affiliated_14,
                             l_org_rec.gov_contract_15,
                             l_org_rec.duns_16,
                             l_org_rec.apprentices_emp_19,
                             l_org_rec.sic_20,
                             l_org_rec.naics_21,
                             l_org_rec.title_cert_off_22,
                             l_org_rec.name_cert_off_23,
                             l_org_rec.tel_num_24,
                             l_org_rec.fax_num_25,
                             l_org_rec.email_26,
                             l_org_rec.par_ent_org_id;

  CLOSE c_org_details;

  OPEN c_max;
  FETCH c_max INTO l_max;
  CLOSE c_max;

  IF l_max >= 100 THEN
         l_org_rec.c1_over_100_13 := '1';
  ELSE
         l_org_rec.c1_over_100_13 := '2';
  END IF;

      /* fnd_file.put_line
      (which => fnd_file.log,
       buff  => 'p_start_date '||p_start_date);
       --
       fnd_file.put_line
      (which => fnd_file.log,
       buff  => 'p_end_date '||p_end_date);
       --
      fnd_file.put_line
      (which => fnd_file.log,
       buff  => 'l_org_rec.l_d1_payroll_period_18 before '
                ||l_org_rec.l_d1_payroll_period_18);  */

      l_org_rec.l_d1_payroll_period_18 :=
      (TO_CHAR(p_start_date,'MMDDYYYY')
      ||
      TO_CHAR(p_end_date,'MMDDYYYY'));
      --
      -- for selection FROM location eit
      --
     --  Bug 7447266
     -- l_report_year := SUBSTR(l_org_rec.l_d1_payroll_period_18,1,4);
     l_report_year := SUBSTR(l_org_rec.l_d1_payroll_period_18,5,4);

      l_prev_year_filed := TO_CHAR(TO_NUMBER(l_report_year - 1));
      /*fnd_file.put_line
      (which => fnd_file.log,
       buff  => 'l_org_rec.name_cert_off_23 '
                ||l_org_rec.name_cert_off_23);
      fnd_file.put_line
      (which => fnd_file.log,
       buff  => 'sustr of l_org_rec.name_cert_off_23 '
                ||substr(l_org_rec.name_cert_off_23,1,3)); */

   BEGIN --Local1
      -- error IF required fields not present.
      IF l_org_rec.company_number_1 IS NULL THEN
         fnd_file.put_line
           (which => fnd_file.log,
            buff  => '==================================');
         fnd_file.put_line
           (which => fnd_file.log,
            buff  => '*** Field 1 - company NUMBER is blank, '
            ||'but this is a required field - Please enter. '
            ||'This is entered IN the GRE parent Entity Data '
            ||'nav=Organization/Description/Parent Entity/Others ***');
         fnd_file.put_line
           (which => fnd_file.log,
            buff  => '==================================');
         fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Field 14 - Question C2 may also be blank '
            ||'(is company affiliated with Companies of at least 100 emps?) '
            ||'This is also a required field - which the app will force you to '
            ||'enter at organization level for the GRE parent Entity Data. '
            ||'nav=Organization/Description/Parent Entity/Others ');
         fnd_file.put_line
           (which => fnd_file.log,
            buff  => '==================================');
         RAISE hr_utility.hr_error;
      END IF;
   END;  --Local1

   IF UPPER(SUBSTR(l_org_rec.title_cert_off_22,1,3)) = UPPER('THE') THEN
         l_org_rec.title_cert_off_22 :=
         ltrim(l_org_rec.title_cert_off_22,'THEthe');
         l_org_rec.title_cert_off_22 :=
         l_org_rec.title_cert_off_22||' The';
   END IF;

   IF UPPER(SUBSTR(l_org_rec.name_cert_off_23,1,3)) = UPPER('THE') THEN
         l_org_rec.name_cert_off_23 :=
         ltrim(l_org_rec.name_cert_off_23,'THEthe');
        -- fnd_file.put_line
        --(which => fnd_file.log,
        --  buff  => 'l_org_rec.name_cert_off_23 '
         --       ||l_org_rec.name_cert_off_23);
         l_org_rec.name_cert_off_23 :=
         l_org_rec.name_cert_off_23||' The';
        -- fnd_file.put_line
         --(which => fnd_file.log,
      -- buff  => 'l_org_rec.name_cert_off_23 '
               -- ||l_org_rec.name_cert_off_23);
   END IF;

      --
/*      fnd_file.put_line
      (which => fnd_file.log,
       buff  => 'l_org_rec.l_d1_payroll_period_18 after '
                ||l_org_rec.l_d1_payroll_period_18);
      --
      fnd_file.put_line
      (which => fnd_file.log,
       buff  => 'l_report_year '||l_report_year);
      --
      fnd_file.put_line
      (which => fnd_file.log,
       buff  => 'l_prev_year_filed '||l_prev_year_filed);  */

END set_org_details;


PROCEDURE write_consolidated_record is

  l_string VARCHAR2(3000);
  l_proc   VARCHAR2(60) := g_package || 'write_consolidated_record';

BEGIN

  hr_utility.set_location('Entering..' || l_proc,10);
  hr_utility.trace('l_consol_rec.unit_number_3 : ' || l_consol_rec.unit_number_3);
  hr_utility.trace('l_consol_rec.unit_name_4   : ' || l_consol_rec.unit_name_4);
  hr_utility.trace('l_consol_rec.unit_address_5: ' || l_consol_rec.unit_address_req_5);

  IF l_org_rec.form_type = 'M' THEN

     IF l_consol_rec.unit_name_4 IS NULL THEN

           fnd_file.put_line
           (which => fnd_file.log,
            buff  => '                                        ');

           fnd_file.put_line
           (which => fnd_file.log,
            buff  => ' UNIT NAME OR NUMBER SHOULD NOT BE NULL FOR CONSOLIDATED REPORT.'
            ||'THIS INFORMATION COMES FROM HEADQUARTERS ESTABLISHMENT.'
            ||'The unit NUMBER  IS ' || l_consol_rec.unit_number_3
            ||'The unit name    IS ' || l_consol_rec.unit_name_4
	    ||'The unit address IS ' || l_consol_rec.unit_address_req_5);

           fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Reported field IN the EEO1 Specific Data Extra '
            ||'Information Type ');

           fnd_file.put_line
           (which => fnd_file.log,
            buff  => '                                        ');

     END IF; --l_consol_rec.unit_name_4 IS NULL

     l_org_rec.l_status_code_2 := '2';

    l_consol_rec.o_1_total_cat := l_consol_rec.a_1_hl_male +
                                                   l_consol_rec.b_1_hl_female +
						   l_consol_rec.c_1_white_male +
						   l_consol_rec.d_1_black_male +
						   l_consol_rec.e_1_latin_male +
						   l_consol_rec.f_1_aspac_male +
						   l_consol_rec.g_1_ameri_male +
						   l_consol_rec.h_1_tmraces_male +
						   l_consol_rec.i_1_white_fem +
						   l_consol_rec.j_1_black_fem +
						   l_consol_rec.k_1_latin_fem +
						   l_consol_rec.l_1_aspac_fem +
						   l_consol_rec.m_1_ameri_fem +
						   l_consol_rec.n_1_tmraces_female;

    l_consol_rec.o_2_total_cat := l_consol_rec.a_2_hl_male +
                                                   l_consol_rec.b_2_hl_female +
						   l_consol_rec.c_2_white_male +
						   l_consol_rec.d_2_black_male +
						   l_consol_rec.e_2_latin_male +
						   l_consol_rec.f_2_aspac_male +
						   l_consol_rec.g_2_ameri_male +
						   l_consol_rec.h_2_tmraces_male +
						   l_consol_rec.i_2_white_fem +
						   l_consol_rec.j_2_black_fem +
						   l_consol_rec.k_2_latin_fem +
						   l_consol_rec.l_2_aspac_fem +
						   l_consol_rec.m_2_ameri_fem +
						   l_consol_rec.n_2_tmraces_female;

    l_consol_rec.o_3_total_cat := l_consol_rec.a_3_hl_male +
                                                   l_consol_rec.b_3_hl_female +
						   l_consol_rec.c_3_white_male +
						   l_consol_rec.d_3_black_male +
						   l_consol_rec.e_3_latin_male +
						   l_consol_rec.f_3_aspac_male +
						   l_consol_rec.g_3_ameri_male +
						   l_consol_rec.h_3_tmraces_male +
						   l_consol_rec.i_3_white_fem +
						   l_consol_rec.j_3_black_fem +
						   l_consol_rec.k_3_latin_fem +
						   l_consol_rec.l_3_aspac_fem +
						   l_consol_rec.m_3_ameri_fem +
						   l_consol_rec.n_3_tmraces_female;

    l_consol_rec.o_4_total_cat := l_consol_rec.a_4_hl_male +
                                                   l_consol_rec.b_4_hl_female +
						   l_consol_rec.c_4_white_male +
						   l_consol_rec.d_4_black_male +
						   l_consol_rec.e_4_latin_male +
						   l_consol_rec.f_4_aspac_male +
						   l_consol_rec.g_4_ameri_male +
						   l_consol_rec.h_4_tmraces_male +
						   l_consol_rec.i_4_white_fem +
						   l_consol_rec.j_4_black_fem +
						   l_consol_rec.k_4_latin_fem +
						   l_consol_rec.l_4_aspac_fem +
						   l_consol_rec.m_4_ameri_fem +
						   l_consol_rec.n_4_tmraces_female;

    l_consol_rec.o_5_total_cat := l_consol_rec.a_5_hl_male +
                                                   l_consol_rec.b_5_hl_female +
						   l_consol_rec.c_5_white_male +
						   l_consol_rec.d_5_black_male +
						   l_consol_rec.e_5_latin_male +
						   l_consol_rec.f_5_aspac_male +
						   l_consol_rec.g_5_ameri_male +
						   l_consol_rec.h_5_tmraces_male +
						   l_consol_rec.i_5_white_fem +
						   l_consol_rec.j_5_black_fem +
						   l_consol_rec.k_5_latin_fem +
						   l_consol_rec.l_5_aspac_fem +
						   l_consol_rec.m_5_ameri_fem +
						   l_consol_rec.n_5_tmraces_female;

    l_consol_rec.o_6_total_cat := l_consol_rec.a_6_hl_male +
                                                   l_consol_rec.b_6_hl_female +
						   l_consol_rec.c_6_white_male +
						   l_consol_rec.d_6_black_male +
						   l_consol_rec.e_6_latin_male +
						   l_consol_rec.f_6_aspac_male +
						   l_consol_rec.g_6_ameri_male +
						   l_consol_rec.h_6_tmraces_male +
						   l_consol_rec.i_6_white_fem +
						   l_consol_rec.j_6_black_fem +
						   l_consol_rec.k_6_latin_fem +
						   l_consol_rec.l_6_aspac_fem +
						   l_consol_rec.m_6_ameri_fem +
						   l_consol_rec.n_6_tmraces_female;

    l_consol_rec.o_7_total_cat := l_consol_rec.a_7_hl_male +
                                                   l_consol_rec.b_7_hl_female +
						   l_consol_rec.c_7_white_male +
						   l_consol_rec.d_7_black_male +
						   l_consol_rec.e_7_latin_male +
						   l_consol_rec.f_7_aspac_male +
						   l_consol_rec.g_7_ameri_male +
						   l_consol_rec.h_7_tmraces_male +
						   l_consol_rec.i_7_white_fem +
						   l_consol_rec.j_7_black_fem +
						   l_consol_rec.k_7_latin_fem +
						   l_consol_rec.l_7_aspac_fem +
						   l_consol_rec.m_7_ameri_fem +
						   l_consol_rec.n_7_tmraces_female;

    l_consol_rec.o_8_total_cat := l_consol_rec.a_8_hl_male +
                                                   l_consol_rec.b_8_hl_female +
						   l_consol_rec.c_8_white_male +
						   l_consol_rec.d_8_black_male +
						   l_consol_rec.e_8_latin_male +
						   l_consol_rec.f_8_aspac_male +
						   l_consol_rec.g_8_ameri_male +
						   l_consol_rec.h_8_tmraces_male +
						   l_consol_rec.i_8_white_fem +
						   l_consol_rec.j_8_black_fem +
						   l_consol_rec.k_8_latin_fem +
						   l_consol_rec.l_8_aspac_fem +
						   l_consol_rec.m_8_ameri_fem +
						   l_consol_rec.n_8_tmraces_female;

    l_consol_rec.o_9_total_cat := l_consol_rec.a_9_hl_male +
                                                   l_consol_rec.b_9_hl_female +
						   l_consol_rec.c_9_white_male +
						   l_consol_rec.d_9_black_male +
						   l_consol_rec.e_9_latin_male +
						   l_consol_rec.f_9_aspac_male +
						   l_consol_rec.g_9_ameri_male +
						   l_consol_rec.h_9_tmraces_male +
						   l_consol_rec.i_9_white_fem +
						   l_consol_rec.j_9_black_fem +
						   l_consol_rec.k_9_latin_fem +
						   l_consol_rec.l_9_aspac_fem +
						   l_consol_rec.m_9_ameri_fem +
						   l_consol_rec.n_9_tmraces_female;

  l_consol_rec.o_10_total_cat := l_consol_rec.a_10_hl_male +
                                                   l_consol_rec.b_10_hl_female +
						   l_consol_rec.c_10_white_male +
						   l_consol_rec.d_10_black_male +
						   l_consol_rec.e_10_latin_male +
						   l_consol_rec.f_10_aspac_male +
						   l_consol_rec.g_10_ameri_male +
						   l_consol_rec.h_10_tmraces_male +
						   l_consol_rec.i_10_white_fem +
						   l_consol_rec.j_10_black_fem +
						   l_consol_rec.k_10_latin_fem +
						   l_consol_rec.l_10_aspac_fem +
						   l_consol_rec.m_10_ameri_fem +
						   l_consol_rec.n_10_tmraces_female;

l_consol_rec.o_10_grand_total := l_consol_rec.a_10_grand_total +
                                                     l_consol_rec.b_10_grand_total +
						     l_consol_rec.c_10_grand_total +
						     l_consol_rec.d_10_grand_total +
						     l_consol_rec.e_10_grand_total +
						     l_consol_rec.f_10_grand_total +
						     l_consol_rec.g_10_grand_total +
						     l_consol_rec.h_10_grand_total +
						     l_consol_rec.i_10_grand_total +
						     l_consol_rec.j_10_grand_total +
						     l_consol_rec.k_10_grand_total +
						     l_consol_rec.l_10_grand_total +
						     l_consol_rec.m_10_grand_total +
						     l_consol_rec.n_10_grand_total;

     l_string :=
              -- 1
              nvl(lpad(l_org_rec.company_number_1,7,0),(lpad(' ',7,' ')))
              -- 2
              -- status code always 2 for consol rpt
              ||'2'
              -- 3
              ||nvl(lpad(SUBSTR(l_consol_rec.unit_number_3,1,7),7,0),
              ('0000000'))
              -- 4
              ||nvl(rpad(ltrim(replace(replace(l_consol_rec.unit_name_4,',','')
              ,'.',''),'1234567890'),35,' '),(lpad(' ',35,' ')))
              -- 5
              ||nvl(rpad(replace(replace
              (SUBSTR(l_consol_rec.unit_address_req_5,1,34)
              ,',',''),'.',''),34,' '),(lpad(' ',34,' ')))
              -- 6
              ||nvl(rpad(replace(replace(SUBSTR(l_consol_rec.unit_address_6,1,25)
	      ,',',''),'.',''),25,' '),(lpad(' ',25,' ')))
              -- 7
              ||nvl(rpad(replace(replace(SUBSTR(l_consol_rec.city_7,1,20),',','')
	      ,'.',''),20,' '),(lpad(' ',20,' ')))
              -- 8
              ||nvl(rpad(l_consol_rec.state_8,2),(lpad(' ',8,' ')))
              -- 9
              ||nvl(rpad(l_consol_rec.zip_code_9,5),(lpad(' ',5,' ')))
              -- 10
              ||rpad(l_consol_rec.reported_last_year_11,1)
              -- 11
              ||rpad(l_org_rec.c1_over_100_13,1)
              -- 12
              ||rpad(l_org_rec.c2_affiliated_14,1)
              -- 13
	      ||rpad(nvl(l_consol_rec.gov_contract_15,l_org_rec.gov_contract_15)
              ,1)
              -- 14
	      ||nvl(lpad(nvl(l_consol_rec.duns_16,l_org_rec.duns_16),9,0)
              ,(lpad(' ',9,' ')))
              -- 15
	      ||nvl(rpad(replace(replace(l_consol_rec.county_17,',',''),'.','')
              ,18),(lpad(' ',18,' ')))
              -- 16
              ||rpad(l_org_rec.l_d1_payroll_period_18,16)
              -- 17
	      ||nvl(lpad(nvl(l_consol_rec.naics_21,l_org_rec.naics_21),6,0), --BUG4494412
              (lpad(' ',6,' ')))
             -- 18
	     ||nvl(rpad(ltrim(replace(replace(l_org_rec.title_cert_off_22,',','')
              ,'.',''),'1234567890'),35),(lpad(' ',35,' ')))
              -- 19
	      ||nvl(rpad(ltrim(replace(replace(l_org_rec.name_cert_off_23,',','')
              ,'.',''),'1234567890'),35),(lpad(' ',35,' ')))
             -- 20
              ||nvl(rpad(replace(replace(l_org_rec.tel_num_24,',',''),'.','')
              ,10),(lpad(' ',10,' ')))
	      -- 21
	      ||nvl(rpad(replace(l_org_rec.email_26,',',''),40),
              (lpad(' ',40,' ')))||
	      --
              lpad(l_consol_rec.a_1_hl_male,6,0)||
	      lpad(l_consol_rec.b_1_hl_female,6,0)||
              lpad(l_consol_rec.c_1_white_male,6,0)||
              lpad(l_consol_rec.d_1_black_male,6,0)||
              lpad(l_consol_rec.e_1_latin_male,6,0)||
              lpad(l_consol_rec.f_1_aspac_male,6,0)||
              lpad(l_consol_rec.g_1_ameri_male,6,0)||
	      lpad(l_consol_rec.h_1_tmraces_male,6,0)||
              lpad(l_consol_rec.i_1_white_fem,6,0)||
              lpad(l_consol_rec.j_1_black_fem,6,0)||
              lpad(l_consol_rec.k_1_latin_fem,6,0)||
              lpad(l_consol_rec.l_1_aspac_fem,6,0)||
              lpad(l_consol_rec.m_1_ameri_fem,6,0)||
	      lpad(l_consol_rec.n_1_tmraces_female,6,0)||
	      lpad(l_consol_rec.o_1_total_cat,7,0)||
              --
              lpad(l_consol_rec.a_2_hl_male,6,0)||
	      lpad(l_consol_rec.b_2_hl_female,6,0)||
              lpad(l_consol_rec.c_2_white_male,6,0)||
              lpad(l_consol_rec.d_2_black_male,6,0)||
              lpad(l_consol_rec.e_2_latin_male,6,0)||
              lpad(l_consol_rec.f_2_aspac_male,6,0)||
              lpad(l_consol_rec.g_2_ameri_male,6,0)||
	      lpad(l_consol_rec.h_2_tmraces_male,6,0)||
              lpad(l_consol_rec.i_2_white_fem,6,0)||
              lpad(l_consol_rec.j_2_black_fem,6,0)||
              lpad(l_consol_rec.k_2_latin_fem,6,0)||
              lpad(l_consol_rec.l_2_aspac_fem,6,0)||
              lpad(l_consol_rec.m_2_ameri_fem,6,0)||
	      lpad(l_consol_rec.n_2_tmraces_female,6,0)||
	      lpad(l_consol_rec.o_2_total_cat,7,0)||
              --
              lpad(l_consol_rec.a_3_hl_male,6,0)||
	      lpad(l_consol_rec.b_3_hl_female,6,0)||
              lpad(l_consol_rec.c_3_white_male,6,0)||
              lpad(l_consol_rec.d_3_black_male,6,0)||
              lpad(l_consol_rec.e_3_latin_male,6,0)||
              lpad(l_consol_rec.f_3_aspac_male,6,0)||
              lpad(l_consol_rec.g_3_ameri_male,6,0)||
	      lpad(l_consol_rec.h_3_tmraces_male,6,0)||
              lpad(l_consol_rec.i_3_white_fem,6,0)||
              lpad(l_consol_rec.j_3_black_fem,6,0)||
              lpad(l_consol_rec.k_3_latin_fem,6,0)||
              lpad(l_consol_rec.l_3_aspac_fem,6,0)||
              lpad(l_consol_rec.m_3_ameri_fem,6,0)||
	      lpad(l_consol_rec.n_3_tmraces_female,6,0)||
	      lpad(l_consol_rec.o_3_total_cat,7,0)||
              --
              lpad(l_consol_rec.a_4_hl_male,6,0)||
	      lpad(l_consol_rec.b_4_hl_female,6,0)||
              lpad(l_consol_rec.c_4_white_male,6,0)||
              lpad(l_consol_rec.d_4_black_male,6,0)||
              lpad(l_consol_rec.e_4_latin_male,6,0)||
              lpad(l_consol_rec.f_4_aspac_male,6,0)||
              lpad(l_consol_rec.g_4_ameri_male,6,0)||
	      lpad(l_consol_rec.h_4_tmraces_male,6,0)||
              lpad(l_consol_rec.i_4_white_fem,6,0)||
              lpad(l_consol_rec.j_4_black_fem,6,0)||
              lpad(l_consol_rec.k_4_latin_fem,6,0)||
              lpad(l_consol_rec.l_4_aspac_fem,6,0)||
              lpad(l_consol_rec.m_4_ameri_fem,6,0)||
	      lpad(l_consol_rec.n_4_tmraces_female,6,0)||
	      lpad(l_consol_rec.o_4_total_cat,7,0)||
              --
              lpad(l_consol_rec.a_5_hl_male,6,0)||
	      lpad(l_consol_rec.b_5_hl_female,6,0)||
              lpad(l_consol_rec.c_5_white_male,6,0)||
              lpad(l_consol_rec.d_5_black_male,6,0)||
              lpad(l_consol_rec.e_5_latin_male,6,0)||
              lpad(l_consol_rec.f_5_aspac_male,6,0)||
              lpad(l_consol_rec.g_5_ameri_male,6,0)||
	      lpad(l_consol_rec.h_5_tmraces_male,6,0)||
              lpad(l_consol_rec.i_5_white_fem,6,0)||
              lpad(l_consol_rec.j_5_black_fem,6,0)||
              lpad(l_consol_rec.k_5_latin_fem,6,0)||
              lpad(l_consol_rec.l_5_aspac_fem,6,0)||
              lpad(l_consol_rec.m_5_ameri_fem,6,0)||
	      lpad(l_consol_rec.n_5_tmraces_female,6,0)||
	      lpad(l_consol_rec.o_5_total_cat,7,0)||
              --
              lpad(l_consol_rec.a_6_hl_male,6,0)||
	      lpad(l_consol_rec.b_6_hl_female,6,0)||
              lpad(l_consol_rec.c_6_white_male,6,0)||
              lpad(l_consol_rec.d_6_black_male,6,0)||
              lpad(l_consol_rec.e_6_latin_male,6,0)||
              lpad(l_consol_rec.f_6_aspac_male,6,0)||
              lpad(l_consol_rec.g_6_ameri_male,6,0)||
	      lpad(l_consol_rec.h_6_tmraces_male,6,0)||
              lpad(l_consol_rec.i_6_white_fem,6,0)||
              lpad(l_consol_rec.j_6_black_fem,6,0)||
              lpad(l_consol_rec.k_6_latin_fem,6,0)||
              lpad(l_consol_rec.l_6_aspac_fem,6,0)||
              lpad(l_consol_rec.m_6_ameri_fem,6,0)||
	      lpad(l_consol_rec.n_6_tmraces_female,6,0)||
	      lpad(l_consol_rec.o_6_total_cat,7,0)||
              --
              lpad(l_consol_rec.a_7_hl_male,6,0)||
	      lpad(l_consol_rec.b_7_hl_female,6,0)||
              lpad(l_consol_rec.c_7_white_male,6,0)||
              lpad(l_consol_rec.d_7_black_male,6,0)||
              lpad(l_consol_rec.e_7_latin_male,6,0)||
              lpad(l_consol_rec.f_7_aspac_male,6,0)||
              lpad(l_consol_rec.g_7_ameri_male,6,0)||
	      lpad(l_consol_rec.h_7_tmraces_male,6,0)||
              lpad(l_consol_rec.i_7_white_fem,6,0)||
              lpad(l_consol_rec.j_7_black_fem,6,0)||
              lpad(l_consol_rec.k_7_latin_fem,6,0)||
              lpad(l_consol_rec.l_7_aspac_fem,6,0)||
              lpad(l_consol_rec.m_7_ameri_fem,6,0)||
	      lpad(l_consol_rec.n_7_tmraces_female,6,0)||
	      lpad(l_consol_rec.o_7_total_cat,7,0)||
              --
              lpad(l_consol_rec.a_8_hl_male,6,0)||
	      lpad(l_consol_rec.b_8_hl_female,6,0)||
              lpad(l_consol_rec.c_8_white_male,6,0)||
              lpad(l_consol_rec.d_8_black_male,6,0)||
              lpad(l_consol_rec.e_8_latin_male,6,0)||
              lpad(l_consol_rec.f_8_aspac_male,6,0)||
              lpad(l_consol_rec.g_8_ameri_male,6,0)||
	      lpad(l_consol_rec.h_8_tmraces_male,6,0)||
              lpad(l_consol_rec.i_8_white_fem,6,0)||
              lpad(l_consol_rec.j_8_black_fem,6,0)||
              lpad(l_consol_rec.k_8_latin_fem,6,0)||
              lpad(l_consol_rec.l_8_aspac_fem,6,0)||
              lpad(l_consol_rec.m_8_ameri_fem,6,0)||
	      lpad(l_consol_rec.n_8_tmraces_female,6,0)||
	      lpad(l_consol_rec.o_8_total_cat,7,0)||
              --
              lpad(l_consol_rec.a_9_hl_male,6,0)||
	      lpad(l_consol_rec.b_9_hl_female,6,0)||
              lpad(l_consol_rec.c_9_white_male,6,0)||
              lpad(l_consol_rec.d_9_black_male,6,0)||
              lpad(l_consol_rec.e_9_latin_male,6,0)||
              lpad(l_consol_rec.f_9_aspac_male,6,0)||
              lpad(l_consol_rec.g_9_ameri_male,6,0)||
	      lpad(l_consol_rec.h_9_tmraces_male,6,0)||
              lpad(l_consol_rec.i_9_white_fem,6,0)||
              lpad(l_consol_rec.j_9_black_fem,6,0)||
              lpad(l_consol_rec.k_9_latin_fem,6,0)||
              lpad(l_consol_rec.l_9_aspac_fem,6,0)||
              lpad(l_consol_rec.m_9_ameri_fem,6,0)||
	      lpad(l_consol_rec.n_9_tmraces_female,6,0)||
	      lpad(l_consol_rec.o_9_total_cat,7,0)||
              --
	      lpad(l_consol_rec.a_10_hl_male,6,0)||
	      lpad(l_consol_rec.b_10_hl_female,6,0)||
              lpad(l_consol_rec.c_10_white_male,6,0)||
              lpad(l_consol_rec.d_10_black_male,6,0)||
              lpad(l_consol_rec.e_10_latin_male,6,0)||
              lpad(l_consol_rec.f_10_aspac_male,6,0)||
              lpad(l_consol_rec.g_10_ameri_male,6,0)||
	      lpad(l_consol_rec.h_10_tmraces_male,6,0)||
              lpad(l_consol_rec.i_10_white_fem,6,0)||
              lpad(l_consol_rec.j_10_black_fem,6,0)||
              lpad(l_consol_rec.k_10_latin_fem,6,0)||
              lpad(l_consol_rec.l_10_aspac_fem,6,0)||
              lpad(l_consol_rec.m_10_ameri_fem,6,0)||
	      lpad(l_consol_rec.n_10_tmraces_female,6,0)||
	      lpad(l_consol_rec.o_10_total_cat,7,0)||
	      --
              lpad(l_consol_rec.a_10_grand_total,6,0) ||
              lpad(l_consol_rec.b_10_grand_total,6,0) ||
              lpad(l_consol_rec.c_10_grand_total,6,0) ||
              lpad(l_consol_rec.d_10_grand_total,6,0) ||
              lpad(l_consol_rec.e_10_grand_total,6,0) ||
              lpad(l_consol_rec.f_10_grand_total,6,0) ||
              lpad(l_consol_rec.g_10_grand_total,6,0) ||
              lpad(l_consol_rec.h_10_grand_total,6,0) ||
              lpad(l_consol_rec.i_10_grand_total,6,0) ||
              lpad(l_consol_rec.j_10_grand_total,6,0) ||
              lpad(l_consol_rec.k_10_grand_total,6,0)||
	      lpad(l_consol_rec.l_10_grand_total,6,0)||
	      lpad(l_consol_rec.m_10_grand_total,6,0)||
	      lpad(l_consol_rec.n_10_grand_total,6,0)||
	      lpad(l_consol_rec.o_10_grand_total,7,0);
  --
 /* g_message_text := 'd1) l_consol_rec.a_1_total_mf IN string '
                    ||l_consol_rec.a_1_total_mf;
     fnd_file.put_line
     (which => fnd_file.log,
      buff  => g_message_text);
 g_message_text := '                                                          ';
     fnd_file.put_line
        (which => fnd_file.log,
         buff  => g_message_text);
 g_message_text := 'e1) put line for l_string for consolidated RECORD ';
     fnd_file.put_line
        (which => fnd_file.log,
         buff  => g_message_text);
 g_message_text := '                                   ';
     fnd_file.put_line
        (which => fnd_file.log,
         buff  => g_message_text); */
  fnd_file.put_line
    (which => fnd_file.output,
     buff  => l_string);

END IF;  -- l_org_rec.form_type = 'M'
    hr_utility.set_location('Leaving..' || l_proc,100);
END write_consolidated_record;



PROCEDURE write_establishment_record IS

  l_string VARCHAR2 (3000);
  l_proc   VARCHAR2(60) := g_package || 'write_establishment_record';

BEGIN

  hr_utility.set_location('Entering..' || l_proc,10);
  hr_utility.trace('l_estab_rec.unit_number_3 : '||l_estab_rec.unit_number_3);
  hr_utility.trace('l_estab_rec.unit_name_4   : '||l_estab_rec.unit_name_4);
  hr_utility.trace('l_estab_rec.unit_address_5: '||l_estab_rec.unit_address_req_5);

/*  fnd_file.put_line
     (which => fnd_file.log,
      buff  => '                                             ');
  fnd_file.put_line
     (which => fnd_file.log,
      buff  => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
  fnd_file.put_line
     (which => fnd_file.log,
      buff  => ' PROCEDURE write_establishment_record  ');
    fnd_file.put_line
     (which => fnd_file.log,
      buff  => '-------------------------------------------------------------');
      */
  --
  -- Set Status
  --
  hr_utility.trace('l_org_rec.form_type : ' || l_org_rec.form_type);
  IF l_org_rec.form_type = 'S' THEN

     IF l_estab_rec.reported_last_year_11 = '2' THEN
        hr_utility.set_location(l_proc,15);
        l_org_rec.l_status_code_2 := '9';
     ELSE
        hr_utility.set_location(l_proc,16);
        l_org_rec.l_status_code_2 := '1';
     END IF;

  ELSE  --l_org_rec.form_type = 'S'
     --  IF under 50 employees THEN always status 8 ..  unless status 3

     IF l_estab_rec.reported_last_year_11 = '2' AND l_estab_rec.max_count = 'Y' THEN

        IF l_estab_rec.hq = 'Y' THEN
		l_org_rec.l_status_code_2 := '3';
		hr_utility.set_location(l_proc,30);
		-- BUG4494412
		l_consol_rec.unit_number_3 := l_estab_rec.unit_number_3;
		l_consol_rec.unit_name_4 := l_estab_rec.unit_name_4;
		l_consol_rec.unit_address_req_5 := l_estab_rec.unit_address_req_5;
		l_consol_rec.unit_address_6 := l_estab_rec.unit_address_6;
		l_consol_rec.city_7 := l_estab_rec.city_7;
		l_consol_rec.state_8 := l_estab_rec.state_8;
		l_consol_rec.zip_code_9 := l_estab_rec.zip_code_9;
		l_consol_rec.zip_code_last_4_10 := l_estab_rec.zip_code_last_4_10;
		l_consol_rec.reported_last_year_11 := l_estab_rec.reported_last_year_11;
		l_consol_rec.ein_12 := l_estab_rec.ein_12;
		l_consol_rec.gov_contract_15 := l_estab_rec.gov_contract_15;
		l_consol_rec.duns_16 := l_estab_rec.duns_16;
		l_consol_rec.county_17 := l_estab_rec.county_17;
		l_consol_rec.apprentices_emp_19 := l_estab_rec.apprentices_emp_19;
		l_consol_rec.sic_20 := l_estab_rec.sic_20;
		l_consol_rec.naics_21 := l_estab_rec.naics_21;
        ELSE
		hr_utility.set_location(l_proc,20);
                l_org_rec.l_status_code_2 := '9';
        END IF;

        ELSIF l_estab_rec.hq = 'Y'
           AND l_estab_rec.reported_last_year_11 = '1' THEN

        hr_utility.set_location(l_proc,40);
        l_org_rec.l_status_code_2 := '3';
        -- BUG4494412
        l_consol_rec.unit_number_3 := l_estab_rec.unit_number_3;
        l_consol_rec.unit_name_4 := l_estab_rec.unit_name_4;
        l_consol_rec.unit_address_req_5 := l_estab_rec.unit_address_req_5;
        l_consol_rec.unit_address_6 := l_estab_rec.unit_address_6;
        l_consol_rec.city_7 := l_estab_rec.city_7;
        l_consol_rec.state_8 := l_estab_rec.state_8;
        l_consol_rec.zip_code_9 := l_estab_rec.zip_code_9;
        l_consol_rec.zip_code_last_4_10 := l_estab_rec.zip_code_last_4_10;
        l_consol_rec.reported_last_year_11 := l_estab_rec.reported_last_year_11;
        l_consol_rec.ein_12 := l_estab_rec.ein_12;
        l_consol_rec.gov_contract_15 := l_estab_rec.gov_contract_15;
        l_consol_rec.duns_16 := l_estab_rec.duns_16;
        l_consol_rec.county_17 := l_estab_rec.county_17;
        l_consol_rec.apprentices_emp_19 := l_estab_rec.apprentices_emp_19;
        l_consol_rec.sic_20 := l_estab_rec.sic_20;
        l_consol_rec.naics_21 := l_estab_rec.naics_21;
        --
        -- headquarters report.
     ELSIF l_estab_rec.hq = 'N'
           AND l_estab_rec.max_count = 'Y'
	   AND l_estab_rec.reported_last_year_11 = '1'
     THEN

        hr_utility.set_location(l_proc,50);
        l_org_rec.l_status_code_2 := '4';
        --
        -- not HQ AND less than 50 emps over at location
     ELSIF l_estab_rec.hq = 'N' AND l_estab_rec.max_count = 'N'
     THEN

        hr_utility.set_location(l_proc,60);
        l_org_rec.l_status_code_2 := '8';
        --
        -- not HQ AND under 50 emps at location
        /*
        fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'l_estab_rec.unit_number_3: '||l_estab_rec.unit_number_3);
            */
      --  END IF;

     END IF; --l_estab_rec.reported_last_year_11 = '2'
     hr_utility.trace('l_org_rec.l_status_code_2 : ' || l_org_rec.l_status_code_2);
     hr_utility.trace('l_estab_rec.unit_number_3 : ' || l_estab_rec.unit_number_3);

     IF l_estab_rec.hq = 'Y' THEN
	l_org_rec.l_status_code_2 := '3';
     END IF;

     IF l_estab_rec.unit_number_3 IS NOT NULL
        AND l_org_rec.l_status_code_2 IN ('8','9') THEN

	   fnd_file.put_line
           (which => fnd_file.log,
            buff  => '                                        ');
           fnd_file.put_line
           (which => fnd_file.log,
            buff  => ' UNIT NUMBER SHOULD BE NULL AS THIS LOCATION('
                     || l_estab_rec.unit_name_4 || ') HAS EITHER '
                     ||'NOT YET BEEN REPORTED OR IS UNDER 50 EMPS');
           fnd_file.put_line
           (which => fnd_file.log,
            buff  => '                                        ');

     ELSIF  l_estab_rec.unit_number_3 IS NULL
               AND l_org_rec.l_status_code_2 IN ('1','3','4','5') THEN

           fnd_file.put_line
           (which => fnd_file.log,
            buff  => '                                        ');
           fnd_file.put_line
           (which => fnd_file.log,
            buff  => '********** UNIT NAME AND NUMBER SHOULD NOT BE NULL AS '
            ||'THIS LOCATION HAS BEEN REPORTED ACCORDING TO THE Previously ');
           fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Reported field IN the EEO1 Specific Data Extra '
            ||'Information Type. '
            ||' The unit NUMBER  IS ' || l_estab_rec.unit_number_3
            ||' The unit name    IS ' || l_estab_rec.unit_name_4
            ||' The unit address IS ' || l_estab_rec.unit_address_req_5
            || ' **********');
           fnd_file.put_line
           (which => fnd_file.log,
            buff  => '                                        ');

     END IF; --l_estab_rec.unit_number_3 IS NOT NULL


     g_message_text := '*2-for estab rec write form TYPE IS* '||l_org_rec.form_type;
     fnd_file.put_line
        (which => fnd_file.log,
         buff  => g_message_text);
     g_message_text := '*2-l_estab_rec.reported_last_year_11 IS* '||l_estab_rec.reported_last_year_11;
     fnd_file.put_line
        (which => fnd_file.log,
         buff  => g_message_text);
     g_message_text := '*2-l_estab_rec.hq IS* '||l_estab_rec.hq ;
     fnd_file.put_line
        (which => fnd_file.log,
         buff  => g_message_text);
     g_message_text := '*2-status code IS* '||l_org_rec.l_status_code_2;
     fnd_file.put_line
        (which => fnd_file.log,
         buff  => g_message_text);
     g_message_text := '                          '||l_org_rec.l_status_code_2;
     fnd_file.put_line
        (which => fnd_file.log,
         buff  => g_message_text);
  END IF; ----l_org_rec.form_type = 'S'
  --
  -- include hawaii IN main processing
  -- IF state = 'HI' everyone counted as white.
  --
  -- Set totals
  --
  -- grand total for column a (Hispanic or latino male)
  --
  hr_utility.set_location(l_proc,70);
  l_estab_rec.a_10_grand_total := nvl(l_estab_rec.a_1_hl_male,0)+
                                  nvl(l_estab_rec.a_2_hl_male,0)+
                                  nvl(l_estab_rec.a_3_hl_male,0)+
                                  nvl(l_estab_rec.a_4_hl_male,0)+
                                  nvl(l_estab_rec.a_5_hl_male,0)+
                                  nvl(l_estab_rec.a_6_hl_male,0)+
                                  nvl(l_estab_rec.a_7_hl_male,0)+
                                  nvl(l_estab_rec.a_8_hl_male,0)+
                                  nvl(l_estab_rec.a_9_hl_male,0)+
				  nvl(l_estab_rec.a_10_hl_male,0);
  --
  hr_utility.trace('l_estab_rec.a_10_grand_total : '||l_estab_rec.a_10_grand_total);
  l_consol_rec.a_10_grand_total := (l_consol_rec.a_10_grand_total +
                                   l_estab_rec.a_10_grand_total);
  hr_utility.trace('l_consol_rec.a_10_grand_total : '||l_consol_rec.a_10_grand_total);
  /*
  g_message_text := 'grand total for estab rep column a '
                    ||'(total males AND females) ';
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => g_message_text);
  g_message_text := 'l_estab_rec.a_10_grand_total *'
                    ||l_estab_rec.a_10_grand_total;
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => g_message_text);
    fnd_file.put_line
    (which => fnd_file.log,
     buff  => '       ');   */
  --
  -- grand total for column b (Hispanic or Latino Female)
  --
  l_estab_rec.b_10_grand_total := nvl(l_estab_rec.b_1_hl_female,0)+
                               nvl(l_estab_rec.b_2_hl_female,0)+
                               nvl(l_estab_rec.b_3_hl_female,0)+
                               nvl(l_estab_rec.b_4_hl_female,0)+
                               nvl(l_estab_rec.b_5_hl_female,0)+
                               nvl(l_estab_rec.b_6_hl_female,0)+
                               nvl(l_estab_rec.b_7_hl_female,0)+
                               nvl(l_estab_rec.b_8_hl_female,0)+
                               nvl(l_estab_rec.b_9_hl_female,0)+
			       nvl(l_estab_rec.b_10_hl_female,0);
  --
  l_consol_rec.b_10_grand_total := (l_consol_rec.b_10_grand_total +
                                    l_estab_rec.b_10_grand_total);
  --
  -- grand total for column c (total white males - non hisp)
  --
   l_estab_rec.c_10_grand_total := nvl(l_estab_rec.c_1_white_male,0)+
                               nvl(l_estab_rec.c_2_white_male,0)+
                               nvl(l_estab_rec.c_3_white_male,0)+
                               nvl(l_estab_rec.c_4_white_male,0)+
                               nvl(l_estab_rec.c_5_white_male,0)+
                               nvl(l_estab_rec.c_6_white_male,0)+
                               nvl(l_estab_rec.c_7_white_male,0)+
                               nvl(l_estab_rec.c_8_white_male,0)+
                               nvl(l_estab_rec.c_9_white_male,0)+
			       nvl(l_estab_rec.c_10_white_male,0);
  --
  l_consol_rec.c_10_grand_total := (l_consol_rec.c_10_grand_total +
                                    l_estab_rec.c_10_grand_total);
  --
  -- grand total for column d (Black or African American - non hisp)
  --
  l_estab_rec.d_10_grand_total := nvl(l_estab_rec.d_1_black_male,0)+
                               nvl(l_estab_rec.d_2_black_male,0)+
                               nvl(l_estab_rec.d_3_black_male,0)+
                               nvl(l_estab_rec.d_4_black_male,0)+
                               nvl(l_estab_rec.d_5_black_male,0)+
                               nvl(l_estab_rec.d_6_black_male,0)+
                               nvl(l_estab_rec.d_7_black_male,0)+
                               nvl(l_estab_rec.d_8_black_male,0)+
                               nvl(l_estab_rec.d_9_black_male,0)+
			        nvl(l_estab_rec.d_10_black_male,0);
  --
  l_consol_rec.d_10_grand_total := (l_consol_rec.d_10_grand_total +
                                    l_estab_rec.d_10_grand_total);
  --
  -- grand total for column e (total Native Hawaiian or Other Pacific Islanderr males - non hisp)
  --
  l_estab_rec.e_10_grand_total := nvl(l_estab_rec.e_1_latin_male,0)+
                               nvl(l_estab_rec.e_2_latin_male,0)+
                               nvl(l_estab_rec.e_3_latin_male,0)+
                               nvl(l_estab_rec.e_4_latin_male,0)+
                               nvl(l_estab_rec.e_5_latin_male,0)+
                               nvl(l_estab_rec.e_6_latin_male,0)+
                               nvl(l_estab_rec.e_7_latin_male,0)+
                               nvl(l_estab_rec.e_8_latin_male,0)+
                               nvl(l_estab_rec.e_9_latin_male,0)+
			       nvl(l_estab_rec.e_10_latin_male,0);
  --
  l_consol_rec.e_10_grand_total := (l_consol_rec.e_10_grand_total +
                                    l_estab_rec.e_10_grand_total);
  --
  -- grand total for column f (total Asian males - non hisp)
  --
  l_estab_rec.f_10_grand_total := nvl(l_estab_rec.f_1_aspac_male,0)+
                               nvl(l_estab_rec.f_2_aspac_male,0)+
                               nvl(l_estab_rec.f_3_aspac_male,0)+
                               nvl(l_estab_rec.f_4_aspac_male,0)+
                               nvl(l_estab_rec.f_5_aspac_male,0)+
                               nvl(l_estab_rec.f_6_aspac_male,0)+
                               nvl(l_estab_rec.f_7_aspac_male,0)+
                               nvl(l_estab_rec.f_8_aspac_male,0)+
                               nvl(l_estab_rec.f_9_aspac_male,0)+
			       nvl(l_estab_rec.f_10_aspac_male,0);
  --
  l_consol_rec.f_10_grand_total := (l_consol_rec.f_10_grand_total +
                                    l_estab_rec.f_10_grand_total);
  --
  -- grand total for column g (total American Indian or Alaska Native males - non hisp)
  --
  l_estab_rec.g_10_grand_total := nvl(l_estab_rec.g_1_ameri_male,0)+
                               nvl(l_estab_rec.g_2_ameri_male,0)+
                               nvl(l_estab_rec.g_3_ameri_male,0)+
                               nvl(l_estab_rec.g_4_ameri_male,0)+
                               nvl(l_estab_rec.g_5_ameri_male,0)+
                               nvl(l_estab_rec.g_6_ameri_male,0)+
                               nvl(l_estab_rec.g_7_ameri_male,0)+
                               nvl(l_estab_rec.g_8_ameri_male,0)+
                               nvl(l_estab_rec.g_9_ameri_male,0)+
			       nvl(l_estab_rec.g_10_ameri_male,0);
  --
  l_consol_rec.g_10_grand_total := (l_consol_rec.g_10_grand_total +
                                    l_estab_rec.g_10_grand_total);
  --
  -- grand total for column h (total Two  or more races males - non hisp)
  --
  l_estab_rec.h_10_grand_total := nvl(l_estab_rec.h_1_tmraces_male,0)+
                               nvl(l_estab_rec.h_2_tmraces_male,0)+
                               nvl(l_estab_rec.h_3_tmraces_male,0)+
                               nvl(l_estab_rec.h_4_tmraces_male,0)+
                               nvl(l_estab_rec.h_5_tmraces_male,0)+
                               nvl(l_estab_rec.h_6_tmraces_male,0)+
                               nvl(l_estab_rec.h_7_tmraces_male,0)+
                               nvl(l_estab_rec.h_8_tmraces_male,0)+
                               nvl(l_estab_rec.h_9_tmraces_male,0)+
			       nvl(l_estab_rec.h_10_tmraces_male,0);
  --
  l_consol_rec.h_10_grand_total := (l_consol_rec.h_10_grand_total +
                                    l_estab_rec.h_10_grand_total);
  --
  -- grand total for column i (total White females - non hisp)
  --
  l_estab_rec.i_10_grand_total := nvl(l_estab_rec.i_1_white_fem,0)+
                               nvl(l_estab_rec.i_2_white_fem,0)+
                               nvl(l_estab_rec.i_3_white_fem,0)+
                               nvl(l_estab_rec.i_4_white_fem,0)+
                               nvl(l_estab_rec.i_5_white_fem,0)+
                               nvl(l_estab_rec.i_6_white_fem,0)+
                               nvl(l_estab_rec.i_7_white_fem,0)+
                               nvl(l_estab_rec.i_8_white_fem,0)+
                               nvl(l_estab_rec.i_9_white_fem,0)+
			       nvl(l_estab_rec.i_10_white_fem,0);
  --
  l_consol_rec.i_10_grand_total := (l_consol_rec.i_10_grand_total +
                                    l_estab_rec.i_10_grand_total);
  --
  -- grand total for column j (total Black or African American females - non hisp)
  --
  l_estab_rec.j_10_grand_total := nvl(l_estab_rec.j_1_black_fem,0)+
                               nvl(l_estab_rec.j_2_black_fem,0)+
                               nvl(l_estab_rec.j_3_black_fem,0)+
                               nvl(l_estab_rec.j_4_black_fem,0)+
                               nvl(l_estab_rec.j_5_black_fem,0)+
                               nvl(l_estab_rec.j_6_black_fem,0)+
                               nvl(l_estab_rec.j_7_black_fem,0)+
                               nvl(l_estab_rec.j_8_black_fem,0)+
                               nvl(l_estab_rec.j_9_black_fem,0)+
			       nvl(l_estab_rec.j_10_black_fem,0);
  --
  l_consol_rec.j_10_grand_total := (l_consol_rec.j_10_grand_total +
                                    l_estab_rec.j_10_grand_total);
  --
  -- grand total for column k (total Native Hawaiian or Other Pacific Islander females - non hisp)
  --
  l_estab_rec.k_10_grand_total := nvl(l_estab_rec.k_1_latin_fem,0)+
                               nvl(l_estab_rec.k_2_latin_fem,0)+
                               nvl(l_estab_rec.k_3_latin_fem,0)+
                               nvl(l_estab_rec.k_4_latin_fem,0)+
                               nvl(l_estab_rec.k_5_latin_fem,0)+
                               nvl(l_estab_rec.k_6_latin_fem,0)+
                               nvl(l_estab_rec.k_7_latin_fem,0)+
                               nvl(l_estab_rec.k_8_latin_fem,0)+
                               nvl(l_estab_rec.k_9_latin_fem,0)+
			       nvl(l_estab_rec.k_10_latin_fem,0);

  l_consol_rec.k_10_grand_total := (l_consol_rec.k_10_grand_total +
                                    l_estab_rec.k_10_grand_total);

  --
  -- grand total for column L(total Asian females - non hisp)
  --
  l_estab_rec.l_10_grand_total := nvl(l_estab_rec.l_1_aspac_fem,0)+
                               nvl(l_estab_rec.l_2_aspac_fem,0)+
                               nvl(l_estab_rec.l_3_aspac_fem,0)+
                               nvl(l_estab_rec.l_4_aspac_fem,0)+
                               nvl(l_estab_rec.l_5_aspac_fem,0)+
                               nvl(l_estab_rec.l_6_aspac_fem,0)+
                               nvl(l_estab_rec.l_7_aspac_fem,0)+
                               nvl(l_estab_rec.l_8_aspac_fem,0)+
                               nvl(l_estab_rec.l_9_aspac_fem,0)+
			       nvl(l_estab_rec.l_10_aspac_fem,0);

  l_consol_rec.l_10_grand_total := (l_consol_rec.l_10_grand_total +
                                    l_estab_rec.l_10_grand_total);

--
  -- grand total for column M(total American Indian or Alaska Native females - non hisp)
  --
  l_estab_rec.m_10_grand_total := nvl(l_estab_rec.m_1_ameri_fem,0)+
                               nvl(l_estab_rec.m_2_ameri_fem,0)+
                               nvl(l_estab_rec.m_3_ameri_fem,0)+
                               nvl(l_estab_rec.m_4_ameri_fem,0)+
                               nvl(l_estab_rec.m_5_ameri_fem,0)+
                               nvl(l_estab_rec.m_6_ameri_fem,0)+
                               nvl(l_estab_rec.m_7_ameri_fem,0)+
                               nvl(l_estab_rec.m_8_ameri_fem,0)+
                               nvl(l_estab_rec.m_9_ameri_fem,0)+
			       nvl(l_estab_rec.m_10_ameri_fem,0);

  l_consol_rec.m_10_grand_total := (l_consol_rec.m_10_grand_total +
                                    l_estab_rec.m_10_grand_total);
--
  -- grand total for column N(total Two or more races females - non hisp)
  --
  l_estab_rec.n_10_grand_total := nvl(l_estab_rec.n_1_tmraces_female,0)+
                               nvl(l_estab_rec.n_2_tmraces_female,0)+
                               nvl(l_estab_rec.n_3_tmraces_female,0)+
                               nvl(l_estab_rec.n_4_tmraces_female,0)+
                               nvl(l_estab_rec.n_5_tmraces_female,0)+
                               nvl(l_estab_rec.n_6_tmraces_female,0)+
                               nvl(l_estab_rec.n_7_tmraces_female,0)+
                               nvl(l_estab_rec.n_8_tmraces_female,0)+
                               nvl(l_estab_rec.n_9_tmraces_female,0)+
			       nvl(l_estab_rec.n_10_tmraces_female,0);

  l_consol_rec.n_10_grand_total := (l_consol_rec.n_10_grand_total +
                                    l_estab_rec.n_10_grand_total);

--
  -- grand total for column O(total Total Col A - N )
  --
  l_estab_rec.o_10_grand_total := nvl(l_estab_rec.a_10_grand_total,0)+
                               nvl(l_estab_rec.b_10_grand_total,0) +
                               nvl(l_estab_rec.c_10_grand_total,0) +
                               nvl(l_estab_rec.d_10_grand_total,0) +
                               nvl(l_estab_rec.e_10_grand_total,0) +
                               nvl(l_estab_rec.f_10_grand_total,0) +
                               nvl(l_estab_rec.g_10_grand_total,0) +
                               nvl(l_estab_rec.h_10_grand_total,0) +
                               nvl(l_estab_rec.i_10_grand_total,0) +
			       nvl(l_estab_rec.j_10_grand_total,0) +
			       nvl(l_estab_rec.k_10_grand_total,0) +
			       nvl(l_estab_rec.l_10_grand_total,0) +
			       nvl(l_estab_rec.m_10_grand_total,0) +
			       nvl(l_estab_rec.n_10_grand_total,0);

  l_consol_rec.o_10_grand_total := (l_consol_rec.o_10_grand_total +
                                    l_estab_rec.o_10_grand_total);


  -- IF Hawaii
 /* IF l_estab_rec.state_8 = 'HI' THEN
     --
     -- count all men as white
     --
     l_estab_rec.c_10_grand_total := (l_estab_rec.a_10_grand_total +
                                                        l_estab_rec.c_10_grand_total +
							l_estab_rec.d_10_grand_total +
							l_estab_rec.e_10_grand_total +
							l_estab_rec.f_10_grand_total +
							l_estab_rec.g_10_grand_total+
							l_estab_rec.h_10_grand_total);

     l_estab_rec.a_10_grand_total := 0;
     l_estab_rec.d_10_grand_total := 0;
     l_estab_rec.e_10_grand_total := 0;
     l_estab_rec.f_10_grand_total := 0;
     l_estab_rec.g_10_grand_total := 0;
     l_estab_rec.h_10_grand_total := 0;

     l_estab_rec.i_10_grand_total := (l_estab_rec.b_10_grand_total +
                                                       l_estab_rec.i_10_grand_total +
                                                       l_estab_rec.j_10_grand_total +
                                                       l_estab_rec.k_10_grand_total +
                                                       l_estab_rec.l_10_grand_total +
                                                       l_estab_rec.m_10_grand_total+
						       l_estab_rec.n_10_grand_total);

     l_estab_rec.b_10_grand_total := 0;
     l_estab_rec.j_10_grand_total := 0;
     l_estab_rec.k_10_grand_total := 0;
     l_estab_rec.l_10_grand_total := 0;
     l_estab_rec.m_10_grand_total := 0;
     l_estab_rec.n_10_grand_total := 0;

  END IF; --l_estab_rec.state_8 = 'HI' */

   l_string :=
              -- 1
              nvl(lpad(l_org_rec.company_number_1,7,0),(lpad(' ',7,' ')))
              -- 2
              -- status code
              ||l_org_rec.l_status_code_2
              -- 3
              ||nvl(lpad(SUBSTR(l_estab_rec.unit_number_3,1,7),7,0),
              ('0000000'))
              -- 4
              ||nvl(rpad(ltrim(replace(replace(l_estab_rec.unit_name_4,',','')
              ,'.',''),'1234567890'),35,' '),(lpad(' ',35,' ')))
              -- 5
              ||nvl(rpad(replace(replace
              (SUBSTR(l_estab_rec.unit_address_req_5,1,34)
              ,',',''),'.',''),34,' '),(lpad(' ',34,' ')))
              -- 6
              ||nvl(rpad(replace(replace(SUBSTR(l_estab_rec.unit_address_6,1,25)
	      ,',',''),'.',''),25,' '),(lpad(' ',25,' ')))
              -- 7
              ||nvl(rpad(replace(replace(SUBSTR(l_estab_rec.city_7,1,20),',','')
	      ,'.',''),20,' '),(lpad(' ',20,' ')))
              -- 8
              ||nvl(rpad(l_estab_rec.state_8,2),(lpad(' ',8,' ')))
              -- 9
              ||nvl(rpad(l_estab_rec.zip_code_9,5),(lpad(' ',5,' ')))
              -- 10
              ||rpad(l_estab_rec.reported_last_year_11,1)
              -- 11
              ||rpad(l_org_rec.c1_over_100_13,1)
              -- 12
              ||rpad(l_org_rec.c2_affiliated_14,1)
              -- 13
	      ||rpad(nvl(l_estab_rec.gov_contract_15,l_org_rec.gov_contract_15)
              ,1)
              -- 14
	      ||nvl(lpad(nvl(l_estab_rec.duns_16,l_org_rec.duns_16),9,0)
              ,(lpad(' ',9,' ')))
              -- 15
	      ||nvl(rpad(replace(replace(l_estab_rec.county_17,',',''),'.','')
              ,18),(lpad(' ',18,' ')))
              -- 16
              ||rpad(l_org_rec.l_d1_payroll_period_18,16)
              -- 17
	      ||nvl(lpad(nvl(l_estab_rec.naics_21,l_org_rec.naics_21),6,0), --BUG4494412
              (lpad(' ',6,' ')))
             -- 18
	     ||nvl(rpad(ltrim(replace(replace(l_org_rec.title_cert_off_22,',','')
              ,'.',''),'1234567890'),35),(lpad(' ',35,' ')))
              -- 19
	      ||nvl(rpad(ltrim(replace(replace(l_org_rec.name_cert_off_23,',','')
              ,'.',''),'1234567890'),35),(lpad(' ',35,' ')))
             -- 20
              ||nvl(rpad(replace(replace(l_org_rec.tel_num_24,',',''),'.','')
              ,10),(lpad(' ',10,' ')))
	      -- 21
	      ||nvl(rpad(replace(l_org_rec.email_26,',',''),40),
              (lpad(' ',40,' ')))||
	      --
              lpad(l_estab_rec.a_1_hl_male,6,0)||
	      lpad(l_estab_rec.b_1_hl_female,6,0)||
              lpad(l_estab_rec.c_1_white_male,6,0)||
              lpad(l_estab_rec.d_1_black_male,6,0)||
              lpad(l_estab_rec.e_1_latin_male,6,0)||
              lpad(l_estab_rec.f_1_aspac_male,6,0)||
              lpad(l_estab_rec.g_1_ameri_male,6,0)||
	      lpad(l_estab_rec.h_1_tmraces_male,6,0)||
              lpad(l_estab_rec.i_1_white_fem,6,0)||
              lpad(l_estab_rec.j_1_black_fem,6,0)||
              lpad(l_estab_rec.k_1_latin_fem,6,0)||
              lpad(l_estab_rec.l_1_aspac_fem,6,0)||
              lpad(l_estab_rec.m_1_ameri_fem,6,0)||
	      lpad(l_estab_rec.n_1_tmraces_female,6,0)||
	      lpad(l_estab_rec.o_1_total_cat,7,0)||
              --
              lpad(l_estab_rec.a_2_hl_male,6,0)||
	      lpad(l_estab_rec.b_2_hl_female,6,0)||
              lpad(l_estab_rec.c_2_white_male,6,0)||
              lpad(l_estab_rec.d_2_black_male,6,0)||
              lpad(l_estab_rec.e_2_latin_male,6,0)||
              lpad(l_estab_rec.f_2_aspac_male,6,0)||
              lpad(l_estab_rec.g_2_ameri_male,6,0)||
	      lpad(l_estab_rec.h_2_tmraces_male,6,0)||
              lpad(l_estab_rec.i_2_white_fem,6,0)||
              lpad(l_estab_rec.j_2_black_fem,6,0)||
              lpad(l_estab_rec.k_2_latin_fem,6,0)||
              lpad(l_estab_rec.l_2_aspac_fem,6,0)||
              lpad(l_estab_rec.m_2_ameri_fem,6,0)||
	      lpad(l_estab_rec.n_2_tmraces_female,6,0)||
	      lpad(l_estab_rec.o_2_total_cat,7,0)||
              --
              lpad(l_estab_rec.a_3_hl_male,6,0)||
	      lpad(l_estab_rec.b_3_hl_female,6,0)||
              lpad(l_estab_rec.c_3_white_male,6,0)||
              lpad(l_estab_rec.d_3_black_male,6,0)||
              lpad(l_estab_rec.e_3_latin_male,6,0)||
              lpad(l_estab_rec.f_3_aspac_male,6,0)||
              lpad(l_estab_rec.g_3_ameri_male,6,0)||
	      lpad(l_estab_rec.h_3_tmraces_male,6,0)||
              lpad(l_estab_rec.i_3_white_fem,6,0)||
              lpad(l_estab_rec.j_3_black_fem,6,0)||
              lpad(l_estab_rec.k_3_latin_fem,6,0)||
              lpad(l_estab_rec.l_3_aspac_fem,6,0)||
              lpad(l_estab_rec.m_3_ameri_fem,6,0)||
	      lpad(l_estab_rec.n_3_tmraces_female,6,0)||
	      lpad(l_estab_rec.o_3_total_cat,7,0)||
              --
              lpad(l_estab_rec.a_4_hl_male,6,0)||
	      lpad(l_estab_rec.b_4_hl_female,6,0)||
              lpad(l_estab_rec.c_4_white_male,6,0)||
              lpad(l_estab_rec.d_4_black_male,6,0)||
              lpad(l_estab_rec.e_4_latin_male,6,0)||
              lpad(l_estab_rec.f_4_aspac_male,6,0)||
              lpad(l_estab_rec.g_4_ameri_male,6,0)||
	      lpad(l_estab_rec.h_4_tmraces_male,6,0)||
              lpad(l_estab_rec.i_4_white_fem,6,0)||
              lpad(l_estab_rec.j_4_black_fem,6,0)||
              lpad(l_estab_rec.k_4_latin_fem,6,0)||
              lpad(l_estab_rec.l_4_aspac_fem,6,0)||
              lpad(l_estab_rec.m_4_ameri_fem,6,0)||
	      lpad(l_estab_rec.n_4_tmraces_female,6,0)||
	      lpad(l_estab_rec.o_4_total_cat,7,0)||
              --
              lpad(l_estab_rec.a_5_hl_male,6,0)||
	      lpad(l_estab_rec.b_5_hl_female,6,0)||
              lpad(l_estab_rec.c_5_white_male,6,0)||
              lpad(l_estab_rec.d_5_black_male,6,0)||
              lpad(l_estab_rec.e_5_latin_male,6,0)||
              lpad(l_estab_rec.f_5_aspac_male,6,0)||
              lpad(l_estab_rec.g_5_ameri_male,6,0)||
	      lpad(l_estab_rec.h_5_tmraces_male,6,0)||
              lpad(l_estab_rec.i_5_white_fem,6,0)||
              lpad(l_estab_rec.j_5_black_fem,6,0)||
              lpad(l_estab_rec.k_5_latin_fem,6,0)||
              lpad(l_estab_rec.l_5_aspac_fem,6,0)||
              lpad(l_estab_rec.m_5_ameri_fem,6,0)||
	      lpad(l_estab_rec.n_5_tmraces_female,6,0)||
	      lpad(l_estab_rec.o_5_total_cat,7,0)||
              --
              lpad(l_estab_rec.a_6_hl_male,6,0)||
	      lpad(l_estab_rec.b_6_hl_female,6,0)||
              lpad(l_estab_rec.c_6_white_male,6,0)||
              lpad(l_estab_rec.d_6_black_male,6,0)||
              lpad(l_estab_rec.e_6_latin_male,6,0)||
              lpad(l_estab_rec.f_6_aspac_male,6,0)||
              lpad(l_estab_rec.g_6_ameri_male,6,0)||
	      lpad(l_estab_rec.h_6_tmraces_male,6,0)||
              lpad(l_estab_rec.i_6_white_fem,6,0)||
              lpad(l_estab_rec.j_6_black_fem,6,0)||
              lpad(l_estab_rec.k_6_latin_fem,6,0)||
              lpad(l_estab_rec.l_6_aspac_fem,6,0)||
              lpad(l_estab_rec.m_6_ameri_fem,6,0)||
	      lpad(l_estab_rec.n_6_tmraces_female,6,0)||
	      lpad(l_estab_rec.o_6_total_cat,7,0)||
              --
              lpad(l_estab_rec.a_7_hl_male,6,0)||
	      lpad(l_estab_rec.b_7_hl_female,6,0)||
              lpad(l_estab_rec.c_7_white_male,6,0)||
              lpad(l_estab_rec.d_7_black_male,6,0)||
              lpad(l_estab_rec.e_7_latin_male,6,0)||
              lpad(l_estab_rec.f_7_aspac_male,6,0)||
              lpad(l_estab_rec.g_7_ameri_male,6,0)||
	      lpad(l_estab_rec.h_7_tmraces_male,6,0)||
              lpad(l_estab_rec.i_7_white_fem,6,0)||
              lpad(l_estab_rec.j_7_black_fem,6,0)||
              lpad(l_estab_rec.k_7_latin_fem,6,0)||
              lpad(l_estab_rec.l_7_aspac_fem,6,0)||
              lpad(l_estab_rec.m_7_ameri_fem,6,0)||
	      lpad(l_estab_rec.n_7_tmraces_female,6,0)||
	      lpad(l_estab_rec.o_7_total_cat,7,0)||
              --
              lpad(l_estab_rec.a_8_hl_male,6,0)||
	      lpad(l_estab_rec.b_8_hl_female,6,0)||
              lpad(l_estab_rec.c_8_white_male,6,0)||
              lpad(l_estab_rec.d_8_black_male,6,0)||
              lpad(l_estab_rec.e_8_latin_male,6,0)||
              lpad(l_estab_rec.f_8_aspac_male,6,0)||
              lpad(l_estab_rec.g_8_ameri_male,6,0)||
	      lpad(l_estab_rec.h_8_tmraces_male,6,0)||
              lpad(l_estab_rec.i_8_white_fem,6,0)||
              lpad(l_estab_rec.j_8_black_fem,6,0)||
              lpad(l_estab_rec.k_8_latin_fem,6,0)||
              lpad(l_estab_rec.l_8_aspac_fem,6,0)||
              lpad(l_estab_rec.m_8_ameri_fem,6,0)||
	      lpad(l_estab_rec.n_8_tmraces_female,6,0)||
	      lpad(l_estab_rec.o_8_total_cat,7,0)||
              --
              lpad(l_estab_rec.a_9_hl_male,6,0)||
	      lpad(l_estab_rec.b_9_hl_female,6,0)||
              lpad(l_estab_rec.c_9_white_male,6,0)||
              lpad(l_estab_rec.d_9_black_male,6,0)||
              lpad(l_estab_rec.e_9_latin_male,6,0)||
              lpad(l_estab_rec.f_9_aspac_male,6,0)||
              lpad(l_estab_rec.g_9_ameri_male,6,0)||
	      lpad(l_estab_rec.h_9_tmraces_male,6,0)||
              lpad(l_estab_rec.i_9_white_fem,6,0)||
              lpad(l_estab_rec.j_9_black_fem,6,0)||
              lpad(l_estab_rec.k_9_latin_fem,6,0)||
              lpad(l_estab_rec.l_9_aspac_fem,6,0)||
              lpad(l_estab_rec.m_9_ameri_fem,6,0)||
	      lpad(l_estab_rec.n_9_tmraces_female,6,0)||
	      lpad(l_estab_rec.o_9_total_cat,7,0)||
              --
	      lpad(l_estab_rec.a_10_hl_male,6,0)||
	      lpad(l_estab_rec.b_10_hl_female,6,0)||
              lpad(l_estab_rec.c_10_white_male,6,0)||
              lpad(l_estab_rec.d_10_black_male,6,0)||
              lpad(l_estab_rec.e_10_latin_male,6,0)||
              lpad(l_estab_rec.f_10_aspac_male,6,0)||
              lpad(l_estab_rec.g_10_ameri_male,6,0)||
	      lpad(l_estab_rec.h_10_tmraces_male,6,0)||
              lpad(l_estab_rec.i_10_white_fem,6,0)||
              lpad(l_estab_rec.j_10_black_fem,6,0)||
              lpad(l_estab_rec.k_10_latin_fem,6,0)||
              lpad(l_estab_rec.l_10_aspac_fem,6,0)||
              lpad(l_estab_rec.m_10_ameri_fem,6,0)||
	      lpad(l_estab_rec.n_10_tmraces_female,6,0)||
	      lpad(l_estab_rec.o_10_total_cat,7,0)||
	      --
              lpad(l_estab_rec.a_10_grand_total,6,0) ||
              lpad(l_estab_rec.b_10_grand_total,6,0) ||
              lpad(l_estab_rec.c_10_grand_total,6,0) ||
              lpad(l_estab_rec.d_10_grand_total,6,0) ||
              lpad(l_estab_rec.e_10_grand_total,6,0) ||
              lpad(l_estab_rec.f_10_grand_total,6,0) ||
              lpad(l_estab_rec.g_10_grand_total,6,0) ||
              lpad(l_estab_rec.h_10_grand_total,6,0) ||
              lpad(l_estab_rec.i_10_grand_total,6,0) ||
              lpad(l_estab_rec.j_10_grand_total,6,0) ||
              lpad(l_estab_rec.k_10_grand_total,6,0)||
	      lpad(l_estab_rec.l_10_grand_total,6,0)||
	      lpad(l_estab_rec.m_10_grand_total,6,0)||
	      lpad(l_estab_rec.n_10_grand_total,6,0)||
	      lpad(l_estab_rec.o_10_grand_total,7,0);

    /*l_string := nvl(lpad(l_org_rec.company_number_1,7,0),(lpad(' ',7,' ')))
              ||rpad(l_org_rec.l_status_code_2,1)
              ||nvl(lpad(SUBSTR(l_estab_rec.unit_number_3,1,7),7,0),
              (lpad(' ',7,' ')))
              ||nvl(rpad(ltrim(replace(replace(l_estab_rec.unit_name_4,',','')
              ,'.',''),'1234567890'),35,' '),(lpad(' ',35,' ')))
              ||nvl(rpad(replace(replace
              (SUBSTR(l_estab_rec.unit_address_req_5,1,34)
              ,',',''),'.',''),34,' '),(lpad(' ',34,' ')))
              ||nvl(rpad(replace(replace(SUBSTR(l_estab_rec.unit_address_6,1,25)
              ,',',''),'.',''),25,' '),(lpad(' ',25,' ')))
              ||nvl(rpad(replace(replace(SUBSTR(l_estab_rec.city_7,1,20),',','')
              ,'.',''),20,' '),(lpad(' ',20,' ')))
              ||nvl(rpad(l_estab_rec.state_8,2),(lpad(' ',8,' ')))
              ||nvl(rpad(l_estab_rec.zip_code_9,5),(lpad(' ',5,' ')))
              ||nvl(rpad(l_estab_rec.zip_code_last_4_10,4),(lpad(' ',4,' ')))
              ||rpad(l_estab_rec.reported_last_year_11,1)
              ||nvl(lpad(l_estab_rec.ein_12,9,0),(lpad(' ',9,' ')))
              ||rpad(l_org_rec.c1_over_100_13,1)
              ||rpad(l_org_rec.c2_affiliated_14,1)
              ||rpad(nvl(l_estab_rec.gov_contract_15,l_org_rec.gov_contract_15)
              ,1)
              ||nvl(lpad(nvl(l_estab_rec.duns_16,l_org_rec.duns_16),9,0)
              ,(lpad(' ',9,' ')))
              ||nvl(rpad(replace(replace(l_estab_rec.county_17,',',''),'.','')
              ,18),(lpad(' ',18,' ')))
              ||rpad(l_org_rec.l_d1_payroll_period_18,16)
              ||rpad(nvl(l_estab_rec.apprentices_emp_19
              ,l_org_rec.apprentices_emp_19),1)
              ||nvl(lpad(nvl(l_estab_rec.sic_20,l_org_rec.sic_20),4,0)
              ,(lpad(' ',4,' ')))
              ||nvl(lpad(nvl(l_estab_rec.naics_21,l_org_rec.naics_21),6,0)
              ,(lpad(' ',6,' ')))
              ||nvl(rpad(ltrim(replace(replace(l_org_rec.title_cert_off_22,',','')
              ,'.',''),'1234567890'),35),(lpad(' ',35,' ')))
              ||nvl(rpad(ltrim(replace(replace(l_org_rec.name_cert_off_23,',','')
              ,'.',''),'1234567890'),35),(lpad(' ',35,' ')))
              ||nvl(rpad(replace(replace(l_org_rec.tel_num_24,',',''),'.','')
              ,10),(lpad(' ',10,' ')))
              ||nvl(rpad(replace(replace(l_org_rec.fax_num_25,',',''),'.','')
              ,10),(lpad(' ',10,' ')))
              ||nvl(rpad(replace(l_org_rec.email_26,',',''),40)
              ,(lpad(' ',40,' ')))
              ||
              --
              lpad(l_estab_rec.a_1_total_mf,7,0)  ||
              lpad(l_estab_rec.b_1_white_male,6,0)||
              lpad(l_estab_rec.c_1_black_male,6,0)||
              lpad(l_estab_rec.d_1_latin_male,6,0)||
              lpad(l_estab_rec.e_1_aspac_male,6,0)||
              lpad(l_estab_rec.f_1_ameri_male,6,0)||
              lpad(l_estab_rec.g_1_white_fem,6,0) ||
              lpad(l_estab_rec.h_1_black_fem,6,0) ||
              lpad(l_estab_rec.i_1_latin_fem,6,0) ||
              lpad(l_estab_rec.j_1_aspac_fem,6,0) ||
              lpad(l_estab_rec.k_1_ameri_fem,6,0) ||
              --
              lpad(l_estab_rec.a_2_total_mf,7,0)  ||
              lpad(l_estab_rec.b_2_white_male,6,0)||
              lpad(l_estab_rec.c_2_black_male,6,0)||
              lpad(l_estab_rec.d_2_latin_male,6,0)||
              lpad(l_estab_rec.e_2_aspac_male,6,0)||
              lpad(l_estab_rec.f_2_ameri_male,6,0)||
              lpad(l_estab_rec.g_2_white_fem,6,0) ||
              lpad(l_estab_rec.h_2_black_fem,6,0) ||
              lpad(l_estab_rec.i_2_latin_fem,6,0) ||
              lpad(l_estab_rec.j_2_aspac_fem,6,0) ||
              lpad(l_estab_rec.k_2_ameri_fem,6,0) ||
              --
              lpad(l_estab_rec.a_3_total_mf,7,0)   ||
              lpad(l_estab_rec.b_3_white_male,6,0) ||
              lpad(l_estab_rec.c_3_black_male,6,0) ||
              lpad(l_estab_rec.d_3_latin_male,6,0) ||
              lpad(l_estab_rec.e_3_aspac_male,6,0) ||
              lpad(l_estab_rec.f_3_ameri_male,6,0) ||
              lpad(l_estab_rec.g_3_white_fem,6,0)  ||
              lpad(l_estab_rec.h_3_black_fem,6,0)  ||
              lpad(l_estab_rec.i_3_latin_fem,6,0)  ||
              lpad(l_estab_rec.j_3_aspac_fem,6,0)  ||
              lpad(l_estab_rec.k_3_ameri_fem,6,0)  ||
              --
              lpad(l_estab_rec.a_4_total_mf,7,0)   ||
              lpad(l_estab_rec.b_4_white_male,6,0) ||
              lpad(l_estab_rec.c_4_black_male,6,0) ||
              lpad(l_estab_rec.d_4_latin_male,6,0) ||
              lpad(l_estab_rec.e_4_aspac_male,6,0) ||
              lpad(l_estab_rec.f_4_ameri_male,6,0) ||
              lpad(l_estab_rec.g_4_white_fem,6,0)  ||
              lpad(l_estab_rec.h_4_black_fem,6,0)  ||
              lpad(l_estab_rec.i_4_latin_fem,6,0)  ||
              lpad(l_estab_rec.j_4_aspac_fem,6,0)  ||
              lpad(l_estab_rec.k_4_ameri_fem,6,0)  ||
              --
              lpad(l_estab_rec.a_5_total_mf,7,0)   ||
              lpad(l_estab_rec.b_5_white_male,6,0) ||
              lpad(l_estab_rec.c_5_black_male,6,0) ||
              lpad(l_estab_rec.d_5_latin_male,6,0) ||
              lpad(l_estab_rec.e_5_aspac_male,6,0) ||
              lpad(l_estab_rec.f_5_ameri_male,6,0) ||
              lpad(l_estab_rec.g_5_white_fem,6,0)  ||
              lpad(l_estab_rec.h_5_black_fem,6,0)  ||
              lpad(l_estab_rec.i_5_latin_fem,6,0)  ||
              lpad(l_estab_rec.j_5_aspac_fem,6,0)  ||
              lpad(l_estab_rec.k_5_ameri_fem,6,0)  ||
              --
              lpad(l_estab_rec.a_6_total_mf,7,0)   ||
              lpad(l_estab_rec.b_6_white_male,6,0) ||
              lpad(l_estab_rec.c_6_black_male,6,0) ||
              lpad(l_estab_rec.d_6_latin_male,6,0) ||
              lpad(l_estab_rec.e_6_aspac_male,6,0) ||
              lpad(l_estab_rec.f_6_ameri_male,6,0) ||
              lpad(l_estab_rec.g_6_white_fem,6,0)  ||
              lpad(l_estab_rec.h_6_black_fem,6,0)  ||
              lpad(l_estab_rec.i_6_latin_fem,6,0)  ||
              lpad(l_estab_rec.j_6_aspac_fem,6,0)  ||
              lpad(l_estab_rec.k_6_ameri_fem,6,0)  ||
              --
              lpad(l_estab_rec.a_7_total_mf,7,0)   ||
              lpad(l_estab_rec.b_7_white_male,6,0) ||
              lpad(l_estab_rec.c_7_black_male,6,0) ||
              lpad(l_estab_rec.d_7_latin_male,6,0) ||
              lpad(l_estab_rec.e_7_aspac_male,6,0) ||
              lpad(l_estab_rec.f_7_ameri_male,6,0) ||
              lpad(l_estab_rec.g_7_white_fem,6,0)  ||
              lpad(l_estab_rec.h_7_black_fem,6,0)  ||
              lpad(l_estab_rec.i_7_latin_fem,6,0)  ||
              lpad(l_estab_rec.j_7_aspac_fem,6,0)  ||
              lpad(l_estab_rec.k_7_ameri_fem,6,0)  ||
              --
              lpad(l_estab_rec.a_8_total_mf,7,0)   ||
              lpad(l_estab_rec.b_8_white_male,6,0) ||
              lpad(l_estab_rec.c_8_black_male,6,0) ||
              lpad(l_estab_rec.d_8_latin_male,6,0) ||
              lpad(l_estab_rec.e_8_aspac_male,6,0) ||
              lpad(l_estab_rec.f_8_ameri_male,6,0) ||
              lpad(l_estab_rec.g_8_white_fem,6,0)  ||
              lpad(l_estab_rec.h_8_black_fem,6,0)  ||
              lpad(l_estab_rec.i_8_latin_fem,6,0)  ||
              lpad(l_estab_rec.j_8_aspac_fem,6,0)  ||
              lpad(l_estab_rec.k_8_ameri_fem,6,0)  ||
              --
              lpad(l_estab_rec.a_9_total_mf,7,0)   ||
              lpad(l_estab_rec.b_9_white_male,6,0) ||
              lpad(l_estab_rec.c_9_black_male,6,0) ||
              lpad(l_estab_rec.d_9_latin_male,6,0) ||
              lpad(l_estab_rec.e_9_aspac_male,6,0) ||
              lpad(l_estab_rec.f_9_ameri_male,6,0) ||
              lpad(l_estab_rec.g_9_white_fem,6,0)  ||
              lpad(l_estab_rec.h_9_black_fem,6,0)  ||
              lpad(l_estab_rec.i_9_latin_fem,6,0)  ||
              lpad(l_estab_rec.j_9_aspac_fem,6,0)  ||
              lpad(l_estab_rec.k_9_ameri_fem,6,0)  ||
              --
              lpad(l_estab_rec.a_10_grand_total,7,0) ||
              lpad(l_estab_rec.b_10_grand_total,6,0) ||
              lpad(l_estab_rec.c_10_grand_total,6,0) ||
              lpad(l_estab_rec.d_10_grand_total,6,0) ||
              lpad(l_estab_rec.e_10_grand_total,6,0) ||
              lpad(l_estab_rec.f_10_grand_total,6,0) ||
              lpad(l_estab_rec.g_10_grand_total,6,0) ||
              lpad(l_estab_rec.h_10_grand_total,6,0) ||
              lpad(l_estab_rec.i_10_grand_total,6,0) ||
              lpad(l_estab_rec.j_10_grand_total,6,0) ||
              lpad(l_estab_rec.k_10_grand_total,6,0) ||
              --
              lpad(l_estab_rec.a_11_last_year_grand_total,7,0) ||
              lpad(l_estab_rec.b_11_last_year_grand_total,6,0) ||
              lpad(l_estab_rec.c_11_last_year_grand_total,6,0) ||
              lpad(l_estab_rec.d_11_last_year_grand_total,6,0) ||
              lpad(l_estab_rec.e_11_last_year_grand_total,6,0) ||
              lpad(l_estab_rec.f_11_last_year_grand_total,6,0) ||
              lpad(l_estab_rec.g_11_last_year_grand_total,6,0) ||
              lpad(l_estab_rec.h_11_last_year_grand_total,6,0) ||
              lpad(l_estab_rec.i_11_last_year_grand_total,6,0) ||
              lpad(l_estab_rec.j_11_last_year_grand_total,6,0) ||
              lpad(l_estab_rec.k_11_last_year_grand_total,6,0); */

  /*g_message_text := 'l_estab_rec.a_1_total_mf -> '|| l_estab_rec.a_1_total_mf;
  fnd_file.put_line(which => fnd_file.log, buff => g_message_text);

  g_message_text := 'l_estab_rec.a_2_total_mf -> '|| l_estab_rec.a_2_total_mf;
  fnd_file.put_line(which => fnd_file.log, buff => g_message_text);

  g_message_text := 'l_estab_rec.a_3_total_mf -> '|| l_estab_rec.a_3_total_mf;
  fnd_file.put_line(which => fnd_file.log, buff => g_message_text);

  g_message_text := 'l_estab_rec.a_4_total_mf -> '|| l_estab_rec.a_4_total_mf;
  fnd_file.put_line(which => fnd_file.log, buff => g_message_text);

  g_message_text := 'l_estab_rec.a_5_total_mf -> '|| l_estab_rec.a_5_total_mf;
  fnd_file.put_line(which => fnd_file.log, buff => g_message_text);

  g_message_text := 'l_estab_rec.a_6_total_mf -> '|| l_estab_rec.a_6_total_mf;
  fnd_file.put_line(which => fnd_file.log, buff => g_message_text);

  g_message_text := 'l_estab_rec.a_7_total_mf -> '|| l_estab_rec.a_7_total_mf;
  fnd_file.put_line(which => fnd_file.log, buff => g_message_text);

  g_message_text := 'l_estab_rec.a_8_total_mf -> '|| l_estab_rec.a_8_total_mf;
  fnd_file.put_line(which => fnd_file.log, buff => g_message_text);


  g_message_text := 'l_estab_rec.a_9_total_mf -> '|| l_estab_rec.a_9_total_mf;
  fnd_file.put_line(which => fnd_file.log, buff => g_message_text);*/


  g_message_text := 'l_estab_rec.a_10_grand_total -> '||l_estab_rec.a_10_grand_total;
  fnd_file.put_line(which => fnd_file.log, buff => g_message_text);


  --
  fnd_file.put_line
    (which => fnd_file.output,
     buff  => l_string);
  hr_utility.set_location('Leaving..' || l_proc,100);

END write_establishment_record;


PROCEDURE loop_through_establishments(p_hierarchy_version_id IN NUMBER,
                                      p_business_group_id    IN NUMBER,
                                      p_start_date           IN DATE,
                                      p_end_date             IN DATE,
                                      p_report_mode          IN  VARCHAR2) IS
  l_hierarchy_node_id NUMBER;
  l_proc VARCHAR2(80) := g_package || 'loop_through_establishments';

  CURSOR c_estab_details IS
     SELECT
           hlei1.lei_information2 unit_number_3,
           UPPER(hlei1.lei_information1) unit_name_4,
           UPPER(eloc.address_line_1||
                 ' '||
                 eloc.address_line_2)  unit_address_req_5,
           UPPER(eloc.address_line_3)  unit_address_6,
           UPPER(eloc.town_or_city) city_7,
           UPPER(eloc.region_2) state_8,
           SUBSTR(eloc.postal_code,1,5) zip_code_9,
           SUBSTR(eloc.postal_code,7,4) zip_code_last_4_10,
           DECODE(hlei1.lei_information9,'Y',1,2) reported_last_year_11,
           hlei2.lei_information6 ein_12,
           DECODE(hlei1.lei_information4,'Y',1,'N',2) gov_contract_15,
           hlei2.lei_information2 duns_16,
           UPPER(eloc.region_1) county_17,
           DECODE(hlei1.lei_information3,'Y',1,'N',2) apprentices_emp_19,
           hlei2.lei_information3 sic_20,
           hlei2.lei_information4 naics_21,
           pghn.hierarchy_node_id,
           hlei2.lei_information10 hq
    FROM   per_gen_hierarchy_nodes pghn,
           hr_location_extra_info hlei1,
           hr_location_extra_info hlei2,
           hr_locations_all eloc
    WHERE  -- pghn.hierarchy_version_id = 2683  -- sd1
           pghn.hierarchy_version_id = p_hierarchy_version_id -- 2803 sd10plus
           -- pghn.hierarchy_version_id = 2823 -- Vik SD Albuquereque
    AND    pghn.node_type = 'EST'
    AND    eloc.location_id = pghn.entity_id
    AND    hlei1.location_id = pghn.entity_id
    AND    hlei1.location_id = hlei2.location_id
    AND    hlei1.information_type = 'EEO-1 Specific Information'
    AND    hlei1.lei_information_category = 'EEO-1 Specific Information'
    AND    hlei2.information_type = 'Establishment Information'
    AND    hlei2.lei_information_category = 'Establishment Information';
    --order  by eloc.region_2,decode(hlei2.lei_information10,'Y',1,2);

  l_c_estab_details c_estab_details%ROWTYPE;

CURSOR c_estab_max IS -- find out IF over 50 people at location
/* SELECT count('num_emps_at_location')
       FROM per_all_assignments_f paf
      WHERE paf.business_group_id = p_business_group_id
        AND paf.primary_flag = 'Y'
        AND paf.assignment_type = 'E'
        AND p_start_date >= paf.effective_start_date
        AND p_end_date <= paf.effective_end_date
        AND TO_CHAR(paf.location_id) IN
           (SELECT entity_id
            FROM   per_gen_hierarchy_nodes pgn
            WHERE
            pgn.hierarchy_version_id = p_hierarchy_version_id
            AND (
              pgn.hierarchy_node_id = l_hierarchy_node_id
                   OR pgn.parent_hierarchy_node_id = l_hierarchy_node_id)
            AND pgn.node_type IN ('EST','LOC')
            ); */
-- The above query is replace with the following query for the bug# 6216140
SELECT  count(peo.person_id)
FROM    per_all_assignments_f ass,
               per_all_people_f peo,
               per_jobs_vl job
WHERE  peo.person_id = ass.person_id
AND    peo.per_information1 is not NULL
AND    job.job_information_category  = 'US'
AND    p_start_date <= nvl(job.date_to,p_end_date )
AND    p_end_date >= job.date_from
AND    job.job_information1 is not NULL
AND    ass.job_id  = job.job_id
AND    peo.effective_start_date = (select max(peo1.effective_start_date)
						       from   per_people_f peo1
						       where  p_start_date <= peo1.effective_end_date
						       and  p_end_date >= peo1.effective_start_date
						       and    peo.person_id = peo1.person_id
						       and     peo1.current_employee_flag = 'Y'
						       )
AND    ass.effective_start_date = (select max(ass1.effective_start_date)
						       from    per_all_assignments_f ass1
						       where   p_start_date <= ass1.effective_end_date
						       and     p_end_date  >= ass1.effective_start_date
						       and     ass.person_id = ass1.person_id
						       and     ass1.assignment_type  = 'E'
						       and     ass1.primary_flag     = 'Y'
						       )
AND    ass.assignment_type = 'E'
AND    ass.primary_flag = 'Y'
AND    ass.business_group_id = p_business_group_id
AND    peo.business_group_id = p_business_group_id
AND    job.business_group_id = p_business_group_id
AND EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE  TO_CHAR(ASS.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND hoi1.org_information_context    = 'Reporting Statuses'
              AND    hoi1.organization_id               = p_business_group_id
              AND    ass.employment_category      = hoi2.org_information1
              AND    hoi2.organization_id               = p_business_group_id
              AND    hoi2.org_information_context = 'Reporting Categories'  )
AND   p_start_date <= ass.effective_end_date
AND   p_end_date  >= ass.effective_start_date
AND TO_CHAR(ass.location_id) IN
           (SELECT entity_id
            FROM   per_gen_hierarchy_nodes pgn
            WHERE
            pgn.hierarchy_version_id = p_hierarchy_version_id
            AND (
              pgn.hierarchy_node_id = l_hierarchy_node_id
                   OR pgn.parent_hierarchy_node_id = l_hierarchy_node_id)
            AND pgn.node_type IN ('EST','LOC')
            );


  l_estab_max NUMBER;

  CURSOR c_female_details IS
     SELECT
           COUNT(DECODE(peo.per_information1,'3',1))   c_hlfemale,
	   COUNT(DECODE(peo.per_information1,'1',1))   c_wfemale,
           COUNT(DECODE(peo.per_information1,'2',1))   c_bfemale,
           COUNT(DECODE(peo.per_information1,'5',1))   c_hfemale,
           COUNT(DECODE(peo.per_information1,'4',1))   c_afemale,
           COUNT(DECODE(peo.per_information1,'6',1))   c_ifemale,
	   COUNT(DECODE(peo.per_information1,'13',1))   c_tmracesfemale,
	   count(peo.person_id)  "c_total_cat",
           hrl.lookup_code lookup_code
    FROM   per_all_people_f                peo,
           per_all_assignments_f           ass,
           per_jobs_vl                     job,
           hr_lookups                      hrl,
           per_gen_hierarchy_nodes         pgn_est
    WHERE  peo.person_id = ass.person_id
    AND    peo.per_information1 IS not NULL
    AND    peo.per_information_category = 'US'
    AND    job.job_information_category = 'US'
    AND    p_start_date <= nvl(job.date_to,p_start_date)
    AND    p_end_date >= job.date_from
    AND    job.job_information1 = hrl.lookup_code
    AND    hrl.lookup_type = 'US_EEO1_JOB_CATEGORIES'
    AND    ass.job_id = job.job_id
    AND    peo.effective_start_date =
             (SELECT MAX(peo1.effective_start_date)
              FROM   per_people_f peo1
              WHERE  p_start_date <= peo1.effective_end_date
              AND    p_end_date >= peo1.effective_start_date
              AND    peo.person_id = peo1.person_id
              AND    peo1.current_employee_flag = 'Y'
              )
    AND ass.effective_start_date =
             (SELECT MAX(ass1.effective_start_date)
              FROM   per_assignments_f ass1
              WHERE  p_start_date <= ass1.effective_end_date
    AND    p_end_date >= ass1.effective_start_date
              AND    ass.person_id = ass1.person_id
              AND    ass1.assignment_type  = 'E'
              AND    ass1.primary_flag     = 'Y'
              )
    AND ass.assignment_type  = 'E'
    AND ass.primary_flag     = 'Y'
    AND ass.business_group_id =  p_business_group_id
    AND peo.business_group_id =  p_business_group_id
    AND job.business_group_id =  p_business_group_id
    AND EXISTS (
           SELECT 'X'
             FROM hr_organization_information  hoi1,
                  hr_organization_information hoi2
              WHERE TO_CHAR(ass.assignment_status_type_id) = hoi1.org_information1
              AND   hoi1.org_information_context    = 'Reporting Statuses'
              AND   hoi1.organization_id            = p_business_group_id
              AND   ass.employment_category        = hoi2.org_information1
              AND   hoi2.organization_id            = p_business_group_id
              AND   hoi2.org_information_context    = 'Reporting Categories'
)
    AND ass.location_id = pgn_est.entity_id
    AND (pgn_est.hierarchy_node_id = l_hierarchy_node_id
           OR pgn_est.parent_hierarchy_node_id = l_hierarchy_node_id)
    AND  pgn_est.node_type IN ('EST','LOC')
    AND pgn_est.hierarchy_version_id = p_hierarchy_version_id
    AND pgn_est.business_group_id  = p_business_group_id
    AND peo.sex = 'F'
    AND  1 > (SELECT count(*)
                FROM per_gen_hierarchy_nodes         pgn_loc
               WHERE pgn_est.entity_id = pgn_loc.entity_id
                 AND pgn_loc.node_type = 'LOC'
                 AND pgn_loc.parent_hierarchy_node_id = pgn_est.hierarchy_node_id
                 AND pgn_loc.business_group_id = p_business_group_id)
    GROUP BY hrl.lookup_code;

  l_c_female_details c_female_details%ROWTYPE;

  CURSOR c_male_details IS
     SELECT
           COUNT(DECODE(peo.per_information1,'3',1))   c_hlmale,
	   COUNT(DECODE(peo.per_information1,'1',1))   c_wmale,
           COUNT(DECODE(peo.per_information1,'2',1))   c_bmale,
           COUNT(DECODE(peo.per_information1,'5',1))   c_hmale,
           COUNT(DECODE(peo.per_information1,'4',1))   c_amale,
           COUNT(DECODE(peo.per_information1,'6',1))   c_imale,
	   COUNT(DECODE(peo.per_information1,'13',1))   c_tmracesmale,
            hrl.lookup_code lookup_code
    FROM   per_all_people_f                peo,
           per_all_assignments_f           ass,
           per_jobs_vl                     job,
           hr_lookups                      hrl,
           per_gen_hierarchy_nodes         pgn_est
    WHERE  peo.person_id = ass.person_id
    AND    peo.per_information1 IS NOT NULL
    AND    peo.per_information_category = 'US'
    AND    job.job_information_category = 'US'
    AND    p_start_date <= NVL(job.date_to,p_start_date)
    AND    p_end_date >= job.date_from
    AND    job.job_information1 = hrl.lookup_code
    AND    hrl.lookup_type = 'US_EEO1_JOB_CATEGORIES'
    AND    ass.job_id = job.job_id
    AND    peo.effective_start_date =
             (SELECT MAX(peo1.effective_start_date)
              FROM   per_people_f peo1
              WHERE  p_start_date <= peo1.effective_end_date
              AND    p_end_date >= peo1.effective_start_date
              AND    peo.person_id = peo1.person_id
              AND    peo1.current_employee_flag = 'Y'
              )
    AND ass.effective_start_date =
             (SELECT MAX(ass1.effective_start_date)
              FROM   per_assignments_f ass1
              WHERE  p_start_date <= ass1.effective_end_date
  AND    p_end_date >= ass1.effective_start_date
              AND    ass.person_id = ass1.person_id
              AND    ass1.assignment_type  = 'E'
              AND    ass1.primary_flag     = 'Y'
              )
    AND ass.assignment_type  = 'E'
    AND ass.primary_flag     = 'Y'
    AND ass.business_group_id =  P_BUSINESS_GROUP_ID
    AND peo.business_group_id =  P_BUSINESS_GROUP_ID
    AND job.business_group_id =  P_BUSINESS_GROUP_ID
    AND EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
              WHERE TO_CHAR(ASS.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND   hoi1.org_information_context    = 'Reporting Statuses'
              AND   hoi1.organization_id            = P_BUSINESS_GROUP_ID
              AND   ass.employment_category        = hoi2.org_information1
              AND   hoi2.organization_id            = P_BUSINESS_GROUP_ID
              AND   hoi2.org_information_context    = 'Reporting Categories'
)
    AND ass.location_id = pgn_est.entity_id
    AND (pgn_est.hierarchy_node_id = l_hierarchy_node_id
           OR pgn_est.parent_hierarchy_node_id = l_hierarchy_node_id)
    AND  pgn_est.node_type IN ('EST','LOC')
    AND pgn_est.hierarchy_version_id = p_hierarchy_version_id
    AND pgn_est.business_group_id  = p_business_group_id
    AND peo.sex = 'M'
    AND  1 > (SELECT count(*)
                FROM per_gen_hierarchy_nodes         pgn_loc
               WHERE pgn_est.entity_id = pgn_loc.entity_id
                 AND pgn_loc.node_type = 'LOC'
                 AND pgn_loc.parent_hierarchy_node_id = pgn_est.hierarchy_node_id
                 AND pgn_loc.business_group_id = p_business_group_id)
    GROUP BY hrl.lookup_code;

  l_c_male_details c_male_details%ROWTYPE;

  CURSOR c_mf_details IS
    -- Updated CURSOR BUG4583250
    SELECT
           count('all_birds_and_blokes_in_job')   c_mf,
           hrl.lookup_code lookup_code
    FROM   per_all_people_f                peo,
           per_all_assignments_f           ass,
           per_jobs_vl                     job,
           hr_lookups                      hrl,
           per_gen_hierarchy_nodes	   pgn_est
    WHERE  peo.person_id = ass.person_id
    AND    peo.per_information1 IN ('1','2','3','4','5','6','13') --BUG4410003
    AND    peo.per_information_category = 'US'
    AND    job.job_information_category = 'US'
    AND    p_start_date <= nvl(job.date_to,p_start_date)
    AND    p_end_date >= job.date_from
    AND    job.job_information1 = hrl.lookup_code
    AND    hrl.lookup_type = 'US_EEO1_JOB_CATEGORIES'
    AND    ass.job_id = job.job_id
    AND    peo.effective_start_date =
             (SELECT MAX(peo1.effective_start_date)
              FROM   per_people_f peo1
              WHERE  p_start_date <= peo1.effective_end_date
              AND    p_end_date >= peo1.effective_start_date
              AND    peo.person_id = peo1.person_id
              AND    peo1.current_employee_flag = 'Y'
              )
    AND ass.effective_start_date =
             (SELECT MAX(ass1.effective_start_date)
              FROM   per_assignments_f ass1
              WHERE  p_start_date <= ass1.effective_end_date
              AND    p_end_date >= ass1.effective_start_date
              AND    ass.person_id = ass1.person_id
              AND    ass1.assignment_type  = 'E'
              AND    ass1.primary_flag     = 'Y'
              )
    AND ass.assignment_type  = 'E'
    AND ass.primary_flag     = 'Y'
    AND ass.business_group_id =  P_BUSINESS_GROUP_ID
    AND peo.business_group_id =  P_BUSINESS_GROUP_ID
    AND job.business_group_id =  P_BUSINESS_GROUP_ID
    AND EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
              WHERE TO_CHAR(ASS.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND   hoi1.org_information_context    = 'Reporting Statuses'
              AND   hoi1.organization_id            = P_BUSINESS_GROUP_ID
              AND   ass.employment_category        = hoi2.org_information1
              AND   hoi2.organization_id            = P_BUSINESS_GROUP_ID
              AND   hoi2.org_information_context    = 'Reporting Categories'  )
    AND ass.location_id = pgn_est.entity_id
    AND (pgn_est.hierarchy_node_id = l_hierarchy_node_id
           OR pgn_est.parent_hierarchy_node_id = l_hierarchy_node_id)
    AND  pgn_est.node_type IN ('EST','LOC')
    AND pgn_est.hierarchy_version_id = p_hierarchy_version_id
    AND pgn_est.business_group_id  = p_business_group_id
    AND  1 > (SELECT count(*)
                FROM per_gen_hierarchy_nodes         pgn_loc
               WHERE pgn_est.entity_id = pgn_loc.entity_id
                 AND pgn_loc.node_type = 'LOC'
                 AND pgn_loc.parent_hierarchy_node_id = pgn_est.hierarchy_node_id
                 AND pgn_loc.business_group_id = p_business_group_id)
    GROUP BY hrl.lookup_code;

  l_start_date DATE := p_start_date;
  l_c_mf_details c_mf_details%ROWTYPE;

  CURSOR c_lastyears_details IS
    SELECT
     lei_information14   p_hlmale
      ,lei_information15  p_hlfemale
      ,lei_information4    p_wmale
     ,lei_information5     p_bmale
     ,lei_information6     p_hmale
     ,lei_information7     p_amale
     ,lei_information8     p_imale
     ,lei_information16   p_tmracesmale
     ,lei_information9     p_wfemale
     ,lei_information10   p_bfemale
     ,lei_information11   p_hfemale
     ,lei_information12   p_afemale
     ,lei_information13   p_ifemale
     ,lei_information17   p_tmracesfemale
     ,lei_information3     p_total

   FROM     hr_location_extra_info  lei
           ,per_gen_hierarchy_nodes pgn
  WHERE   lei.lei_information1 =  l_prev_year_filed
    AND   lei.information_type = 'EEO-1 Archive Information'
    -- BUG3646445
    AND   lei.location_id = pgn.entity_id
    AND  pgn.hierarchy_node_id =  l_hierarchy_node_id
    AND pgn.hierarchy_version_id = p_hierarchy_version_id;
   -- End of BUG3646445

  l_c_lastyears_details c_lastyears_details%ROWTYPE;

  PROCEDURE insert_location_eit(p_hierarchy_node_id IN NUMBER,
                                p_hierarchy_version_id IN NUMBER,
                                p_report_year IN  VARCHAR2)  IS

  p_update VARCHAR2(1) := 'C';
  l_location_id VARCHAR2(40);
  l_location_code VARCHAR2(100);
  l_location_extra_info_id NUMBER := NULL;
  l_object_version_number NUMBER := NULL;

  l_eit_count NUMBER := 0;
  l_min_year VARCHAR2(4) :=  NULL;

  BEGIN --insert_location_eit

     fnd_file.put_line(which => fnd_file.log,buff =>'insert INTO location eit ');

      BEGIN --Local1
         SELECT eloc.location_id,
                eloc.location_code
           INTO l_location_id,
                l_location_code
           FROM per_gen_hierarchy_nodes pgn,
                hr_locations_all eloc
          WHERE (hierarchy_node_id = p_hierarchy_node_id
             or parent_hierarchy_node_id = p_hierarchy_node_id)
            AND hierarchy_version_id =  p_hierarchy_version_id
            AND pgn.node_type = 'EST'
            AND eloc.location_id = pgn.entity_id;
      END;  --Local1
      fnd_file.put_line
         (which => fnd_file.log,
          buff  => 'location code IS '||l_location_code);
      --
      BEGIN --Local2
      SELECT 'U',
             location_extra_info_id
        INTO p_update,
             l_location_extra_info_id
        FROM hr_location_extra_info
       WHERE lei_information1 = p_report_year
         AND lei_information_category =  'EEO-1 Archive Information'
         AND location_id = l_location_id;
      EXCEPTION
      WHEN no_data_found THEN
         p_update := 'C';
         fnd_file.put_line
           (which => fnd_file.log,
            buff  => '                      ');
         fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Need to create new eit for location '
                     ||l_location_id ||' '|| l_location_code);

      WHEN OTHERS THEN
         NULL;
      END;--Local2

     IF p_update = 'U' THEN
         fnd_file.put_line
           (which => fnd_file.log,
            buff  => '                     ');
         fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'p_update '||p_update||' location_id to update IS '
                     ||l_location_id ||' '|| l_location_code);

         BEGIN--Local3
            SELECT object_version_number
              INTO l_object_version_number
              FROM hr_location_extra_info
             WHERE location_extra_info_id = l_location_extra_info_id;
         END;--Local3

         BEGIN --Local4
           hr_location_extra_info_api.delete_location_extra_info
            (p_validate                  =>    false -- true
            ,p_location_extra_info_id    =>    l_location_extra_info_id
            ,p_object_version_number     =>    l_object_version_number
            );
         END;--Local4
      COMMIT;

      p_update := 'C';

     END IF; --p_update = 'U'

   IF  p_update = 'C'  THEN
   fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'p_update '||p_update||' location_id '||l_location_id);
   fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'need to create new eit');

      BEGIN--Local5
         -- Bug 7447266
      /*
	 hr_location_extra_info_api.create_location_extra_info
          (p_validate                  =>    false  -- true
          ,p_location_id               =>    l_location_id
          ,p_information_type          =>    'EEO-1 Archive Information'
          ,p_lei_information_category  =>    'EEO-1 Archive Information'
          ,p_lei_information1          =>    p_report_year
          ,p_lei_information2          =>    'DATE report run '||sysdate -- l_conc_request_id
          ,p_lei_information3          =>    l_estab_rec.c_10_grand_total  -- grand tot mf
          ,p_lei_information4          =>    l_estab_rec.d_10_grand_total  -- white male
          ,p_lei_information5          =>    l_estab_rec.e_10_grand_total  -- black male
          ,p_lei_information6          =>    l_estab_rec.f_10_grand_total  -- hispanic males
          ,p_lei_information7          =>    l_estab_rec.g_10_grand_total  -- asian pac isle males
          ,p_lei_information8          =>    l_estab_rec.h_10_grand_total  -- american native males
          ,p_lei_information9          =>    l_estab_rec.j_10_grand_total  -- white females
          ,p_lei_information10         =>    l_estab_rec.k_10_grand_total  -- black females
          ,p_lei_information11         =>    l_estab_rec.l_10_grand_total  -- hispanic females
          ,p_lei_information12         =>    l_estab_rec.m_10_grand_total  -- asian pac isle females
          ,p_lei_information13         =>    l_estab_rec.o_10_grand_total  -- american native females
	    -- Bug# 5259440
          ,p_lei_information14         =>    l_estab_rec.a_10_grand_total       -- male hispanic or latino
          ,p_lei_information15         =>     l_estab_rec.b_10_grand_total     -- female hispanic or latino
          ,p_lei_information16         =>    l_estab_rec.i_10_grand_total  -- male two or more races
          ,p_lei_information17         =>    l_estab_rec.n_10_grand_total  -- female two or more races
          ,p_location_extra_info_id    =>    l_location_extra_info_id
          ,p_object_version_number     =>    l_object_version_number
           );
    */

hr_location_extra_info_api.create_location_extra_info
          (p_validate                  =>    false  -- true
          ,p_location_id               =>    l_location_id
          ,p_information_type          =>    'EEO-1 Archive Information'
          ,p_lei_information_category  =>    'EEO-1 Archive Information'
          ,p_lei_information1          =>    p_report_year
          ,p_lei_information2          =>    'DATE report run '||sysdate -- l_conc_request_id
          ,p_lei_information3          =>    l_estab_rec.o_10_grand_total  -- grand tot mf
          ,p_lei_information4          =>    l_estab_rec.c_10_grand_total  -- white male
          ,p_lei_information5          =>    l_estab_rec.d_10_grand_total  -- black male
          ,p_lei_information6          =>    l_estab_rec.e_10_grand_total  -- hispanic males
          ,p_lei_information7          =>    l_estab_rec.f_10_grand_total  -- asian pac isle males
          ,p_lei_information8          =>    l_estab_rec.g_10_grand_total  -- american native males
          ,p_lei_information9          =>    l_estab_rec.i_10_grand_total  -- white females
          ,p_lei_information10         =>    l_estab_rec.j_10_grand_total  -- black females
          ,p_lei_information11         =>    l_estab_rec.k_10_grand_total  -- hispanic females
          ,p_lei_information12         =>    l_estab_rec.l_10_grand_total  -- asian pac isle females
          ,p_lei_information13         =>    l_estab_rec.m_10_grand_total  -- american native females
	    -- Bug# 5259440
          ,p_lei_information14         =>    l_estab_rec.a_10_grand_total       -- male hispanic or latino
          ,p_lei_information15         =>     l_estab_rec.b_10_grand_total     -- female hispanic or latino
          ,p_lei_information16         =>    l_estab_rec.h_10_grand_total  -- male two or more races
          ,p_lei_information17         =>    l_estab_rec.n_10_grand_total  -- female two or more races
          ,p_location_extra_info_id    =>    l_location_extra_info_id
          ,p_object_version_number     =>    l_object_version_number
           );

      END;--Local5
      COMMIT;
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => '                                                       ');
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'eit created for location_id '||l_location_id ||' year '
                     ||p_report_year);
      /*fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'grand total IS '||l_estab_rec.a_11_last_year_grand_total); */
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => '   ');
   END IF; -- IF p_update = 'C'
   --
   -- IF over 4 eits delete the earliest
   --
   BEGIN--Local6

     BEGIN--Local7

         SELECT count(*)
           INTO l_eit_count
           FROM hr_location_extra_info  lei
          WHERE location_id = l_location_id
            AND information_type = 'EEO-1 Archive Information';
     EXCEPTION
        WHEN no_data_found THEN
             NULL;
        WHEN OTHERS THEN
             NULL;
     END;--Local7


    IF l_eit_count > 4 THEN
        BEGIN--Local8
          SELECT min(lei_information1)
            INTO l_min_year
            FROM hr_location_extra_info  lei
           WHERE location_id = l_location_id
             AND information_type = 'EEO-1 Archive Information';
        END;--Local8
        BEGIN--Local9
          SELECT location_extra_info_id, object_version_number
           INTO l_location_extra_info_id,l_object_version_number
           FROM hr_location_extra_info  lei
          WHERE lei_information1 = l_min_year
            AND information_type = 'EEO-1 Archive Information'
            AND location_id = l_location_id;
        END;--Local9
        BEGIN--Local10
         hr_location_extra_info_api.delete_location_extra_info
            (p_validate                  =>    false -- true
            ,p_location_extra_info_id    =>    l_location_extra_info_id
            ,p_object_version_number     =>    l_object_version_number
            );
        END;--Local10
        fnd_file.put_line
             (which => fnd_file.log,
              buff  => '* there are over 4 Archive EITs for location id '
                     ||l_location_id||' so deleting for year '||l_min_year);
    END IF;--l_eit_count > 4

   END;--Local6

END insert_location_eit;
--
PROCEDURE insert_org_eit(p_hierarchy_node_id IN NUMBER,
                         p_hierarchy_version_id IN NUMBER,
                         p_business_group_id    IN NUMBER,
                         p_report_year IN  VARCHAR2)  IS

  p_update VARCHAR2(1) := 'C';
  l_effective_date DATE := sysdate;
  l_org_information_id NUMBER := NULL;
  l_object_version_number NUMBER := NULL;

  l_organization_id NUMBER(15,0);
  l_location_code VARCHAR2(100);
  l_location_extra_info_id NUMBER := NULL;

  l_eit_count NUMBER := 0;
  l_min_year VARCHAR2(4) :=  NULL;
  l_proc VARCHAR2(40) := g_package || 'insert_org_eit';

BEGIN--insert_org_eit

   BEGIN--Local1
      l_organization_id := l_org_rec.par_ent_org_id;
      SELECT 'U', org_information_id
        INTO p_update, l_org_information_id
        FROM hr_organization_information
       WHERE org_information1 = p_report_year
         AND ORG_INFORMATION_CONTEXT =  'EEO_Archive'
         AND organization_id = l_org_rec.par_ent_org_id;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_update := 'C';
      l_organization_id := l_org_rec.par_ent_org_id;
      --
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => '                      ');
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'need to create new eit for '||l_organization_id);
     fnd_file.put_line
           (which => fnd_file.log,
            buff  => '                      ');
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'IMPORTANT.  IF YOU FILED LAST YEAR BUT LAST YEARS DATES');
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'ARE NOT BEING PRINTED, PLEASE EITHER MANUALLY ENTER DATA');
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'IN THE ORGANIZATION EIT, OR RE-RUN THIS REPORT IN FINAL ');
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'MODE FOR LAST YEARS DATES. ');
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => '                      ');
   WHEN OTHERS  THEN
      NULL;
   END;--Local1

   IF p_update = 'U' THEN
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'p_update '||p_update||' org_id to update IS '
                     ||l_organization_id||' IN bus grp '
                     ||p_business_group_id);

      BEGIN --Local2
            SELECT object_version_number
              INTO l_object_version_number
              FROM hr_organization_information
             WHERE org_information_id = l_org_information_id;
      END;--Local2

      --
      --  (delete AND turn marker to 'C') ...
      --
      BEGIN--Local3
         hr_organization_api.delete_org_manager
            (p_validate                  =>    false -- true
            ,p_org_information_id        =>    l_org_information_id
            ,p_object_version_number     =>    l_object_version_number
            );
      END;--Local3
      COMMIT;
      --
      p_update := 'C';
      --
   END IF; --p_update = 'U'

   IF  p_update = 'C' THEN
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => '                      ');
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'p_update '||p_update||' org id '||l_organization_id);
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'need to create new eit');

      BEGIN --Local4
     /*    hr_organization_api.create_org_information
         (p_validate              =>         false
         ,p_effective_date        =>         l_effective_date
         ,p_organization_id       =>         l_organization_id
         ,p_org_info_type_code    =>         'EEO_Archive'
         ,p_org_information1      =>         p_report_year
         ,p_org_information2      =>         'DATE report run '||sysdate
         ,p_org_information3         =>    l_estab_rec.c_10_grand_total  -- grand tot mf
          ,p_org_information4          =>    l_estab_rec.d_10_grand_total  -- white male
          ,p_org_information5          =>    l_estab_rec.e_10_grand_total  -- black male
          ,p_org_information6          =>    l_estab_rec.f_10_grand_total  -- hispanic males
          ,p_org_information7          =>    l_estab_rec.g_10_grand_total  -- asian pac isle males
          ,p_org_information8          =>    l_estab_rec.h_10_grand_total  -- american native males
          ,p_org_information9          =>    l_estab_rec.j_10_grand_total  -- white females
          ,p_org_information10         =>    l_estab_rec.k_10_grand_total  -- black females
          ,p_org_information11         =>    l_estab_rec.l_10_grand_total  -- hispanic females
          ,p_org_information12         =>    l_estab_rec.m_10_grand_total  -- asian pac isle females
          ,p_org_information13         =>    l_estab_rec.o_10_grand_total  -- american native females

          ,p_org_information14         =>    l_estab_rec.a_10_grand_total       -- male hispanic or latino
          ,p_org_information15         =>     l_estab_rec.b_10_grand_total     -- female hispanic or latino
          ,p_org_information16         =>    l_estab_rec.i_10_grand_total  -- male two or more races
          ,p_org_information17         =>    l_estab_rec.n_10_grand_total  -- female two or more races
         ,p_org_information_id       =>     l_org_information_id
         ,p_object_version_number =>         l_object_version_number
         ); */
	 hr_organization_api.create_org_information
         (p_validate              =>         false
         ,p_effective_date        =>         l_effective_date
         ,p_organization_id       =>         l_organization_id
         ,p_org_info_type_code    =>         'EEO_Archive'
         ,p_org_information1      =>         p_report_year
         ,p_org_information2      =>         'DATE report run '||sysdate
	 ,p_org_information3          =>    l_estab_rec.o_10_grand_total  -- grand tot mf
          ,p_org_information4          =>    l_estab_rec.c_10_grand_total  -- white male
          ,p_org_information5          =>    l_estab_rec.d_10_grand_total  -- black male
          ,p_org_information6          =>    l_estab_rec.e_10_grand_total  -- hispanic males
          ,p_org_information7          =>    l_estab_rec.f_10_grand_total  -- asian pac isle males
          ,p_org_information8          =>    l_estab_rec.g_10_grand_total  -- american native males
          ,p_org_information9          =>    l_estab_rec.i_10_grand_total  -- white females
          ,p_org_information10         =>    l_estab_rec.j_10_grand_total  -- black females
          ,p_org_information11         =>    l_estab_rec.k_10_grand_total  -- hispanic females
          ,p_org_information12         =>    l_estab_rec.l_10_grand_total  -- asian pac isle females
          ,p_org_information13         =>    l_estab_rec.m_10_grand_total  -- american native females
	 ,p_org_information14         =>    l_estab_rec.a_10_grand_total       -- male hispanic or latino
          ,p_org_information15         =>     l_estab_rec.b_10_grand_total     -- female hispanic or latino
          ,p_org_information16         =>    l_estab_rec.h_10_grand_total  -- male two or more races
          ,p_org_information17         =>    l_estab_rec.n_10_grand_total  -- female two or more races
	  ,p_org_information_id       =>     l_org_information_id
         ,p_object_version_number =>         l_object_version_number
         );

      END;--Local4
      COMMIT;

      fnd_file.put_line
           (which => fnd_file.log,
            buff  => '                                                 ');
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'eit created for org id '||l_organization_id
                      ||' year '||p_report_year);
   END IF; --p_update = 'C'

   --
   -- IF over 4 eits delete the earliest
   --
   BEGIN--Local5

     BEGIN--Local6

      SELECT count(*)
        INTO l_eit_count
        FROM hr_organization_information
       WHERE organization_id = p_business_group_id
         AND org_information_context = 'EEO_Archive';
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
           NULL;
        WHEN OTHERS THEN
           NULL;
     END;--Local6

     IF l_eit_count > 4 THEN
        BEGIN--Local7
           SELECT MIN(org_information1)
             INTO l_min_year
             FROM hr_organization_information
            WHERE organization_id = p_business_group_id
              AND ORG_INFORMATION_CONTEXT = 'EEO_Archive';
        END;--Local7

	BEGIN--Local8
         SELECT org_information_id,
                object_version_number
           INTO l_org_information_id
               ,l_object_version_number
           FROM hr_organization_information
          WHERE org_information1 = l_min_year
            AND org_information_context = 'EEO_Archive'
            AND organization_id = p_business_group_id;
        END;--Local8
        BEGIN--Local9
         hr_organization_api.delete_org_manager
            (p_validate                  =>    false -- true
            ,p_org_information_id        =>    l_org_information_id
            ,p_object_version_number     =>    l_object_version_number
            );
        END;--Local9
          fnd_file.put_line
           (which => fnd_file.log,
            buff  => ' there are over 4 Archive EITs for organization id '
                     ||p_business_group_id||' so deleting for year '||l_min_year);
     END IF;--l_eit_count > 4
   END; --Local5
END insert_org_eit;


BEGIN   --loop_through_establishments

  OPEN c_estab_details;
    LOOP
    FETCH c_estab_details INTO l_c_estab_details;
    EXIT WHEN c_estab_details%NOTFOUND;

      BEGIN -- unit name AND address are required.
         IF (l_c_estab_details.unit_name_4 IS NULL OR
             l_c_estab_details.unit_address_req_5 IS NULL)
         THEN
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '======================================================');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '                 ');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => 'Unit name AND address are '
                 ||'required fields - ');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => 'Please enter ''Reporting Name'' IN location/extra '
                 ||'info/eeo1 specific information for unit/establishment '
                 ||l_c_estab_details.unit_name_4||' '
                 ||l_c_estab_details.unit_address_req_5);
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '                 ');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => 'Nav path = location/extra info/EEO1 Specific Data');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '                 ');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '======================================================');
            RAISE hr_utility.hr_error;
         ELSIF
               (l_c_estab_details.city_7 IS NULL OR
                l_c_estab_details.state_8 IS NULL OR
                l_c_estab_details.zip_code_9 IS NULL OR
                l_c_estab_details.county_17 IS NULL)
         THEN
               fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '==================================');
               fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '                 ');
               fnd_file.put_line
                (which => fnd_file.log,
                 buff  => 'The Location/Establishment City, State, County AND '
                 ||'Zip Code are required fields  ');
               fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '                 ');
               fnd_file.put_line
                (which => fnd_file.log,
                 buff  => 'Please enter IN location form for unit '
                 ||l_c_estab_details.unit_name_4);
               fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '==================================');
            RAISE hr_utility.hr_error;
         END IF;
      END; -- unit name AND address are required.
      -- do not let unit name start with 'The'

      IF UPPER(SUBSTR(l_c_estab_details.unit_name_4,1,3)) = UPPER('THE')
      THEN
         l_c_estab_details.unit_name_4 :=
         ltrim(l_c_estab_details.unit_name_4,'THEthe');
         l_c_estab_details.unit_name_4 :=
         (l_c_estab_details.unit_name_4||' The');
      END IF;

      --
      BEGIN--Local1
      -- vikkybbbbb
      -- IF answer to question c1, c2 or c3 IS Yes (1)
      -- THEN all required fields will be required.
      -- 7441123
     /*   IF (l_org_rec.c2_affiliated_14 = 1 OR l_org_rec.c1_over_100_13 = 1
         OR l_c_estab_details.gov_contract_15 = 1) THEN  */

          IF ( nvl(l_org_rec.c2_affiliated_14,'X') = '1' OR nvl(l_org_rec.c1_over_100_13,'X') = '1'
          OR nvl(l_c_estab_details.gov_contract_15,'X') = '1') THEN

         IF (l_c_estab_details.naics_21 IS NULL AND l_org_rec.naics_21 IS NULL) THEN
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '*==================================================*');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '                 ');
            fnd_file.put_line
                  (which => fnd_file.log,
                   buff  => 'The Location/Establishment NAICS NUMBER '
                   ||'IS a required field ');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => 'Please enter IN either location/extra info'
                 ||'/eeo1 specific information ');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => 'for unit/establishment: ');
             fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '<<'||l_c_estab_details.unit_name_4||'>>');
             fnd_file.put_line
                (which => fnd_file.log,
                 buff  => 'address: ');
             fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '<<'||l_c_estab_details.unit_address_req_5||' '
                 ||l_c_estab_details.unit_address_6||' '
                 ||l_c_estab_details.city_7||' '
                 ||l_c_estab_details.state_8||' '
                 ||l_c_estab_details.zip_code_9||'>>');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '*Nav path = location/extra info/EEO1/VETS Generic Data*');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '                 ');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '~OR~');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '                 ');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => 'enter at organization level - for the '
                 ||'top organization IN this hierarchy (ie.GRE/Parent Entity)');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => 'IN parent entity EEO1/VETS Establishment Data');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '*Nav path = Organization/Description/Parent Entity/'||
                 'Others/EEO1/VETS Establishment Data*');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '                 ');
            fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '*==================================================*');
            RAISE hr_utility.hr_error;
         END IF; --(l_c_estab_details.naics_21 IS NULL AND l_org_rec.naics_21 IS NULL)

	 IF (l_org_rec.title_cert_off_22 IS NULL OR
             l_org_rec.name_cert_off_23 IS NULL OR
             l_org_rec.tel_num_24 IS NULL) THEN
               fnd_file.put_line
                (which => fnd_file.log,
                 buff  => '==================================');
               fnd_file.put_line
                 (which => fnd_file.log,
                  buff  => '        ');
               fnd_file.put_line
                 (which => fnd_file.log,
                  buff  => 'Fields 22/23/24 - Title of certifying official AND'
                  ||'/or their name AND phone NUMBER IS blank.  ');
               fnd_file.put_line
                  (which => fnd_file.log,
                   buff  => 'These are required fields.  Please enter '
                   ||'at organization level for the Business Group ');
               fnd_file.put_line
                  (which => fnd_file.log,
                   buff  => '        ');
               fnd_file.put_line
                  (which => fnd_file.log,
                   buff  => '<<'||l_org_rec.org_name||'>>');
               fnd_file.put_line
                  (which => fnd_file.log,
                   buff  => '        ');
               fnd_file.put_line
                  (which => fnd_file.log,
                   buff  => 'nav path = '
                   ||'Business Group Organization/Description/Business Group'
                   ||'/Others/EEO Report Details');
               fnd_file.put_line
                  (which => fnd_file.log,
                   buff  => '(unit name: '
                  ||l_c_estab_details.unit_name_4||' address: '
                  ||l_c_estab_details.unit_address_req_5||' '
                  ||l_c_estab_details.zip_code_9||')');
               fnd_file.put_line
                  (which => fnd_file.log,
                   buff  => '        ');
               fnd_file.put_line
                  (which => fnd_file.log,
                   buff  => '==================================');
               RAISE hr_utility.hr_error;
         END IF;--l_org_rec.title_cert_off_22 IS NULL

      END IF;--l_org_rec.c2_affiliated_14 = 1

      END;--Local1

      l_estab_rec := l_estab_rec_blank;
      l_hierarchy_node_id := l_c_estab_details.hierarchy_node_id;
      l_estab_rec.unit_number_3 := l_c_estab_details.unit_number_3;
      l_estab_rec.unit_name_4 := l_c_estab_details.unit_name_4;
      l_estab_rec.unit_address_req_5 := l_c_estab_details.unit_address_req_5;
      l_estab_rec.unit_address_6 := l_c_estab_details.unit_address_6;
      l_estab_rec.city_7 := l_c_estab_details.city_7;
      l_estab_rec.state_8 := l_c_estab_details.state_8;
      l_estab_rec.zip_code_9 := l_c_estab_details.zip_code_9;
      l_estab_rec.zip_code_last_4_10 := l_c_estab_details.zip_code_last_4_10;
      l_estab_rec.reported_last_year_11 := l_c_estab_details.reported_last_year_11;
      l_estab_rec.ein_12 := l_c_estab_details.ein_12;
      l_estab_rec.gov_contract_15 := l_c_estab_details.gov_contract_15;
      l_estab_rec.duns_16 := l_c_estab_details.duns_16;
      l_estab_rec.county_17 := l_c_estab_details.county_17;
      l_estab_rec.apprentices_emp_19 := l_c_estab_details.apprentices_emp_19;
      l_estab_rec.sic_20 := l_c_estab_details.sic_20;
      l_estab_rec.naics_21 := l_c_estab_details.naics_21; -- vik need nvl here?
      l_estab_rec.hq := l_c_estab_details.hq;


      OPEN c_estab_max;
      FETCH c_estab_max INTO l_estab_max;
      EXIT WHEN c_estab_details%NOTFOUND;
      CLOSE c_estab_max;

      IF l_estab_max >= 50 THEN
         l_estab_rec.max_count := 'Y';
      ELSE
         l_estab_rec.max_count := 'N';
      END IF;

      hr_utility.set_location(l_proc,10);
      hr_utility.trace('p_hierarchy_version_id : ' || p_hierarchy_version_id);

   /*   OPEN c_mf_details;
      LOOP
      FETCH c_mf_details INTO l_c_mf_details;
      EXIT WHEN c_mf_details%NOTFOUND;

          hr_utility.trace('l_hierarchy_node_id : ' || l_hierarchy_node_id);

	  IF l_c_mf_details.lookup_code = '1' THEN
            --
            -- count First/Mid Level Officials and Managers
            --
            l_estab_rec.a_1_total_mf :=  l_c_mf_details.c_mf;
            --
            l_consol_rec.a_1_total_mf := nvl(l_consol_rec.a_1_total_mf,0) +
                                         nvl(l_estab_rec.a_1_total_mf,0);

          ELSIF l_c_mf_details.lookup_code = '2' THEN
            --
            -- count professionals (pr)
            --
            l_estab_rec.a_2_total_mf :=  l_c_mf_details.c_mf;
            l_consol_rec.a_2_total_mf := nvl(l_consol_rec.a_2_total_mf,0) +
                                         nvl(l_estab_rec.a_2_total_mf,0);

	  ELSIF l_c_mf_details.lookup_code = '3' THEN
            --
            -- count technicians (te)
            --
            l_estab_rec.a_3_total_mf :=  l_c_mf_details.c_mf;
            l_consol_rec.a_3_total_mf := nvl(l_consol_rec.a_3_total_mf,0) +
                                         nvl(l_estab_rec.a_3_total_mf,0);

          ELSIF l_c_mf_details.lookup_code = '4' THEN
            --
            -- count salesworkers (sa)
            --
            l_estab_rec.a_4_total_mf :=  l_c_mf_details.c_mf;
            --
            l_consol_rec.a_4_total_mf := nvl(l_consol_rec.a_4_total_mf,0) +
                                         nvl(l_estab_rec.a_4_total_mf,0);

	  ELSIF l_c_mf_details.lookup_code = '5' THEN
            --
            -- count office AND clerical (oc)
            --
            l_estab_rec.a_5_total_mf :=  l_c_mf_details.c_mf;
            l_consol_rec.a_5_total_mf := nvl(l_consol_rec.a_5_total_mf,0) +
                                         nvl(l_estab_rec.a_5_total_mf,0);

          ELSIF l_c_mf_details.lookup_code = '6' THEN
            --
            -- count craftworkers - skilled (cw)
            --
            l_estab_rec.a_6_total_mf :=  l_c_mf_details.c_mf;
            -- BUG4494412
            l_consol_rec.a_6_total_mf := nvl(l_consol_rec.a_6_total_mf,0) +
                                         nvl(l_estab_rec.a_6_total_mf,0);

          ELSIF l_c_mf_details.lookup_code = '7' THEN
            --
            -- count operatives - semi skilled (op)
            --
            l_estab_rec.a_7_total_mf :=  l_c_mf_details.c_mf;
            --
            l_consol_rec.a_7_total_mf := nvl(l_consol_rec.a_7_total_mf,0) +
                                         nvl(l_estab_rec.a_7_total_mf,0);

	  ELSIF l_c_mf_details.lookup_code = '8' THEN
            --
            -- count laborers - unskilled (la)
            --
            l_estab_rec.a_8_total_mf :=  l_c_mf_details.c_mf;
            l_consol_rec.a_8_total_mf := nvl(l_consol_rec.a_8_total_mf,0) +
                                         nvl(l_estab_rec.a_8_total_mf,0);
          ELSIF l_c_mf_details.lookup_code = '9' THEN
            --
            -- count service workers (sw)
            --
            l_estab_rec.a_9_total_mf :=  l_c_mf_details.c_mf;
            l_consol_rec.a_9_total_mf := nvl(l_consol_rec.a_9_total_mf,0) +
                                         nvl(l_estab_rec.a_9_total_mf,0);
          END IF;

        END LOOP;

      CLOSE c_mf_details; */

      hr_utility.set_location(l_proc,20);
      OPEN c_female_details;
      LOOP
      FETCH c_female_details INTO l_c_female_details;
      EXIT WHEN c_female_details%NOTFOUND;

          --
          -- hawaii stuff here?
          --
          IF l_c_female_details.lookup_code = '10' THEN
            --
            -- count Executive/Senior Level Officials and Managers
            --
            l_estab_rec.b_1_hl_female := l_c_female_details.c_hlfemale;
            l_estab_rec.i_1_white_fem :=  l_c_female_details.c_wfemale;
            l_estab_rec.j_1_black_fem :=  l_c_female_details.c_bfemale;
            l_estab_rec.k_1_latin_fem := l_c_female_details.c_hfemale;
            l_estab_rec.l_1_aspac_fem := l_c_female_details.c_afemale;
            l_estab_rec.m_1_ameri_fem :=  l_c_female_details.c_ifemale;
	    l_estab_rec.n_1_tmraces_female  :=  l_c_female_details.c_tmracesfemale;

	    l_estab_rec.o_1_total_cat := l_estab_rec.b_1_hl_female +
	                                                l_estab_rec.i_1_white_fem +
							l_estab_rec.j_1_black_fem +
							 l_estab_rec.k_1_latin_fem +
							 l_estab_rec.l_1_aspac_fem +
							 l_estab_rec.m_1_ameri_fem +
							 l_estab_rec.n_1_tmraces_female;

	    hr_utility.trace('l_estab_rec.b_1_hl_female : ' || l_estab_rec.b_1_hl_female);
	    hr_utility.trace('l_estab_rec.i_1_white_fem : ' || l_estab_rec.i_1_white_fem);
	    hr_utility.trace('l_estab_rec.j_1_black_fem : ' || l_estab_rec.j_1_black_fem);
	    hr_utility.trace('l_estab_rec.k_1_latin_fem : ' || l_estab_rec.k_1_latin_fem);
	    hr_utility.trace('l_estab_rec.l_1_aspac_fem : ' || l_estab_rec.l_1_aspac_fem);
	    hr_utility.trace('l_estab_rec.m_1_ameri_fem : ' || l_estab_rec.m_1_ameri_fem);
	    hr_utility.trace('l_estab_rec.n_1_tmraces_female : ' || l_estab_rec.n_1_tmraces_female);

	    -- IF Hawaii
            /* IF l_estab_rec.state_8 = 'HI' THEN
               l_estab_rec.i_1_white_fem := (l_estab_rec.b_1_hl_female+
	                                                      l_estab_rec.i_1_white_fem +
                                                              l_estab_rec.j_1_black_fem +
                                                              l_estab_rec.k_1_latin_fem +
                                                              l_estab_rec.l_1_aspac_fem +
                                                              l_estab_rec.m_1_ameri_fem +
					                      l_estab_rec.n_1_tmraces_female);
               l_estab_rec.b_1_hl_female := 0;
               l_estab_rec.j_1_black_fem :=  0;
               l_estab_rec.k_1_latin_fem := 0;
               l_estab_rec.l_1_aspac_fem := 0;
               l_estab_rec.m_1_ameri_fem :=  0;
	       l_estab_rec.n_1_tmraces_female  :=  0;

	    END IF;   */

	    l_consol_rec.b_1_hl_female := nvl(l_consol_rec.b_1_hl_female,0) +
                                          nvl(l_estab_rec.b_1_hl_female,0);
            l_consol_rec.i_1_white_fem := nvl(l_consol_rec.i_1_white_fem,0) +
                                          nvl(l_estab_rec.i_1_white_fem,0);
            l_consol_rec.j_1_black_fem := nvl(l_consol_rec.j_1_black_fem,0) +
                                          nvl(l_estab_rec.j_1_black_fem,0);
            l_consol_rec.k_1_latin_fem := nvl(l_consol_rec.k_1_latin_fem,0) +
                                          nvl(l_estab_rec.k_1_latin_fem,0);
            l_consol_rec.l_1_aspac_fem := nvl(l_consol_rec.l_1_aspac_fem,0) +
                                          nvl(l_estab_rec.l_1_aspac_fem,0);
            l_consol_rec.m_1_ameri_fem := nvl(l_consol_rec.m_1_ameri_fem,0) +
                                          nvl(l_estab_rec.m_1_ameri_fem,0);
            l_consol_rec.n_1_tmraces_female := nvl(l_consol_rec.n_1_tmraces_female,0) +
                                          nvl(l_estab_rec.n_1_tmraces_female,0);

          ELSIF l_c_female_details.lookup_code = '1' THEN
            --
            -- count First/Mid Level Officials and Managers
            --
            l_estab_rec.b_2_hl_female := l_c_female_details.c_hlfemale;
            l_estab_rec.i_2_white_fem :=  l_c_female_details.c_wfemale;
            l_estab_rec.j_2_black_fem :=  l_c_female_details.c_bfemale;
            l_estab_rec.k_2_latin_fem := l_c_female_details.c_hfemale;
            l_estab_rec.l_2_aspac_fem := l_c_female_details.c_afemale;
            l_estab_rec.m_2_ameri_fem :=  l_c_female_details.c_ifemale;
	    l_estab_rec.n_2_tmraces_female  :=  l_c_female_details.c_tmracesfemale;

	    l_estab_rec.o_2_total_cat := l_estab_rec.b_2_hl_female +
	                                                l_estab_rec.i_2_white_fem +
							l_estab_rec.j_2_black_fem +
							 l_estab_rec.k_2_latin_fem +
							 l_estab_rec.l_2_aspac_fem +
							 l_estab_rec.m_2_ameri_fem +
							 l_estab_rec.n_2_tmraces_female;

	    hr_utility.trace('l_estab_rec.b_2_hl_female : ' || l_estab_rec.b_2_hl_female);
	    hr_utility.trace('l_estab_rec.i_2_white_fem : ' || l_estab_rec.i_2_white_fem);
	    hr_utility.trace('l_estab_rec.j_2_black_fem : ' || l_estab_rec.j_2_black_fem);
	    hr_utility.trace('l_estab_rec.k_2_latin_fem : ' || l_estab_rec.k_2_latin_fem);
	    hr_utility.trace('l_estab_rec.l_2_aspac_fem : ' || l_estab_rec.l_2_aspac_fem);
	    hr_utility.trace('l_estab_rec.m_2_ameri_fem : ' || l_estab_rec.m_2_ameri_fem);
	    hr_utility.trace('l_estab_rec.n_2_tmraces_female : ' || l_estab_rec.n_2_tmraces_female);

	    -- IF Hawaii
          /*  IF l_estab_rec.state_8 = 'HI' THEN
              l_estab_rec.i_2_white_fem := (l_estab_rec.b_2_hl_female +
	                                                     l_estab_rec.i_2_white_fem +
                                                             l_estab_rec.j_2_black_fem +
                                                             l_estab_rec.k_2_latin_fem +
                                                             l_estab_rec.l_2_aspac_fem +
                                                             l_estab_rec.m_2_ameri_fem +
					                     l_estab_rec.n_2_tmraces_female);
               l_estab_rec.b_2_hl_female := 0;
               l_estab_rec.j_2_black_fem :=  0;
               l_estab_rec.k_2_latin_fem := 0;
               l_estab_rec.l_2_aspac_fem := 0;
               l_estab_rec.m_2_ameri_fem :=  0;
	       l_estab_rec.n_2_tmraces_female  :=  0;

            END IF;  */

             l_consol_rec.b_2_hl_female := nvl(l_consol_rec.b_2_hl_female,0) +
                                          nvl(l_estab_rec.b_2_hl_female,0);
            l_consol_rec.i_2_white_fem := nvl(l_consol_rec.i_2_white_fem,0) +
                                          nvl(l_estab_rec.i_2_white_fem,0);
            l_consol_rec.j_2_black_fem := nvl(l_consol_rec.j_2_black_fem,0) +
                                          nvl(l_estab_rec.j_2_black_fem,0);
            l_consol_rec.k_2_latin_fem := nvl(l_consol_rec.k_2_latin_fem,0) +
                                          nvl(l_estab_rec.k_2_latin_fem,0);
            l_consol_rec.l_2_aspac_fem := nvl(l_consol_rec.l_2_aspac_fem,0) +
                                          nvl(l_estab_rec.l_2_aspac_fem,0);
            l_consol_rec.m_2_ameri_fem := nvl(l_consol_rec.m_2_ameri_fem,0) +
                                          nvl(l_estab_rec.m_2_ameri_fem,0);
            l_consol_rec.n_2_tmraces_female := nvl(l_consol_rec.n_2_tmraces_female,0) +
                                          nvl(l_estab_rec.n_2_tmraces_female,0);

           ELSIF l_c_female_details.lookup_code = '2' THEN
            --
            -- count Professionals
            --
             l_estab_rec.b_3_hl_female := l_c_female_details.c_hlfemale;
            l_estab_rec.i_3_white_fem :=  l_c_female_details.c_wfemale;
            l_estab_rec.j_3_black_fem :=  l_c_female_details.c_bfemale;
            l_estab_rec.k_3_latin_fem := l_c_female_details.c_hfemale;
            l_estab_rec.l_3_aspac_fem := l_c_female_details.c_afemale;
            l_estab_rec.m_3_ameri_fem :=  l_c_female_details.c_ifemale;
	    l_estab_rec.n_3_tmraces_female  :=  l_c_female_details.c_tmracesfemale;

	     l_estab_rec.o_3_total_cat := l_estab_rec.b_3_hl_female +
	                                                l_estab_rec.i_3_white_fem +
							l_estab_rec.j_3_black_fem +
							 l_estab_rec.k_3_latin_fem +
							 l_estab_rec.l_3_aspac_fem +
							 l_estab_rec.m_3_ameri_fem +
							 l_estab_rec.n_3_tmraces_female;

	    hr_utility.trace('l_estab_rec.b_3_hl_female : ' || l_estab_rec.b_3_hl_female);
	    hr_utility.trace('l_estab_rec.i_3_white_fem : ' || l_estab_rec.i_3_white_fem);
	    hr_utility.trace('l_estab_rec.j_3_black_fem : ' || l_estab_rec.j_3_black_fem);
	    hr_utility.trace('l_estab_rec.k_3_latin_fem : ' || l_estab_rec.k_3_latin_fem);
	    hr_utility.trace('l_estab_rec.l_3_aspac_fem : ' || l_estab_rec.l_3_aspac_fem);
	    hr_utility.trace('l_estab_rec.m_3_ameri_fem : ' || l_estab_rec.m_3_ameri_fem);
	    hr_utility.trace('l_estab_rec.n_3_tmraces_female : ' || l_estab_rec.n_3_tmraces_female);

	    -- IF Hawaii
          /*  IF l_estab_rec.state_8 = 'HI' THEN
                l_estab_rec.i_3_white_fem := (l_estab_rec.b_3_hl_female +
		                                             l_estab_rec.i_3_white_fem +
                                                             l_estab_rec.j_3_black_fem +
                                                             l_estab_rec.k_3_latin_fem +
                                                             l_estab_rec.l_3_aspac_fem +
                                                             l_estab_rec.m_3_ameri_fem +
					                     l_estab_rec.n_3_tmraces_female);
               l_estab_rec.b_3_hl_female := 0;
               l_estab_rec.j_3_black_fem :=  0;
               l_estab_rec.k_3_latin_fem := 0;
               l_estab_rec.l_3_aspac_fem := 0;
               l_estab_rec.m_3_ameri_fem :=  0;
	       l_estab_rec.n_3_tmraces_female  :=  0;

            END IF;  */

            l_consol_rec.b_3_hl_female := nvl(l_consol_rec.b_3_hl_female,0) +
                                          nvl(l_estab_rec.b_3_hl_female,0);
            l_consol_rec.i_3_white_fem := nvl(l_consol_rec.i_3_white_fem,0) +
                                          nvl(l_estab_rec.i_3_white_fem,0);
            l_consol_rec.j_3_black_fem := nvl(l_consol_rec.j_3_black_fem,0) +
                                          nvl(l_estab_rec.j_3_black_fem,0);
            l_consol_rec.k_3_latin_fem := nvl(l_consol_rec.k_3_latin_fem,0) +
                                          nvl(l_estab_rec.k_3_latin_fem,0);
            l_consol_rec.l_3_aspac_fem := nvl(l_consol_rec.l_3_aspac_fem,0) +
                                          nvl(l_estab_rec.l_3_aspac_fem,0);
            l_consol_rec.m_3_ameri_fem := nvl(l_consol_rec.m_3_ameri_fem,0) +
                                          nvl(l_estab_rec.m_3_ameri_fem,0);
            l_consol_rec.n_3_tmraces_female := nvl(l_consol_rec.n_3_tmraces_female,0) +
                                          nvl(l_estab_rec.n_3_tmraces_female,0);

           ELSIF l_c_female_details.lookup_code = '3' THEN
            --
            -- count Technicians
            --
            l_estab_rec.b_4_hl_female := l_c_female_details.c_hlfemale;
            l_estab_rec.i_4_white_fem :=  l_c_female_details.c_wfemale;
            l_estab_rec.j_4_black_fem :=  l_c_female_details.c_bfemale;
            l_estab_rec.k_4_latin_fem := l_c_female_details.c_hfemale;
            l_estab_rec.l_4_aspac_fem := l_c_female_details.c_afemale;
            l_estab_rec.m_4_ameri_fem :=  l_c_female_details.c_ifemale;
	    l_estab_rec.n_4_tmraces_female  :=  l_c_female_details.c_tmracesfemale;

	    l_estab_rec.o_4_total_cat := l_estab_rec.b_4_hl_female +
	                                                l_estab_rec.i_4_white_fem +
							l_estab_rec.j_4_black_fem +
							 l_estab_rec.k_4_latin_fem +
							 l_estab_rec.l_4_aspac_fem +
							 l_estab_rec.m_4_ameri_fem +
							 l_estab_rec.n_4_tmraces_female;

	    hr_utility.trace('l_estab_rec.b_4_hl_female : ' || l_estab_rec.b_4_hl_female);
	    hr_utility.trace('l_estab_rec.i_4_white_fem : ' || l_estab_rec.i_4_white_fem);
	    hr_utility.trace('l_estab_rec.j_4_black_fem : ' || l_estab_rec.j_4_black_fem);
	    hr_utility.trace('l_estab_rec.k_4_latin_fem : ' || l_estab_rec.k_4_latin_fem);
	    hr_utility.trace('l_estab_rec.l_4_aspac_fem : ' || l_estab_rec.l_4_aspac_fem);
	    hr_utility.trace('l_estab_rec.m_4_ameri_fem : ' || l_estab_rec.m_4_ameri_fem);
	    hr_utility.trace('l_estab_rec.n_4_tmraces_female : ' || l_estab_rec.n_4_tmraces_female);

	    -- IF Hawaii
           /* IF l_estab_rec.state_8 = 'HI' THEN
                l_estab_rec.i_4_white_fem := (l_estab_rec.b_4_hl_female +
		                                               l_estab_rec.i_4_white_fem +
                                                               l_estab_rec.j_4_black_fem +
                                                               l_estab_rec.k_4_latin_fem +
                                                               l_estab_rec.l_4_aspac_fem +
                                                               l_estab_rec.m_4_ameri_fem +
					                       l_estab_rec.n_4_tmraces_female);
               l_estab_rec.b_4_hl_female := 0;
               l_estab_rec.j_4_black_fem :=  0;
               l_estab_rec.k_4_latin_fem := 0;
               l_estab_rec.l_4_aspac_fem := 0;
               l_estab_rec.m_4_ameri_fem :=  0;
	       l_estab_rec.n_4_tmraces_female  :=  0;
           END IF;  */

           l_consol_rec.b_4_hl_female := nvl(l_consol_rec.b_4_hl_female,0) +
                                          nvl(l_estab_rec.b_4_hl_female,0);
            l_consol_rec.i_4_white_fem := nvl(l_consol_rec.i_4_white_fem,0) +
                                          nvl(l_estab_rec.i_4_white_fem,0);
            l_consol_rec.j_4_black_fem := nvl(l_consol_rec.j_4_black_fem,0) +
                                          nvl(l_estab_rec.j_4_black_fem,0);
            l_consol_rec.k_4_latin_fem := nvl(l_consol_rec.k_4_latin_fem,0) +
                                          nvl(l_estab_rec.k_4_latin_fem,0);
            l_consol_rec.l_4_aspac_fem := nvl(l_consol_rec.l_4_aspac_fem,0) +
                                          nvl(l_estab_rec.l_4_aspac_fem,0);
            l_consol_rec.m_4_ameri_fem := nvl(l_consol_rec.m_4_ameri_fem,0) +
                                          nvl(l_estab_rec.m_4_ameri_fem,0);
            l_consol_rec.n_4_tmraces_female := nvl(l_consol_rec.n_4_tmraces_female,0) +
                                          nvl(l_estab_rec.n_4_tmraces_female,0);

	    ELSIF l_c_female_details.lookup_code = '4' THEN
            --
            -- count Sales Workers
            --
            l_estab_rec.b_5_hl_female := l_c_female_details.c_hlfemale;
            l_estab_rec.i_5_white_fem :=  l_c_female_details.c_wfemale;
            l_estab_rec.j_5_black_fem :=  l_c_female_details.c_bfemale;
            l_estab_rec.k_5_latin_fem := l_c_female_details.c_hfemale;
            l_estab_rec.l_5_aspac_fem := l_c_female_details.c_afemale;
            l_estab_rec.m_5_ameri_fem :=  l_c_female_details.c_ifemale;
	    l_estab_rec.n_5_tmraces_female  :=  l_c_female_details.c_tmracesfemale;

	    l_estab_rec.o_5_total_cat := l_estab_rec.b_5_hl_female +
	                                                l_estab_rec.i_5_white_fem +
							l_estab_rec.j_5_black_fem +
							 l_estab_rec.k_5_latin_fem +
							 l_estab_rec.l_5_aspac_fem +
							 l_estab_rec.m_5_ameri_fem +
							 l_estab_rec.n_5_tmraces_female;

	    hr_utility.trace('l_estab_rec.b_5_hl_female : ' || l_estab_rec.b_5_hl_female);
	    hr_utility.trace('l_estab_rec.i_5_white_fem : ' || l_estab_rec.i_5_white_fem);
	    hr_utility.trace('l_estab_rec.j_5_black_fem : ' || l_estab_rec.j_5_black_fem);
	    hr_utility.trace('l_estab_rec.k_5_latin_fem : ' || l_estab_rec.k_5_latin_fem);
	    hr_utility.trace('l_estab_rec.l_5_aspac_fem : ' || l_estab_rec.l_5_aspac_fem);
	    hr_utility.trace('l_estab_rec.m_5_ameri_fem : ' || l_estab_rec.m_5_ameri_fem);
	    hr_utility.trace('l_estab_rec.n_5_tmraces_female : ' || l_estab_rec.n_5_tmraces_female);

	    -- IF Hawaii
         /*   IF l_estab_rec.state_8 = 'HI' THEN
               l_estab_rec.i_5_white_fem := (l_estab_rec.b_5_hl_female +
	                                                      l_estab_rec.i_5_white_fem +
                                                              l_estab_rec.j_5_black_fem +
                                                              l_estab_rec.k_5_latin_fem +
                                                              l_estab_rec.l_5_aspac_fem +
                                                              l_estab_rec.m_5_ameri_fem +
					                      l_estab_rec.n_5_tmraces_female);
               l_estab_rec.b_5_hl_female := 0;
               l_estab_rec.j_5_black_fem :=  0;
               l_estab_rec.k_5_latin_fem := 0;
               l_estab_rec.l_5_aspac_fem := 0;
               l_estab_rec.m_5_ameri_fem :=  0;
	       l_estab_rec.n_5_tmraces_female  :=  0;

	    END IF;  */

            l_consol_rec.b_5_hl_female := nvl(l_consol_rec.b_5_hl_female,0) +
                                          nvl(l_estab_rec.b_5_hl_female,0);
            l_consol_rec.i_5_white_fem := nvl(l_consol_rec.i_5_white_fem,0) +
                                          nvl(l_estab_rec.i_5_white_fem,0);
            l_consol_rec.j_5_black_fem := nvl(l_consol_rec.j_5_black_fem,0) +
                                          nvl(l_estab_rec.j_5_black_fem,0);
            l_consol_rec.k_5_latin_fem := nvl(l_consol_rec.k_5_latin_fem,0) +
                                          nvl(l_estab_rec.k_5_latin_fem,0);
            l_consol_rec.l_5_aspac_fem := nvl(l_consol_rec.l_5_aspac_fem,0) +
                                          nvl(l_estab_rec.l_5_aspac_fem,0);
            l_consol_rec.m_5_ameri_fem := nvl(l_consol_rec.m_5_ameri_fem,0) +
                                          nvl(l_estab_rec.m_5_ameri_fem,0);
            l_consol_rec.n_5_tmraces_female := nvl(l_consol_rec.n_5_tmraces_female,0) +
                                          nvl(l_estab_rec.n_5_tmraces_female,0);

	  ELSIF l_c_female_details.lookup_code = '5' THEN
            --
            -- count Administrative Support Workers
            --
            l_estab_rec.b_6_hl_female := l_c_female_details.c_hlfemale;
            l_estab_rec.i_6_white_fem :=  l_c_female_details.c_wfemale;
            l_estab_rec.j_6_black_fem :=  l_c_female_details.c_bfemale;
            l_estab_rec.k_6_latin_fem := l_c_female_details.c_hfemale;
            l_estab_rec.l_6_aspac_fem := l_c_female_details.c_afemale;
            l_estab_rec.m_6_ameri_fem :=  l_c_female_details.c_ifemale;
	    l_estab_rec.n_6_tmraces_female  :=  l_c_female_details.c_tmracesfemale;

	    l_estab_rec.o_6_total_cat := l_estab_rec.b_6_hl_female +
	                                                l_estab_rec.i_6_white_fem +
							l_estab_rec.j_6_black_fem +
							 l_estab_rec.k_6_latin_fem +
							 l_estab_rec.l_6_aspac_fem +
							 l_estab_rec.m_6_ameri_fem +
							 l_estab_rec.n_6_tmraces_female;

	    hr_utility.trace('l_estab_rec.b_6_hl_female : ' || l_estab_rec.b_6_hl_female);
	    hr_utility.trace('l_estab_rec.i_6_white_fem : ' || l_estab_rec.i_6_white_fem);
	    hr_utility.trace('l_estab_rec.j_6_black_fem : ' || l_estab_rec.j_6_black_fem);
	    hr_utility.trace('l_estab_rec.k_6_latin_fem : ' || l_estab_rec.k_6_latin_fem);
	    hr_utility.trace('l_estab_rec.l_6_aspac_fem : ' || l_estab_rec.l_6_aspac_fem);
	    hr_utility.trace('l_estab_rec.m_6_ameri_fem : ' || l_estab_rec.m_6_ameri_fem);
	    hr_utility.trace('l_estab_rec.n_6_tmraces_female : ' || l_estab_rec.n_6_tmraces_female);

	    -- IF Hawaii
          /*  IF l_estab_rec.state_8 = 'HI' THEN
                l_estab_rec.i_6_white_fem := (l_estab_rec.b_6_hl_female +
		                                               l_estab_rec.i_6_white_fem +
                                                               l_estab_rec.j_6_black_fem +
                                                               l_estab_rec.k_6_latin_fem +
                                                               l_estab_rec.l_6_aspac_fem +
                                                               l_estab_rec.m_6_ameri_fem +
					                       l_estab_rec.n_6_tmraces_female);
               l_estab_rec.b_6_hl_female := 0;
               l_estab_rec.j_6_black_fem :=  0;
               l_estab_rec.k_6_latin_fem := 0;
               l_estab_rec.l_6_aspac_fem := 0;
               l_estab_rec.m_6_ameri_fem :=  0;
	       l_estab_rec.n_6_tmraces_female  :=  0;

	    END IF;  */

            l_consol_rec.b_6_hl_female := nvl(l_consol_rec.b_6_hl_female,0) +
                                          nvl(l_estab_rec.b_6_hl_female,0);
            l_consol_rec.i_6_white_fem := nvl(l_consol_rec.i_6_white_fem,0) +
                                          nvl(l_estab_rec.i_6_white_fem,0);
            l_consol_rec.j_6_black_fem := nvl(l_consol_rec.j_6_black_fem,0) +
                                          nvl(l_estab_rec.j_6_black_fem,0);
            l_consol_rec.k_6_latin_fem := nvl(l_consol_rec.k_6_latin_fem,0) +
                                          nvl(l_estab_rec.k_6_latin_fem,0);
            l_consol_rec.l_6_aspac_fem := nvl(l_consol_rec.l_6_aspac_fem,0) +
                                          nvl(l_estab_rec.l_6_aspac_fem,0);
            l_consol_rec.m_6_ameri_fem := nvl(l_consol_rec.m_6_ameri_fem,0) +
                                          nvl(l_estab_rec.m_6_ameri_fem,0);
            l_consol_rec.n_6_tmraces_female := nvl(l_consol_rec.n_6_tmraces_female,0) +
                                          nvl(l_estab_rec.n_6_tmraces_female,0);

          ELSIF l_c_female_details.lookup_code = '6' THEN
            --
            -- count Craft Workers
            --
            l_estab_rec.b_7_hl_female := l_c_female_details.c_hlfemale;
            l_estab_rec.i_7_white_fem :=  l_c_female_details.c_wfemale;
            l_estab_rec.j_7_black_fem :=  l_c_female_details.c_bfemale;
            l_estab_rec.k_7_latin_fem := l_c_female_details.c_hfemale;
            l_estab_rec.l_7_aspac_fem := l_c_female_details.c_afemale;
            l_estab_rec.m_7_ameri_fem :=  l_c_female_details.c_ifemale;
	    l_estab_rec.n_7_tmraces_female  :=  l_c_female_details.c_tmracesfemale;

	    l_estab_rec.o_7_total_cat := l_estab_rec.b_7_hl_female +
	                                                l_estab_rec.i_7_white_fem +
							l_estab_rec.j_7_black_fem +
							 l_estab_rec.k_7_latin_fem +
							 l_estab_rec.l_7_aspac_fem +
							 l_estab_rec.m_7_ameri_fem +
							 l_estab_rec.n_7_tmraces_female;

	    hr_utility.trace('l_estab_rec.b_7_hl_female : ' || l_estab_rec.b_7_hl_female);
	    hr_utility.trace('l_estab_rec.i_7_white_fem : ' || l_estab_rec.i_7_white_fem);
	    hr_utility.trace('l_estab_rec.j_7_black_fem : ' || l_estab_rec.j_7_black_fem);
	    hr_utility.trace('l_estab_rec.k_7_latin_fem : ' || l_estab_rec.k_7_latin_fem);
	    hr_utility.trace('l_estab_rec.l_7_aspac_fem : ' || l_estab_rec.l_7_aspac_fem);
	    hr_utility.trace('l_estab_rec.m_7_ameri_fem : ' || l_estab_rec.m_7_ameri_fem);
	    hr_utility.trace('l_estab_rec.n_7_tmraces_female : ' || l_estab_rec.n_7_tmraces_female);

	    -- IF Hawaii
          /*  IF l_estab_rec.state_8 = 'HI' THEN
               l_estab_rec.i_7_white_fem := ( l_estab_rec.b_7_hl_female +
	                                                       l_estab_rec.i_7_white_fem +
                                                               l_estab_rec.j_7_black_fem +
                                                               l_estab_rec.k_7_latin_fem +
                                                               l_estab_rec.l_7_aspac_fem +
                                                               l_estab_rec.m_7_ameri_fem +
					                       l_estab_rec.n_7_tmraces_female);
               l_estab_rec.b_7_hl_female := 0;
               l_estab_rec.j_7_black_fem :=  0;
               l_estab_rec.k_7_latin_fem := 0;
               l_estab_rec.l_7_aspac_fem := 0;
               l_estab_rec.m_7_ameri_fem :=  0;
	       l_estab_rec.n_7_tmraces_female  :=  0;

	   END IF; */

           l_consol_rec.b_7_hl_female := nvl(l_consol_rec.b_7_hl_female,0) +
                                          nvl(l_estab_rec.b_7_hl_female,0);
            l_consol_rec.i_7_white_fem := nvl(l_consol_rec.i_7_white_fem,0) +
                                          nvl(l_estab_rec.i_7_white_fem,0);
            l_consol_rec.j_7_black_fem := nvl(l_consol_rec.j_7_black_fem,0) +
                                          nvl(l_estab_rec.j_7_black_fem,0);
            l_consol_rec.k_7_latin_fem := nvl(l_consol_rec.k_7_latin_fem,0) +
                                          nvl(l_estab_rec.k_7_latin_fem,0);
            l_consol_rec.l_7_aspac_fem := nvl(l_consol_rec.l_7_aspac_fem,0) +
                                          nvl(l_estab_rec.l_7_aspac_fem,0);
            l_consol_rec.m_7_ameri_fem := nvl(l_consol_rec.m_7_ameri_fem,0) +
                                          nvl(l_estab_rec.m_7_ameri_fem,0);
            l_consol_rec.n_7_tmraces_female := nvl(l_consol_rec.n_7_tmraces_female,0) +
                                          nvl(l_estab_rec.n_7_tmraces_female,0);
           --
          ELSIF l_c_female_details.lookup_code = '7' THEN
            --
            -- count Operatives
            --
             l_estab_rec.b_8_hl_female := l_c_female_details.c_hlfemale;
            l_estab_rec.i_8_white_fem :=  l_c_female_details.c_wfemale;
            l_estab_rec.j_8_black_fem :=  l_c_female_details.c_bfemale;
            l_estab_rec.k_8_latin_fem := l_c_female_details.c_hfemale;
            l_estab_rec.l_8_aspac_fem := l_c_female_details.c_afemale;
            l_estab_rec.m_8_ameri_fem :=  l_c_female_details.c_ifemale;
	    l_estab_rec.n_8_tmraces_female  :=  l_c_female_details.c_tmracesfemale;

	    l_estab_rec.o_8_total_cat := l_estab_rec.b_8_hl_female +
	                                                l_estab_rec.i_8_white_fem +
							l_estab_rec.j_8_black_fem +
							 l_estab_rec.k_8_latin_fem +
							 l_estab_rec.l_8_aspac_fem +
							 l_estab_rec.m_8_ameri_fem +
							 l_estab_rec.n_8_tmraces_female;

	    hr_utility.trace('l_estab_rec.b_8_hl_female : ' || l_estab_rec.b_8_hl_female);
	    hr_utility.trace('l_estab_rec.i_8_white_fem : ' || l_estab_rec.i_8_white_fem);
	    hr_utility.trace('l_estab_rec.j_8_black_fem : ' || l_estab_rec.j_8_black_fem);
	    hr_utility.trace('l_estab_rec.k_8_latin_fem : ' || l_estab_rec.k_8_latin_fem);
	    hr_utility.trace('l_estab_rec.l_8_aspac_fem : ' || l_estab_rec.l_8_aspac_fem);
	    hr_utility.trace('l_estab_rec.m_8_ameri_fem : ' || l_estab_rec.m_8_ameri_fem);
	    hr_utility.trace('l_estab_rec.n_8_tmraces_female : ' || l_estab_rec.n_8_tmraces_female);

	    -- IF Hawaii
          /*  IF l_estab_rec.state_8 = 'HI' THEN
               l_estab_rec.i_8_white_fem := (l_estab_rec.b_8_hl_female +
	                                                      l_estab_rec.i_8_white_fem +
                                                              l_estab_rec.j_8_black_fem +
                                                              l_estab_rec.k_8_latin_fem +
                                                              l_estab_rec.l_8_aspac_fem +
                                                              l_estab_rec.m_8_ameri_fem +
					                      l_estab_rec.n_8_tmraces_female);
               l_estab_rec.b_8_hl_female := 0;
               l_estab_rec.j_8_black_fem :=  0;
               l_estab_rec.k_8_latin_fem := 0;
               l_estab_rec.l_8_aspac_fem := 0;
               l_estab_rec.m_8_ameri_fem :=  0;
	       l_estab_rec.n_8_tmraces_female  :=  0;

	    END IF; */

            l_consol_rec.b_8_hl_female := nvl(l_consol_rec.b_8_hl_female,0) +
                                          nvl(l_estab_rec.b_8_hl_female,0);
            l_consol_rec.i_8_white_fem := nvl(l_consol_rec.i_8_white_fem,0) +
                                          nvl(l_estab_rec.i_8_white_fem,0);
            l_consol_rec.j_8_black_fem := nvl(l_consol_rec.j_8_black_fem,0) +
                                          nvl(l_estab_rec.j_8_black_fem,0);
            l_consol_rec.k_8_latin_fem := nvl(l_consol_rec.k_8_latin_fem,0) +
                                          nvl(l_estab_rec.k_8_latin_fem,0);
            l_consol_rec.l_8_aspac_fem := nvl(l_consol_rec.l_8_aspac_fem,0) +
                                          nvl(l_estab_rec.l_8_aspac_fem,0);
            l_consol_rec.m_8_ameri_fem := nvl(l_consol_rec.m_8_ameri_fem,0) +
                                          nvl(l_estab_rec.m_8_ameri_fem,0);
            l_consol_rec.n_8_tmraces_female := nvl(l_consol_rec.n_8_tmraces_female,0) +
                                          nvl(l_estab_rec.n_8_tmraces_female,0);

          ELSIF l_c_female_details.lookup_code = '8' THEN
            --
            -- count Laborers and Helpers
            --
            l_estab_rec.b_9_hl_female := l_c_female_details.c_hlfemale;
            l_estab_rec.i_9_white_fem :=  l_c_female_details.c_wfemale;
            l_estab_rec.j_9_black_fem :=  l_c_female_details.c_bfemale;
            l_estab_rec.k_9_latin_fem := l_c_female_details.c_hfemale;
            l_estab_rec.l_9_aspac_fem := l_c_female_details.c_afemale;
            l_estab_rec.m_9_ameri_fem :=  l_c_female_details.c_ifemale;
	    l_estab_rec.n_9_tmraces_female  :=  l_c_female_details.c_tmracesfemale;

	    l_estab_rec.o_9_total_cat := l_estab_rec.b_9_hl_female +
	                                                l_estab_rec.i_9_white_fem +
							l_estab_rec.j_9_black_fem +
							 l_estab_rec.k_9_latin_fem +
							 l_estab_rec.l_9_aspac_fem +
							 l_estab_rec.m_9_ameri_fem +
							 l_estab_rec.n_9_tmraces_female;

	    hr_utility.trace('l_estab_rec.b_9_hl_female : ' || l_estab_rec.b_9_hl_female);
	    hr_utility.trace('l_estab_rec.i_9_white_fem : ' || l_estab_rec.i_9_white_fem);
	    hr_utility.trace('l_estab_rec.j_9_black_fem : ' || l_estab_rec.j_9_black_fem);
	    hr_utility.trace('l_estab_rec.k_9_latin_fem : ' || l_estab_rec.k_9_latin_fem);
	    hr_utility.trace('l_estab_rec.l_9_aspac_fem : ' || l_estab_rec.l_9_aspac_fem);
	    hr_utility.trace('l_estab_rec.m_9_ameri_fem : ' || l_estab_rec.m_9_ameri_fem);
	    hr_utility.trace('l_estab_rec.n_9_tmraces_female : ' || l_estab_rec.n_9_tmraces_female);

	    -- IF Hawaii
          /*  IF l_estab_rec.state_8 = 'HI' THEN
                l_estab_rec.i_9_white_fem := (l_estab_rec.b_9_hl_female +
		                                               l_estab_rec.i_9_white_fem +
                                                               l_estab_rec.j_9_black_fem +
                                                               l_estab_rec.k_9_latin_fem +
                                                               l_estab_rec.l_9_aspac_fem +
                                                               l_estab_rec.m_9_ameri_fem +
					                       l_estab_rec.n_9_tmraces_female);
               l_estab_rec.b_9_hl_female := 0;
               l_estab_rec.j_9_black_fem :=  0;
               l_estab_rec.k_9_latin_fem := 0;
               l_estab_rec.l_9_aspac_fem := 0;
               l_estab_rec.m_9_ameri_fem :=  0;
	       l_estab_rec.n_9_tmraces_female  :=  0;

	   END IF; */
            --
           l_consol_rec.b_9_hl_female := nvl(l_consol_rec.b_9_hl_female,0) +
                                          nvl(l_estab_rec.b_9_hl_female,0);
            l_consol_rec.i_9_white_fem := nvl(l_consol_rec.i_9_white_fem,0) +
                                          nvl(l_estab_rec.i_9_white_fem,0);
            l_consol_rec.j_9_black_fem := nvl(l_consol_rec.j_9_black_fem,0) +
                                          nvl(l_estab_rec.j_9_black_fem,0);
            l_consol_rec.k_9_latin_fem := nvl(l_consol_rec.k_9_latin_fem,0) +
                                          nvl(l_estab_rec.k_9_latin_fem,0);
            l_consol_rec.l_9_aspac_fem := nvl(l_consol_rec.l_9_aspac_fem,0) +
                                          nvl(l_estab_rec.l_9_aspac_fem,0);
            l_consol_rec.m_9_ameri_fem := nvl(l_consol_rec.m_9_ameri_fem,0) +
                                          nvl(l_estab_rec.m_9_ameri_fem,0);
            l_consol_rec.n_9_tmraces_female := nvl(l_consol_rec.n_9_tmraces_female,0) +
                                          nvl(l_estab_rec.n_9_tmraces_female,0);

	  ELSIF l_c_female_details.lookup_code = '9' THEN
            --
            -- count Service Workers
            --
            l_estab_rec.b_10_hl_female := l_c_female_details.c_hlfemale;
            l_estab_rec.i_10_white_fem :=  l_c_female_details.c_wfemale;
            l_estab_rec.j_10_black_fem :=  l_c_female_details.c_bfemale;
            l_estab_rec.k_10_latin_fem := l_c_female_details.c_hfemale;
            l_estab_rec.l_10_aspac_fem := l_c_female_details.c_afemale;
            l_estab_rec.m_10_ameri_fem :=  l_c_female_details.c_ifemale;
	    l_estab_rec.n_10_tmraces_female  :=  l_c_female_details.c_tmracesfemale;

	    l_estab_rec.o_10_total_cat := l_estab_rec.b_10_hl_female +
	                                                l_estab_rec.i_10_white_fem +
							l_estab_rec.j_10_black_fem +
							 l_estab_rec.k_10_latin_fem +
							 l_estab_rec.l_10_aspac_fem +
							 l_estab_rec.m_10_ameri_fem +
							 l_estab_rec.n_10_tmraces_female;

	    hr_utility.trace('l_estab_rec.b_10_hl_female : ' || l_estab_rec.b_10_hl_female);
	    hr_utility.trace('l_estab_rec.i_10_white_fem : ' || l_estab_rec.i_10_white_fem);
	    hr_utility.trace('l_estab_rec.j_10_black_fem : ' || l_estab_rec.j_10_black_fem);
	    hr_utility.trace('l_estab_rec.k_10_latin_fem : ' || l_estab_rec.k_10_latin_fem);
	    hr_utility.trace('l_estab_rec.l_10_aspac_fem : ' || l_estab_rec.l_10_aspac_fem);
	    hr_utility.trace('l_estab_rec.m_10_ameri_fem : ' || l_estab_rec.m_10_ameri_fem);
	    hr_utility.trace('l_estab_rec.n_10_tmraces_female : ' || l_estab_rec.n_10_tmraces_female);

	    -- IF Hawaii
         /*   IF l_estab_rec.state_8 = 'HI' THEN
               l_estab_rec.i_10_white_fem := (l_estab_rec.b_10_hl_female +
	                                                        l_estab_rec.i_10_white_fem +
                                                                l_estab_rec.j_10_black_fem +
                                                                l_estab_rec.k_10_latin_fem +
                                                                l_estab_rec.l_10_aspac_fem +
                                                                l_estab_rec.m_10_ameri_fem +
					                        l_estab_rec.n_10_tmraces_female);
               l_estab_rec.b_10_hl_female := 0;
               l_estab_rec.j_10_black_fem :=  0;
               l_estab_rec.k_10_latin_fem := 0;
               l_estab_rec.l_10_aspac_fem := 0;
               l_estab_rec.m_10_ameri_fem :=  0;
	       l_estab_rec.n_10_tmraces_female  :=  0;

	    END IF; */
            --
            l_consol_rec.b_10_hl_female := nvl(l_consol_rec.b_10_hl_female,0) +
                                          nvl(l_estab_rec.b_10_hl_female,0);
            l_consol_rec.i_10_white_fem := nvl(l_consol_rec.i_10_white_fem,0) +
                                          nvl(l_estab_rec.i_10_white_fem,0);
            l_consol_rec.j_10_black_fem := nvl(l_consol_rec.j_10_black_fem,0) +
                                          nvl(l_estab_rec.j_10_black_fem,0);
            l_consol_rec.k_10_latin_fem := nvl(l_consol_rec.k_10_latin_fem,0) +
                                          nvl(l_estab_rec.k_10_latin_fem,0);
            l_consol_rec.l_10_aspac_fem := nvl(l_consol_rec.l_10_aspac_fem,0) +
                                          nvl(l_estab_rec.l_10_aspac_fem,0);
            l_consol_rec.m_10_ameri_fem := nvl(l_consol_rec.m_10_ameri_fem,0) +
                                          nvl(l_estab_rec.m_10_ameri_fem,0);
            l_consol_rec.n_10_tmraces_female := nvl(l_consol_rec.n_10_tmraces_female,0) +
                                          nvl(l_estab_rec.n_10_tmraces_female,0);
           END IF;

        END LOOP;

      CLOSE c_female_details;

      hr_utility.set_location(l_proc,30);
      OPEN c_male_details;
      LOOP
      FETCH c_male_details INTO l_c_male_details;
      EXIT WHEN c_male_details%NOTFOUND;

          IF l_c_male_details.lookup_code = '10' THEN
            --
            -- count Executive/Senior Level Officials and Managers
            --
            l_estab_rec.a_1_hl_male := l_c_male_details.c_hlmale;
            l_estab_rec.c_1_white_male :=  l_c_male_details.c_wmale;
            l_estab_rec.d_1_black_male :=  l_c_male_details.c_bmale;
            l_estab_rec.e_1_latin_male := l_c_male_details.c_hmale;
            l_estab_rec.f_1_aspac_male := l_c_male_details.c_amale;
            l_estab_rec.g_1_ameri_male :=  l_c_male_details.c_imale;
	    l_estab_rec.h_1_tmraces_male  :=  l_c_male_details.c_tmracesmale;

	    l_estab_rec.o_1_total_cat := l_estab_rec.o_1_total_cat +
	                                                l_estab_rec.a_1_hl_male +
	                                                l_estab_rec.c_1_white_male +
	                                                l_estab_rec.d_1_black_male +
							l_estab_rec.e_1_latin_male +
							 l_estab_rec.f_1_aspac_male +
							 l_estab_rec.g_1_ameri_male +
							 l_estab_rec.h_1_tmraces_male;

	    hr_utility.trace('l_estab_rec.a_1_hl_male : ' || l_estab_rec.a_1_hl_male);
	    hr_utility.trace('l_estab_rec.c_1_white_male : ' || l_estab_rec.c_1_white_male);
	    hr_utility.trace('l_estab_rec.d_1_black_male : ' || l_estab_rec.d_1_black_male);
	    hr_utility.trace('l_estab_rec.e_1_latin_male : ' || l_estab_rec.e_1_latin_male);
	    hr_utility.trace('l_estab_rec.f_1_aspac_male : ' || l_estab_rec.f_1_aspac_male);
	    hr_utility.trace('l_estab_rec.g_1_ameri_male : ' || l_estab_rec.g_1_ameri_male);
	    hr_utility.trace('l_estab_rec.h_1_tmraces_male : ' || l_estab_rec.h_1_tmraces_male);
	    hr_utility.trace('l_estab_rec.o_1_total_cat : ' || l_estab_rec.o_1_total_cat);

	    -- IF Hawaii
         /*   IF l_estab_rec.state_8 = 'HI' THEN
               l_estab_rec.c_1_white_male := (l_estab_rec.a_1_hl_male +
	                                                        l_estab_rec.c_1_white_male +
                                                                l_estab_rec.d_1_black_male +
                                                                l_estab_rec.e_1_latin_male +
                                                                l_estab_rec.f_1_aspac_male +
                                                                l_estab_rec.g_1_ameri_male +
					                        l_estab_rec.h_1_tmraces_male);
               l_estab_rec.a_1_hl_male := 0;
               l_estab_rec.d_1_black_male :=  0;
               l_estab_rec.e_1_latin_male := 0;
               l_estab_rec.f_1_aspac_male := 0;
               l_estab_rec.g_1_ameri_male :=  0;
	       l_estab_rec.h_1_tmraces_male  :=  0;

            END IF;   */

	    l_consol_rec.a_1_hl_male := nvl(l_consol_rec.a_1_hl_male,0) +
                                          nvl(l_estab_rec.a_1_hl_male,0);
            l_consol_rec.c_1_white_male := nvl(l_consol_rec.c_1_white_male,0) +
                                          nvl(l_estab_rec.c_1_white_male,0);
            l_consol_rec.d_1_black_male := nvl(l_consol_rec.d_1_black_male,0) +
                                          nvl(l_estab_rec.d_1_black_male,0);
            l_consol_rec.e_1_latin_male := nvl(l_consol_rec.e_1_latin_male,0) +
                                          nvl(l_estab_rec.e_1_latin_male,0);
            l_consol_rec.f_1_aspac_male := nvl(l_consol_rec.f_1_aspac_male,0) +
                                          nvl(l_estab_rec.f_1_aspac_male,0);
            l_consol_rec.g_1_ameri_male := nvl(l_consol_rec.g_1_ameri_male,0) +
                                          nvl(l_estab_rec.g_1_ameri_male,0);
            l_consol_rec.h_1_tmraces_male := nvl(l_consol_rec.h_1_tmraces_male,0) +
                                          nvl(l_estab_rec.h_1_tmraces_male,0);

	    ELSIF l_c_male_details.lookup_code = '1' THEN
            --
            -- count First/Mid Level Officials and Managers
            --
            l_estab_rec.a_2_hl_male := l_c_male_details.c_hlmale;
            l_estab_rec.c_2_white_male :=  l_c_male_details.c_wmale;
            l_estab_rec.d_2_black_male :=  l_c_male_details.c_bmale;
            l_estab_rec.e_2_latin_male := l_c_male_details.c_hmale;
            l_estab_rec.f_2_aspac_male := l_c_male_details.c_amale;
            l_estab_rec.g_2_ameri_male :=  l_c_male_details.c_imale;
	    l_estab_rec.h_2_tmraces_male  :=  l_c_male_details.c_tmracesmale;

	    l_estab_rec.o_2_total_cat := l_estab_rec.o_2_total_cat +
	                                                l_estab_rec.a_2_hl_male +
	                                                l_estab_rec.c_2_white_male +
	                                                l_estab_rec.d_2_black_male +
							l_estab_rec.e_2_latin_male +
							 l_estab_rec.f_2_aspac_male +
							 l_estab_rec.g_2_ameri_male +
							 l_estab_rec.h_2_tmraces_male;

	    hr_utility.trace('l_estab_rec.a_2_hl_male : ' || l_estab_rec.a_2_hl_male);
	    hr_utility.trace('l_estab_rec.c_2_white_male : ' || l_estab_rec.c_2_white_male);
	    hr_utility.trace('l_estab_rec.d_2_black_male : ' || l_estab_rec.d_2_black_male);
	    hr_utility.trace('l_estab_rec.e_2_latin_male : ' || l_estab_rec.e_2_latin_male);
	    hr_utility.trace('l_estab_rec.f_2_aspac_male : ' || l_estab_rec.f_2_aspac_male);
	    hr_utility.trace('l_estab_rec.g_2_ameri_male : ' || l_estab_rec.g_2_ameri_male);
	    hr_utility.trace('l_estab_rec.h_2_tmraces_male : ' || l_estab_rec.h_2_tmraces_male);
	    hr_utility.trace('l_estab_rec.o_2_total_cat : ' || l_estab_rec.o_2_total_cat);

	    -- IF Hawaii
           /* IF l_estab_rec.state_8 = 'HI' THEN
             l_estab_rec.c_2_white_male := (l_estab_rec.a_2_hl_male +
	                                                        l_estab_rec.c_2_white_male +
                                                                l_estab_rec.d_2_black_male +
                                                                l_estab_rec.e_2_latin_male +
                                                                l_estab_rec.f_2_aspac_male +
                                                                l_estab_rec.g_2_ameri_male +
					                        l_estab_rec.h_2_tmraces_male);
               l_estab_rec.a_2_hl_male := 0;
               l_estab_rec.d_2_black_male :=  0;
               l_estab_rec.e_2_latin_male := 0;
               l_estab_rec.f_2_aspac_male := 0;
               l_estab_rec.g_2_ameri_male :=  0;
	       l_estab_rec.h_2_tmraces_male  :=  0;

            END IF;     */

	    l_consol_rec.a_2_hl_male := nvl(l_consol_rec.a_2_hl_male,0) +
                                          nvl(l_estab_rec.a_2_hl_male,0);
            l_consol_rec.c_2_white_male := nvl(l_consol_rec.c_2_white_male,0) +
                                          nvl(l_estab_rec.c_2_white_male,0);
            l_consol_rec.d_2_black_male := nvl(l_consol_rec.d_2_black_male,0) +
                                          nvl(l_estab_rec.d_2_black_male,0);
            l_consol_rec.e_2_latin_male := nvl(l_consol_rec.e_2_latin_male,0) +
                                          nvl(l_estab_rec.e_2_latin_male,0);
            l_consol_rec.f_2_aspac_male := nvl(l_consol_rec.f_2_aspac_male,0) +
                                          nvl(l_estab_rec.f_2_aspac_male,0);
            l_consol_rec.g_2_ameri_male := nvl(l_consol_rec.g_2_ameri_male,0) +
                                          nvl(l_estab_rec.g_2_ameri_male,0);
            l_consol_rec.h_2_tmraces_male := nvl(l_consol_rec.h_2_tmraces_male,0) +
                                          nvl(l_estab_rec.h_2_tmraces_male,0);

	    ELSIF l_c_male_details.lookup_code = '2' THEN
            --
            -- count Professionals
            --
            l_estab_rec.a_3_hl_male := l_c_male_details.c_hlmale;
            l_estab_rec.c_3_white_male :=  l_c_male_details.c_wmale;
            l_estab_rec.d_3_black_male :=  l_c_male_details.c_bmale;
            l_estab_rec.e_3_latin_male := l_c_male_details.c_hmale;
            l_estab_rec.f_3_aspac_male := l_c_male_details.c_amale;
            l_estab_rec.g_3_ameri_male :=  l_c_male_details.c_imale;
	    l_estab_rec.h_3_tmraces_male  :=  l_c_male_details.c_tmracesmale;

	     l_estab_rec.o_3_total_cat := l_estab_rec.o_3_total_cat +
	                                                l_estab_rec.a_3_hl_male +
	                                                l_estab_rec.c_3_white_male +
	                                                l_estab_rec.d_3_black_male +
							l_estab_rec.e_3_latin_male +
							 l_estab_rec.f_3_aspac_male +
							 l_estab_rec.g_3_ameri_male +
							 l_estab_rec.h_3_tmraces_male;

	    hr_utility.trace('l_estab_rec.a_3_hl_male : ' || l_estab_rec.a_3_hl_male);
	    hr_utility.trace('l_estab_rec.c_3_white_male : ' || l_estab_rec.c_3_white_male);
	    hr_utility.trace('l_estab_rec.d_3_black_male : ' || l_estab_rec.d_3_black_male);
	    hr_utility.trace('l_estab_rec.e_3_latin_male : ' || l_estab_rec.e_3_latin_male);
	    hr_utility.trace('l_estab_rec.f_3_aspac_male : ' || l_estab_rec.f_3_aspac_male);
	    hr_utility.trace('l_estab_rec.g_3_ameri_male : ' || l_estab_rec.g_3_ameri_male);
	    hr_utility.trace('l_estab_rec.h_3_tmraces_male : ' || l_estab_rec.h_3_tmraces_male);
	    hr_utility.trace('l_estab_rec.o_3_total_cat : ' || l_estab_rec.o_3_total_cat);

	    -- IF Hawaii
          /*  IF l_estab_rec.state_8 = 'HI' THEN
               l_estab_rec.c_3_white_male := (l_estab_rec.a_3_hl_male +
	                                                        l_estab_rec.c_3_white_male +
                                                                l_estab_rec.d_3_black_male +
                                                                l_estab_rec.e_3_latin_male +
                                                                l_estab_rec.f_3_aspac_male +
                                                                l_estab_rec.g_3_ameri_male +
					                        l_estab_rec.h_3_tmraces_male);
               l_estab_rec.a_3_hl_male := 0;
               l_estab_rec.d_3_black_male :=  0;
               l_estab_rec.e_3_latin_male := 0;
               l_estab_rec.f_3_aspac_male := 0;
               l_estab_rec.g_3_ameri_male :=  0;
	       l_estab_rec.h_3_tmraces_male  :=  0;

	    END IF;          */

	    l_consol_rec.a_3_hl_male := nvl(l_consol_rec.a_3_hl_male,0) +
                                          nvl(l_estab_rec.a_3_hl_male,0);
            l_consol_rec.c_3_white_male := nvl(l_consol_rec.c_3_white_male,0) +
                                          nvl(l_estab_rec.c_3_white_male,0);
            l_consol_rec.d_3_black_male := nvl(l_consol_rec.d_3_black_male,0) +
                                          nvl(l_estab_rec.d_3_black_male,0);
            l_consol_rec.e_3_latin_male := nvl(l_consol_rec.e_3_latin_male,0) +
                                          nvl(l_estab_rec.e_3_latin_male,0);
            l_consol_rec.f_3_aspac_male := nvl(l_consol_rec.f_3_aspac_male,0) +
                                          nvl(l_estab_rec.f_3_aspac_male,0);
            l_consol_rec.g_3_ameri_male := nvl(l_consol_rec.g_3_ameri_male,0) +
                                          nvl(l_estab_rec.g_3_ameri_male,0);
            l_consol_rec.h_3_tmraces_male := nvl(l_consol_rec.h_3_tmraces_male,0) +
                                          nvl(l_estab_rec.h_3_tmraces_male,0);

            ELSIF l_c_male_details.lookup_code = '3' THEN
            --
            -- count Technicians
            --
            l_estab_rec.a_4_hl_male := l_c_male_details.c_hlmale;
            l_estab_rec.c_4_white_male :=  l_c_male_details.c_wmale;
            l_estab_rec.d_4_black_male :=  l_c_male_details.c_bmale;
            l_estab_rec.e_4_latin_male := l_c_male_details.c_hmale;
            l_estab_rec.f_4_aspac_male := l_c_male_details.c_amale;
            l_estab_rec.g_4_ameri_male :=  l_c_male_details.c_imale;
	    l_estab_rec.h_4_tmraces_male  :=  l_c_male_details.c_tmracesmale;

	     l_estab_rec.o_4_total_cat := l_estab_rec.o_4_total_cat +
	                                                l_estab_rec.a_4_hl_male +
	                                                l_estab_rec.c_4_white_male +
	                                                l_estab_rec.d_4_black_male +
							l_estab_rec.e_4_latin_male +
							 l_estab_rec.f_4_aspac_male +
							 l_estab_rec.g_4_ameri_male +
							 l_estab_rec.h_4_tmraces_male;

	    hr_utility.trace('l_estab_rec.a_4_hl_male : ' || l_estab_rec.a_4_hl_male);
	    hr_utility.trace('l_estab_rec.c_4_white_male : ' || l_estab_rec.c_4_white_male);
	    hr_utility.trace('l_estab_rec.d_4_black_male : ' || l_estab_rec.d_4_black_male);
	    hr_utility.trace('l_estab_rec.e_4_latin_male : ' || l_estab_rec.e_4_latin_male);
	    hr_utility.trace('l_estab_rec.f_4_aspac_male : ' || l_estab_rec.f_4_aspac_male);
	    hr_utility.trace('l_estab_rec.g_4_ameri_male : ' || l_estab_rec.g_4_ameri_male);
	    hr_utility.trace('l_estab_rec.h_4_tmraces_male : ' || l_estab_rec.h_4_tmraces_male);
	    hr_utility.trace('l_estab_rec.o_4_total_cat : ' || l_estab_rec.o_4_total_cat);

	    -- IF Hawaii
        /*    IF l_estab_rec.state_8 = 'HI' THEN
               l_estab_rec.c_4_white_male := (l_estab_rec.a_4_hl_male +
	                                                        l_estab_rec.c_4_white_male +
                                                                l_estab_rec.d_4_black_male +
                                                                l_estab_rec.e_4_latin_male +
                                                                l_estab_rec.f_4_aspac_male +
                                                                l_estab_rec.g_4_ameri_male +
					                        l_estab_rec.h_4_tmraces_male);
               l_estab_rec.a_4_hl_male := 0;
               l_estab_rec.d_4_black_male :=  0;
               l_estab_rec.e_4_latin_male := 0;
               l_estab_rec.f_4_aspac_male := 0;
               l_estab_rec.g_4_ameri_male :=  0;
	       l_estab_rec.h_4_tmraces_male  :=  0;

            END IF;     */

	    l_consol_rec.a_4_hl_male := nvl(l_consol_rec.a_4_hl_male,0) +
                                          nvl(l_estab_rec.a_4_hl_male,0);
            l_consol_rec.c_4_white_male := nvl(l_consol_rec.c_4_white_male,0) +
                                          nvl(l_estab_rec.c_4_white_male,0);
            l_consol_rec.d_4_black_male := nvl(l_consol_rec.d_4_black_male,0) +
                                          nvl(l_estab_rec.d_4_black_male,0);
            l_consol_rec.e_4_latin_male := nvl(l_consol_rec.e_4_latin_male,0) +
                                          nvl(l_estab_rec.e_4_latin_male,0);
            l_consol_rec.f_4_aspac_male := nvl(l_consol_rec.f_4_aspac_male,0) +
                                          nvl(l_estab_rec.f_4_aspac_male,0);
            l_consol_rec.g_4_ameri_male := nvl(l_consol_rec.g_4_ameri_male,0) +
                                          nvl(l_estab_rec.g_4_ameri_male,0);
            l_consol_rec.h_4_tmraces_male := nvl(l_consol_rec.h_4_tmraces_male,0) +
                                          nvl(l_estab_rec.h_4_tmraces_male,0);

          ELSIF l_c_male_details.lookup_code = '4' THEN
            --
            -- count Sales Workers
            --
           l_estab_rec.a_5_hl_male := l_c_male_details.c_hlmale;
            l_estab_rec.c_5_white_male :=  l_c_male_details.c_wmale;
            l_estab_rec.d_5_black_male :=  l_c_male_details.c_bmale;
            l_estab_rec.e_5_latin_male := l_c_male_details.c_hmale;
            l_estab_rec.f_5_aspac_male := l_c_male_details.c_amale;
            l_estab_rec.g_5_ameri_male :=  l_c_male_details.c_imale;
	    l_estab_rec.h_5_tmraces_male  :=  l_c_male_details.c_tmracesmale;

	     l_estab_rec.o_5_total_cat := l_estab_rec.o_5_total_cat +
	                                                l_estab_rec.a_5_hl_male +
	                                                l_estab_rec.c_5_white_male +
	                                                l_estab_rec.d_5_black_male +
							l_estab_rec.e_5_latin_male +
							 l_estab_rec.f_5_aspac_male +
							 l_estab_rec.g_5_ameri_male +
							 l_estab_rec.h_5_tmraces_male;

	    hr_utility.trace('l_estab_rec.a_5_hl_male : ' || l_estab_rec.a_5_hl_male);
	    hr_utility.trace('l_estab_rec.c_5_white_male : ' || l_estab_rec.c_5_white_male);
	    hr_utility.trace('l_estab_rec.d_5_black_male : ' || l_estab_rec.d_5_black_male);
	    hr_utility.trace('l_estab_rec.e_5_latin_male : ' || l_estab_rec.e_5_latin_male);
	    hr_utility.trace('l_estab_rec.f_5_aspac_male : ' || l_estab_rec.f_5_aspac_male);
	    hr_utility.trace('l_estab_rec.g_5_ameri_male : ' || l_estab_rec.g_5_ameri_male);
	    hr_utility.trace('l_estab_rec.h_5_tmraces_male : ' || l_estab_rec.h_5_tmraces_male);
	    hr_utility.trace('l_estab_rec.o_5_total_cat : ' || l_estab_rec.o_5_total_cat);

	    -- IF Hawaii
        /*    IF l_estab_rec.state_8 = 'HI' THEN
               l_estab_rec.c_5_white_male := (l_estab_rec.a_5_hl_male +
	                                                        l_estab_rec.c_5_white_male +
                                                                l_estab_rec.d_5_black_male +
                                                                l_estab_rec.e_5_latin_male +
                                                                l_estab_rec.f_5_aspac_male +
                                                                l_estab_rec.g_5_ameri_male +
					                        l_estab_rec.h_5_tmraces_male);
               l_estab_rec.a_5_hl_male := 0;
               l_estab_rec.d_5_black_male :=  0;
               l_estab_rec.e_5_latin_male := 0;
               l_estab_rec.f_5_aspac_male := 0;
               l_estab_rec.g_5_ameri_male :=  0;
	       l_estab_rec.h_5_tmraces_male  :=  0;

	   END IF;  */

	    l_consol_rec.a_5_hl_male := nvl(l_consol_rec.a_5_hl_male,0) +
                                          nvl(l_estab_rec.a_5_hl_male,0);
            l_consol_rec.c_5_white_male := nvl(l_consol_rec.c_5_white_male,0) +
                                          nvl(l_estab_rec.c_5_white_male,0);
            l_consol_rec.d_5_black_male := nvl(l_consol_rec.d_5_black_male,0) +
                                          nvl(l_estab_rec.d_5_black_male,0);
            l_consol_rec.e_5_latin_male := nvl(l_consol_rec.e_5_latin_male,0) +
                                          nvl(l_estab_rec.e_5_latin_male,0);
            l_consol_rec.f_5_aspac_male := nvl(l_consol_rec.f_5_aspac_male,0) +
                                          nvl(l_estab_rec.f_5_aspac_male,0);
            l_consol_rec.g_5_ameri_male := nvl(l_consol_rec.g_5_ameri_male,0) +
                                          nvl(l_estab_rec.g_5_ameri_male,0);
            l_consol_rec.h_5_tmraces_male := nvl(l_consol_rec.h_5_tmraces_male,0) +
                                          nvl(l_estab_rec.h_5_tmraces_male,0);

	  ELSIF l_c_male_details.lookup_code = '5' THEN
            --
            -- count Administrative Support Workers
            --
           l_estab_rec.a_6_hl_male := l_c_male_details.c_hlmale;
            l_estab_rec.c_6_white_male :=  l_c_male_details.c_wmale;
            l_estab_rec.d_6_black_male :=  l_c_male_details.c_bmale;
            l_estab_rec.e_6_latin_male := l_c_male_details.c_hmale;
            l_estab_rec.f_6_aspac_male := l_c_male_details.c_amale;
            l_estab_rec.g_6_ameri_male :=  l_c_male_details.c_imale;
	    l_estab_rec.h_6_tmraces_male  :=  l_c_male_details.c_tmracesmale;

	     l_estab_rec.o_6_total_cat := l_estab_rec.o_6_total_cat +
	                                                l_estab_rec.a_6_hl_male +
	                                                l_estab_rec.c_6_white_male +
	                                                l_estab_rec.d_6_black_male +
							l_estab_rec.e_6_latin_male +
							 l_estab_rec.f_6_aspac_male +
							 l_estab_rec.g_6_ameri_male +
							 l_estab_rec.h_6_tmraces_male;

	    hr_utility.trace('l_estab_rec.a_6_hl_male : ' || l_estab_rec.a_6_hl_male);
	    hr_utility.trace('l_estab_rec.c_6_white_male : ' || l_estab_rec.c_6_white_male);
	    hr_utility.trace('l_estab_rec.d_6_black_male : ' || l_estab_rec.d_6_black_male);
	    hr_utility.trace('l_estab_rec.e_6_latin_male : ' || l_estab_rec.e_6_latin_male);
	    hr_utility.trace('l_estab_rec.f_6_aspac_male : ' || l_estab_rec.f_6_aspac_male);
	    hr_utility.trace('l_estab_rec.g_6_ameri_male : ' || l_estab_rec.g_6_ameri_male);
	    hr_utility.trace('l_estab_rec.h_6_tmraces_male : ' || l_estab_rec.h_6_tmraces_male);
	    hr_utility.trace('l_estab_rec.o_6_total_cat : ' || l_estab_rec.o_6_total_cat);

	    -- IF Hawaii
          /*  IF l_estab_rec.state_8 = 'HI' THEN
               l_estab_rec.c_6_white_male := (l_estab_rec.a_6_hl_male +
	                                                        l_estab_rec.c_6_white_male +
                                                                l_estab_rec.d_6_black_male +
                                                                l_estab_rec.e_6_latin_male +
                                                                l_estab_rec.f_6_aspac_male +
                                                                l_estab_rec.g_6_ameri_male +
					                        l_estab_rec.h_6_tmraces_male);
               l_estab_rec.a_6_hl_male := 0;
               l_estab_rec.d_6_black_male :=  0;
               l_estab_rec.e_6_latin_male := 0;
               l_estab_rec.f_6_aspac_male := 0;
               l_estab_rec.g_6_ameri_male :=  0;
	       l_estab_rec.h_6_tmraces_male  :=  0;

	    END IF;    */

	    l_consol_rec.a_6_hl_male := nvl(l_consol_rec.a_6_hl_male,0) +
                                          nvl(l_estab_rec.a_6_hl_male,0);
            l_consol_rec.c_6_white_male := nvl(l_consol_rec.c_6_white_male,0) +
                                          nvl(l_estab_rec.c_6_white_male,0);
            l_consol_rec.d_6_black_male := nvl(l_consol_rec.d_6_black_male,0) +
                                          nvl(l_estab_rec.d_6_black_male,0);
            l_consol_rec.e_6_latin_male := nvl(l_consol_rec.e_6_latin_male,0) +
                                          nvl(l_estab_rec.e_6_latin_male,0);
            l_consol_rec.f_6_aspac_male := nvl(l_consol_rec.f_6_aspac_male,0) +
                                          nvl(l_estab_rec.f_6_aspac_male,0);
            l_consol_rec.g_6_ameri_male := nvl(l_consol_rec.g_6_ameri_male,0) +
                                          nvl(l_estab_rec.g_6_ameri_male,0);
            l_consol_rec.h_6_tmraces_male := nvl(l_consol_rec.h_6_tmraces_male,0) +
                                          nvl(l_estab_rec.h_6_tmraces_male,0);

          ELSIF l_c_male_details.lookup_code = '6' THEN
            --
            -- count Craft Workers
            --
           l_estab_rec.a_7_hl_male := l_c_male_details.c_hlmale;
            l_estab_rec.c_7_white_male :=  l_c_male_details.c_wmale;
            l_estab_rec.d_7_black_male :=  l_c_male_details.c_bmale;
            l_estab_rec.e_7_latin_male := l_c_male_details.c_hmale;
            l_estab_rec.f_7_aspac_male := l_c_male_details.c_amale;
            l_estab_rec.g_7_ameri_male :=  l_c_male_details.c_imale;
	    l_estab_rec.h_7_tmraces_male  :=  l_c_male_details.c_tmracesmale;

	     l_estab_rec.o_7_total_cat := l_estab_rec.o_7_total_cat +
	                                                l_estab_rec.a_7_hl_male +
	                                                l_estab_rec.c_7_white_male +
	                                                l_estab_rec.d_7_black_male +
							l_estab_rec.e_7_latin_male +
							 l_estab_rec.f_7_aspac_male +
							 l_estab_rec.g_7_ameri_male +
							 l_estab_rec.h_7_tmraces_male;

	    hr_utility.trace('l_estab_rec.a_7_hl_male : ' || l_estab_rec.a_7_hl_male);
	    hr_utility.trace('l_estab_rec.c_7_white_male : ' || l_estab_rec.c_7_white_male);
	    hr_utility.trace('l_estab_rec.d_7_black_male : ' || l_estab_rec.d_7_black_male);
	    hr_utility.trace('l_estab_rec.e_7_latin_male : ' || l_estab_rec.e_7_latin_male);
	    hr_utility.trace('l_estab_rec.f_7_aspac_male : ' || l_estab_rec.f_7_aspac_male);
	    hr_utility.trace('l_estab_rec.g_7_ameri_male : ' || l_estab_rec.g_7_ameri_male);
	    hr_utility.trace('l_estab_rec.h_7_tmraces_male : ' || l_estab_rec.h_7_tmraces_male);
	    hr_utility.trace('l_estab_rec.o_7_total_cat : ' || l_estab_rec.o_7_total_cat);

	    -- IF Hawaii
         /*   IF l_estab_rec.state_8 = 'HI' THEN
              l_estab_rec.c_7_white_male := (l_estab_rec.a_7_hl_male +
	                                                        l_estab_rec.c_7_white_male +
                                                                l_estab_rec.d_7_black_male +
                                                                l_estab_rec.e_7_latin_male +
                                                                l_estab_rec.f_7_aspac_male +
                                                                l_estab_rec.g_7_ameri_male +
					                        l_estab_rec.h_7_tmraces_male);
               l_estab_rec.a_7_hl_male := 0;
               l_estab_rec.d_7_black_male :=  0;
               l_estab_rec.e_7_latin_male := 0;
               l_estab_rec.f_7_aspac_male := 0;
               l_estab_rec.g_7_ameri_male :=  0;
	       l_estab_rec.h_7_tmraces_male  :=  0;

	   END IF;   */

	    l_consol_rec.a_7_hl_male := nvl(l_consol_rec.a_7_hl_male,0) +
                                          nvl(l_estab_rec.a_7_hl_male,0);
            l_consol_rec.c_7_white_male := nvl(l_consol_rec.c_7_white_male,0) +
                                          nvl(l_estab_rec.c_7_white_male,0);
            l_consol_rec.d_7_black_male := nvl(l_consol_rec.d_7_black_male,0) +
                                          nvl(l_estab_rec.d_7_black_male,0);
            l_consol_rec.e_7_latin_male := nvl(l_consol_rec.e_7_latin_male,0) +
                                          nvl(l_estab_rec.e_7_latin_male,0);
            l_consol_rec.f_7_aspac_male := nvl(l_consol_rec.f_7_aspac_male,0) +
                                          nvl(l_estab_rec.f_7_aspac_male,0);
            l_consol_rec.g_7_ameri_male := nvl(l_consol_rec.g_7_ameri_male,0) +
                                          nvl(l_estab_rec.g_7_ameri_male,0);
            l_consol_rec.h_7_tmraces_male := nvl(l_consol_rec.h_7_tmraces_male,0) +
                                          nvl(l_estab_rec.h_7_tmraces_male,0);
           --
          ELSIF l_c_male_details.lookup_code = '7' THEN
            --
            -- count Operatives
            --
            l_estab_rec.a_8_hl_male := l_c_male_details.c_hlmale;
            l_estab_rec.c_8_white_male :=  l_c_male_details.c_wmale;
            l_estab_rec.d_8_black_male :=  l_c_male_details.c_bmale;
            l_estab_rec.e_8_latin_male := l_c_male_details.c_hmale;
            l_estab_rec.f_8_aspac_male := l_c_male_details.c_amale;
            l_estab_rec.g_8_ameri_male :=  l_c_male_details.c_imale;
	    l_estab_rec.h_8_tmraces_male  :=  l_c_male_details.c_tmracesmale;

	    l_estab_rec.o_8_total_cat := l_estab_rec.o_8_total_cat +
	                                                l_estab_rec.a_8_hl_male +
	                                                l_estab_rec.c_8_white_male +
	                                                l_estab_rec.d_8_black_male +
							l_estab_rec.e_8_latin_male +
							 l_estab_rec.f_8_aspac_male +
							 l_estab_rec.g_8_ameri_male +
							 l_estab_rec.h_8_tmraces_male;

	    hr_utility.trace('l_estab_rec.a_8_hl_male : ' || l_estab_rec.a_8_hl_male);
	    hr_utility.trace('l_estab_rec.c_8_white_male : ' || l_estab_rec.c_8_white_male);
	    hr_utility.trace('l_estab_rec.d_8_black_male : ' || l_estab_rec.d_8_black_male);
	    hr_utility.trace('l_estab_rec.e_8_latin_male : ' || l_estab_rec.e_8_latin_male);
	    hr_utility.trace('l_estab_rec.f_8_aspac_male : ' || l_estab_rec.f_8_aspac_male);
	    hr_utility.trace('l_estab_rec.g_8_ameri_male : ' || l_estab_rec.g_8_ameri_male);
	    hr_utility.trace('l_estab_rec.h_8_tmraces_male : ' || l_estab_rec.h_8_tmraces_male);
	    hr_utility.trace('l_estab_rec.o_8_total_cat : ' || l_estab_rec.o_8_total_cat);

	    -- IF Hawaii
          /*  IF l_estab_rec.state_8 = 'HI' THEN
               l_estab_rec.c_8_white_male := (l_estab_rec.a_8_hl_male +
	                                                        l_estab_rec.c_8_white_male +
                                                                l_estab_rec.d_8_black_male +
                                                                l_estab_rec.e_8_latin_male +
                                                                l_estab_rec.f_8_aspac_male +
                                                                l_estab_rec.g_8_ameri_male +
					                        l_estab_rec.h_8_tmraces_male);
               l_estab_rec.a_8_hl_male := 0;
               l_estab_rec.d_8_black_male :=  0;
               l_estab_rec.e_8_latin_male := 0;
               l_estab_rec.f_8_aspac_male := 0;
               l_estab_rec.g_8_ameri_male :=  0;
	       l_estab_rec.h_8_tmraces_male  :=  0;
	    END IF;   */

	    l_consol_rec.a_8_hl_male := nvl(l_consol_rec.a_8_hl_male,0) +
                                          nvl(l_estab_rec.a_8_hl_male,0);
            l_consol_rec.c_8_white_male := nvl(l_consol_rec.c_8_white_male,0) +
                                          nvl(l_estab_rec.c_8_white_male,0);
            l_consol_rec.d_8_black_male := nvl(l_consol_rec.d_8_black_male,0) +
                                          nvl(l_estab_rec.d_8_black_male,0);
            l_consol_rec.e_8_latin_male := nvl(l_consol_rec.e_8_latin_male,0) +
                                          nvl(l_estab_rec.e_8_latin_male,0);
            l_consol_rec.f_8_aspac_male := nvl(l_consol_rec.f_8_aspac_male,0) +
                                          nvl(l_estab_rec.f_8_aspac_male,0);
            l_consol_rec.g_8_ameri_male := nvl(l_consol_rec.g_8_ameri_male,0) +
                                          nvl(l_estab_rec.g_8_ameri_male,0);
            l_consol_rec.h_8_tmraces_male := nvl(l_consol_rec.h_8_tmraces_male,0) +
                                          nvl(l_estab_rec.h_8_tmraces_male,0);

          ELSIF l_c_male_details.lookup_code = '8' THEN
            --
            -- count Laborers and Helpers
            --
           l_estab_rec.a_9_hl_male := l_c_male_details.c_hlmale;
            l_estab_rec.c_9_white_male :=  l_c_male_details.c_wmale;
            l_estab_rec.d_9_black_male :=  l_c_male_details.c_bmale;
            l_estab_rec.e_9_latin_male := l_c_male_details.c_hmale;
            l_estab_rec.f_9_aspac_male := l_c_male_details.c_amale;
            l_estab_rec.g_9_ameri_male :=  l_c_male_details.c_imale;
	    l_estab_rec.h_9_tmraces_male  :=  l_c_male_details.c_tmracesmale;

	     l_estab_rec.o_9_total_cat := l_estab_rec.o_9_total_cat +
	                                                l_estab_rec.a_9_hl_male +
	                                                l_estab_rec.c_9_white_male +
	                                                l_estab_rec.d_9_black_male +
							l_estab_rec.e_9_latin_male +
							 l_estab_rec.f_9_aspac_male +
							 l_estab_rec.g_9_ameri_male +
							 l_estab_rec.h_9_tmraces_male;

	    hr_utility.trace('l_estab_rec.a_9_hl_male : ' || l_estab_rec.a_9_hl_male);
	    hr_utility.trace('l_estab_rec.c_9_white_male : ' || l_estab_rec.c_9_white_male);
	    hr_utility.trace('l_estab_rec.d_9_black_male : ' || l_estab_rec.d_9_black_male);
	    hr_utility.trace('l_estab_rec.e_9_latin_male : ' || l_estab_rec.e_9_latin_male);
	    hr_utility.trace('l_estab_rec.f_9_aspac_male : ' || l_estab_rec.f_9_aspac_male);
	    hr_utility.trace('l_estab_rec.g_9_ameri_male : ' || l_estab_rec.g_9_ameri_male);
	    hr_utility.trace('l_estab_rec.h_9_tmraces_male : ' || l_estab_rec.h_9_tmraces_male);
	    hr_utility.trace('l_estab_rec.o_9_total_cat : ' || l_estab_rec.o_9_total_cat);

	    -- IF Hawaii
           /* IF l_estab_rec.state_8 = 'HI' THEN
               l_estab_rec.c_9_white_male := (l_estab_rec.a_9_hl_male +
	                                                        l_estab_rec.c_9_white_male +
                                                                l_estab_rec.d_9_black_male +
                                                                l_estab_rec.e_9_latin_male +
                                                                l_estab_rec.f_9_aspac_male +
                                                                l_estab_rec.g_9_ameri_male +
					                        l_estab_rec.h_9_tmraces_male);
               l_estab_rec.a_9_hl_male := 0;
               l_estab_rec.d_9_black_male :=  0;
               l_estab_rec.e_9_latin_male := 0;
               l_estab_rec.f_9_aspac_male := 0;
               l_estab_rec.g_9_ameri_male :=  0;
	       l_estab_rec.h_9_tmraces_male  :=  0;
           END IF;    */

	    l_consol_rec.a_9_hl_male := nvl(l_consol_rec.a_9_hl_male,0) +
                                          nvl(l_estab_rec.a_9_hl_male,0);
            l_consol_rec.c_9_white_male := nvl(l_consol_rec.c_9_white_male,0) +
                                          nvl(l_estab_rec.c_9_white_male,0);
            l_consol_rec.d_9_black_male := nvl(l_consol_rec.d_9_black_male,0) +
                                          nvl(l_estab_rec.d_9_black_male,0);
            l_consol_rec.e_9_latin_male := nvl(l_consol_rec.e_9_latin_male,0) +
                                          nvl(l_estab_rec.e_9_latin_male,0);
            l_consol_rec.f_9_aspac_male := nvl(l_consol_rec.f_9_aspac_male,0) +
                                          nvl(l_estab_rec.f_9_aspac_male,0);
            l_consol_rec.g_9_ameri_male := nvl(l_consol_rec.g_9_ameri_male,0) +
                                          nvl(l_estab_rec.g_9_ameri_male,0);
            l_consol_rec.h_9_tmraces_male := nvl(l_consol_rec.h_9_tmraces_male,0) +
                                          nvl(l_estab_rec.h_9_tmraces_male,0);

          ELSIF l_c_male_details.lookup_code = '9' THEN
            --
            -- count Service Workers
            --
            l_estab_rec.a_10_hl_male := l_c_male_details.c_hlmale;
            l_estab_rec.c_10_white_male :=  l_c_male_details.c_wmale;
            l_estab_rec.d_10_black_male :=  l_c_male_details.c_bmale;
            l_estab_rec.e_10_latin_male := l_c_male_details.c_hmale;
            l_estab_rec.f_10_aspac_male := l_c_male_details.c_amale;
            l_estab_rec.g_10_ameri_male :=  l_c_male_details.c_imale;
	    l_estab_rec.h_10_tmraces_male  :=  l_c_male_details.c_tmracesmale;

	    l_estab_rec.o_10_total_cat := l_estab_rec.o_10_total_cat +
	                                                l_estab_rec.a_10_hl_male +
	                                                l_estab_rec.c_10_white_male +
	                                                l_estab_rec.d_10_black_male +
							l_estab_rec.e_10_latin_male +
							 l_estab_rec.f_10_aspac_male +
							 l_estab_rec.g_10_ameri_male +
							 l_estab_rec.h_10_tmraces_male;

	    hr_utility.trace('l_estab_rec.a_10_hl_male : ' || l_estab_rec.a_10_hl_male);
	    hr_utility.trace('l_estab_rec.c_10_white_male : ' || l_estab_rec.c_10_white_male);
	    hr_utility.trace('l_estab_rec.d_10_black_male : ' || l_estab_rec.d_10_black_male);
	    hr_utility.trace('l_estab_rec.e_10_latin_male : ' || l_estab_rec.e_10_latin_male);
	    hr_utility.trace('l_estab_rec.f_10_aspac_male : ' || l_estab_rec.f_10_aspac_male);
	    hr_utility.trace('l_estab_rec.g_10_ameri_male : ' || l_estab_rec.g_10_ameri_male);
	    hr_utility.trace('l_estab_rec.h_10_tmraces_male : ' || l_estab_rec.h_10_tmraces_male);
	    hr_utility.trace('l_estab_rec.o_10_total_cat : ' || l_estab_rec.o_10_total_cat);

	    -- IF Hawaii
         /*   IF l_estab_rec.state_8 = 'HI' THEN
               l_estab_rec.c_10_white_male := (l_estab_rec.a_10_hl_male +
	                                                        l_estab_rec.c_10_white_male +
                                                                l_estab_rec.d_10_black_male +
                                                                l_estab_rec.e_10_latin_male +
                                                                l_estab_rec.f_10_aspac_male +
                                                                l_estab_rec.g_10_ameri_male +
					                        l_estab_rec.h_10_tmraces_male);
               l_estab_rec.a_10_hl_male := 0;
               l_estab_rec.d_10_black_male :=  0;
               l_estab_rec.e_10_latin_male := 0;
               l_estab_rec.f_10_aspac_male := 0;
               l_estab_rec.g_10_ameri_male :=  0;
	       l_estab_rec.h_10_tmraces_male  :=  0;
            END IF;    */

	    l_consol_rec.a_10_hl_male := nvl(l_consol_rec.a_10_hl_male,0) +
                                          nvl(l_estab_rec.a_10_hl_male,0);
            l_consol_rec.c_10_white_male := nvl(l_consol_rec.c_10_white_male,0) +
                                          nvl(l_estab_rec.c_10_white_male,0);
            l_consol_rec.d_10_black_male := nvl(l_consol_rec.d_10_black_male,0) +
                                          nvl(l_estab_rec.d_10_black_male,0);
            l_consol_rec.e_10_latin_male := nvl(l_consol_rec.e_10_latin_male,0) +
                                          nvl(l_estab_rec.e_10_latin_male,0);
            l_consol_rec.f_10_aspac_male := nvl(l_consol_rec.f_10_aspac_male,0) +
                                          nvl(l_estab_rec.f_10_aspac_male,0);
            l_consol_rec.g_10_ameri_male := nvl(l_consol_rec.g_10_ameri_male,0) +
                                          nvl(l_estab_rec.g_10_ameri_male,0);
            l_consol_rec.h_10_tmraces_male := nvl(l_consol_rec.h_10_tmraces_male,0) +
                                          nvl(l_estab_rec.h_10_tmraces_male,0);
           END IF;

        END LOOP;

     CLOSE c_male_details;
/*
      hr_utility.set_location(l_proc,40);
      OPEN c_lastyears_details;
      LOOP
      FETCH c_lastyears_details INTO l_c_lastyears_details;
      EXIT WHEN c_lastyears_details%NOTFOUND;

         l_estab_rec.a_11_last_year_grand_total := l_c_lastyears_details.p_total_a;
         l_consol_rec.a_11_last_year_grand_total
                             := nvl(l_consol_rec.a_11_last_year_grand_total,0) +
                                nvl(l_estab_rec.a_11_last_year_grand_total,0);

  g_message_text := 'l_c_lastyears_details.p_total_a -> '|| l_c_lastyears_details.p_total_a;
  fnd_file.put_line(which => fnd_file.log, buff => g_message_text);

  g_message_text := 'l_consol_rec.a_11_last_year_grand_total -> '|| l_consol_rec.a_11_last_year_grand_total;
  fnd_file.put_line(which => fnd_file.log, buff => g_message_text);

         l_estab_rec.b_11_last_year_grand_total := l_c_lastyears_details.p_wmale_b;
         l_consol_rec.b_11_last_year_grand_total
                             := nvl(l_consol_rec.b_11_last_year_grand_total,0) +
                                nvl(l_estab_rec.b_11_last_year_grand_total,0);

         l_estab_rec.c_11_last_year_grand_total := l_c_lastyears_details.p_bmale_c;
         l_consol_rec.c_11_last_year_grand_total
                             := nvl(l_consol_rec.c_11_last_year_grand_total,0) +
                                nvl(l_estab_rec.c_11_last_year_grand_total,0);

         l_estab_rec.d_11_last_year_grand_total := l_c_lastyears_details.p_hmale_d;
         l_consol_rec.d_11_last_year_grand_total
                             := nvl(l_consol_rec.d_11_last_year_grand_total,0) +
                                nvl(l_estab_rec.d_11_last_year_grand_total,0);

         l_estab_rec.e_11_last_year_grand_total := l_c_lastyears_details.p_amale_e;
         l_consol_rec.e_11_last_year_grand_total
                             := nvl(l_consol_rec.e_11_last_year_grand_total,0) +
                                nvl(l_estab_rec.e_11_last_year_grand_total,0);

         l_estab_rec.f_11_last_year_grand_total := l_c_lastyears_details.p_imale_f;
         l_consol_rec.f_11_last_year_grand_total
                             := nvl(l_consol_rec.f_11_last_year_grand_total,0) +
                                nvl(l_estab_rec.f_11_last_year_grand_total,0);

         l_estab_rec.g_11_last_year_grand_total := l_c_lastyears_details.p_wfemale_g;
         l_consol_rec.g_11_last_year_grand_total
                             := nvl(l_consol_rec.g_11_last_year_grand_total,0) +
                                nvl(l_estab_rec.g_11_last_year_grand_total,0);

         l_estab_rec.h_11_last_year_grand_total := l_c_lastyears_details.p_bfemale_h;
         l_consol_rec.h_11_last_year_grand_total
                             := nvl(l_consol_rec.h_11_last_year_grand_total,0) +
                                nvl(l_estab_rec.h_11_last_year_grand_total,0);

         l_estab_rec.i_11_last_year_grand_total := l_c_lastyears_details.p_hfemale_i;
         l_consol_rec.i_11_last_year_grand_total
                             := nvl(l_consol_rec.i_11_last_year_grand_total,0) +
                                nvl(l_estab_rec.i_11_last_year_grand_total,0);

         l_estab_rec.j_11_last_year_grand_total := l_c_lastyears_details.p_afemale_j;
         l_consol_rec.j_11_last_year_grand_total
                             := nvl(l_consol_rec.j_11_last_year_grand_total,0) +
                                nvl(l_estab_rec.j_11_last_year_grand_total,0);

         l_estab_rec.k_11_last_year_grand_total := l_c_lastyears_details.p_ifemale_k;
         l_consol_rec.k_11_last_year_grand_total
                             := nvl(l_consol_rec.k_11_last_year_grand_total,0) +
                                nvl(l_estab_rec.k_11_last_year_grand_total,0);
       END loop;

       CLOSE c_lastyears_details; */

       hr_utility.set_location(l_proc,50);

       write_establishment_record;


       IF p_report_mode = 'F'
       AND l_org_rec.l_status_code_2 IN ('1','3','4','9','8')
       -- added status 8 here, bug 3544973
       THEN

	  insert_location_eit(p_hierarchy_node_id => l_hierarchy_node_id,
                              p_hierarchy_version_id => p_hierarchy_version_id,
                              p_report_year => l_report_year);

       END IF;

    END LOOP;  -- C_estab_details

    CLOSE c_estab_details;
    --
    hr_utility.set_location(l_proc,60);

    write_consolidated_record;

    IF p_report_mode = 'F'
       AND l_org_rec.l_status_code_2 = '2' -- form type?
    THEN
      insert_org_eit(p_hierarchy_node_id => l_hierarchy_node_id,
                     p_hierarchy_version_id => p_hierarchy_version_id,
                     p_business_group_id    => p_business_group_id,
                     p_report_year => l_report_year);
    END IF;

   hr_utility.set_location('Leaving..' ||l_proc,100);

END loop_through_establishments;



PROCEDURE eeo_mag_report
  (errbuf                        OUT NOCOPY VARCHAR2,
   retcode                       OUT NOCOPY NUMBER,
   p_start_date                  IN  VARCHAR2,
   p_end_date                    IN  VARCHAR2,
   p_hierarchy_id                IN  NUMBER,
   p_hierarchy_version_id        IN  NUMBER,
   p_report_mode                 IN  VARCHAR2,
   p_business_group_id           IN  NUMBER
   ) IS

  l_proc       VARCHAR2(80) := g_package || 'eeo_mag_report';
  l_start_date DATE := fnd_date.canonical_to_date(p_start_date);
  l_end_date   DATE := fnd_date.canonical_to_date(p_end_date);
  l_string     VARCHAR2(5000);  --1074

  CURSOR  c_nodes(p_hierarchy_version_id NUMBER) IS
  SELECT  count('establishments')
    FROM  per_gen_hierarchy_nodes
   WHERE  node_type = 'EST'
     AND  hierarchy_version_id = p_hierarchy_version_id;

  l_count NUMBER;

 BEGIN
  --hr_utility.trace_on(NULL,'ORACLE');
  hr_utility.set_location('Entering..'||l_proc,10);

  g_message_text := 'EEO1 Entering...'||l_proc||'  10';
  fnd_file.put_line(which => fnd_file.log,buff => g_message_text);



  set_org_details(p_hierarchy_version_id => p_hierarchy_version_id,
                  p_business_group_id    => p_business_group_id,
                  p_start_date           => l_start_date,
                  p_end_date             => l_end_date);



  OPEN c_nodes(p_hierarchy_version_id);
  FETCH c_nodes INTO l_count;
    IF l_count = 1 THEN
       l_org_rec.form_type := 'S';
    ELSE
       l_org_rec.form_type := 'M';
    END IF;
  CLOSE c_nodes;

  g_message_text := 'EEO1 l_org_rec.form_type -> '||l_org_rec.form_type;
  fnd_file.put_line(which => fnd_file.log,buff => g_message_text);

  g_message_text := 'EEO1 p_hierarchy_version_id -> '||p_hierarchy_version_id;
  fnd_file.put_line(which => fnd_file.log,buff => g_message_text);

  g_message_text := 'EEO1 p_business_group_id -> '|| p_business_group_id;
  fnd_file.put_line(which => fnd_file.log,buff => g_message_text);

  g_message_text := 'EEO1 l_start_date -> '|| l_start_date;
  fnd_file.put_line(which => fnd_file.log,buff => g_message_text);

  g_message_text := 'EEO1 l_end_date -> '|| l_end_date;
  fnd_file.put_line(which => fnd_file.log,buff => g_message_text);

  g_message_text := 'EEO1 p_report_mode -> '|| p_report_mode;
  fnd_file.put_line(which => fnd_file.log,buff => g_message_text);


  loop_through_establishments(p_hierarchy_version_id => p_hierarchy_version_id,
                              p_business_group_id    => p_business_group_id,
                              p_start_date           => l_start_date,
                              p_end_date             => l_end_date,
                              p_report_mode          => p_report_mode);
--
END eeo_mag_report;
--
END per_eeo_mag_report;

/
