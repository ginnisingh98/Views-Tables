--------------------------------------------------------
--  DDL for Package Body PQP_UK_UNION_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_UK_UNION_TEMPLATE" AS
/* $Header: pqgbundt.pkb 115.3 2003/10/01 09:01:37 bsamuel noship $ */

/*========================================================================
 *                        CREATE_USER_TEMPLATE
 *=======================================================================*/

g_proc                           VARCHAR2(31):= 'pqp_uk_union_template.';
g_element_extra_info_type  pay_element_type_extra_info.information_type%TYPE:=
                            'PQP_UK_UNION_INFO';

FUNCTION create_user_template
           (p_frm_union_name                IN VARCHAR2
           ,p_frm_element_name              IN VARCHAR2
           ,p_frm_reporting_name            IN VARCHAR2
           ,p_frm_description               IN VARCHAR2   DEFAULT NULL
--         ,p_frm_classification            IN VARCHAR2
           ,p_frm_processing_type           IN VARCHAR2
           ,p_frm_override_amount           IN VARCHAR2   DEFAULT 'N'
           ,p_frm_tax_relief                IN VARCHAR2   DEFAULT 'N'
           ,p_frm_supplementary_levy        IN VARCHAR2   DEFAULT 'N'
           ,p_frm_union_level_balance       IN VARCHAR2
           ,p_frm_union_level_balance_yn    IN VARCHAR2
           ,p_frm_rate_type                 IN VARCHAR2   DEFAULT NULL
           ,p_frm_fund_list                 IN VARCHAR2   DEFAULT NULL
           ,p_frm_effective_start_date      IN DATE       DEFAULT NULL
           ,p_frm_effective_end_date        IN DATE       DEFAULT NULL
           ,p_frm_business_group_id         IN NUMBER
           )
   RETURN NUMBER IS -- The union element type core object id



   /*--------------------------------------------------------------------
    The input values are explained below : V-varchar2, D-Date, N-number
      Input-Name               Type  Valid Values/Explaination
      ----------               ----  ------------------------------------
      p_frm_union_name             (V) - LOV based i/p Extra Element Info #1
      p_frm_element_name           (V) - User i/p Element name
      p_frm_reporting_name         (V) - User i/p reporting name
      p_frm_description            (V) - User i/p Description
--    p_frm_classification         (V) - Assumed 'Voluntary Deductions'
      p_frm_processing_type        (V) - 'R'/'N' (Recurring/Non-recurring)
      p_frm_override_amount        (V) - 'Y'es/'N'o Exclusion Rule
      p_frm_tax_relief             (V) - 'Y'es/'N'o Exclusion Rule
      p_frm_supplementary_levy     (V) - 'Y'es/'N'o Exclusion Rule
      p_frm_union_level_balance    (V) - Union level Balance Name
      p_frm_union_level_balance_yn (V) - 'Y'es/'N'o Exclusion Rule
      p_frm_rate_type              (V) - Extra Element Info #2
      p_frm_fund_list              (V) - Input Value to seed ?
      p_frm_effective_start_date   (D) - Default NULL Effective Start Date
      p_frm_effective_end_date     (D) - Default NULL Effective Start Date
      p_frm_business_grp_id        (N) - Business Group ID
   ----------------------------------------------------------------------*/
  l_proc                VARCHAR2(61) := g_proc||'create_user_template';

  c_iv_payvlu_nm        CONSTANT pay_shadow_input_values.name%TYPE:=
                                   'Pay Value';
  c_iv_fdsltd_nm        CONSTANT pay_shadow_input_values.name%TYPE:=
                                   'Fund Selected';
  l_te_usrstr_id        pay_element_templates.template_id%TYPE;
  l_te_source_id        pay_element_templates.template_id%TYPE;

  -- Return Value
  l_el_core_id          pay_template_core_objects.core_object_id%TYPE:= -1;

  -- Generic Never to be passed IN
  l_xx_rowid_id         ROWID;
  l_xx_unnddn_ovn       pay_element_templates.object_version_number%TYPE;


  l_bl_core_id          pay_balance_types.balance_type_id%TYPE;
  l_db_core_id          pay_defined_balances.defined_balance_id%TYPE;
  l_iv_core_id          pay_template_core_objects.core_object_id%TYPE;
  l_dm_baldmn_id        pay_balance_dimensions.balance_dimension_id%TYPE;








  l_bl_unnbal_nm        pay_shadow_balance_types.balance_name%TYPE;
  l_bf_unnbal_id        pay_shadow_balance_feeds.balance_feed_id%TYPE;

  l_ee_unnddn_id pay_element_type_extra_info.element_type_extra_info_id%TYPE;
  l_ee_unnorg_id        pay_element_type_extra_info.eei_information1%TYPE;
  l_ee_unnddn_nm        pay_element_type_extra_info.eei_information2%TYPE;
  l_ee_rattyp_nm        pay_element_type_extra_info.eei_information3%TYPE;

  l_or_unnddn_id        hr_organization_information.organization_id%TYPE;
  l_oi_unndat_dt        hr_organization_information.org_information2%TYPE;

  l_ut_unnudt_nm        pay_user_tables.user_table_name%TYPE;
  l_ut_unnudt_id        pay_user_tables.user_table_id%TYPE;
  l_ut_tbltyp_nm        pay_user_tables.range_or_match%TYPE;


  l_frm_effective_end_date  DATE:=NVL(p_frm_effective_end_date
                                     ,TO_DATE('31/12/4712','DD/MM/YYYY'));

  l_ERROR_MESSAGE        VARCHAR2(2000);


   CURSOR csr_el_unnddn(p_te_unnddn_id NUMBER
                       ,p_el_unnddn_nm VARCHAR2) IS
   SELECT element_type_id
         ,object_version_number
   FROM   pay_shadow_element_types
   WHERE  template_id = p_te_unnddn_id
     AND  element_name = p_el_unnddn_nm;

   row_el_unnddn csr_el_unnddn%ROWTYPE;

   CURSOR csr_bl_unnbal IS
   SELECT pbt.balance_type_id
         ,pbt.object_version_number
   FROM   pay_balance_types pbt
   WHERE  pbt.balance_name = p_frm_union_level_balance
     AND  pbt.business_group_id = p_frm_business_group_id
     AND  (pbt.legislation_code IS NULL
          OR
           pbt.legislation_code = 'GB');

   row_bl_unnbal csr_bl_unnbal%ROWTYPE;

   CURSOR csr_iv_payvlu(p_el_unnddn_id NUMBER
                       ,p_iv_payvlu_nm VARCHAR2) IS
   SELECT siv.input_value_id
         ,siv.object_version_number
   FROM   pay_shadow_input_values siv
   WHERE  siv.element_type_id = p_el_unnddn_id
     AND  siv.name = p_iv_payvlu_nm;


   row_iv_payvlu csr_iv_payvlu%ROWTYPE;

   CURSOR csr_or_unnorg(p_or_unnorg_nm VARCHAR2
                     ,p_bg_unnddn_id NUMBER  ) IS
   SELECT hou.organization_id
   FROM   hr_all_organization_units hou
   WHERE  hou.name = p_or_unnorg_nm
     AND  hou.business_group_id = p_bg_unnddn_id;

   row_or_unnorg csr_or_unnorg%ROWTYPE;

   -- Added cursor to get balance category info
   CURSOR csr_get_balance_cat_id (c_category_name VARCHAR2)
   IS
   SELECT balance_category_id
     FROM pay_balance_categories_f
    WHERE category_name = c_category_name
      AND legislation_code = 'GB'
      AND p_frm_effective_start_date BETWEEN effective_start_date
                                         AND effective_end_date;

   l_balance_category_id  NUMBER;



  --======================================================================
  --                     FUNCTION GET_TEMPLATE_ID
  --======================================================================
  FUNCTION get_template_id (p_legislation_code IN VARCHAR2)
  RETURN NUMBER IS
     --
     l_te_unnddn_id        pay_element_templates.template_id%TYPE;
     l_te_unnddn_nm        pay_element_templates.template_name%TYPE;
     l_proc_nm             VARCHAR2(61):= g_proc||'get_template_id';
     --
     CURSOR csr_te_unnddn IS
     SELECT template_id
     FROM   pay_element_templates
     WHERE  template_name = l_te_unnddn_nm
       AND  legislation_code = p_legislation_code
       AND  template_type = 'T'
       AND  business_group_id is NULL;
     --
  BEGIN
      --
      hr_utility.set_location('Entering: '||l_proc, 10);
      --
      l_te_unnddn_nm := 'PQP UNION DEDUCTIONS';
      --
      hr_utility.set_location(l_proc, 30);
      --
      FOR rec_te_unnddn IN csr_te_unnddn LOOP
         l_te_unnddn_id := rec_te_unnddn.template_id;
      END LOOP;
      --
      hr_utility.set_location('Leaving: '||l_proc, 100);
      --
      RETURN l_te_unnddn_id;
      --
  END get_template_id;


  PROCEDURE create_table_columns(p_business_group_id NUMBER
                                 ,p_ut_unnudt_id      NUMBER
                                 ,p_fund_list         VARCHAR2
                                 ) IS

     l_column_rowid        VARCHAR2(100);
