--------------------------------------------------------
--  DDL for Package CSI_I_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_I_PARTIES_PKG" AUTHID CURRENT_USER as
/* $Header: csitptys.pls 115.14 2003/09/04 00:22:43 sguthiva ship $ */

PROCEDURE Insert_Row(
          p_INSTANCE_PARTY_ID   IN OUT NOCOPY NUMBER,
          p_INSTANCE_ID    NUMBER,
          p_PARTY_SOURCE_TABLE    VARCHAR2,
          p_PARTY_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_CONTACT_FLAG    VARCHAR2,
          p_CONTACT_IP_ID   NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CONTEXT    VARCHAR2,
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
          p_PRIMARY_FLAG    VARCHAR2,
          p_PREFERRED_FLAG    VARCHAR2);

PROCEDURE Update_Row(
          p_INSTANCE_PARTY_ID    NUMBER,
          p_INSTANCE_ID    NUMBER,
          p_PARTY_SOURCE_TABLE    VARCHAR2,
          p_PARTY_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_CONTACT_FLAG    VARCHAR2,
          p_CONTACT_IP_ID   NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CONTEXT    VARCHAR2,
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
          p_PRIMARY_FLAG    VARCHAR2,
          p_PREFERRED_FLAG    VARCHAR2);

PROCEDURE Lock_Row(
          p_INSTANCE_PARTY_ID    NUMBER,
          p_INSTANCE_ID    NUMBER,
          p_PARTY_SOURCE_TABLE   VARCHAR2 ,
          p_PARTY_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_CONTACT_FLAG    VARCHAR2,
          p_CONTACT_IP_ID    NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CONTEXT    VARCHAR2,
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
          p_PRIMARY_FLAG    VARCHAR2,
          p_PREFERRED_FLAG    VARCHAR2);

PROCEDURE Delete_Row(
    p_INSTANCE_PARTY_ID  NUMBER);
End CSI_I_PARTIES_PKG;


 

/
