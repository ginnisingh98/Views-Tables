--------------------------------------------------------
--  DDL for Package Body PQP_GB_PENSION_SCHEME_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PENSION_SCHEME_TEMPLATE" 
/* $Header: pqpgbped.pkb 120.4 2006/04/05 09:46:03 anshghos noship $ */
AS
   g_proc_name                VARCHAR2 (80)
                                          := 'pqp_gb_pension_scheme_template.';

   TYPE r_pension_types IS RECORD (
      pension_type_id               pqp_pension_types_f.pension_type_id%TYPE
     ,pension_type_name             pqp_pension_types_f.pension_type_name%TYPE
     ,effective_start_date          pqp_pension_types_f.effective_start_date%TYPE
     ,effective_end_date            pqp_pension_types_f.effective_end_date%TYPE
     ,pension_category              pqp_pension_types_f.pension_category%TYPE
     ,ee_contribution_percent       pqp_pension_types_f.ee_contribution_percent%TYPE
     ,er_contribution_percent       pqp_pension_types_f.er_contribution_percent%TYPE
     ,ee_contribution_fixed_rate    pqp_pension_types_f.ee_contribution_fixed_rate%TYPE
     ,er_contribution_fixed_rate    pqp_pension_types_f.er_contribution_fixed_rate%TYPE
     ,ee_contribution_bal_type_id   pqp_pension_types_f.ee_contribution_bal_type_id%TYPE
     ,er_contribution_bal_type_id   pqp_pension_types_f.er_contribution_bal_type_id%TYPE);

   TYPE t_pension_types IS TABLE OF r_pension_types
      INDEX BY BINARY_INTEGER;

   g_tab_pension_types_info   t_pension_types;

   TYPE t_number IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   g_tab_formula_ids          t_number;


/*========================================================================
 *                        CREATE_USER_TEMPLATE_LOW
 *=======================================================================*/
   FUNCTION create_user_template_low (
      p_pension_scheme_name       IN   VARCHAR2
     ,p_pension_year_start_dt     IN   DATE
     ,p_pension_category          IN   VARCHAR2
     ,p_pension_provider_id       IN   NUMBER
     ,p_pension_type_id           IN   NUMBER
     ,p_emp_deduction_method      IN   VARCHAR2
     ,p_ele_base_name             IN   VARCHAR2
     ,p_effective_start_date      IN   DATE
     ,p_ele_reporting_name        IN   VARCHAR2
     ,p_ele_classification_id     IN   NUMBER
     ,p_business_group_id         IN   NUMBER
     ,p_eer_deduction_method      IN   VARCHAR2
     ,p_scon_number               IN   VARCHAR2
     ,p_econ_number               IN   VARCHAR2 -- Bug 4108320
     ,p_additional_contribution   IN   VARCHAR2
     ,p_added_years               IN   VARCHAR2
     ,p_family_widower            IN   VARCHAR2
     ,p_fwc_added_years           IN   VARCHAR2
     ,p_scheme_reference_no       IN   VARCHAR2
     ,p_employer_reference_no     IN   VARCHAR2
     ,p_associated_ocp_ele_id     IN   NUMBER
     ,p_ele_description           IN   VARCHAR2
     ,p_pension_scheme_type       IN   VARCHAR2
     ,p_pensionable_sal_bal_id    IN   NUMBER
     ,p_third_party_only_flag     IN   VARCHAR2
     ,p_iterative_processing      IN   VARCHAR2
     ,p_arrearage_allowed         IN   VARCHAR2
     ,p_partial_deduction         IN   VARCHAR2
     ,p_termination_rule          IN   VARCHAR2
     ,p_standard_link             IN   VARCHAR2
     ,p_validate                  IN   BOOLEAN
   )
      RETURN NUMBER
   IS
      --


      /*---------------------------------------------------------------------------
       The input values are explained below : V-varchar2, D-Date, N-number
         Input-Name                  Type   Valid Values/Explaination
         ----------                  ----
         --------------------------------------------------------------------------
         p_pension_scheme_name       (V) - User i/p Scheme Name
         p_pension_year_start_dt     (D) - User i/p Date
         p_pension_category          (V) - LOV based i/p (OCP/AVC/SHP/FSAVC/PEP)
         p_pension_provider_ip       (N) - LOV based i/p
         p_pension_type_id           (N) - LOV based i/p
         p_emp_deduction_method      (V) - LOV based i/p (PE/FR/PEFR)
         p_ele_base_name             (V) - User i/p Base Name
         p_effective_start_date      (D) - User i/p Date
         p_ele_reporting_name        (V) - User i/p Reporting Name
         p_ele_classification_id     (N) - LOV based i/p
         p_business_group_id         (N) - User i/p Business Group
         p_eer_deduction_method      (V) - LOV based i/p (PE/FR/PEFR)
         p_scon_number               (V) - User i/p SCON
         p_econ_number               (V) - User i/p ECON
         p_additional_contribution   (V) - LOV based i/p (PE/FR/PEFR)
         p_added_years               (V) - LOV based i/p (PE/FR/PEFR)
         p_family_widower            (V) - LOV based i/p (PE/FR/PEFR)
         p_fwc_added_years           (V) - LOV based i/p (PE/FR/PEFR)
         p_scheme_reference_no       (V) - User i/p Scheme Reference Number
         p_employer_reference_no     (V) - User i/p Employer Reference Number
         p_associated_ocp_ele_id     (N) - LOV based i/p
         p_ele_description           (V) - User i/p Element Description
         p_pension_scheme_type       (V) - LOV based i/p (COSR/COMP)
         p_pensionable_sal_bal_id    (N) - LOV based i/p
         p_third_party_only_flag     (V) - Check box based i/p (Y/N) Default N
         p_iterative_processing      (V) - Check box based i/p (Y/N) Default N
         p_arrearage_allowed         (V) - Check box based i/p (Y/N) Default N
         p_partial_deduction         (V) - Check box based i/p (Y/N) Default N
         p_termination_rule          (V) - Radio button based i/p (A/F/L) Default L
         p_standard_link             (V) - Check box based i/p (Y/N) Default N
         p_validate                  (B) - TRUE or FALSE

      -----------------------------------------------------------------------------*/
      --
      l_template_id                     pay_shadow_element_types.template_id%TYPE;
      l_base_element_type_id            pay_template_core_objects.core_object_id%TYPE;
      l_base_fwc_element_type_id        pay_template_core_objects.core_object_id%TYPE;
      l_base_fwc_element_type_id_fix  pay_template_core_objects.core_object_id%TYPE;
      l_source_template_id              pay_element_templates.template_id%TYPE;
      l_object_version_number           pay_element_types_f.object_version_number%TYPE;
      l_proc_name                  VARCHAR2 (80)
                                :=    g_proc_name
                                   || 'create_user_template_low';
      l_element_type_id            NUMBER;
      l_fwc_element_type_id        NUMBER;
      l_fwc_element_type_id_fixed  NUMBER;
      l_balance_type_id            NUMBER;
      l_eei_element_type_id        NUMBER;
      l_ele_obj_ver_number         NUMBER;
      l_bal_obj_ver_number         NUMBER;
      i                            NUMBER;
      j                            NUMBER;
      l_eei_info_id                NUMBER;
      l_ovn_eei                    NUMBER;
      l_exists                     VARCHAR2 (1);

      TYPE t_ele_name IS TABLE OF pay_element_types_f.element_name%TYPE
         INDEX BY BINARY_INTEGER;

      l_ele_name                   t_ele_name;
      l_ele_new_name               t_ele_name;
      l_bal_name                   pay_balance_types.balance_name%TYPE;
      l_bal_new_name               pay_balance_types.balance_name%TYPE;
      l_ele_class_name             pay_element_classifications.classification_name%TYPE;
      l_exc_ocp_rule_id            VARCHAR2 (1);
      l_exc_ers_cent_rule_id       VARCHAR2 (1);
      l_exc_ers_fxd_rule_id        VARCHAR2 (1);
      l_exc_adl_cent_rule_id       VARCHAR2 (1);
      l_exc_adl_fxd_rule_id        VARCHAR2 (1);
      l_exc_ayr_cent_rule_id       VARCHAR2 (1);
      l_exc_ayr_fxd_rule_id        VARCHAR2 (1);

      -- for buy back added years for family widower
      l_exc_bb_fwc_cent_rule_id       VARCHAR2 (1);
      l_exc_bb_fwc_fxd_rule_id        VARCHAR2 (1);

      l_exc_fwd_cent_rule_id       VARCHAR2 (1);
      l_exc_fwd_fxd_rule_id        VARCHAR2 (1);
      l_exc_avc_rule_id            VARCHAR2 (1);
      l_exc_shp_rule_id            VARCHAR2 (1);
      l_exc_fsavc_rule_id          VARCHAR2 (1);
      l_exc_pep_rule_id            VARCHAR2 (1);
      l_exc_pre_tax_rule_id        VARCHAR2 (1);
      l_exc_ees_cram_rule_id       VARCHAR2 (1);
      l_exc_ees_cent_rule_id       VARCHAR2 (1);
      l_exc_ers_rule_id            VARCHAR2 (1);
      l_exc_adl_rule_id            VARCHAR2 (1);
      l_exc_ayr_rule_id            VARCHAR2 (1);

      -- for buy back added years for family widower
      l_exc_bb_fwc_rule_id            VARCHAR2 (1);

      l_exc_fwd_rule_id            VARCHAR2 (1);
      l_exc_ssal_rule_id           VARCHAR2 (1);
      l_exc_vol_con_rule_id        VARCHAR2 (1);
      l_exc_fsavc_eer_rule_id      VARCHAR2 (1);
      l_cont_iv_name               pay_input_values_f.NAME%TYPE;
      l_skip_formula               ff_formulas_f.formula_name%TYPE;
      l_iv_default_value           pay_input_values_f.default_value%TYPE;
      l_base_processing_priority   pay_element_types_f.processing_priority%TYPE;
      l_iterative_flag             pay_element_types_f.iterative_flag%TYPE;
      l_iterative_priority         pay_element_types_f.iterative_priority%TYPE;
      l_iterative_formula          ff_formulas_f.formula_name%TYPE;
      l_sub_class_name             pay_element_classifications.classification_name%TYPE;
      l_pensionable_sal_bal_id     NUMBER;
      l_pensionable_sal_bal_name   pay_balance_types.balance_name%TYPE;
      l_arrearage_allowed          VARCHAR2 (1)
                                             := NVL (p_arrearage_allowed, 'N');
      l_partial_deduction          VARCHAR2 (1)
                                             := NVL (p_partial_deduction, 'N');
      l_standard_link              VARCHAR2 (1)        := NVL (
                                                             p_standard_link
                                                            ,'N'
                                                          );
      l_format_base_name           pay_element_templates.base_name%TYPE
                        := UPPER (TRANSLATE (TRIM (p_ele_base_name), ' ', '_'));
      l_ees_cont_formula           ff_formulas_f.formula_name%TYPE
   :=    l_format_base_name
      || '_EES_'
      || p_pension_category
      || '_CONTRIBUTION_FORMULA';
      l_ees_cont_formula_id        ff_formulas_f.formula_id%TYPE;
      l_ers_cont_formula           ff_formulas_f.formula_name%TYPE
                :=    l_format_base_name
                   || '_ERS_PENSION_CONTRIBUTION_FORMULA';
      l_ers_cont_formula_id        ff_formulas_f.formula_id%TYPE;
      l_adl_cont_formula           ff_formulas_f.formula_name%TYPE
                 :=    l_format_base_name
                    || '_ADDITIONAL_CONTRIBUTION_FORMULA';
      l_adl_cont_formula_id        ff_formulas_f.formula_id%TYPE;
      l_ayr_cont_formula           ff_formulas_f.formula_name%TYPE
                :=    l_format_base_name
                   || '_ADDED_YEARS_CONTRIBUTION_FORMULA';
      l_ayr_cont_formula_id        ff_formulas_f.formula_id%TYPE;

      l_fwd_cont_formula           ff_formulas_f.formula_name%TYPE
             :=    l_format_base_name
                || '_FAMILY_WIDOWER_CONTRIBUTION_FORMULA';
      l_fwd_cont_formula_id        ff_formulas_f.formula_id%TYPE;

      l_bb_fwc_cont_formula           ff_formulas_f.formula_name%TYPE
                :=    l_format_base_name
                   || '_EES_BUY_BACK_FWC_CONTRIBUTION_FORMULA';
      l_bb_fwc_cont_formula_id        ff_formulas_f.formula_id%TYPE;


      l_search_string              VARCHAR2 (2000);
      l_replace_string             VARCHAR2 (2000);
      l_associated_ocp_base_name   VARCHAR2 (100);
      -- Iterative rule variables

      l_iterative_rule_id          NUMBER;
      l_ovn_itr                    NUMBER;
      l_itr_effective_start_dt     DATE;
      l_itr_effective_end_dt       DATE;
      l_itr_result_name            pay_iterative_rules_f.result_name%TYPE
                                                                := 'L_STOPPER';
      l_itr_rule_type              pay_iterative_rules_f.iterative_rule_type%TYPE
                                                                        := 'S';
      l_exc_itr_rule_id            VARCHAR2 (1);
      l_emp_deduction_method       hr_lookups.lookup_code%TYPE
                                                    := p_emp_deduction_method;

      --

      -- Cursor to retrieve the shadow element information
      CURSOR csr_get_shadow_ele_info (c_ele_name VARCHAR2)
      IS
         SELECT element_type_id, object_version_number
           FROM pay_shadow_element_types
          WHERE template_id = l_template_id AND element_name = c_ele_name;

      -- Cursor to retrieve the shadow balance information
      CURSOR csr_get_shadow_bal_info (c_bal_name VARCHAR2)
      IS
         SELECT balance_type_id, object_version_number
           FROM pay_shadow_balance_types
          WHERE template_id = l_template_id AND balance_name = c_bal_name;

      -- Cursor to check unique base name
      CURSOR csr_chk_uniq_base_name
      IS
         SELECT 'X'
           FROM pay_element_templates
          WHERE template_name = g_template_name
            AND business_group_id = p_business_group_id
            AND template_type = 'U'
            AND UPPER (base_name) = UPPER (p_ele_base_name);


--
--======================================================================
--|-------------------------< get_template_id >------------------------|
--======================================================================
      FUNCTION get_template_id (p_legislation_code IN VARCHAR2)
         RETURN NUMBER
      IS
         --

         l_template_id     NUMBER;
         l_template_name   VARCHAR2 (80);
         l_proc_name       VARCHAR2 (72) :=    g_proc_name
                                            || 'get_template_id';

         --
         CURSOR csr_get_temp_id
         IS
            SELECT template_id
              FROM pay_element_templates
             WHERE template_name = g_template_name
               AND legislation_code = p_legislation_code
               AND template_type = 'T'
               AND business_group_id IS NULL;
      --
      BEGIN
         --
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);
         --

         OPEN csr_get_temp_id;
         FETCH csr_get_temp_id INTO l_template_id;
         CLOSE csr_get_temp_id;
         --
         hr_utility.set_location (   'l_template_id: '||l_template_id, 25);

         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 30);
         --
         RETURN l_template_id;
      --
      END get_template_id;


--
--=======================================================================
--|----------------------------< get_object_id >------------------------|
--=======================================================================
      FUNCTION get_object_id (
         p_object_type   IN   VARCHAR2
        ,p_object_name   IN   VARCHAR2
      )
         RETURN NUMBER
      IS
         --
         l_object_id   NUMBER        := NULL;
         l_proc_name   VARCHAR2 (72) :=    g_proc_name
                                        || 'get_object_id';

         --
         CURSOR csr_get_ele_id
         IS
            SELECT element_type_id
              FROM pay_element_types_f
             WHERE element_name = p_object_name
               AND business_group_id = p_business_group_id
               AND p_effective_start_date BETWEEN effective_start_date
                                              AND effective_end_date;

         --
         CURSOR csr_get_bal_id
         IS
            SELECT ptco.core_object_id
              FROM pay_shadow_balance_types psbt
                  ,pay_template_core_objects ptco
             WHERE psbt.template_id = l_template_id
               AND psbt.balance_name = p_object_name
               AND ptco.template_id = psbt.template_id
               AND ptco.shadow_object_id = psbt.balance_type_id;
      --
      BEGIN
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);

         --
         IF p_object_type = 'ELE'
         THEN
            OPEN csr_get_ele_id;
            FETCH csr_get_ele_id INTO l_object_id;

            IF csr_get_ele_id%NOTFOUND
            THEN
               CLOSE csr_get_ele_id;
               fnd_message.set_name ('PQP', 'PQP_230933_ELE_TYPE_NOTFOUND');
               fnd_message.set_token ('ELEMENT_TYPE', p_object_name);
               fnd_message.raise_error;
            END IF; -- End if of csr ele id row not found check ...
            hr_utility.set_location (   'l_object_id (ELE) : '||l_object_id, 15);

            CLOSE csr_get_ele_id;
         ELSIF p_object_type = 'BAL'
         THEN
            OPEN csr_get_bal_id;
            FETCH csr_get_bal_id INTO l_object_id;

            IF csr_get_bal_id%NOTFOUND
            THEN
               CLOSE csr_get_bal_id;
               fnd_message.set_name ('PQP', 'PQP_230932_BAL_TYPE_NOTFOUND');
               fnd_message.set_token ('BALANCE_TYPE', p_object_name);
               fnd_message.raise_error;
            END IF; -- End if of csr bal id row not found check ...
            hr_utility.set_location (   'l_object_id (BAL) : '||l_object_id, 15);

            CLOSE csr_get_bal_id;
         END IF; -- End if of object type = ele check ...

         --
         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 20);
         --
         RETURN l_object_id;
      --
      END get_object_id;


 --
--=======================================================================
--|-------------------------< update_ipval_defval >---------------------|
--=======================================================================
      PROCEDURE update_ipval_defval (
         p_ele_name    IN   VARCHAR2
        ,p_ip_name     IN   VARCHAR2
        ,p_def_value   IN   VARCHAR2
      )
      IS
         CURSOR csr_getinput (c_ele_name VARCHAR2, c_iv_name VARCHAR2)
         IS
            SELECT piv.input_value_id, piv.NAME, piv.element_type_id
              FROM pay_input_values_f piv, pay_element_types_f pet
             WHERE element_name = c_ele_name
               AND piv.element_type_id = pet.element_type_id
               AND piv.business_group_id = p_business_group_id
               AND piv.NAME = c_iv_name;

         CURSOR csr_updinput (c_ip_id NUMBER, c_element_type_id NUMBER)
         IS
            SELECT     ROWID
                  FROM pay_input_values_f
                 WHERE input_value_id = c_ip_id
                   AND element_type_id = c_element_type_id
            FOR UPDATE NOWAIT;

         csr_getinput_rec   csr_getinput%ROWTYPE;
         csr_updinput_rec   csr_updinput%ROWTYPE;
         l_proc_name        VARCHAR2 (72)
                                     :=    g_proc_name
                                        || 'update_ipval_defval';
      --
      BEGIN
         --

         --
         hr_utility.set_location (   'Entering '
                                  || l_proc_name, 10);
         --
         OPEN csr_getinput (p_ele_name, p_ip_name);

         LOOP
            FETCH csr_getinput INTO csr_getinput_rec;
            EXIT WHEN csr_getinput%NOTFOUND;
            --
            hr_utility.set_location (l_proc_name, 20);
            --

            OPEN csr_updinput (
               csr_getinput_rec.input_value_id
              ,csr_getinput_rec.element_type_id
            );

            LOOP
               FETCH csr_updinput INTO csr_updinput_rec;
               EXIT WHEN csr_updinput%NOTFOUND;
               --
               hr_utility.set_location (l_proc_name, 30);

               --

               UPDATE pay_input_values_f
                  SET default_value = p_def_value
                WHERE ROWID = csr_updinput_rec.ROWID;
            END LOOP;

            CLOSE csr_updinput;
         END LOOP;

         CLOSE csr_getinput;
         --
         hr_utility.set_location (   'Leaving '
                                  || l_proc_name, 40);
      --

      END update_ipval_defval;

      --

