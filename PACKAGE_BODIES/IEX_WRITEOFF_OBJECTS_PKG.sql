--------------------------------------------------------
--  DDL for Package Body IEX_WRITEOFF_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WRITEOFF_OBJECTS_PKG" AS
/* $Header: iextwobb.pls 120.1 2007/10/31 12:24:31 ehuh ship $ */

PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

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
 x_customer_trx_line_id  in number) IS

 CURSOR C IS SELECT ROWID FROM IEX_WRITEOFF_OBJECTS
		WHERE WRITEOFF_OBJECT_ID = x_WRITEOFF_OBJECT_ID;

BEGIN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage ('** Start of Procedure =>'||
               'IEX_WRITEOFF_OBJECTS_PKG.INSERT_ROW ** ');
    END IF;
	INSERT INTO IEX_WRITEOFF_OBJECTS
	        (
    	         WRITEOFF_OBJECT_ID
		,WRITEOFF_ID
		,OBJECT_VERSION_NUMBER
		,CONTRACT_ID
		,CONS_INVOICE_ID
		,CONS_INVOICE_LINE_ID
		,TRANSACTION_ID
		,ADJUSTMENT_AMOUNT
		,ADJUSTMENT_REASON_CODE
		,RECEVIABLES_ADJUSTMENT_ID
		,REQUEST_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_ID
		,PROGRAM_UPDATE_DATE
		,ATTRIBUTE_CATEGORY
		,ATTRIBUTE1
		,ATTRIBUTE2
		,ATTRIBUTE3
		,ATTRIBUTE4
		,ATTRIBUTE5
		,ATTRIBUTE6
		,ATTRIBUTE7
		,ATTRIBUTE8
		,ATTRIBUTE9
		,ATTRIBUTE10
		,ATTRIBUTE11
		,ATTRIBUTE12
		,ATTRIBUTE13
		,ATTRIBUTE14
		,ATTRIBUTE15
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN
                ,WRITEOFF_STATUS
                ,WRITEOFF_TYPE_ID
                ,WRITEOFF_TYPE
                ,customer_trx_id
                ,customer_trx_line_id
	) VALUES (
		 x_WRITEOFF_OBJECT_ID
		,x_WRITEOFF_ID
		,x_OBJECT_VERSION_NUMBER
        ,decode( x_CONTRACT_ID, FND_API.G_MISS_NUM, NULL, x_CONTRACT_ID)
		,decode( x_CONS_INVOICE_ID, FND_API.G_MISS_NUM, NULL, x_CONS_INVOICE_ID)
        ,decode( x_CONS_INVOICE_LINE_ID, FND_API.G_MISS_NUM, NULL, x_CONS_INVOICE_LINE_ID)
        ,x_TRANSACTION_ID
		,x_ADJUSTMENT_AMOUNT
		,x_ADJUSTMENT_REASON_CODE
        ,decode( x_RECEVIABLES_ADJUSTMENT_ID, FND_API.G_MISS_NUM, NULL,
                                                x_RECEVIABLES_ADJUSTMENT_ID),
         decode( x_REQUEST_ID, FND_API.G_MISS_NUM, NULL, x_REQUEST_ID),
         decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, x_PROGRAM_APPLICATION_ID),
         decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, x_PROGRAM_ID),
         decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), x_PROGRAM_UPDATE_DATE),
         decode( x_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE_CATEGORY),
         decode( x_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE1),
         decode( x_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE2),
         decode( x_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE3),
         decode( x_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE4),
         decode( x_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE5),
         decode( x_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE6),
         decode( x_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE7),
         decode( x_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE8),
         decode( x_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE9),
         decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE10),
         decode( x_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE11),
         decode( x_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE12),
         decode( x_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE13),
         decode( x_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE14),
         decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, x_ATTRIBUTE15)
         ,x_CREATED_BY
         ,x_CREATION_DATE
         ,x_LAST_UPDATED_BY
         ,x_LAST_UPDATE_DATE
         ,decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, x_LAST_UPDATE_LOGIN)
         ,decode( x_writeoff_status, FND_API.G_MISS_CHAR, NULL, x_writeoff_status)
         ,decode( x_writeoff_type_id, FND_API.G_MISS_NUM, NULL, x_writeoff_type_id)
         ,decode( x_writeoff_type, FND_API.G_MISS_CHAR, NULL, x_writeoff_type)
         ,decode( x_customer_trx_id, FND_API.G_MISS_NUM, NULL, x_customer_trx_id)
         ,decode( x_customer_trx_line_id, FND_API.G_MISS_NUM, NULL, x_customer_trx_line_id)
        );

	OPEN C;
	FETCH C INTO x_rowid;
	IF (C%NOTFOUND) THEN
	   RAISE NO_DATA_FOUND;
	END IF;
	CLOSE C;
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage ('** End of Procedure =>'||
                           'IEX_WRITEOFF_OBJECTS_PKG.INSERT_ROW *** ');
        END IF;
