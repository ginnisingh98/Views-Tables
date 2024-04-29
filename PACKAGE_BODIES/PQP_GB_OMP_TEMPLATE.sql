--------------------------------------------------------
--  DDL for Package Body PQP_GB_OMP_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_OMP_TEMPLATE" AS
/* $Header: pqpgbomd.pkb 120.0 2005/05/29 01:59:53 appldev noship $ */

  g_proc_name         varchar2(80) := 'pqp_gb_omp_template.';

/*========================================================================
 *                        CREATE_USER_TEMPLATE
 *=======================================================================*/
FUNCTION create_user_template
           (p_plan_id                       IN NUMBER
           ,p_plan_description              IN VARCHAR2
           ,p_abse_days_def                 IN VARCHAR2
           ,p_maternity_abse_ent_udt        IN NUMBER
           ,p_holidays_udt                  IN NUMBER
           ,p_daily_rate_calc_method        IN VARCHAR2
           ,p_daily_rate_calc_period        IN VARCHAR2
           ,p_daily_rate_calc_divisor       IN NUMBER
           ,p_working_pattern               IN VARCHAR2
           ,p_los_calc                      IN VARCHAR2
           ,p_los_calc_uom                  IN VARCHAR2
           ,p_los_calc_duration             IN VARCHAR2
           ,p_avg_earnings_duration         IN VARCHAR2
           ,p_avg_earnings_uom              IN VARCHAR2
           ,p_avg_earnings_balance          IN VARCHAR2
           ,p_pri_ele_name                  IN VARCHAR2
	   ,p_pri_ele_reporting_name        IN VARCHAR2
           ,p_pri_ele_description           IN VARCHAR2
           ,p_pri_ele_processing_priority   IN NUMBER
           ,p_abse_primary_yn                IN VARCHAR2
           ,p_pay_ele_reporting_name        IN VARCHAR2
           ,p_pay_ele_description           IN VARCHAR2
           ,p_pay_ele_processing_priority   IN NUMBER
           ,p_pay_src_pay_component         IN VARCHAR2
           ,p_band1_ele_base_name           IN VARCHAR2
           ,p_band2_ele_base_name           IN VARCHAR2
           ,p_band3_ele_base_name           IN VARCHAR2
           ,p_band4_ele_base_name           IN VARCHAR2
           ,p_effective_start_date          IN DATE
           ,p_effective_end_date            IN DATE
           ,p_abse_type_lookup_type         IN VARCHAR2
           ,p_abse_type_lookup_value        IN PQP_GB_OSP_TEMPLATE.T_ABS_TYPES
           ,p_security_group_id             IN NUMBER
           ,p_bg_id                         IN NUMBER
           )
   RETURN NUMBER IS
   --


   /*--------------------------------------------------------------------
    The input values are explained below : V-varchar2, D-Date, N-number
      Input-Name                    Type   Valid Values/Explaination
      ----------                    ----
      --------------------------------------
      p_plan_id                      (N) - LOV based i/p
      p_plan_description             (V) - User i/p Description
      p_abse_days_def                (V) - Absence day definition
                                           ( Working / Calendar )
      p_cal_abse_uom                 (V) - Days/Weeks/Months
      p_maternity_abse_ent_udt       (V) - UDT id for Maternity Entitlements
      p_holidays_udt                 (V) - UDT id for Holidays
      p_abs_daily_rate_calc_method   (V) - Radio Button based i/p
      (Working/Calendar)
      p_abs_daily_rate_calc_period   (V) - LOV based i/p(ANNUAL/PAYPERIOD/CYEAR)
      p_abs_daily_rate_calc_divisor  (N) - 365/User Provided Default 365
      p_abs_working_pattern          (V) - User i/p Working Pattern Name
      p_pri_ele_name                 (V) - User i/p Element Name
      p_pri_ele_reporting_name       (V) - User i/p Reporting Name
      p_pri_ele_description          (V) - User i/p Description
      p_pri_ele_processing_priority  (N) - User provided
      p_primary_yn                   (V) - 'Y'/'N'
      p_pay_ele_reporting_name       (V) - User i/p Reporting Name
      p_pay_ele_description          (V) - User i/p Description
      p_pay_ele_processing_priority  (N) - User provided
      p_pay_src_pay_component        (V) - LOV based i/p
      p_band1_ele_base_name          (V) - User i/p Band1 Base Name
      p_band2_ele_base_name          (V) - User i/p Band2 Base Name
      p_band3_ele_base_sub_name      (V) - User i/p Band3 Base Name
      p_band4_ele_base_sub_name      (V) - User i/p Band4 Base Name
      p_effective_start_date         (D) - User i/p Effective Start Date
      p_effective_end_date           (D) - User i/p Effective End Date
      p_abse_type_lookup_type         (V) - Absence Type Lookup Name
      p_abse_type_lookup_value        (C) - Collection of Absence Types
      p_bg_id                        (N) - Business Group id
   ----------------------------------------------------------------------*/
   --
   l_template_id                 pay_shadow_element_types.template_id%TYPE;
   l_base_element_type_id        pay_template_core_objects.core_object_id%TYPE;
   l_source_template_id          pay_element_templates.template_id%TYPE;
   l_object_version_number       pay_element_types_f.object_version_number%TYPE;
   l_proc_name                   VARCHAR2(80) :=
                         g_proc_name || 'create_user_template';

   l_template_name               pay_element_templates.template_name%TYPE ;
   l_days_hours                  VARCHAR2(10) ;

   l_element_type_id             NUMBER;
   l_balance_type_id             NUMBER;
   l_eei_element_type_id         NUMBER;
   l_ele_obj_ver_number          NUMBER;
   l_bal_obj_ver_number          NUMBER;
   i                             NUMBER;
   l_eei_info_id                 NUMBER;
   l_ovn_eei                     NUMBER;
   l_abs_ele_correction_pp       NUMBER := p_pri_ele_processing_priority - 50;
   l_pay_ele_correction_pp       NUMBER := p_pay_ele_processing_priority - 50;
   l_formula_name                pay_shadow_formulas.formula_name%TYPE;
   l_formula_id                  NUMBER;
   l_lookup_type                 fnd_lookup_types_vl.lookup_type%TYPE;
   l_lookup_meaning              fnd_lookup_types_vl.meaning%TYPE;
   l_abse_days_def               VARCHAR2(1);
   y                             NUMBER := 0;
   l_exists                      VARCHAR2(1);

   l_exc_sec_days_bf             VARCHAR2(1);
   l_base_name                   pay_element_templates.base_name%TYPE
                              := UPPER(TRANSLATE(TRIM(p_pri_ele_name),' ','_'));

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


   TYPE t_ele_reporting_name IS TABLE OF pay_element_types_f.reporting_name%TYPE
   INDEX BY BINARY_INTEGER;

   l_ele_reporting_name          t_ele_reporting_name;

   TYPE t_ele_description IS TABLE OF pay_element_types_f.description%TYPE
   INDEX BY BINARY_INTEGER;

   l_ele_description             t_ele_description;

   TYPE t_ele_pp IS TABLE OF pay_element_types_f.processing_priority%TYPE
   INDEX BY BINARY_INTEGER;

   l_ele_pp                      t_ele_pp;

   TYPE t_eei_info IS TABLE OF pay_element_type_extra_info.eei_information19%
   TYPE
   INDEX BY BINARY_INTEGER;

   l_main_eei_info19             t_eei_info;
   l_retro_eei_info19            t_eei_info;

   TYPE r_udt_type IS RECORD
     (user_table_name   VARCHAR2(80)
     ,range_or_match    VARCHAR2(30)
     ,user_key_units    VARCHAR2(30)
     ,user_row_title    VARCHAR2(80)
     );

   l_udt_type                    r_udt_type;

   TYPE r_udt_cols_type IS RECORD
     (user_column_name   pay_user_columns.user_column_name%TYPE
     ,formula_id         pay_user_columns.formula_id%TYPE
     ,business_group_id  pay_user_columns.business_group_id%TYPE
     ,legislation_code   pay_user_columns.legislation_code%TYPE
     );

   TYPE t_udt_cols IS TABLE OF r_udt_cols_type
   INDEX BY BINARY_INTEGER;

   l_udt_cols                    t_udt_cols;

   TYPE r_udt_rows_type IS RECORD
     (row_low_range_or_name pay_user_rows_f.row_low_range_or_name%TYPE
     ,display_sequence      pay_user_rows_f.display_sequence%TYPE
     ,row_high_range        pay_user_rows_f.row_high_range%TYPE
     ,business_group_id     pay_user_rows.business_group_id%TYPE
     ,legislation_code      pay_user_rows.legislation_code%TYPE
     );

   TYPE t_udt_rows IS TABLE OF r_udt_rows_type
   INDEX BY BINARY_INTEGER;

   l_udt_rows    t_udt_rows;
   l_ele_core_id pay_template_core_objects.core_object_id%TYPE:= -1;

   -- Extra Information variables
   l_eei_information11 pay_element_type_extra_info.eei_information9%TYPE;
   l_eei_information12 pay_element_type_extra_info.eei_information10%TYPE;
   l_eei_information20 pay_element_type_extra_info.eei_information18%TYPE;
   l_eei_information27 pay_element_type_extra_info.eei_information27%TYPE
                       := 'PQP_GB_OMP_CALENDAR_RULES';
   l_eei_information30 pay_element_type_extra_info.eei_information30%TYPE
                       := 'Maternity' ;

   CURSOR csr_get_ele_info (c_ele_name varchar2) is
   SELECT element_type_id
         ,object_version_number
   FROM   pay_shadow_element_types
   WHERE  template_id    = l_template_id
     AND  element_name   = c_ele_name;

   CURSOR csr_get_bal_info (c_bal_name varchar2) is
   SELECT balance_type_id
         ,object_version_number
     FROM pay_shadow_balance_types
   WHERE  template_id  = l_template_id
     AND  balance_name = c_bal_name;

   CURSOR c_get_band_meaning (c_effective_date DATE) IS
   SELECT meaning
     FROM hr_lookups hrl
    WHERE lookup_type = 'PQP_GAP_ENTITLEMENT_BANDS'
      AND NVL(enabled_flag,'Y') = 'Y'
      AND lookup_code like 'BAND%'
      AND c_effective_date BETWEEN hrl.start_date_active
      AND nvl(hrl.end_date_active,hr_api.g_eot);

   CURSOR csr_chk_primary_exists is
   SELECT 'X'
     FROM pay_element_type_extra_info
   WHERE  eei_information1  =  fnd_number.number_to_canonical(p_plan_id)
     AND  eei_information17 = 'Y'
     AND  information_type  = 'PQP_GB_OMP_ABSENCE_PLAN_INFO'
     AND  rownum = 1;

   --
   --======================================================================
   --                     FUNCTION GET_TEMPLATE_ID
   --======================================================================
   FUNCTION get_template_id ( p_template_name    IN VARCHAR2
                             ,p_legislation_code IN VARCHAR2)
     RETURN NUMBER IS
     --
     --l_template_name VARCHAR2(80);
     l_proc_name     VARCHAR2(72)       := g_proc_name || 'get_template_id';
     --
     CURSOR csr_get_temp_id(
                             p_template_name IN VARCHAR2
                            ,p_leg_code IN VARCHAR2
                            ) IS
     SELECT template_id
       FROM PAY_ELEMENT_TEMPLATES
      WHERE template_name     = p_template_name
        AND legislation_code  = p_leg_code
        AND template_type     = 'T'
        AND business_group_id IS NULL;
     --
   BEGIN
      --
      hr_utility.set_location('Entering: '||l_proc_name, 10);
      --
      -- l_template_name  := 'PQP OMP Template';
      --
      hr_utility.set_location(l_proc_name, 20);
      --
      for csr_get_temp_id_rec in
              csr_get_temp_id( p_template_name => p_template_name
                              ,p_leg_code      => p_legislation_code
			      )  loop
         l_template_id   := csr_get_temp_id_rec.template_id;
      end loop;
      --
      hr_utility.set_location('Leaving: '||l_proc_name, 30);
      --
      RETURN l_template_id;
      --
   END get_template_id;

   --=======================================================================
   --                FUNCTION GET_OBJECT_ID
   --=======================================================================
   FUNCTION get_object_id (p_object_type   IN VARCHAR2,
                           p_object_name   IN VARCHAR2)
   RETURN NUMBER is
     --
     l_object_id  NUMBER          := NULL;
     l_proc_name  varchar2(72)    := g_proc_name || 'get_object_id';
     --
     CURSOR c2 (c_object_name varchar2) is
           SELECT element_type_id
             FROM pay_element_types_f
            WHERE element_name      = c_object_name
              AND business_group_id = p_bg_id;
     --
     CURSOR c3 (c_object_name in varchar2) is
          SELECT ptco.core_object_id
            FROM  pay_shadow_balance_types psbt,
                  pay_template_core_objects ptco
           WHERE  psbt.template_id      = l_template_id
             AND  psbt.balance_name     = c_object_name
             AND  ptco.template_id      = psbt.template_id
             AND  ptco.shadow_object_id = psbt.balance_type_id;
     --
   BEGIN
      hr_utility.set_location('Entering: '||l_proc_name, 10);
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
      hr_utility.set_location('Leaving: '||l_proc_name, 20);
      --
      RETURN l_object_id;
      --
   END get_object_id;
   --

   --
   --========================================================================
   --        PROCEDURE Update Element Type with Retro Ele Info
   --========================================================================
   PROCEDURE update_ele_retro_info (p_main_ele_name  IN VARCHAR2
                                   ,p_retro_ele_name IN VARCHAR2
                                   ) IS
   --

     l_main_ele_type_id   pay_element_types_f.element_type_id%TYPE;
     l_retro_ele_type_id  pay_element_types_f.element_type_id%TYPE;
     l_proc_name          VARCHAR2(72) := g_proc_name ||
                                'update_ele_retro_info';

   --
   BEGIN

     --
     hr_utility.set_location ('Entering '||l_proc_name, 10);
     --

     -- Get element type id for retro element
     l_retro_ele_type_id := get_object_id (p_object_type => 'ELE'
                                          ,p_object_name => p_retro_ele_name
                                          );


     hr_utility.set_location (l_proc_name, 20);
     -- Get element type id for main element
     l_main_ele_type_id := get_object_id (p_object_type => 'ELE'
                                         ,p_object_name => p_main_ele_name
                                         );

     -- Update main element with retro element info

     hr_utility.set_location(l_proc_name, 30);

     UPDATE pay_element_types_f
       SET  retro_summ_ele_id = l_retro_ele_type_id
     WHERE  element_type_id   = l_main_ele_type_id;

     --
     hr_utility.set_location ('Leaving '||l_proc_name, 40);
     --

   END update_ele_retro_info;
   --

  -----------------------------------------------------------------------------
  --  FUNCTION get_formula_id
  -----------------------------------------------------------------------------
   FUNCTION get_formula_id (p_formula_name IN VARCHAR2)
     RETURN NUMBER IS

     CURSOR csr_get_formula_id IS
     SELECT formula_id
       FROM pay_shadow_formulas
      WHERE formula_name  = p_formula_name
        AND template_type = 'T';

     l_proc_name         VARCHAR2(72) := g_proc_name || 'get_formula_id';
     l_formula_id        NUMBER;

  --
  BEGIN
    --
    hr_utility.set_location ('Entering '||l_proc_name, 10);
    --

     OPEN csr_get_formula_id;
    FETCH csr_get_formula_id INTO l_formula_id;
    CLOSE csr_get_formula_id;

    --
    hr_utility.set_location ('Leaving '||l_proc_name, 20);
    --

    RETURN l_formula_id;

   --
  END get_formula_id;
  --

  -----------------------------------------------------------------------------
    ---  PROCEDURE update input value default value
  -----------------------------------------------------------------------------
   PROCEDURE update_ipval_defval(p_ele_name  IN VARCHAR2
                                ,p_ip_name   IN VARCHAR2
                                ,p_def_value IN VARCHAR2)
   IS

     CURSOR csr_getinput(c_ele_name varchar2
                        ,c_iv_name  varchar2) IS
     SELECT input_value_id
           ,piv.name
           ,piv.element_type_id
       FROM pay_input_values_f  piv
           ,pay_element_types_f pet
     WHERE  element_name           = c_ele_name
       AND  piv.element_type_id    = pet.element_type_id
       AND  (piv.business_group_id = p_bg_id OR piv.business_group_id IS NULL)
       AND  piv.name               = c_iv_name
       AND  (piv.legislation_code  = 'GB' OR piv.legislation_code IS NULL);

     CURSOR csr_updinput(c_ip_id           number
                        ,c_element_type_id number) IS
     SELECT rowid
       FROM pay_input_values_f
      WHERE input_value_id  = c_ip_id
        AND element_type_id = c_element_type_id
     FOR UPDATE NOWAIT;

     csr_getinput_rec          csr_getinput%rowtype;
     csr_updinput_rec          csr_updinput%rowtype;

     l_proc_name               VARCHAR2(72) := g_proc_name ||
                                'update_ipval_defval';
   --
   BEGIN
   --

     --
     hr_utility.set_location ('Entering '||l_proc_name, 10);
     --
     OPEN csr_getinput(p_ele_name
                      ,p_ip_name);
     LOOP

       FETCH csr_getinput INTO csr_getinput_rec;
       EXIT WHEN csr_getinput%NOTFOUND;

        --
        hr_utility.set_location (l_proc_name, 20);
        --

        OPEN csr_updinput(csr_getinput_rec.input_value_id
                        ,csr_getinput_rec.element_type_id);
        LOOP

          FETCH csr_updinput INTO csr_updinput_rec;
          EXIT WHEN csr_updinput%NOTFOUND;

            --
            hr_utility.set_location (l_proc_name, 30);
            --

            UPDATE pay_input_values_f
              SET default_value = p_def_value
            WHERE rowid = csr_updinput_rec.rowid;

        END LOOP;
        CLOSE csr_updinput;

     END LOOP;
     CLOSE csr_getinput;

     --
     hr_utility.set_location ('Leaving '||l_proc_name, 40);
     --

   END update_ipval_defval;
   --
   --
   --======================================================================
   -- FUNCTION get_user_table_id
   --======================================================================
   FUNCTION get_user_table_id (p_udt_name in   varchar2)
     RETURN NUMBER IS
   --

     CURSOR csr_get_udt_id IS
     SELECT user_table_id
       FROM pay_user_tables
      WHERE user_table_name = p_udt_name
        AND (business_group_id = p_bg_id OR
             business_group_id IS NULL);

     l_proc_name       VARCHAR2(72) := g_proc_name || 'get_user_table_id';
     l_user_table_id   pay_user_tables.user_table_id%TYPE;

   --
   BEGIN
     --
     hr_utility.set_location('Entering '||l_proc_name, 10);
     --
      OPEN csr_get_udt_id;
     FETCH csr_get_udt_id INTO l_user_table_id;
     CLOSE csr_get_udt_id;

     hr_utility.set_location('Leaving '||l_proc_name, 20);

     RETURN l_user_table_id;

   END get_user_table_id;
   --

   --
   --======================================================================
   --  FUNCTION create_udt
   --======================================================================
   FUNCTION create_udt (p_udt_type r_udt_type
                       ,p_udt_cols t_udt_cols
                       ,p_udt_rows t_udt_rows
                       )
     RETURN NUMBER IS
   --

     CURSOR csr_get_next_udt_row_seq
     IS
     SELECT pay_user_rows_s.NEXTVAL
       FROM dual;

     l_proc_name      VARCHAR2(72) := g_proc_name || 'create_udt';
     l_user_table_id  pay_user_tables.user_table_id%TYPE;
     l_user_column_id pay_user_columns.user_column_id%TYPE;
     l_user_row_id    pay_user_rows_f.user_row_id%TYPE;
     l_udt_rowid      rowid ;
     l_udt_cols_rowid rowid;
     l_udt_rows_rowid rowid;

   --
   BEGIN

     --
     hr_utility.set_location ('Entering '||l_proc_name, 10);
     --

     -- Create the UDT

     hr_utility.set_location (l_proc_name, 20);

     pay_user_tables_pkg.insert_row
        (p_rowid                 => l_udt_rowid
        ,p_user_table_id         => l_user_table_id
        ,p_business_group_id     => p_bg_id
        ,p_legislation_code      => NULL
        ,p_legislation_subgroup  => NULL
        ,p_range_or_match        => p_udt_type.range_or_match
        ,p_user_key_units        => p_udt_type.user_key_units
        ,p_user_table_name       => p_udt_type.user_table_name
        ,p_user_row_title        => p_udt_type.user_row_title
        );

     IF p_udt_cols.count > 0 THEN

        -- Create the columns
        hr_utility.set_location (l_proc_name, 30);

        i := p_udt_cols.FIRST;

        WHILE i IS NOT NULL
        LOOP

                pay_user_columns_pkg.insert_row
                  (p_rowid                => l_udt_cols_rowid
                  ,p_user_column_id       => l_user_column_id
                  ,p_user_table_id        => l_user_table_id
                  ,p_business_group_id    => p_udt_cols(i).business_group_id
                  ,p_legislation_code     => p_udt_cols(i).legislation_code
                  ,p_legislation_subgroup => NULL
                  ,p_user_column_name     => p_udt_cols(i).user_column_name
                  ,p_formula_id           => p_udt_cols(i).formula_id
                  );

                i := p_udt_cols.NEXT(i);
        END LOOP;

     END IF; -- End if of user cols > 1 check ...

     IF p_udt_rows.count > 0 THEN

        hr_utility.set_location (l_proc_name, 40);
        -- Create the rows

        i := p_udt_rows.FIRST;

        WHILE i IS NOT NULL
        LOOP

                OPEN csr_get_next_udt_row_seq;
                FETCH csr_get_next_udt_row_seq INTO l_user_row_id;
                CLOSE csr_get_next_udt_row_seq;

                pay_user_rows_pkg.pre_insert
                 (p_rowid                 => l_udt_rows_rowid
                 ,p_user_table_id         => l_user_table_id
                 ,p_row_low_range_or_name => p_udt_rows(i).row_low_range_or_name
                 ,p_user_row_id           => l_user_row_id
                 ,p_business_group_id     => p_bg_id
                 );

                INSERT INTO pay_user_rows_f
                  (user_row_id
                  ,effective_start_date
                  ,effective_end_date
                  ,business_group_id
                  ,legislation_code
                  ,user_table_id
                  ,row_low_range_or_name
                  ,display_sequence
                  ,legislation_subgroup
                  ,row_high_range
                  )
                VALUES
                  (l_user_row_id
                  ,p_effective_start_date
                  ,nvl(p_effective_end_date, hr_api.g_eot)
                  ,p_udt_rows(i).business_group_id
                  ,p_udt_rows(i).legislation_code
                  ,l_user_table_id
                  ,p_udt_rows(i).row_low_range_or_name
                  ,p_udt_rows(i).display_sequence
                  ,NULL
                  ,p_udt_rows(i).row_high_range
                  );

                i := p_udt_rows.NEXT(i);

        END LOOP; -- End Loop for user rows...
     END IF; -- End if of user rows if present check...

    hr_utility.set_location ('Leaving '||l_proc_name, 50);

    RETURN l_user_table_id;

  --
  END create_udt;
  --

   --
   --======================================================================
   --                     PROCEDURE create_lookup
   --======================================================================
   PROCEDURE create_lookup (p_lookup_type    varchar2
                           ,p_lookup_meaning varchar2
                           ,p_lookup_values  pqp_gb_osp_template.t_abs_types
                           ) IS
   --

     CURSOR csr_chk_uniq_type IS
     SELECT 'x'
       FROM fnd_lookup_types_vl
      WHERE lookup_type         = p_lookup_type
        AND security_group_id   = p_security_group_id
        AND view_application_id = 3;

     CURSOR csr_chk_uniq_meaning
     IS
     SELECT 'x'
       FROM fnd_lookup_types_vl
      WHERE meaning             = p_lookup_meaning
        AND security_group_id   = p_security_group_id
        AND view_application_id = 3;

     l_proc_name      VARCHAR2(72) := g_proc_name || 'create_lookup';
     l_exists         VARCHAR2(1);
     l_rowid          fnd_lookup_types_vl.row_id%type;
     l_user_id        number := fnd_global.user_id;
     l_login_id       number := fnd_global.login_id;

   --
   BEGIN
     --
     hr_utility.set_location('Entering '||l_proc_name, 10);
     --

     -- Check unique lookup type
     OPEN csr_chk_uniq_type;
     FETCH csr_chk_uniq_type INTO l_exists;

     IF csr_chk_uniq_type%FOUND THEN

        -- Raise error
        CLOSE csr_chk_uniq_type;
        hr_utility.set_message(0, 'QC-Duplicate type');
        hr_utility.raise_error;

     END IF; -- End if of unique lookup type check ...
     CLOSE csr_chk_uniq_type;

     hr_utility.set_location(l_proc_name, 20);

     -- Check unique lookup type meaning
     OPEN csr_chk_uniq_meaning;
     FETCH csr_chk_uniq_meaning INTO l_exists;

     IF csr_chk_uniq_meaning%FOUND THEN

        -- Raise error
        CLOSE csr_chk_uniq_meaning;
        hr_utility.set_message(0, 'QC-Duplicate Type Meaning');
        hr_utility.raise_error;

     END IF; -- End if of unique lookup type meaning check ...
     CLOSE csr_chk_uniq_meaning;

     -- Create Lookup type
     hr_utility.set_location(l_proc_name, 30);

     fnd_lookup_types_pkg.insert_row
        (
         x_rowid               => l_rowid
        ,x_lookup_type         => p_lookup_type
        ,x_security_group_id   => p_security_group_id
        ,x_view_application_id => 3
        ,x_application_id      => 800
        ,x_customization_level => 'U'
        ,x_meaning             => p_lookup_meaning
        ,x_description         => NULL
        ,x_creation_date       => SYSDATE
        ,x_created_by          => l_user_id
        ,x_last_update_date    => SYSDATE
        ,x_last_updated_by     => l_user_id
        ,x_last_update_login   => l_login_id
        );

     -- Create Lookup Values
     -- The validation for lookup values should've been taken care in the
     -- form
     hr_utility.set_location(l_proc_name, 40);
     IF p_lookup_values.count > 0 THEN

        i := p_lookup_values.FIRST;
        WHILE i IS NOT NULL
          LOOP
            fnd_lookup_values_pkg.insert_row
              (
               x_rowid               => l_rowid
              ,x_lookup_type         => p_lookup_type
              ,x_security_group_id   => p_security_group_id
              ,x_view_application_id => 3
              ,x_lookup_code         => fnd_number.number_to_canonical(
                                          p_lookup_values(i).abs_type_id)
              ,x_tag                 => NULL
              ,x_attribute_category  => NULL
              ,x_attribute1          => NULL
              ,x_attribute2          => NULL
              ,x_attribute3          => NULL
              ,x_attribute4          => NULL
              ,x_attribute5          => NULL
              ,x_attribute6          => NULL
              ,x_attribute7          => NULL
              ,x_attribute8          => NULL
              ,x_attribute9          => NULL
              ,x_attribute10         => NULL
              ,x_attribute11         => NULL
              ,x_attribute12         => NULL
              ,x_attribute13         => NULL
              ,x_attribute14         => NULL
              ,x_attribute15         => NULL
              ,x_enabled_flag        => 'Y'
              ,x_start_date_active   => p_effective_start_date
              ,x_end_date_active     => NULL
              ,x_territory_code      => NULL
              ,x_meaning             => p_lookup_values(i).abs_type_name
              ,x_description         => NULL
              ,x_creation_date       => SYSDATE
              ,x_created_by          => l_user_id
              ,x_last_update_date    => SYSDATE
              ,x_last_updated_by     => l_user_id
              ,x_last_update_login   => l_login_id
              );

            i := p_lookup_values.NEXT(i);

        END LOOP;

     END IF; -- End if of p_lookup_values check ...

    --
    hr_utility.set_location('Leaving '||l_proc_name, 60);
    --
   END create_lookup;
   --

   --
   /*
   --======================================================================
   --                     PROCEDURE create_gap_lookup
   --======================================================================
   PROCEDURE create_gap_lookup (p_lookup_type    varchar2
                               ,p_lookup_meaning varchar2
                               ,p_lookup_values  t_abs_types
                               ) IS
   --

     CURSOR csr_chk_uniq_type
     IS
     SELECT 'X'
       FROM fnd_lookup_types_vl
     WHERE  lookup_type         = p_lookup_type
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = 3;

     CURSOR csr_chk_uniq_meaning
     IS
     SELECT 'X'
       FROM fnd_lookup_types_vl
     WHERE  meaning             = p_lookup_meaning
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = 3;

     CURSOR csr_chk_uniq_value (c_lookup_code varchar2)
     IS
     SELECT 'X'
       FROM fnd_lookup_values_vl
     WHERE  lookup_type         = p_lookup_type
       AND  lookup_code         = c_lookup_code
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = 3;

     CURSOR csr_chk_uniq_value_meaning (c_lookup_meaning varchar2)
     IS
     SELECT 'X'
       FROM fnd_lookup_values_vl
     WHERE  lookup_type         = p_lookup_type
       AND  meaning             = c_lookup_meaning
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = 3;

     l_proc_name      VARCHAR2(72) := g_proc_name || 'create_gap_lookup';
     l_exists         VARCHAR2(1);
     l_rowid          fnd_lookup_types_vl.row_id%type;
     l_user_id        number := fnd_global.user_id;
     l_login_id       number := fnd_global.login_id;

   --
   BEGIN
     --
     hr_utility.set_location('Entering '||l_proc_name, 10);
     --

     -- Check lookup type exists
     OPEN csr_chk_uniq_type;
     FETCH csr_chk_uniq_type INTO l_exists;

     IF csr_chk_uniq_type%NOTFOUND THEN

	hr_utility.set_location(l_proc_name, 20);

	-- Check unique lookup type meaning
        OPEN csr_chk_uniq_meaning;
        FETCH csr_chk_uniq_meaning INTO l_exists;

        IF csr_chk_uniq_meaning%FOUND THEN

           -- Raise error
           CLOSE csr_chk_uniq_meaning;
           hr_utility.set_message(0, 'QC-DUPLICATE TYPE MEANING');
           hr_utility.raise_error;

        END IF; -- End if of unique lookup type meaning check ...
        CLOSE csr_chk_uniq_meaning;

        -- Create Lookup type
        hr_utility.set_location(l_proc_name, 30);

        fnd_lookup_types_pkg.insert_row
           (
            x_rowid               => l_rowid
           ,x_lookup_type         => p_lookup_type
           ,x_security_group_id   => p_security_group_id
           ,x_view_application_id => 3
           ,x_application_id      => 800
           ,x_customization_level => 'U' --'S'
           ,x_meaning             => p_lookup_meaning
           ,x_description         => NULL
           ,x_creation_date       => SYSDATE
           ,x_created_by          => l_user_id
           ,x_last_update_date    => SYSDATE
           ,x_last_updated_by     => l_user_id
           ,x_last_update_login   => l_login_id
          );

     END IF; -- End if of lookup type exists check ...
     CLOSE csr_chk_uniq_type;

     hr_utility.set_location(l_proc_name, 40);
     IF p_lookup_values.count > 0 THEN

        i := p_lookup_values.FIRST;
        WHILE i IS NOT NULL
          LOOP

            hr_utility.set_location(l_proc_name, 50);
            -- Check whether this lookup code already exists

            OPEN csr_chk_uniq_value (fnd_number.number_to_canonical(
                                          p_lookup_values(i).abs_type_id));
            FETCH csr_chk_uniq_value INTO l_exists;

            IF csr_chk_uniq_value%NOTFOUND THEN

               hr_utility.set_location(l_proc_name, 60);
               -- Check whether the lookup code meaning is unique
               OPEN csr_chk_uniq_value_meaning (p_lookup_values(i).abs_type_name);
               FETCH csr_chk_uniq_value_meaning INTO l_exists;

               IF csr_chk_uniq_value_meaning%FOUND THEN

	          -- Raise error
                  CLOSE csr_chk_uniq_value_meaning;
                  hr_utility.set_message(0, 'QC-DUPLICATE MEANING');
                  hr_utility.raise_error;

               END IF; -- End if of lookup code meaning check ...
               CLOSE csr_chk_uniq_value_meaning;

               hr_utility.set_location(l_proc_name, 70);

               fnd_lookup_values_pkg.insert_row
                (
                 x_rowid               => l_rowid
                ,x_lookup_type         => p_lookup_type
                ,x_security_group_id   => p_security_group_id
                ,x_view_application_id => 3
                ,x_lookup_code         => fnd_number.number_to_canonical(
                                            p_lookup_values(i).abs_type_id)
                ,x_tag                 => NULL
                ,x_attribute_category  => NULL
                ,x_attribute1          => NULL
                ,x_attribute2          => NULL
                ,x_attribute3          => NULL
                ,x_attribute4          => NULL
                ,x_attribute5          => NULL
                ,x_attribute6          => NULL
                ,x_attribute7          => NULL
                ,x_attribute8          => NULL
                ,x_attribute9          => NULL
                ,x_attribute10         => NULL
                ,x_attribute11         => NULL
                ,x_attribute12         => NULL
                ,x_attribute13         => NULL
                ,x_attribute14         => NULL
                ,x_attribute15         => NULL
                ,x_enabled_flag        => 'Y'
                ,x_start_date_active   => p_effective_start_date
                ,x_end_date_active     => NULL
                ,x_territory_code      => NULL
                ,x_meaning             => p_lookup_values(i).abs_type_name
                ,x_description         => NULL
                ,x_creation_date       => SYSDATE
                ,x_created_by          => l_user_id
                ,x_last_update_date    => SYSDATE
                ,x_last_updated_by     => l_user_id
                ,x_last_update_login   => l_login_id
                );

            END IF; -- End if of lookup code check ...
            CLOSE csr_chk_uniq_value;

            i := p_lookup_values.NEXT(i);

        END LOOP;

     END IF; -- End if of p_lookup_values check ...

    --
    hr_utility.set_location('Leaving '||l_proc_name, 80);
    --
   END create_gap_lookup;
   --
   */

