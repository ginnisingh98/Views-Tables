--------------------------------------------------------
--  DDL for Package Body QP_PRC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PRC_UTIL" AS
/* $Header: QPXUPRCB.pls 120.2 2005/10/03 23:26:50 srashmi noship $ */

--  Global constants holding the package name.

G_PKG_NAME      	CONSTANT    VARCHAR2(30):='QP_PRC_UTIL';

--  Global variables and tables to keep track if attribute data
--  has been queried yet in the Attribute_Used procedure

G_ATTRIBUTES_QUERIED	BOOLEAN := FALSE;

TYPE Attribute_Tbl_Type IS TABLE OF BOOLEAN
    INDEX BY BINARY_INTEGER;

G_ATTRIBUTE_USED	Attribute_Tbl_Type;
--QP
G_SOLD_TO_ORG_NAME  VARCHAR2(30);
G_SOLD_TO_ORG_CONTEXT VARCHAR2(30);
G_SITE_ORG_NAME      VARCHAR2(30);
G_SITE_ORG_CONTEXT VARCHAR2(30);
G_UNIT_NAME            VARCHAR2(30);
G_UNIT_CONTEXT    VARCHAR2(30);
G_CUSTOMER_CLASS_NAME    VARCHAR2(30);
G_CUSTOMER_CLASS_CONTEXT VARCHAR2(30);
G_CUSTOMER_PO_NAME VARCHAR2(30); --1004
G_CUSTOMER_PO_CONTEXT VARCHAR2(30);
G_ORDER_TYPE_NAME VARCHAR2(30);  --1007
G_ORDER_TYPE_CONTEXT VARCHAR2(30);
G_AGREEMENT_NAME VARCHAR2(30); --1006
G_AGREEMENT_CONTEXT VARCHAR2(30);
G_AGREEMENT_TYPE_NAME VARCHAR2(30); --1005
G_AGREEMENT_TYPE_CONTEXT VARCHAR2(30);
G_DOLLARS_NAME VARCHAR2(30);
G_DOLLARS_CONTEXT VARCHAR2(30);
G_ITEM_CONTEXT VARCHAR2(30);
G_ITEM_NAME  VARCHAR2(30);
G_ITEM_CATEGORY_CONTEXT VARCHAR2(30);
G_ITEM_CATEGORY_NAME VARCHAR2(30);
G_PRICE_LIST_CONTEXT VARCHAR2(30);
G_PRICE_LIST_NAME VARCHAR2(30);
--QP END


--  FUNCTION EQUAL

FUNCTION    Equal
(   p_attr1	IN  NUMBER ,
    p_attr2	IN  NUMBER
) RETURN BOOLEAN
IS
BEGIN

    oe_debug_pub.add('Entering QP_PRC_UTIL.EQUAL', 1);

    RETURN	(   p_attr1 IS NULL	AND
		    p_attr2 IS NULL	    ) OR
		(   p_attr1 IS NOT NULL	AND
		    p_attr2 IS NOT NULL AND
		    p_attr1 = p_attr2	    );

    oe_debug_pub.add('Exiting QP_PRC_UTIL.EQUAL', 1);

END Equal;

FUNCTION    Equal
(   p_attr1	IN  VARCHAR2,
    p_attr2	IN  VARCHAR2
) RETURN BOOLEAN
IS
BEGIN

    RETURN	(   p_attr1 IS NULL	AND
		    p_attr2 IS NULL	    ) OR
		(   p_attr1 IS NOT NULL	AND
		    p_attr2 IS NOT NULL AND
		    p_attr1 = p_attr2	    );

END Equal;

FUNCTION    Equal
(   p_attr1	IN  DATE ,
    p_attr2	IN  DATE
) RETURN BOOLEAN
IS
BEGIN

    RETURN	(   p_attr1 IS NULL	AND
		    p_attr2 IS NULL	    ) OR
		(   p_attr1 IS NOT NULL	AND
		    p_attr2 IS NOT NULL AND
		    p_attr1 = p_attr2	    );

END Equal;



--  Get_Hdr_Adj_Total queries the total of all header level adjustments
--  from DB.

FUNCTION Get_Hdr_Adj_Total
(   p_header_id   	IN  	NUMBER := NULL) RETURN NUMBER
IS
l_adj_total NUMBER := 0;
BEGIN

   oe_debug_pub.add('Entering QP_PRC_UTIL.GET_HDR_ADJ_TOTAL', 1);

    -- If p_header_id is NULL, return 0

    IF p_header_id IS NULL THEN

        oe_debug_pub.add('Exiting QP_PRC_UTIL.GET_HDR_ADJ_TOTAL', 1);

	RETURN 0;
    END IF;

    --	Query total.

    SELECT  SUM ( OPERAND ) --QP change percent to OPERAND  QP END
    INTO    l_adj_total
    FROM    OE_PRICE_ADJUSTMENTS
    WHERE   HEADER_ID = p_header_id
    AND	    LINE_ID IS NULL;

    IF l_adj_total IS NULL THEN

	l_adj_total := 0;

    END IF;

    oe_debug_pub.add('Exiting QP_PRC_UTIL.GET_HDR_ADJ_TOTAL', 1);

    RETURN l_adj_total;

EXCEPTION

    WHEN OTHERS THEN

        -- Unexpected error
	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

	    OE_MSG_PUB.Add_Exc_Msg
	    (   G_PKG_NAME  	    ,
    	        'Price_Utilities - Get_Hdr_Adj_Total'
	    );
	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Hdr_Adj_Total;

--  FUNCTION Get_Agr_Type : Queries the agreement type code from
--  OE_AGREEMENTS.

FUNCTION Get_Agr_Type
(   p_agreement_id   	IN  	NUMBER := NULL
) RETURN VARCHAR2
IS
l_agr_type_code	    VARCHAR2(30);
BEGIN

    oe_debug_pub.add('Entering QP_PRC_UTIL.GET_AGR_TYPE', 1);

    -- If p_agreement_id is NULL, return NULL

    IF p_agreement_id IS NULL THEN

        oe_debug_pub.add('Exiting QP_PRC_UTIL.GET_AGR_TYPE', 1);

	RETURN NULL;
    END IF;

    --	Query Agreement type.

    SELECT  AGREEMENT_TYPE_CODE
    INTO    l_agr_type_code
    FROM    OE_AGREEMENTS
    WHERE   AGREEMENT_ID = p_agreement_id;

    oe_debug_pub.add('Exiting QP_PRC_UTIL.GET_AGR_TYPE', 1);

    RETURN l_agr_type_code;

EXCEPTION

    WHEN OTHERS THEN

        -- Unexpected error
	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

	    OE_MSG_PUB.Add_Exc_Msg
	    (   G_PKG_NAME  	    ,
    	        'Get_Agr_Type. p_agr_id = '||p_agreement_id
	    );
	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Agr_Type;

--Function  Get_Item_Category
-- Usage:
--  This procedure is called from the Price API to fetch the item
--  category if missing.
-- Description:
--   Uses the p_item_id to fetch the item category.
-- Notes
--  This procedure doesn't perform the fetch because this version of
--  the API doesn't support discounting by item category. In future
--  releases, the SQL statement should be added to this procedure.

FUNCTION Get_item_Category
(   p_item_id		IN  NUMBER
) RETURN NUMBER
IS
l_org_id	    NUMBER := NULL;
l_item_category_id  NUMBER := NULL;
BEGIN

    oe_debug_pub.add('Entering QP_PRC_UTIL.GET_ITEM_CATEGORY', 1);

    IF p_item_id IS NOT NULL THEN

	--  Fetch validation org.

	l_org_id := FND_PROFILE.VALUE('SO_ORGANIZATION_ID');

	IF l_org_id IS NOT NULL THEN

	    SELECT  CATEGORY_ID
	    INTO    l_item_category_id
	    FROM    MTL_ITEM_CATEGORIES		CAT
	    ,	    MTL_DEFAULT_CATEGORY_SETS	DCS
	    WHERE   CAT.INVENTORY_ITEM_ID = p_item_id
	    AND	    CAT.ORGANIZATION_ID = l_org_id
	    AND	    CAT.CATEGORY_SET_ID = DCS.CATEGORY_SET_ID
	    AND	    DCS.FUNCTIONAL_AREA_ID = 7;

	END IF;

    END IF;

oe_debug_pub.add('Exiting QP_PRC_UTIL.GET_ITEM_CATEGORY', 1);

RETURN l_item_category_id;


