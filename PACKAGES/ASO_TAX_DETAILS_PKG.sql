--------------------------------------------------------
--  DDL for Package ASO_TAX_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_TAX_DETAILS_PKG" AUTHID CURRENT_USER as
/* $Header: asottaxs.pls 120.2 2005/08/30 04:57:47 anrajan ship $ */
-- Start of Comments
-- Package name     : ASO_TAX_DETAILS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
--Added the TAX_RATE_ID column in INSERT_ROW,UPDATE_ROW and LOCK_ROW procedures
--by Anoop Rajan on 30 August 2005.
PROCEDURE Insert_Row(
          px_TAX_DETAIL_ID   IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_QUOTE_SHIPMENT_ID    NUMBER,
          p_ORIG_TAX_CODE    VARCHAR2,
          p_TAX_CODE    VARCHAR2,
          p_TAX_RATE    NUMBER,
          p_TAX_DATE    DATE,
          p_TAX_AMOUNT    NUMBER,
          p_TAX_EXEMPT_FLAG    VARCHAR2,
          p_TAX_EXEMPT_NUMBER    VARCHAR2,
          p_TAX_EXEMPT_REASON_CODE    VARCHAR2,
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
           p_ATTRIBUTE16    VARCHAR2,
          p_ATTRIBUTE17    VARCHAR2,
          p_ATTRIBUTE18    VARCHAR2,
          p_ATTRIBUTE19    VARCHAR2,
          p_ATTRIBUTE20    VARCHAR2,
		p_TAX_INCLUSIVE_FLAG  VARCHAR2,
          p_OBJECT_VERSION_NUMBER  NUMBER,
	  p_TAX_RATE_ID		NUMBER

		);

PROCEDURE Update_Row(
          p_TAX_DETAIL_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_QUOTE_SHIPMENT_ID    NUMBER,
          p_ORIG_TAX_CODE    VARCHAR2,
          p_TAX_CODE    VARCHAR2,
          p_TAX_RATE    NUMBER,
          p_TAX_DATE    DATE,
          p_TAX_AMOUNT    NUMBER,
          p_TAX_EXEMPT_FLAG    VARCHAR2,
          p_TAX_EXEMPT_NUMBER    VARCHAR2,
          p_TAX_EXEMPT_REASON_CODE    VARCHAR2,
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
           p_ATTRIBUTE16    VARCHAR2,
          p_ATTRIBUTE17    VARCHAR2,
          p_ATTRIBUTE18    VARCHAR2,
          p_ATTRIBUTE19    VARCHAR2,
          p_ATTRIBUTE20    VARCHAR2,
		p_TAX_INCLUSIVE_FLAG  VARCHAR2,
          p_OBJECT_VERSION_NUMBER  NUMBER,
	  p_TAX_RATE_ID		NUMBER
		);

PROCEDURE Lock_Row(
          --p_OBJECT_VERSION_NUMBER  NUMBER,
          p_TAX_DETAIL_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_QUOTE_SHIPMENT_ID    NUMBER,
          p_ORIG_TAX_CODE    VARCHAR2,
          p_TAX_CODE    VARCHAR2,
          p_TAX_RATE    NUMBER,
          p_TAX_DATE    DATE,
          p_TAX_AMOUNT    NUMBER,
          p_TAX_EXEMPT_FLAG    VARCHAR2,
          p_TAX_EXEMPT_NUMBER    VARCHAR2,
          p_TAX_EXEMPT_REASON_CODE    VARCHAR2,
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
	  p_TAX_RATE_ID		NUMBER);

PROCEDURE Delete_Row(
    p_TAX_DETAIL_ID  NUMBER);

PROCEDURE Delete_Row(
    p_QUOTE_LINE_ID  NUMBER);

End ASO_TAX_DETAILS_PKG;

 

/
