--------------------------------------------------------
--  DDL for Package CSP_STOCK_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_STOCK_LISTS_PKG" AUTHID CURRENT_USER AS
/* $Header: csptpsls.pls 115.3 2002/11/26 06:34:49 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_STOCK_LISTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          p_ORGANIZATION_ID    NUMBER
         ,p_INVENTORY_ITEM_ID   IN NUMBER
         ,p_SUBINVENTORY_CODE    VARCHAR2
         ,p_MANUAL_AUTO    VARCHAR2
         ,p_REASON_CODE    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
);
PROCEDURE Update_Row(
          p_ORGANIZATION_ID    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_SUBINVENTORY_CODE    VARCHAR2
         ,p_MANUAL_AUTO    VARCHAR2
         ,p_REASON_CODE    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
);
PROCEDURE Lock_Row(
          p_ORGANIZATION_ID    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_SUBINVENTORY_CODE    VARCHAR2
         ,p_MANUAL_AUTO    VARCHAR2
         ,p_REASON_CODE    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
);

PROCEDURE Delete_Row(
    p_INVENTORY_ITEM_ID  NUMBER
   ,p_ORGANIZATION_ID    NUMBER
   ,p_SUBINVENTORY_CODE  VARCHAR2
);

End CSP_STOCK_LISTS_PKG;

 

/
