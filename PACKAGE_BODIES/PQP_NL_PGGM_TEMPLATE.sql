--------------------------------------------------------
--  DDL for Package Body PQP_NL_PGGM_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_NL_PGGM_TEMPLATE" AS
/* $Header: pqpggped.pkb 120.2.12010000.3 2008/08/05 14:18:52 ubhat ship $ */

  g_proc_name   VARCHAR2(80) := '  pqp_nl_pggm_template.';
  g_debug       BOOLEAN      := hr_utility.debug_enabled;

-- ---------------------------------------------------------------------
-- |--------------------< Create_Element_Link >------------------------|
-- ---------------------------------------------------------------------
PROCEDURE Create_Element_Link
           (p_element_type_id               IN NUMBER
           ,p_business_group_id             IN NUMBER
           ,p_effective_start_date          IN DATE
           ,p_effective_end_date            IN DATE
           ) IS

l_link_rowid       ROWID;
l_element_link_id  NUMBER;
l_eff_end_dt       DATE := p_effective_end_date;
l_proc_name        VARCHAR2(80);

BEGIN

l_proc_name := g_proc_name||'Create_Element_Link';

IF g_debug THEN
   hr_utility.set_location('Entering: '||l_proc_name, 10);
END IF;

IF p_element_type_id IS NOT NULL THEN

     pay_element_links_pkg.insert_row(
                     p_rowid                        => l_link_rowid,
                     p_element_link_id              => l_element_link_id ,
                     p_effective_start_date         => p_effective_start_date,
                     p_effective_end_date           => l_eff_end_dt,
                     p_payroll_id                   => NULL,
                     p_job_id                       => NULL,
                     p_position_id                  => NULL,
                     p_people_group_id              => NULL,
                     p_cost_allocation_keyflex_id   => NULL,
                     p_organization_id              => NULL,
                     p_element_type_id              => p_element_type_id,
                     p_location_id                  => NULL,
                     p_grade_id                     => NULL,
                     p_balancing_keyflex_id         => NULL,
                     p_business_group_id            => p_business_group_id,
                     p_legislation_code             => NULL,
                     p_element_set_id               => NULL,
                     p_pay_basis_id                 => NULL,
                     p_costable_type                => 'N',
                     p_link_to_all_payrolls_flag    => 'N',
                     p_multiply_value_flag          => 'N',
                     p_standard_link_flag           => 'N',
                     p_transfer_to_gl_flag          => 'N',
                     p_comment_id                   => NULL,
                     p_employment_category          => NULL,
                     p_qualifying_age               => NULL,
                     p_qualifying_length_of_service => NULL,
                     p_qualifying_units             => NULL,
                     p_attribute_category           => NULL,
                     p_attribute1                   => NULL,
                     p_attribute2                   => NULL,
                     p_attribute3                   => NULL,
                     p_attribute4                   => NULL,
                     p_attribute5                   => NULL,
                     p_attribute6                   => NULL,
                     p_attribute7                   => NULL,
                     p_attribute8                   => NULL,
                     p_attribute9                   => NULL,
                     p_attribute10                  => NULL,
                     p_attribute11                  => NULL,
                     p_attribute12                  => NULL,
                     p_attribute13                  => NULL,
                     p_attribute14                  => NULL,
                     p_attribute15                  => NULL,
                     p_attribute16                  => NULL,
                     p_attribute17                  => NULL,
                     p_attribute18                  => NULL,
                     p_attribute19                  => NULL,
                     p_attribute20                  => NULL ) ;

END IF;

IF g_debug THEN
   hr_utility.set_location('Leaving : '||l_proc_name, 10);
END IF;

END Create_Element_Link;

