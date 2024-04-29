--------------------------------------------------------
--  DDL for Package CSI_T_EXTEND_ATTRIBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_EXTEND_ATTRIBS_PKG" AUTHID CURRENT_USER as
/* $Header: csitteas.pls 115.4 2002/11/12 00:23:56 rmamidip noship $ */
-- Package name     : CSI_T_EXTEND_ATTRIBS_PKG
-- Purpose          : Table Handler for csi_t_entend_attribs
-- History          : brmanesh created 12-MAY-2001
-- NOTE             :

PROCEDURE Insert_Row(
          px_TXN_ATTRIB_DETAIL_ID   IN OUT NOCOPY NUMBER,
          p_TXN_LINE_DETAIL_ID    NUMBER,
          p_ATTRIB_SOURCE_ID    NUMBER,
          p_ATTRIB_SOURCE_TABLE    VARCHAR2,
          p_ATTRIBUTE_VALUE    VARCHAR2,
          p_PROCESS_FLAG     VARCHAR2,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_PRESERVE_DETAIL_FLAG    VARCHAR2,
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
          p_TXN_ATTRIB_DETAIL_ID    NUMBER,
          p_TXN_LINE_DETAIL_ID    NUMBER,
          p_ATTRIB_SOURCE_ID    NUMBER,
          p_ATTRIB_SOURCE_TABLE    VARCHAR2,
          p_ATTRIBUTE_VALUE    VARCHAR2,
          p_PROCESS_FLAG     VARCHAR2,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_PRESERVE_DETAIL_FLAG    VARCHAR2,
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
          p_TXN_ATTRIB_DETAIL_ID    NUMBER,
          p_TXN_LINE_DETAIL_ID    NUMBER,
          p_ATTRIB_SOURCE_ID    NUMBER,
          p_ATTRIB_SOURCE_TABLE    VARCHAR2,
          p_ATTRIBUTE_VALUE    VARCHAR2,
          p_PROCESS_FLAG     VARCHAR2,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_PRESERVE_DETAIL_FLAG    VARCHAR2,
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
    p_TXN_ATTRIB_DETAIL_ID  NUMBER);
End CSI_T_EXTEND_ATTRIBS_PKG;

 

/
