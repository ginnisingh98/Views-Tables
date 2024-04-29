--------------------------------------------------------
--  DDL for Package Body ONT_IMPLICITCUSTACCEPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_IMPLICITCUSTACCEPT_PVT" AS
/* $Header: OEXVAIPB.pls 120.12.12010000.2 2009/06/24 11:16:20 aambasth ship $ */
--=============================================================================
-- CONSTANTS
--=============================================================================
--remove, check how to get the values for debug level from atg site
--G_DEBUG_LEVEL VARCHAR2(1)  :=   FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_DEBUG       VARCHAR2(1)  := 'N';
G_THRESHOLD NUMBER := 50;
--=============================================================================
-- PUBLIC VARIABLES
--=============================================================================
g_action_request_tbl                OE_ORDER_PUB.Request_Tbl_Type;
g_cust_query                        VARCHAR2(15000) := 'SELECT  line_id  '||
                                                              ', header_id '||
							      ', item_type_code '||
							      ', flow_status_code '||
							      ', actual_shipment_date '||
							      ', service_reference_type_code '||
							      ', service_reference_line_id '||
							      ', top_model_line_id '||
							      ', contingency_id '||
							      ', accepted_quantity '||
							      ', sold_to_org_id '||
							      ', revrec_expiration_days';

g_query_from_clause                 VARCHAR2(1000) :=  ' FROM oe_order_lines_all ';
g_query_where_clause                VARCHAR2(3000) :=  ' WHERE flow_status_code = ''PRE-BILLING_ACCEPTANCE''';
g_customer_acceptance_enabled       BOOLEAN;
g_fulfillment_action                VARCHAR2(40);
g_return_status		            VARCHAR2(1);
g_msg_count		            NUMBER;
g_msg_data		            VARCHAR2(2000);
g_errbuf                            VARCHAR2(2500);
g_retcode                           VARCHAR2(5);
g_org_id			    NUMBER;
g_acceptance_date                   VARCHAR2(1); -- bug 8293484
--=============================================================================
-- PROCEDURES AND FUNCTIONS
--=============================================================================
--=============================================================================
-- PROCEDURE : implicit_acceptance
-- PARAMETERS: p_org_id                operating unit parameter
--
-- COMMENT   : Process order lines for implicit acceptance as well as
--             accepting all the lines in pre-billing and post-billing status
--             when the system parameter is turned off.
--=============================================================================
PROCEDURE implicit_acceptance
( errbuf          OUT NOCOPY VARCHAR2
, retcode         OUT NOCOPY NUMBER
, p_org_id        IN  NUMBER
, p_acceptance_date IN VARCHAR2 --bug 8293484
)
IS
-- Section for declaring local variables
--
l_procedure_name        CONSTANT VARCHAR2(30) := ' implicit_acceptance ';
l_cust_sys_param        VARCHAR(1);
l_debug_level		CONSTANT NUMBER := oe_debug_pub.g_debug_level;

CURSOR l_secured_ou_cur IS
    SELECT ou.organization_id
    FROM hr_operating_units ou
    WHERE mo_global.check_access(ou.organization_id) = 'Y';

BEGIN

IF l_debug_level > 0 THEN
    oe_debug_pub.add('Implicit_acceptance'||g_org_id);
END IF;


g_org_id := p_org_id;

g_acceptance_date := NVL(p_acceptance_date,'S'); --bug 8293484

  -----------------------------------------------------------------------------
  -- Standard Start of API savepoint
  -----------------------------------------------------------------------------

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME || l_procedure_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

-- Get the value of system parameter,To verify whether customer acceptance is enabled.
-- MOAC Start
  IF g_org_id IS NOT NULL THEN
  IF l_debug_level  > 0 THEN
  oe_debug_pub.add('Implicit Acceptance: g_org_id:'||g_org_id);
  END IF;

     MO_GLOBAL.set_policy_context('S', g_org_id);
     l_cust_sys_param := OE_SYS_PARAMETERS.VALUE('ENABLE_FULFILLMENT_ACCEPTANCE',g_org_id);