--==============================================================================
--                         MAIN FUNCTION
--==============================================================================

  BEGIN

   hr_utility.set_location('Entering : '||l_proc_name, 10);
   ---------------------
   -- Set session date
   ---------------------
   pay_db_pay_setup.set_session_date(nvl(p_effective_start_date, sysdate));
   --
   hr_utility.set_location(l_proc_name, 20);
   --

  IF (hr_utility.chk_product_install('Oracle Payroll',g_template_leg_code))
  THEN

   OPEN csr_chk_primary_exists;
   FETCH csr_chk_primary_exists INTO l_exists;

   -- Check whether Primary Plan Exists when creating Secondary Plans
   IF p_abse_primary_yn = 'N' THEN

      hr_utility.set_location(l_proc_name, 25);


      IF csr_chk_primary_exists%NOTFOUND THEN

         -- Raise Error
         CLOSE csr_chk_primary_exists;
         hr_utility.set_message(8303, 'PQP_230665_OMP_PRIM_NOT_FOUND');
         hr_utility.raise_error;

      END IF; -- End if of primary element check...

      l_exc_sec_days_bf  := 'N' ;

   -- Check whether Primary Elements exists for this plan
   -- when creating Primary Scheme

   ELSIF p_abse_primary_yn = 'Y' THEN

      hr_utility.set_location(l_proc_name, 26);

      IF csr_chk_primary_exists%FOUND THEN

         -- Raise Error
         CLOSE csr_chk_primary_exists;
         hr_utility.set_message(8303, 'PQP_230667_OMP_PRIMARY_EXISTS');
         hr_utility.raise_error;

      END IF; -- End if of primary element check...

   END IF; -- End if of abs primary yes or no check...
   CLOSE csr_chk_primary_exists;


   ---------------------------
   -- Get Source Template ID
   ---------------------------
   -- Check which Template to call
   -- If p_abse_days_def = 'H' or p_daily_rate_calc_method = 'H'
   -- then Call 'OMP Hours Template' else 'OMP Template'

    IF SUBSTR(p_abse_days_def,2,1) = 'H' OR p_daily_rate_calc_method = 'H' THEN
        l_template_name := 'PQP OMP Hours Template' ;
	l_days_hours    := 'Hours ' ;
    ELSE
        l_template_name := 'PQP OMP Template' ;
        l_days_hours    := NULL ;
    END IF ;


   l_source_template_id := get_template_id
                             ( p_template_name     => l_template_name
			      ,p_legislation_code  => g_template_leg_code
                             );
   -- Based on the user inputs attach the corresponding formula to the absence
   -- element
