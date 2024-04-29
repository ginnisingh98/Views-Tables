--------------------------------------------------------
--  DDL for Package HR_ELEMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ELEMENTS" AUTHID CURRENT_USER as
/* $Header: pyelemnt.pkh 120.0 2005/05/29 04:32:14 appldev noship $ */
--
 /*
 NAME
 chk_element_name
 DESCRIPTION
   Checks element name for duplication.
 */
--
PROCEDURE       chk_element_name(p_element_name         in varchar2,
                                 p_element_type_id      in number,
                                 p_val_start_date       in date,
                                 p_val_end_date         in date,
                                 p_business_group_id    in number,
                                 p_legislation_code     in varchar2);
--
--
 /*
 NAME
 chk_reporting_name
 DESCRIPTION
   Checks reporting name for duplication. Will only be called if reporting
   name is not null.
 */
--
PROCEDURE       chk_reporting_name(p_reporting_name     in varchar2,
                                 p_element_type_id      in number,
                                 p_val_start_date       in date,
                                 p_val_end_date         in date,
                                 p_business_group_id    in number,
                                 p_legislation_code     in varchar2);
--
 /*
 NAME
 chk_element_type
 DESCRIPTION
   Checks attributes of element type according to business rules
 */
--
 PROCEDURE chk_element_type(p_element_name                    in varchar2,
                            p_element_type_id                 in number,
                            p_val_start_date                  in date,
                            p_val_end_date                    in date,
                            p_reporting_name                  in varchar2,
                            p_rowid                           in varchar2,
                            p_recurring_flag                  in varchar2,
                            p_standard_flag                   in varchar2,
                            p_scndry_ent_allwd_flag           in varchar2,
                            p_process_in_run_flag             in varchar2,
                            p_indirect_only_flag              in varchar2,
                            p_adjustment_only_flag            in varchar2,
                            p_multiply_value_flag             in varchar2,
                            p_classification_type             in varchar2,
                            p_output_currency_code            in varchar2,
                            p_input_currency_code            in varchar2,
                            p_business_group_id               in number,
                            p_legislation_code                in varchar2,
                            p_bus_grp_currency_code           in varchar2);
--
 /*
 NAME
 chk_upd_element_type
 DESCRIPTION
   Checks that the attributes of element type are allowed to be updated.
 NOTES
   Does not test for attributes which cannot be updated.
   These are element_name and classification id.
 */
--
 PROCEDURE chk_upd_element_type(p_update_mode                 in varchar2,
                                p_val_start_date              in date,
                                p_val_end_date                in date,
                                p_element_type_id             in number,
                                p_business_group_id           in number,
                                p_old_name                    in varchar2,
                                p_name                        in varchar2,
                                p_old_process_in_run_flag     in varchar2,
                                p_process_in_run_flag         in varchar2,
                                p_old_input_currency          in varchar2,
                                p_input_currency              in varchar2,
                                p_old_output_currency         in varchar2,
                                p_output_currency             in varchar2,
                                p_old_standard_link_flag      in varchar2,
                                p_standard_link_flag          in varchar2,
                                p_old_adjustment_only_flag    in varchar2,
                                p_adjustment_only_flag        in varchar2,
                                p_old_indirect_only_flag      in varchar2,
                                p_indirect_only_flag          in varchar2,
                                p_old_scndry_ent_allwd_flag   in varchar2,
                                p_scndry_ent_allwd_flag       in varchar2,
                                p_old_post_termination_rule   in varchar2,
                                p_post_termination_rule       in varchar2,
                                p_old_processing_priority     in number,
                                p_processing_priority         in number);
--
 /*
 NAME
 element_priority_ok
 DESCRIPTION
 should be called on any sitation where the processing priority of the element
 can change. This is on update and on next change delete.
 */
--
FUNCTION        element_priority_ok(p_element_type_id   number,
                                        p_processing_priority   number,
                                             p_val_start_date   date,
                                             p_val_end_date     date)
                                             return boolean;
--
 /*
 NAME
 chk_del_element_type
 DESCRIPTION
   Checks that the element can be deleted. This is either complete delete or
   Date effective delete.
 NOTES
  This procedure disallows delete for any element with element links.
 */
--
 PROCEDURE chk_del_element_type(p_mode             in varchar2,
                                p_element_type_id  in number,
                                p_processing_priority   number,
                                p_session_date     in date,
                                p_val_start_date   in date,
                                p_val_end_date     in date);
--
 /*
 NAME
ins_input_value
 DESCRIPTION
  inserts a pay value for an element type.
 NOTES
  This function requires a row to be in HR_LOOKUPS with a lookup type of
  PAY_NAME_TRANSLATIONS for the PAY_VALUE and the correct legislation code.
 */
--
 PROCEDURE ins_input_value(p_element_type_id       in number,
                           p_legislation_code      in varchar2,
                           p_business_group_id     in number,
                           p_classification_id     in number,
                           p_val_start_date        in date,
                           p_val_end_date          in date,
                           p_startup_mode          in varchar2);