END Insert_Row;

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
 x_customer_trx_line_id  in number)
  IS
BEGIN
	UPDATE IEX_WRITEOFF_OBJECTS SET
	         WRITEOFF_ID           = decode( x_WRITEOFF_ID, FND_API.G_MISS_NUM, NULL,
                                         NULL, WRITEOFF_ID, x_WRITEOFF_ID)
		,OBJECT_VERSION_NUMBER = decode( x_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM,NULL,
                                       NULL,OBJECT_VERSION_NUMBER, x_OBJECT_VERSION_NUMBER)

		,CONTRACT_ID           = decode( x_CONTRACT_ID, FND_API.G_MISS_NUM, NULL,
                                         NULL, CONTRACT_ID, x_CONTRACT_ID)

		,CONS_INVOICE_ID       = decode( x_CONS_INVOICE_ID, FND_API.G_MISS_NUM,NULL,
                                    NULL,CONS_INVOICE_ID, x_CONS_INVOICE_ID)

		,CONS_INVOICE_LINE_ID  = decode( x_CONS_INVOICE_LINE_ID, FND_API.G_MISS_NUM,NULL,
                                       NULL,CONS_INVOICE_LINE_ID,x_CONS_INVOICE_LINE_ID)

		,TRANSACTION_ID        = decode( x_TRANSACTION_ID, FND_API.G_MISS_NUM,NULL,
                                         NULL,TRANSACTION_ID, x_TRANSACTION_ID)

		,ADJUSTMENT_AMOUNT      = decode( x_ADJUSTMENT_AMOUNT, FND_API.G_MISS_NUM,NULL,
                                  NULL,ADJUSTMENT_AMOUNT, x_ADJUSTMENT_AMOUNT)

		,ADJUSTMENT_REASON_CODE   = decode( x_ADJUSTMENT_REASON_CODE, FND_API.G_MISS_CHAR,NULL,
                                    NULL,ADJUSTMENT_REASON_CODE, x_ADJUSTMENT_REASON_CODE)

		,RECEVIABLES_ADJUSTMENT_ID = decode( x_RECEVIABLES_ADJUSTMENT_ID, FND_API.G_MISS_NUM,NULL,
                                      NULL,RECEVIABLES_ADJUSTMENT_ID,  x_RECEVIABLES_ADJUSTMENT_ID)

                ,REQUEST_ID = decode( x_REQUEST_ID, FND_API.G_MISS_NUM,NULL, NULL,REQUEST_ID, x_REQUEST_ID)
                ,PROGRAM_APPLICATION_ID = decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM,NULL,
                           NULL,PROGRAM_APPLICATION_ID,   x_PROGRAM_APPLICATION_ID),
        PROGRAM_ID = decode( x_PROGRAM_ID, FND_API.G_MISS_NUM,NULL,
                                 NULL,PROGRAM_ID, x_PROGRAM_ID),
        PROGRAM_UPDATE_DATE = decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE,NULL,
                              NULL,PROGRAM_UPDATE_DATE, x_PROGRAM_UPDATE_DATE),
              ATTRIBUTE_CATEGORY = decode( x_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR,NULL,
                                           NULL,ATTRIBUTE_CATEGORY, x_ATTRIBUTE_CATEGORY),
              ATTRIBUTE1 = decode( x_ATTRIBUTE1, FND_API.G_MISS_CHAR,NULL,
                                    NULL,ATTRIBUTE1, x_ATTRIBUTE1),
              ATTRIBUTE2 = decode( x_ATTRIBUTE2, FND_API.G_MISS_CHAR,NULL,
                                      NULL,ATTRIBUTE2, x_ATTRIBUTE2),
              ATTRIBUTE3 = decode( x_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL,
                                     NULL,ATTRIBUTE3, x_ATTRIBUTE3),
              ATTRIBUTE4 = decode( x_ATTRIBUTE4, FND_API.G_MISS_CHAR,NULL,
                                      NULL,ATTRIBUTE4, x_ATTRIBUTE4),
              ATTRIBUTE5 = decode( x_ATTRIBUTE5, FND_API.G_MISS_CHAR,NULL,
                                      NULL,ATTRIBUTE5, x_ATTRIBUTE5),

              ATTRIBUTE6 = decode( x_ATTRIBUTE6, FND_API.G_MISS_CHAR,NULL,
                                    NULL,ATTRIBUTE6, x_ATTRIBUTE6),
              ATTRIBUTE7 = decode( x_ATTRIBUTE7, FND_API.G_MISS_CHAR,NULL,
                                      NULL,ATTRIBUTE7, x_ATTRIBUTE7),
              ATTRIBUTE8 = decode( x_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL,
                                     NULL,ATTRIBUTE8, x_ATTRIBUTE8),
              ATTRIBUTE9= decode( x_ATTRIBUTE9, FND_API.G_MISS_CHAR,NULL,
                                      NULL,ATTRIBUTE9, x_ATTRIBUTE9),
              ATTRIBUTE10 = decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR,NULL,
                                      NULL,ATTRIBUTE10, x_ATTRIBUTE10),

              ATTRIBUTE11 = decode( x_ATTRIBUTE11, FND_API.G_MISS_CHAR,NULL,
                                      NULL,ATTRIBUTE11, x_ATTRIBUTE11),

               ATTRIBUTE12 = decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR,NULL,
                                      NULL,ATTRIBUTE12, x_ATTRIBUTE12),

               ATTRIBUTE13 = decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR,NULL,
                                      NULL,ATTRIBUTE13, x_ATTRIBUTE13),
              ATTRIBUTE14 = decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR,NULL,
                                      NULL,ATTRIBUTE14, x_ATTRIBUTE14),
              ATTRIBUTE15 = decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR,NULL,
                                      NULL,ATTRIBUTE15, x_ATTRIBUTE15),

              LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,NULL,
                                       NULL,LAST_UPDATED_BY, x_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,NULL,
                                      NULL,LAST_UPDATE_DATE, x_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,NULL,
                                     NULL,LAST_UPDATE_LOGIN, x_LAST_UPDATE_LOGIN),
             WRITEOFF_STATUS = decode( x_WRITEOFF_STATUS, FND_API.G_MISS_CHAR,NULL,
                                   NULL,WRITEOFF_STATUS, x_WRITEOFF_STATUS),
             WRITEOFF_TYPE_ID = decode( x_WRITEOFF_TYPE_ID, FND_API.G_MISS_NUM,NULL,
                                     NULL,WRITEOFF_TYPE_ID, X_WRITEOFF_TYPE_ID),
             WRITEOFF_TYPE = decode( x_WRITEOFF_TYPE, FND_API.G_MISS_CHAR,NULL,
                                   NULL,WRITEOFF_TYPE, x_WRITEOFF_TYPE),
             customer_trx_id = decode( x_customer_trx_id, FND_API.G_MISS_NUM,NULL,
                                     NULL, customer_trx_id, x_customer_trx_id),
             customer_trx_line_id = decode( x_customer_trx_line_id, FND_API.G_MISS_NUM,NULL,
                                     NULL, customer_trx_line_id, x_customer_trx_line_id)

	 WHERE writeoff_object_id = x_WRITEOFF_OBJECT_ID;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Update_Row;