--     l_user_table_id       NUMBER;
     l_user_column_id      NUMBER;
     l_column_exists       NUMBER;

     CURSOR c_lookup_values IS
     SELECT lookup_code
           ,meaning
     FROM   hr_lookups hrl
     WHERE  hrl.lookup_type = p_fund_list
       AND  hrl.enabled_flag = 'Y';

--     CURSOR get_user_table_id is
--     SELECT to_number(hoi.org_information1)
--     FROM   hr_all_organization_units hou
--           ,hr_organization_information hoi
--     WHERE  hou.organization_id = hoi.organization_id
--       AND  org_information_context = 'GB_TRADE_UNION_INFO'
--       AND  hou.name = p_union_name;

     CURSOR c_column_exists(p_column_name VARCHAR2
                           ,p_user_table_id NUMBER) IS
     SELECT user_column_id
     FROM   pay_user_columns
     WHERE  user_table_id = p_user_table_id
       AND  user_column_name = p_column_name;

  BEGIN

--     OPEN c_get_user_table_id;
--     FETCH c_get_user_table_id INTO l_user_table_id;
--      CLOSE c_get_user_table_id;


     FOR l_lookup_value IN c_lookup_values LOOP
     --
       OPEN c_column_exists(l_lookup_value.meaning||' Weekly', p_ut_unnudt_id);
       FETCH c_column_exists into l_column_exists;
       CLOSE c_column_exists;

       IF l_column_exists IS NULL THEN
       --
         pay_user_columns_pkg.insert_row (
           p_rowid                => l_column_rowid
          ,p_user_column_id       => l_user_column_id
          ,p_user_table_id        => p_ut_unnudt_id
          ,p_business_group_id    => p_frm_business_group_id
          ,p_legislation_code     => NULL
          ,p_legislation_subgroup => NULL
          ,p_user_column_name     => l_lookup_value.meaning||' Weekly'
          ,p_formula_id           => NULL
           );
       --
       END IF;

       l_column_exists := null;

       OPEN c_column_exists(l_lookup_value.meaning||' Monthly'
                           , p_ut_unnudt_id);
       FETCH c_column_exists INTO l_column_exists;
       CLOSE c_column_exists;

       IF l_column_exists IS NULL THEN
       --
         pay_user_columns_pkg.insert_row (
           p_rowid                => l_column_rowid
          ,p_user_column_id       => l_user_column_id
          ,p_user_table_id        => p_ut_unnudt_id
          ,p_business_group_id    => p_frm_business_group_id
          ,p_legislation_code     => NULL
          ,p_legislation_subgroup => NULL
          ,p_user_column_name     => l_lookup_value.meaning||' Monthly'
          ,p_formula_id           => NULL
           );
       --
       END IF;
    --
    END LOOP;
  --
  END create_table_columns;



   --
   --=======================================================================
   --                FUNCTION GET_BALANCE_DIMENSION_ID
   --=======================================================================

   FUNCTION get_balance_dimension_id (p_dimension_name VARCHAR2)
   RETURN NUMBER -- Null if the dimension name is not found.
   IS

     CURSOR csr_id_baldmn IS
     SELECT balance_dimension_id
     FROM   pay_balance_dimensions
     WHERE  dimension_name = p_dimension_name
       AND  ((business_group_id is null and legislation_code is null)
            OR
             (legislation_code is null and business_group_id + 0 =
              p_frm_business_group_id)
            OR
             (business_group_id is null and legislation_code = 'GB'));

     l_bd_baldmn_id  pay_balance_dimensions.balance_dimension_id%TYPE;

   BEGIN
   --
     FOR csr_id_baldmn_rec IN csr_id_baldmn LOOP
       l_bd_baldmn_id := csr_id_baldmn_rec.balance_dimension_id;
     END LOOP;

     RETURN l_bd_baldmn_id;
   --
   END get_balance_dimension_id;


   --
   --=======================================================================
   --                FUNCTION GET_OBJECT_ID
   --=======================================================================



   FUNCTION get_object_id (p_object_type    in varchar2,
                           p_object_name    in varchar2,
                           p_shadow_id      in number default null,
                           p_template_id    in number default null)
   RETURN NUMBER is
     --
     l_xx_object_id        NUMBER:= NULL;
     l_proc                VARCHAR2(61):= g_proc||'get_object_id';
     --
     CURSOR csr_el_payele(p_xx_object_nm VARCHAR2) IS
     SELECT element_type_id
     FROM   pay_element_types_f
     WHERE  element_name = p_xx_object_nm
       AND  business_group_id = p_frm_business_group_id;
     --
     CURSOR csr_bl_coreobj(p_xx_object_nm VARCHAR2) IS
     SELECT ptco.core_object_id
     FROM   pay_shadow_balance_types psbt,
            pay_template_core_objects ptco
     WHERE  psbt.template_id = l_te_usrstr_id
       AND  psbt.balance_name = p_xx_object_nm
       AND  ptco.template_id = psbt.template_id
       AND  ptco.shadow_object_id = psbt.balance_type_id;
     --
     CURSOR csr_id_coreobj IS
     SELECT ptco.core_object_id
     FROM   pay_template_core_objects ptco
     WHERE  ptco.template_id = NVL(p_template_id,l_te_usrstr_id)
       AND  ptco.shadow_object_id = p_shadow_id
       AND  ptco.core_object_type = p_object_type;
     --
   BEGIN
      hr_utility.set_location('Entering: '||l_proc, 10);
      --
      IF p_object_type = 'ELE' THEN
         FOR rec_el_payele IN csr_el_payele(p_object_name) LOOP
            l_xx_object_id := rec_el_payele.element_type_id;  -- element id
         END LOOP;
      ELSIF p_object_type = 'BAL' THEN
         FOR rec_bl_coreobj IN csr_bl_coreobj(p_object_name) LOOP
            l_xx_object_id := rec_bl_coreobj.core_object_id;   -- balance id
         END LOOP;
      ELSE
         IF p_shadow_id IS NOT NULL THEN
           FOR rec_id_coreobj IN csr_id_coreobj LOOP
             l_xx_object_id := rec_id_coreobj.core_object_id;
           END LOOP;
         END IF;
      END IF;
      --
      hr_utility.set_location('Leaving: '||l_proc, 50);
      --
      RETURN l_xx_object_id;
      --
   END get_object_id;
   --
