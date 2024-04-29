--------------------------------------------------------
--  DDL for Package Body PQP_GB_STAKEHOLDER_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_STAKEHOLDER_TEMPLATE" AS
/* $Header: pqgbstht.pkb 120.1 2005/05/30 00:12:24 rvishwan noship $ */

/*========================================================================
 *                        CREATE_USER_TEMPLATE
 *=======================================================================*/
FUNCTION create_user_template
           (p_frm_sd_scheme_name           IN     VARCHAR2 --'Stakeholder'
           ,p_frm_sd_contribution_method   IN     VARCHAR2 --Ex Rule Eme Cntrbn
           ,p_frm_sd_employee_contribution IN     NUMBER
           ,p_frm_be_element_name          IN     VARCHAR2
           ,p_frm_be_reporting_name        IN     VARCHAR2
--         ,p_frm_be_classification        --     Always 'Voluntary Deductions'
           ,p_frm_be_description           IN     VARCHAR2 DEFAULT NULL
           ,p_frm_ae_employer_contribution IN     VARCHAR2 DEFAULT 'N'--Ex Rule
           ,p_frm_ae_type                  IN     VARCHAR2 DEFAULT NULL
           ,p_frm_ae_rate                  IN     NUMBER   DEFAULT NULL
           ,p_frm_ctl_effective_start_date IN     DATE     DEFAULT NULL
           ,p_frm_ctl_effective_end_date   IN     DATE     DEFAULT NULL
           ,p_frm_ctl_business_group_id    IN     NUMBER
           )
   RETURN NUMBER -- Base Element Core Object ID
IS
   /*-------------------------------------------------------------------------
    The input values are explained below : V-varchar2, D-Date, N-number
      Input-Name                     Type  Valid Values/Explaination
      ----------                     ----  ----------------------------------
      p_frm_sd_scheme_name           (V)   'Stakeholder Pension' -- Maybe ?
      p_frm_sd_contribution_method   (V)   'P'or'F' Ex Rule Employee Contributn
      p_frm_sd_employee_contribution (V)   Default Amount The Selected Method
      p_frm_be_element_name          (V)   Base Element Name = <BASE NAME>
      p_frm_be_reporting_name        (V)   Reporting Name
--    p_frm_be_classification        (V)   Always 'Voluntary Deduction'
      p_frm_be_description           (V)   Optional Element Description
      p_frm_ae_employer_contribution (V)   Optional Ex Rule Employer Contributn
      p_frm_ae_type                  (V)   Optional Ex Rule Employer Contributn
      p_frm_ae_rate                  (N)   Optional Employer Contribution Rate
      p_frm_ctl_effective_start_date (D)   Standard Effective Start Date
      p_frm_ctl_effective_end_date   (D)   Standard Effective End Date
      p_frm_ctl_busines_group_id     (N)   Standard Business Group Id
   -------------------------------------------------------------------------*/

   l_proc                        VARCHAR2(61):= g_proc||'create_user_template';

   l_xx_stkhldr_ovn              NUMBER(9);

   l_te_source_id                NUMBER(9);
   l_te_ustrctr_id               NUMBER(9);

   l_ex_emrfctr_yn               VARCHAR2(150);
   l_ex_emrpctr_yn               VARCHAR2(150);

   l_el_stkcore_id               NUMBER(9);
   l_el_bsuffix_nm               VARCHAR2(40);
   l_el_skpfrml_nm               VARCHAR2(80):= NULL; -- Explicit

   l_ee_stkhldr_id               NUMBER;

   l_contribution_method_name    VARCHAR2(80);
   l_employer_contribution_type  VARCHAR2(80);


   CURSOR csr_el_stkhldr_details(p_el_stkhldr_nm VARCHAR2) IS
   SELECT element_type_id
         ,object_version_number
   FROM   pay_shadow_element_types
   WHERE  template_id = l_te_ustrctr_id
     AND  element_name = p_el_stkhldr_nm;

   row_el_stkhldr_details csr_el_stkhldr_details%ROWTYPE;

   CURSOR csr_iv_emecntr(p_el_stkhldr_id NUMBER) IS
   SELECT input_value_id
         ,object_version_number
   FROM   pay_shadow_input_values
   WHERE  element_type_id = p_el_stkhldr_id
     AND  name = DECODE(p_frm_sd_contribution_method
                       ,'P','Percentage Contribution'
                       ,'F','Flat Rate Contribution'
                       ,NULL);

   row_iv_emecntr csr_iv_emecntr%ROWTYPE;

   CURSOR csr_iv_emrcntr(p_el_stkhldr_id NUMBER) IS
   SELECT input_value_id
         ,object_version_number
   FROM   pay_shadow_input_values
   WHERE  element_type_id = p_el_stkhldr_id
     AND  name = DECODE(p_frm_ae_type
                       ,'P','Employers Percentage'
                       ,'F','Employers Factor'
                       ,NULL);

   row_iv_emrcntr csr_iv_emrcntr%ROWTYPE;


   CURSOR csr_iv_schname(p_el_stkhldr_id NUMBER) IS
   SELECT input_value_id
         ,object_version_number
   FROM   pay_shadow_input_values
   WHERE  element_type_id = p_el_stkhldr_id
     AND  name = 'Scheme Name';

   row_iv_schname csr_iv_schname%ROWTYPE;



   --
   -- cursor to fetch the core element id
   --
   CURSOR c5 (c_element_name in varchar2) is
   SELECT ptco.core_object_id
   FROM   pay_shadow_element_types psbt,
          pay_template_core_objects ptco
   WHERE  psbt.template_id      = l_te_ustrctr_id
     AND  psbt.element_name     = c_element_name
     AND  ptco.template_id      = psbt.template_id
     AND  ptco.shadow_object_id = psbt.element_type_id
     AND  ptco.core_object_type = 'ET';

