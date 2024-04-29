--------------------------------------------------------
--  DDL for Package FND_VAL_ATTRIBUTE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_VAL_ATTRIBUTE_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: AFFFVATS.pls 120.2.12010000.1 2008/07/25 14:14:46 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_SEGMENT_ATTRIBUTE_TYPE in VARCHAR2,
  X_VALUE_ATTRIBUTE_TYPE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_DERIVATION_RULE_CODE in VARCHAR2,
  X_DERIVATION_RULE_VALUE1 in VARCHAR2,
  X_DERIVATION_RULE_VALUE2 in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_SEGMENT_ATTRIBUTE_TYPE in VARCHAR2,
  X_VALUE_ATTRIBUTE_TYPE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_DERIVATION_RULE_CODE in VARCHAR2,
  X_DERIVATION_RULE_VALUE1 in VARCHAR2,
  X_DERIVATION_RULE_VALUE2 in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_SEGMENT_ATTRIBUTE_TYPE in VARCHAR2,
  X_VALUE_ATTRIBUTE_TYPE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_DERIVATION_RULE_CODE in VARCHAR2,
  X_DERIVATION_RULE_VALUE1 in VARCHAR2,
  X_DERIVATION_RULE_VALUE2 in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_SEGMENT_ATTRIBUTE_TYPE in VARCHAR2,
  X_VALUE_ATTRIBUTE_TYPE in VARCHAR2
);
procedure ADD_LANGUAGE;

PROCEDURE load_row
  (x_application_short_name       IN VARCHAR2,
   x_id_flex_code                 IN VARCHAR2,
   x_segment_attribute_type       IN VARCHAR2,
   x_value_attribute_type         IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_required_flag                IN VARCHAR2,
   x_application_column_name      IN VARCHAR2,
   x_default_value                IN VARCHAR2,
   x_lookup_type                  IN VARCHAR2,
   x_derivation_rule_code         IN VARCHAR2,
   x_derivation_rule_value1       IN VARCHAR2,
   x_derivation_rule_value2       IN VARCHAR2,
   x_prompt                       IN VARCHAR2,
   x_description                  IN VARCHAR2);

PROCEDURE translate_row
  (x_application_short_name       IN VARCHAR2,
   x_id_flex_code                 IN VARCHAR2,
   x_segment_attribute_type       IN VARCHAR2,
   x_value_attribute_type         IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_prompt                       IN VARCHAR2,
   x_description                  IN VARCHAR2);

end FND_VAL_ATTRIBUTE_TYPES_PKG;

/
