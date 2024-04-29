--------------------------------------------------------
--  DDL for Package ASO_PAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_PAYMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: asotpays.pls 120.1 2005/06/29 12:40:05 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_PAYMENTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_PAYMENT_ID   IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
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
          p_PAYMENT_TYPE_CODE    VARCHAR2,
          p_PAYMENT_REF_NUMBER    VARCHAR2,
          p_PAYMENT_OPTION    VARCHAR2,
          p_PAYMENT_TERM_ID    NUMBER,
          p_CREDIT_CARD_CODE    VARCHAR2,
          p_CREDIT_CARD_HOLDER_NAME    VARCHAR2,
          p_CREDIT_CARD_EXPIRATION_DATE    DATE,
          p_CREDIT_CARD_APPROVAL_CODE    VARCHAR2,
          p_CREDIT_CARD_APPROVAL_DATE    DATE,
          p_PAYMENT_AMOUNT    NUMBER,
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
          p_QUOTE_SHIPMENT_ID    NUMBER,
	  p_CUST_PO_NUMBER VARCHAR2,
	  p_PAYMENT_TERM_ID_FROM    NUMBER,
          p_OBJECT_VERSION_NUMBER  NUMBER,
          p_CUST_PO_LINE_NUMBER   VARCHAR2, -- Line Payments Change
		p_TRXN_EXTENSION_ID NUMBER
	);

PROCEDURE Update_Row(
          p_PAYMENT_ID    NUMBER,
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
          p_PAYMENT_TYPE_CODE    VARCHAR2,
          p_PAYMENT_REF_NUMBER    VARCHAR2,
          p_PAYMENT_OPTION    VARCHAR2,
          p_PAYMENT_TERM_ID    NUMBER,
          p_CREDIT_CARD_CODE    VARCHAR2,
          p_CREDIT_CARD_HOLDER_NAME    VARCHAR2,
          p_CREDIT_CARD_EXPIRATION_DATE    DATE,
          p_CREDIT_CARD_APPROVAL_CODE    VARCHAR2,
          p_CREDIT_CARD_APPROVAL_DATE    DATE,
          p_PAYMENT_AMOUNT    NUMBER,
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
          p_QUOTE_SHIPMENT_ID    NUMBER,
	  p_CUST_PO_NUMBER VARCHAR2,
	  p_PAYMENT_TERM_ID_FROM    NUMBER,
          p_OBJECT_VERSION_NUMBER  NUMBER,
          p_CUST_PO_LINE_NUMBER  VARCHAR2, -- Line Payments Change
		p_TRXN_EXTENSION_ID NUMBER

	);

PROCEDURE Lock_Row(
          --p_OBJECT_VERSION_NUMBER  NUMBER,
          p_PAYMENT_ID    NUMBER,
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
          p_PAYMENT_TYPE_CODE    VARCHAR2,
          p_PAYMENT_REF_NUMBER    VARCHAR2,
          p_PAYMENT_OPTION    VARCHAR2,
          p_PAYMENT_TERM_ID    NUMBER,
          p_CREDIT_CARD_CODE    VARCHAR2,
          p_CREDIT_CARD_HOLDER_NAME    VARCHAR2,
          p_CREDIT_CARD_EXPIRATION_DATE    DATE,
          p_CREDIT_CARD_APPROVAL_CODE    VARCHAR2,
          p_CREDIT_CARD_APPROVAL_DATE    DATE,
          p_PAYMENT_AMOUNT    NUMBER,
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
          p_QUOTE_SHIPMENT_ID    NUMBER,
		p_CUST_PO_NUMBER VARCHAR2);

PROCEDURE Delete_Row(
    p_PAYMENT_ID  NUMBER);

PROCEDURE Delete_Row(
    p_QUOTE_LINE_ID  NUMBER);

End ASO_PAYMENTS_PKG;

 

/
