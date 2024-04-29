--------------------------------------------------------
--  DDL for Package CSD_REPAIR_JOB_XREF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_JOB_XREF_PKG" AUTHID CURRENT_USER as
/* $Header: csdtdrjs.pls 115.9 2003/09/15 21:33:16 sragunat ship $ */
-- Start of Comments
-- Package name     : CSD_REPAIR_JOB_XREF_PKG
-- Purpose          :
-- History          : Added Columns Inventory_Item_ID and Item_Revision -- travi
-- History          : 01/17/2002, TRAVI added column OBJECT_VERSION_NUMBER
-- History          : 08/20/2003, Shiv Ragunathan, 11.5.10 Changes: Added parameters
-- History          :   p_source_type_code, p_source_id1, p_ro_service_code_id, p_job_name
-- History          :   to Insert_row procedure.
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_REPAIR_JOB_XREF_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REPAIR_LINE_ID    NUMBER,
          p_WIP_ENTITY_ID    NUMBER,
          p_GROUP_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ITEM_REVISION    VARCHAR2,
          p_SOURCE_TYPE_CODE 		VARCHAR2,
          p_SOURCE_ID1       		NUMBER,
          p_RO_SERVICE_CODE_ID  	NUMBER,
          p_JOB_NAME         		VARCHAR2,
          p_OBJECT_VERSION_NUMBER   NUMBER,
          p_ATTRIBUTE_CATEGORY    	VARCHAR2,
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
        P_QUANTITY_COMPLETED NUMBER);

PROCEDURE Update_Row(
          p_REPAIR_JOB_XREF_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REPAIR_LINE_ID    NUMBER,
          p_WIP_ENTITY_ID    NUMBER,
          p_GROUP_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ITEM_REVISION    VARCHAR2,
          p_OBJECT_VERSION_NUMBER    NUMBER,
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
        p_QUANTITY_COMPLETED NUMBER);

PROCEDURE Lock_Row(
          p_REPAIR_JOB_XREF_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REPAIR_LINE_ID    NUMBER,
          p_WIP_ENTITY_ID    NUMBER,
          p_GROUP_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ITEM_REVISION    VARCHAR2,
          p_OBJECT_VERSION_NUMBER    NUMBER,
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
        p_QUANTITY_COMPLETED NUMBER);

PROCEDURE Delete_Row(
    p_REPAIR_JOB_XREF_ID  NUMBER);
End CSD_REPAIR_JOB_XREF_PKG;

 

/
