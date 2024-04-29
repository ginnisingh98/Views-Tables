--------------------------------------------------------
--  DDL for Package AR_BPA_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BPA_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: ARBPRULS.pls 120.3 2005/10/30 04:13:45 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RULE_ID in NUMBER,
  X_SAME_PRINTING_TEMPLATE_FLAG in VARCHAR2,
  X_PRIMARY_APP_ID in NUMBER,
  X_SECONDARY_APP_ID in NUMBER,
  X_RULE_SEARCH_ORDER in NUMBER,
  X_MATCH_ALL_ATTRIBUTES in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_RULE_NAME in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2,
  X_PRINT_RULE_SEARCH_ORDER in NUMBER,
  X_CM_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_DM_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_CB_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_DEP_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_GUAR_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_RULE_ID in NUMBER,
  X_SAME_PRINTING_TEMPLATE_FLAG in VARCHAR2,
  X_PRIMARY_APP_ID in NUMBER,
  X_SECONDARY_APP_ID in NUMBER,
  X_RULE_SEARCH_ORDER in NUMBER,
  X_MATCH_ALL_ATTRIBUTES in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_RULE_NAME in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2,
  X_PRINT_RULE_SEARCH_ORDER in NUMBER,
  X_CM_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_DM_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_CB_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_DEP_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_GUAR_SAME_PRT_TMPLT_FLAG in VARCHAR2
);

procedure UPDATE_ROW (
  X_RULE_ID in NUMBER,
  X_SAME_PRINTING_TEMPLATE_FLAG in VARCHAR2,
  X_PRIMARY_APP_ID in NUMBER,
  X_SECONDARY_APP_ID in NUMBER,
  X_RULE_SEARCH_ORDER in NUMBER,
  X_MATCH_ALL_ATTRIBUTES in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_RULE_NAME in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2,
  X_PRINT_RULE_SEARCH_ORDER in NUMBER,
  X_CM_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_DM_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_CB_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_DEP_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_GUAR_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_RULE_ID in NUMBER
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_RULE_ID in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
);

procedure LOAD_ROW (
  X_RULE_ID in NUMBER,
  X_PRIMARY_APP_ID in NUMBER,
  X_SECONDARY_APP_ID in NUMBER,
  X_RULE_SEARCH_ORDER in NUMBER,
  X_MATCH_ALL_ATTRIBUTES in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_RULE_NAME in VARCHAR2,
  X_RULE_DESCRIPTION in VARCHAR2,
  X_PRINT_RULE_SEARCH_ORDER in NUMBER,
  X_SAME_PRINTING_TEMPLATE_FLAG  IN VARCHAR2,
  X_CM_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_DM_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_CB_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_DEP_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_GUAR_SAME_PRT_TMPLT_FLAG in VARCHAR2,
  X_OWNER in VARCHAR2
);

end AR_BPA_RULES_PKG;

 

/
