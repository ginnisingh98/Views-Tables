--------------------------------------------------------
--  DDL for Package Body PAY_MX_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_RULES" AS
/* $Header: pymxrule.pkb 120.7.12000000.4 2007/02/21 17:27:21 sdahiya noship $ */
--

    g_proc_name varchar2(100);
    g_debug     BOOLEAN;

  /****************************************************************************
    Name        : HR_UTILITY_TRACE
    Description : This procedure prints debug messages.
  *****************************************************************************/
PROCEDURE HR_UTILITY_TRACE
(
    P_TRC_DATA  varchar2
) AS
BEGIN
    IF g_debug THEN
        hr_utility.trace(p_trc_data);
    END IF;
END HR_UTILITY_TRACE;


  /****************************************************************************
    Name        : LOAD_XML
    Description : This procedure loads the global XML cache.
  *****************************************************************************/
PROCEDURE LOAD_XML (
    P_XML   varchar2
) AS
    l_proc_name varchar2(100);
    l_data      pay_action_information.action_information1%type;

BEGIN
    l_proc_name := g_proc_name || 'LOAD_XML';
    hr_utility_trace ('Entering '||l_proc_name);
    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()):=
                                                                        p_xml;
    hr_utility_trace ('Leaving '||l_proc_name);
END LOAD_XML;


  /****************************************************************************
    Name        : PREPARE_XML
    Description : This procedure prepares the XML to be loaded in XML cache.
  *****************************************************************************/
PROCEDURE PREPARE_XML (
    P_NODE_TYPE         varchar2,
    P_NODE              varchar2,
    P_DATA              varchar2
) AS
    l_proc_name varchar2(100);
    l_data      pay_action_information.action_information1%type;

