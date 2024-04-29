--------------------------------------------------------
--  DDL for Package AS_PE_INT_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_PE_INT_CATEGORIES_PKG" AUTHID CURRENT_USER as
/* $Header: asxtpeis.pls 120.0 2005/06/02 17:23:01 appldev noship $ */
-- Start of Comments
-- Package name     : AS_PE_INT_CATEGORIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_PE_INT_CATEGORY_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTA_ID    NUMBER,
          -- mapping type is obsoleted during uptake of product catalog
          --p_MAPPING_TYPE    VARCHAR2,
          p_PRODUCT_CATEGORY_ID     NUMBER,
          p_PRODUCT_CAT_SET_ID      NUMBER);

PROCEDURE Update_Row(
          p_PE_INT_CATEGORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTA_ID    NUMBER,
          -- mapping type is obsoleted during uptake of product catalog
          --p_MAPPING_TYPE    VARCHAR2,
          p_PRODUCT_CATEGORY_ID     NUMBER,
          p_PRODUCT_CAT_SET_ID      NUMBER);

PROCEDURE Lock_Row(
          p_PE_INT_CATEGORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTA_ID    NUMBER,
          -- mapping type is obsoleted during uptake of product catalog
          --p_MAPPING_TYPE    VARCHAR2,
          p_PRODUCT_CATEGORY_ID     NUMBER,
          p_PRODUCT_CAT_SET_ID      NUMBER);

PROCEDURE Delete_Row(
    p_PE_INT_CATEGORY_ID  NUMBER);
End AS_PE_INT_CATEGORIES_PKG;

 

/
