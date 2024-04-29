--------------------------------------------------------
--  DDL for Package Body CSD_MASS_RO_SN_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_MASS_RO_SN_ERRORS_PKG" as
/* $Header: csdtmreb.pls 115.3 2003/11/24 18:48:59 vparvath noship $ */
-- Start of Comments
-- Package name     : CSD_MASS_RO_SN_ERRORS_PKG
-- Purpose          :
-- History          : stubbing out the procs in this since this is no
--                    longer used in the R10. Generic error messages table
--                    is created instead of this.
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_MASS_RO_SN_ERRORS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdtmreb.pls';

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
         ,p_OBJECT_VERSION_NUMBER    NUMBER)

 IS
BEGIN
null;
End Insert_Row;

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
         ,p_OBJECT_VERSION_NUMBER    NUMBER)

IS
BEGIN
null;
END Update_Row;

PROCEDURE Delete_Row(
    p_MASS_RO_SN_ERROR_ID  NUMBER)
IS
BEGIN
null;
END Delete_Row;

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
         ,p_OBJECT_VERSION_NUMBER    NUMBER)

 IS
BEGIN
null;
END Lock_Row;

End CSD_MASS_RO_SN_ERRORS_PKG;

/
