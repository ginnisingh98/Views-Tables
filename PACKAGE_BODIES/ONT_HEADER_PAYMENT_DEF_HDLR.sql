--------------------------------------------------------
--  DDL for Package Body ONT_HEADER_PAYMENT_DEF_HDLR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_HEADER_PAYMENT_DEF_HDLR" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_HEADER_PAYMENT_Def_Hdlr
--  
--  DESCRIPTION
--  
--      Body of package ONT_HEADER_PAYMENT_Def_Hdlr
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_HEADER_PAYMENT_Def_Hdlr';
 
  g_entity_code  varchar2(15) := 'HEADER_PAYMENT';
  g_database_object_name varchar2(30) :='OE_AK_HEADER_PAYMENTS_V';
 
--  Default_Record
PROCEDURE Default_Record
  (   p_x_rec                         IN OUT NOCOPY  OE_AK_HEADER_PAYMENTS_V%ROWTYPE
,   p_in_old_rec                    IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE 
,   p_iteration                     IN  NUMBER default 1
)
IS
l_action  NUMBER;
l_attr  VARCHAR2(200);
BEGIN
 
oe_debug_pub.ADD('Enter ONT_HEADER_PAYMENT_Def_Hdlr.Default_Record');
 
IF p_iteration =1 THEN
OE_HEADER_PAYMENT_Security.G_Is_Caller_Defaulting := 'Y';
  g_record := p_x_rec;
END IF;
 
--  if max. iteration is reached exit
IF p_iteration > ONT_DEF_UTIL.G_MAX_DEF_ITERATIONS THEN
    FND_MESSAGE.SET_NAME('ONT','OE_DEF_MAX_ITERATIONS');
    OE_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
END IF;
 
--  Default missing attributes
l_attr:= 'PAYMENT_TYPE_CODE';
 
IF g_record.PAYMENT_TYPE_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.PAYMENT_TYPE_CODE := ONT_D1024_PAYMENT_TYPE_CODE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.payment_type_code, p_in_old_rec.payment_type_code) THEN
      IF OE_HEADER_PAYMENT_SECURITY.PAYMENT_TYPE_CODE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.PAYMENT_TYPE_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
      -- if valid, clear dependent attributes
      OE_HEADER_PAYMENT_CL_DEP_ATTR.PAYMENT_TYPE_CODE(g_record);
  END IF;
END IF;
l_attr:= 'ATTRIBUTE1';
 
IF g_record.ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE1 := NULL;
END IF;
l_attr:= 'ATTRIBUTE10';
 
IF g_record.ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE10 := NULL;
END IF;
l_attr:= 'ATTRIBUTE11';
 
IF g_record.ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE11 := NULL;
END IF;
l_attr:= 'ATTRIBUTE12';
 
IF g_record.ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE12 := NULL;
END IF;
l_attr:= 'ATTRIBUTE13';
 
IF g_record.ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE13 := NULL;
END IF;
l_attr:= 'ATTRIBUTE14';
 
IF g_record.ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE14 := NULL;
END IF;
l_attr:= 'ATTRIBUTE15';
 
IF g_record.ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE15 := NULL;
END IF;
l_attr:= 'ATTRIBUTE2';
 
IF g_record.ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE2 := NULL;
END IF;
l_attr:= 'ATTRIBUTE3';
 
IF g_record.ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE3 := NULL;
END IF;
l_attr:= 'ATTRIBUTE4';
 
IF g_record.ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE4 := NULL;
END IF;
l_attr:= 'ATTRIBUTE5';
 
IF g_record.ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE5 := NULL;
END IF;
l_attr:= 'ATTRIBUTE6';
 
IF g_record.ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE6 := NULL;
END IF;
l_attr:= 'ATTRIBUTE7';
 
IF g_record.ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE7 := NULL;
END IF;
l_attr:= 'ATTRIBUTE8';
 
IF g_record.ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE8 := NULL;
END IF;
l_attr:= 'ATTRIBUTE9';
 
IF g_record.ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE9 := NULL;
END IF;
l_attr:= 'CHECK_NUMBER';
 
IF g_record.CHECK_NUMBER = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CHECK_NUMBER := NULL;
END IF;
l_attr:= 'COMMITMENT_APPLIED_AMOUNT';
 
IF g_record.COMMITMENT_APPLIED_AMOUNT = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.COMMITMENT_APPLIED_AMOUNT := NULL;
END IF;
l_attr:= 'COMMITMENT_INTERFACED_AMOUNT';
 
IF g_record.COMMITMENT_INTERFACED_AMOUNT = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.COMMITMENT_INTERFACED_AMOUNT := NULL;
END IF;
l_attr:= 'CONTEXT';
 
IF g_record.CONTEXT = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CONTEXT := NULL;
END IF;
l_attr:= 'CREATED_BY';
 
