--------------------------------------------------------
--  DDL for Package CSD_MASS_RO_SN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_MASS_RO_SN_PKG" AUTHID CURRENT_USER as
/* $Header: csdtmrss.pls 115.2 2003/08/13 17:22:34 mshirkol noship $ */
-- Start of Comments
-- Package name     : CSD_MASS_RO_SN_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_MASS_RO_SN_ID   IN OUT NOCOPY NUMBER
         ,p_REPAIR_LINE_ID    NUMBER
         ,p_SERIAL_NUMBER    VARCHAR2
         ,p_INSTANCE_ID    NUMBER
         ,p_PROCESS_FLAG    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_ATTRIBUTE_CATEGORY    VARCHAR2
         ,p_ATTRIBUTE1    VARCHAR2
         ,p_ATTRIBUTE2    VARCHAR2
         ,p_ATTRIBUTE3    VARCHAR2
         ,p_ATTRIBUTE4    VARCHAR2
         ,p_ATTRIBUTE5    VARCHAR2
         ,p_ATTRIBUTE6    VARCHAR2
         ,p_ATTRIBUTE7    VARCHAR2
         ,p_ATTRIBUTE8    VARCHAR2
         ,p_ATTRIBUTE9    VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Update_Row(
          p_MASS_RO_SN_ID    NUMBER
         ,p_REPAIR_LINE_ID    NUMBER
         ,p_SERIAL_NUMBER    VARCHAR2
         ,p_INSTANCE_ID    NUMBER
         ,p_PROCESS_FLAG    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_ATTRIBUTE_CATEGORY    VARCHAR2
         ,p_ATTRIBUTE1    VARCHAR2
         ,p_ATTRIBUTE2    VARCHAR2
         ,p_ATTRIBUTE3    VARCHAR2
         ,p_ATTRIBUTE4    VARCHAR2
         ,p_ATTRIBUTE5    VARCHAR2
         ,p_ATTRIBUTE6    VARCHAR2
         ,p_ATTRIBUTE7    VARCHAR2
         ,p_ATTRIBUTE8    VARCHAR2
         ,p_ATTRIBUTE9    VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Lock_Row(
          p_MASS_RO_SN_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Delete_Row(
    p_MASS_RO_SN_ID  NUMBER);
End CSD_MASS_RO_SN_PKG;

 

/
