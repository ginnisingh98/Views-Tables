--------------------------------------------------------
--  DDL for Package AME_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_UTILITY_PKG" AUTHID CURRENT_USER as
/* $Header: ameutility.pkh 120.4 2006/01/04 06:00 pvelugul noship $ */

  endOfTime constant date := to_date('31-12-4712', 'DD-MM-YYYY');

  defaultAmeAppId constant integer := 0;

  -- IMPORTANT:
  -- This procedure should only be called from middle tier using the
  -- format: select ame_utility_pkg.validate_query() from dual
  -- Otherwise in the process of validation of SQL if a DDL operation
  -- is passed then it gets executed.
  -- e.g. ame_utility_pkg.validate_query('create table a(b number(5))')
  -- If no such situtation is expected then it can be called safely
 function validate_query
    (p_query_string varchar2
    ,p_columns      number default null
    ,p_object       varchar2 default null
    ) return varchar2;

  function get_action_description(p_action_id      in number
                                 ,p_effective_date in date default sysdate) return varchar2;

  function is_approver_valid_in_action(p_action_type_id in number
                                      ,p_action_id in number) return varchar2;

  procedure purge_log
    (p_transaction_type in            varchar2 default null
    ,p_transaction_id   in            varchar2 default null
    ,p_success             out nocopy varchar2
    );

  function get_condition_description(p_condition_id   in varchar2
                                    ,p_truncate       in varchar2 default 'Y'
                                    ,p_effective_date in date default sysdate) return varchar2;

  function get_action_types(p_attribute_id number) return varchar2;

  function get_attribute_category(p_attribute_id number) return varchar2;

  procedure set_ame_savepoint;

  procedure rollback_to_ame_savepoint;

  procedure get_value_set_query
    (p_value_set_id in            number
    ,p_select          out nocopy varchar2);

  function get_rule_last_update_date
    (p_rule_id integer
    ,p_application_id integer
    ,p_usage_start_date date
    ) return date;

  function get_rule_last_updated_by
    (p_rule_id integer
    ,p_application_id integer
    ,p_usage_start_date date
    ) return integer;

  function is_rule_updatable
    (p_rule_id integer
    ,p_application_id integer
    ,p_usage_start_date date
    ) return varchar2;

  function get_rule_last_update_action
    (p_rule_id integer
    ,p_application_id integer
    ,p_usage_start_date date
    ,p_usage_end_date date
    ) return varchar2;

  function is_valid_attribute
    (p_attribute_id   in varchar2
    ,p_application_id in varchar2
    ,p_allow_all      in varchar2
    ) return varchar2;

  function get_rule_end_date
    (p_rule_id integer
    ) return date;

  function check_seeddb return varchar2;
  function get_rule_id return number;
  function get_condition_id return number;
  function get_item_class_id return number;
  function getNextApproverTypeId return integer;
  function is_seed_user
    (p_user_id integer
    ) return number;

end ame_utility_pkg;

 

/
