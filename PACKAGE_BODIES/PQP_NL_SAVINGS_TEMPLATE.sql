--------------------------------------------------------
--  DDL for Package Body PQP_NL_SAVINGS_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_NL_SAVINGS_TEMPLATE" As
/* $Header: pqpnlsad.pkb 120.6.12010000.2 2009/07/15 12:35:04 rrajaman ship $ */

  g_proc_name   VARCHAR2(80) := '  pqp_nl_savings_template.';
  g_debug       BOOLEAN      := hr_utility.debug_enabled;

   -- ---------------------------------------------------------------------
   -- |----------------------< Create_Retro_Usages >-----------------------|
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
-- |--------------------< Create_User_Template >------------------------|
-- ---------------------------------------------------------------------
function Create_User_Template
           (p_pension_category              in Varchar2
           ,p_eligibility_model             in Varchar2
           ,p_pension_provider_id           in Number
           ,p_pension_type_id               in Number
           ,p_pension_plan_id               in Number
           ,p_deduction_method              in Varchar2
	   ,p_saving_scheme_type            in Varchar2
           ,p_arrearage_flag                in Varchar2
           ,p_partial_deductions_flag       in Varchar2
           ,p_employer_component            in Varchar2
           ,p_scheme_prefix                 in Varchar2
           ,p_reporting_name                in Varchar2
           ,p_scheme_description            in Varchar2
           ,p_termination_rule              in Varchar2
	   ,p_zvw_std_tax_chk               IN VARCHAR2
           ,p_zvw_spl_tax_chk               IN VARCHAR2
           ,p_standard_link                 in Varchar2
           ,p_effective_start_date          in Date
           ,p_effective_end_date            in Date
           ,p_security_group_id             in Number
           ,p_business_group_id             in Number
           )
   return Number is
   --
   l_template_id                 pay_shadow_element_types.template_id%type;
   l_base_element_type_id        pay_template_core_objects.core_object_id%type;
   l_er_base_element_type_id     pay_template_core_objects.core_object_id%type;
   l_source_template_id          pay_element_templates.template_id%type;
   l_object_version_number       pay_element_types_f.object_version_number%type;
   l_proc_name                   Varchar2(80) := g_proc_name || 'create_user_template';
   l_element_type_id             Number;
   l_balance_type_id             Number;
   l_eei_element_type_id         Number;
   l_ele_obj_ver_number          Number;
   l_bal_obj_ver_number          Number;
   i                             Number;
   l_eei_info_id                 Number;
   l_ovn_eei                     Number;
   l_formula_name                pay_shadow_formulas.formula_name%type;
   l_formula_id                  Number;
   l_formula_id1                 Number;
   y                             Number := 0;
   l_exists                      Varchar2(1);
   l_count                       Number := 0;
   l_shad_formula_id             Number;
   l_shad_formula_id1            Number;
   l_prem_replace_string         varchar2(5000) := ' ' ;
   l_std_link_flag               varchar2(10) := 'N';
   l_scheme_prefix               varchar2(50) := p_scheme_prefix;
   l_deduction_method            varchar2(4)  := p_deduction_method;
   l_zvw_text                    VARCHAR2(5000):= ' ' ;

   type shadow_ele_rec is record
         (element_type_id        pay_shadow_element_types.element_type_id%type
         ,object_version_number  pay_shadow_element_types.object_version_number%type
         ,reporting_name         pay_shadow_element_types.reporting_name%type
         ,description            pay_shadow_element_types.description%type
         );
   type t_shadow_ele_info is table of shadow_ele_rec
   index by Binary_Integer;
   l_shadow_element              t_shadow_ele_info;

   type t_ele_name is table of pay_element_types_f.element_name%type
   index by BINARY_INTEGER;
   l_ele_name                    t_ele_name;
   l_ele_new_name                t_ele_name;
   l_main_ele_name               t_ele_name;
   l_retro_ele_name              t_ele_name;

   type t_bal_name is table of pay_balance_types.balance_name%type
   index by BINARY_INTEGER;
   l_bal_name                    t_bal_name;
   l_bal_new_name                t_bal_name;

   type t_ele_reporting_name is table of pay_element_types_f.reporting_name%type
   index by BINARY_INTEGER;
   l_ele_reporting_name          t_ele_reporting_name;

   type t_ele_description is table of pay_element_types_f.description%type
   index by BINARY_INTEGER;
   l_ele_description             t_ele_description;

   type t_ele_pp is table of pay_element_types_f.processing_priority%type
   index by BINARY_INTEGER;
   l_ele_pp                      t_ele_pp;

   type t_eei_info is table of pay_element_type_extra_info.eei_information19%type
   index by BINARY_INTEGER;
   l_main_eei_info19             t_eei_info;
   l_retro_eei_info19            t_eei_info;

   l_ele_core_id                 pay_template_core_objects.core_object_id%type:= -1;

   -- Extra Information variables
   l_eei_information11           pay_element_type_extra_info.eei_information9%type;
   l_eei_information12           pay_element_type_extra_info.eei_information10%type;
   l_eei_information20           pay_element_type_extra_info.eei_information18%type;
   l_configuration_information4  VARCHAR2(10) := 'N' ;
   l_configuration_information5  VARCHAR2(10) := 'N' ;
   l_configuration_information6  VARCHAR2(10) := 'N' ;
   l_configuration_information7  VARCHAR2(10) := 'N' ;
   l_configuration_information9  VARCHAR2(10) := 'N' ;
   l_configuration_information10 VARCHAR2(10) := 'N' ;
   l_configuration_information11 VARCHAR2(10) := 'Y' ;
   l_configuration_information12 VARCHAR2(10) := 'N' ;
   l_configuration_information13 VARCHAR2(10) := 'N' ;
   l_configuration_information14 VARCHAR2(10) := 'N' ;
   l_configuration_information15 VARCHAR2(10) := 'N' ;
   l_configuration_information16 VARCHAR2(10) := 'N' ;
   l_configuration_information17 VARCHAR2(10) := 'N' ;
   l_configuration_information18 VARCHAR2(10) := 'N' ;
   l_configuration_information19 VARCHAR2(10) := 'N' ;
   l_configuration_information20 VARCHAR2(10) := 'N' ;

   l_ee_contribution_bal_type_id pqp_pension_types_f.ee_contribution_bal_type_id%type;
   l_er_contribution_bal_type_id pqp_pension_types_f.er_contribution_bal_type_id%type;
   l_balance_feed_Id             pay_balance_feeds_f.balance_feed_id%type;
   l_row_id                      rowid;
   l_request_id                  Number;
   l_er_request_id               Number;
   l_formula_text                varchar2(32767);
   l_formula_text1               varchar2(32767);
   l_tax_si_text                 varchar2(32767);
   l_dbi_user_name               ff_database_items.user_name%TYPE;
   --
   cursor  csr_get_ele_info (c_ele_name varchar2) is
   select  element_type_id
          ,object_version_number
     from  pay_shadow_element_types
    where  template_id    = l_template_id
      and  element_name   = c_ele_name;
   --
   cursor  csr_get_bal_info (c_bal_name varchar2) is
   select  balance_type_id
          ,object_version_number
     from  pay_shadow_balance_types
    where  template_id  = l_template_id
      and  balance_name = c_bal_name;
   --
   cursor csr_shd_ele (c_shd_elename varchar2) is
   select element_type_id, object_version_number
     from pay_shadow_element_types
    where template_id    = l_template_id
      and element_name   = c_shd_elename;
   --
   cursor csr_ipv  (c_ele_typeid     number
                   ,c_effective_date date) is
   select input_value_id
     from pay_input_values_f
    where element_type_id   = c_ele_typeid
      and business_group_id = p_business_group_id
      and name              = 'Pay Value'
      and c_effective_date between effective_start_date
                               and effective_end_date;
   --
   cursor csr_shd_ipv  (c_shd_elename varchar2) is
   select input_value_id
     from pay_shadow_input_values
    where element_type_id   =
          (Select element_type_id
              from pay_shadow_element_types
           where template_id = l_template_id
             and element_name = c_shd_elename)
      and name              = 'Percentage';
   --
   cursor csr_pty  (c_pension_type_id     number
                   ,c_effective_date date) is
   select ee_contribution_bal_type_id
     from pqp_pension_types_f
    where pension_type_id   = c_pension_type_id
      and business_group_id = p_business_group_id
      and c_effective_date between effective_start_date
                               and effective_end_date;

   cursor csr_pty1  (c_pension_type_id     number
                   ,c_effective_date date) is
   select *
     from pqp_pension_types_f
    where pension_type_id   = c_pension_type_id
      and business_group_id = p_business_group_id
      and c_effective_date between effective_start_date
                               and effective_end_date;

   cursor csr_pty2  (c_pension_type_id     number
                   ,c_effective_date date) is
   select er_contribution_bal_type_id
     from pqp_pension_types_f
    where pension_type_id   = c_pension_type_id
      and business_group_id = p_business_group_id
      and c_effective_date between effective_start_date
                               and effective_end_date;


   r_pty_rec pqp_pension_types_f%ROWTYPE;


     cursor  csr_get_formula_txt (c_formula_id number) is
     select formula_text
       from pay_shadow_formulas
      where formula_id  = c_formula_id
        and template_type = 'U';

     cursor csr_get_dbi_user_name (c_bal_type_id NUMBER) IS

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

    CURSOR chk_savings_scheme_name_cur IS
    SELECT 'x'
      FROM pay_element_type_extra_info
     WHERE eei_information_category = 'PQP_NL_SAVINGS_DEDUCTIONS'
       AND eei_information1 = p_scheme_description
       AND rownum = 1;

   l_scheme_dummy varchar2(10);
   -- ---------------------------------------------------------------------
   -- |------------------------< Get_Template_ID >-------------------------|
   -- ---------------------------------------------------------------------
   function Get_Template_ID (p_legislation_code in Varchar2)
     return Number is
     --
     l_template_name Varchar2(80);
     l_proc_name     Varchar2(72) := g_proc_name || 'get_template_id';
     --
     cursor csr_get_temp_id  is
     select template_id
       from pay_element_templates
      where template_name     = l_template_name
        and legislation_code  = p_legislation_code
        and template_type     = 'T'
        and business_group_id is null;
     --
   begin
      --
      hr_utility.set_location('Entering: '||l_proc_name, 10);
      --
      l_template_name  := 'Dutch Savings Deduction';
      --
      hr_utility.set_location(l_proc_name, 20);
      --
      for csr_get_temp_id_rec in csr_get_temp_id loop
         l_template_id   := csr_get_temp_id_rec.template_id;
      end loop;
      --
      hr_utility.set_location('Leaving: '||l_proc_name, 30);
      --
      return l_template_id;
      --
   end Get_Template_ID;


   -- ---------------------------------------------------------------------
   -- |-----------------------< Create_Pen_Sal_Bal_Feeds >-----------------|
   -- ---------------------------------------------------------------------
   procedure Create_Pen_Sal_Bal_Feeds  is
     --
     l_row_id                     rowid;
     l_balance_feed_Id            pay_balance_feeds_f.balance_feed_id%type;
     l_proc_name                  Varchar2(80) := g_proc_name ||
                                                  'Create_Pen_Sal_Bal_Feeds ';
     --
     cursor c1_get_reg_earn_feeds is
     select bc.classification_id, pbf.input_value_id,
            pbf.scale, pbf.element_type_id
      from  pay_balance_feeds_v pbf,
            pay_balance_classifications bc,
            pay_element_classifications pec
     where  nvl(pbf.balance_initialization_flag,'N') = 'N'
       and  nvl(pbf.business_group_id,
                p_business_group_id)  = p_business_group_id
       and  nvl(pbf.legislation_code, 'NL') = 'NL'
       and  pbf.balance_name                = 'Gross Salary'
       and  bc.balance_type_id              = pbf.balance_type_id
       and  bc.classification_id = pec.classification_id
       and  pec.classification_name = 'Earnings'
       and  nvl(pec.legislation_code, 'NL') = 'NL'
       order by pbf.element_name;
     --
     cursor c2_balance_type is
       select balance_type_id
       from   pay_balance_types
       where  business_group_id =  p_business_group_id
         and  balance_name in (p_scheme_prefix||' Pension Salary');
   begin
       hr_utility.set_location('Entering: '||l_proc_name, 10);
       for c1_rec in c1_get_reg_earn_feeds loop
         for c2_rec in c2_balance_type loop
           Pay_Balance_Feeds_f_pkg.Insert_Row
             (X_Rowid                => l_row_id,
              X_Balance_Feed_Id      => l_Balance_Feed_Id,
              X_Effective_Start_Date => p_effective_start_date,
              X_Effective_End_Date   => hr_api.g_eot,
              X_Business_Group_Id    => p_business_group_id,
              X_Legislation_Code     => null,
              X_Balance_Type_Id      => c2_rec.balance_type_id,
              X_Input_Value_Id       => c1_rec.input_value_id,
              X_Scale                => c1_rec.scale,
              X_Legislation_Subgroup => null,
              X_Initial_Balance_Feed => false );

              l_Balance_Feed_Id := Null;
              l_row_id          := Null;
         end loop;
       end loop;
       hr_utility.set_location('Leaving: '||l_proc_name, 70);
   end Create_Pen_Sal_Bal_Feeds ;

  begin
  -- ---------------------------------------------------------------------
  -- |-------------< Main Function : Create_User_Template Body >----------|
  -- ---------------------------------------------------------------------

   hr_utility.set_location('Entering : '||l_proc_name, 10);

   IF LENGTH(p_scheme_prefix) > 8 THEN

   -- Limit the prefix length due to DBI's
   -- generated for the element names. Max of 8 chars is allowed.
   --
     fnd_message.set_name('PQP','PQP_230300_SAV_PREFIX_LEN_ERR');
     fnd_message.raise_error;
   END IF;

   pqp_nl_pension_template.chk_scheme_prefix(p_scheme_prefix);

   hr_utility.set_location('Check unique scheme name : '||l_proc_name, 11);
    OPEN chk_savings_scheme_name_cur;
    FETCH chk_savings_scheme_name_cur INTO l_scheme_dummy;
    IF chk_savings_scheme_name_cur%FOUND THEN
       CLOSE chk_savings_scheme_name_cur;
        hr_utility.set_location('Check unique scheme name : '||l_proc_name, 12);
       fnd_message.set_name('PQP', 'PQP_230924_SCHEME_NAME_ERR');
       fnd_message.raise_error;
    ELSE
      CLOSE chk_savings_scheme_name_cur;
    END IF;

   -- ---------------------------------------------------------------------
   -- Set session date
   -- ---------------------------------------------------------------------
   pay_db_pay_setup.set_session_date(nvl(p_effective_start_date, sysdate));
   --
   hr_utility.set_location('..Setting the Session Date', 15);
   -- ---------------------------------------------------------------------
   -- Get Source Template ID
   -- ---------------------------------------------------------------------
   l_source_template_id := get_template_id
                            (p_legislation_code  => g_template_leg_code);
   -- ---------------------------------------------------------------------
   -- Exclusion rules
   -- ---------------------------------------------------------------------
   hr_utility.set_location('..Checking all the Exclusion Rules', 20);

   -- Define the exclusion_rule based on the salary calculation
   -- method.
   OPEN csr_pty1 (c_pension_type_id => p_pension_type_id
                ,c_effective_date  => p_effective_start_date);
    FETCH csr_pty1 INTO r_pty_rec;

      IF csr_pty1%notfound THEN

        fnd_message.set_name('PQP', 'PQP_230805_INV_PENSIONID');
        fnd_message.raise_error;
        CLOSE csr_pty1;

      ELSE

        -- Fixed premium amount exclusion rules
        IF p_deduction_method = 'PE' AND
           r_pty_rec.pension_basis_calc_method = '13' THEN
           l_configuration_information4 := 'Y';
           l_configuration_information5 := 'Y';
        ELSE
           l_configuration_information4 := 'N';
           l_configuration_information5 := 'N';
        END IF;

        -- Exclusion rule to make sure that both inputs are not
        -- created when the pension_basis_calc_method is 13
        IF p_employer_component = 'Y' AND
           r_pty_rec.pension_basis_calc_method  = '13' THEN
           l_configuration_information6 := 'N';
           l_configuration_information7 := 'N';
        ELSE
           IF p_employer_component = 'Y' AND
              p_deduction_method = 'PE' AND
              r_pty_rec.pension_basis_calc_method = '14' THEN
              l_configuration_information6 := 'N';
              l_configuration_information7 := 'Y';
           ELSIF p_employer_component = 'Y'AND p_deduction_method = 'FA' THEN
              l_configuration_information6 := 'Y';
              l_configuration_information7 := 'N';
           END IF;
        END IF;


        CLOSE csr_pty1;

      END IF;

      -- Exclusion rule for feeding either the Wage Saving Taxable Amount
      -- Premium Saving Taxable Amount balance

      IF p_saving_scheme_type = 'W' THEN
         l_configuration_information9  := 'Y';
      END IF;

      IF p_saving_scheme_type = 'P' THEN
         l_configuration_information10  := 'Y';
      END IF;

      -- Exclusion rule for feeding life saving scheme balances
      -- This balance is not to be fed when the scheme is
      -- Wage or Premium

      IF p_saving_scheme_type = 'L' THEN
         l_configuration_information20  := 'Y';
      END IF;

      -- exclusion rule for either removing or displaying the Override Pension
      -- Days Input Value

      IF p_deduction_method = 'PE' THEN
         l_configuration_information11  :=   'N';
      END IF;

      -- setup exclusion rules for formula results to the SI Gross Taxation Balances
      IF r_pty_rec.sig_sal_spl_tax_reduction IS NOT NULL THEN
        l_configuration_information13 := 'Y';
      END IF;

      IF r_pty_rec.sig_sal_non_tax_reduction IS NOT NULL THEN
        l_configuration_information14 := 'Y';
      END IF;

      IF r_pty_rec.sig_sal_std_tax_reduction IS NOT NULL THEN
        l_configuration_information12 := 'Y';
      END IF;

      IF r_pty_rec.std_tax_reduction IS NOT NULL THEN
        l_configuration_information15 := 'Y';
      END IF;

      IF r_pty_rec.spl_tax_reduction IS NOT NULL THEN
        l_configuration_information16 := 'Y';
      END IF;

      IF r_pty_rec.sii_std_tax_reduction IS NOT NULL THEN
        l_configuration_information17 := 'Y';
      END IF;

      IF r_pty_rec.sii_spl_tax_reduction IS NOT NULL THEN
        l_configuration_information18 := 'Y';
      END IF;

      IF r_pty_rec.sii_non_tax_reduction IS NOT NULL THEN
        l_configuration_information19 := 'Y';
      END IF;

   -- ---------------------------------------------------------------------
   -- Create user structure from the template
   -- ---------------------------------------------------------------------
   hr_utility.set_location('..Creating template User structure', 25);

   -- for savings , change the deduction method to PE for both percentage cases


   pay_element_template_api.create_user_structure
    (p_validate                      => false
    ,p_effective_date                => p_effective_start_date
    ,p_business_group_id             => p_business_group_id
    ,p_source_template_id            => l_source_template_id
    ,p_base_name                     => p_scheme_prefix
    ,p_configuration_information1    => l_deduction_method
    ,p_configuration_information2    => l_deduction_method
    ,p_configuration_information3    => p_employer_component
    ,p_configuration_information4    => l_configuration_information4
    ,p_configuration_information5    => l_configuration_information5
    ,p_configuration_information6    => l_configuration_information6
    ,p_configuration_information7    => l_configuration_information7
    ,p_configuration_information8    => p_arrearage_flag
    ,p_configuration_information9    => l_configuration_information9
    ,p_configuration_information10   => l_configuration_information10
    ,p_configuration_information11   => l_configuration_information11
    ,p_configuration_information12   => l_configuration_information12
    ,p_configuration_information13   => l_configuration_information13
    ,p_configuration_information14   => l_configuration_information14
    ,p_configuration_information15   => l_configuration_information15
    ,p_configuration_information16   => l_configuration_information16
    ,p_configuration_information17   => l_configuration_information17
    ,p_configuration_information18   => l_configuration_information18
    ,p_configuration_information19   => l_configuration_information19
    ,p_configuration_information20   => l_configuration_information20
    ,p_template_id                   => l_template_id
    ,p_object_version_number         => l_object_version_number
    );
   -- ---------------------------------------------------------------------
   -- |-------------------< Update Shadow Structure >----------------------|
   -- ---------------------------------------------------------------------
   -- Get Element Type id and update user-specified Classification,
   -- Category, Processing Type and Standard Link on Base Element
   -- as well as other element created for the Scheme
   -- ---------------------------------------------------------------------
   -- 1. <BASE NAME> Special Inputs
   for csr_rec in csr_shd_ele (p_scheme_prefix||' Special Inputs')
   loop
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix)
                                                       ||' SI';
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                       ||' Special Inputs';
   end loop;
   -- 2. <BASE NAME> Savings Deduction
   for csr_rec in csr_shd_ele (p_scheme_prefix||' Savings Deduction')
   loop
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix);
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
	                                                       ||' Savings Deduction';
   end loop;
   --  <BASE NAME> Retro Savings Deduction Current Year

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix
                              ||' Retro Savings Deduction Current Year')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
                := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
                := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
                := NVL(p_reporting_name,p_scheme_prefix)||' Retro Employee Savings CY';
    l_shadow_element(l_count).description
              := 'Element for '||p_scheme_prefix
                               ||' Retro Employee Savings Deduction CY';
   END LOOP;

   --  <BASE NAME> Retro Savings Deduction Previous Year

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix
                               ||' Retro Savings Deduction Previous Year')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
              := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
              := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
              := NVL(p_reporting_name,p_scheme_prefix)
                   ||' Retro Life Savings PY';
      l_shadow_element(l_count).description
              := 'Element for '||p_scheme_prefix
                              ||' Retro Employee Savings Deduction PY';
     END LOOP;


   -- 3. <BASE NAME> SI Gross Standard Adjustment
   for csr_rec in csr_shd_ele (p_scheme_prefix||' SI Gross Standard Adjustment')
   loop
    l_count := l_count +1;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix)
                                                       ||' SI Gross Std. Tax';
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                       ||' SI Gross Standard Adjustment';
   end loop;
   -- 4. <BASE NAME> Standard Tax Adjustment
   for csr_rec in csr_shd_ele (p_scheme_prefix||' Standard Tax Adjustment')
   loop
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix)
                                                       ||' Std. Tax';
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                       ||' Standard Tax Adjustment';
   end loop;
   -- 5. <BASE NAME> SI Income Standard Adjustment
   for csr_rec in csr_shd_ele (p_scheme_prefix||' SI Income Standard Adjustment')
   loop
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix)
                                                       ||' SI Income Std. Tax';
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                       ||' SI Income Standard Adjustment';
   end loop;
   -- 6. <BASE NAME> SI Gross Special Adjustment
   for csr_rec in csr_shd_ele (p_scheme_prefix||' SI Gross Special Adjustment')
   loop
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix)
                                                       ||' SI Gross Spl. Tax';
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                       ||' SI Gross Special Adjustment';
   end loop;
   -- 7. <BASE NAME> Special Tax Adjustment
   for csr_rec in csr_shd_ele (p_scheme_prefix||' Special Tax Adjustment')
   loop
    l_count := l_count + 1 ;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix)
                                                       ||' Spl. Tax';
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                       ||' Special Tax Adjustment';
   end loop;
   -- 8. <BASE NAME> SI Income Special Adjustment
   for csr_rec in csr_shd_ele (p_scheme_prefix||' SI Income Special Adjustment')
   loop
    l_count := l_count + 1 ;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix)
                                                       ||' SI Income Spl. Tax';
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                       ||' SI Income Special Adjustment';
   end loop;
   -- 9. <BASE NAME> SI Gross Non Tax Adjustment
   for csr_rec in csr_shd_ele (p_scheme_prefix||' SI Gross Non Tax Adjustment')
   loop
    l_count := l_count + 1 ;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix)
                                                       ||' SI Gross Non-Tax';
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                       ||' SI Gross Non Tax Adjustment';
   end loop;
   -- 10. <BASE NAME> SI Income Non Tax Adjustment
   for csr_rec in csr_shd_ele (p_scheme_prefix||' SI Income Non Tax Adjustment')
   loop
    l_count := l_count + 1 ;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix)
                                                       ||' SI Income Non-Tax';
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                        ||' SI Income Non Tax Adjustment';
   end loop;
   -- 11. <BASE NAME> Special Features
   for csr_rec in csr_shd_ele (p_scheme_prefix||' Special Features')
   loop
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix)
                                                       ||' SF';
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                       ||' Special Features';
   end loop;

   -- 12. <BASE NAME> Employer Savings Contribution
   IF p_employer_component = 'Y' THEN
      for csr_rec in csr_shd_ele (p_scheme_prefix||' Employer Savings Contribution')
      loop
       l_count := l_count + 1;
       l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
       l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
       l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix)
                                                          ||' ER Savings Contribution';
       l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                          ||' Employer Savings Contribution';
      end loop;
   END IF;

     --  <BASE NAME> Retro Employer Savings Contribution Current Year

      for csr_rec in csr_shd_ele (p_scheme_prefix||' Retro Employer Savings Contribution CY')
      loop
       l_count := l_count + 1;
       l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
       l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
       l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix)
                                                          ||' Retro ER Savings Contribution Current Year';
       l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                          ||' Retro Employer Savings Contribution CY';
      end loop;

   --  <BASE NAME> Retro Employer Savings Contribution Previous Year

      for csr_rec in csr_shd_ele (p_scheme_prefix||' Retro Employer Savings Contribution PY')
      loop
       l_count := l_count + 1;
       l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
       l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
       l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix)
                                                          ||' Retro ER Savings Contribution Previous Year';
       l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                          ||' Retro Employer Savings Contribution PY';
      end loop;

   -- 13. <BASE NAME> Tax SI Adjustment

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


   hr_utility.set_location('..Updating the scheme shadow elements', 30);
   for i in 1..l_count
   loop
     -- Set the standard link flag only for EE and ER elements
     -- if the standard link is Y
     IF UPPER(p_standard_link) = 'Y' THEN
        IF l_shadow_element(i).description LIKE '%Savings Deduction' OR
           l_shadow_element(i).description LIKE '%Employer Savings Contribution' THEN
             l_std_link_flag := 'Y';
        ELSE
             l_std_link_flag := 'N';
        END IF;
     END IF;

     pay_shadow_element_api.update_shadow_element
       (p_validate               => false
       ,p_effective_date         => p_effective_start_date
       ,p_element_type_id        => l_shadow_element(i).element_type_id
       ,p_description            => l_shadow_element(i).description
       ,p_reporting_name         => l_shadow_element(i).reporting_name
       ,p_post_termination_rule  => p_termination_rule
       ,p_standard_link_flag     => nvl(l_std_link_flag, hr_api.g_varchar2)
       ,p_object_version_number  => l_shadow_element(i).object_version_number
       );

     -- Reset the value for standard link flag.
     l_std_link_flag := 'N';

   end loop;

      --  <BASE NAME> Retro Standard Tax Adjustment Current Year

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix
                              ||' Retro Standard Tax Adjustment Current Year')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
                   := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
                    := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
                  := NVL(p_reporting_name,p_scheme_prefix)
                      ||' Retro Std. Tax Adj CY';
      l_shadow_element(l_count).description
                   := 'Element for '||p_scheme_prefix
                              ||' Retro Standard Tax Adjustment Current Year';
     END LOOP;


    --  <BASE NAME> Retro Standard Tax Adjustment Previous Year

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix
                              ||' Retro Standard Tax Adjustment Previous Year')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
                   := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
                    := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
                  := NVL(p_reporting_name,p_scheme_prefix)
                      ||' Retro Std. Tax Adj PY';
      l_shadow_element(l_count).description
                   := 'Element for '||p_scheme_prefix
                              ||' Retro Standard Tax Adjustment Previous Year';
     END LOOP;

   --  <BASE NAME> Special Tax Adjustment

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

    --  <BASE NAME> Retro Special Tax Adjustment Current Year

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix
                              ||' Retro Special Tax Adjustment Current Year')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
                   := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
                    := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
                  := NVL(p_reporting_name,p_scheme_prefix)
                      ||' Retro Spl. Tax Adj CY';
      l_shadow_element(l_count).description
                   := 'Element for '||p_scheme_prefix
                              ||' Retro Special Tax Adjustment Current Year';
     END LOOP;

    --  <BASE NAME> Retro Special Tax Adjustment Previous Year

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix
                              ||' Retro Special Tax Adjustment Previous Year')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
                   := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
                    := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
                  := NVL(p_reporting_name,p_scheme_prefix)
                      ||' Retro Spl. Tax Adj PY';
      l_shadow_element(l_count).description
                   := 'Element for '||p_scheme_prefix
                              ||' Retro Special Tax Adjustment Previous Year';
     END LOOP;

   --  <BASE NAME> ZVW Income Standard Tax Adjustment

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' ZVW Income Standard Tax Adjustment')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' ZVW Income Std. Tax Adj.';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' ZVW Income Standard Tax Adjustment';
   END LOOP;

   --  <BASE NAME> Retro ZVW Income Standard Tax Adjustment Current Year

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' Retro ZVW Income Standard Adjustment CY')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' Retro ZVW Income Std. Tax Adj. CY';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' Retro ZVW Income Standard Adjustment CY';
   END LOOP;

   --  <BASE NAME> Retro ZVW Income Standard Tax Adjustment Previous Year

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' Retro ZVW Income Standard Adjustment PY')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' Retro ZVW Income Std. Tax Adj. PY';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' ZVW Income Standard Tax Adjustment Previous Year';
   END LOOP;

   --  <BASE NAME> ZVW Income Special Tax Adjustment

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' ZVW Income Special Tax Adjustment')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' ZVW Income Spl. Tax Adj.';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' ZVW Income Special Tax Adjustment';
   END LOOP;

   --  <BASE NAME> Retro ZVW Income Special Tax Adjustment Current Year

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' Retro ZVW Income Special Adjustment CY')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' Retro ZVW Income Spl. Tax Adj. CY';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' Retro ZVW Income Special Adjustment CY';
   END LOOP;

   --  <BASE NAME> Retro ZVW Income Special Tax Adjustment Previous Year

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' Retro ZVW Income Special Adjustment PY')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' Retro ZVW Income Spl. Tax Adj. PY';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' ZVW Income Special Tax Adjustment Previous Year';
   END LOOP;

   hr_utility.set_location('..After Updating the scheme shadow elements', 50);

   hr_utility.set_location('Before updating the mandatory flag for the input value',52);
   IF p_deduction_method = 'PE' THEN
      for csr_rec in csr_shd_ipv (p_scheme_prefix||' Savings Deduction')
      loop
      --update the mandatory flag for the Percentage input value
      UPDATE pay_shadow_input_values
        SET  mandatory_flag = 'Y'
      WHERE  input_value_id = csr_rec.input_value_id;
      end loop;
    END IF;
   hr_utility.set_location('After updating the mandatory flag for the input value',54);

   -- Replace the spaces in the prefix with underscores. The formula name
   -- has underscores if the prefix name has spaces in it .
   l_scheme_prefix := upper(replace(l_scheme_prefix,' ','_'));

   -- Update Shadow formula

   l_shad_formula_id := pqp_nl_pension_template.Get_Formula_Id
                              (l_scheme_prefix||'_SAVINGS_DEDUCTION'
                                      ,p_business_group_id);


   OPEN csr_pty (c_pension_type_id => p_pension_type_id
                ,c_effective_date  => p_effective_start_date);
    FETCH csr_pty INTO l_ee_contribution_bal_type_id;

      IF csr_pty%notfound THEN
        fnd_message.set_name('PQP', 'PQP_230805_INV_PENSIONID');
        fnd_message.raise_error;
        CLOSE csr_pty;
      ELSE

         FOR temp_rec IN csr_get_formula_txt(l_shad_formula_id)
           LOOP
             l_formula_text := temp_rec.formula_text;
           END LOOP;

         FOR temp_rec IN csr_get_dbi_user_name(l_ee_contribution_bal_type_id)
           LOOP
             l_dbi_user_name := temp_rec.user_name;
             l_formula_text := replace(l_formula_text,'REPLACE_PT_EE_BAL_PER_YTD',
                          l_dbi_user_name);

             update pay_shadow_formulas
                set formula_text = l_formula_text
              where formula_id = l_shad_formula_id
                and business_group_id = p_business_group_id;

           END LOOP;
      END IF;

    CLOSE csr_pty;

