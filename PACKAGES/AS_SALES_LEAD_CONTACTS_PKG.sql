--------------------------------------------------------
--  DDL for Package AS_SALES_LEAD_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEAD_CONTACTS_PKG" AUTHID CURRENT_USER as
/* $Header: asxtslcs.pls 115.4 2002/11/22 08:02:11 ckapoor ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_CONTACTS_PKG
-- Purpose          : Sales lead contacts table handlers
-- NOTE             :
-- History          : 04/09/2001 FFANG   Created.
--
-- End of Comments


PROCEDURE SALES_LEAD_CONTACTS_Insert_Row(
          px_LEAD_CONTACT_ID   IN OUT NOCOPY NUMBER,
          p_SALES_LEAD_ID    NUMBER,
          p_CONTACT_ID    NUMBER,
          p_CONTACT_PARTY_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_ENABLED_FLAG    VARCHAR2,
          p_RANK    VARCHAR2,
          p_CUSTOMER_ID    NUMBER,
          p_ADDRESS_ID    NUMBER,
          p_PHONE_ID    NUMBER,
          p_CONTACT_ROLE_CODE    VARCHAR2,
          p_PRIMARY_CONTACT_FLAG    VARCHAR2,
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
--        p_SECURITY_GROUP_ID              NUMBER);


PROCEDURE SALES_LEAD_CONTACTS_Update_Row(
          p_LEAD_CONTACT_ID    NUMBER,
          p_SALES_LEAD_ID    NUMBER,
          p_CONTACT_ID    NUMBER,
          p_CONTACT_PARTY_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_ENABLED_FLAG    VARCHAR2,
          p_RANK    VARCHAR2,
          p_CUSTOMER_ID    NUMBER,
          p_ADDRESS_ID    NUMBER,
          p_PHONE_ID    NUMBER,
          p_CONTACT_ROLE_CODE    VARCHAR2,
          p_PRIMARY_CONTACT_FLAG    VARCHAR2,
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
--        p_SECURITY_GROUP_ID              NUMBER);


PROCEDURE SALES_LEAD_CONTACTS_Lock_Row(
          p_LEAD_CONTACT_ID    NUMBER,
          p_SALES_LEAD_ID    NUMBER,
          p_CONTACT_ID    NUMBER,
          p_CONTACT_PARTY_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_ENABLED_FLAG    VARCHAR2,
          p_RANK    VARCHAR2,
          p_CUSTOMER_ID    NUMBER,
          p_ADDRESS_ID    NUMBER,
          p_PHONE_ID    NUMBER,
          p_CONTACT_ROLE_CODE    VARCHAR2,
          p_PRIMARY_CONTACT_FLAG    VARCHAR2,
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
--        p_SECURITY_GROUP_ID              NUMBER);


PROCEDURE SALES_LEAD_CONTACTS_Delete_Row(
    p_LEAD_CONTACT_ID  NUMBER);


End AS_SALES_LEAD_CONTACTS_PKG;

 

/