/* myerrams, Bug: 5161878. Null value should be treated as No.*/
    IF l_cust_sys_param = 'Y' THEN
    IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Implicit Acceptance: Customer Acceptance System Parameter is True');
    END IF;
      g_customer_acceptance_enabled := true;
    ELSE
    IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Implicit Acceptance: Customer Acceptance System Parameter is False');
    END IF;
      g_customer_acceptance_enabled := false;
    END IF;
/*myerrams, Bug: 5161878. End.*/

  IF g_customer_acceptance_enabled THEN
      IF l_debug_level > 0 THEN
          oe_debug_pub.add('g_customer_acceptance_enabled is TRUE calling process_expired_lines');
      END IF;
      process_expired_lines;
  ELSE
        IF l_debug_level > 0 THEN
            oe_debug_pub.add('AAMBASTH: g_customer_acceptance_enabled is FALSE calling process_all_lines');
      END IF;
      process_all_lines;
  END IF;

  ELSE
     MO_GLOBAL.set_policy_context('M', '');

  OPEN l_secured_ou_cur;
  loop
     FETCH l_secured_ou_cur
     into g_org_id;
     EXIT WHEN l_secured_ou_cur%NOTFOUND;

     MO_GLOBAL.set_policy_context('S', g_org_id);
     l_cust_sys_param := OE_SYS_PARAMETERS.VALUE('ENABLE_FULFILLMENT_ACCEPTANCE',g_org_id);

/* myerrams, Bug: 5161878. Null value should be treated as No.*/
    IF l_cust_sys_param = 'Y' THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Implicit Acceptance: Customer Acceptance System Parameter is True for Org:'||g_org_id );
    END IF;
      g_customer_acceptance_enabled := true;
    ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Implicit Acceptance: Customer Acceptance System Parameter is False for Org:'||g_org_id);
    END IF;
      g_customer_acceptance_enabled := false;
    END IF;
/* myerrams, Bug: 5161878. End.*/

  IF g_customer_acceptance_enabled THEN
      process_expired_lines;
  ELSE
      process_all_lines;
  END IF;

 END LOOP;
CLOSE l_secured_ou_cur;

END IF;
-- MOAC End

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME || l_procedure_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_procedure_name );
    FND_MSG_PUB.Add;
    errbuf := g_errbuf;
    retcode := g_retcode;
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME || l_procedure_name || 'Inside the WHEN OTHERS EXCEPTION'
                    ,substr(SQLERRM(sqlcode), 1, 2000)
                    );
    END IF;
    errbuf := g_errbuf;
    retcode := g_retcode;

END implicit_acceptance;

--=============================================================================
-- PROCEDURE : process_all_lines
-- PARAMETERS: None
--
-- COMMENT   : TODO
--=============================================================================
PROCEDURE process_all_lines
IS
l_line_id                         NUMBER;
l_header_id                       NUMBER;
l_item_type_code                  VARCHAR(30);
l_flow_status_code                VARCHAR(30);
l_actual_shipment_date            DATE;
l_service_reference_type_code     VARCHAR(30);
l_service_reference_line_id       NUMBER;
l_top_model_line_id               NUMBER;
l_contingency_id                  NUMBER;
l_accepted_quantity               NUMBER;
l_sold_to_org_id		  NUMBER;	--myerrams
l_revrec_expiration_days	  NUMBER;	--myerrams
l_table_loop_index                NUMBER := 1;
l_query_where_clause              VARCHAR2(3000);			--myerrams, Bug:5161878
l_cust_query			  VARCHAR2(15000);			--myerrams, Bug:5161878
l_action_request_tbl              OE_ORDER_PUB.Request_Tbl_Type;	--myerrams, Bug:5161878
l_expiry_date DATE := SYSDATE; -- bug 8293484
l_fulfillment_date DATE; -- bug 8293484

-- ======================
-- Dynamic Cursor Variable
-- =======================
TYPE g_cust_lines_type              IS REF CURSOR;
g_cust_lines                        g_cust_lines_type;
l_debug_level			    CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