--=============================================================================
--                         MAIN FUNCTION
--=============================================================================
  BEGIN

   hr_utility.set_location('Entering : '||l_proc, 10);
   ---------------------
   -- Set session date
   ---------------------

   pay_db_pay_setup.set_session_date(nvl(p_frm_effective_start_date, sysdate));
   --
   hr_utility.set_location(l_proc, 20);

  IF (hr_utility.chk_product_install('Oracle Payroll',g_template_leg_code))
  THEN

    ---------------------------
    -- Get Source Template ID
    ---------------------------
    l_te_source_id := get_template_id
                        (p_legislation_code => g_template_leg_code);

    hr_utility.set_location(l_proc, 30);


    /*--------------------------------------------------------------------
     The input values are explained below : V-varchar2, D-Date, N-number
      Input-Name               Type  Valid Values/Explaination
      ----------               ----  ------------------------------------
      p_frm_union_name             (V) - LOV based i/p Extra Element Info #1
      p_element_name           (V) - User i/p Element name
      p_reporting_name         (V) - User i/p reporting name
      p_description            (V) - User i/p Description
--    p_classification         (V) - Assumed 'Voluntary Deductions'
      p_processing_type        (V) - 'R'/'N' (Recurring/Non-recurring)
      p_override_amount        (V) - 'Y'es/'N'o Exclusion Rule
      p_tax_relief             (V) - 'Y'es/'N'o Exclusion Rule
      p_supplementary_levy     (V) - 'Y'es/'N'o Exclusion Rule
      p_frm_union_level_balance    (V) - Union level Balance Name
      p_frm_union_level_balance_yn (V) - 'Y'es/'N'o Exclusion Rule
      p_rate_type              (V) - Extra Element Info #2
      p_fund_list              (V) - Input Value to seed ?
      p_effective_start_date   (D) - Default NULL Effective Start Date
      p_effective_end_date     (D) - Default NULL Effective Start Date
      p_business_group_id      (N) - Business Group ID
    ----------------------------------------------------------------------*/


    -------------------------------------------------------------------------
    ------------ create user structure from the template --------------------
    -------------------------------------------------------------------------
    pay_element_template_api.create_user_structure
      (p_validate                      =>     false
      ,p_effective_date                =>     p_frm_effective_start_date
      ,p_business_group_id             =>     p_frm_business_group_id
      ,p_source_template_id            =>     l_te_source_id
      ,p_base_name                     =>     p_frm_element_name
      ,p_configuration_information1    =>     p_frm_override_amount
      ,p_configuration_information2    =>     p_frm_tax_relief
      ,p_configuration_information3    =>     p_frm_supplementary_levy
--      ,p_configuration_information4    =>     p_frm_union_level_balance_yn
      ,p_template_id                   =>     l_te_usrstr_id
      ,p_object_version_number         =>     l_xx_unnddn_ovn
      );

    hr_utility.set_location(l_proc, 40);




    ------------------------------------------------------------------------
    ------------------------- Update Shadow Structure ------------------------
    ---------------------------------------------------------------------------

    -- Update the user choice of Recurring or Non-Recurring processing type

    OPEN csr_el_unnddn(l_te_usrstr_id, p_frm_element_name);  -- <BASENAME>
    LOOP
    FETCH csr_el_unnddn INTO row_el_unnddn;
    EXIT WHEN csr_el_unnddn%NOTFOUND;

    pay_shadow_element_api.update_shadow_element
      (p_validate                    => false
      ,p_effective_date              => p_frm_effective_start_date
      ,p_element_type_id             => row_el_unnddn.element_type_id
      ,p_element_name                => p_frm_element_name
      ,p_description                 => p_frm_description
      ,p_object_version_number       => row_el_unnddn.object_version_number
      ,p_processing_type             => p_frm_processing_type
      ,p_reporting_name              => p_frm_reporting_name
      );

   END LOOP;
   CLOSE csr_el_unnddn;


   -- Update the fund list lookup type

   OPEN csr_iv_payvlu(row_el_unnddn.element_type_id, c_iv_fdsltd_nm);
   FETCH csr_iv_payvlu INTO row_iv_payvlu;
