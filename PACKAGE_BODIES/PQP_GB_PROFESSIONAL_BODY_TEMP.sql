--------------------------------------------------------
--  DDL for Package Body PQP_GB_PROFESSIONAL_BODY_TEMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PROFESSIONAL_BODY_TEMP" AS
/* $Header: pqgbpbtp.pkb 115.3 2003/10/01 09:01:00 bsamuel noship $ */

/*========================================================================
 *                        CREATE_USER_TEMPLATE
 *=======================================================================*/
FUNCTION create_user_template
           (p_professional_body_name       in varchar2
           ,p_ele_name                     in varchar2
           ,p_ele_reporting_name           in varchar2
           ,p_ele_description              in varchar2     default NULL
           ,p_ele_processing_type          in varchar2
           ,p_ele_third_party_payment      in varchar2     default 'Y'
           ,p_override_amount              in varchar2     default 'N'
           ,p_professional_body_level_bal  in varchar2
           ,p_professional_body_level_yn   in varchar2
           ,p_ele_eff_start_date           in date         default NULL
           ,p_ele_eff_end_date             in date         default NULL
           ,p_bg_id                        in number
           )
   RETURN NUMBER IS
   --


   /*--------------------------------------------------------------------
    The input values are explained below : V-varchar2, D-Date, N-number
      Input-Name                    Type   Valid Values/Explaination
      ----------                    ----   --------------------------------------
      p_professional_body_name       (V) - LOV based i/p
      p_ele_name                     (V) - User i/p Element name
      p_ele_reporting_name           (V) - User i/p reporting name
      p_ele_description              (V) - User i/p Description
      p_ele_processiong_type         (V) - 'R'/'N' (Recurring/Non-recurring)
      p_ele_third_party_payment      (V) - 'Y'/'N'
      p_override_amount              (V) - 'Y'/'N'
      p_professional_body_level_bal  (V) - Professional Body Level Balance Name
      p_professional_body_level_yn   (V) - Balance already exists ('Y'/'N')
      p_ele_eff_start_date           (D) - Trunc(start date)
      p_ele_eff_end_date             (D) - Trunc(end date)
      p_bg_id                        (N) - Business group id
   ----------------------------------------------------------------------*/
   --
   l_template_id                 pay_shadow_element_types.template_id%TYPE;
   l_base_element_type_id        pay_template_core_objects.core_object_id%TYPE;
   l_source_template_id          pay_element_templates.template_id%TYPE;
   l_object_version_number       NUMBER(9);
   l_proc                        VARCHAR2(80) :=
                          'pqp_gb_professional_body_temp.create_user_template';
   l_override_amount             VARCHAR2(1);
   l_eei_info_id                 NUMBER;
   l_ovn_eei                     NUMBER;
   l_element_type_id             NUMBER;
   l_ele_obj_ver_number          NUMBER;
   l_ele_name                    pay_element_types_f.element_name%TYPE;
   l_name                        pay_input_values_f.name%TYPE;
   i                             NUMBER;

   l_ele_core_id                 pay_template_core_objects.core_object_id%TYPE:= -1;
   l_organization_id             NUMBER;

   -- Generic Never to be passed IN
   l_xx_rowid_id                 ROWID;

   l_bl_core_id                  pay_balance_types.balance_type_id%TYPE;
   l_bf_pbdbal_id                pay_shadow_balance_feeds.balance_feed_id%TYPE;
   l_db_core_id                  pay_defined_balances.defined_balance_id%TYPE;
   l_iv_core_id                  pay_template_core_objects.core_object_id%TYPE;
   l_dm_baldmn_id                pay_balance_dimensions.balance_dimension_id%TYPE;

   -- Extra Information variables
   l_eei_information3            pay_element_type_extra_info.eei_information3%TYPE;
   l_eei_information4            pay_element_type_extra_info.eei_information4%TYPE;

   --

   TYPE t_dim IS TABLE OF VARCHAR2(80)
   INDEX BY BINARY_INTEGER;

    l_dim                        t_dim;

   CURSOR csr_get_ele_info (c_ele_name varchar2) is
   SELECT element_type_id
         ,object_version_number
   FROM   pay_shadow_element_types
   WHERE  template_id    = l_template_id
     AND  element_name   = c_ele_name;

   --
   -- cursor to fetch the core element id
   --
   CURSOR c5 (c_element_name in varchar2) is
   SELECT ptco.core_object_id
   FROM   pay_shadow_element_types psbt,
          pay_template_core_objects ptco
   WHERE  psbt.template_id      = l_template_id
     AND  psbt.element_name     = c_element_name
     AND  ptco.template_id      = psbt.template_id
     AND  ptco.shadow_object_id = psbt.element_type_id
     AND  ptco.core_object_type = 'ET';

   CURSOR csr_get_pb_balid IS
   SELECT pbt.balance_type_id
         ,pbt.object_version_number
   FROM   pay_balance_types pbt
   WHERE  pbt.balance_name      = p_professional_body_level_bal
     AND  pbt.business_group_id = p_bg_id
     AND  (pbt.legislation_code IS NULL
          OR
           pbt.legislation_code = 'GB');

   csr_get_pb_balid_rec csr_get_pb_balid%ROWTYPE;

   CURSOR csr_get_ivid (c_element_type_id NUMBER
                       ,c_inputvalue_name VARCHAR2) IS
   SELECT siv.input_value_id
         ,siv.object_version_number
   FROM   pay_shadow_input_values siv
   WHERE  siv.element_type_id = c_element_type_id
     AND  siv.name            = c_inputvalue_name;

   csr_get_ivid_rec csr_get_ivid%ROWTYPE;

   CURSOR csr_get_orgid(c_org_name  VARCHAR2) IS
   SELECT hou.organization_id
   FROM   hr_all_organization_units hou
   WHERE  hou.name              = c_org_name
     AND  (hou.business_group_id = p_bg_id OR
           hou.business_group_id is null);

   -- Added cursor to get balance category info
   CURSOR csr_get_balance_cat_id (c_category_name VARCHAR2)
   IS
   SELECT balance_category_id
     FROM pay_balance_categories_f
    WHERE category_name = c_category_name
      AND legislation_code = 'GB'
      AND p_ele_eff_start_date BETWEEN effective_start_date
                                   AND effective_end_date;

   l_balance_category_id  NUMBER;

   --
   --======================================================================
   --                     FUNCTION GET_TEMPLATE_ID
   --======================================================================
   FUNCTION get_template_id (p_legislation_code    in varchar2 )
   RETURN number IS
     --
  --   l_template_id   NUMBER(9);
     l_template_name VARCHAR2(80);
     l_proc  varchar2(60)       := 'pqp_gb_professional_body_temp.get_template_id';
     --
     CURSOR csr_get_temp_id  is
     SELECT template_id
     FROM   pay_element_templates
     WHERE  template_name     = l_template_name
     AND    legislation_code  = p_legislation_code
     AND    template_type     = 'T'
     AND    business_group_id is NULL;
     --
   BEGIN
      --
      hr_utility.set_location('Entering: '||l_proc, 10);
      --
      l_template_name  := 'PQP PROFESSIONAL BODY';
      --
      hr_utility.set_location(l_proc, 20);
      --
      for csr_get_temp_id_rec in csr_get_temp_id loop
         l_template_id   := csr_get_temp_id_rec.template_id;
      end loop;
      --
      hr_utility.set_location('Leaving: '||l_proc, 30);
      --
      RETURN l_template_id;
      --
   END get_template_id;