/*myerrams, Bug:5161878. This method is executed more than once.
value of g_query_where_clause is getting modified for each run in that case. It should be same.
  g_query_where_clause := g_query_where_clause || ' OR FLOW_STATUS_CODE = ''POST-BILLING_ACCEPTANCE''';
  g_cust_query := g_cust_query || g_query_from_clause || g_query_where_clause;
myerrams, Bug:5161878. end*/
--myerrams, Bug: 5235959. Added the org_id condition.
--myerrams, Bug: 5297684  l_query_where_clause := ' WHERE flow_status_code in (''PRE-BILLING_ACCEPTANCE'' , ''POST-BILLING_ACCEPTANCE'') AND org_id =' || g_org_id ||' ';
  l_query_where_clause := ' WHERE flow_status_code in (:1 , :2) AND org_id = :3  and open_flag = :4 ';
  l_cust_query := g_cust_query || g_query_from_clause || l_query_where_clause;

IF l_debug_level  > 0 THEN
  oe_debug_pub.add('Implicit Acceptance: l_query_where_clause:'||l_query_where_clause);
  oe_debug_pub.add('Implicit Acceptance: l_cust_query:'||l_cust_query);
END IF;

  OPEN g_cust_lines FOR l_cust_query
  USING 'PRE-BILLING_ACCEPTANCE','POST-BILLING_ACCEPTANCE',g_org_id,'Y';  --myerrams, Bug: 5297684
  LOOP
    FETCH g_cust_lines
    INTO  l_line_id,
	  l_header_id,
	  l_item_type_code,
	  l_flow_status_code,
	  l_actual_shipment_date,
	  l_service_reference_type_code,
	  l_service_reference_line_id,
	  l_top_model_line_id,
	  l_contingency_id,
	  l_accepted_quantity,
	  l_sold_to_org_id,
	  l_revrec_expiration_days;
    EXIT WHEN g_cust_lines%NOTFOUND;


    -- bug 8293484
    IF g_acceptance_date = 'E' THEN

        IF l_actual_shipment_date IS NOT NULL THEN

            l_expiry_date := l_actual_shipment_date + NVL(l_revrec_expiration_days,0);

        ELSIF l_actual_shipment_date IS NULL THEN

            BEGIN
                SELECT fulfillment_date
                INTO l_fulfillment_date
                FROM oe_order_lines_all
                WHERE line_id = l_line_id;
            EXCEPTION

                WHEN OTHERS THEN
                    oe_debug_pub.add('Exception in getting the fulfillment date');

            END;

            l_expiry_date := l_fulfillment_date + NVL(l_revrec_expiration_days,0);

        END IF;
    END IF;
    -- bug 8293484

/*myerrams, Bug:5161878
    g_action_request_tbl(l_table_loop_index).entity_code  := OE_GLOBALS.G_ENTITY_LINE;
    g_action_request_tbl(l_table_loop_index).request_type := OE_GLOBALS.G_ACCEPT_FULFILLMENT;
    g_action_request_tbl(l_table_loop_index).entity_id    := l_line_id;
    g_action_request_tbl(l_table_loop_index).param4       := 'Y';
    g_action_request_tbl(l_table_loop_index).param5       := l_header_id;
    g_action_request_tbl(l_table_loop_index).date_param1  := SYSDATE;
myerrams, Bug:5161878 end*/
    l_action_request_tbl(l_table_loop_index).entity_code  := OE_GLOBALS.G_ENTITY_LINE;
    l_action_request_tbl(l_table_loop_index).request_type := OE_GLOBALS.G_ACCEPT_FULFILLMENT;
    l_action_request_tbl(l_table_loop_index).entity_id    := l_line_id;
    l_action_request_tbl(l_table_loop_index).param4       := 'Y';
    l_action_request_tbl(l_table_loop_index).param5       := l_header_id;
    --l_action_request_tbl(l_table_loop_index).date_param1  := SYSDATE; --bug 8293484
    l_action_request_tbl(l_table_loop_index).date_param1  := l_expiry_date; -- bug 8293484
    l_table_loop_index := l_table_loop_index + 1;

IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Implicit Acceptance: inside l_status condition');
      oe_debug_pub.add('Implicit Acceptance: entity_code:'||OE_GLOBALS.G_ENTITY_LINE);
      oe_debug_pub.add('Implicit Acceptance: request_type:'||OE_GLOBALS.G_ACCEPT_FULFILLMENT);
      oe_debug_pub.add('Implicit Acceptance: entity_id:'||l_line_id);
      oe_debug_pub.add('Implicit Acceptance: param5:'||l_header_id);
      oe_debug_pub.add('Implicit Acceptance: date_param1:'||l_expiry_date); --bug 8293484
END IF;
  END LOOP;
  g_action_request_tbl := l_action_request_tbl;		--myerrams,  Bug:5161878
  CLOSE g_cust_lines;

--Call Process Order API for further processing
  call_process_order_api;

END process_all_lines;
--=============================================================================
-- PROCEDURE : process_expired_lines
-- PARAMETERS: p_org_id
--
-- COMMENT   : TODO
--=============================================================================
PROCEDURE process_expired_lines
IS
l_cust_query                        VARCHAR2(15000) := 'SELECT  oel.line_id  '||
                                                              ', oel.header_id '||
							      ', oel.item_type_code '||
							      ', oel.flow_status_code '||
							      ', oel.actual_shipment_date '||
							      ', oel.service_reference_type_code '||
							      ', oel.service_reference_line_id '||
							      ', oel.top_model_line_id '||
							      ', oel.contingency_id '||
							      ', oel.accepted_quantity '||
							      ', oel.sold_to_org_id '||
							      ', oel.revrec_expiration_days ';
l_line_id                         NUMBER;
l_header_id                       NUMBER;
l_item_type_code                  VARCHAR(30);
l_flow_status_code                VARCHAR(30);
l_actual_shipment_date            DATE;
l_service_reference_type_code     VARCHAR(30);
l_service_reference_line_id       NUMBER;
l_top_model_line_id               NUMBER;
l_contingency_id                  NUMBER;
l_accepted_quantity               NUMBER;
l_sold_to_org_id                  NUMBER;
l_revrec_expiration_days	  NUMBER;
l_table_loop_index                NUMBER := 1;
l_status                          BOOLEAN;
l_action_request_tbl              OE_ORDER_PUB.Request_Tbl_Type;	--myerrams, Bug:5161878
l_query_where_clause              VARCHAR2(3000);			--myerrams, Bug: 5235959
l_max_actual_shipment_date	  DATE;					--myerrams, Bug: 5212583
l_count				  NUMBER;				--myerrams, Bug: 5212583
l_debug_level		CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_query_from_clause		  VARCHAR2(100);

l_expiry_date DATE := SYSDATE; -- bug 8293484
l_fulfillment_date DATE; -- bug 8293484

-- ======================
-- Dynamic Cursor Variable
-- =======================
TYPE g_cust_lines_type              IS REF CURSOR;
g_cust_lines                        g_cust_lines_type;

BEGIN

IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Implicit Acceptance: Inside Process_expired_lines');
END IF;

/* myerrams, Bug: 5531056. Modified the l_cust_query to restrict records with Acceptance Expire Event as Ship Confirm Date and REVREC_EVENT_CODE as Invoicing (Pre-Billing Acceptance) */
l_query_where_clause := ' WHERE oel.contingency_id = arc.contingency_id AND oel.flow_status_code = :1 AND oel.org_id = :2 and oel.open_flag = :3 AND arc.expiration_event_code = :4 AND oel.REVREC_EVENT_CODE = :5 ';
l_query_from_clause := ' FROM oe_order_lines_all oel, ar_deferral_reasons arc ';
l_cust_query := l_cust_query || l_query_from_clause || l_query_where_clause;
IF l_debug_level  > 0 THEN
  oe_debug_pub.add('Implicit Acceptance: the query that is being executed is:'||l_cust_query);
END IF;

  OPEN g_cust_lines FOR l_cust_query
  USING 'PRE-BILLING_ACCEPTANCE',g_org_id,'Y', 'SHIP_CONFIRM_DATE', 'INVOICING' ;  --myerrams, Bug: 5297684
  LOOP
    FETCH g_cust_lines
    INTO  l_line_id
	, l_header_id
	, l_item_type_code
	, l_flow_status_code
	, l_actual_shipment_date
	, l_service_reference_type_code
	, l_service_reference_line_id
	, l_top_model_line_id
	, l_contingency_id
	, l_accepted_quantity
	, l_sold_to_org_id
	, l_revrec_expiration_days;
    EXIT WHEN g_cust_lines%NOTFOUND;

    IF l_item_type_code = 'SERVICE'
       AND l_service_reference_type_code ='CUSTOMER_PRODUCT'
       AND l_service_reference_line_id IS NOT NULL
    THEN
      l_status := validate_service_lines
                    ( l_service_reference_line_id
		    , l_sold_to_org_id
		    );
