--------------------------------------------------------
--  DDL for Package IEX_STRATEGY_USER_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRATEGY_USER_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: iextsuis.pls 120.0 2004/01/24 03:23:08 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_STRATEGY_USER_ITEMS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_STRATEGY_USER_ITEM_ID   IN OUT NOCOPY NUMBER
         ,p_STRATEGY_ID    NUMBER
         ,p_WORK_ITEM_TEMP_ID    NUMBER
         ,p_WORK_ITEM_ORDER    NUMBER
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_PROGRAM_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_STRATEGY_TEMPLATE_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_OPERATION    VARCHAR2);

PROCEDURE Update_Row(
          p_STRATEGY_USER_ITEM_ID    NUMBER
         ,p_STRATEGY_ID    NUMBER
         ,p_WORK_ITEM_TEMP_ID    NUMBER
         ,p_WORK_ITEM_ORDER    NUMBER
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_PROGRAM_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_STRATEGY_TEMPLATE_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_OPERATION    VARCHAR2);

PROCEDURE Lock_Row(
          p_STRATEGY_USER_ITEM_ID    NUMBER
         ,p_STRATEGY_ID    NUMBER
         ,p_WORK_ITEM_TEMP_ID    NUMBER
         ,p_WORK_ITEM_ORDER    NUMBER
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_PROGRAM_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_STRATEGY_TEMPLATE_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_OPERATION    VARCHAR2);

PROCEDURE Delete_Row(
    p_STRATEGY_USER_ITEM_ID  NUMBER);
End IEX_STRATEGY_USER_ITEMS_PKG;

 

/