-- ---------------------------------------------------------------------
-- |-----------------------< Compile_Formula >--------------------------|
-- ---------------------------------------------------------------------
      PROCEDURE compile_formula (p_element_type_id IN NUMBER)
      IS

-- --------------------------------------------------------
-- Cursor to get the formula details necessary to compile
-- --------------------------------------------------------
         CURSOR csr_get_ff_id (c_element_type_id NUMBER)
         IS
            SELECT fra.formula_id, fra.formula_name, fty.formula_type_id
                  ,fty.formula_type_name
              FROM ff_formulas_f fra
                  ,ff_formula_types fty
                  ,pay_status_processing_rules_f spr
             WHERE fty.formula_type_id = fra.formula_type_id
               AND fra.formula_id = spr.formula_id
               AND spr.assignment_status_type_id IS NULL
               AND spr.element_type_id = c_element_type_id
               AND p_effective_start_date BETWEEN fra.effective_start_date
                                              AND fra.effective_end_date
               AND p_effective_start_date BETWEEN spr.effective_start_date
                                              AND spr.effective_end_date;

         l_request_id      NUMBER;
         l_er_request_id   NUMBER;
         l_proc_name       VARCHAR2 (80) :=    g_proc_name
                                            || 'compile_formula';
      BEGIN
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);


-- ------------------------------------------------------------
-- Query formula info (ie. the formula attached to this
-- element's Standard status proc rule.
-- ------------------------------------------------------------
         FOR fra_rec IN csr_get_ff_id (
                           c_element_type_id             => p_element_type_id
                        )
         LOOP
            hr_utility.set_location (
                  '..FF Name :'
               || fra_rec.formula_name
              ,15
            );
            hr_utility.set_location (
                  '..FF Type Name :'
               || fra_rec.formula_type_name
              ,20
            );


-- ----------------------------------------------
-- Submit the request to compile the formula
-- ----------------------------------------------

            -- Check whether the formula id is in the collection
            -- if so do not submit a request as the compiled info
            -- should exist
            IF NOT g_tab_formula_ids.EXISTS (fra_rec.formula_id)
            THEN
               l_request_id               :=
                     fnd_request.submit_request (
                        application                   => 'FF'
                       ,program                       => 'SINGLECOMPILE'
                       ,argument1                     => fra_rec.formula_type_name --Oracle Payroll
                       ,argument2                     => fra_rec.formula_name
                     ); --formula name
               hr_utility.set_location (
                     '..Request Id :'
                  || l_request_id
                 ,25
               );
               -- store it in the collection
               g_tab_formula_ids (fra_rec.formula_id) := fra_rec.formula_id;
            END IF; -- End if of formula id exists in collection check ...
         END LOOP;

         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 30);
      END compile_formula;


-- ----------------------------------------------------------------------------
-- |------------------------< chk_scheme_prefix >-----------------------------|
-- ----------------------------------------------------------------------------
      PROCEDURE chk_scheme_prefix (p_scheme_prefix IN VARCHAR2)
      IS
         l_element_name   VARCHAR2 (100) := p_scheme_prefix;
         l_output         VARCHAR2 (100);
         l_rgeflg         VARCHAR2 (100);
      BEGIN
         hr_utility.set_location (   'Entering : chk_scheme_prefix ', 10);

         hr_chkfmt.checkformat (
            VALUE                         => l_element_name
           ,format                        => 'PAY_NAME'
           ,output                        => l_output
           ,MINIMUM                       => NULL
           ,maximum                       => NULL
           ,nullok                        => 'N'
           ,rgeflg                        => l_rgeflg
           ,curcode                       => NULL
         );

         hr_utility.set_location (   'Exiting : chk_scheme_prefix ', 20);

      EXCEPTION
         WHEN OTHERS
         THEN
            fnd_message.set_name ('PQP', 'PQP_230923_SCHEME_PREFIX_ERR');
            fnd_message.raise_error;
      END chk_scheme_prefix;

      --

--
--==============================================================================
--|-----------------------------< get_balance_info >---------------------------|
--==============================================================================
      FUNCTION get_balance_info (p_balance_type_id IN NUMBER)
         RETURN VARCHAR2
      IS
            --
         -- Cursor to retrieve the balance information
         CURSOR csr_get_bal_info
         IS
            SELECT balance_name
              FROM pay_balance_types
             WHERE balance_type_id = p_balance_type_id
               AND (   (    business_group_id IS NOT NULL
                        AND business_group_id = p_business_group_id
                       )
                    OR (    legislation_code IS NOT NULL
                        AND legislation_code = g_template_leg_code
                       )
                    OR (business_group_id IS NULL AND legislation_code IS NULL)
                   );

         l_proc_name      VARCHAR2 (80)          :=    g_proc_name
                                                    || 'get_balance_info';
         l_balance_name   pay_balance_types.balance_name%TYPE;
      --

      BEGIN
         --
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);
         --

         OPEN csr_get_bal_info;
         FETCH csr_get_bal_info INTO l_balance_name;

         IF csr_get_bal_info%NOTFOUND
         THEN
            CLOSE csr_get_bal_info;
            fnd_message.set_name ('PQP', 'PQP_230549_BAL_TYPE_NOT_FOUND');
            fnd_message.raise_error;
         END IF; -- End if of row found check ...

         hr_utility.set_location (   'l_balance_name : '|| l_balance_name, 20);

         CLOSE csr_get_bal_info;
         --
         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 20);
         RETURN l_balance_name;
      --
      END get_balance_info;

      --

--
--==============================================================================
--|-----------------------< get_ele_classification_info >----------------------|
--==============================================================================
      PROCEDURE get_ele_classification_info (
         p_classification_id     IN              NUMBER
        ,p_classification_name   OUT NOCOPY      VARCHAR2
        ,p_default_priority      OUT NOCOPY      NUMBER
      )
      IS
         --
         CURSOR csr_get_ele_class_info
         IS
            SELECT classification_name, default_priority
              FROM pay_element_classifications
             WHERE classification_id = p_classification_id;

         l_proc_name        VARCHAR2 (80)
                             :=    g_proc_name
                                || 'get_ele_classification_info';
         l_ele_class_info   csr_get_ele_class_info%ROWTYPE;
      --

      BEGIN
         --
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);
         --

         OPEN csr_get_ele_class_info;
         FETCH csr_get_ele_class_info INTO l_ele_class_info;

         IF csr_get_ele_class_info%FOUND
         THEN
            p_classification_name      :=
                                         l_ele_class_info.classification_name;
            p_default_priority         := l_ele_class_info.default_priority;
         END IF; -- End if of row found check ...

         hr_utility.set_location (   'l_ele_class_info : '|| l_ele_class_info.classification_name, 20);

         CLOSE csr_get_ele_class_info;
         --
         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 20);
      --

      EXCEPTION
         WHEN OTHERS
         THEN
            hr_utility.set_location (
                  'Others Exception: '
               || l_proc_name
              ,30
            );
            hr_utility.set_location (   'Leaving: '
                                     || l_proc_name, 40);
            p_classification_name      := NULL;
            p_default_priority         := NULL;
            RAISE;
      END get_ele_classification_info;


  --
--
--==============================================================================
--|--------------------------< get_iterative_priority >------------------------|
--==============================================================================
      FUNCTION get_iterative_priority (p_element_type_id IN NUMBER)
         RETURN NUMBER
      IS
         --
         CURSOR csr_get_prs_priority
         IS
            SELECT relative_processing_priority
              FROM pay_shadow_element_types
             WHERE element_type_id = p_element_type_id;

         l_proc_name             VARCHAR2 (80)
                                  :=    g_proc_name
                                     || 'get_iterative_priority';
         l_processing_priority   NUMBER;
         l_iterative_priority    NUMBER;
      --
      BEGIN
         --
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);
         --
         OPEN csr_get_prs_priority;
         FETCH csr_get_prs_priority INTO l_processing_priority;
         CLOSE csr_get_prs_priority;
         l_iterative_priority       :=   400
                                       - l_processing_priority;
         --
         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 20);
         --

         RETURN l_iterative_priority;
      --
      END get_iterative_priority;

      --
--
--==============================================================================
--|---------------------------< get_pension_type_info >------------------------|
--==============================================================================
      FUNCTION get_pension_type_info
         RETURN t_pension_types
      IS
         --
         CURSOR csr_get_pension_type_info
         IS
            SELECT pension_type_id, pension_type_name, effective_start_date
                  ,effective_end_date, pension_category
                  ,ee_contribution_percent, er_contribution_percent
                  ,ee_contribution_fixed_rate, er_contribution_fixed_rate
                  ,ee_contribution_bal_type_id, er_contribution_bal_type_id
              FROM pqp_pension_types_f
             WHERE pension_type_id = p_pension_type_id
               AND p_effective_start_date BETWEEN effective_start_date
                                              AND effective_end_date
               AND (   (    business_group_id IS NOT NULL
                        AND business_group_id = p_business_group_id
                       )
                    OR (    legislation_code IS NOT NULL
                        AND legislation_code = g_template_leg_code
                       )
                    OR (business_group_id IS NULL AND legislation_code IS NULL)
                   );

         l_proc_name           VARCHAR2 (80)
                                        :=    g_proc_name
                                           || 'get_pension_type';
         l_pension_type_info   csr_get_pension_type_info%ROWTYPE;
         l_tab_pension_types   t_pension_types;
      --
      BEGIN
         --
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);
         --

         OPEN csr_get_pension_type_info;
         FETCH csr_get_pension_type_info INTO l_pension_type_info;

         IF csr_get_pension_type_info%NOTFOUND
         THEN
            CLOSE csr_get_pension_type_info;
            fnd_message.set_name ('PQP', 'PQP_230934_PEN_TYPE_ID_INVALID');
            fnd_message.raise_error;
         END IF; -- End if of pension type row found check ...

         CLOSE csr_get_pension_type_info;

         hr_utility.set_location (   'l_pension_type_info : '|| l_pension_type_info.pension_type_name, 20);


         l_tab_pension_types (p_pension_type_id).pension_type_id :=
                                           l_pension_type_info.pension_type_id;
         l_tab_pension_types (p_pension_type_id).pension_type_name :=
                                         l_pension_type_info.pension_type_name;
         l_tab_pension_types (p_pension_type_id).effective_start_date :=
                                      l_pension_type_info.effective_start_date;
         l_tab_pension_types (p_pension_type_id).effective_end_date :=
                                        l_pension_type_info.effective_end_date;
         l_tab_pension_types (p_pension_type_id).pension_category :=
                                          l_pension_type_info.pension_category;
         l_tab_pension_types (p_pension_type_id).ee_contribution_percent :=
                                   l_pension_type_info.ee_contribution_percent;
         l_tab_pension_types (p_pension_type_id).er_contribution_percent :=
                                   l_pension_type_info.er_contribution_percent;
         l_tab_pension_types (p_pension_type_id).ee_contribution_fixed_rate :=
                                l_pension_type_info.ee_contribution_fixed_rate;
         l_tab_pension_types (p_pension_type_id).er_contribution_fixed_rate :=
                                l_pension_type_info.er_contribution_fixed_rate;
         l_tab_pension_types (p_pension_type_id).ee_contribution_bal_type_id :=
                               l_pension_type_info.ee_contribution_bal_type_id;
         l_tab_pension_types (p_pension_type_id).er_contribution_bal_type_id :=
                               l_pension_type_info.er_contribution_bal_type_id;
         --
         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 20);
         --

         RETURN l_tab_pension_types;
      END get_pension_type_info;


  --
--
--==============================================================================
--|---------------------------< insert_validate >------------------------------|
--==============================================================================
      PROCEDURE insert_validate
      IS
         --
         -- Cursor to check whether provider exists

         CURSOR csr_chk_provider_exists
         IS
            SELECT 'X'
              FROM hr_all_organization_units hou
                  ,hr_organization_information hoi
             WHERE hou.organization_id = p_pension_provider_id
               AND (   hou.business_group_id = p_business_group_id
                    OR hou.business_group_id IS NULL
                   )
               AND p_effective_start_date BETWEEN date_from
                                              AND NVL (
                                                     date_to
                                                    ,p_effective_start_date
                                                  )
               AND hoi.organization_id = hou.organization_id
               AND hoi.org_information_context = 'CLASS'
               AND hoi.org_information1 = 'FR_PENSION'
               AND hoi.org_information2 = 'Y';

         -- Cursor to check whether provider supports this pension type

         CURSOR csr_chk_pens_type_in_prov
         IS
            SELECT 'X'
              FROM hr_organization_information
             WHERE organization_id = p_pension_provider_id
               AND org_information_context = 'PQP_GB_PENSION_TYPES_INFO'
               AND org_information1 = p_pension_type_id;

         -- Cursor to check the associated OCP element validity

         CURSOR csr_chk_ocp_ele_info (c_element_type_id NUMBER)
         IS
            SELECT 'X'
              FROM pay_element_type_extra_info eeit, pay_element_types_f pet
             WHERE pet.element_type_id = c_element_type_id
               AND (   (    pet.business_group_id IS NOT NULL
                        AND pet.business_group_id = p_business_group_id
                       )
                    OR (    pet.legislation_code IS NOT NULL
                        AND pet.legislation_code = g_template_leg_code
                       )
                    OR (    pet.business_group_id IS NULL
                        AND pet.legislation_code IS NULL
                       )
                   )
               AND p_effective_start_date BETWEEN pet.effective_start_date
                                              AND pet.effective_end_date
               AND eeit.element_type_id = pet.element_type_id
               AND eeit.information_type = 'PQP_GB_PENSION_SCHEME_INFO'
               AND eeit.eei_information4 = 'OCP'
               AND eeit.eei_information12 IS NULL;

         -- Cursor to get ECON number
         CURSOR csr_get_econ
         IS
            SELECT org_information7
              FROM hr_organization_information
             WHERE organization_id = p_business_group_id
               AND org_information_context = 'Tax Details References';

         -- BUG 4108320
         -- Cursor to get translated value of SCON / ECON
         CURSOR csr_translate_escon (c_number VARCHAR2)
         IS
            SELECT TRANSLATE (
                      UPPER (c_number)
                     ,'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
                     ,'AAAAAAAAAAAAAAAAAAAAAAAAAA9999999999'
                   )
              FROM DUAL;


         l_proc_name     VARCHAR2 (80)            :=    g_proc_name
                                                     || 'insert_validate';
         l_exists        VARCHAR2 (1);
         l_econ_number   hr_organization_information.org_information7%TYPE;
         l_scon_format   VARCHAR2 (9)                                    := 'A9999999A';
         l_econ_format   VARCHAR2 (9)                                    := 'E9999999A';
         l_scon_number   pay_element_type_extra_info.eei_information1%TYPE;
      --
      BEGIN
         --
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);
         --
         -- Check mandatory arguments first
         -- Pension Scheme Name
         hr_utility.set_location('Pension Scheme Name',15);

         hr_api.mandatory_arg_error (
            p_api_name                    => l_proc_name
           ,p_argument                    => 'Pension Scheme Name'
           ,p_argument_value              => p_pension_scheme_name
         );

         -- Pension Year Start Date
         hr_utility.set_location('Pension Year Start Date',15);
         hr_api.mandatory_arg_error (
            p_api_name                    => l_proc_name
           ,p_argument                    => 'Pension Year Start Date'
           ,p_argument_value              => p_pension_year_start_dt
         );

         -- Effective Start Date
         hr_utility.set_location('Effective Start Date',15);
         hr_api.mandatory_arg_error (
            p_api_name                    => l_proc_name
           ,p_argument                    => 'Effective Start Date'
           ,p_argument_value              => p_effective_start_date
         );

         hr_utility.set_location('Pension Category',15);
         -- Pension Category
         hr_api.mandatory_arg_error (
            p_api_name                    => l_proc_name
           ,p_argument                    => 'Pension Category'
           ,p_argument_value              => p_pension_category
         );

         hr_utility.set_location('Pension Provider ID',15);
         -- Pension Provider
         hr_api.mandatory_arg_error (
            p_api_name                    => l_proc_name
           ,p_argument                    => 'Pension Provider ID'
           ,p_argument_value              => p_pension_provider_id
         );

         hr_utility.set_location('Pension Type ID',15);
         -- Pension Type
         hr_api.mandatory_arg_error (
            p_api_name                    => l_proc_name
           ,p_argument                    => 'Pension Type ID'
           ,p_argument_value              => p_pension_type_id
         );

         hr_utility.set_location('Employee Deduction Method',15);
         -- Employee Deduction Method
         hr_api.mandatory_arg_error (
            p_api_name                    => l_proc_name
           ,p_argument                    => 'Employee Deduction Method'
           ,p_argument_value              => l_emp_deduction_method
         );

         hr_utility.set_location('Scheme Prefix',15);
         -- Element Base Name
         hr_api.mandatory_arg_error (
            p_api_name                    => l_proc_name
           ,p_argument                    => 'Scheme Prefix'
           ,p_argument_value              => p_ele_base_name
         );

         hr_utility.set_location('Reporting Name',15);
         -- Reporting Name
         hr_api.mandatory_arg_error (
            p_api_name                    => l_proc_name
           ,p_argument                    => 'Reporting Name'
           ,p_argument_value              => p_ele_reporting_name
         );

         hr_utility.set_location('Classification',15);
         -- Element Classification
         hr_api.mandatory_arg_error (
            p_api_name                    => l_proc_name
           ,p_argument                    => 'Classification'
           ,p_argument_value              => p_ele_classification_id
         );

         -- For AVC p_associated_ocp_ele_id is mandatory
         IF p_pension_category = 'AVC'
         THEN
            hr_api.mandatory_arg_error (
               p_api_name                    => l_proc_name
              ,p_argument                    => 'Associated OCP Scheme'
              ,p_argument_value              => p_associated_ocp_ele_id
            );
         END IF; -- End if of pension category is AVC check ...

         --
         hr_utility.set_location (l_proc_name, 20);

         --
         -- Check pension category lookup code
         --

         IF hr_api.not_exists_in_hr_lookups (
               p_effective_date              => p_effective_start_date
              ,p_lookup_type                 => 'PQP_PENSION_CATEGORY'
              ,p_lookup_code                 => p_pension_category
            )
         THEN
            -- Invalid Pension Category
            fnd_message.set_name ('PAY', 'HR_52966_INVALID_LOOKUP');
            fnd_message.set_token ('COLUMN', 'Pension Category');
            fnd_message.set_token ('LOOKUP_TYPE', 'PQP_PENSION_CATEGORY');

            hr_utility.set_location (l_proc_name, 25);

            fnd_message.raise_error;
         END IF; -- End if of not exists in lookup check ...

         -- Check Pension Provider exists for this BG
         --
         hr_utility.set_location (l_proc_name, 30);
         --

         OPEN csr_chk_provider_exists;
         FETCH csr_chk_provider_exists INTO l_exists;

         IF csr_chk_provider_exists%NOTFOUND
         THEN
            CLOSE csr_chk_provider_exists;
            fnd_message.set_name ('PQP', 'PQP_230936_PEN_PROV_ID_INVALID');
            fnd_message.raise_error;
         END IF; -- End if of provider exists row not found check ...

         CLOSE csr_chk_provider_exists;
         -- Get Pension Type Info
         --
         hr_utility.set_location (l_proc_name, 30);

         --

         IF    NOT g_tab_pension_types_info.EXISTS (p_pension_type_id)
            OR -- Check the effectiveness as this is DT table
              (    g_tab_pension_types_info.EXISTS (p_pension_type_id)
               AND NOT (p_effective_start_date
                           BETWEEN g_tab_pension_types_info (
                                      p_pension_type_id
                                   ).effective_start_date
                               AND g_tab_pension_types_info (
                                      p_pension_type_id
                                   ).effective_end_date
                       )
              )
         THEN
            g_tab_pension_types_info   := get_pension_type_info;
         END IF; -- End if of pension type info exists

         -- Validate whether the pension type supports the pension category
         IF g_tab_pension_types_info (p_pension_type_id).pension_category <>
                                                            p_pension_category
         THEN
            fnd_message.set_name ('PQP', 'PQP_230938_PEN_TYP_CAT_NOTSUP');
            fnd_message.set_token (
               'PENSION_CATEGORY'
              ,hr_general.decode_lookup (
                  'PQP_PENSION_CATEGORY'
                 ,p_pension_category
               )
            );
            fnd_message.raise_error;
         END IF; -- End if of pension category in pension type matches with parameter check ...

         -- Check pension type is supported by this pension provider
         --
         hr_utility.set_location (l_proc_name, 40);
         --

         OPEN csr_chk_pens_type_in_prov;
         FETCH csr_chk_pens_type_in_prov INTO l_exists;

         IF csr_chk_pens_type_in_prov%NOTFOUND
         THEN
            CLOSE csr_chk_pens_type_in_prov;
            fnd_message.set_name ('PQP', 'PQP_230937_PEN_TYP_NOTIN_PROV');
            fnd_message.raise_error;
         END IF; -- End if of pension type in provider not found check ...

         CLOSE csr_chk_pens_type_in_prov;
         -- Check employee deduction method in lookup
         --
         hr_utility.set_location (l_proc_name, 50);

         --
         IF hr_api.not_exists_in_hr_lookups (
               p_effective_date              => p_effective_start_date
              ,p_lookup_type                 => 'PQP_PENSION_DEDUCTION_METHOD'
              ,p_lookup_code                 => l_emp_deduction_method
            )
         THEN
            -- Invalid Deduction Method
            fnd_message.set_name ('PAY', 'HR_52966_INVALID_LOOKUP');
            fnd_message.set_token ('COLUMN', 'Employee Deduction Method');
            fnd_message.set_token (
               'LOOKUP_TYPE'
              ,'PQP_PENSION_DEDUCTION_METHOD'
            );
            fnd_message.raise_error;
         END IF; -- End if of not exists in lookup check ...

         -- Check employer deduction method in lookup
         --
         hr_utility.set_location (l_proc_name, 60);

         --
         IF p_eer_deduction_method IS NOT NULL
         THEN
            IF hr_api.not_exists_in_hr_lookups (
                  p_effective_date              => p_effective_start_date
                 ,p_lookup_type                 => 'PQP_PENSION_DEDUCTION_METHOD'
                 ,p_lookup_code                 => p_eer_deduction_method
               )
            THEN
               -- Invalid Deduction Method
               fnd_message.set_name ('PAY', 'HR_52966_INVALID_LOOKUP');
               fnd_message.set_token ('COLUMN', 'Employer Deduction Method');
               fnd_message.set_token (
                  'LOOKUP_TYPE'
                 ,'PQP_PENSION_DEDUCTION_METHOD'
               );
               fnd_message.raise_error;
            END IF; -- End if of not exists in lookup check ...
         END IF; -- End if of employer deduction method specified check ...

         -- NOT required now
         -- Check scon if pension category is OCP
         --