EXCEPTION

    WHEN NO_DATA_FOUND THEN

	RETURN NULL;

    WHEN OTHERS THEN

	-- Unexpected error

	IF OE_MSG_PUB.Check_Msg_Level(
	    OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN

	    OE_MSG_PUB.Add_Exc_Msg
	    (   G_PKG_NAME  	    ,
		'Get_Item_Category'
	    );
	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Item_Category;

--  FUNCTION Get_Cust_Class : Queries the customer class code from
--  RA_CUSTOMERS.

FUNCTION Get_Cust_Class
(   p_sold_to_org_id   	IN  	NUMBER := NULL
) RETURN VARCHAR2
IS
l_class_code	    VARCHAR2(30);
BEGIN

    oe_debug_pub.add('Entering QP_PRC_UTIL.GET_CUST_CLASS', 1);

    -- If p_customer_id is NULL, return NULL

    IF p_sold_to_org_id IS NULL THEN

        oe_debug_pub.add('Exiting QP_PRC_UTIL.GET_CUST_CLASS', 1);

	RETURN NULL;
    END IF;

    --	Query Customer Class Code.

    SELECT  CUSTOMER_CLASS_CODE
    INTO    l_class_code
    FROM    HZ_CUST_ACCOUNTS
    WHERE   CUST_ACCOUNT_ID = p_sold_to_org_id;

    oe_debug_pub.add('Exiting QP_PRC_UTIL.GET_CUST_CLASS', 1);

    RETURN l_class_code;

EXCEPTION

    WHEN OTHERS THEN

        -- Unexpected error
	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

	    OE_MSG_PUB.Add_Exc_Msg
	    (   G_PKG_NAME  	    ,
    	        'Get_Cust_Class. p_cust_id = '||p_sold_to_org_id
	    );
	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Cust_Class;

-- Fix For Bug-1974413
-- This Function returns Attribute Name corresponding to the
-- Attribute Code Passed.

FUNCTION Get_Attribute_Name
(p_attribute_code  IN VARCHAR2
)  RETURN VARCHAR2
  IS
      l_attribute_name  VARCHAR2(240);
  BEGIN
      SELECT AK.NAME
      INTO l_attribute_name
      FROM AK_ATTRIBUTES_VL AK
      WHERE AK.attribute_code = upper(p_attribute_code)
      AND   AK.attribute_application_id = 661;
  RETURN(l_attribute_name);
END Get_Attribute_Name;


-- Procedure Query_Adjustments
-- Usage:
--   This procedure is called from Price_Line and Price_Order.
-- Description:
--   Queries line and/or header level adjustments.
--

PROCEDURE Query_Adjustments
(   p_header_id		IN	NUMBER	:=  NULL    ,
    p_line_id		IN	NUMBER	:=  NULL    ,
    p_adj_tbl		OUT NOCOPY /* file.sql.39 change */	QP_PRC_UTIL.Adj_Short_Tbl_Type
)
IS

    CURSOR  l_line_adj_csr IS
    SELECT  P.PRICE_ADJUSTMENT_ID   ,   --   QP
	    P.LIST_HEADER_ID	    ,   --   CHANGE FROM DISCOUNT_ID TO LIST_HEADER_ID
	    P.LIST_LINE_ID	    ,   --   CHANGE FROM DISCOUNT_LINE TO LIST_LINE_ID
	    P.AUTOMATIC_FLAG	    ,
	    P.OPERAND		    ,   --   CHANGE PERCENT TO OPERAND
	    P.HEADER_ID		    ,   --
	    P.LINE_ID		    ,   -- Change OE_DISCOUNT to QP_LIST_HEADERS
	    D.NAME
    FROM    OE_PRICE_ADJUSTMENTS P, QP_LIST_HEADERS D
    WHERE   P.LINE_ID = p_line_id
    AND	    P.LIST_HEADER_ID = D.LIST_HEADER_ID;
                                        -- QP END
    CURSOR  l_hdr_adj_csr IS
    SELECT  P.PRICE_ADJUSTMENT_ID   ,
	    P.LIST_HEADER_ID	    ,  --QP CHANGE FROM DISCOUNT_ID TO LIST_HEADER_ID
	    P.LIST_LINE_ID	    ,  -- CHANGE FROM DISCOUNT_LINE_ID TO LIST_LINE_ID
	    P.AUTOMATIC_FLAG	    ,
	    P.OPERAND		    ,  -- CHANGE PERCENT TO OPERAN
	    P.HEADER_ID		    ,  -- Change OE_DISCOUNT to QP_LIST_HEADERS
	    D.NAME
    FROM    OE_PRICE_ADJUSTMENTS P, QP_LIST_HEADERS D
    WHERE   HEADER_ID = p_header_id
    AND	    LINE_ID IS NULL
    AND	    P.DISCOUNT_ID = D.LIST_HEADER_ID;
                                       -- QP END

    l_adj_rec		QP_PRC_UTIL.Adj_Short_Rec_Type;
    temp_num		NUMBER;
    adj_number		NUMBER := 0;

BEGIN

    oe_debug_pub.add('Entering QP_PRC_UTIL.QUERY_ADJUSTMENTS', 1);

    --	Header level adjustments.

    IF p_header_id IS NOT NULL THEN

	OPEN l_hdr_adj_csr ;

	LOOP
	    -- load l_adj_rec

	    FETCH l_hdr_adj_csr INTO
		l_adj_rec.adjustment_id	    ,
		l_adj_rec.discount_id	    ,
		l_adj_rec.discount_line_id  ,
		l_adj_rec.automatic_flag    ,
		l_adj_rec.percent	    ,
		l_adj_rec.header_id	    ,
		l_adj_rec.discount_name;

	    EXIT WHEN l_hdr_adj_csr%NOTFOUND;

	    -- add adjustment to adjustment table

	    adj_number := adj_number + 1;
	    p_adj_tbl(adj_number) := l_adj_rec;

	END LOOP;

	CLOSE l_hdr_adj_csr;

    END IF;

    --	Line level adjustments.

    IF p_line_id IS NOT NULL THEN

	OPEN l_line_adj_csr ;

	LOOP
	    -- load l_adj_rec

	    FETCH l_line_adj_csr INTO
		l_adj_rec.adjustment_id	    ,
		l_adj_rec.discount_id	    ,
		l_adj_rec.discount_line_id  ,
		l_adj_rec.automatic_flag    ,
		l_adj_rec.percent	    ,
		l_adj_rec.header_id	    ,
		l_adj_rec.line_id	    ,
		l_adj_rec.discount_name;

	    EXIT WHEN l_line_adj_csr%NOTFOUND;

	    -- add adjustment to adjustment table

	    adj_number := adj_number + 1;
	    p_adj_tbl(adj_number) := l_adj_rec;

	END LOOP;

	CLOSE l_line_adj_csr;

    END IF;

    oe_debug_pub.add('Exiting QP_PRC_UTIL.QUERY_ADJUSTMENTS', 1);

EXCEPTION

    WHEN OTHERS THEN

        -- Unexpected error
	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

	    OE_MSG_PUB.Add_Exc_Msg
	    (   G_PKG_NAME  	    ,
    	        'Query Adjustments. p_header_id = '
		||p_header_id||' p_line_id = '||p_line_id
	    );
	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Adjustments;



-- Function Attribute_Used
-- Usage:
--   Attribute_Used is called from Fetch_Best_Adjustment as a check to
--   see if a call to Get_Adjustment is necessary.
-- Description:
--   This function is used to enhance performance of pricing when a lot
--   of discount lines exist. It checks a profile option
--   OE_DISCOUNT_TUNING, and if set attempts to optimize the number of
--   fetches it does against OE_DISCOUNT_LINES (which is the number of
--   calls to Fetch_Best_Adjustment).
--
--   The function executes a query against OE_DISCOUNT_LINES to select the
--   entites used in discounts. If the attribute_id passed to the function
--   exists in OE_DISCOUNT_LINES the function returns TRUE, otherwise it
--   returns FALSE.
--
--   The function caches this information, so in subsequent calls it
--   doesn't need to hit the database. It uses a PL/SQL table of BOOLEANs
--   G_ATTRIBUTE_USED to store the results.

FUNCTION Attribute_Used
(p_attribute_id		IN  NUMBER) RETURN BOOLEAN
IS
    l_discount_tuning	VARCHAR2(1);
    l_entity_id		VARCHAR2(30);  --QP CHANGE FROM NUMBER TO VARCHAR2
                                       --QP END

    /* QP replace following SQL with new SQL for QP data model
    CURSOR used_entities IS
        SELECT DISTINCT l.entity_id
        FROM   oe_discount_lines l,
               oe_discounts d
        WHERE  d.automatic_discount_flag = 'Y'
        AND    d.discount_id = l.discount_id;
   QP END */
  /*
  CURSOR used_entities IS
  SELECT DISTINCT QPPA.PRODUCT_ATTRIBUTE
  FROM QP_PRICING_ATTRIBUTES QPPA
       , QP_LIST_LINES QPLL
       , QP_LIST_HEADERS QPLH
  WHERE QPLL.LIST_LINE_ID = QPPA.LIST_LINE_ID
  AND QPLL.LIST_HEADER_ID = QPLH.LIST_HEADER_ID
  AND QPLH.AUTOMATIC_FLAG = 'Y'
  AND QPPA.PRODUCT_ATTRIBUTE IN (G_ITEM_NAME
                                ,G_ITEM_CATEGORY_NAME)
  AND QPPA.PRODUCT_ATTRIBUTE_CONTEXT IN  (G_ITEM_CONTEXT
                               ,G_ITEM_CATEGORY_CONTEXT)
  UNION
  SELECT DISTINCT QPQ.QUALIFIER_ATTRIBUTE
  FROM QP_QUALIFIERS QPQ
      ,QP_LIST_HEADERS QPLH
      ,QP_LIST_LINES QPLL
  WHERE QPQ.LIST_HEADER_ID = QPLH.LIST_HEADER_ID
  AND   QPLL.LIST_HEADER_ID = QPLH.LIST_HEADER_ID
  AND   QPLH.AUTOMATIC_FLAG = 'Y'
  AND QPQ.QUALIFIER_ATTRIBUTE IN (G_CUSTOMER_PO_NAME
                                 ,G_AGREEMENT_TYPE_NAME
                                 ,G_AGREEMENT_NAME
                                 ,G_ORDER_TYPE_NAME)
 AND QPQ.QUALIFIER_CONTEXT IN (G_CUSTOMER_PO_CONTEXT
                                 ,G_AGREEMENT_TYPE_CONTEXT
                                 ,G_AGREEMENT_CONTEXT
                                 ,G_ORDER_TYPE_CONTEXT);*/
 --QP END

BEGIN

    oe_debug_pub.add('Entering QP_PRC_UTIL.ATTRIBUTE_USED', 1);

    IF NOT G_ATTRIBUTES_QUERIED THEN

        -- First time to call this function.  Fetch values from DB.

        G_ATTRIBUTES_QUERIED := TRUE;

        l_discount_tuning := FND_PROFILE.VALUE ('OE_DISCOUNT_TUNING');

        IF l_discount_tuning = 'Y' THEN

            -- Set all pricing attributes used flags to TRUE

	    G_ATTRIBUTE_USED(G_ATTR_ITEM) 		:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_ITEM_CATEGORY)	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PO_NUMBER) 		:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_AGREEMENT_TYPE) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_AGREEMENT) 		:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_ORDER_TYPE_ID) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE1) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE2) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE3) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE4) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE5) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE6) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE7) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE8) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE9) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE10) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE11) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE12) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE13) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE14) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE15) 	:= TRUE;

        ELSE

            -- Default all pricing attributes used flags to FALSE

	    G_ATTRIBUTE_USED(G_ATTR_ITEM) 		:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_ITEM_CATEGORY)	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PO_NUMBER) 		:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_AGREEMENT_TYPE) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_AGREEMENT) 		:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_ORDER_TYPE_ID) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE1) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE2) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE3) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE4) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE5) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE6) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE7) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE8) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE9) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE10) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE11) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE12) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE13) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE14) 	:= TRUE;
	    G_ATTRIBUTE_USED(G_ATTR_PRC_ATTRIBUTE15) 	:= TRUE;

            -- Fetch used entity IDs from oe_discount_lines
/*
            OPEN used_entities;
            LOOP
                FETCH used_entities INTO l_entity_id;
                EXIT WHEN used_entities%NOTFOUND; --QP CHANGE TO CONVERT PRICING_ATTRIBUTEX TO NUMBER
                G_ATTRIBUTE_USED(QP_UTIL.GET_ENTITYVALUE(l_entity_id)) := TRUE;
            END LOOP;                            -- CALL QP_UTIL FUNCTION TO DO THAT
            CLOSE used_entities;                 -- QP END
*/
	END IF;

    END IF;

    oe_debug_pub.add('Exiting QP_PRC_UTIL.ATTRIBUTE_USED', 1);

    RETURN G_ATTRIBUTE_USED(p_attribute_id);

EXCEPTION

    WHEN OTHERS THEN

        -- Unexpected error
	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

	    OE_MSG_PUB.Add_Exc_Msg
	    (   G_PKG_NAME  	    ,
    	        'Price_Item - Attribute_Used'
	    );
	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END; -- Attribute_Used



-- Procedure Get_Adjustment
-- Usage:
--   Get_Adjustment is called multiple times from the
--   Fetch_Best_Adjustment procedure, once for each attribute that
--   affects pricing.
-- Description:
--   This procedure executes a query against OE_DISCOUNTS and
--   OE_DISCOUNT_LINES to fetch the best discount available.
--
--   The SQL statment is restricted by percent > l_adj_percent to
--   ensure that we only fetch adjustments higher than we already have.
--
--   The procedure executes one of 2 queries based on the
--   p_attribute_id passed to it.  If p_attribute_id is null, it only
--   queries OE_DISCOUNTS, otherwise it queries against OE_DISCOUNTS and
--   OE_DISCOUNT_LINES.

PROCEDURE Get_Adjustment
( p_best_adj_rec	IN  Adj_Short_Rec_Type				,
  p_best_adj_percent	IN  NUMBER					,
  p_attribute_id	IN  NUMBER					,
  p_attribute_value	IN  VARCHAR2					,
  p_price_list_id	IN  NUMBER					,
  p_quantity		IN  NUMBER					,
  p_list_price		IN  NUMBER					,
  p_sold_to_org_id		IN  NUMBER					,
  p_customer_class_code	IN  VARCHAR2					,
  p_gsa			IN  VARCHAR2					,
  p_ship_to_id		IN  NUMBER					,
  p_invoice_to_id	IN  NUMBER					,
  p_unit_code		IN  VARCHAR2					,
  p_adj_rec		OUT NOCOPY /* file.sql.39 change */  Adj_Short_Rec_Type				,
  p_adj_percent		OUT NOCOPY /* file.sql.39 change */ NUMBER
)



IS

     TYPE discount_cursor	IS ref CURSOR;
     TYPE discount_line_cursor	IS ref CURSOR;

     l_discount_csr		discount_cursor;
     l_discount_lines_csr	discount_line_cursor;

     l_discounting_type		VARCHAR2(30) := NULL;
     l_pricing_date		DATE;

     l_adj_rec			Adj_Short_Rec_Type := p_best_adj_rec;
     l_qp_discount_line_rec QP_PRICING_ENGINE_PVT.l_discount_line_rec;

BEGIN

    oe_debug_pub.add('Entering QP_PRC_UTIL.GET_ADJUSTMENT', 1);



    IF p_list_price = 0 THEN

	--  list price is zero. Same behavior as if no adjustments
	--  were fetched.

	l_adj_rec := p_best_adj_rec ;
	p_adj_percent := l_adj_rec.percent;

	RETURN;
    END IF;


    l_discounting_type := FND_PROFILE.VALUE ('OE_DISCOUNTING_TYPE');


    -- Get pricing_date
    l_pricing_date	:= Nvl(l_adj_rec.pricing_date, Sysdate);


    IF p_attribute_id IS NULL THEN

        -- Perform fetch without hitting discount lines

       IF l_discounting_type = 'LOW' THEN



--DBMS_OUTPUT.PUT_LINE('+================================+');
--DBMS_OUTPUT.PUT_LINE('|IN Big select statement --Header| ');
--DBMS_OUTPUT.PUT_LINE('+================================+');
--DBMS_OUTPUT.PUT_LINE('Discounting type is low--ASC');
--DBMS_OUTPUT.PUT_LINE('p_gsa : '||p_gsa);
--DBMS_OUTPUT.PUT_LINE('l_pricing_date : '||l_pricing_date);
OE_DEBUG_PUB.ADD('+================================+');
OE_DEBUG_PUB.ADD('|IN Big select statement --Header| ');
OE_DEBUG_PUB.ADD('+================================+');
OE_DEBUG_PUB.ADD('Discounting type is low--ASC');
OE_DEBUG_PUB.ADD('p_gsa : '||p_gsa);
OE_DEBUG_PUB.ADD('l_pricing_date : '||l_pricing_date);



