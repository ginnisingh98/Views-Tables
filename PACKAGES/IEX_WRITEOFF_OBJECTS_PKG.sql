--------------------------------------------------------
--  DDL for Package IEX_WRITEOFF_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_WRITEOFF_OBJECTS_PKG" AUTHID CURRENT_USER as
/* $Header: iextwobs.pls 120.1 2007/10/31 12:24:16 ehuh ship $ */

PROCEDURE Insert_Row
    (x_rowid            	      IN OUT nocopy VARCHAR2
	,x_WRITEOFF_OBJECT_ID	      IN NUMBER
	,x_WRITEOFF_ID		          IN NUMBER
	,x_OBJECT_VERSION_NUMBER      IN NUMBER
	,x_CONTRACT_ID		          IN NUMBER
	,x_CONS_INVOICE_ID		      IN NUMBER
	,x_CONS_INVOICE_LINE_ID	      IN NUMBER
	,x_TRANSACTION_ID		      IN NUMBER
	,x_ADJUSTMENT_AMOUNT	      IN NUMBER
	,x_ADJUSTMENT_REASON_CODE     IN VARCHAR2
	,x_RECEVIABLES_ADJUSTMENT_ID  IN NUMBER
 ,X_REQUEST_ID              in  NUMBER,
 X_PROGRAM_APPLICATION_ID  in  NUMBER,
 X_PROGRAM_ID              in  NUMBER,
 X_PROGRAM_UPDATE_DATE     in  DATE,
 X_ATTRIBUTE_CATEGORY      in VARCHAR2,
 X_ATTRIBUTE1              in VARCHAR2,
 X_ATTRIBUTE2              in VARCHAR2,
 X_ATTRIBUTE3              in VARCHAR2,
 X_ATTRIBUTE4              in VARCHAR2,
 X_ATTRIBUTE5              in VARCHAR2,
 X_ATTRIBUTE6              in VARCHAR2,
 X_ATTRIBUTE7              in VARCHAR2,
 X_ATTRIBUTE8              in VARCHAR2,
 X_ATTRIBUTE9              in VARCHAR2,
 X_ATTRIBUTE10             in VARCHAR2,
 X_ATTRIBUTE11             in VARCHAR2,
 X_ATTRIBUTE12             in VARCHAR2,
 X_ATTRIBUTE13             in VARCHAR2,
 X_ATTRIBUTE14             in VARCHAR2,
 X_ATTRIBUTE15             in VARCHAR2,
 X_CREATION_DATE           in DATE,
 X_CREATED_BY              in NUMBER,
 X_LAST_UPDATE_DATE        in DATE,
 X_LAST_UPDATED_BY         in NUMBER,
 X_LAST_UPDATE_LOGIN       in NUMBER,
 X_WRITEOFF_STATUS         in VARCHAR2,
 X_WRITEOFF_TYPE_ID       in NUMBER,
 X_WRITEOFF_TYPE         in VARCHAR2,
 x_customer_trx_id       in number,
 x_customer_trx_line_id  in number);


/* Update_Row procedure */
PROCEDURE Update_Row(
	x_WRITEOFF_OBJECT_ID	      IN NUMBER
	,x_WRITEOFF_ID		          IN NUMBER
	,x_OBJECT_VERSION_NUMBER      IN NUMBER
	,x_CONTRACT_ID		          IN NUMBER
	,x_CONS_INVOICE_ID		      IN NUMBER
	,x_CONS_INVOICE_LINE_ID	      IN NUMBER
	,x_TRANSACTION_ID		      IN NUMBER
	,x_ADJUSTMENT_AMOUNT	      IN NUMBER
	,x_ADJUSTMENT_REASON_CODE     IN VARCHAR2
	,x_RECEVIABLES_ADJUSTMENT_ID  IN NUMBER
 ,X_REQUEST_ID              in  NUMBER,
 X_PROGRAM_APPLICATION_ID  in  NUMBER,
 X_PROGRAM_ID              in  NUMBER,
 X_PROGRAM_UPDATE_DATE     in  DATE,
 X_ATTRIBUTE_CATEGORY      in VARCHAR2,
 X_ATTRIBUTE1              in VARCHAR2,
 X_ATTRIBUTE2              in VARCHAR2,
 X_ATTRIBUTE3              in VARCHAR2,
 X_ATTRIBUTE4              in VARCHAR2,
 X_ATTRIBUTE5              in VARCHAR2,
 X_ATTRIBUTE6              in VARCHAR2,
 X_ATTRIBUTE7              in VARCHAR2,
 X_ATTRIBUTE8              in VARCHAR2,
 X_ATTRIBUTE9              in VARCHAR2,
 X_ATTRIBUTE10             in VARCHAR2,
 X_ATTRIBUTE11             in VARCHAR2,
 X_ATTRIBUTE12             in VARCHAR2,
 X_ATTRIBUTE13             in VARCHAR2,
 X_ATTRIBUTE14             in VARCHAR2,
 X_ATTRIBUTE15             in VARCHAR2,
 X_LAST_UPDATE_DATE        in DATE,
 X_LAST_UPDATED_BY         in NUMBER,
 X_LAST_UPDATE_LOGIN       in NUMBER,
  X_WRITEOFF_STATUS         in VARCHAR2,
 X_WRITEOFF_TYPE_ID       in NUMBER,
 X_WRITEOFF_TYPE         in VARCHAR2,
 x_customer_trx_id       in number,
 x_customer_trx_line_id  in number);

/* Delete_Row procedure */
 PROCEDURE Delete_Row(x_object_writeoff_id IN NUMBER);

procedure LOCK_ROW (
  X_WRITEOFF_OBJECT_ID    in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER);


END IEX_WRITEOFF_OBJECTS_PKG ;

/
