--------------------------------------------------------
--  DDL for Package MSD_HIERARCHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_HIERARCHIES_PKG" AUTHID CURRENT_USER as
/* $Header: msdhpkgs.pls 120.0 2005/05/26 01:15:37 appldev noship $ */

PROCEDURE LOAD_ROW(
          X_HIERARCHY_ID    varchar2,
          X_PLAN_TYPE   varchar2,
          X_HIERARCHY_NAME  varchar2,
          X_DESCRIPTION     varchar2,
          X_DIMENSION_CODE  varchar2,
          X_VALID_FLAG      varchar2,
          X_ATTRIBUTE_CATEGORY  varchar2,
          X_ATTRIBUTE1 varchar2,
          X_ATTRIBUTE2 varchar2,
          X_ATTRIBUTE3 varchar2,
          X_ATTRIBUTE4 varchar2,
          X_ATTRIBUTE5 varchar2,
          X_ATTRIBUTE6 varchar2,
          X_ATTRIBUTE7 varchar2,
          X_ATTRIBUTE8 varchar2,
          X_ATTRIBUTE9 varchar2,
          X_ATTRIBUTE10 varchar2,
          X_ATTRIBUTE11 varchar2,
          X_ATTRIBUTE12 varchar2,
          X_ATTRIBUTE13 varchar2,
          X_ATTRIBUTE14 varchar2,
          X_ATTRIBUTE15 varchar2,
          x_last_update_date in varchar2,
          x_owner in varchar2,
          x_custom_mode in varchar2);

PROCEDURE TRANSLATE_ROW(
        x_hierarchy_id in varchar2,
        X_PLAN_TYPE   varchar2,
        x_hierarchy_name varchar2,
        x_description varchar2,
        x_last_update_date in varchar2,
        x_owner in varchar2,
        x_custom_mode in varchar2);

PROCEDURE LOAD_HIERARCHY_LEVEL_ROW(
        x_HIERARCHY_ID in varchar2,
        X_PLAN_TYPE   varchar2,
        x_LEVEL_ID in varchar2,
        x_PARENT_LEVEL_ID in varchar2,
        x_RELATIONSHIP_VIEW in varchar2,
        x_LEVEL_VALUE_COLUMN in varchar2,
        x_LEVEL_VALUE_PK_COLUMN in varchar2,
        x_level_value_desc_column in varchar2,
        x_PARENT_VALUE_COLUMN in varchar2,
        x_PARENT_VALUE_PK_COLUMN in varchar2,
        x_parent_value_desc_column in varchar2,
        x_last_update_date in varchar2,
        x_owner in varchar2,
        x_custom_mode in varchar2);

function is_hierarchy_complete(hid number, p_plan_type varchar2 ) return boolean;

end MSD_HIERARCHIES_PKG;

 

/