-- ---------------------------------------------------------------------
-- |--------------------< Create_User_Template >------------------------|
-- ---------------------------------------------------------------------
FUNCTION Create_User_Template
           (p_pension_category              IN VARCHAR2
           ,p_pension_provider_id           IN NUMBER
           ,p_pension_type_id               IN NUMBER
           ,p_scheme_prefix                 IN VARCHAR2
           ,p_reporting_name                IN VARCHAR2
           ,p_scheme_description            IN VARCHAR2
           ,p_termination_rule              IN VARCHAR2
           ,p_standard_link                 IN VARCHAR2
           ,p_effective_start_date          IN DATE      DEFAULT NULL
           ,p_effective_end_date            IN DATE      DEFAULT NULL
           ,p_security_group_id             IN NUMBER    DEFAULT NULL
           ,p_business_group_id             IN NUMBER
           ,p_basis_rounding                IN VARCHAR2
           ,p_contrib_rounding              IN VARCHAR2
           ,p_link_dedn_elements            IN VARCHAR2
           ,p_link_retro_elements           IN VARCHAR2
           )
   RETURN NUMBER IS
   --
   TYPE shadow_ele_rec IS RECORD
         (element_type_id  pay_shadow_element_types.element_type_id%TYPE
         ,object_version_number
                           pay_shadow_element_types.object_version_NUMBER%TYPE
         ,reporting_name   pay_shadow_element_types.reporting_name%TYPE
         ,description      pay_shadow_element_types.description%TYPE
         );
   TYPE t_shadow_ele_info IS TABLE OF shadow_ele_rec
   INDEX BY BINARY_INTEGER;

   l_shadow_element              t_shadow_ele_info;

   TYPE t_ele_name IS TABLE OF pay_element_types_f.element_name%TYPE
   INDEX BY BINARY_INTEGER;

   l_ele_name                    t_ele_name;
   l_ele_new_name                t_ele_name;
   l_main_ele_name               t_ele_name;
   l_retro_ele_name              t_ele_name;

   TYPE t_bal_name IS TABLE OF pay_balance_types.balance_name%TYPE
   INDEX BY BINARY_INTEGER;
   l_bal_name                    t_bal_name;
   l_bal_new_name                t_bal_name;

   TYPE t_ele_reporting_name IS TABLE OF
        pay_element_types_f.reporting_name%TYPE
   INDEX BY BINARY_INTEGER;
   l_ele_reporting_name          t_ele_reporting_name;

   TYPE t_ele_description IS TABLE OF
        pay_element_types_f.description%TYPE
   INDEX BY BINARY_INTEGER;
   l_ele_description             t_ele_description;

   TYPE t_ele_pp IS TABLE OF
        pay_element_types_f.processing_priority%TYPE
   INDEX BY BINARY_INTEGER;
   l_ele_pp                      t_ele_pp;

   TYPE t_eei_info IS TABLE OF
        pay_element_type_extra_info.eei_information19%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE t_retro_ele IS TABLE OF
        pay_element_types_f.element_type_id%TYPE
   INDEX BY BINARY_INTEGER;

   l_retro_element_lst  t_retro_ele;

   l_main_eei_info19   t_eei_info;
   l_retro_eei_info19  t_eei_info;
   l_ele_core_id       pay_template_core_objects.core_object_id%TYPE:= -1;

   --
   -- Extra Information variables
   --
   l_eei_information11    pay_element_type_extra_info.eei_information9%TYPE;
   l_eei_information12    pay_element_type_extra_info.eei_information10%TYPE;
   l_eei_information20    pay_element_type_extra_info.eei_information18%TYPE;
   --l_configuration_information1  VARCHAR2(10) := 'N' ;
   l_configuration_information2  VARCHAR2(10) := 'N' ;
   l_configuration_information3  VARCHAR2(10) := 'N' ;
   l_configuration_information4  VARCHAR2(10) := 'N' ;
   l_configuration_information5  VARCHAR2(10) := 'N' ;
   l_configuration_information6  VARCHAR2(10) := 'N' ;
   l_configuration_information7  VARCHAR2(10) := 'N' ;
   l_configuration_information8  VARCHAR2(10) := 'N' ;
   l_configuration_information9  VARCHAR2(10) := 'N' ;
   l_configuration_information10 VARCHAR2(10) := 'N' ;
   l_ee_contribution_bal_type_id
        pqp_pension_types_f.ee_contribution_bal_type_id%TYPE;
   l_er_contribution_bal_type_id
        pqp_pension_types_f.er_contribution_bal_type_id%TYPE;
   l_ee_retro_bal_id pay_balance_types.balance_type_id%TYPE;
   l_er_retro_bal_id pay_balance_types.balance_type_id%TYPE;
   l_pen_sal_bal_type_id
        pqp_pension_types_f.pension_salary_balance%TYPE := -1;
   l_balance_feed_Id
        pay_balance_feeds_f.balance_feed_id%TYPE;
   l_row_id                      ROWID;
   l_request_id                  NUMBER;
   l_er_request_id               NUMBER;
   l_formula_text                VARCHAR2(32767);
   l_formula_text1               VARCHAR2(32767);
   l_tax_si_text                 VARCHAR2(32767);
   l_abs_text                    VARCHAR2(32767);
   l_dbi_user_name               ff_database_items.user_name%TYPE;
   l_balance_name                pay_balance_types.balance_name%TYPE;
   l_balance_dbi_name            ff_database_items.user_name%TYPE;
   l_template_id                 pay_shadow_element_types.template_id%TYPE;
   l_base_element_type_id        pay_template_core_objects.core_object_id%TYPE;
   l_er_base_element_type_id     pay_template_core_objects.core_object_id%TYPE;
   l_cy_retro_element_type_id    pay_template_core_objects.core_object_id%TYPE;
   l_cy_er_retro_element_type_id pay_template_core_objects.core_object_id%TYPE;
   l_py_retro_element_type_id    pay_template_core_objects.core_object_id%TYPE;
   l_py_er_retro_element_type_id pay_template_core_objects.core_object_id%TYPE;
   l_xtr_element_type_id         pay_template_core_objects.core_object_id%TYPE;
   l_source_template_id          pay_element_templates.template_id%TYPE;
   l_object_version_NUMBER       pay_element_types_f.object_version_NUMBER%TYPE;
   l_proc_name                   VARCHAR2(80)
                                 := g_proc_name || 'create_user_template';
   l_element_type_id             NUMBER;
   l_balance_type_id             NUMBER;
   l_eei_element_type_id         NUMBER;
   l_ele_obj_ver_NUMBER          NUMBER;
   l_bal_obj_ver_NUMBER          NUMBER;
   i                             NUMBER;
   li                            NUMBER;
   l_eei_info_id                 NUMBER;
   l_ovn_eei                     NUMBER;
   l_formula_name                pay_shadow_formulas.formula_name%TYPE;
   l_formula_id                  NUMBER;
   l_formula_id1                 NUMBER;
   y                             NUMBER := 0;
   l_exists                      VARCHAR2(1);
   l_count                       NUMBER := 0;
   l_retro_count                 NUMBER := 0;
   l_shad_formula_id             NUMBER;
   l_shad_formula_id1            NUMBER;
   l_retr_1                      NUMBER;
   l_retr_2                      NUMBER;
   l_retr_3                      NUMBER;
   l_retr_4                      NUMBER;
   l_retr_5                      NUMBER;
   l_retr_6                      NUMBER;
   l_retr_7                      NUMBER;
   l_retr_21                     NUMBER;
   l_retr_22                     NUMBER;
   l_prem_replace_string         VARCHAR2(5000) := ' ' ;
   l_std_link_flag               VARCHAR2(10) := 'N';
   l_scheme_prefix               VARCHAR2(50) := p_scheme_prefix;
   l_pension_sub_category       pqp_pension_types_f.pension_sub_category%TYPE;
   l_subcat                     VARCHAR2(30);
   l_conversion_rule
                                pqp_pension_types_f.threshold_conversion_rule%TYPE;
   l_basis_method               pqp_pension_types_f.pension_basis_calc_method%TYPE;




   --
   CURSOR  csr_get_ele_info (c_ele_name VARCHAR2) IS
   SELECT  element_type_id
          ,object_version_NUMBER
     FROM  pay_shadow_element_types
    WHERE  template_id    = l_template_id
      AND  element_name   = c_ele_name;
   --
   CURSOR  csr_get_bal_info (c_bal_name VARCHAR2) IS
   SELECT  balance_type_id
          ,object_version_NUMBER
     FROM  pay_shadow_balance_types
    WHERE  template_id  = l_template_id
      AND  balance_name = c_bal_name;
   --
   CURSOR csr_shd_ele (c_shd_elename VARCHAR2) IS
   SELECT element_type_id, object_version_NUMBER
     FROM pay_shadow_element_types
    WHERE template_id    = l_template_id
      AND element_name   = c_shd_elename;
   --
   CURSOR csr_ipv  (c_ele_typeid     NUMBER
                   ,c_effective_date DATE) IS
   SELECT input_value_id
     FROM pay_input_values_f
    WHERE element_type_id   = c_ele_typeid
      AND business_group_id = p_business_group_id
      AND NAME              = 'Pay Value'
      AND c_effective_date BETWEEN effective_start_date
                               AND effective_end_date;
   --
   CURSOR csr_pty1  (c_pension_type_id     NUMBER
                   ,c_effective_date DATE) IS
   SELECT *
     FROM pqp_pension_types_f
    WHERE pension_type_id   = c_pension_type_id
      AND business_group_id = p_business_group_id
      AND c_effective_date BETWEEN effective_start_date
                               AND effective_end_date;

   r_pty_rec pqp_pension_types_f%ROWTYPE;

     CURSOR  csr_get_formula_txt (c_formula_id NUMBER) IS
     SELECT formula_text
       FROM pay_shadow_formulas
      WHERE formula_id  = c_formula_id
        AND template_type = 'U';

     CURSOR csr_get_dbi_user_name (c_bal_type_id NUMBER) IS
     SELECT user_name
       FROM ff_database_items dbi
           ,ff_route_parameter_values rpv
           ,ff_route_parameters rp
           ,pay_balance_dimensions pbd
           ,pay_defined_balances pdb
      WHERE dbi.user_entity_id = rpv.user_entity_id
        AND rpv.route_parameter_id = rp.route_parameter_id
        AND rp.route_id = pbd.route_id
        AND pbd.database_item_suffix =  '_PER_YTD'
         and pdb.BALANCE_DIMENSION_ID = pbd.BALANCE_DIMENSION_ID
         and pdb.balance_type_id = to_char(c_bal_type_id)
        AND pbd.legislation_code = 'NL'
         AND rpv.value = pdb.DEFINED_BALANCE_ID;



     -- Cursor added to find the dbi name for the
     -- Pension Salary Balance for ABP
     CURSOR csr_get_pen_sal_bal_dbi_name (c_bal_type_id NUMBER) IS
     SELECT user_name
       FROM ff_database_items dbi
           ,ff_route_parameter_values rpv
           ,ff_route_parameters rp
           ,pay_balance_dimensions pbd
           ,pay_defined_balances pdb
      WHERE dbi.user_entity_id = rpv.user_entity_id
        AND rpv.route_parameter_id = rp.route_parameter_id
        AND rp.route_id = pbd.route_id
         AND pbd.database_item_suffix = '_ASG_RUN'
         and pdb.BALANCE_DIMENSION_ID = pbd.BALANCE_DIMENSION_ID
         and pdb.balance_type_id = to_char(c_bal_type_id)
        AND pbd.legislation_code = 'NL'
        AND rpv.value = pdb.DEFINED_BALANCE_ID ;

     -- Cursor added to find the balance name for the
     -- Pension Salary Balance for
        CURSOR csr_get_pen_sal_bal_name (c_bal_type_id NUMBER) IS
        SELECT balance_name
        FROM pay_balance_types
           WHERE balance_type_id = c_bal_type_id
                 AND (business_group_id = p_business_group_id
                      OR business_group_id IS NULL
                      OR legislation_code = 'NL');


    CURSOR chk_pension_scheme_name_cur IS
    SELECT 'x'
      FROM pay_element_type_extra_info
     WHERE eei_information_category = 'PQP_NL_PGGM_DEDUCTION'
       AND eei_information1         = p_scheme_description
       AND rownum                   = 1;

    CURSOR c_get_retro_bal_id(c_subcat IN VARCHAR2
                             ,c_ee_er  IN VARCHAR2) IS
    SELECT balance_type_id
      FROM pay_balance_types_tl
    WHERE  balance_name = 'Retro '||c_subcat||' '
                          ||c_ee_er||' Contribution'
      AND  LANGUAGE = 'US';

   l_scheme_dummy VARCHAR2(10);

   -- ---------------------------------------------------------------------
   -- |----------------------< Create_Retro_Usages >-------------------------|
   -- ---------------------------------------------------------------------

   PROCEDURE Create_Retro_Usages
     (p_creator_name             VARCHAR2,
      p_creator_type             VARCHAR2,
      p_retro_component_priority BINARY_INTEGER,
      p_default_component        VARCHAR2,
      p_reprocess_type           VARCHAR2,
      p_retro_element_name       VARCHAR2 DEFAULT NULL,
      p_start_time_def_name      VARCHAR2 DEFAULT 'Start of Time',
      p_end_time_def_name        VARCHAR2 DEFAULT 'End of Time',
      p_business_group_id        NUMBER)
   IS
     l_creator_id    NUMBER;
     l_comp_name     pay_retro_components.component_name%TYPE;
     l_comp_id       pay_retro_components.retro_component_id%TYPE;
     l_comp_type     pay_retro_components.retro_type%TYPE;
     l_rc_usage_id   pay_retro_component_usages.Retro_Component_Usage_Id%TYPE;
     l_retro_ele_id  pay_element_types_f.element_type_id%TYPE;
     l_time_span_id  pay_time_spans.time_span_id%TYPE;
     l_es_usage_id   pay_element_span_usages.element_span_usage_id%TYPE;
     l_proc_name     VARCHAR2(80);
   --
   --
   --
