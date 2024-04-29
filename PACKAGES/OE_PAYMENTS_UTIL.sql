--------------------------------------------------------
--  DDL for Package OE_PAYMENTS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PAYMENTS_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXULCMS.pls 120.0 2005/05/31 23:44:15 appldev noship $ */

Type Payment_Types_Rec_Type  is RECORD
(   PAYMENT_TRX_ID			NUMBER
,   COMMITMENT_APPLIED_AMOUNT	   	NUMBER
,   COMMITMENT_INTERFACED_AMOUNT	NUMBER
/* START PREPAYMENT */
,   PAYMENT_SET_ID                      NUMBER
,   PREPAID_AMOUNT                      NUMBER
,   PAYMENT_TYPE_CODE                   VARCHAR2(30)
,   CREDIT_CARD_CODE                    VARCHAR2(30)
,   CREDIT_CARD_NUMBER                  VARCHAR2(80)
,   CREDIT_CARD_HOLDER_NAME             VARCHAR2(80)
,   CREDIT_CARD_EXPIRATION_DATE         DATE
/* END PREPAYMENT */
,   PAYMENT_LEVEL_CODE		VARCHAR2(30)
,   HEADER_ID				NUMBER
,   LINE_ID				NUMBER
,   CREATION_DATE		DATE
,   CREATED_BY			NUMBER
,   LAST_UPDATE_DATE		DATE
,   LAST_UPDATED_BY			NUMBER
,   LAST_UPDATE_LOGIN			NUMBER
,   REQUEST_ID				NUMBER
,   PROGRAM_APPLICATION_ID		NUMBER
,   PROGRAM_ID				NUMBER
,   PROGRAM_UPDATE_DATE			DATE
,   CONTEXT				VARCHAR2(30)
,   ATTRIBUTE1				VARCHAR2(240)
,   ATTRIBUTE2				VARCHAR2(240)
,   ATTRIBUTE3				VARCHAR2(240)
,   ATTRIBUTE4				VARCHAR2(240)
,   ATTRIBUTE5				VARCHAR2(240)
,   ATTRIBUTE6				VARCHAR2(240)
,   ATTRIBUTE7				VARCHAR2(240)
,   ATTRIBUTE8				VARCHAR2(240)
,   ATTRIBUTE9				VARCHAR2(240)
,   ATTRIBUTE10				VARCHAR2(240)
,   ATTRIBUTE11				VARCHAR2(240)
,   ATTRIBUTE12				VARCHAR2(240)
,   ATTRIBUTE13				VARCHAR2(240)
,   ATTRIBUTE14				VARCHAR2(240)
,   ATTRIBUTE15				VARCHAR2(240)
,   db_flag				VARCHAR2(1)
,   operation				VARCHAR2(30)
,   return_status			VARCHAR2(1)
,   payment_amount                      NUMBER
,   payment_number                      NUMBER
);

TYPE  Payment_Types_Tbl_Type is TABLE of Payment_Types_Rec_Type
	INDEX by BINARY_INTEGER;

PROCEDURE Update_Row
(   p_payment_types_rec	IN OUT NOCOPY Payment_Types_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_payment_types_rec	IN OUT NOCOPY Payment_Types_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_payment_trx_id	IN  NUMBER := FND_API.G_MISS_NUM
,   p_header_id       	IN  NUMBER := FND_API.G_MISS_NUM
,   p_line_id       	IN  NUMBER := FND_API.G_MISS_NUM
);

--  Procedure Query_Row
PROCEDURE Query_Row
(   p_payment_trx_id       	IN  	NUMBER
,   p_header_id			IN 	NUMBER
,   p_line_id				IN 	NUMBER
,   x_payment_types_rec 	IN OUT NOCOPY  Payment_Types_Rec_Type
);

--  Procedure Query_Rows
PROCEDURE Query_Rows
(   p_payment_trx_id	IN  NUMBER := FND_API.G_MISS_NUM
,   p_Header_id          IN  NUMBER := FND_API.G_MISS_NUM
,   p_line_id            IN  NUMBER := FND_API.G_MISS_NUM
,   x_Payment_Types_Tbl	IN OUT NOCOPY Payment_Types_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

);

FUNCTION Get_Uninvoiced_Commitment_Bal
	(p_customer_trx_id IN NUMBER
	)
RETURN NUMBER;


/***
--  Procedure       lock_Row
PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_payment_types_rec     IN OUT NOCOPY Payment_Types_Rec_Type
,   p_payment_id           	IN NUMBER
                              	:= FND_API.G_MISS_NUM
);

--  Procedure       lock_Rows
PROCEDURE Lock_Rows
(   p_payment_id         IN NUMBER
                         	:= FND_API.G_MISS_NUM
,   p_line_id           	IN NUMBER
                         	:= FND_API.G_MISS_NUM
,   x_payment_types_tbl  OUT NOCOPY Payment_Types_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

);
***/


END oe_payments_Util;

 

/