--======================================================================
--                     FUNCTION GET_TEMPLATE_ID
--======================================================================
   FUNCTION get_template_id (p_legislation_code    in varchar2 )
   RETURN number IS
     --
     l_template_id   NUMBER(9);
     l_template_name VARCHAR2(80);
     l_proc  varchar2(61)       := g_proc||'get_template_id';
     --
     CURSOR c4  is
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
      l_template_name  := 'PQP STAKEHOLDER PENSION';
      --
      hr_utility.set_location(l_proc, 30);
      --
      for c4_rec in c4 loop
         l_template_id   := c4_rec.template_id;
      end loop;
      --
      hr_utility.set_location('Leaving: '||l_proc, 100);
      --
      RETURN l_template_id;
      --
   END get_template_id;



--=======================================================================
--                FUNCTION GET_OBJECT_ID
--=======================================================================

   FUNCTION get_object_id (p_object_type    in varchar2,
                           p_object_name   in varchar2)
   RETURN NUMBER is
     --
     l_object_id  NUMBER      := NULL;
     l_proc   varchar2(61)    := g_proc||'get_object_id';
     --
     CURSOR c2 (c_object_name varchar2) is
           SELECT element_type_id
             FROM   pay_element_types_f
            WHERE  element_name      = c_object_name
              AND  business_group_id = p_frm_ctl_business_group_id;
     --
     CURSOR c3 (c_object_name in varchar2) is
          SELECT ptco.core_object_id
            FROM   pay_shadow_balance_types psbt,
                   pay_template_core_objects ptco
           WHERE  psbt.template_id      = l_te_ustrctr_id
             AND  psbt.balance_name     = c_object_name
             AND  ptco.template_id      = psbt.template_id
             AND  ptco.shadow_object_id = psbt.balance_type_id;
     --
   BEGIN
      hr_utility.set_location('Entering: '||l_proc, 10);
      --
      if p_object_type = 'ELE' then
         for c2_rec in c2 (p_object_name) loop
            l_object_id := c2_rec.element_type_id;  -- element id
         end loop;
      elsif p_object_type = 'BAL' then
         for c3_rec in c3 (p_object_name) loop
            l_object_id := c3_rec.core_object_id;   -- balance id
         end loop;
      end if;
      --
      hr_utility.set_location('Leaving: '||l_proc, 50);
      --
      RETURN l_object_id;
      --
   END get_object_id;
   --
--============================================================================
--                         MAIN FUNCTION
--============================================================================

   /*-------------------------------------------------------------------------
    The input values are explained below : V-varchar2, D-Date, N-number
      Input-Name                     Type  Valid Values/Explaination
      ----------                     ----  ---------------------------------
      p_frm_sd_scheme_name           (V)   'Stakeholder Pension' -- Maybe ?
      p_frm_sd_contribution_method   (V)   'P'or'F' Ex Rule Employee Contributn
      p_frm_sd_employee_contribution  (V)   Default Amount The Selected Method
      p_frm_be_element_name          (V)   Base Element Name = <BASE NAME>
      p_frm_be_reporting_name        (V)   Reporting Name
--    p_frm_be_classification        (V)   Always 'Voluntary Deduction'
      p_frm_be_description           (V)   Optional Element Description
      p_frm_ae_employer_contribution (V)   Optional Ex Rule Employer Contributn
      p_frm_ae_type                  (V)   Optional Ex Rule Employer Contributn
      p_frm_ae_rate                  (N)   Optional Employer Contribution Rate
      p_frm_ctl_effective_start_date (D)   Standard Effective Start Date
      p_frm_ctl_effective_end_date   (D)   Standard Effective End Date
      p_frm_ctl_busines_group_id     (N)   Standard Business Group Id
   -------------------------------------------------------------------------*/



