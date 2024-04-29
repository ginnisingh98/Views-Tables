--------------------------------------------------------
--  DDL for Package AR_ACTIVITY_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ACTIVITY_DETAILS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARRWLLTS.pls 120.1.12000000.4 2008/09/25 12:15:02 mpsingh ship $ */

PROCEDURE Insert_Row (
    X_ROWID				 IN OUT NOCOPY				 VARCHAR2,
    X_APPLY_TO     				 IN				 VARCHAR2,
    X_TAX_BALANCE  				 IN				 NUMBER,
    X_CUSTOMER_TRX_LINE_ID				 IN				 NUMBER,
    X_COMMENTS     				 IN				 VARCHAR2,
    X_TAX          				 IN				 NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    X_ATTRIBUTE_CATEGORY				 IN				 VARCHAR2,
    X_ALLOCATED_RECEIPT_AMOUNT				 IN				 NUMBER,
    X_GROUP_ID     				 IN				 NUMBER,
    X_TAX_DISCOUNT 				 IN				 NUMBER,
    X_REFERENCE5   				 IN				 VARCHAR2,
    X_REFERENCE4   				 IN				 VARCHAR2,
    X_REFERENCE3   				 IN				 VARCHAR2,
    X_AMOUNT       				 IN				 NUMBER,
    X_LINE_DISCOUNT				 IN				 NUMBER,
    X_REFERENCE2   				 IN				 VARCHAR2,
    X_REFERENCE1   				 IN				 VARCHAR2,
    X_ATTRIBUTE9   				 IN				 VARCHAR2,
    X_ATTRIBUTE8   				 IN				 VARCHAR2,
    X_ATTRIBUTE7   				 IN				 VARCHAR2,
    X_ATTRIBUTE6   				 IN				 VARCHAR2,
    X_ATTRIBUTE5   				 IN				 VARCHAR2,
    X_ATTRIBUTE4   				 IN				 VARCHAR2,
    X_ATTRIBUTE3   				 IN				 VARCHAR2,
    X_ATTRIBUTE2   				 IN				 VARCHAR2,
    X_ATTRIBUTE1   				 IN				 VARCHAR2,
    X_LINE_BALANCE 				 IN				 NUMBER,
    X_ATTRIBUTE15  				 IN				 VARCHAR2,
    X_ATTRIBUTE14  				 IN				 VARCHAR2,
    X_ATTRIBUTE13  				 IN				 VARCHAR2,
    X_ATTRIBUTE12  				 IN				 VARCHAR2,
    X_ATTRIBUTE11  				 IN				 VARCHAR2,
    X_ATTRIBUTE10  				 IN				 VARCHAR2,
    X_OBJECT_VERSION_NUMBER			 IN				 NUMBER,
    X_CREATED_BY_MODULE				 IN				 VARCHAR2
);



PROCEDURE Update_Row (
    X_APPLY_TO     				 IN				 VARCHAR2,
    X_TAX_BALANCE  				 IN				 NUMBER,
    X_CUSTOMER_TRX_LINE_ID				 IN				 NUMBER,
    X_COMMENTS     				 IN				 VARCHAR2,
    X_TAX          				 IN				 NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    X_ATTRIBUTE_CATEGORY				 IN				 VARCHAR2,
    X_ALLOCATED_RECEIPT_AMOUNT				 IN				 NUMBER,
    X_GROUP_ID     				 IN				 NUMBER,
    X_TAX_DISCOUNT 				 IN				 NUMBER,
    X_REFERENCE5   				 IN				 VARCHAR2,
    X_REFERENCE4   				 IN				 VARCHAR2,
    X_REFERENCE3   				 IN				 VARCHAR2,
    X_AMOUNT       				 IN				 NUMBER,
    X_LINE_DISCOUNT				 IN				 NUMBER,
    X_REFERENCE2   				 IN				 VARCHAR2,
    X_REFERENCE1   				 IN				 VARCHAR2,
    X_ATTRIBUTE9   				 IN				 VARCHAR2,
    X_ATTRIBUTE8   				 IN				 VARCHAR2,
    X_ATTRIBUTE7   				 IN				 VARCHAR2,
    X_ATTRIBUTE6   				 IN				 VARCHAR2,
    X_ATTRIBUTE5   				 IN				 VARCHAR2,
    X_ATTRIBUTE4   				 IN				 VARCHAR2,
    X_ATTRIBUTE3   				 IN				 VARCHAR2,
    X_ATTRIBUTE2   				 IN				 VARCHAR2,
    X_ATTRIBUTE1   				 IN				 VARCHAR2,
    X_LINE_BALANCE 				 IN				 NUMBER,
    X_ATTRIBUTE15  				 IN				 VARCHAR2,
    X_ATTRIBUTE14  				 IN				 VARCHAR2,
    X_ATTRIBUTE13  				 IN				 VARCHAR2,
    X_ATTRIBUTE12  				 IN				 VARCHAR2,
    X_ATTRIBUTE11  				 IN				 VARCHAR2,
    X_ATTRIBUTE10  				 IN				 VARCHAR2,
    X_OBJECT_VERSION_NUMBER			 IN				 NUMBER,
    X_CREATED_BY_MODULE				 IN				 VARCHAR2
);

