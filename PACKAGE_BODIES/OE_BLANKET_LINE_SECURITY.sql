--------------------------------------------------------
--  DDL for Package Body OE_BLANKET_LINE_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BLANKET_LINE_SECURITY" AS
/* $Header: OEXXBLNB.pls 120.0.12000000.2 2007/10/31 06:51:40 smmathew ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Blanket_Line_Security';

g_order_number                   NUMBER := FND_API.G_MISS_NUM;

-- LOCAL PROCEDURES

FUNCTION Is_Op_Constrained
( p_operation           IN VARCHAR2
 , p_column_name         IN VARCHAR2 DEFAULT NULL
 , p_record       IN OE_AK_BLANKET_LINES_V%ROWTYPE
 , x_on_operation_action	OUT NOCOPY NUMBER
) RETURN NUMBER IS
l_constraint_id	        NUMBER;
l_grp	                NUMBER;
l_on_operation_action	NUMBER;
l_result		NUMBER;
l_column_name	        VARCHAR2(30);
l_audit_trail_enabled   VARCHAR2(1) := OE_SYS_PARAMETERS.VALUE('AUDIT_TRAIL_ENABLE_FLAG');
l_code_level            VARCHAR2(6) := OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL;
l_ctr                   NUMBER := OE_GLOBALS.OE_AUDIT_HISTORY_TBL.count;
l_ind                   NUMBER;
l_history_captured      BOOLEAN; -- Is history captured for this line?

BEGIN

-- Bug 1755817: if line belongs to a different order, then
-- clear the cached results so that the cache is reset for
-- the new order
IF p_record.order_number <> g_order_number THEN
   OE_PC_Constraints_Admin_Pvt.Clear_Cached_Results;
   g_order_number := p_record.order_number;
END IF;

l_result := OE_PC_Constraints_Admin_PVT.Is_OP_constrained
    ( p_responsibility_id	=> nvl(fnd_global.resp_id, -1)
    , p_application_id          => nvl(fnd_global.resp_appl_id,-1) --added for bug3631547
    , p_operation	=> p_operation
    , p_qualifier_attribute => p_record.transaction_phase_code
    , p_entity_id	=> OE_PC_GLOBALS.G_ENTITY_BLANKET_LINE
    , p_column_name	=> p_column_name
    , p_check_all_cols_constraint	=> g_check_all_cols_constraint
    , p_is_caller_defaulting	=> g_is_caller_defaulting
    , p_use_cached_results      => 'Y'
    , x_constraint_id	=> l_constraint_id
    , x_constraining_conditions_grp	=> l_grp
    , x_on_operation_action	=> x_on_operation_action
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
        if l_column_name is null and x_on_operation_action = 0 then
		  oe_debug_pub.add('Constraint on UPDATE of all columns!');
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

/*
OE_DEBUG_PUB.add('Action performed code : '||x_on_operation_action,1);

IF l_result = OE_PC_GLOBALS.YES THEN
   IF x_on_operation_action = 1 THEN
      IF p_column_name = 'ORDERED_QUANTITY' THEN
         oe_debug_pub.add('Setting Cancellation Flag to True',1);
         oe_sales_can_util.G_REQUIRE_REASON := TRUE;
      END IF;
   END IF;
END IF;
*/
/* Start AuditTrail */
/*
-- Code level should be OM-H and
-- if Audit Trail enabled
IF g_is_caller_defaulting='N' THEN
   IF l_code_level >= '110508' and nvl(l_audit_trail_enabled,'D') <> 'D' THEN
      OE_DEBUG_PUB.add('Audit Trail enabled ',5);
      IF l_audit_trail_enabled = 'B' THEN  -- capture only for booked orders
         OE_DEBUG_PUB.add('Audit Trail enabled for booked orders only ...',5);

         IF p_record.booked_flag = 'Y' THEN
            IF l_result = OE_PC_GLOBALS.YES THEN
               l_history_captured := FALSE;
               IF x_on_operation_action = 1 THEN
                  BEGIN
                     FOR l_ind in 1..l_ctr LOOP
                         IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr).LINE_ID = p_record.line_id THEN
                            l_history_captured := TRUE;
                         END IF;
                     END LOOP;
                  EXCEPTION WHEN OTHERS THEN
                     OE_DEBUG_PUB.add('While capturing history : '||sqlerrm,1);
                     NULL;
                  END;
                  IF NOT l_history_captured THEN
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).LINE_ID := p_record.line_id;
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).HISTORY_TYPE := 'R';
                     oe_debug_pub.add('Line Security, attribute change requires reason',1);
                     OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
                     OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
                  END IF;
               ELSIF x_on_operation_action = 2 THEN
                  BEGIN
                     FOR l_ind in 1..l_ctr LOOP
                         IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr).LINE_ID = p_record.line_id THEN
                            l_history_captured := TRUE;
                         END IF;
                     END LOOP;
                  EXCEPTION WHEN OTHERS THEN
                     OE_DEBUG_PUB.add('While capturing history : '||sqlerrm,1);
                     NULL;
                  END;
                  IF NOT l_history_captured THEN
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).LINE_ID := p_record.line_id;
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).HISTORY_TYPE := 'H';
                     oe_debug_pub.add('Line Security, attribute change requires history',7);
                     IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG <> 'Y' then
                        oe_debug_pub.add('Line Security, attribute change requires history',7);
   	                OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'Y';
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;

      ELSE -- capture audit for all orders
         IF l_result = OE_PC_GLOBALS.YES THEN
              l_history_captured := FALSE;
              IF x_on_operation_action = 1 THEN
                  BEGIN
                     FOR l_ind in 1..l_ctr LOOP
                         IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr).LINE_ID = p_record.line_id THEN
                            l_history_captured := TRUE;
                         END IF;
                     END LOOP;
                  EXCEPTION WHEN OTHERS THEN
                     OE_DEBUG_PUB.add('While capturing history : '||sqlerrm,1);
                     NULL;
                  END;
                  IF NOT l_history_captured THEN
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).LINE_ID := p_record.line_id;
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).HISTORY_TYPE := 'R';
                     oe_debug_pub.add('Line Security, attribute change requires reason',1);
                     OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
                     OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
                  END IF;
              ELSIF x_on_operation_action = 2 THEN
                  BEGIN
                     FOR l_ind in 1..l_ctr LOOP
                         IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr).LINE_ID = p_record.line_id THEN
                            l_history_captured := TRUE;
                         END IF;
                     END LOOP;
                  EXCEPTION WHEN OTHERS THEN
                     OE_DEBUG_PUB.add('While capturing history : '||sqlerrm,1);
                     NULL;
                  END;
                  IF NOT l_history_captured THEN
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).LINE_ID := p_record.line_id;
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).HISTORY_TYPE := 'H';
                     oe_debug_pub.add('Line Security, attribute change requires history',7);
                     IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG <> 'Y' then
                        oe_debug_pub.add('Line Security, attribute change requires history',7);
   	                OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'Y';
                     END IF;
                  END IF;
              END IF;
         END IF;
     END IF;
  ELSE
     OE_DEBUG_PUB.add('Audit Trail is disabled..',5);
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
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


FUNCTION CUST_PO_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
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


FUNCTION INVENTORY_ITEM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'INVENTORY_ITEM_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END INVENTORY_ITEM;

FUNCTION INVOICE_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
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

FUNCTION LINE_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'LINE_NUMBER'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END LINE_NUMBER;


FUNCTION LINE_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'LINE_TYPE_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END LINE_TYPE;



FUNCTION ORDER_QUANTITY_UOM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ORDER_QUANTITY_UOM'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ORDER_QUANTITY_UOM;


FUNCTION PACKING_INSTRUCTIONS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PACKING_INSTRUCTIONS'
        ,p_record	     => p_record
        ,x_on_operation_action	=> x_on_operation_action
        );


RETURN(l_result);

END PACKING_INSTRUCTIONS;


FUNCTION PAYMENT_TERM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
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

FUNCTION PLANNING_PRIORITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PLANNING_PRIORITY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END PLANNING_PRIORITY;


FUNCTION PRICE_LIST
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
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


FUNCTION PRICING_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PRICING_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END PRICING_DATE;


FUNCTION PRICING_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PRICING_QUANTITY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END PRICING_QUANTITY;


FUNCTION PRICING_QUANTITY_UOM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PRICING_QUANTITY_UOM'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END PRICING_QUANTITY_UOM;


FUNCTION PROJECT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PROJECT_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END PROJECT;


FUNCTION PROMISE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PROMISE_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END PROMISE_DATE;

FUNCTION REFERENCE_CUST_TRX_LINE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'REFERENCE_CUSTOMER_TRX_LINE_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END REFERENCE_CUST_TRX_LINE;

FUNCTION REFERENCE_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'REFERENCE_TYPE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END REFERENCE_TYPE;


FUNCTION REQUEST_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'REQUEST_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END REQUEST_DATE;


FUNCTION RETURN_REASON
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'RETURN_REASON_CODE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END RETURN_REASON;


FUNCTION SALESREP
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
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

FUNCTION SHIP_SET
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIP_SET_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIP_SET;

FUNCTION ARRIVAL_SET
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ARRIVAL_SET_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ARRIVAL_SET;


FUNCTION SCHEDULE_ARRIVAL_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SCHEDULE_ARRIVAL_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SCHEDULE_ARRIVAL_DATE;

FUNCTION SCHEDULE_SHIP_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SCHEDULE_SHIP_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SCHEDULE_SHIP_DATE;


FUNCTION SHIPMENT_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIPMENT_NUMBER'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIPMENT_NUMBER;


FUNCTION SHIPMENT_PRIORITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIPMENT_PRIORITY_CODE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIPMENT_PRIORITY;


FUNCTION SHIPPED_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIPPED_QUANTITY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIPPED_QUANTITY;

FUNCTION SHIPPING_INSTRUCTIONS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation    => p_operation
    ,p_column_name  => 'SHIPPING_INSTRUCTIONS'
    ,p_record  => p_record
    ,x_on_operation_action    => x_on_operation_action
    );

RETURN(l_result);

END SHIPPING_INSTRUCTIONS;


FUNCTION SHIPPING_METHOD
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation    => p_operation
    ,p_column_name  => 'SHIPPING_METHOD_CODE'
    ,p_record  => p_record
    ,x_on_operation_action    => x_on_operation_action
    );

RETURN(l_result);

END SHIPPING_METHOD;


FUNCTION SHIPPING_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIPPING_QUANTITY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIPPING_QUANTITY;


FUNCTION SHIPPING_QUANTITY_UOM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIPPING_QUANTITY_UOM'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIPPING_QUANTITY_UOM;


FUNCTION SHIP_FROM_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
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

FUNCTION SUBINVENTORY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation     => p_operation
        ,p_column_name   => 'SUBINVENTORY'
        ,p_record   => p_record
        ,x_on_operation_action     => x_on_operation_action
        );

RETURN(l_result);

END SUBINVENTORY;

FUNCTION SHIP_MODEL_COMPLETE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIP_MODEL_COMPLETE_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIP_MODEL_COMPLETE;


FUNCTION SHIP_TOLERANCE_ABOVE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIP_TOLERANCE_ABOVE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIP_TOLERANCE_ABOVE;


FUNCTION SHIP_TOLERANCE_BELOW
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIP_TOLERANCE_BELOW'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIP_TOLERANCE_BELOW;


FUNCTION SHIP_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIP_TO_CONTACT_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIP_TO_CONTACT;


FUNCTION SHIP_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
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


FUNCTION SOLD_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
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


FUNCTION SOURCE_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SOURCE_TYPE_CODE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SOURCE_TYPE;


FUNCTION TASK
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'TASK_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END TASK;


FUNCTION TAX
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'TAX_CODE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END TAX;


FUNCTION TAX_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'TAX_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END TAX_DATE;


FUNCTION TAX_EXEMPT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'TAX_EXEMPT_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END TAX_EXEMPT;


FUNCTION TAX_EXEMPT_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'TAX_EXEMPT_NUMBER'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END TAX_EXEMPT_NUMBER;


FUNCTION TAX_EXEMPT_REASON
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'TAX_EXEMPT_REASON_CODE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END TAX_EXEMPT_REASON;


FUNCTION UNIT_LIST_PRICE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'UNIT_LIST_PRICE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END UNIT_LIST_PRICE;


/*1449220*/
FUNCTION ITEM_IDENTIFIER_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ITEM_IDENTIFIER_TYPE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ITEM_IDENTIFIER_TYPE;
/*1449220*/


