--------------------------------------------------------
--  DDL for Package CSP_PICKLIST_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PICKLIST_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: cspttpls.pls 115.5 2002/11/26 07:09:09 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_PICKLIST_LINES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_picklist_line_id   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PICKLIST_LINE_NUMBER    NUMBER,
          p_picklist_header_id    NUMBER,
          p_LINE_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_UOM_CODE    VARCHAR2,
          p_REVISION    VARCHAR2,
          p_QUANTITY_PICKED    NUMBER,
          p_TRANSACTION_TEMP_ID    NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Update_Row(
          p_picklist_line_id    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PICKLIST_LINE_NUMBER    NUMBER,
          p_picklist_header_id    NUMBER,
          p_LINE_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_UOM_CODE    VARCHAR2,
          p_REVISION    VARCHAR2,
          p_QUANTITY_PICKED    NUMBER,
          p_TRANSACTION_TEMP_ID    NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Lock_Row(
          p_picklist_line_id    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PICKLIST_LINE_NUMBER    NUMBER,
          p_picklist_header_id    NUMBER,
          p_LINE_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_UOM_CODE    VARCHAR2,
          p_REVISION    VARCHAR2,
          p_QUANTITY_PICKED    NUMBER,
          p_TRANSACTION_TEMP_ID    NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Delete_Row(
    p_picklist_line_id  NUMBER);
End CSP_PICKLIST_LINES_PKG;

 

/