-- replace the taxation and social insurance text
pqp_pension_functions.gen_dynamic_sav_formula(p_pension_type_id => p_pension_type_id
                                             ,p_effective_date => p_effective_start_date
					     ,p_formula_string => l_tax_si_text);

 FOR temp_rec IN csr_get_formula_txt(l_shad_formula_id)
 LOOP
    l_formula_text := temp_rec.formula_text;
 END LOOP;
 l_formula_text := replace(l_formula_text,'REPLACE_TAX_SI_TEXT',
                                  l_tax_si_text);

 update pay_shadow_formulas
    set formula_text = l_formula_text
 where formula_id = l_shad_formula_id
       and business_group_id = p_business_group_id;

IF p_employer_component = 'Y' AND l_configuration_information6 = 'N'
   AND l_configuration_information7 = 'N' THEN

l_prem_replace_string := '
ELSE IF Percentage WAS DEFAULTED
        AND Amount WAS DEFAULTED THEN
 /* Percentage of fixed premium amount calculation */
( ';
l_prem_replace_string := l_prem_replace_string ||'

 l_ee_pen_dedn_prem_amt =
            '|| l_scheme_prefix ||'_SAVINGS_DEDUCTION_FIXED_PREMIUM_AMOUNT_ENTRY_VALUE'
 ||'

   l_annual_prem_amt_char = '' ''
   l_ret_val = PQP_GET_PENSION_TYPE_DETAILS( Pension_Type_Id
                     ,'' ''
                     ,''ANNUAL_PREMIUM_AMOUNT''
                     ,l_annual_prem_amt_char
                     ,l_error_message)

   IF l_ret_val = 1 THEN
     (
       error_mesg = l_error_message
       return error_mesg
       )
   ELSE
    (
    /* Fixed premium amount is the least of the value
       entered on the pension type and the value entered in the
       input Fixed Premium Amount
    */
     l_ee_pen_dedn_prem_amt = LEAST(l_ee_pen_dedn_prem_amt,TO_NUMBER(l_annual_prem_amt_char))
     )

 l_ee_pen_dedn_percent  =
             '|| l_scheme_prefix ||'_SAVINGS_DEDUCTION_PERCENTAGE_ENTRY_VALUE
 l_er_prem_amt = l_ee_pen_dedn_prem_amt - l_ee_pen_dedn_prem_amt * (l_ee_pen_dedn_percent/100)
 l_fixed_prem_flag = ''Y''

 l_ret_val = PQP_PRORATE_AMOUNT ( l_er_prem_amt
                            ,''Y''
                            ,l_work_pattern
                            ,l_contrib_conv_rule
                            ,dedn_amt
                            ,l_error_message
                            ,l_proc_period_name
			    ,Override_Pension_Days)

        IF l_ret_val = 1 THEN
           (
             error_mesg = l_error_message
             return error_mesg
           )

         IF (l_ret_val = 2 AND l_tmp_decimal_realdays <> 1 )THEN
           (
              l_tmp_decimal_realdays = 1
              mesg = mesg || '''|| l_scheme_prefix || ' Employer Savings Contribution: ''
              mesg = mesg ||''Real SI Days value rounded as it is to be a whole number .''
           )
         IF (l_ret_val = 3) THEN
           (
             dedn_amt = 0
             mesg = '''||l_scheme_prefix ||' Employer Savings Contribution : ''
             mesg = mesg||'' Deduction amount cannot be calculated since ''
             mesg = mesg||''no workpattern is attached to this assignment.''
             return dedn_amt,mesg
           )
           ELSE IF(l_ret_val = 4 AND l_avg_ws1 <> 1) THEN
            (
               l_avg_ws1 = 1
               mesg = mesg||'''||l_scheme_prefix||' Employer Savings Contribution: ''
               mesg = mesg||''Average Days have been used in the proration instead ''
               mesg = mesg||''of Average Days with Work Schedules since no workpattern ''
               mesg = mesg||'' is attached to the assignment. ''
            )
)';

ELSE

l_prem_replace_string := '  ' ;

END IF;
hr_utility.set_location('leaving'||l_prem_replace_string,30);

  IF p_employer_component = 'Y' THEN

    l_shad_formula_id1 := pqp_nl_pension_template.Get_Formula_Id(l_scheme_prefix||'_EMPLOYER_SAVINGS_CONTRIBUTION'
                                      ,p_business_group_id);
  hr_utility.set_location('leaving'||l_shad_formula_id1,40);
   OPEN csr_pty2 (c_pension_type_id => p_pension_type_id
                ,c_effective_date  => p_effective_start_date);
    FETCH csr_pty2 INTO l_er_contribution_bal_type_id;
      hr_utility.set_location('leaving'||l_er_contribution_bal_type_id,50);
      IF csr_pty2%notfound THEN
        fnd_message.set_name('PQP', 'PQP_230805_INV_PENSIONID');
        fnd_message.raise_error;
        CLOSE csr_pty2;
      ELSE
         hr_utility.set_location('leaving',60);
         FOR temp_rec IN csr_get_formula_txt(l_shad_formula_id1)
           LOOP
             l_formula_text1 := temp_rec.formula_text;
           END LOOP;

         FOR temp_rec IN csr_get_dbi_user_name(l_er_contribution_bal_type_id)
           LOOP
             l_dbi_user_name := temp_rec.user_name;
             l_formula_text1 := replace(l_formula_text1,'REPLACE_PT_ER_BAL_PER_YTD',
                          l_dbi_user_name);
        hr_utility.set_location('leaving',70);
             l_formula_text1 := replace(l_formula_text1,'REPLACE_PREM_AMT_FORMULA_TEXT',
                          l_prem_replace_string);
      hr_utility.set_location('leaving',80);

             update pay_shadow_formulas
                set formula_text = l_formula_text1
              where formula_id = l_shad_formula_id1
                and business_group_id = p_business_group_id;
      hr_utility.set_location('leaving',90);
           END LOOP;
      END IF;
 --     hr_utility.trace_off;
    CLOSE csr_pty2;
  END IF;

-----------------------------------------------------
---Replacing ZVW String from the EE formula
-----------------------------------------------------

IF p_zvw_std_tax_chk = 'Y' and p_zvw_spl_tax_chk = 'N' THEN

   --
   -- Reduce just the ZVW std tax balance
   --
   l_zvw_text := '
   IF dedn_amt <= l_zvw_std_tax_bal THEN
       feed_to_zvw_std_tax = dedn_amt
   ELSE IF dedn_amt > l_zvw_std_tax_bal THEN
     (
       feed_to_zvw_std_tax = l_zvw_std_tax_bal
     ) ';
ELSIF p_zvw_std_tax_chk = 'N' and p_zvw_spl_tax_chk = 'Y' THEN

   --
   -- Reduce just the ZVW spl tax balance
   --
   l_zvw_text := '
   IF dedn_amt <= l_zvw_spl_tax_bal THEN
       feed_to_zvw_spl_tax = dedn_amt
   ELSE IF dedn_amt > l_zvw_spl_tax_bal THEN
     (
       feed_to_zvw_spl_tax = l_zvw_spl_tax_bal
     ) ';

ELSIF p_zvw_std_tax_chk = 'Y' and p_zvw_spl_tax_chk = 'Y' THEN

   --
   -- Reduce the ZVW std tax balance first and then
   -- reduce the ZVW spl tax balance
 --
   l_zvw_text := '

   IF dedn_amt <= l_zvw_std_tax_bal THEN
       feed_to_zvw_std_tax = dedn_amt
   ELSE IF dedn_amt > l_zvw_std_tax_bal THEN
     (
       feed_to_zvw_std_tax = l_zvw_std_tax_bal
       dedn_amt_temp = dedn_amt - feed_to_zvw_std_tax
       feed_to_zvw_spl_tax = LEAST(dedn_amt_temp,l_zvw_spl_tax_bal)
     ) ';

ELSIF ( p_zvw_std_tax_chk ='N' and  p_zvw_spl_tax_chk ='N')  THEN
   l_zvw_text:=' ';
END IF;


       FOR temp_rec IN csr_get_formula_txt(l_shad_formula_id)
       LOOP
          l_formula_text := temp_rec.formula_text;
       END LOOP;
       l_formula_text := REPLACE(l_formula_text,'REPLACE_ZVW_TEXT',
                                        l_zvw_text);

       UPDATE pay_shadow_formulas
          SET formula_text = l_formula_text
        WHERE formula_id = l_shad_formula_id
          AND business_group_id = p_business_group_id;



   IF g_debug THEN
      hr_utility.set_location('Done replacing Tax SI string in the formula', 51);
      hr_utility.set_location('Generating Core objects : Part - 1', 50);
   END IF;


   -- ---------------------------------------------------------------------
   -- |-------------------< Generate Core Objects >------------------------|
   -- ---------------------------------------------------------------------
   pay_element_template_api.generate_part1
    (p_validate         => false
    ,p_effective_date   => p_effective_start_date
    ,p_hr_only          => false
    ,p_hr_to_payroll    => false
    ,p_template_id      => l_template_id);
   --
   hr_utility.set_location('..After Generating Core objects : Part - 1', 50);
   --
   pay_element_template_api.generate_part2
    (p_validate         => false
    ,p_effective_date   => p_effective_start_date
    ,p_template_id      => l_template_id);
   --
   hr_utility.set_location('..After Generating Core objects : Part - 2', 50);

   -- Update some of the input values on the main element

   pqp_nl_pension_template.Update_Ipval_Defval(  p_scheme_prefix||' Savings Deduction'
                       ,'Pension Type Id'
                       ,to_char(p_pension_type_id)
		       ,p_business_group_id);

   -- Update some of the input values on the ER element
   IF p_employer_component = 'Y' THEN
      pqp_nl_pension_template.Update_Ipval_Defval(  p_scheme_prefix||' Employer Savings Contribution'
                          ,'Pension Type Id'
                          ,to_char(p_pension_type_id)
			  ,p_business_group_id);
   END IF;


   OPEN csr_pty1 (c_pension_type_id => p_pension_type_id
                ,c_effective_date  => p_effective_start_date);
    FETCH csr_pty1 INTO r_pty_rec;

      IF csr_pty1%notfound THEN
        fnd_message.set_name('PQP', 'PQP_230805_INV_PENSIONID');
        fnd_message.raise_error;
        CLOSE csr_pty1;
      ELSE
        IF p_deduction_method = 'PE'
           AND r_pty_rec.pension_basis_calc_method = '13' THEN
           IF NVL(r_pty_rec.annual_premium_amount,0) > 0 THEN
              pqp_nl_pension_template.Update_Ipval_Defval(  p_scheme_prefix||' Savings Deduction'
                          ,'Percentage'
                          ,fnd_number.number_to_canonical(r_pty_rec.ee_contribution_percent)
			  ,p_business_group_id);
              pqp_nl_pension_template.Update_Ipval_Defval(  p_scheme_prefix||' Savings Deduction'
                          ,'Fixed Premium Amount'
                          ,fnd_number.number_to_canonical(r_pty_rec.annual_premium_amount)
			  ,p_business_group_id);
           END IF;
        ELSIF p_deduction_method = 'PE' THEN
           IF NVL(r_pty_rec.ee_contribution_percent,0) > 0 THEN
              pqp_nl_pension_template.Update_Ipval_Defval(  p_scheme_prefix||' Savings Deduction'
                          ,'Percentage'
                          ,fnd_number.number_to_canonical(r_pty_rec.ee_contribution_percent)
			  ,p_business_group_id);
           END IF;

           IF (NVL(r_pty_rec.er_contribution_percent,0) > 0
              AND p_employer_component = 'Y'
              AND l_configuration_information7 = 'Y' ) THEN
              pqp_nl_pension_template.Update_Ipval_Defval(  p_scheme_prefix||' Employer Savings Contribution'
                          ,'Percentage'
                          ,fnd_number.number_to_canonical(r_pty_rec.er_contribution_percent)
			  ,p_business_group_id);
           END IF;
        END IF;
        CLOSE csr_pty1;
      END IF;

   -- ------------------------------------------------------------------------
   -- Create a row in pay_element_extra_info with all the element information
   -- ------------------------------------------------------------------------
   l_base_element_type_id := pqp_nl_pension_template.Get_Object_ID ('ELE',
                                p_scheme_prefix||' Savings Deduction',
                                p_business_group_id,
		                l_template_id);

   IF p_employer_component = 'Y' THEN

   l_er_base_element_type_id := pqp_nl_pension_template.Get_Object_ID ('ELE',
                                 p_scheme_prefix||' Employer Savings Contribution',
				 p_business_group_id,
			         l_template_id);

   END IF;

   pay_element_extra_info_api.create_element_extra_info
     (p_element_type_id          => l_base_element_type_id
     ,p_information_type         => 'PQP_NL_SAVINGS_DEDUCTIONS'
     ,p_eei_information_category => 'PQP_NL_SAVINGS_DEDUCTIONS'
     ,p_eei_information1         => p_scheme_description
     ,p_eei_information2         => to_char(p_pension_type_id)
     ,p_eei_information3         => to_char(p_pension_provider_id)
     ,p_eei_information4         => p_pension_category
     ,p_eei_information5         => p_deduction_method
     ,p_eei_information6         => p_employer_component
     ,p_eei_information7         => p_arrearage_flag
     ,p_eei_information8         => p_partial_deductions_flag
     ,p_eei_information9         => to_char(p_pension_plan_id)
     ,p_eei_information10        => p_scheme_prefix
     ,p_eei_information11        => p_saving_scheme_type
     ,p_eei_information12        => null
     ,p_eei_information13        => null
     ,p_eei_information14        => null
     ,p_eei_information15        => null
     ,p_eei_information16        => null
     ,p_eei_information17        => null
     ,p_eei_information18        => null
     ,p_eei_information19        => null
     ,p_eei_information20        => null
     ,p_element_type_extra_info_id => l_eei_info_id
     ,p_object_version_number      => l_ovn_eei);

   hr_utility.set_location('..After Creating element extra information', 50);

   -- ---------------------------------------------------------------------
   -- The base element's Pay Value should feed the EE Contribution balance
   -- for the pension scheme created.
   -- ---------------------------------------------------------------------
   for ipv_rec in csr_ipv
                   (c_ele_typeid     => l_base_element_type_id
                   ,c_effective_date => p_effective_start_date )
   loop
         open csr_pty (c_pension_type_id => p_pension_type_id
                      ,c_effective_date  => p_effective_start_date);
         fetch csr_pty into l_ee_contribution_bal_type_id;
         if csr_pty%notfound then
            fnd_message.set_name('PQP', 'PQP_230805_INV_PENSIONID');
            fnd_message.raise_error;
            close csr_pty;
         elsif l_ee_contribution_bal_type_id is null then
            fnd_message.set_name('PQP', 'PQP_230805_BAL_NOTFOUND');
            fnd_message.raise_error;
            close csr_pty;
         end if;
         close csr_pty;
         Pay_Balance_Feeds_f_pkg.Insert_Row(
          X_Rowid                => l_row_id,
          X_Balance_Feed_Id      => l_Balance_Feed_Id,
          X_Effective_Start_Date => p_effective_start_date,
          X_Effective_End_Date   => hr_api.g_eot,
          X_Business_Group_Id    => p_business_group_id,
          X_Legislation_Code     => null,
          X_Balance_Type_Id      => l_ee_contribution_bal_type_id,
          X_Input_Value_Id       => ipv_rec.input_value_id,
          X_Scale                => '1',
          X_Legislation_Subgroup => null,
          X_Initial_Balance_Feed => false );

          l_Balance_Feed_Id := null;
          l_row_id          := null;

   end loop;

   hr_utility.set_location('..After creating the balance feed for the base, Pay Value', 50);

   -- ---------------------------------------------------------------------
   -- The ER base element's Pay Value should feed the ER Contribution balance
   -- for the savings scheme created.
   -- ---------------------------------------------------------------------
IF p_employer_component = 'Y' THEN
   for ipv_rec in csr_ipv
                   (c_ele_typeid     => l_er_base_element_type_id
                   ,c_effective_date => p_effective_start_date )
   loop
         open csr_pty2 (c_pension_type_id => p_pension_type_id
                      ,c_effective_date  => p_effective_start_date);
         fetch csr_pty2 into l_er_contribution_bal_type_id;
         if csr_pty2%notfound then
            fnd_message.set_name('PQP', 'PQP_230805_INV_PENSIONID');
            fnd_message.raise_error;
            close csr_pty2;
         elsif l_er_contribution_bal_type_id is null then
            fnd_message.set_name('PQP', 'PQP_230805_BAL_NOTFOUND');
            fnd_message.raise_error;
            close csr_pty2;
         end if;
         close csr_pty2;
         Pay_Balance_Feeds_f_pkg.Insert_Row(
          X_Rowid                => l_row_id,
          X_Balance_Feed_Id      => l_Balance_Feed_Id,
          X_Effective_Start_Date => p_effective_start_date,
          X_Effective_End_Date   => hr_api.g_eot,
          X_Business_Group_Id    => p_business_group_id,
          X_Legislation_Code     => null,
          X_Balance_Type_Id      => l_er_contribution_bal_type_id,
          X_Input_Value_Id       => ipv_rec.input_value_id,
          X_Scale                => '1',
          X_Legislation_Subgroup => null,
          X_Initial_Balance_Feed => false );

          l_Balance_Feed_Id := null;
          l_row_id          := null;
   end loop;

END IF;

   hr_utility.set_location('..After creating the balance feed for the ER base, Pay Value', 51);


   Create_Retro_Usages
     (p_creator_name             => p_scheme_prefix||' Savings Deduction'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  10
     ,p_default_component        => 'Y'
     ,p_reprocess_type           => 'R'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro Savings Deduction Current Year'
     ,p_start_time_def_name      => 'Start of Current Year'
     ,p_end_time_def_name        => 'End of Time'
     ,p_business_group_id        => p_business_group_id);

  -- commented out because retro changes to the prev year are not brought
  -- forward to the current year.
  --  Create_Retro_Usages
  --   (p_creator_name             => p_scheme_prefix||' Employee Savings Deduction'
  --   ,p_creator_type             => 'ET'
  --   ,p_retro_component_priority =>  10
  --   ,p_default_component        => 'Y'
  --   ,p_reprocess_type           => 'R'
  --   ,p_retro_element_name
  --    => p_scheme_prefix||' Retro Employee Savings Deduction PY'
  --   ,p_start_time_def_name      => 'Start of Time'
  --   ,p_end_time_def_name        => 'End of Previous Year'
  --   ,p_business_group_id        => p_business_group_id);

    Create_Retro_Usages
     (p_creator_name
      => p_scheme_prefix||' Employer Savings Contribution'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  10
     ,p_default_component        => 'Y'
     ,p_reprocess_type           => 'R'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro Employer Savings Contribution CY'
     ,p_start_time_def_name      => 'Start of Current Year'
     ,p_end_time_def_name        => 'End of Time'
     ,p_business_group_id        => p_business_group_id);

  -- commented out because retro changes to the prev year are not brought
  -- forward to the current year.
  --  Create_Retro_Usages
  --   (p_creator_name
  --    => p_scheme_prefix||' Employer Savings Contribution'
  --   ,p_creator_type             => 'ET'
  --   ,p_retro_component_priority =>  10
  --   ,p_default_component        => 'Y'
  --   ,p_reprocess_type           => 'R'
  --   ,p_retro_element_name
  --    => p_scheme_prefix||' Retro Employer Savings Contribution PY'
  --   ,p_start_time_def_name      => 'Start of Time'
  --   ,p_end_time_def_name        => 'End of Previous Year'
  --   ,p_business_group_id        => p_business_group_id);

  --   Create_Retro_Usages (p_creator_name
  --    => p_scheme_prefix||' Standard Tax Adjustment'
  --   ,p_creator_type             => 'ET'
  --   ,p_retro_component_priority =>  10
  --   ,p_default_component        => 'Y'
  --   ,p_reprocess_type           => 'R'
  --   ,p_retro_element_name
  --    => p_scheme_prefix||' Retro Standard Tax Adjustment Current Year'
  --   ,p_start_time_def_name      => 'Start of Current Year'
  --   ,p_end_time_def_name        => 'End of Time'
  --   ,p_business_group_id        => p_business_group_id);

  --  Create_Retro_Usages
  --   (p_creator_name
  --    => p_scheme_prefix||' Standard Tax Adjustment'
  --   ,p_creator_type             => 'ET'
  --   ,p_retro_component_priority =>  10
  --   ,p_default_component        => 'Y'
  --   ,p_reprocess_type           => 'R'
  --   ,p_retro_element_name
  --    => p_scheme_prefix||' Retro Standard Tax Adjustment Previous Year'
  --   ,p_start_time_def_name      => 'Start of Time'
  --   ,p_end_time_def_name        => 'End of Previous Year'
  --   ,p_business_group_id        => p_business_group_id);

   --  Create_Retro_Usages (p_creator_name
   --   => p_scheme_prefix||' Special Tax Adjustment'
   --  ,p_creator_type             => 'ET'
   --  ,p_retro_component_priority =>  10
   --  ,p_default_component        => 'Y'
   --  ,p_reprocess_type           => 'R'
   --  ,p_retro_element_name
   --   => p_scheme_prefix||' Retro Special Tax Adjustment Current Year'
   --  ,p_start_time_def_name      => 'Start of Current Year'
   --  ,p_end_time_def_name        => 'End of Time'
   --  ,p_business_group_id        => p_business_group_id);

   -- Create_Retro_Usages
   --  (p_creator_name
   --   => p_scheme_prefix||' Special Tax Adjustment'
   --  ,p_creator_type             => 'ET'
   --  ,p_retro_component_priority =>  10
   --  ,p_default_component        => 'Y'
   --  ,p_reprocess_type           => 'R'
   --  ,p_retro_element_name
   --   => p_scheme_prefix||' Retro Special Tax Adjustment Previous Year'
   --  ,p_start_time_def_name      => 'Start of Time'
   --  ,p_end_time_def_name        => 'End of Previous Year'
   --  ,p_business_group_id        => p_business_group_id);

    --Create_Retro_Usages (p_creator_name
   --     => p_scheme_prefix||' ZVW Income Standard Tax Adjustment'
   --  ,p_creator_type             => 'ET'
   --  ,p_retro_component_priority =>  10
   --  ,p_default_component        => 'Y'
   --  ,p_reprocess_type           => 'R'
   --  ,p_retro_element_name
   --   => p_scheme_prefix||' Retro ZVW Income Standard Adjustment CY'
   --  ,p_start_time_def_name      => 'Start of Current Year'
   --  ,p_end_time_def_name        => 'End of Time'
   --  ,p_business_group_id        => p_business_group_id);

   -- Create_Retro_Usages
   --  (p_creator_name
   --   => p_scheme_prefix||' ZVW Income Standard Tax Adjustment'
   --  ,p_creator_type             => 'ET'
   --  ,p_retro_component_priority =>  10
   --  ,p_default_component        => 'Y'
   --  ,p_reprocess_type           => 'R'
   --  ,p_retro_element_name
   --   => p_scheme_prefix||' Retro ZVW Income Standard Adjustment PY'
   --  ,p_start_time_def_name      => 'Start of Time'
   --  ,p_end_time_def_name        => 'End of Previous Year'
   --  ,p_business_group_id        => p_business_group_id);

   --  Create_Retro_Usages (p_creator_name
   --   => p_scheme_prefix||' ZVW Income Special Tax Adjustment'
   --  ,p_creator_type             => 'ET'
   --  ,p_retro_component_priority =>  10
   --  ,p_default_component        => 'Y'
   --  ,p_reprocess_type           => 'R'
   --  ,p_retro_element_name
   --   => p_scheme_prefix||' Retro ZVW Income Special Adjustment CY'
   --  ,p_start_time_def_name      => 'Start of Current Year'
   --  ,p_end_time_def_name        => 'End of Time'
   --  ,p_business_group_id        => p_business_group_id);

   --  Create_Retro_Usages
   --  (p_creator_name
   --   => p_scheme_prefix||' ZVW Income Special Tax Adjustment'
   --  ,p_creator_type             => 'ET'
   --  ,p_retro_component_priority =>  10
   --  ,p_default_component        => 'Y'
   --  ,p_reprocess_type           => 'R'
   --  ,p_retro_element_name
   --   => p_scheme_prefix||' Retro ZVW Income Special Adjustment PY'
   --  ,p_start_time_def_name      => 'Start of Time'
   --  ,p_end_time_def_name        => 'End of Previous Year'
   --  ,p_business_group_id        => p_business_group_id);



   IF g_debug THEN
      hr_utility.set_location('Done Creating Retro Comp Usgs', 50);
   END IF;

   IF g_debug THEN
      hr_utility.set_location('Adding Event Group',60);
   END IF;

   Update_Event_Group
   (p_element_name => p_scheme_prefix||' Savings Deduction'
    ,p_business_group_id => p_business_group_id);

   Update_Event_Group
   (p_element_name => p_scheme_prefix||' Employer Savings Contribution'
    ,p_business_group_id => p_business_group_id);



   IF g_debug THEN
      hr_utility.set_location('Done Adding the Event Group', 60);
   END IF;

   -- Compile the base element's standard formula
   -- ---------------------------------------------------------------------


      pqp_nl_pension_template.Compile_Formula
        (p_element_type_id       => l_base_element_type_id
        ,p_effective_start_date  => p_effective_start_date
        ,p_scheme_prefix         => l_scheme_prefix
        ,p_business_group_id     => p_business_group_id
        ,p_request_id            => l_request_id
         );

   IF p_employer_component = 'Y' THEN

      pqp_nl_pension_template.Compile_Formula
        (p_element_type_id       => l_er_base_element_type_id
        ,p_effective_start_date  => p_effective_start_date
        ,p_scheme_prefix         => l_scheme_prefix
        ,p_business_group_id     => p_business_group_id
        ,p_request_id            => l_er_request_id
         );

   END IF;


 hr_utility.set_location('Leaving :'||l_proc_name, 190);

 return l_base_element_type_id;

end Create_User_Template;


-- ---------------------------------------------------------------------
-- |--------------------< Create_User_Template_Swi >------------------------|
-- ---------------------------------------------------------------------

function Create_User_Template_Swi
           (p_pension_category              in Varchar2
           ,p_eligibility_model             in Varchar2
           ,p_pension_provider_id           in Number
           ,p_pension_type_id               in Number
           ,p_pension_plan_id               in Number
           ,p_deduction_method              in Varchar2
	   ,p_saving_scheme_type            in Varchar2
           ,p_arrearage_flag                in Varchar2
           ,p_partial_deductions_flag       in Varchar2
           ,p_employer_component            in Varchar2
           ,p_scheme_prefix                 in Varchar2
           ,p_reporting_name                in Varchar2
           ,p_scheme_description            in Varchar2
           ,p_termination_rule              in Varchar2
	   ,p_zvw_std_tax_chk               IN VARCHAR2
           ,p_zvw_spl_tax_chk               IN VARCHAR2
           ,p_standard_link                 in Varchar2
           ,p_effective_start_date          in Date
           ,p_effective_end_date            in Date
           ,p_security_group_id             in Number
           ,p_business_group_id             in Number
           )
   return Number is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_element_type_id      number;
  --
  -- Other variables
  l_return_status varchar2(1);
  l_proc    varchar2(72) := 'Create_User_Template_Swi';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  l_element_type_id    :=    -1;
  --
  -- Issue a savepoint
  --
  savepoint Create_User_Template_Swi;
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
           (p_pension_category        =>      p_pension_category
           ,p_eligibility_model       =>      p_eligibility_model
           ,p_pension_provider_id     =>      p_pension_provider_id
           ,p_pension_type_id         =>      p_pension_type_id
           ,p_pension_plan_id         =>      p_pension_plan_id
           ,p_deduction_method        =>      p_deduction_method
	   ,p_saving_scheme_type      =>      p_saving_scheme_type
           ,p_arrearage_flag          =>      p_arrearage_flag
           ,p_partial_deductions_flag =>      p_partial_deductions_flag
           ,p_employer_component      =>      p_employer_component
           ,p_scheme_prefix           =>      p_scheme_prefix
           ,p_reporting_name          =>      p_reporting_name
           ,p_scheme_description      =>      p_scheme_description
           ,p_termination_rule        =>      p_termination_rule
	   ,p_zvw_std_tax_chk         =>      p_zvw_std_tax_chk
           ,p_zvw_spl_tax_chk         =>      p_zvw_spl_tax_chk
           ,p_standard_link           =>      p_standard_link
           ,p_effective_start_date    =>      p_effective_start_date
           ,p_effective_end_date      =>      p_effective_end_date
           ,p_security_group_id       =>      p_security_group_id
           ,p_business_group_id       =>      p_business_group_id
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
  hr_utility.set_location(' Leaving:' || l_proc,20);
  return l_element_type_id;

  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to Create_User_Template_Swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    return l_element_type_id;
    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to Create_User_Template_Swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    return l_element_type_id;
    hr_utility.set_location(' Leaving:' || l_proc,50);


END create_user_template_swi;



-- ---------------------------------------------------------------------
-- |--------------------< Delete_User_Template >------------------------|
-- ---------------------------------------------------------------------
procedure Delete_User_Template
           (p_savings_plan_id              in Number
           ,p_business_group_id            in Number
           ,p_savings_dedn_ele_name        in Varchar2
           ,p_savings_dedn_ele_type_id     in Number
           ,p_security_group_id            in Number
           ,p_effective_date               in Date
           ) is
  --
  cursor c1 is
   select template_id
     from pay_element_templates
    where base_name||' Savings Deduction'  = p_savings_dedn_ele_name
      and business_group_id = p_business_group_id
      and template_type     = 'U';

    CURSOR csr_ele_extra_info IS
    SELECT element_type_extra_info_id
          ,object_version_number
      FROM pay_element_type_extra_info
     WHERE eei_information_category = 'PQP_NL_SAVINGS_DEDUCTIONS'
       AND element_type_id = p_savings_dedn_ele_type_id;

  l_template_id   Number(9);
  l_proc          Varchar2(60) := g_proc_name||'Delete_User_Template';

begin
   hr_utility.set_location('Entering :'||l_proc, 10);
   --
   for c1_rec in c1 loop
       l_template_id := c1_rec.template_id;
   end loop;
   --
   pay_element_template_api.delete_user_structure
     (p_validate                =>   false
     ,p_drop_formula_packages   =>   true
     ,p_template_id             =>   l_template_id);
   --

   --
   -- Delete the rows in pay_element_type_extra_info
   --

   FOR temp_rec IN csr_ele_extra_info
     LOOP
       pay_element_extra_info_api.delete_element_extra_info
       (p_element_type_extra_info_id => temp_rec.element_type_extra_info_id
       ,p_object_version_number      => temp_rec.object_version_number);
     END LOOP;

   hr_utility.set_location('Leaving :'||l_proc, 50);
end Delete_User_Template;
--

-- ---------------------------------------------------------------------
-- |--------------------< Delete_User_Template_Swi >------------------------|
-- ---------------------------------------------------------------------

procedure Delete_User_Template_Swi
           (p_savings_plan_id              in Number
           ,p_business_group_id            in Number
           ,p_savings_dedn_ele_name        in Varchar2
           ,p_savings_dedn_ele_type_id     in Number
           ,p_security_group_id            in Number
           ,p_effective_date               in Date
           ) is

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_return_status varchar2(1);
  l_proc    varchar2(72) := 'Delete_User_Template_Swi';

Begin

  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint Delete_User_Template_Swi;
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
           (p_savings_plan_id           =>   p_savings_plan_id
           ,p_business_group_id         =>   p_business_group_id
           ,p_savings_dedn_ele_name     =>   p_savings_dedn_ele_name
           ,p_savings_dedn_ele_type_id  =>   p_savings_dedn_ele_type_id
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
  hr_utility.set_location(' Leaving:' || l_proc,20);

  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to Delete_User_Template_Swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to Delete_User_Template_Swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

END delete_user_template_swi;

end pqp_nl_savings_template;


/
