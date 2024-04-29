--------------------------------------------------------
--  DDL for Package CSD_GENERIC_ERRMSGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_GENERIC_ERRMSGS_PKG" AUTHID CURRENT_USER as
/* $Header: csdtgems.pls 115.0 2003/08/29 18:47:44 vparvath noship $ */
-- Start of Comments
-- Package name     : CSD_GENERIC_ERRMSGS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_GENERIC_ERRMSGS_ID   IN OUT NOCOPY NUMBER
         ,p_MODULE_CODE    VARCHAR2
         ,p_SOURCE_ENTITY_ID1    NUMBER
         ,p_SOURCE_ENTITY_ID2    NUMBER
         ,p_SOURCE_ENTITY_TYPE_CODE    VARCHAR2
         ,p_MSG_TYPE_CODE    VARCHAR2
         ,p_MSG    VARCHAR2
         ,p_MSG_STATUS    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Update_Row(
          p_GENERIC_ERRMSGS_ID    NUMBER
         ,p_MODULE_CODE    VARCHAR2
         ,p_SOURCE_ENTITY_ID1    NUMBER
         ,p_SOURCE_ENTITY_ID2    NUMBER
         ,p_SOURCE_ENTITY_TYPE_CODE    VARCHAR2
         ,p_MSG_TYPE_CODE    VARCHAR2
         ,p_MSG    VARCHAR2
         ,p_MSG_STATUS    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Lock_Row(
          p_GENERIC_ERRMSGS_ID    NUMBER
         ,p_MODULE_CODE    VARCHAR2
         ,p_SOURCE_ENTITY_ID1    NUMBER
         ,p_SOURCE_ENTITY_ID2    NUMBER
         ,p_SOURCE_ENTITY_TYPE_CODE    VARCHAR2
         ,p_MSG_TYPE_CODE    VARCHAR2
         ,p_MSG    VARCHAR2
         ,p_MSG_STATUS    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Delete_Row(
    p_GENERIC_ERRMSGS_ID  NUMBER);
End CSD_GENERIC_ERRMSGS_PKG;

 

/