--          hr_utility.set_location (l_proc_name, 70);
--
--          --
--
--          IF p_pension_category = 'OCP'
--          THEN
--             -- SCON
--             hr_api.mandatory_arg_error (
--                p_api_name                    => l_proc_name
--               ,p_argument                    => 'SCON'
--               ,p_argument_value              => p_scon_number
--             );
--          END IF; -- End if of pension category is OCP check ...

         -- Check deduction method codes for Additional contributions
         --
         hr_utility.set_location (l_proc_name, 80);

         --

         IF p_additional_contribution IS NOT NULL
         THEN
            IF hr_api.not_exists_in_hr_lookups (
                  p_effective_date              => p_effective_start_date
                 ,p_lookup_type                 => 'PQP_PENSION_DEDUCTION_METHOD'
                 ,p_lookup_code                 => p_additional_contribution
               )
            THEN
               -- Invalid Deduction Method
               fnd_message.set_name ('PAY', 'HR_52966_INVALID_LOOKUP');
               fnd_message.set_token (
                  'COLUMN'
                 ,'Additional Contribution Deduction Method'
               );
               fnd_message.set_token (
                  'LOOKUP_TYPE'
                 ,'PQP_PENSION_DEDUCTION_METHOD'
               );
               fnd_message.raise_error;
            END IF; -- End if of not exists in lookup check ...
         END IF; -- End if of additional contribution deduction method specified check ...

         -- Check deduction method codes for Addded Years contributions
         --
         hr_utility.set_location (l_proc_name, 90);

         --

         IF p_added_years IS NOT NULL
         THEN
            IF hr_api.not_exists_in_hr_lookups (
                  p_effective_date              => p_effective_start_date
                 ,p_lookup_type                 => 'PQP_PENSION_DEDUCTION_METHOD'
                 ,p_lookup_code                 => p_added_years
               )
            THEN
               -- Invalid Deduction Method
               fnd_message.set_name ('PAY', 'HR_52966_INVALID_LOOKUP');
               fnd_message.set_token (
                  'COLUMN'
                 ,'Added Years Deduction Method'
               );
               fnd_message.set_token (
                  'LOOKUP_TYPE'
                 ,'PQP_PENSION_DEDUCTION_METHOD'
               );
               fnd_message.raise_error;
            END IF; -- End if of not exists in lookup check ...
         END IF; -- End if of added years deduction method specified check ...

         -- Check deduction method codes for Family Widower
         --
         hr_utility.set_location (l_proc_name, 100);

         --

         IF p_family_widower IS NOT NULL
         THEN
            IF hr_api.not_exists_in_hr_lookups (
                  p_effective_date              => p_effective_start_date
                 ,p_lookup_type                 => 'PQP_PENSION_DEDUCTION_METHOD'
                 ,p_lookup_code                 => p_family_widower
               )
            THEN
               -- Invalid Deduction Method
               fnd_message.set_name ('PAY', 'HR_52966_INVALID_LOOKUP');
               fnd_message.set_token (
                  'COLUMN'
                 ,'Family Widower Deduction Method'
               );
               fnd_message.set_token (
                  'LOOKUP_TYPE'
                 ,'PQP_PENSION_DEDUCTION_METHOD'
               );
               fnd_message.raise_error;
            END IF; -- End if of not exists in lookup check ...
         END IF; -- End if of family widower contribution deduction method specified check ...


        -- Check deduction method codes for Family Widower Addded Years contributions
         --
         hr_utility.set_location (l_proc_name, 90);

         --

         IF p_fwc_added_years IS NOT NULL
         THEN
            IF hr_api.not_exists_in_hr_lookups (
                  p_effective_date              => p_effective_start_date
                 ,p_lookup_type                 => 'PQP_PENSION_DEDUCTION_METHOD'
                 ,p_lookup_code                 => p_fwc_added_years
               )
            THEN
               -- Invalid Deduction Method
               fnd_message.set_name ('PAY', 'HR_52966_INVALID_LOOKUP');
               fnd_message.set_token (
                  'COLUMN'
                 ,'Family Widower Added Years Deduction Method'
               );
               fnd_message.set_token (
                  'LOOKUP_TYPE'
                 ,'PQP_PENSION_DEDUCTION_METHOD'
               );
               fnd_message.raise_error;
            END IF; -- End if of not exists in lookup check ...
         END IF; -- End if of added years deduction method specified check ...



         -- Check pension scheme type
         --
         hr_utility.set_location (l_proc_name, 110);

         --

         IF p_pension_scheme_type IS NOT NULL
         THEN
            IF hr_api.not_exists_in_hr_lookups (
                  p_effective_date              => p_effective_start_date
                 ,p_lookup_type                 => 'PQP_PENSION_SCHEME_TYPE'
                 ,p_lookup_code                 => p_pension_scheme_type
               )
            THEN
               -- Invalid Pension Scheme Type
               fnd_message.set_name ('PAY', 'HR_52966_INVALID_LOOKUP');
               fnd_message.set_token ('COLUMN', 'Pension Scheme Type');
               fnd_message.set_token (
                  'LOOKUP_TYPE'
                 ,'PQP_PENSION_SCHEME_TYPE'
               );
               fnd_message.raise_error;
            END IF; -- End if of not exists in lookup check ...

            -- Check whether ECON and SCON values are entered
            -- Ideally for a scheme of this type should have these
            -- values
            -- BUG 4108320
            -- Remove mandatory validation for ECON and SCON

            -- Get ECON number first
            l_econ_number              := NULL;
--             OPEN csr_get_econ;
--             FETCH csr_get_econ INTO l_econ_number;
--             CLOSE csr_get_econ;

--            IF    p_scon_number IS NULL
--               OR l_econ_number IS NULL
--            THEN
--               -- Raise an error
--               fnd_message.set_name ('PQP', 'PQP_230983_PEN_SCON_ECON_NULL');
--               hr_multi_message.add
-- 	           (p_associated_column4
--	             => 'PQP_GB_PENSION_SCHEMES_V.SCON'
--	           );
--            END IF; -- End if of scon or econ is null check ...
         END IF; -- End if of pension scheme type specified check ...

         --
         hr_utility.set_location (l_proc_name, 111);

         --

         -- Added validation for SCON format
         IF p_scon_number IS NOT NULL
         THEN
            --
            -- Get the translated value
            OPEN csr_translate_escon(p_scon_number);
            FETCH csr_translate_escon INTO l_scon_number;
            CLOSE csr_translate_escon;

            IF l_scon_number <> l_scon_format
            THEN
               -- Raise an error
               fnd_message.set_name ('PQP', 'PQP_230984_SCON_INVALID_FORMAT');
               fnd_message.raise_error;
            END IF; -- End if of scon number in invalid check ...
         END IF; -- End if of scon number entered check ...

         --
         hr_utility.set_location (l_proc_name, 112);

         -- Added validation for ECON format
         IF p_econ_number IS NOT NULL
         THEN
            --
            -- Get the translated value
            l_econ_number := SUBSTR(p_econ_number,2);
            OPEN csr_translate_escon(l_econ_number);
            FETCH csr_translate_escon INTO l_econ_number;
            CLOSE csr_translate_escon;

            l_econ_number := SUBSTR(p_econ_number,1,1)||l_econ_number;

            IF l_econ_number <> l_econ_format
            THEN
               -- Raise an error
               fnd_message.set_name ('PQP', 'PQP_230172_ECON_INVALID_FORMAT');
               fnd_message.raise_error;
            END IF; -- End if of econ number in invalid check ...
         END IF; -- End if of econ number entered check ...

         --
         hr_utility.set_location (l_proc_name, 115);

         --

         -- Check associated OCP element id validity
         IF p_associated_ocp_ele_id IS NOT NULL
         THEN
            OPEN csr_chk_ocp_ele_info (p_associated_ocp_ele_id);
            FETCH csr_chk_ocp_ele_info INTO l_exists;

            IF csr_chk_ocp_ele_info%NOTFOUND
            THEN
               -- Raise error
               CLOSE csr_chk_ocp_ele_info;
               fnd_message.set_name ('PQP', 'PQP_230944_PEN_OCP_SCH_INVALID');
               fnd_message.raise_error;
            END IF; -- End if of ocp ele not found check ...

            CLOSE csr_chk_ocp_ele_info;
         END IF; -- End if of associated ocp ele id not null check ...

         -- Check post termination rule
         --
         hr_utility.set_location (l_proc_name, 120);

         --

         IF hr_api.not_exists_in_hr_lookups (
               p_effective_date              => p_effective_start_date
              ,p_lookup_type                 => 'TERMINATION_RULE'
              ,p_lookup_code                 => NVL (
                                                   p_termination_rule
                                                  ,hr_api.g_varchar2
                                                )
            )
         THEN
            -- Invalid Termination Rule
            fnd_message.set_name ('PAY', 'HR_52966_INVALID_LOOKUP');
            fnd_message.set_token ('COLUMN', 'Termination Rule');
            fnd_message.set_token ('LOOKUP_TYPE', 'TERMINATION_RULE');
            fnd_message.raise_error;
         END IF; -- End if of not exists in lookup check ...

         --
         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 130);
      --
      END insert_validate;

      --


--
--==============================================================================
--|---------------------------< get_shadow_formula_id >------------------------|
--==============================================================================
      FUNCTION get_shadow_formula_id (p_formula_name IN VARCHAR2)
         RETURN NUMBER
      IS
         --
         -- Cursor to retrieve the formula information
         CURSOR csr_get_formula_info
         IS
            SELECT formula_id
              FROM pay_shadow_formulas
             WHERE formula_name = p_formula_name
               AND business_group_id = p_business_group_id
               AND template_type = 'U';

         l_proc_name    VARCHAR2 (80)
                                   :=    g_proc_name
                                      || 'get_shadow_formula_id';
         l_formula_id   NUMBER;
      --
      BEGIN
         --
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);
         --
         OPEN csr_get_formula_info;
         FETCH csr_get_formula_info INTO l_formula_id;

         IF csr_get_formula_info%NOTFOUND
         THEN
            CLOSE csr_get_formula_info;
            fnd_message.set_name ('PER', 'HR_289263_FORMULA_ID_INVALID');
            fnd_message.raise_error;
         END IF; -- End if of csr row not found check ...

         CLOSE csr_get_formula_info;
         --
         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 20);
         --
         RETURN l_formula_id;
      END get_shadow_formula_id;


--
--==============================================================================
--|---------------------------< update_shadow_formula >------------------------|
--==============================================================================
      PROCEDURE update_shadow_formula (
         p_formula_id       IN   NUMBER
        ,p_search_string    IN   VARCHAR2
        ,p_replace_string   IN   VARCHAR2
      )
      IS
         --
         -- Cursor to retrieve the formula information
         CURSOR csr_get_formula_info
         IS
            SELECT formula_text
              FROM pay_shadow_formulas
             WHERE formula_id = p_formula_id;

         l_proc_name      VARCHAR2 (80)
                                   :=    g_proc_name
                                      || 'update_shadow_formula';
         l_formula_text   LONG;
      --
      BEGIN
         --
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);
         --
         OPEN csr_get_formula_info;
         FETCH csr_get_formula_info INTO l_formula_text;

         IF csr_get_formula_info%NOTFOUND
         THEN
            CLOSE csr_get_formula_info;
            fnd_message.set_name ('PER', 'HR_289263_FORMULA_ID_INVALID');
            fnd_message.raise_error;
         END IF; -- End if of csr row not found check ...

         CLOSE csr_get_formula_info;
         l_formula_text             :=
                   REPLACE (l_formula_text, p_search_string, p_replace_string);
         --
         hr_utility.set_location (l_proc_name, 20);

         --
         UPDATE pay_shadow_formulas
            SET formula_text = l_formula_text
          WHERE formula_id = p_formula_id;

         --
         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 30);

--
      END update_shadow_formula;


  --
--
--==============================================================================
--|---------------------------< get_input_value_id >---------------------------|
--==============================================================================
      FUNCTION get_input_value_id (
         p_input_value_name   IN   VARCHAR2
        ,p_element_type_id    IN   NUMBER
        ,p_element_name       IN   VARCHAR2
      )
         RETURN NUMBER
      IS
         --
         -- Cursor to retrieve the input value information
         CURSOR csr_get_ipv_info (c_element_type_id NUMBER)
         IS
            SELECT input_value_id
              FROM pay_input_values_f
             WHERE NAME = p_input_value_name
               AND element_type_id = c_element_type_id
               AND p_effective_start_date BETWEEN effective_start_date
                                              AND effective_end_date;

         l_proc_name         VARCHAR2 (80)
                                      :=    g_proc_name
                                         || 'get_input_value_id';
         l_input_value_id    NUMBER;
         l_element_type_id   NUMBER;
      --
      BEGIN
         --
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);

         IF p_element_type_id IS NULL
         THEN
            --
            -- Get the element type id for the element name
            l_element_type_id          :=
                  get_object_id (
                     p_object_type                 => 'ELE'
                    ,p_object_name                 => p_element_name
                  );
         ELSE -- p_element_type_id is not null
            l_element_type_id          := p_element_type_id;
         END IF; -- End if of p_element_type_id is null check ...

         --
         hr_utility.set_location (l_proc_name, 20);
         --
         OPEN csr_get_ipv_info (l_element_type_id);
         FETCH csr_get_ipv_info INTO l_input_value_id;

         IF csr_get_ipv_info%NOTFOUND
         THEN
            CLOSE csr_get_ipv_info;
            fnd_message.set_name ('PQP', 'PQP_230935_INPUT_VAL_NOTFOUND');
            fnd_message.set_token ('INPUT_VALUE', p_input_value_name);
            fnd_message.raise_error;
         END IF; -- End if of csr row not found check ...

         CLOSE csr_get_ipv_info;

--
         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 20);
         --
         RETURN l_input_value_id;
      END get_input_value_id;

      --

--
--==============================================================================
--|---------------------------< update_ipv_mandatory_flag >--------------------|
--==============================================================================
      PROCEDURE update_ipv_mandatory_flag (
         p_input_value_name   IN   VARCHAR2
        ,p_element_type_id    IN   NUMBER
        ,p_mandatory_flag     IN   VARCHAR2
      )
      IS
         --
         l_proc_name        VARCHAR2 (80)
                               :=    g_proc_name
                                  || 'update_ipv_mandatory_flag';
         l_input_value_id   NUMBER;
      --
      BEGIN
         --
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);
         --

         -- Get input value id
         l_input_value_id           :=
               get_input_value_id (
                  p_input_value_name            => p_input_value_name
                 ,p_element_type_id             => p_element_type_id
                 ,p_element_name                => NULL
               );
         --
         hr_utility.set_location (l_proc_name, 20);

         --
         UPDATE pay_input_values_f
            SET mandatory_flag = p_mandatory_flag
          WHERE input_value_id = l_input_value_id
            AND p_effective_start_date BETWEEN effective_start_date
                                           AND effective_end_date;

         --
         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 30);
      --
      END update_ipv_mandatory_flag;


  --
