--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_TEMPLATE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_TEMPLATE_UTIL" AUTHID CURRENT_USER as
/* $Header: pyetmutl.pkh 120.0 2005/05/29 04:43:00 appldev noship $ */
-------------------------------------------------------------------
-- Placeholder string used within formula text and flex columns. --
-------------------------------------------------------------------
g_name_placeholder constant varchar2(30) default '<BASE NAME>';
-----------------------------------
-- PL/SQL table types used here. --
-----------------------------------
type t_boolean is table of boolean index by binary_integer;
type t_exclusion_rules is table of pay_ter_shd.g_rec_type index by
binary_integer;
type t_formulas is table of pay_sf_shd.g_rec_type index by binary_integer;
type t_balance_types is table of pay_sbt_shd.g_rec_type index by
binary_integer;
type t_defined_balances is table of pay_sdb_shd.g_rec_type index by
binary_integer;
type t_element_types is table of pay_set_shd.g_rec_type index by
binary_integer;
type t_sub_classi_rules is table of pay_ssr_shd.g_rec_type index by
binary_integer;
type t_balance_classis is table of pay_sbc_shd.g_rec_type index by
binary_integer;
type t_input_values is table of pay_siv_shd.g_rec_type index by
binary_integer;
type t_balance_feeds is table of pay_sbf_shd.g_rec_type index by
binary_integer;
type t_formula_rules is table of pay_sfr_shd.g_rec_type index by
binary_integer;
type t_core_objects is table of pay_tco_shd.g_rec_type index by binary_integer;
type t_iterative_rules is table of pay_sir_shd.g_rec_type index by
binary_integer;
type t_ele_type_usages is table of pay_seu_shd.g_rec_type index by
binary_integer;
type t_gu_bal_exclusions is table of pay_sgb_shd.g_rec_type index by
binary_integer;
type t_bal_attributes is table of pay_sba_shd.g_rec_type index by
binary_integer;
type t_template_ff_usages is table of pay_tfu_shd.g_rec_type index by
binary_integer;
-- ----------------------------------------------------------------------------
-- |---------------------------< get_template_type >--------------------------|
-- ----------------------------------------------------------------------------
function get_template_type(p_template_id in number) return varchar2;
-- ----------------------------------------------------------------------------
-- |------------------------< create_plsql_template >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_plsql_template
  (p_lock                          in     boolean default false
  ,p_template_id                   in     number
  ,p_generate_part1                in     boolean default false
  ,p_generate_part2                in     boolean default false
  ,p_element_template              in out nocopy pay_etm_shd.g_rec_type
  ,p_core_objects                  in out nocopy t_core_objects
  ,p_exclusion_rules               in out nocopy t_exclusion_rules
  ,p_formulas                      in out nocopy t_formulas
  ,p_balance_types                 in out nocopy t_balance_types
  ,p_defined_balances              in out nocopy t_defined_balances
  ,p_element_types                 in out nocopy t_element_types
  ,p_sub_classi_rules              in out nocopy t_sub_classi_rules
  ,p_balance_classis               in out nocopy t_balance_classis
  ,p_input_values                  in out nocopy t_input_values
  ,p_balance_feeds                 in out nocopy t_balance_feeds
  ,p_formula_rules                 in out nocopy t_formula_rules
  ,p_iterative_rules               in out nocopy t_iterative_rules
  ,p_ele_type_usages               in out nocopy t_ele_type_usages
  ,p_gu_bal_exclusions             in out nocopy t_gu_bal_exclusions
  ,p_bal_attributes                in out nocopy t_bal_attributes
  ,p_template_ff_usages            in out nocopy t_template_ff_usages
  );