-----------------------------------------------------------------------------

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
              p_bg_id)
            OR
             (business_group_id is null and legislation_code = 'GB'));

     l_bd_baldmn_id  pay_balance_dimensions.balance_dimension_id%TYPE;
     l_proc          varchar2(80) := 'pqp_gb_professional_body_temp.get_balance_dimension_id';

   BEGIN

     hr_utility.set_location('Entering: '||l_proc, 10);
   --
     FOR csr_id_baldmn_rec IN csr_id_baldmn LOOP
       l_bd_baldmn_id := csr_id_baldmn_rec.balance_dimension_id;
     END LOOP;
    --
     hr_utility.set_location('Leaving: '||l_proc, 20);

    --

     RETURN l_bd_baldmn_id;
   --
   END get_balance_dimension_id;


   --
   --=======================================================================
   --                FUNCTION GET_OBJECT_ID
   --=======================================================================
   FUNCTION get_object_id (p_object_type    in varchar2
                          ,p_object_name    in varchar2
                          ,p_shadow_id      in number   default null)
   RETURN NUMBER is
     --
     l_object_id  NUMBER      := NULL;
     l_proc   varchar2(60)    := 'pqp_gb_professional_body_temp.get_object_id';
     --
     CURSOR csr_get_ele_type_id (c_object_name varchar2) is
           SELECT element_type_id
             FROM   pay_element_types_f
            WHERE  element_name      = c_object_name
              AND  business_group_id = p_bg_id;
     --
     CURSOR csr_core_bal_id (c_object_name in varchar2) is
          SELECT ptco.core_object_id
            FROM   pay_shadow_balance_types psbt,
                   pay_template_core_objects ptco
           WHERE  psbt.template_id      = l_template_id
             AND  psbt.balance_name     = c_object_name
             AND  ptco.template_id      = psbt.template_id
             AND  ptco.shadow_object_id = psbt.balance_type_id;

     --
     CURSOR csr_core_obj_id  is
          SELECT ptco.core_object_id
            FROM   pay_template_core_objects ptco
          WHERE   ptco.template_id      = l_template_id
            AND   ptco.shadow_object_id = p_shadow_id
            AND   ptco.core_object_type = p_object_type;
     --
   BEGIN

      hr_utility.set_location('Entering: '||l_proc, 10);
      --
      if p_object_type = 'ELE' then
         for csr_get_ele_type_id_rec in csr_get_ele_type_id (p_object_name) loop
            l_object_id := csr_get_ele_type_id_rec.element_type_id;  -- element id
         end loop;
      elsif p_object_type = 'BAL' then
         for csr_core_bal_id_rec in csr_core_bal_id (p_object_name) loop
            l_object_id := csr_core_bal_id_rec.core_object_id;   -- balance id
         end loop;
      else
         if p_shadow_id is not null then
           for csr_core_obj_id_rec  in csr_core_obj_id loop
             l_object_id := csr_core_obj_id_rec.core_object_id; -- input value id
           end loop;
         end if;

      end if;
      --
      hr_utility.set_location('Leaving: '||l_proc, 20);
      --
      RETURN l_object_id;
      --
   END get_object_id;
   --
