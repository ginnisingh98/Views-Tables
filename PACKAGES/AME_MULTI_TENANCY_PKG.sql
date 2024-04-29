--------------------------------------------------------
--  DDL for Package AME_MULTI_TENANCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_MULTI_TENANCY_PKG" AUTHID CURRENT_USER as
/* $Header: amemultncy.pkh 120.0.12010000.2 2008/11/28 05:36:11 prasashe noship $ */
--+
  type ref_cursor is REF CURSOR;
  Type calling_apps is TABLE OF ame_calling_apps%rowtype index by binary_integer;
  g_seed_call_apps calling_apps;
  Type item_class_usg is TABLE OF ame_item_class_usages%rowtype index by binary_integer;
  g_seed_ic_usg item_class_usg;
  Type ame_config_vars_type is TABLE OF ame_config_vars%rowtype index by binary_integer;
  g_seed_config_usg ame_config_vars_type;
  Type attr_usages is TABLE OF ame_attribute_usages%rowtype index by binary_integer;
  g_seed_mand_attr_usg attr_usages;
  g_seed_attr_usg attr_usages;
  Type ame_act_config is TABLE OF ame_action_type_config%rowtype index by binary_integer;
  g_seed_act_config ame_act_config;
  Type ame_act_usage is TABLE OF ame_action_usages%rowtype index by binary_integer;
  g_seed_act_usage ame_act_usage;
  Type ame_cond_usage is TABLE OF ame_condition_usages%rowtype index by binary_integer;
  g_seed_cond_usage ame_cond_usage;
   type group_details is record(
      voting_regime varchar2(2)
     ,order_number number
     ,name varchar2(100)
     ,approval_group_id number
     ,query_string varchar2(4000)
     ,is_static varchar2(2)
     ,description varchar2(200)
     ,group_last_updated_by number
     ,config_last_updated_by number
     ,group_creation_date date
     ,config_creation_date date
    );
    Type ame_group_dets is table of group_details index by binary_integer;
    g_seed_group_data ame_group_dets;
   type rule_details is record(
    rule_id integer,
    description varchar2(100),
    rule_type integer,
    start_date date,
    end_date date,
    usage_start_date date,
    usage_end_date date,
    approver_category varchar2(2),
    priority integer,
    item_class_id number
    );
 Type ame_rule_dets is table of rule_details index by binary_integer;
 g_seed_ame_rule ame_rule_dets;
--+
 function isSeedUser(userId in number) return varchar2;
 function isEntDataModified(p_creationDateIn in date, p_lastUpdateDateIn in date) return varchar2;
 function getSeedUser return number;
 function is_multi_tenant_system return varchar2;
 function disableConditionUpd(conditionIdIn in number) return varchar2;
 function isConfigUpdatable return varchar2;
--+
 procedure logMessage(methodNameIn in varchar2, errMsgIn in varchar2);
 procedure fetchSeedDataFromTables;
 procedure copyTxnType(errbuf              out nocopy varchar2,
                       retcode             out nocopy number,
                       applicationIdIn in number,
                       enterpriseIdIn in varchar2);
--+
end ame_multi_tenancy_pkg;

/
