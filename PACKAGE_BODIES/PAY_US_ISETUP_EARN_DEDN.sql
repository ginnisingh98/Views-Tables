--------------------------------------------------------
--  DDL for Package Body PAY_US_ISETUP_EARN_DEDN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_ISETUP_EARN_DEDN" AS
/* $Header: pyusisetup.pkb 120.4 2005/08/25 19:29:56 ndorai noship $ */
-----------------------------------------------------------------------------
--                       CREATE_ISETUP_EARN_ELEMENT
-----------------------------------------------------------------------------
FUNCTION create_isetup_earn_element
         (p_ele_name              in varchar2
         ,p_ele_reporting_name    in varchar2
         ,p_ele_description       in varchar2
         ,p_ele_classification    in varchar2
         ,p_ele_category          in varchar2
         ,p_ele_ot_base           in varchar2
         ,p_flsa_hours            in varchar2
         ,p_ele_processing_type   in varchar2
         ,p_ele_priority          in number
         ,p_ele_standard_link     in varchar2
         ,p_ele_calc_ff_id        in number
         ,p_ele_calc_ff_name      in varchar2
         ,p_sep_check_option      in varchar2
         ,p_dedn_proc             in varchar2
         ,p_mix_flag              in varchar2
         ,p_reduce_regular        in varchar2
         ,p_ele_eff_start_date    in date
         ,p_ele_eff_end_date      in date
         ,p_alien_supp_category   in varchar2
         ,p_bg_id                 in number
         ,p_termination_rule      in varchar2 default 'F'
         ,p_grossup_chk           in varchar2
         ,p_legislation_code      in varchar2
         )
   RETURN NUMBER is
   --
   l_ele_type_id   number;
   l_proc          varchar2(50) := 'pay_iSetup_earn_dedn';

BEGIN
   --
 IF p_grossup_chk = 'N' THEN
   IF p_ele_classification = 'Alien/Expat Earnings' THEN
      --
      l_ele_type_id := pqp_earnings_template.create_ele_template_objects
          (p_ele_name            =>  p_ele_name
          ,p_ele_reporting_name  =>  p_ele_reporting_name
          ,p_ele_description     =>  p_ele_description
          ,p_ele_classification  =>  p_ele_classification
          ,p_ele_category        =>  p_ele_category
          ,p_ele_processing_type =>  p_ele_processing_type
          ,p_ele_priority        =>  p_ele_priority
          ,p_ele_standard_link   =>  p_ele_standard_link
          ,p_ele_ot_base         =>  p_ele_ot_base
          ,p_flsa_hours          =>  p_flsa_hours
          ,p_ele_calc_ff_name    =>  p_ele_calc_ff_name
          ,p_sep_check_option    =>  p_sep_check_option
          ,p_dedn_proc           =>  p_dedn_proc
          ,p_reduce_regular      =>  p_reduce_regular
          ,p_ele_eff_start_date  =>  p_ele_eff_start_date
          ,p_ele_eff_end_date    =>  p_ele_eff_end_date
          ,p_supp_category       =>  p_alien_supp_category
          ,p_legislation_code    =>  'US'
          ,p_bg_id               =>  p_bg_id
          ,p_termination_rule      => p_termination_rule
          );
      hr_utility.set_location(l_proc, 10);
      --
   ELSE
      l_ele_type_id := hr_user_init_earn.do_insertions
         (p_ele_name              => p_ele_name
         ,p_ele_reporting_name    => p_ele_reporting_name
         ,p_ele_description       => p_ele_description
         ,p_ele_classification    => p_ele_classification
         ,p_ele_category          => p_ele_category
         ,p_ele_ot_base           => p_ele_ot_base
         ,p_flsa_hours            => p_flsa_hours
         ,p_ele_processing_type   => p_ele_processing_type
         ,p_ele_priority          => p_ele_priority
         ,p_ele_standard_link     => p_ele_standard_link
         ,p_ele_calc_ff_id        => p_ele_calc_ff_id
         ,p_ele_calc_ff_name      => p_ele_calc_ff_name
         ,p_sep_check_option      => p_sep_check_option
         ,p_dedn_proc             => p_dedn_proc
         ,p_mix_flag              => p_mix_flag
         ,p_reduce_regular        => p_reduce_regular
         ,p_ele_eff_start_date    => p_ele_eff_start_date
         ,p_ele_eff_end_date      => p_ele_eff_end_date
         ,p_bg_id                 => p_bg_id
         ,p_termination_rule      => p_termination_rule
         );
      hr_utility.set_location(l_proc, 30);
      --
     END IF;
 ELSE
   IF p_grossup_chk = 'Y' THEN
     l_ele_type_id := ntg_earnings_template.create_ele_ntg_objects
           ( p_ele_name            => p_ele_name
            ,p_ele_reporting_name  => p_ele_reporting_name
            ,p_ele_description     => p_ele_description
            ,p_ele_classification  => p_ele_classification
            ,p_ele_processing_type => p_ele_processing_type
            ,p_sep_check_option    => p_sep_check_option
            ,p_ele_eff_start_date  => p_ele_eff_start_date
            ,p_ele_eff_end_date    => p_ele_eff_end_date
            ,p_supp_category       => p_ele_category
            ,p_legislation_code    => p_legislation_code
            ,p_bg_id               => p_bg_id
            ,p_termination_rule    => p_termination_rule
           );
   END IF;
 END IF;
   --
   compile_formula(l_ele_type_id);
   RETURN (l_ele_type_id);
   --
   hr_utility.set_location('Leaving '||l_proc, 50);
   --
