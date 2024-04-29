--------------------------------------------------------
--  DDL for Package IEX_CASE_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_CASE_CONTACTS_PKG" AUTHID CURRENT_USER as
/* $Header: iextcons.pls 120.0 2004/01/24 03:21:27 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_CASE_CONTACTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          X_ROWID                  in out NOCOPY VARCHAR2,
          p_CAS_CONTACT_ID         IN  NUMBER,
          p_CAS_ID                 IN NUMBER,
          p_CONTACT_PARTY_ID       IN NUMBER,
          p_OBJECT_VERSION_NUMBER  IN NUMBER,
          p_address_id             IN NUMBER,
          p_phone_id               IN NUMBER,
          p_active_flag            IN VARCHAR2,
          p_REQUEST_ID             IN NUMBER,
          p_PROGRAM_APPLICATION_ID IN NUMBER,
          p_PROGRAM_ID             IN NUMBER,
          p_PROGRAM_UPDATE_DATE    IN DATE,
          p_ATTRIBUTE_CATEGORY     IN VARCHAR2,
          p_ATTRIBUTE1             IN VARCHAR2,
          p_ATTRIBUTE2             IN VARCHAR2,
          p_ATTRIBUTE3             IN VARCHAR2,
          p_ATTRIBUTE4             IN VARCHAR2,
          p_ATTRIBUTE5             IN VARCHAR2,
          p_ATTRIBUTE6             IN VARCHAR2,
          p_ATTRIBUTE7             IN VARCHAR2,
          p_ATTRIBUTE8             IN VARCHAR2,
          p_ATTRIBUTE9             IN VARCHAR2,
          p_ATTRIBUTE10            IN VARCHAR2,
          p_ATTRIBUTE11            IN VARCHAR2,
          p_ATTRIBUTE12            IN VARCHAR2,
          p_ATTRIBUTE13            IN VARCHAR2,
          p_ATTRIBUTE14            IN VARCHAR2,
          p_ATTRIBUTE15            IN VARCHAR2,
          p_CREATED_BY             IN VARCHAR2,
          p_CREATION_DATE          IN DATE,
          p_LAST_UPDATED_BY        IN NUMBER,
          p_LAST_UPDATE_DATE       IN DATE,
          p_LAST_UPDATE_LOGIN      IN NUMBER,
          P_PRIMARY_FLAG           IN VARCHAR2 );

PROCEDURE Update_Row(
          p_CAS_CONTACT_ID         IN  NUMBER,
          p_CAS_ID                 IN NUMBER,
          p_CONTACT_PARTY_ID       IN NUMBER,
          p_OBJECT_VERSION_NUMBER  IN   NUMBER,
          p_address_id             IN NUMBER,
          p_phone_id               IN NUMBER,
          p_active_flag            IN VARCHAR2,
          p_REQUEST_ID             IN NUMBER,
          p_PROGRAM_APPLICATION_ID IN NUMBER,
          p_PROGRAM_ID             IN NUMBER,
          p_PROGRAM_UPDATE_DATE    IN DATE,
          p_ATTRIBUTE_CATEGORY     IN VARCHAR2,
          p_ATTRIBUTE1             IN VARCHAR2,
          p_ATTRIBUTE2             IN VARCHAR2,
          p_ATTRIBUTE3             IN VARCHAR2,
          p_ATTRIBUTE4             IN VARCHAR2,
          p_ATTRIBUTE5             IN VARCHAR2,
          p_ATTRIBUTE6             IN VARCHAR2,
          p_ATTRIBUTE7             IN VARCHAR2,
          p_ATTRIBUTE8             IN VARCHAR2,
          p_ATTRIBUTE9             IN VARCHAR2,
          p_ATTRIBUTE10            IN VARCHAR2,
          p_ATTRIBUTE11            IN VARCHAR2,
          p_ATTRIBUTE12            IN VARCHAR2,
          p_ATTRIBUTE13            IN VARCHAR2,
          p_ATTRIBUTE14            IN VARCHAR2,
          p_ATTRIBUTE15            IN VARCHAR2,
          p_LAST_UPDATED_BY        IN NUMBER,
          p_LAST_UPDATE_DATE       IN DATE,
          p_LAST_UPDATE_LOGIN      IN NUMBER,
          P_PRIMARY_FLAG           IN VARCHAR2 );

procedure LOCK_ROW (
  p_CAS_CONTACT_ID in NUMBER,
  p_OBJECT_VERSION_NUMBER in NUMBER);

/*
PROCEDURE Lock_Row(
          p_CAS_CONTACT_ID    NUMBER,
          p_CAS_ID    NUMBER,
          p_CONTACT_PARTY_ID    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_address_id             IN NUMBER,
          p_phone_id               IN NUMBER,
          p_active_flag           IN VARCHAR2,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
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
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN      IN NUMBER,
          P_PRIMARY_FLAG           IN VARCHAR2 );
*/

PROCEDURE Delete_Row(
    p_CAS_CONTACT_ID  IN NUMBER);
End IEX_CASE_CONTACTS_PKG;

 

/
