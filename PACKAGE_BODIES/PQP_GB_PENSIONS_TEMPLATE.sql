--------------------------------------------------------
--  DDL for Package Body PQP_GB_PENSIONS_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PENSIONS_TEMPLATE" AS
/* $Header: pqgbpatp.pkb 120.1 2005/05/30 00:12:07 rvishwan noship $ */

/*========================================================================
 *                        CREATE_USER_TEMPLATE
 *=======================================================================*/
FUNCTION create_user_template
           (p_ele_name              in varchar2
           ,p_ele_reporting_name    in varchar2
           ,p_ele_description       in varchar2     default NULL
           ,p_ele_classification    in varchar2
           ,p_sch_type              in varchar2
           ,p_emp_cont_method       in varchar2
           ,p_emp_contribution      in number       default NULL
           ,p_adl_contribution      in varchar2
           ,p_eer_contribution      in varchar2
           ,p_eer_type              in varchar2
           ,p_eer_rate              in number       default NULL
           ,p_ept_contribution      in varchar2
           ,p_byb_added_years       in varchar2
           ,p_fmwd_benefit          in varchar2
           ,p_avc_percentage        in varchar2
           ,p_avc_per_provider      in varchar2
           ,p_avc_fixed_rate        in varchar2
           ,p_avc_fxdrt_provider    in varchar2
           ,p_life_assurance        in varchar2
           ,p_life_asr_provider     in varchar2
           ,p_ele_eff_start_date    in date         default NULL
           ,p_ele_eff_end_date      in date         default NULL
           ,p_bg_id                 in number
           )
   RETURN NUMBER IS
   --


   /*--------------------------------------------------------------------
    The input values are explained below : V-varchar2, D-Date, N-number
      Input-Name            Type   Valid Values/Explaination
      ----------            ----   --------------------------------------
      p_ele_name             (V) - User i/p Element name
      p_ele_reporting_name   (V) - User i/p reporting name
      p_ele_description      (V) - User i/p Description
      p_ele_classification   (V) - 'Pre-Tax Deductions'
      p_sch_type             (V) - User i/p
      p_emp_cont_method      (V) - 'P'/'F'
      p_emp_contribution     (N) - User i/p
      p_adl_contribution     (V) - 'Y'/'N'
      p_eer_contribution     (V) - 'Y'/'N'
      p_eer_type             (V) - 'P'/'F'
      p_eer_rate             (N) - User i/p
      p_ept_contribution     (V) - 'Y'/'N'
      p_byb_added_years      (V) - 'Y'/'N'
      p_fmwd_benefit         (V) - 'Y'/'N'
      p_avc_percentage       (V) - 'Y'/'N'
      p_avc_per_provider     (V) - User i/p
      p_avc_fixed_rate       (V) - 'Y'/'N'
      p_avc_fxdrt_provider   (V) - User i/p
      p_life_assurance       (V) - 'Y'/'N'
      p_life_asr_provider    (V) - User i/p
      p_ele_eff_start_date   (D) - Trunc(start date)
      p_ele_eff_end_date     (D) - Trunc(end date)
      p_bg_id                (N) - Business group id
   ----------------------------------------------------------------------*/
   --
   l_template_id                 pay_shadow_element_types.template_id%TYPE;
   l_base_element_type_id        pay_template_core_objects.core_object_id%TYPE;
   l_source_template_id          pay_element_templates.template_id%TYPE;
   l_object_version_number       NUMBER(9);
   l_proc                        VARCHAR2(80) :=
                          'pqp_gb_pensions_template.create_user_template';
   l_flat_rate                   VARCHAR2(3);
   l_per_contribution            VARCHAR2(3);
   l_adl_contribution            VARCHAR2(3);
   l_eer_contribution            VARCHAR2(3);
   l_eer_per_type                VARCHAR2(3);
   l_eer_fac_type                VARCHAR2(3);
   l_ept_contribution            VARCHAR2(3);
   l_byb_added_years             VARCHAR2(3);
   l_fmwd_benefit                VARCHAR2(3);
   l_avc_percentage              VARCHAR2(3);
   l_avc_fixed_rate              VARCHAR2(3);
   l_life_assurance              VARCHAR2(3);
   l_stk_hld_pension             VARCHAR2(3);
   l_eei_info_id                 NUMBER;
   l_ovn_eei                     NUMBER;
   l_element_type_id             NUMBER;
   l_avcren                      VARCHAR2(80);
   l_ele_obj_ver_number          NUMBER; --
   l_ele_name                    pay_element_types_f.element_name%TYPE;
   l_name                        pay_input_values_f.name%TYPE;
   i                             NUMBER;

   -- Extra Information variables
   l_eei_information2            pay_element_type_extra_info.eei_information2%TYPE;
   l_eei_information3            pay_element_type_extra_info.eei_information3%TYPE;
   l_eei_information4            pay_element_type_extra_info.eei_information4%TYPE;
   l_eei_information5            pay_element_type_extra_info.eei_information5%TYPE;
   l_eei_information6            pay_element_type_extra_info.eei_information6%TYPE;
   l_eei_information7            pay_element_type_extra_info.eei_information7%TYPE;
   l_eei_information8            pay_element_type_extra_info.eei_information8%TYPE;
   l_eei_information9            pay_element_type_extra_info.eei_information9%TYPE;
   l_eei_information10           pay_element_type_extra_info.eei_information10%TYPE;
   l_eei_information11           pay_element_type_extra_info.eei_information11%TYPE;
   l_eei_information12           pay_element_type_extra_info.eei_information12%TYPE;
   --
   TYPE t_avc_prov IS TABLE OF VARCHAR2(80)
   INDEX BY BINARY_INTEGER;

    l_avc                        t_avc_prov;

   TYPE t_avc_temp IS TABLE OF VARCHAR2(80)
   INDEX BY BINARY_INTEGER;

    l_avctemp                    t_avc_temp;

   TYPE t_sub_ele IS TABLE OF VARCHAR2(80)
   INDEX BY BINARY_INTEGER;

    l_sub                        t_sub_ele;

   CURSOR c1 (c_ele_name varchar2) is
   SELECT element_type_id, object_version_number
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
   --
   --======================================================================
   --                     FUNCTION GET_TEMPLATE_ID
   --======================================================================
   FUNCTION get_template_id (p_legislation_code    in varchar2 )
   RETURN number IS
     --
  --   l_template_id   NUMBER(9);
     l_template_name VARCHAR2(80);
     l_proc  varchar2(60)       := 'pqp_gb_pensions_template.get_template_id';
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
      l_template_name  := 'PQP PENSION AND AVCS';
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

  -----------------------------------------------------------------------------
    ---  Procedure Update Element Type formula
  -----------------------------------------------------------------------------
   PROCEDURE update_eletyp_for(l_ele_name     IN VARCHAR2
                              ,l_formula_name IN VARCHAR2)
   IS

     CURSOR c1_getfor(lc_formula_name varchar2) IS
               SELECT formula_id
                 FROM ff_formulas_f
               WHERE formula_name      = lc_formula_name
                 AND (business_group_id = p_bg_id OR business_group_id IS NULL)
                 AND (legislation_code  = 'GB' OR legislation_code IS NULL);

     CURSOR c2_getele(lc_ele_name varchar2) IS
               SELECT element_type_id
                 FROM pay_element_types_f
               WHERE element_name      = lc_ele_name
                 AND (business_group_id = p_bg_id OR business_group_id IS NULL)
                 AND (legislation_code  = 'GB' OR legislation_code IS NULL);

     CURSOR c3_updele(lc_ele_type_id number) IS
               SELECT rowid
                 FROM pay_element_types_f
               WHERE element_type_id = lc_ele_type_id
               FOR UPDATE NOWAIT;

     c1_rec                          c1_getfor%ROWTYPE;
     c2_rec                          c2_getele%ROWTYPE;
     c3_rec                          c3_updele%ROWTYPE;

  BEGIN

     OPEN c1_getfor(l_formula_name);
      LOOP

        FETCH c1_getfor INTO c1_rec;
        EXIT WHEN c1_getfor%NOTFOUND;

          OPEN c2_getele(l_ele_name);
           LOOP

             FETCH c2_getele INTO c2_rec;
             EXIT WHEN c2_getele%NOTFOUND;

               OPEN c3_updele(c2_rec.element_type_id);
                LOOP

                  FETCH c3_updele INTO c3_rec;
                  EXIT WHEN c3_updele%NOTFOUND;

                    UPDATE pay_element_types_f
                      SET formula_id = c1_rec.formula_id
                    WHERE rowid = c3_rec.rowid;

                 END LOOP;
                CLOSE c3_updele;

            END LOOP;
           CLOSE c2_getele;

      END LOOP;
     CLOSE c1_getfor;

  END update_eletyp_for;

  -----------------------------------------------------------------------------
    ---  Procedure Update Input Value default value
  -----------------------------------------------------------------------------
   PROCEDURE update_ipval_defval(l_ele_name IN VARCHAR2
                                ,l_name     IN VARCHAR2
                                ,l_value    IN NUMBER)
   IS

     CURSOR c1_getinput(lc_ele_name Varchar2,lc_name varchar2) IS
               SELECT input_value_id,
                      piv.name,
                      piv.element_type_id
                 FROM pay_input_values_f piv,
                      pay_element_types_f pet
                 WHERE element_name= lc_ele_name
                   AND piv.element_type_id=pet.element_type_id
                   AND  (piv.business_group_id =p_bg_id OR piv.business_group_id IS NULL)
                   AND piv.name =lc_name
                   AND  (piv.legislation_code='GB' OR piv.legislation_code IS NULL);

     CURSOR c2_updinput(lc_ip_id           number
                       ,lc_element_type_id number) IS
            SELECT rowid
              FROM pay_input_values_f
            WHERE  input_value_id  = lc_ip_id
              AND  element_type_id = lc_element_type_id
            FOR UPDATE NOWAIT;

     c1_rec                       c1_getinput%rowtype;
     c2_rec                       c2_updinput%rowtype;

   BEGIN

     OPEN c1_getinput(l_ele_name
                     ,l_name);
     LOOP

       FETCH c1_getinput INTO c1_rec;
       EXIT WHEN c1_getinput%NOTFOUND;

        OPEN c2_updinput(c1_rec.input_value_id
                        ,c1_rec.element_type_id);
        LOOP

          FETCH c2_updinput INTO c2_rec;
          EXIT WHEN c2_updinput%NOTFOUND;

            UPDATE pay_input_values_f
              SET default_value = l_value
            WHERE rowid = c2_rec.rowid;

        END LOOP;
        CLOSE c2_updinput;

     END LOOP;
     CLOSE c1_getinput;

   END update_ipval_defval;

   --
   --=======================================================================
   --                FUNCTION GET_OBJECT_ID
   --=======================================================================
   FUNCTION get_object_id (p_object_type    in varchar2,
                           p_object_name   in varchar2)
   RETURN NUMBER is
     --
     l_object_id  NUMBER      := NULL;
     l_proc   varchar2(60)    := 'pqp_gb_pensions_template.get_object_id';
     --
     CURSOR c2 (c_object_name varchar2) is
           SELECT element_type_id
             FROM   pay_element_types_f
            WHERE  element_name      = c_object_name
              AND  business_group_id = p_bg_id;
     --
     CURSOR c3 (c_object_name in varchar2) is
          SELECT ptco.core_object_id
            FROM   pay_shadow_balance_types psbt,
                   pay_template_core_objects ptco
           WHERE  psbt.template_id      = l_template_id
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
   ---------------------------
   -- Get Source Template ID
   ---------------------------
   l_source_template_id := get_template_id
                             (p_legislation_code  => 'GB'
                             );
   hr_utility.set_location(l_proc, 30);
   --
   /*--------------------------------------------------------------------------
      Create the user Structure
      The Configuration Flex segments for the Exclusion Rules are as follows:
    ---------------------------------------------------------------------------
    Config1  --
    Config2  --
   ---------------------------------------------------------------------------*/

   l_flat_rate        := 'N';
   l_per_contribution := 'N';
   l_adl_contribution := 'N';
   l_eer_contribution := 'N';
   l_eer_per_type     := 'N';
   l_eer_fac_type     := 'N';
   l_ept_contribution := 'N';
   l_byb_added_years  := 'N';
   l_fmwd_benefit     := 'N';
   l_avc_percentage   := 'N';
   l_avc_fixed_rate   := 'N';
   l_life_assurance   := 'N';
   l_stk_hld_pension  := 'N';
   i                  := 0;

   -- Intialize all Extra Infornation type variables
   l_eei_information2  := NULL;
   l_eei_information3  := 'N';
   l_eei_information4  := 'N';
   l_eei_information5  := NULL;
   l_eei_information6  := NULL;
   l_eei_information7  := 'N';
   l_eei_information8  := 'N';
   l_eei_information9  := NULL;
   l_eei_information10 := NULL;
   l_eei_information11 := NULL;
   l_eei_information12 := NULL;

   IF p_emp_cont_method = 'F' THEN
         l_flat_rate        := NULL;
         l_eei_information2 := 'F';
   ELSIF p_emp_cont_method = 'P' THEN
         l_per_contribution := NULL;
         l_eei_information2 := 'P';
   END IF; -- End if of contribution type check...

   IF p_eer_contribution = 'Y' THEN
         l_eer_contribution := NULL;
         i                  := i + 1;
         l_sub(i)           := ' Employer Contribution';

         IF p_eer_type = 'P' THEN
            l_eer_per_type     := NULL;
            l_eei_information6 := 'P';
         ELSIF p_eer_type = 'F' THEN
            l_eer_fac_type     := NULL;
            l_eei_information6 := 'F';
         END IF; -- End if of employer contribution type check...

   END IF; -- End if of employer contribution check...

   IF p_adl_contribution = 'Y' THEN
         l_adl_contribution := NULL;
         i                  := i + 1;
         l_sub(i)           := ' Additional Contribution';
         i                  := i + 1;
         l_sub(i)           := ' Exceptional Adjustment';
         l_eei_information3 := 'Y';
   END IF; -- End if of adl contribution check...

   IF p_ept_contribution = 'Y' THEN
         l_ept_contribution := NULL;
         i                  := i + 1;
         l_sub(i)           := ' Exceptional Contribution';
         l_eei_information4 := 'Y';
   END IF; -- End if of ept contribution check...

   IF p_byb_added_years = 'Y' THEN
         l_byb_added_years  := NULL;
         i                  := i + 1;
         l_sub(i)           := ' BuyBack Added Yrs';
         l_eei_information7 := 'Y';
   END IF; -- End if of byb addyrs check...

   IF p_fmwd_benefit = 'Y' THEN
         l_fmwd_benefit     := NULL;
         i                  := i + 1;
         l_sub(i)           := ' Family Widower';
         l_eei_information8 := 'Y';
   END IF; -- End if of fmwd benefit check...

   IF p_avc_percentage = 'Y' THEN
         l_avc_percentage := NULL;
         i                  := i + 1;
         l_sub(i)           := ' AVC Percentage ';
         l_eei_information9 := p_avc_per_provider;
   END IF; -- End if of avc percentage check...

   IF p_avc_fixed_rate = 'Y' THEN
         l_avc_fixed_rate    := NULL;
         i                   := i + 1;
         l_sub(i)            := ' AVC Fixed Rate ';
         l_eei_information10 := p_avc_fxdrt_provider;
   END IF; -- End if of avc fixed rate check...

   IF p_life_assurance = 'Y' THEN
         l_life_assurance    := NULL;
         i                   := i + 1;
         l_sub(i)            := ' Life Assurance ';
         l_eei_information11 := p_life_asr_provider;
   END IF; -- End if of life assurance check...

   --
   -- create user structure from the template
   --
   pay_element_template_api.create_user_structure
    (p_validate                      =>     false
    ,p_effective_date                =>     p_ele_eff_start_date
    ,p_business_group_id             =>     p_bg_id
    ,p_source_template_id            =>     l_source_template_id
    ,p_base_name                     =>     p_ele_name
    ,p_configuration_information1    =>     l_flat_rate
    ,p_configuration_information2    =>     l_per_contribution
    ,p_configuration_information3    =>     l_eer_per_type
    ,p_configuration_information4    =>     l_eer_fac_type
    ,p_configuration_information5    =>     l_eer_contribution
    ,p_configuration_information6    =>     l_adl_contribution
    ,p_configuration_information7    =>     l_ept_contribution
    ,p_configuration_information8    =>     l_byb_added_years
    ,p_configuration_information9    =>     l_fmwd_benefit
    ,p_configuration_information10   =>     l_avc_percentage
    ,p_configuration_information11   =>     l_avc_fixed_rate
    ,p_configuration_information12   =>     l_life_assurance
    ,p_template_id                   =>     l_template_id
    ,p_object_version_number         =>     l_object_version_number
    );
   --

   hr_utility.set_location(l_proc, 80);
   ---------------------------------------------------------------------------
   ---------------------------- Update Shadow Structure ----------------------
   --

   OPEN c1(p_ele_name);
   LOOP
     FETCH c1 INTO l_element_type_id,l_ele_obj_ver_number;
     EXIT WHEN c1%NOTFOUND;

     pay_shadow_element_api.update_shadow_element
       (p_validate                     => false
        ,p_effective_date              => p_ele_eff_start_date
        ,p_element_type_id             => l_element_type_id
        ,p_element_name                => p_ele_name
        ,p_reporting_name              => p_ele_reporting_name
        ,P_DESCRIPTION                 => p_ele_description
        ,p_object_version_number       => l_ele_obj_ver_number
       );

   END LOOP;
   CLOSE c1;


   FOR i in 1..l_sub.count
   LOOP

     OPEN c1(p_ele_name||l_sub(i));
     LOOP
     FETCH c1 INTO l_element_type_id,l_ele_obj_ver_number;
     EXIT WHEN c1%NOTFOUND;

     pay_shadow_element_api.update_shadow_element
       (p_validate                     => false
        ,p_effective_date              => p_ele_eff_start_date
        ,p_element_type_id             => l_element_type_id
        ,p_element_name                => p_ele_name || l_sub(i)
        ,P_DESCRIPTION                 => p_ele_description
        ,p_object_version_number       => l_ele_obj_ver_number
       );

     END LOOP;
     CLOSE c1;

   END LOOP;



   i := 0;
   IF p_avc_percentage = 'Y' THEN
        i            := i + 1;
        l_avc(i)     := ' AVC Percentage ';
        l_avctemp(i) := l_avc(i) || substr(p_avc_per_provider,1,5);
   END IF; -- End if of avc percentage check...

   IF p_avc_fixed_rate = 'Y' THEN
        i            := i + 1;
        l_avc(i)     := ' AVC Fixed Rate ';
        l_avctemp(i) := l_avc(i) || substr(p_avc_fxdrt_provider,1,5);
   END IF; -- End if of avc fixed rate check...

   IF p_life_assurance = 'Y' THEN
        i            := i + 1 ;
        l_avc(i)     := ' Life Assurance ';
        l_avctemp(i) := l_avc(i) || substr(p_life_asr_provider,1,5);
   END IF; -- End if of life assurance check...

   FOR i in 1..l_avc.count
   LOOP
       OPEN c1(p_ele_name||l_avc(i));
       LOOP

        FETCH c1 INTO l_element_type_id,l_ele_obj_ver_number;
        EXIT WHEN c1%NOTFOUND;

        l_avcren := p_ele_name || l_avctemp(i);

        pay_shadow_element_api.update_shadow_element
          (p_validate                      => false
           ,p_effective_date               => p_ele_eff_start_date
           ,p_element_type_id              => l_element_type_id
           ,p_element_name                 => l_avcren
           ,p_object_version_number        => l_ele_obj_ver_number
          );

       END LOOP;
     CLOSE c1;
   END LOOP;



   -------------------------------------------------------------------------
   --
   --
   hr_utility.set_location(l_proc, 110);
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
   hr_utility.set_location(l_proc, 120);
   --
   pay_element_template_api.generate_part2
    (p_validate                      =>     false
    ,p_effective_date                =>     p_ele_eff_start_date
    ,p_template_id                   =>     l_template_id);
   --

   hr_utility.set_location(l_proc, 130);

   --
   -- Update base element formula if contribution type is flat rate
   --

   IF p_emp_cont_method = 'F' THEN
      update_eletyp_for(p_ele_name
                       ,'ONCE_EACH_PERIOD');
   END IF; -- End if of contribution method check...

   hr_utility.set_location(l_proc, 140);

   --
   -- Update Input Values Default Values
   --

   IF p_emp_contribution IS NOT NULL THEN

      l_name := NULL;
      IF p_emp_cont_method = 'F' THEN
         l_name      := 'Flat Rate Contribution';
      ELSIF p_emp_cont_method = 'P' THEN
         l_name      := 'Percentage Contribution';
      END IF; -- End if of contribution method check...

      l_eei_information12 := TO_CHAR(p_emp_contribution);
      update_ipval_defval(p_ele_name
                         ,l_name
                         ,p_emp_contribution);
   END IF; -- End if of emp_contribution value check...

   hr_utility.set_location(l_proc, 150);

   IF p_eer_contribution = 'Y' AND
      p_eer_rate IS NOT NULL   THEN

      l_name := NULL;
      IF p_eer_type = 'P' THEN
         l_name := 'Employers Percentage Cont';
      ELSIF p_eer_type = 'F' THEN
         l_name := 'Employers Factor Cont';
      END IF; -- End if of employer contribution type check...

      l_eei_information5 := TO_CHAR(p_eer_rate);
      update_ipval_defval(p_ele_name
                         ,l_name
                         ,p_eer_rate);
   END IF; -- End if of employer contribution check...

   hr_utility.set_location(l_proc, 160);

   l_base_element_type_id := get_object_id ('ELE', p_ele_name);

   hr_utility.set_location(l_proc, 170);

