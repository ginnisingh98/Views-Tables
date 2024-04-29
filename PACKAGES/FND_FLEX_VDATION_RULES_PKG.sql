--------------------------------------------------------
--  DDL for Package FND_FLEX_VDATION_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_VDATION_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: AFFFVDRS.pls 120.2.12010000.1 2008/07/25 14:14:49 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_FLEX_VALIDATION_RULE_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_ERROR_SEGMENT_COLUMN_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ERROR_MESSAGE_TEXT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_FLEX_VALIDATION_RULE_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_ERROR_SEGMENT_COLUMN_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ERROR_MESSAGE_TEXT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_FLEX_VALIDATION_RULE_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_ERROR_SEGMENT_COLUMN_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ERROR_MESSAGE_TEXT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_FLEX_VALIDATION_RULE_NAME in VARCHAR2
);
procedure ADD_LANGUAGE;

PROCEDURE load_row
  (x_application_short_name       IN VARCHAR2,
   x_id_flex_code                 IN VARCHAR2,
   x_id_flex_structure_code       IN VARCHAR2,
   x_flex_validation_rule_name    IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_enabled_flag                 IN VARCHAR2,
   x_error_segment_column_name    IN VARCHAR2,
   x_start_date_active            IN DATE,
   x_end_date_active              IN DATE,
   x_error_message_text           IN VARCHAR2,
   x_description                  IN VARCHAR2);

PROCEDURE translate_row
  (x_application_short_name       IN VARCHAR2,
   x_id_flex_code                 IN VARCHAR2,
   x_id_flex_structure_code       IN VARCHAR2,
   x_flex_validation_rule_name    IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_error_message_text           IN VARCHAR2,
   x_description                  IN VARCHAR2);

end FND_FLEX_VDATION_RULES_PKG;

/
