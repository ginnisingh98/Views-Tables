--------------------------------------------------------
--  DDL for Package Body PQP_NL_ABP_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_NL_ABP_TEMPLATE" AS
/* $Header: pqabpped.pkb 120.1.12000000.2 2007/03/02 06:28:51 niljain noship $ */

  g_proc_name         VARCHAR2(80) := '  pqp_nl_abp_template.';

-- ---------------------------------------------------------------------
-- |--------------------< Create_User_Template >------------------------|
-- ---------------------------------------------------------------------
FUNCTION Create_User_Template
           (p_pension_category              IN VARCHAR2
           ,p_pension_provider_id           IN NUMBER
           ,p_pension_type_id               IN NUMBER
           ,p_deduction_method              IN VARCHAR2
           ,p_arrearage_flag                IN VARCHAR2
           ,p_partial_deductions_flag       IN VARCHAR2  DEFAULT 'N'
           ,p_employer_component            IN VARCHAR2
           ,p_scheme_prefix                 IN VARCHAR2
           ,p_reporting_name                IN VARCHAR2
           ,p_scheme_description            IN VARCHAR2
           ,p_termination_rule              IN VARCHAR2
           ,p_standard_link                 IN VARCHAR2
           ,p_effective_start_date          IN DATE      DEFAULT NULL
           ,p_effective_end_date            IN DATE      DEFAULT NULL
           ,p_security_group_id             IN NUMBER    DEFAULT NULL
           ,p_business_group_id             IN NUMBER
           ,p_oht_applicable                IN VARCHAR2
           ,p_absence_applicable            IN VARCHAR2
           ,p_part_time_perc_calc_choice    IN VARCHAR2
           )
   RETURN NUMBER IS
   --
   TYPE shadow_ele_rec IS RECORD
         (element_type_id  pay_shadow_element_types.element_type_id%TYPE
         ,object_version_NUMBER
                           pay_shadow_element_types.object_version_NUMBER%TYPE
         ,reporting_name   pay_shadow_element_types.reporting_name%TYPE
         ,description      pay_shadow_element_types.description%TYPE
         );
   TYPE t_shadow_ele_info IS TABLE OF shadow_ele_rec
   INDEX BY Binary_Integer;

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

   l_main_eei_info19  t_eei_info;
   l_retro_eei_info19 t_eei_info;
   l_ele_core_id      pay_template_core_objects.core_object_id%TYPE:= -1;

   --
   -- Extra Information variables
   --
   l_eei_information11    pay_element_type_extra_info.eei_information9%TYPE;
   l_eei_information12    pay_element_type_extra_info.eei_information10%TYPE;
   l_eei_information20    pay_element_type_extra_info.eei_information18%TYPE;
   l_configuration_information1  VARCHAR2(10) := 'N' ;
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
   l_eei_info_id                 NUMBER;
   l_ovn_eei                     NUMBER;
   l_formula_name                pay_shadow_formulas.formula_name%TYPE;
   l_formula_id                  NUMBER;
   l_formula_id1                 NUMBER;
   y                             NUMBER := 0;
   l_exists                      VARCHAR2(1);
   l_count                       NUMBER := 0;
   l_shad_formula_id             NUMBER;
   l_shad_formula_id1            NUMBER;
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
                   ,c_effective_date date) IS
   SELECT input_value_id
     FROM pay_input_values_f
    WHERE element_type_id   = c_ele_typeid
      AND business_group_id = p_business_group_id
      AND name              = 'Pay Value'
      AND c_effective_date BETWEEN effective_start_date
                               AND effective_end_date;
   --
   CURSOR csr_pty1  (c_pension_type_id     NUMBER
                   ,c_effective_date date) IS
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
     WHERE eei_information_category = 'PQP_NL_ABP_DEDUCTION'
       AND eei_information1 = p_scheme_description
       AND ROWNUM = 1;

    CURSOR c_get_retro_bal_id(c_subcat IN varchar2
                             ,c_ee_er  IN varchar2) IS
    SELECT balance_type_id
      FROM pay_balance_types_tl
    WHERE  balance_name = 'Retro '||c_subcat||' '
                          ||c_ee_er||' Contribution'
      AND  language = 'US';

    CURSOR c_get_subcat(c_subcat IN varchar2) IS
    SELECT decode(c_subcat
                 ,'OPNP','OPNP'
                 ,'OPNP_65','OPNP65'
                 ,'OPNP_AOW','OPNPAOW'
                 ,'OPNP_W25','OPNPW25'
                 ,'OPNP_W50','OPNPW50'
                 ,'FPU_E','FPU Extra'
                 ,'FPU_R','FPU Raise'
                 ,'FPU_S','FPU Standard'
                 ,'FPU_T','FPU Total'
                 ,'FUR_S','FUR Standard'
                 ,'IPAP','IPAP'
                 ,'IPBW_H','IPBW High'
                 ,'IPBW_L','IPBW Low'
                 ,'VSG','VSG'
                 ,'FPU_B','FPU Base'
                 ,'FPU_C','FPU Composition'
                 ,'PPP','Partner Plus Pension'
                 ,'FPB','FP Basis'
                 ,'AAOP','ABP Disabiliy Pension'
                 ,c_subcat
                 )
      FROM dual;

   l_scheme_dummy VARCHAR2(10);

   -- ---------------------------------------------------------------------
   -- |----------------------< create_retro_usgs >-------------------------|
   -- ---------------------------------------------------------------------

   procedure create_retro_usgs
     (p_creator_name             varchar2,
      p_creator_type             varchar2,
      p_retro_component_priority binary_integer,
      p_default_component        varchar2,
      p_reprocess_type           varchar2,
      p_retro_element_name       varchar2 default null,
      p_start_time_def_name      varchar2 default 'Start of Time',
      p_end_time_def_name        varchar2 default 'End of Time',
      p_business_group_id        number)
   is
     l_creator_id    number;
     l_comp_name     pay_retro_components.component_name%TYPE;
     l_comp_id       pay_retro_components.retro_component_id%TYPE;
     l_comp_type     pay_retro_components.retro_type%TYPE;
     l_rc_usage_id   pay_retro_component_usages.Retro_Component_Usage_Id%TYPE;
     l_retro_ele_id  pay_element_types_f.element_type_id%TYPE;
     l_time_span_id  pay_time_spans.time_span_id%TYPE;
     l_es_usage_id   pay_element_span_usages.element_span_usage_id%TYPE;
   begin
     if  g_creator.name = p_creator_name
     and g_creator.type = p_creator_type
     then
       l_creator_id := g_creator.id;
     else
       -- Prime creator cache
       if p_creator_type = 'ET' then
         select distinct element_type_id
         into   l_creator_id
         from   pay_element_types_f
         where  element_name = p_creator_name
       --  and    legislation_code    = g_legislation_code
         and    business_group_id = p_business_group_id;
       elsif p_creator_type = 'EC' then
         select classification_id
         into   l_creator_id
         from   pay_element_classifications
         where  classification_name = p_creator_name
       --  and    legislation_code    = g_legislation_code
         and    business_group_id = p_business_group_id;
       else
         raise no_data_found;
       end if;
       g_creator.name := p_creator_name;
       g_creator.type := p_creator_type;
       g_creator.id   := l_creator_id;
     end if;
     --
     if g_component.exists(p_retro_component_priority)  then
       l_comp_name := g_component(p_retro_component_priority).name;
       l_comp_type := g_component(p_retro_component_priority).type;
       l_comp_id   := g_component(p_retro_component_priority).id;
     else
       -- prime component cache
       select rc.retro_component_id,rc.component_name, rc.retro_type
       into   l_comp_id, l_comp_name, l_comp_type
       from   pay_retro_definitions     rd,
              pay_retro_defn_components rdc,
              pay_retro_components      rc
       where  rdc.retro_component_id = rc.retro_component_id
       and    rc.legislation_code    = g_legislation_code
       and    rdc.priority           = p_retro_component_priority
       and    rd.retro_definition_id = rdc.retro_definition_id
       and    rd.legislation_code    = g_legislation_code
       and    rd.definition_name     = g_retro_def_name;
       --
       g_component(p_retro_component_priority).name := l_comp_name;
       g_component(p_retro_component_priority).type := l_comp_type;
       g_component(p_retro_component_priority).id   := l_comp_id;
     end if;
     --
     if l_comp_type = 'F' and p_reprocess_type <> 'R' then
       raise no_data_found;
     end if;
     --
     begin
       select Retro_Component_Usage_Id
       into   l_rc_usage_id
       from   pay_retro_component_usages
       where  retro_component_id = l_comp_id
       and    creator_id         = l_creator_id
       and    creator_type       = p_creator_type;
     exception when no_data_found then
       select pay_retro_component_usages_s.nextval
       into   l_rc_usage_id
       from dual;
       --

       insert into pay_retro_component_usages(
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
       values(l_rc_usage_id, l_comp_id, l_creator_id, p_creator_type,
              p_default_component, p_reprocess_type, p_business_group_id, null,
              sysdate, -1, sysdate, -1, -1, 1);
     end;
     if p_retro_element_name is not null and p_creator_type='ET' then
       if  g_component(p_retro_component_priority).start_time_def_name
                                                      = p_start_time_def_name
       and g_component(p_retro_component_priority).end_time_def_name
                                                      = p_end_time_def_name
       then
         l_time_span_id := g_component(p_retro_component_priority).time_span_id;
       else
         -- Prime cache
         select ts.time_span_id
         into   l_time_span_id
         from   pay_time_definitions s,
                pay_time_definitions e,
                pay_time_spans       ts
         where  ts.creator_id = l_comp_id
         and    ts.creator_type = 'RC'
         and    ts.start_time_def_id = s.time_definition_id
         and    ts.end_time_def_id = e.time_definition_id
         and    s.legislation_code = 'NL'
         and    s.definition_name = p_start_time_def_name
         and    e.legislation_code = 'NL'
         and    e.definition_name = p_end_time_def_name;
         g_component(p_retro_component_priority).time_span_id := l_time_span_id;
         g_component(p_retro_component_priority).start_time_def_name
                                                      := p_start_time_def_name;
         g_component(p_retro_component_priority).end_time_def_name
                                                      := p_end_time_def_name;
       end if;
       --
       select distinct element_type_id
       into   l_retro_ele_id
       from   pay_element_types_f
       where  element_name = p_retro_element_name
       and    business_group_id = p_business_group_id;
       --and    legislation_code = g_legislation_code;

       --
       begin
         select element_span_usage_id
         into   l_es_usage_id
         from   pay_element_span_usages
         where  time_span_id             = l_time_span_id
         and    retro_component_usage_id = l_rc_usage_id
         and    adjustment_type   is null;
       exception when no_data_found then
         select pay_element_span_usages_s.nextval
         into   l_es_usage_id
         from   dual;



         insert into pay_element_span_usages(
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
         values(l_es_usage_id, p_business_group_id,null, l_time_span_id,
                l_rc_usage_id, null, l_retro_ele_id,
                sysdate, -1, sysdate, -1, -1, 1);
       end;
     end if;
   exception when no_data_found then null;
   end create_retro_usgs;

   -- ---------------------------------------------------------------------
   -- |------------------------< Get_Template_ID >-------------------------|
   -- ---------------------------------------------------------------------
   FUNCTION Get_Template_ID (p_legislation_code IN VARCHAR2)
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
      hr_utility.set_location('Entering: '||l_proc_name, 10);
      --
      l_template_name  := 'ABP Pension Deduction';
      --
      hr_utility.set_location(l_proc_name, 20);
      --
      FOR csr_get_temp_id_rec IN csr_get_temp_id LOOP
         l_template_id   := csr_get_temp_id_rec.template_id;
      END LOOP;
      --
      hr_utility.set_location('Leaving: '||l_proc_name, 30);
      --
      RETURN l_template_id;
      --
   END Get_Template_ID;

   -- ---------------------------------------------------------------------
   -- |-----------------------< Create_Pen_Sal_Bal_Feeds >-----------------|
   -- ---------------------------------------------------------------------
   PROCEDURE Create_Pen_Sal_Bal_Feeds IS
     --
     l_row_id                     ROWID;
     l_balance_feed_Id            pay_balance_feeds_f.balance_feed_id%TYPE;
     l_proc_name                  VARCHAR2(80) := g_proc_name ||
                                                  'Create_Pen_Sal_Bal_Feeds ';
     --
     cursor c1_get_reg_earn_feeds is
     select bc.classification_id, pbf.input_value_id,
            pbf.scale, pbf.element_type_id
      from  pay_balance_feeds_v pbf,
            pay_balance_classifications bc,
            pay_element_classifications pec,
            pay_element_classifications_tl pect,
            pay_balance_types_tl pbtl
     where  nvl(pbf.balance_initialization_flag,'N') = 'N'
       and  nvl(pbf.business_group_id,
                p_business_group_id)        = p_business_group_id
       and  nvl(pbf.legislation_code, 'NL') = 'NL'
       and  pbtl.balance_name               = 'Gross Salary'
       and  pbtl.language                   = 'US'
       and  pbtl.balance_type_id            = pbf.balance_type_id
       and  bc.balance_type_id              = pbf.balance_type_id
       and  pec.classification_id           = pect.classification_id
       and  bc.classification_id            = pec.classification_id
       and  pect.classification_name        = 'Earnings'
       and  pect.language                   = 'US'
       and  nvl(pec.legislation_code, 'NL') = 'NL'
       order by pbf.element_name;
     --
     CURSOR c2_balance_type IS
       SELECT balance_type_id
       FROM   pay_balance_types
       WHERE  business_group_id =  p_business_group_id
         AND  balance_name IN (p_scheme_prefix||' Pension Salary');
   BEGIN
       hr_utility.set_location('Entering: '||l_proc_name, 10);
       FOR c1_rec IN c1_get_reg_earn_feeds LOOP
         FOR c2_rec IN c2_balance_type LOOP
           Pay_Balance_Feeds_f_pkg.Insert_Row
             (X_Rowid                => l_row_id,
              X_Balance_Feed_Id      => l_Balance_Feed_Id,
              X_Effective_Start_Date => p_effective_start_date,
              X_Effective_End_Date   => hr_api.g_eot,
              X_Business_Group_Id    => p_business_group_id,
              X_Legislation_Code     => NULL,
              X_Balance_Type_Id      => c2_rec.balance_type_id,
              X_Input_Value_Id       => c1_rec.input_value_id,
              X_Scale                => c1_rec.scale,
              X_Legislation_Subgroup => NULL,
              X_Initial_Balance_Feed => FALSE );

              l_Balance_Feed_Id := NULL;
              l_row_id          := NULL;
         END LOOP;
       END LOOP;
       hr_utility.set_location('Leaving: '||l_proc_name, 70);
   END Create_Pen_Sal_Bal_Feeds ;

   -- ---------------------------------------------------------------------
   -- |-----------------------< chk_scheme_validity >----------------------|
   -- ---------------------------------------------------------------------
   PROCEDURE chk_scheme_validity
     ( p_scheme_start_date    IN DATE
      ,p_scheme_end_date      IN DATE
      ,p_pension_type_id      IN pqp_pension_types_f.pension_type_id%TYPE
      ,p_pension_sub_category IN pqp_pension_types_f.pension_sub_category%TYPE
      ,p_conversion_rule  IN pqp_pension_types_f.threshold_conversion_rule%TYPE
      ,p_pension_basis_method IN pqp_pension_types_f.pension_basis_calc_method%TYPE
      ,p_business_group_id    IN NUMBER)
   IS
     --
     l_proc_name                  VARCHAR2(80) := g_proc_name ||
                                                  'chk_scheme_validity ';
     --
     CURSOR c_abp_schemes IS
     SELECT to_date(pei.eei_information10,'DD/MM/YYYY') date_from
           ,to_date(pei.eei_information11,'DD/MM/YYYY') date_to
           ,pei.eei_information1 scheme_name
       FROM pay_element_type_extra_info pei
      WHERE pei.eei_information12 = p_pension_sub_category
        AND pei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'
        AND pei.information_type         = 'PQP_NL_ABP_DEDUCTION'
        AND EXISTS( SELECT 1
                      FROM pay_element_types_f pet
                     WHERE pei.element_type_id = pet.element_type_id
                       AND pet.business_group_id = p_business_group_id);

   BEGIN
   --
   -- This procedure is used to make sure that there is only one valid
   -- ABP pension scheme for a given ABP Pension Sub Category
   -- If a new pension scheme needs to be created for the same
   -- sub category, users will have to delete the existing
   -- schemes and then create a new one.
   --

       hr_utility.set_location('Entering: '||l_proc_name, 10);

       FOR temp_rec IN c_abp_schemes
         LOOP
           IF (trunc(p_scheme_start_date) >=
               trunc(temp_rec.date_from) AND
               trunc(p_scheme_start_date) <=
               trunc(temp_rec.date_to)) THEN
                 fnd_message.set_name('PQP','PQP_230059_ABP_SCHEME_OVERLAP');
                 fnd_message.set_token('SCHM',temp_rec.scheme_name);
                 fnd_message.set_token('FROM',to_char(temp_rec.date_from));
                 fnd_message.set_token('TO',to_char(temp_rec.date_to)) ;
                 fnd_message.raise_error;
           ELSIF (trunc(p_scheme_end_date) >=
                  trunc(temp_rec.date_from) AND
                  trunc(p_scheme_end_date) <=
                  trunc(temp_rec.date_to)) THEN
                     fnd_message.set_name('PQP','PQP_230059_ABP_SCHEME_OVERLAP');
                     fnd_message.set_token('SCHM',temp_rec.scheme_name);
                     fnd_message.set_token('FROM',to_char(temp_rec.date_from));
                     fnd_message.set_token('TO',to_char(temp_rec.date_to));
                     fnd_message.raise_error;
           END IF;
         END LOOP;

       hr_utility.set_location('Leaving: '||l_proc_name, 20);

   END chk_scheme_validity ;

   -- ---------------------------------------------------------------------
   -- |---------------------< create_abp_formula_results >-----------------|
   -- ---------------------------------------------------------------------
   PROCEDURE create_abp_formula_results
    ( p_scheme_start_date    IN DATE
     ,p_scheme_end_date      IN DATE
     ,p_pension_type_id      IN pqp_pension_types_f.pension_type_id%TYPE
     ,p_pension_sub_category IN pqp_pension_types_f.pension_sub_category%TYPE
     ,p_conversion_rule   IN pqp_pension_types_f.threshold_conversion_rule%TYPE
     ,p_pension_basis_method IN pqp_pension_types_f.pension_basis_calc_method%TYPE
     ,p_abp_element_type_id  IN NUMBER
     ,p_business_group_id    IN NUMBER
     ,p_employer_component   IN VARCHAR2
    )
   IS

   -- This procedure is used to create formula results from the seeded
   -- ABP Pensions element and ABP_PENSION_INFORMATION formula combination.
   -- The results are created from the seeded element to the ABP scheme just
   -- created. This is to make sure that the contributions are passed
   -- correctly to the indirect elements created in the ABP scheme.

   l_formula_result_rule_id    NUMBER;
   l_effective_start_date      DATE;
   l_effective_end_date        DATE;
   l_object_version_number     NUMBER;
   l_status_processing_rule_id NUMBER;
   i                           NUMBER;
   l_rowid                     ROWID;
   l_abp_ele_id                NUMBER;
   l_abp_formula_id            NUMBER;
   l_subcat                    VARCHAR2(30);
   --
   TYPE r_input_result IS RECORD
     ( result_name pay_formula_result_rules_f.result_name%TYPE
      ,input_value_id pay_input_values_f.input_value_id%TYPE
     );
   --
   TYPE t_input_result IS TABLE of r_input_result INDEX BY BINARY_INTEGER;
   --
   l_input_result t_input_result ;
   --
   CURSOR c_ip_val
     ( c_element_type_id IN NUMBER
      ,c_name            IN VARCHAR2) IS
   SELECT input_value_id
     FROM pay_input_values_f
    WHERE element_type_id = c_element_type_id
      AND trunc(p_scheme_start_date) BETWEEN
            effective_start_date AND effective_end_date
      AND name = c_name ;

   CURSOR c_proc_rule IS
   SELECT psp.status_processing_rule_id
     FROM pay_status_processing_rules_f psp
         ,pay_element_types_f pet
         ,ff_formulas_f fff
    WHERE psp.element_type_id = pet.element_type_id
      AND psp.formula_id = fff.formula_id
      AND trunc(p_scheme_start_date)
           BETWEEN psp.effective_start_date AND psp.effective_end_date
      AND trunc(p_scheme_start_date)
           BETWEEN pet.effective_start_date AND pet.effective_end_date
      AND trunc(p_scheme_start_date)
           BETWEEN fff.effective_start_date AND fff.effective_end_date
      AND pet.element_name = 'ABP Pensions'
      AND pet.legislation_code = 'NL'
      AND fff.formula_name = 'ABP_PENSION_INFORMATION'
      AND fff.legislation_code = 'NL'
      AND psp.business_group_id = p_business_group_id;

  CURSOR c_abp_ele IS
  SELECT element_type_id
    FROM pay_element_types_f
   WHERE element_name = 'ABP Pensions'
     AND legislation_code = 'NL'
     AND trunc(p_scheme_start_date) BETWEEN
         effective_start_date AND effective_end_date;

  CURSOR c_abp_ff IS
  SELECT formula_id
    FROM ff_formulas_f
   WHERE formula_name = 'ABP_PENSION_INFORMATION'
     AND legislation_code = 'NL'
     AND trunc(p_scheme_start_date) BETWEEN
         effective_start_date AND effective_end_date;

  CURSOR c_encode_subcat IS
  SELECT decode(p_pension_sub_category,'FPU_B','FB',
                'FPU_C','FC','FPU_E','FE','FPU_R','FR',
                'FPU_S','FS','FPU_T','FT','FUR_S','FUS',
                'IPAP','I','IPBW_L','IL','IPBW_H','IH',
                'OPNP','O','OPNP_65','O65','OPNP_AOW','OA',
                'OPNP_W25','OW25','OPNP_W50','OW50',
                'PPP','P','VSG','V','FPB','FP','AAOP','AP')
    FROM dual;

  BEGIN

  --encode the sub category to use it in the formula result name
  OPEN c_encode_subcat;
  FETCH c_encode_subcat INTO l_subcat;
  CLOSE c_encode_subcat;

  -- Fetch the value for status_processing_rule_id
  OPEN c_proc_rule;
    FETCH c_proc_rule INTO l_status_processing_rule_id;
      IF c_proc_rule%NOTFOUND THEN
        CLOSE c_proc_rule;
        -- Create the status processing rule for this BG
        --
        -- Fetch Element Type ID
        --
        OPEN c_abp_ele;
          FETCH c_abp_ele INTO l_abp_ele_id;
            IF c_abp_ele%NOTFOUND THEN
              CLOSE c_abp_ele;
              fnd_message.raise_error;
            ELSE
                CLOSE c_abp_ele;
            END IF;
        --
        -- Fetch Formula ID
        --
        OPEN c_abp_ff;
          FETCH c_abp_ff INTO l_abp_formula_id;
            IF c_abp_ff%NOTFOUND THEN
              CLOSE c_abp_ff;
              fnd_message.raise_error;
            ELSE
                CLOSE c_abp_ff;
            END IF;

         -- Create the status processing rule for this BG
          pay_status_rules_pkg.Insert_Row
            ( X_Rowid                      => l_rowid
             ,X_Status_Processing_Rule_Id  => l_status_processing_rule_id
             ,X_Effective_Start_Date       => to_date('01/01/1951','DD/MM/RRRR')
             ,X_Effective_End_Date         => to_date('31/12/4712','DD/MM/RRRR')
             ,X_Business_Group_Id          => p_business_group_id
             ,X_Legislation_Code           => NULL
             ,X_Element_Type_Id            => l_abp_ele_id
             ,X_Assignment_Status_Type_Id  => NULL
             ,X_Formula_Id                 => l_abp_formula_id
             ,X_Processing_Rule            => 'P'
             ,X_Comment_Id                 => NULL
             ,X_Legislation_Subgroup       => NULL
             ,X_Last_Update_Date           => hr_api.g_sys
             ,X_Last_Updated_By            => -1
             ,X_Last_Update_Login          => -1
             ,X_Created_By                 => -1
             ,X_Creation_Date              => hr_api.g_sys);

      ELSE
        CLOSE c_proc_rule;
      END IF;

  -- Get I/P Value id for Contribution Type
  OPEN c_ip_val( p_abp_element_type_id
                ,'Contribution Type');
    FETCH c_ip_val INTO l_input_result(1).input_value_id;
    IF c_ip_val%NOTFOUND THEN
      CLOSE c_ip_val;
      fnd_message.raise_error;
    ELSE
      CLOSE c_ip_val;
    END IF;

  -- Get I/P Value id for Contribution Value
  OPEN c_ip_val( p_abp_element_type_id
                ,'Contribution Value');
    FETCH c_ip_val INTO l_input_result(2).input_value_id;
    IF c_ip_val%NOTFOUND THEN
      CLOSE c_ip_val;
      fnd_message.raise_error;
    ELSE
      CLOSE c_ip_val;
    END IF;

  -- Build PL/SQL Table with result_name
  IF p_employer_component = 'N' THEN
    l_input_result(1).result_name := l_subcat
                                    ||'_EE_TYP';
    l_input_result(2).result_name := l_subcat
                                    ||'_EE_VAL';
  END IF;

  IF p_employer_component = 'Y' THEN
    l_input_result(1).result_name := l_subcat
                                    ||'_ER_TYP';
    l_input_result(2).result_name := l_subcat
                                    ||'_ER_VAL';
  END IF;

  IF (p_abp_element_type_id       IS NOT NULL AND
      l_status_processing_rule_id IS NOT NULL)  THEN

  -- Create Formula Result Rules
    FOR i IN 1..2
      LOOP

      SELECT pay_formula_result_rules_s.nextval
        INTO l_formula_result_rule_id
        FROM dual;

        pay_formula_result_rules_pkg.insert_row
         (p_rowid                     => l_rowid
         ,p_formula_result_rule_id    => l_formula_result_rule_id
         ,p_effective_start_date      => p_scheme_start_date
         ,p_effective_end_date        => p_scheme_end_date
         ,p_business_group_id         => p_business_group_id
         ,p_legislation_code          => NULL
         ,p_element_type_id           => p_abp_element_type_id
         ,p_status_processing_rule_id => l_status_processing_rule_id
         ,p_result_name               => l_input_result(i).result_name
         ,p_result_rule_type          => 'I'
         ,p_legislation_subgroup      => NULL
         ,p_severity_level            => NULL
         ,p_input_value_id            => l_input_result(i).input_value_id
         ,p_session_date              => p_scheme_start_date
         ,p_created_by                => -1
         );

      END LOOP;

  END IF;

  END create_abp_formula_results;

  BEGIN
  -- ---------------------------------------------------------------------
  -- |-------------< Main Function : Create_User_Template Body >----------|
  -- ---------------------------------------------------------------------
   hr_utility.set_location('Entering : '||l_proc_name, 10);

   pqp_nl_pension_template.chk_scheme_prefix(p_scheme_prefix);

   hr_utility.set_location('Check unique scheme name : '||l_proc_name, 11);

   OPEN chk_pension_scheme_name_cur;
     FETCH chk_pension_scheme_name_cur INTO l_scheme_dummy;
       IF chk_pension_scheme_name_cur%FOUND THEN
         CLOSE chk_pension_scheme_name_cur;
         fnd_message.set_name('PQP', 'PQP_230924_SCHEME_NAME_ERR');
         fnd_message.raise_error;
       ELSE
         CLOSE chk_pension_scheme_name_cur;
       END IF;

    -- Fetch all pension type details
    OPEN csr_pty1 (c_pension_type_id => p_pension_type_id
                  ,c_effective_date  => p_effective_start_date);
    FETCH csr_pty1 INTO r_pty_rec;
    --
        IF csr_pty1%NOTFOUND THEN
        fnd_message.set_name('PQP', 'PQP_230805_INV_PENSIONID');
        fnd_message.raise_error;
        CLOSE csr_pty1;
      ELSE
        CLOSE csr_pty1;
      END IF;

     l_pension_sub_category := r_pty_rec.pension_sub_category;
     l_conversion_rule      := r_pty_rec.threshold_conversion_rule;
     l_basis_method         := r_pty_rec.pension_basis_calc_method;

     chk_scheme_validity( p_scheme_start_date    => p_effective_start_date
                         ,p_scheme_end_date      => p_effective_end_date
                         ,p_pension_type_id      => p_pension_type_id
                         ,p_pension_sub_category => l_pension_sub_category
                         ,p_conversion_rule      => l_conversion_rule
                         ,p_pension_basis_method => l_basis_method
                         ,p_business_group_id    => p_business_group_id);

   -- ---------------------------------------------------------------------
   -- Set session date
   -- ---------------------------------------------------------------------
   pay_db_pay_setup.set_session_date(NVL(p_effective_start_date, SYSDATE));
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

   -- Define the exclusion rules
   -- Employer component XRule
        IF p_employer_component = 'Y' THEN
           l_configuration_information1 := 'Y';
        ELSIF p_employer_component = 'N' THEN
           l_configuration_information1 := 'N';
        END IF;

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

        IF p_arrearage_flag IS NOT NULL THEN
           l_configuration_information10 := p_arrearage_flag;
        END IF;

   -- ---------------------------------------------------------------------
   -- Create user structure from the template
   -- ---------------------------------------------------------------------
   hr_utility.set_location('..Creating template User structure', 25);

   pay_element_template_api.create_user_structure
    (p_validate                      => FALSE
    ,p_effective_date                => p_effective_start_date
    ,p_business_group_id             => p_business_group_id
    ,p_source_template_id            => l_source_template_id
    ,p_base_name                     => p_scheme_prefix
    ,p_configuration_information1    => l_configuration_information1
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
    ,p_object_version_NUMBER         => l_object_version_NUMBER
    );
   -- ---------------------------------------------------------------------
   -- |-------------------< Update Shadow Structure >----------------------|
   -- ---------------------------------------------------------------------
   -- Get Element Type id and update user-specified Classification,
   -- Category, Processing Type and Standard Link on Base Element
   -- as well as other element created for the Scheme
   -- ---------------------------------------------------------------------

   -- 1. <BASE NAME> ABP Special Inputs

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' ABP Special Inputs')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
                := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
                := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
                := NVL(p_reporting_name,p_scheme_prefix)||' ABP SI';
    l_shadow_element(l_count).description
                := 'Element for '||p_scheme_prefix||' ABP Special Inputs';
   END LOOP;

   -- 2. <BASE NAME> ABP Pension Deduction

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' ABP Pension Deduction')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
           := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
           := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
           := NVL(p_reporting_name,p_scheme_prefix);
    l_shadow_element(l_count).description
           := 'Element for '||p_scheme_prefix||' ABP Pension Deduction';
   END LOOP;

   -- 3. <BASE NAME> SI Gross Standard Adjustment

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

   -- 4. <BASE NAME> Standard Tax Adjustment

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

   -- 5. <BASE NAME> SI Income Standard Adjustment

   FOR csr_rec IN csr_shd_ele(p_scheme_prefix||' SI Income Standard Adjustment')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' SI Income Std. Adj.';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' SI Income Standard Adjustment';
   END LOOP;

   -- 6. <BASE NAME> SI Gross Special Adjustment

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

   -- 7. <BASE NAME> Special Tax Adjustment

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

   -- 8. <BASE NAME> SI Income Special Adjustment

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' SI Income Special Adjustment')
   LOOP
    l_count := l_count + 1 ;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' SI Income Spl. Adj';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' SI Income Special Adjustment';
   END LOOP;

   -- 9. <BASE NAME> SI Gross Non Tax Adjustment

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

   -- 10. <BASE NAME> SI Income Non Tax Adjustment

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' SI Income Non Tax Adjustment')
   LOOP
    l_count := l_count + 1 ;
    l_shadow_element(l_count).element_type_id
          := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
          := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
          := NVL(p_reporting_name,p_scheme_prefix)||' SI Income Non Tax Adj.';
    l_shadow_element(l_count).description
          := 'Element for '||p_scheme_prefix||' SI Income Non Tax Adjustment';
   END LOOP;

   -- 12. <BASE NAME> ABP Employer Pension Contribution

   IF p_employer_component = 'Y' THEN
      FOR csr_rec IN csr_shd_ele (p_scheme_prefix||
                                  ' ABP Employer Pension Contribution')
      LOOP
       l_count := l_count + 1;
       l_shadow_element(l_count).element_type_id
             := csr_rec.element_type_id;
       l_shadow_element(l_count).object_version_NUMBER
             := csr_rec.object_version_NUMBER;
       l_shadow_element(l_count).reporting_name
             := NVL(p_reporting_name,p_scheme_prefix)
                ||' ABP ER Pension Contribution';
       l_shadow_element(l_count).description
             := 'Element for '||p_scheme_prefix
                              ||' ABP Employer Pension Contribution';
      END LOOP;
   END IF;

   -- 13. <BASE NAME> ABP Special Features

   FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' ABP Special Features')
   LOOP
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id
                := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_NUMBER
                := csr_rec.object_version_NUMBER;
    l_shadow_element(l_count).reporting_name
                := NVL(p_reporting_name,p_scheme_prefix)||' ABP SF';
    l_shadow_element(l_count).description
                := 'Element for '||p_scheme_prefix||' ABP Special Features';
   END LOOP;

   -- 14. <BASE NAME> Tax SI Adjustment

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

    -- 15. <BASE NAME> Retro ABP Pension Deduction Current Year

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' Retro ABP Pension Deduction Current Year')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
                   := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
                    := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
                  := NVL(p_reporting_name,p_scheme_prefix)||' Retro ABP Pension Deduction Current Year';
      l_shadow_element(l_count).description
                   := 'Element for '||p_scheme_prefix||' Retro ABP Pension Deduction Current Year';
     End LOOP;

     -- 16. <BASE NAME> Retro ABP Employer Pension Contribution Current Year

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' Retro ABP Employer Pension Contribution Current Year')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
                   := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
                    := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
                  := NVL(p_reporting_name,p_scheme_prefix)||'   Retro ABP Employer Pension Contribution Current Year';
      l_shadow_element(l_count).description
                   := 'Element for '||p_scheme_prefix||'  Retro ABP Employer Pension Contribution Current Year';
     End LOOP;

      -- 17. <BASE NAME> Retro ABP Pension Deduction Previous Year

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' Retro ABP Pension Deduction Previous Year')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
                   := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
                    := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
                  := NVL(p_reporting_name,p_scheme_prefix)||' Retro ABP Pension Deduction Previous Year';
      l_shadow_element(l_count).description
                   := 'Element for '||p_scheme_prefix||' Retro ABP Pension Deduction Previous Year';
     End LOOP;

      -- 18. <BASE NAME> Retro ABP Employer Pension Contribution Previous Year

    FOR csr_rec IN csr_shd_ele (p_scheme_prefix||' Retro ABP Employer Pension Contribution Previous Year')
    LOOP
      l_count := l_count + 1;
      l_shadow_element(l_count).element_type_id
                   := csr_rec.element_type_id;
      l_shadow_element(l_count).object_version_NUMBER
                    := csr_rec.object_version_NUMBER;
      l_shadow_element(l_count).reporting_name
                  := NVL(p_reporting_name,p_scheme_prefix)||' Retro ABP Employer Pension Contribution Previous Year';
      l_shadow_element(l_count).description
                   := 'Element for '||p_scheme_prefix||'  Retro ABP Employer Pension Contribution Previous Year';
     End LOOP;

   hr_utility.set_location('..Updating the scheme shadow elements', 30);

   FOR i IN 1..l_count
   LOOP
     pay_shadow_element_api.update_shadow_element
       (p_validate               => FALSE
       ,p_effective_date         => p_effective_start_date
       ,p_element_type_id        => l_shadow_element(i).element_type_id
       ,p_description            => l_shadow_element(i).description
       ,p_reporting_name         => l_shadow_element(i).reporting_name
       ,p_post_termination_rule  => p_termination_rule
       ,p_object_version_NUMBER  => l_shadow_element(i).object_version_NUMBER
       );

   END LOOP;

   hr_utility.set_location('..After Updating the scheme shadow elements', 50);

   -- Replace the spaces in the prefix with underscores. The formula name
   -- has underscores if the prefix name has spaces in it .

   l_scheme_prefix := UPPER(REPLACE(l_scheme_prefix,' ','_'));

   -- Update Shadow formula

   l_shad_formula_id := pqp_nl_pension_template.Get_Formula_Id
                          (l_scheme_prefix||'_ABP_PENSION_DEDUCTION'
                           ,p_business_group_id);


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
                SET formula_text = l_formula_text
              WHERE formula_id = l_shad_formula_id
                AND business_group_id = p_business_group_id;

           END LOOP;
      END IF;

       -- Replace the taxation and social insurance
       -- balance reduction text in the formula
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