-- Create a row in pay_element_extra_info with all the element information

    pay_element_extra_info_api.create_element_extra_info
                              (p_element_type_id            => l_base_element_type_id
                              ,p_information_type           => 'PQP_GB_PENSION_INFORMATION'
                              ,P_EEI_INFORMATION_CATEGORY   => 'PQP_GB_PENSION_INFORMATION'
                              ,p_eei_information1           => p_sch_type
                              ,p_eei_information2           => l_eei_information2
                              ,p_eei_information3           => l_eei_information3
                              ,p_eei_information4           => l_eei_information4
                              ,p_eei_information5           => l_eei_information5
                              ,p_eei_information6           => l_eei_information6
                              ,p_eei_information7           => l_eei_information7
                              ,p_eei_information8           => l_eei_information8
                              ,p_eei_information9           => l_eei_information9
                              ,p_eei_information10          => l_eei_information10
                              ,p_eei_information11          => l_eei_information11
                              ,p_eei_information12          => l_eei_information12
                              ,p_element_type_extra_info_id => l_eei_info_id
                              ,p_object_version_number      => l_ovn_eei);

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
           (p_business_group_id     in number
           ,p_ele_type_id           in number
           ,p_ele_name              in varchar2
           ,p_effective_date        in date
           ) IS
  --
  l_template_id   NUMBER(9);
  l_proc   varchar2(60)      :='pqp_gb_pensions_template.delete_user_template';
  l_eei_info_id  number;
  l_ovn_eei   number;
  --
  CURSOR eei is
  SELECT element_type_extra_info_id
   FROM pay_element_type_extra_info petei
   WHERE element_type_id=p_ele_type_id ;


 CURSOR c1 is
  SELECT template_id
  FROM   pay_element_templates
  WHERE  base_name         = p_ele_name
    AND  business_group_id = p_business_group_id
    AND  template_type     = 'U';
--
BEGIN
   --
   hr_utility.set_location('Entering :'||l_proc, 10);
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

   FOR c1_rec in c1 loop
       l_template_id := c1_rec.template_id;
   END LOOP;
   --

   pay_element_template_api.delete_user_structure
     (p_validate                =>   false
     ,p_drop_formula_packages   =>   true
     ,p_template_id             =>   l_template_id);
   --

   hr_utility.set_location('Leaving :'||l_proc, 50);
   --
END delete_user_template;
--
END pqp_gb_pensions_template;


/