FUNCTION BLANKET_LINE_MIN_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'BLANKET_LINE_MIN_AMOUNT'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END BLANKET_LINE_MIN_AMOUNT;

FUNCTION BLANKET_LINE_MAX_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'BLANKET_LINE_MAX_AMOUNT'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END BLANKET_LINE_MAX_AMOUNT;

FUNCTION BLANKET_MIN_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'BLANKET_MIN_QUANTITY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END BLANKET_MIN_QUANTITY;

FUNCTION BLANKET_MAX_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'BLANKET_MAX_QUANTITY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END BLANKET_MAX_QUANTITY;

FUNCTION MIN_RELEASE_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'MIN_RELEASE_AMOUNT'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END MIN_RELEASE_AMOUNT;

FUNCTION MAX_RELEASE_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'MAX_RELEASE_AMOUNT'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END MAX_RELEASE_AMOUNT;

FUNCTION MIN_RELEASE_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'MIN_RELEASE_QUANTITY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END MIN_RELEASE_QUANTITY;

FUNCTION MAX_RELEASE_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'MAX_RELEASE_QUANTITY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END MAX_RELEASE_QUANTITY;

FUNCTION OVERRIDE_BLANKET_CONTROLS_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'OVERRIDE_BLANKET_CONTROLS_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END OVERRIDE_BLANKET_CONTROLS_FLAG;

