--------------------------------------------------------
--  DDL for Package Body ONT_LINE_DEF_HDLR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_LINE_DEF_HDLR" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_LINE_Def_Hdlr
--  
--  DESCRIPTION
--  
--      Body of package ONT_LINE_Def_Hdlr
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_LINE_Def_Hdlr';
 
  g_entity_code  varchar2(15) := 'LINE';
  g_database_object_name varchar2(30) :='OE_AK_ORDER_LINES_V';
 
--  Default_Record
PROCEDURE Default_Record
  (   p_x_rec                         IN OUT NOCOPY  OE_AK_ORDER_LINES_V%ROWTYPE
,   p_initial_rec                   IN  OE_AK_ORDER_LINES_V%ROWTYPE 
,   p_in_old_rec                    IN  OE_AK_ORDER_LINES_V%ROWTYPE 
,   p_iteration                     IN  NUMBER default 1
)
IS
l_action  NUMBER;
l_attr  VARCHAR2(200);
BEGIN
 
oe_debug_pub.ADD('Enter ONT_LINE_Def_Hdlr.Default_Record');
 
IF p_iteration =1 THEN
OE_LINE_Security.G_Is_Caller_Defaulting := 'Y';
  g_record := p_x_rec;
END IF;
 
--  if max. iteration is reached exit
IF p_iteration > ONT_DEF_UTIL.G_MAX_DEF_ITERATIONS THEN
    FND_MESSAGE.SET_NAME('ONT','OE_DEF_MAX_ITERATIONS');
    OE_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
END IF;
 
--  Default missing attributes
l_attr:= 'LINE_TYPE_ID';
 
