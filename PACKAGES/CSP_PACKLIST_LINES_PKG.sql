--------------------------------------------------------
--  DDL for Package CSP_PACKLIST_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PACKLIST_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: cspttals.pls 115.4 2002/11/26 07:40:08 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_PACKLIST_LINES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_PACKLIST_LINE_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PACKLIST_LINE_NUMBER    NUMBER,
          p_PACKLIST_HEADER_ID    NUMBER,
          p_BOX_ID    NUMBER,
          p_PICKLIST_LINE_ID    NUMBER,
          p_PACKLIST_LINE_STATUS    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_QUANTITY_PACKED    NUMBER,
          p_QUANTITY_SHIPPED    NUMBER,
          p_QUANTITY_RECEIVED    NUMBER,
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
          p_UOM_CODE    VARCHAR2,
          p_LINE_ID    NUMBER);

PROCEDURE Update_Row(
          p_PACKLIST_LINE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PACKLIST_LINE_NUMBER    NUMBER,
          p_PACKLIST_HEADER_ID    NUMBER,
          p_BOX_ID    NUMBER,
          p_PICKLIST_LINE_ID    NUMBER,
          p_PACKLIST_LINE_STATUS    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_QUANTITY_PACKED    NUMBER,
          p_QUANTITY_SHIPPED    NUMBER,
          p_QUANTITY_RECEIVED    NUMBER,
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
          p_UOM_CODE    VARCHAR2,
          p_LINE_ID    NUMBER);

PROCEDURE Lock_Row(
          p_PACKLIST_LINE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PACKLIST_LINE_NUMBER    NUMBER,
          p_PACKLIST_HEADER_ID    NUMBER,
          p_BOX_ID    NUMBER,
          p_PICKLIST_LINE_ID    NUMBER,
          p_PACKLIST_LINE_STATUS    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_QUANTITY_PACKED    NUMBER,
          p_QUANTITY_SHIPPED    NUMBER,
          p_QUANTITY_RECEIVED    NUMBER,
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
          p_UOM_CODE    VARCHAR2,
          p_LINE_ID    NUMBER);

PROCEDURE Delete_Row(
    p_PACKLIST_LINE_ID  NUMBER);
End CSP_PACKLIST_LINES_PKG;

 

/