--
--==============================================================================
--|---------------------------< create_balance_feeds >-------------------------|
--==============================================================================
      PROCEDURE create_balance_feeds (
         p_balance_type_id    IN   NUMBER
        ,p_element_name       IN   VARCHAR2
        ,p_input_value_name   IN   VARCHAR2
        ,p_scale              IN   NUMBER
      )
      IS
         --
         l_proc_name         VARCHAR2 (80)
                                    :=    g_proc_name
                                       || 'create_balance_feeds';
         l_element_type_id   NUMBER;
         l_input_value_id    NUMBER;
         l_row_id            ROWID;
         l_balance_feed_id   NUMBER;
      --
      BEGIN
         --
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);
         --
         -- Get input value id for the input value name

         l_input_value_id           :=
               get_input_value_id (
                  p_input_value_name            => p_input_value_name
                 ,p_element_name                => p_element_name
                 ,p_element_type_id             => NULL
               );
         --
         hr_utility.set_location (l_proc_name, 20);
         --
         -- Create Balance Feed
         pay_balance_feeds_f_pkg.insert_row (
            x_rowid                       => l_row_id
           ,x_balance_feed_id             => l_balance_feed_id
           ,x_effective_start_date        => p_effective_start_date
           ,x_effective_end_date          => hr_api.g_eot
           ,x_business_group_id           => p_business_group_id
           ,x_legislation_code            => NULL
           ,x_balance_type_id             => p_balance_type_id
           ,x_input_value_id              => l_input_value_id
           ,x_scale                       => p_scale
           ,x_legislation_subgroup        => NULL
         );
         --
         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 30);
      --
      END create_balance_feeds;


  --
--
--==============================================================================
--|----------------------------< get_scheme_prefix >---------------------------|
--==============================================================================
      FUNCTION get_scheme_prefix (p_element_type_id IN NUMBER)
         RETURN VARCHAR2
      IS
         --
         CURSOR csr_get_scheme_prefix
         IS
            SELECT eei_information18
              FROM pay_element_type_extra_info
             WHERE element_type_id = p_element_type_id
               AND information_type = 'PQP_GB_PENSION_SCHEME_INFO';

         l_proc_name       VARCHAR2 (80)
                                       :=    g_proc_name
                                          || 'get_scheme_prefix';
         l_scheme_prefix   pay_element_type_extra_info.eei_information18%TYPE;
      --
      BEGIN
         --
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);
         --
         OPEN csr_get_scheme_prefix;
         FETCH csr_get_scheme_prefix INTO l_scheme_prefix;

         IF csr_get_scheme_prefix%NOTFOUND
         THEN
            CLOSE csr_get_scheme_prefix;
            fnd_message.set_name ('PQP', 'PQP_230944_PEN_OCP_SCH_INVALID');
            fnd_message.raise_error;
         END IF; -- End if of row not found check ...

         CLOSE csr_get_scheme_prefix;
         --
         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 20);
         --

         RETURN l_scheme_prefix;
      --
      END get_scheme_prefix;

      --


--
--==============================================================================
--|----------------------------< create_sub_class_rules >----------------------|
--==============================================================================
      PROCEDURE create_sub_class_rules (
         p_classification_name   IN   VARCHAR2
        ,p_element_type_id       IN   NUMBER
      )
      IS
         --
         CURSOR csr_get_class_id
         IS
            SELECT classification_id
              FROM pay_element_classifications
             WHERE classification_name = p_classification_name
               AND legislation_code = g_template_leg_code
               AND business_group_id IS NULL;

         l_proc_name           VARCHAR2 (80)
                                  :=    g_proc_name
                                     || 'create_sub_class_rules';
         l_rowid               ROWID;
         l_sub_class_rule_id   NUMBER;
         l_classification_id   NUMBER;
         l_user_id             NUMBER        := fnd_global.user_id;
         l_login_id            NUMBER        := fnd_global.login_id;
      --
      BEGIN
         --
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);
         --

         -- Get classification id
         OPEN csr_get_class_id;
         FETCH csr_get_class_id INTO l_classification_id;

         IF csr_get_class_id%NOTFOUND
         THEN
            CLOSE csr_get_class_id;
            fnd_message.set_name ('PAY', 'PAY_50060_ETM_BAD_ELE_CLASS');
            fnd_message.set_token ('CLASSIFICATION', p_classification_name);
            fnd_message.raise_error;
         END IF; -- End if of csr class id not found check ...

         CLOSE csr_get_class_id;
         -- Insert sub classification rule
         --
         hr_utility.set_location (l_proc_name, 20);
         --

         pay_sub_class_rules_pkg.insert_row (
            p_rowid                       => l_rowid
           ,p_sub_classification_rule_id  => l_sub_class_rule_id
           ,p_effective_start_date        => p_effective_start_date
           ,p_effective_end_date          => hr_api.g_eot
           ,p_element_type_id             => p_element_type_id
           ,p_classification_id           => l_classification_id
           ,p_business_group_id           => p_business_group_id
           ,p_legislation_code            => NULL
           ,p_creation_date               => SYSDATE
           ,p_created_by                  => l_user_id
           ,p_last_update_date            => SYSDATE
           ,p_last_updated_by             => l_user_id
           ,p_last_update_login           => l_login_id
         );
         --
         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 30);
      --
      END create_sub_class_rules;

  --
--
--==============================================================================
--|------------------------------< Main Function >-----------------------------|
--==============================================================================

   BEGIN
      --
      hr_utility.set_location (   'Entering : '
                               || l_proc_name, 10);
      --

      -- Check scheme prefix
      chk_scheme_prefix (p_scheme_prefix => p_ele_base_name);
      --
      hr_utility.set_location (l_proc_name, 20);
      --

      OPEN csr_chk_uniq_base_name;
      FETCH csr_chk_uniq_base_name INTO l_exists;

      IF csr_chk_uniq_base_name%FOUND
      THEN
         -- Raise error
         fnd_message.set_name ('PAY', 'PAY_50076_ETM_BASE_NAME_EXISTS');
         fnd_message.set_token ('BASE_NAME', p_ele_base_name);
         CLOSE csr_chk_uniq_base_name;
         hr_multi_message.add
           (p_associated_column4
            => 'PQP_GB_PENSION_SCHEMES_V.SCHEME_PREFIX'
           );
      END IF; -- End if of base name row found check...

      IF csr_chk_uniq_base_name%ISOPEN THEN
         CLOSE csr_chk_uniq_base_name;
      END IF; -- Cursor is open check ...

      -- Validate all the parameters before processing
      --
      hr_utility.set_location (l_proc_name, 25);

      --

      IF p_validate
      THEN
         insert_validate;
      END IF; -- End if of p_validate check ...

      -- Initialize all exclusion variables first

      l_exc_ocp_rule_id          := 'N';
      l_exc_ers_cent_rule_id     := 'N';
      l_exc_ers_fxd_rule_id      := 'N';
      l_exc_adl_cent_rule_id     := 'N';
      l_exc_adl_fxd_rule_id      := 'N';
      l_exc_ayr_cent_rule_id     := 'N';
      l_exc_ayr_fxd_rule_id      := 'N';

      l_exc_bb_fwc_cent_rule_id     := 'N';
      l_exc_bb_fwc_fxd_rule_id      := 'N';

      l_exc_fwd_cent_rule_id     := 'N';
      l_exc_fwd_fxd_rule_id      := 'N';
      l_exc_avc_rule_id          := 'N';
      l_exc_shp_rule_id          := 'N';
      l_exc_fsavc_rule_id        := 'N';
      l_exc_pep_rule_id          := 'N';
      l_exc_pre_tax_rule_id      := 'N';
      l_exc_ees_cram_rule_id     := 'N';
      l_exc_ees_cent_rule_id     := 'N';
      l_exc_ers_rule_id          := 'N';
      l_exc_adl_rule_id          := 'N';
      l_exc_ayr_rule_id          := 'N';
      l_exc_fwd_rule_id          := 'N';
      l_exc_ssal_rule_id         := 'N';
      l_exc_vol_con_rule_id      := 'N';
      l_exc_itr_rule_id          := 'N';
      l_exc_fsavc_eer_rule_id    := 'N';

      l_exc_bb_fwc_rule_id          := 'N';
      --
      -- Set exclusion rule
      --
      -- Set employees contribution exclusion rule based
      -- on pension category

      --
      hr_utility.set_location (l_proc_name, 50);

      --

      IF p_pension_category = 'OCP'
      THEN
         l_exc_ocp_rule_id          := NULL;
      ELSIF p_pension_category = 'AVC'
      THEN
         l_exc_avc_rule_id          := NULL;
      ELSIF p_pension_category = 'SHP'
      THEN
         l_exc_shp_rule_id          := NULL;
      ELSIF p_pension_category = 'FSAVC'
      THEN
         l_exc_fsavc_rule_id        := NULL;
      ELSIF p_pension_category = 'PEP'
      THEN
         l_exc_pep_rule_id          := NULL;
      END IF; -- End if of pension category check ...

      -- Set employees input value exclusion rule based
      -- on employees deduction method

      --
      hr_utility.set_location (l_proc_name, 60);
      --

      -- Check whether the pension type supports the employee
      -- and employer deduction method chosen

      l_cont_iv_name             := NULL;
      l_skip_formula             := NULL;
      l_iv_default_value         := NULL;

      IF    l_emp_deduction_method = 'PE'
         OR l_emp_deduction_method = 'PEFR'
      THEN
         IF g_tab_pension_types_info (p_pension_type_id).ee_contribution_percent IS NULL
         THEN
            fnd_message.set_name ('PQP', 'PQP_230931_PEN_INVALID_DED_MTH');
            fnd_message.set_token ('DEDUCTION_METHOD', 'Employee Percentage');
            fnd_message.set_token (
               'PENSION_TYPE'
              ,g_tab_pension_types_info (p_pension_type_id).pension_type_name
            );
            IF l_emp_deduction_method = 'PEFR'
            THEN
               IF g_tab_pension_types_info (p_pension_type_id).ee_contribution_fixed_rate IS NULL
               THEN
                  fnd_message.set_name ('PQP', 'PQP_230931_PEN_INVALID_DED_MTH');
                  fnd_message.set_token (
                     'DEDUCTION_METHOD'
                    ,'Employee Percentage and Fixed Rate'
                  );
                  fnd_message.set_token (
                     'PENSION_TYPE'
                    ,g_tab_pension_types_info (p_pension_type_id).pension_type_name
                  );
               END IF; -- End if of pension type support FR deduction method check ...
            END IF; -- End if of emp deduction method is PEFR check ...
            hr_multi_message.add
	           (p_associated_column2
	             => 'EMPLOYEE_DEDUCTION_METHOD'
	           );
         END IF; -- End if of pension type support % deduction method check ...

         -- Check whether deduction method FR is supported by this
         -- pension type
         IF l_emp_deduction_method = 'PEFR'
         THEN
            IF g_tab_pension_types_info (p_pension_type_id).ee_contribution_fixed_rate IS NULL
            THEN
               fnd_message.set_name ('PQP', 'PQP_230931_PEN_INVALID_DED_MTH');
               fnd_message.set_token (
                  'DEDUCTION_METHOD'
                 ,'Employee Fixed Rate'
               );
               fnd_message.set_token (
                  'PENSION_TYPE'
                 ,g_tab_pension_types_info (p_pension_type_id).pension_type_name
               );
            hr_multi_message.add
	           (p_associated_column2
	             => 'PQP_GB_PENSION_SCHEMES_V.EMPLOYEE_DEDUCTION_METHOD'
	           );
            END IF; -- End if of pension type support FR deduction method check ...

            l_emp_deduction_method     := 'PE';
         END IF; -- End if of emp deduction method is PEFR check ...

         l_exc_ees_cent_rule_id     := NULL;
         l_skip_formula             := NULL;
         l_cont_iv_name             := 'Contribution Percent';
         l_iv_default_value         :=
               g_tab_pension_types_info (p_pension_type_id).ee_contribution_percent;
      ELSIF l_emp_deduction_method = 'FR'
      THEN
         IF g_tab_pension_types_info (p_pension_type_id).ee_contribution_fixed_rate IS NULL
         THEN
            fnd_message.set_name ('PQP', 'PQP_230931_PEN_INVALID_DED_MTH');
            fnd_message.set_token ('DEDUCTION_METHOD', 'Employee Fixed Rate');
            fnd_message.set_token (
               'PENSION_TYPE'
              ,g_tab_pension_types_info (p_pension_type_id).pension_type_name
            );
            hr_multi_message.add
	           (p_associated_column2
	             => 'PQP_GB_PENSION_SCHEMES_V.EMPLOYEE_DEDUCTION_METHOD'
	           );
         END IF; -- End if of pension type support FR deduction method check ...

         l_exc_ees_cram_rule_id     := NULL;
         l_skip_formula             := 'ONCE_EACH_PERIOD';
         l_cont_iv_name             := 'Contribution Amount';
         l_iv_default_value         :=
               g_tab_pension_types_info (p_pension_type_id).ee_contribution_fixed_rate;
      END IF; -- End if of emp deduction method check ...

      -- Set employers contribution exclusion rule based
      -- on employer deduction method

      --
      hr_utility.set_location (l_proc_name, 70);

      --

      IF p_eer_deduction_method = 'PE'
      THEN
         IF g_tab_pension_types_info (p_pension_type_id).er_contribution_percent IS NULL
         THEN
            fnd_message.set_name ('PQP', 'PQP_230931_PEN_INVALID_DED_MTH');
            fnd_message.set_token ('DEDUCTION_METHOD', 'Employer Percentage');
            fnd_message.set_token (
               'PENSION_TYPE'
              ,g_tab_pension_types_info (p_pension_type_id).pension_type_name
            );
            hr_multi_message.add
	           (p_associated_column3
	             => 'PQP_GB_PENSION_SCHEMES_V.EMPLOYER_DEDUCTION_METHOD'
	           );

         END IF; -- End if of pension type support % deduction method check ...

         l_exc_ers_cent_rule_id     := NULL;
         l_exc_ers_rule_id          := NULL;
      ELSIF p_eer_deduction_method = 'FR'
      THEN
         IF g_tab_pension_types_info (p_pension_type_id).er_contribution_fixed_rate IS NULL
         THEN
            fnd_message.set_name ('PQP', 'PQP_230931_PEN_INVALID_DED_MTH');
            fnd_message.set_token ('DEDUCTION_METHOD', 'Employer Fixed Rate');
            fnd_message.set_token (
               'PENSION_TYPE'
              ,g_tab_pension_types_info (p_pension_type_id).pension_type_name
            );
            hr_multi_message.add
	           (p_associated_column3
	             => 'PQP_GB_PENSION_SCHEMES_V.EMPLOYER_DEDUCTION_METHOD'
	           );
         END IF; -- End if of pension type support FR deduction method check ...

         l_exc_ers_fxd_rule_id      := NULL;
         l_exc_ers_rule_id          := NULL;
      ELSIF p_eer_deduction_method = 'PEFR'
      THEN
         IF      g_tab_pension_types_info (p_pension_type_id).er_contribution_percent IS NULL
             AND g_tab_pension_types_info (p_pension_type_id).er_contribution_fixed_rate IS NULL
         THEN
            fnd_message.set_name ('PQP', 'PQP_230931_PEN_INVALID_DED_MTH');
            fnd_message.set_token (
               'DEDUCTION_METHOD'
              ,'Employer Percentage and Fixed Rate'
            );
            fnd_message.set_token (
               'PENSION_TYPE'
              ,g_tab_pension_types_info (p_pension_type_id).pension_type_name
            );
            hr_multi_message.add
	           (p_associated_column3
	             => 'PQP_GB_PENSION_SCHEMES_V.EMPLOYER_DEDUCTION_METHOD'
	           );
         END IF; -- End if of pension type support % and FR deduction method check ...

         IF g_tab_pension_types_info (p_pension_type_id).er_contribution_fixed_rate IS NULL
         THEN
            fnd_message.set_name ('PQP', 'PQP_230931_PEN_INVALID_DED_MTH');
            fnd_message.set_token ('DEDUCTION_METHOD', 'Employer Fixed Rate');
            fnd_message.set_token (
               'PENSION_TYPE'
              ,g_tab_pension_types_info (p_pension_type_id).pension_type_name
            );
            hr_multi_message.add
	           (p_associated_column3
	             => 'PQP_GB_PENSION_SCHEMES_V.EMPLOYER_DEDUCTION_METHOD'
	           );
         END IF; -- End if of fixed rate is null check ...

         IF g_tab_pension_types_info (p_pension_type_id).er_contribution_percent IS NULL
         THEN
            fnd_message.set_name ('PQP', 'PQP_230931_PEN_INVALID_DED_MTH');
            fnd_message.set_token ('DEDUCTION_METHOD', 'Employer Percentage');
            fnd_message.set_token (
               'PENSION_TYPE'
              ,g_tab_pension_types_info (p_pension_type_id).pension_type_name
            );
            hr_multi_message.add
	           (p_associated_column3
	             => 'PQP_GB_PENSION_SCHEMES_V.EMPLOYER_DEDUCTION_METHOD'
	           );
         END IF; -- End if of percentage is null check ...

         l_exc_ers_cent_rule_id     := NULL;
         l_exc_ers_fxd_rule_id      := NULL;
         l_exc_ers_rule_id          := NULL;
      END IF; -- End if of eer deduction method check ...

      hr_multi_message.end_validation_set;

      -- Set exclusion rules for additional, added and family widower
      -- contributions

      --
      hr_utility.set_location (l_proc_name, 80);

      --

      IF p_additional_contribution = 'PE'
      THEN
         l_exc_adl_cent_rule_id     := NULL;
         l_exc_adl_rule_id          := NULL;
      ELSIF p_additional_contribution = 'FR'
      THEN
         l_exc_adl_fxd_rule_id      := NULL;
         l_exc_adl_rule_id          := NULL;
      ELSIF p_additional_contribution = 'PEFR'
      THEN
         l_exc_adl_cent_rule_id     := NULL;
         l_exc_adl_fxd_rule_id      := NULL;
         l_exc_adl_rule_id          := NULL;
      END IF; -- End if of additional contribution check ...

      IF p_added_years = 'PE'
      THEN
         l_exc_ayr_cent_rule_id     := NULL;
         l_exc_ayr_rule_id          := NULL;
      ELSIF p_added_years = 'FR'
      THEN
         l_exc_ayr_fxd_rule_id      := NULL;
         l_exc_ayr_rule_id          := NULL;
      ELSIF p_added_years = 'PEFR'
      THEN
         l_exc_ayr_cent_rule_id     := NULL;
         l_exc_ayr_fxd_rule_id      := NULL;
         l_exc_ayr_rule_id          := NULL;
      END IF; -- End if of added years check ...

      IF p_family_widower = 'PE'
      THEN
         l_exc_fwd_cent_rule_id     := NULL;
         l_exc_fwd_rule_id          := NULL;
      ELSIF p_family_widower = 'FR'
      THEN
         l_exc_fwd_fxd_rule_id      := NULL;
         l_exc_fwd_rule_id          := NULL;
      ELSIF p_family_widower = 'PEFR'
      THEN
         l_exc_fwd_cent_rule_id     := NULL;
         l_exc_fwd_fxd_rule_id      := NULL;
         l_exc_fwd_rule_id          := NULL;
      END IF; -- End if of family widower check ...


      IF p_fwc_added_years = 'PE'
      THEN
         l_exc_bb_fwc_cent_rule_id     := NULL;
         l_exc_bb_fwc_rule_id          := NULL;
      ELSIF p_fwc_added_years = 'FR'
      THEN
         l_exc_bb_fwc_fxd_rule_id      := NULL;
         l_exc_bb_fwc_rule_id          := NULL;
      ELSIF p_fwc_added_years = 'PEFR'
      THEN
         l_exc_bb_fwc_cent_rule_id     := NULL;
         l_exc_bb_fwc_fxd_rule_id      := NULL;
         l_exc_bb_fwc_rule_id          := NULL;
      END IF; -- End if of added years check ...
      -- Get element classification name
      --
      hr_utility.set_location (l_proc_name, 90);
      --

      get_ele_classification_info (
         p_classification_id           => p_ele_classification_id
        ,p_classification_name         => l_ele_class_name
        ,p_default_priority            => l_base_processing_priority
      );

      IF      l_base_processing_priority = 4500
          AND l_ele_class_name = 'Pre Tax Deductions'
      THEN
         l_base_processing_priority := 4100;
      END IF; -- End if of base processing priority check ...

      -- Set exclusion rule for pre-tax and vol cont
      -- based on classification name

      IF l_ele_class_name = 'Pre Tax Deductions'
      THEN
         l_exc_pre_tax_rule_id      := NULL;

         -- Set exclusion rule for FSAVC employer contribution
         -- balance feed
         IF l_exc_fsavc_rule_id IS NULL
         THEN
            l_exc_fsavc_eer_rule_id    := NULL;
         END IF; -- End if of fsavc check ...
      ELSIF l_ele_class_name = 'Voluntary Deductions'
      THEN
         l_exc_vol_con_rule_id      := NULL;
      END IF; -- End if of ele class name check ...

      -- Set exclusion rule for superannuable salary balance
      -- based on pensionable salary information
      --
      hr_utility.set_location (l_proc_name, 100);

      --

      IF p_pensionable_sal_bal_id IS NULL
      THEN
         l_exc_ssal_rule_id         := NULL;
      END IF; -- End if of pensionable sal bal check ...

      -- Set exclusion rule for iterative rules
      -- Check iterative processing is chosen only for classification
      -- pre tax deduction

      l_iterative_flag           := 'N';

      IF l_ele_class_name = 'Pre Tax Deductions'
      THEN
         IF p_iterative_processing = 'Y'
         THEN
            l_iterative_flag           := 'Y';
            l_exc_itr_rule_id          := NULL;
         END IF; -- End if of iterative processing is enabled check ...
      END IF; -- End if of classification is pre tax check ...

      -- Get Source Template ID

      --
      hr_utility.set_location (l_proc_name, 110);
      --

      l_source_template_id       :=
                   get_template_id (p_legislation_code => g_template_leg_code);
      /*--------------------------------------------------------------------------
         Create the user Structure
         The Configuration Flex segments for the Exclusion Rules are as follows:
       ---------------------------------------------------------------------------
       Config1  -- l_exc_ocp_rule_id
       Config2  -- l_exc_pre_tax_rule_id
       Config3  -- l_exc_ees_cram_rule_id
       Config4  -- l_exc_ees_cent_rule_id
       Config5  -- l_exc_ers_cent_rule_id
       Config6  -- l_exc_ers_fxd_rule_id
       Config7  -- l_exc_adl_cent_rule_id
       Config8  -- l_exc_adl_fxd_rule_id
       Config9  -- l_exc_ayr_cent_rule_id
       Config10 -- l_exc_ayr_fxd_rule_id
       Config11 -- l_exc_fwd_cent_rule_id
       Config12 -- l_exc_fwd_fxd_rule_id
       Config13 -- l_exc_avc_rule_id
       Config14 -- l_exc_shp_rule_id
       Config15 -- l_exc_fsavc_rule_id
       Config16 -- l_exc_pep_rule_id
       Config17 -- l_exc_ers_rule_id
       Config18 -- l_exc_adl_rule_id
       Config19 -- l_exc_ayr_rule_id
       Config20 -- l_exc_fwd_rule_id
       Config21 -- l_exc_ssal_rule_id
       Config22 -- l_exc_vol_con_rule_id
       Config23 -- l_exc_itr_rule_id
       Config24 -- l_exc_fsavc_eer_rule_id

      ---------------------------------------------------------------------------*/
      --
      hr_utility.set_location (l_proc_name, 120);
      --

      --
      -- create user structure from the template
      --
      pay_element_template_api.create_user_structure (
         p_validate                    => FALSE
        ,p_effective_date              => p_effective_start_date
        ,p_business_group_id           => p_business_group_id
        ,p_source_template_id          => l_source_template_id
        ,p_base_name                   => p_ele_base_name
        ,p_base_processing_priority    => l_base_processing_priority
        ,p_configuration_information1  => l_exc_ocp_rule_id
        ,p_configuration_information2  => l_exc_pre_tax_rule_id
        ,p_configuration_information3  => l_exc_ees_cram_rule_id
        ,p_configuration_information4  => l_exc_ees_cent_rule_id
        ,p_configuration_information5  => l_exc_ers_cent_rule_id
        ,p_configuration_information6  => l_exc_ers_fxd_rule_id
        ,p_configuration_information7  => l_exc_adl_cent_rule_id
        ,p_configuration_information8  => l_exc_adl_fxd_rule_id
        ,p_configuration_information9  => l_exc_ayr_cent_rule_id
        ,p_configuration_information10 => l_exc_ayr_fxd_rule_id
        ,p_configuration_information11 => l_exc_fwd_cent_rule_id
        ,p_configuration_information12 => l_exc_fwd_fxd_rule_id
        ,p_configuration_information13 => l_exc_avc_rule_id
        ,p_configuration_information14 => l_exc_shp_rule_id
        ,p_configuration_information15 => l_exc_fsavc_rule_id
        ,p_configuration_information16 => l_exc_pep_rule_id
        ,p_configuration_information17 => l_exc_ers_rule_id
        ,p_configuration_information18 => l_exc_adl_rule_id
        ,p_configuration_information19 => l_exc_ayr_rule_id
        ,p_configuration_information20 => l_exc_fwd_rule_id
        ,p_configuration_information21 => l_exc_ssal_rule_id
        ,p_configuration_information22 => l_exc_vol_con_rule_id
        ,p_configuration_information23 => l_exc_itr_rule_id
        ,p_configuration_information24 => l_exc_fsavc_eer_rule_id
        ,p_configuration_information25 => l_exc_bb_fwc_cent_rule_id
        ,p_configuration_information26 => l_exc_bb_fwc_fxd_rule_id
        ,p_configuration_information27 => l_exc_bb_fwc_rule_id
        ,p_template_id                 => l_template_id
        ,p_object_version_number       => l_object_version_number
        ,p_allow_base_name_reuse       => TRUE
      );
      --
      hr_utility.set_location (l_proc_name, 130);
      --
      ---------------------------- Update Shadow Structure ----------------------
      --

      -- Employee Contribution element
      i                          := 0;
      i                          :=   i
                                    + 1;
      l_ele_name (i)             :=
               p_ele_base_name
            || ' EES '
            || p_pension_category
            || ' Contribution';
      OPEN csr_get_shadow_ele_info (l_ele_name (i));
      FETCH csr_get_shadow_ele_info INTO l_element_type_id
                                        ,l_ele_obj_ver_number;
      CLOSE csr_get_shadow_ele_info;
      -- Get iterative priority and formula only if
      -- iterative flag is set

      l_iterative_priority       := NULL;
      l_iterative_formula        := NULL;

      IF l_iterative_flag = 'Y'
      THEN
         l_iterative_priority       :=
              get_iterative_priority (p_element_type_id => l_element_type_id);
         l_iterative_formula        := 'PQP_GB_ITERATIVE_PRETAX';
      END IF; -- End if of iterative flag = Y check ...

      --
      hr_utility.set_location (l_proc_name, 140);
      --

      pay_shadow_element_api.update_shadow_element (
         p_validate                    => FALSE
        ,p_effective_date              => p_effective_start_date
        ,p_element_type_id             => l_element_type_id
        ,p_element_name                => l_ele_name (i)
        ,p_reporting_name              => p_ele_reporting_name
        ,p_description                 => p_ele_description
        ,p_classification_name         => l_ele_class_name
        ,p_skip_formula                => l_skip_formula
        ,p_third_party_pay_only_flag   => p_third_party_only_flag
        ,p_iterative_flag              => l_iterative_flag
        ,p_iterative_priority          => l_iterative_priority
        ,p_iterative_formula_name      => l_iterative_formula
        ,p_standard_link_flag          => l_standard_link
        ,p_post_termination_rule       => p_termination_rule
        ,p_object_version_number       => l_ele_obj_ver_number
      );
      --
      hr_utility.set_location (l_proc_name, 150);

      --

      -- Employer Pension Element

      IF l_exc_ers_cent_rule_id IS NULL
      THEN
         i                          :=   i
                                       + 1;
         l_ele_name (i)             :=
                                         p_ele_base_name
                                      || ' ERS Contribution';
         l_ele_new_name (i)         :=    p_ele_base_name
                                       || ' ERS '
                                       || p_pension_category
                                       || ' Contribution';
      END IF; -- End if of ers cent rule null check ...

      IF l_exc_ers_fxd_rule_id IS NULL
      THEN
         i                          :=   i
                                       + 1;
         l_ele_name (i)             :=
                                   p_ele_base_name
                                || ' ERS Contribution Fixed';
         l_ele_new_name (i)         :=    p_ele_base_name
                                       || ' ERS '
                                       || p_pension_category
                                       || ' Contribution Fixed';
      END IF; -- End if of ers fr rule null check ...

      -- Start from 2 as the first one will always be a base element

      IF i > 1
      THEN
         FOR i IN 2 .. l_ele_name.LAST
         LOOP
            OPEN csr_get_shadow_ele_info (l_ele_name (i));

            LOOP
               FETCH csr_get_shadow_ele_info INTO l_element_type_id
                                                 ,l_ele_obj_ver_number;
               EXIT WHEN csr_get_shadow_ele_info%NOTFOUND;
               --
               hr_utility.set_location (l_proc_name, 170);