--   IF csr_iv_payvlu%NOTFOUND THEN
--   --
--     --Error Out
--     hr_utility.set_message(8303, 'PQP_UNNTEST_FUNDIVLU_NOT_FOUND');
--     hr_utility.raise_error;
--
--   ELSE

     pay_siv_upd.upd
       (p_effective_date               => p_frm_effective_start_date
       ,p_input_value_id               => row_iv_payvlu.input_value_id
--       ,p_element_type_id            => --in number default hr_api.g_number
--       ,p_display_sequence           => --in number default hr_api.g_number
--       ,p_generate_db_items_flag     => --in varchar2 default hr_api.g_varc
--       ,p_hot_default_flag           => --in varchar2 default hr_api.g_varc
--       ,p_mandatory_flag             => --in varchar2 default hr_api.g_varc
--       ,p_name                       => --in varchar2 default hr_api.g_varc
--       ,p_uom                        => --in varchar2 default hr_api.g_varc
       ,p_lookup_type                  => p_frm_fund_list
       ,p_default_value                => NULL
--       ,p_max_value                  => --in varchar2 default hr_api.g_varc
--       ,p_min_value                  => --in varchar2 default hr_api.g_varc
--       ,p_warning_or_error           => --in varchar2 default hr_api.g_varc
--       ,p_default_value_column       => --in varchar2 default hr_api.g_varc
--       ,p_exclusion_rule_id          => --in number default hr_api.g_number
       ,p_object_version_number        => l_xx_unnddn_ovn
       );