BEGIN
    l_proc_name := g_proc_name || 'PREPARE_XML';
    hr_utility_trace ('Entering '||l_proc_name);

    IF p_node_type = 'CS' THEN
        load_xml ('<'||p_node||'>');
    ELSIF p_node_type = 'CE' THEN
        load_xml ('</'||p_node||'>');
    ELSIF p_node_type = 'D' THEN
        /* Handle special charaters in data */
        l_data := REPLACE (p_data, '&', '&amp;');
        l_data := REPLACE (l_data, '>', '&gt;');
        l_data := REPLACE (l_data, '<', '&lt;');
        l_data := REPLACE (l_data, '''', '&apos;');
        l_data := REPLACE (l_data, '"', '&quot;');
        load_xml ('<'||p_node||'>'||l_data||'</'||p_node||'>');
    END IF;

    hr_utility_trace ('Leaving '||l_proc_name);
END PREPARE_XML;


  /****************************************************************************
    Name        : STRIP_SPL_CHARS
    Description : This function converts special characters into equivalent
                  ASCII characters.
  *****************************************************************************/
FUNCTION STRIP_SPL_CHARS ( P_IN_STRING  IN  VARCHAR2)
RETURN VARCHAR2 AS

    CURSOR get_repl_char (cp_hex_code varchar2) IS
        SELECT tag
          FROM fnd_lookup_values
         WHERE lookup_type = 'MX_SS_SPL_CHARS'
           AND lookup_code = cp_hex_code;

    l_proc_name     varchar2(100);
    lv_db_charset   varchar2(50);
    lv_repl_char    varchar2(10);
    lv_curr_char    varchar2(10);
    lv_hex_code     varchar2(10);
    lv_conv_string  varchar2(32000);
    lv_return       varchar2(32000);


BEGIN
    l_proc_name := g_proc_name || 'STRIP_SPL_CHARS';
    hr_utility_trace ('Entering '||l_proc_name);
    hr_utility_trace ('p_in_string = '||p_in_string);

    lv_db_charset := SUBSTR(USERENV('LANGUAGE'),
                            INSTR(USERENV('LANGUAGE'), '.') + 1);

    hr_utility_trace ('lv_db_charset = '||lv_db_charset);

    IF lv_db_charset = 'WE8ISO8859P1' THEN
       lv_conv_string := upper(p_in_string);
    ELSE
       lv_conv_string := CONVERT(p_in_string, 'UTF8', lv_db_charset);
    END IF;

    FOR cntr IN 1..NVL(length (lv_conv_string),0) LOOP
        lv_repl_char := 'NONE';

        lv_curr_char := SUBSTR(lv_conv_string, cntr, 1);
        hr_utility_trace ('Current char = "'|| lv_curr_char ||'"');

        IF lv_db_charset <> 'WE8ISO8859P1' THEN
           lv_hex_code  := RAWTOHEX (UTL_RAW.cast_to_RAW(lv_curr_char));
           hr_utility_trace ('Hex Code = '|| lv_hex_code);

           OPEN get_repl_char (lv_hex_code);
            FETCH get_repl_char INTO lv_repl_char;
           CLOSE get_repl_char;
        ELSE
           lv_repl_char := ASCII(lv_curr_char);
           hr_utility_trace('lv_repl_char '||lv_repl_char);

           IF lv_repl_char = 193 THEN
              lv_repl_char := 'A';
           ELSIF lv_repl_char = 201 THEN
              lv_repl_char := 'E';
           ELSIF lv_repl_char = 205 THEN
              lv_repl_char := 'I';
           ELSIF lv_repl_char = 209 THEN -- This is for N
              lv_repl_char := '/';
           ELSIF lv_repl_char = 211 THEN
              lv_repl_char := 'O';
           ELSIF lv_repl_char = 218 THEN
              lv_repl_char := 'U';
           ELSE
              lv_repl_char := lv_curr_char;
           END IF;

        END IF;

        IF lv_repl_char = 'NONE' THEN
            hr_utility_trace ('Character "' || lv_curr_char ||'" not replaced');
            lv_return := lv_return || lv_curr_char;
        ELSE
            hr_utility_trace ('Character "' ||lv_curr_char ||'" replaced by ' ||
                                                                  lv_repl_char);
            lv_return := lv_return || lv_repl_char;
        END IF;
        hr_utility_trace ('-------------');
    END LOOP;

    lv_return := UPPER(CONVERT(lv_return, lv_db_charset, 'UTF8'));

    hr_utility_trace ('lv_return = '||lv_return);
    hr_utility_trace ('Leaving '||l_proc_name);
    RETURN (lv_return);
END STRIP_SPL_CHARS;


   PROCEDURE get_main_tax_unit_id(p_assignment_id   IN     NUMBER,
                                  p_effective_date  IN     DATE,
                                  p_tax_unit_id     IN OUT NOCOPY NUMBER) IS


     CURSOR csr_get_asg_details IS
     SELECT location_id,
            soft_coding_keyflex_id,
            business_group_id
     FROM   per_all_assignments_f
     WHERE  assignment_id  = p_assignment_id
     AND    p_effective_date BETWEEN effective_start_date
                                 AND effective_end_date;

     l_hsck_id        per_all_assignments_f.soft_coding_keyflex_id%TYPE;
     l_location_id    per_all_assignments_f.location_id%TYPE;
     l_bg_id          per_all_assignments_f.business_group_id%TYPE;
     l_ppa_eff_date   DATE;
     l_ambiguous_flag BOOLEAN;
     l_missing_flag   BOOLEAN;

   BEGIN
   --
     p_tax_unit_id := NULL;

     OPEN  csr_get_asg_details;
     FETCH csr_get_asg_details INTO l_location_id, l_hsck_id, l_bg_id;
     CLOSE csr_get_asg_details;

     p_tax_unit_id := nvl( hr_mx_utility.get_GRE_from_scl(l_hsck_id),

                           hr_mx_utility.get_gre_from_location(l_location_id,
                                                               l_bg_id,
                                                               p_effective_date,
                                                               l_ambiguous_flag,
                                                               l_missing_flag )
                         );

   --
   END get_main_tax_unit_id;

--
   PROCEDURE get_default_jurisdiction( p_asg_act_id   IN            NUMBER
                                      ,p_ee_id        IN            NUMBER
                                      ,p_jurisdiction IN OUT NOCOPY VARCHAR2)
   IS

     CURSOR csr_get_jd (cp_assignment_action_id NUMBER) IS
       SELECT hl.region_1
       FROM   hr_locations_all hl
             ,per_all_assignments_f paf
             ,pay_assignment_actions paa
             ,fnd_sessions fs
       WHERE paa.assignment_action_id = cp_assignment_action_id
       AND   fs.session_id            = userenv('sessionid')
       AND   paf.assignment_id        = paa.assignment_id
       AND   fs.effective_date        BETWEEN paf.effective_start_date
                                      AND     paf.effective_end_date
       AND   hl.location_id           = paf.location_id;

   BEGIN

     OPEN  csr_get_jd(p_asg_act_id);
     FETCH csr_get_jd INTO p_jurisdiction;
     CLOSE csr_get_jd;

   END get_default_jurisdiction;

--


   FUNCTION  element_template_pre_process( p_rec   in PAY_ELE_TMPLT_OBJ )
   RETURN PAY_ELE_TMPLT_OBJ IS

     l_rec PAY_ELE_TMPLT_OBJ;
   BEGIN
      l_rec := p_rec;

      hr_utility_trace('Entering pay_mx_rules.element_template_pre_process');

      hr_utility_trace('Legislation Code '||l_rec.legislation_code);

      IF ( instr( p_rec.element_classification, 'Earnings' ) > 0  OR
           p_rec.element_classification = 'Amends' ) THEN

         l_rec.process_mode := 'S';

         IF p_rec.element_classification = 'Employer Liabilities' THEN

            l_rec.configuration_information8 := 'Y';

         ELSE

            l_rec.configuration_information8 := 'N';

         END IF;

      END IF;


      IF ( instr( p_rec.element_classification, 'Deduction' ) > 0 ) THEN

         IF p_rec.configuration_information1 in ( 'A', 'APD' ) THEN

            l_rec.configuration_information2 := 'Y';

         ELSE

            l_rec.configuration_information2 := 'N';

         END IF;

      END IF;

      hr_utility_trace('Leaving pay_mx_rules.element_template_pre_process');

      RETURN l_rec;

   END element_template_pre_process;

   PROCEDURE element_template_post_process( p_element_template_id   in NUMBER )
   IS

     TYPE varchar_tab IS TABLE OF VARCHAR2(240)
        INDEX BY BINARY_INTEGER;

     CURSOR c_tmplt_info ( cp_element_template_id NUMBER ) IS
       SELECT *
       FROM   pay_element_templates
       WHERE  template_id   = cp_element_template_id
       AND    template_type = 'U';

    CURSOR get_busgrp_info ( cp_business_group_id NUMBER ) IS
      SELECT legislation_code
      FROM   per_business_groups
      WHERE  business_group_id = cp_business_group_id
      AND    organization_id   = cp_business_group_id;

   CURSOR get_classification_name( cp_template_id NUMBER ) IS
     SELECT classification_name
     FROM   pay_shadow_element_types
     WHERE  template_id = cp_template_id;

   CURSOR get_element_type_id( cp_business_group_id NUMBER
                              ,cp_element_name      VARCHAR2 ) IS
     SELECT element_type_id
     FROM   pay_element_types_f
     WHERE  business_group_id = cp_business_group_id
     AND    element_name      = cp_element_name;

   /*CURSOR get_core_element_type_id (cp_template_id NUMBER,
                                    cp_shadow_element_type_id NUMBER) IS
     SELECT core_object_id
       FROM pay_template_core_objects
      WHERE template_id = cp_template_id
        AND shadow_object_id = cp_shadow_element_type_id
        AND core_object_type = 'ET';*/

   CURSOR get_sub_classifications (cp_element_type_id NUMBER) IS
     SELECT pec.classification_name
       FROM pay_element_classifications pec,
            pay_sub_classification_rules pscr
      WHERE pec.classification_id = pscr.classification_id
        AND pscr.element_type_id = cp_element_type_id
        AND pscr.business_group_id IS NOT NULL
        AND pscr.legislation_code IS NULL
        AND pec.parent_classification_id IS NOT NULL;

     l_tmplt  pay_element_templates%ROWTYPE;

     lv_legislation_code    VARCHAR2(100);
     lv_classification_name VARCHAR2(240);
     lv_context             VARCHAR2(240);
     ln_element_type_id     NUMBER;

     l_element_type_extra_info_id       NUMBER;
     lv_sub_classification_name
                           pay_element_classifications.classification_name%type;
     l_object_version_number            NUMBER;
     ln_rate_type_count                 NUMBER;
     l_rate_type                        varchar_tab;
     l_rate_desc                        varchar_tab;
     lv_eei_info6                       VARCHAR2(240);
     lv_eei_info10                      VARCHAR2(240);
     lv_eei_info11                      VARCHAR2(240);
     lv_eei_info13                      VARCHAR2(240);

   BEGIN

     hr_utility_trace('Entering pay_mx_rules.element_template_post_process');

     hr_utility_trace('p_element_template_id '|| p_element_template_id );

     OPEN  c_tmplt_info( p_element_template_id );
     FETCH c_tmplt_info INTO l_tmplt;
     CLOSE c_tmplt_info;

     OPEN  get_busgrp_info( l_tmplt.business_group_id );
     FETCH get_busgrp_info INTO lv_legislation_code;
     CLOSE get_busgrp_info;

     OPEN  get_classification_name( l_tmplt.template_id );
     FETCH get_classification_name INTO lv_classification_name;
     CLOSE get_classification_name;

     OPEN  get_element_type_id( l_tmplt.business_group_id
                               ,l_tmplt.base_name );
     FETCH get_element_type_id INTO ln_element_type_id;
     CLOSE get_element_type_id;

     lv_context := lv_legislation_code || '_' || upper(lv_classification_name);

     IF l_tmplt.template_name = 'Days X Rate' THEN

        UPDATE pay_element_types_f
        SET    element_information_category = lv_context
              ,element_information1         = l_tmplt.preference_information8
        WHERE  element_type_id = ln_element_type_id;

     ELSIF instr( l_tmplt.template_name, 'Deduction' ) > 0 THEN

        UPDATE pay_element_types_f
        SET    element_information_category = lv_context
              ,element_information1         = l_tmplt.configuration_information1
        WHERE  element_type_id = ln_element_type_id;

        /* If an element is deduction element and INFONAVIT is Yes
           we need to create an extra info type Deduction Processing where
           Type of Deduction should be INFONAVIT */

        IF l_tmplt.configuration_information4 = 'Y' THEN

            pay_element_extra_info_api.create_element_extra_info
              (p_validate                     => FALSE
              ,p_element_type_id              => ln_element_type_id
              ,p_information_type             => 'MX_DEDUCTION_PROCESSING'
              ,p_eei_information_category     => 'MX_DEDUCTION_PROCESSING'
              ,p_eei_information1             => 'INFONAVIT'
              ,p_element_type_extra_info_id   => l_element_type_extra_info_id
              ,p_object_version_number        => l_object_version_number
              );

        END IF;

     END IF;

      IF ( instr( lv_classification_name, 'Earnings' ) > 0  OR
           lv_classification_name = 'Amends' OR
           lv_classification_name = 'Employer Liabilities' ) THEN

         IF ( l_tmplt.preference_information3 is NOT NULL)
         THEN
            lv_eei_info6  := NULL;
            lv_eei_info11 := NULL;
            lv_eei_info10 := NULL;
            IF ( l_tmplt.preference_information4 = 'IV' ) THEN
               lv_eei_info13 := 'Y';
            ELSE
               lv_eei_info13 := 'N';
               lv_eei_info11 := 'X';
               lv_eei_info10 := 'Y';
               IF (l_tmplt.preference_information4 IN ('RT', 'EN')) THEN
                  lv_eei_info6 := 'X';
               END IF;
            END IF;

            pay_element_extra_info_api.create_element_extra_info
              (p_validate                     => FALSE
              ,p_element_type_id              => ln_element_type_id
              ,p_information_type             => 'PQP_UK_ELEMENT_ATTRIBUTION'
              ,p_eei_information_category     => 'PQP_UK_ELEMENT_ATTRIBUTION'
              ,p_eei_information1             => l_tmplt.preference_information3
              ,p_eei_information2             => l_tmplt.preference_information4
              ,p_eei_information3             => l_tmplt.preference_information5
              ,p_eei_information4             => 'H'
              ,p_eei_information5             => 'N'
              ,p_eei_information6             => lv_eei_info6
              ,p_eei_information7             => l_tmplt.preference_information6
              ,p_eei_information8             => l_tmplt.preference_information7
              ,p_eei_information10            => lv_eei_info10
              ,p_eei_information11            => lv_eei_info11
              ,p_eei_information12            => 'Y'
              ,p_eei_information13            => lv_eei_info13
              ,p_eei_information14            => 'N'
              ,p_element_type_extra_info_id   => l_element_type_extra_info_id
              ,p_object_version_number        => l_object_version_number
              );

         END IF;

         ln_rate_type_count := 0;
         IF ( l_tmplt.preference_information1 = 'Y' ) THEN
            ln_rate_type_count  := ln_rate_type_count + 1;
            l_rate_type(ln_rate_type_count) := 'MX_BASE';
            l_rate_desc(ln_rate_type_count) :=
               'The Base Pay (MX_BASE) rate type will include this element'||
               ' in its rate calculation.';
         END IF;

         IF ( l_tmplt.preference_information2 = 'F' ) THEN
            ln_rate_type_count  := ln_rate_type_count + 1;
            l_rate_type(ln_rate_type_count) := 'MX_IDWF';
            l_rate_desc(ln_rate_type_count) :=
            'The Fixed IDW (MX_IDWF) rate type will include this element'||
            ' in its rate calculation.';
         ELSIF ( l_tmplt.preference_information2 = 'V' ) THEN
            ln_rate_type_count  := ln_rate_type_count + 1;
            l_rate_type(ln_rate_type_count) := 'MX_IDWV';
            l_rate_desc(ln_rate_type_count) :=
            'The Variable IDW(MX_IDWV) rate type will include this element'||
            ' in its rate calculation.';
         END IF;

         FOR i in 1..l_rate_type.COUNT
         LOOP
            pay_element_extra_info_api.create_element_extra_info
              (p_validate                     => FALSE
              ,p_element_type_id              => ln_element_type_id
              ,p_information_type             => 'PQP_UK_RATE_TYPE'
              ,p_eei_information_category     => 'PQP_UK_RATE_TYPE'
              ,p_eei_information1             => l_rate_type(i)
              ,p_eei_information2             => l_rate_desc(i)
              ,p_element_type_extra_info_id   => l_element_type_extra_info_id
              ,p_object_version_number        => l_object_version_number
              );
            hr_utility_trace('Created PQP_UK_RATE_TYPE:'||l_rate_type(i));
         END LOOP;
      END IF;

    /* If the created element belongs to social foresight or Employer
       Contributions to Savings Fund then update element's processing
       priority to 4490 and 4480 respectively. This will ensure that
       such earnings elements are processesed just before MEXICO_TAX
       (whose processing priority is 4500). */

     IF lv_classification_name in ('Supplemental Earnings',
                                   'Imputed Earnings') THEN
        OPEN get_sub_classifications (ln_element_type_id);
            LOOP
                FETCH get_sub_classifications INTO lv_sub_classification_name;
                EXIT WHEN get_sub_classifications%NOTFOUND;

                IF lv_sub_classification_name IN
                            ('Supplemental Earnings:Social Foresight Earnings',
                             'Imputed Earnings:Social Foresight Earnings') THEN
                    UPDATE pay_element_types_f
                       SET processing_priority = 4490
                     WHERE element_type_id = ln_element_type_id;
                    EXIT;
                END IF;

                IF lv_sub_classification_name =
                                   'Employer Contribution to Savings Fund' THEN
                    UPDATE pay_element_types_f
                       SET processing_priority = 4480
                     WHERE element_type_id = ln_element_type_id;
                    EXIT;
                END IF;
            END LOOP;
        CLOSE get_sub_classifications;
     END IF;

     hr_utility_trace('Leaving pay_mx_rules.element_template_post_process');

   END element_template_post_process;

   PROCEDURE add_custom_xml
       (p_assignment_action_id number,
        p_action_information_category varchar2,
        p_document_type varchar2) as

      CURSOR c_get_bus_grp_id(p_tax_unit_id number) IS
         SELECT hou.business_group_id
         FROM hr_organization_units hou
         WHERE hou.organization_id = p_tax_unit_id;

      CURSOR get_tax_unit_id(p_asg_action_id number) IS
         SELECT tax_unit_id
         FROM pay_assignment_actions
         WHERE assignment_action_id = p_asg_action_id;

      CURSOR c_get_employer_information(p_org_id number) IS
         SELECT hoi.org_information1
               ,hou.location_id
           FROM hr_organization_units hou
               ,hr_organization_information hoi
          WHERE hou.organization_id = p_org_id
            AND hoi.organization_id = hou.organization_id
            AND hoi.org_information_context = 'MX_TAX_REGISTRATION';

      CURSOR c_get_employer_address(p_location_id number) IS
         SELECT location.address_line_1,
                location.address_line_2, location.address_line_3,
                location.town_or_city, location.postal_code,
                location.country,location.region_2
           FROM hr_locations location
          WHERE location.location_id = p_location_id;

      CURSOR c_get_ee_information(p_asg_action_id number) IS
         SELECT ppf.per_information1,
	        ppf.first_name,
		ppf.last_name,
		ppf.middle_names,
		ppf.order_name,
                ppf.full_name,
		paf.payroll_id
         FROM pay_assignment_actions paa,
              pay_payroll_actions ppa,
              per_assignments_f paf,
              per_people_f      ppf
         WHERE paa.assignment_action_id = p_asg_action_id
         AND paa.payroll_action_id = ppa.payroll_action_id
         AND paf.assignment_id = paa.assignment_id
         AND ppa.effective_date BETWEEN paf.effective_start_date
                                AND paf.effective_end_date
         AND paf.person_id = ppf.person_id
         AND ppa.effective_date BETWEEN ppf.effective_start_date
                                AND ppf.effective_end_date;

      CURSOR c_get_payroll_name(p_payroll_id number) IS
         SELECT payroll_name
	 FROM   pay_payrolls_f
	 where  payroll_id = p_payroll_id;


    CURSOR get_account_type(p_per_pay_method   NUMBER,
                            p_effective_date DATE) IS
       SELECT  decode(segment4
  	              ,'CHECK','01'
  	              ,'MASTER','02'
  	              ,'DEBIT','03'
  	              ,'SAVINGS','04'
  	              ,'OTHER','05'
  	              ,substr(segment4,1,2)) segment4
               ,org_payment_method_id
       FROM pay_personal_payment_methods_f pppm,
            pay_external_accounts pea
       WHERE --pppm.assignment_id = p_assignment_id
       pppm.personal_payment_method_id = p_per_pay_method
       AND pppm.external_account_id = pea.external_account_id
       AND p_effective_date between pppm.EFFECTIVE_START_DATE
                            and pppm.EFFECTIVE_END_DATE;

      TYPE char_tab IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;


      ln_tax_unit_id        number;
      ln_bus_grp_id         number;
      lv_org_name           hr_organization_units.name%TYPE;
      ln_location_id        hr_organization_units.location_id%TYPE;
      lv_address_line1      hr_locations.address_line_1%TYPE;
      lv_address_line2      hr_locations.address_line_2%TYPE;
      lv_address_line3      hr_locations.address_line_3%TYPE;
      lv_town_or_city       hr_locations.town_or_city%TYPE;
      lv_postal_code        hr_locations.postal_code%TYPE;
      lv_country            hr_locations.country%TYPE;
      lv_state              hr_locations.region_2%TYPE;
      lv_maternal_last_name per_people_f.per_information1%TYPE;
      lv_first_name         per_people_f.first_name%TYPE;
      lv_last_name          per_people_f.last_name%TYPE;
      lv_middle_names       per_people_f.middle_names%TYPE;
      lv_order_name         per_people_f.order_name%TYPE;
      lv_full_name          per_people_f.full_name%TYPE;
      lv_payroll_id         pay_payrolls_f.payroll_id%TYPE;
      lv_payroll_name       pay_payrolls_f.payroll_name%TYPE;
      ln_per_pay_method     number;
      lv_account_type       varchar2(2);
      l_org_payment_method_id
                     pay_personal_payment_methods_f.org_payment_method_id%TYPE;

      ln_legal_employer_id  number;
      l_employer_xml        char_tab;
      ld_effective_date     date;
      lv_gre_name           pay_action_information.action_information1%type;
      lv_trans_gre_name     pay_action_information.action_information1%type;
      lv_paternal_last_name pay_action_information.action_information1%type;
      lv_employee_name      pay_action_information.action_information1%type;
      lv_location_id        pay_action_information.action_information1%type;
      l_proc_name           varchar2(100);
      --l_xml                        CLOB;

      CURSOR get_archived_info (cp_action_info_id number) IS
        SELECT effective_date,
               action_information2,
               action_information4,
               action_information5,
               action_information6,
               action_information7,
               action_information12
          FROM pay_action_information
         WHERE action_information_id = cp_action_info_id;

      FUNCTION get_param_val (p_param_name  varchar2) return varchar2 is
      BEGIN
        FOR cntr in pay_payroll_xml_extract_pkg.g_custom_params.first()..
                     pay_payroll_xml_extract_pkg.g_custom_params.last()
        LOOP
            IF pay_payroll_xml_extract_pkg.g_custom_params(cntr).parameter_name
	       = p_param_name
            THEN
               hr_utility_trace('Custom Params : '||
	             pay_payroll_xml_extract_pkg.g_custom_params(cntr).parameter_name);

               hr_utility_trace('Custom Params Value : '||
                     pay_payroll_xml_extract_pkg.g_custom_params(cntr).
                          parameter_value);

               RETURN pay_payroll_xml_extract_pkg.g_custom_params(cntr).
                     parameter_value;
            END IF;

        END LOOP;

        RETURN NULL;
      END;

   BEGIN
    l_proc_name := g_proc_name || 'ADD_CUSTOM_XML';
    hr_utility_trace('Entering '||l_proc_name);
    hr_utility_trace('p_assignment_action_id '|| p_assignment_action_id);
    hr_utility_trace('p_action_information_category '||
                   p_action_information_category);
    hr_utility_trace('p_document_type '|| p_document_type);

   /* For Direct Deposit */

   IF (p_document_type = 'DEPOSIT_XML') AND
      (p_assignment_action_id IS NOT NULL) AND
      (get_param_val('p_xml_level') = 'ER') THEN

     NULL;

   END IF;

   IF (p_document_type = 'DEPOSIT_XML') AND
      (p_assignment_action_id IS NOT NULL) AND
      (get_param_val('p_xml_level') = 'EE') THEN

      OPEN get_tax_unit_id(p_assignment_action_id);
      FETCH get_tax_unit_id INTO ln_tax_unit_id;
      CLOSE get_tax_unit_id;

      hr_utility_trace('ln_tax_unit_id '|| ln_tax_unit_id);

      OPEN c_get_bus_grp_id(ln_tax_unit_id);
      FETCH c_get_bus_grp_id INTO ln_bus_grp_id;
      CLOSE c_get_bus_grp_id;

      hr_utility_trace('ln_bus_grp_id '|| ln_bus_grp_id);

      ln_legal_employer_id :=
               hr_mx_utility.get_legal_employer(ln_bus_grp_id, ln_tax_unit_id);
      hr_utility_trace('ln_legal_employer_id '|| ln_legal_employer_id);


      OPEN  c_get_employer_information(ln_legal_employer_id);
      FETCH c_get_employer_information INTO lv_org_name
                                           ,ln_location_id;
      CLOSE c_get_employer_information;

      OPEN  c_get_employer_address(ln_location_id);
      FETCH c_get_employer_address INTO lv_address_line1
                                       ,lv_address_line2
                                       ,lv_address_line3
                                       ,lv_town_or_city
                                       ,lv_postal_code
                                       ,lv_country
                                       ,lv_state;
      CLOSE c_get_employer_address;

      OPEN c_get_ee_information (p_assignment_action_id);
      FETCH c_get_ee_information INTO
        lv_maternal_last_name,
	lv_first_name,
	lv_last_name,
	lv_middle_names,
	lv_order_name,
	lv_full_name,
	lv_payroll_id;
      CLOSE c_get_ee_information;

      OPEN c_get_payroll_name (lv_payroll_id);
      FETCH c_get_payroll_name INTO lv_payroll_name;
      CLOSE c_get_payroll_name;

      ln_per_pay_method       :=
             pay_magtape_generic.get_parameter_value(
                                                 'TRANSFER_PERSONAL_PAY_METH');

      ld_effective_date       :=
             fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value(
	                                         'TRANSFER_EFFECTIVE_DATE'));

      OPEN get_account_type(ln_per_pay_method,ld_effective_date);
      FETCH get_account_type INTO lv_account_type
                                  ,l_org_payment_method_id;
      CLOSE get_account_type;

      hr_utility_trace('lv_org_name '|| lv_org_name);
      hr_utility_trace('lv_address_line1 '|| lv_address_line1);
      hr_utility_trace('lv_address_line2 '|| lv_address_line2);
      hr_utility_trace('lv_address_line3 '|| lv_address_line3);
      hr_utility_trace('lv_town_or_city '|| lv_town_or_city);
      hr_utility_trace('lv_postal_code '|| lv_postal_code);
      hr_utility_trace('lv_country '|| lv_country);
      hr_utility_trace('lv_state '|| lv_state);
      hr_utility_trace('lv_maternal_last_name '|| lv_maternal_last_name);

      pay_payroll_xml_extract_pkg.load_xml_data('D','EMPLOYER_NAME',
                 lv_org_name);
      pay_payroll_xml_extract_pkg.load_xml_data('D','EMPLOYER_NAME_REPORTING',
                 replace(strip_spl_chars (lv_org_name),'/','N'));
      pay_payroll_xml_extract_pkg.load_xml_data('D','ADDRESS_LINE1',
                 lv_address_line1);
      pay_payroll_xml_extract_pkg.load_xml_data('D','ADDRESS_LINE2',
                 lv_address_line2);
      pay_payroll_xml_extract_pkg.load_xml_data('D','ADDRESS_LINE3',
                 lv_address_line3);
      pay_payroll_xml_extract_pkg.load_xml_data('D','CITY',lv_town_or_city);
      pay_payroll_xml_extract_pkg.load_xml_data('D','STATE',lv_state);
      pay_payroll_xml_extract_pkg.load_xml_data('D','COUNTRY',lv_country);
      pay_payroll_xml_extract_pkg.load_xml_data('D','POSTAL_CODE',
                 lv_postal_code);
      pay_payroll_xml_extract_pkg.load_xml_data('D','MATERNAL_LAST_NAME',
                 lv_maternal_last_name);
      pay_payroll_xml_extract_pkg.load_xml_data('D',
                                                'MATERNAL_LAST_NAME_REPORTING',
                 replace(strip_spl_chars (lv_maternal_last_name),'/','N'));

      pay_payroll_xml_extract_pkg.load_xml_data('D','FIRST_NAME_REPORTING',
                 replace(strip_spl_chars (lv_first_name),'/','N'));
      pay_payroll_xml_extract_pkg.load_xml_data('D','LAST_NAME_REPORTING',
                 replace(strip_spl_chars (lv_last_name),'/','N'));
      pay_payroll_xml_extract_pkg.load_xml_data('D','MIDDLE_NAMES_REPORTING',
                 replace(strip_spl_chars (lv_middle_names),'/','N'));
      pay_payroll_xml_extract_pkg.load_xml_data('D','ORDER_NAME_REPORTING',
                 replace(strip_spl_chars (lv_order_name),'/','N'));
      pay_payroll_xml_extract_pkg.load_xml_data('D','FULL_NAME_REPORTING',
                 replace(strip_spl_chars (lv_full_name),'/','N'));
      pay_payroll_xml_extract_pkg.load_xml_data('D','PAYROLL_NAME_REPORTING',
                 replace(strip_spl_chars (lv_payroll_name),'/','N'));
      pay_payroll_xml_extract_pkg.load_xml_data('D','ACCOUNT_TYPE_REPORTING',
                 lv_account_type);
   END IF;

    /* Custom XML for SUA Interface Extract and Social Security Affiliation
       Report. */
    IF p_document_type IN ('MX_SUA_MAG', 'MX_SS_AFFL') THEN
        IF p_action_information_category IS NOT NULL THEN
            OPEN get_archived_info (get_param_val ('action_information_id'));
                FETCH get_archived_info INTO ld_effective_date,
                                             lv_gre_name,
                                             lv_trans_gre_name,
                                             lv_paternal_last_name,
                                             lv_maternal_last_name,
                                             lv_employee_name,
                                             lv_location_id;
            CLOSE get_archived_info;

            IF p_action_information_category = 'MX SS GRE INFORMATION' THEN
                prepare_xml('D',
                            'GRE_NAME_REPORTING',
                            strip_spl_chars (lv_gre_name ));
                prepare_xml('D',
                            'TRANSMITTER_GRE_NAME_REPORTING',
                            strip_spl_chars (lv_trans_gre_name ));

            ELSIF p_action_information_category = 'MX SS PERSON INFORMATION'
               THEN

                prepare_xml('D',
                            'PATERNAL_LAST_NAME_REPORTING',
                            strip_spl_chars (lv_paternal_last_name ));
                prepare_xml('D',
                            'MATERNAL_LAST_NAME_REPORTING',
                            strip_spl_chars (lv_maternal_last_name ));
                prepare_xml('D',
                            'EMPLOYEE_NAME_REPORTING',
                            strip_spl_chars (lv_employee_name ));

                hr_utility_trace ('Translating location_id ...');
                prepare_xml('D',
                            'LOCATION_ID_REPORTING',
                            strip_spl_chars (lv_location_id ));

            END IF;
        END IF;
    END IF;

   hr_utility_trace('Leaving '||l_proc_name);
   EXCEPTION
    WHEN OTHERS THEN
        hr_utility_trace (SQLERRM);
        RAISE;
   end;
BEGIN
    g_proc_name := 'PAY_MX_RULES.';
    g_debug := hr_utility.debug_enabled;
END pay_mx_rules;


/