FUNCTION OVERRIDE_RELEASE_CONTROLS_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'OVERRIDE_RELEASE_CONTROLS_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END OVERRIDE_RELEASE_CONTROLS_FLAG;

FUNCTION ENFORCE_ACCOUNTING_RULE_FLAG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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

FUNCTION PREFERRED_GRADE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PREFERRED_GRADE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END PREFERRED_GRADE;

FUNCTION DISCOUNT_PERCENT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'DISCOUNT_PERCENT'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END DISCOUNT_PERCENT;

FUNCTION DISCOUNT_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'DISCOUNT_AMOUNT'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END DISCOUNT_AMOUNT;
--bug 6531947
FUNCTION CONTEXT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
,   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
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
(   p_LINE_rec                      IN  Oe_Blanket_Pub.LINE_Rec_Type
,   x_result                        OUT NOCOPY NUMBER
,   x_return_status                 OUT NOCOPY VARCHAR2
) IS
l_operation	VARCHAR2(1);
l_on_operation_action	NUMBER;
l_rowtype_rec	OE_AK_BLANKET_LINES_V%ROWTYPE;
BEGIN

oe_debug_pub.add('Enter OE_Blanket_Line_Security.Entity',1);

-- Initializing return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF p_LINE_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
    l_operation := OE_PC_GLOBALS.CREATE_OP;