BEGIN
     l_proc_name := g_proc_name||'Create_Retro_Usages';

     IF g_debug THEN
        hr_utility.set_location('Entering: '||l_proc_name, 10);
     END IF;
     --
     IF  g_creator.name = p_creator_name AND
         g_creator.type = p_creator_type
     THEN
        l_creator_id := g_creator.id;
     ELSE
        --
        -- Prime creator cache
        --
        IF p_creator_type = 'ET' THEN
           SELECT DISTINCT element_type_id
             INTO l_creator_id
             FROM pay_element_types_f
            WHERE element_name = p_creator_name
              AND business_group_id = p_business_group_id;
        ELSIF p_creator_type = 'EC' THEN
           SELECT classification_id
             INTO l_creator_id
             FROM pay_element_classifications
            WHERE classification_name = p_creator_name
              AND business_group_id = p_business_group_id;
        ELSE
           RAISE no_data_found;
        END IF;

        g_creator.name := p_creator_name;
        g_creator.type := p_creator_type;
        g_creator.id   := l_creator_id;

     END IF;
     --
     IF g_component.EXISTS(p_retro_component_priority)  THEN
        l_comp_name := g_component(p_retro_component_priority).NAME;
        l_comp_type := g_component(p_retro_component_priority).TYPE;
        l_comp_id   := g_component(p_retro_component_priority).id;
     ELSE
        -- prime component cache
        SELECT rc.retro_component_id,rc.component_name, rc.retro_type
          INTO l_comp_id, l_comp_name, l_comp_type
          FROM pay_retro_definitions     rd,
               pay_retro_defn_components rdc,
               pay_retro_components      rc
        WHERE  rdc.retro_component_id = rc.retro_component_id
          AND  rc.legislation_code    = g_legislation_code
          AND  rdc.priority           = p_retro_component_priority
          AND  rd.retro_definition_id = rdc.retro_definition_id
          AND  rd.legislation_code    = g_legislation_code
          AND  rd.definition_name     = g_retro_def_name;
        --
        g_component(p_retro_component_priority).NAME := l_comp_name;
        g_component(p_retro_component_priority).TYPE := l_comp_type;
        g_component(p_retro_component_priority).id   := l_comp_id;
     END IF;
     --
     IF l_comp_type = 'F' AND p_reprocess_type <> 'R' THEN
       RAISE no_data_found;
     END IF;
     --
     BEGIN
       SELECT Retro_Component_Usage_Id
         INTO l_rc_usage_id
         FROM pay_retro_component_usages
        WHERE retro_component_id = l_comp_id
          AND creator_id         = l_creator_id
          AND creator_type       = p_creator_type;
     EXCEPTION WHEN no_data_found THEN
       SELECT pay_retro_component_usages_s.NEXTVAL
         INTO l_rc_usage_id
         FROM dual;
       --
       IF g_debug THEN
          hr_utility.set_location('Insert Retro Comp Usgs '||l_proc_name, 20);
       END IF;

       INSERT INTO pay_retro_component_usages(
          RETRO_COMPONENT_USAGE_ID,
          RETRO_COMPONENT_ID,
          CREATOR_ID,
          CREATOR_TYPE,
          DEFAULT_COMPONENT,
          REPROCESS_TYPE,
          BUSINESS_GROUP_ID,
          LEGISLATION_CODE,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          OBJECT_VERSION_NUMBER)
       VALUES(l_rc_usage_id
             ,l_comp_id
             ,l_creator_id
             ,p_creator_type
             ,p_default_component
             ,p_reprocess_type
             ,p_business_group_id
             ,NULL
             ,SYSDATE
             ,-1
             ,SYSDATE
             ,-1
             ,-1
             ,1);
     END;
     --
     IF p_retro_element_name IS NOT NULL AND p_creator_type='ET' THEN
        IF  g_component(p_retro_component_priority).start_time_def_name
                 = p_start_time_def_name
        AND g_component(p_retro_component_priority).end_time_def_name
                 = p_end_time_def_name
       THEN
         l_time_span_id := g_component(p_retro_component_priority).time_span_id;
       ELSE
         -- Prime cache
         SELECT ts.time_span_id
           INTO l_time_span_id
           FROM pay_time_definitions s,
                pay_time_definitions e,
                pay_time_spans       ts
          WHERE ts.creator_id = l_comp_id
            AND ts.creator_type = 'RC'
            AND ts.start_time_def_id = s.time_definition_id
            AND ts.end_time_def_id = e.time_definition_id
            AND s.legislation_code = 'NL'
            AND s.definition_name = p_start_time_def_name
            AND e.legislation_code = 'NL'
            AND e.definition_name = p_end_time_def_name;

         g_component(p_retro_component_priority).time_span_id := l_time_span_id;
         g_component(p_retro_component_priority).start_time_def_name
                    := p_start_time_def_name;
         g_component(p_retro_component_priority).end_time_def_name
                    := p_end_time_def_name;
       END IF;
       --
       SELECT DISTINCT element_type_id
         INTO l_retro_ele_id
         FROM pay_element_types_f
        WHERE element_name = p_retro_element_name
          AND business_group_id = p_business_group_id;
       --
       BEGIN
         SELECT element_span_usage_id
           INTO l_es_usage_id
           FROM pay_element_span_usages
          WHERE time_span_id             = l_time_span_id
            AND retro_component_usage_id = l_rc_usage_id
            AND adjustment_type   IS NULL;

       EXCEPTION WHEN no_data_found THEN
         SELECT pay_element_span_usages_s.NEXTVAL
           INTO l_es_usage_id
           FROM dual;

         IF g_debug THEN
            hr_utility.set_location('Insert Element Span Usgs '||l_proc_name, 30);
         END IF;

         INSERT INTO pay_element_span_usages(
           ELEMENT_SPAN_USAGE_ID,
           BUSINESS_GROUP_ID,
           LEGISLATION_CODE,
           TIME_SPAN_ID,
           RETRO_COMPONENT_USAGE_ID,
           ADJUSTMENT_TYPE,
           RETRO_ELEMENT_TYPE_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           OBJECT_VERSION_NUMBER)
         VALUES(l_es_usage_id
               ,p_business_group_id
               ,NULL
               ,l_time_span_id
               ,l_rc_usage_id
               ,NULL
               ,l_retro_ele_id
               ,SYSDATE
               ,-1
               ,SYSDATE
               ,-1
               ,-1
               ,1);
       END;
     END IF;

  IF g_debug THEN
     hr_utility.set_location('Leaving '||l_proc_name, 40);
  END IF;
--
EXCEPTION WHEN no_data_found THEN
      NULL;
END Create_Retro_Usages;

-- ---------------------------------------------------------------------
-- |----------------------< Update_Event_Group >-------------------------|
-- ---------------------------------------------------------------------

PROCEDURE Update_Event_Group
  (p_element_name             VARCHAR2,
   p_business_group_id        NUMBER)
IS

CURSOR c_get_retro_evg_id IS
SELECT event_group_id
  FROM pay_event_groups
WHERE  event_group_name = 'PQP_NL_RETRO_EVG'
  AND  legislation_code = 'NL';

l_retro_evg_id  NUMBER;
l_proc_name     VARCHAR2(80);
--
--
--
BEGIN
  l_proc_name := g_proc_name||'Update_Event_Group';

  IF g_debug THEN
     hr_utility.set_location('Entering: '||l_proc_name, 10);
  END IF;

   --Query up the retro event group id
   OPEN c_get_retro_evg_id;
   FETCH c_get_retro_evg_id INTO l_retro_evg_id;
   IF c_get_retro_evg_id%FOUND THEN
      hr_utility.set_location('Retro EVG id found: '||l_retro_evg_id,20);
      CLOSE c_get_retro_evg_id;

      --now update the elements with this recalc event grp id
      UPDATE pay_element_types_f
         SET recalc_event_group_id = l_retro_evg_id
      WHERE  element_name = p_element_name
         AND business_group_id = p_business_group_id;
   ELSE
      --evg id was not found
      hr_utility.set_location('Retro EVG id not found',30);
      CLOSE c_get_retro_evg_id;
   END IF;

  IF g_debug THEN
     hr_utility.set_location('Leaving: '||l_proc_name, 40);
  END IF;

EXCEPTION WHEN OTHERS THEN
      NULL;