OPEN l_discount_csr FOR
	  SELECT    QPH.LIST_HEADER_ID, QPL.LIST_LINE_ID, QPH.NAME,
          DECODE(QPL.ARITHMETIC_OPERATOR,'AMT',NVL(QPL.OPERAND/p_list_price * 100,0),
           '%',NVL(QPL.OPERAND,0))
FROM  QP_LIST_HEADERS QPH , QP_LIST_LINES QPL , QP_QUALIFIERS QPQ
WHERE QPH.LIST_HEADER_ID = QPL.LIST_HEADER_ID
AND   QPH.LIST_HEADER_ID = QPQ.LIST_HEADER_ID
AND   QPQ.QUALIFIER_CONTEXT = G_PRICE_LIST_CONTEXT
AND   QPQ.QUALIFIER_ATTRIBUTE =G_PRICE_LIST_NAME
AND   QPQ.QUALIFIER_ATTR_VALUE = p_price_list_id
AND   QPH.AUTOMATIC_FLAG = 'Y'
AND   QPH.DISCOUNT_LINES_FLAG = 'N'
AND   (p_gsa = 'Y'
       OR NVL(QPH.GSA_INDICATOR,'N') = 'N')
AND   TRUNC(l_pricing_date) BETWEEN NVL(QPH.START_DATE_ACTIVE, TRUNC(l_pricing_date))
	AND     NVL(QPH.END_DATE_ACTIVE, l_pricing_date)
AND   DECODE(QPL.ARITHMETIC_OPERATOR,'AMT',NVL(QPL.OPERAND/p_list_price * 100,0),
	 '%', NVL(QPL.OPERAND,0)) < p_best_adj_percent
AND  ( NOT EXISTS (SELECT NULL
			  FROM QP_QUALIFIERS QPQ
			  WHERE QPQ.LIST_HEADER_ID = QPH.LIST_HEADER_ID
			  AND   QPQ.QUALIFIER_CONTEXT = G_CUSTOMER_CLASS_CONTEXT
			  AND   QPQ.QUALIFIER_ATTRIBUTE IN (G_CUSTOMER_CLASS_NAME
                                                           ,G_SOLD_TO_ORG_NAME
							   ,G_SITE_ORG_NAME))
	 OR
          (         EXISTS(SELECT NULL
		   		        FROM QP_QUALIFIERS QPQ
		   			   WHERE QPQ.LIST_HEADER_ID = QPH.LIST_HEADER_ID
	           		   AND (QPQ.QUALIFIER_CONTEXT = G_SOLD_TO_ORG_CONTEXT
	           		   AND QPQ.QUALIFIER_ATTRIBUTE = G_SOLD_TO_ORG_NAME
		   			   AND NVL(QPQ.QUALIFIER_ATTR_VALUE,p_sold_to_org_id) = p_sold_to_org_id))
	  		 OR  EXISTS(SELECT NULL
		   			  FROM QP_QUALIFIERS QPQ
		   			  WHERE QPQ.LIST_HEADER_ID = QPH.LIST_HEADER_ID
		   			  AND (qpq.qualifier_context = G_CUSTOMER_CLASS_CONTEXT
	              		  AND QPQ.QUALIFIER_ATTRIBUTE = G_CUSTOMER_CLASS_NAME
		   	    		  AND NVL(QPQ.QUALIFIER_ATTR_VALUE,p_customer_class_code) =
					  p_customer_class_code))
	   		AND  EXISTS(SELECT NULL
		   			FROM QP_QUALIFIERS QPQ
		   			WHERE (QPQ.QUALIFIER_CONTEXT = G_CUSTOMER_CLASS_CONTEXT
	           		AND QPQ.QUALIFIER_ATTRIBUTE = G_SITE_ORG_NAME
		   	     	AND (NVL(QPQ.QUALIFIER_ATTR_VALUE,p_ship_to_id) = p_ship_to_id
			         OR NVL(QPQ.QUALIFIER_ATTR_VALUE,p_invoice_to_id) = p_invoice_to_id)))))
AND   TRUNC(l_pricing_date) BETWEEN NVL(QPH.START_DATE_ACTIVE, TRUNC(l_pricing_date))
	AND     NVL(QPH.END_DATE_ACTIVE, l_pricing_date)
ORDER BY DECODE(QPL.ARITHMETIC_OPERATOR,'AMT',nvl(QPL.OPERAND/p_list_price * 100,0),
	  '%', NVL(QPL.OPERAND,0)) ASC;
--QP END above is the case to get lowest discount

	ELSE


--NEW SQL
--DBMS_OUTPUT.PUT_LINE('+================================+');
--DBMS_OUTPUT.PUT_LINE('|IN Big select statement --Header| ');
--DBMS_OUTPUT.PUT_LINE('+================================+');
--DBMS_OUTPUT.PUT_LINE('Discounting type is low--DESC');
--DBMS_OUTPUT.PUT_LINE('p_gsa : '||p_gsa);
--DBMS_OUTPUT.PUT_LINE('l_pricing_date : '||l_pricing_date);
OE_DEBUG_PUB.ADD('+================================+');
OE_DEBUG_PUB.ADD('|IN Big select statement --Header| ');
OE_DEBUG_PUB.ADD('+================================+');
OE_DEBUG_PUB.ADD('Discounting type is low--DESC');
OE_DEBUG_PUB.ADD('p_gsa : '||p_gsa);
OE_DEBUG_PUB.ADD('l_pricing_date : '||l_pricing_date);

OPEN l_discount_csr FOR
       SELECT    QPH.LIST_HEADER_ID,QPL.LIST_LINE_ID, QPH.NAME,
          DECODE(QPL.ARITHMETIC_OPERATOR,'AMT',NVL(QPL.OPERAND/p_list_price * 100,0),
           '%',NVL(QPL.OPERAND,0))
FROM  QP_LIST_HEADERS QPH , QP_LIST_LINES QPL , QP_QUALIFIERS QPQ
WHERE QPH.LIST_HEADER_ID = QPL.LIST_HEADER_ID
AND   QPH.LIST_HEADER_ID = QPQ.LIST_HEADER_ID
AND   QPQ.QUALIFIER_CONTEXT = G_PRICE_LIST_CONTEXT
AND   QPQ.QUALIFIER_ATTRIBUTE =G_PRICE_LIST_NAME
AND   QPQ.QUALIFIER_ATTR_VALUE = p_price_list_id
AND   QPH.AUTOMATIC_FLAG = 'Y'
AND   QPH.DISCOUNT_LINES_FLAG = 'N'
AND   (p_gsa = 'Y'
       OR NVL(QPH.GSA_INDICATOR,'N') = 'N')
AND   TRUNC(l_pricing_date) BETWEEN NVL(QPH.START_DATE_ACTIVE, TRUNC(l_pricing_date))
	AND     NVL(QPH.END_DATE_ACTIVE, l_pricing_date)
AND   DECODE(QPL.ARITHMETIC_OPERATOR,'AMT',NVL(QPL.OPERAND/p_list_price * 100,0),
	 '%', NVL(QPL.OPERAND,0)) > p_best_adj_percent
AND  ( NOT EXISTS (SELECT NULL
			  FROM QP_QUALIFIERS QPQ
			  WHERE QPQ.LIST_HEADER_ID = QPH.LIST_HEADER_ID
			  AND   QPQ.QUALIFIER_CONTEXT = G_CUSTOMER_CLASS_CONTEXT
			  AND   QPQ.QUALIFIER_ATTRIBUTE IN (G_CUSTOMER_CLASS_NAME
                                                           ,G_SOLD_TO_ORG_NAME
							   ,G_SITE_ORG_NAME))
	 OR
          (         EXISTS(SELECT NULL
		   		        FROM QP_QUALIFIERS QPQ
		   			   WHERE QPQ.LIST_HEADER_ID = QPH.LIST_HEADER_ID
	           		   AND (QPQ.QUALIFIER_CONTEXT = G_SOLD_TO_ORG_CONTEXT
	           		   AND QPQ.QUALIFIER_ATTRIBUTE = G_SOLD_TO_ORG_NAME
		   			   AND NVL(QPQ.QUALIFIER_ATTR_VALUE,p_sold_to_org_id) = p_sold_to_org_id))
	  		AND  EXISTS(SELECT NULL
		   			  FROM QP_QUALIFIERS QPQ
		   			  WHERE QPQ.LIST_HEADER_ID = QPH.LIST_HEADER_ID
		   			  AND (qpq.qualifier_context = G_CUSTOMER_CLASS_CONTEXT
	              		  AND QPQ.QUALIFIER_ATTRIBUTE = G_CUSTOMER_CLASS_NAME
		   	    		  AND NVL(QPQ.QUALIFIER_ATTR_VALUE,
                                                NVL(p_customer_class_code,'NULL')) =
					        NVL(p_customer_class_code,'NULL') ))
	   		AND  EXISTS(SELECT NULL
		   			FROM QP_QUALIFIERS QPQ
		   			WHERE QPQ.QUALIFIER_CONTEXT = G_CUSTOMER_CLASS_CONTEXT
	           		AND QPQ.QUALIFIER_ATTRIBUTE = G_SITE_ORG_NAME
		   	     	AND (NVL(QPQ.QUALIFIER_ATTR_VALUE,p_ship_to_id) = p_ship_to_id
			             OR NVL(QPQ.QUALIFIER_ATTR_VALUE,p_invoice_to_id) = p_invoice_to_id
                                     )
                                    )
            )
         )

AND   TRUNC(l_pricing_date) BETWEEN NVL(QPH.START_DATE_ACTIVE, TRUNC(l_pricing_date))
	AND     NVL(QPH.END_DATE_ACTIVE, l_pricing_date)
