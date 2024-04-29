--------------------------------------------------------
--  DDL for Package CSI_T_PARTY_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_PARTY_DETAILS_PKG" AUTHID CURRENT_USER as
/* $Header: csittpts.pls 120.1 2005/06/17 01:52:10 appldev  $ */
-- Package name     : CSI_T_PARTY_DETAILS_PKG
-- Purpose          : Table Handler for csi_t_party_details
-- History          : brmanesh created 12-MAY-2001
-- NOTE             :

PROCEDURE Insert_Row(
          px_TXN_PARTY_DETAIL_ID   IN OUT NOCOPY NUMBER,
          p_TXN_LINE_DETAIL_ID    NUMBER,
          p_PARTY_SOURCE_TABLE    VARCHAR2,
          p_PARTY_SOURCE_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_CONTACT_FLAG    VARCHAR2,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_PRESERVE_DETAIL_FLAG    VARCHAR2,
          p_INSTANCE_PARTY_ID    NUMBER,
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
          p_CONTACT_PARTY_ID    NUMBER,
          p_PRIMARY_FLAG    VARCHAR2,
          p_PREFERRED_FLAG    VARCHAR2);

PROCEDURE Update_Row(
          p_TXN_PARTY_DETAIL_ID    NUMBER,
          p_TXN_LINE_DETAIL_ID    NUMBER,
          p_PARTY_SOURCE_TABLE    VARCHAR2,
          p_PARTY_SOURCE_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_CONTACT_FLAG    VARCHAR2,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_PRESERVE_DETAIL_FLAG    VARCHAR2,
          p_INSTANCE_PARTY_ID    NUMBER,
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
          p_CONTACT_PARTY_ID    NUMBER,
          p_PRIMARY_FLAG    VARCHAR2,
          p_PREFERRED_FLAG    VARCHAR2);

PROCEDURE Lock_Row(
          p_TXN_PARTY_DETAIL_ID    NUMBER,
          p_TXN_LINE_DETAIL_ID    NUMBER,
          p_PARTY_SOURCE_TABLE    VARCHAR2,
          p_PARTY_SOURCE_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_CONTACT_FLAG    VARCHAR2,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_PRESERVE_DETAIL_FLAG    VARCHAR2,
          p_INSTANCE_PARTY_ID    NUMBER,
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
          p_CONTACT_PARTY_ID    NUMBER,
          p_PRIMARY_FLAG    VARCHAR2,
          p_PREFERRED_FLAG    VARCHAR2);

PROCEDURE Delete_Row(
    p_TXN_PARTY_DETAIL_ID  NUMBER);
End CSI_T_PARTY_DETAILS_PKG;

 

/