--

               pay_shadow_element_api.update_shadow_element (
                  p_validate                    => FALSE
                 ,p_effective_date              => p_effective_start_date
                 ,p_element_type_id             => l_element_type_id
                 ,p_element_name                => l_ele_new_name (i)
                 ,p_third_party_pay_only_flag   => p_third_party_only_flag
                 ,p_standard_link_flag          => l_standard_link
                 ,p_post_termination_rule       => p_termination_rule
                 ,p_object_version_number       => l_ele_obj_ver_number
               );
               -- Move the ele new name to the ele name
               l_ele_name (i)             := l_ele_new_name (i);
            END LOOP;

            CLOSE csr_get_shadow_ele_info;
         END LOOP;
      END IF; -- End if of i > 1 check ...

      --
      hr_utility.set_location (l_proc_name, 180);
      --

      -- set counter initial value
      j                          := l_ele_name.LAST;

      -- Additional Contribution Element

      IF l_exc_adl_cent_rule_id IS NULL
      THEN
         i                          :=   i
                                       + 1;
         l_ele_name (i)             :=
                                  p_ele_base_name
                               || ' Additional Contribution';
      END IF; -- End if of ers cent rule null check ...

      IF l_exc_adl_fxd_rule_id IS NULL
      THEN
         i                          :=   i
                                       + 1;
         l_ele_name (i)             :=
                            p_ele_base_name
                         || ' Additional Contribution Fixed';
      END IF; -- End if of ers fr rule null check ...

      -- Added Years Element

      IF l_exc_ayr_cent_rule_id IS NULL
      THEN
         i                          :=   i
                                       + 1;
         l_ele_name (i)             :=    p_ele_base_name
                                       || ' Added Years';
      END IF; -- End if of ers cent rule null check ...

      IF l_exc_ayr_fxd_rule_id IS NULL
      THEN
         i                          :=   i
                                       + 1;
         l_ele_name (i)             :=
                                        p_ele_base_name
                                     || ' Added Years Fixed';
      END IF; -- End if of ers fr rule null check ...

      -- Family Widower Element

      IF l_exc_fwd_cent_rule_id IS NULL
      THEN
         i                          :=   i
                                       + 1;
         l_ele_name (i)             :=    p_ele_base_name
                                       || ' Family Widower';
      END IF; -- End if of ers cent rule null check ...

      IF l_exc_fwd_fxd_rule_id IS NULL
      THEN
         i                          :=   i
                                       + 1;
         l_ele_name (i)             :=
                                     p_ele_base_name
                                  || ' Family Widower Fixed';
      END IF; -- End if of ers fr rule null check ...


      -- Family Widower Added Years Element

      IF l_exc_bb_fwc_cent_rule_id IS NULL
      THEN
         i                          :=   i
                                       + 1;
         l_ele_name (i)             :=    p_ele_base_name
                                       || ' Buy Back FWC';
      END IF; -- End if of ers cent rule null check ...

      IF l_exc_bb_fwc_fxd_rule_id IS NULL
      THEN
         i                          :=   i
                                       + 1;
         l_ele_name (i)             :=
                                        p_ele_base_name
                                     || ' Buy Back FWC Fixed';
      END IF; -- End if of ers fr rule null check ...



      -- Start after j
      i                          := l_ele_name.NEXT (j);

      WHILE i IS NOT NULL
      LOOP
         OPEN csr_get_shadow_ele_info (l_ele_name (i));

         LOOP
            FETCH csr_get_shadow_ele_info INTO l_element_type_id
                                              ,l_ele_obj_ver_number;
            EXIT WHEN csr_get_shadow_ele_info%NOTFOUND;

            IF l_iterative_flag = 'Y'
            THEN
               -- Get iterative priority for this element
               l_iterative_priority       :=
                     get_iterative_priority (
                        p_element_type_id             => l_element_type_id
                     );
            END IF; -- End if of iterative flag = Y check ...

            --
            hr_utility.set_location (l_proc_name, 190);
            --

            pay_shadow_element_api.update_shadow_element (
               p_validate                    => FALSE
              ,p_effective_date              => p_effective_start_date
              ,p_element_type_id             => l_element_type_id
              ,p_element_name                => l_ele_name (i)
              ,p_classification_name         => l_ele_class_name
              ,p_third_party_pay_only_flag   => p_third_party_only_flag
              ,p_iterative_flag              => l_iterative_flag
              ,p_iterative_priority          => l_iterative_priority
              ,p_iterative_formula_name      => l_iterative_formula
              ,p_standard_link_flag          => l_standard_link
              ,p_post_termination_rule       => p_termination_rule
              ,p_object_version_number       => l_ele_obj_ver_number
            );
         END LOOP;

         CLOSE csr_get_shadow_ele_info;
         i                          := l_ele_name.NEXT (i);
      END LOOP;

      -- Update shadow structure for Balances

      --
      hr_utility.set_location (l_proc_name, 200);

      --

      -- Employer Pension Balance

      IF l_exc_ers_rule_id IS NULL
      THEN
         l_bal_name                 :=
                                         p_ele_base_name
                                      || ' ERS Contribution';
         l_bal_new_name             :=    p_ele_base_name
                                       || ' '
                                       || p_pension_category
                                       || ' ERS Contribution';
         OPEN csr_get_shadow_bal_info (l_bal_name);

         LOOP
            FETCH csr_get_shadow_bal_info INTO l_balance_type_id
                                              ,l_bal_obj_ver_number;
            EXIT WHEN csr_get_shadow_bal_info%NOTFOUND;
            pay_sbt_upd.upd (
               p_effective_date              => p_effective_start_date
              ,p_balance_type_id             => l_balance_type_id
              ,p_balance_name                => l_bal_new_name
              ,p_object_version_number       => l_bal_obj_ver_number
            );
         END LOOP;

         CLOSE csr_get_shadow_bal_info;
      END IF; -- End if of ers exc rule is null check ...

      -- Update shadow formula with OCP base name information
      -- for AVC employee contribution
      IF l_exc_avc_rule_id IS NULL
      THEN
         -- Get the base name for associated ocp element
         l_associated_ocp_base_name :=
             get_scheme_prefix (p_element_type_id => p_associated_ocp_ele_id);
         l_associated_ocp_base_name :=
                UPPER (TRANSLATE (TRIM (l_associated_ocp_base_name), ' ', '_'));
         hr_utility.set_location (l_proc_name, 185);
         --
         l_ees_cont_formula_id      :=
                 get_shadow_formula_id (p_formula_name => l_ees_cont_formula);
         --
         hr_utility.set_location (l_proc_name, 186);
         --
         l_search_string            := '<OCP NAME>';
         l_replace_string           := l_associated_ocp_base_name;
         update_shadow_formula (
            p_formula_id                  => l_ees_cont_formula_id
           ,p_search_string               => l_search_string
           ,p_replace_string              => l_replace_string
         );
      END IF; -- End if of avc pension category check ...

      -- Update shadow formula with pension category information
      -- for employer contribution
      IF l_exc_ers_rule_id IS NULL
      THEN
         -- Update the employer contribution formula
         --
         hr_utility.set_location (l_proc_name, 191);
         --
         l_ers_cont_formula_id      :=
                 get_shadow_formula_id (p_formula_name => l_ers_cont_formula);
         --
         hr_utility.set_location (l_proc_name, 192);
         --
         l_search_string            := '<PENSION CATEGORY>';
         l_replace_string           := p_pension_category;
         update_shadow_formula (
            p_formula_id                  => l_ers_cont_formula_id
           ,p_search_string               => l_search_string
           ,p_replace_string              => l_replace_string
         );
         -- Check whether the pension category is AVC
         --
         hr_utility.set_location (l_proc_name, 193);

         --
         IF l_exc_avc_rule_id IS NULL
         THEN
            l_search_string            := '/* OCP_Opt_Out_Date Alias */';
            l_replace_string           :=
                     'ALIAS '
                  || l_associated_ocp_base_name
                  || '_EES_OCP_CONTRIBUTION_OPT_OUT_DATE_ENTRY_VALUE
                                          AS OCP_Opt_Out_Date';
            update_shadow_formula (
               p_formula_id                  => l_ers_cont_formula_id
              ,p_search_string               => l_search_string
              ,p_replace_string              => l_replace_string
            );
            l_search_string            := '/* OCP_Opt_Out_Date Default */';
            l_replace_string           :=
                  'Default for OCP_Opt_Out_Date IS ''4712/12/31 00:00:00'' (DATE)';
            update_shadow_formula (
               p_formula_id                  => l_ers_cont_formula_id
              ,p_search_string               => l_search_string
              ,p_replace_string              => l_replace_string
            );
            l_search_string            := '/* OCP_Opt_Out_Date Logic */';
            l_replace_string           :=
                  '
  /* OCP_Opt_Out_Date Logic */
  IF OCP_Opt_Out_Date WAS NOT DEFAULTED THEN
   (
     /* Check whether the date entered is lesser than the payroll
        period end date. */

     IF OCP_Opt_Out_Date <= PAY_PROC_PERIOD_END_DATE THEN
      (
        /* If lesser, then issue a warning message and stop rule */
        l_stop_entry = ''Y''
        l_warning2 = l_element_name
                   +
                     ''Employee opted out from the associated ''
                   +
                     ''occupational pension scheme.''
      )
   )';
            update_shadow_formula (
               p_formula_id                  => l_ers_cont_formula_id
              ,p_search_string               => l_search_string
              ,p_replace_string              => l_replace_string
            );
         END IF; -- End if of pension category is AVC check ...
      END IF; -- End if of ers rule id is null check ...

      -- Update shadow formulas with the pensionable salary information
      -- First get the pensionable salary name, update only if is not created

      IF p_pensionable_sal_bal_id IS NOT NULL
      THEN
         --
         hr_utility.set_location (l_proc_name, 201);
         --
         -- Get the balance name
         l_pensionable_sal_bal_name :=
             get_balance_info (p_balance_type_id => p_pensionable_sal_bal_id);
         -- Update the employee contribution formula
         --
         hr_utility.set_location (l_proc_name, 202);
         --
         l_ees_cont_formula_id      :=
                 get_shadow_formula_id (p_formula_name => l_ees_cont_formula);
         --
         hr_utility.set_location (l_proc_name, 203);
         --
         l_search_string            :=
                                  l_format_base_name
                               || '_SUPERANNUABLE_SALARY';
         l_replace_string           :=
                UPPER (TRANSLATE (TRIM (l_pensionable_sal_bal_name), ' ', '_'));
         update_shadow_formula (
            p_formula_id                  => l_ees_cont_formula_id
           ,p_search_string               => l_search_string
           ,p_replace_string              => l_replace_string
         );

         IF l_exc_ers_rule_id IS NULL
         THEN
            -- Update the employer contribution formula
            --
            hr_utility.set_location (l_proc_name, 204);
            --
            l_ers_cont_formula_id      :=
                 get_shadow_formula_id (p_formula_name => l_ers_cont_formula);
            --
            hr_utility.set_location (l_proc_name, 205);
            --
            update_shadow_formula (
               p_formula_id                  => l_ers_cont_formula_id
              ,p_search_string               => l_search_string
              ,p_replace_string              => l_replace_string
            );
         END IF; -- End if of ers rule id is null check ...

         IF l_exc_adl_rule_id IS NULL
         THEN
            -- Update the additional contribution formula
            --
            hr_utility.set_location (l_proc_name, 204);
            --
            l_adl_cont_formula_id      :=
                 get_shadow_formula_id (p_formula_name => l_adl_cont_formula);
            --
            hr_utility.set_location (l_proc_name, 205);
            --
            update_shadow_formula (
               p_formula_id                  => l_adl_cont_formula_id
              ,p_search_string               => l_search_string
              ,p_replace_string              => l_replace_string
            );
         END IF; -- End if of adl rule id is null check ...

         IF l_exc_ayr_rule_id IS NULL
         THEN
            -- Update the added years contribution formula
            --
            hr_utility.set_location (l_proc_name, 206);
            --
            l_ayr_cont_formula_id      :=
                 get_shadow_formula_id (p_formula_name => l_ayr_cont_formula);
            --
            hr_utility.set_location (l_proc_name, 207);
            --
            update_shadow_formula (
               p_formula_id                  => l_ayr_cont_formula_id
              ,p_search_string               => l_search_string
              ,p_replace_string              => l_replace_string
            );
         END IF; -- End if of ayr rule id is null check ...

         IF l_exc_fwd_rule_id IS NULL
         THEN
            -- Update the family widower contribution formula
            --
            hr_utility.set_location (l_proc_name, 208);
            --
            l_fwd_cont_formula_id      :=
                 get_shadow_formula_id (p_formula_name => l_fwd_cont_formula);
            --
            hr_utility.set_location (l_proc_name, 209);
            --
            update_shadow_formula (
               p_formula_id                  => l_fwd_cont_formula_id
              ,p_search_string               => l_search_string
              ,p_replace_string              => l_replace_string
            );
         END IF; -- End if of fwd rule id is null check ...


         IF l_exc_bb_fwc_rule_id IS NULL
         THEN
            -- Update the added years family widower contribution formula
            --
            hr_utility.set_location (l_proc_name, 206);
            --
            l_bb_fwc_cont_formula_id      :=
                 get_shadow_formula_id (p_formula_name => l_bb_fwc_cont_formula);
            --
            hr_utility.set_location (l_proc_name, 207);
            --
            update_shadow_formula (
               p_formula_id                  => l_bb_fwc_cont_formula_id
              ,p_search_string               => l_search_string
              ,p_replace_string              => l_replace_string
            );
         END IF; -- End if of ayr rule id is null check ...


      END IF; -- End if of pensionable salary bal specified check ...



