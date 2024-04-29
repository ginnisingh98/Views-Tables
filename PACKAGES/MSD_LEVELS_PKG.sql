--------------------------------------------------------
--  DDL for Package MSD_LEVELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_LEVELS_PKG" AUTHID CURRENT_USER as
/* $Header: msdlpkgs.pls 120.1 2006/01/31 21:53:47 amitku noship $ */

PROCEDURE LOAD_ROW(
          x_level_id in varchar2,
          x_plan_type in varchar2,
          x_level_name varchar2,
          x_description varchar2,
          x_DIMENSION_CODE VARCHAR2,
          x_LEVEL_TYPE_CODE VARCHAR2,
          X_ORG_RELATIONSHIP_VIEW VARCHAR2,
          X_ATTRIBUTE1_CONTEXT VARCHAR2,
          X_ATTRIBUTE2_CONTEXT VARCHAR2,
          X_ATTRIBUTE3_CONTEXT VARCHAR2,
          X_ATTRIBUTE4_CONTEXT VARCHAR2,
          X_ATTRIBUTE5_CONTEXT VARCHAR2,
          X_ATTRIBUTE_CATEGORY VARCHAR2,
          X_ATTRIBUTE1 VARCHAR2,
          X_ATTRIBUTE2 VARCHAR2,
          X_ATTRIBUTE3 VARCHAR2,
          X_ATTRIBUTE4 VARCHAR2,
          X_ATTRIBUTE5 VARCHAR2,
          X_ATTRIBUTE6 VARCHAR2,
          X_ATTRIBUTE7 VARCHAR2,
          X_ATTRIBUTE8 VARCHAR2,
          X_ATTRIBUTE9 VARCHAR2,
          X_ATTRIBUTE10 VARCHAR2,
          X_ATTRIBUTE11 VARCHAR2,
          X_ATTRIBUTE12 VARCHAR2,
          X_ATTRIBUTE13 VARCHAR2,
          X_ATTRIBUTE14 VARCHAR2,
          X_ATTRIBUTE15 VARCHAR2,
          x_last_update_date in varchar2,
          x_owner in varchar2,
          x_custom_mode in varchar2,
          x_system_attribute1_context in varchar2,
          x_system_attribute2_context in varchar2);

PROCEDURE TRANSLATE_ROW(
        x_level_id in varchar2,
        x_plan_type in varchar2,
        x_level_name varchar2,
        x_description varchar2,
        x_last_update_date in varchar2,
        x_owner in varchar2,
        x_custom_mode in varchar2);

end MSD_LEVELS_PKG;

 

/
