--------------------------------------------------------
--  DDL for Package FND_FLEX_VALUE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_VALUE_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: AFFFVLRS.pls 120.2.12010000.1 2008/07/25 14:14:54 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_FLEX_VALUE_RULE_ID in NUMBER,
  X_FLEX_VALUE_RULE_NAME in VARCHAR2,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_PARENT_FLEX_VALUE_LOW in VARCHAR2,
  X_PARENT_FLEX_VALUE_HIGH in VARCHAR2,
  X_ERROR_MESSAGE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_FLEX_VALUE_RULE_ID in NUMBER,
  X_FLEX_VALUE_RULE_NAME in VARCHAR2,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_PARENT_FLEX_VALUE_LOW in VARCHAR2,
  X_PARENT_FLEX_VALUE_HIGH in VARCHAR2,
  X_ERROR_MESSAGE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_FLEX_VALUE_RULE_ID in NUMBER,
  X_FLEX_VALUE_RULE_NAME in VARCHAR2,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_PARENT_FLEX_VALUE_LOW in VARCHAR2,
  X_PARENT_FLEX_VALUE_HIGH in VARCHAR2,
  X_ERROR_MESSAGE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_FLEX_VALUE_RULE_ID in NUMBER
);
procedure ADD_LANGUAGE;

PROCEDURE load_row
  (x_flex_value_set_name          IN VARCHAR2,
   x_parent_flex_value_low        IN VARCHAR2,
   x_flex_value_rule_name         IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_parent_flex_value_high       IN VARCHAR2,
   x_error_message                IN VARCHAR2,
   x_description                  IN VARCHAR2);

PROCEDURE translate_row
  (x_flex_value_set_name          IN VARCHAR2,
   x_parent_flex_value_low        IN VARCHAR2,
   x_flex_value_rule_name         IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_error_message                IN VARCHAR2,
   x_description                  IN VARCHAR2);

end FND_FLEX_VALUE_RULES_PKG;

/
