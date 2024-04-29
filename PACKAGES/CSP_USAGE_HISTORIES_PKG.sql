--------------------------------------------------------
--  DDL for Package CSP_USAGE_HISTORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_USAGE_HISTORIES_PKG" AUTHID CURRENT_USER as
/* $Header: csptpuss.pls 115.3 2002/11/26 06:43:46 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_USAGE_HISTORIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_USAGE_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_PERIOD_TYPE    VARCHAR2,
          p_PERIOD_START_DATE    DATE,
          p_QUANTITY    NUMBER,
		p_HISTORY_DATA_TYPE NUMBER DEFAULT NULL,
		p_USAGE_HEADER_ID NUMBER DEFAULT NULL,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
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
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_TRANSACTION_TYPE_ID    NUMBER);

PROCEDURE Update_Row(
          p_USAGE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_PERIOD_TYPE    VARCHAR2,
          p_PERIOD_START_DATE    DATE,
          p_QUANTITY    NUMBER,
		p_HISTORY_DATA_TYPE NUMBER DEFAULT NULL,
		p_USAGE_HEADER_ID NUMBER DEFAULT NULL,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
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
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_TRANSACTION_TYPE_ID    NUMBER);

PROCEDURE Lock_Row(
          p_USAGE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_PERIOD_TYPE    VARCHAR2,
          p_PERIOD_START_DATE    DATE,
          p_QUANTITY    NUMBER,
		p_HISTORY_DATA_TYPE NUMBER DEFAULT NULL,
		p_USAGE_HEADER_ID NUMBER DEFAULT NULL,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
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
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_TRANSACTION_TYPE_ID    NUMBER);

PROCEDURE Delete_Row(
    p_USAGE_ID  NUMBER);
End CSP_USAGE_HISTORIES_PKG;

 

/