--   END IF; /* IF csr_iv_payvlu%NOTFOUND THEN */
   CLOSE csr_iv_payvlu;

   hr_utility.set_location(l_proc, 50);



   ---------------------------------------------------------------------------
   ---------------------------- Generate Core Objects ------------------------
   ---------------------------------------------------------------------------

   pay_element_template_api.generate_part1
     (p_validate          =>     FALSE
     ,p_effective_date    =>     p_frm_effective_start_date
     ,p_hr_only           =>     FALSE
     ,p_hr_to_payroll     =>     FALSE
     ,p_template_id       =>     l_te_usrstr_id);

   hr_utility.set_location(l_proc, 60);

   pay_element_template_api.generate_part2
     (p_validate          =>     FALSE
     ,p_effective_date    =>     p_frm_effective_start_date
     ,p_template_id       =>     l_te_usrstr_id);

   hr_utility.set_location(l_proc, 70);


   l_el_core_id := get_object_id (p_object_type => 'ELE'
                                 ,p_object_name => p_frm_element_name
                                  );



   IF p_frm_union_level_balance_yn = 'N' THEN
   --
   -- If this is the first time that the driver is being run for a driver
   -- then create a union level balance with the given name and its associated
   -- feed. All subsequent runs of the driver, for the same union, will only
   -- create the feed.
   --
   -- NB This balance will not have a corresponding user structure created.
   -- This is because, a user may delete the corresponding user structure and
   -- thus corrupt the feeds created by other runs of the same template.
   --
   -- This places an additional requirement on the delete_user_structure
   -- procedure to detect if the user structure being deleted is the last user
   -- structure and if so it must then delete the corresponding union level
   -- balance.In all cases the core objects may not be deleted if a payroll
   -- has been run with the union element.
   --
   --
   -- All GB balances should be categorized now
   -- added this new piece of code to populate category information
   --
      l_balance_category_id := NULL;
      OPEN csr_get_balance_cat_id ('Other Deductions');
      FETCH csr_get_balance_cat_id INTO l_balance_category_id;
      CLOSE csr_get_balance_cat_id;

      l_xx_rowid_id := NULL;
      pay_balance_types_pkg.insert_row
        (X_Rowid                        => l_xx_rowid_id  -- IN OUT VARCHAR2
        ,X_Balance_Type_Id              => l_bl_core_id   -- IN OUT NUMBER
        ,X_Business_Group_Id            => p_frm_business_group_id -- NUMBER
        ,X_Legislation_Code             => NULL           -- VARCHAR2
        ,X_Currency_Code                => 'GBP'          --       VARCHAR2
        ,X_Assignment_Remuneration_Flag => 'N'            --       VARCHAR2
        ,X_Balance_Name                 => p_frm_union_level_balance --VARCHAR2
        ,X_Base_Balance_Name            => p_frm_union_level_balance --VARCHAR2
        ,X_Balance_Uom                  => 'M'                       --VARCHAR2
        ,X_Comments                     => 'Union level balance for '||
                                           p_frm_union_name -- VARCHAR2
        ,X_Legislation_Subgroup         => NULL          -- VARCHAR2
        ,X_Reporting_Name               => p_frm_union_level_balance --VARCHAR2
        ,X_Attribute_Category           => NULL      -- VARCHAR2
        ,X_Attribute1                   => NULL      -- VARCHAR2
        ,X_Attribute2                   => NULL      -- VARCHAR2
        ,X_Attribute3                   => NULL      -- VARCHAR2
        ,X_Attribute4                   => NULL      -- VARCHAR2
        ,X_Attribute5                   => NULL      -- VARCHAR2
        ,X_Attribute6                   => NULL      -- VARCHAR2
        ,X_Attribute7                   => NULL      -- VARCHAR2
        ,X_Attribute8                   => NULL      -- VARCHAR2
        ,X_Attribute9                   => NULL      -- VARCHAR2
        ,X_Attribute10                  => NULL      -- VARCHAR2
        ,X_Attribute11                  => NULL      -- VARCHAR2
        ,X_Attribute12                  => NULL      -- VARCHAR2
        ,X_Attribute13                  => NULL      -- VARCHAR2
        ,X_Attribute14                  => NULL      -- VARCHAR2
        ,X_Attribute15                  => NULL      -- VARCHAR2
        ,X_Attribute16                  => NULL      -- VARCHAR2
        ,X_Attribute17                  => NULL      -- VARCHAR2
        ,X_Attribute18                  => NULL      -- VARCHAR2
        ,X_Attribute19                  => NULL      -- VARCHAR2
        ,X_Attribute20                  => NULL      -- VARCHAR2
        ,X_balance_category_id          => l_balance_category_id
        );

   -- now create the defined balances also for _ASG_RUN/PROC_PTD/STAT_YTD

        l_dm_baldmn_id := get_balance_dimension_id('_ASG_RUN');
        l_xx_rowid_id := NULL;
        l_db_core_id  := NULL;
        pay_defined_balances_pkg.insert_row
          (x_rowid                        => l_xx_rowid_id  -- IN OUT VARCHAR2
	  ,x_defined_balance_id           => l_db_core_id   -- IN OUT NUMBER
	  ,x_business_group_id            => p_frm_business_group_id --NUMBER
	  ,x_legislation_code             => NULL           -- VARCHAR2
	  ,x_balance_type_id              => l_bl_core_id   -- NUMBER
	  ,x_balance_dimension_id         => l_dm_baldmn_id -- NUMBER
	  ,x_force_latest_balance_flag    => NULL           -- VARCHAR2
	  ,x_legislation_subgroup         => NULL           -- VARCHAR2
          ,x_grossup_allowed_flag         => 'N'            -- VARCHAR2
          );

        l_dm_baldmn_id := get_balance_dimension_id('_ASG_PROC_PTD');
        l_xx_rowid_id := NULL;
        l_db_core_id  := NULL;
	pay_defined_balances_pkg.insert_row
	  (x_rowid                        => l_xx_rowid_id  -- IN OUT VARCHAR2
	  ,x_defined_balance_id           => l_db_core_id   -- IN OUT NUMBER
	  ,x_business_group_id            => p_frm_business_group_id --NUMBER
	  ,x_legislation_code             => NULL           --       VARCHAR2
	  ,x_balance_type_id              => l_bl_core_id   --       NUMBER
	  ,x_balance_dimension_id         => l_dm_baldmn_id --       NUMBER
	  ,x_force_latest_balance_flag    => NULL           --       VARCHAR2
	  ,x_legislation_subgroup         => NULL           --       VARCHAR2
	  ,x_grossup_allowed_flag         => 'N'            --       VARCHAR2
	  );

        l_dm_baldmn_id := get_balance_dimension_id('_ASG_STAT_YTD');
        l_xx_rowid_id := NULL;
        l_db_core_id  := NULL;
	pay_defined_balances_pkg.insert_row
	  (x_rowid                        => l_xx_rowid_id  -- IN OUT VARCHAR2
	  ,x_defined_balance_id           => l_db_core_id   -- IN OUT NUMBER
	  ,x_business_group_id            => p_frm_business_group_id --NUMBER
	  ,x_legislation_code             => NULL           --       VARCHAR2
	  ,x_balance_type_id              => l_bl_core_id   --       NUMBER
	  ,x_balance_dimension_id         => l_dm_baldmn_id --       NUMBER
	  ,x_force_latest_balance_flag    => NULL           --       VARCHAR2
	  ,x_legislation_subgroup         => NULL           --       VARCHAR2
	  ,x_grossup_allowed_flag         => 'N'            --       VARCHAR2
	  );

   ELSE -- this is not the first run
   -- so query out the core balance type id for the given balance name

     OPEN csr_bl_unnbal;
     FETCH csr_bl_unnbal INTO row_bl_unnbal;
     IF csr_bl_unnbal%NOTFOUND THEN
     --
       hr_utility.set_message(8303, 'PQP_230532_UNNBAL_NOT_FOUND');
       hr_utility.raise_error;
     ELSE

       l_bl_core_id :=  row_bl_unnbal.balance_type_id;

     END IF;
     CLOSE csr_bl_unnbal;

   END IF;


   OPEN csr_iv_payvlu(row_el_unnddn.element_type_id, c_iv_payvlu_nm);
   FETCH csr_iv_payvlu INTO row_iv_payvlu;
