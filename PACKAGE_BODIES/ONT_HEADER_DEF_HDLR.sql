--------------------------------------------------------
--  DDL for Package Body ONT_HEADER_DEF_HDLR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_HEADER_DEF_HDLR" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_HEADER_Def_Hdlr
--  
--  DESCRIPTION
--  
--      Body of package ONT_HEADER_Def_Hdlr
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_HEADER_Def_Hdlr';
 
  g_entity_code  varchar2(15) := 'HEADER';
  g_database_object_name varchar2(30) :='OE_AK_ORDER_HEADERS_V';
 
--  Default_Record
PROCEDURE Default_Record
  (   p_x_rec                         IN OUT NOCOPY  OE_AK_ORDER_HEADERS_V%ROWTYPE
,   p_initial_rec                   IN  OE_AK_ORDER_HEADERS_V%ROWTYPE 
,   p_in_old_rec                    IN  OE_AK_ORDER_HEADERS_V%ROWTYPE 
,   p_iteration                     IN  NUMBER default 1
)
IS
l_action  NUMBER;
l_attr  VARCHAR2(200);
BEGIN
 
oe_debug_pub.ADD('Enter ONT_HEADER_Def_Hdlr.Default_Record');
 
IF p_iteration =1 THEN
OE_HEADER_Security.G_Is_Caller_Defaulting := 'Y';
  g_record := p_x_rec;
END IF;
 
--  if max. iteration is reached exit
IF p_iteration > ONT_DEF_UTIL.G_MAX_DEF_ITERATIONS THEN
    FND_MESSAGE.SET_NAME('ONT','OE_DEF_MAX_ITERATIONS');
    OE_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
END IF;
 
--  Default missing attributes
l_attr:= 'SOLD_TO_ORG_ID';
 