-- Commented out this code as the formula also created during the
-- Element Creation itself as it is a single formula

   --l_abse_days_def := SUBSTR(p_abse_days_def,1,1);

--   IF l_abse_days_def = 'C' AND
--      p_daily_rate_calc_method = 'C'
--   THEN
--      l_formula_name := '_OMP_CC_ABSENCE_PAY_INFORMATION_FORMULA';
--
--   ELSIF l_abse_days_def = 'C' AND
--      p_daily_rate_calc_method = 'W'
--   THEN
--      l_formula_name := '_OMP_CW_ABSENCE_PAY_INFORMATION_FORMULA';
--
--   ELSIF l_abse_days_def = 'W' AND
--      p_daily_rate_calc_method = 'W'
--   THEN
--      l_formula_name := '_OMP_WW_ABSENCE_PAY_INFORMATION_FORMULA';
--
--   ELSIF l_abse_days_def = 'W' AND
--      p_daily_rate_calc_method = 'C'
--   THEN
--      l_formula_name := '_OMP_WC_ABSENCE_PAY_INFORMATION_FORMULA';
--
--   END IF;
--
--   hr_utility.set_location(l_proc_name, 30);
--
--   l_formula_id   := get_formula_id (p_formula_name => l_formula_name);
--
--   OPEN csr_get_ele_info (' OMP Absence');
--   FETCH csr_get_ele_info INTO l_element_type_id, l_ele_obj_ver_number;
--   CLOSE csr_get_ele_info;
--
--   pay_shadow_element_api.update_shadow_element
--     (p_validate                     => false
--     ,p_effective_date               => p_effective_start_date
--     ,p_element_type_id              => l_element_type_id
--     ,p_element_name                 => ' OMP Absence'
--     ,p_payroll_formula_id           => l_formula_id
--     ,p_object_version_number        => l_ele_obj_ver_number
--     );

   hr_utility.set_location(l_proc_name, 40);

   --
   -- Create user structure from the template
   --
   pay_element_template_api.create_user_structure
    (p_validate                      =>     false
    ,p_effective_date                =>     p_effective_start_date
    ,p_business_group_id             =>     p_bg_id
    ,p_source_template_id            =>     l_source_template_id
    ,p_base_name                     =>     p_pri_ele_name
    ,p_configuration_information1    =>     l_exc_sec_days_bf
    ,p_template_id                   =>     l_template_id
    ,p_allow_base_name_reuse         =>     true
    ,p_object_version_number         =>     l_object_version_number
    );
   --
   hr_utility.set_location(l_proc_name, 50);
   --
   ---------------------------- Update Shadow Structure ----------------------
   --

   l_ele_name(1)           := p_pri_ele_name || ' OMP '||l_days_hours||'Absence';
   l_ele_reporting_name(1) := NVL(p_pri_ele_reporting_name,
                              'OMP '||l_days_hours||'Absence');
   l_ele_description(1)    := NVL(p_pri_ele_description,
                              'OMP '||l_days_hours||'Absence Information Element');
   l_ele_pp(1)             := p_pri_ele_processing_priority;
   l_ele_name(2)           := p_pri_ele_name || ' OMP '||l_days_hours||'Pay';
   l_ele_reporting_name(2) := NVL(p_pay_ele_reporting_name,
                              'OMP '||l_days_hours||'Pay');
   l_ele_description(2)    := NVL(p_pay_ele_description,
                              'OMP '||l_days_hours||'Absence Pay Information Element');
   l_ele_pp(2)             := p_pay_ele_processing_priority;

   FOR i in 1..l_ele_name.count LOOP

     OPEN csr_get_ele_info(l_ele_name(i));
     LOOP
       FETCH csr_get_ele_info INTO l_element_type_id,l_ele_obj_ver_number;
       EXIT WHEN csr_get_ele_info%NOTFOUND;
       if i = 1 then
          l_base_element_type_id := l_element_type_id;
       end if;

       pay_shadow_element_api.update_shadow_element
         (p_validate                     => false
         ,p_effective_date               => p_effective_start_date
         ,p_element_type_id              => l_element_type_id
         ,p_element_name                 => l_ele_name(i)
         ,p_reporting_name               => l_ele_reporting_name(i)
         ,p_description                  => l_ele_description(i)
         ,p_relative_processing_priority => l_ele_pp(i)
         ,p_object_version_number        => l_ele_obj_ver_number
         );

     END LOOP;
     CLOSE csr_get_ele_info;

   END LOOP;

   l_ele_name(1)      := p_pri_ele_name || ' OMP '||l_days_hours||'Absence Retro';
   l_ele_new_name(1)  := l_ele_name(1);
   l_ele_pp(1)        := l_abs_ele_correction_pp;
   l_ele_name(2)      := p_pri_ele_name || ' OMP '||l_days_hours||'Pay Retro';
   l_ele_new_name(2)  := l_ele_name(2);
   l_ele_pp(2)        := l_pay_ele_correction_pp;
   l_ele_name(3)      := p_pri_ele_name || ' OMP '||l_days_hours||'Band1 Pay';
   l_ele_new_name(3)  := nvl(p_pri_ele_name || ' ' || p_band1_ele_base_name ||
                                  'OMP '||l_days_hours||'Band1 Pay', l_ele_name(3));
   l_ele_pp(3)        := p_pay_ele_processing_priority;
   l_ele_name(4)      := p_pri_ele_name || ' OMP '||l_days_hours||'Band2 Pay';
   l_ele_new_name(4)  := nvl(p_pri_ele_name || ' ' || p_band2_ele_base_name ||
                                  'OMP '||l_days_hours||'Band2 Pay', l_ele_name(4));
   l_ele_pp(4)        := p_pay_ele_processing_priority;
   l_ele_name(5)      := p_pri_ele_name || ' OMP '||l_days_hours||'Band3 Pay';
   l_ele_new_name(5)  := nvl(p_pri_ele_name || ' ' || p_band3_ele_base_name ||
                      'OMP '||l_days_hours||'Band3 Pay', l_ele_name(5));
   l_ele_pp(5)        := p_pay_ele_processing_priority;
   l_ele_name(6)      := p_pri_ele_name || ' OMP '||l_days_hours||'Band4 Pay';
   l_ele_new_name(6)  := nvl(p_pri_ele_name || ' ' || p_band4_ele_base_name ||
                      'OMP '||l_days_hours||'Band4 Pay', l_ele_name(6));
   l_ele_pp(6)        := p_pay_ele_processing_priority;
   l_ele_name(7)      := p_pri_ele_name || ' OMP '||l_days_hours||'Band1 Pay Retro';
   l_ele_new_name(7)  := nvl(p_pri_ele_name || ' ' || p_band1_ele_base_name ||
                      'OMP '||l_days_hours||'Band1 Pay Retro', l_ele_name(7));
   l_ele_pp(7)        := l_pay_ele_correction_pp;
   l_ele_name(8)      := p_pri_ele_name || ' OMP '||l_days_hours||'Band2 Pay Retro';
   l_ele_new_name(8)  := nvl(p_pri_ele_name || ' ' || p_band2_ele_base_name ||
                      'OMP '||l_days_hours||'Band2 Pay Retro', l_ele_name(8));
   l_ele_pp(8)        := l_pay_ele_correction_pp;
   l_ele_name(9)      := p_pri_ele_name || ' OMP '||l_days_hours||'Band3 Pay Retro';
   l_ele_new_name(9)  := nvl(p_pri_ele_name || ' ' || p_band3_ele_base_name ||
                      'OMP '||l_days_hours||'Band3 Pay Retro', l_ele_name(9));
   l_ele_pp(9)        := l_pay_ele_correction_pp;
   l_ele_name(10)     := p_pri_ele_name || ' OMP '||l_days_hours||'Band4 Pay Retro';
   l_ele_new_name(10) := nvl(p_pri_ele_name || ' ' || p_band4_ele_base_name ||
                      'OMP '||l_days_hours||'Band4 Pay Retro', l_ele_name(10));
   l_ele_pp(10)       := l_pay_ele_correction_pp;

   hr_utility.set_location(l_proc_name, 60);

   FOR i in 1..l_ele_name.count LOOP

     OPEN csr_get_ele_info(l_ele_name(i));
     LOOP
       FETCH csr_get_ele_info INTO l_element_type_id,l_ele_obj_ver_number;
       EXIT WHEN csr_get_ele_info%NOTFOUND;

       pay_shadow_element_api.update_shadow_element
         (p_validate                     => false
         ,p_effective_date               => p_effective_start_date
         ,p_element_type_id              => l_element_type_id
         ,p_element_name                 => l_ele_new_name(i)
         ,p_relative_processing_priority => l_ele_pp(i)
         ,p_object_version_number        => l_ele_obj_ver_number
         );

     END LOOP;
     CLOSE csr_get_ele_info;

   END LOOP;

   -- Update shadow structure for Balances

   hr_utility.set_location(l_proc_name, 70);

   if p_band1_ele_base_name is not null then
     l_bal_name(1)      := p_pri_ele_name || ' Days Paid Band1 Pay';
     l_bal_new_name(1)  := p_pri_ele_name || ' ' || p_band1_ele_base_name ||
                           ' Days Paid Band1 Pay';
     l_bal_name(2)      := p_pri_ele_name || ' Band1 Pay Paid';
     l_bal_new_name(2)  := p_pri_ele_name || ' ' || p_band1_ele_base_name ||
                           ' Band1 Pay Paid';
     l_bal_name(3)      := p_pri_ele_name || ' Band1 Pay Entitlement';
     l_bal_new_name(3)  := p_pri_ele_name || ' ' || p_band1_ele_base_name ||
                           ' Band1 Pay Entitlement';

     if p_band2_ele_base_name is not null then
       l_bal_name(4)      := p_pri_ele_name || ' Days Paid Band2 Pay';
       l_bal_new_name(4)  := p_pri_ele_name || ' ' || p_band2_ele_base_name ||
                             ' Days Paid Band2 Pay';
       l_bal_name(5)      := p_pri_ele_name || ' Band2 Pay Paid';
       l_bal_new_name(5)  := p_pri_ele_name || ' ' || p_band2_ele_base_name ||
                             ' Band2 Pay Paid';
       l_bal_name(6)      := p_pri_ele_name || ' Band2 Pay Entitlement';
       l_bal_new_name(6)  := p_pri_ele_name || ' ' || p_band2_ele_base_name ||
                             ' Band2 Pay Entitlement';

       if p_band3_ele_base_name is not null then
         l_bal_name(7)      := p_pri_ele_name || ' Days Paid Band3 Pay';
         l_bal_new_name(7)  := p_pri_ele_name || ' ' || p_band3_ele_base_name ||
                               ' Days Paid Band3 Pay';
         l_bal_name(8)      := p_pri_ele_name || ' Band3 Pay Paid';
         l_bal_new_name(8)  := p_pri_ele_name || ' ' || p_band3_ele_base_name ||
                               ' Band3 Pay Paid';
         l_bal_name(9)      := p_pri_ele_name || ' Band3 Pay Entitlement';
         l_bal_new_name(9)  := p_pri_ele_name || ' ' || p_band3_ele_base_name ||
                               ' Band3 Pay Entitlement';

         if p_band4_ele_base_name is not null then
           l_bal_name(10)     := p_pri_ele_name || ' Days Paid Band4 Pay';
           l_bal_new_name(10) := p_pri_ele_name || ' ' || p_band4_ele_base_name ||
                                 ' Days Paid Band4 Pay';
           l_bal_name(11)     := p_pri_ele_name || ' Band4 Pay Paid';
           l_bal_new_name(11) := p_pri_ele_name || ' ' || p_band4_ele_base_name ||
                                 ' Band4 Pay Paid';
           l_bal_name(12)     := p_pri_ele_name || ' Band4 Pay Entitlement';
           l_bal_new_name(12) := p_pri_ele_name || ' ' || p_band4_ele_base_name ||
                                 ' Band4 Pay Entitlement';

         end if; --  end if of bnd4 sub name check ...

       end if; -- end if of bnd3 sub name check ...

     end if; -- end if of bnd2 sub name check ...

   end if; -- end if of bnd1 sub name check ...

   hr_utility.set_location(l_proc_name, 80);
 /*

   FOR i in 1..l_bal_name.count LOOP

     OPEN csr_get_bal_info(l_bal_name(i));
     LOOP
       FETCH csr_get_bal_info INTO l_balance_type_id,l_bal_obj_ver_number;
       EXIT WHEN csr_get_bal_info%NOTFOUND;

       pay_sbt_upd.upd
         (p_effective_date               => p_effective_start_date
         ,p_balance_type_id              => l_balance_type_id
         ,p_balance_name                 => l_bal_new_name(i)
         ,p_object_version_number        => l_bal_obj_ver_number
         );

     END LOOP;
     CLOSE csr_get_bal_info;

   END LOOP;
vjhanak
*/

   hr_utility.set_location(l_proc_name, 90);
   ---------------------------------------------------------------------------
   ---------------------------- Generate Core Objects ------------------------
   ---------------------------------------------------------------------------

   pay_element_template_api.generate_part1
    (p_validate                      =>     false
    ,p_effective_date                =>     p_effective_start_date
    ,p_hr_only                       =>     false
    ,p_hr_to_payroll                 =>     false
    ,p_template_id                   =>     l_template_id);
   --
   hr_utility.set_location(l_proc_name, 100);
   --
   pay_element_template_api.generate_part2
    (p_validate                      =>     false
    ,p_effective_date                =>     p_effective_start_date
    ,p_template_id                   =>     l_template_id);
   --

   -- Update Main Elements with the Correction Element Information

   hr_utility.set_location(l_proc_name, 110);

   l_main_ele_name(1)    := p_pri_ele_name || ' OMP '||l_days_hours||'Absence';
   l_main_eei_info19(1)  := 'Absence Info';
   l_retro_ele_name(1)   := l_ele_new_name(1);
   l_retro_eei_info19(1) := 'Absence Correction Info';
   l_main_ele_name(2)    := p_pri_ele_name || ' OMP '||l_days_hours||'Pay';
   l_main_eei_info19(2)  := 'Pay Info';
   l_retro_ele_name(2)   := l_ele_new_name(2);
   l_retro_eei_info19(2) := 'Pay Correction Info';
   l_main_ele_name(3)    := l_ele_new_name(3);
   l_main_eei_info19(3)  := 'Band1 Info';
   l_retro_ele_name(3)   := l_ele_new_name(7);
   l_retro_eei_info19(3) := 'Band1 Correction Info';
   l_main_ele_name(4)    := l_ele_new_name(4);
   l_main_eei_info19(4)  := 'Band2 Info';
   l_retro_ele_name(4)   := l_ele_new_name(8);
   l_retro_eei_info19(4) := 'Band2 Correction Info';
   l_main_ele_name(5)    := l_ele_new_name(5);
   l_main_eei_info19(5)  := 'Band3 Info';
   l_retro_ele_name(5)   := l_ele_new_name(9);
   l_retro_eei_info19(5) := 'Band3 Correction Info';
   l_main_ele_name(6)    := l_ele_new_name(6);
   l_main_eei_info19(6)  := 'Band4 Info';
   l_retro_ele_name(6)   := l_ele_new_name(10);
   l_retro_eei_info19(6) := 'Band4 Correction Info';

   FOR I IN 1..l_main_ele_name.count LOOP

       update_ele_retro_info (p_main_ele_name  => l_main_ele_name(i)
                             ,p_retro_ele_name => l_retro_ele_name(i)
                             );

   END LOOP;

   -- Update the pay component rate type input value for base element

   IF p_pay_src_pay_component IS NOT NULL THEN

      --
      hr_utility.set_location (l_proc_name, 120);
      --
      update_ipval_defval (p_ele_name  => l_main_ele_name(1)
                          ,p_ip_name   => 'Pay Component Rate Type'
                          ,p_def_value => p_pay_src_pay_component
                          );

   END IF; -- End of of pay src comp not null check ...

   hr_utility.set_location(l_proc_name, 130);

   l_base_element_type_id := get_object_id ('ELE', l_main_ele_name(1));

   hr_utility.set_location(l_proc_name, 140);
   IF p_maternity_abse_ent_udt IS NULL THEN

     -- Create UDT for Maternity Absence Entitlements

     l_udt_type.user_table_name := l_base_name|| --UPPER(p_pri_ele_name) ||
                                   '_MATERNITY_ABSENCE_ENTITLEMENTS';
     l_udt_type.range_or_match  := 'R'; -- Range
     l_udt_type.user_key_units  := 'N';
     l_udt_type.user_row_title  := NULL;

     -- columns
     l_udt_cols.DELETE;
     FOR band_rec IN c_get_band_meaning(p_effective_start_date)
       LOOP
         y := y + 1;
         l_udt_cols(y).user_column_name  := band_rec.meaning||'Y';
         l_udt_cols(y).formula_id        := NULL;
         l_udt_cols(y).business_group_id := p_bg_id;
       END LOOP;

     FOR band_rec IN c_get_band_meaning(p_effective_start_date)
       LOOP
         y := y + 1;
         l_udt_cols(y).user_column_name  := band_rec.meaning||'N';
         l_udt_cols(y).formula_id        := NULL;
         l_udt_cols(y).business_group_id := p_bg_id;
       END LOOP;

     -- rows

     l_udt_rows.DELETE;
     l_udt_rows(1).row_low_range_or_name := '-999999';
     l_udt_rows(1).display_sequence      := 1;
     l_udt_rows(1).row_high_range        := '-999999';
     l_udt_rows(1).business_group_id     := NULL;
     l_udt_rows(1).legislation_code      := 'GB';
     l_udt_rows(2).row_low_range_or_name := '-888888';
     l_udt_rows(2).display_sequence      := 2;
     l_udt_rows(2).row_high_range        := '-888888';
     l_udt_rows(2).business_group_id     := NULL;
     l_udt_rows(2).legislation_code      := 'GB';

     l_eei_information11 := fnd_number.number_to_canonical
                                  (create_udt (p_udt_type => l_udt_type
                                              ,p_udt_cols => l_udt_cols
                                              ,p_udt_rows => l_udt_rows
                                              )
                                  );

   ELSE

     -- Store the user_table_id for this udt name
     l_eei_information11 := fnd_number.number_to_canonical
                             (p_maternity_abse_ent_udt);

   END IF; -- End if of p_maternity_abse_ent_udt null check ...

   hr_utility.set_location(l_proc_name, 150);

   IF p_holidays_udt IS NOT NULL THEN

      -- No Cal UDT
      IF p_holidays_udt = -1 THEN
            l_eei_information12 := NULL;
      -- Use Existing UDT
      ELSIF p_holidays_udt <> -1  THEN
         -- Store the user_table_id for this udt name
         l_eei_information12 := fnd_number.number_to_canonical
                               (p_holidays_udt);
      END IF;

   ELSE -- create the udt

     -- Create UDT for Holidays Calendar

     l_udt_type.user_table_name :=  l_base_name||'_CALENDAR'; --UPPER(p_pri_ele_name)
     l_udt_type.range_or_match  := 'M'; -- Match
     l_udt_type.user_key_units  := 'T';
     l_udt_type.user_row_title  := NULL;

     -- columns

     l_udt_cols.DELETE;
     l_udt_cols(1).user_column_name  := 'Excluded Paid Days'; --'Default';
     l_udt_cols(1).formula_id        := NULL;
     l_udt_cols(1).business_group_id := NULL;
     l_udt_cols(1).legislation_code  := 'GB';

     l_udt_rows.DELETE;

     l_eei_information12 := fnd_number.number_to_canonical(
                                create_udt (p_udt_type => l_udt_type
                                           ,p_udt_cols => l_udt_cols
                                           ,p_udt_rows => l_udt_rows
                                           )              );


   END IF; -- End if of p_holidays_udt null check ...

   --
   hr_utility.set_location(l_proc_name, 160);
   --
   l_eei_information20 := p_abse_type_lookup_type;

   IF p_abse_type_lookup_type IS NULL THEN

      -- Create Lookup dynamically
