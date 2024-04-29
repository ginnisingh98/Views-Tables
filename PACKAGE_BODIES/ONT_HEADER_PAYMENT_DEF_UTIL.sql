--------------------------------------------------------
--  DDL for Package Body ONT_HEADER_PAYMENT_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_HEADER_PAYMENT_DEF_UTIL" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_HEADER_PAYMENT_Def_Util
--  
--  DESCRIPTION
--  
--      Body of package ONT_HEADER_PAYMENT_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_HEADER_PAYMENT_Def_Util';
 
 
  g_database_object_name varchar2(30) :='OE_AK_HEADER_PAYMENTS_V';
 
  TYPE Condition_Rec_Type IS RECORD (
  condition_id      NUMBER,
  group_number      NUMBER,
  attribute_code      VARCHAR2(30),
  value_op            VARCHAR2(15),
  value_string      VARCHAR2(255));
 
  TYPE Condition_Tbl_Type IS TABLE OF Condition_Rec_Type
  INDEX BY BINARY_INTEGER;
  g_conditions_tbl_cache         Condition_Tbl_Type;
 
  g_attr_condns_cache         ONT_DEF_UTIL.Attr_Condn_Tbl_Type;
 
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE 
) RETURN VARCHAR2
IS
BEGIN
 
IF p_attr_code =('ATTRIBUTE1') THEN
  IF NVL(p_record.ATTRIBUTE1, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE1;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ATTRIBUTE10') THEN
  IF NVL(p_record.ATTRIBUTE10, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE10;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ATTRIBUTE11') THEN
  IF NVL(p_record.ATTRIBUTE11, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE11;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ATTRIBUTE12') THEN
  IF NVL(p_record.ATTRIBUTE12, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE12;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ATTRIBUTE13') THEN
  IF NVL(p_record.ATTRIBUTE13, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE13;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ATTRIBUTE14') THEN
  IF NVL(p_record.ATTRIBUTE14, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE14;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ATTRIBUTE15') THEN
  IF NVL(p_record.ATTRIBUTE15, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE15;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ATTRIBUTE2') THEN
  IF NVL(p_record.ATTRIBUTE2, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE2;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ATTRIBUTE3') THEN
  IF NVL(p_record.ATTRIBUTE3, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE3;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ATTRIBUTE4') THEN
  IF NVL(p_record.ATTRIBUTE4, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE4;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ATTRIBUTE5') THEN
  IF NVL(p_record.ATTRIBUTE5, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE5;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ATTRIBUTE6') THEN
  IF NVL(p_record.ATTRIBUTE6, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE6;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ATTRIBUTE7') THEN
  IF NVL(p_record.ATTRIBUTE7, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE7;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ATTRIBUTE8') THEN
  IF NVL(p_record.ATTRIBUTE8, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE8;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ATTRIBUTE9') THEN
  IF NVL(p_record.ATTRIBUTE9, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ATTRIBUTE9;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('CHECK_NUMBER') THEN
  IF NVL(p_record.CHECK_NUMBER, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.CHECK_NUMBER;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('COMMITMENT_APPLIED_AMOUNT') THEN
  IF NVL(p_record.COMMITMENT_APPLIED_AMOUNT, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.COMMITMENT_APPLIED_AMOUNT;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('COMMITMENT_INTERFACED_AMOUNT') THEN
  IF NVL(p_record.COMMITMENT_INTERFACED_AMOUNT, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.COMMITMENT_INTERFACED_AMOUNT;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('CONTEXT') THEN
  IF NVL(p_record.CONTEXT, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.CONTEXT;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('CREATED_BY') THEN
  IF NVL(p_record.CREATED_BY, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.CREATED_BY;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('CREATION_DATE') THEN
  IF NVL(p_record.CREATION_DATE, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE THEN
  RETURN p_record.CREATION_DATE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('CREDIT_CARD_APPROVAL_CODE') THEN
  IF NVL(p_record.CREDIT_CARD_APPROVAL_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.CREDIT_CARD_APPROVAL_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('CREDIT_CARD_APPROVAL_DATE') THEN
  IF NVL(p_record.CREDIT_CARD_APPROVAL_DATE, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE THEN
  RETURN p_record.CREDIT_CARD_APPROVAL_DATE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('CREDIT_CARD_CODE') THEN
  IF NVL(p_record.CREDIT_CARD_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.CREDIT_CARD_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('CREDIT_CARD_EXPIRATION_DATE') THEN
  IF NVL(p_record.CREDIT_CARD_EXPIRATION_DATE, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE THEN
  RETURN p_record.CREDIT_CARD_EXPIRATION_DATE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('CREDIT_CARD_HOLDER_NAME') THEN
  IF NVL(p_record.CREDIT_CARD_HOLDER_NAME, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.CREDIT_CARD_HOLDER_NAME;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('CREDIT_CARD_NUMBER') THEN
  IF NVL(p_record.CREDIT_CARD_NUMBER, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.CREDIT_CARD_NUMBER;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('DB_FLAG') THEN
  IF NVL(p_record.DB_FLAG, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.DB_FLAG;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('HEADER_ID') THEN
  IF NVL(p_record.HEADER_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.HEADER_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('LAST_UPDATED_BY') THEN
  IF NVL(p_record.LAST_UPDATED_BY, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.LAST_UPDATED_BY;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('LAST_UPDATE_DATE') THEN
  IF NVL(p_record.LAST_UPDATE_DATE, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE THEN
  RETURN p_record.LAST_UPDATE_DATE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('LAST_UPDATE_LOGIN') THEN
  IF NVL(p_record.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.LAST_UPDATE_LOGIN;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('LINE_ID') THEN
  IF NVL(p_record.LINE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.LINE_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('OPERATION') THEN
  IF NVL(p_record.OPERATION, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.OPERATION;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PAYMENT_AMOUNT') THEN
  IF NVL(p_record.PAYMENT_AMOUNT, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.PAYMENT_AMOUNT;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PAYMENT_COLLECTION_EVENT') THEN
  IF NVL(p_record.PAYMENT_COLLECTION_EVENT, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.PAYMENT_COLLECTION_EVENT;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PAYMENT_LEVEL_CODE') THEN
  IF NVL(p_record.PAYMENT_LEVEL_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.PAYMENT_LEVEL_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PAYMENT_NUMBER') THEN
  IF NVL(p_record.PAYMENT_NUMBER, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.PAYMENT_NUMBER;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PAYMENT_SET_ID') THEN
  IF NVL(p_record.PAYMENT_SET_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.PAYMENT_SET_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PAYMENT_TRX_ID') THEN
  IF NVL(p_record.PAYMENT_TRX_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.PAYMENT_TRX_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PAYMENT_TYPE_CODE') THEN
  IF NVL(p_record.PAYMENT_TYPE_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.PAYMENT_TYPE_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PREPAID_AMOUNT') THEN
  IF NVL(p_record.PREPAID_AMOUNT, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.PREPAID_AMOUNT;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PROGRAM_APPLICATION_ID') THEN
  IF NVL(p_record.PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.PROGRAM_APPLICATION_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PROGRAM_ID') THEN
  IF NVL(p_record.PROGRAM_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.PROGRAM_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PROGRAM_UPDATE_DATE') THEN
  IF NVL(p_record.PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE THEN
  RETURN p_record.PROGRAM_UPDATE_DATE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('RECEIPT_METHOD_ID') THEN
  IF NVL(p_record.RECEIPT_METHOD_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.RECEIPT_METHOD_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('REQUEST_ID') THEN
  IF NVL(p_record.REQUEST_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.REQUEST_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('RETURN_STATUS') THEN
  IF NVL(p_record.RETURN_STATUS, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.RETURN_STATUS;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('TANGIBLE_ID') THEN
  IF NVL(p_record.TANGIBLE_ID, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.TANGIBLE_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSE
RETURN NULL; 
END IF;
END  Get_Attr_Val_Varchar2;
 
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE 
) RETURN DATE
IS
BEGIN
 
IF p_attr_code =('CREATION_DATE') THEN
    IF NVL(p_record.CREATION_DATE, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE THEN
    RETURN p_record.CREATION_DATE;
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('CREDIT_CARD_APPROVAL_DATE') THEN
    IF NVL(p_record.CREDIT_CARD_APPROVAL_DATE, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE THEN
    RETURN p_record.CREDIT_CARD_APPROVAL_DATE;
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('CREDIT_CARD_EXPIRATION_DATE') THEN
    IF NVL(p_record.CREDIT_CARD_EXPIRATION_DATE, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE THEN
    RETURN p_record.CREDIT_CARD_EXPIRATION_DATE;
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('LAST_UPDATE_DATE') THEN
    IF NVL(p_record.LAST_UPDATE_DATE, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE THEN
    RETURN p_record.LAST_UPDATE_DATE;
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PROGRAM_UPDATE_DATE') THEN
    IF NVL(p_record.PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE THEN
    RETURN p_record.PROGRAM_UPDATE_DATE;
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE1') THEN
    IF NVL(p_record.ATTRIBUTE1, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE1,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE10') THEN
    IF NVL(p_record.ATTRIBUTE10, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE10,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE11') THEN
    IF NVL(p_record.ATTRIBUTE11, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE11,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE12') THEN
    IF NVL(p_record.ATTRIBUTE12, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE12,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE13') THEN
    IF NVL(p_record.ATTRIBUTE13, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE13,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE14') THEN
    IF NVL(p_record.ATTRIBUTE14, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE14,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE15') THEN
    IF NVL(p_record.ATTRIBUTE15, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE15,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE2') THEN
    IF NVL(p_record.ATTRIBUTE2, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE2,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE3') THEN
    IF NVL(p_record.ATTRIBUTE3, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE3,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE4') THEN
    IF NVL(p_record.ATTRIBUTE4, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE4,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE5') THEN
    IF NVL(p_record.ATTRIBUTE5, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE5,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE6') THEN
    IF NVL(p_record.ATTRIBUTE6, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE6,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE7') THEN
    IF NVL(p_record.ATTRIBUTE7, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE7,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE8') THEN
    IF NVL(p_record.ATTRIBUTE8, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE8,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ATTRIBUTE9') THEN
    IF NVL(p_record.ATTRIBUTE9, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ATTRIBUTE9,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('CHECK_NUMBER') THEN
    IF NVL(p_record.CHECK_NUMBER, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.CHECK_NUMBER,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('COMMITMENT_APPLIED_AMOUNT') THEN
    IF NVL(p_record.COMMITMENT_APPLIED_AMOUNT, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.COMMITMENT_APPLIED_AMOUNT,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('COMMITMENT_INTERFACED_AMOUNT') THEN
    IF NVL(p_record.COMMITMENT_INTERFACED_AMOUNT, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.COMMITMENT_INTERFACED_AMOUNT,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('CONTEXT') THEN
    IF NVL(p_record.CONTEXT, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.CONTEXT,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('CREATED_BY') THEN
    IF NVL(p_record.CREATED_BY, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.CREATED_BY,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('CREDIT_CARD_APPROVAL_CODE') THEN
    IF NVL(p_record.CREDIT_CARD_APPROVAL_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.CREDIT_CARD_APPROVAL_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('CREDIT_CARD_CODE') THEN
    IF NVL(p_record.CREDIT_CARD_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.CREDIT_CARD_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('CREDIT_CARD_HOLDER_NAME') THEN
    IF NVL(p_record.CREDIT_CARD_HOLDER_NAME, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.CREDIT_CARD_HOLDER_NAME,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('CREDIT_CARD_NUMBER') THEN
    IF NVL(p_record.CREDIT_CARD_NUMBER, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.CREDIT_CARD_NUMBER,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('DB_FLAG') THEN
    IF NVL(p_record.DB_FLAG, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.DB_FLAG,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('HEADER_ID') THEN
    IF NVL(p_record.HEADER_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.HEADER_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('LAST_UPDATED_BY') THEN
    IF NVL(p_record.LAST_UPDATED_BY, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.LAST_UPDATED_BY,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('LAST_UPDATE_LOGIN') THEN
    IF NVL(p_record.LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.LAST_UPDATE_LOGIN,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('LINE_ID') THEN
    IF NVL(p_record.LINE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.LINE_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('OPERATION') THEN
    IF NVL(p_record.OPERATION, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.OPERATION,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PAYMENT_AMOUNT') THEN
    IF NVL(p_record.PAYMENT_AMOUNT, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.PAYMENT_AMOUNT,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PAYMENT_COLLECTION_EVENT') THEN
    IF NVL(p_record.PAYMENT_COLLECTION_EVENT, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.PAYMENT_COLLECTION_EVENT,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PAYMENT_LEVEL_CODE') THEN
    IF NVL(p_record.PAYMENT_LEVEL_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.PAYMENT_LEVEL_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PAYMENT_NUMBER') THEN
    IF NVL(p_record.PAYMENT_NUMBER, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.PAYMENT_NUMBER,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PAYMENT_SET_ID') THEN
    IF NVL(p_record.PAYMENT_SET_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.PAYMENT_SET_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PAYMENT_TRX_ID') THEN
    IF NVL(p_record.PAYMENT_TRX_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.PAYMENT_TRX_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PAYMENT_TYPE_CODE') THEN
    IF NVL(p_record.PAYMENT_TYPE_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.PAYMENT_TYPE_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PREPAID_AMOUNT') THEN
    IF NVL(p_record.PREPAID_AMOUNT, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.PREPAID_AMOUNT,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PROGRAM_APPLICATION_ID') THEN
    IF NVL(p_record.PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.PROGRAM_APPLICATION_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PROGRAM_ID') THEN
    IF NVL(p_record.PROGRAM_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.PROGRAM_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('RECEIPT_METHOD_ID') THEN
    IF NVL(p_record.RECEIPT_METHOD_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.RECEIPT_METHOD_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('REQUEST_ID') THEN
    IF NVL(p_record.REQUEST_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.REQUEST_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('RETURN_STATUS') THEN
    IF NVL(p_record.RETURN_STATUS, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.RETURN_STATUS,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('TANGIBLE_ID') THEN
    IF NVL(p_record.TANGIBLE_ID, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.TANGIBLE_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSE
RETURN NULL; 
END IF;
 
END  Get_Attr_Val_Date;
 
 
  PROCEDURE Clear_HEADER_PAYMENT_Cache
  IS  
  BEGIN  
  g_cached_record.PAYMENT_NUMBER := null;
  g_cached_record.HEADER_ID := null;
  g_cached_record.LINE_ID := null;
   END Clear_HEADER_PAYMENT_Cache;
 
 
FUNCTION Sync_HEADER_PAYMENT_Cache
(   p_PAYMENT_NUMBER                IN  NUMBER
,   p_HEADER_ID                     IN  NUMBER
,   p_LINE_ID                       IN  NUMBER
 
 
) RETURN NUMBER
IS
CURSOR cache IS 
  SELECT * FROM   OE_AK_HEADER_PAYMENTS_V
  WHERE PAYMENT_NUMBER  = p_PAYMENT_NUMBER
  AND HEADER_ID  = p_HEADER_ID
  AND LINE_ID  = p_LINE_ID
  ;
BEGIN
 
IF (NVL(p_PAYMENT_NUMBER,FND_API.G_MISS_NUM)  = FND_API.G_MISS_NUM) 
OR (NVL(p_HEADER_ID,FND_API.G_MISS_NUM)  = FND_API.G_MISS_NUM) 
OR (NVL(p_LINE_ID,FND_API.G_MISS_NUM)  = FND_API.G_MISS_NUM) 
THEN
  RETURN 0 ;
ELSIF (NVL(g_cached_record.PAYMENT_NUMBER,FND_API.G_MISS_NUM)  <>  p_PAYMENT_NUMBER) 
OR (NVL(g_cached_record.HEADER_ID,FND_API.G_MISS_NUM)  <>  p_HEADER_ID) 
OR (NVL(g_cached_record.LINE_ID,FND_API.G_MISS_NUM)  <>  p_LINE_ID) 
THEN
  Clear_HEADER_PAYMENT_Cache;
  Open cache;
  FETCH cache into g_cached_record;
  IF cache%NOTFOUND THEN
    RETURN 0;
  END IF;
  Close cache;
  RETURN 1 ;
END IF;
 
  RETURN 1 ;
EXCEPTION
  WHEN OTHERS THEN 
  RETURN 0 ;
END Sync_HEADER_PAYMENT_Cache;
 
 
FUNCTION Get_Foreign_Attr_Val_Varchar2
(   p_foreign_attr_code             IN  VARCHAR2
,   p_record                        IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE 
,   p_foreign_database_object_name  IN  VARCHAR2
) RETURN VARCHAR2
 
IS
 
BEGIN
 
 IF (p_foreign_database_object_name = 'OE_AK_ORDER_HEADERS_V') THEN
    IF NVL(p_record.HEADER_ID,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN 
      RETURN NULL;
    END IF;
    IF  ONT_HEADER_Def_Util.Sync_HEADER_Cache
      (p_HEADER_ID => p_record.HEADER_ID) = 1  then 
    RETURN ONT_HEADER_Def_Util.Get_Attr_Val_Varchar2
      (p_foreign_attr_code,ONT_HEADER_Def_Util.g_cached_record); 
  END IF;
END IF;
 
     RETURN NULL;
END Get_Foreign_Attr_Val_Varchar2;
 
FUNCTION Get_Foreign_Attr_Val_Date
(   p_foreign_attr_code             IN  VARCHAR2
,   p_record                        IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE 
,   p_foreign_database_object_name  IN  VARCHAR2
) RETURN DATE
 
IS
BEGIN
 
 IF (p_foreign_database_object_name = 'OE_AK_ORDER_HEADERS_V') THEN
    IF NVL(p_record.HEADER_ID,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN 
      RETURN NULL;
    END IF;
    IF  ONT_HEADER_Def_Util.Sync_HEADER_Cache
      (p_HEADER_ID => p_record.HEADER_ID) = 1  then 
    RETURN ONT_HEADER_Def_Util.Get_Attr_Val_Date(p_foreign_attr_code,ONT_HEADER_Def_Util.g_cached_record); 
  END IF;
END IF;
 
     RETURN NULL;
END Get_Foreign_Attr_Val_Date;
 
 
FUNCTION Get_Condition_Index_In_Cache
(   p_condition_id                  IN  NUMBER
) RETURN NUMBER
IS  
BEGIN  
 
  FOR i in 0..g_conditions_tbl_cache.COUNT -1  LOOP  
    if (g_conditions_tbl_cache(i).condition_id = p_condition_id ) then  
      RETURN i; 
    END IF;  
  END LOOP;  
  RETURN -1; 
END Get_Condition_Index_In_Cache;  
FUNCTION Validate_Defaulting_Condition
(   p_condition_id                  IN  NUMBER
,   p_header_payment_rec            IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE 
) RETURN BOOLEAN
IS  
  CURSOR CONDNS IS  
  SELECT condition_id,group_number,attribute_code,
    value_op,value_string
  FROM OE_DEF_CONDN_ELEMS
  WHERE condition_id = p_condition_id
  ORDER BY group_number;
 
  I         NUMBER;  
  l_column_value          VARCHAR2(255);  
  l_start_index         NUMBER;  
  l_stop_index         NUMBER ;  
  l_curr_group         NUMBER;  
  l_group_result         BOOLEAN;  
  l_element_result         BOOLEAN;  
BEGIN  
 
  l_start_index := Get_Condition_Index_In_Cache(p_condition_id);
IF (l_start_index = -1) THEN  
  l_stop_index := g_conditions_tbl_cache.COUNT;  
  l_start_index := l_stop_index;
  i := l_start_index;
  FOR condns_rec IN CONDNS LOOP  
    g_conditions_tbl_cache(i).condition_id := condns_rec.condition_id;
    g_conditions_tbl_cache(i).group_number := condns_rec.group_number;
    g_conditions_tbl_cache(i).attribute_code := condns_rec.attribute_code;
    g_conditions_tbl_cache(i).value_op := condns_rec.value_op;
    g_conditions_tbl_cache(i).value_string := condns_rec.value_string;
  i := i+1;
  END LOOP;  
IF (i = l_start_index) THEN  
    Return FALSE;  
  END IF;  
  END IF;  
 
 
  i := 0;
  l_curr_group := g_conditions_tbl_cache(l_start_index).group_number;
  l_group_result := TRUE;
  l_element_result := FALSE;
 
 IF g_conditions_tbl_cache.COUNT <> 0 then  
FOR J in l_start_index ..g_conditions_tbl_cache.COUNT -1 LOOP  
  IF (g_conditions_tbl_cache(j).condition_id <>  p_condition_id) THEN
    EXIT;
  END IF;
 
  IF (l_curr_group <>  g_conditions_tbl_cache(j).group_number) THEN
    IF (l_group_result = TRUE) THEN
      EXIT;
    ELSE
      l_group_result := TRUE;
    END IF;
  END IF;
 
  l_element_result := ONT_Def_Util.Validate_Value(g_conditions_tbl_cache(j).value_string,
  g_conditions_tbl_cache(j).value_op,Get_Attr_Val_Varchar2(g_conditions_tbl_cache(j).attribute_code,p_header_payment_rec ));
    l_group_result := l_group_result AND l_element_result;
END LOOP;
ELSE
  l_group_result := FALSE;
  END IF;
  RETURN l_group_result;
END Validate_Defaulting_Condition;
 
 
PROCEDURE Update_Attr_Rules_Cache
	( p_condn_index		        IN NUMBER
	)
IS
l_index			NUMBER := 0;
l_start_index		NUMBER := 0;
l_attribute_code		VARCHAR2(30);
l_condition_id		NUMBER;
    CURSOR DEFSRC IS SELECT
    R.SEQUENCE_NO,
    R.SRC_TYPE,
    R.SRC_ATTRIBUTE_CODE,
    R.SRC_DATABASE_OBJECT_NAME,
    R.SRC_PARAMETER_NAME,
    R.SRC_SYSTEM_VARIABLE_EXPR,
    R.SRC_PROFILE_OPTION,
    R.SRC_API_PKG||'.'||R.SRC_API_FN SRC_API_NAME,
    R.SRC_CONSTANT_VALUE,
    R.SRC_SEQUENCE_NAME
    FROM OE_DEF_ATTR_DEF_RULES R, OE_DEF_ATTR_CONDNS C
    WHERE R.database_object_name = g_database_object_name
    AND R.attribute_code = l_attribute_code
    AND C.database_object_name = g_database_object_name
    AND C.attribute_code = l_attribute_code
    AND R.attr_def_condition_id = C.attr_def_condition_id
    AND C.CONDITION_ID = l_condition_id
    AND C.ENABLED_FLAG = 'Y'
    ORDER BY SEQUENCE_NO;
BEGIN
 
      l_attribute_code := g_attr_condns_cache(p_condn_index).attribute_code;
      l_condition_id := g_attr_condns_cache(p_condn_index).condition_id;
      l_start_index := g_attr_rules_cache.COUNT + 1;
 
    FOR DEFSRC_rec IN DEFSRC LOOP
	l_index := g_attr_rules_cache.COUNT + 1; 
	g_attr_rules_cache(l_index).SRC_TYPE 
			:= DEFSRC_rec.SRC_TYPE; 
	g_attr_rules_cache(l_index).SRC_ATTRIBUTE_CODE 
			:= DEFSRC_rec.SRC_ATTRIBUTE_CODE; 
	g_attr_rules_cache(l_index).SRC_DATABASE_OBJECT_NAME 
			:= DEFSRC_rec.SRC_DATABASE_OBJECT_NAME; 
	g_attr_rules_cache(l_index).SRC_PARAMETER_NAME 
			:= DEFSRC_rec.SRC_PARAMETER_NAME; 
	g_attr_rules_cache(l_index).SRC_SYSTEM_VARIABLE_EXPR 
			:= DEFSRC_rec.SRC_SYSTEM_VARIABLE_EXPR; 
	g_attr_rules_cache(l_index).SRC_PROFILE_OPTION
			:= DEFSRC_rec.SRC_PROFILE_OPTION; 
	g_attr_rules_cache(l_index).SRC_API_NAME
			:= DEFSRC_rec.SRC_API_NAME; 
	g_attr_rules_cache(l_index).SRC_CONSTANT_VALUE
			:= DEFSRC_rec.SRC_CONSTANT_VALUE; 
	g_attr_rules_cache(l_index).SRC_SEQUENCE_NAME
			:= DEFSRC_rec.SRC_SEQUENCE_NAME; 
   END LOOP;
 
   IF l_index > 0 THEN
	g_attr_condns_cache(p_condn_index).rules_start_index := l_start_index;
	g_attr_condns_cache(p_condn_index).rules_stop_index := l_index;
   ELSE
	g_attr_condns_cache(p_condn_index).rules_start_index := -1;
   END IF;
 
EXCEPTION
	WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME          ,
		'Update_Attr_Rules_Cache: '||l_attribute_code
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Update_Attr_Rules_Cache;
 
 
PROCEDURE Get_Valid_Defaulting_Rules
(   p_attr_code                     IN  VARCHAR2
,   p_attr_id                       IN  NUMBER
,   p_header_payment_rec            IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE
,   x_rules_start_index_tbl         OUT OE_GLOBALS.NUMBER_TBL_Type
,   x_rules_stop_index_tbl          OUT OE_GLOBALS.NUMBER_TBL_Type
) IS
l_condn_index     			NUMBER; 
l_index     				NUMBER := 0; 
l_valid_condn_index_tbl		OE_GLOBALS.Number_TBL_Type; 
condns_cached				BOOLEAN := FALSE;
num_attr_condns			NUMBER := 0;
CURSOR ATTRC IS    
    SELECT condition_id  
    FROM OE_DEF_ATTR_CONDNS    
    WHERE attribute_code = p_attr_code  
      AND database_object_name = g_database_object_name  
      AND enabled_flag = 'Y'
    ORDER BY precedence;
BEGIN  
 
  l_condn_index := p_attr_id * ONT_Def_Util.G_MAX_ATTR_CONDNS;
 
  -- Check in the cache
  WHILE g_attr_condns_cache.EXISTS(l_condn_index) LOOP
    condns_cached := TRUE;
    IF g_attr_condns_cache(l_condn_index).conditions_defined = 'N' THEN
      EXIT;
    ELSE
      IF (g_attr_condns_cache(l_condn_index).condition_id = 0 OR
         Validate_Defaulting_Condition
	       (g_attr_condns_cache(l_condn_index).condition_id,p_header_payment_rec)= TRUE) THEN 
	     l_index := l_index + 1;
	     l_valid_condn_index_tbl(l_index) := l_condn_index;
      END IF;
    END IF;
    l_condn_index := l_condn_index + 1;
  END LOOP;
 
  -- If the conditions were cached for this attribute, 
  -- then return rules for valid conditions
  IF condns_cached THEN
 
      GOTO Return_Rules;
 
  -- If the conditions were NOT cached for this attribute,
  -- then cache them AND get the conditions that are valid
  -- for the current record
  ELSE
    FOR c_rec IN ATTRC LOOP  
      -- Put it in the cache
      g_attr_condns_cache(l_condn_index).attribute_code
        := p_attr_code;
      g_attr_condns_cache(l_condn_index).condition_id
        := c_rec.condition_id;
      g_attr_condns_cache(l_condn_index).conditions_defined
        := 'Y';
	  IF (c_rec.condition_id = 0 OR
	         Validate_Defaulting_Condition
		  (c_rec.condition_id,p_header_payment_rec)= TRUE) THEN 
	     l_index := l_index + 1;
	     l_valid_condn_index_tbl(l_index) := l_condn_index;
      END IF;
      l_condn_index := l_condn_index + 1;
      num_attr_condns := num_attr_condns + 1;
    END LOOP;
 
    -- No defaulting conditions defined for this attribute,
    -- insert a new record in the cache with conditions_defined = 'N'
    IF num_attr_condns = 0 THEN
      g_attr_condns_cache(l_condn_index).attribute_code
        := p_attr_code;
      g_attr_condns_cache(l_condn_index).conditions_defined
        := 'N';
    END IF;
 
  END IF;
 
  <<Return_Rules>>
FOR I IN 1..l_index LOOP
  IF g_attr_condns_cache(l_valid_condn_index_tbl(I)).rules_start_index IS NULL THEN
     Update_Attr_Rules_Cache(l_valid_condn_index_tbl(I));
  END IF;
  x_rules_start_index_tbl(I) := g_attr_condns_cache(l_valid_condn_index_tbl(I)).rules_start_index;
  x_rules_stop_index_tbl(I) := g_attr_condns_cache(l_valid_condn_index_tbl(I)).rules_stop_index;
END LOOP;
 
EXCEPTION
	WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME          ,
		'Get_Valid_Defaulting_Rules :'||p_attr_code
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Valid_Defaulting_Rules;
 
 
END ONT_HEADER_PAYMENT_Def_Util;

/
