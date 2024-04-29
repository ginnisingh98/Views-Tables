--------------------------------------------------------
--  DDL for Package JTF_DPF_LOGICAL_FLOWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DPF_LOGICAL_FLOWS_PKG" AUTHID CURRENT_USER as
/* $Header: jtfdpffs.pls 120.2 2005/10/25 05:16:54 psanyal ship $ */
-- this creates a new in jtf_dpf_logical_flows_b and in _tl.
-- the ENABLED_CLONE_FLAG has special handling. It's set to 'F',
-- except if it would be the only Flow with this appid and flow_name,
-- in which case it's set to 'T'
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_LOGICAL_FLOW_ID in NUMBER,
  X_LOGICAL_FLOW_HEAD_ID in NUMBER,
  X_LOGICAL_FLOW_NAME in VARCHAR2,
  X_SECURE_FLOW_FLAG in VARCHAR2,
  X_VALIDATE_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FLOW_FINALIZER_CLASS in VARCHAR2,
  X_RETURN_TO_PAGE_ID in NUMBER,
  X_BASE_FLOW_FLAG in VARCHAR2,
--  X_ENABLED_CLONE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LOGICAL_FLOW_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_LOGICAL_FLOW_ID in NUMBER,
  X_LOGICAL_FLOW_HEAD_ID in NUMBER,
  X_LOGICAL_FLOW_NAME in VARCHAR2,
  X_SECURE_FLOW_FLAG in VARCHAR2,
  X_VALIDATE_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FLOW_FINALIZER_CLASS in VARCHAR2,
  X_RETURN_TO_PAGE_ID in NUMBER,
  X_BASE_FLOW_FLAG in VARCHAR2,
  X_ENABLED_CLONE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LOGICAL_FLOW_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_LOGICAL_FLOW_ID in NUMBER,
  X_LOGICAL_FLOW_HEAD_ID in NUMBER,
  X_LOGICAL_FLOW_NAME in VARCHAR2,
  X_SECURE_FLOW_FLAG in VARCHAR2,
  X_VALIDATE_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FLOW_FINALIZER_CLASS in VARCHAR2,
  X_RETURN_TO_PAGE_ID in NUMBER,
  X_BASE_FLOW_FLAG in VARCHAR2,
--  X_ENABLED_CLONE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LOGICAL_FLOW_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_LOGICAL_FLOW_ID in NUMBER
);
procedure ADD_LANGUAGE;

-- find the flow_id for a flow which has the given name and appid.
-- if there are more than one flow_id which match, preference is
-- given to:
--  (1) the oldest which has last_updated_by = x_last_updated_by, if any, else
--  (2) the oldest
-- where 'oldest' means that it has the earliest last_update_date
--
-- If no pages have that name and appid, returns null

function find_oldest_prefer_owned_by(x_logical_flow_name varchar2,
  x_application_id varchar2, x_last_updated_by number) return number;

  procedure insert_flow_params(
    x_flow_id number,
    x_parameter_name varchar2,
    x_parameter_type varchar2,
    x_parameter_sequence varchar2,
    x_owner varchar2);

  procedure update_flow_params(
    x_flow_id number,
    x_parameter_name varchar2,
    x_parameter_type varchar2,
    x_parameter_sequence varchar2,
    x_owner varchar2);

  procedure translate_row(
    x_flow_name varchar2,
    x_application_id varchar2,
    x_flow_description varchar2,
    x_owner varchar2);

  procedure load_row(
    X_APPLICATION_ID VARCHAR2,
    X_LOGICAL_FLOW_NAME VARCHAR2,
    X_HEAD_LOGICAL_PAGE_NAME VARCHAR2,
    X_HEAD_LOGICAL_PAGE_APP_ID VARCHAR2,
    X_SECURE_FLOW_FLAG VARCHAR2,
    X_VALIDATE_FLAG VARCHAR2,
    X_FLOW_FINALIZER_CLASS VARCHAR2,
    X_RTN_TO_LOGICAL_PAGE_NAME VARCHAR2,
    X_RTN_TO_LOGICAL_PAGE_APP_ID VARCHAR2,
    X_BASE_FLOW_FLAG VARCHAR2,
--    X_ENABLED_CLONE_FLAG VARCHAR2,
    X_LOGICAL_FLOW_DESCRIPTION VARCHAR2,
    X_OWNER in VARCHAR2);

-- an entry into table jtf_dpf_lgcl_next_rules.  We should
-- decide whether this is an update or an insert, based on
-- the rules:
--  (1) a LOGICAL IS UNIQUELY identified logical_page_application_id +
--      logical_page_name
--  (2) for any (flow, logical) there can only be one rule for which
--      DEFAULT_NEXT_FLAG='T'
--  (3) for any (flow, logical) there can only be one rule which has
--       DEFAULT_NEXT_FLAG='F' and the given RULE_EVAL_SEQ
  procedure ins_upd_or_ign_lgcl_next_rules(
    x_rule_eval_seq varchar2,
    x_default_next_flag varchar2,
    x_logical_flow_application_id varchar2,
    x_logical_flow_name varchar2,
    x_logical_page_application_id varchar2,
    x_logical_page_name varchar2,
    x_logical_next_page_app_id varchar2,
    x_logical_next_page_name varchar2,
    x_rule_application_id varchar2,
    x_rule_name varchar2,
    x_owner varchar2,
    x_force_update_flag varchar2);

end JTF_DPF_LOGICAL_FLOWS_PKG;

 

/