END Update_Event_Group;

   -- ---------------------------------------------------------------------
   -- |------------------------< Get_Template_ID >-------------------------|
   -- ---------------------------------------------------------------------
   FUNCTION Get_Template_Id (p_legislation_code IN VARCHAR2)
     RETURN NUMBER IS
     --
     l_template_name VARCHAR2(80);
     l_proc_name     VARCHAR2(72) := g_proc_name || 'get_template_id';
     --
     CURSOR csr_get_temp_id  IS
     SELECT template_id
       FROM pay_element_templates
      WHERE template_name     = l_template_name
        AND legislation_code  = p_legislation_code
        AND template_type     = 'T'
        AND business_group_id IS NULL;
     --
   BEGIN
      --
      IF g_debug THEN
         hr_utility.set_location('Entering: '||l_proc_name, 10);
      END IF;
      --
      l_template_name  := 'PGGM Pension Deduction';
      --
      IF g_debug THEN
         hr_utility.set_location(l_proc_name, 20);
      END IF;
      --
      FOR csr_get_temp_id_rec IN csr_get_temp_id LOOP
         l_template_id   := csr_get_temp_id_rec.template_id;
      END LOOP;
      --
      IF g_debug THEN
         hr_utility.set_location('Leaving: '||l_proc_name, 30);
      END IF;
      --
      RETURN l_template_id;
      --
   END Get_Template_ID;

  BEGIN
  -- ---------------------------------------------------------------------
  -- |-------------< Main Function : Create_User_Template Body >----------|
  -- ---------------------------------------------------------------------
  IF g_debug THEN
     hr_utility.set_location('Entering : '||l_proc_name, 10);
  END IF;

   --
   -- Check the format of the prefix name entered.
   --
   pqp_nl_pension_template.chk_scheme_prefix(p_scheme_prefix);

   IF g_debug THEN
      hr_utility.set_location('Check unique scheme name : '||l_proc_name, 11);
   END IF;

   --
   -- Check if the scheme being created is already in use.
   --
   OPEN chk_pension_scheme_name_cur;
     FETCH chk_pension_scheme_name_cur INTO l_scheme_dummy;
       IF chk_pension_scheme_name_cur%FOUND THEN
         CLOSE chk_pension_scheme_name_cur;
         fnd_message.set_name('PQP','PQP_230924_SCHEME_NAME_ERR');
         fnd_message.raise_error;
       ELSE
         CLOSE chk_pension_scheme_name_cur;
       END IF;

    --
    -- Fetch all pension type details
    --
    IF g_debug THEN
       hr_utility.set_location('Fetching PT Details : '||l_proc_name, 12);
    END IF;

    OPEN csr_pty1 (c_pension_type_id => p_pension_type_id
                  ,c_effective_date  => p_effective_start_date);
    FETCH csr_pty1 INTO r_pty_rec;
    --
      IF csr_pty1%NOTFOUND THEN
         fnd_message.set_name('PQP', 'PQP_230805_INV_PENSIONID');
         fnd_message.raise_error;
      END IF;
    --
    CLOSE csr_pty1;

     l_pension_sub_category := r_pty_rec.pension_sub_category;
     l_conversion_rule      := r_pty_rec.threshold_conversion_rule;
     l_basis_method         := r_pty_rec.pension_basis_calc_method;


   -- ---------------------------------------------------------------------
   -- Set session date to the start date of the PGGM Pension scheme
   -- ---------------------------------------------------------------------
   pay_db_pay_setup.set_session_date(NVL(p_effective_start_date, SYSDATE));
   --
   IF g_debug THEN
      hr_utility.set_location('..Setting the Session Date', 15);
   END IF;
   -- ---------------------------------------------------------------------
   -- Get Source Template Id for the PGGM template
   -- ---------------------------------------------------------------------
   l_source_template_id := get_template_id
                   (p_legislation_code  => g_template_leg_code);
   IF g_debug THEN
      hr_utility.set_location('Derived the Src Template id', 15);
   END IF;
   -- ---------------------------------------------------------------------
   -- Exclusion rules
   -- ---------------------------------------------------------------------
   IF g_debug THEN
      hr_utility.set_location('..Checking all the Exclusion Rules', 20);
   END IF;

   -- Define the exclusion rules

        IF r_pty_rec.std_tax_reduction IS NOT NULL THEN
          l_configuration_information2 := 'Y';
        END IF;

        IF r_pty_rec.spl_tax_reduction IS NOT NULL THEN
          l_configuration_information3 := 'Y';
        END IF;

        IF r_pty_rec.sig_sal_spl_tax_reduction IS NOT NULL THEN
          l_configuration_information8 := 'Y';
        END IF;

        IF r_pty_rec.sig_sal_non_tax_reduction IS NOT NULL THEN
          l_configuration_information9 := 'Y';
        END IF;

        IF r_pty_rec.sig_sal_std_tax_reduction IS NOT NULL THEN
          l_configuration_information7 := 'Y';
        END IF;

        IF r_pty_rec.sii_std_tax_reduction IS NOT NULL THEN
          l_configuration_information4 := 'Y';
        END IF;

        IF r_pty_rec.sii_spl_tax_reduction IS NOT NULL THEN
          l_configuration_information5 := 'Y';
        END IF;

        IF r_pty_rec.sii_non_tax_reduction IS NOT NULL THEN
          l_configuration_information6 := 'Y';
        END IF;

   -- ---------------------------------------------------------------------
   -- Create user structure from the template
   -- ---------------------------------------------------------------------
   IF g_debug THEN
      hr_utility.set_location('..Creating template User structure', 25);
   END IF;

   pay_element_template_api.create_user_structure
    (p_validate                      => FALSE
    ,p_effective_date                => p_effective_start_date
    ,p_business_group_id             => p_business_group_id
    ,p_source_template_id            => l_source_template_id
    ,p_base_name                     => p_scheme_prefix
    ,p_configuration_information2    => l_configuration_information2
    ,p_configuration_information3    => l_configuration_information3
    ,p_configuration_information4    => l_configuration_information4
    ,p_configuration_information5    => l_configuration_information5
    ,p_configuration_information6    => l_configuration_information6
    ,p_configuration_information7    => l_configuration_information7
    ,p_configuration_information8    => l_configuration_information8
    ,p_configuration_information9    => l_configuration_information9
    ,p_configuration_information10   => l_configuration_information10
    ,p_template_id                   => l_template_id
    ,p_object_version_number         => l_object_version_number
    );

   IF g_debug THEN
      hr_utility.set_location('Done Creating User structure', 26);
      hr_utility.set_location('Deriving element typ ids', 27);
   END IF;

   -- ---------------------------------------------------------------------
   -- |-------------------< Update Shadow Structure >----------------------|
   -- ---------------------------------------------------------------------
   -- Get Element Type id and update user-specified Classification,
   -- Category, Processing Type and Standard Link on Base Element
   -- as well as other element created for the Scheme
   -- ---------------------------------------------------------------------
   -- 1. <BASE NAME> PGGM Pension Deduction

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' PGGM Pension Deduction')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
                := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number
                := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name
                := NVL(p_reporting_name,p_scheme_prefix)||' PGGM EE';
    l_shadow_element(l_count).description
                := 'Element for '||p_scheme_prefix||' PGGM Pension Deduction';
   END LOOP;

   -- 2. <BASE NAME>  Retro PGGM Pension Deduction Current Year

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix
                              ||' Retro PGGM Pension Deduction Current Year')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
                := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
                := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
                := NVL(p_reporting_name,p_scheme_prefix)||' Retro PGGM CY';
    l_shadow_element(l_count).description
              := 'Element for '||p_scheme_prefix
                               ||'  Retro PGGM Pension Deduction Current Year';
   END LOOP;

    -- 3. <BASE NAME> Retro PGGM Pension Deduction Previous Year

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix
                               ||' Retro PGGM Pension Deduction Previous Year')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
              := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
              := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
              := NVL(p_reporting_name,p_scheme_prefix)
                   ||' Retro PGGM PY';
      l_shadow_element(l_count).description
              := 'Element for '||p_scheme_prefix
                              ||' Retro PGGM Pension Deduction Previous Year';
     END LOOP;


   -- 4. <BASE NAME> PGGM Employer Pension Contribution

      FOR csr_rec IN csr_shd_ele (p_scheme_prefix||
                                  ' PGGM Employer Pension Contribution')
      LOOP
       l_count := l_count + 1;
       l_shadow_element(l_count).element_type_id
             := csr_rec.element_type_id;
       l_shadow_element(l_count).object_version_NUMBER
             := csr_rec.object_version_NUMBER;
       l_shadow_element(l_count).reporting_name
             := NVL(p_reporting_name,p_scheme_prefix)
                ||' PGGM ER Contribution';
       l_shadow_element(l_count).description
             := 'Element for '||p_scheme_prefix
                              ||' PGGM Employer Pension Contribution';
      END LOOP;

    -- 5. <BASE NAME> Retro PGGM Employer Pension Contribution Current Year

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix
                        ||' Retro PGGM Employer Pension Contribution Current Year')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
                  := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
                  := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
                  := NVL(p_reporting_name,p_scheme_prefix)
                  ||' Retro PGGM ER CY';
      l_shadow_element(l_count).description
                   := 'Element for '||p_scheme_prefix
                   ||' Retro PGGM Employer Pension Contribution Current Year';
     END LOOP;

    -- 6. <BASE NAME> Retro PGGM Employer Pension Contribution Previous Year

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix
                     ||' Retro PGGM Employer Pension Contribution Previous Year')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
                   := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
                    := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
                  := NVL(p_reporting_name,p_scheme_prefix)||' Retro PGGM ER PY';
      l_shadow_element(l_count).description
                   := 'Element for '||p_scheme_prefix
                   ||' Retro PGGM Employer Pension Contribution Previous Year';
     END LOOP;


   -- 7. <BASE NAME> PGGM Disability Pension Contribution

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' PGGM Disability Pension Contribution')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
           := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
           := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
           := NVL(p_reporting_name,p_scheme_prefix||' PGGM Disability');
    l_shadow_element(l_count).description
           := 'Element for '||p_scheme_prefix||' PGGM Disability Pension Contribution';
   END LOOP;

   -- 8. <BASE NAME> Standard Tax Adjustment

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' Standard Tax Adjustment')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' Std. Tax Adj.';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' Standard Tax Adjustment';
   END LOOP;


   -- 9. <BASE NAME> SI Gross Standard Adjustment

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' SI Gross Standard Adjustment')
   LOOP
    l_count := l_count +1;
    l_shadow_element(l_count).element_type_id
           := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
           := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
           := NVL(p_reporting_name,p_scheme_prefix)||' SI Gross Std. Adj.';
    l_shadow_element(l_count).description
           := 'Element for '||p_scheme_prefix||' SI Gross Standard Adjustment';
   END LOOP;


   -- 10. <BASE NAME> SI Income Standard Adjustment

   FOR csr_rec IN csr_shd_ele(p_scheme_prefix||' SI Income Standard Adjustment')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' SII Std. Adj.';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' SI Income Standard Adjustment';
   END LOOP;

   -- 11. <BASE NAME> SI Gross Special Adjustment

   FOR csr_rec IN csr_shd_ele(p_scheme_prefix||' SI Gross Special Adjustment')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' SI Gross Spl. Adj.';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' SI Gross Special Adjustment';
   END LOOP;

   -- 12. <BASE NAME> Special Tax Adjustment

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' Special Tax Adjustment')
   LOOP
    l_count := l_count + 1 ;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' Spl. Tax Adj.';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' Special Tax Adjustment';
   END LOOP;

   -- 13. <BASE NAME> SI Income Special Adjustment

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' SI Income Special Adjustment')
   LOOP
    l_count := l_count + 1 ;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' SII Spl. Adj';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' SI Income Special Adjustment';
   END LOOP;

   -- 14. <BASE NAME> SI Gross Non Tax Adjustment

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' SI Gross Non Tax Adjustment')
   LOOP
    l_count := l_count + 1 ;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' SI Gross Non Tax Adj.';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' SI Gross Non Tax Adjustment';
   END LOOP;

   -- 15. <BASE NAME> SI Income Non Tax Adjustment

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' SI Income Non Tax Adjustment')
   LOOP
    l_count := l_count + 1 ;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' SII Non Tax Adj.';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' SI Income Non Tax Adjustment';
   END LOOP;


   -- 16. <BASE NAME> Tax SI Adjustment

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' Tax SI Adjustment')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
                := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
                := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
                := NVL(p_reporting_name,p_scheme_prefix)||' Tax SI Adjustment';
    l_shadow_element(l_count).description
                := 'Element for '||p_scheme_prefix||' Tax SI Adjustment';
   END LOOP;

    -- 17. <BASE NAME> PGGM Extra Pensions

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' PGGM Extra Pensions')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
                   := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
                    := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
                  := NVL(p_reporting_name,p_scheme_prefix)
                      ||' PGGM Extra Pensions';
      l_shadow_element(l_count).description
                   := 'Element for '||p_scheme_prefix||' PGGM Extra Pensions';
     END LOOP;

    -- 34. <BASE NAME> Retro PGGM Extra Pensions

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix
                              ||' Retro PGGM Extra Pensions')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
                   := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
                    := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
                  := NVL(p_reporting_name,p_scheme_prefix)
                      ||' Retro PGGM Ext ';
      l_shadow_element(l_count).description
                   := 'Element for '||p_scheme_prefix
                              ||' Retro PGGM Extra Pensions';
     END LOOP;

   -- 35. <BASE NAME> Retro PGGM Disability Pension Contribution

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix
                              ||' Retro PGGM Disability Pension Contribution')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
                   := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
                    := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
                  := NVL(p_reporting_name,p_scheme_prefix)
                      ||' Retro PGGM Disability ';
      l_shadow_element(l_count).description
                   := 'Element for '||p_scheme_prefix
                              ||' Retro PGGM Disability Pension Contribution';
     END LOOP;

   IF g_debug THEN
      hr_utility.set_location('Finished deriving element typ ids', 28);
      hr_utility.set_location('..Updating the scheme shadow elements', 30);
   END IF;

   FOR i IN 1..l_count
      LOOP
        pay_shadow_element_api.update_shadow_element
          (p_validate               => FALSE
          ,p_effective_date         => p_effective_start_date
          ,p_element_type_id        => l_shadow_element(i).element_type_id
          ,p_description            => l_shadow_element(i).description
          ,p_reporting_name         => l_shadow_element(i).reporting_name
          ,p_post_termination_rule  => p_termination_rule
          ,p_object_version_number  => l_shadow_element(i).object_version_number
          );
   END LOOP;

   IF g_debug THEN
      hr_utility.set_location('..After Updating the scheme shadow elements', 50);
   END IF;
   --
   -- Replace the spaces in the prefix with underscores. The formula name
   -- has underscores if the prefix name has spaces in it .
   --
   l_scheme_prefix := UPPER(REPLACE(l_scheme_prefix,' ','_'));

   --
   -- Update Shadow formula
   --
   l_shad_formula_id := pqp_nl_pension_template.Get_Formula_Id
                         (l_scheme_prefix||'_PGGM_PENSION_DEDUCTION'
                           ,p_business_group_id);

    IF g_debug THEN
       hr_utility.set_location('Replacing Balance Name in the formula', 51);
    END IF;

      IF r_pty_rec.ee_contribution_bal_type_id IS NOT NULL THEN

         FOR temp_rec IN csr_get_formula_txt(l_shad_formula_id)
           LOOP
             l_formula_text := temp_rec.formula_text;
           END LOOP;

         FOR temp_rec IN
                csr_get_dbi_user_name(r_pty_rec.ee_contribution_bal_type_id)
           LOOP
             l_dbi_user_name := temp_rec.user_name;
             l_formula_text := REPLACE(l_formula_text,
                                       'REPLACE_PT_EE_BAL_PER_YTD',
                                       l_dbi_user_name);

             UPDATE pay_shadow_formulas
                SET formula_text      = l_formula_text
              WHERE formula_id        = l_shad_formula_id
                AND business_group_id = p_business_group_id;

           END LOOP;
      END IF;

       --
       -- Replace the taxation and social insurance
       -- balance reduction text in the formula
       --
       IF g_debug THEN
          hr_utility.set_location('Replacing Tax SI string in the formula', 51);
       END IF;

       pqp_pension_functions.gen_dynamic_formula
                          (p_pension_type_id => p_pension_type_id
                          ,p_effective_date => p_effective_start_date
                          ,p_formula_string => l_tax_si_text);

       FOR temp_rec IN csr_get_formula_txt(l_shad_formula_id)
       LOOP
          l_formula_text := temp_rec.formula_text;
       END LOOP;
       l_formula_text := REPLACE(l_formula_text,'REPLACE_TAX_SI_TEXT',
                                        l_tax_si_text);

       UPDATE pay_shadow_formulas
          SET formula_text = l_formula_text
        WHERE formula_id = l_shad_formula_id
          AND business_group_id = p_business_group_id;

    l_shad_formula_id1 :=
      pqp_nl_pension_template.Get_Formula_Id
                               (l_scheme_prefix||
                                '_PGGM_EMPLOYER_PENSION_CONTRIBUTION'
                                ,p_business_group_id);

   IF g_debug THEN
      hr_utility.set_location('Done replacing Tax SI string in the formula', 51);
      hr_utility.set_location('Generating Core objects : Part - 1', 50);
   END IF;
   -- ---------------------------------------------------------------------
   -- |-------------------< Generate Core Objects >------------------------|
   -- ---------------------------------------------------------------------
   pay_element_template_api.generate_part1
    (p_validate         => FALSE
    ,p_effective_date   => p_effective_start_date
    ,p_hr_only          => FALSE
    ,p_hr_to_payroll    => FALSE
    ,p_template_id      => l_template_id);
   --
   IF g_debug THEN
      hr_utility.set_location('..After Generating Core objects : Part - 1', 50);
      hr_utility.set_location('..After Generating Core objects : Part - 2', 50);
   END IF;

   pay_element_template_api.generate_part2
    (p_validate         => FALSE
    ,p_effective_date   => p_effective_start_date
    ,p_template_id      => l_template_id);
   --
   IF g_debug THEN
      hr_utility.set_location('..After Generating Core objects : Part - 2', 50);
      hr_utility.set_location('Updating Input Values..', 50);
   END IF;

   --
   -- Update some the input values for default values
   --
   pqp_nl_pension_template.Update_Ipval_Defval(
                    p_scheme_prefix||' PGGM Pension Deduction'
                   ,'Pension Type Id'
                   ,TO_CHAR(p_pension_type_id)
                   ,p_business_group_id);

   pqp_nl_pension_template.Update_Ipval_Defval(
                    p_scheme_prefix||' PGGM Pension Deduction'
                   ,'Basis Rounding'
                   ,p_basis_rounding
                   ,p_business_group_id);

   pqp_nl_pension_template.Update_Ipval_Defval(
                    p_scheme_prefix||' PGGM Pension Deduction'
                   ,'Contribution Rounding'
                   ,p_contrib_rounding
                   ,p_business_group_id);

   pqp_nl_pension_template.Update_Ipval_Defval(
                    p_scheme_prefix||' PGGM Employer Pension Contribution'
                    ,'Pension Type Id'
                    ,TO_CHAR(p_pension_type_id)
                    ,p_business_group_id);

   pqp_nl_pension_template.Update_Ipval_Defval(
                    p_scheme_prefix||' PGGM Employer Pension Contribution'
                   ,'Basis Rounding'
                   ,p_basis_rounding
                   ,p_business_group_id);

   pqp_nl_pension_template.Update_Ipval_Defval(
                    p_scheme_prefix||' PGGM Employer Pension Contribution'
                   ,'Contribution Rounding'
                   ,p_contrib_rounding
                   ,p_business_group_id);

   IF g_debug THEN
      hr_utility.set_location('Done Updating Input Values..', 50);
      hr_utility.set_location('Deriving Element Type Ids..', 50);
   END IF;

   -- ------------------------------------------------------------------------
   -- Derive Element Type Ids for all elements created.
   -- ------------------------------------------------------------------------
   l_base_element_type_id := pqp_nl_pension_template.get_object_id
                                ('ELE',
                                  p_scheme_prefix||' PGGM Pension Deduction',
                                  p_business_group_id,
                                  l_template_id);

   l_er_base_element_type_id := pqp_nl_pension_template.get_object_id
                        ('ELE',
                          p_scheme_prefix||' PGGM Employer Pension Contribution',
                          p_business_group_id,
                          l_template_id);

   l_xtr_element_type_id := pqp_nl_pension_template.get_object_id
                        ('ELE',
                          p_scheme_prefix||' PGGM Extra Pensions',
                          p_business_group_id,
                          l_template_id);

   l_cy_retro_element_type_id := pqp_nl_pension_template.get_object_id
                                ('ELE',
                                  p_scheme_prefix
                                  ||' Retro PGGM Pension Deduction Current Year',
                                  p_business_group_id,
                                  l_template_id);

   l_py_retro_element_type_id := pqp_nl_pension_template.get_object_id
                                ('ELE',
                                  p_scheme_prefix
                                  ||' Retro PGGM Pension Deduction Previous Year',
                                  p_business_group_id,
                                  l_template_id);

   l_cy_er_retro_element_type_id := pqp_nl_pension_template.get_object_id
                        ('ELE',
                          p_scheme_prefix
                          ||' Retro PGGM Employer Pension Contribution Current Year',
                          p_business_group_id,
                          l_template_id);

   l_py_er_retro_element_type_id := pqp_nl_pension_template.get_object_id
                        ('ELE',
                          p_scheme_prefix
                          ||' Retro PGGM Employer Pension Contribution Previous Year',
                          p_business_group_id,
                          l_template_id);
    IF g_debug THEN
       hr_utility.set_location('Completed Deriving Element Type Ids..', 50);
    END IF;
    --
    -- Get the ids of all the retro elements
    -- This is required to create links if the user has
    -- selected to do so
    --

   IF NVL(p_link_retro_elements,'N') = 'Y' THEN

   IF g_debug THEN
      hr_utility.set_location('Deriving Retro Element Type Ids..', 50);
   END IF;

   l_retr_1 := pqp_nl_pension_template.get_object_id
                      ('ELE',
                        p_scheme_prefix||
                      ' Retro PGGM Employer Pension Contribution Current Year'
                      , p_business_group_id
                      , l_template_id);

    IF l_retr_1 IS NOT NULL THEN
       l_retro_count := l_retro_count + 1;
       l_retro_element_lst(l_retro_count) := l_retr_1;
    END IF;

   l_retr_2 := pqp_nl_pension_template.get_object_id
                      ('ELE',
                       p_scheme_prefix||
                       ' Retro PGGM Employer Pension Contribution Previous Year'
                       ,p_business_group_id
                       ,l_template_id);

    IF l_retr_2 IS NOT NULL THEN
       l_retro_count := l_retro_count + 1;
       l_retro_element_lst(l_retro_count) := l_retr_2;
    END IF;

   l_retr_3 := pqp_nl_pension_template.get_object_id
               ('ELE',
                 p_scheme_prefix||
                 ' Retro PGGM Pension Deduction Current Year'
                 ,p_business_group_id
                 ,l_template_id);

    IF l_retr_3 IS NOT NULL THEN
       l_retro_count := l_retro_count + 1;
       l_retro_element_lst(l_retro_count) := l_retr_3;
    END IF;


   l_retr_4 := pqp_nl_pension_template.get_object_id
               ('ELE',
                 p_scheme_prefix||
                 ' Retro PGGM Pension Deduction Previous Year'
                 ,p_business_group_id
                 ,l_template_id);

    IF l_retr_4 IS NOT NULL THEN
       l_retro_count := l_retro_count + 1;
       l_retro_element_lst(l_retro_count) := l_retr_4;
    END IF;

   l_retr_5 := pqp_nl_pension_template.get_object_id
               ('ELE',
                 p_scheme_prefix||
                 ' Retro PGGM Pension Adj CY'
                 ,p_business_group_id
                 ,l_template_id);

    IF l_retr_5 IS NOT NULL THEN
       l_retro_count := l_retro_count + 1;
       l_retro_element_lst(l_retro_count) := l_retr_5;
    END IF;

   l_retr_6 := pqp_nl_pension_template.get_object_id
               ('ELE',
                 p_scheme_prefix||
                 ' Retro PGGM Pension Adj PY'
                 ,p_business_group_id
                 ,l_template_id);

    IF l_retr_6 IS NOT NULL THEN
       l_retro_count := l_retro_count + 1;
       l_retro_element_lst(l_retro_count) := l_retr_6;
    END IF;

   l_retr_7 := pqp_nl_pension_template.get_object_id
               ('ELE',
                 p_scheme_prefix||
                 ' Retro PGGM Disability Adj'
                 ,p_business_group_id
                 ,l_template_id);

    IF l_retr_7 IS NOT NULL THEN
       l_retro_count := l_retro_count + 1;
       l_retro_element_lst(l_retro_count) := l_retr_7;
    END IF;

   l_retr_21 := pqp_nl_pension_template.get_object_id ('ELE',
                p_scheme_prefix||
                ' Retro PGGM Extra Pensions'
                ,p_business_group_id
                ,l_template_id);

    IF l_retr_21 IS NOT NULL THEN
       l_retro_count := l_retro_count + 1;
       l_retro_element_lst(l_retro_count) := l_retr_21;
    END IF;

    l_retr_22 := pqp_nl_pension_template.get_object_id ('ELE',
                p_scheme_prefix||
                ' Retro PGGM Disability Pension Contribution'
                ,p_business_group_id
                ,l_template_id);

    IF l_retr_22 IS NOT NULL THEN
       l_retro_count := l_retro_count + 1;
       l_retro_element_lst(l_retro_count) := l_retr_22;
    END IF;

    IF g_debug THEN
       hr_utility.set_location('Completed Deriving Retro Element Type Ids..', 50);
       hr_utility.set_location('Creating Retro Ele Links..', 50);
    END IF;

    --
    -- Create Links for the retro elements if the user has chosen to do so.
    --
    FOR li IN 1..l_retro_count
       LOOP
       Create_Element_Link
           (p_element_type_id       => l_retro_element_lst(li)
           ,p_business_group_id     => p_business_group_id
           ,p_effective_start_date  => p_effective_start_date
           ,p_effective_end_date    => p_effective_end_date );
    END LOOP;

    IF g_debug THEN
       hr_utility.set_location('Completed Creating Retro Ele Links..', 50);
    END IF;

    END IF; -- Check if retro element links need to be created

    --
    -- If necessary, create the element links fro the main deduction elements.
    --
    IF NVL(p_link_dedn_elements,'N') = 'Y' THEN

       IF g_debug THEN
          hr_utility.set_location('Creating Ele Links..', 50);
       END IF;

        -- Main Deduction Element
        Create_Element_Link
           (p_element_type_id       => l_base_element_type_id
           ,p_business_group_id     => p_business_group_id
           ,p_effective_start_date  => p_effective_start_date
           ,p_effective_end_date    => p_effective_end_date );

        -- ER Contribution Element
        Create_Element_Link
           (p_element_type_id       => l_er_base_element_type_id
           ,p_business_group_id     => p_business_group_id
           ,p_effective_start_date  => p_effective_start_date
           ,p_effective_end_date    => p_effective_end_date );

        -- Extra Pensions Element
        Create_Element_Link
           (p_element_type_id       => l_xtr_element_type_id
           ,p_business_group_id     => p_business_group_id
           ,p_effective_start_date  => p_effective_start_date
           ,p_effective_end_date    => p_effective_end_date );

       IF g_debug THEN
          hr_utility.set_location('Completed Creating Ele Links..', 50);
       END IF;

     END IF;


   -- ------------------------------------------------------------------------
   -- Create a row in pay_element_extra_info with all the element information
   -- ------------------------------------------------------------------------
   IF g_debug THEN
      hr_utility.set_location('..Creating element extra information', 50);
   END IF;

   pay_element_extra_info_api.create_element_extra_info
     (p_element_type_id            => l_base_element_type_id
     ,p_information_type           => 'PQP_NL_PGGM_DEDUCTION'
     ,p_eei_information_category   => 'PQP_NL_PGGM_DEDUCTION'
     ,p_eei_information1           => p_scheme_description
     ,p_eei_information2           => TO_CHAR(p_pension_type_id)
     ,p_eei_information3           => TO_CHAR(p_pension_provider_id)
     ,p_eei_information4           => p_scheme_prefix
     ,p_eei_information5           => to_char(p_effective_start_date,'DD/MM/YYYY')
     ,p_eei_information6           => to_char(p_effective_end_date,'DD/MM/YYYY')
     ,p_eei_information7           => l_pension_sub_category
     ,p_eei_information8           => l_basis_method
     ,p_eei_information9           => p_basis_rounding
     ,p_eei_information10          => p_contrib_rounding
     ,p_eei_information11          => TO_CHAR(l_cy_retro_element_type_id)
     ,p_eei_information12          => TO_CHAR(l_py_retro_element_type_id)
     ,p_eei_information13          => TO_CHAR(l_cy_er_retro_element_type_id)
     ,p_eei_information14          => TO_CHAR(l_py_er_retro_element_type_id)
     ,p_element_type_extra_info_id => l_eei_info_id
     ,p_object_version_number      => l_ovn_eei);

   IF g_debug THEN
       hr_utility.set_location('..After Creating element extra information', 50);

   -- ---------------------------------------------------------------------
   -- Create the Retro Component usage associations between the retro and
   -- pension deduction elements
   -- ---------------------------------------------------------------------
       hr_utility.set_location('Creating Retro Comp Usgs', 50);
   END IF;

    -- EE Correction
    Create_Retro_Usages
     (p_creator_name             => p_scheme_prefix||' PGGM Pension Deduction'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  10
     ,p_default_component        => 'N'
     ,p_reprocess_type           => 'S'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Pension Deduction Current Year'
     ,p_start_time_def_name      => 'Start of Current Year'
     ,p_end_time_def_name        => 'End of Time'
     ,p_business_group_id        => p_business_group_id);

    Create_Retro_Usages
     (p_creator_name             => p_scheme_prefix||' PGGM Pension Deduction'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  10
     ,p_default_component        => 'N'
     ,p_reprocess_type           => 'S'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Pension Deduction Previous Year'
     ,p_start_time_def_name      => 'Start of Time'
     ,p_end_time_def_name        => 'End of Previous Year'
     ,p_business_group_id        => p_business_group_id);

    -- EE Adjustment
    Create_Retro_Usages
     (p_creator_name             => p_scheme_prefix||' PGGM Pension Deduction'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  20
     ,p_default_component        => 'Y'
     ,p_reprocess_type           => 'R'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Pension Adj CY'
     ,p_start_time_def_name      => 'Start of Current Year'
     ,p_end_time_def_name        => 'End of Time'
     ,p_business_group_id        => p_business_group_id);

    Create_Retro_Usages
     (p_creator_name             => p_scheme_prefix||' PGGM Pension Deduction'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  20
     ,p_default_component        => 'Y'
     ,p_reprocess_type           => 'R'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Pension Adj PY'
     ,p_start_time_def_name      => 'Start of Time'
     ,p_end_time_def_name        => 'End of Previous Year'
     ,p_business_group_id        => p_business_group_id);

    -- ER Correction
    Create_Retro_Usages
     (p_creator_name
      => p_scheme_prefix||' PGGM Employer Pension Contribution'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  10
     ,p_default_component        => 'N'
     ,p_reprocess_type           => 'S'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Employer Pension Contribution Current Year'
     ,p_start_time_def_name      => 'Start of Current Year'
     ,p_end_time_def_name        => 'End of Time'
     ,p_business_group_id        => p_business_group_id);

    Create_Retro_Usages
     (p_creator_name
      => p_scheme_prefix||' PGGM Employer Pension Contribution'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  10
     ,p_default_component        => 'N'
     ,p_reprocess_type           => 'S'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Employer Pension Contribution Previous Year'
     ,p_start_time_def_name      => 'Start of Time'
     ,p_end_time_def_name        => 'End of Previous Year'
     ,p_business_group_id        => p_business_group_id);

    -- Changes as specified in Version history for version 115.9
    -- ER Adjustment
    Create_Retro_Usages
     (p_creator_name
      => p_scheme_prefix||' PGGM Employer Pension Contribution'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  20
     ,p_default_component        => 'Y'
     ,p_reprocess_type           => 'R'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Employer Pension Contribution Current Year'
     ,p_start_time_def_name      => 'Start of Current Year'
     ,p_end_time_def_name        => 'End of Time'
     ,p_business_group_id        => p_business_group_id);

    Create_Retro_Usages
     (p_creator_name
      => p_scheme_prefix||' PGGM Employer Pension Contribution'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  20
     ,p_default_component        => 'Y'
     ,p_reprocess_type           => 'R'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Employer Pension Contribution Previous Year'
     ,p_start_time_def_name      => 'Start of Time'
     ,p_end_time_def_name        => 'End of Previous Year'
     ,p_business_group_id        => p_business_group_id);

     -- Extra Pensions Correction
     Create_Retro_Usages (p_creator_name
      => p_scheme_prefix||' PGGM Extra Pensions'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  10
     ,p_default_component        => 'N'
     ,p_reprocess_type           => 'S'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Extra Pensions'
     ,p_start_time_def_name      => 'Start of Current Year'
     ,p_end_time_def_name        => 'End of Time'
     ,p_business_group_id        => p_business_group_id);

    Create_Retro_Usages
     (p_creator_name
      => p_scheme_prefix||' PGGM Extra Pensions'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  10
     ,p_default_component        => 'N'
     ,p_reprocess_type           => 'S'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Extra Pensions'
     ,p_start_time_def_name      => 'Start of Time'
     ,p_end_time_def_name        => 'End of Previous Year'
     ,p_business_group_id        => p_business_group_id);

     -- Extra Pensions Adjustment
    Create_Retro_Usages (p_creator_name
      => p_scheme_prefix||' PGGM Extra Pensions'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  20
     ,p_default_component        => 'Y'
     ,p_reprocess_type           => 'R'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Extra Pensions'
     ,p_start_time_def_name      => 'Start of Current Year'
     ,p_end_time_def_name        => 'End of Time'
     ,p_business_group_id        => p_business_group_id);

    Create_Retro_Usages
     (p_creator_name
      => p_scheme_prefix||' PGGM Extra Pensions'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  20
     ,p_default_component        => 'Y'
     ,p_reprocess_type           => 'R'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Extra Pensions'
     ,p_start_time_def_name      => 'Start of Time'
     ,p_end_time_def_name        => 'End of Previous Year'
     ,p_business_group_id        => p_business_group_id);


     -- Disability Correction
     Create_Retro_Usages (p_creator_name
      => p_scheme_prefix||' PGGM Disability Pension Contribution'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  10
     ,p_default_component        => 'N'
     ,p_reprocess_type           => 'S'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Disability Pension Contribution'
     ,p_start_time_def_name      => 'Start of Current Year'
     ,p_end_time_def_name        => 'End of Time'
     ,p_business_group_id        => p_business_group_id);

    Create_Retro_Usages
     (p_creator_name
      => p_scheme_prefix||' PGGM Disability Pension Contribution'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  10
     ,p_default_component        => 'N'
     ,p_reprocess_type           => 'S'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Disability Pension Contribution'
     ,p_start_time_def_name      => 'Start of Time'
     ,p_end_time_def_name        => 'End of Previous Year'
     ,p_business_group_id        => p_business_group_id);

     -- Disability Adjustment
     Create_Retro_Usages (p_creator_name
      => p_scheme_prefix||' PGGM Disability Pension Contribution'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  20
     ,p_default_component        => 'Y'
     ,p_reprocess_type           => 'R'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Disability Adj'
     ,p_start_time_def_name      => 'Start of Current Year'
     ,p_end_time_def_name        => 'End of Time'
     ,p_business_group_id        => p_business_group_id);

    Create_Retro_Usages
     (p_creator_name
      => p_scheme_prefix||' PGGM Disability Pension Contribution'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  20
     ,p_default_component        => 'Y'
     ,p_reprocess_type           => 'R'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro PGGM Disability Adj'
     ,p_start_time_def_name      => 'Start of Time'
     ,p_end_time_def_name        => 'End of Previous Year'
     ,p_business_group_id        => p_business_group_id);

   IF g_debug THEN
      hr_utility.set_location('Done Creating Retro Comp Usgs', 50);
   END IF;

   IF g_debug THEN
      hr_utility.set_location('Adding Event Group',60);
   END IF;

   Update_Event_Group
   (p_element_name => p_scheme_prefix||' PGGM Pension Deduction'
    ,p_business_group_id => p_business_group_id);

   Update_Event_Group
   (p_element_name => p_scheme_prefix||' PGGM Employer Pension Contribution'
    ,p_business_group_id => p_business_group_id);

   Update_Event_Group
   (p_element_name => p_scheme_prefix||' PGGM Extra Pensions'
    ,p_business_group_id => p_business_group_id);

   IF g_debug THEN
      hr_utility.set_location('Done Adding the Event Group', 60);
   END IF;

   -- ---------------------------------------------------------------------
   -- Compile the base element's standard formula
   -- ---------------------------------------------------------------------
      hr_utility.set_location('Compile EE Formula', 50);

      pqp_nl_pension_template.Compile_Formula
        (p_element_type_id       => l_base_element_type_id
        ,p_effective_start_date  => p_effective_start_date
        ,p_scheme_prefix         => l_scheme_prefix
        ,p_business_group_id     => p_business_group_id
        ,p_request_id            => l_request_id
         );

      IF g_debug THEN
         hr_utility.set_location('Done Compile EE Formula', 50);
         hr_utility.set_location('Compile ER Formula', 50);
      END IF;

      pqp_nl_pension_template.Compile_Formula
        (p_element_type_id       => l_er_base_element_type_id
        ,p_effective_start_date  => p_effective_start_date
        ,p_scheme_prefix         => l_scheme_prefix
        ,p_business_group_id     => p_business_group_id
        ,p_request_id            => l_er_request_id
         );

       IF g_debug THEN
          hr_utility.set_location('Done Compile ER Formula', 50);
          hr_utility.set_location('Leaving :'||l_proc_name, 190);
       END IF;

 RETURN l_base_element_type_id;

