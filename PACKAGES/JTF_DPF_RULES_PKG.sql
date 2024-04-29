--------------------------------------------------------
--  DDL for Package JTF_DPF_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DPF_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: jtfdpfrs.pls 120.2 2005/10/25 05:18:56 psanyal ship $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_RULE_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_RULE_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_RULE_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_RULE_ID in NUMBER
);
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
   X_RULE_NAME IN VARCHAR2,
   X_APPLICATION_ID IN VARCHAR2,
   X_RULE_DESCRIPTION IN VARCHAR2,
   X_OWNER IN VARCHAR2
);

-- this has to remember to delete any param in jtf_dpf_rule_aprams
-- which matches this rule_name and appid, but has sequence higher
-- than x_num_params.
procedure LOAD_ROW (
   X_RULE_NAME in VARCHAR2,
   X_APPLICATION_ID in VARCHAR2,
   X_RULE_DESCRIPTION  in VARCHAR2,
   X_NUM_PARAMS IN VARCHAR2,
   X_OWNER in VARCHAR2
);

-- insert a row into the rule_params table
procedure INSERT_RULE_PARAMS(
  X_RULE_PARAM_SEQUENCE NUMBER,
  X_RULE_ID NUMBER,
  X_RULE_PARAM_CONDITION VARCHAR2,
  X_RULE_PARAM_NAME VARCHAR2,
  X_RULE_PARAM_VALUE VARCHAR2,
  X_OWNER IN VARCHAR2
);

-- update a row into the rule_params table
procedure UPDATE_RULE_PARAMS(
  X_RULE_PARAM_SEQUENCE NUMBER,
  X_RULE_ID NUMBER,
  X_RULE_PARAM_CONDITION VARCHAR2,
  X_RULE_PARAM_NAME VARCHAR2,
  X_RULE_PARAM_VALUE VARCHAR2,
  X_OWNER IN VARCHAR2
);

-- this function's job is to find a rule which has
-- the given rule_name and appid.  Returns the rule_id
-- from table jtf_dpf_rules_b.  if no rule matches,
-- returns null.
function find(
  x_rule_name varchar2,
  x_application_id in varchar2
) return number;

end JTF_DPF_RULES_PKG;

 

/