IF g_record.SOLD_TO_ORG_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SOLD_TO_ORG_ID := ONT_D1_SOLD_TO_ORG_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  IF g_record.SOLD_TO_ORG_ID IS NULL 
   AND p_in_old_rec.SOLD_TO_ORG_ID <> FND_API.G_MISS_NUM THEN 
  g_record.SOLD_TO_ORG_ID := p_in_old_rec.SOLD_TO_ORG_ID;
  END IF;
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.sold_to_org_id, p_in_old_rec.sold_to_org_id) THEN
      IF OE_HEADER_SECURITY.SOLD_TO_ORG(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SOLD_TO_ORG_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SOLD_TO_ORG(g_record.SOLD_TO_ORG_ID) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.SOLD_TO_ORG(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.SOLD_TO_ORG_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SHIP_TO_ORG_ID';
 
IF g_record.SHIP_TO_ORG_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SHIP_TO_ORG_ID := ONT_D1_SHIP_TO_ORG_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ship_to_org_id, p_in_old_rec.ship_to_org_id) THEN
      IF OE_HEADER_SECURITY.SHIP_TO_ORG(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SHIP_TO_ORG_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SHIP_TO_ORG(g_record.SHIP_TO_ORG_ID) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.SHIP_TO_ORG(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.SHIP_TO_ORG_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'DELIVER_TO_ORG_ID';
 
IF g_record.DELIVER_TO_ORG_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.DELIVER_TO_ORG_ID := ONT_D1_DELIVER_TO_ORG_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.deliver_to_org_id, p_in_old_rec.deliver_to_org_id) THEN
      IF OE_HEADER_SECURITY.DELIVER_TO_ORG(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.DELIVER_TO_ORG_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.DELIVER_TO_ORG(g_record.DELIVER_TO_ORG_ID) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.DELIVER_TO_ORG(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.DELIVER_TO_ORG_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'AGREEMENT_ID';
 
IF g_record.AGREEMENT_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.AGREEMENT_ID := ONT_D1_AGREEMENT_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.agreement_id, p_in_old_rec.agreement_id) THEN
      IF OE_HEADER_SECURITY.AGREEMENT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.AGREEMENT_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.AGREEMENT(g_record.AGREEMENT_ID) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.AGREEMENT(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.AGREEMENT_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'INVOICE_TO_ORG_ID';
 
IF g_record.INVOICE_TO_ORG_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.INVOICE_TO_ORG_ID := ONT_D1_INVOICE_TO_ORG_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.invoice_to_org_id, p_in_old_rec.invoice_to_org_id) THEN
      IF OE_HEADER_SECURITY.INVOICE_TO_ORG(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.INVOICE_TO_ORG_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.INVOICE_TO_ORG(g_record.INVOICE_TO_ORG_ID) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.INVOICE_TO_ORG(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.INVOICE_TO_ORG_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'PRICE_LIST_ID';
 
IF g_record.PRICE_LIST_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.PRICE_LIST_ID := ONT_D1_PRICE_LIST_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  IF g_record.PRICE_LIST_ID IS NULL 
   AND p_in_old_rec.PRICE_LIST_ID <> FND_API.G_MISS_NUM THEN 
  g_record.PRICE_LIST_ID := p_in_old_rec.PRICE_LIST_ID;
  END IF;
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.price_list_id, p_in_old_rec.price_list_id) THEN
      IF OE_HEADER_SECURITY.PRICE_LIST(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.PRICE_LIST_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.PRICE_LIST(g_record.PRICE_LIST_ID) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.PRICE_LIST(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.PRICE_LIST_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'PAYMENT_TYPE_CODE';
 
IF g_record.PAYMENT_TYPE_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PAYMENT_TYPE_CODE := NULL;
END IF;
l_attr:= 'REQUEST_DATE';
 
IF g_record.REQUEST_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.REQUEST_DATE := ONT_D1_REQUEST_DATE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.request_date, p_in_old_rec.request_date) THEN
      IF OE_HEADER_SECURITY.REQUEST_DATE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.REQUEST_DATE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.REQUEST_DATE(g_record.REQUEST_DATE) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.REQUEST_DATE(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.REQUEST_DATE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'CREDIT_CARD_NUMBER';
 
IF g_record.CREDIT_CARD_NUMBER = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CREDIT_CARD_NUMBER := ONT_D1_CREDIT_CARD_NUMBER.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'ACCOUNTING_RULE_ID';
 
IF g_record.ACCOUNTING_RULE_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.ACCOUNTING_RULE_ID := ONT_D1_ACCOUNTING_RULE_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.accounting_rule_id, p_in_old_rec.accounting_rule_id) THEN
      IF OE_HEADER_SECURITY.ACCOUNTING_RULE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.ACCOUNTING_RULE_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.ACCOUNTING_RULE(g_record.ACCOUNTING_RULE_ID) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.ACCOUNTING_RULE_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'ACCOUNTING_RULE_DURATION';
 
IF g_record.ACCOUNTING_RULE_DURATION = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.ACCOUNTING_RULE_DURATION := ONT_D1_ACCOUNTING_RULE_DURA.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.accounting_rule_duration, p_in_old_rec.accounting_rule_duration) THEN
      IF OE_HEADER_SECURITY.ACCOUNTING_RULE_DURATION(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.ACCOUNTING_RULE_DURATION IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.ACCOUNTING_RULE_DURATION(g_record.ACCOUNTING_RULE_DURATION) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.ACCOUNTING_RULE_DURATION(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.ACCOUNTING_RULE_DURATION := NULL;
      l_attr:=l_attr||' 6';
    END IF;
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
l_attr:= 'ATTRIBUTE16';
 
IF g_record.ATTRIBUTE16 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE16 := NULL;
END IF;
l_attr:= 'ATTRIBUTE17';
 
IF g_record.ATTRIBUTE17 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE17 := NULL;
END IF;
l_attr:= 'ATTRIBUTE18';
 
IF g_record.ATTRIBUTE18 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE18 := NULL;
END IF;
l_attr:= 'ATTRIBUTE19';
 
IF g_record.ATTRIBUTE19 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE19 := NULL;
END IF;
l_attr:= 'ATTRIBUTE2';
 
IF g_record.ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE2 := NULL;
END IF;
l_attr:= 'ATTRIBUTE20';
 
IF g_record.ATTRIBUTE20 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATTRIBUTE20 := NULL;
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
l_attr:= 'INVOICE_TO_CONTACT_ID';
 
IF g_record.INVOICE_TO_CONTACT_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.INVOICE_TO_CONTACT_ID := ONT_D1_INVOICE_TO_CONTACT_I.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.invoice_to_contact_id, p_in_old_rec.invoice_to_contact_id) THEN
      IF OE_HEADER_SECURITY.INVOICE_TO_CONTACT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.INVOICE_TO_CONTACT_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.INVOICE_TO_CONTACT(g_record.INVOICE_TO_CONTACT_ID) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.INVOICE_TO_CONTACT(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.INVOICE_TO_CONTACT_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'BOOKED_FLAG';
 
IF g_record.BOOKED_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.BOOKED_FLAG := NULL;
END IF;
l_attr:= 'BOOKED_DATE';
 
IF g_record.BOOKED_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.BOOKED_DATE := NULL;
END IF;
l_attr:= 'CANCELLED_FLAG';
 
IF g_record.CANCELLED_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CANCELLED_FLAG := NULL;
END IF;
l_attr:= 'CHANGE_COMMENTS';
 
IF g_record.CHANGE_COMMENTS = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CHANGE_COMMENTS := NULL;
END IF;
l_attr:= 'CHANGE_REASON';
 
IF g_record.CHANGE_REASON = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CHANGE_REASON := NULL;
END IF;
l_attr:= 'CHECK_NUMBER';
 
IF g_record.CHECK_NUMBER = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CHECK_NUMBER := NULL;
END IF;
l_attr:= 'SOLD_TO_CONTACT_ID';
 
IF g_record.SOLD_TO_CONTACT_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SOLD_TO_CONTACT_ID := ONT_D1_SOLD_TO_CONTACT_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.sold_to_contact_id, p_in_old_rec.sold_to_contact_id) THEN
      IF OE_HEADER_SECURITY.SOLD_TO_CONTACT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SOLD_TO_CONTACT_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SOLD_TO_CONTACT(g_record.SOLD_TO_CONTACT_ID) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.SOLD_TO_CONTACT(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.SOLD_TO_CONTACT_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'CONTEXT';
 
IF g_record.CONTEXT = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CONTEXT := NULL;
END IF;
l_attr:= 'CONTRACT_TERMS';
 
IF g_record.CONTRACT_TERMS = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CONTRACT_TERMS := NULL;
END IF;
l_attr:= 'CONVERSION_RATE';
 
IF g_record.CONVERSION_RATE = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CONVERSION_RATE := NULL;
END IF;
l_attr:= 'CONVERSION_RATE_DATE';
 
IF g_record.CONVERSION_RATE_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CONVERSION_RATE_DATE := ONT_D1_CONVERSION_RATE_DATE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.conversion_rate_date, p_in_old_rec.conversion_rate_date) THEN
      IF OE_HEADER_SECURITY.CONVERSION_RATE_DATE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.CONVERSION_RATE_DATE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.CONVERSION_RATE_DATE(g_record.CONVERSION_RATE_DATE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.CONVERSION_RATE_DATE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'CONVERSION_TYPE_CODE';
 
IF g_record.CONVERSION_TYPE_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CONVERSION_TYPE_CODE := ONT_D1_CONVERSION_TYPE_CODE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.conversion_type_code, p_in_old_rec.conversion_type_code) THEN
      IF OE_HEADER_SECURITY.CONVERSION_TYPE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.CONVERSION_TYPE_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.CONVERSION_TYPE(g_record.CONVERSION_TYPE_CODE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.CONVERSION_TYPE_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
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
l_attr:= 'CREDIT_CARD_EXPIRATION_DATE';
 
IF g_record.CREDIT_CARD_EXPIRATION_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CREDIT_CARD_EXPIRATION_DATE := ONT_D1_CREDIT_CARD_EXPIRATI.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'CREDIT_CARD_HOLDER_NAME';
 
IF g_record.CREDIT_CARD_HOLDER_NAME = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CREDIT_CARD_HOLDER_NAME := ONT_D1_CREDIT_CARD_HOLDER_N.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'TRANSACTIONAL_CURR_CODE';
 
IF g_record.TRANSACTIONAL_CURR_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.TRANSACTIONAL_CURR_CODE := ONT_D1_TRANSACTIONAL_CURR_C.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.transactional_curr_code, p_in_old_rec.transactional_curr_code) THEN
      IF OE_HEADER_SECURITY.TRANSACTIONAL_CURR(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.TRANSACTIONAL_CURR_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.TRANSACTIONAL_CURR(g_record.TRANSACTIONAL_CURR_CODE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.TRANSACTIONAL_CURR_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'IB_CURRENT_LOCATION';
 
IF g_record.IB_CURRENT_LOCATION = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.IB_CURRENT_LOCATION := ONT_D1_IB_CURRENT_LOCATION.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ib_current_location, p_in_old_rec.ib_current_location) THEN
      IF OE_HEADER_SECURITY.IB_CURRENT_LOCATION(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.IB_CURRENT_LOCATION IS NOT NULL THEN
    l_attr:=l_attr||' 4';
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.IB_CURRENT_LOCATION(p_initial_rec, p_in_old_rec, g_record);
  END IF;
END IF;
l_attr:= 'SOLD_TO_SITE_USE_ID';
 
IF g_record.SOLD_TO_SITE_USE_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SOLD_TO_SITE_USE_ID := ONT_D1_SOLD_TO_SITE_USE_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.sold_to_site_use_id, p_in_old_rec.sold_to_site_use_id) THEN
      IF OE_HEADER_SECURITY.SOLD_TO_SITE_USE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'CUST_PO_NUMBER';
 
IF g_record.CUST_PO_NUMBER = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CUST_PO_NUMBER := ONT_D1_CUST_PO_NUMBER.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  IF g_record.CUST_PO_NUMBER IS NULL 
   AND p_in_old_rec.CUST_PO_NUMBER <> FND_API.G_MISS_CHAR THEN 
  g_record.CUST_PO_NUMBER := p_in_old_rec.CUST_PO_NUMBER;
  END IF;
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.cust_po_number, p_in_old_rec.cust_po_number) THEN
      IF OE_HEADER_SECURITY.CUST_PO_NUMBER(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.CUST_PO_NUMBER IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.CUST_PO_NUMBER(g_record.CUST_PO_NUMBER) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.CUST_PO_NUMBER := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'CUSTOMER_SIGNATURE';
 
IF g_record.CUSTOMER_SIGNATURE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CUSTOMER_SIGNATURE := NULL;
END IF;
l_attr:= 'CUSTOMER_SIGNATURE_DATE';
 
IF g_record.CUSTOMER_SIGNATURE_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CUSTOMER_SIGNATURE_DATE := NULL;
END IF;
l_attr:= 'DB_FLAG';
 
IF g_record.DB_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.DB_FLAG := NULL;
END IF;
l_attr:= 'DEFAULT_INBOUND_LINE_TYPE_ID';
 
IF g_record.DEFAULT_INBOUND_LINE_TYPE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.DEFAULT_INBOUND_LINE_TYPE_ID := NULL;
END IF;
l_attr:= 'DEFAULT_OUTBOUND_LINE_TYPE_ID';
 
IF g_record.DEFAULT_OUTBOUND_LINE_TYPE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.DEFAULT_OUTBOUND_LINE_TYPE_ID := NULL;
END IF;
l_attr:= 'DELIVER_TO_CONTACT_ID';
 
IF g_record.DELIVER_TO_CONTACT_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.DELIVER_TO_CONTACT_ID := ONT_D1_DELIVER_TO_CONTACT_I.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.deliver_to_contact_id, p_in_old_rec.deliver_to_contact_id) THEN
      IF OE_HEADER_SECURITY.DELIVER_TO_CONTACT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.DELIVER_TO_CONTACT_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.DELIVER_TO_CONTACT(g_record.DELIVER_TO_CONTACT_ID) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.DELIVER_TO_CONTACT(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.DELIVER_TO_CONTACT_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'DEMAND_CLASS_CODE';
 
IF g_record.DEMAND_CLASS_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.DEMAND_CLASS_CODE := ONT_D1_DEMAND_CLASS_CODE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.demand_class_code, p_in_old_rec.demand_class_code) THEN
      IF OE_HEADER_SECURITY.DEMAND_CLASS(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.DEMAND_CLASS_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.DEMAND_CLASS(g_record.DEMAND_CLASS_CODE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.DEMAND_CLASS_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'DRAFT_SUBMITTED_FLAG';
 
IF g_record.DRAFT_SUBMITTED_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.DRAFT_SUBMITTED_FLAG := NULL;
END IF;
l_attr:= 'EARLIEST_SCHEDULE_LIMIT';
 
IF g_record.EARLIEST_SCHEDULE_LIMIT = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.EARLIEST_SCHEDULE_LIMIT := ONT_D1_EARLIEST_SCHEDULE_LI.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
  IF g_record.EARLIEST_SCHEDULE_LIMIT IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.EARLIEST_SCHEDULE_LIMIT(g_record.EARLIEST_SCHEDULE_LIMIT) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.EARLIEST_SCHEDULE_LIMIT := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'END_CUSTOMER_ID';
 
IF g_record.END_CUSTOMER_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.END_CUSTOMER_ID := ONT_D1_END_CUSTOMER_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.end_customer_id, p_in_old_rec.end_customer_id) THEN
      IF OE_HEADER_SECURITY.END_CUSTOMER(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.END_CUSTOMER_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.END_CUSTOMER(p_initial_rec, p_in_old_rec, g_record);
  END IF;
END IF;
l_attr:= 'END_CUSTOMER_CONTACT_ID';
 
IF g_record.END_CUSTOMER_CONTACT_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.END_CUSTOMER_CONTACT_ID := ONT_D1_END_CUSTOMER_CONTACT.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.end_customer_contact_id, p_in_old_rec.end_customer_contact_id) THEN
      IF OE_HEADER_SECURITY.END_CUSTOMER_CONTACT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.END_CUSTOMER_CONTACT_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.END_CUSTOMER_CONTACT(p_initial_rec, p_in_old_rec, g_record);
  END IF;
END IF;
l_attr:= 'END_CUSTOMER_SITE_USE_ID';
 
IF g_record.END_CUSTOMER_SITE_USE_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.END_CUSTOMER_SITE_USE_ID := ONT_D1_END_CUSTOMER_SITE_US.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.end_customer_site_use_id, p_in_old_rec.end_customer_site_use_id) THEN
      IF OE_HEADER_SECURITY.END_CUSTOMER_SITE_USE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.END_CUSTOMER_SITE_USE_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.END_CUSTOMER_SITE_USE(p_initial_rec, p_in_old_rec, g_record);
  END IF;
END IF;
l_attr:= 'EXPIRATION_DATE';
 
IF g_record.EXPIRATION_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.EXPIRATION_DATE := ONT_D1_EXPIRATION_DATE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.expiration_date, p_in_old_rec.expiration_date) THEN
      IF OE_HEADER_SECURITY.EXPIRATION_DATE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.EXPIRATION_DATE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.EXPIRATION_DATE(g_record.EXPIRATION_DATE) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.EXPIRATION_DATE(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.EXPIRATION_DATE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'FOB_POINT_CODE';
 
IF g_record.FOB_POINT_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.FOB_POINT_CODE := ONT_D1_FOB_POINT_CODE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.fob_point_code, p_in_old_rec.fob_point_code) THEN
      IF OE_HEADER_SECURITY.FOB_POINT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.FOB_POINT_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.FOB_POINT(g_record.FOB_POINT_CODE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.FOB_POINT_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'FIRST_ACK_CODE';
 
IF g_record.FIRST_ACK_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.FIRST_ACK_CODE := NULL;
END IF;
l_attr:= 'FIRST_ACK_DATE';
 
IF g_record.FIRST_ACK_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.FIRST_ACK_DATE := NULL;
END IF;
l_attr:= 'FREIGHT_CARRIER_CODE';
 
IF g_record.FREIGHT_CARRIER_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.FREIGHT_CARRIER_CODE := NULL;
END IF;
l_attr:= 'FREIGHT_TERMS_CODE';
 
IF g_record.FREIGHT_TERMS_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.FREIGHT_TERMS_CODE := ONT_D1_FREIGHT_TERMS_CODE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.freight_terms_code, p_in_old_rec.freight_terms_code) THEN
      IF OE_HEADER_SECURITY.FREIGHT_TERMS(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.FREIGHT_TERMS_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.FREIGHT_TERMS(g_record.FREIGHT_TERMS_CODE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.FREIGHT_TERMS_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'DEFAULT_FULFILLMENT_SET';
 
IF g_record.DEFAULT_FULFILLMENT_SET = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.DEFAULT_FULFILLMENT_SET := ONT_D1_DEFAULT_FULFILLMENT.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
  IF g_record.DEFAULT_FULFILLMENT_SET IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.DEFAULT_FULFILLMENT_SET(g_record.DEFAULT_FULFILLMENT_SET) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.DEFAULT_FULFILLMENT_SET(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.DEFAULT_FULFILLMENT_SET := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE_CATEGORY';
 
IF g_record.GLOBAL_ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE_CATEGORY := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE1';
 
IF g_record.GLOBAL_ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE1 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE10';
 
IF g_record.GLOBAL_ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE10 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE11';
 
IF g_record.GLOBAL_ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE11 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE12';
 
IF g_record.GLOBAL_ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE12 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE13';
 
IF g_record.GLOBAL_ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE13 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE14';
 
IF g_record.GLOBAL_ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE14 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE15';
 
IF g_record.GLOBAL_ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE15 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE16';
 
IF g_record.GLOBAL_ATTRIBUTE16 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE16 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE17';
 
IF g_record.GLOBAL_ATTRIBUTE17 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE17 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE18';
 
IF g_record.GLOBAL_ATTRIBUTE18 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE18 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE19';
 
IF g_record.GLOBAL_ATTRIBUTE19 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE19 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE2';
 
IF g_record.GLOBAL_ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE2 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE20';
 
IF g_record.GLOBAL_ATTRIBUTE20 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE20 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE3';
 
IF g_record.GLOBAL_ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE3 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE4';
 
IF g_record.GLOBAL_ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE4 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE5';
 
IF g_record.GLOBAL_ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE5 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE6';
 
IF g_record.GLOBAL_ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE6 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE7';
 
IF g_record.GLOBAL_ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE7 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE8';
 
IF g_record.GLOBAL_ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE8 := NULL;
END IF;
l_attr:= 'GLOBAL_ATTRIBUTE9';
 
IF g_record.GLOBAL_ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.GLOBAL_ATTRIBUTE9 := NULL;
END IF;
l_attr:= 'HEADER_ID';
 
IF g_record.HEADER_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.HEADER_ID := NULL;
END IF;
l_attr:= 'IB_INSTALLED_AT_LOCATION';
 
IF g_record.IB_INSTALLED_AT_LOCATION = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.IB_INSTALLED_AT_LOCATION := ONT_D1_IB_INSTALLED_AT_LOCA.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ib_installed_at_location, p_in_old_rec.ib_installed_at_location) THEN
      IF OE_HEADER_SECURITY.IB_INSTALLED_AT_LOCATION(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.IB_INSTALLED_AT_LOCATION IS NOT NULL THEN
    l_attr:=l_attr||' 4';
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.IB_INSTALLED_AT_LOCATION(p_initial_rec, p_in_old_rec, g_record);
  END IF;
END IF;
l_attr:= 'INVOICING_RULE_ID';
 
IF g_record.INVOICING_RULE_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.INVOICING_RULE_ID := ONT_D1_INVOICING_RULE_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.invoicing_rule_id, p_in_old_rec.invoicing_rule_id) THEN
      IF OE_HEADER_SECURITY.INVOICING_RULE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.INVOICING_RULE_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.INVOICING_RULE(g_record.INVOICING_RULE_ID) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.INVOICING_RULE_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'LAST_ACK_CODE';
 
IF g_record.LAST_ACK_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.LAST_ACK_CODE := NULL;
END IF;
l_attr:= 'LAST_ACK_DATE';
 
IF g_record.LAST_ACK_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.LAST_ACK_DATE := NULL;
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
l_attr:= 'LATEST_SCHEDULE_LIMIT';
 
IF g_record.LATEST_SCHEDULE_LIMIT = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.LATEST_SCHEDULE_LIMIT := ONT_D1_LATEST_SCHEDULE_LIMI.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
  IF g_record.LATEST_SCHEDULE_LIMIT IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.LATEST_SCHEDULE_LIMIT(g_record.LATEST_SCHEDULE_LIMIT) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.LATEST_SCHEDULE_LIMIT := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'DEFAULT_LINE_SET';
 
IF g_record.CUSTOMER_PREFERENCE_SET_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CUSTOMER_PREFERENCE_SET_CODE := ONT_D1_DEFAULT_LINE_SET.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
  IF g_record.CUSTOMER_PREFERENCE_SET_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.CUSTOMER_PREFERENCE_SET(g_record.CUSTOMER_PREFERENCE_SET_CODE) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.CUSTOMER_PREFERENCE_SET(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.CUSTOMER_PREFERENCE_SET_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SALES_DOCUMENT_NAME';
 
IF g_record.SALES_DOCUMENT_NAME = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SALES_DOCUMENT_NAME := NULL;
END IF;
l_attr:= 'OPEN_FLAG';
 
IF g_record.OPEN_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.OPEN_FLAG := NULL;
END IF;
l_attr:= 'OPERATION';
 
IF g_record.OPERATION = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.OPERATION := NULL;
END IF;
l_attr:= 'ORDER_CATEGORY_CODE';
 
IF g_record.ORDER_CATEGORY_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ORDER_CATEGORY_CODE := NULL;
END IF;
l_attr:= 'ORDER_DATE_TYPE_CODE';
 
IF g_record.ORDER_DATE_TYPE_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.ORDER_DATE_TYPE_CODE := ONT_D1_ORDER_DATE_TYPE_CODE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
  IF g_record.ORDER_DATE_TYPE_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.ORDER_DATE_TYPE_CODE(g_record.ORDER_DATE_TYPE_CODE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.ORDER_DATE_TYPE_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'ORDER_FIRMED_DATE';
 
IF g_record.ORDER_FIRMED_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.ORDER_FIRMED_DATE := ONT_D1_ORDER_FIRMED_DATE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'ORDER_NUMBER';
 
IF g_record.ORDER_NUMBER = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ORDER_NUMBER := NULL;
END IF;
l_attr:= 'ORDER_SOURCE_ID';
 
IF g_record.ORDER_SOURCE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ORDER_SOURCE_ID := NULL;
END IF;
l_attr:= 'ORDER_TYPE_ID';
 
IF g_record.ORDER_TYPE_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.ORDER_TYPE_ID := ONT_D1_ORDER_TYPE_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  IF g_record.ORDER_TYPE_ID IS NULL 
   AND p_in_old_rec.ORDER_TYPE_ID <> FND_API.G_MISS_NUM THEN 
  g_record.ORDER_TYPE_ID := p_in_old_rec.ORDER_TYPE_ID;
  END IF;
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.order_type_id, p_in_old_rec.order_type_id) THEN
      IF OE_HEADER_SECURITY.ORDER_TYPE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.ORDER_TYPE_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.ORDER_TYPE(g_record.ORDER_TYPE_ID) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.ORDER_TYPE(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.ORDER_TYPE_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'ORDERED_DATE';
 
IF g_record.ORDERED_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.ORDERED_DATE := ONT_D1_ORDERED_DATE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ordered_date, p_in_old_rec.ordered_date) THEN
      IF OE_HEADER_SECURITY.ORDERED_DATE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.ORDERED_DATE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.ORDERED_DATE(g_record.ORDERED_DATE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.ORDERED_DATE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'ORG_ID';
 
IF g_record.ORG_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ORG_ID := NULL;
END IF;
l_attr:= 'ORIG_SYS_DOCUMENT_REF';
 
IF g_record.ORIG_SYS_DOCUMENT_REF = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ORIG_SYS_DOCUMENT_REF := NULL;
END IF;
l_attr:= 'IB_OWNER';
 
IF g_record.IB_OWNER = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.IB_OWNER := ONT_D1_IB_OWNER.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ib_owner, p_in_old_rec.ib_owner) THEN
      IF OE_HEADER_SECURITY.IB_OWNER(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.IB_OWNER IS NOT NULL THEN
    l_attr:=l_attr||' 4';
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.IB_OWNER(p_initial_rec, p_in_old_rec, g_record);
  END IF;
END IF;
l_attr:= 'PACKING_INSTRUCTIONS';
 
IF g_record.PACKING_INSTRUCTIONS = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.PACKING_INSTRUCTIONS := ONT_D1_PACKING_INSTRUCTIONS.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
  IF g_record.PACKING_INSTRUCTIONS IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.PACKING_INSTRUCTIONS(g_record.PACKING_INSTRUCTIONS) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.PACKING_INSTRUCTIONS := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'PARTIAL_SHIPMENTS_ALLOWED';
 
IF g_record.PARTIAL_SHIPMENTS_ALLOWED = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PARTIAL_SHIPMENTS_ALLOWED := NULL;
END IF;
l_attr:= 'PARTY_TYPE';
 
IF g_record.PARTY_TYPE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PARTY_TYPE := NULL;
END IF;
l_attr:= 'PAYMENT_AMOUNT';
 
IF g_record.PAYMENT_AMOUNT = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PAYMENT_AMOUNT := NULL;
END IF;
l_attr:= 'PAYMENT_TERM_ID';
 
IF g_record.PAYMENT_TERM_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.PAYMENT_TERM_ID := ONT_D1_PAYMENT_TERM_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.payment_term_id, p_in_old_rec.payment_term_id) THEN
      IF OE_HEADER_SECURITY.PAYMENT_TERM(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.PAYMENT_TERM_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.PAYMENT_TERM(g_record.PAYMENT_TERM_ID) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.PAYMENT_TERM_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'PRICING_DATE';
 
IF g_record.PRICING_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.PRICING_DATE := ONT_D1_PRICING_DATE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.pricing_date, p_in_old_rec.pricing_date) THEN
      IF OE_HEADER_SECURITY.PRICING_DATE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.PRICING_DATE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.PRICING_DATE(g_record.PRICING_DATE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.PRICING_DATE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
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
l_attr:= 'QUOTE_DATE';
 
IF g_record.QUOTE_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.QUOTE_DATE := ONT_D1_QUOTE_DATE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.quote_date, p_in_old_rec.quote_date) THEN
      IF OE_HEADER_SECURITY.QUOTE_DATE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'QUOTE_NUMBER';
 
IF g_record.QUOTE_NUMBER = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.QUOTE_NUMBER := NULL;
END IF;
l_attr:= 'REQUEST_ID';
 
IF g_record.REQUEST_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.REQUEST_ID := NULL;
END IF;
l_attr:= 'RETURN_REASON_CODE';
 
IF g_record.RETURN_REASON_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_REASON_CODE := NULL;
END IF;
l_attr:= 'RETURN_STATUS';
 
IF g_record.RETURN_STATUS = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_STATUS := NULL;
END IF;
l_attr:= 'BLANKET_NUMBER';
 
IF g_record.BLANKET_NUMBER = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.BLANKET_NUMBER := ONT_D1_BLANKET_NUMBER.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.blanket_number, p_in_old_rec.blanket_number) THEN
      IF OE_HEADER_SECURITY.BLANKET_NUMBER(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.BLANKET_NUMBER IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.Blanket_Number(g_record.BLANKET_NUMBER) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.BLANKET_NUMBER(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.BLANKET_NUMBER := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SALES_CHANNEL_CODE';
 
IF g_record.SALES_CHANNEL_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SALES_CHANNEL_CODE := ONT_D1_SALES_CHANNEL_CODE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.sales_channel_code, p_in_old_rec.sales_channel_code) THEN
      IF OE_HEADER_SECURITY.SALES_CHANNEL_CODE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SALES_CHANNEL_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SALES_CHANNEL(g_record.SALES_CHANNEL_CODE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SALES_CHANNEL_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SALESREP_ID';
 
IF g_record.SALESREP_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SALESREP_ID := ONT_D1_SALESREP_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  IF g_record.SALESREP_ID IS NULL 
   AND p_in_old_rec.SALESREP_ID <> FND_API.G_MISS_NUM THEN 
  g_record.SALESREP_ID := p_in_old_rec.SALESREP_ID;
  END IF;
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.salesrep_id, p_in_old_rec.salesrep_id) THEN
      IF OE_HEADER_SECURITY.SALESREP(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SALESREP_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SALESREP(g_record.SALESREP_ID) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SALESREP_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SOLD_FROM_ORG_ID';
 
IF g_record.SOLD_FROM_ORG_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SOLD_FROM_ORG_ID := NULL;
END IF;
l_attr:= 'SHIP_TO_CONTACT_ID';
 
IF g_record.SHIP_TO_CONTACT_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SHIP_TO_CONTACT_ID := ONT_D1_SHIP_TO_CONTACT_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ship_to_contact_id, p_in_old_rec.ship_to_contact_id) THEN
      IF OE_HEADER_SECURITY.SHIP_TO_CONTACT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SHIP_TO_CONTACT_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SHIP_TO_CONTACT(g_record.SHIP_TO_CONTACT_ID) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.SHIP_TO_CONTACT(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.SHIP_TO_CONTACT_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SHIP_TOLERANCE_ABOVE';
 
IF g_record.SHIP_TOLERANCE_ABOVE = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SHIP_TOLERANCE_ABOVE := ONT_D1_SHIP_TOLERANCE_ABOVE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ship_tolerance_above, p_in_old_rec.ship_tolerance_above) THEN
      IF OE_HEADER_SECURITY.SHIP_TOLERANCE_ABOVE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SHIP_TOLERANCE_ABOVE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SHIP_TOLERANCE_ABOVE(g_record.SHIP_TOLERANCE_ABOVE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SHIP_TOLERANCE_ABOVE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SHIP_TOLERANCE_BELOW';
 
IF g_record.SHIP_TOLERANCE_BELOW = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SHIP_TOLERANCE_BELOW := ONT_D1_SHIP_TOLERANCE_BELOW.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ship_tolerance_below, p_in_old_rec.ship_tolerance_below) THEN
      IF OE_HEADER_SECURITY.SHIP_TOLERANCE_BELOW(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SHIP_TOLERANCE_BELOW IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SHIP_TOLERANCE_BELOW(g_record.SHIP_TOLERANCE_BELOW) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SHIP_TOLERANCE_BELOW := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SHIPMENT_PRIORITY_CODE';
 
IF g_record.SHIPMENT_PRIORITY_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SHIPMENT_PRIORITY_CODE := ONT_D1_SHIPMENT_PRIORITY_CO.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.shipment_priority_code, p_in_old_rec.shipment_priority_code) THEN
      IF OE_HEADER_SECURITY.SHIPMENT_PRIORITY(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SHIPMENT_PRIORITY_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SHIPMENT_PRIORITY(g_record.SHIPMENT_PRIORITY_CODE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SHIPMENT_PRIORITY_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SHIPPING_INSTRUCTIONS';
 
IF g_record.SHIPPING_INSTRUCTIONS = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SHIPPING_INSTRUCTIONS := ONT_D1_SHIPPING_INSTRUCTION.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
  IF g_record.SHIPPING_INSTRUCTIONS IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SHIPPING_INSTRUCTIONS(g_record.SHIPPING_INSTRUCTIONS) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SHIPPING_INSTRUCTIONS := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SHIPPING_METHOD_CODE';
 
IF g_record.SHIPPING_METHOD_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SHIPPING_METHOD_CODE := ONT_D1_SHIPPING_METHOD_CODE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
  IF g_record.SHIPPING_METHOD_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SHIPPING_METHOD(g_record.SHIPPING_METHOD_CODE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SHIPPING_METHOD_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SOURCE_DOCUMENT_ID';
 
IF g_record.SOURCE_DOCUMENT_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SOURCE_DOCUMENT_ID := NULL;
END IF;
l_attr:= 'SOURCE_DOCUMENT_TYPE_ID';
 
IF g_record.SOURCE_DOCUMENT_TYPE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SOURCE_DOCUMENT_TYPE_ID := NULL;
END IF;
l_attr:= 'SOURCE_DOCUMENT_VERSION_NUMBER';
 
IF g_record.SOURCE_DOCUMENT_VERSION_NUMBER = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SOURCE_DOCUMENT_VERSION_NUMBER := NULL;
END IF;
l_attr:= 'FLOW_STATUS_CODE';
 
IF g_record.FLOW_STATUS_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.FLOW_STATUS_CODE := NULL;
END IF;
l_attr:= 'SUPPLIER_SIGNATURE';
 
IF g_record.SUPPLIER_SIGNATURE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SUPPLIER_SIGNATURE := NULL;
END IF;
l_attr:= 'SUPPLIER_SIGNATURE_DATE';
 
IF g_record.SUPPLIER_SIGNATURE_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SUPPLIER_SIGNATURE_DATE := NULL;
END IF;
l_attr:= 'TAX_EXEMPT_FLAG';
 
IF g_record.TAX_EXEMPT_FLAG = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.TAX_EXEMPT_FLAG := ONT_D1_TAX_EXEMPT_FLAG.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.tax_exempt_flag, p_in_old_rec.tax_exempt_flag) THEN
      IF OE_HEADER_SECURITY.TAX_EXEMPT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.TAX_EXEMPT_FLAG IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.TAX_EXEMPT(g_record.TAX_EXEMPT_FLAG) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.TAX_EXEMPT(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.TAX_EXEMPT_FLAG := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'TAX_EXEMPT_NUMBER';
 
IF g_record.TAX_EXEMPT_NUMBER = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.TAX_EXEMPT_NUMBER := ONT_D1_TAX_EXEMPT_NUMBER.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.tax_exempt_number, p_in_old_rec.tax_exempt_number) THEN
      IF OE_HEADER_SECURITY.TAX_EXEMPT_NUMBER(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.TAX_EXEMPT_NUMBER IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.TAX_EXEMPT_NUMBER(g_record.TAX_EXEMPT_NUMBER) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.TAX_EXEMPT_NUMBER := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'TAX_EXEMPT_REASON_CODE';
 
IF g_record.TAX_EXEMPT_REASON_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.TAX_EXEMPT_REASON_CODE := ONT_D1_TAX_EXEMPT_REASON_CO.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.tax_exempt_reason_code, p_in_old_rec.tax_exempt_reason_code) THEN
      IF OE_HEADER_SECURITY.TAX_EXEMPT_REASON(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.TAX_EXEMPT_REASON_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.TAX_EXEMPT_REASON(g_record.TAX_EXEMPT_REASON_CODE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.TAX_EXEMPT_REASON_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'TAX_POINT_CODE';
 
IF g_record.TAX_POINT_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.TAX_POINT_CODE := NULL;
END IF;
l_attr:= 'TRANSACTION_PHASE_CODE';
 
IF g_record.TRANSACTION_PHASE_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.TRANSACTION_PHASE_CODE := ONT_D1_TRANSACTION_PHASE_CO.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  IF g_record.TRANSACTION_PHASE_CODE IS NULL 
   AND p_in_old_rec.TRANSACTION_PHASE_CODE <> FND_API.G_MISS_CHAR THEN 
  g_record.TRANSACTION_PHASE_CODE := p_in_old_rec.TRANSACTION_PHASE_CODE;
  END IF;
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.transaction_phase_code, p_in_old_rec.transaction_phase_code) THEN
      IF OE_HEADER_SECURITY.TRANSACTION_PHASE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.TRANSACTION_PHASE_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.TRANSACTION_PHASE(g_record.TRANSACTION_PHASE_CODE) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.TRANSACTION_PHASE(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.TRANSACTION_PHASE_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'UPGRADED_FLAG';
 
IF g_record.UPGRADED_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.UPGRADED_FLAG := NULL;
END IF;
l_attr:= 'USER_STATUS_CODE';
 
IF g_record.USER_STATUS_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.USER_STATUS_CODE := NULL;
END IF;
l_attr:= 'VERSION_NUMBER';
 
IF g_record.VERSION_NUMBER = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.VERSION_NUMBER := NULL;
END IF;
l_attr:= 'SHIP_FROM_ORG_ID';
 
IF g_record.SHIP_FROM_ORG_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SHIP_FROM_ORG_ID := ONT_D1_SHIP_FROM_ORG_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ship_from_org_id, p_in_old_rec.ship_from_org_id) THEN
      IF OE_HEADER_SECURITY.SHIP_FROM_ORG(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SHIP_FROM_ORG_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SHIP_FROM_ORG(g_record.SHIP_FROM_ORG_ID) THEN  
      -- if valid, clear dependent attributes
      OE_HEADER_CL_DEP_ATTR.SHIP_FROM_ORG(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.SHIP_FROM_ORG_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
 
    --  CHeck if there are any missing values for attrs
    --  If there are any missing call Default_Record again AND repeat till all the values 
    --  are defaulted or till the max. iterations are reached
 
     IF( 
      (g_record.SOLD_TO_ORG_ID =FND_API.G_MISS_NUM)  
     OR (g_record.SHIP_TO_ORG_ID = FND_API.G_MISS_NUM)  
     OR (g_record.DELIVER_TO_ORG_ID = FND_API.G_MISS_NUM)  
     OR (g_record.AGREEMENT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.INVOICE_TO_ORG_ID = FND_API.G_MISS_NUM)  
     OR (g_record.PRICE_LIST_ID = FND_API.G_MISS_NUM)  
     OR (g_record.PAYMENT_TYPE_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.REQUEST_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.CREDIT_CARD_NUMBER = FND_API.G_MISS_CHAR)  
     OR (g_record.ACCOUNTING_RULE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.ACCOUNTING_RULE_DURATION = FND_API.G_MISS_NUM)  
     OR (g_record.ATTRIBUTE1 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE10 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE11 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE12 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE13 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE14 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE15 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE16 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE17 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE18 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE19 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE2 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE20 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE3 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE4 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE5 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE6 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE7 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE8 = FND_API.G_MISS_CHAR)  
     OR (g_record.ATTRIBUTE9 = FND_API.G_MISS_CHAR)  
     OR (g_record.INVOICE_TO_CONTACT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.BOOKED_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.BOOKED_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.CANCELLED_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.CHANGE_COMMENTS = FND_API.G_MISS_CHAR)  
     OR (g_record.CHANGE_REASON = FND_API.G_MISS_CHAR)  
     OR (g_record.CHECK_NUMBER = FND_API.G_MISS_CHAR)  
     OR (g_record.SOLD_TO_CONTACT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.CONTEXT = FND_API.G_MISS_CHAR)  
     OR (g_record.CONTRACT_TERMS = FND_API.G_MISS_NUM)  
     OR (g_record.CONVERSION_RATE = FND_API.G_MISS_NUM)  
     OR (g_record.CONVERSION_RATE_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.CONVERSION_TYPE_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.CREATED_BY = FND_API.G_MISS_NUM)  
     OR (g_record.CREATION_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.CREDIT_CARD_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.CREDIT_CARD_APPROVAL_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.CREDIT_CARD_EXPIRATION_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.CREDIT_CARD_HOLDER_NAME = FND_API.G_MISS_CHAR)  
     OR (g_record.TRANSACTIONAL_CURR_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.IB_CURRENT_LOCATION = FND_API.G_MISS_CHAR)  
     OR (g_record.SOLD_TO_SITE_USE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.CUST_PO_NUMBER = FND_API.G_MISS_CHAR)  
     OR (g_record.CUSTOMER_SIGNATURE = FND_API.G_MISS_CHAR)  
     OR (g_record.CUSTOMER_SIGNATURE_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.DB_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.DEFAULT_INBOUND_LINE_TYPE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.DEFAULT_OUTBOUND_LINE_TYPE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.DELIVER_TO_CONTACT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.DEMAND_CLASS_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.DRAFT_SUBMITTED_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.EARLIEST_SCHEDULE_LIMIT = FND_API.G_MISS_NUM)  
     OR (g_record.END_CUSTOMER_ID = FND_API.G_MISS_NUM)  
     OR (g_record.END_CUSTOMER_CONTACT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.END_CUSTOMER_SITE_USE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.EXPIRATION_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.FOB_POINT_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.FIRST_ACK_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.FIRST_ACK_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.FREIGHT_CARRIER_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.FREIGHT_TERMS_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.DEFAULT_FULFILLMENT_SET = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE1 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE10 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE11 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE12 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE13 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE14 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE15 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE16 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE17 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE18 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE19 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE2 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE20 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE3 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE4 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE5 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE6 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE7 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE8 = FND_API.G_MISS_CHAR)  
     OR (g_record.GLOBAL_ATTRIBUTE9 = FND_API.G_MISS_CHAR)  
     OR (g_record.HEADER_ID = FND_API.G_MISS_NUM)  
     OR (g_record.IB_INSTALLED_AT_LOCATION = FND_API.G_MISS_CHAR)  
     OR (g_record.INVOICING_RULE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.LAST_ACK_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.LAST_ACK_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.LAST_UPDATE_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.LAST_UPDATE_LOGIN = FND_API.G_MISS_NUM)  
     OR (g_record.LAST_UPDATED_BY = FND_API.G_MISS_NUM)  
     OR (g_record.LATEST_SCHEDULE_LIMIT = FND_API.G_MISS_NUM)  
     OR (g_record.CUSTOMER_PREFERENCE_SET_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.SALES_DOCUMENT_NAME = FND_API.G_MISS_CHAR)  
     OR (g_record.OPEN_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.OPERATION = FND_API.G_MISS_CHAR)  
     OR (g_record.ORDER_CATEGORY_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.ORDER_DATE_TYPE_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.ORDER_FIRMED_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.ORDER_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.ORDER_SOURCE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.ORDER_TYPE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.ORDERED_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.ORG_ID = FND_API.G_MISS_NUM)  
     OR (g_record.ORIG_SYS_DOCUMENT_REF = FND_API.G_MISS_CHAR)  
     OR (g_record.IB_OWNER = FND_API.G_MISS_CHAR)  
     OR (g_record.PACKING_INSTRUCTIONS = FND_API.G_MISS_CHAR)  
     OR (g_record.PARTIAL_SHIPMENTS_ALLOWED = FND_API.G_MISS_CHAR)  
     OR (g_record.PARTY_TYPE = FND_API.G_MISS_CHAR)  
     OR (g_record.PAYMENT_AMOUNT = FND_API.G_MISS_NUM)  
     OR (g_record.PAYMENT_TERM_ID = FND_API.G_MISS_NUM)  
     OR (g_record.PRICING_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.PROGRAM_ID = FND_API.G_MISS_NUM)  
     OR (g_record.PROGRAM_APPLICATION_ID = FND_API.G_MISS_NUM)  
     OR (g_record.PROGRAM_UPDATE_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.QUOTE_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.QUOTE_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.REQUEST_ID = FND_API.G_MISS_NUM)  
     OR (g_record.RETURN_REASON_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_STATUS = FND_API.G_MISS_CHAR)  
     OR (g_record.BLANKET_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.SALES_CHANNEL_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.SALESREP_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SOLD_FROM_ORG_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SHIP_TO_CONTACT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SHIP_TOLERANCE_ABOVE = FND_API.G_MISS_NUM)  
     OR (g_record.SHIP_TOLERANCE_BELOW = FND_API.G_MISS_NUM)  
     OR (g_record.SHIPMENT_PRIORITY_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.SHIPPING_INSTRUCTIONS = FND_API.G_MISS_CHAR)  
     OR (g_record.SHIPPING_METHOD_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.SOURCE_DOCUMENT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SOURCE_DOCUMENT_TYPE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SOURCE_DOCUMENT_VERSION_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.FLOW_STATUS_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.SUPPLIER_SIGNATURE = FND_API.G_MISS_CHAR)  
     OR (g_record.SUPPLIER_SIGNATURE_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.TAX_EXEMPT_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.TAX_EXEMPT_NUMBER = FND_API.G_MISS_CHAR)  
     OR (g_record.TAX_EXEMPT_REASON_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.TAX_POINT_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.TRANSACTION_PHASE_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.UPGRADED_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.USER_STATUS_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.VERSION_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.SHIP_FROM_ORG_ID = FND_API.G_MISS_NUM)  
    ) THEN   
    ONT_HEADER_Def_Hdlr.Default_Record(
     p_x_rec => g_record,
     p_initial_rec => p_initial_rec,
     p_in_old_rec => p_in_old_rec,
      p_iteration => p_iteration+1 );
    END IF;
 
IF p_iteration =1 THEN
OE_HEADER_Security.G_Is_Caller_Defaulting := 'N';
  p_x_rec := g_record;
END IF;
 
oe_debug_pub.ADD('Exit ONT_HEADER_Def_Hdlr.Default_Record');
 
EXCEPTION
 
  WHEN FND_API.G_EXC_ERROR THEN
    OE_HEADER_Security.G_Is_Caller_Defaulting := 'N';
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    OE_HEADER_Security.G_Is_Caller_Defaulting := 'N';
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      ,'Default_Record: '||l_attr
      );
    END IF;
    OE_HEADER_Security.G_Is_Caller_Defaulting := 'N';
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 
END Default_Record;
 
END ONT_HEADER_Def_Hdlr;

/