ORDER BY DECODE(QPL.ARITHMETIC_OPERATOR,'AMT',nvl(QPL.OPERAND/p_list_price * 100,0),
	  '%', NVL(QPL.OPERAND,0)) DESC;
       END IF;


	--  Fetch the first discount.

	FETCH l_discount_csr INTO

	    l_adj_rec.discount_id   ,
            l_adj_rec.discount_line_id,
            l_adj_rec.discount_name ,
            l_adj_rec.percent	    ;

	IF l_discount_csr%NOTFOUND THEN
	    --DBMS_output.put_line('Got the Discount');
	    p_adj_rec := p_best_adj_rec;
	    p_adj_percent := p_best_adj_percent;

	ELSE
	    --DBMS_output.put_line('Did not get the Discount');

	    p_adj_rec := l_adj_rec;
	    p_adj_percent := l_adj_rec.percent;

	END IF;

	CLOSE l_discount_csr;

    ELSE

        -- Perform fetch hitting discount lines

       IF l_discounting_type = 'LOW' THEN

        --QP following SQL is commented out for new datamodel
        --it is replaced by a sigle procedure call
        /*
	  OPEN l_discount_lines_csr FOR
	    SELECT
	     ORDERED
            INDEX(OEDLN OE_DISCOUNT_LINE_N2)
            INDEX(OEDIS OE_DISCOUNTS_U1)
            OEDIS.DISCOUNT_ID,
            OEDIS.NAME,
            NVL( OEDLN.DISCOUNT_LINE_ID, -1 ),
            NVL( OEDIS.AMOUNT / p_list_price * 100,
            NVL( OEDIS.PERCENT,
            NVL( ( p_list_price - OEDLN.PRICE ) / p_list_price * 100,
            NVL( OEDLN.AMOUNT / p_list_price * 100,
            NVL( OEDLN.PERCENT,
            NVL( ( p_list_price - OEPBL.PRICE ) / p_list_price * 100,
            NVL( OEPBL.AMOUNT / p_list_price * 100,
		 NVL( OEPBL.PERCENT, 0 ) ) ) ) ) ) ) )
	    FROM     OE_DISCOUNT_LINES OEDLN
	    ,        OE_DISCOUNTS OEDIS
	    ,        OE_PRICE_BREAK_LINES OEPBL
	    WHERE    OEDLN.ENTITY_ID = p_attribute_id
	    AND      OEDLN.ENTITY_VALUE = p_attribute_value
	    AND      TRUNC(L_PRICING_DATE) BETWEEN
                       NVL( OEDLN.START_DATE_ACTIVE, TRUNC(L_PRICING_DATE) )
                         AND  NVL( OEDLN.END_DATE_ACTIVE, TRUNC(L_PRICING_DATE) )
	    AND      OEDIS.DISCOUNT_ID  = OEDLN.DISCOUNT_ID
	    AND      OEDIS.PRICE_LIST_ID = p_price_list_id
	    AND      OEDIS.AUTOMATIC_DISCOUNT_FLAG = 'Y'
	    AND    ( p_gsa = 'Y'
		     OR       NVL( OEDIS.GSA_INDICATOR, 'N' ) = 'N' )
	    AND      TRUNC(L_PRICING_DATE)
                       BETWEEN NVL( OEDIS.START_DATE_ACTIVE, TRUNC(L_PRICING_DATE) )
                         AND     NVL( OEDIS.END_DATE_ACTIVE, TRUNC(L_PRICING_DATE) )
	    AND      OEPBL.DISCOUNT_LINE_ID (+) = OEDLN.DISCOUNT_LINE_ID
	    AND      TRUNC(L_PRICING_DATE)
                     BETWEEN NVL( OEPBL.START_DATE_ACTIVE (+), TRUNC(L_PRICING_DATE) )
                     AND     NVL( OEPBL.END_DATE_ACTIVE (+), TRUNC(L_PRICING_DATE) )
	    AND      DECODE( OEPBL.METHOD_TYPE_CODE (+),
                         'UNITS', p_quantity,
                         'DOLLARS', p_quantity * p_list_price,
                         0 )
                 BETWEEN NVL( OEPBL.PRICE_BREAK_LINES_LOW_RANGE (+),
                              DECODE( OEPBL.METHOD_TYPE_CODE (+),
                                      'UNITS', p_quantity,
                                      'DOLLARS', p_quantity * p_list_price,
                                      0 ) )
                 AND     NVL( OEPBL.PRICE_BREAK_LINES_HIGH_RANGE (+),
                              DECODE( OEPBL.METHOD_TYPE_CODE (+),
                                      'UNITS', p_quantity,
                                      'DOLLARS', p_quantity * p_list_price,
                                      0 ) )
	    AND      NVL(OEPBL.UNIT_CODE(+),NVL(p_unit_code,'NULL'))=
                 NVL(p_unit_code,'NULL')
	    AND      NVL( OEDIS.AMOUNT / p_list_price * 100,
			  NVL( OEDIS.PERCENT,
                 NVL( ( p_list_price - OEDLN.PRICE ) / p_list_price * 100,
                 NVL( OEDLN.AMOUNT / p_list_price * 100,
                 NVL( OEDLN.PERCENT,
                 NVL( ( p_list_price - OEPBL.PRICE ) / p_list_price * 100,
                 NVL( OEPBL.AMOUNT / p_list_price * 100,
                 NVL( OEPBL.PERCENT , 0 ) ) ) ) ) ) ) ) < p_best_adj_percent
	    AND    ( NOT EXISTS (SELECT NULL
				 FROM   OE_DISCOUNT_CUSTOMERS OECST
				 WHERE  OECST.DISCOUNT_ID = OEDIS.DISCOUNT_ID )
		     OR  EXISTS (SELECT NULL
				 FROM   OE_DISCOUNT_CUSTOMERS OECST
				 WHERE  OECST.DISCOUNT_ID = OEDIS.DISCOUNT_ID
				 AND  NVL( OECST.sold_to_org_id, p_sold_to_org_id ) =
				      p_sold_to_org_id
				 AND  NVL(  OECST.CUSTOMER_CLASS_CODE,
					    NVL ( p_customer_class_code, 'NULL'
						  ) )=
				 NVL ( p_customer_class_code , 'NULL' )
				 AND ( NVL( OECST.site_org_id, p_ship_to_id) =
				       p_ship_to_id
				       OR
				       NVL( OECST.site_org_id, p_invoice_to_id)
				       = p_invoice_to_id )
				 AND    TRUNC(L_PRICING_DATE)
				 BETWEEN NVL( OECST.START_DATE_ACTIVE,
					      TRUNC(L_PRICING_DATE))
				 AND   NVL( OECST.END_DATE_ACTIVE,
					    TRUNC(L_PRICING_DATE))))
	    ORDER BY NVL( OEDIS.AMOUNT / p_list_price * 100,
                     NVL( OEDIS.PERCENT,
		     NVL( ( p_list_price - OEDLN.PRICE ) / p_list_price * 100,
		     NVL( OEDLN.AMOUNT / p_list_price * 100,
		     NVL( OEDLN.PERCENT,
		     NVL( ( p_list_price - OEPBL.PRICE ) / p_list_price * 100,
		     NVL( OEPBL.AMOUNT / p_list_price * 100,
		     NVL( OEPBL.PERCENT, 0 ) ) ) ) ) ) ) ) ASC;
       */

           -- Call QP_PRICING_ENGINE to perform above SQL operation
/*DBMS_output.put_line('list '||p_price_list_id||' qty '||p_quantity
		||'attr'||p_attribute_id||' valu '||p_attribute_value
||'date '||l_pricing_date);*/

            QP_PRICING_ENGINE_PVT.GET_DISCOUNT_LINES(p_price_list_id
                                                ,p_list_price
                                                ,p_quantity
                                                ,p_unit_code
                                                ,p_attribute_id
                                                ,p_attribute_value
                                                ,l_pricing_date
                                                ,p_customer_class_code
                                                ,p_sold_to_org_id
                                                ,p_ship_to_id
                                                ,p_invoice_to_id
                                                ,p_best_adj_percent
                                                ,p_gsa
                                                ,'A'  --A for ascending
                                                ,l_qp_discount_line_rec);



	ELSE

/*
	  OPEN l_discount_lines_csr FOR
	    SELECT
	     ORDERED
            INDEX(OEDLN OE_DISCOUNT_LINE_N2)
            INDEX(OEDIS OE_DISCOUNTS_U1)
            OEDIS.DISCOUNT_ID,
            OEDIS.NAME,
            NVL( OEDLN.DISCOUNT_LINE_ID, -1 ),
            NVL( OEDIS.AMOUNT / p_list_price * 100,
            NVL( OEDIS.PERCENT,
            NVL( ( p_list_price - OEDLN.PRICE ) / p_list_price * 100,
            NVL( OEDLN.AMOUNT / p_list_price * 100,
            NVL( OEDLN.PERCENT,
            NVL( ( p_list_price - OEPBL.PRICE ) / p_list_price * 100,
            NVL( OEPBL.AMOUNT / p_list_price * 100,
		 NVL( OEPBL.PERCENT, 0 ) ) ) ) ) ) ) )
	    FROM     OE_DISCOUNT_LINES OEDLN
	    ,        OE_DISCOUNTS OEDIS
	    ,        OE_PRICE_BREAK_LINES OEPBL
	    WHERE    OEDLN.ENTITY_ID = p_attribute_id
	    AND      OEDLN.ENTITY_VALUE = p_attribute_value
	    AND      TRUNC(L_PRICING_DATE) BETWEEN
                       NVL( OEDLN.START_DATE_ACTIVE, TRUNC(L_PRICING_DATE) )
                         AND  NVL( OEDLN.END_DATE_ACTIVE, TRUNC(L_PRICING_DATE) )
	    AND      OEDIS.DISCOUNT_ID  = OEDLN.DISCOUNT_ID
	    AND      OEDIS.PRICE_LIST_ID = p_price_list_id
	    AND      OEDIS.AUTOMATIC_DISCOUNT_FLAG = 'Y'
	    AND    ( p_gsa = 'Y'
		     OR       NVL( OEDIS.GSA_INDICATOR, 'N' ) = 'N' )
	    AND      TRUNC(L_PRICING_DATE)
                       BETWEEN NVL( OEDIS.START_DATE_ACTIVE, TRUNC(L_PRICING_DATE) )
                         AND     NVL( OEDIS.END_DATE_ACTIVE, TRUNC(L_PRICING_DATE) )
	    AND      OEPBL.DISCOUNT_LINE_ID (+) = OEDLN.DISCOUNT_LINE_ID
	    AND      TRUNC(L_PRICING_DATE)
                     BETWEEN NVL( OEPBL.START_DATE_ACTIVE (+), TRUNC(L_PRICING_DATE) )
                     AND     NVL( OEPBL.END_DATE_ACTIVE (+), TRUNC(L_PRICING_DATE) )
	    AND      DECODE( OEPBL.METHOD_TYPE_CODE (+),
                         'UNITS', p_quantity,
                         'DOLLARS', p_quantity * p_list_price,
                         0 )
                 BETWEEN NVL( OEPBL.PRICE_BREAK_LINES_LOW_RANGE (+),
                              DECODE( OEPBL.METHOD_TYPE_CODE (+),
                                      'UNITS', p_quantity,
                                      'DOLLARS', p_quantity * p_list_price,
                                      0 ) )
                 AND     NVL( OEPBL.PRICE_BREAK_LINES_HIGH_RANGE (+),
                              DECODE( OEPBL.METHOD_TYPE_CODE (+),
                                      'UNITS', p_quantity,
                                      'DOLLARS', p_quantity * p_list_price,
                                      0 ) )
	    AND      NVL(OEPBL.UNIT_CODE(+),NVL(p_unit_code,'NULL'))=
                 NVL(p_unit_code,'NULL')
	    AND      NVL( OEDIS.AMOUNT / p_list_price * 100,
			  NVL( OEDIS.PERCENT,
                 NVL( ( p_list_price - OEDLN.PRICE ) / p_list_price * 100,
                 NVL( OEDLN.AMOUNT / p_list_price * 100,
                 NVL( OEDLN.PERCENT,
                 NVL( ( p_list_price - OEPBL.PRICE ) / p_list_price * 100,
                 NVL( OEPBL.AMOUNT / p_list_price * 100,
                 NVL( OEPBL.PERCENT , 0 ) ) ) ) ) ) ) ) > p_best_adj_percent
	    AND    ( NOT EXISTS (SELECT NULL
				 FROM   OE_DISCOUNT_CUSTOMERS OECST
				 WHERE  OECST.DISCOUNT_ID = OEDIS.DISCOUNT_ID )
		     OR  EXISTS (SELECT NULL
				 FROM   OE_DISCOUNT_CUSTOMERS OECST
				 WHERE  OECST.DISCOUNT_ID = OEDIS.DISCOUNT_ID
				 AND  NVL( OECST.sold_to_org_id, p_sold_to_org_id ) =
				      p_sold_to_org_id
				 AND  NVL(  OECST.CUSTOMER_CLASS_CODE,
					    NVL ( p_customer_class_code, 'NULL'
						  ) )=
				 NVL ( p_customer_class_code , 'NULL' )
				 AND ( NVL( OECST.site_org_id, p_ship_to_id) =
				       p_ship_to_id
				       OR
				       NVL( OECST.site_org_id, p_invoice_to_id)
				       = p_invoice_to_id )
				 AND    TRUNC(L_PRICING_DATE)
				 BETWEEN NVL( OECST.START_DATE_ACTIVE,
					      TRUNC(L_PRICING_DATE))
				 AND   NVL( OECST.END_DATE_ACTIVE,
					    TRUNC(L_PRICING_DATE))))
	    ORDER BY NVL( OEDIS.AMOUNT / p_list_price * 100,
                     NVL( OEDIS.PERCENT,
		     NVL( ( p_list_price - OEDLN.PRICE ) / p_list_price * 100,
		     NVL( OEDLN.AMOUNT / p_list_price * 100,
		     NVL( OEDLN.PERCENT,
		     NVL( ( p_list_price - OEPBL.PRICE ) / p_list_price * 100,
		     NVL( OEPBL.AMOUNT / p_list_price * 100,
		     NVL( OEPBL.PERCENT, 0 ) ) ) ) ) ) ) ) DESC;
*/

--DBMS_output.put_line('IN QPXUPRCB--BEFORE QP_PRICING_ENGINE_PVT');
--DBMS_output.put_line('p_price_list_id: '|| p_price_list_id);
--DBMS_output.put_line('p_quantity: '||p_quantity);
--DBMS_output.put_line('p_unit_code: ' || p_unit_code);
--DBMS_output.put_line('p_attribute_id: '||p_attribute_id);
--DBMS_output.put_line('p_attribute_value: '|| p_attribute_value);
--DBMS_output.put_line('l_pricing_date: '||l_pricing_date);
--DBMS_output.put_line('p_customer_class_code: '||p_customer_class_code);
--DBMS_output.put_line('p_sold_to_org_id: '||p_sold_to_org_id);
--DBMS_output.put_line('p_ship_to_id: '||p_ship_to_id);
--DBMS_output.put_line('p_invoice_to_id: '||p_invoice_to_id);
--DBMS_output.put_line('p_best_adj_percent: '||p_best_adj_percent);

        QP_PRICING_ENGINE_PVT.GET_DISCOUNT_LINES(p_price_list_id
                                                ,p_list_price
                                                ,p_quantity
                                                ,p_unit_code
                                                ,p_attribute_id
                                                ,p_attribute_value
                                                ,l_pricing_date
                                                ,p_customer_class_code
                                                ,p_sold_to_org_id
                                                ,p_ship_to_id
                                                ,p_invoice_to_id
                                                ,nvl(p_best_adj_percent,0)
                                                ,'Y'
                                                ,'D'  --D for descending
                                                ,l_qp_discount_line_rec);