BEGIN

  hr_utility.set_location('Entering : '||l_proc, 10);



--------------------------- Set session date ---------------------------------

  pay_db_pay_setup.set_session_date
    (NVL(p_frm_ctl_effective_start_date, TRUNC(SYSDATE))
    );

  hr_utility.set_location(l_proc, 20);



-------------------------- Get Source Template ID ----------------------------

  l_te_source_id := get_template_id
                       (p_legislation_code  => 'GB'
                       );

  hr_utility.set_location(l_proc, 30);




------------------ Setup Flags For The Exclusion Rules -----------------------

  -- If the user has checked employer contribution only then create the
  -- input values for the employer contribution.

  IF p_frm_ae_employer_contribution = 'Y' THEN

    IF p_frm_ae_type = 'P'/*ercentage*/ THEN

      l_ex_emrfctr_yn := 'N';  -- Exclude Input Value For Factor
      l_ex_emrpctr_yn := 'Y';  -- Create  Input Value For Percentage

    ELSE

      l_ex_emrfctr_yn := 'Y';  -- Create Input Value For Factor
      l_ex_emrpctr_yn := 'N';  -- Exclude Input Value For Percentage

    END IF;

  ELSE -- p_frm_ae_employer_contribution is 'N'

    l_ex_emrfctr_yn := 'N';  -- Exclude Input Value For Factor
    l_ex_emrpctr_yn := 'N';  -- Exclude Input Value For Percentage

  END IF;

  -- Flat rate deductions should be applied only once in a period.
  IF p_frm_sd_contribution_method = 'F'/*lat Rate*/ THEN

    l_el_skpfrml_nm := 'ONCE_EACH_PERIOD';

--Percentage calculation should be applied to all runs in the period.
--Hence leave skip formula name as the default ie NULL.

  END IF;



  pay_element_template_api.create_user_structure
    (p_validate                   => FALSE
    ,p_effective_date             => p_frm_ctl_effective_start_date
    ,p_business_group_id          => p_frm_ctl_business_group_id
    ,p_source_template_id         => l_te_source_id
    ,p_base_name                  => p_frm_be_element_name
    ,p_configuration_information1 => p_frm_sd_contribution_method
    ,p_configuration_information2 => l_ex_emrpctr_yn
    ,p_configuration_information3 => l_ex_emrfctr_yn
    ,p_configuration_information4 => p_frm_ae_employer_contribution
    ,p_template_id                => l_te_ustrctr_id -- Returned User Struct ID
    ,p_object_version_number      => l_xx_stkhldr_ovn
    );

  hr_utility.set_location(l_proc, 40);



---------------------------- Update Shadow Structure --------------------------


-- Update reporting name and description on the base element

  l_el_bsuffix_nm := ' Stakeholder Pension';
  OPEN csr_el_stkhldr_details(p_frm_be_element_name||l_el_bsuffix_nm);
--  LOOP
    FETCH csr_el_stkhldr_details INTO row_el_stkhldr_details;
--    EXIT WHEN csr_el_stkhldr_details%NOTFOUND;
    pay_shadow_element_api.update_shadow_element
      (p_validate               => FALSE
       ,p_effective_date        => p_frm_ctl_effective_start_date
       ,p_element_type_id       => row_el_stkhldr_details.element_type_id
--     ,p_element_name          => p_frm_be_element_name
       ,p_reporting_name        => p_frm_be_reporting_name
       ,p_description           => p_frm_be_description
       ,p_skip_formula          => l_el_skpfrml_nm
       ,p_object_version_number => row_el_stkhldr_details.object_version_number
      );
--  END LOOP;
  CLOSE csr_el_stkhldr_details;

  hr_utility.set_location(l_proc, 50);


-- Update the input values of the base element with user defaults.

  -- Update the employee contribution input value
  OPEN csr_iv_emecntr(row_el_stkhldr_details.element_type_id);
  FETCH csr_iv_emecntr INTO row_iv_emecntr;