-------------------------------------------------------------------------
--
--
      hr_utility.set_location (l_proc_name, 210);

---------------------------------------------------------------------------
---------------------------- Generate Core Objects ------------------------
---------------------------------------------------------------------------

      pay_element_template_api.generate_part1 (
         p_validate                    => FALSE
        ,p_effective_date              => p_effective_start_date
        ,p_hr_only                     => FALSE
        ,p_hr_to_payroll               => FALSE
        ,p_template_id                 => l_template_id
      );
      --
      hr_utility.set_location (l_proc_name, 220);
      --

      pay_element_template_api.generate_part2 (
         p_validate                    => FALSE
        ,p_effective_date              => p_effective_start_date
        ,p_template_id                 => l_template_id
      );
      --

      -- Update the default contribution value for base element
      -- or Employee Contribution Element
      -- Remember l_cont_iv_name and iv_default_value are already
      -- stored for employee contribution element

      --
      hr_utility.set_location (l_proc_name, 230);
      --
      i                          := 0;
      i                          :=   i
                                    + 1;
      update_ipval_defval (
         p_ele_name                    => l_ele_name (i)
        , -- base element name
         p_ip_name                     => l_cont_iv_name
        ,p_def_value                   => l_iv_default_value
      );

      -- Create balance feeds for <pension type> EE Contribution balance
      IF g_tab_pension_types_info (p_pension_type_id).ee_contribution_bal_type_id IS NULL
      THEN
         fnd_message.set_name ('PQP', 'PQP_230932_BAL_TYPE_NOTFOUND');
         fnd_message.set_token (
            'BALANCE_TYPE'
           ,   g_tab_pension_types_info (p_pension_type_id).pension_type_name
            || ' EE Contribution'
         );
         fnd_message.raise_error;
      END IF; -- End if of ee contribution balance is null check ...

      --
      hr_utility.set_location (l_proc_name, 240);
      --

      create_balance_feeds (
         p_balance_type_id             => g_tab_pension_types_info (
                                             p_pension_type_id
                                          ).ee_contribution_bal_type_id
        ,p_element_name                => l_ele_name (i)
        ,p_input_value_name            => 'Pay Value'
        ,p_scale                       => 1
      );
      -- update the default contribution value for employer contribution
      -- element
      -- Remember there may be two elements created for employer contribution
      -- so check them before you update the default values
      -- safe assumption would be to start checking the exclusion rule

      --
      hr_utility.set_location (l_proc_name, 250);

      --

      IF l_exc_ers_cent_rule_id IS NULL
      THEN
         i                          :=   i
                                       + 1;
         -- Contribution Percent for Employer is present
         update_ipval_defval (
            p_ele_name                    => l_ele_name (
                                                i
                                             ) -- employer contribution %
           ,p_ip_name                     => 'Contribution Percent'
           ,p_def_value                   => g_tab_pension_types_info (
                                                p_pension_type_id
                                             ).er_contribution_percent
         );

         -- Create balance feeds for <pension type> ER Contribution balance
         IF g_tab_pension_types_info (p_pension_type_id).er_contribution_bal_type_id IS NULL
         THEN
            fnd_message.set_name ('PQP', 'PQP_230932_BAL_TYPE_NOTFOUND');
            fnd_message.set_token (
               'BALANCE_TYPE'
              ,   g_tab_pension_types_info (p_pension_type_id).pension_type_name
               || ' ER Contribution'
            );
            fnd_message.raise_error;
         END IF; -- End if of er contribution balance is null check ...

         --
         hr_utility.set_location (l_proc_name, 260);
         --

         create_balance_feeds (
            p_balance_type_id             => g_tab_pension_types_info (
                                                p_pension_type_id
                                             ).er_contribution_bal_type_id
           ,p_element_name                => l_ele_name (i)
           ,p_input_value_name            => 'Pay Value'
           ,p_scale                       => 1
         );
      END IF; -- End if of employer percent rule is null check ...

      --
      hr_utility.set_location (l_proc_name, 270);

      --

      IF l_exc_ers_fxd_rule_id IS NULL
      THEN
         i                          :=   i
                                       + 1;
         -- Contribution Fixed Rate for Employer is present
         update_ipval_defval (
            p_ele_name                    => l_ele_name (
                                                i
                                             ) -- employer contribution FR
           ,p_ip_name                     => 'Contribution Amount'
           ,p_def_value                   => g_tab_pension_types_info (
                                                p_pension_type_id
                                             ).er_contribution_fixed_rate
         );

         -- Create balance feeds for <pension type> ER Contribution balance
         IF g_tab_pension_types_info (p_pension_type_id).er_contribution_bal_type_id IS NULL
         THEN
            fnd_message.set_name ('PQP', 'PQP_230932_BAL_TYPE_NOTFOUND');
            fnd_message.set_token (
               'BALANCE_TYPE'
              ,   g_tab_pension_types_info (p_pension_type_id).pension_type_name
               || ' ER Contribution'
            );
            fnd_message.raise_error;
         END IF; -- End if of er contribution balance is null check ...

         --
         hr_utility.set_location (l_proc_name, 280);
         --

         create_balance_feeds (
            p_balance_type_id             => g_tab_pension_types_info (
                                                p_pension_type_id
                                             ).er_contribution_bal_type_id
           ,p_element_name                => l_ele_name (i)
           ,p_input_value_name            => 'Pay Value'
           ,p_scale                       => 1
         );
      END IF; -- End if of employer fixed rate rule is null check ...

      --
      hr_utility.set_location (l_proc_name, 290);
      --

      l_base_element_type_id     := get_object_id ('ELE', l_ele_name (1));
      --
      hr_utility.set_location (l_proc_name, 295);
      --
      -- Get pensionable salary details
      l_pensionable_sal_bal_id   := NULL;

      IF p_pensionable_sal_bal_id IS NULL
      THEN
         l_pensionable_sal_bal_id   :=
               get_object_id (
                  'BAL'
                 ,   p_ele_base_name
                  || ' Superannuable Salary'
               );
      ELSE -- pensionable sal present
         l_pensionable_sal_bal_id   := p_pensionable_sal_bal_id;
      END IF; -- End if of pensionable sal is null check ...

      IF l_pensionable_sal_bal_id IS NULL
      THEN
         fnd_message.set_name ('PQP', 'PQP_230932_BAL_TYPE_NOTFOUND');
         fnd_message.set_token ('BALANCE_TYPE', 'Superannuable Salary');
         fnd_message.raise_error;
      END IF; -- End if of local pensionable sal id is null check ...

      -- Create sub classification rule for the company pension base element
      -- create only if it is pre tax and scheme type is comp/cosr
      -- and pension category is OCP
      IF      l_ele_class_name = 'Pre Tax Deductions'
          AND p_pension_category = 'OCP'
          AND NVL (p_pension_scheme_type, hr_api.g_varchar2) IN
                                                              ('COSR', 'COMP')
      THEN
         l_sub_class_name           :=
                          'Pre Tax Employee Pension '
                       || p_pension_scheme_type;
         --
         hr_utility.set_location (l_proc_name, 300);
         --

         create_sub_class_rules (
            p_classification_name         => l_sub_class_name
           ,p_element_type_id             => l_base_element_type_id
         );
      END IF; -- End if of class name = pre tax check ...

      -- Set EEIT with Arrears information type "PQP_GB_ARREARAGE_INFO" for
      -- base element and additional elements
      -- PS EER contribution element should not have an arrear information set
      -- Also within the same loop we could create EEIT rows with the relevant
      -- information for pension scheme information type "PQP_GB_PENSION_SCHEME_INFO"

      -- Create EEIT for the base element as the values are different

      --
      hr_utility.set_location (l_proc_name, 310);
      --
      -- Create a row in pay_element_extra_info with all the element information

      pay_element_extra_info_api.create_element_extra_info (
         p_element_type_id             => l_base_element_type_id
        ,p_information_type            => 'PQP_GB_PENSION_SCHEME_INFO'
        ,p_eei_information_category    => 'PQP_GB_PENSION_SCHEME_INFO'
        ,p_eei_information1            => p_pension_scheme_name -- pension scheme name
        ,p_eei_information2            => fnd_number.number_to_canonical (
                                             p_pension_provider_id
                                          ) -- pension provider
        ,p_eei_information3            => fnd_number.number_to_canonical (
                                             p_pension_type_id
                                          ) -- pension type
        ,p_eei_information4            => p_pension_category -- pension category
        ,p_eei_information5            => fnd_date.date_to_canonical (
                                             p_pension_year_start_dt
                                          ) -- pension year start date
        ,p_eei_information6            => l_emp_deduction_method -- employee deduction method
        ,p_eei_information7            => p_eer_deduction_method -- employer deduction method
        ,p_eei_information8            => p_pension_scheme_type -- scheme type
        ,p_eei_information9            => p_scon_number -- SCON
        ,p_eei_information10           => p_scheme_reference_no -- Scheme Number
        ,p_eei_information11           => p_employer_reference_no -- Employer Reference Number
        ,p_eei_information12           => NULL -- Base pension scheme
        ,p_eei_information13           => p_additional_contribution -- Additional Contributions
        ,p_eei_information14           => p_added_years -- Added Years
        ,p_eei_information15           => p_family_widower -- Family or Widower Benefit
        ,p_eei_information16           => fnd_number.number_to_canonical (
                                             p_associated_ocp_ele_id
                                          ) -- Associated OCP Scheme
        ,p_eei_information17           => fnd_number.number_to_canonical (
                                             l_pensionable_sal_bal_id
                                          ) -- Pensionable Salary Balance
        ,p_eei_information18           => p_ele_base_name -- Scheme Prefix
        ,p_eei_information19           => p_econ_number -- ECON ( BUG 4108320 )
        ,p_eei_information20           => p_fwc_added_years -- Family Widower Added Years
        ,p_element_type_extra_info_id  => l_eei_info_id
        ,p_object_version_number       => l_ovn_eei
      );
      --
      hr_utility.set_location (l_proc_name, 320);
      --

      -- Create a row in pay_element_extra_info with arrearage information
      pay_element_extra_info_api.create_element_extra_info (
         p_element_type_id             => l_base_element_type_id
        ,p_information_type            => 'PQP_GB_ARREARAGE_INFO'
        ,p_eei_information_category    => 'PQP_GB_ARREARAGE_INFO'
        ,p_eei_information1            => l_arrearage_allowed
        , -- Arrears Allowed
         p_eei_information2            => l_partial_deduction
        , -- Partial Deduction Allowed
         p_element_type_extra_info_id  => l_eei_info_id
        ,p_object_version_number       => l_ovn_eei
      );
      -- Delete the collection that holds the formula ids before requesting
      -- compilation
      g_tab_formula_ids.DELETE;
      -- Compile formula attached with this base element
      --
      hr_utility.set_location (l_proc_name, 330);
      --
      compile_formula (p_element_type_id => l_base_element_type_id);

      FOR i IN 2 .. l_ele_name.COUNT
      LOOP
         hr_utility.set_location (l_proc_name, 340);
         l_eei_element_type_id      := get_object_id ('ELE', l_ele_name (i));
         --
         hr_utility.set_location (l_proc_name, 350);
         --


         --- bug fix : 5128634
         -- if this is a Family Widower element, store the element id
         IF l_ele_name (i) IN (   p_ele_base_name
                                   || ' Family Widower'
                                  )
         THEN
           l_fwc_element_type_id   := l_eei_element_type_id;
         END IF;

         -- if this is a Family Widower fixed element, store the element id
         IF l_ele_name (i) IN (   p_ele_base_name
                                   || ' Family Widower Fixed'
                                   )
         THEN
           l_fwc_element_type_id_fixed   := l_eei_element_type_id;
         END IF;

         -- if this is a Family Widower Added years element, store the element id of FWC main element(s)
         IF l_ele_name (i) IN (   p_ele_base_name
                                   || ' Buy Back FWC'
                                , p_ele_base_name
                                  || ' Buy Back FWC Fixed'
                                  )
         THEN

           -- if PEFR, the store FW_id in 21, and FW_fixed_id in 22
           IF  l_fwc_element_type_id IS NOT NULL
             AND
               l_fwc_element_type_id_fixed IS NOT NULL
           THEN
             l_base_fwc_element_type_id       := l_fwc_element_type_id;
             l_base_fwc_element_type_id_fix   := l_fwc_element_type_id_fixed;
           ELSIF l_fwc_element_type_id IS NOT NULL -- this is PE, hence store FW_id in both
           THEN
             l_base_fwc_element_type_id       := l_fwc_element_type_id;
             l_base_fwc_element_type_id_fix   := NULL;
           ELSIF l_fwc_element_type_id_fixed IS NOT NULL -- -- this is FR, hence store FW_fixed_id in both
           THEN
             l_base_fwc_element_type_id       := NULL;
             l_base_fwc_element_type_id_fix   := l_fwc_element_type_id_fixed;
           ELSE -- ideally this shd not arise, as it is PE/FR/PEFR
             l_base_fwc_element_type_id       := NULL;
             l_base_fwc_element_type_id_fix   := NULL;
           END IF;

         ELSE -- not a FWC added_years element, hence null
           l_base_fwc_element_type_id       := NULL;
           l_base_fwc_element_type_id_fix   := NULL;
         END IF;



         --
         -- Create a row in pay_element_extra_info with all the element information

         pay_element_extra_info_api.create_element_extra_info (
            p_element_type_id             => l_eei_element_type_id
           ,p_information_type            => 'PQP_GB_PENSION_SCHEME_INFO'
           ,p_eei_information_category    => 'PQP_GB_PENSION_SCHEME_INFO'
           ,p_eei_information1            => p_pension_scheme_name -- pension scheme name
           ,p_eei_information2            => fnd_number.number_to_canonical (
                                                p_pension_provider_id
                                             ) -- pension provider
           ,p_eei_information3            => fnd_number.number_to_canonical (
                                                p_pension_type_id
                                             ) -- pension type
           ,p_eei_information4            => p_pension_category -- pension category
           ,p_eei_information5            => fnd_date.date_to_canonical (
                                                p_pension_year_start_dt
                                             ) -- pension year start date
           ,p_eei_information6            => l_emp_deduction_method -- employee deduction method
           ,p_eei_information7            => p_eer_deduction_method -- employer deduction method
           ,p_eei_information9            => p_scon_number -- SCON
           ,p_eei_information10           => p_scheme_reference_no -- Scheme Number
           ,p_eei_information11           => p_employer_reference_no -- Employer Reference Number
           ,p_eei_information12           => fnd_number.number_to_canonical (
                                                l_base_element_type_id
                                             ) -- Base pension scheme
           ,p_eei_information16           => fnd_number.number_to_canonical (
                                                p_associated_ocp_ele_id
                                             ) -- Associated OCP Scheme
           ,p_eei_information17           => fnd_number.number_to_canonical (
                                                l_pensionable_sal_bal_id
                                             ) -- Pensionable Salary Balance
           ,p_eei_information18           => p_ele_base_name -- Scheme Prefix
           ,p_eei_information19           => p_econ_number -- ECON ( BUG 4108320 )
           ,p_eei_information20           => p_fwc_added_years -- Family Widower Added Years
           ,p_eei_information21           => fnd_number.number_to_canonical (
                                                l_base_fwc_element_type_id
                                                ) -- Family Widower base element type_id :5128634
           ,p_eei_information22           => fnd_number.number_to_canonical (
                                                l_base_fwc_element_type_id_fix
                                                ) -- Family Widower base element type_id :5128634

           ,p_element_type_extra_info_id  => l_eei_info_id
           ,p_object_version_number       => l_ovn_eei
         );
         --
         hr_utility.set_location (l_proc_name, 360);

         --

         -- Do not create arrear info for ers contribution..
         IF l_ele_name (i) NOT IN (   p_ele_base_name
                                   || ' ERS '
                                   || p_pension_category
                                   || ' Contribution'
                                  ,   p_ele_base_name
                                   || ' ERS '
                                   || p_pension_category
                                   || ' Contribution Fixed'
                                  )
         THEN
            -- Create a row in pay_element_extra_info with arrearage information
            pay_element_extra_info_api.create_element_extra_info (
               p_element_type_id             => l_eei_element_type_id
              ,p_information_type            => 'PQP_GB_ARREARAGE_INFO'
              ,p_eei_information_category    => 'PQP_GB_ARREARAGE_INFO'
              ,p_eei_information1            => l_arrearage_allowed
              , -- Arrears Allowed
               p_eei_information2            => l_partial_deduction
              , -- Partial Deduction Allowed
               p_element_type_extra_info_id  => l_eei_info_id
              ,p_object_version_number       => l_ovn_eei
            );
         END IF; -- End if of ele name not in ERS cont check ...

         -- Compile formula attached with this base element
         --
         hr_utility.set_location (l_proc_name, 370);
         --
         compile_formula (p_element_type_id => l_eei_element_type_id);
      END LOOP;

      hr_utility.set_location (   'Leaving :'
                               || l_proc_name, 380);
      RETURN l_base_element_type_id;
   --
   END create_user_template_low;