ELSIF p_LINE_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_operation := OE_PC_GLOBALS.UPDATE_OP;
ELSIF p_LINE_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
    l_operation := OE_PC_GLOBALS.DELETE_OP;
ELSE
    oe_debug_pub.add('Invalid operation',1);
    RAISE FND_API.G_EXC_ERROR;
END IF;

OE_Blanket_Util.Line_API_Rec_To_Rowtype_Rec
	(p_LINE_rec		=> p_line_rec
	, x_rowtype_rec	=> l_rowtype_rec);

--Initialize security global record
OE_Blanket_Line_SECURITY.g_record := l_rowtype_rec;

x_result := Is_OP_constrained
    (p_operation	=> l_operation
    ,p_record	=> l_rowtype_rec
    ,x_on_operation_action	=> l_on_operation_action
    );

oe_debug_pub.add('Exit OE_Blanket_Line_Security.Entity',1);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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
(   p_LINE_rec                      IN  Oe_Blanket_Pub.LINE_Rec_Type
,   p_old_LINE_rec                  IN  Oe_Blanket_Pub.LINE_Rec_Type := Oe_Blanket_Pub.G_MISS_BLANKET_LINE_REC
,   x_result                        OUT NOCOPY NUMBER
,   x_return_status                 OUT NOCOPY VARCHAR2
) IS
l_operation	VARCHAR2(1);
l_on_operation_action  NUMBER;
l_result		NUMBER;
l_rowtype_rec	OE_AK_BLANKET_LINES_V%ROWTYPE;
l_column_name	VARCHAR2(30);
l_active_flag  VARCHAR2(1);
l_check_all_cols_constraint VARCHAR2(1);
BEGIN
oe_debug_pub.add('Enter OE_Blanket_Line_Security.Attributes',1);

