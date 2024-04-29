--------------------------------------------------------
--  DDL for Package FND_DESCR_FLEX_CONTEXTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DESCR_FLEX_CONTEXTS_PKG" AUTHID CURRENT_USER as
/* $Header: AFFFDFCS.pls 120.2.12010000.1 2008/07/25 14:13:47 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_GLOBAL_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_NAM in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_GLOBAL_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_NAM in VARCHAR2
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_GLOBAL_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_NAM in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2
);
procedure ADD_LANGUAGE;

PROCEDURE load_row
  (x_application_short_name       IN VARCHAR2,
   x_descriptive_flexfield_name   IN VARCHAR2,
   x_descriptive_flex_context_cod IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_enabled_flag                 IN VARCHAR2,
   x_global_flag                  IN VARCHAR2,
   x_description                  IN VARCHAR2,
   x_descriptive_flex_context_nam IN VARCHAR2);

PROCEDURE translate_row
  (x_application_short_name       IN VARCHAR2,
   x_descriptive_flexfield_name   IN VARCHAR2,
   x_descriptive_flex_context_cod IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_description                  IN VARCHAR2,
   x_descriptive_flex_context_nam IN VARCHAR2);

end FND_DESCR_FLEX_CONTEXTS_PKG;

/
