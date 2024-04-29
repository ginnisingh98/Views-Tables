--------------------------------------------------------
--  DDL for Package CSD_MASS_RO_SN_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_MASS_RO_SN_ERRORS_PKG" AUTHID CURRENT_USER as
/* $Header: csdtmres.pls 115.2 2003/08/13 17:23:40 mshirkol noship $ */
-- Start of Comments
-- Package name     : CSD_MASS_RO_SN_ERRORS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_MASS_RO_SN_ERROR_ID   IN OUT NOCOPY NUMBER
         ,p_REPAIR_LINE_ID   NUMBER
         ,p_MASS_RO_SN_ID    NUMBER
         ,p_ERROR_TYPE    VARCHAR2
         ,p_ERROR_MSG    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Update_Row(
          p_MASS_RO_SN_ERROR_ID    NUMBER
         ,p_REPAIR_LINE_ID   NUMBER
         ,p_MASS_RO_SN_ID    NUMBER
         ,p_ERROR_TYPE    VARCHAR2
         ,p_ERROR_MSG    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Lock_Row(
          p_MASS_RO_SN_ERROR_ID    NUMBER
         ,p_REPAIR_LINE_ID   NUMBER
         ,p_MASS_RO_SN_ID    NUMBER
         ,p_ERROR_TYPE    VARCHAR2
         ,p_ERROR_MSG    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Delete_Row(
    p_MASS_RO_SN_ERROR_ID  NUMBER);
End CSD_MASS_RO_SN_ERRORS_PKG;

 

/