-- ----------------------------------------------------------------------------
-- |------------------------< flush_plsql_template >--------------------------|
-- ----------------------------------------------------------------------------
procedure flush_plsql_template
  (p_element_template              in out nocopy pay_etm_shd.g_rec_type
  ,p_core_objects                  in out nocopy t_core_objects
  ,p_exclusion_rules               in out nocopy t_exclusion_rules
  ,p_formulas                      in out nocopy t_formulas
  ,p_balance_types                 in out nocopy t_balance_types
  ,p_defined_balances              in out nocopy t_defined_balances
  ,p_element_types                 in out nocopy t_element_types
  ,p_sub_classi_rules              in out nocopy t_sub_classi_rules
  ,p_balance_classis               in out nocopy t_balance_classis
  ,p_input_values                  in out nocopy t_input_values
  ,p_balance_feeds                 in out nocopy t_balance_feeds
  ,p_formula_rules                 in out nocopy t_formula_rules
  ,p_iterative_rules               in out nocopy t_iterative_rules
  ,p_ele_type_usages               in out nocopy t_ele_type_usages
  ,p_gu_bal_exclusions             in out nocopy t_gu_bal_exclusions
  ,p_bal_attributes                in out nocopy t_bal_attributes
  ,p_template_ff_usages            in out nocopy t_template_ff_usages
  );
-- ----------------------------------------------------------------------------
-- |-------------------< create_plsql_user_structure >------------------------|
-- ----------------------------------------------------------------------------
procedure create_plsql_user_structure
  (p_business_group_id             in     number
  ,p_base_name                     in     varchar2
  ,p_base_processing_priority      in     number   default null
  ,p_preference_info_category      in     varchar2 default null
  ,p_preference_information1       in     varchar2 default null
  ,p_preference_information2       in     varchar2 default null
  ,p_preference_information3       in     varchar2 default null
  ,p_preference_information4       in     varchar2 default null
  ,p_preference_information5       in     varchar2 default null
  ,p_preference_information6       in     varchar2 default null
  ,p_preference_information7       in     varchar2 default null
  ,p_preference_information8       in     varchar2 default null
  ,p_preference_information9       in     varchar2 default null
  ,p_preference_information10      in     varchar2 default null
  ,p_preference_information11      in     varchar2 default null
  ,p_preference_information12      in     varchar2 default null
  ,p_preference_information13      in     varchar2 default null
  ,p_preference_information14      in     varchar2 default null
  ,p_preference_information15      in     varchar2 default null
  ,p_preference_information16      in     varchar2 default null
  ,p_preference_information17      in     varchar2 default null
  ,p_preference_information18      in     varchar2 default null
  ,p_preference_information19      in     varchar2 default null
  ,p_preference_information20      in     varchar2 default null
  ,p_preference_information21      in     varchar2 default null
  ,p_preference_information22      in     varchar2 default null
  ,p_preference_information23      in     varchar2 default null
  ,p_preference_information24      in     varchar2 default null
  ,p_preference_information25      in     varchar2 default null
  ,p_preference_information26      in     varchar2 default null
  ,p_preference_information27      in     varchar2 default null
  ,p_preference_information28      in     varchar2 default null
  ,p_preference_information29      in     varchar2 default null
  ,p_preference_information30      in     varchar2 default null
  ,p_configuration_info_category   in     varchar2 default null
  ,p_configuration_information1    in     varchar2 default null
  ,p_configuration_information2    in     varchar2 default null
  ,p_configuration_information3    in     varchar2 default null
  ,p_configuration_information4    in     varchar2 default null
  ,p_configuration_information5    in     varchar2 default null
  ,p_configuration_information6    in     varchar2 default null
  ,p_configuration_information7    in     varchar2 default null
  ,p_configuration_information8    in     varchar2 default null
  ,p_configuration_information9    in     varchar2 default null
  ,p_configuration_information10   in     varchar2 default null
  ,p_configuration_information11   in     varchar2 default null
  ,p_configuration_information12   in     varchar2 default null
  ,p_configuration_information13   in     varchar2 default null
  ,p_configuration_information14   in     varchar2 default null
  ,p_configuration_information15   in     varchar2 default null
  ,p_configuration_information16   in     varchar2 default null
  ,p_configuration_information17   in     varchar2 default null
  ,p_configuration_information18   in     varchar2 default null
  ,p_configuration_information19   in     varchar2 default null
  ,p_configuration_information20   in     varchar2 default null
  ,p_configuration_information21   in     varchar2 default null
  ,p_configuration_information22   in     varchar2 default null
  ,p_configuration_information23   in     varchar2 default null
  ,p_configuration_information24   in     varchar2 default null
  ,p_configuration_information25   in     varchar2 default null
  ,p_configuration_information26   in     varchar2 default null
  ,p_configuration_information27   in     varchar2 default null
  ,p_configuration_information28   in     varchar2 default null
  ,p_configuration_information29   in     varchar2 default null
  ,p_configuration_information30   in     varchar2 default null
  ,p_prefix_reporting_name         in     varchar2 default 'N'
  ,p_element_template              in out nocopy pay_etm_shd.g_rec_type
  ,p_exclusion_rules               in out nocopy t_exclusion_rules
  ,p_formulas                      in out nocopy t_formulas
  ,p_balance_types                 in out nocopy t_balance_types
  ,p_defined_balances              in out nocopy t_defined_balances
  ,p_element_types                 in out nocopy t_element_types
  ,p_sub_classi_rules              in out nocopy t_sub_classi_rules
  ,p_balance_classis               in out nocopy t_balance_classis
  ,p_input_values                  in out nocopy t_input_values
  ,p_balance_feeds                 in out nocopy t_balance_feeds
  ,p_formula_rules                 in out nocopy t_formula_rules
  ,p_iterative_rules               in out nocopy t_iterative_rules
  ,p_ele_type_usages               in out nocopy t_ele_type_usages
  ,p_gu_bal_exclusions             in out nocopy t_gu_bal_exclusions
  ,p_bal_attributes                in out nocopy t_bal_attributes
  ,p_template_ff_usages            in out nocopy t_template_ff_usages
  );
