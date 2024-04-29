--------------------------------------------------------
--  DDL for Package Body OE_HEADER_SCREDIT_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HEADER_SCREDIT_SECURITY" AS
/* $Header: OEXXHSCB.pls 115.22 2004/06/22 18:34:04 jvicenti ship $ */


--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Header_Scredit_Security';

g_header_id                   NUMBER := FND_API.G_MISS_NUM;

-- LOCAL PROCEDURES

FUNCTION Is_Op_Constrained
(  p_operation           IN VARCHAR2
 , p_column_name         IN VARCHAR2 DEFAULT NULL
 , p_record              IN OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER IS
l_constraint_id	      NUMBER;
l_grp	              NUMBER;
l_result	      NUMBER;
l_constrained_column  VARCHAR2(30);
l_audit_trail_enabled VARCHAR2(1) := OE_SYS_PARAMETERS.VALUE('AUDIT_TRAIL_ENABLE_FLAG');
l_order_booked_flag   VARCHAR2(1);
l_code_level varchar2(6) := OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL;

CURSOR IS_ORDER_BOOKED(x_header_id NUMBER) IS
       SELECT NVL(BOOKED_FLAG,'N')
       FROM   OE_ORDER_HEADERS_ALL
       WHERE  HEADER_ID = x_header_id;
l_transaction_phase_code VARCHAR2(30);
       --
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
       --
BEGIN

-- Bug 1755817: if sales credit belongs to a different order, then
-- clear the cached results so that the cache is reset for
-- the new order
IF p_record.header_id <> g_header_id THEN
   OE_PC_Constraints_Admin_Pvt.Clear_Cached_Results;
   g_header_id := p_record.header_id;
END IF;

IF l_code_level >= '110510' THEN
   OE_Order_Cache.Load_Order_Header(p_record.header_id);
   l_transaction_phase_code := oe_order_cache.g_header_rec.transaction_phase_code;
END IF;

l_result := OE_PC_Constraints_Admin_PVT.Is_OP_constrained
    ( p_responsibility_id     => nvl(fnd_global.resp_id, -1)
    , p_application_id          => nvl(fnd_global.resp_appl_id,-1) --added for bug3631547
    , p_operation   => p_operation
    , p_qualifier_attribute => l_transaction_phase_code
    , p_entity_id   => OE_PC_GLOBALS.G_ENTITY_HEADER_SCREDIT
    , p_column_name => p_column_name
    , p_check_all_cols_constraint  => g_check_all_cols_constraint
    , p_is_caller_defaulting  => g_is_caller_defaulting
    , p_use_cached_results    => 'Y'
    , x_constraint_id    => l_constraint_id
    , x_constraining_conditions_grp     => l_grp
    , x_on_operation_action   => x_on_operation_action
    );

if l_result = OE_PC_GLOBALS.YES then

    IF g_check_all_cols_constraint = 'Y'
       AND (p_operation = OE_PC_GLOBALS.UPDATE_OP
            OR p_operation = OE_PC_GLOBALS.CREATE_OP)
       AND x_on_operation_action = 0
       AND p_column_name IS NOT NULL THEN
          SELECT column_name
          INTO   l_constrained_column
          FROM   oe_pc_constraints
          WHERE  constraint_id = l_constraint_id;
          if l_constrained_column is null then
             oe_debug_pub.add('There is an UPDATE constraint on all columns - Error',1);
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
-- Code level should be OM-H and
-- Audit Trail Not Disabled
IF g_is_caller_defaulting = 'N' THEN
IF l_code_level >= '110508' and nvl(l_audit_trail_enabled,'D') <> 'D' and
      nvl(l_transaction_phase_code,'F') = 'F' and
      not OE_GLOBALS.G_HEADER_CREATED THEN
   IF l_audit_trail_enabled = 'B' THEN  -- capture only for booked orders
      OPEN IS_ORDER_BOOKED (p_record.header_id);
      FETCH IS_ORDER_BOOKED INTO l_order_booked_flag;
      CLOSE IS_ORDER_BOOKED;
      IF l_order_booked_flag = 'Y' THEN
         IF l_result = OE_PC_GLOBALS.YES THEN
            IF x_on_operation_action = 1 THEN
               -- set OUT result to NOT CONSTRAINED
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'HEADER SALES CREDIT SECURITY , ATTRIBUTE CHANGE REQUIRES REASON' , 1 ) ;
               END IF;
               OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
               OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
            ELSIF x_on_operation_action = 2 THEN
               -- set OUT result to NOT CONSTRAINED
               IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG <> 'Y' then
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'HEADER SALES CREDIT SECURITY , ATTRIBUTE CHANGE REQUIRES HISTORY' , 1 ) ;
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
                oe_debug_pub.add(  'HEADER SALES CREDIT SECURITY , ATTRIBUTE CHANGE REQUIRES REASON' , 1 ) ;
            END IF;
            OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
            OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
         ELSIF x_on_operation_action = 2 THEN
            -- set OUT result to NOT CONSTRAINED
            IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG <> 'Y' then
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'HEADER SALES CREDIT SECURITY , ATTRIBUTE CHANGE REQUIRES HISTORY' , 1 ) ;
               END IF;
	       OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'Y';
            END IF;
         END IF;
      END IF;
   END IF;