--      l_lookup_type    := upper(p_pri_ele_name) || '_ABS_TP';
      l_lookup_type    := l_base_name|| '_LIST'; -- upper(p_pri_ele_name)
--      l_lookup_meaning := upper(p_pri_ele_name) || '_ABSENCE_ATTENDANCE_TYPES';
      l_lookup_meaning := l_base_name || '_ABSENCE_ATTENDANCE_TYPES';
      create_lookup (p_lookup_type    => l_lookup_type
                    ,p_lookup_meaning => l_lookup_meaning
                    ,p_lookup_values  => p_abse_type_lookup_value
                    );
      l_eei_information20 := l_lookup_type;

      -- Create GAP lookup dynamically
      l_lookup_type    := 'PQP_GAP_ABSENCE_TYPES_LIST';
      l_lookup_meaning := l_lookup_type;
      pqp_gb_osp_template.create_gap_lookup (
                         p_security_group_id => p_security_group_id
			,p_ele_eff_start_date => p_effective_start_date
                        ,p_lookup_type    => l_lookup_type
                        ,p_lookup_meaning => l_lookup_meaning
                        ,p_lookup_values  => p_abse_type_lookup_value
                        );

   END IF; -- End if of abs type lookup type not null ...

   FOR I IN 1..l_main_ele_name.count LOOP

     hr_utility.set_location(l_proc_name, 170);

     l_eei_element_type_id    := get_object_id ('ELE', l_main_ele_name(i));

  -- Create a row in pay_element_extra_info with all the element information
      pay_element_extra_info_api.create_element_extra_info
        (p_element_type_id          => l_eei_element_type_id
        ,p_information_type         => 'PQP_GB_OMP_ABSENCE_PLAN_INFO'
        ,P_EEI_INFORMATION_CATEGORY => 'PQP_GB_OMP_ABSENCE_PLAN_INFO'
        ,p_eei_information1         =>
                                   fnd_number.number_to_canonical(p_plan_id)
        ,p_eei_information2         => p_plan_description
        ,p_eei_information3         => p_los_calc
        ,p_eei_information4         => p_los_calc_duration
        ,p_eei_information5         => p_los_calc_uom
        ,p_eei_information6         => p_avg_earnings_duration
        ,p_eei_information7         => p_avg_earnings_uom
        ,p_eei_information8         => p_avg_earnings_balance
        ,p_eei_information9         => p_abse_days_def
        --,p_eei_information10        => p_cal_abse_uom
        ,p_eei_information11        => l_eei_information11
        ,p_eei_information12        => l_eei_information12
        ,p_eei_information13        => p_daily_rate_calc_method
        ,p_eei_information14        => p_daily_rate_calc_period
        ,p_eei_information15        => p_daily_rate_calc_divisor
        ,p_eei_information16        => p_pay_src_pay_component
        ,p_eei_information17        => p_abse_primary_yn
        ,p_eei_information18        => p_working_pattern
        ,p_eei_information19        => l_main_eei_info19(i)
        ,p_eei_information20        => l_eei_information20
        ,p_eei_information27        => l_eei_information27
        ,p_eei_information30        => l_eei_information30
        ,p_element_type_extra_info_id => l_eei_info_id
        ,p_object_version_number      => l_ovn_eei);

     l_eei_element_type_id    := get_object_id ('ELE', l_retro_ele_name(i));

     hr_utility.set_location(l_proc_name, 180);
     -- Create a row in pay_element_extra_info with all the element information
      pay_element_extra_info_api.create_element_extra_info
        (p_element_type_id          => l_eei_element_type_id
        ,p_information_type         => 'PQP_GB_OMP_ABSENCE_PLAN_INFO'
        ,P_EEI_INFORMATION_CATEGORY => 'PQP_GB_OMP_ABSENCE_PLAN_INFO'
        ,p_eei_information1         =>
                                   fnd_number.number_to_canonical(p_plan_id)
        ,p_eei_information2         => p_plan_description
        ,p_eei_information3         => p_los_calc
        ,p_eei_information4         => p_los_calc_duration
        ,p_eei_information5         => p_los_calc_uom
        ,p_eei_information6         => p_avg_earnings_duration
        ,p_eei_information7         => p_avg_earnings_uom
        ,p_eei_information8         => p_avg_earnings_balance
        ,p_eei_information9         => p_abse_days_def
        --,p_eei_information10        => p_cal_abse_uom
        ,p_eei_information11        => l_eei_information11
        ,p_eei_information12        => l_eei_information12
        ,p_eei_information13        => p_daily_rate_calc_method
        ,p_eei_information14        => p_daily_rate_calc_period
        ,p_eei_information15        => p_daily_rate_calc_divisor
        ,p_eei_information16        => p_pay_src_pay_component
        ,p_eei_information17        => p_abse_primary_yn
        ,p_eei_information18        => p_working_pattern
        ,p_eei_information19        => l_retro_eei_info19(i)
        ,p_eei_information20        => l_eei_information20
        ,p_eei_information27        => l_eei_information27
        ,p_eei_information30        => l_eei_information30
        ,p_element_type_extra_info_id => l_eei_info_id
        ,p_object_version_number      => l_ovn_eei);

   END LOOP;

   --- Elements Can be Linked Here
       create_element_links ( p_business_group_id    => p_bg_id
 			    , p_effective_start_date => p_effective_start_date
                            , p_effective_end_date   => p_effective_end_date
			    --, p_legislation_code     => 'GB'
			    --, p_base_name            => p_pri_ele_name
			    --, p_abs_type             => ' OMP '||l_days_hours
                            ,p_template_id          => l_template_id
			    ) ;
   --------

     IF p_abse_primary_yn = 'Y' THEN
          pqp_gb_osp_template.automate_plan_setup
          (p_pl_id             => p_plan_id
          ,p_business_group_id => p_bg_id
          ,p_element_type_id   => l_base_element_type_id
          ,p_effective_date    => p_effective_start_date
          ,p_base_name         => l_base_name
          ,p_plan_class        => 'OMP'
          );
    END IF;


 ELSE

   hr_utility.set_message(8303, 'PQP_230535_GBORAPAY_NOT_FOUND');
   hr_utility.raise_error;


 END IF; -- IF chk_product_install('Oracle Payroll',g_template_leg_code))

 hr_utility.set_location('Leaving :'||l_proc_name, 190);

 RETURN l_base_element_type_id;

  --
