--------------------------------------------------------
--  DDL for Package JTF_DPF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DPF" AUTHID CURRENT_USER as
  /* $Header: jtfdpfs.pls 120.1 2005/07/02 00:40:44 appldev ship $ */

  -- created by sel12.sql
  type dpf is record (
    dpf_id jtf_dpf_lgcl_flow_params.logical_flow_id%type,
    dpf_name jtf_dpf_logical_flows_b.logical_flow_name%type,
    head_logical_asn fnd_application.application_short_name%type,
    head_logical_name jtf_dpf_logical_pages_b.logical_page_name%type,
    rtn_to_page_logical_asn fnd_application.application_short_name%type,
    rtn_to_page_logical_name jtf_dpf_logical_pages_b.logical_page_name%type,
    flow_finalizer_class jtf_dpf_logical_flows_b.flow_finalizer_class%type,
    logical_flow_description
      jtf_dpf_logical_flows_tl.logical_flow_description%type,
    validate_flag jtf_dpf_logical_flows_b.validate_flag%type,
    secure_flow_flag jtf_dpf_logical_flows_b.secure_flow_flag%type,
    active_flag varchar2(1), -- jtf_dpf_logical_flows_b.enabled_clone_flag%type,
    editable_flag varchar2(1));

  -- created by sel13.sql
  type logical is record(
    logical_page_id jtf_dpf_logical_pages_b.logical_page_id%type,
    logical_page_name jtf_dpf_logical_pages_b.logical_page_name%type,
    logical_page_type jtf_dpf_logical_pages_b.logical_page_type%type,
    logical_page_description
      jtf_dpf_logical_pages_tl.logical_page_description%type,
    page_controller_class jtf_dpf_logical_pages_b.page_controller_class%type,
    page_permission_name jtf_dpf_logical_pages_b.page_permission_name%type,
    def_phys_asn fnd_application.application_short_name%type,
    def_phys_id number,
    def_phys_name jtf_dpf_physical_pages_b.physical_page_name%type);

  -- created by sel14.sql
  type physical is record(
    id number,
    name jtf_dpf_physical_pages_b.physical_page_name%type,
    descr jtf_dpf_physical_pages_tl.physical_page_description%type);

  -- created by sel15.sql
  type physical_non_default is record(
    logical_name jtf_dpf_logical_pages_b.logical_page_name%type,
    rule_eval_sequence jtf_dpf_lgcl_phy_rules.rule_eval_sequence%type,
    rule_asn fnd_application.application_short_name%type,
    rule_name jtf_dpf_rules_b.rule_name%type,
    phys_asn fnd_application.application_short_name%type,
    phys_id number,
    phys_name jtf_dpf_physical_pages_b.physical_page_name%type);

  -- sel16.sql
  type rule is record(
    rule_id jtf_dpf_rules_b.rule_id%type,
    rule_name jtf_dpf_rules_b.rule_name%type,
    rule_description jtf_dpf_rules_tl.rule_description%type,
    rule_param_name jtf_dpf_rule_params.rule_param_name%type,
    rule_param_value jtf_dpf_rule_params.rule_param_value%type,
    rule_param_condition jtf_dpf_rule_params.rule_param_condition%type);

  -- sel17.sql
  type next_logical_default is record(
    dpf_name jtf_dpf_logical_flows_b.logical_flow_name%type,
    dpf_id  jtf_dpf_logical_flows_b.logical_flow_id%type,
    key_log_asn fnd_application.application_short_name%type,
    key_log_name jtf_dpf_logical_pages_b.logical_page_name%type,
    result_log_asn fnd_application.application_short_name%type,
    result_log_name jtf_dpf_logical_pages_b.logical_page_name%type);

  -- sel18.sql
  type next_logical_non_default is record(
    dpf_name jtf_dpf_logical_flows_b.logical_flow_name%type,
    dpf_id  jtf_dpf_logical_flows_b.logical_flow_id%type,
    rule_asn fnd_application.application_short_name%type,
    rule_name jtf_dpf_rules_b.rule_name%type,
    key_log_asn fnd_application.application_short_name%type,
    key_log_name jtf_dpf_logical_pages_b.logical_page_name%type,
    result_log_asn fnd_application.application_short_name%type,
    result_log_name jtf_dpf_logical_pages_b.logical_page_name%type);

  type physical_attribs is record(
    id number,
    name jtf_dpf_phy_attribs.page_attribute_name%type,
    value jtf_dpf_phy_attribs.page_attribute_value%type);

  -- used to nad
  type new_rule_param is record(
    condition jtf_dpf_rule_params.rule_param_condition%type,
    param_name jtf_dpf_rule_params.rule_param_name%type,
    param_value jtf_dpf_rule_params.rule_param_value%type);

  type new_rule_param_tbl is table of new_rule_param index by binary_integer;

  type new_phys_non_def is record (rule_id number, physical_page_id number);
  type new_phys_non_def_tbl is table of new_phys_non_def
      index by binary_integer;
  type new_next_log_non_def is record (rule_id number, logical_page_id number);
  type new_next_log_non_def_tbl is table of new_next_log_non_def
      index by binary_integer;
  type new_phys_attribs is record(
    name jtf_dpf_phy_attribs.page_attribute_name%type,
    value jtf_dpf_phy_attribs.page_attribute_value%type);
  type new_phys_attribs_tbl is table of new_phys_attribs
    index by binary_integer;

  type dpf_tbl is table of dpf index by binary_integer;
  type logical_tbl is table of logical index by binary_integer;
  type physical_tbl is table of physical index by binary_integer;
  type physical_non_default_tbl is table of physical_non_default
    index by binary_integer;
  type rule_tbl is table of rule index by binary_integer;
  type next_logical_default_tbl is table of next_logical_default
    index by binary_integer;
  type next_logical_non_default_tbl is table of next_logical_non_default
    index by binary_integer;
  type physical_attribs_tbl is table of physical_attribs
    index by binary_integer;