--===============================================================================
--                         MAIN FUNCTION
--===============================================================================
  BEGIN

     hr_utility.set_location('Entering : '||l_proc, 10);
   ---------------------
   -- Set session date
   ---------------------

   pay_db_pay_setup.set_session_date(nvl(p_ele_eff_start_date, sysdate));
   --
   hr_utility.set_location(l_proc, 20);
   --

  IF (hr_utility.chk_product_install('Oracle Payroll',g_template_leg_code))
  THEN

   ---------------------------
   -- Get Source Template ID
   ---------------------------
   l_source_template_id := get_template_id
                             (p_legislation_code  => g_template_leg_code
                             );

   /*--------------------------------------------------------------------------
      Create the user Structure
      The Configuration Flex segments for the Exclusion Rules are as follows:
    ---------------------------------------------------------------------------
    Config1  --
    Config2  --
   ---------------------------------------------------------------------------*/

   hr_utility.set_location(l_proc, 30);

   l_override_amount  := 'N';
   i                  := 0;

   -- Intialize all Extra Information type variables
   l_eei_information3  := 'N';
   l_eei_information4  := 'Y';

   -- Check whether an override amount is included

   IF p_override_amount  = 'Y' THEN
      l_override_amount  := 'Y';
      l_eei_information3 := 'Y';
   END IF; -- End if of override amount check...

   -- Check whether third party payment processing is excluded

   IF p_ele_third_party_payment = 'N' THEN
      l_eei_information4 := 'N';
   END IF; -- End if of third party payment check..

   --
   -- create user structure from the template
   --
   pay_element_template_api.create_user_structure
    (p_validate                      =>     false
    ,p_effective_date                =>     p_ele_eff_start_date
    ,p_business_group_id             =>     p_bg_id
    ,p_source_template_id            =>     l_source_template_id
    ,p_base_name                     =>     p_ele_name
    ,p_configuration_information1    =>     l_override_amount
    ,p_template_id                   =>     l_template_id
    ,p_object_version_number         =>     l_object_version_number
    );
   --

   hr_utility.set_location(l_proc, 40);
   ---------------------------------------------------------------------------
   ---------------------------- Update Shadow Structure ----------------------
   --

   OPEN csr_get_ele_info(p_ele_name);
   LOOP
     FETCH csr_get_ele_info INTO l_element_type_id,l_ele_obj_ver_number;
     EXIT WHEN csr_get_ele_info%NOTFOUND;

     pay_shadow_element_api.update_shadow_element
       (p_validate                     => false
       ,p_effective_date               => p_ele_eff_start_date
       ,p_element_type_id              => l_element_type_id
       ,p_element_name                 => p_ele_name
       ,p_reporting_name               => p_ele_reporting_name
       ,p_description                  => p_ele_description
       ,p_processing_type              => p_ele_processing_type
       ,p_third_party_pay_only_flag    => p_ele_third_party_payment
       ,p_object_version_number        => l_ele_obj_ver_number
       );

   END LOOP;
   CLOSE csr_get_ele_info;

   -------------------------------------------------------------------------
   --
   --
   hr_utility.set_location(l_proc, 50);
   ---------------------------------------------------------------------------
   ---------------------------- Generate Core Objects ------------------------
   ---------------------------------------------------------------------------

   pay_element_template_api.generate_part1
    (p_validate                      =>     false
    ,p_effective_date                =>     p_ele_eff_start_date
    ,p_hr_only                       =>     false
    ,p_hr_to_payroll                 =>     false
    ,p_template_id                   =>     l_template_id);
   --
   hr_utility.set_location(l_proc, 60);
   --
   pay_element_template_api.generate_part2
    (p_validate                      =>     false
    ,p_effective_date                =>     p_ele_eff_start_date
    ,p_template_id                   =>     l_template_id);
   --

   hr_utility.set_location(l_proc, 70);

   l_ele_core_id := get_object_id (p_object_type => 'ELE'
                                  ,p_object_name => p_ele_name
                                  );

   hr_utility.set_location(l_proc, 80);

   IF p_professional_body_level_yn = 'N' THEN
   --
   -- If this is the first time that the driver is being run for an element
   -- then create a professional body level balance with the given name and its associated
   -- feed. All subsequent runs of the driver, for the same professional body, will only
   -- create the feed.
   --
   -- NB This balance will not have a corresponding user structure created.
   -- This is because, a user may delete the corresponding user structure and
   -- thus corrupt the feeds created by other runs of the same template.
   --
   -- This places an additional requirement on the delete_user_structure
   -- procedure to detect if the user structure being deleted is the last user
   -- structure and if so it must then delete the corresponding professional body level
   -- balance. In all cases the core objects may not be deleted if a payroll
   -- has been run with the professional body element.
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
        (X_Rowid                        => l_xx_rowid_id                 -- IN OUT VARCHAR2
        ,X_Balance_Type_Id              => l_bl_core_id                  -- IN OUT NUMBER
        ,X_Business_Group_Id            => p_bg_id                       -- NUMBER
        ,X_Legislation_Code             => NULL                          -- VARCHAR2
        ,X_Currency_Code                => 'GBP'                         -- VARCHAR2
        ,X_Assignment_Remuneration_Flag => 'N'                           -- VARCHAR2
        ,X_Balance_Name                 => p_professional_body_level_bal -- VARCHAR2
        ,X_Base_Balance_Name            => p_professional_body_level_bal -- VARCHAR2
        ,X_Balance_Uom                  => 'M'                           -- VARCHAR2
        ,X_Comments                     => 'Professional body Level balance for '||
                                           p_professional_body_name      -- VARCHAR2
        ,X_Legislation_Subgroup         => NULL                          -- VARCHAR2
        ,X_Reporting_Name               => p_professional_body_level_bal -- VARCHAR2
        ,X_Attribute_Category           => NULL                          -- VARCHAR2
        ,X_Attribute1                   => NULL                          -- VARCHAR2
        ,X_Attribute2                   => NULL                          -- VARCHAR2
        ,X_Attribute3                   => NULL                          -- VARCHAR2
        ,X_Attribute4                   => NULL                          -- VARCHAR2
        ,X_Attribute5                   => NULL                          -- VARCHAR2
        ,X_Attribute6                   => NULL                          -- VARCHAR2
        ,X_Attribute7                   => NULL                          -- VARCHAR2
        ,X_Attribute8                   => NULL                          -- VARCHAR2
        ,X_Attribute9                   => NULL                          -- VARCHAR2
        ,X_Attribute10                  => NULL                          -- VARCHAR2
        ,X_Attribute11                  => NULL                          -- VARCHAR2
        ,X_Attribute12                  => NULL                          -- VARCHAR2
        ,X_Attribute13                  => NULL                          -- VARCHAR2
        ,X_Attribute14                  => NULL                          -- VARCHAR2
        ,X_Attribute15                  => NULL                          -- VARCHAR2
        ,X_Attribute16                  => NULL                          -- VARCHAR2
        ,X_Attribute17                  => NULL                          -- VARCHAR2
        ,X_Attribute18                  => NULL                          -- VARCHAR2
        ,X_Attribute19                  => NULL                          -- VARCHAR2
        ,X_Attribute20                  => NULL                          -- VARCHAR2
        ,X_balance_category_id          => l_balance_category_id
        );

        hr_utility.set_location(l_proc, 90);

   -- now create the defined balances also for _ASG_RUN/PROC_PTD/STAT_YTD

        l_dim(1) := '_ASG_RUN';
        l_dim(2) := '_ASG_PROC_PTD';
        l_dim(3) := '_ASG_STAT_YTD';
        l_dim(4) := '_PER_TD_YTD';

        FOR i IN 1..l_dim.count LOOP

          l_dm_baldmn_id := get_balance_dimension_id(l_dim(i));
          l_xx_rowid_id  := NULL;
          l_db_core_id   := NULL;
          pay_defined_balances_pkg.insert_row
            (x_rowid                        => l_xx_rowid_id  -- IN OUT VARCHAR2
            ,x_defined_balance_id           => l_db_core_id   -- IN OUT NUMBER
            ,x_business_group_id            => p_bg_id        -- NUMBER
            ,x_legislation_code             => NULL           -- VARCHAR2
            ,x_balance_type_id              => l_bl_core_id   -- NUMBER
            ,x_balance_dimension_id         => l_dm_baldmn_id -- NUMBER
            ,x_force_latest_balance_flag    => NULL           -- VARCHAR2
            ,x_legislation_subgroup         => NULL           -- VARCHAR2
            ,x_grossup_allowed_flag         => 'N'            -- VARCHAR2
            );

        END LOOP;


   ELSE -- this is not the first run

   -- so query out the core balance type id for the given balance name

     hr_utility.set_location(l_proc, 100);

     OPEN csr_get_pb_balid;
     FETCH csr_get_pb_balid INTO csr_get_pb_balid_rec;
     IF csr_get_pb_balid%NOTFOUND THEN
     --
       CLOSE csr_get_pb_balid;
       hr_utility.set_message(8303, 'PQP_230538_PBDBAL_NOT_FOUND');
       hr_utility.raise_error;

     ELSE

       l_bl_core_id :=  csr_get_pb_balid_rec.balance_type_id;

     END IF;
     CLOSE csr_get_pb_balid;

   END IF;

   hr_utility.set_location(l_proc, 110);

   OPEN csr_get_ivid(l_element_type_id, 'Pay Value');
   FETCH csr_get_ivid INTO csr_get_ivid_rec;
   CLOSE csr_get_ivid;

   hr_utility.set_location(l_proc, 120);

   l_iv_core_id := get_object_id
                     (p_object_type   => 'IV'
                     ,p_object_name   => 'Pay Value' -- dummy
                     ,p_shadow_id     => csr_get_ivid_rec.input_value_id
                     );

   IF l_iv_core_id IS NULL OR l_ele_core_id IS NULL THEN
   -- Error Out
         hr_utility.set_message(8303, 'PQP_230539_PBD_GENERATE_FAILED');
         hr_utility.raise_error;

   ELSE

     hr_utility.set_location(l_proc, 130);

     l_xx_rowid_id := NULL;
     pay_balance_feeds_f_pkg.insert_row
       (x_rowid                      => l_xx_rowid_id        -- IN OUT VARCHAR2,
       ,x_balance_feed_id            => l_bf_pbdbal_id       -- IN OUT NUMBER,
       ,x_effective_start_date       => p_ele_eff_start_date -- DATE,
       ,x_effective_end_date         => p_ele_eff_end_date   -- DATE,
       ,x_business_group_id          => p_bg_id              -- NUMBER,
       ,x_legislation_code           => g_template_leg_code  -- VARCHAR2,
       ,x_balance_type_id            => l_bl_core_id         -- NUMBER,
       ,x_input_value_id             => l_iv_core_id         -- NUMBER,
       ,x_scale                      => 1                    -- NUMBER,
       ,x_legislation_subgroup       => NULL                 -- VARCHAR2
       );


   END IF; -- IF any core id is null THEN

   hr_utility.set_location(l_proc, 140);

   --
   -- Retrieve organization id for the organization name
   --

   l_organization_id := NULL;
   OPEN csr_get_orgid (p_professional_body_name);
   FETCH csr_get_orgid INTO l_organization_id;
   IF csr_get_orgid%NOTFOUND THEN

      -- Error Out
      CLOSE csr_get_orgid;
      hr_utility.set_message(8303, 'PQP_230537_PBD_ORG_NOT_FOUND');
      hr_utility.raise_error;

   END IF; -- Organization id not found chk...
   CLOSE csr_get_orgid;

   hr_utility.set_location(l_proc, 160);

   l_base_element_type_id := get_object_id ('ELE', p_ele_name);

   hr_utility.set_location(l_proc, 170);