END IF;
END IF;
/* End AuditTrail */

IF x_on_operation_action > 0 THEN
   l_result := OE_PC_GLOBALS.NO;
END IF;

RETURN l_result;

END Is_Op_Constrained;


-- PUBLIC PROCEDURES

-- Start of fix #1459428  for function definition

FUNCTION ATTRIBUTE1
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE1'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE1;


FUNCTION ATTRIBUTE10
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE10'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE10;


FUNCTION ATTRIBUTE11
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE11'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE11;


FUNCTION ATTRIBUTE12
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE12'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE12;


FUNCTION ATTRIBUTE13
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE13'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE13;


FUNCTION ATTRIBUTE14
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE14'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE14;


FUNCTION ATTRIBUTE15
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE15'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE15;


FUNCTION ATTRIBUTE2
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE2'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE2;


FUNCTION ATTRIBUTE3
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE3'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE3;


FUNCTION ATTRIBUTE4
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE4'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE4;


FUNCTION ATTRIBUTE5
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE5'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE5;


FUNCTION ATTRIBUTE6
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE6'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE6;


FUNCTION ATTRIBUTE7
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE7'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE7;


FUNCTION ATTRIBUTE8
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE8'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE8;


FUNCTION ATTRIBUTE9
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ATTRIBUTE9'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ATTRIBUTE9;


FUNCTION CONTEXT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'CONTEXT'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END CONTEXT;

-- End  of fix #1459428  for function definition

FUNCTION CREATED_BY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'CREATED_BY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END CREATED_BY;


FUNCTION DW_UPDATE_ADVICE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'DW_UPDATE_ADVICE_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END DW_UPDATE_ADVICE;


FUNCTION PERCENT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PERCENT'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END PERCENT;



FUNCTION SALESREP
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SALESREP_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SALESREP;

FUNCTION sales_credit_type
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SALES_CREDIT_TYPE_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END sales_credit_type;

FUNCTION WH_UPDATE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_HEADER_SCREDITS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'WH_UPDATE_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END WH_UPDATE_DATE;


PROCEDURE Entity
(   p_HEADER_SCREDIT_rec            IN  OE_Order_PUB.HEADER_SCREDIT_Rec_Type
, x_result OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

) IS
l_operation	VARCHAR2(1);
l_on_operation_action	NUMBER;
l_rowtype_rec	OE_AK_HEADER_SCREDITS_V%ROWTYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTER OE_HEADER_SCREDIT_SECURITY.ENTITY' , 1 ) ;
END IF;

-- Initializing return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF p_HEADER_SCREDIT_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
    l_operation := OE_PC_GLOBALS.CREATE_OP;
ELSIF p_HEADER_SCREDIT_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_operation := OE_PC_GLOBALS.UPDATE_OP;
ELSIF p_HEADER_SCREDIT_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
    l_operation := OE_PC_GLOBALS.DELETE_OP;
ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INVALID OPERATION' , 1 ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
END IF;

OE_Header_Scredit_Util.API_Rec_To_Rowtype_Rec
	(p_HEADER_SCREDIT_rec,
	l_rowtype_rec);

-- Initialize security global record
OE_Header_Scredit_SECURITY.g_record := l_rowtype_rec;

x_result := Is_OP_constrained
    (p_operation	=> l_operation
    ,p_record	=> l_rowtype_rec
    ,x_on_operation_action	=> l_on_operation_action
    );

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXIT OE_HEADER_SCREDIT_SECURITY.ENTITY' , 1 ) ;
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
(   p_HEADER_SCREDIT_rec            IN  OE_Order_PUB.HEADER_SCREDIT_Rec_Type
,   p_old_HEADER_SCREDIT_rec        IN  OE_Order_PUB.HEADER_SCREDIT_Rec_Type := OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC
, x_result OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

) IS
l_operation	VARCHAR2(1);
l_on_operation_action  NUMBER;
l_result		NUMBER;
l_rowtype_rec	OE_AK_HEADER_SCREDITS_V%ROWTYPE;
l_column_name	VARCHAR2(30);
l_check_all_cols_constraint VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTER OE_HEADER_SCREDIT_SECURITY.ATTRIBUTES' , 1 ) ;
END IF;