END Create_User_Template;


-- ---------------------------------------------------------------------
-- |--------------------< Create_User_Template_Swi >------------------------|
-- ---------------------------------------------------------------------
FUNCTION Create_User_Template_Swi
           (p_pension_category              IN VARCHAR2
           ,p_pension_provider_id           IN NUMBER
           ,p_pension_type_id               IN NUMBER
           ,p_scheme_prefix                 IN VARCHAR2
           ,p_reporting_name                IN VARCHAR2
           ,p_scheme_description            IN VARCHAR2
           ,p_termination_rule              IN VARCHAR2
           ,p_standard_link                 IN VARCHAR2
           ,p_effective_start_date          IN DATE      DEFAULT NULL
           ,p_effective_end_date            IN DATE      DEFAULT NULL
           ,p_security_group_id             IN NUMBER    DEFAULT NULL
           ,p_business_group_id             IN NUMBER
           ,p_basis_rounding                IN VARCHAR2
           ,p_contrib_rounding              IN VARCHAR2
           ,p_link_dedn_elements            IN VARCHAR2
           ,p_link_retro_elements           IN VARCHAR2
           )
   RETURN NUMBER IS
  --
  -- Variables for API Boolean parameters
  l_validate                      BOOLEAN;
  --
  -- Variables for IN/OUT parameters
  l_element_type_id      NUMBER;
  --
  -- Other variables
  l_return_status VARCHAR2(1);
  l_proc    VARCHAR2(72) := 'Create_User_Template_Swi';
