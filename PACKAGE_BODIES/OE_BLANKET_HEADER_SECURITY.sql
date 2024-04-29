--------------------------------------------------------
--  DDL for Package Body OE_BLANKET_HEADER_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BLANKET_HEADER_SECURITY" AS
/* $Header: OEXXBHDB.pls 120.2.12010000.2 2008/08/04 15:09:57 amallik ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Blanket_Header_Security';

-- LOCAL PROCEDURES


FUNCTION Is_Op_Constrained
( p_operation           IN VARCHAR2
 , p_column_name         IN VARCHAR2 DEFAULT NULL
 , p_record       IN OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER IS
l_constraint_id	NUMBER;
l_grp	NUMBER;
l_result		NUMBER;
l_column_name	VARCHAR2(30);
l_audit_trail_enabled VARCHAR2(1) := OE_SYS_PARAMETERS.VALUE('AUDIT_TRAIL_ENABLE_FLAG');
l_code_level varchar2(6) := OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

l_result := OE_PC_Constraints_Admin_PVT.Is_OP_constrained
    ( p_responsibility_id     => nvl(fnd_global.resp_id, -1)
    , p_application_id          => nvl(fnd_global.resp_appl_id,-1) --added for bug3631547
    , p_operation   => p_operation
    , p_qualifier_attribute => p_record.transaction_phase_code
    , p_entity_id   => OE_PC_GLOBALS.G_ENTITY_BLANKET_HEADER
    , p_column_name => p_column_name
    , p_check_all_cols_constraint  => g_check_all_cols_constraint
    , p_is_caller_defaulting  => g_is_caller_defaulting
    , x_constraint_id    => l_constraint_id
    , x_constraining_conditions_grp     => l_grp
    , x_on_operation_action   => x_on_operation_action
    );

if l_result = OE_PC_GLOBALS.YES then

    IF g_check_all_cols_constraint = 'Y'
       AND (p_operation = OE_PC_GLOBALS.UPDATE_OP
            OR p_operation = OE_PC_GLOBALS.CREATE_OP)
       AND p_column_name IS NOT NULL THEN
        SELECT column_name
        INTO l_column_name
        FROM oe_pc_constraints
        WHERE constraint_id = l_constraint_id;
        if l_column_name is null  and x_on_operation_action = 0 then
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'CONSTRAINT ON UPDATE OF ALL COLUMNS!' ) ;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        end if;
    END IF;

elsif l_result = OE_PC_GLOBALS.ERROR then

    raise FND_API.G_EXC_UNEXPECTED_ERROR;

end if;

g_check_all_cols_constraint := 'N';

/* Start Versioning */
IF l_code_level >= '110510' AND
  ( p_column_name = 'TRANSACTION_PHASE_CODE' OR
    x_on_operation_action IN (.1,.2))THEN
   OE_Versioning_Util.Check_Security(p_column_name => p_column_name,
                   p_on_operation_action => x_on_operation_action);
END IF;
/* End Versioning */

/* Start AuditTrail */
/*
IF g_is_caller_defaulting = 'N' THEN
   IF l_code_level >= '110508' and nvl(l_audit_trail_enabled,'D') <> 'D' THEN
      IF l_audit_trail_enabled = 'B' THEN  -- capture only for booked orders
         IF p_record.booked_flag = 'Y' THEN
            IF l_result = OE_PC_GLOBALS.YES THEN
               IF x_on_operation_action = 1 THEN
                  -- set OUT result to NOT CONSTRAINED
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'HEADER SECURITY , ATTRIBUTE CHANGE REQUIRES REASON' , 1 ) ;
                  END IF;
                  OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
                  OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
               ELSIF x_on_operation_action = 2 THEN
                  -- set OUT result to NOT CONSTRAINED
                  IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG <> 'Y' then
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'HEADER SECURITY , ATTRIBUTE CHANGE REQUIRES HISTORY' , 1 ) ;
                     END IF;
	             OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'Y';
                  END IF;
               END IF;
            END IF;
         END IF;
      ELSE -- capture audit trail for all orders
         IF l_result = OE_PC_GLOBALS.YES THEN
            IF x_on_operation_action = 1 THEN
               -- set OUT result to NOT CONSTRAINED
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'HEADER SECURITY , ATTRIBUTE CHANGE REQUIRES REASON' , 1 ) ;
               END IF;
               OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
               OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
            ELSIF x_on_operation_action = 2 THEN
               -- set OUT result to NOT CONSTRAINED
               IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG <> 'Y' then
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'HEADER SECURITY , ATTRIBUTE CHANGE REQUIRES HISTORY' , 1 ) ;
                  END IF;
	          OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'Y';
               END IF;
            END IF;
         END IF;
      END IF;
   END IF;
END IF;
*/
/* End AuditTrail */
IF x_on_operation_action > 0 THEN
   l_result := OE_PC_GLOBALS.NO;
