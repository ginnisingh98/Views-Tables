--------------------------------------------------------
--  DDL for Package JTF_DPF_LOGICAL_PAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DPF_LOGICAL_PAGES_PKG" AUTHID CURRENT_USER as
/* $Header: jtfdpfls.pls 120.2 2005/10/25 05:17:31 psanyal ship $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_LOGICAL_PAGE_ID in NUMBER,
  X_LOGICAL_PAGE_NAME in VARCHAR2,
  X_LOGICAL_PAGE_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_PAGE_CONTROLLER_CLASS in VARCHAR2,
  X_PAGE_PERMISSION_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LOGICAL_PAGE_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_LOGICAL_PAGE_ID in NUMBER,
  X_LOGICAL_PAGE_NAME in VARCHAR2,
  X_LOGICAL_PAGE_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_PAGE_CONTROLLER_CLASS in VARCHAR2,
  X_PAGE_PERMISSION_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LOGICAL_PAGE_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_LOGICAL_PAGE_ID in NUMBER,
  X_LOGICAL_PAGE_NAME in VARCHAR2,
  X_LOGICAL_PAGE_TYPE in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_PAGE_CONTROLLER_CLASS in VARCHAR2,
  X_PAGE_PERMISSION_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LOGICAL_PAGE_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_LOGICAL_PAGE_ID in NUMBER
);
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
   X_LOGICAL_PAGE_NAME IN VARCHAR2,
   X_APPLICATION_ID IN VARCHAR2,
   X_LOGICAL_PAGE_DESCRIPTION IN VARCHAR2,
   X_OWNER IN VARCHAR2
);

procedure LOAD_ROW (
   X_LOGICAL_PAGE_NAME in VARCHAR2,
   X_APPLICATION_ID in VARCHAR2,
   X_LOGICAL_PAGE_DESCRIPTION  in VARCHAR2,
--   X_NUM_NON_DEF_RULES IN VARCHAR2,
   X_LOGICAL_PAGE_TYPE IN VARCHAR2,
   X_ENABLED_FLAG IN VARCHAR2,
   X_PAGE_CONTROLLER_CLASS IN VARCHAR2,
   X_PAGE_PERMISSION_NAME IN VARCHAR2,
   X_OWNER in VARCHAR2
);

-- this procedures truncates the list of l2p rules if needed.
-- We do this if the number of non-default rules is greater
-- than x_num_non_def_rules, and either we own the rows that make
-- up the rules, or force_update_flag = 'T'.

  procedure ceiling_lgcl_phy(
    X_LOGICAL_PAGE_NAME VARCHAR2,
    X_APPLICATION_ID VARCHAR2,
    X_NUM_NON_DEF_RULES VARCHAR2,
    X_OWNER VARCHAR2,
    X_FORCE_UPDATE_FLAG VARCHAR2);

-- this function's job is to find a logical which has
-- the given logical_page_name and appid.  Returns the logical_page_id
-- from table jtf_dpf_logical_pagse_b.  if no logical matches,
-- returns null.
function find(
  x_logical_page_name varchar2,
  x_application_id in varchar2
) return number;

-- an entry into table jtf_dpf_lgcl_phy_rules.  We should
-- decide whether this is an insert, update, or ingore, based on
-- the rules:
--  (1) if this set of l2p rules is not owned by us, then we should
--      leave it alone (unless x_force_update_flag='TRUE')
--  (2) a LOGICAL IS UNIQUELY identified logical_page_application_id +
--      logical_page_name
--  (3) for any logical, there can only be one rule for which
--      DEFAULT_PAGE_FLAG='T'
--  (4) for any logical, there can only be one rule which has
--       DEFAULT_PAGE_FLAG='F' and the given RULE_EVAL_SEQUENCE
  procedure ins_upd_or_ign_lgcl_phy_rules(
    x_rule_eval_sequence		varchar2,
    x_default_page_flag			varchar2,
    x_logical_page_application_id	varchar2,
    x_logical_page_name			varchar2,
    x_physical_page_application_id	varchar2,
    x_physical_page_name		varchar2,
    x_rule_application_id		varchar2,
    x_rule_name				varchar2,
    x_owner				varchar2,
    x_force_update_flag			varchar2);

end JTF_DPF_LOGICAL_PAGES_PKG;

 

/
