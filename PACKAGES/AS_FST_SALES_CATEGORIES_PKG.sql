--------------------------------------------------------
--  DDL for Package AS_FST_SALES_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_FST_SALES_CATEGORIES_PKG" AUTHID CURRENT_USER as
/* $Header: asxtfsts.pls 115.5 2003/11/21 08:13:06 sumahali ship $ */
-- Start of Comments
-- Package name     : AS_FST_SALES_CATEGORIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_FST_SALES_CATEGORY_ID   IN OUT NOCOPY NUMBER,
          p_PRODUCT_CATEGORY_ID    NUMBER,
          p_PRODUCT_CAT_SET_ID    NUMBER,
          p_FORECAST_CATEGORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE);

PROCEDURE Update_Row(
          p_FST_SALES_CATEGORY_ID    NUMBER,
          p_PRODUCT_CATEGORY_ID    NUMBER,
          p_PRODUCT_CAT_SET_ID    NUMBER,
          p_FORECAST_CATEGORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE);

PROCEDURE Lock_Row(
          p_FST_SALES_CATEGORY_ID    NUMBER,
          p_PRODUCT_CATEGORY_ID    NUMBER,
          p_PRODUCT_CAT_SET_ID    NUMBER,
          p_FORECAST_CATEGORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE);

PROCEDURE Delete_Row(
    p_FST_SALES_CATEGORY_ID  NUMBER);
End AS_FST_SALES_CATEGORIES_PKG;

 

/