--DBMS_output.put_line('IN QPXUPRCB--AFTER QP_PRICING_ENGINE_PVT');

       END IF;


       -- comment out following statement
       --  Fetch the first discount line.
/*
	FETCH l_discount_lines_csr INTO

	    l_adj_rec.discount_id	,
            l_adj_rec.discount_name	,
            l_adj_rec.discount_line_id	,
            l_adj_rec.percent		;
*/
--above statement replaced by following statements
  l_adj_rec.discount_id := l_qp_discount_line_rec.p_discount_id;
  l_adj_rec.discount_name := l_qp_discount_line_rec.p_discount_name;
  l_adj_rec.discount_line_id := l_qp_discount_line_rec.p_discount_line_id;
  l_adj_rec.percent :=  l_qp_discount_line_rec.p_discount_percent;
  --DBMS_output.put_line('New discount_id: ' ||l_qp_discount_line_rec.p_discount_id);
  --DBMS_output.put_line('New percent: '||l_qp_discount_line_rec.p_discount_percent);

--QP END

	-- Debug info
/*
	OE_MSG_PUB.Add_Exc_Msg
	(   p_error_text => 'In Get Adjustment - After fetch - '||
	    ' p_attr_id = '||p_attribute_id||
	    ' p_attr_value = '||p_attribute_value||
	    ' p_disc_name = '||l_adj_rec.discount_name||
	    ' percent = '||l_adj_rec.percent
	);
*/

--QP
  --DBMS_output.put_line('Old discount_id: ' ||p_adj_rec.discount_id);
  --DBMS_output.put_line('Old percent: '||p_adj_rec.percent);

           IF l_adj_rec.percent IS NOT null THEN
           --DBMS_output.put_line('Old kills me: ');
	    p_adj_rec := l_adj_rec;
	    p_adj_percent := l_adj_rec.percent;
           ELSE
            p_adj_rec := p_best_adj_rec;
            p_adj_percent := p_best_adj_percent;
           END IF;

--QP END


    END IF;

    oe_debug_pub.add('Exiting QP_PRC_UTIL.GET_ADJUSTMENT', 1);

EXCEPTION

    WHEN OTHERS THEN

        -- Unexpected error
	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

	    OE_MSG_PUB.Add_Exc_Msg
	    (   G_PKG_NAME  	    ,
		'Price_Item - Get_Adjustment, p_attribute_id = '||p_attribute_id
	    );
	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END; -- Get_Adjustment

-- Function Get_GSA
-- Usage:
--   Get_GSA is called from Fetch_Best_Adjustment if no value for
--   GSA is provided as a parameter to that procedure.
-- Description:
--   Queries the GSA value from the database according to the customer_id
--   and invoice_to_site_use_id parameters.

FUNCTION Get_GSA (p_sold_to_org_id 	IN NUMBER,
                  p_invoice_to_id	IN NUMBER) RETURN VARCHAR2
IS
    l_GSA	VARCHAR2(1) := NULL;
    l_error_msg VARCHAR2(240);

BEGIN

    oe_debug_pub.add('Entering QP_PRC_UTIL.GET_GSA', 1);

    -- If the invoice to is NULL, then the order is automatically not GSA

    IF p_invoice_to_id IS NULL THEN

        oe_debug_pub.add('Exiting QP_PRC_UTIL.GET_GSA', 1);

        RETURN 'N';

    ELSE
        -- Get invoice to GSA indicator

        SELECT GSA_INDICATOR
        INTO   l_GSA
        FROM   HZ_CUST_SITE_USES
        WHERE  SITE_USE_ID = p_invoice_to_id;

 	l_error_msg := 'Get invoice to GSA indicator';
    END IF;


    -- If invoice to GSA indicator  is NULL, then get
    -- get the customer GSA indicator

    IF l_GSA IS NULL THEN
        IF p_sold_to_org_id IS NOT NULL THEN
            SELECT NVL( DECODE(party.PARTY_TYPE,'ORGANIZATION',party.GSA_INDICATOR_FLAG, 'N'),'N' )
            INTO   l_gsa
            FROM  HZ_CUST_ACCOUNTS cust_acct,HZ_PARTIES party
	    WHERE  cust_acct.PARTY_ID = party.PARTY_ID and
                 cust_acct.CUST_ACCOUNT_ID = p_sold_to_org_id;
        END IF;

 	l_error_msg := 'Get the customer GSA indicator';
    END IF;


    --  If the GSA indicator is NULL, then set it to 'N' (No)

    IF l_gsa IS NULL THEN

        l_gsa := 'N';

    END IF;


    -- Return the GSA Value

    oe_debug_pub.add('Exiting QP_PRC_UTIL.GET_GSA', 1);

    RETURN l_gsa;

EXCEPTION

    WHEN OTHERS THEN

        -- Unexpected error
	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

	    OE_MSG_PUB.Add_Exc_Msg
	    (   G_PKG_NAME  	    ,
                'Price_Item - Get_GSA, section '||l_error_msg
	    );
	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END; -- Get_GSA



-- Procedure Fetch_Best_Adjustment
-- Usage:
--   Called from Price_Item to return the best available price
--   adjustment available based on the item's criteria.
-- Description:
--   The following attributes are the discounting attributes:
--      p_item_id
--      p_pricing_attribute1 through p_pricing_attribute15
--      p_po_number
--      p_agreement_id
--      p_agreement_type_code
--      p_order_type_id
--   If an attribute is not null and is used as a pricing entity, then
--   we execute a fetch using the attribute as the entity.  For
--   performance reasons, a fetch against oe_discount_lines is
--   performed for each attribute (in order to hit the
--   appropriate indexes).
--   We also execute an initial fetch for the best adjustment from
--   discounts that have no discount lines.
--
--   The following attributed are used in the fetch query:
--      p_price_list_id		required
--      p_list_price		required
--      p_quantity		optional
--      p_unit_code		optional
--      p_ship_to_id		optional
--      p_customer_id		optional
--      p_customer_class_code  	optional
--      p_invoice_to_id		optional
--      p_gsa			optional
--
--  In order to optimize performance and reduce the number of fetches
--  against oe_discount_lines, a check is performed for each attribute
--  to determine whether it is used as a discounting attribute or not.
--  The function Attribute_Used performs this check.
--
--  The query performed in the Get_Adjustment procedure is restricted
--  by a greater-than clause which compares against the previously
--  queried percent and returns an adjustment only if it is higher in
--  value.  The initial value for this variable is 0.  If Get_Adjustment
--  fetches no rows, it will pass back the best adjustment record and
--  best adjustment percent in the out parameters p_adj_rec
--  and p_adj_percent.

PROCEDURE Fetch_Best_Adjustment
( p_inventory_item_id	IN  NUMBER					,
  p_price_list_id	IN  NUMBER					,
  p_list_price		IN  NUMBER					,
  p_quantity		IN  NUMBER					,
  p_pricing_attribute1	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute2	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute3	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute4	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute5	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute6	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute7	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute8	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute9	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute10	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute11	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute12	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute13	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute14	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute15	IN  VARCHAR2	:= NULL				,
  p_pricing_date	IN  DATE	:= NULL				,
  p_unit_code		IN  VARCHAR2 	:= NULL				,
  p_ship_to_id		IN  NUMBER	:= NULL				,
  p_item_category_id	IN  NUMBER	:= NULL				,
  p_sold_to_org_id		IN  NUMBER	:= NULL				,
  p_customer_class_code	IN  VARCHAR2 	:= NULL				,
  p_invoice_to_id	IN  NUMBER 	:= NULL				,
  p_po_number		IN  VARCHAR2	:= NULL				,
  p_agreement_id	IN  NUMBER	:= NULL				,
  p_agreement_type_code	IN  VARCHAR2	:= NULL				,
  p_order_type_id	IN  NUMBER	:= NULL				,
  p_gsa			IN  VARCHAR2	:= NULL				,
  p_adj_rec		OUT NOCOPY /* file.sql.39 change */ Adj_Short_Rec_Type
)
IS
    l_adj_percent	NUMBER 		:= 0;
    l_gsa		VARCHAR2(1);
    l_adj_rec		Adj_Short_Rec_Type;