END IF;
RETURN l_result;

END Is_Op_Constrained;


-- PUBLIC PROCEDURES


FUNCTION ACCOUNTING_RULE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'ACCOUNTING_RULE_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END ACCOUNTING_RULE;

FUNCTION CONVERSION_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'CONVERSION_TYPE_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END CONVERSION_TYPE;


FUNCTION CUST_PO_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'CUST_PO_NUMBER'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END CUST_PO_NUMBER;


FUNCTION DELIVER_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'DELIVER_TO_ORG_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END DELIVER_TO_ORG;


FUNCTION FREIGHT_TERMS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'FREIGHT_TERMS_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END FREIGHT_TERMS;


FUNCTION INVOICE_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'INVOICE_TO_ORG_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END INVOICE_TO_ORG;

FUNCTION INVOICING_RULE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'INVOICING_RULE_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END INVOICING_RULE;

FUNCTION ORDER_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'ORDER_NUMBER'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END ORDER_NUMBER;

FUNCTION ORDER_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'ORDER_TYPE_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END ORDER_TYPE;


FUNCTION PACKING_INSTRUCTIONS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'PACKING_INSTRUCTIONS'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END PACKING_INSTRUCTIONS;


FUNCTION PAYMENT_TERM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'PAYMENT_TERM_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END PAYMENT_TERM;


FUNCTION PRICE_LIST
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'PRICE_LIST_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END PRICE_LIST;


FUNCTION SALESREP
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SALESREP_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SALESREP;


FUNCTION SHIPPING_INSTRUCTIONS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SHIPPING_INSTRUCTIONS'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SHIPPING_INSTRUCTIONS;

FUNCTION SHIPPING_METHOD
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SHIPPING_METHOD_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SHIPPING_METHOD;


FUNCTION SHIP_FROM_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SHIP_FROM_ORG_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SHIP_FROM_ORG;


FUNCTION SHIP_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SHIP_TO_ORG_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SHIP_TO_ORG;


FUNCTION SOLD_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SOLD_TO_CONTACT_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SOLD_TO_CONTACT;


FUNCTION SOLD_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SOLD_TO_ORG_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SOLD_TO_ORG;


FUNCTION TRANSACTIONAL_CURR
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'TRANSACTIONAL_CURR_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END TRANSACTIONAL_CURR;

FUNCTION ENFORCE_ACCOUNTING_RULE_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ENFORCE_ACCOUNTING_RULE_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ENFORCE_ACCOUNTING_RULE_FLAG;

FUNCTION ENFORCE_INVOICE_TO_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ENFORCE_INVOICE_TO_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ENFORCE_INVOICE_TO_FLAG;

FUNCTION ENFORCE_PRICE_LIST_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ENFORCE_PRICE_LIST_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ENFORCE_PRICE_LIST_FLAG;

FUNCTION ENFORCE_PAYMENT_TERM_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ENFORCE_PAYMENT_TERM_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ENFORCE_PAYMENT_TERM_FLAG;

FUNCTION ENFORCE_INVOICING_RULE_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ENFORCE_INVOICING_RULE_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ENFORCE_INVOICING_RULE_FLAG;

FUNCTION ENFORCE_SHIP_TO_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ENFORCE_SHIP_TO_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ENFORCE_SHIP_TO_FLAG;

FUNCTION ENFORCE_FREIGHT_TERM_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ENFORCE_FREIGHT_TERM_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ENFORCE_FREIGHT_TERM_FLAG;