END create_user_template;
--
--==========================================================================
--                             Deletion procedure
--==========================================================================
PROCEDURE delete_user_template
           (p_plan_id                      IN NUMBER
           ,p_business_group_id            IN NUMBER
           ,p_pri_ele_name                 IN VARCHAR2
           ,p_abse_ele_type_id             IN NUMBER
           ,p_abse_primary_yn              IN VARCHAR2
           ,p_security_group_id            IN NUMBER
           ,p_effective_date               IN DATE
           ) IS
  --
  l_template_id     NUMBER(9);
  l_proc_name       varchar2(72)      := g_proc_name || 'delete_user_template';
  l_eei_info_id     number;
  l_ovn_eei         number;
  l_entudt_id       pay_user_tables.user_table_id%TYPE;
  l_caludt_id       pay_user_tables.user_table_id%TYPE;
  l_lookup_type     fnd_lookup_types_vl.lookup_type%TYPE;
  l_lookup_code     fnd_lookup_values_vl.lookup_code%TYPE;
  l_exists          VARCHAR2(1);
  l_element_type_id pay_element_types_f.element_type_id%TYPE;

  TYPE t_number IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

  l_lookup_collection t_number;

  l_entitlements_uom VARCHAR2(1) ;
  l_daily_rate_uom   pay_element_type_extra_info.eei_information13%TYPE ;
  l_days_hours       VARCHAR2(10) ;

  --
   CURSOR csr_get_scheme_type(p_ele_type_id IN NUMBER) IS
   SELECT  substr(pee.eei_information9,2,1) entitlements_uom
          ,pee.eei_information13 daily_rate_uom
     FROM pay_element_type_extra_info pee
    WHERE  element_type_id = p_ele_type_id
      AND  information_type = 'PQP_GB_OMP_ABSENCE_PLAN_INFO' ;

  CURSOR csr_get_ele_type_id (c_template_id number) IS
  SELECT element_type_id
    FROM pay_template_core_objects pet
        ,pay_element_types_f       petf
  WHERE  pet.template_id = c_template_id
    AND  petf.element_type_id = pet.core_object_id
    AND  pet.core_object_type = 'ET';

  CURSOR csr_get_eei_info (c_element_type_id number) IS
  SELECT element_type_extra_info_id
        ,fnd_number.canonical_to_number(eei_information11) entitlement_udt
        ,fnd_number.canonical_to_number(eei_information12) calendar_udt
        ,eei_information20 lookup_type
   FROM pay_element_type_extra_info petei
   WHERE element_type_id = c_element_type_id ;

  CURSOR csr_chk_eei_for_entudt (c_udt_id number) IS
  SELECT 'x'
    FROM pay_element_type_extra_info
  WHERE  eei_information1 <> fnd_number.number_to_canonical(p_plan_id)
    AND  eei_information11 = fnd_number.number_to_canonical(c_udt_id)
    AND  information_type = 'PQP_GB_OMP_ABSENCE_PLAN_INFO'
    AND  rownum = 1;

  CURSOR csr_chk_eei_for_caludt (c_udt_id number) IS
  SELECT 'x'
    FROM pay_element_type_extra_info
  WHERE  eei_information1 <> fnd_number.number_to_canonical(p_plan_id)
    AND  eei_information12 = fnd_number.number_to_canonical(c_udt_id)
    AND  information_type = 'PQP_GB_OMP_ABSENCE_PLAN_INFO'
    AND  rownum = 1;

  CURSOR csr_chk_eei_for_lkt (c_lookup_type varchar2)
  IS
  SELECT 'x'
    FROM pay_element_type_extra_info
  WHERE  eei_information1 <> fnd_number.number_to_canonical(p_plan_id)
    AND  eei_information20 = c_lookup_type
    AND  information_type = 'PQP_GB_OMP_ABSENCE_PLAN_INFO'
    AND  rownum = 1;


  CURSOR csr_chk_sec_ele (c_te_usrstr_id NUMBER
                         ,c_template_name VARCHAR2
			 ,c_days_hours VARCHAR2) IS
  SELECT 'x'
  FROM   pay_element_templates       pets
        ,pay_shadow_element_types    pset
        ,pay_template_core_objects   ptco
        ,pay_element_type_extra_info peei
  WHERE  pets.template_id       <> c_te_usrstr_id
    -- For the given user structure
    AND  pets.template_name     = c_template_name --'PQP OMP Template'
    AND  pets.template_type     = 'U'
    AND  pets.business_group_id = p_business_group_id
    AND  pset.template_id       = pets.template_id  -- find the base element
    AND  pset.element_name      = pets.base_name ||c_days_hours|| ' OMP Absence'
    AND  ptco.template_id       = pset.template_id  -- For the base element
    AND  ptco.shadow_object_id  = pset.element_type_id -- find the core element
    AND  ptco.core_object_type  = 'ET'
    AND  ptco.core_object_id    = peei.element_type_id -- For the core element
    AND  peei.eei_information1  = fnd_number.number_to_canonical(p_plan_id)
    AND  peei.information_type  = 'PQP_GB_OMP_ABSENCE_PLAN_INFO';
    -- find the eei info

 CURSOR csr_get_template_id (p_template_name IN VARCHAR2) is
  SELECT template_id
  FROM   pay_element_templates
  WHERE  base_name         = p_pri_ele_name
    AND  template_name     = p_template_name --'PQP OMP Template'
    AND  business_group_id = p_business_group_id
    AND  template_type     = 'U';

    l_template_name pay_element_templates.template_name%TYPE ;

  -- Cursor to retrieve lookup code for a given
  -- lookup type

  CURSOR csr_get_lookup_code (c_lookup_type varchar2)
  IS
  SELECT lookup_code
    FROM fnd_lookup_values_vl
  WHERE  lookup_type         = c_lookup_type
    AND  security_group_id   = p_security_group_id
    AND  view_application_id = 3;

   --
   --========================================================================
   --                PROCEDURE get_other_lookups
   --========================================================================

   PROCEDURE get_other_lookups (p_business_group_id   in  number
                               ,p_template_name       in  varchar2
			       ,p_days_hours          in varchar2
                               ,p_lookup_collection   out nocopy t_number )
   IS

   -- The original query is split into 2 queries
   -- to avoid Merge joins and make use of Indexes.
   -- There is no effective date check on table pay_element_types_f
   -- as we are interested in data irrespective of date.
     -- Cursor to retrieve lookup type information

     CURSOR csr_get_lookup_type(c_base_name varchar2)
     IS
     SELECT DISTINCT(pete.eei_information20) lookup_type
       FROM pay_element_type_extra_info pete
           ,pay_element_types_f         petf
        --   ,pay_element_templates       pet
     WHERE  pete.element_type_id   = petf.element_type_id
       AND  pete.information_type  = 'PQP_GB_OMP_ABSENCE_PLAN_INFO'
       AND  pete.eei_information17 = 'Y'
       AND  petf.element_name      = c_base_name||p_days_hours|| ' OMP Absence'
                       -- pet.base_name ||p_days_hours|| ' OMP Absence'
       AND  petf.business_group_id = p_business_group_id
       --AND  pet.template_name      = p_template_name --'PQP OMP Template'
       --AND  pet.template_type      = 'U'
       --AND  pet.business_group_id  = p_business_group_id;
       ;

      CURSOR csr_template_names IS
       SELECT pet.base_name
         FROM pay_element_templates pet
        WHERE pet.template_name      = p_template_name
          AND pet.template_type      = 'U'
          AND pet.business_group_id  = p_business_group_id ;

     l_lookup_collection t_number;
     l_number            NUMBER;
     l_lookup_code       fnd_lookup_values_vl.lookup_code%TYPE;
     l_lookup_type       fnd_lookup_types_vl.lookup_type%TYPE;
     l_proc_name         VARCHAR2(72) := g_proc_name || 'get_other_lookups';
     l_base_name         pay_element_templates.base_name%TYPE ;

   --
   BEGIN

   --
     hr_utility.set_location('Entering '||l_proc_name, 10);

     -- get the template base names
     OPEN csr_template_names ;
     LOOP
     FETCH csr_template_names INTO l_base_name ;
     EXIT WHEN csr_template_names%NOTFOUND ;

     -- Get the lookup type information

       OPEN csr_get_lookup_type(c_base_name => l_base_name);
       LOOP

         FETCH csr_get_lookup_type INTO l_lookup_type;
         EXIT WHEN csr_get_lookup_type%NOTFOUND;

       -- Get the lookup code for this lookup type

         hr_utility.set_location(l_proc_name, 20);

         OPEN csr_get_lookup_code(l_lookup_type);
         LOOP

           FETCH csr_get_lookup_code INTO l_lookup_code;
           EXIT WHEN csr_get_lookup_code%NOTFOUND;

           -- Check whether this lookup code is already added to
           -- the collection

           l_number := fnd_number.canonical_to_number(l_lookup_code);

           IF NOT l_lookup_collection.EXISTS(l_number) THEN

              l_lookup_collection(l_number) := l_number;

           END IF; -- End if of lookup collection exists check ...

         END LOOP;
         CLOSE csr_get_lookup_code;

       END LOOP;
       CLOSE csr_get_lookup_type;

     END LOOP ;
     CLOSE csr_template_names;


     p_lookup_collection := l_lookup_collection;

     hr_utility.set_location('Leaving '||l_proc_name, 30);

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Entering excep:'||l_proc_name, 35);
       p_lookup_collection.delete;
       raise;


   --
   END get_other_lookups;
   --

   --
   --========================================================================
   --                PROCEDURE delete_lookup
   --========================================================================

   PROCEDURE delete_lookup (p_lookup_type         in   varchar2
                           ,p_security_group_id   in   number
                           ,p_view_application_id in   number
                           ,p_lookup_collection   in   t_number)
   IS

   --

     CURSOR csr_get_lkt_info IS
     SELECT 'x'
       FROM fnd_lookup_types_vl
     WHERE  lookup_type         = p_lookup_type
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = p_view_application_id;

     CURSOR csr_get_lkv_info IS
     SELECT lookup_code
       FROM fnd_lookup_values_vl
     WHERE  lookup_type = p_lookup_type
       AND  security_group_id   = p_security_group_id
       AND  view_application_id = p_view_application_id;

     l_proc_name     VARCHAR2(72) := g_proc_name || 'delete_lookup';
     l_exists        VARCHAR2(1);
     l_lookup_code   fnd_lookup_values_vl.lookup_code%TYPE;

   BEGIN
     --
     hr_utility.set_location ('Entering '||l_proc_name, 10);
     --

     hr_utility.set_location('Security Group' || to_char(p_security_group_id),
     15);
     hr_utility.set_location('Lookup Type' || p_lookup_type, 16);

     OPEN csr_get_lkt_info;
     FETCH csr_get_lkt_info into l_exists;

     IF csr_get_lkt_info%FOUND THEN

        -- Get Lookup Value Info
        hr_utility.set_location(l_proc_name, 20);

        OPEN csr_get_lkv_info;
        LOOP
          FETCH csr_get_lkv_info INTO l_lookup_code;
          EXIT WHEN csr_get_lkv_info%NOTFOUND;

          -- Check whether this lookup code has to be deleted
          -- from PQP_GAP_ABSENCE_TYPES_LIST lookup type

          hr_utility.set_location (l_proc_name, 25);

          IF NOT p_lookup_collection.EXISTS(fnd_number.canonical_to_number(
                                               l_lookup_code)) THEN
             fnd_lookup_values_pkg.delete_row
               (x_lookup_type         => 'PQP_GAP_ABSENCE_TYPES_LIST'
               ,x_security_group_id   => p_security_group_id
               ,x_view_application_id => p_view_application_id
               ,x_lookup_code         => l_lookup_code
               );

          END IF; -- End if of absence type exists in this collection check...

          -- Delete the lookup code
          hr_utility.set_location (l_proc_name, 30);

          fnd_lookup_values_pkg.delete_row
            (x_lookup_type         => p_lookup_type
            ,x_security_group_id   => p_security_group_id
            ,x_view_application_id => p_view_application_id
            ,x_lookup_code         => l_lookup_code
            );
        END LOOP;
        CLOSE csr_get_lkv_info;

        -- Delete the lookup type
        hr_utility.set_location(l_proc_name, 40);

        fnd_lookup_types_pkg.delete_row
          (x_lookup_type         => p_lookup_type
          ,x_security_group_id   => p_security_group_id
          ,x_view_application_id => p_view_application_id
          );

     END IF; -- End if of row found check ...
     CLOSE csr_get_lkt_info;

     --
     hr_utility.set_location('Leaving '||l_proc_name, 50);
     --

   END delete_lookup;
   --

   --
   --========================================================================
   --                PROCEDURE delete_udt
   --========================================================================

   PROCEDURE delete_udt (p_udt_id IN NUMBER) IS

     CURSOR csr_get_usr_table_id IS
     SELECT rowid
       FROM pay_user_tables
      WHERE user_table_id     = p_udt_id
        AND business_group_id = p_business_group_id;

     CURSOR csr_get_usr_col_id IS
     SELECT user_column_id
       FROM pay_user_columns
      WHERE user_table_id = p_udt_id;

     CURSOR csr_get_usr_row_id IS
     SELECT user_row_id
       FROM pay_user_rows_f
     WHERE  user_table_id = p_udt_id;

     --
     l_proc_name          VARCHAR(72) := g_proc_name || 'delete_udt';
     l_rowid              rowid;
     l_usr_row_id         pay_user_rows.user_row_id%TYPE;
     l_usr_col_id         pay_user_columns.user_column_id%TYPE;
     --
   --
   BEGIN

     --
     hr_utility.set_location ('Entering '||l_proc_name, 10);
     --

     -- Get user_table_id from pay_user_tables
     OPEN csr_get_usr_table_id;
     FETCH csr_get_usr_table_id INTO l_rowid;

     IF csr_get_usr_table_id%FOUND THEN

        -- Get user_column_id from pay_user_columns
        hr_utility.set_location (l_proc_name, 20);

        OPEN csr_get_usr_col_id;
        LOOP
          FETCH csr_get_usr_col_id INTO l_usr_col_id;
          EXIT WHEN csr_get_usr_col_id%NOTFOUND;

            -- Delete pay_user_column_instances_f for this column_id
            hr_utility.set_location (l_proc_name, 30);

            DELETE pay_user_column_instances_f
            WHERE  user_column_id = l_usr_col_id;

        END LOOP;
        CLOSE csr_get_usr_col_id;

        -- Delete pay_user_columns for this table_id
        hr_utility.set_location (l_proc_name, 40);

        DELETE pay_user_columns
        WHERE  user_table_id = p_udt_id;

        OPEN csr_get_usr_row_id;
        LOOP
          FETCH csr_get_usr_row_id INTO l_usr_row_id;
          EXIT WHEN csr_get_usr_row_id%NOTFOUND;

            -- Delete pay_user_rows_f for this table id
            hr_utility.set_location (l_proc_name, 50);

            pay_user_rows_pkg.check_delete_row
              (p_user_row_id           => l_usr_row_id
              ,p_validation_start_date => NULL
              ,p_dt_delete_mode        => 'ZAP'
              );

            DELETE pay_user_rows_f
            WHERE  user_row_id = l_usr_row_id;

        END LOOP;
        CLOSE csr_get_usr_row_id;


        -- Delete pay_user_tables for this table id
        hr_utility.set_location (l_proc_name, 60);
        pay_user_tables_pkg.delete_row
          (p_rowid         => l_rowid
          ,p_user_table_id => p_udt_id
          );


     END IF; -- End of of user_table found check ...
     CLOSE csr_get_usr_table_id;

     --
     hr_utility.set_location ('Leaving '||l_proc_name, 70);
     --
   --
   END delete_udt;
   --