-- Create a row in pay_element_extra_info with all the element information

    pay_element_extra_info_api.create_element_extra_info
                              (p_element_type_id            => l_base_element_type_id
                              ,p_information_type           => 'PQP_PROFESSIONAL_BODY_INFO'
                              ,P_EEI_INFORMATION_CATEGORY   => 'PQP_PROFESSIONAL_BODY_INFO'
                              ,p_eei_information1           => TO_CHAR(l_organization_id)
--                              ,p_eei_information1           => p_professional_body_name
                              ,p_eei_information2           => p_professional_body_level_bal
                              ,p_eei_information3           => l_eei_information3
                              ,p_eei_information4           => l_eei_information4
                              ,p_element_type_extra_info_id => l_eei_info_id
                              ,p_object_version_number      => l_ovn_eei);

 ELSE

   hr_utility.set_message(8303, 'PQP_230535_GBORAPAY_NOT_FOUND');
   hr_utility.raise_error;


 END IF; -- IF chk_product_install('Oracle Payroll',g_template_leg_code))

 hr_utility.set_location('Leaving :'||l_proc, 180);

 RETURN l_base_element_type_id;

  --
END create_user_template;
--
--
--==========================================================================
--                             Deletion procedure
--==========================================================================
--
PROCEDURE delete_user_template
           (p_professional_body_name      in varchar2
           ,p_professional_body_level_bal in varchar2
           ,p_business_group_id           in number
           ,p_ele_type_id                 in number
           ,p_ele_name                    in varchar2
           ,p_effective_date              in date
           ) IS
  --
  l_template_id   NUMBER(9);
  l_proc          varchar2(60)      :='pqp_gb_professional_body_temp.delete_user_template';
  l_eei_info_id   number;
  l_ovn_eei       number;
  l_del_pbd_level_balance_yn varchar2(1) := 'Y';
  --
  CURSOR eei is
  SELECT element_type_extra_info_id
   FROM pay_element_type_extra_info petei
   WHERE element_type_id = p_ele_type_id ;


 CURSOR csr_get_template_id is
  SELECT template_id
  FROM   pay_element_templates
  WHERE  base_name         = p_ele_name
    AND  business_group_id = p_business_group_id
    AND  template_type     = 'U';

  CURSOR csr_get_other_tempid (c_te_usrstr_id NUMBER) IS
  SELECT usr_others.template_id
  FROM   pay_element_templates usr_this
        ,pay_element_templates usr_others
  WHERE  usr_this.template_id     = c_te_usrstr_id
    AND  usr_others.template_name = usr_this.template_name
    AND  usr_others.template_type = 'U'
    AND  usr_others.template_id  <> usr_this.template_id;

  csr_get_other_tempid_rec  csr_get_other_tempid%ROWTYPE;

  CURSOR csr_get_orginfo (c_te_usrstr_id NUMBER) IS
  SELECT TO_NUMBER(peei.eei_information1) pbd_org_id
  FROM   pay_element_templates       pets
        ,pay_shadow_element_types    pset
        ,pay_template_core_objects   ptco
        ,pay_element_type_extra_info peei
  WHERE  pets.template_id      = c_te_usrstr_id    -- For the given user structure
    AND  pset.template_id      = pets.template_id  -- find the base element
    AND  pset.element_name     = pets.base_name
    AND  ptco.template_id      = pset.template_id  -- For the base element
    AND  ptco.shadow_object_id = pset.element_type_id -- find the core element
    AND  ptco.core_object_type = 'ET'
    AND  ptco.core_object_id   = peei.element_type_id -- For the core element
    AND  peei.information_type = 'PQP_PROFESSIONAL_BODY_INFO' -- find the eei info
  ;

  csr_get_orginfo_rec  csr_get_orginfo%ROWTYPE;

   CURSOR csr_get_orgid (c_pb_orgid NUMBER) IS
   SELECT horg.organization_id
   FROM   hr_all_organization_units horg
   WHERE  horg.organization_id = c_pb_orgid
     AND  horg.name            = p_professional_body_name
     AND  ( horg.business_group_id = p_business_group_id
          OR horg.business_group_id IS NULL);

  csr_get_orgid_rec  csr_get_orgid%ROWTYPE;

  CURSOR csr_get_pb_balid IS
  SELECT pbts.rowid
        ,pbts.balance_type_id
  FROM   pay_balance_types pbts
  WHERE  pbts.balance_name      = p_professional_body_level_bal
    AND  pbts.business_group_id = p_business_group_id
    AND  pbts.legislation_code IS NULL;

  csr_get_pb_balid_rec csr_get_pb_balid%ROWTYPE;