-- Initializing return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Initializing out result to NOT CONSTRAINED
x_result := OE_PC_GLOBALS.NO;

 -- Get the operation code to be passed to the security framework API
IF p_LINE_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

    -- Bug 2639336 : if the order source is Copy then skip the Attribute
    -- level check
--   IF p_LINE_rec.source_document_type_id = OE_GLOBALS.G_ORDER_SOURCE_COPY
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
           (p_entity_id   => OE_PC_GLOBALS.G_ENTITY_LINE
           ,p_responsibility_id     => nvl(fnd_global.resp_id, -1)
           , p_application_id       => nvl(fnd_global.resp_appl_id,-1) --added for bug3631547
           )
    THEN
       RETURN;
    END IF;

ELSIF p_LINE_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_operation := OE_PC_GLOBALS.UPDATE_OP;
ELSE
    oe_debug_pub.add('Invalid operation',1);
    RAISE FND_API.G_EXC_ERROR;
END IF;

OE_Blanket_Util.Line_API_Rec_To_Rowtype_Rec
	(p_LINE_rec		=> p_line_rec
	, x_rowtype_rec	=> l_rowtype_rec);

--Initialize security global record
OE_Blanket_Line_SECURITY.g_record := l_rowtype_rec;

-- Compare the new and old entity records and
-- check constraints for all the changed attributes.

    IF p_line_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.accounting_rule_id,p_old_line_rec.accounting_rule_id) THEN

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

    IF p_line_rec.cust_po_number = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.cust_po_number,p_old_line_rec.cust_po_number) THEN

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

    IF p_line_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.deliver_to_org_id,p_old_line_rec.deliver_to_org_id) THEN

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

    IF p_line_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.freight_terms_code,p_old_line_rec.freight_terms_code) THEN

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

    IF p_line_rec.inventory_item_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.inventory_item_id,p_old_line_rec.inventory_item_id) THEN

        l_result := INVENTORY_ITEM
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.invoice_to_org_id,p_old_line_rec.invoice_to_org_id) THEN

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

    IF p_line_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.invoicing_rule_id,p_old_line_rec.invoicing_rule_id) THEN

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

    IF p_line_rec.item_identifier_type = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.item_identifier_type,p_old_line_rec.item_identifier_type) THEN

        l_result := ITEM_IDENTIFIER_TYPE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.line_number = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.line_number,p_old_line_rec.line_number) THEN

        l_result := LINE_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.line_type_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.line_type_id,p_old_line_rec.line_type_id) THEN

        l_result := LINE_TYPE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.order_quantity_uom = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.order_quantity_uom,p_old_line_rec.order_quantity_uom) THEN

        l_result := ORDER_QUANTITY_UOM
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.packing_instructions = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.packing_instructions,p_old_line_rec.packing_instructions) THEN

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

    IF p_line_rec.payment_term_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.payment_term_id,p_old_line_rec.payment_term_id) THEN

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

    IF p_line_rec.price_list_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.price_list_id,p_old_line_rec.price_list_id) THEN

        l_result := PRICE_LIST
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.salesrep_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.salesrep_id,p_old_line_rec.salesrep_id) THEN

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

    IF p_line_rec.shipping_instructions = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.shipping_instructions,p_old_line_rec.shipping_instructions) THEN

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

    IF p_line_rec.shipping_method_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.shipping_method_code,p_old_line_rec.shipping_method_code) THEN

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

    IF p_line_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ship_from_org_id,p_old_line_rec.ship_from_org_id) THEN

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

    IF p_line_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ship_to_org_id,p_old_line_rec.ship_to_org_id) THEN

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

    IF p_line_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.sold_to_org_id,p_old_line_rec.sold_to_org_id) THEN

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

    IF p_line_rec.unit_list_price = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.unit_list_price,p_old_line_rec.unit_list_price) THEN

        l_result := UNIT_LIST_PRICE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.start_date_active = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.start_date_active,p_old_line_rec.start_date_active) THEN

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

    IF p_line_rec.end_date_active = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.end_date_active,p_old_line_rec.end_date_active) THEN

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

    IF p_line_rec.preferred_grade = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.preferred_grade,p_old_line_rec.preferred_grade) THEN

        l_result := PREFERRED_GRADE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.enforce_ship_to_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.enforce_ship_to_flag,p_old_line_rec.enforce_ship_to_flag) THEN

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

    IF p_line_rec.enforce_freight_term_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.enforce_freight_term_flag,p_old_line_rec.enforce_freight_term_flag) THEN

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

    IF p_line_rec.enforce_shipping_method_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.enforce_shipping_method_flag,p_old_line_rec.enforce_shipping_method_flag) THEN

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

    IF p_line_rec.enforce_invoice_to_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.enforce_invoice_to_flag,p_old_line_rec.enforce_invoice_to_flag) THEN

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

    IF p_line_rec.enforce_price_list_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.enforce_price_list_flag,p_old_line_rec.enforce_price_list_flag) THEN

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

    IF p_line_rec.enforce_payment_term_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.enforce_payment_term_flag,p_old_line_rec.enforce_payment_term_flag) THEN

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

    IF p_line_rec.enforce_accounting_rule_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.enforce_accounting_rule_flag,p_old_line_rec.enforce_accounting_rule_flag) THEN

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

    IF p_line_rec.enforce_invoicing_rule_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.enforce_invoicing_rule_flag,p_old_line_rec.enforce_invoicing_rule_flag) THEN

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

    IF p_line_rec.blanket_min_amount = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_min_amount,p_old_line_rec.blanket_min_amount) THEN

        l_result := BLANKET_LINE_MIN_AMOUNT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.blanket_max_amount = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_max_amount,p_old_line_rec.blanket_max_amount) THEN

        l_result := BLANKET_LINE_MAX_AMOUNT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.blanket_min_quantity = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_min_quantity,p_old_line_rec.blanket_min_quantity) THEN

        l_result := BLANKET_MIN_QUANTITY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.blanket_max_quantity = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_max_quantity,p_old_line_rec.blanket_max_quantity) THEN

        l_result := BLANKET_MAX_QUANTITY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.min_release_amount = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.min_release_amount,p_old_line_rec.min_release_amount) THEN

        l_result := MIN_RELEASE_AMOUNT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.max_release_amount = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.max_release_amount,p_old_line_rec.max_release_amount) THEN

        l_result := MAX_RELEASE_AMOUNT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.min_release_quantity = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.min_release_quantity,p_old_line_rec.min_release_quantity) THEN

        l_result := MIN_RELEASE_QUANTITY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.max_release_quantity = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.max_release_quantity,p_old_line_rec.max_release_quantity) THEN

        l_result := MAX_RELEASE_QUANTITY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.override_blanket_controls_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.override_blanket_controls_flag,p_old_line_rec.override_blanket_controls_flag) THEN

        l_result := OVERRIDE_BLANKET_CONTROLS_FLAG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.override_release_controls_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.override_release_controls_flag,p_old_line_rec.override_release_controls_flag) THEN

        l_result := OVERRIDE_RELEASE_CONTROLS_FLAG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.pricing_uom = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.pricing_uom,p_old_line_rec.pricing_uom) THEN

        l_result := PRICING_QUANTITY_UOM
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.discount_percent = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.discount_percent,p_old_line_rec.discount_percent) THEN

        l_result := DISCOUNT_PERCENT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.discount_amount = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.discount_amount,p_old_line_rec.discount_amount) THEN

        l_result := DISCOUNT_AMOUNT
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
 IF p_line_rec.CONTEXT  = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.CONTEXT,p_old_line_rec.CONTEXT )