--   IF csr_iv_payvlu%NOTFOUND THEN
--   --
--     hr_utility.set_message(8303, 'PQP_UNNTEST_PAYIVLU_NOT_FOUND');
--     hr_utility.raise_error;
--   END IF;
   CLOSE csr_iv_payvlu;


   l_iv_core_id := get_object_id
                     (p_object_type   => 'IV'
                     ,p_object_name   => 'Pay Value' -- dummy
                     ,p_shadow_id     => row_iv_payvlu.input_value_id
                     );



   IF l_iv_core_id IS NULL OR l_el_core_id IS NULL THEN
   -- Error Out
         hr_utility.set_message(8303, 'PQP_230533_GENERATE_PART_FAIL');
         hr_utility.raise_error;

   ELSE
     l_xx_rowid_id := NULL;
     pay_balance_feeds_f_pkg.insert_row
       (x_rowid                      => l_xx_rowid_id    --IN OUT VARCHAR2,
       ,x_balance_feed_id            => l_bf_unnbal_id   --IN OUT NUMBER,
       ,x_effective_start_date       => p_frm_effective_start_date -- DATE,
       ,x_effective_end_date         => l_frm_effective_end_date   -- DATE,
       ,x_business_group_id          => p_frm_business_group_id -- NUMBER,
       ,x_legislation_code           => g_template_leg_code     -- VARCHAR2,
       ,x_balance_type_id            => l_bl_core_id            -- NUMBER,
       ,x_input_value_id             => l_iv_core_id            -- NUMBER,
       ,x_scale                      => 1                       -- NUMBER,
       ,x_legislation_subgroup       => NULL                    -- VARCHAR2
       );


   END IF; -- IF any core id is null THEN




   ---------------------------------------------------------------------------
   ---------------------------- Update Core Objects ------------------------
   ---------------------------------------------------------------------------