/*myerrams, Bug: 5212583. Modified the Logic for Non Shippable Lines. */
    ELSE
        g_fulfillment_action := OE_GLOBALS.G_ACCEPT_FULFILLMENT;
	IF l_actual_shipment_date IS NULL THEN
	  IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('Inside Non Shippable line Logic');
	  END IF;
	  IF (l_item_type_code = 'KIT' or l_item_type_code = 'MODEL') and l_top_model_line_id = l_line_id THEN
	    IF l_debug_level  > 0 THEN
	      oe_debug_pub.add('Inside KIT or MODEL Item Logic, Line_id:'||l_line_id);
	    END IF;
                  SELECT count(*)
                  INTO l_count
                  FROM oe_order_lines_all
                  WHERE header_id = l_header_id
                  AND top_model_line_id = l_line_id
                  AND flow_status_code NOT IN ('PRE-BILLING_ACCEPTANCE')	--myerrams, Bug: 5290313
		  AND nvl(open_flag, 'Y') = 'Y';
		/* If all the Child/Included lines are either Pending Pre-Billing_Acceptance or Closed */
		IF l_count = 0 THEN
                  SELECT max(actual_shipment_date)
                  INTO l_max_actual_shipment_date
                  FROM oe_order_lines_all
                  WHERE header_id = l_header_id
                  AND top_model_line_id = l_line_id;

		  IF l_max_actual_shipment_date IS NULL THEN
			l_status := TRUE;
		  ELSE
			l_status := validate_expiration
				 ( l_max_actual_shipment_date
				 , l_revrec_expiration_days
				 );
			l_actual_shipment_date := l_max_actual_shipment_date;	  -- bug 8293484
		  END IF;
		ELSE
	  		l_status := FALSE;
		END IF;
	   ELSE
	   l_status := TRUE;
	   END IF;
	ELSE
	      l_status := validate_expiration
                   ( l_actual_shipment_date
		   , l_revrec_expiration_days
		   );
	END IF;
    END IF;

    -- bug 8293484
    IF g_acceptance_date = 'E' THEN

        IF l_actual_shipment_date IS NOT NULL THEN

            l_expiry_date := l_actual_shipment_date + NVL(l_revrec_expiration_days,0);

        ELSIF l_actual_shipment_date IS NULL THEN

            BEGIN
                SELECT fulfillment_date
                INTO l_fulfillment_date
                FROM oe_order_lines_all
                WHERE line_id = l_line_id;
            EXCEPTION

                WHEN OTHERS THEN
                    oe_debug_pub.add('Exception in getting the fulfillment date'); -- exception should be raised

            END;

            l_expiry_date := l_fulfillment_date + NVL(l_revrec_expiration_days,0);

        END IF;
    END IF;
    --bug 8293484

    IF l_status
    THEN
--      g_action_request_tbl(l_table_loop_index).request_type := OE_GLOBALS.G_BOOK_ORDER;
/*myerrams,  Bug:5161878
      g_action_request_tbl(l_table_loop_index).entity_code  := OE_GLOBALS.G_ENTITY_LINE;
      g_action_request_tbl(l_table_loop_index).request_type := OE_GLOBALS.G_ACCEPT_FULFILLMENT;
      g_action_request_tbl(l_table_loop_index).entity_id    := l_line_id;
--myerrams, Bug:4751568      g_action_request_tbl(l_table_loop_index).param4       := 'N';
      g_action_request_tbl(l_table_loop_index).param4       := 'Y';
      g_action_request_tbl(l_table_loop_index).param5       := l_header_id;
      g_action_request_tbl(l_table_loop_index).date_param1  := SYSDATE;
myerrams,  Bug:5161878. end.*/

      l_action_request_tbl(l_table_loop_index).entity_code  := OE_GLOBALS.G_ENTITY_LINE;
      l_action_request_tbl(l_table_loop_index).request_type := g_fulfillment_action;--OE_GLOBALS.G_ACCEPT_FULFILLMENT;  --myerrams
      l_action_request_tbl(l_table_loop_index).entity_id    := l_line_id;
      l_action_request_tbl(l_table_loop_index).param4       := 'Y';
      l_action_request_tbl(l_table_loop_index).param5       := l_header_id;
      --l_action_request_tbl(l_table_loop_index).date_param1  := SYSDATE; --bug 8293484
      l_action_request_tbl(l_table_loop_index).date_param1  := l_expiry_date; --bug 8293484
      l_table_loop_index := l_table_loop_index + 1;

IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Implicit Acceptance: inside l_status condition');
      oe_debug_pub.add('Implicit Acceptance: entity_code:'||OE_GLOBALS.G_ENTITY_LINE);
      oe_debug_pub.add('Implicit Acceptance: request_type:'||g_fulfillment_action);	--myerrams, Bug: 5212583
      oe_debug_pub.add('Implicit Acceptance: entity_id:'||l_line_id);
      oe_debug_pub.add('Implicit Acceptance: param5:'||l_header_id);
      oe_debug_pub.add('Implicit Acceptance: date_param1:'||l_expiry_date); -- bug 8293484
END IF;
    END IF;
  END LOOP;
  g_action_request_tbl := l_action_request_tbl; --myerrams, Bug:5161878
  call_process_order_api;
END process_expired_lines;

--=============================================================================
-- PROCEDURE : call_process_order_api
-- PARAMETERS: None
--
-- COMMENT   : TODO
--=============================================================================
PROCEDURE call_process_order_api
IS
l_header_out_rec            OE_ORDER_PUB.Header_Rec_Type;
l_header_adj_out_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
l_header_price_att_out_tbl  OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
l_header_adj_att_out_tbl    OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
l_header_adj_assoc_out_tbl  OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
l_header_scredit_out_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
l_line_out_tbl              OE_ORDER_PUB.Line_Tbl_Type;
l_line_adj_out_tbl          OE_ORDER_PUB.Line_Adj_Tbl_Type;
l_line_price_att_out_tbl    OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
l_line_adj_att_out_tbl	    OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
l_line_adj_assoc_out_tbl    OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
l_line_scredit_out_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
l_lot_serial_out_tbl        OE_Order_PUB.Lot_Serial_Tbl_Type;
l_action_request_out_tbl    OE_Order_PUB.Request_Tbl_Type;
l_debug_level		CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level  > 0 THEN
oe_debug_pub.add('Implicit Acceptance: Before call to Process Order API');
END IF;
  OE_Order_PVT.Process_Order( p_api_version_number       => 1.0
                            , x_return_status	         => g_return_status
			    , x_msg_count                => g_msg_count
			    , x_msg_data	         => g_msg_data
			    , p_x_header_rec	         => l_header_out_rec
			    , p_x_header_adj_tbl         => l_header_adj_out_tbl
			    , p_x_header_price_att_tbl	 => l_header_price_att_out_tbl
			    , p_x_header_adj_att_tbl	 => l_header_adj_att_out_tbl
			    , p_x_header_adj_assoc_tbl   => l_header_adj_assoc_out_tbl
			    , p_x_header_scredit_tbl	 => l_header_scredit_out_tbl
			    , p_x_line_tbl		 => l_line_out_tbl
			    , p_x_line_adj_tbl           => l_line_adj_out_tbl
			    , p_x_line_price_att_tbl     => l_line_price_att_out_tbl
			    , p_x_line_adj_att_tbl	 => l_line_adj_att_out_tbl
			    , p_x_line_adj_assoc_tbl	 => l_line_adj_assoc_out_tbl
			    , p_x_line_scredit_tbl       => l_line_scredit_out_tbl
			    , p_x_lot_serial_tbl         => l_lot_serial_out_tbl
			    , p_x_action_request_tbl	 => g_action_request_tbl
                            );