FUNCTION ENFORCE_SHIPPING_METHOD_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ENFORCE_SHIPPING_METHOD_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ENFORCE_SHIPPING_METHOD_FLAG;

FUNCTION START_DATE_ACTIVE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'START_DATE_ACTIVE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END START_DATE_ACTIVE;

FUNCTION END_DATE_ACTIVE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'END_DATE_ACTIVE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END END_DATE_ACTIVE;

FUNCTION BLANKET_MIN_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'BLANKET_MIN_AMOUNT'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END BLANKET_MIN_AMOUNT;

FUNCTION BLANKET_MAX_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'BLANKET_MAX_AMOUNT'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END BLANKET_MAX_AMOUNT;

FUNCTION VERSION_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'VERSION_NUMBER'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END VERSION_NUMBER;

FUNCTION REVISION_CHANGE_REASON
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'REVISION_CHANGE_REASON'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END REVISION_CHANGE_REASON;

FUNCTION REVISION_CHANGE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'REVISION_CHANGE_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END REVISION_CHANGE_DATE;

FUNCTION REVISION_CHANGE_COMMENTS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'REVISION_CHANGE_COMMENTS'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END REVISION_CHANGE_COMMENTS;

FUNCTION OVERRIDE_AMOUNT_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'OVERRIDE_AMOUNT_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END OVERRIDE_AMOUNT_FLAG;

FUNCTION TRANSACTION_PHASE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'TRANSACTION_PHASE_CODE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END TRANSACTION_PHASE;

FUNCTION SOLD_TO_SITE_USE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SOLD_TO_SITE_USE_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SOLD_TO_SITE_USE;

FUNCTION SALES_DOCUMENT_NAME
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SALES_DOCUMENT_NAME'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SALES_DOCUMENT_NAME;

FUNCTION CUSTOMER_SIGNATURE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'CUSTOMER_SIGNATURE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END CUSTOMER_SIGNATURE;

FUNCTION CUSTOMER_SIGNATURE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'CUSTOMER_SIGNATURE_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END CUSTOMER_SIGNATURE_DATE;

FUNCTION SUPPLIER_SIGNATURE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SUPPLIER_SIGNATURE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SUPPLIER_SIGNATURE;

FUNCTION SUPPLIER_SIGNATURE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SUPPLIER_SIGNATURE_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SUPPLIER_SIGNATURE_DATE;

FUNCTION USER_STATUS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'USER_STATUS_CODE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END USER_STATUS;

FUNCTION NEW_PRICE_LIST
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'NEW_PRICE_LIST_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END NEW_PRICE_LIST;

FUNCTION NEW_MODIFIER_LIST
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'NEW_MODIFIER_LIST_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END NEW_MODIFIER_LIST;

FUNCTION DEFAULT_DISCOUNT_PERCENT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'DEFAULT_DISCOUNT_PERCENT'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END DEFAULT_DISCOUNT_PERCENT;

FUNCTION DEFAULT_DISCOUNT_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'DEFAULT_DISCOUNT_AMOUNT'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END DEFAULT_DISCOUNT_AMOUNT;

--bug6531947
FUNCTION CONTEXT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'CONTEXT'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END CONTEXT;

FUNCTION ATTRIBUTE1
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE1'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE1;

FUNCTION ATTRIBUTE2
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE2'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE2;

FUNCTION ATTRIBUTE3
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE3'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE3;

FUNCTION ATTRIBUTE4
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE4'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE4;

FUNCTION ATTRIBUTE5
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE5'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE5;

FUNCTION ATTRIBUTE6
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE6'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE6;

FUNCTION ATTRIBUTE7
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE7'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE7;

FUNCTION ATTRIBUTE8
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE8'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE8;

FUNCTION ATTRIBUTE9
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE9'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE9;

FUNCTION ATTRIBUTE10
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE10'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE10;

FUNCTION ATTRIBUTE11
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE11'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE11;

FUNCTION ATTRIBUTE12
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE12'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE12;

FUNCTION ATTRIBUTE13
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE13'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE13;

FUNCTION ATTRIBUTE14
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE14'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE14;

