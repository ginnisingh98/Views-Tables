--------------------------------------------------------
--  DDL for Package Body OE_LINE_UTIL_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_UTIL_EXT" AS
/* $Header: OEXULXTB.pls 120.4 2006/04/17 03:45:25 pviprana noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Line_Util_Ext';

-- LOCAL Procedures
-- Clear_Dependents

-- 13-DEC-2001:
-- Introduced new OUT parameter x_dep_attr_exists. This parameter
-- is set to 'Y' if at least one dependent attribute is set to missing
-- in this procedure.
PROCEDURE Clear_Dependents
	(p_src_attr_tbl		IN  OE_GLOBALS.NUMBER_Tbl_Type
	,p_initial_line_rec		IN OE_AK_ORDER_LINES_V%ROWTYPE
	,p_old_line_rec		IN OE_AK_ORDER_LINES_V%ROWTYPE
	,p_x_line_rec		     IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
        ,x_dep_attr_exists      OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_dep_attr_tbl          OE_GLOBALS.NUMBER_Tbl_Type;

   PROCEDURE ACCOUNTING_RULE IS
   BEGIN
   IF (p_initial_line_rec.ACCOUNTING_RULE_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.ACCOUNTING_RULE_ID, p_old_line_rec.ACCOUNTING_RULE_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.ACCOUNTING_RULE_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.ACCOUNTING_RULE_ID := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END ACCOUNTING_RULE;

   PROCEDURE ACCOUNTING_RULE_DURATION IS
   BEGIN
   IF (p_initial_line_rec.ACCOUNTING_RULE_DURATION = FND_API.G_MISS_NUM OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.ACCOUNTING_RULE_DURATION, p_old_line_rec.ACCOUNTING_RULE_DURATION)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.ACCOUNTING_RULE_DURATION IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.ACCOUNTING_RULE_DURATION := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END ACCOUNTING_RULE_DURATION;

   PROCEDURE AGREEMENT IS
   BEGIN
   IF (p_initial_line_rec.AGREEMENT_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.AGREEMENT_ID, p_old_line_rec.AGREEMENT_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.AGREEMENT_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.AGREEMENT_ID := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END AGREEMENT;

   PROCEDURE ATO_LINE IS
   BEGIN
   IF (p_initial_line_rec.ATO_LINE_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.ATO_LINE_ID, p_old_line_rec.ATO_LINE_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.ATO_LINE_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.ATO_LINE_ID := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END ATO_LINE;

   -- For bug 3571400
   PROCEDURE BLANKET_NUMBER IS
   BEGIN
   IF (p_initial_line_rec.blanket_number = FND_API.G_MISS_NUM OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.blanket_number, p_old_line_rec.blanket_number)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.blanket_number IS NOT NULL))
       )
   THEN
       p_x_line_rec.blanket_number := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END BLANKET_NUMBER;

   PROCEDURE BLANKET_LINE_NUMBER IS
   BEGIN
   IF (p_initial_line_rec.blanket_line_number = FND_API.G_MISS_NUM OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.blanket_line_number, p_old_line_rec.blanket_line_number)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.blanket_line_number IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.blanket_line_number := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END BLANKET_LINE_NUMBER;

   PROCEDURE BLANKET_VERSION_NUMBER IS
   BEGIN
   IF (p_initial_line_rec.blanket_version_number = FND_API.G_MISS_NUM OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.blanket_version_number, p_old_line_rec.blanket_version_number)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.blanket_version_number IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.blanket_version_number := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';

   END IF;
   END BLANKET_VERSION_NUMBER;

   PROCEDURE COMMITMENT IS
   BEGIN
   IF (p_initial_line_rec.COMMITMENT_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.COMMITMENT_ID, p_old_line_rec.COMMITMENT_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.COMMITMENT_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.COMMITMENT_ID := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END COMMITMENT;


   PROCEDURE COMPONENT IS
   BEGIN
   IF (p_initial_line_rec.COMPONENT_CODE = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.COMPONENT_CODE, p_old_line_rec.COMPONENT_CODE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.COMPONENT_CODE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.COMPONENT_CODE := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END COMPONENT;


   PROCEDURE COMPONENT_SEQUENCE IS
   BEGIN
   IF (p_initial_line_rec.COMPONENT_SEQUENCE_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.COMPONENT_SEQUENCE_ID, p_old_line_rec.COMPONENT_SEQUENCE_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.COMPONENT_SEQUENCE_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.COMPONENT_SEQUENCE_ID := FND_API.G_MISS_NUM;
       x_dep_attr_exists                  := 'Y';
   END IF;
   END COMPONENT_SEQUENCE;


   PROCEDURE SORT_ORDER IS
   BEGIN
   IF (p_initial_line_rec.SORT_ORDER = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.SORT_ORDER, p_old_line_rec.SORT_ORDER)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SORT_ORDER IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.SORT_ORDER := FND_API.G_MISS_CHAR;
       x_dep_attr_exists                  := 'Y';
   END IF;
   END SORT_ORDER;


   PROCEDURE SOURCE_TYPE IS
   BEGIN
   IF (p_initial_line_rec.SOURCE_TYPE_CODE = FND_API.G_MISS_CHAR OR
        (OE_GLOBALS.Equal(p_initial_line_rec.SOURCE_TYPE_CODE, p_old_line_rec.SOURCE_TYPE_CODE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SOURCE_TYPE_CODE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       -- ER: 1840556 - do not clear source type if this is a scheduling
       -- recursive call. Any updates due to scheduling (warehouse or item
       -- in case of item substitution) should not result in a change to
       -- the source type.

       --Bug4504362

         IF OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING = 'N' THEN
            RETURN;
         END IF;

       p_x_line_rec.SOURCE_TYPE_CODE := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END SOURCE_TYPE;

   PROCEDURE CUST_PO_NUMBER IS
   BEGIN
   IF (p_initial_line_rec.CUST_PO_NUMBER = FND_API.G_MISS_CHAR OR
        (OE_GLOBALS.Equal(p_initial_line_rec.CUST_PO_NUMBER, p_old_line_rec.CUST_PO_NUMBER)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.CUST_PO_NUMBER IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.CUST_PO_NUMBER := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END CUST_PO_NUMBER;

   PROCEDURE CUSTOMER_LINE_NUMBER IS  --For bug 2844285
   BEGIN
   IF (p_initial_line_rec.CUSTOMER_LINE_NUMBER = FND_API.G_MISS_CHAR OR
        (OE_GLOBALS.Equal(p_initial_line_rec.CUSTOMER_LINE_NUMBER, p_old_line_rec.CUSTOMER_LINE_NUMBER)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.CUSTOMER_LINE_NUMBER IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.CUSTOMER_LINE_NUMBER := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END CUSTOMER_LINE_NUMBER;

   PROCEDURE DELIVER_TO_CONTACT IS
   BEGIN
   IF (p_initial_line_rec.DELIVER_TO_CONTACT_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.DELIVER_TO_CONTACT_ID, p_old_line_rec.DELIVER_TO_CONTACT_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.DELIVER_TO_CONTACT_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
           p_x_line_rec.DELIVER_TO_CONTACT_ID := FND_API.G_MISS_NUM;
           x_dep_attr_exists               := 'Y';
       END IF;
   END IF;
   END DELIVER_TO_CONTACT;

   PROCEDURE DELIVER_TO_ORG IS
   BEGIN
   IF (p_initial_line_rec.DELIVER_TO_ORG_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.DELIVER_TO_ORG_ID, p_old_line_rec.DELIVER_TO_ORG_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.DELIVER_TO_ORG_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
           p_x_line_rec.DELIVER_TO_ORG_ID := FND_API.G_MISS_NUM;
           x_dep_attr_exists               := 'Y';
       END IF;
   END IF;
   END DELIVER_TO_ORG;

   PROCEDURE DEMAND_CLASS IS
   BEGIN
   IF (p_initial_line_rec.DEMAND_CLASS_CODE = FND_API.G_MISS_CHAR OR
        (OE_GLOBALS.Equal(p_initial_line_rec.DEMAND_CLASS_CODE, p_old_line_rec.DEMAND_CLASS_CODE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.DEMAND_CLASS_CODE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.DEMAND_CLASS_CODE := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END DEMAND_CLASS;

   PROCEDURE DEP_PLAN_REQUIRED IS
   BEGIN
   IF (p_initial_line_rec.DEP_PLAN_REQUIRED_FLAG = FND_API.G_MISS_CHAR OR
        (OE_GLOBALS.Equal(p_initial_line_rec.DEP_PLAN_REQUIRED_FLAG, p_old_line_rec.DEP_PLAN_REQUIRED_FLAG)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.DEP_PLAN_REQUIRED_FLAG IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.DEP_PLAN_REQUIRED_FLAG := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END DEP_PLAN_REQUIRED;

   PROCEDURE END_ITEM_UNIT_NUMBER IS
   BEGIN
   IF (p_initial_line_rec.END_ITEM_UNIT_NUMBER = FND_API.G_MISS_CHAR OR
        (OE_GLOBALS.Equal(p_initial_line_rec.END_ITEM_UNIT_NUMBER, p_old_line_rec.END_ITEM_UNIT_NUMBER)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.END_ITEM_UNIT_NUMBER IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.END_ITEM_UNIT_NUMBER := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END END_ITEM_UNIT_NUMBER;

   PROCEDURE FOB_POINT IS
   BEGIN
   IF (p_initial_line_rec.FOB_POINT_CODE = FND_API.G_MISS_CHAR OR
        (OE_GLOBALS.Equal(p_initial_line_rec.FOB_POINT_CODE, p_old_line_rec.FOB_POINT_CODE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.FOB_POINT_CODE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.FOB_POINT_CODE := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END FOB_POINT;

   PROCEDURE FREIGHT_TERMS IS
   BEGIN
   IF (p_initial_line_rec.FREIGHT_TERMS_CODE = FND_API.G_MISS_CHAR OR
        (OE_GLOBALS.Equal(p_initial_line_rec.FREIGHT_TERMS_CODE, p_old_line_rec.FREIGHT_TERMS_CODE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.FREIGHT_TERMS_CODE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.FREIGHT_TERMS_CODE := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END FREIGHT_TERMS;

   PROCEDURE INTERMED_SHIP_TO_CONTACT IS
   BEGIN
   IF (p_initial_line_rec.INTERMED_SHIP_TO_CONTACT_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.INTERMED_SHIP_TO_CONTACT_ID, p_old_line_rec.INTERMED_SHIP_TO_CONTACT_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.INTERMED_SHIP_TO_CONTACT_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.INTERMED_SHIP_TO_CONTACT_ID := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END INTERMED_SHIP_TO_CONTACT;

   PROCEDURE INTERMED_SHIP_TO_ORG IS
   BEGIN
   IF (p_initial_line_rec.INTERMED_SHIP_TO_ORG_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.INTERMED_SHIP_TO_ORG_ID, p_old_line_rec.INTERMED_SHIP_TO_ORG_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.INTERMED_SHIP_TO_ORG_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.INTERMED_SHIP_TO_ORG_ID := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END INTERMED_SHIP_TO_ORG;

   PROCEDURE INVOICE_TO_CONTACT IS
   BEGIN
   IF (p_initial_line_rec.INVOICE_TO_CONTACT_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.INVOICE_TO_CONTACT_ID, p_old_line_rec.INVOICE_TO_CONTACT_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.INVOICE_TO_CONTACT_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
           p_x_line_rec.INVOICE_TO_CONTACT_ID := FND_API.G_MISS_NUM;
           x_dep_attr_exists               := 'Y';
       END IF;
   END IF;
   END INVOICE_TO_CONTACT;

   PROCEDURE INVOICE_TO_ORG IS
   BEGIN
   IF (p_initial_line_rec.INVOICE_TO_ORG_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.INVOICE_TO_ORG_ID, p_old_line_rec.INVOICE_TO_ORG_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.INVOICE_TO_ORG_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
           p_x_line_rec.INVOICE_TO_ORG_ID := FND_API.G_MISS_NUM;
           x_dep_attr_exists := 'Y';
       END IF;
   END IF;
   END INVOICE_TO_ORG;

   PROCEDURE INVOICING_RULE IS
   BEGIN
   IF (p_initial_line_rec.INVOICING_RULE_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.INVOICING_RULE_ID, p_old_line_rec.INVOICING_RULE_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.INVOICING_RULE_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.INVOICING_RULE_ID := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END INVOICING_RULE;

   PROCEDURE ITEM_IDENTIFIER_TYPE IS
   BEGIN
   IF (p_initial_line_rec.ITEM_IDENTIFIER_TYPE = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.ITEM_IDENTIFIER_TYPE, p_old_line_rec.ITEM_IDENTIFIER_TYPE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.ITEM_IDENTIFIER_TYPE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
           p_x_line_rec.ITEM_IDENTIFIER_TYPE := FND_API.G_MISS_CHAR;
           x_dep_attr_exists               := 'Y';
       END IF;
   END IF;
   END ITEM_IDENTIFIER_TYPE;

   PROCEDURE ITEM_REVISION IS    -- For bug 2951575
   BEGIN
   IF (p_initial_line_rec.ITEM_REVISION = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.ITEM_REVISION, p_old_line_rec.ITEM_REVISION)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.ITEM_REVISION IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
      p_x_line_rec.ITEM_REVISION := FND_API.G_MISS_CHAR;
      x_dep_attr_exists               := 'Y';
   END IF;
   END ITEM_REVISION;

   PROCEDURE ITEM_TYPE IS
   BEGIN
   IF (p_initial_line_rec.ITEM_TYPE_CODE = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.ITEM_TYPE_CODE, p_old_line_rec.ITEM_TYPE_CODE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.ITEM_TYPE_CODE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
           p_x_line_rec.ITEM_TYPE_CODE := FND_API.G_MISS_CHAR;
           x_dep_attr_exists               := 'Y';
       END IF;
   END IF;
   END ITEM_TYPE;

   PROCEDURE LINE_TYPE IS
   BEGIN
   IF (p_initial_line_rec.LINE_TYPE_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.LINE_TYPE_ID, p_old_line_rec.LINE_TYPE_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.LINE_TYPE_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.LINE_TYPE_ID := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END LINE_TYPE;

   PROCEDURE LINE_CATEGORY IS
   BEGIN
   IF (p_initial_line_rec.LINE_CATEGORY_CODE = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.LINE_CATEGORY_CODE, p_old_line_rec.LINE_CATEGORY_CODE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.LINE_CATEGORY_CODE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.LINE_CATEGORY_CODE := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END LINE_CATEGORY;


   PROCEDURE OPTION_NUMBER IS
   BEGIN
   IF (p_initial_line_rec.OPTION_NUMBER = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.OPTION_NUMBER, p_old_line_rec.OPTION_NUMBER)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.OPTION_NUMBER IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.OPTION_NUMBER := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END OPTION_NUMBER;

   PROCEDURE ORDERED_ITEM IS
   BEGIN
   IF (p_initial_line_rec.ORDERED_ITEM_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.ORDERED_ITEM_ID, p_old_line_rec.ORDERED_ITEM_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.ORDERED_ITEM_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
           p_x_line_rec.ORDERED_ITEM_ID := FND_API.G_MISS_NUM;
           x_dep_attr_exists := 'Y';
       END IF;
   END IF;
   END ORDERED_ITEM;

   PROCEDURE ORDER_QUANTITY_UOM IS
   BEGIN
   IF (p_initial_line_rec.ORDER_QUANTITY_UOM = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.ORDER_QUANTITY_UOM, p_old_line_rec.ORDER_QUANTITY_UOM)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.ORDER_QUANTITY_UOM IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
       --  do not clear uom  if this is a scheduling
       -- recursive call. Any updates due to scheduling (warehouse or item
       -- in case of item substitution) should not result in a change to
       -- the uom.

       --4504362

           IF OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING = 'N' THEN
              RETURN;
           END IF;

         -- bug 2454963, do not clear for pricing call
         IF (nvl(OE_GLOBALS.G_PRICING_RECURSION,'N') <> 'Y') THEN
           p_x_line_rec.ORDER_QUANTITY_UOM := FND_API.G_MISS_CHAR;
         END IF;
       x_dep_attr_exists               := 'Y';
       END IF;
   END IF;
   END ORDER_QUANTITY_UOM;

   /* OPM 02/JUN/00 BEGIN
   =====================*/
   PROCEDURE ORDERED_QUANTITY_UOM2 IS
   BEGIN
   IF (p_initial_line_rec.ORDERED_QUANTITY_UOM2 = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.ORDERED_QUANTITY_UOM2, p_old_line_rec.ORDERED_QUANTITY_UOM2)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.ORDERED_QUANTITY_UOM2 IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
           p_x_line_rec.ORDERED_QUANTITY_UOM2 := FND_API.G_MISS_CHAR;
           x_dep_attr_exists := 'Y';
       END IF;
   END IF;
   END ORDERED_QUANTITY_UOM2;
   /* OPM 02/JUN/00 END
   ===================*/

   -- OPM Bug3016136
   PROCEDURE ORDERED_QUANTITY2 IS
   BEGIN
   OE_DEBUG_PUB.add('OPM Procedure ordered_quantity2',1);
   IF (p_initial_line_rec.ORDERED_QUANTITY2 = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.ORDERED_QUANTITY2, p_old_line_rec.ORDERED_QUANTITY2)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.ORDERED_QUANTITY2 IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
           p_x_line_rec.ORDERED_QUANTITY2 := FND_API.G_MISS_NUM;
           x_dep_attr_exists := 'Y';
       END IF;
   END IF;
   END ORDERED_QUANTITY2;
   -- OPM End Bug3016136


   PROCEDURE PAYMENT_TERM IS
   BEGIN
   IF (p_initial_line_rec.PAYMENT_TERM_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.PAYMENT_TERM_ID, p_old_line_rec.PAYMENT_TERM_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.PAYMENT_TERM_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.PAYMENT_TERM_ID := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END PAYMENT_TERM;

   /* OPM 02/JUN/00 BEGIN
   =====================*/
   PROCEDURE PREFERRED_GRADE IS
   BEGIN
   IF (p_initial_line_rec.PREFERRED_GRADE = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.PREFERRED_GRADE, p_old_line_rec.PREFERRED_GRADE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.PREFERRED_GRADE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.PREFERRED_GRADE := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END PREFERRED_GRADE;
   /* OPM 02/JUN/00 END
   ===================*/

   PROCEDURE PRICE_LIST IS
   BEGIN
   IF (p_initial_line_rec.PRICE_LIST_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.PRICE_LIST_ID, p_old_line_rec.PRICE_LIST_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.PRICE_LIST_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
        --retro{For a retrobill line if price increases the line category and line_type are changed.
        --This causes the price list also to be defaulted, but it shouldn't happen,
        --So the following if with null for retrobill lines
          IF( p_x_line_rec.retrobill_request_id is NOT NULL) THEN
              oe_debug_pub.add('Retro:Pricelist not defaulted');
              oe_debug_pub.add('Pricelist Id:'||p_x_line_rec.PRICE_LIST_ID);
          Else
           oe_debug_pub.add('Retro:Reseting price list to missnum');
           p_x_line_rec.PRICE_LIST_ID := FND_API.G_MISS_NUM;
           x_dep_attr_exists               := 'Y';
          END IF; --End of Retrobill check
       END IF;
   END IF;
   END PRICE_LIST;

   PROCEDURE PRICE_REQUEST_CODE IS -- PROMOTIONS SEP/01
   BEGIN
   IF (p_initial_line_rec.PRICE_REQUEST_CODE = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.PRICE_REQUEST_CODE, p_old_line_rec.PRICE_REQUEST_CODE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.PRICE_REQUEST_CODE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.PRICE_REQUEST_CODE := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END PRICE_REQUEST_CODE;

   PROCEDURE PRICING_QUANTITY_UOM IS
   BEGIN
   IF (p_initial_line_rec.PRICING_QUANTITY_UOM = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.PRICING_QUANTITY_UOM, p_old_line_rec.PRICING_QUANTITY_UOM)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.PRICING_QUANTITY_UOM IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN

       -- bug 2454963, do not clear for pricing call
       IF (nvl(OE_GLOBALS.G_PRICING_RECURSION,'N') <> 'Y') THEN
         p_x_line_rec.PRICING_QUANTITY_UOM := FND_API.G_MISS_CHAR;
       END IF;
       x_dep_attr_exists               := 'Y';
   END IF;
   END PRICING_QUANTITY_UOM;

   PROCEDURE PROMISE_DATE IS
   BEGIN
   IF (p_initial_line_rec.PROMISE_DATE = FND_API.G_MISS_DATE OR
        (OE_GLOBALS.Equal(p_initial_line_rec.PROMISE_DATE, p_old_line_rec.PROMISE_DATE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.PROMISE_DATE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.PROMISE_DATE := FND_API.G_MISS_DATE;
       x_dep_attr_exists               := 'Y';
   END IF;
   END PROMISE_DATE;

   PROCEDURE REQUEST_DATE IS
   BEGIN
   IF (p_initial_line_rec.REQUEST_DATE = FND_API.G_MISS_DATE OR
        (OE_GLOBALS.Equal(p_initial_line_rec.REQUEST_DATE, p_old_line_rec.REQUEST_DATE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.REQUEST_DATE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
                -- Let us not clear request_date for an ATO option or SMC
                -- PTO option

                IF (p_x_line_rec.ato_line_id is not null AND
                    p_x_line_rec.ato_line_id <> FND_API.G_MISS_NUM AND
                    p_x_line_rec.ato_line_id <> p_x_line_rec.line_id) OR
                   (p_x_line_rec.top_model_line_id is not null AND
                    p_x_line_rec.top_model_line_id <> FND_API.G_MISS_NUM AND
                    p_x_line_rec.top_model_line_id <> p_x_line_rec.line_id AND
                    p_x_line_rec.ship_model_complete_flag = 'Y') THEN
                    null;
                ELSE
                    p_x_line_rec.REQUEST_DATE := FND_API.G_MISS_DATE;
                    x_dep_attr_exists               := 'Y';
                END IF;

   END IF;
   END REQUEST_DATE;

   PROCEDURE SALESREP IS
   BEGIN
   IF (p_initial_line_rec.SALESREP_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.SALESREP_ID, p_old_line_rec.SALESREP_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SALESREP_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.SALESREP_ID := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END SALESREP;

   PROCEDURE SCHEDULE_SHIP_DATE IS
   BEGIN
   IF (p_initial_line_rec.SCHEDULE_SHIP_DATE = FND_API.G_MISS_DATE OR
        (OE_GLOBALS.Equal(p_initial_line_rec.SCHEDULE_SHIP_DATE, p_old_line_rec.SCHEDULE_SHIP_DATE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SCHEDULE_SHIP_DATE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.SCHEDULE_SHIP_DATE := FND_API.G_MISS_DATE;
       x_dep_attr_exists               := 'Y';
   END IF;
   END SCHEDULE_SHIP_DATE;

   PROCEDURE SHIPMENT_NUMBER IS
   BEGIN
   IF ((p_initial_line_rec.SHIPMENT_NUMBER = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.SHIPMENT_NUMBER, p_old_line_rec.SHIPMENT_NUMBER)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SHIPMENT_NUMBER IS NOT NULL)))
          AND
         (p_initial_line_rec.SPLIT_FROM_LINE_ID is null OR p_initial_line_rec.SPLIT_FROM_LINE_ID= FND_API.G_MISS_NUM)
        ) --  the second AND condition above added to fix 3098878
         -- Added the last and condition for bug 3209104
THEN
       p_x_line_rec.SHIPMENT_NUMBER := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END SHIPMENT_NUMBER;

   PROCEDURE SHIPMENT_PRIORITY IS
   BEGIN
   IF (p_initial_line_rec.SHIPMENT_PRIORITY_CODE = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.SHIPMENT_PRIORITY_CODE, p_old_line_rec.SHIPMENT_PRIORITY_CODE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SHIPMENT_PRIORITY_CODE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.SHIPMENT_PRIORITY_CODE := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END SHIPMENT_PRIORITY;

   PROCEDURE SHIPPABLE IS
   BEGIN
   IF (p_initial_line_rec.SHIPPABLE_FLAG = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.SHIPPABLE_FLAG, p_old_line_rec.SHIPPABLE_FLAG)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SHIPPABLE_FLAG IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       /*
       ** Fix Bug # 2314689
       ** Shippable flag should not be cleared on a return
       ** line after it has been defaulted from reference line.
       */
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
          NULL;
       ELSE
          p_x_line_rec.SHIPPABLE_FLAG := FND_API.G_MISS_CHAR;
          x_dep_attr_exists               := 'Y';
       END IF;
   END IF;
   END SHIPPABLE;

   PROCEDURE SHIPPING_METHOD IS
   BEGIN
   IF (p_initial_line_rec.SHIPPING_METHOD_CODE = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.SHIPPING_METHOD_CODE, p_old_line_rec.SHIPPING_METHOD_CODE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SHIPPING_METHOD_CODE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.SHIPPING_METHOD_CODE := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END SHIPPING_METHOD;

   PROCEDURE SHIP_FROM_ORG IS
   BEGIN
   IF (p_initial_line_rec.SHIP_FROM_ORG_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.SHIP_FROM_ORG_ID, p_old_line_rec.SHIP_FROM_ORG_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SHIP_FROM_ORG_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
                -- Let us not clear request_date for an ATO option or SMC
                -- PTO option

                IF (p_x_line_rec.ato_line_id is not null AND
                    p_x_line_rec.ato_line_id <> FND_API.G_MISS_NUM AND
                    p_x_line_rec.ato_line_id <> p_x_line_rec.line_id) OR
                   (p_x_line_rec.top_model_line_id is not null AND
                    p_x_line_rec.top_model_line_id <> FND_API.G_MISS_NUM AND
                    p_x_line_rec.top_model_line_id <> p_x_line_rec.line_id AND
                    p_x_line_rec.ship_model_complete_flag = 'Y') OR
                    (p_x_line_rec.ship_set_id is not null AND
                     p_x_line_rec.ship_set_id <> FND_API.G_MISS_NUM) OR
                    (p_x_line_rec.arrival_set_id is not null AND
                     p_x_line_rec.arrival_set_id <> FND_API.G_MISS_NUM)
                THEN
                    null;
                ELSE

       --  do not clear Ship_from type if this is a scheduling
       -- recursive call. Any updates due to scheduling (warehouse or item
       -- in case of item substitution) should not result in a change to
       -- the ship from.
                 --4504362

                    IF OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING = 'N' THEN
                       RETURN;
                    END IF;
                 p_x_line_rec.SHIP_FROM_ORG_ID := FND_API.G_MISS_NUM;
                 x_dep_attr_exists               := 'Y';
                END IF;

   END IF;
   END SHIP_FROM_ORG;

   PROCEDURE SUBINVENTORY IS
   BEGIN
   IF (p_initial_line_rec.SUBINVENTORY = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.SUBINVENTORY, p_old_line_rec.SUBINVENTORY)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SUBINVENTORY IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
		    p_x_line_rec.SUBINVENTORY := FND_API.G_MISS_CHAR;
                    x_dep_attr_exists               := 'Y';

   END IF;
   END SUBINVENTORY;


   PROCEDURE SHIP_TOLERANCE_ABOVE IS
   BEGIN
   IF (p_initial_line_rec.SHIP_TOLERANCE_ABOVE = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.SHIP_TOLERANCE_ABOVE, p_old_line_rec.SHIP_TOLERANCE_ABOVE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SHIP_TOLERANCE_ABOVE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.SHIP_TOLERANCE_ABOVE := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END SHIP_TOLERANCE_ABOVE;

   PROCEDURE SHIP_TOLERANCE_BELOW IS
   BEGIN
   IF (p_initial_line_rec.SHIP_TOLERANCE_BELOW = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.SHIP_TOLERANCE_BELOW, p_old_line_rec.SHIP_TOLERANCE_BELOW)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SHIP_TOLERANCE_BELOW IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.SHIP_TOLERANCE_BELOW := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END SHIP_TOLERANCE_BELOW;

   PROCEDURE SHIP_TO_CONTACT IS
   BEGIN
   IF (p_initial_line_rec.SHIP_TO_CONTACT_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.SHIP_TO_CONTACT_ID, p_old_line_rec.SHIP_TO_CONTACT_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SHIP_TO_CONTACT_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.SHIP_TO_CONTACT_ID := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END SHIP_TO_CONTACT;

   PROCEDURE SHIP_TO_ORG IS
   BEGIN
   IF (p_initial_line_rec.SHIP_TO_ORG_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.SHIP_TO_ORG_ID, p_old_line_rec.SHIP_TO_ORG_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SHIP_TO_ORG_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
                -- Let us not clear request_date for an ATO option or SMC
                -- PTO option
                -- Code commented for Bug-2543024
               /* IF (p_x_line_rec.ato_line_id is not null AND
                    p_x_line_rec.ato_line_id <> FND_API.G_MISS_NUM AND
                    p_x_line_rec.ato_line_id <> p_x_line_rec.line_id) OR
                   (p_x_line_rec.top_model_line_id is not null AND
                    p_x_line_rec.top_model_line_id <> FND_API.G_MISS_NUM AND
                    p_x_line_rec.top_model_line_id <> p_x_line_rec.line_id AND
                    p_x_line_rec.ship_model_complete_flag = 'Y') THEN

                    null;
                ELSE*/
                    p_x_line_rec.SHIP_TO_ORG_ID := FND_API.G_MISS_NUM;
                    x_dep_attr_exists               := 'Y';
               -- END IF;

   END IF;
   END SHIP_TO_ORG;

   PROCEDURE SOLD_TO_ORG IS
   BEGIN
   IF (p_initial_line_rec.SOLD_TO_ORG_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.SOLD_TO_ORG_ID, p_old_line_rec.SOLD_TO_ORG_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SOLD_TO_ORG_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
           p_x_line_rec.SOLD_TO_ORG_ID := FND_API.G_MISS_NUM;
           x_dep_attr_exists               := 'Y';
       END IF;
   END IF;
   END SOLD_TO_ORG;

   PROCEDURE TAX IS
   BEGIN
   IF (p_initial_line_rec.TAX_CODE = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.TAX_CODE, p_old_line_rec.TAX_CODE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.TAX_CODE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
    --  commenting the below code to address bug 2287931
    --    ELSIF p_x_line_rec.TAX_CODE IS NOT NULL THEN
    --      NULL;
       ELSE
           p_x_line_rec.TAX_CODE := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
       END IF;
   END IF;
   END TAX;

   PROCEDURE TAX_DATE IS
   BEGIN
   IF (p_initial_line_rec.TAX_DATE = FND_API.G_MISS_DATE OR
        (OE_GLOBALS.Equal(p_initial_line_rec.TAX_DATE, p_old_line_rec.TAX_DATE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.TAX_DATE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
           p_x_line_rec.TAX_DATE := FND_API.G_MISS_DATE;
       x_dep_attr_exists               := 'Y';
       END IF;
   END IF;
   END TAX_DATE;

   PROCEDURE TAX_EXEMPT IS
   BEGIN
   IF (p_initial_line_rec.TAX_EXEMPT_FLAG = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.TAX_EXEMPT_FLAG, p_old_line_rec.TAX_EXEMPT_FLAG)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.TAX_EXEMPT_FLAG IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
           p_x_line_rec.TAX_EXEMPT_FLAG := FND_API.G_MISS_CHAR;
           x_dep_attr_exists := 'Y';
       END IF;
   END IF;
   END TAX_EXEMPT;

   PROCEDURE TAX_EXEMPT_NUMBER IS
   BEGIN
   IF (p_initial_line_rec.TAX_EXEMPT_NUMBER = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.TAX_EXEMPT_NUMBER, p_old_line_rec.TAX_EXEMPT_NUMBER)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.TAX_EXEMPT_NUMBER IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
         -- Clear it only if the tax_exempt_flag = 'S' or
		 -- the tax_exempt_flag has changed.
           IF NOT OE_GLOBAlS.Equal(p_x_line_rec.TAX_EXEMPT_FLAG
							   , p_old_line_rec.TAX_EXEMPT_FLAG)
              OR  (p_old_line_rec.TAX_EXEMPT_FLAG = 'S' AND
              p_x_line_rec.TAX_EXEMPT_FLAG = 'S' ) THEN

               p_x_line_rec.TAX_EXEMPT_NUMBER := FND_API.G_MISS_CHAR;
               x_dep_attr_exists               := 'Y';
           END IF;
       END IF;

   END IF;
   END TAX_EXEMPT_NUMBER;

   PROCEDURE TAX_EXEMPT_REASON IS
   BEGIN
   IF (p_initial_line_rec.TAX_EXEMPT_REASON_CODE = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.TAX_EXEMPT_REASON_CODE, p_old_line_rec.TAX_EXEMPT_REASON_CODE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.TAX_EXEMPT_REASON_CODE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       IF p_x_line_rec.reference_line_id IS NOT NULL AND
          p_x_line_rec.reference_line_id <> FND_API.G_MISS_NUM AND
          p_x_line_rec.line_category_code = 'RETURN'
       THEN
           NULL;
       ELSE
          -- Clear it only if the tax_exempt_flag = 'S' or
		  -- the tax_exempt_flag has changed.

           IF NOT OE_GLOBAlS.Equal(p_x_line_rec.TAX_EXEMPT_FLAG
							   , p_old_line_rec.TAX_EXEMPT_FLAG)
           OR  (p_old_line_rec.TAX_EXEMPT_FLAG = 'S' AND
           p_x_line_rec.TAX_EXEMPT_FLAG = 'S' ) THEN

               p_x_line_rec.TAX_EXEMPT_REASON_CODE := FND_API.G_MISS_CHAR;
               x_dep_attr_exists               := 'Y';
           END IF;

       END IF;

   END IF;
   END TAX_EXEMPT_REASON;

   PROCEDURE TOP_MODEL_LINE IS
   BEGIN
   IF (p_initial_line_rec.TOP_MODEL_LINE_ID = FND_API.G_MISS_NUM OR
        (OE_GLOBALS.Equal(p_initial_line_rec.TOP_MODEL_LINE_ID, p_old_line_rec.TOP_MODEL_LINE_ID)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.TOP_MODEL_LINE_ID IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.TOP_MODEL_LINE_ID := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END TOP_MODEL_LINE;

   PROCEDURE SERVICE_START_DATE IS
   BEGIN
   IF (p_initial_line_rec.SERVICE_START_DATE = FND_API.G_MISS_DATE OR
        (OE_GLOBALS.Equal(p_initial_line_rec.SERVICE_START_DATE, p_old_line_rec.SERVICE_START_DATE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SERVICE_START_DATE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.SERVICE_START_DATE := FND_API.G_MISS_DATE;
       x_dep_attr_exists               := 'Y';
   END IF;
   END SERVICE_START_DATE;

   PROCEDURE SERVICE_PERIOD IS
   BEGIN
   IF (p_initial_line_rec.SERVICE_PERIOD = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.SERVICE_PERIOD, p_old_line_rec.SERVICE_PERIOD)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SERVICE_PERIOD IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.SERVICE_PERIOD := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END SERVICE_PERIOD;

   -- bug4283037
   PROCEDURE SERVICE_DURATION IS
   BEGIN
   IF (p_initial_line_rec.SERVICE_DURATION = FND_API.G_MISS_NUM OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.SERVICE_DURATION, p_old_line_rec.SERVICE_DURATION)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SERVICE_DURATION IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.SERVICE_DURATION := FND_API.G_MISS_NUM;
       x_dep_attr_exists               := 'Y';
   END IF;
   END SERVICE_DURATION;

   PROCEDURE SERVICE_REFERENCE_TYPE_CODE IS
   BEGIN
   IF (p_initial_line_rec.SERVICE_REFERENCE_TYPE_CODE = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.SERVICE_REFERENCE_TYPE_CODE, p_old_line_rec.SERVICE_REFERENCE_TYPE_CODE)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SERVICE_REFERENCE_TYPE_CODE IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.SERVICE_REFERENCE_TYPE_CODE := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END SERVICE_REFERENCE_TYPE_CODE;

   PROCEDURE RETURN_CONTEXT IS
   BEGIN
   IF (p_initial_line_rec.RETURN_CONTEXT = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.RETURN_CONTEXT, p_old_line_rec.RETURN_CONTEXT)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.RETURN_CONTEXT IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
	oe_debug_pub.add('RMA:Clearing Return Attrs',1);

       p_x_line_rec.RETURN_CONTEXT := FND_API.G_MISS_CHAR;
       p_x_line_rec.RETURN_ATTRIBUTE1 := FND_API.G_MISS_CHAR;
       p_x_line_rec.RETURN_ATTRIBUTE2 := FND_API.G_MISS_CHAR;
       p_x_line_rec.reference_customer_trx_line_id := FND_API.G_MISS_NUM;
       p_x_line_rec.credit_invoice_line_id := FND_API.G_MISS_NUM;
       p_x_line_rec.reference_line_id := FND_API.G_MISS_NUM;
       p_x_line_rec.reference_header_id := FND_API.G_MISS_NUM;
   END IF;
   END RETURN_CONTEXT;

   -- Add for Bug 2766005
   PROCEDURE PACKING_INSTRUCTIONS IS
   BEGIN
   IF (p_initial_line_rec.PACKING_INSTRUCTIONS = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.PACKING_INSTRUCTIONS, p_old_line_rec.PACKING_INSTRUCTIONS)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.PACKING_INSTRUCTIONS IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.PACKING_INSTRUCTIONS := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END PACKING_INSTRUCTIONS;

   PROCEDURE SHIPPING_INSTRUCTIONS IS
   BEGIN
   IF (p_initial_line_rec.SHIPPING_INSTRUCTIONS = FND_API.G_MISS_CHAR OR
        (OE_GLOBAlS.Equal(p_initial_line_rec.SHIPPING_INSTRUCTIONS, p_old_line_rec.SHIPPING_INSTRUCTIONS)
          AND
        (p_old_line_rec.line_id IS NOT NULL OR p_initial_line_rec.SHIPPING_INSTRUCTIONS IS NOT NULL))
       ) --  the AND condition above added to fix 3098878
   THEN
       p_x_line_rec.SHIPPING_INSTRUCTIONS := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END SHIPPING_INSTRUCTIONS;
   -- End code for bug 2766005


   --distributed orders
PROCEDURE end_customer IS
   BEGIN
      IF (p_initial_line_rec.end_customer_id = FND_API.G_MISS_NUM
	  OR OE_GLOBALS.Equal(p_initial_line_rec.end_customer_id
			      , p_old_line_rec.end_customer_id ))
      THEN
	 p_x_line_rec.end_customer_id := FND_API.G_MISS_NUM;
	 x_dep_attr_exists                    := 'Y';
      END IF;
   END end_customer;

   PROCEDURE end_customer_contact IS
   BEGIN
      IF (p_initial_line_rec.end_customer_contact_id = FND_API.G_MISS_NUM
	  OR OE_GLOBALS.Equal(p_initial_line_rec.end_customer_contact_id
			      , p_old_line_rec.end_customer_contact_id ))
      THEN
	 p_x_line_rec.end_customer_contact_id := FND_API.G_MISS_NUM;
	 x_dep_attr_exists                    := 'Y';
      END IF;
   END end_customer_contact;

   PROCEDURE end_customer_site_use IS
   BEGIN
      IF (p_initial_line_rec.end_customer_site_use_id = FND_API.G_MISS_NUM
	  OR OE_GLOBALS.Equal(p_initial_line_rec.end_customer_site_use_id ,
			      p_old_line_rec.end_customer_site_use_id ))
      THEN
	 p_x_line_rec.end_customer_site_use_id := FND_API.G_MISS_NUM;
	 x_dep_attr_exists                 := 'Y';
      END IF;
   END end_customer_site_use;

--key Transaction Dates Project
   PROCEDURE order_firmed_date IS
   BEGIN
	IF(p_initial_line_rec.order_firmed_date = FND_API.G_MISS_DATE
	   OR OE_GLOBALS.Equal(p_initial_line_rec.order_firmed_date ,
			       p_old_line_rec.order_firmed_date ))
        THEN
	  p_x_line_rec.order_firmed_date := FND_API.G_MISS_DATE ;
          x_dep_attr_exists              := 'Y' ;
       END IF;
   END order_firmed_date ;
--end
--Rakesh
   PROCEDURE CHARGE_PERIODICITY IS
   BEGIN
   IF (p_initial_line_rec.charge_periodicity_code = FND_API.G_MISS_CHAR OR
        OE_GLOBAlS.Equal(p_initial_line_rec.charge_periodicity_code, p_old_line_rec.charge_periodicity_code))
   THEN
       p_x_line_rec.charge_periodicity_code := FND_API.G_MISS_CHAR;
       x_dep_attr_exists               := 'Y';
   END IF;
   END CHARGE_PERIODICITY;

BEGIN


     -- Bug 2337711: Initialize this OUT parameter to 'N', if a
     -- dependent attribute is cleared later, it will be re-set to 'Y'.
     -- Without this initialization, procedure Clear_Dep_And_Default
     -- was calling oe_default_line even if there weren't any dependents!
     x_dep_attr_exists := 'N';

     IF p_src_attr_tbl.COUNT > 0 THEN

        OE_Dependencies.Mark_Dependent
        (p_entity_code     => OE_GLOBALS.G_ENTITY_LINE,
        p_source_attr_tbl => p_src_attr_tbl,
        p_dep_attr_tbl    => l_dep_attr_tbl);

        FOR I IN 1..l_dep_attr_tbl.COUNT LOOP
		oe_debug_pub.add('Dep. attr :'||l_dep_attr_tbl(I));

		-- Bug fix 1131529: clear the dependent attribute ONLY if attribute
		-- did not have a user-specified value (attribute is not user specified
	  	-- if value is missing or old value is same as the initial value)

		-- Bug fix : create nested procedures per attribute and call the
		-- procedure if it is the dependent attribute.
		-- Also, eliminate unnecessary code for attribute that cannot be
		-- dependent attributes

            IF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_ACCOUNTING_RULE THEN
                ACCOUNTING_RULE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_ACCOUNTING_RULE_DURATION THEN
                ACCOUNTING_RULE_DURATION;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_AGREEMENT THEN
                AGREEMENT;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_ATO_LINE THEN
                ATO_LINE;
	    --For bug 3571400
            ELSIF  l_dep_attr_tbl(I) = OE_LINE_UTIL.G_BLANKET_NUMBER THEN
                BLANKET_NUMBER;
            ELSIF  l_dep_attr_tbl(I) = OE_LINE_UTIL.G_BLANKET_LINE_NUMBER THEN
                BLANKET_LINE_NUMBER;
            ELSIF  l_dep_attr_tbl(I) = OE_LINE_UTIL.G_BLANKET_VERSION_NUMBER THEN
                BLANKET_VERSION_NUMBER;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_COMMITMENT THEN
                COMMITMENT;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_COMPONENT THEN
                COMPONENT;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_COMPONENT_SEQUENCE THEN
                COMPONENT_SEQUENCE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SORT_ORDER THEN
                SORT_ORDER;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_CUST_PO_NUMBER THEN
                CUST_PO_NUMBER;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_CUSTOMER_LINE_NUMBER THEN   --For 2844285
                CUSTOMER_LINE_NUMBER;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_DELIVER_TO_CONTACT THEN
                DELIVER_TO_CONTACT;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_DELIVER_TO_ORG THEN
                DELIVER_TO_ORG;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_DEMAND_CLASS THEN
                DEMAND_CLASS;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_DEP_PLAN_REQUIRED THEN
                DEP_PLAN_REQUIRED;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_END_ITEM_UNIT_NUMBER THEN
                END_ITEM_UNIT_NUMBER;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_FOB_POINT THEN
                FOB_POINT;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_FREIGHT_TERMS THEN
                FREIGHT_TERMS;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_INTERMED_SHIP_TO_CONTACT THEN
                INTERMED_SHIP_TO_CONTACT;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_INTERMED_SHIP_TO_ORG THEN
                INTERMED_SHIP_TO_ORG;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_INVOICE_TO_CONTACT THEN
                INVOICE_TO_CONTACT;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_INVOICE_TO_ORG THEN
                INVOICE_TO_ORG;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_INVOICING_RULE THEN
                INVOICING_RULE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_ITEM_IDENTIFIER_TYPE THEN
                ITEM_IDENTIFIER_TYPE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_ITEM_REVISION THEN  -- For bug 2951575
                ITEM_REVISION;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_ITEM_TYPE THEN
                ITEM_TYPE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_LINE_TYPE THEN
                LINE_TYPE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_LINE_CATEGORY THEN
                LINE_CATEGORY;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_OPTION_NUMBER THEN
                OPTION_NUMBER;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_ORDERED_ITEM THEN
                ORDERED_ITEM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_ORDER_QUANTITY_UOM THEN
                ORDER_QUANTITY_UOM;
            -- OPM 02/JUN/00 BEGIN
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_ORDERED_QUANTITY_UOM2 THEN
                ORDERED_QUANTITY_UOM2;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_ORDERED_QUANTITY2 THEN
                ORDERED_QUANTITY2;    -- Bug3016136
            -- OPM 02/JUN/00 END
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_PAYMENT_TERM THEN
                PAYMENT_TERM;
            -- OPM 02/JUN/00 BEGIN
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_PREFERRED_GRADE THEN
                PREFERRED_GRADE;
            -- OPM 02/JUN/00 END
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_PRICE_LIST THEN
                PRICE_LIST;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_PRICE_REQUEST_CODE THEN
                PRICE_REQUEST_CODE;                 -- PROMOTIONS SEP/01
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_PRICING_QUANTITY_UOM THEN
                PRICING_QUANTITY_UOM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_PROMISE_DATE THEN
                PROMISE_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_REQUEST_DATE THEN
                REQUEST_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SALESREP THEN
                SALESREP;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SCHEDULE_SHIP_DATE THEN
                SCHEDULE_SHIP_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SHIPMENT_NUMBER THEN
                SHIPMENT_NUMBER;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SHIPMENT_PRIORITY THEN
                SHIPMENT_PRIORITY;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SHIPPABLE THEN
                SHIPPABLE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SHIPPING_METHOD THEN
                SHIPPING_METHOD;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SHIP_FROM_ORG THEN
                SHIP_FROM_ORG;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SUBINVENTORY THEN
                SUBINVENTORY;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SHIP_TOLERANCE_ABOVE THEN
                SHIP_TOLERANCE_ABOVE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SHIP_TOLERANCE_BELOW THEN
                SHIP_TOLERANCE_BELOW;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SHIP_TO_CONTACT THEN
                SHIP_TO_CONTACT;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SHIP_TO_ORG THEN
                SHIP_TO_ORG;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SOLD_TO_ORG THEN
                SOLD_TO_ORG;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_TAX THEN
                TAX;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_TAX_DATE THEN
                TAX_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_TAX_EXEMPT THEN
                TAX_EXEMPT;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_TAX_EXEMPT_NUMBER THEN
                TAX_EXEMPT_NUMBER;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_TAX_EXEMPT_REASON THEN
                TAX_EXEMPT_REASON;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_TOP_MODEL_LINE THEN
                TOP_MODEL_LINE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SERVICE_START_DATE THEN
                SERVICE_START_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SERVICE_PERIOD THEN
                SERVICE_PERIOD;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SERVICE_REFERENCE_TYPE_CODE THEN
                SERVICE_REFERENCE_TYPE_CODE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_RETURN_CONTEXT THEN
                RETURN_CONTEXT;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SOURCE_TYPE THEN
                SOURCE_TYPE;
            -- Add for bug 2766005
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_PACKING_INSTRUCTIONS THEN
                PACKING_INSTRUCTIONS;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SHIPPING_INSTRUCTIONS THEN
                SHIPPING_INSTRUCTIONS;
            -- End of code for bug 2766005
	    -- Distributed orders
	    ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_END_CUSTOMER THEN
		END_CUSTOMER;
	    ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_END_CUSTOMER_CONTACT THEN
		END_CUSTOMER_CONTACT;
	    ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_END_CUSTOMER_SITE_USE THEN
		END_CUSTOMER_SITE_USE;
            -- bug 4283037
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_SERVICE_DURATION THEN
                SERVICE_DURATION;
	    ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_ORDER_FIRMED_DATE and OE_CODE_CONTROL.CODE_RELEASE_LEVEL >='110509'
			 THEN  --key Transaction Dates Project
		ORDER_FIRMED_DATE ;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_UTIL.G_CHARGE_PERIODICITY THEN
                CHARGE_PERIODICITY;
            END IF;
        END LOOP;
    END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	WHEN OTHERS THEN
 	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    		OE_MSG_PUB.Add_Exc_Msg
         	(   G_PKG_NAME
         	,   'Clear_Dependents'
         	);
     END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Clear_Dependents;

-- Function to initialize a record of type OE_AK_ORDER_LINES_V%ROWTYPE
FUNCTION G_MISS_OE_AK_LINE_REC
RETURN OE_AK_ORDER_LINES_V%ROWTYPE IS
l_rowtype_rec			OE_AK_ORDER_LINES_V%ROWTYPE;
BEGIN

-- OPM 02/JUN/00 - add process attributes
-- =========================================================================

    l_rowtype_rec.ACCOUNTING_RULE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.ACCOUNTING_RULE_DURATION	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.ACTUAL_ARRIVAL_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.ACTUAL_SHIPMENT_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.AGREEMENT_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.ARRIVAL_SET	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.upgraded_flag	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ARRIVAL_SET_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.ATO_LINE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.ATTRIBUTE1	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE10	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE11	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE12	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE13	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE14	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE15	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE16	:= FND_API.G_MISS_CHAR;  --For bug 2184255
    l_rowtype_rec.ATTRIBUTE17	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE18	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE19	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE2	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE20	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE3	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE4	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE5	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE6	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE7	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE8	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE9	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AUTHORIZED_TO_SHIP_FLAG	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AUTO_SELECTED_QUANTITY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.BOOKED_FLAG	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.CANCELLED_FLAG	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.CANCELLED_QUANTITY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.CANCELLED_QUANTITY2   := FND_API.G_MISS_NUM;          --OPM
    l_rowtype_rec.COMPONENT_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.COMPONENT_NUMBER	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.COMPONENT_SEQUENCE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.CONFIGURATION_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.CONFIG_DISPLAY_SEQUENCE	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.CONFIG_HEADER_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.CONFIG_REV_NBR	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.CONTEXT	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.CREATED_BY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.CREATION_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.CREDIT_INVOICE_LINE_ID := FND_API.G_MISS_NUM;
    l_rowtype_rec.CUSTOMER_DOCK_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.CUSTOMER_JOB	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.CUSTOMER_PRODUCTION_LINE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.CUSTOMER_TRX_LINE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.CUST_MODEL_SERIAL_NUMBER	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.CUST_PO_NUMBER	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.CUSTOMER_LINE_NUMBER	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.CUST_PRODUCTION_SEQ_NUM	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.DELIVERY_LEAD_TIME	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.DELIVER_TO_CONTACT_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.DELIVER_TO_ORG_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.DEMAND_BUCKET_TYPE_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.DEMAND_CLASS_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.DEP_PLAN_REQUIRED_FLAG	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.EARLIEST_ACCEPTABLE_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.END_ITEM_UNIT_NUMBER	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.EXPLOSION_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.FOB_POINT_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.FREIGHT_CARRIER_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.FREIGHT_TERMS_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.FULFILLED_QUANTITY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.FULFILLED_FLAG		:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.FULFILLMENT_METHOD_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.FULFILLMENT_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.GLOBAL_ATTRIBUTE1	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE10	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE11	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE12	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE13	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE14	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE15	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE16	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE17	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE18	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE19	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE2	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE20	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE3	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE4	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE5	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE6	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE7	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE8	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE9	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.GLOBAL_ATTRIBUTE_CATEGORY	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.HEADER_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE1	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE10	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE11	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE12	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE13	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE14	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE15	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE16	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE17	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE18	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE19	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE2	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE20	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE21	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE22	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE23	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE24	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE25	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE26	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE27	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE28	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE29	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE3	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE30	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE4	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE5	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE6	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE7	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE8	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_ATTRIBUTE9	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INDUSTRY_CONTEXT	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INTERMED_SHIP_TO_CONTACT_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.INTERMED_SHIP_TO_ORG_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.INVENTORY_ITEM_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.INVOICE_INTERFACE_STATUS_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.INVOICE_TO_CONTACT_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.INVOICE_TO_ORG_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.INVOICED_QUANTITY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.INVOICING_RULE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.ORDERED_ITEM_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.ITEM_IDENTIFIER_TYPE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ORDERED_ITEM	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ITEM_REVISION	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ITEM_TYPE_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.LAST_UPDATED_BY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.LAST_UPDATE_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.LAST_UPDATE_LOGIN	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.LATEST_ACCEPTABLE_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.LINE_CATEGORY_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.LINE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.LINE_NUMBER	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.LINE_TYPE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.LINK_TO_LINE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.MFG_COMPONENT_SEQUENCE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.MODEL_GROUP_NUMBER	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.OPEN_FLAG	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.OPTION_FLAG	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.OPTION_NUMBER	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.ORDERED_QUANTITY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.ORDERED_QUANTITY2	:= FND_API.G_MISS_NUM;   -- OPM 1857167
    l_rowtype_rec.ORDER_QUANTITY_UOM	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ORG_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.ORIG_SYS_DOCUMENT_REF	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ORIG_SYS_LINE_REF	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.OVER_SHIP_REASON_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.OVER_SHIP_RESOLVED_FLAG	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PACKING_INSTRUCTIONS	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PAYMENT_TERM_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.PLANNING_PRIORITY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.PRICE_LIST_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.PRICE_REQUEST_CODE	:= FND_API.G_MISS_CHAR; -- PROMOTIONS SEP/01
    l_rowtype_rec.PRICING_ATTRIBUTE1	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PRICING_ATTRIBUTE10	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PRICING_ATTRIBUTE2	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PRICING_ATTRIBUTE3	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PRICING_ATTRIBUTE4	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PRICING_ATTRIBUTE5	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PRICING_ATTRIBUTE6	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PRICING_ATTRIBUTE7	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PRICING_ATTRIBUTE8	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PRICING_ATTRIBUTE9	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PRICING_CONTEXT	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PRICING_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.PRICING_QUANTITY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.PRICING_QUANTITY_UOM	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PROGRAM_APPLICATION_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.PROGRAM_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.PROGRAM_UPDATE_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.PROJECT_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.PROMISE_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.RE_SOURCE_FLAG   := FND_API.G_MISS_CHAR;
    l_rowtype_rec.REFERENCE_CUSTOMER_TRX_LINE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.REFERENCE_HEADER_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.REFERENCE_LINE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.REFERENCE_TYPE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.REQUEST_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.REQUEST_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.RESERVED_QUANTITY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.RETURN_ATTRIBUTE1	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_ATTRIBUTE10	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_ATTRIBUTE11	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_ATTRIBUTE12	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_ATTRIBUTE13	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_ATTRIBUTE14	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_ATTRIBUTE15	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_ATTRIBUTE2	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_ATTRIBUTE3	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_ATTRIBUTE4	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_ATTRIBUTE5	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_ATTRIBUTE6	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_ATTRIBUTE7	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_ATTRIBUTE8	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_ATTRIBUTE9	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_CONTEXT	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_REASON_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.RLA_SCHEDULE_TYPE_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SALESREP_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SCHEDULE_ACTION_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SPLIT_ACTION_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SCHEDULE_ARRIVAL_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.SCHEDULE_SHIP_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.SCHEDULE_STATUS_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SHIPMENT_NUMBER	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SHIPMENT_PRIORITY_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SHIPPED_QUANTITY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SHIPPING_INTERFACED_FLAG	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SHIPPING_METHOD_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SHIPPING_QUANTITY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SHIPPING_QUANTITY_UOM	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SHIPPING_INSTRUCTIONS	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SHIP_FROM_ORG_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SUBINVENTORY		:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SHIP_MODEL_COMPLETE_FLAG	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SHIP_SET	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SHIP_SET_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SHIP_TOLERANCE_ABOVE	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SHIP_TOLERANCE_BELOW	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SHIP_TO_CONTACT_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SHIP_TO_ORG_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SOLD_FROM_ORG_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SOLD_TO_ORG_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SORT_ORDER	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SOURCE_DOCUMENT_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SOURCE_DOCUMENT_LINE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SOURCE_DOCUMENT_TYPE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SOURCE_TYPE_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SPLIT_FROM_LINE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.LINE_SET_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SPLIT_BY	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.Model_remnant_flag := FND_API.G_MISS_CHAR;
    l_rowtype_rec.TASK_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.TAX_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TAX_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.TAX_EXEMPT_FLAG	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TAX_EXEMPT_NUMBER	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TAX_EXEMPT_REASON_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TAX_POINT_CODE	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TAX_RATE	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.TAX_VALUE	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.TOP_MODEL_LINE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.UNIT_LIST_PRICE	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.UNIT_SELLING_PRICE	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.VEH_CUS_ITEM_CUM_KEY_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.VISIBLE_DEMAND_FLAG	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SHIPPABLE_FLAG		:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.SERVICE_TXN_REASON_CODE := FND_API.G_MISS_CHAR;
    l_rowtype_rec.SERVICE_DURATION := FND_API.G_MISS_NUM;
    l_rowtype_rec.SERVICE_PERIOD := FND_API.G_MISS_CHAR;
    l_rowtype_rec.SERVICE_START_DATE := FND_API.G_MISS_DATE;
    l_rowtype_rec.SERVICE_END_DATE := FND_API.G_MISS_DATE;
    l_rowtype_rec.SERVICE_COTERMINATE_FLAG := FND_API.G_MISS_CHAR;
    l_rowtype_rec.SERVICE_TXN_COMMENTS := FND_API.G_MISS_CHAR;
    l_rowtype_rec.UNIT_SELLING_PERCENT := FND_API.G_MISS_NUM;
    l_rowtype_rec.UNIT_LIST_PERCENT := FND_API.G_MISS_NUM;
    l_rowtype_rec.UNIT_PERCENT_BASE_PRICE := FND_API.G_MISS_NUM;
    l_rowtype_rec.SERVICE_NUMBER := FND_API.G_MISS_NUM;
    l_rowtype_rec.SERVICE_REFERENCE_TYPE_CODE := FND_API.G_MISS_CHAR;
    l_rowtype_rec.SERVICE_REFERENCE_LINE_ID := FND_API.G_MISS_NUM;
    l_rowtype_rec.SERVICE_REFERENCE_SYSTEM_ID := FND_API.G_MISS_NUM;
    l_rowtype_rec.TP_ATTRIBUTE1	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_ATTRIBUTE10	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_ATTRIBUTE11	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_ATTRIBUTE12	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_ATTRIBUTE13	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_ATTRIBUTE14	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_ATTRIBUTE15	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_ATTRIBUTE2	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_ATTRIBUTE3	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_ATTRIBUTE4	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_ATTRIBUTE5	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_ATTRIBUTE6	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_ATTRIBUTE7	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_ATTRIBUTE8	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_ATTRIBUTE9	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.TP_CONTEXT       := FND_API.G_MISS_CHAR;
    l_rowtype_rec.CALCULATE_PRICE_FLAG       := FND_API.G_MISS_CHAR;
    -- QUOTING changes
    l_rowtype_rec.TRANSACTION_PHASE_CODE          := FND_API.G_MISS_CHAR;
    l_rowtype_rec.SOURCE_DOCUMENT_VERSION_NUMBER  := FND_API.G_MISS_NUM;
    --key Transaction Dates Project
    l_rowtype_rec.order_firmed_date   := FND_API.G_MISS_DATE;
    l_rowtype_rec.actual_fulfillment_date   :=    FND_API.G_MISS_DATE;
    -- INVCONV
    l_rowtype_rec.FULFILLED_QUANTITY2	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SHIPPED_QUANTITY2	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SHIPPING_QUANTITY2	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.SHIPPING_QUANTITY_UOM2	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.charge_periodicity_code	:= FND_API.G_MISS_CHAR; -- Rakesh


    RETURN l_rowtype_rec;

EXCEPTION
  WHEN OTHERS THEN
        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'G_MISS_OE_AK_LINE_REC'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END G_MISS_OE_AK_LINE_REC;

PROCEDURE API_Rec_To_Rowtype_Rec
(   p_LINE_rec                      IN  OE_Order_PUB.LINE_Rec_Type
,   x_rowtype_rec                   IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
) IS
BEGIN

    x_rowtype_rec.ACCOUNTING_RULE_ID       := p_line_rec.ACCOUNTING_RULE_ID;
    x_rowtype_rec.ACCOUNTING_RULE_DURATION       := p_line_rec.ACCOUNTING_RULE_DURATION;
    x_rowtype_rec.ACTUAL_ARRIVAL_DATE       := p_line_rec.ACTUAL_ARRIVAL_DATE;
    x_rowtype_rec.ACTUAL_SHIPMENT_DATE       := p_line_rec.ACTUAL_SHIPMENT_DATE;
    x_rowtype_rec.AGREEMENT_ID       := p_line_rec.AGREEMENT_ID;
    x_rowtype_rec.ARRIVAL_SET       := p_line_rec.ARRIVAL_SET;
    x_rowtype_rec.upgraded_flag       := p_line_rec.upgraded_flag;
    x_rowtype_rec.ARRIVAL_SET_ID       := p_line_rec.ARRIVAL_SET_ID;
    x_rowtype_rec.ATO_LINE_ID       := p_line_rec.ATO_LINE_ID;
    x_rowtype_rec.ATTRIBUTE1       := p_line_rec.ATTRIBUTE1;
    x_rowtype_rec.ATTRIBUTE10       := p_line_rec.ATTRIBUTE10;
    x_rowtype_rec.ATTRIBUTE11       := p_line_rec.ATTRIBUTE11;
    x_rowtype_rec.ATTRIBUTE12       := p_line_rec.ATTRIBUTE12;
    x_rowtype_rec.ATTRIBUTE13       := p_line_rec.ATTRIBUTE13;
    x_rowtype_rec.ATTRIBUTE14       := p_line_rec.ATTRIBUTE14;
    x_rowtype_rec.ATTRIBUTE15       := p_line_rec.ATTRIBUTE15;
    x_rowtype_rec.ATTRIBUTE16       := p_line_rec.ATTRIBUTE16; --For bug 2184255
    x_rowtype_rec.ATTRIBUTE17       := p_line_rec.ATTRIBUTE17;
    x_rowtype_rec.ATTRIBUTE18       := p_line_rec.ATTRIBUTE18;
    x_rowtype_rec.ATTRIBUTE19       := p_line_rec.ATTRIBUTE19;
    x_rowtype_rec.ATTRIBUTE2        := p_line_rec.ATTRIBUTE2;
    x_rowtype_rec.ATTRIBUTE20       := p_line_rec.ATTRIBUTE20;
    x_rowtype_rec.ATTRIBUTE3       := p_line_rec.ATTRIBUTE3;
    x_rowtype_rec.ATTRIBUTE4       := p_line_rec.ATTRIBUTE4;
    x_rowtype_rec.ATTRIBUTE5       := p_line_rec.ATTRIBUTE5;
    x_rowtype_rec.ATTRIBUTE6       := p_line_rec.ATTRIBUTE6;
    x_rowtype_rec.ATTRIBUTE7       := p_line_rec.ATTRIBUTE7;
    x_rowtype_rec.ATTRIBUTE8       := p_line_rec.ATTRIBUTE8;
    x_rowtype_rec.ATTRIBUTE9       := p_line_rec.ATTRIBUTE9;
    x_rowtype_rec.AUTHORIZED_TO_SHIP_FLAG       := p_line_rec.AUTHORIZED_TO_SHIP_FLAG;
    x_rowtype_rec.AUTO_SELECTED_QUANTITY       := p_line_rec.AUTO_SELECTED_QUANTITY;
    x_rowtype_rec.BLANKET_NUMBER                := p_line_rec.BLANKET_NUMBER;
    x_rowtype_rec.BLANKET_LINE_NUMBER           := p_line_rec.BLANKET_LINE_NUMBER;
    x_rowtype_rec.BLANKET_VERSION_NUMBER        := p_line_rec.BLANKET_VERSION_NUMBER;
    x_rowtype_rec.BOOKED_FLAG       := p_line_rec.BOOKED_FLAG;
    x_rowtype_rec.CALCULATE_PRICE_FLAG       := p_line_rec.CALCULATE_PRICE_FLAG;
    x_rowtype_rec.CANCELLED_FLAG       := p_line_rec.CANCELLED_FLAG;
    x_rowtype_rec.CANCELLED_QUANTITY       := p_line_rec.CANCELLED_QUANTITY;
    x_rowtype_rec.CANCELLED_QUANTITY2      := p_line_rec.CANCELLED_QUANTITY2;
    x_rowtype_rec.COMMITMENT_ID      := p_line_rec.COMMITMENT_ID;
    x_rowtype_rec.COMPONENT_CODE       := p_line_rec.COMPONENT_CODE;
    x_rowtype_rec.COMPONENT_NUMBER       := p_line_rec.COMPONENT_NUMBER;
    x_rowtype_rec.COMPONENT_SEQUENCE_ID       := p_line_rec.COMPONENT_SEQUENCE_ID;
    x_rowtype_rec.CONFIGURATION_ID       := p_line_rec.CONFIGURATION_ID;
    x_rowtype_rec.CONFIG_DISPLAY_SEQUENCE       := p_line_rec.CONFIG_DISPLAY_SEQUENCE;
    x_rowtype_rec.CONFIG_HEADER_ID       := p_line_rec.CONFIG_HEADER_ID;
    x_rowtype_rec.CONFIG_REV_NBR       := p_line_rec.CONFIG_REV_NBR;
    x_rowtype_rec.CONTEXT       := p_line_rec.CONTEXT;
    x_rowtype_rec.CREATED_BY       := p_line_rec.CREATED_BY;
    x_rowtype_rec.CREATION_DATE       := p_line_rec.CREATION_DATE;
    x_rowtype_rec.CREDIT_INVOICE_LINE_ID := p_line_rec.CREDIT_INVOICE_LINE_ID;
    x_rowtype_rec.CUSTOMER_DOCK_CODE       := p_line_rec.CUSTOMER_DOCK_CODE;
    x_rowtype_rec.CUSTOMER_JOB       := p_line_rec.CUSTOMER_JOB;
    x_rowtype_rec.CUSTOMER_PRODUCTION_LINE       := p_line_rec.CUSTOMER_PRODUCTION_LINE;
    x_rowtype_rec.CUSTOMER_TRX_LINE_ID       := p_line_rec.CUSTOMER_TRX_LINE_ID;
    x_rowtype_rec.CUST_MODEL_SERIAL_NUMBER       := p_line_rec.CUST_MODEL_SERIAL_NUMBER;
    x_rowtype_rec.CUST_PO_NUMBER       := p_line_rec.CUST_PO_NUMBER;
    x_rowtype_rec.CUSTOMER_LINE_NUMBER  := p_line_rec.CUSTOMER_LINE_NUMBER;
    x_rowtype_rec.CUST_PRODUCTION_SEQ_NUM       := p_line_rec.CUST_PRODUCTION_SEQ_NUM;
    x_rowtype_rec.DELIVERY_LEAD_TIME       := p_line_rec.DELIVERY_LEAD_TIME;
    x_rowtype_rec.DELIVER_TO_CONTACT_ID       := p_line_rec.DELIVER_TO_CONTACT_ID;
    x_rowtype_rec.DELIVER_TO_ORG_ID       := p_line_rec.DELIVER_TO_ORG_ID;
    x_rowtype_rec.DEMAND_BUCKET_TYPE_CODE       := p_line_rec.DEMAND_BUCKET_TYPE_CODE;
    x_rowtype_rec.DEMAND_CLASS_CODE       := p_line_rec.DEMAND_CLASS_CODE;
    x_rowtype_rec.DEP_PLAN_REQUIRED_FLAG       := p_line_rec.DEP_PLAN_REQUIRED_FLAG;
    x_rowtype_rec.EARLIEST_ACCEPTABLE_DATE       := p_line_rec.EARLIEST_ACCEPTABLE_DATE;
    x_rowtype_rec.END_ITEM_UNIT_NUMBER       := p_line_rec.END_ITEM_UNIT_NUMBER;
    x_rowtype_rec.EXPLOSION_DATE       := p_line_rec.EXPLOSION_DATE;
    x_rowtype_rec.FOB_POINT_CODE       := p_line_rec.FOB_POINT_CODE;
    x_rowtype_rec.FREIGHT_CARRIER_CODE       := p_line_rec.FREIGHT_CARRIER_CODE;
    x_rowtype_rec.FREIGHT_TERMS_CODE       := p_line_rec.FREIGHT_TERMS_CODE;
    x_rowtype_rec.FULFILLED_QUANTITY       := p_line_rec.FULFILLED_QUANTITY;
    x_rowtype_rec.FULFILLED_QUANTITY2      := p_line_rec.FULFILLED_QUANTITY2;
    x_rowtype_rec.FULFILLED_FLAG       := p_line_rec.FULFILLED_FLAG;
    x_rowtype_rec.FULFILLMENT_METHOD_CODE       := p_line_rec.FULFILLMENT_METHOD_CODE;
    x_rowtype_rec.FULFILLMENT_DATE       := p_line_rec.FULFILLMENT_DATE;
    x_rowtype_rec.GLOBAL_ATTRIBUTE1       := p_line_rec.GLOBAL_ATTRIBUTE1;
    x_rowtype_rec.GLOBAL_ATTRIBUTE10       := p_line_rec.GLOBAL_ATTRIBUTE10;
    x_rowtype_rec.GLOBAL_ATTRIBUTE11       := p_line_rec.GLOBAL_ATTRIBUTE11;
    x_rowtype_rec.GLOBAL_ATTRIBUTE12       := p_line_rec.GLOBAL_ATTRIBUTE12;
    x_rowtype_rec.GLOBAL_ATTRIBUTE13       := p_line_rec.GLOBAL_ATTRIBUTE13;
    x_rowtype_rec.GLOBAL_ATTRIBUTE14       := p_line_rec.GLOBAL_ATTRIBUTE14;
    x_rowtype_rec.GLOBAL_ATTRIBUTE15       := p_line_rec.GLOBAL_ATTRIBUTE15;
    x_rowtype_rec.GLOBAL_ATTRIBUTE16       := p_line_rec.GLOBAL_ATTRIBUTE16;
    x_rowtype_rec.GLOBAL_ATTRIBUTE17       := p_line_rec.GLOBAL_ATTRIBUTE17;
    x_rowtype_rec.GLOBAL_ATTRIBUTE18       := p_line_rec.GLOBAL_ATTRIBUTE18;
    x_rowtype_rec.GLOBAL_ATTRIBUTE19       := p_line_rec.GLOBAL_ATTRIBUTE19;
    x_rowtype_rec.GLOBAL_ATTRIBUTE2       := p_line_rec.GLOBAL_ATTRIBUTE2;
    x_rowtype_rec.GLOBAL_ATTRIBUTE20       := p_line_rec.GLOBAL_ATTRIBUTE20;
    x_rowtype_rec.GLOBAL_ATTRIBUTE3       := p_line_rec.GLOBAL_ATTRIBUTE3;
    x_rowtype_rec.GLOBAL_ATTRIBUTE4       := p_line_rec.GLOBAL_ATTRIBUTE4;
    x_rowtype_rec.GLOBAL_ATTRIBUTE5       := p_line_rec.GLOBAL_ATTRIBUTE5;
    x_rowtype_rec.GLOBAL_ATTRIBUTE6       := p_line_rec.GLOBAL_ATTRIBUTE6;
    x_rowtype_rec.GLOBAL_ATTRIBUTE7       := p_line_rec.GLOBAL_ATTRIBUTE7;
    x_rowtype_rec.GLOBAL_ATTRIBUTE8       := p_line_rec.GLOBAL_ATTRIBUTE8;
    x_rowtype_rec.GLOBAL_ATTRIBUTE9       := p_line_rec.GLOBAL_ATTRIBUTE9;
    x_rowtype_rec.GLOBAL_ATTRIBUTE_CATEGORY       := p_line_rec.GLOBAL_ATTRIBUTE_CATEGORY;
    x_rowtype_rec.HEADER_ID       := p_line_rec.HEADER_ID;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE1       := p_line_rec.INDUSTRY_ATTRIBUTE1;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE10       := p_line_rec.INDUSTRY_ATTRIBUTE10;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE11       := p_line_rec.INDUSTRY_ATTRIBUTE11;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE12       := p_line_rec.INDUSTRY_ATTRIBUTE12;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE13       := p_line_rec.INDUSTRY_ATTRIBUTE13;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE14       := p_line_rec.INDUSTRY_ATTRIBUTE14;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE15       := p_line_rec.INDUSTRY_ATTRIBUTE15;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE16       := p_line_rec.INDUSTRY_ATTRIBUTE16;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE17       := p_line_rec.INDUSTRY_ATTRIBUTE17;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE18       := p_line_rec.INDUSTRY_ATTRIBUTE18;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE19       := p_line_rec.INDUSTRY_ATTRIBUTE19;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE2       := p_line_rec.INDUSTRY_ATTRIBUTE2;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE20       := p_line_rec.INDUSTRY_ATTRIBUTE20;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE21       := p_line_rec.INDUSTRY_ATTRIBUTE21;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE22       := p_line_rec.INDUSTRY_ATTRIBUTE22;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE23       := p_line_rec.INDUSTRY_ATTRIBUTE23;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE24       := p_line_rec.INDUSTRY_ATTRIBUTE24;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE25       := p_line_rec.INDUSTRY_ATTRIBUTE25;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE26       := p_line_rec.INDUSTRY_ATTRIBUTE26;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE27       := p_line_rec.INDUSTRY_ATTRIBUTE27;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE28       := p_line_rec.INDUSTRY_ATTRIBUTE28;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE29       := p_line_rec.INDUSTRY_ATTRIBUTE29;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE3       := p_line_rec.INDUSTRY_ATTRIBUTE3;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE30       := p_line_rec.INDUSTRY_ATTRIBUTE30;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE4       := p_line_rec.INDUSTRY_ATTRIBUTE4;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE5       := p_line_rec.INDUSTRY_ATTRIBUTE5;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE6       := p_line_rec.INDUSTRY_ATTRIBUTE6;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE7       := p_line_rec.INDUSTRY_ATTRIBUTE7;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE8       := p_line_rec.INDUSTRY_ATTRIBUTE8;
    x_rowtype_rec.INDUSTRY_ATTRIBUTE9       := p_line_rec.INDUSTRY_ATTRIBUTE9;
    x_rowtype_rec.INDUSTRY_CONTEXT       := p_line_rec.INDUSTRY_CONTEXT;
    x_rowtype_rec.INTERMED_SHIP_TO_CONTACT_ID       := p_line_rec.INTERMED_SHIP_TO_CONTACT_ID;
    x_rowtype_rec.INTERMED_SHIP_TO_ORG_ID       := p_line_rec.INTERMED_SHIP_TO_ORG_ID;
    x_rowtype_rec.INVENTORY_ITEM_ID       := p_line_rec.INVENTORY_ITEM_ID;
    x_rowtype_rec.INVOICE_INTERFACE_STATUS_CODE       := p_line_rec.INVOICE_INTERFACE_STATUS_CODE;
    x_rowtype_rec.INVOICE_TO_CONTACT_ID       := p_line_rec.INVOICE_TO_CONTACT_ID;
    x_rowtype_rec.INVOICE_TO_ORG_ID       := p_line_rec.INVOICE_TO_ORG_ID;
    x_rowtype_rec.INVOICED_QUANTITY       := p_line_rec.INVOICED_QUANTITY;
    x_rowtype_rec.INVOICING_RULE_ID       := p_line_rec.INVOICING_RULE_ID;
    x_rowtype_rec.ORDERED_ITEM_ID       := p_line_rec.ORDERED_ITEM_ID;
    x_rowtype_rec.ITEM_IDENTIFIER_TYPE       := p_line_rec.ITEM_IDENTIFIER_TYPE;
    x_rowtype_rec.ORDERED_ITEM       := p_line_rec.ORDERED_ITEM;
    x_rowtype_rec.ITEM_REVISION       := p_line_rec.ITEM_REVISION;
    x_rowtype_rec.ITEM_TYPE_CODE       := p_line_rec.ITEM_TYPE_CODE;
    x_rowtype_rec.LAST_UPDATED_BY       := p_line_rec.LAST_UPDATED_BY;
    x_rowtype_rec.LAST_UPDATE_DATE       := p_line_rec.LAST_UPDATE_DATE;
    x_rowtype_rec.LAST_UPDATE_LOGIN       := p_line_rec.LAST_UPDATE_LOGIN;
    x_rowtype_rec.LATEST_ACCEPTABLE_DATE       := p_line_rec.LATEST_ACCEPTABLE_DATE;
    x_rowtype_rec.LINE_CATEGORY_CODE       := p_line_rec.LINE_CATEGORY_CODE;
    x_rowtype_rec.LINE_ID       := p_line_rec.LINE_ID;
    x_rowtype_rec.LINE_NUMBER       := p_line_rec.LINE_NUMBER;
    x_rowtype_rec.LINE_TYPE_ID       := p_line_rec.LINE_TYPE_ID;
    x_rowtype_rec.LINK_TO_LINE_ID       := p_line_rec.LINK_TO_LINE_ID;
    x_rowtype_rec.MFG_COMPONENT_SEQUENCE_ID       := p_line_rec.MFG_COMPONENT_SEQUENCE_ID;
    x_rowtype_rec.MODEL_GROUP_NUMBER       := p_line_rec.MODEL_GROUP_NUMBER;
    x_rowtype_rec.OPEN_FLAG       := p_line_rec.OPEN_FLAG;
    x_rowtype_rec.OPTION_FLAG       := p_line_rec.OPTION_FLAG;
    x_rowtype_rec.OPTION_NUMBER       := p_line_rec.OPTION_NUMBER;
    x_rowtype_rec.ORDERED_QUANTITY       := p_line_rec.ORDERED_QUANTITY;
    x_rowtype_rec.ORDERED_QUANTITY2      := p_line_rec.ORDERED_QUANTITY2;
    x_rowtype_rec.ORDER_QUANTITY_UOM       := p_line_rec.ORDER_QUANTITY_UOM;
    x_rowtype_rec.ORDERED_QUANTITY_UOM2    := p_line_rec.ORDERED_QUANTITY_UOM2;
    x_rowtype_rec.ORG_ID       := p_line_rec.ORG_ID;
    x_rowtype_rec.ORIG_SYS_DOCUMENT_REF       := p_line_rec.ORIG_SYS_DOCUMENT_REF;
    x_rowtype_rec.ORIG_SYS_LINE_REF       := p_line_rec.ORIG_SYS_LINE_REF;
    x_rowtype_rec.OVER_SHIP_REASON_CODE       := p_line_rec.OVER_SHIP_REASON_CODE;
    x_rowtype_rec.OVER_SHIP_RESOLVED_FLAG       := p_line_rec.OVER_SHIP_RESOLVED_FLAG;
    x_rowtype_rec.PACKING_INSTRUCTIONS       := p_line_rec.PACKING_INSTRUCTIONS;
    x_rowtype_rec.PAYMENT_TERM_ID       := p_line_rec.PAYMENT_TERM_ID;
    x_rowtype_rec.PLANNING_PRIORITY       := p_line_rec.PLANNING_PRIORITY;
    x_rowtype_rec.PREFERRED_GRADE         := p_line_rec.PREFERRED_GRADE;
    x_rowtype_rec.PRICE_LIST_ID       := p_line_rec.PRICE_LIST_ID;
    x_rowtype_rec.PRICE_REQUEST_CODE       := p_line_rec.PRICE_REQUEST_CODE; -- PROMOTIONS SEP/01
    x_rowtype_rec.PRICING_ATTRIBUTE1       := p_line_rec.PRICING_ATTRIBUTE1;
    x_rowtype_rec.PRICING_ATTRIBUTE10       := p_line_rec.PRICING_ATTRIBUTE10;
    x_rowtype_rec.PRICING_ATTRIBUTE2       := p_line_rec.PRICING_ATTRIBUTE2;
    x_rowtype_rec.PRICING_ATTRIBUTE3       := p_line_rec.PRICING_ATTRIBUTE3;
    x_rowtype_rec.PRICING_ATTRIBUTE4       := p_line_rec.PRICING_ATTRIBUTE4;
    x_rowtype_rec.PRICING_ATTRIBUTE5       := p_line_rec.PRICING_ATTRIBUTE5;
    x_rowtype_rec.PRICING_ATTRIBUTE6       := p_line_rec.PRICING_ATTRIBUTE6;
    x_rowtype_rec.PRICING_ATTRIBUTE7       := p_line_rec.PRICING_ATTRIBUTE7;
    x_rowtype_rec.PRICING_ATTRIBUTE8       := p_line_rec.PRICING_ATTRIBUTE8;
    x_rowtype_rec.PRICING_ATTRIBUTE9       := p_line_rec.PRICING_ATTRIBUTE9;
    x_rowtype_rec.PRICING_CONTEXT       := p_line_rec.PRICING_CONTEXT;
    x_rowtype_rec.PRICING_DATE       := p_line_rec.PRICING_DATE;
    x_rowtype_rec.PRICING_QUANTITY       := p_line_rec.PRICING_QUANTITY;
    x_rowtype_rec.PRICING_QUANTITY_UOM       := p_line_rec.PRICING_QUANTITY_UOM;
    x_rowtype_rec.PROGRAM_APPLICATION_ID       := p_line_rec.PROGRAM_APPLICATION_ID;
    x_rowtype_rec.PROGRAM_ID       := p_line_rec.PROGRAM_ID;
    x_rowtype_rec.PROGRAM_UPDATE_DATE       := p_line_rec.PROGRAM_UPDATE_DATE;
    x_rowtype_rec.PROJECT_ID       := p_line_rec.PROJECT_ID;
    x_rowtype_rec.PROMISE_DATE       := p_line_rec.PROMISE_DATE;
    x_rowtype_rec.RE_SOURCE_FLAG       := p_line_rec.RE_SOURCE_FLAG;
    x_rowtype_rec.REFERENCE_CUSTOMER_TRX_LINE_ID
            := p_line_rec.REFERENCE_CUSTOMER_TRX_LINE_ID;
    x_rowtype_rec.REFERENCE_HEADER_ID       := p_line_rec.REFERENCE_HEADER_ID;
    x_rowtype_rec.REFERENCE_LINE_ID       := p_line_rec.REFERENCE_LINE_ID;
    x_rowtype_rec.REFERENCE_TYPE       := p_line_rec.REFERENCE_TYPE;
    x_rowtype_rec.REQUEST_DATE       := p_line_rec.REQUEST_DATE;
    x_rowtype_rec.REQUEST_ID       := p_line_rec.REQUEST_ID;
    x_rowtype_rec.RESERVED_QUANTITY       := p_line_rec.RESERVED_QUANTITY;
    x_rowtype_rec.RETURN_ATTRIBUTE1       := p_line_rec.RETURN_ATTRIBUTE1;
    x_rowtype_rec.RETURN_ATTRIBUTE10       := p_line_rec.RETURN_ATTRIBUTE10;
    x_rowtype_rec.RETURN_ATTRIBUTE11       := p_line_rec.RETURN_ATTRIBUTE11;
    x_rowtype_rec.RETURN_ATTRIBUTE12       := p_line_rec.RETURN_ATTRIBUTE12;
    x_rowtype_rec.RETURN_ATTRIBUTE13       := p_line_rec.RETURN_ATTRIBUTE13;
    x_rowtype_rec.RETURN_ATTRIBUTE14       := p_line_rec.RETURN_ATTRIBUTE14;
    x_rowtype_rec.RETURN_ATTRIBUTE15       := p_line_rec.RETURN_ATTRIBUTE15;
    x_rowtype_rec.RETURN_ATTRIBUTE2       := p_line_rec.RETURN_ATTRIBUTE2;
    x_rowtype_rec.RETURN_ATTRIBUTE3       := p_line_rec.RETURN_ATTRIBUTE3;
    x_rowtype_rec.RETURN_ATTRIBUTE4       := p_line_rec.RETURN_ATTRIBUTE4;
    x_rowtype_rec.RETURN_ATTRIBUTE5       := p_line_rec.RETURN_ATTRIBUTE5;
    x_rowtype_rec.RETURN_ATTRIBUTE6       := p_line_rec.RETURN_ATTRIBUTE6;
    x_rowtype_rec.RETURN_ATTRIBUTE7       := p_line_rec.RETURN_ATTRIBUTE7;
    x_rowtype_rec.RETURN_ATTRIBUTE8       := p_line_rec.RETURN_ATTRIBUTE8;
    x_rowtype_rec.RETURN_ATTRIBUTE9       := p_line_rec.RETURN_ATTRIBUTE9;
    x_rowtype_rec.RETURN_CONTEXT       := p_line_rec.RETURN_CONTEXT;
    x_rowtype_rec.RETURN_REASON_CODE       := p_line_rec.RETURN_REASON_CODE;
    x_rowtype_rec.RLA_SCHEDULE_TYPE_CODE       := p_line_rec.RLA_SCHEDULE_TYPE_CODE;
    x_rowtype_rec.SALESREP_ID       := p_line_rec.SALESREP_ID;
    x_rowtype_rec.SCHEDULE_ACTION_CODE       := p_line_rec.SCHEDULE_ACTION_CODE;
    x_rowtype_rec.SPLIT_ACTION_CODE       := p_line_rec.SPLIT_ACTION_CODE;
    x_rowtype_rec.SCHEDULE_ARRIVAL_DATE       := p_line_rec.SCHEDULE_ARRIVAL_DATE;
    x_rowtype_rec.SCHEDULE_SHIP_DATE       := p_line_rec.SCHEDULE_SHIP_DATE;
    x_rowtype_rec.SCHEDULE_STATUS_CODE       := p_line_rec.SCHEDULE_STATUS_CODE;
    x_rowtype_rec.SHIPMENT_NUMBER       := p_line_rec.SHIPMENT_NUMBER;
    x_rowtype_rec.SHIPMENT_PRIORITY_CODE       := p_line_rec.SHIPMENT_PRIORITY_CODE;
    x_rowtype_rec.SHIPPED_QUANTITY       := p_line_rec.SHIPPED_QUANTITY;
    x_rowtype_rec.SHIPPED_QUANTITY2      := p_line_rec.SHIPPED_QUANTITY2;
    x_rowtype_rec.SHIPPING_INTERFACED_FLAG       := p_line_rec.SHIPPING_INTERFACED_FLAG;
    x_rowtype_rec.SHIPPING_INSTRUCTIONS       := p_line_rec.SHIPPING_INSTRUCTIONS;
    x_rowtype_rec.SHIPPING_METHOD_CODE       := p_line_rec.SHIPPING_METHOD_CODE;
    x_rowtype_rec.SHIPPING_QUANTITY       := p_line_rec.SHIPPING_QUANTITY;
    x_rowtype_rec.SHIPPING_QUANTITY2      := p_line_rec.SHIPPING_QUANTITY2;
    x_rowtype_rec.SHIPPING_QUANTITY_UOM       := p_line_rec.SHIPPING_QUANTITY_UOM;
    x_rowtype_rec.SHIPPING_QUANTITY_UOM2  := p_line_rec.SHIPPING_QUANTITY_UOM2;
    x_rowtype_rec.SHIP_FROM_ORG_ID       := p_line_rec.SHIP_FROM_ORG_ID;
    x_rowtype_rec.SUBINVENTORY		 := p_line_rec.SUBINVENTORY;
    x_rowtype_rec.SHIP_MODEL_COMPLETE_FLAG       := p_line_rec.SHIP_MODEL_COMPLETE_FLAG;
    x_rowtype_rec.SHIP_SET       := p_line_rec.SHIP_SET;
    x_rowtype_rec.SHIP_SET_ID       := p_line_rec.SHIP_SET_ID;
    x_rowtype_rec.SHIP_TOLERANCE_ABOVE       := p_line_rec.SHIP_TOLERANCE_ABOVE;
    x_rowtype_rec.SHIP_TOLERANCE_BELOW       := p_line_rec.SHIP_TOLERANCE_BELOW;
    x_rowtype_rec.SHIP_TO_CONTACT_ID       := p_line_rec.SHIP_TO_CONTACT_ID;
    x_rowtype_rec.SHIP_TO_ORG_ID       := p_line_rec.SHIP_TO_ORG_ID;
    x_rowtype_rec.SOLD_FROM_ORG_ID       := p_line_rec.SOLD_FROM_ORG_ID;
    x_rowtype_rec.SOLD_TO_ORG_ID       := p_line_rec.SOLD_TO_ORG_ID;
    x_rowtype_rec.SORT_ORDER       := p_line_rec.SORT_ORDER;
    x_rowtype_rec.SOURCE_DOCUMENT_ID       := p_line_rec.SOURCE_DOCUMENT_ID;
    x_rowtype_rec.SOURCE_DOCUMENT_LINE_ID       := p_line_rec.SOURCE_DOCUMENT_LINE_ID;
    x_rowtype_rec.SOURCE_DOCUMENT_TYPE_ID       := p_line_rec.SOURCE_DOCUMENT_TYPE_ID;
    x_rowtype_rec.SOURCE_TYPE_CODE       := p_line_rec.SOURCE_TYPE_CODE;
    x_rowtype_rec.SPLIT_FROM_LINE_ID       := p_line_rec.SPLIT_FROM_LINE_ID;
    x_rowtype_rec.LINE_SET_ID       := p_line_rec.LINE_SET_ID;
    x_rowtype_rec.SPLIT_BY       := p_line_rec.SPLIT_BY;
    x_rowtype_rec.MODEL_REMNANT_FLAG   := p_line_rec.MODEL_REMNANT_FLAG;
    x_rowtype_rec.TASK_ID       := p_line_rec.TASK_ID;
    x_rowtype_rec.TAX_CODE       := p_line_rec.TAX_CODE;
    x_rowtype_rec.TAX_DATE       := p_line_rec.TAX_DATE;
    x_rowtype_rec.TAX_EXEMPT_FLAG       := p_line_rec.TAX_EXEMPT_FLAG;
    x_rowtype_rec.TAX_EXEMPT_NUMBER       := p_line_rec.TAX_EXEMPT_NUMBER;
    x_rowtype_rec.TAX_EXEMPT_REASON_CODE       := p_line_rec.TAX_EXEMPT_REASON_CODE;
    x_rowtype_rec.TAX_POINT_CODE       := p_line_rec.TAX_POINT_CODE;
    x_rowtype_rec.TAX_RATE       := p_line_rec.TAX_RATE;
    x_rowtype_rec.TAX_VALUE       := p_line_rec.TAX_VALUE;
    x_rowtype_rec.TOP_MODEL_LINE_ID       := p_line_rec.TOP_MODEL_LINE_ID;
    x_rowtype_rec.UNIT_LIST_PRICE       := p_line_rec.UNIT_LIST_PRICE;
    x_rowtype_rec.UNIT_SELLING_PRICE       := p_line_rec.UNIT_SELLING_PRICE;
    x_rowtype_rec.UNIT_LIST_PRICE_PER_PQTY       := p_line_rec.UNIT_LIST_PRICE_PER_PQTY;
    x_rowtype_rec.UNIT_SELLING_PRICE_PER_PQTY       := p_line_rec.UNIT_SELLING_PRICE_PER_PQTY;
    x_rowtype_rec.VEH_CUS_ITEM_CUM_KEY_ID       := p_line_rec.VEH_CUS_ITEM_CUM_KEY_ID;
    x_rowtype_rec.VISIBLE_DEMAND_FLAG       := p_line_rec.VISIBLE_DEMAND_FLAG;
    x_rowtype_rec.OPERATION			    := p_line_rec.OPERATION;
    x_rowtype_rec.RETURN_STATUS		    := p_line_rec.RETURN_STATUS;
    x_rowtype_rec.DB_FLAG			    := p_line_rec.DB_FLAG;
    x_rowtype_rec.CHANGE_REASON		    := p_line_rec.CHANGE_REASON;
    x_rowtype_rec.CHANGE_COMMENTS		    := p_line_rec.CHANGE_COMMENTS;
    x_rowtype_rec.SHIPPABLE_FLAG		    := p_line_rec.SHIPPABLE_FLAG;
    x_rowtype_rec.SERVICE_TXN_REASON_CODE   := p_line_rec.SERVICE_TXN_REASON_CODE;
    x_rowtype_rec.SERVICE_DURATION   := p_line_rec.SERVICE_DURATION;
    x_rowtype_rec.SERVICE_PERIOD   := p_line_rec.SERVICE_PERIOD;
    x_rowtype_rec.SERVICE_START_DATE   := p_line_rec.SERVICE_START_DATE;
    x_rowtype_rec.SERVICE_END_DATE   := p_line_rec.SERVICE_END_DATE;
    x_rowtype_rec.SERVICE_COTERMINATE_FLAG   := p_line_rec.SERVICE_COTERMINATE_FLAG;
   x_rowtype_rec.SERVICE_TXN_COMMENTS   := p_line_rec.SERVICE_TXN_COMMENTS;
   x_rowtype_rec.UNIT_SELLING_PERCENT   := p_line_rec.UNIT_SELLING_PERCENT;
   x_rowtype_rec.UNIT_LIST_PERCENT   := p_line_rec.UNIT_LIST_PERCENT;
   x_rowtype_rec.UNIT_PERCENT_BASE_PRICE  := p_line_rec.UNIT_PERCENT_BASE_PRICE;
   x_rowtype_rec.SERVICE_NUMBER   := p_line_rec.SERVICE_NUMBER;
   x_rowtype_rec.SERVICE_REFERENCE_TYPE_CODE := p_line_rec.SERVICE_REFERENCE_TYPE_CODE;
   x_rowtype_rec.SERVICE_REFERENCE_LINE_ID := p_line_rec.SERVICE_REFERENCE_LINE_ID;
   x_rowtype_rec.SERVICE_REFERENCE_SYSTEM_ID := p_line_rec.SERVICE_REFERENCE_SYSTEM_ID;
   x_rowtype_rec.FLOW_STATUS_CODE := p_line_rec.flow_status_code;
    x_rowtype_rec.TP_ATTRIBUTE1       := p_line_rec.TP_ATTRIBUTE1;
    x_rowtype_rec.TP_ATTRIBUTE10       := p_line_rec.TP_ATTRIBUTE10;
    x_rowtype_rec.TP_ATTRIBUTE11       := p_line_rec.TP_ATTRIBUTE11;
    x_rowtype_rec.TP_ATTRIBUTE12       := p_line_rec.TP_ATTRIBUTE12;
    x_rowtype_rec.TP_ATTRIBUTE13       := p_line_rec.TP_ATTRIBUTE13;
    x_rowtype_rec.TP_ATTRIBUTE14       := p_line_rec.TP_ATTRIBUTE14;
    x_rowtype_rec.TP_ATTRIBUTE15       := p_line_rec.TP_ATTRIBUTE15;
    x_rowtype_rec.TP_ATTRIBUTE2       := p_line_rec.TP_ATTRIBUTE2;
    x_rowtype_rec.TP_ATTRIBUTE3       := p_line_rec.TP_ATTRIBUTE3;
    x_rowtype_rec.TP_ATTRIBUTE4       := p_line_rec.TP_ATTRIBUTE4;
    x_rowtype_rec.TP_ATTRIBUTE5       := p_line_rec.TP_ATTRIBUTE5;
    x_rowtype_rec.TP_ATTRIBUTE6       := p_line_rec.TP_ATTRIBUTE6;
    x_rowtype_rec.TP_ATTRIBUTE7       := p_line_rec.TP_ATTRIBUTE7;
    x_rowtype_rec.TP_ATTRIBUTE8       := p_line_rec.TP_ATTRIBUTE8;
    x_rowtype_rec.TP_ATTRIBUTE9       := p_line_rec.TP_ATTRIBUTE9;
    x_rowtype_rec.TP_CONTEXT          := p_line_rec.TP_CONTEXT;
    x_rowtype_rec.FIRST_ACK_CODE      := p_line_rec.FIRST_ACK_CODE;
    x_rowtype_rec.FIRST_ACK_DATE      := p_line_rec.FIRST_ACK_DATE;
    x_rowtype_rec.LAST_ACK_CODE      := p_line_rec.LAST_ACK_CODE;
    x_rowtype_rec.LAST_ACK_DATE      := p_line_rec.LAST_ACK_DATE;
    x_rowtype_rec.USER_ITEM_DESCRIPTION := p_line_rec.USER_ITEM_DESCRIPTION;
    -- QUOTING changes
    x_rowtype_rec.transaction_phase_code := p_line_rec.transaction_phase_code;
    x_rowtype_rec.source_document_version_number :=
                                p_line_rec.source_document_version_number;
    x_rowtype_rec.IB_OWNER := p_line_rec.IB_OWNER;
    x_rowtype_rec.IB_INSTALLED_AT_LOCATION := p_line_rec.IB_INSTALLED_AT_LOCATION;
    x_rowtype_rec.IB_CURRENT_LOCATION := p_line_rec.IB_CURRENT_LOCATION;
    x_rowtype_rec.END_CUSTOMER_ID := p_line_rec.END_CUSTOMER_ID;
    x_rowtype_rec.END_CUSTOMER_CONTACT_ID := p_line_rec.END_CUSTOMER_CONTACT_ID;
    x_rowtype_rec.END_CUSTOMER_SITE_USE_ID := p_line_rec.END_CUSTOMER_SITE_USE_ID;
    --retro{
    x_rowtype_rec.retrobill_request_id:=p_line_rec.retrobill_request_id;
     --retro}
   --key Transaction Dates Project
    x_rowtype_rec.order_firmed_date  := p_line_rec.order_firmed_date;
    x_rowtype_rec.actual_fulfillment_date := p_line_rec.actual_fulfillment_date;
   --Customer Acceptance
   x_rowtype_rec.CONTINGENCY_ID            := p_line_rec.CONTINGENCY_ID;
   x_rowtype_rec.REVREC_EVENT_CODE         := p_line_rec.REVREC_EVENT_CODE;
   x_rowtype_rec.REVREC_EXPIRATION_DAYS    := p_line_rec.REVREC_EXPIRATION_DAYS;
   x_rowtype_rec.ACCEPTED_QUANTITY         := p_line_rec.ACCEPTED_QUANTITY;
   x_rowtype_rec.REVREC_COMMENTS           := p_line_rec.REVREC_COMMENTS;
   x_rowtype_rec.REVREC_SIGNATURE          := p_line_rec.REVREC_SIGNATURE;
   x_rowtype_rec.REVREC_SIGNATURE_DATE     := p_line_rec.REVREC_SIGNATURE_DATE;
   x_rowtype_rec.ACCEPTED_BY               := p_line_rec.ACCEPTED_BY;
   x_rowtype_rec.REVREC_REFERENCE_DOCUMENT := p_line_rec.REVREC_REFERENCE_DOCUMENT;
   x_rowtype_rec.REVREC_IMPLICIT_FLAG      := p_line_rec.REVREC_IMPLICIT_FLAG;
   x_rowtype_rec.charge_periodicity_code      := p_line_rec.charge_periodicity_code; -- Rakesh


EXCEPTION
  WHEN OTHERS THEN
        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'API_Rec_To_RowType_Rec'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END API_Rec_To_RowType_Rec;


PROCEDURE Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_api_rec                       IN OUT NOCOPY OE_Order_PUB.LINE_Rec_Type
) IS
BEGIN

    x_api_rec.ACCOUNTING_RULE_ID       := p_record.ACCOUNTING_RULE_ID;
    x_api_rec.ACCOUNTING_RULE_DURATION       := p_record.ACCOUNTING_RULE_DURATION;
    x_api_rec.ACTUAL_ARRIVAL_DATE       := p_record.ACTUAL_ARRIVAL_DATE;
    x_api_rec.ACTUAL_SHIPMENT_DATE       := p_record.ACTUAL_SHIPMENT_DATE;
    x_api_rec.AGREEMENT_ID       := p_record.AGREEMENT_ID;
    x_api_rec.ARRIVAL_SET       := p_record.ARRIVAL_SET;
    x_api_rec.upgraded_flag       := p_record.upgraded_flag;
    x_api_rec.ARRIVAL_SET_ID       := p_record.ARRIVAL_SET_ID;
    x_api_rec.ATO_LINE_ID       := p_record.ATO_LINE_ID;
    x_api_rec.ATTRIBUTE1       := p_record.ATTRIBUTE1;
    x_api_rec.ATTRIBUTE10       := p_record.ATTRIBUTE10;
    x_api_rec.ATTRIBUTE11       := p_record.ATTRIBUTE11;
    x_api_rec.ATTRIBUTE12       := p_record.ATTRIBUTE12;
    x_api_rec.ATTRIBUTE13       := p_record.ATTRIBUTE13;
    x_api_rec.ATTRIBUTE14       := p_record.ATTRIBUTE14;
    x_api_rec.ATTRIBUTE15       := p_record.ATTRIBUTE15;
    x_api_rec.ATTRIBUTE16      := p_record.ATTRIBUTE16;   -- For bug 2184255
    x_api_rec.ATTRIBUTE17       := p_record.ATTRIBUTE17;
    x_api_rec.ATTRIBUTE18       := p_record.ATTRIBUTE18;
    x_api_rec.ATTRIBUTE19       := p_record.ATTRIBUTE19;
    x_api_rec.ATTRIBUTE2       := p_record.ATTRIBUTE2;
    x_api_rec.ATTRIBUTE20       := p_record.ATTRIBUTE20;
    x_api_rec.ATTRIBUTE3       := p_record.ATTRIBUTE3;
    x_api_rec.ATTRIBUTE4       := p_record.ATTRIBUTE4;
    x_api_rec.ATTRIBUTE5       := p_record.ATTRIBUTE5;
    x_api_rec.ATTRIBUTE6       := p_record.ATTRIBUTE6;
    x_api_rec.ATTRIBUTE7       := p_record.ATTRIBUTE7;
    x_api_rec.ATTRIBUTE8       := p_record.ATTRIBUTE8;
    x_api_rec.ATTRIBUTE9       := p_record.ATTRIBUTE9;
    x_api_rec.AUTHORIZED_TO_SHIP_FLAG       := p_record.AUTHORIZED_TO_SHIP_FLAG;
    x_api_rec.AUTO_SELECTED_QUANTITY       := p_record.AUTO_SELECTED_QUANTITY;
    x_api_rec.BOOKED_FLAG       := p_record.BOOKED_FLAG;
    x_api_rec.BLANKET_NUMBER            := p_record.BLANKET_NUMBER;
    x_api_rec.BLANKET_LINE_NUMBER       := p_record.BLANKET_LINE_NUMBER;
    x_api_rec.BLANKET_VERSION_NUMBER    := p_record.BLANKET_VERSION_NUMBER;
    x_api_rec.CALCULATE_PRICE_FLAG       := p_record.CALCULATE_PRICE_FLAG;
    x_api_rec.COMMITMENT_ID       := p_record.COMMITMENT_ID;
    x_api_rec.CANCELLED_FLAG       := p_record.CANCELLED_FLAG;
    x_api_rec.CANCELLED_QUANTITY       := p_record.CANCELLED_QUANTITY;
    x_api_rec.CANCELLED_QUANTITY2      := p_record.CANCELLED_QUANTITY2;
    x_api_rec.COMPONENT_CODE       := p_record.COMPONENT_CODE;
    x_api_rec.COMPONENT_NUMBER       := p_record.COMPONENT_NUMBER;
    x_api_rec.COMPONENT_SEQUENCE_ID       := p_record.COMPONENT_SEQUENCE_ID;
    x_api_rec.CONFIGURATION_ID       := p_record.CONFIGURATION_ID;
    x_api_rec.CONFIG_DISPLAY_SEQUENCE       := p_record.CONFIG_DISPLAY_SEQUENCE;
    x_api_rec.CONFIG_HEADER_ID       := p_record.CONFIG_HEADER_ID;
    x_api_rec.CONFIG_REV_NBR       := p_record.CONFIG_REV_NBR;
    x_api_rec.CONTEXT       := p_record.CONTEXT;
    x_api_rec.CREATED_BY       := p_record.CREATED_BY;
    x_api_rec.CREATION_DATE       := p_record.CREATION_DATE;
    x_api_rec.CREDIT_INVOICE_LINE_ID := p_record.CREDIT_INVOICE_LINE_ID;
    x_api_rec.CUSTOMER_DOCK_CODE       := p_record.CUSTOMER_DOCK_CODE;
    x_api_rec.CUSTOMER_JOB       := p_record.CUSTOMER_JOB;
    x_api_rec.CUSTOMER_PRODUCTION_LINE       := p_record.CUSTOMER_PRODUCTION_LINE;
    x_api_rec.CUSTOMER_TRX_LINE_ID       := p_record.CUSTOMER_TRX_LINE_ID;
    x_api_rec.CUST_MODEL_SERIAL_NUMBER       := p_record.CUST_MODEL_SERIAL_NUMBER;
    x_api_rec.CUST_PO_NUMBER       := p_record.CUST_PO_NUMBER;
    x_api_rec.CUSTOMER_LINE_NUMBER   := p_record.CUSTOMER_LINE_NUMBER;
    x_api_rec.CUST_PRODUCTION_SEQ_NUM       := p_record.CUST_PRODUCTION_SEQ_NUM;
    x_api_rec.DELIVERY_LEAD_TIME       := p_record.DELIVERY_LEAD_TIME;
    x_api_rec.DELIVER_TO_CONTACT_ID       := p_record.DELIVER_TO_CONTACT_ID;
    x_api_rec.DELIVER_TO_ORG_ID       := p_record.DELIVER_TO_ORG_ID;
    x_api_rec.DEMAND_BUCKET_TYPE_CODE       := p_record.DEMAND_BUCKET_TYPE_CODE;
    x_api_rec.DEMAND_CLASS_CODE       := p_record.DEMAND_CLASS_CODE;
    x_api_rec.DEP_PLAN_REQUIRED_FLAG       := p_record.DEP_PLAN_REQUIRED_FLAG;
    x_api_rec.EARLIEST_ACCEPTABLE_DATE       := p_record.EARLIEST_ACCEPTABLE_DATE;
    x_api_rec.END_ITEM_UNIT_NUMBER       := p_record.END_ITEM_UNIT_NUMBER;
    x_api_rec.EXPLOSION_DATE       := p_record.EXPLOSION_DATE;
    x_api_rec.FOB_POINT_CODE       := p_record.FOB_POINT_CODE;
    x_api_rec.FREIGHT_CARRIER_CODE       := p_record.FREIGHT_CARRIER_CODE;
    x_api_rec.FREIGHT_TERMS_CODE       := p_record.FREIGHT_TERMS_CODE;
    x_api_rec.FULFILLED_QUANTITY       := p_record.FULFILLED_QUANTITY;
    x_api_rec.FULFILLED_QUANTITY2      := p_record.FULFILLED_QUANTITY2;
    x_api_rec.FULFILLED_FLAG       := p_record.FULFILLED_FLAG;
    x_api_rec.FULFILLMENT_METHOD_CODE       := p_record.FULFILLMENT_METHOD_CODE;
    x_api_rec.FULFILLMENT_DATE       := p_record.FULFILLMENT_DATE;
    x_api_rec.GLOBAL_ATTRIBUTE1       := p_record.GLOBAL_ATTRIBUTE1;
    x_api_rec.GLOBAL_ATTRIBUTE10       := p_record.GLOBAL_ATTRIBUTE10;
    x_api_rec.GLOBAL_ATTRIBUTE11       := p_record.GLOBAL_ATTRIBUTE11;
    x_api_rec.GLOBAL_ATTRIBUTE12       := p_record.GLOBAL_ATTRIBUTE12;
    x_api_rec.GLOBAL_ATTRIBUTE13       := p_record.GLOBAL_ATTRIBUTE13;
    x_api_rec.GLOBAL_ATTRIBUTE14       := p_record.GLOBAL_ATTRIBUTE14;
    x_api_rec.GLOBAL_ATTRIBUTE15       := p_record.GLOBAL_ATTRIBUTE15;
    x_api_rec.GLOBAL_ATTRIBUTE16       := p_record.GLOBAL_ATTRIBUTE16;
    x_api_rec.GLOBAL_ATTRIBUTE17       := p_record.GLOBAL_ATTRIBUTE17;
    x_api_rec.GLOBAL_ATTRIBUTE18       := p_record.GLOBAL_ATTRIBUTE18;
    x_api_rec.GLOBAL_ATTRIBUTE19       := p_record.GLOBAL_ATTRIBUTE19;
    x_api_rec.GLOBAL_ATTRIBUTE2       := p_record.GLOBAL_ATTRIBUTE2;
    x_api_rec.GLOBAL_ATTRIBUTE20       := p_record.GLOBAL_ATTRIBUTE20;
    x_api_rec.GLOBAL_ATTRIBUTE3       := p_record.GLOBAL_ATTRIBUTE3;
    x_api_rec.GLOBAL_ATTRIBUTE4       := p_record.GLOBAL_ATTRIBUTE4;
    x_api_rec.GLOBAL_ATTRIBUTE5       := p_record.GLOBAL_ATTRIBUTE5;
    x_api_rec.GLOBAL_ATTRIBUTE6       := p_record.GLOBAL_ATTRIBUTE6;
    x_api_rec.GLOBAL_ATTRIBUTE7       := p_record.GLOBAL_ATTRIBUTE7;
    x_api_rec.GLOBAL_ATTRIBUTE8       := p_record.GLOBAL_ATTRIBUTE8;
    x_api_rec.GLOBAL_ATTRIBUTE9       := p_record.GLOBAL_ATTRIBUTE9;
    x_api_rec.GLOBAL_ATTRIBUTE_CATEGORY       := p_record.GLOBAL_ATTRIBUTE_CATEGORY;
    x_api_rec.HEADER_ID       := p_record.HEADER_ID;
    x_api_rec.INDUSTRY_ATTRIBUTE1       := p_record.INDUSTRY_ATTRIBUTE1;
    x_api_rec.INDUSTRY_ATTRIBUTE10       := p_record.INDUSTRY_ATTRIBUTE10;
    x_api_rec.INDUSTRY_ATTRIBUTE11       := p_record.INDUSTRY_ATTRIBUTE11;
    x_api_rec.INDUSTRY_ATTRIBUTE12       := p_record.INDUSTRY_ATTRIBUTE12;
    x_api_rec.INDUSTRY_ATTRIBUTE13       := p_record.INDUSTRY_ATTRIBUTE13;
    x_api_rec.INDUSTRY_ATTRIBUTE14       := p_record.INDUSTRY_ATTRIBUTE14;
    x_api_rec.INDUSTRY_ATTRIBUTE15       := p_record.INDUSTRY_ATTRIBUTE15;
    x_api_rec.INDUSTRY_ATTRIBUTE16       := p_record.INDUSTRY_ATTRIBUTE16;
    x_api_rec.INDUSTRY_ATTRIBUTE17       := p_record.INDUSTRY_ATTRIBUTE17;
    x_api_rec.INDUSTRY_ATTRIBUTE18       := p_record.INDUSTRY_ATTRIBUTE18;
    x_api_rec.INDUSTRY_ATTRIBUTE19       := p_record.INDUSTRY_ATTRIBUTE19;
    x_api_rec.INDUSTRY_ATTRIBUTE2       := p_record.INDUSTRY_ATTRIBUTE2;
    x_api_rec.INDUSTRY_ATTRIBUTE20       := p_record.INDUSTRY_ATTRIBUTE20;
    x_api_rec.INDUSTRY_ATTRIBUTE21       := p_record.INDUSTRY_ATTRIBUTE21;
    x_api_rec.INDUSTRY_ATTRIBUTE22       := p_record.INDUSTRY_ATTRIBUTE22;
    x_api_rec.INDUSTRY_ATTRIBUTE23       := p_record.INDUSTRY_ATTRIBUTE23;
    x_api_rec.INDUSTRY_ATTRIBUTE24       := p_record.INDUSTRY_ATTRIBUTE24;
    x_api_rec.INDUSTRY_ATTRIBUTE25       := p_record.INDUSTRY_ATTRIBUTE25;
    x_api_rec.INDUSTRY_ATTRIBUTE26       := p_record.INDUSTRY_ATTRIBUTE26;
    x_api_rec.INDUSTRY_ATTRIBUTE27       := p_record.INDUSTRY_ATTRIBUTE27;
    x_api_rec.INDUSTRY_ATTRIBUTE28       := p_record.INDUSTRY_ATTRIBUTE28;
    x_api_rec.INDUSTRY_ATTRIBUTE29       := p_record.INDUSTRY_ATTRIBUTE29;
    x_api_rec.INDUSTRY_ATTRIBUTE3       := p_record.INDUSTRY_ATTRIBUTE3;
    x_api_rec.INDUSTRY_ATTRIBUTE30       := p_record.INDUSTRY_ATTRIBUTE30;
    x_api_rec.INDUSTRY_ATTRIBUTE4       := p_record.INDUSTRY_ATTRIBUTE4;
    x_api_rec.INDUSTRY_ATTRIBUTE5       := p_record.INDUSTRY_ATTRIBUTE5;
    x_api_rec.INDUSTRY_ATTRIBUTE6       := p_record.INDUSTRY_ATTRIBUTE6;
    x_api_rec.INDUSTRY_ATTRIBUTE7       := p_record.INDUSTRY_ATTRIBUTE7;
    x_api_rec.INDUSTRY_ATTRIBUTE8       := p_record.INDUSTRY_ATTRIBUTE8;
    x_api_rec.INDUSTRY_ATTRIBUTE9       := p_record.INDUSTRY_ATTRIBUTE9;
    x_api_rec.INDUSTRY_CONTEXT       := p_record.INDUSTRY_CONTEXT;
    x_api_rec.INTERMED_SHIP_TO_CONTACT_ID       := p_record.INTERMED_SHIP_TO_CONTACT_ID;
    x_api_rec.INTERMED_SHIP_TO_ORG_ID       := p_record.INTERMED_SHIP_TO_ORG_ID;
    x_api_rec.INVENTORY_ITEM_ID       := p_record.INVENTORY_ITEM_ID;
    x_api_rec.INVOICE_INTERFACE_STATUS_CODE       := p_record.INVOICE_INTERFACE_STATUS_CODE;
    x_api_rec.INVOICE_TO_CONTACT_ID       := p_record.INVOICE_TO_CONTACT_ID;
    x_api_rec.INVOICE_TO_ORG_ID       := p_record.INVOICE_TO_ORG_ID;
    x_api_rec.INVOICED_QUANTITY       := p_record.INVOICED_QUANTITY;
    x_api_rec.INVOICING_RULE_ID       := p_record.INVOICING_RULE_ID;
    x_api_rec.ORDERED_ITEM_ID       := p_record.ORDERED_ITEM_ID;
    x_api_rec.ITEM_IDENTIFIER_TYPE       := p_record.ITEM_IDENTIFIER_TYPE;
    x_api_rec.ORDERED_ITEM       := p_record.ORDERED_ITEM;
    x_api_rec.ITEM_REVISION       := p_record.ITEM_REVISION;
    x_api_rec.ITEM_TYPE_CODE       := p_record.ITEM_TYPE_CODE;
    x_api_rec.LAST_UPDATED_BY       := p_record.LAST_UPDATED_BY;
    x_api_rec.LAST_UPDATE_DATE       := p_record.LAST_UPDATE_DATE;
    x_api_rec.LAST_UPDATE_LOGIN       := p_record.LAST_UPDATE_LOGIN;
    x_api_rec.LATEST_ACCEPTABLE_DATE       := p_record.LATEST_ACCEPTABLE_DATE;
    x_api_rec.LINE_CATEGORY_CODE       := p_record.LINE_CATEGORY_CODE;
    x_api_rec.LINE_ID       := p_record.LINE_ID;
    x_api_rec.LINE_NUMBER       := p_record.LINE_NUMBER;
    x_api_rec.LINE_TYPE_ID       := p_record.LINE_TYPE_ID;
    x_api_rec.LINK_TO_LINE_ID       := p_record.LINK_TO_LINE_ID;
    x_api_rec.MFG_COMPONENT_SEQUENCE_ID       := p_record.MFG_COMPONENT_SEQUENCE_ID;
    x_api_rec.MODEL_GROUP_NUMBER       := p_record.MODEL_GROUP_NUMBER;
    x_api_rec.OPEN_FLAG       := p_record.OPEN_FLAG;
    x_api_rec.OPTION_FLAG       := p_record.OPTION_FLAG;
    x_api_rec.OPTION_NUMBER       := p_record.OPTION_NUMBER;
    x_api_rec.ORDERED_QUANTITY       := p_record.ORDERED_QUANTITY;
    x_api_rec.ORDERED_QUANTITY2      := p_record.ORDERED_QUANTITY2;
    x_api_rec.ORDER_QUANTITY_UOM       := p_record.ORDER_QUANTITY_UOM;
    x_api_rec.ORDERED_QUANTITY_UOM2    := p_record.ORDERED_QUANTITY_UOM2;
    x_api_rec.ORG_ID       := p_record.ORG_ID;
    x_api_rec.ORIG_SYS_DOCUMENT_REF       := p_record.ORIG_SYS_DOCUMENT_REF;
    x_api_rec.ORIG_SYS_LINE_REF       := p_record.ORIG_SYS_LINE_REF;
    x_api_rec.OVER_SHIP_REASON_CODE       := p_record.OVER_SHIP_REASON_CODE;
    x_api_rec.OVER_SHIP_RESOLVED_FLAG       := p_record.OVER_SHIP_RESOLVED_FLAG;
    x_api_rec.PACKING_INSTRUCTIONS       := p_record.PACKING_INSTRUCTIONS;
    x_api_rec.PAYMENT_TERM_ID       := p_record.PAYMENT_TERM_ID;
    x_api_rec.PLANNING_PRIORITY       := p_record.PLANNING_PRIORITY;
    x_api_rec.PREFERRED_GRADE         := p_record.PREFERRED_GRADE;
    x_api_rec.PRICE_LIST_ID       := p_record.PRICE_LIST_ID;
    x_api_rec.PRICE_REQUEST_CODE    := p_record.PRICE_REQUEST_CODE;   -- PROMOTIONS SEP/01
    x_api_rec.PRICING_ATTRIBUTE1       := p_record.PRICING_ATTRIBUTE1;
    x_api_rec.PRICING_ATTRIBUTE10       := p_record.PRICING_ATTRIBUTE10;
    x_api_rec.PRICING_ATTRIBUTE2       := p_record.PRICING_ATTRIBUTE2;
    x_api_rec.PRICING_ATTRIBUTE3       := p_record.PRICING_ATTRIBUTE3;
    x_api_rec.PRICING_ATTRIBUTE4       := p_record.PRICING_ATTRIBUTE4;
    x_api_rec.PRICING_ATTRIBUTE5       := p_record.PRICING_ATTRIBUTE5;
    x_api_rec.PRICING_ATTRIBUTE6       := p_record.PRICING_ATTRIBUTE6;
    x_api_rec.PRICING_ATTRIBUTE7       := p_record.PRICING_ATTRIBUTE7;
    x_api_rec.PRICING_ATTRIBUTE8       := p_record.PRICING_ATTRIBUTE8;
    x_api_rec.PRICING_ATTRIBUTE9       := p_record.PRICING_ATTRIBUTE9;
    x_api_rec.PRICING_CONTEXT       := p_record.PRICING_CONTEXT;
    x_api_rec.PRICING_DATE       := p_record.PRICING_DATE;
    x_api_rec.PRICING_QUANTITY       := p_record.PRICING_QUANTITY;
    x_api_rec.PRICING_QUANTITY_UOM       := p_record.PRICING_QUANTITY_UOM;
    x_api_rec.PROGRAM_APPLICATION_ID       := p_record.PROGRAM_APPLICATION_ID;
    x_api_rec.PROGRAM_ID       := p_record.PROGRAM_ID;
    x_api_rec.PROGRAM_UPDATE_DATE       := p_record.PROGRAM_UPDATE_DATE;
    x_api_rec.PROJECT_ID       := p_record.PROJECT_ID;
    x_api_rec.PROMISE_DATE       := p_record.PROMISE_DATE;
    x_api_rec.RE_SOURCE_FLAG       := p_record.RE_SOURCE_FLAG;
    x_api_rec.REFERENCE_CUSTOMER_TRX_LINE_ID
              := p_record.REFERENCE_CUSTOMER_TRX_LINE_ID;
    x_api_rec.REFERENCE_HEADER_ID       := p_record.REFERENCE_HEADER_ID;
    x_api_rec.REFERENCE_LINE_ID       := p_record.REFERENCE_LINE_ID;
    x_api_rec.REFERENCE_TYPE       := p_record.REFERENCE_TYPE;
    x_api_rec.REQUEST_DATE       := p_record.REQUEST_DATE;
    x_api_rec.REQUEST_ID       := p_record.REQUEST_ID;
    -- Commenting this to fix bug 1391988.
   -- x_api_rec.RESERVED_QUANTITY       := p_record.RESERVED_QUANTITY;
    x_api_rec.RETURN_ATTRIBUTE1       := p_record.RETURN_ATTRIBUTE1;
    x_api_rec.RETURN_ATTRIBUTE10       := p_record.RETURN_ATTRIBUTE10;
    x_api_rec.RETURN_ATTRIBUTE11       := p_record.RETURN_ATTRIBUTE11;
    x_api_rec.RETURN_ATTRIBUTE12       := p_record.RETURN_ATTRIBUTE12;
    x_api_rec.RETURN_ATTRIBUTE13       := p_record.RETURN_ATTRIBUTE13;
    x_api_rec.RETURN_ATTRIBUTE14       := p_record.RETURN_ATTRIBUTE14;
    x_api_rec.RETURN_ATTRIBUTE15       := p_record.RETURN_ATTRIBUTE15;
    x_api_rec.RETURN_ATTRIBUTE2       := p_record.RETURN_ATTRIBUTE2;
    x_api_rec.RETURN_ATTRIBUTE3       := p_record.RETURN_ATTRIBUTE3;
    x_api_rec.RETURN_ATTRIBUTE4       := p_record.RETURN_ATTRIBUTE4;
    x_api_rec.RETURN_ATTRIBUTE5       := p_record.RETURN_ATTRIBUTE5;
    x_api_rec.RETURN_ATTRIBUTE6       := p_record.RETURN_ATTRIBUTE6;
    x_api_rec.RETURN_ATTRIBUTE7       := p_record.RETURN_ATTRIBUTE7;
    x_api_rec.RETURN_ATTRIBUTE8       := p_record.RETURN_ATTRIBUTE8;
    x_api_rec.RETURN_ATTRIBUTE9       := p_record.RETURN_ATTRIBUTE9;
    x_api_rec.RETURN_CONTEXT       := p_record.RETURN_CONTEXT;
    x_api_rec.RETURN_REASON_CODE       := p_record.RETURN_REASON_CODE;
    x_api_rec.RLA_SCHEDULE_TYPE_CODE       := p_record.RLA_SCHEDULE_TYPE_CODE;
    x_api_rec.SALESREP_ID       := p_record.SALESREP_ID;
    x_api_rec.SCHEDULE_ACTION_CODE       := p_record.SCHEDULE_ACTION_CODE;
    x_api_rec.SPLIT_ACTION_CODE       := p_record.SPLIT_ACTION_CODE;
    x_api_rec.SCHEDULE_ARRIVAL_DATE       := p_record.SCHEDULE_ARRIVAL_DATE;
    x_api_rec.SCHEDULE_SHIP_DATE       := p_record.SCHEDULE_SHIP_DATE;
    x_api_rec.SCHEDULE_STATUS_CODE       := p_record.SCHEDULE_STATUS_CODE;
    x_api_rec.SHIPMENT_NUMBER       := p_record.SHIPMENT_NUMBER;
    x_api_rec.SHIPMENT_PRIORITY_CODE       := p_record.SHIPMENT_PRIORITY_CODE;
    x_api_rec.SHIPPED_QUANTITY       := p_record.SHIPPED_QUANTITY;
    x_api_rec.SHIPPED_QUANTITY2      := p_record.SHIPPED_QUANTITY2;
    x_api_rec.SHIPPING_INTERFACED_FLAG       := p_record.SHIPPING_INTERFACED_FLAG;
    x_api_rec.SHIPPING_INSTRUCTIONS       := p_record.SHIPPING_INSTRUCTIONS;
    x_api_rec.SHIPPING_METHOD_CODE       := p_record.SHIPPING_METHOD_CODE;
    x_api_rec.SHIPPING_QUANTITY       := p_record.SHIPPING_QUANTITY;
    x_api_rec.SHIPPING_QUANTITY2      := p_record.SHIPPING_QUANTITY2;
    x_api_rec.SHIPPING_QUANTITY_UOM       := p_record.SHIPPING_QUANTITY_UOM;
    x_api_rec.SHIPPING_QUANTITY_UOM2      := p_record.SHIPPING_QUANTITY_UOM2;
    x_api_rec.SHIP_FROM_ORG_ID       := p_record.SHIP_FROM_ORG_ID;
    x_api_rec.SUBINVENTORY	     := p_record.SUBINVENTORY;
    x_api_rec.SHIP_MODEL_COMPLETE_FLAG       := p_record.SHIP_MODEL_COMPLETE_FLAG;
    x_api_rec.SHIP_SET       := p_record.SHIP_SET;
    x_api_rec.SHIP_SET_ID       := p_record.SHIP_SET_ID;
    x_api_rec.SHIP_TOLERANCE_ABOVE       := p_record.SHIP_TOLERANCE_ABOVE;
    x_api_rec.SHIP_TOLERANCE_BELOW       := p_record.SHIP_TOLERANCE_BELOW;
    x_api_rec.SHIP_TO_CONTACT_ID       := p_record.SHIP_TO_CONTACT_ID;
    x_api_rec.SHIP_TO_ORG_ID       := p_record.SHIP_TO_ORG_ID;
    x_api_rec.SOLD_FROM_ORG_ID       := p_record.SOLD_FROM_ORG_ID;
    x_api_rec.SOLD_TO_ORG_ID       := p_record.SOLD_TO_ORG_ID;
    x_api_rec.SORT_ORDER       := p_record.SORT_ORDER;
    x_api_rec.SOURCE_DOCUMENT_ID       := p_record.SOURCE_DOCUMENT_ID;
    x_api_rec.SOURCE_DOCUMENT_LINE_ID       := p_record.SOURCE_DOCUMENT_LINE_ID;
    x_api_rec.SOURCE_DOCUMENT_TYPE_ID       := p_record.SOURCE_DOCUMENT_TYPE_ID;
    x_api_rec.SOURCE_TYPE_CODE       := p_record.SOURCE_TYPE_CODE;
    x_api_rec.SPLIT_FROM_LINE_ID       := p_record.SPLIT_FROM_LINE_ID;
    x_api_rec.LINE_SET_ID       := p_record.LINE_SET_ID;
    x_api_rec.SPLIT_BY       := p_record.SPLIT_BY;
    x_api_rec.Model_remnant_flag  := p_record.Model_Remnant_Flag;
    x_api_rec.TASK_ID       := p_record.TASK_ID;
    x_api_rec.TAX_CODE       := p_record.TAX_CODE;
    x_api_rec.TAX_DATE       := p_record.TAX_DATE;
    x_api_rec.TAX_EXEMPT_FLAG       := p_record.TAX_EXEMPT_FLAG;
    x_api_rec.TAX_EXEMPT_NUMBER       := p_record.TAX_EXEMPT_NUMBER;
    x_api_rec.TAX_EXEMPT_REASON_CODE       := p_record.TAX_EXEMPT_REASON_CODE;
    x_api_rec.TAX_POINT_CODE       := p_record.TAX_POINT_CODE;
    x_api_rec.TAX_RATE       := p_record.TAX_RATE;
    x_api_rec.TAX_VALUE       := p_record.TAX_VALUE;
    x_api_rec.TOP_MODEL_LINE_ID       := p_record.TOP_MODEL_LINE_ID;
    x_api_rec.UNIT_LIST_PRICE       := p_record.UNIT_LIST_PRICE;
    x_api_rec.UNIT_SELLING_PRICE       := p_record.UNIT_SELLING_PRICE;
    x_api_rec.UNIT_LIST_PRICE_PER_PQTY       := p_record.UNIT_LIST_PRICE_PER_PQTY;
    x_api_rec.UNIT_SELLING_PRICE_PER_PQTY       := p_record.UNIT_SELLING_PRICE_PER_PQTY;
    x_api_rec.VEH_CUS_ITEM_CUM_KEY_ID       := p_record.VEH_CUS_ITEM_CUM_KEY_ID;
    x_api_rec.VISIBLE_DEMAND_FLAG       := p_record.VISIBLE_DEMAND_FLAG;
    x_api_rec.OPERATION			    := p_record.OPERATION;
    x_api_rec.RETURN_STATUS		    := p_record.RETURN_STATUS;
    x_api_rec.DB_FLAG			    := p_record.DB_FLAG;
    x_api_rec.CHANGE_REASON		    := p_record.CHANGE_REASON;
    x_api_rec.CHANGE_COMMENTS		    := p_record.CHANGE_COMMENTS;
    x_api_rec.SHIPPABLE_FLAG		    := p_record.SHIPPABLE_FLAG;
    x_api_rec.SERVICE_TXN_REASON_CODE  := p_record.SERVICE_TXN_REASON_CODE;
    x_api_rec.SERVICE_DURATION  := p_record.SERVICE_DURATION;
    x_api_rec.SERVICE_PERIOD  := p_record.SERVICE_PERIOD;
    x_api_rec.SERVICE_START_DATE  := p_record.SERVICE_START_DATE;
    x_api_rec.SERVICE_END_DATE  := p_record.SERVICE_END_DATE;
    x_api_rec.SERVICE_COTERMINATE_FLAG  := p_record.SERVICE_COTERMINATE_FLAG;
    x_api_rec.SERVICE_TXN_COMMENTS  := p_record.SERVICE_TXN_COMMENTS;
    x_api_rec.UNIT_SELLING_PERCENT  := p_record.UNIT_SELLING_PERCENT;
    x_api_rec.UNIT_LIST_PERCENT  := p_record.UNIT_LIST_PERCENT;
    x_api_rec.UNIT_PERCENT_BASE_PRICE  := p_record.UNIT_PERCENT_BASE_PRICE;
    x_api_rec.SERVICE_NUMBER  := p_record.SERVICE_NUMBER;
    x_api_rec.SERVICE_REFERENCE_TYPE_CODE  := p_record.SERVICE_REFERENCE_TYPE_CODE;
    x_api_rec.SERVICE_REFERENCE_LINE_ID  := p_record.SERVICE_REFERENCE_LINE_ID;
    x_api_rec.SERVICE_REFERENCE_SYSTEM_ID := p_record.SERVICE_REFERENCE_SYSTEM_ID;
    x_api_rec.FLOW_STATUS_CODE := p_record.FLOW_STATUS_CODE;
    x_api_rec.TP_ATTRIBUTE1       := p_record.TP_ATTRIBUTE1;
    x_api_rec.TP_ATTRIBUTE10       := p_record.TP_ATTRIBUTE10;
    x_api_rec.TP_ATTRIBUTE11       := p_record.TP_ATTRIBUTE11;
    x_api_rec.TP_ATTRIBUTE12       := p_record.TP_ATTRIBUTE12;
    x_api_rec.TP_ATTRIBUTE13       := p_record.TP_ATTRIBUTE13;
    x_api_rec.TP_ATTRIBUTE14       := p_record.TP_ATTRIBUTE14;
    x_api_rec.TP_ATTRIBUTE15       := p_record.TP_ATTRIBUTE15;
    x_api_rec.TP_ATTRIBUTE2       := p_record.TP_ATTRIBUTE2;
    x_api_rec.TP_ATTRIBUTE3       := p_record.TP_ATTRIBUTE3;
    x_api_rec.TP_ATTRIBUTE4       := p_record.TP_ATTRIBUTE4;
    x_api_rec.TP_ATTRIBUTE5       := p_record.TP_ATTRIBUTE5;
    x_api_rec.TP_ATTRIBUTE6       := p_record.TP_ATTRIBUTE6;
    x_api_rec.TP_ATTRIBUTE7       := p_record.TP_ATTRIBUTE7;
    x_api_rec.TP_ATTRIBUTE8       := p_record.TP_ATTRIBUTE8;
    x_api_rec.TP_ATTRIBUTE9       := p_record.TP_ATTRIBUTE9;
    x_api_rec.TP_CONTEXT          := p_record.TP_CONTEXT;
    x_api_rec.FIRST_ACK_CODE      := p_record.FIRST_ACK_CODE;
    x_api_rec.FIRST_ACK_DATE      := p_record.FIRST_ACK_DATE;
    x_api_rec.LAST_ACK_CODE      := p_record.LAST_ACK_CODE;
    x_api_rec.LAST_ACK_DATE      := p_record.LAST_ACK_DATE;
    x_api_rec.USER_ITEM_DESCRIPTION := p_record.USER_ITEM_DESCRIPTION;
    -- QUOTING changes
    x_api_rec.transaction_phase_code := p_record.transaction_phase_code;
    x_api_rec.source_document_version_number :=
                                p_record.source_document_version_number;
   x_api_rec.IB_OWNER      := p_record.IB_OWNER;
   x_api_rec.IB_INSTALLED_AT_LOCATION      := p_record.IB_INSTALLED_AT_LOCATION;
   x_api_rec.IB_CURRENT_LOCATION      := p_record.IB_CURRENT_LOCATION;
   x_api_rec.END_CUSTOMER_ID      := p_record.END_CUSTOMER_ID;
  x_api_rec.END_CUSTOMER_CONTACT_ID      := p_record.END_CUSTOMER_CONTACT_ID;
  x_api_rec.END_CUSTOMER_SITE_USE_ID      := p_record.END_CUSTOMER_SITE_USE_ID;

  --retro{
  x_api_rec.retrobill_request_id := p_record.retrobill_request_id;
  --retro}
  --key Transaction dates Project
  x_api_rec.order_firmed_date   := p_record.order_firmed_date;
  x_api_rec.actual_fulfillment_date := p_record.actual_fulfillment_date;
   --Customer Acceptance
   x_api_rec.CONTINGENCY_ID            := p_record.CONTINGENCY_ID;
   x_api_rec.REVREC_EVENT_CODE         := p_record.REVREC_EVENT_CODE;
   x_api_rec.REVREC_EXPIRATION_DAYS    := p_record.REVREC_EXPIRATION_DAYS;
   x_api_rec.ACCEPTED_QUANTITY         := p_record.ACCEPTED_QUANTITY;
   x_api_rec.REVREC_COMMENTS           := p_record.REVREC_COMMENTS;
   x_api_rec.REVREC_SIGNATURE          := p_record.REVREC_SIGNATURE;
   x_api_rec.REVREC_SIGNATURE_DATE     := p_record.REVREC_SIGNATURE_DATE;
   x_api_rec.ACCEPTED_BY               := p_record.ACCEPTED_BY;
   x_api_rec.REVREC_REFERENCE_DOCUMENT := p_record.REVREC_REFERENCE_DOCUMENT;
   x_api_rec.REVREC_IMPLICIT_FLAG      := p_record.REVREC_IMPLICIT_FLAG;
   x_api_rec.charge_periodicity_code      := p_record.charge_periodicity_code; --Rakesh

EXCEPTION
  WHEN OTHERS THEN
        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rowtype_Rec_To_API_Rec'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Rowtype_Rec_To_API_Rec;

-- PROCEDURE Clear_Dependent_Attr
-- This version of the clear dependent attributes procedure is called
--  from the generated entity defaulting handler packages to clear
-- the dependents if the new defaulted value is different from the
-- old value on the record. The record types here of view%rowtype
-- as the defaulting packages operate only on these record types.
-- Arguments:
-- p_attr_id: if passed, then clear attributes dependent only on
--			this attribute else compare p_old_line_rec and p_line_rec
--			and clear attributes dependent on all the change attributes
-- p_initial_line_rec: this is the initial record passed to the process
--			order or the defaulting APIs and is used to identify which
--			attributes are user-specified so that they are not cleared
-- p_old_line_rec: the old record as it was before the changes
-- p_x_line_rec: the current record with the user-specified changes and
--			attributes that may have defaulted prior to this call
PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_initial_line_rec              IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   p_old_line_rec                  IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   p_x_line_rec                    IN  OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
)
IS
l_index                 NUMBER :=0;
l_src_attr_tbl          OE_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_exists       VARCHAR2(1);
BEGIN

    oe_debug_pub.add('Entering OE_LINE_UTIL.CLEAR_DEPENDENT_ATTR', 1);
    oe_debug_pub.add('Attr Id: '||p_attr_id);


    IF p_attr_id <> FND_API.G_MISS_NUM THEN

            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := p_attr_id;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    ELSE

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.ACCOUNTING_RULE_ID,p_old_line_rec.ACCOUNTING_RULE_ID)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_ACCOUNTING_RULE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.AGREEMENT_ID,p_old_line_rec.AGREEMENT_ID)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_AGREEMENT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.blanket_number,p_old_line_rec.blanket_number)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_BLANKET_NUMBER;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.blanket_line_number,p_old_line_rec.blanket_line_number)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_BLANKET_LINE_NUMBER;
        END IF;

	--bug5160469
	IF NOT OE_GLOBALS.Equal(p_x_line_rec.commitment_id,p_old_line_rec.commitment_id)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_COMMITMENT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.DELIVER_TO_ORG_ID,p_old_line_rec.DELIVER_TO_ORG_ID)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_DELIVER_TO_ORG;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.INTERMED_SHIP_TO_ORG_ID,p_old_line_rec.INTERMED_SHIP_TO_ORG_ID)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_INTERMED_SHIP_TO_ORG;
        END IF;



        IF NOT OE_GLOBALS.Equal(p_x_line_rec.INVENTORY_ITEM_ID,p_old_line_rec.INVENTORY_ITEM_ID)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_INVENTORY_ITEM;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.INVOICE_TO_ORG_ID,p_old_line_rec.INVOICE_TO_ORG_ID)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_INVOICE_TO_ORG;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.LINE_NUMBER,p_old_line_rec.LINE_NUMBER)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_LINE_NUMBER;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.LINE_TYPE_ID,p_old_line_rec.LINE_TYPE_ID)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_LINE_TYPE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.PRICE_LIST_ID,p_old_line_rec.PRICE_LIST_ID)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_PRICE_LIST;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.PROMISE_DATE,p_old_line_rec.PROMISE_DATE)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_PROMISE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.REQUEST_DATE,p_old_line_rec.REQUEST_DATE)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_REQUEST_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.SCHEDULE_SHIP_DATE,p_old_line_rec.SCHEDULE_SHIP_DATE)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_SCHEDULE_SHIP_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.SHIP_FROM_ORG_ID,p_old_line_rec.SHIP_FROM_ORG_ID)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_SHIP_FROM_ORG;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.SUBINVENTORY,p_old_line_rec.SUBINVENTORY)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_SUBINVENTORY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.SHIP_TO_ORG_ID,p_old_line_rec.SHIP_TO_ORG_ID)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_SHIP_TO_ORG;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.SOLD_TO_ORG_ID,p_old_line_rec.SOLD_TO_ORG_ID)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_SOLD_TO_ORG;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.TAX_CODE,p_old_line_rec.TAX_CODE)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_TAX;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.TAX_DATE,p_old_line_rec.TAX_DATE)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_TAX_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.TAX_EXEMPT_FLAG,p_old_line_rec.TAX_EXEMPT_FLAG)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_TAX_EXEMPT;
        END IF;
        --Added following condition for Bug 2245073
        IF NOT OE_GLOBALS.Equal(p_x_line_rec.PRICING_DATE, p_old_line_rec.PRICING_DATE
) Then
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_PRICING_DATE;
        End If;

        -- The next two IF statements added for bug 5076119
        IF NOT OE_GLOBALS.Equal(p_x_line_rec.ORDERED_QUANTITY, p_old_line_rec.ORDERED_QUANTITY)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_ORDERED_QUANTITY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_rec.ORDER_QUANTITY_UOM, p_old_line_rec.ORDER_QUANTITY_UOM)
        THEN
            l_index := l_index + 1.0;
            l_src_attr_tbl(l_index) := OE_LINE_UTIL.G_ORDER_QUANTITY_UOM;
        END IF;


    END IF;

    Clear_Dependents
			(p_src_attr_tbl 	=> l_src_attr_tbl
			,p_initial_line_rec => p_initial_line_rec
			,p_old_line_rec     => p_old_line_rec
		    	,p_x_line_rec		=> p_x_line_rec
                        ,x_dep_attr_exists  => l_dep_attr_exists);

    oe_debug_pub.add('Exiting OE_LINE_UTIL.CLEAR_DEPENDENT_ATTR', 1);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	WHEN OTHERS THEN
 	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    		OE_MSG_PUB.Add_Exc_Msg
         	(   G_PKG_NAME
         	,   'Clear_Dependent_Attr'
         	);
     END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Clear_Dependent_Attr;

-- PROCEDURE Clear_Dependent_Attr
-- This version of the clear dependent attributes procedure is called
-- from the private process order API (OE_Order_PVT) to clear the
-- dependents if control_rec.clear_dependents is TRUE. The record
-- types are of the type OE_Order_PUB.<Entity>_rec_Type
-- Arguments:
-- p_attr_id: if passed, then clear attributes dependent only on
--			this attribute else compare p_old_line_rec and p_x_line_rec
--			and clear attributes dependent on all the change attributes
-- p_old_line_rec: the old record as it was before the changes
-- p_x_line_rec: the current record with the user-specified changes
PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_line_rec                    IN  OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
)
IS
l_line_rec		OE_AK_ORDER_LINES_V%ROWTYPE;
l_initial_line_rec		OE_AK_ORDER_LINES_V%ROWTYPE;
l_old_line_rec		OE_AK_ORDER_LINES_V%ROWTYPE;
BEGIN

    API_Rec_To_RowType_Rec(p_x_line_rec, l_line_rec);
    API_Rec_To_RowType_Rec(p_old_line_rec, l_old_line_rec);

    -- Initial rec is same as current record here as this procedure is
    -- called before defaulting and the current record is the same as
    -- that passed to process order with the user-specified changes only
    l_initial_line_rec := l_line_rec;

	Clear_Dependent_Attr
		( p_attr_id	=> p_attr_id
		, p_initial_line_rec => l_initial_line_rec
		, p_old_line_rec => l_old_line_rec
		, p_x_line_rec	=> l_line_rec
		);

     RowType_Rec_To_API_Rec(l_line_rec, p_x_line_rec);

END Clear_Dependent_Attr;

--  13-DEC-01 Introduced new procedure - clear_dep_and_default.
-- This procedure will be used to detect if there was a dependent
-- attribute that is changed and re-defaulted in the call or not.
PROCEDURE Clear_Dep_And_Default
(   p_src_attr_tbl                  IN  OE_GLOBALS.Number_Tbl_Type
,   p_x_line_rec                    IN  OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type
)IS
l_line_rec		OE_AK_ORDER_LINES_V%ROWTYPE;
l_initial_line_rec		OE_AK_ORDER_LINES_V%ROWTYPE;
l_old_line_rec		OE_AK_ORDER_LINES_V%ROWTYPE;
l_dep_attr_exists       VARCHAR2(1);
BEGIN

    API_Rec_To_RowType_Rec(p_x_line_rec, l_line_rec);
    API_Rec_To_RowType_Rec(p_old_line_rec, l_old_line_rec);

    -- Initial rec is same as current record here as this procedure is
    -- called before defaulting and the current record is the same as
    -- that passed to process order with the user-specified changes only
    l_initial_line_rec := l_line_rec;

    -- Initialize the global to 'N'
    OE_GLOBALS.G_ATTR_UPDATED_BY_DEF := 'N';

    Clear_Dependents
		( p_src_attr_tbl      => p_src_attr_tbl
		, p_initial_line_rec  => l_initial_line_rec
		, p_old_line_rec      => l_old_line_rec
		, p_x_line_rec	      => l_line_rec
                , x_dep_attr_exists   => l_dep_attr_exists
		);

    IF l_dep_attr_exists = 'N' THEN
       oe_debug_pub.add('No Dep Attributes');
       RETURN;
    END IF;

    RowType_Rec_To_API_Rec(l_line_rec, p_x_line_rec);

    OE_Default_Line.Attributes
                ( p_x_line_rec        => p_x_line_rec
                , p_old_line_rec      => p_old_line_rec
                );

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	WHEN OTHERS THEN
 	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    		OE_MSG_PUB.Add_Exc_Msg
         	(   G_PKG_NAME
         	,   'Clear_Dep_And_Default'
         	);
        END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Clear_Dep_And_Default;

END OE_Line_Util_Ext;

/
