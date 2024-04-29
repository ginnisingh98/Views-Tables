--------------------------------------------------------
--  DDL for Package CSI_TXN_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_TXN_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: csittsts.pls 115.6 2002/11/12 00:26:07 rmamidip noship $ */
-- Start of Comments
-- Package name     : CSI_TXN_TYPES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_TRANSACTION_TYPE_ID   IN OUT NOCOPY NUMBER,
          p_SOURCE_APPLICATION_ID    NUMBER,
          p_SOURCE_TRANSACTION_TYPE    VARCHAR2,
          p_SOURCE_TXN_TYPE_NAME    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_SOURCE_OBJECT_CODE    VARCHAR2,
          p_IN_OUT_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_SUB_TYPE_ID     NUMBER,
          p_DEFAULT_FLAG    VARCHAR2,
          p_UPDATE_IB_FLAG    VARCHAR2,
          p_SEEDED_FLAG       VARCHAR2);

PROCEDURE Update_Row(
          p_TRANSACTION_TYPE_ID    NUMBER,
          p_SOURCE_APPLICATION_ID    NUMBER,
          p_SOURCE_TRANSACTION_TYPE    VARCHAR2,
          p_SOURCE_TXN_TYPE_NAME    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_SOURCE_OBJECT_CODE    VARCHAR2,
          p_IN_OUT_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_SUB_TYPE_ID     NUMBER,
          p_DEFAULT_FLAG    VARCHAR2,
          p_UPDATE_IB_FLAG    VARCHAR2);

PROCEDURE Lock_Row(
          p_TRANSACTION_TYPE_ID    NUMBER,
          p_SOURCE_APPLICATION_ID    NUMBER,
          p_SOURCE_TRANSACTION_TYPE    VARCHAR2,
          p_SOURCE_TXN_TYPE_NAME    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_SOURCE_OBJECT_CODE    VARCHAR2,
          p_IN_OUT_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_SUB_TYPE_ID     NUMBER,
          p_DEFAULT_FLAG    VARCHAR2,
          p_UPDATE_IB_FLAG    VARCHAR2,
          p_SEEDED_FLAG       VARCHAR2);


PROCEDURE Delete_Row(
    p_TRANSACTION_TYPE_ID  NUMBER,
    p_SUB_TYPE_ID     NUMBER);
End CSI_TXN_TYPES_PKG;

 

/