FUNCTION ATTRIBUTE15
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE15'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE15;

FUNCTION ATTRIBUTE16
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE16'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE16;

FUNCTION ATTRIBUTE17
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE17'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE17;

FUNCTION ATTRIBUTE18
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE18'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE18;

FUNCTION ATTRIBUTE19
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE19'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE19;

FUNCTION ATTRIBUTE20
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ATTRIBUTE20'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE20;

PROCEDURE Entity
(   p_HEADER_rec                    IN  OE_Blanket_Pub.HEADER_Rec_Type
, x_result OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

) IS
l_operation	VARCHAR2(1);
l_on_operation_action	NUMBER;
l_rowtype_rec	OE_AK_BLANKET_HEADERS_V%ROWTYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTER OE_BLANKET_HEADER_SECURITY.ENTITY' , 1 ) ;
END IF;

-- Initializing return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF p_HEADER_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
    l_operation := OE_PC_GLOBALS.CREATE_OP;
ELSIF p_HEADER_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_operation := OE_PC_GLOBALS.UPDATE_OP;
ELSIF p_HEADER_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
    l_operation := OE_PC_GLOBALS.DELETE_OP;
ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INVALID OPERATION' , 1 ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
END IF;

OE_BLANKET_UTIL.API_Rec_To_Rowtype_Rec(p_HEADER_rec, l_rowtype_rec);

-- Initialize security global record
OE_Blanket_Header_Security.g_record := l_rowtype_rec;

x_result := Is_OP_constrained
    (p_operation	=> l_operation
    ,p_record	=> l_rowtype_rec
    ,x_on_operation_action	=> l_on_operation_action
    );

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXIT OE_BLANKET_HEADER_SECURITY.ENTITY' , 1 ) ;
END IF;

EXCEPTION
    WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Entity'
        );
    END IF;

END Entity;


PROCEDURE Attributes
(   p_HEADER_rec                    IN  OE_Blanket_Pub.HEADER_Rec_Type
,   p_old_HEADER_rec                IN  OE_Blanket_Pub.HEADER_Rec_Type := OE_Blanket_Pub.G_MISS_HEADER_REC
, x_result OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

) IS
l_operation	VARCHAR2(1);
l_on_operation_action  NUMBER;
l_result		NUMBER;
l_rowtype_rec	OE_AK_BLANKET_HEADERS_V%ROWTYPE;
l_column_name	VARCHAR2(30);
l_active_flag   VARCHAR2(1);
e_inacitve_pl   EXCEPTION;
l_check_all_cols_constraint VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTER OE_BLANKET_HEADER_SECURITY.ATTRIBUTES' , 1 ) ;
    oe_debug_pub.add(  'new sold_to_org_id' || p_header_rec.sold_to_org_id ) ;
    oe_debug_pub.add(  'old sold_to_org_id' || p_old_header_rec.sold_to_org_id ) ;
    oe_debug_pub.add(  'new pl name ' || p_header_rec.new_price_list_name ) ;
    oe_debug_pub.add(  'old pl name ' || p_old_header_rec.new_price_list_name ) ;
END IF;

-- Initializing return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Initializing out result to NOT CONSTRAINED
x_result := OE_PC_GLOBALS.NO;

 -- Get the operation code to be passed to the security framework API
IF p_HEADER_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
    -- Bug 1987983 : if the order source is Copy then skip the Attribute
    -- level check
--   IF p_HEADER_rec.source_document_type_id = OE_GLOBALS.G_ORDER_SOURCE_COPY
--      THEN
--      RETURN;
--   ELSE
    l_operation := OE_PC_GLOBALS.CREATE_OP;
--   END IF;
    -- Bug 1755817: if there are no attribute-specific insert
    -- constraints, then no need to go further. Entity level
    -- security check for CREATE will be called again from
    -- process order after defaulting.
    IF NOT OE_PC_Constraints_Admin_PVT.Check_On_Insert_Exists
           (p_entity_id   => OE_PC_GLOBALS.G_ENTITY_BLANKET_HEADER
           ,p_responsibility_id     => nvl(fnd_global.resp_id, -1)
           ,p_application_id          => nvl(fnd_global.resp_appl_id,-1) --added for bug3631547
           )
    THEN
       RETURN;
    END IF;