--
BEGIN
   --
   hr_utility.set_location('Entering :'||l_proc, 10);

   --
   FOR csr_get_template_id_rec IN csr_get_template_id LOOP
       l_template_id := csr_get_template_id_rec.template_id;
   END LOOP;

   hr_utility.set_location(l_proc, 20);

   --
   -- Check to see if there are other user structures for the given template.
   -- If there are then check to see if they have they belong to the same
   -- professional body as the one being deleted.
   --
   OPEN csr_get_other_tempid(l_template_id);
   FETCH csr_get_other_tempid INTO csr_get_other_tempid_rec;
   --
   -- If no other structures were found this was the last user structure for
   -- professional body deductions. So don't bother to check the extra element info and
   -- delete the professional body level balance. If on the other hand more user structures
   -- were found then loop thru each of them to check if they belong to the
   -- same professional body.
   --
   IF csr_get_other_tempid%FOUND THEN
     LOOP

       hr_utility.set_location(l_proc, 30);

       OPEN csr_get_orginfo(csr_get_other_tempid_rec.template_id);
       FETCH csr_get_orginfo INTO csr_get_orginfo_rec;
       CLOSE csr_get_orginfo;

       hr_utility.set_location(l_proc, 40);

       OPEN csr_get_orgid(csr_get_orginfo_rec.pbd_org_id);
       FETCH csr_get_orgid INTO csr_get_orgid_rec;
       IF csr_get_orgid%FOUND THEN
         CLOSE csr_get_orgid;
         l_del_pbd_level_balance_yn := 'N';
         EXIT; -- Even if one more matching user structure exists
               -- the balance cannot be deleted.
       END IF;
       CLOSE csr_get_orgid;

       hr_utility.set_location(l_proc, 50);

       FETCH csr_get_other_tempid INTO csr_get_other_tempid_rec;
       EXIT WHEN csr_get_other_tempid%NOTFOUND;
     END LOOP;
   --
   END IF;
   CLOSE csr_get_other_tempid;

   hr_utility.set_location(l_proc, 60);

   IF l_del_pbd_level_balance_yn = 'Y' THEN
   --
   -- Delete the professional body level balance also.
   -- NB This will also delete any dependent feeds and defined balances.
   --
     OPEN csr_get_pb_balid;
     FETCH csr_get_pb_balid INTO csr_get_pb_balid_rec;
     IF csr_get_pb_balid%NOTFOUND THEN
     --
       CLOSE csr_get_pb_balid;
       hr_utility.set_message(8303, 'PQP_230538_PBDBAL_NOT_FOUND');
       hr_utility.raise_error;
     --
     END IF;
     CLOSE csr_get_pb_balid;

     hr_utility.set_location(l_proc, 70);

     pay_balance_types_pkg.delete_row
       (x_rowid             => csr_get_pb_balid_rec.rowid         -- VARCHAR2
       ,x_balance_type_id   => csr_get_pb_balid_rec.balance_type_id  -- NUMBER
       );

   END IF;

   hr_utility.set_location(l_proc, 80);
   --
   OPEN eei;
    LOOP
    FETCH eei INTO l_eei_info_id  ;
    EXIT WHEN eei%NOTFOUND;


    pay_element_extra_info_api.delete_element_extra_info
                              (p_validate                    => FALSE
                              ,p_element_type_extra_info_id  => l_eei_info_id
                              ,p_object_version_number       => l_ovn_eei);


      END LOOP;
     CLOSE eei;

   --
   hr_utility.set_location(l_proc, 90);

   pay_element_template_api.delete_user_structure
     (p_validate                =>   false
     ,p_drop_formula_packages   =>   true
     ,p_template_id             =>   l_template_id);
   --

   hr_utility.set_location('Leaving :'||l_proc, 100);
   --
END delete_user_template;
--
END pqp_gb_professional_body_temp;


/