--
BEGIN
     -- for Multi Messages
   hr_multi_message.enable_message_list;

   --
   hr_utility.set_location('Entering :'||l_proc_name, 10);
   --

   FOR csr_get_scheme_type_rec IN csr_get_scheme_type
                                (
				p_ele_type_id => p_abse_ele_type_id
				)
   LOOP
       l_entitlements_uom := csr_get_scheme_type_rec.entitlements_uom ;
       l_daily_rate_uom   := csr_get_scheme_type_rec.daily_rate_uom ;
   END LOOP ;

   IF l_entitlements_uom = 'H' or l_daily_rate_uom = 'H' THEN
       l_template_name := 'PQP OMP Hours Template' ;
       l_days_hours    := 'Hours ';
   ELSE
       l_template_name := 'PQP OMP Template' ;
       l_days_hours    := NULL ;
   END IF ;

   FOR csr_get_template_id_rec IN csr_get_template_id
                                 ( p_template_name => l_template_name
				 ) LOOP
       l_template_id := csr_get_template_id_rec.template_id;
   END LOOP;

   hr_utility.set_location(l_proc_name, 20);

   -- Check whether this is primary element

   IF p_abse_primary_yn = 'Y' THEN

      -- Check whether there are any secondary elements
      hr_utility.set_location(l_proc_name, 40);

      OPEN csr_chk_sec_ele (
			  c_te_usrstr_id  => l_template_id
                         ,c_template_name => l_template_name
			 ,c_days_hours    => l_days_hours );
      FETCH csr_chk_sec_ele INTO l_exists;

      IF csr_chk_sec_ele%FOUND THEN

         -- Raise error
         CLOSE csr_chk_sec_ele;
         hr_utility.set_message (8303,'PQP_230607_OSP_SEC_ELE_EXISTS');
         hr_utility.raise_error;

      END IF; -- End if of sec element check ...
      CLOSE csr_chk_sec_ele;

   END IF; -- End if of abs primary yn check ...