--
/*========================================================================
 *                        CREATE_USER_TEMPLATE
 *=======================================================================*/
   FUNCTION create_user_template (
      p_pension_scheme_name       IN   VARCHAR2
     ,p_pension_year_start_dt     IN   DATE
     ,p_pension_category          IN   VARCHAR2
     ,p_pension_provider_id       IN   NUMBER
     ,p_pension_type_id           IN   NUMBER
     ,p_emp_deduction_method      IN   VARCHAR2
     ,p_ele_base_name             IN   VARCHAR2
     ,p_effective_start_date      IN   DATE
     ,p_ele_reporting_name        IN   VARCHAR2
     ,p_ele_classification_id     IN   NUMBER
     ,p_business_group_id         IN   NUMBER
     ,p_eer_deduction_method      IN   VARCHAR2
     ,p_scon_number               IN   VARCHAR2
     ,p_econ_number               IN   VARCHAR2  -- BUG 4108320
     ,p_additional_contribution   IN   VARCHAR2
     ,p_added_years               IN   VARCHAR2
     ,p_family_widower            IN   VARCHAR2
     ,p_fwc_added_years           IN   VARCHAR2
     ,p_scheme_reference_no       IN   VARCHAR2
     ,p_employer_reference_no     IN   VARCHAR2
     ,p_associated_ocp_ele_id     IN   NUMBER
     ,p_ele_description           IN   VARCHAR2
     ,p_pension_scheme_type       IN   VARCHAR2
     ,p_pensionable_sal_bal_id    IN   NUMBER
     ,p_third_party_only_flag     IN   VARCHAR2
     ,p_iterative_processing      IN   VARCHAR2
     ,p_arrearage_allowed         IN   VARCHAR2
     ,p_partial_deduction         IN   VARCHAR2
     ,p_termination_rule          IN   VARCHAR2
     ,p_standard_link             IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      --


      /*---------------------------------------------------------------------------
       The input values are explained below : V-varchar2, D-Date, N-number
         Input-Name                  Type   Valid Values/Explaination
         ----------                  ----
         --------------------------------------------------------------------------
         p_pension_scheme_name       (V) - User i/p Scheme Name
         p_pension_year_start_dt     (D) - User i/p Date
         p_pension_category          (V) - LOV based i/p (OCP/AVC/SHP/FSAVC/PEP)
         p_pension_provider_ip       (N) - LOV based i/p
         p_pension_type_id           (N) - LOV based i/p
         p_emp_deduction_method      (V) - LOV based i/p (PE/FR/PEFR)
         p_ele_base_name             (V) - User i/p Base Name
         p_effective_start_date      (D) - User i/p Date
         p_ele_reporting_name        (V) - User i/p Reporting Name
         p_ele_classification_id     (N) - LOV based i/p
         p_business_group_id         (N) - User i/p Business Group
         p_eer_deduction_method      (V) - LOV based i/p (PE/FR/PEFR)
         p_scon_number               (V) - User i/p SCON
         p_additional_contribution   (V) - LOV based i/p (PE/FR/PEFR)
         p_added_years               (V) - LOV based i/p (PE/FR/PEFR)
         p_family_widower            (V) - LOV based i/p (PE/FR/PEFR)
         p_fwc_added_years           (V) - LOV based i/p (PE/FR/PEFR)
         p_scheme_reference_no       (V) - User i/p Scheme Reference Number
         p_employer_reference_no     (V) - User i/p Employer Reference Number
         p_associated_ocp_ele_id     (N) - LOV based i/p
         p_ele_description           (V) - User i/p Element Description
         p_pension_scheme_type       (V) - LOV based i/p (COSR/COMP)
         p_pensionable_sal_bal_id    (N) - LOV based i/p
         p_third_party_only_flag     (V) - Check box based i/p (Y/N) Default N
         p_iterative_processing      (V) - Check box based i/p (Y/N) Default N
         p_arrearage_allowed         (V) - Check box based i/p (Y/N) Default N
         p_partial_deduction         (V) - Check box based i/p (Y/N) Default N
         p_termination_rule          (V) - Radio button based i/p (A/F/L) Default L
         p_standard_link             (V) - Check box based i/p (Y/N) Default N

      -----------------------------------------------------------------------------*/
      --
      l_element_type_id          NUMBER;
      l_proc_name                VARCHAR2 (80)
                                    :=    g_proc_name
                                       || 'create_user_template';
      l_effective_start_date     DATE          := TRUNC (
                                                     p_effective_start_date
                                                  );

      -- Cursor to get pensionable salary balance information
      CURSOR csr_get_pens_bal_id (c_element_type_id NUMBER)
      IS
         SELECT fnd_number.canonical_to_number (eei_information17)
           FROM pay_element_type_extra_info
          WHERE element_type_id = c_element_type_id
            AND information_type = 'PQP_GB_PENSION_SCHEME_INFO';

      l_pensionable_sal_bal_id   NUMBER;


--
--==============================================================================
--|--------------------------< chk_scheme_name >-------------------------------|
--==============================================================================
      PROCEDURE chk_scheme_name
      IS
         --
         CURSOR csr_chk_uniq_sch_name
         IS
            SELECT 'X'
              FROM DUAL
             WHERE EXISTS ( SELECT 1
                              FROM pay_element_type_extra_info eei
                                  ,pay_element_types_f pet
                             WHERE pet.element_type_id = eei.element_type_id
                               AND pet.business_group_id =
                                                          p_business_group_id
                               AND eei.information_type =
                                                 'PQP_GB_PENSION_SCHEME_INFO'
                               AND UPPER (eei.eei_information1) =
                                                UPPER (p_pension_scheme_name)
                               AND eei.eei_information12 IS NULL);

         l_proc_name   VARCHAR2 (80) :=    g_proc_name
                                        || 'chk_scheme_name';
         l_exists      VARCHAR2 (1);
      --
      BEGIN
         --
         hr_utility.set_location (   'Entering: '
                                  || l_proc_name, 10);
         --

         OPEN csr_chk_uniq_sch_name;
         FETCH csr_chk_uniq_sch_name INTO l_exists;

         IF csr_chk_uniq_sch_name%FOUND
         THEN
            CLOSE csr_chk_uniq_sch_name;
            fnd_message.set_name ('PQP', 'PQP_230924_SCHEME_NAME_ERR');
            hr_multi_message.add
	           (p_associated_column1
	             => 'PQP_GB_PENSION_SCHEMES_V.PENSION_SCHEME_NAME'
	           );
         END IF; -- End if of csr uniq row found check ...

         IF csr_chk_uniq_sch_name%ISOPEN THEN
            CLOSE csr_chk_uniq_sch_name;
         END IF; -- Cursor is open check ...
         --
         hr_utility.set_location (   'Leaving: '
                                  || l_proc_name, 20);
      --
      END chk_scheme_name;

  --
--
--==============================================================================
--|------------------------------< Main Function >-----------------------------|
--==============================================================================

   BEGIN
      --
      hr_utility.set_location (   'Entering : '
                               || l_proc_name, 10);
      --

---------------------
-- Set session date
---------------------

      pay_db_pay_setup.set_session_date (
         NVL (l_effective_start_date, SYSDATE)
      );
      --
      hr_utility.set_location (l_proc_name, 20);

      --

      IF (hr_utility.chk_product_install (
             'Oracle Payroll'
            ,g_template_leg_code
          )
         )
      THEN
         -- Check scheme name for its uniqueness
         chk_scheme_name;
         --
         hr_utility.set_location (l_proc_name, 25);
         -- Delete the pension type collection
         g_tab_pension_types_info.DELETE;


--

         -- Check employee deduction method
         IF p_emp_deduction_method = 'PEFR'
         THEN
            -- Set the same base name but pass percentage first
            --
            hr_utility.set_location (l_proc_name, 30);
            --
            l_element_type_id          :=
                  create_user_template_low (
                     p_pension_scheme_name         => p_pension_scheme_name
                    ,p_pension_year_start_dt       => p_pension_year_start_dt
                    ,p_pension_category            => p_pension_category
                    ,p_pension_provider_id         => p_pension_provider_id
                    ,p_pension_type_id             => p_pension_type_id
                    ,p_emp_deduction_method        => 'PEFR'
                    ,p_ele_base_name               => p_ele_base_name
                    ,p_effective_start_date        => l_effective_start_date
                    ,p_ele_reporting_name          => p_ele_reporting_name
                    ,p_ele_classification_id       => p_ele_classification_id
                    ,p_business_group_id           => p_business_group_id
                    ,p_eer_deduction_method        => p_eer_deduction_method
                    ,p_scon_number                 => p_scon_number
                    ,p_econ_number                 => p_econ_number  -- BUG 4108320
                    ,p_additional_contribution     => p_additional_contribution
                    ,p_added_years                 => p_added_years
                    ,p_family_widower              => p_family_widower
                    ,p_fwc_added_years             => p_fwc_added_years
                    ,p_scheme_reference_no         => p_scheme_reference_no
                    ,p_employer_reference_no       => p_employer_reference_no
                    ,p_associated_ocp_ele_id       => p_associated_ocp_ele_id
                    ,p_ele_description             => p_ele_description
                    ,p_pension_scheme_type         => p_pension_scheme_type
                    ,p_pensionable_sal_bal_id      => p_pensionable_sal_bal_id
                    ,p_third_party_only_flag       => p_third_party_only_flag
                    ,p_iterative_processing        => p_iterative_processing
                    ,p_arrearage_allowed           => p_arrearage_allowed
                    ,p_partial_deduction           => p_partial_deduction
                    ,p_termination_rule            => p_termination_rule
                    ,p_standard_link               => p_standard_link
                    ,p_validate                    => TRUE
                  );
            -- Get the pensionable salary balance if a new one is created above
            -- so that the same information is used for the fixed rate element

            --
            hr_utility.set_location (l_proc_name, 35);

            --

            IF p_pensionable_sal_bal_id IS NULL
            THEN
               -- Get the balance id
               OPEN csr_get_pens_bal_id (l_element_type_id);
               FETCH csr_get_pens_bal_id INTO l_pensionable_sal_bal_id;
               CLOSE csr_get_pens_bal_id;
            ELSE -- pensionable_sal_bal_id entered
               l_pensionable_sal_bal_id   := p_pensionable_sal_bal_id;
            END IF; -- End if of pensionable sal bal id null check ...

            -- Change the base name and pass FR now
            --
            hr_utility.set_location (l_proc_name, 40);
            --
            l_element_type_id          :=
                  create_user_template_low (
                     p_pension_scheme_name         => p_pension_scheme_name
                    ,p_pension_year_start_dt       => p_pension_year_start_dt
                    ,p_pension_category            => p_pension_category
                    ,p_pension_provider_id         => p_pension_provider_id
                    ,p_pension_type_id             => p_pension_type_id
                    ,p_emp_deduction_method        => 'FR'
                    ,p_ele_base_name               =>    p_ele_base_name
                                                      || ' Fixed'
                    ,p_effective_start_date        => l_effective_start_date
                    ,p_ele_reporting_name          => p_ele_reporting_name
                    ,p_ele_classification_id       => p_ele_classification_id
                    ,p_business_group_id           => p_business_group_id
                    ,p_eer_deduction_method        => NULL
                    ,p_scon_number                 => p_scon_number
                    ,p_econ_number                 => p_econ_number  -- BUG 4108320
                    ,p_additional_contribution     => NULL
                    ,p_added_years                 => NULL
                    ,p_family_widower              => NULL
                    ,p_fwc_added_years             => NULL
                    ,p_scheme_reference_no         => p_scheme_reference_no
                    ,p_employer_reference_no       => p_employer_reference_no
                    ,p_associated_ocp_ele_id       => p_associated_ocp_ele_id
                    ,p_ele_description             => p_ele_description
                    ,p_pension_scheme_type         => p_pension_scheme_type
                    ,p_pensionable_sal_bal_id      => l_pensionable_sal_bal_id
                    ,p_third_party_only_flag       => p_third_party_only_flag
                    ,p_iterative_processing        => p_iterative_processing
                    ,p_arrearage_allowed           => p_arrearage_allowed
                    ,p_partial_deduction           => p_partial_deduction
                    ,p_termination_rule            => p_termination_rule
                    ,p_standard_link               => p_standard_link
                    ,p_validate                    => FALSE
                  );
         ELSE -- not PEFR
            -- Call the low level function with the same parameters
            --
            hr_utility.set_location (l_proc_name, 50);
            --
            l_element_type_id          :=
                  create_user_template_low (
                     p_pension_scheme_name         => p_pension_scheme_name
                    ,p_pension_year_start_dt       => p_pension_year_start_dt
                    ,p_pension_category            => p_pension_category
                    ,p_pension_provider_id         => p_pension_provider_id
                    ,p_pension_type_id             => p_pension_type_id
                    ,p_emp_deduction_method        => p_emp_deduction_method
                    ,p_ele_base_name               => p_ele_base_name
                    ,p_effective_start_date        => l_effective_start_date
                    ,p_ele_reporting_name          => p_ele_reporting_name
                    ,p_ele_classification_id       => p_ele_classification_id
                    ,p_business_group_id           => p_business_group_id
                    ,p_eer_deduction_method        => p_eer_deduction_method
                    ,p_scon_number                 => p_scon_number
                    ,p_econ_number                 => p_econ_number  -- BUG 4108320
                    ,p_additional_contribution     => p_additional_contribution
                    ,p_added_years                 => p_added_years
                    ,p_family_widower              => p_family_widower
                    ,p_fwc_added_years             => p_fwc_added_years
                    ,p_scheme_reference_no         => p_scheme_reference_no
                    ,p_employer_reference_no       => p_employer_reference_no
                    ,p_associated_ocp_ele_id       => p_associated_ocp_ele_id
                    ,p_ele_description             => p_ele_description
                    ,p_pension_scheme_type         => p_pension_scheme_type
                    ,p_pensionable_sal_bal_id      => p_pensionable_sal_bal_id
                    ,p_third_party_only_flag       => p_third_party_only_flag
                    ,p_iterative_processing        => p_iterative_processing
                    ,p_arrearage_allowed           => p_arrearage_allowed
                    ,p_partial_deduction           => p_partial_deduction
                    ,p_termination_rule            => p_termination_rule
                    ,p_standard_link               => p_standard_link
                    ,p_validate                    => TRUE
                  );
         END IF; -- End if of emp deduction method = PEFR check ...
      ELSE
         hr_utility.set_message (8303, 'PQP_230535_GBORAPAY_NOT_FOUND');
         hr_utility.raise_error;
      END IF; -- IF chk_product_install('Oracle Payroll',g_template_leg_code))

      --
      hr_utility.set_location (   'Leaving: '
                               || l_proc_name, 60);
      --

      RETURN l_element_type_id;
   --
   END create_user_template;

   --