END create_isetup_earn_element;
------------------------------------------------------------------------------
--                       CREATE_ISETUP_DEDN_ELEMENT
------------------------------------------------------------------------------

FUNCTION create_isetup_dedn_element
         (p_element_name          in varchar2
         ,p_reporting_name        in varchar2
         ,p_description           in varchar2     default NULL
         ,p_classification_name   in varchar2
         ,p_ben_class_id          in number       default NULL
         ,p_category              in varchar2
         ,p_processing_type       in varchar2
         ,p_processing_priority   in number       default NULL
         ,p_standard_link_flag    in varchar2     default 'N'
         ,p_processing_runtype    in varchar2
         ,p_start_rule            in varchar2
         ,p_stop_rule             in varchar2
         ,p_amount_rule           in varchar2
         ,p_series_ee_bond        in varchar2
         ,p_payroll_table         in varchar2
         ,p_paytab_column         in varchar2
         ,p_rowtype_meaning       in varchar2
         ,p_arrearage             in varchar2
         ,p_deduct_partial        in varchar2
         ,p_employer_match        in varchar2     default 'N'
         ,p_aftertax_component    in varchar2     default 'N'
         ,p_ele_eff_start_date    in date         default NULL
         ,p_ele_eff_end_date      in date         default NULL
         ,p_business_group_id     in number
         ,p_srs_plan_type         in varchar2     default 'N'
         ,p_srs_buy_back          in varchar2     default 'N'
         ,p_catchup_processing    in varchar2     default 'NONE'
         ,p_termination_rule      in varchar2     default 'F'
         )
   RETURN NUMBER is
   --
   l_ele_type_id   number;

BEGIN

 l_ele_type_id :=
    pay_us_dedn_template_wrapper.create_deduction_element (
        p_element_name        => p_element_name
       ,p_reporting_name      => p_reporting_name
       ,p_description         => p_description
       ,p_classification_name => p_classification_name
       ,p_ben_class_id        => p_ben_class_id
       ,p_category            => p_category
       ,p_processing_type     => p_processing_type
       ,p_processing_priority => p_processing_priority
       ,p_standard_link_flag  => p_standard_link_flag
       ,p_processing_runtype  => p_processing_runtype
       ,p_start_rule          => p_start_rule
       ,p_stop_rule           => p_stop_rule
       ,p_amount_rule         => p_amount_rule
       ,p_series_ee_bond      => p_series_ee_bond
       ,p_payroll_table       => p_payroll_table
       ,p_paytab_column       => p_paytab_column
       ,p_rowtype_meaning     => p_rowtype_meaning
       ,p_arrearage           => p_arrearage
       ,p_deduct_partial      => p_deduct_partial
       ,p_employer_match      => p_employer_match
       ,p_aftertax_component  => p_aftertax_component
       ,p_ele_eff_start_date  => p_ele_eff_start_date
       ,p_ele_eff_end_date    => p_ele_eff_end_date
       ,p_business_group_id   => p_business_group_id
       ,p_catchup_processing  => p_catchup_processing
       ,p_termination_rule    => p_termination_rule
       ,p_srs_plan_type       => p_srs_plan_type
       ,p_srs_buy_back        => p_srs_buy_back
     );