ELSIF p_HEADER_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_operation := OE_PC_GLOBALS.UPDATE_OP;
ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INVALID OPERATION' , 1 ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
END IF;

OE_BLANKET_UTIL.API_Rec_To_Rowtype_Rec(p_HEADER_rec, l_rowtype_rec);

-- Initialize security global record
OE_Blanket_Header_Security.g_record := l_rowtype_rec;

-- Compare the new and old entity records and
-- check constraints for all the changed attributes.
/*
   IF p_header_rec.cancelled_flag <> FND_API.G_MISS_CHAR
     AND NOT OE_GLOBALS.Equal(p_header_rec.cancelled_flag,
		 p_old_header_rec.cancelled_flag)
            THEN
		IF p_header_rec.cancelled_flag = 'Y' THEN
        l_result := CANCELLED
            (p_operation => l_operation
            ,p_record    => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
             x_result := OE_PC_GLOBALS.YES;
		   --RAISE;
        END IF;
	     END IF;

    END IF;
*/
    IF ((p_header_rec.price_list_id IS NOT NULL)
      AND (NOT oe_globals.equal(p_header_rec.price_list_id,
      p_old_HEADER_rec.price_list_id))
      AND (p_header_rec.order_category_code IS NOT NULL)
      AND (p_header_rec.order_category_code <>
                 Oe_Globals.G_RETURN_CATEGORY_CODE)) THEN
      BEGIN
        SELECT active_flag
        INTO l_active_flag
        FROM qp_List_headers_vl
        WHERE list_header_id = p_header_rec.price_list_id;
        IF(nvl(l_active_flag,'N')='N') THEN
          RAISE e_inacitve_pl;
        END IF;
      EXCEPTION
        WHEN e_inacitve_pl  THEN
          RAISE e_inacitve_pl ;

        WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'WHEN OTHERS' , 2 ) ;
          END IF;
      END;
    END IF;

    IF p_header_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.accounting_rule_id,p_old_header_rec.accounting_rule_id) THEN

        l_result := ACCOUNTING_RULE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.conversion_type_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.conversion_type_code,p_old_header_rec.conversion_type_code) THEN

        l_result := CONVERSION_TYPE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.cust_po_number = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.cust_po_number,p_old_header_rec.cust_po_number) THEN

        l_result := CUST_PO_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.deliver_to_org_id,p_old_header_rec.deliver_to_org_id) THEN

        l_result := DELIVER_TO_ORG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.freight_terms_code,p_old_header_rec.freight_terms_code) THEN

        l_result := FREIGHT_TERMS
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.invoice_to_org_id,p_old_header_rec.invoice_to_org_id) THEN

        l_result := INVOICE_TO_ORG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.invoicing_rule_id,p_old_header_rec.invoicing_rule_id) THEN

        l_result := INVOICING_RULE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.order_number = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.order_number,p_old_header_rec.order_number) THEN

        l_result := ORDER_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.order_type_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.order_type_id,p_old_header_rec.order_type_id) THEN

        l_result := ORDER_TYPE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.packing_instructions = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.packing_instructions,p_old_header_rec.packing_instructions) THEN

        l_result := PACKING_INSTRUCTIONS
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.payment_term_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.payment_term_id,p_old_header_rec.payment_term_id) THEN

        l_result := PAYMENT_TERM
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.price_list_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.price_list_id,p_old_header_rec.price_list_id) THEN

        l_result := PRICE_LIST
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'exiting price list check:' || l_result, 2 ) ;
          END IF;

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.salesrep_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.salesrep_id,p_old_header_rec.salesrep_id) THEN

        l_result := SALESREP
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.shipping_instructions = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.shipping_instructions,p_old_header_rec.shipping_instructions) THEN

        l_result := SHIPPING_INSTRUCTIONS
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.shipping_method_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.shipping_method_code,p_old_header_rec.shipping_method_code) THEN

        l_result := SHIPPING_METHOD
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ship_from_org_id,p_old_header_rec.ship_from_org_id) THEN

        l_result := SHIP_FROM_ORG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ship_to_org_id,p_old_header_rec.ship_to_org_id) THEN

        l_result := SHIP_TO_ORG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.sold_to_contact_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_contact_id,p_old_header_rec.sold_to_contact_id) THEN

        l_result := SOLD_TO_CONTACT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id,p_old_header_rec.sold_to_org_id) THEN

        l_result := SOLD_TO_ORG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.transactional_curr_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.transactional_curr_code,p_old_header_rec.transactional_curr_code) THEN

        l_result := TRANSACTIONAL_CURR
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.enforce_ship_to_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.enforce_ship_to_flag,p_old_header_rec.enforce_ship_to_flag) THEN

        l_result := ENFORCE_SHIP_TO_FLAG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.enforce_freight_term_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.enforce_freight_term_flag,p_old_header_rec.enforce_freight_term_flag) THEN

        l_result := ENFORCE_FREIGHT_TERM_FLAG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.enforce_shipping_method_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.enforce_shipping_method_flag,p_old_header_rec.enforce_shipping_method_flag) THEN

        l_result := ENFORCE_SHIPPING_METHOD_FLAG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.enforce_invoice_to_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.enforce_invoice_to_flag,p_old_header_rec.enforce_invoice_to_flag) THEN

        l_result := ENFORCE_INVOICE_TO_FLAG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.enforce_price_list_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.enforce_price_list_flag,p_old_header_rec.enforce_price_list_flag) THEN

        l_result := ENFORCE_PRICE_LIST_FLAG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.enforce_payment_term_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.enforce_payment_term_flag,p_old_header_rec.enforce_payment_term_flag) THEN

        l_result := ENFORCE_PAYMENT_TERM_FLAG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.enforce_accounting_rule_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.enforce_accounting_rule_flag,p_old_header_rec.enforce_accounting_rule_flag) THEN

        l_result := ENFORCE_ACCOUNTING_RULE_FLAG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.enforce_invoicing_rule_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.enforce_invoicing_rule_flag,p_old_header_rec.enforce_invoicing_rule_flag) THEN

        l_result := ENFORCE_INVOICING_RULE_FLAG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.start_date_active = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.start_date_active,p_old_header_rec.start_date_active) THEN

        l_result := START_DATE_ACTIVE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.end_date_active = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.end_date_active,p_old_header_rec.end_date_active) THEN

        l_result := END_DATE_ACTIVE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.version_number = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.version_number,p_old_header_rec.version_number) THEN

        l_result := VERSION_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.revision_change_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.revision_change_date,p_old_header_rec.revision_change_date) THEN

        l_result := REVISION_CHANGE_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.revision_change_reason_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.revision_change_reason_code,p_old_header_rec.revision_change_reason_code) THEN

        l_result := REVISION_CHANGE_REASON
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.revision_change_comments = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.revision_change_comments,p_old_header_rec.revision_change_comments) THEN

        l_result := REVISION_CHANGE_COMMENTS
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.blanket_min_amount = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.blanket_min_amount,p_old_header_rec.blanket_min_amount) THEN

        l_result := BLANKET_MIN_AMOUNT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.blanket_max_amount = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.blanket_max_amount,p_old_header_rec.blanket_max_amount) THEN

        l_result := BLANKET_MAX_AMOUNT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.override_amount_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.override_amount_flag,p_old_header_rec.override_amount_flag) THEN

        l_result := OVERRIDE_AMOUNT_FLAG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.transaction_phase_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.transaction_phase_code,p_old_header_rec.transaction_phase_code) THEN

        l_result := TRANSACTION_PHASE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.SOLD_TO_SITE_USE_ID = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.SOLD_TO_SITE_USE_ID,p_old_header_rec.SOLD_TO_SITE_USE_ID) THEN

        l_result := SOLD_TO_SITE_USE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.SALES_DOCUMENT_NAME = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.SALES_DOCUMENT_NAME,p_old_header_rec.SALES_DOCUMENT_NAME) THEN

        l_result := SALES_DOCUMENT_NAME
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.CUSTOMER_SIGNATURE = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.CUSTOMER_SIGNATURE,p_old_header_rec.CUSTOMER_SIGNATURE) THEN

        l_result := CUSTOMER_SIGNATURE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.CUSTOMER_SIGNATURE_DATE = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.CUSTOMER_SIGNATURE_DATE,p_old_header_rec.CUSTOMER_SIGNATURE_DATE) THEN

        l_result := CUSTOMER_SIGNATURE_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.SUPPLIER_SIGNATURE = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.SUPPLIER_SIGNATURE,p_old_header_rec.SUPPLIER_SIGNATURE) THEN

        l_result := SUPPLIER_SIGNATURE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.SUPPLIER_SIGNATURE_DATE = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.SUPPLIER_SIGNATURE_DATE,p_old_header_rec.SUPPLIER_SIGNATURE_DATE) THEN

        l_result := SUPPLIER_SIGNATURE_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.USER_STATUS_CODE = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.USER_STATUS_CODE,p_old_header_rec.USER_STATUS_CODE) THEN

        l_result := USER_STATUS
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.NEW_PRICE_LIST_ID = FND_API.G_MISS_NUM THEN NULL;
    ELSIF ( NOT OE_GLOBALS.EQUAL(p_header_rec.NEW_PRICE_LIST_ID,p_old_header_rec.NEW_PRICE_LIST_ID)
            OR NOT OE_GLOBALS.EQUAL(p_header_rec.NEW_PRICE_LIST_NAME,p_old_header_rec.NEW_PRICE_LIST_NAME)
          )
    THEN

        l_result := NEW_PRICE_LIST
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.NEW_MODIFIER_LIST_ID = FND_API.G_MISS_NUM THEN NULL;
    ELSIF ( NOT OE_GLOBALS.EQUAL(p_header_rec.NEW_MODIFIER_LIST_ID,p_old_header_rec.NEW_MODIFIER_LIST_ID)
            OR NOT OE_GLOBALS.EQUAL(p_header_rec.NEW_MODIFIER_LIST_NAME,p_old_header_rec.NEW_MODIFIER_LIST_NAME)
          )
    THEN


        l_result := NEW_MODIFIER_LIST
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.DEFAULT_DISCOUNT_PERCENT = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.DEFAULT_DISCOUNT_PERCENT,p_old_header_rec.DEFAULT_DISCOUNT_PERCENT) THEN

        l_result := DEFAULT_DISCOUNT_PERCENT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.DEFAULT_DISCOUNT_AMOUNT = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.DEFAULT_DISCOUNT_AMOUNT,p_old_header_rec.DEFAULT_DISCOUNT_AMOUNT) THEN

        l_result := DEFAULT_DISCOUNT_AMOUNT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;
 --bug6531947

    -- Bug 6609645
 IF p_header_rec.ON_HOLD_FLAG = FND_API.G_MISS_CHAR THEN NULL;
     ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ON_HOLD_FLAG,p_old_header_rec.ON_HOLD_FLAG) THEN
         l_result := ON_HOLD_FLAG
             (p_operation        => l_operation
             ,p_record   => l_rowtype_rec
             ,x_on_operation_action => l_on_operation_action
             );

         IF l_result = OE_PC_GLOBALS.YES THEN
             -- set OUT result to CONSTRAINED
             x_result := OE_PC_GLOBALS.YES;
         END IF;

 END IF;

 --Bug 6609645

 IF p_header_rec.CONTEXT  = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.CONTEXT,p_old_header_rec.CONTEXT
) THEN
         l_result := CONTEXT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;


      IF p_header_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE1,p_old_header_rec.ATTRIBUTE1) THEN
         l_result := ATTRIBUTE1
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;


       IF p_header_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE2,p_old_header_rec.ATTRIBUTE2) THEN
         l_result := ATTRIBUTE2
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;


	    IF p_header_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE3,p_old_header_rec.ATTRIBUTE3) THEN
         l_result := ATTRIBUTE3
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;


	    IF p_header_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE4,p_old_header_rec.ATTRIBUTE4) THEN
         l_result := ATTRIBUTE4
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

	    IF p_header_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE5,p_old_header_rec.ATTRIBUTE5) THEN
         l_result := ATTRIBUTE5
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;


	    IF p_header_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE6,p_old_header_rec.ATTRIBUTE6) THEN
         l_result := ATTRIBUTE6
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;


	    IF p_header_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE7,p_old_header_rec.ATTRIBUTE7) THEN
         l_result := ATTRIBUTE7
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

	    IF p_header_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE8,p_old_header_rec.ATTRIBUTE8) THEN
         l_result := ATTRIBUTE8
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;


	    IF p_header_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE9,p_old_header_rec.ATTRIBUTE9) THEN
         l_result := ATTRIBUTE9
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

	    IF p_header_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE10,p_old_header_rec.ATTRIBUTE10) THEN
         l_result := ATTRIBUTE10
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;


	    IF p_header_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE11,p_old_header_rec.ATTRIBUTE11) THEN
         l_result := ATTRIBUTE11
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

	    IF p_header_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE12,p_old_header_rec.ATTRIBUTE12) THEN
         l_result := ATTRIBUTE12
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

	    IF p_header_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE13,p_old_header_rec.ATTRIBUTE13) THEN
         l_result := ATTRIBUTE13
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

	    IF p_header_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE14,p_old_header_rec.ATTRIBUTE14) THEN
         l_result := ATTRIBUTE14
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

	    IF p_header_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE15,p_old_header_rec.ATTRIBUTE15) THEN
         l_result := ATTRIBUTE15
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

	    IF p_header_rec.ATTRIBUTE16 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE16,p_old_header_rec.ATTRIBUTE16) THEN
         l_result := ATTRIBUTE16
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

	    IF p_header_rec.ATTRIBUTE17 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE17,p_old_header_rec.ATTRIBUTE17) THEN
         l_result := ATTRIBUTE17
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

	    IF p_header_rec.ATTRIBUTE18 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE18,p_old_header_rec.ATTRIBUTE18) THEN
         l_result := ATTRIBUTE18
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;


	    IF p_header_rec.ATTRIBUTE19 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE19,p_old_header_rec.ATTRIBUTE19) THEN
         l_result := ATTRIBUTE19
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

	    IF p_header_rec.ATTRIBUTE20 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ATTRIBUTE20,p_old_header_rec.ATTRIBUTE20) THEN
         l_result := ATTRIBUTE20
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );


    IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    -- BEGIN: CHECK FOR CONSTRAINTS ON DESC FLEXFIELD ATTRIBUTES
    -- Bug 2003823:
    -- If profile indicates that generic update constraints (e.g. seeded
    -- closed order condition) should not be checked for DFF, then
    -- set the global to 'N'.
    -- Also, store the current value of global in a local variable and
    -- re-set it after DFF check. If DFF were the only fields being
    -- updated and profile was set to 'N', global at the end should
    -- be re-set to 'Y' - this indicates to process order that no
    -- constrainable attributes were updated and thus, it would
    -- suppress entity level security check also.
    IF OE_PC_GLOBALS.G_CHECK_UPDATE_ALL_FOR_DFF = 'N' THEN
       l_check_all_cols_constraint := g_check_all_cols_constraint;
       g_check_all_cols_constraint := 'N';
    END IF;

    IF OE_PC_GLOBALS.G_CHECK_UPDATE_ALL_FOR_DFF = 'N' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SETTING CHECK ALL COLS CONSTRAINT TO:'||L_CHECK_ALL_COLS_CONSTRAINT ) ;
       END IF;
       g_check_all_cols_constraint := l_check_all_cols_constraint;
    END IF;

    -- END: CHECK FOR CONSTRAINTS ON DESC FLEXFIELD ATTRIBUTES
    -- NOTE: Please add constraints check for new attributes before the
    -- descriptive flexfield attributes check.

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXIT OE_BLANKET_HEADER_SECURITY.ATTRIBUTES' , 1 ) ;
END IF;

EXCEPTION
   WHEN e_inacitve_pl THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ONT','OE_INACTIVE_PRICELIST');
      OE_MSG_PUB.ADD;

    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Attributes'
        );
    END IF;

END Attributes;

FUNCTION ON_HOLD_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'ON_HOLD_FLAG'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END ON_HOLD_FLAG;
END OE_Blanket_Header_Security;

/