--  IF csr_iv_emecntr%NOTFOUND THEN
--  -- Common Fatal Error Out
--    hr_utility.set_message(8303, 'PQP_STKTEST_EMECNTR_NOT_FOUND');
--    hr_utility.raise_error;
--  ELSE
    pay_siv_upd.upd
      (p_effective_date        => p_frm_ctl_effective_start_date
      ,p_input_value_id        => row_iv_emecntr.input_value_id
      ,p_element_type_id       => row_el_stkhldr_details.element_type_id
--      ,p_display_sequence       =>   --   in number
--      ,p_generate_db_items_flag =>   --   in varchar2
--      ,p_hot_default_flag       =>   --   in varchar2
--      ,p_mandatory_flag         =>   --   in varchar2
--      ,p_name                   =>   --   in varchar2
--      ,p_uom                    =>   --   in varchar2
--      ,p_lookup_type            =>   --   in varchar2
      ,p_default_value         => p_frm_sd_employee_contribution
--      ,p_max_value              =>   --   in varchar2
--      ,p_min_value              =>   --   in varchar2
--      ,p_warning_or_error       =>   --   in varchar2
--      ,p_default_value_column   =>   --   in varchar2
--      ,p_exclusion_rule_id      =>   --   in number
      ,p_object_version_number => row_iv_emecntr.object_version_number --inout
      );
--  END IF;
  CLOSE csr_iv_emecntr;

  hr_utility.set_location(l_proc, 60);


  -- And if required update the employer contribution input value

  IF p_frm_ae_employer_contribution = 'Y' THEN

    hr_utility.set_location(l_proc, 70);

    OPEN csr_iv_emrcntr(row_el_stkhldr_details.element_type_id);
    FETCH csr_iv_emrcntr INTO row_iv_emrcntr;
--    IF csr_iv_emrcntr%NOTFOUND THEN
--    -- Common Fatal Error Out
--      hr_utility.set_message(8303, 'PQP_STKTEST_EMRCNTR_NOT_FOUND');
--      hr_utility.raise_error;
--    ELSE
      pay_siv_upd.upd
        (p_effective_date         => p_frm_ctl_effective_start_date
        ,p_input_value_id         => row_iv_emrcntr.input_value_id
        ,p_element_type_id        => row_el_stkhldr_details.element_type_id
--        ,p_display_sequence       =>   --   in number
--        ,p_generate_db_items_flag =>   --   in varchar2
--        ,p_hot_default_flag       =>   --   in varchar2
--        ,p_mandatory_flag         =>   --   in varchar2
--        ,p_name                   =>   --   in varchar2
--        ,p_uom                    =>   --   in varchar2
--        ,p_lookup_type            =>   --   in varchar2
        ,p_default_value          => p_frm_ae_rate      -- varchar2
--        ,p_max_value              =>   --   in varchar2
--        ,p_min_value              =>   --   in varchar2
--        ,p_warning_or_error       =>   --   in varchar2
--        ,p_default_value_column   =>   --   in varchar2
--        ,p_exclusion_rule_id      =>   --   in number
        ,p_object_version_number  => row_iv_emrcntr.object_version_number
        );
--  END IF;
  CLOSE csr_iv_emrcntr;

  END IF;

  hr_utility.set_location(l_proc, 80);


  -- Update the scheme name input value
  OPEN csr_iv_schname(row_el_stkhldr_details.element_type_id);
  FETCH csr_iv_schname INTO row_iv_schname;
--  IF csr_iv_schname%NOTFOUND THEN
--  -- Common Fatal Error Out
--    hr_utility.set_message(8303, 'PQP_STKTEST_EMECNTR_NOT_FOUND');
--    hr_utility.raise_error;
--  ELSE
    pay_siv_upd.upd
      (p_effective_date        => p_frm_ctl_effective_start_date
      ,p_input_value_id        => row_iv_schname.input_value_id
      ,p_element_type_id       => row_el_stkhldr_details.element_type_id
--      ,p_display_sequence       =>   --   in number
--      ,p_generate_db_items_flag =>   --   in varchar2
--      ,p_hot_default_flag       =>   --   in varchar2
--      ,p_mandatory_flag         =>   --   in varchar2
--      ,p_name                   =>   --   in varchar2
--      ,p_uom                    =>   --   in varchar2
--      ,p_lookup_type            =>   --   in varchar2
      ,p_default_value         => p_frm_sd_scheme_name
--      ,p_max_value              =>   --   in varchar2
--      ,p_min_value              =>   --   in varchar2
--      ,p_warning_or_error       =>   --   in varchar2
--      ,p_default_value_column   =>   --   in varchar2
--      ,p_exclusion_rule_id      =>   --   in number
      ,p_object_version_number => row_iv_schname.object_version_number --inout
      );