--Delete data created by auto plan setup

   IF p_abse_primary_yn = 'Y'
   THEN
    pqp_gb_osp_template.del_automated_plan_setup_data
      (p_pl_id                        => p_plan_id
      ,p_business_group_id            => p_business_group_id
      ,p_effective_date               => p_effective_date
      ,p_base_name                    => p_pri_ele_name
      );
   END IF;
--

   -- Get Element type Id's from template core object

   OPEN csr_get_ele_type_id (l_template_id);
   LOOP

      FETCH csr_get_ele_type_id INTO l_element_type_id;
      EXIT WHEN csr_get_ele_type_id%NOTFOUND;


       -- Check if this Element is Linked to Benefit Standard Rates
       check_ben_standard_rates_link (
                      p_business_group_id => p_business_group_id
                     ,p_plan_id           => p_plan_id
	             ,p_element_type_id   => l_element_type_id  ) ;



        -- Get Element extra info id for this element type id

        OPEN csr_get_eei_info (l_element_type_id);
        FETCH csr_get_eei_info INTO l_eei_info_id
                                   ,l_entudt_id
                                   ,l_caludt_id
                                   ,l_lookup_type;

        -- Delete the EEI row
        hr_utility.set_location (l_proc_name, 50);

        pay_element_extra_info_api.delete_element_extra_info
                                (p_validate                    => FALSE
                                ,p_element_type_extra_info_id  => l_eei_info_id
                                ,p_object_version_number       => l_ovn_eei);
        CLOSE csr_get_eei_info;

    END LOOP;
    CLOSE csr_get_ele_type_id;

    -- Delete Ent UDT

    IF l_entudt_id IS NOT NULL AND
       p_abse_primary_yn = 'Y'
    THEN

       OPEN csr_chk_eei_for_entudt (l_entudt_id);
       FETCH csr_chk_eei_for_entudt INTO l_exists;

       IF csr_chk_eei_for_entudt%NOTFOUND THEN

          -- Delete UDT

          hr_utility.set_location(l_proc_name, 60);

          delete_udt (p_udt_id  => l_entudt_id);

       END IF; -- End if of eei row found check...
       CLOSE csr_chk_eei_for_entudt;

   END IF; -- End if of ent udt name not null check ...

   -- Delete Cal UDT

   IF l_caludt_id IS NOT NULL AND
      p_abse_primary_yn = 'Y'
   THEN

       OPEN csr_chk_eei_for_caludt (l_caludt_id);
       FETCH csr_chk_eei_for_caludt INTO l_exists;

       IF csr_chk_eei_for_caludt%NOTFOUND THEN

          -- Delete UDT

          hr_utility.set_location(l_proc_name, 70);

          delete_udt (p_udt_id  => l_caludt_id);

       END IF; -- End if of eei row found check...
       CLOSE csr_chk_eei_for_caludt;

   END IF; -- End if of cal udt name not null check ...


    -- Delete Lookup Type

    IF l_lookup_type IS NOT NULL AND
       p_abse_primary_yn = 'Y'
    THEN

       OPEN csr_chk_eei_for_lkt (l_lookup_type);
       FETCH csr_chk_eei_for_lkt INTO l_exists;

       IF csr_chk_eei_for_lkt%NOTFOUND THEN

          -- Get Other Lookup Information

          hr_utility.set_location(l_proc_name, 75);

          get_other_lookups (p_business_group_id => p_business_group_id
	                    ,p_template_name     => l_template_name
			    ,p_days_hours        => l_days_hours
                            ,p_lookup_collection => l_lookup_collection
                            );

          -- Delete Lookup Type

          hr_utility.set_location(l_proc_name, 80);

          delete_lookup (p_lookup_type         => l_lookup_type
                        ,p_security_group_id   => p_security_group_id
                        ,p_view_application_id => 3
                        ,p_lookup_collection   => l_lookup_collection
                        );

          -- Check whether PQP_GAP_ABSENCE_TYPES_LIST lookup type
          -- has atleast one lookup code

          OPEN csr_get_lookup_code('PQP_GAP_ABSENCE_TYPES_LIST');
          FETCH csr_get_lookup_code INTO l_lookup_code;

          IF csr_get_lookup_code%NOTFOUND THEN

             -- Delete this lookup type
             hr_utility.set_location(l_proc_name, 85);

             fnd_lookup_types_pkg.delete_row
	               (x_lookup_type         => 'PQP_GAP_ABSENCE_TYPES_LIST'
	               ,x_security_group_id   => p_security_group_id
	               ,x_view_application_id => 3
	               );

          END IF; -- End if of lookup code check ...
          CLOSE csr_get_lookup_code;

       END IF; -- End if of eei row found check...
       CLOSE csr_chk_eei_for_lkt;

   END IF; -- End of of udt name not null check ...

   hr_utility.set_location(l_proc_name, 90);
 ---- Delete Links
         delete_element_links
                     ( p_business_group_id    => p_business_group_id
		      ,p_effective_start_date => p_effective_date
		      ,p_effective_end_date   => p_effective_date
                      --,p_base_name            => p_pri_ele_name
		      --,p_abs_type             => ' OMP '||l_days_hours
		      ,p_template_id          => l_template_id
		      );
 ---- Delete Links

   pay_element_template_api.delete_user_structure
     (p_validate                =>   false
     ,p_drop_formula_packages   =>   true
     ,p_template_id             =>   l_template_id);
   --

   hr_utility.set_location('Leaving :'||l_proc_name, 100);