IF l_debug_level  > 0 THEN
oe_debug_pub.add('Implicit Acceptance: After call to Process Order API');
END IF;
--myerrams, decode the message
if g_msg_count > 0 then
	for k in 1 .. g_msg_count loop
		g_msg_data := oe_msg_pub.get( p_msg_index => k,
					      p_encoded => 'F'
					    );
		g_msg_data := g_msg_data || k || '.' ||  g_msg_data || '  ' ;
	end loop;
end if;
IF l_debug_level  > 0 THEN
oe_debug_pub.add('Implicit Acceptance: Process Order Error Msgs -> g_msg_data:'||g_msg_data);
END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
--  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  g_errbuf := 'Unexpected Error while calling process order API: '||g_msg_data;
  g_retcode := 2;
  g_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;	--myerrams

 WHEN FND_API.G_EXC_ERROR
  THEN
--  RAISE FND_API.G_RET_STS_ERROR;
  g_errbuf := 'Error while calling process order API: '||g_msg_data;
  g_retcode := 2;
  g_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS
  THEN
  g_errbuf := 'Others Exception while calling process order API: '||g_msg_data;
  g_retcode := 2;
  g_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
-- Do the status processing

END call_process_order_api;
--=============================================================================
-- PROC NAME     : validate_service_lines
-- DESCRIPTION   : Validates whether parent line associted with the service line
--                 is accepted or not.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--=============================================================================
FUNCTION validate_service_lines
( p_service_ref_line_id	      IN NUMBER
, p_sold_to_org_id            IN NUMBER
)
RETURN BOOLEAN
IS
l_return_status		VARCHAR2(100);
l_product_line_id	NUMBER;
l_line_id		NUMBER;
l_contingency_id	NUMBER;
l_revrec_event_code	VARCHAR2(30);
l_accepted_quantity	NUMBER;
l_debug_level		CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  OE_SERVICE_UTIL.Get_Cust_Product_Line_Id( x_return_status        => l_return_status
                                          , p_reference_line_id    => p_service_ref_line_id
                                          , p_customer_id          => p_sold_to_org_id
					  , x_cust_product_line_id => l_product_line_id
					  );
  SELECT line_id
       , contingency_id
       , revrec_event_code
       , accepted_quantity
  INTO   l_line_id
       , l_contingency_id
       , l_revrec_event_code
       , l_accepted_quantity
  FROM   oe_order_lines_all
  WHERE  line_id = l_product_line_id;

  IF l_contingency_id IS NOT NULL
     AND l_accepted_quantity IS NOT NULL
     AND l_revrec_event_code = 'INVOICING'
  THEN
    IF l_accepted_quantity = 0
    THEN
      g_fulfillment_action := OE_GLOBALS.G_REJECT_FULFILLMENT;
    ELSE
      g_fulfillment_action := OE_GLOBALS.G_ACCEPT_FULFILLMENT;
    END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Implicit Acceptance: validate_service_lines returns true');
END IF;
    RETURN TRUE;
  ELSE
IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Implicit Acceptance: validate_service_lines returns false');
END IF;
    RETURN FALSE;
  END IF;

END validate_service_lines;
--=============================================================================
-- PROC NAME     : validate_expiration
-- DESCRIPTION   : Validates whether order line is expired or not.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--=============================================================================
FUNCTION validate_expiration
(  p_actual_shipment_date	IN DATE
 , p_revrec_expiration_days	IN NUMBER
)
RETURN BOOLEAN
IS
l_reference_date                DATE;
l_revrec_expiration_days	NUMBER;
l_debug_level			CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  l_reference_date := p_actual_shipment_date;

/* myerrams, Bug: 5531056; If Exipration Days is null, then its explicit acceptance.
   This SO line will never expire. So, Returning False. */
  IF p_revrec_expiration_days IS NULL THEN
    RETURN FALSE;
  ELSE
    l_revrec_expiration_days := p_revrec_expiration_days;
  END IF;
  IF l_reference_date + l_revrec_expiration_days < SYSDATE
  THEN
   RETURN TRUE;
  ELSE
   RETURN FALSE;
  END IF;
END validate_expiration;

END ONT_ImplicitCustAccept_PVT;

/
