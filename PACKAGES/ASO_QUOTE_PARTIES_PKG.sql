--------------------------------------------------------
--  DDL for Package ASO_QUOTE_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_PARTIES_PKG" AUTHID CURRENT_USER as
/* $Header: asotqpts.pls 120.0 2005/05/31 12:06:14 appldev noship $ */
-- Start of Comments
-- Package name     : ASO_QUOTE_PARTIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_QUOTE_PARTY_ID   IN OUT NOCOPY  NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_QUOTE_SHIPMENT_ID    NUMBER,
          p_PARTY_TYPE    VARCHAR2,
          p_PARTY_ID    NUMBER,
          p_PARTY_OBJECT_TYPE    VARCHAR2,
          p_PARTY_OBJECT_ID    VARCHAR2,
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
          p_OBJECT_VERSION_NUMBER  NUMBER
		);
--          p_SECURITY_GROUP_ID    NUMBER,

PROCEDURE Update_Row(
          p_QUOTE_PARTY_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_QUOTE_SHIPMENT_ID    NUMBER,
          p_PARTY_TYPE    VARCHAR2,
          p_PARTY_ID    NUMBER,
          p_PARTY_OBJECT_TYPE    VARCHAR2,
          p_PARTY_OBJECT_ID    VARCHAR2,
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
          p_OBJECT_VERSION_NUMBER  NUMBER
		);
--          p_SECURITY_GROUP_ID    NUMBER,

PROCEDURE Lock_Row(
          --p_OBJECT_VERSION_NUMBER  NUMBER,
          p_QUOTE_PARTY_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_QUOTE_SHIPMENT_ID    NUMBER,
          p_PARTY_TYPE    VARCHAR2,
          p_PARTY_ID    NUMBER,
          p_PARTY_OBJECT_TYPE    VARCHAR2,
          p_PARTY_OBJECT_ID    VARCHAR2,
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
--          p_SECURITY_GROUP_ID    NUMBER,

PROCEDURE Delete_Row(
    p_QUOTE_PARTY_ID  NUMBER);

PROCEDURE Delete_Row(
    p_QUOTE_LINE_ID  NUMBER);

PROCEDURE Delete_Row(
    p_QUOTE_HEADER_ID  NUMBER);

PROCEDURE Delete_Row(
    p_QUOTE_SHIPMENT_ID  NUMBER);


End ASO_QUOTE_PARTIES_PKG;

 

/
