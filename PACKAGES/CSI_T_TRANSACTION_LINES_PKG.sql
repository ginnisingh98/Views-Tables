--------------------------------------------------------
--  DDL for Package CSI_T_TRANSACTION_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_TRANSACTION_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: csitttls.pls 115.7 2002/11/12 00:27:33 rmamidip noship $ */
-- Package name     : CSI_T_TRANSACTION_LINES_PKG
-- Purpose          : Table handler for CSI_T_TRANSACTION_LINES
-- History          : bmanesh created 12-MAY-2001
-- NOTE             :


---Added (Start) for m-to-m enhancements
-- p_SOURCE_TXN_HEADER_ID added to various modules
---Added (End) for m-to-m enhancements

-- Added for CZ Integration (Begin)
-- Following attributes are added to various modules
--P_CONFIG_SESSION_HDR_ID  NUMBER
--P_CONFIG_SESSION_REV_NUM NUMBER
--P_CONFIG_SESSION_ITEM_ID NUMBER
--P_CONFIG_VALID_STATUS VARCHAR2
--P_SOURCE_TRANSACTION_STATUS VARCHAR2
-- Added for CZ Integration (End)

PROCEDURE Insert_Row(
          px_TRANSACTION_LINE_ID   IN OUT NOCOPY NUMBER,
          p_SOURCE_TRANSACTION_TYPE_ID    NUMBER,
          p_SOURCE_TRANSACTION_TABLE    VARCHAR2,
          p_SOURCE_TXN_HEADER_ID    NUMBER,
          p_SOURCE_TRANSACTION_ID    NUMBER,
          P_CONFIG_SESSION_HDR_ID  NUMBER ,
          P_CONFIG_SESSION_REV_NUM NUMBER ,
          P_CONFIG_SESSION_ITEM_ID NUMBER ,
          P_CONFIG_VALID_STATUS VARCHAR2 ,
          P_SOURCE_TRANSACTION_STATUS VARCHAR2 ,
          p_ERROR_CODE    VARCHAR2,
          p_ERROR_EXPLANATION    VARCHAR2,
          p_PROCESSING_STATUS    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_CONTEXT    VARCHAR2);

PROCEDURE Update_Row(
          p_TRANSACTION_LINE_ID    NUMBER,
          p_SOURCE_TRANSACTION_TYPE_ID    NUMBER,
          p_SOURCE_TRANSACTION_TABLE    VARCHAR2,
          p_SOURCE_TXN_HEADER_ID    NUMBER,
          p_SOURCE_TRANSACTION_ID    NUMBER,
          P_CONFIG_SESSION_HDR_ID  NUMBER ,
          P_CONFIG_SESSION_REV_NUM NUMBER ,
          P_CONFIG_SESSION_ITEM_ID NUMBER ,
          P_CONFIG_VALID_STATUS VARCHAR2 ,
          P_SOURCE_TRANSACTION_STATUS VARCHAR2 ,
          p_ERROR_CODE    VARCHAR2,
          p_ERROR_EXPLANATION    VARCHAR2,
          p_PROCESSING_STATUS    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_CONTEXT    VARCHAR2);

PROCEDURE Lock_Row(
          p_TRANSACTION_LINE_ID    NUMBER,
          p_SOURCE_TRANSACTION_TYPE_ID    NUMBER,
          p_SOURCE_TRANSACTION_TABLE    VARCHAR2,
          p_SOURCE_TXN_HEADER_ID    NUMBER,
          p_SOURCE_TRANSACTION_ID    NUMBER,
          P_CONFIG_SESSION_HDR_ID  NUMBER ,
          P_CONFIG_SESSION_REV_NUM NUMBER ,
          P_CONFIG_SESSION_ITEM_ID NUMBER ,
          P_CONFIG_VALID_STATUS VARCHAR2 ,
          P_SOURCE_TRANSACTION_STATUS VARCHAR2 ,
          p_ERROR_CODE    VARCHAR2,
          p_ERROR_EXPLANATION    VARCHAR2,
          p_PROCESSING_STATUS    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_CONTEXT    VARCHAR2);

PROCEDURE Delete_Row(
    p_TRANSACTION_LINE_ID  NUMBER);
End CSI_T_TRANSACTION_LINES_PKG;

 

/