-- ----------------------------------------------------------------------------
-- |------------------------< plsql_to_db_template >--------------------------|
-- ----------------------------------------------------------------------------
procedure plsql_to_db_template
  (p_effective_date                in     date
  ,p_element_template              in out nocopy pay_etm_shd.g_rec_type
  ,p_exclusion_rules               in out nocopy t_exclusion_rules
  ,p_formulas                      in out nocopy t_formulas
  ,p_balance_types                 in out nocopy t_balance_types
  ,p_defined_balances              in out nocopy t_defined_balances
  ,p_element_types                 in out nocopy t_element_types
  ,p_sub_classi_rules              in out nocopy t_sub_classi_rules
  ,p_balance_classis               in out nocopy t_balance_classis
  ,p_input_values                  in out nocopy t_input_values
  ,p_balance_feeds                 in out nocopy t_balance_feeds
  ,p_formula_rules                 in out nocopy t_formula_rules
  ,p_iterative_rules               in out nocopy t_iterative_rules
  ,p_ele_type_usages               in out nocopy t_ele_type_usages
  ,p_gu_bal_exclusions             in out nocopy t_gu_bal_exclusions
  ,p_bal_attributes                in out nocopy t_bal_attributes
  ,p_template_id                      out nocopy number
  ,p_object_version_number            out nocopy number
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_template >----------------------------|
-- ----------------------------------------------------------------------------
procedure delete_template
  (p_template_id     in number
  ,p_formulas        in t_formulas
  ,p_delete_formulas in boolean default true
  );
--
-- |---------------------------< get_shadow_formula_name >--------------------------|
-- ----------------------------------------------------------------------------
function get_shadow_formula_name(p_formula_id in number) return varchar2;
-- ---------------------------------------------------------------------------------
--
end pay_element_template_util;

 

/