EXCEPTION

      WHEN hr_multi_message.error_message_exist THEN
         --
         -- Catch the Multiple Message List exception which
         -- indicates API processing has been aborted because
         -- at least one message exists in the list.
         --
         hr_utility.set_location (   ' Leaving:'
                                  || l_proc_name, 40);
      WHEN OTHERS THEN
         --
         -- When Multiple Message Detection is enabled catch
         -- any Application specific or other unexpected
         -- exceptions.  Adding appropriate details to the
         -- Multiple Message List.  Otherwise re-raise the
         -- error.
         --
         IF hr_multi_message.unexpected_error_add (l_proc_name)
         THEN
            hr_utility.set_location (   ' Leaving:'
                                     || l_proc_name, 50);
            RAISE;
         END IF;

   --
END delete_user_template;


-- Procedure Creates Open Links for All Retro Elements
-- and Absence Element. This can be called from both
-- OSP and OMP Drivers as this takes the input Absence Type (l_abs_type).
-- Creates the Link if element exists. Otherwise it will ignore the elemnent.

PROCEDURE create_element_links ( p_business_group_id    IN NUMBER
 			       , p_effective_start_date IN DATE
                               , p_effective_end_date   IN DATE
			       --, p_legislation_code     IN VARCHAR2
			       --, p_base_name            IN VARCHAR2
			       --, p_abs_type             IN VARCHAR2
			       ,p_template_id           IN NUMBER
 		                ) IS
-- l_link_ele_name t_ele_name ;
 l_element_type_id pay_element_types_f.element_type_id%TYPE ;
 l_rowid VARCHAR2(100) ;
 l_element_link_id pay_element_links_f.element_link_id%TYPE ;
 l_effective_end_date DATE := p_effective_end_date ;

   --CURSOR csr_get_element_type_id (p_element_name IN VARCHAR2 ) IS
   --SELECT element_type_id
   --FROM   PAY_ELEMENT_TYPES_F
   --WHERE  element_name = p_element_name ;
  l_element_name pay_element_types_f.element_name%TYPE ;

begin

--    l_link_ele_name(1) := p_base_name||p_abs_type||'Absence' ; -- Absence
--    l_link_ele_name(2) := p_base_name||p_abs_type||'Absence Retro' ; -- Absence Retro
--    l_link_ele_name(3) := p_base_name||p_abs_type||'Pay Retro' ; -- Pay Retro
--    l_link_ele_name(4) := p_base_name||p_abs_type||'Band1 Pay Retro' ; -- Band1 Pay Retro
--    l_link_ele_name(5) := p_base_name||p_abs_type||'Band2 Pay Retro' ; -- Band2 Pay Retro
--    l_link_ele_name(6) := p_base_name||p_abs_type||'Band3 Pay Retro' ; -- Band3 Pay Retro
--    l_link_ele_name(7) := p_base_name||p_abs_type||'Band4 Pay Retro' ; -- Band4 Pay Retro


--    FOR i in 1..l_link_ele_name.COUNT
--    LOOP

--    OPEN csr_get_element_type_id ( p_element_name => l_link_ele_name(i) ) ;
--    FETCH csr_get_element_type_id INTO l_element_type_id ;

      -- hr_utility.set_location(' Element Id:'|| l_element_type_id,10 );

--    IF csr_get_element_type_id%FOUND THEN
      -- Call the Element Link API

      FOR i in csr_get_element_type_id(p_Template_id => p_template_id)
      LOOP

       OPEN csr_get_element_name(p_element_type_id => i.element_type_id);
       FETCH csr_get_element_name INTO l_element_name ;
       hr_utility.set_location(' Element Name:'||l_element_name,10 );
       CLOSE csr_get_element_name ;

       IF l_element_name like '%Absence' OR l_element_name like '%Retro' THEN

       hr_utility.set_location(' Element Name:'||l_element_name,20 );

       pay_element_links_pkg.insert_row(
                     p_rowid                        => l_rowid,
                     p_element_link_id              => l_element_link_id ,
                     p_effective_start_date         => p_effective_start_date,
                     p_effective_end_date           => l_effective_end_date ,
                     p_payroll_id                   => NULL,
                     p_job_id                       => NULL,
                     p_position_id                  => NULL,
                     p_people_group_id              => NULL,
                     p_cost_allocation_keyflex_id   => NULL,
                     p_organization_id              => NULL,
                     p_element_type_id              => i.element_type_id ,
                     p_location_id                  => NULL,
                     p_grade_id                     => NULL,
                     p_balancing_keyflex_id         => NULL,
                     p_business_group_id            => p_business_group_id,
                     p_legislation_code             => NULL, --p_legislation_code,
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

                  l_element_link_id := NULL ;
		  l_effective_end_date := p_effective_end_date ;
		  l_element_type_id := NULL ;

    END IF;

    -- CLOSE csr_get_element_type_id ;
    END LOOP ;

EXCEPTION

   WHEN OTHERS THEN
      hr_utility.set_location('Error:'||sqlerrm, 20);

END create_element_links ;


-- This Procedure Deletes the Element Links of all Retro
-- elements and Absence Element. This Procedure deletes
-- if any Element Link is there.If there is no link
-- it doesnt error out.
PROCEDURE delete_element_links
                     ( p_business_group_id    IN NUMBER
		      ,p_effective_start_date IN DATE
		      ,p_effective_end_date   IN DATE
		      --,p_base_name            IN VARCHAR2
		      --,p_abs_type             IN VARCHAR2
		      ,p_template_id          IN NUMBER
		      ) IS


     --l_link_ele_name t_ele_name ;
     --l_element_type_id pay_element_types_f.element_type_id%TYPE ;
     l_rowid VARCHAR2(100) ;
     l_element_link_id pay_element_links_f.element_link_id%TYPE ;
     l_people_group_id pay_element_links_f.people_group_id%TYPE ;
     l_effective_end_date DATE := p_effective_end_date ;

--     CURSOR csr_get_element_type_id (p_element_name IN VARCHAR2 ) IS
     --SELECT element_type_id
     --FROM   PAY_ELEMENT_TYPES_F
     --WHERE  element_name = p_element_name ;

     CURSOR csr_link_details ( p_element_type_id IN NUMBER ) IS
     SELECT rowid, element_link_id, people_group_id
     FROM   pay_element_links_f
     WHERE  element_type_id = p_element_type_id ;

--     CURSOR csr_get_element_name(p_element_type_id NUMBER)
--     IS
--     SELECT element_name
--     FROM   PAY_ELEMENT_TYPES_F
--     WHERE  element_type_id = p_element_type_id ;

     l_link_details csr_link_Details%ROWTYPE ;
     l_element_name pay_element_types_f.element_name%TYPE ;

BEGIN

    -- All Element Names are First Stored in a Record
    --

--    l_link_ele_name(1) := p_base_name||p_abs_type||'Absence' ; -- Absence
--    l_link_ele_name(2) := p_base_name||p_abs_type||'Absence Retro' ; -- Absence Retro
--    l_link_ele_name(3) := p_base_name||p_abs_type||'Pay Retro' ; -- Pay Retro
--    l_link_ele_name(4) := p_base_name||p_abs_type||'Band1 Pay Retro' ; -- Band1 Pay Retro
--    l_link_ele_name(5) := p_base_name||p_abs_type||'Band2 Pay Retro' ; -- Band2 Pay Retro
--    l_link_ele_name(6) := p_base_name||p_abs_type||'Band3 Pay Retro' ; -- Band3 Pay Retro
--    l_link_ele_name(7) := p_base_name||p_abs_type||'Band4 Pay Retro' ; -- Band4 Pay Retro

    -- Loop through all the elements
--    FOR i in 1..l_link_ele_name.count LOOP

     -- Get Element Type Id based on element Name
--      OPEN csr_get_element_type_id ( p_element_name => l_link_ele_name(i) );
--      FETCH csr_get_element_type_id INTO l_element_type_id ;

       FOR i in csr_get_element_type_id(p_template_id => p_template_id )
       LOOP
          OPEN csr_get_element_name(p_element_type_id => i.element_type_id ) ;
          FETCH csr_get_element_name INTO l_element_name ;
          hr_utility.set_location(' Element Name:'||l_element_name,10 );
	  CLOSE csr_get_element_name ;

	--IF csr_get_element_type_id%FOUND THEN

        IF l_element_name LIKE '%Absence' OR l_element_name LIKE '%Retro' THEN
        -- Get Element Link Id based on Element Type Id
         OPEN csr_link_details ( p_element_type_id =>  i.element_type_id );
	 FETCH csr_link_details INTO l_link_details ;
          l_rowid := l_link_details.rowid ;
	  l_element_link_id := l_link_details.element_link_id ;
	  l_people_group_id := l_link_details.people_group_id ;

          hr_utility.set_location(' Element Name:'||l_element_name,20 );

         IF csr_link_details%FOUND THEN
         -- Call Delete API

	 pay_element_links_pkg.delete_row
	   (
             p_rowid                 => l_rowid
            ,p_element_link_id       => l_element_link_id
            ,p_delete_mode           => 'ZAP'
            ,p_session_date          => p_effective_start_date
            ,p_validation_start_date => p_effective_start_date
            ,p_validation_end_date   => p_effective_end_date
            ,p_effective_start_date  => p_effective_start_date
            ,p_business_group_id     => p_business_group_id
            ,p_people_group_id       => l_people_group_id
	    ) ;

	 END IF ;
	 CLOSE csr_link_details ;

	END IF ;


--      CLOSE csr_get_element_type_id ;
    END LOOP ;

EXCEPTION
   WHEN OTHERS THEN
     hr_utility.set_location(' Error: '||SQLERRM, 10);

END delete_element_links ;


-- This Procedure checks if there are any Standard Rates exists
-- for the Scheme. If any exists it raises a error.
-- This shud be called before deleting a Scheme.


PROCEDURE check_ben_standard_rates_link (
                      p_business_group_id in number
                     ,p_plan_id          in number
	             ,p_element_type_id  in number ) IS

    l_exists VARCHAR2(1) ;

    CURSOR csr_chk_ele_in_ben ( p_business_group_id in number
                               ,p_plan_id          in number
	                       ,p_element_type_id  in number )
    IS
     SELECT 'X'
       FROM ben_acty_base_rt_f
      WHERE pl_id             = p_plan_id
        AND element_type_id   = p_element_type_id
        AND business_group_id = p_business_group_id ;

BEGIN

	-- Check whether elements are attached to benefits
        -- standard rate formula before deleting them

        OPEN csr_chk_ele_in_ben (
	           p_business_group_id => p_business_group_id
		  ,p_plan_id           => p_plan_id
		  ,p_element_type_id   => p_element_type_id);
        FETCH csr_chk_ele_in_ben INTO l_exists;

        IF csr_chk_ele_in_ben%FOUND THEN

            -- Raise Error
           Close csr_chk_ele_in_ben;
           hr_utility.set_message (800,'PER_74880_CHILD_RECORD');
           hr_utility.set_message_token('TYPE','Standard Rates, Table: BEN_ACTY_BASE_RT_F');
           hr_utility.raise_error;

        END IF; -- End if of element in ben check ...
        CLOSE csr_chk_ele_in_ben;

END check_ben_standard_rates_link ;



--
END pqp_gb_omp_template;


/