--
 /*
 NAME
  ins_sub_classification_rules
 DESCRIPTION
  This procedure will create a sub_classification_rule for each
  sub_classification that has the create_by_default_flag set to 'Y',,
  It will then call hr_balances.ins_balance_feed to create the balance feeds.
 */
--
 PROCEDURE ins_sub_classification_rules(
                               p_element_type_id       in number,
                               p_legislation_code       in varchar2,
                               p_business_group_id      in number,
                               p_classification_id     in number,
                               p_val_start_date        in date,
                               p_val_end_date          in date,
                               p_startup_mode           in varchar2);
--
 /*
 NAME
  ins_3p_element_type
 DESCRIPTION
  Based on the process in run flag this will call the insert input value
  and the insert status processing rules procedures.
 */
--
 PROCEDURE ins_3p_element_type(p_element_type_id       in number,
                               p_process_in_run_flag   in varchar2,
                               p_legislation_code      in varchar2,
                               p_business_group_id     in number,
                               p_classification_id     in number,
                               p_non_payments_flag     in varchar,
                               p_val_start_date        in date,
                               p_val_end_date          in date,
                                p_startup_mode          in varchar2);

--
 /*
 NAME
  del_formula_result_rules
 DESCRIPTION
  This procedure deletes any formula result rules in existence for the element.  It is only called from del_status_processing_rules.
*/
--
PROCEDURE       del_formula_result_rules(
                               p_status_processing_rule_id in number,
                               p_delete_mode            in varchar2,
                               p_val_session_date       in date,
                               p_val_start_date         in date,
                               p_val_end_date           in date,
                                p_startup_mode          in varchar2);
--
 /*
 NAME
  del_status_processing_ruleS
 DESCRIPTION
  This procedure deletes any status processing rules for this element and
  calls a function to delete any formula result rules.
 NOTES
  Element types cannot be subject to a future change delete. They can be subject  to a next change delete but, in the case of status processing rules, this
  does not cause the records to 'open up' if we are on the final record. A
  warning will appear in the form telling the users that this is the case.
*/
PROCEDURE       del_status_processing_rules(
                               p_element_type_id        in number,
                               p_delete_mode            in varchar2,
                               p_val_session_date       in date,
                               p_val_start_date         in date,
                               p_val_end_date           in date,
                                p_startup_mode          in varchar2);
--
--
 /*
 NAME
  del_sub_classification_rules
 DESCRIPTION
  This procedure deletes any existing sub_classification_rules and any
  related balance feeds.
 NOTES
  Element types cannot be subject to a future change delete. They can, however,  be subject to a next change delete and this is handled in the code. This
  procedure relies on the hr_input_values.del_3p_input_values being called
  in the same commit unit as this will tidy up the balance feeds that may have
  been created by the sub_classification rules.
*/
--
PROCEDURE       del_sub_classification_rules(
                               p_element_type_id        in number,
                               p_delete_mode            in varchar2,
                               p_val_session_date       in date,
                               p_val_start_date         in date,
                               p_val_end_date           in date,
                               p_startup_mode           in varchar2);
--
--
 /*
 NAME
  upd_3p_element_type
 DESCRIPTION
  This procedure does third party processing necessary on update. Currenctly
  this only consists of deleting and recreating the database items
*/
PROCEDURE       upd_3p_element_type(p_element_type_id   in number,
                                    p_val_start_date    in date,
                                    p_old_name          in varchar2,
                                    p_name              in varchar2);
--
 /*
 NAME
  del_3p_element_type
 DESCRIPTION
  This procedure does the necessary cascade deletes when an element type is
  deleted. This affects the following tables: Input values, status processing
  rules and formula result rules.
 NOTES
  Element types cannot be subject to a future change delete. They can, however,  be subject to a next change delete and this is handled in the code.
 */
--
 PROCEDURE del_3p_element_type(p_element_type_id       in number,
                               p_delete_mode           in varchar2,
                               p_val_session_date      in date,
                               p_val_start_date        in date,
                               p_val_end_date          in date,
                                p_startup_mode          in varchar2);
--
PROCEDURE       ins_ownerships(p_key_name       varchar2,
                               p_key_value      number,
                               p_element_type_id        number);
 /*
 NAME
  check_element_freq
 DESCRIPTION
  This function checks whether there are any frequency rules for this
  element and if they apply to the current period.
 */

PROCEDURE check_element_freq (  p_payroll_id    IN NUMBER,
                                p_bg_id         IN NUMBER,
                                p_pay_action_id IN NUMBER,
                                p_passed_date   IN DATE,
                                p_ele_type_id   IN NUMBER,
                                p_whole_period_only IN VARCHAR2,
                                p_skip_element  OUT NOCOPY VARCHAR2);

PROCEDURE check_element_freq (  p_payroll_id    IN NUMBER,
                                p_bg_id         IN NUMBER,
                                p_pay_action_id IN NUMBER,
                                p_date_earned   IN DATE,
                                p_ele_type_id   IN NUMBER,
                                p_skip_element  OUT NOCOPY VARCHAR2);

--
end hr_elements;
 

/
