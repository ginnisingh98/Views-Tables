--------------------------------------------------------
--  DDL for Package CSP_FAILURE_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_FAILURE_RATES_PKG" AUTHID CURRENT_USER as
/* $Header: csptfras.pls 115.3 2002/11/26 07:19:03 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_FAILURE_RATES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_FAILURE_RATE_ID   IN OUT NOCOPY NUMBER
         ,p_PRODUCT_ID    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_CALCULATED_FAILURE_RATE    NUMBER
         ,p_MANUAL_FAILURE_RATE    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_PLANNING_PARAMETERS_ID    NUMBER);
PROCEDURE Update_Row(
          p_FAILURE_RATE_ID    NUMBER
         ,p_PRODUCT_ID    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_CALCULATED_FAILURE_RATE    NUMBER
         ,p_MANUAL_FAILURE_RATE    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_PLANNING_PARAMETERS_ID    NUMBER);
PROCEDURE Lock_Row(
          p_FAILURE_RATE_ID    NUMBER
         ,p_PRODUCT_ID    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_CALCULATED_FAILURE_RATE    NUMBER
         ,p_MANUAL_FAILURE_RATE    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_PLANNING_PARAMETERS_ID    NUMBER);
PROCEDURE Delete_Row(
    p_FAILURE_RATE_ID  NUMBER);
End CSP_FAILURE_RATES_PKG;

 

/
