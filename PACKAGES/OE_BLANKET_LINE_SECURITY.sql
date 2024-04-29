--------------------------------------------------------
--  DDL for Package OE_BLANKET_LINE_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BLANKET_LINE_SECURITY" AUTHID CURRENT_USER AS
/* $Header: OEXXBLNS.pls 120.0.12000000.2 2007/10/31 06:50:06 smmathew ship $ */


-- Package Globals
g_check_all_cols_constraint VARCHAR2(1) := 'Y';
g_is_caller_defaulting      VARCHAR2(1) := 'N';
-- Entity global record that is used in APIs for validation templates
-- and the generated validation packages to access attribute values
-- on the entity record
g_record				   OE_AK_BLANKET_LINES_V%ROWTYPE;

FUNCTION ACCOUNTING_RULE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION CUST_PO_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION DELIVER_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION FREIGHT_TERMS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION INVENTORY_ITEM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION INVOICE_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION INVOICING_RULE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION LINE_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ORDER_QUANTITY_UOM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION PACKING_INSTRUCTIONS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION PAYMENT_TERM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION PRICE_LIST
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION PRICING_QUANTITY_UOM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION SALESREP
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION SHIPPING_INSTRUCTIONS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION SHIPPING_METHOD
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION SHIP_FROM_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION SHIP_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION UNIT_LIST_PRICE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

/*1449220*/
FUNCTION ITEM_IDENTIFIER_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;
/*1449220*/

FUNCTION START_DATE_ACTIVE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION END_DATE_ACTIVE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION PREFERRED_GRADE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ENFORCE_SHIP_TO_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ENFORCE_FREIGHT_TERM_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ENFORCE_SHIPPING_METHOD_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ENFORCE_INVOICE_TO_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ENFORCE_PRICE_LIST_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ENFORCE_PAYMENT_TERM_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ENFORCE_ACCOUNTING_RULE_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ENFORCE_INVOICING_RULE_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION BLANKET_LINE_MIN_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION BLANKET_LINE_MAX_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION BLANKET_MIN_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION BLANKET_MAX_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION MIN_RELEASE_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION MAX_RELEASE_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION MIN_RELEASE_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION MAX_RELEASE_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION OVERRIDE_BLANKET_CONTROLS_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION OVERRIDE_RELEASE_CONTROLS_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;


PROCEDURE ALLOW_TRX_LINE_EXEMPTIONS
( p_application_id                  IN NUMBER,
  p_entity_short_name               IN VARCHAR2,
  p_validation_entity_short_name    IN VARCHAR2,
  p_validation_tmplt_short_name     IN VARCHAR2,
  p_record_set_tmplt_short_name     IN VARCHAR2,
  p_scope                           IN VARCHAR2,
  p_result                          OUT NOCOPY NUMBER
);

PROCEDURE Entity
(   p_LINE_rec                      IN  Oe_Blanket_Pub.LINE_Rec_Type
,   x_result                        OUT NOCOPY NUMBER
,   x_return_status                 OUT NOCOPY VARCHAR2
);

PROCEDURE Attributes
(   p_LINE_rec                      IN  Oe_Blanket_Pub.LINE_Rec_Type
,   p_old_LINE_rec                  IN  Oe_Blanket_Pub.LINE_Rec_Type := Oe_Blanket_Pub.G_MISS_BLANKET_LINE_REC
,   x_result                        OUT NOCOPY NUMBER
,   x_return_status                 OUT NOCOPY VARCHAR2
);

--bug6531947
FUNCTION CONTEXT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE1
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE2
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE3
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE4
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE5
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE6
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE7
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE8
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE9
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE10
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE11
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE12
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE13
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE14
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE15
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE16
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE17
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE18
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE19
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION ATTRIBUTE20
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER;


END OE_Blanket_Line_Security;

 

/