IF g_record.CREATED_BY = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CREATED_BY := NULL;
END IF;
l_attr:= 'CREATION_DATE';
 
IF g_record.CREATION_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CREATION_DATE := NULL;
END IF;
l_attr:= 'CREDIT_CARD_CODE';
 
IF g_record.CREDIT_CARD_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CREDIT_CARD_CODE := NULL;
END IF;
l_attr:= 'CREDIT_CARD_APPROVAL_CODE';
 
IF g_record.CREDIT_CARD_APPROVAL_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CREDIT_CARD_APPROVAL_CODE := NULL;
END IF;
l_attr:= 'CREDIT_CARD_APPROVAL_DATE';
 
IF g_record.CREDIT_CARD_APPROVAL_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CREDIT_CARD_APPROVAL_DATE := NULL;
END IF;
l_attr:= 'CREDIT_CARD_NUMBER';
 
IF g_record.CREDIT_CARD_NUMBER = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CREDIT_CARD_NUMBER := ONT_D1024_CREDIT_CARD_NUMBER.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'DB_FLAG';
 
IF g_record.DB_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.DB_FLAG := NULL;
END IF;
l_attr:= 'HEADER_ID';
 
IF g_record.HEADER_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.HEADER_ID := NULL;
END IF;
l_attr:= 'LAST_UPDATE_DATE';
 
IF g_record.LAST_UPDATE_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.LAST_UPDATE_DATE := NULL;
END IF;
l_attr:= 'LAST_UPDATE_LOGIN';
 
IF g_record.LAST_UPDATE_LOGIN = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.LAST_UPDATE_LOGIN := NULL;
END IF;
l_attr:= 'LAST_UPDATED_BY';
 
IF g_record.LAST_UPDATED_BY = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.LAST_UPDATED_BY := NULL;
END IF;
l_attr:= 'LINE_ID';
 
IF g_record.LINE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.LINE_ID := NULL;
END IF;
l_attr:= 'OPERATION';
 
IF g_record.OPERATION = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.OPERATION := NULL;
END IF;
l_attr:= 'PAYMENT_AMOUNT';
 
IF g_record.PAYMENT_AMOUNT = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PAYMENT_AMOUNT := NULL;
END IF;
l_attr:= 'PAYMENT_COLLECTION_EVENT';
 
IF g_record.PAYMENT_COLLECTION_EVENT = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PAYMENT_COLLECTION_EVENT := NULL;
END IF;
l_attr:= 'PAYMENT_LEVEL_CODE';
 
IF g_record.PAYMENT_LEVEL_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PAYMENT_LEVEL_CODE := NULL;
END IF;
l_attr:= 'PAYMENT_NUMBER';
 
IF g_record.PAYMENT_NUMBER = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PAYMENT_NUMBER := NULL;
END IF;
l_attr:= 'PAYMENT_SET_ID';
 
IF g_record.PAYMENT_SET_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PAYMENT_SET_ID := NULL;
END IF;
l_attr:= 'PAYMENT_TRX_ID';
 
IF g_record.PAYMENT_TRX_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PAYMENT_TRX_ID := NULL;
END IF;
l_attr:= 'PREPAID_AMOUNT';
 
IF g_record.PREPAID_AMOUNT = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PREPAID_AMOUNT := NULL;
END IF;
l_attr:= 'PROGRAM_ID';
 
IF g_record.PROGRAM_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PROGRAM_ID := NULL;
END IF;
l_attr:= 'PROGRAM_APPLICATION_ID';
 
IF g_record.PROGRAM_APPLICATION_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PROGRAM_APPLICATION_ID := NULL;
END IF;
l_attr:= 'PROGRAM_UPDATE_DATE';
 
IF g_record.PROGRAM_UPDATE_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PROGRAM_UPDATE_DATE := NULL;
END IF;
l_attr:= 'REQUEST_ID';
 
IF g_record.REQUEST_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.REQUEST_ID := NULL;
END IF;
l_attr:= 'RETURN_STATUS';
 
IF g_record.RETURN_STATUS = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_STATUS := NULL;
END IF;
l_attr:= 'TANGIBLE_ID';
 
IF g_record.TANGIBLE_ID = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.TANGIBLE_ID := NULL;
END IF;
l_attr:= 'CREDIT_CARD_EXPIRATION_DATE';
 
IF g_record.CREDIT_CARD_EXPIRATION_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CREDIT_CARD_EXPIRATION_DATE := ONT_D1024_CREDIT_CARD_EXPIRATI.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'CREDIT_CARD_HOLDER_NAME';
 
