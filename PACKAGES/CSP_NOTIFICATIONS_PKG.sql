--------------------------------------------------------
--  DDL for Package CSP_NOTIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_NOTIFICATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: csptpnos.pls 115.7 2002/11/26 07:21:47 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_NOTIFICATIONS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_NOTIFICATION_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_PARTS_LOOP_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_NOTIFICATION_DATE    DATE,
          p_REASON    VARCHAR2,
          p_STATUS    VARCHAR2,
          p_QUANTITY    NUMBER,
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
          p_REQUEST_ID    NUMBER DEFAULT NULL,
          p_PROGRAM_APPLICATION_ID    NUMBER DEFAULT NULL,
          p_PROGRAM_ID    NUMBER DEFAULT NULL,
          p_PROGRAM_UPDATE_DATE    DATE DEFAULT NULL,
          p_NEED_DATE    DATE DEFAULT NULL,
          p_SUPPRESS_END_DATE    DATE DEFAULT NULL,
          p_NOTIFICATION_TYPE    VARCHAR2 DEFAULT NULL);

PROCEDURE Update_Row(
          p_NOTIFICATION_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_PARTS_LOOP_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_NOTIFICATION_DATE    DATE,
          p_REASON    VARCHAR2,
          p_STATUS    VARCHAR2,
          p_QUANTITY    NUMBER,
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
          p_REQUEST_ID    NUMBER DEFAULT NULL,
          p_PROGRAM_APPLICATION_ID    NUMBER DEFAULT NULL,
          p_PROGRAM_ID    NUMBER DEFAULT NULL,
          p_PROGRAM_UPDATE_DATE    DATE DEFAULT NULL,
          p_NEED_DATE    DATE DEFAULT NULL,
          p_SUPPRESS_END_DATE    DATE DEFAULT NULL,
          p_NOTIFICATION_TYPE    VARCHAR2 DEFAULT NULL);

PROCEDURE Lock_Row(
          p_NOTIFICATION_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_PARTS_LOOP_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_NOTIFICATION_DATE    DATE,
          p_REASON    VARCHAR2,
          p_STATUS    VARCHAR2,
          p_QUANTITY    NUMBER,
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
          p_REQUEST_ID    NUMBER DEFAULT NULL,
          p_PROGRAM_APPLICATION_ID    NUMBER DEFAULT NULL,
          p_PROGRAM_ID    NUMBER DEFAULT NULL,
          p_PROGRAM_UPDATE_DATE    DATE DEFAULT NULL,
          p_NEED_DATE    DATE DEFAULT NULL,
          p_SUPPRESS_END_DATE    DATE DEFAULT NULL,
          p_NOTIFICATION_TYPE    VARCHAR2 DEFAULT NULL);

PROCEDURE Delete_Row(
    p_NOTIFICATION_ID  NUMBER);
End CSP_NOTIFICATIONS_PKG;

 

/