BEGIN

  IF g_debug THEN
     hr_utility.set_location(' Entering:' || l_proc,10);
  END IF;

  l_element_type_id    :=    -1;
  --
  -- Issue a savepoint
  --
  SAVEPOINT Create_User_Template_Swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => hr_api.g_false_num);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
   l_element_type_id   :=  Create_User_Template
           (p_pension_category       => p_pension_category
           ,p_pension_provider_id    => p_pension_provider_id
           ,p_pension_type_id        => p_pension_type_id
           ,p_scheme_prefix          => p_scheme_prefix
           ,p_reporting_name         => p_reporting_name
           ,p_scheme_description     => p_scheme_description
           ,p_termination_rule       => p_termination_rule
           ,p_standard_link          => p_standard_link
           ,p_effective_start_date   => p_effective_start_date
           ,p_effective_end_date     => p_effective_end_date
           ,p_security_group_id      => p_security_group_id
           ,p_business_group_id      => p_business_group_id
           ,p_basis_rounding         => p_basis_rounding
           ,p_contrib_rounding       => p_contrib_rounding
           ,p_link_dedn_elements     => p_link_dedn_elements
           ,p_link_retro_elements    => p_link_retro_elements
           );

  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  l_return_status := hr_multi_message.get_return_status_disable;

  IF g_debug THEN
     hr_utility.set_location(' Leaving:' || l_proc,20);
  END IF;

  RETURN l_element_type_id;

  --
