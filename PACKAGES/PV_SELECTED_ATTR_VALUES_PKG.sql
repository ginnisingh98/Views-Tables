--------------------------------------------------------
--  DDL for Package PV_SELECTED_ATTR_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_SELECTED_ATTR_VALUES_PKG" AUTHID CURRENT_USER as
/* $Header: pvrtsavs.pls 115.3 2003/09/24 22:07:54 pklin ship $ */
-- Start of Comments
-- Package name     : PV_SELECTED_ATTR_VALUES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_ATTR_VALUE_ID   IN OUT NOCOPY NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_PROGRAM_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_SELECTION_CRITERIA_ID    NUMBER
         ,p_ATTRIBUTE_VALUE    VARCHAR2
         ,p_ATTRIBUTE_TO_VALUE    VARCHAR2
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
         ,p_ATTRIBUTE15    VARCHAR2
         ,p_SCORE          NUMBER);

PROCEDURE Update_Row(
          p_ATTR_VALUE_ID    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_PROGRAM_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_SELECTION_CRITERIA_ID    NUMBER
         ,p_ATTRIBUTE_VALUE    VARCHAR2
         ,p_ATTRIBUTE_TO_VALUE    VARCHAR2
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
         ,p_ATTRIBUTE15    VARCHAR2
         ,p_SCORE          NUMBER);

PROCEDURE Lock_Row(
          p_ATTR_VALUE_ID    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_PROGRAM_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_SELECTION_CRITERIA_ID    NUMBER
         ,p_ATTRIBUTE_VALUE    VARCHAR2
         ,p_ATTRIBUTE_TO_VALUE    VARCHAR2
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
         ,p_ATTRIBUTE15    VARCHAR2
         ,p_SCORE          NUMBER);

PROCEDURE Delete_Row(
    p_ATTR_VALUE_ID  NUMBER);
End PV_SELECTED_ATTR_VALUES_PKG;

 

/