IF g_record.LINE_TYPE_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.LINE_TYPE_ID := ONT_D2_LINE_TYPE_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.line_type_id, p_in_old_rec.line_type_id) THEN
      IF OE_LINE_SECURITY.LINE_TYPE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.LINE_TYPE_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.LINE_TYPE(g_record.LINE_TYPE_ID) THEN  
      -- if valid, clear dependent attributes
      OE_LINE_CL_DEP_ATTR.LINE_TYPE(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.LINE_TYPE_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'AGREEMENT_ID';
 
IF g_record.AGREEMENT_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.AGREEMENT_ID := ONT_D2_AGREEMENT_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.agreement_id, p_in_old_rec.agreement_id) THEN
      IF OE_LINE_SECURITY.AGREEMENT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
      OE_LINE_CL_DEP_ATTR.AGREEMENT(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.AGREEMENT_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SOLD_TO_ORG_ID';
 
IF g_record.SOLD_TO_ORG_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SOLD_TO_ORG_ID := ONT_D2_SOLD_TO_ORG_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  IF g_record.SOLD_TO_ORG_ID IS NULL 
   AND p_in_old_rec.SOLD_TO_ORG_ID <> FND_API.G_MISS_NUM THEN 
  g_record.SOLD_TO_ORG_ID := p_in_old_rec.SOLD_TO_ORG_ID;
  END IF;
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.sold_to_org_id, p_in_old_rec.sold_to_org_id) THEN
      IF OE_LINE_SECURITY.SOLD_TO_ORG(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
      OE_LINE_CL_DEP_ATTR.SOLD_TO_ORG(p_initial_rec, p_in_old_rec, g_record);
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
    g_record.SHIP_TO_ORG_ID := ONT_D2_SHIP_TO_ORG_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ship_to_org_id, p_in_old_rec.ship_to_org_id) THEN
      IF OE_LINE_SECURITY.SHIP_TO_ORG(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
      OE_LINE_CL_DEP_ATTR.SHIP_TO_ORG(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.SHIP_TO_ORG_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'INVOICE_TO_ORG_ID';
 
IF g_record.INVOICE_TO_ORG_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.INVOICE_TO_ORG_ID := ONT_D2_INVOICE_TO_ORG_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.invoice_to_org_id, p_in_old_rec.invoice_to_org_id) THEN
      IF OE_LINE_SECURITY.INVOICE_TO_ORG(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
      OE_LINE_CL_DEP_ATTR.INVOICE_TO_ORG(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.INVOICE_TO_ORG_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'DELIVER_TO_ORG_ID';
 
IF g_record.DELIVER_TO_ORG_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.DELIVER_TO_ORG_ID := ONT_D2_DELIVER_TO_ORG_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.deliver_to_org_id, p_in_old_rec.deliver_to_org_id) THEN
      IF OE_LINE_SECURITY.DELIVER_TO_ORG(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
      OE_LINE_CL_DEP_ATTR.DELIVER_TO_ORG(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.DELIVER_TO_ORG_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'REQUEST_DATE';
 
IF g_record.REQUEST_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.REQUEST_DATE := ONT_D2_REQUEST_DATE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.request_date, p_in_old_rec.request_date) THEN
      IF OE_LINE_SECURITY.REQUEST_DATE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
      OE_LINE_CL_DEP_ATTR.REQUEST_DATE(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.REQUEST_DATE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SCHEDULE_SHIP_DATE';
 
IF g_record.SCHEDULE_SHIP_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SCHEDULE_SHIP_DATE := ONT_D2_SCHEDULE_SHIP_DATE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
  IF g_record.SCHEDULE_SHIP_DATE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SCHEDULE_SHIP_DATE(g_record.SCHEDULE_SHIP_DATE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SCHEDULE_SHIP_DATE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'PROMISE_DATE';
 
IF g_record.PROMISE_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.PROMISE_DATE := ONT_D2_PROMISE_DATE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.promise_date, p_in_old_rec.promise_date) THEN
      IF OE_LINE_SECURITY.PROMISE_DATE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.PROMISE_DATE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.PROMISE_DATE(g_record.PROMISE_DATE) THEN  
      -- if valid, clear dependent attributes
      OE_LINE_CL_DEP_ATTR.PROMISE_DATE(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.PROMISE_DATE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'TAX_DATE';
 
IF g_record.TAX_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.TAX_DATE := ONT_D2_TAX_DATE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.tax_date, p_in_old_rec.tax_date) THEN
      IF OE_LINE_SECURITY.TAX_DATE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.TAX_DATE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.TAX_DATE(g_record.TAX_DATE) THEN  
      -- if valid, clear dependent attributes
      OE_LINE_CL_DEP_ATTR.TAX_DATE(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.TAX_DATE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'TAX_CODE';
 
IF g_record.TAX_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.TAX_CODE := ONT_D2_TAX_CODE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.tax_code, p_in_old_rec.tax_code) THEN
      IF OE_LINE_SECURITY.TAX(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.TAX_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.TAX(g_record.TAX_CODE) THEN  
      -- if valid, clear dependent attributes
      OE_LINE_CL_DEP_ATTR.TAX(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.TAX_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'TAX_EXEMPT_FLAG';
 
IF g_record.TAX_EXEMPT_FLAG = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.TAX_EXEMPT_FLAG := ONT_D2_TAX_EXEMPT_FLAG.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.tax_exempt_flag, p_in_old_rec.tax_exempt_flag) THEN
      IF OE_LINE_SECURITY.TAX_EXEMPT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
      OE_LINE_CL_DEP_ATTR.TAX_EXEMPT(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.TAX_EXEMPT_FLAG := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SHIP_FROM_ORG_ID';
 
IF g_record.SHIP_FROM_ORG_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SHIP_FROM_ORG_ID := ONT_D2_SHIP_FROM_ORG_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ship_from_org_id, p_in_old_rec.ship_from_org_id) THEN
      IF OE_LINE_SECURITY.SHIP_FROM_ORG(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
      OE_LINE_CL_DEP_ATTR.SHIP_FROM_ORG(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.SHIP_FROM_ORG_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'ATO_LINE_ID';
 
IF g_record.ATO_LINE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ATO_LINE_ID := NULL;
END IF;
l_attr:= 'ACCOUNTING_RULE_ID';
 
IF g_record.ACCOUNTING_RULE_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.ACCOUNTING_RULE_ID := ONT_D2_ACCOUNTING_RULE_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.accounting_rule_id, p_in_old_rec.accounting_rule_id) THEN
      IF OE_LINE_SECURITY.ACCOUNTING_RULE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
    g_record.ACCOUNTING_RULE_DURATION := ONT_D2_ACCOUNTING_RULE_DURA.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.accounting_rule_duration, p_in_old_rec.accounting_rule_duration) THEN
      IF OE_LINE_SECURITY.ACCOUNTING_RULE_DURATION(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
      OE_LINE_CL_DEP_ATTR.ACCOUNTING_RULE_DURATION(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.ACCOUNTING_RULE_DURATION := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'ACTUAL_ARRIVAL_DATE';
 
IF g_record.ACTUAL_ARRIVAL_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ACTUAL_ARRIVAL_DATE := NULL;
END IF;
l_attr:= 'ACTUAL_FULFILLMENT_DATE';
 
IF g_record.ACTUAL_FULFILLMENT_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ACTUAL_FULFILLMENT_DATE := NULL;
END IF;
l_attr:= 'ACTUAL_SHIPMENT_DATE';
 
IF g_record.ACTUAL_SHIPMENT_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ACTUAL_SHIPMENT_DATE := NULL;
END IF;
l_attr:= 'ARRIVAL_SET_ID';
 
IF g_record.ARRIVAL_SET_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ARRIVAL_SET_ID := NULL;
END IF;
l_attr:= 'ARRIVAL_SET';
 
IF g_record.ARRIVAL_SET = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ARRIVAL_SET := NULL;
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
l_attr:= 'AUTHORIZED_TO_SHIP_FLAG';
 
IF g_record.AUTHORIZED_TO_SHIP_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.AUTHORIZED_TO_SHIP_FLAG := NULL;
END IF;
l_attr:= 'AUTO_SELECTED_QUANTITY';
 
IF g_record.AUTO_SELECTED_QUANTITY = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.AUTO_SELECTED_QUANTITY := NULL;
END IF;
l_attr:= 'INVOICE_TO_CONTACT_ID';
 
IF g_record.INVOICE_TO_CONTACT_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.INVOICE_TO_CONTACT_ID := ONT_D2_INVOICE_TO_CONTACT_I.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.invoice_to_contact_id, p_in_old_rec.invoice_to_contact_id) THEN
      IF OE_LINE_SECURITY.INVOICE_TO_CONTACT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
      OE_LINE_CL_DEP_ATTR.INVOICE_TO_CONTACT(p_initial_rec, p_in_old_rec, g_record);
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
l_attr:= 'CALCULATE_PRICE_FLAG';
 
IF g_record.CALCULATE_PRICE_FLAG = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CALCULATE_PRICE_FLAG := ONT_D2_CALCULATE_PRICE_FLAG.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'CANCELLED_FLAG';
 
IF g_record.CANCELLED_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CANCELLED_FLAG := NULL;
END IF;
l_attr:= 'CANCELLED_QUANTITY';
 
IF g_record.CANCELLED_QUANTITY = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CANCELLED_QUANTITY := NULL;
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
l_attr:= 'CHARGE_PERIODICITY_CODE';
 
IF g_record.CHARGE_PERIODICITY_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CHARGE_PERIODICITY_CODE := ONT_D2_CHARGE_PERIODICITY_C.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'COMMITMENT_ID';
 
IF g_record.COMMITMENT_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.COMMITMENT_ID := ONT_D2_COMMITMENT_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'COMPONENT_CODE';
 
IF g_record.COMPONENT_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.COMPONENT_CODE := NULL;
END IF;
l_attr:= 'COMPONENT_NUMBER';
 
IF g_record.COMPONENT_NUMBER = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.COMPONENT_NUMBER := NULL;
END IF;
l_attr:= 'COMPONENT_SEQUENCE_ID';
 
IF g_record.COMPONENT_SEQUENCE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.COMPONENT_SEQUENCE_ID := NULL;
END IF;
l_attr:= 'CONFIG_DISPLAY_SEQUENCE';
 
IF g_record.CONFIG_DISPLAY_SEQUENCE = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CONFIG_DISPLAY_SEQUENCE := NULL;
END IF;
l_attr:= 'CONFIG_HEADER_ID';
 
IF g_record.CONFIG_HEADER_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CONFIG_HEADER_ID := NULL;
END IF;
l_attr:= 'CONFIG_REV_NBR';
 
IF g_record.CONFIG_REV_NBR = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CONFIG_REV_NBR := NULL;
END IF;
l_attr:= 'CONFIGURATION_ID';
 
IF g_record.CONFIGURATION_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CONFIGURATION_ID := NULL;
END IF;
l_attr:= 'CONTEXT';
 
IF g_record.CONTEXT = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CONTEXT := NULL;
END IF;
l_attr:= 'CONTINGENCY_ID';
 
IF g_record.CONTINGENCY_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CONTINGENCY_ID := NULL;
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
l_attr:= 'CREDIT_INVOICE_LINE_ID';
 
IF g_record.CREDIT_INVOICE_LINE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CREDIT_INVOICE_LINE_ID := NULL;
END IF;
l_attr:= 'IB_CURRENT_LOCATION';
 
IF g_record.IB_CURRENT_LOCATION = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.IB_CURRENT_LOCATION := ONT_D2_IB_CURRENT_LOCATION.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ib_current_location, p_in_old_rec.ib_current_location) THEN
      IF OE_LINE_SECURITY.IB_CURRENT_LOCATION(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.IB_CURRENT_LOCATION IS NOT NULL THEN
    l_attr:=l_attr||' 4';
      -- if valid, clear dependent attributes
      OE_LINE_CL_DEP_ATTR.IB_CURRENT_LOCATION(p_initial_rec, p_in_old_rec, g_record);
  END IF;
END IF;
l_attr:= 'CUST_MODEL_SERIAL_NUMBER';
 
IF g_record.CUST_MODEL_SERIAL_NUMBER = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CUST_MODEL_SERIAL_NUMBER := NULL;
END IF;
l_attr:= 'CUSTOMER_DOCK_CODE';
 
IF g_record.CUSTOMER_DOCK_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CUSTOMER_DOCK_CODE := NULL;
END IF;
l_attr:= 'CUSTOMER_JOB';
 
IF g_record.CUSTOMER_JOB = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CUSTOMER_JOB := NULL;
END IF;
l_attr:= 'CUST_PO_NUMBER';
 
IF g_record.CUST_PO_NUMBER = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CUST_PO_NUMBER := ONT_D2_CUST_PO_NUMBER.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  IF g_record.CUST_PO_NUMBER IS NULL 
   AND p_in_old_rec.CUST_PO_NUMBER <> FND_API.G_MISS_CHAR THEN 
  g_record.CUST_PO_NUMBER := p_in_old_rec.CUST_PO_NUMBER;
  END IF;
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.cust_po_number, p_in_old_rec.cust_po_number) THEN
      IF OE_LINE_SECURITY.CUST_PO_NUMBER(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
l_attr:= 'CUSTOMER_LINE_NUMBER';
 
IF g_record.CUSTOMER_LINE_NUMBER = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CUSTOMER_LINE_NUMBER := ONT_D2_CUSTOMER_LINE_NUMBER.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.customer_line_number, p_in_old_rec.customer_line_number) THEN
      IF OE_LINE_SECURITY.CUSTOMER_LINE_NUMBER(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'CUSTOMER_PRODUCTION_LINE';
 
IF g_record.CUSTOMER_PRODUCTION_LINE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CUSTOMER_PRODUCTION_LINE := NULL;
END IF;
l_attr:= 'CUST_PRODUCTION_SEQ_NUM';
 
IF g_record.CUST_PRODUCTION_SEQ_NUM = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CUST_PRODUCTION_SEQ_NUM := NULL;
END IF;
l_attr:= 'CUSTOMER_SHIPMENT_NUMBER';
 
IF g_record.CUSTOMER_SHIPMENT_NUMBER = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.CUSTOMER_SHIPMENT_NUMBER := ONT_D2_CUSTOMER_SHIPMENT_NU.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
  IF g_record.CUSTOMER_SHIPMENT_NUMBER IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.CUSTOMER_SHIPMENT_NUMBER(g_record.CUSTOMER_SHIPMENT_NUMBER) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.CUSTOMER_SHIPMENT_NUMBER := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'CUSTOMER_TRX_LINE_ID';
 
IF g_record.CUSTOMER_TRX_LINE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CUSTOMER_TRX_LINE_ID := NULL;
END IF;
l_attr:= 'DB_FLAG';
 
IF g_record.DB_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.DB_FLAG := NULL;
END IF;
l_attr:= 'DELIVER_TO_CONTACT_ID';
 
IF g_record.DELIVER_TO_CONTACT_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.DELIVER_TO_CONTACT_ID := ONT_D2_DELIVER_TO_CONTACT_I.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.deliver_to_contact_id, p_in_old_rec.deliver_to_contact_id) THEN
      IF OE_LINE_SECURITY.DELIVER_TO_CONTACT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
      OE_LINE_CL_DEP_ATTR.DELIVER_TO_CONTACT(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.DELIVER_TO_CONTACT_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'DELIVERY_LEAD_TIME';
 
IF g_record.DELIVERY_LEAD_TIME = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.DELIVERY_LEAD_TIME := NULL;
END IF;
l_attr:= 'DEMAND_BUCKET_TYPE_CODE';
 
IF g_record.DEMAND_BUCKET_TYPE_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.DEMAND_BUCKET_TYPE_CODE := NULL;
END IF;
l_attr:= 'DEMAND_CLASS_CODE';
 
IF g_record.DEMAND_CLASS_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.DEMAND_CLASS_CODE := ONT_D2_DEMAND_CLASS_CODE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.demand_class_code, p_in_old_rec.demand_class_code) THEN
      IF OE_LINE_SECURITY.DEMAND_CLASS(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
l_attr:= 'DEP_PLAN_REQUIRED_FLAG';
 
IF g_record.DEP_PLAN_REQUIRED_FLAG = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.DEP_PLAN_REQUIRED_FLAG := ONT_D2_DEP_PLAN_REQUIRED_FL.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.dep_plan_required_flag, p_in_old_rec.dep_plan_required_flag) THEN
      IF OE_LINE_SECURITY.DEP_PLAN_REQUIRED(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.DEP_PLAN_REQUIRED_FLAG IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.DEP_PLAN_REQUIRED(g_record.DEP_PLAN_REQUIRED_FLAG) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.DEP_PLAN_REQUIRED_FLAG := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'EARLIEST_ACCEPTABLE_DATE';
 
IF g_record.EARLIEST_ACCEPTABLE_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.EARLIEST_ACCEPTABLE_DATE := ONT_D2_EARLIEST_ACCEPTABLE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.earliest_acceptable_date, p_in_old_rec.earliest_acceptable_date) THEN
      IF OE_LINE_SECURITY.EARLIEST_ACCEPTABLE_DATE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.EARLIEST_ACCEPTABLE_DATE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.EARLIEST_ACCEPTABLE_DATE(g_record.EARLIEST_ACCEPTABLE_DATE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.EARLIEST_ACCEPTABLE_DATE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'END_CUSTOMER_ID';
 
IF g_record.END_CUSTOMER_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.END_CUSTOMER_ID := ONT_D2_END_CUSTOMER_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.end_customer_id, p_in_old_rec.end_customer_id) THEN
      IF OE_LINE_SECURITY.END_CUSTOMER(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.END_CUSTOMER_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
      -- if valid, clear dependent attributes
      OE_LINE_CL_DEP_ATTR.END_CUSTOMER(p_initial_rec, p_in_old_rec, g_record);
  END IF;
END IF;
l_attr:= 'END_CUSTOMER_CONTACT_ID';
 
IF g_record.END_CUSTOMER_CONTACT_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.END_CUSTOMER_CONTACT_ID := ONT_D2_END_CUSTOMER_CONTACT.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.end_customer_contact_id, p_in_old_rec.end_customer_contact_id) THEN
      IF OE_LINE_SECURITY.END_CUSTOMER_CONTACT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.END_CUSTOMER_CONTACT_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
      -- if valid, clear dependent attributes
      OE_LINE_CL_DEP_ATTR.END_CUSTOMER_CONTACT(p_initial_rec, p_in_old_rec, g_record);
  END IF;
END IF;
l_attr:= 'END_CUSTOMER_SITE_USE_ID';
 
IF g_record.END_CUSTOMER_SITE_USE_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.END_CUSTOMER_SITE_USE_ID := ONT_D2_END_CUSTOMER_SITE_US.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.end_customer_site_use_id, p_in_old_rec.end_customer_site_use_id) THEN
      IF OE_LINE_SECURITY.END_CUSTOMER_SITE_USE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.END_CUSTOMER_SITE_USE_ID IS NOT NULL THEN
    l_attr:=l_attr||' 4';
      -- if valid, clear dependent attributes
      OE_LINE_CL_DEP_ATTR.END_CUSTOMER_SITE_USE(p_initial_rec, p_in_old_rec, g_record);
  END IF;
END IF;
l_attr:= 'END_ITEM_UNIT_NUMBER';
 
IF g_record.END_ITEM_UNIT_NUMBER = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.END_ITEM_UNIT_NUMBER := ONT_D2_END_ITEM_UNIT_NUMBER.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
  IF g_record.END_ITEM_UNIT_NUMBER IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.END_ITEM_UNIT_NUMBER(g_record.END_ITEM_UNIT_NUMBER) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.END_ITEM_UNIT_NUMBER := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'EXPLOSION_DATE';
 
IF g_record.EXPLOSION_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.EXPLOSION_DATE := NULL;
END IF;
l_attr:= 'FOB_POINT_CODE';
 
IF g_record.FOB_POINT_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.FOB_POINT_CODE := ONT_D2_FOB_POINT_CODE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.fob_point_code, p_in_old_rec.fob_point_code) THEN
      IF OE_LINE_SECURITY.FOB_POINT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
    g_record.FREIGHT_TERMS_CODE := ONT_D2_FREIGHT_TERMS_CODE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.freight_terms_code, p_in_old_rec.freight_terms_code) THEN
      IF OE_LINE_SECURITY.FREIGHT_TERMS(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
l_attr:= 'FULFILLED_FLAG';
 
IF g_record.FULFILLED_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.FULFILLED_FLAG := NULL;
END IF;
l_attr:= 'FULFILLED_QUANTITY';
 
IF g_record.FULFILLED_QUANTITY = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.FULFILLED_QUANTITY := NULL;
END IF;
l_attr:= 'FULFILLMENT_DATE';
 
IF g_record.FULFILLMENT_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.FULFILLMENT_DATE := NULL;
END IF;
l_attr:= 'FULFILLMENT_METHOD_CODE';
 
IF g_record.FULFILLMENT_METHOD_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.FULFILLMENT_METHOD_CODE := NULL;
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
l_attr:= 'PREFERRED_GRADE';
 
IF g_record.PREFERRED_GRADE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.PREFERRED_GRADE := ONT_D2_PREFERRED_GRADE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'HEADER_ID';
 
IF g_record.HEADER_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.HEADER_ID := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE16';
 
IF g_record.INDUSTRY_ATTRIBUTE16 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE16 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE17';
 
IF g_record.INDUSTRY_ATTRIBUTE17 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE17 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE18';
 
IF g_record.INDUSTRY_ATTRIBUTE18 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE18 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE19';
 
IF g_record.INDUSTRY_ATTRIBUTE19 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE19 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE20';
 
IF g_record.INDUSTRY_ATTRIBUTE20 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE20 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE21';
 
IF g_record.INDUSTRY_ATTRIBUTE21 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE21 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE22';
 
IF g_record.INDUSTRY_ATTRIBUTE22 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE22 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE23';
 
IF g_record.INDUSTRY_ATTRIBUTE23 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE23 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE24';
 
IF g_record.INDUSTRY_ATTRIBUTE24 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE24 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE25';
 
IF g_record.INDUSTRY_ATTRIBUTE25 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE25 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE26';
 
IF g_record.INDUSTRY_ATTRIBUTE26 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE26 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE27';
 
IF g_record.INDUSTRY_ATTRIBUTE27 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE27 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE28';
 
IF g_record.INDUSTRY_ATTRIBUTE28 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE28 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE29';
 
IF g_record.INDUSTRY_ATTRIBUTE29 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE29 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE30';
 
IF g_record.INDUSTRY_ATTRIBUTE30 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE30 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE1';
 
IF g_record.INDUSTRY_ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE1 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE10';
 
IF g_record.INDUSTRY_ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE10 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE11';
 
IF g_record.INDUSTRY_ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE11 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE12';
 
IF g_record.INDUSTRY_ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE12 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE13';
 
IF g_record.INDUSTRY_ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE13 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE14';
 
IF g_record.INDUSTRY_ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE14 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE15';
 
IF g_record.INDUSTRY_ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE15 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE2';
 
IF g_record.INDUSTRY_ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE2 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE3';
 
IF g_record.INDUSTRY_ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE3 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE4';
 
IF g_record.INDUSTRY_ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE4 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE5';
 
IF g_record.INDUSTRY_ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE5 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE6';
 
IF g_record.INDUSTRY_ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE6 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE7';
 
IF g_record.INDUSTRY_ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE7 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE8';
 
IF g_record.INDUSTRY_ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE8 := NULL;
END IF;
l_attr:= 'INDUSTRY_ATTRIBUTE9';
 
IF g_record.INDUSTRY_ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_ATTRIBUTE9 := NULL;
END IF;
l_attr:= 'INDUSTRY_CONTEXT';
 
IF g_record.INDUSTRY_CONTEXT = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INDUSTRY_CONTEXT := NULL;
END IF;
l_attr:= 'IB_INSTALLED_AT_LOCATION';
 
IF g_record.IB_INSTALLED_AT_LOCATION = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.IB_INSTALLED_AT_LOCATION := ONT_D2_IB_INSTALLED_AT_LOCA.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ib_installed_at_location, p_in_old_rec.ib_installed_at_location) THEN
      IF OE_LINE_SECURITY.IB_INSTALLED_AT_LOCATION(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.IB_INSTALLED_AT_LOCATION IS NOT NULL THEN
    l_attr:=l_attr||' 4';
      -- if valid, clear dependent attributes
      OE_LINE_CL_DEP_ATTR.IB_INSTALLED_AT_LOCATION(p_initial_rec, p_in_old_rec, g_record);
  END IF;
END IF;
l_attr:= 'INTERMED_SHIP_TO_CONTACT_ID';
 
IF g_record.INTERMED_SHIP_TO_CONTACT_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INTERMED_SHIP_TO_CONTACT_ID := NULL;
END IF;
l_attr:= 'INTERMED_SHIP_TO_ORG_ID';
 
IF g_record.INTERMED_SHIP_TO_ORG_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INTERMED_SHIP_TO_ORG_ID := NULL;
END IF;
l_attr:= 'INVENTORY_ITEM_ID';
 
IF g_record.INVENTORY_ITEM_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INVENTORY_ITEM_ID := NULL;
END IF;
l_attr:= 'INVOICE_INTERFACE_STATUS_CODE';
 
IF g_record.INVOICE_INTERFACE_STATUS_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INVOICE_INTERFACE_STATUS_CODE := NULL;
END IF;
l_attr:= 'INVOICED_QUANTITY';
 
IF g_record.INVOICED_QUANTITY = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.INVOICED_QUANTITY := NULL;
END IF;
l_attr:= 'INVOICING_RULE_ID';
 
IF g_record.INVOICING_RULE_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.INVOICING_RULE_ID := ONT_D2_INVOICING_RULE_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.invoicing_rule_id, p_in_old_rec.invoicing_rule_id) THEN
      IF OE_LINE_SECURITY.INVOICING_RULE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
l_attr:= 'ITEM_IDENTIFIER_TYPE';
 
IF g_record.ITEM_IDENTIFIER_TYPE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.ITEM_IDENTIFIER_TYPE := ONT_D2_ITEM_IDENTIFIER_TYPE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'ITEM_REVISION';
 
IF g_record.ITEM_REVISION = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.ITEM_REVISION := ONT_D2_ITEM_REVISION.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.item_revision, p_in_old_rec.item_revision) THEN
      IF OE_LINE_SECURITY.ITEM_REVISION(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.ITEM_REVISION IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.ITEM_REVISION(g_record.ITEM_REVISION) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.ITEM_REVISION := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'ITEM_TYPE_CODE';
 
IF g_record.ITEM_TYPE_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ITEM_TYPE_CODE := NULL;
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
l_attr:= 'LATEST_ACCEPTABLE_DATE';
 
IF g_record.LATEST_ACCEPTABLE_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.LATEST_ACCEPTABLE_DATE := ONT_D2_LATEST_ACCEPTABLE_DA.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.latest_acceptable_date, p_in_old_rec.latest_acceptable_date) THEN
      IF OE_LINE_SECURITY.LATEST_ACCEPTABLE_DATE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.LATEST_ACCEPTABLE_DATE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.LATEST_ACCEPTABLE_DATE(g_record.LATEST_ACCEPTABLE_DATE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.LATEST_ACCEPTABLE_DATE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'LINE_ID';
 
IF g_record.LINE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.LINE_ID := NULL;
END IF;
l_attr:= 'LINE_CATEGORY_CODE';
 
IF g_record.LINE_CATEGORY_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.LINE_CATEGORY_CODE := NULL;
END IF;
l_attr:= 'LINE_NUMBER';
 
IF g_record.LINE_NUMBER = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.LINE_NUMBER := NULL;
END IF;
l_attr:= 'LINE_SET_ID';
 
IF g_record.LINE_SET_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.LINE_SET_ID := NULL;
END IF;
l_attr:= 'LINK_TO_LINE_ID';
 
IF g_record.LINK_TO_LINE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.LINK_TO_LINE_ID := NULL;
END IF;
l_attr:= 'MFG_COMPONENT_SEQUENCE_ID';
 
IF g_record.MFG_COMPONENT_SEQUENCE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.MFG_COMPONENT_SEQUENCE_ID := NULL;
END IF;
l_attr:= 'MODEL_GROUP_NUMBER';
 
IF g_record.MODEL_GROUP_NUMBER = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.MODEL_GROUP_NUMBER := NULL;
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
l_attr:= 'OPTION_FLAG';
 
IF g_record.OPTION_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.OPTION_FLAG := NULL;
END IF;
l_attr:= 'OPTION_NUMBER';
 
IF g_record.OPTION_NUMBER = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.OPTION_NUMBER := NULL;
END IF;
l_attr:= 'ORDER_FIRMED_DATE';
 
IF g_record.ORDER_FIRMED_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.ORDER_FIRMED_DATE := ONT_D2_ORDER_FIRMED_DATE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'ORDER_QUANTITY_UOM';
 
IF g_record.ORDER_QUANTITY_UOM = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.ORDER_QUANTITY_UOM := ONT_D2_ORDER_QUANTITY_UOM.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.order_quantity_uom, p_in_old_rec.order_quantity_uom) THEN
      IF OE_LINE_SECURITY.ORDER_QUANTITY_UOM(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.ORDER_QUANTITY_UOM IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.ORDER_QUANTITY_UOM(g_record.ORDER_QUANTITY_UOM) THEN  
      -- if valid, clear dependent attributes
      OE_LINE_CL_DEP_ATTR.ORDER_QUANTITY_UOM(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.ORDER_QUANTITY_UOM := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'ORDERED_ITEM';
 
IF g_record.ORDERED_ITEM = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ORDERED_ITEM := NULL;
END IF;
l_attr:= 'ORDERED_ITEM_ID';
 
IF g_record.ORDERED_ITEM_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ORDERED_ITEM_ID := NULL;
END IF;
l_attr:= 'ORDERED_QUANTITY';
 
IF g_record.ORDERED_QUANTITY = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.ORDERED_QUANTITY := ONT_D2_ORDERED_QUANTITY.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ordered_quantity, p_in_old_rec.ordered_quantity) THEN
      IF OE_LINE_SECURITY.ORDERED_QUANTITY(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.ORDERED_QUANTITY IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.ORDERED_QUANTITY(g_record.ORDERED_QUANTITY) THEN  
      -- if valid, clear dependent attributes
      OE_LINE_CL_DEP_ATTR.ORDERED_QUANTITY(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.ORDERED_QUANTITY := NULL;
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
l_attr:= 'ORIG_SYS_LINE_REF';
 
IF g_record.ORIG_SYS_LINE_REF = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.ORIG_SYS_LINE_REF := NULL;
END IF;
l_attr:= 'OVER_SHIP_REASON_CODE';
 
IF g_record.OVER_SHIP_REASON_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.OVER_SHIP_REASON_CODE := NULL;
END IF;
l_attr:= 'OVER_SHIP_RESOLVED_FLAG';
 
IF g_record.OVER_SHIP_RESOLVED_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.OVER_SHIP_RESOLVED_FLAG := NULL;
END IF;
l_attr:= 'IB_OWNER';
 
IF g_record.IB_OWNER = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.IB_OWNER := ONT_D2_IB_OWNER.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ib_owner, p_in_old_rec.ib_owner) THEN
      IF OE_LINE_SECURITY.IB_OWNER(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.IB_OWNER IS NOT NULL THEN
    l_attr:=l_attr||' 4';
      -- if valid, clear dependent attributes
      OE_LINE_CL_DEP_ATTR.IB_OWNER(p_initial_rec, p_in_old_rec, g_record);
  END IF;
END IF;
l_attr:= 'PACKING_INSTRUCTIONS';
 
IF g_record.PACKING_INSTRUCTIONS = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.PACKING_INSTRUCTIONS := ONT_D2_PACKING_INSTRUCTIONS.Get_Default_Value(g_record);
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
l_attr:= 'PARTY_TYPE';
 
IF g_record.PARTY_TYPE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PARTY_TYPE := NULL;
END IF;
l_attr:= 'PAYMENT_TERM_ID';
 
IF g_record.PAYMENT_TERM_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.PAYMENT_TERM_ID := ONT_D2_PAYMENT_TERM_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.payment_term_id, p_in_old_rec.payment_term_id) THEN
      IF OE_LINE_SECURITY.PAYMENT_TERM(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
l_attr:= 'PLANNING_PRIORITY';
 
IF g_record.PLANNING_PRIORITY = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PLANNING_PRIORITY := NULL;
END IF;
l_attr:= 'PRICE_LIST_ID';
 
IF g_record.PRICE_LIST_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.PRICE_LIST_ID := ONT_D2_PRICE_LIST_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  IF g_record.PRICE_LIST_ID IS NULL 
   AND p_in_old_rec.PRICE_LIST_ID <> FND_API.G_MISS_NUM THEN 
  g_record.PRICE_LIST_ID := p_in_old_rec.PRICE_LIST_ID;
  END IF;
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.price_list_id, p_in_old_rec.price_list_id) THEN
      IF OE_LINE_SECURITY.PRICE_LIST(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
      OE_LINE_CL_DEP_ATTR.PRICE_LIST(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.PRICE_LIST_ID := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'PRICING_ATTRIBUTE1';
 
IF g_record.PRICING_ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PRICING_ATTRIBUTE1 := NULL;
END IF;
l_attr:= 'PRICING_ATTRIBUTE10';
 
IF g_record.PRICING_ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PRICING_ATTRIBUTE10 := NULL;
END IF;
l_attr:= 'PRICING_ATTRIBUTE2';
 
IF g_record.PRICING_ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PRICING_ATTRIBUTE2 := NULL;
END IF;
l_attr:= 'PRICING_ATTRIBUTE3';
 
IF g_record.PRICING_ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PRICING_ATTRIBUTE3 := NULL;
END IF;
l_attr:= 'PRICING_ATTRIBUTE4';
 
IF g_record.PRICING_ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PRICING_ATTRIBUTE4 := NULL;
END IF;
l_attr:= 'PRICING_ATTRIBUTE5';
 
IF g_record.PRICING_ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PRICING_ATTRIBUTE5 := NULL;
END IF;
l_attr:= 'PRICING_ATTRIBUTE6';
 
IF g_record.PRICING_ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PRICING_ATTRIBUTE6 := NULL;
END IF;
l_attr:= 'PRICING_ATTRIBUTE7';
 
IF g_record.PRICING_ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PRICING_ATTRIBUTE7 := NULL;
END IF;
l_attr:= 'PRICING_ATTRIBUTE8';
 
IF g_record.PRICING_ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PRICING_ATTRIBUTE8 := NULL;
END IF;
l_attr:= 'PRICING_ATTRIBUTE9';
 
IF g_record.PRICING_ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PRICING_ATTRIBUTE9 := NULL;
END IF;
l_attr:= 'PRICING_CONTEXT';
 
IF g_record.PRICING_CONTEXT = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PRICING_CONTEXT := NULL;
END IF;
l_attr:= 'PRICING_DATE';
 
IF g_record.PRICING_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.PRICING_DATE := ONT_D2_PRICING_DATE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.pricing_date, p_in_old_rec.pricing_date) THEN
      IF OE_LINE_SECURITY.PRICING_DATE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
l_attr:= 'PRICING_QUANTITY';
 
IF g_record.PRICING_QUANTITY = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PRICING_QUANTITY := NULL;
END IF;
l_attr:= 'PRICING_QUANTITY_UOM';
 
IF g_record.PRICING_QUANTITY_UOM = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PRICING_QUANTITY_UOM := NULL;
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
l_attr:= 'PROJECT_ID';
 
IF g_record.PROJECT_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.PROJECT_ID := NULL;
END IF;
l_attr:= 'REFERENCE_CUSTOMR_TRX_LINE_ID';
 
IF g_record.REFERENCE_CUSTOMER_TRX_LINE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.REFERENCE_CUSTOMER_TRX_LINE_ID := NULL;
END IF;
l_attr:= 'REFERENCE_HEADER_ID';
 
IF g_record.REFERENCE_HEADER_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.REFERENCE_HEADER_ID := NULL;
END IF;
l_attr:= 'REFERENCE_LINE_ID';
 
IF g_record.REFERENCE_LINE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.REFERENCE_LINE_ID := NULL;
END IF;
l_attr:= 'REFERENCE_TYPE';
 
IF g_record.REFERENCE_TYPE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.REFERENCE_TYPE := NULL;
END IF;
l_attr:= 'REQUEST_ID';
 
IF g_record.REQUEST_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.REQUEST_ID := NULL;
END IF;
l_attr:= 'RESERVED_QUANTITY';
 
IF g_record.RESERVED_QUANTITY = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RESERVED_QUANTITY := NULL;
END IF;
l_attr:= 'RETROBILL_REQUEST_ID';
 
IF g_record.RETROBILL_REQUEST_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETROBILL_REQUEST_ID := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE1';
 
IF g_record.RETURN_ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE1 := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE10';
 
IF g_record.RETURN_ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE10 := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE11';
 
IF g_record.RETURN_ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE11 := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE12';
 
IF g_record.RETURN_ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE12 := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE13';
 
IF g_record.RETURN_ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE13 := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE14';
 
IF g_record.RETURN_ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE14 := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE15';
 
IF g_record.RETURN_ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE15 := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE2';
 
IF g_record.RETURN_ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE2 := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE3';
 
IF g_record.RETURN_ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE3 := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE4';
 
IF g_record.RETURN_ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE4 := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE5';
 
IF g_record.RETURN_ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE5 := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE6';
 
IF g_record.RETURN_ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE6 := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE7';
 
IF g_record.RETURN_ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE7 := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE8';
 
IF g_record.RETURN_ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE8 := NULL;
END IF;
l_attr:= 'RETURN_ATTRIBUTE9';
 
IF g_record.RETURN_ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_ATTRIBUTE9 := NULL;
END IF;
l_attr:= 'RETURN_CONTEXT';
 
IF g_record.RETURN_CONTEXT = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_CONTEXT := NULL;
END IF;
l_attr:= 'RETURN_REASON_CODE';
 
IF g_record.RETURN_REASON_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.RETURN_REASON_CODE := ONT_D2_RETURN_REASON_CODE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.return_reason_code, p_in_old_rec.return_reason_code) THEN
      IF OE_LINE_SECURITY.RETURN_REASON(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.RETURN_REASON_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.RETURN_REASON(g_record.RETURN_REASON_CODE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.RETURN_REASON_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'RETURN_STATUS';
 
IF g_record.RETURN_STATUS = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RETURN_STATUS := NULL;
END IF;
l_attr:= 'REVENUE_AMOUNT';
 
IF g_record.REVENUE_AMOUNT = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.REVENUE_AMOUNT := NULL;
END IF;
l_attr:= 'REVREC_EXPIRATION_DAYS';
 
IF g_record.REVREC_EXPIRATION_DAYS = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.REVREC_EXPIRATION_DAYS := NULL;
END IF;
l_attr:= 'RLA_SCHEDULE_TYPE_CODE';
 
IF g_record.RLA_SCHEDULE_TYPE_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.RLA_SCHEDULE_TYPE_CODE := NULL;
END IF;
l_attr:= 'BLANKET_LINE_NUMBER';
 
IF g_record.BLANKET_LINE_NUMBER = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.BLANKET_LINE_NUMBER := NULL;
END IF;
l_attr:= 'BLANKET_NUMBER';
 
IF g_record.BLANKET_NUMBER = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.BLANKET_NUMBER := ONT_D2_BLANKET_NUMBER.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.blanket_number, p_in_old_rec.blanket_number) THEN
      IF OE_LINE_SECURITY.BLANKET_NUMBER(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
      OE_LINE_CL_DEP_ATTR.BLANKET_NUMBER(p_initial_rec, p_in_old_rec, g_record);
    ELSE
      g_record.BLANKET_NUMBER := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'BLANKET_VERSION_NUMBER';
 
IF g_record.BLANKET_VERSION_NUMBER = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.BLANKET_VERSION_NUMBER := NULL;
END IF;
l_attr:= 'SALESREP_ID';
 
IF g_record.SALESREP_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SALESREP_ID := ONT_D2_SALESREP_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  IF g_record.SALESREP_ID IS NULL 
   AND p_in_old_rec.SALESREP_ID <> FND_API.G_MISS_NUM THEN 
  g_record.SALESREP_ID := p_in_old_rec.SALESREP_ID;
  END IF;
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.salesrep_id, p_in_old_rec.salesrep_id) THEN
      IF OE_LINE_SECURITY.SALESREP(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
l_attr:= 'SCHEDULE_ACTION_CODE';
 
IF g_record.SCHEDULE_ACTION_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SCHEDULE_ACTION_CODE := NULL;
END IF;
l_attr:= 'SCHEDULE_ARRIVAL_DATE';
 
IF g_record.SCHEDULE_ARRIVAL_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SCHEDULE_ARRIVAL_DATE := ONT_D2_SCHEDULE_ARRIVAL_DAT.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.schedule_arrival_date, p_in_old_rec.schedule_arrival_date) THEN
      IF OE_LINE_SECURITY.SCHEDULE_ARRIVAL_DATE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SCHEDULE_ARRIVAL_DATE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SCHEDULE_ARRIVAL_DATE(g_record.SCHEDULE_ARRIVAL_DATE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SCHEDULE_ARRIVAL_DATE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SCHEDULE_STATUS_CODE';
 
IF g_record.SCHEDULE_STATUS_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SCHEDULE_STATUS_CODE := NULL;
END IF;
l_attr:= 'CANCELLED_QUANTITY2';
 
IF g_record.CANCELLED_QUANTITY2 = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.CANCELLED_QUANTITY2 := NULL;
END IF;
l_attr:= 'FULFILLED_QUANTITY2';
 
IF g_record.FULFILLED_QUANTITY2 = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.FULFILLED_QUANTITY2 := NULL;
END IF;
l_attr:= 'ORDERED_QUANTITY2';
 
IF g_record.ORDERED_QUANTITY2 = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.ORDERED_QUANTITY2 := ONT_D2_ORDERED_QUANTITY2.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ordered_quantity2, p_in_old_rec.ordered_quantity2) THEN
      IF OE_LINE_SECURITY.ORDERED_QUANTITY2(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'SHIPPED_QUANTITY2';
 
IF g_record.SHIPPED_QUANTITY2 = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SHIPPED_QUANTITY2 := NULL;
END IF;
l_attr:= 'SHIPPING_QUANTITY2';
 
IF g_record.SHIPPING_QUANTITY2 = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SHIPPING_QUANTITY2 := NULL;
END IF;
l_attr:= 'SHIPPING_QUANTITY_UOM2';
 
IF g_record.SHIPPING_QUANTITY_UOM2 = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SHIPPING_QUANTITY_UOM2 := NULL;
END IF;
l_attr:= 'ORDERED_QUANTITY_UOM2';
 
IF g_record.ORDERED_QUANTITY_UOM2 = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.ORDERED_QUANTITY_UOM2 := ONT_D2_ORDERED_QUANTITY_UOM.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
      -- There is no validation api registered in the AK dictionary  
END IF;
l_attr:= 'SERVICE_COTERMINATE_FLAG';
 
IF g_record.SERVICE_COTERMINATE_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SERVICE_COTERMINATE_FLAG := NULL;
END IF;
l_attr:= 'SERVICE_DURATION';
 
IF g_record.SERVICE_DURATION = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SERVICE_DURATION := ONT_D2_SERVICE_DURATION.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.service_duration, p_in_old_rec.service_duration) THEN
      IF OE_LINE_SECURITY.SERVICE_DURATION(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SERVICE_DURATION IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SERVICE_DURATION(g_record.SERVICE_DURATION) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SERVICE_DURATION := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SERVICE_END_DATE';
 
IF g_record.SERVICE_END_DATE = FND_API.G_MISS_DATE THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SERVICE_END_DATE := NULL;
END IF;
l_attr:= 'SERVICE_NUMBER';
 
IF g_record.SERVICE_NUMBER = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SERVICE_NUMBER := NULL;
END IF;
l_attr:= 'SERVICE_PERIOD';
 
IF g_record.SERVICE_PERIOD = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SERVICE_PERIOD := ONT_D2_SERVICE_PERIOD.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.service_period, p_in_old_rec.service_period) THEN
      IF OE_LINE_SECURITY.SERVICE_PERIOD(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SERVICE_PERIOD IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SERVICE_PERIOD(g_record.SERVICE_PERIOD) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SERVICE_PERIOD := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SERVICE_REFERENCE_LINE_ID';
 
IF g_record.SERVICE_REFERENCE_LINE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SERVICE_REFERENCE_LINE_ID := NULL;
END IF;
l_attr:= 'SERVICE_REFERENCE_SYSTEM_ID';
 
IF g_record.SERVICE_REFERENCE_SYSTEM_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SERVICE_REFERENCE_SYSTEM_ID := NULL;
END IF;
l_attr:= 'SERVICE_REFERENCE_TYPE_CODE';
 
IF g_record.SERVICE_REFERENCE_TYPE_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SERVICE_REFERENCE_TYPE_CODE := ONT_D2_SERVICE_REFERENCE_TY.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.service_reference_type_code, p_in_old_rec.service_reference_type_code) THEN
      IF OE_LINE_SECURITY.SERVICE_REFERENCE_TYPE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SERVICE_REFERENCE_TYPE_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SERVICE_REFERENCE_TYPE(g_record.SERVICE_REFERENCE_TYPE_CODE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SERVICE_REFERENCE_TYPE_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SERVICE_START_DATE';
 
IF g_record.SERVICE_START_DATE = FND_API.G_MISS_DATE THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SERVICE_START_DATE := ONT_D2_SERVICE_START_DATE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.service_start_date, p_in_old_rec.service_start_date) THEN
      IF OE_LINE_SECURITY.SERVICE_START_DATE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SERVICE_START_DATE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SERVICE_START_DATE(g_record.SERVICE_START_DATE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SERVICE_START_DATE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SERVICE_TXN_COMMENTS';
 
IF g_record.SERVICE_TXN_COMMENTS = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SERVICE_TXN_COMMENTS := NULL;
END IF;
l_attr:= 'SERVICE_TXN_REASON_CODE';
 
IF g_record.SERVICE_TXN_REASON_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SERVICE_TXN_REASON_CODE := NULL;
END IF;
l_attr:= 'SHIP_MODEL_COMPLETE_FLAG';
 
IF g_record.SHIP_MODEL_COMPLETE_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SHIP_MODEL_COMPLETE_FLAG := NULL;
END IF;
l_attr:= 'SHIP_SET_ID';
 
IF g_record.SHIP_SET_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SHIP_SET_ID := NULL;
END IF;
l_attr:= 'SHIP_SET';
 
IF g_record.SHIP_SET = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SHIP_SET := NULL;
END IF;
l_attr:= 'SHIP_TO_CONTACT_ID';
 
IF g_record.SHIP_TO_CONTACT_ID = FND_API.G_MISS_NUM THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SHIP_TO_CONTACT_ID := ONT_D2_SHIP_TO_CONTACT_ID.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ship_to_contact_id, p_in_old_rec.ship_to_contact_id) THEN
      IF OE_LINE_SECURITY.SHIP_TO_CONTACT(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
      OE_LINE_CL_DEP_ATTR.SHIP_TO_CONTACT(p_initial_rec, p_in_old_rec, g_record);
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
    g_record.SHIP_TOLERANCE_ABOVE := ONT_D2_SHIP_TOLERANCE_ABOVE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ship_tolerance_above, p_in_old_rec.ship_tolerance_above) THEN
      IF OE_LINE_SECURITY.SHIP_TOLERANCE_ABOVE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
    g_record.SHIP_TOLERANCE_BELOW := ONT_D2_SHIP_TOLERANCE_BELOW.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.ship_tolerance_below, p_in_old_rec.ship_tolerance_below) THEN
      IF OE_LINE_SECURITY.SHIP_TOLERANCE_BELOW(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
l_attr:= 'SHIPMENT_NUMBER';
 
IF g_record.SHIPMENT_NUMBER = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SHIPMENT_NUMBER := NULL;
END IF;
l_attr:= 'SHIPMENT_PRIORITY_CODE';
 
IF g_record.SHIPMENT_PRIORITY_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SHIPMENT_PRIORITY_CODE := ONT_D2_SHIPMENT_PRIORITY_CO.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.shipment_priority_code, p_in_old_rec.shipment_priority_code) THEN
      IF OE_LINE_SECURITY.SHIPMENT_PRIORITY(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
l_attr:= 'SHIPPED_QUANTITY';
 
IF g_record.SHIPPED_QUANTITY = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SHIPPED_QUANTITY := NULL;
END IF;
l_attr:= 'SHIPPING_INSTRUCTIONS';
 
IF g_record.SHIPPING_INSTRUCTIONS = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SHIPPING_INSTRUCTIONS := ONT_D2_SHIPPING_INSTRUCTION.Get_Default_Value(g_record);
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
l_attr:= 'SHIPPING_INTERFACED_FLAG';
 
IF g_record.SHIPPING_INTERFACED_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SHIPPING_INTERFACED_FLAG := NULL;
END IF;
l_attr:= 'SHIPPING_METHOD_CODE';
 
IF g_record.SHIPPING_METHOD_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SHIPPING_METHOD_CODE := ONT_D2_SHIPPING_METHOD_CODE.Get_Default_Value(g_record);
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
l_attr:= 'SHIPPING_QUANTITY';
 
IF g_record.SHIPPING_QUANTITY = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SHIPPING_QUANTITY := NULL;
END IF;
l_attr:= 'SHIPPING_QUANTITY_UOM';
 
IF g_record.SHIPPING_QUANTITY_UOM = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SHIPPING_QUANTITY_UOM := NULL;
END IF;
l_attr:= 'SORT_ORDER';
 
IF g_record.SORT_ORDER = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SORT_ORDER := NULL;
END IF;
l_attr:= 'SOURCE_DOCUMENT_ID';
 
IF g_record.SOURCE_DOCUMENT_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SOURCE_DOCUMENT_ID := NULL;
END IF;
l_attr:= 'SOURCE_DOCUMENT_LINE_ID';
 
IF g_record.SOURCE_DOCUMENT_LINE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SOURCE_DOCUMENT_LINE_ID := NULL;
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
l_attr:= 'SOURCE_TYPE_CODE';
 
IF g_record.SOURCE_TYPE_CODE = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SOURCE_TYPE_CODE := ONT_D2_SOURCE_TYPE_CODE.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.source_type_code, p_in_old_rec.source_type_code) THEN
      IF OE_LINE_SECURITY.SOURCE_TYPE(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
      -- Raise error if security returns YES, operation IS CONSTRAINED
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'Y';
    END IF;
  END IF;
  IF g_record.SOURCE_TYPE_CODE IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SOURCE_TYPE(g_record.SOURCE_TYPE_CODE) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SOURCE_TYPE_CODE := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'SPLIT_BY';
 
IF g_record.SPLIT_BY = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SPLIT_BY := NULL;
END IF;
l_attr:= 'SPLIT_FROM_LINE_ID';
 
IF g_record.SPLIT_FROM_LINE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.SPLIT_FROM_LINE_ID := NULL;
END IF;
l_attr:= 'SUBINVENTORY';
 
IF g_record.SUBINVENTORY = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.SUBINVENTORY := ONT_D2_SUBINVENTORY.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
-- There is no security api registered in the AK dictionary  
  IF g_record.SUBINVENTORY IS NOT NULL THEN
    l_attr:=l_attr||' 4';
    -- Validate defaulted value if not null
    IF OE_VALIDATE.SUBINVENTORY(g_record.SUBINVENTORY) THEN  
      -- There is no dependent api registered in the AK dictionary  
      NULL;
      l_attr:=l_attr||' 5';
    ELSE
      g_record.SUBINVENTORY := NULL;
      l_attr:=l_attr||' 6';
    END IF;
  END IF;
END IF;
l_attr:= 'TASK_ID';
 
IF g_record.TASK_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.TASK_ID := NULL;
END IF;
l_attr:= 'TAX_EXEMPT_NUMBER';
 
IF g_record.TAX_EXEMPT_NUMBER = FND_API.G_MISS_CHAR THEN
--  Get the defaulting api registered in the AK AND default
    l_attr:=l_attr||' 1';
    g_record.TAX_EXEMPT_NUMBER := ONT_D2_TAX_EXEMPT_NUMBER.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.tax_exempt_number, p_in_old_rec.tax_exempt_number) THEN
      IF OE_LINE_SECURITY.TAX_EXEMPT_NUMBER(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
    g_record.TAX_EXEMPT_REASON_CODE := ONT_D2_TAX_EXEMPT_REASON_CO.Get_Default_Value(g_record);
    l_attr:=l_attr||' 2';
  -- For UPDATE operations, check security if new defaulted value is not equal to old value
  IF g_record.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_attr:=l_attr||' 3';
    IF NOT OE_GLOBALS.Equal(g_record.tax_exempt_reason_code, p_in_old_rec.tax_exempt_reason_code) THEN
      IF OE_LINE_SECURITY.TAX_EXEMPT_REASON(p_record => g_record, x_on_operation_action	=> l_action) = OE_PC_GLOBALS.YES THEN
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
l_attr:= 'TAX_RATE';
 
IF g_record.TAX_RATE = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.TAX_RATE := NULL;
END IF;
l_attr:= 'TAX_VALUE';
 
IF g_record.TAX_VALUE = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.TAX_VALUE := NULL;
END IF;
l_attr:= 'TOP_MODEL_LINE_ID';
 
IF g_record.TOP_MODEL_LINE_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.TOP_MODEL_LINE_ID := NULL;
END IF;
l_attr:= 'TRANSACTION_PHASE_CODE';
 
IF g_record.TRANSACTION_PHASE_CODE = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.TRANSACTION_PHASE_CODE := NULL;
END IF;
l_attr:= 'UNIT_LIST_PERCENT';
 
IF g_record.UNIT_LIST_PERCENT = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.UNIT_LIST_PERCENT := NULL;
END IF;
l_attr:= 'UNIT_LIST_PRICE';
 
IF g_record.UNIT_LIST_PRICE = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.UNIT_LIST_PRICE := NULL;
END IF;
l_attr:= 'UNIT_PERCENT_BASE_PRICE';
 
IF g_record.UNIT_PERCENT_BASE_PRICE = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.UNIT_PERCENT_BASE_PRICE := NULL;
END IF;
l_attr:= 'UNIT_SELLING_PERCENT';
 
IF g_record.UNIT_SELLING_PERCENT = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.UNIT_SELLING_PERCENT := NULL;
END IF;
l_attr:= 'UNIT_SELLING_PRICE';
 
IF g_record.UNIT_SELLING_PRICE = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.UNIT_SELLING_PRICE := NULL;
END IF;
l_attr:= 'UPGRADED_FLAG';
 
IF g_record.UPGRADED_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.UPGRADED_FLAG := NULL;
END IF;
l_attr:= 'USER_ITEM_DESCRIPTION';
 
IF g_record.USER_ITEM_DESCRIPTION = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.USER_ITEM_DESCRIPTION := NULL;
END IF;
l_attr:= 'VEH_CUS_ITEM_CUM_KEY_ID';
 
IF g_record.VEH_CUS_ITEM_CUM_KEY_ID = FND_API.G_MISS_NUM THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.VEH_CUS_ITEM_CUM_KEY_ID := NULL;
END IF;
l_attr:= 'VISIBLE_DEMAND_FLAG';
 
IF g_record.VISIBLE_DEMAND_FLAG = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  g_record.VISIBLE_DEMAND_FLAG := NULL;
END IF;
 
    --  CHeck if there are any missing values for attrs
    --  If there are any missing call Default_Record again AND repeat till all the values 
    --  are defaulted or till the max. iterations are reached
 
     IF( 
      (g_record.LINE_TYPE_ID =FND_API.G_MISS_NUM)  
     OR (g_record.AGREEMENT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SOLD_TO_ORG_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SHIP_TO_ORG_ID = FND_API.G_MISS_NUM)  
     OR (g_record.INVOICE_TO_ORG_ID = FND_API.G_MISS_NUM)  
     OR (g_record.DELIVER_TO_ORG_ID = FND_API.G_MISS_NUM)  
     OR (g_record.REQUEST_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.SCHEDULE_SHIP_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.PROMISE_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.TAX_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.TAX_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.TAX_EXEMPT_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.SHIP_FROM_ORG_ID = FND_API.G_MISS_NUM)  
     OR (g_record.ATO_LINE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.ACCOUNTING_RULE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.ACCOUNTING_RULE_DURATION = FND_API.G_MISS_NUM)  
     OR (g_record.ACTUAL_ARRIVAL_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.ACTUAL_FULFILLMENT_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.ACTUAL_SHIPMENT_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.ARRIVAL_SET_ID = FND_API.G_MISS_NUM)  
     OR (g_record.ARRIVAL_SET = FND_API.G_MISS_CHAR)  
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
     OR (g_record.AUTHORIZED_TO_SHIP_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.AUTO_SELECTED_QUANTITY = FND_API.G_MISS_NUM)  
     OR (g_record.INVOICE_TO_CONTACT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.BOOKED_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.CALCULATE_PRICE_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.CANCELLED_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.CANCELLED_QUANTITY = FND_API.G_MISS_NUM)  
     OR (g_record.CHANGE_COMMENTS = FND_API.G_MISS_CHAR)  
     OR (g_record.CHANGE_REASON = FND_API.G_MISS_CHAR)  
     OR (g_record.CHARGE_PERIODICITY_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.COMMITMENT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.COMPONENT_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.COMPONENT_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.COMPONENT_SEQUENCE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.CONFIG_DISPLAY_SEQUENCE = FND_API.G_MISS_NUM)  
     OR (g_record.CONFIG_HEADER_ID = FND_API.G_MISS_NUM)  
     OR (g_record.CONFIG_REV_NBR = FND_API.G_MISS_NUM)  
     OR (g_record.CONFIGURATION_ID = FND_API.G_MISS_NUM)  
     OR (g_record.CONTEXT = FND_API.G_MISS_CHAR)  
     OR (g_record.CONTINGENCY_ID = FND_API.G_MISS_NUM)  
     OR (g_record.CREATED_BY = FND_API.G_MISS_NUM)  
     OR (g_record.CREATION_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.CREDIT_INVOICE_LINE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.IB_CURRENT_LOCATION = FND_API.G_MISS_CHAR)  
     OR (g_record.CUST_MODEL_SERIAL_NUMBER = FND_API.G_MISS_CHAR)  
     OR (g_record.CUSTOMER_DOCK_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.CUSTOMER_JOB = FND_API.G_MISS_CHAR)  
     OR (g_record.CUST_PO_NUMBER = FND_API.G_MISS_CHAR)  
     OR (g_record.CUSTOMER_LINE_NUMBER = FND_API.G_MISS_CHAR)  
     OR (g_record.CUSTOMER_PRODUCTION_LINE = FND_API.G_MISS_CHAR)  
     OR (g_record.CUST_PRODUCTION_SEQ_NUM = FND_API.G_MISS_CHAR)  
     OR (g_record.CUSTOMER_SHIPMENT_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.CUSTOMER_TRX_LINE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.DB_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.DELIVER_TO_CONTACT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.DELIVERY_LEAD_TIME = FND_API.G_MISS_NUM)  
     OR (g_record.DEMAND_BUCKET_TYPE_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.DEMAND_CLASS_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.DEP_PLAN_REQUIRED_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.EARLIEST_ACCEPTABLE_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.END_CUSTOMER_ID = FND_API.G_MISS_NUM)  
     OR (g_record.END_CUSTOMER_CONTACT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.END_CUSTOMER_SITE_USE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.END_ITEM_UNIT_NUMBER = FND_API.G_MISS_CHAR)  
     OR (g_record.EXPLOSION_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.FOB_POINT_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.FIRST_ACK_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.FIRST_ACK_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.FREIGHT_CARRIER_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.FREIGHT_TERMS_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.FULFILLED_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.FULFILLED_QUANTITY = FND_API.G_MISS_NUM)  
     OR (g_record.FULFILLMENT_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.FULFILLMENT_METHOD_CODE = FND_API.G_MISS_CHAR)  
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
     OR (g_record.PREFERRED_GRADE = FND_API.G_MISS_CHAR)  
     OR (g_record.HEADER_ID = FND_API.G_MISS_NUM)  
     OR (g_record.INDUSTRY_ATTRIBUTE16 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE17 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE18 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE19 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE20 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE21 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE22 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE23 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE24 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE25 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE26 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE27 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE28 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE29 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE30 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE1 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE10 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE11 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE12 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE13 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE14 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE15 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE2 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE3 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE4 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE5 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE6 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE7 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE8 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_ATTRIBUTE9 = FND_API.G_MISS_CHAR)  
     OR (g_record.INDUSTRY_CONTEXT = FND_API.G_MISS_CHAR)  
     OR (g_record.IB_INSTALLED_AT_LOCATION = FND_API.G_MISS_CHAR)  
     OR (g_record.INTERMED_SHIP_TO_CONTACT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.INTERMED_SHIP_TO_ORG_ID = FND_API.G_MISS_NUM)  
     OR (g_record.INVENTORY_ITEM_ID = FND_API.G_MISS_NUM)  
     OR (g_record.INVOICE_INTERFACE_STATUS_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.INVOICED_QUANTITY = FND_API.G_MISS_NUM)  
     OR (g_record.INVOICING_RULE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.ITEM_IDENTIFIER_TYPE = FND_API.G_MISS_CHAR)  
     OR (g_record.ITEM_REVISION = FND_API.G_MISS_CHAR)  
     OR (g_record.ITEM_TYPE_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.LAST_ACK_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.LAST_ACK_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.LAST_UPDATE_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.LAST_UPDATE_LOGIN = FND_API.G_MISS_NUM)  
     OR (g_record.LAST_UPDATED_BY = FND_API.G_MISS_NUM)  
     OR (g_record.LATEST_ACCEPTABLE_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.LINE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.LINE_CATEGORY_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.LINE_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.LINE_SET_ID = FND_API.G_MISS_NUM)  
     OR (g_record.LINK_TO_LINE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.MFG_COMPONENT_SEQUENCE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.MODEL_GROUP_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.OPEN_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.OPERATION = FND_API.G_MISS_CHAR)  
     OR (g_record.OPTION_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.OPTION_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.ORDER_FIRMED_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.ORDER_QUANTITY_UOM = FND_API.G_MISS_CHAR)  
     OR (g_record.ORDERED_ITEM = FND_API.G_MISS_CHAR)  
     OR (g_record.ORDERED_ITEM_ID = FND_API.G_MISS_NUM)  
     OR (g_record.ORDERED_QUANTITY = FND_API.G_MISS_NUM)  
     OR (g_record.ORG_ID = FND_API.G_MISS_NUM)  
     OR (g_record.ORIG_SYS_DOCUMENT_REF = FND_API.G_MISS_CHAR)  
     OR (g_record.ORIG_SYS_LINE_REF = FND_API.G_MISS_CHAR)  
     OR (g_record.OVER_SHIP_REASON_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.OVER_SHIP_RESOLVED_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.IB_OWNER = FND_API.G_MISS_CHAR)  
     OR (g_record.PACKING_INSTRUCTIONS = FND_API.G_MISS_CHAR)  
     OR (g_record.PARTY_TYPE = FND_API.G_MISS_CHAR)  
     OR (g_record.PAYMENT_TERM_ID = FND_API.G_MISS_NUM)  
     OR (g_record.PLANNING_PRIORITY = FND_API.G_MISS_NUM)  
     OR (g_record.PRICE_LIST_ID = FND_API.G_MISS_NUM)  
     OR (g_record.PRICING_ATTRIBUTE1 = FND_API.G_MISS_CHAR)  
     OR (g_record.PRICING_ATTRIBUTE10 = FND_API.G_MISS_CHAR)  
     OR (g_record.PRICING_ATTRIBUTE2 = FND_API.G_MISS_CHAR)  
     OR (g_record.PRICING_ATTRIBUTE3 = FND_API.G_MISS_CHAR)  
     OR (g_record.PRICING_ATTRIBUTE4 = FND_API.G_MISS_CHAR)  
     OR (g_record.PRICING_ATTRIBUTE5 = FND_API.G_MISS_CHAR)  
     OR (g_record.PRICING_ATTRIBUTE6 = FND_API.G_MISS_CHAR)  
     OR (g_record.PRICING_ATTRIBUTE7 = FND_API.G_MISS_CHAR)  
     OR (g_record.PRICING_ATTRIBUTE8 = FND_API.G_MISS_CHAR)  
     OR (g_record.PRICING_ATTRIBUTE9 = FND_API.G_MISS_CHAR)  
     OR (g_record.PRICING_CONTEXT = FND_API.G_MISS_CHAR)  
     OR (g_record.PRICING_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.PRICING_QUANTITY = FND_API.G_MISS_NUM)  
     OR (g_record.PRICING_QUANTITY_UOM = FND_API.G_MISS_CHAR)  
     OR (g_record.PROGRAM_ID = FND_API.G_MISS_NUM)  
     OR (g_record.PROGRAM_APPLICATION_ID = FND_API.G_MISS_NUM)  
     OR (g_record.PROGRAM_UPDATE_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.PROJECT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.REFERENCE_CUSTOMER_TRX_LINE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.REFERENCE_HEADER_ID = FND_API.G_MISS_NUM)  
     OR (g_record.REFERENCE_LINE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.REFERENCE_TYPE = FND_API.G_MISS_CHAR)  
     OR (g_record.REQUEST_ID = FND_API.G_MISS_NUM)  
     OR (g_record.RESERVED_QUANTITY = FND_API.G_MISS_NUM)  
     OR (g_record.RETROBILL_REQUEST_ID = FND_API.G_MISS_NUM)  
     OR (g_record.RETURN_ATTRIBUTE1 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_ATTRIBUTE10 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_ATTRIBUTE11 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_ATTRIBUTE12 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_ATTRIBUTE13 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_ATTRIBUTE14 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_ATTRIBUTE15 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_ATTRIBUTE2 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_ATTRIBUTE3 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_ATTRIBUTE4 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_ATTRIBUTE5 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_ATTRIBUTE6 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_ATTRIBUTE7 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_ATTRIBUTE8 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_ATTRIBUTE9 = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_CONTEXT = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_REASON_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.RETURN_STATUS = FND_API.G_MISS_CHAR)  
     OR (g_record.REVENUE_AMOUNT = FND_API.G_MISS_NUM)  
     OR (g_record.REVREC_EXPIRATION_DAYS = FND_API.G_MISS_NUM)  
     OR (g_record.RLA_SCHEDULE_TYPE_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.BLANKET_LINE_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.BLANKET_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.BLANKET_VERSION_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.SALESREP_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SCHEDULE_ACTION_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.SCHEDULE_ARRIVAL_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.SCHEDULE_STATUS_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.CANCELLED_QUANTITY2 = FND_API.G_MISS_NUM)  
     OR (g_record.FULFILLED_QUANTITY2 = FND_API.G_MISS_NUM)  
     OR (g_record.ORDERED_QUANTITY2 = FND_API.G_MISS_NUM)  
     OR (g_record.SHIPPED_QUANTITY2 = FND_API.G_MISS_NUM)  
     OR (g_record.SHIPPING_QUANTITY2 = FND_API.G_MISS_NUM)  
     OR (g_record.SHIPPING_QUANTITY_UOM2 = FND_API.G_MISS_CHAR)  
     OR (g_record.ORDERED_QUANTITY_UOM2 = FND_API.G_MISS_CHAR)  
     OR (g_record.SERVICE_COTERMINATE_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.SERVICE_DURATION = FND_API.G_MISS_NUM)  
     OR (g_record.SERVICE_END_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.SERVICE_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.SERVICE_PERIOD = FND_API.G_MISS_CHAR)  
     OR (g_record.SERVICE_REFERENCE_LINE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SERVICE_REFERENCE_SYSTEM_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SERVICE_REFERENCE_TYPE_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.SERVICE_START_DATE = FND_API.G_MISS_DATE)  
     OR (g_record.SERVICE_TXN_COMMENTS = FND_API.G_MISS_CHAR)  
     OR (g_record.SERVICE_TXN_REASON_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.SHIP_MODEL_COMPLETE_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.SHIP_SET_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SHIP_SET = FND_API.G_MISS_CHAR)  
     OR (g_record.SHIP_TO_CONTACT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SHIP_TOLERANCE_ABOVE = FND_API.G_MISS_NUM)  
     OR (g_record.SHIP_TOLERANCE_BELOW = FND_API.G_MISS_NUM)  
     OR (g_record.SHIPMENT_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.SHIPMENT_PRIORITY_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.SHIPPED_QUANTITY = FND_API.G_MISS_NUM)  
     OR (g_record.SHIPPING_INSTRUCTIONS = FND_API.G_MISS_CHAR)  
     OR (g_record.SHIPPING_INTERFACED_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.SHIPPING_METHOD_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.SHIPPING_QUANTITY = FND_API.G_MISS_NUM)  
     OR (g_record.SHIPPING_QUANTITY_UOM = FND_API.G_MISS_CHAR)  
     OR (g_record.SORT_ORDER = FND_API.G_MISS_CHAR)  
     OR (g_record.SOURCE_DOCUMENT_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SOURCE_DOCUMENT_LINE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SOURCE_DOCUMENT_TYPE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SOURCE_DOCUMENT_VERSION_NUMBER = FND_API.G_MISS_NUM)  
     OR (g_record.SOURCE_TYPE_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.SPLIT_BY = FND_API.G_MISS_CHAR)  
     OR (g_record.SPLIT_FROM_LINE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.SUBINVENTORY = FND_API.G_MISS_CHAR)  
     OR (g_record.TASK_ID = FND_API.G_MISS_NUM)  
     OR (g_record.TAX_EXEMPT_NUMBER = FND_API.G_MISS_CHAR)  
     OR (g_record.TAX_EXEMPT_REASON_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.TAX_POINT_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.TAX_RATE = FND_API.G_MISS_NUM)  
     OR (g_record.TAX_VALUE = FND_API.G_MISS_NUM)  
     OR (g_record.TOP_MODEL_LINE_ID = FND_API.G_MISS_NUM)  
     OR (g_record.TRANSACTION_PHASE_CODE = FND_API.G_MISS_CHAR)  
     OR (g_record.UNIT_LIST_PERCENT = FND_API.G_MISS_NUM)  
     OR (g_record.UNIT_LIST_PRICE = FND_API.G_MISS_NUM)  
     OR (g_record.UNIT_PERCENT_BASE_PRICE = FND_API.G_MISS_NUM)  
     OR (g_record.UNIT_SELLING_PERCENT = FND_API.G_MISS_NUM)  
     OR (g_record.UNIT_SELLING_PRICE = FND_API.G_MISS_NUM)  
     OR (g_record.UPGRADED_FLAG = FND_API.G_MISS_CHAR)  
     OR (g_record.USER_ITEM_DESCRIPTION = FND_API.G_MISS_CHAR)  
     OR (g_record.VEH_CUS_ITEM_CUM_KEY_ID = FND_API.G_MISS_NUM)  
     OR (g_record.VISIBLE_DEMAND_FLAG = FND_API.G_MISS_CHAR)  
    ) THEN   
    ONT_LINE_Def_Hdlr.Default_Record(
     p_x_rec => g_record,
     p_initial_rec => p_initial_rec,
     p_in_old_rec => p_in_old_rec,
      p_iteration => p_iteration+1 );
    END IF;
 
IF p_iteration =1 THEN
OE_LINE_Security.G_Is_Caller_Defaulting := 'N';
  p_x_rec := g_record;
END IF;
 
oe_debug_pub.ADD('Exit ONT_LINE_Def_Hdlr.Default_Record');
 
EXCEPTION
 
  WHEN FND_API.G_EXC_ERROR THEN
    OE_LINE_Security.G_Is_Caller_Defaulting := 'N';
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    OE_LINE_Security.G_Is_Caller_Defaulting := 'N';
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      ,'Default_Record: '||l_attr
      );
    END IF;
    OE_LINE_Security.G_Is_Caller_Defaulting := 'N';
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 
END Default_Record;
 
END ONT_LINE_Def_Hdlr;

/