--replace the text for absence correction
 IF p_absence_applicable = 'N' THEN
    l_abs_text := '';
 ELSE
    l_abs_text :=
    '/*======================= ABSENCE SECTION BEGIN =========================*/
     dedn_amt_abs = dedn_amt * l_reduction_percent/100
     dedn_amt     = dedn_amt - dedn_amt_abs
     /*======================= ABSENCE SECTION END =========================*/';
  END IF;

 FOR temp_rec IN csr_get_formula_txt(l_shad_formula_id)
 LOOP
    l_formula_text := temp_rec.formula_text;
 END LOOP;

 l_formula_text := REPLACE(l_formula_text,'REPLACE_ABSENCE_TEXT',
                                  l_abs_text);

 UPDATE pay_shadow_formulas
    SET formula_text = l_formula_text
  WHERE formula_id = l_shad_formula_id
    AND business_group_id = p_business_group_id;


  IF p_employer_component = 'Y' THEN

    l_shad_formula_id1 :=
      pqp_nl_pension_template.Get_Formula_Id
                               (l_scheme_prefix||
                                '_ABP_EMPLOYER_PENSION_CONTRIBUTION'
                                ,p_business_group_id);

      IF r_pty_rec.er_contribution_bal_type_id IS NOT NULL THEN

         FOR temp_rec IN csr_get_formula_txt(l_shad_formula_id1)
           LOOP
             l_formula_text1 := temp_rec.formula_text;
           END LOOP;

         FOR temp_rec IN
          csr_get_dbi_user_name(r_pty_rec.er_contribution_bal_type_id)
           LOOP
             l_dbi_user_name := temp_rec.user_name;
             l_formula_text1 := REPLACE(l_formula_text1,
                                        'REPLACE_PT_ER_BAL_PER_YTD',
                                        l_dbi_user_name);

             UPDATE pay_shadow_formulas
                SET formula_text = l_formula_text1
              WHERE formula_id = l_shad_formula_id1
                AND business_group_id = p_business_group_id;

           END LOOP;
      END IF;
    --replace the text for absence correction
    IF p_absence_applicable = 'N' THEN
       l_abs_text := '';
    ELSE
       l_abs_text :=
       '/*======================= ABSENCE SECTION BEGIN =========================*/
        dedn_amt = dedn_amt + '||l_scheme_prefix||'_ABSENCE_ADJUSTMENT_ASG_RUN
        /*======================= ABSENCE SECTION END =========================*/';
     END IF;

    --To replace the ABS text depending on the choice made in the UI
    FOR temp_rec IN csr_get_formula_txt(l_shad_formula_id1)
    LOOP
       l_formula_text1 := temp_rec.formula_text;
    END LOOP;
    l_formula_text1 := REPLACE(l_formula_text1,'REPLACE_ABSENCE_TEXT',
                                     l_abs_text);

    UPDATE pay_shadow_formulas
       SET formula_text = l_formula_text1
     WHERE formula_id = l_shad_formula_id1
       AND business_group_id = p_business_group_id;


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
   hr_utility.set_location('..After Generating Core objects : Part - 1', 50);
   --
   pay_element_template_api.generate_part2
    (p_validate         => FALSE
    ,p_effective_date   => p_effective_start_date
    ,p_template_id      => l_template_id);
   --
   hr_utility.set_location('..After Generating Core objects : Part - 2', 50);

   -- Update some of the input values on the main element

   pqp_nl_pension_template.Update_Ipval_Defval(
                            p_scheme_prefix||' ABP Pension Deduction'
                           ,'Pension Type Id'
                           ,TO_CHAR(p_pension_type_id)
		                   ,p_business_group_id);

   -- Update some of the input values on the ER element
   IF p_employer_component = 'Y' THEN
      pqp_nl_pension_template.Update_Ipval_Defval(
                         p_scheme_prefix||' ABP Employer Pension Contribution'
                       ,'Pension Type Id'
                       ,TO_CHAR(p_pension_type_id)
	                   ,p_business_group_id);
   END IF;


   -- ------------------------------------------------------------------------
   -- Create a row in pay_element_extra_info with all the element information
   -- ------------------------------------------------------------------------
   l_base_element_type_id := pqp_nl_pension_template.get_object_id
                                ('ELE',
                                  p_scheme_prefix||' ABP Pension Deduction',
                                  p_business_group_id,
                                  l_template_id);

   IF p_employer_component = 'Y' THEN

   l_er_base_element_type_id := pqp_nl_pension_template.get_object_id
                        ('ELE',
                          p_scheme_prefix||' ABP Employer Pension Contribution',
                          p_business_group_id,
                          l_template_id);

   END IF;

   l_cy_retro_element_type_id := pqp_nl_pension_template.get_object_id
                                ('ELE',
                                  p_scheme_prefix
                                  ||' Retro ABP Pension Deduction Current Year',
                                  p_business_group_id,
                                  l_template_id);

   l_py_retro_element_type_id := pqp_nl_pension_template.get_object_id
                                ('ELE',
                                  p_scheme_prefix
                                  ||' Retro ABP Pension Deduction Previous Year',
                                  p_business_group_id,
                                  l_template_id);

   IF p_employer_component = 'Y' THEN

   l_cy_er_retro_element_type_id := pqp_nl_pension_template.get_object_id
                        ('ELE',
                          p_scheme_prefix
                          ||' Retro ABP Employer Pension Contribution Current Year',
                          p_business_group_id,
                          l_template_id);

   l_py_er_retro_element_type_id := pqp_nl_pension_template.get_object_id
                        ('ELE',
                          p_scheme_prefix
                          ||' Retro ABP Employer Pension Contribution Previous Year',
                          p_business_group_id,
                          l_template_id);

   END IF;

   pay_element_extra_info_api.create_element_extra_info
     (p_element_type_id          => l_base_element_type_id
     ,p_information_type         => 'PQP_NL_ABP_DEDUCTION'
     ,p_eei_information_category => 'PQP_NL_ABP_DEDUCTION'
     ,p_eei_information1         => p_scheme_description
     ,p_eei_information2         => TO_CHAR(p_pension_type_id)
     ,p_eei_information3         => TO_CHAR(p_pension_provider_id)
     ,p_eei_information4         => p_pension_category
     ,p_eei_information5         => p_deduction_method
     ,p_eei_information6         => p_employer_component
     ,p_eei_information7         => p_arrearage_flag
     ,p_eei_information8         => p_partial_deductions_flag
     ,p_eei_information9         => p_scheme_prefix
     ,p_eei_information10        => to_char(p_effective_start_date,'DD/MM/YYYY')
     ,p_eei_information11        => to_char(p_effective_end_date,'DD/MM/YYYY')
     ,p_eei_information12        => l_pension_sub_category
     ,p_eei_information13        => l_conversion_rule
     ,p_eei_information14        => p_oht_applicable
     ,p_eei_information15        => p_absence_applicable
     ,p_eei_information16        => l_basis_method
     ,p_eei_information17        => p_part_time_perc_calc_choice
     ,p_eei_information18        => TO_CHAR(l_cy_retro_element_type_id)
     ,p_eei_information19        => TO_CHAR(l_py_retro_element_type_id)
     ,p_eei_information20        => TO_CHAR(l_cy_er_retro_element_type_id)
     ,p_eei_information21        => TO_CHAR(l_py_er_retro_element_type_id)
     ,p_element_type_extra_info_id => l_eei_info_id
     ,p_object_version_NUMBER      => l_ovn_eei);

   hr_utility.set_location('..After Creating element extra information', 50);

   -- ---------------------------------------------------------------------
   -- The base element's Pay Value should feed the EE Contribution balance
   -- for the pension scheme created.
   -- ---------------------------------------------------------------------
   FOR ipv_rec IN csr_ipv
                   (c_ele_typeid     => l_base_element_type_id
                   ,c_effective_date => p_effective_start_date )

   LOOP
        l_ee_contribution_bal_type_id := r_pty_rec.ee_contribution_bal_type_id;

        IF l_ee_contribution_bal_type_id IS NOT NULL THEN

          Pay_Balance_Feeds_f_pkg.Insert_Row(
            X_Rowid                => l_row_id,
            X_Balance_Feed_Id      => l_Balance_Feed_Id,
            X_Effective_Start_Date => p_effective_start_date,
            X_Effective_End_Date   => hr_api.g_eot,
            X_Business_Group_Id    => p_business_group_id,
            X_Legislation_Code     => NULL,
            X_Balance_Type_Id      => l_ee_contribution_bal_type_id,
            X_Input_Value_Id       => ipv_rec.input_value_id,
            X_Scale                => '1',
            X_Legislation_Subgroup => NULL,
            X_Initial_Balance_Feed => FALSE );

            l_Balance_Feed_Id := NULL;
            l_row_id          := NULL;

         ELSIF l_ee_contribution_bal_type_id IS NULL THEN
            fnd_message.set_name('PQP', 'PQP_230805_BAL_NOTFOUND');
            fnd_message.raise_error;
         END IF;
   hr_utility.set_location('..After creating the balance feed for
   the base, Pay Value', 50);
   END LOOP;

   /*OPEN c_get_subcat(l_pension_sub_category);
   FETCH c_get_subcat INTO l_subcat;
   CLOSE c_get_subcat;

   OPEN c_get_retro_bal_id(l_subcat,
                           'EE');
   FETCH c_get_retro_bal_id INTO l_ee_retro_bal_id;
   CLOSE c_get_retro_bal_id;

   OPEN c_get_retro_bal_id(l_subcat,
                           'ER');
   FETCH c_get_retro_bal_id INTO l_er_retro_bal_id;
   CLOSE c_get_retro_bal_id;

   -- ---------------------------------------------------------------------
   -- The retro ee element's Pay Value should feed the Retro EE Contribution
   -- balance for the sub-category of the pension scheme created.
   -- ---------------------------------------------------------------------
   FOR ipv_rec IN csr_ipv
                   (c_ele_typeid     => l_cy_retro_element_type_id
                   ,c_effective_date => p_effective_start_date )

   LOOP


        IF l_ee_retro_bal_id IS NOT NULL THEN

          Pay_Balance_Feeds_f_pkg.Insert_Row(
            X_Rowid                => l_row_id,
            X_Balance_Feed_Id      => l_Balance_Feed_Id,
            X_Effective_Start_Date => p_effective_start_date,
            X_Effective_End_Date   => hr_api.g_eot,
            X_Business_Group_Id    => p_business_group_id,
            X_Legislation_Code     => NULL,
            X_Balance_Type_Id      => l_ee_retro_bal_id,
            X_Input_Value_Id       => ipv_rec.input_value_id,
            X_Scale                => '1',
            X_Legislation_Subgroup => NULL,
            X_Initial_Balance_Feed => FALSE );

            l_Balance_Feed_Id := NULL;
            l_row_id          := NULL;

         ELSIF l_ee_retro_bal_id IS NULL THEN
            fnd_message.set_name('PQP', 'PQP_230805_BAL_NOTFOUND');
            fnd_message.raise_error;
         END IF;
   hr_utility.set_location('..After creating the balance feed for
   the ee retro element, Pay Value', 54);
   END LOOP;

   FOR ipv_rec IN csr_ipv
                   (c_ele_typeid     => l_py_retro_element_type_id
                   ,c_effective_date => p_effective_start_date )

   LOOP


        IF l_ee_retro_bal_id IS NOT NULL THEN

          Pay_Balance_Feeds_f_pkg.Insert_Row(
            X_Rowid                => l_row_id,
            X_Balance_Feed_Id      => l_Balance_Feed_Id,
            X_Effective_Start_Date => p_effective_start_date,
            X_Effective_End_Date   => hr_api.g_eot,
            X_Business_Group_Id    => p_business_group_id,
            X_Legislation_Code     => NULL,
            X_Balance_Type_Id      => l_ee_retro_bal_id,
            X_Input_Value_Id       => ipv_rec.input_value_id,
            X_Scale                => '1',
            X_Legislation_Subgroup => NULL,
            X_Initial_Balance_Feed => FALSE );

            l_Balance_Feed_Id := NULL;
            l_row_id          := NULL;

         ELSIF l_ee_retro_bal_id IS NULL THEN
            fnd_message.set_name('PQP', 'PQP_230805_BAL_NOTFOUND');
            fnd_message.raise_error;
         END IF;
   hr_utility.set_location('..After creating the balance feed for
   the ee retro element, Pay Value', 55);
   END LOOP;*/

IF p_employer_component = 'Y' THEN
   -- ---------------------------------------------------------------------
   -- The base er element's Pay Value should feed the ER Contribution balance
   -- for the pension scheme created.
   -- ---------------------------------------------------------------------
   FOR ipv_rec IN csr_ipv
                   (c_ele_typeid     => l_er_base_element_type_id
                   ,c_effective_date => p_effective_start_date )

   LOOP
        l_er_contribution_bal_type_id := r_pty_rec.er_contribution_bal_type_id;

        IF l_er_contribution_bal_type_id IS NOT NULL THEN

          Pay_Balance_Feeds_f_pkg.Insert_Row(
            X_Rowid                => l_row_id,
            X_Balance_Feed_Id      => l_Balance_Feed_Id,
            X_Effective_Start_Date => p_effective_start_date,
            X_Effective_End_Date   => hr_api.g_eot,
            X_Business_Group_Id    => p_business_group_id,
            X_Legislation_Code     => NULL,
            X_Balance_Type_Id      => l_er_contribution_bal_type_id,
            X_Input_Value_Id       => ipv_rec.input_value_id,
            X_Scale                => '1',
            X_Legislation_Subgroup => NULL,
            X_Initial_Balance_Feed => FALSE );

            l_Balance_Feed_Id := NULL;
            l_row_id          := NULL;

         ELSIF l_er_contribution_bal_type_id IS NULL THEN
            fnd_message.set_name('PQP', 'PQP_230805_BAL_NOTFOUND');
            fnd_message.raise_error;
         END IF;
   hr_utility.set_location('..After creating the balance feed for
   the er base, Pay Value', 50);
   END LOOP;

   /*-- ---------------------------------------------------------------------
   -- The ER retro element's Pay Value should feed the Retro ER Contribution
   -- balance for the sub-category of the pension scheme created.
   -- ---------------------------------------------------------------------
   FOR ipv_rec IN csr_ipv
                   (c_ele_typeid     => l_cy_er_retro_element_type_id
                   ,c_effective_date => p_effective_start_date )
   LOOP
    IF l_er_retro_bal_id IS NOT NULL THEN
             Pay_Balance_Feeds_f_pkg.Insert_Row(
          X_Rowid                => l_row_id,
          X_Balance_Feed_Id      => l_Balance_Feed_Id,
          X_Effective_Start_Date => p_effective_start_date,
          X_Effective_End_Date   => hr_api.g_eot,
          X_Business_Group_Id    => p_business_group_id,
          X_Legislation_Code     => NULL,
          X_Balance_Type_Id      => l_er_retro_bal_id,
          X_Input_Value_Id       => ipv_rec.input_value_id,
          X_Scale                => '1',
          X_Legislation_Subgroup => NULL,
          X_Initial_Balance_Feed => FALSE );

          l_Balance_Feed_Id := NULL;
          l_row_id          := NULL;

    ELSIF l_er_retro_bal_id IS NULL THEN
      fnd_message.set_name('PQP', 'PQP_230805_BAL_NOTFOUND');
      fnd_message.raise_error;
    END IF;
   hr_utility.set_location('..After creating the balance feed for the ER retro element,
                            Pay Value', 57);
 END LOOP;

   FOR ipv_rec IN csr_ipv
                   (c_ele_typeid     => l_py_er_retro_element_type_id
                   ,c_effective_date => p_effective_start_date )
   LOOP
    IF l_er_retro_bal_id IS NOT NULL THEN
             Pay_Balance_Feeds_f_pkg.Insert_Row(
          X_Rowid                => l_row_id,
          X_Balance_Feed_Id      => l_Balance_Feed_Id,
          X_Effective_Start_Date => p_effective_start_date,
          X_Effective_End_Date   => hr_api.g_eot,
          X_Business_Group_Id    => p_business_group_id,
          X_Legislation_Code     => NULL,
          X_Balance_Type_Id      => l_er_retro_bal_id,
          X_Input_Value_Id       => ipv_rec.input_value_id,
          X_Scale                => '1',
          X_Legislation_Subgroup => NULL,
          X_Initial_Balance_Feed => FALSE );

          l_Balance_Feed_Id := NULL;
          l_row_id          := NULL;

    ELSIF l_er_retro_bal_id IS NULL THEN
      fnd_message.set_name('PQP', 'PQP_230805_BAL_NOTFOUND');
      fnd_message.raise_error;
    END IF;
   hr_utility.set_location('..After creating the balance feed for the ER retro element,
                            Pay Value', 58);
 END LOOP;*/

 END IF;

   -- ---------------------------------------------------------------------
   -- Create the Retro Component usage associations between the retro and
   -- pension deduction elements
   -- ---------------------------------------------------------------------
    create_retro_usgs
     (p_creator_name             => p_scheme_prefix||' ABP Pension Deduction'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  10
     ,p_default_component        => 'Y'
     ,p_reprocess_type           => 'R'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro ABP Pension Deduction Current Year'
     ,p_start_time_def_name      => 'Start of Current Year'
     ,p_end_time_def_name        => 'End of Time'
     ,p_business_group_id        => p_business_group_id);

    create_retro_usgs
     (p_creator_name             => p_scheme_prefix||' ABP Pension Deduction'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  10
     ,p_default_component        => 'Y'
     ,p_reprocess_type           => 'R'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro ABP Pension Deduction Previous Year'
     ,p_start_time_def_name      => 'Start of Time'
     ,p_end_time_def_name        => 'End of Previous Year'
     ,p_business_group_id        => p_business_group_id);

    create_retro_usgs
     (p_creator_name
      => p_scheme_prefix||' ABP Employer Pension Contribution'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  10
     ,p_default_component        => 'Y'
     ,p_reprocess_type           => 'R'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro ABP Employer Pension Contribution Current Year'
     ,p_start_time_def_name      => 'Start of Current Year'
     ,p_end_time_def_name        => 'End of Time'
     ,p_business_group_id        => p_business_group_id);

    create_retro_usgs
     (p_creator_name
      => p_scheme_prefix||' ABP Employer Pension Contribution'
     ,p_creator_type             => 'ET'
     ,p_retro_component_priority =>  10
     ,p_default_component        => 'Y'
     ,p_reprocess_type           => 'R'
     ,p_retro_element_name
      => p_scheme_prefix||' Retro ABP Employer Pension Contribution Previous Year'
     ,p_start_time_def_name      => 'Start of Time'
     ,p_end_time_def_name        => 'End of Previous Year'
     ,p_business_group_id        => p_business_group_id);

   -- ---------------------------------------------------------------------
   -- Create the Balance feeds for the eligible comp balance
   -- ---------------------------------------------------------------------
      --Create_Pen_Sal_Bal_Feeds ;
   -- ---------------------------------------------------------------------
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

 -- ---------------------------------------------------------------------
 -- Create formula results from ABP_PENSION_INFORMATION
 -- ---------------------------------------------------------------------
 create_abp_formula_results
    ( p_scheme_start_date    => p_effective_start_date
     ,p_scheme_end_date      => p_effective_end_date
     ,p_pension_type_id      => p_pension_type_id
     ,p_pension_sub_category => l_pension_sub_category
     ,p_conversion_rule      => l_conversion_rule
     ,p_pension_basis_method => l_basis_method
     ,p_abp_element_type_id  => l_base_element_type_id
     ,p_business_group_id    => p_business_group_id
     ,p_employer_component   => 'N'
    );

 IF p_employer_component = 'Y' THEN
   create_abp_formula_results
      ( p_scheme_start_date    => p_effective_start_date
       ,p_scheme_end_date      => p_effective_end_date
       ,p_pension_type_id      => p_pension_type_id
       ,p_pension_sub_category => l_pension_sub_category
       ,p_conversion_rule      => l_conversion_rule
       ,p_pension_basis_method => l_basis_method
       ,p_abp_element_type_id  => l_er_base_element_type_id
       ,p_business_group_id    => p_business_group_id
       ,p_employer_component   => 'Y'
      );
 END IF;

 hr_utility.set_location('Leaving :'||l_proc_name, 190);

 RETURN l_base_element_type_id;

END Create_User_Template;


-- ---------------------------------------------------------------------
-- |--------------------< Create_User_Template_Swi >------------------------|
-- ---------------------------------------------------------------------
FUNCTION Create_User_Template_Swi
           (p_pension_category              IN VARCHAR2
           ,p_pension_provider_id           IN NUMBER
           ,p_pension_type_id               IN NUMBER
           ,p_deduction_method              IN VARCHAR2
           ,p_arrearage_flag                IN VARCHAR2
           ,p_partial_deductions_flag       IN VARCHAR2  DEFAULT 'N'
           ,p_employer_component            IN VARCHAR2
           ,p_scheme_prefix                 IN VARCHAR2
           ,p_reporting_name                IN VARCHAR2
           ,p_scheme_description            IN VARCHAR2
           ,p_termination_rule              IN VARCHAR2
           ,p_standard_link                 IN VARCHAR2
           ,p_effective_start_date          IN DATE      DEFAULT NULL
           ,p_effective_end_date            IN DATE      DEFAULT NULL
           ,p_security_group_id             IN NUMBER    DEFAULT NULL
           ,p_business_group_id             IN NUMBER
           ,p_oht_applicable                IN VARCHAR2
           ,p_absence_applicable            IN VARCHAR2
           ,p_part_time_perc_calc_choice    IN VARCHAR2
           )
   RETURN NUMBER IS
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_element_type_id      NUMBER;
  --
  -- Other variables
  l_return_status VARCHAR2(1);
  l_proc    VARCHAR2(72) := 'Create_User_Template_Swi';
BEGIN
  hr_utility.set_location(' Entering:' || l_proc,10);
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
           (p_pension_category           =>      p_pension_category
           ,p_pension_provider_id        =>      p_pension_provider_id
           ,p_pension_type_id            =>      p_pension_type_id
           ,p_deduction_method           =>      p_deduction_method
           ,p_arrearage_flag             =>      p_arrearage_flag
           ,p_employer_component         =>      p_employer_component
           ,p_scheme_prefix              =>      p_scheme_prefix
           ,p_reporting_name             =>      p_reporting_name
           ,p_scheme_description         =>      p_scheme_description
           ,p_termination_rule           =>      p_termination_rule
           ,p_standard_link              =>      p_standard_link
           ,p_effective_start_date       =>      p_effective_start_date
           ,p_effective_end_date         =>      p_effective_end_date
           ,p_security_group_id          =>      p_security_group_id
           ,p_business_group_id          =>      p_business_group_id
           ,p_oht_applicable             =>      p_oht_applicable
           ,p_absence_applicable         =>      p_absence_applicable
           ,p_part_time_perc_calc_choice =>      p_part_time_perc_calc_choice
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
    hr_utility.set_location(' Leaving:' || l_proc, 30);

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
       hr_utility.set_location(' Leaving:' || l_proc,40);
       RAISE;
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    RETURN l_element_type_id;
    hr_utility.set_location(' Leaving:' || l_proc,50);


END create_user_template_Swi;



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
    WHERE base_name||' ABP Pension Deduction'  = p_pension_dedn_ele_name
      AND business_group_id = p_business_group_id
      AND template_type     = 'U';

  CURSOR csr_ele_extra_info IS
  SELECT element_type_extra_info_id
        ,object_version_number ovn
    FROM pay_element_type_extra_info
   WHERE eei_information_category = 'PQP_NL_ABP_DEDUCTION'
     AND element_type_id = p_pension_dedn_ele_type_id;

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
  -- Cursor to check if the element has been processed in
  -- a payroll after the effective date given by the user
  --
  CURSOR c_ele_processed (c_in_ele_typ_id IN NUMBER) IS
  SELECT 1
    FROM pay_assignment_actions paa
        ,pay_payroll_actions    ppa
   WHERE paa.payroll_action_id    = ppa.payroll_action_id
     AND ppa.business_group_id    = p_business_group_id
     AND ppa.action_status        = 'C'
     AND paa.action_status        = 'C'
     AND ppa.effective_date       >= trunc(p_effective_date)
     AND EXISTS ( SELECT 1
                    FROM pay_run_results prr
                   WHERE prr.assignment_action_id = paa.assignment_action_id
                     AND prr.element_type_id = c_in_ele_typ_id) ;
   --
   -- Cursor to get the formula rules of an element
   --
   CURSOR c_formula_rules (c_ele_typ_id IN NUMBER) IS
   SELECT formula_result_rule_id
         ,rowid
     FROM pay_formula_result_rules_f
    WHERE element_type_id   = c_ele_typ_id
      AND result_rule_type  = 'I'
      AND business_group_id = p_business_group_id
      FOR UPDATE OF effective_end_date;

--cursor to fetch the retro component usage id for a given element type id
CURSOR c_get_retro_comp_id(c_element_type_id in number) IS
SELECT retro_component_usage_id
  FROM pay_retro_component_usages
WHERE  creator_id = c_element_type_id
  AND  creator_type = 'ET'
  AND  business_group_id = p_business_group_id;

--cursor to fetch the element span usage ids for the element type id
CURSOR c_get_element_span_id(c_retro_comp_usage_id in number) IS
SELECT element_span_usage_id
  FROM pay_element_span_usages
WHERE  retro_component_usage_id = c_retro_comp_usage_id
  AND  business_group_id = p_business_group_id;


  l_template_id   NUMBER(9);
  l_dummy         NUMBER;
  l_proc          VARCHAR2(60) := g_proc_name||'Delete_User_Template';
  l_rr_exist             BOOLEAN := FALSE;
  l_er_dedn_ele_type_id  NUMBER := -1 ;
  l_retro_comp_id  NUMBER;
  l_base_name     VARCHAR2(100);

   CURSOR c_er_ele (c_base_name IN VARCHAR2) IS
   SELECT element_type_id
     FROM pay_element_types_f
    WHERE element_name = c_base_name||' ABP Employer Pension Contribution'
      AND business_group_id = p_business_group_id
      AND trunc(p_effective_date) BETWEEN effective_start_date AND
                                          effective_end_date ;


BEGIN
   hr_utility.set_location('Entering :'||l_proc, 10);
   --

   -- Check if Run Results exist for the EE Deduction Element
   -- If Run Results exist, the pension scheme and related
   -- payroll objects cannot be deleted. Try to end date the
   -- formula results from the main ABP Formula

   OPEN c_chk_rr_exist(p_pension_dedn_ele_type_id);
     FETCH c_chk_rr_exist INTO l_dummy;
       IF c_chk_rr_exist%FOUND THEN
         CLOSE c_chk_rr_exist;
         l_rr_exist := TRUE;
       ELSIF c_chk_rr_exist%NOTFOUND THEN
         CLOSE c_chk_rr_exist;
         -- Check if Run Results exist for the EE Deduction Element
         IF l_er_dedn_ele_type_id <> -1 THEN
           OPEN c_chk_rr_exist(l_er_dedn_ele_type_id);
             FETCH c_chk_rr_exist INTO l_dummy;
               IF c_chk_rr_exist%FOUND THEN
                 CLOSE c_chk_rr_exist;
                 l_rr_exist := TRUE;
               ELSE
                 CLOSE c_chk_rr_exist;
               END IF;
         END IF;
       END IF;

--
   FOR c1_rec IN c1 LOOP
     l_base_name   := c1_rec.base_name;
     l_template_id := c1_rec.template_id;
   END LOOP;
--
-- Get the element_type_id of the ER element
--
OPEN c_er_ele(l_base_name) ;
  FETCH c_er_ele INTO l_er_dedn_ele_type_id;
    IF c_er_ele%FOUND THEN
      CLOSE c_er_ele;
    ELSIF c_er_ele%FOUND THEN
      l_er_dedn_ele_type_id    := -1;
      CLOSE c_er_ele;
    END IF;


IF NOT l_rr_exist THEN
   --
   -- Delete the formula results before deleting the other
   -- objects
   --
   FOR temp_rec IN c_formula_rules (p_pension_dedn_ele_type_id)
     LOOP
       pay_formula_result_rules_pkg.delete_row(p_rowid => temp_rec.rowid);
     END LOOP;

   IF l_er_dedn_ele_type_id <> -1  THEN
     FOR temp_rec IN c_formula_rules (l_er_dedn_ele_type_id)
       LOOP
         pay_formula_result_rules_pkg.delete_row(p_rowid => temp_rec.rowid);
       END LOOP;
   END IF;

   --
   -- Delete the retro component element spans and usages
   --
   OPEN c_get_retro_comp_id(c_element_type_id => p_pension_dedn_ele_type_id);
   FETCH c_get_retro_comp_id INTO l_retro_comp_id;
   IF c_get_retro_comp_id%FOUND THEN
      CLOSE c_get_retro_comp_id;
      --delete all the element span usages
      FOR temp_rec in c_get_element_span_id(c_retro_comp_usage_id
                                                  => l_retro_comp_id
                                                 )
      LOOP
         DELETE
           FROM pay_element_span_usages
         WHERE  element_span_usage_id = temp_rec.element_span_usage_id;
      END LOOP;
      --finally delete the retro component usage
      DELETE
        FROM pay_retro_component_usages
      WHERE  retro_component_usage_id = l_retro_comp_id;
   ELSE
      CLOSE c_get_retro_comp_id;
   END IF;

   IF l_er_dedn_ele_type_id <> -1 THEN
      OPEN c_get_retro_comp_id(c_element_type_id => l_er_dedn_ele_type_id);
      FETCH c_get_retro_comp_id INTO l_retro_comp_id;
      IF c_get_retro_comp_id%FOUND THEN
         CLOSE c_get_retro_comp_id;
         --delete all the element span usages
         FOR temp_rec in c_get_element_span_id(c_retro_comp_usage_id
                                                     => l_retro_comp_id
                                                    )
         LOOP
            DELETE
              FROM pay_element_span_usages
            WHERE  element_span_usage_id = temp_rec.element_span_usage_id;
         END LOOP;
         --finally delete the retro component usage
         DELETE
           FROM pay_retro_component_usages
         WHERE  retro_component_usage_id = l_retro_comp_id;
      ELSE
         CLOSE c_get_retro_comp_id;
      END IF;
   END IF;

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

   hr_utility.set_location('Leaving :'||l_proc, 50);

ELSIF l_rr_exist THEN
--
-- Payroll has been processed . Attempt to end date the formula
-- results and end date the scheme.
--

--
-- For the effective date provided, check if any run results exist
-- for the EE and ER deduction elements. If Results exist, raise
-- and error and prompt the user to change the effective date.
--
OPEN c_ele_processed(p_pension_dedn_ele_type_id);
  FETCH c_ele_processed INTO l_dummy;
    IF c_ele_processed%FOUND THEN
      CLOSE c_ele_processed;
      fnd_message.set_name('PQP', 'PQP_230060_CHANGE_EFFECTIVE_DT');
      fnd_message.raise_error;
    ELSIF c_ele_processed%NOTFOUND THEN
      CLOSE c_ele_processed;
    END IF;

IF l_er_dedn_ele_type_id  <> -1 THEN
  OPEN c_ele_processed(l_er_dedn_ele_type_id);
    FETCH c_ele_processed INTO l_dummy;
      IF c_ele_processed%FOUND THEN
        CLOSE c_ele_processed;
        fnd_message.set_name('PQP', 'PQP_230060_CHANGE_EFFECTIVE_DT');
        fnd_message.raise_error;
      ELSIF c_ele_processed%NOTFOUND THEN
        CLOSE c_ele_processed;
      END IF;
END IF;

  --
  -- End Date the formula results row
  --
  FOR temp_rec IN c_formula_rules (p_pension_dedn_ele_type_id)
    LOOP
      UPDATE pay_formula_result_rules_f
         SET effective_end_date     = p_effective_date
       WHERE formula_result_rule_id = temp_rec.formula_result_rule_id;
    END LOOP;

IF l_er_dedn_ele_type_id  <> -1 THEN
  FOR temp_rec IN c_formula_rules (l_er_dedn_ele_type_id)
    LOOP
      UPDATE pay_formula_result_rules_f
         SET effective_end_date     = p_effective_date
       WHERE formula_result_rule_id = temp_rec.formula_result_rule_id;
    END LOOP;
END IF;
  --
  -- End Date the Schemes Row on the EIT.
  --
  FOR temp_rec IN csr_ele_extra_info
    LOOP
     pay_element_extra_info_api.update_element_extra_info
      (p_validate                   => FALSE
      ,p_element_type_extra_info_id => temp_rec.element_type_extra_info_id
      ,p_object_version_number      => temp_rec.ovn
      ,p_eei_information_category   => 'PQP_NL_ABP_DEDUCTION'
      ,p_eei_information11          => to_char(p_effective_date,'DD/MM/YYYY')
      );
    END LOOP;

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
           ,p_effective_date               IN Date
           ) IS

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_return_status VARCHAR2(1);
  l_proc    VARCHAR2(72) := 'Delete_User_Template_Swi';
BEGIN
  hr_utility.set_location(' Entering:' || l_proc,10);
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
  hr_utility.set_location(' Leaving:' || l_proc,20);

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
    hr_utility.set_location(' Leaving:' || l_proc, 30);

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
       hr_utility.set_location(' Leaving:' || l_proc,40);
       RAISE;
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

END delete_user_template_swi;

--

END pqp_nl_abp_template;

/