/* Delete_Row procedure */
 PROCEDURE Delete_Row(x_object_writeoff_id IN NUMBER)
  IS
BEGIN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('*** Start of Procedure =>IEX_WRITEOFF_OBJECTS_PKG.DELETE_ROW *** ');
     END IF;
      delete from IEX_WRITEOFF_OBJECTS
      where  writeoff_object_id = x_object_writeoff_id;

      if (sql%notfound) then
         raise no_data_found;
      end if;

END Delete_Row;

procedure LOCK_ROW (
  X_WRITEOFF_OBJECT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select OBJECT_VERSION_NUMBER
    from IEX_WRITEOFF_OBJECTS
    where WRITEOFF_OBJECT_ID = X_WRITEOFF_OBJECT_ID
    and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
    for update of WRITEOFF_OBJECT_ID nowait;
  recinfo c%rowtype;


begin
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
 IEX_DEBUG_PUB.LogMessage ('*** Start of Procedure =>IEX_WRITEOFF_OBJECTS_PKG.LOCK_ROW ** ');
 END IF;
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;

  close c;

  if recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_WRITEOFF_OBJECTS_PKG.LOCK_ROW ******** ');
END IF;
end LOCK_ROW;

END IEX_WRITEOFF_OBJECTS_PKG;


/