--  END IF;
  CLOSE csr_iv_schname;


  hr_utility.set_location(l_proc, 90);



-------------------------- Generate Core Objects -----------------------------

  pay_element_template_api.generate_part1
    (p_validate                 => FALSE
    ,p_effective_date           => p_frm_ctl_effective_start_date
    ,p_hr_only                  => FALSE
    ,p_hr_to_payroll            => FALSE
    ,p_template_id              => l_te_ustrctr_id
    );

  hr_utility.set_location(l_proc, 100);

  pay_element_template_api.generate_part2
    (p_validate                 => FALSE
    ,p_effective_date           => p_frm_ctl_effective_start_date
    ,p_template_id              => l_te_ustrctr_id
    );


  hr_utility.set_location(l_proc, 110);

  l_el_stkcore_id := get_object_id
                       ('ELE'
                       ,p_frm_be_element_name||l_el_bsuffix_nm
                       );

  hr_utility.set_location(l_proc, 120);

  IF p_frm_ae_employer_contribution = 'Y' THEN
  --
    hr_utility.set_location(l_proc, 130);

    l_employer_contribution_type := p_frm_ae_type;
  --
  END IF;

  hr_utility.set_location(l_proc, 140);

  pay_element_extra_info_api.create_element_extra_info
    (p_element_type_id            => l_el_stkcore_id
    ,p_information_type           => 'PQP_GB_STAKEHOLDER_INFORMATION'
    ,p_eei_information_category   => 'PQP_GB_STAKEHOLDER_INFORMATION'
    ,p_eei_information1           => p_frm_sd_scheme_name
    ,p_eei_information2           => p_frm_sd_contribution_method
    ,p_eei_information3           => p_frm_ae_rate
    ,p_eei_information4           => l_employer_contribution_type
    ,p_eei_information5           => p_frm_sd_employee_contribution
    ,p_element_type_extra_info_id => l_ee_stkhldr_id
    ,p_object_version_number      => l_xx_stkhldr_ovn);

  hr_utility.set_location('Leaving : '||l_proc, 150);

  RETURN l_el_stkcore_id;

END create_user_template;

--==========================================================================
--                             Deletion procedure
--==========================================================================
--
PROCEDURE delete_user_template
            (p_frm_ctl_business_group_id     IN     NUMBER
            ,p_frm_ctl_element_type_id       IN     NUMBER
            ,p_frm_be_element_name           IN     VARCHAR2
            ,p_frm_ctl_effective_start_date  IN     DATE
            )
IS
  --
  l_te_ustrctr_id     NUMBER(9);
  l_proc              VARCHAR2(61):=g_proc||'delete_user_template';
  l_ee_stkhldr_id     NUMBER;
  l_ee_stkhldr_ovn    NUMBER;
  --
  CURSOR csr_ee_stkhldr is
  SELECT element_type_extra_info_id
  FROM   pay_element_type_extra_info petei
  WHERE  element_type_id = p_frm_ctl_element_type_id ;


  CURSOR csr_te_stkhldr IS
  SELECT template_id
  FROM   pay_element_templates
  WHERE  base_name = p_frm_be_element_name
    AND  business_group_id = p_frm_ctl_business_group_id
    AND  template_type = 'U';
--
BEGIN
  --
  hr_utility.set_location('Entering :'||l_proc, 10);
  --

  OPEN csr_ee_stkhldr;
  LOOP
    FETCH csr_ee_stkhldr INTO l_ee_stkhldr_id  ;
    EXIT WHEN csr_ee_stkhldr%NOTFOUND;

    pay_element_extra_info_api.delete_element_extra_info
      (p_validate                    => FALSE
      ,p_element_type_extra_info_id  => l_ee_stkhldr_id
      ,p_object_version_number       => l_ee_stkhldr_ovn
      );

  END LOOP;
  CLOSE csr_ee_stkhldr;

  hr_utility.set_location(l_proc, 20);

  FOR csr_te_stkhldr_rec IN csr_te_stkhldr LOOP
    l_te_ustrctr_id := csr_te_stkhldr_rec.template_id;
  END LOOP;

  hr_utility.set_location(l_proc, 30);

  pay_element_template_api.delete_user_structure
    (p_validate                =>   FALSE
    ,p_drop_formula_packages   =>   TRUE
    ,p_template_id             =>   l_te_ustrctr_id
    );

  hr_utility.set_location('Leaving :'||l_proc, 40);

END delete_user_template;
--
END pqp_gb_stakeholder_template;

/