EXCEPTION
  WHEN hr_multi_message.error_message_exist THEN
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    ROLLBACK TO Create_User_Template_Swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    RETURN l_element_type_id;

    IF g_debug THEN
       hr_utility.set_location(' Leaving:' || l_proc, 30);
    END IF;

  WHEN others THEN
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    ROLLBACK TO Create_User_Template_Swi;
    IF hr_multi_message.unexpected_error_add(l_proc) THEN
       IF g_debug THEN
          hr_utility.set_location(' Leaving:' || l_proc,40);
       END IF;
       RAISE;
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    RETURN l_element_type_id;

    IF g_debug THEN
       hr_utility.set_location(' Leaving:' || l_proc,50);
    END IF;

END Create_User_Template_Swi;

-- ---------------------------------------------------------------------
-- |--------------------< Delete_User_Template >------------------------|
-- ---------------------------------------------------------------------
PROCEDURE Delete_User_Template
           (p_business_group_id            IN NUMBER
           ,p_pension_dedn_ele_name        IN VARCHAR2
           ,p_pension_dedn_ele_type_id     IN NUMBER
           ,p_security_group_id            IN NUMBER
           ,p_effective_date               IN DATE
           ) IS
  --
  CURSOR c1 IS
   SELECT template_id
          ,base_name
     FROM pay_element_templates
    WHERE base_name||' PGGM Pension Deduction'  = p_pension_dedn_ele_name
      AND business_group_id                     = p_business_group_id
      AND template_type                         = 'U';

  CURSOR csr_ele_extra_info IS
  SELECT element_type_extra_info_id
        ,object_version_number ovn
    FROM pay_element_type_extra_info
   WHERE eei_information_category = 'PQP_NL_PGGM_DEDUCTION'
     AND element_type_id          = p_pension_dedn_ele_type_id;

  --
  -- Cursor to check the existance of a run result
  -- for a particular element_type_id
  --
  CURSOR c_chk_rr_exist (c_element_type_id IN NUMBER) IS
  SELECT 1
    FROM dual
   WHERE EXISTS ( SELECT 1
                    FROM pay_run_results prr
                   WHERE prr.element_type_id = c_element_type_id) ;

   --
   -- Cursor to fetch the retro component usage id for a given
   -- element type id
   --
   CURSOR c_get_retro_comp_id(c_element_type_id IN NUMBER) IS
   SELECT retro_component_usage_id
     FROM pay_retro_component_usages
    WHERE creator_id = c_element_type_id
      AND creator_type = 'ET'
      AND business_group_id = p_business_group_id;

   --
   -- Cursor to fetch the element span usage ids for the element type id
   --
   CURSOR c_get_element_span_id(c_retro_comp_usage_id IN NUMBER) IS
   SELECT element_span_usage_id
     FROM pay_element_span_usages
    WHERE retro_component_usage_id = c_retro_comp_usage_id
      AND business_group_id = p_business_group_id;

   CURSOR c_er_ele (c_base_name IN VARCHAR2) IS
   SELECT element_type_id
     FROM pay_element_types_f
    WHERE element_name = c_base_name||' PGGM Employer Pension Contribution'
      AND business_group_id = p_business_group_id
      AND trunc(p_effective_date) BETWEEN effective_start_date AND
                                          effective_end_date ;


  l_template_id          NUMBER(9);
  l_dummy                NUMBER;
  l_proc                 VARCHAR2(60) := g_proc_name||'Delete_User_Template';
  l_rr_exist             BOOLEAN      := FALSE;
  l_er_dedn_ele_type_id  NUMBER       := -1 ;
  l_base_name            VARCHAR2(100);