--
  compile_formula(l_ele_type_id);
  RETURN (l_ele_type_id);
--
END create_isetup_dedn_element;
--
--
PROCEDURE compile_formula
           (p_element_type_id IN NUMBER) IS
 CURSOR csr_formula_name IS
   SELECT ff.formula_name,
          ft.formula_type_name
     FROM pay_status_processing_rules_f spr,
          ff_formulas_f ff,
          ff_formula_types ft,
          pay_element_types_f et
    WHERE et.element_type_id = p_element_type_id
      AND spr.formula_id = ff.formula_id
      AND ff.formula_type_id = ft.formula_type_id
      AND spr.element_type_id = et.element_type_id;
--
  CURSOR csr_bg_name IS
    SELECT name || ' GRP KF' grp_name
      FROM per_business_groups bg,
           pay_element_types_f et
     WHERE et.business_group_id = p_element_type_id;
--
   l_req_id NUMBER(10);
BEGIN
  FOR csr_formula_name_rec IN csr_formula_name
  LOOP
    l_req_id := fnd_request.submit_request(
                            application    => 'FF',
                            program        => 'SINGLECOMPILE',
                            argument1      => csr_formula_name_rec.formula_type_name,
                            argument2      => csr_formula_name_rec.formula_name);
  END LOOP;
/* update fnd_id_flex_structures
      set freeze_flex_definition_flag = 'Y'
    WHERE application_id = 801
      AND id_flex_structure_code = csr_bg_name_rec.grp_name;

  l_req_id := fnd_request.submit_request(
                            application    => 'FND',
                            program        => 'Compile Key Flexfields',
                            argument1      => 'Oracle Payroll'
                            argument2      => 'People Group Flexfield',
                            arguement3     => csr_bg_name_rec.grp_name); */
END compile_formula;
--
--
PROCEDURE compile_mig_formula
           (p_formula_id IN NUMBER) IS
 CURSOR csr_formula_name IS
   SELECT ff.formula_name,
          ft.formula_type_name
     FROM ff_formulas_f ff,
          ff_formula_types ft
    WHERE ff.formula_type_id = ft.formula_type_id
      AND ff.formula_id = p_formula_id;
 --
   l_req_id NUMBER(10);
BEGIN
   FOR csr_formula_name_rec IN csr_formula_name
   LOOP
     l_req_id := fnd_request.submit_request(
                        application    => 'FF',
                        program        => 'SINGLECOMPILE',
                        argument1      => csr_formula_name_rec.formula_type_name,
                        argument2      => csr_formula_name_rec.formula_name);
   END LOOP;
END compile_mig_formula;
--
--
PROCEDURE bulk_compile_formula IS
--
  l_req_id NUMBER(10);
BEGIN
  l_req_id := fnd_request.submit_request(
                    application    => 'FF',
                    program        => 'BULKCOMPILE',
                    argument1      => '-W',
                    argument2      => '%',
                    argument3      => '%');
END bulk_compile_formula;
--
--
FUNCTION uncompiled_formula return number IS
--PROCEDURE uncompiled_formula IS
--
  l_req_id NUMBER(10);
  l_resp_id fnd_responsibility.responsibility_id%type;
BEGIN
  SELECT responsibility_id
    INTO l_resp_id
    FROM fnd_responsibility
   WHERE responsibility_key = 'US_HRMS_MANAGER';
  --
  --FND_GLOBAL.APPS_INITIALIZE(0,l_resp_id,800);
  l_req_id := fnd_request.submit_request(
                    application    => 'FF',
                    program        => 'FF_UNCOMP',
                    argument1      => '-U',
                    argument2      => '%',
                    argument3      => '%');
  commit;
  return l_req_id;
END uncompiled_formula;
--
--
END pay_us_iSetup_earn_dedn;

/