-- Update input value Fund_Selected with the lookup type passed as Fund List



   OPEN csr_or_unnorg(p_frm_union_name, p_frm_business_group_id);
   FETCH csr_or_unnorg INTO row_or_unnorg;
--   IF csr_or_unnorg%NOTFOUND THEN
--   -- Error out, the union does not exist as a organization for the
--   -- given business group.
--     hr_utility.set_message(8303, 'PQP_UNNTEST_UNNORG_NOT_FOUND');
--     hr_utility.raise_error;
--   --
--   END IF;
   CLOSE csr_or_unnorg;


   --
   -- Extract the Union Rates Table Name/Id and Type from Organisation
   -- Information flexfields.If it has not been setup untill now then
   -- error out.
   --

   IF pqp_uk_union_deduction.get_uk_union_org_info
        (p_union_organization_id     => row_or_unnorg.organization_id -- IN
        ,p_union_rates_table_id      => l_ut_unnudt_id  -- OUT  NUMBER
        ,p_union_rates_table_name    => l_ut_unnudt_nm  -- OUT  VARCHAR2
        ,p_union_rates_table_type    => l_ut_tbltyp_nm  -- OUT  VARCHAR2
        ,p_union_recalculation_date  => l_oi_unndat_dt  -- OUT  VARCHAR2
        ,p_ERROR_MESSAGE             => l_ERROR_MESSAGE -- OUT  VARCHAR2
        ) <> 0 THEN
    --
    -- Error Out
       hr_utility.set_message(8303, 'PQP_230534_ORGINFO_NOT_FOUND');
       hr_utility.raise_error;
    --
    ELSE

      create_table_columns
        (p_business_group_id => p_frm_business_group_id        -- NUMBER
        ,p_ut_unnudt_id      => l_ut_unnudt_id                 -- NUMBER
        ,p_fund_list         => p_frm_fund_list                -- VARCHAR2
        );

    END IF;


    pay_element_extra_info_api.create_element_extra_info
     (p_element_type_id             => l_el_core_id
      ,p_information_type           => g_element_extra_info_type
      ,p_eei_information_category   => g_element_extra_info_type
      ,p_eei_information1           => TO_CHAR(row_or_unnorg.organization_id)
      ,p_eei_information2           => p_frm_union_level_balance
      ,p_eei_information3           => p_frm_rate_type
      ,p_eei_information4           => p_frm_fund_list
      ,p_element_type_extra_info_id => l_ee_unnddn_id
      ,p_object_version_number      => l_xx_unnddn_ovn);


 ELSE

   hr_utility.set_message(8303, 'PQP_230535_GBORAPAY_NOT_FOUND');
   hr_utility.raise_error;


 END IF; -- IF chk_product_install('Oracle Payroll',g_template_leg_code))

 RETURN l_el_core_id;

  --
END create_user_template;
--
--
--==========================================================================
--                             Deletion procedure
--==========================================================================
--
PROCEDURE delete_user_template
           (p_frm_union_name               IN VARCHAR2
           ,p_frm_union_level_balance      IN VARCHAR2
           ,p_frm_element_type_id          IN NUMBER
           ,p_frm_element_name             IN VARCHAR2
           ,p_frm_business_group_id        IN NUMBER
           ,p_frm_effective_date           IN DATE
           ) IS
  --
  l_proc                VARCHAR2(61):= g_proc||'delete_user_template';
  l_te_unnddn_id        pay_element_templates.template_id%TYPE;

  l_ee_unnddn_id   pay_element_type_extra_info.element_type_extra_info_id%TYPE;
  l_ee_unnddn_ovn  pay_element_type_extra_info.object_version_number%TYPE;


  l_del_union_level_balance_yn VARCHAR2(1):= 'Y'; --Default delete the balance
  --
  CURSOR csr_ee_unnddn IS
  SELECT element_type_extra_info_id
  FROM   pay_element_type_extra_info petei
  WHERE  element_type_id = p_frm_element_type_id;


  CURSOR csr_te_unnddn IS
  SELECT template_id
  FROM   pay_element_templates
  WHERE  base_name = p_frm_element_name
    AND  business_group_id = p_frm_business_group_id
    AND  template_type = 'U';


  CURSOR csr_te_others (p_te_usrstr_id NUMBER) IS
  SELECT usr_others.template_id
  FROM   pay_element_templates usr_this
        ,pay_element_templates usr_others
  WHERE  usr_this.template_id = p_te_usrstr_id
    AND  usr_others.template_name = usr_this.template_name
    AND  usr_others.template_type = 'U'
    AND  usr_others.template_id <> usr_this.template_id;

  row_te_others  csr_te_others%ROWTYPE;

  CURSOR csr_ee_unionm (p_te_usrstr_id NUMBER) IS
  SELECT TO_NUMBER(peei.eei_information1) union_org_id
  FROM   pay_element_templates       pets
        ,pay_shadow_element_types    pset
        ,pay_template_core_objects   ptco
        ,pay_element_type_extra_info peei