IF g_record.CREDIT_CARD_HOLDER_NAME = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CREDIT_CARD_HOLDER_NAME := ONT_D1024_CREDIT_CARD_HOLDER_N.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'RECEIPT_METHOD_ID';
 
IF g_record.RECEIPT_METHOD_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.RECEIPT_METHOD_ID := ONT_D1024_RECEIPT_METHOD_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.receipt_method_id, p_in_old_rec.receipt_method_id) THEN
      IF OE_HEADER_PAYMENT_SECURITY.RECEIPT_METHOD(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.RECEIPT_METHOD_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
      -- if valid, clear dependent attributes
      OE_HEADER_PAYMENT_CL_DEP_ATTR.RECEIPT_METHOD(g_record);
  END IF;
END IF;
 
    --  CHeck if there are any missing values for attrs
    --  If there are any missing call Default_Record again AND repeat till all the values 
    --  are defaulted or till the max. iterations are reached
 
     IF( 
      (g_record.PAYMENT_TYPE_CODE =FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE1 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE10 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE11 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE12 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE13 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE14 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE15 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE2 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE3 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE4 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE5 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE6 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE7 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE8 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE9 = FND_API.G_MISS_CHAR)  
     OR (g_record.CHECK_NUMBER = FND_API.G_MISS_CHAR)  
     OR (g_record.COMMITMENT_APPLIED_AMOUNT = FND_API.G_MISS_NUM)  
     OR (g_record.COMMITMENT_INTERFACED_AMOUNT = FND_API.G_MISS_NUM)  
     OR (g_record.CONTEXT = FND_API.G_MISS_CHAR)  
     OR (g_record.CREATED_BY = FND_API.G_MISS_NUM)  
     OR (g_record.CREATION_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.CREDIT_CARD_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.CREDIT_CARD_APPROVAL_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.CREDIT_CARD_APPROVAL_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.CREDIT_CARD_NUMBER = FND_API.G_MISS_CHAR)  
     OR (g_record.DB_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.HEADER_ID = FND_API.G_MISS_NUM)  
     OR (g_record.LAST_UPDATE_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.LAST_UPDATE_LOGIN = FND_API.G_MISS_NUM)  
     OR (g_record.LAST_UPDATED_BY = FND_API.G_MISS_NUM)  
     OR (g_record.LINE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.OPERATION = FND_API.G_MISS_CHAR)  
     OR (g_record.PAYMENT_AMOUNT = FND_API.G_MISS_NUM)  
     OR (g_record.PAYMENT_COLLECTION_EVENT = FND_API.G_MISS_CHAR)  
     OR (g_record.PAYMENT_LEVEL_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.PAYMENT_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.PAYMENT_SET_ID = FND_API.G_MISS_NUM)  
     OR (g_record.PAYMENT_TRX_ID = FND_API.G_MISS_NUM)  
     OR (g_record.PREPAID_AMOUNT = FND_API.G_MISS_NUM)  
     OR (g_record.PROGRAM_ID = FND_API.G_MISS_NUM)  
     OR (g_record.PROGRAM_APPLICATION_ID = FND_API.G_MISS_NUM)  
     OR (g_record.PROGRAM_UPDATE_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.REQUEST_ID = FND_API.G_MISS_NUM)  
     OR (g_record.RETURN_STATUS = FND_API.G_MISS_CHAR)  
     OR (g_record.TANGIBLE_ID = FND_API.G_MISS_CHAR)  
     OR (g_record.CREDIT_CARD_EXPIRATION_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.CREDIT_CARD_HOLDER_NAME = FND_API.G_MISS_CHAR)  
     OR (g_record.RECEIPT_METHOD_ID = FND_API.G_MISS_NUM)  
    ) THEN   
    ONT_HEADER_PAYMENT_Def_Hdlr.Default_Record(
     p_x_rec => g_record,
     p_in_old_rec => p_in_old_rec,
      p_iteration => p_iteration+1 );
    END IF;
 
IF p_iteration =1 THEN
OE_HEADER_PAYMENT_Security.G_Is_Caller_Defaulting := 'N';
  p_x_rec := g_record;
END IF;
 
oe_debug_pub.ADD('Exit ONT_HEADER_PAYMENT_Def_Hdlr.Default_Record');
 
EXCEPTION
 
  WHEN FND_API.G_EXC_ERROR THEN
    OE_HEADER_PAYMENT_Security.G_Is_Caller_Defaulting := 'N';
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    OE_HEADER_PAYMENT_Security.G_Is_Caller_Defaulting := 'N';
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      ,'Default_Record: '||l_attr
      );
    END IF;
    OE_HEADER_PAYMENT_Security.G_Is_Caller_Defaulting := 'N';
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 
END Default_Record;
 
END ONT_HEADER_PAYMENT_Def_Hdlr;

/