/*
PROCEDURE Lock_Row (
    X_APPLY_TO     				 IN				 VARCHAR2,
    X_TAX_BALANCE  				 IN				 NUMBER,
    X_CUSTOMER_TRX_LINE_ID				 IN				 NUMBER,
    X_COMMENTS     				 IN				 VARCHAR2,
    X_TAX          				 IN				 NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    X_ATTRIBUTE_CATEGORY				 IN				 VARCHAR2,
    X_ALLOCATED_RECEIPT_AMOUNT				 IN				 NUMBER,
    X_GROUP_ID     				 IN				 NUMBER,
    X_TAX_DISCOUNT 				 IN				 NUMBER,
    X_REFERENCE5   				 IN				 VARCHAR2,
    X_REFERENCE4   				 IN				 VARCHAR2,
    X_REFERENCE3   				 IN				 VARCHAR2,
    X_AMOUNT       				 IN				 NUMBER,
    X_LINE_DISCOUNT				 IN				 NUMBER,
    X_REFERENCE2   				 IN				 VARCHAR2,
    X_REFERENCE1   				 IN				 VARCHAR2,
    X_ATTRIBUTE9   				 IN				 VARCHAR2,
    X_ATTRIBUTE8   				 IN				 VARCHAR2,
    X_ATTRIBUTE7   				 IN				 VARCHAR2,
    X_ATTRIBUTE6   				 IN				 VARCHAR2,
    X_ATTRIBUTE5   				 IN				 VARCHAR2,
    X_ATTRIBUTE4   				 IN				 VARCHAR2,
    X_ATTRIBUTE3   				 IN				 VARCHAR2,
    X_ATTRIBUTE2   				 IN				 VARCHAR2,
    X_ATTRIBUTE1   				 IN				 VARCHAR2,
    X_LINE_BALANCE 				 IN				 NUMBER,
    X_ATTRIBUTE15  				 IN				 VARCHAR2,
    X_ATTRIBUTE14  				 IN				 VARCHAR2,
    X_ATTRIBUTE13  				 IN				 VARCHAR2,
    X_ATTRIBUTE12  				 IN				 VARCHAR2,
    X_ATTRIBUTE11  				 IN				 VARCHAR2,
    X_ATTRIBUTE10  				 IN				 VARCHAR2,
    X_CREATED_BY				 IN 				 NUMBER,
    X_CREATION_DATE				 IN 				 DATE,
    X_LAST_UPDATE_LOGIN				 IN 				 NUMBER,
    X_LAST_UPDATE_DATE				 IN 				 DATE,
    X_LAST_UPDATED_BY				 IN 				 NUMBER,
    X_OBJECT_VERSION_NUMBER			 IN				 NUMBER,
    X_CREATED_BY_MODULE				 IN				 VARCHAR2,
    X_CUSTOMER_TRX_ID      IN NUMBER
);
*/


PROCEDURE Delete_Row (
    X_CUSTOMER_TRX_LINE_ID				 IN				 NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER
);

procedure select_summary (x_customer_Trx_id in number,
                          x_cash_receipt_id in number,
                          x_total in out NOCOPY number,
                          x_total_rtot_db in out NOCOPY number) ;


PROCEDURE offset_row (
 X_CUSTOMER_TRX_LINE_ID IN NUMBER,
 X_CASH_RECEIPT_ID      IN NUMBER
);

PROCEDURE Chk_offset_Row (
    X_RECEIVABLE_APPLICATION_ID			 IN				 NUMBER,
    X_OLD_RECEIVABLE_APP_ID                      IN				 NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER
);

END AR_ACTIVITY_DETAILS_PKG;

 

/
