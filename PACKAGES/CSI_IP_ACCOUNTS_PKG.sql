--------------------------------------------------------
--  DDL for Package CSI_IP_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_IP_ACCOUNTS_PKG" AUTHID CURRENT_USER as
/* $Header: csitaccs.pls 115.13 2003/09/04 00:17:10 sguthiva ship $ */


PROCEDURE Insert_Row(
          px_IP_ACCOUNT_ID   IN OUT NOCOPY NUMBER,
          p_INSTANCE_PARTY_ID    NUMBER,
          p_PARTY_ACCOUNT_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
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
          p_BILL_TO_ADDRESS    NUMBER,
          p_SHIP_TO_ADDRESS    NUMBER,
          p_request_id                  NUMBER,
          p_program_application_id      NUMBER,
          p_program_id                  NUMBER,
          p_program_update_date         DATE
          );

PROCEDURE Update_Row(
          p_IP_ACCOUNT_ID    NUMBER,
          p_INSTANCE_PARTY_ID    NUMBER,
          p_PARTY_ACCOUNT_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
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
          p_BILL_TO_ADDRESS    NUMBER,
          p_SHIP_TO_ADDRESS    NUMBER,
          p_request_id                  NUMBER ,
          p_program_application_id      NUMBER ,
          p_program_id                  NUMBER ,
          p_program_update_date         DATE
          );

PROCEDURE Lock_Row(
          p_IP_ACCOUNT_ID    NUMBER,
          p_INSTANCE_PARTY_ID    NUMBER,
          p_PARTY_ACCOUNT_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
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
          p_BILL_TO_ADDRESS    NUMBER,
          p_SHIP_TO_ADDRESS    NUMBER);

PROCEDURE Delete_Row(
    p_IP_ACCOUNT_ID  NUMBER);
End CSI_IP_ACCOUNTS_PKG;


 

/