THEN
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


      IF p_line_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE1,p_old_line_rec.ATTRIBUTE1) THEN
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

  IF p_line_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE2,p_old_line_rec.ATTRIBUTE2) THEN
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

      IF p_line_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE3,p_old_line_rec.ATTRIBUTE3) THEN
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

      IF p_line_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE4,p_old_line_rec.ATTRIBUTE4) THEN
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

      IF p_line_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE5,p_old_line_rec.ATTRIBUTE5) THEN
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

      IF p_line_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE6,p_old_line_rec.ATTRIBUTE6) THEN
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

      IF p_line_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE7,p_old_line_rec.ATTRIBUTE7) THEN
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

      IF p_line_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE8,p_old_line_rec.ATTRIBUTE8) THEN
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

      IF p_line_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE9,p_old_line_rec.ATTRIBUTE9) THEN
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

      IF p_line_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE10,p_old_line_rec.ATTRIBUTE10) THEN
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

      IF p_line_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE11,p_old_line_rec.ATTRIBUTE11) THEN
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

      IF p_line_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE12,p_old_line_rec.ATTRIBUTE12) THEN
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

      IF p_line_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE13,p_old_line_rec.ATTRIBUTE13) THEN
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

      IF p_line_rec.ATTRIBUTE14= FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE14,p_old_line_rec.ATTRIBUTE14) THEN
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

      IF p_line_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE15,p_old_line_rec.ATTRIBUTE15) THEN
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

      IF p_line_rec.ATTRIBUTE16 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE16,p_old_line_rec.ATTRIBUTE16) THEN
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

      IF p_line_rec.ATTRIBUTE17 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE17,p_old_line_rec.ATTRIBUTE17) THEN
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

      IF p_line_rec.ATTRIBUTE18 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE18,p_old_line_rec.ATTRIBUTE18) THEN
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

      IF p_line_rec.ATTRIBUTE19 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE19,p_old_line_rec.ATTRIBUTE19) THEN
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

      IF p_line_rec.ATTRIBUTE20 = FND_API.G_MISS_CHAR THEN NULL;
       ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ATTRIBUTE20,p_old_line_rec.ATTRIBUTE20) THEN
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

oe_debug_pub.add('Exit OE_Blanket_Line_Security.Attributes',1);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Attributes'
        );
    END IF;

END Attributes;

PROCEDURE ALLOW_TRX_LINE_EXEMPTIONS
( p_application_id                  IN NUMBER,
  p_entity_short_name               IN VARCHAR2,
  p_validation_entity_short_name    IN VARCHAR2,
  p_validation_tmplt_short_name     IN VARCHAR2,
  p_record_set_tmplt_short_name     IN VARCHAR2,
  p_scope                           IN VARCHAR2,
  p_result                          OUT NOCOPY NUMBER
)
IS
    Ret_Val    VARCHAR2(1);
BEGIN
--    Ret_Val := FND_PROFILE.VALUE('AR_ALLOW_TRX_LINE_EXEMPTIONS');
    Ret_Val := FND_PROFILE.VALUE('ZX_ALLOW_TRX_LINE_EXEMPTIONS');
    IF Ret_Val = 'Y' THEN
        p_result := 1;
    ELSE
        p_result := 0;
    END IF;
END ALLOW_TRX_LINE_EXEMPTIONS;

END OE_Blanket_Line_Security;

/