-- Initializing return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Initializing out result to NOT CONSTRAINED
x_result := OE_PC_GLOBALS.NO;

 -- Get the operation code to be passed to the security framework API
IF p_HEADER_SCREDIT_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

    l_operation := OE_PC_GLOBALS.CREATE_OP;

    -- Bug 1755817: if there are no attribute-specific insert
    -- constraints, then no need to go further. Entity level
    -- security check for CREATE will be called again from
    -- process order after defaulting.
    IF NOT OE_PC_Constraints_Admin_PVT.Check_On_Insert_Exists
           (p_entity_id   => OE_PC_GLOBALS.G_ENTITY_HEADER_SCREDIT
           ,p_responsibility_id     => nvl(fnd_global.resp_id, -1)
           , p_application_id          => nvl(fnd_global.resp_appl_id,-1) --added for bug3631547
           )
    THEN
       RETURN;
    END IF;

ELSIF p_HEADER_SCREDIT_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_operation := OE_PC_GLOBALS.UPDATE_OP;
ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INVALID OPERATION' , 1 ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
END IF;

OE_Header_Scredit_Util.API_Rec_To_Rowtype_Rec
	(p_HEADER_SCREDIT_rec,
	l_rowtype_rec);

-- Initialize security global record
OE_Header_Scredit_SECURITY.g_record := l_rowtype_rec;

-- Compare the new and old entity records and
-- check constraints for all the changed attributes.

    IF p_header_scredit_rec.percent = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.percent,p_old_header_scredit_rec.percent) THEN

        l_result := PERCENT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_scredit_rec.salesrep_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.salesrep_id,p_old_header_scredit_rec.salesrep_id) THEN

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

  IF p_header_scredit_rec.dw_update_advice_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.Equal(p_header_scredit_rec.dw_update_advice_flag, p_old_header_scredit_rec.dw_update_advice_flag) THEN

        l_result := DW_UPDATE_ADVICE
            (p_operation	=> l_operation
            ,p_record	=> l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;


    IF p_header_scredit_rec.wh_update_date = FND_API.G_MISS_DATE THEN NULL;
      ELSIF NOT OE_GLOBALS.Equal(p_header_scredit_rec.wh_update_date, p_old_header_scredit_rec.wh_update_date) THEN

        l_result := WH_UPDATE_DATE
            (p_operation	=> l_operation
            ,p_record	=> l_rowtype_rec
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

    IF p_header_scredit_rec.context = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.context,p_old_header_scredit_rec.context) THEN

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

   IF p_header_scredit_rec.attribute1 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute1,p_old_header_scredit_rec.attribute1) THEN

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

    IF p_header_scredit_rec.attribute10 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute10,p_old_header_scredit_rec.attribute10) THEN

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

    IF p_header_scredit_rec.attribute11 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute11,p_old_header_scredit_rec.attribute11) THEN

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

    IF p_header_scredit_rec.attribute12 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute12,p_old_header_scredit_rec.attribute12) THEN

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

    IF p_header_scredit_rec.attribute13 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute13,p_old_header_scredit_rec.attribute13) THEN

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

    IF p_header_scredit_rec.attribute14 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute14,p_old_header_scredit_rec.attribute14) THEN

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

    IF p_header_scredit_rec.attribute15 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute15,p_old_header_scredit_rec.attribute15) THEN

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

    IF p_header_scredit_rec.attribute2 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute2,p_old_header_scredit_rec.attribute2) THEN

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

    IF p_header_scredit_rec.attribute3 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute3,p_old_header_scredit_rec.attribute3) THEN

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

    IF p_header_scredit_rec.attribute4 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute4,p_old_header_scredit_rec.attribute4) THEN

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

    IF p_header_scredit_rec.attribute5 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute5,p_old_header_scredit_rec.attribute5) THEN

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

    IF p_header_scredit_rec.attribute6 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute6,p_old_header_scredit_rec.attribute6) THEN

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

    IF p_header_scredit_rec.attribute7 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute7,p_old_header_scredit_rec.attribute7) THEN

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

    IF p_header_scredit_rec.attribute8 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute8,p_old_header_scredit_rec.attribute8) THEN

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

    IF p_header_scredit_rec.attribute9 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.attribute9,p_old_header_scredit_rec.attribute9) THEN

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

    IF p_header_scredit_rec.sales_credit_type_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_scredit_rec.sales_credit_type_id,p_old_header_scredit_rec.sales_credit_type_id) THEN

        l_result := SALES_CREDIT_TYPE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

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
    oe_debug_pub.add(  'EXIT OE_HEADER_SCREDIT_SECURITY.ATTRIBUTES' , 1 ) ;
END IF;

EXCEPTION
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

END OE_Header_Scredit_Security;

/