--        ,hr_all_organization_units   horg
  WHERE  pets.template_id = p_te_usrstr_id    -- For the given user structure
    AND  pset.template_id = pets.template_id  -- find the base element
    AND  pset.element_name = pets.base_name
    AND  ptco.template_id = pset.template_id  -- For the base element
    AND  ptco.shadow_object_id = pset.element_type_id -- find the core element
    AND  ptco.core_object_type = 'ET'
    AND  ptco.core_object_id = peei.element_type_id -- For the core element
    AND  peei.information_type = g_element_extra_info_type -- find the eei info
--    AND  horg.organization_id = TO_NUMBER(peei.eei_information1)
--    AND  horg.name = p_frm_union_name
  ;

  row_ee_unionm  csr_ee_unionm%ROWTYPE;
--
-- The above cursor had to be split into two bcos of the invalid number error
-- while joining eei to org
--

   CURSOR csr_or_unionm (p_or_unnorg_id NUMBER) IS
   SELECT horg.organization_id
   FROM   hr_all_organization_units horg
   WHERE  horg.organization_id = p_or_unnorg_id
     AND  horg.name = p_frm_union_name
     AND  ( horg.business_group_id = p_frm_business_group_id
          OR horg.business_group_id IS NULL);

  row_or_unionm  csr_or_unionm%ROWTYPE;



  CURSOR csr_bt_unnbal IS
  SELECT pbts.rowid
        ,pbts.balance_type_id
  FROM   pay_balance_types pbts
  WHERE  pbts.balance_name = p_frm_union_level_balance
    AND  pbts.business_group_id = p_frm_business_group_id
    AND  pbts.legislation_code IS NULL;

  row_bt_unnbal csr_bt_unnbal%ROWTYPE;


--
BEGIN
   --
   hr_utility.set_location('Entering :'||l_proc, 10);
   --
   FOR csr_te_unnddn_rec IN csr_te_unnddn LOOP
       l_te_unnddn_id := csr_te_unnddn_rec.template_id;
   END LOOP;
   --
   -- Check to see if there are other user structures for the given template.
   -- If there are then check to see if they have they belong to the same
   -- union as the one being deleted.
   --
   OPEN csr_te_others(l_te_unnddn_id);
   FETCH csr_te_others INTO row_te_others;
   --
   -- If no other structures were found this was the last user structure for
   -- union deductions. So don't bother to check the extra element info and
   -- delete the union level balance.If on the other hand more user structures
   -- were found then loop thru each of them to check if they belong to the
   -- same union.
   --
   IF csr_te_others%FOUND THEN
     LOOP
       OPEN csr_ee_unionm(row_te_others.template_id);
       FETCH csr_ee_unionm INTO row_ee_unionm;
       CLOSE csr_ee_unionm;
       OPEN csr_or_unionm(row_ee_unionm.union_org_id);
       FETCH csr_or_unionm INTO row_or_unionm;
       IF csr_or_unionm%FOUND THEN
         CLOSE csr_or_unionm;
         l_del_union_level_balance_yn := 'N';
         EXIT; -- Even if one more matching user structure exists
               -- the balance cannot be deleted.
       END IF;
       CLOSE csr_or_unionm;
       FETCH csr_te_others INTO row_te_others;
       EXIT WHEN csr_te_others%NOTFOUND;
     END LOOP;
   --
   END IF;
   CLOSE csr_te_others;


   IF l_del_union_level_balance_yn = 'Y' THEN
   --
   -- Delete the union level balance also.
   -- NB This will also delete any dependent feeds and defined balances.
   --
     OPEN csr_bt_unnbal;
     FETCH csr_bt_unnbal INTO row_bt_unnbal;
     IF csr_bt_unnbal%NOTFOUND THEN
     --
       hr_utility.set_message(8303, 'PQP_230532_UNNBAL_NOT_FOUND');
       hr_utility.raise_error;
     --
     END IF;
     CLOSE csr_bt_unnbal;

     pay_balance_types_pkg.delete_row
       (x_rowid             => row_bt_unnbal.rowid         -- VARCHAR2
       ,x_balance_type_id   => row_bt_unnbal.balance_type_id  -- NUMBER
       );

   END IF;


   OPEN csr_ee_unnddn;
   LOOP
     FETCH csr_ee_unnddn INTO l_ee_unnddn_id;
     EXIT WHEN csr_ee_unnddn%NOTFOUND;

     pay_element_extra_info_api.delete_element_extra_info
       (p_validate                   => FALSE
       ,p_element_type_extra_info_id => l_ee_unnddn_id
       ,p_object_version_number      => l_ee_unnddn_ovn);

   END LOOP;
   CLOSE csr_ee_unnddn;


   pay_element_template_api.delete_user_structure
     (p_validate                =>   FALSE
     ,p_drop_formula_packages   =>   TRUE
     ,p_template_id             =>   l_te_unnddn_id);


   hr_utility.set_location('Leaving :'||l_proc, 50);
   --
END delete_user_template;
--
END pqp_uk_union_template ;

/
