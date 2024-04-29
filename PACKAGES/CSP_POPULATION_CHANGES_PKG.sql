--------------------------------------------------------
--  DDL for Package CSP_POPULATION_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_POPULATION_CHANGES_PKG" AUTHID CURRENT_USER as
/* $Header: csptppcs.pls 120.2 2005/12/16 10:08:18 phegde noship $ */
-- Start of Comments
-- Package name     : CSP_POPULATION_CHANGES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

  PROCEDURE Insert_Row(
          px_POPULATION_CHANGES_ID  IN OUT NOCOPY NUMBER,
          p_ORGANIZATION_ID         NUMBER,
         -- p_INVENTORY_ITEM_ID       NUMBER,
          p_START_DATE              DATE,
          p_END_DATE                DATE,
          p_POPULATION_CHANGE       NUMBER,
          p_CREATION_DATE           DATE,
          p_CREATED_BY              NUMBER,
          p_LAST_UPDATE_DATE        DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN       NUMBER,
          p_PRODUCT_ID              NUMBER );

  PROCEDURE Update_Row(
          p_POPULATION_CHANGES_ID   NUMBER,
          p_ORGANIZATION_ID         NUMBER,
          --p_INVENTORY_ITEM_ID       NUMBER,
          p_START_DATE              DATE,
          p_END_DATE                DATE,
          p_POPULATION_CHANGE       NUMBER,
          p_CREATION_DATE           DATE,
          p_CREATED_BY              NUMBER,
          p_LAST_UPDATE_DATE        DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN       NUMBER,
          p_PRODUCT_ID              NUMBER );

  PROCEDURE Lock_Row(
          p_POPULATION_CHANGES_ID   NUMBER,
          p_ORGANIZATION_ID         NUMBER,
          --p_INVENTORY_ITEM_ID       NUMBER,
          p_START_DATE              DATE,
          p_END_DATE                DATE,
          p_POPULATION_CHANGE       NUMBER,
          p_CREATION_DATE           DATE,
          p_CREATED_BY              NUMBER,
          p_LAST_UPDATE_DATE        DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN       NUMBER,
          p_PRODUCT_ID              NUMBER);

  PROCEDURE Delete_Row(
    p_POPULATION_CHANGES_ID  NUMBER);
End CSP_POPULATION_CHANGES_PKG;

 

/