/*========================================================================
 *                        CREATE_USER_TEMPLATE_SWI
 *=======================================================================*/
   FUNCTION create_user_template_swi (
      p_pension_scheme_name       IN   VARCHAR2
     ,p_pension_year_start_dt     IN   DATE
     ,p_pension_category          IN   VARCHAR2
     ,p_pension_provider_id       IN   NUMBER
     ,p_pension_type_id           IN   NUMBER
     ,p_emp_deduction_method      IN   VARCHAR2
     ,p_ele_base_name             IN   VARCHAR2
     ,p_effective_start_date      IN   DATE
     ,p_ele_reporting_name        IN   VARCHAR2
     ,p_ele_classification_id     IN   NUMBER
     ,p_business_group_id         IN   NUMBER
     ,p_eer_deduction_method      IN   VARCHAR2
     ,p_scon_number               IN   VARCHAR2
     ,p_econ_number               IN   VARCHAR2  -- BUG 4108320
     ,p_additional_contribution   IN   VARCHAR2
     ,p_added_years               IN   VARCHAR2
     ,p_family_widower            IN   VARCHAR2
     ,p_fwc_added_years           IN   VARCHAR2
     ,p_scheme_reference_no       IN   VARCHAR2
     ,p_employer_reference_no     IN   VARCHAR2
     ,p_associated_ocp_ele_id     IN   NUMBER
     ,p_ele_description           IN   VARCHAR2
     ,p_pension_scheme_type       IN   VARCHAR2
     ,p_pensionable_sal_bal_id    IN   NUMBER
     ,p_third_party_only_flag     IN   VARCHAR2
     ,p_iterative_processing      IN   VARCHAR2
     ,p_arrearage_allowed         IN   VARCHAR2
     ,p_partial_deduction         IN   VARCHAR2
     ,p_termination_rule          IN   VARCHAR2
     ,p_standard_link             IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      --
      -- Variables for API Boolean parameters
      l_validate          BOOLEAN;
      --
      -- Variables for IN/OUT parameters
      l_element_type_id   NUMBER;
      --
      -- Other variables
      l_return_status     VARCHAR2 (1);
      l_proc_name         VARCHAR2 (80)
                                :=    g_proc_name
                                   || 'create_user_template_swi';
   BEGIN

--*********************************
-- AG IMP !!
--    hr_utility.trace_on(NULL, 'ag_pension');


 hr_utility.set_location('p_pension_scheme_name     :'   ||p_pension_scheme_name ,5);
 hr_utility.set_location('p_pension_year_start_dt   :'   ||p_pension_year_start_dt ,5);
 hr_utility.set_location(' p_pension_category       :'   ||p_pension_category        ,5);
 hr_utility.set_location(' p_pension_provider_id    :'   ||p_pension_provider_id     ,5);
 hr_utility.set_location(' p_pension_type_id        :'   ||p_pension_type_id         ,5);
 hr_utility.set_location(' p_emp_deduction_method   :'   ||p_emp_deduction_method    ,5);
 hr_utility.set_location(' p_ele_base_name          :'   ||p_ele_base_name           ,5);
 hr_utility.set_location(' p_effective_start_date   :'   ||p_effective_start_date    ,5);
 hr_utility.set_location(' p_ele_reporting_name     :'   ||p_ele_reporting_name      ,5);
 hr_utility.set_location(' p_ele_classification_id  :'   ||p_ele_classification_id   ,5);
 hr_utility.set_location(' p_business_group_id      :'   ||p_business_group_id       ,5);
 hr_utility.set_location(' p_eer_deduction_method   :'   ||p_eer_deduction_method    ,5);
 hr_utility.set_location(' p_scon_number            :'   ||p_scon_number             ,5);
 hr_utility.set_location(' p_econ_number            :'   ||p_econ_number             ,5);
 hr_utility.set_location(' p_additional_contribution:'   ||p_additional_contribution ,5);
 hr_utility.set_location(' p_added_years            :'   ||p_added_years             ,5);
 hr_utility.set_location(' p_family_widower         :'   ||p_family_widower          ,5);
 hr_utility.set_location(' p_fwc_added_years        :'   ||p_fwc_added_years         ,5);
 hr_utility.set_location(' p_scheme_reference_no    :'   ||p_scheme_reference_no     ,5);
 hr_utility.set_location(' p_employer_reference_no  :'   ||p_employer_reference_no   ,5);
 hr_utility.set_location(' p_associated_ocp_ele_id  :'   ||p_associated_ocp_ele_id   ,5);
 hr_utility.set_location(' p_ele_description        :'   ||p_ele_description         ,5);
 hr_utility.set_location(' p_pension_scheme_type    :'   ||p_pension_scheme_type     ,5);
 hr_utility.set_location(' p_pensionable_sal_bal_id :'   ||p_pensionable_sal_bal_id  ,5);
 hr_utility.set_location(' p_third_party_only_flag  :'   ||p_third_party_only_flag   ,5);
 hr_utility.set_location(' p_iterative_processing   :'   ||p_iterative_processing    ,5);
 hr_utility.set_location(' p_arrearage_allowed      :'   ||p_arrearage_allowed       ,5);
 hr_utility.set_location(' p_partial_deduction      :'   ||p_partial_deduction       ,5);
 hr_utility.set_location(' p_termination_rule       :'   ||p_termination_rule        ,5);
 hr_utility.set_location(' p_standard_link          :'   ||p_standard_link           ,5);

--**********************************

      hr_utility.set_location (   ' Entering:'
                               || l_proc_name, 10);
      l_element_type_id          := -1;
      --
      -- Issue a savepoint
      --
      SAVEPOINT create_user_template_swi;
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
      l_validate                 :=
          hr_api.constant_to_boolean (p_constant_value => hr_api.g_false_num);
      --
      -- Register Surrogate ID or user key values
      --
      --
      -- Call API
      --
      --
      hr_utility.set_location (l_proc_name, 20);
      --
      l_element_type_id          :=
            create_user_template (
               p_pension_scheme_name         => p_pension_scheme_name
              ,p_pension_year_start_dt       => p_pension_year_start_dt
              ,p_pension_category            => p_pension_category
              ,p_pension_provider_id         => p_pension_provider_id
              ,p_pension_type_id             => p_pension_type_id
              ,p_emp_deduction_method        => p_emp_deduction_method
              ,p_ele_base_name               => p_ele_base_name
              ,p_effective_start_date        => p_effective_start_date
              ,p_ele_reporting_name          => p_ele_reporting_name
              ,p_ele_classification_id       => p_ele_classification_id
              ,p_business_group_id           => p_business_group_id
              ,p_eer_deduction_method        => p_eer_deduction_method
              ,p_scon_number                 => p_scon_number
              ,p_econ_number                 => p_econ_number
              ,p_additional_contribution     => p_additional_contribution
              ,p_added_years                 => p_added_years
              ,p_family_widower              => p_family_widower
              ,p_fwc_added_years             => p_fwc_added_years
              ,p_scheme_reference_no         => p_scheme_reference_no
              ,p_employer_reference_no       => p_employer_reference_no
              ,p_associated_ocp_ele_id       => p_associated_ocp_ele_id
              ,p_ele_description             => p_ele_description
              ,p_pension_scheme_type         => p_pension_scheme_type
              ,p_pensionable_sal_bal_id      => p_pensionable_sal_bal_id
              ,p_third_party_only_flag       => p_third_party_only_flag
              ,p_iterative_processing        => p_iterative_processing
              ,p_arrearage_allowed           => p_arrearage_allowed
              ,p_partial_deduction           => p_partial_deduction
              ,p_termination_rule            => p_termination_rule
              ,p_standard_link               => p_standard_link
            );

      hr_utility.set_location (   'l_element_type_id: ' || l_element_type_id, 25);
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
      l_return_status            :=
                                   hr_multi_message.get_return_status_disable;
      hr_utility.set_location (   ' Leaving:'
                               || l_proc_name, 30);
      RETURN l_element_type_id;
   --
   EXCEPTION
      WHEN hr_multi_message.error_message_exist
      THEN
         --
         -- Catch the Multiple Message List exception which
         -- indicates API processing has been aborted because
         -- at least one message exists in the list.
         --
         ROLLBACK TO create_user_template_swi;
         --
         -- Reset IN OUT parameters and set OUT parameters
         --
         RETURN l_element_type_id;
         hr_utility.set_location (   ' Leaving:'
                                  || l_proc_name, 40);
      WHEN OTHERS
      THEN
         --
         -- When Multiple Message Detection is enabled catch
         -- any Application specific or other unexpected
         -- exceptions.  Adding appropriate details to the
         -- Multiple Message List.  Otherwise re-raise the
         -- error.
         --
         ROLLBACK TO create_user_template_swi;

         IF hr_multi_message.unexpected_error_add (l_proc_name)
         THEN
            hr_utility.set_location (   ' Leaving:'
                                     || l_proc_name, 50);
            RAISE;
         END IF;

         --
         -- Reset IN OUT and set OUT parameters
         --
         l_return_status            :=
                                    hr_multi_message.get_return_status_disable;
         RETURN l_element_type_id;
         hr_utility.set_location (   ' Leaving:'
                                  || l_proc_name, 60);
   END create_user_template_swi;


 --
--
--==========================================================================
--                             Deletion procedure
--==========================================================================
--
   PROCEDURE delete_user_template (
      p_business_group_id   IN   NUMBER
     ,p_ele_base_name       IN   VARCHAR2
     ,p_element_type_id     IN   NUMBER
     ,p_effective_date      IN   DATE
   )
   IS
      --
      l_template_id                  NUMBER;
      l_proc_name                    VARCHAR2 (72)
                                    :=    g_proc_name
                                       || 'delete_user_template';
      l_eei_info_id                  NUMBER;
      l_ovn_eei                      NUMBER;
      l_exists                       VARCHAR2 (1);
      l_element_type_id              pay_element_types_f.element_type_id%TYPE;

      -- Cursor to get template id
      CURSOR csr_get_template_id
      IS
         SELECT template_id
           FROM pay_element_templates
          WHERE base_name = p_ele_base_name
            AND template_name = g_template_name
            AND business_group_id = p_business_group_id
            AND template_type = 'U';

      -- Cursor to retrieve core element type id for this
      -- template
      CURSOR csr_get_ele_type_id (c_template_id NUMBER)
      IS
         SELECT element_type_id
           FROM pay_template_core_objects pet, pay_element_types_f petf
          WHERE pet.template_id = c_template_id
            AND petf.element_type_id = pet.core_object_id
            AND pet.core_object_type = 'ET';

      -- Cursor to retrieve element extra info for this
      -- element type id
      CURSOR csr_get_eei_info (c_element_type_id NUMBER)
      IS
         SELECT element_type_extra_info_id
           FROM pay_element_type_extra_info petei
          WHERE element_type_id = c_element_type_id;

      -- Cursor to check whether an sub classification row
      -- exists for the base element type id
      CURSOR csr_chk_sub_class_exists
      IS
         SELECT sub.ROWID, sub.sub_classification_rule_id
           FROM pay_sub_classification_rules_f sub
               ,pay_element_classifications pec
          WHERE element_type_id = p_element_type_id
            AND sub.classification_id = pec.classification_id
            AND pec.classification_name IN
                      ('Pre Tax Employee Pension COSR'
                      ,'Pre Tax Employee Pension COMP'
                      )
            AND pec.legislation_code = g_template_leg_code;

      -- Cursor to check whether an iterative rule exists
      -- for this element type
      CURSOR csr_get_itr_info (c_element_type_id NUMBER)
      IS
         SELECT iterative_rule_id, object_version_number
           FROM pay_iterative_rules_f
          WHERE element_type_id = c_element_type_id;

      -- Cursor to get pension category
      CURSOR csr_get_pens_cat
      IS
         SELECT eei_information4, eei_information6
           FROM pay_element_type_extra_info
          WHERE element_type_id = p_element_type_id
            AND information_type = 'PQP_GB_PENSION_SCHEME_INFO';

      -- Cursor to check whether this is an OCP scheme
      -- and whether any AVC scheme uses this OCP scheme
      -- to ensure that we do not delete an OCP scheme
      -- attached to an AVC scheme

      CURSOR csr_chk_ocp_asoc_avc
      IS
         SELECT 'X'
           FROM DUAL
          WHERE EXISTS ( SELECT 1
                           FROM pqp_gb_pension_schemes_v
                          WHERE (    associated_ocp_ele_type_id IS NOT NULL
                                 AND associated_ocp_ele_type_id =
                                                            p_element_type_id
                                )
                            AND business_group_id = p_business_group_id);

      -- Check whether a fixed rate emp deduction method exists
      -- for this pension scheme
      CURSOR csr_chk_fr_exists
      IS
         SELECT 'X'
           FROM DUAL
          WHERE EXISTS ( SELECT 1
                           FROM pay_element_templates
                          WHERE base_name =    p_ele_base_name
                                            || ' Fixed'
                            AND template_name = g_template_name
                            AND business_group_id = p_business_group_id
                            AND template_type = 'U');

      l_sub_classification_rule_id   NUMBER;
      l_rowid                        ROWID;
      l_ovn_itr                      NUMBER;
      l_itr_effective_start_dt       DATE;
      l_itr_effective_end_dt         DATE;
      l_pension_category             hr_lookups.lookup_code%TYPE;
      l_emp_deduction_method         hr_lookups.lookup_code%TYPE;

--
   BEGIN
      --
      hr_utility.set_location (   'Entering :'
                               || l_proc_name, 10);
      -- Get the pension category
      OPEN csr_get_pens_cat;
      FETCH csr_get_pens_cat INTO l_pension_category, l_emp_deduction_method;
      CLOSE csr_get_pens_cat;

      IF l_emp_deduction_method = 'PE'
      THEN
         -- Check whether this pension scheme has
         -- an FR deduction method
         OPEN csr_chk_fr_exists;
         FETCH csr_chk_fr_exists INTO l_exists;

         IF csr_chk_fr_exists%FOUND
         THEN
            CLOSE csr_chk_fr_exists;
            fnd_message.set_name ('PQP', 'PQP_230981_PEN_FR_DED_EXISTS');
            hr_multi_message.add
               (p_associated_column1
                => 'PQP_GB_PENSION_SCHEMES_V.EMPLOYEE_DEDUCTION_METHOD'
               );
         END IF; -- End if of fr deduction method exist check ...

         IF csr_chk_fr_exists%ISOPEN THEN
            CLOSE csr_chk_fr_exists;
         END IF; -- Cursor is open check ...
      END IF; -- End if of emp deduction method is percentage check ...

      IF l_pension_category = 'OCP'
      THEN
         -- Check whether any AVC uses this OCP
         OPEN csr_chk_ocp_asoc_avc;
         FETCH csr_chk_ocp_asoc_avc INTO l_exists;

         IF csr_chk_ocp_asoc_avc%FOUND
         THEN
            CLOSE csr_chk_ocp_asoc_avc;
            fnd_message.set_name ('PQP', 'PQP_230945_PEN_AVC_CHILD_EXIST');
            hr_multi_message.add
               (p_associated_column2
                => 'PQP_GB_PENSION_SCHEMES_V.ELEMENT_TYPE_ID'
               );
         END IF; -- End if of ocp associated with AVC check ...

         IF csr_chk_ocp_asoc_avc%ISOPEN THEN
            CLOSE csr_chk_ocp_asoc_avc;
         END IF; -- cursor is open check ...
      END IF; -- End if of pension category is OCP check ...

      hr_multi_message.end_validation_set;
      --

      FOR csr_get_template_id_rec IN csr_get_template_id
      LOOP
         l_template_id              := csr_get_template_id_rec.template_id;
      END LOOP;

      hr_utility.set_location (l_proc_name, 20);
      OPEN csr_get_ele_type_id (l_template_id);

      LOOP
         FETCH csr_get_ele_type_id INTO l_element_type_id;
         EXIT WHEN csr_get_ele_type_id%NOTFOUND;
         -- Get Element extra info id for this element type id

         OPEN csr_get_eei_info (l_element_type_id);

         LOOP
            FETCH csr_get_eei_info INTO l_eei_info_id;
            EXIT WHEN csr_get_eei_info%NOTFOUND;
            -- Delete the EEI row
            --
            hr_utility.set_location (l_proc_name, 30);
            --
            pay_element_extra_info_api.delete_element_extra_info (
               p_validate                    => FALSE
              ,p_element_type_extra_info_id  => l_eei_info_id
              ,p_object_version_number       => l_ovn_eei
            );
         END LOOP; -- EEIT loop

         CLOSE csr_get_eei_info;
      END LOOP; -- Element type id LOOP

      CLOSE csr_get_ele_type_id;
      --
      hr_utility.set_location (l_proc_name, 40);
      --

      -- Delete sub classification rules if one exist
      OPEN csr_chk_sub_class_exists;
      FETCH csr_chk_sub_class_exists INTO l_rowid, l_sub_classification_rule_id;

      IF csr_chk_sub_class_exists%FOUND
      THEN
         -- Delete the sub classification row
         pay_sub_class_rules_pkg.delete_row (
            p_rowid                       => l_rowid
           ,p_sub_classification_rule_id  => l_sub_classification_rule_id
           ,p_delete_mode                 => 'ZAP'
           ,p_validation_start_date       => p_effective_date
           ,p_validation_end_date         => p_effective_date
         );
      END IF; -- End if of sub class row exists check ...

      CLOSE csr_chk_sub_class_exists;
      --
      hr_utility.set_location (l_proc_name, 50);
      --

      pay_element_template_api.delete_user_structure (
         p_validate                    => FALSE
        ,p_drop_formula_packages       => TRUE
        ,p_template_id                 => l_template_id
      );
      --
      hr_utility.set_location (   'Leaving :'
                               || l_proc_name, 60);
   --

   END delete_user_template;


-- ---------------------------------------------------------------------
-- |--------------------< delete_user_template_swi >-------------------|
-- ---------------------------------------------------------------------

   PROCEDURE delete_user_template_swi (
      p_business_group_id   IN   NUMBER
     ,p_ele_base_name       IN   VARCHAR2
     ,p_element_type_id     IN   NUMBER
     ,p_effective_date      IN   DATE
   )
   IS
      --
      -- Variables for API Boolean parameters
      l_validate        BOOLEAN;
      --
      -- Variables for IN/OUT parameters
      --
      -- Other variables
      l_return_status   VARCHAR2 (1);
      l_proc_name       VARCHAR2 (80)
                                :=    g_proc_name
                                   || 'delete_user_template_swi';
   BEGIN
      hr_utility.set_location (   ' Entering:'
                               || l_proc_name, 10);
      --
      -- Issue a savepoint
      --
      SAVEPOINT delete_user_template_swi;
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
      l_validate                 :=
          hr_api.constant_to_boolean (p_constant_value => hr_api.g_false_num);
      --
      -- Register Surrogate ID or user key values
      --
      --
      -- Call API
      --
      delete_user_template (
         p_business_group_id           => p_business_group_id
        ,p_ele_base_name               => p_ele_base_name
        ,p_element_type_id             => p_element_type_id
        ,p_effective_date              => p_effective_date
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
      l_return_status            :=
                                   hr_multi_message.get_return_status_disable;
      hr_utility.set_location (   ' Leaving:'
                               || l_proc_name, 20);
   --
   EXCEPTION
      WHEN hr_multi_message.error_message_exist
      THEN
         --
         -- Catch the Multiple Message List exception which
         -- indicates API processing has been aborted because
         -- at least one message exists in the list.
         --
         ROLLBACK TO delete_user_template_swi;
         --
         -- Reset IN OUT parameters and set OUT parameters
         --
         hr_utility.set_location (   ' Leaving:'
                                  || l_proc_name, 30);
      WHEN OTHERS
      THEN
         --
         -- When Multiple Message Detection is enabled catch
         -- any Application specific or other unexpected
         -- exceptions.  Adding appropriate details to the
         -- Multiple Message List.  Otherwise re-raise the
         -- error.
         --
         ROLLBACK TO delete_user_template_swi;

         IF hr_multi_message.unexpected_error_add (l_proc_name)
         THEN
            hr_utility.set_location (   ' Leaving:'
                                     || l_proc_name, 40);
            RAISE;
         END IF;

         --
         -- Reset IN OUT and set OUT parameters
         --
         l_return_status            :=
                                    hr_multi_message.get_return_status_disable;
         hr_utility.set_location (   ' Leaving:'
                                  || l_proc_name, 50);
   END delete_user_template_swi;
--
END pqp_gb_pension_scheme_template;

/