BEGIN
   IF g_debug THEN
      hr_utility.set_location('Entering :'||l_proc, 10);
   END IF;
   --
   -- Check if Run Results exist for the EE Deduction Element
   -- If Run Results exist, the pension scheme and related
   -- payroll objects cannot be deleted.
   --

   OPEN c_chk_rr_exist(p_pension_dedn_ele_type_id);
     FETCH c_chk_rr_exist
      INTO l_dummy;

      IF c_chk_rr_exist%FOUND THEN
            l_rr_exist := TRUE;
      ELSIF c_chk_rr_exist%NOTFOUND THEN
            l_rr_exist := FALSE;
      END IF;

      CLOSE c_chk_rr_exist;

--
   FOR c1_rec IN c1 LOOP
     l_base_name   := c1_rec.base_name;
     l_template_id := c1_rec.template_id;
   END LOOP;
--
-- Get the element_type_id of the ER element
--
OPEN c_er_ele(l_base_name) ;
   FETCH c_er_ele
    INTO l_er_dedn_ele_type_id;
       IF c_er_ele%FOUND THEN
          l_er_dedn_ele_type_id := -1;
       END IF;
    CLOSE c_er_ele;

IF NOT l_rr_exist THEN

   --
   -- Payroll has not been processed. Attempt to delete
   --

   --
   pay_element_template_api.delete_user_structure
     (p_validate                =>   FALSE
     ,p_drop_formula_packages   =>   TRUE
     ,p_template_id             =>   l_template_id);
   --

   --
   -- Delete the rows in pay_element_type_extra_info
   --
   FOR temp_rec IN csr_ele_extra_info
     LOOP
       pay_element_extra_info_api.delete_element_extra_info
       (p_element_type_extra_info_id => temp_rec.element_type_extra_info_id
       ,p_object_version_number      => temp_rec.ovn);
     END LOOP;

   IF g_debug THEN
      hr_utility.set_location('Leaving :'||l_proc, 50);
   END IF;

ELSE -- run results exist
   hr_utility.set_message(8303,'PQP_230214_PGGM_SCHM_DEL_ERR');
   hr_utility.raise_error;
END IF;

END Delete_User_Template;
--

-- ---------------------------------------------------------------------
-- |------------------< Delete_User_Template_Swi >----------------------|
-- ---------------------------------------------------------------------

PROCEDURE Delete_User_Template_Swi
           (p_business_group_id            IN NUMBER
           ,p_pension_dedn_ele_name        IN VARCHAR2
           ,p_pension_dedn_ele_type_id     IN NUMBER
           ,p_security_group_id            IN NUMBER
           ,p_effective_date               IN DATE
           ) IS

  --
  -- Variables for API Boolean parameters
  l_validate                      BOOLEAN;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_return_status   VARCHAR2(1);
  l_proc            VARCHAR2(72) := 'Delete_User_Template_Swi';
BEGIN
  IF g_debug THEN
     hr_utility.set_location(' Entering:' || l_proc,10);
  END IF;
  --
  -- Issue a savepoint
  --
  SAVEPOINT Delete_User_Template_Swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => hr_api.g_false_num);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
   Delete_User_Template
           (p_business_group_id         =>   p_business_group_id
           ,p_pension_dedn_ele_name     =>   p_pension_dedn_ele_name
           ,p_pension_dedn_ele_type_id  =>   p_pension_dedn_ele_type_id
           ,p_security_group_id         =>   p_security_group_id
           ,p_effective_date            =>   p_effective_date
           );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  l_return_status := hr_multi_message.get_return_status_disable;
  IF g_debug THEN
     hr_utility.set_location(' Leaving:' || l_proc,20);
  END IF;

  --
EXCEPTION
  WHEN hr_multi_message.error_message_exist THEN
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    ROLLBACK TO Delete_User_Template_Swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    IF g_debug THEN
       hr_utility.set_location(' Leaving:' || l_proc, 30);
    END IF;

  WHEN others THEN
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    ROLLBACK TO Delete_User_Template_Swi;
    IF hr_multi_message.unexpected_error_add(l_proc) THEN
       IF g_debug THEN
          hr_utility.set_location(' Leaving:' || l_proc,40);
       END IF;
       RAISE;
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    IF g_debug THEN
       hr_utility.set_location(' Leaving:' || l_proc,50);
    END IF;

END delete_user_template_swi;
--
END pqp_nl_pggm_template;

/
