--------------------------------------------------------
--  DDL for Package CSI_T_II_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_II_RELATIONSHIPS_PKG" AUTHID CURRENT_USER as
/* $Header: csittiis.pls 115.8 2003/09/02 20:06:25 epajaril ship $ */
-- Package name     : CSI_T_II_RELATIONSHIPS_PKG
-- Purpose          : Table Handler for csi_t_ii_relationships
-- History          : brmanesh created 12-MAY-2001
--                  : epajaril added the transfer_components 26-AUG-2003
-- NOTE             :


---Added (Start) for m-to-m enhancements
--New columns p_OBJECT_TYPE , p_SUBJECT_TYPE added
--and due to this there are changes at various modules
---Added (End) for m-to-m enhancements

PROCEDURE Insert_Row(
          px_TXN_RELATIONSHIP_ID   IN OUT NOCOPY NUMBER,
          p_TRANSACTION_LINE_ID    NUMBER,
          p_OBJECT_TYPE  VARCHAR2,
          p_OBJECT_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_DISPLAY_ORDER    NUMBER,
          p_POSITION_REFERENCE    VARCHAR2,
          p_MANDATORY_FLAG    VARCHAR2,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CSI_INST_RELATIONSHIP_ID    NUMBER,
          p_SUBJECT_TYPE  VARCHAR2 ,
          p_SUBJECT_ID    NUMBER,
          p_SUB_CONFIG_INST_HDR_ID  NUMBER ,
          p_SUB_CONFIG_INST_REV_NUM NUMBER ,
          p_SUB_CONFIG_INST_ITEM_ID NUMBER ,
          p_OBJ_CONFIG_INST_HDR_ID  NUMBER ,
          p_OBJ_CONFIG_INST_REV_NUM NUMBER ,
          p_OBJ_CONFIG_INST_ITEM_ID NUMBER ,
          p_TARGET_COMMITMENT_DATE  DATE   ,
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
          p_CONTEXT    VARCHAR2,
          p_TRANSFER_COMPONENTS_FLAG  VARCHAR2);

PROCEDURE Update_Row(
          p_TXN_RELATIONSHIP_ID    NUMBER,
          p_TRANSACTION_LINE_ID    NUMBER,
          p_OBJECT_TYPE  VARCHAR2,
          p_OBJECT_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_DISPLAY_ORDER    NUMBER,
          p_POSITION_REFERENCE    VARCHAR2,
          p_MANDATORY_FLAG    VARCHAR2,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CSI_INST_RELATIONSHIP_ID    NUMBER,
          p_SUBJECT_TYPE  VARCHAR2 ,
          p_SUBJECT_ID    NUMBER,
          p_SUB_CONFIG_INST_HDR_ID  NUMBER ,
          p_SUB_CONFIG_INST_REV_NUM NUMBER ,
          p_SUB_CONFIG_INST_ITEM_ID NUMBER ,
          p_OBJ_CONFIG_INST_HDR_ID  NUMBER ,
          p_OBJ_CONFIG_INST_REV_NUM NUMBER ,
          p_OBJ_CONFIG_INST_ITEM_ID NUMBER ,
          p_TARGET_COMMITMENT_DATE  DATE   ,
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
          p_CONTEXT    VARCHAR2,
          p_TRANSFER_COMPONENTS_FLAG  VARCHAR2);

PROCEDURE Lock_Row(
          p_TXN_RELATIONSHIP_ID    NUMBER,
          p_TRANSACTION_LINE_ID    NUMBER,
          p_OBJECT_TYPE  VARCHAR2,
          p_OBJECT_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_DISPLAY_ORDER    NUMBER,
          p_POSITION_REFERENCE    VARCHAR2,
          p_MANDATORY_FLAG    VARCHAR2,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CSI_INST_RELATIONSHIP_ID    NUMBER,
          p_SUBJECT_TYPE  VARCHAR2 ,
          p_SUBJECT_ID    NUMBER,
          p_SUB_CONFIG_INST_HDR_ID  NUMBER ,
          p_SUB_CONFIG_INST_REV_NUM NUMBER ,
          p_SUB_CONFIG_INST_ITEM_ID NUMBER ,
          p_OBJ_CONFIG_INST_HDR_ID  NUMBER ,
          p_OBJ_CONFIG_INST_REV_NUM NUMBER ,
          p_OBJ_CONFIG_INST_ITEM_ID NUMBER ,
          p_TARGET_COMMITMENT_DATE  DATE   ,
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
          p_CONTEXT    VARCHAR2,
          p_TRANSFER_COMPONENTS_FLAG  VARCHAR2);

PROCEDURE Delete_Row(
    p_TXN_RELATIONSHIP_ID  NUMBER);
End CSI_T_II_RELATIONSHIPS_PKG;

 

/