BEGIN

    oe_debug_pub.add('Entering QP_PRC_UTIL.FETCH_BEST_ADJUSTMENT', 1);

    -- Price list and list price are required

    IF	p_price_list_id IS NULL	OR
	p_list_price IS NULL	OR
	p_list_price = 0
    THEN
        return;
    END IF;


    --  Get GSA flag

    IF p_gsa IS NULL THEN
        l_gsa := Get_GSA (p_sold_to_org_id, p_invoice_to_id);
    ELSE
        l_gsa := p_gsa;
    END IF;


    -- set pricing_date
    l_adj_rec.pricing_date	:= p_pricing_date;


    --  Initial fetch (no pricing entities)
        OE_DEBUG_PUB.ADD('+==========================================+');
        OE_DEBUG_PUB.ADD('|Befor calling header big select statement|');
        OE_DEBUG_PUB.ADD('+==========================================+');
        OE_DEBUG_PUB.ADD('l_adj_percent '||l_adj_percent);
        OE_DEBUG_PUB.ADD('adjustment id '||l_adj_rec.adjustment_id);
        OE_DEBUG_PUB.ADD('discount id '||l_adj_rec.discount_id);
        OE_DEBUG_PUB.ADD('discount line id '||l_adj_rec.discount_line_id);
        OE_DEBUG_PUB.ADD('automatic discount flag '||l_adj_rec.automatic_flag);
        OE_DEBUG_PUB.ADD('percent '|| l_adj_rec.percent);
        OE_DEBUG_PUB.ADD('line id '||l_adj_rec.line_id);
        OE_DEBUG_PUB.ADD('header id' || l_adj_rec.header_id);
        OE_DEBUG_PUB.ADD('discount_name '||l_adj_rec.discount_name);
        OE_DEBUG_PUB.ADD('pricing_date '||l_adj_rec.pricing_date);
        OE_DEBUG_PUB.ADD('operation '||l_adj_rec.operation);
        OE_DEBUG_PUB.ADD('line_tbl_index '||l_adj_rec.line_tbl_index);
        OE_DEBUG_PUB.ADD('p_price_list_id '||p_price_list_id);
        OE_DEBUG_PUB.ADD('p_quantity '||p_quantity);
        OE_DEBUG_PUB.ADD('p_list_price '||p_list_price);
        OE_DEBUG_PUB.ADD('p_sold_to_org_id '||p_sold_to_org_id);
        OE_DEBUG_PUB.ADD('p_customer_class_code '||p_customer_class_code);
        OE_DEBUG_PUB.ADD('p_ship_to_id	'||p_ship_to_id	);
        OE_DEBUG_PUB.ADD('p_invoice_to_id '||p_invoice_to_id);
        OE_DEBUG_PUB.ADD('p_unit_code '||p_unit_code );


        --DBMS_OUTPUT.PUT_LINE('+==========================================+');
        --DBMS_OUTPUT.PUT_LINE('|Before calling header big select statement|');
        --DBMS_OUTPUT.PUT_LINE('+==========================================+');
        --DBMS_OUTPUT.PUT_LINE('l_adj_percent '||l_adj_percent);
        --DBMS_OUTPUT.PUT_LINE('adjustment id '||l_adj_rec.adjustment_id);
        --DBMS_OUTPUT.PUT_LINE('discount id '||l_adj_rec.discount_id);
        --DBMS_OUTPUT.PUT_LINE('discount line id '||l_adj_rec.discount_line_id);
        --DBMS_OUTPUT.PUT_LINE('automatic discount flag '||l_adj_rec.automatic_flag);
        --DBMS_OUTPUT.PUT_LINE('percent '|| l_adj_rec.percent);
        --DBMS_OUTPUT.PUT_LINE('line id '||l_adj_rec.line_id);
        --DBMS_OUTPUT.PUT_LINE('header id' || l_adj_rec.header_id);
        --DBMS_OUTPUT.PUT_LINE('discount_name '||l_adj_rec.discount_name);
        --DBMS_OUTPUT.PUT_LINE('pricing_date '||l_adj_rec.pricing_date);
        --DBMS_OUTPUT.PUT_LINE('operation '||l_adj_rec.operation);
        --DBMS_OUTPUT.PUT_LINE('line_tbl_index '||l_adj_rec.line_tbl_index);
        --DBMS_OUTPUT.PUT_LINE('p_price_list_id '||p_price_list_id);
        --DBMS_OUTPUT.PUT_LINE('p_quantity '||p_quantity);
        --DBMS_OUTPUT.PUT_LINE('p_list_price '||p_list_price);
        --DBMS_OUTPUT.PUT_LINE('p_sold_to_org_id '||p_sold_to_org_id);
        --DBMS_OUTPUT.PUT_LINE('p_customer_class_code '||p_customer_class_code);
        --DBMS_OUTPUT.PUT_LINE('p_ship_to_id	'||p_ship_to_id	);
        --DBMS_OUTPUT.PUT_LINE('p_invoice_to_id '||p_invoice_to_id);
        --DBMS_OUTPUT.PUT_LINE('p_unit_code '||p_unit_code );
    --l_adj_rec.pricing_date := TO_DATE('13-OCT-99');
    Get_Adjustment
    ( p_best_adj_rec		=> l_adj_rec				,
      p_best_adj_percent	=> l_adj_percent			,
      p_attribute_id		=> NULL					,
      p_attribute_value		=> NULL					,
      p_price_list_id		=> p_price_list_id			,
      p_quantity		=> p_quantity				,
      p_list_price		=> p_list_price				,
      p_sold_to_org_id		=> p_sold_to_org_id			,
      p_customer_class_code	=> p_customer_class_code		,
      p_gsa			=> l_gsa				,
      p_ship_to_id		=> p_ship_to_id				,
      p_invoice_to_id		=> p_invoice_to_id			,
      p_unit_code		=> p_unit_code				,
      p_adj_rec			=> l_adj_rec				,
      p_adj_percent		=> l_adj_percent
    );

        --DBMS_output.put_line('In fetch best adjustment without attributes : '|| p_adj_rec.percent);

        OE_DEBUG_PUB.ADD('+==========================================+');
        OE_DEBUG_PUB.ADD('|After calling header big select statement|');
        OE_DEBUG_PUB.ADD('+==========================================+');
        OE_DEBUG_PUB.ADD('l_adj_percent '||l_adj_percent);
        OE_DEBUG_PUB.ADD('adjustment id '||l_adj_rec.adjustment_id);
        OE_DEBUG_PUB.ADD('discount id '||l_adj_rec.discount_id);
        OE_DEBUG_PUB.ADD('discount line id '||l_adj_rec.discount_line_id);
        OE_DEBUG_PUB.ADD('automatic discount flag '||l_adj_rec.automatic_flag);
        OE_DEBUG_PUB.ADD('percent '|| l_adj_rec.percent);
        OE_DEBUG_PUB.ADD('line id '||l_adj_rec.line_id);
        OE_DEBUG_PUB.ADD('header id' || l_adj_rec.header_id);
        OE_DEBUG_PUB.ADD('discount_name '||l_adj_rec.discount_name);
        OE_DEBUG_PUB.ADD('pricing_date '||l_adj_rec.pricing_date);
        OE_DEBUG_PUB.ADD('operation '||l_adj_rec.operation);
        OE_DEBUG_PUB.ADD('line_tbl_index '||l_adj_rec.line_tbl_index);

        --DBMS_OUTPUT.PUT_LINE('+==========================================+');
        --DBMS_OUTPUT.PUT_LINE('|After calling header big select statement|');
        --DBMS_OUTPUT.PUT_LINE('+==========================================+');
        --DBMS_OUTPUT.PUT_LINE('l_adj_percent '||l_adj_percent);
        --DBMS_OUTPUT.PUT_LINE('adjustment id '||l_adj_rec.adjustment_id);
        --DBMS_OUTPUT.PUT_LINE('discount id '||l_adj_rec.discount_id);
        --DBMS_OUTPUT.PUT_LINE('discount line id '||l_adj_rec.discount_line_id);
        --DBMS_OUTPUT.PUT_LINE('automatic discount flag '||l_adj_rec.automatic_flag);
        --DBMS_OUTPUT.PUT_LINE('percent '|| l_adj_rec.percent);
        --DBMS_OUTPUT.PUT_LINE('line id '||l_adj_rec.line_id);
        --DBMS_OUTPUT.PUT_LINE('header id' || l_adj_rec.header_id);
        --DBMS_OUTPUT.PUT_LINE('discount_name '||l_adj_rec.discount_name);
        --DBMS_OUTPUT.PUT_LINE('pricing_date '||l_adj_rec.pricing_date);
        --DBMS_OUTPUT.PUT_LINE('operation '||l_adj_rec.operation);
        --DBMS_OUTPUT.PUT_LINE('line_tbl_index '||l_adj_rec.line_tbl_index);


    --  Fetches for each discounting attribute

    IF p_inventory_item_id IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_ITEM) THEN
             Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_ITEM				,
              p_attribute_value	=> TO_CHAR(p_inventory_item_id)		,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );
 --DBMS_output.put_line('In fetch best adjustment in ITEM percent After: '|| p_adj_rec.percent);
OE_DEBUG_PUB.ADD('In fetch best adjustment in ITEM percent After: '|| p_adj_rec.percent);
	END IF;

    END IF;

    IF p_item_category_id IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_ITEM_CATEGORY) THEN
 --DBMS_output.put_line('In fetch best adjustment G_ATTR_ITEM_CAT: '||G_ATTR_ITEM_CATEGORY );
--DBMS_output.put_line('In fetch best adj --p_attribute_value: '||p_item_category_id);
OE_DEBUG_PUB.ADD('In fetch best adj --p_attribute_value: '||p_item_category_id);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_ITEM_CATEGORY			,
              p_attribute_value	=> TO_CHAR(p_item_category_id)		,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );
        --DBMS_output.put_line('In fetch best adjustment in ITEM_CAT After: '|| p_adj_rec.percent);

	END IF;

    END IF;

    IF p_pricing_attribute1 IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE1) THEN
     --DBMS_output.put_line('In fetch best adjustment PRC_ATTRIBUTE1: '|| p_adj_rec.percent);
 OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE1: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE1		,
              p_attribute_value	=> p_pricing_attribute1			,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_pricing_attribute2 IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE2) THEN
     --DBMS_output.put_line('In fetch best adjustment in PRC_ATTRIB2: '|| p_adj_rec.percent);
OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE2: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE2		,
              p_attribute_value	=> p_pricing_attribute2			,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_pricing_attribute3 IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE3) THEN
            --DBMS_output.put_line('In fetch best adjustment PRC_ATTR3: '|| p_adj_rec.percent);
OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE3: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE3		,
              p_attribute_value	=> p_pricing_attribute3			,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_pricing_attribute4 IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE4) THEN
     --DBMS_output.put_line('In fetch best adjustment PRC_ATTR4: '|| p_adj_rec.percent);
OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE4: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE4		,
              p_attribute_value	=> p_pricing_attribute4			,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_pricing_attribute5 IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE5) THEN
     --DBMS_output.put_line('In fetch best adjustment PRC_ATTR5: '|| p_adj_rec.percent);
OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE5: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE5		,
              p_attribute_value	=> p_pricing_attribute5			,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_pricing_attribute6 IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE6) THEN
     --DBMS_output.put_line('In fetch best adjustment PRC_ATTR6: '|| p_adj_rec.percent);
OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE6: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE6		,
              p_attribute_value	=> p_pricing_attribute6			,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_pricing_attribute7 IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE7) THEN
     --DBMS_output.put_line('In fetch best adjustment PRC_ATTR7: '|| p_adj_rec.percent);
OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE7: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE7		,
              p_attribute_value	=> p_pricing_attribute7			,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_pricing_attribute8 IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE8) THEN
     --DBMS_output.put_line('In fetch best adjustment PRC_ATTR8: '|| p_adj_rec.percent);
OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE8: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE8		,
              p_attribute_value	=> p_pricing_attribute8			,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_pricing_attribute9 IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE9) THEN
     --DBMS_output.put_line('In fetch best adjustment PRC_ATTR9: '|| p_adj_rec.percent);
OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE9: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE9		,
              p_attribute_value	=> p_pricing_attribute9			,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_pricing_attribute10 IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE10) THEN
     --DBMS_output.put_line('In fetch best adjustment PRC_ATTR10: '|| p_adj_rec.percent);
OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE10: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE10		,
              p_attribute_value	=> p_pricing_attribute10		,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_pricing_attribute11 IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE11) THEN
     --DBMS_output.put_line('In fetch best adjustment PRC_ATTR11: '|| p_adj_rec.percent);
OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE11: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE11		,
              p_attribute_value	=> p_pricing_attribute11		,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_pricing_attribute12 IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE12) THEN
     --DBMS_output.put_line('In fetch best adjustment PRC_ATTR12: '|| p_adj_rec.percent);
OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE12: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE12		,
              p_attribute_value	=> p_pricing_attribute12		,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_pricing_attribute13 IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE13) THEN
     --DBMS_OUTPUT.PUT_LINE('In fetch best adjustment PRC_ATTRIBUTE13: '|| p_adj_rec.percent);
    OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE13: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE13		,
              p_attribute_value	=> p_pricing_attribute13		,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_pricing_attribute14 IS NOT NULL THEN

      IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE13) THEN
     --DBMS_OUTPUT.PUT_LINE('In fetch best adjustment PRC_ATTRIBUTE14: '|| p_adj_rec.percent);
    OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE14: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE14		,
              p_attribute_value	=> p_pricing_attribute14		,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_pricing_attribute15 IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PRC_ATTRIBUTE15) THEN

            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PRC_ATTRIBUTE15		,
              p_attribute_value	=> p_pricing_attribute15		,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

     --DBMS_OUTPUT.PUT_LINE('In fetch best adjustment PRC_ATTRIBUTE15: '|| p_adj_rec.percent);
    OE_DEBUG_PUB.ADD('In fetch best adjustment PRC_ATTRIBUTE15: '|| p_adj_rec.percent);

	END IF;

    END IF;


    IF p_po_number IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_PO_NUMBER) THEN
     --DBMS_output.put_line('In fetch best adjustment PO_NUMBER: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_PO_NUMBER 			,
              p_attribute_value	=> p_po_number				,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_agreement_id IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_AGREEMENT) THEN
     --DBMS_output.put_line('In fetch best adjustment ATTR_AGREEMENT: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_AGREEMENT			,
              p_attribute_value	=> TO_CHAR(p_agreement_id)		,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_agreement_type_code IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_AGREEMENT_TYPE) THEN
     --DBMS_output.put_line('In fetch best adjustment IN AGREEMENT_TYPE: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_AGREEMENT_TYPE		,
              p_attribute_value	=> p_agreement_type_code		,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    IF p_order_type_id IS NOT NULL THEN

        IF Attribute_Used(G_ATTR_ORDER_TYPE_ID) THEN
     --DBMS_output.put_line('In fetch best adjustment in Order_Type_ID: '|| p_adj_rec.percent);
            Get_Adjustment
            ( p_best_adj_rec	=> l_adj_rec				,
      	      p_best_adj_percent=> l_adj_percent			,
              p_attribute_id	=> G_ATTR_ORDER_TYPE_ID			,
              p_attribute_value	=> TO_CHAR(p_order_type_id)		,
              p_price_list_id	=> p_price_list_id			,
              p_quantity	=> p_quantity				,
              p_list_price	=> p_list_price				,
              p_sold_to_org_id	=> p_sold_to_org_id			,
              p_customer_class_code => p_customer_class_code		,
              p_gsa		=> l_gsa				,
              p_ship_to_id	=> p_ship_to_id				,
              p_invoice_to_id	=> p_invoice_to_id			,
              p_unit_code	=> p_unit_code				,
              p_adj_rec		=> l_adj_rec				,
              p_adj_percent	=> l_adj_percent
             );

	END IF;

    END IF;


    -- Return values collected in l_adj_rec to p_adj_rec out variable

    p_adj_rec := l_adj_rec;
    --DBMS_output.put_line('In Fetch Best Adjustment percent :'||p_adj_rec.percent);
    oe_debug_pub.add('Exiting QP_PRC_UTIL.FETCH_BEST_ADJUSTMENT', 1);

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	RAISE;

    WHEN OTHERS THEN

        -- Unexpected error
	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

	    OE_MSG_PUB.Add_Exc_Msg
	    (   G_PKG_NAME  	    ,
                'Price_Item - Fetch_Best_Adjustment'
	    );
	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END; -- Fetch_Best_Adjustment



-- Procedure Calculate_Selling_Price
-- Usage:
--   Calculate_Selling_Price is called from the Price_Item procedure
--   after Price_Item has fetched the best available automatic
--   adjustment and calculated the total adjustment total.
--   Calculate_Selling_Price is also called from the Price_Line
--   procedure as a full call to Price_Item from the Price_Line API
--   is unnecessary in certain situations.
-- Description:
--   Calculates the selling price or selling percent for an
--   item, applying all adjustments.
--   Two pricing methods are supported: amount and percent.
-- Parameters:
--   IN:
--     p_adj_total		NUMBER          required
-- 		Total adjustment percent to apply 0-100
--     p_list_price		NUMBER		required
--		Used when price_method_code = AMNT (amount),
--               otherwise pass NULL
--     p_list_percent		NUMBER		required
--		Used when price_method_code = PERC (percent),
--		 otherwise pass NULL
--     p_price_list_id		NUMBER 		required
--		If p_price_list_id is NULL, Calculate_Selling_Price
--              returns with all OUT parameters set to NULL
--     p_base_price		NUMBER		required
--		Used when price_method_code = PERC.  Comes from
--		the parent service line list_price in oe_order_lines
--     p_service_duration		NUMBER	required
--		Used when price_method_code = PERC,
--		otherwise pass NULL
--     p_price_method_code	VARCHAR2(4)	required
--		price_item procedure supports two types of pricing:
--			G_PRC_METHOD_AMOUNT - an amount
--			G_PRC_METHOD_PERCENT - a percent
--		Value for price_method_code comes from oe_order_lines or
--		from fetch_list_price.  If price_method_code is
-- 		missing, price_item returns with all out
--		parameters set to NULL
--
--   OUT:
--     p_selling_price		NUMBER
--		Final rounded selling price
--     p_selling_percent	NUMBER
--  		When price_method_code = PERC, this parameter
--		holds the selling percent
--     p_list_price_out		NUMBER
--		When price_method_code = PERC, this parameter
--		holds the list price
--
-- Notes:

PROCEDURE   Calculate_Selling_Price
(  p_adj_total		   IN  NUMBER	 			,
   p_list_price	    	   IN  NUMBER	 			,
   p_list_percent	   IN  NUMBER	 			,
   p_price_list_id	   IN  NUMBER	 			,
   p_base_price	    	   IN  NUMBER	 			,
   p_service_duration	   IN  NUMBER	 			,
   p_pricing_method_code   IN  VARCHAR2	 			,
   p_selling_price	   OUT NOCOPY /* file.sql.39 change */ NUMBER				,
   p_selling_percent	   OUT NOCOPY /* file.sql.39 change */ NUMBER				,
   p_list_price_out	   OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
    l_selling_percent   NUMBER := NULL;
    l_adj_total	    	NUMBER;
    l_rounding_factor 	NUMBER;

BEGIN

    oe_debug_pub.add('Entering QP_PRC_UTIL.CALCULATE_SELLING_PRICE', 1);

    --  p_price_list_id and p_pricing_method_code are required.  If
    --  either is null, set all out parameters to NULL and return.
    --DBMS_output.put_line('In cal selling price--price_list_id: '||p_price_list_id);
    --DBMS_output.put_line('===========================================');
    --DBMS_output.put_line('pricing_method_code: '||p_pricing_method_code);

IF p_price_list_id IS NULL
    OR  p_pricing_method_code IS NULL
    THEN
	p_selling_price := NULL;
	p_selling_percent := NULL;
	p_list_price_out := NULL;
	RETURN;
    END IF;


    --	Fetch rounding factor from price list.
    --QP
/*
    SELECT ROUNDING_FACTOR
    INTO   l_rounding_factor
    FROM   oe_price_lists
    WHERE  price_list_id = p_price_list_id;
*/


    SELECT ROUNDING_FACTOR
    INTO l_rounding_factor
    FROM QP_LIST_HEADERS
    WHERE LIST_HEADER_ID = p_price_list_id;
    --END QP
    --  Initialize local variable holding adjustment total

    IF p_adj_total IS NULL THEN
	l_adj_total := 0 ;
    ELSE
	l_adj_total := p_adj_total ;
    END IF;


    IF p_pricing_method_code = G_PRC_METHOD_AMOUNT THEN

	--  selling_price = list_price * (100-l_adj_total)/100
        --DBMS_output.put_line('p_list_price in cal sell prc: '||p_list_price);
	p_selling_price := ROUND ( p_list_price	   *
				 ( 100 - l_adj_total )  / 100
				 , - l_rounding_factor
			   );

	p_selling_percent := NULL;
	p_list_price_out := p_list_price;

    --DBMS_output.put_line('Sell price '||p_selling_price);

    ELSIF p_pricing_method_code = G_PRC_METHOD_PERCENT THEN

	--  Init OUT parameters.

	p_selling_price	    := NULL;
	p_list_price_out    := NULL ;
	p_selling_percent   := NULL ;

        --DBMS_output.put_line('in cal sell--p_list_percent: '||p_list_percent);

        --  If pricing method is percent, p_list_percent must be valid

	IF  p_list_percent IS NULL
	THEN
	    RETURN;
	END IF;
        --DBMS_output.put_line('in cal sell--p_list_percent '||p_list_percent);

	--  Calculate selling percent
	--  selling_percent = list_percent * (100 - l_adj_total )/ 100

	l_selling_percent := p_list_percent * (100 - l_adj_total)/100;
	p_selling_percent := l_selling_percent;


        --  p_base_price and p_service_duration are required to
        --  calculate p_list_price and p_selling price when the
        --  pricing method is percent

	IF  p_base_price IS NULL OR
	    p_service_duration IS NULL
	THEN
	    RETURN;
	END IF;


	--  calculate list_price
	--  list_price := base_price*service_duration*list_percent/100

	p_list_price_out :=  ROUND (p_base_price	*
				    p_service_duration  *
				    p_list_percent	/ 100
				  , - l_rounding_factor
			     );

	--  calculate selling_price
	--  selling_price := base_price*service_duration*selling_percent/100

	p_selling_price :=  ROUND ( p_base_price	*
				    p_service_duration  *
				    l_selling_percent	/ 100
				  , - l_rounding_factor
			    );

    ELSE

        --  Unexpected error, invalid pricing method

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

	    OE_MSG_PUB.Add_Exc_Msg
		(   G_PKG_NAME  	    ,
		    'Price_Item, Calculate_Selling_Price - invalid pricing method ='||p_pricing_method_code
		);
	END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    oe_debug_pub.add('Exiting QP_PRC_UTIL.CALCULATE_SELLING_PRICE', 1);

EXCEPTION

    WHEN OTHERS THEN

        -- Unexpected error
	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

	    OE_MSG_PUB.Add_Exc_Msg
	    (   G_PKG_NAME  	    ,
                'Price_Item - Calculate_Selling_Price'
	    );
	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Calculate_Selling_Price;



-- Procedure Price_Item
-- Usage:
--   Price_Item is called from the Price_Line API.
-- Description:
--   Fetches the best automatic adjustment for an item, sums
--   up all the adjustments (manual and automatic, header and
--   line) applied to the item, an finally calculates the
--   selling price based on the pricing method.
-- Parameters:
--   IN:
--     p_item_rec		Prc_Item_Rec_Type	required
--  		p_item_rec holds the item/price_list information.
--		It also holds the discounting attributes affecting
--		the fetch of the best discount.
--     p_existing_adj_total  	NUMBER			optional
--		This parameter holds the total of all manual
--		line and header level adjustments.  It will be
--		used when validating that by applying the new
--		adjustment, the total is not going to exceed 100,
--		and it will be added to the new adjustment (if any)
--		to compute the final adjustment total that will
--		be used to calculate the selling price
--   OUT:
--     p_return_status   	VARCHAR2(1)
--     p_selling_price		NUMBER
--		Final rounded selling price
--     p_selling_percent	NUMBER
--  		When price_method_code = PERC, this parameter
--		holds the selling percent
--     p_adj_out_tbl		Adj_Short_Tbl_Type
--		PL/SQL table that holds the new fetched automatic
--		adjustment if found.  Currently the Price_Item
--              procedure fetches only one automatic adjustment.
--              We use the Adj_Short_Tbl_Type table as an OUT
--              parameter to allow for future enhancements that
--              may result in the procedure returning more than
--              one adjustment.
-- Notes:

PROCEDURE Price_Item
( p_return_status   	OUT NOCOPY /* file.sql.39 change */ VARCHAR2					,
  p_item_rec		IN  Prc_Item_Rec_Type				,
  p_existing_adj_total	IN  NUMBER	:= 0				,
  p_selling_price	OUT NOCOPY /* file.sql.39 change */ NUMBER					,
  p_selling_percent	OUT NOCOPY /* file.sql.39 change */ NUMBER					,
  p_list_price_out	OUT NOCOPY /* file.sql.39 change */ NUMBER					,
  p_adj_out_table	OUT NOCOPY /* file.sql.39 change */ Adj_Short_Tbl_Type
)
IS
    l_return_status	    VARCHAR2(1);
    l_validation_error	    BOOLEAN 	:= FALSE;
    l_adj_total		    NUMBER	:= 0;
    l_adj_rec		    Adj_Short_Rec_Type;
    l_dummy                 NUMBER;
    l_msg_count             NUMBER;
    l_rounding_factor       NUMBER;
    l_msg_data              VARCHAR2(30);
    l_item_rec              Prc_Item_Rec_Type;
BEGIN

--DBMS_output.put_line('I am in Price Item');

    oe_debug_pub.add('Entering QP_PRC_UTIL.PRICE_ITEM', 1);

    --  Initialize p_return_status

	p_return_status := FND_API.G_RET_STS_SUCCESS;


    --  Initialize OUT parameters

    p_selling_price 	:= NULL;
    p_selling_percent 	:= NULL;


    --	Check required parameters are not null
    --  IF NULL try to get them

    l_item_rec := p_item_rec;

    IF l_item_rec.price_list_id IS NULL
    OR l_item_rec.list_price IS NULL
    OR l_item_rec.price_method_code IS NULL
    THEN
         QP_Price_List_PVT.Fetch_List_Price
	( p_api_version_number    =>	1.0			    	,
	  p_return_status	  =>	l_return_status		    	,
	  p_msg_count		  =>  	l_msg_count			,
	  p_msg_data		  => 	l_msg_data			,
	  p_price_list_id	  =>    l_item_rec.price_list_id    	,
	  p_inventory_item_id	  =>	l_item_rec.inventory_item_id 	,
	  p_unit_code		  =>	l_item_rec.unit_code		,
	  p_service_duration	  =>	l_item_rec.service_duration	,
	  p_item_type_code	  =>	l_item_rec.item_type_code	,
	  p_prc_method_code	  =>	l_item_rec.price_method_code	,
	  p_pricing_attribute1	  =>	l_item_rec.pricing_attribute1	,
	  p_pricing_attribute2	  =>	l_item_rec.pricing_attribute2	,
	  p_pricing_attribute3	  =>	l_item_rec.pricing_attribute3	,
	  p_pricing_attribute4	  =>	l_item_rec.pricing_attribute4	,
	  p_pricing_attribute5	  =>	l_item_rec.pricing_attribute5	,
	  p_pricing_attribute6	  =>	l_item_rec.pricing_attribute6	,
	  p_pricing_attribute7	  =>	l_item_rec.pricing_attribute7	,
	  p_pricing_attribute8	  =>	l_item_rec.pricing_attribute8	,
	  p_pricing_attribute9	  =>	l_item_rec.pricing_attribute9	,
	  p_pricing_attribute10	  =>	l_item_rec.pricing_attribute10	,
	  p_pricing_attribute11	  =>	l_item_rec.pricing_attribute11	,
	  p_pricing_attribute12	  =>	l_item_rec.pricing_attribute12	,
	  p_pricing_attribute13	  =>	l_item_rec.pricing_attribute13	,
	  p_pricing_attribute14	  =>	l_item_rec.pricing_attribute14	,
	  p_pricing_attribute15	  =>	l_item_rec.pricing_attribute15	,
	  p_base_price		  =>	l_item_rec.base_price		,
	  p_pricing_date	  =>	l_item_rec.pricing_date		,
	  p_price_list_id_out	  =>	l_item_rec.price_list_id	,
	  p_prc_method_code_out	  =>	l_item_rec.price_method_code,
	  p_list_price		  =>	l_item_rec.list_price	,
	  p_list_percent	  =>	l_item_rec.list_percent	,
	  p_rounding_factor	  =>	l_rounding_factor
	);

    END IF;


 --If these values are still NULL after the above call, exit
    IF l_item_rec.price_list_id IS NULL
       OR l_item_rec.list_price IS NULL
       OR l_item_rec.price_method_code IS NULL THEN
         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 return;
    END IF;



    --	Validate Input

    --  Validate input :
    --      l_item_rec.price_method_code
    --      p_existing_adj_total

    -- price method code must be valid
    IF  NOT Equal ( l_item_rec.price_method_code , G_PRC_METHOD_AMOUNT ) AND
	NOT Equal ( l_item_rec.price_method_code , G_PRC_METHOD_PERCENT )
    THEN

	l_validation_error := TRUE;

	FND_MESSAGE.SET_NAME('QP','OE_PRC_INVALID_PRC_METHOD');
	FND_MESSAGE.SET_TOKEN('METHOD',l_item_rec.price_method_code);
	OE_MSG_PUB.Add;

    END IF;

    --	If any validation errors occur then return error.

    IF l_validation_error THEN
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Set l_adj_total.

    IF p_existing_adj_total IS NULL THEN
        l_adj_total := 0;
    ELSE
        l_adj_total := p_existing_adj_total;
    END IF;

	-- Debug info
/*
	OE_MSG_PUB.Add_Exc_Msg
	(   p_error_text => 'Before calling fetch_best_adj - '||
	    ' item = '||l_item_rec.inventory_item_id||
	    ' price_list = '||l_item_rec.price_list_id||
	    ' list_rice = '||l_item_rec.list_price||
	    ' quantity = '||l_item_rec.quantity
	);
*/

    -- Fetch highest automatic discount

OE_DEBUG_PUB.ADD('+============================+');
OE_DEBUG_PUB.ADD('|Before fetch best adjustment|');
OE_DEBUG_PUB.ADD('+============================+');
OE_DEBUG_PUB.ADD('l_item_rec.inventory_item_id '||l_item_rec.inventory_item_id);
OE_DEBUG_PUB.ADD('l_item_rec.price_list_id '||l_item_rec.price_list_id);
OE_DEBUG_PUB.ADD('l_item_rec.list_price '||l_item_rec.list_price);
OE_DEBUG_PUB.ADD('l_item_rec.quantity '||l_item_rec.quantity);
OE_DEBUG_PUB.ADD('l_item_rec.pricing_date '||l_item_rec.pricing_date);
OE_DEBUG_PUB.ADD('l_item_rec.unit_code '||l_item_rec.unit_code);
OE_DEBUG_PUB.ADD('l_item_rec.ship_to_site_use_id '||l_item_rec.ship_to_site_use_id);
OE_DEBUG_PUB.ADD('l_item_rec.item_category_id '||l_item_rec.item_category_id);
OE_DEBUG_PUB.ADD('l_item_rec.sold_to_org_id '||l_item_rec.sold_to_org_id);
OE_DEBUG_PUB.ADD('l_item_rec.customer_class_code '||l_item_rec.customer_class_code);
OE_DEBUG_PUB.ADD('l_item_rec.invoice_to_org_id '||l_item_rec.invoice_to_org_id);
OE_DEBUG_PUB.ADD('l_item_rec.po_number '||l_item_rec.po_number);
OE_DEBUG_PUB.ADD('l_item_rec.agreement_id '||l_item_rec.agreement_id);
OE_DEBUG_PUB.ADD('p_order_type_id '||l_item_rec.order_type_id);
OE_DEBUG_PUB.ADD('p_gsa '||l_item_rec.gsa);
OE_DEBUG_PUB.ADD('l_item_rec.pricing_attribute1'||l_item_rec.pricing_attribute1);

--DBMS_OUTPUT.PUT_LINE('+============================+');
--DBMS_OUTPUT.PUT_LINE('|Before fetch best adjustment|');
--DBMS_OUTPUT.PUT_LINE('+============================+');
--DBMS_OUTPUT.PUT_LINE('l_item_rec.inventory_item_id '||l_item_rec.inventory_item_id);
--DBMS_OUTPUT.PUT_LINE('l_item_rec.price_list_id '||l_item_rec.price_list_id);
--DBMS_OUTPUT.PUT_LINE('l_item_rec.list_price '||l_item_rec.list_price);
--DBMS_OUTPUT.PUT_LINE('l_item_rec.quantity '||l_item_rec.quantity);
--DBMS_OUTPUT.PUT_LINE('l_item_rec.pricing_date '||l_item_rec.pricing_date);
--DBMS_OUTPUT.PUT_LINE('l_item_rec.unit_code '||l_item_rec.unit_code);
--DBMS_OUTPUT.PUT_LINE('l_item_rec.ship_to_site_use_id '||l_item_rec.ship_to_site_use_id);
--DBMS_OUTPUT.PUT_LINE('l_item_rec.item_category_id '||l_item_rec.item_category_id);
--DBMS_OUTPUT.PUT_LINE('l_item_rec.sold_to_org_id '||l_item_rec.sold_to_org_id);
----DBMS_OUTPUT.PUT_LINE('l_item_rec.customer_class_code '||l_item_rec.customer_class_code);
----DBMS_OUTPUT.PUT_LINE('l_item_rec.invoice_to_org_id '||l_item_rec.invoice_to_org_id);
----DBMS_OUTPUT.PUT_LINE('l_item_rec.po_number '||l_item_rec.po_number);
----DBMS_OUTPUT.PUT_LINE('l_item_rec.agreement_id '||l_item_rec.agreement_id);
----DBMS_OUTPUT.PUT_LINE('p_order_type_id '||l_item_rec.order_type_id);
----DBMS_OUTPUT.PUT_LINE('p_gsa '||l_item_rec.gsa);

 ----DBMS_output
 --QP Debug, see the effect if set p_customer_class_code to other
 --l_item_rec.customer_class_code := 'Other';

    Fetch_Best_Adjustment
    ( p_inventory_item_id 	=>	l_item_rec.inventory_item_id	,
      p_price_list_id		=>	l_item_rec.price_list_id	,
      p_list_price		=>   	l_item_rec.list_price		,
      p_quantity		=>	l_item_rec.quantity		,
      p_pricing_attribute1	=>	l_item_rec.pricing_attribute1	,
      p_pricing_attribute2	=>	l_item_rec.pricing_attribute2	,
      p_pricing_attribute3	=>	l_item_rec.pricing_attribute3	,
      p_pricing_attribute4	=>	l_item_rec.pricing_attribute4	,
      p_pricing_attribute5	=>	l_item_rec.pricing_attribute5	,
      p_pricing_attribute6	=>	l_item_rec.pricing_attribute6	,
      p_pricing_attribute7	=>	l_item_rec.pricing_attribute7	,
      p_pricing_attribute8	=>	l_item_rec.pricing_attribute8	,
      p_pricing_attribute9	=>	l_item_rec.pricing_attribute9	,
      p_pricing_attribute10	=>	l_item_rec.pricing_attribute10	,
      p_pricing_attribute11	=>	l_item_rec.pricing_attribute11	,
      p_pricing_attribute12	=>	l_item_rec.pricing_attribute12	,
      p_pricing_attribute13	=>	l_item_rec.pricing_attribute13	,
      p_pricing_attribute14	=>	l_item_rec.pricing_attribute14	,
      p_pricing_attribute15	=>	l_item_rec.pricing_attribute15	,
      p_pricing_date		=>	l_item_rec.pricing_date		,
      p_unit_code		=>	l_item_rec.unit_code		,
      p_ship_to_id		=>	l_item_rec.ship_to_site_use_id	,
      p_item_category_id	=>	l_item_rec.item_category_id	,
      p_sold_to_org_id		=>	l_item_rec.sold_to_org_id       ,
      p_customer_class_code	=>	l_item_rec.customer_class_code  ,
      p_invoice_to_id		=>	l_item_rec.invoice_to_org_id,
      p_po_number		=>	l_item_rec.po_number		,
      p_agreement_id		=>	l_item_rec.agreement_id		,
      p_agreement_type_code 	=>	l_item_rec.agreement_type_code	,
      p_order_type_id		=>	l_item_rec.order_type_id        ,
      p_gsa			=>	l_item_rec.gsa			,
      p_adj_rec			=>  	l_adj_rec
    );
--DBMS_output.put_line('After fetch best adjustment '||l_item_rec.list_price);
	-- Debug info
/*
	OE_MSG_PUB.Add_Exc_Msg
	(   p_error_text => 'After calling fetch_best_adj - '||
	    ' adj_id = '||l_adj_rec.adjustment_id||
	    ' percent = '||l_adj_rec.percent
	);
*/
    -- Add automatic adjustment retrieved by Fetch_Best_Adjustment

    IF l_adj_rec.percent IS NOT NULL THEN

        l_adj_total := l_adj_total + l_adj_rec.percent;

        -- Validate the adjustment total

        IF l_adj_total > 100 THEN

            -- Not an error condition, we just can't add the new adjustment.
            -- Decrement the total with the amount we just added, and add
            -- a message describing the failed attempt to add the adjustment.

            l_adj_total := l_adj_total - l_adj_rec.percent;


       FND_MESSAGE.SET_NAME('QP','OE_PRC_AUTOADJUSTMENT_OVERFLOW');
       FND_MESSAGE.SET_TOKEN('DISCOUNT', l_adj_rec.discount_name );
       OE_MSG_PUB.Add;


	ELSE

            -- Add the new adjustment, if any, to the p_adj_out_table

            -- Ensure operation is set to create
            l_adj_rec.operation := G_PRC_OPR_CREATE;

            -- Add adjustment to p_adj_out_table
            p_adj_out_table(1) := l_adj_rec;

	    --	Add a message to the message list to inform the user
	    --	that an adjustment has been applied to this line.

	    --	this code should be moved to the part when we process
	    --	adjustments, but since we don't do actual inserts the
	    --	code will temporarily reside here.

			if l_item_rec.agreement_id is null then
            	FND_MESSAGE.SET_NAME('QP','OE_PRC_AUTOADJUSTMENT_APPLIED');
	    		FND_MESSAGE.SET_TOKEN('DISCOUNT', l_adj_rec.discount_name );
	    		OE_MSG_PUB.Add;
			end if;


        END IF;

    END IF;


    -- Calculate Selling Price

    Calculate_Selling_Price
    ( p_adj_total		=>	l_adj_total			,
      p_list_price		=>	l_item_rec.list_price		,
      p_list_percent	 	=>	l_item_rec.list_percent		,
      p_price_list_id	  	=>	l_item_rec.price_list_id	,
      p_base_price	  	=>	l_item_rec.base_price		,
      p_service_duration	=>	l_item_rec.service_duration	,
      p_pricing_method_code  	=>	l_item_rec.price_method_code	,
      p_selling_price	  	=>	p_selling_price			,
      p_selling_percent	  	=>	p_selling_percent		,
      p_list_price_out	  	=>	p_list_price_out
    );

    oe_debug_pub.add('Exiting QP_PRC_UTIL.PRICE_ITEM', 1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

    	p_return_status := FND_API.G_RET_STS_ERROR;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


    WHEN OTHERS THEN

    	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Price_Item'
	    );
    	END IF;

END; -- Price_Item

--QP Initialization
BEGIN
QP_UTIL.GET_CONTEXT_ATTRIBUTE('SOLD_TO_ORG_ID'
                             ,G_SOLD_TO_ORG_CONTEXT
                             ,G_SOLD_TO_ORG_NAME);

QP_UTIL.GET_CONTEXT_ATTRIBUTE('SITE_ORG_ID'
                             ,G_SITE_ORG_CONTEXT
                             ,G_SITE_ORG_NAME);

QP_UTIL.GET_CONTEXT_ATTRIBUTE('UNITS'
                             ,G_UNIT_CONTEXT
                             ,G_UNIT_NAME);

QP_UTIL.GET_CONTEXT_ATTRIBUTE('CUSTOMER_CLASS_CODE'
                             ,G_CUSTOMER_CLASS_CONTEXT
                             ,G_CUSTOMER_CLASS_NAME);

QP_UTIL.GET_CONTEXT_ATTRIBUTE('1001'
                             ,G_ITEM_CONTEXT
                             ,G_ITEM_NAME);

QP_UTIL.GET_CONTEXT_ATTRIBUTE('1045'
                             ,G_ITEM_CATEGORY_CONTEXT
                             ,G_ITEM_CATEGORY_NAME);

QP_UTIL.GET_CONTEXT_ATTRIBUTE('1004'
                             ,G_CUSTOMER_PO_CONTEXT
                             ,G_CUSTOMER_PO_NAME);

QP_UTIL.GET_CONTEXT_ATTRIBUTE('1005'
                             ,G_AGREEMENT_TYPE_CONTEXT
                             ,G_AGREEMENT_TYPE_NAME);

QP_UTIL.GET_CONTEXT_ATTRIBUTE('1006'
                             ,G_AGREEMENT_CONTEXT
                             ,G_AGREEMENT_NAME);

QP_UTIL.GET_CONTEXT_ATTRIBUTE('1007'
                             ,G_ORDER_TYPE_CONTEXT
                             ,G_ORDER_TYPE_NAME);

QP_UTIL.GET_CONTEXT_ATTRIBUTE('DOLLARS'
                             ,G_DOLLARS_CONTEXT
                             ,G_DOLLARS_NAME);

QP_UTIL.GET_CONTEXT_ATTRIBUTE('PRICE_LIST_ID'
                             ,G_PRICE_LIST_CONTEXT
                             ,G_PRICE_LIST_NAME);


-- END QP
END QP_PRC_UTIL;


/
