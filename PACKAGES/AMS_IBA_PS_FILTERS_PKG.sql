--------------------------------------------------------
--  DDL for Package AMS_IBA_PS_FILTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IBA_PS_FILTERS_PKG" AUTHID CURRENT_USER as
/* $Header: amstflts.pls 115.5 2002/01/24 22:27:13 pkm ship     $ */
-- ======================================================================
-- Start of Comments
-- Package name     : AMS_IBA_PS_FILTERS_PKG
-- Purpose          : PACKAGE SPECIFICATION FOR TABLE HANDLER
-- History          : 05/25/01  Avijit Saha  CREATED
-- End of Comments
-- ======================================================================

procedure INSERT_ROW (
  P_FILTER_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_FILTER_REF_CODE in VARCHAR2,
  P_CONTENT_TYPE in VARCHAR2,
  P_GROUP_NUM in NUMBER,
  P_FILTER_NAME in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_FILTER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FILTER_REF_CODE in VARCHAR2,
  X_CONTENT_TYPE in VARCHAR2,
  X_GROUP_NUM in NUMBER,
  X_FILTER_NAME in VARCHAR2
);

procedure UPDATE_ROW (
  P_FILTER_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_FILTER_REF_CODE in VARCHAR2,
  P_CONTENT_TYPE in VARCHAR2,
  P_GROUP_NUM in NUMBER,
  P_FILTER_NAME in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  P_FILTER_ID in NUMBER
);

procedure ADD_LANGUAGE;

PROCEDURE translate_row (
   x_filter_id IN NUMBER,
   x_filter_name IN VARCHAR2,
   x_owner IN VARCHAR2
);

PROCEDURE load_row (
   x_filter_id           IN NUMBER,
   x_filter_ref_code     IN VARCHAR2,
   x_content_type        IN VARCHAR2,
   x_group_num           IN NUMBER,
   x_filter_name         IN VARCHAR2,
   x_owner               IN VARCHAR2
);

end AMS_IBA_PS_FILTERS_PKG;

 

/
