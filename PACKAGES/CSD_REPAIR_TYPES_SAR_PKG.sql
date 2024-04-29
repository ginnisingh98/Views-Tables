--------------------------------------------------------
--  DDL for Package CSD_REPAIR_TYPES_SAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_TYPES_SAR_PKG" AUTHID CURRENT_USER as
/* $Header: csdtsars.pls 115.2 2003/01/06 22:20:00 takwong noship $ */
-- Start of Comments
-- Package name     : CSD_REPAIR_TYPES_SAR_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_REPAIR_TXN_BILLING_TYPE_ID IN OUT NOCOPY NUMBER
         ,p_REPAIR_TYPE_ID    NUMBER
         ,p_TXN_BILLING_TYPE_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
);
PROCEDURE Update_Row(
          p_REPAIR_TXN_BILLING_TYPE_ID    NUMBER
         ,p_REPAIR_TYPE_ID    NUMBER
         ,p_TXN_BILLING_TYPE_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
);
PROCEDURE Lock_Row(
          p_REPAIR_TXN_BILLING_TYPE_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
);
PROCEDURE Delete_Row(
    p_REPAIR_TXN_BILLING_TYPE_ID  NUMBER);
End CSD_REPAIR_TYPES_SAR_PKG;

 

/