--   type lang_rec is record(lang fnd_languages.language_code%type);

  -- this procedure gets everything there is to know about a DPF,
  -- per user language, in a single round trip!
  -- Java will call this with descrs_only=true if we already has the DPF
  -- data for the given 'asn', except not in this langauge.  if descrs_only
  -- is true, then we don't bother to write these 4 variables:
  --  phys_non_def
  --  next_log_def
  --  next_log_non_def
  --  phys_attrs
  --
  -- the p_lang parameter is the language code ('US', 'JP', etc...)
  -- We allow the user of this interface to pass in an explicit parameter,
  -- to work around repeated troubles for the java client who has a hard time
  -- getting the a JDBC Connection with the right language handle.  If the
  -- language is not provided (i.e. if p_lang is null) then we use
  -- userenv('lang'). In any case, we set p_lang to userenv('lang') before
  -- returning.

  procedure get (asn varchar2,
   p_lang in out NOCOPY varchar2,
   descrs_only boolean,
   dpf out NOCOPY dpf_tbl,
   log out NOCOPY logical_tbl,
   phys out NOCOPY physical_tbl,
   phys_non_def out NOCOPY physical_non_default_tbl,
   rule out NOCOPY rule_tbl,
   next_log_def out NOCOPY next_logical_default_tbl,
   next_log_non_def out NOCOPY next_logical_non_default_tbl,
   phys_atts out NOCOPY physical_attribs_tbl);

  -- rule editing procedures
  -- removes the rule and any rule_params that were stored under it.  Has
  -- no effect if the rule doesn't exist
  procedure rule_delete(p_rule_id number);
  -- change the rule specified by rule_id so that it is of the specified
  -- application, name, and description.  Has no effect
  -- if no rule has p_rule_id
  --
  -- returns:
  --   1: successfully updated
  --   2: the proposed new name "p_new_name" is already taken
  --   3: the proposed new name "p_new_name" is null
  type rule_update_rec is record(
    p_new_asn fnd_application.application_short_name%type,
    p_new_name jtf_dpf_rules_b.rule_name%type,
    p_new_descr jtf_dpf_rules_tl.rule_description%type);

  function rule_update(p_rule_id number,
    upd rule_update_rec) return number;

  -- creates the rule (ASN, NAME) if it doesn't already exist.
  --
  -- Returns one of the following values:
  --   1: new one successfully created
  --   2: new one not created: the given "p_new_name" is already taken
  --   3: new one not created: the given "p_new_name" is null
  function rule_new(p_asn varchar2, p_name varchar2, p_descr varchar2,
      rules new_rule_param_tbl) return number;

  -- Sets the params of a rule rule_id.  If there's no such rule,
  -- then it has no effect.
  procedure rule_set_params(p_rule_id number,
      rules new_rule_param_tbl);

  -- Physical editing procedures
  -- remove the physical denoted by ppid.  If there's no such physical,
  -- then this has no effect.
  procedure phys_delete(p_ppid number);

  -- modify the phys denoted by ppid to have the new name and description
  -- If there's no such physical, then this has no effect.  Returns one
  -- of:
  --
  --  1: physical successfully updated
  --  3: physical not successfully updated: the given p_name is null or empty
  type phys_update_rec is record(
    p_new_asn fnd_application.application_short_name%type,
    p_name jtf_dpf_physical_pages_b.physical_page_name%type,
    p_descr jtf_dpf_physical_pages_tl.physical_page_description%type);

  function phys_update(p_ppid number,
      upd phys_update_rec) return number;

  -- modify the physical (specified by its physical_id = p_ppid)
  -- so that it has the given entries in table jtf_dpf_phy_attribs.
  -- this replaces any previous entries.  If p_new_ones is null or empty,
  -- then the call has the effect of removing all physical_attribs
  -- for the physical page
  procedure phys_attribs_update(p_ppid number,
      p_new_ones new_phys_attribs_tbl);

  -- create a new phys.  Returns one of the following values:
  --
  --  1: new one successfully created
  --  3: new one not created: the given "p_name" is null or empty
  function phys_new (p_asn varchar2, p_name varchar2, p_descr varchar2)
    return number;

  -- dpf editing procedures
  -- delete_flow.  Removes all rows with logical_page_flow from tables:
  -- - jtf_dpf_lgcl_flow_params
  -- - jtf_dpf_logical_flows
  -- - jtf_dpf_lgcl_next_rules
  procedure flow_delete(p_logical_flow_id number);

  -- updates the components of the flow specified by p_logical_flow_id.
  -- if p_new_header_logical_page_id is G_MISS_NUM, then it's not
  -- altered.  Likewise, if p_rtn_to_logical_page_id is G_MISS_NUM, then it's
  -- not altered.
  -- This function has no effect of there's no such flow as p_logical_flow_id.
  --
  -- returns
  --   1: successfully updated
  --   2: no update: the proposed new name "p_new_name" is already taken
  --   3: no update: the proposed new name "p_new_name" is null
  --   4: no update: the given "p_new_header_logical_page_id" or
  --      "p_rtn_to_logical_page_id" (or both) is not G_MISS_NUM, and is bad
  type flow_update_rec is record(
    p_new_asn fnd_application.application_short_name%type,
    p_new_name jtf_dpf_logical_flows_b.logical_flow_name%type,
    p_new_flow_finalizer_class
      jtf_dpf_logical_flows_b.flow_finalizer_class%type,
    p_new_descr  jtf_dpf_logical_flows_tl.logical_flow_description%type,
    p_new_validate_flag varchar2(1),
    p_new_secure_flow_flag varchar2(1),
    p_new_header_logical_page_id
      jtf_dpf_logical_pages_b.logical_page_id%type,
    p_rtn_to_logical_page_id jtf_dpf_logical_pages_b.logical_page_id%type);

  function flow_update(p_logical_flow_id number,
    upd flow_update_rec) return number;

  -- create a new Key Business Flow with the given info.
  --
  -- Returns one of the following values:
  --   1: new one successfully created
  --   2: new one not created: the given "p_new_name" is already taken
  --   3: new one not created: the given "p_new_name" is null
  --   4: new one not created: the given "p_new_header_logical_page_id"
  --      or "p_rtn_to_logical_page_id" is bad
  function flow_new(
    p_new_asn varchar2,
    p_new_name varchar2,
    p_new_flow_finalizer_class varchar2,
    p_new_descr varchar2,
    p_new_validate_flag varchar2,
    p_new_secure_flow_flag varchar2,
    p_new_header_logical_page_id number,
    p_rtn_to_logical_page_id number) return number;

  -- create a new Key Business Flow with the same name as the given one.
  -- writes the flow_id of the newly-created flow into p_new_flow_id.
  --
  -- Returns one of the following values:
  --   1: new one successfully created
  --   2: new one not created: the given "p_flow_id" not found
  function flow_copy(p_flow_id number, p_new_flow_id out NOCOPY number) return number;

  -- sets the given flow to 'active'.  All other flows with the same
  -- appid and flow_name become deactivated.
  --
  -- Returns one of the following values:
  --   1: new one successfully activated
  --   2: new one not created: the given "p_flow_id" not found
  function flow_activate(p_flow_id number) return number;


  -- logical editing procedures:
  -- removes any instances with logical_page_id from tables:
  -- - jtf_dpf_logical_pages
  -- - jtf_dpf_lgcl_next_rules
  -- - jtf_dpf_lgcl_phy_rules
  -- removes the logical from JTF_DPF_LOGICAL_PAGES.  Also removes
  -- any jtf_dpf_lgcl_phy_rules with the same logical_page_id
  procedure logical_delete(p_logical_page_id number);

  -- update the jtf_dpf_logical_pages table so that the logical identified
  -- by logical_page_id has the specified ASN, NAME, and DESCR.
  -- Also updates the JTF_DPF_LGCL_PHY_RULES table,
  -- so that the one default_next_flag='T' row it has for this logical_page_id
  -- indicates the specified default_physical page
  --
  -- This does NOT update the defaultPhysical of the Logical if
  -- p_default_physical_id is G_MISS_NUM.
  --
  -- returns
  --   1: successfully updated
  --   2: no update: the proposed new name "p_new_name" is already taken
  --   3: no update: the proposed new name "p_new_name" is null
  --   4: no update: new one not created: the given "p_default_physical_id"
  --      is not G_MISS_NUM, and there's no such Physical
  type logical_update_rec is record(
    p_new_asn fnd_application.application_short_name%type,
    p_new_name jtf_dpf_logical_pages_b.logical_page_name%type,
    p_new_type jtf_dpf_logical_pages_b.logical_page_type%type,
    p_new_descr jtf_dpf_logical_pages_tl.logical_page_description%type,
    p_new_page_controller_class
      jtf_dpf_logical_pages_b.page_controller_class%type,
    p_new_page_permission_name
      jtf_dpf_logical_pages_b.page_permission_name%type,
    p_default_physical_id JTF_DPF_PHYSICAL_PAGES_B.PHYSICAL_PAGE_ID%type);

  function logical_update(p_logical_page_id number,
    upd logical_update_rec) return number;

  -- creates a new logical with the designated parameters.  Always inserts
  -- 1 row into JTF_DPF_LOGICAL_PAGES and one row into JTF_DPF_LGCL_PHY_RULES
  --
  -- Returns one of the following values:
  --   1: new one successfully created
  --   2: new one not created: the given "p_new_name" is already taken
  --   3: new one not created: the given "p_new_name" is null
  --   4: new one not created: the given "p_default_physical_id" is bad
  function logical_new(
    p_new_asn varchar2,
    p_new_name varchar2,
    p_new_type varchar2,
    p_new_descr varchar2,
    p_new_page_controller_class varchar2,
    p_new_page_permission_name varchar2,
    p_default_physical_id JTF_DPF_PHYSICAL_PAGES_B.PHYSICAL_PAGE_ID%type)
      return number;

  -- updates table JTF_DPF_LGCL_PHY_RULES, so that the default_next_flag='F'
  -- rows which it contains for this logical_page_id are the rules and
  -- results specified by p_new_ones
  procedure logical_set_non_default_phys(p_logical_page_id number,
    p_new_ones new_phys_non_def_tbl);

  -- set next_logicals
  -- sets the default next logical of (p_flow_id, p_log_page_id) to
  -- next_log_page_id.  This might either update an existing
  -- row in JTF_DPF_LGCL_NEXT_RULES or insert a new one.
  -- if p_next_log_page_id is null, it means that the next logical
  -- of (p_flow_id, p_log_page_id) is null, i.e. that there's
  -- nothing after it (it's the last in the flow)
  --
  -- returns:
  --   1: successfully updated
  --   2: p_log_page_id is not found, or p_next_log_page_id
  --      is both not null and not a valid logical_page_id
  function next_logical_set_default(
    p_flow_id jtf_dpf_lgcl_next_rules.logical_flow_id%type,
    p_log_page_id jtf_dpf_lgcl_next_rules.logical_page_id%type,
    p_next_log_page_id jtf_dpf_lgcl_next_rules.logical_next_page_id%type)
      return number;

  -- sets up the non-default next logical rules for (flow_id, log_page_id).
  -- if there were already non-default rules for it, it removes them first
  procedure next_logical_set_non_default(
    p_flow_id jtf_dpf_lgcl_next_rules.logical_flow_id%type,
    p_log_page_id jtf_dpf_lgcl_next_rules.logical_page_id%type,
    p_new_ones new_next_log_non_def_tbl);

end;

 

/
